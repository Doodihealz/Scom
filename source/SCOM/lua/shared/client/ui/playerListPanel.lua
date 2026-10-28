local Lobby = Import("common/lobby.lua")
local Factions = Import("common/systems/factions.lua")

local factionDisplayNames = {
    EDA = "UEF",
    Chosen = "Aeon",
    Guard = "Cybran",
}

---@class PlayerListPanel
PlayerListPanel = Class("PlayerListPanel")

local isEnabled = false
local isDirty = true
local lastArmyCount = 0

function PlayerListPanel.__init()
    Engine.UI_SetPanelVisibility(UIPanelType.Players, isEnabled)
end

--- Use only when color, disconnects, etc...
function PlayerListPanel.SetDirty()
    isDirty = true
end

function PlayerListPanel:SetEnabled(enabled)
    if enabled ~= isEnabled then
        isEnabled = enabled
        Engine.UI_SetPanelVisibility(UIPanelType.Players, enabled)
    end
end

local function Rebuild()
    Engine.UI_ClearElements(UIPanelType.Players)

    -- Sort armies by ID
    local armyIds = {}
    for armyId in pairs(Armies) do
        table.insert(armyIds, armyId)
    end
    table.sort(armyIds)

    for _, armyId in ipairs(armyIds) do
        local army = Armies[armyId]
        local player = Lobby.LobbyEntriesByArmy[armyId]
        if player and not army.civilian then
            local faction = Factions.FactionsData[army.factionId]
            Engine.UI_AddPlayerListEntry({
                playerName = player.nickname,
                armyID = armyId,
                factionName = faction and (factionDisplayNames[faction.name] or faction.name) or "",
                color = army.color,
            })
        end
    end
end

function PlayerListPanel.Update()

    if isEnabled == false then
        return
    end

    local armyCount = table.size(Armies)
    if armyCount ~= lastArmyCount then
        lastArmyCount = armyCount
        isDirty = true
    end

    if isDirty then
        isDirty = false
        Rebuild()
    end
end