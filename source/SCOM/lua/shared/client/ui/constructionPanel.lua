local TempBuildMode = Import("client/input/buildmodeTemp.lua")
local ButtonList = Import("client/ui/buttonList.lua").ButtonList
local ConstructionHotkeys = Import("client/input/constructionPanelHotkeys.lua")
local InputSystem = Import("client/input/inputSystem.lua")
local QueuedStationUpgrades = { ues2501 = true, ugs2501 = true, ugs5026 = true }

ConstructionPanel = Class("ConstructionPanel")

local isFilterEnabled = false
local isEnabled = false
local currentDisplayedTemplates = {}
local currentTemplateDisplayOptions = {}
local currentTemplateDisplayTier = 1
local currentIsFactory = false
local currentSelectedUnits = nil

function ConstructionPanel:__init()
    self.constructionButtons = ButtonList(UIPanelType.Construction)
    self.constructionFilteringButtons = ButtonList(UIPanelType.ConstructionFilter)
    self.groupDefinitions = self:GetGroupDefinitions()
    self.hoveredTemplate = nil
end

function ConstructionPanel:GetGroupDefinitions()
    return {
        {
            debugname = "FACTORY",
            expression = Tags.FACTORY,
            results = {}
        },
        {
            debugname = "ENGINEER",
            expression = Tags.ENGINEER,
            results = {}
        },
        {
            debugname = "ECONOMIC",
            expression = Tags.ECONOMIC,
            results = {}
        },
        {
            debugname = "DEFENCE",
            expression = Tags.DEFENCE,
            results = {}
        },
        {
            debugname = "everything else",
            expression = Tags.ALL_UNITS,
            results = {}
        }
    }
end

function ConstructionPanel:SetConstructionEnabled(enabled)
    if enabled ~= isEnabled then
        isEnabled = enabled
        Engine.UI_SetPanelVisibility(UIPanelType.Construction, enabled)
    end
end

function ConstructionPanel:SetConstructionFilterEnabled(enabled)
    if enabled ~= isFilterEnabled then
        isFilterEnabled = enabled
        Engine.UI_SetPanelVisibility(UIPanelType.ConstructionFilter, enabled)
    end
end

---comment
---@param tpId any
---@param isFactory any
---@param selectedUnits table<integer, ClientUnit|PredictedUnit|Selectable>
---@param deltaAmount any
---@return table
local function ExecuteConstructionAction(tpId, isFactory, selectedUnits, deltaAmount)

    -- Observers may not control units. Return before the queue is predicted locally.
    if IsObserver() then
        return
    end

    if isFactory then
        local factories = {}

        for localIDIndex, unit in pairs(selectedUnits) do

            -- There is no requirement that the units selected can build. Skip any that cannot.
            if unit.tp.construction and unit.tp.construction.canBuild then
                factories[localIDIndex] = unit
            end
        end

        local BuildQueueCommands = Import("common/commands/definitions/buildQueue.lua")
        if deltaAmount > 0 then
            BuildQueueCommands.AddToBuildQueueForUnits(factories, tpId, deltaAmount)
        else
            BuildQueueCommands.RemoveFromBuildQueueForUnits(factories, tpId, -deltaAmount)
        end
    else
        TempBuildMode.SetBuildTemplate(tpId)
        TempBuildMode.SetBuildMode(true)
    end
end

function ConstructionClickFunction(clickData, payload)
    local deltaAmount = clickData.mouseClickType == UIMouseClickType.Left and 1 or -1
    if clickData.isShiftHeld then deltaAmount = deltaAmount * 5 end
    ExecuteConstructionAction(payload.tpId, payload.isFactory, payload.selectedUnits, deltaAmount)
end

function ConstructionHoverFunction(hoverData, payload)
    if hoverData.mouseHoverState == UIMouseHoverState.Enter then
        payload.panel.hoveredTemplate = __Templates.Units[payload.tpId]
    else
        payload.panel.hoveredTemplate = nil
    end
end

-- Show the available construction buttons for this Tier (like TECH1)
---@param templateDisplayTier integer
function ConstructionPanel:ShowConstructionButtonsForTier(templatesInTier, isFactory, selectedUnits, templateDisplayTier)
    self.constructionButtons:ClearButtons()

    currentTemplateDisplayTier = templateDisplayTier
    currentIsFactory = isFactory
    currentSelectedUnits = selectedUnits
    currentDisplayedTemplates = {}

    local shouldAddSeparator = false

    local demoTags = Tags.DEMO_UI_ONLY

    for _, group in pairs(templatesInTier) do
        if shouldAddSeparator then
            self.constructionButtons:AddSeparator()
        end

        shouldAddSeparator = true

        -- make a button for each unit type
        for _, tpId in ipairs(group) do
            local template = __Templates.Units[tpId]

            local buttonData = {}

            local isDemoUnit = demoTags[tpId]

            if isDemoUnit then
                buttonData.emitClickEvents = false
                buttonData.emitHoverEvents = false
                buttonData.foreground = { index = 0 }
                buttonData.background = { index = 0}
                buttonData.frame = { index = 0 }
                buttonData.icon = { index = 0}
                buttonData.iconGlowColor = EngineClasses.float3(0, 0, 0)
                buttonData.emitClickEvents = false
                buttonData.emitHoverEvents = false
            else
                buttonData.text = ConstructionHotkeys.GetHotkeyForTemplate(tpId, isFactory) or '?'
                buttonData.foreground = template.general.foregroundIconID or { index = 0 }
                buttonData.background = template.general.backgroundIconID or { index = 0 }
                buttonData.icon = template.general.strategicIconID or { index = 0 }
                buttonData.frame = { index = 0 }
                buttonData.iconGlowColor = template.general.strategicIconGlowColor
                buttonData.emitClickEvents = true
                buttonData.emitHoverEvents = true
                table.insert(currentDisplayedTemplates, tpId)
            end

            local payload = {
                panel = self,
                selectedUnits = selectedUnits,
                isFactory = isFactory,
                tpId = tpId
            }

            self.constructionButtons:AddButton(buttonData, ConstructionClickFunction, ConstructionClickFunction, ConstructionHoverFunction, ConstructionHoverFunction, payload)
        end
    end

    self:SetConstructionEnabled(true)
end

function ConstructionFilterLeftClickFunction(data, payload)
    -- Disable all other toggles
    for _, otherButton in pairs(payload.panel.constructionFilteringButtons.buttons) do
      if otherButton.buttonID.id ~= payload.button.buttonID.id then
          otherButton:SetActive(false)
      end
    end

    payload.panel:ShowConstructionButtonsForTier(payload.templatesInTier, payload.hasFactoryOptions, payload.units, payload.templateDisplayTier)
end

---@param units table<integer, ClientUnit|PredictedUnit|Selectable>
function ConstructionPanel:GetConstructionOptionsForUnits(units)
    local constructionOptions = {}
    local hasEngineerOptions = false
    local hasFactoryOptions = false
    local engineerTags = Tags.COMMAND + Tags.ENGINEER + Tags.ENGINEERING_STATION

    for _, unit in pairs(units) do
        -- gather construction options for engineers and factories
        local buildableTags = buildQueueUtils.GetBuildableTags(unit)
        if next(buildableTags) then
            -- Fixed stations expose their next stage through the native self-upgrade queue.
            local tpId = unit.tp.general.tpId
            local stationUpgrade = QueuedStationUpgrades[tpId]
            if engineerTags[tpId] and not stationUpgrade then
                constructionOptions = constructionOptions + buildableTags
                hasEngineerOptions = true
            else
                constructionOptions = constructionOptions + buildableTags
                hasFactoryOptions = true
            end
        end
    end

    -- constructionOptions now contains { { key="ues1511", val=true } }
    return constructionOptions, hasEngineerOptions, hasFactoryOptions
end

--- Show the construction panel for the selected units, includes the tier filtering panel
---@param units table<integer, ClientUnit|PredictedUnit|Selectable>
---@param constructionOptions any
---@param hasEngineerOptions any
---@param hasFactoryOptions any
function ConstructionPanel:UpdateConstructionPanel(units, constructionOptions, hasEngineerOptions, hasFactoryOptions)
    -- dont show any build options if both types of constructor are selected
    if hasEngineerOptions and hasFactoryOptions then
        self:SetConstructionEnabled(false)
        self:SetConstructionFilterEnabled(false)
        return
    end

    if not hasEngineerOptions and not hasFactoryOptions then
        self:SetConstructionEnabled(false)
        self:SetConstructionFilterEnabled(false)
        return
    end

    -- put unitcounts into first matching group
    table.assignIntoFirstGroup(constructionOptions, self.groupDefinitions, function(tpId, _, group)
        return group.expression[tpId] -- returns true if the tags expression matches this unit
    end)

    local templatesPerTier = {}
    local highestTechNumber = 1

    -- Distribute the templates into their proper tier tabs directly driven by tags
    for groupIndex, group in ipairs(self.groupDefinitions) do
        if next(group.results) then
            for tpId, _ in pairs(group.results) do
                local tier = __Templates.Units[tpId].general.techNumber
                local isFactoryUpgrade = hasFactoryOptions and Tags.STRUCTURE[tpId]
            
                -- Correctly handle factory upgrades naturally (e.g. T2 Upgrade built in T1 factory shows in T1 tab)
                if isFactoryUpgrade then
                    tier = tier - 1
                    for _, unit in pairs(units) do
                        local ownerId = unit.tp.general.tpId
                        if QueuedStationUpgrades[ownerId]
                            and unit.tp.construction.upgradesTo == tpId then
                            tier = unit.tp.general.techNumber
                            break
                        end
                    end
                end

                if tier > highestTechNumber then
                    highestTechNumber = tier
                end

                if not templatesPerTier[tier] then 
                    templatesPerTier[tier] = {} 
                end
            
                if not templatesPerTier[tier][groupIndex] then 
                    templatesPerTier[tier][groupIndex] = {}
                end

                table.insert(templatesPerTier[tier][groupIndex], tpId)
            end
        end
    end

    for i = 1, highestTechNumber do
        if not templatesPerTier[i] then 
            templatesPerTier[i] = {} 
        end
    
        for groupIndex = 1, #self.groupDefinitions do
            if templatesPerTier[i][groupIndex] then
                if not next(templatesPerTier[i][groupIndex]) then
                    -- Set this no nil to allow simpler UI code (UI separators, tier filtering)
                    templatesPerTier[i][groupIndex] = nil
                else
                    table.sort(templatesPerTier[i][groupIndex])
                end
            end
        end
    end

    --- we cache the display options to be able to lookup other template display options
    --- for now we use this to fallback to other display options if the current one does not satisfy our needs
    local templateDisplayOptions = {}
    for tier = 1, highestTechNumber do
        local displayTemplates = {}
        for groupIndex = 1, #self.groupDefinitions do
            local group = templatesPerTier[tier][groupIndex]
            if group then
                for _, tpId in ipairs(group) do
                    if not Tags.DEMO_UI_ONLY[tpId] then
                        table.insert(displayTemplates, tpId)
                    end
                end
            end
        end
        templateDisplayOptions[tier] = displayTemplates
    end

    -- Default tier shown is the highest tech tier among the selected units (including queued upgrades),
    local defaultTier = 1
    for _, unit in pairs(units) do
        local _, unitTech = buildQueueUtils.GetHighestQueuedUpgradeTemplateId(unit)
        if unitTech > defaultTier then
            defaultTier = unitTech
        end
    end
    defaultTier = math.min(defaultTier, highestTechNumber)

    --Show construction filter buttons
    self.constructionFilteringButtons:ClearButtons()

    for i = 1, highestTechNumber do
        local buttonData = {
            text = 'T'..i,
            foreground = { index = 0 },
            background = { index = 0},
            frame = { index = 0 },
            icon = { index = 0},
            emitClickEvents = true,
            emitHoverEvents = false,
            iconGlowColor = EngineClasses.float3(0, 0, 0)
        }

        local payload = {
            panel = self,
            templatesInTier = templatesPerTier[i],
            hasFactoryOptions = hasFactoryOptions,
            units = units,
            templateDisplayTier = i
        }

        local button = self.constructionFilteringButtons:AddButton(buttonData, ConstructionFilterLeftClickFunction, nil, nil, nil, payload)
        payload.button = button

        if i == defaultTier then
            button:SetActive(true)
        end

        -- No templates in the current tier
        if not next(templatesPerTier[i]) then
            button:SetDisabled(true)
        end
    end

    self:SetConstructionFilterEnabled(true)
    currentTemplateDisplayOptions = templateDisplayOptions
    self:ShowConstructionButtonsForTier(templatesPerTier[defaultTier], hasFactoryOptions, units, defaultTier)
end

function IsConstructionPanelEnabled()
    return isEnabled
end

---Searches the active tier first, then lower tiers before higher tiers.
---@param hotkey string
---@return boolean
function TriggerConstructionHotkey(hotkey)
    if not isEnabled then return false end
    local tpId = ConstructionHotkeys.FindTemplateForHotkey(hotkey, currentIsFactory, currentDisplayedTemplates)
    -- If the hotkey does not correspond to a template in the current display, we search other display options.
    -- We prioritize lower tiers when searching for alternative template display options then go back to higher ones.
    if not tpId then
        local displayCount = #currentTemplateDisplayOptions
        for displayIndex = currentTemplateDisplayTier - 1, 1, -1 do
            tpId = ConstructionHotkeys.FindTemplateForHotkey(hotkey, currentIsFactory, currentTemplateDisplayOptions[displayIndex])
            if tpId then break end
        end
        if not tpId then
            for displayIndex = currentTemplateDisplayTier + 1, displayCount do
                tpId = ConstructionHotkeys.FindTemplateForHotkey(hotkey, currentIsFactory, currentTemplateDisplayOptions[displayIndex])
                if tpId then break end
            end
        end
    end
    if not tpId then return false end
    local deltaAmount = InputSystem.IsRawKeyPressed("Shift") and 5 or 1
    ExecuteConstructionAction(tpId, currentIsFactory, currentSelectedUnits, deltaAmount)
    return true
end

-- Sanctuary Construction Plans 2.1.0
local SCO_Blueprints = Import("client/ui/scoBlueprints.lua")
local SCO_StockUpdateConstructionPanel = ConstructionPanel.UpdateConstructionPanel
local SCO_StockConstructionClickFunction = ConstructionClickFunction
local SCO_StockConstructionFilterLeftClickFunction = ConstructionFilterLeftClickFunction
local SCO_StockTriggerConstructionHotkey = TriggerConstructionHotkey

function ConstructionPanel:UpdateConstructionPanel(units, constructionOptions, hasEngineerOptions, hasFactoryOptions)
    local canCapture = SCO_Blueprints.CanCaptureSelection(units)
    -- A selection refresh always returns ownership of the visible
    -- tab to Sanctuary. BP is entered only by clicking its filter.
    SCO_Blueprints.CloseBlueprintPanel()
    SCO_StockUpdateConstructionPanel(self, units, constructionOptions, hasEngineerOptions, hasFactoryOptions)
    if hasEngineerOptions ~= hasFactoryOptions or canCapture then
        if not hasEngineerOptions and not hasFactoryOptions then
            self.constructionFilteringButtons:ClearButtons()
        end
        SCO_Blueprints.AddBlueprintFilter(self, units, canCapture)
    end
end

function ConstructionFilterLeftClickFunction(data, payload)
    SCO_Blueprints.LeaveBlueprintUI()
    return SCO_StockConstructionFilterLeftClickFunction(data, payload)
end

function ConstructionClickFunction(clickData, payload)
    SCO_Blueprints.LeaveBlueprintUI()
    return SCO_StockConstructionClickFunction(clickData, payload)
end

function TriggerConstructionHotkey(hotkey)
    SCO_Blueprints.LeaveBlueprintUI()
    return SCO_StockTriggerConstructionHotkey(hotkey)
end

-- SCOM support commander scope 80185ac0b1e1c39ed6e3abf80c545bef076bb753578af1edb505110a8f1ae1ee EDC6AC4C8E95B060DAF5D374E35B8628F5A9ECFB9D2DD2FFBDC23030E20700C4
-- Supreme Commander Overhaul commander enhancements 1.0.0
-- Adds a distinct native UPGRADES filter for one selected imported ACU. Enhancement
-- buttons are grouped under passive equipment-slot headings and use the stock
-- Forged Alliance artwork. SupComStyleUI remains a presentation-only skin with no
-- enhancement behavior or state ownership.
local SCOCommanderEnhancementPanelEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderEnhancementPanelMarker = rawget(
    SCOCommanderEnhancementPanelEnvironment,
    "SCO_CommanderEnhancementConstructionPanelInstalled")
if SCOCommanderEnhancementPanelMarker ~= nil
    and SCOCommanderEnhancementPanelMarker ~= "1.9.0"
then
    error("Unsupported SCOM commander-enhancement construction-panel marker "
        .. tostring(SCOCommanderEnhancementPanelMarker))
end
if SCOCommanderEnhancementPanelMarker == nil then
    if type(ConstructionPanel) ~= "table"
        or type(ConstructionPanel.UpdateConstructionPanel) ~= "function"
        or type(ConstructionPanel.SetConstructionEnabled) ~= "function"
        or type(ConstructionFilterLeftClickFunction) ~= "function"
        or type(Engine) ~= "table"
        or type(Engine.UI_SetButtonTooltip) ~= "function"
        or type(GetFocusArmy) ~= "function"
    then
        error("SCOM commander enhancements could not resolve ConstructionPanel lifecycle")
    end

    local SCOSupportedCommanders = {
        uel0000 = true,
        ugl0000 = true,
        ucl0000 = true,
        usl0000 = true,
    }
    local SCOFactionIconFolders = {
        uel0000 = "uef",
        ugl0000 = "cybran",
        ucl0000 = "aeon",
        usl0000 = "seraphim",
    }
    -- Keep Forged Alliance's physical equipment-slot order, but present all three
    -- groups together so the location names are headings rather than nested tabs.
    local SCOEnhancementSlotOrder = { "LCH", "Back", "RCH" }
    local SCOEnhancementSlotLabels = {
        LCH = "LEFT ARM",
        Back = "BACK",
        RCH = "RIGHT ARM",
    }
    local SCOEnhancementSlotNames = {
        LCH = "Left Arm",
        Back = "Back",
        RCH = "Right Arm",
    }
    local SCOEnhancementIconIDs = {}
    local SCOPreviousUpdateConstructionPanel =
        ConstructionPanel.UpdateConstructionPanel
    local SCOPreviousSetConstructionEnabled =
        ConstructionPanel.SetConstructionEnabled
    local SCOPreviousConstructionFilterLeftClick =
        ConstructionFilterLeftClickFunction

SCOSupportedCommanders.ucl4002 = true
SCOSupportedCommanders.uel5007 = true
SCOSupportedCommanders.ugl5004 = true
SCOSupportedCommanders.usl4002 = true
SCOFactionIconFolders.ucl4002 = "aeon"
SCOFactionIconFolders.uel5007 = "uef"
SCOFactionIconFolders.ugl5004 = "cybran"
SCOFactionIconFolders.usl4002 = "seraphim"

    local function SCOFinite(value)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
    end

    local function SCOUnitTpId(unit)
        return unit and (unit.tpId
            or (unit.tp and unit.tp.general and unit.tp.general.tpId))
    end

    local function SCOUnitKey(unit)
        return unit and unit.id
            and (tostring(unit.id.index) .. ":" .. tostring(unit.id.version))
            or nil
    end

    local function SCOLoadEnhancementSprite(path)
        if type(path) ~= "string"
            or type(Engine.LoadSprite) ~= "function"
        then
            return nil
        end
        local cached = SCOEnhancementIconIDs[path]
        if cached == false then return nil end
        if type(cached) == "table" then return cached end

        local assetId = {}
        local loaded = pcall(Engine.LoadSprite, path, assetId)
        if not loaded
            or type(assetId.index) ~= "number"
            or assetId.index == 0
        then
            SCOEnhancementIconIDs[path] = false
            return nil
        end
        SCOEnhancementIconIDs[path] = assetId
        return assetId
    end

    local function SCOLoadEnhancementIcon(unit, rule)
        local folder = SCOFactionIconFolders[SCOUnitTpId(unit)]
        local icon = type(rule) == "table" and rule.icon
        if type(folder) ~= "string"
            or type(icon) ~= "string"
            or string.match(icon, "^[%l%d_%-]+$") == nil
        then
            return nil
        end
        return SCOLoadEnhancementSprite(
            "UI/Sprites/Icons/Enhancements/"
                .. folder .. "/" .. icon .. ".sansprite")
    end

    local function SCOLoadEnhancementClearIcon()
        return SCOLoadEnhancementSprite(
            "UI/Sprites/Icons/Enhancements/clear.sansprite")
    end

    local function SCOExactlyOneCommander(units)
        local result = nil
        local count = 0
        for _, unit in pairs(units or {}) do
            count = count + 1
            if count > 1 then return nil end
            result = unit
        end
        if count ~= 1 or not SCOSupportedCommanders[SCOUnitTpId(result)] then
            return nil
        end
        return result
    end

    local function SCOCommanderContract(unit)
        local contract = _G.SCO_CommanderEnhancementContract
        local commanders = type(contract) == "table" and contract.commanders
        local commander = type(commanders) == "table"
            and commanders[SCOUnitTpId(unit)]
        if type(commander) ~= "table"
            or type(commander.enhancements) ~= "table"
        then
            return nil
        end
        return commander
    end

    local function SCOCurrentSelectedCommander()
        local selection = Import("client/input/selectionSystem.lua")
        return SCOExactlyOneCommander(selection.GetSelectedUnits())
    end

    local function SCOState(unit)
        local getter = _G.SCO_GetCommanderEnhancementClientState
        return type(getter) == "function" and getter(unit) or nil
    end

    local function SCORequest(action, unit, enhancementId)
        local request = _G.SCO_CommanderEnhancementClientRequest
        if type(request) ~= "function" or not unit or not unit.id then
            return false
        end
        return request(action, unit.id, enhancementId) == true
    end

    local function SCOBlueprintModule()
        local ok, module = pcall(Import, "client/ui/scoBlueprints.lua")
        return ok and type(module) == "table" and module or nil
    end

    local function SCOIsBlueprintActive()
        local module = SCOBlueprintModule()
        if not module or type(module.IsBlueprintUIActive) ~= "function" then
            return false
        end
        local ok, active = pcall(module.IsBlueprintUIActive)
        return ok and active == true
    end

    local function SCOLeaveBlueprintUI()
        local module = SCOBlueprintModule()
        if module and type(module.LeaveBlueprintUI) == "function" then
            pcall(module.LeaveBlueprintUI)
        end
    end

    local function SCOIsCompleted(unit)
        if not unit or type(unit.IsCompleted) ~= "function" then return false end
        local ok, completed = pcall(unit.IsCompleted, unit)
        return ok and completed == true
    end

    local function SCORequirementIds(value)
        local ids = {}
        if type(value) == "string" then
            ids[1] = value
        elseif type(value) == "table" then
            for key, entry in pairs(value) do
                local candidate = nil
                if type(entry) == "string" then
                    candidate = entry
                elseif entry == true and type(key) == "string" then
                    candidate = key
                end
                if candidate then ids[#ids + 1] = candidate end
            end
        end
        table.sort(ids)
        return ids
    end

    local function SCOFirstInstalled(ids, installed)
        for _, enhancementId in ipairs(ids) do
            if installed[enhancementId] then return enhancementId end
        end
        return nil
    end

    local function SCOFirstMissing(ids, installed)
        for _, enhancementId in ipairs(ids) do
            if not installed[enhancementId] then return enhancementId end
        end
        return nil
    end

    local function SCORuleName(commander, enhancementId)
        local rule = commander.enhancements[enhancementId]
        return type(rule) == "table" and rule.name or enhancementId
    end

    local function SCOCanRemove(rule)
        local cost = type(rule.removal) == "table"
            and rule.removal.cost
        return type(cost) == "table"
            and SCOFinite(cost.mass) and cost.mass >= 0
            and SCOFinite(cost.energy) and cost.energy >= 0
            and SCOFinite(cost.buildTime) and cost.buildTime > 0
    end

    local function SCOInstalledDependent(commander, installed, prerequisiteId)
        for installedId in pairs(installed or {}) do
            local current = commander.enhancements[installedId]
            local prerequisite = type(current) == "table"
                and current.prerequisite
            local visited = {}
            while type(prerequisite) == "string" and not visited[prerequisite] do
                if prerequisite == prerequisiteId then return installedId end
                visited[prerequisite] = true
                current = commander.enhancements[prerequisite]
                prerequisite = type(current) == "table"
                    and current.prerequisite
            end
        end
        return nil
    end

    local function SCOEvaluateAction(unit, commander, rule, state)
        if unit.armyId ~= GetFocusArmy() then
            return nil, "NOT YOUR UNIT"
        end
        if unit.dead == true then return nil, "DESTROYED" end
        if not SCOIsCompleted(unit) then return nil, "INCOMPLETE" end
        if type(state) ~= "table" then return nil, "WAITING FOR HOST" end

        local active = state.active
        if type(active) == "table" then
            if active.id == rule.id then return "cancel", nil end
            return nil, "UPGRADING " .. SCORuleName(commander, active.id)
        end
        if state.idle ~= true then return nil, "COMMANDER MUST BE IDLE" end
        if state.installed[rule.id] then
            local dependent = SCOInstalledDependent(
                commander,
                state.installed,
                rule.id)
            if dependent then
                return nil, "REMOVE "
                    .. SCORuleName(commander, dependent)
                    .. " FIRST"
            end
            if SCOCanRemove(rule) then return "remove", nil end
            return nil, "INSTALLED"
        end

        local capability = type(state.capabilities) == "table"
            and type(state.capabilities.enhancements) == "table"
            and state.capabilities.enhancements[rule.id]
        if type(capability) ~= "table" or capability.install ~= true then
            local capabilityReason = type(capability) == "table"
                and capability.reason
            if type(capabilityReason) ~= "string" or capabilityReason == "" then
                capabilityReason = "UNSUPPORTED BY THIS SANCTUARY RUNTIME"
            end
            return nil, capabilityReason
        end

        local missing = SCOFirstMissing(
            SCORequirementIds(rule.prerequisite),
            state.installed)
        if missing then
            return nil, "REQUIRES " .. SCORuleName(commander, missing)
        end
        local conflict = SCOFirstInstalled(
            SCORequirementIds(rule.conflicts),
            state.installed)
        if conflict then
            return nil, "CONFLICTS WITH " .. SCORuleName(commander, conflict)
        end
        local occupied = state.slots[rule.slot]
        -- A chained enhancement is allowed to replace its prerequisite in the
        -- same slot (T2 -> T3 engineering, normal -> heavy shield, and the
        -- analogous stock FA chains).  Keep this identical to host validation.
        if occupied and occupied ~= rule.prerequisite then
            return nil, "REMOVE " .. SCORuleName(commander, occupied)
        end
        return "install", nil
    end

    local function SCOEnhancementActionFingerprint(state)
        if type(state) ~= "table" then return nil end

        local installedIds = {}
        for enhancementId, installed in pairs(state.installed or {}) do
            if installed == true and type(enhancementId) == "string" then
                installedIds[#installedIds + 1] = enhancementId
            end
        end
        table.sort(installedIds)

        local slotValues = {}
        for _, slot in ipairs(SCOEnhancementSlotOrder) do
            slotValues[#slotValues + 1] = slot .. "="
                .. tostring((state.slots or {})[slot] or "")
        end

        local active = type(state.active) == "table" and state.active or nil
        return table.concat({
            state.idle == true and "idle" or "busy",
            active and (tostring(active.id) .. ":" .. tostring(active.kind)) or "",
            table.concat(installedIds, ","),
            table.concat(slotValues, ","),
        }, "|")
    end

    local function SCOFormatNumber(value)
        if value == math.floor(value) then
            return string.format("%.0f", value)
        end
        if math.abs(value) < 0.1 then
            return string.format("%.2f", value)
        end
        return string.format("%.1f", value)
    end

    local function SCOCostText(cost, unit, active)
        if type(cost) ~= "table" then return "Cost unavailable" end
        local mass = SCOFinite(cost.mass) and cost.mass or 0
        local energy = SCOFinite(cost.energy) and cost.energy or 0
        local work = SCOFinite(cost.buildTime) and cost.buildTime or 0
        local buildPower = type(active) == "table"
            and active.buildPower or (unit and unit.buildPower)
        local text = SCOFormatNumber(mass) .. " alloys / "
            .. SCOFormatNumber(energy) .. " energy"
        if SCOFinite(buildPower) and buildPower > 0 then
            text = text .. "\nBuild power: " .. SCOFormatNumber(buildPower)
            if not active then
                text = text .. " (~" .. SCOFormatNumber(work / buildPower) .. "s)"
            end
        end
        return text
    end

    local function SCOButtonText(action, reason, state)
        if action == "cancel" then
            local fraction = state.active and state.active.fraction or 0
            return tostring(math.floor(fraction * 100 + 0.5)) .. "%"
        end
        -- Stock Supreme Commander presents names and availability in tooltips.
        -- Keep compact button faces icon-only; disabled tint and the tooltip
        -- carry locked/removal state without overlapping adjacent buttons.
        return ""
    end

    local function SCOButtonData(unit, rule, text, enabled)
        local general = unit.tp and unit.tp.general or {}
        return {
            text = text,
            foreground = SCOLoadEnhancementIcon(unit, rule)
                or general.foregroundIconID
                or { index = 0 },
            background = general.backgroundIconID or { index = 0 },
            frame = { index = 0 },
            -- Asset ID zero leaves Sanctuary's default unknown strategic icon
            -- in place. A valid transparent sprite explicitly clears it.
            icon = SCOLoadEnhancementClearIcon() or { index = 0 },
            iconGlowColor = EngineClasses.float3(0, 0, 0),
            emitClickEvents = enabled,
            emitHoverEvents = false,
        }
    end

    local function SCOSetTooltip(button, title, description)
        Engine.UI_SetButtonTooltip(button.buttonID, title, description)
    end


    local function SCOEnhancementDescription(unit, rule, slot, action, reason, state)
        local active = action == "cancel" and state and state.active or nil
        local cost = rule.cost
        if (action == "remove" or (active and active.kind == "remove"))
            and type(rule.removal) == "table"
        then
            cost = rule.removal.cost
        end
        local description = "Slot: " .. SCOEnhancementSlotNames[slot] .. ". "
            .. tostring(rule.description or "")
            .. "\nCost: " .. SCOCostText(cost, unit, active)
        if state and state.installed[rule.id] and not active then
            description = description .. "\nInstalled."
        end
        if active then
            description = description .. "\nProgress: "
                .. SCOButtonText(action, reason, state)
            if active.paused == true then
                description = description .. " (paused)"
            elseif SCOFinite(active.buildPower) and active.buildPower > 0 then
                local remaining = math.max(0, active.buildTime - active.progress)
                description = description .. " / ~"
                    .. SCOFormatNumber(remaining / active.buildPower) .. "s remaining"
            end
            description = description .. "\nClick to cancel."
        elseif action == "remove" then
            description = description .. "\nRight-click to confirm removal."
        elseif reason then
            description = description .. "\nUnavailable: " .. reason .. "."
        else
            description = description .. "\nClick to install."
        end
        local capability = state and type(state.capabilities) == "table"
            and type(state.capabilities.enhancements) == "table"
            and state.capabilities.enhancements[rule.id]
        if type(capability) == "table" and capability.partial == true
            and capability.reason ~= "projectile-presentation-adapted"
        then
            local limitation = "Some effects of this upgrade are unavailable."
            if type(capability.reason) == "string"
                and string.find(capability.reason, "overcharge", 1, true)
            then
                limitation = "Overcharge is unavailable."
            end
            description = description .. "\n" .. limitation
        end
        return description
    end

    -- Canonical snapshots are immutable. Compare the control state separately
    -- from progress; a percentage/rate update must not return hovered buttons
    -- to Unity's pool or reconstruct the surrounding tab and heading rows.
    local function SCOEqualControlState(left, right)
        if type(left) ~= type(right) then return false end
        if type(left) ~= "table" then return left == right end
        for key, value in pairs(left) do
            if not SCOEqualControlState(value, right[key]) then return false end
        end
        for key in pairs(right) do
            if left[key] == nil then return false end
        end
        return true
    end

    local function SCOConstructionInputs(unit, options)
        if not unit then return nil end
        local copiedOptions = {}
        for tpId, available in pairs(options or {}) do
            copiedOptions[tpId] = available
        end
        return {
            unitKey = SCOUnitKey(unit),
            armyId = unit.armyId,
            focusArmy = GetFocusArmy(),
            dead = unit.dead == true,
            completed = SCOIsCompleted(unit),
            options = copiedOptions,
        }
    end

    local function SCOAbilityTargetState()
        local getter = rawget(_G, "SCO_GetCommanderAbilityTargetInputState")
        if type(getter) ~= "function" then return nil end
        local ok, state = pcall(getter)
        return ok and type(state) == "table" and state or nil
    end

    local function SCORefreshEnhancementProgress(panel, unit)
        local rendered = panel.scoCommanderEnhancementRendered
        local state = SCOState(unit)
        if type(rendered) ~= "table" or type(state) ~= "table"
            or type(Engine.UI_SetButtonText) ~= "function"
            or type(Engine.UI_SetButtonProgress) ~= "function"
            or rendered.armyId ~= unit.armyId
            or rendered.focusArmy ~= GetFocusArmy()
            or rendered.fingerprint ~= SCOEnhancementActionFingerprint(state)
            or not SCOEqualControlState(rendered.state.capabilities, state.capabilities)
            or not SCOEqualControlState(rendered.state.abilities, state.abilities)
            or not SCOEqualControlState(rendered.target, SCOAbilityTargetState())
        then
            return false
        end
        local commander = SCOCommanderContract(unit)
        for _, entry in ipairs(rendered.buttons) do
            local action, reason = SCOEvaluateAction(unit, commander, entry.rule, state)
            if action ~= entry.action or reason ~= entry.reason then return false end
        end
        for _, entry in ipairs(rendered.buttons) do
            local text = SCOButtonText(entry.action, entry.reason, state)
            if text ~= entry.text then
                Engine.UI_SetButtonText(entry.button.buttonID, text)
                entry.text = text
            end
            if entry.action == "cancel" and entry.fraction ~= state.active.fraction then
                Engine.UI_SetButtonProgress(entry.button.buttonID, state.active.fraction)
                entry.fraction = state.active.fraction
            end
            local description = SCOEnhancementDescription(
                unit, entry.rule, entry.slot, entry.action, entry.reason, state)
            if description ~= entry.description then
                SCOSetTooltip(entry.button, entry.rule.name, description)
                entry.description = description
            end
        end
        rendered.state = state
        return true
    end

    local SCOShowRemovalConfirmation

    local function SCOHandleEnhancementClick(_, payload)
        local unit = SCOCurrentSelectedCommander()
        if not unit or SCOUnitKey(unit) ~= payload.unitKey then return end
        local commander = SCOCommanderContract(unit)
        local rule = commander and commander.enhancements[payload.enhancementId]
        local state = SCOState(unit)
        if not rule or payload.enhancementFingerprint
            ~= SCOEnhancementActionFingerprint(state)
        then return end
        local action = SCOEvaluateAction(unit, commander, rule, state)
        if action ~= payload.action or (action ~= "install" and action ~= "cancel") then
            return
        end
        SCORequest(action, unit, payload.enhancementId)
    end

    local function SCOValidatedRemovalContext(payload)
        if type(payload) ~= "table"
            or type(payload.enhancementId) ~= "string"
            or type(payload.enhancementFingerprint) ~= "string"
            or payload.consumed == true
        then
            return nil
        end
        local unit = SCOCurrentSelectedCommander()
        if not unit or SCOUnitKey(unit) ~= payload.unitKey then return nil end
        local commander = SCOCommanderContract(unit)
        local rule = commander
            and commander.enhancements[payload.enhancementId]
        if type(rule) ~= "table"
            or rule.id ~= payload.enhancementId
            or rule.slot ~= payload.slot
        then
            return nil
        end
        local state = SCOState(unit)
        if type(state) ~= "table"
            or SCOEnhancementActionFingerprint(state)
                ~= payload.enhancementFingerprint
        then
            return nil
        end
        local action = SCOEvaluateAction(unit, commander, rule, state)
        if action ~= "remove" then return nil end
        return unit, commander, rule, state
    end

    local function SCOHandleEnhancementRemove(_, payload)
        local unit, commander, rule, state =
            SCOValidatedRemovalContext(payload)
        if not unit then return end
        SCOShowRemovalConfirmation(
            payload.panel,
            unit,
            commander,
            rule,
            state,
            payload.slot)
    end

    local function SCOOrderedSlotRules(commander, slot)
        local rulesById = {}
        for enhancementId, rule in pairs(commander.enhancements) do
            if type(rule) == "table"
                and type(rule.id) == "string"
                and rule.id == enhancementId
                and type(rule.name) == "string"
                and rule.slot == slot
            then
                rulesById[enhancementId] = rule
            end
        end

        local roots = {}
        local children = {}
        for enhancementId, rule in pairs(rulesById) do
            local prerequisite = rule.prerequisite
            if type(prerequisite) == "string"
                and rulesById[prerequisite] ~= nil
            then
                children[prerequisite] = children[prerequisite] or {}
                children[prerequisite][#children[prerequisite] + 1] = enhancementId
            else
                roots[#roots + 1] = enhancementId
            end
        end
        table.sort(roots)
        for _, ids in pairs(children) do table.sort(ids) end

        local ordered = {}
        local visited = {}
        local function AppendChain(enhancementId, startsChain)
            if visited[enhancementId] or rulesById[enhancementId] == nil then
                return
            end
            visited[enhancementId] = true
            ordered[#ordered + 1] = {
                rule = rulesById[enhancementId],
                startsChain = startsChain,
            }
            for _, childId in ipairs(children[enhancementId] or {}) do
                AppendChain(childId, false)
            end
        end
        for _, rootId in ipairs(roots) do AppendChain(rootId, true) end

        -- Contract validation rejects prerequisite cycles, but retaining a
        -- deterministic fallback keeps a malformed UI payload fail-visible.
        local remaining = {}
        for enhancementId in pairs(rulesById) do
            if not visited[enhancementId] then
                remaining[#remaining + 1] = enhancementId
            end
        end
        table.sort(remaining)
        for _, enhancementId in ipairs(remaining) do
            AppendChain(enhancementId, true)
        end
        return ordered
    end

    local function SCOHasEnhancements(commander)
        for _, slot in ipairs(SCOEnhancementSlotOrder) do
            if #SCOOrderedSlotRules(commander, slot) > 0 then return true end
        end
        return false
    end

    local function SCOShowEnhancements(panel, unit)
        local commander = SCOCommanderContract(unit)
        if not commander then return end
        if not SCOHasEnhancements(commander) then return end
        local previousConfirmation =
            panel.scoCommanderEnhancementRemovalConfirmation
        if type(previousConfirmation) == "table" then
            previousConfirmation.consumed = true
        end
        panel.scoCommanderEnhancementRemovalConfirmation = nil
        if type(TempBuildMode) == "table"
            and type(TempBuildMode.SetBuildMode) == "function"
        then
            TempBuildMode.SetBuildMode(false)
        end
        SCOLeaveBlueprintUI()
        panel.hoveredTemplate = nil
        panel.constructionButtons:ClearButtons()
        currentDisplayedTemplates = {}
        currentIsFactory = false
        currentSelectedUnits = { unit }

        local state = SCOState(unit)
        if not state and unit.armyId == GetFocusArmy() then
            SCORequest("state", unit)
        end
        local rendered = {
            state = state,
            fingerprint = SCOEnhancementActionFingerprint(state),
            armyId = unit.armyId,
            focusArmy = GetFocusArmy(),
            target = SCOAbilityTargetState(),
            buttons = {},
        }
        panel.scoCommanderEnhancementRendered = state and rendered or nil
        local hasVisibleGroup = false
        local populateAbilities =
            rawget(_G, "SCO_CommanderAbilityPopulateConstructionButtons")
        if type(populateAbilities) == "function" then
            local ok, added = pcall(
                populateAbilities,
                panel,
                unit,
                commander,
                state,
                {
                    loadEnhancementIcon = SCOLoadEnhancementIcon,
                    loadClearIcon = SCOLoadEnhancementClearIcon,
                    setTooltip = SCOSetTooltip,
                    unitKey = SCOUnitKey,
                })
            hasVisibleGroup = ok and added == true
        end
        for _, slot in ipairs(SCOEnhancementSlotOrder) do
            local orderedRules = SCOOrderedSlotRules(commander, slot)
            if #orderedRules > 0 and hasVisibleGroup then
                panel.constructionButtons:AddSeparator()
            end
            local firstRule = true
            for _, entry in ipairs(orderedRules) do
                if not firstRule and entry.startsChain then
                    panel.constructionButtons:AddSeparator()
                end
                firstRule = false
                local rule = entry.rule
                local action, reason = SCOEvaluateAction(
                    unit,
                    commander,
                    rule,
                    state)
                local enabled = action ~= nil
                local payload = {
                    action = action,
                    enhancementId = rule.id,
                    unitKey = SCOUnitKey(unit),
                    panel = panel,
                    slot = slot,
                    enhancementFingerprint =
                        SCOEnhancementActionFingerprint(state),
                }
                local button = panel.constructionButtons:AddButton(
                    SCOButtonData(
                        unit,
                        rule,
                        SCOButtonText(action, reason, state),
                        enabled),
                    enabled and action ~= "remove"
                        and SCOHandleEnhancementClick or nil,
                    enabled and action == "remove"
                        and SCOHandleEnhancementRemove or nil,
                    nil,
                    nil,
                    payload)
                button:SetDisabled(not enabled)
                if action == "cancel"
                    and type(Engine.UI_SetButtonProgress) == "function"
                then
                    Engine.UI_SetButtonProgress(
                        button.buttonID,
                        state.active.fraction)
                end

                local description = SCOEnhancementDescription(
                    unit, rule, slot, action, reason, state)
                SCOSetTooltip(button, rule.name, description)
                rendered.buttons[#rendered.buttons + 1] = {
                    button = button, rule = rule, slot = slot,
                    action = action, reason = reason, description = description,
                    text = SCOButtonText(action, reason, state),
                    fraction = action == "cancel" and state.active.fraction or nil,
                }
            end
            if #orderedRules > 0 then hasVisibleGroup = true end
        end
        panel:SetConstructionEnabled(true)
        panel:SetConstructionFilterEnabled(true)
    end

    SCOShowRemovalConfirmation = function(
        panel,
        unit,
        commander,
        rule,
        state,
        slot)
        panel.hoveredTemplate = nil
        panel.constructionButtons:ClearButtons()
        currentDisplayedTemplates = {}
        currentIsFactory = false
        currentSelectedUnits = { unit }

        local payload = {
            panel = panel,
            unitKey = SCOUnitKey(unit),
            enhancementId = rule.id,
            slot = slot,
            enhancementFingerprint =
                SCOEnhancementActionFingerprint(state),
            consumed = false,
        }
        panel.scoCommanderEnhancementRemovalConfirmation = payload
        local yesButton = panel.constructionButtons:AddButton(
            SCOButtonData(unit, rule, "YES", true),
            function(_, confirmation)
                if confirmation.consumed then return end
                local currentUnit =
                    SCOValidatedRemovalContext(confirmation)
                if not currentUnit then
                    confirmation.consumed = true
                    confirmation.panel.scoCommanderEnhancementRemovalConfirmation = nil
                    local selected = SCOCurrentSelectedCommander()
                    if selected
                        and SCOUnitKey(selected) == confirmation.unitKey
                    then
                        SCOShowEnhancements(confirmation.panel, selected)
                    end
                    return
                end
                confirmation.consumed = true
                confirmation.panel.scoCommanderEnhancementRemovalConfirmation = nil
                SCORequest(
                    "remove",
                    currentUnit,
                    confirmation.enhancementId)
                SCOShowEnhancements(confirmation.panel, currentUnit)
            end,
            nil,
            nil,
            nil,
            payload)
        SCOSetTooltip(
            yesButton,
            "Remove " .. rule.name .. "?",
            "Confirm removal from the commander's "
                .. string.lower(SCOEnhancementSlotNames[slot])
                .. ". Removal cost: "
                .. SCOCostText(rule.removal and rule.removal.cost, unit)
                .. ".")

        local noButton = panel.constructionButtons:AddButton(
            SCOButtonData(unit, rule, "NO", true),
            function(_, confirmation)
                confirmation.consumed = true
                confirmation.panel.scoCommanderEnhancementRemovalConfirmation = nil
                local selected = SCOCurrentSelectedCommander()
                if not selected
                    or SCOUnitKey(selected) ~= confirmation.unitKey
                then
                    return
                end
                SCOShowEnhancements(confirmation.panel, selected)
            end,
            nil,
            nil,
            nil,
            payload)
        SCOSetTooltip(
            noButton,
            "Keep " .. rule.name,
            "Cancel without removing this enhancement.")
        panel:SetConstructionEnabled(true)
        panel:SetConstructionFilterEnabled(true)
    end

    local function SCOMarkEnhancementFilters(panel, upgradesButton)
        for _, button in pairs(panel.constructionFilteringButtons.buttons) do
            local payload = button.payload
            if type(payload) ~= "table"
                or payload.scoEnhancementSectionHeading ~= true
            then
                button:SetActive(button == upgradesButton)
            end
        end
    end

    local function SCOResetEnhancementPanelState(panel)
        local confirmation = panel.scoCommanderEnhancementRemovalConfirmation
        if type(confirmation) == "table" then confirmation.consumed = true end
        panel.scoCommanderEnhancementRendered = nil
        panel.scoCommanderEnhancementFilterActive = false
        panel.scoCommanderEnhancementUnitKey = nil
        panel.scoCommanderEnhancementSectionHeadings = nil
        panel.scoCommanderEnhancementRemovalConfirmation = nil
        panel.scoCommanderEnhancementConstructionInputs = nil
        panel.scoCommanderEnhancementConstructionUnit = nil
    end

    local function SCOClearEnhancementFilterControls(panel)
        local headings = panel.scoCommanderEnhancementSectionHeadings
        if type(headings) ~= "table" or next(headings) == nil then
            return false
        end
        panel.constructionFilteringButtons:ClearButtons()
        return true
    end

    local function SCONativeTierOrdinal(panel, payload)
        if type(payload) ~= "table"
            or type(payload.templatesInTier) ~= "table"
        then
            return nil
        end
        local ordinal = 0
        for _, button in ipairs(
            panel.constructionFilteringButtons.buttons)
        do
            local candidate = button.payload
            if type(candidate) == "table"
                and candidate.panel == panel
                and type(candidate.templatesInTier) == "table"
            then
                ordinal = ordinal + 1
                if button == payload.button then return ordinal end
            end
        end
        return nil
    end

    local function SCOFindNativeTierButton(panel, ordinal)
        local current = 0
        for _, button in ipairs(
            panel.constructionFilteringButtons.buttons)
        do
            local payload = button.payload
            if type(payload) == "table"
                and payload.panel == panel
                and type(payload.templatesInTier) == "table"
            then
                current = current + 1
                if current == ordinal then return button end
            end
        end
        return nil
    end

    local function SCOHighestBuildableTier(options)
        local highest = nil
        for tpId, available in pairs(options or {}) do
            local template = available and __Templates.Units[tpId]
            local tech = template and template.general
                and template.general.techNumber
            if SCOFinite(tech) and tech >= 1 and tech == math.floor(tech)
                and (highest == nil or tech > highest)
            then
                highest = tech
            end
        end
        return highest
    end

    local function SCOClearNativeTierState(panel)
        panel.scoCommanderBuildTierUnitKey = nil
        panel.scoCommanderHighestBuildableTier = nil
        panel.scoCommanderManualTierUnitKey = nil
        panel.scoCommanderManualTierOrdinal = nil
    end

    local function SCORecordManualTier(panel, payload, ordinal)
        local unit = type(payload) == "table"
            and type(payload.units) == "table"
            and SCOExactlyOneCommander(payload.units)
        local unitKey = SCOUnitKey(unit)
        if not unitKey or not ordinal then return end
        panel.scoCommanderManualTierUnitKey = unitKey
        panel.scoCommanderManualTierOrdinal = ordinal
    end

    local function SCOSelectNativeTier(panel, ordinal)
        local button = SCOFindNativeTierButton(panel, ordinal)
        local payload = button and button.payload
        if type(payload) ~= "table"
            or type(payload.templatesInTier) ~= "table"
            or next(payload.templatesInTier) == nil
        then
            return false
        end
        SCOPreviousConstructionFilterLeftClick({}, payload)
        button:SetActive(true)
        return true
    end

    local function SCOAddEnhancementSectionHeadings(
        panel,
        commander,
        upgrades)
        for _, slot in ipairs(SCOEnhancementSlotOrder) do
            if upgrades.sectionHeadings[slot] == nil
                and #SCOOrderedSlotRules(commander, slot) > 0
            then
                local headingPayload = {
                    panel = panel,
                    unitKey = upgrades.unitKey,
                    slot = slot,
                    scoEnhancementSectionHeading = true,
                }
                local heading = panel.constructionFilteringButtons:AddButton(
                    {
                        text = SCOEnhancementSlotLabels[slot],
                        foreground = { index = 0 },
                        background = { index = 0 },
                        frame = { index = 0 },
                        icon = { index = 0 },
                        iconGlowColor = EngineClasses.float3(0, 0, 0),
                        emitClickEvents = false,
                        emitHoverEvents = false,
                    },
                    nil,
                    nil,
                    nil,
                    nil,
                    headingPayload)
                upgrades.sectionHeadings[slot] = heading
            end
        end
        panel.scoCommanderEnhancementSectionHeadings =
            upgrades.sectionHeadings
    end

    local function SCOAddEnhancementFilter(panel, unit, activate)
        local commander = SCOCommanderContract(unit)
        if not commander or not SCOHasEnhancements(commander) then return end
        local payload = {
            panel = panel,
            unitKey = SCOUnitKey(unit),
            sectionHeadings = {},
        }
        local button = panel.constructionFilteringButtons:AddButton(
            {
                text = "UPG",
                foreground = { index = 0 },
                background = { index = 0 },
                frame = { index = 0 },
                icon = SCOLoadEnhancementClearIcon() or { index = 0 },
                iconGlowColor = EngineClasses.float3(0, 0, 0),
                emitClickEvents = true,
                emitHoverEvents = false,
            },
            function(_, clickPayload)
                local selected = SCOCurrentSelectedCommander()
                if not selected
                    or SCOUnitKey(selected) ~= clickPayload.unitKey
                then
                    return
                end
                local targetPanel = clickPayload.panel
                local targetCommander = SCOCommanderContract(selected)
                if not targetCommander
                    or not SCOHasEnhancements(targetCommander)
                then return end
                targetPanel.scoCommanderEnhancementFilterActive = true
                targetPanel.scoCommanderEnhancementUnitKey = clickPayload.unitKey
                SCOAddEnhancementSectionHeadings(
                    targetPanel,
                    targetCommander,
                    clickPayload)
                SCOMarkEnhancementFilters(targetPanel, clickPayload.button)
                if SCOState(selected) ~= nil then
                    SCORequest("state", selected)
                end
                SCOShowEnhancements(targetPanel, selected)
            end,
            nil,
            nil,
            nil,
            payload)
        payload.button = button
        SCOSetTooltip(
            button,
            "Commander Upgrades",
            "Show all Left Arm, Back, and Right Arm upgrades.")

        panel:SetConstructionFilterEnabled(true)
        if activate then
            SCOAddEnhancementSectionHeadings(panel, commander, payload)
            SCOMarkEnhancementFilters(panel, button)
            SCOShowEnhancements(panel, unit)
        end
    end

    function ConstructionPanel:UpdateConstructionPanel(
        units,
        constructionOptions,
        hasEngineerOptions,
        hasFactoryOptions)
        local hadEnhancementHeadings =
            type(self.scoCommanderEnhancementSectionHeadings) == "table"
            and next(self.scoCommanderEnhancementSectionHeadings) ~= nil
        local commander = SCOExactlyOneCommander(units)
        local unitKey = SCOUnitKey(commander)
        local highestBuildableTier =
            SCOHighestBuildableTier(constructionOptions)
        local previousTierUnitKey = self.scoCommanderBuildTierUnitKey
        local previousHighestBuildableTier =
            self.scoCommanderHighestBuildableTier
        if SCOIsBlueprintActive() then
            SCOResetEnhancementPanelState(self)
        end
        local pendingRemovalConfirmation =
            self.scoCommanderEnhancementRemovalConfirmation
        local keepEnhancementFilter = commander ~= nil
            and self.scoCommanderEnhancementFilterActive == true
            and self.scoCommanderEnhancementUnitKey == unitKey
        local constructionInputs = SCOConstructionInputs(commander, constructionOptions)
        -- Host progress dirties the entire native UI, even when a build tier is
        -- open. Retain those controls so a refresh between pointer down and up
        -- cannot return the UPGRADES toggle to the native pool.
        if commander and hasEngineerOptions and not hasFactoryOptions
            and self.scoCommanderEnhancementConstructionUnit == commander
            and SCOEqualControlState(
                self.scoCommanderEnhancementConstructionInputs, constructionInputs)
        then
            if keepEnhancementFilter then
                if type(pendingRemovalConfirmation) == "table"
                    and SCOValidatedRemovalContext(pendingRemovalConfirmation)
                then
                    return
                end
                if pendingRemovalConfirmation ~= nil
                    or not SCORefreshEnhancementProgress(self, commander)
                then
                    SCOShowEnhancements(self, commander)
                end
            end
            return
        end
        local removalUnit,
            removalCommander,
            removalRule,
            removalState
        if keepEnhancementFilter
            and type(pendingRemovalConfirmation) == "table"
        then
            removalUnit,
                removalCommander,
                removalRule,
                removalState =
                    SCOValidatedRemovalContext(pendingRemovalConfirmation)
        end
        if type(pendingRemovalConfirmation) == "table" then
            pendingRemovalConfirmation.consumed = true
        end

        SCOPreviousUpdateConstructionPanel(
            self,
            units,
            constructionOptions,
            hasEngineerOptions,
            hasFactoryOptions)

        -- Stock returns before clearing its filter list when selection is empty,
        -- mixed between engineers and factories, or otherwise has no build menu.
        -- Explicitly remove our passive heading buttons in those paths so their
        -- text cannot outlive the hidden construction-filter panel.
        local stockReturnedBeforeFilterClear =
            (hasEngineerOptions and hasFactoryOptions)
            or (not hasEngineerOptions and not hasFactoryOptions)
        if not commander
            and hadEnhancementHeadings
            and stockReturnedBeforeFilterClear
        then
            self.constructionFilteringButtons:ClearButtons()
        end

        self.scoCommanderEnhancementSectionHeadings = nil

        if not commander then
            SCOClearNativeTierState(self)
            SCOResetEnhancementPanelState(self)
            return
        end

        if not keepEnhancementFilter then
            local tierToSelect = nil
            local highestTierAdvanced = highestBuildableTier ~= nil
                and (previousTierUnitKey ~= unitKey
                    or previousHighestBuildableTier == nil
                    or highestBuildableTier > previousHighestBuildableTier)
            local manualTier = self.scoCommanderManualTierUnitKey == unitKey
                and self.scoCommanderManualTierOrdinal
                or nil
            if highestTierAdvanced then
                tierToSelect = highestBuildableTier
                self.scoCommanderManualTierUnitKey = nil
                self.scoCommanderManualTierOrdinal = nil
            elseif manualTier and highestBuildableTier
                and manualTier <= highestBuildableTier
            then
                tierToSelect = manualTier
            elseif highestBuildableTier
                and previousHighestBuildableTier
                and highestBuildableTier < previousHighestBuildableTier
            then
                tierToSelect = highestBuildableTier
                self.scoCommanderManualTierUnitKey = nil
                self.scoCommanderManualTierOrdinal = nil
            end
            if tierToSelect then SCOSelectNativeTier(self, tierToSelect) end
            self.scoCommanderBuildTierUnitKey = unitKey
            self.scoCommanderHighestBuildableTier = highestBuildableTier
        end
        self.scoCommanderEnhancementFilterActive = keepEnhancementFilter
        self.scoCommanderEnhancementUnitKey = unitKey
        SCOAddEnhancementFilter(self, commander, keepEnhancementFilter)
        if removalUnit then
            SCOShowRemovalConfirmation(
                self,
                removalUnit,
                removalCommander,
                removalRule,
                removalState,
                pendingRemovalConfirmation.slot)
        end
        self.scoCommanderEnhancementConstructionInputs = constructionInputs
        self.scoCommanderEnhancementConstructionUnit = commander
    end

    function ConstructionPanel:SetConstructionEnabled(enabled)
        if enabled == false then
            SCOClearEnhancementFilterControls(self)
            SCOClearNativeTierState(self)
            SCOResetEnhancementPanelState(self)
        end
        return SCOPreviousSetConstructionEnabled(self, enabled)
    end

    function ConstructionFilterLeftClickFunction(data, payload)
        local panel = payload and payload.panel
        local wasActive = panel
            and panel.scoCommanderEnhancementFilterActive == true
        local tierOrdinal = panel and SCONativeTierOrdinal(panel, payload)
        if panel then SCOResetEnhancementPanelState(panel) end
        if not panel or not wasActive or not tierOrdinal
            or type(payload.units) ~= "table"
            or type(panel.GetConstructionOptionsForUnits) ~= "function"
        then
            local result = SCOPreviousConstructionFilterLeftClick(data, payload)
            if panel and tierOrdinal then
                SCORecordManualTier(panel, payload, tierOrdinal)
                payload.button:SetActive(true)
            end
            return result
        end

        local constructionOptions,
            hasEngineerOptions,
            hasFactoryOptions =
                panel:GetConstructionOptionsForUnits(payload.units)
        panel:UpdateConstructionPanel(
            payload.units,
            constructionOptions,
            hasEngineerOptions,
            hasFactoryOptions)
        local rebuiltTier = SCOFindNativeTierButton(panel, tierOrdinal)
        if not rebuiltTier then
            return SCOPreviousConstructionFilterLeftClick(data, payload)
        end
        local result = SCOPreviousConstructionFilterLeftClick(
            data,
            rebuiltTier.payload)
        rebuiltTier:SetActive(true)
        SCORecordManualTier(panel, rebuiltTier.payload, tierOrdinal)
        return result
    end

    rawset(
        SCOCommanderEnhancementPanelEnvironment,
        "SCO_CommanderEnhancementConstructionPanelInstalled",
        "1.9.0")
end

-- SCOM support commander scope 80919e5ef7320d08d4e2b19423976e85aff3930a060ae357b3a7e6fe012e7c17 E60A21AB4CBEF814358FA0A6F47D4762DC2C85E25C5C17ED579B11F4EF9401C3
-- Supreme Commander Overhaul commander ability UI 1.1.0
-- Load after commander_enhancement_construction_panel_appendix.lua. Ability
-- controls live inside the distinct ACU upgrade panel and consume only the
-- owner snapshot produced by the authoritative host runtime.
local SCOCommanderAbilityUIEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderAbilityUIMarker = rawget(
    SCOCommanderAbilityUIEnvironment,
    "SCO_CommanderAbilityUIInstalled")
if SCOCommanderAbilityUIMarker ~= nil
    and SCOCommanderAbilityUIMarker ~= "1.1.0"
then
    error("Unsupported SCOM commander-ability UI marker "
        .. tostring(SCOCommanderAbilityUIMarker))
end

if SCOCommanderAbilityUIMarker == nil then
    if rawget(
            SCOCommanderAbilityUIEnvironment,
            "SCO_CommanderEnhancementConstructionPanelInstalled") ~= "1.9.0"
        or type(Engine) ~= "table"
        or type(EngineClasses) ~= "table"
        or type(EngineClasses.float3) ~= "function"
        or type(GetFocusArmy) ~= "function"
    then
        error("SCOM commander ability UI requires enhancement panel 1.9.0")
    end

    local function SCOFinite(value)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
    end

    local function SCOInteger(value, minimum, maximum)
        return SCOFinite(value)
            and value == math.floor(value)
            and value >= minimum
            and value <= maximum
    end

    local function SCOGlobalId(value)
        if type(value) ~= "table"
            or not SCOInteger(value.index, 1, 2147483647)
            or not SCOInteger(value.version, 0, 2147483647)
        then
            return nil
        end
        return { index = value.index, version = value.version }
    end

    local function SCOResolveUnit(unitId)
        local canonical = SCOGlobalId(unitId)
        local units = type(__Entities) == "table" and __Entities.Units
        local unit = canonical and type(units) == "table"
            and units[canonical.index] or nil
        if unit == nil
            or unit.id == nil
            or unit.id.version ~= canonical.version
            or unit.dead == true
            or unit.armyId ~= GetFocusArmy()
        then
            return nil
        end
        return unit
    end

    local function SCORequest(action, unit, target)
        local request = rawget(_G, "SCO_CommanderAbilityClientRequest")
        if type(request) ~= "function" or unit == nil then return false end
        local ok, accepted = pcall(request, action, unit.id, target)
        return ok and accepted == true
    end

    local function SCOBeginTarget(unit, abilityId)
        local begin = rawget(_G, "SCO_CommanderAbilityTargetInputBegin")
        if type(begin) ~= "function" or unit == nil then return false end
        local ok, accepted = pcall(begin, unit, abilityId)
        return ok and accepted == true
    end

    local function SCOCancelTarget(reason)
        local cancel = rawget(_G, "SCO_CommanderAbilityTargetInputCancel")
        if type(cancel) ~= "function" then return false end
        local ok, accepted = pcall(cancel, reason)
        return ok and accepted == true
    end

    local function SCOTargetState()
        local getter = rawget(_G, "SCO_GetCommanderAbilityTargetInputState")
        if type(getter) ~= "function" then return nil end
        local ok, value = pcall(getter)
        return ok and type(value) == "table" and value or nil
    end

    local function SCOSameId(left, right)
        return type(left) == "table" and type(right) == "table"
            and left.index == right.index
            and left.version == right.version
    end

    local function SCOButtonData(unit, rule, text, enabled, helpers)
        local general = unit.tp and unit.tp.general or {}
        return {
            text = text,
            foreground = helpers.loadEnhancementIcon(unit, rule)
                or general.foregroundIconID
                or { index = 0 },
            background = general.backgroundIconID or { index = 0 },
            frame = { index = 0 },
            icon = helpers.loadClearIcon() or { index = 0 },
            iconGlowColor = EngineClasses.float3(0, 0, 0),
            emitClickEvents = enabled,
            emitHoverEvents = false,
        }
    end

    local function SCOAddButton(
        panel,
        unit,
        rule,
        text,
        enabled,
        title,
        description,
        action,
        progress,
        helpers)
        local payload = {
            unitId = SCOGlobalId(unit.id),
            action = action,
        }
        local button = panel.constructionButtons:AddButton(
            SCOButtonData(unit, rule, text, enabled, helpers),
            enabled and function(_, clickPayload)
                local selected = SCOResolveUnit(clickPayload.unitId)
                if selected == nil then return end
                if clickPayload.action == "TeleportTarget" then
                    SCOBeginTarget(selected, "Teleport")
                elseif clickPayload.action == "MissileTarget" then
                    SCOBeginTarget(selected, "MissileLaunch")
                elseif clickPayload.action == "TargetCancel" then
                    SCOCancelTarget("button")
                else
                    SCORequest(clickPayload.action, selected)
                end
            end or nil,
            nil,
            nil,
            nil,
            payload)
        button:SetDisabled(not enabled)
        if SCOFinite(progress)
            and type(Engine.UI_SetButtonProgress) == "function"
        then
            Engine.UI_SetButtonProgress(
                button.buttonID,
                math.max(0, math.min(1, progress)))
        end
        helpers.setTooltip(button, title, description)
        return button
    end

    local function SCOFormatNumber(value)
        if not SCOFinite(value) then return "?" end
        if value == math.floor(value) then return string.format("%.0f", value) end
        return string.format("%.1f", value)
    end

    local function SCOMissileRule(commander, profileId)
        local enhancements = commander and commander.enhancements or {}
        if profileId == "uefBilly" then
            return enhancements.TacticalNukeMissile
        elseif profileId == "uefTactical" then
            return enhancements.TacticalMissile
        elseif profileId == "seraphimTactical" or profileId == "sacuSeraphimTactical" then
            return enhancements.Missile
        end
        return nil
    end

    local function SCOCloakRule(commander, mode)
        local enhancements = commander and commander.enhancements or {}
        if mode == "cloak" then return enhancements.CloakingGenerator end
        if mode == "stealth" then return enhancements.StealthGenerator end
        return nil
    end

    local function SCOPopulateAbilities(
        panel,
        unit,
        commander,
        state,
        helpers)
        if type(panel) ~= "table"
            or type(unit) ~= "table"
            or type(commander) ~= "table"
            or type(state) ~= "table"
            or type(state.abilities) ~= "table"
            or type(helpers) ~= "table"
            or type(helpers.loadEnhancementIcon) ~= "function"
            or type(helpers.loadClearIcon) ~= "function"
            or type(helpers.setTooltip) ~= "function"
        then
            return false
        end

        local added = false
        local target = SCOTargetState()
        local enhancementBusy = state.active ~= nil
        local teleport = state.abilities.teleport
        local missile = state.abilities.missile
        local cloakMode = state.abilities.cloakMode
        local cloakRule = SCOCloakRule(commander, cloakMode)
        if type(cloakRule) == "table" then
            local cloakEnabled = state.abilities.cloakEnabled == true
            local upkeep = state.abilities.cloakEnergyUpkeep
            if not SCOFinite(upkeep) then
                upkeep = cloakMode == "cloak" and 3000 or 50
            end
            local fallbackTitle = cloakMode == "cloak"
                and "Personal Cloaking Generator"
                or "Personal Stealth Generator"
            local title = type(cloakRule.name) == "string"
                and cloakRule.name ~= "" and cloakRule.name
                or fallbackTitle
            local description = cloakEnabled
                and ("Enabled. Drains " .. SCOFormatNumber(upkeep)
                    .. " energy per second. Click to disable the field.")
                or ("Disabled. Click to enable the field; upkeep is "
                    .. SCOFormatNumber(upkeep) .. " energy per second.")
            SCOAddButton(
                panel,
                unit,
                cloakRule,
                cloakEnabled and "ON" or "OFF",
                not enhancementBusy,
                title,
                description,
                "CloakToggle",
                nil,
                helpers)
            added = true
        end

        -- UEF counted missiles use the stock ManualFire2 orders control. Keep
        -- this panel's explicit build/launch pair only for manual-build
        -- profiles (currently the Seraphim ACU).
        if type(missile) == "table"
            and missile.available == true
            and missile.autoBuild ~= true
        then
            local rule = SCOMissileRule(commander, missile.profileId)
            if type(rule) == "table" then
                local cost = type(missile.buildCost) == "table"
                    and missile.buildCost or {}
                local isBuilding = missile.building == true
                local storageFull = SCOFinite(missile.ammo)
                    and SCOFinite(missile.maxAmmo)
                    and missile.ammo >= missile.maxAmmo
                local buildEnabled = isBuilding
                    or (not storageFull
                        and not enhancementBusy
                        and (type(teleport) ~= "table"
                            or teleport.active ~= true))
                local buildText = isBuilding
                    and (tostring(math.floor(
                        (missile.fraction or 0) * 100 + 0.5)) .. "%")
                    or "BUILD"
                local buildAction = isBuilding
                    and "MissileBuildCancel" or "MissileBuild"
                local buildDescription = isBuilding
                    and "Building one counted missile. Click to cancel; spent resources are not refunded."
                    or ("Build one counted missile (storage 1). Cost: "
                        .. SCOFormatNumber(cost.alloys) .. " alloys, "
                        .. SCOFormatNumber(cost.energy) .. " energy, "
                        .. SCOFormatNumber(missile.buildTime) .. " work.")
                SCOAddButton(
                    panel,
                    unit,
                    rule,
                    buildText,
                    buildEnabled,
                    "Build " .. tostring(missile.name or "Missile"),
                    buildDescription,
                    buildAction,
                    isBuilding and missile.fraction or nil,
                    helpers)
                added = true

                local targeting = type(target) == "table"
                    and target.abilityId == "MissileLaunch"
                    and SCOSameId(target.unitId, unit.id)
                local ammoReady = SCOFinite(missile.ammo)
                    and missile.ammo >= 1
                local cooldownReady = not SCOFinite(missile.cooldownRemaining)
                    or missile.cooldownRemaining <= 0
                local launchEnabled = targeting
                    or (ammoReady
                        and cooldownReady
                        and not isBuilding
                        and not enhancementBusy
                        and (type(teleport) ~= "table"
                            or teleport.active ~= true))
                local launchDescription = targeting
                    and "Selecting a world target. Click here or right-click in the world to cancel."
                    or ("Launch the stored missile from "
                        .. tostring(missile.muzzleBone or "the launcher")
                        .. ". Valid range: "
                        .. SCOFormatNumber(missile.rangeMin) .. " to "
                        .. SCOFormatNumber(missile.rangeMax) .. ".")
                SCOAddButton(
                    panel,
                    unit,
                    rule,
                    targeting and "CANCEL" or "LAUNCH",
                    launchEnabled,
                    "Launch " .. tostring(missile.name or "Missile"),
                    launchDescription,
                    targeting and "TargetCancel" or "MissileTarget",
                    nil,
                    helpers)
                added = true
            end
        end

        local teleportRule = commander.enhancements.Teleporter
        if type(teleport) == "table"
            and teleport.available == true
            and type(teleportRule) == "table"
        then
            local targeting = type(target) == "table"
                and target.abilityId == "Teleport"
                and SCOSameId(target.unitId, unit.id)
            local active = teleport.active == true
            local enabled = active or targeting
                or (state.idle == true
                    and not enhancementBusy
                    and not (type(missile) == "table"
                        and missile.building == true))
            local action = active and "TeleportCancel"
                or (targeting and "TargetCancel" or "TeleportTarget")
            local text = active
                and (tostring(math.floor(
                    (teleport.fraction or 0) * 100 + 0.5)) .. "%")
                or (targeting and "CANCEL" or "TELEPORT")
            local description = active
                and "Teleport charging. Click to cancel; energy already spent is not refunded."
                or (targeting
                    and "Selecting a destination. Click here or right-click in the world to cancel."
                    or ("Choose a clear destination. Activation costs "
                        .. SCOFormatNumber(teleport.energyCost)
                        .. " energy over "
                        .. SCOFormatNumber(teleport.duration)
                        .. " seconds."))
            SCOAddButton(
                panel,
                unit,
                teleportRule,
                text,
                enabled,
                "Personal Teleporter",
                description,
                action,
                active and teleport.fraction or nil,
                helpers)
            added = true
        end
        return added
    end

    local existingPopulate = rawget(
        _G,
        "SCO_CommanderAbilityPopulateConstructionButtons")
    if existingPopulate ~= nil and type(existingPopulate) ~= "function" then
        error("SCOM commander-ability panel hook is occupied")
    end
    _G.SCO_CommanderAbilityPopulateConstructionButtons = SCOPopulateAbilities

    local previousTargetChanged = rawget(
        _G,
        "SCO_CommanderAbilityTargetingChanged")
    if previousTargetChanged ~= nil and type(previousTargetChanged) ~= "function" then
        error("SCOM commander-ability targeting callback is occupied")
    end
    local SCOLastTargetUnitId = nil
    _G.SCO_CommanderAbilityTargetingChanged = function(snapshot, reason)
        if type(previousTargetChanged) == "function" then
            pcall(previousTargetChanged, snapshot, reason)
        end
        local unitId = type(snapshot) == "table"
            and SCOGlobalId(snapshot.unitId) or SCOLastTargetUnitId
        if type(snapshot) == "table" then
            SCOLastTargetUnitId = unitId
        else
            SCOLastTargetUnitId = nil
        end
        local unit = SCOResolveUnit(unitId)
        if unit and type(unit.SetUIDirtyIfSelected) == "function" then
            pcall(unit.SetUIDirtyIfSelected, unit)
        end
    end

    rawset(
        SCOCommanderAbilityUIEnvironment,
        "SCO_CommanderAbilityUIInstalled",
        "1.1.0")
end

return {
    TriggerConstructionHotkey = TriggerConstructionHotkey,
    IsConstructionPanelEnabled = IsConstructionPanelEnabled,
}
