local CommonOrders = Import("common/commonOrders.lua")
local OrderTasks = CommonOrders.OrderTasks
local OrderMessages = CommonOrders.OrderMessages
local ClientBaseOrder = Import("client/managers/orders/clientBaseOrder.lua").ClientBaseOrder
local ClientPatrolOrder = Import("client/managers/orders/clientPatrolOrder.lua").ClientPatrolOrder
local ClientOrderRenderer = Import("client/managers/orders/interfaces/clientOrderRenderer.lua").ClientOrderRenderer
local OrderCommands = Import("common/commands/definitions/orders.lua")

local ClientOrderClasses = {
    [OrderTasks.PATROLMOVE] = ClientPatrolOrder,
    [OrderTasks.PATROLATTACKMOVE] = ClientPatrolOrder,
}

---@type ClientOrderRenderer
local orderRenderer = ClientOrderRenderer()

---@class ClientOrderMessage
---@field orderId OrderId
---@field append boolean
---@field unitGlobalIds GlobalID[]
---@field orderTask OrderTaskType|nil
---@field position float3
---@field payload table|nil
---@field orderMessage OrderMessageType
---@field onAcknowledged fun(accepted: boolean, additionalPayload: table|nil)|nil

local verboseLog = false

---@type table<OrderId, ClientBaseOrder>
local ordersMap = {}
---@type table<OrderId, ClientOrderMessage>
local pendingMessages = {}

local recalculateAllPendingMessages = false

-- todo: remove word "predict" from field names
-- todo: test with a large amount of units
-- todo: maybe can get rid of activeOrder because its always the first
-- todo: maintain the directed diagram for rendering
-- todo: collapse lines

-- todo: i need to test everything for player 2 and player 3, when you didnt do any prediction
-- todo: !! check error codes for all delegates
-- todo !! make build order <<<<<<<< then can delete old orders
-- todo !! rendering? and collapse of order graph
-- todo !! draggable waypoints
-- todo !! delete waypoints

-- todo !! get some help with performance?

-- todo remove logs
-- todo we don't have a set rally point
-- todo different rendering by order type, move/attack


function ClientClearOrder(units)
    -- # validate
    if not next(units) or IsObserver() then
        return
    end

    -- # get unit global ids
    local unitIdMap = GetUnitIds(units)

    -- # create order
    ---@type ClientOrderMessage
    local msg = {
        -- # make composite id, unique across players
        orderId = _G.GetFocusArmy() .. "." .. CommonOrders.GetNextUniqueLuaId(), -- this is NOT an orderId! this is really a messageId
        append = false,
        unitGlobalIds = unitIdMap,
        orderTask = nil,
        position = { x = 0, y = 0, z = 0 },
        payload = nil,
        orderMessage = OrderMessages.CLEAR
    }

    -- # send order
    OrderCommands.ClearOrder.Send(msg.orderId, msg.unitGlobalIds)

    pendingMessages[msg.orderId] = msg
    recalculateAllPendingMessages = true
end

function ClientIssueOrder(orderTask, units, append, position, payload, onAcknowledged)
    -- # validate
    if not next(units) or IsObserver() then
        return
    end

    -- # get unit global ids
    local unitIdMap = GetUnitIds(units)

    -- # create order
    ---@type ClientOrderMessage
    local msg = {
        -- # make composite id, unique across players
        orderId = Engine.GetClientID() .. "." .. CommonOrders.GetNextUniqueLuaId(),
        append = append,
        orderTask = orderTask,
        unitGlobalIds = unitIdMap,
        position = position,
        payload = payload,
        orderMessage = OrderMessages.ADD,
        onAcknowledged = onAcknowledged,
    }

    -- # send order
    OrderCommands.IssueOrder.Send(msg.orderId, msg.append, msg.orderTask, msg.unitGlobalIds, msg.position, msg.payload)

    if verboseLog then
        LogSwitch("!CLIENT.UI>>> dispatched msg: " .. repr(msg))
    end
    -- note: take care that everything in msg is shallow copied!

    pendingMessages[msg.orderId] = msg
    recalculateAllPendingMessages = true

    DumpOrderMap("(end-ui)")
end

local function OnHostOperationApplied()
    recalculateAllPendingMessages = true
    DumpOrderMap("(end-network)")
end

function OnOrderAdded(orderId, orderTask, positionFloat3, payload)
    AddOrder(orderId, positionFloat3, false, ordersMap[orderId], nil, orderTask, payload)
    OnHostOperationApplied()
end

function OnOrderDeleted(orderId)
    DeleteOrder(ordersMap[orderId], false)
    OnHostOperationApplied()
end

function OnOrderQueuedUnitsAdded(orderId, unitIds)
    AddQueuedUnits(ordersMap[orderId], _G.GetUnitsByIDs(unitIds), false)
    OnHostOperationApplied()
end

function OnOrderQueuedUnitRemoved(orderId, unitId)
    RemoveQueuedUnit(ordersMap[orderId], _G.GetUnitById(unitId), false)
    OnHostOperationApplied()
end

function OnOrderActivatedForUnit(orderId, unitId)
    ActivateOrderForUnit(ordersMap[orderId], _G.GetUnitById(unitId), false)
    OnHostOperationApplied()
end

function OnOrderDeactivatedForUnit(orderId, unitId)
    DeactivateOrderForUnit(ordersMap[orderId], _G.GetUnitById(unitId), false)
    OnHostOperationApplied()
end

function OnOrderTargetSet(orderId, unitId)
    SetTargetForOrder(ordersMap[orderId], _G.GetUnitById(unitId), false)
    OnHostOperationApplied()
end

function OnOrderTargetCleared(orderId)
    SetTargetForOrder(ordersMap[orderId], nil, false)
    OnHostOperationApplied()
end

function OnOrderAcknowledged(orderId, accepted, additionalPayload)
    LogSwitch("!  REMOVE originMessageId = " .. orderId)

    local pendingMsg = pendingMessages[orderId]
    if pendingMsg and pendingMsg.onAcknowledged then
        -- We could pcall this so we are safe!
        pcall(pendingMsg.onAcknowledged, accepted, additionalPayload)
        --pendingMsg.onAcknowledged(accepted, additionalPayload)
    end

    pendingMessages[orderId] = nil
    -- todo: how to recycle unique loa ids
    OnHostOperationApplied()
end

local function CreateClientOrder(orderId, positionFloat3, isPrediction, orderMessage, orderTask, payload)
    local orderClass = ClientOrderClasses[orderTask]
    if orderClass then
        return orderClass(orderId, positionFloat3, isPrediction, orderMessage, orderTask, payload)
    end
    return ClientBaseOrder(orderId, positionFloat3, isPrediction, orderMessage, orderTask)
end

function AddOrder(orderId, positionFloat3, isPrediction, existingOrder, orderMessage, orderTask, payload)
    if verboseLog then
        LogSwitch("!      AddOrder: " .. repr({isPrediction=isPrediction, orderId = orderId}))
    end

    -- create the order (you may have had a prediction for it, and now the network version is coming through)
    if existingOrder == nil then
        existingOrder = CreateClientOrder(orderId, positionFloat3, isPrediction, orderMessage, orderTask, payload)
        ordersMap[orderId] = existingOrder
    end

    -- set is it a real/predicted create
    existingOrder.isCreatePredicted = isPrediction

    if isPrediction then
        EnsureTrackingOrder(existingOrder)
    end

    return existingOrder
end

function AddQueuedUnits(order, units, isPrediction)
    if verboseLog then
        LogSwitch("!      AddQueuedUnits: " .. repr({isPrediction=isPrediction, orderId = order.id, unitIds = GetUnitIds(units)}))
    end
    if isPrediction then
        EnsureTrackingOrder(order)
        for _, unit in pairs(units) do
            EnsureTrackingUnit(unit)
            table.insert(order.orderState.queuedUnitsArray, unit)
            table.insert(unit.orderState.queuedOrdersArray, order)
        end
    else
        for _, unit in pairs(units) do
            table.insert(order.simOrderState.queuedUnitsArray, unit)
            table.insert(unit.simOrderState.queuedOrdersArray, order)
        end
    end
end

function RemoveQueuedUnit(order, unit, isPrediction)
    if verboseLog then
        LogSwitch("!      RemoveQueuedUnit: " .. repr({isPrediction=isPrediction, orderId = order.id, unitId = unit.id}))
    end
    if isPrediction then
        EnsureTrackingUnit(unit)
        EnsureTrackingOrder(order)
        table.removeByValue(order.orderState.queuedUnitsArray, unit)
        table.removeByValue(unit.orderState.queuedOrdersArray, order)
    else 
        table.removeByValue(order.simOrderState.queuedUnitsArray, unit)
        table.removeByValue(unit.simOrderState.queuedOrdersArray, order)
    end
end

function ActivateOrderForUnit(order, unit, isPrediction)
    if verboseLog then
        LogSwitch("!      ActivateOrderForUnit: " .. repr({isPrediction=isPrediction, orderId = order.id, unitId = unit.id}))
    end
    if isPrediction then
        EnsureTrackingUnit(unit)
        EnsureTrackingOrder(order)
        table.insert(order.orderState.activeUnitsArray, unit)
        unit.orderState.activeOrder = order
    else
        table.insert(order.simOrderState.activeUnitsArray, unit)
        unit.simOrderState.activeOrder = order
        unit:OnOrderChanged()
    end
    order:OnUnitActivated(unit)
end

function DeactivateOrderForUnit(order, unit, isPrediction)
    if verboseLog then
        LogSwitch("!      DeactivateOrderForUnit: " .. repr({isPrediction=isPrediction, orderId = order.id, unitId = unit.id}))
    end
    if isPrediction then
        EnsureTrackingUnit(unit)
        EnsureTrackingOrder(order)
        table.removeByValue(order.orderState.activeUnitsArray, unit)
        unit.orderState.activeOrder = nil
    else 
        table.removeByValue(order.simOrderState.activeUnitsArray, unit)
        unit.simOrderState.activeOrder = nil
        unit:OnOrderChanged()
    end
end
function SetTargetForOrder(order, unit, isPrediction)
    local unitId = unit and unit.id or nil
    if verboseLog then
        LogSwitch("!      SetTargetForOrder: " .. repr({isPrediction=isPrediction, orderId = order.id, unitId = unitId}))
    end
    if isPrediction then
        -- no prediction yet
        --EnsureTrackingOrder(order)
        order.targetUnit = unit
    else
        order.targetUnit = unit
    end
end

function DeleteOrder(order, isPrediction)
    if verboseLog then
        LogSwitch("!      DeleteOrder: " .. repr({isPrediction=isPrediction, orderId = order.id}))
    end
    if isPrediction then
        EnsureTrackingOrder(order)
        order.isDeletePredicted = true
    else 
        -- todo: call order.delete?
        if verboseLog then
            LogSwitch("!actually deleting " .. repr(order.id))
        end
        ordersMap[order.id] = nil
    end
end

local previouslyTrackedOrders = {}
local previouslyTrackedUnits = {}
function RecalculatePendingMessages()
    if verboseLog then
        LogSwitch("!pending msgs are: " .. repr(pendingMessages))
    end

    local counters = {
        a_ordersReset = 0,
        b_ordersDeleted1 = 0,
        b_ordersDeleted2 = 0,
        c_unitsReset = 0,
        d_sortedMsgIds = 0,
        e_msgsProcessed = 0,
        f_ordersAdded = 0,
        g_unitsFetched = 0,
        h_unitsIterated = 0,
        i_ensureTrackingUnit = 0,
        j_predActiveOrderCleared = 0,
        k_predQueuedOrderRemoved = 0,
        l_activatedOrder = 0,
        m_queuedOrderAdded = 0,
        n_ordersEmptiedChecked = 0,
        o_ordersDeletedPred = 0,
    }

    -- #  revert tracking for orders
    for orderId, order in pairs(previouslyTrackedOrders) do
        if verboseLog then
            LogSwitch("! revert order: " .. repr(orderId))
        end
        order.hasPendingOrderMessages = false
        order.isDeletePredicted = false
        order.orderState = order.simOrderState -- this is key to reversion

        counters.a_ordersReset = counters.a_ordersReset + 1
    end

    for ptoId, previouslyTrackedOrder in pairs(previouslyTrackedOrders) do
        local shouldDelete = previouslyTrackedOrder.isCreatePredicted
        if shouldDelete then
            LogSwitch("! super revert-delete order: " .. ptoId)
            ordersMap[ptoId] = nil
        end
    end

    -- # revert tracking for units
    for _, unit in pairs(previouslyTrackedUnits) do
        if verboseLog then
            LogSwitch("! revert unit: " .. repr(unit.id))
        end
        unit.hasPendingOrderMessages = false
        unit.orderState = unit.simOrderState -- this is key to reversion
        counters.c_unitsReset = counters.c_unitsReset + 1
    end

    -- # clear previous tracked
    table.clear(previouslyTrackedOrders)
    table.clear(previouslyTrackedUnits)

    -- # now replace each message, anticipating its effects

    -- # first get msg keys in order, which lua doesnt always do
    local sortedPendingMessageIds = {}
    for msgId, _ in pairs(pendingMessages) do
        table.insert(sortedPendingMessageIds, msgId)
        counters.d_sortedMsgIds = counters.d_sortedMsgIds + 1
    end
    table.sort(sortedPendingMessageIds)

    -- # anticipate the effects of each message
    for _, msgId in ipairs(sortedPendingMessageIds) do
        LogSwitch("!  APPLY originMessageId = " .. msgId)
        local msg = pendingMessages[msgId]
        counters.e_msgsProcessed = counters.e_msgsProcessed + 1

        if msg.orderMessage == OrderMessages.CLEAR then
            local units = msg.unitGlobalIds and _G.GetUnitsByIDs(msg.unitGlobalIds) or {}
            local potentiallyEmptyOrderIds = {}

            for index, unit in pairs(units) do 
                if unit.orderState.activeOrder ~= nil then
                    potentiallyEmptyOrderIds[unit.orderState.activeOrder.id] = true
                    DeactivateOrderForUnit(unit.orderState.activeOrder, unit, true)
                end
                -- note: shallowCopy to avoid skipping indexes
                local pqoaCopy = table.shallowCopy(unit.orderState.queuedOrdersArray)
                for index, queuedOrder in ipairs(pqoaCopy) do
                    potentiallyEmptyOrderIds[queuedOrder.id] = true
                    RemoveQueuedUnit(queuedOrder, unit, true)
                end
            end

            for potentiallyEmptyOrderId, _ in pairs(potentiallyEmptyOrderIds) do
                local affectedOrder = ordersMap[potentiallyEmptyOrderId]
                local shouldDelete = #affectedOrder.orderState.activeUnitsArray == 0 and #affectedOrder.orderState.queuedUnitsArray == 0
                if shouldDelete then
                    DeleteOrder(affectedOrder, true)
                end
            end
        elseif msg.orderMessage == OrderMessages.ADD then

            -- # for each unit
            local order = AddOrder(msg.orderId, msg.position, true, nil, msg.orderMessage, msg.orderTask, msg.payload)
            counters.f_ordersAdded = counters.f_ordersAdded + 1

            local units = msg.unitGlobalIds and _G.GetUnitsByIDs(msg.unitGlobalIds) or {}
            counters.g_unitsFetched = counters.g_unitsFetched + (units and #units or 0)
            local potentiallyEmptyOrderIds = {}

            for index, unit in pairs(units) do
                counters.h_unitsIterated = counters.h_unitsIterated + 1
                -- # simulate clearing next/current orders
                --EnsureTrackingUnit(unit) <-- i used to have this here to guarantee it was reading from predicted state. however seems unnecessary now
                counters.i_ensureTrackingUnit = counters.i_ensureTrackingUnit + 1
                if not msg.append then
                    if unit.orderState.activeOrder ~= nil then
                        potentiallyEmptyOrderIds[unit.orderState.activeOrder.id] = true
                        DeactivateOrderForUnit(unit.orderState.activeOrder, unit, true)
                        counters.j_predActiveOrderCleared = counters.j_predActiveOrderCleared + 1
                    end
                    -- note: shallowCopy to avoid skipping indexes
                    local pqoaCopy = table.shallowCopy(unit.orderState.queuedOrdersArray)
                    for index, queuedOrder in ipairs(pqoaCopy) do
                        potentiallyEmptyOrderIds[queuedOrder.id] = true
                        RemoveQueuedUnit(queuedOrder, unit, true)
                        counters.k_predQueuedOrderRemoved = counters.k_predQueuedOrderRemoved + 1
                    end
                end
                -- # simulate queuing/activating next orders
                local shouldActivate = (not msg.append) or unit.orderState.activeOrder == nil
                if shouldActivate then
                    ActivateOrderForUnit(order, unit, true)
                    counters.l_activatedOrder = counters.l_activatedOrder + 1
                else
                    AddQueuedUnits(order, { unit }, true)
                    counters.m_queuedOrderAdded = counters.m_queuedOrderAdded + 1
                end
            end
            -- # simulate deleting orders that were just emptied
            for potentiallyEmptyOrderId, _ in pairs(potentiallyEmptyOrderIds) do
                counters.n_ordersEmptiedChecked = counters.n_ordersEmptiedChecked + 1
                local affectedOrder = ordersMap[potentiallyEmptyOrderId]
                local shouldDelete = #affectedOrder.orderState.activeUnitsArray == 0 and #affectedOrder.orderState.queuedUnitsArray == 0
                if shouldDelete then
                    DeleteOrder(affectedOrder, true)
                    counters.o_ordersDeletedPred = counters.o_ordersDeletedPred + 1
                end
            end
        end
    end

    counters.z_orderCount = table.size(ordersMap)

    -- # calculate how expensive this all was
    if verboseLog then
        LogSwitch("prediction counters: " .. repr(counters))
    end

    DumpOrderMap("(end-predict)")
end

function EnsureTrackingOrder(order)
    if order.hasPendingOrderMessages then
        return
    end

    -- todo: try remove this check, i dont think its needed
    if previouslyTrackedOrders[order.id] then
        return
    end

    previouslyTrackedOrders[order.id] = order
    order.hasPendingOrderMessages = true
    order.isDeletePredicted = false
    order.orderState = {
        queuedUnitsArray = table.shallowCopy(order.simOrderState.queuedUnitsArray),
        activeUnitsArray = table.shallowCopy(order.simOrderState.activeUnitsArray),
    }
end

function EnsureTrackingUnit(unit)
    if unit.hasPendingOrderMessages then
        return
    end

    -- todo: try remove this check, i dont think its needed
    -- todo: this is very different to the order one, whats up with that
    if not previouslyTrackedUnits[unit.id] then
        previouslyTrackedUnits[unit.id] = unit
    end
    unit.hasPendingOrderMessages = true
    
    unit.orderState = {
        queuedOrdersArray = table.shallowCopy(unit.simOrderState.queuedOrdersArray),
        activeOrder = unit.simOrderState.activeOrder,
    }
end

function Update()
    local profilerMarker = Engine.CreateProfilerMarker("Client Lua: ClientOrderManager.Update")

    Engine.BeginProfile(profilerMarker)

    -- note: this Update() fn gets called after network commands are processed in clientMain.lua
    -- todo: we can skip this whole thing if its got no prediction messages -> or is that a smart if greco?

    if recalculateAllPendingMessages then
        LogSwitch("!<predict>")
        RecalculatePendingMessages()
        LogSwitch("!</predict>")
        UpdateOrderDraw()
        LogSwitch("!-------------")
        recalculateAllPendingMessages = false
    else
        UpdateOrderDraw()
    end

    -- todo: now we can run Update() for each order, but only the valid ones, not the predicted ones (predicted changes have already been rolled back) although we shouldnt have an Update, we should repond to a specific message that the host set
    
    Engine.EndProfile(profilerMarker)
end

function SetOrderDraw(value)
    SetOrderDrawEnabled(value)
end

function SetOrderDrawEnabled(isEnabled)
    orderRenderer:SetOrderDrawEnabled(isEnabled)
end

function UpdateOrderDraw()
    LogSwitch("!<draw>")
    orderRenderer:UpdateOrderDraw(ordersMap)
    LogSwitch("!</draw>")
end

-- ####################### temporary util methods follow, to put somewhere
-- #
-- #
-- #
-- #

local dumpId = 0
function DumpOrderMap(prefix)
    if not verboseLog then
        return
    end

    dumpId = dumpId + 1
    local ordersStates = {}
    for _, order in pairs(ordersMap) do
        local row = {
            _type = 'order',
            id = order.id,
            isCreatePredicted = order.isCreatePredicted,
            isDeletePredicted = order.isDeletePredicted,
            -- positionFloat3 = order.positionFloat3,
            -- positionFloat2 = order.positionFloat2,
            simOrderState = {
                queuedUnitsArray = GetUnitIds(order.simOrderState.queuedUnitsArray),
                activeUnitsArray = GetUnitIds(order.simOrderState.activeUnitsArray),
            },
            hasPendingOrderMessages = order.hasPendingOrderMessages,
        }     
        
        if order.orderState ~= order.simOrderState then
            row.orderState = {
                queuedUnitsArray = GetUnitIds(order.orderState.queuedUnitsArray),
                activeUnitsArray = GetUnitIds(order.orderState.activeUnitsArray),
            }
        end

        table.insert(ordersStates, row)
    end

    for _, unit in pairs(__Entities.Units) do
        local row = {
            _type = 'unit',
            id = unit.id,
            activeOrder = unit.orderState.activeOrder and unit.orderState.activeOrder.id or nil,
            simOrderState = {
                queuedOrdersArray = GetUnitIds(unit.simOrderState.queuedOrdersArray),
                activeOrder = unit.simOrderState.activeOrder and unit.simOrderState.activeOrder.id or nil,
            },
            hasPendingOrderMessages = unit.hasPendingOrderMessages,
        }

        if unit.orderState ~= unit.simOrderState then
            row.orderState = {
                queuedOrdersArray = GetUnitIds(unit.orderState.queuedOrdersArray),
                activeOrder = unit.orderState.activeOrder and unit.orderState.activeOrder.id or nil,
            }
        end

        table.insert(ordersStates, row)
    end

    LogSwitch("!Dump: " .. prefix .. " " .. dumpId .. ": " .. repr(ordersStates))
end

function LogSwitch(msg)
    if verboseLog then
        Log("ClientOrderManager: " .. msg)
    end 
end
-- SCOM selected factory rally marker 1.0.0
local SelectionSystem = Import("client/input/selectionSystem.lua")
local previousRallyOrderDraw = UpdateOrderDraw

local function GetFactoryRallyPoint(unit, state)
    if unit.GetFactoryRallyDisplayPoint then
        return unit:GetFactoryRallyDisplayPoint(state)
    end
    if state.hasExplicit then
        return state.point
    end
    local construction = unit.tp and unit.tp.construction
    local rollOff = construction and construction.rollOffPoints
    local offset = rollOff and rollOff[1] and rollOff[1].offset
    if offset == nil then
        return nil
    end
    local origin = unit:GetPosition()
    -- Match HostFactory:RollOffUnit's default rally calculation.
    return EngineClasses.float3(origin.x + offset.x, origin.y + offset.y, origin.z + offset.z * 2)
end

function UpdateOrderDraw(...)
    previousRallyOrderDraw(...)
    if IsObserver() then
        return
    end
    local focus = GetFocusArmy()
    local tick = Engine.GetSimulationTick()
    for _, unit in pairs(SelectionSystem.GetSelectedUnits()) do
        if unit.armyId == focus and unit:HasTags(Tags.FACTORY) then
            local state = unit.scoFactoryRallyState
            if state == nil then
                local last = unit.scoFactoryRallyRequestTick
                if last == nil or tick < last or tick - last >= 50 then
                    SendToHost({unitIndex = unit.id.index, unitVersion = unit.id.version}, "FactoryRallySnapshot")
                    unit.scoFactoryRallyRequestTick = tick
                end
            else
                local point, destination = GetFactoryRallyPoint(unit, state)
                if point ~= nil then
                    orderRenderer:CreateOrderNode(point, orderRenderer.orderStyles[OrderTasks.MOVE])
                    orderRenderer:CreateOrderLine(unit:GetPosition(), point, point, orderRenderer.orderStyles[OrderTasks.MOVE])
                    if destination ~= nil then
                        orderRenderer:CreateOrderNode(destination, orderRenderer.orderStyles[OrderTasks.MOVE])
                        orderRenderer:CreateOrderLine(point, destination, destination, orderRenderer.orderStyles[OrderTasks.MOVE])
                    end
                end
            end
        end
    end
end
