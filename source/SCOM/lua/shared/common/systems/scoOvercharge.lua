-- Manual ACU Overcharge. The primary cannon keeps sole ownership of its bones.
local M = {}
local Version = "1.0.0"
local EnergyCost, Damage, Radius, Speed = 5000, 12000, 2.5, 25
local Cooldown = 1 / 0.3
local AimTimeout = 10
local Profiles = {
    uel0000 = { sourceId = "UEL0001", projectile = "pocuef", upgrade = "HeavyAntiMatterCannon", range = 30 },
    ucl0000 = { sourceId = "UAL0001", projectile = "pocaeon", upgrade = "CrysalisBeam", range = 35 },
    ugl0000 = { sourceId = "URL0001", projectile = "poccybran", upgrade = "CoolingUpgrade", range = 30 },
    usl0000 = { sourceId = "XSL0001", projectile = "pocsera", upgrade = "RateOfFire", range = 30, minimum = 2 },
}
local Layers = Import("common/layers.lua").TargetingLayer
local Lobby = Import("common/lobby.lua")
local bit = require("bit")

local function finite(value)
    return type(value) == "number" and value == value
        and value ~= math.huge and value ~= -math.huge
end

local function validId(id)
    return type(id) == "table" and finite(id.index) and finite(id.version)
        and id.index == math.floor(id.index) and id.version == math.floor(id.version)
        and id.index >= 1 and id.index <= 2147483647
        and id.version >= 0 and id.version <= 2147483647
end

local function sameId(left, right)
    return validId(left) and validId(right)
        and left.index == right.index and left.version == right.version
end

local function now()
    return GetGameTimeSeconds()
end

local function ownerId(unit)
    local player = unit.army and Lobby.ArmyToPlayer[unit.army.id]
    return player and player.clientID
end

local function current(unit)
    return unit and not unit.dead and not unit.deleted and validId(unit.id)
        and GetUnitById(unit.id) == unit
end

local function configuration(unit)
    local profile = unit and Profiles[unit.tpId]
    local additions = unit and unit.tp and unit.tp.additions
    local contract = additions and additions.scoOvercharge
    if not profile or type(contract) ~= "table" or contract.version ~= Version
        or contract.projectileTemplate ~= profile.projectile then return nil end
    local index = additions.scoCommanderEnhancementBaseWeaponIndex
    local weapon = unit.weapons and unit.weapons[index or 1]
    if not weapon or weapon.unit ~= unit or not weapon.tp then return nil end
    return profile, weapon
end

local function stateFor(unit)
    local state = unit.scoOvercharge
    if not state then
        state = { version = Version, cooldownUntil = 0 }
        unit.scoOvercharge = state
    elseif state.version ~= Version then
        error("SCOM Overcharge state version mismatch")
    end
    return state
end

local function rangeFor(unit, profile)
    local enhancements = unit.scoCommanderEnhancements
    local installed = enhancements and enhancements.installed
    return installed and installed[profile.upgrade] == true and profile.range or 22
end

local function surfaceLayer(layer)
    return type(layer) == "number"
        and bit.band(layer, Layers.Land + Layers.WaterSurface) ~= 0
        and bit.band(layer, Layers.Air + Layers.Water + Layers.Seabed) == 0
end

local function economyFor(unit)
    return unit.army and unit.army.economy
end

local function readiness(unit, state, weapon)
    if not current(unit) then return false, "unit-dead" end
    if state.restoring or state.restoreFailed then return false, "runtime-unavailable" end
    if not unit:IsCompleted() then return false, "under-construction" end
    if not weapon.enabled or not surfaceLayer(weapon:GetFiringLayer()) then
        return false, "weapon-unavailable"
    end
    if state.pending then return false, "aiming" end
    if now() + 0.000001 < state.cooldownUntil then return false, "cooldown" end
    local enhancements, abilities = unit.scoCommanderEnhancements, unit.scoCommanderAbilities
    if enhancements and enhancements.active then return false, "enhancement-busy" end
    if abilities and (abilities.teleport or abilities.missileLaunch) then return false, "ability-busy" end
    if unit.unitBeingBuilt or unit.unitBeingCaptured or unit.unitBeingReclaimed
        or unit.unitBeingRepaired or unit.dashBehaviorIsActive then return false, "unit-busy" end
    local economy = economyFor(unit)
    if not economy or economy:GetResourceStored("energy") < EnergyCost then
        return false, "energy"
    end
    return true
end

function M.Snapshot(unit)
    local profile, weapon = configuration(unit)
    if not profile then return nil end
    local state = stateFor(unit)
    local ready, reason = readiness(unit, state, weapon)
    return {
        version = Version, available = true, ready = ready, reason = reason,
        energyCost = EnergyCost, cooldownDuration = Cooldown,
        cooldownRemaining = math.max(0, state.cooldownUntil - now()),
        active = state.pending ~= nil, rangeMax = rangeFor(unit, profile),
    }
end

local function emit(unit)
    local enhancements = unit.scoCommanderEnhancements
    if enhancements then enhancements.revision = ((enhancements.revision or 0) + 1) % 2147483648 end
    local getter, sender = _G.SCO_CommanderEnhancementHostGetState, _G.SCO_CommanderEnhancementEmitState
    local clientID = ownerId(unit)
    if type(getter) == "function" and type(sender) == "function" and clientID ~= nil then
        local ok, failure = pcall(function()
            local snapshot = getter(clientID, unit.id)
            if snapshot then sender(clientID, snapshot) end
        end)
        if not ok then Warn("SCOM Overcharge state publication failed: " .. tostring(failure)) end
    end
end

local function requireSuccess(code, operation)
    if code ~= EngineErrorCode.Success then error("SCOM Overcharge " .. operation .. ": " .. tostring(code)) end
end

local function validateTarget(unit, weapon, profile, target)
    if not current(target) or not surfaceLayer(target.targetingLayer)
        or not weapon:CanShootAt(target) then return false, "invalid-target" end
    local origin, destination = unit:GetPosition(), target:GetPosition()
    if not origin or not destination or not finite(origin.x) or not finite(origin.z)
        or not finite(destination.x) or not finite(destination.z) then return false, "invalid-position" end
    local dx, dz = destination.x - origin.x, destination.z - origin.z
    local distance = math.sqrt(dx * dx + dz * dz)
    if distance + 0.000001 < (profile.minimum or 0)
        or distance > rangeFor(unit, profile) + 0.000001 then return false, "out-of-range" end
    return true
end

local function validateOwner(clientID, unitId)
    if not finite(clientID) or clientID < 0 or clientID > 2147483647
        or clientID ~= math.floor(clientID) or not validId(unitId) then return nil, "invalid-request" end
    local unit = GetUnitById(unitId)
    if not current(unit) or not sameId(unit.id, unitId) then return nil, "unit-not-found" end
    if ownerId(unit) ~= clientID then return nil, "not-owner" end
    local profile, weapon = configuration(unit)
    if not profile then return nil, "overcharge-unavailable" end
    return unit, stateFor(unit), profile, weapon
end

local function restoreAim(unit, pending)
    local weapon = pending.weapon
    local restored = true
    local function attempt(action)
        local ok, failure = pcall(action)
        if not ok then
            restored = false
            if not pending.restoreWarning then
                pending.restoreWarning = true
                Warn("SCOM Overcharge aim restoration failed: " .. tostring(failure))
            end
        end
    end
    for _, saved in ipairs(pending.controllers) do
        attempt(function()
            requireSuccess(Engine.SetAimControllerProjectileSpeed(saved.id, saved.speed), "restore aim speed")
        end)
        attempt(function()
            requireSuccess(Engine.SetAimControllerAimGravity(saved.id, saved.gravity), "restore aim gravity")
        end)
        attempt(function()
            requireSuccess(Engine.SetAimControllerControllerType(saved.id, saved.solver), "restore aim solver")
        end)
        attempt(function()
            requireSuccess(Engine.SetAimControllerLeadTarget(saved.id, saved.leading), "restore aim leading")
        end)
    end
    attempt(function() weapon:SetMuzzlesFiring(false) end)
    if not unit.dead and not unit.deleted then
        attempt(function()
            local target = pending.previousTarget
            if not current(target) or not weapon:CanShootAt(target) or not weapon:IsTargetInRange(target) then target = nil end
            weapon:SetAimTarget(target)
            if weapon.enabled then weapon:RequestRetarget() end
        end)
    end
    return restored
end

function M.Cancel(unit)
    local state = unit and unit.scoOvercharge
    local pending = state and state.pending
    if not pending then return false end
    state.pending = nil
    if not restoreAim(unit, pending) and current(unit) then
        pending.restoreAttempts = 0
        state.restoring = pending
    end
    return true
end

function M.CancelForOrders(unit)
    if M.Cancel(unit) then emit(unit) end
end

function M.Request(clientID, unitId, targetId)
    local unit, state, profile, weapon = validateOwner(clientID, unitId)
    if not unit then return false, state end
    local ready, reason = readiness(unit, state, weapon)
    if not ready then return false, reason end
    if not validId(targetId) then return false, "invalid-target" end
    local target = GetUnitById(targetId)
    if not sameId(target and target.id, targetId) then return false, "invalid-target" end
    local valid, rejection = validateTarget(unit, weapon, profile, target)
    if not valid then return false, rejection end
    if #weapon.muzzleGroups ~= 1 or #weapon.muzzleGroups[1] ~= 1 then return false, "muzzle-layout" end
    local pending = {
        clientID = clientID, target = target, targetId = { index = targetId.index, version = targetId.version },
        weapon = weapon, previousTarget = weapon.targetUnit, controllers = {},
        acceptedAt = now(), deadline = now() + AimTimeout,
    }
    -- Snapshot every controller before mutating any, so setup failure is reversible.
    for _, id in ipairs(weapon.aimControllerIds) do
        local code, speed = Engine.GetAimControllerProjectileSpeed(id)
        if code ~= EngineErrorCode.Success or not finite(speed) then return false, "aim-unavailable" end
        local gravityCode, gravity = Engine.GetAimControllerAimGravity(id)
        local solverCode, solver = Engine.GetAimControllerControllerType(id)
        local leadingCode, leading = Engine.GetAimControllerLeadTarget(id)
        if gravityCode ~= EngineErrorCode.Success or not gravity
            or not finite(gravity.x) or not finite(gravity.y) or not finite(gravity.z)
            or solverCode ~= EngineErrorCode.Success or leadingCode ~= EngineErrorCode.Success then
            return false, "aim-unavailable"
        end
        pending.controllers[#pending.controllers + 1] = {
            id = id, speed = speed, gravity = EngineClasses.float3(gravity.x, gravity.y, gravity.z),
            solver = solver, leading = leading,
        }
    end
    if #pending.controllers == 0 then return false, "aim-unavailable" end
    state.pending = pending
    local ok, failure = pcall(function()
        weapon:SetMuzzlesFiring(false)
        for _, saved in ipairs(pending.controllers) do
            requireSuccess(Engine.SetAimControllerProjectileSpeed(saved.id, Speed), "set aim speed")
            requireSuccess(Engine.SetAimControllerAimGravity(saved.id, EngineClasses.float3(0, 0, 0)), "set aim gravity")
            requireSuccess(Engine.SetAimControllerControllerType(saved.id, BallisticType.None), "set aim solver")
            requireSuccess(Engine.SetAimControllerLeadTarget(saved.id, false), "set aim leading")
        end
        weapon:SetAimTarget(target)
    end)
    if not ok then
        M.Cancel(unit)
        Warn(tostring(failure))
        return false, "aim-unavailable"
    end
    emit(unit)
    return true
end

local function spawn(unit, profile, pending)
    local weapon = pending.weapon
    local template = __Templates.Projectiles[profile.projectile]
    local provenance = template and template.additions and template.additions.scoOvercharge
    if not template or not template.general or not template.general.prefabID
        or not provenance or provenance.version ~= Version or provenance.sourceId ~= profile.sourceId then
        return false, "projectile-unavailable"
    end
    local muzzle = weapon.muzzleGroups[1][1]
    local code, aligned = Engine.GetAimControllerIsOnTarget(muzzle.aimControllerId)
    if code ~= EngineErrorCode.Success or aligned ~= true then return false, "aiming" end
    local speed, gravity, targetBone = weapon:GetDesiredProjectileValues(muzzle.aimControllerId)
    if not finite(speed) or speed <= 0 or not gravity or not validId(targetBone) then return false, "aiming" end
    local rootCode, rootId = Engine.GetGlobalEntityRoot(targetBone)
    if rootCode ~= EngineErrorCode.Success or not sameId(rootId, pending.targetId) then return false, "aiming" end
    local positionCode, position = Engine.GetGlobalEntityWorldPosition(muzzle.id)
    local rotationCode, rotation = Engine.GetGlobalEntityWorldRotation(muzzle.id)
    if positionCode ~= EngineErrorCode.Success or rotationCode ~= EngineErrorCode.Success
        or not position or not rotation or not finite(position.x)
        or not finite(position.y) or not finite(position.z) then return false, "muzzle-unavailable" end
    local commands = Import("common/commands/definitions/projectiles.lua")
    local economy = economyFor(unit)
    if economy:GetResourceStored("energy") < EnergyCost then return false, "energy" end
    -- The simulation cannot yield between this debit, spawn, and compensation.
    local paid = economy:TakeResources("energy", EnergyCost)
    if paid ~= EnergyCost then
        if paid > 0 then economy:GiveResources("energy", paid) end
        return false, "energy"
    end
    local projectile, projectileId, announced
    local ok, failure = pcall(function()
        local result
        result, projectileId = Engine.InstantiatePrefab(template.general.prefabID, position,
            EngineClasses.float3(1, 1, 1), rotation)
        requireSuccess(result, "instantiate projectile")
        if not validId(projectileId) or not Engine.IsValidGlobalID(projectileId) then error("SCOM Overcharge invalid projectile") end
        local waterCode, waterCollider = Engine.GetGlobalBone(projectileId, "WaterCollider")
        requireSuccess(waterCode, "water collider")
        if not validId(waterCollider) then error("SCOM Overcharge water collider unavailable") end
        requireSuccess(Engine.SetRayColliderEventsEnabled(waterCollider, true), "water collision events")
        local movement = template.movement or {}
        if movement.type == "Homing" or movement.type == "TargetEntity" or movement.type == "LeadTargetEntity" then
            requireSuccess(Engine.SetHomingProjectileTargetID(projectileId, targetBone), "homing target")
            requireSuccess(Engine.SetHomingProjectileTargetType(projectileId, HomingType.TargetGlobalID), "homing mode")
            local velocity = math3D.scale(Engine.QuaternionRotateVector(rotation, EngineClasses.float3(0, 0, 1)), speed)
            requireSuccess(Engine.SetHomingProjectileVelocity(projectileId, velocity), "homing velocity")
        elseif movement.type == nil then
            requireSuccess(Engine.SetCurvedProjectileSpeed(projectileId, speed), "projectile speed")
        else
            error("SCOM Overcharge unsupported projectile motion")
        end
        requireSuccess(Engine.SetProjectileGravity(projectileId,
            math3D.scale(gravity, movement.gravityMultiplier or 0)), "projectile gravity")
        commands.CreateProjectile.Send(projectileId, unit.army.id)
        announced = true
        local HostProjectile = Import("host/projectiles/projectilesClasses/projectilesBaseClass.lua").HostProjectile
        projectile = HostProjectile(projectileId, unit.army.id, template, Damage, Radius,
            math.max(1, 2 * rangeFor(unit, profile) / Speed), muzzle.id, unit)
        projectile.damageFriendly = false
        projectile.scoOvercharge = { version = Version, sourceId = profile.sourceId }
        __Entities.Projectiles[projectileId.index] = projectile
        commands.FireMuzzle.Send(muzzle.id)
    end)
    if not ok then
        local deleted = projectile and pcall(projectile.Delete, projectile)
        if not deleted and validId(projectileId) then
            __Entities.Projectiles[projectileId.index] = nil
            if announced then pcall(commands.DeleteProjectile.Send, projectileId) end
            pcall(Engine.DeletePrefabInstance, projectileId, false)
        end
        economy:GiveResources("energy", paid)
        Warn("SCOM Overcharge launch failed: " .. tostring(failure))
        return false, "spawn-failed"
    end
    return true
end

function M.UpdateWeapon(weapon, WeaponState)
    local unit = weapon.unit
    local profile, primary = configuration(unit)
    if not profile or primary ~= weapon then return false end
    local state = stateFor(unit)
    if state.restoring then
        local restoring = state.restoring
        restoring.restoreAttempts = restoring.restoreAttempts + 1
        if restoreAim(unit, restoring) then
            state.restoring = nil
            emit(unit)
        elseif restoring.restoreAttempts >= 10 then
            state.restoring = nil
            state.restoreFailed = true
            Warn("SCOM Overcharge primary cannon held after repeated aim restoration failure")
            emit(unit)
        end
        return true
    end
    if state.restoreFailed then return true end
    local pending = state.pending
    if not pending then
        local ready, reason = readiness(unit, state, weapon)
        local signature = tostring(ready) .. ":" .. tostring(reason) .. ":" .. tostring(rangeFor(unit, profile))
        if state.lastReadiness ~= signature then state.lastReadiness = signature; emit(unit) end
        return false
    end
    weapon.reloadTimer = math.max(0, weapon.reloadTimer - Constants.TickTimeStep)
    local authentic = current(unit) and ownerId(unit) == pending.clientID
        and current(pending.target) and sameId(pending.target.id, pending.targetId)
    -- Reuse the readiness predicate without exposing a second owner of pending state.
    state.pending = nil
    local ready = readiness(unit, state, weapon)
    state.pending = pending
    local valid = authentic and ready and validateTarget(unit, weapon, profile, pending.target)
    if not valid or now() > pending.deadline then
        M.Cancel(unit); emit(unit); return true
    end
    -- Native on-target is cached. A new request must survive a simulation tick.
    if now() <= pending.acceptedAt then return true end
    local fired, reason = spawn(unit, profile, pending)
    if not fired and reason == "aiming" then return true end
    if fired then
        state.cooldownUntil = now() + Cooldown
        weapon.reloadTimer = math.max(weapon.reloadTimer, weapon.tp.reloadTime or 0)
        weapon.currentState = WeaponState.WaitingForReload
    end
    M.Cancel(unit)
    emit(unit)
    return true
end

function M.InstallWeapon(HostWeapon, WeaponState)
    if HostWeapon.scoOverchargeInstalled then
        if HostWeapon.scoOverchargeInstalled ~= Version then error("SCOM Overcharge weapon version mismatch") end
        return
    end
    local update, setTarget, delete = HostWeapon.Update, HostWeapon.SetAimTarget, HostWeapon.Delete
    function HostWeapon:Update(...)
        local profile, primary = configuration(self.unit)
        if not profile or primary ~= self then return update(self, ...) end
        local ok, handled = pcall(M.UpdateWeapon, self, WeaponState)
        if not ok then
            M.Cancel(self.unit)
            Warn("SCOM Overcharge update failed: " .. tostring(handled))
            return
        end
        if handled then return end
        return update(self, ...)
    end
    function HostWeapon:SetAimTarget(target, ...)
        local state = self.unit.scoOvercharge
        local pending = state and state.pending
        if pending and pending.weapon == self and target ~= pending.target then return end
        return setTarget(self, target, ...)
    end
    function HostWeapon:Delete(...)
        local state = self.unit.scoOvercharge
        if state and state.pending and state.pending.weapon == self then M.Cancel(self.unit) end
        if state then state.restoring = nil end
        return delete(self, ...)
    end
    HostWeapon.scoOverchargeInstalled = Version
end

function M.InstallHost(HostCommander)
    if HostCommander.scoOverchargeInstalled then
        if HostCommander.scoOverchargeInstalled ~= Version then error("SCOM Overcharge host version mismatch") end
        return
    end
    if _G.SCO_CommanderAbilityHostOvercharge ~= nil then error("SCOM Overcharge host export is occupied") end
    _G.SCO_CommanderAbilityHostOvercharge = M.Request
    local getState = assert(_G.SCO_CommanderEnhancementHostGetState)
    _G.SCO_CommanderEnhancementHostGetState = function(clientID, unitId)
        local snapshot, reason = getState(clientID, unitId)
        if snapshot then
            local unit = GetUnitById(unitId)
            if unit and ownerId(unit) == clientID then
                local overcharge = M.Snapshot(unit)
                if overcharge then snapshot.abilities = snapshot.abilities or {}; snapshot.abilities.overcharge = overcharge end
            end
        end
        return snapshot, reason
    end
    for _, name in ipairs({ "SCO_CommanderAbilityHostCancel", "SCO_CommanderEnhancementHostCancel" }) do
        local previous = assert(_G[name])
        _G[name] = function(clientID, unitId)
            local unit = validateOwner(clientID, unitId)
            if unit and M.Cancel(unit) then emit(unit); return true end
            return previous(clientID, unitId)
        end
    end
    for _, name in ipairs({ "SCO_CommanderEnhancementHostStart", "SCO_CommanderEnhancementHostRemove" }) do
        local previous = assert(_G[name])
        _G[name] = function(clientID, unitId, ...)
            local unit = validateOwner(clientID, unitId)
            local state = unit and unit.scoOvercharge
            if state and (state.pending or state.restoring or state.restoreFailed) then return false, "ability-busy" end
            return previous(clientID, unitId, ...)
        end
    end
    local destroy = HostCommander.OnDestroy
    function HostCommander:OnDestroy(...)
        M.Cancel(self)
        return destroy(self, ...)
    end
    local transfer = assert(_G.SCO_CommanderEnhancementHostTransfer)
    _G.SCO_CommanderEnhancementHostTransfer = function(source, destination)
        local cooldownUntil = source.scoOvercharge and source.scoOvercharge.cooldownUntil
        local transferred = transfer(source, destination)
        if transferred then
            M.Cancel(source)
            if configuration(destination) then
                M.Cancel(destination)
                stateFor(destination).cooldownUntil = cooldownUntil or 0
            end
        end
        return transferred
    end
    HostCommander.scoOverchargeInstalled = Version
end

local environment = type(getfenv) == "function" and getfenv(1) or _ENV
for name, value in pairs(M) do environment[name] = value end
return M
