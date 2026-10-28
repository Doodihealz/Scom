local HostListeners = Import("host/hostListeners.lua").functions
local Commands = Import("host/commands.lua")
local EconomyCommands = Import("common/commands/definitions/economy.lua")
local SamplingProfiler = Import("common/systems/samplingProfiler.lua")
local LogWindows = Import("host/logWindows.lua")

-- Defines _G.CreateResourceSpot / _G.RemoveResourceSpot. Imported here so they exist before map setup.
Import("host/resourceSpots/resourceSpotUtilities.lua")

--- Set up basic host things
function Init()
    Log("InitHost")

    -- Registers calls from clients
    for name, func in pairs(HostListeners) do
        RegisterListener("host_" .. name, func)
    end
end

-- Start the host
function Start()
    assert(GameInfo.MapInfo ~= nil)
    assert(GameInfo.MapData ~= nil)

    Import("host/testUtils.lua").LoadDebugUnitGroups()

    TryRunningCmndLineScenario()

    NewThread(Import("AI/AIInit.lua").InitAIInfrastructure)
end

function TryRunningCmndLineScenario()
    if HasCommandLineArgument("scenario") then
        local availableScenario = {
            ["Showcase"] = "StartShowcase",
            ["Bigbattle"] = "ToggleBigBattle",
            ["Allunits"] = "SpawnAllUnits",
        }
        local scenario = GetCommandLineArguments("scenario")
        Log("Launching scenario: " .. scenario)
        if availableScenario[scenario] then
            Import("host/testUtils.lua")[availableScenario[scenario]]()
        end
    end
end

function _G.OnRenderUpdate()
    LogWindows.RenderUpdate()

    SamplingProfiler.NotifyLeavingLua()
end

---Called from engine each tick.  
---This is the place to set what order things should be updated in.
function _G.OnSimulationTickUpdate()
    ProcessFileEvents()
    
    -- NOTE: Must run before we update _G.Tick and _G.Time.
    -- This will flush any threads which have yet to resolved on the previous tick.
    ThreadDispatcherFlush()

    _G.Time = Engine.GetSimulationTime()
    _G.Tick = Engine.GetSimulationTick()

    --TODO: Running this inside the normal init breaks systems as they would update in a different order compared to the client
    --We should always have the engine just call lua from the LuaUpdate system, otherwise we can get unexpected behaviour/results
    if _G.Tick == 0 then
        local lobbyData = Engine.GetLobbyInformation()
        InitLobby(lobbyData, Engine.GetCommandLineOverrides())
        Import("common/mapUtils.lua").RunMapSetup(true)
        
        SCOStartSurvival()
    end

    if SCOHoldCommanderArrival() then
        SamplingProfiler.NotifyLeavingLua()
        return
    end

    for _, economy in pairs(Economies) do
        economy:Update()
        EconomyCommands.UpdateEconomyTotals.Send(economy.armyId, economy.totals)
    end

    -- Rradar detectors get disabled during the economy update, so we must UpdateIntel after economy update()
    local intelUpdate = Import("host/managers/intel/intelManager.lua")
    intelUpdate.UpdateIntel()

    local unitsUpdate = Import("host/units/unitsUpdate.lua")
    unitsUpdate.MovementUpdate()
    unitsUpdate.AnimationUpdate()
    unitsUpdate.WeaponsUpdate()
    
    local constructionUpdate = Import("host/managers/colliders/constructionManager.lua")
    constructionUpdate.ProcessConstructionEvents()

    local collisionUpdate = Import("host/collisionUpdate.lua")
    collisionUpdate.CollisionUpdate()

    -- Should run after collision update. Can have collisions but instead of processing them, projectile dies from lifetime.
    local projectilesUpdate = Import("host/projectiles/projectilesUpdate.lua")
    projectilesUpdate.ProjectilesUpdate()

    local targeterUpdate = Import("host/managers/targeting/targeterManager.lua")
    targeterUpdate.UpdateTargeting()

    -- Should likely be the first thing ran in the update.
    Commands.ProcessClientCommands()

    local orderManager = Import("host/managers/orders/hostOrderManager.lua")
    orderManager.Update()
    
    -- Run all lua threads
    ThreadsDispatcherUpdate()

    SamplingProfiler.NotifyLeavingLua()
end


-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0
-- SCO_CommanderArrivalHost_v1
-- Appended inside hostMain; only the canonical initial-unit call opens this cohort.
local scoArrivalIds = {uel0000=true, ugl0000=true, ucl0000=true, usl0000=true}
local scoArrivalSession = Import("common/commands/definitions/session.lua")
local scoArrivalLobby = Import("common/lobby.lua")
local scoArrivalStockStart = Start
local scoArrivalState
local scoArrivalStarted = false

local function scoArrivalSend(name, state, units)
    scoArrivalSession.ExecuteClientFunction.Send(name, {
        version = 2,
        sequence = 1,
        phase = state.phase,
        startTick = state.startTick,
        effectTick = state.effectTick,
        revealTick = state.releaseTick,
        releaseTick = state.releaseTick,
        units = units or state.units,
    })
end

local function scoArrivalAcceptReady(data, clientId)
    local state = scoArrivalState
    if not state or type(data) ~= "table" or data.version ~= 2
        or data.sequence ~= 1 or data.phase ~= state.phase
        or not state.clients[clientId] or not scoArrivalLobby.Players[clientId] then
        return false
    end
    state.ready[clientId] = true
    return true
end

-- The ordinary named-function bridge drops sender identity. Intercept only this
-- acknowledgment while the registry still supplies its authenticated command.
local scoArrivalReceiveHostFunction = scoArrivalSession.ExecuteHostFunction.Receive
function scoArrivalSession.ExecuteHostFunction.Receive(data, command)
    local call = json.decode(data.call)
    if call.functionName == "SCOCommanderArrivalReady" then
        return scoArrivalAcceptReady(call.functionData, command and command.clientID)
    end
    return scoArrivalReceiveHostFunction(data, command)
end

local function scoArrivalAllReady(state)
    for clientId in pairs(state.clients) do
        if scoArrivalLobby.Players[clientId] and not state.ready[clientId] then return false end
    end
    return true
end

local function scoArrivalRestore(state)
    for _, saved in ipairs(state.savedUnits) do
        local unit = saved.unit
        if not unit.dead and __Entities.Units[unit.id.index] == unit then
            unit.canTakeDamage = saved.canTakeDamage
            unit.canBeKilled = saved.canBeKilled
            unit.isTargetable = saved.isTargetable
        end
    end
end

function SCOSpawnInitialUnits(gameUtils)
    if scoArrivalStarted then return end
    if Engine.GetSimulationTick() ~= 0 then
        return gameUtils.SpawnInitialUnits()
    end
    scoArrivalStarted = true
    local factions = Import("common/systems/factions.lua").FactionsData
    local placement = Import("common/systems/placementUtils.lua")
    local _, terrainSize = Engine.GetTerrainHeightmapSize()
    local plans = {}
    local plannedArmies = {}
    for armyId, army in pairs(Armies) do
        local faction = factions[army.faction]
        local tpId = faction and faction.initialUnit
        if not army.lobbyOptions.isEmptySlot and scoArrivalIds[tpId]
            and gameUtils.GetMarker(army.name, "Spawn", true) then
            local position = gameUtils.MarkerToPosition(army.name, "Spawn")
            local x = math.clamp(position.x, 0, terrainSize.x - 2)
            local z = math.clamp(position.z, 0, terrainSize.y - 2)
            local y = position.y
            if y == 0 then
                y = placement.GetPlacementHeight(__Templates.Units[tpId], x, z)
            end
            local plan = {armyId=armyId, tpId=tpId, position={x=x, y=y, z=z}}
            plans[#plans + 1] = plan
            plannedArmies[armyId] = plan
        end
    end
    if #plans == 0 then
        return gameUtils.SpawnInitialUnits()
    end
    table.sort(plans, function(first, second) return first.armyId < second.armyId end)
    local startTick = Engine.GetSimulationTick()
    local clients = {}
    -- Observers have no arrival camera and must not hold gameplay startup.
    for clientId, player in pairs(scoArrivalLobby.Players) do
        if player.playerType == PlayerType.Player then clients[clientId] = true end
    end
    if next(clients) == nil then return gameUtils.SpawnInitialUnits() end
    local state = {
        startTick = startTick,
        phase = "pan",
        clients = clients,
        ready = {},
        units = plans,
        savedUnits = {},
        gameUtils = gameUtils,
        plannedArmies = plannedArmies,
    }
    scoArrivalState = state
    -- ExecuteClientFunction and CreateUnit share the ordered host-command channel.
    local beginSucceeded, beginError = pcall(scoArrivalSend, "SCOCommanderArrivalBegin", state)
    if not beginSucceeded then
        scoArrivalState = nil
        error(beginError)
    end
    Engine.Warn("[SCOM Arrival] Waiting for every client's rendered camera pan.")
end

local function scoArrivalSpawnUnits(state)
    state.spawned = true
    state.phase = "teleport"
    state.effectTick = Engine.GetSimulationTick()
    state.ready = {}
    local stockCreateUnit = _G.CreateUnit
    _G.CreateUnit = function(armyId, tpId, position, orientation, ...)
        local plan = state.plannedArmies[armyId]
        if plan and plan.tpId == tpId and not plan.unitId then
            -- Imported ACUs face +Z; the unchanged arrival camera ends on -Z.
            orientation = Engine.QuaternionAxisAngle(EngineClasses.float3(0, 1, 0), math.pi)
        end
        local unit = stockCreateUnit(armyId, tpId, position, orientation, ...)
        if plan and plan.tpId == tpId and not plan.unitId then
            plan.unitId = {index=unit.id.index, version=unit.id.version}
            local position = unit:GetPosition()
            plan.position = {x=position.x, y=position.y, z=position.z}
            state.savedUnits[#state.savedUnits + 1] = {
                unit=unit,
                canTakeDamage=unit.canTakeDamage,
                canBeKilled=unit.canBeKilled,
                isTargetable=unit.isTargetable,
            }
            unit.canTakeDamage = false
            unit.canBeKilled = false
            unit.isTargetable = false
        end
        return unit
    end
    local success, result = pcall(state.gameUtils.SpawnInitialUnits)
    _G.CreateUnit = stockCreateUnit
    if not success then
        scoArrivalRestore(state)
        scoArrivalState = nil
        pcall(scoArrivalSend, "SCOCommanderArrivalCancel", state)
        error(result)
    end
    local cohort = {}
    for _, plan in ipairs(state.units) do
        if plan.unitId then cohort[#cohort + 1] = plan end
    end
    state.units = cohort
    if #cohort == 0 then
        scoArrivalState = nil
        scoArrivalSend("SCOCommanderArrivalCancel", state)
        if state.startPending then scoArrivalStockStart() end
        if state.survivalPending then
            Import("host/survival/survival.lua").TryStartSurvival()
        end
    else
        local bindSucceeded, bindError = pcall(scoArrivalSend, "SCOCommanderArrivalBind", state)
        if not bindSucceeded then
            scoArrivalRestore(state)
            scoArrivalState = nil
            pcall(scoArrivalSend, "SCOCommanderArrivalCancel", state)
            error(bindError)
        end
        Engine.Warn("[SCOM Arrival] Commanders created after all camera pans; teleport started.")
    end
    return result
end

function Start()
    if scoArrivalState then
        scoArrivalState.startPending = true
        return
    end
    return scoArrivalStockStart()
end

function SCOStartSurvival()
    if scoArrivalState then
        scoArrivalState.survivalPending = true
        return
    end
    return Import("host/survival/survival.lua").TryStartSurvival()
end

function SCOHoldCommanderArrival()
    local state = scoArrivalState
    if not state then return false end
    -- Rendering acknowledgments and disconnects must be consumed while gameplay
    -- is held. Simulation catch-up alone can never finish either visible phase.
    Import("host/commands.lua").ProcessClientCommands()
    if not scoArrivalAllReady(state) then
        Import("host/managers/intel/intelManager.lua").UpdateIntel()
        return true
    end
    if not state.spawned then
        scoArrivalSpawnUnits(state)
        if scoArrivalState ~= state then return false end
        Import("host/managers/intel/intelManager.lua").UpdateIntel()
        return true
    end
    -- Intel continues to own fog/cloak masks while gameplay updates are held.
    Import("host/managers/intel/intelManager.lua").UpdateIntel()
    state.releaseTick = Engine.GetSimulationTick()
    state.phase = "released"
    scoArrivalRestore(state)
    scoArrivalState = nil
    local released, releaseError = pcall(function()
        scoArrivalSend("SCOCommanderArrivalReveal", state)
        scoArrivalSend("SCOCommanderArrivalRelease", state)
    end)
    if not released then
        pcall(scoArrivalSend, "SCOCommanderArrivalCancel", state)
    end
    if state.startPending then scoArrivalStockStart() end
    if state.survivalPending then
        Import("host/survival/survival.lua").TryStartSurvival()
    end
    if not released then error(releaseError) end
    Engine.Warn("[SCOM Arrival] Teleport presentation complete for all clients; gameplay released.")
    return false
end
