local UnitCommands = Import("common/commands/definitions/units.lua")
local PlacementUtils = Import("common/systems/placementUtils.lua")
local PlacementDomain = Import("common/layers.lua").PlacementDomain

local Armies = Armies
local Units = __Entities.Units
local Shields = __Entities.Shields
local GetClass = GetClass

-- SCO_SeraphimMovementRegistry
-- Native movement owns land, seabed, hover, and air altitude. Register only
-- ships/submarines whose authored root needs an explicit waterline or depth.
local SCO_SeraphimMovementUnits = {}
_G.SCO_SeraphimMovementUnits = SCO_SeraphimMovementUnits

local function SCO_RegisterSeraphimMovementUnit(unit, unitTemplate)
    local tags = unitTemplate and unitTemplate.tags or {}
    if not table.find(tags, "SERAPHIM") or not table.find(tags, "MOBILE") then
        return
    end

    local movement = unitTemplate.movement
    local movementType = movement and movement.type
    local general = unitTemplate.general
    local waterlineOffset = general and general.waterlineOffset
    local submergeDepth = general and general.submergeDepth
    if movementType ~= "WaterSurface"
        and movementType ~= "UnderWater"
    then
        return
    end
    if (movementType == "WaterSurface" and waterlineOffset == nil)
        or (movementType == "UnderWater" and submergeDepth == nil)
    then
        return
    end

    SCO_SeraphimMovementUnits[unit.id.index] = {
        unit = unit,
        position = EngineClasses.float3(),
        movementType = movementType,
        waterlineOffset = waterlineOffset,
        submergeDepth = submergeDepth,
    }
end

local function SCO_UnregisterSeraphimMovementUnit(unit)
    local id = unit and unit.id
    if id then
        SCO_SeraphimMovementUnits[id.index] = nil
    end
end

---Creates a new unit
---@param armyId ArmyId ID of the army the unit will belong to
---@param tpId TemplateId Template ID to spawn, e.g. `"uel1001"`
---@param position float3 Position to spawn at
---@param orientation? quaternion Initial orientation of the unit
---@param progress? number 0.0 - 1.0, 1 for finished unit
---@return HostUnit unit New instance of unit class
function _G.CreateUnit(armyId, tpId, position, orientation, progress)
    orientation = orientation or GetIdentityQuaternion()
    progress = progress or 1.0

    local army = GetArmy(armyId)
    local unitClass = GetClass(tpId, "Units")
    local unitTemplate = GetTemplate(tpId, "Units")

    if PlacementUtils.GetPlacementDomain(unitTemplate) == PlacementDomain.Water or position.y == 0 then
        position = {
            x = position.x,
            y = PlacementUtils.GetPlacementHeight(unitTemplate, position.x, position.z),
            z = position.z,
        }
    end
    
    local globalId = {}

    local errorCode = Engine.InstantiatePrefab(unitTemplate.general.prefabID, position, EngineClasses.float3(1.0, 1.0, 1.0), orientation, globalId)

    if errorCode ~= EngineErrorCode.Success then
        Error(string.format("CreateUnit: Engine failed to create unit: army: %d, tpId: %s, pos: %s, o: %s, errorCode: %d", armyId, tpId, position, orientation, errorCode))
    end

    UnitCommands.CreateUnit.Send(globalId, progress, armyId)

    local unit = unitClass(globalId, armyId, unitTemplate, progress)
    -- Save the unit into the global table
    Units[unit.id.index] = unit
    army:AddUnit(unit)
    SCO_RegisterSeraphimMovementUnit(unit, unitTemplate)

    return unit
end

---comment
---@param unit HostUnit
function _G.RemoveUnit(unit)
    SCO_UnregisterSeraphimMovementUnit(unit)
    if not Units[unit.id.index] then
        Warn("RemoveUnit: Unit with id: " .. (unit.id.index or "UNKNOWN id") .. " doesn't exist.")
        return
    end
    Units[unit.id.index] = nil

    if unit.army then
        unit.army:RemoveUnit(unit)
    else
        Warn("RemoveUnit: Removing unit "..unit.tpId.." for nonexisting Lua army, index: "..unit.army.id)
    end
end

--- Register a shield which is on a unit.
---@param armyId ArmyId
---@param shieldTp ShieldInfo
---@param ownerUnit HostUnit
---@param shieldId GlobalID
---@return HostShield
function _G.CreateShield(armyId, shieldTp, ownerUnit, shieldId)
    -- if not shieldId then
    --     -- TODO: Creating shields without units. Would use some sort of shield prefab.
    -- end

    local army =  Armies[armyId]
    if not army then
        Error("CreateUnit: Creating shield for entity " .. ownerUnit.id .. " for nonexisting Lua army, index: " .. armyId)
    end

    local shield = Import("host/shield.lua").HostShield(shieldId, army, ownerUnit, shieldTp)

    Shields[shieldId.index] = shield

    return shield
end

---@param shield HostShield
function _G.RemoveShield(shield)
    if not Shields[shield.id.index] then
        Warn("RemoveShield: Shield with id: " .. (shield.id or "UNKNOWN id") .. " doesn't exist.")
        return
    end
    Shields[shield.id.index] = nil
end

-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0
