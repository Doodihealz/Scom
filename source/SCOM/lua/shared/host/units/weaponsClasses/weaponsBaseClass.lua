local SCOMEditableUnits = Import("scom/editableUnits.lua")
local SessionCommands = Import("common/commands/definitions/session.lua")
local ProjectileCommands = Import("common/commands/definitions/projectiles.lua")
local Layers = Import("common/layers.lua")
local bit = require("bit")
local IsBeamWeapon = Import("common/utilities/beams.lua").IsBeamWeapon
local IsBeamPulseWeapon = Import("common/utilities/beams.lua").IsBeamPulseWeapon
local Projectile = Import("host/projectiles/projectilesClasses/projectilesBaseClass.lua").HostProjectile
local FlakProjectile = Import("host/projectiles/projectilesClasses/flakProjectile.lua").HostFlakProjectile
local RegisterHostMuzzle = Import("host/units/weaponsClasses/muzzleClass.lua").RegisterHostMuzzle
local TargeterCollider = Import("host/managers/targeting/targeterCollider.lua")
local TargeterManager = Import("host/managers/targeting/targeterManager.lua")
local Projectiles = __Entities.Projectiles
local TargetColliders = __TargetColliders

local OverkillBeamLookaheadSeconds = 2
local OverkillHitChance = 0.8
local ContinuousBeamOffTargetTicks = 8

---@class HostWeapon
---@field id globalId Gloabl ID of the weapon
---@field unit HostUnit Parent unit
---@field aimControllerIds GlobalID[] Aim controllers of the weapon
---@field tp WeaponTemplate Weapon template
---@field targetDestroyedCallback fun(targetUnit: HostUnit)
---@overload fun(id: globalId, unit: HostUnit, tp: Template): HostWeapon
HostWeapon = Class("Weapon")

---Initializes a new weapon class
---@param aimControllerIds GlobalID[] Aim controllers of the weapon
---@param muzzleGroups { id: GlobalID, aimControllerId: GlobalID }[][] Muzzle groups that fire together; each muzzle carries its bone id and the aim controller driving its projectile speed/gravity
---@param unit HostUnit Parent unit
---@param tp WeaponTemplate Weapon template
---@protected
function HostWeapon:__init(aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)
    self.aimControllerIds = aimControllerIds
    self.unit = unit
    self.tp = tp
    self.reloadTimer = tp.reloadTime or 0
    self.salvosRemaining = 0
    self.currentMuzzleGroupIndex = 1
    self.beamLifetimeCountdown = 0
    self.beamRenderCountdown = 0
    self.waitBetweenSalvosCountdown = 0
    self.currentState = WeaponState.WaitingForReload
    self.muzzleGroups = muzzleGroups
    self.isDeathExplosion = tp.category == "DeathExplosion"
    self.projectileTemplate = projectileTemplate
    self.isBeamWeapon = IsBeamWeapon(self.tp)
    self.isBeamPulseWeapon = IsBeamPulseWeapon(self.tp)
    self.beamPendingEnable = false
    self.beamOffTargetTicks = {}
    self.layerTargetLimitsMask = Layers.TargetingLayerMaskFromList(tp.layerTargetLimits or {})
    self.layerWeaponLimitsMask = Layers.TargetingLayerMaskFromList(tp.layerWeaponLimits or {})
    -- Air-only area-damage shells burst near their target instead of needing a direct hit.
    self.isFlakWeapon = (tp.damageRadius or 0) > 0 and self.layerTargetLimitsMask == Layers.TargetingLayer.Air

    ---@type HostUnit
    self.targetUnit = nil
    ---@type HostUnit
    self.preferredTarget = nil

    self.targetDestroyedCallback = function(targetUnit)
        if self.targetUnit == targetUnit then
            self:RequestRetarget()
        end
    end

    self.wantsEnabled = false
    self.enabled = false
    self.waterSensorSubmerged = false

    if self.tp.waterSensorEntityName then
        local sensorID = unit:GetBoneId(self.tp.waterSensorEntityName)
        if sensorID then
            self.waterSensorID = sensorID
            unit:RegisterWeaponWaterSensor(sensorID, self)
        end
    end

    -- Create targeter collider to get targets when they enter weapon range.
    if self.tp.weaponColliderEntityName then
        local isValid, weaponColliderID = Engine.GetGlobalBone(unit.id, self.tp.weaponColliderEntityName)
        
        if isValid then
            ---@type TargeterCollider
            self.targeterCollider = TargeterCollider.CreateTargeterCollider(weaponColliderID, self)
        end
    end

    local muzzles = {}
    for _, muzzleGroup in ipairs(muzzleGroups) do
        for _, muzzle in ipairs(muzzleGroup) do
            table.insert(muzzles, RegisterHostMuzzle(muzzle.id, muzzle.boneName, self))
        end
    end
    self.muzzles = muzzles

    -- TODO: The predicited damage can be done at template time.
    if self.isBeamWeapon then
        self.predictedDamage = (tp.damage or 0) / Constants.TickTimeStep * OverkillBeamLookaheadSeconds
    else
        self.predictedDamage = (tp.damage or 0) * #muzzles * (tp.muzzleSalvoSize or 1) * OverkillHitChance / math.max(#muzzleGroups, 1)
    end
end

function HostWeapon:Delete()
    if self.targetUnit then
        self.targetUnit:RemoveCallback(self.targetDestroyedCallback, "OnDestroyed")
        self.targetUnit = nil
    end

    if self.targeterCollider then
        self.targeterCollider:Delete() 
    end

    for _, muzzle in ipairs(self.muzzles) do
        muzzle:Delete()
    end
end

---@public Enable/Disable the weapon
---@param enabled boolean
function HostWeapon:SetEnabled(enabled)
    self.wantsEnabled = enabled
    self:RefreshEnabled()
end

---@public Get the layers this weapon fires from.
---@return integer A TargetingLayer mask.
function HostWeapon:GetFiringLayer()
    if not self.waterSensorID then
        return self.unit.targetingLayer
    end

    if self.waterSensorSubmerged then
        return Layers.TargetingLayer.Water + Layers.TargetingLayer.Seabed
    end

    return Layers.TargetingLayer.WaterSurface + Layers.TargetingLayer.Land
end

---@public Whether this weapon may fire from where it currently is (i.e. from in or out of water).
---@return boolean
function HostWeapon:CanFireFromCurrentLayer()
    if self.layerWeaponLimitsMask == 0 then
        return true
    end

    return bit.band(self:GetFiringLayer(), self.layerWeaponLimitsMask) ~= 0
end

---@public Applies `wantsEnabled` filtered through the water sensor gate. Also called by the unit
---when its own domain changes, since a dry weapon's firing layer is the unit's.
function HostWeapon:RefreshEnabled()
    local enabled = self.wantsEnabled and self:CanFireFromCurrentLayer()

    if self.enabled == enabled then return end

    if not enabled then
        self:SetMuzzlesFiring(false)
    end

    for _, aimControllerId in ipairs(self.aimControllerIds) do
        Engine.SetAimControllerEnabled(aimControllerId, enabled)
    end

    if self.targeterCollider then
        self.targeterCollider:SetEnabled(enabled)
    end

    self.enabled = enabled
end

---@public This weapon's own water sensor entered or left the water.
---@param isUnderWater boolean
function HostWeapon:OnCrossedWaterline(isUnderWater)
    if self.waterSensorSubmerged == isUnderWater then return end

    self.waterSensorSubmerged = isUnderWater
    self:RefreshEnabled()
end

---@public Check if the weapon is enabled
---@return boolean enabled
function HostWeapon:IsEnabled()
    return self.enabled
end

---@public comment
---@return boolean
function HostWeapon:HasTarget()
    return self.targetUnit ~= nil
end

---@public Whether the current target remains valid and in weapon range.
---@return boolean
function HostWeapon:HasValidTarget()
    return self.targetUnit ~= nil
        and self:CanShootAt(self.targetUnit)
        and self:IsTargetInRange(self.targetUnit)
end

---@public Returns a random target bone ID from the target unit. Returns nil if the target has no bones.
---@param targetUnit HostUnit The target unit to get a random bone ID from.
---@return GlobalID? The ID of a random target bone, or nil if the target has no bones.
function HostWeapon:GetRandomTargetBoneID(targetUnit)
    local targetBoneIds = targetUnit.targetBoneIds
    if #targetBoneIds == 0 then
        return nil
    end
    return targetBoneIds[math.random(#targetBoneIds)]
end

---@public Sets a new target for the weapon. Pass nil to clear the target.
---NOTE: This operation bypasses ALL weapon paremeters including range, layers, etc. This allows the weapon to aim and fire at anything. 
---@param targetUnit HostUnit? The new target. Pass nil to clear the target.
function HostWeapon:SetAimTarget(targetUnit)
    if self.targetUnit then
        self.targetUnit:RemoveCallback(self.targetDestroyedCallback, "OnDestroyed")
    end

    self.targetUnit = targetUnit

    if self.targetUnit then
        self.targetUnit:AddCallback(self.targetDestroyedCallback, "OnDestroyed")
    end

    -- Get a random target bone ID or fallback to the target collider ID.
    -- We want to be able to fallback because some units may not have targeting bones defined. 
    local selectedTargetBoneID = (targetUnit and self:GetRandomTargetBoneID(self.targetUnit)) or (targetUnit and self.targetUnit.targetCollider.id)

    local targetBoneID = (targetUnit and selectedTargetBoneID) or EngineClasses.GlobalID()
    for _, aimControllerId in ipairs(self.aimControllerIds) do
        Engine.SetAimControllerTarget(aimControllerId, targetBoneID)
    end
end

---@public Returns the weapons aim target. Returns nil if there is no target set.
---@return HostUnit? 
function HostWeapon:GetAimTarget()
    return self.targetUnit
end

---Sets a preferred target for this weapon. When preferred target is in range and valid, this target will be selected over any other candidate. Pass nil to clear the target.
---@param preferredTarget HostUnit? When preferred target is in range and valid, this target will be selected over any other candidate. Pass nil to clear the target.
function HostWeapon:SetPreferredTarget(preferredTarget)
    self.preferredTarget = preferredTarget

    -- If new, valid preferred target, if it is in range, target it now!
    if preferredTarget then

        -- Weapons do not currently handle other targets switching ability to shoot at besides leaving/entering range.
        if not self:CanShootAt(preferredTarget) then
            --Engine.Error("Weapon cannot fire at target unit. The preferrred target was dead or this case is not currently covered.")
            return
        end

        if self:IsTargetInRange(preferredTarget) then
            self:SetAimTarget(preferredTarget)
        end
    end
end

---@public Returns the weapons preferred target. Returns nil if there is no preferred target set.
---@return HostUnit?
function HostWeapon:GetPreferredTarget()
    return self.targetUnit
end

---@public If it is possible for this weapon to target the specified unit.
---@param targetUnit HostUnit
---@return boolean isValidTarget
function HostWeapon:CanShootAt(targetUnit)

    local isTargetableUnit = (targetUnit and targetUnit.isTargetable == true and not targetUnit.dead and self.unit.army:IsEnemy(targetUnit.army))

    if not isTargetableUnit then
        return false
    end

    -- If we the target unit is not visible through any intel we cannot target it!
    if not targetUnit:IsIntelVisible(self.unit.army) then
        return false
    end

    if not self:CanFireFromCurrentLayer() then
        return false
    end

    if self.layerTargetLimitsMask ~= 0 then
        if bit.band(targetUnit.targetingLayer, self.layerTargetLimitsMask) == 0 then
            return false
        end
    end

    return true
end

---@param targetUnit HostUnit
---@return number
function HostWeapon:PredictedDamageFor(targetUnit)
    if self.unit.tp.hasTags.ARTILLERY and targetUnit.tp.hasTags.MOBILE then
        return 0
    end

    return self.predictedDamage
end

---@param hits { colliderIndices: integer[], hitPositionsX: number[], hitPositionsY: number[], hitPositionsZ: number[] }
---@param first integer
---@param last integer
---@return HostUnit? bestTarget
function HostWeapon:SelectTarget(hits, first, last)
    if self.preferredTarget and self:CanShootAt(self.preferredTarget) and self:IsTargetInRange(self.preferredTarget) then
        return self.preferredTarget
    end

    local army = self.unit.army
    local muzzleID = self.muzzleGroups[1][1].id
    local _, muzzlePosition = Engine.GetGlobalEntityWorldPosition(muzzleID)
    local _, forward = Engine.GetGlobalEntityForwardDirection(muzzleID)
    local hitColliderIndices = hits.colliderIndices
    local hitPositionsX = hits.hitPositionsX
    local hitPositionsY = hits.hitPositionsY
    local hitPositionsZ = hits.hitPositionsZ

    local bestTarget, bestAlignment
    local doomedTarget, doomedAlignment

    for index = first, last do
        local targetCollider = TargetColliders[hitColliderIndices[index]]
        local targetUnit = targetCollider and targetCollider.unit

        if targetUnit and self:CanShootAt(targetUnit) then
            local toX = hitPositionsX[index] - muzzlePosition.x
            local toY = hitPositionsY[index] - muzzlePosition.y
            local toZ = hitPositionsZ[index] - muzzlePosition.z
            local alignment = (toX * forward.x + toY * forward.y + toZ * forward.z) / math.sqrt(toX * toX + toY * toY + toZ * toZ)

            if TargeterManager.IsOverkilled(targetUnit, army) then
                if not doomedTarget or alignment > doomedAlignment then
                    doomedTarget = targetUnit
                    doomedAlignment = alignment
                end
            elseif not bestTarget or alignment > bestAlignment then
                bestTarget = targetUnit
                bestAlignment = alignment
            end
        end
    end

    return bestTarget, doomedTarget
end

---@public Asks for a new target while preserving the current aim pose until the query completes.
function HostWeapon:RequestRetarget()
    if self.targeterCollider then
        TargeterManager.QueueRetarget(self.targeterCollider)
    end
end

function HostWeapon:UpdateTargeting()
    if self:HasTarget() then
        if not self:CanShootAt(self.targetUnit) or not self:IsTargetInRange(self.targetUnit) then
            self:SetAimTarget(nil)
            self:RequestRetarget()
            return
        end

        if self.preferredTarget and self.targetUnit ~= self.preferredTarget and self:CanShootAt(self.preferredTarget) and self:IsTargetInRange(self.preferredTarget) then
            self:SetAimTarget(self.preferredTarget)
        end

        if self.targetUnit ~= self.preferredTarget and self.targeterCollider and TargeterManager.IsOverkilled(self.targetUnit, self.unit.army, self:PredictedDamageFor(self.targetUnit)) then
            TargeterManager.QueueRetarget(self.targeterCollider)
        end

        return
    end

    if self.enabled and self.targeterCollider then
        self:RequestRetarget()
    end
end

---@public Returns if the weapon is properly aligned to shoot at its aim target.
---@return boolean isWeaponOnTarget
function HostWeapon:IsWeaponOnTarget()

    if self.targetUnit == nil then 
        return false
    end

    -- NOTE: This might be improper for units with no aim controllers.
    if #self.aimControllerIds == 0 then
        return false
    end

    for _, aimControllerId in ipairs(self.aimControllerIds) do
        
        local _, aimControllerIsOnTarget = Engine.GetAimControllerIsOnTarget(aimControllerId)

        if aimControllerIsOnTarget == false then
            return false
        end
    end

    return true
end

---@private Returns whether the aim controller assigned to a muzzle is on target.
---@param muzzle { id: GlobalID, aimControllerId: GlobalID }
---@return boolean
function HostWeapon:IsMuzzleOnTarget(muzzle)
    if not muzzle.aimControllerId then return false end

    local returnCode, isOnTarget = Engine.GetAimControllerIsOnTarget(muzzle.aimControllerId)
    return returnCode == EngineErrorCode.Success and isOnTarget
end

---@private Returns if the provided unit is within weapon range
---@param unit HostUnit The unit to check.
---@return boolean isInRange If the provided unit is in the weapon's range.
function HostWeapon:IsTargetInRange(unit)
    if not self.targeterCollider or not unit.targetCollider then
        return false
    end

    local _, isOverlapping = self.targeterCollider:CalculateCollision(unit.targetCollider.id)
    return isOverlapping
end

function HostWeapon:GetDesiredProjectileValues(aimControllerId)
    local returnCode, aimControllerIsOnTarget = Engine.GetAimControllerIsOnTarget(aimControllerId)
    if returnCode == EngineErrorCode.InvalidGlobalID then
        Warn("WeaponBaseClase: GetDesiredProjectileValues Invalid aimControllerID " .. aimControllerId.index .. " on unit ".. self.unit.name)
        return nil
    end

    if not aimControllerIsOnTarget then
        return nil
    end

    if not self.targetUnit then
        return nil
    end

    local _, desiredProjectileSpeed = Engine.GetAimControllerAdjustedProjectileSpeed(aimControllerId)
    local _, projectileGravity = Engine.GetAimControllerAimGravity(aimControllerId)
    local _, targetBoneID = Engine.GetAimControllerTarget(aimControllerId)

    return desiredProjectileSpeed, projectileGravity, targetBoneID
end

function HostWeapon:Update()
    self.reloadTimer = self.reloadTimer - Constants.TickTimeStep

    if self.currentState == WeaponState.WaitingForReload and self.reloadTimer <= 0 then
        self.currentState = WeaponState.WaitingForTarget
    end

    if not self.enabled and SCOMEditableUnits.IsEditable(self.unit.tp) then
        self:SetMuzzlesFiring(false)
        return
    end

    self:UpdateTargeting()

    local isOnTarget = self:IsWeaponOnTarget()

    if self.currentState == WeaponState.WaitingForTarget and isOnTarget then
        self.reloadTimer = self.tp.reloadTime
        self.salvosRemaining = self.tp.muzzleSalvoSize or 1
        self.currentState = WeaponState.ShootSalvo
    end

    if self.isBeamWeapon then
        self:UpdateBeam(isOnTarget)
    else
        self:UpdateProjectile(isOnTarget)

        if not isOnTarget then
            self:SetMuzzlesFiring(false)
        end
    end
end

--- Starts or stops the firing effects (beam visuals, looping fire sound) of every muzzle.
---@param enabled boolean
function HostWeapon:SetMuzzlesFiring(enabled)
    for _, muzzleGroup in ipairs(self.muzzleGroups) do
        for _, muzzle in ipairs(muzzleGroup) do
            __Muzzles[muzzle.id.index]:SetFiring(enabled)
            self.beamOffTargetTicks[muzzle.id.index] = 0
        end
    end
end

local function ApplyFiringRandomness(rotation, randomnessDegrees)
    local tiltRadians = math.rad(math.random() * randomnessDegrees)
    local rollRadians = math.random() * (2 * math.pi)
    local tilt = Engine.QuaternionAxisAngle(EngineClasses.float3(1, 0, 0), tiltRadians)
    local roll = Engine.QuaternionAxisAngle(EngineClasses.float3(0, 0, 1), rollRadians)
    local perturbation = Engine.QuaternionMultiply(roll, tilt)
    return Engine.QuaternionMultiply(rotation, perturbation)
end

function HostWeapon:UpdateProjectile(isOnTarget)
    if self.currentState == WeaponState.ShootSalvo then
        local muzzleGroup = self.muzzleGroups[self.currentMuzzleGroupIndex]
        local projectilePrefabID = self.projectileTemplate.general.prefabID

        if projectilePrefabID then
            for _, muzzle in ipairs(muzzleGroup) do
                local desiredProjectileSpeed, projectileGravity, targetBoneID = self:GetDesiredProjectileValues(muzzle.aimControllerId)

                if desiredProjectileSpeed then
                    local muzzleID = muzzle.id
                    local _, muzzlePosition = Engine.GetGlobalEntityWorldPosition(muzzleID)
                    local _, muzzleRotation = Engine.GetGlobalEntityWorldRotation(muzzleID)
                    local launchRotation = muzzleRotation
                    if self.tp.scoFaBombDrop ~= nil then
                        launchRotation = SCO_FaBomberCarrierFiringRotation(
                            self,
                            muzzleRotation)
                    end
                    local firingRotation = SCO_FieldFixFatboyGaussFiringRotation(
                        self,
                        targetBoneID,
                        muzzlePosition,
                        launchRotation,
                        desiredProjectileSpeed,
                        projectileGravity)
                    firingRotation = ApplyFiringRandomness(
                        firingRotation,
                        self.tp.firingRandomness or 1.0)
                    local _, projectileID = Engine.InstantiatePrefab(projectilePrefabID, muzzlePosition, EngineClasses.float3(1.0, 1.0, 1.0), firingRotation)
                    if self.tp.scoFaBombDrop ~= nil
                        and type(self.unit.SCO_FaBomberOnBombReleased) == "function"
                    then
                        self.unit:SCO_FaBomberOnBombReleased(projectileID)
                    end
                    if not (self.projectileTemplate.movement and self.projectileTemplate.movement.type) then
                        Engine.SetCurvedProjectileSpeed(projectileID, SCO_FieldFixArtilleryProjectileSpeed(self, desiredProjectileSpeed, muzzlePosition, targetBoneID))
                    else
                        local projectileType = self.projectileTemplate.movement.type
                        if projectileType == "TargetEntity" or projectileType == "LeadTargetEntity" then
                            Engine.SetHomingProjectileTargetID(projectileID, targetBoneID)
                            Engine.SetHomingProjectileTargetType(projectileID, HomingType.TargetGlobalID)
                        elseif projectileType == "StaticPosistion" or projectileType == "LeadStaticPosition" then
                            local _, targetPosition = Engine.GetGlobalEntityWorldPosition(targetBoneID)
                            Engine.SetHomingProjectileTargetPosition(projectileID, targetPosition)
                            Engine.SetHomingProjectileTargetType(projectileID, HomingType.TargetPosition)
                        end
                        local velocity = Engine.QuaternionRotateVector(firingRotation, EngineClasses.float3(0, 0, 1))
                        velocity = math3D.scale(velocity, desiredProjectileSpeed)
                        Engine.SetHomingProjectileVelocity(projectileID, velocity)
                    end

                    local gravityMultiplier = (self.projectileTemplate.movement and self.projectileTemplate.movement.gravityMultiplier) or 1
                    Engine.SetProjectileGravity(projectileID, math3D.scale(projectileGravity, gravityMultiplier))

                    ProjectileCommands.CreateProjectile.Send(projectileID, self.unit.army.id)
                    ProjectileCommands.FireMuzzle.Send(muzzleID)
                    __Muzzles[muzzleID.index]:SetFiring(true)

                    if self.isFlakWeapon then
                        Projectiles[projectileID.index] = FlakProjectile(projectileID, self.unit.army.id, self.projectileTemplate, self.tp.damage or 0, self.tp.damageRadius, self.tp.projectileLifetime, muzzleID, targetBoneID)
                    else
                        Projectiles[projectileID.index] = Projectile(projectileID, self.unit.army.id, self.projectileTemplate, self.tp.damage or 0, self.tp.damageRadius or 0, self.tp.projectileLifetime, muzzleID, self.unit)
                    Projectiles[projectileID.index].damageFriendly = self.tp.damageFriendly == true
                    end
                end
            end
        end

        self.currentState = WeaponState.FinishSalvo
    end

    if self.currentState == WeaponState.FinishSalvo then
        self:AdvanceSalvoState()
    end

    if self.currentState == WeaponState.WaitingBetweenSalvos then
        self.waitBetweenSalvosCountdown = self.waitBetweenSalvosCountdown - Constants.TickTimeStep
        if self.waitBetweenSalvosCountdown <= 0 then
            self.currentState = WeaponState.ShootSalvo
        end
    end
end

-- Updates the state and behavior of beam weapons each tick.
--- @param isOnTarget boolean indicating whether the weapon currently has a valid target.
function HostWeapon:UpdateBeam(isOnTarget)
    if self.currentState == WeaponState.ShootSalvo then
        self.currentState = WeaponState.WaitingPersistentBeamLifetime
        self.beamPendingEnable = true
        return
    end

    if self.currentState == WeaponState.WaitingPersistentBeamLifetime then
        if not self:HasTarget() then
            self.beamPendingEnable = false
            self.currentState = WeaponState.FinishSalvo
            return
        end
        
        -- If there is no target, turn off the beam for each muzzle after a certain number of ticks
        -- this is to give the beam some time to be on target before turning off
        if not self.isBeamPulseWeapon and not self.beamPendingEnable then
            local muzzleGroup = self.muzzleGroups[self.currentMuzzleGroupIndex]
            for _, muzzle in ipairs(muzzleGroup) do
                local muzzleIndex = muzzle.id.index
                if self:IsMuzzleOnTarget(muzzle) then
                    self.beamOffTargetTicks[muzzleIndex] = 0
                    __Muzzles[muzzleIndex]:SetFiring(true)
                else
                    local offTargetTicks = (self.beamOffTargetTicks[muzzleIndex] or 0) + 1
                    self.beamOffTargetTicks[muzzleIndex] = offTargetTicks
                    if offTargetTicks >= ContinuousBeamOffTargetTicks then
                        __Muzzles[muzzleIndex]:SetFiring(false)
                    end
                end
            end
        end

        if not isOnTarget then return end

        if self.beamPendingEnable then
            self.beamPendingEnable = false

            local muzzleGroup = self.muzzleGroups[self.currentMuzzleGroupIndex]
            local beamLifetime = self.tp.beamLifetime or -1
            self.beamLifetimeCountdown = beamLifetime

            for _, muzzle in ipairs(muzzleGroup) do
                local hostMuzzle = __Muzzles[muzzle.id.index]
                hostMuzzle:SetFiring(true)
                ProjectileCommands.FireMuzzle.Send(muzzle.id)
            end
            return
        end

        if self.beamLifetimeCountdown > 0 then
            self.beamLifetimeCountdown = self.beamLifetimeCountdown - 1
            if self.beamLifetimeCountdown == 0 then
                self.currentState = WeaponState.FinishSalvo
            end
        end
    end

    if self.currentState == WeaponState.FinishSalvo then
        if not self.isBeamPulseWeapon and self:HasTarget() then
            self.currentState = WeaponState.WaitingPersistentBeamLifetime
            return
        end

        self.beamPendingEnable = false

        local muzzleGroup = self.muzzleGroups[self.currentMuzzleGroupIndex]
        for _, muzzle in ipairs(muzzleGroup) do
            local hostMuzzle = __Muzzles[muzzle.id.index]
            hostMuzzle:SetFiring(false)
        end

        self:AdvanceSalvoState()
    end

    if self.currentState == WeaponState.WaitingBetweenSalvos then
        self.waitBetweenSalvosCountdown = self.waitBetweenSalvosCountdown - Constants.TickTimeStep
        if self.waitBetweenSalvosCountdown <= 0 then
            self.currentState = WeaponState.ShootSalvo
        end
    end
end

function HostWeapon:AdvanceSalvoState()
    self.currentMuzzleGroupIndex = self.currentMuzzleGroupIndex + 1
    if self.currentMuzzleGroupIndex > #self.muzzleGroups then
        self.currentMuzzleGroupIndex = 1
    end

    self.salvosRemaining = self.salvosRemaining - 1
    if self.salvosRemaining <= 0 then
        self.currentState = WeaponState.WaitingForReload
    else
        self.waitBetweenSalvosCountdown = self.tp.muzzleSalvoDelay or 0
        self.currentState = WeaponState.WaitingBetweenSalvos
    end
end

WeaponState =
{
    WaitingForReload              = 0,
    WaitingForTarget              = 1,
    ShootSalvo                    = 2,
    WaitingPersistentBeamLifetime = 3,
    FinishSalvo                   = 4,
    WaitingBetweenSalvos          = 5,
}


-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0
-- Delay only source-configured unpacking weapons until their exact native
-- deploy clip reaches its final frame.  Every other weapon calls through.
local SCO_EdaFaStockWeaponUpdate = HostWeapon.Update
function HostWeapon:Update()
    local unit = self.unit
    local deploy = unit and unit.tp and unit.tp.additions
        and unit.tp.additions.faWeaponDeploy
    if deploy and not unit.dead then
        if not self:HasTarget() then
            if self.UpdateTargeting then
            self:UpdateTargeting()
        else
            self:RecalculateTargets()
        end
        end
        if self:HasTarget() then
            unit:UpdateAnimations()
            local readyTime = unit.scoFaWeaponReadyTime
            if readyTime and GetGameTimeSeconds() < readyTime then
                return
            end
        end
    end
    return SCO_EdaFaStockWeaponUpdate(self)
end
-- Guard Cybran Monkeylord Cache Patcher 1.4.0
local SCO_MonkeylordStockCanShootAt = HostWeapon.CanShootAt

local function SCO_MonkeylordPassesWaterGate(weapon, target)
    local gate = weapon.tp and weapon.tp.scoMonkeylordWaterGate
    if gate == nil then return true end

    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success then return false end
    if not hasWater then return gate == "Above" end
    local levelResult, waterLevel = Engine.GetWaterLevel()
    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then
        return false
    end
    local ownerPosition = weapon.unit and weapon.unit:GetPosition()
    local targetPosition = target and target:GetPosition()
    if ownerPosition == nil or targetPosition == nil then return false end
    local margin = 0.05
    if gate == "Above" then
        return ownerPosition.y >= waterLevel - margin
            and targetPosition.y >= waterLevel - margin
    elseif gate == "Below" then
        return ownerPosition.y < waterLevel - margin
            and targetPosition.y < waterLevel - margin
    end
    return false
end

local function SCO_MonkeylordNormalizeHeading(value)
    return (value + 180) % 360 - 180
end

local function SCO_MonkeylordPassesHeadingArc(weapon, target)
    local arc = weapon.tp and weapon.tp.scoMonkeylordHeadingArc
    if arc == nil then return true end
    local ownerPosition = weapon.unit and weapon.unit:GetPosition()
    local targetPosition = target and target:GetPosition()
    if ownerPosition == nil or targetPosition == nil then return false end
    local deltaX = targetPosition.x - ownerPosition.x
    local deltaZ = targetPosition.z - ownerPosition.z
    if deltaX == 0 and deltaZ == 0 then return true end
    local yawResult, ownerYaw = Engine.GetMovementChassisYawDegrees(weapon.unit.id)
    if yawResult ~= EngineErrorCode.Success or ownerYaw == nil then
        return false
    end
    local targetHeading = math.deg(math.atan2(deltaX, deltaZ))
    local relativeHeading = SCO_MonkeylordNormalizeHeading(
        targetHeading - ownerYaw - arc.center)
    return math.abs(relativeHeading) <= arc.range
end

function HostWeapon:CanShootAt(target)
    return SCO_MonkeylordStockCanShootAt(self, target)
        and SCO_MonkeylordPassesWaterGate(self, target)
        and SCO_MonkeylordPassesHeadingArc(self, target)
end
-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0
-- targetWaterLimits is descriptive-only in this engine build. Enforce
-- the two imported Wagner/Titan gates physically after every earlier
-- CanShootAt implementation has accepted the target.
local SCO_FaRoleStockCanShootAt = HostWeapon.CanShootAt
function HostWeapon:CanShootAt(targetUnit)
    if not SCO_FaRoleStockCanShootAt(self, targetUnit) then
        return false
    end
    local gate = self.tp and self.tp.scoFaWaterGate
    if gate == nil then return true end

    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success then return false end
    if not hasWater then return gate == "Above" end
    local levelResult, waterLevel = Engine.GetWaterLevel()
    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return false end

    local ownerPosition = self.unit and self.unit:GetPosition()
    local targetPosition = targetUnit and targetUnit:GetPosition()
    if ownerPosition == nil or targetPosition == nil then return false end
    local margin = 0.05
    if gate == "Above" then
        return ownerPosition.y >= waterLevel - margin
            and targetPosition.y >= waterLevel - margin
    elseif gate == "Below" then
        return ownerPosition.y < waterLevel - margin
            and targetPosition.y < waterLevel - margin
    end
    return false
end
-- Supreme Commander Overhaul UEF Percival 1.0.0
-- FA AboveWaterFireOnly and AboveWaterTargetsOnly are physical constraints,
-- not merely target-layer labels. Chain the current host gate.
local SCO_PercivalStockCanShootAt = HostWeapon.CanShootAt
function HostWeapon:CanShootAt(targetUnit)
    if not SCO_PercivalStockCanShootAt(self, targetUnit) then return false end
    if not self.unit or self.unit.tpId ~= "uel3401" then return true end
    if not self.tp or self.tp.scoFaPercivalWaterGate ~= "OwnerAndTargetAbove" then
        return true
    end
    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success then return false end
    if not hasWater then return true end
    local levelResult, waterLevel = Engine.GetWaterLevel()
    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return false end
    local ownerPosition = self.unit:GetPosition()
    local targetPosition = targetUnit and targetUnit:GetPosition()
    if ownerPosition == nil or targetPosition == nil then return false end
    local margin = 0.05
    return ownerPosition.y >= waterLevel - margin
        and targetPosition.y >= waterLevel - margin
end
-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0
-- targetWaterLimits is descriptive in this engine build. Enforce only
-- URL0106's AboveWaterTargetsOnly target constraint after prior wrappers.
local SCO_FaHunterStockCanShootAt = HostWeapon.CanShootAt
function HostWeapon:CanShootAt(targetUnit)
    if not SCO_FaHunterStockCanShootAt(self, targetUnit) then
        return false
    end
    if not self.unit or self.unit.tpId ~= "ugl1001"
        or not self.tp or self.tp.scoFaHunterAboveWater ~= true
    then
        return true
    end

    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success then return false end
    if not hasWater then return true end
    local levelResult, waterLevel = Engine.GetWaterLevel()
    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return false end
    local targetPosition = targetUnit and targetUnit:GetPosition()
    return targetPosition ~= nil and targetPosition.y >= waterLevel - 0.05
end
-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0
-- Physically enforce donor water gates after every earlier wrapper.
local SCO_FaCybranT3StockCanShootAt = HostWeapon.CanShootAt
function HostWeapon:CanShootAt(targetUnit)
    if not SCO_FaCybranT3StockCanShootAt(self, targetUnit) then return false end
    local unitId = self.unit and self.unit.tpId
    if unitId ~= "ugl3001" and unitId ~= "ugl3002" then return true end
    local gate = self.tp and self.tp.scoFaCybranT3WaterGate
    if gate == nil then return true end

    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success then return false end
    if not hasWater then return gate ~= "OwnerAndTargetBelow" end
    local levelResult, waterLevel = Engine.GetWaterLevel()
    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return false end
    local targetPosition = targetUnit and targetUnit:GetPosition()
    if targetPosition == nil then return false end
    local targetAbove = targetPosition.y >= waterLevel - 0.05
    if gate == "TargetAbove" then return targetAbove end
    local ownerPosition = self.unit:GetPosition()
    if ownerPosition == nil then return false end
    local ownerAbove = ownerPosition.y >= waterLevel - 0.05
    if gate == "OwnerAndTargetAbove" then return ownerAbove and targetAbove end
    if gate == "OwnerAndTargetBelow" then return not ownerAbove and not targetAbove end
    return false
end
-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0
-- URL0304 deterministic host lifecycle:
-- packed -> opening -> ready -> closing -> packed.
local SCO_EggStockWeaponInit = HostWeapon.__init
local SCO_EggStockWeaponDelete = HostWeapon.Delete
local SCO_EggStockSetAimTarget = HostWeapon.SetAimTarget
local SCO_EggStockCanShootAt = HostWeapon.CanShootAt
local SCO_EggStockWeaponUpdate = HostWeapon.Update
local SCO_EggOrderTasks = Import("common/commonOrders.lua").OrderTasks

local function SCO_IsEggTrebuchetWeapon(self)
    return self.unit and self.unit.tpId == "ugl3101"
        and self.tp and self.tp.scoFaEggTrebuchet == true
end

local function SCO_PlayEggTrebuchetAnimation(self, key)
    local animation = self.unit.tp.visuals and self.unit.tp.visuals.animations
        and self.unit.tp.visuals.animations[key]
    if not animation or not animation.id then
        error("Trebuchet requires source animation " .. tostring(key))
    end
    Engine.PlayAnimation(self.unit.id, animation.id, 0.1)
end

local function SCO_SetEggTrebuchetMovementLocked(self, locked)
    if self.scoEggTrebuchetMovementLocked == locked then return end
    local unit = self.unit
    if unit.dead or unit.deleted then
        self.scoEggTrebuchetMovementLocked = locked
        self.scoEggTrebuchetPreviousMaxSpeed = nil
        return
    end
    local speed
    if locked then
        local status
        status, speed = Engine.GetMovementMaxSpeed(unit.id)
        if status ~= EngineErrorCode.Success or type(speed) ~= "number" then
            error("Trebuchet deploy could not read movement speed")
        end
        -- Keep movement active so native separation retains the collision entry.
        local stop = Engine.MovementStop(unit.id, EngineClasses.float2(0, 0))
        if stop ~= EngineErrorCode.Success then
            error("Trebuchet deploy could not stop movement")
        end
    else
        speed = self.scoEggTrebuchetPreviousMaxSpeed
        if type(speed) ~= "number" then
            error("Trebuchet deploy has no movement speed to restore")
        end
    end
    local result = Engine.SetMovementMaxSpeed(unit.id, locked and 0 or speed)
    if result ~= EngineErrorCode.Success then
        error("Trebuchet deploy could not update movement speed")
    end
    self.scoEggTrebuchetPreviousMaxSpeed = locked and speed or nil
    self.scoEggTrebuchetMovementLocked = locked
end

local function SCO_BeginEggTrebuchetOpen(self, now)
    SCO_SetEggTrebuchetMovementLocked(self, true)
    SCO_PlayEggTrebuchetAnimation(self, "deploy")
    self.scoEggTrebuchetState = "opening"
    self.scoEggTrebuchetDeadline = now + self.tp.scoFaEggTrebuchetDeploySeconds
end

local function SCO_BeginEggTrebuchetClose(self, now)
    SCO_PlayEggTrebuchetAnimation(self, "close")
    self.scoEggTrebuchetState = "closing"
    self.scoEggTrebuchetDeadline = now + self.tp.scoFaEggTrebuchetRepackSeconds
end

function HostWeapon:SCO_ReleaseEggTrebuchetForMove()
    if not SCO_IsEggTrebuchetWeapon(self) then return end
    if self:HasTarget() then self:SetAimTarget(nil) end
    if self.scoEggTrebuchetState ~= "packed" then
        SCO_PlayEggTrebuchetAnimation(self, "walk")
    end
    self.scoEggTrebuchetState = "packed"
    self.scoEggTrebuchetDeadline = nil
    SCO_SetEggTrebuchetMovementLocked(self, false)
end

function HostWeapon:__init(aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)
    SCO_EggStockWeaponInit(self, aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)
    if not SCO_IsEggTrebuchetWeapon(self) then return end
    if tp.scoFaEggTrebuchetDeploySeconds ~= 1.600000023841858
        or tp.scoFaEggTrebuchetRepackSeconds ~= 1.600000023841858
    then error("Trebuchet source deployment timing drifted") end
    self.scoEggTrebuchetState = "packed"
    self.scoEggTrebuchetMovementLocked = false
end

function HostWeapon:Delete()
    if SCO_IsEggTrebuchetWeapon(self) then
        self.scoEggTrebuchetDisposed = true
        SCO_SetEggTrebuchetMovementLocked(self, false)
    end
    return SCO_EggStockWeaponDelete(self)
end

function HostWeapon:CanShootAt(targetUnit)
    if not SCO_EggStockCanShootAt(self, targetUnit) then return false end
    if not SCO_IsEggTrebuchetWeapon(self)
        or self.tp.scoFaEggAboveWaterTargetsOnly ~= true
    then return true end
    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success then return false end
    if not hasWater then return true end
    local levelResult, waterLevel = Engine.GetWaterLevel()
    local targetPosition = targetUnit and targetUnit:GetPosition()
    return levelResult == EngineErrorCode.Success and waterLevel ~= nil
        and targetPosition ~= nil and targetPosition.y >= waterLevel - 0.05
end

function HostWeapon:SetAimTarget(targetUnit)
    local result = SCO_EggStockSetAimTarget(self, targetUnit)
    if not SCO_IsEggTrebuchetWeapon(self) then return result end
    self.scoEggTrebuchetHasTarget = targetUnit ~= nil
    return result
end

function HostWeapon:SCO_UpdateEggTrebuchetLifecycle(now)
    local state = self.scoEggTrebuchetState
    local hasTarget = self:HasTarget()
    self.scoEggTrebuchetHasTarget = hasTarget

    if state == "packed" and hasTarget then
        SCO_BeginEggTrebuchetOpen(self, now)
        return
    end
    if state == "opening" and now >= self.scoEggTrebuchetDeadline then
        self.scoEggTrebuchetDeadline = nil
        self.scoEggTrebuchetState = "ready"
        state = "ready"
    end
    if state == "ready" and not hasTarget then
        SCO_BeginEggTrebuchetClose(self, now)
        return
    end
    if state == "closing" and now >= self.scoEggTrebuchetDeadline then
        self.scoEggTrebuchetDeadline = nil
        self.scoEggTrebuchetState = "packed"
        SCO_PlayEggTrebuchetAnimation(self, "walk")
        SCO_SetEggTrebuchetMovementLocked(self, false)
        if hasTarget then SCO_BeginEggTrebuchetOpen(self, now) end
    end
end

function HostWeapon:Update()
    if not SCO_IsEggTrebuchetWeapon(self) then
        return SCO_EggStockWeaponUpdate(self)
    end
    local activeOrder = self.unit.orders and self.unit.orders.activeOrder
    local explicitMove = activeOrder and activeOrder.orderTask == SCO_EggOrderTasks.MOVE
    if explicitMove then
        self:SCO_ReleaseEggTrebuchetForMove()
    else
        self:SCO_UpdateEggTrebuchetLifecycle(GetGameTimeSeconds())
    end
    if not explicitMove and self.scoEggTrebuchetState == "ready" then
        return SCO_EggStockWeaponUpdate(self)
    end

    -- Preserve reload time while withholding projectiles until the source
    -- deploy clip reaches its authored endpoint.
    if self.currentState == WeaponState.WaitingForReload then
        self.reloadTimer = self.reloadTimer - Constants.TickTimeStep
        if self.reloadTimer <= 0 then
            self.currentState = WeaponState.WaitingForTarget
        end
    end
    if not explicitMove then
        if self.UpdateTargeting then
            self:UpdateTargeting()
        else
            self:RecalculateTargets()
        end
    end
end
-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0
-- Preserve all earlier HostWeapon gates, then enforce only the explicit
-- ugl4002 source-depth markers carried by this port's physical template.
local SCO_MegalithStockCanShootAt = HostWeapon.CanShootAt
local SCO_MegalithTargetingLayer = Import("common/layers.lua").TargetingLayer

local function SCO_MegalithIsTorpedoTarget(target)
    local layer = target and target.targetingLayer
    return layer == SCO_MegalithTargetingLayer.Seabed
        or layer == SCO_MegalithTargetingLayer.Water
        or layer == SCO_MegalithTargetingLayer.WaterSurface
end

local function SCO_MegalithWaterGate(weapon, target)
    if not weapon.unit or weapon.unit.tpId ~= "ugl4002" then return true end
    local gate = weapon.tp and weapon.tp.scoMegalithWaterGate
    if gate == nil then return true end
    if gate ~= "Above" and gate ~= "Below" then return false end
    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success then return false end
    if not hasWater then return gate == "Above" end
    local levelResult, waterLevel = Engine.GetWaterLevel()
    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then
        return false
    end
    local ownerPosition = weapon.unit:GetPosition()
    local targetPosition = target and target:GetPosition()
    if ownerPosition == nil or targetPosition == nil then return false end
    local ownerAbove = ownerPosition.y >= waterLevel - 0.05
    local targetAbove = targetPosition.y >= waterLevel - 0.05
    if gate == "Above" then return ownerAbove and targetAbove end
    return weapon.unit.targetingLayer == SCO_MegalithTargetingLayer.Seabed
        and SCO_MegalithIsTorpedoTarget(target)
end

function HostWeapon:CanShootAt(targetUnit)
    return SCO_MegalithStockCanShootAt(self, targetUnit)
        and SCO_MegalithWaterGate(self, targetUnit)
end
-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0
local SCO_ScathisCommands = Import("common/commands/definitions/projectiles.lua")
local SCO_ScathisStockInit = HostWeapon.__init
local SCO_ScathisStockDelete = HostWeapon.Delete
local SCO_ScathisStockSetAimTarget = HostWeapon.SetAimTarget
local SCO_ScathisStockCanShootAt = HostWeapon.CanShootAt
local SCO_ScathisStockUpdate = HostWeapon.Update
local SCO_ScathisStockUpdateProjectile = HostWeapon.UpdateProjectile

local function SCO_IsScathisWeapon(self)
    return self.unit and self.unit.tpId == "ugl4011"
        and self.tp and self.tp.scoFaScathis == true
end

local function SCO_PlayScathisAnimation(self, key)
    local animation = self.unit.tp.visuals and self.unit.tp.visuals.animations
        and self.unit.tp.visuals.animations[key]
    if not animation or not animation.id then
        error("Scathis requires source animation " .. tostring(key))
    end
    local enableResult = Engine.SetAnimatorEnabled(self.unit.id, true)
    if enableResult ~= EngineErrorCode.Success then
        error("Scathis could not enable source animation " .. tostring(key))
    end
    self.scoScathisAnimatorSampling = true
    Engine.PlayAnimation(self.unit.id, animation.id, 0.1)
end

local SCO_ScathisOpenSeconds = 16.66666603088379
local SCO_ScathisPitchGoalTolerance = 0.05
local SCO_ScathisSampleSentinel = -10000

local function SCO_SampleScathisDeployment(self, progress)
    if not self.scoScathisAnimatorSampling then
        local enableResult = Engine.SetAnimatorEnabled(self.unit.id, true)
        if enableResult ~= EngineErrorCode.Success then
            error("Scathis could not enable source deployment sampling")
        end
        self.scoScathisAnimatorSampling = true
    end
    local animation = self.unit.tp.visuals and self.unit.tp.visuals.animations
        and self.unit.tp.visuals.animations.open
    if not animation or not animation.id then
        error("Scathis requires source animation open")
    end
    -- The coordinator's exact-time bridge samples the original open clip
    -- in either direction without restarting a fully open close clip.
    Engine.PlayAnimation(
        self.unit.id, animation.id, SCO_ScathisSampleSentinel + progress)
end

local function SCO_AdvanceScathisDeployment(self, now, direction)
    local lastTime = self.scoScathisDeployLastTime or now
    self.scoScathisDeployLastTime = now
    local progress = (self.scoScathisDeployProgress or 0)
        + direction * math.max(0, now - lastTime)
    progress = math.max(0, math.min(SCO_ScathisOpenSeconds, progress))
    self.scoScathisDeployProgress = progress
    SCO_SampleScathisDeployment(self, progress)
    return progress
end

local function SCO_SetScathisMovementLocked(self, locked)
    if self.scoScathisMovementLocked == locked then return end
    self.scoScathisMovementLocked = locked
    Engine.SetMovementEnabled(self.unit.id, not locked)
end

local function SCO_ResetScathisFakeTurret(self)
    if not self.scoScathisFakeTurretId then return end
    Engine.SetRotatorEnabled(self.scoScathisFakeTurretId, false)
    if self.scoScathisFakeTurretBaseRotation then
        Engine.SetGlobalEntityLocalRotation(
            self.scoScathisFakeTurretId,
            self.scoScathisFakeTurretBaseRotation)
    end
    self.scoScathisFakeRotationDegrees = 0
end

local function SCO_ScathisAngleBetween(a, b)
    local lengthA = math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
    local lengthB = math.sqrt(b.x * b.x + b.y * b.y + b.z * b.z)
    if lengthA <= 0 or lengthB <= 0 then
        error("Scathis cannot align a zero-length barrel direction")
    end
    local cosine = (a.x * b.x + a.y * b.y + a.z * b.z)
        / (lengthA * lengthB)
    cosine = math.max(-1, math.min(1, cosine))
    return math.acos(cosine) * 180 / math.pi
end

local function SCO_SetScathisPitch(self, degrees)
    local delta = Engine.QuaternionAxisAngle(
        EngineClasses.float3(1, 0, 0),
        math.rad(degrees))
    for index, boneId in ipairs(self.scoScathisPitchBoneIds) do
        Engine.SetGlobalEntityLocalRotation(
            boneId,
            Engine.QuaternionMultiply(self.scoScathisPitchBases[index], delta))
    end
    self.scoScathisPitchCurrent = degrees
end

local function SCO_ResetScathisPitch(self)
    if self.scoScathisPitchBases then
        for index, boneId in ipairs(self.scoScathisPitchBoneIds) do
            Engine.SetGlobalEntityLocalRotation(
                boneId,
                self.scoScathisPitchBases[index])
        end
    end
    self.scoScathisPitchBases = nil
    self.scoScathisPitchRestAngle = nil
    self.scoScathisPitchCurrent = 0
    self.scoScathisPitchGoal = 0
    self.scoScathisPitchLastTime = nil
    self.scoScathisPitchDelayDeadline = nil
end

local function SCO_ReadScathisPitchGoal(self)
    local aimResult, aimDirection = Engine.GetGlobalEntityForwardDirection(
        self.scoScathisAimBarrelBoneId)
    local baseResult, baseDirection = Engine.GetGlobalEntityForwardDirection(
        self.scoScathisAimBoneId)
    if aimResult ~= EngineErrorCode.Success or baseResult ~= EngineErrorCode.Success then
        error("Scathis cannot read central aim-barrel direction")
    end
    return self.scoScathisPitchRestAngle
        - SCO_ScathisAngleBetween(aimDirection, baseDirection)
end

local function SCO_BeginScathisPitchAlignment(self, now)
    -- SCOM Field Fix: Scathis deployed animator ownership 1.0.0
    -- AnimOpen keys all six B01 pitch bones. Freeze the sampled pose before
    -- manual pitch alignment, including target reacquisition.
    if self.scoScathisAnimatorSampling then
        local disableResult = Engine.SetAnimatorEnabled(self.unit.id, false)
        if disableResult ~= EngineErrorCode.Success then
            error("Scathis could not freeze its deployed source pose")
        end
        self.scoScathisAnimatorSampling = nil
    end
    if not self.scoScathisPitchBases then
        self.scoScathisPitchBases = {}
        for index, boneId in ipairs(self.scoScathisPitchBoneIds) do
            local rotation = EngineClasses.quaternion()
            local rotationResult = Engine.GetGlobalEntityLocalRotation(boneId, rotation)
            if rotationResult ~= EngineErrorCode.Success then
                error("Scathis cannot read fake barrel " .. tostring(index) .. " rotation")
            end
            self.scoScathisPitchBases[index] = rotation
        end
        local barrelResult, barrelDirection = Engine.GetGlobalEntityForwardDirection(
            self.scoScathisPitchBoneIds[self.scoScathisBarrelIndex])
        local baseResult, baseDirection = Engine.GetGlobalEntityForwardDirection(
            self.scoScathisAimBoneId)
        if barrelResult ~= EngineErrorCode.Success
            or baseResult ~= EngineErrorCode.Success
        then error("Scathis cannot read unpacked fake-barrel direction") end
        self.scoScathisPitchRestAngle =
            SCO_ScathisAngleBetween(barrelDirection, baseDirection)
    end

    self.scoScathisPitchGoal = SCO_ReadScathisPitchGoal(self)
    self.scoScathisPitchLastTime = now
    self.scoScathisPitchDelayDeadline = nil
    self.scoScathisDeployState = "aligning"
end

local function SCO_UpdateScathisPitchAlignment(self, now)
    local sampledGoal = SCO_ReadScathisPitchGoal(self)
    if math.abs(sampledGoal - (self.scoScathisPitchGoal or sampledGoal))
        > SCO_ScathisPitchGoalTolerance
    then
        self.scoScathisPitchGoal = sampledGoal
        self.scoScathisPitchDelayDeadline = nil
    end
    if self.scoScathisPitchDelayDeadline then
        if now >= self.scoScathisPitchDelayDeadline
            and self:IsWeaponOnTarget()
        then
            self.scoScathisDeployState = "deployed"
            return true
        end
        return false
    end

    local current = self.scoScathisPitchCurrent or 0
    local goal = self.scoScathisPitchGoal or 0
    local difference = goal - current
    local elapsed = math.max(0, now - (self.scoScathisPitchLastTime or now))
    local step = 30 * elapsed
    if math.abs(difference) <= step then
        local arrivalTime = now
        if step > 0 then
            arrivalTime = (self.scoScathisPitchLastTime or now)
                + math.abs(difference) / 30
        end
        SCO_SetScathisPitch(self, goal)
        self.scoScathisPitchDelayDeadline = arrivalTime + 0.2
    elseif step > 0 then
        SCO_SetScathisPitch(
            self,
            current + (difference > 0 and step or -step))
    end
    self.scoScathisPitchLastTime = now
    if self.scoScathisPitchDelayDeadline
        and now >= self.scoScathisPitchDelayDeadline
        and self:IsWeaponOnTarget()
    then
        self.scoScathisDeployState = "deployed"
        return true
    end
    return false
end

local function SCO_ScathisRotationThread(unit, weapon, generation)
    WaitSeconds(0.5)
    if unit.dead or weapon.scoScathisDisposed
        or weapon.scoScathisRotationGeneration ~= generation
    then return end
    Engine.SetRotatorSpeed(
        weapon.scoScathisFakeTurretId,
        EngineClasses.float3(0, 120, 0))
    Engine.SetRotatorEnabled(weapon.scoScathisFakeTurretId, true)
    WaitSeconds(0.5)
    if unit.dead or weapon.scoScathisDisposed
        or weapon.scoScathisRotationGeneration ~= generation
    then return end
    Engine.SetRotatorEnabled(weapon.scoScathisFakeTurretId, false)
    weapon.scoScathisFakeRotationDegrees =
        ((weapon.scoScathisFakeRotationDegrees or 0) + 60) % 360
end

function HostWeapon:__init(aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)
    SCO_ScathisStockInit(self, aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)
    if not SCO_IsScathisWeapon(self) then return end
    if #muzzleGroups ~= 7 or #muzzleGroups[1] ~= 1 then
        error("Scathis requires one central and six indexed fake muzzle groups")
    end
    if #aimControllerIds ~= 1 then
        error("Scathis requires exactly one aim controller")
    end
    -- Native velocity reduction uses the aim controller max range as its
    -- distance denominator. FA uses 2350; weapon targeting still reaches 4000.
    local rangeResult = Engine.SetAimControllerMaxRange(aimControllerIds[1], 2350)
    if rangeResult ~= EngineErrorCode.Success then
        error("Scathis cannot set FA muzzle velocity reduction distance")
    end
    self.scoScathisFakeMuzzles = {}
    for index = 2, 7 do
        if #muzzleGroups[index] ~= 1 then
            error("Scathis fake muzzle group " .. tostring(index - 1) .. " is invalid")
        end
        table.insert(self.scoScathisFakeMuzzles, muzzleGroups[index][1])
    end
    -- All seven host/client muzzle IDs remain registered. Only the central
    -- source muzzle may instantiate the real projectile.
    self.muzzleGroups = { muzzleGroups[1] }
    self.scoScathisBarrelIndex = 1
    self.scoScathisDeployState = "packed"
    self.scoScathisEnergyDebt = 0
    self.scoScathisRotationGeneration = 0
    self.scoScathisPitchBoneIds = {}
    local pitchBoneNames = {
        "Turret_Barrel_F_B01", "Turret_Barrel_E_B01",
        "Turret_Barrel_D_B01", "Turret_Barrel_C_B01",
        "Turret_Barrel_B_B01", "Turret_Barrel_A_B01",
    }
    for index, boneName in ipairs(pitchBoneNames) do
        local pitchResult, pitchBoneId = Engine.GetGlobalBone(unit.id, boneName)
        if pitchResult ~= EngineErrorCode.Success then
            error("Scathis fake pitch bone " .. tostring(index) .. " is absent")
        end
        self.scoScathisPitchBoneIds[index] = pitchBoneId
    end
    local aimResult, aimBoneId = Engine.GetGlobalBone(unit.id, "Turret_Aim")
    local aimBarrelResult, aimBarrelBoneId =
        Engine.GetGlobalBone(unit.id, "Turret_Aim_Barrel")
    if aimResult ~= EngineErrorCode.Success
        or aimBarrelResult ~= EngineErrorCode.Success
    then error("Scathis central aim bones are absent") end
    self.scoScathisAimBoneId = aimBoneId
    self.scoScathisAimBarrelBoneId = aimBarrelBoneId
    self.scoScathisPitchCurrent = 0
    self.scoScathisPitchGoal = 0
    local result, fakeTurretId = Engine.GetGlobalBone(unit.id, "Turret_Fake")
    if result ~= EngineErrorCode.Success then error("Scathis Turret_Fake bone is absent") end
    self.scoScathisFakeTurretId = fakeTurretId
    self.scoScathisFakeTurretBaseRotation = EngineClasses.quaternion()
    Engine.GetGlobalEntityLocalRotation(fakeTurretId, self.scoScathisFakeTurretBaseRotation)
    SCO_ResetScathisFakeTurret(self)
end

function HostWeapon:Delete()
    if SCO_IsScathisWeapon(self) then
        self.scoScathisDisposed = true
        self.scoScathisRotationGeneration =
            (self.scoScathisRotationGeneration or 0) + 1
        SCO_ResetScathisFakeTurret(self)
        SCO_ResetScathisPitch(self)
    end
    return SCO_ScathisStockDelete(self)
end

function HostWeapon:CanShootAt(targetUnit)
    if not SCO_IsScathisWeapon(self) then
        return SCO_ScathisStockCanShootAt(self, targetUnit)
    end
    if not SCO_ScathisStockCanShootAt(self, targetUnit) then return false end
    if not self.tp.scoFaAboveWaterTargetsOnly then return true end
    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success then return false end
    if not hasWater then return true end
    local levelResult, waterLevel = Engine.GetWaterLevel()
    local position = targetUnit and targetUnit:GetPosition()
    return levelResult == EngineErrorCode.Success and waterLevel ~= nil
        and position ~= nil and position.y >= waterLevel - 0.05
end

function HostWeapon:SetAimTarget(targetUnit)
    local previous = self.targetUnit
    local result = SCO_ScathisStockSetAimTarget(self, targetUnit)
    if not SCO_IsScathisWeapon(self) then return result end
    local now = GetGameTimeSeconds()
    if targetUnit then
        self.scoScathisTargetLostTime = nil
        if previous ~= targetUnit and self.scoScathisDeployState == "deployed" then
            SCO_BeginScathisPitchAlignment(self, now)
        end
    elseif previous ~= nil then
        self.scoScathisTargetLostTime = now
    end
    return result
end

function HostWeapon:SCO_UpdateScathisDeployment(now)
    local state = self.scoScathisDeployState
    local hasTarget = self:HasTarget()
    if state == "packed" then
        if not hasTarget then return end
        SCO_ResetScathisFakeTurret(self)
        SCO_SetScathisMovementLocked(self, true)
        self.scoScathisDeployProgress = 0
        self.scoScathisDeployLastTime = now
        self.scoScathisDeployState = "opening"
        SCO_SampleScathisDeployment(self, 0)
        return
    end

    if state == "closing" and hasTarget then
        -- Reacquisition reverses from the current pose while motion stays locked.
        self.scoScathisDeployState = "opening"
        self.scoScathisDeployLastTime = now
        state = "opening"
    end

    if state == "opening" or state == "repack_wait" then
        local progress = SCO_AdvanceScathisDeployment(self, now, 1)
        if state == "opening" then
            if not hasTarget then
                self.scoScathisTargetLostTime =
                    self.scoScathisTargetLostTime or now
                self.scoScathisDeployState = "repack_wait"
                state = "repack_wait"
            elseif progress >= SCO_ScathisOpenSeconds then
                SCO_BeginScathisPitchAlignment(self, now)
                state = "aligning"
            else
                return
            end
        end
    end

    if state == "deployed" and hasTarget
        and math.abs(SCO_ReadScathisPitchGoal(self)
            - (self.scoScathisPitchCurrent or 0))
            > SCO_ScathisPitchGoalTolerance
    then
        SCO_BeginScathisPitchAlignment(self, now)
        state = "aligning"
    end

    if state == "aligning" then
        if not hasTarget then
            self.scoScathisTargetLostTime =
                self.scoScathisTargetLostTime or now
            self.scoScathisDeployState = "repack_wait"
            state = "repack_wait"
        else
            if not SCO_UpdateScathisPitchAlignment(self, now) then return end
            state = "deployed"
        end
    end

    if state == "deployed" and not hasTarget then
        self.scoScathisTargetLostTime =
            self.scoScathisTargetLostTime or now
        self.scoScathisDeployState = "repack_wait"
        state = "repack_wait"
    end

    if state == "repack_wait" then
        if hasTarget then
            self.scoScathisTargetLostTime = nil
            if self.scoScathisDeployProgress >= SCO_ScathisOpenSeconds then
                SCO_BeginScathisPitchAlignment(self, now)
            else
                self.scoScathisDeployState = "opening"
            end
        elseif now >= self.scoScathisTargetLostTime + 4 then
            self.scoScathisRotationGeneration =
                (self.scoScathisRotationGeneration or 0) + 1
            SCO_ResetScathisFakeTurret(self)
            SCO_ResetScathisPitch(self)
            self.scoScathisDeployState = "closing"
            self.scoScathisDeployLastTime = now
        end
        return
    end

    if state == "closing" then
        if SCO_AdvanceScathisDeployment(self, now, -1) <= 0 then
            self.scoScathisDeployState = "packed"
            self.scoScathisDeployLastTime = nil
            self.scoScathisTargetLostTime = nil
            SCO_PlayScathisAnimation(self, "walk")
            SCO_SetScathisMovementLocked(self, false)
        end
    end
end

function HostWeapon:SCO_DrainScathisEnergy()
    local debt = self.scoScathisEnergyDebt or 0
    if debt <= 0 then return false end
    local economy = self.unit:GetEconomy()
    local request = math.min(
        debt,
        self.tp.scoFaEnergyDrainPerSecond * Constants.TickTimeStep)
    local taken = economy and economy:TakeResources("energy", request) or 0
    self.scoScathisEnergyDebt = math.max(0, debt - taken)
    return self.scoScathisEnergyDebt > 0
end

function HostWeapon:Update()
    if not SCO_IsScathisWeapon(self) then return SCO_ScathisStockUpdate(self) end
    self:SCO_UpdateScathisDeployment(GetGameTimeSeconds())
    local draining = self:SCO_DrainScathisEnergy()
    if self.scoScathisDeployState ~= "deployed" or draining then
        if self.currentState == WeaponState.WaitingForReload then
            self.reloadTimer = self.reloadTimer - Constants.TickTimeStep
            if self.reloadTimer <= 0 then
                self.currentState = WeaponState.WaitingForTarget
            end
        end
        if self.UpdateTargeting then
            self:UpdateTargeting()
        else
            self:RecalculateTargets()
        end
        return
    end
    return SCO_ScathisStockUpdate(self)
end

function HostWeapon:UpdateProjectile(isOnTarget)
    if not SCO_IsScathisWeapon(self) then
        return SCO_ScathisStockUpdateProjectile(self, isOnTarget)
    end
    local fired = false
    if self.currentState == WeaponState.ShootSalvo then
        local central = self.muzzleGroups[1] and self.muzzleGroups[1][1]
        fired = central ~= nil
            and self.projectileTemplate.general.prefabID ~= nil
            and self:GetDesiredProjectileValues(central.aimControllerId) ~= nil
    end
    local result = SCO_ScathisStockUpdateProjectile(self, isOnTarget)
    if fired then
        local fake = self.scoScathisFakeMuzzles[self.scoScathisBarrelIndex]
        SCO_ScathisCommands.FireMuzzle.Send(fake.id)
        self.scoScathisBarrelIndex = self.scoScathisBarrelIndex % 6 + 1
        self.scoScathisEnergyDebt = self.tp.scoFaEnergyRequired
        self.scoScathisRotationGeneration =
            (self.scoScathisRotationGeneration or 0) + 1
        self.unit:NewThread(
            SCO_ScathisRotationThread,
            self,
            self.scoScathisRotationGeneration)
    end
    return result
end


-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0
-- SCO_GalacticColossusTractor
-- FA's ADFTractorClaw accepts ordinary mobile units, excludes
-- structures/commanders/experimentals/naval/SACUs, lets only one
-- claw claim a target, makes the victim untargetable, and pulls its
-- root into MuzzleSpecial at 15 world units per second before the
-- crush. Sanctuary has no attachment slider, so the host simulation
-- performs the equivalent deterministic position integration.
local scoTractorHostOrderManager =
    Import("host/managers/orders/hostOrderManager.lua")
local scoTractorUnits = __Entities.Units
local scoTractorClaims =
    _G.SCO_GalacticColossusTractorClaims or {}
_G.SCO_GalacticColossusTractorClaims = scoTractorClaims

local scoTractorStockCanShootAt = HostWeapon.CanShootAt
local scoTractorStockDelete = HostWeapon.Delete
local scoTractorStockSetAimTarget = HostWeapon.SetAimTarget
local scoTractorStockUpdate = HostWeapon.Update

local function scoTractorIsCurrent(unit)
    local id = unit and unit.id
    return unit ~= nil
        and not unit.dead
        and not unit.deleted
        and id ~= nil
        and scoTractorUnits[id.index] == unit
end

local function scoWeaponPassesWaterGate(weapon, target)
    local tp = weapon.tp
    if tp == nil
        or (
            tp.scoAboveWaterFireOnly ~= true
            and tp.scoAboveWaterTargetsOnly ~= true)
    then
        return true
    end

    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success then
        return false
    end
    if not hasWater then
        return true
    end
    local levelResult, waterLevel = Engine.GetWaterLevel()
    if levelResult ~= EngineErrorCode.Success
        or waterLevel == nil
    then
        return false
    end
    if tp.scoAboveWaterFireOnly == true then
        local ownerPosition = weapon.unit:GetPosition()
        if ownerPosition == nil or ownerPosition.y < waterLevel then
            return false
        end
    end
    if tp.scoAboveWaterTargetsOnly == true then
        local targetPosition = target and target:GetPosition()
        if targetPosition == nil or targetPosition.y < waterLevel then
            return false
        end
    end
    return true
end

local function scoNormalizeHeadingDegrees(value)
    return (value + 180) % 360 - 180
end

local function scoWeaponPassesHeadingArc(weapon, target)
    local config = weapon.tp and weapon.tp.scoTractor
    if config == nil
        or config.headingArcCenter == nil
        or config.headingArcRange == nil
    then
        return true
    end

    local ownerPosition = weapon.unit:GetPosition()
    local targetPosition = target and target:GetPosition()
    if ownerPosition == nil or targetPosition == nil then
        return false
    end
    local deltaX = targetPosition.x - ownerPosition.x
    local deltaZ = targetPosition.z - ownerPosition.z
    if deltaX == 0 and deltaZ == 0 then
        return true
    end

    local yawResult, ownerYaw =
        Engine.GetMovementChassisYawDegrees(weapon.unit.id)
    if yawResult ~= EngineErrorCode.Success
        or ownerYaw == nil
    then
        return false
    end
    local targetHeading = math.deg(math.atan2(deltaX, deltaZ))
    local relativeHeading = scoNormalizeHeadingDegrees(
        targetHeading - ownerYaw - config.headingArcCenter)
    return math.abs(relativeHeading) <= config.headingArcRange
end

local function scoTractorTargetKey(target)
    local id = target and target.id
    if id == nil then
        return nil
    end
    return tostring(id.index) .. ":" .. tostring(id.version)
end

local function scoTractorHasCategory(target, category)
    local tags = target.tp and target.tp.hasTags
    if tags and (tags[category] or tags["SCFA_" .. category]) then return true end
    local additions = target.tp and target.tp.additions
    local contract = additions and additions.faSourceContract
    local categories = contract and contract.sourceCategories
    for _, sourceCategory in ipairs(categories or {}) do
        if sourceCategory == category then
            return true
        end
    end
    return false
end

local function scoTractorIsEligible(weapon, target, claimed)
    if not scoTractorIsCurrent(target)
        or (not claimed and target.isTargetable ~= true)
        or target.canTakeDamage == false
        or target.canBeKilled == false
        or not weapon.unit.army:IsEnemy(target.army)
    then
        return false
    end

    if not scoTractorHasCategory(target, "MOBILE")
        or not (scoTractorHasCategory(target, "TECH1")
            or scoTractorHasCategory(target, "TECH2")
            or scoTractorHasCategory(target, "TECH3"))
        or target.scoCargoCarrier or target.scoCargoReleasing or target.scoFactoryColliderPinOwner
    then
        return false
    end

    for _, excluded in ipairs({
        "STRUCTURE",
        "COMMAND",
        "EXPERIMENTAL",
        "NAVAL",
        "SUBCOMMANDER",
        "TECH4",
        "TECH5",
    }) do
        if scoTractorHasCategory(target, excluded) then
            return false
        end
    end
    return true
end

local function scoTractorIsAlreadyUsed(weapon, target)
    -- Provisional aim from the eye or another claw is not ownership.
    -- Only an established versioned claim excludes a victim.
    local key = scoTractorTargetKey(target)
    local claim = key and scoTractorClaims[key]
    return claim ~= nil and claim.weapon ~= weapon
end

local function scoTractorEyeYieldsToClaw(weapon, target)
    if weapon.unit.tpId ~= "ucl4004"
        or not weapon.tp or weapon.tp.scoSourceLabel ~= "EyeWeapon" then return false end
    for _, claw in ipairs(weapon.unit.weapons or {}) do
        if claw.tp and claw.tp.scoTractor and claw.enabled
            and claw.scoTractorTarget == nil
            and scoTractorStockCanShootAt(claw, target)
            and scoWeaponPassesWaterGate(claw, target)
            and scoWeaponPassesHeadingArc(claw, target)
            and scoTractorIsEligible(claw, target)
            and not scoTractorIsAlreadyUsed(claw, target)
            and claw:IsTargetInRange(target) then
            return true
        end
    end
    return false
end

local function scoTractorRelease(weapon, restoreTarget)
    local target = weapon.scoTractorTarget
    local key = weapon.scoTractorTargetKey
    local claim = key and scoTractorClaims[key]
    local ownsClaim = claim and claim.weapon == weapon and claim.target == target
    if ownsClaim then
        scoTractorClaims[key] = nil
        if target and target.scoTractorTargetKey == key then
            target.scoTractorTargetKey = nil
        end
    end

    weapon.scoTractorTarget = nil
    weapon.scoTractorTargetKey = nil
    weapon.scoTractorCaptureBone = nil
    weapon.scoTractorReleasing = true
    scoTractorStockSetAimTarget(weapon, nil)
    weapon.scoTractorReleasing = nil
    weapon:SetMuzzlesFiring(false)

    if restoreTarget and ownsClaim and scoTractorIsCurrent(target) then
        Engine.SetMovementEnabled(target.id, true)
        -- SetTargetable also disables/enables the unit collider.
        -- FA's SetDoNotTarget changes acquisition only, so keep
        -- the victim's beam/physics collider alive throughout.
        target.isTargetable = true
    end
end

local function scoTractorTryClaim(weapon)
    local config = weapon.tp and weapon.tp.scoTractor
    local target = weapon.targetUnit
    if config == nil
        or not weapon.enabled
        or not scoTractorIsCurrent(weapon.unit)
        or weapon.scoTractorTarget ~= nil
        or weapon.currentState
            ~= WeaponState.WaitingPersistentBeamLifetime
        or weapon.beamPendingEnable
        or not scoTractorIsEligible(weapon, target)
        or scoTractorIsAlreadyUsed(weapon, target)
    then
        return
    end

    local key = scoTractorTargetKey(target)
    local captureBone = weapon.unit:GetBoneId(config.captureBone)
    if key == nil
        or captureBone == nil
        or scoTractorClaims[key] ~= nil
    then
        return
    end

    scoTractorClaims[key] = {
        weapon = weapon,
        target = target,
    }
    weapon.scoTractorTarget = target
    weapon.scoTractorTargetKey = key
    weapon.scoTractorCaptureBone = captureBone
    target.scoTractorTargetKey = key
    scoTractorHostOrderManager.HostClearOrder({ target })
    Engine.SetMovementEnabled(target.id, false)
    target.isTargetable = false
    -- A previously aimed eye beam must stop before the first pull tick.
    for _, eye in ipairs(weapon.unit.weapons or {}) do
        if eye.tp and eye.tp.scoSourceLabel == "EyeWeapon" and eye.targetUnit == target then
            eye:SetAimTarget(nil)
            eye:SetMuzzlesFiring(false)
            eye:RequestRetarget()
        end
    end
end

local function scoTractorCrush(weapon, target, capturePosition)
    if not scoTractorIsCurrent(target) then
        return
    end
    if capturePosition ~= nil then
        SessionCommands.ExecuteClientFunction.Send(
            "SCOGalacticColossusTractorCrush",
            {
                position = {
                    x = capturePosition.x,
                    y = capturePosition.y,
                    z = capturePosition.z,
                },
            })
    end
    if target.SCOOnKilledUnit then
        -- The optional SCOM veterancy layer adds a third
        -- instigator argument while preserving DestroyType.
        -- Preserve FA kill attribution when composed.
        target:Destroy(1, DestroyType.Kinetic, weapon.unit)
    else
        target:Destroy(1, DestroyType.Kinetic)
    end
end

local function scoTractorPull(weapon)
    local target = weapon.scoTractorTarget
    local config = weapon.tp and weapon.tp.scoTractor
    if not scoTractorIsCurrent(weapon.unit)
        or not weapon.enabled
        or not scoTractorIsEligible(weapon, target, true)
        or not scoWeaponPassesWaterGate(weapon, target)
        or config == nil
        or weapon.scoTractorCaptureBone == nil
    then
        scoTractorRelease(weapon, true)
        return
    end

    if type(Engine.IsValidGlobalID) == "function"
        and not Engine.IsValidGlobalID(weapon.scoTractorCaptureBone)
    then
        scoTractorRelease(weapon, true)
        return
    end
    local result, capturePosition = Engine.GetGlobalEntityWorldPosition(
        weapon.scoTractorCaptureBone)
    if result ~= EngineErrorCode.Success
        or capturePosition == nil
    then
        scoTractorRelease(weapon, true)
        return
    end
    local targetPosition = target:GetPosition()
    if targetPosition == nil then
        scoTractorRelease(weapon, true)
        return
    end
    local deltaX = capturePosition.x - targetPosition.x
    local deltaY = capturePosition.y - targetPosition.y
    local deltaZ = capturePosition.z - targetPosition.z
    local distance = math.sqrt(
        deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
    local step = config.pullSpeed * Constants.TickTimeStep
    if step <= 0 then
        scoTractorRelease(weapon, true)
        return
    end

    if distance <= step then
        target:SetPosition(EngineClasses.float3(
            capturePosition.x,
            capturePosition.y,
            capturePosition.z))
        scoTractorRelease(weapon, false)
        scoTractorCrush(weapon, target, capturePosition)
        return
    end

    local ratio = step / distance
    target:SetPosition(EngineClasses.float3(
        targetPosition.x + deltaX * ratio,
        targetPosition.y + deltaY * ratio,
        targetPosition.z + deltaZ * ratio))
end

function HostWeapon:CanShootAt(target)
    if not scoWeaponPassesWaterGate(self, target) then
        return false
    end
    if self.tp and self.tp.scoTractor then
        if self.scoTractorTarget == target
            and scoTractorIsCurrent(target)
        then
            return true
        end
        return scoTractorStockCanShootAt(self, target)
            and scoWeaponPassesHeadingArc(self, target)
            and scoTractorIsEligible(self, target)
            and not scoTractorIsAlreadyUsed(self, target)
    end
    return scoTractorStockCanShootAt(self, target)
        and not scoTractorEyeYieldsToClaw(self, target)
end

function HostWeapon:SetAimTarget(target)
    if self.scoTractorTarget ~= nil
        and target ~= self.scoTractorTarget
        and not self.scoTractorReleasing
    then
        return
    end
    if self.unit.tpId == "ucl4004" and self.tp
        and self.tp.scoSourceLabel == "EyeWeapon" and self.targetUnit ~= target then
        -- Native persistent beams otherwise keep firing for one nil-target tick.
        self:SetMuzzlesFiring(false)
    end
    return scoTractorStockSetAimTarget(self, target)
end

function HostWeapon:Update()
    if self.tp and self.tp.scoTractor and not self.enabled then
        if self.scoTractorTarget then scoTractorRelease(self, true) end
        self:SetMuzzlesFiring(false)
        return
    end
    scoTractorStockUpdate(self)
    if self.tp and self.tp.scoTractor then
        if self.scoTractorTarget == nil then
            scoTractorTryClaim(self)
        end
        if self.scoTractorTarget ~= nil then
            scoTractorPull(self)
        end
    end
end

function HostWeapon:Delete()
    if self.scoTractorTarget ~= nil then
        -- A destroyed or removed Colossus no longer owns the victim.
        -- Release a living unit instead of killing it out of band.
        scoTractorRelease(self, true)
    end
    return scoTractorStockDelete(self)
end


-- Supreme Commander Overhaul FA animation closure 1.0.1
local SCO_AnimationClosureWeaponStockDelete = HostWeapon.Delete
local SCO_AnimationClosureWeaponStockSetAimTarget = HostWeapon.SetAimTarget
local SCO_AnimationClosureWeaponStockUpdate = HostWeapon.Update
local SCO_AnimationClosureWeaponSentinelBase = -10000

local function SCO_AnimationClosureWeaponConfig(weapon)
    if not weapon.tp or not weapon.tp.scoFaAnimationClosureDeploy then
        return nil
    end
    local additions = weapon.unit and weapon.unit.tp
        and weapon.unit.tp.additions
    return additions and additions.faAnimationClosureWeaponDeploy
end

local function SCO_AnimationClosureWeaponSample(weapon, key, seconds)
    local animations = weapon.unit.tp.visuals
        and weapon.unit.tp.visuals.animations
    local animation = animations and animations[key]
    if not animation or not animation.id then
        error(weapon.unit.tpId .. " requires source animation " .. tostring(key))
    end
    Engine.PlayAnimation(
        weapon.unit.id,
        animation.id,
        SCO_AnimationClosureWeaponSentinelBase + seconds)
end

local function SCO_AnimationClosureWeaponSetMovement(weapon, locked)
    if weapon.scoFaAnimationMovementLocked == locked then return end
    local unit = weapon.unit
    local unitId = unit and unit.tpId
    if unitId ~= "usl3101" and unitId ~= "ucl3801" then
        error("Unexpected FA animation-closure movement lock owner")
    end
    if unit.dead or unit.deleted then
        weapon.scoFaAnimationMovementLocked = locked
        weapon.scoFaAnimationPreviousMaxSpeed = nil
        return
    end
    local speed
    if locked then
        local status
        status, speed = Engine.GetMovementMaxSpeed(unit.id)
        if status ~= EngineErrorCode.Success or type(speed) ~= "number" then
            error(unitId .. " deploy could not read movement speed")
        end
        -- Keep movement active so native separation retains the collision entry.
        local stop = Engine.MovementStop(unit.id, EngineClasses.float2(0, 0))
        if stop ~= EngineErrorCode.Success then
            error(unitId .. " deploy could not stop movement")
        end
    else
        speed = weapon.scoFaAnimationPreviousMaxSpeed
        if type(speed) ~= "number" then
            error(unitId .. " deploy has no movement speed to restore")
        end
    end
    local result = Engine.SetMovementMaxSpeed(unit.id, locked and 0 or speed)
    if result ~= EngineErrorCode.Success then
        error(unitId .. " deploy could not update movement speed")
    end
    weapon.scoFaAnimationPreviousMaxSpeed = locked and speed or nil
    weapon.scoFaAnimationMovementLocked = locked
end

local function SCO_AnimationClosureWeaponPlayPacked(weapon, config)
    local construction = config.constructionOpen
    if construction then
        SCO_AnimationClosureWeaponSample(
            weapon,
            construction.animationKey,
            construction.authoredDurationSeconds)
        return
    end
    local animations = weapon.unit.tp.visuals
        and weapon.unit.tp.visuals.animations
    local packed = animations and animations[config.packedAnimationKey]
    if not packed or not packed.id then
        error(weapon.unit.tpId .. " requires its source packed pose")
    end
    Engine.PlayAnimation(weapon.unit.id, packed.id, 0.1)
end

local function SCO_AnimationClosureWeaponBegin(weapon, state, config)
    weapon.scoFaAnimationDeployState = state
    if state == "opening" and config.sourceWeaponUnpackLocksMotion then
        SCO_AnimationClosureWeaponSetMovement(weapon, true)
    end
end

local function SCO_AnimationClosureWeaponAdvance(weapon, config, now)
    local state = weapon.scoFaAnimationDeployState or "packed"
    local sample = weapon.scoFaAnimationDeploySample or 0
    local hasTarget = weapon:HasTarget()

    if config.constructionOpen
        and weapon.unit.scoFaAnimationConstructionReady ~= true
    then
        return false
    end

    if hasTarget then
        weapon.scoFaAnimationTargetLostTime = nil
        if state == "packed" or state == "closing" then
            SCO_AnimationClosureWeaponBegin(weapon, "opening", config)
            state = "opening"
        end
    elseif weapon.scoFaAnimationTargetLostTime == nil then
        weapon.scoFaAnimationTargetLostTime = now
    end

    if state == "opening" then
        SCO_AnimationClosureWeaponSample(
            weapon, config.deployAnimationKey, sample)
        sample = math.min(
            config.authoredDurationSeconds,
            sample + Constants.TickTimeStep * config.authoredRate)
        weapon.scoFaAnimationDeploySample = sample
        if sample >= config.authoredDurationSeconds then
            SCO_AnimationClosureWeaponSample(
                weapon, config.deployAnimationKey, sample)
            weapon.scoFaAnimationDeployState = "deployed"
            state = "deployed"
        else
            return false
        end
    end

    if state == "deployed" and not hasTarget
        and now >= weapon.scoFaAnimationTargetLostTime
            + config.repackTimeoutSeconds
    then
        SCO_AnimationClosureWeaponBegin(weapon, "closing", config)
        state = "closing"
    end

    if state == "closing" then
        if hasTarget then
            SCO_AnimationClosureWeaponBegin(weapon, "opening", config)
            return false
        end
        SCO_AnimationClosureWeaponSample(
            weapon, config.deployAnimationKey, sample)
        sample = math.max(
            0,
            sample - Constants.TickTimeStep * config.authoredRate)
        weapon.scoFaAnimationDeploySample = sample
        if sample <= 0 then
            weapon.scoFaAnimationDeployState = "packed"
            weapon.scoFaAnimationTargetLostTime = nil
            SCO_AnimationClosureWeaponPlayPacked(weapon, config)
            if config.sourceWeaponUnpackLocksMotion then
                SCO_AnimationClosureWeaponSetMovement(weapon, false)
            end
        end
        return false
    end

    return weapon.scoFaAnimationDeployState == "deployed"
end

function HostWeapon:Delete()
    local config = SCO_AnimationClosureWeaponConfig(self)
    if config and self.scoFaAnimationMovementLocked then
        SCO_AnimationClosureWeaponSetMovement(self, false)
    end
    return SCO_AnimationClosureWeaponStockDelete(self)
end

function HostWeapon:SetAimTarget(targetUnit)
    local previous = self.targetUnit
    local result = SCO_AnimationClosureWeaponStockSetAimTarget(
        self, targetUnit)
    local config = SCO_AnimationClosureWeaponConfig(self)
    if config then
        local now = GetGameTimeSeconds()
        if targetUnit ~= nil then
            self.scoFaAnimationTargetLostTime = nil
            if self.scoFaAnimationDeployState == "closing" then
                SCO_AnimationClosureWeaponBegin(self, "opening", config)
            end
        elseif previous ~= nil then
            self.scoFaAnimationTargetLostTime = now
        end
    end
    return result
end

function HostWeapon:Update()
    if self.tp and self.tp.scoFaAnimationClosureSurfaceWeapon
        and not self.unit.scoFaSubmarineCannonReady
    then
        return
    end
    local config = SCO_AnimationClosureWeaponConfig(self)
    if config and not SCO_AnimationClosureWeaponAdvance(
        self, config, GetGameTimeSeconds())
    then
        return
    end
    return SCO_AnimationClosureWeaponStockUpdate(self)
end

-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0
-- FA surface bombers do not fire when a target merely enters weapon
-- range. NeedToComputeBombDrop predicts the impact point using the
-- carrier's velocity plus a reviewed forward release bonus and releases
-- only inside BombDropThreshold. Keep
-- Sanctuary's stock targeting and salvo state machine, but restore that
-- source-owned release gate and RealisticOrdinance velocity inheritance
-- for the ten private surface-bomb projectile IDs. Ahwassa's four fixed
-- AA stations also retain their source-relative heading acquisition arcs.
local SCO_FaBomberDropEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCO_FaBomberDropInstalled = rawget(
    SCO_FaBomberDropEnvironment,
    "SCO_FaBomberDropInstalled")
if SCO_FaBomberDropInstalled ~= nil
    and SCO_FaBomberDropInstalled ~= "1.0.0"
then
    error("Unsupported SCOM FA bomber drop runtime "
        .. tostring(SCO_FaBomberDropInstalled))
end
if SCO_FaBomberDropInstalled == nil then
    if type(HostWeapon) ~= "table"
        or type(HostWeapon.CanShootAt) ~= "function"
        or type(HostWeapon.IsWeaponOnTarget) ~= "function"
        or type(HostWeapon.GetDesiredProjectileValues) ~= "function"
        or type(Engine.GetGlobalEntityWorldPosition) ~= "function"
        or type(Engine.GetMovementHeadingDegrees) ~= "function"
        or type(Engine.GetMovementChassisYawDegrees) ~= "function"
        or type(Engine.GetMovementCurrentSpeed) ~= "function"
        or type(Engine.QuaternionLookRotationSafe) ~= "function"
        or type(Engine.HasWater) ~= "function"
        or type(Engine.GetWaterLevel) ~= "function"
    then
        error("SCOM FA bomber drop runtime cannot resolve host weapon functions")
    end

    local SCO_FaBomberStockCanShootAt =
        HostWeapon.CanShootAt
    local SCO_FaBomberStockIsWeaponOnTarget =
        HostWeapon.IsWeaponOnTarget
    local SCO_FaBomberStockGetDesiredProjectileValues =
        HostWeapon.GetDesiredProjectileValues
    local SCO_FaBomberDropProfiles = {
        pab101 = { threshold = 1.5, lifetime = 3, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 40 },
        pab301 = { threshold = 3.5, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 },
        peb101 = { threshold = 3, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 },
        peb301 = { threshold = 3.5, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 },
        pgb101 = { threshold = 3, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 25 },
        pgb301 = { threshold = 3.5, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 },
        psb101 = { threshold = 3, lifetime = 3, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 40 },
        psb202 = { threshold = 2, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 },
        psb301 = { threshold = 3.5, lifetime = 8, predictAhead = 3, forwardSpeedBonus = 3, maxSpeed = 20 },
        psb402 = { threshold = 4, lifetime = 8, predictAhead = 2, forwardSpeedBonus = 3, maxSpeed = 20 },
    }
    local SCO_FaBomberHeadingProfiles = {
        RightFrontAutocannon = { center = 310, range = 80 },
        LeftFrontAutocannon = { center = 60, range = 90 },
        RightRearAutocannon = { center = 180, range = 120 },
        LeftRearAutocannon = { center = 180, range = 130 },
    }

    local function SCO_FaBomberDropContract(weapon)
        local contract = weapon and weapon.tp
            and weapon.tp.scoFaBombDrop
        if contract == nil then return nil end
        local profile = SCO_FaBomberDropProfiles[
            contract.runtimeProjectileId]
        if profile == nil
            or contract.version ~= "1.0.0"
            or contract.sourceNeedToComputeBombDrop ~= true
            or contract.sourceRealisticOrdinance ~= true
            or contract.sourceMuzzleVelocity ~= 0
            or contract.sourcePredictAheadForBombDrop ~= profile.predictAhead
            or contract.sourceBombDropThreshold ~= profile.threshold
            or contract.runtimeAimProjectileSpeed ~= 0.0001
            or contract.runtimeGravity ~= 4.9
            or contract.runtimeProjectileLifetime ~= profile.lifetime
            or contract.runtimeForwardSpeedBonus ~= profile.forwardSpeedBonus
            or contract.sourceProjectileMaxSpeed ~= profile.maxSpeed
            or contract.runtimeReleaseMode
                ~= "PredictedHorizontalImpactThreshold"
            or contract.runtimeVelocityMode
                ~= "CarrierCurrentMovementSpeedPlusForwardBonus"
            or weapon.tp.projectileTemplate
                ~= contract.runtimeProjectileId
            or weapon.tp.projectileLifetime ~= profile.lifetime
        then
            error("Malformed SCOM FA bomber drop weapon contract")
        end
        return contract
    end

    local function SCO_FaBomberHeadingContract(weapon)
        local contract = weapon and weapon.tp
            and weapon.tp.scoFaHeadingArc
        if contract == nil then return nil end
        local profile = SCO_FaBomberHeadingProfiles[
            contract.sourceLabel]
        local unitTemplate = weapon.unit and weapon.unit.tp
        local unitId = unitTemplate and unitTemplate.general
            and unitTemplate.general.tpId
        local aim = weapon.tp.aimControllers
            and weapon.tp.aimControllers[1]
        local gravity = aim and aim.aimGravity
        if profile == nil
            or contract.version ~= "1.0.0"
            or contract.sourceUnitId ~= "XSA0402"
            or contract.sourceHeadingArcCenter ~= profile.center
            or contract.sourceHeadingArcRange ~= profile.range
            or contract.runtimeMode ~= "HostRelativeHeadingGate"
            or unitId ~= "usa4011"
            or weapon.tp.projectileTemplate ~= "psf0101"
            or weapon.tp.damage ~= 450
            or aim == nil
            or aim.solverType ~= "NoArc"
            or aim.projectileSpeed ~= 90
            or gravity == nil
            or gravity.x ~= 0
            or gravity.y ~= 0
            or gravity.z ~= 0
        then
            error("Malformed SCOM Ahwassa AA heading contract")
        end
        return contract
    end

    local function SCO_FaBomberNormalizeHeading(value)
        return (value + 180) % 360 - 180
    end

    local function SCO_FaBomberPassesHeadingArc(
        weapon,
        target,
        contract)
        local ownerPosition = weapon.unit:GetPosition()
        local targetPosition = target and target:GetPosition()
        if ownerPosition == nil or targetPosition == nil then
            return false
        end
        local deltaX = targetPosition.x - ownerPosition.x
        local deltaZ = targetPosition.z - ownerPosition.z
        if deltaX == 0 and deltaZ == 0 then return true end
        local _, ownerYaw = Engine.GetMovementChassisYawDegrees(weapon.unit.id)
        if type(ownerYaw) ~= "number" then return false end
        local targetHeading = math.deg(math.atan2(deltaX, deltaZ))
        local arcCenter = contract.sourceHeadingArcCenter
        local tp = weapon.unit.tp
        if tp.general.tpId == "usa4011" and tp.additions
            and tp.additions.scoAircraftVisualRoll == 180 then
            arcCenter = -arcCenter
        end
        local relativeHeading = SCO_FaBomberNormalizeHeading(
            targetHeading
                - ownerYaw
                - arcCenter)
        return math.abs(relativeHeading)
            <= contract.sourceHeadingArcRange
    end

    local function SCO_FaBomberHorizontalForward(entityId)
        local _, heading = Engine.GetMovementHeadingDegrees(entityId)
        if type(heading) ~= "number" then return nil end
        local radians = math.rad(heading)
        return { x = math.sin(radians), z = math.cos(radians) }
    end

    local function SCO_FaBomberMovementSpeed(unit, useFlightFallback)
        -- Stationary targets have no native Movement component.
        if not (unit.tp and unit.tp.movement) then return 0 end
        local _, speed = Engine.GetMovementCurrentSpeed(unit.id)
        if type(speed) == "number" and speed > 0 then
            return speed
        end
        if useFlightFallback then
            local movement = unit.tp and unit.tp.movement
            return movement and (movement.minSpeed or movement.speed) or 0
        end
        return 0
    end

    local function SCO_FaBomberLaunchSpeed(weapon, contract)
        local inheritedSpeed =
            SCO_FaBomberMovementSpeed(weapon.unit, true)
        return math.min(
            inheritedSpeed + contract.runtimeForwardSpeedBonus,
            contract.sourceProjectileMaxSpeed)
    end

    function SCO_FaBomberCarrierFiringRotation(
        weapon,
        fallbackRotation)
        local contract = SCO_FaBomberDropContract(weapon)
        if contract == nil then return fallbackRotation end
        local forward = SCO_FaBomberHorizontalForward(weapon.unit.id)
        if forward == nil then return fallbackRotation end
        return Engine.QuaternionLookRotationSafe(
            EngineClasses.float3(forward.x, 0, forward.z),
            EngineClasses.float3(0, 1, 0))
    end

    local function SCO_FaBomberDropIsAligned(weapon, contract)
        local target = weapon.targetUnit
        local muzzleGroup = weapon.muzzleGroups[
            weapon.currentMuzzleGroupIndex]
            or weapon.muzzleGroups[1]
        local muzzle = muzzleGroup and muzzleGroup[1]
        if target == nil or muzzle == nil
            or target.dead or target.deleted or weapon.unit.dead or weapon.unit.deleted
            or not Engine.IsValidGlobalID(weapon.unit.id)
            or not Engine.IsValidGlobalID(muzzle.id)
            or not Engine.IsValidGlobalID(target.id) then return false end

        local muzzleResult, muzzlePosition =
            Engine.GetGlobalEntityWorldPosition(muzzle.id)
        local targetResult, targetPosition =
            Engine.GetGlobalEntityWorldPosition(target.id)
        if muzzleResult ~= EngineErrorCode.Success
            or targetResult ~= EngineErrorCode.Success then return false end
        local carrierForward =
            SCO_FaBomberHorizontalForward(weapon.unit.id)
        if muzzlePosition == nil
            or targetPosition == nil
            or carrierForward == nil
        then
            return false
        end

        local height = muzzlePosition.y - targetPosition.y
        if height <= 0 then return false end
        local fallTime = math.sqrt(
            (2 * height) / contract.runtimeGravity)
        if fallTime >= contract.runtimeProjectileLifetime then
            return false
        end

        local launchSpeed = SCO_FaBomberLaunchSpeed(weapon, contract)
        local impactX = muzzlePosition.x
            + carrierForward.x * launchSpeed * fallTime
        local impactZ = muzzlePosition.z
            + carrierForward.z * launchSpeed * fallTime

        local predictedTargetX = targetPosition.x
        local predictedTargetZ = targetPosition.z
        local targetSpeed = SCO_FaBomberMovementSpeed(target, false)
        if targetSpeed > 0 then
            local targetForward =
                SCO_FaBomberHorizontalForward(target.id)
            if targetForward ~= nil then
                predictedTargetX = predictedTargetX
                    + targetForward.x * targetSpeed * fallTime
                predictedTargetZ = predictedTargetZ
                    + targetForward.z * targetSpeed * fallTime
            end
        end

        local missX = impactX - predictedTargetX
        local missZ = impactZ - predictedTargetZ
        local threshold = contract.sourceBombDropThreshold
        return missX * missX + missZ * missZ
            <= threshold * threshold
    end

    function HostWeapon:CanShootAt(target)
        if not SCO_FaBomberStockCanShootAt(self, target) then
            return false
        end
        -- Nine source bomb weapons explicitly require an above-water
        -- target. Sanctuary's targetWaterLimits field is descriptive;
        -- enforce that source constraint after the native target gate.
        -- UAA0103/pab101 omits AboveWaterTargetsOnly and is unchanged.
        local bomb = SCO_FaBomberDropContract(self)
        if bomb ~= nil and bomb.runtimeProjectileId ~= "pab101" then
            local waterResult, hasWater = Engine.HasWater()
            if waterResult ~= EngineErrorCode.Success then return false end
            if hasWater then
                local levelResult, level = Engine.GetWaterLevel()
                if levelResult ~= EngineErrorCode.Success
                    or type(level) ~= "number"
                    or target == nil
                    or type(target.GetPosition) ~= "function"
                then
                    return false
                end
                local position = target:GetPosition()
                if position == nil or type(position.y) ~= "number"
                    or position.y < level - 0.05
                then
                    return false
                end
            end
        end
        local contract = SCO_FaBomberHeadingContract(self)
        if contract == nil then return true end
        return SCO_FaBomberPassesHeadingArc(
            self,
            target,
            contract)
    end

    function HostWeapon:IsWeaponOnTarget()
        if not SCO_FaBomberStockIsWeaponOnTarget(self) then
            return false
        end
        local contract = SCO_FaBomberDropContract(self)
        if contract == nil then return true end
        return SCO_FaBomberDropIsAligned(self, contract)
    end

    function HostWeapon:GetDesiredProjectileValues(aimControllerId)
        local desiredSpeed, gravity, targetBoneId =
            SCO_FaBomberStockGetDesiredProjectileValues(
                self,
                aimControllerId)
        if desiredSpeed == nil then return nil end
        local contract = SCO_FaBomberDropContract(self)
        if contract == nil then
            return desiredSpeed, gravity, targetBoneId
        end
        local launchSpeed = SCO_FaBomberLaunchSpeed(self, contract)
        return launchSpeed,
            EngineClasses.float3(0, -contract.runtimeGravity, 0),
            targetBoneId
    end

    rawset(
        SCO_FaBomberDropEnvironment,
        "SCO_FaBomberDropInstalled",
        "1.0.0")
end

-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0

-- Supreme Commander Overhaul commander enhancements 1.0.0
-- Narrow FA target-category parity for opt-in commander weapons.

local SCOCommanderWeaponTargetEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderWeaponTargetVersion = "1.0.0"
local SCOCommanderWeaponTargetMarker = rawget(
    SCOCommanderWeaponTargetEnvironment,
    "SCO_CommanderWeaponTargetInstalled")

if SCOCommanderWeaponTargetMarker ~= nil
    and SCOCommanderWeaponTargetMarker ~= SCOCommanderWeaponTargetVersion
then
    error("Unsupported SCOM commander weapon-target marker "
        .. tostring(SCOCommanderWeaponTargetMarker))
end

if SCOCommanderWeaponTargetMarker == nil then
    if type(HostWeapon) ~= "table"
        or type(HostWeapon.CanShootAt) ~= "function"
        or type(Tags) ~= "table"
        or Tags.NAVAL == nil
        or Tags.MOBILE == nil
        or Tags.HOVER == nil
    then
        error("SCOM commander weapon targeting could not resolve dependencies")
    end

    local SCOPreviousCommanderWeaponCanShootAt = HostWeapon.CanShootAt

    local function SCOCommanderWeaponPassesTargetFilter(weapon, target)
        local filter = weapon.tp and weapon.tp.scoCommanderTargetFilter
        if filter == nil then return true end
        if filter ~= "NavalMobileNonHover" then return false end
        if target == nil or type(target.HasTags) ~= "function" then
            return false
        end
        return target:HasTags(Tags.NAVAL)
            and target:HasTags(Tags.MOBILE)
            and not target:HasTags(Tags.HOVER)
    end

    function HostWeapon:CanShootAt(target)
        return SCOPreviousCommanderWeaponCanShootAt(self, target)
            and SCOCommanderWeaponPassesTargetFilter(self, target)
    end

    rawset(
        SCOCommanderWeaponTargetEnvironment,
        "SCO_CommanderWeaponTargetInstalled",
        SCOCommanderWeaponTargetVersion)
end

-- Supreme Commander Overhaul Monkeylord collider aim fix 1.3.0
local SCOM_MonkeylordPreviousGetRandomTargetBoneID =
    HostWeapon.GetRandomTargetBoneID

function HostWeapon:GetRandomTargetBoneID(targetUnit)
    if self.tp and self.tp.scomAimAtTargetCollider then
        local targetCollider = targetUnit and targetUnit.targetCollider
        local targetColliderID = targetCollider and targetCollider.id
        if targetColliderID and Engine.IsValidGlobalID(targetColliderID) then
            return targetColliderID
        end
    end
    return SCOM_MonkeylordPreviousGetRandomTargetBoneID(self, targetUnit)
end

-- Supreme Commander Overhaul sea parity 1.0.0
-- Sanctuary validates targetWaterLimits but does not consume it. Generated
-- surface-only guns opt into this narrow physical target-height gate.
local SCOSeaParityPreviousHostWeaponCanShootAt = HostWeapon.CanShootAt
function HostWeapon:CanShootAt(targetUnit)
    if not SCOSeaParityPreviousHostWeaponCanShootAt(self, targetUnit) then
        return false
    end
    if self.tp == nil
        or self.tp.scoSeaParityTargetGate ~= "TargetAbove"
    then
        return true
    end
    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success then return false end
    if not hasWater then return true end
    local levelResult, waterLevel = Engine.GetWaterLevel()
    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then
        return false
    end
    local targetPosition = targetUnit and targetUnit:GetPosition()
    return targetPosition ~= nil
        and targetPosition.y >= waterLevel - 0.05
end
-- SCOM Field Fix: Galactic Colossus off-target beam gate 1.0.1
local SCO_GalacticColossusBeamGateVersion = "1.0.1"
local SCO_GalacticColossusBeamGateInstalled =
    _G.SCO_GalacticColossusBeamGateInstalled
if SCO_GalacticColossusBeamGateInstalled ~= nil
    and SCO_GalacticColossusBeamGateInstalled
        ~= SCO_GalacticColossusBeamGateVersion
then
    error("SCOM Galactic Colossus beam gate found an unsupported installed version")
end
if SCO_GalacticColossusBeamGateInstalled == nil then

    if type(HostWeapon) ~= "table"
        or type(HostWeapon.UpdateBeam) ~= "function"
        or type(HostWeapon.HasTarget) ~= "function"
        or type(HostWeapon.SetMuzzlesFiring) ~= "function"
        or type(WeaponState) ~= "table"
        or WeaponState.WaitingPersistentBeamLifetime == nil
    then
        error("SCOM Galactic Colossus beam gate could not resolve HostWeapon state APIs")
    end

    local SCO_GalacticColossusStockUpdateBeam = HostWeapon.UpdateBeam
    local SCO_GalacticColossusPersistentBeamState =
        WeaponState.WaitingPersistentBeamLifetime
    local SCO_GalacticColossusContractLogged = false
    local SCO_GalacticColossusSuspensionLogged = false
    local SCO_GalacticColossusResumeLogged = false

    local function SCO_GetGalacticColossusEyeState(weapon)
        local weaponTemplate = weapon and weapon.tp
        local unitTemplate = weapon and weapon.unit and weapon.unit.tp
        local weapons = unitTemplate and unitTemplate.weapons
        if type(weaponTemplate) ~= "table"
            or type(unitTemplate) ~= "table"
            or type(unitTemplate.general) ~= "table"
            or unitTemplate.general.tpId ~= "ucl4004"
            or type(weapons) ~= "table"
            or weapons[1] ~= weaponTemplate
            or weaponTemplate.scoFieldFixGalacticColossusEye ~= "1.0.1"
        then
            return nil
        end

        local additions = unitTemplate and unitTemplate.additions
        local contract = additions and additions.scoFieldFixColossusEye
        local controllers = weaponTemplate and weaponTemplate.aimControllers
        local aim = controllers and controllers[1]
        return weapon.isBeamWeapon == true
            and weaponTemplate.scoSourceLabel == "EyeWeapon"
            and weaponTemplate.beamLifetime == -1
            and type(additions) == "table"
            and additions.scoFieldFixGalacticColossusEye == "1.0.1"
            and type(contract) == "table"
            and contract.version == "1.0.1"
            and contract.aimBone == "Head_Muzzle"
            and contract.yawBone == "Head"
            and contract.pitchBone == "Head_Muzzle"
            and contract.aimTolerance == 0.05
            and contract.offTargetHostGateRequired == true
            and type(controllers) == "table"
            and type(aim) == "table"
            and aim.aimBone == "Head_Muzzle"
            and aim.yawBone == "Head"
            and aim.pitchBone == "Head_Muzzle"
            and aim.aimTolerance == 0.05
    end

    function HostWeapon:UpdateBeam(isOnTarget)
        local eyeState = SCO_GetGalacticColossusEyeState(self)
        if eyeState == nil then
            return SCO_GalacticColossusStockUpdateBeam(self, isOnTarget)
        end
        if eyeState == false then
            if not self.scoGalacticColossusAimSuspended then
                self:SetMuzzlesFiring(false)
                self.scoGalacticColossusAimSuspended = true
            end
            return
        end
        if not SCO_GalacticColossusContractLogged and type(Log) == "function" then
            Log("[SCOM Field Fixes] Matched the Galactic Colossus 1.0.1 host eye contract.")
            SCO_GalacticColossusContractLogged = true
        end

        local hasTarget = self:HasTarget()
        local active = self.currentState
                == SCO_GalacticColossusPersistentBeamState
            and not self.beamPendingEnable
            and hasTarget
        if active and not isOnTarget then
            if not self.scoGalacticColossusAimSuspended then
                self:SetMuzzlesFiring(false)
                self.scoGalacticColossusAimSuspended = true
                if not SCO_GalacticColossusSuspensionLogged
                    and type(Log) == "function"
                then
                    Log("[SCOM Field Fixes] Suspended an off-target Galactic Colossus eye beam.")
                    SCO_GalacticColossusSuspensionLogged = true
                end
            end
            return
        end
        if active and isOnTarget and self.scoGalacticColossusAimSuspended then
            if self.enabled then
                self:SetMuzzlesFiring(true)
                self.scoGalacticColossusAimSuspended = nil
                if not SCO_GalacticColossusResumeLogged
                    and type(Log) == "function"
                then
                    Log("[SCOM Field Fixes] Resumed an on-target Galactic Colossus eye beam.")
                    SCO_GalacticColossusResumeLogged = true
                end
            end
            return
        end

        local result = SCO_GalacticColossusStockUpdateBeam(self, isOnTarget)
        if self.currentState ~= SCO_GalacticColossusPersistentBeamState
            or not self:HasTarget()
        then
            self.scoGalacticColossusAimSuspended = nil
        end
        return result
    end

    _G.SCO_GalacticColossusBeamGateInstalled =
        SCO_GalacticColossusBeamGateVersion
end
-- Supreme Commander Overhaul Aeon Structure Motion Closure 1.0.0
-- Body only. CachePatcherRuntime prepends the authoritative version marker.
local SCO_ASM_StockUpdateProjectile = HostWeapon.UpdateProjectile

local function SCO_ASM_SpawnCapableProjectileCount(weapon)
    if weapon.currentState ~= 2 then return 0 end
    local projectileTemplate = weapon.projectileTemplate
    local general = projectileTemplate and projectileTemplate.general
    if not general or not general.prefabID then return 0 end
    local muzzleGroup = weapon.muzzleGroups
        and weapon.muzzleGroups[weapon.currentMuzzleGroupIndex]
    if not muzzleGroup then return 0 end

    local count = 0
    for _, muzzle in ipairs(muzzleGroup) do
        local desiredProjectileSpeed =
            weapon:GetDesiredProjectileValues(muzzle.aimControllerId)
        if desiredProjectileSpeed then
            count = count + 1
        end
    end
    return count
end

function HostWeapon:UpdateProjectile(isOnTarget)
    local ownsDomeStep = self.tp
        and self.tp.scoAeonStructureMotionDomeStep == true
    local spawnCapableShots = ownsDomeStep
        and SCO_ASM_SpawnCapableProjectileCount(self)
        or 0
    local result = SCO_ASM_StockUpdateProjectile(self, isOnTarget)
    if spawnCapableShots > 0
        and self.unit
        and self.unit.SCO_AeonStructureMotionDomeStep
    then
        for _ = 1, spawnCapableShots do
            self.unit:SCO_AeonStructureMotionDomeStep()
        end
    end
    return result
end
-- SCOM Field Fix: Supreme Commander UEF artillery host parity 1.0.0
local SCOFaArtilleryStockInit = HostWeapon.__init
local SCOFaArtilleryStockCanShootAt = HostWeapon.CanShootAt
local SCOFaArtilleryStockSetAimTarget = HostWeapon.SetAimTarget
local SCOFaArtilleryStockUpdate = HostWeapon.Update
local SCOFaArtilleryStockUpdateProjectile = HostWeapon.UpdateProjectile
local SCOFaArtilleryStockGetDesiredProjectileValues = HostWeapon.GetDesiredProjectileValues
local SCOFaArtilleryStockIsWeaponOnTarget = HostWeapon.IsWeaponOnTarget

local function SCOFaArtilleryContract(weapon)
    local unit = weapon and weapon.unit
    local additions = unit and unit.tp and unit.tp.additions
    local contract = additions and additions.scoFaArtillery
    if contract == nil then
        return nil
    end
    if type(contract) ~= "table" or contract.version ~= "1.0.0"
        or contract.targetId ~= unit.tpId
        or type(contract.energyRequired) ~= "number"
        or type(contract.energyDrainPerSecond) ~= "number"
        or contract.energyRequired < 0
        or contract.energyDrainPerSecond <= 0
    then
        error("Invalid SCOM FA artillery contract for " .. tostring(unit and unit.tpId), 2)
    end
    return contract
end

local function SCOFaArtilleryFatboyGauss(weapon)
    local unit = weapon and weapon.unit
    local template = weapon and weapon.tp
    return unit ~= nil
        and unit.tpId == "uel4511"
        and template ~= nil
        and (template.projectileTemplate == "psf401"
            or template.projectileTemplate == "psf0154")
end

-- FA executable 0x638588..0x6385E5 reduces aim velocity from horizontal
-- distance, with denominator 90 and a cap at the source muzzle velocity 25.
-- Host setters also enqueue the matching client component command. Sampling
-- after Update lets the next native aim tick solve the requested speed before
-- firing; changing it before Update would starve a moving target indefinitely.
local function SCO_UpdateFatboySourceMuzzleSpeed(weapon)
    if not SCOFaArtilleryFatboyGauss(weapon) then return end
    if not weapon.targetUnit then
        weapon.scoFatboySourceMuzzleSpeeds=nil
        return
    end
    local speeds=weapon.scoFatboySourceMuzzleSpeeds or {}
    weapon.scoFatboySourceMuzzleSpeeds=speeds
    for _,id in ipairs(weapon.aimControllerIds or {}) do
        local previous=speeds[id.index]
        speeds[id.index]=nil
        local targetCode,targetId=Engine.GetAimControllerTarget(id)
        if targetCode==EngineErrorCode.Success and targetId then
            local muzzleCode,muzzle=Engine.GetGlobalEntityWorldPosition(id)
            local positionCode,target=Engine.GetGlobalEntityWorldPosition(targetId)
            if muzzleCode==EngineErrorCode.Success and positionCode==EngineErrorCode.Success
                and muzzle and target then
                local x,z=target.x-muzzle.x,target.z-muzzle.z
                local distance=math.sqrt(x*x+z*z)
                local speed=25*math.sqrt(math.min(distance/90,1))
                if previous==nil or math.abs(previous-speed)>0.00001 then
                    local result=Engine.SetAimControllerProjectileSpeed(id,speed)
                    if result~=EngineErrorCode.Success then
                        error('Fatboy source muzzle-speed update failed: '..tostring(result))
                    end
                    speeds[id.index]=speed
                else
                    -- Compare against the last value actually sent, so small
                    -- per-tick changes eventually accumulate into a new request.
                    speeds[id.index]=previous
                end
            end
        end
    end
end

-- A stale native solve must not start a reload or consume an empty salvo.
function HostWeapon:IsWeaponOnTarget()
    if not SCOFaArtilleryStockIsWeaponOnTarget(self) then return false end
    if SCOFaArtilleryFatboyGauss(self) then
        for _,muzzle in ipairs(self.muzzleGroups[self.currentMuzzleGroupIndex] or {}) do
            if self:GetDesiredProjectileValues(muzzle.aimControllerId)==nil then return false end
        end
    end
    return true
end

function HostWeapon:GetDesiredProjectileValues(id)
    local speed,gravity,target=SCOFaArtilleryStockGetDesiredProjectileValues(self,id)
    if not SCOFaArtilleryFatboyGauss(self) then return speed,gravity,target end
    local requested=self.scoFatboySourceMuzzleSpeeds and self.scoFatboySourceMuzzleSpeeds[id.index]
    if not speed or not requested or requested<=0 or math.abs(speed-requested)>0.00001 then
        return nil
    end
    return speed,gravity,target
end

-- Sanctuary's targeter uses collider overlap, which can admit a large target
-- while its center is beyond rangeMax. FA's Fatboy envelope is center-based.
function HostWeapon:CanShootAt(targetUnit)
    if not SCOFaArtilleryStockCanShootAt(self, targetUnit) then
        return false
    end
    if not SCOFaArtilleryFatboyGauss(self) then
        return true
    end

    local ownerPosition = self.unit:GetPosition()
    local targetPosition = targetUnit and targetUnit:GetPosition()
    local rangeMax = self.tp and self.tp.rangeMax
    if ownerPosition == nil
        or targetPosition == nil
        or type(rangeMax) ~= "number"
        or rangeMax <= 0
    then
        return false
    end
    local deltaX = targetPosition.x - ownerPosition.x
    local deltaZ = targetPosition.z - ownerPosition.z
    return deltaX * deltaX + deltaZ * deltaZ
        <= rangeMax * rangeMax + 0.000001
end

function HostWeapon:__init(aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)
    SCOFaArtilleryStockInit(self, aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)
    local contract = SCOFaArtilleryContract(self)
    if not contract then
        return
    end

    -- Supreme Commander artillery is ready to reload immediately. Its energy
    -- charge is an independent gate, concurrent with reload and target search.
    self.reloadTimer = 0
    self.scoFaArtilleryEnergyCharged = contract.firstShotRequiresCharge
        and 0 or contract.energyRequired
end

function HostWeapon:SetAimTarget(targetUnit)
    local result = SCOFaArtilleryStockSetAimTarget(self, targetUnit)
    SCO_UpdateFatboySourceMuzzleSpeed(self)
    local contract = SCOFaArtilleryContract(self)
    if not contract or not targetUnit or not contract.openingAnimation
        or self.unit.scoFaArtilleryOpened
    then
        return result
    end

    local animations = self.unit.tp.visuals and self.unit.tp.visuals.animations
    local opening = animations and animations[contract.openingAnimation]
    if not opening or type(opening.id) ~= "number" then
        error("Missing Mavor opening animation binding.", 2)
    end
    Engine.PlayAnimation(self.unit.id, opening.id, 0)
    self.unit.scoFaArtilleryOpened = true
    return result
end

local function SCOFaArtilleryUpdateEnergyCharge(weapon, contract)
    local required = contract.energyRequired
        * math.max(0, 1 + (weapon.scoFaAdjacencyEnergyAdd or 0))
    weapon.scoFaArtilleryEnergyRequiredForCharge = required
    local charged = weapon.scoFaArtilleryEnergyCharged or 0
    if charged >= required then
        return
    end
    local request = math.min(
        contract.energyDrainPerSecond * Constants.TickTimeStep,
        required - charged)
    local taken = weapon.unit.army:TakeResources("energy", request)
    weapon.scoFaArtilleryEnergyCharged = math.min(
        required, charged + math.max(taken or 0, 0))
end

function HostWeapon:Update()
    -- Ten 0.1-second Lua subtractions leave a positive rounding residue at
    -- source RateOfFire=1. Clamp only that terminal tick, not a real cooldown.
    if SCOFaArtilleryFatboyGauss(self)
        and self.currentState==WeaponState.WaitingForReload
        and self.reloadTimer>0
        and self.reloadTimer<=Constants.TickTimeStep+0.0000001 then
        self.reloadTimer=Constants.TickTimeStep
    end
    local contract = SCOFaArtilleryContract(self)
    if contract then
        SCOFaArtilleryUpdateEnergyCharge(self, contract)
    end
    local chargeBlocked = contract
        and (self.scoFaArtilleryEnergyCharged or 0) + 1e-7
            < (self.scoFaArtilleryEnergyRequiredForCharge or contract.energyRequired)
    local result = SCOFaArtilleryStockUpdate(self)
    -- Stock starts reload when it enters ShootSalvo, before the projectile is
    -- created. Keep an uncharged weapon target-ready so its cadence starts at
    -- the actual shot instead of at the beginning of the initial charge.
    if chargeBlocked and self.currentState == WeaponState.ShootSalvo then
        self.currentState = WeaponState.WaitingForTarget
        self.reloadTimer = 0
        self.salvosRemaining = 0
    end
    SCO_UpdateFatboySourceMuzzleSpeed(self)
    return result
end

function HostWeapon:UpdateProjectile(isOnTarget)
    local contract = SCOFaArtilleryContract(self)
    local wasShooting = self.currentState == WeaponState.ShootSalvo
    if SCOFaArtilleryFatboyGauss(self) and wasShooting and not self:IsWeaponOnTarget() then
        return
    end
    if contract and wasShooting
        and (self.scoFaArtilleryEnergyCharged or 0) + 1e-7
            < (self.scoFaArtilleryEnergyRequiredForCharge or contract.energyRequired)
    then
        return
    end

    local fired = false
    if contract and wasShooting then
        local muzzleGroup = self.muzzleGroups[self.currentMuzzleGroupIndex]
        local muzzle = muzzleGroup and muzzleGroup[1]
        fired = muzzle ~= nil
            and self.projectileTemplate.general.prefabID ~= nil
            and self:GetDesiredProjectileValues(muzzle.aimControllerId) ~= nil
    end
    local result = SCOFaArtilleryStockUpdateProjectile(self, isOnTarget)
    if fired then
        self.scoFaArtilleryEnergyCharged = 0
        self.scoFaArtilleryEnergyRequiredForCharge = nil
    end
    return result
end

-- Called from the surgically patched curved-projectile launch site. Retail FA
-- defines Mavor's MuzzleVelocityRandom as a Gaussian standard deviation.
function SCO_FieldFixArtilleryProjectileSpeed(weapon, desiredSpeed, muzzlePosition, targetBoneId)
    -- FA spawn0x6DD334 measures XYZ distance, then0x6DD38A normalizes the
    -- already-created projectile direction and scales it without re-aiming.
    -- Keep the horizontal-distance aim solve and this spawn law distinct.
    if SCOFaArtilleryFatboyGauss(weapon) and muzzlePosition and targetBoneId then
        local code,target=Engine.GetGlobalEntityWorldPosition(targetBoneId)
        if code==EngineErrorCode.Success and target then
            local x,y,z=target.x-muzzlePosition.x,target.y-muzzlePosition.y,target.z-muzzlePosition.z
            local distance=math.sqrt(x*x+y*y+z*z)
            return 25*math.sqrt(math.min(distance/90,1))
        end
    end
    local contract = SCOFaArtilleryContract(weapon)
    local deviation = contract and contract.muzzleVelocityRandom or 0
    if deviation <= 0 then
        return desiredSpeed
    end
    local first = math.max(math.random(), 1e-12)
    local second = math.random()
    local gaussian = math.sqrt(-2 * math.log(first))
        * math.cos(2 * math.pi * second)
    return math.max(0.01, desiredSpeed + gaussian * deviation)
end

-- Solve the source LowArc with the speed accepted by the native aim tick.
-- The host launch splice applies source spread after this correction, so
-- rebuilding the trajectory cannot erase the weapon's firing randomness.
local function SCO_FieldFixFatboyGaussLowArcDirection(
    muzzlePosition,
    targetX,
    targetY,
    targetZ,
    projectileSpeed,
    gravity)
    local deltaX = targetX - muzzlePosition.x
    local deltaY = targetY - muzzlePosition.y
    local deltaZ = targetZ - muzzlePosition.z
    local horizontalDistanceSquared = deltaX * deltaX + deltaZ * deltaZ
    if horizontalDistanceSquared <= 0.000001 then
        return nil
    end

    local horizontalDistance = math.sqrt(horizontalDistanceSquared)
    local speedSquared = projectileSpeed * projectileSpeed
    local discriminant = speedSquared * speedSquared
        - gravity * (
            gravity * horizontalDistanceSquared
            + 2 * deltaY * speedSquared)
    if discriminant < 0 then
        return nil
    end

    local lowArcTangent =
        (speedSquared - math.sqrt(discriminant))
        / (gravity * horizontalDistance)
    local lowArcCosine = 1 / math.sqrt(
        1 + lowArcTangent * lowArcTangent)
    local flightTime = horizontalDistance
        / (projectileSpeed * lowArcCosine)
    local horizontalScale = lowArcCosine / horizontalDistance
    return EngineClasses.float3(
        deltaX * horizontalScale,
        lowArcTangent * lowArcCosine,
        deltaZ * horizontalScale), flightTime
end

function SCO_FieldFixFatboyGaussFiringRotation(
    weapon,
    targetBoneId,
    muzzlePosition,
    fallbackRotation,
    desiredProjectileSpeed,
    projectileGravity)
    local unit = weapon and weapon.unit
    local template = weapon and weapon.tp
    if unit == nil
        or unit.tpId ~= "uel4511"
        or template == nil
        or (template.projectileTemplate ~= "psf401"
            and template.projectileTemplate ~= "psf0154")
    then
        return fallbackRotation
    end
    if muzzlePosition == nil
        or targetBoneId == nil
        or type(desiredProjectileSpeed) ~= "number"
        or desiredProjectileSpeed <= 0
        or projectileGravity == nil
        or type(projectileGravity.y) ~= "number"
        or projectileGravity.y >= -0.000001
        or math.abs(projectileGravity.x or 0) > 0.000001
        or math.abs(projectileGravity.z or 0) > 0.000001
    then
        return fallbackRotation
    end

    local _, targetPosition =
        Engine.GetGlobalEntityWorldPosition(targetBoneId)
    if targetPosition == nil then
        return fallbackRotation
    end

    local targetVelocityX = 0
    local targetVelocityZ = 0
    local target = weapon.targetUnit
    if target ~= nil and target.id ~= nil and target:CanMove() then
        local _, targetSpeed = Engine.GetMovementCurrentSpeed(target.id)
        local _, targetHeading = Engine.GetMovementHeadingDegrees(target.id)
        if type(targetSpeed) == "number"
            and targetSpeed ~= 0
            and type(targetHeading) == "number"
        then
            local headingRadians = math.rad(targetHeading)
            -- Movement stores displacement per simulation tick, not per second.
            targetSpeed = targetSpeed / Constants.TickTimeStep
            targetVelocityX = math.sin(headingRadians) * targetSpeed
            targetVelocityZ = math.cos(headingRadians) * targetSpeed
        end
    end

    local gravity = -projectileGravity.y
    local direction, flightTime =
        SCO_FieldFixFatboyGaussLowArcDirection(
            muzzlePosition,
            targetPosition.x,
            targetPosition.y,
            targetPosition.z,
            desiredProjectileSpeed,
            gravity)
    if direction == nil then
        return fallbackRotation
    end

    -- Three bounded refinements preserve the stock controller's moving-target
    -- intent without introducing a per-tick hook or persistent weapon state.
    if targetVelocityX ~= 0 or targetVelocityZ ~= 0 then
        for _ = 1, 3 do
            direction, flightTime =
                SCO_FieldFixFatboyGaussLowArcDirection(
                    muzzlePosition,
                    targetPosition.x + targetVelocityX * flightTime,
                    targetPosition.y,
                    targetPosition.z + targetVelocityZ * flightTime,
                    desiredProjectileSpeed,
                    gravity)
            if direction == nil then
                return fallbackRotation
            end
        end
    end

    return Engine.QuaternionLookRotationSafe(
        direction,
        EngineClasses.float3(0, 1, 0))
end

-- FA adjacency weapon consumer, composed after the UEF artillery bridge.
-- Append after the native HostWeapon class and the existing UEF artillery
-- appendix. Host-side only. No shared weapon template is mutated.
local M = {}
M.version = "1.0.0"

-- Eleven FA structures with positive Weapon.EnergyRequired. The two entries
-- marked artilleryBridge already have a charge owner in the SCOM patcher.
local sources = {
    ucs2101 = { id="UAB2303", hash="f056166ac1588ee419d833f890aefbf3db56798f05bfc914925c44a8dfc98bac", energy=1450, drain=145, projectile="pai211", reload=20, damage=575, radius=2, salvo=1 },
    ucs3001 = { id="XAB2307", hash="ea23580adb52cdaf56103f7ef9e73afa2094cb7f6032f16585a02b0fc48fed22", energy=15000, drain=7500, projectile="pai311", reload=3.125, damage=220, radius=2, salvo=1 },
    ucs3101 = { id="UAB2302", hash="8c8e58b4ea9a3b74aded12e3db0276383fe8b4db6adc2d92c703dd6bf8074999", energy=8500, drain=4250, projectile="pai311", reload=20, damage=6000, radius=4, salvo=1 },
    ues2101 = { id="UEB2303", hash="71c7238490b499fab6e2b978eea2192caa7b91659b929c163fe28602df55e90f", energy=1000, drain=100, projectile="psk201", reload=20, damage=2000, radius=3, salvo=1, artilleryBridge=true },
    ues4101 = { id="UEB2401", hash="4e0242d1113c20d75f77426b35b40713b580f08500683ac92e8d17c22e794c6a", energy=30000, drain=7500, projectile="psm401", reload=8, damage=12000, radius=7, salvo=1, artilleryBridge=true },
    ues5019 = { id="UEB2302", hash="5a53f06668e0b28f1b260a922fc08ced19351acca338cc227ae3fb245c6e5300", energy=8000, drain=4000, projectile="psf0038", reload=10, damage=5500, radius=5, salvo=1 },
    ues5042 = { id="XEB2306", hash="44010918c0950cf314a8fb013742976f0fe164f32ceeb4d0c7116d3c0b0869de", energy=50, drain=50, projectile="psf0030", reload=1, damage=175, radius=1, salvo=15 },
    ugs2101 = { id="URB2303", hash="f0f11960837abf5a856d885fcf5500a2e4cd47546752a8865f7bf22e4998cf0a", energy=1150, drain=115, projectile="pcg203", reload=20, damage=1750, radius=4, salvo=1 },
    ugs3101 = { id="URB2302", hash="0e77af840ac48c72e611750863ab7e282fed6b93d91da95e5f713768275f583c", energy=7000, drain=3500, projectile="pcg312", reload=10, damage=4600, radius=8, salvo=1 },
    uss2101 = { id="XSB2303", hash="e7476de490faacbd791b77524ef57de8b2d7c5aea761a4ffd35a4fa0094bc4f2", energy=1300, drain=130, projectile="pci211", reload=20, damage=2400, radius=3, salvo=1 },
    uss3101 = { id="XSB2302", hash="295debc2df24890246d7f94099db510562f572ccd05656b11ff8d56e3e6b4ce7", energy=7500, drain=3750, projectile="pci211", reload=10, damage=5000, radius=6, salvo=1 },
}

local function sourceFor(unit)
    if not unit or not unit.tp then return nil end
    local source = sources[unit.tpId]
    if not source then return nil end
    local additions = unit.tp.additions
    local contract = additions and additions.faSourceContract
    if source.artilleryBridge and not contract then
        contract = additions and additions.scoFaArtillery
    end
    if contract and (contract.sourceId ~= source.id
        or (contract.sourceBlueprintSha256
            and contract.sourceBlueprintSha256 ~= source.hash)
        or (contract.targetId and contract.targetId ~= unit.tpId)) then
        return nil
    end
    return source
end

local function weaponFor(weapon)
    local unit = weapon and weapon.unit
    local source = sourceFor(unit)
    if not source or not weapon.tp then return nil end
    if not unit.tp.weapons or #unit.tp.weapons ~= 1
        or not unit.GetWeaponCount or unit:GetWeaponCount() ~= 1
        or unit.tp.weapons[1] ~= weapon.tp then return nil end
    local template = weapon.tp
    if template.projectileTemplate ~= source.projectile
        or math.abs((template.reloadTime or -1) - source.reload) > 1e-6
        or template.damage ~= source.damage
        or template.damageRadius ~= source.radius
        or (template.muzzleSalvoSize or 1) ~= source.salvo
        or (template.name and template.name ~= "MainGun") then return nil end
    local index = template.scoFaSourceWeaponIndex
    if index ~= nil and index ~= 1 then return nil end
    local sourceWeapon = weapon.tp.scoFaSourceWeapon
    if sourceWeapon then
        if sourceWeapon.Label ~= "MainGun"
            or sourceWeapon.EnergyRequired ~= source.energy
            or sourceWeapon.EnergyDrainPerSecond ~= source.drain then
            return nil
        end
    else
        -- Older roster templates carry only the FA label and reload facts, or
        -- no live source contract. The exact mapped template tuple above is
        -- required in every case.
        local contract = unit.tp.additions and unit.tp.additions.faSourceContract
        local fact = contract and contract.weapons and contract.weapons[1]
        if fact and (fact.label ~= "MainGun"
            or math.abs((fact.reloadTime or -1) - source.reload) > 1e-6) then
            return nil
        end
    end
    if index == nil and unit.GetWeapon and unit:GetWeapon(1) ~= weapon then
        return nil
    end
    return source
end

local function energyFactor(weapon)
    return math.max(0, 1 + (weapon.scoFaAdjacencyEnergyAdd or 0))
end

function M.WeaponUsesEnergy(unit)
    if not sourceFor(unit) or not unit.GetWeaponCount then return false end
    for i=1, unit:GetWeaponCount() do
        if weaponFor(unit:GetWeapon(i)) then return true end
    end
    return false
end

function M.UpdateWeapons(unit, affect, oldAdd, newAdd)
    if affect ~= "EnergyWeapon" and affect ~= "RateOfFire" then return end
    if not sourceFor(unit) or not unit.GetWeaponCount then return end
    for i=1, unit:GetWeaponCount() do
        local weapon = unit:GetWeapon(i)
        if weaponFor(weapon) then
            if affect == "EnergyWeapon" then
                weapon.scoFaAdjacencyEnergyAdd = newAdd
            else
                -- FA computes ROF = blueprint ROF / (1 + adjacency add).
                weapon.scoFaAdjacencyReloadFactor = math.max(0, 1 + newAdd)
            end
        end
    end
end

local function ensureCharge(weapon, source)
    local required = source.energy * energyFactor(weapon)
    weapon.scoFaEnergyRequiredForCharge = required
    local charged = weapon.scoFaEnergyCharged or 0
    if charged + 1e-7 >= required then return true end
    local request = math.min(source.drain * Constants.TickTimeStep, required - charged)
    local taken = weapon.unit.army:TakeResources("energy", request)
    weapon.scoFaEnergyCharged = math.min(required, charged + math.max(0, taken or 0))
    return weapon.scoFaEnergyCharged + 1e-7 >= required
end

function M.Install(HostWeapon, WeaponState)
    if HostWeapon.scoFaAdjacencyWeaponsInstalled then return end
    HostWeapon.scoFaAdjacencyWeaponsInstalled = true
    local previousUpdate = HostWeapon.Update
    local previousUpdateProjectile = HostWeapon.UpdateProjectile
    local previousAdvanceSalvoState = HostWeapon.AdvanceSalvoState

    function HostWeapon:Update()
        local source = weaponFor(self)
        local blocked = source and not source.artilleryBridge
            and not ensureCharge(self, source)
        local result = previousUpdate(self)
        if blocked and self.currentState == WeaponState.ShootSalvo then
            -- Stock starts reload before projectile creation. Stay target-ready
            -- until the FA energy charge is complete.
            self.currentState = WeaponState.WaitingForTarget
            self.reloadTimer = 0
            self.salvosRemaining = 0
        end
        return result
    end

    function HostWeapon:UpdateProjectile(isOnTarget)
        local source = weaponFor(self)
        if source and not source.artilleryBridge
            and self.currentState == WeaponState.ShootSalvo then
            if (self.scoFaEnergyCharged or 0) + 1e-7
                < (self.scoFaEnergyRequiredForCharge or source.energy) then
                return
            end
            local group = self.muzzleGroups[self.currentMuzzleGroupIndex]
            local prefab = self.projectileTemplate
                and self.projectileTemplate.general
                and self.projectileTemplate.general.prefabID
            if group and prefab then
                for _, muzzle in ipairs(group) do
                    if self:GetDesiredProjectileValues(muzzle.aimControllerId) then
                        self.scoFaFiredDuringSalvo = true
                        break
                    end
                end
            end
        end
        return previousUpdateProjectile(self, isOnTarget)
    end

    function HostWeapon:AdvanceSalvoState()
        local source = weaponFor(self)
        local result = previousAdvanceSalvoState(self)
        if source and self.currentState == WeaponState.WaitingForReload then
            if not source.artilleryBridge and self.scoFaFiredDuringSalvo then
                -- One charge per whole rack salvo, including the 15-round
                -- XEB2306 burst. The existing UEF bridge owns its two charges.
                self.scoFaEnergyCharged = nil
                self.scoFaEnergyRequiredForCharge = nil
            end
            self.scoFaFiredDuringSalvo = nil
            local factor = self.scoFaAdjacencyReloadFactor
            if factor and self.tp.reloadTime then
                self.reloadTimer = math.max(Constants.TickTimeStep,
                    self.tp.reloadTime * factor)
            end
        end
        return result
    end
end

function M.Export(HostWeapon, WeaponState)
    M.Install(HostWeapon, WeaponState)
    _G.SCO_FA_AdjacencyWeaponAPI = M
    return M
end

M.Export(HostWeapon, WeaponState)
-- SCOM tactical stock-weapon exclusion 1.0.0
do
    if not HostWeapon.scoTacticalUpdateInstalled then
        local previous = HostWeapon.Update
        function HostWeapon:Update(...)
            if self.tp and self.tp.scoTacticalOwned == true then return end
            return previous(self, ...)
        end
        HostWeapon.scoTacticalUpdateInstalled = true
    end
end
-- SCOM source weapon runtime installation 1.0.0
Import('common/systems/scoSourceWeaponRuntime.lua').InstallWeapon(HostWeapon,WeaponState)
Import('common/systems/scoSourceSpecialWeapons.lua').InstallWeapon(HostWeapon)
Import('common/systems/scoSourceContinuousBeams.lua').InstallWeapon(HostWeapon,WeaponState)
Import('common/systems/scoSourceProjectileMotion.lua').InstallWeapon(HostWeapon)
Import('common/systems/scoSourceUnitModes.lua').InstallWeapon(HostWeapon,WeaponState)
Import('common/systems/scoSourceDynamicVisuals.lua').InstallWeapon(HostWeapon,WeaponState)
Import('common/systems/scoTorpedoWeapons.lua').InstallWeapon(HostWeapon,WeaponState)

-- GCol direct beams may use two consecutive confirmed world poses while the
-- native on-target bit is false. Keep the native fast path and authored cones.
do
    local previousWeaponOnTarget = HostWeapon.IsWeaponOnTarget
    local previousMuzzleOnTarget = HostWeapon.IsMuzzleOnTarget
    local previousRefreshEnabled = HostWeapon.RefreshEnabled
    local previousSetAimTarget = HostWeapon.SetAimTarget
    local previousDelete = HostWeapon.Delete
    local specifications = {
        EyeWeapon = {1, "Head_Muzzle", "Head", "Head_Muzzle", 0.05},
        RightArmTractor = {2, "Right_Arm_Muzzle01", "Right_Arm_B01", "Right_Arm_B02", 5},
        LeftArmTractor = {3, "Left_Arm_Muzzle01", "Left_Arm_B01", "Left_Arm_B02", 5},
    }

    local function configuration(weapon)
        local owner, tp = weapon.unit, weapon.tp
        local spec = tp and specifications[tp.scoSourceLabel]
        local aim = tp and tp.aimControllers and tp.aimControllers[1]
        if not spec or not aim or not owner or owner.tpId ~= "ucl4004"
            or not owner.tp or owner.tp.weapons[spec[1]] ~= tp
            or #weapon.aimControllerIds ~= 1 or #tp.aimControllers ~= 1
            or aim.aimBone ~= spec[2] or aim.yawBone ~= spec[3]
            or aim.pitchBone ~= spec[4] or aim.aimTolerance ~= spec[5]
            or aim.solverType ~= "NoArc" or aim.leadTarget ~= false then
            return nil
        end
        return aim
    end

    local function confirmedWorldAim(weapon, controller, aim)
        local owner, target = weapon.unit, weapon.targetUnit
        local function reject()
            weapon.scoColossusAimConfirmation = nil
            return false
        end
        if not weapon.enabled or not scoTractorIsCurrent(owner)
            or not scoTractorIsCurrent(target)
            or target.canTakeDamage == false or target.canBeKilled == false
            or not owner.army:IsEnemy(target.army)
            or not weapon:CanShootAt(target) then return reject() end
        local code, enabled = Engine.GetAimControllerEnabled(controller)
        if code ~= EngineErrorCode.Success or not enabled then return reject() end
        local state
        code, state = Engine.GetAimControllerState(controller)
        if code ~= EngineErrorCode.Success or state ~= AimControllerState.Aiming then return reject() end
        local targetID
        code, targetID = Engine.GetAimControllerTarget(controller)
        if code ~= EngineErrorCode.Success or not Engine.IsValidGlobalID(targetID) then return reject() end
        local rootID
        code, rootID = Engine.GetGlobalEntityRoot(targetID)
        if code ~= EngineErrorCode.Success or rootID.index ~= target.id.index
            or rootID.version ~= target.id.version then return reject() end
        local origin, forward, position
        code, origin = Engine.GetGlobalEntityWorldPosition(controller)
        if code ~= EngineErrorCode.Success then return reject() end
        code, forward = Engine.GetGlobalEntityForwardDirection(controller)
        if code ~= EngineErrorCode.Success then return reject() end
        code, position = Engine.GetGlobalEntityWorldPosition(targetID)
        if code ~= EngineErrorCode.Success then return reject() end
        local x, y, z = position.x-origin.x, position.y-origin.y, position.z-origin.z
        local distanceSquared = x*x+y*y+z*z
        local forwardSquared = forward.x*forward.x+forward.y*forward.y+forward.z*forward.z
        if not (forwardSquared > 0 and forwardSquared < math.huge
            and distanceSquared >= 0 and distanceSquared < math.huge) then return reject() end
        if distanceSquared > 0 then
            local dot = (x*forward.x+y*forward.y+z*forward.z)
                / math.sqrt(distanceSquared*forwardSquared)
            if not (dot > math.cos(math.rad(aim.aimTolerance))) then return reject() end
        elseif distanceSquared ~= 0 then return reject() end

        local previous = weapon.scoColossusAimConfirmation
        local sameTarget = previous and previous.target == target
            and previous.ownerVersion == owner.id.version
            and previous.targetUnitVersion == target.id.version
            and previous.controllerIndex == controller.index
            and previous.controllerVersion == controller.version
            and previous.targetIndex == targetID.index
            and previous.targetVersion == targetID.version
        local confirmed = sameTarget and (previous.tick == Tick and previous.confirmed
            or previous.tick == Tick-1) or false
        weapon.scoColossusAimConfirmation = {
            target = target, ownerVersion = owner.id.version,
            targetUnitVersion = target.id.version,
            controllerIndex = controller.index, controllerVersion = controller.version,
            targetIndex = targetID.index, targetVersion = targetID.version,
            tick = Tick, confirmed = confirmed,
        }
        if confirmed and not weapon.scoColossusAimConfirmationLogged then
            weapon.scoColossusAimConfirmationLogged = true
            Log("[SCOM] Confirmed Galactic Colossus " .. weapon.tp.scoSourceLabel
                .. " aim from stable world geometry while the native flag was false.")
        end
        return confirmed
    end

    function HostWeapon:RefreshEnabled(...)
        local wasEnabled = self.enabled
        local result = previousRefreshEnabled(self, ...)
        if configuration(self) and (not self.enabled or self.enabled ~= wasEnabled) then
            self.scoColossusAimConfirmation = nil
        end
        return result
    end

    function HostWeapon:SetAimTarget(target, ...)
        if target ~= self.targetUnit and configuration(self) then
            self.scoColossusAimConfirmation = nil
        end
        return previousSetAimTarget(self, target, ...)
    end

    function HostWeapon:Delete(...)
        self.scoColossusAimConfirmation = nil
        return previousDelete(self, ...)
    end

    function HostWeapon:IsWeaponOnTarget()
        local native = previousWeaponOnTarget(self)
        local aim = configuration(self)
        if native or not aim then
            self.scoColossusAimConfirmation = nil
            return native
        end
        local id = self.aimControllerIds[1]
        local code, onTarget = Engine.GetAimControllerIsOnTarget(id)
        if code ~= EngineErrorCode.Success or onTarget then
            self.scoColossusAimConfirmation = nil
            return false
        end
        return confirmedWorldAim(self, id, aim)
    end

    function HostWeapon:IsMuzzleOnTarget(muzzle)
        local native = previousMuzzleOnTarget(self, muzzle)
        local aim = configuration(self)
        if native or not aim then
            self.scoColossusAimConfirmation = nil
            return native
        end
        local id = muzzle.aimControllerId
        local expected = self.aimControllerIds[1]
        if not id or id.index ~= expected.index or id.version ~= expected.version then
            self.scoColossusAimConfirmation = nil
            return false
        end
        local code, onTarget = Engine.GetAimControllerIsOnTarget(id)
        if code ~= EngineErrorCode.Success or onTarget then
            self.scoColossusAimConfirmation = nil
            return false
        end
        return confirmedWorldAim(self, id, aim)
    end
end

-- SCOM manual ACU Overcharge 1.0.0
Import('common/systems/scoOvercharge.lua').InstallWeapon(HostWeapon, WeaponState)
