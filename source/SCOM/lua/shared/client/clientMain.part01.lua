local DebugUI = Import("client/ui/debugUI.lua")
local ClientListeners = Import("client/clientListeners.lua").functions
local SamplingProfiler = Import("common/systems/samplingProfiler.lua")

_G.Client = {}

--- Set up basic client things
function Init()
    Log("InitClient")

    Import("client/input/inputSystem.lua")

    _G.OnDebugSpawnButtonClicked = DebugUI.OnDebugSpawnButtonClicked
    _G.OnDebugSpawnGroupButtonClicked = DebugUI.OnDebugSpawnGroupButtonClicked

    -- Registers calls from clients
    for name, func in pairs(ClientListeners) do
        RegisterListener("client_" .. name, func)
    end

    Import("client/survival/survival.lua")
end

-- Start the client
function Start()
    assert(GameInfo.MapInfo ~= nil)
    DebugUI.FillUIButtons()
    Engine.HideUIDebug()
    Engine.HideProfilerUI()
    Import("client/audio/audioManager.lua").Start()
    Import("client/rendering/rendering.lua").Start()
end

function _G.OnRenderUpdate()

    _G.Tick = Engine.GetSimulationTick()
    _G.Time = Engine.GetSimulationTime()

    local inputSystem = Import("client/input/inputSystem.lua")
    inputSystem.UpdateInputs()

    local cameraController = Import("client/input/cameraController.lua")
    cameraController.Update()

    local mouseCursor = Import("client/input/mouseCursor.lua")
    mouseCursor.UpdateMouseRayCastPosition()

    local engineUIEventManager = Import("client/ui/engineUIEventManager.lua")
    engineUIEventManager.FireUIEvents()

    Import("client/ui/panels.lua").ChatPanel.Update()
    Import("client/ui/panels.lua").PausePanel.Update()
    Import("client/ui/panels.lua").PlayerListPanel.Update()

    local selectionSystem = Import("client/input/selectionSystem.lua")
    selectionSystem.UpdateSelectionSystem()

    -- Should be ran after selection system.
    local uiManager = Import("client/ui/uiManager.lua")
    uiManager.UpdateUI()

    local constructionPreviewSystem = Import("client/input/constructionPreviewSystem.lua")
    constructionPreviewSystem.UpdateConstructionPreview()
    
    local dragFormationPreviewSystem = Import("client/input/dragFormationPreviewSystem.lua")
    dragFormationPreviewSystem.UpdateDragFormationPreview()

    local unitsUpdate = Import("client/units/unitsUpdate.lua")
    unitsUpdate.RenderUpdateUnits()

    local rendering = Import("client/rendering/rendering.lua")
    rendering.RenderUpdate()

    local clientBeamManager = Import("client/entities/beams/clientBeamManager.lua")
    clientBeamManager.UpdateBeams()

    local audioManager = Import("client/audio/audioManager.lua")
    audioManager.Update()

    ThreadsDispatcherUpdate()

    SamplingProfiler.NotifyLeavingLua()
end

--- Called from engine each tick.
-- This is the place to set what order things should be updated in.
function _G.OnSimulationTickUpdate()
    ProcessFileEvents()
    _G.Tick = Engine.GetSimulationTick()
    _G.Time = Engine.GetSimulationTime()

    local commands = Import("client/commands.lua")
    commands.ProcessHostCommands()

    local unitsUpdate = Import("client/units/unitsUpdate.lua")
    unitsUpdate.UpdateUnits()

    local orderManager = Import("client/managers/orders/clientOrderManager.lua")
    orderManager.Update()

    -- if _G.Tick == 0 then
    --     --Uncomment to test adjaceny connectors and visual markers in the game.
    --     Import("client/tests/BeamTests.lua").RunTest()
    --     -- Import("client/tests/AdjacencyConnectorTests.lua").RunTest()
    --     -- Import("client/tests/OrderLineNodeTests.lua").RunTest()
    --     -- Import("client/tests/VisualMarkerTests.lua").RunTest()
    -- end

    -- Run all lua threads
    ThreadsDispatcherUpdate()

    SamplingProfiler.NotifyLeavingLua()

    --local simplifiedUnits = table.deepCopyExcept(__Entities.Units, { "tp", "weapons", "progressBars", " constructionProgressBar", "healthProgressBar", "icons", "rangeRings", "orderState", "simOrderState" })
    --Log("SuperLog: " .. repr(simplifiedUnits))
end

--- Called from engine at the end of each tick.
function _G.OnSimulationTickEnd()

    _G.Tick = Engine.GetSimulationTick()
    _G.Time = Engine.GetSimulationTime()

    -- Cleanup any lua threads for this tick.
    ThreadDispatcherFlush()

    SamplingProfiler.NotifyLeavingLua()
end
