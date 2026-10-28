local SCOM_EditableUnits = Import("scom/editableUnits.lua")
local HostEntity = Import("host/entity.lua").HostEntity
local Factions = Import("common/systems/factions.lua")
local ResourceEntity = Import("host/systems/resourceEntity.lua").ResourceEntity
local Weapon = Import("host/units/weaponsClasses/weaponsBaseClass.lua").HostWeapon
local HostOrderManager = Import("host/managers/orders/hostOrderManager.lua")
local OrderTasks = Import("common/commonOrders.lua").OrderTasks
local ToggleTypes = Import("common/toggles.lua").ToggleTypes
local CollisionUpdate = Import("host/collisionUpdate.lua")
local IntelLayer = Import("host/managers/intel/intelLayer.lua").IntelLayer
local ConstructionDetector = Import("host/managers/colliders/constructionDetector.lua")
local TargetCollider = Import("host/managers/targeting/targetCollider.lua")
local HostCollider = Import("host/managers/colliders/collider.lua")
local NavmapModifiers = Import("common/navmapModifiers.lua")
local MovementPatterns = Import("common/movementPatterns.lua")
local UnitEnums = Import("common/units/unitEnums.lua")
local SessionCommands = Import("common/commands/definitions/session.lua")
local Lobby = Import("common/lobby.lua")

local Worker = Import("host/interfaces/work/worker.lua").Worker
local Workable = Import("host/interfaces/work/workable.lua").Workable

local DashBehavior = Import("host/interfaces/behaviors/dashBehavior.lua").DashBehavior

local EconomyCommands = Import("common/commands/definitions/economy.lua")
local IntelCommands   = Import("common/commands/definitions/intel.lua")
local ToggleCommands  = Import("common/commands/definitions/toggles.lua")
local UnitCommands    = Import("common/commands/definitions/units.lua")
local WorkCommands    = Import("common/commands/definitions/work.lua")
local Layers = Import("common/layers.lua")

local Units = __Entities.Units
local Shields = __Entities.Shields

---@class HostUnit: HostEntity, Worker, Workable, DashBehavior
---@field tp Template Unit's template
---@field platoon Platoon|nil
---@field protected rotatorIds GlobalID[] Bone global IDs of this unit's rotators
HostUnit = Class("UnitBase", HostEntity, Worker, Workable, DashBehavior)

HostUnit.DefaultTargetingLayer = Layers.TargetingLayer.Land
HostUnit.GroundedNavigationLayerName = nil

HostUnit.DefaultIsInWater = false

local DamagedAlertMaxNoDamageTakenInSeconds = 15

--- Sets up basics things for the new unit instance. Called automatically when new class instance is created.
---@param id GlobalID - GlobalID for this unit.
---@param armyId integer - Army ID for this unit.
---@param template UnitTemplate - Template for this unit.
---@param fractionCompleted number - Sets the build fractionCompleted of the unit. Range 0.0 - 1.0.
---@protected
function HostUnit:__init(id, armyId, template, fractionCompleted)
    HostEntity.__init(self, id)

    Worker.__init(self)
    Workable.__init(self)
    DashBehavior.__init(self)

    self.tp = template
    self.name = self.tp.general.name
    self.tpId = self.tp.general.tpId

    -- todo: i reckon i can get rid of thse by making a smarter callback system
    self.energyDownCallback = function()
        self:OnEnergyDown()
    end
    self.energyUpCallback = function()
        self:OnEnergyUp()
    end

    self.entityType = "unit"
    self.dead = false

    if self.tp.audio and self.tp.audio.onDamagedAlert and self.tp.audio.onDamagedAlert.name then
        self.lastDamageAlertTime = -DamagedAlertMaxNoDamageTakenInSeconds
        self:AddCallback(self.OnDamagedAlert, "OnDamaged")
    end

    ---@type HostWeapon[]
    self.weapons = {}
    self.hasTarget = false -- TODO: Check what this does
    self.resourceEntities = {}
    self.canTakeDamage = true
    self.canBeKilled = true

    self.isSlaveFactory = false
    ---@type Factory
    self.masterFactory = nil

    self.buffs = {}
    self.orders = {
        activeOrder = nil, -- managed by hostOrderManager
        queuedOrders = {}, -- managed by hostOrderManager
    }

    self.toggles = table.deepCopy(self.tp.general.toggles);
    -- Some editable SCOM templates omit controls. Own a table per instance
    -- while preserving the absent keys that determine available UI toggles.
    if self.toggles == nil and SCOM_EditableUnits.IsEditable(self.tp) then
        self.toggles = {}
    end

    -- Setup fog of war detectors. Must be setup before calling HostUnit:SetArmy as this will change the intel state.
    self:SetUpIntel()

    self:SetArmy(GetArmy(armyId))

    -- Save common lookup data (faction, layer, tech)
    local id, name, tag = Factions.GetUnitFactionData(self)
    self.factionId = id
    self.faction = name
    self.factionTag = tag

    self.targetingLayer = self.DefaultTargetingLayer
    self.isInWater = self.DefaultIsInWater
    self.isUnderWater = false

    -- The movement template spawns the unit on its native navigation layer; classes that start out
    -- of their element (parked aircraft, surfaced submarines) correct that here.
    if self.GroundedNavigationLayerName ~= nil then
        self:SetNavigationLayer(Layers.GetNavigationLayerByName(self.GroundedNavigationLayerName))
    end

    if self:HasTags(Tags.AIR) then
        self.layerTag = "AIR"
    elseif self:HasTags(Tags.LAND) then
        self.layerTag = "LAND"
    elseif self:HasTags(Tags.NAVAL) then
        self.layerTag = "NAVAL"
    end

    if self:HasTags(Tags.TECH1) then
        self.techTag = "TECH1"
    elseif self:HasTags(Tags.TECH2) then
        self.techTag = "TECH2"
    elseif self:HasTags(Tags.TECH3) then
        self.techTag = "TECH3"
    end

    self:SetFractionComplete(fractionCompleted)

    -- Resource entity that build and repairs this unit
    self.resourceEntities["construction"] = ResourceEntity(
        self.army.id,
        self.id,
        "construction",
        nil,
        nil,
        true
    )
    -- TODO: Prolly send the whole tp so it extracts everything it needs.
    self.resourceEntities["construction"]:SetCost(self.tp.economy.cost)
    self.resourceEntities["construction"]:SetBuildTime(self.tp.economy.buildTime)

    -- For engineers, factories, upgradable structures
    self:SetupConstruction()
    self:SetUpWreck()
    self:CreateResourceEntities()

    -- Create weason if unit has some
    self:SetUpWeapons()
    self:SetUpAttackRange()
    self:SetUpCanAttack()
    self:SetUpTarget()

    self:ApplyGroupID()

    self:SetupRotators()
    self:SetupAnimations()

    -- Create shields
    self:SetUpShields()

    -- Set up initial HP / max HP
    self:SetMaxHealth(self.tp.defence.health.max)
    self:SetHealth((self.tp.defence.health.value or self:GetMaxHealth()) * fractionCompleted)
    
    self:SetUnitStateFromProgress()

    -- Spawned by other unit to be constructed.
    if self:IsCompleted() then
        self.bypassedBuildProcess = true
        self:OnStopBeingBuilt()
    else -- This is wrong. We can spawn a unit which is a placement ghost! Has not started being built.
        --self:OnStartBeingBuilt()

        -- If we are not complete then we need to check our starting states.
        -- We check states in OnStopBeingBuilt so we do not need to do that there.
        self:CheckShieldState()
        self:CheckRadarState()
        self:CheckSonarState()
    end
end

function HostUnit:SetUpTarget()
    self.isTargetable = false
    self.targetBoneIds = {}
    for _, boneName in ipairs(self.tp.collisionInfo.targetBones or {}) do
        local boneId = self:GetBoneId(boneName)
        if boneId then
            table.insert(self.targetBoneIds, boneId)
        else
            Engine.Warn("Missing target bone: " .. boneName .. " on unit " .. self.tpId)
        end
    end

    local targetColliderID = self:GetBoneId("TargetCollider")
    ---@type TargetCollider
    self.targetCollider = TargetCollider.CreateTargetCollider(targetColliderID, self)
end

function HostUnit:ApplyGroupID()
    local groupID = self.army.id

    self.visionLayer:SetGroupID(groupID)
    self.radarLayer:SetGroupID(groupID)
    self.sonarLayer:SetGroupID(groupID)

    if self.visionDetector then
        self.visionDetector:SetGroupID(groupID)
    end

    if self.radarDetector then
        self.radarDetector:SetGroupID(groupID)
    end

    if self.sonarDetector then
        self.sonarDetector:SetGroupID(groupID)
    end

    if self.targetCollider then
        self.targetCollider:SetGroupID(groupID)
    end

    for _, weapon in ipairs(self.weapons) do
        if weapon.targeterCollider then
            weapon.targeterCollider:SetGroupID(groupID)
        end
    end
end

---@private
---@param signatureColliderName string
---@param collisionWorld integer
---@param onVisibilityChanged function Called the intel visibility changes.
---@return IntelLayer inteLayer
function HostUnit:CreateIntelLayer(signatureColliderName, collisionWorld, onVisibilityChanged)

    -- Vision layer: tracks which armies can see this unit via line-of-sight.
    -- SetArmy seeds own-army visibility; the intel manager handles enemy detection.
    local signatureColliderID = self:GetBoneId(signatureColliderName)
    local signatureCollider = HostCollider.CreateHostCollider(signatureColliderID)

    ---@type IntelLayer
    local intelLayer = IntelLayer.new(signatureCollider, collisionWorld, onVisibilityChanged)

    return intelLayer
end

-- TODO: Rename intel layer to intel signature.

function HostUnit:SetUpIntel()
    -- SetArmy seeds own-army visibility; the intel manager queries the detectors every tick.
    self.visionLayer = self:CreateIntelLayer("IntelVisionSignatureCollider", CollisionWorld.IntelVision, function(mask)
        IntelCommands.SetIntelVision.Send(self.id, mask)
    end)
    self.radarLayer = self:CreateIntelLayer("IntelRadarSignatureCollider", CollisionWorld.IntelRadar, function(mask)
        IntelCommands.SetIntelRadar.Send(self.id, mask)
    end)
    self.sonarLayer = self:CreateIntelLayer("IntelSonarSignatureCollider", CollisionWorld.IntelSonar, function(mask)
        IntelCommands.SetIntelSonar.Send(self.id, mask)
    end)

    if self.tp.intel.visionRadius then
        self.visionDetector = HostCollider.CreateHostCollider(self:GetBoneId("IntelVisionDetectorCollider"))
    end

    if self.tp.intel.radarRadius then
        self.radarDetector = HostCollider.CreateHostCollider(self:GetBoneId("IntelRadarDetectorCollider"))
    end

    if self.tp.intel.sonarRadius then
        self.sonarDetector = HostCollider.CreateHostCollider(self:GetBoneId("IntelSonarDetectorCollider"))
    end

    self.wantsRadarActive = false
    self.wantsSonarActive = false
end

---If the unit should provide intel detection and/or be an intel signature.
---@param enabled boolean
function HostUnit:SetIntelEnabled(enabled)
    self.intelEnabled = enabled

    self:CheckVisionState()
    self:RecalculateIntelEnvironment()
end

---@public Set if the unit's hull is fully under water.
---@param isUnderWater boolean
function HostUnit:SetUnderWater(isUnderWater)
    if self.isUnderWater == isUnderWater then return end

    self.isUnderWater = isUnderWater

    self:RecalculateIntelEnvironment()
    self:CheckVisionState()
    self:CheckRadarState()
end

---@public Set if the unit is on or in the water.
---@param isInWater boolean
function HostUnit:SetInWater(isInWater)
    if self.isInWater == isInWater then return end

    self.isInWater = isInWater

    self:RecalculateIntelEnvironment()
end

---@private Enable the intel signatures that can see the unit in its current environment.
function HostUnit:RecalculateIntelEnvironment()
    local enabled = self.intelEnabled == true

    self.visionLayer:SetEnabled(enabled and not self.isUnderWater)
    self.radarLayer:SetEnabled(enabled and not self.isUnderWater)
    self.sonarLayer:SetEnabled(enabled and self.isInWater)
end

---@public Update the vision based on intel being enabled and the environment.
function HostUnit:CheckVisionState()
    if not self.visionDetector then return end

    local isVisionActive = self.intelEnabled == true and not self.isUnderWater

    if self.visionDetector:GetEnabled() ~= isVisionActive then
        self.visionDetector:SetEnabled(isVisionActive)
        UnitCommands.SetVisionActive.Send(self.id, isVisionActive)
    end
end

---@public Updates the radar's active state based on unit completion, player toggle, and energy availability.
function HostUnit:CheckRadarState()
    if not self.radarDetector or self.progress == nil then return end

    -- Check whether the player has manually toggled radar on (if the unit supports toggling).
    local isPlayerToggleOn = true
    if self:ToggleExists("Intel") then
        isPlayerToggleOn = self:GetIntelToggle()
    end
    
    -- Radar wants to be active when the unit is fully built and the player hasn't disabled it.
    self.wantsRadarActive = self:IsCompleted() and isPlayerToggleOn and not self.isUnderWater

    -- Enable/disable energy drain.
    self:CheckIntelConsumption()
    
    -- Radar only actually emits if the player's economy can sustain it (not energy-stalled).
    local isRadarActive = self.wantsRadarActive and not self.army.economy.isEnergyDown

    if self.radarDetector:GetEnabled() ~= isRadarActive then
        self.radarDetector:SetEnabled(isRadarActive)
        UnitCommands.SetRadarActive.Send(self.id, isRadarActive)
    end
end

---@public Update the sonar's active state based on unit completion, player toggle, and energy availability.
function HostUnit:CheckSonarState()
    if not self.sonarDetector or self.progress == nil then return end

    local isPlayerToggleOn = true
    if self:ToggleExists("Intel") then
        isPlayerToggleOn = self:GetIntelToggle()
    end

    self.wantsSonarActive = self:IsCompleted() and isPlayerToggleOn

    self:CheckIntelConsumption()

    local isSonarActive = self.wantsSonarActive and not self.army.economy.isEnergyDown

    if self.sonarDetector:GetEnabled() ~= isSonarActive then
        self.sonarDetector:SetEnabled(isSonarActive)
        UnitCommands.SetSonarActive.Send(self.id, isSonarActive)
    end
end

---@private Enable the energy drain while the radar or sonar wants to be active.
function HostUnit:CheckIntelConsumption()
    if self.resourceEntities.consumption then
        self.resourceEntities.consumption:SetEnabled(self.wantsRadarActive or self.wantsSonarActive)
    end
end

---Returns if any existing intel type detects this unit for the army.
---@param army HostArmy
---@return boolean isIntelVisible
function HostUnit:IsIntelVisible(army)
    return self:IsIntelVisionVisible(army) or self:IsIntelRadarVisible(army) or self:IsIntelSonarVisible(army)
end

---Returns if the unit is visible to the army on vision.
---@param army HostArmy
---@return boolean isIntelVisionVisible If the unit is visible to the army.
function HostUnit:IsIntelVisionVisible(army)
    return self.visionLayer:IsVisible(army)
end

---Returns if the unit is visible to the army on radar.
---@param army HostArmy
---@return boolean isIntelRadarVisible If the unit is visible to the army.
function HostUnit:IsIntelRadarVisible(army)
    return self.radarLayer:IsVisible(army)
end

---Returns if the unit is visible to the army on sonar.
---@param army HostArmy
---@return boolean isIntelSonarVisible If the unit is visible to the army.
function HostUnit:IsIntelSonarVisible(army)
    return self.sonarLayer:IsVisible(army)
end

function HostUnit:SetArmy(army)
    -- clean up old army
    if self.army then
        self.army.economy.EnergyDownTrigger:RemoveHandler(self.energyDownCallback)
        self.army.economy.EnergyUpTrigger:RemoveHandler(self.energyUpCallback)
    end

    --BUG: This does not properly remove the unit from the army.units and army.stats.units
    --BUG: This does not properly add the unit to the new army.units and army.stats.units

    ---@type HostArmy
    self.army = army
    army.economy.EnergyDownTrigger:AddHandler(self.energyDownCallback)
    army.economy.EnergyUpTrigger:AddHandler(self.energyUpCallback)

    self.visionLayer:SetOwnerArmy(army.id) -- Always visible to its own army.
    self:ApplyGroupID()

    self:CheckShieldState()
    self:CheckRadarState()
    self:CheckSonarState()
end

function HostUnit:OnEnergyDown()
    self:CheckShieldState()
    self:CheckRadarState()
    self:CheckSonarState()
end

function HostUnit:OnEnergyUp()
    self:CheckShieldState()
    self:CheckRadarState()
    self:CheckSonarState()
end

---@public 
---@param toggle ToggleName The name of the toggle.
---@param value boolean toggle value
function HostUnit:SetToggle(toggle, value)
    if toggle == "Submerge" and self.SetSubmerged then
        value = self:SetSubmerged(value)
    end

    if toggle == "Pause" then
        self:SetPause(value)
    else
        self.toggles[toggle] = value
    end

    if toggle == "Shield" then
        self:CheckShieldState()
    end

    if toggle == "Intel" then
        self:CheckRadarState()
        self:CheckSonarState()
    end

    if toggle == "Production" then
        self:CheckProductionState()
    end

    self:UpdateUIValues()

    ToggleCommands.SetUnitToggle.Send(self, ToggleTypes[toggle], value)
end

---@public Copies this unit's toggle states onto another unit. Only toggles that `otherUnit` also supports are copied; unsupported ones are skipped.
---@param otherUnit HostUnit The unit to copy this unit's toggle states onto.
function HostUnit:CopyToggles(otherUnit)
    for name, value in pairs(self.toggles) do
        if otherUnit.toggles[name] ~= nil then
            otherUnit:SetToggle(name, value)
        end
    end
end

function HostUnit:CanMove()
    return self:HasTags(Tags.MOBILE)
end

-- function HostUnit:EnsureInRange(position, range)
--     if self.isMoving then
--         return false -- waiting to stop
--     elseif self:GetIsInRange(position, range) then
--         return true -- done
--     else
--         self:StartMoving(position, range)
--         return false
--     end
-- end

function HostUnit:CheckProductionState()
    if self.resourceEntities.production then
        local canEnableProduction = self:IsCompleted() and self:GetProductionToggle()
        self.resourceEntities.production:SetEnabled(canEnableProduction)
    end
end

--* factories should repeat
--* slave factories should take and put back onto the master queue
function HostUnit:SetRepeatBuild(value)
    self.toggles.RepeatBuild = value
end

function HostUnit:GetRepeatBuild()
    return self.toggles.RepeatBuild
end

function HostUnit:SetPause(value)
    if self.toggles.Pause == value then return end

    self.toggles.Pause = value
    
    -- Build, Repair, Reclaim, Capture each handle pause inside their own thread by polling
    -- GetPause(); they do not need a dispatch here. Production and Upgrade still use hooks.
    if value then
        if self.productionBehaviorIsActive then
            self:OnPauseProduction()
        end
    else
        if self.productionBehaviorIsActive then
            self:OnUnpauseProduction()
        end
    end
end

function HostUnit:GetPause()
    return self.toggles.Pause
end

function HostUnit:SetShieldToggle(value)
    self.toggles.Shield = value
end

function HostUnit:GetShieldToggle()
    return self.toggles.Shield
end

function HostUnit:SetIntelToggle(value)
    self.toggles.Intel = value
end

---@return boolean
function HostUnit:GetIntelToggle()
    return self.toggles.Intel or false
end

function HostUnit:SetProductionToggle(value)
    self.toggles.Production = value
end

---@return boolean
function HostUnit:GetProductionToggle()
    return self.toggles.Production or false
end

---@param toggleName string The name of the toggle to check.
---@return boolean True if the specified toggle exists
function HostUnit:ToggleExists(toggleName)
    return self.toggles and self.toggles[toggleName] ~= nil
end

function HostUnit:CanBeAssignedToOrder(order)
    -- most of the validation for orders comes from the orders asking the behaviors if it is ok
    if self.dead then
        return false
    end

    return true
end

--- Sets the unit's navigation layer. Units default to the Land layer while under
--- construction and move onto their real layer (e.g. Air for aircraft) once
--- complete.
---@param layer integer A Layers.NavigationLayer value.
function HostUnit:SetNavigationLayer(layer)
    if self.tp.movement == nil then return end

    if layer == nil or layer < 0 then
        Warn(string.format("WARNING: HostUnit:SetNavigationLayer: unit %d (%s) given invalid navigation layer %s; ignoring.",
            self.id, tostring(self.tpId), tostring(layer)))
        return
    end

    Engine.SetMovementNavigationLayer(self.id, layer)
end

---@protected Sets the unit's weapon-targeting layer
---@param layer integer A Layers.TargetingLayer mask.
function HostUnit:SetTargetingLayer(layer)
    if self.targetingLayer == layer then return end

    self.targetingLayer = layer

    if self.weapons then
        for _, weapon in pairs(self.weapons) do
            weapon:RefreshEnabled()
        end
    end
end

-- TODO: Need to remove
-- Called once after __init set up the basic stuff
function HostUnit:OnStartBeingBuilt()
    --Log(string.format("Unit id: %d, tpId: %s, is started to be built by unit id: %d, tpId: %s", self.id, self.tpId, (builder and builder.id) or -1, (builder and builder.tpId) or "UNKNOWN"))
    self.progress = self.progress or 0

    Armies[self.army.id]:SetUnitStat("beingBuilt", self.tpId, 1)

    --self.buildThread = self:NewThread(self.BuildProcess)
end

-- TODO: need to properly move...
--- Called once when this unit in completed.
-- Enable all things this unit should have like intel, shields.
function HostUnit:OnStopBeingBuilt()
    --Log(string.format("Unit id: %d, tpId: %s, is stop being built.", self.id, self.tpId))

    self:SetRegenEnabled(true)

    self:CheckShieldState(true)
    self:CheckRadarState()
    self:CheckSonarState()

    local resourcesToStart = { "generation", "harvest" }
    for _, resourceName in pairs(resourcesToStart) do
        local resource = self.resourceEntities[resourceName]
        if resource then
            resource:SetEnabled(true)
        end
    end

    local productionResource = self.resourceEntities["production"]
    if productionResource then
        -- if the unit has toggles, respect the production toggle else enable it by default
        local productionToggleExists = self:ToggleExists("Production")
        if productionToggleExists then
            productionResource:SetEnabled(self:GetProductionToggle())
        else
            productionResource:SetEnabled(true)
        end
    end

    self:UpdateUIValues()

    if self.weapons then
        for _, wep in pairs(self.weapons) do
            if not wep:IsEnabled() then
                wep:SetEnabled(true)
            end
        end
    end

    if self:RotatorsEnabledOnConstruction() then
        self:SetRotatorsEnabled(true)
    end

    if self.isAnimated then
        self:SetAnimatorEnabled(true)
    end

    self.buildThread = nil

    -- If finished flag is false, the unit was built and not spawned already built
    if not self.bypassedBuildProcess then
        Armies[self.army.id]:SetUnitStat("beingBuilt", self.tpId, -1)
        self:SetFinished()
    end
    self.bypassedBuildProcess = nil

    Armies[self.army.id]:SetUnitStat("active", self.tpId, 1)
end



function HostUnit:SetFinished()
    self.progress = self.tp.economy.buildTime
end

function HostUnit:IsCompleted()
    return (self.tp.economy.buildTime - self.progress) <= 0.001
end

function HostUnit:GetFractionComplete()
    if self:IsCompleted() then
        return 1.0
    else
        return self.progress / self.tp.economy.buildTime
    end
end

function HostUnit:SetFractionComplete(fraction)
    if self.progress and self:IsCompleted() then
        return
    end

    fraction = math.min(math.max(fraction, 0.0), 1.0)
    self.progress = self.tp.economy.buildTime * fraction
    UnitCommands.SetUnitProgress.Send(self.id, self.progress)
end

function HostUnit:GetUpgradeTpId()
    return self.construction and self.construction.upgradesTo
end

function HostUnit:GetEconomy()
    local eco = Economies[self.army.id]
    -- fallback if army economy not found
    if not eco then
        local lowestArmyId
        for armyId in pairs(Economies) do
            if not lowestArmyId or armyId < lowestArmyId then
                lowestArmyId = armyId
            end
        end
        eco = Economies[lowestArmyId]
    end
    return eco
end

function HostUnit:CreateResourceEntities()
    local tpEco = self.tp.economy

    if tpEco.production and (not tpEco.maintenanceConsumption or tpEco.narutalProducer) then
        self.resourceEntities["generation"] = ResourceEntity(
            self.army.id,
            self.id,
            "generation",
            tpEco.production,
            nil,
            false
        )
    elseif tpEco.production and tpEco.maintenanceConsumption then
        self.resourceEntities["production"] = ResourceEntity(
            self.army.id,
            self.id,
            "production",
            tpEco.production,
            tpEco.maintenanceConsumption,
            false
        )
    elseif tpEco.maintenanceConsumption then
        self.resourceEntities["consumption"] = ResourceEntity(
            self.army.id,
            self.id,
            "consumption",
            nil,
            tpEco.maintenanceConsumption,
            false
        )
    end
    if self:HasTags(Tags.HARVEST) then
        self.resourceEntities["harvest"] = ResourceEntity(
            self.army.id,
            self.id,
            "harvest",
            nil,
            nil,
            false
        )
    end

    self:UpdateUIValues()
end

function HostUnit:SetupConstruction()
    self.constructionCollider = self:GetBoneId("ConstructionCollider")

    if self.tp.construction then
        self.construction = table.deepCopy(self.tp.construction)
        
        if self.tp.construction.range then
            local constructionDetectorColliderID = self:GetBoneId("ConstructorCollider")
            ---@type ConstructionDetector
            self.constructionDetectorCollider = ConstructionDetector.CreateConstructionDetector(constructionDetectorColliderID, self)
        end

        if self.tp.construction.platformBoneName then
            self.platformBone = self:GetBoneId(self.tp.construction.platformBoneName)
        end
    end
end

function HostUnit:IsFactory()
    return self:HasTags(Tags.FACTORY)
end

function HostUnit:IsEngineeringStation()
    return self:HasTags(Tags.ENGINEERING_STATION)
end

function HostUnit:SetBuildPower(new)
    self.construction.buildPower = new

    UnitCommands.SetBuildPower.Send(self.id, new)
end

--* returns true if the unit has construction capabilities
function HostUnit:CanConstruct()
    return self:HasTags(Tags.CONSTRUCTION)
end

--* this intentionally excludes things like extractors which can upgrade themselves but cant assist other projects
function HostUnit:CanConstructOthers()
    if self.tp.construction and self.construction.range then return true end
    return false
end
-- Changes unit's build power back to it's template's value.
function HostUnit:RevertBuildPower()
    self:SetBuildPower(self.tp.construction.buildPower)
end

function HostUnit:UpdateUIValues()

    if self.dead then
        return
    end

    -- TODO: This table shouldn't be hardcoded.
    local result = {
        alloys = 0,
        energy = 0,
    }

    for name, entity in pairs(self.resourceEntities) do
        if name ~= "construction" and entity.enabled then
            for resName, amount in pairs(entity.income) do
                result[resName] = result[resName] + amount
            end

            for resName, amount in pairs(entity.outcome) do
                result[resName] = result[resName] - amount
            end
        end
    end

    -- Convert to res/second
    for resName, amout in pairs(result) do
        result[resName] = amout * 10
    end

    -- Drain of building something else
    if self.unitBeingBuilt then
        local targetTpEco = self.unitBeingBuilt.tp.economy
        for resName, amount in pairs(targetTpEco.cost) do
            result[resName] = result[resName] - (amount / (targetTpEco.buildTime / self.construction.buildPower))
        end
    end

    EconomyCommands.SetEconomyValues.Send(self.id, result)
end

--- When the unit dies, turn into wreckage
---@param overkillRatio number
---@param destroyType DestroyType?
function HostUnit:Destroy(overkillRatio, destroyType)
    if not self.canBeKilled then return end

    if self.dead then
        error(string.format("HostUnit:Destroy: Unit id: %d, tpId: %s is already dead.", self.id.index, self.tpId))
    end

    destroyType = destroyType or DestroyType.Unspecified
    
    -- Dissolve damage type creates full overkill and never spawns wrecks.
    if destroyType == DestroyType.Dissolve then
        overkillRatio = 1
    end

    -- Preserve the death-effect gate when an aircraft defers its scorch to contact.
    self.scoAircraftCrashScorch = not self:IsPlacementGhost()
        and (destroyType == DestroyType.Kinetic or destroyType == DestroyType.Unspecified)

    self:OnDestroy(destroyType)

    -- Custom command to client which is UnitDestroy command.
    -- This spawns the destroy effects for now
    UnitCommands.DestroyUnit.Send(self.id, destroyType)

    -- SCOM naval death handoff 1.3.0
    local navalTerrainHeight
    if self:HasTags(Tags.NAVAL) and not self:HasTags(Tags.STRUCTURE)
        and self.scoSeaParitySalemDeathWater ~= false
    then
        local waterResult, hasWater = Engine.HasWater()
        if waterResult == EngineErrorCode.Success and hasWater then
            local levelResult, waterLevel = Engine.GetWaterLevel()
            local terrainResult, terrainHeight = Engine.SampleTerrainHeight(self:GetPosition())
            if levelResult == EngineErrorCode.Success
                and terrainResult == EngineErrorCode.Success
                and terrainHeight < waterLevel
            then
                navalTerrainHeight = terrainHeight
            end
        end
    end
    if navalTerrainHeight ~= nil then
        self.scoNavalWreckTerrainHeight = navalTerrainHeight
        local handedOff = false
        local function startNavalWreck(unit, deathOverkill)
            if handedOff or unit.deleted then return end
            handedOff = true
            return Import("host/props/wreckCrash.lua").StartWreckCrash(
                unit, deathOverkill or overkillRatio or 0, true)
        end
        -- Each death owner keeps its clip duration and chosen playback rate.
        -- Both native and specialized wreck creation copy only its final pose;
        -- the wreck then owns the existing bounded descent and reclaim phase.
        self.OnSpawnWreckage = startNavalWreck
        self.CreateWreckage = startNavalWreck
    end
    self:NewThread(self.DeathThread, overkillRatio)
end

--- Called when this unit is destroyed. Cleans up construction, reclaim, capture,
--- resource entities and notifies associated systems.
---@param destroyType DestroyType
function HostUnit:OnDestroy(destroyType)
    self.army.economy.EnergyDownTrigger:RemoveHandler(self.energyDownCallback)
    self.army.economy.EnergyUpTrigger:RemoveHandler(self.energyUpCallback)
    
    if self:IsCompleted() then
        Armies[self.army.id]:SetUnitStat("active", self.tpId, -1)
        Armies[self.army.id]:SetUnitStat("lost", self.tpId, 1)
    else
        Armies[self.army.id]:SetUnitStat("beingBuilt", self.tpId, -1)
    end

    -- mark unit as dead
    self.dead = true
    
    self:DoCallbacks("OnDestroyed")

    -- Stop any active processes. This will also stop any thing subscribed to these processes.
    if self:IsBuildProcessEnabled() then
        self:EndBuildProcess()
    end

    if self:IsReclaimProcessEnabled() then
        self:EndReclaimProcess()
    end

    if self:IsCaptureProcessEnabled() then
        self:EndCaptureProcess()
    end

    if self:IsRepairProcessEnabled() then
        self:EndRepairProcess()
    end

    -- Stop any active processes. This will also stop any thing subscribed to these processes.
    if self:IsBuildRoutineEnabled() then
        self:EndBuildRoutine(self.unitBeingBuilt)
    end

    if self:IsReclaimRoutineEnabled() then
        self:EndReclaimRoutine(self.unitBeingReclaimed)
    end

    if self:IsCaptureRoutineEnabled() then
        self:EndCaptureRoutine(self.unitBeingCaptured)
    end

    if self:IsRepairRoutineEnabled() then
        self:EndRepairRoutine(self.unitBeingRepaired)
    end

    -- Would be something like this I guess...
    if self:IsUpgrading() then
        self:EndUpgrade()
    end


    -- remove resource entities and storage contributions
    local eco = self:GetEconomy()
    eco:RemoveUnitsResourceEntities(self)
    if self.tp.economy.storage then
        eco:RemoveStorage(self.id)
    end

    -- delete active shields
    if self.shields then
        for _, shield in pairs(self.shields) do
            shield:Delete()
        end
    end

    -- deactivate beam weapons
    for _, weapon in ipairs(self.weapons) do
        weapon:Delete()
    end

    self.visionLayer:Delete()
    self.radarLayer:Delete()
    self.sonarLayer:Delete()
    self.targetCollider:Delete()

    -- Only units with construction.range can detect constructable structures
    if self.constructionDetectorCollider then
        self.constructionDetectorCollider:Delete()
    end
    
    if destroyType ~= DestroyType.Delete and not self:IsPlacementGhost() then
        self:CreateDeathExplosions()
    end

    HostOrderManager.HandleUnitDestroyed(self)
end

function HostUnit:CreateDeathExplosions()
    if not self.scoCommanderTreeImpactApplied and self:HasTags(Tags.COMMAND) then
        local radius = 0
        for _, weapon in ipairs(self.tp.weapons or {}) do
            if weapon.category == "DeathExplosion" and weapon.damage and weapon.damageRadius then
                radius = math.max(radius, weapon.damageRadius)
            end
        end
        if radius > 0 then
            self.scoCommanderTreeImpactApplied = true
            Import("common/loading/unitTemplateLoader.lua").SCOMTreeKnockdown.Impact(self:GetPosition(), radius)
        end
    end
    for _, weapon in ipairs(self.tp.weapons or {}) do
        if weapon.category and weapon.category == "DeathExplosion" and weapon.damageRadius and weapon.damage then
            CollisionUpdate.ProcessAreaDamage(self:GetPosition(), weapon.damageRadius, weapon.damage, self.army, weapon.damageFriendly or false, self)
        end
    end
end

function HostUnit:CopyOrders(otherUnit)
    HostOrderManager.CopyOrders(self, otherUnit)
end

function HostUnit:SetUpWreck()
    self.spawnsWreck = true

    if self.tp.additions and self.tp.additions.displayWreckOnDeath == false then
        self.spawnsWreck = false
    end
end

function HostUnit:DeathThread(overkillRatio)
    self:OnSpawnWreckage(overkillRatio or 0)

    self:Delete()
end

--- Leaves behind the wreckage of this unit.
---@param overkillRatio number
function HostUnit:OnSpawnWreckage(overkillRatio)
    if self:GetFractionComplete() >= 0.5 and self.spawnsWreck then
        self:CreateWreckage(overkillRatio)
    end
end

---@param overkillRatio number
function HostUnit:CreateWreckage(overkillRatio)
    if overkillRatio < 1 then
        local wreckage = CreateWreckageFromUnit(self)

        -- TODO:
        -- Set HP based on overkill
        --local delta = wreckage.maxHP * overkillRatio
        --wreckage:AdjustHealth(-delta)
    end
end

-- When the unit should be completely removed.
function HostUnit:Delete()

    if not self.dead then
        self:OnDestroy(DestroyType.Delete)
    end

    if self.deleted then
        error(string.format("HostUnit:Delete: Unit id: %d, tpId: %s is already deleted.", self.id.index, self.tpId))
    end

    self:DoCallbacks("OnDeleted")

    -- Custom command to delete unit here.
    UnitCommands.DeleteUnit.Send(self.id)
    Engine.DeletePrefabInstance(self.id, false)

    RemoveUnit(self)

    HostEntity.Delete(self)
end

---Checks if unit has specified tags.
---@param tags any Tags to check
---@return boolean
function HostUnit:HasTags(tags)
    return tags[self.tpId]
end

function HostUnit:CanBeBuiltBy(buildingUnit)
    return buildQueueUtils.CanBuild(buildingUnit, self.tpId)
end

---@public If the unit is a placement ghost. This is true if the unit has not been built.                   
---@return boolean isPlacementGhost
function HostUnit:IsPlacementGhost()
    return self.progress <= 0
end

-- Called when placement ghost is promoted from placement ghost -> unit.
function HostUnit:PromoteToUnit()
    self.hasBeenPromotedFromPlacementGhost = true 
    
    -- Once we go from placement ghost -> real unit we can be shot and are targetingable.
    Engine.SetVolumeColliderEnabled(self.id, true)
    self:SetTargetable(true)

    -- We can activate intel detection.
    self:SetIntelEnabled(true)
end

function HostUnit:SetUnitStateFromProgress()
    if not self.hasBeenPromotedFromPlacementGhost and self.progress > 0 then
        self:PromoteToUnit()
    end
end

---@protected
---@param damage number
function HostUnit:OnDamagedAlert(damage)
    local currentTime = GetGameTimeSeconds()
    local timeSinceLastDamage = currentTime - self.lastDamageAlertTime

    if timeSinceLastDamage >= DamagedAlertMaxNoDamageTakenInSeconds then
        local owner = Lobby.ArmyToPlayer[self.army.id]
        if owner then
            SessionCommands.PlayUnitDamagedAlert.SendTo(
                owner.clientID,
                self.tp.audio.onDamagedAlert.name
            )
        end
    end

    self.lastDamageAlertTime = currentTime
end

---------
-- Damage
---------

---@param amount number
---@param destroyType DestroyType?
function HostUnit:TakeDamage(amount, destroyType)
    if not self.canTakeDamage then
        return
    elseif self.dead then
        return
    end

    local finalDamage = self:ProcessDamage(amount)
    self:DoCallbacks("OnDamaged", finalDamage)

    local currentHP = self:GetHealth()
    local newHP = currentHP - finalDamage

    if newHP > 0 then
        self:SetHealth(newHP)
    else
        local maxHP = self:GetMaxHealth()
        local overkillRatio = -newHP / maxHP

        self:SetHealth(0)

        self:Destroy(overkillRatio, destroyType)
    end
end

function HostUnit:ProcessDamage(damage)
    --Do stuff to the damage number
    return damage
end

function HostUnit:SetCanTakeDamage(bool)
    self.canTakeDamage = bool

    if self.shields then
        for _, shield in pairs(self.shields) do
            shield:SetCanTakeDamage(bool)
        end
    end
end

function HostUnit:SetCanBeKilled(bool)
    self.canBeKilled = bool
end

--------------------
-- Water sensors
--------------------

---@public Registers a weapon's water sensor so events on it route back to that weapon.
---@param sensorID GlobalID
---@param weapon HostWeapon
function HostUnit:RegisterWeaponWaterSensor(sensorID, weapon)
    if not self.weaponWaterSensors then
        ---@type table<integer, HostWeapon>
        self.weaponWaterSensors = {}
    end

    self.weaponWaterSensors[sensorID.index] = weapon
end

---@public Routes a water sensor enter/exit to whichever part of the unit owns that sensor.
---@param sensorID GlobalID The collider that changed state.
---@param isUnderWater boolean True when the sensor is inside the water volume.
function HostUnit:OnWaterSensorChanged(sensorID, isUnderWater)
    if self.hullWaterSensorIndex == sensorID.index then
        self:OnHullCrossedWaterline(isUnderWater)
        return
    end

    local weapon = self.weaponWaterSensors and self.weaponWaterSensors[sensorID.index]
    if weapon then
        weapon:OnCrossedWaterline(isUnderWater)
    end
end

----------
-- Weapons
----------
function HostUnit:SetUpWeapons()
    if not self.tp.weapons then
        return
    end

    local wepCount = self:GetWeaponCount()
    --Log("SetUpWeapons: Num weapons: " .. wepCount)

    for i = 1, wepCount do
        local wepTp = self.tp.weapons[i]
        if not wepTp then
            Error(string.format("SetUpWeapons: Unit id: %d, tpId: %s, Weapon num: %d was not found in the template.", self.id.index, self.tpId, i))
        end

        local aimControllerIds = { }
        local boneNameToAimControllerGlobalID = { }

        if wepTp.aimControllers then
            for _, aimController in ipairs(wepTp.aimControllers) do
                local result, bone = Engine.GetGlobalBone(self.id, aimController.aimBone)

                if result == EngineErrorCode.Success then
                    table.insert(aimControllerIds, bone)
                    boneNameToAimControllerGlobalID[aimController.aimBone] = bone
                else
                    Warn("AimController bone in weapon " .. i .. " in template " .. self.tpId .. " has errors reported by the engine. Ignoring.")
                end
            end
        end

        local muzzleGroups = { }
        if wepTp.muzzleGroups then
            for _, muzzleGroup in ipairs(wepTp.muzzleGroups) do
                local muzzleGroupMuzzles = { }
                for _, muzzle in ipairs(muzzleGroup.muzzles) do

                    local muzzleBoneId = self:GetBoneId(muzzle)

                    if muzzleBoneId then
                        local aimControllerId
                        if wepTp.muzzles and wepTp.muzzles[muzzle] then
                            aimControllerId = boneNameToAimControllerGlobalID[wepTp.muzzles[muzzle].aimController]
                        else
                            aimControllerId = aimControllerIds[#aimControllerIds]
                        end

                        table.insert(muzzleGroupMuzzles, { id = muzzleBoneId, boneName = muzzle, aimControllerId = aimControllerId })
                    else
                        Warn("Muzzle bone: "..muzzle.." in template " .. self.tpId .. " could not be found: Ignoring.")
                    end
                end
                table.insert(muzzleGroups, muzzleGroupMuzzles)
            end
        end

        local projectileTemplateName = wepTp.projectileTemplate or nil
        local projectileTemplate = __Templates.Projectiles[projectileTemplateName]

        local wep = Weapon(aimControllerIds, muzzleGroups, self, wepTp, projectileTemplate)
        table.insert(self.weapons, wep)

        if not self:IsCompleted() then
            wep:SetEnabled(false)
        end

        --Log("SetUpWeapons: Unit id: " .. self.id .. " tpId: " .. self.tpId .. " Weapon num: " .. i .. " created.")
    end
end

function HostUnit:SetUpAttackRange()
    self.attackRange = 0
    for index, weapon in pairs(self.weapons) do
        -- note some units have no range like commander death explosion
        if not weapon.isDeathExplosion then
            self.attackRange = math.max(self.attackRange, weapon.tp.rangeMax or 0)
        end
    end
end

function HostUnit:SetUpCanAttack()
    self.canAttack = false
    for index, weapon in pairs(self.weapons) do
        if not weapon.isDeathExplosion then
            self.canAttack = true
            return
        end
    end
end

---Returns number of weapons this unit has
---@return integer self.weaponCount Number of weapons
function HostUnit:GetWeaponCount()
    if not self.weaponCount then
        self.weaponCount = self.tp.weapons and #self.tp.weapons or 0
    end

    return self.weaponCount
end

function HostUnit:CanAttack()
    return self.canAttack
end

function HostUnit:GetWeapon(i)
    local turret = self.weapons[i]
    if not turret then
        Error(string.format("GetWeapon: Unit id: %d, tpId: %s doesn't have turret number: %d. Weapon cound is: %d", self.id.index, self.tpId, i, self:GetWeaponCount()))
    end

    return turret
end

function HostUnit:GetMainWeaponTarget()
    -- todo: this needs a concept of the "main" weapon. right now its using any weapon
    for index, weapon in ipairs(self.weapons) do
        local target = weapon:GetAimTarget()
        if target ~= nil then
            return target
        end
    end
    return nil
end

---Set the preferred target unit for all weapons. The preferred target will be prioritized over all other targets.
---@param targetUnit? HostUnit The unit to prioritize. Set to nil to clear all priorities.
function HostUnit:SetWeaponPreferredTarget(targetUnit)
    for _, weapon in ipairs(self.weapons) do
        weapon:SetPreferredTarget(targetUnit)
    end
end

---@public If this unit can be targeted by any weapons, no matter the team or army.
---@param enabled boolean If the unit 
function HostUnit:SetTargetable(enabled)
    self.isTargetable = enabled
    self.targetCollider:SetEnabled(enabled)
end

----------
-- Shields
----------
function HostUnit:SetUpShields()
    if not self.tp.defence.shields then
        return
    end

    self.shields = {}

    local shieldCount = self:GetShieldCount()
    --Log("SetUpShields: Num Shields: " .. shieldCount)

    for i = 1, shieldCount do
        local shieldTp = self.tp.defence.shields[i]
        local shieldId = self:GetShieldId(i)
        if not shieldTp then
            Error(string.format("SetUpShields: Unit id: %d, tpId: %s, Shield num: %d was not found in the template.", self.id.index, self.tpId, i))
        elseif not shieldId then
            Error(string.format("SetUpShields: Unit id: %d, tpId: %s, Shield num: %d has no global Id.", self.id.index, self.tpId, i))
        end

        local shield = CreateShield(self.army.id, shieldTp, self, shieldId)
        table.insert(self.shields, shield)

        --Log(string.format("SetUpShields: Unit id: %d, tpId: %s, Shield num: %d created.", self.id, self.tpId, i))
    end
end

---Returns number of shields this unit has
---@return integer self.shieldCount of shields
function HostUnit:GetShieldCount()
    if not self.shieldCount then
        self.shieldCount = #self.tp.defence.shields
    end

    return self.shieldCount
end

---comment
---@param i integer Nth shield to get. Starting at index 1
---@return unknown
function HostUnit:GetShield(i)
    local shield = self.shields[i]
    if not shield then
        Error(string.format("GetShield: Unit id: %d, tpId: %s doesn't have shield number: %d. Shield count is: %d", self.id.index, self.tpId, i, self:GetShieldCount()))
    end

    return shield
end

---Returns Globad ID of the Nth shield or nil
---@param i integer Nth shield to get. Starting at index 1
---@return globalId|nil id Global ID of the shield
function HostUnit:GetShieldId(i)
    local bone = {}
    local shieldTp = self.tp.defence.shields[i]
    local shieldEntityName = shieldTp.entityName
        or shieldTp.boneName..'ShieldEntity'
    local result = Engine.GetGlobalBone(self.id, shieldEntityName, bone)
    if result ~= EngineErrorCode.Success then 
        Warn("Global Bone for shield " .. i .. " could not be found in " .. self.tpId .. " globalID " .. self.tp)
    end
    return bone
end

function HostUnit:CheckShieldState(skipRecharge)
    if not self.shields then return end
    -- unit is in charge of powerstall and toggle 
    -- shield is in charge of recharge delays

    local isTryingToBeUp = self:IsCompleted() and self:GetShieldToggle()
    
    if self.resourceEntities.consumption then
        self.resourceEntities.consumption:SetEnabled(isTryingToBeUp)
    end

    local isUpOrRecharging = isTryingToBeUp and not self.army.economy.isEnergyDown
    for _, shield in pairs(self.shields) do
        shield:SetEnableable(isUpOrRecharging, skipRecharge)
    end

    self:SetRotatorsEnabled(isUpOrRecharging)
end

---Sets a custom name for a entity. This name is rendered below the entity.
---@param name string Text to display.
---@param row? 1|2 Only 2 rows are supported
function HostUnit:DrawCustomName(name, row)
    row = row or 1
    if not self.debugName then
        self.debugName = {}
    end
    self.debugName[row] = name
    --Log("Setting custom name: " .. name)

    Engine.DrawCustomName(self.id, name, row)
end

---Returns unit's current name
---@param row? 1|2 Only 2 rows are supported
---@return string name Displayed name
function HostUnit:GetCustomName(row)
    row = row or 1
    if not self.debugName then
        return ""
    end

    return self.debugName[row] or ""
end

---Enables or disables the unit's navmap modifiers.
---@param enabled boolean
function HostUnit:SetNavmapModifiersEnabled(enabled)
    local layerNames = self.tp.general.navmapModifierLayers
    if not layerNames then
        return
    end

    if not self.navmapModifierIDs then
        self.navmapModifierIDs = NavmapModifiers.GetNavmapModifierIDs(self.id, layerNames)
    end

    NavmapModifiers.SetNavmapModifiersEnabled(self.navmapModifierIDs, enabled)
end

---Returns global ID of the bone
---@param name string Bone name
---@return globalId|nil id Global ID of the bone
function HostUnit:GetBoneId(name)
    local boneId = {}
    Engine.GetGlobalBone(self.id, name, boneId)
    if Engine.IsValidGlobalID(boneId) then
        return boneId
    end
    return
end

function HostUnit:GetDebugStr()
    return string.format("HostUnit: %s - %s, globalId: %d. ", self.tpId, self.name, self.id.index)
end

--------------
-- Production
--------------
function HostUnit:CanBeSlaveFactory()
    return false
end

function HostUnit:CanBeMasterFactory()
    return false
end

function HostUnit:SetMasterFactory(assistedUnit)
    self.isSlaveFactory = true
    self.masterFactory = assistedUnit
    self:SetToggle("RepeatBuild", false)
end

function HostUnit:ClearMasterFactory()
    self.isSlaveFactory = false
    self.masterFactory = nil
end

---@private Setup animations.
function HostUnit:SetupAnimations()
    if self.tp.visuals.animations then
        self.isAnimated = true
        self.isWalking = true
    end
end

---@public Enable or disable this unit's skeletal animation.
---@param enabled boolean
function HostUnit:SetAnimatorEnabled(enabled)
    Engine.SetAnimatorEnabled(self.id, enabled)
end

---@private Collect the bone global IDs of this unit's rotators.
function HostUnit:SetupRotators()
    self.rotatorIds = {}
    if self.tp.additions and self.tp.additions.rotators then
        for _, rotator in ipairs(self.tp.additions.rotators) do
            local boneId = self:GetBoneId(rotator.boneName)
            if boneId then
                table.insert(self.rotatorIds, boneId)
            end
        end
    end
end

---@public Enable or disable all of this unit's rotators.
---@param enabled boolean
function HostUnit:SetRotatorsEnabled(enabled)
    for _, rotatorId in ipairs(self.rotatorIds) do
        Engine.SetRotatorEnabled(rotatorId, enabled)
    end
end

---@protected Whether rotators should turn on when construction finishes.
---@return boolean
function HostUnit:RotatorsEnabledOnConstruction()
    return self.shields == nil
end

---@public Update walk/run animations.
function HostUnit:UpdateAnimations()
    -- Right now we assume the unit has at least a walk animation if there are any animations 
    if self.isAnimated then
        local _, movementSpeed = Engine.GetMovementCurrentSpeed(self.id)

        if not self.isWalking and self.tp.visuals.animations.run then
            if movementSpeed < (self.tp.visuals.animations.run.startSpeed or 0) then
                -- Imported walkers use the low-speed clip as idle; settle promptly after a stop.
                local idleBlendSeconds = self.tp.hasTags and self.tp.hasTags.SCFA_ALLUNITS and 0.2 or 1
                Engine.PlayAnimation(self.id, self.tp.visuals.animations.walk.id, idleBlendSeconds);
                self.isWalking = true
                --Engine.Error("Walking: MovementSpeed: "..tostring(movementSpeed))
            end
        end

        if self.isWalking and self.tp.visuals.animations.run then 
            if movementSpeed >= (self.tp.visuals.animations.run.startSpeed or 0) then
                Engine.PlayAnimation(self.id, self.tp.visuals.animations.run.id, 0.3);
                self.isWalking = false
                --Engine.Error("Running: MovementSpeed: "..tostring(movementSpeed))
            end
        end
    end
end

---Returns whether the unit flies a Circle pattern when holding at a point, so it never stands still to align.
---@return boolean
function HostUnit:CirclesWhenHolding()
    return false
end

local zeroAlignDirection = EngineClasses.float2(0, 0)

---Returns the ID of the movement pattern the unit flies in a situation, from its own patternBySituation or its template's.
---@param situation '"move"'|'"hold"'|'"attack"'|'"assist"'
---@return integer patternID The pattern ID, or 0 (None) when the unit has no pattern for the situation
function HostUnit:GetPatternID(situation)
    local movement = self.tp.movement
    if not movement then return 0 end

    local patternBySituation = self.patternBySituation or movement.patternBySituation
    local pattern = patternBySituation and patternBySituation[situation]
    local patternIDs = movement.patternIDs
    return pattern and patternIDs and patternIDs[pattern] or 0
end

---Returns the mode of a movement pattern.
---@param patternID integer
---@return '"None"'|'"Orbit"'|'"Circle"'|'"Strafe"'
function HostUnit:GetPatternMode(patternID)
    return MovementPatterns.GetMode(patternID)
end

---Sets the patterns the unit flies: its "move" pattern while travelling and its goalSituation pattern once engaged at
---the goal. Does nothing when both are already set.
---@param goalSituation '"hold"'|'"attack"'|'"assist"'
function HostUnit:SetMovementPatterns(goalSituation)
    local moveID = self:GetPatternID("move")
    local goalID = self:GetPatternID(goalSituation)

    if (self.movePatternID or 0) == moveID and (self.goalPatternID or 0) == goalID then
        return
    end

    if Engine.SetMovementPatterns(self.id, moveID, goalID) == EngineErrorCode.Success then
        self.movePatternID = moveID
        self.goalPatternID = goalID
    end
end

---Stops the unit where it is and has it fly its hold pattern there, without aligning.
function HostUnit:Hold()
    self:SetMovementPatterns("hold")
    Engine.MovementStop(self.id, zeroAlignDirection)
end

--# move behaviour ==================
--* not valid if cant move
--* unit moves to target and stops, removes the order
--* brakeOnApproach false lets the unit fly through the point at full speed (an
--* intermediate waypoint); defaults to braking
---@param requestedPosition float2
---@param goalRadius number
---@param alignDirection float2? Direction to face on arrival, or nil to not align
---@param brakeOnApproach boolean?
function HostUnit:MoveIntoRangeBehaviorStart(requestedPosition, goalRadius, alignDirection, brakeOnApproach)
    if not self:MoveIntoRangeBehaviorIsValidFor(requestedPosition, goalRadius) then return end

    if self.alignBehaviorIsActive then
        self:AlignBehaviorStop()
    end

    if self:AlignBehaviorIsValidFor() and math2D.isValidDirection(alignDirection) then
        alignDirection = math2D.normalize(alignDirection)
    else
        alignDirection = nil
    end

    if math3D.distanceToFloat2(self:GetPosition(), requestedPosition) < goalRadius and self:GetIsAlignedToDirection(alignDirection) then
        return
    end
    self.moveIntoRangeBehaviorIsActive = true

    local braking = brakeOnApproach ~= false

    self.moveIntoRangeAlignIssued = alignDirection ~= nil
    self.moveIntoRangeAwaitingAlign = self.moveIntoRangeAlignIssued and braking

    self:SetMovementPatterns("hold")
    if Engine.MovementMove(self.id, requestedPosition, alignDirection or zeroAlignDirection, goalRadius) ~= EngineErrorCode.Success then
        self:MoveIntoRangeBehaviorFinish()
        return
    end

    if not braking then
        Engine.SetMovementBrakeOnApproach(self.id, false)
    end
end

---Changes whether the active move brakes into its destination, e.g. when orders are queued behind it
function HostUnit:SetMoveIntoRangeBrakeOnApproach(brakeOnApproach)
    Engine.SetMovementBrakeOnApproach(self.id, brakeOnApproach)
    self.moveIntoRangeAwaitingAlign = self.moveIntoRangeAlignIssued == true and brakeOnApproach
end

function HostUnit:MoveIntoRangeBehaviorIsValidFor(requestedPosition, goalRadius)
    return self:CanMove()
end

---Called when the active move reaches its goal. Finishes the move unless it is still waiting for the unit to align.
---@param reason MovementEventType Arrived or ArrivedBestEffort
function HostUnit:MoveIntoRangeBehaviorEnteredRange(reason)
    if self.moveIntoRangeAwaitingAlign then return end
    self:MoveIntoRangeBehaviorFinish()
end

---Called when the unit finishes aligning. Finishes the active move if it was waiting for that alignment.
function HostUnit:MoveIntoRangeBehaviorAligned()
    if not self.moveIntoRangeBehaviorIsActive or not self.moveIntoRangeAwaitingAlign then return end
    self:MoveIntoRangeBehaviorFinish()
end

-- callback from the engineverse: the unit finished changing altitude and now sits at its target.
function HostUnit:AltitudeReached()
    self:OnAltitudeReached()
end

---Called when the unit reaches its target altitude. Does nothing by default; override it to react, as submarines do.
function HostUnit:OnAltitudeReached()
end

function HostUnit:MoveIntoRangeBehaviorFinish()
    self.moveIntoRangeBehaviorIsActive = false
    self.moveIntoRangeAwaitingAlign = nil
    self.moveIntoRangeAlignIssued = nil
end

function HostUnit:MoveIntoRangeBehaviorStop()
    if self.moveIntoRangeBehaviorIsActive then
        self:MoveIntoRangeBehaviorFinish()
        self:Hold()
    end
end

---Returns the normalized 2D direction from the unit to a position.
---@param targetPosition float2
---@return float2 direction
function HostUnit:GetAlignRotation(targetPosition)
    return math2D.getDirection(math3D.tofloat2(self:GetPosition()), targetPosition)
end

---Returns whether the unit is facing a direction. True when the unit cannot align or the direction is nil or invalid.
---@param targetDirection float2? Normalized direction to check
---@return boolean
function HostUnit:GetIsAlignedToDirection(targetDirection)
    if not self:AlignBehaviorIsValidFor() then return true end
    if not math2D.isValidDirection(targetDirection) then return true end

    local _, forward3D = Engine.GetGlobalEntityForwardDirection(self.id)
    local forward2D = math2D.normalize(math3D.tofloat2(forward3D))
    return math2D.dot(forward2D, targetDirection) >= Constants.MovementAlignmentCosineThreshold
end

---@param waypoints float2[] At least one destination, in traversal order.
---@param range number
---@param align boolean|float2
function HostUnit:PatrolMoveBehaviorStart(waypoints, range, align)
    if #waypoints == 0 or not self:MoveIntoRangeBehaviorIsValidFor(waypoints[1], range) then return end

    if self.patrolMoveBehaviorIsActive then
        self:PatrolMoveBehaviorStop()
    end

    self.patrolMoveBehaviorIsActive = true
    self.patrolMoveBehaviorThread = self:NewThread(self.PatrolMoveBehaviorThread, waypoints, range, align)
end

---Goes to each waypoint using the move behaviors in a patrol loop.
---@param waypoints float2[]
---@param range number
---@param align boolean|float2
function HostUnit:PatrolMoveBehaviorThread(waypoints, range, align)
    WaitUntil(function() return self:IsCompleted() or not self:MoveIntoRangeBehaviorIsValidFor(waypoints[1], range) end)

    local waypointIndex = 1
    while self:MoveIntoRangeBehaviorIsValidFor(waypoints[waypointIndex], range) do
        local brakeOnApproach = false
        self:MoveIntoRangeBehaviorStart(waypoints[waypointIndex], range, align, brakeOnApproach)
        WaitUntil(function() return not self.moveIntoRangeBehaviorIsActive end)
        WaitTicks(1)
        waypointIndex = waypointIndex % #waypoints + 1
    end

    self:PatrolMoveBehaviorStop()
end

---Stops the active patrol and its current movement movement behavior.
function HostUnit:PatrolMoveBehaviorStop()
    if not self.patrolMoveBehaviorIsActive then return end

    self.patrolMoveBehaviorIsActive = false
    if self.patrolMoveBehaviorThread then
        KillThread(self.patrolMoveBehaviorThread)
        self.patrolMoveBehaviorThread = nil
    end
    self:MoveIntoRangeBehaviorStop()
end

--- Whether the unit can stand still. A unit with a speed floor can only hold by circling, so it
-- can never align in place.
function HostUnit:CanHoldStill()
    return (self.tp.movement and self.tp.movement.minSpeed or 0) == 0
end

function HostUnit:AlignBehaviorIsValidFor()
    return self:CanMove()
        and not self:CirclesWhenHolding()
        and self:CanHoldStill()
end

--# align behaviour ==================
function HostUnit:AlignBehaviorStart(targetDirection)
    if not self:AlignBehaviorIsValidFor() then return end
    if not math2D.isValidDirection(targetDirection) then return end

    if self.alignBehaviorIsActive then
        self:AlignBehaviorStop()
    end

    self.alignBehaviorIsActive = true
    self.alignBehaviorThread = self:NewThread(self.AlignBehaviorThread, targetDirection)
end

function HostUnit:AlignBehaviorThread(targetDirection)
    WaitUntil(function() return self:IsCompleted() or not self:AlignBehaviorIsValidFor() end)
    if not self:AlignBehaviorIsValidFor() then
        self:AlignBehaviorStop()
        return
    end

    self:SetMovementPatterns("hold")
    if Engine.MovementStop(self.id, targetDirection) == EngineErrorCode.Success then
        self.alignBehaviorIssued = true
    else
        self:AlignBehaviorFinish()
    end
end

function HostUnit:AlignBehaviorFinish()
    if not self.alignBehaviorIsActive then return end

    if self.alignBehaviorThread then
        KillThread(self.alignBehaviorThread)
    end

    self.alignBehaviorIsActive = false
    self.alignBehaviorIssued = nil
    self.alignBehaviorThread = nil
end

function HostUnit:AlignBehaviorStop()
    if not self.alignBehaviorIsActive then return end

    local issued = self.alignBehaviorIssued
    self:AlignBehaviorFinish()

    if issued then
        self:Hold()
    end
end

function HostUnit:OnMovementAligned()
    if self.alignBehaviorIsActive then
        self:AlignBehaviorFinish()
    end

    self:MoveIntoRangeBehaviorAligned()
end


--# attack behaviour ==================
--* cannot attack own team
--* moves into range, then stops
--* aims with weapons onto target
--* when target moves out of range, moves again
--* when target changes direction, moves to new location
--* if target dies, removes the order

function HostUnit:AttackBehaviorStart(targetUnit, range)
    if not self:AttackBehaviorIsValidFor(targetUnit, range) then return end

    if self.attackBehaviorIsActive then
        self:AttackBehaviorStop()
    end

    self.attackBehaviorIsActive = true;
    self.attackBehaviorTargetUnit = targetUnit
    self.attackBehaviorThread = self:NewThread(self.AttackBehaviorThread)

    self:SetWeaponPreferredTarget(targetUnit)
    self:AttackBehaviorMoveStart(targetUnit, range)
end

function HostUnit:AttackBehaviorMoveStart(targetUnit, range)
    self:FollowBehaviorStart(targetUnit, range)
end

function HostUnit:AttackBehaviorMoveStop()
    self:FollowBehaviorStop()
end

function HostUnit:AttackBehaviorIsValidFor(targetUnit, range)
    if not self:CanAttack() then return false end
    if not targetUnit or targetUnit.dead then return false end
    if not self.army:IsEnemy(targetUnit.army) then return false end
    return targetUnit:IsIntelVisible(self.army)
end

function HostUnit:AttackBehaviorThread()
    while self:AttackBehaviorIsValidFor(self.attackBehaviorTargetUnit) do
        WaitTicks(10)
    end

    self:AttackBehaviorStop()
end

function HostUnit:AttackBehaviorStop()
    if self.attackBehaviorThread then
        KillThread(self.attackBehaviorThread)
    end
    self.attackBehaviorIsActive = false
    self.attackBehaviorTargetUnit = nil
    self.attackBehaviorThread = nil
    self:SetWeaponPreferredTarget(nil)
    self:AttackBehaviorMoveStop()
end



--# attackMove behaviour ==================
--* not valid if cant move (eg structures)
--* IS valid if cant attack (eg engineer, we want non combat units to move with combat units)
--* moves towards the position
--* when in range of a target, stops
--* when no more targets in range, moves again
--* when arrives at position, removes the order
---@param targetPositionFloat2 float2
---@param range number
---@param alignDirection float2? Direction to face on arrival, or nil to not align
---@param brakeOnApproach boolean|nil Whether to brake when approaching the target position
function HostUnit:AttackMoveBehaviorStart(targetPositionFloat2, range, alignDirection, brakeOnApproach)
    if not self:AttackMoveBehaviorIsValidFor(targetPositionFloat2) then return end

    self.attackMoveBehaviorIsActive = true;
    self.attackMoveBehaviorTargetPositionFloat2 = targetPositionFloat2
    self.attackMoveBehaviorRange = range
    self.attackMoveBehaviorAlignDirection = alignDirection
    self.attackMoveBehaviorBrakeOnApproach = brakeOnApproach
    self.attackMoveBehaviorThread = self:NewThread(self.AttackMoveBehaviorThread)
end

function HostUnit:AttackMoveBehaviorSetBrakeOnApproach(brakeOnApproach)
    self.attackMoveBehaviorBrakeOnApproach = brakeOnApproach
    if self.moveIntoRangeBehaviorIsActive then
        self:SetMoveIntoRangeBrakeOnApproach(brakeOnApproach)
    end
end

function HostUnit:AttackMoveBehaviorIsValidFor(targetPositionFloat2)
    return self:CanMove()
end

function HostUnit:AttackMoveBehaviorThread()
    -- hold the thread until the unit is completed or the attack move behavior is no longer valid
    WaitUntil(function() return self:IsCompleted() or not self:AttackMoveBehaviorIsValidFor(self.attackMoveBehaviorTargetPositionFloat2) end)
    if not self:AttackMoveBehaviorIsValidFor(self.attackMoveBehaviorTargetPositionFloat2) then 
        self:AttackMoveBehaviorStop()
        return 
    end

    local range = self.attackMoveBehaviorRange or 2 -- arbitrary

    --# start moving
    self:MoveIntoRangeBehaviorStart(self.attackMoveBehaviorTargetPositionFloat2, range, self.attackMoveBehaviorAlignDirection, self.attackMoveBehaviorBrakeOnApproach)

    while self:AttackMoveBehaviorIsValidFor(self.attackMoveBehaviorTargetPositionFloat2) do

        --# when we arrive, cancel this order
        if not self.moveIntoRangeBehaviorIsActive then
            self:AttackMoveBehaviorStop()
            return
        end

        --# if we can reclaim something, stop driving until we have no targets, then resume driving

        if self:CanConstructOthers() then
            local target = self:FindReclaimTarget()

            if target then
                self:MoveIntoRangeBehaviorStop()

                self:ReclaimBehaviorStart(target)

                repeat
                    WaitTicks(1)
                until not self.reclaimBehaviorIsActive

                self:MoveIntoRangeBehaviorStart(self.attackMoveBehaviorTargetPositionFloat2, range, self.attackMoveBehaviorAlignDirection, self.attackMoveBehaviorBrakeOnApproach)
            end
        end

        --# when our weapons start targeting, stop driving until we have no targets, then resume driving

        if self:GetMainWeaponTarget() ~= nil then
            self:MoveIntoRangeBehaviorStop()

            self:AttackMoveEngageTargets()

            self:MoveIntoRangeBehaviorStart(self.attackMoveBehaviorTargetPositionFloat2, range, self.attackMoveBehaviorAlignDirection, self.attackMoveBehaviorBrakeOnApproach)
        else
            -- we are still driving towards the destination
            WaitTicks(1)
        end
    end

    -- can only get here if order somehow becomes invalid, which doesnt happen yet, but fits the pattern
    self:AttackMoveBehaviorStop()
end

---@protected Engage weapon targets in place during an attack-move, returning once there are no
--- more targets in range.
function HostUnit:AttackMoveEngageTargets()
    while self:GetMainWeaponTarget() ~= nil do
        WaitTicks(1)
    end
end

function HostUnit:FindReclaimTarget()
    local radius = self.tp.construction.range

    local entities = __Entities.Props
    local filtered = FilterEntitiesAroundPosition(self:GetPosition(), radius, entities)

    -- this is just picking the first one for now
    if #filtered then
        return filtered[1]
    else
        return nil
    end
end

function HostUnit:AttackMoveBehaviorStop()
    
    self:ReclaimBehaviorStop()
    self:MoveIntoRangeBehaviorStop()

    if self.attackMoveBehaviorThread then
        KillThread(self.attackMoveBehaviorThread)
    end

    self.attackMoveBehaviorIsActive = false
    self.attackMoveBehaviorTargetPositionFloat2 = nil
    self.attackMoveBehaviorThread = nil
end

---@param waypoints float2[] List of waypoints to patrol through. Needs at least one destination.
---@param range number
---@param align boolean
function HostUnit:PatrolAttackMoveBehaviorStart(waypoints, range, align)
    if #waypoints == 0 or not self:AttackMoveBehaviorIsValidFor(waypoints[1]) then return end

    if self.patrolAttackMoveBehaviorIsActive then
        self:PatrolAttackMoveBehaviorStop()
    end

    self.patrolAttackMoveBehaviorIsActive = true
    self.patrolAttackMoveBehaviorThread = self:NewThread(self.PatrolAttackMoveBehaviorThread, waypoints, range, align)
end

---Goes through the waypoints in a patrol loop using the attack-move behaviors..
---@param waypoints float2[]
---@param range number
---@param align boolean
function HostUnit:PatrolAttackMoveBehaviorThread(waypoints, range, align)
    WaitUntil(function() return self:IsCompleted() or not self:AttackMoveBehaviorIsValidFor(waypoints[1]) end)

    local waypointIndex = 1
    while self:AttackMoveBehaviorIsValidFor(waypoints[waypointIndex]) do
        local brakeOnApproach = false
        self:AttackMoveBehaviorStart(waypoints[waypointIndex], range, align, brakeOnApproach)
        WaitUntil(function() return not self.attackMoveBehaviorIsActive end)
        WaitTicks(1)
        waypointIndex = waypointIndex % #waypoints + 1
    end

    self:PatrolAttackMoveBehaviorStop()
end

---Stops the active patrol and its current attack-move behavior.
function HostUnit:PatrolAttackMoveBehaviorStop()
    if not self.patrolAttackMoveBehaviorIsActive then return end

    self.patrolAttackMoveBehaviorIsActive = false
    if self.patrolAttackMoveBehaviorThread then
        KillThread(self.patrolAttackMoveBehaviorThread)
        self.patrolAttackMoveBehaviorThread = nil
    end
    self:AttackMoveBehaviorStop()
end



--# follow behaviour ==================
--* unlike most behaviors there is no matching order, you can only do this as part of an assist
--* not valid if target is dead
--* not valid if you cant move
--* moves towards the target unit, updating the location periodically
--* when you get into range, unit stops, but order remains
--* when target dies, order is cancelled
function HostUnit:FollowBehaviorStart(targetUnit, range)
    if not self:FollowBehaviorIsValidFor(targetUnit, range) then return end

    self.followBehaviorIsActive = true;
    self.followBehaviorTargetUnit = targetUnit
    self.followBehaviorRange = range
    self.followBehaviorThread = self:NewThread(self.FollowBehaviorThread)
end

function HostUnit:FollowBehaviorIsValidFor(targetUnit, range)
    if not targetUnit or targetUnit.dead then return false end
    if targetUnit == self then return false end
    if not self:CanMove() then return false end
    return not targetUnit.army or not self.army:IsEnemy(targetUnit.army) or targetUnit:IsIntelVisible(self.army)
end

function HostUnit:FollowBehaviorGetTargetPosition()
    return math3D.tofloat2(self.followBehaviorTargetUnit:GetPosition())
end

function HostUnit:FollowBehaviorThread()

    -- hold the thread until the unit is completed or the follow behavior is no longer valid
    WaitUntil(function() return self:IsCompleted() or not self:FollowBehaviorIsValidFor(self.followBehaviorTargetUnit, self.followBehaviorRange) end)

    while self:FollowBehaviorIsValidFor(self.followBehaviorTargetUnit, self.followBehaviorRange) do

        local targetPosition = self:FollowBehaviorGetTargetPosition()
        self:MoveIntoRangeBehaviorStart(targetPosition, self.followBehaviorRange, self:GetAlignRotation(targetPosition))
        WaitTicks(30)
        -- todo: could wait until targetUnit has moved here
    end

    self:FollowBehaviorStop()
end

function HostUnit:FollowBehaviorStop()
    if self.followBehaviorThread then
        KillThread(self.followBehaviorThread)
    end
    self.followBehaviorIsActive = false
    self.followBehaviorTargetUnit = nil
    self.followBehaviorRange = nil
    self.followBehaviorThread = nil
    self:MoveIntoRangeBehaviorStop()
end



--# build behaviour ==================
--* not valid if you cant build others (eg: extractor can upgrade itself but not build others)
--* places ghost
--* unit in range starts building
--* unit out of range moves in range, promotes ghost, starts building
--* unit out of range moves in range, finds ghost already promoted, finishes building
--* unit out of range moves towards, finds building finished, cancels early
--* when the construction is complete or dies, removes the order
function HostUnit:BuildBehaviorStart(actualUnit)
    if not self:BuildBehaviorIsValidFor(actualUnit) then return end

    if self.buildBehaviorIsActive then
        self:BuildBehaviorStop()
    end

    self.buildBehaviorIsActive = true
    self.buildBehaviorActualUnit = actualUnit
    self.buildBehaviorActualUnitPositionFloat2 = math3D.tofloat2(actualUnit:GetPosition())
    self.buildBehaviorThread = self:NewThread(self.BuildBehaviorThread)
end

-- returns true if its not complete
function HostUnit:BuildBehaviorIsValidFor(unitToBuild)
    if not self:CanConstructOthers() then return false end

    if not unitToBuild then return false end

    -- if its a finished structure, stop
    if unitToBuild:IsCompleted() then return false end

    -- if its dead, stop
    if unitToBuild.dead then return false end

    return true
end

function HostUnit:BuildBehaviorThread()
    local target = self.buildBehaviorActualUnit

    -- The builder may itself still be under construction; it cannot build others until complete.
    WaitUntil(function() return self:IsCompleted() or not self:BuildBehaviorIsValidFor(target) end)
    if not self:BuildBehaviorIsValidFor(target) then 
        self:BuildBehaviorStop()
        return 
    end

    -- # while valid: run the build routine, suspending it across pause and attempts to keep the engineer in the range of the target.
    -- assisting engineer can finish it; unpause restarts our own routine. The loop
    -- exits when the target completes or dies -- possibly finished by that assister.
    while self:BuildBehaviorIsValidFor(target) do
        local inRange = self.constructionDetectorCollider:IsOverlappingUnit(target)

        -- only if the unit can move do we care about it moving and facing the target. Else it should just be in range.
        local canMove = self:CanMove()

        if canMove then
            local targetDirection = self:GetAlignRotation(self.buildBehaviorActualUnitPositionFloat2)
            local isAlignedToTarget = self:GetIsAlignedToDirection(targetDirection)
            while self:BuildBehaviorIsValidFor(target) and (not inRange or not isAlignedToTarget) do
                inRange = self.constructionDetectorCollider:IsOverlappingUnit(target)
                targetDirection = self:GetAlignRotation(self.buildBehaviorActualUnitPositionFloat2)
                isAlignedToTarget = self:GetIsAlignedToDirection(targetDirection)

                if inRange then
                    -- when we are in range, we face the target
                    self:AlignBehaviorStart(targetDirection)
                    WaitUntil(function()
                        return not self:BuildBehaviorIsValidFor(target)
                            or not self.alignBehaviorIsActive
                    end)
                    self:AlignBehaviorStop()

                    -- check if we are still in range since while we were trying to face the target, the unit or target could have moved
                    inRange = self.constructionDetectorCollider:IsCollidingWithGlobalID(target.id)
                    isAlignedToTarget = self:GetIsAlignedToDirection(targetDirection)
                else
                    -- # move into range. Pause never blocks movement -- only the build routine is pausable,
                    -- so a paused engineer still walks to its target and waits there.
                    local targetPosition = math3D.tofloat2(target:GetPosition())
                    self:MoveIntoRangeBehaviorStart(targetPosition, 0.1, self:GetAlignRotation(targetPosition))

                    WaitUntil(function()
                        return not self:BuildBehaviorIsValidFor(target)
                            or not self.moveIntoRangeBehaviorIsActive
                            or self.constructionDetectorCollider:IsCollidingWithGlobalID(target.id)
                    end)
                    self:MoveIntoRangeBehaviorStop()

                    inRange = self.constructionDetectorCollider:IsCollidingWithGlobalID(target.id)
                    isAlignedToTarget = self:GetIsAlignedToDirection(targetDirection)
                end
                WaitTicks(1)
            end
        end

        -- Target finished/died en route, or we could not get in range: a mobile builder that gave
        -- up, or a stationary builder given a target outside its construction range.
        if not self:BuildBehaviorIsValidFor(target) or not inRange then
            self:BuildBehaviorStop()
            return
        end

        -- Hold until we may build: promoted from placement ghost or tech allows, and not paused.
        WaitUntil(function()
            if not self:BuildBehaviorIsValidFor(target) then return true end
            local canBuild = target.hasBeenPromotedFromPlacementGhost or target:CanBeBuiltBy(self)
            return canBuild and not self:GetPause()
        end)

        if not self:BuildBehaviorIsValidFor(target) then break end

        self:StartBuildRoutine(target)

        -- Build until paused, or the routine ends (process completes / target dies) or the target goes out of range.
        WaitUntil(function() return self:GetPause() or not self:BuildBehaviorIsValidFor(target) or not self.constructionDetectorCollider:IsOverlappingUnit(target) end)

        -- End our contribution. If the process already ended it (completion/death),
        -- IsBuilding is false and EndBuildRoutine must not run again (Rule R1).
        if self:IsBuilding(target) then
            self:EndBuildRoutine(target)
        end
    end

    self:BuildBehaviorStop()
end

function HostUnit:BuildBehaviorStop()
    -- Idempotent: safe to call from the thread's happy path and from external aborts.
    if not self.buildBehaviorIsActive then return end

    -- This behavior owns the build routine: end it if the process has not already (Rule B2).
    if self:IsBuilding(self.buildBehaviorActualUnit) then
        self:EndBuildRoutine(self.buildBehaviorActualUnit)
    end

    if self.buildBehaviorThread then
        KillThread(self.buildBehaviorThread)
    end
    self.buildBehaviorIsActive = false
    self.buildBehaviorThread = nil
    self.buildBehaviorActualUnit = nil

    self:MoveIntoRangeBehaviorStop()
end




--# assist behaviour ==================
--* not valid if targeting itself
--* not valid if target is dead
--* only valid of unit can move or construct others, with the exception of a factory, because factories can assist too
--* for engineers assisting structures:
--*     if is incomplete or has upgrade queued, moves into range, finishes it according to the "build" logic 
--*     special: cancels the assist order when structure or upgrade is finished, to allow chaining.
--*     special: previous point does not apply to factories
--* for engineers assisting factory/engineer:
--*     engineers move to target
--*     engineers assist building whatever the target builds
--*     engineers can assist engineers that assist engineers, but they will just copy the first engineer (follow/build) and there will be a chain reaction
--* for tanks:
--*     follow the target around the map forever
--* for factories assisting factories:
--*     when fac becomes slave it turns off autobuild automatically
--*     slave removes items from master and builds them
--*     slave factories can still get their own direct queueitems, they build their own stuff first, then look to the master
--*     finished units go to the source-factories rally point
--*     if master has repeatbuild on, when slave starts a queueitem it immediately re-adds it to the end of the master queue
--*     because master doesn't move its own workitems to the end of the queue until its complete, slaves wont take the first master queue item (only if queue item count is 1)
--*     however if there is only 1 queue item and repeat build is on, the slave does take the queue item
--*     bug: edge case: if master orders 1 tankA and 1 tankB then the slaves will only build tankB, not a mix
--*     if master has an upgrade queued, slaves will not use it
--* for factories assisting factories that assist factories:
--*     builds from the nearest factory that has an available queueitem to take
--*     a loop of assisting factories doesn't crash the game

---comment
---@param assistedUnit HostUnit
function HostUnit:AssistBehaviorStart(assistedUnit)
    if not self:AssistBehaviorIsValidFor(assistedUnit) then return end

    if self.assistBehaviorIsActive then
        self:AssistBehaviorStop()
    end

    self.assistBehaviorIsActive = true;
    self.assistBehaviorAssistedUnit = assistedUnit;
    self.assistBehaviorIsSlaveFac = self:CanBeSlaveFactory() and assistedUnit:CanBeMasterFactory()

    if self.assistBehaviorIsSlaveFac then
        self:SetMasterFactory(assistedUnit)
        -- no thread required in this case, the factory already has a production thread
    else
        self.assistBehaviorThread = self:NewThread(self.AssistBehaviorThread)
    end
end

-- overridden by different units to create subtle behavior differences
function HostUnit:AssistBehaviorIsValidFor(assistedUnit)
    -- dont assist nil, dead or self
    if not assistedUnit then return false end
    if assistedUnit.dead then return false end
    if assistedUnit == self then return false end
    if not self.army:IsAlly(assistedUnit.army) then return false end
    if not (self:IsFactory() and assistedUnit:IsFactory()) then
        if not self:CanMove() and not self:CanConstructOthers() then return false end
    end

    -- some buildings will say they DONT want assistance so that the next building in a chain can be assisted instead
    return assistedUnit:DesiresAssistance(self)
end

function HostUnit:DesiresAssistance(fromUnit)
    return true
end

function HostUnit:AssistBehaviorThread()

    -- hold the thread until the unit is completed or no longer valid for assistance
    WaitUntil(function() return self:IsCompleted() or not self:AssistBehaviorIsValidFor(self.assistBehaviorAssistedUnit) end)
    local assistFollowRange = (self.tp and self.tp.construction and self.tp.construction.range) or 10
    
    -- Runs as long as the assisted unit is considered valid/alive.
    while self:AssistBehaviorIsValidFor(self.assistBehaviorAssistedUnit) do
        local assistedUnit = self.assistBehaviorAssistedUnit

        -- WAIT: if the assisted unit hasn't actually started construction yet (still a placement ghost),
        -- just follow and poll until it gets promoted.
        if assistedUnit and not assistedUnit.hasBeenPromotedFromPlacementGhost then
            if not self.followBehaviorIsActive then
                self:FollowBehaviorStart(assistedUnit, assistFollowRange)
            end
            WaitTicks(10)
        -- Assist in completing an unfinished structure.
        elseif self.SCOHasCommanderEnhancementWork
            and self:SCOHasCommanderEnhancementWork(assistedUnit) then
            self:SCOAssistCommanderEnhancement(assistedUnit, 'assist')
        elseif self:BuildBehaviorIsValidFor(assistedUnit) then
            self:FollowBehaviorStop()

            self:BuildBehaviorStart(assistedUnit)
            while self.buildBehaviorIsActive do
                WaitTicks(1)
            end
            self:BuildBehaviorStop()

        -- Assist whatever the target unit is currently building.
        elseif self:BuildBehaviorIsValidFor(assistedUnit.buildBehaviorActualUnit) then
            local unitBeingBuilt = assistedUnit.buildBehaviorActualUnit

            -- WAIT: don't try to build-assist a placement ghost; wait until someone promotes it.
            if unitBeingBuilt and not unitBeingBuilt.hasBeenPromotedFromPlacementGhost then
                -- Follow the assisted unit while waiting for the unit being built to be promoted from a placement ghost.
                if not self.followBehaviorIsActive then
                    self:FollowBehaviorStart(assistedUnit, assistFollowRange)
                end
                WaitTicks(10)
            else
                self:FollowBehaviorStop()
                self:BuildBehaviorStart(unitBeingBuilt)

                while self.buildBehaviorIsActive and assistedUnit.buildBehaviorIsActive and self.buildBehaviorActualUnit == assistedUnit.buildBehaviorActualUnit do
                    WaitTicks(1)
                end
                self:BuildBehaviorStop()
            end
        
        -- Assist in production
        elseif self:BuildBehaviorIsValidFor(assistedUnit.productionBehaviorTargetUnit) then
            local unitBeingBuilt = assistedUnit.productionBehaviorTargetUnit

            -- WAIT: don't try to build-assist a placement ghost; wait until someone promotes it.
            if unitBeingBuilt and not unitBeingBuilt.hasBeenPromotedFromPlacementGhost then
                WaitTicks(10)
            else
                self:FollowBehaviorStop()
                self:BuildBehaviorStart(unitBeingBuilt)

                while self.buildBehaviorIsActive and assistedUnit.productionBehaviorIsActive do
                    WaitTicks(1)
                end
                self:BuildBehaviorStop()
            end
        
        -- Assist in upgrade
        elseif self:BuildBehaviorIsValidFor(assistedUnit.upgradeBehaviorTargetUnit) then
            local unitBeingBuilt = assistedUnit.upgradeBehaviorTargetUnit

            -- WAIT: don't try to build-assist a placement ghost; wait until someone promotes it.
            if unitBeingBuilt and not unitBeingBuilt.hasBeenPromotedFromPlacementGhost then
                WaitTicks(10)
            else
                self:FollowBehaviorStop()
                self:BuildBehaviorStart(unitBeingBuilt)

                while self.buildBehaviorIsActive and assistedUnit.upgradeBehaviorIsActive do
                    WaitTicks(1)
                end
                self:BuildBehaviorStop()
            end

        -- Assist attacking the current attack target.
        --elseif self:AttackBehaviorIsValidFor(assisted.attackBehaviorTargetUnit) then

        --    self:AttackBehaviorStart(assisted.attackBehaviorTargetUnit, self.attackRange)

        --    while self.attackBehaviorIsActive and assisted.attackBehaviorIsActive and self.attackBehaviorTargetUnit == assisted.attackBehaviorTargetUnit do
        --        WaitTicks(1)
        --    end
        --    self:AttackBehaviorStop()

        -- Assist repairing the unit currently being repaired.
        elseif self:RepairBehaviorIsValidFor(assistedUnit.repairBehaviorTarget) then
            -- Disable follow behavior when assisting with a structure.
            if assistedUnit.repairBehaviorTarget:HasTags(Tags.STRUCTURE) then
                self:FollowBehaviorStop()
            end

            self:RepairBehaviorStart(assistedUnit.repairBehaviorTarget)

            while self.repairBehaviorIsActive and assistedUnit.repairBehaviorIsActive and self.repairBehaviorTarget == assistedUnit.repairBehaviorTarget do
                WaitTicks(1)
            end
            self:RepairBehaviorStop()

        -- Assist reclaiming the target currently being reclaimed.
        elseif self:ReclaimBehaviorIsValidFor(assistedUnit.reclaimBehaviorTarget) then
            -- Disable follow behavior when assisting with a structure.
            if assistedUnit.reclaimBehaviorTarget:HasTags(Tags.STRUCTURE) then
                self:FollowBehaviorStop()
            end

            self:ReclaimBehaviorStart(assistedUnit.reclaimBehaviorTarget)

            while self.reclaimBehaviorIsActive and assistedUnit.reclaimBehaviorIsActive and self.reclaimBehaviorTarget == assistedUnit.reclaimBehaviorTarget do
                WaitTicks(1)
            end
            self:ReclaimBehaviorStop()

        -- Assist capturing the target currently being captured.
        elseif self:CaptureBehaviorIsValidFor(assistedUnit.captureBehaviorTarget) then
            -- Disable follow behavior when assisting with a structure.
            if assistedUnit.captureBehaviorTarget:HasTags(Tags.STRUCTURE) then
                self:FollowBehaviorStop()
            end

            self:CaptureBehaviorStart(assistedUnit.captureBehaviorTarget)

            while self.captureBehaviorIsActive and assistedUnit.captureBehaviorIsActive and self.captureBehaviorTarget == assistedUnit.captureBehaviorTarget do
                WaitTicks(1)
            end
            self:CaptureBehaviorStop()

        else
            -- Follow the assisted unit.
            if not self.followBehaviorIsActive then
                self:FollowBehaviorStart(assistedUnit, (self.tp and self.tp.construction and self.tp.construction.range) or 10)
            end
            -- Coarse polling interval by design.
            WaitTicks(3)
        end
    end

    -- Assisted unit became invalid or died: cleanly shut down assist behavior.
    self:AssistBehaviorStop()
end


function HostUnit:AssistBehaviorStop()
    self:ClearMasterFactory()

    self:FollowBehaviorStop()
    self:BuildBehaviorStop()
    self:AttackBehaviorStop()
    self:CaptureBehaviorStop()
    self:ReclaimBehaviorStop()
    self:RepairBehaviorStop()

    -- clear behavior thread
    if self.assistBehaviorThread then
        KillThread(self.assistBehaviorThread)
    end
    self.assistBehaviorIsActive = false
    self.assistBehaviorThread = nil
    self.assistBehaviorAssistedUnit = nil
    self.assistBehaviorIsSlaveFac = nil
end

--- Determines if this unit can reclaim the given target.
--- @param reclaimTarget HostUnit The target unit to be reclaimed.
--- @return boolean True if reclaiming is valid, false otherwise.
function HostUnit:ReclaimBehaviorIsValidFor(reclaimTarget)
    -- target must exist
    if not reclaimTarget then
        return false
    end

    -- unit must be allowed to perform construction interactions
    if not self:CanConstructOthers() then
        return false
    end

    -- cannot reclaim dead units
    if reclaimTarget.dead then
        return false
    end

    -- cannot reclaim itself
    if reclaimTarget == self then
        return false
    end

    -- cannot reclaim Commander
    if reclaimTarget:HasTags(Tags.COMMAND) then
        return false
    end

    if __Entities.Units[reclaimTarget.id.index] == reclaimTarget and self.army:IsEnemy(reclaimTarget.army) and not reclaimTarget:IsIntelVisible(self.army) then return false end
    return true
end

--- Starts the reclaim behavior for this unit.
--- @param reclaimTarget HostUnit The unit to be reclaimed.
--- @return nil
function HostUnit:ReclaimBehaviorStart(reclaimTarget)
    -- abort if the target cannot be reclaimed
    if not self:ReclaimBehaviorIsValidFor(reclaimTarget) then
        return
    end

    if self.reclaimBehaviorIsActive then
        self:ReclaimBehaviorStop()
    end

    -- store state and mark behavior as active
    self.reclaimBehaviorIsActive = true
    self.reclaimBehaviorTarget = reclaimTarget

    -- start the behavior thread
    self.reclaimBehaviorThread = self:NewThread(self.ReclaimBehaviorThread)
end

--- Main thread handling the reclaim behavior.
--- Moves the unit into range, initiates reclaim, and suspends the routine across pause.
--- @return nil
function HostUnit:ReclaimBehaviorThread()
    local target = self.reclaimBehaviorTarget

    -- hold the thread until the unit is completed
    WaitUntil(function() return self:IsCompleted() or not self:ReclaimBehaviorIsValidFor(target) end)

    if not self:ReclaimBehaviorIsValidFor(target) then
        self:ReclaimBehaviorStop()
        return
    end

    local canMove = self:CanMove()

    if canMove then
        local range = self.tp.construction and self.tp.construction.range or 5

        -- # move into range. Pause never blocks movement -- only the reclaim routine is pausable,
        -- so a paused engineer still walks to its target and waits there.
        self:FollowBehaviorStart(target, range)
        self:MoveIntoRangeBehaviorStart(math3D.tofloat2(target:GetPosition()), range)

        WaitUntil(function()
            return not self:ReclaimBehaviorIsValidFor(target)
                or not self.moveIntoRangeBehaviorIsActive
        end)
    else
        local inRange = self.constructionDetectorCollider:IsOverlappingUnit(target)

        -- stationary builder cannot reach the target: abort reclaim behavior.
        if not inRange then
            self:ReclaimBehaviorStop()
            return
        end
    end

    if not self:ReclaimBehaviorIsValidFor(target) then
        self:ReclaimBehaviorStop()
        return
    end

    -- # in range: run the reclaim routine, suspending it across pause.
    while self:ReclaimBehaviorIsValidFor(target) do
        WaitUntil(function() return not self:ReclaimBehaviorIsValidFor(target) or not self:GetPause() end)
        if not self:ReclaimBehaviorIsValidFor(target) then break end
        
        local targetPositionFloat2 = math3D.tofloat2(target:GetPosition())
        local directionToTarget = self:GetAlignRotation(targetPositionFloat2)
        self:AlignBehaviorStart(directionToTarget)
        WaitUntil(function() return not self:ReclaimBehaviorIsValidFor(target) or not self.alignBehaviorIsActive end)
        self:StartReclaimRoutine(target)
        WaitUntil(function() return self:GetPause() or not self:ReclaimBehaviorIsValidFor(target) end)

        if self:IsReclaiming(target) then
            self:EndReclaimRoutine(target)
        end
    end

    self:ReclaimBehaviorStop()
end

--- Stops the reclaim behavior and cleans up active threads.
--- @return nil
function HostUnit:ReclaimBehaviorStop()
    if not self.reclaimBehaviorIsActive then
        return
    end

    -- This behavior owns the reclaim routine: end it if the process has not already (Rule B2).
    if self:IsReclaiming(self.reclaimBehaviorTarget) then
        self:EndReclaimRoutine(self.reclaimBehaviorTarget)
    end

    self.reclaimBehaviorIsActive = false
    self.reclaimBehaviorTarget = nil

    if self.reclaimBehaviorThread then
        KillThread(self.reclaimBehaviorThread)
        self.reclaimBehaviorThread = nil
    end

    self:FollowBehaviorStop()
end

--- Determines if this unit can repair the given target.
--- @param repairTarget HostUnit The target unit to be repaired.
--- @return boolean True if repairing is valid, false otherwise.
function HostUnit:RepairBehaviorIsValidFor(repairTarget)
    if not repairTarget then return false end
    if not self:CanConstructOthers() then return false end
    if repairTarget.dead then return false end
    if repairTarget == self then return false end
    if not self.army:IsAlly(repairTarget.army) then return false end

    -- valid if incomplete: build phase must run first before any HP restoration
    if not repairTarget:IsCompleted() then return true end

    -- valid if HP, capture, or reclaim progress needs restoring
    local reclaimProgress = repairTarget.reclaimProgress or 0
    local captureProgress = repairTarget.captureProgress or 0
    return repairTarget:GetHealth() < repairTarget:GetMaxHealth() or captureProgress > 0 or reclaimProgress > 0
end

--- Starts the repair behavior for this unit.
--- @param repairTarget HostUnit The unit to be repaired.
--- @return nil
function HostUnit:RepairBehaviorStart(repairTarget)
    -- abort if the target cannot be repaired
    if not self:RepairBehaviorIsValidFor(repairTarget) then
        return
    end

    if self.repairBehaviorIsActive then
        self:RepairBehaviorStop()
    end

    -- store state and mark behavior as active
    self.repairBehaviorIsActive = true
    self.repairBehaviorTarget = repairTarget

    -- start the behavior thread
    self.repairBehaviorThread = self:NewThread(self.RepairBehaviorThread)
end

--- Main thread handling the repair behavior.
--- Phase 1: if target is incomplete, delegates entirely to BuildBehavior (which manages its own pause).
--- Phase 2: moves into range and runs the repair routine, suspending it across pause.
--- @return nil
function HostUnit:RepairBehaviorThread()
    local target = self.repairBehaviorTarget
    if self.SCOHasCommanderEnhancementWork
        and self:SCOHasCommanderEnhancementWork(target) then
        self:SCOAssistCommanderEnhancement(target, 'repair')
        if not self.repairBehaviorIsActive then return end
    end

    -- hold the thread until the unit is completed or no longer valid for repair
    WaitUntil(function() return self:IsCompleted() or not self:RepairBehaviorIsValidFor(target) end)

    if not self:RepairBehaviorIsValidFor(target) then
        self:RepairBehaviorStop()
        return
    end

    local canMove = self:CanMove()

    -- # Phase 1: construction -- delegate fully to BuildBehavior (Rule B4).
    if not target:IsCompleted() then
        local inRange = self.constructionDetectorCollider:IsOverlappingUnit(target)
        if not canMove and not inRange then
            -- stationary builder cannot reach the target: abort repair behavior.
            self:RepairBehaviorStop()
            return
        end
        
        self:BuildBehaviorStart(target)
        WaitUntil(function() return not self.buildBehaviorIsActive end)
    end

    if not self:RepairBehaviorIsValidFor(target) then
        self:RepairBehaviorStop()
        return
    end

    -- # Phase 2: HP / captureProgress / reclaimProgress restoration.
    if canMove then
        local range = self.tp.construction and self.tp.construction.range or 5

        -- # move into range. Pause never blocks movement -- only the repair routine is pausable,
        -- so a paused engineer still walks to its target and waits there.
        self:FollowBehaviorStart(target, range)
    end

    -- # while valid: run the repair routine, suspending it across pause. If the target gets out of range, the routine will pause until it comes back into range or becomes invalid.
    while self:RepairBehaviorIsValidFor(target) do
        WaitUntil(function() return not self:RepairBehaviorIsValidFor(target) or (self.constructionDetectorCollider:IsCollidingWithGlobalID(target.id) and not self:GetPause()) end)
        if not self:RepairBehaviorIsValidFor(target) then break end

        if self.SCOHasCommanderEnhancementWork
            and self:SCOHasCommanderEnhancementWork(target) then
            self:SCOAssistCommanderEnhancement(target, 'repair')
            if not self.repairBehaviorIsActive then return end
        else
            self:StartRepairRoutine(target)
            WaitUntil(function() return self:GetPause() or not self:RepairBehaviorIsValidFor(target)
                or not self.constructionDetectorCollider:IsCollidingWithGlobalID(target.id)
                or (self.SCOHasCommanderEnhancementWork and self:SCOHasCommanderEnhancementWork(target)) end)

            if self:IsRepairing(target) then
                self:EndRepairRoutine(target)
            end
        end
    end

    self:RepairBehaviorStop()
end

--- Stops the repair behavior and cleans up active threads.
--- @return nil
function HostUnit:RepairBehaviorStop()
    -- Idempotent: safe to call from the thread's happy path and from external aborts.
    if not self.repairBehaviorIsActive then
        return
    end

    -- Covers abort during phase 1 (build delegation).
    self:BuildBehaviorStop()

    -- This behavior owns the repair routine: end it if the process has not already (Rule B2).
    if self:IsRepairing(self.repairBehaviorTarget) then
        self:EndRepairRoutine(self.repairBehaviorTarget)
    end

    self.repairBehaviorIsActive = false
    self.repairBehaviorTarget = nil

    if self.repairBehaviorThread then
        KillThread(self.repairBehaviorThread)
        self.repairBehaviorThread = nil
    end

    self:FollowBehaviorStop()
end

---Determines if this unit can capture the given target.
---@param captureTarget HostUnit The target unit to be captured
---@return boolean True if capturing the target is allowed
function HostUnit:CaptureBehaviorIsValidFor(captureTarget)
    -- target must exist
    if not captureTarget then return false end
    -- unit must be allowed to perform construction interactions
    if not self:CanConstructOthers() then return false end
    -- cannot capture dead units
    if captureTarget.dead then return false end
    -- can only capture units (not wrecks)
    if not __Entities.Units[captureTarget.id.index] then  return false end
    -- Only completed units can be captured.
    if not captureTarget:IsCompleted() then return false end
    -- cannot capture own army (check after __Entities.Units, - wrecks don't have an army ID)
    if self.army:IsAlly(captureTarget.army) then return false end
    -- cannot capture Commander
    if captureTarget:HasTags(Tags.COMMAND) then return false end

    return captureTarget:IsIntelVisible(self.army)
end

---Starts the capture behavior for this unit.
---@param captureTarget HostUnit The unit that should be captured
---@return nil
function HostUnit:CaptureBehaviorStart(captureTarget)
    -- stop if target is not valid for capture
    if not self:CaptureBehaviorIsValidFor(captureTarget) then
        return
    end
    
    if self.captureBehaviorIsActive then
        self:CaptureBehaviorStop()
    end

    -- initialize capture behavior state
    self.captureBehaviorIsActive = true
    self.captureBehaviorTarget = captureTarget

    -- start behavior thread
    self.captureBehaviorThread = self:NewThread(self.CaptureBehaviorThread)
end

---Main thread handling the capture behavior.
---Moves the unit into range, initiates capture, and suspends the routine across pause.
---@return nil
function HostUnit:CaptureBehaviorThread()
    local target = self.captureBehaviorTarget

    -- hold the thread until the unit is completed or no longer valid for capture
    WaitUntil(function() return self:IsCompleted() or not self:CaptureBehaviorIsValidFor(target) end)

    if not self:CaptureBehaviorIsValidFor(target) then
        self:CaptureBehaviorStop()
        return
    end

    local range = self.tp.construction and self.tp.construction.range or 5

    -- # move into range. Pause never blocks movement -- only the capture routine is pausable,
    -- so a paused engineer still walks to its target and waits there.
    self:FollowBehaviorStart(target, range)
    self:MoveIntoRangeBehaviorStart(math3D.tofloat2(target:GetPosition()), range)

    WaitUntil(function()
        return not self:CaptureBehaviorIsValidFor(target)
            or not self.moveIntoRangeBehaviorIsActive
            or self.constructionDetectorCollider:IsCollidingWithGlobalID(target.id)
    end)

    if not self:CaptureBehaviorIsValidFor(target) then
        self:CaptureBehaviorStop()
        return
    end

    -- # in range: run the capture routine, suspending it across pause.
    while self:CaptureBehaviorIsValidFor(target) do
        WaitUntil(function() return not self:CaptureBehaviorIsValidFor(target) or not self:GetPause() and 
            self.constructionDetectorCollider:IsCollidingWithGlobalID(target.id) end)

        if not self:CaptureBehaviorIsValidFor(target) then break end

        self:StartCaptureRoutine(target)
        WaitUntil(function() return self:GetPause() or 
            not self:CaptureBehaviorIsValidFor(target) or 
            not self.constructionDetectorCollider:IsCollidingWithGlobalID(target.id) end)

        if self:IsCapturing(target) then
            self:EndCaptureRoutine(target)
        end
    end

    self:CaptureBehaviorStop()
end

---Stops the capture behavior and cleans up state and active threads.
---@return nil
function HostUnit:CaptureBehaviorStop()
    -- ignore if not active
    if not self.captureBehaviorIsActive then
        return
    end

    -- stop capture
    if self:IsCapturing(self.captureBehaviorTarget) then
        self:EndCaptureRoutine(self.captureBehaviorTarget)
    end

    -- reset behavior state
    self.captureBehaviorIsActive = false
    self.captureBehaviorTarget = nil

    -- stop active behavior thread
    if self.captureBehaviorThread then
        KillThread(self.captureBehaviorThread)
        self.captureBehaviorThread = nil
    end

    -- stop follow behavior
    self:FollowBehaviorStop()
end

----------------------------------------------
---------- Routines and Processes ------------
----------------------------------------------

---------- Build Routine -------------

---------- Build Routine Callbacks -------------
-- Extension hooks for mods/subclasses.

---@protected Called when we start building a unit.
---@param targetUnit HostUnit The new unit being built.
function HostUnit:OnStartBuildRoutine(targetUnit)
    targetUnit.resourceEntities.construction:AddBuilder(self)

    self:UpdateUIValues()

    WorkCommands.OnStartBuilding.Send(self.id, targetUnit.id)
end

---@protected Called when we stop building a unit.
---@param targetUnit HostUnit The new unit being built.
function HostUnit:OnStopBuildRoutine(targetUnit)
    targetUnit.resourceEntities.construction:RemoveBuilder(self)
    
    self:UpdateUIValues()

    WorkCommands.OnStopBuilding.Send(self.id)
end



---------- Build Process -------------

---------- Build Process Callbacks -------------
-- Extension hooks for mods/subclasses.

---@protected Called when this unit has starts getting built.
function HostUnit:OnBuildProcessStarted()

    Armies[self.army.id]:SetUnitStat("beingBuilt", self.tpId, 1)

end
---@protected Called whenever this unit stops getting built.
function HostUnit:OnBuildProcessEnded()

    Armies[self.army.id]:SetUnitStat("beingBuilt", self.tpId, -1)

    if self:IsCompleted() then
        self:OnStopBeingBuilt()

        -- If this build was a part of an upgrade. We can now safely end the upgrade.
        if self:IsUpgrade() then
            self:EndUpgrade()
        end
    end
end



---------- Build Routine -------------

---@protected Called when this HostUpgrader starts Upgrading a target upgrade.
---@param upgrade HostUnit The upgrade that has just started being Upgraded.
function HostUnit:OnStartUpgrading(upgrade)
end

---@protected Called when this HostUpgrader stops Upgrading a target upgrade.
---@param upgrade HostUnit The upgrade that was being Upgraded.
function HostUnit:OnEndUpgrading(upgrade)
end

---------- Upgrades Process -------------

---@protected Called when this unit starts being upgraded by `upgrader`.
---@param upgrader HostUnit The unit that has just started upgrading this one.
function HostUnit:OnStartUpgrade(upgrader)
end

---@protected Called when this unit stops being upgraded (upgrade completed or cancelled).
---@param upgrader HostUnit The unit that was upgrading this one.
function HostUnit:OnEndUpgrade(upgrader)
    if self:IsCompleted() and not upgrader.dead then
        upgrader:CopyToggles(self)
        upgrader:CopyOrders(self)
        upgrader:DoCallbacks("OnUpgraded", self)
    end
end



---------- Repair Routine -------------

---------- Repair Routine Callbacks -------------
-- Extension hooks for mods/subclasses.

---@protected Called when this unit starts Repairing a target unit.
---@param targetUnit HostUnit The unit that has just started being Repaired.
function HostUnit:OnStartRepairRoutine(targetUnit)
    
    targetUnit.resourceEntities.construction:AddBuilder(self)

    self:UpdateUIValues()

    WorkCommands.OnStartRepair.Send(self.id, targetUnit.id)
end

---@protected Called when this unit stops Repairing a target unit.
---@param targetUnit HostUnit The unit that was being Repaired.
function HostUnit:OnStopRepairRoutine(targetUnit)
    
    targetUnit.resourceEntities.construction:RemoveBuilder(self)

    self:UpdateUIValues()

    WorkCommands.OnStopRepair.Send(self.id)
end



---------- Repair Process -------------

---------- Repair Process Callbacks -------------
-- Extension hooks for mods/subclasses.

---@protected Called after the Repair process thread has been spawned.
function HostUnit:OnRepairProcessStarted() end

---@protected Called after the Repair process thread has been killed and cleanup has run.
function HostUnit:OnRepairProcessEnded() end



---------- Reclaim Routine -------------

---------- Reclaim Routine Callbacks -------------
-- Extension hooks for mods/subclasses. Empty by default.

---@protected Called when this unit starts Reclaiming a target unit.
---@param targetUnit HostUnit The unit that has just started being Reclaimed.
function HostUnit:OnStartReclaimRoutine(targetUnit)

    -- add this unit as active builder on the target
    -- phase 1, make unit to wreck
    if targetUnit.entityType == "unit" then
        targetUnit.resourceEntities.construction:AddBuilderReclaim(self)
    -- phase 2 reclaim wreck
    elseif targetUnit.entityType == "prop" then
        targetUnit.resourceEntities.harvest:AddBuilder(self)
    end

    self:UpdateUIValues()
    WorkCommands.OnStartReclaim.Send(self.id, targetUnit.id)
end

---@protected Called when this unit stops Reclaiming a target unit.
---@param targetUnit HostUnit The unit that was being Reclaimed.
function HostUnit:OnStopReclaimRoutine(targetUnit)
    
    -- remove resource consumption
    -- phase 1, make unit to wreck
    if targetUnit.entityType == "unit" then
        targetUnit.resourceEntities.construction:RemoveBuilder(self)
    -- phase 2 reclaim wreck
    elseif targetUnit.entityType == "prop" then
        targetUnit.resourceEntities.harvest:RemoveBuilder(self)
    end
    
    self:UpdateUIValues()
    WorkCommands.OnStopReclaim.Send(self.id)
end



---------- Reclaim Process -------------

---------- Reclaim Process Callbacks -------------
-- Extension hooks for mods/subclasses. Empty by default.

---@protected Called after the Reclaim process thread has been spawned.
function HostUnit:OnReclaimProcessStarted() end

---@protected Called after the Reclaim process thread has been killed and cleanup has run.
---@param reclaimers HostUnit[] All reclaimers for this process.
function HostUnit:OnReclaimProcessEnded(reclaimers)
    
    if self:IsReclaimProcessComplete() then

        local wreckage = CreateWreckageFromUnit(self)
        WorkCommands.OnUnitReclaimed.Send(self.id)

        self:Delete()

        if wreckage then
            -- Dirty: We create a thread to wait 1 tick before calling ReclaimBehaviorStart. 
            -- This 1 Tick grace period allows any reclaimers to stop their existing Reclaim behavior (if they have any) because the unit they are reclaim is deleted.
            NewThread(function()
                WaitTicks(1)
                for _, reclaimer in ipairs(reclaimers) do
                    if reclaimer and not reclaimer.dead then
                        -- Immeditely start reclaiming the wreck which was produced.
                        reclaimer:ReclaimBehaviorStart(wreckage)
                    end
                end
            end)
        end
    end
end



---------- Capture Routine -------------

---------- Capture Routine Callbacks -------------
-- Extension hooks for mods/subclasses. Empty by default.

---@protected Called when this unit starts Capturing a target unit.
---@param targetUnit HostUnit The unit that has just started being Captured.
function HostUnit:OnStartCaptureRoutine(targetUnit)
    targetUnit.resourceEntities.construction:AddBuilder(self)

    -- update UI and notify client
    self:UpdateUIValues()

    WorkCommands.OnStartCapture.Send(self.id, targetUnit.id)
end

---@protected Called when this unit stops Capturing a target unit.
---@param targetUnit HostUnit The unit that was being Captured.
function HostUnit:OnStopCaptureRoutine(targetUnit)
    targetUnit.resourceEntities.construction:RemoveBuilder(self)
    
    -- update UI
    self:UpdateUIValues()

    -- send on stop capturing to client
    WorkCommands.OnStopCapture.Send(self.id)
end



---------- Capture Process -------------

---------- Capture Process Callbacks -------------
-- Extension hooks for mods/subclasses. Empty by default.

---@protected Called after the Capture process thread has been spawned.
function HostUnit:OnCaptureProcessStarted()
    -- do not target the unit that will be captured
    self:SetTargetable(false)
end

---@protected Called after the Capture process thread has been killed and cleanup has run.
---@param army? HostArmy Which army captured the unit.
function HostUnit:OnCaptureProcessEnded(army)
    
    -- re-enable targeting only if no capturers remain
    self:SetTargetable(true)

    -- On a completed capture!
    if self:IsCaptureProcessComplete() then
        local position = self:GetPosition()
        local tpId = self.tpId

        -- notify clients to remove visual capture elements
        WorkCommands.OnUnitCaptured.Send(self.id)
        
        -- spawn new unit with updated army ownership
        local newUnit = CreateUnit(army.id, tpId, position)

        -- copy bone hierarchy state from old unit to new unit
        if newUnit then
            Engine.CopyHierarchy(self.id, newUnit.id)
            newUnit:SCOSetVeterancyKills(self.scoVeterancyKills or 0, true)
            local transfer = rawget(_G, "SCO_CommanderEnhancementHostTransfer")
            if type(transfer) == "function" then
                pcall(transfer, self, newUnit)
            end
        end

        -- remove old unit
        self:Delete()
    end
end

function HostUnit:OnBecameIdle()
end

-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0
-- HostUnit:PromoteToUnit enables collision exactly once when a placement
-- ghost becomes a real unit. Factory-owned children must remain pinned
-- until their host moves them clear of imported hull geometry.
if not _G.SupremeCommanderOverhaulFactoryColliderPromotionHookInstalled then
    _G.SupremeCommanderOverhaulFactoryColliderPromotionHookInstalled = true
    local SCOFatboyUnit = HostUnit or Unit
    if not SCOFatboyUnit then
        error("Fatboy collider hook could not resolve the host unit base class")
    end
    local StockUnitPromoteToUnit = SCOFatboyUnit.PromoteToUnit
    function SCOFatboyUnit:PromoteToUnit()
        StockUnitPromoteToUnit(self)
        if self.scoFactoryColliderPinOwner ~= nil then
            Engine.SetVolumeColliderEnabled(self.id, false)
        end
    end
end

-- Native HostUnit:SetTargetable owns collider enablement; current targeting
-- queries unit state directly and has no TargetCollider:Dirty event bridge.

-- FA Support Structures Cache Patcher 1.1.2
-- Exact FA support-shield rotor lifecycle. Sanctuary normally enables a
-- shield unit's rotators throughout the recharge window; FA starts them
-- only when the shield is actually enabled (or while UEB4202 upgrades).
local SCO_FaSupportShieldUnit = HostUnit or Unit
if not SCO_FaSupportShieldUnit then
    error("FA support shields could not resolve the host unit base class.")
end
local SCO_FaSupportStockCheckShieldState = SCO_FaSupportShieldUnit.CheckShieldState
local SCO_FaSupportStockOnStopBeingBuilt = SCO_FaSupportShieldUnit.OnStopBeingBuilt
local SCO_FaSupportStockOnStartUpgrading = SCO_FaSupportShieldUnit.OnStartUpgrading
local SCO_FaSupportStockOnEndUpgrading = SCO_FaSupportShieldUnit.OnEndUpgrading

function SCO_FaSupportShieldUnit:SCOApplySupportShieldRotators(enabled, upgrading, initial)
    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield
    if not contract or not self.shields or not self.rotatorIds then
        return
    end
    local speeds = initial and contract.initialRotatorSpeeds
        or (upgrading and contract.upgradeRotatorSpeeds)
        or contract.steadyRotatorSpeeds
    for index, speed in ipairs(speeds or {}) do
        local rotatorId = self.rotatorIds and self.rotatorIds[index]
        if rotatorId then
            Engine.SetRotatorSpeed(
                rotatorId,
                EngineClasses.float3(speed.x, speed.y, speed.z)
            )
        end
    end
    self:SetRotatorsEnabled(enabled)
end

function SCO_FaSupportShieldUnit:CheckShieldState(skipRecharge)
    SCO_FaSupportStockCheckShieldState(self, skipRecharge)
    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield
    if not contract then
        return
    end
    local actualShieldEnabled = false
    for _, shield in pairs(self.shields or {}) do
        if shield.enabled then
            actualShieldEnabled = true
            break
        end
    end
    local upgrading = self.scoFaSupportShieldUpgrading == true
    self:SCOApplySupportShieldRotators(actualShieldEnabled or upgrading, upgrading)
end

function SCO_FaSupportShieldUnit:OnStopBeingBuilt()
    SCO_FaSupportStockOnStopBeingBuilt(self)
    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield
    if not contract then
        return
    end
    local actualShieldEnabled = false
    for _, shield in pairs(self.shields or {}) do
        if shield.enabled then
            actualShieldEnabled = true
            break
        end
    end
    self:SCOApplySupportShieldRotators(actualShieldEnabled, false, true)
end

function SCO_FaSupportShieldUnit:OnStartUpgrading(targetUnit)
    SCO_FaSupportStockOnStartUpgrading(self, targetUnit)
    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield
    if contract and contract.upgradeRotatorSpeeds then
        self.scoFaSupportShieldUpgrading = true
        self:SCOApplySupportShieldRotators(true, true)
    end
end

function SCO_FaSupportShieldUnit:OnEndUpgrading(targetUnit)
    SCO_FaSupportStockOnEndUpgrading(self, targetUnit)
    local contract = self.tp and self.tp.additions and self.tp.additions.faSupportShield
    if not contract then
        return
    end
    self.scoFaSupportShieldUpgrading = false
    if self.dead or self.deleted then
        return
    end
    local actualShieldEnabled = false
    for _, shield in pairs(self.shields or {}) do
        if shield.enabled then
            actualShieldEnabled = true
            break
        end
    end
    self:SCOApplySupportShieldRotators(actualShieldEnabled, false)
end

-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0
-- Exact supported portions of the FA extractor/radar lifecycle. Every wrapper
-- delegates first (except the pre-upgrade animator wake-up) and is ID-gated, so
-- unrelated units and wrappers installed by earlier modules keep ownership.
local SCO_FaCombatHostUnit = HostUnit or Unit
if not SCO_FaCombatHostUnit then
    error("FA combat structures could not resolve the host unit base class.")
end

local SCO_FaCombatExtractorIds = {
    ["ugs1601"] = true,
    ["ugs2601"] = true,
    ["ugs3601"] = true,
    ["ues1601"] = true,
    ["ues2601"] = true,
    ["ues3601"] = true,
}
local SCO_FaCombatRadarIds = {
    ["ugs1701"] = true,
    ["ugs2701"] = true,
    ["ugs3701"] = true,
    ["ues1701"] = true,
    ["ues2701"] = true,
    ["ues3701"] = true,
    ["uss1701"] = true,
    ["uss2701"] = true,
    ["uss3701"] = true,
}

local SCO_FaCombatStockCheckProductionState = SCO_FaCombatHostUnit.CheckProductionState
local SCO_FaCombatStockCheckRadarState = SCO_FaCombatHostUnit.CheckRadarState
local SCO_FaCombatStockOnEnergyDown = SCO_FaCombatHostUnit.OnEnergyDown
local SCO_FaCombatStockOnEnergyUp = SCO_FaCombatHostUnit.OnEnergyUp
local SCO_FaCombatStockOnStopBeingBuilt = SCO_FaCombatHostUnit.OnStopBeingBuilt
local SCO_FaCombatStockOnStartUpgrading = SCO_FaCombatHostUnit.OnStartUpgrading
local SCO_FaCombatStockOnEndUpgrading = SCO_FaCombatHostUnit.OnEndUpgrading

function SCO_FaCombatHostUnit:SCOApplyFaExtractorState()
    if not SCO_FaCombatExtractorIds[self.tpId] then
        return
    end
    local active = self:IsCompleted()
        and self:GetProductionToggle()
        and not self.army.economy.isEnergyDown
    if self.resourceEntities.production then
        self.resourceEntities.production:SetEnabled(active)
    end
    -- Progress-bound upgrade clips share this animator. Keep it awake during an
    -- upgrade; otherwise the source pump follows production/power state.
    self:SetAnimatorEnabled(self:IsUpgrading() or active)
end

function SCO_FaCombatHostUnit:CheckProductionState()
    SCO_FaCombatStockCheckProductionState(self)
    self:SCOApplyFaExtractorState()
end

function SCO_FaCombatHostUnit:CheckRadarState()
    SCO_FaCombatStockCheckRadarState(self)
    if SCO_FaCombatRadarIds[self.tpId] and self.radarDetector and self.rotatorIds then
        self:SetRotatorsEnabled(self.radarDetector:GetEnabled())
    end
end

function SCO_FaCombatHostUnit:OnEnergyDown()
    SCO_FaCombatStockOnEnergyDown(self)
    self:SCOApplyFaExtractorState()
end

function SCO_FaCombatHostUnit:OnEnergyUp()
    SCO_FaCombatStockOnEnergyUp(self)
    self:SCOApplyFaExtractorState()
end

function SCO_FaCombatHostUnit:OnStopBeingBuilt()
    SCO_FaCombatStockOnStopBeingBuilt(self)
    self:SCOApplyFaExtractorState()
    if SCO_FaCombatRadarIds[self.tpId] then
        self:CheckRadarState()
    end
end

function SCO_FaCombatHostUnit:OnStartUpgrading(targetUnit)
    if SCO_FaCombatExtractorIds[self.tpId] then
        self:SetAnimatorEnabled(true)
    end
    return SCO_FaCombatStockOnStartUpgrading(self, targetUnit)
end

function SCO_FaCombatHostUnit:OnEndUpgrading(targetUnit)
    local result = SCO_FaCombatStockOnEndUpgrading(self, targetUnit)
    self:SCOApplyFaExtractorState()
    return result
end

-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0
local SCO_VETERANCY_RULES = {
    ["uca1001"] = { kills = {3, 6, 9, 12, 15}, regen = {1, 2, 3, 4, 5} },
    ["uca1201"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["uca2011"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["uca2101"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["uca2301"] = { kills = {2, 4, 6, 8, 10}, regen = {2, 4, 6, 8, 10} },
    ["uca2502"] = { kills = {3, 6, 9, 12, 15}, regen = {2, 4, 6, 8, 10} },
    ["uca2701"] = { kills = {4, 8, 12, 16, 20}, regen = {3, 6, 9, 12, 15} },
    ["uca2806"] = { kills = {16, 32, 48, 64, 80}, regen = {3, 6, 9, 12, 15} },
    ["uca3001"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["uca3011"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["uca3201"] = { kills = {6, 12, 18, 24, 30}, regen = {3, 6, 9, 12, 15} },
    ["uca4011"] = { kills = {40, 80, 120, 160, 200}, regen = {10, 20, 30, 40, 50} },
    ["ucl0000"] = { kills = {20, 40, 60, 80, 100}, regen = {3, 6, 9, 12, 15} },
    ["ucl1001"] = { kills = {3, 6, 9, 12, 15}, regen = {1, 2, 3, 4, 5} },
    ["ucl1002"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["ucl1101"] = { kills = {3, 6, 9, 12, 15}, regen = {1, 2, 3, 4, 5} },
    ["ucl1201"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["ucl1701"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["ucl2002"] = { kills = {9, 18, 27, 35, 42}, regen = {2, 4, 6, 8, 10} },
    ["ucl2101"] = { kills = {3, 6, 9, 12, 15}, regen = {2, 4, 6, 8, 10} },
    ["ucl2201"] = { kills = {4, 8, 12, 16, 20}, regen = {2, 4, 6, 8, 10} },
    ["ucl2806"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["ucl3001"] = { kills = {9, 18, 27, 36, 45}, regen = {3, 6, 9, 12, 15} },
    ["ucl3101"] = { kills = {9, 18, 27, 36, 45}, regen = {3, 6, 9, 12, 15} },
    ["ucl3801"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["ucl4001"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["ucl4002"] = { kills = {30, 60, 90, 120, 150}, regen = {5, 10, 15, 20, 25} },
    ["ucl4003"] = { kills = {30, 60, 90, 120, 150}, regen = {10, 20, 30, 40, 50} },
    ["ucl4004"] = { kills = {50, 100, 150, 200, 250}, regen = {10, 20, 30, 40, 50} },
    ["ucl4005"] = { kills = {32, 64, 96, 128, 160}, regen = {3, 6, 9, 12, 15} },
    ["ucl5001"] = { kills = {9, 18, 27, 36, 45}, regen = {3, 6, 9, 12, 15} },
    ["ucn1001"] = { kills = {8, 16, 24, 32, 40}, regen = {1, 2, 3, 4, 5} },
    ["ucn3001"] = { kills = {32, 64, 96, 128, 160}, regen = {5, 10, 15, 20, 25} },
    ["ucs1001"] = { kills = {6, 12, 18, 24, 30}, regen = {1, 2, 3, 4, 5} },
    ["ucs1201"] = { kills = {4, 8, 12, 16, 20}, regen = {1, 2, 3, 4, 5} },
    ["ucs1301"] = { kills = {6, 12, 18, 24, 30}, regen = {1, 2, 3, 4, 5} },
    ["ucs1801"] = { kills = {4, 8, 12, 16, 20}, regen = {1, 2, 3, 4, 5} },
    ["ucs1802"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["ucs1803"] = { kills = {16, 32, 48, 64, 80}, regen = {5, 10, 15, 20, 25} },
    ["ucs2001"] = { kills = {12, 24, 36, 48, 60}, regen = {2, 4, 6, 8, 10} },
    ["ucs2101"] = { kills = {15, 30, 45, 60, 75}, regen = {2, 4, 6, 8, 10} },
    ["ucs2102"] = { kills = {9, 18, 27, 36, 45}, regen = {2, 4, 6, 8, 10} },
    ["ucs2201"] = { kills = {8, 16, 24, 32, 40}, regen = {2, 4, 6, 8, 10} },
    ["ucs2301"] = { kills = {12, 24, 36, 48, 60}, regen = {2, 4, 6, 8, 10} },
    ["ucs2501"] = { kills = {8, 16, 24, 32, 40}, regen = {2, 4, 6, 8, 10} },
    ["ucs2803"] = { kills = {32, 64, 96, 128, 160}, regen = {5, 10, 15, 20, 25} },
    ["ucs3001"] = { kills = {50, 100, 150, 200, 250}, regen = {3, 6, 9, 12, 15} },
    ["ucs3101"] = { kills = {30, 60, 90, 120, 150}, regen = {3, 6, 9, 12, 15} },
    ["ucs3102"] = { kills = {30, 60, 90, 120, 150}, regen = {3, 6, 9, 12, 15} },
    ["ucs3201"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["uea1001"] = { kills = {3, 6, 9, 12, 15}, regen = {1, 2, 3, 4, 5} },
    ["uea1201"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["uea2301"] = { kills = {2, 4, 6, 8, 10}, regen = {2, 4, 6, 8, 10} },
    ["uea3001"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["uea5001"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["uea5003"] = { kills = {3, 6, 9, 12, 15}, regen = {2, 4, 6, 8, 10} },
    ["uea5005"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["uea5007"] = { kills = {6, 12, 18, 24, 30}, regen = {3, 6, 9, 12, 15} },
    ["uea5008"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["uea5009"] = { kills = {25, 50, 75, 100, 125}, regen = {2, 4, 6, 8, 10} },
    ["uea5010"] = { kills = {3, 6, 9, 12, 15}, regen = {3, 6, 9, 12, 15} },
    ["uel0000"] = { kills = {20, 40, 60, 80, 100}, regen = {3, 6, 9, 12, 15} },
    ["uel1001"] = { kills = {3, 6, 9, 12, 15}, regen = {1, 2, 3, 4, 5} },
    ["uel1002"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["uel1101"] = { kills = {3, 6, 9, 12, 15}, regen = {1, 2, 3, 4, 5} },
    ["uel1201"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["uel1701"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["uel2201"] = { kills = {3, 6, 9, 12, 15}, regen = {2, 4, 6, 8, 10} },
    ["uel3001"] = { kills = {9, 18, 27, 36, 45}, regen = {3, 6, 9, 12, 15} },
    ["uel3002"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["uel3101"] = { kills = {9, 18, 27, 36, 45}, regen = {3, 6, 9, 12, 15} },
    ["uel3401"] = { kills = {9, 18, 27, 36, 45}, regen = {3, 6, 9, 12, 15} },
    ["uel4511"] = { kills = {25, 50, 75, 100, 125}, regen = {15, 30, 45, 60, 75} },
    ["uel5001"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["uel5005"] = { kills = {7, 14, 21, 28, 35}, regen = {2, 4, 6, 8, 10} },
    ["uel5006"] = { kills = {4, 8, 12, 16, 20}, regen = {2, 4, 6, 8, 10} },
    ["uel5007"] = { kills = {30, 60, 90, 120, 150}, regen = {5, 10, 15, 20, 25} },
    ["uel5010"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["uel5011"] = { kills = {6, 12, 18, 24, 30}, regen = {3, 6, 9, 12, 15} },
    ["uen1001"] = { kills = {8, 16, 24, 32, 40}, regen = {1, 2, 3, 4, 5} },
    ["uen1002"] = { kills = {4, 8, 12, 16, 20}, regen = {1, 2, 3, 4, 5} },
    ["uen2001"] = { kills = {16, 32, 48, 64, 80}, regen = {5, 10, 15, 20, 25} },
    ["uen2002"] = { kills = {16, 32, 48, 64, 80}, regen = {2, 4, 6, 8, 10} },
    ["uen3001"] = { kills = {32, 64, 96, 128, 160}, regen = {5, 10, 15, 20, 25} },
    ["uen3004"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["uen3005"] = { kills = {16, 32, 48, 64, 80}, regen = {3, 6, 9, 12, 15} },
    ["uen4001"] = { kills = {30, 60, 90, 120, 150}, regen = {10, 20, 30, 40, 50} },
    ["uen5001"] = { kills = {4, 8, 12, 16, 20}, regen = {2, 4, 6, 8, 10} },
    ["uen5003"] = { kills = {25, 50, 75, 100, 125}, regen = {3, 6, 9, 12, 15} },
    ["ues1001"] = { kills = {6, 12, 18, 24, 30}, regen = {1, 2, 3, 4, 5} },
    ["ues1201"] = { kills = {4, 8, 12, 16, 20}, regen = {1, 2, 3, 4, 5} },
    ["ues2001"] = { kills = {12, 24, 36, 48, 60}, regen = {2, 4, 6, 8, 10} },
    ["ues2101"] = { kills = {15, 30, 45, 60, 75}, regen = {2, 4, 6, 8, 10} },
    ["ues2102"] = { kills = {9, 18, 27, 36, 45}, regen = {2, 4, 6, 8, 10} },
    ["ues2201"] = { kills = {8, 16, 24, 32, 40}, regen = {2, 4, 6, 8, 10} },
    ["ues3102"] = { kills = {30, 60, 90, 120, 150}, regen = {3, 6, 9, 12, 15} },
    ["ues3201"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["ues4101"] = { kills = {50, 100, 150, 200, 250}, regen = {10, 20, 30, 40, 50} },
    ["ues5017"] = { kills = {6, 12, 18, 24, 30}, regen = {1, 2, 3, 4, 5} },
    ["ues5018"] = { kills = {12, 24, 36, 48, 60}, regen = {2, 4, 6, 8, 10} },
    ["ues5019"] = { kills = {30, 60, 90, 120, 150}, regen = {3, 6, 9, 12, 15} },
    ["ues5042"] = { kills = {24, 48, 72, 96, 120}, regen = {3, 6, 9, 12, 15} },
    ["ues5043"] = { kills = {25, 50, 75, 100, 125}, regen = {2, 4, 6, 8, 10} },
    ["uga1001"] = { kills = {3, 6, 9, 12, 15}, regen = {1, 2, 3, 4, 5} },
    ["uga1201"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["uga2301"] = { kills = {2, 4, 6, 8, 10}, regen = {2, 4, 6, 8, 10} },
    ["uga3001"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["uga5001"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["uga5002"] = { kills = {3, 6, 9, 12, 15}, regen = {2, 4, 6, 8, 10} },
    ["uga5004"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["uga5006"] = { kills = {6, 12, 18, 24, 30}, regen = {3, 6, 9, 12, 15} },
    ["uga5007"] = { kills = {40, 80, 120, 160, 200}, regen = {10, 20, 30, 40, 50} },
    ["uga5008"] = { kills = {3, 6, 9, 12, 15}, regen = {1, 2, 3, 4, 5} },
    ["uga5009"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["ugl0000"] = { kills = {20, 40, 60, 80, 100}, regen = {3, 6, 9, 12, 15} },
    ["ugl1001"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["ugl1002"] = { kills = {3, 6, 9, 12, 15}, regen = {1, 2, 3, 4, 5} },
    ["ugl1101"] = { kills = {3, 6, 9, 12, 15}, regen = {1, 2, 3, 4, 5} },
    ["ugl2002"] = { kills = {7, 14, 21, 28, 35}, regen = {2, 4, 6, 8, 10} },
    ["ugl2101"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["ugl2201"] = { kills = {4, 8, 12, 16, 20}, regen = {2, 4, 6, 8, 10} },
    ["ugl3001"] = { kills = {9, 18, 27, 36, 45}, regen = {3, 6, 9, 12, 15} },
    ["ugl3002"] = { kills = {9, 18, 27, 36, 45}, regen = {3, 6, 9, 12, 15} },
    ["ugl3101"] = { kills = {9, 18, 27, 36, 45}, regen = {3, 6, 9, 12, 15} },
    ["ugl4001"] = { kills = {25, 50, 75, 100, 125}, regen = {10, 20, 30, 40, 50} },
    ["ugl4002"] = { kills = {50, 100, 150, 200, 250}, regen = {10, 20, 30, 40, 50} },
    ["ugl4011"] = { kills = {50, 100, 150, 200, 250}, regen = {10, 20, 30, 40, 50} },
    ["ugl5001"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["ugl5002"] = { kills = {3, 6, 9, 12, 15}, regen = {2, 4, 6, 8, 10} },
    ["ugl5003"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["ugl5004"] = { kills = {30, 60, 90, 120, 150}, regen = {5, 10, 15, 20, 25} },
    ["ugn1001"] = { kills = {8, 16, 24, 32, 40}, regen = {1, 2, 3, 4, 5} },
    ["ugn1002"] = { kills = {4, 8, 12, 16, 20}, regen = {1, 2, 3, 4, 5} },
    ["ugn2001"] = { kills = {16, 32, 48, 64, 80}, regen = {5, 10, 15, 20, 25} },
    ["ugn2002"] = { kills = {16, 32, 48, 64, 80}, regen = {2, 4, 6, 8, 10} },
    ["ugn3001"] = { kills = {32, 64, 96, 128, 160}, regen = {5, 10, 15, 20, 25} },
    ["ugn3003"] = { kills = {32, 64, 96, 128, 160}, regen = {5, 10, 15, 20, 25} },
    ["ugn3004"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["ugn5001"] = { kills = {8, 16, 24, 32, 40}, regen = {2, 4, 6, 8, 10} },
    ["ugs1001"] = { kills = {6, 12, 18, 24, 30}, regen = {1, 2, 3, 4, 5} },
    ["ugs1201"] = { kills = {4, 8, 12, 16, 20}, regen = {1, 2, 3, 4, 5} },
    ["ugs2001"] = { kills = {12, 24, 36, 48, 60}, regen = {2, 4, 6, 8, 10} },
    ["ugs2101"] = { kills = {15, 30, 45, 60, 75}, regen = {2, 4, 6, 8, 10} },
    ["ugs2102"] = { kills = {9, 18, 27, 36, 45}, regen = {2, 4, 6, 8, 10} },
    ["ugs2201"] = { kills = {8, 16, 24, 32, 40}, regen = {2, 4, 6, 8, 10} },
    ["ugs3101"] = { kills = {30, 60, 90, 120, 150}, regen = {3, 6, 9, 12, 15} },
    ["ugs3201"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["ugs5005"] = { kills = {6, 12, 18, 24, 30}, regen = {1, 2, 3, 4, 5} },
    ["ugs5006"] = { kills = {12, 24, 36, 48, 60}, regen = {2, 4, 6, 8, 10} },
    ["ugs5007"] = { kills = {30, 60, 90, 120, 150}, regen = {3, 6, 9, 12, 15} },
    ["ugs5027"] = { kills = {18, 36, 54, 72, 90}, regen = {3, 6, 9, 12, 15} },
    ["usa1001"] = { kills = {3, 6, 9, 12, 15}, regen = {1, 2, 3, 4, 5} },
    ["usa1201"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["usa2011"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["usa2101"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["usa2301"] = { kills = {2, 4, 6, 8, 10}, regen = {2, 4, 6, 8, 10} },
    ["usa2502"] = { kills = {3, 6, 9, 12, 15}, regen = {2, 4, 6, 8, 10} },
    ["usa3001"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["usa3201"] = { kills = {6, 12, 18, 24, 30}, regen = {3, 6, 9, 12, 15} },
    ["usa4011"] = { kills = {50, 100, 150, 200, 250}, regen = {15, 30, 45, 60, 75} },
    ["usl0000"] = { kills = {20, 40, 60, 80, 100}, regen = {3, 6, 9, 12, 15} },
    ["usl1001"] = { kills = {3, 6, 9, 12, 15}, regen = {1, 2, 3, 4, 5} },
    ["usl1101"] = { kills = {3, 6, 9, 12, 15}, regen = {1, 2, 3, 4, 5} },
    ["usl1201"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["usl1701"] = { kills = {2, 4, 6, 8, 10}, regen = {1, 2, 3, 4, 5} },
    ["usl2002"] = { kills = {9, 18, 27, 35, 42}, regen = {2, 4, 6, 8, 10} },
    ["usl2101"] = { kills = {3, 6, 9, 12, 15}, regen = {2, 4, 6, 8, 10} },
    ["usl2201"] = { kills = {4, 8, 12, 16, 20}, regen = {2, 4, 6, 8, 10} },
    ["usl2806"] = { kills = {6, 12, 18, 24, 30}, regen = {2, 4, 6, 8, 10} },
    ["usl3001"] = { kills = {9, 18, 27, 36, 45}, regen = {3, 6, 9, 12, 15} },
    ["usl3101"] = { kills = {9, 18, 27, 36, 45}, regen = {3, 6, 9, 12, 15} },
    ["usl3801"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["usl4002"] = { kills = {30, 60, 90, 120, 150}, regen = {5, 10, 15, 20, 25} },
    ["usl4004"] = { kills = {25, 50, 75, 100, 125}, regen = {15, 30, 45, 60, 75} },
    ["usn1001"] = { kills = {8, 16, 24, 32, 40}, regen = {1, 2, 3, 4, 5} },
    ["usn1002"] = { kills = {4, 8, 12, 16, 20}, regen = {1, 2, 3, 4, 5} },
    ["usn2001"] = { kills = {16, 32, 48, 64, 80}, regen = {5, 10, 15, 20, 25} },
    ["usn2002"] = { kills = {16, 32, 48, 64, 80}, regen = {2, 4, 6, 8, 10} },
    ["usn3001"] = { kills = {32, 64, 96, 128, 160}, regen = {5, 10, 15, 20, 25} },
    ["usn3003"] = { kills = {32, 64, 96, 128, 160}, regen = {5, 10, 15, 20, 25} },
    ["usn3004"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["uss1001"] = { kills = {6, 12, 18, 24, 32}, regen = {1, 2, 3, 4, 5} },
    ["uss1201"] = { kills = {4, 8, 12, 16, 20}, regen = {1, 2, 3, 4, 5} },
    ["uss1301"] = { kills = {6, 12, 18, 24, 30}, regen = {1, 2, 3, 4, 5} },
    ["uss2001"] = { kills = {12, 24, 36, 48, 60}, regen = {2, 4, 6, 8, 10} },
    ["uss2101"] = { kills = {15, 30, 45, 60, 75}, regen = {2, 4, 6, 8, 10} },
    ["uss2102"] = { kills = {9, 18, 27, 36, 45}, regen = {2, 4, 6, 8, 10} },
    ["uss2201"] = { kills = {8, 16, 24, 32, 40}, regen = {2, 4, 6, 8, 10} },
    ["uss2301"] = { kills = {12, 24, 36, 48, 60}, regen = {2, 4, 6, 8, 10} },
    ["uss3101"] = { kills = {30, 60, 90, 120, 150}, regen = {3, 6, 9, 12, 15} },
    ["uss3102"] = { kills = {30, 60, 90, 120, 150}, regen = {3, 6, 9, 12, 15} },
    ["uss3201"] = { kills = {12, 24, 36, 48, 60}, regen = {3, 6, 9, 12, 15} },
    ["uss4102"] = { kills = {50, 100, 150, 200, 250}, regen = {10, 20, 30, 40, 50} },
}
local SCO_VETERANCY_DEFAULT = { kills = { 25, 100, 250, 500, 1000 }, regen = { 2, 4, 6, 8, 10 } }
local function SCO_GetVeterancyRule(tpId)
    return SCO_VETERANCY_RULES[tpId] or SCO_VETERANCY_DEFAULT
end

local SCO_StockUnitInit = HostUnit.__init
function HostUnit:__init(...)
    SCO_StockUnitInit(self, ...)

    local health = self.tp.defence and self.tp.defence.health or nil
    self.scoVeterancyBaseMaxHealth = (health and health.max) or self:GetMaxHealth()
    self.scoVeterancyBaseRegen = (health and health.regen) or self:GetHealthRegen()
    self.scoVeterancyKills = 0
    self.scoVeterancyLevel = 0
end

function HostUnit:SCOApplyVeterancyLevel(level)
    local rule = SCO_GetVeterancyRule(self.tpId)
    local oldMaxHealth = self:GetMaxHealth()
    local newMaxHealth = (self.scoVeterancyBaseMaxHealth or oldMaxHealth) * (1 + level * 0.1)

    self:SetMaxHealth(newMaxHealth)

    local currentHealth = self:GetHealth()
    if newMaxHealth > oldMaxHealth then
        self:SetHealth(math.min(currentHealth + newMaxHealth - oldMaxHealth, newMaxHealth))
    else
        self:SetHealth(math.min(currentHealth, newMaxHealth))
    end

    self:SetHealthRegen((self.scoVeterancyBaseRegen or 0) + (rule.regen[level] or 0))
end

function HostUnit:SCOSetVeterancyKills(kills, synchronize)
    kills = math.max(0, math.floor(kills or 0))
    self.scoVeterancyKills = kills

    local rule = SCO_GetVeterancyRule(self.tpId)
    local desiredLevel = 0
    while desiredLevel < #rule.kills and kills >= rule.kills[desiredLevel + 1] do
        desiredLevel = desiredLevel + 1
    end

    local currentLevel = self.scoVeterancyLevel or 0
    if desiredLevel > currentLevel then
        while currentLevel < desiredLevel do
            currentLevel = currentLevel + 1
            self.scoVeterancyLevel = currentLevel
            self:SCOApplyVeterancyLevel(currentLevel)
        end
    elseif desiredLevel ~= currentLevel then
        self.scoVeterancyLevel = desiredLevel
        self:SCOApplyVeterancyLevel(desiredLevel)
    end

    if synchronize then
        UnitCommands.SetVeterancyCommand.Send(self.id, kills)
    end
end

function HostUnit:SCOOnKilledUnit(unitKilled)
    self:SCOSetVeterancyKills((self.scoVeterancyKills or 0) + 1, true)
end

local SCO_StockUnitDestroy = HostUnit.Destroy
function HostUnit:Destroy(overkillRatio, destroyType, instigator)
    -- This deliberately matches Forged Alliance's Unit.OnKilled rule: any
    -- supplied Unit instigator receives one KILLS stat, with no enemy,
    -- completion, or alive-state filter added here.
    if self.canBeKilled and not self.dead and instigator and instigator.entityType == "unit" then
        instigator:SCOOnKilledUnit(self)
    end

    return SCO_StockUnitDestroy(self, overkillRatio, destroyType)
end

function HostUnit:TakeDamage(amount, destroyType, instigator)
    if not self.canTakeDamage then
        return
    elseif self.dead then
        return
    end

    local finalDamage = self:ProcessDamage(amount)
    self:DoCallbacks("OnDamaged", finalDamage)

    local currentHP = self:GetHealth()
    local newHP = currentHP - finalDamage

    if newHP > 0 then
        self:SetHealth(newHP)
    else
        local maxHP = self:GetMaxHealth()
        local overkillRatio = -newHP / maxHP

        self:SetHealth(0)

        self:Destroy(overkillRatio, destroyType, instigator)
    end
end

local SCO_StockUnitOnEndUpgrade = HostUnit.OnEndUpgrade
function HostUnit:OnEndUpgrade(upgrader)
    SCO_StockUnitOnEndUpgrade(self, upgrader)

    if self:IsCompleted() and not upgrader.dead then
        self:SCOSetVeterancyKills(upgrader.scoVeterancyKills or 0, true)
    end
end

-- SCOM commander shield entity-name compatibility 1.0.0

-- Supreme Commander Overhaul locomotion death guard 1.1.0
-- Quiesce imported weapons before stock muzzle deletion.
-- SCOM aircraft crash momentum 1.0.0
-- Native SimVelocity is the consecutive simulation-position delta / tick time.
local function SCO_AircraftCrashIsAirborne(unit)
    if unit.isAirborne == false or not (unit.tp and unit.tp.movement)
        or not unit:HasTags(Tags.AIR) then return false end
    if Tags.NAVAL and unit:HasTags(Tags.NAVAL) then return false end
    if Tags.ORBITAL and unit:HasTags(Tags.ORBITAL) then return false end
    return true
end

local function SCO_AircraftCrashFinite(value)
    return type(value) == "number" and value == value
        and value > -math.huge and value < math.huge
end

local function SCO_AircraftCrashReadPose(unit)
    local result, position = Engine.GetGlobalEntityWorldPosition(unit.id)
    if result ~= EngineErrorCode.Success or not position
        or not SCO_AircraftCrashFinite(position.x)
        or not SCO_AircraftCrashFinite(position.y)
        or not SCO_AircraftCrashFinite(position.z) then return end
    local tick = Engine.GetSimulationTick()
    if not SCO_AircraftCrashFinite(tick) or tick < 0 or tick % 1 ~= 0 then return end
    return position, tick
end

local function SCO_AircraftCrashRecordMotion(unit)
    if unit.dead or unit.deleted or not SCO_AircraftCrashIsAirborne(unit) then
        unit.scoAircraftCrashSamples = nil
        return
    end
    local position, tick = SCO_AircraftCrashReadPose(unit)
    if not position then return end
    local sample = unit.scoAircraftCrashSamples
    if sample and sample.tick == tick then return end
    if not sample then
        sample = {}
        unit.scoAircraftCrashSamples = sample
    end
    if sample.tick == tick - 1 then
        sample.previousTick, sample.previousX, sample.previousY, sample.previousZ =
            sample.tick, sample.x, sample.y, sample.z
    else
        sample.previousTick, sample.previousX, sample.previousY, sample.previousZ = nil, nil, nil, nil
    end
    sample.tick, sample.x, sample.y, sample.z = tick, position.x, position.y, position.z
end

local function SCO_AircraftCrashCaptureVelocity(unit)
    if unit.dead or unit.deleted or not SCO_AircraftCrashIsAirborne(unit) then return end
    local dt = Constants.TickTimeStep
    if not SCO_AircraftCrashFinite(dt) or dt <= 0 then return end
    local position, tick = SCO_AircraftCrashReadPose(unit)
    local sample = unit.scoAircraftCrashSamples
    local x, y, z
    if position and sample then
        if sample.tick == tick - 1 then
            x, y, z = sample.x, sample.y, sample.z
        elseif sample.tick == tick and sample.previousTick == tick - 1 then
            x, y, z = sample.previousX, sample.previousY, sample.previousZ
        end
    end
    if x ~= nil then
        local vx, vy, vz = (position.x - x) / dt, (position.y - y) / dt, (position.z - z) / dt
        if SCO_AircraftCrashFinite(vx) and SCO_AircraftCrashFinite(vy)
            and SCO_AircraftCrashFinite(vz) then
            unit.scoAircraftCrashVelocity = EngineClasses.float3(vx, vy, vz)
            return
        end
    end
    -- No consecutive live pose: retain native signed horizontal travel, never nose yaw.
    local speedResult, speedPerTick = Engine.GetMovementCurrentSpeed(unit.id)
    local headingResult, headingDegrees = Engine.GetMovementHeadingDegrees(unit.id)
    if speedResult == EngineErrorCode.Success and headingResult == EngineErrorCode.Success
        and SCO_AircraftCrashFinite(speedPerTick) and SCO_AircraftCrashFinite(headingDegrees) then
        local speed, heading = speedPerTick / dt, math.rad(headingDegrees)
        unit.scoAircraftCrashVelocity = EngineClasses.float3(
            math.sin(heading) * speed, 0, math.cos(heading) * speed)
    end
end

-- These two flying engineer classes inherit the ground-only base wreck dispatch.
local SCO_AircraftCrashPodSpawnWreckage = HostUnit.OnSpawnWreckage
function HostUnit:OnSpawnWreckage(overkillRatio)
    if (self.tpId == "uea5002" or self.tpId == "uea5011")
        and SCO_AircraftCrashIsAirborne(self) then
        return Import("host/props/wreckCrash.lua").StartWreckCrash(self, overkillRatio, false)
    end
    return SCO_AircraftCrashPodSpawnWreckage(self, overkillRatio)
end

local SCO_IdleResetOnDestroy = HostUnit.OnDestroy

function HostUnit:OnDestroy(destroyType)
    SCO_AircraftCrashCaptureVelocity(self)

    local delayedSourceDeath = self.tpId == "ugl3001" or self.tpId == "uel3001" or self.tpId == "uel1002" or self.tpId == "uel3401"
    -- Imported death animations may retain the unit until their final frame.
    for _, tag in ipairs(self.tp and self.tp.tags or {}) do
        if tag == "SCFA_ALLUNITS" then delayedSourceDeath = true; break end
    end
    if delayedSourceDeath then
        for _, weapon in ipairs(self.weapons or {}) do
            if weapon:IsEnabled() then weapon:SetEnabled(false) end
            weapon:SetAimTarget(nil)
        end
    end
    local result = SCO_IdleResetOnDestroy(self, destroyType)
    if delayedSourceDeath then self.weapons = {} end
    return result
end

-- A stopped transition must not overwrite a delayed source death clip.
local SCO_IdleResetUpdateAnimations = HostUnit.UpdateAnimations
function HostUnit:UpdateAnimations()
    SCO_AircraftCrashRecordMotion(self)
    local additions = self.tp and self.tp.additions

    if self.dead and additions and additions.scoIdleResetLocomotion then
        return
    end
    if not (self.tp and self.tp.movement and self.tp.visuals and self.tp.visuals.animations and self.tp.visuals.animations.run) then return end
    return SCO_IdleResetUpdateAnimations(self)
end
-- SCOM Field Fixes 1.0.8 - host-authoritative strategic silo lifecycle.
local SCOFieldFixStrategicSiloHostEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOFieldFixStrategicSiloHostMarker = rawget(
    SCOFieldFixStrategicSiloHostEnvironment,
    "SCO_FieldFixStrategicSiloHostInstalled")
if SCOFieldFixStrategicSiloHostMarker ~= nil
    and SCOFieldFixStrategicSiloHostMarker ~= "1.0.8"
then
    error("Unsupported SCOM strategic silo host marker "
        .. tostring(SCOFieldFixStrategicSiloHostMarker))
end
if SCOFieldFixStrategicSiloHostMarker == nil then

    local SCOResourceEntity = ResourceEntity
    if SCOResourceEntity == nil then
        SCOResourceEntity = Import("host/systems/resourceEntity.lua").ResourceEntity
    end
    local SCOCommands = Import("common/commands/definitions/projectiles.lua")
    local SCOMapUtils = Import("common/mapUtils.lua")
    local SCOLobby = Import("common/lobby.lua")
    if type(SCOLobby) ~= "table"
        or type(SCOLobby.ArmyToPlayer) ~= "table"
    then
        error("SCOM strategic silo host lifecycle could not resolve lobby ownership")
    end
    local SCOProjectile = Import(
        "host/projectiles/projectilesClasses/projectilesBaseClass.lua").HostProjectile
    local SCOProjectiles = __Entities.Projectiles
    local SCOCaptureHandoff = nil
    local SCOAnimationSampleSentinel = -10000
    local SCOApocalypseConstructionOpenDuration = 16.6666660308838
    local SCOAdvanceNukeLaunch

    local SCOExpectedSilos = {
        ues3102 = { muzzle = "Nuke_Spawner_01", projectile = "psn001", maxAmmo = 5,
            rangeMin = 0, rangeMax = 20000, alloys = 12000, energy = 1350000,
            innerDamage = 70000 },
        ugs3102 = { muzzle = "Nuke_Spawner_01", projectile = "psn002", maxAmmo = 5,
            rangeMin = 0, rangeMax = 20000, alloys = 12000, energy = 1350000,
            innerDamage = 70000 },
        ucs3102 = { muzzle = "Turret_Muzzle01", projectile = "psn003", maxAmmo = 5,
            rangeMin = 0, rangeMax = 20000, alloys = 12000, energy = 1350000,
            innerDamage = 140000, innerRadius = 60,
            outerDamage = 1000, outerRadius = 80,
            nukeVersion = "1.1.0", impactProfile = "ApocalypseAeon2x",
            creativeSpawnAmmo = 5,
            apocalypseFlight = {
                version = "4.0.0",
                route = "VerticalArcLevelArcDown",
                sourceProjectile = "AIFQuantumWarhead01",
                sourceArchiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
                sourceBlueprintSha256 = "7098e71f9e65f3780accaaf72b4936836780aeabf82d1543b67b68b9d22cecf1",
                sourceScriptSha256 = "7a05f1b44a4050aa33a86d7753f1bb161a2af55db401dd2429426a67b3462a0e",
                sourceUniformScale = 0.2,
                sourceInitialSpeed = 0, sourceAcceleration = 3,
                sourceMaximumSpeed = 40, sourcePreTrackSeconds = 7.5,
                cruiseHeight = 60, turnRadius = 12,
                ascentTerminalSpeed = 18,
                cruiseSpeed = 27, descentSpeed = 27,
                arrivalTolerance = 0.01,
            },
            launchAnimation = {
                key = "fa_deploy", packedKey = "fa_packed",
                duration = 10, rate = 1, repackTimeout = 2.8,
            } },
        uss3102 = { muzzle = "Projectile01", projectile = "psn004", maxAmmo = 5,
            rangeMin = 0, rangeMax = 20000, alloys = 12000, energy = 1350000,
            innerDamage = 70000 },
        ucl4001 = { muzzle = "Muzzle_05", projectile = "psn005", maxAmmo = 3,
            rangeMin = 128, rangeMax = 1024, alloys = 15000, energy = 1800000,
            innerDamage = 75000 },
    }

    local function SCOFinite(value)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
    end

    local function SCOArmyClientId(army)
        local player = army
            and type(army.id) == "number"
            and SCOLobby.ArmyToPlayer[army.id]
        return type(player) == "table" and player.clientID or nil
    end

    local function SCORequireEqual(actual, expected, path, unit)
        if actual ~= expected then
            error("SCOM strategic silo [" .. tostring(unit.tpId) .. "] invalid "
                .. path .. ": expected " .. tostring(expected)
                .. ", got " .. tostring(actual), 3)
        end
    end

    local function SCOGetContract(unit, required)
        local expected = SCOExpectedSilos[unit.tpId]
        local additions = unit.tp and unit.tp.additions
        local contract = additions and additions.scoStrategicSilo
        -- The source UEF silo now owns its stockpile through the tactical
        -- controller. Do not require the retired native-silo contract as well.
        local sourceSilo = additions and additions.scoTactical
        if unit.tpId == "ues3102" and contract == nil and sourceSilo
            and sourceSilo.sourceId == "UEB2305" and sourceSilo.version == "1.0.0"
            and sourceSilo.sourceStockpile == true and sourceSilo.role == "launcher"
        then
            return nil
        end
        if not expected then
            if contract ~= nil then
                error("SCOM strategic silo contract attached to non-whitelisted unit "
                    .. tostring(unit.tpId), 3)
            end
            return nil
        end
        if contract == nil then
            if required then
                error("SCOM strategic silo contract missing for " .. unit.tpId, 3)
            end
            return nil
        end
        if type(contract) ~= "table" then
            error("SCOM strategic silo contract must be a table for " .. unit.tpId, 3)
        end
        SCORequireEqual(contract.version, "1.0.0", "version", unit)
        SCORequireEqual(contract.initialAmmo, 0, "initialAmmo", unit)
        SCORequireEqual(contract.creativeSpawnAmmo, expected.creativeSpawnAmmo,
            "creativeSpawnAmmo", unit)
        SCORequireEqual(contract.maxAmmo, expected.maxAmmo, "maxAmmo", unit)
        SCORequireEqual(contract.defaultAutoBuild, true, "defaultAutoBuild", unit)
        SCORequireEqual(contract.buildPower, 1080, "buildPower", unit)
        SCORequireEqual(contract.buildTime, 324000, "buildTime", unit)
        SCORequireEqual(contract.muzzle, expected.muzzle, "muzzle", unit)
        SCORequireEqual(contract.projectileTemplate, expected.projectile,
            "projectileTemplate", unit)
        SCORequireEqual(contract.projectileLifetime, 600, "projectileLifetime", unit)
        SCORequireEqual(contract.initialProjectileSpeed, 1,
            "initialProjectileSpeed", unit)
        SCORequireEqual(contract.terrainClearance, 0.05,
            "terrainClearance", unit)
        SCORequireEqual(contract.rangeMin, expected.rangeMin, "rangeMin", unit)
        SCORequireEqual(contract.rangeMax, expected.rangeMax, "rangeMax", unit)
        SCORequireEqual(contract.damageFriendly, true, "damageFriendly", unit)
        SCORequireEqual(contract.buildOrder, "ManualFire1", "buildOrder", unit)
        SCORequireEqual(contract.launchOrder, "ManualFire2", "launchOrder", unit)
        if expected.launchAnimation then
            if type(contract.launchAnimation) ~= "table" then
                error("SCOM strategic silo launch animation is missing for "
                    .. unit.tpId, 3)
            end
            for key, value in pairs(expected.launchAnimation) do
                SCORequireEqual(contract.launchAnimation[key], value,
                    "launchAnimation." .. key, unit)
            end
            local deploy = additions.faAnimationClosureWeaponDeploy
            local animations = unit.tp.visuals and unit.tp.visuals.animations
            local launch = animations and animations[contract.launchAnimation.key]
            local packed = animations
                and animations[contract.launchAnimation.packedKey]
            if type(deploy) ~= "table"
                or deploy.deployAnimationKey ~= contract.launchAnimation.key
                or deploy.packedAnimationKey ~= contract.launchAnimation.packedKey
                or type(deploy.constructionOpen) ~= "table"
                or deploy.constructionOpen.animationKey
                    ~= "fa_construction_open"
                or deploy.constructionOpen.authoredDurationSeconds
                    ~= SCOApocalypseConstructionOpenDuration
                or deploy.constructionOpen.authoredRate ~= 1
                or deploy.authoredDurationSeconds
                    ~= contract.launchAnimation.duration
                or deploy.authoredRate ~= contract.launchAnimation.rate
                or deploy.repackTimeoutSeconds
                    ~= contract.launchAnimation.repackTimeout
                or type(launch) ~= "table"
                or not launch.id
                or type(packed) ~= "table"
                or not packed.id
            then
                error("SCOM strategic silo source launch animation drifted for "
                    .. unit.tpId, 3)
            end
        else
            SCORequireEqual(contract.launchAnimation, nil,
                "launchAnimation", unit)
        end
        if type(contract.cost) ~= "table"
            or type(contract.innerDamage) ~= "table"
            or type(contract.outerDamage) ~= "table"
        then
            error("SCOM strategic silo nested contract is malformed for " .. unit.tpId, 3)
        end
        SCORequireEqual(contract.cost.alloys, expected.alloys, "cost.alloys", unit)
        SCORequireEqual(contract.cost.energy, expected.energy, "cost.energy", unit)
        SCORequireEqual(contract.innerDamage.amount, expected.innerDamage,
            "innerDamage.amount", unit)
        SCORequireEqual(contract.innerDamage.radius, expected.innerRadius or 30,
            "innerDamage.radius", unit)
        SCORequireEqual(contract.innerDamage.ticks, 24, "innerDamage.ticks", unit)
        SCORequireEqual(contract.innerDamage.totalTime, 0,
            "innerDamage.totalTime", unit)
        SCORequireEqual(contract.outerDamage.amount, expected.outerDamage or 500,
            "outerDamage.amount", unit)
        SCORequireEqual(contract.outerDamage.radius, expected.outerRadius or 40,
            "outerDamage.radius", unit)
        SCORequireEqual(contract.outerDamage.ticks, 20, "outerDamage.ticks", unit)
        SCORequireEqual(contract.outerDamage.totalTime, 0,
            "outerDamage.totalTime", unit)
        local flight = contract.apocalypseFlight
        if expected.apocalypseFlight then
            if type(flight) ~= "table" then
                error("SCOM strategic silo Apocalypse flight contract is malformed for "
                    .. unit.tpId, 3)
            end
            local expectedFlight = expected.apocalypseFlight
            SCORequireEqual(flight.version, expectedFlight.version,
                "apocalypseFlight.version", unit)
            SCORequireEqual(flight.route, expectedFlight.route,
                "apocalypseFlight.route", unit)
            SCORequireEqual(flight.sourceProjectile,
                expectedFlight.sourceProjectile,
                "apocalypseFlight.sourceProjectile", unit)
            SCORequireEqual(flight.sourceArchiveSha256,
                expectedFlight.sourceArchiveSha256,
                "apocalypseFlight.sourceArchiveSha256", unit)
            SCORequireEqual(flight.sourceBlueprintSha256,
                expectedFlight.sourceBlueprintSha256,
                "apocalypseFlight.sourceBlueprintSha256", unit)
            SCORequireEqual(flight.sourceScriptSha256,
                expectedFlight.sourceScriptSha256,
                "apocalypseFlight.sourceScriptSha256", unit)
            SCORequireEqual(flight.sourceUniformScale,
                expectedFlight.sourceUniformScale,
                "apocalypseFlight.sourceUniformScale", unit)
            SCORequireEqual(flight.sourceInitialSpeed,
                expectedFlight.sourceInitialSpeed,
                "apocalypseFlight.sourceInitialSpeed", unit)
            SCORequireEqual(flight.sourceAcceleration,
                expectedFlight.sourceAcceleration,
                "apocalypseFlight.sourceAcceleration", unit)
            SCORequireEqual(flight.sourceMaximumSpeed,
                expectedFlight.sourceMaximumSpeed,
                "apocalypseFlight.sourceMaximumSpeed", unit)
            SCORequireEqual(flight.sourcePreTrackSeconds,
                expectedFlight.sourcePreTrackSeconds,
                "apocalypseFlight.sourcePreTrackSeconds", unit)
            SCORequireEqual(flight.cruiseHeight, expectedFlight.cruiseHeight,
                "apocalypseFlight.cruiseHeight", unit)
            SCORequireEqual(flight.turnRadius, expectedFlight.turnRadius,
                "apocalypseFlight.turnRadius", unit)
            SCORequireEqual(flight.ascentTerminalSpeed,
                expectedFlight.ascentTerminalSpeed,
                "apocalypseFlight.ascentTerminalSpeed", unit)
            SCORequireEqual(flight.cruiseSpeed, expectedFlight.cruiseSpeed,
                "apocalypseFlight.cruiseSpeed", unit)
            SCORequireEqual(flight.descentSpeed, expectedFlight.descentSpeed,
                "apocalypseFlight.descentSpeed", unit)
            SCORequireEqual(flight.arrivalTolerance,
                expectedFlight.arrivalTolerance,
                "apocalypseFlight.arrivalTolerance", unit)
            local tunedAscentSeconds =
                (flight.ascentTerminalSpeed - flight.sourceInitialSpeed)
                / flight.sourceAcceleration
            if tunedAscentSeconds <= 0
                or tunedAscentSeconds > flight.sourcePreTrackSeconds
                or flight.cruiseSpeed > flight.sourceMaximumSpeed
                or flight.descentSpeed > flight.sourceMaximumSpeed
            then
                error("SCOM strategic silo has an invalid tuned Apocalypse speed profile for "
                    .. unit.tpId, 3)
            end
            local tunedAscentDistance = flight.sourceInitialSpeed
                    * tunedAscentSeconds
                + 0.5 * flight.sourceAcceleration
                    * tunedAscentSeconds
                    * tunedAscentSeconds
            if flight.cruiseHeight <= tunedAscentDistance
                or flight.turnRadius <= 0
                or flight.turnRadius >= flight.cruiseHeight
            then
                error("SCOM strategic silo has an invalid rounded Apocalypse route for "
                    .. unit.tpId, 3)
            end
        else
            SCORequireEqual(flight, nil, "apocalypseFlight", unit)
        end
        if not unit.construction
            or unit.construction.buildPower ~= contract.buildPower
        then
            error("SCOM strategic silo requires exact host construction build power for "
                .. unit.tpId, 3)
        end
        return contract
    end

    local function SCOCopyState(unit)
        local state = unit.scoStrategicSilo
        if not state then return nil end
        return {
            unitId = unit.id,
            tpId = unit.tpId,
            ammo = state.ammo,
            maxAmmo = state.contract.maxAmmo,
            queued = state.queued,
            work = state.work,
            buildTime = state.contract.buildTime,
            autoBuild = state.autoBuild,
            building = state.building,
            paused = unit:GetPause() == true,
            launchPending = state.launch ~= nil,
            animationReady = state.animationReady,
            sequence = state.sequence,
        }
    end

    local function SCOEmitState(unit)
        local state = unit.scoStrategicSilo
        if not state then return end
        state.sequence = state.sequence + 1
        local listener = _G.SCO_FieldFixStrategicSiloStateChanged
        if type(listener) == "function" then
            listener(unit, SCOCopyState(unit))
        end
    end

    local function SCOSetDrainEnabled(unit, enabled)
        local state = unit.scoStrategicSilo
        local entity = state and state.resourceEntity
        if not entity then return end
        if enabled then
            if not entity.enabled then
                entity:SetEnabled(true)
                entity:RecalculateBuildDrain()
                unit:UpdateUIValues()
            end
        else
            if entity.enabled then
                entity:SetEnabled(false)
                -- UpdateUIValues ignores ResourceEntity.enabled. Clear the detached
                -- outcome so an idle or paused silo does not advertise a false drain.
                entity.outcome = {}
                entity.prevOutcome = {}
                unit:UpdateUIValues()
            end
            -- ResourceEntity retains the last economy result while disabled.
            -- Never let a later re-enable consume that stale paid multiplier.
            entity.productionMultiplier = 0
        end
    end

    local function SCOCreateResourceEntity(unit)
        local state = unit.scoStrategicSilo
        local contract = state.contract
        local entity = SCOResourceEntity(
            unit.army.id, unit.id, "construction", nil, nil, false)
        entity:SetCost(contract.cost)
        entity:SetBuildTime(contract.buildTime)

        -- AddBuilder recalculates the drain, so register briefly before calling it.
        -- This avoids ResourceEntity trying to update an unregistered economy entry.
        entity:SetEnabled(true)
        entity:AddBuilder(unit)
        entity:SetEnabled(false)
        entity.productionMultiplier = 0
        entity.outcome = {}
        entity.prevOutcome = {}

        state.resourceEntity = entity
        unit.resourceEntities.scoNukeAmmo = entity
    end

    local function SCOReleaseResourceEntity(unit)
        local state = unit.scoStrategicSilo
        local entity = state and state.resourceEntity
        if not entity then return end
        if entity.enabled then
            entity:SetEnabled(false)
        end
        entity.productionMultiplier = 0
        if unit.resourceEntities.scoNukeAmmo == entity then
            unit.resourceEntities.scoNukeAmmo = nil
        end
        state.resourceEntity = nil
    end

    local function SCOStartNextMissile(unit)
        local state = unit.scoStrategicSilo
        if state.building or state.ammo >= state.contract.maxAmmo then
            return false
        end
        if state.queued > 0 then
            state.activeConsumesQueue = true
        elseif state.autoBuild then
            state.activeConsumesQueue = false
        else
            return false
        end
        state.building = true
        state.work = 0
        state.syncTicks = 0
        SCOSetDrainEnabled(unit, not unit:GetPause())
        SCOEmitState(unit)
        return true
    end

    local function SCOEnsureSiloThread(unit)
        local state = unit.scoStrategicSilo
        if not state
            or state.thread
            or unit.dead
            or not unit:IsCompleted()
        then
            return false
        end
        state.thread = unit:NewThread(unit.SCOStrategicSiloThread)
        SCOEmitState(unit)
        return true
    end

    local function SCOReservedAmmo(state)
        local autoActive = state.building and not state.activeConsumesQueue and 1 or 0
        return state.ammo + state.queued + autoActive
    end

    local function SCOAnimation(unit, key)
        local animations = unit.tp
            and unit.tp.visuals
            and unit.tp.visuals.animations
        return animations and animations[key]
    end

    local function SCOSampleLaunchAnimation(unit, key, seconds)
        local animation = SCOAnimation(unit, key)
        if not animation or not animation.id then
            error(unit.tpId .. " requires strategic launch animation "
                .. tostring(key), 2)
        end
        Engine.PlayAnimation(
            unit.id,
            animation.id,
            SCOAnimationSampleSentinel + seconds)
    end

    local function SCOCancelNukeLaunch(unit)
        local state = unit.scoStrategicSilo
        local launch = state and state.launch
        if not launch then return false end
        state.launch = nil
        local config = state.contract.launchAnimation
        if config and not unit.dead then
            local packed = SCOAnimation(unit, config.packedKey)
            if not packed or not packed.id then
                error(unit.tpId .. " requires strategic packed animation ", 2)
            end
            Engine.PlayAnimation(unit.id, packed.id, 0.1)
        end
        return true
    end

    local function SCOApplyCaptureHandoff(unit)
        local handoff = SCOCaptureHandoff
        local state = unit.scoStrategicSilo
        if not handoff
            or handoff.consumed
            or not state
            or handoff.tpId ~= unit.tpId
            or not unit.army
            or handoff.armyId ~= unit.army.id
        then
            return false
        end
        state.ammo = math.min(handoff.ammo, state.contract.maxAmmo)
        handoff.consumed = true
        return true
    end

    function HostUnit:SCOGetStrategicSiloState()
        return SCOCopyState(self)
    end

    function HostUnit:GetNukeSiloAmmoCount()
        return self.scoStrategicSilo and self.scoStrategicSilo.ammo or 0
    end

    function HostUnit:SCOCanClientControlStrategicSilo(clientId)
        return type(clientId) == "number"
            and self.scoStrategicSilo ~= nil
            and not self.dead
            and self:IsCompleted()
            and self.army ~= nil
            and SCOArmyClientId(self.army) == clientId
    end

    function HostUnit:SCOQueueNuke(amount)
        local state = self.scoStrategicSilo
        if not state or self.dead or not self:IsCompleted() then
            return false, 0
        end
        if type(amount) ~= "number" or amount ~= math.floor(amount) or amount < 1 then
            return false, 0
        end
        amount = math.min(amount, state.contract.maxAmmo)
        local available = math.max(state.contract.maxAmmo - SCOReservedAmmo(state), 0)
        local accepted = math.min(amount, available)
        if accepted <= 0 then return false, 0 end
        state.queued = state.queued + accepted
        SCOStartNextMissile(self)
        SCOEmitState(self)
        return true, accepted
    end

    function HostUnit:SCOSetNukeAutoBuild(enabled)
        local state = self.scoStrategicSilo
        if not state or self.dead or not self:IsCompleted()
            or type(enabled) ~= "boolean"
        then
            return false
        end
        state.autoBuild = enabled
        SCOStartNextMissile(self)
        SCOEmitState(self)
        return true
    end

    function HostUnit:SCOClearNukeQueue()
        local state = self.scoStrategicSilo
        if not state then return false end
        SCOCancelNukeLaunch(self)
        state.queued = 0
        state.autoBuild = false
        state.building = false
        state.activeConsumesQueue = false
        state.work = 0
        SCOSetDrainEnabled(self, false)
        SCOEmitState(self)
        return true
    end

    function HostUnit:SCOTickStrategicSilo()
        local state = self.scoStrategicSilo
        if not state or self.dead or not self:IsCompleted() then return end
        local animationReady = state.contract.launchAnimation == nil
            or self.scoFaAnimationConstructionReady == true
        if state.animationReady ~= animationReady then
            state.animationReady = animationReady
            SCOEmitState(self)
        end
        if state.launch then
            SCOAdvanceNukeLaunch(self)
        end
        if not state.building then
            SCOStartNextMissile(self)
        end
        if not state.building then
            SCOSetDrainEnabled(self, false)
            return
        end
        if self:GetPause() then
            SCOSetDrainEnabled(self, false)
            return
        end

        SCOSetDrainEnabled(self, true)
        local entity = state.resourceEntity
        local increment = entity.buildPower
            * entity.productionMultiplier
            * (entity.userMultiplier or 1)
        if increment <= 0 then return end
        state.work = state.work + increment
        state.syncTicks = state.syncTicks - 1
        if state.work + 0.000001 >= state.contract.buildTime then
            state.work = 0
            state.ammo = math.min(state.ammo + 1, state.contract.maxAmmo)
            if state.activeConsumesQueue then
                state.queued = math.max(state.queued - 1, 0)
            end
            state.activeConsumesQueue = false
            state.building = false
            SCOSetDrainEnabled(self, false)
            SCOEmitState(self)
        elseif state.syncTicks <= 0 then
            state.syncTicks = Constants.TickRate
            SCOEmitState(self)
        end
    end

    function HostUnit:SCOStrategicSiloThread()
        while not self.dead and self.scoStrategicSilo do
            self:SCOTickStrategicSilo()
            WaitTicks(1)
        end
    end

    local function SCOValidateLaunchTarget(unit, targetPosition)
        if type(targetPosition) ~= "table"
            or not SCOFinite(targetPosition.x)
            or not SCOFinite(targetPosition.y)
            or not SCOFinite(targetPosition.z)
        then
            return nil
        end
        -- Client input supplies a convenient terrain hit, but it is not an
        -- authority boundary.  Rebuild the target from host-validated X/Z so
        -- a forged finite Y cannot destabilize homing physics.
        local horizontalPosition = EngineClasses.float3(
            targetPosition.x, 0, targetPosition.z)
        if not SCOMapUtils.IsPositionOnMap(horizontalPosition) then
            return nil
        end
        local origin = unit:GetPosition()
        if not origin
            or not SCOFinite(origin.x)
            or not SCOFinite(origin.z)
        then
            return nil
        end
        local dx = targetPosition.x - origin.x
        local dz = targetPosition.z - origin.z
        local range = math.sqrt(dx * dx + dz * dz)
        local contract = unit.scoStrategicSilo.contract
        if range + 0.000001 < contract.rangeMin
            or range > contract.rangeMax + 0.000001
        then
            return nil
        end
        local terrainResult, terrainY = Engine.SampleTerrainHeight(horizontalPosition)
        if terrainResult ~= EngineErrorCode.Success or not SCOFinite(terrainY) then
            return nil
        end
        return EngineClasses.float3(targetPosition.x, terrainY, targetPosition.z)
    end

    local function SCOValidateProjectileTemplate(unit)
        local state = unit.scoStrategicSilo
        local contract = state.contract
        local expected = SCOExpectedSilos[unit.tpId]
        local template = __Templates.Projectiles[contract.projectileTemplate]
        local additions = template and template.additions
        local nuke = additions and additions.scoStrategicNuke
        if not template or not template.general or not template.general.prefabID
            or template.general.tpId ~= contract.projectileTemplate
            or type(nuke) ~= "table"
            or nuke.version ~= (expected.nukeVersion or "1.0.0")
            or nuke.impactProfile ~= expected.impactProfile
            or nuke.damageFriendly ~= contract.damageFriendly
            or type(nuke.innerDamage) ~= "table"
            or type(nuke.outerDamage) ~= "table"
            or nuke.innerDamage.amount ~= contract.innerDamage.amount
            or nuke.innerDamage.radius ~= contract.innerDamage.radius
            or nuke.innerDamage.ticks ~= contract.innerDamage.ticks
            or nuke.innerDamage.totalTime ~= contract.innerDamage.totalTime
            or nuke.outerDamage.amount ~= contract.outerDamage.amount
            or nuke.outerDamage.radius ~= contract.outerDamage.radius
            or nuke.outerDamage.ticks ~= contract.outerDamage.ticks
            or nuke.outerDamage.totalTime ~= contract.outerDamage.totalTime
        then
            return nil
        end
        local movement = template.movement
        local stages = template.extraStages
        local flight = contract.apocalypseFlight
        if flight then
            if type(movement) ~= "table"
                or movement.acceleration ~= 0
                or movement.alignToVelocity ~= true
                or movement.gravityMultiplier ~= 0
                or movement.rotationSpeed ~= 0
                or movement.speedMax ~= flight.sourceMaximumSpeed
                or movement.type ~= "LeadStaticPosition"
                or stages ~= nil
            then
                return nil
            end
        elseif stages ~= nil then
            return nil
        end
        return template
    end

    local function SCORequireEngineSuccess(result, operation)
        if result ~= EngineErrorCode.Success then
            error(operation .. " failed with engine code " .. tostring(result), 3)
        end
    end

    local function SCOSetApocalypseWaypoint(projectile, position)
        SCORequireEngineSuccess(
            Engine.SetHomingProjectileTargetPosition(projectile.id, position),
            "Apocalypse waypoint")
    end

    local function SCOSetApocalypseMotion(projectile, velocity, up)
        local rotation = Engine.QuaternionLookRotationSafe(velocity, up)
        SCORequireEngineSuccess(
            Engine.SetGlobalEntityLocalRotation(projectile.id, rotation),
            "Apocalypse rotation")
        SCORequireEngineSuccess(
            Engine.SetHomingProjectileVelocity(projectile.id, velocity),
            "Apocalypse velocity")
    end

    local function SCOLogApocalypsePhase(projectile, phase)
        Log("[SCOM Apocalypse Flight] projectile="
            .. tostring(projectile.id.index) .. " phase=" .. phase)
    end

    local function SCOApocalypsePathPhase(route, distance)
        if distance < route.ascentEndDistance then
            return "ascent", route.ascentEndDistance
        end
        if route.turnRadius > 0 and distance < route.curveUpEndDistance then
            return "curve-up", route.curveUpEndDistance
        end
        if distance < route.transitEndDistance then
            return "transit", route.transitEndDistance
        end
        if route.turnRadius > 0 and distance < route.curveDownEndDistance then
            return "curve-down", route.curveDownEndDistance
        end
        if distance < route.totalDistance then
            return "descent", route.totalDistance
        end
        return "terminal", route.totalDistance
    end

    local function SCOApocalypsePathPoint(route, distance)
        distance = math.max(0, math.min(route.totalDistance, distance))
        if distance <= route.ascentEndDistance then
            return EngineClasses.float3(
                route.spawnPosition.x,
                route.spawnPosition.y + distance,
                route.spawnPosition.z)
        end

        local radius = route.turnRadius
        if radius > 0 and distance <= route.curveUpEndDistance then
            local angle = (distance - route.ascentEndDistance) / radius
            local horizontalOffset = radius * (1 - math.cos(angle))
            return EngineClasses.float3(
                route.spawnPosition.x
                    + route.horizontalX * horizontalOffset,
                route.cruiseY - radius + radius * math.sin(angle),
                route.spawnPosition.z
                    + route.horizontalZ * horizontalOffset)
        end

        if distance <= route.transitEndDistance then
            local horizontalOffset = radius
                + distance - route.curveUpEndDistance
            return EngineClasses.float3(
                route.spawnPosition.x
                    + route.horizontalX * horizontalOffset,
                route.cruiseY,
                route.spawnPosition.z
                    + route.horizontalZ * horizontalOffset)
        end

        if radius > 0 and distance <= route.curveDownEndDistance then
            local angle = (distance - route.transitEndDistance) / radius
            local horizontalOffset = route.horizontalDistance
                - radius + radius * math.sin(angle)
            return EngineClasses.float3(
                route.spawnPosition.x
                    + route.horizontalX * horizontalOffset,
                route.cruiseY - radius + radius * math.cos(angle),
                route.spawnPosition.z
                    + route.horizontalZ * horizontalOffset)
        end

        local descentDistance = distance - route.curveDownEndDistance
        return EngineClasses.float3(
            route.targetPosition.x,
            route.cruiseY - radius - descentDistance,
            route.targetPosition.z)
    end

    local function SCOApocalypsePhaseWaypoint(route, phase, phaseEndDistance)
        if phase == "terminal" then
            return route.targetPosition
        end
        return SCOApocalypsePathPoint(route, phaseEndDistance)
    end

    local function SCOSetApocalypsePhase(
        projectile, phase, phaseEndDistance)
        local route = projectile.scoApocalypseFlight
        if route.phase == phase then return end
        route.phase = phase
        SCOSetApocalypseWaypoint(
            projectile,
            SCOApocalypsePhaseWaypoint(route, phase, phaseEndDistance))
        SCOLogApocalypsePhase(projectile, phase)
    end

    local function SCONextApocalypseSpeed(route, phase)
        local speedLimit = route.cruiseSpeed
        if phase == "ascent" or phase == "curve-up" then
            speedLimit = route.ascentTerminalSpeed
        elseif phase == "descent" or phase == "terminal" then
            speedLimit = route.descentSpeed
        end
        speedLimit = math.min(route.sourceMaximumSpeed, speedLimit)

        local startSpeed = route.commandedSpeed
        local step = route.sourceAcceleration * Constants.TickTimeStep
        local endSpeed = startSpeed
        if startSpeed < speedLimit then
            endSpeed = math.min(speedLimit, startSpeed + step)
        elseif startSpeed > speedLimit then
            endSpeed = math.max(speedLimit, startSpeed - step)
        end
        route.commandedSpeed = endSpeed
        route.commandedTicks = route.commandedTicks + 1
        return 0.5 * (startSpeed + endSpeed)
    end

    local function SCOApocalypseMotionUp(route, velocity)
        local magnitude = math.sqrt(
            velocity.x * velocity.x
            + velocity.y * velocity.y
            + velocity.z * velocity.z)
        if magnitude <= 0 then
            error("Apocalypse path produced zero velocity", 3)
        end
        if route.horizontalDistance <= route.arrivalTolerance then
            return EngineClasses.float3(0, 0, 1)
        end

        local forwardX = velocity.x / magnitude
        local forwardY = velocity.y / magnitude
        local forwardZ = velocity.z / magnitude
        local upX = -route.horizontalX * forwardY
        local upY = route.horizontalX * forwardX
            + route.horizontalZ * forwardZ
        local upZ = -route.horizontalZ * forwardY
        local upMagnitude = math.sqrt(upX * upX + upY * upY + upZ * upZ)
        if upMagnitude <= 0 then
            return EngineClasses.float3(0, 0, 1)
        end
        return EngineClasses.float3(
            upX / upMagnitude,
            upY / upMagnitude,
            upZ / upMagnitude)
    end

    local function SCOCommandApocalypsePathStep(projectile, position)
        local route = projectile.scoApocalypseFlight
        local phase, phaseEndDistance = SCOApocalypsePathPhase(
            route, route.distance)
        if phase == "terminal" then
            SCOSetApocalypsePhase(projectile, phase, phaseEndDistance)
            local velocity = EngineClasses.float3(0, -route.descentSpeed, 0)
            SCOSetApocalypseMotion(
                projectile,
                velocity,
                SCOApocalypseMotionUp(route, velocity))
            return
        end

        local speed = SCONextApocalypseSpeed(route, phase)
        local nextDistance = math.min(
            route.totalDistance,
            route.distance + speed * Constants.TickTimeStep)
        local nextPosition = SCOApocalypsePathPoint(route, nextDistance)
        local velocity = EngineClasses.float3(
            (nextPosition.x - position.x) / Constants.TickTimeStep,
            (nextPosition.y - position.y) / Constants.TickTimeStep,
            (nextPosition.z - position.z) / Constants.TickTimeStep)
        route.distance = nextDistance
        local nextPhase, nextPhaseEndDistance = SCOApocalypsePathPhase(
            route, nextDistance)
        SCOSetApocalypsePhase(
            projectile, nextPhase, nextPhaseEndDistance)
        SCOSetApocalypseMotion(
            projectile,
            velocity,
            SCOApocalypseMotionUp(route, velocity))
    end

    local function SCOAdvanceApocalypseFlight(projectile)
        local result, position = Engine.GetGlobalEntityWorldPosition(projectile.id)
        if result ~= EngineErrorCode.Success
            or type(position) ~= "table"
            or not SCOFinite(position.x)
            or not SCOFinite(position.y)
            or not SCOFinite(position.z)
        then
            error("Apocalypse position was unavailable", 2)
        end
        SCOCommandApocalypsePathStep(projectile, position)
    end

    local function SCOUpdateApocalypseProjectile(projectile)
        SCOProjectile.Update(projectile)
        if not projectile.scoApocalypseFlight
            or not Engine.IsValidGlobalID(projectile.id)
        then
            return
        end
        local ok, failure = pcall(SCOAdvanceApocalypseFlight, projectile)
        if ok then return end

        Warn("[SCOM Apocalypse Flight] projectile="
            .. tostring(projectile.id.index)
            .. " aborted reason=" .. tostring(failure))
        projectile.scoApocalypseFlight = nil
        projectile:Delete()
    end

    local function SCOInitializeApocalypseFlight(
        projectile, spawnPosition, targetPosition, contract)
        local cruiseY = math.max(spawnPosition.y, targetPosition.y)
            + contract.cruiseHeight
        local dx = targetPosition.x - spawnPosition.x
        local dz = targetPosition.z - spawnPosition.z
        local horizontalDistance = math.sqrt(dx * dx + dz * dz)
        local horizontalX = 1
        local horizontalZ = 0
        if horizontalDistance > contract.arrivalTolerance then
            horizontalX = dx / horizontalDistance
            horizontalZ = dz / horizontalDistance
        end
        local turnRadius = math.min(
            contract.turnRadius,
            horizontalDistance * 0.5,
            contract.cruiseHeight * 0.5)
        if turnRadius <= contract.arrivalTolerance then
            turnRadius = 0
        end
        local ascentLength = cruiseY - turnRadius - spawnPosition.y
        local curveLength = turnRadius * math.pi * 0.5
        local transitLength = math.max(
            0, horizontalDistance - 2 * turnRadius)
        local descentLength = cruiseY - turnRadius - targetPosition.y
        local curveUpEndDistance = ascentLength + curveLength
        local transitEndDistance = curveUpEndDistance + transitLength
        local curveDownEndDistance = transitEndDistance + curveLength
        projectile.scoApocalypseFlight = {
            phase = nil,
            spawnPosition = EngineClasses.float3(
                spawnPosition.x, spawnPosition.y, spawnPosition.z),
            targetPosition = EngineClasses.float3(
                targetPosition.x, targetPosition.y, targetPosition.z),
            cruiseY = cruiseY,
            horizontalDistance = horizontalDistance,
            horizontalX = horizontalX,
            horizontalZ = horizontalZ,
            turnRadius = turnRadius,
            ascentEndDistance = ascentLength,
            curveUpEndDistance = curveUpEndDistance,
            transitEndDistance = transitEndDistance,
            curveDownEndDistance = curveDownEndDistance,
            totalDistance = curveDownEndDistance + descentLength,
            distance = 0,
            sourceInitialSpeed = contract.sourceInitialSpeed,
            sourceAcceleration = contract.sourceAcceleration,
            sourceMaximumSpeed = contract.sourceMaximumSpeed,
            sourcePreTrackSeconds = contract.sourcePreTrackSeconds,
            commandedSpeed = contract.sourceInitialSpeed,
            commandedTicks = 0,
            ascentTerminalSpeed = contract.ascentTerminalSpeed,
            cruiseSpeed = contract.cruiseSpeed,
            descentSpeed = contract.descentSpeed,
            arrivalTolerance = contract.arrivalTolerance,
        }
        projectile.Update = SCOUpdateApocalypseProjectile

        SCORequireEngineSuccess(
            Engine.SetHomingProjectileTargetType(
                projectile.id, HomingType.TargetPosition),
            "Apocalypse target type")
        SCORequireEngineSuccess(
            Engine.SetHomingProjectileAcceleration(projectile.id, 0),
            "Apocalypse acceleration")
        SCORequireEngineSuccess(
            Engine.SetHomingProjectileMaxSpeed(
                projectile.id, contract.sourceMaximumSpeed),
            "Apocalypse maximum speed")
        SCORequireEngineSuccess(
            Engine.SetHomingProjectileRotationSpeed(projectile.id, 0),
            "Apocalypse rotation speed")
        SCORequireEngineSuccess(
            Engine.SetProjectileGravity(
                projectile.id, EngineClasses.float3(0, 0, 0)),
            "Apocalypse gravity")
        SCOCommandApocalypsePathStep(projectile, spawnPosition)
    end

    local function SCOCommitNukeLaunch(unit, canonicalTargetPosition)
        local state = unit.scoStrategicSilo
        local projectileTemplate = SCOValidateProjectileTemplate(unit)
        if not projectileTemplate then
            return false, "projectile-template"
        end
        local muzzleId = unit:GetBoneId(state.contract.muzzle)
        if not muzzleId or not Engine.IsValidGlobalID(muzzleId) then
            return false, "muzzle"
        end

        local _, muzzlePosition = Engine.GetGlobalEntityWorldPosition(muzzleId)
        local _, muzzleRotation = Engine.GetGlobalEntityWorldRotation(muzzleId)
        if not muzzlePosition or not muzzleRotation
            or not SCOFinite(muzzlePosition.x)
            or not SCOFinite(muzzlePosition.y)
            or not SCOFinite(muzzlePosition.z)
        then
            return false, "muzzle-transform"
        end
        local terrainResult, terrainY = Engine.SampleTerrainHeight(muzzlePosition)
        if terrainResult ~= EngineErrorCode.Success or not SCOFinite(terrainY) then
            return false, "terrain"
        end
        -- Some imported launcher muzzles rest below Sanctuary terrain, and two
        -- others begin inside their source collider. The collision appendix
        -- ignores only the exact versioned source unit; this small vertical
        -- clearance keeps the projectile root itself above terrain.
        local spawnPosition = EngineClasses.float3(
            muzzlePosition.x,
            math.max(muzzlePosition.y, terrainY + state.contract.terrainClearance),
            muzzlePosition.z)
        local result, projectileId = Engine.InstantiatePrefab(
            projectileTemplate.general.prefabID,
            spawnPosition,
            EngineClasses.float3(1, 1, 1),
            muzzleRotation)
        if result ~= EngineErrorCode.Success
            or not projectileId
            or not Engine.IsValidGlobalID(projectileId)
        then
            return false, "instantiate"
        end

        local projectile = nil
        local createSent = false
        local ok, failure = pcall(function()
            SCOCommands.CreateProjectile.Send(projectileId, unit.army.id)
            createSent = true
            projectile = SCOProjectile(
                projectileId,
                unit.army.id,
                projectileTemplate,
                state.contract.innerDamage.amount,
                state.contract.innerDamage.radius,
                state.contract.projectileLifetime,
                muzzleId, unit)
            projectile.scoStrategicNukeSourceId = unit.id
            if state.contract.apocalypseFlight then
                SCOInitializeApocalypseFlight(
                    projectile,
                    spawnPosition,
                    canonicalTargetPosition,
                    state.contract.apocalypseFlight)
            else
                Engine.SetHomingProjectileTargetPosition(
                    projectileId, canonicalTargetPosition)
                Engine.SetHomingProjectileTargetType(
                    projectileId, HomingType.TargetPosition)
                local velocity = Engine.QuaternionRotateVector(
                    muzzleRotation, EngineClasses.float3(0, 0, 1))
                velocity = math3D.scale(
                    velocity, state.contract.initialProjectileSpeed)
                Engine.SetHomingProjectileVelocity(projectileId, velocity)
                Engine.SetProjectileGravity(
                    projectileId, EngineClasses.float3(0, 0, 0))
            end
            SCOProjectiles[projectileId.index] = projectile
            local registeredMuzzle = __Muzzles and __Muzzles[muzzleId.index]
            if registeredMuzzle then
                SCOCommands.FireMuzzle.Send(muzzleId)
                registeredMuzzle:SetFiring(true)
            end
        end)
        if not ok then
            if projectile then
                local deleted = pcall(projectile.Delete, projectile)
                if not deleted then
                    SCOProjectiles[projectileId.index] = nil
                    pcall(Engine.DeletePrefabInstance, projectileId)
                end
            else
                if createSent then pcall(SCOCommands.DeleteProjectile.Send, projectileId) end
                pcall(Engine.DeletePrefabInstance, projectileId)
            end
            Warn("SCOM strategic silo launch failed: " .. tostring(failure))
            return false, "spawn"
        end

        -- Stockpile changes only after the projectile is registered and announced.
        state.ammo = state.ammo - 1
        SCOEmitState(unit)
        return true, projectileId
    end

    SCOAdvanceNukeLaunch = function(unit)
        local state = unit.scoStrategicSilo
        local launch = state and state.launch
        if not launch then return end
        local config = state.contract.launchAnimation
        if not config then
            error(unit.tpId .. " has an animated launch without a contract", 2)
        end
        if unit.scoFaAnimationConstructionReady ~= true then
            launch.readinessElapsed = launch.readinessElapsed
                + Constants.TickTimeStep
            if launch.readinessElapsed + 0.000001
                >= SCOApocalypseConstructionOpenDuration + 2
            then
                SCOCancelNukeLaunch(unit)
                SCOEmitState(unit)
                Warn("[SCOM Strategic Silo] Launch rejected: tp="
                    .. tostring(unit.tpId)
                    .. " id=" .. tostring(unit.id)
                    .. " reason=animation-readiness-timeout")
            end
            return
        end
        local step = Constants.TickTimeStep * config.rate

        if launch.phase == "opening" then
            SCOSampleLaunchAnimation(unit, config.key, launch.sample)
            launch.sample = math.min(config.duration, launch.sample + step)
            if launch.sample + 0.000001 < config.duration then return end

            SCOSampleLaunchAnimation(unit, config.key, config.duration)
            local launched, result = SCOCommitNukeLaunch(
                unit, launch.targetPosition)
            if not launched then
                SCOCancelNukeLaunch(unit)
                SCOEmitState(unit)
                Warn("SCOM strategic silo delayed launch failed: "
                    .. tostring(result))
                return
            end
            launch.phase = "holding"
            launch.elapsed = 0
            return
        end

        if launch.phase == "holding" then
            launch.elapsed = launch.elapsed + Constants.TickTimeStep
            if launch.elapsed + 0.000001 >= config.repackTimeout then
                launch.phase = "closing"
                launch.sample = config.duration
            end
            return
        end

        if launch.phase ~= "closing" then
            SCOCancelNukeLaunch(unit)
            error(unit.tpId .. " has an invalid strategic launch phase", 2)
        end
        SCOSampleLaunchAnimation(unit, config.key, launch.sample)
        launch.sample = math.max(0, launch.sample - step)
        if launch.sample <= 0.000001 then
            launch.sample = 0
            SCOCancelNukeLaunch(unit)
            SCOEmitState(unit)
        end
    end

    function HostUnit:SCOLaunchNuke(targetPosition)
        local state = self.scoStrategicSilo
        if not state or self.dead or not self:IsCompleted() then
            return false, "unavailable"
        end
        if state.launch then
            return false, "launching"
        end
        if state.ammo <= 0 then
            return false, "unavailable"
        end
        local canonicalTargetPosition = SCOValidateLaunchTarget(self, targetPosition)
        if not canonicalTargetPosition then
            return false, "target"
        end
        if not SCOValidateProjectileTemplate(self) then
            return false, "projectile-template"
        end
        local muzzleId = self:GetBoneId(state.contract.muzzle)
        if not muzzleId or not Engine.IsValidGlobalID(muzzleId) then
            return false, "muzzle"
        end

        local config = state.contract.launchAnimation
        if not config then
            return SCOCommitNukeLaunch(self, canonicalTargetPosition)
        end
        state.launch = {
            targetPosition = canonicalTargetPosition,
            phase = "opening",
            sample = 0,
            elapsed = 0,
            readinessElapsed = 0,
        }
        SCOEmitState(self)
        return true, "launching"
    end

    if type(HostUnit) ~= "table"
        or type(HostUnit.__init) ~= "function"
        or type(HostUnit.OnStopBeingBuilt) ~= "function"
        or type(HostUnit.SetPause) ~= "function"
        or type(HostUnit.SetArmy) ~= "function"
        or type(HostUnit.OnCaptureProcessEnded) ~= "function"
        or type(HostUnit.OnDestroy) ~= "function"
    then
        error("SCOM strategic silo could not resolve HostUnit lifecycle")
    end

    local SCOHostUnitInit = HostUnit.__init
    local SCOHostUnitStopBeingBuilt = HostUnit.OnStopBeingBuilt
    local SCOHostUnitSetPause = HostUnit.SetPause
    local SCOHostUnitSetArmy = HostUnit.SetArmy
    local SCOHostUnitCaptureEnded = HostUnit.OnCaptureProcessEnded
    local SCOHostUnitOnDestroy = HostUnit.OnDestroy

    function HostUnit:__init(...)
        local result = SCOHostUnitInit(self, ...)
        local contract = SCOGetContract(self, SCOExpectedSilos[self.tpId] ~= nil)
        if contract then
            local initialAmmo = contract.initialAmmo
            local creativeSpawned = false
            if _G.SCO_FieldFixCreativeSpawnContext == "1.0.0"
                and (self.tpId == "ucs3102" or self.tpId == "ugs3102" or self.tpId == "uss3102")
            then
                initialAmmo = contract.maxAmmo
                creativeSpawned = true
            end
            self.scoStrategicSilo = {
                contract = contract,
                ammo = initialAmmo,
                queued = 0,
                work = 0,
                autoBuild = contract.defaultAutoBuild,
                building = false,
                activeConsumesQueue = false,
                launch = nil,
                animationReady = contract.launchAnimation == nil
                    or self.scoFaAnimationConstructionReady == true,
                sequence = 0,
                syncTicks = 0,
            }
            -- Sanctuary capture recreates a unit instead of calling SetArmy.
            -- A synchronous handoff preserves completed stockpile only; partial
            -- work, manual queue, and automation restart cleanly for the captor.
            SCOApplyCaptureHandoff(self)
            SCOCreateResourceEntity(self)
            if creativeSpawned then
                Log("[SCOM Strategic Silo] Creative preload: tp="
                    .. tostring(self.tpId)
                    .. " id=" .. tostring(self.id)
                    .. " ammo=" .. tostring(initialAmmo))
            end
            -- Stock __init calls OnStopBeingBuilt before this wrapper regains
            -- control for units spawned complete. Start their silo thread here;
            -- normally-built units start it from the lifecycle hook below.
            SCOEnsureSiloThread(self)
        end
        return result
    end

    function HostUnit:OnStopBeingBuilt(...)
        local result = SCOHostUnitStopBeingBuilt(self, ...)
        SCOEnsureSiloThread(self)
        return result
    end

    function HostUnit:SetPause(value)
        local result = SCOHostUnitSetPause(self, value)
        local state = self.scoStrategicSilo
        if state and state.building then
            SCOSetDrainEnabled(self, value ~= true)
            SCOEmitState(self)
        end
        return result
    end

    function HostUnit:SetArmy(army)
        local state = self.scoStrategicSilo
        if state then
            self:SCOClearNukeQueue()
            SCOReleaseResourceEntity(self)
        end
        local result = SCOHostUnitSetArmy(self, army)
        if state then
            SCOCreateResourceEntity(self)
            SCOEmitState(self)
        end
        return result
    end

    function HostUnit:OnCaptureProcessEnded(army, ...)
        local state = self.scoStrategicSilo
        local handoff = nil
        if state
            and self:IsCaptureProcessComplete()
            and type(army) == "table"
            and type(army.id) == "number"
        then
            handoff = {
                tpId = self.tpId,
                armyId = army.id,
                ammo = state.ammo,
                consumed = false,
            }
        end

        local previousHandoff = SCOCaptureHandoff
        if handoff then SCOCaptureHandoff = handoff end
        local ok, result = pcall(SCOHostUnitCaptureEnded, self, army, ...)
        SCOCaptureHandoff = previousHandoff
        if not ok then error(result, 0) end
        return result
    end

    function HostUnit:OnDestroy(...)
        local state = self.scoStrategicSilo
        if state then
            if state.thread then
                KillThread(state.thread)
                state.thread = nil
            end
            -- Detach before stock destruction. Assistants can otherwise retain a
            -- dangling enabled ResourceEntity after the army removes it, then warn
            -- when their cleanup calls RemoveBuilder on an unregistered entity.
            SCOReleaseResourceEntity(self)
        end
        return SCOHostUnitOnDestroy(self, ...)
    end

    if _G.IssueNuke == nil then
        function _G.IssueNuke(units, targetPosition)
            local launched = false
            for _, unit in pairs(units or {}) do
                if unit and unit.SCOLaunchNuke then
                    launched = unit:SCOLaunchNuke(targetPosition) or launched
                end
            end
            return launched
        end
    end

    rawset(
        SCOFieldFixStrategicSiloHostEnvironment,
        "SCO_FieldFixStrategicSiloHostInstalled",
        "1.0.8")
    -- Retain a process-global version only for diagnostics/dependencies outside
    -- this module. It must not suppress wrappers in a fresh import environment.
    _G.SCO_FieldFixStrategicSiloHostInstalled = "1.0.8"
end
-- SCOM Field Fixes 1.0.4 - owner-only strategic silo state replication.
local SCOFieldFixStrategicSiloStateHostMarker =
    _G.SCO_FieldFixStrategicSiloStateHostInstalled
if SCOFieldFixStrategicSiloStateHostMarker ~= nil
    and SCOFieldFixStrategicSiloStateHostMarker ~= "1.0.4"
then
    error("Unsupported SCOM strategic silo state-host marker "
        .. tostring(SCOFieldFixStrategicSiloStateHostMarker))
end
if SCOFieldFixStrategicSiloStateHostMarker == nil then
    if _G.SCO_FieldFixStrategicSiloHostInstalled ~= "1.0.8" then
        error("SCOM strategic silo state bridge requires the host lifecycle first")
    end

    local SCOStateCommands = Import("common/commands/definitions/session.lua")
    local SCOLobby = Import("common/lobby.lua")
    if type(SCOLobby) ~= "table"
        or type(SCOLobby.ArmyToPlayer) ~= "table"
    then
        error("SCOM strategic silo state bridge could not resolve lobby ownership")
    end
    if type(SCOStateCommands) ~= "table"
        or type(SCOStateCommands.ExecuteClientFunction) ~= "table"
    then
        error("SCOM strategic silo state bridge could not resolve host commands")
    end

    local SCOPreviousSiloStateListener =
        _G.SCO_FieldFixStrategicSiloStateChanged
    if SCOPreviousSiloStateListener ~= nil
        and type(SCOPreviousSiloStateListener) ~= "function"
    then
        error("SCOM strategic silo state hook is occupied by a non-function")
    end

    function _G.SCO_FieldFixStrategicSiloStateChanged(unit, state)
        if SCOPreviousSiloStateListener then
            SCOPreviousSiloStateListener(unit, state)
        end
        local army = unit and unit.army
        local player = army
            and type(army.id) == "number"
            and SCOLobby.ArmyToPlayer[army.id]
        local clientId = type(player) == "table" and player.clientID or nil
        if type(clientId) ~= "number" then
            return
        end
        SCOStateCommands.ExecuteClientFunction.SendTo(
                clientId,
                "SCOStrategicSiloState",
                state)
    end

    _G.SCO_FieldFixStrategicSiloStateHostInstalled = "1.0.4"
end
-- SCOM Field Fixes 1.0.4 - engineer assistance for active silo ammo work.
local SCOFieldFixStrategicSiloAssistEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOFieldFixStrategicSiloAssistMarker = rawget(
    SCOFieldFixStrategicSiloAssistEnvironment,
    "SCO_FieldFixStrategicSiloAssistInstalled")
if SCOFieldFixStrategicSiloAssistMarker ~= nil
    and SCOFieldFixStrategicSiloAssistMarker ~= "1.0.4"
then
    error("Unsupported SCOM strategic silo assist marker "
        .. tostring(SCOFieldFixStrategicSiloAssistMarker))
end
if SCOFieldFixStrategicSiloAssistMarker == nil then
    if rawget(
        SCOFieldFixStrategicSiloAssistEnvironment,
        "SCO_FieldFixStrategicSiloHostInstalled") ~= "1.0.8"
    then
        error("SCOM strategic silo assist requires the host lifecycle first")
    end
    if type(HostUnit) ~= "table"
        or type(HostUnit.AssistBehaviorThread) ~= "function"
        or type(HostUnit.AssistBehaviorStop) ~= "function"
        or type(HostUnit.BuildBehaviorIsValidFor) ~= "function"
        or type(HostUnit.BuildBehaviorStart) ~= "function"
        or type(HostUnit.BuildBehaviorStop) ~= "function"
    then
        error("SCOM strategic silo assist could not resolve HostUnit behavior")
    end

    local function SCORemoveSiloBuilder(builder)
        local entity = builder.scoStrategicSiloAssistEntity
        if not entity then return end
        local source = entity.buildPowerSources
            and entity.buildPowerSources[builder.id]
        if source then
            if entity.enabled then
                entity:RemoveBuilder(builder)
            else
                entity.buildPower = entity.buildPower
                    - source.buildPower / Constants.TickRate
                for resourceName in pairs(entity.resourceBuildPower or {}) do
                    local discount = source.discount
                        and source.discount[resourceName]
                    local amount = discount
                        and source.buildPower * discount
                        or source.buildPower
                    entity.resourceBuildPower[resourceName] =
                        entity.resourceBuildPower[resourceName] - amount
                end
                entity.buildPowerSources[builder.id] = nil
            end
        end
        builder.scoStrategicSiloAssistEntity = nil
    end

    local function SCOAddSiloBuilder(builder, entity)
        if builder.scoStrategicSiloAssistEntity == entity then return end
        SCORemoveSiloBuilder(builder)
        if not entity.enabled
            or not entity.buildPowerSources
            or entity.buildPowerSources[builder.id] ~= nil
        then
            return
        end
        entity:AddBuilder(builder)
        -- AddBuilder expands the next drain immediately but retains the economy
        -- result paid for the smaller pre-assist drain. Suppress one tick of
        -- work until Economy.Update establishes a paid multiplier for the new
        -- total build power.
        entity.productionMultiplier = 0
        builder.scoStrategicSiloAssistEntity = entity
    end

    local SCOAssistBehaviorThread = HostUnit.AssistBehaviorThread
    local SCOAssistBehaviorStop = HostUnit.AssistBehaviorStop

    local function SCOAssistUnfinishedSilo(builder, assisted)
        SCORemoveSiloBuilder(builder)
        if not assisted.hasBeenPromotedFromPlacementGhost then
            if not builder.followBehaviorIsActive then
                builder:FollowBehaviorStart(
                    assisted,
                    builder.construction.range or 10)
            end
            WaitTicks(10)
            return
        end
        if builder:BuildBehaviorIsValidFor(assisted) then
            builder:FollowBehaviorStop()
            builder:BuildBehaviorStart(assisted)
            while builder.buildBehaviorIsActive
                and builder.assistBehaviorAssistedUnit == assisted
                and (assisted.scoStrategicSilo or assisted.scoTactical)
                and not assisted:IsCompleted()
            do
                WaitTicks(1)
            end
            builder:BuildBehaviorStop()
            return
        end
        if not builder.followBehaviorIsActive then
            builder:FollowBehaviorStart(
                assisted,
                builder.construction.range or 10)
        end
        WaitTicks(3)
    end

    function HostUnit:AssistBehaviorThread()
        local assisted = self.assistBehaviorAssistedUnit
        if not assisted or not (assisted.scoStrategicSilo or assisted.scoTactical) then
            return SCOAssistBehaviorThread(self)
        end
        if not self.constructionDetectorCollider
            or not self.construction
            or type(self.construction.buildPower) ~= "number"
            or self.construction.buildPower <= 0
        then
            return self:AssistBehaviorStop()
        end

        while self:AssistBehaviorIsValidFor(assisted)
            and self.assistBehaviorAssistedUnit == assisted
            and (assisted.scoStrategicSilo or assisted.scoTactical)
        do
            if not assisted:IsCompleted() then
                SCOAssistUnfinishedSilo(self, assisted)
            else
                local state = assisted.scoStrategicSilo or assisted.scoTactical
                local entity = state.resourceEntity
                local inRange = self.constructionDetectorCollider
                    :IsCollidingWithGlobalID(assisted.id)
                if not inRange then
                    SCORemoveSiloBuilder(self)
                    if not self.followBehaviorIsActive then
                        self:FollowBehaviorStart(
                            assisted,
                            self.construction.range or 10)
                    end
                else
                    self:FollowBehaviorStop()
                    if state.building
                        and entity
                        and entity.enabled
                        and not self:GetPause()
                        and not assisted:GetPause()
                    then
                        SCOAddSiloBuilder(self, entity)
                    else
                        SCORemoveSiloBuilder(self)
                    end
                end
                WaitTicks(1)
            end
        end
        self:AssistBehaviorStop()
    end

    function HostUnit:AssistBehaviorStop(...)
        SCORemoveSiloBuilder(self)
        return SCOAssistBehaviorStop(self, ...)
    end

    rawset(
        SCOFieldFixStrategicSiloAssistEnvironment,
        "SCO_FieldFixStrategicSiloAssistInstalled",
        "1.0.4")
    -- Observable version only; installation ownership belongs to this module
    -- environment so a fresh HostUnit import receives fresh wrappers.
    _G.SCO_FieldFixStrategicSiloAssistInstalled = "1.0.4"
end
-- SCOM tactical missiles 1.0.0. Append after the strategic HostUnit lifecycle.
do
    local version = "1.0.0"
    if _G.SCO_TacticalHostInstalled and _G.SCO_TacticalHostInstalled ~= version then
        error("Unsupported tactical host version")
    end
    if not _G.SCO_TacticalHostInstalled then
        local allowed = {
            ues2102 = "UEB2108", ucs2102 = "UAB2108", ugs2102 = "URB2108", uss2102 = "XSB2108",
            ues2402 = "UEB4201", ucs2402 = "UAB4201", ugs2402 = "URB4201", uss2402 = "XSB4201",
            wsb4205 = "XSB4201",
            ues3102 = "UEB2305", ugs5007 = "URB2305", uss4102 = "XSB2401", ues5023 = "UEB4302", ugs5015 = "URB4302",
            ucs3402 = "UAB4302", uss3402 = "XSB4302",
            uen3004 = "UES0304", ugn3004 = "URS0304", usn3001 = "XSS0302",
        }
        local Resource = Import("host/systems/resourceEntity.lua").ResourceEntity
        local Projectile = Import("host/projectiles/projectilesClasses/projectilesBaseClass.lua").HostProjectile
        local Commands = Import("common/commands/definitions/projectiles.lua")
        local Session = Import("common/commands/definitions/session.lua")
        local Lobby = Import("common/lobby.lua")
        local MapUtils = Import("common/mapUtils.lua")
        local Projectiles = __Entities.Projectiles
        local Tactical = { missiles = {}, allowed = allowed }
        _G.SCO_Tactical = Tactical

        local function finite(value)
            return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
        end
        local function same(a, b)
            return a and b and a.index == b.index and a.version == b.version
        end
        local function point(id)
            local result, position = Engine.GetGlobalEntityWorldPosition(id)
            if result ~= EngineErrorCode.Success or not position then return nil end
            return position
        end
        local function distance(a, b)
            local x, z = a.x - b.x, a.z - b.z
            return math.sqrt(x * x + z * z)
        end
        local function client(unit)
            local player = unit.army and Lobby.ArmyToPlayer[unit.army.id]
            return player and player.clientID
        end
        local function copyState(unit)
            local s = unit.scoTactical
            if not s or s.contract.role ~= "launcher" then return nil end
            return { unitId = unit.id, tpId = unit.tpId, ammo = s.ammo,
                maxAmmo = s.contract.maxAmmo, queued = s.queued, work = s.work,
                buildTime = s.contract.buildTime, autoBuild = s.autoBuild,
                building = s.building, paused = (unit.toggles and unit:GetPause()) == true,
                launchPending = s.launch ~= nil, animationReady = s.phase == "packed",
                sequence = s.sequence }
        end
        local function emit(unit)
            local s = unit.scoTactical
            if s.contract.role ~= "launcher" then return end
            s.sequence = s.sequence + 1
            local owner = client(unit)
            if type(owner) == "number" then
                Session.ExecuteClientFunction.SendTo(owner, "SCOTacticalSiloState", copyState(unit))
            end
            if unit.tpId == 'uss4102' then
                assert(_G.SCO_UpdateYolonaMissile, 'Yolona missile pose owner missing')(unit)
            end
        end
        local function drain(unit, enabled)
            local s, c = unit.scoTactical, unit.scoTactical.contract
            if not s.resource and enabled then
                local entity = Resource(unit.army.id, unit.id, "construction", nil, nil, false)
                entity:SetCost(c.cost)
                entity:SetBuildTime(c.buildTime)
                entity:SetEnabled(true)
                entity:AddBuilder(unit)
                entity:SetEnabled(false)
                entity.productionMultiplier = 0
                entity.outcome, entity.prevOutcome = {}, {}
                s.resource = entity
                s.resourceEntity = entity
                unit.resourceEntities.scoTacticalAmmo = entity
            end
            if s.resource and s.resource.enabled ~= enabled then
                s.resource:SetEnabled(enabled)
                if enabled then s.resource:RecalculateBuildDrain() end
            end
            if s.resource and not enabled then
                s.resource.productionMultiplier = 0
                s.resource.outcome, s.resource.prevOutcome = {}, {}
            end
        end
        local function release(unit)
            local s = unit.scoTactical
            if s.resource then
                drain(unit, false)
                s.resource.productionMultiplier = 0
                unit.resourceEntities.scoTacticalAmmo = nil
                s.resource = nil
                s.resourceEntity = nil
            end
        end
        local function sample(unit, value)
            local s = unit.scoTactical
            local c = s.contract
            if c.deployDuration == 0 then return end
            if c.hatch then
                if not s.hatch then
                    if value == 0 then return end
                    local id=assert(unit:GetBoneId(c.hatch.bones[s.rack]),"Source submarine hatch missing")
                    local result,rotation=Engine.GetGlobalEntityLocalRotation(id)
                    assert(result==EngineErrorCode.Success and rotation,"Source submarine hatch pose missing")
                    s.hatch={id=id,rest=rotation}
                end
                local angle=math.rad(c.hatch.goal*value/c.deployDuration)
                local delta=Engine.QuaternionAxisAngle(EngineClasses.float3(0,0,1),angle)
                Engine.SetGlobalEntityLocalRotation(s.hatch.id,Engine.QuaternionMultiply(s.hatch.rest,delta))
                if value==0 then s.hatch=nil end
                return
            end
            local animations = unit.tp.visuals.animations
            local animation = animations and animations[c.deployKey]
            if not animation or not animation.id then error("Missing tactical deploy clip: " .. unit.tpId) end
            Engine.PlayAnimation(unit.id, animation.id, -10000 + value)
        end
        local function requireSuccess(result, operation)
            if result ~= EngineErrorCode.Success then error("Tactical " .. operation .. " failed: " .. tostring(result)) end
        end

        function Tactical.Spawn(unit, templateId, spawn, target, muzzleId, damage, radius, velocity, ownerArmyId, rotationOverride)
            local tp = __Templates.Projectiles[templateId]
            local config = tp and tp.additions and tp.additions.scoTacticalProjectile
            if not config or config.version ~= version or not tp.general.prefabID then return nil, "template" end
            local _, rotation = Engine.GetGlobalEntityWorldRotation(muzzleId or unit.id)
            rotation = rotationOverride or rotation
            if not rotation then return nil, "rotation" end
            if config.sourceId:lower() == "tdphalanx01" then
                -- Phalanx shells cannot turn; retain the native controller's lead aim.
                local direction = Engine.QuaternionRotateVector(rotation, EngineClasses.float3(0, 0, 1))
                local speed = math.sqrt(velocity.x*velocity.x + velocity.y*velocity.y + velocity.z*velocity.z)
                velocity = EngineClasses.float3(direction.x*speed, direction.y*speed, direction.z*speed)
            end
            local armyId=ownerArmyId or unit.army.id
            local result, id = Engine.InstantiatePrefab(tp.general.prefabID, spawn,
                EngineClasses.float3(1, 1, 1), rotation)
            if result ~= EngineErrorCode.Success or not id then return nil, "instantiate" end
            local projectile
            local createSent = false
            local ok, failure = pcall(function()
                Commands.CreateProjectile.Send(id, armyId)
                createSent = true
                projectile = Projectile(id, armyId, tp, damage, radius, config.lifetime, muzzleId, unit)
                projectile.scoTactical = { config = config, source = unit, sourceId = unit.id,
                    target = target, health = config.health or 1, born = GetGameTimeSeconds(),
                    turnAt = GetGameTimeSeconds() + 0.3, previous = spawn, velocity = velocity, rotation = rotation }
                requireSuccess(Engine.SetHomingProjectileTargetPosition(id, target), "target")
                requireSuccess(Engine.SetHomingProjectileTargetType(id, HomingType.TargetPosition), "target type")
                requireSuccess(Engine.SetHomingProjectileAcceleration(id, config.acceleration), "acceleration")
                requireSuccess(Engine.SetHomingProjectileMaxSpeed(id, config.maxSpeed), "maximum speed")
                requireSuccess(Engine.SetHomingProjectileRotationSpeed(id, config.turnRate), "turn rate")
                if not config.sourcePhysics then
                    requireSuccess(Engine.SetProjectileGravity(id, EngineClasses.float3(0, 0, 0)), "gravity")
                end
                requireSuccess(Engine.SetHomingProjectileVelocity(id, velocity), "velocity")
                Projectiles[id.index] = projectile
                if config.tactical then Tactical.missiles[id.index] = projectile end
                if config.sourceNuke then
                    assert(_G.SCO_SourceNukeLaunched, "Source nuke runtime missing")(projectile, unit, target)
                end
                if muzzleId and __Muzzles and __Muzzles[muzzleId.index] then Commands.FireMuzzle.Send(muzzleId) end
            end)
            if not ok then
                if projectile then
                    local deleted = pcall(projectile.Delete, projectile)
                    if not deleted then
                        Projectiles[id.index] = nil
                        Tactical.missiles[id.index] = nil
                        pcall(Engine.DeletePrefabInstance, id, false)
                    end
                else
                    if createSent then pcall(Commands.DeleteProjectile.Send, id) end
                    pcall(Engine.DeletePrefabInstance, id, false)
                end
                Tactical.missiles[id.index] = nil
                return nil, tostring(failure)
            end
            return projectile
        end

        function Tactical.HitMissile(projectile, amount)
            local state = projectile and projectile.scoTactical
            if not state or state.destroyed or not finite(amount) or amount <= 0 then return false end
            if state.config.invincibleSeconds and GetGameTimeSeconds() < state.born + state.config.invincibleSeconds then return false end
            state.health = state.health - amount
            if state.health > 0 then return true end
            state.destroyed = true
            if state.config.split and not state.split then
                state.split = true
                local position = point(projectile.id)
                local velocity = state.velocity
                if not position or not velocity then error("Cybran tactical split transform unavailable") end
                for index = 0, 2 do
                    local angle = index * 2 * math.pi / 3
                    local x, y, z = velocity.x + math.sin(angle) * 0.5,
                        velocity.y + math.cos(angle) * 0.5, velocity.z + math.cos(angle) * 0.5
                    local length = math.sqrt(x*x+y*y+z*z)
                    local child, reason = Tactical.Spawn(state.source, "pst005", position, state.target,
                        nil, 833, 1.3, EngineClasses.float3(x*7/length, y*7/length, z*7/length),projectile.armyId,state.rotation)
                    if not child then error("Cybran tactical child spawn failed: " .. tostring(reason)) end
                end
            end
            Tactical.missiles[projectile.id.index] = nil
            projectile:Destroy(0)
            return true
        end

        local function targetPosition(unit, target)
            if not target or not finite(target.x) or not finite(target.y) or not finite(target.z)
                or not MapUtils.IsPositionOnMap(target) then return nil end
            local position = point(unit.id)
            if not position then return nil end
            local c = unit.scoTactical.contract
            local range = distance(position, target)
            if range < c.rangeMin or range > c.rangeMax then return nil end
            local result, y = Engine.SampleTerrainHeight(target)
            if result ~= EngineErrorCode.Success or not finite(y) then return nil end
            return EngineClasses.float3(target.x, y, target.z)
        end
        local function commit(unit, target)
            local s, c = unit.scoTactical, unit.scoTactical.contract
            local muzzle = unit:GetBoneId(c.muzzles[s.rack])
            if not muzzle or not Engine.IsValidGlobalID(muzzle) then return false end
            local spawn = point(muzzle)
            local _, rotation = Engine.GetGlobalEntityWorldRotation(muzzle)
            if not spawn or not rotation then return false end
            if unit.tpId == 'uss4102' then
                spawn, rotation = assert(_G.SCO_YolonaMissileLaunchTransform, 'Yolona launch pose owner missing')(unit)
                if not spawn or not rotation then return false end
                _G.SCO_UpdateYolonaMissile(unit, true)
            end
            local velocity = Engine.QuaternionRotateVector(rotation, EngineClasses.float3(0, 0, c.muzzleVelocity))
            local projectile = Tactical.Spawn(unit, c.projectile, spawn, target, muzzle, c.damage, c.damageRadius, velocity, nil, rotation)
            if not projectile then
                if unit.tpId == 'uss4102' then _G.SCO_UpdateYolonaMissile(unit, false) end
                return false
            end
            s.ammo = s.ammo - 1
            if unit.tpId == 'uss4102' then _G.SCO_UpdateYolonaMissile(unit, false) end
            s.rack = s.rack % #c.muzzles + 1
            s.cooldown = GetGameTimeSeconds() + math.max(c.reload, s.rack == 1 and c.cycleReload or 0)
            return true
        end
        local function advanceLaunch(unit, now)
            local s, c = unit.scoTactical, unit.scoTactical.contract
            local step = Constants.TickTimeStep * c.deployRate
            if s.phase == "opening" then
                s.sample = math.min(c.deployDuration, s.sample + step)
                sample(unit, s.sample)
                if s.sample >= c.deployDuration then s.phase, s.untilTime = "charging", now + c.charge end
            elseif s.phase == "charging" and now >= s.untilTime then
                local accepted = s.launch and targetPosition(unit, s.launch)
                if accepted then commit(unit, accepted) end
                s.launch = nil
                s.phase, s.untilTime = "holding", now + c.repackTimeout
                emit(unit)
            elseif s.phase == "holding" and now >= s.untilTime then
                s.phase = "closing"
            elseif s.phase == "closing" then
                s.sample = math.max(0, s.sample - step)
                sample(unit, s.sample)
                if s.sample == 0 then
                    if c.deployDuration > 0 and c.packedKey then
                        local packed = unit.tp.visuals.animations[c.packedKey]
                        if not packed or not packed.id then error("Missing tactical packed clip: " .. unit.tpId) end
                        Engine.PlayAnimation(unit.id, packed.id, 0.1)
                    end
                    s.phase = "packed"
                    emit(unit)
                end
            end
        end
        local function advanceAmmo(unit)
            local s, c = unit.scoTactical, unit.scoTactical.contract
            if c.role ~= "launcher" then return end
            if not s.building and s.ammo < c.maxAmmo and (s.autoBuild or s.queued > 0) then
                s.building = true
                s.consumesQueue = s.queued > 0
                emit(unit)
            end
            local enabled = s.building and not (unit.toggles and unit:GetPause())
            drain(unit, enabled)
            if not enabled then return end
            local entity = s.resource
            s.work = s.work + entity.buildPower * entity.productionMultiplier * (entity.userMultiplier or 1)
            if s.work >= c.buildTime then
                s.work, s.building = 0, false
                s.ammo = math.min(c.maxAmmo, s.ammo + 1)
                if s.consumesQueue then s.queued = math.max(0, s.queued - 1) end
                drain(unit, false)
                emit(unit)
            end
        end
        local function closestMissile(unit)
            local position, c = point(unit.id), unit.scoTactical.contract
            if not position then return nil end
            if _G.SCO_SourceInterception then return _G.SCO_SourceInterception.nearest(unit,c,'tactical') end
            local best, bestDistance
            for index, missile in pairs(Tactical.missiles) do
                if Projectiles[index] == missile and not missile.scoTactical.destroyed
                    and unit.army:IsEnemy(Armies[missile.armyId]) then
                    local missilePosition = point(missile.id)
                    local range = missilePosition and distance(position, missilePosition)
                    if range and range <= c.rangeMax and (not best or range < bestDistance
                        or (range == bestDistance and index < best.id.index)) then
                        best, bestDistance = missile, range
                    end
                end
            end
            return best
        end
        function Tactical.AdvanceBeamPulses(unit,now)
            for index,pulse in pairs(unit.scoTacticalBeamPulses or {}) do
                if now>=pulse.untilTime then
                    pulse.muzzle:SetFiring(false)
                    unit.scoTacticalBeamPulses[index]=nil
                end
            end
        end
        function Tactical.FireInterceptorBeam(unit,muzzle,targetPoint,lifetime)
            local native=assert(__Muzzles and __Muzzles[muzzle.index],"Tactical beam muzzle missing")
            local beam=assert(native.beam,"Tactical Zapper native beam missing")
            -- The projectile-health owner handles damage. This muzzle's host ray
            -- only fits beam intel; it cannot damage ordinary units or shields.
            beam.Raycast=function(self)
                local origin=point(self.id)
                if not origin then return 0 end
                local dx,dy,dz=targetPoint.x-origin.x,targetPoint.y-origin.y,targetPoint.z-origin.z
                return math.sqrt(dx*dx+dy*dy+dz*dz)
            end
            unit.scoTacticalBeamPulses=unit.scoTacticalBeamPulses or {}
            unit.scoTacticalBeamPulses[muzzle.index]={muzzle=native,untilTime=GetGameTimeSeconds()+lifetime}
            unit.scoTacticalBeamSequence=(unit.scoTacticalBeamSequence or 0)+1
            native:SetFiring(true)
            Session.ExecuteClientFunction.Send("SCOTacticalBeam",{unitId=unit.id,muzzleId=muzzle,
                targetPosition={x=targetPoint.x,y=targetPoint.y,z=targetPoint.z},sequence=unit.scoTacticalBeamSequence})
            Commands.FireMuzzle.Send(muzzle)
        end
        local function advanceDefense(unit, now)
            local s, c = unit.scoTactical, unit.scoTactical.contract
            Tactical.AdvanceBeamPulses(unit,now)
            local stun = _G.SCO_SourceStun
            if stun and stun.IsStunned(unit) then return end
            if unit.toggles and unit:GetPause() then return end
            local weapon = unit.weapons and unit.weapons[1]
            if not weapon or not weapon.enabled then return end
            local target = closestMissile(unit)
            if c.barrelSpin then
                local goal = target and 270 or 0
                local speed = s.spinSpeed or 0
                local increment = 180*Constants.TickTimeStep
                speed = speed<goal and math.min(goal,speed+increment) or math.max(goal,speed-increment)
                s.spinSpeed=speed
                local id=unit.rotatorIds and unit.rotatorIds[1]
                if not id then error("UEF Phalanx barrel rotator unavailable") end
                Engine.SetRotatorSpeed(id,EngineClasses.float3(0,0,speed))
                unit:SetRotatorsEnabled(true)
            end
            if weapon then
                for _, id in ipairs(weapon.aimControllerIds or {}) do
                    Engine.SetAimControllerTarget(id, target and target.id or EngineClasses.GlobalID())
                end
            end
            if not target then
                if not s.lostTarget then s.lostTarget = now end
                if now >= s.lostTarget + c.repackTimeout then
                    s.sample = math.max(0, s.sample - Constants.TickTimeStep*c.deployRate); sample(unit, s.sample)
                end
                return
            end
            s.lostTarget = nil
            s.sample = math.min(c.deployDuration, s.sample + Constants.TickTimeStep*c.deployRate)
            sample(unit, s.sample)
            if s.sample < c.deployDuration or now < s.cooldown then return end
            if weapon then
                for _, id in ipairs(weapon.aimControllerIds or {}) do
                    local _, ready = Engine.GetAimControllerIsOnTarget(id)
                    if not ready then return end
                end
            end
            local muzzle = unit:GetBoneId(c.muzzles[1])
            local spawn, targetPoint = muzzle and point(muzzle), point(target.id)
            if not spawn or not targetPoint then return end
            if c.beam then
                Tactical.FireInterceptorBeam(unit,muzzle,targetPoint,0.1)
                if _G.SCO_SourceInterception then _G.SCO_SourceInterception.Hit(target,c.damage)
                else Tactical.HitMissile(target,c.damage) end
            else
                local dx, dy, dz = targetPoint.x-spawn.x, targetPoint.y-spawn.y, targetPoint.z-spawn.z
                local length = math.sqrt(dx*dx+dy*dy+dz*dz)
                if length <= 0 then return end
                local projectile = Tactical.Spawn(unit, c.projectile, spawn, targetPoint, muzzle,
                    c.damage, 0, EngineClasses.float3(dx*c.muzzleVelocity/length,dy*c.muzzleVelocity/length,dz*c.muzzleVelocity/length))
                if not projectile then return end
                projectile.scoTactical.interceptorTarget = target.id
                if c.domeRecoil and unit.SCO_AeonStructureMotionDomeStep then unit:SCO_AeonStructureMotionDomeStep() end
            end
            s.cooldown = now + c.reload
        end
        function HostUnit:SCOTacticalThread()
            while self.scoTactical and not self.dead and not self.deleted do
                if self:IsCompleted() then
                    local now = GetGameTimeSeconds()
                    advanceAmmo(self)
                    if self.scoTactical.contract.autoIntercept then
                        assert(_G.SCO_SourceSiloAdvance, "Source interceptor runtime missing")(self, now)
                    elseif self.scoTactical.contract.role == "launcher" then advanceLaunch(self, now)
                    else advanceDefense(self, now) end
                    if now >= self.scoTactical.nextSync then self.scoTactical.nextSync = now+1; emit(self) end
                end
                WaitTicks(1)
            end
        end
        local oldInit, oldDestroy, oldSetArmy = HostUnit.__init, HostUnit.OnDestroy, HostUnit.SetArmy
        function HostUnit:__init(...)
            local result = oldInit(self, ...)
            local c = self.tp and self.tp.additions and self.tp.additions.scoTactical
            if c then
                if allowed[self.tpId] ~= c.sourceId or c.version ~= version then error("Unscoped tactical contract") end
                self.scoTactical = { contract=c, ammo=c.initialAmmo, queued=0, work=0, autoBuild=c.defaultAutoBuild==true,
                    building=false, sequence=0, phase="packed", sample=0, rack=1, cooldown=0, nextSync=0 }
                if _G.SCO_FieldFixCreativeSpawnContext == "1.0.0"
                    and (self.tpId == "ues3102" or self.tpId == "ugs5007" or self.tpId == "uss4102")
                then
                    self.scoTactical.ammo = c.maxAmmo
                end
                self:NewThread(self.SCOTacticalThread)
            end
            return result
        end
        function HostUnit:OnDestroy(...)
            if self.scoTactical then release(self); self.scoTactical = nil end
            return oldDestroy(self, ...)
        end
        function HostUnit:SetArmy(army)
            local s = self.scoTactical
            if s then release(self); s.launch=nil; s.phase="closing" end
            local result = oldSetArmy(self, army)
            if s then emit(self) end
            return result
        end
        Tactical.state, Tactical.emit, Tactical.drain = copyState, emit, drain
        Tactical.advanceLaunch, Tactical.advanceAmmo, Tactical.advanceDefense = advanceLaunch, advanceAmmo, advanceDefense
        Tactical.targetPosition, Tactical.same, Tactical.point = targetPosition, same, point
        assert(_G.SCO_TacticalInstallProjectileHooks, "Tactical collision resource must load before HostUnit")(Projectile)
        _G.SCO_TacticalHostInstalled = version
    end
end
-- SCOM tactical missiles 1.0.0. Append to HostUnit after tactical host lifecycle.
-- Reuse the authenticated strategic command transport; keep separate state ownership.
do
    if _G.SCO_TacticalCommandsInstalled and _G.SCO_TacticalCommandsInstalled ~= "1.0.0" then
        error("Unsupported tactical command version")
    end
    if not _G.SCO_TacticalCommandsInstalled then
        local tactical = assert(_G.SCO_Tactical,"Tactical host must load before commands")
        local function state(unit)
            local s=unit.scoTactical
            return s and s.contract.role=="launcher" and s or nil
        end
        local function integer(value,min,max)
            return type(value)=="number" and value==math.floor(value) and value>=min and value<=max
        end
        local oldControl=HostUnit.SCOCanClientControlStrategicSilo
        function HostUnit:SCOCanClientControlStrategicSilo(clientId)
            if not state(self) then return oldControl(self,clientId) end
            local player=Import("common/lobby.lua").ArmyToPlayer[self.army.id]
            return not self.dead and self:IsCompleted() and player and player.clientID==clientId
        end
        local oldState=HostUnit.SCOGetStrategicSiloState
        function HostUnit:SCOGetStrategicSiloState()
            if state(self) then return tactical.state(self) end
            return oldState(self)
        end
        local oldAmmo=HostUnit.GetNukeSiloAmmoCount
        function HostUnit:GetNukeSiloAmmoCount()
            local s=state(self)
            if s then return s.ammo end
            return oldAmmo(self)
        end
        local oldQueue=HostUnit.SCOQueueNuke
        function HostUnit:SCOQueueNuke(amount)
            local s=state(self)
            if not s then return oldQueue(self,amount) end
            if self.dead or not self:IsCompleted() or not integer(amount,1,s.contract.maxAmmo) then return false end
            local capacity=s.contract.maxAmmo-s.ammo-s.queued-(s.building and not s.consumesQueue and 1 or 0)
            if capacity<=0 then return false end
            s.queued=s.queued+math.min(capacity,amount)
            tactical.emit(self)
            return true
        end
        local oldAuto=HostUnit.SCOSetNukeAutoBuild
        function HostUnit:SCOSetNukeAutoBuild(enabled)
            local s=state(self)
            if not s then return oldAuto(self,enabled) end
            if type(enabled)~="boolean" or self.dead then return false end
            s.autoBuild=enabled; tactical.emit(self); return true
        end
        local oldClear=HostUnit.SCOClearNukeQueue
        function HostUnit:SCOClearNukeQueue()
            local s=state(self)
            if not s then return oldClear(self) end
            s.queued,s.autoBuild,s.building,s.launch=0,false,false,nil
            -- Retain paid construction work for the next job; cancellation cannot
            -- duplicate ammunition or charge those resources a second time.
            s.phase="closing"
            tactical.drain(self,false); tactical.emit(self); return true
        end
        local oldLaunch=HostUnit.SCOLaunchNuke
        function HostUnit:SCOLaunchNuke(target)
            local s=state(self)
            if not s then return oldLaunch(self,target) end
            if s.contract.autoIntercept then return false,"automatic-interceptor" end
            if self.dead or not self:IsCompleted() or self:GetPause() or s.ammo<1
                or s.phase~="packed" or s.launch or GetGameTimeSeconds()<s.cooldown then return false,"not-ready" end
            local position=tactical.targetPosition(self,target)
            if not position then return false,"target" end
            s.launch=position
            s.phase=s.contract.deployDuration>0 and "opening" or "charging"
            s.untilTime=GetGameTimeSeconds()+s.contract.charge
            tactical.emit(self)
            return true,"launching"
        end
        _G.SCO_TacticalCommandsInstalled="1.0.0"
    end
end
-- Source projectile targeting and stockpiles. Append to HostUnit after tactical commands.
do
    if not _G.SCO_SourceInterception then
        local Tactical=assert(_G.SCO_Tactical,"Tactical projectile owner must load first")
        local Projectile=Import("host/projectiles/projectilesClasses/projectilesBaseClass.lua").HostProjectile
        local Commands=Import("common/commands/definitions/projectiles.lua")
        local Session=Import("common/commands/definitions/session.lua")
        local Source={targets={}}
        _G.SCO_SourceInterception=Source
        local allowed={ues3102="UEB2305",ugs5007="URB2305",uss4102="XSB2401",ues5023="UEB4302",ugs5015="URB4302",
            uen5001="XES0102",uen5003="XES0307",ugn5001="XRS0204",ugn5002="XRS0205",
            ucs3402="UAB4302",uss3402="XSB4302",uss2301="XSB2205",
            uen3004="UES0304",ugn3004="URS0304",usn3001="XSS0302"}
        function Source.AllowUnit(target,sourceId)
            assert(type(target)=="string" and target:match("^u%l%l%d%d%d%d$") and type(sourceId)=="string" and sourceId:match("^%u%u%u%d%d%d%d$"),"Invalid source interception registry entry")
            assert(not allowed[target] or allowed[target]==sourceId,"Conflicting source interception registry entry")
            allowed[target]=sourceId
        end
        local function length(a,b)
            local x,y,z=a.x-b.x,a.y-b.y,a.z-b.z
            return math.sqrt(x*x+y*y+z*z)
        end
        local function segment(a,b,p)
            local x,y,z=b.x-a.x,b.y-a.y,b.z-a.z
            local square=x*x+y*y+z*z
            local t=square>0 and ((p.x-a.x)*x+(p.y-a.y)*y+(p.z-a.z)*z)/square or 0
            t=math.max(0,math.min(1,t))
            return length({x=a.x+x*t,y=a.y+y*t,z=a.z+z*t},p)
        end
        local function kindOf(projectile)
            if projectile.scoTactical and projectile.scoTactical.config.tactical then return "tactical" end
            return projectile.scoSourceThreat and projectile.scoSourceThreat.kind
        end
        local function tacticalPrevious(projectile,position,now)
            if kindOf(projectile)~="tactical" then return position end
            if not position or position.x~=position.x or position.y~=position.y or position.z~=position.z
                or math.abs(position.x)==math.huge or math.abs(position.y)==math.huge or math.abs(position.z)==math.huge then
                projectile.scoTacticalSweep=nil
                return nil
            end
            local sample=projectile.scoTacticalSweep
            if sample and sample.time==now then
                if sample.position.x~=position.x or sample.position.y~=position.y or sample.position.z~=position.z then
                    sample.position={x=position.x,y=position.y,z=position.z}
                    sample.previous=sample.position
                end
                return sample.previous
            end
            local state=projectile.scoTactical
            local previous=sample and sample.position or state and state.previous or position
            local elapsed=now-(sample and sample.time or state and state.born or now)
            -- Only adjacent simulation samples describe a continuous missile path.
            if elapsed<=0 or elapsed>Constants.TickTimeStep+1e-7 then previous=position end
            projectile.scoTacticalSweep={time=now,position={x=position.x,y=position.y,z=position.z},previous=previous}
            return previous
        end
        local function collisionReady(projectile)
            return not projectile.scoSourceNuke or GetGameTimeSeconds()+1e-7>=projectile.scoSourceNuke.born+2.5
        end
        local function candidates(kind)
            local result={}
            for _,registry in ipairs({Tactical.missiles,Source.targets}) do
                for index,p in pairs(registry) do
                    local destroyed=p.scoSourceThreat and p.scoSourceThreat.destroyed or p.scoTactical and p.scoTactical.destroyed
                    if __Entities.Projectiles[index]==p and not destroyed and kindOf(p)==kind and collisionReady(p) then result[index]=p end
                end
            end
            return result
        end
        function Source.Register(projectile)
            if projectile.scoSourceThreat then return end
            local additions=projectile.tp and projectile.tp.additions
            local metadata=additions and (additions.scoSourceProjectile or additions.scoSourceThreat)
            if not metadata then return end
            local tags={}
            for _,tag in ipairs(metadata.categories or {}) do tags[tag]=true end
            local kind=tags.STRATEGIC and tags.MISSILE and "strategic" or tags.TACTICAL and tags.MISSILE and "tactical" or tags.TORPEDO and "torpedo"
            if not kind then return end
            local defense=metadata.defense or {}
            projectile.scoSourceThreat={kind=kind,health=defense.Health or defense.MaxHealth or 1,
                radius=metadata.collisionRadius or (kind=="strategic" and 2 or 1),sourceId=metadata.sourceId}
            Source.targets[projectile.id.index]=projectile
            if kind=="tactical" then tacticalPrevious(projectile,Tactical.point(projectile.id),GetGameTimeSeconds()) end
        end
        local oldCreated=_G.SCO_SourceProjectileCreated
        function _G.SCO_SourceProjectileCreated(projectile)
            if oldCreated then oldCreated(projectile) end
            Source.Register(projectile)
        end
        function Source.Hit(projectile,damage)
            if type(damage)~='number' or damage~=damage or damage<=0 or damage==math.huge then return false end
            if projectile.scoTactical and projectile.scoTactical.config.tactical then return Tactical.HitMissile(projectile,damage) end
            local state=projectile.scoSourceThreat
            if not state or state.destroyed or not collisionReady(projectile) then return false end
            if state.invulnerableUntil and GetGameTimeSeconds()<state.invulnerableUntil then return false end
            state.health=state.health-damage
            local killed=state.health<=0
            if killed then state.destroyed=true end
            if _G.SCO_SourceProjectileIntercepted and _G.SCO_SourceProjectileIntercepted(projectile,damage,killed) then return true end
            if killed then
                -- An intercepted nuke receives a projectile hit, so its land rings never run.
                projectile:Destroy(0)
            end
            return true
        end
        function Source.SetInvulnerability(projectile,seconds)
            assert(type(seconds)=='number' and seconds>=0 and seconds<math.huge,'Invalid source projectile invulnerability')
            Source.Register(projectile)
            assert(projectile.scoSourceThreat,'Invulnerability requires a registered source threat').invulnerableUntil=GetGameTimeSeconds()+seconds
        end
        local function nearest(unit,contract,kind)
            local origin=Tactical.point(unit.id)
            if not origin then return end
            local best,bestDistance
            for index,p in pairs(candidates(kind or contract.targetClass)) do
                local position=Tactical.point(p.id)
                if position and unit.army:IsEnemy(Armies[p.armyId]) then
                    local x,z=position.x-origin.x,position.z-origin.z
                    local distance=math.sqrt(x*x+z*z)
                    if distance>=(contract.rangeMin or 0) and distance<=contract.rangeMax and (not best or distance<bestDistance or distance==bestDistance and index<best.id.index) then
                        best,bestDistance=p,distance
                    end
                end
            end
            return best
        end
        local function validTacticalTarget(unit,contract,target)
            if not target or kindOf(target)~="tactical" or not unit.army:IsEnemy(Armies[target.armyId])
                or target.scoSourceThreat and target.scoSourceThreat.destroyed
                or target.scoTactical and target.scoTactical.destroyed then return false end
            local origin,position=Tactical.point(unit.id),Tactical.point(target.id)
            if not origin or not position then return false end
            local x,z=position.x-origin.x,position.z-origin.z
            local distance=math.sqrt(x*x+z*z)
            return distance>=(contract.rangeMin or 0) and distance<=contract.rangeMax
        end
        local function fire(unit,weapon,state,contract,target,now)
            if contract.targetClass=="tactical" and not weapon.enabled then return false end
            if now<state.cooldown or contract.counted and unit.scoTactical.ammo<1 then return false end
            for _,id in ipairs(weapon.aimControllerIds or {}) do
                Engine.SetAimControllerTarget(id,target.id)
                local _,ready=Engine.GetAimControllerIsOnTarget(id)
                if not ready then return false end
            end
            local muzzle=unit:GetBoneId(contract.muzzles[state.rack])
            local origin,destination=muzzle and Tactical.point(muzzle),Tactical.point(target.id)
            if not origin or not destination then return false end
            local distance=length(origin,destination)
            if distance==0 then return false end
            local speed=contract.muzzleVelocity
            local velocity=EngineClasses.float3((destination.x-origin.x)*speed/distance,(destination.y-origin.y)*speed/distance,(destination.z-origin.z)*speed/distance)
            if contract.beam then
                Tactical.FireInterceptorBeam(unit,muzzle,destination,contract.beam.lifetime)
                Source.Hit(target,contract.damage)
            else
                local p=Tactical.Spawn(unit,contract.projectile,origin,destination,muzzle,contract.damage,0,velocity)
                if not p then return false end
                p.scoTactical.interceptorTarget=target.id
                p.scoTactical.depthChargeRadius=contract.depthChargeRadius
            end
            state.cooldown=now+contract.reload
            state.rack=state.rack%#contract.muzzles+1
            if contract.counted then unit.scoTactical.ammo=unit.scoTactical.ammo-1;Tactical.emit(unit) end
            return true
        end
        function Source.Advance(unit,now)
            if unit.dead or unit.deleted then return end
            Tactical.AdvanceBeamPulses(unit,now)
            local stun = _G.SCO_SourceStun
            if stun and stun.IsStunned(unit) then return end
            if not unit.scoSourceInterception or not unit:IsCompleted() then return end
            local permanent=unit.tp.additions.scoSourceInterception.permanentOpen
            if permanent and not unit.scoSourceInterception.opened then
                local sample=math.min(permanent.duration,(unit.scoSourceInterception.sample or 0)+Constants.TickTimeStep)
                unit.scoSourceInterception.sample=sample
                -- The Aeon completion callback already owns this same opening.
                -- Sampling a second clip would compete with its clamped playback.
                local motion=unit.tp.additions.aeonStructureMotion
                if not motion or motion.kind~="permanent_open" then
                    Engine.PlayAnimation(unit.id,unit.tp.visuals.animations[permanent.key].id,-10000+sample)
                end
                if sample<permanent.duration then return end
                unit.scoSourceInterception.opened=true
            end
            -- Pausing ammunition production does not rewind the completed silo.
            if unit.toggles and unit:GetPause() then return end
            for _,weapon in ipairs(unit.weapons or {}) do
                local contract=unit.tp.additions.scoSourceInterception.weapons[weapon.tp.scoSourceInterceptionLabel or weapon.tp.name]
                if contract and contract.targetClass then
                    local state=unit.scoSourceInterception[contract.sourceLabel]
                    local target=state.target and __Entities.Projectiles[state.target.index]
                    if now>=state.checkAt or not target or not Tactical.same(target.id,state.target)
                        or contract.targetClass=="tactical" and not validTacticalTarget(unit,contract,target) then
                        target=nearest(unit,contract)
                        state.target=target and target.id
                        state.checkAt=now+contract.interval
                    end
                    if target and unit.army:IsEnemy(Armies[target.armyId]) then fire(unit,weapon,state,contract,target,now) end
                end
            end
        end
        _G.SCO_SourceSiloAdvance=Source.Advance
        function _G.SCO_SourceIntercept(projectile,position,previous)
            local state=projectile.scoTactical
            local config=state.config
            local target=state.interceptorTarget and __Entities.Projectiles[state.interceptorTarget.index]
            if target and Tactical.same(target.id,state.interceptorTarget) and config.track then
                local destination=Tactical.point(target.id)
                if destination then Engine.SetHomingProjectileTargetPosition(projectile.id,destination) end
            end
            local ids,targets={},candidates(config.targetClass or 'tactical')
            for index in pairs(targets) do ids[#ids+1]=index end
            table.sort(ids)
            for _,index in ipairs(ids) do
                local threat=targets[index]
                local point=Tactical.point(threat.id)
                local previousThreat
                if (config.targetClass or 'tactical')=='tactical' then
                    previousThreat=tacticalPrevious(threat,point,GetGameTimeSeconds())
                    if previousThreat and state.born>=GetGameTimeSeconds() then previousThreat=point end
                    if not previousThreat then point=nil end
                end
                if point and Armies[projectile.armyId]:IsEnemy(Armies[threat.armyId]) then
                    local attractionRadius=state.depthChargeRadius or config.flareRadius
                    if attractionRadius and length(position,point)<=attractionRadius then
                        Engine.SetHomingProjectileTargetPosition(threat.id,position)
                        if threat.scoSourceThreat then threat.scoSourceThreat.decoy=projectile.id
                        else threat.scoTactical.decoy=projectile.id end
                    end
                    local radius=threat.scoSourceThreat and threat.scoSourceThreat.radius or threat.scoTactical.config.collisionRadius
                    local separation
                    if previousThreat then
                        separation=segment({x=previous.x-previousThreat.x,y=previous.y-previousThreat.y,z=previous.z-previousThreat.z},
                            {x=position.x-point.x,y=position.y-point.y,z=position.z-point.z},{x=0,y=0,z=0})
                    else separation=segment(previous,position,point) end
                    if separation<=radius+(config.collisionRadius or 0) then
                        Source.Hit(threat,projectile.damage)
                        if not config.persistOnMissileImpact then
                            state.destroyed=true;projectile:Destroy(0);return true
                        end
                    end
                end
            end
            return false
        end
        function _G.SCO_SourceNukeLaunched(projectile,unit,target)
            local old=projectile.scoTactical
            projectile.scoTactical=nil
            Source.Register(projectile)
            assert(projectile.scoSourceThreat,"Missing source strategic threat contract")
            projectile.scoSourceNuke={target=target,born=GetGameTimeSeconds(),source=unit,
                sourceId=unit.id,rings=unit.scoTactical.contract.nukeRings,nextTurn=GetGameTimeSeconds()+9.5,interval=.5,
                profile=assert(old.config.nukeProfile,"Source nuke movement profile missing")}
            -- Source muzzle velocity is zero; acceleration starts along the muzzle's local forward axis.
            Engine.SetHomingProjectileTargetPosition(projectile.id,EngineClasses.float3(old.previous.x,old.previous.y+10000,old.previous.z))
            Engine.SetHomingProjectileVelocity(projectile.id,EngineClasses.float3(0,0,0))
            Engine.SetHomingProjectileRotationSpeed(projectile.id,0)
            Source.NukeEffects(projectile,0)
        end
        function Source.NukeEffects(projectile,age)
            local state=projectile.scoSourceNuke
            local phase=age+1e-7>=5 and 3 or age+1e-7>=2.5 and 2 or 1
            phase=math.min(phase,state.profile.effectPhases or 3)
            if phase>(state.visualPhase or 0) then
                state.visualPhase=phase
                Session.ExecuteClientFunction.Send('SCOSourceNukePhase',{projectileId=projectile.id,tpId=projectile.tp.general.tpId,phase=phase})
            end
        end
        function Source.NukeImpact(projectile,position,tick,hitGlobalID)
            local state=projectile.scoSourceNuke
            if not state or state.destroyed or GetGameTimeSeconds()<state.born+2.5 then return end
            state.destroyed=true
            assert(_G.SCO_SourceApplyNukeRings,"Strategic shield snapshot owner missing")(position,state.rings,state.source)
            local radius=0
            for _,ring in ipairs(state.rings) do radius=math.max(radius,ring.radius) end
            Import("common/loading/unitTemplateLoader.lua").SCOMTreeKnockdown.NukeImpact(position,radius*2)
            projectile:Destroy(tick or 0,hitGlobalID)
        end
        function Source.NukeTick(projectile,position,now)
            local state=projectile.scoSourceNuke
            Source.NukeEffects(projectile,now-state.born)
            local seraphim=state.profile.seraphimMobile
            if seraphim and now>=state.born+5 and not state.pitchStarted then
                state.pitchStarted=true
                Engine.SetHomingProjectileRotationSpeed(projectile.id,5)
            end
            if now>=state.born+7.5 and not state.tracking then
                state.tracking=true
                Engine.SetHomingProjectileTargetPosition(projectile.id,state.target)
                Engine.SetHomingProjectileRotationSpeed(projectile.id,seraphim and 50 or 47.36)
            end
            if now>=state.nextTurn then
                if not state.cruise then
                    state.cruise=true
                    if seraphim then Engine.SetProjectileGravity(projectile.id,EngineClasses.float3(0,10,0))
                    else
                        Engine.SetHomingProjectileRotationSpeed(projectile.id,0)
                        Engine.SetHomingProjectileAcceleration(projectile.id,.001)
                    end
                end
                local x,z=position.x-state.target.x,position.z-state.target.z
                local distance=math.sqrt(x*x+z*z)
                if distance>150 then Engine.SetHomingProjectileRotationSpeed(projectile.id,0)
                elseif distance>75 and not seraphim then state.interval=.3
                elseif distance>32 and distance<=75 and not seraphim then state.interval=.1
                elseif distance<32 then Engine.SetHomingProjectileRotationSpeed(projectile.id,seraphim and 80 or 50) end
                state.nextTurn=now+state.interval
            end
        end
        local oldUpdate,oldDelete,oldWater=Projectile.Update,Projectile.Delete,Projectile.OnCrossedWaterline
        function Projectile:Update(...)
            Source.Register(self)
            local position=Tactical.point(self.id)
            if kindOf(self)=="tactical" then tacticalPrevious(self,position,GetGameTimeSeconds()) end
            if position and self.scoSourceNuke then Source.NukeTick(self,position,GetGameTimeSeconds()) end
            local threat=self.scoSourceThreat
            if threat and threat.decoy then
                local decoy=__Entities.Projectiles[threat.decoy.index]
                if decoy and Tactical.same(decoy.id,threat.decoy) then
                    local destination=Tactical.point(decoy.id)
                    if destination then Engine.SetHomingProjectileTargetPosition(self.id,destination) end
                else threat.decoy=nil end
            end
            return oldUpdate(self,...)
        end
        function Projectile:Delete(...)
            Source.targets[self.id.index]=nil
            return oldDelete(self,...)
        end
        function Projectile:OnCrossedWaterline(position,tick,waterGlobalID)
            if self.scoSourceNuke then
                local state=self.scoSourceNuke
                if state.profile.waterAt and GetGameTimeSeconds()>=state.born+state.profile.waterAt then Source.NukeImpact(self,position,tick,waterGlobalID) end
                return
            end
            local state=self.scoTactical
            if state and state.config.targetClass=="torpedo" then
                Engine.SetProjectileGravity(self.id,EngineClasses.float3(0,0,0))
                if state.config.sourceId:lower()=="cimantitorpedo01" then
                    Engine.SetHomingProjectileRotationSpeed(self.id,0)
                    Engine.SetHomingProjectileMaxSpeed(self.id,1)
                    Engine.SetHomingProjectileVelocity(self.id,EngineClasses.float3(0,-.25,0))
                end
                return
            end
            return oldWater(self,position,tick,waterGlobalID)
        end
        function HostUnit:SCOSourceInterceptionThread()
            while self.scoSourceInterception and not self.dead and not self.deleted do
                Source.Advance(self,GetGameTimeSeconds());WaitTicks(1)
            end
        end
        local oldInit=HostUnit.__init
        function HostUnit:__init(...)
            local result=oldInit(self,...)
            local contract=self.tp.additions and self.tp.additions.scoSourceInterception
            if contract then
                assert(allowed[self.tpId]==contract.sourceId,"Unscoped source interceptor")
                self.scoSourceInterception={}
                local hasDefense=false
                for label,weapon in pairs(contract.weapons) do
                    self.scoSourceInterception[label]={rack=1,cooldown=0,checkAt=0}
                    hasDefense=hasDefense or weapon.targetClass~=nil
                end
                if hasDefense and (not contract.silo or not contract.silo.autoIntercept) then self:NewThread(self.SCOSourceInterceptionThread) end
            end
            return result
        end
        Source.nearest,Source.kindOf=nearest,kindOf
        assert(_G.SCO_SourceInterceptionCollisionInstall,"Source collision owner must load first")(Source)
    end
end
-- Only source/target pairs whose missing defense and rig were proven.
do
local source=assert(_G.SCO_SourceInterception)
source.AllowUnit("uca2806","UAS0202")
source.AllowUnit("ucl3701","UAS0305")
source.AllowUnit("ucl4003","UAS0401")
source.AllowUnit("ucl4005","XAS0306")
source.AllowUnit("ucn1001","UAS0103")
source.AllowUnit("ucn3001","UAS0302")
source.AllowUnit("ucs1803","UAS0201")
source.AllowUnit("ucs2501","XAS0204")
source.AllowUnit("uen2002","UES0202")
source.AllowUnit("uen3001","UES0302")
source.AllowUnit("ugl4002","XRL0403")
source.AllowUnit("ugn2001","URS0201")
source.AllowUnit("ugn2002","URS0202")
source.AllowUnit("ugn3001","URS0302")
source.AllowUnit("ugn3003","URS0303")
source.AllowUnit("usn1002","XSS0203")
source.AllowUnit("usn2001","XSS0201")
source.AllowUnit("usn2002","XSS0202")
source.AllowUnit("usn3001","XSS0302")
source.AllowUnit("usn3004","XSS0304")
end
-- Ground cargo transport using source slots and native host-owned transforms.
local SCOCargoOrders = Import("host/managers/orders/hostOrderManager.lua")
local SCOCargoOrderTasks = Import("common/commonOrders.lua").OrderTasks
local SCOCargoLayers = Import("common/layers.lua")
local SCOCargoMap = Import("common/mapUtils.lua")
local SCOCargoCommands = Import("common/commands/definitions/units.lua")

local function CargoConfig(unit)
    return unit and unit.tp and unit.tp.additions and unit.tp.additions.scoCargo
end

local function CargoAlive(unit)
    return unit and not unit.dead and GetUnitById(unit.id) == unit
end

local function CargoDistance(a, b)
    return (a.x-b.x)^2 + (a.z-b.z)^2
end

function HostUnit:SCOStopAirStorageFlight()
    if self.TakeoffBehaviourStop then self:TakeoffBehaviourStop() end
    if self.LandingBehaviorStop then self:LandingBehaviorStop() end
    if self.CancelLandWhenIdle then self:CancelLandWhenIdle() end
end

function HostUnit:SCOResumeAirStorageFlight()
    if self.SetAirborneLayers then
        self.isAirborne = true
        self:SetAirborneLayers()
    end
end

local function CargoPickupRange(carrier, cargo)
    if CargoConfig(carrier).airStorage and cargo.CirclesWhenHolding
        and cargo:CirclesWhenHolding() then
        return math.max(4, (cargo.tp.movement.orbitRange or cargo:GetTurnRadius()) + 0.5)
    end
    return 4
end

local function CargoPlay(unit, name)
    local animations = unit.tp.visuals and unit.tp.visuals.animations
    local animation = animations and (animations[name] or animations[name == "cargoFold" and "fold" or "unfold"])
    if animation and animation.id then Engine.PlayAnimation(unit.id, animation.id, .1) end
end

local function CargoState(carrier, cargo, attached, count)
    if SCOCargoCommands.SCOSourceCargoState then
        SCOCargoCommands.SCOSourceCargoState.Send(carrier.id, cargo.id, attached, count or #(carrier.scoCargo or {}))
    end
end

local function CargoEligible(carrier, cargo, manufactured)
    local config = CargoConfig(cargo)
    local carrierConfig = CargoConfig(carrier)
    if not CargoAlive(carrier) or not CargoAlive(cargo) or carrier == cargo
        or not config or not carrierConfig or #carrierConfig.slots == 0
        or not carrier.army:IsAlly(cargo.army) or not cargo.army:IsAlly(carrier.army)
        or not cargo:IsCompleted() or not carrier:IsCompleted()
        or cargo:IsPlacementGhost() or cargo.scoCargoCarrier or cargo.scoCargoReleasing
        or (cargo.scoCargoPendingCarrier and cargo.scoCargoPendingCarrier ~= carrier)
        or cargo.scoFactoryColliderPinOwner or cargo.scoTractorTargetKey
        or (config.commander and not carrierConfig.canCarryCommander)
    then return false end
    if carrierConfig.airStorage then
        if not config.airPortable or (not manufactured and not carrier:SCOAirDeckAvailable())
            or #(cargo.scoCargo or {}) > 0 then return false end
    elseif not config.portable then return false end
    for _, method in ipairs({"IsBuildProcessEnabled", "IsReclaimProcessEnabled", "IsRepairProcessEnabled", "IsCaptureProcessEnabled"}) do
        if cargo[method] and cargo[method](cargo) then return false end
    end
    return carrierConfig.airStorage or (config.cargoClass >= 1 and config.cargoClass <= 3)
end

local function CargoIssueMove(carrier,position)
    carrier.scoCargoIssuingOrder=true
    SCOCargoOrders.HostIssueOrder(SCOCargoOrderTasks.MOVE,{carrier},false,position)
    carrier.scoCargoIssuingOrder=nil
end

function HostUnit:SCOCargoChooseSlot(cargo)
    local config = CargoConfig(self)
    local cargoConfig = CargoConfig(cargo)
    if not config or not cargoConfig then return nil end
    local occupied = self.scoCargoOccupied or {}
    for index, slot in ipairs(config.slots) do
        local accepts = (config.airStorage and cargoConfig.airPortable) or slot.cargoClass == cargoConfig.cargoClass
            or (config.genericUpTo and config.genericUpTo >= cargoConfig.cargoClass)
        if accepts and #slot.occupies > 0 then
            local free = true
            for _, cell in ipairs(slot.occupies) do if occupied[cell] then free = false end end
            if free then return index end
        end
    end
end

local function CargoReserve(carrier, cargo, index, reserve)
    local slot = CargoConfig(carrier).slots[index]
    carrier.scoCargoOccupied = carrier.scoCargoOccupied or {}
    for _, cell in ipairs(slot.occupies) do
        if reserve then carrier.scoCargoOccupied[cell] = cargo
        elseif carrier.scoCargoOccupied[cell] == cargo then carrier.scoCargoOccupied[cell] = nil end
    end
end

local function CargoRotate(v, q)
    q = q.value
    local x, y, z = v[1], v[2], v[3]
    local tx, ty, tz = 2*(q.y*z-q.z*y), 2*(q.z*x-q.x*z), 2*(q.x*y-q.y*x)
    return x+q.w*tx+q.y*tz-q.z*ty, y+q.w*ty+q.z*tx-q.x*tz, z+q.w*tz+q.x*ty-q.y*tx
end

function HostUnit:SCOCargoPin(record)
    local cargo = record.unit
    if not CargoAlive(cargo) then return false end
    local status, point = Engine.GetGlobalEntityWorldPosition(record.bone)
    if status ~= EngineErrorCode.Success then return false end
    local orientation = self:GetOrientation()
    local x, y, z = CargoRotate(CargoConfig(cargo).attachOffset, orientation)
    cargo:SetOrientation(orientation)
    cargo:SetPosition(EngineClasses.float3(point.x-x, point.y-y, point.z-z))
    return true
end

function HostUnit:SCOCargoAttach(cargo, index, manufactured)
    if not CargoEligible(self, cargo, manufactured) then return false end
    local config,cargoConfig=CargoConfig(self),CargoConfig(cargo)
    local slot = config.slots[index]
    if not slot or #slot.occupies==0 or not ((config.airStorage and cargoConfig.airPortable) or slot.cargoClass==cargoConfig.cargoClass
        or (config.genericUpTo and config.genericUpTo>=cargoConfig.cargoClass)) then return false end
    for _,cell in ipairs(slot.occupies) do
        local owner=(self.scoCargoOccupied or {})[cell]
        if owner and owner~=cargo then return false end
    end
    local bone = self:GetBoneId(slot.bone)
    if not bone then return false end
    local status = Engine.GetGlobalEntityWorldPosition(bone)
    if status ~= EngineErrorCode.Success then return false end
    local _, collider = Engine.GetVolumeColliderEnabled(cargo.id)
    local record = { unit = cargo, slot = index, bone = bone, collider = collider,
        targetable = cargo.isTargetable, weapons = {}, shieldToggle = cargo:GetShieldToggle(),
        updateAnimations = rawget(cargo, "UpdateAnimations"), orientation=cargo:GetOrientation() }
    cargo.scoCargoIssuingOrder=true
    SCOCargoOrders.HostClearOrder({cargo})
    cargo.scoCargoIssuingOrder=nil
    if config.airStorage then cargo:SCOStopAirStorageFlight() end
    cargo.scoCargoPendingCarrier = nil
    cargo.scoCargoCarrier = self
    cargo.UpdateAnimations = function() end
    Engine.SetMovementEnabled(cargo.id, false)
    cargo:SetTargetable(false)
    Engine.SetVolumeColliderEnabled(cargo.id, false)
    cargo:SetShieldToggle(false)
    for _, weapon in ipairs(cargo.weapons or {}) do
        record.weapons[#record.weapons+1] = { weapon = weapon, wanted = weapon.wantsEnabled == true }
        if config.airStorage or not CargoConfig(cargo).canFire then weapon:SetEnabled(false) end
    end
    self.scoCargo = self.scoCargo or {}
    self.scoCargo[#self.scoCargo+1] = record
    CargoReserve(self, cargo, index, true)
    if not config.airStorage then CargoPlay(cargo, "cargoFold") end
    self:SCOCargoPin(record)
    CargoState(self, cargo, true)
    return true
end

local CargoDropReservations={}
local function CargoDropRadius(cargo)
    local info=cargo.tp.collisionInfo or {}
    local size,offset=info.collisionSize or {x=1,z=1},info.centerOffset or {x=0,z=0}
    return math.max(size.x or 1,size.z or 1)/2+math.abs(offset.x)+math.abs(offset.z)+.1
end

local function CargoDropClear(cargo,position)
    local radius=CargoDropRadius(cargo)
    for other,point in pairs(CargoDropReservations) do
        if other~=cargo and CargoAlive(other)
            and CargoDistance(position,point)<(radius+CargoDropRadius(other))^2 then return false end
    end
    local layer=SCOCargoLayers.GetDefaultNavigationLayerFromTemplate(cargo.tp)
    -- Test the entire conservative horizontal footprint against native nav cells.
    local rows=math.max(1,math.ceil(radius*4))
    for row=0,rows do
        local z=position.z-radius+2*radius*row/rows
        local a,b=EngineClasses.float2(position.x-radius,z),EngineClasses.float2(position.x+radius,z)
        if not SCOCargoMap.IsPositionOnMap(EngineClasses.float3(a.x,position.y,a.y))
            or not SCOCargoMap.IsPositionOnMap(EngineClasses.float3(b.x,position.y,b.y)) then return false end
        local status,result=Engine.NavmapLineCast(a,b,layer)
        if status~=EngineErrorCode.Success or result~=NavmapLineCastResult.NoHit then return false end
    end
    local info=cargo.tp.collisionInfo or {}
    local size,offset=info.collisionSize or {y=1},info.centerOffset or {y=0}
    local center=EngineClasses.float3(position.x,position.y+(offset.y or 0),position.z)
    local bounds=EngineClasses.float3(radius*2,(size.y or 1)+.1,radius*2)
    local rotation=Engine.EulerToQuaternion(EngineClasses.float3(0,0,0),RotationOrder.Default)
    local hits=Engine.BoxCast(CollisionWorld.Collision,center,bounds,rotation,
        SCOCargoLayers.CollisionLayer.Units+SCOCargoLayers.CollisionLayer.Props)
    for _,hit in ipairs(hits) do
        local id=hit.colliderGlobalID
        if id and id.index~=0 and Engine.IsValidGlobalID(id) then
            local status,root=Engine.GetGlobalEntityRoot(id)
            local own=id.index==cargo.id.index and id.version==cargo.id.version
                or (status==EngineErrorCode.Success and root.index==cargo.id.index and root.version==cargo.id.version)
            if not own then return false end
        end
    end
    return true
end

function HostUnit:SCOCargoGroundPoint(cargo, position, number)
    local spacing=CargoDropRadius(cargo)*2+.3
    for attempt = 1, 64 do
        local angle = (attempt+number*7)*2.399963229728653
        local radius = spacing*(1+math.floor((attempt-1)/8))
        local p = EngineClasses.float3(position.x+math.cos(angle)*radius, position.y, position.z+math.sin(angle)*radius)
        if SCOCargoMap.IsPositionOnMap(p) then
            local status,height=Engine.SampleTerrainHeight(p)
            if status==EngineErrorCode.Success then
                p.y=height+(cargo.tp.movement.preferredAltitude or 0)
                if CargoDropClear(cargo,p) then return p end
            end
        end
    end
end

function HostUnit:SCOCargoDetach(record, position)
    local cargo = record.unit
    if CargoAlive(cargo) and not position then return false end
    CargoReserve(self, cargo, record.slot, false)
    if not CargoAlive(cargo) then return true end
    cargo:SetPosition(position)
    cargo:SetOrientation(record.orientation)
    cargo.scoCargoCarrier = nil
    cargo:SetTargetable(record.targetable ~= false)
    Engine.SetVolumeColliderEnabled(cargo.id, record.collider ~= false)
    cargo:SetShieldToggle(record.shieldToggle)
    for _, state in ipairs(record.weapons) do state.weapon:SetEnabled(state.wanted) end
    if CargoConfig(self).airStorage then
        cargo.UpdateAnimations = record.updateAnimations
        cargo:SCOResumeAirStorageFlight()
        Engine.SetMovementEnabled(cargo.id, true)
        cargo:UpdateAnimations()
        CargoState(self, cargo, false, math.max(0,#(self.scoCargo or {})-1))
        return true
    end
    CargoPlay(cargo, "cargoUnfold")
    -- Hold navigation until the source unfold finishes; do not replay walking
    -- over the drop pose. This coroutine belongs to the cargo, not the carrier.
    local config = CargoConfig(cargo)
    cargo.scoCargoReleasing = true
    cargo:NewThread(function(unit)
        WaitSeconds(config.unfoldDuration or .1)
        if CargoAlive(unit) and not unit.scoCargoCarrier then
            unit.scoCargoReleasing = nil
            unit.UpdateAnimations = record.updateAnimations
            Engine.SetMovementEnabled(unit.id, true)
            unit:UpdateAnimations()
        end
        CargoDropReservations[unit]=nil
    end)
    CargoState(self, cargo, false, math.max(0,#(self.scoCargo or {})-1))
    return true
end

local function CargoReleasePending(carrier,pending)
    local cargo=pending.unit
    if cargo.scoCargoPendingCarrier==carrier then cargo.scoCargoPendingCarrier=nil end
    CargoReserve(carrier,cargo,pending.slot,false)
end

local function CargoRemovePending(carrier,cargo)
    if carrier.scoCargoPending and carrier.scoCargoPending.unit==cargo then
        CargoReleasePending(carrier,carrier.scoCargoPending)
        carrier.scoCargoPending=nil
    end
    for index=#(carrier.scoCargoLoadQueue or {}),1,-1 do
        local pending=carrier.scoCargoLoadQueue[index]
        if pending.unit==cargo then
            CargoReleasePending(carrier,pending)
            table.remove(carrier.scoCargoLoadQueue,index)
        end
    end
end

function HostUnit:SCOCancelCargoTasks()
    if self.scoCargoPendingCarrier then CargoRemovePending(self.scoCargoPendingCarrier,self) end
    if self.scoCargoPending then CargoReleasePending(self,self.scoCargoPending) end
    for _,pending in ipairs(self.scoCargoLoadQueue or {}) do CargoReleasePending(self,pending) end
    self.scoCargoPending=nil
    self.scoCargoLoadQueue={}
    self.scoCargoUnloadPosition=nil
    self.scoCargoNextDropSearch=nil
    self.scoCargoRequestClientID=nil
end

local function CargoNextPickup(carrier)
    if carrier.scoCargoPending then return end
    local queue=carrier.scoCargoLoadQueue or {}
    if #queue==0 then carrier.scoCargoRequestClientID=nil;return end
    local pending=table.remove(queue,1)
    carrier.scoCargoPending=pending
    pending.expires=_G.Time+60
    pending.lastApproach=_G.Time
    local aircraft = CargoConfig(carrier).airStorage
    pending.approach=aircraft and carrier:GetPosition() or pending.unit:GetPosition()
    CargoIssueMove(aircraft and pending.unit or carrier,pending.approach)
end

function HostUnit:SCOCargoDriver()
    while CargoAlive(self) do
        CargoNextPickup(self)
        local pending = self.scoCargoPending
        if pending then
            local cargo = pending.unit
            if not CargoEligible(self,cargo) or _G.Time > pending.expires then
                CargoReleasePending(self,pending)
                self.scoCargoPending=nil
            elseif CargoDistance(self:GetPosition(),cargo:GetPosition()) <= CargoPickupRange(self,cargo)^2 then
                self.scoCargoPending=nil
                if not self:SCOCargoAttach(cargo,pending.slot) then CargoReleasePending(self,pending) end
            elseif _G.Time-pending.lastApproach>=1
                and CargoDistance(pending.approach,CargoConfig(self).airStorage and self:GetPosition() or cargo:GetPosition())>1 then
                pending.lastApproach=_G.Time
                local aircraft=CargoConfig(self).airStorage
                pending.approach=aircraft and self:GetPosition() or cargo:GetPosition()
                CargoIssueMove(aircraft and cargo or self,pending.approach)
            end
        end
        local cargo = self.scoCargo or {}
        for index = #cargo, 1, -1 do
            local record = cargo[index]
            if not CargoAlive(record.unit) then
                CargoReserve(self,record.unit,record.slot,false)
                table.remove(cargo,index)
                CargoState(self,record.unit,false)
            elseif CargoConfig(self).airStorage and
                (not self.army:IsAlly(record.unit.army) or not record.unit.army:IsAlly(self.army)) then
                -- SetArmy may change allegiance without the native capture/delete
                -- path. Release the old owner's aircraft and restore its state.
                local point=self:SCOAirLaunchPoint(record.unit)
                if self:SCOCargoDetach(record,point) then table.remove(cargo,index) end
            else
                self:SCOCargoPin(record)
            end
        end
        local destination = self.scoCargoUnloadPosition
        if destination and CargoConfig(self).airStorage then
            if self:SCOAirDeckAvailable() then
                local record=cargo[#cargo]
                if record then
                    local point=self:SCOAirLaunchPoint(record.unit)
                    if self:SCOCargoDetach(record,point) then
                        table.remove(cargo,#cargo)
                        SCOCargoOrders.HostIssueOrder(SCOCargoOrderTasks.MOVE,{record.unit},false,destination)
                    end
                end
                if #cargo==0 then self.scoCargoUnloadPosition=nil end
            end
        elseif destination and CargoDistance(self:GetPosition(),destination) <= 16
            and _G.Time>=(self.scoCargoNextDropSearch or 0) then
            self.scoCargoNextDropSearch=_G.Time+.5
            for index = #cargo,1,-1 do
                local record=cargo[index]
                local point=self:SCOCargoGroundPoint(record.unit,destination,index)
                if point then
                    -- Native transform/collider writes are consumed on the next tick.
                    -- Reserve the footprint across transports until unfolding ends.
                    CargoDropReservations[record.unit]=point
                    record.unit:SetOrientation(record.orientation)
                    record.unit:SetPosition(point)
                    WaitTicks(1)
                    local status,current=Engine.GetGlobalEntityWorldPosition(record.unit.id)
                    local synced=status==EngineErrorCode.Success and CargoDistance(current,point)<.0001
                        and math.abs(current.y-point.y)<.01
                    if CargoAlive(self) and CargoAlive(record.unit) and record.unit.scoCargoCarrier==self
                        and synced and self.scoCargoUnloadPosition==destination and CargoDropClear(record.unit,point) then
                        if self:SCOCargoDetach(record,point) then
                            self.scoCargoNextDropSearch=nil
                            for slot=#cargo,1,-1 do
                                if cargo[slot]==record then table.remove(cargo,slot);break end
                            end
                        end
                    else
                        CargoDropReservations[record.unit]=nil
                        if CargoAlive(self) and CargoAlive(record.unit) then self:SCOCargoPin(record) end
                    end
                    break
                end
            end
            -- Blocked drops remain aboard and retry; STOP/new orders cancel them.
            if #cargo==0 then self.scoCargoUnloadPosition=nil end
        end
        if not self.scoCargoPending and #(self.scoCargoLoadQueue or {})==0 and #cargo==0 then break end
        WaitTicks(1)
    end
    self.scoCargoDriverRunning = false
end

local function CargoStartDriver(unit)
    if not unit.scoCargoDriverRunning then
        unit.scoCargoDriverRunning = true
        unit:NewThread(unit.SCOCargoDriver)
    end
end

function HostUnit:SCOStartCargoDriver()
    CargoStartDriver(self)
end

function HostUnit:SCORequestCargoLoad(cargo)
    if not CargoEligible(self,cargo) or cargo.scoCargoPendingCarrier then return false end
    local slot = self:SCOCargoChooseSlot(cargo)
    if not slot then return false end
    CargoReserve(self,cargo,slot,true)
    cargo.scoCargoPendingCarrier = self
    self.scoCargoUnloadPosition=nil
    self.scoCargoLoadQueue=self.scoCargoLoadQueue or {}
    self.scoCargoLoadQueue[#self.scoCargoLoadQueue+1]={unit=cargo,slot=slot}
    CargoNextPickup(self)
    CargoStartDriver(self)
    return true
end

function HostUnit:SCORequestCargoUnload(position)
    if not CargoAlive(self) or not self.scoCargo or #self.scoCargo == 0
        or not SCOCargoMap.IsPositionOnMap(position) then return false end
    if CargoConfig(self).airStorage and not self:SCOAirDeckAvailable() then return false end
    self:SCOCancelCargoTasks()
    self.scoCargoUnloadPosition = position
    if not CargoConfig(self).airStorage then CargoIssueMove(self,position) end
    CargoStartDriver(self)
    return true
end

local SCOCargoPreviousOrder = HostUnit.CanBeAssignedToOrder
function HostUnit:CanBeAssignedToOrder(order)
    if self.scoCargoCarrier or self.scoCargoReleasing then return false end
    return SCOCargoPreviousOrder(self,order)
end

local function CargoCleanupAll(self)
    if self.scoCargoCarrier then
        local carrier=self.scoCargoCarrier
        for index=#(carrier.scoCargo or {}),1,-1 do
            local record=carrier.scoCargo[index]
            if record.unit==self then
                CargoReserve(carrier,self,record.slot,false)
                table.remove(carrier.scoCargo,index)
                CargoState(carrier,self,false)
            end
        end
        self.scoCargoCarrier=nil
    end
    self:SCOCancelCargoTasks()
    CargoDropReservations[self]=nil
    local cargo = self.scoCargo or {}
    self.scoCargo = {}
    for _, record in ipairs(cargo) do
        CargoReserve(self,record.unit,record.slot,false)
        if CargoAlive(record.unit) then
            record.unit.scoCargoCarrier = nil
            record.unit:Destroy(1,DestroyType.Kinetic)
        end
    end
end
local SCOCargoPreviousDestroy = HostUnit.OnDestroy
function HostUnit:OnDestroy(destroyType)
    CargoCleanupAll(self)
    return SCOCargoPreviousDestroy(self,destroyType)
end
local SCOCargoPreviousDelete = HostUnit.Delete
function HostUnit:Delete()
    CargoCleanupAll(self)
    return SCOCargoPreviousDelete(self)
end
-- SCOM source death animation closure 1.0.0
-- The configured clips already exist in the pack. Existing specialized death
-- owners have no scoSourceDeath contract and keep their original lifecycle.
local SCO_SourceDeathInherited = HostUnit.DeathThread

local function SCO_SourceDeathVariant(variants)
    local total = 0
    for _, variant in ipairs(variants) do total = total + variant.weight end
    assert(total > 0, "Source death weights are empty")
    local choice = math.random(total)
    for _, variant in ipairs(variants) do
        choice = choice - variant.weight
        if choice <= 0 then return variant end
    end
    error("Source death weighted selection failed")
end

function HostUnit:DeathThread(overkillRatio)
    -- Airborne wrecks inherit flight velocity immediately. A root-fixed
    -- source death clip must not hold their gravity controller for seconds.
    if self:HasTags(Tags.AIR) and not self:HasTags(Tags.NAVAL)
        and not self:HasTags(Tags.ORBITAL) and self.isAirborne ~= false then
        return SCO_SourceDeathInherited(self, overkillRatio)
    end
    local config = self.tp.additions and self.tp.additions.scoSourceDeath
    if not config or not self:IsCompleted() then
        return SCO_SourceDeathInherited(self, overkillRatio)
    end
    if self.deleted or self.scoSourceDeathStarted then return end
    assert(self.dead, "Source death must run after native OnDestroy")
    self.scoSourceDeathStarted = true
    self.isAnimated = false
    local variant = SCO_SourceDeathVariant(config.variants)
    local animation = self.tp.visuals.animations[variant.key]
    assert(animation and animation.id and animation.playbackMode == AnimationPlaybackMode.Clamp,
        "Source death animation is not registered with Clamp")
    -- Preserve the inherited movement/crash owner. In particular, do not freeze
    -- aircraft in midair or add a second sinking/ground-height controller.
    if config.hasMovement then Engine.SetMovementCollisionMask(self.id, 0) end
    Engine.SetAnimatorEnabled(self.id, true)
    local rate = variant.rateMin
    if variant.rateMax ~= rate then
        -- Hundredths retain authored .75/1.25 bounds as well as tenths. All
        -- randomness is host-owned; clients receive the same sampled clock.
        rate = math.random(math.floor(rate * 100 + 0.5),
            math.floor(variant.rateMax * 100 + 0.5)) / 100
    end
    assert(rate > 0 and variant.durationSeconds > 0, "Invalid source death timing")
    local elapsed = 0
    while not self.deleted and elapsed < variant.durationSeconds do
        Engine.PlayAnimation(self.id, animation.id, -10000 + elapsed)
        local step = math.min(0.1, (variant.durationSeconds - elapsed) / rate)
        WaitSeconds(step)
        elapsed = math.min(variant.durationSeconds, elapsed + step * rate)
    end
    if not self.deleted then
        Engine.PlayAnimation(self.id, animation.id, -10000 + variant.durationSeconds)
        return SCO_SourceDeathInherited(self, overkillRatio)
    end
end
-- Source Novax launcher/satellite and Ythotha/Othuy lifecycle.
local SpecialCommands = Import("common/commands/definitions/units.lua")
local SpecialOrders = Import("host/managers/orders/hostOrderManager.lua")
local SpecialTasks = Import("common/commonOrders.lua").OrderTasks
local SpecialMap = Import("common/mapUtils.lua")
local SpecialDamage = Import("host/collisionUpdate.lua")

local function Config(unit)
    return unit and unit.tp and unit.tp.additions and unit.tp.additions.scoSpecial
end
local function IsNovaxSatellite(unit)
    local cfg = Config(unit)
    return cfg and cfg.kind == "novaxSatellite"
end

-- XEA0002 is UNTARGETABLE and its source OnDamage is a no-op. Enforce that
-- contract through promotion/capture resets, without blocking the explicit
-- Destroy/Delete calls that link its lifetime to the vulnerable control center.
local PreviousTargetable = HostUnit.SetTargetable
function HostUnit:SetTargetable(enabled)
    if IsNovaxSatellite(self) then enabled = false end
    return PreviousTargetable(self, enabled)
end

local PreviousDamage = HostUnit.TakeDamage
function HostUnit:TakeDamage(...)
    if IsNovaxSatellite(self) then return end
    return PreviousDamage(self, ...)
end

local PreviousAttackValid = HostUnit.AttackBehaviorIsValidFor
function HostUnit:AttackBehaviorIsValidFor(target, ...)
    if IsNovaxSatellite(target) then return false end
    return PreviousAttackValid(self, target, ...)
end

local function Alive(unit)
    return unit and not unit.dead and not unit.deleted and GetUnitById(unit.id)==unit
end
local function Event(unit,name,bone)
    if SpecialCommands.SCOSourceSpecialEvent then
        SpecialCommands.SCOSourceSpecialEvent.Send(unit.id,name,bone or "")
    end
end
local function Play(unit,name)
    local animation=unit.tp.visuals.animations["scoSpecial_"..name]
    if not animation or not animation.id then return 0 end
    Engine.PlayAnimation(unit.id,animation.id,.1)
    return animation.duration
end
local function Weapons(unit,enabled)
    for _,weapon in ipairs(unit.weapons or {}) do
        if not weapon.isDeathExplosion then weapon:SetEnabled(enabled) end
    end
end
local function HoldAnimation(unit)
    unit.scoSpecialPreviousAnimations=unit.scoSpecialPreviousAnimations or unit.UpdateAnimations
    unit.UpdateAnimations=function() end
end

function HostUnit:SCOSpecialSatelliteOpen()
    if self.scoSpecialReleased or not Alive(self) then return end
    self.scoSpecialReleased=true
    self.scoSpecialAttached=false
    self.scoSpecialInitialized=true
    self.TakeoffBehaviourStart=self.scoSpecialTakeoff or self.TakeoffBehaviourStart
    -- Air movement's zero altitude-change rate snaps straight to altitude 75.
    -- The native takeoff curve starts at the launcher lift's final position.
    self:TakeoffBehaviourStart()
    HoldAnimation(self)
    WaitSeconds(Play(self,"aopen01"))
    if not Alive(self) then return end
    local duration=Play(self,"aopen02")
    Event(self,"hideShells")
    WaitSeconds(duration)
    if Alive(self) then Weapons(self,true) end
end

function HostUnit:SCOSpecialLauncherOpen()
    local cfg=Config(self)
    HoldAnimation(self)
    WaitSeconds(Play(self,"aopen"))
    if not Alive(self) then return end
    local bone=self:GetBoneId(cfg.attachBone)
    if not bone then return end -- source contract validates this before packaging
    local status,position=Engine.GetGlobalEntityWorldPosition(bone)
    if status~=EngineErrorCode.Success then return end
    for name,effect in pairs(cfg.effects) do if effect.loop then Event(self,name) end end
    local child=CreateUnit(self.army.id,cfg.child,position,self:GetOrientation(),1)
    self.scoSpecialChild=child
    child.scoSpecialParent=self
    child.scoSpecialAttached=true
    Weapons(child,false)
    Engine.SetMovementEnabled(child.id,false)
    local ticks=math.ceil(Play(self,"aopen01")/Constants.TickTimeStep-1e-7)
    for _=1,ticks do
        if not Alive(self) or not Alive(child) then return end
        local result,point=Engine.GetGlobalEntityWorldPosition(bone)
        if result==EngineErrorCode.Success then
            child:SetPosition(point)
            child:SetOrientation(self:GetOrientation())
        end
        WaitTicks(1)
    end
    if not Alive(self) or not Alive(child) then return end
    local result,point=Engine.GetGlobalEntityWorldPosition(bone)
    if result==EngineErrorCode.Success then
        child:SetPosition(point)
        child:SetOrientation(self:GetOrientation())
    end
    Event(self,"launch1");Event(self,"launch2")
    child:NewThread(child.SCOSpecialSatelliteOpen)
end

function HostUnit:SCOSpecialResidualLife()
    local cfg=Config(self)
    self:SetCanTakeDamage(false)
    self:SetCanBeKilled(false)
    self:SetTargetable(false)
    Event(self,"hideModel");Event(self,"ambient");Event(self,"spawn")
    local center=self:GetPosition()
    -- Source queues 100 independent moves around the initial location.
    for _=1,100 do
        local point=EngineClasses.float3(center.x+(math.random()*2-1)*cfg.moveRadius,
            center.y,center.z+(math.random()*2-1)*cfg.moveRadius)
        if SpecialMap.IsPositionOnMap(point) then
            local result,height=Engine.SampleTerrainHeight(point)
            if result==EngineErrorCode.Success then
                point.y=height
                SpecialOrders.HostIssueOrder(SpecialTasks.MOVE,{self},true,point)
            end
        end
    end
    WaitSeconds(cfg.lifetime)
    if Alive(self) then
        self:SetCanBeKilled(true)
        self:Destroy(1,DestroyType.Unspecified)
    end
end

function HostUnit:SCOSpecialYthothaDeath(overkillRatio)
    local cfg=Config(self)
    HoldAnimation(self)
    Play(self,math.random(1,2)==1 and "adeath01" or "adeath02")
    Event(self,"explosion",cfg.bigBones[math.random(1,#cfg.bigBones)])
    WaitSeconds(cfg.initialDelay)
    if self.deleted then return end
    local bones={}
    for i,bone in ipairs(cfg.explosionBones) do bones[i]=bone end
    for _=1,math.random(4,6) do
        local index=math.random(1,#bones)
        Event(self,"explosion",table.remove(bones,index))
        WaitTicks(math.random(1,3))
        if self.deleted then return end
    end
    local damage=cfg.deathDamage
    Event(self,"deathPulse")
    SpecialDamage.ProcessAreaDamage(self:GetPosition(),damage.DamageRadius,damage.Damage,self.army,damage.DamageFriendly)
    WaitSeconds(cfg.finalDelay)
    if self.deleted then return end
    Event(self,"explosion","Torso")
    self:OnSpawnWreckage(overkillRatio or 0)
    CreateUnit(self.army.id,cfg.child,self:GetPosition(),GetIdentityQuaternion(),1)
    self:Delete()
end

function HostUnit:SCOSpecialBegin()
    WaitTicks(1) -- derived native completion methods finish before attachment
    if not Alive(self) or self.scoSpecialInitialized then return end
    local cfg=Config(self)
    if cfg.kind=="novaxSatellite" and self.scoSpecialAttached then return end
    self.scoSpecialInitialized=true
    if cfg.kind=="novaxLauncher" then self:SCOSpecialLauncherOpen()
    elseif cfg.kind=="novaxSatellite" then self:SCOSpecialSatelliteOpen()
    elseif cfg.kind=="othuy" then self:SCOSpecialResidualLife() end
end

local PreviousComplete=HostUnit.OnStopBeingBuilt
function HostUnit:OnStopBeingBuilt()
    local result=PreviousComplete(self)
    local cfg=Config(self)
    if cfg and self:IsCompleted() then
        if cfg.kind=="novaxSatellite" then
            self:SetCanTakeDamage(false)
            self:SetTargetable(false)
            Weapons(self,false)
            self.scoSpecialTakeoff=self.TakeoffBehaviourStart
            self.TakeoffBehaviourStart=function() end
        elseif cfg.kind=="othuy" then
            self:SetCanTakeDamage(false)
            self:SetCanBeKilled(false)
            self:SetTargetable(false)
        end
        self:NewThread(self.SCOSpecialBegin)
    end
    return result
end

local PreviousExplosions=HostUnit.CreateDeathExplosions
function HostUnit:CreateDeathExplosions()
    if Config(self) and Config(self).kind=="ythotha" then return end
    local death = self.tp and self.tp.additions and self.tp.additions.scoFieldFixParagonDeath
    if self.tpId=="ucs4102" and death then
        -- Native OnDestroy owns the kill/delete distinction. Retain source
        -- DoDeathWeapon's construction guard and prevent repeated callbacks.
        if not self.dead or not self:IsCompleted() or self:IsPlacementGhost()
            or self.scoParagonDeathDamageApplied then return end
        self.scoParagonDeathDamageApplied=true
        -- Reuse the canonical nuke owner for allied damage, shield snapshots,
        -- duplicate-collider suppression and the dying launcher's attribution.
        SCO_SourceApplyNukeRings(self:GetPosition(),death.rings,self)
        return
    end
    return PreviousExplosions(self)
end

local PreviousDestroy=HostUnit.OnDestroy
function HostUnit:OnDestroy(destroyType)
    local cfg=Config(self)
    if cfg and not self.scoSpecialUnlinking then
        self.scoSpecialUnlinking=true
        self:SetCanTakeDamage(false)
        local linked=cfg.kind=="novaxLauncher" and self.scoSpecialChild or
            (cfg.kind=="novaxSatellite" and self.scoSpecialParent)
        if Alive(linked) then
            linked.scoSpecialUnlinking=true
            if destroyType==DestroyType.Delete then linked:Delete()
            else linked:Destroy(0,destroyType) end
        end
        if cfg.kind=="ythotha" and destroyType~=DestroyType.Delete and self:IsCompleted() then
            self.DeathThread=self.SCOSpecialYthothaDeath
        end
    end
    return PreviousDestroy(self,destroyType)
end

local PreviousCapture=HostUnit.OnCaptureProcessEnded
function HostUnit:OnCaptureProcessEnded(army)
    local cfg=Config(self)
    if not cfg or cfg.kind~="novaxLauncher" or not self:IsCaptureProcessComplete() then
        return PreviousCapture(self,army)
    end
    -- Native capture recreates units; SetArmy alone leaves stale army ownership.
    local replacement=CreateUnit(army.id,self.tpId,self:GetPosition(),self:GetOrientation(),1)
    replacement.scoSpecialInitialized=true
    replacement:SetHealth(self:GetHealth())
    Engine.CopyHierarchy(self.id,replacement.id)
    HoldAnimation(replacement)
    local child=self.scoSpecialChild
    if Alive(child) then
        local newChild=CreateUnit(army.id,child.tpId,child:GetPosition(),child:GetOrientation(),1)
        newChild.scoSpecialInitialized=true
        newChild.scoSpecialReleased=true
        newChild.scoSpecialParent=replacement
        replacement.scoSpecialChild=newChild
        newChild:SetHealth(child:GetHealth())
        Engine.CopyHierarchy(child.id,newChild.id)
        HoldAnimation(newChild)
        newChild.isAirborne=true
        newChild:SetAirborneLayers()
        Engine.SetMovementEnabled(newChild.id,true)
        Weapons(newChild,true)
        Event(newChild,"hideShells")
        child.scoSpecialUnlinking=true
        child:Delete()
    else
        replacement.scoSpecialInitialized=false
    end
    self.scoSpecialUnlinking=true
    self:Delete()
    return replacement
end

-- XAB1401 adjusts generation to army demand every half second. One elected
-- Paragon updates every active Paragon in an army from the same economy
-- snapshot; independent controllers would alternately overproduce and stall.
local function ParagonEconomyContract(unit)
    if unit.tpId ~= "ucs4102" then return nil end
    local additions = unit.tp and unit.tp.additions
    local contract = additions and additions.scoFieldFixParagonEconomy
    assert(contract and contract.version == "1.0.0"
        and contract.sourceId == "XAB1401" and contract.sampleSeconds == 0.5
        and contract.baselineAlloysPerSecond == 20
        and contract.baselineEnergyPerSecond == 1000
        and contract.maxAlloysPerSecond == 10000
        and contract.maxEnergyPerSecond == 1000000,
        "Paragon dynamic economy source contract changed")
    return contract
end

local function ParagonEconomyMembers(economy)
    local members = {}
    for _, entity in pairs(economy.resourceEntities.generation) do
        local unit = GetUnitById(entity.unitId)
        if unit and unit.tpId == "ucs4102" and Alive(unit)
            and unit.army.economy == economy and unit:IsCompleted() then
            ParagonEconomyContract(unit)
            assert(unit.resourceEntities.generation == entity and entity.enabled,
                "Paragon generation entity changed")
            members[#members + 1] = { unit = unit, entity = entity }
        end
    end
    table.sort(members, function(a, b)
        if a.unit.id.index ~= b.unit.id.index then
            return a.unit.id.index < b.unit.id.index
        end
        return a.unit.id.version < b.unit.id.version
    end)
    return members
end

local function ParagonOtherIncome(economy, members, resource, multiplier)
    local totals = economy.resoucesEntitiesTotals
    assert(totals and totals.generation and totals.harvest,
        "Paragon economy totals changed")
    local ownIncome = 0
    for _, member in ipairs(members) do
        ownIncome = ownIncome + (member.entity.income[resource] or 0)
    end
    local production = 0
    for _, entity in pairs(economy.resourceEntities.production) do
        production = production + (entity.income[resource] or 0)
            * entity.productionMultiplier * entity.userMultiplier
    end
    return ((totals.generation[resource] or 0) - ownIncome + production)
        * multiplier + (totals.harvest[resource] or 0)
end

local function ParagonTarget(economy, members, resource, baseline, cap, multiplier)
    local request = economy:GetResourceRequest(resource)
    assert(type(request) == "number" and request == request
        and request >= 0 and request < math.huge,
        "Paragon economy request changed")
    if multiplier <= 0 then return baseline end
    local otherIncome = ParagonOtherIncome(economy, members, resource, multiplier)
    local deficitPerSecond = math.max(0,
        (request - otherIncome) * Constants.TickRate)
    return math.min(cap, baseline + deficitPerSecond / (#members * multiplier))
end

function HostUnit:SCOParagonEconomyThread()
    WaitTicks(1) -- completed spawn registers its host unit after construction
    local contract = ParagonEconomyContract(self)
    local sampleTicks = math.floor(contract.sampleSeconds * Constants.TickRate + 0.5)
    assert(sampleTicks > 0, "Paragon economy sampling interval changed")
    while Alive(self) do
        local economy = self.army and self.army.economy
        assert(economy and economy.resourceEntities
            and economy.resourceEntities.generation
            and economy.resourceEntities.production,
            "Paragon host economy route changed")
        local members = ParagonEconomyMembers(economy)
        if members[1] and members[1].unit == self then
            local multiplier = economy.incomeAndBuildMultiplier
            assert(type(multiplier) == "number" and multiplier == multiplier
                and multiplier > -math.huge and multiplier < math.huge,
                "Paragon economy multiplier changed")
            local alloys = ParagonTarget(economy, members, "alloys",
                contract.baselineAlloysPerSecond,
                contract.maxAlloysPerSecond, multiplier)
            local energy = ParagonTarget(economy, members, "energy",
                contract.baselineEnergyPerSecond,
                contract.maxEnergyPerSecond, multiplier)
            for _, member in ipairs(members) do
                local entity = member.entity
                if math.abs((entity.income.alloys or 0) * Constants.TickRate - alloys) > 0.0001
                    or math.abs((entity.income.energy or 0) * Constants.TickRate - energy) > 0.0001 then
                    entity:SetResources({ alloys = alloys, energy = energy }, nil)
                    member.unit:UpdateUIValues()
                end
            end
        end
        WaitTicks(sampleTicks)
    end
end

local PreviousParagonComplete = HostUnit.OnStopBeingBuilt
function HostUnit:OnStopBeingBuilt(...)
    local result = PreviousParagonComplete(self, ...)
    if self.tpId == "ucs4102" and self:IsCompleted()
        and not self:IsPlacementGhost() and not self.scoParagonEconomyStarted then
        ParagonEconomyContract(self)
        self.scoParagonEconomyStarted = true
        self:NewThread(self.SCOParagonEconomyThread)
    end
    return result
end

-- SCOM source impact stun 1.0.0.
-- Own only movement and weapon suppression; preserve every caller's desired state.
do
    assert(not _G.SCO_SourceStun, "Source stun owner loaded twice")
    local runtime = { version = 1 }
    local movement = {}
    local setMovement = Engine.SetMovementEnabled
    local collisionLayers = Import("common/layers.lua").CollisionLayer

    local function same(id, other)
        return id and other and id.index == other.index and id.version == other.version
    end

    local function alive(unit)
        return unit and not unit.dead and not unit.deleted
    end

    function Engine.SetMovementEnabled(id, enabled)
        local state = movement[id.index]
        if not state or not same(state.id, id) then
            state = { id = { index = id.index, version = id.version } }
            movement[id.index] = state
        end
        state.requested = enabled
        return setMovement(id, enabled and not state.stunned)
    end

    local function refreshWeapons(unit)
        for _, weapon in ipairs(unit.weapons or {}) do weapon:RefreshEnabled() end
    end

    function runtime.IsStunned(unit)
        return alive(unit) and unit.scoSourceStunUntil ~= nil
    end

    local function finish(unit)
        unit.scoSourceStunUntil = nil
        unit.scoSourceStunThread = nil
        local state = movement[unit.id.index]
        if state and same(state.id, unit.id) then
            state.stunned = nil
            if alive(unit) then setMovement(unit.id, state.requested) end
        end
        if alive(unit) then refreshWeapons(unit) end
    end

    local function expire(unit)
        while alive(unit) and _G.Time < unit.scoSourceStunUntil do
            WaitSeconds(unit.scoSourceStunUntil - _G.Time)
        end
        finish(unit)
    end

    function runtime.Apply(unit, seconds)
        if not alive(unit) or unit.progress ~= 1 or type(seconds) ~= "number"
            or seconds <= 0 or seconds ~= seconds or seconds == math.huge then return false end
        local state = movement[unit.id.index]
        -- A completed mobile's native construction callback records its movement state.
        -- Refuse an unknown mobile state rather than guessing on stun release.
        if unit:HasTags(Tags.MOBILE) and (not state or not same(state.id, unit.id)) then return false end
        unit.scoSourceStunUntil = math.max(unit.scoSourceStunUntil or 0, _G.Time + seconds)
        if state and same(state.id, unit.id) then
            state.stunned = true
            setMovement(unit.id, false)
        end
        refreshWeapons(unit)
        if not unit.scoSourceStunThread then
            unit.scoSourceStunThread = unit:NewThread(expire)
        end
        return true
    end

    function runtime.Impact(projectile, position)
        local spec = projectile.scoSourceStunSpec
        local army = Armies[projectile.armyId]
        if not spec or not army then return end
        local hits = Engine.CapsuleCast(CollisionWorld.Collision, position,
            spec.radius * 2 + 4, spec.radius, GetIdentityQuaternion(), collisionLayers.Units)
        local seen = {}
        for _, hit in ipairs(hits) do
            local unit = __Entities.Units[hit.colliderGlobalID.index]
            if alive(unit) and not seen[unit] and army:IsEnemy(unit.army) then
                seen[unit] = true
                -- Native capsule casts require a minimum height. Apply FA's final
                -- 3D origin-distance test so that broad-phase height cannot stun aircraft above it.
                local targetPosition = unit:GetPosition()
                local dx, dy, dz = targetPosition.x - position.x,
                    targetPosition.y - position.y, targetPosition.z - position.z
                local inRadius = dx * dx + dy * dy + dz * dz <= spec.radius * spec.radius
                local eligible = spec.kind == "medusa" and unit:HasTags(Tags.TECH1 + Tags.TECH2)
                    or spec.kind == "sacu" and unit:HasTags(Tags.MOBILE)
                        and not unit:HasTags(Tags.COMMAND + Tags.TECH4 + Tags.TECH5)
                if inRadius and eligible then runtime.Apply(unit, spec.duration) end
            end
        end
    end

    local previousDestroy = HostUnit.OnDestroy
    function HostUnit:OnDestroy(...)
        -- Do not restore movement on a corpse; native destruction remains authoritative.
        local state = movement[self.id.index]
        if state and same(state.id, self.id) then state.stunned = nil end
        self.scoSourceStunUntil = nil
        if self.scoSourceStunThread then KillThread(self.scoSourceStunThread) end
        self.scoSourceStunThread = nil
        return previousDestroy(self, ...)
    end

    local previousDelete = HostUnit.Delete
    function HostUnit:Delete(...)
        local state = movement[self.id.index]
        if state and same(state.id, self.id) then movement[self.id.index] = nil end
        return previousDelete(self, ...)
    end

    _G.SCO_SourceStun = runtime
end
-- XRB3301 vision uses the native vision collider and real maintenance satisfaction.
-- The detector remains enabled while contracting; Intel off does not erase sight.
do
    if not HostUnit.scoSoothsayerInstalled then
        local function Config(unit)
            local additions = unit.tp and unit.tp.additions
            local config = additions and additions.scoSoothsayer
            if unit.tpId == 'ugs5028' and config and config.version == 1
                and config.sourceId == 'XRB3301' then return config end
        end

        local function Alive(unit)
            return not unit.dead and not unit.deleted
        end

        local function SetRadius(unit, radius)
            assert(unit.visionDetector, 'Soothsayer native vision detector missing')
            local result = Engine.SetVolumeColliderSize(unit.visionDetector.id,
                EngineClasses.float3(radius, 0, 0))
            assert(result == EngineErrorCode.Success, 'Soothsayer vision collider resize failed')
            unit.scoSoothsayer.radius = radius
        end

        local function RefreshPower(unit)
            local wanted = Alive(unit) and unit:IsCompleted() and unit:GetIntelToggle()
            local consumption = unit.resourceEntities and unit.resourceEntities.consumption
            if consumption then consumption:SetEnabled(wanted) end
            local economy = consumption and consumption.economy
            -- Native consumption entities never update productionMultiplier. Their
            -- exact resource combination's satisfaction is owned by Economy.Update.
            local satisfaction = economy and economy.satisfactionTable
                and economy.satisfactionTable[consumption.satisfactionTable]
            return wanted and satisfaction == 1
        end

        function HostUnit:SCOSoothsayerStep()
            local config, state = Config(self), self.scoSoothsayer
            if not config or not state or not Alive(self) or not self:IsCompleted() then return end
            state.active = RefreshPower(self)
            local radius = state.active
                and math.min(config.maximum, state.radius + config.step)
                or math.max(config.minimum, state.radius - config.step)
            if radius ~= state.radius then SetRadius(self, radius) end
        end

        local function Start(unit)
            local config = Config(unit)
            if not config or unit.scoSoothsayer or not Alive(unit) or not unit:IsCompleted() then return end
            unit.scoSoothsayer = { radius = config.minimum, active = false }
            SetRadius(unit, config.minimum)
            unit.scoSoothsayer.active = RefreshPower(unit)
            unit:NewThread(function(self)
                WaitSeconds(config.initialDelay)
                while Alive(self) do
                    self:SCOSoothsayerStep()
                    WaitSeconds(config.interval)
                end
            end)
        end

        local residualPrefab
        local function ResidualPrefab()
            if residualPrefab then return residualPrefab end
            local prefab = EngineClasses.PrefabTemplate('SCO_SoothsayerResidualVision')
            prefab.hierarchyTemplate.entities[1] = EngineClasses.EntityTemplate(
                TemplateHeadEntityName, nil, EngineClasses.float3(), 1, GetIdentityQuaternion(), true)
            prefab.globalTemplate.volumeColliderTemplates[1] = EngineClasses.VolumeColliderTemplate(
                TemplateHeadEntityName, EngineClasses.float3(1, 0, 0), EngineClasses.float3(),
                ColliderType.Circle, CollisionWorld.IntelVision, 1, 0, ColliderFlags.Disabled)
            local result, id = Engine.CreatePrefab(prefab)
            assert(result == EngineErrorCode.Success and id, 'Soothsayer residual prefab failed')
            residualPrefab = id
            return id
        end

        local function LeaveResidualVision(unit, config, radius)
            local result, id = Engine.InstantiatePrefab(ResidualPrefab(), unit:GetPosition(),
                EngineClasses.float3(1, 1, 1), GetIdentityQuaternion())
            assert(result == EngineErrorCode.Success and id, 'Soothsayer residual vision spawn failed')
            Engine.SetVolumeColliderGroupID(id, unit.army.id)
            Engine.SetVolumeColliderSize(id, EngineClasses.float3(radius, 0, 0))
            Engine.SetVolumeColliderEnabled(id, true)
            -- This source VizMarker outlives its unit; do not put its thread in
            -- the unit's garbage bag, which native Delete destroys immediately.
            NewThread(function()
                for _ = 1, config.deathSteps do
                    radius = math.max(1, radius - 1)
                    Engine.SetVolumeColliderSize(id, EngineClasses.float3(radius, 0, 0))
                    WaitSeconds(config.deathInterval)
                end
                Engine.DeletePrefabInstance(id, false)
            end)
        end

        local previousCheck = HostUnit.CheckRadarState
        function HostUnit:CheckRadarState(...)
            if Config(self) then RefreshPower(self); return end
            return previousCheck(self, ...)
        end

        local previousFinish = HostUnit.OnStopBeingBuilt
        function HostUnit:OnStopBeingBuilt(...)
            local result = previousFinish(self, ...)
            Start(self)
            return result
        end

        local previousDestroy = HostUnit.OnDestroy
        function HostUnit:OnDestroy(destroyType, ...)
            local config, state = Config(self), self.scoSoothsayer
            if config and state and Alive(self) and destroyType ~= DestroyType.Delete then
                LeaveResidualVision(self, config, state.radius)
                state.active = false
            end
            return previousDestroy(self, destroyType, ...)
        end
        HostUnit.scoSoothsayerInstalled = true
    end
end
-- Append in host unitsBaseClass.lua after native definitions. Existing ACU pods
-- keep their separate owner; this scope is the SACU and the two Kennel levels.
local SCOPodsResource = Import("host/systems/resourceEntity.lua").ResourceEntity
local SCOPodsOrders = Import("host/managers/orders/hostOrderManager.lua")
local SCOPodsTasks = Import("common/commonOrders.lua").OrderTasks
local SCOPodsWorkCommands = Import("common/commands/definitions/work.lua")
local SCOPodsLayers = Import("common/layers.lua")
-- All four installed source SACU scripts explicitly SetCapturable(false).
-- Exact source script hashes and IDs are pinned in pods-contract.json.
local SCOPodsNonCapturableSacu={ucl4002=true,uel5007=true,ugl5004=true,usl4002=true}
local function PodConfig(unit)
    local config=unit and unit.tp and unit.tp.additions and unit.tp.additions.scoSourcePods
    if config and config.targetId==unit.tpId then return config end
end
local function Alive(unit) return unit and not unit.dead and not unit.deleted end
local function Publish(unit)
    local command=Import("common/commands/definitions/units.lua").SCOSourcePodState
    if command then
        local state=unit.scoSourcePods
        command.Send(unit.id,state and state.installed==true,state and state.work~=nil,
            state and state.work and state.work.progress/state.work.cost.time or 0)
    end
    unit:UpdateUIValues()
end
local function Airborne(pod)
    for _,name in ipairs({"CancelLandWhenIdle","TakeoffBehaviourStop","LandingBehaviorStop"}) do
        if pod[name] then pod[name](pod) end
    end
    pod.isAirborne=true
    if pod.SetAirborneLayers then
        pod:SetAirborneLayers()
    else
        -- Native EDAEngineer inherits HostMobileUnit, so it never invokes the
        -- ordinary HostAirUnit takeoff layer transition. These two source pods
        -- still need the exact native airborne navigation and targeting layers.
        local movement=pod.tp.movement
        pod:SetNavigationLayer(pod.tp.general.navigationLayer)
        pod:SetTargetingLayer(SCOPodsLayers.TargetingLayer.Air)
        Engine.SetMovementCollisionMask(pod.id,movement.collisionMaskDefault)
        Engine.SetMovementReferenceAltitude(pod.id,movement.referenceAltitude)
        Engine.SetMovementPreferredAltitude(pod.id,movement.preferredAltitude)
        pod:SetMovementPatterns("hold")
        Engine.SetMovementTerrainAlignmentFactor(pod.id,movement.terrainAlignmentFactor)
        Engine.SetMovementMaxBankDegrees(pod.id,movement.maxBankDegrees)
    end
end
local function BoneTransform(unit,slot)
    local bone=unit:GetBoneId(slot.bone)
    if not bone then error("Source pod bone missing: "..unit.tpId.."/"..slot.bone) end
    local code,p=Engine.GetGlobalEntityWorldPosition(bone)
    assert(code==EngineErrorCode.Success,"Source pod world position unavailable")
    local code2,q=Engine.GetGlobalEntityWorldRotation(bone)
    assert(code2==EngineErrorCode.Success,"Source pod world rotation unavailable")
    return p,q
end
local function Link(owner,pod,slot)
    owner.scoSourcePods.children[slot.name]=pod
    pod.scoSourcePodOwner=owner
    pod.scoSourcePodSlot=slot
    pod.scoSourcePodMode="docked"
    if pod.scoSourcePodWasDocked==nil then pod.scoSourcePodWasDocked=true end
end
local function KennelUpgrading(unit)
    return unit.upgradeTarget~=nil or unit.scoProgressBoundUpgradeTarget~=nil
end
local function KennelSample(unit)
    local state=unit.scoKennelSourceAnimation
    if not state or not state.active or not Alive(unit) or KennelUpgrading(unit) then return end
    local segments=PodConfig(unit).animation.segments
    local segment=segments[#segments]
    for _,candidate in ipairs(segments) do
        if state.sourceTime<=candidate.finish then segment=candidate;break end
    end
    local seconds=(state.sourceTime-segment.start)/segment.bakedRate
    if state.lastKey==segment.key and state.lastTime and math.abs(state.lastTime-seconds)<0.000001 then return end
    local animation=unit.tp.visuals.animations[segment.key]
    assert(animation and animation.id and animation.clipName==segment.clip and animation.authoredSpeed==1,
        "Kennel source animation binding changed: "..unit.tpId.."/"..segment.key)
    local result=Engine.PlayAnimation(unit.id,animation.id,-10000+seconds)
    assert(result==EngineErrorCode.Success,"Kennel exact animation sampling failed")
    state.lastKey,state.lastTime=segment.key,seconds
end
local function KennelNotify(unit,departed)
    local state=unit.scoKennelSourceAnimation
    if not state or not Alive(unit) then return end
    local config=PodConfig(unit).animation
    if departed then
        if state.openingStarted then return end
        state.openingStarted=true;state.active=true;state.sourceTime=0
        state.rate=config.sourceStartRate
        -- Source notifications are separate threads sharing the same animator.
        -- An early return changes its rate, but the original half-second hold
        -- still takes effect unless an upgrade owns the unit at that instant.
        state.holdDeadlines[#state.holdDeadlines+1]=state.tick+math.floor(config.sourceHoldSeconds*Constants.TickRate+.5)
    elseif state.openingStarted then
        state.rate=config.sourceStopRate;state.openingStarted=false
    end
    KennelSample(unit)
end
local function KennelAdvance(unit)
    local state=unit.scoKennelSourceAnimation
    if not state then return end
    local config=PodConfig(unit).animation
    state.tick=state.tick+1
    if state.active then state.sourceTime=math.min(config.sourceDuration,state.sourceTime+state.rate/Constants.TickRate) end
    local upgrading=KennelUpgrading(unit)
    for i=#state.holdDeadlines,1,-1 do
        if state.tick>=state.holdDeadlines[i] then
            if not upgrading then state.rate=0 end
            table.remove(state.holdDeadlines,i)
        end
    end
    if upgrading then
        state.yielded=true
    else
        if state.yielded then state.lastKey=nil;state.lastTime=nil;state.yielded=false end
        KennelSample(unit)
    end
end
local function KennelInitialize(unit,config)
    if not config.animation then return end
    unit.scoKennelSourceAnimation={sourceTime=0,rate=config.animation.initialRate,
        active=config.animation.initialRate>0,tick=0,holdDeadlines={}}
    -- Retire only the old Kennel direct-builder animation shim. Its native
    -- builder subscriptions still execute, while actual pod movement now owns
    -- the source opening notifications. The existing upgrade owner is intact.
    if unit.tpId=="ues2501" then
        unit.OnStartBuildRoutine=function(owner,target) return HostUnit.OnStartBuildRoutine(owner,target) end
        unit.OnStopBuildRoutine=function(owner,target) return HostUnit.OnStopBuildRoutine(owner,target) end
        local previousEndUpgrade=unit.OnEndUpgrading
        unit.OnEndUpgrading=function(owner,target)
            local result=previousEndUpgrade(owner,target)
            local state=owner.scoKennelSourceAnimation
            if target and target:GetFractionComplete()>=1 then
                -- The completed upgrade is about to transfer pods and remove
                -- this hull. Keep the native upgrade owner until deletion.
                state.active=false
            else
                state.lastKey=nil;state.lastTime=nil;state.yielded=false
                KennelSample(owner)
            end
            return result
        end
    end
    KennelSample(unit)
end
local function Spawn(owner,slot)
    local p,q=BoneTransform(owner,slot)
    local pod=CreateUnit(owner.army.id,slot.template,p,q,1)
    assert(Alive(pod) and pod.tpId==slot.template,"Source pod creation failed")
    Link(owner,pod,slot)
    return pod
end
-- Enhancement framework commits only after its own native economy work has
-- completed. This entrypoint never creates a second resource drain.
function HostUnit:SCOApplyPaidPodEnhancement(remove)
    local config,state=PodConfig(self),self.scoSourcePods
    if not config or config.kind~="sacu" or not state or state.work
        or not Alive(self) or not self:IsCompleted() then return false end
    local slot=config.slots[1]
    if remove then
        local child=state.children[slot.name]
        state.children[slot.name]=nil;state.installed=false
        if Alive(child) then child.scoSourcePodOwner=nil;child:Destroy() end
    else
        if state.installed or Alive(state.children[slot.name]) then return false end
        Spawn(self,slot);state.installed=true
    end
    Publish(self)
    return true
end
local function WorkEnabled(work,enabled)
    local e=work.entity
    if enabled then
        e:SetEnabled(true)
        e:RecalculateBuildDrain()
        local remaining=math.max(0,work.cost.time-work.progress)
        -- Predict the next paid native economy tick, including resource stall.
        local satisfaction=1
        for _,name in ipairs(e.satisfactionTable or {}) do
            local resource=e.economy.resources[name]
            satisfaction=math.min(satisfaction,math.max(0,resource.satisfaction or 0))
        end
        local full=e.buildPower*satisfaction
        e:SetUserMultiplier(full>0 and math.min(1,remaining/full) or 1)
    else
        e:SetEnabled(false)
        e.outcome={};e.prevOutcome={};e.productionMultiplier=0
        e:SetUserMultiplier(1)
    end
    work.paused=not enabled
end
local function ReleaseWork(unit)
    local state=unit.scoSourcePods
    local work=state and state.work
    if not work then return end
    -- RemoveBuilder recalculates drain; native requires registration first.
    work.entity:SetEnabled(true)
    work.entity:RemoveBuilder(work.builder)
    WorkEnabled(work,false)
    state.work=nil
    Publish(unit)
end
local function BeginWork(unit,slot,cost,kind)
    local state=unit.scoSourcePods
    if state.work then return false end
    local config=PodConfig(unit)
    local e=state.resource
    if not e then
        e=SCOPodsResource(unit.army.id,unit.id,"construction",nil,nil,false)
        state.resource=e
        unit.resourceEntities.scoSourcePod=e
    end
    local builder={id=unit.id,construction={buildPower=config.buildPower},adjacencyBonus={}}
    e:SetCost({alloys=cost.alloys,energy=cost.energy});e:SetBuildTime(cost.time)
    e:SetEnabled(true);e:AddBuilder(builder)
    local work={slot=slot,cost=cost,kind=kind,progress=0,entity=e,builder=builder}
    state.work=work
    if config.kind=="sacu" then
        work.locked=true
    end
    WorkEnabled(work,not unit:GetPause())
    Publish(unit)
    return true
end
local function IsBusy(unit)
    return unit.unitBeingBuilt or unit.unitBeingRepaired or unit.unitBeingCaptured or unit.unitBeingReclaimed
        or unit.upgradeTarget or unit.scoCargoCarrier or unit.scoCargoPendingCarrier or
        (unit.orders and (unit.orders.activeOrder or #(unit.orders.queuedOrders or {})>0))
end
function HostUnit:SCORequestPod(remove)
    local config=PodConfig(self)
    local state=self.scoSourcePods
    if not config or config.kind~="sacu" or not state or not Alive(self) or not self:IsCompleted() then return false end
    if remove then
        if state.work then ReleaseWork(self);return true end
        if not state.installed or IsBusy(self) then return false end
        return BeginWork(self,config.slots[1],config.remove,"remove")
    end
    if state.work or state.installed or IsBusy(self) then return false end
    return BeginWork(self,config.slots[1],config.install,"install")
end
local function ClearAutomatic(pod)
    local order=pod.scoSourcePodAutoOrder
    if order and pod.orders and pod.orders.activeOrder==order then
        SCOPodsOrders.RemoveUnitFromActiveOrder(pod)
        SCOPodsOrders.TryStartNextOrderForUnit(pod)
    end
    pod.scoSourcePodAutoOrder=nil
    pod.scoSourcePodAutoKind=nil
end
local function OwnerNeedsAssistance(owner)
    if owner:GetPause() then return false end
    return owner.buildBehaviorIsActive or owner.productionBehaviorIsActive
        or owner.upgradeBehaviorIsActive or owner.repairBehaviorIsActive
        or owner.reclaimBehaviorIsActive or owner.captureBehaviorIsActive
        or owner.unitBeingBuilt or owner.unitBeingRepaired
        or owner.unitBeingCaptured or owner.unitBeingReclaimed
end
local function NearbyTargetValid(owner,pod,target)
    if not Alive(target) or target==pod or GetUnitById(target.id)~=target
        or target:IsPlacementGhost() or not owner.army:IsAlly(target.army)
        or not pod:RepairBehaviorIsValidFor(target) then return false end
    local detector=owner.constructionDetectorCollider
    return detector and detector:IsCollidingWithGlobalID(target.id)
        and detector:IsOverlappingUnit(target)
end
local function SelectNearbyTarget(owner,pod)
    local detector=owner.constructionDetectorCollider
    if not detector then return end
    local position=owner:GetPosition()
    local best,priority,distance
    for index,id in pairs(detector.contructionsInRange) do
        local target=GetUnitById(id)
        if not target then
            detector.contructionsInRange[index]=nil
        elseif NearbyTargetValid(owner,pod,target) then
            local rank=target:IsCompleted() and 2 or 1
            local p=target:GetPosition()
            local d=(p.x-position.x)^2+(p.z-position.z)^2
            if not best or rank<priority or (rank==priority and
                (d<distance or (d==distance and target.id.index<best.id.index))) then
                best,priority,distance=target,rank,d
            end
        end
    end
    return best
end
local function AssignAutomatic(pod,target,task,kind)
    SCOPodsOrders.HostIssueOrder(task,{pod},false,target:GetPosition(),{targetGlobalId=target.id})
    local active=pod.orders.activeOrder
    if active and active.orderTask==task and active.targetUnit==target then
        pod.scoSourcePodAutoOrder=active
        pod.scoSourcePodAutoKind=kind
    end
end
local function DockUpdate(owner,pod,slot)
    if not Alive(pod) or pod.scoCargoCarrier then return end
    local p,q=BoneTransform(owner,slot)
    local current=pod:GetPosition()
    local d=(current.x-p.x)^2+(current.z-p.z)^2
    local orders=pod.orders or {}
    local auto=pod.scoSourcePodAutoOrder
    local assist=OwnerNeedsAssistance(owner)
    local config=PodConfig(owner)
    local nearby=config.kind=="tower" and not owner:GetPause() and not assist
        and not IsBusy(owner) and not owner.productionBehaviorIsActive
        and not owner.upgradeBehaviorIsActive and #(owner.buildQueue or {})==0
    if auto and orders.activeOrder~=auto then
        pod.scoSourcePodAutoOrder=nil;pod.scoSourcePodAutoKind=nil;auto=nil
    end
    if auto and (#(orders.queuedOrders or {})>0
        or (pod.scoSourcePodAutoKind=="nearby" and
            (not nearby or not NearbyTargetValid(owner,pod,auto.targetUnit)))
        or (pod.scoSourcePodAutoKind~="nearby" and not assist)) then
        ClearAutomatic(pod);auto=nil
    end
    if not orders.activeOrder and #(orders.queuedOrders or {})==0 then
        if assist then
            AssignAutomatic(pod,owner,SCOPodsTasks.ASSISTUNIT,"owner")
        elseif nearby and owner.scoSourcePods.scan%5==0 then
            local target=SelectNearbyTarget(owner,pod)
            if target then AssignAutomatic(pod,target,SCOPodsTasks.REPAIR,"nearby") end
        end
        auto=pod.scoSourcePodAutoOrder
    end
    local working=(orders.activeOrder and orders.activeOrder~=auto) or #(orders.queuedOrders or {})>0
        or pod.unitBeingBuilt or pod.unitBeingRepaired or pod.unitBeingCaptured or pod.unitBeingReclaimed or auto
    Airborne(pod)
    if working then
        if pod.scoSourcePodWasDocked and d>0 then
            pod.scoSourcePodWasDocked=false;KennelNotify(owner,true)
        end
        -- A speed floor with the pod's zero-radius hold makes it drift
        -- straight past the work site. Kennel pods can hover there instead.
        local kennelPod=pod.tpId=="uea5011" and PodConfig(owner).kind=="tower"
        Engine.SetMovementMinSpeed(pod.id,kennelPod and 0 or (pod.tp.movement.minSpeed or 0))
        Engine.SetMovementEnabled(pod.id,true)
        if PodConfig(owner).kind=="tower" then pod:SetTargetable(true) end
        pod.scoSourcePodMode="working"
        return
    end
    if pod.scoSourcePodWasDocked==false and d<1 then
        pod.scoSourcePodWasDocked=true;KennelNotify(owner,false)
    end
    if pod.scoSourcePodMode=="docked" or d<0.35^2 then
        if pod.scoSourcePodMode~="docked" and pod.MoveIntoRangeBehaviorStop then
            pod:MoveIntoRangeBehaviorStop()
        end
        Engine.MovementStop(pod.id,EngineClasses.float2(0,0));Engine.SetMovementMinSpeed(pod.id,0)
        Engine.SetMovementEnabled(pod.id,false)
        Engine.SetGlobalEntityPosition(pod.id,p)
        Engine.SetGlobalEntityLocalRotation(pod.id,q)
        if PodConfig(owner).kind=="tower" then pod:SetTargetable(false) end
        pod.scoSourcePodMode="docked"
    else
        Engine.SetMovementMinSpeed(pod.id,0);Engine.SetMovementEnabled(pod.id,true)
        Engine.MovementMove(pod.id,EngineClasses.float2(p.x,p.z),EngineClasses.float2(0,0),0.35)
        pod.scoSourcePodMode="returning"
    end
end
local function Tick(unit)
    local state,config=unit.scoSourcePods,PodConfig(unit)
    KennelAdvance(unit)
    local work=state.work
    if work then
        -- Economy precedes Lua threads: account paid work before a pause change.
        if not work.paused then
            work.progress=math.min(work.cost.time,work.progress+work.entity.buildPower
                *work.entity.productionMultiplier*work.entity.userMultiplier)
        end
        if work.progress+0.000001>=work.cost.time then
            local slot,kind=work.slot,work.kind
            ReleaseWork(unit)
            if kind=="remove" then
                local child=state.children[slot.name]
                state.children[slot.name]=nil;state.installed=false
                if Alive(child) then child.scoSourcePodOwner=nil;child:Destroy() end
            else
                Spawn(unit,slot)
                if config.kind=="sacu" then state.installed=true end
            end
            Publish(unit)
        else
            WorkEnabled(work,not unit:GetPause() and not unit.upgradeTarget)
        end
    end
    state.scan=state.scan+1
    for _,slot in ipairs(config.slots) do
        local pod=state.children[slot.name]
        if Alive(pod) then DockUpdate(unit,pod,slot)
        elseif config.kind=="tower" and not state.work and not unit.upgradeTarget and state.scan%10==0 then
            BeginWork(unit,slot,slot.cost,"replace")
        end
    end
end
local function ForwardTowerWork(unit)
    if PodConfig(unit).kind~="tower" then return end
    -- Keep native routines/order intent, but only actual pods contribute work
    -- and emit beams. The tower retains its paid native self-upgrade builder.
    local registered={}
    for _,name in ipairs({"Build","Repair","Reclaim","Capture"}) do
        local start,stop="OnStart"..name.."Routine","OnStop"..name.."Routine"
        local previousStart,previousStop=unit[start],unit[stop]
        unit[start]=function(owner,target,...)
            if name=="Build" and (target==owner.upgradeTarget
                or target==owner.upgradeBehaviorTargetUnit) then
                registered[name]=target
                return previousStart(owner,target,...)
            end
            owner:UpdateUIValues()
        end
        unit[stop]=function(owner,target,...)
            if registered[name]==target then
                registered[name]=nil
                return previousStop(owner,target,...)
            end
            owner:UpdateUIValues()
        end
    end
end
local function StartOwner(unit)
    local config=PodConfig(unit)
    if not config or config.kind=="pod" or unit.scoSourcePods then return end
    unit.scoSourcePods={children={},scan=0,installed=false}
    KennelInitialize(unit,config)
    ForwardTowerWork(unit)
    unit:NewThread(function(owner)
        WaitTicks(1) -- native upgrade/capture may transfer live children first
        if not Alive(owner) then return end
        local state=owner.scoSourcePods
        for _,slot in ipairs(config.slots) do
            if slot.initial and not Alive(state.children[slot.name]) then Spawn(owner,slot) end
        end
        Publish(owner)
        while Alive(owner) do Tick(owner);WaitTicks(1) end
    end)
end
local PreviousComplete=HostUnit.OnStopBeingBuilt
function HostUnit:OnStopBeingBuilt(...)
    local result=PreviousComplete(self,...)
    local config=PodConfig(self)
    if config and config.kind=="pod" and not self.scoSourcePodAirInitialized then
        self.scoSourcePodAirInitialized=true
        self.OnHullCrossedWaterline=Airborne
        self:NewThread(function(pod)
            WaitTicks(1)
            if Alive(pod) then Airborne(pod) end
        end)
    end
    StartOwner(self)
    return result
end
local PreviousCaptureValidity=HostUnit.CaptureBehaviorIsValidFor
function HostUnit:CaptureBehaviorIsValidFor(target)
    if target and SCOPodsNonCapturableSacu[target.tpId] then return false end
    return PreviousCaptureValidity(self,target)
end
local PreviousCaptureStart=HostUnit.CanStartCaptureProcess
function HostUnit:CanStartCaptureProcess(...)
    if SCOPodsNonCapturableSacu[self.tpId] then return false end
    return PreviousCaptureStart(self,...)
end
local PreviousCaptureContinue=HostUnit.CanContinueCaptureProcess
function HostUnit:CanContinueCaptureProcess(...)
    if SCOPodsNonCapturableSacu[self.tpId] then return false end
    return PreviousCaptureContinue(self,...)
end
local PreviousAssignment=HostUnit.CanBeAssignedToOrder
function HostUnit:CanBeAssignedToOrder(...)
    if self.scoSourcePods and self.scoSourcePods.work and self.scoSourcePods.work.locked then return false end
    return PreviousAssignment(self,...)
end
local function Transfer(source,destination,capture)
    StartOwner(destination)
    local state=source.scoSourcePods
    if not state then return end
    ReleaseWork(source)
    for _,slot in ipairs(PodConfig(destination).slots) do
        local child=state.children[slot.name]
        if Alive(child) then
            ClearAutomatic(child)
            if capture then
                local copy=CreateUnit(destination.army.id,child.tpId,child:GetPosition(),child:GetOrientation(),1)
                assert(Alive(copy),"Captured source pod creation failed")
                copy:SetHealth(child:GetHealth());Engine.CopyHierarchy(child.id,copy.id)
                child.scoSourcePodOwner=nil;child:Delete();child=copy
            end
            Link(destination,child,slot)
            child.scoSourcePodMode="returning"
            state.children[slot.name]=nil
        end
    end
end
local PreviousUpgrade=HostUnit.OnEndUpgrade
function HostUnit:OnEndUpgrade(upgrader)
    if self.tpId=="ues3501" and upgrader.tpId=="ues2501" and self:IsCompleted() and Alive(upgrader) then
        Transfer(upgrader,self,false)
    end
    return PreviousUpgrade(self,upgrader)
end
local PreviousCapture=HostUnit.OnCaptureProcessEnded
function HostUnit:OnCaptureProcessEnded(army)
    local config=PodConfig(self)
    if not config or config.kind~="tower" or not self:IsCaptureProcessComplete() then return PreviousCapture(self,army) end
    self:SetTargetable(true)
    SCOPodsWorkCommands.OnUnitCaptured.Send(self.id)
    local replacement=CreateUnit(army.id,self.tpId,self:GetPosition())
    assert(Alive(replacement),"Captured source Kennel creation failed")
    Engine.CopyHierarchy(self.id,replacement.id)
    Transfer(self,replacement,true)
    self:Delete()
end
local PreviousDestroy=HostUnit.OnDestroy
function HostUnit:OnDestroy(...)
    local owner=self.scoSourcePodOwner
    if owner and owner.scoSourcePods then
        local state=owner.scoSourcePods
        if state.children[self.scoSourcePodSlot.name]==self then
            state.children[self.scoSourcePodSlot.name]=nil
            if PodConfig(owner).kind=="sacu" then
                state.installed=false
                if Alive(owner) and owner.SCOOnSourcePodLost then owner:SCOOnSourcePodLost() end
            end
            if Alive(owner) then Publish(owner) end
        end
        self.scoSourcePodOwner=nil
    end
    if self.scoSourcePods then
        ReleaseWork(self)
        local children=self.scoSourcePods.children
        self.scoSourcePods.children={}
        for _,child in pairs(children) do
            child.scoSourcePodOwner=nil
            if Alive(child) then child:Destroy() end
        end
    end
    return PreviousDestroy(self,...)
end
-- Reject assistance to old hydro placement ghosts as well as fresh builds.
local SourceHydro=Import("common/systems/scoSourceHydroPlacement.lua")
local PreviousHydroBuildBehavior=HostUnit.BuildBehaviorIsValidFor
local PreviousHydroBuildRoutine=HostUnit.StartBuildRoutine

function HostUnit:BuildBehaviorIsValidFor(target)
    if target and not SourceHydro.CanBuildNormally(target.tp) then return false end
    return PreviousHydroBuildBehavior(self,target)
end

function HostUnit:StartBuildRoutine(target)
    if target and not SourceHydro.CanBuildNormally(target.tp) then return end
    return PreviousHydroBuildRoutine(self,target)
end
-- Source unit mode installation follows all native and scoped unit lifecycle owners.
Import('common/systems/scoSourceUnitModes.lua').InstallUnit(HostUnit)

-- The source water defences retain faction-specific Structure classes for
-- their build and animation lifecycles. Give only these instances the native
-- naval target layer before the stock constructor creates weapons/targeting.
local SCO_WaterDefenceTargetClass = {
    ues5017 = "EDAStructure", ues5018 = "EDAStructure",
    ues5020 = "EDAStructure", ues5021 = "EDAStructure",
    ugs5005 = "GuardStructure", ugs5006 = "GuardStructure",
    ugs5008 = "GuardStructure", ugs5010 = "GuardStructure",
    ugs5027 = "GuardStructure",
    ucs1301 = "AeonPortStructure", ucs2301 = "AeonPortStructure",
    ucs1702 = "AeonPortStructure", ucs2702 = "AeonPortStructure",
    uss1301 = "SeraphimStructure", uss2301 = "SeraphimStructure",
    uss1702 = "SeraphimStructure", uss2702 = "SeraphimStructure",
}
local SCO_WaterDefenceLayers = Import('common/layers.lua').TargetingLayer
local SCO_PreviousWaterDefenceInit = HostUnit.__init
function HostUnit:__init(id, armyId, template, fractionCompleted)
    local general = template and template.general
    local tpId = general and general.tpId
    local expectedClass = SCO_WaterDefenceTargetClass[tpId]
    local targetLayer
    if expectedClass then
        assert(general.class and general.class[2] == expectedClass
            and general.iconUIType == "water" and Tags.NAVAL[tpId],
            "SCOM water defence targeting contract changed: " .. tpId)
        targetLayer = tpId == "ugs5027"
            and SCO_WaterDefenceLayers.Water or SCO_WaterDefenceLayers.WaterSurface
        self.DefaultTargetingLayer = targetLayer
    end
    SCO_PreviousWaterDefenceInit(self, id, armyId, template, fractionCompleted)
    if targetLayer then self:SetTargetingLayer(targetLayer) end
end
-- SCOM source secondary visual host installation 1.0.0
Import('common/systems/scoSourceSecondaryVisuals.lua').InstallUnit(HostUnit)
-- SCOM source dynamic visual host installation 1.0.0
Import('common/systems/scoSourceDynamicVisuals.lua').InstallUnit(HostUnit)
-- ACUs aim with their work arm; UEF pods aim their visual root at the work site.
do
    local previousFacing = HostUnit.GetIsAlignedToDirection
    local previousApproach = HostUnit.MoveIntoRangeBehaviorStart
    assert(type(previousFacing) == 'function' and type(previousApproach) == 'function',
        'ACU build-facing native methods are missing')

    local arms = {
        uel0000 = { 'Left_Arm_Muzzle', 'Left_Arm_Barrel' },
        ugl0000 = { 'Turret_Muzzle_01', 'Left_Turret' },
        ucl0000 = { 'Left_Turret_Muzzle', 'Left_Turret' },
        usl0000 = { 'Left_Turret_Muzzle', 'Left_Arm_B02' },
    }

    local function WorkTarget(unit)
        local target = unit.buildBehaviorIsActive and unit.buildBehaviorActualUnit
            or unit.repairBehaviorIsActive and unit.repairBehaviorTarget
        if not target or target.dead or target.deleted then return nil end
        -- Native plane alignment can circle away from an already reachable site.
        -- The pod's client construction controller owns its work-facing rotation.
        if unit.tpId == 'uea0001' and unit.tp and unit.tp.general
            and unit.tp.general.unitTypeName == 'EDACommanderEngineeringDrone' then
            return target
        end
        local arm = arms[unit.tpId]
        if not arm then return nil end
        local spec = unit.tp and unit.tp.additions and unit.tp.additions.scomBuildFacing
        local controller = spec and spec.controllers and spec.controllers[1]
        if not (spec and spec.faceWholeUnit == false and controller
            and controller.aimBone == arm[1] and controller.yawBone == 'Torso'
            and controller.pitchBone == arm[2]) then return nil end
        return target
    end

    function HostUnit:GetIsAlignedToDirection(direction)
        -- Native BuildBehaviorThread asks this before starting the build arm.
        -- The dedicated joint controller owns facing once the target is in range.
        if direction and WorkTarget(self) and self.buildBehaviorIsActive and self.buildBehaviorActualUnitPositionFloat2 then
            local targetDirection = self:GetAlignRotation(self.buildBehaviorActualUnitPositionFloat2)
            if direction.x == targetDirection.x and direction.y == targetDirection.y then return true end
        end
        return previousFacing(self, direction)
    end

    function HostUnit:MoveIntoRangeBehaviorStart(position, range, align, brakeOnApproach)
        local targetUnit = WorkTarget(self)
        if targetUnit then
            local target = targetUnit:GetPosition()
            if position.x == target.x and position.y == target.z then
                -- Walk normally to the build site, without the optional chassis
                -- rotation callback when the movement reports arrival.
                align = false
            end
        end
        return previousApproach(self, position, range, align, brakeOnApproach)
    end
end
-- URL0107/Mantis can repair and assist building, but cannot reclaim or capture.
-- Native guard assistance invokes these validators without checking order tags.
do
    local marker = _G.SCO_MantisAssistHostInstalled
    if marker ~= nil and marker ~= "1.0.0" then
        error("Unsupported SCOM Mantis assistance version")
    end
    if marker == nil then
        local nativeReclaim = assert(HostUnit.ReclaimBehaviorIsValidFor,
            "SCOM Mantis requires native reclaim validation")
        local nativeCapture = assert(HostUnit.CaptureBehaviorIsValidFor,
            "SCOM Mantis requires native capture validation")

        function HostUnit:ReclaimBehaviorIsValidFor(target)
            if self.tpId == "ugl1002" then return false end
            return nativeReclaim(self, target)
        end

        function HostUnit:CaptureBehaviorIsValidFor(target)
            if self.tpId == "ugl1002" then return false end
            return nativeCapture(self, target)
        end

        _G.SCO_MantisAssistHostInstalled = "1.0.0"
    end
end
-- Idle Hives select nearby work; native REPAIR owns construction, cost and beams.
local HiveOrders = Import("host/managers/orders/hostOrderManager.lua")
local HiveTasks = Import("common/commonOrders.lua").OrderTasks
local HiveIds = {ugs2501 = true, ugs5026 = true, ugs3501 = true}

local function IsHive(unit)
    return HiveIds[unit.tpId] == true
end

local function HiveAlive(unit)
    return not unit.dead and not unit.deleted and not unit.scoHiveAutoDisposed
        and GetUnitById(unit.id) == unit
end

local function EligibleHiveTarget(hive, target)
    if not target or target == hive or target.dead or target.deleted then return false end
    if GetUnitById(target.id) ~= target or target:IsPlacementGhost() then return false end
    if not hive.army:IsAlly(target.army) or not hive:RepairBehaviorIsValidFor(target) then return false end
    -- Events can lag geometry or retain a deleted/recycled ID. Require both.
    local detector = hive.constructionDetectorCollider
    return detector and detector:IsCollidingWithGlobalID(target.id)
        and detector:IsOverlappingUnit(target)
end

local function ReleaseHiveOrder(hive, resumeQueued)
    local automatic = hive.scoHiveAutomaticOrder
    hive.scoHiveAutomaticOrder = nil
    if automatic and hive.orders.activeOrder == automatic then
        HiveOrders.RemoveUnitFromActiveOrder(hive)
        -- A queued player command takes over; never clear their queue.
        if resumeQueued then HiveOrders.TryStartNextOrderForUnit(hive) end
    end
end

local function SelectHiveTarget(hive)
    local detector = hive.constructionDetectorCollider
    if not detector then return end
    local position = hive:GetPosition()
    local selected, selectedPriority, selectedDistance
    for index, id in pairs(detector.contructionsInRange) do
        local target = GetUnitById(id)
        if not target then
            -- Native exit events can lose invalid colliders before removing them.
            detector.contructionsInRange[index] = nil
        elseif EligibleHiveTarget(hive, target) then
            local priority = target:IsCompleted() and 2 or 1
            local other = target:GetPosition()
            local dx, dz = other.x - position.x, other.z - position.z
            local distance = dx * dx + dz * dz
            if not selected or priority < selectedPriority
                or (priority == selectedPriority and (distance < selectedDistance
                    or (distance == selectedDistance and target.id.index < selected.id.index))) then
                selected, selectedPriority, selectedDistance = target, priority, distance
            end
        end
    end
    return selected
end

function HostUnit:SCOHiveAutoWorkStep()
    if not IsHive(self) or not HiveAlive(self) then return end
    local orders = self.orders
    local automatic = self.scoHiveAutomaticOrder
    if automatic and orders.activeOrder ~= automatic then
        self.scoHiveAutomaticOrder, automatic = nil, nil
    end
    local busy = not self:IsCompleted() or self:GetPause()
        or self.upgradeBehaviorIsActive or self.productionBehaviorIsActive
        or (self.buildQueue and #self.buildQueue > 0) or #orders.queuedOrders > 0
    if automatic then
        if busy or not EligibleHiveTarget(self, automatic.targetUnit) then
            ReleaseHiveOrder(self, true)
        else
            return -- Keep working; a nearer target must not cause order churn.
        end
    end
    if busy or orders.activeOrder or #orders.queuedOrders > 0 then return end
    -- Preserve work started directly by another native behavior or mod.
    if self.buildBehaviorIsActive or self.repairBehaviorIsActive
        or self.assistBehaviorIsActive or self.reclaimBehaviorIsActive
        or self.captureBehaviorIsActive then return end
    local target = SelectHiveTarget(self)
    if not target then return end
    HiveOrders.HostIssueOrder(HiveTasks.REPAIR, {self}, false, target:GetPosition(),
        {targetGlobalId = target.id})
    -- HostIssueOrder returns no success value. Only claim its actual accepted order.
    local active = orders.activeOrder
    if active and active.targetUnit == target and active.orderTask == HiveTasks.REPAIR then
        self.scoHiveAutomaticOrder = active
    end
end

function HostUnit:SCOHiveAutoWorkThread()
    -- Completion can run inside the constructor before entity registration.
    -- Stagger stations so simultaneous construction does not align their scans.
    WaitTicks(1 + self.id.index % 5)
    while HiveAlive(self) do
        self:SCOHiveAutoWorkStep()
        WaitSeconds(0.5)
    end
    self.scoHiveAutoThread = nil
end

local PreviousHiveCompletion = HostUnit.OnStopBeingBuilt
function HostUnit:OnStopBeingBuilt(...)
    local result = PreviousHiveCompletion(self, ...)
    if IsHive(self) and not self.scoHiveAutoDisposed and not self.scoHiveAutoThread then
        self.scoHiveAutoThread = self:NewThread(self.SCOHiveAutoWorkThread)
    end
    return result
end

local function DisposeHiveWork(hive)
    if not IsHive(hive) or hive.scoHiveAutoDisposed then return end
    hive.scoHiveAutoDisposed = true
    ReleaseHiveOrder(hive, false)
    if hive.scoHiveAutoThread then
        KillThread(hive.scoHiveAutoThread)
        hive.scoHiveAutoThread = nil
    end
end

local PreviousHiveDestroy = HostUnit.OnDestroy
function HostUnit:OnDestroy(...)
    DisposeHiveWork(self)
    return PreviousHiveDestroy(self, ...)
end

local PreviousHiveDelete = HostUnit.Delete
function HostUnit:Delete(...)
    DisposeHiveWork(self)
    return PreviousHiveDelete(self, ...)
end
-- Pose snapshots describe only the existing visual mesh; stockpile owns payment.
do
    local Session = Import('common/commands/definitions/session.lua')
    local function Config(unit)
        if unit.tpId ~= 'uss4102' then return end
        local c = unit.tp and unit.tp.additions and unit.tp.additions.scoYolonaMissile
        assert(c and c.version == '1.0.0' and c.bone == 'Nuke', 'Yolona missile pose contract missing')
        return c
    end
    function _G.SCO_UpdateYolonaMissile(unit, launching)
        if not Config(unit) then return end
        local state = unit.scoYolonaMissile or {sequence = 0}
        unit.scoYolonaMissile = state
        if launching ~= nil then state.launching = launching end
        local silo = unit.scoTactical
        local visible = not unit.dead and not unit.deleted and unit:IsCompleted()
            and silo ~= nil and not state.launching
        local fraction = 0
        if visible then
            if silo.ammo > 0 then fraction = 1
            elseif silo.building and silo.work > 0 then fraction = math.min(1, silo.work / silo.contract.buildTime)
            else visible = false end
        end
        state.sequence = state.sequence + 1
        Session.ExecuteClientFunction.Send('SCOYolonaMissilePose', {
            unitId = unit.id, sequence = state.sequence, visible = visible, fraction = fraction,
        })
    end
    function _G.SCO_YolonaMissileLaunchTransform(unit)
        local c = Config(unit)
        if not c then return end
        local bone = unit:GetBoneId(c.root)
        if not bone or not Engine.IsValidGlobalID(bone) then return end
        local pr, rootPosition = Engine.GetGlobalEntityWorldPosition(bone)
        local rr, rootRotation = Engine.GetGlobalEntityWorldRotation(bone)
        if pr ~= EngineErrorCode.Success or rr ~= EngineErrorCode.Success then return end
        local q = c.rotation
        local rotation = EngineClasses.quaternion(EngineClasses.float4(q.x, q.y, q.z, q.w))
        local origin = c.projectileOrigin
        local offset = Engine.QuaternionRotateVector(rotation, EngineClasses.float3(origin.x, origin.y, origin.z))
        local p = c.position
        offset = Engine.QuaternionRotateVector(rootRotation,
            EngineClasses.float3(p.x + offset.x, p.y + c.lift + offset.y, p.z + offset.z))
        return EngineClasses.float3(rootPosition.x + offset.x, rootPosition.y + offset.y, rootPosition.z + offset.z),
            Engine.QuaternionMultiply(rootRotation, rotation)
    end
    local destroy = HostUnit.OnDestroy
    function HostUnit:OnDestroy(...)
        if self.tpId == 'uss4102' then _G.SCO_UpdateYolonaMissile(self, true) end
        return destroy(self, ...)
    end
end
