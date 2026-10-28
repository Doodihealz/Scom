-- Survival game mode. Host only.
--
-- Sends escalating waves of enemy units at the players from map authored spawn markers.
-- Any map defining the markers listed in ResolveSpawnPoints supports the mode, and opts
-- into it through its name, see TryStartSurvival at the bottom.
--
-- Players do not fight from their map start positions. Every player army is forced onto
-- one team and teleported to the centre of the playable area, where the spawn rings converge.
--
-- Clients only render UI, see client/survival/survival.lua.

local GameUtils        = Import("common/gameUtils.lua")
local MapUtils         = Import("common/mapUtils.lua")
local SessionCommands  = Import("common/commands/definitions/session.lua")
local HostOrderManager = Import("host/managers/orders/hostOrderManager.lua")
local PlayableArea     = Import("host/managers/playableArea/hostPlayableAreaManager.lua")
local Triggers         = Import("host/game/triggers.lua")
local OrderTasks       = Import("common/commonOrders.lua").OrderTasks
local Area             = Import("common/area.lua").Area

local TimeBetweenWaves = 120  -- seconds

---Per-difficulty unit count multiplier (index 1..8, Easy..GodGamer)
local DifficultyMultipliers = { 0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 2.5, 3.0 }

---Wait before the first wave fires (seconds), per difficulty
local DifficultyStartupTimes = { 300, 270, 240, 210, 190, 170, 150, 130 }

---Shown in the persistent UI banner, already upper cased to match the rest of it
local DifficultyNames = {
    "EASY", "NORMAL", "HARD", "VERY HARD", "BRUTAL", "INSANE", "NIGHTMARE", "GOD GAMER",
}

local DefaultDifficulty = 4

-- Difficulties 1-3 only use the first three spawn points. Higher difficulties
-- unlock one extra flanking direction each.
local MinActiveSpawnPoints = 3

-- Scouts are fast light units that bypass their ring target and rush the player base.
local ScoutTpIdPattern = "l1701"

-- How far units are scattered around their spawn / target markers.
local SpawnScatter    = 10
local TargetScatter   = 10
local WaypointScatter = 5

-- Every live enemy unit polls on this, so keep it coarse.
local CommanderHuntPollSeconds = 2

-- Player armies are dropped on a ring around the centre of the playable area so
-- their commanders do not land on top of each other.
local PlayerRingRadius  = 20
local PlayerUnitScatter = 5

-- The team id every player army is forced onto.
local SurvivalTeam = 1

-- Map authored intel structures, without them the enemy army cannot see the players.
local EnemyIntelGroup = "Enemy_Intel"

-- ============================================================
-- Unit pools per faction per tier
-- ============================================================

---@type table<string, string[][]>
local FactionUnits = {
    Chosen = {
        { "ucl1001", "ucl1101", "ucl1701" },  -- T1
        { "uel3002" },                        -- T2
        { "ucl3001", "ucl3101", "ucl3801" },  -- T3
        { "ucl4004" },             -- T4
        { "ucl4004" },                        -- T5
    },
    EDA = {
        { "uel1001", "uel1002", "uel1101", "uel1701" },  -- T1
        { "uel3002" },                                   -- T2
        { "uel3001", "uel3101", "uel3801" },             -- T3
        -- EDA has no T4/T5 of its own yet, so it borrows the Chosen ones.
        { "uel4001", "uel4002" },                        -- T4
        { "ucl4004" },                                   -- T5
    },
    Guard = {
        { "ugl1001", "ugl1101", "ugl1701" },  -- T1
        { "ugl2002", "ugl2101" },             -- T2
        { "ugl3001", "ugl3002" },             -- T3
        { "ugl4001" },                        -- T4
        -- Guard has no T5 of its own yet.
        { "ucl4004" },                        -- T5
    },
}

local TierCount = 5

-- ============================================================
-- Wave definitions  {t1, t2, t3, t4, t5}
-- Baseline counts for difficulty 4 (VeryHard, multiplier 1.0).
-- Scaled by unitMultiplier at runtime, minimum 1 per non-zero tier.
-- ============================================================

local WaveUnitCounts = {
    { 20, 0,  0,  0, 0 },  -- 1
    { 25, 0,  0,  0, 0 },  -- 2
    { 30, 2,  0,  0, 0 },  -- 3
    { 35, 4,  0,  0, 0 },  -- 4
    { 40, 6,  0,  0, 0 },  -- 5
    { 45, 8,  0,  0, 0 },  -- 6
    { 50, 10, 2,  0, 0 },  -- 7
    { 45, 14, 5,  0, 0 },  -- 8
    { 40, 18, 8,  0, 0 },  -- 9
    { 45, 22, 11, 0, 0 },  -- 10
    { 50, 26, 14, 0, 0 },  -- 11
    { 55, 30, 17, 0, 0 },  -- 12
    { 50, 34, 20, 0, 0 },  -- 13
    { 45, 38, 23, 1, 0 },  -- 14
    { 40, 42, 26, 1, 0 },  -- 15
    { 35, 36, 29, 1, 0 },  -- 16
    { 30, 30, 32, 2, 0 },  -- 17
    { 25, 24, 35, 2, 0 },  -- 18
    { 20, 20, 38, 3, 0 },  -- 19
    { 15, 16, 41, 3, 1 },  -- 20
}

local TotalWaves = #WaveUnitCounts

-- ============================================================
-- Runtime state, set by StartSurvival before WaveLoop runs
-- ============================================================

---@class SurvivalSpawnPoint
---@field spawn float3 Where the units appear
---@field target float3 Where they attack toward
---@field waypoint float3|nil Optional intermediate point, for maps where units spawn in a corner

---@type number
local unitMultiplier = 1.0
---@type integer
local startupTime = DifficultyStartupTimes[DefaultDifficulty]
---@type string
local difficultyName = DifficultyNames[DefaultDifficulty]
---@type SurvivalSpawnPoint[]
local spawnPoints = {}
---@type integer Number of spawnPoints entries in use at the current difficulty
local activeSpawnCount = MinActiveSpawnPoints
---@type float3 Where scouts head for
local scoutTarget
---@type MapArea|nil Units spawned outside this rect are routed to its edge first
local routingArea
---@type string[][] Merged tier unit lists for the active enemy factions
local availableUnits = {}
---@type HostArmy
local enemyArmy
---@type boolean
local isRunning = false

-- ============================================================
-- Helpers
-- ============================================================

---Scatters a position on the XZ plane. y is zeroed so CreateUnit and the order
---system snap the result to the terrain surface.
---@param pos float3
---@param dx number
---@param dz number
---@return float3
local function RandomOffset(pos, dx, dz)
    return EngineClasses.float3(
        pos.x + math.random(-dx, dx),
        0,
        pos.z + math.random(-dz, dz)
    )
end

---@param pos float3
---@return boolean
local function IsInsideRoutingArea(pos)
    if not routingArea then
        return true
    end

    return pos.x >= routingArea.x and pos.x <= routingArea.x + routingArea.width
       and pos.z >= routingArea.y and pos.z <= routingArea.y + routingArea.height
end

---Returns the nearest point on the routing area boundary.
---@param pos float3
---@return float3
local function ClampToRoutingEdge(pos)
    return EngineClasses.float3(
        math.clamp(pos.x, routingArea.x, routingArea.x + routingArea.width),
        0,
        math.clamp(pos.z, routingArea.y, routingArea.y + routingArea.height)
    )
end

---@param seconds integer
---@param enabled boolean
local function BroadcastCountdown(seconds, enabled)
    SendToAllClients({ seconds = seconds, enabled = enabled }, "SurvivalSetCountdown")
end

---Puts the clients into survival mode. Has to go out before any other survival command.
local function BroadcastSurvivalStart(difficulty)
    SendToAllClients({
        difficulty = difficulty,
        difficultyName = difficultyName,
        totalWaves = TotalWaves,
    }, "SurvivalStart")
end

---Banners the status behind the mode and difficulty, "SURVIVAL | HARD | GET READY".
---@param status string
---@param enabled boolean
local function BroadcastPersistentText(status, enabled)
    local text = "SURVIVAL | " .. difficultyName .. " | " .. status
    SendToAllClients({ text = text, enabled = enabled }, "SurvivalSetPersistentText")
end

-- ============================================================
-- Setup
-- ============================================================

---Builds the merged tier unit lists for the given factions.
---@param factionKeys string[] e.g. {"Chosen", "EDA", "Guard"}
---@return string[][] tiers Index 1..5, each a flat list of tpIds
local function BuildAvailableUnits(factionKeys)
    local tiers = {}
    for tier = 1, TierCount do
        tiers[tier] = {}
    end

    for _, faction in ipairs(factionKeys) do
        local factionTiers = FactionUnits[faction]
        if not factionTiers then
            Warn("Survival: Unknown enemy faction: " .. tostring(faction))
        else
            for tier = 1, TierCount do
                for _, tpId in ipairs(factionTiers[tier] or {}) do
                    table.insert(tiers[tier], tpId)
                end
            end
        end
    end

    for tier = 1, TierCount do
        if not tiers[tier][1] then
            Error("Survival: No units available for tier " .. tier .. ". Check the enemy faction list.")
        end
    end

    return tiers
end

---Reads the survival markers from the map data.
---Requires `Spawn_Marker_N` and `Target_Marker_N` pairs numbered from 1, plus an
---`Enemy_Target_Marker` for the scouts. `Waypoint_Marker_N` is optional and is used
---on maps where units spawn in a corner and need routing before their attack move.
local function ResolveSpawnPoints()
    spawnPoints = {}

    local index = 1
    while GameUtils.GetMarker("Spawn_Marker_" .. index, nil, true) do
        if not GameUtils.GetMarker("Target_Marker_" .. index, nil, true) then
            Error("Survival: Spawn_Marker_" .. index .. " has no matching Target_Marker_" .. index)
        end

        local waypoint = GameUtils.GetMarker("Waypoint_Marker_" .. index, nil, true)

        table.insert(spawnPoints, {
            spawn    = GameUtils.MarkerToPosition("Spawn_Marker_" .. index),
            target   = GameUtils.MarkerToPosition("Target_Marker_" .. index),
            waypoint = waypoint and table.deepCopy(waypoint.position) or nil,
        })

        index = index + 1
    end

    if not spawnPoints[1] then
        Error("Survival: The map defines no Spawn_Marker_1, this map does not support survival.")
    end

    -- Prefer the tighter survival routing rect when the map defines one. It makes the
    -- outer spawn markers count as "outside", so units path to its edge before attacking.
    routingArea = GameUtils.GetArea("Playable_Area", true) or GameUtils.GetArea("PlayableArea", true)
    if not routingArea then
        Warn("Survival: No Playable_Area or PlayableArea defined, units will attack move directly from their spawn.")
    end

    if routingArea then
        PlayableArea.SetPlayableArea(Area.FromMapArea(routingArea))
    end

    if GameUtils.GetMarker("Enemy_Target_Marker", nil, true) then
        scoutTarget = GameUtils.MarkerToPosition("Enemy_Target_Marker")
    elseif routingArea then
        -- Fall back to the centre of the routing area.
        scoutTarget = EngineClasses.float3(
            routingArea.x + routingArea.width / 2,
            0,
            routingArea.y + routingArea.height / 2
        )
        Warn("Survival: No Enemy_Target_Marker, scouts will rush the centre of the playable area.")
    else
        scoutTarget = table.deepCopy(spawnPoints[1].target)
        Warn("Survival: No Enemy_Target_Marker, scouts will use the first target marker.")
    end
end

---Returns the army the waves are spawned for.
---Unused map start slots are already created as hostile armies by GameUtils.CreateArmies,
---so the first of those is reused. A new army is only created when every slot is taken.
---@return HostArmy
local function GetOrCreateEnemyArmy()
    local armyIds = {}
    for id in pairs(Armies) do
        table.insert(armyIds, id)
    end
    table.sort(armyIds)

    for _, id in ipairs(armyIds) do
        local army = Armies[id]
        if army.lobbyOptions and army.lobbyOptions.isEmptySlot then
            Log("Survival: Using empty start slot as the enemy army: " .. army.name .. " (id " .. army.id .. ")")
            return army
        end
    end

    -- CreateArmy derives a free id from the map slot count, which is a hash table here
    -- and would resolve to 0, so pick the next free id explicitly.
    local nextId = 1
    while Armies[nextId] do
        nextId = nextId + 1
    end

    local newArmy = CreateArmy(nextId, "Survival_Enemy", 1, false)
    newArmy.lobbyOptions = {
        armyID = newArmy.id,
        playerName = "Survival_Enemy",
        team = 1000 + newArmy.id,
        faction = 1,
        aiSettings = false,
        isEmptySlot = true,
    }

    for _, id in ipairs(armyIds) do
        local army = Armies[id]
        if not army.civilian then
            newArmy:SetEnemy(army)
            army:SetEnemy(newArmy)
        end
    end

    Log("Survival: Created a new enemy army (id " .. newArmy.id .. ")")

    return newArmy
end

---Every army that belongs to a player, in ascending id order.
---Civilians, unused map slots and the wave army itself are left out.
---@return HostArmy[]
local function GetPlayerArmies()
    local armyIds = {}
    for id in pairs(Armies) do
        table.insert(armyIds, id)
    end
    table.sort(armyIds)

    local playerArmies = {}
    for _, id in ipairs(armyIds) do
        local army = Armies[id]
        local isEmptySlot = army.lobbyOptions and army.lobbyOptions.isEmptySlot
        if army ~= enemyArmy and not army.civilian and not isEmptySlot then
            table.insert(playerArmies, army)
        end
    end

    return playerArmies
end

---Puts every player army on one team. Survival is always co-op, so a free for all lobby
---setup must not carry over into the run.
local function ForcePlayerAlliance()
    local playerArmies = GetPlayerArmies()

    for indexA, armyA in ipairs(playerArmies) do
        if armyA.lobbyOptions then
            armyA.lobbyOptions.team = SurvivalTeam
        end

        for indexB = indexA + 1, #playerArmies do
            local armyB = playerArmies[indexB]
            armyA:SetAlly(armyB)
            armyB:SetAlly(armyA)
        end

        -- Re-assert the one relation the mode cannot work without.
        armyA:SetEnemy(enemyArmy)
        enemyArmy:SetEnemy(armyA)
    end

    Log("Survival: Forced " .. #playerArmies .. " player armies onto team " .. SurvivalTeam)
end

---Moves every player army to the centre of the playable area and points the clients at
---their new position. The spawn rings converge there, the map start positions are not
---where the mode is meant to be played from.
local function TeleportPlayerArmiesToCentre()
    local area = PlayableArea.GetPlayableArea()
    if not area then
        Warn("Survival: The playable area is not initialized, player armies keep their start positions.")
        return
    end

    local playerArmies = GetPlayerArmies()
    local armyCount = #playerArmies
    if armyCount == 0 then
        return
    end

    -- Area.position is the centre as a float2 on the XZ plane, so y is world z.
    local centreX = area.position.x
    local centreZ = area.position.y

    local cameraTargets = {}

    for index, army in ipairs(playerArmies) do
        local slot = EngineClasses.float3(centreX, 0, centreZ)

        if armyCount > 1 then
            local angle = 2 * math.pi * (index - 1) / armyCount
            slot.x = centreX + math.cos(angle) * PlayerRingRadius
            slot.z = centreZ + math.sin(angle) * PlayerRingRadius
        end

        SnapToGround(slot, slot)
        table.insert(cameraTargets, { armyId = army.id, x = slot.x, y = slot.y, z = slot.z })

        for _, unit in ipairs(army:GetListOfUnits(Tags.ALL_UNITS, true)) do
            if not unit.dead then
                local position = RandomOffset(slot, PlayerUnitScatter, PlayerUnitScatter)
                if MapUtils.IsPositionOnMap(position) then
                    -- SetPosition does not snap, so sample the terrain height first.
                    SnapToGround(position, position)
                    unit:SetPosition(position)
                end
            end
        end
    end

    Log("Survival: Moved " .. armyCount .. " player armies to the centre of the playable area ("
        .. centreX .. ", " .. centreZ .. ")")

    SendToAllClients({ armies = cameraTargets }, "SurvivalFocusCamera")
end

---Spawns the map authored intel group for the wave army.
local function SpawnEnemyIntel()
    local units = GameUtils.SpawnGroup(enemyArmy.id, EnemyIntelGroup, true)
    if not units then
        Warn("Survival: The map defines no " .. EnemyIntelGroup
            .. " group, the enemy army has no vision of the players.")
        return
    end

    Log("Survival: Spawned " .. #units .. " " .. EnemyIntelGroup
        .. " units for the enemy army (id " .. enemyArmy.id .. ")")
end

-- ============================================================
-- Spawning
-- ============================================================

---@param position float3
---@return HostUnit|nil #nil when the players have no commander left
local function FindNearestPlayerCommander(position)
    local nearest, nearestDistance

    for _, army in ipairs(GetPlayerArmies()) do
        -- Unfinished included, a commander may still be dropping in.
        for _, commander in ipairs(army:GetListOfUnits(Tags.COMMAND, true)) do
            if not commander.dead then
                local distance = math3D.distanceSquared(position, commander:GetPosition())
                if not nearestDistance or distance < nearestDistance then
                    nearest, nearestDistance = commander, distance
                end
            end
        end
    end

    return nearest
end

---@param unit HostUnit
---@return boolean idle False when the unit died before it ran out of orders
local function WaitUntilOutOfOrders(unit)
    while not unit.dead do
        if unit.orders.activeOrder == nil and #unit.orders.queuedOrders == 0 then
            return true
        end

        WaitSeconds(CommanderHuntPollSeconds)
    end

    return false
end

---Re-targets the unit whenever it runs out of orders, so a wave does not pile up on its
---target marker. Picked again each time because commanders move and die.
---@param unit HostUnit
local function HuntPlayerCommanders(unit)
    while WaitUntilOutOfOrders(unit) do
        local commander = FindNearestPlayerCommander(unit:GetPosition())
        if commander then
            local targetPos = RandomOffset(commander:GetPosition(), TargetScatter, TargetScatter)
            HostOrderManager.HostIssueOrder(OrderTasks.ATTACKMOVE, { unit }, false, targetPos, nil)
        end

        -- Paces the retry when there is no commander, or the order was rejected.
        WaitSeconds(CommanderHuntPollSeconds)
    end
end

---Spawns one enemy unit and issues its movement orders. Runs as its own thread so the
---WaitTicks below does not stall the wave spawner, and then lives as long as the unit.
---@param tpId string
---@param spawnPoint SurvivalSpawnPoint
local function SpawnEnemyUnit(tpId, spawnPoint)
    local spawnPos = RandomOffset(spawnPoint.spawn, SpawnScatter, SpawnScatter)
    local unit = CreateUnit(enemyArmy.id, tpId, spawnPos)

    -- Orders issued on the same tick as CreateUnit are ignored.
    WaitTicks(1)

    local target = string.find(tpId, ScoutTpIdPattern) and scoutTarget or spawnPoint.target
    local targetPos = RandomOffset(target, TargetScatter, TargetScatter)

    HostOrderManager.HostIssueOrder(OrderTasks.ATTACKMOVE, { unit }, true, targetPos, nil)

    HuntPlayerCommanders(unit)
end

---Dispatches all units for one wave, cycling through the active spawn points.
---@param waveIndex integer
local function SpawnWave(waveIndex)
    local tierCounts = WaveUnitCounts[waveIndex]
    local spawnIndex = 1

    Log("Survival: Spawning wave " .. waveIndex .. "/" .. TotalWaves)

    for tier = 1, TierCount do
        local baseCount = tierCounts[tier]
        if baseCount > 0 then
            -- At least one unit per non-zero tier, even on the lowest difficulty.
            local count = math.max(1, math.floor(baseCount * unitMultiplier + 0.5))
            local tierPool = availableUnits[tier]

            for _ = 1, count do
                NewThread(SpawnEnemyUnit, table.random(tierPool), spawnPoints[spawnIndex])

                spawnIndex = spawnIndex + 1
                if spawnIndex > activeSpawnCount then
                    spawnIndex = 1
                end
            end
        end
    end
end

-- ============================================================
-- Wave loop
-- ============================================================

---Reports the victory once every remaining enemy is dead.
---@param lastRemainingEnemyUnits HostUnit[]
local function VictoryWatcher(lastRemainingEnemyUnits)
    -- We use the trigger to look if all the remaining units was destroyed then trigger a Win Condition
    Triggers.CreateGroupDestroyedTrigger(function()
        Log("Survival: All enemies destroyed.")
        SessionCommands.AddLog.Send("All waves cleared, you survived!")
        -- Trigger the win condition for the survival team
        SessionCommands.ExecuteClientFunction.Send("WinConditionUpdate", { armyID = SurvivalTeam, condition = 1 })
    end, lastRemainingEnemyUnits)
end

---@param seconds number
---@return string
local function FormatSeconds(seconds)
    seconds = math.floor(seconds)
    return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function WaveLoop()

    BroadcastPersistentText("GET READY", true)
    BroadcastCountdown(startupTime, true)

    WaitTicks(ConvertTimeToTick(startupTime))

    for waveNumber = 1, TotalWaves do
        SpawnWave(waveNumber)
        BroadcastPersistentText(tostring(waveNumber) .. "/" .. tostring(TotalWaves), true);

        if waveNumber < TotalWaves then
            SessionCommands.AddLog.Send("Wave " .. waveNumber .. " starts in " .. FormatSeconds(TimeBetweenWaves))
            BroadcastCountdown(TimeBetweenWaves, true)
            WaitTicks(ConvertTimeToTick(TimeBetweenWaves))
        end
    end

    BroadcastCountdown(0, false)

    SessionCommands.AddLog.Send("Destroy the remaining enemies to win!")
    Log("Survival: All " .. TotalWaves .. " waves dispatched.")

    -- We get mobile units because structures are outside the playable area and cannot be destroyed
    VictoryWatcher(enemyArmy:GetListOfUnits(Tags.MOBILE))
end

-- ============================================================
-- Public entry point
-- ============================================================

---Starts the survival scenario. Call once after the lobby is set up and the map is loaded.
---@param difficulty integer|nil 1 (Easy) to 8 (GodGamer). Defaults to 4 (VeryHard).
---@param enemyFactions string[]|nil Faction names to draw enemies from. Defaults to all three (mixed).
function StartSurvival(difficulty, enemyFactions)
    if isRunning then
        Warn("Survival: StartSurvival called while a run is already in progress, ignoring.")
        return
    end
    isRunning = true

    local diff = math.clamp(difficulty or DefaultDifficulty, 1, #DifficultyMultipliers)

    unitMultiplier = DifficultyMultipliers[diff]
    startupTime    = DifficultyStartupTimes[diff]
    difficultyName = DifficultyNames[diff]
    availableUnits = BuildAvailableUnits(enemyFactions or { "Chosen", "EDA", "Guard" })
    enemyArmy      = GetOrCreateEnemyArmy()

    BroadcastSurvivalStart(diff)

    -- Publishes the survival playable area, which the teleport below reads back.
    ResolveSpawnPoints()

    activeSpawnCount = math.min(math.max(diff, MinActiveSpawnPoints), #spawnPoints)

    ForcePlayerAlliance()
    TeleportPlayerArmiesToCentre()

    SpawnEnemyIntel()

    Log("Survival: difficulty=" .. diff .. " (" .. difficultyName .. ")"
        .. " multiplier=" .. unitMultiplier
        .. " startup=" .. startupTime .. "s"
        .. " activeSpawns=" .. activeSpawnCount .. "/" .. #spawnPoints
        .. " enemyArmy=" .. enemyArmy.id)

    NewThread(WaveLoop)
end

-- ============================================================
-- Start up: map name, command line, quick launch
-- ============================================================

-- Maps opt into survival by carrying this word in their name, e.g. "White_Desert_Survival_Hard".
local SurvivalMapKeyword = "survival"

---Difficulty words a map name may carry. Longest first, otherwise "veryhard" matches "hard".
local MapNameDifficulties = {
    { keyword = "nightmare", difficulty = 7 },
    { keyword = "godgamer",  difficulty = 8 },
    { keyword = "veryhard",  difficulty = 4 },
    { keyword = "brutal",    difficulty = 5 },
    { keyword = "insane",    difficulty = 6 },
    { keyword = "normal",    difficulty = 2 },
    { keyword = "easy",      difficulty = 1 },
    { keyword = "hard",      difficulty = 3 },
}

---Splits a comma separated string into a trimmed string array.
---@param str string
---@return string[]|nil #nil when the input is empty or not a string
local function ParseCommaSeparated(str)
    if type(str) ~= "string" or str == "" then return nil end

    local result = {}
    for part in string.gmatch(str, "([^,%s]+)") do
        table.insert(result, part)
    end

    return result[1] and result or nil
end

---Reads the optional -difficulty and -factions overrides from the command line.
---@param defaultDifficulty integer|nil Used when -difficulty is not passed
---@return integer difficulty
---@return string[]|nil factions
local function ReadCommandLineOptions(defaultDifficulty)
    local difficulty = HasCommandLineArgument("difficulty")
        and tonumber(GetCommandLineArguments("difficulty"))
        or defaultDifficulty
        or DefaultDifficulty

    local factions = HasCommandLineArgument("factions")
        and ParseCommaSeparated(GetCommandLineArguments("factions"))
        or nil

    return difficulty, factions
end

-- Expected args:
--   -scenario=Survival
--   -difficulty=4          (optional, 1..8, default 4)
--   -factions=Chosen,EDA   (optional, comma separated, default all three)
local function TryStartFromCommandLine()
    if not HasCommandLineArgument("scenario") then return false end
    if GetCommandLineArguments("scenario") ~= "Survival" then return false end

    Log("Survival: starting from command line args")
    StartSurvival(ReadCommandLineOptions())

    return true
end

-- The editor quick launch field only carries the scenario name, so -difficulty and -factions can still be used alongside it.
local function TryStartFromQuickLaunch()
    if Engine.GetQuickLaunchScenarioName() ~= "Survival" then return false end

    Log("Survival: starting from quick launch")
    StartSurvival(ReadCommandLineOptions())

    return true
end

---Lower cases and drops everything but letters and digits, so the keyword lookups do not care how the map author separated the words.
---@param name string|nil
---@return string
local function NormalizeMapName(name)
    return (string.gsub(string.lower(name or ""), "[^%a%d]", ""))
end

---Reads the difficulty out of the map name, e.g. "White_Desert_Survival_Hard".
---@return integer|nil difficulty #nil when the map is not a survival map
local function ReadMapNameDifficulty()
    -- Both names are checked, either one may carry the tag. The space keeps a keyword from straddling the two.
    local name = NormalizeMapName(MapUtils.GetMapDataName()) .. " " .. NormalizeMapName(MapUtils.GetMapName())

    if not string.find(name, SurvivalMapKeyword, 1, true) then
        return nil
    end

    for _, entry in ipairs(MapNameDifficulties) do
        if string.find(name, entry.keyword, 1, true) then
            return entry.difficulty
        end
    end

    return DefaultDifficulty
end

-- -difficulty and -factions still override what the map name asks for.
local function TryStartFromMapName()
    local difficulty = ReadMapNameDifficulty()
    if not difficulty then return false end

    Log("Survival: starting from map name " .. tostring(MapUtils.GetMapDataName()))
    StartSurvival(ReadCommandLineOptions(difficulty))

    return true
end

---Starts survival when the launch context asks for it. Called once from hostMain, after
---the map data is loaded.
---@return boolean started
function TryStartSurvival()
    return TryStartFromCommandLine()
        or TryStartFromQuickLaunch()
        or TryStartFromMapName()
end

-- Only for annotations
return {
    StartSurvival = StartSurvival,
    TryStartSurvival = TryStartSurvival,
}
-- SCOM Field Fix: land-safe Chosen T4 survival pool 1.0.1
