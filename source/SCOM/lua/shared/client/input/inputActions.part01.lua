--could be like 450+ different entries in here when its all finished
--devs can create new hotkey actions by only editing this file

InputActions = {} --all the possible actions that can be set to hotkeys

-----------------------------
-- Debug of the input system
-----------------------------

--[[
-- UNCOMMENT TO SHOW HOTKEY CLASH ERRORS ON PLAY TO DEBUG THE INPUT SYSTEM

InputActions.inputSystemDebug = {
    debugLogInputsTwo = {
        defaultActions = { press = function() Warn("breadinput debugLogInputsTwo") end, },--import something
        uiDescription = "Description for what the key does goes here",
        uiCategory = "Debug", --not the same as the game categories?
        defaultHotkeys = {"Ctrl-Shift-L","Ctrl-L"},
    },
    debugLogInputsMultipleActions = {
        defaultActions = {
            press = function() Warn("breadinput debug press") end,
            release = function() Warn("breadinput debug release") end,
            doublePress = function() Warn("breadinput debug doublepress") end,
            valueChange = function() Warn("breadinput debug valueChange") end,
        },--import something
        uiDescription = "Description for what the key does goes here",
        uiCategory = "Debug", --not the same as the game categories?
        defaultHotkeys = {"Ctrl-E","Ctrl-Shift-E"},
    },
    debugLogInputsClashSameGroup = {
        defaultActions = { press = function() Warn("breadinput debugLogInputsClashSameGroup") end, },--import something
        uiDescription = "Description for what the key does goes here",
        uiCategory = "Debug", --not the same as the game categories?
        defaultHotkeys = {"Ctrl-Shift-L","Ctrl-L"},
    },
}

InputActions.inputSystemDebugClashDifferentGroup = {
    debugLogInputs = {
        defaultActions = { press = function() Warn("breadinput inputSystemDebugClashDifferentGroup") end, },--import something
        uiDescription = "Description for what the key does goes here",
        uiCategory = "Debug", --not the same as the game categories?
        defaultHotkeys = {"Ctrl-Shift-L","Ctrl-L"},
    },
}
--]]


-----------------------------
-- MouseControls
-----------------------------



InputActions.MouseControls = {
    UpdateMousePositionX = {
        defaultActions = { valueChange = function(eventValue) Import("client/input/mouseCursor.lua").SetMousePositionX(eventValue) end, },
        uiDescription = "Set the mouse X position in screen pixels",
        uiCategory = "Mouse",
        defaultHotkeys = {"AnyModifier-PositionX"},
    },
    UpdateMousePositionY = {
        defaultActions = { valueChange = function(eventValue) Import("client/input/mouseCursor.lua").SetMousePositionY(eventValue) end, },
        uiDescription = "Set the mouse Y position in screen pixels",
        uiCategory = "Mouse",
        defaultHotkeys = {"AnyModifier-PositionY"},
    },

-----------------------------
-- WIP mouse buttons implementation - needs to be redone
-----------------------------


    MouseLeftClick = {
        defaultActions = {
            press = function() Import("client/inputEventsFunctions.lua").OnMouseLeftDown() end,
            release = function() Import("client/inputEventsFunctions.lua").OnMouseLeftUp() end,
        },
        uiDescription = "Mouse left button",
        uiCategory = "Mouse",
        defaultHotkeys = {"AnyModifier-LeftButton"},
    },
    MouseRightClick = {
        defaultActions = {
            press = function() Import("client/inputEventsFunctions.lua").OnMouseRightDown() end,
            release = function() Import("client/inputEventsFunctions.lua").OnMouseRightUp() end,
        },
        uiDescription = "Mouse Right button",
        uiCategory = "Mouse",
        defaultHotkeys = {"AnyModifier-RightButton"},
    },
}

-----------------------------
-- Debug Controls - simple events
-----------------------------

InputActions.DebugControls = {
    -- QuickDebugEvent0 = {
    --     defaultActions = { press = function() SendToHost("OnAlpha0", "SimpleEvent") end, },
    --     uiDescription = "Send a simple event to the host",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-Digit0"},
    -- },
    -- QuickDebugEvent1 = {
    --     defaultActions = { press = function() end, },
    --     uiDescription = "Empty",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-Digit1"},
    -- },
    -- QuickDebugEvent2 = {
    --     defaultActions = { press = function() SendToHost("OnAlpha2", "SimpleEvent") end, },
    --     uiDescription = "Send a simple event to the host",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-Digit2"},
    -- },
    -- QuickDebugEvent3 = {
    --     defaultActions = { press = function() SendToHost("OnAlpha3", "SimpleEvent") end, },
    --     uiDescription = "Send a simple event to the host",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-Digit3"},
    -- },
    -- QuickDebugEvent4 = {
    --     defaultActions = { press = function() SendToHost("OnAlpha4", "SimpleEvent") end, },
    --     uiDescription = "Send a simple event to the host",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-Digit4"},
    -- },
    -- QuickDebugEvent5 = {
    --     defaultActions = { press = function() SendToHost("OnAlpha5", "SimpleEvent") end, },
    --     uiDescription = "Send a simple event to the host",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-Digit5"},
    -- },
    -- QuickDebugEvent6 = {
    --     defaultActions = { press = function() SendToHost("OnAlpha6", "SimpleEvent") end, },
    --     uiDescription = "Send a simple event to the host",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-Digit6"},
    -- },
    -- QuickDebugEvent7 = {
    --     defaultActions = { press = function() SendToHost("OnAlpha7", "SimpleEvent") end, },
    --     uiDescription = "Send a simple event to the host",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-Digit7"},
    -- },
    -- QuickDebugEvent8 = {
    --     defaultActions = { press = function() SendToHost("OnAlpha8", "SimpleEvent") end, },
    --     uiDescription = "Send a simple event to the host",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-Digit8"},
    -- },
    -- QuickDebugEvent9 = {
    --     defaultActions = { press = function() SendToHost("OnAlpha9", "SimpleEvent") end, },
    --     uiDescription = "",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-Digit9"},
    -- },

-----------------------------
-- Scenario Controls
-----------------------------

    -- DebugScenario01 = {
    --     defaultActions = { press = function() Import("client/simpleEvents.lua").StartShowcase() end, },
    --     uiDescription = "Start showcase",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-E"},
    -- },
    -- DebugScenario02 = {
    --     defaultActions = { press = function() Import("client/simpleEvents.lua").ToggleBigBattle() end, },
    --     uiDescription = "Toggle big battle",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-R"},
    -- },
    -- DebugScenario03 = {
    --     defaultActions = { press = function() Import("client/simpleEvents.lua").SpawnAllUnits() end, },
    --     uiDescription = "Spawn all units",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-T"},
    -- },

    -- CycleFocusArmy = {
    --     defaultActions = { press = function() Import("client/inputEventsFunctions.lua").CycleFocusArmy() end, },
    --     uiDescription = "Cycle focus army",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-P"},
    -- },

    -- NineDebug1 = {
    --     defaultActions = { press = function() Import("client/managers/orders/clientOrderManager.lua").DebugNine1() end, },
    --     uiDescription = "Debug nine",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-B"},
    -- },
    -- NineDebug2 = {
    --     defaultActions = { press = function() Import("client/managers/orders/clientOrderManager.lua").DebugNine2() end, },
    --     uiDescription = "Debug nine",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-N"},
    -- },

-----------------------------
-- Unit Controls
-----------------------------

    DestroySelectedUnits = {
        defaultActions = { press = function() Import("client/simpleEvents.lua").DestroySelectedUnits() end, },
        uiDescription = "Destroy selected units",
        uiCategory = "Debug",
        defaultHotkeys = {"Delete"},
    },
    DeleteSelectedUnits = {
        defaultActions = { press = function() Import("client/simpleEvents.lua").DeleteSelectedUnits() end, },
        uiDescription = "Delete selected units",
        uiCategory = "Debug",
        defaultHotkeys = {"Ctrl-Delete"},
    },
    -- TeleportSelectedUnits = {
    --     defaultActions = { press = function() Import("client/simpleEvents.lua").TeleportUnits() end, },
    --     uiDescription = "Teleport selected units",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-T"},
    -- },
    -- CopySelectedUnits = {
    --     defaultActions = { press = function() Import("client/simpleEvents.lua").CopySelectedUnits() end, },
    --     uiDescription = "Copy selected units",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-C"},
    -- },
    -- PasteBufferedUnits = {
    --     defaultActions = { press = function() Import("client/simpleEvents.lua").PasteBufferedUnits() end, },
    --     uiDescription = "Paste buffered units",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-V"},
    -- },

-----------------------------
-- Rendering toggles
-----------------------------

    ToggleStrategicIcons = {
        defaultActions = { press = function() Import("client/rendering/rendering.lua").ToggleIcons() end, },
        uiDescription = "Toggle icons",
        uiCategory = "Debug",
        defaultHotkeys = {"Ctrl-Shift-I"},
    },
    ToggleProgressBars = {
        defaultActions = { press = function() Engine.ToggleProgressBars() end, },
        uiDescription = "Toggle progress bars",
        uiCategory = "Debug",
        defaultHotkeys = {"Ctrl-Shift-B"},
    },
    ToggleSoundMute = {
        defaultActions = { press = function() Engine.ToggleSoundMute() end, },
        uiDescription = "Toggle sound mute",
        uiCategory = "Debug",
        defaultHotkeys = {"Ctrl-Alt-M"},
    },
    ToggleUIHUD = {
        defaultActions = { press = function() Engine.ToggleUIHUD() end, },
        uiDescription = "Toggle UI HUD",
        uiCategory = "Debug",
        defaultHotkeys = {"Ctrl-Alt-F2"},
    },
    -- ToggleUIDebug = {
    --     defaultActions = { press = function() Engine.ToggleUIDebug() end, },
    --     uiDescription = "Toggle UI debug",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-Alt-F3"},
    -- },
    DebugToggleProfilerUI = {
        defaultActions = { press = function() Engine.ToggleProfilerUI() end, },
        uiDescription = "Toggle profilers UI",
        uiCategory = "Debug",
        defaultHotkeys = {"Ctrl-Alt-F1"},
    },

-----------------------------
-- Debug Groups
-----------------------------
    -- DebugSaveUnitGroup = {
    --     defaultActions = { press = function() Import("client/ui/debugUI.lua").LuaBreadUIClientSaveGroup() end, },
    --     uiDescription = "Save selected units to a group",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-S"},
    -- },
    -- DebugDeleteUnitGroup = {
    --     defaultActions = { press = function() Import("client/ui/debugUI.lua").LuaBreadUIClientDeleteGroup() end, },
    --     uiDescription = "Delete group by name",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-D"},
    -- },
    -- DebugUpdateUnitGroup = {
    --     defaultActions = { press = function() Import("client/ui/debugUI.lua").LuaBreadUIClientUpdateGroup() end, },
    --     uiDescription = "Update group by name with selected units",
    --     uiCategory = "Debug",
    --     defaultHotkeys = {"Ctrl-F"},
    -- },
    SimSpeedUp = {
        defaultActions = { press = function() Import("client/simpleEvents.lua").IncreaseSimSpeed() end, },
        uiDescription = "Increase simulation speed by 1",
        uiCategory = "Debug",
        defaultHotkeys = {"AnyModifier-PageUp"},
    },
    SimSpeedDown = {
        defaultActions = { press = function() Import("client/simpleEvents.lua").DecreaseSimSpeed() end, },
        uiDescription = "Decrease simulation speed by 1",
        uiCategory = "Debug",
        defaultHotkeys = {"AnyModifier-PageDown"},
    },

}

-----------------------------
-- Orders
-----------------------------

InputActions.Orders = {
    Overcharge = {
        defaultActions = { press = function()
            local activate = rawget(_G, "SCO_ActivateSelectedOvercharge")
            return type(activate) == "function" and activate() == true
        end },
        uiDescription = "Overcharge: select an enemy target",
        uiCategory = "Orders",
        defaultHotkeys = { "O" },
    },
    Priority = 5,
    ToggleAppend = { --this is going to be a mess - needs cleaning up in a proper order mode later
        defaultActions = {
            press = function() 
                -- TODO: These are seperate actions. But currently it seems like the input system does not handle actions with different hotkeys.
                Import("client/inputEventsFunctions.lua").SetAppendOrderToggle(true)
                Import("client/inputEventsFunctions.lua").SetOrdersVisibile(true)
            end,
            release = function() 
                -- TODO: These are seperate actions. But currently it seems like the input system does not handle actions with different hotkeys.
                Import("client/inputEventsFunctions.lua").SetAppendOrderToggle(false)
                Import("client/inputEventsFunctions.lua").SetOrdersVisibile(false)
            end,
        },
        uiDescription = "Toggle append order",
        uiCategory = "Orders",
        defaultHotkeys = {"Shift", "Alt-Shift"},
    },
    ToggleAlt = { --this is going to be a mess - needs cleaning up in a proper order mode later
        defaultActions = {
            press = function() 
                Import("client/inputEventsFunctions.lua").SetAltToggle(true)
            end,
            release = function() 
                Import("client/inputEventsFunctions.lua").SetAltToggle(false)
            end,
        },
        uiDescription = "Toggle append order",
        uiCategory = "Orders",
        defaultHotkeys = {"Alt", "Shift-Alt"},
    },
    OrderStop = {
        defaultActions = { press = function() Import("client/inputEventsFunctions.lua").IssueClearOrder() end, },
        uiDescription = "Clear order queue",
        uiCategory = "Orders",
        defaultHotkeys = {"H","Shift-H"},
    },
    OrderAttack = {
        defaultActions = { press = function() Import("client/inputEventsFunctions.lua").IssueAttackOrder() end, },
        uiDescription = "Attack",
        uiCategory = "Orders",
        defaultHotkeys = {"A","Shift-A"},
    },
    OrderAttackMove = {
        defaultActions = { press = function() Import("client/inputEventsFunctions.lua").IssueAttackMoveOrder() end, },
        uiDescription = "AttackMove",
        uiCategory = "Orders",
        defaultHotkeys = {"F","Shift-F"},
    },
    OrderRepair = {
        defaultActions = { press = function() Import("client/inputEventsFunctions.lua").IssueRepairOrder() end, },
        uiDescription = "Repair",
        uiCategory = "Orders",
        defaultHotkeys = {"G","Shift-G"},
    },
    OrderAssist = {
        defaultActions = { press = function() Import("client/inputEventsFunctions.lua").IssueAssistOrder() end, },
        uiDescription = "Assist",
        uiCategory = "Orders",
        defaultHotkeys = {"I","Shift-I"},
    },
    OrderReclaim = {
        defaultActions = { press = function() Import("client/inputEventsFunctions.lua").IssueReclaimOrder() end, },
        uiDescription = "Reclaim",
        uiCategory = "Orders",
        defaultHotkeys = {"V","Shift-V"},
    },
    OrderCapture = {
        defaultActions = { press = function() Import("client/inputEventsFunctions.lua").IssueCaptureOrder() end, },
        uiDescription = "Capture",
        uiCategory = "Orders",
        defaultHotkeys = {"Z","Shift-Z"},
    },
    OrderDash = {
        defaultActions = { press = function() Import("client/inputEventsFunctions.lua").IssueDashOrder() end, },
        uiDescription = "Dash",
        uiCategory = "Orders",
        defaultHotkeys = {"J","Shift-J"},
    },
    OrderPatrol = {
        defaultActions = { press = function() Import("client/inputEventsFunctions.lua").BeginPatrolOrder() end, },
        uiDescription = "Patrol selected units (P, then left-click; hold Shift for multiple waypoints)",
        uiCategory = "Orders",
        defaultHotkeys = {"Alt-P", "Alt-Shift-P"},
    },
    TogglePause = {
        defaultActions = { press = function() Import("client/inputEventsFunctions.lua").TogglePauseUnits() end, },
        uiDescription = "Toggle pause on selected units",
        uiCategory = "Orders",
        defaultHotkeys = {"P"},
    },
    ToggleSubmerge = {
        defaultActions = { press = function() Import("client/inputEventsFunctions.lua").ToggleSubmergeSelected() end, },
        uiDescription = "Submerge / surface selected submarines",
        uiCategory = "Orders",
        defaultHotkeys = {"U"},
    },
}

-----------------------------
-- Construction
-----------------------------

InputActions.Construction = {
    Priority = 10,
    HotkeyW = {
        defaultActions = { press = function() return Import("client/ui/constructionPanel.lua").TriggerConstructionHotkey("W") end, },
        uiDescription = "Land Factory / Engineer Unit",
        uiCategory = "Construction",
        defaultHotkeys = {"W", "Shift-W"},
    },
    HotkeyE = {
        defaultActions = { press = function() return Import("client/ui/constructionPanel.lua").TriggerConstructionHotkey("E") end, },
        uiDescription = "Engineering Station / Scout",
        uiCategory = "Construction",
        defaultHotkeys = {"E", "Shift-E"},
    },
    HotkeyS = {
        defaultActions = { press = function() return Import("client/ui/constructionPanel.lua").TriggerConstructionHotkey("S") end, },
        uiDescription = "Alloy Well",
        uiCategory = "Construction",
        defaultHotkeys = {"S", "Shift-S"},
    },
    HotkeyD = {
        defaultActions = { press = function() return Import("client/ui/constructionPanel.lua").TriggerConstructionHotkey("D") end, },
        uiDescription = "Energy Generator",
        uiCategory = "Construction",
        defaultHotkeys = {"D", "Shift-D"},
    },
    HotkeyX = {
        defaultActions = { press = function() return Import("client/ui/constructionPanel.lua").TriggerConstructionHotkey("X") end, },
        uiDescription = "Point Defense",
        uiCategory = "Construction",
        defaultHotkeys = {"X", "Shift-X"},
    },
    HotkeyC = {
        defaultActions = { press = function() return Import("client/ui/constructionPanel.lua").TriggerConstructionHotkey("C") end, },
        uiDescription = "Anti-Air Defense",
        uiCategory = "Construction",
        defaultHotkeys = {"C", "Shift-C"},
    },
    HotkeyR = {
        defaultActions = { press = function() return Import("client/ui/constructionPanel.lua").TriggerConstructionHotkey("R") end, },
        uiDescription = "Radar / Tank",
        uiCategory = "Construction",
        defaultHotkeys = {"R", "Shift-R"},
    },
    HotkeyY = {
        defaultActions = { press = function() return Import("client/ui/constructionPanel.lua").TriggerConstructionHotkey("Y") end, },
        uiDescription = "Anti-Air Unit",
        uiCategory = "Construction",
        defaultHotkeys = {"Y", "Shift-Y"},
    },
    HotkeyM = {
        defaultActions = { press = function() return Import("client/ui/constructionPanel.lua").TriggerConstructionHotkey("M") end, },
        uiDescription = "Upgrade Structure",
        uiCategory = "Construction",
        defaultHotkeys = {"M", "Shift-M"},
    },
}

-----------------------------
-- Control Groups
-----------------------------

InputActions.ControlGroups = {}

for digit = 0, 9 do
    local digitKey = "Digit" .. digit

    InputActions.ControlGroups["SaveControlGroup" .. digit] = {
        defaultActions = { press = function() Import("client/input/controlGroups.lua").SaveControlGroup(digit) end, },
        uiDescription = "Save the selected units to control group " .. digit,
        uiCategory = "Control Groups",
        defaultHotkeys = {"Ctrl-" .. digitKey},
    }
    InputActions.ControlGroups["AppendControlGroup" .. digit] = {
        defaultActions = { press = function() Import("client/input/controlGroups.lua").AppendToControlGroup(digit) end, },
        uiDescription = "Add the selected units to control group " .. digit,
        uiCategory = "Control Groups",
        defaultHotkeys = {"Shift-" .. digitKey},
    }
    InputActions.ControlGroups["SelectControlGroup" .. digit] = {
        defaultActions = {
            press = function() Import("client/input/controlGroups.lua").SelectControlGroup(digit) end,
            doublePress = function() Import("client/input/controlGroups.lua").FocusCameraOnControlGroup(digit) end,
        },
        uiDescription = "Select control group " .. digit .. ", double tap to fit the camera to it",
        uiCategory = "Control Groups",
        defaultHotkeys = {digitKey},
    }
end

-----------------------------
-- Camera Controls
-----------------------------


InputActions.cameraControls = {
    cameraZoom = {
        defaultActions = {
            valueChange = function(eventValue) Import("client/input/cameraController.lua").SetZoomAmount(eventValue) end,
        },
        uiDescription = "Zoom the camera",
        uiCategory = "Camera", --not the same as the game categories?
        defaultHotkeys = {"AnyModifier-ScrollUpDown"},
    },
    cameraToggleFreeCamera = {
        defaultActions = {
            press = function() Import("client/input/cameraController.lua").ToggleFreeCamera() end,
        },
        uiDescription = "Toggle free camera",
        uiCategory = "Camera", --not the same as the game categories?
        defaultHotkeys = {"AnyModifier-End"},
    },
    cameraResetController = {
        defaultActions = {
            press = function() Import("client/input/cameraController.lua").RestartCamera() end,
        },
        uiDescription = "Reset camera controller",
        uiCategory = "Camera", --not the same as the game categories?
        defaultHotkeys = {"AnyModifier-Home"},
    },
    cameraRotateDeltaX = {
        defaultActions = {
            valueChange = function(eventValue) Import("client/input/cameraController.lua").AddRotationDeltaX(eventValue) end,
        },
        uiDescription = "Add camera mouse rotation horizontal amount",
        uiCategory = "Camera",
        defaultHotkeys = {"AnyModifier-DeltaX"},
    },
    cameraRotateDeltaY = {
        defaultActions = {
            valueChange = function(eventValue) Import("client/input/cameraController.lua").AddRotationDeltaY(eventValue) end,
        },
        uiDescription = "Add camera mouse rotation vertical amount",
        uiCategory = "Camera",
        defaultHotkeys = {"AnyModifier-DeltaY"},
    },
    cameraSetCameraRotation = {
        defaultActions = {
            press = function() Import("client/input/cameraController.lua").SetCameraRotation(true) end,
            release = function() Import("client/input/cameraController.lua").SetCameraRotation(false) end,
        },
        uiDescription = "Toggle camera rotation",
        uiCategory = "Camera", --not the same as the game categories?
        defaultHotkeys = {"AnyModifier-Space"},
    },
    cameraSetCameraPan = {
        defaultActions = {
            press = function() Import("client/input/cameraController.lua").SetCameraPan(true) end,
            release = function() Import("client/input/cameraController.lua").SetCameraPan(false) end,
        },
        uiDescription = "Toggle camera pan",
        uiCategory = "Camera", --not the same as the game categories?
        defaultHotkeys = {"AnyModifier-MiddleButton"},
    },
    --cameraToggleLockOnToTarget = { --engine function is bugged - 2024-10-28
    --    defaultActions = {
    --        press = function() Warn("breadinput cameraToggleLockOnToTarget toggle") Engine.CameraToggleLockOnToTarget() end,
    --    },
    --    uiDescription = "Toggle lock on to target",
    --    uiCategory = "Camera", --not the same as the game categories?
    --    defaultHotkeys = {"Ctrl-F"},
    --},

    cameraPanLeft = {
        defaultActions = {
            press = function() Import("client/input/cameraController.lua").SetPanLeft(true) end,
            release = function() Import("client/input/cameraController.lua").SetPanLeft(false) end,
        },
        uiDescription = "Pan the camera to the left",
        uiCategory = "Camera", --not the same as the game categories?
        defaultHotkeys = {"AnyModifier-LeftArrow"},
    },
    cameraPanRight = {
        defaultActions = {
            press = function() Import("client/input/cameraController.lua").SetPanRight(true) end,
            release = function() Import("client/input/cameraController.lua").SetPanRight(false) end,
        },
        uiDescription = "Pan the camera to the right",
        uiCategory = "Camera", --not the same as the game categories?
        defaultHotkeys = {"AnyModifier-RightArrow"},
    },
    cameraPanUp = {
        defaultActions = {
            press = function() Import("client/input/cameraController.lua").SetPanUp(true) end,
            release = function() Import("client/input/cameraController.lua").SetPanUp(false) end,
        },
        uiDescription = "Pan the camera up",
        uiCategory = "Camera", --not the same as the game categories?
        defaultHotkeys = {"AnyModifier-UpArrow"},
    },
    cameraPanDown = {
        defaultActions = {
            press = function() Import("client/input/cameraController.lua").SetPanDown(true) end,
            release = function() Import("client/input/cameraController.lua").SetPanDown(false) end,
        },
        uiDescription = "Pan the camera down",
        uiCategory = "Camera", --not the same as the game categories?
        defaultHotkeys = {"AnyModifier-DownArrow"},
    },
}

-----------------------------
-- Chat
-----------------------------

InputActions.Chat = {
    OpenAllChat = {
        defaultActions = { press = function() Import("client/ui/panels.lua").ChatPanel.Open(ChatChannel.All) end, },
        uiDescription = "Write a message to everyone",
        uiCategory = "Chat",
        defaultHotkeys = {"Shift-Enter"},
    },
    OpenTeamChat = {
        defaultActions = { press = function() Import("client/ui/panels.lua").ChatPanel.Open(ChatChannel.Team) end, },
        uiDescription = "Write a message to your team",
        uiCategory = "Chat",
        defaultHotkeys = {"Enter"},
    },
}

-----------------------------
-- Game Menu
-----------------------------

InputActions.GameMenu = {
    TogglePauseMenu = {
        defaultActions = {
            press = function()
                Engine.UI_ToggleInGameMenuVisibility()
            end,
        },
        uiDescription = "Toggle the in game menu",
        uiCategory = "Game",
        defaultHotkeys = {"Escape"},
    },
    TogglePauseGame = {
        defaultActions = { press = function() Import("client/simpleEvents.lua").TogglePauseGame() end, },
        uiDescription = "Pause or resume the game",
        uiCategory = "Game",
        defaultHotkeys = {"F3"},
    },
}

-----------------------------
-- Selection input
-----------------------------

InputActions.Selection = {
    SelectCommander = {
        defaultActions = {
            press = function()
                local selectionSystem = Import("client/input/selectionSystem.lua")
                selectionSystem.SetSelectedEntities(selectionSystem.GetSelectableUnitsByTags(Tags.COMMAND))
            end,
        },
        uiDescription = "Select the commander unit",
        uiCategory = "Selection",
        defaultHotkeys = {"Ctrl-Comma"},
    },
    SelectAirMobile = {
        defaultActions = {
            press = function()
                local selectionSystem = Import("client/input/selectionSystem.lua")
                selectionSystem.SetSelectedEntities(selectionSystem.GetSelectableUnitsByTags(Tags.AIR * Tags.MOBILE))
            end,
        },
        uiDescription = "Select mobile air units",
        uiCategory = "Selection",
        defaultHotkeys = {"Ctrl-Period"},
    },
    SelectIdleEngineers = {
        defaultActions = {
            press = function()
                local selectionSystem = Import("client/input/selectionSystem.lua")
                local engineers = selectionSystem.GetSelectableUnitsByTags(Tags.ENGINEER * Tags.MOBILE)
                selectionSystem.SetSelectedEntities(selectionSystem.FilterUnitsByIdle(engineers))
            end,
        },
        uiDescription = "Select idle mobile engineers",
        uiCategory = "Selection",
        defaultHotkeys = {"Ctrl-Slash"},
    },
    FilterAirMobileSelection = {
        defaultActions = {
            press = function()
                Import("client/input/selectionSystem.lua").SetSelectionFilterByTags(Tags.AIR * Tags.MOBILE)
            end,
            release = function()
                Import("client/input/selectionSystem.lua").ClearSelectionFilterByTags()
            end,
        },
        uiDescription = "Filter selection to mobile air units",
        uiCategory = "Selection",
        defaultHotkeys = {"Ctrl-A"},
    },
    FilterEngineerSelection = {
        defaultActions = {
            press = function()
                Import("client/input/selectionSystem.lua").SetSelectionFilterByTags(Tags.ENGINEER * Tags.MOBILE)
            end,
            release = function()
                Import("client/input/selectionSystem.lua").ClearSelectionFilterByTags()
            end,
        },
        uiDescription = "Filter selection to mobile engineers",
        uiCategory = "Selection",
        defaultHotkeys = {"Ctrl-E"},
    }
}
