local Projectiles = __Entities.Projectiles

local xpcall = xpcall
local ErrorHandler = ErrorHandler

local GetTemplateId = GetTemplateId
local GetTemplate = GetTemplate

---Registers a new projectile on the client
---@param globalId globalId GlobalID of the projectile
---@param localId localId LocalID of the projectile
---@param prefabID PrefabID PrefabID of the projectile
---@param armyId integer Army index of the projectile 
local function registerProjectile(globalId, localId, prefabID, armyId)
    local tpId = GetTemplateId(prefabID, "Projectiles")
    --local projectileClass = GetClass(tpId, "Projectiles")
    local projectileClass = Import("client/projectiles/projectilesClasses/projectilesBaseClass.lua").ClientProjectile
    local projectileTemplate = GetTemplate(tpId, "Projectiles")

    local projectile = projectileClass(globalId, localId, armyId, projectileTemplate)
    -- Save the unit into the global table
    Projectiles[globalId.index] = projectile

    --Log(string.format("Client: RegisterProjectile: globalId: %d, localId: %d, armyId: %d, engine id: %d, tpId: %s", globalId, localId, armyId, tpEngineId, tpId))
end

---Destroys the projectile, used for triggering projectile hit effects.
---@param globalId globalId Global ID of the projectile
---@param localId localId Local ID of the projectile
---@param impactTime number The time from the start of this tick the projectile should be destroyed.
---@param orientation any Projectile orientation
---@param hitGlobalId GlobalID The entity that was hit, invalid when the projectile hit the terrain.
---@param detectionMask IntelBitMask The armies which could see the projectile, deciding who gets its impact effects.
local function destroyProjectile(globalId, localId, impactTime, orientation, hitGlobalId, detectionMask, impactPosition, impactBone, impactBonePosition)
    local projectile = GetEntityById(globalId, "Projectiles")
    if not projectile then
        Warn("Client Destroy projectile: Trying to destroy non existant projectile: " .. globalId)
        return
    end

    projectile:UpdateIntelVisionDetection(detectionMask)

    --Log(string.format("Client: DestroyProjectile: globalId: %d, localId: %d, position: %s, orientation: %s", globalId, localId, position, orientation))

    projectile:Destroy(impactTime, orientation, hitGlobalId, impactPosition, impactBone, impactBonePosition)
end

---@param globalId globalId Global ID of the projectile
---@param detectionMask IntelBitMask The armies which can currently see the projectile.
local function updateProjectileIntel(globalId, detectionMask)
    local projectile = GetEntityById(globalId, "Projectiles")
    if not projectile then
        Warn("Client UpdateProjectileIntel: Trying to update non existant projectile: " .. globalId)
        return
    end

    projectile:UpdateIntelVisionDetection(detectionMask)
end

---Deletes the projectile
---@param globalId globalId Global ID of the projectile
local function removeProjectile(globalId)
    local projectile = GetEntityById(globalId, "Projectiles")
    if not projectile then
        Warn("Client Remove projectile: Trying to remove non existant projectile: " .. globalId)
        return
    end

    projectile:Delete()

    --Log(string.format("Client: Removeprojectile: id: %d, army: %d, tpId: %s", projectile.id, projectile.armyId, projectile.tpId))

    Projectiles[globalId.index] = nil
end

-- Will eventually be called by custom commands...
---Destroys the client unit. Calls `Destroy` method on the unit.
function CreateProjectile(projectileGlobalID, localID, prefabID, armyID)
    xpcall(registerProjectile, ErrorHandler, projectileGlobalID, localID, prefabID, armyID)
end

---Destroys the client unit. Calls `Destroy` method on the unit.
function DestroyProjectile(projectileGlobalID, localID, impactTime, orientation, hitGlobalID, detectionMask, impactPosition, impactBone, impactBonePosition)
    xpcall(destroyProjectile, ErrorHandler, projectileGlobalID, localID, impactTime, orientation, hitGlobalID, detectionMask, impactPosition, impactBone, impactBonePosition)
end

---Destroys the client unit. Calls `Destroy` method on the unit.
function DeleteProjectile(projectileGlobalID)
    xpcall(removeProjectile, ErrorHandler, projectileGlobalID)
end

function UpdateProjectileIntel(projectileGlobalID, detectionMask)
    xpcall(updateProjectileIntel, ErrorHandler, projectileGlobalID, detectionMask)
end