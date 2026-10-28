local DebugUI = Import("client/ui/debugUI.lua")
local TempBuildMode = Import("client/input/buildmodeTemp.lua")
local SelectionSystem = Import("client/input/selectionSystem.lua")
local UIManager = Import("client/ui/uiManager.lua")
local ConstructionPreviewSystem = Import("client/input/constructionPreviewSystem.lua")
local DragFormationPreviewSystem = Import("client/input/dragFormationPreviewSystem.lua")
local CommonOrders = Import("common/commonOrders.lua")
local ClientOrderManager = Import("client/managers/orders/clientOrderManager.lua")
local OrderTasks = CommonOrders.OrderTasks

local ToggleNameToToggleType = Import("common/toggles.lua").ToggleNameToToggleType

local MouseCursor = Import("client/input/mouseCursor.lua")
local PredictedUnit = Import("client/entities/predictedUnit.lua").PredictedUnit
local DragFormation = Import("client/dragFormation.lua")
local isAppendingToQueue = false
local isAltDown = false
local isPatrolAttackMoveMode = false
local patrolAttackMoveAppend = false
---@type float3[]
local patrolAttackMoveWaypoints = {}
local isPatrolMode = false
local isPatrolAppend = false
---@type float3[]
local patrolWaypoints = {}

local function ResetPatrolMode()
    isPatrolMode = false
    isPatrolAppend = false
    patrolWaypoints = {}
end

--- Issues a patrol order with the given waypoints.
---@param append boolean
---@param routeWaypoints float3[]
local function IssuePatrolWaypoints(append, routeWaypoints)
    if #routeWaypoints == 0 then return end

    local position = routeWaypoints[1]
    local waypoints = {}
    for index = 2, #routeWaypoints do
        table.insert(waypoints, routeWaypoints[index])
    end

    -- For now we do an attack move patrol. This will change in the future with other inputs?
    ClientOrderManager.ClientIssueOrder(
        OrderTasks.PATROLATTACKMOVE,
        SelectionSystem.GetSelectedUnits(),
        append,
        position,
        { align = false, waypoints = waypoints }
    )
end

local function IssuePatrolOrder()
    if #patrolWaypoints == 0 then
        ResetPatrolMode()
        return
    end

    local shouldAppend = isPatrolAppend
    local routeWaypoints = patrolWaypoints
    ResetPatrolMode()

    IssuePatrolWaypoints(shouldAppend, routeWaypoints)
end

local function UpdatePatrolMode()
    if isPatrolMode and isPatrolAppend and not isAppendingToQueue then
        IssuePatrolOrder()
    end
end

---@param position float3
local function AddPatrolWaypoint(position)
    table.insert(patrolWaypoints, position)
    if isAppendingToQueue then
        isPatrolAppend = true
    else
        IssuePatrolOrder()
    end
end

function BeginPatrolOrder()
    if isPatrolMode or TempBuildMode.GetBuildMode() or SelectionSystem.SelectionBox:IsActive()
        or isPatrolAttackMoveMode then return end
    if not next(SelectionSystem.GetSelectedUnits()) then return end

    isPatrolMode = true
    isPatrolAppend = false
    patrolWaypoints = {}
end

---Records Shift+Alt right-click points and submits one patrol order when the chord ends.
---@return nil
local function UpdatePatrolAttackMoveMode()
    local shouldBeActive = isAppendingToQueue and isAltDown
    if shouldBeActive == isPatrolAttackMoveMode then return end

    isPatrolAttackMoveMode = shouldBeActive
    if shouldBeActive then
        patrolAttackMoveWaypoints = {}
        patrolAttackMoveAppend = isAppendingToQueue
        return
    end

    if #patrolAttackMoveWaypoints > 0 then
        IssuePatrolWaypoints(patrolAttackMoveAppend, patrolAttackMoveWaypoints)
    end

    patrolAttackMoveWaypoints = {}
end

-------------------------------------------------------------------------------------------------------------------
-- todo: delete this entire file - the individual input events should be moved to either the new input system or into their respective systems.
-------------------------------------------------------------------------------------------------------------------
function OnMouseLeftDown()
    if not MouseCursor.IsCursorInGameView() then return end
