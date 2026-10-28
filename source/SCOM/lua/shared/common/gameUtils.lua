local Factions = Import("common/systems/factions.lua")

---@alias MarkerName string
---@alias ChainName string
---@alias AreaName string
---@alias GroupName string
---@alias UnitName string

---@alias MarkerCategory
---|'"Spawn"'
---|'"Reesource"'
---|'"Blank"'

---@class Marker
---@field position float3
---@field rotation quaternion
---@field scale float3

---@class ChainItem
---@field type MarkerCategory
---@field name MarkerName

---@alias Chain ChainItem[]

---Area as stored in the map data.
---@class MapArea
---@field x number Min corner x.
---@field y number Min corner y.
---@field width number
---@field height number

---Unit as stored in a map data group.
---@class GroupUnit
---@field type string
---@field tpId string
---@field position float3
---@field rotation quaternion
---@field scale float3

---Unit group as stored in the map data.
---@class UnitGroup
---@field units table<UnitName, GroupUnit>
---@field groups table<GroupName, UnitGroup>|nil Subgroups, only used by older map data.

---Returns a marker from the map data.
---@param name MarkerName Marker name from the map file.
---@param category? MarkerCategory Marker category. If not provided, searches all categories.
---@param noError? boolean If true, doesn't throw an error if the marker is not found.
---@return Marker marker Found marker data or nil.
function GetMarker(name, category, noError)
    local marker
    if category then
        marker = GameInfo.MapData.markers[category] and GameInfo.MapData.markers[category].transforms[name]
    else
        for cat, data in pairs(GameInfo.MapData.markers) do
            marker = data.transforms[name]
            if marker then
                break
            end
        end
    end

    if not (noError or marker) then
        Error("gameUtils - GetMarker: Invalid marker name or category: " .. name, 2)
    end

    return marker
end

---Returns a chain from the map data.  
---Chain is a list of marker data(category, name).
---@param name ChainName Chain name from the map file.
---@param noError? boolean If true, doesn't throw an error if the chain is not found.
---@return Chain chain Found chain data or nil.
function GetChain(name, noError)
    local chain = GameInfo.MapData.chains[name]
    if not (noError or chain) then
        Error("gameUtils - GetChain: Invalid chain name: " .. name, 2)
    end

    return chain
end

---Returns a position of the marker.
---@param name MarkerName Marker name from the map file.
---@param category? MarkerCategory Marker category. If not provided, searches all categories.
---@return float3 position Copy of marker position {x=float, y=float, z=float}.
function MarkerToPosition(name, category)
    local pos = GetMarker(name, category).position
    return table.deepCopy(pos)
end

---Returns a table of positions from given chain.
---@param name ChainName Chain name from the map file.
---@return float3[] positions Table with markers {x, y z} positions.
function ChainToPositions(name)
    local chain = GetChain(name)
    local positions = {}

    for _, markerData in ipairs(chain) do
        table.insert(positions, MarkerToPosition(markerData.name, markerData.type))
    end

    return positions
end

---Returns an area from the map data.
---@param name AreaName Area name in the map data.
---@param noError boolean? If true, doesn't throw an error if the area is not found.
---@return MapArea area Area defined in the map editor {x = number, y = number, width = number, height = number} or nil.
function GetArea(name, noError)
    local area = GameInfo.MapData.areas[name]
    if not (noError or area) then
        Error("gameUtils - GetArea: Invalid area name: " .. name, 2)
    end

    return area
end

---Returns a unit group from the map data. Subgroups are searched as well.
---@param name GroupName Group name from the map file.
---@param noError? boolean If true, doesn't throw an error if the group is not found.
---@return UnitGroup group Found group data or nil.
function GetGroup(name, noError)
    local group = FindGroup(name)
    if not (noError or group) then
        Error("gameUtils - GetGroup: Invalid group name: " .. name, 2)
    end

    return group
end

---Creates a new area and adds it to the loaded ones from the map.
---@param name AreaName Name of the area to add.
---@param data table
---@return AreaName
function CreateArea(name, data)
    if type(name) ~= "string" then
        Error("CreateArea: Invalid area name: " .. type(name))
    --elseif GameInfo.MapData.areas[name] then
        --Error("CreateArea: Area with name '" .. name .. "' already exists.")
    elseif not (type(data) == "table" and data.x and data.y and data.width and data.height) then
        Error("CreateArea: Invalid area. Requies table with format {x = num, y = num, width = num, height = num}")
    end

    GameInfo.MapData.areas[name] = data

    return name
end

---Creates a new marker and adds it to the loaded ones from the map.
---@param name MarkerName Name of the new marker
---@param data table
---@param category? MarkerCategory
---@return MarkerName
function CreateMarker(name, data, category)
    if type(name) ~= "string" then
        Error("CreateMarker: Invalid marker name: " .. type(name))
    end

    category = category or "Blank"
    local markers = GameInfo.MapData.markers
    if not markers[category] then
        markers[category] = {
            resource = false,
            transforms = {},
        }
    end
    markers[category].transforms[name] = data
    --Log("Marker created: " .. name)

    return name
end

---Creates a new chain and adds it to the loaded ones from the map.
---@param name ChainName Name of the new chain
---@param data table
---@return ChainName
function CreateChain(name, data)
    if type(name) ~= "string" then
        Error("CreateChain: Invalid chain name: " .. type(name))
    end

    GameInfo.MapData.chains[name] = data
    --Log("Chain created: " .. name)

    return name
end

---Creates a new unit group and adds it to the loaded ones from the map.
---@param name GroupName Name of the new group.
---@param data UnitGroup
---@return GroupName
function CreateGroup(name, data)
    if type(name) ~= "string" then
        Error("CreateGroup: Invalid group name: " .. type(name))
    elseif type(data) ~= "table" or type(data.units) ~= "table" then
        Error("CreateGroup: Invalid group. Requires table with format {units = {}}")
    end

    GameInfo.MapData.groups[name] = data

    return name
end

---Returns a new table containing the default settings for an AI army.
---@return table
function GetDefaultAISettings()
    return {
        maximumUnitCount = 3000,                        -- maximum number of units allowed for this army
        economySettings = {
            incomeAndBuildMultiplier = 1.0,             -- regular income, construction and repair multiplier
            incomeAndBuildMultiplierRamp = {
                startMinute = 20,                       -- first game minute that changes the multiplier
                changePerMinute = 0.0,                  -- amount added each minute; 0 disables the ramp
            },
        },
        aiSettings = {                                  -- AI configuration for this player
            modDirectory = "AI/mods/AI-Sanctuary-Rush", -- directory containing the AI implementation
            modName = "AI-Sanctuary-Rush",              -- AI implementation name
            difficulty = "hard",                        -- easy, medium, hard
            expansionCount = 2,                         -- number of buildable expansions (4+ alloy spots)
            outpostCount = 2,                           -- number of buildable outposts (2-3 alloy spots)
            useLayer = {                                -- movement layers available to the AI
                land = true,                            -- allow the AI to use the land layer
                air = true,                             -- allow the AI to use the air layer
                water = false,                          -- allow the AI to use the water layer
            },
        },
    }
end

---@class ArmyLobbyOptions
---@field armyID ArmyId
---@field playerName string
---@field team integer Armies with the same team become allies, others become enemies.
---@field faction integer Faction index
---@field maximumUnitCount integer? Zero means unlimited
---@field economySettings EconomySettings?
---@field aiSettings table|false? AI configuration, false or nil for non-AI armies
---@field isEmptySlot boolean? True for armies created for unused map slots

---Creates all armies defined in the map and applies lobby configuration.
---Initializes faction, team, player name and AI settings from lobby data.
-- SCOM Large Map Load Compat: deferred initial units 1.0.0
---@param deferInitialUnits? boolean When true, the caller must invoke SpawnInitialUnits after client initialization is queued.
---@return nil
function CreateArmies(deferInitialUnits)
    -- Importing lobby options
    local lobbyOptionsAI, optionsOverride = GetLobbyDebugOptionsAI()
    local lobbyOptions = {}
    local mapArmies = GameInfo.MapData.armies

    local armySetup = {}
    for mapStartSlotName,_ in pairs(mapArmies) do
        table.insert(armySetup, mapStartSlotName)
    end
    -- Sort numbered map start slots by their numeric suffix.
    table.sort(armySetup, function(firstArmyName, secondArmyName)
        local firstArmyPrefix, firstArmyNumber = string.match(firstArmyName, "^(.-)_(%d+)$")
        local secondArmyPrefix, secondArmyNumber = string.match(secondArmyName, "^(.-)_(%d+)$")
        firstArmyPrefix = firstArmyPrefix or firstArmyName
        secondArmyPrefix = secondArmyPrefix or secondArmyName
        if firstArmyPrefix ~= secondArmyPrefix then return firstArmyPrefix < secondArmyPrefix end
        if not firstArmyNumber then return secondArmyNumber ~= nil end
        if not secondArmyNumber then return false end
        local firstArmyIndex, secondArmyIndex = tonumber(firstArmyNumber), tonumber(secondArmyNumber)
        if firstArmyIndex ~= secondArmyIndex then return firstArmyIndex < secondArmyIndex end
        return firstArmyName < secondArmyName
    end)

    local playerInfo = Engine.GetLobbyInformation().playersInformation

    -- collect used army IDs
    local usedArmyIds = {}
    for index = 1, table.getn(playerInfo) do
        usedArmyIds[playerInfo[index].armyID] = true
    end

    -- function to get smallest free army ID
    local function GetNextFreeArmyId()
        for id = 1, table.getn(armySetup) do
            if not usedArmyIds[id] then
                usedArmyIds[id] = true
                return id
            end
        end
    end

    -- Create the armies from map data
    for mapStartSlotIndex, mapStartSlotName in ipairs(armySetup) do
        lobbyOptions = {}

        --check if we have a playerEntry for this startplace
        local playerEntry = nil
        for index = 1, table.getn(playerInfo) do
            if playerInfo[index].armyID == mapStartSlotIndex then
                playerEntry = playerInfo[index]
                break
            end
        end

        -- apply lobby configuration from lobby information
        if playerEntry and not optionsOverride then
            lobbyOptions.armyID = playerEntry.armyID
            lobbyOptions.playerName = playerEntry.nickname
            lobbyOptions.team = playerEntry.team
            lobbyOptions.faction = playerEntry.faction + 1
            lobbyOptions.maximumUnitCount = playerEntry.maximumUnitCount or 0 -- 0 = no cap
            if playerEntry.playerType == PlayerType.AI then
                if playerEntry.hasAISettings then
                    lobbyOptions.maximumUnitCount = playerEntry.maximumUnitCount
                    lobbyOptions.economySettings = {
                        incomeAndBuildMultiplier = playerEntry.incomeAndBuildMultiplier,
                        incomeAndBuildMultiplierRamp = { startMinute = playerEntry.startMinute, changePerMinute = playerEntry.changePerMinute },
                    }
                    lobbyOptions.aiSettings = {
                        modDirectory = "AI/mods/"..playerEntry.modName,
                        modName = playerEntry.modName,
                        difficulty = playerEntry.difficulty,
                        expansionCount = playerEntry.expansionCount,
                        outpostCount = playerEntry.outpostCount,
                        useLayer = { land = playerEntry.land, air = playerEntry.air, water = playerEntry.water },
                    }
                else
                    local defaultAISettings = GetDefaultAISettings()
                    lobbyOptions.maximumUnitCount = defaultAISettings.maximumUnitCount
                    lobbyOptions.economySettings = defaultAISettings.economySettings
                    lobbyOptions.aiSettings = defaultAISettings.aiSettings
                end
            end

        -- apply debug override lobby configuration
        elseif optionsOverride and next(lobbyOptionsAI[mapStartSlotIndex]) then
            lobbyOptions.armyID = mapStartSlotIndex
            lobbyOptions.playerName = lobbyOptionsAI[mapStartSlotIndex].playerName
            lobbyOptions.team = lobbyOptionsAI[mapStartSlotIndex].team
            lobbyOptions.faction = lobbyOptionsAI[mapStartSlotIndex].faction
            lobbyOptions.maximumUnitCount = lobbyOptionsAI[mapStartSlotIndex].maximumUnitCount
            lobbyOptions.economySettings = lobbyOptionsAI[mapStartSlotIndex].economySettings
            lobbyOptions.aiSettings = lobbyOptionsAI[mapStartSlotIndex].aiSettings
            usedArmyIds[lobbyOptions.armyID] = true
        end

        -- create army
        if next(lobbyOptions) then
            local army = CreateArmy(lobbyOptions.armyID, mapStartSlotName, lobbyOptions.faction, false, lobbyOptions.economySettings, lobbyOptions.maximumUnitCount)
            army.lobbyOptions = lobbyOptions
        else
            -- create enemy army for unused slots
            local enemyArmyId = GetNextFreeArmyId()
            local enemyLobbyOptions = {}
            enemyLobbyOptions.armyID = enemyArmyId
            enemyLobbyOptions.playerName = "no Player"
            -- This team options just identifies armies together which should become allies/enemies. Just be unique so armies get different teams and become enemies.
            enemyLobbyOptions.team = 1000 + enemyArmyId
            enemyLobbyOptions.faction = 1
            enemyLobbyOptions.aiSettings = false
            enemyLobbyOptions.isEmptySlot = true
            local army = CreateArmy(enemyArmyId, mapStartSlotName, enemyLobbyOptions.faction, false)
            army.lobbyOptions = enemyLobbyOptions
        end
    end

    ---Applies team-based diplomatic relations between all armies
    ---Each army pair is processed only once (A < B) to avoid redundant checks.
    for _, armyA in pairs(Armies) do
        -- Retrieve the team ID for the first army
        local teamA = armyA.lobbyOptions.team
        for _, armyB in pairs(Armies) do
            -- Only process each unique pair once (avoid duplicates like A↔B and B↔A)
            if armyA.id < armyB.id then
                -- Retrieve the team ID for the second army
                local teamB = armyB.lobbyOptions.team
                -- Skip civilians for special neutral handling
                if not (armyA.civilian or armyB.civilian) then
                    -- If both armies share the same team, mark them as allies
                    if teamA == teamB then
                        armyA:SetAlly(armyB)
                        armyB:SetAlly(armyA)
                    -- Otherwise mark them as enemies
                    else
                        armyA:SetEnemy(armyB)
                        armyB:SetEnemy(armyA)
                    end
                -- Civilian armies are always neutral to everyone
                else
                    armyA:SetNeutral(armyB)
                    armyB:SetNeutral(armyA)
                end
            end
        end
    end

    if not deferInitialUnits then
        SpawnInitialUnits()
    end
end

---Returns the lobby options table if the (debug) file exists.
---@return table|false Returns lobbyDebugOptionsAI table if available, false otherwise
function GetLobbyDebugOptionsAI()
    -- attempt to import lobby options file
    local success, options = pcall(function()
        return Import("AI/_lobbyOptions.lua").lobbyDebugOptionsAI
    end)
    -- return imported table if successful
    if not success or not options then
        return false, false
    end
    -- attempt to import lobby override option
    local _, override = pcall(function()
        return Import("AI/_lobbyOptions.lua").lobbyOptionsAIOverride
    end)
    -- return false if file missing or import failed
    return options, override
end

-- SCOM Forged Alliance match-start resources 1.0.0
local function SCO_GiveStartingResources(army, unit)
    if not unit or army.scoStartingResourcesGranted then return end
    local economy = army.economy
    -- FA commander scripts give their full 650 mass / 4000 energy storage.
    -- Run after the initial unit completes Sanctuary's half-storage grant.
    for name, amount in pairs({ alloys = 650, energy = 4000 }) do
        local resource = economy.resources[name]
        if resource.storage < amount then
            -- Other installed factions can have smaller commander storage.
            economy:AddStorage(-1, { [name] = amount - resource.storage })
        end
        economy:TakeResources(name, resource.current)
        economy:GiveResources(name, amount)
    end
    army.scoStartingResourcesGranted = true
end

function SpawnInitialUnits()
    for i, army in pairs(Armies) do
        if not army.lobbyOptions.isEmptySlot then 
            if GetMarker(army.name, "Spawn", true) then
                local startingPos = MarkerToPosition(army.name, "Spawn")
            
                local _, terrainSize = Engine.GetTerrainHeightmapSize()
                
                startingPos.x = math.clamp(startingPos.x, 0, terrainSize.x - 2)
                startingPos.z = math.clamp(startingPos.z, 0, terrainSize.y - 2)

                local initialUnit = CreateUnit(i, Factions.FactionsData[army.faction].initialUnit, startingPos)
                SCO_GiveStartingResources(army, initialUnit)
            end
        end
    end
end

---Spawns all units of a group node and of its subgroups.
---@param armyIndex integer Army to spawn the units for.
---@param node UnitGroup
---@param result? Unit[] Used for recursive spawning of subgroups.
---@return Unit[] units
function SpawnSubGroup(armyIndex, node, result)
    result = result or {}

    for _, group in pairs(node.groups or {}) do
        SpawnSubGroup(armyIndex, group, result)
    end

    for name, unitData in pairs(node.units or {}) do
        local unit = CreateUnit(armyIndex, unitData.tpId, table.deepCopy(unitData.position)) -- TODO: rotation
        unit.unitName = name
        table.insert(result, unit)
    end

    return result
end

---Spawns a single group of units (including all subgroups) from the map data.
---@param armyIndex integer Army to spawn the units for.
---@param groupName GroupName Name of the unit group to spawn.
---@param noError? boolean If true, doesn't throw an error if the group is not found.
---@return Unit[] units Spawned units or nil when the group does not exist.
function SpawnGroup(armyIndex, groupName, noError)
    local group = GetGroup(groupName, noError)
    if not group then
        return
    end

    return SpawnSubGroup(armyIndex, group)
end

---Searches the given groups and their subgroups for a group.
---@param groupName GroupName
---@param groups? table<GroupName, UnitGroup> Defaults to all map groups.
---@return UnitGroup group Found group data or nil.
function FindGroup(groupName, groups)
    groups = groups or GameInfo.MapData.groups

    local result = groups[groupName]
    if result then
        return result
    end

    for _, group in pairs(groups) do
        result = FindGroup(groupName, group.groups or {})

        if result then
            return result
        end
    end
end

function FactionConvert(data, faction)
    local oldFaction = false
    local factionLetter = Factions.FactionsData[faction].tpLetter
    if type(data) == "string" then
        data = factionLetter .. string.sub(data, 3)
    elseif type(data) == "table" then
        -- TODO
        --data = string.gsub(data, "", "")
    else
        Error("Faction convert: Unsupported data type: " .. type(data))
    end
    return data
end

---Spawns a single unit from the map data groups.
---@param armyIndex integer Army to spawn the unit for.
---@param unitName UnitName Name of the unit to spawn.
---@return Unit unit
function SpawnGroupUnit(armyIndex, unitName)
    local unitData = FindUnit(unitName)
    if not unitData then
        Error("gameUtils - SpawnGroupUnit: Unit not found in the map data: " .. unitName, 2)
    end

    local unit = CreateUnit(armyIndex, unitData.tpId, table.deepCopy(unitData.position)) -- TODO: rotation
    unit.unitName = unitName

    return unit
end

---Searches the given groups and their subgroups for a unit.
---@param unitName UnitName
---@param groups? table<GroupName, UnitGroup> Defaults to all map groups.
---@return GroupUnit unitData Found unit data or nil.
function FindUnit(unitName, groups)
    for _, group in pairs(groups or GameInfo.MapData.groups) do
        local result = group.units and group.units[unitName]
        if result then
            return result
        end

        result = FindUnit(unitName, group.groups or {})
        if result then
            return result
        end
    end
end

--Only for annotations
return {
    GetMarker = GetMarker,
    GetChain = GetChain,
    MarkerToPosition = MarkerToPosition,
    ChainToPositions = ChainToPositions,
    GetArea = GetArea,
    GetGroup = GetGroup,
    CreateArea = CreateArea,
    CreateMarker = CreateMarker,
    CreateChain = CreateChain,
    CreateGroup = CreateGroup,
    GetDefaultAISettings = GetDefaultAISettings,
    CreateArmies = CreateArmies,
    SpawnInitialUnits = SpawnInitialUnits,
    SpawnSubGroup = SpawnSubGroup,
    SpawnGroup = SpawnGroup,
    SpawnGroupUnit = SpawnGroupUnit,
    FindUnit = FindUnit,
    FindGroup = FindGroup,
    FactionConvert = FactionConvert,
}
