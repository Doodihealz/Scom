-- FA pulse beams and Fire Beetle attack, scoped by generated source contracts.
-- Install into the two native classes after their definitions; other weapons
-- retain the previously composed methods, including the Monkeylord exception.
local M = {}

-- Sanctuary's exact NoArc intercept rejects some faster aircraft entirely.
-- Retain source shell speed and normal leading; direct aim is the fallback
-- only while this weapon's selected target has no future intercept solution.
local function FlakHasIntercept(x, y, z, vx, vy, vz, speed)
    local a = vx * vx + vy * vy + vz * vz - speed * speed
    local b = 2 * (x * vx + y * vy + z * vz)
    local c = x * x + y * y + z * z
    if vx == 0 and vy == 0 and vz == 0 then return true end
    -- ProjectileMovementHelper.GetTargetTimeOfImpactNoDeltaAcc/SolveQuadratic.
    if math.abs(a) < 1e-9 then
        return math.abs(b) >= 1e-9 and -c / b >= 0
    end
    local half = b / (2 * a)
    local discriminant = half * half - c / a
    if math.abs(discriminant) < 1e-9 then return -half >= 0 end
    if discriminant < 0 then return false end
    local root = math.sqrt(discriminant)
    return root - half >= 0 or -root - half >= 0
end

local function RestoreFlakLeading(self)
    local state = self.scoFlakAimSample
    if not state then return end
    for _, row in ipairs(state.controllers) do
        local result, current = Engine.GetAimControllerLeadTarget(row.id)
        local leading = row.policy and row.template.leadTarget == true
        if result == EngineErrorCode.Success and current ~= leading then
            assert(Engine.SetAimControllerLeadTarget(row.id, leading) == EngineErrorCode.Success,
                'SCOM flak lead restore failed')
        end
    end
    self.scoFlakAimSample = nil
end

local function UpdateFlakLeading(self)
    local source = self.unit.tp.additions and self.unit.tp.additions.faSourceContract
    local sourceWeapon = self.tp.scoFaSourceWeapon
    local identity = self.tp.scoFaProjectileIdentity
    local mobile = self.unit.tpId == 'uel5006' and source and source.sourceId == 'UEL0205'
        and self.tp.name == 'AAGun' and sourceWeapon and sourceWeapon.Label == 'AAGun'
    local structure = self.unit.tpId == 'ues2201' and source
        and source.sourceBlueprint == 'units/UEB2204/UEB2204_unit.bp'
        and source.sourceBlueprintSha256 == '8e459e3d4f2528c88597b13df611cb6999ddd113e97d83237cd1049ab0788099'
        and identity and identity.sourceIndex == 1 and identity.sourceLabel == 'AAGun'
        and identity.sourceBlueprintSha256 == '40248b18e2d77e9ee0659444c440511b4232b515eff6372774d1c42b539dc588'
    if self.tp.projectileTemplate ~= 'psf0023' or not (mobile or structure)
    then RestoreFlakLeading(self); return end
    if not self.enabled or not self.targetUnit or self.targetUnit.dead
        or self.targetUnit.deleted or self.unit.dead or self.unit.deleted
    then RestoreFlakLeading(self); return end

    local first = self.aimControllerIds[1]
    if not first then RestoreFlakLeading(self); return end
    local result, target = Engine.GetAimControllerTarget(first)
    if result ~= EngineErrorCode.Success or target.index == 0 then
        RestoreFlakLeading(self); return
    end
    local positionResult, position = Engine.GetGlobalEntityWorldPosition(target)
    if positionResult ~= EngineErrorCode.Success then RestoreFlakLeading(self); return end
    local now = Tick * Constants.TickTimeStep
    local state = self.scoFlakAimSample
    if state and (state.index ~= target.index or state.version ~= target.version) then
        RestoreFlakLeading(self); state = nil
    end
    if not state then
        local controllers = {}
        for index, id in ipairs(self.aimControllerIds) do
            local template = self.tp.aimControllers[index]
            if not template or template.solverType ~= 'NoArc'
                or template.reduceMuzzleVelocityToTarget == true
            then return end
            local leadResult, policy = Engine.GetAimControllerLeadTarget(id)
            if leadResult ~= EngineErrorCode.Success then return end
            controllers[index] = {id = id, template = template,
                policy = policy and template.leadTarget == true}
        end
        state = {index = target.index, version = target.version, controllers = controllers}
        self.scoFlakAimSample = state
    end
    local previous, elapsed = state.position, state.time and now - state.time
    state.position = {x = position.x, y = position.y, z = position.z}
    state.time = now
    if not previous then return end
    if math.abs(elapsed - Constants.TickTimeStep) > 1e-6 then
        RestoreFlakLeading(self); return
    end
    local vx, vy, vz = (position.x - previous.x) / elapsed,
        (position.y - previous.y) / elapsed, (position.z - previous.z) / elapsed
    local direct = false
    for _, row in ipairs(state.controllers) do
        if row.policy and row.template.leadTarget == true then
            local originResult, origin = Engine.GetGlobalEntityWorldPosition(row.id)
            local speedResult, speed = Engine.GetAimControllerProjectileSpeed(row.id)
            if originResult ~= EngineErrorCode.Success or speedResult ~= EngineErrorCode.Success
                or speed <= 0 then RestoreFlakLeading(self); return end
            if not FlakHasIntercept(position.x - origin.x, position.y - origin.y,
                position.z - origin.z, vx, vy, vz, speed) then direct = true end
        end
    end
    for _, row in ipairs(state.controllers) do
        local leading = row.policy and row.template.leadTarget == true and not direct
        local leadResult, current = Engine.GetAimControllerLeadTarget(row.id)
        if leadResult ~= EngineErrorCode.Success then RestoreFlakLeading(self); return end
        if current ~= leading then
            -- The native setter also replicates this field to the client.
            assert(Engine.SetAimControllerLeadTarget(row.id, leading) == EngineErrorCode.Success,
                'SCOM flak lead update failed')
        end
    end
end

local function TickCount(seconds)
    return math.max(1, math.ceil(seconds / Constants.TickTimeStep - 1e-7))
end

local function StingerSource(self)
    local source=self.tp and self.tp.scoFaSourceWeapon
    if self.unit.tpId=='uea5005' and source and source.Label=='Turret01'
        and self.tp.projectileTemplate=='psf0034' then return source end
end

local MechMarineSource = {
    RateOfFire=3, MuzzleSalvoSize=1,
    sourceIndex=1, sourceLabel='ArmCannonTurret',
    sourceProjectile='/projectiles/TDFMachineGun01/TDFMachineGun01_proj.bp',
    sourceBlueprintSha256='8b7851d08f385f9ecd28d546d7cb601ced695eb66eeabfb08b01ac4427a7277d',
}

local function CadenceSource(self)
    local source=StingerSource(self)
    if source then return source,'Stinger' end
    local identity=self.tp and self.tp.scoFaProjectileIdentity
    if self.unit.tpId=='uel1002' and self.tp.projectileTemplate=='peu106m'
        and identity and identity.sourceIndex==MechMarineSource.sourceIndex
        and identity.sourceLabel==MechMarineSource.sourceLabel
        and identity.sourceProjectile==MechMarineSource.sourceProjectile
        and identity.sourceBlueprintSha256==MechMarineSource.sourceBlueprintSha256
    then return MechMarineSource,'Mech Marine' end
end

local function SourceCadence(self,previousUpdate,WeaponState,sourceName)
    local step=Constants.TickTimeStep
    -- Native subtraction can leave a positive rounding residue at zero.
    if self.currentState==WeaponState.WaitingForReload and self.reloadTimer<=step+1e-7 then
        self.reloadTimer=math.min(self.reloadTimer,step)
    end
    local result=previousUpdate(self)
    local justFired=self.currentState==WeaponState.WaitingForReload
        and math.abs(self.reloadTimer-self.tp.reloadTime)<1e-7
    local ready=self.enabled and not self.unit.dead and self.targetUnit and not self.targetUnit.dead
        and (self:IsWeaponOnTarget() or (sourceName=='Mech Marine' and justFired))
    if not ready or self.scoSourceCadenceTarget~=self.targetUnit then self.scoSourceCadenceFraction=0 end
    self.scoSourceCadenceTarget=ready and self.targetUnit or nil
    if ready and justFired then
        -- Native Update just began a source salvo. Carry the fractional tick
        -- only across uninterrupted eligible firing: 3,3,4 ticks at 3 Hz.
        -- Never change shared template values or repay missed idle shots.
        local ticks=self.tp.reloadTime/step+(self.scoSourceCadenceFraction or 0)
        local whole=math.max(1,math.floor(ticks+1e-7))
        self.scoSourceCadenceFraction=ticks-whole
        self.reloadTimer=whole*step
    end
    return result
end

-- The Marine alternates two separately aimed muzzles. Sanctuary's stock
-- IsWeaponOnTarget requires both controllers aligned before either fires,
-- allowing an inactive arm to stall the entire weapon at close range.
local function MarineGroupAligned(self, group)
    -- Native on-target is cached until the next simulation update after a
    -- target change. Reject that one stale tick for both Marine arms.
    if self.scoMarineAimChangedAt
        and GetGameTimeSeconds() < self.scoMarineAimChangedAt
            + Constants.TickTimeStep - 1e-7 then return false end
    if not group or #group == 0 then return false end
    for _, muzzle in ipairs(group) do
        if not muzzle.aimControllerId then return false end
        local status, aligned = Engine.GetAimControllerIsOnTarget(muzzle.aimControllerId)
        if status ~= EngineErrorCode.Success or aligned ~= true then return false end
    end
    return true
end

local function MarineSelectReadyGroup(self)
    if not self.enabled or not self.targetUnit or self.targetUnit.dead then return end
    if MarineGroupAligned(self, self.muzzleGroups[self.currentMuzzleGroupIndex]) then return end
    for index, group in ipairs(self.muzzleGroups) do
        if MarineGroupAligned(self, group) then
            self.currentMuzzleGroupIndex = index
            return
        end
    end
end

-- These source launchers have fixed racks. Their missiles turn after launch;
-- native angular alignment must not make their authored zero-speed joints stall.
local MobileMissiles = {
    ucl2101 = {projectile='psf0073', sourceId='aifmissileserpentine01', label='MissileRack',
        path='/projectiles/AIFMissileSerpentine01/AIFMissileSerpentine01_proj.bp',
        hash='1376c174654070b29fdc47935b7f7b921acf5a2045e05ec78aaee49d0976e86f'},
    ugl5002 = {projectile='psf0021', sourceId='cifmissiletactical01', label='MissileRack',
        path='/projectiles/CIFMissileTactical01/CIFMissileTactical01_proj.bp',
        hash='87e1a314b45cb224421b60d0aef68670ecfdaaa12311b1e269112f0956c25963'},
    usl2101 = {projectile='psf0138', sourceId='siflaansetacticalmissile01', label='MissileRack',
        path='/projectiles/SIFLaanseTacticalMissile01/SIFLaanseTacticalMissile01_proj.bp',
        hash='33b12c7115c72cbca467e9084ff507094991641359cf7d28948d42c8cca09ece'},
    uel2201 = {projectile='psf0174', sourceId='tifmissilecruise03',
        path='/projectiles/TIFMissileCruise03/TIFMissileCruise03_proj.bp',
        hash='1d66eea3f9a50a802fc2ae554f067738495da05e69d1828ab2e98fe0a421be7c'},
    uel5011 = {projectile='psf0039', sourceId='tifmissilecruise05',
        path='/projectiles/TIFMissileCruise05/TIFMissileCruise05_proj.bp',
        hash='02d8fc7f3a65e0351eca8c587d024552a6a32cc913cd119cbb9aebd5625c8d0f'},
}

local function MobileMissileSource(self)
    local rule = self.unit and MobileMissiles[self.unit.tpId]
    if not rule or not self.tp or self.tp.projectileTemplate ~= rule.projectile then return end
    local additions = self.projectileTemplate and self.projectileTemplate.additions
    local source = additions and additions.scoSourceProjectile
    if not source or source.sourceId ~= rule.sourceId or source.blueprintSha256 ~= rule.hash then return end
    local identity = self.tp.scoFaProjectileIdentity
    if self.unit.tpId ~= 'uel5011' and self.unit.tpId ~= 'ugl5002' then
        if not identity or identity.sourceIndex ~= 1 or identity.sourceLabel ~= (rule.label or 'MissileWeapon')
            or identity.sourceProjectile ~= rule.path or identity.sourceBlueprintSha256 ~= rule.hash then return end
    else
        local weapon = self.tp.scoFaSourceWeapon
        if self.tp.scoFaSourceWeaponIndex ~= 1 or not weapon or weapon.Label ~= (rule.label or 'MissileWeapon')
            or weapon.ProjectileId ~= rule.path or weapon.Turreted ~= false
            or weapon.MuzzleVelocity ~= 3 then return end
    end
    return rule
end

local function MobileMissileTarget(self, aimControllerId)
    if not self.enabled or self.unit.dead or self.unit.deleted or not self.targetUnit
        or not self:CanShootAt(self.targetUnit) or not self:IsTargetInRange(self.targetUnit) then return end
    local owned = false
    for _, id in ipairs(self.aimControllerIds) do
        if id.index == aimControllerId.index and id.version == aimControllerId.version then owned = true; break end
    end
    if not owned then return end
    local status, targetId = Engine.GetAimControllerTarget(aimControllerId)
    if status ~= EngineErrorCode.Success or not targetId or not Engine.IsValidGlobalID(targetId) then return end
    local rootStatus, rootId = Engine.GetGlobalEntityRoot(targetId)
    local expected = self.targetUnit.id
    if rootStatus ~= EngineErrorCode.Success or not rootId
        or rootId.index ~= expected.index or rootId.version ~= expected.version then return end
    return targetId
end

function M.InstallWeapon(HostWeapon,WeaponState)
    if HostWeapon.scoFaSourceWeaponsInstalled then return end
    HostWeapon.scoFaSourceWeaponsInstalled = true
    local previousFireLayer = HostWeapon.CanFireFromCurrentLayer
    function HostWeapon:CanFireFromCurrentLayer()
        local stun = _G.SCO_SourceStun
        if stun and stun.IsStunned(self.unit) then return false end
        return previousFireLayer(self)
    end
    local previousUpdate = HostWeapon.Update
    local previousUpdateBeam = HostWeapon.UpdateBeam
    local previousCanShootAt = HostWeapon.CanShootAt
    local previousIsWeaponOnTarget = HostWeapon.IsWeaponOnTarget
    local previousGetDesiredProjectileValues = HostWeapon.GetDesiredProjectileValues
    local previousSetAimTarget = HostWeapon.SetAimTarget
    local ProjectileCommands = Import("common/commands/definitions/projectiles.lua")
    local CollisionUpdate = Import("host/collisionUpdate.lua")
    local Layers = Import('common/layers.lua').TargetingLayer
    local bit = require('bit')

    function HostWeapon:SetAimTarget(target)
        RestoreFlakLeading(self)
        local result = previousSetAimTarget(self, target)
        local _, sourceName = CadenceSource(self)
        if sourceName == 'Mech Marine' then
            self.scoMarineAimChangedAt = GetGameTimeSeconds()
        end
        return result
    end

    function HostWeapon:CanShootAt(target)
        if not previousCanShootAt(self,target) then return false end
        local source=StingerSource(self)
        if not source then return true end
        local sourceTagged=false
        for _,tag in ipairs(target.tp.tags or {}) do
            if tag=='SCFA_HIGHALTAIR' or tag=='SCFA_UNTARGETABLE' then return false end
            if tag=='SCFA_ALLUNITS' then sourceTagged=true end
        end
        local layer=target.targetingLayer
        -- Native hull sensors assign pure Water/Seabed only when fully below
        -- the surface. Keep exposed and transitioning hulls targetable.
        local exposed=Layers.Land+Layers.WaterSurface+Layers.Air+Layers.LandedAir
        if source.AboveWaterTargetsOnly and bit.band(layer,exposed)==0
            and bit.band(layer,Layers.Water+Layers.Seabed)~=0 then return false end
        -- Imported categories remain authoritative. Stock aircraft have no
        -- HIGHALTAIR category: map airborne native Plane, retaining Gunship.
        if not sourceTagged and bit.band(layer,Layers.Air)~=0
            and target.tp.movement and target.tp.movement.type=='Plane' then return false end
        return true
    end

    function HostWeapon:IsWeaponOnTarget()
        if MobileMissileSource(self) then
            if #self.aimControllerIds == 0 then return false end
            for _, id in ipairs(self.aimControllerIds) do
                if not MobileMissileTarget(self, id) then return false end
            end
            return true
        end
        local _, sourceName = CadenceSource(self)
        if sourceName ~= 'Mech Marine' then
            return previousIsWeaponOnTarget(self)
        end
        return self.enabled and self.targetUnit ~= nil
            and MarineGroupAligned(self, self.muzzleGroups[self.currentMuzzleGroupIndex])
    end

    function HostWeapon:GetDesiredProjectileValues(aimControllerId)
        if not MobileMissileSource(self) then
            return previousGetDesiredProjectileValues(self, aimControllerId)
        end
        if not aimControllerId then return end
        local targetId = MobileMissileTarget(self, aimControllerId)
        if not targetId then return end
        -- Keep the physical launch pose, source launch speed and ground target.
        return 3, EngineClasses.float3(0, 0, 0), targetId
    end

    function HostWeapon:Update()
        UpdateFlakLeading(self)
        local source,sourceName=CadenceSource(self)
        if source then
            assert(source.RateOfFire==3 and source.MuzzleSalvoSize==1
                and math.abs(self.tp.reloadTime-1/source.RateOfFire)<1e-7,
                sourceName..' cadence source drift')
            if sourceName=='Mech Marine' then
                assert(self.tp.damage==7 and #self.muzzleGroups==2
                    and #self.muzzleGroups[1]==1 and #self.muzzleGroups[2]==1,
                    'Mech Marine source weapon drift')
            end
            if sourceName=='Mech Marine' then MarineSelectReadyGroup(self) end
            return SourceCadence(self,previousUpdate,WeaponState,sourceName)
        end
        local beam = self.tp and self.tp.scoFaBeam
        if beam then
            self.scoFaReloadTicks = math.max(0, (self.scoFaReloadTicks or 0) - 1)
            if not self.enabled or self.unit.dead then
                self:SetMuzzlesFiring(false)
                self.currentState = WeaponState.WaitingForReload
                return
            end
            if self.currentState == WeaponState.WaitingForReload and self.scoFaReloadTicks == 0 then
                self.currentState = WeaponState.WaitingForTarget
            end
            self:UpdateTargeting()
            local onTarget = self:IsWeaponOnTarget()
            if self.currentState == WeaponState.WaitingForTarget and onTarget then
                -- FA is quantized to 10 Hz. Integer counters avoid an extra
                -- frame from repeated binary floating-point subtraction.
                self.scoFaReloadTicks = TickCount(self.tp.reloadTime)
                self.reloadTimer = self.tp.reloadTime
                self.salvosRemaining = self.tp.muzzleSalvoSize or 1
                self.currentState = WeaponState.ShootSalvo
            else
                self.reloadTimer = self.scoFaReloadTicks * Constants.TickTimeStep
            end
            return self:UpdateBeam(onTarget)
        end
        local suicide = self.tp and self.tp.scoFaSuicide
        if not suicide then return previousUpdate(self) end
        if self.scoFaSuicideFired or self.unit.dead or not self.enabled then return end
        self:UpdateTargeting()
        local target = self.targetUnit
        if not target or not self:CanShootAt(target) or not self:IsTargetInRange(target) then return end

        -- DamageArea can also kill the attacker because FA enables friendly
        -- damage. Mark first and only invoke Destroy if it survived that call.
        self.scoFaSuicideFired = true
        CollisionUpdate.ProcessAreaDamage(self.unit:GetPosition(), suicide.damageRadius,
            suicide.damage, self.unit.army, suicide.damageFriendly, self.unit)
        if not self.unit.dead then self.unit:Destroy(0, DestroyType.Kinetic) end
    end

    function HostWeapon:UpdateBeam(isOnTarget)
        local beam = self.tp and self.tp.scoFaBeam
        if not beam then return previousUpdateBeam(self, isOnTarget) end
        if self.currentState == WeaponState.ShootSalvo then
            self.currentState = WeaponState.WaitingPersistentBeamLifetime
            self.beamPendingEnable = false
            self.beamLifetimeCountdown = beam.lifetimeTicks
            local group = self.muzzleGroups[self.currentMuzzleGroupIndex]
            for _, muzzle in ipairs(group) do
                __Muzzles[muzzle.id.index]:SetFiring(true)
                ProjectileCommands.FireMuzzle.Send(muzzle.id)
            end
            return
        end
        if self.currentState == WeaponState.WaitingPersistentBeamLifetime then
            -- FA positive-lifetime beams complete their pulse even when aim
            -- momentarily drifts. Pausing here would multiply source damage.
            self.beamLifetimeCountdown = self.beamLifetimeCountdown - 1
            if self.beamLifetimeCountdown > 0 then return end
            self.currentState = WeaponState.FinishSalvo
        end
        if self.currentState == WeaponState.FinishSalvo then
            for _, muzzle in ipairs(self.muzzleGroups[self.currentMuzzleGroupIndex]) do
                __Muzzles[muzzle.id.index]:SetFiring(false)
            end
            self:AdvanceSalvoState()
        elseif self.currentState == WeaponState.WaitingBetweenSalvos then
            self.waitBetweenSalvosCountdown = self.waitBetweenSalvosCountdown - Constants.TickTimeStep
            if self.waitBetweenSalvosCountdown <= 1e-7 then self.currentState = WeaponState.ShootSalvo end
        end
    end
end

function M.InstallBeam(HostBeam)
    if HostBeam.scoFaSourceBeamInstalled then return end
    HostBeam.scoFaSourceBeamInstalled = true
    local previousInit = HostBeam.__init
    local previousEnable = HostBeam.SetBeamEnabled
    local previousFire = HostBeam.Raycast
    local CollisionUpdate = Import("host/collisionUpdate.lua")
    local Layers = Import("common/layers.lua")
    local Units, Shields = __Entities.Units, __Entities.Shields

    function HostBeam:__init(id, muzzle)
        previousInit(self, id, muzzle)
        local weaponTemplate = muzzle.weapon.tp
        self.scoFaBeam = weaponTemplate.scoFaBeam
        self.scoFaCollisionTick = 0
    end

    function HostBeam:SetBeamEnabled(enabled)
        if enabled and not self.enabled then self.scoFaCollisionTick = 0 end
        return previousEnable(self, enabled)
    end

    function HostBeam:Raycast()
        local source = self.scoFaBeam
        if not source then return previousFire(self) end
        self.scoFaCollisionTick = self.scoFaCollisionTick + 1
        local applyDamage = self.scoFaCollisionTick % source.collisionIntervalTicks == 0
        local _, origin = Engine.GetGlobalEntityWorldPosition(self.id)
        local _, forward = Engine.GetGlobalEntityForwardDirection(self.id)
        local events = Engine.RayCast(Layers.CollisionWorld.Collision, origin, forward,
            self.rangeMax, Layers.CollisionLayer.Shields + Layers.CollisionLayer.Units)
        local army = self.unit.army
        for _, event in ipairs(events) do
            local id = event.otherGlobalID
            local terrain = id.index == 0
            local valid = not terrain and Engine.IsValidGlobalID(id)
            local unit, shield = valid and Units[id.index], valid and Shields[id.index]
            local enemyUnit = unit and army:IsEnemy(unit.army)
            local enemyShield = shield and shield.enabled and army:IsEnemy(shield.army)
            if terrain or enemyUnit or enemyShield then
                if applyDamage then
                    if source.damageRadius > 0 then
                        local distance = event.hitDistance
                        local position = EngineClasses.float3(origin.x + forward.x * distance,
                            origin.y + forward.y * distance, origin.z + forward.z * distance)
                        CollisionUpdate.ProcessAreaDamage(position, source.damageRadius,
                            self.damage, army, source.damageFriendly, self.unit)
                    elseif enemyUnit then
                        unit:TakeDamage(self.damage, DestroyType.Kinetic, self.unit)
                    elseif enemyShield then
                        shield:TakeDamage(self.damage)
                    end
                end
                return event.hitDistance
            end
        end
        return self.rangeMax
    end
end

M.TickCount = TickCount
-- Native Import returns this module environment; plain Lua loaders keep the return API.
local moduleEnvironment = getfenv(1)
for name, value in pairs(M) do moduleEnvironment[name] = value end
return M

