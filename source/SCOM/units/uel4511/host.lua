-- Fatboy (uel4511): complete host implementation.
local EDA = Import("host/units/unitsClasses/unitsDefaultEDA.lua")
local EDALandUnit = EDA.HostEDALandUnit
local EDALandFactory = EDA.HostEDALandFactory
local EDAUefLandFactory = EDA.HostEDAUefLandFactory
-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0
-- Mobile Factory composition: retain Factory queue ownership, but delegate the
-- mobile lifecycle to EDALandUnit and never reserve a permanent structure grid.
local FatboyTargetingLayer = Import("common/layers.lua").TargetingLayer
local FatboyOrderTasks = Import("common/commonOrders.lua").OrderTasks
local FatboyHostOrderManager = Import("host/managers/orders/hostOrderManager.lua")
local FatboyCurve = Import("host/curves.lua").Curve
local FatboyBayAnimationSeconds = 2.87333336

local function FatboyIsAlive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
end

local function FatboyWorldPoint(factory, x, y, z)
    local rotated = Engine.QuaternionRotateVector(
        factory:GetOrientation(),
        EngineClasses.float3(x, y, z)
    )
    local origin = factory:GetPosition()
    return EngineClasses.float3(
        origin.x + rotated.x,
        origin.y + rotated.y,
        origin.z + rotated.z
    )
end

local function FatboyRearOrientation(factory)
    return Engine.QuaternionRotateY(factory:GetOrientation(), math.pi)
end

local function FatboyGroundPoint(factory, x, z)
    local position = FatboyWorldPoint(factory, x, 0, z)
    local _, terrainHeight = Engine.SampleTerrainHeight(
        EngineClasses.float3(position.x, 0, position.z)
    )
    return EngineClasses.float3(position.x, terrainHeight, position.z)
end

local function FatboyIsSubmerged(factory)
    local _, hasWater = Engine.HasWater()
    if not hasWater then
        return false
    end

    local _, waterLevel = Engine.GetWaterLevel()
    return factory:GetPosition().y < waterLevel - 0.25
end

local HostEDAFatboyMobileFactory = Class("EDAFatboyMobileFactory", EDALandFactory)
local EDAFatboyMobileFactory = HostEDAFatboyMobileFactory

local function FatboyShieldEnergyState(factory)
    local economy = factory.army and factory.army.economy
    local energy = economy and economy.resources and economy.resources.energy
    if not economy or not energy then
        return 0, false
    end

    -- Sanctuary reports an energy stall whenever storage is below one, even
    -- when generation exactly meets demand. Satisfaction is the authoritative
    -- per-tick supply fraction and therefore avoids that zero-storage deadlock.
    if not economy.isEnergyDown then
        return 1, true
    end

    local satisfaction = energy.satisfaction or 0
    satisfaction = math.max(0, math.min(satisfaction, 1))
    return satisfaction, satisfaction >= 1
end

local function FatboyCancelNativeShieldTimers(shield)
    if shield.rechargeThread then
        KillThread(shield.rechargeThread)
        shield.rechargeThread = nil
    end
    if shield.regenAfterDelayThread then
        KillThread(shield.regenAfterDelayThread)
        shield.regenAfterDelayThread = nil
    end
end

function EDAFatboyMobileFactory:CancelFatboyShieldRestart(resetProgress)
    self.fatboyShieldRestartGeneration =
        (self.fatboyShieldRestartGeneration or 0) + 1
    if self.fatboyShieldRestartThread then
        KillThread(self.fatboyShieldRestartThread)
        self.fatboyShieldRestartThread = nil
    end
    if resetProgress then
        self.fatboyShieldRestartProgress = 0
    end
end

function EDAFatboyMobileFactory:CancelFatboyShieldEnergyMonitor()
    self.fatboyShieldEnergyMonitorGeneration =
        (self.fatboyShieldEnergyMonitorGeneration or 0) + 1
    if self.fatboyShieldEnergyMonitorThread then
        KillThread(self.fatboyShieldEnergyMonitorThread)
        self.fatboyShieldEnergyMonitorThread = nil
    end
end

function EDAFatboyMobileFactory:BeginFatboyShieldOperationalDisable(shield)
    self:CancelFatboyShieldEnergyMonitor()
    if self.fatboyShieldOperationallyDisabled then
        return
    end

    self:CancelFatboyShieldRestart(true)
    -- This override never uses Shield.rechargeThread for operational restarts,
    -- so an existing native thread uniquely identifies damage-pop recharge.
    -- Do not inspect HP: Sanctuary clamps Entity health to at least one.
    self.fatboyShieldDamageRechargePending = shield.rechargeThread ~= nil

    FatboyCancelNativeShieldTimers(shield)

    shield.isEnableable = false
    shield:SetEnabled(false)
    shield:SetRegenEnabled(false)
    self.fatboyShieldOperationallyDisabled = true
end

function EDAFatboyMobileFactory:EnableFatboyShieldImmediately(shield, fullHealth)
    self:CancelFatboyShieldRestart(true)
    self:CancelFatboyShieldEnergyMonitor()
    FatboyCancelNativeShieldTimers(shield)
    self.fatboyShieldOperationallyDisabled = false
    self.fatboyShieldDamageRechargePending = false
    shield.isEnableable = true
    shield:SetEnabled(true)
    shield:SetRegenEnabled(true)
    if fullHealth then
        shield:SetHealth(shield:GetMaxHealth())
    end
    self.fatboyShieldRestartFullHealth = false
    self:StartFatboyShieldEnergyMonitor(shield)
end

function EDAFatboyMobileFactory:FatboyShieldRestartThread(generation, shield)
    local shieldTemplate = shield.tp or {}
    local rechargeTicks =
        (shieldTemplate.energyDrainRechargeTime or 5) * Constants.TickRate

    while FatboyIsAlive(self)
        and FatboyIsAlive(shield)
        and generation == self.fatboyShieldRestartGeneration
        and self:IsCompleted()
        and self:GetShieldToggle()
    do
        local _, energyStable = FatboyShieldEnergyState(self)

        if self.fatboyShieldDamageRechargePending then
            if energyStable then
                self.fatboyShieldRestartThread = nil
                self.fatboyShieldOperationallyDisabled = false
                self.fatboyShieldDamageRechargePending = false
                shield.isEnableable = true
                shield.rechargeThread = shield:NewThread(shield.RechargeThread)
                self:StartFatboyShieldEnergyMonitor(shield)
                return
            end
        elseif (self.fatboyShieldRestartProgress or 0) >= rechargeTicks then
            if energyStable then
                self.fatboyShieldRestartThread = nil
                self.fatboyShieldOperationallyDisabled = false
                shield.isEnableable = true
                shield:SetEnabled(true)
                shield:SetRegenEnabled(true)
                if self.fatboyShieldRestartFullHealth then
                    shield:SetHealth(shield:GetMaxHealth())
                end
                self.fatboyShieldRestartFullHealth = false
                self:StartFatboyShieldEnergyMonitor(shield)
                return
            end
        end

        WaitTicks(1)
        if not self.fatboyShieldDamageRechargePending then
            local tickSatisfaction = FatboyShieldEnergyState(self)
            self.fatboyShieldRestartProgress =
                (self.fatboyShieldRestartProgress or 0)
                + tickSatisfaction
        end
    end

    if generation == self.fatboyShieldRestartGeneration then
        self.fatboyShieldRestartThread = nil
    end
end

function EDAFatboyMobileFactory:FatboyShieldEnergyMonitorThread(generation, shield)
    while FatboyIsAlive(self)
        and FatboyIsAlive(shield)
        and generation == self.fatboyShieldEnergyMonitorGeneration
        and self:IsCompleted()
        and self:GetShieldToggle()
    do
        local economy = self.army and self.army.economy
        if not economy or not economy.isEnergyDown then
            break
        end

        local _, energyStable = FatboyShieldEnergyState(self)
        if not energyStable then
            self.fatboyShieldEnergyMonitorThread = nil
            self:BeginFatboyShieldOperationalDisable(shield)
            self:StartFatboyShieldRestart(shield)
            return
        end
        WaitTicks(1)
    end

    if generation == self.fatboyShieldEnergyMonitorGeneration then
        self.fatboyShieldEnergyMonitorThread = nil
    end
end

function EDAFatboyMobileFactory:StartFatboyShieldEnergyMonitor(shield)
    local economy = self.army and self.army.economy
    if self.fatboyShieldEnergyMonitorThread
        or not economy
        or not economy.isEnergyDown
    then
        return
    end

    self.fatboyShieldEnergyMonitorGeneration =
        (self.fatboyShieldEnergyMonitorGeneration or 0) + 1
    local generation = self.fatboyShieldEnergyMonitorGeneration
    self.fatboyShieldEnergyMonitorThread = self:NewThread(
        self.FatboyShieldEnergyMonitorThread,
        generation,
        shield
    )
end

function EDAFatboyMobileFactory:StartFatboyShieldRestart(shield)
    if self.fatboyShieldRestartThread
        or not self:IsCompleted()
        or not self:GetShieldToggle()
    then
        return
    end

    self.fatboyShieldRestartGeneration =
        (self.fatboyShieldRestartGeneration or 0) + 1
    local generation = self.fatboyShieldRestartGeneration
    self.fatboyShieldRestartThread = self:NewThread(
        self.FatboyShieldRestartThread,
        generation,
        shield
    )
end

function EDAFatboyMobileFactory:CheckShieldState(skipRecharge)
    local shield = self.shields and self.shields[1]
    if not shield then
        return
    end

    local wantsShield = self:IsCompleted() and self:GetShieldToggle()
    if self.resourceEntities.consumption then
        self.resourceEntities.consumption:SetEnabled(wantsShield)
    end

    local _, energyStable = FatboyShieldEnergyState(self)
    self:SetRotatorsEnabled(wantsShield and energyStable)

    if not wantsShield then
        self:BeginFatboyShieldOperationalDisable(shield)
        self:CancelFatboyShieldRestart(true)
        return
    end

    if skipRecharge then
        if energyStable then
            self:EnableFatboyShieldImmediately(shield, true)
            return
        end
        self.fatboyShieldRestartFullHealth = true
    end

    if shield:IsEnabled() then
        if energyStable then
            self:StartFatboyShieldEnergyMonitor(shield)
            return
        end
        self:BeginFatboyShieldOperationalDisable(shield)
    elseif shield.rechargeThread and not self.fatboyShieldOperationallyDisabled then
        if energyStable then
            self:StartFatboyShieldEnergyMonitor(shield)
            return
        end
        self:BeginFatboyShieldOperationalDisable(shield)
    elseif not self.fatboyShieldOperationallyDisabled then
        self:BeginFatboyShieldOperationalDisable(shield)
    end

    self:StartFatboyShieldRestart(shield)
end

function EDAFatboyMobileFactory:CanBeSlaveFactory()
    return false
end

function EDAFatboyMobileFactory:CanBeMasterFactory()
    return false
end

function EDAFatboyMobileFactory:PromoteToUnit()
    EDALandUnit.PromoteToUnit(self)
end

function EDAFatboyMobileFactory:UpdateAnimations()
    -- The mobile factory has event-driven build/close clips, not walk/run
    -- clips. Placement ghosts have no Movement component, so avoid the base
    -- animation loop's movement-speed query.
end

function EDAFatboyMobileFactory:OnBuildProcessStarted()
    -- External builders construct the Fatboy itself through Buildable, not
    -- through this factory's child-production callback. Start the deployment
    -- clip here so the bay opens while its own construction is in progress.
    EDALandFactory.OnBuildProcessStarted(self)
    self:SetAnimatorEnabled(true)
    self:PlayFatboyAnimation("build")
end

function EDAFatboyMobileFactory:OnBuildProcessEnded()
    EDALandFactory.OnBuildProcessEnded(self)
    -- A completed Fatboy may immediately start an already queued child build;
    -- leave its bay open in that case. Paused or canceled external construction
    -- returns safely to the closed pose.
    if not self.dead and not self:IsCompleted() then
        self:PlayFatboyAnimation("close")
    end
end

function EDAFatboyMobileFactory:RefreshFatboyWeaponTargets()
    -- A targeter can be created while an enemy is already inside its range.
    -- Mark only empty targeters and let TargeterManager perform its normal
    -- next-tick recalculation/dirty-clear after collision state has settled.
    for _, weapon in ipairs(self.weapons or {}) do
        if weapon.targeterCollider and not weapon:HasTarget() then
            weapon.targeterCollider.isDirty = true
        end
    end
end

function EDAFatboyMobileFactory:CancelFatboyTargetRefresh()
    self.fatboyTargetRefreshGeneration =
        (self.fatboyTargetRefreshGeneration or 0) + 1
    if self.fatboyTargetRefreshThread then
        KillThread(self.fatboyTargetRefreshThread)
        self.fatboyTargetRefreshThread = nil
    end
end

function EDAFatboyMobileFactory:FatboyTargetRefreshThread(generation)
    -- Collision registration and intel visibility settle on separate ticks.
    -- This bounded retry covers enemies already in range at completion or
    -- attack-order time; new entrants remain event-driven.
    for _, delayTicks in ipairs({ 1, 4, 12 }) do
        WaitTicks(delayTicks)
        if not FatboyIsAlive(self)
            or not self:IsCompleted()
            or generation ~= self.fatboyTargetRefreshGeneration
        then
            break
        end
        self:RefreshFatboyWeaponTargets()
    end

    if generation == self.fatboyTargetRefreshGeneration then
        self.fatboyTargetRefreshThread = nil
    end
end

function EDAFatboyMobileFactory:StartFatboyTargetRefresh()
    self:CancelFatboyTargetRefresh()
    if not FatboyIsAlive(self) or not self:IsCompleted() then
        return
    end

    self:RefreshFatboyWeaponTargets()
    local generation = self.fatboyTargetRefreshGeneration
    self.fatboyTargetRefreshThread = self:NewThread(
        self.FatboyTargetRefreshThread,
        generation
    )
end

function EDAFatboyMobileFactory:OnStopBeingBuilt()
    -- EDALandFactory supplies Unit completion plus the factory production
    -- monitor. Add only MobileUnit's movement/grid tail to avoid a double Unit
    -- completion callback.
    EDALandFactory.OnStopBeingBuilt(self)
    Engine.SetMovementEnabled(self.id, true)
    self:SetNavmapModifiersEnabled(false)
    Engine.SetGlobalGridModifierEnabled(self.id, false)
    self.fatboyMovementLocked = false
    self.fatboySubmerged = nil
    self.fatboyLayerThread = self:NewThread(self.FatboyLayerUpdateThread)
    self:StartFatboyTargetRefresh()
end

function EDAFatboyMobileFactory:AttackBehaviorStart(targetUnit, range)
    EDALandFactory.AttackBehaviorStart(self, targetUnit, range)
    if self.attackBehaviorIsActive then
        self:StartFatboyTargetRefresh()
    end
end

function EDAFatboyMobileFactory:AttackBehaviorStop()
    self:CancelFatboyTargetRefresh()
    EDALandFactory.AttackBehaviorStop(self)
end

function EDAFatboyMobileFactory:SetFatboyMovementLocked(locked)
    if self.fatboyMovementLocked == locked then
        return
    end

    self.fatboyMovementLocked = locked
    Engine.SetMovementEnabled(self.id, not locked)
end

function EDAFatboyMobileFactory:PlayFatboyAnimation(name)
    local animations = self.tp.visuals and self.tp.visuals.animations
    local animation = animations and animations[name]
    if animation and animation.id then
        Engine.PlayAnimation(self.id, animation.id, 0.1)
    end
end

function EDAFatboyMobileFactory:StopFatboyBuildColliderPin(targetUnit)
    if targetUnit ~= nil and self.fatboyPinnedBuildTarget ~= targetUnit then
        return
    end
    local pinnedTarget = self.fatboyPinnedBuildTarget
    if self.fatboyBuildPoseThread then
        KillThread(self.fatboyBuildPoseThread)
        self.fatboyBuildPoseThread = nil
    end
    if pinnedTarget and pinnedTarget.scoFactoryColliderPinOwner == self then
        local callbacks = self.fatboyBuildCallbacks
        if callbacks then
            pinnedTarget.OnStopBeingBuilt = callbacks.onStopBeingBuilt
            pinnedTarget.UpdateAnimations = callbacks.updateAnimations
        end
        pinnedTarget.scoFactoryColliderPinOwner = nil
    end
    self.fatboyPinnedBuildTarget = nil
    self.fatboyBuildCallbacks = nil
    self.fatboyRollOffTarget = nil
end

function EDAFatboyMobileFactory:HoldFatboyBuildPose(targetUnit)
    if not FatboyIsAlive(targetUnit) then return end
    Engine.SetMovementEnabled(targetUnit.id, false)
    Engine.SetVolumeColliderEnabled(targetUnit.id, false)
    targetUnit:SetOrientation(FatboyRearOrientation(self))
    if self.fatboyRollOffTarget ~= targetUnit then
        targetUnit:SetPosition(FatboyWorldPoint(self, 0, 0.669224, -2.083794))
    end
end

function EDAFatboyMobileFactory:FatboyBuildPoseThread(targetUnit)
    while FatboyIsAlive(self) and FatboyIsAlive(targetUnit)
        and self.fatboyPinnedBuildTarget == targetUnit
    do
        self:HoldFatboyBuildPose(targetUnit)
        WaitTicks(1)
    end
end

function EDAFatboyMobileFactory:PinFatboyBuildCollider(targetUnit)
    if not FatboyIsAlive(targetUnit) then return end
    if self.fatboyPinnedBuildTarget == targetUnit then
        self:HoldFatboyBuildPose(targetUnit)
        return
    end
    self:StopFatboyBuildColliderPin()
    self.fatboyPinnedBuildTarget = targetUnit
    self.fatboyBuildCallbacks = {
        onStopBeingBuilt = rawget(targetUnit, "OnStopBeingBuilt"),
        updateAnimations = rawget(targetUnit, "UpdateAnimations"),
    }
    local onStopBeingBuilt = targetUnit.OnStopBeingBuilt
    targetUnit.OnStopBeingBuilt = function(unit, ...)
        onStopBeingBuilt(unit, ...)
        -- Mobile completion enables movement after the factory's stop callback.
        if unit.scoFactoryColliderPinOwner == self then
            self:HoldFatboyBuildPose(unit)
        end
    end
    -- Native animation speed follows actual SimVelocity while Curve.Play drives
    -- the child; the ordinary updater reads the disabled mover's stale speed.
    targetUnit.UpdateAnimations = function() end
    targetUnit.scoFactoryColliderPinOwner = self
    self:HoldFatboyBuildPose(targetUnit)
    self.fatboyBuildPoseThread = self:NewThread(self.FatboyBuildPoseThread, targetUnit)
end

function EDAFatboyMobileFactory:GetFatboyRollOffGroundPoint(targetUnit)
    local hull = self.tp.collisionInfo
    local child = targetUnit.tp.collisionInfo
    local hullRear = (hull.centerOffset.z or 0) - hull.collisionSize.z * 0.5
    local childRear = child.collisionSize.z * 0.5 - (child.centerOffset.z or 0)
    -- FA's 17-unit attachment slide is 3.74 at the converted 0.22 scale.
    -- Large products must also clear the carrier's collision hull completely.
    local rear = math.min(-5.823794, hullRear - childRear - 0.25)
    local position = FatboyGroundPoint(self, 0, rear)
    position.y = position.y + (targetUnit.tp.movement.preferredAltitude or 0)
    return position
end

function EDAFatboyMobileFactory:ReleaseFatboyBuiltUnit(targetUnit, interrupted)
    if not FatboyIsAlive(targetUnit) or not targetUnit:IsCompleted() then
        return false
    end
    if self.fatboyPinnedBuildTarget ~= targetUnit then
        return true
    end
    if interrupted then
        -- A stopped production coroutine cannot finish its curve. Preserve the
        -- completed unit at a clear terrain point before releasing ownership.
        targetUnit:SetPosition(self:GetFatboyRollOffGroundPoint(targetUnit))
        targetUnit:SetOrientation(FatboyRearOrientation(self))
    end
    self:StopFatboyBuildColliderPin(targetUnit)
    Engine.SetVolumeColliderEnabled(targetUnit.id, true)
    Engine.SetMovementEnabled(targetUnit.id, true)
    targetUnit:UpdateAnimations()
    return true
end

function EDAFatboyMobileFactory:MoveFatboyBuiltUnit(targetUnit, destination, duration, startPosition)
    local origin = startPosition or targetUnit:GetPosition()
    local curve = FatboyCurve.Play(targetUnit, {
        duration = duration,
        position = {
            mode = FatboyCurve.Absolute,
            x = FatboyCurve.Linear(origin.x, destination.x),
            y = FatboyCurve.EaseInOut(origin.y, destination.y),
            z = FatboyCurve.Linear(origin.z, destination.z),
        },
    })
    while FatboyIsAlive(self) and FatboyIsAlive(targetUnit)
        and self.fatboyPinnedBuildTarget == targetUnit
    do
        local progress = duration > 0 and (_G.Time - curve.startTime) / duration or 1
        -- World-position reads lag transform writes until the next native tick.
        -- Clamp the next sample before applying it, without reading it back.
        local position = curve:Sample(math.clamp(progress, 0, 1))
        local _, terrainHeight = Engine.SampleTerrainHeight(position)
        local groundY = terrainHeight + (targetUnit.tp.movement.preferredAltitude or 0)
        if position.y < groundY then
            position.y = groundY
        end
        Engine.SetGlobalEntityPosition(targetUnit.id, position)
        if progress >= 1 then return true, position end
        WaitTicks(1)
    end
    return false
end

function EDAFatboyMobileFactory:FatboyLayerUpdateThread()
    while not self.dead do
        local submerged = FatboyIsSubmerged(self)
        if submerged ~= self.fatboySubmerged then
            self.fatboySubmerged = submerged
            self:SetTargetingLayer(submerged
                and FatboyTargetingLayer.Seabed
                or FatboyTargetingLayer.Land)

            -- The FA Fatboy cannot manufacture underwater. Preserve the queued
            -- item, but abort/delete the partial child as soon as it submerges.
            if submerged and self.productionBehaviorIsActive then
                self:ProductionBehaviorStop()
            end
        end
        WaitTicks(4)
    end
end

function EDAFatboyMobileFactory:ProductionBehaviorIsValidFor()
    if FatboyIsSubmerged(self) then
        return false
    end
    return EDALandFactory.ProductionBehaviorIsValidFor(self)
end

function EDAFatboyMobileFactory:GetConstructionSpawnPoint()
    -- Build-box compatibility maps this hook to the live construction API.
    -- The native attachment sits just above the rear tray surface.
    return FatboyWorldPoint(self, 0, 0.669224, -2.083794)
end

function EDAFatboyMobileFactory:OnStartBuildRoutine(targetUnit)
    local newTarget = self.fatboyPinnedBuildTarget ~= targetUnit
    self:SetFatboyMovementLocked(true)
    self:PinFatboyBuildCollider(targetUnit)
    EDALandFactory.OnStartBuildRoutine(self, targetUnit)
    self:HoldFatboyBuildPose(targetUnit)
    if newTarget then
        self:PlayFatboyAnimation("build")
        self.fatboyBayReadyTime = _G.Time + FatboyBayAnimationSeconds
    end
end

function EDAFatboyMobileFactory:OnStopBuildRoutine(targetUnit)
    if FatboyIsAlive(targetUnit) then
        self:HoldFatboyBuildPose(targetUnit)
    end
    EDALandFactory.OnStopBuildRoutine(self, targetUnit)
    -- A pause keeps the partial child on the open tray. Completed products
    -- leave through RollOffUnit before the bay closes.
end

function EDAFatboyMobileFactory:ProductionBehaviorBuildOne(item)
    -- Mirror the native pre-build wait before locking the mobile hull.
    while not self.dead and (self:GetPause() or not self.army:HasUnitCapSpace()) do
        WaitTicks(5)
    end
    if self.dead then return end
    self:SetFatboyMovementLocked(true)
    self.fatboyClosePending = false
    EDALandFactory.ProductionBehaviorBuildOne(self, item)
    if self.fatboyClosePending and not self.dead then
        -- The stock queue already waits two seconds after RollOffUnit.
        WaitSeconds(FatboyBayAnimationSeconds - 2)
    end
    self.fatboyClosePending = false
    self:SetFatboyMovementLocked(false)
end

function EDAFatboyMobileFactory:RollOffUnit(targetUnit)
    if not FatboyIsAlive(targetUnit) then
        self:StopFatboyBuildColliderPin(targetUnit)
        return
    end
    self:SetFatboyMovementLocked(true)
    if self.fatboyPinnedBuildTarget ~= targetUnit then
        self:PinFatboyBuildCollider(targetUnit)
        self:PlayFatboyAnimation("build")
        self.fatboyBayReadyTime = _G.Time + FatboyBayAnimationSeconds
    end
    while FatboyIsAlive(self) and FatboyIsAlive(targetUnit)
        and self.fatboyPinnedBuildTarget == targetUnit
        and _G.Time < (self.fatboyBayReadyTime or 0)
    do
        WaitTicks(1)
    end
    if not FatboyIsAlive(self) or not FatboyIsAlive(targetUnit)
        or self.fatboyPinnedBuildTarget ~= targetUnit
    then
        self:StopFatboyBuildColliderPin(targetUnit)
        return
    end
    self:HoldFatboyBuildPose(targetUnit)
    self.fatboyRollOffTarget = targetUnit
    local animations = targetUnit.tp.visuals.animations
    local gait = animations and (animations.run or animations.walk)
    if gait and gait.id then
        targetUnit:SetAnimatorEnabled(true)
        targetUnit.isWalking = animations.run == nil
        Engine.PlayAnimation(targetUnit.id, gait.id, 0.1)
    end
    local groundPoint = self:GetFatboyRollOffGroundPoint(targetUnit)
    local origin = targetUnit:GetPosition()
    local deckEnd = EngineClasses.float3(
        groundPoint.x, math.max(origin.y, groundPoint.y), groundPoint.z)
    local dx, dz = deckEnd.x - origin.x, deckEnd.z - origin.z
    local speed = math.max(0.1, math.min(2.2, targetUnit.tp.movement.speed or 2.2))
    local moved, position = self:MoveFatboyBuiltUnit(
        targetUnit, deckEnd, math.sqrt(dx * dx + dz * dz) / speed)
    if moved then
        moved = self:MoveFatboyBuiltUnit(targetUnit, groundPoint, 0.3, position)
    end
    if moved and self:ReleaseFatboyBuiltUnit(targetUnit) then
        local clearance = FatboyGroundPoint(self, 0, -15)
        FatboyHostOrderManager.HostIssueOrder(
            FatboyOrderTasks.MOVE, {targetUnit}, false, clearance, nil)
        local source = self.unitBeingBuiltSource or self
        if source.rallyPoint then
            FatboyHostOrderManager.HostIssueOrder(
                FatboyOrderTasks.MOVE, {targetUnit}, true, source.rallyPoint, nil)
        end
    else
        self:StopFatboyBuildColliderPin(targetUnit)
    end
    if FatboyIsAlive(self) then
        self:PlayFatboyAnimation("close")
        self.fatboyClosePending = true
    end
end

function EDAFatboyMobileFactory:ProductionBehaviorStop()
    local targetUnit = self.fatboyPinnedBuildTarget or self.productionBehaviorTargetUnit
    local closeAfterStop = FatboyIsAlive(targetUnit) and not targetUnit:IsCompleted()
    self:ReleaseFatboyBuiltUnit(targetUnit, true)
    self:StopFatboyBuildColliderPin(targetUnit)
    EDALandFactory.ProductionBehaviorStop(self)
    self:SetFatboyMovementLocked(false)
    if closeAfterStop then
        self:PlayFatboyAnimation("close")
    end
end

function EDAFatboyMobileFactory:OnCancelConstruction()
    self:ReleaseFatboyBuiltUnit(self.fatboyPinnedBuildTarget, true)
    self:StopFatboyBuildColliderPin()
    EDALandFactory.OnCancelConstruction(self)
    self:SetFatboyMovementLocked(false)
    self:PlayFatboyAnimation("close")
end

function EDAFatboyMobileFactory:OnDestroy(isDelete)
    self:CancelFatboyTargetRefresh()
    self:CancelFatboyShieldRestart(true)
    self:CancelFatboyShieldEnergyMonitor()
    if self.fatboyLayerThread then
        KillThread(self.fatboyLayerThread)
        self.fatboyLayerThread = nil
    end
    self:ReleaseFatboyBuiltUnit(self.fatboyPinnedBuildTarget, true)
    self:StopFatboyBuildColliderPin()
    self:SetFatboyMovementLocked(false)
    EDALandFactory.OnDestroy(self, isDelete)
end

local Base = HostEDAFatboyMobileFactory
UnitClass = Import("scom/units/behavior.lua").Derive("SCOMUel4511host", Base)
local Library = {Engine = Engine, EngineClasses = EngineClasses, EngineErrorCode = EngineErrorCode,
    TreeKnockdown = Import("common/loading/unitTemplateLoader.lua").SCOMTreeKnockdown}
local treeFootprint = {left = -2.71, right = 2.71, rear = -4.04, front = 3.68,
    bottom = 0, top = 1.5, rootHeight = 1.0725999832153321}

function UnitClass:UpdateAnimations(...)
    Base.UpdateAnimations(self, ...)
    Library.TreeKnockdown.Update(self, treeFootprint)
end

function UnitClass:OnStopBeingBuilt(...)
    Base.OnStopBeingBuilt(self, ...)
    -- Re-publish the existing destination through the owner-only rally channel.
    Base.SetRallyPoint(self, self.rallyPoint)
end

function UnitClass:SetFatboyMovementLocked(locked)
    local previous = self.fatboyMovementLocked
    Base.SetFatboyMovementLocked(self, locked)
    if previous ~= self.fatboyMovementLocked then
        Base.SetRallyPoint(self, self.rallyPoint)
    end
end
