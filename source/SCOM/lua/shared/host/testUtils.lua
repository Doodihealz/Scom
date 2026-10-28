local MapUtils = Import("common/mapUtils.lua")
local PlacementUtils = Import("common/systems/placementUtils.lua")

-- Helper function
local function getAverageUnitsPositionXZ(units)
    local x, z = 0, 0

    for _, unit in pairs(units) do
        local pos = unit:GetPosition()
        x = x + pos.x
        z = z + pos.z
    end

    local numUnits = #units
    x = x / numUnits
    z = z / numUnits

    return x, z
end

---@class BufferedUnit
---@field army ArmyId
---@field tpId TemplateId
---@field relativePos { x: number, z: number } Offset from the average position of the copied group
---@field orientation quaternion

---@type BufferedUnit[]
local bufferedUnits = {}

function CopySelectedUnits(unitIds)
    Log("Test Utilities: CopySelectedUnits with IDs:\n"..repr(unitIds))

    local units = GetUnitsByIDs(unitIds)
    if not units[1] then
        return
    end

    local x, z = getAverageUnitsPositionXZ(units)

    bufferedUnits = {}
    for _, unit in pairs(units) do
        local pos = unit:GetPosition()
        bufferedUnits[#bufferedUnits + 1] = {
            army        = unit.army.id,
            tpId        = unit.tpId,
            relativePos = { x = pos.x - x, z = pos.z - z },
            orientation = unit:GetOrientation(),
        }
    end
end

local mousePos = {}
local function createUnitAtMouse(army, tpId, unitRelativePos, orientation)
    local position = EngineClasses.float3(mousePos.x + unitRelativePos.x, 0, mousePos.z + unitRelativePos.z)
    if string.sub(tpId, 3, 3) == "s" then
        position = RoundIntoGrid(position)
    end

    if not MapUtils.IsPositionOnMap(position) then
        return
    end

    --Log(string.format("createUnitAtMouse: %d, %s, %s, %s", army, tpId, position, ))
    CreateUnit(army, tpId, position, orientation)
end

function PasteBufferedUnits(position)
    mousePos = position
    Log("PasteBufferedUnits at position: "..repr(position))

    for _, unit in ipairs(bufferedUnits) do
        createUnitAtMouse(unit.army, unit.tpId, unit.relativePos, unit.orientation)
    end
end

function DestroyUnitsByIds(unitIds)
    Log("Test Utilities: Destroying units with IDs:\n"..repr(unitIds))

    local units = GetUnitsByIDs(unitIds)
    for _, unit in pairs(units) do
        if not unit.dead then
            unit:Destroy()
        end
    end
end

function DeleteUnitsByIds(unitIds)
    Log("Test Utilities: Deleting units with IDs:\n"..repr(unitIds))

    local units = GetUnitsByIDs(unitIds)
    for _, unit in pairs(units) do
        if not unit.deleted then
            unit:Delete()
        end
    end
end

function GetSpiralGridXZ(n)
    local k = math.ceil((math.sqrt(n) - 1) / 2)
    local t = 2 * k + 1
    local m = t ^ 2
    t = t - 1

    if n >= m - t then
        return k - (m - n) , -k
    else
        m = m - t
    end

    if n >= m - t then
        return -k, -k + (m - n)
    else
        m = m - t
    end

    if n >= m - t then
        return -k + (m - n), k
    else
        return k, k - (m - n - t)
    end
end

-- @param data {
--     engineTpId = number,
--     armyId = number,
--     count = number,
--     position = float3,
-- }
function SpawnUnits(data)
    local tp = GetTemplate(data.engineTpId, "Units")
    local position = EngineClasses.float3(data.position.x, data.position.y, data.position.z)

    local footprint = tp.skirtSize or tp.footprint

    if string.sub(data.engineTpId, 3, 3) == "s" then
        position = RoundIntoGrid(position)
    end

    -- Spawn the desired amount of units in a spiral with proper spacing based on unit's footprint
    for i = 1, data.count do
        local spiralX, spiralZ = GetSpiralGridXZ(i)
        local x = position.x + (footprint.x * spiralX)
        local z = position.z + (footprint.y * spiralZ)

        local newPositon = EngineClasses.float3(x, 0, z)

        if MapUtils.IsPositionOnMap(newPositon) then
            CreateUnit(data.armyId, data.engineTpId, newPositon)
        end
    end
end

-- Teleports units to given position.
-- Keeps the spacing among the units
function TeleportUnits(unitIds, position)
    Log("Test Utilities: Teleporting units to position: "..repr(position)..", units IDs:\n"..repr(unitIds))

    local units = GetUnitsByIDs(unitIds)
    if not units[1] then
        return
    end

    local x, z = getAverageUnitsPositionXZ(units)

    for _, unit in pairs(units) do
        local pos = unit:GetPosition()
        local newPosition = EngineClasses.float3(position.x + pos.x - x, position.y, position.z + pos.z - z)

        if unit:HasTags(Tags.STRUCTURE) then
            newPosition = RoundIntoGrid(newPosition)
            newPosition.y = PlacementUtils.GetPlacementHeight(unit.tp, newPosition.x, newPosition.z)
        end
        if MapUtils.IsPositionOnMap(newPosition) then
            unit:SetPosition(newPosition)
        end
    end
end

--- Converts the list of unit IDs into a json data that can be saved in the map file.
function PrintSelectedUnitsAsJSONMapData(unitIds)
    local units = GetUnitsByIDs(unitIds)
    local name = "Unit_"
    local i = 1
    local data = {
        Army_1_PDs = {
            units = {},
            groups = {},
        },
    }
    local jUnits = data.Army_1_PDs.units
    for _, unit in pairs(units) do
        local pos = unit:GetPosition()
        if unit:HasTags(Tags.STRUCTURE) then
            pos = RoundIntoGrid(pos)
        end
        jUnits[name..i] = {
            type = "Unit",
            tpId = unit.tpId,
            position = {
                x = pos.x,
                y = 0,
                z = pos.z,
            },
            rotation = {
                x = 0.0,
                y = 0.0,
                z = 0.0,
                w = 0.0,
            },
            scale = {
                x = 0.0,
                y = 0.0,
                z = 0.0,
            },
        }
        i = i + 1
    end

    Log(json.encode(data))
    Log("Last id: "..i)
end

---Prints all extractors on map as a alloy spot data for the json map filee
function PrintExtractorsAsJSONMarkerData(mirror)
    local units = GetListOfUnits(nil, Tags.ALLOYS_EXTRACTION)
    local name = "Alloys_"
    local i = 1

    local data = {}

    for _, unit in pairs(units) do
        local pos = unit:GetPosition()
        if unit:HasTags(Tags.STRUCTURE) then
            pos = RoundIntoGrid(pos)
        end
        data[name..i] = {
            position = {
                x = pos.x,
                y = math.round(pos.y, 6),
                z = pos.z,
            },
            rotation = {
                x = 0.0,
                y = 0.0,
                z = 0.0,
                w = 1.0,
            },
            scale = {
                x = 0.0,
                y = 0.0,
                z = 0.0,
            },
        }
        i = i + 1

        if mirror then
            local mPos = Import("common/mapUtils.lua").MirrorPostion(pos)
            data[name..i] = {
                position = {
                    x = mPos.x,
                    y = math.round(mPos.y, 6),
                    z = mPos.z,
                },
                rotation = {
                    x = 0.0,
                    y = 0.0,
                    z = 0.0,
                    w = 1.0,
                },
                scale = {
                    x = 0.0,
                    y = 0.0,
                    z = 0.0,
                },
            }
            i = i + 1
        end
    end

    Log(json.encode(data))
    Log("Last id: "..i)
end

-- Debug unit groups
-- Custom group of units saved for from the UI, map specific.
local DebugUnitGroupsFilePath = false
local DebugUnitGroups = {
    groups = {},
    nextUnitId = 1,
    nextGroupId = 1,
}

local function convertUnitsForMapData(units, groupName)
    units = GetUnitsByIDs(units)

    if not (units and units[1]) then
        Warn("convertUnitsForMapData: No units provided.")
        return {}
    end

    -- Override the name to default, if the name is not valid.
    if type(groupName) ~= "string" then
        groupName = "Group_" .. DebugUnitGroups.nextGroupId

        DebugUnitGroups.nextGroupId = DebugUnitGroups.nextGroupId + 1
    end

    -- basic structure for the new group
    local data = {
        [groupName] = {
            units = {},
            groups = {},
        },
    }

    local groupToInsert = data[groupName].units
    local unitName = "Unit_"
    local i = DebugUnitGroups.nextUnitId

    for _, unit in pairs(units) do
        local pos = unit:GetPosition()
        if unit:HasTags(Tags.STRUCTURE) then
            pos = RoundIntoGrid(pos)
        end
        local rotation = unit:GetOrientation()
        groupToInsert[unitName..i] = {
            type = "Unit",
            tpId = unit.tpId,
            position = {
                x = pos.x,
                y = math.round(pos.y, 6),
                z = pos.z,
            },
            rotation = {
                x = math.round(rotation.value.x, 6),
                y = math.round(rotation.value.y, 6),
                z = math.round(rotation.value.z, 6),
                w = math.round(rotation.value.w, 6),
            },
            scale = {
                x = 0.0,
                y = 0.0,
                z = 0.0,
            },
        }
        i = i + 1
    end

    DebugUnitGroups.nextUnitId = i

    return data
end

local function saveDebugUnitGroupToDisc()
    --Log("Debug unit group: file saved: "..DebugUnitGroupsFilePath.."\n"..repr(DebugUnitGroups))
    table.save(DebugUnitGroups, DebugUnitGroupsFilePath, "MapData = ")
end

function LoadDebugUnitGroups()
    local mapName = Import("common/mapUtils.lua").GetMapDataName()
    if not mapName then
        Warn("Debug unit group: Loading failed, no map name.")
        return false
    end

    local mapPath = string.format("/maps/%s/%s_data.lua", mapName, mapName)
    DebugUnitGroupsFilePath = libPath..mapPath
    Log("Debug unit group: setting path: "..DebugUnitGroupsFilePath)

    if not Engine.FileExists(DebugUnitGroupsFilePath) then
        --Warn("Debug unit group: No data found for map: "..mapName)
        return false
    end

    local mapData = Import(mapPath).MapData
    if mapData then
        DebugUnitGroups = mapData

        --Log("Debug unit group: new data loaded.")

        local groups = {}
        for name, data in pairs(DebugUnitGroups.groups) do
            table.insert(groups, name)
        end
        table.sort(groups, function(a, b) return a > b end)

        SendGroupNamesToUI(groups)
    end

    return true
end

function SendGroupNamesToUI(tblNames)
    SendToAllClients(tblNames, "DebugUIAddUnitGroups")
end

function GetDebugUnitGroup(name)
    return DebugUnitGroups.groups[name]
end

function SaveDebugUnitGroup(unitIds, name)
    local data = convertUnitsForMapData(unitIds, name)

    for k, v in pairs(data) do
        if not DebugUnitGroups.groups[k] then
            DebugUnitGroups.groups[k] = v

            SendGroupNamesToUI({k})
            Log("Debug unit group: Group added: "..name)
            saveDebugUnitGroupToDisc()
        else
            Warn("Debug unit group: Can't save group that already exists: "..name)
            return
        end
    end
end

function UpdateDebugUnitGroup(unitIds, name)
    local data = convertUnitsForMapData(unitIds, name)

    for k, v in pairs(data) do
        if not DebugUnitGroups.groups[k] then
            Warn("Debug unit group: Can't update group that doesn't exist: " .. name)
            return
        else
            DebugUnitGroups.groups[k] = v

            Log("Debug unit group: Group updated: "..name)
            saveDebugUnitGroupToDisc()
        end
    end
end

function DeleteDebugUnitGroup(name)
    if DebugUnitGroups.groups[name] then
        DebugUnitGroups.groups[name] = nil
        Log("Debug unit group: Group deleted: ".. name)
    else
        Warn("Debug unit group: Can't delete group that doesn't exist: "..name)
        return
    end

    saveDebugUnitGroupToDisc()
end

function SpawnDebugUnitGroup(army, name)
    local group = GetDebugUnitGroup(name)
    if not group then
        --Warn("Debug unit group: Group not found: " .. name)
        return
    end

    local result = {}

    for name, data in pairs(group.units) do
        local unit = CreateUnit(army or 1, data.tpId, EngineClasses.float3(data.position.x, data.position.y, data.position.z))
        table.insert(result, unit)
    end

    return result
    --Log("Debug unit group: group spawned, army: " .. army .. ", name: " .. name)
end

-- Highlight structures skirts
local function structureHighlightSkirt(unit)
    if not unit:HasTags(Tags.STRUCTURE) then
        return
    end

    local colour = EngineClasses.float4(0, 1, 0, 1)

    while not unit.dead do
        local pos = unit:GetPosition()
        local skirtSize = unit.tp.skirtSize

        local min = EngineClasses.float3(pos.x - (skirtSize.x / 2), pos.y, pos.z - (skirtSize.y / 2))
        local max = EngineClasses.float3(pos.x + (skirtSize.x / 2), pos.y, pos.z + (skirtSize.y / 2))

        Engine.DrawBox(min, max, colour)
        WaitTicks(1)
    end
end

local skirtsEnabled = false
-- Hook CreateUnit function to enable skirts on newly spawned units
local oldCreateUnit = CreateUnit
function ToggleHighlightSkirts()
    skirtsEnabled = not skirtsEnabled
    if skirtsEnabled then
        _G.CreateUnit = function(...)
            local unit = oldCreateUnit(...)
            unit.skirtHighlightThread = unit:NewThread(structureHighlightSkirt)
            return unit
        end
    else
        _G.CreateUnit = oldCreateUnit
    end

    local units = FilterUnitsByTags(__Entities.Units, Tags.STRUCTURE)
    for _, unit in pairs(units) do
        if skirtsEnabled and not unit.skirtHighlightThread then
            unit.skirtHighlightThread = unit:NewThread(structureHighlightSkirt)
        elseif not skirtsEnabled and unit.skirtHighlightThread then
            unit.skirtHighlightThread:Delete()
            unit.skirtHighlightThread = nil
        end
    end
end

-- Spawn and resave all units groups with new pos/rotation data.
function ResaveAllGroups()
    NewThread(function()
        Log("Resaving all map groups")
        LoadDebugUnitGroups()

        for name, group in pairs(DebugUnitGroups.groups) do
            Log(name)
            local units = SpawnDebugUnitGroup(1, name)
            WaitSeconds(0.2)

            DeleteDebugUnitGroup(name)
            WaitSeconds(0.2)

            SaveDebugUnitGroup(units, name) 
            WaitSeconds(0.2)

            for _, v in pairs(units) do
                v:Delete()
            end
            WaitSeconds(0.2)
        end
        Log("All groups resaved!")
    end)
end

-- Spawn all available units
function SpawnAllUnits()
    Import("host/debug/spawnAllUnits.lua").SpawnAllUnits()
end

function ToggleBigBattle()
    Import("host/debug/battleTest.lua").ToggleBattleThread()
end

function StartShowcase()
    Import("maps/showcase_script.lua").Start()
end
-- SCOM Field Fix: scoped Creative/TestUtilities spawn context 1.0.1
local SCOFieldFixCreativeSpawnBridgeEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOFieldFixCreativeSpawnBridgeMarker = rawget(
    SCOFieldFixCreativeSpawnBridgeEnvironment,
    "SCO_FieldFixCreativeSpawnBridgeInstalled")
if SCOFieldFixCreativeSpawnBridgeMarker ~= nil
    and SCOFieldFixCreativeSpawnBridgeMarker ~= "1.0.1"
then
    error("Unsupported SCOM Creative spawn bridge marker "
        .. tostring(SCOFieldFixCreativeSpawnBridgeMarker))
end
if SCOFieldFixCreativeSpawnBridgeMarker == nil then
    if type(SpawnUnits) ~= "function" then
        error("SCOM Creative spawn bridge could not resolve TestUtilities.SpawnUnits")
    end

    local SCOFieldFixCreativeSpawnUnits = SpawnUnits

    function SpawnUnits(data)
        -- Sanctuary Creative Mode exposes this stock TestUtilities entry point.
        -- Publish a narrowly scoped host marker while its CreateUnit calls run;
        -- strategic-silo initialization consumes the marker synchronously.
        local previousContext = _G.SCO_FieldFixCreativeSpawnContext
        _G.SCO_FieldFixCreativeSpawnContext = "1.0.0"
        if type(Log) == "function"
            and type(data) == "table"
            and data.engineTpId == "ucs3102"
        then
            Log("[SCOM Strategic Silo] Creative SpawnUnits entry: "
                .. "tp=ucs3102 context=1.0.0")
        end
        local ok, result = pcall(SCOFieldFixCreativeSpawnUnits, data)
        _G.SCO_FieldFixCreativeSpawnContext = previousContext
        if not ok then
            error(result, 0)
        end
        return result
    end

    rawset(
        SCOFieldFixCreativeSpawnBridgeEnvironment,
        "SCO_FieldFixCreativeSpawnBridgeInstalled",
        "1.0.1")
    _G.SCO_FieldFixCreativeSpawnBridgeInstalled = "1.0.1"
    _G.SCO_FieldFixCreativeSpawnBridgeVersion = "1.0.1"
end
