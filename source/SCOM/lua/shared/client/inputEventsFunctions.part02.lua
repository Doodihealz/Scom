    
    if Engine.IsMouseOverUI() then return end
    if isPatrolMode then return end

    local buildMode = TempBuildMode.GetBuildMode()

    if buildMode then
        TempBuildMode.StartLineDrag()
    else
        SelectionSystem.SelectionBox:Start()
    end
end

function OnMouseLeftUp()

    if not MouseCursor.IsCursorInGameView() then return end
    if isPatrolMode then
        if Engine.IsMouseOverUI() then return end
        AddPatrolWaypoint(MouseCursor.GetMousePosition())
        return
    end

