-- Retail visual phases. Native weapons still own targeting, muzzles and damage.
local M={}
-- These two surviving native rigs already own four velocity-scaled rotators.
-- Preserve their axis/gain and use each axle's signed longitudinal velocity.
local NativeWheels={ugl1201={axis='x',gain=180},ugl3502={axis='y',gain=-180}}
local WheelNames={'Wheel01_Left','Wheel01_Right','Wheel02_Left','Wheel02_Right'}
local function WheelConfig(unit)
    local native=NativeWheels[unit.tpId]
    if not native then return end
    if unit.scoSignedWheelConfig~=nil then return unit.scoSignedWheelConfig or nil end
    local definitions=unit.tp and unit.tp.additions and unit.tp.additions.rotators or {}
    local found={}
    for _,definition in ipairs(definitions) do
        local speed=definition.speed or {}
        if definition.isVelocityScalingEnabled==true and speed[native.axis]==native.gain then
            local valid=true
            for _,axis in ipairs({'x','y','z'}) do
                if axis~=native.axis and (speed[axis] or 0)~=0 then valid=false end
            end
            if valid then found[definition.boneName]=true end
        end
    end
    local valid=#definitions==4
    for _,name in ipairs(WheelNames) do valid=valid and found[name] end
    if not valid then
        unit.scoSignedWheelConfig=false
        print('[SCOM visuals] Signed wheels skipped: changed '..unit.tpId..' rotator contract')
        return
    end
    local c={targetId=unit.tpId,wheels=native}
    unit.scoSignedWheelConfig=c
    return c
end
local function Config(unit)
    local c=unit.tp and unit.tp.additions and unit.tp.additions.scoSourceDynamicVisuals
    if not c then c=WheelConfig(unit) end
    if c then assert(c.targetId==unit.tpId,'Dynamic host target drift') end
    return c
end
local function Label(weapon)
    local tp=weapon.tp or {}
    return (tp.scoFaSourceWeapon and tp.scoFaSourceWeapon.Label)
        or (tp.scoFaProjectileIdentity and tp.scoFaProjectileIdentity.sourceLabel) or tp.scoSourceLabel or tp.name
end
local function State(unit,now)
    local s=unit.scoDynamicVisuals
    if not s then s={last=now,nextMonitor=now+1,serial=0};unit.scoDynamicVisuals=s end
    return s
end
local function Send(unit,kind,enabled,now,left,right,leftGoal,rightGoal)
    local s=State(unit,now);s.serial=s.serial+1
    Import('common/commands/definitions/units.lua').SCOSourceDynamicVisual.Send(unit.id,kind,s.serial,enabled,now,
        left or 0,right or 0,leftGoal or 0,rightGoal or 0)
end
local function Approach(value,goal,step)
    if value<goal then return math.min(value+step,goal) end
    return math.max(value-step,goal)
end
local function Weapon(unit,label)
    for _,w in ipairs(unit.weapons or {}) do if Label(w)==label then return w end end
end
local function Air(target)
    return target and not target.dead and target:HasTags(Tags.AIR)
end
function M.WingTarget(unit,target,now)
    local c=Config(unit);if not c or not c.wings then return end
    local s=State(unit,now)
    s.wingGoals=Air(target) and c.wings.airAngles or c.wings.groundAngles
end
local function Wings(unit,c,s,now,delta)
    if now+1e-7>=s.nextMonitor then
        s.nextMonitor=now+c.monitorSeconds
        local target
        for _,label in ipairs(c.targetLabels) do
            local weapon=Weapon(unit,label)
            target=weapon and weapon.targetUnit
            if target and not target.dead then break end
        end
        M.WingTarget(unit,target,now)
    end
    if not s.wingGoals then return end
    s.wings=s.wings or {}
    for index,bone in ipairs(c.bones) do
        local id=unit:GetBoneId(bone)
        if id and Engine.IsValidGlobalID(id) then
            local part=s.wings[index]
            if not part then
                local _,basis=Engine.GetGlobalEntityLocalRotation(id)
                part={basis=basis,angle=0};s.wings[index]=part
            end
            local angle=Approach(part.angle,s.wingGoals[index],delta*c.speed)
            if angle~=part.angle then
                local axis={x=0,y=0,z=0};axis[c.axis]=1
                local offset=Engine.QuaternionAxisAngle(EngineClasses.float3(axis.x,axis.y,axis.z),angle*math.pi/180)
                Engine.SetGlobalEntityLocalRotation(id,Engine.QuaternionMultiply(part.basis,offset))
                part.angle=angle
            end
        end
    end
    if s.wings[1] and s.wings[2] then
        local left,right=s.wings[1].angle,s.wings[2].angle
        local previous=s.sentWings
        if not previous or previous[1]~=left or previous[2]~=right
            or previous[3]~=s.wingGoals[1] or previous[4]~=s.wingGoals[2] then
            Send(unit,3,true,now,left,right,s.wingGoals[1],s.wingGoals[2])
            s.sentWings={left,right,s.wingGoals[1],s.wingGoals[2]}
        end
    end
end
local function BarrelState(unit,c,now)
    local s=State(unit,now)
    if not s.barrel then s.barrel={speed=c.initialSpeed,goal=0,phase='packed',active=false} end
    return s.barrel
end
function M.Phase(unit,phase,now)
    local c=Config(unit);c=c and c.barrel
    if not c or c.dormantReason then return end
    local b=BarrelState(unit,c,now)
    if b.phase==phase then return end
    b.phase=phase;b.active=true
    b.goal=phase=='charge' and c.chargeSpeed or phase=='reload' and c.reloadSpeed or c.packedSpeed
    if not unit.dead and (phase=='reload' or phase=='packed') then Send(unit,2,true,now) end
end
local function SignedWheels(unit,c,s,delta,alive)
    s.wheels=s.wheels or {}
    local status,forward=Engine.GetGlobalEntityForwardDirection(unit.id)
    if status~=EngineErrorCode.Success then return end
    local result,origin=Engine.GetGlobalEntityWorldPosition(unit.id)
    if result~=EngineErrorCode.Success then return end
    local length=math.sqrt(forward.x*forward.x+forward.z*forward.z)
    if length<1e-6 then return end
    local fx,fz=forward.x/length,forward.z/length
    local motion=s.wheelMotion
    local distance,turn=0,0
    if alive and motion and delta>0 and delta<=1 then
        local dx,dz=origin.x-motion.x,origin.z-motion.z
        local sumX,sumZ=fx+motion.fx,fz+motion.fz
        local sumLength=math.sqrt(sumX*sumX+sumZ*sumZ)
        local yaw=math.atan2(fx*motion.fz-fz*motion.fx,fx*motion.fx+fz*motion.fz)
        if dx*dx+dz*dz<=16 and sumLength>1e-6 and math.abs(yaw)<=1 then
            distance=(dx*sumX+dz*sumZ)/sumLength
            turn=2*math.sin(yaw*.5)
        end
    end
    s.wheelMotion={x=origin.x,z=origin.z,fx=fx,fz=fz}
    for _,name in ipairs(WheelNames) do
        local bone=unit:GetBoneId(name)
        if bone and Engine.IsValidGlobalID(bone) then
            local result,position=Engine.GetGlobalEntityWorldPosition(bone)
            if result==EngineErrorCode.Success then
                local previous=s.wheels[name]
                -- Only root motion rolls the axle. Authored water-stow motion
                -- can move its pivot without the vehicle travelling.
                local centerX=(position.x-origin.x)*fz-(position.z-origin.z)*fx
                local speed=alive and previous and delta>0 and c.gain*(distance-turn*centerX)/delta or 0
                local axis={x=0,y=0,z=0};axis[c.axis]=speed
                if not previous then Engine.SetRotatorIsVelocityScalingEnabled(bone,false) end
                if not previous or previous.speed~=speed then
                    Engine.SetRotatorSpeed(bone,EngineClasses.float3(axis.x,axis.y,axis.z))
                end
                s.wheels[name]={speed=speed}
            end
        end
    end
end
local function InterceptorBarrels(unit,c,s,now,alive)
    s.interceptionBarrels=s.interceptionBarrels or {}
    local goals={}
    for index,definition in ipairs(c) do
        local part=s.interceptionBarrels[index] or {};s.interceptionBarrels[index]=part
        local state=unit.scoSourceInterception and unit.scoSourceInterception[definition.label]
        local id=state and state.target
        local target=id and __Entities.Projectiles[id.index]
        local active=alive and not (unit.toggles and unit:GetPause()) and target
            and target.id.version==id.version and not target.dead and not target.deleted
            and unit.army:IsEnemy(Armies[target.armyId])
        if active then part.lastTarget=now end
        goals[index]=alive and part.lastTarget and now-part.lastTarget<c[index].repackSeconds and 1 or 0
    end
    if not s.sentBarrels or s.sentBarrels[1]~=goals[1] or s.sentBarrels[2]~=goals[2] then
        Send(unit,4,true,now,goals[1],goals[2]);s.sentBarrels=goals
    end
end
function M.Tick(unit,now)
    local c=Config(unit);if not c then return end
    local s=State(unit,now);local delta=math.max(0,now-s.last);s.last=now
    local alive=not unit.dead and not unit.deleted and unit:IsCompleted()
    if c.wheels then SignedWheels(unit,c.wheels,s,delta,alive) end
    if c.wings and not unit.dead and not unit.deleted then Wings(unit,c.wings,s,now,delta) end
    if c.barrel and not c.barrel.dormantReason then
        local b=s.barrel
        if b then
            local id=unit:GetBoneId(c.barrel.bone)
            if id and Engine.IsValidGlobalID(id) then
                b.speed=alive and Approach(b.speed,b.goal,delta*c.barrel.acceleration) or 0
                local enabled=alive and b.active and b.speed~=0
                if b.applied~=b.speed then
                    Engine.SetRotatorSpeed(id,EngineClasses.float3(0,0,b.speed));b.applied=b.speed
                end
                if b.enabled~=enabled then Engine.SetRotatorEnabled(id,enabled);b.enabled=enabled end
            end
        end
    end
    if c.barrels then InterceptorBarrels(unit,c.barrels,s,now,alive) end
    if c.exhaust then
        local _,speed=Engine.GetMovementCurrentSpeed(unit.id)
        local moving=alive and speed~=nil and speed>0
        if not moving then
            if s.exhaustOn then Send(unit,1,false,now) end
            s.exhaustOn=false;s.exhaustDeadline=nil
        elseif not s.exhaustDeadline then
            s.exhaustOn=true;s.exhaustDeadline=now+c.exhaust.onSeconds;Send(unit,1,true,now)
        elseif now+1e-7>=s.exhaustDeadline then
            s.exhaustOn=not s.exhaustOn
            s.exhaustDeadline=now+(s.exhaustOn and c.exhaust.onSeconds or
                c.exhaust.offMin+math.random()*(c.exhaust.offMax-c.exhaust.offMin))
            Send(unit,1,s.exhaustOn,now)
        end
    end
end
function M.InstallUnit(class)
    if class.scoDynamicVisualsInstalled then return end
    class.scoDynamicVisualsInstalled=true
    local init,destroy=class.__init,class.OnDestroy
    function class:__init(...)
        init(self,...)
        if Config(self) then
            self:NewThread(function(unit)
                repeat
                    M.Tick(unit,Engine.GetSimulationTime())
                    if unit.dead or unit.deleted then return end
                    WaitSeconds(.1)
                until false
            end)
        end
    end
    function class:OnDestroy(...)
        local result=destroy(self,...)
        if Config(self) then M.Tick(self,Engine.GetSimulationTime()) end
        return result
    end
end
function M.InstallWeapon(class,WeaponState)
    if class.scoDynamicWeaponInstalled then return end
    class.scoDynamicWeaponInstalled=true
    local previousUpdate,previousProjectile,previousAdvance=class.Update,class.UpdateProjectile,class.AdvanceSalvoState
    local previousTargeting=class.UpdateTargeting
    function class:UpdateTargeting()
        local result=previousTargeting(self)
        local c=Config(self.unit);local barrel=c and c.barrel
        if not barrel or barrel.dormantReason or Label(self)~=barrel.label then return result end
        local now=Engine.GetSimulationTime()
        local b=BarrelState(self.unit,barrel,now)
        local target=self.enabled and not self.unit.dead and self.targetUnit
        if target and target.dead then target=nil end
        if b.target and b.target~=target then
            -- Retail OnLostTarget enters packing from charge, firing or reload.
            b.cycle=false;b.chargeUntil=nil;b.reloadUntil=nil;b.packAt=now+barrel.repackSeconds
            self.currentState=WeaponState.WaitingForTarget;self:SetMuzzlesFiring(false)
        end
        b.target=target
        if target then
            b.packAt=nil
            if b.reloadUntil and now+1e-7>=b.reloadUntil then b.reloadUntil=nil end
            if not b.cycle and not b.chargeUntil and not b.reloadUntil then
                -- Aim and source rack charging run concurrently after acquisition.
                M.Phase(self.unit,'charge',now);b.chargeUntil=now+barrel.chargeSeconds
            end
        elseif b.packAt and now+1e-7>=b.packAt then
            M.Phase(self.unit,'packed',now);b.packAt=nil
        end
        return result
    end
    function class:Update()
        local c=Config(self.unit);local barrel=c and c.barrel
        if barrel and not barrel.dormantReason and Label(self)==barrel.label then
            local now=Engine.GetSimulationTime()
            local s=State(self.unit,now);local b=s.barrel
            if not self.enabled or self.unit.dead then
                if b then b.cycle=false;b.chargeUntil=nil;b.reloadUntil=nil;b.packAt=nil;M.Phase(self.unit,'packed',now) end
            end
        end
        return previousUpdate(self)
    end
    function class:UpdateProjectile(onTarget)
        local c=Config(self.unit)
        local barrel=c and c.barrel
        local now=Engine.GetSimulationTime()
        if barrel and not barrel.dormantReason and Label(self)==barrel.label then
            local b=BarrelState(self.unit,barrel,now)
            if not self.enabled or self.unit.dead then return end
            if b.reloadUntil then
                if now+1e-7<b.reloadUntil then return end
                b.reloadUntil=nil
            end
            if self.currentState==WeaponState.ShootSalvo and not b.cycle then
                if not self.targetUnit or self.targetUnit.dead then
                    b.chargeUntil=nil;self.currentState=WeaponState.WaitingForTarget
                    return
                end
                if not b.chargeUntil then
                    M.Phase(self.unit,'charge',now);b.chargeUntil=now+barrel.chargeSeconds;b.packAt=nil
                end
                if now+1e-7<b.chargeUntil then return end
                if not onTarget then
                    if not self.targetUnit or self.targetUnit.dead then
                        b.chargeUntil=nil;self.currentState=WeaponState.WaitingForTarget
                    end
                    return
                end
                b.chargeUntil=nil;b.cycle=true
            end
        end
        if c and c.wings and c.wings.immediateFireLabel==Label(self)
            and self.currentState==WeaponState.ShootSalvo then M.WingTarget(self.unit,self.targetUnit,now) end
        return previousProjectile(self,onTarget)
    end
    function class:AdvanceSalvoState()
        local result=previousAdvance(self)
        local c=Config(self.unit);local barrel=c and c.barrel
        if barrel and not barrel.dormantReason and Label(self)==barrel.label then
            local now=Engine.GetSimulationTime();local b=BarrelState(self.unit,barrel,now)
            if b.cycle and self.currentState==WeaponState.WaitingForReload then
                b.cycle=false;b.reloadUntil=now+barrel.reloadSeconds
                M.Phase(self.unit,'reload',now)
            end
        end
        return result
    end
end
M.Label=Label
-- Native Import returns this module environment; plain Lua loaders keep the return API.
local moduleEnvironment = getfenv(1)
for name, value in pairs(M) do moduleEnvironment[name] = value end
return M
