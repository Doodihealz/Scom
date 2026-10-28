    if TempBuildMode.GetBuildMode() then return end
    if Engine.IsMouseOverUI() then return end
    if SelectionSystem.SelectionBox:IsActive() then return end
    if isPatrolAttackMoveMode then return end
    if isPatrolMode then return end

    DragFormationPreviewSystem.StartFormationDrag()
end

---comment
---@return ClientUnit|Prop
function GetHoverUnit()
    local highLightedUnits = SelectionSystem.GetHighlightedUnitsAndProps()
    local _, targetUnit = next(highLightedUnits)
    return targetUnit
end

function OnMouseRightUp()
