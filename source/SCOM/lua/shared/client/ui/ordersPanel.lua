local Button = Import("client/ui/button.lua").Button

OrdersPanel = Class("OrdersPanel")

-- Panel State
local isEnabled = false

local orderIconDirectory = "UI/Sprites/Icons/Orders/"

-- Colors
local colorRed    = EngineClasses.float4(0.5471698, 0.02271269, 0.02271269, 1.0)
local colorBlue   = EngineClasses.float4(0.1647059, 0.4901961, 0.7764707, 1.0)
local colorOrange = EngineClasses.float4(0.6627451, 0.4941176, 0.2705882, 1.0)
local colorGreen  = EngineClasses.float4(0.0, 0.5215687, 0.3686275, 1.0)

local ElementType = {
    Button = 1,
    Toggle = 2,
}

-- Buttons: Use circle sprites.
local backgroundCircle = "UI/Sprites/Backgrounds/dashed_bg_circle_white.sansprite"

local frameCircle = {
    "UI/Sprites/Frames/frame_circle01.sansprite",
    "UI/Sprites/Frames/frame_circle02.sansprite",
    "UI/Sprites/Frames/frame_circle03.sansprite",
    "UI/Sprites/Frames/frame_circle04.sansprite",
    "UI/Sprites/Frames/frame_circle05.sansprite",
    "UI/Sprites/Frames/frame_circle06.sansprite",
}

local function createButton(name, frameIndex, icon, color, func)
    return { name = name, type = ElementType.Button, background = backgroundCircle, frame = frameCircle[frameIndex], icon = orderIconDirectory..icon, color = color, func = func }
end

-- Toggles: Use square sprites.
local backgroundSquare = "UI/Sprites/Backgrounds/dashed_bg_square_white.sansprite"

local frameSquare = {
    "UI/Sprites/Frames/frame_square01.sansprite",
    "UI/Sprites/Frames/frame_square02.sansprite",
    "UI/Sprites/Frames/frame_square03.sansprite",
    "UI/Sprites/Frames/frame_square04.sansprite",
    "UI/Sprites/Frames/frame_square05.sansprite",
    "UI/Sprites/Frames/frame_square06.sansprite",
}

local function createToggle(name, frameIndex, icon, color, func)
    return { name = name, type = ElementType.Toggle, background = backgroundSquare, frame = frameSquare[frameIndex], icon = orderIconDirectory..icon, color = color, func = func }
end


function StopClickFunction(clickData, payload)
    Import("client/inputEventsFunctions.lua").IssueClearOrder()
end

function PatrolClickFunction(clickData, payload)
    Import("client/inputEventsFunctions.lua").BeginPatrolOrder()
end

function RepeatBuildClickFunction(clickData, payload)
    local toggle = payload.panel.toggles.RepeatBuild
    local toggleState = toggle:GetActive()
    toggleState = not toggleState
    toggle:SetActive(toggleState)
    Import("client/inputEventsFunctions.lua").SetToggle("RepeatBuild", toggleState)
end

function PauseClickFunction(clickData, payload)
    local toggle = payload.panel.toggles.Pause
    local toggleState = toggle:GetActive()
    toggleState = not toggleState
    toggle:SetActive(toggleState)
    Import("client/inputEventsFunctions.lua").SetToggle("Pause", toggleState)
end

function ShieldClickFunction(clickData, payload)
    local toggle = payload.panel.toggles.Shield
    local toggleState = toggle:GetActive()
    toggleState = not toggleState
    toggle:SetActive(toggleState)
    Import("client/inputEventsFunctions.lua").SetToggle("Shield", toggleState)
end

function IntelClickFunction(clickData, payload)
    local toggle = payload.panel.toggles.Intel
    local toggleState = toggle:GetActive()
    toggleState = not toggleState
    toggle:SetActive(toggleState)
    Import("client/inputEventsFunctions.lua").SetToggle("Intel", toggleState)
end

function ProductionClickFunction(clickData, payload)
    local toggle = payload.panel.toggles.Production
    local toggleState = toggle:GetActive()
    toggleState = not toggleState
    toggle:SetActive(toggleState)
    Import("client/inputEventsFunctions.lua").SetToggle("Production", toggleState)
end

function SurfaceDiveClickFunction(clickData, payload)
    Import("client/inputEventsFunctions.lua").ToggleSubmergeSelected()
end

-- All elements arrangede in the orders panel. The elements can be buttons or toggles. Toggles currently hold a binary state.
local elements = {
    -- Top Row
    createToggle("Shield",       1, "icon_order_shield.sansprite",          colorGreen, ShieldClickFunction),
    createToggle("Production",   1, "icon_order_alloys.sansprite",          colorOrange, ProductionClickFunction),
    -- Also uses icon_order_sonar.sansprite as an icon.
    createToggle("Intel",        2, "icon_order_spr.sansprite",             colorGreen, IntelClickFunction),
    createToggle("Stealth",      4, "icon_order_stealth.sansprite",         colorGreen),
    createButton("SurfaceDive",  1, "icon_order_surface_dive.sansprite",   colorBlue, SurfaceDiveClickFunction),
    createButton("Dock",         1, "icon_order_dock.sansprite",           colorBlue),
    createButton("Transport",    1, "icon_order_transport.sansprite",      colorBlue),

    -- Middle Row
    createButton("ManualFire1",  1, "icon_order_manual_fire_01.sansprite", colorRed),
    createButton("ManualFire2",  1, "icon_order_manual_fire_02.sansprite", colorRed),
    createButton("Harvest",      1, "icon_order_harvest.sansprite",        colorOrange),
    createButton("Capture",      1, "icon_order_capture.sansprite",        colorOrange),
    createButton("Repair",       6, "icon_order_repair.sansprite",         colorOrange),
    createToggle("Pause",        1, "icon_order_pause.sansprite",          colorOrange, PauseClickFunction),
    createToggle("RepeatBuild",  1, "icon_order_repeat_build.sansprite",   colorOrange, RepeatBuildClickFunction),

    -- Button Row
    createButton("TargetPriority", 1, "icon_order_target_priority.sansprite", colorRed),
    createButton("Move",           1, "icon_order_move.sansprite",            colorRed),
    createButton("AttackMove",     1, "icon_order_attack_move.sansprite",     colorBlue),
    createButton("Attack",         1, "icon_order_attack.sansprite",          colorRed),
    createButton("Patrol",         1, "icon_order_patrol.sansprite",          colorBlue, PatrolClickFunction),
    createButton("Assist",         1, "icon_order_assist.sansprite",          colorOrange),
    createButton("Stop",           1, "icon_order_stop.sansprite",            colorRed, StopClickFunction),
}

-- Native tooltips handle pointer hover independently of Lua hover callbacks.
local orderTooltips = {
    Shield = { "Shield", "Enable or disable the selected units' shields." },
    Production = { "Production", "Enable or disable resource production." },
    Intel = { "Intelligence", "Enable or disable radar, sonar, and other intelligence systems." },
    Stealth = { "Stealth", "Enable or disable the selected units' stealth systems." },
    SurfaceDive = { "Surface / dive", "Switch amphibious or submarine units between surface and submerged operation." },
    Dock = { "Dock", "Return a supported unit to its docking facility." },
    Transport = { "Transport", "Choose a transport destination. Right-click to cancel transport targeting." },
    ManualFire1 = { "Build missile", "Left-click to queue one missile. Right-click to toggle automatic missile production." },
    ManualFire2 = { "Launch missile", "Choose a target for a loaded silo or commander missile. Right-click to cancel targeting." },
    Harvest = { "Reclaim", "Recover resources from a reclaimable object or wreck." },
    Capture = { "Capture", "Take control of a capturable target." },
    Repair = { "Repair", "Repair a friendly unit or structure." },
    Pause = { "Pause work", "Pause or resume the selected units' construction work." },
    RepeatBuild = { "Repeat production", "Repeat the factory's build queue until this toggle is disabled." },
    TargetPriority = { "Weapon mode", "Switch supported units between ground and anti-air targeting, or between normal and sniper fire." },
    Move = { "Move", "Order the selected units to move to a destination." },
    AttackMove = { "Attack move", "Move toward a destination while engaging enemies along the way." },
    Attack = { "Attack", "Order the selected units to attack a target." },
    Patrol = { "Patrol", "Choose patrol waypoints for the selected units." },
    Assist = { "Assist", "Help a friendly unit with its current work." },
    Stop = { "Stop", "Clear the selected units' current orders." },
}

-- Panel Initialization
function OrdersPanel:__init()

    Engine.UI_ClearElements(UIPanelType.Orders)

    self.buttons = { }
    self.toggles = { }

    for _, element in ipairs(elements) do

        local data = {}
        data.foreground = { index = 0 }
        data.background = {}
        data.frame = {}
        data.icon = {}
        data.text = ""

        Engine.LoadSprite(element.background, data.background)
        Engine.LoadSprite(element.frame, data.frame)
        Engine.LoadSprite(element.icon, data.icon)

        data.iconGlowColor = EngineClasses.float3(1, 1, 1)
        data.emitClickEvents = true
        data.emitHoverEvents = false

        local payload = { panel = self }
        
        local button = Button(UIPanelType.Orders, data, element.func, element.func, nil, nil, payload)
        Engine.UI_SetButtonColorTint(button.buttonID, element.color)
        local tooltip = orderTooltips[element.name]
        if tooltip then
            Engine.UI_SetButtonTooltip(button.buttonID, tooltip[1], tooltip[2])
        end

        if element.type == ElementType.Button then
            self.buttons[element.name] = button
        elseif element.type == ElementType.Toggle then
            self.toggles[element.name] = button
        else
            Error("OrdersPanel: Element did not have a valid type. Should be either a button or a toggle.")
        end
    end
end

function OrdersPanel:ResetButtons()

    for _, button in pairs(self.buttons) do
        button:SetActive(false)
        button:SetDisabled(true)
    end

    for _, toggle in pairs(self.toggles) do
        toggle:SetActive(false)
        toggle:SetDisabled(true)
    end
end

function OrdersPanel:Update(selectedUnits)

    local activeButtons = { }
    local activeToggles = { }
    
    for key, unit in pairs(selectedUnits) do
        
        if unit.tp.general.orders then
            for orderName, enabled in pairs(unit.tp.general.orders) do
                if enabled then
                    activeButtons[orderName] = true
                end
            end
        end

        if unit.toggles then
            for toggleName, toggleState in pairs(unit.toggles) do
                if activeToggles[toggleName] == nil then
                    activeToggles[toggleName] = toggleState
                elseif toggleState == false then
                    activeToggles[toggleName] = false
                end
            end
        end
    end

    for buttonName, button in pairs(self.buttons) do
        local isDisabled = true
        
        if activeButtons[buttonName] then
            isDisabled = false
        end

        if button:GetDisabled() ~= isDisabled then
            button:SetDisabled(isDisabled)
        end
    end

    for toggleName, toggle in pairs(self.toggles) do 
        
        local isDisabled = true
        local isActive = false

        -- Be careful. Active toggles stores a true or false. We simple want to check if a toggle is present.
        if activeToggles[toggleName] ~= nil then
            isDisabled = false
            isActive = activeToggles[toggleName]
        end

        if toggle:GetDisabled() ~= isDisabled then
            toggle:SetDisabled(isDisabled)
        end
        if toggle:GetActive() ~= isActive then
            toggle:SetActive(isActive)
        end
    end
end

-- Enable/Disable Orders Panel
function OrdersPanel:SetEnabled(enabled)
    if enabled ~= isEnabled then
        isEnabled = enabled

        if enabled then
            self:ResetButtons()
        end

        Engine.UI_SetPanelVisibility(UIPanelType.Orders, enabled)
    end
end
-- SCOM Field Fixes 1.1.1 - strategic silo and UEF ACU order consumers.
local SCOFieldFixStrategicSiloOrdersPanelEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOFieldFixStrategicSiloOrdersPanelMarker = rawget(
    SCOFieldFixStrategicSiloOrdersPanelEnvironment,
    "SCO_FieldFixStrategicSiloOrdersPanelInstalled")
if SCOFieldFixStrategicSiloOrdersPanelMarker ~= nil
    and SCOFieldFixStrategicSiloOrdersPanelMarker ~= "1.1.1"
then
    error("Unsupported SCOM strategic silo orders-panel marker "
        .. tostring(SCOFieldFixStrategicSiloOrdersPanelMarker))
end
if SCOFieldFixStrategicSiloOrdersPanelMarker == nil then
    if type(OrdersPanel) ~= "table"
        or type(OrdersPanel.__init) ~= "function"
        or type(OrdersPanel.Update) ~= "function"
    then
        error("SCOM strategic silo could not resolve OrdersPanel lifecycle")
    end

    local SCOOrdersCommand = nil
    local function SCOGetOrdersCommand()
        if SCOOrdersCommand ~= nil then return SCOOrdersCommand end

        -- Resolve command senders after client modules finish loading.
        local commands = Import("common/commands/definitions/buildQueue.lua")
        local command = commands.SCOStrategicSilo
        if type(command) ~= "table"
            or type(command.Send) ~= "function"
            or type(command.Actions) ~= "table"
        then
            error("SCOM strategic silo orders panel requires command registration first")
        end
        SCOOrdersCommand = command
        return command
    end

    local function SCOIsSilo(unit)
        local contract = unit
            and unit.tp
            and unit.tp.additions
            and (unit.tp.additions.scoStrategicSilo
                or (unit.tp.additions.scoTactical
                    and unit.tp.additions.scoTactical.role == "launcher"
                    and unit.tp.additions.scoTactical))
        return type(contract) == "table" and contract.version == "1.0.0"
    end

    local function SCOSilos(units)
        local silos = {}
        for _, unit in pairs(units or {}) do
            if SCOIsSilo(unit) then
                silos[#silos + 1] = unit
            end
        end
        return silos
    end

    local function SCOCurrentSilos()
        return SCOSilos(
            Import("client/input/selectionSystem.lua").GetSelectedUnits())
    end

    local function SCOUnitTpId(unit)
        return unit and (unit.tpId
            or (unit.tp and unit.tp.general and unit.tp.general.tpId))
    end

    local function SCOExactlyOneUEFCommander(units)
        local unit = nil
        local count = 0
        for _, candidate in pairs(units or {}) do
            count = count + 1
            if count > 1 then return nil end
            unit = candidate
        end
        if count ~= 1
            or SCOIsSilo(unit)
            or SCOUnitTpId(unit) ~= "uel0000"
            or unit.dead == true
            or type(GetFocusArmy) ~= "function"
            or unit.armyId ~= GetFocusArmy()
        then
            return nil
        end
        return unit
    end

    local function SCOCommanderMissileState(unit)
        local getter = rawget(_G, "SCO_GetCommanderEnhancementClientState")
        if type(getter) ~= "function" or type(unit) ~= "table" then return nil end
        local ok, state = pcall(getter, unit)
        local missile = ok
            and type(state) == "table"
            and type(state.abilities) == "table"
            and state.abilities.missile or nil
        if type(missile) ~= "table"
            or missile.available ~= true
            or missile.autoBuild ~= true
            or (missile.profileId ~= "uefTactical"
                and missile.profileId ~= "uefBilly")
            or type(state.unitId) ~= "table"
            or type(unit.id) ~= "table"
            or state.unitId.index ~= unit.id.index
            or state.unitId.version ~= unit.id.version
        then
            return nil
        end
        return state, missile
    end

    local function SCOCurrentAutoMissileCommander()
        local selection = Import("client/input/selectionSystem.lua")
        local units = type(selection) == "table"
            and type(selection.GetSelectedUnits) == "function"
            and selection.GetSelectedUnits() or {}
        local unit = SCOExactlyOneUEFCommander(units)
        if not unit then return nil end
        local state, missile = SCOCommanderMissileState(unit)
        if not state then return nil end
        return unit, state, missile
    end

    local function SCOIsCommanderMissileTargeting(unit)
        local getter = rawget(_G, "SCO_GetCommanderAbilityTargetInputState")
        if type(getter) ~= "function" then return false end
        local ok, target = pcall(getter)
        return ok
            and type(target) == "table"
            and target.abilityId == "MissileLaunch"
            and type(target.unitId) == "table"
            and type(unit.id) == "table"
            and target.unitId.index == unit.id.index
            and target.unitId.version == unit.id.version
    end

    local function SCOCancelCommanderLaunch(reason)
        local cancel = rawget(_G, "SCO_CommanderAbilityTargetInputCancel")
        return type(cancel) == "function"
            and cancel(reason or "button") == true
    end

    local function SCOCancelStrategicLaunch(reason)
        local cancel = rawget(_G, "SCO_CancelStrategicSiloTargetMode")
        return type(cancel) == "function"
            and cancel(reason or "button") == true
    end

    local function SCOCancelAllLaunchTargeting(reason)
        local commanderCancelled = SCOCancelCommanderLaunch(reason)
        local strategicCancelled = SCOCancelStrategicLaunch(reason)
        return commanderCancelled or strategicCancelled
    end

    local function SCOBeginOrCancelCommanderLaunch(unit)
        if SCOIsCommanderMissileTargeting(unit) then
            return SCOCancelAllLaunchTargeting("button")
        end
        SCOCancelStrategicLaunch("commander-begin")
        local begin = rawget(_G, "SCO_CommanderAbilityTargetInputBegin")
        return type(begin) == "function"
            and begin(unit, "MissileLaunch") == true
    end

    local function SCOPercent(value)
        if type(value) ~= "number" or value ~= value then return 0 end
        return math.floor(math.max(0, math.min(1, value)) * 100 + 0.5)
    end

    local function SCOQueueMissile()
        local silos = SCOCurrentSilos()
        if #silos == 0 then return end
        local command = SCOGetOrdersCommand()
        command.Send(
            silos,
            command.Actions.Queue,
            1,
            EngineClasses.float3(0, 0, 0))
    end

    local function SCOToggleAutoBuild()
        local silos = SCOCurrentSilos()
        if #silos == 0 then return end
        local allAuto = true
        for _, unit in ipairs(silos) do
            local state = type(_G.SCO_GetStrategicSiloClientState) == "function"
                and _G.SCO_GetStrategicSiloClientState(unit)
            if not state or not state.autoBuild then
                allAuto = false
                break
            end
        end
        local command = SCOGetOrdersCommand()
        command.Send(
            silos,
            command.Actions.SetAuto,
            allAuto and 0 or 1,
            EngineClasses.float3(0, 0, 0))
    end

    local function SCOBeginLaunch()
        local commander = SCOCurrentAutoMissileCommander()
        if commander then
            return SCOBeginOrCancelCommanderLaunch(commander)
        end
        local silos = SCOCurrentSilos()
        if #silos == 0 then return end
        SCOCancelCommanderLaunch("strategic-begin")
        local begin = _G.SCO_BeginStrategicSiloTargetMode
        if type(begin) ~= "function" then
            error("SCOM strategic silo target mode is not installed")
        end
        begin(silos)
    end

    local function SCOCancelLaunch()
        return SCOCancelAllLaunchTargeting("button")
    end

    local SCOOrdersPanelInit = OrdersPanel.__init
    local SCOOrdersPanelUpdate = OrdersPanel.Update

    function OrdersPanel:__init(...)
        local result = SCOOrdersPanelInit(self, ...)
        local build = self.buttons and self.buttons.ManualFire1
        local launch = self.buttons and self.buttons.ManualFire2
        if not build or not launch then
            error("SCOM strategic silo requires ManualFire1/2 order buttons")
        end
        build.leftClickFunction = SCOQueueMissile
        build.rightClickFunction = SCOToggleAutoBuild
        launch.leftClickFunction = SCOBeginLaunch
        launch.rightClickFunction = SCOCancelLaunch
        return result
    end

    function OrdersPanel:Update(selectedUnits)
        local result = SCOOrdersPanelUpdate(self, selectedUnits)
        local silos = SCOSilos(selectedUnits)
        local build = self.buttons and self.buttons.ManualFire1
        local launch = self.buttons and self.buttons.ManualFire2
        if not build or not launch then return result end
        if #silos == 0 then
            local commander = SCOExactlyOneUEFCommander(selectedUnits)
            local state, missile = SCOCommanderMissileState(commander)
            if state then
                local targeting = SCOIsCommanderMissileTargeting(commander)
                local ammo = type(missile.ammo) == "number"
                    and missile.ammo or 0
                local cooldown = type(missile.cooldownRemaining) == "number"
                    and missile.cooldownRemaining or 0
                local building = missile.building == true
                local teleport = type(state.abilities.teleport) == "table"
                    and state.abilities.teleport.active == true
                local enabled = targeting or (ammo >= 1
                    and not building
                    and cooldown <= 0
                    and state.active == nil
                    and not teleport)
                local launchText = "FIRE "
                    .. tostring(math.max(0, math.floor(ammo)))
                if targeting then
                    launchText = "CANCEL"
                elseif building then
                    launchText = (missile.paused == true
                        and "PAUSED " or "LOADING ")
                        .. tostring(SCOPercent(missile.fraction)) .. "%"
                elseif ammo < 1 then
                    launchText = "LOADING"
                elseif cooldown > 0 then
                    launchText = "READYING"
                end
                Engine.UI_SetButtonText(build.buttonID, "")
                build:SetDisabled(true)
                Engine.UI_SetButtonText(launch.buttonID, launchText)
                launch:SetDisabled(not enabled)
                return result
            end
            Engine.UI_SetButtonText(build.buttonID, "")
            Engine.UI_SetButtonText(launch.buttonID, "")
            return result
        end

        local known = true
        local ammo, maximum = 0, 0
        local work, buildTime, building = 0, 0, false
        local anyAuto = false
        local anyLaunchPending = false
        local allAnimationReady = true
        for _, unit in ipairs(silos) do
            local state = type(_G.SCO_GetStrategicSiloClientState) == "function"
                and _G.SCO_GetStrategicSiloClientState(unit)
            if not state then
                known = false
                break
            end
            ammo = ammo + state.ammo
            maximum = maximum + state.maxAmmo
            anyAuto = anyAuto or state.autoBuild
            anyLaunchPending = anyLaunchPending or state.launchPending
            allAnimationReady = allAnimationReady and state.animationReady
            if state.building then
                building = true
                work = work + state.work
                buildTime = buildTime + state.buildTime
            end
        end

        if known then
            local buildText = (anyAuto and "A " or "")
                .. tostring(ammo) .. "/" .. tostring(maximum)
            if building and buildTime > 0 then
                buildText = buildText .. "\n"
                    .. tostring(math.floor(work / buildTime * 100)) .. "%"
            end
            Engine.UI_SetButtonText(build.buttonID, buildText)
            local launchText = "FIRE " .. tostring(ammo)
            if anyLaunchPending then
                launchText = "FIRING " .. tostring(ammo)
            elseif not allAnimationReady then
                launchText = "READYING " .. tostring(ammo)
            end
            Engine.UI_SetButtonText(launch.buttonID, launchText)
            launch:SetDisabled(
                ammo <= 0 or anyLaunchPending or not allAnimationReady)
        else
            Engine.UI_SetButtonText(build.buttonID, "?/?")
            Engine.UI_SetButtonText(launch.buttonID, "FIRE ?")
            launch:SetDisabled(true)
        end
        return result
    end

    rawset(
        SCOFieldFixStrategicSiloOrdersPanelEnvironment,
        "SCO_FieldFixStrategicSiloOrdersPanelInstalled",
        "1.1.1")
    _G.SCO_FieldFixStrategicSiloOrdersPanelInstalled = "1.1.1"
end
-- Choose a destination with the native Transport button; right-click cancels.
for _,element in ipairs(elements) do
    if element.name=="Transport" then
        element.func=function() Import("client/inputEventsFunctions.lua").SCOUnloadSelectedCargo(false) end
    elseif element.name=="SurfaceDive" then
        element.func=function() Import("client/inputEventsFunctions.lua").ToggleSubmergeSelected() end
    end
end
-- Append in OrdersPanel lexical scope. Reuse its existing TargetPriority slot;
-- all unrelated selections retain the original native button and behavior.
for _,element in ipairs(elements) do
    if element.name=='TargetPriority' then
        local previous=element.func
        element.func=function(event,payload)
            local panel=payload.panel
            if (not panel.scoSourceModeUnits or #panel.scoSourceModeUnits==0)
                and (not panel.scoSourceSniperUnits or #panel.scoSourceSniperUnits==0) then
                if previous then return previous(event,payload) end
                return
            end
            if IsObserver and IsObserver() then return end
            local commands=Import('common/commands/definitions/units.lua')
            for _,unit in ipairs(panel.scoSourceModeUnits or {}) do
                commands.SCOSourceUnitMode.Send(unit.id,not panel.scoSourceModeAllGround)
            end
            for _,unit in ipairs(panel.scoSourceSniperUnits or {}) do
                commands.SCOSourceSniperMode.Send(unit.id,not panel.scoSourceSniperAllOn)
            end
        end
    end
    if element.name=='Stealth' then
        local previous=element.func
        element.func=function(event,payload)
            local panel=payload.panel
            if not panel.scoSourceStealthUnits or #panel.scoSourceStealthUnits==0 then
                if previous then return previous(event,payload) end
                return
            end
            if IsObserver and IsObserver() then return end
            local commands=Import('common/commands/definitions/units.lua')
            for _,unit in ipairs(panel.scoSourceStealthUnits) do
                commands.SCOSourceStealth.Send(unit.id,not panel.scoSourceStealthAllOn)
            end
        end
    end
end
local SCOUnitModePanelUpdate=OrdersPanel.Update
function OrdersPanel:Update(selectedUnits)
    SCOUnitModePanelUpdate(self,selectedUnits)
    self.scoSourceModeUnits={}
    self.scoSourceModeAllGround=true
    self.scoSourceStealthUnits={}
    self.scoSourceStealthAllOn=true
    self.scoSourceSniperUnits={}
    self.scoSourceSniperAllOn=true
    for _,unit in pairs(selectedUnits) do
        local c=unit.tp and unit.tp.additions and unit.tp.additions.scoSourceUnitModes
        if unit.tpId=='ugl5001' and c and c.sourceId=='URL0104' then
            self.scoSourceModeUnits[#self.scoSourceModeUnits+1]=unit
            if not unit.scoSourceGroundMode then self.scoSourceModeAllGround=false end
        end
        if unit.tpId=='uga5006' and c and c.sourceId=='URA0303' then
            self.scoSourceStealthUnits[#self.scoSourceStealthUnits+1]=unit
            if not unit.scoSourceStealth then self.scoSourceStealthAllOn=false end
        end
        if unit.tpId=='usl3801' and c and c.sourceId=='XSL0305' then
            self.scoSourceSniperUnits[#self.scoSourceSniperUnits+1]=unit
            if not unit.scoSourceSniperMode then self.scoSourceSniperAllOn=false end
        end
    end
    local stealth=self.toggles.Stealth
    if stealth and #self.scoSourceStealthUnits>0 then
        stealth:SetDisabled(IsObserver and IsObserver() or false)
        stealth:SetActive(self.scoSourceStealthAllOn)
        Engine.UI_SetButtonText(stealth.buttonID,'Stealth')
        self.scoSourceStealthLabel=true
    elseif stealth and self.scoSourceStealthLabel then
        Engine.UI_SetButtonText(stealth.buttonID,'')
        self.scoSourceStealthLabel=nil
    end
    local button=self.buttons.TargetPriority
    if not button then return end
    if #self.scoSourceSniperUnits>0 then
        button:SetDisabled(IsObserver and IsObserver() or false)
        button:SetActive(self.scoSourceSniperAllOn)
        local label=self.scoSourceSniperAllOn and 'Sniper mode' or 'Normal mode'
        if #self.scoSourceModeUnits>0 then label='Weapon modes' end
        Engine.UI_SetButtonText(button.buttonID,label)
        self.scoSourceModeLabel=true
    elseif #self.scoSourceModeUnits>0 then
        button:SetDisabled(IsObserver and IsObserver() or false)
        button:SetActive(self.scoSourceModeAllGround)
        Engine.UI_SetButtonText(button.buttonID,self.scoSourceModeAllGround and 'Ground attack' or 'Anti-air')
        self.scoSourceModeLabel=true
    elseif self.scoSourceModeLabel then
        Engine.UI_SetButtonText(button.buttonID,'')
        self.scoSourceModeLabel=nil
    end
end
-- Append before OrdersPanel exports. Existing native sprites require no assets.
table.insert(elements,createButton("EngineeringPod",1,"icon_order_dock.sansprite",colorBlue,
    function() Import("client/inputEventsFunctions.lua").SCOSelectedPodAction(false) end))
table.insert(elements,createButton("RemoveEngineeringPod",1,"icon_order_stop.sansprite",colorOrange,
    function() Import("client/inputEventsFunctions.lua").SCOSelectedPodAction(true) end))
local SCOPodPanelInit=OrdersPanel.__init
function OrdersPanel:__init(...)
    SCOPodPanelInit(self,...)
    Engine.UI_SetButtonTooltip(self.buttons.EngineeringPod.buttonID,"Engineering drone",
        "Install the SACU's C-D2 pod: 120 alloys, 2400 energy, 40 seconds at base build rate. Requires an idle SACU.")
    Engine.UI_SetButtonTooltip(self.buttons.RemoveEngineeringPod.buttonID,"Remove or cancel drone",
        "Cancel an in-progress pod enhancement, or remove the installed pod for 1 alloy and 1 energy.")
end
local SCOPodPanelUpdate=OrdersPanel.Update
function OrdersPanel:Update(selectedUnits)
    SCOPodPanelUpdate(self,selectedUnits)
    local canInstall,canRemove=false,false
    for _,unit in pairs(selectedUnits) do
        if unit.tpId=="uel5007" then
            canInstall=canInstall or (not unit.scoSourcePodInstalled and not unit.scoSourcePodWorking)
            canRemove=canRemove or unit.scoSourcePodInstalled or unit.scoSourcePodWorking
        end
    end
    self.buttons.EngineeringPod:SetDisabled(not canInstall)
    self.buttons.RemoveEngineeringPod:SetDisabled(not canRemove)
end

-- An ACU's unused missile-build slot exposes its innate manual weapon.
-- Silo selections keep missile production; ManualFire2 remains missile launch.
do
    local acuIds = { uel0000 = true, ucl0000 = true, ugl0000 = true, usl0000 = true }

    local function selectedACU(units)
        if type(IsObserver) == "function" and IsObserver() then return nil end
        local unit, count = nil, 0
        for _, candidate in pairs(units or {}) do
            unit, count = candidate, count + 1
        end
        if count ~= 1 or not acuIds[unit.tpId] or unit.dead
            or unit.armyId ~= GetFocusArmy()
        then return nil end
        return unit
    end

    local function currentACU()
        return selectedACU(Import("client/input/selectionSystem.lua").GetSelectedUnits())
    end

    local function overchargeTarget()
        local getter = rawget(_G, "SCO_GetCommanderAbilityTargetInputState")
        local target = type(getter) == "function" and getter() or nil
        return target and target.abilityId == "Overcharge" and target or nil
    end

    local function targetingUnit(target, unit)
        return target and unit and target.unitId and unit.id
            and target.unitId.index == unit.id.index
            and target.unitId.version == unit.id.version
    end

    local function cancelTarget(reason)
        local cancel = rawget(_G, "SCO_CommanderAbilityTargetInputCancel")
        return overchargeTarget() ~= nil and type(cancel) == "function"
            and cancel(reason or "button") == true
    end

    local function activateSelected()
        local unit = currentACU()
        if not unit then return false end
        if targetingUnit(overchargeTarget(), unit) then
            return cancelTarget("button")
        end
        local begin = rawget(_G, "SCO_CommanderAbilityTargetInputBegin")
        return type(begin) == "function" and begin(unit, "Overcharge") == true
    end
    _G.SCO_ActivateSelectedOvercharge = activateSelected

    local previousInit = OrdersPanel.__init
    function OrdersPanel:__init(...)
        previousInit(self, ...)
        local button = self.buttons.ManualFire1
        local previousLeft, previousRight = button.leftClickFunction, button.rightClickFunction
        button.leftClickFunction = function(...)
            if currentACU() then return activateSelected() end
            if previousLeft then return previousLeft(...) end
        end
        button.rightClickFunction = function(...)
            if currentACU() then return cancelTarget("button") end
            if previousRight then return previousRight(...) end
        end
    end

    local previousUpdate = OrdersPanel.Update
    function OrdersPanel:Update(selectedUnits)
        previousUpdate(self, selectedUnits)
        local button = self.buttons.ManualFire1
        local unit = selectedACU(selectedUnits)
        local target = overchargeTarget()
        if target and not targetingUnit(target, unit) then
            cancelTarget("selection-changed")
            target = nil
        end
        if not unit then
            if self.scoOverchargeContext then
                local tooltip = orderTooltips.ManualFire1
                Engine.UI_SetButtonTooltip(button.buttonID, tooltip[1], tooltip[2])
                button:SetActive(false)
                self.scoOverchargeContext = nil
            end
            return
        end

        self.scoOverchargeContext = true
        local getter = rawget(_G, "SCO_GetCommanderEnhancementClientState")
        local state = type(getter) == "function" and getter(unit) or nil
        local ability = state and state.unitId
            and state.unitId.index == unit.id.index
            and state.unitId.version == unit.id.version
            and type(state.abilities) == "table" and state.abilities.overcharge
        local targeting = targetingUnit(target, unit) == true
        local ready = type(ability) == "table"
            and ability.available == true and ability.ready == true
        local text = targeting and "CANCEL" or "OC"
        local description = "Select an enemy unit to fire Overcharge. Right-click or Escape cancels targeting."
        if type(ability) == "table" then
            description = description .. " Costs " .. tostring(ability.energyCost or "?") .. " energy."
            if type(ability.cooldownDuration) == "number" then
                description = description .. " Cooldown: "
                    .. string.format("%.2f", ability.cooldownDuration) .. " seconds."
            end
            if not targeting then
                if ability.active then text = "AIM"
                elseif type(ability.cooldownRemaining) == "number" and ability.cooldownRemaining > 0 then
                    text = "WAIT"
                elseif ability.reason == "energy" then text = "ENERGY"
                elseif not ready then text = "WAIT" end
            end
        else
            text = "WAIT"
        end
        button:SetDisabled(not (targeting or ready))
        button:SetActive(targeting)
        Engine.UI_SetButtonText(button.buttonID, text)
        Engine.UI_SetButtonTooltip(button.buttonID, "Overcharge (O)", description)
    end
end
