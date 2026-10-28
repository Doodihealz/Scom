-- Retail FA projectile behavior, scoped by source ID and blueprint digest.
local M = {pendingDamage = {}}
local contracts, ProjectileClass, launch
local function vec(x,y,z) return EngineClasses.float3(x,y,z) end
local function copy(v) return vec(v.x,v.y,v.z) end
local function length(v) return math.sqrt(v.x*v.x+v.y*v.y+v.z*v.z) end
local function scaled(v, speed)
    local n=length(v)
    if n<0.000001 then return vec(0,0,speed) end
    return vec(v.x*speed/n,v.y*speed/n,v.z*speed/n)
end
local function source(self)
    local a=self.tp and self.tp.additions
    local s=a and a.scoSourceProjectile
    if not s or a.scoTacticalProjectile or self.scoTactical or self.sourceNuke then return end
    local key=self.tp.general and self.tp.general.tpId
    local expected=contracts and contracts.projectiles[key]
    if not expected then return end
    assert(s.sourceId:lower()==expected.sourceId:lower() and
        s.blueprintSha256:lower()==expected.blueprintSha256:lower(), 'Source projectile motion identity drift '..key)
    return expected
end
local function weaponSource(weapon)
    if not weapon or weapon.tp.scoTacticalOwned then return end
    if weapon.tp.scoFaSourceWeapon then return weapon.tp.scoFaSourceWeapon end
    local identity=weapon.tp.scoFaProjectileIdentity
    local rows=contracts.units[weapon.unit.tpId]
    return rows and identity and rows[identity.sourceIndex]
end
local splits={
    aifguidedmissile01={event='time',delay=.1,child='aifguidedmissile02',count=8,speed=16,speedRange=.2,spread=.4,radialRange={.6,1.3},vertical=.8,divide=true},
    aantorpedocluster01={event='water',child='aantorpedoclustersplit01',count=2,inherit=true},
    aiffragmentationsensorshell01={event='impact',child='aiffragmentationsensorshell02',count=5,center=true,speed=16,spread=.8,variation=8,vertical=.8},
    aiffragmentationsensorshell02={event='impact',child='aiffragmentationsensorshell03',count=5,center=true,speed=12,spread=.4,variation=13,vertical=.8,shieldDamage=true},
    aifmiasmashell01={event='impact',child='aifmiasmashell02',count=1,speedMultiplier=10,inherit=true},
    sanheavycavitationtorpedo01={event='waterTime',delay=1,child='sanheavycavitationtorpedo04',count=3,speed=10,spread=.4,variation=.3,divide=true},
    sanheavycavitationtorpedo02={event='time',delay=.5,child='sanheavycavitationtorpedo03',count=3,speed=7,spread=.4,variation=.4,divide=true},
    sifthunthoartilleryshell01={event='impact',child='sifthunthoartilleryshell02',count=5,speed=18,spread=.15,variation=.8},
    tiffragmentationsensorshell01={event='impact',child='tiffragmentationsensorshell02',count=4,center=true,speed=6,spread=.5,variation=.35},
}
local waterProfiles={
    aantorpedoclustersplit01={acceleration=2.5,turn=180},
    cantorpedonanite01={turn=120},
    cantorpedonanite02={turn=120,maxSpeed=18,speed=3},
    cantorpedonanite03={turn=240},
    tananglertorpedo01={turn=120,maxSpeed=18,delayedSpeed=3},
    tananglertorpedo06={turn=240,maxSpeed=18},
    sanheavycavitationtorpedo01={turn=240},
    aandepthcharge01={turn=180,maxSpeed=20,acceleration=5,speed=0,delayedSpeed=.5},
    aandepthcharge03={turn=240},
}
local depthCharges={aandepthcharge01=true,aandepthcharge03=true,aantorpedoclustersplit01=true}
local phases={
    caamissilenanite02={{at=1.5,maxSpeed=80,acceleration=10,accelerationRange=8}},
    caamissilenanite03={{at=1.5,maxSpeed=80,acceleration=10,accelerationRange=8}},
    caananodart01={{at=.35,maxSpeed=2,gravity=-.5},{at=.85,maxSpeed=50,acceleration=8,accelerationRange=5},{at=1.15,turn=360}},
    caananodart03={{at=.35,maxSpeed=2,gravity=-.5},{at=.85,maxSpeed=50,acceleration=8,accelerationRange=5},{at=1.15,turn=360}},
    caananodart04={{at=0,maxSpeed=50},{at=.25,gravity=-.5,acceleration=8,accelerationRange=5},{at=.55,turn=360}},
    cifmissiletacticalsplit01={{at=.3,turn=80,maxSpeed=25,acceleration=25,track=true}},
    aifguidedmissile02={{at=.6,track=true}},
}
function M.Configure(value)
    contracts=value
    M.ids={}
    for target,row in pairs(value.projectiles) do M.ids[row.sourceId:lower()]=target end
end
local function setVelocity(self,value)
    local state=self.scoSourceMotion
    state.velocity=copy(value)
    if length(value)>.000001 then state.direction=scaled(value,1) end
    if self.tp.movement and self.tp.movement.type then
        Engine.SetHomingProjectileVelocity(self.id,value)
    else
        Engine.SetCurvedProjectileSpeed(self.id,length(value))
    end
end
local function target(self,state)
    if not state.targetID or not Engine.IsValidGlobalID(state.targetID) then return end
    if state.physics.TrackTargetGround or state.underwater then
        local _,p=Engine.GetGlobalEntityWorldPosition(state.targetID)
        local _,h=Engine.SampleTerrainHeight(p)
        local _,hasWater=Engine.HasWater()
        if hasWater then
            local _,w=Engine.GetWaterLevel()
            h=state.underwater and math.min(p.y,w) or math.max(h,w)
        elseif state.underwater then h=p.y end
        local aim = vec(p.x,h,p.z)
        Engine.SetHomingProjectileTargetPosition(self.id,aim)
        if state.cruiseTurnAt then state.cruiseTargetPosition=aim end
        if state.mobileCruiseAt then state.mobileCruiseTargetPosition=aim end
        Engine.SetHomingProjectileTargetType(self.id,HomingType.TargetPosition)
        state.fixedTarget=state.physics.TrackTargetGround==true
    else
        Engine.SetHomingProjectileTargetID(self.id,state.targetID)
        Engine.SetHomingProjectileTargetType(self.id,HomingType.TargetGlobalID)
    end
end
local function MobileCruiseDistance(position, targetPosition)
    local x, z = position.x - targetPosition.x, position.z - targetPosition.z
    return math.sqrt(x*x + z*z)
end

local function MobileCruiseRangeTurn(self, state, distance)
    state.mobileCruisePhase = 'range'
    if distance > 50 then
        state.mobileCruiseNextTurn, state.mobileCruiseAt = 10, _G.Time + 2
    elseif distance > 30 then
        Engine.SetHomingProjectileRotationSpeed(self.id, 12)
        state.mobileCruiseNextTurn, state.mobileCruiseAt = 12, _G.Time + 1.5
    elseif distance > 10 and distance <= 25 then
        state.mobileCruiseNextTurn, state.mobileCruiseAt = 50, _G.Time + .3
    elseif distance > 0 and distance <= 10 then
        Engine.SetHomingProjectileRotationSpeed(self.id, 100)
        state.mobileCruiseAt = nil
    else
        -- Retail deliberately leaves the 25..30 interval at its current rate.
        state.mobileCruisePhase, state.mobileCruiseAt = 'check', _G.Time + .1
    end
end

local function UpdateMobileCruise(self, state, position)
    if not state.mobileCruiseAt or _G.Time + .000001 < state.mobileCruiseAt then return end
    if not state.mobileCruiseTargetPosition then state.mobileCruiseAt = nil; return end
    local distance = MobileCruiseDistance(position, state.mobileCruiseTargetPosition)
    if state.mobileCruisePhase == 'recover' then
        Engine.SetHomingProjectileRotationSpeed(self.id, 8)
        state.mobileCruiseDistance = distance
        MobileCruiseRangeTurn(self, state, state.mobileCruisePendingDistance)
        state.mobileCruisePendingDistance = nil
    elseif state.mobileCruisePhase == 'range' then
        Engine.SetHomingProjectileRotationSpeed(self.id, state.mobileCruiseNextTurn)
        state.mobileCruiseNextTurn = nil
        state.mobileCruisePhase, state.mobileCruiseAt = 'check', _G.Time + .1
    elseif distance > state.mobileCruiseDistance then
        Engine.SetHomingProjectileRotationSpeed(self.id, state.mobileCruiseOvershootTurn)
        state.mobileCruisePendingDistance = distance
        state.mobileCruisePhase, state.mobileCruiseAt = 'recover', _G.Time + 3
    else
        MobileCruiseRangeTurn(self, state, distance)
    end
end

function M.Created(self)
    local row=source(self)
    if not row or (launch and launch.weapon and launch.weapon.tp.scoTacticalOwned) then return end
    local bp=row.physics
    local sw=launch and weaponSource(launch.weapon)
    local lifetime=(sw and sw.ProjectileLifetime) or 0
    if lifetime<=0 then lifetime=bp.Lifetime or 15 end
    if sw and sw.ProjectileLifetimeUsesMultiplier and (sw.MuzzleVelocity or 0)>0 then
        lifetime=sw.ProjectileLifetimeUsesMultiplier*(sw.MaxRadius or 0)/sw.MuzzleVelocity
    end
    if row.sourceId:lower()=='cdfrocketiridium02' and launch and launch.weapon and launch.weapon.unit.tpId=='ugl2101' then
        -- The final Hoplite template grants 4.25s for its native curved flight.
        -- Keep that validated lifetime instead of reverting to the source 2.84s.
        lifetime=math.max(lifetime,self.lifetime or 0)
    end
    self.lifetime=lifetime
    local _,position=Engine.GetGlobalEntityWorldPosition(self.id)
    local _,rotation=Engine.GetGlobalEntityWorldRotation(self.id)
    local velocity=Engine.QuaternionRotateVector(rotation,vec(0,0,1))
    velocity=scaled(velocity,(launch and launch.speed) or bp.InitialSpeed or 0)
    local state={row=row,physics=bp,weapon=sw,velocity=velocity,position=copy(position),sampleTime=_G.Time,
        damage=self.damage,radius=self.damageRadius,targetID=launch and launch.targetID,
        split=splits[row.sourceId:lower()],friendly=sw and sw.DamageFriendly or false,tracking=bp.TrackTarget==true,
        underwater=bp.StayUnderwater==true,direction=Engine.QuaternionRotateVector(rotation,vec(0,0,1))}
    self.scoSourceMotion=state
    if row.sourceId:lower()=='cifmissiletactical01' and self.sourceUnit
        and self.sourceUnit.tpId=='ugl5002' then
        local contract=self.sourceUnit.tp.additions.faSourceContract
        assert(contract.sourceId=='URL0111' and contract.sourceBlueprintSha256==
            'c2e3e514e2a31ab9b0de215b29dc22e1b34571b09dd82f6e3297489ed05900b6',
            'Cybran mobile split source drift')
        state.splitDamage=contract.sourceSplitDamage
    end
    if sw and sw.DoTTime and sw.DoTTime>0 then
        -- Some earlier ports flattened all pulses into native weapon.damage.
        -- Restoring pulse timing must use the source per-pulse amount once.
        state.damage=sw.Damage or state.damage
        state.radius=sw.DamageRadius or 0
    end
    if row.sourceId:lower()=='aifguidedmissile01' and launch and launch.weapon and launch.weapon.unit.tpId=='uca5001' then
        -- DAA0206.ProjectileFired calls Destroy directly: consume the airframe
        -- after native muzzle dispatch finishes, without a second death weapon.
        launch.consumeUnit=launch.weapon.unit
    end
    state.depthCharge=depthCharges[row.sourceId:lower()]
    state.phases=phases[row.sourceId:lower()]
    state.phaseIndex=1
    local sourceId=row.sourceId:lower()
    if sourceId=='tifmissilecruise03' or sourceId=='tifmissilecruise05'
        or sourceId=='aifmissileserpentine01' or sourceId=='cifmissiletactical01'
        or sourceId=='siflaansetacticalmissile01' then
        state.mobileCruiseAt, state.mobileCruisePhase = _G.Time + .3, 'check'
        state.mobileCruiseOvershootTurn = sourceId=='tifmissilecruise05' and 50 or 75
    end
    if sourceId=='tifmissilecruise04' or sourceId=='siflaansetacticalmissile02' then
        -- Both source cruiser scripts launch at 8 degrees/s, then adjust turn
        -- rate by horizontal distance. Their blueprint TurnRate=0 is not final.
        state.cruiseTurnAt=_G.Time+.3
    end
    if (row.sourceId:lower()=='sanheavycavitationtorpedo03' or row.sourceId:lower()=='sanheavycavitationtorpedo04') and state.targetID then
        local _,p=Engine.GetGlobalEntityWorldPosition(state.targetID)
        local distance=math.sqrt((p.x-position.x)^2+(p.z-position.z)^2)
        local delay=distance>18 and 1 or (distance>12 and .7 or (distance>6 and .45 or .2))
        state.phases={{at=delay,track=true,turn=distance>6 and 360 or 720,
            maxSpeed=row.sourceId:lower()=='sanheavycavitationtorpedo03' and 20 or 14}}
    end
    if state.depthCharge then state.explodeAt=_G.Time+10;self.lifetime=math.max(self.lifetime,10.1) end
    if row.sourceId:lower()=='cifmissiletacticalsplit01' then
        state.invulnerableUntil=_G.Time+.3
        local owner=assert(_G.SCO_SourceInterception,'Source child interception owner missing')
        owner.SetInvulnerability(self,.3)
    end
    if state.split and state.split.event=='impact' or (sw and sw.DoTTime and sw.DoTTime>0) then
        -- Native collision dispatch damages before calling Destroy. These source
        -- scripts replace that damage with children or pulses, so suppress it here.
        self.damage,self.damageRadius=0,0
    end
    if bp.UseGravity==false then Engine.SetProjectileGravity(self.id,vec(0,0,0)) end
    if self.tp.movement and self.tp.movement.type then
        if bp.Acceleration~=nil then Engine.SetHomingProjectileAcceleration(self.id,bp.Acceleration) end
        if bp.MaxSpeed~=nil then Engine.SetHomingProjectileMaxSpeed(self.id,bp.MaxSpeed) end
        if bp.TurnRate~=nil then Engine.SetHomingProjectileRotationSpeed(self.id,bp.TurnRate) end
        if bp.TrackTarget==false then Engine.SetHomingProjectileRotationSpeed(self.id,0) end
        if state.cruiseTurnAt or state.mobileCruiseAt then Engine.SetHomingProjectileRotationSpeed(self.id,8) end
        if row.sourceId:lower()=='sanheavycavitationtorpedo01' then
            Engine.SetHomingProjectileRotationSpeed(self.id,0);state.tracking=false
        end
        target(self,state)
        if state.mobileCruiseTargetPosition then
            state.mobileCruiseDistance = MobileCruiseDistance(position, state.mobileCruiseTargetPosition)
        end
    end
    if state.split and state.split.event=='time' then state.splitAt=_G.Time+state.split.delay end
    local _,hasWater=Engine.HasWater()
    if hasWater then
        local _,level=Engine.GetWaterLevel()
        if position.y<level then
            if state.split and state.split.event=='water' then state.initialWater=copy(position)
            else M.Water(self,position) end
        elseif row.sourceId:lower()=='cantorpedonanite01' then
            Engine.SetProjectileGravity(self.id,vec(0,-20,0))
            Engine.SetHomingProjectileRotationSpeed(self.id,0)
            state.tracking=false
        end
    end
    if row.sourceId:lower()=='caananodart04' and state.targetID then
        local _,p=Engine.GetGlobalEntityWorldPosition(state.targetID)
        setVelocity(self,vec(p.x-position.x,p.y-position.y-40,p.z-position.z))
    end
end
local function velocity(self)
    if _G.SCO_GetSourceProjectileVelocity then
        local value=_G.SCO_GetSourceProjectileVelocity(self.id)
        if value then return value end
    end
    return self.scoSourceMotion.velocity
end
local function rand(a,b) return a+(b-a)*math.random() end
function M.SpawnChild(self,childId,value,damage)
    local state=self.scoSourceMotion
    local tp=assert(__Templates.Projectiles[childId],'Missing source child '..childId)
    assert(tp.general.prefabID,'Source child has no prefab '..childId)
    local _,position=Engine.GetGlobalEntityWorldPosition(self.id)
    position=state.impactPosition or position
    local rotation=Engine.QuaternionLookRotationSafe(value,vec(0,1,0))
    local commands=Import('common/commands/definitions/projectiles.lua')
    local result,id=Engine.InstantiatePrefab(tp.general.prefabID,position,vec(1,1,1),rotation)
    assert(result==EngineErrorCode.Success and id,'Source child instantiate failed '..childId)
    local previous=launch
    local child,createSent
    local ok,failure=pcall(function()
        commands.CreateProjectile.Send(id,self.armyId)
        createSent=true
        launch={targetID=state.targetID,speed=length(value)}
        child=ProjectileClass(id,self.armyId,tp,damage,state.radius,15,self.muzzleId,self.sourceUnit)
        __Entities.Projectiles[id.index]=child
        local cs=assert(child.scoSourceMotion,'Child source contract not bound '..childId)
        cs.weapon,cs.friendly=state.weapon,state.friendly
        child.damageFriendly=state.friendly
        if cs.weapon and cs.weapon.DoTTime and cs.weapon.DoTTime>0 then child.damage,child.damageRadius=0,0 end
        setVelocity(child,value)
        local p=cs.physics
        Engine.SetProjectileGravity(id,vec(0,p.UseGravity and -4.9 or 0,0))
    end)
    launch=previous
    if not ok then
        if child then
            local deleted=pcall(child.Delete,child)
            if not deleted then
                __Entities.Projectiles[id.index]=nil
                pcall(Engine.DeletePrefabInstance,id,false)
            end
        else
            if createSent then pcall(commands.DeleteProjectile.Send,id) end
            pcall(Engine.DeletePrefabInstance,id,false)
        end
        error(failure)
    end
    return child
end
function M.Split(self)
    local state=self.scoSourceMotion
    if not state or state.splitDone then return end
    local spec=state.split
    state.splitDone=true
    local child=assert(M.ids[spec.child],'Missing source split map '..spec.child)
    local v=velocity(self)
    local y=v.y*(spec.vertical or 1)
    local damage=state.damage/(spec.divide and spec.count or 1)
    local speed=spec.speed or length(v)*(spec.speedMultiplier or 1)
    if spec.center then M.SpawnChild(self,child,scaled(vec(v.x,y,v.z),speed),damage) end
    local angle=2*math.pi/spec.count
    local initial=rand(0,angle)
    for i=0,spec.count-1 do
        local x,z=v.x,v.z
        if not spec.inherit then
            local variation=angle*(spec.variation or 0)
            local radial=spec.radialRange and rand(spec.radialRange[1],spec.radialRange[2]) or 1
            x=x+math.sin(initial+i*angle+rand(-variation,variation))*(spec.spread or 0)*radial
            z=z+math.cos(initial+i*angle+rand(-variation,variation))*(spec.spread or 0)*radial
        end
        local actualSpeed=speed*(spec.speedRange and rand(1-spec.speedRange,1+spec.speedRange) or 1)
        M.SpawnChild(self,child,scaled(vec(x,y,z),actualSpeed),damage)
    end
    self:Delete()
end
function M.Intercepted(self,damage,killed)
    if not killed then return false end
    local state=self.scoSourceMotion
    if not state or not source(self) or state.splitDone then return false end
    local sid=state.row.sourceId:lower()
    if sid~='cifmissiletactical01' and sid~='cifmissiletactical02' then return false end
    local sw=state.weapon
    local split=state.splitDamage or (sw and sw.SplitDamage)
    if not split then return false end
    state.damage=split.DamageAmount or 0
    state.radius=split.DamageRadius or 1
    state.split={child='cifmissiletacticalsplit01',count=3,
        speed=sid=='cifmissiletactical01' and 10 or 7,
        spread=sid=='cifmissiletactical01' and 1 or .5,variation=0}
    M.Split(self)
    return true
end
function M.Water(self,position)
    local state=self.scoSourceMotion
    if not state or not source(self) or state.enteredWater then return end
    state.enteredWater=true
    local profile=waterProfiles[state.row.sourceId:lower()]
    if profile and self.tp.movement and self.tp.movement.type then
        state.tracking=true
        state.underwater=true
        Engine.SetProjectileGravity(self.id,vec(0,0,0))
        if profile.turn then Engine.SetHomingProjectileRotationSpeed(self.id,profile.turn) end
        if profile.maxSpeed then Engine.SetHomingProjectileMaxSpeed(self.id,profile.maxSpeed) end
        if profile.acceleration then Engine.SetHomingProjectileAcceleration(self.id,profile.acceleration) end
        if profile.speed then setVelocity(self,scaled(velocity(self),profile.speed)) end
        if profile.delayedSpeed then state.waterSpeedAt=_G.Time+.1;state.waterSpeed=profile.delayedSpeed end
        target(self,state)
    end
    if state.split then
        if state.split.event=='water' then M.Split(self)
        elseif state.split.event=='waterTime' then state.splitAt=_G.Time+state.split.delay end
    end
end
local function damagePulse(job)
    if job.radius>0 then
        Import('host/collisionUpdate.lua').ProcessAreaDamage(job.position,job.radius,job.damage,Armies[job.armyId],job.friendly,job.sourceUnit)
    elseif job.target and not job.target.dead and not job.target.deleted then
        job.target:TakeDamage(job.damage,DestroyType.Kinetic,job.sourceUnit)
    end
end
local function impactTarget(id)
    if not id or not Engine.IsValidGlobalID(id) then return end
    local direct=__Entities.Shields[id.index] or __Entities.Units[id.index]
    if direct then return direct end
    local _,root=Engine.GetGlobalEntityRoot(id)
    return __Entities.Units[root.index] or __Entities.Shields[root.index]
end
function M.Impact(self,hitID)
    local state=self.scoSourceMotion
    if not state or not source(self) then return false end
    local sw=state.weapon
    if sw and type(sw.DamageToShields)=='number' and sw.DamageToShields>0 and not state.shieldBonusApplied then
        local hit=impactTarget(hitID)
        if hit and __Entities.Shields[hit.id.index]==hit then
            state.shieldBonusApplied=true
            local health=hit:GetHealth()
            if health>0 then hit:TakeDamage(math.min(health,sw.DamageToShields)) end
        end
    end
    if state.split and state.split.event=='impact' then
        local hit=impactTarget(hitID)
        if state.split.shieldDamage and hit and __Entities.Shields[hit.id.index]==hit then
            hit:TakeDamage(state.damage)
            return false
        end
        M.Split(self)
        return true
    end
    if sw and sw.DoTTime and sw.DoTTime>0 and not state.impacted then
        state.impacted=true
        local _,position=Engine.GetGlobalEntityWorldPosition(self.id)
        position=state.impactPosition or position
        local count=math.max(1,sw.DoTPulses or 1)
        local job={position=copy(position),radius=state.radius,damage=state.damage,armyId=self.armyId,
            friendly=state.friendly,sourceUnit=self.sourceUnit,target=impactTarget(hitID),remaining=count-1,interval=sw.DoTTime/count,nextTime=_G.Time+sw.DoTTime/count}
        damagePulse(job)
        if job.remaining>0 then M.pendingDamage[#M.pendingDamage+1]=job end
    end
    return false
end
function M.TickDamage()
    for i=#M.pendingDamage,1,-1 do
        local job=M.pendingDamage[i]
        while job.remaining>0 and _G.Time+0.000001>=job.nextTime do
            damagePulse(job);job.remaining=job.remaining-1;job.nextTime=job.nextTime+job.interval
        end
        if job.remaining==0 then table.remove(M.pendingDamage,i) end
    end
end
function M.WrapRayCollision(previous)
    return function(event,...)
        local projectile=__Entities.Projectiles[event.rayGlobalID.index]
        local state=projectile and projectile.scoSourceMotion
        if state then
            local d=math.max(event.hitDistance-.01,0)
            state.impactPosition=vec(event.rayOrigin.x+event.rayDirection.x*d,
                event.rayOrigin.y+event.rayDirection.y*d,event.rayOrigin.z+event.rayDirection.z*d)
        end
        local result=previous(event,...)
        if state then state.impactPosition=nil end
        return result
    end
end
function M.Update(self)
    local state=self.scoSourceMotion
    if not state or not source(self) then return end
    if state.initialWater then
        local p=state.initialWater;state.initialWater=nil;M.Water(self,p)
        if state.splitDone then return true end
    end
    local _,position=Engine.GetGlobalEntityWorldPosition(self.id)
    local dt=_G.Time-state.sampleTime
    if dt>0 then
        state.velocity=vec((position.x-state.position.x)/dt,(position.y-state.position.y)/dt,(position.z-state.position.z)/dt)
        state.position,state.sampleTime=copy(position),_G.Time
    end
    if state.splitAt and _G.Time+0.000001>=state.splitAt then M.Split(self);return true end
    if state.waterSpeedAt and _G.Time+0.000001>=state.waterSpeedAt then
        state.waterSpeedAt=nil
        local current=velocity(self)
        if length(current)<.000001 then current=state.direction end
        setVelocity(self,scaled(current,state.waterSpeed))
    end
    if state.underwater and state.tracking then target(self,state) end
    while state.phases and state.phases[state.phaseIndex] and
        _G.Time-self.spawnTime+0.000001>=state.phases[state.phaseIndex].at do
        local phase=state.phases[state.phaseIndex]
        if phase.maxSpeed then Engine.SetHomingProjectileMaxSpeed(self.id,phase.maxSpeed) end
        if phase.acceleration then Engine.SetHomingProjectileAcceleration(self.id,phase.acceleration+math.random()*(phase.accelerationRange or 0)) end
        if phase.turn then Engine.SetHomingProjectileRotationSpeed(self.id,phase.turn) end
        if phase.track then
            state.tracking=true
            if not phase.turn then Engine.SetHomingProjectileRotationSpeed(self.id,state.physics.TurnRate or 0) end
            target(self,state)
        end
        if phase.gravity then Engine.SetProjectileGravity(self.id,vec(0,phase.gravity,0)) end
        state.phaseIndex=state.phaseIndex+1
    end
    UpdateMobileCruise(self, state, position)
    if state.cruiseTurnAt and _G.Time+0.000001>=state.cruiseTurnAt then
        if state.cruisePendingTurn then
            Engine.SetHomingProjectileRotationSpeed(self.id,state.cruisePendingTurn)
            state.cruisePendingTurn=nil
            state.cruiseTurnAt=_G.Time+.1
        elseif state.cruiseTargetPosition then
            local dx=position.x-state.cruiseTargetPosition.x
            local dz=position.z-state.cruiseTargetPosition.z
            local distance=math.sqrt(dx*dx+dz*dz)
            if distance>50 then
                state.cruisePendingTurn=20
                state.cruiseTurnAt=_G.Time+2
            elseif distance>21 then
                state.cruisePendingTurn=50
                state.cruiseTurnAt=_G.Time+.3
            else
                Engine.SetHomingProjectileRotationSpeed(self.id,100)
                state.cruiseTurnAt=nil
            end
        else
            state.cruiseTurnAt=nil
        end
    end
    if state.explodeAt and _G.Time+0.000001>=state.explodeAt then
        damagePulse({position=copy(position),radius=state.radius,damage=state.damage,armyId=self.armyId,friendly=state.friendly,sourceUnit=self.sourceUnit})
        state.explodeAt=nil;self:Destroy(0,_G.WaterGlobalID);return true
    end
    if state.tracking and state.targetID and not state.fixedTarget and not state.lostAt
        and not Engine.IsValidGlobalID(state.targetID) then
        state.lostAt=_G.Time
        if state.depthCharge then
            Engine.SetHomingProjectileMaxSpeed(self.id,2)
            Engine.SetHomingProjectileAcceleration(self.id,-.6)
            state.stopAt=_G.Time+3
        else
            self.lifetime=math.min(self.lifetime,_G.Time-self.spawnTime+(state.physics.OnLostTargetLifetime or .5))
        end
    end
    if state.stopAt and _G.Time+0.000001>=state.stopAt then
        state.stopAt=nil
        Engine.SetHomingProjectileMaxSpeed(self.id,0)
        Engine.SetHomingProjectileAcceleration(self.id,0)
        setVelocity(self,vec(0,0,0))
    end
end
function M.InstallWeapon(class)
    if class.scoSourceMotionInstalled then return end
    class.scoSourceMotionInstalled=true
    local previous=class.UpdateProjectile
    local desired=class.GetDesiredProjectileValues
    class.GetDesiredProjectileValues=function(self,...)
        local speed,gravity,targetID=desired(self,...)
        if launch and launch.weapon==self then launch.speed,launch.targetID=speed,targetID end
        return speed,gravity,targetID
    end
    class.UpdateProjectile=function(self,...)
        local saved=launch
        launch={weapon=self}
        local ok,result=pcall(previous,self,...)
        local consume=launch.consumeUnit
        launch=saved
        if not ok then error(result,0) end
        if consume and not consume.dead and not consume.deleted then consume:Delete() end
        return result
    end
end
function M.InstallProjectile(class)
    if class.scoSourceMotionInstalled then return end
    class.scoSourceMotionInstalled=true
    ProjectileClass=class
    local init,update,destroy,water=class.__init,class.Update,class.Destroy,class.OnCrossedWaterline
    class.__init=function(self,...)
        init(self,...)
        M.Created(self)
    end
    class.Update=function(self,...)
        if not M.Update(self) then return update(self,...) end
    end
    class.Destroy=function(self,tick,hitID)
        if not M.Impact(self,hitID) then return destroy(self,tick,hitID) end
    end
    class.OnCrossedWaterline=function(self,position,tick,waterGlobalID)
        local state=self.scoSourceMotion
        if state and source(self) then
            if state.invulnerableUntil and _G.Time<state.invulnerableUntil then return end
            M.Water(self,position)
            if state.splitDone or state.physics.DestroyOnWater==false then return end
        end
        return water(self,position,tick,waterGlobalID)
    end
end
-- Native Import returns this module environment; plain Lua loaders keep the return API.
local moduleEnvironment = getfenv(1)
for name, value in pairs(M) do moduleEnvironment[name] = value end
return M
