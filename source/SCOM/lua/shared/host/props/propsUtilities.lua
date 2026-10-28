local PropCommands = Import("common/commands/definitions/props.lua")

local Props = __Entities.Props

function _G.CreateProp(tpId, position, orientation, unitId)
    local propClass = GetClass(tpId, "Props")
    local propTemplate = GetTemplate(tpId, "Props")

    local propId = {}
    local errorCode = Engine.InstantiatePrefab(propTemplate.general.prefabID, position, EngineClasses.float3(1.0, 1.0, 1.0), orientation, propId)

    if errorCode ~= EngineErrorCode.Success then
        Warn(string.format("Engine.InstantiatePrefab() failed! Unable to create prop! errorCode: %d", errorCode))
        return
    end

    local prop = propClass(propId, propTemplate)
    Props[prop.id.index] = prop

    -- Wrecks copy the hierarchy of the unit.
    if unitId then
        Engine.CopyHierarchy(unitId, propId)
        PropCommands.CreateProp.Send(unitId, propId)
    end

    return prop
end

function _G.CreateWreckage(tpId, position, orientation)
    return CreateProp(tpId, position, orientation)
end

function _G.CreateWreckageFromUnit(unit)
    --if not unit or unit.entityType ~= "unit" or unit.dead then
    if not unit then
        Error("CreateWreckageFromUnit: Invalid unit.", 2)
    elseif unit.entityType ~= "unit" then
        Error("CreateWreckageFromUnit: Provided type is not a unit.", 2)
    elseif unit.deleted then
        Error("CreateWreckageFromUnit: Unit is already deleted.", 2)
    end

    local wreckageTpId = unit.tpId.."_Wreckage"

    return CreateProp(wreckageTpId, unit:GetPosition(), unit:GetOrientation(), unit.id)
end

function _G.RemoveProp(prop)
    if not Props[prop.id.index] then
        Error("RemoveProp: Prop is not in the global table. id: "..prop.id.index.. " tpId: "..prop.tpId)
    end

    --Log(string.format("RemoveProp: id: %d, tpId: %s, name: %s", prop.id, prop.tpId, prop.name))

    Props[prop.id.index] = nil
end
-- SCOM source aircraft crash registration 1.0.0
local sourceCrash = Import('common/systems/scoMissingCrash.lua')
sourceCrash.Configure(Import('common/systems/scoMissingCrashRegistry.lua'))
CreateWreckageFromUnit = sourceCrash.WrapCreateWreckage(CreateWreckageFromUnit)
