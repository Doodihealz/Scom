local ordersArray = {};
local HostMoveOrder = Import("host/managers/orders/orderClasses/hostMoveOrder.lua").HostMoveOrder
local HostTeleportOrder = Import("host/managers/orders/orderClasses/hostTeleportOrder.lua").HostTeleportOrder
local HostBuildOrder = Import("host/managers/orders/orderClasses/hostBuildOrder.lua").HostBuildOrder
local HostAttackUnitOrder = Import("host/managers/orders/orderClasses/hostAttackUnitOrder.lua").HostAttackUnitOrder
local HostAttackMoveOrder = Import("host/managers/orders/orderClasses/hostAttackMoveOrder.lua").HostAttackMoveOrder
local HostPatrolMoveOrder = Import("host/managers/orders/orderClasses/hostPatrolMoveOrder.lua").HostPatrolMoveOrder
local HostPatrolAttackMoveOrder = Import("host/managers/orders/orderClasses/hostPatrolAttackMoveOrder.lua").HostPatrolAttackMoveOrder
local HostRepairOrder = Import("host/managers/orders/orderClasses/hostRepairOrder.lua").HostRepairOrder
local HostReclaimOrder = Import("host/managers/orders/orderClasses/hostReclaimOrder.lua").HostReclaimOrder
local HostCaptureOrder = Import("host/managers/orders/orderClasses/hostCaptureOrder.lua").HostCaptureOrder
local HostAssistUnitOrder = Import("host/managers/orders/orderClasses/hostAssistUnitOrder.lua").HostAssistUnitOrder
local HostDashOrder = Import("host/managers/orders/orderClasses/hostDashOrder.lua").HostDashOrder
local HostGameTriggers = Import("host/hostGameTriggers.lua")
local OrderCommands = Import("common/commands/definitions/orders.lua")
local CommonOrders = Import("common/commonOrders.lua")
local OrderTasks = CommonOrders.OrderTasks
local verboseLog = false

local OrderClasses = {}
OrderClasses[OrderTasks.MOVE] = HostMoveOrder
OrderClasses[OrderTasks.TELEPORT] = HostTeleportOrder
OrderClasses[OrderTasks.BUILD] = HostBuildOrder
OrderClasses[OrderTasks.ATTACKUNIT] = HostAttackUnitOrder
OrderClasses[OrderTasks.ATTACKMOVE] = HostAttackMoveOrder
OrderClasses[OrderTasks.PATROLMOVE] = HostPatrolMoveOrder
OrderClasses[OrderTasks.PATROLATTACKMOVE] = HostPatrolAttackMoveOrder
OrderClasses[OrderTasks.REPAIR] = HostRepairOrder
OrderClasses[OrderTasks.RECLAIM] = HostReclaimOrder
OrderClasses[OrderTasks.CAPTURE] = HostCaptureOrder
OrderClasses[OrderTasks.ASSISTUNIT] = HostAssistUnitOrder
OrderClasses[OrderTasks.DASH] = HostDashOrder


function HostIssueOrder(orderTask, unitsArray, append, position, payload)
    -- # validate
    if not next(unitsArray) then
        return
    end

    local orderId =  "-1." .. CommonOrders.GetNextUniqueLuaId()
    IssueOrder(orderId, position, unitsArray, append, orderTask, payload)
end

function HostClearOrder(unitsArray) -- todo: rename HostClearOrdersCommand
    -- # validate
    if not next(unitsArray) then
        return
    end

    local orderId =  "-1." .. CommonOrders.GetNextUniqueLuaId()
    ClearOrder(orderId, unitsArray)
end

function ClientIssueOrder(orderId, position, unitsArray, append, orderTask, payload)
    IssueOrder(orderId, position, unitsArray, append, orderTask, payload)
end

function ClientClearOrder(orderId, unitsArray)-- todo: rename ClientClearOrdersCommand
    ClearOrder(orderId, unitsArray)
end

-- note: this is when the player/ai has issues an explicit clear command (eg press h key). 
-- note: not when they issue a new order without pressing shift
--* stops orders (therefore behaviors, therefore things like movement)
--* clears build queue of factory
--* stops building the current item in a factory
--* is no longer a slave of a factory
function ClearOrder(orderId, unitsArray)-- todo: rename ClearOrdersCommand
    LogSwitch("hostOrderManager.ClearOrder")

    for index, unit in ipairs(unitsArray) do
      ClearOrdersForUnit(unit)
        -- todo: this is probably not the way to test something has a build queue
        if unit.ClearBuildQueue then
            unit:ClearBuildQueue()
        end

        if unit.orders.activeOrder == nil then
            unit:OnBecameIdle()
        end
    end

    OrderCommands.OrderAcknowledged.Send(orderId, OrderTasks.NONE, true)
end

--* issuing an invalid order does not cancel a valid order
function IssueOrder(orderId, position, unitsArray, append, orderTask, payload)
    LogSwitch("hostOrderManager.IssueOrder")

    local accepted = false
    local additionalPayload = nil -- Extra information sent from the host to the client, in the case of build orders it's used to send the globalid of the newly created unit

    -- # create order
    local orderClass = GetOrderClass(orderTask)
    if orderClass then
        local order = orderClass(orderId, position, payload)

        -- # if its a valid order lets set it up
        if order:ValidateOrder(true) then
            accepted = true

            table.insert(ordersArray, order);
            OrderCommands.OrderAdded.Send(order.id, orderTask, order.positionFloat3, payload)

            order:OrderStart()
            
            if order.GetAdditionalPayload then
                additionalPayload = order:GetAdditionalPayload()
            end

            -- # validate unit assignments
            local validUnitsArray = {}
            for index, unit in ipairs(unitsArray) do
                -- one day we might want to split validateOnIssue and validateOnStart
                -- for example if you try to assist an extractor that you know you will hit the upgrade button for soon, it will throw it away too early
                if order:ValidateUnitAssignment(unit) then
                    table.insert(validUnitsArray, unit)

                    -- # clear orders if not appending
                    if not append then
                        ClearOrdersForUnit(unit)
                    end
                end
            end

            -- # update queued orders
            order.queuedUnitsArray = validUnitsArray
            order:OnQueuedUnitsAssigned()

            for index, unit in ipairs(validUnitsArray) do
                table.insert(unit.orders.queuedOrders, order)
                if unit.orders.activeOrder then
                    unit.orders.activeOrder:OnUnitQueueChanged(unit)
                end
            end

            OrderCommands.OrderQueuedUnitsAdded.Send(order.id, GetUnitIds(order.queuedUnitsArray))

            -- # update active orders for idle units
            order.activeUnitsArray = {}
            -- shallowcopy because we are about to remove units from this array
            local validUnitsArray = table.shallowCopy(order.queuedUnitsArray)
            for index, unit in ipairs(validUnitsArray) do
                TryStartNextOrderForUnit(unit)
            end
        else
            -- Set target unit to null so Delete doesn't send a HostGameTriggers.OrderTargetSet:Invoke(self, nil) message to the client for an order that failed validation
            order.targetUnit = nil
            order:Delete()
        end
    end
    
    -- -- # tell the creator client we have processed their request
    OrderCommands.OrderAcknowledged.Send(orderId, orderTask, accepted, additionalPayload) -- this message should only go back to the creator client
end

function AddUnitToQueuedOrder(unit, order)
    table.insert(order.queuedUnitsArray, unit)
    table.insert(unit.orders.queuedOrders, order)
    OrderCommands.OrderQueuedUnitsAdded.Send(order.id, GetUnitIds({unit}))
    if unit.orders.activeOrder then
        unit.orders.activeOrder:OnUnitQueueChanged(unit)
    end
end

-- Copies oldUnit's orders to newUnit. Appends to back of newUnit's order queue. Ensures
-- a queued order is started if there is no active order.
function CopyOrders(oldUnit, newUnit)
    -- Copy the active order: activate if newUnit is idle, otherwise queue it
    if oldUnit.orders.activeOrder ~= nil then
        local order = oldUnit.orders.activeOrder
        if order:ValidateOrder() and order:ValidateUnitAssignment(newUnit) then
            if newUnit.orders.activeOrder == nil then
                newUnit.orders.activeOrder = order
                table.insert(order.activeUnitsArray, newUnit)
                OrderCommands.OrderActivatedForUnit.Send(order.id, newUnit.id)
                order:UnitStart(newUnit)
            else
                AddUnitToQueuedOrder(newUnit, order)
            end
        end
    end

    -- Copy queued orders to the end of newUnit's queue
    for _, order in ipairs(oldUnit.orders.queuedOrders) do
        if order:ValidateOrder() and order:ValidateUnitAssignment(newUnit) then
            AddUnitToQueuedOrder(newUnit, order)
        end
    end

    -- If newUnit has no active order, promote a queued order if one exists
    if newUnit.orders.activeOrder == nil then
        TryStartNextOrderForUnit(newUnit)
    end
end

function HandleUnitDestroyed(unit)
    LogSwitch("HandleUnitDestroyed: " .. unit.id.index)
    if unit.orders.activeOrder or #unit.orders.queuedOrders > 0 then
        ClearOrdersForUnit(unit)
    end
end

function ClearOrdersForUnit(unit)
    -- # update queued orders
    for index, order in ipairs(unit.orders.queuedOrders) do
        table.removeByValue(order.queuedUnitsArray, unit)
        OrderCommands.OrderQueuedUnitRemoved.Send(order.id, unit.id)
    end
    table.clear(unit.orders.queuedOrders)

    -- # update active order
    if unit.orders.activeOrder ~= nil then
        RemoveUnitFromActiveOrder(unit)
    end
end

function TryStartNextOrderForUnit(unit)
    -- # check if can start an order
    if unit.orders.activeOrder ~= nil -- busy
       or #unit.orders.queuedOrders == 0 -- nothing to do
    then
        return
    end

    -- # take one from the queue
    local order = unit.orders.queuedOrders[1]
    RemoveUnitFromQueuedOrder(unit, order)

    -- # activate it
    unit.orders.activeOrder = order
    table.insert(order.activeUnitsArray, unit)
    OrderCommands.OrderActivatedForUnit.Send(order.id, unit.id)
    -- # start order
    order:UnitStart(unit)
end

function RemoveUnitFromQueuedOrder(unit, queuedOrder)
    -- # update order
    OrderCommands.OrderQueuedUnitRemoved.Send(queuedOrder.id, unit.id)
    -- # update active order
    table.removeByValue(unit.orders.queuedOrders, queuedOrder)
    table.removeByValue(queuedOrder.queuedUnitsArray, unit)

    if unit.orders.activeOrder then
        unit.orders.activeOrder:OnUnitQueueChanged(unit)
    end
end

--- remove happens on clear, on complete
function RemoveUnitFromActiveOrder(unit)
    -- # update order
    OrderCommands.OrderDeactivatedForUnit.Send(unit.orders.activeOrder.id, unit.id)
    unit.orders.activeOrder:UnitStop(unit)
    -- # update active order
    table.removeByValue(unit.orders.activeOrder.activeUnitsArray, unit)
    unit.orders.activeOrder = nil
end

function OrderTargetUnitSet(order, unit)
    -- todo: we should only send this if it changed (ie from null to not-null). we send this for no reason sometimes
    if unit then
        OrderCommands.OrderTargetSet.Send(order.id, unit.id)
    else
        OrderCommands.OrderTargetCleared.Send(order.id)
    end
end

HostGameTriggers.OrderTargetSet:AddHandler(OrderTargetUnitSet)

function Update()
    local idleUnits = {}

    -- # update each unit for each order
    for _, order in pairs(ordersArray) do
        local toRemoveActiveArray = {}
        local toRemoveQueuedArray = {}

        -- todo: we dont need to revalidate every order every frame
        -- todo: we could limit it to the ones where the target changed
        if not order:ValidateOrder(false) then

            for index, unit in ipairs(order.activeUnitsArray) do
                table.insert(toRemoveActiveArray, unit)
                table.insert(idleUnits, unit)
            end
            for index, unit in ipairs(order.queuedUnitsArray) do
                table.insert(toRemoveQueuedArray, unit)
            end

        else

            for index, unit in ipairs(order.activeUnitsArray) do
                local isComplete = order:UnitUpdate(unit)
                if isComplete then
                    table.insert(toRemoveActiveArray, unit)
                    table.insert(idleUnits, unit)
                end
            end
        end

        -- # remove active units from this order (completed/invalid)
        for index, unit in ipairs(toRemoveActiveArray) do
            RemoveUnitFromActiveOrder(unit)
        end
        -- # remove queued units from this order (invalid)
        for index, unit in ipairs(toRemoveQueuedArray) do
            RemoveUnitFromQueuedOrder(unit, order)
        end
    end

    -- # remove orders with no units
    DeleteCompletedOrders()

    -- # start nxet orders for idle units
    for index, unit in ipairs(idleUnits) do
        TryStartNextOrderForUnit(unit)

        if unit.orders.activeOrder == nil then
            unit:OnBecameIdle()
        end
    end

    -- # draw
    UpdateOrderDraw();
end

function DeleteCompletedOrders()
     table.deleteWhere(ordersArray, function (_, order)
        -- # order is complete when all units are done/cancelled
        --LogSwitch("completion: order.activeUnitsArray=="..#order.activeUnitsArray..","..#order.queuedUnitsArray)
        local isComplete = #order.activeUnitsArray == 0 and #order.queuedUnitsArray == 0
        if isComplete then
            
            order:Delete()
            if verboseLog then
                LogSwitch("$DeleteCompletedOrders.. " .. repr(order.id))
            end
            OrderCommands.OrderDeleted.Send(order.id)
        end
        return isComplete
     end)
end

function UpdateOrderDraw()
    -- local color1 = Engine.Types.float4(1, 0, 0, 0.5)
    -- local color2 = Engine.Types.float4(1, 0, 0, 1)
    -- for _, order in pairs(ordersArray) do
    --     local color = #order.activeUnitsArray > 0 and color2 or color1
    --     Engine.DrawCircle(order.positionFloat3, 1, color)

    --     -- foreach active unit
    --     for _, unit in pairs(order.activeUnitsArray) do
    --         -- draw a line from unit to active order
    --         Engine.DrawLine(unit:GetPosition(), order.positionFloat3, color2)
    --         local previous = order.positionFloat3

    --         -- foreach queued order, draw a line from previous order 
    --         for _, queuedOrder in pairs(unit.orders.queuedOrders) do
    --             Engine.DrawLine(previous, queuedOrder.positionFloat3, color1)
    --             previous = queuedOrder.positionFloat3
    --         end
    --     end
    -- end
end

function GetOrderClass(orderTask)
    local orderClass = OrderClasses[orderTask]
    if not orderClass then
        Error("Could not find order class for task: " .. tostring(orderTask))
        return nil
    end
    return orderClass
end

function LogSwitch(msg)
    if verboseLog then
        Log("HostOrderManager: " .. msg)
    end
end
-- A valid native replacement order or STOP cancels pickup/drop reservations.
-- Cargo's own approach orders pass through this same manager without cancelling.
local SCOCargoClearOrdersForUnit=ClearOrdersForUnit
function ClearOrdersForUnit(unit)
    if not unit.scoCargoIssuingOrder and unit.SCOCancelCargoTasks then
        unit:SCOCancelCargoTasks()
    end
    return SCOCargoClearOrdersForUnit(unit)
end

-- Replacement orders and native Stop cancel a pending Overcharge aim.
do
    local previous = ClearOrdersForUnit
    function ClearOrdersForUnit(unit)
        Import('common/systems/scoOvercharge.lua').CancelForOrders(unit)
        return previous(unit)
    end
end
