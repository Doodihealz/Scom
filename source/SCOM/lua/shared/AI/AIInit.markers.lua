    AIMarkerGenerator.InitMarkerGenerator()
    -- Human-only matches do not consume the AI navigation graph. The player
    -- takeover path already creates it on demand if AI is enabled later.
    local needsAIMarkers = false
    if not lobbyOptionsAIOverride or allowedAIPlayerCount > 0 then
        local getStartPosition = Import("AI/AIFunctions.lua").GetArmyStartPosition
        for _, army in pairs(Armies) do
            if army.lobbyOptions and army.lobbyOptions.aiSettings
                and getStartPosition(army.name) then
                needsAIMarkers = true
                break
            end
        end
    end
    if needsAIMarkers or lobbyOptionsAI.debugPathFinding
        or lobbyOptionsAI.debugMarkerDirtyMap or lobbyOptionsAI.debugMarkerGenerator then
        AIMarkerGenerator.CreateAIMarkers(14)  -- gridCellSize 14
    end
