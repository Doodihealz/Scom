
    local buildMode = TempBuildMode.GetBuildMode()

    if buildMode and not Engine.IsMouseOverUI() then --hack to prevent build mode from being cancelled while clicking the construction button
        ConstructionPreviewSystem.RemoveExistingConstructionGhosts() --Clean up previous frame placement ghosts so that GetBuildingPlacementPositions returns the correct values
        local placementPositions = ConstructionPreviewSystem.GetBuildingPlacementPositions()
        if next(placementPositions) then
            local selectedUnits = SelectionSystem.GetSelectedUnits()
            local _, firstUnit = next(selectedUnits)
            if firstUnit then
                local builderArmyId = firstUnit.armyId
                IssueBuildOrderTemp(placementPositions, builderArmyId)
                if isAppendingToQueue == false then
                    TempBuildMode.SetBuildMode(false)
                end
            end
        end
        
        TempBuildMode.ClearStartPosition()
    end

    if SelectionSystem.SelectionBox:IsActive() then
        SelectionSystem.SelectionBox:End()
    end
end

---@return nil
function OnMouseRightDown()
    if not MouseCursor.IsCursorInGameView() then return end
