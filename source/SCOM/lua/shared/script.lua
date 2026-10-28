IsClient = false
IsHost = false

---Entry point to the Lua
---@param libPath string Full path C:/../trebuchet/LJ/lua/
---@param isClient boolean `false` for host, `true` for client set up
function init(libPath, isClient) ---@diagnostic disable-line: lowercase-global
    jit.opt.start("maxtrace=20000", "maxmcode=32768")

    if isClient then
        IsClient = true
    else
        IsHost = true
    end

    --- Full path to the Lua folder `C:/../trebuchet/LJ/lua/`
    _G.libPath = libPath

    table.insert(package.loaders,
        ---@param filePath string Path of the required file, relative to the lua folder
        ---@return function|nil loader
        ---@return string? errorMessage
        function(filePath)
            local fileContent = Engine.GetFileContent(libPath .. filePath)
            if fileContent then
                Engine.Log("San require: Loading file: " .. filePath)
                return load(fileContent, filePath)
            end
            return nil, "San require: File: '" .. filePath .. "' not found."
        end
    )

    ---@diagnostic disable-next-line: lowercase-global
    Class = require("common/systems/classy.lua")
    ---@diagnostic disable-next-line: lowercase-global
    json = require("common/systems/json.lua")

    require("common/systems/import.lua")
    require("common/systems/networking.lua")

    if IsHost then
        require("host/generated/lua/enums.lua")
        require("host/generated/lua/constants.lua")
        require("host/generated/ffi/engineConstructors.lua")
    else
        require("client/generated/lua/enums.lua")
        require("client/generated/lua/constants.lua")
        require("client/generated/ffi/engineConstructors.lua")
    end

    local profilingTarget = Engine.GetLuaProfilingTarget()
    if (IsHost and profilingTarget == LuaProfilingTarget.Host) or (IsClient and profilingTarget == LuaProfilingTarget.Client) then
        Import("common/systems/samplingProfiler.lua").Start()
    end

    _G.defaultGravityAcceleration = EngineClasses.float3(0, -1.0, 0)

    Import("common/globalTables.lua")
    Import("common/utilities/utils.lua")
    Import("common/utilities/math.lua")
    Import("common/utilities/math2D.lua")
    Import("common/utilities/math3D.lua")
    Import("common/utilities/buildQueueUtils.lua")
    Import("common/utilities/table.lua")
    Import("common/utilities/string.lua")
    Import("common/hashset.lua")
    Import("common/systems/threads.lua")
    Import("common/commonFunctions.lua")
    Import("common/systems/commandLineArguments.lua")
    Import("common/systems/tags.lua")
    Import("common/utilities/ticks.lua")
    Import("common/navigationLayers.lua").CreateNavigationLayers()

    if IsClient then

        local platform = Engine.GetPlatform()
        local audioBanks = {}

        if platform == Platform.Windows then
            audioBanks = {
                "Gamedata/Audio/Windows/Init.bnk",
                "Gamedata/Audio/Windows/All_In_One.bnk",
            }
        elseif platform == Platform.Linux then
            audioBanks = {
                "Gamedata/Audio/Linux/Init.bnk",
                "Gamedata/Audio/Linux/All_In_One.bnk",
            }
        end

        for _, bankPath in ipairs(audioBanks) do
            local result = Engine.LoadAudioBank(bankPath)
            if result ~= EngineErrorCode.Success then
                Engine.Error(string.format("Failed to load audio bank '%s' (error %d).", bankPath, result))
            end
        end
    end

    local TemplateLoader = Import("common/systems/templateLoader.lua")
    TemplateLoader.LoadAllTemplates()

    local Registry = Import("common/commands/registry.lua")
    -- Loads every command definition and assigns command ids. Idempotent.
    Registry.Initialize()

    if IsHost then
        Import("host/hostFunctions.lua")
        Import("host/units/unitsUtilities.lua")
        Import("host/props/propsUtilities.lua")

        Import("host/hostMain.lua").Init()
    else
        Import('client/clientMain.lua').Init()
    end

    Import("common/systems/samplingProfiler.lua").NotifyLeavingLua()
end

--- Samples the four corners of the heightmap cell at (x, y) once and determines if the cell
--- is in shallow or deep water.
-- SCOM Large Map Load Compat: placement grid 1.0.1
-- Preserve the native depth-aware placement grid.
local function GetCellWaterFlags(x, y, waterLevel, depth)
    local deepThreshold = waterLevel - depth
    local isPartialWater = false
    local isDeepWater = true

    for cornerX = x, x + 1 do
        for cornerY = y, y + 1 do
            local errorCode, height = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(cornerX, cornerY))
            if errorCode == EngineErrorCode.Success then
                if height < waterLevel then
                    isPartialWater = true
                end
                if height > deepThreshold then
                    isDeepWater = false
                end
            else
                isDeepWater = false
            end
        end
    end

    return isPartialWater, isDeepWater
end

local function InitializePlacementGrid(setCellBaseFlags, gridID)
    --TODO: This might not be deterministic, so if we want to use this for both host and client it's better to have the host compute the values and send them to the client
    local PlacementLayer = Import("common/layers.lua").PlacementLayer
    local NavalPlacementDepth = Import("common/systems/placementUtils.lua").NavalPlacementDepth
    local Water = Import("common/water.lua")
    local mapSizeX = GameInfo.MapInfo.size[1]
    local mapSizeY = GameInfo.MapInfo.size[2]

    local maxPlacementAngle = 9.0
    local steepnessThreshold = math.cos(math.rad(maxPlacementAngle))

    local hasWater = Water.HasWater()
    local waterLevel = Water.GetLevel()

    for x = 1, mapSizeX -1 do
        for y = 1, mapSizeY - 1 do
            local coordinate = EngineClasses.int2(x, y)
            local _, firstNormal, secondNormal = Engine.SampleTerrainNormals(coordinate)

            local isTooSteep = firstNormal.y < steepnessThreshold or secondNormal.y < steepnessThreshold

            local isPartialWater, isDeepWater = false, false
            if hasWater then
                isPartialWater, isDeepWater = GetCellWaterFlags(x, y, waterLevel, NavalPlacementDepth)
            end

            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.InvalidTerrain, isTooSteep or isPartialWater)
            setCellBaseFlags(gridID, coordinate, coordinate, PlacementLayer.Water, isDeepWater)
        end
    end
end

---Initializes lobby state for host and client.
---@param lobbyData LobbyInformation
---@param argString string
function InitLobby(lobbyData, argString)
    local Lobby = Import("common/lobby.lua")

    local CommandRegistry = Import("common/commands/registry.lua")

    if IsHost then
        ProcessCmdLineString(argString)

        Import("common/mapUtils.lua").LoadMapData(lobbyData.mapPath)
        InitializePlacementGrid(Engine.SetGlobalGridCellBaseFlags, _G.globalBuildingPlacementGridID)

        Import("host/managers/targeting/targeterManager.lua")
        local GameUtils = Import("common/gameUtils.lua")
        GameUtils.CreateArmies(true)

        -- Count how many armies are defined in the map
        local mappedArmyCount = 0
        for _ in pairs(GameInfo.MapData.armies) do
            mappedArmyCount = mappedArmyCount + 1
        end
        
        for index, player in ipairs(lobbyData.playersInformation) do
            
            -- Force any player with an army unsupported by the map to be an observer.
            if player.playerType ~= PlayerType.AI and player.armyID > mappedArmyCount then
                player.playerType = PlayerType.Observer
            end

            -- ArmyIDs assigned to observers after the map armies
            if player.playerType == PlayerType.Observer then
                player.armyID = mappedArmyCount
                mappedArmyCount = mappedArmyCount + 1
            end
            
            if player.playerType ~= PlayerType.AI then
                Lobby.AddPlayer(player)
                Lobby.AddArmyToPlayer(player.clientID, player.armyID)

                ---@type LobbyInformation
                local data = table.deepCopy(lobbyData)
                data.playersInformation[index].focus = true

                -- Sent first, and on the same ordered channel, so a command-table disagreement
                -- is reported before any gameplay command can misroute.
                SendToClient(CommandRegistry.GetManifest(), "VerifyCommandManifest", player.clientID)
                SendToClient(data, "InitClient", player.clientID)
            end
        end

        -- SCOM Large Map Load Compat: client initialization ordering 1.0.0
        -- Armies and relationships must reach the client before focus initialization.
        -- Initial units must wait until InitClient registers the map's prop prefabs.
        Import("host/hostMain.lua").SCOSpawnInitialUnits(GameUtils)
        Import("host/hostMain.lua").Start()

    else
        Import("common/mapUtils.lua").LoadMapData(lobbyData.mapPath)

        for _, player in ipairs(lobbyData.playersInformation) do

            -- Humans and AIs for UI display only
            if player.playerType ~= PlayerType.Observer then
                Lobby.AddLobbyEntry(player)
            end

            if player.playerType ~= PlayerType.AI then
                Lobby.AddPlayer(player)
                Lobby.AddArmyToPlayer(player.clientID, player.armyID)

                if player.focus then
                    local isObserver = player.playerType == PlayerType.Observer or Engine.IsReplayPlayback()
                    Lobby.SetObserver(isObserver)

                    -- Observers view every army, just like the focus == -1 debug mode.
                    Lobby.InitiateFocus(player.clientID, isObserver and -1 or player.armyID)
                end
            end
        end
        Import("common/mapUtils.lua").RunMapSetup(false)
        InitializePlacementGrid(Engine.SetLocalGridCellBaseFlags, _G.localBuildingPlacementGridID)
        Import('client/clientMain.lua').Start()
    end
end

function OnShutdown()
    Import("common/systems/samplingProfiler.lua").StopAndWriteReport()
end

function ErrorHandler(text)
    Engine.Exception(debug.traceback(text, 2))
end

