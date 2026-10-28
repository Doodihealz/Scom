    local dragStartScreenPosition, dragStartWorldPosition = DragFormationPreviewSystem.GetDragFormationStartPositions()
    DragFormationPreviewSystem.EndFormationDrag()
                    
    -- Abort if the mouse is not interacting with the actual game world
    if not MouseCursor.IsCursorInGameView() then return end
    -- Check whether the build mode is active
    local buildMode = TempBuildMode.GetBuildMode()
    if buildMode then
        -- Any right click while in build mode cancels it immediately
        TempBuildMode.SetBuildMode(false)
    else
        -- Ignore clicks on UI elements
        if Engine.IsMouseOverUI() then return end
        -- Ignore right click while a selection box drag is active
        if SelectionSystem.SelectionBox:IsActive() then return end

        if isPatrolAttackMoveMode then
            table.insert(patrolAttackMoveWaypoints, MouseCursor.GetMousePosition())
            return
        end
        if isPatrolMode then
            ResetPatrolMode()
            return
        end

        if dragStartScreenPosition and DragFormationPreviewSystem.HasDraggedMinimumDistance(dragStartScreenPosition) then
            local dragEndWorldPosition = MouseCursor.GetMousePosition()
            IssueDragFormationMoveOrder(dragStartWorldPosition, dragEndWorldPosition)
            return
        end
        
        -- Retrieve current unit selection
        ---@type ClientUnit[]
        local selectedUnits = SelectionSystem.GetSelectedUnits()
        local _, firstUnit = next(selectedUnits)

        -- Hard abort if no unit is selected
        if not firstUnit then return end

        -- Determine whether the mouse is hovering a unit or wreck
        local hoverObject = GetHoverUnit()

        -- === CASE 1: Right click on ground (no unit under cursor) ===
        if hoverObject == nil then
            if isAltDown then
                -- ALT + right click on ground issues an attack-move order
                IssueAttackMoveOrder()
            else
                -- Normal right click on ground issues a move order
                -- Additionally sets factory rally point if applicable
                IssueMoveOrder()
                SetFactoryRallyPoint() -- todo: dubious
            end
        -- === CASE 2: Right click on a wreck ===
        elseif hoverObject.entityType == "prop" then
            -- === CASE 2a: Manipulating unit is Engineer or Command unit ===
            if firstUnit:HasTags(Tags.ENGINEER + Tags.COMMAND + Tags.ENGINEERING_STATION) then
                -- Command units and engineers reclaim props
                IssueReclaimOrder()
            end
        -- === CASE 3: Right click on a unit ===
        elseif hoverObject.entityType == "unit" then
            -- Also true if the player owns the unit.
            local isAllyUnit = hoverObject.army:IsAlly(firstUnit.army)
            local isEnemyUnit = hoverObject.army:IsEnemy(firstUnit.army)

            -- === CASE 3a: Manipulating unit is Engineer or Engineering Station or Command unit ===
            if firstUnit:HasTags(Tags.ENGINEER + Tags.COMMAND + Tags.ENGINEERING_STATION) then
                -- On same army or allied army, we get access to building orders.
                if isAllyUnit then
                    -- Target is unfinished: resume build
                    if not hoverObject:IsCompleted() and not hoverObject:IsUpgrading() then
                        IssueRepairOrder() -- TODO: Replace with explicit resume-build command if available; repair currently resumes construction implicitly.
                    -- Target is damaged or being captured/reclaimed: repair
                    elseif hoverObject:GetHealth() < hoverObject:GetMaxHealth() and not hoverObject:IsUpgrading()
                        or (hoverObject.captureProgress or 0) > 0
                        or (hoverObject.reclaimProgress or 0) > 0 then
                        IssueRepairOrder()
                    -- Otherwise assist the unit (default same-army behavior)
                    else
                        IssueAssistOrder()
                    end
                -- Enemy army engineers should attack/capture
                elseif isEnemyUnit then
                    -- Command units attack all other entities
                    -- SCOM Field Fix: Megalith enemy right-click attacks 1.0.0
                    local isMegalith = firstUnit.tpId == "ugl4002"
                        or (firstUnit.tp
                            and firstUnit.tp.general
                            and firstUnit.tp.general.tpId == "ugl4002")
                    if firstUnit:HasTags(Tags.COMMAND) or isMegalith then
                        IssueAttackOrder()
                    elseif not hoverObject:IsCompleted() then
                        -- Reclaim unfinished enemy units.
                        IssueReclaimOrder()
                    else
                        IssueCaptureOrder()
                    end
                else
                    -- If it is a neutral unit do nothing.
                end
            -- === CASE 3b: Manipulating a factory ===
            elseif hoverObject:HasTags(Tags.STRUCTURE * Tags.FACTORY) and firstUnit:HasTags(Tags.STRUCTURE * Tags.FACTORY) then
                -- Factory interaction limited to assisting friendly targets
                if isAllyUnit then
                    IssueAssistOrder()
                end
            -- === CASE 3c: Manipulating unit is NOT Engineer / Engineering Station / Command / Factory ===
            elseif isAllyUnit then
                -- Default behavior for for cobat units: assist
                IssueAssistOrder()
            elseif isEnemyUnit then
                -- Default behavior for combat units: attack
                IssueAttackOrder()
            else
                -- If it is a neutral unit do nothing.
            end
        end
    end
end

-- Match the validated host command limit for selections of any size.
local function SCOForEachCommandBatch(items, send)
    for first = 1, #items, 64 do
        local batch = {}
        for index = first, math.min(first + 63, #items) do
            batch[#batch + 1] = items[index]
        end
        send(batch)
    end
end

---@param toggleName ToggleName
---@param enabled boolean
function SetToggle(toggleName, enabled)
    ---@type ClientUnit[]
    local units = SelectionSystem.GetSelectedUnits()

    ---@type GlobalID[]
    local unitIds = {}
    for _, unit in pairs(units) do
        if unit:HasToggle(toggleName) then
            table.insert(unitIds, unit.id)
        end
    end

    if #unitIds == 0 then
        return
    end

    local toggleType = ToggleNameToToggleType(toggleName)

    local send = Import("common/commands/definitions/toggles.lua").RequestUnitsToggle.Send
    SCOForEachCommandBatch(unitIds, function(batch)
        send(batch, toggleType, enabled)
    end)
end

--- Submerges or surfaces the selected submarines (hotkey U). If any selected
--- submarine is surfaced, all dive; otherwise all surface.
function ToggleSubmergeSelected()
    local units = SelectionSystem.GetSelectedUnits()

    ---@type GlobalID[]
    local unitIds = {}
    local anySurfaced = false

    for _, unit in pairs(units) do
        if unit:CanSubmerge() then
            table.insert(unitIds, unit.id)
            if not unit:GetSubmergeToggle() then
                anySurfaced = true
            end
        end
    end

    if #unitIds == 0 then return end

    local toggleType = ToggleNameToToggleType("Submerge")
    local send = Import("common/commands/definitions/toggles.lua").RequestUnitsToggle.Send
    SCOForEachCommandBatch(unitIds, function(batch)
        send(batch, toggleType, anySurfaced)
    end)
    UIManager.SetUIDirty()
end

function TogglePauseUnits()
    local units = SelectionSystem.GetSelectedUnits()
    local allPaused = true
    local anyPauseable = false
    for _, unit in pairs(units) do
        if unit:GetPause() ~= nil then
            anyPauseable = true
            if not unit:GetPause() then
                allPaused = false
            end
        end
    end
    if not anyPauseable then return end
    SetToggle("Pause", not allPaused)
    UIManager.SetUIDirty()
end

function OnBuildOrderAcknowledged(accepted, predictedUnitLocalID, newUnitGlobalID)
    if accepted then
        local predictedUnit = _G.PredictedUnits[predictedUnitLocalID.index]
        local targetUnit = _G.GetUnitById(newUnitGlobalID)
        targetUnit.predictedBuildQueue = table.deepCopy(predictedUnit.predictedBuildQueue)
        for _, queueItem in ipairs(predictedUnit.predictedBuildQueue) do
            local entryIds = table.shallowCopy(queueItem.entryIds)
            table.insert(targetUnit.buildQueuePendingOperations, {
                tpId = queueItem.tpId,
                entryIds = entryIds,
                targetItemEntryId = 0,
            })
            Import("common/commands/definitions/buildQueue.lua").RequestAddToBuildQueue.Send({ targetUnit.id }, { entryIds }, { 0 }, queueItem.tpId)
        end
        predictedUnit:Delete()
    else
        _G.PredictedUnits[predictedUnitLocalID.index]:Delete()
    end
end

function IssueBuildOrderTemp(placementPositions, builderArmyId)
    local tpId = TempBuildMode.GetBuildTpId()
    local unitTemplate = __Templates.Units[tpId]
    local placementUtils = Import("common/systems/placementUtils.lua")
    local payload = { 
        tpId = tpId,
        armyId = builderArmyId
    }
    local shouldAppend = isAppendingToQueue
    local defaultScale = EngineClasses.float3(1, 1, 1)
    local defaultRotation = GetIdentityQuaternion()
    local iconColor = Armies[builderArmyId]:GetColor()
    iconColor.w = PlacementGhostIconAlpha
    
    for _, position in pairs(placementPositions) do
        position = placementUtils.SnapToBuildGrid(unitTemplate, position)
        local _, predictedUnitLocalID = Engine.InstantiatePrefab(unitTemplate.general.placementGhostPrefabID, position, defaultScale, defaultRotation)
        -- SCOM Field Fix: predicted build ghost team color 1.0.0
        Engine.SetRendererInstanceData0(predictedUnitLocalID, Armies[builderArmyId]:GetColor())
        Engine.SetIconColor(predictedUnitLocalID, 0, iconColor)
        _G.PredictedUnits[predictedUnitLocalID.index] = PredictedUnit(predictedUnitLocalID, GetFocusArmy(), unitTemplate)
        ClientOrderManager.ClientIssueOrder(OrderTasks.BUILD, SelectionSystem.GetSelectedUnits(), shouldAppend, position, payload, function(accepted, newUnitGlobalID) 
            OnBuildOrderAcknowledged(accepted, predictedUnitLocalID, newUnitGlobalID)
        end)

        shouldAppend = true -- even if the first placement was not queued, the next ones will be (line drag)
    end
end

function IssueDragFormationMoveOrder(startPosition, endPosition)
    local validUnits = DragFormation.GetDraggableUnits()
    local assignments, _, _, _, alignDirection = DragFormation.CalculateFormationPositions(startPosition, endPosition, validUnits)
    local orderType = isAltDown and OrderTasks.ATTACKMOVE or OrderTasks.MOVE
    local payload = alignDirection and { alignDirection = { x = alignDirection.x, y = alignDirection.y } } or nil

    -- TODO: Check that we are issuing a move order within map bounds. Clamp the drag points to be within map bounds.

    for _, assignment in ipairs(assignments) do
        local unit = assignment.unit
        ClientOrderManager.ClientIssueOrder(orderType, {[unit.id] = unit}, isAppendingToQueue, assignment.destination, payload)
    end
end

function SetAppendOrderToggle(isAppendActive)
    isAppendingToQueue = isAppendActive
    SelectionSystem.SelectionBox:SetModifySelection(isAppendActive)
    UpdatePatrolAttackMoveMode()
    UpdatePatrolMode()
end

-- dubious
function SetAltToggle(isActive)
    isAltDown = isActive
    UpdatePatrolAttackMoveMode()
end

function SetOrdersVisibile(isOrdersVisible)
    ClientOrderManager.SetOrderDrawEnabled(isOrdersVisible)
end

function IssueClearOrder()
    ClientOrderManager.ClientClearOrder(SelectionSystem.GetSelectedUnits())
end

function IssueMoveOrder()
    if SelectionSystem.SelectionBox:IsActive() then return end
    local shouldAppend = isAppendingToQueue
    local position = MouseCursor.GetMousePosition()
    
    -- TODO: Check that we are issuing a move order within map bounds. Should we clamp into the map bounds?
    
    ClientOrderManager.ClientIssueOrder(OrderTasks.MOVE, SelectionSystem.GetSelectedUnits(), shouldAppend, position)
end

function IssueAttackOrder()
    if SelectionSystem.SelectionBox:IsActive() then return end
    local shouldAppend = isAppendingToQueue
    local hoverUnit = GetHoverUnit()
    if hoverUnit then
        local payload = { targetGlobalId = hoverUnit.id }
        local position = hoverUnit:GetPosition()
        ClientOrderManager.ClientIssueOrder(OrderTasks.ATTACKUNIT, SelectionSystem.GetSelectedUnits(), shouldAppend, position, payload)
    end
end

function IssueAttackMoveOrder()
    if SelectionSystem.SelectionBox:IsActive() then return end
    local shouldAppend = isAppendingToQueue
    local position = MouseCursor.GetMousePosition()

    -- TODO: Check that we are issuing a move order within map bounds. Clamp the drag points to be within map bounds.

    ClientOrderManager.ClientIssueOrder(OrderTasks.ATTACKMOVE, SelectionSystem.GetSelectedUnits(), shouldAppend, position)
end

-- Self-target orders are invalid on the host; omit them before client prediction.
local function SCOUnitsExceptTarget(target)
    local units = {}
    for key, unit in pairs(SelectionSystem.GetSelectedUnits()) do
        if unit.id.index ~= target.id.index or unit.id.version ~= target.id.version then
            units[key] = unit
        end
    end
    return units
end

function IssueRepairOrder()
    if SelectionSystem.SelectionBox:IsActive() then return end
    local shouldAppend = isAppendingToQueue
    local hoverUnit = GetHoverUnit()
    if hoverUnit then
        local payload = { targetGlobalId = hoverUnit.id }
        local position = hoverUnit:GetPosition()
        ClientOrderManager.ClientIssueOrder(OrderTasks.REPAIR, SCOUnitsExceptTarget(hoverUnit), shouldAppend, position, payload)
    end
end

function IssueAssistOrder()
    if SelectionSystem.SelectionBox:IsActive() then return end
    local shouldAppend = isAppendingToQueue
    local hoverUnit = GetHoverUnit()
    if hoverUnit then
        local payload = { targetGlobalId = hoverUnit.id }
        local position = hoverUnit:GetPosition()
        ClientOrderManager.ClientIssueOrder(OrderTasks.ASSISTUNIT, SCOUnitsExceptTarget(hoverUnit), shouldAppend, position, payload)
    end
end

--- Issues a reclaim order on the unit currently under the cursor
---@return nil
function IssueReclaimOrder()
    if SelectionSystem.SelectionBox:IsActive() then return end
    local shouldAppend = isAppendingToQueue

    local localIDIndex, highlightedEntity = next(SelectionSystem.GetHighlightedEntities())

    -- Highlighted entity can be a prop, predicted unit, or unit.
    -- I am unsure what assigning this to a predicted would do. But the host does not understand predicted units so ya.
    if PredictedUnits[localIDIndex] == highlightedEntity then
        return
    end

    if highlightedEntity then
        local payload = { targetGlobalId = highlightedEntity.id }
        local position = highlightedEntity:GetPosition()
        ClientOrderManager.ClientIssueOrder(OrderTasks.RECLAIM, SelectionSystem.GetSelectedUnits(), shouldAppend, position, payload)
    end
end


--- Issues a capture order on the unit currently under the cursor
---@return nil
function IssueCaptureOrder()
    if SelectionSystem.SelectionBox:IsActive() then return end
    local shouldAppend = isAppendingToQueue
    local hoverUnit = GetHoverUnit()
    if hoverUnit and hoverUnit.entityType == "unit" and hoverUnit:IsCompleted() then
        local payload = { targetGlobalId = hoverUnit.id }
        local position = hoverUnit:GetPosition()
        ClientOrderManager.ClientIssueOrder(OrderTasks.CAPTURE, SelectionSystem.GetSelectedUnits(), shouldAppend, position, payload)
    end
end

function IssueDashOrder()
    if SelectionSystem.SelectionBox:IsActive() then return end
    local shouldAppend = isAppendingToQueue
    local position = MouseCursor.GetMousePosition()

    local dashUnits = {}
    local moveUnits = {}
    for _, unit in pairs(SelectionSystem.GetSelectedUnits()) do
        if unit:DashBehaviorIsValidFor() then
            table.insert(dashUnits, unit)
        else
            table.insert(moveUnits, unit)
        end
    end

    if next(dashUnits) then
        ClientOrderManager.ClientIssueOrder(OrderTasks.DASH, dashUnits, shouldAppend, position)
    end
    
    if next(moveUnits) then
        ClientOrderManager.ClientIssueOrder(OrderTasks.MOVE, moveUnits, shouldAppend, position)
    end
end

function SetFactoryRallyPoint()
    -- Factory rally point at home
    local selected = SelectionSystem.GetSelectedUnits()
    local factories = {}
    for _, unit in pairs(selected) do
        if unit:HasTags(Tags.FACTORY) then
            table.insert(factories, unit)
        end
    end

    if factories[1] then
        local pos = MouseCursor.GetMousePosition()
        local send = Import("common/commands/definitions/buildQueue.lua").RequestRallyPoint.Send
        SCOForEachCommandBatch(factories, function(batch)
            send(batch, pos)
        end)
    end
end

---Cycles the focus army to the next available army and resets to global view after the last army.
---@return nil
function CycleFocusArmy()
    local focus = GetFocusArmy()
    local nextArmy = nil
    local firstArmy = nil

    -- determine first army and next army after current focus
    for armyId, army in pairs(Armies) do
        if next(army.units) then
            if not firstArmy or armyId < firstArmy then
                firstArmy = armyId
            end
            if focus ~= -1 and armyId > focus then
                if not nextArmy or armyId < nextArmy then
                    nextArmy = armyId
                end
            end
        end
    end

    -- if currently in global view, focus first army
    if focus == -1 then
        if firstArmy then
            SetFocusArmy(firstArmy)
        end
    -- advance focus to next army
    elseif nextArmy then
        SetFocusArmy(nextArmy)
    else
        -- reset to global view after last army
        SetFocusArmy(-1)
    end
end

-- Sanctuary Construction Plans 2.1.0
local SCO_BlueprintPlacement = Import("client/input/scoBlueprintPlacement.lua")
local SCO_StockOnMouseLeftDown = OnMouseLeftDown
local SCO_StockOnMouseLeftUp = OnMouseLeftUp
local SCO_StockOnMouseRightDown = OnMouseRightDown
local SCO_StockOnMouseRightUp = OnMouseRightUp

function OnMouseLeftDown()
    if SCO_BlueprintPlacement.IsActive() then
        return SCO_BlueprintPlacement.OnMouseLeftDown()
    end
    return SCO_StockOnMouseLeftDown()
end

function OnMouseLeftUp()
    if SCO_BlueprintPlacement.IsActive() then
        return SCO_BlueprintPlacement.OnMouseLeftUp(isAppendingToQueue)
    end
    return SCO_StockOnMouseLeftUp()
end

function OnMouseRightDown()
    if SCO_BlueprintPlacement.IsActive() then
        return SCO_BlueprintPlacement.OnMouseRightDown()
    end
    return SCO_StockOnMouseRightDown()
end

function OnMouseRightUp()
    if SCO_BlueprintPlacement.IsActive() then
        return SCO_BlueprintPlacement.OnMouseRightUp()
    end
    return SCO_StockOnMouseRightUp()
end

-- Only for annotations
-- SCOM Field Fixes 1.0.1 - partition ground right-click by unit capability.
local SCOFieldFixFactoryGroundRightClickEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOFieldFixFactoryGroundRightClickMarker = rawget(
    SCOFieldFixFactoryGroundRightClickEnvironment,
    "SCO_FieldFixFactoryGroundRightClickInstalled")
if SCOFieldFixFactoryGroundRightClickMarker ~= nil
    and SCOFieldFixFactoryGroundRightClickMarker ~= "1.0.1"
then
    error("Unsupported SCOM factory right-click marker "
        .. tostring(SCOFieldFixFactoryGroundRightClickMarker))
end
if SCOFieldFixFactoryGroundRightClickMarker == nil then

    if type(IssueMoveOrder) ~= "function"
        or type(IssueAttackMoveOrder) ~= "function"
        or type(SetFactoryRallyPoint) ~= "function"
        or type(OnMouseRightDown) ~= "function"
    then
        error("SCOM factory right-click could not resolve client input routes")
    end

    local function SCOMobileSelection()
        local units = {}
        for _, unit in pairs(SelectionSystem.GetSelectedUnits()) do
            if unit:HasTags(Tags.MOBILE) then
                units[#units + 1] = unit
            end
        end
        return units
    end

    local function SCOStationaryFactories()
        local factories = {}
        for _, unit in pairs(SelectionSystem.GetSelectedUnits()) do
            if unit:HasTags(Tags.STRUCTURE)
                and unit:HasTags(Tags.FACTORY)
                and not unit:HasTags(Tags.MOBILE)
            then
                factories[#factories + 1] = unit
            end
        end
        return factories
    end

    local SCOMaxFactoriesPerRallyCommand = 64

    function IssueMoveOrder()
        if SelectionSystem.SelectionBox:IsActive() then return end
        local units = SCOMobileSelection()
        if #units == 0 then return end
        ClientOrderManager.ClientIssueOrder(
            OrderTasks.MOVE,
            units,
            isAppendingToQueue,
            MouseCursor.GetMousePosition())
    end

    function IssueAttackMoveOrder()
        if SelectionSystem.SelectionBox:IsActive() then return end
        local units = SCOMobileSelection()
        if #units == 0 then return end
        ClientOrderManager.ClientIssueOrder(
            OrderTasks.ATTACKMOVE,
            units,
            isAppendingToQueue,
            MouseCursor.GetMousePosition())
    end

    function SetFactoryRallyPoint()
        local factories = SCOStationaryFactories()
        if #factories == 0 then return end
        local sender = Import("common/commands/definitions/buildQueue.lua").RequestRallyPoint.Send
        local position = MouseCursor.GetMousePosition()
        for first = 1, #factories, SCOMaxFactoriesPerRallyCommand do
            local batch = {}
            local last = math.min(
                first + SCOMaxFactoriesPerRallyCommand - 1, #factories)
            for index = first, last do
                batch[#batch + 1] = factories[index]
            end
            sender(batch, position)
        end
    end

    function OnMouseRightDown()
        if not MouseCursor.IsCursorInGameView() then return end
        if TempBuildMode.GetBuildMode() then return end
        if Engine.IsMouseOverUI() then return end
        if SelectionSystem.SelectionBox:IsActive() then return end

        -- The drag-formation module rejects structures. Do not enter a drag state
        -- for a stationary-factory-only selection, or small mouse jitter converts
        -- a valid rally click into an empty formation order.
        for _, unit in pairs(SelectionSystem.GetSelectedUnits()) do
            if unit:HasTags(Tags.MOBILE)
                and not unit:HasTags(Tags.STRUCTURE)
            then
                DragFormationPreviewSystem.StartFormationDrag()
                return
            end
        end
    end

    rawset(
        SCOFieldFixFactoryGroundRightClickEnvironment,
        "SCO_FieldFixFactoryGroundRightClickInstalled",
        "1.0.1")
    _G.SCO_FieldFixFactoryGroundRightClickInstalled = "1.0.1"
end

-- SCOM Field Fixes 1.1.0 - strategic targeting, Megalith combat context, and Stop bridge.
local SCOFieldFixStrategicSiloTargetInputEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOFieldFixStrategicSiloTargetInputMarker = rawget(
    SCOFieldFixStrategicSiloTargetInputEnvironment,
    "SCO_FieldFixStrategicSiloTargetInputInstalled")
if SCOFieldFixStrategicSiloTargetInputMarker ~= nil
    and SCOFieldFixStrategicSiloTargetInputMarker ~= "1.1.0"
then
    error("Unsupported SCOM strategic silo target-input marker "
        .. tostring(SCOFieldFixStrategicSiloTargetInputMarker))
end
if SCOFieldFixStrategicSiloTargetInputMarker == nil then
    if type(OnMouseLeftDown) ~= "function"
        or type(OnMouseLeftUp) ~= "function"
        or type(OnMouseRightDown) ~= "function"
        or type(OnMouseRightUp) ~= "function"
        or type(IssueClearOrder) ~= "function"
        or type(IssueAttackOrder) ~= "function"
        or type(GetHoverUnit) ~= "function"
        or type(ClientOrderManager) ~= "table"
        or type(ClientOrderManager.ClientIssueOrder) ~= "function"
        or type(OrderTasks) ~= "table"
        or OrderTasks.ATTACKUNIT == nil
        or type(SelectionSystem) ~= "table"
        or type(SelectionSystem.GetSelectedUnits) ~= "function"
        or type(SelectionSystem.GetSelectedEntities) ~= "function"
        or type(SelectionSystem.UpdateSelectionSystem) ~= "function"
        or type(MouseCursor) ~= "table"
        or type(MouseCursor.IsCursorInGameView) ~= "function"
        or type(MouseCursor.SetMousePositionX) ~= "function"
        or type(MouseCursor.SetMousePositionY) ~= "function"
        or type(MouseCursor.UpdateMouseRayCastPosition) ~= "function"
        or type(MouseCursor.GetMousePosition) ~= "function"
        or type(TempBuildMode) ~= "table"
        or type(TempBuildMode.GetBuildMode) ~= "function"
        or type(DragFormationPreviewSystem) ~= "table"
        or type(DragFormationPreviewSystem.GetDragFormationStartPositions)
            ~= "function"
        or type(DragFormationPreviewSystem.HasDraggedMinimumDistance)
            ~= "function"
        or type(DragFormationPreviewSystem.EndFormationDrag) ~= "function"
        or type(NewThread) ~= "function"
        or type(WaitTicks) ~= "function"
        or type(Engine.GetMousePositionInPixels) ~= "function"
        or type(Engine.InstantiatePrefab) ~= "function"
        or type(Engine.DeletePrefabInstance) ~= "function"
        or type(Engine.DrawCircle) ~= "function"
        or type(Engine.DrawCross) ~= "function"
        or type(Engine.Error) ~= "function"
        or type(EngineErrorCode) ~= "table"
        or EngineErrorCode.Success == nil
        or type(GetIdentityQuaternion) ~= "function"
        or type(EngineClasses.float4) ~= "function"
    then
        error("SCOM strategic silo target mode could not resolve client input routes")
    end

    local SCOTargetMode = nil
    local SCOConsumeRightUp = false
    local SCOInputTraceBudget = 16
    local SCOClientCommands = Import("common/commands/definitions/buildQueue.lua")
    local SCOCommandEntry = SCOClientCommands.SCOStrategicSilo
    if type(SCOCommandEntry) ~= "table"
        or type(SCOCommandEntry.Send) ~= "function"
        or type(SCOCommandEntry.Actions) ~= "table"
    then
        error("SCOM strategic silo target mode requires command registration first")
    end

    local function SCOUnitTpId(unit)
        if unit == nil then return nil end
        if type(unit.tpId) == "string" then return unit.tpId end
        local general = unit.tp and unit.tp.general
        if type(general) == "table"
            and type(general.tpId) == "string"
        then
            return general.tpId
        end
        local stateGetter = _G.SCO_GetStrategicSiloClientState
        if type(stateGetter) == "function" then
            local ok, state = pcall(stateGetter, unit)
            if ok and type(state) == "table"
                and type(state.tpId) == "string"
            then
                return state.tpId
            end
        end
        return nil
    end

    local function SCOIsApocalypse(unit)
        return SCOUnitTpId(unit) == "ucs3102"
    end

    local function SCOIsSilo(unit)
        if SCOIsApocalypse(unit) then return true end
        local contract = unit
            and unit.tp
            and unit.tp.additions
            and (unit.tp.additions.scoStrategicSilo
                or (unit.tp.additions.scoTactical
                    and unit.tp.additions.scoTactical.role == "launcher"
                    and unit.tp.additions.scoTactical))
        if type(contract) == "table" and contract.version == "1.0.0" then
            return true
        end
        local stateGetter = _G.SCO_GetStrategicSiloClientState
        if type(stateGetter) ~= "function" then return false end
        local ok, state = pcall(stateGetter, unit)
        return ok and type(state) == "table"
            and type(state.tpId) == "string"
    end

    -- The Megalith intentionally remains an ENGINEER so its construction
    -- panel issues direct egg-placement orders. Stock right-click therefore
    -- classifies it before ordinary combat units. Restrict the combat override
    -- to the exact port, its dedicated role tag, and its explicit Attack order.
    local function SCOIsMegalithCombatBuilder(unit)
        if SCOUnitTpId(unit) ~= "ugl4002"
            or type(Tags) ~= "table"
            or Tags.MEGALITH_BUILDER == nil
            or type(unit.HasTags) ~= "function"
            or not unit:HasTags(Tags.MEGALITH_BUILDER)
        then
            return false
        end
        local orders = unit.tp
            and unit.tp.general
            and unit.tp.general.orders
        return type(orders) == "table" and orders.Attack == true
    end

    -- Stock GetSelectedUnits drops selected entities whose local/global-ID bridge
    -- is briefly stale. Merge the authoritative selected-entity set so a newly
    -- spawned Apocalypse cannot disappear during the release frame.
    local function SCOCurrentSelectedUnits()
        local result = {}
        local seen = {}
        local function add(units)
            for _, unit in pairs(units or {}) do
                if unit ~= nil and unit.id ~= nil and not seen[unit] then
                    seen[unit] = true
                    result[#result + 1] = unit
                end
            end
        end
        add(SelectionSystem.GetSelectedUnits())
        add(SelectionSystem.GetSelectedEntities())
        return result
    end

    local function SCOSelectedSilos()
        local silos = {}
        for _, unit in pairs(SCOCurrentSelectedUnits()) do
            if SCOIsSilo(unit) then
                silos[#silos + 1] = unit
            end
        end
        return silos
    end

    local function SCOPartitionSelection(units)
        local silos = {}
        local ordinaryUnits = {}
        for _, unit in pairs(units or {}) do
            if SCOIsSilo(unit) then
                silos[#silos + 1] = unit
            else
                ordinaryUnits[#ordinaryUnits + 1] = unit
            end
        end
        return silos, ordinaryUnits
    end

    local function SCOPartitionMegalithCombatBuilders(units)
        local megaliths = {}
        local ordinaryUnits = {}
        for _, unit in pairs(units or {}) do
            if SCOIsMegalithCombatBuilder(unit) then
                megaliths[#megaliths + 1] = unit
            else
                ordinaryUnits[#ordinaryUnits + 1] = unit
            end
        end
        return megaliths, ordinaryUnits
    end

    local SCOWorldTargetNuclearStructures = {
        ucs3102 = true,
        ues3102 = true,
        ugs3102 = true,
        ugs5007 = true,
        uss3102 = true,
        uss4102 = true,
    }

    local function SCOOnlyNuclearStructures(silos, ordinaryUnits)
        if #silos == 0 or #ordinaryUnits > 0 then return false end
        for _, unit in pairs(silos) do
            if not SCOWorldTargetNuclearStructures[SCOUnitTpId(unit)] then
                return false
            end
        end
        return true
    end

    local function SCOIsEnemyUnit(target, silos)
        local silo = silos and silos[1]
        return target ~= nil
            and target.entityType == "unit"
            and target.army ~= nil
            and type(target.army.IsEnemy) == "function"
            and silo ~= nil
            and silo.army ~= nil
            and target.army:IsEnemy(silo.army) == true
    end

    local function SCOCancelCommanderTargetInput(reason)
        local cancel = rawget(_G, "SCO_CommanderAbilityTargetInputCancel")
        return type(cancel) == "function"
            and cancel(reason or "strategic-targeting") == true
    end

    function _G.SCO_BeginStrategicSiloTargetMode(units)
        local silos = {}
        for _, unit in pairs(units or SCOSelectedSilos()) do
            if SCOIsSilo(unit) then
                silos[#silos + 1] = unit
            end
        end
        if #silos == 0 then return false end
        SCOCancelCommanderTargetInput("strategic-begin")
        SCOTargetMode = { units = silos, pressed = false }
        return true
    end

    function _G.SCO_CancelStrategicSiloTargetMode()
        if not SCOTargetMode then return false end
        SCOTargetMode = nil
        return true
    end

    function _G.SCO_IsStrategicSiloTargetMode()
        return SCOTargetMode ~= nil
    end

    local SCOInputLeftDown = OnMouseLeftDown
    local SCOInputLeftUp = OnMouseLeftUp
    local SCOInputRightDown = OnMouseRightDown
    local SCOInputRightUp = OnMouseRightUp
    local SCOInputClearOrder = IssueClearOrder
    local SCOInputAttackOrder = IssueAttackOrder

    local function SCOFinite(value)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
    end

    -- Input callbacks run before clientMain refreshes the cursor ray. A button
    -- release can also arrive before the PositionX/PositionY events in the same
    -- Engine.GetInput batch, so refresh the mouseCursor module from the engine's
    -- current pointer before raycasting.
    local function SCOSyncMouseCursor()
        local screenPosition = Engine.GetMousePositionInPixels()
        if type(screenPosition) == "table"
            and SCOFinite(screenPosition.x)
            and SCOFinite(screenPosition.y)
        then
            MouseCursor.SetMousePositionX(screenPosition.x)
            MouseCursor.SetMousePositionY(screenPosition.y)
        end
        MouseCursor.UpdateMouseRayCastPosition()
    end

    local function SCORefreshHoverUnit()
        SCOSyncMouseCursor()
        if not MouseCursor.IsCursorInGameView()
            or Engine.IsMouseOverUI()
        then
            return nil, false
        end
        SelectionSystem.UpdateSelectionSystem()
        return GetHoverUnit(), true
    end

    local function SCODrawFallbackLaunchMarker(position)
        local markerPosition = EngineClasses.float3(
            position.x, position.y + 0.1, position.z)
        NewThread(function()
            local color = EngineClasses.float4(1, 0.05, 0.05, 1)
            for tick = 1, 18 do
                Engine.DrawCircle(
                    markerPosition,
                    2.5 + tick / 9,
                    color)
                Engine.DrawCross(markerPosition, 3.5, color)
                WaitTicks(1)
            end
        end)
    end

    local function SCODrawLaunchMarker(position)
        -- A prefab can instantiate successfully without a visible renderer in a
        -- modded HUD. The explicit world-space mark is the reliable contract.
        SCODrawFallbackLaunchMarker(position)
        local markerPrefab = _G.OrderNodePrefabIDRed
        if markerPrefab ~= nil then
            local markerLocalId = {}
            local result = Engine.InstantiatePrefab(
                markerPrefab,
                position,
                EngineClasses.float3(1, 1, 1),
                GetIdentityQuaternion(),
                markerLocalId)
            if result == EngineErrorCode.Success then
                NewThread(function()
                    WaitTicks(18)
                    Engine.DeletePrefabInstance(markerLocalId)
                end)
                return
            end
        end
    end

    local function SCOSendLaunch(silos, position, source)
        local sent, detail = SCOCommandEntry.Send(
            silos,
            SCOCommandEntry.Actions.Launch,
            0,
            position)
        if SCOInputTraceBudget > 0 then
            SCOInputTraceBudget = SCOInputTraceBudget - 1
            Engine.Error("[SCOM Strategic Silo Diagnostic] Client launch "
                .. (sent and "queued" or "rejected")
                .. ": source=" .. tostring(source)
                .. " silos=" .. tostring(#silos)
                .. " target=" .. tostring(position.x)
                .. "," .. tostring(position.y)
                .. "," .. tostring(position.z)
                .. " detail=" .. tostring(detail))
        end
        if sent then
            SCODrawLaunchMarker(position)
        end
        return sent
    end

    local function SCODispatchAttack(silos, ordinaryUnits, hoverUnit, source)
        local position = hoverUnit:GetPosition()
        SCOSendLaunch(silos, position, source)
        if #ordinaryUnits > 0 then
            ClientOrderManager.ClientIssueOrder(
                OrderTasks.ATTACKUNIT,
                ordinaryUnits,
                isAppendingToQueue,
                position,
                { targetGlobalId = hoverUnit.id })
        end
    end

    local function SCORunStockRightUpWithSelection(units)
        local selectedUnits = SelectionSystem.GetSelectedUnits
        local selectedEntities = SelectionSystem.GetSelectedEntities
        local function getScopedSelection() return units end
        SelectionSystem.GetSelectedUnits = getScopedSelection
        SelectionSystem.GetSelectedEntities = getScopedSelection
        local ok, result = pcall(SCOInputRightUp)
        SelectionSystem.GetSelectedUnits = selectedUnits
        SelectionSystem.GetSelectedEntities = selectedEntities
        if not ok then error(result, 0) end
        return result
    end

    local function SCORunStockAttackWithSelection(units)
        if #units == 0 then return end
        local selectedUnits = SelectionSystem.GetSelectedUnits
        local selectedEntities = SelectionSystem.GetSelectedEntities
        local function getScopedSelection() return units end
        SelectionSystem.GetSelectedUnits = getScopedSelection
        SelectionSystem.GetSelectedEntities = getScopedSelection
        local ok, result = pcall(SCOInputAttackOrder)
        SelectionSystem.GetSelectedUnits = selectedUnits
        SelectionSystem.GetSelectedEntities = selectedEntities
        if not ok then error(result, 0) end
        return result
    end

    local function SCOTryRunMegalithEnemyRightUp(units, hoverUnit)
        local megaliths, ordinaryUnits =
            SCOPartitionMegalithCombatBuilders(units)
        if #megaliths == 0
            or not SCOIsEnemyUnit(hoverUnit, megaliths)
        then
            return false
        end

        -- Let every non-Megalith retain the stock context route, including
        -- engineer capture and friendly assist/repair. The captured stock
        -- attack function then issues ATTACKUNIT only for the Megalith subset.
        local result = SCORunStockRightUpWithSelection(ordinaryUnits)
        SCORunStockAttackWithSelection(megaliths)
        return true, result
    end

    -- URL0107 has weak repair/build assistance but is not an engineer. Keep
    -- its combat, movement and healthy-unit guard context on the stock route.
    local function SCOTryRunMantisRepairRightUp(units, hoverUnit)
        if not hoverUnit or hoverUnit.entityType ~= "unit"
            or hoverUnit.id == nil or hoverUnit.dead or hoverUnit.deleted
            or type(hoverUnit.IsCompleted) ~= "function"
            or type(hoverUnit.GetPosition) ~= "function"
            or not hoverUnit.army
            or type(hoverUnit.army.IsAlly) ~= "function"
            or type(GetFocusArmy) ~= "function"
        then
            return false
        end
        local needsRepair = not hoverUnit:IsCompleted()
            or (type(hoverUnit.GetHealth) == "function"
                and type(hoverUnit.GetMaxHealth) == "function"
                and hoverUnit:GetHealth() < hoverUnit:GetMaxHealth())
            or (hoverUnit.captureProgress or 0) > 0
            or (hoverUnit.reclaimProgress or 0) > 0
        if not needsRepair then return false end

        local mantises, remainder = {}, {}
        local focusArmy = GetFocusArmy()
        for _, unit in ipairs(units) do
            if SCOUnitTpId(unit) == "ugl1002"
                and unit.id ~= nil and unit ~= hoverUnit
                and not unit.dead and not unit.deleted
                and unit.armyId == focusArmy and unit.army ~= nil
                and hoverUnit.army:IsAlly(unit.army)
            then
                mantises[#mantises + 1] = unit
            else
                remainder[#remainder + 1] = unit
            end
        end
        if #mantises == 0 then return false end

        ClientOrderManager.ClientIssueOrder(
            assert(OrderTasks.REPAIR, "SCOM Mantis requires the native repair order"),
            mantises,
            isAppendingToQueue,
            hoverUnit:GetPosition(),
            { targetGlobalId = hoverUnit.id })
        -- Run even for an empty remainder so native formation-drag cleanup
        -- still executes. The temporary selection is restored on errors too.
        return true, SCORunStockRightUpWithSelection(remainder)
    end

    local function SCORunOrdinaryRightUp(units, hoverUnit)
        local repaired, inheritedResult =
            SCOTryRunMantisRepairRightUp(units, hoverUnit)
        if repaired then return inheritedResult end
        local handled, result =
            SCOTryRunMegalithEnemyRightUp(units, hoverUnit)
        if handled then return result end
        return SCORunStockRightUpWithSelection(units)
    end

    local function SCOTraceRightRelease(silos, selectedCount, guard)
        if #silos == 0 or SCOInputTraceBudget <= 0 then
            return
        end
        SCOInputTraceBudget = SCOInputTraceBudget - 1
        local ids = {}
        for _, unit in pairs(silos) do
            ids[#ids + 1] = tostring(SCOUnitTpId(unit))
        end
        local observer = type(IsObserver) == "function" and IsObserver() or false
        Engine.Error("[SCOM Strategic Silo Diagnostic] Client release: selected="
            .. tostring(selectedCount)
            .. " silos=" .. tostring(#silos)
            .. " tp=" .. table.concat(ids, ",")
            .. " guard=" .. tostring(guard)
            .. " observer=" .. tostring(observer))
    end

    -- Strategic silos deliberately have no automatic HostWeapon. Preserve
    -- ordinary ATTACKUNIT behavior for a mixed selection, but translate the
    -- silo subset's enemy right-click into its host-validated launch command.
    function IssueAttackOrder()
        if SelectionSystem.SelectionBox:IsActive() then return end
        local hoverUnit = SCORefreshHoverUnit()
        local silos, ordinaryUnits = SCOPartitionSelection(
            SCOCurrentSelectedUnits())
        if #silos == 0 then return SCOInputAttackOrder() end
        if not hoverUnit or not SCOIsEnemyUnit(hoverUnit, silos) then
            return SCORunStockAttackWithSelection(ordinaryUnits)
        end
        SCODispatchAttack(silos, ordinaryUnits, hoverUnit, "attack-order")
    end

    function OnMouseLeftDown()
        if not SCOTargetMode then
            return SCOInputLeftDown()
        end
        SCOSyncMouseCursor()
        if not MouseCursor.IsCursorInGameView()
            or Engine.IsMouseOverUI()
        then
            return
        end
        SCOCancelCommanderTargetInput("strategic-left-down")
        SCOTargetMode.pressed = true
    end

    function OnMouseLeftUp()
        if not SCOTargetMode then
            return SCOInputLeftUp()
        end
        if not SCOTargetMode.pressed then
            return
        end
        local mode = SCOTargetMode
        SCOTargetMode = nil
        SCOCancelCommanderTargetInput("strategic-submit")
        SCOSyncMouseCursor()
        if not MouseCursor.IsCursorInGameView()
            or Engine.IsMouseOverUI()
        then
            return
        end
        SCOSendLaunch(
            mode.units,
            MouseCursor.GetMousePosition(),
            "target-left")
    end

    function OnMouseRightDown()
        SCOSyncMouseCursor()
        if SCOTargetMode then
            SCOCancelCommanderTargetInput("strategic-right-down")
            SCOTargetMode.rightPressed = MouseCursor.IsCursorInGameView()
                and not Engine.IsMouseOverUI()
            SCOConsumeRightUp = true
            return
        end
        SCOConsumeRightUp = false
        return SCOInputRightDown()
    end

    function OnMouseRightUp()
        if SCOConsumeRightUp then
            SCOConsumeRightUp = false
            local mode = SCOTargetMode
            SCOTargetMode = nil
            SCOCancelCommanderTargetInput("strategic-right-click")
            if mode and mode.rightPressed then
                local hoverUnit, validWorld = SCORefreshHoverUnit()
                if validWorld and SCOIsEnemyUnit(hoverUnit, mode.units) then
                    SCOSendLaunch(
                        mode.units,
                        hoverUnit:GetPosition(),
                        "target-right")
                end
            end
            return
        end

        SCOSyncMouseCursor()
        local guard = "ready"
        if not MouseCursor.IsCursorInGameView() then
            guard = "outside-view"
        elseif TempBuildMode.GetBuildMode() then
            guard = "build-mode"
        elseif Engine.IsMouseOverUI() then
            guard = "over-ui"
        elseif SelectionSystem.SelectionBox:IsActive() then
            guard = "selection-box"
        end

        -- Refresh before reading either the highlighted target or the selected
        -- units. This matches the post-input ordering that clientMain normally
        -- performs and prevents a same-frame release from using stale state.
        if guard == "ready" then
            SelectionSystem.UpdateSelectionSystem()
        end
        local selectedUnits = SCOCurrentSelectedUnits()
        local silos, ordinaryUnits = SCOPartitionSelection(selectedUnits)
        local selectedCount = #selectedUnits
        SCOTraceRightRelease(silos, selectedCount, guard)
        if guard == "ready" then
            local dragStartScreenPosition =
                DragFormationPreviewSystem.GetDragFormationStartPositions()
            local dragged = dragStartScreenPosition
                and DragFormationPreviewSystem.HasDraggedMinimumDistance(
                    dragStartScreenPosition)
            if not dragged then
                local hoverUnit = GetHoverUnit()
                -- Nuclear structures target world positions. A hovered enemy
                -- supplies its exact position; otherwise use the cursor ray.
                -- Mobile launchers and mixed combat selections retain stock
                -- ground orders so movement never spends their stockpile.
                if SCOOnlyNuclearStructures(silos, ordinaryUnits) then
                    local position = MouseCursor.GetMousePosition()
                    local source = "right-click-world"
                    if SCOIsEnemyUnit(hoverUnit, silos)
                        and type(hoverUnit.GetPosition) == "function"
                    then
                        position = hoverUnit:GetPosition()
                        source = "right-click-enemy"
                    elseif hoverUnit ~= nil then
                        source = "right-click-world-under-entity"
                    end
                    SCOSendLaunch(silos, position, source)
                    return SCORunOrdinaryRightUp(ordinaryUnits, hoverUnit)
                end
                if #silos > 0 and SCOIsEnemyUnit(hoverUnit, silos) then
                    SCOSendLaunch(
                        silos,
                        hoverUnit:GetPosition(),
                        "right-click-enemy")
                    return SCORunOrdinaryRightUp(ordinaryUnits, hoverUnit)
                end
                if #silos == 0 then
                    local repaired, inheritedResult =
                        SCOTryRunMantisRepairRightUp(ordinaryUnits, hoverUnit)
                    if repaired then return inheritedResult end
                    local handled, result =
                        SCOTryRunMegalithEnemyRightUp(
                            ordinaryUnits, hoverUnit)
                    if handled then return result end
                end
            end
        end
        return SCOInputRightUp()
    end

    function IssueClearOrder()
        SCOTargetMode = nil
        SCOCancelCommanderTargetInput("stop")
        local silos = SCOSelectedSilos()
        local result = SCOInputClearOrder()
        if #silos > 0 then
            SCOCommandEntry.Send(
                silos,
                SCOCommandEntry.Actions.Clear,
                0,
                EngineClasses.float3(0, 0, 0))
        end
        return result
    end

    _G.SCO_FieldFixStrategicSiloRightUp = OnMouseRightUp
    rawset(
        SCOFieldFixStrategicSiloTargetInputEnvironment,
        "SCO_FieldFixStrategicSiloTargetInputInstalled",
        "1.1.0")
    _G.SCO_FieldFixStrategicSiloTargetInputInstalled = "1.1.0"
    _G.SCO_FieldFixStrategicSiloTargetInputVersion = "1.1.0"
    Engine.Error(
        "[SCOM Strategic Silo Diagnostic] Client target input ready: version=1.1.0")
end

-- Native input wrappers: units right-click a transport; Unload chooses a point.
local SCOCargoUnitCommands=Import("common/commands/definitions/units.lua")
local SCOCargoUnloadSelection
local SCOCargoUnloadPressed=false
local function SCOCargoClientConfig(unit)
    return unit and unit.tp and unit.tp.additions and unit.tp.additions.scoCargo
end
local function SCOCargoAllied(a,b)
    return a.army and b.army and a.army:IsAlly(b.army) and b.army:IsAlly(a.army)
end
local function SCOCargoSelection(carriers)
    local result={}
    for _,unit in pairs(SelectionSystem.GetSelectedUnits()) do
        local config=SCOCargoClientConfig(unit)
        if config and ((carriers and #config.slots>0) or (not carriers and (config.portable or config.airPortable))) then
            result[#result+1]=unit
        end
    end
    table.sort(result,function(a,b)return a.id.index<b.id.index end)
    return result
end

function SCOUnloadSelectedCargo(action)
    if action=="cancel" then
        local active=SCOCargoUnloadSelection~=nil
        SCOCargoUnloadSelection=nil
        SCOCargoUnloadPressed=false
        return active
    end
    if IsObserver and IsObserver() then return false end
    local selected=SCOCargoSelection(true)
    if #selected==0 then return false end
    TempBuildMode.SetBuildMode(false)
    DragFormationPreviewSystem.EndFormationDrag()
    SCOCargoUnloadSelection=selected
    SCOCargoUnloadPressed=false
    return true
end

local SCOCargoLeftDown=OnMouseLeftDown
function OnMouseLeftDown()
    if SCOCargoUnloadSelection then
        SCOCargoUnloadPressed=MouseCursor.IsCursorInGameView() and not Engine.IsMouseOverUI()
        return
    end
    return SCOCargoLeftDown()
end
local SCOCargoLeftUp=OnMouseLeftUp
function OnMouseLeftUp()
    if SCOCargoUnloadSelection then
        if SCOCargoUnloadPressed and MouseCursor.IsCursorInGameView() and not Engine.IsMouseOverUI()
            and not (IsObserver and IsObserver()) then
            local selected=SCOCargoUnloadSelection
            SCOUnloadSelectedCargo("cancel")
            local position=MouseCursor.GetMousePosition()
            for _,carrier in ipairs(selected) do
                SCOCargoUnitCommands.SCOSourceCargo.Send(carrier.id,carrier.id,true,position)
            end
        end
        SCOCargoUnloadPressed=false
        return
    end
    return SCOCargoLeftUp()
end
local SCOCargoRightDown=OnMouseRightDown
function OnMouseRightDown()
    if SCOCargoUnloadSelection then return end
    return SCOCargoRightDown()
end
local SCOCargoRightUp=OnMouseRightUp
function OnMouseRightUp()
    if SCOUnloadSelectedCargo("cancel") then return end
    if not (IsObserver and IsObserver()) and MouseCursor.IsCursorInGameView()
        and not Engine.IsMouseOverUI() and not TempBuildMode.GetBuildMode()
        and not SelectionSystem.SelectionBox:IsActive() then
        local start=DragFormationPreviewSystem.GetDragFormationStartPositions()
        if not start or not DragFormationPreviewSystem.HasDraggedMinimumDistance(start) then
            local target=GetHoverUnit()
            local config=SCOCargoClientConfig(target)
            local sent=false
            if config and #config.slots>0 then
                for _,cargo in ipairs(SCOCargoSelection(false)) do
                    local payload=SCOCargoClientConfig(cargo)
                    if cargo~=target and SCOCargoAllied(target,cargo)
                        and ((config.airStorage and payload.airPortable) or (not config.airStorage and payload.portable)) then
                        SCOCargoUnitCommands.SCOSourceCargo.Send(target.id,cargo.id,false,cargo:GetPosition())
                        sent=true
                    end
                end
            elseif config and (config.portable or config.airPortable) then
                -- Retain the existing reverse gesture for the player's own cargo.
                for _,carrier in ipairs(SCOCargoSelection(true)) do
                    local transport=SCOCargoClientConfig(carrier)
                    if carrier~=target and carrier.armyId==target.armyId
                        and ((transport.airStorage and config.airPortable) or (not transport.airStorage and config.portable)) then
                        SCOCargoUnitCommands.SCOSourceCargo.Send(carrier.id,target.id,false,target:GetPosition())
                        sent=true
                        break
                    end
                end
            end
            if sent then DragFormationPreviewSystem.EndFormationDrag();return end
        end
    end
    return SCOCargoRightUp()
end

-- Append before inputEventsFunctions.lua exports, exporting SCOSelectedPodAction.
function SCOSelectedPodAction(remove)
    if IsObserver and IsObserver() then return false end
    local selection={}
    for _,unit in pairs(SelectionSystem.GetSelectedUnits()) do
        if unit.tpId=="uel5007" then selection[#selection+1]=unit end
    end
    table.sort(selection,function(a,b) return a.id.index<b.id.index end)
    for _,unit in ipairs(selection) do
        Import("common/commands/definitions/units.lua").SCOSourcePod.Send(unit.id,remove==true)
    end
    return #selection>0
end

return {
    SCOUnloadSelectedCargo = SCOUnloadSelectedCargo,
    SCOSelectedPodAction = SCOSelectedPodAction,
    OnMouseLeftDown = OnMouseLeftDown,
    OnMouseLeftUp = OnMouseLeftUp,
    OnMouseRightDown = OnMouseRightDown,
    OnMouseRightUp = OnMouseRightUp,
    CycleFocusArmy = CycleFocusArmy,
    SetAppendOrderToggle = SetAppendOrderToggle,
    BeginPatrolOrder = BeginPatrolOrder,
    IssueClearOrder = IssueClearOrder,
    IssueAttackOrder = IssueAttackOrder
}
