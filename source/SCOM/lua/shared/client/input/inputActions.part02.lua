
-- Sanctuary Construction Plans 2.1.0
-- Always let inputSystem update its pressed/released state. Routing
-- exclusivity lives in inputEventsFunctions, not in event consumption.
InputActions.MouseControls.MouseLeftClick.defaultActions.press =
    function()
        Import("client/inputEventsFunctions.lua").OnMouseLeftDown()
        return false
    end
InputActions.MouseControls.MouseLeftClick.defaultActions.release =
    function()
        Import("client/inputEventsFunctions.lua").OnMouseLeftUp()
        return false
    end
InputActions.MouseControls.MouseRightClick.defaultActions.press =
    function()
        Import("client/inputEventsFunctions.lua").OnMouseRightDown()
        return false
    end
InputActions.MouseControls.MouseRightClick.defaultActions.release =
    function()
        Import("client/inputEventsFunctions.lua").OnMouseRightUp()
        return false
    end

InputActions.ConstructionPlans = {
    Priority = 11,
    CapturePlan = {
        defaultActions = {
            press = function()
                local SelectionSystem = Import("client/input/selectionSystem.lua")
                local Blueprints = Import("client/ui/scoBlueprints.lua")
                local saved = Blueprints.CaptureDefaultPlan(SelectionSystem.GetSelectedUnits())
                if saved then
                    Import("client/ui/uiManager.lua").SetUIDirty()
                end
                return saved
            end,
        },
        uiDescription = "Capture Construction Plan",
        uiCategory = "Construction",
        defaultHotkeys = { "Shift-T" },
    },
}

local SCO_PlanHotkeys = {
    "Alt-Digit1",
    "Alt-Digit2",
    "Alt-Digit3",
    "Alt-Digit4",
    "Alt-Digit5",
    "Alt-Digit6",
    "Alt-Digit7",
    "Alt-Digit8",
}
local function SCO_CreatePlacePlanAction(planSlot)
    return function()
        local SelectionSystem = Import("client/input/selectionSystem.lua")
        local Blueprints = Import("client/ui/scoBlueprints.lua")
        Blueprints.ActivatePlanSlot(planSlot, SelectionSystem.GetSelectedUnits())
        return true
    end
end
for slot, hotkey in ipairs(SCO_PlanHotkeys) do
    InputActions.ConstructionPlans["PlacePlan" .. slot] = {
        defaultActions = {
            press = SCO_CreatePlacePlanAction(slot),
        },
        uiDescription = "Place Construction Plan " .. slot,
        uiCategory = "Construction",
        defaultHotkeys = { hotkey },
    }
end
-- SCOM Field Fixes 1.1.0 - Escape cancels all SCOM targeting before menus.
local SCOFieldFixStrategicSiloEscapeEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOFieldFixStrategicSiloEscapeMarker = rawget(
    SCOFieldFixStrategicSiloEscapeEnvironment,
    "SCO_FieldFixStrategicSiloEscapeInputInstalled")
if SCOFieldFixStrategicSiloEscapeMarker ~= nil
    and SCOFieldFixStrategicSiloEscapeMarker ~= "1.1.0"
then
    error("Unsupported SCOM strategic silo Escape marker "
        .. tostring(SCOFieldFixStrategicSiloEscapeMarker))
end
if SCOFieldFixStrategicSiloEscapeMarker == nil then
    local action = InputActions
        and InputActions.GameMenu
        and InputActions.GameMenu.TogglePauseMenu
        and InputActions.GameMenu.TogglePauseMenu.defaultActions
    if type(action) ~= "table" or type(action.press) ~= "function" then
        error("SCOM strategic silo Escape hook could not resolve pause-menu action")
    end
    local SCOInputPauseMenuPress = action.press
    action.press = function(...)
        local cancelled = false
        local cancelStrategic = _G.SCO_CancelStrategicSiloTargetMode
        if type(cancelStrategic) == "function"
            and cancelStrategic("escape") == true
        then
            cancelled = true
        end
        local cancelCommander = _G.SCO_CommanderAbilityTargetInputCancel
        if type(cancelCommander) == "function"
            and cancelCommander("escape") == true
        then
            cancelled = true
        end
        if cancelled then return end
        return SCOInputPauseMenuPress(...)
    end

    rawset(
        SCOFieldFixStrategicSiloEscapeEnvironment,
        "SCO_FieldFixStrategicSiloEscapeInputInstalled",
        "1.1.0")
    _G.SCO_FieldFixStrategicSiloEscapeInputInstalled = "1.1.0"
end
InputActions.SourceCargo = {
    UnloadCargo = {
        defaultActions = {press=function() Import("client/inputEventsFunctions.lua").SCOUnloadSelectedCargo(true) end},
        uiDescription="Choose transport unload destination", uiCategory="Orders", defaultHotkeys={"Ctrl-Shift-U"},
    },
}
local SCOCargoEscape=InputActions.GameMenu.TogglePauseMenu.defaultActions.press
InputActions.GameMenu.TogglePauseMenu.defaultActions.press=function(...)
    if Import("client/inputEventsFunctions.lua").SCOUnloadSelectedCargo("cancel") then return end
    return SCOCargoEscape(...)
end
