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

-- Match the native card's two shield rows to the actual client entities.
-- Enhancement placeholders stay hidden until their runtime maximum is installed.
local function SCOShieldValues(tp, unit)
    local bubble = {value = 0, maximum = 0, regen = 0}
    local armour = {value = 0, maximum = 0, regen = 0}
    for index, spec in ipairs(tp.defence and tp.defence.shields or {}) do
        local bucket
        if spec.type == 0 or spec.type == "Bubble" then
            bucket = bubble
        elseif spec.type == "Personal" then
            bucket = armour
        end
        if bucket then
            local shield = unit and unit.shields and unit.shields[index]
            local maximum = shield and shield:GetMaxHealth() or spec.max or 0
            if not spec.scoCommanderEnhancementShieldId or maximum > 1 then
                bucket.maximum = bucket.maximum + maximum
                bucket.regen = bucket.regen + (shield and shield:GetHealthRegen() or spec.regen or 0)
                if unit then
                    bucket.value = bucket.value + (shield and shield:GetHealth() or 0)
                else
                    bucket.value = bucket.value + (spec.value or spec.max or 0)
                end
            end
        end
    end
    return bubble, armour
end

function InformationPanel:UpdateUnitInformationPanel(unit)
    local unitName = unit.tp.general.name
    local scoSiloBuilding, scoSiloProgress, scoSiloAmmo =
        SCOGetSiloInformationValues(unit)
    local bubble, armour = SCOShieldValues(unit.tp, unit)
    if not scoSiloBuilding and not unit:IsCompleted() then
        scoSiloBuilding = true
        scoSiloProgress = math.max(0, math.min(1, unit:GetFractionComplete()))
    end
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

        isArmourShieldEnabled = armour.maximum > 0,
        armourShieldValue = armour.value,
        armourShieldMax = armour.maximum,
        armourShieldRegen = armour.regen,

        isBubbleShieldEnabled = bubble.maximum > 0,
        bubbleShieldValue = bubble.value,
        bubbleShieldMax = bubble.maximum,
        bubbleShieldRegen = bubble.regen,

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
    local bubble, armour = SCOShieldValues(tp)
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

        isArmourShieldEnabled = armour.maximum > 0,
        armourShieldValue = armour.value,
        armourShieldMax = armour.maximum,
        armourShieldRegen = armour.regen,

        isBubbleShieldEnabled = bubble.maximum > 0,
        bubbleShieldValue = bubble.value,
        bubbleShieldMax = bubble.maximum,
        bubbleShieldRegen = bubble.regen,

        isConstructionPercentEnabled = false,
        constructionPercent = 0,

        veterancy = 0,
        transportCapacity = 0,
        ammoCapacity = 0,

        currentOrderName = nil
    })
end

-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0
