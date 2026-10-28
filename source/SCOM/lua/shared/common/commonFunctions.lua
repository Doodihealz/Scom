local pairs, type = pairs, type
local Warn, Error = Warn, Error
local Import = Import

local Classes = __Classes
local Entities = __Entities
local Templates = __Templates
local PrefabIDs = __PrefabIDs
local Units = __Entities.Units
local Props = __Entities.Props
local Projectiles = __Entities.Projectiles

---Returns a template for given tpId
---@param tpId TemplateId tpId
---@param tpType? EntityType Entity type or nil
---@return Template tp Entity template
function _G.GetTemplate(tpId, tpType)
    local tp = nil

    if tpType then
        if not Templates[tpType] then
            Error("GetTemplate: Template type: " .. tpType .. " doesn't exist.", 2)
        end
        tp = Templates[tpType][tpId]
    else
        for _, templates in pairs(Templates) do
            tp = templates[tpId]
            if tp then
                break
            end
        end
    end

    if not tp then
        Error("GetTemplate: Template: "..tpId.." doesn't exist.", 2)
    end

    return tp
end

---Returns tpId for given prefabId
---@param prefabId PrefabID
---@param tpType? EntityType
---@return TemplateId
function _G.GetTemplateId(prefabId, tpType)
    local tpId = nil

    if tpType then
        if not PrefabIDs[tpType] then
            Error("GetTemplateId: Template type: " .. tpType .. " doesn't exist.", 2)
        end
        tpId = PrefabIDs[tpType][prefabId.Value]

        if not tpId then
            Error("GetTemplateId: Template type: " .. tpType.. " with engine ID: ".. prefabId.Value .." doesn't exist.", 2)
        end

    else
        for _, templates in pairs(PrefabIDs) do
            tpId = templates[prefabId.Value]
            if tpId then
                break
            end
        end
        
        if not tpId then
            Error("GetTemplateId: Template with engine ID: ".. prefabId.Value .." doesn't exist.", 2)
        end
    end

    return tpId
end

---Returns an entity class associated with tpId
---@param tpId TemplateId
---@param classType? EntityType
---@return any
function _G.GetClass(tpId, classType)
    local classData = nil
    if classType then
        if not Classes[classType] then
            Error("GetClass: Class type: " .. classType .. " doesn't exist.", 2)
        end
        classData = Classes[classType][tpId]
    else
        for cType, classes in pairs(Classes) do
            classType = cType
            classData = classes[tpId]
            if classData then
                break
            end
        end
    end

    if not classData then
        Error("GetClass: Entity class: "..tpId.." doesn't exist.", 2)
    end

    local class
    local cType = string.lower(classType)
    if cType == "units" and Import("scom/units/index.lua").Units[tpId] then
        local realm = IsHost and "host" or "client"
        local module = Import("scom/units/" .. tpId .. "/" .. realm .. ".lua")
        return assert(module.UnitClass, "SCOM unit class is missing: " .. tpId .. "/" .. realm)
    end
    if IsHost then
        class = Import(string.format("host/%s/%sClasses/%s.lua", cType, cType, classData[1]))["Host"..classData[2]]
    else
        class = Import(string.format("client/%s/%sClasses/%s.lua", cType, cType, classData[1]))["Client"..classData[2]]
    end

    return class
end

---Returns entity with given id. Units should always use GlobalIDs
---@param originalID GlobalID
---@param entityType EntityType|nil
---@return any
function _G.GetEntityById(originalID, entityType)
    local id = originalID.index

    local entity = nil

    if entityType then
        if not Entities[entityType] then
            Error("GetEntityById: Entity type: " .. entityType .. " doesn't exist.", 2)
        end
        entity = Entities[entityType][id]
    else
        for _, entities in pairs(Entities) do
            entity = entities[id]
            if entity then
                break
            end
        end
    end

    if not entity then
        Warn("GetEntityById: Entity: " .. id .. " doesn't exist.", 2)
        return
    end

    return entity
end

---Returns array of entities with given ids.
---@param entityIds GlobalID[] Array of IDs.
---@param entityType EntityType
---@return any
function _G.GetEntitiesByIds(entityIds, entityType)
    local entities = {}

    for _, id in pairs(entityIds) do
        local entity = GetEntityById(id, entityType)
        if entity then
            table.insert(entities, entity)
        end
    end
end

---Returns a unit with this ID or `nil`
---@param originalID GlobalID - Unique ID of the unit.
---@return Unit?
function _G.GetUnitById(originalID)
    local id = originalID.index

    local unit = Units[id]
    if not unit or unit.id.version ~= originalID.version then
        return -- Don't log warning, as units missing on the host is normal/expected behaviour due to latency
    end
    return unit
end

---Returns a prop with this ID or `nil`
---@param originalID GlobalID - Unique ID of the prop.
---@return Prop?
function _G.GetPropById(originalID)
    local id = originalID.index

    local prop = Props[id]
    if not prop or prop.id.version ~= originalID.version then
        return
    end
    return prop
end

---Returns a projectile with this ID or `nil`
---@param originalID GlobalID - Unique ID of the projectile.
---@return Projectile?
function _G.GetProjectileByID(originalID)
    local id = originalID.index
    local projectile = Projectiles[id]
    if not projectile then
        Warn("GetProjectileByID: projectile with id: "..id.." doesn't exist.", 2)
        return
    end
    return projectile
end

-- Returns a Unit or Prop for a given GlobalID
---@param originalID GlobalID - Unique ID of the entity.
---@return Unit|Prop?
function _G.GetUnitOrPropByGlobalId(originalID)
    local id = originalID.index
    -- check unit
    local unit = Units[id]
    if unit and unit.id.version == originalID.version then
        return unit
    end
    -- check prop
    local prop = Props[id]
    if prop and prop.id.version == originalID.version then
        return prop
    end
    -- units/props missing
    return
end

---Returns a table of units with these IDs.
---@param unitsIDs GlobalID[] of unit IDs.
---@return Unit[]
function _G.GetUnitsByIDs(unitsIDs)
    local units = {}
    for _, id in pairs(unitsIDs) do
        local unit = GetUnitById(id)
        if unit then
            table.insert(units, unit)
        end
    end

    return units
end

---Retruns a table with global ids of given units
---@param units Unit[]
---@return GlobalID[]
function _G.GetUnitIds(units)
    local ids = {}

    for _, unit in pairs(units) do
        table.insert(ids, unit.id)
    end

    return ids
end
