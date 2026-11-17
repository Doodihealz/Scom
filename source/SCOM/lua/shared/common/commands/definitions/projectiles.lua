-- Host-to-client projectile lifecycle and muzzle firing.

local Registry = Import("common/commands/registry.lua")
local Layouts  = Import("common/commands/layouts.lua")
local IntelBitMask = Import("common/intelBitMask.lua").IntelBitMask

local UnitsUpdate = nil
local ProjectileUpdate = nil
if IsClient then
    UnitsUpdate = Import("client/units/unitsUpdate.lua")
    ProjectileUpdate = Import("client/projectiles/projectilesUpdate.lua")
end

--== Projectiles ===============================================================

---@class CreateProjectile : Command
CreateProjectile = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "projectileGlobalID", type = Layouts.GlobalID },
    { key = "armyID",             type = "int" },
})

---@param projectileGlobalID GlobalID
---@param armyID ArmyId
function CreateProjectile.Send(projectileGlobalID, armyID)
    return { projectileGlobalID = projectileGlobalID, armyID = armyID }
end

function CreateProjectile.Receive(data)
    local _, localID = Engine.GetGlobalEntityPairedLocalID(data.projectileGlobalID)
    local _, prefabID = Engine.GetGlobalEntityPrefabID(data.projectileGlobalID)

    ProjectileUpdate.CreateProjectile(data.projectileGlobalID, localID, prefabID, data.armyID)
end

---@class DestroyProjectile : Command
DestroyProjectile = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "projectileGlobalID",   type = Layouts.GlobalID },
    { key = "projectileImpactTime", type = "float" },
    { key = "hitGlobalID",          type = Layouts.GlobalID },
    { key = "detectionMask",        type = "int" },
    { key = "hasImpactPosition",    type = "bool" },
    { key = "impactPosition",       type = Layouts.Float3 },
    { key = "impactBone",           type = "string" },
    { key = "impactBonePosition",   type = Layouts.Float3 },
})

---@param projectileGlobalID GlobalID
---@param projectileImpactTime number
---@param hitGlobalID GlobalID
---@param detectionMask integer
function DestroyProjectile.Send(projectileGlobalID, projectileImpactTime, hitGlobalID, detectionMask, impactPosition, impactBone, impactBonePosition)
    return {
        projectileGlobalID   = projectileGlobalID,
        projectileImpactTime = projectileImpactTime,
        hitGlobalID          = hitGlobalID,
        detectionMask        = detectionMask,
        hasImpactPosition    = impactPosition ~= nil,
        impactPosition       = impactPosition or { x = 0, y = 0, z = 0 },
        impactBone           = impactBone or "",
        impactBonePosition   = impactBonePosition or { x = 0, y = 0, z = 0 },
    }
end

function DestroyProjectile.Receive(data)
    local localID = {}
    Engine.GetGlobalEntityPairedLocalID(data.projectileGlobalID, localID)

    -- TODO: Pass in proper rotation / normal...
    ProjectileUpdate.DestroyProjectile(data.projectileGlobalID, localID, data.projectileImpactTime,
        GetIdentityQuaternion(), data.hitGlobalID, IntelBitMask.new(data.detectionMask),
        data.hasImpactPosition and data.impactPosition or nil, data.impactBone, data.impactBonePosition)
end

---@class DeleteProjectile : Command
DeleteProjectile = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "projectileGlobalID", type = Layouts.GlobalID },
})

---@param projectileGlobalID GlobalID
function DeleteProjectile.Send(projectileGlobalID)
    return { projectileGlobalID = projectileGlobalID }
end

function DeleteProjectile.Receive(data)
    ProjectileUpdate.DeleteProjectile(data.projectileGlobalID)
end

--== Muzzles ===================================================================

---@class FireMuzzle : Command
FireMuzzle = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "muzzleGlobalID", type = Layouts.GlobalID },
})

---@param muzzleGlobalID GlobalID
function FireMuzzle.Send(muzzleGlobalID)
    return { muzzleGlobalID = muzzleGlobalID }
end

function FireMuzzle.Receive(data)
    UnitsUpdate.FireMuzzle(data.muzzleGlobalID)
end

---@class SetMuzzleFiring : Command
SetMuzzleFiring = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "muzzleID", type = Layouts.GlobalID },
    { key = "enabled",  type = "bool" },
})

---@param muzzleID GlobalID
---@param enabled boolean
function SetMuzzleFiring.Send(muzzleID, enabled)
    return { muzzleID = muzzleID, enabled = enabled }
end

function SetMuzzleFiring.Receive(data)
    local muzzle = __Muzzles[data.muzzleID.index]
    if muzzle then
        muzzle:SetFiring(data.enabled)
    end
end
