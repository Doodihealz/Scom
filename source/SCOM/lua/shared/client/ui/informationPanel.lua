InformationPanel = Class("InformationPanel")

local isEnabled = false

function InformationPanel:SetEnabled(enabled)
    if enabled ~= isEnabled then
        isEnabled = enabled
        Engine.UI_SetPanelVisibility(UIPanelType.Information, enabled)
    end
end

---comment
---@param unit ClientUnit
-- SCOM silo information-panel ammunition and build progress.
local function SCOGetSiloInformationValues(unit)
    local getState = _G.SCO_GetStrategicSiloClientState
    local state = type(getState) == "function" and getState(unit)
    local ammo = state and state.ammo or 0
    if not state or state.building ~= true then
        return false, 0, ammo
    end

    local progress = 0
    if type(state.work) == "number"
        and type(state.buildTime) == "number"
        and state.buildTime > 0
    then
        progress = math.max(0, math.min(1, state.work / state.buildTime))
    end
    return true, progress, ammo
end

function InformationPanel:UpdateUnitInformationPanel(unit)
    local unitName = unit.tp.general.name
    local scoSiloBuilding, scoSiloProgress, scoSiloAmmo =
        SCOGetSiloInformationValues(unit)
    local unitDisplayName = unit.tp.general.displayName
    if not unitName or unitName == "" then
        unitName = unitDisplayName
        unitDisplayName = nil
    end
    Engine.UI_SetUnitInformationValues({
        unitName = unitName,
        unitTemplateID = unit.tpId,
        unitDisplayName = unitDisplayName,

        healthValue = unit:GetHealth() or 0,
        healthMax = unit:GetMaxHealth() or 0,
        healthRegen = unit:GetHealthRegen() or 0,

        buildPower = unit.buildPower or 0,

        energyBuildCost = unit.tp.economy.cost.energy or 0,
        energyNetIncome = unit.resources.energy,
        alloyBuildCost = unit.tp.economy.cost.alloys or 0,
        alloyNetIncome = unit.resources.alloys,

        currentOrderIcon = { index = 0 },

        isArmourShieldEnabled = false,
        armourShieldValue = 0,
        armourShieldMax = 0,
        armourShieldRegen = 0,

        isBubbleShieldEnabled = false,
        bubbleShieldValue = 0,
        bubbleShieldMax = 0,
        bubbleShieldRegen = 0,

        isConstructionPercentEnabled = scoSiloBuilding,
        constructionPercent = scoSiloProgress,

        veterancy = unit.scoVeterancyKills or 0,
        transportCapacity = 0,
        ammoCapacity = scoSiloAmmo,

        currentOrderName = nil
    })
end

---comment
---@param tp UnitTemplate
function InformationPanel:UpdateUnitInformationPanelTemplate(tp)
    local unitName = tp.general.name
    local unitDisplayName = tp.general.displayName
    if not unitName or unitName == "" then
        unitName = unitDisplayName
        unitDisplayName = nil
    end

    local production = tp.economy.production
    local maintenance = tp.economy.maintenanceConsumption
    Engine.UI_SetUnitInformationValues({
        unitName = unitName,
        unitTemplateID = tp.general.tpId,
        unitDisplayName = unitDisplayName,

        healthValue = tp.defence.health.value or 0,
        healthMax = tp.defence.health.max or 0,
        healthRegen = tp.defence.health.regen or 0,

        buildPower = (tp.construction and tp.construction.buildPower) or 0,

        energyBuildCost = tp.economy.cost.energy,
        energyNetIncome = ((production and production.energy) or 0) - ((maintenance and maintenance.energy) or 0),
        alloyBuildCost = tp.economy.cost.alloys,
        alloyNetIncome = ((production and production.alloys) or 0) - ((maintenance and maintenance.alloys) or 0),

        currentOrderIcon = { index = 0 },

        isArmourShieldEnabled = false,
        armourShieldValue = 0,
        armourShieldMax = 0,
        armourShieldRegen = 0,

        isBubbleShieldEnabled = false,
        bubbleShieldValue = 0,
        bubbleShieldMax = 0,
        bubbleShieldRegen = 0,

        isConstructionPercentEnabled = false,
        constructionPercent = 0,

        veterancy = 0,
        transportCapacity = 0,
        ammoCapacity = 0,

        currentOrderName = nil
    })
end

-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0
