local SCOM_EditableUnits = Import("scom/editableUnits.lua")
local ClientWeapons = Import("client/units/weaponsClasses/clientWeaponClass.lua")
local ClientEntity = Import("client/entities/entity.lua").ClientEntity
local Selectable = Import("client/selectable.lua").Selectable
local Highlightable = Import("client/highlightable.lua").Highlightable
local Decals = Import("client/entities/decal.lua")
local Icons = Import("client/entities/icon.lua")
local Holes = Import("client/entities/hole.lua")
local ConstructionBeam = Import("client/entities/constructionBeam.lua")
local ProgressBars = Import("client/entities/progressBar.lua")
local RangeRings = Import("client/entities/rangeRing.lua")
local UIManager = Import("client/ui/uiManager.lua")
local IntelBitMask = Import("common/intelBitMask.lua").IntelBitMask
local UnitEnums = Import("common/units/unitEnums.lua")
local AudioManager = Import("client/audio/audioManager.lua")

local Upgrade = Import("client/units/interfaces/upgrade.lua").ClientUpgrade
local Upgrader = Import("client/units/interfaces/upgrader.lua").ClientUpgrader

local PlacementUtils = Import("common/systems/placementUtils.lua")
local PlacementDomain = Import("common/layers.lua").PlacementDomain

local Units = __Entities.Units

local RadarIconColor = EngineClasses.float4(1, 1, 1, 1)
_G.PlacementGhostIconAlpha = 0.30
_G.InConstructionIconAlpha = 0.30

local pairs = pairs
local IsFocused = IsFocused
local GetFocusArmy = GetFocusArmy

local _, unitSpeedRTPCID = Engine.GetAudioRTPCID("UnitSpeed")
local _, unitHealthRTPCID = Engine.GetAudioRTPCID("UnitHealth")
local _, isSelectedRTPCID = Engine.GetAudioRTPCID("IsSelected")
local _, constructionSpeedRTPCID = Engine.GetAudioRTPCID("ConstructionSpeed")
local _, unitBankAngleRTPCID = Engine.GetAudioRTPCID("UnitBankAngle")

local ScorchMarkSizeMultiplier = 4.0
local ScorchMarkMinSize = 1.0

---@class ClientUnit: ClientEntity, Selectable, ClientUpgrade, ClientUpgrader
---@field tp UnitTemplate Unit's template
---@field name string Name from the template
---@field tpId TemplateId Template ID of the unit. e.g. "uel0000"
---@field armyId ArmyId Index of the army this unit belongs to
---@field army ClientArmy The army this unit belongs to
---@field dead boolean If the unit is dead
---@field resources table<ResourceName, number> Resource net balance of this unit
---@field buildPower integer|nil Unit's build power
---@field buildQueue table Unit's build queue
---@field constructionBeam ConstructionBeam the construction beam entity attached to this unit
---@field holes Hole[]|nil List of rendering holes into the terrain.
---@field icons table<string, StrategicIcon>|nil Strategic icons
---@field rangeRings table<RangeRingType, RangeRing>|nil Range rings
---@field progressBars table<string, ProgressBar>|nil Progress bars
---@field weapons ClientWeapon[]|nil Table with weapon classes or nil.
---@overload fun(globalId: globalId, localId: localId, armyId: ArmyId, template: table): ClientUnit
ClientUnit = Class("UnitBase", ClientEntity, Selectable, Upgrade, Upgrader)

---Sets up basic things for the new unit instance in the client.  
---Client units are registered from the engine callback.
---@param globalId globalId Global ID of the unit
---@param localId localId Local ID of the unit
---@param armyId ArmyId Index of the army this unit belongs to
---@param template UnitTemplate Unit's template
---@param fractionComplete number Percentage the unit is compelte from 0 to 1.
---@protected
function ClientUnit:__init(globalId, localId, armyId, template, fractionComplete)
    ClientEntity.__init(self, globalId, localId)
    Selectable.__init(self)

    Upgrade.__init(self)
    Upgrader.__init(self)

    self.tp = template
    self.name = self.tp.general.name
    self.tpId = self.tp.general.tpId
    self.armyId = armyId
    self.army = Armies[self.armyId]
    self.progress = fractionComplete * self.tp.economy.buildTime
    self.entityType = "unit"

    self.resources = {}
    self.buildPower = self.tp.construction and self.tp.construction.buildPower
    
    self.buildQueue = {}
    self.buildQueuePendingOperations = {}
    self.predictedBuildQueue = {}

    -- these fields managed by clientOrderManager:
    self.hasPendingOrderMessages = false
    self.simOrderState = {
        activeOrder = nil,
        queuedOrdersArray = {},
    }
    self.orderState = self.simOrderState -- sometimes points to simOrderState, sometimes not
    
    self.toggles = table.deepCopy(self.tp.general.toggles);
    -- Some editable SCOM templates omit controls. Own a table per instance
    -- while preserving the absent keys that determine available UI toggles.
    if self.toggles == nil and SCOM_EditableUnits.IsEditable(self.tp) then
        self.toggles = {}
    end

    self:SetColor(Armies[self.armyId]:GetColor())
    self:SetUpRangeRings()
    self:SetUpHoles()
    self:SetUpIcon()
    self:SetUpSelection()
    self:SetUpConstructionBeam()
    self:SetUpWeapons()
    self:SetUpShields()
    self:SetUpAudioSources()
    self:SetUpProgressBars()

    self.persistentEffectsEnabled = false
    self:SetUpPersistentEffects()
    self.buildEffectsEnabled = false
    self:SetUpEffectsWhenActive()
    self.constructionBeamEnabled = false
    self.iconsEnabled = false

    -- Until initiailzed = true, we need to hold commands from the host for the 1 tick of prediction.
    self.isInitialized = false
    self.isIntelVisionVisible = false
    self.visibilityMask = IntelBitMask.FromArmyId(self.armyId)
    self.isIntelRadarVisible = false
    self.radarMask = IntelBitMask.FromArmyId(self.armyId)
    self.isIntelSonarVisible = false
    self.sonarMask = IntelBitMask.FromArmyId(self.armyId)

    self:OnFocused(IsFocused(self.armyId))

    if self:IsCompleted() then
        self:OnCompleted()
    end

    -- If we are a simulated entity then run the proper interpolated delay for our rendering object.
    self:SimCreate();
end

function ClientUnit:SimCreateThread()

    -- If we are a placment ghost that is for our team,
    -- We do not need to do all this recalculate intel stuff, we will of course be seen.
    -- So just set our rendering to true!
    -- Then return.
    if self:IsPlacementGhost() and IsFocused(self.armyId) then
        self.isInitialized = true
        self.isIntelVisionVisible = true
        self:OnIntelVision()
        self:EnableUnitIcons(true)
        return
    end

    WaitTickEnd()

    -- We have waited our one tick of prediction.
    -- We can now allow commands from the host to take effect.
    self.isInitialized = true

    -- This properly will enable all the relevant things on the unit
    -- for the unit per the player's intel state. Colliders, icons, you get the idea.
    self:RecalculateIntel()
end

---Update UI elements when owner army is switching focus by the client
---@param focused boolean
function ClientUnit:OnFocused(focused)

    -- TODO: Still likely a of edge cases if units are selected and seen apart of your army then change teams or something.
    if focused == false and self:GetSelectionBracketEnabled() then
        self:SetSelectionBracketEnabled(false)
    end
end

---@public If the unit is a placement ghost. This is true if the unit has not been built.                   
---@return boolean isPlacementGhost
function ClientUnit:IsPlacementGhost()
    return self.progress <= 0
end

---@protected Event called when unit goes from placement ghost
function ClientUnit:OnPromoteToUnit()
    self:RecalculateIntel(true)
    self:EnableUnitIcons(true)
    self.icons.StrategicIcon:SetAlpha(InConstructionIconAlpha)
end

---@public Start the destruction of the unit. The destruction of the unit will be delayed to the proper time for a client. Use OnDestroy for destroy logic.
---@param destroyType DestroyType
function ClientUnit:Destroy(destroyType)
    self:NewThread(ClientUnit.DestroyThread, destroyType)
end

---@private Operations must wait till end of tick for rendering to catch up to proper sim point.
---@param destroyType DestroyType
function ClientUnit:DestroyThread(destroyType)
    WaitTickEnd()
    self:OnDestroy(destroyType)
end

---@public Start the deletion of the unit. The deletion of the unit will be delayed to the proper time for a client. Use OnDelete for delete logic.
function ClientUnit:Delete()
    self:NewThread(ClientUnit.DeleteThread)
end

---@private Operations must wait till end of tick for rendering to catch up to proper sim point.
function ClientUnit:DeleteThread()
    WaitTickEnd()

    if not self.dead then
        self:OnDestroy(DestroyType.Delete)
    end

    self:OnDelete()
    ClientEntity.Delete(self)
end

---Delete callback. Put your extra delete logic here!
function ClientUnit:OnDelete()
    self:CleanupWeapons()
    self:CleanupShields()
end

---Handles unit's death.<br>
---Creates all death VFXs, decals.
---@param destroyType DestroyType
function ClientUnit:OnDestroy(destroyType)
    -- SCOM naval death selection 1.1.0
    self.dead = true
    if self:HasTags(Tags.NAVAL) and not self:HasTags(Tags.STRUCTURE) then
        self:SetSelectionEnabled(false)
        self:SetSelectionBracketEnabled(false)
        Engine.SetRangeRingsEnabled(self.localId, false)
    end

    self:CleanupWeapons()
    self:StopAudioSources()

    -- Disable the unit object. This should eventually be taken care of the entity itself.
    --self:ClearProgressBars()
    --self:ClearIcons()

    -- If we died to a projectile as a built unit.
    if not self:IsPlacementGhost() and (destroyType == DestroyType.Kinetic or destroyType == DestroyType.Unspecified) then
        if not self.scoDeferDeathScorch then
            self:CreateRandomScorchmark()
        end
    
        -- If you want to visualize the simulated position vs the current interpolated position of the rendering object.
        --Engine.DrawCircle(self:GetPosition(), 0.25, {x=1, y=0, z=0, w=1})
        --Engine.DrawCircle(self:GetSimPosition(), 0.25, {x=0, y=1, z=0, w=1})
        
        self:CreateDeathEffects()
    end
end

-- TODO: Can be calculated at prefab load time.
---@return PrefabID DissolveEffect The dissolve effect prefab that should be instantiated for this unit.
function ClientUnit:GetDissolveEffectPrefab()
    local size = math3D.length(self.tp.collisionInfo.collisionSize)
    if size < 1.5 then return DissolveSmallEffectPrefab end
    if size < 3.5 then return DissolveMediumEffectPrefab end
    if size < 5.5 then return DissolveLargeEffectPrefab end
    if size < 10.0 then return DissolveHugeEffectPrefab end
    return DissolveExtremeEffectPrefab
end

--- When the client unit got hit with a dissolve attack.
---@param direction float3 The direction the dissolve should face.
function ClientUnit:OnDissolve(direction)
    local dissolveEffectPrefab = self:GetDissolveEffectPrefab()
    local position = self:GetSimPosition()
    local rotation = Engine.QuaternionLookRotation(direction, EngineClasses.float3(0, 1, 0))
    Engine.InstantiatePrefab(dissolveEffectPrefab, position, EngineClasses.float3(1.0, 1.0, 1.0), rotation)
end

function ClientUnit:CreateDeathEffects()
    if self:IsIntelVisionVisible() then      
        self:CreateOnDeathEffect()
        self:CreateSmokeEffect()
        self:CreateOnDestroyedAudioEffect()
    end
end

function ClientUnit:CreateOnDeathEffect()
    local data = self.tp.visuals and self.tp.visuals.effectsInstant and self.tp.visuals.effectsInstant.onDeath
    if data then
        local effects = table.random(data)
        if not effects then
            return
        end

        --TODO: Add some logic to handle onImpact effects
        local particlePrefabID = effects.particlePrefabID

        if particlePrefabID then
            -- Use default for rotation
            local deadEffectLocalID = {}
            Engine.InstantiatePrefab(particlePrefabID, self:GetSimPosition(), EngineClasses.float3(1.0, 1.0, 1.0), GetIdentityQuaternion(), deadEffectLocalID)
        end
    end
end

function ClientUnit:CreateSmokeEffect()
    local fp = self.tp.footprint
    local hitbox = self.tp.collisionInfo.collisionSize
    local sizeArea = fp.x * fp.y
    -- 50% chance to spawn a smoke effects for larger buildings and units
    if math.random(1, 2) == 1 then
        if self:HasTags(Tags.STRUCTURE) and (sizeArea >= 16 or hitbox.y >= 3) then
            local smokeEffectLocalID = {}
            Engine.InstantiatePrefab(self.tp.buildingSmokeVFXPrefabID, self:GetSimPosition(), EngineClasses.float3(1.0, 1.0, 1.0), GetIdentityQuaternion(), smokeEffectLocalID)
        elseif not self:HasTags(Tags.TECH1) then
            local smokeEffectLocalID = {}
            Engine.InstantiatePrefab(self.tp.unitSmokeVFXPrefabID, self:GetSimPosition(), EngineClasses.float3(1.0, 1.0, 1.0), GetIdentityQuaternion(), smokeEffectLocalID)
        end
    end
end

function ClientUnit:CreateOnDestroyedAudioEffect()
    if self.tp.audio and self.tp.audio.onDestroyed and self.tp.audio.onDestroyed.prefabID then
        AudioManager.PlayOneShot(self.tp.audio.onDestroyed.prefabID, self:GetSimPosition(), GetIdentityQuaternion())
    end
end

function ClientUnit:IsHighlightable()
    return (self:IsIntelVisionVisible() or self:IsIntelRadarVisible() or self:IsIntelSonarVisible()) and not self:IsUpgrade()
end

function ClientUnit:IsSelectable()
    return IsFocused(self.armyId) and self:IsIntelVisionVisible() and not self:IsUpgrade()
end

---Whether this unit type can dash.
---@return boolean canDash
function ClientUnit:DashBehaviorIsValidFor()
    return false
end

---Creates a new decal using unit's position
---@param decalPrefabID PrefabID ID of the decal prefab
---@param sizeX number Width
---@param sizeZ number Height
---@param rotation? number Rotation in degrees
---@param lifeTime? number Decal will be deleted after this amount of seconds.
---@return Decal|nil decal Created decal class or nil
function ClientUnit:CreateDecal(decalPrefabID, sizeX, sizeZ, rotation, lifeTime)
    local position = self:GetSimPosition()

    ---@type Decal|nil
    local decal = Decals.CreateDecal(decalPrefabID, position, EngineClasses.float3(sizeX, sizeZ, math.min(sizeX, sizeZ)), rotation, lifeTime)

    return decal
end

---Creates a random explosion decal based on units size.
function ClientUnit:CreateRandomScorchmark()
    local collisionSize = self.tp.collisionInfo and self.tp.collisionInfo.collisionSize
    local scale = ScorchMarkMinSize * ScorchMarkSizeMultiplier
    if collisionSize then
        scale = math.max(collisionSize.x, collisionSize.z) * ScorchMarkSizeMultiplier
    end

    local randomScorchmarkDecalID = _G.ScorchmarkDecalPrefabIDs[math.random(1, #_G.ScorchmarkDecalPrefabIDs)]
    self:CreateDecal(randomScorchmarkDecalID, scale, scale, math.random(-180, 180), 300)
end

function ClientUnit:SetUIDirtyIfSelected()
    if self.isSelected then
        UIManager.SetUIDirty()
    end
end

---@public Return if the specific toggle exists.
---@param toggleName ToggleName
---@return boolean exists If the toggle exists
function ClientUnit:HasToggle(toggleName)
    return self.toggles[toggleName] ~= nil
end

---comment
---@param toggle ToggleName
---@param value boolean
function ClientUnit:SetToggle(toggle, value)
    self.toggles[toggle] = value

    if toggle == "Pause" then
        self:SetPause(value)
    end

    self:SetUIDirtyIfSelected()
end

function ClientUnit:SetRepeatBuild(value)
    self.toggles.RepeatBuild = value
end

function ClientUnit:GetRepeatBuild()
    return self.toggles.RepeatBuild
end

function ClientUnit:SetPause(value)
    self.toggles.Pause = value
    self.icons.Pause:SetEnabled(value)
end

function ClientUnit:GetPause()
    return self.toggles.Pause
end

function ClientUnit:SetShieldToggle(value)
    self.toggles.Shield = value
end

function ClientUnit:GetShieldToggle()
    return self.toggles.Shield
end

function ClientUnit:SetIntelToggle(value)
    self.toggles.Intel = value
end

function ClientUnit:GetIntelToggle()
    return self.toggles.Intel
end

---@public
---@param value boolean 
function ClientUnit:SetProductionToggle(value)
    self.toggles.Production = value
end

function ClientUnit:GetProductionToggle()
    return self.toggles.Production
end

---@public Get toggle that tracks surfaced vs. submerged movement.
---@return boolean toggle True while the unit is commanded to submerge.
function ClientUnit:GetSubmergeToggle()
    return self.toggles.Submerge
end

---@public Whether this unit is able to submerge.
---@return boolean canSubmerge True if the unit is able to submerge.
function ClientUnit:CanSubmerge()
    return false
end

function ClientUnit:SetVisionRingsEnabled(enabled)
    local visionRing = self:GetRangeRing(RangeRingMaterial.Vision)
    if visionRing then visionRing:SetEnabled(enabled) end

    local fogOfWarRing = self:GetRangeRing(RangeRingMaterial.FogOfWar)
    if fogOfWarRing then fogOfWarRing:SetEnabled(enabled) end
end

function ClientUnit:SetRadarRingEnabled(enabled)
    local ring = self:GetRangeRing(RangeRingMaterial.IntelRadar)
    if ring then ring:SetEnabled(enabled) end
end

function ClientUnit:SetSonarRingEnabled(enabled)
    local ring = self:GetRangeRing(RangeRingMaterial.IntelSonar)
    if ring then ring:SetEnabled(enabled) end
end

-- Called whenever unit.simOrderState.activeOrder changes.
-- NOTE: This is the sim order which means the idle state does not handle client prediction (yet)
function ClientUnit:OnOrderChanged()
    self:CheckShowIdleAdornment()
end

---Sets a new resource balance for this unit. Recieved from the host.
---@param data table<ResourceName, number>
function ClientUnit:SetEconomyValues(data)
    for resName, amount in pairs(data) do
        self.resources[resName] = amount
    end
end

---Sets new build power. Recieved from the host.
---@param newBuildPower number
function ClientUnit:SetBuildPower(newBuildPower)
    self.buildPower = newBuildPower
end

---Checks if unit has specified tags.
---@param tags any Tags to check
---@return boolean
function ClientUnit:HasTags(tags)
    return tags[self.tpId]
end

---Sets a new build queue. Recieved from the host.
---@param newQueue table
function ClientUnit:UpdateBuildQueue(newQueue)
    self.buildQueue = newQueue
    self.predictedBuildQueue = table.deepCopy(newQueue)
    for _, pendingOperation in ipairs(self.buildQueuePendingOperations) do
        if pendingOperation.isRemoval then
            buildQueueUtils.RemoveFromBuildQueue(self, pendingOperation.entryIds, true)
        else
            buildQueueUtils.AddToBuildQueue(self, pendingOperation.tpId, pendingOperation.entryIds, pendingOperation.targetItemEntryId, true)
        end
    end
    self:CheckShowIdleAdornment()
    self:CheckShowUpgradingAdornment()
end

---Returns volume of the hitbox
---@return number|0 volume Hitbox volume, default to 0.
function ClientUnit:GetVolume()
    local size = self.tp.collisionInfo and self.tp.collisionInfo.collisionSize
    if not size then
        return 0
    end

    return size.x * size.y * size.z
end

---Changes units color.  
---Changing army color will overwrite this.
---@param color float4 RGBA format, alpha is not used for units.
function ClientUnit:SetColor(color)
    Engine.SetRendererInstanceData0(self.localId, color)
end

---Returns current unit's color
---@return float4 color RGBA format
function ClientUnit:GetColor()
    local _, color = Engine.GetRendererInstanceData0(self.localId)
    return color
end



---Set up all holes the unit should have
function ClientUnit:SetUpHoles()
    if not self.holes then
        self.holes = {}
    end

    local holesTp = self.tp.visuals and self.tp.visuals.holes
    if holesTp then
        for index, data in ipairs(holesTp) do
            
            local hole = Holes.Hole(self.localId, index - 1)

            table.insert(self.holes, hole)
        end
    end
end




---Returns a number of holes on the local entity
---@return integer count
function ClientUnit:GetHoleCount()
    local _, holeCount = Engine.GetHoleCount(self.localId)
    return holeCount
end

---Returns hol if the unit has it.
---@param index integer Nth hole on the unit
---@return Hole|nil
function ClientUnit:GetHole(index)
    local hole = self.holes and self.holes[index]
    if not hole then
        Warn("ClientUnit:GetHole: Trying to get invalid hole: " .. tostring(index))
        return nil
    end

    return hole
end



---Set up all range rings the unit should have
function ClientUnit:SetUpRangeRings()
    if self.tp.ranges then
        self.rangeRings = {}
        for material, ranges in pairs(self.tp.ranges) do
            self.rangeRings[material] = RangeRings.RangeRing(self.localId, ranges.ringIndex, material)
        end
    end

    Engine.SetRangeRingsEnabled(self.localId, IsFocused(self.armyId))
end




---Returns number of range rings the unit has
---@return integer numRangeRings Number of range rings
function ClientUnit:GetRangeRingCount()
    local _, ringCount = Engine.GetRangeRingCount(self.localId)
    return ringCount
end

---Returns range ring if the unit has it.
---@param name RangeRingType Type/name of the ring to get
---@return RangeRing|nil
function ClientUnit:GetRangeRing(name)
    local ring = self.rangeRings and self.rangeRings[name]
    if not ring then
        Warn("ClientUnit:GetRangeRing: Trying to get invalid ring: " .. tostring(name))
        return nil
    end

    return ring
end

---@protected Marks the unit icons for enable/disable. The icons might not show due to the intel state of the unit to the player.
---@param enabled boolean
function ClientUnit:EnableUnitIcons(enabled) 
    if self.iconsEnabled == enabled then return end
    self.iconsEnabled = enabled
    self:RecalculateUnitIconState()
end

---@protected Recalculate if the unit icons should be visible..
function ClientUnit:RecalculateUnitIconState()
    Engine.SetIconsEnabled(self.localId, self.iconsEnabled == true and not self:IsUpgrade() and (self.isIntelVisionVisible or self.isIntelRadarVisible or self.isIntelSonarVisible))
end

---Set up unit icon
function ClientUnit:SetUpIcon()

    local unitColor = self:GetColor()

    for name, iconInformation in pairs(self.tp.general.icon.runtimeInformation) do
        
        local color = EngineClasses.float4(1, 1, 1, 1)

        if name == "StrategicIcon" then
            color = table.deepCopy(unitColor)

            -- Ghosts and Inprogress units get a slightly transparent icon.
            if self:IsPlacementGhost() then
                color.w = PlacementGhostIconAlpha
            elseif not self:IsCompleted() then
                color.w = InConstructionIconAlpha
            end
        end
        
        if name == "RadarIcon" then
            color = table.deepCopy(RadarIconColor)

            -- Inprogress units get a slightly transparent icon.
            if not self:IsCompleted() then
                color.w = InConstructionIconAlpha
            end
        end

        self:AddPreExistingIcon(name, iconInformation.index, iconInformation.name, color)
    end
end


---Creates a new icon for the unit from an already existing icon added during prefab creation.
---@param name string Name of the icon, used as a key to store the icon
---@param iconIndex number The index of the icon when trying to grab the icon from the entity.
---@param imageName string Name of the image file inside `StrategicIcons` folder
---@param color? float4 Color in RGBA format
---@return StrategicIcon|nil icon Created icon class
function ClientUnit:AddPreExistingIcon(name, iconIndex, imageName, color)
    if not self.icons then
        self.icons = {}
    elseif self.icons[name] then
        Warn(string.format("ClientUnit:AddIcon: unit: %d tpId: %s, icon '%s' already exists!", self.localId, self.tpId, name))
        return
    end

    local icon = Icons.AddPreExistingIcon(self.localId, iconIndex, imageName)
    self.icons[name] = icon
    
    if color then icon:SetColor(color) end
    return icon
end



---Returns number of icons this unit has
---@return integer numIcons Number of icons
function ClientUnit:GetIconCount()
    local _, iconCount = Engine.GetIconCount(self.localId)
    return iconCount
end

---Returns unit's icon if it exists
---@param name string Name of the icon to get
---@return StrategicIcon|nil
function ClientUnit:GetIcon(name)
    local icon = self.icons and self.icons[name]
    if not icon then
        Warn("ClientUnit:GetIcon: Trying to get invalid icon: " .. tostring(name))
        return
    end

    return icon
end

function ClientUnit:CanShowIdleAdornment()
    return false
end

function ClientUnit:CheckShowIdleAdornment()
    
    if not self.tp.construction then return end

    -- engineers and slave factorieslave orders
    local hasOrder = self.simOrderState.activeOrder ~= nil
    -- master factories have build queue items    
    local hasBuildQueueItem = self.buildQueue and #self.buildQueue > 0
    local shouldDisplay = self:IsCompleted() and not (hasOrder or hasBuildQueueItem)
    
    -- Don't show idle icons for strucutres like alloy extractors
    if not self:CanShowIdleAdornment() then
        shouldDisplay = false
    end

    self.icons.Idle:SetEnabled(shouldDisplay)
end

function ClientUnit:IsUpgradeQueued()
    -- if we dont have an upgrade in the queue it returns our own tpId
    return buildQueueUtils.GetHighestQueuedUpgradeTemplateId(self) ~= self.tp.general.tpId
end


function ClientUnit:CheckShowUpgradingAdornment()
    if not self.tp.construction then return end

    self.icons.Upgrade:SetEnabled(self:IsUpgradeQueued())
end

---@private Update icon sorting when sleection/highlight changes.
function ClientUnit:RecalculateIconSorting()
    
    -- TODO: Should eventually use the icon.priority value from the template.
    local defaultIconSort = 0

    -- Selected things are always on top of normal icons.
    if self.isSelected then
        defaultIconSort = defaultIconSort + 1000
    end

    -- Highlighted things are always on the top.
    if self.isHighlighted then
        defaultIconSort = defaultIconSort + 10000
    end

    -- If we are highlighted + selected we will be on top of everything with a value of 11000 + defaultIconSort
    Engine.SetIconsSorting(self.localId, defaultIconSort)
end

---Change the Highlightable state of the Highlightable.
---@param isHighlighted boolean If the unit is highlighted
function ClientUnit:OnHighlight(isHighlighted)
    Highlightable.OnHighlight(self, isHighlighted)

    if not self.dead then
        local icon = self.icons and self.icons.StrategicIcon
        
        if icon then
            icon:MouseOver(isHighlighted)
        end

        local radarIcon = self.icons and self.icons.RadarIcon
        if radarIcon then
            radarIcon:MouseOver(isHighlighted)
        end

        if not self.isSelected then
            self:SetSelectionBracketEnabled(isHighlighted)
        end
    end

    for _, ring in pairs(self.rangeRings or {}) do
        ring:OnHighlight(isHighlighted)
    end

    self:RecalculateIconSorting()
end

---Updates UI elements when the unit is selected
---@param selected boolean If the unit is selected
function ClientUnit:OnSelect(selected)
    Selectable.OnSelect(self, selected)

    self:SetAudioSourcesRTPC(isSelectedRTPCID, selected and 1 or 0)

    if not self.dead then
        local icon = self.icons and self.icons.StrategicIcon
        if icon then
            icon:Select(selected)
        end

        self:SetSelectionBracketEnabled(selected)
    end

    for _, ring in pairs(self.rangeRings or {}) do
        ring:OnSelect(selected)
    end

    self:RecalculateIconSorting()
end

function ClientUnit:SetProgressBarsEnabled(enabled)
    if self.progressBarsEnabled == enabled then
        return
    end
    self.progressBarsEnabled = enabled
    Engine.SetProgressBarsEnabled(self.localId, enabled)
end

function ClientUnit:UpdateProgressBars(health, maxHealth)
    self:SetProgressBarsEnabled(self.isIntelVisionVisible and not self:IsPlacementGhost())
    self.healthProgressBar:SetMaxValue(maxHealth)
    if health ~= maxHealth then
        self.healthProgressBar:SetValue(health)
        self.healthProgressBar:SetEnabled(true)
    else
        self.healthProgressBar:SetEnabled(false)
    end
    
    if self.progress and not self:IsCompleted() then
        self.constructionProgressBar:SetValue(self:GetFractionComplete())
        self.constructionProgressBar:SetEnabled(true)
    end

    if self:IsCompleted() then
        if self.buildTarget then
            self.constructionProgressBar:SetValue(self.buildTarget:GetFractionComplete())
            self.constructionProgressBar:SetEnabled(true)
        elseif self.captureTarget then 
            if self.captureTarget.captureProgress and self.captureTarget.captureProgress > 0 then
                local workTime = self.captureTarget.tp.economy.buildTime
                self.constructionProgressBar:SetValue(self.captureTarget.captureProgress / workTime)
                self.constructionProgressBar:SetEnabled(true)
            end
        elseif self.reclaimTarget then
            if self.reclaimTarget.reclaimProgress and self.reclaimTarget.reclaimProgress > 0 then
                local workTime = self.reclaimTarget.tp.economy.harvestTime or self.reclaimTarget.tp.economy.buildTime
                self.constructionProgressBar:SetValue(self.reclaimTarget.reclaimProgress / workTime)
                self.constructionProgressBar:SetEnabled(true)
            end
        elseif self.repairTarget then
            if self.repairTarget:GetHealth() < self.repairTarget:GetMaxHealth() then
                local progress = self.repairTarget:GetHealth() / self.repairTarget:GetMaxHealth()
                self.constructionProgressBar:SetValue(progress)
                self.constructionProgressBar:SetEnabled(true)
            elseif self.repairTarget.captureProgress and self.repairTarget.captureProgress > 0 then
                local workTime = self.repairTarget.tp.economy.buildTime
                self.constructionProgressBar:SetValue(1 - self.repairTarget.captureProgress / workTime)
                self.constructionProgressBar:SetEnabled(true)
            elseif self.repairTarget.reclaimProgress and self.repairTarget.reclaimProgress > 0 then
                local workTime = self.repairTarget.tp.economy.buildTime
                self.constructionProgressBar:SetValue(1 - self.repairTarget.reclaimProgress / workTime)
                self.constructionProgressBar:SetEnabled(true)
            end
        else
            self.constructionProgressBar:SetEnabled(false)
        end
    end

    if self.shields then
        for i, shield in ipairs(self.shields) do
            local rechargeProgress, rechargeDuration = shield:GetRechargeProgress()
            if rechargeProgress then
                self.shieldProgressBars[i]:SetMaxValue(rechargeDuration)
                self.shieldProgressBars[i]:SetValue(rechargeProgress)
                self.shieldProgressBars[i]:SetEnabled(true)
            elseif shield:IsEnabled() then
                local shieldHealth = shield:GetHealth()
                local shieldMaxHealth = shield:GetMaxHealth()

                if shieldHealth ~= shieldMaxHealth then
                    self.shieldProgressBars[i]:SetMaxValue(shieldMaxHealth)
                    self.shieldProgressBars[i]:SetValue(shieldHealth)
                    self.shieldProgressBars[i]:SetEnabled(true)
                else
                    self.shieldProgressBars[i]:SetEnabled(false)
                end
            else
                self.shieldProgressBars[i]:SetEnabled(false)
            end
        end
    end
end

function ClientUnit:SetRenderBuildProgress(fractionComplete)
    local _, instanceData1 = Engine.GetRendererInstanceData1(self.localId)
    instanceData1.x = 1 - fractionComplete
    Engine.SetRendererInstanceData1(self.localId, instanceData1)
end

---Set up all progress bars the unit should have
function ClientUnit:SetUpProgressBars()
    self.healthProgressBar = self:AddProgressBarFromPrefab(self.localId, 0, "Health")

    --if self.tp.construction then
        self.constructionProgressBar = self:AddProgressBarFromPrefab(self.localId, 1, "WorkProgress")
    --end

    self:SetUpShieldBars()
end

function ClientUnit:SetUpShieldBars()
    if not self.tp.defence.shields then
        return
    end

    self.shieldProgressBars = {}
    for i, _ in ipairs(self.tp.defence.shields) do
        table.insert(self.shieldProgressBars, self:AddProgressBarFromPrefab(self.localId, 1 + i, "Shield"..i))
    end
end

function ClientUnit:AddProgressBarFromPrefab(localID, index, name)
    if not self.progressBars then
        self.progressBars = {}
    elseif self.progressBars[name] then
        Warn(string.format("ClientUnit:AddProgressBar: unit: %d tpId: %s, bar '%s' already exists!", self.localId.index, self.tpId, name))
        return
    end

    local progressBar = ProgressBars.CreateProgressBarFromEntity(localID, index)
    self.progressBars[name] = progressBar
    return progressBar
end




---Returns number of progress bars this unit has
---@return integer numProgressBars Number of progress bars
function ClientUnit:GetProgressBarCount()
    local _, count = Engine.GetProgressBarCount(self.localId)
    return count
end

---Returns prgoress bar with given name or nil
---@param name string Name of the bar to get
---@return ProgressBar|nil
function ClientUnit:GetProgressBar(name)
    local bar = self.progressBars and self.progressBars[name]
    if not bar then
        Warn("ClientUnit:GetProgressBar: Trying to get invalid bar: " .. tostring(name))
        return nil
    end

    return bar
end

---Set up size and offset of the selection brackets
function ClientUnit:SetUpSelection()
    _, self.selectionBracketID = Engine.GetLocalBone(self.localId, "Selection Bracket")
    self:SetSelectionBracketEnabled(false)

    self.selectionColliderID = EngineClasses.LocalID()
    Engine.GetLocalBone(self.localId, "Selection Collider", self.selectionColliderID)
end

---Enable/Disable the collider which allows the unit to be selected
function ClientUnit:SetSelectionEnabled(enabled)
    Engine.SetVolumeColliderEnabled(self.selectionColliderID, enabled)
end

---Enable/Disable rendering of the selection brackets
---@param enabled boolean
function ClientUnit:SetSelectionBracketEnabled(enabled)
    Engine.SetRendererEnabled(self.selectionBracketID, enabled)
end

---Set selection brackets offset from the root bone
---@param offset float3 Offset from the root bone
function ClientUnit:SetSelectionBracketOffset(offset)
    Engine.SetLocalEntityLocalPosition(self.selectionBracketID, offset)
end

---Set selection brackets size
---@param size float2 Size
function ClientUnit:SetSelectionBracketSize(size)
    Engine.SetMeshRendererScale(self.selectionBracketID, EngineClasses.float3(size.x, 1, size.y))
end

---Check if the brackets are currently rendering
---@return boolean enabled
function ClientUnit:GetSelectionBracketEnabled()
    local _, enabled = Engine.GetRendererEnabled(self.selectionBracketID)
    return enabled
end

---Returns current selection brackets offset from the root bone
---@return float3 offset Current offset from the root bone
function ClientUnit:GetSelectionBracketOffset()
    local offset = {}
    Engine.GetLocalEntityLocalPosition(self.localId, offset)
    return offset
end

---Returns current selection brackets size
---@return float2 size Current size
function ClientUnit:GetSelectionBracketSize()
    local scale = {}
    Engine.GetMeshRendererScale(self.selectionBracketID, scale)
    return math3D.tofloat2(scale)
end

---Set selection bounds offset from the root bone
---@param offset float3 Offset from the root bone
function ClientUnit:SetSelectionBoundsOffset(offset)
    Engine.SetSelectionBoundsOffset(self.localId, offset)
end

---Set selection bounds for entity. Used to decide if to select the unit with click or click and drag
---@param size float3 Size of the selection bound
function ClientUnit:SetSelectionBoundsScale(size)
    Engine.SetSelectionBoundsScale(self.localId, size)
end

---Returns selection bounds offset from root bone
---@return float3 offset Current offset from the root bone
function ClientUnit:GetSelectionBoundsOffset()
    local offset = {}
    Engine.GetSelectionBoundsOffset(self.localId, offset)
    return offset
end

---Retunrs current selection bound size
---@return float3 size Current size of the selection bound
function ClientUnit:GetSelectionBoundsScale()
    local scale = {}
    Engine.GetSelectionBoundsScale(self.localId, scale)
    return scale
end

function ClientUnit:GetDebugStr()
    return string.format("ClientUnit: %s - %s, localID: %d, globalId: %d. ", self.tpId, self.name, self.localId, self.id)
end

---Sets up any weapons the unit has.
function ClientUnit:SetUpWeapons()
    local weapons = self.tp.weapons
    if not weapons then
        return
    end

    self.weapons = {}

    for i, weapon in ipairs(weapons) do
        self.weapons[i] = ClientWeapons.RegisterClientWeapon(self, weapon)
        for _, muzzle in ipairs(self.weapons[i].muzzles) do
            if muzzle.beam then
                self.beams = self.beams or {}
                table.insert(self.beams, muzzle.beam)
            end
        end
    end
end

function ClientUnit:CleanupWeapons()
    for _, weapon in ipairs(self.weapons or {}) do
        weapon:Cleanup()
    end
end

function ClientUnit:CleanupShields()
    for _, shield in ipairs(self.shields or {}) do
        shield:Delete()
    end
    self.shields = nil
end

function ClientUnit:SetUpShields()
    if not self.tp.defence.shields then
        return
    end

    self.shields = {}

    local hasTags = self.tp.hasTags
    local factionTag = (hasTags.CHOSEN and "CHOSEN") or (hasTags.EDA and "EDA") or "GUARD"
    local impactEffectPrefabs = ShieldImpactEffectPrefabs[factionTag]

    for i, shieldTp in ipairs(self.tp.defence.shields) do
        local shieldEntityName = shieldTp.entityName
            or shieldTp.boneName..'ShieldEntity'
        local shieldLocalID = self:GetBoneId(shieldEntityName)
        if not shieldTp then
            Error(string.format("SetUpShields: Unit id: %d, tpId: %s, Shield num: %d was not found in the template.", self.id.index, self.tpId, i))
        elseif not Engine.IsValidLocalID(shieldLocalID) then
            Error(string.format("SetUpShields: tpId: %s, Shield num: %d has no global Id.", self.tpId, i))
        end

        local shieldGlobalID = {}
        Engine.GetLocalEntityGlobalID(shieldLocalID, shieldGlobalID)

        local shieldGlowLocalID = self:GetBoneId(shieldEntityName..'_Glow')

        local shieldPersistentEffectLocalIds
        if shieldTp.effectsPersistent then
            shieldPersistentEffectLocalIds = self:CalculatePersistentEffectIds(shieldTp.effectsPersistent)
        end

        local shieldAudio = shieldTp.audio and shieldTp.audio.active and shieldTp.audio.active.name and shieldTp.audio.active or nil
        local shieldImpactAudio = shieldTp.audio and shieldTp.audio.onImpact
        local shield = Import("client/entities/shield.lua").ClientShield(shieldGlobalID, shieldLocalID, shieldGlowLocalID, shieldPersistentEffectLocalIds, self.army, shieldAudio, shieldImpactAudio, impactEffectPrefabs)
        table.insert(self.shields, shield)
    end
end

function ClientUnit:SetUpAudioSources()
    self.audioSources = {}
    self.audioRtpcs = {}

    if not self.tp.audio then
        return
    end

    local function AddAudioSource(audio, entityName, emitting)
        if not (audio and audio.name) then
            return nil
        end

        local source = {
            localId = entityName and self:GetBoneId(entityName) or self.localId,
            stopEventID = audio.stopEventID,
            emitting = emitting,
        }
        table.insert(self.audioSources, source)
        return source
    end

    self.activeAudio = AddAudioSource(self.tp.audio.active, nil, false)
    self.motorAudio = AddAudioSource(self.tp.audio.engine, "EngineAudioEntity", false)
    self.productionAudio = AddAudioSource(self.tp.audio.production, "ProductionAudioEntity", false)
    self.constructionAudio = AddAudioSource(self.tp.audio.gettingConstructed, "ConstructionProgressAudioEntity", false)
end

function ClientUnit:SetAudioSourceEmitting(source, emitting)
    if not source or source.emitting == emitting then
        return
    end
    source.emitting = emitting

    if not emitting and source.stopEventID then
        Engine.StopAudioSourceSound(source.localId, source.stopEventID)
    else
        Engine.SetAudioSourceCanEmitPersistentSound(source.localId, emitting)
    end
end

function ClientUnit:SetAudioSourcesRTPC(rtpcID, value)
    if self.audioRtpcs[rtpcID.Value] == value then
        return
    end
    self.audioRtpcs[rtpcID.Value] = value
    for _, source in ipairs(self.audioSources) do
        Engine.SetAudioSourceRTPC(source.localId, rtpcID, value)
    end
end

function ClientUnit:UpdateAudio(health, maxHealth)
    if self.dead then
        return
    end

    if self.motorAudio then
        local _, currentSpeed = Engine.GetMovementCurrentSpeed(self.id)

        local isAirUnit = self:HasTags(Tags.AIR)
        self:SetAudioSourceEmitting(self.motorAudio, isAirUnit or currentSpeed > 0)

        local speedValue = math.min((currentSpeed / (self.tp.movement.speed * Constants.TickTimeStep)) * 100, 100)
        self:SetAudioSourcesRTPC(unitSpeedRTPCID, speedValue)

        if isAirUnit then
            local _, rollDegrees = Engine.GetMovementRollDegrees(self.id)
            local fullBankDegrees = math.abs(self.tp.movement.maxBankDegrees)
            local bankValue = fullBankDegrees > 0 and (rollDegrees / fullBankDegrees) * 100 or 0
            self:SetAudioSourcesRTPC(unitBankAngleRTPCID, math.max(-100, math.min(100, bankValue)))
        end
    end

    self:SetAudioSourcesRTPC(unitHealthRTPCID, (health / maxHealth) * 100)

    if self.buildTarget then
        local progress = self.buildTarget:GetFractionComplete()
        self:SetAudioSourcesRTPC(constructionSpeedRTPCID, (progress - self.audioBuildProgress) * 100)
        self.audioBuildProgress = progress
    end
end

--- Plays or stops the sound the unit makes while it builds something.
function ClientUnit:SetProductionAudioEnabled(enabled)
    self:SetAudioSourceEmitting(self.productionAudio, enabled)
end

--- Plays or stops the sound the unit makes while someone else builds it.
function ClientUnit:SetConstructionAudioEnabled(enabled)
    self:SetAudioSourceEmitting(self.constructionAudio, enabled)
end

function ClientUnit:StopAudioSources()
    for _, source in ipairs(self.audioSources) do
        self:SetAudioSourceEmitting(source, false)
    end
end

----------
-- Effects
----------

---@protected Gets all the persistent effect entities and puts it in self.persistentEffects
function ClientUnit:SetUpPersistentEffects()
    if self.tp.visuals and self.tp.visuals.effectsPersistent then
        self.persistentEffects = self:CalculatePersistentEffectIds(self.tp.visuals.effectsPersistent)
    end
end

---@protected Gets all the build/active effect entities and puts it in self.effectsWhenActive
function ClientUnit:SetUpEffectsWhenActive()
    if self.tp.visuals and self.tp.visuals.effectsWhenActive then
        self.effectsWhenActive = self:CalculatePersistentEffectIds(self.tp.visuals.effectsWhenActive)
    end
end

---@protected Marks the construction beam for enable/disable. The beam may not show due to the intel state.
---@param enabled boolean
function ClientUnit:EnableConstructionBeam(enabled)
    if self.constructionBeamEnabled == enabled then return end
    self.constructionBeamEnabled = enabled
    self:RecalculateConstructionBeamState()
end

---@protected Marks the build effects for enable/disable. The build effects might now show due to the intel state to the player.
---@param enabled boolean
function ClientUnit:EnableBuildEffects(enabled) 
    if self.buildEffectsEnabled == enabled then return end
    self.buildEffectsEnabled = enabled
    self:RecalculateBuildEffectsState()
end

---@protected Marks the persistent effects for enable/disable. The persistent effects might now show due to the intel state to the player.
---@param enabled boolean
function ClientUnit:EnablePersistentEffects(enabled) 
    if self.persistentEffectsEnabled == enabled then return end
    self.persistentEffectsEnabled = enabled
    self:RecalculatePersistentEffectsState()
end

---@protected Recalculate if the construction beam should render.
function ClientUnit:RecalculateConstructionBeamState()
    if self.constructionBeam then
        self.constructionBeam:SetEnabled(self.constructionBeamEnabled == true and self:IsIntelVisionVisible() == true)
    end
end

---@protected Recalculate if the build effects should emit.
function ClientUnit:RecalculateBuildEffectsState()
    self:SetPersistentEffectsState(self.effectsWhenActive, self.buildEffectsEnabled == true and self:IsIntelVisionVisible() == true)
end

---@protected Recalculate if the persistent effects should emit.
function ClientUnit:RecalculatePersistentEffectsState()
    self:SetPersistentEffectsState(self.persistentEffects, self.persistentEffectsEnabled == true and self:IsIntelVisionVisible() == true)
end

---@protected Recalculate whether the unit's audio sources are allowed to emit.
function ClientUnit:RecalculateAudioSourcesState()
    local audioEnabled = self:IsIntelVisionVisible()

    for _, source in ipairs(self.audioSources) do
        Engine.SetAudioSourceEnabled(source.localId, audioEnabled)
    end

    for _, weapon in ipairs(self.weapons or {}) do
        for _, muzzle in ipairs(weapon.muzzles) do
            if muzzle.fireAudioLocalId then
                Engine.SetAudioSourceEnabled(muzzle.fireAudioLocalId, audioEnabled)
            end
        end
    end
end

function ClientUnit:RecalculateShieldEffectsState()
    for _, shield in ipairs(self.shields or {}) do
        shield:SetOwnerIntelVisible(self:IsIntelVisionVisible())
    end
end

function ClientUnit:CalculatePersistentEffectIds(effectTemplates)
    local effectLocalIds = {}
    for i, effect in ipairs(effectTemplates) do
        local boneId = self:GetBoneId(effect.effectEntityName)
        if Engine.IsValidLocalID(boneId) then
            table.insert(effectLocalIds, boneId)
        else
            -- We have too many of these, so I've commented it out to avoid spamming the console
            --Warn(string.format("SetUpPersistentEffects: tpId: %s, Effect num: %d has no bone.", self.tpId, i))
        end
    end
    return effectLocalIds
end

----------
-- Intel
----------

---Returns if the unit is visible to the player on vision.
---@return boolean isIntelVisionVisible If the unit is visible to the player.
function ClientUnit:IsIntelVisionVisible()
    return self.isIntelVisionVisible
end

---@public Update the Unit's intel visibility mask. Will create an OnIntelHidden, OnIntelVision, OnIntelRadar or OnIntelSonar if the intel state changed to the player.
---@param visionDetectionMask IntelBitMask
function ClientUnit:UpdateIntelVisionDetection(visionDetectionMask)
    self.visibilityMask = visionDetectionMask
    self:RecalculateIntel()
end

---Returns if the unit is visible to the player on radar.
---@return boolean isIntelRadarVisible If the unit is visible to the player.
function ClientUnit:IsIntelRadarVisible()
    return self.isIntelRadarVisible
end

---@public Update the Unit's intel radar mask. Will create an OnIntelHidden, OnIntelVision, OnIntelRadar or OnIntelSonar if the intel state changed to the player.
---@param radarDetectionMask IntelBitMask
function ClientUnit:UpdateIntelRadarDetection(radarDetectionMask)
    self.radarMask = radarDetectionMask
    self:RecalculateIntel()
end

---Returns if the unit is visible to the player on sonar.
---@return boolean isIntelSonarVisible If the unit is visible to the player.
function ClientUnit:IsIntelSonarVisible()
    return self.isIntelSonarVisible
end

---@public Update the Unit's intel sonar mask. Will create an OnIntelHidden, OnIntelVision, OnIntelRadar or OnIntelSonar if the intel state changed to the player.
---@param sonarDetectionMask IntelBitMask
function ClientUnit:UpdateIntelSonarDetection(sonarDetectionMask)
    self.sonarMask = sonarDetectionMask
    self:RecalculateIntel()
end

---@protected Called whenever the the unit has no source of intel and should be "hidden" to the player.
function ClientUnit:OnIntelHidden()

    Engine.SetRendererEnabled(self.localId, false)
    Engine.SetRangeRingsEnabled(self.localId, false)
    self:SetProgressBarsEnabled(false)

    self:SetSelectionEnabled(false)

    self:RecalculateUnitIconState()
    self:RecalculateConstructionBeamState()
    self:RecalculateBuildEffectsState()
    self:RecalculatePersistentEffectsState()
    self:RecalculateAudioSourcesState()
    self:RecalculateShieldEffectsState()
    self:CheckShowIdleAdornment()
end

---@protected Called whenever the source of intel becomes vision.
function ClientUnit:OnIntelVision()
    
    Engine.SetRendererEnabled(self.localId, true)
    Engine.SetRangeRingsEnabled(self.localId, true)
    if not self:IsPlacementGhost() then
        self:SetProgressBarsEnabled(true)
    end

    self:SetSelectionEnabled(true)

    self:RecalculateConstructionBeamState()
    self:RecalculateBuildEffectsState()
    self:RecalculatePersistentEffectsState()
    self:RecalculateAudioSourcesState()
    self:RecalculateShieldEffectsState()

    self.icons.StrategicIcon:SetEnabled(true)
    self.icons.RadarIcon:SetEnabled(false)
    self:RecalculateUnitIconState()

    Engine.SetRangeRingsEnabled(self.localId, self:IsCompleted() and not self:IsPlacementGhost() and self:IsOwnedOrAlly())

    -- TODO: If its an allied army we should see intel related range rings.
    -- if isIntelVisionVisible then
    --     self.rangeRings["Vision"]:SetEnabled(isIntelVisionVisible)
    --     self.rangeRings["FogOfWar"]:SetEnabled(isIntelVisionVisible)
    -- end
end

---@protected Called whenever the source of intel becomes radar.
function ClientUnit:OnIntelRadar()
    Engine.SetRendererEnabled(self.localId, false)
    Engine.SetRangeRingsEnabled(self.localId, false)
    self:SetProgressBarsEnabled(false)

    self:RecalculateAudioSourcesState()
    self:RecalculateShieldEffectsState()

    self:SetSelectionEnabled(true)

    self.icons.StrategicIcon:SetEnabled(false)
    self.icons.RadarIcon:SetEnabled(true)
    self:RecalculateUnitIconState()
end

---@protected Called whenever the source of intel becomes sonar.
function ClientUnit:OnIntelSonar()
    Engine.SetRendererEnabled(self.localId, false)
    Engine.SetRangeRingsEnabled(self.localId, false)
    self:SetProgressBarsEnabled(false)

    self:RecalculateAudioSourcesState()
    self:RecalculateShieldEffectsState()

    self:SetSelectionEnabled(true)

    self.icons.StrategicIcon:SetEnabled(false)
    self.icons.RadarIcon:SetEnabled(true)
    self:RecalculateUnitIconState()
end

---@protected Recalculate which source of intel (Hidden, Vision, Radar, Sonar) this unit is visible to. Will call OnIntelHidden, OnIntelVision, OnIntelRadar or OnIntelSonar if the source changed.
---@param forceEvent? boolean Force a full recalculation. This will call the OnIntelHidden, OnIntelVision, OnIntelRadar or OnIntelSonar event even if there is there was no change to the intel state.
function ClientUnit:RecalculateIntel(forceEvent)

    -- Our unit is not initialized yet so recalculating intel should not be done. 
    -- When we finish initializing RecalculateIntel will be called so its ok to return here!
    if self.isInitialized == false then return end

    local focusArmyID = GetFocusArmy()

    if focusArmyID == nil then
        return
    end

    -- If focusArmyID == -1 then we are allowed to see all armies.
    if focusArmyID == -1 then
        if self.isIntelVisionVisible == false or forceEvent then
            self.isIntelVisionVisible = true
            self.isIntelRadarVisible = true
            self.isIntelSonarVisible = true
            self:OnIntelVision()
        end
    else 
        -- Otherwise we lookup our visibility to the player's army. 
        local armyIntelMask = Armies[focusArmyID].intelMask
        
        local wasIntelVisionVisible = self.isIntelVisionVisible
        local wasIntelRadarVisible = self.isIntelRadarVisible
        local wasIntelSonarVisible = self.isIntelSonarVisible

        self.isIntelVisionVisible = self.visibilityMask:IsVisible(armyIntelMask)
        self.isIntelRadarVisible = self.radarMask:IsVisible(armyIntelMask)
        self.isIntelSonarVisible = self.sonarMask:IsVisible(armyIntelMask)

        if self.isIntelVisionVisible then
            if forceEvent or wasIntelVisionVisible == false then
                self:OnIntelVision()
            end
        elseif self.isIntelRadarVisible then
            if forceEvent or wasIntelVisionVisible or wasIntelRadarVisible == false then
                self:OnIntelRadar()
            end
        elseif self.isIntelSonarVisible then
            if forceEvent or wasIntelVisionVisible or wasIntelRadarVisible or wasIntelSonarVisible == false then
                self:OnIntelSonar()
            end
        elseif forceEvent or wasIntelVisionVisible ~= false or wasIntelRadarVisible ~= false or wasIntelSonarVisible ~= false then
            self:OnIntelHidden()
        end
    end
end

---@private If the unit is focused by the player's army or an ally of it.
---@return boolean isOwnedOrAlly If the unit belows to the player's army or an ally of it.
function ClientUnit:IsOwnedOrAlly()
    local focusArmyID = GetFocusArmy()

    if focusArmyID == nil then
        return false
    end

    -- If focusArmyID == -1 then we are allowed to see all armies.
    if focusArmyID == -1 then
        return true
    end

    return Armies[focusArmyID]:IsAlly(self.army)
end

function ClientUnit:RecalculateBeamsIntel()
    if not self.beams then
        return
    end
    for _, beam in ipairs(self.beams) do
        beam:RecalculateIntel()
    end
end

function ClientUnit:SetPersistentEffectsState(effectsArray, enabled)
    if effectsArray then
        for _, localId in ipairs(effectsArray) do
            Engine.SetParticleCanEmit(localId, enabled)
        end
    end
end

--------------------
-- Construction
--------------------

---@public Update the build progress of the unit. Does not properly handle a new progress being less than the current progress. 
---i.e. if the current build progress is 10, the new build progress should be greater or equal to 10.
---Will properly promote a placement ghost to a unit if build progress is above 0.
---@param progress number The new build progress. Assumes build progress > 0.
function ClientUnit:SetBuildProgress(progress)
    
    -- We are going from placement ghost -> real unit!
    if self:IsPlacementGhost() and progress > 0 then
        -- Ensure we update progress for OnPromoteToUnit
        self.progress = progress
        
        self:OnPromoteToUnit()
    end

    local wasCompleted = self:IsCompleted()
    self.progress = progress
    local isNowCompleted = self:IsCompleted()

    if not wasCompleted and isNowCompleted then
        self:OnCompleted()
    end

    if self:IsPlacementGhost() then
        -- TODO: Our build progress would be 0. Set to ghost and everything.
        --self:SetRenderBuildProgress(self:GetFractionComplete())
    else
        self:SetRenderBuildProgress(self:GetFractionComplete())
    end
end

function ClientUnit:SetUpConstructionBeam()
    local beamLocalId = {}
    Engine.GetLocalBone(self.localId, "Construction Beam", beamLocalId)

    if self.tp.construction ~= nil and Engine.IsValidLocalID(beamLocalId) then
        self.constructionBeam = ConstructionBeam.CreateConstructionBeam(self.localId)
    end
end


---@protected Called when this unit starts being upgraded by `upgrader`. Refreshes icon state so icons stay suppressed while the upgrade is in progress.
---@param upgrader ClientUpgrader The unit that has just started upgrading this one.
function ClientUnit:OnStartUpgrade(upgrader)
    self:RecalculateUnitIconState()
end

---@protected Called when this unit stops being upgraded (upgrade completed or cancelled). Refreshes icon state.
---@param upgrader ClientUpgrader The unit that was upgrading this one.
function ClientUnit:OnEndUpgrade(upgrader)
    if self:IsCompleted() then
        Import("client/input/controlGroups.lua").ReplaceInControlGroups(upgrader, self)
    end

    self:RecalculateUnitIconState()
end

---@protected Called when this unit starts upgrading toward the target `upgrade`.
---@param upgrade ClientUpgrade The unit being built as the upgrade target.
function ClientUnit:OnStartUpgrading(upgrade)
end

---@protected Called when this unit stops upgrading (upgrade completed or cancelled).
---@param upgrade ClientUpgrade The unit that was being built as the upgrade target.
function ClientUnit:OnEndUpgrading(upgrade)
end


---@public Called from the host when the unit begins a build routine.
---@param buildableId GlobalID
function ClientUnit:OnStartBuildRoutine(buildableId)
    self.isBuilding = true
    self.buildTarget = GetUnitById(buildableId)

    if self.buildTarget == nil then
        Engine.Error(debug.traceback("OnStartBuildRoutine: the build target was nil. This should never happen."))
        return
    end

    if self.constructionBeam then
        self.constructionBeam:SetTarget(self.buildTarget)
        self:EnableConstructionBeam(true)
    end

    self.audioBuildProgress = self.buildTarget:GetFractionComplete()
    self:SetProductionAudioEnabled(true)
    self.buildTarget:SetConstructionAudioEnabled(true)

    -- Only influence client if we are visible to the client!
    self:EnableBuildEffects(true)

    self:NewThread(self.BuildThread)

    -- Does not respect intel!!!
    -- T4/T5 stay selectable/interactable while under construction
    local isTargetUnitExperimental = self.buildTarget:HasTags(Tags.TECH4) or self.buildTarget:HasTags(Tags.TECH5)
    if (self:HasTags(Tags.STRUCTURE) or not self.buildTarget:HasTags(Tags.STRUCTURE)) and not isTargetUnitExperimental then
        self.buildTarget:SetSelectionEnabled(false)
        SetVolumeColliderEnabled(self.buildTarget.id, false)
    end
end

function ClientUnit:BuildThread()
    if self.constructionBeam then
        while self.isBuilding do
                self.constructionBeam:Update()
            WaitTicks(1)
        end
    end
end

--- Called when the unit has finished getting constructed and should not be active.
function ClientUnit:OnCompleted()
    -- Completed units get full icons.
    self.icons.StrategicIcon:SetAlpha(1)
    self.icons.RadarIcon:SetAlpha(1)
    self:EnableUnitIcons(true)
    self:EnablePersistentEffects(true)
    self:SetAudioSourceEmitting(self.activeAudio, true)
    self:CheckShowIdleAdornment()
    self:CheckShowUpgradingAdornment()
    self:RecalculateIntel(true)
    self:SetSelectionEnabled(true)
end

function ClientUnit:ClientOnStopBuilding()
    self.isBuilding = false

    if self.constructionBeam then
        self.constructionBeam:RemoveTarget()
        self:EnableConstructionBeam(false)
    end

    if self.buildTarget == nil then
        Engine.Error(debug.traceback("ClientOnStopBuilding: buildTarget was nil. This should NEVER happen."))
        return
    end

    
    if self.buildTarget:IsCompleted() then
        self.buildTarget:OnCompleted()
    end

    self:SetProductionAudioEnabled(false)
    self.buildTarget:SetConstructionAudioEnabled(false)

    self:EnableBuildEffects(false)

    -- Does not respect intel!!!
    self.buildTarget:SetSelectionEnabled(true)
    SetVolumeColliderEnabled(self.buildTarget.id, true) -- todo: move into if

    -- clear target reference
    self.buildTarget = nil
end

function ClientUnit:IsCompleted()
    return (self.tp.economy.buildTime - self.progress) <= 0.001
end

function ClientUnit:GetFractionComplete()
    if self:IsCompleted() then
        return 1.0
    else
        return self.progress / self.tp.economy.buildTime
    end
end

function SetVolumeColliderEnabled(globalId, enabled)
    local targetLocalId = {}
    Engine.GetGlobalEntityPairedLocalID(globalId, targetLocalId)
    Engine.SetVolumeColliderEnabled(targetLocalId, enabled)
end


--- Called when the client starts a reclaim operation on a target unit.
--- @param targetUnitId table Serialized GlobalID data.
--- @return nil
function ClientUnit:ClientOnStartReclaim(targetUnitId)
    -- resolve target GlobalID into engine format
    targetUnitId = table.deepCopy(targetUnitId)

    -- mark local reclaim state
    self.isReclaiming = true

    -- save reclaimTarget
    local entity = GetUnitOrPropByGlobalId(targetUnitId)
    if not entity then
        return
    end
    self.reclaimTarget = entity

    -- activate construction beam on the target
    if self.constructionBeam then
        self.constructionBeam:SetTarget(self.reclaimTarget)
        self:EnableConstructionBeam(true)
    end

    -- start local client-side beam thread
    self:NewThread(self.ReclaimThread)
end


--- Local client thread that updates the reclaim beam visuals.
--- Runs while reclaiming remains active.
--- @return nil
function ClientUnit:ReclaimThread()
    while self.isReclaiming do
        -- update beam handling
        if self.constructionBeam then
            self.constructionBeam:Update()
        end
        WaitTicks(1)
    end
end


--- Called when the client stops reclaiming a target.
--- @return nil
function ClientUnit:ClientOnStopReclaim()
    -- clear local reclaim state
    self.isReclaiming = false

    -- remove and disable the construction beam
    if self.constructionBeam then
        self.constructionBeam:RemoveTarget()
        self:EnableConstructionBeam(false)
    end

    -- clear target reference
    self.reclaimTarget = nil
end


--- Called client-side when the unit has been fully reclaimed
--- Removes all visual client-side elements (tarmac, construction beam, FX)
---@return nil
function ClientUnit:ClientOnReclaimed()
    -- remove construction beam target and disable the beam
    if self.constructionBeam then
        self.constructionBeam:RemoveTarget()
        self:EnableConstructionBeam(false)
    end

    -- clear client-side state flags
    self.isReclaiming = false
    self.reclaimTarget = nil
end


--- Called when the client starts a repair operation on a target unit.
--- @param targetUnitId table Serialized GlobalID data.
--- @return nil
function ClientUnit:ClientOnStartRepair(targetUnitId)
    targetUnitId = table.deepCopy(targetUnitId)

    self.isRepairing = true

    local entity = GetUnitById(targetUnitId)
    if not entity then
        return
    end
    self.repairTarget = entity

    if self.constructionBeam then
        self.constructionBeam:SetTarget(self.repairTarget)
        self:EnableConstructionBeam(true)
    end

    self:NewThread(self.RepairThread)
end

--- Local client thread that updates the repair beam visuals.
--- Runs while repairing remains active.
--- @return nil
function ClientUnit:RepairThread()
    while self.isRepairing do
        -- update beam handling
        if self.constructionBeam then
            self.constructionBeam:Update()
        end
        WaitTicks(1)
    end
end

--- Called when the client stops repairing a target.
--- @return nil
function ClientUnit:ClientOnStopRepair()
    -- clear local repair state
    self.isRepairing = false

    -- remove and disable the construction beam
    if self.constructionBeam then
        self.constructionBeam:RemoveTarget()
        self:EnableConstructionBeam(false)
    end

    if self.repairTarget and self.repairTarget:IsCompleted() and not self.repairTarget.persistentEffectsEnabled then
        self.repairTarget:OnCompleted()
    end

    -- clear target reference
    self.repairTarget = nil
end

--- Called client-side when the unit has been fully repaired
--- Removes all visual client-side repair elements (beam, FX)
---@return nil
function ClientUnit:ClientOnRepaired()

    -- remove repair beam target and disable the beam
    if self.repairBeam then
        self.repairBeam:RemoveTarget()
        self.repairBeam:SetEnabled(false)
    end

    -- clear client-side repair state flags
    self.isRepairing = false
    self.repairTarget = nil
end


--- Called when the client starts a capture operation on a target unit.
--- @param targetUnitId table Serialized GlobalID data.
--- @return nil
function ClientUnit:ClientOnStartCapture(targetUnitId)
    -- resolve target GlobalID into engine format
    targetUnitId = table.deepCopy(targetUnitId)

    -- mark local capture state
    self.isCapturing = true
    self.captureTarget = GetUnitById(targetUnitId)

    -- activate construction beam on the target
    if self.constructionBeam then
        self.constructionBeam:SetTarget(self.captureTarget)
        self:EnableConstructionBeam(true)
    end

    -- start local client-side beam thread
    self:NewThread(self.CaptureThread)
end


--- Local client thread that updates the capture beam visuals.
--- Runs while capturing remains active.
--- @return nil
function ClientUnit:CaptureThread()
    while self.isCapturing do
        -- update beam handling
        if self.constructionBeam then
            self.constructionBeam:Update()
        end
        WaitTicks(1)
    end
end


--- Called when the client stops capturing a target.
--- @return nil
function ClientUnit:ClientOnStopCapture()
    -- clear local capture state
    self.isCapturing = false

    -- remove and disable the construction beam
    if self.constructionBeam then
        self.constructionBeam:RemoveTarget()
        self:EnableConstructionBeam(false)
    end
    -- clear target reference
    self.captureTarget = nil
end

--- Called client-side when this unit has been fully captured.
--- Used to remove visual elements such as construction beam or FX on the old unit.
--- Note: the actual ownership change is handled on the host.
--- @return nil
function ClientUnit:ClientOnCaptured()
    -- remove construction beam target and disable the beam
    if self.constructionBeam then
        self.constructionBeam:RemoveTarget()
        self:EnableConstructionBeam(false)
    end

    -- clear any client-side state flags
    self.isCapturing = false
    self.captureTarget = nil
end


-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0
-- Prowler landed-exhaust lifecycle 1.0.0. The native client has no motion
-- callback, so its existing per-update audio pass supplies the supported speed sample.
local SCO_FaAirFighterClientUnit = ClientUnit
local SCO_ProwlerExhaustSpeedEpsilon = 0.01
local function SCO_IsProwlerExhaustOwner(unit)
    return unit.tpId == "uga1201"
        and unit.tp and unit.tp.additions
        and unit.tp.additions.prowlerExhaustLifecycle == true
end

local SCO_ProwlerStockRecalculatePersistentEffectsState = SCO_FaAirFighterClientUnit.RecalculatePersistentEffectsState
function SCO_FaAirFighterClientUnit:RecalculatePersistentEffectsState()
    if not SCO_IsProwlerExhaustOwner(self) then
        return SCO_ProwlerStockRecalculatePersistentEffectsState(self)
    end
    local enabled = self.persistentEffectsEnabled == true
        and self:IsIntelVisionVisible() == true
        and self.scoProwlerExhaustMoving == true
    self:SetPersistentEffectsState(self.persistentEffects, enabled)
end

local SCO_ProwlerStockUpdateAudio = SCO_FaAirFighterClientUnit.UpdateAudio
function SCO_FaAirFighterClientUnit:UpdateAudio(...)
    local result = SCO_ProwlerStockUpdateAudio(self, ...)
    if not SCO_IsProwlerExhaustOwner(self) then
        return result
    end
    local moving = false
    if not self.dead then
        local _, currentSpeed = Engine.GetMovementCurrentSpeed(self.id)
        moving = type(currentSpeed) == "number"
            and currentSpeed > SCO_ProwlerExhaustSpeedEpsilon
    end
    if self.scoProwlerExhaustMoving ~= moving then
        self.scoProwlerExhaustMoving = moving
        self:RecalculatePersistentEffectsState()
    end
    return result
end
-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0
_G.SCOClientVeterancyPending = _G.SCOClientVeterancyPending or {}

local function SCO_GetClientVeterancyKey(unitID)
    return tostring(unitID.index) .. ":" .. tostring(unitID.version)
end

function ClientUnit:SCOSetVeterancyKills(kills)
    self.scoVeterancyKills = math.max(0, math.floor(kills or 0))
    self:SetUIDirtyIfSelected()
end

local SCO_StockClientUnitInit = ClientUnit.__init
function ClientUnit:__init(...)
    SCO_StockClientUnitInit(self, ...)
    self.scoVeterancyKills = 0

    local key = SCO_GetClientVeterancyKey(self.id)
    local pendingKills = _G.SCOClientVeterancyPending[key]
    if pendingKills ~= nil then
        _G.SCOClientVeterancyPending[key] = nil
        self:SCOSetVeterancyKills(pendingKills)
    end
end

-- Cached Lua resources run in isolated environments, so expose this client
-- handler through the shared global table for common/systems/commands.lua.
_G.SCO_SetClientVeterancyKills = function(unitID, kills)
    local unit = GetUnitById(unitID)
    if unit then
        unit:SCOSetVeterancyKills(kills)
        return
    end

    _G.SCOClientVeterancyPending[SCO_GetClientVeterancyKey(unitID)] = kills
end

-- SCOM commander shield entity-name compatibility 1.0.0

-- Supreme Commander Overhaul 0.0.1.10 Audio Compatibility 1.0.0
-- SetUpEngineAudio became SetUpAudioSources and engineAudioLocalId became
-- motorAudio. UpdateAudio now natively gates motor audio by movement, so the
-- old UEF commander wrapper is intentionally obsolete.
local SCO_AudioCompatStructureIds = {
    ugs1611 = true,
    ugs2611 = true,
    ugs3611 = true,
    ugs2511 = true,
    ugs3511 = true,
    ugs2401 = true,
    ugs1701 = true,
    ugs2701 = true,
    ugs3701 = true,
    ues1511 = true,
    ues2511 = true,
    ues1611 = true,
    ues2611 = true,
    ues3611 = true,
    ues2401 = true,
    ues3401 = true,
    ues1701 = true,
    ues2701 = true,
    ues3701 = true,
    uss1511 = true,
    uss1512 = true,
    uss1611 = true,
    uss1701 = true,
    uss2401 = true,
    uss2511 = true,
    uss2512 = true,
    uss2611 = true,
    uss2701 = true,
    uss2711 = true,
    uss3401 = true,
    uss3511 = true,
    uss3512 = true,
    uss3611 = true,
    uss3701 = true,
}

local SCO_AudioCompatStockSetUpAudioSources = ClientUnit.SetUpAudioSources

local function SCO_AudioCompatDisable(source)
    if source and source.localId then
        Engine.SetAudioSourceCanEmitPersistentSound(source.localId, false)
        source.emitting = false
    end
end

function ClientUnit:SetUpAudioSources()
    SCO_AudioCompatStockSetUpAudioSources(self)

    -- URL0001 has no authored engine source. Disable the inherited donor
    -- source and remove only the motor role so UpdateAudio cannot re-enable it.
    if self.tpId == "ugl0000" then
        SCO_AudioCompatDisable(self.motorAudio)
        self.motorAudio = nil
    end

    if not SCO_AudioCompatStructureIds[self.tpId]
        or not self:HasTags(Tags.STRUCTURE) then
        return
    end

    local audio = self.tp and self.tp.audio
    if audio and audio.active and audio.active.looping then
        SCO_AudioCompatDisable(self.activeAudio)
        self.activeAudio = nil
    end
    if audio and audio.engine and audio.engine.looping then
        SCO_AudioCompatDisable(self.motorAudio)
        self.motorAudio = nil
    end

    for _, shield in ipairs(self.shields or {}) do
        if shield.audio and shield.audio.looping then
            Engine.SetAudioSourceCanEmitPersistentSound(shield.localId, false)
            shield.audio = nil
        end
    end
end
-- SCOM Field Fix: upgrade presentation, team construction color, stock placement previews, team-owned strategic icons, construction cleanup, shared WorkProgress bridge, and FA artillery recoil 1.0.14
local SCO_FieldFixStockClientUnitInit = ClientUnit.__init
local SCO_FieldFixStockSetColor = ClientUnit.SetColor
local SCO_FieldFixStockSetRenderBuildProgress = ClientUnit.SetRenderBuildProgress
local SCO_FieldFixStockOnCompleted = ClientUnit.OnCompleted
local SCO_FieldFixStockOnStartUpgrade = ClientUnit.OnStartUpgrade
local SCO_FieldFixStockOnEndUpgrade = ClientUnit.OnEndUpgrade
local SCO_FieldFixStockOnEndUpgrading = ClientUnit.OnEndUpgrading
local SCO_FieldFixStockOnIntelVision = ClientUnit.OnIntelVision
local SCO_FieldFixStockUpdateProgressBars = ClientUnit.UpdateProgressBars
local SCO_FieldFixStockClientUnitOnDestroy = ClientUnit.OnDestroy
local SCO_FieldFixStockClientUnitOnDelete = ClientUnit.OnDelete
-- Sanctuary build 25474094 removed the stock per-unit render callback.
-- The unitsUpdate appendix below dispatches the SCOM callback each frame.
local SCO_FieldFixStockRenderUpdateBeams = ClientUnit.RenderUpdateBeams or function() end
local SCO_FieldFixStockOnStartBuildRoutine = ClientUnit.OnStartBuildRoutine
local SCO_FieldFixStockClientOnStopBuilding = ClientUnit.ClientOnStopBuilding
local SCO_FieldFixStockClientOnStartReclaim = ClientUnit.ClientOnStartReclaim
local SCO_FieldFixStockClientOnStopReclaim = ClientUnit.ClientOnStopReclaim
local SCO_FieldFixStockClientOnReclaimed = ClientUnit.ClientOnReclaimed
local SCO_FieldFixStockClientOnStartRepair = ClientUnit.ClientOnStartRepair
local SCO_FieldFixStockClientOnStopRepair = ClientUnit.ClientOnStopRepair
local SCO_FieldFixStockClientOnRepaired = ClientUnit.ClientOnRepaired
local SCO_FieldFixStockClientOnStartCapture = ClientUnit.ClientOnStartCapture
local SCO_FieldFixStockClientOnStopCapture = ClientUnit.ClientOnStopCapture
local SCO_FieldFixStockClientOnCaptured = ClientUnit.ClientOnCaptured

local function SCO_FieldFixCopyColor(color)
    if color == nil then return nil end
    return EngineClasses.float4(
        color.x or color[1],
        color.y or color[2],
        color.z or color[3],
        color.w or color[4])
end


local function SCO_FieldFixCurrentTeamColor(unit, fallback)
    if unit.army ~= nil then
        local teamColor = unit.army:GetColor()
        if teamColor ~= nil then return teamColor end
    end
    return fallback
end


local function SCO_FieldFixSetStrategicIconTeamColor(unit, color)
    local icon = unit.icons and unit.icons.StrategicIcon
    if icon == nil then return end

    local teamColor = SCO_FieldFixCurrentTeamColor(unit, color)
    if teamColor == nil then return end
    local iconColor = SCO_FieldFixCopyColor(teamColor)
    if unit:IsPlacementGhost() then
        iconColor.w = PlacementGhostIconAlpha
    elseif not unit:IsCompleted() then
        iconColor.w = InConstructionIconAlpha
    end
    icon:SetColor(iconColor)
end


local function SCO_FieldFixResolveConstructionColor(unit)
    if not unit:HasTags(Tags.STRUCTURE) then return nil end
    return SCO_FieldFixCurrentTeamColor(unit, nil)
end


local function SCO_FieldFixRememberConstructionRestoreColor(unit, fallback)
    local teamColor = SCO_FieldFixCurrentTeamColor(unit, fallback)
    if teamColor ~= nil then
        unit.scoFieldFixConstructionRestoreColor = SCO_FieldFixCopyColor(teamColor)
    end
    return teamColor
end


local function SCO_FieldFixRestoreConstructionColor(unit)
    local restore = SCO_FieldFixCurrentTeamColor(
        unit,
        unit.scoFieldFixConstructionRestoreColor)
    unit.scoFieldFixConstructionPaletteActive = nil
    unit.scoFieldFixConstructionRestoreColor = nil
    if restore ~= nil then
        SCO_FieldFixStockSetColor(unit, restore)
        SCO_FieldFixSetStrategicIconTeamColor(unit, restore)
    end
    return restore
end


local function SCO_FieldFixApplyConstructionColor(unit, fractionComplete)
    -- Placement previews are owned entirely by Sanctuary. SCOM must not write
    -- their renderer color, regardless of the preview color stock selected.
    if unit:IsPlacementGhost() then return end
    local color = SCO_FieldFixResolveConstructionColor(unit)
    if color == nil then return end
    local fraction = math.max(0, math.min(1, fractionComplete or 0))
    if fraction < 1 then
        local teamColor = SCO_FieldFixRememberConstructionRestoreColor(
            unit,
            unit.scoFieldFixConstructionRestoreColor)
        unit.scoFieldFixConstructionPaletteActive = true
        SCO_FieldFixStockSetColor(unit, color)
        SCO_FieldFixSetStrategicIconTeamColor(unit, teamColor)
    elseif unit.scoFieldFixConstructionPaletteActive then
        SCO_FieldFixRestoreConstructionColor(unit)
    end
end


function ClientUnit:SetColor(color)
    if self:IsPlacementGhost() then
        return SCO_FieldFixStockSetColor(self, color)
    end
    local palette = SCO_FieldFixResolveConstructionColor(self)
    local buildTime = self.tp and self.tp.economy and self.tp.economy.buildTime
    local incomplete = type(buildTime) == "number"
        and buildTime > 0
        and type(self.progress) == "number"
        and self.progress < buildTime
    if palette ~= nil
        and (incomplete or self.scoFieldFixConstructionPaletteActive)
    then
        local teamColor = SCO_FieldFixRememberConstructionRestoreColor(self, color)
        self.scoFieldFixConstructionPaletteActive = true
        SCO_FieldFixSetStrategicIconTeamColor(self, teamColor)
        return SCO_FieldFixStockSetColor(self, palette)
    end
    local result = SCO_FieldFixStockSetColor(self, color)
    SCO_FieldFixSetStrategicIconTeamColor(self, color)
    return result
end

local function SCO_FieldFixDisableConstructionBeam(unit)
    local beam = unit.constructionBeam
    if beam ~= nil then
        if type(beam.RemoveTarget) == "function" then beam:RemoveTarget() end
        if type(beam.SetEnabled) == "function" then beam:SetEnabled(false) end
    end
    unit.constructionBeamEnabled = false
end

local function SCO_FieldFixHasProgressBoundUpgrade(unit)
    local additions = unit and unit.tp and unit.tp.additions
    local binding = additions and additions.progressBoundUpgradeAnimation
    return type(binding) == "table"
        and type(binding.animationKey) == "string"
        and type(binding.durationSeconds) == "number"
        and binding.durationSeconds > 0
end

local function SCO_FieldFixIsStructureUpgradePair(target, source)
    return target ~= nil
        and source ~= nil
        and target:HasTags(Tags.STRUCTURE)
        and source:HasTags(Tags.STRUCTURE)
end

local function SCO_FieldFixOwnsUpgradePresentation(target, source)
    return SCO_FieldFixHasProgressBoundUpgrade(source)
        or SCO_FieldFixIsStructureUpgradePair(target, source)
end

local function SCO_FieldFixSetUpgradeVisualHidden(unit)
    Engine.SetRendererEnabled(unit.localId, false)
    if unit.tarmac ~= nil then unit.tarmac:SetEnabled(false) end
    if unit.holes ~= nil and #unit.holes > 0 then
        Engine.SetHolesEnabled(unit.localId, false)
    end
end

local function SCO_FieldFixIsFactoryUpgradeBuild(unit)
    if not unit:HasTags(Tags.FACTORY) or not unit:IsUpgrading() then
        return false
    end
    local upgrade = unit:GetUpgradeTarget()
    return upgrade ~= nil and unit.buildTarget == upgrade
end

local function SCO_FieldFixStopConstructionLifecycle(unit)
    unit.isBuilding = false
    unit.isReclaiming = false
    unit.isRepairing = false
    unit.isCapturing = false
    unit.buildTarget = nil
    unit.reclaimTarget = nil
    unit.repairTarget = nil
    unit.captureTarget = nil
    local beam = unit.constructionBeam
    SCO_FieldFixDisableConstructionBeam(unit)
    local repairBeam = unit.repairBeam
    if repairBeam ~= nil and repairBeam ~= beam then
        if type(repairBeam.RemoveTarget) == "function" then
            repairBeam:RemoveTarget()
        end
        if type(repairBeam.SetEnabled) == "function" then
            repairBeam:SetEnabled(false)
        end
    end
end

local function SCO_FieldFixSetFaArtilleryRecoilBone(bone, offset)
    local result = Engine.SetLocalEntityLocalPosition(
        bone.id,
        EngineClasses.float3(
            bone.rest.x,
            bone.rest.y,
            bone.rest.z + offset))
    if result ~= EngineErrorCode.Success then
        error("Could not write SCOM FA artillery recoil bone "
            .. bone.name, 2)
    end
end

local function SCO_FieldFixResetFaArtilleryRecoil(unit, forget)
    local state = unit.scoFaArtilleryRecoil
    if state ~= nil then
        for _, bone in ipairs(state.bones) do
            if Engine.IsValidLocalID(bone.id) then
                SCO_FieldFixSetFaArtilleryRecoilBone(bone, 0)
            end
        end
        state.startedAt = nil
        state.active = false
    end
    if forget then
        unit.scoFaArtilleryRecoil = nil
    end
end

local function SCO_FieldFixApplyFaArtilleryRecoil(unit, now)
    local state = unit.scoFaArtilleryRecoil
    if state == nil or not state.active or state.startedAt == nil then
        return
    end

    local elapsed = math.max(now - state.startedAt, 0)
    local returnElapsed = math.max(elapsed - state.holdSeconds, 0)
    local returning = elapsed > state.holdSeconds
    local anyActive = false
    for _, bone in ipairs(state.bones) do
        if not Engine.IsValidLocalID(bone.id) then
            error("SCOM FA artillery recoil bone became invalid: "
                .. bone.name, 2)
        end
        local magnitude = math.abs(bone.distance)
        if returning then
            magnitude = math.max(
                magnitude - bone.returnSpeed * returnElapsed,
                0)
        end
        local offset = bone.distance < 0 and -magnitude or magnitude
        SCO_FieldFixSetFaArtilleryRecoilBone(bone, offset)
        anyActive = anyActive or magnitude > 0
    end

    if not anyActive then
        state.startedAt = nil
        state.active = false
    end
end

function SCO_FieldFixStartFaArtilleryRecoil(unit, contract)
    if unit == nil or unit.dead or unit.deleted then
        return
    end
    if type(contract) ~= "table"
        or type(contract.targetId) ~= "string"
        or contract.targetId ~= unit.tpId
        or type(contract.recoil) ~= "table"
        or type(contract.recoilHoldSeconds) ~= "number"
        or contract.recoilHoldSeconds < 0
    then
        error("Invalid SCOM FA artillery client recoil contract for "
            .. tostring(unit.tpId), 2)
    end

    local state = unit.scoFaArtilleryRecoil
    if state == nil then
        state = {
            targetId = contract.targetId,
            holdSeconds = contract.recoilHoldSeconds,
            bones = {},
        }
        local longestReturn = 0
        for _, recoil in ipairs(contract.recoil) do
            if type(recoil.bone) ~= "string"
                or type(recoil.distance) ~= "number"
                or type(recoil.returnSpeed) ~= "number"
                or recoil.returnSpeed <= 0
            then
                error("Invalid SCOM FA artillery recoil-bone contract.", 2)
            end
            local boneId = unit:GetBoneId(recoil.bone)
            if not Engine.IsValidLocalID(boneId) then
                error("Missing SCOM FA artillery recoil bone "
                    .. recoil.bone, 2)
            end
            local rest = EngineClasses.float3()
            local result = Engine.GetLocalEntityLocalPosition(boneId, rest)
            if result ~= EngineErrorCode.Success then
                error("Could not read SCOM FA artillery recoil bone "
                    .. recoil.bone, 2)
            end
            local returnDuration = math.abs(recoil.distance)
                / recoil.returnSpeed
            longestReturn = math.max(longestReturn, returnDuration)
            table.insert(state.bones, {
                id = boneId,
                name = recoil.bone,
                rest = rest,
                distance = recoil.distance,
                returnSpeed = recoil.returnSpeed,
            })
        end
        if #state.bones == 0
            or type(contract.recoilTime) ~= "number"
            or math.abs(longestReturn - contract.recoilTime) > 1e-6
        then
            error("SCOM FA artillery recoil duration drifted for "
                .. contract.targetId, 2)
        end
        unit.scoFaArtilleryRecoil = state
    elseif state.targetId ~= contract.targetId
        or state.holdSeconds ~= contract.recoilHoldSeconds
    then
        error("SCOM FA artillery recoil state ownership drifted for "
            .. contract.targetId, 2)
    end

    state.startedAt = Engine.GetSimulationTime()
    state.active = true
end

function ClientUnit:__init(
    globalId,
    localId,
    armyId,
    template,
    fractionComplete)
    SCO_FieldFixStockClientUnitInit(
        self,
        globalId,
        localId,
        armyId,
        template,
        fractionComplete)
    if not self:IsPlacementGhost() then
        local fraction = math.max(0, math.min(1, fractionComplete or 0))
        SCO_FieldFixStockSetRenderBuildProgress(self, fraction)
        SCO_FieldFixApplyConstructionColor(self, fraction)
    end
    if not self:IsPlacementGhost() then
        local iconTeamColor = self.scoFieldFixConstructionRestoreColor
        if iconTeamColor == nil and self.army ~= nil then
            iconTeamColor = self.army:GetColor()
        end
        SCO_FieldFixSetStrategicIconTeamColor(self, iconTeamColor)
    end
end

function ClientUnit:SetRenderBuildProgress(fractionComplete)
    local result = SCO_FieldFixStockSetRenderBuildProgress(
        self,
        fractionComplete)
    SCO_FieldFixApplyConstructionColor(self, fractionComplete)
    if self.scoFieldFixProgressUpgradeTargetHidden then
        SCO_FieldFixSetUpgradeVisualHidden(self)
    end
    return result
end

function ClientUnit:OnCompleted()
    if self.scoFieldFixConstructionPaletteActive then
        SCO_FieldFixRestoreConstructionColor(self)
    end
    local result = SCO_FieldFixStockOnCompleted(self)
    return result
end

function ClientUnit:OnStartUpgrade(upgrader)
    SCO_FieldFixStockOnStartUpgrade(self, upgrader)
    if SCO_FieldFixOwnsUpgradePresentation(self, upgrader) then
        self.scoFieldFixProgressUpgradeTargetHidden = true
        SCO_FieldFixSetUpgradeVisualHidden(self)
    end
end

function ClientUnit:OnEndUpgrade(upgrader)
    local wasHidden = self.scoFieldFixProgressUpgradeTargetHidden == true
    local completed = wasHidden and self:IsCompleted()
    SCO_FieldFixStockOnEndUpgrade(self, upgrader)
    self.scoFieldFixProgressUpgradeTargetHidden = nil
    if completed then
        self:RecalculateIntel(true)
    end
end

function ClientUnit:OnEndUpgrading(upgrade)
    local retireSource = SCO_FieldFixOwnsUpgradePresentation(upgrade, self)
        and upgrade ~= nil
        and upgrade:IsCompleted()
    SCO_FieldFixStockOnEndUpgrading(self, upgrade)
    if retireSource then
        self.scoFieldFixProgressUpgradeSourceRetiring = true
        SCO_FieldFixSetUpgradeVisualHidden(self)
    end
end

function ClientUnit:OnIntelVision()
    SCO_FieldFixStockOnIntelVision(self)
    if self.scoFieldFixProgressUpgradeTargetHidden
        or self.scoFieldFixProgressUpgradeSourceRetiring
    then
        SCO_FieldFixSetUpgradeVisualHidden(self)
    end
end

function ClientUnit:OnStartBuildRoutine(buildableId)
    local result = SCO_FieldFixStockOnStartBuildRoutine(self, buildableId)
    if self.buildTarget == nil then
        SCO_FieldFixStopConstructionLifecycle(self)
    elseif SCO_FieldFixIsFactoryUpgradeBuild(self) then
        -- The source factory's progress-bound mechanical animation is the
        -- complete upgrade presentation. Lasers add a second visual owner.
        SCO_FieldFixDisableConstructionBeam(self)
    end
    return result
end

function ClientUnit:ClientOnStopBuilding()
    local result = SCO_FieldFixStockClientOnStopBuilding(self)
    SCO_FieldFixStopConstructionLifecycle(self)
    return result
end

function ClientUnit:ClientOnStartReclaim(targetUnitId)
    -- Native lookup failure returns before assigning the new target.
    self.reclaimTarget = nil
    local result = SCO_FieldFixStockClientOnStartReclaim(self, targetUnitId)
    if self.reclaimTarget == nil then SCO_FieldFixStopConstructionLifecycle(self) end
    return result
end

function ClientUnit:ClientOnStopReclaim()
    local result = SCO_FieldFixStockClientOnStopReclaim(self)
    SCO_FieldFixStopConstructionLifecycle(self)
    return result
end

function ClientUnit:ClientOnReclaimed()
    local result = SCO_FieldFixStockClientOnReclaimed(self)
    SCO_FieldFixStopConstructionLifecycle(self)
    return result
end

function ClientUnit:ClientOnStartRepair(targetUnitId)
    -- Native lookup failure returns before assigning the new target.
    self.repairTarget = nil
    local result = SCO_FieldFixStockClientOnStartRepair(self, targetUnitId)
    if self.repairTarget == nil then SCO_FieldFixStopConstructionLifecycle(self) end
    return result
end

function ClientUnit:ClientOnStopRepair()
    local result = SCO_FieldFixStockClientOnStopRepair(self)
    SCO_FieldFixStopConstructionLifecycle(self)
    return result
end

function ClientUnit:ClientOnRepaired()
    local result = SCO_FieldFixStockClientOnRepaired(self)
    SCO_FieldFixStopConstructionLifecycle(self)
    return result
end

function ClientUnit:ClientOnStartCapture(targetUnitId)
    local result = SCO_FieldFixStockClientOnStartCapture(self, targetUnitId)
    if self.captureTarget == nil then SCO_FieldFixStopConstructionLifecycle(self) end
    return result
end

function ClientUnit:ClientOnStopCapture()
    local result = SCO_FieldFixStockClientOnStopCapture(self)
    SCO_FieldFixStopConstructionLifecycle(self)
    return result
end

function ClientUnit:ClientOnCaptured()
    local result = SCO_FieldFixStockClientOnCaptured(self)
    SCO_FieldFixStopConstructionLifecycle(self)
    return result
end

function ClientUnit:OnDestroy(destroyType)
    SCO_ClearGroundFootfalls(self)
    SCO_ClearGroundTracks(self)
    SCO_ClearDamageSmoke(self)
    SCO_FieldFixResetFaArtilleryRecoil(self, true)
    SCO_FieldFixStopConstructionLifecycle(self)
    self.scoFieldFixConstructionPaletteActive = nil
    self.scoFieldFixConstructionRestoreColor = nil
    self.scoFieldFixConstructionColor = nil
    self.scoFieldFixConstructionColorResolved = nil
    return SCO_FieldFixStockClientUnitOnDestroy(self, destroyType)
end

function ClientUnit:OnDelete()
    SCO_ClearGroundFootfalls(self)
    SCO_ClearGroundTracks(self)
    SCO_ClearDamageSmoke(self)
    SCO_FieldFixResetFaArtilleryRecoil(self, true)
    SCO_FieldFixStopConstructionLifecycle(self)
    self.scoFieldFixConstructionPaletteActive = nil
    self.scoFieldFixConstructionRestoreColor = nil
    self.scoFieldFixConstructionColor = nil
    self.scoFieldFixConstructionColorResolved = nil
    return SCO_FieldFixStockClientUnitOnDelete(self)
end

local SCO_FieldFixPlacementBuildMode
local SCO_FieldFixPlacementCursor
local SCO_FieldFixPlacementUtils
local SCO_FieldFixPlacementGuideRadiusSquared = 24 * 24

local function SCO_FieldFixHidePlacementGuide(unit)
    if unit.scoFieldFixPlacementGuideShown then
        Engine.SetRendererEnabled(unit.scoFieldFixPlacementGuideID, false)
        unit.scoFieldFixPlacementGuideShown = nil
    end
end

local function SCO_FieldFixUpdatePlacementGuide(unit)
    local size = unit.tp and unit.tp.skirtSize
    if unit.dead or unit.deleted or unit:IsPlacementGhost() or not unit:IsIntelVisionVisible()
        or unit.scoFieldFixProgressUpgradeTargetHidden
        or unit.scoFieldFixProgressUpgradeSourceRetiring
        or not (unit:HasTags(Tags.STRUCTURE)
            or (Tags.SCFA_FERRYBEACON
                and unit:HasTags(Tags.SCFA_FERRYBEACON)))
        or not size or not size.x or not size.y
        or size.x <= 0 or size.y <= 0
    then
        SCO_FieldFixHidePlacementGuide(unit)
        return
    end
    if not SCO_FieldFixPlacementBuildMode then
        SCO_FieldFixPlacementBuildMode = Import("client/input/buildmodeTemp.lua")
        SCO_FieldFixPlacementCursor = Import("client/input/mouseCursor.lua")
        SCO_FieldFixPlacementUtils = Import("common/systems/placementUtils.lua")
    end
    local underConstruction = not unit:IsCompleted()
    if underConstruction then
        local focusArmyId = GetFocusArmy()
        if focusArmyId == nil or focusArmyId < 0
            or unit.armyId ~= focusArmyId or IsObserver()
        then
            SCO_FieldFixHidePlacementGuide(unit)
            return
        end
    end
    if not underConstruction and (not SCO_FieldFixPlacementBuildMode.GetBuildMode()
        or not SCO_FieldFixPlacementCursor.IsCursorInGameView())
    then
        SCO_FieldFixHidePlacementGuide(unit)
        return
    end
    local position = unit:GetPosition()
    local minX, minZ, maxX, maxZ = SCO_FieldFixPlacementUtils.GetPlacementBounds(
        position, size)
    maxX, maxZ = maxX + 1, maxZ + 1
    if not underConstruction then
        local cursor = SCO_FieldFixPlacementCursor.GetMousePosition()
        local dx = math.max(minX - cursor.x, 0, cursor.x - maxX)
        local dz = math.max(minZ - cursor.z, 0, cursor.z - maxZ)
        if dx * dx + dz * dz > SCO_FieldFixPlacementGuideRadiusSquared then
            SCO_FieldFixHidePlacementGuide(unit)
            return
        end
    end

    local bracketID = unit.scoFieldFixPlacementGuideID
    if not bracketID then
        local errorCode
        errorCode, bracketID = Engine.GetLocalBone(unit.localId, "Construction Bracket")
        if errorCode ~= EngineErrorCode.Success
            or not Engine.IsValidLocalID(bracketID)
        then
            return
        end
        unit.scoFieldFixPlacementGuideID = bracketID
    end

    -- The grid stays world-aligned even when the structure's root is rotated.
    local worldToLocal = math3D.invert(unit:GetOrientation())
    local worldOffset = EngineClasses.float3(
        (minX + maxX) * 0.5 - position.x,
        0.08,
        (minZ + maxZ) * 0.5 - position.z)
    local localOffset = Engine.QuaternionRotateVector(worldToLocal, worldOffset)
    Engine.SetLocalEntityLocalPosition(bracketID, localOffset)
    Engine.SetLocalEntityLocalRotation(bracketID, worldToLocal)
    Engine.SetMeshRendererScale(bracketID,
        EngineClasses.float3(maxX - minX, 1, maxZ - minZ))
    if not unit.scoFieldFixPlacementGuideShown then
        Engine.SetRendererEnabled(bracketID, true)
        unit.scoFieldFixPlacementGuideShown = true
    end
end

-- SCOM measured ground footfalls 1.0.0. Native animation remains the sole pose owner.
do
local SCO_FootfallDecals = Import("client/entities/decal.lua")
local SCO_FootfallLoader = Import("common/loading/decalTemplateLoader.lua")
local SCO_FootfallPrefabs = {}
local SCO_FootfallWarnings = {}
local SCO_FootfallLifetime = 10
local SCO_FootfallInterval = 1 / 30
-- Original DDS alpha bounds, in image coordinates. DDSLoader and the decal
-- shader flip V: image rows run from model +Z toward -Z on the ground.
local SCO_FootfallPrints = {
    ["Environment/SCOM/Footsteps/commander.sandecal"] = {0.625, 0.953125, 0.5, 0.5234375},
    ["Environment/SCOM/Footsteps/colossus_left.sandecal"] = {0.82421875, 0.9609375, 0.533203125, 0.49609375},
    ["Environment/SCOM/Footsteps/colossus_right.sandecal"] = {0.82421875, 0.9609375, 0.466796875, 0.49609375},
    ["Environment/SCOM/Footsteps/contact.sandecal"] = {1, 1, 0.5, 0.5},
}

-- Ythotha inherits a 2300-ms donor step loop. A private native source per
-- contact prevents that loop and its seek action from changing earlier tails.
local SCO_YthothaAudioPrefab
local SCO_YthothaAudioStart
local SCO_YthothaAudioStop

local function SCO_YthothaDeleteVoice(voice)
    if Engine.IsValidLocalID(voice.id) then Engine.DeletePrefabInstance(voice.id) end
end

local function SCO_YthothaClearAudio(self)
    for _, voice in ipairs(self.scoYthothaFootfallVoices or {}) do
        SCO_YthothaDeleteVoice(voice)
    end
    self.scoYthothaFootfallVoices = nil
end

local function SCO_YthothaAudioUpdate(self)
    local voices = self.scoYthothaFootfallVoices
    if not voices then return end
    if self.dead or self.deleted or self.scoCargoCarrierID or self.scoAirStorageHidden
        or not self:IsCompleted() or self:IsPlacementGhost()
        or not self:IsIntelVisionVisible() or not Engine.IsValidLocalID(self.localId) then
        SCO_YthothaClearAudio(self)
        return
    end
    local now = Engine.GetSimulationTime()
    local realtime = Engine.GetCurrentRealtimeInSeconds()
    local finished = Engine.GetAudioSourceFinishedEvents()
    for index = #voices, 1, -1 do
        local voice = voices[index]
        local remove = not Engine.IsValidLocalID(voice.id)
            or now < voice.time or realtime - voice.born > 4.25
        for _, event in ipairs(finished) do
            if event.sourceID.index == voice.id.index and event.sourceID.version == voice.id.version
                and event.eventID.Value == SCO_YthothaAudioStart.Value then
                remove = true
                break
            end
        end
        if not remove and voice.pending then
            -- The preceding native audio update admitted the start. The direct
            -- stop cannot lose budget arbitration: it breaks the step playlist,
            -- preserves its current tail, and fades the machinery over 1000 ms.
            remove = Engine.StopAudioSourceSound(voice.id, SCO_YthothaAudioStop) ~= EngineErrorCode.Success
            voice.pending = nil
        end
        if remove then
            SCO_YthothaDeleteVoice(voice)
            table.remove(voices, index)
        end
    end
end

local function SCO_YthothaPlayContact(self, point, ground, now)
    if self.tpId ~= "usl4004" or not self.tp.additions.scoYthothaContactAudio then return end
    if SCO_YthothaAudioPrefab == false then return end
    if not SCO_YthothaAudioPrefab then
        local categories = Import("client/audio/audioCategories.lua")
        SCO_YthothaAudioStart = categories.TryResolveEventName("aclu1346_start")
        SCO_YthothaAudioStop = categories.TryResolveEventName("aclu1346_stop")
        assert(SCO_YthothaAudioStart and SCO_YthothaAudioStop, "Ythotha contact audio events missing")
        SCO_YthothaAudioPrefab = Import("common/loading/audioPrefabLoader.lua").CreateOneShotAudioPrefab(
            "SCOM_YthothaContactAudio", "aclu1346_start", "unitMotor") or false
        assert(SCO_YthothaAudioPrefab, "Ythotha contact audio prefab unavailable")
    end
    local voices = self.scoYthothaFootfallVoices or {}
    self.scoYthothaFootfallVoices = voices
    -- Three 4-second tails cover the authored gait; accelerated or interrupted
    -- clips retire the oldest voice instead of accumulating native instances.
    if #voices >= 3 then
        SCO_YthothaDeleteVoice(voices[1])
        table.remove(voices, 1)
    end
    local code, id = Engine.InstantiatePrefab(SCO_YthothaAudioPrefab,
        EngineClasses.float3(point.x, ground, point.z), EngineClasses.float3(1, 1, 1), GetIdentityQuaternion())
    if code == EngineErrorCode.Success and Engine.IsValidLocalID(id) then
        voices[#voices + 1] = {id = id, time = now,
            born = Engine.GetCurrentRealtimeInSeconds(), pending = true}
    end
end

local function SCO_YthothaAudioGuard(self, fn, ...)
    if self.scoYthothaFootfallAudioDisabled then return end
    local ok, message = pcall(fn, self, ...)
    if not ok then
        self.scoYthothaFootfallAudioDisabled = true
        pcall(SCO_YthothaClearAudio, self)
        Engine.Warn("SCOM Ythotha contact audio disabled: " .. tostring(message))
    end
end


local function SCO_FootfallFinite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function SCO_FootfallVector(value)
    return type(value) == "table" and SCO_FootfallFinite(value.x)
        and SCO_FootfallFinite(value.y) and SCO_FootfallFinite(value.z)
end

local function SCO_FootfallReset(state, resetClock)
    state.lastMoved = nil
    for _, foot in ipairs(state.feet) do
        foot.raised = false
        foot.audioRaised = false
        foot.clearance = nil
        if resetClock then foot.lastStamp = nil end
    end
end

local function SCO_FootfallInitialize(unit, profile)
    local modelId = unit.tp.general.modelTpId or unit.tpId
    local modelPath = "Units/" .. modelId .. "/LOD0/" .. modelId .. "_lod0.sanmodel"
    if SCO_SourceBodyModel then modelPath = SCO_SourceBodyModel(unit.tp, modelPath) end
    assert(profile.unit == unit.tpId and profile.modelPath == modelPath,
        "SCOM footfall model identity changed: " .. tostring(unit.tpId))
    assert(SCO_FootfallFinite(profile.groundOffset) and math.abs(profile.groundOffset) < 5
        and unit.tp.movement and unit.tp.movement.preferredAltitude == profile.groundOffset,
        "SCOM footfall movement height changed: " .. tostring(unit.tpId))
    assert(profile.referenceAltitude == "Ground" and ReferenceAltitude
        and unit.tp.movement.referenceAltitude == ReferenceAltitude.Ground,
        "SCOM footfall movement reference changed: " .. tostring(unit.tpId))
    assert(type(profile.feet) == "table" and #profile.feet > 0 and #profile.feet <= 16,
        "SCOM footfall contact count changed")
    local feet = {}
    for _, spec in ipairs(profile.feet) do
        assert(type(spec.boneName) == "string" and SCO_FootfallVector(spec.contactOffset)
            and SCO_FootfallVector(spec.forward) and SCO_FootfallVector(spec.right),
            "SCOM footfall contact frame is invalid")
        assert(SCO_FootfallFinite(spec.width) and spec.width > 0 and spec.width < 100
            and SCO_FootfallFinite(spec.length) and spec.length > 0 and spec.length < 100,
            "SCOM footfall dimensions are invalid")
        assert(SCO_FootfallFinite(spec.minimumHeight) and SCO_FootfallFinite(spec.plantHeight)
            and SCO_FootfallFinite(spec.liftHeight) and spec.minimumHeight > -5
            and spec.plantHeight > spec.minimumHeight and spec.liftHeight > spec.plantHeight
            and spec.liftHeight < 5, "SCOM footfall contact thresholds are invalid")
        local path = spec.decalPath or profile.decalPath
        assert(type(path) == "string" and SCO_FootfallPrints[path],
            "SCOM footfall decal identity changed")
        feet[#feet + 1] = {spec = spec, path = path, raised = false,
            matrix = {c0 = {}, c1 = {}, c2 = {}, c3 = {}}}
    end
    return {profile = profile, feet = feet, sampleTime = -math.huge}
end

local function SCO_FootfallPoint(matrix, offset)
    return {
        x = matrix.c3.x + matrix.c0.x * offset.x + matrix.c1.x * offset.y + matrix.c2.x * offset.z,
        y = matrix.c3.y + matrix.c0.y * offset.x + matrix.c1.y * offset.y + matrix.c2.y * offset.z,
        z = matrix.c3.z + matrix.c0.z * offset.x + matrix.c1.z * offset.y + matrix.c2.z * offset.z,
    }
end

local function SCO_FootfallStamp(foot, point, ground, now)
    local matrix, direction = foot.matrix, foot.spec.forward
    local forwardX = matrix.c0.x * direction.x + matrix.c1.x * direction.y + matrix.c2.x * direction.z
    local forwardZ = matrix.c0.z * direction.x + matrix.c1.z * direction.y + matrix.c2.z * direction.z
    if not SCO_FootfallFinite(forwardX) or not SCO_FootfallFinite(forwardZ)
        or forwardX * forwardX + forwardZ * forwardZ < 0.000001 then return end
    local right = foot.spec.right
    local rightX = matrix.c0.x * right.x + matrix.c1.x * right.y + matrix.c2.x * right.z
    local rightZ = matrix.c0.z * right.x + matrix.c1.z * right.y + matrix.c2.z * right.z
    if not SCO_FootfallFinite(rightX) or not SCO_FootfallFinite(rightZ)
        or rightX * rightX + rightZ * rightZ < 0.000001 then return end
    if foot.lastStamp and now - foot.lastStamp < 0.1 then return end
    local prefab = SCO_FootfallPrefabs[foot.path]
    if prefab == false then return end
    if prefab == nil then
        local loaded, value = pcall(SCO_FootfallLoader.CreateDecalPrefab, foot.path)
        if not loaded or not value then
            -- Assets are immutable after startup. A failed optional decal must
            -- neither retry every frame nor interrupt other units' rendering.
            SCO_FootfallPrefabs[foot.path] = false
            Engine.Warn("SCOM footprints disabled for " .. foot.path .. ": "
                .. tostring(loaded and "prefab unavailable" or value))
            return
        end
        prefab = value
        SCO_FootfallPrefabs[foot.path] = prefab
    end
    local forwardScale = math.sqrt(forwardX * forwardX + forwardZ * forwardZ)
    local rightScale = math.sqrt(rightX * rightX + rightZ * rightZ)
    forwardX, forwardZ = forwardX / forwardScale, forwardZ / forwardScale
    local print = SCO_FootfallPrints[foot.path]
    local width = foot.spec.width * rightScale / print[1]
    local length = foot.spec.length * forwardScale / print[2]
    -- Size and center the painted alpha footprint, not its transparent margins.
    -- A yaw-aligned projector has right=(forwardZ,-forwardX) in terrain XZ.
    local across, along = (0.5 - print[3]) * width, (print[4] - 0.5) * length
    local x = point.x + across * forwardZ + along * forwardX
    local z = point.z - across * forwardX + along * forwardZ
    -- Decal local XY become terrain XZ under the native 90-degree projection.
    local depth = math.max(0.1, math.min(width, length))
    SCO_FootfallDecals.CreateDecal(prefab,
        EngineClasses.float3(x, ground, z),
        EngineClasses.float3(width, length, depth),
        math.deg(math.atan2(forwardX, forwardZ)), SCO_FootfallLifetime)
    foot.lastStamp = now
end

local function SCO_FootfallUpdate(self)
    local profile = self.tp and self.tp.additions and self.tp.additions.scoGroundFootfalls
    if not profile then return end
    local state = self.scoGroundFootfallState
    if not state or state.profile ~= profile then
        state = SCO_FootfallInitialize(self, profile)
        self.scoGroundFootfallState = state
    end
    local now = Engine.GetSimulationTime()
    if not SCO_FootfallFinite(now) then return end
    if now >= state.sampleTime and now - state.sampleTime + 0.000001 < SCO_FootfallInterval then return end
    local previousTime = state.sampleTime
    state.sampleTime = now
    if now < previousTime then SCO_FootfallReset(state, true) end
    if self.dead or self.deleted or self.scoCargoCarrierID or self.scoAirStorageHidden
        or not self:IsCompleted() or self:IsPlacementGhost()
        or not self:IsIntelVisionVisible() or not Engine.IsValidLocalID(self.localId) then
        SCO_FootfallReset(state)
        state.position = nil
        return
    end
    local positionCode, position = Engine.GetLocalEntityWorldPosition(self.localId)
    local speedCode, speed = Engine.GetMovementCurrentSpeed(self.id)
    if positionCode ~= EngineErrorCode.Success or not SCO_FootfallVector(position)
        or speedCode ~= EngineErrorCode.Success or not SCO_FootfallFinite(speed) then
        SCO_FootfallReset(state)
        state.position = nil
        return
    end
    local previousPosition = state.position
    state.position = {x = position.x, y = position.y, z = position.z}
    if not previousPosition or now < previousTime or now - previousTime > 0.25 then
        SCO_FootfallReset(state)
        return
    end
    local dx, dz = position.x - previousPosition.x, position.z - previousPosition.z
    local distanceSquared = dx * dx + dz * dz
    local jumpLimit = math.max(2, math.abs(speed) * 0.5)
    if distanceSquared > jumpLimit * jumpLimit then
        SCO_YthothaAudioGuard(self, SCO_YthothaClearAudio)
        SCO_FootfallReset(state)
        return
    end
    if distanceSquared > 0.00000001 then state.lastMoved = now end
    -- Suppress animation fidgets, stationary recoil, cargo and unfinished products.
    if math.abs(speed) <= 0.005 or not state.lastMoved or now - state.lastMoved > 0.15 then
        SCO_FootfallReset(state)
        return
    end
    local waterCode, hasWater = Engine.HasWater()
    if waterCode ~= EngineErrorCode.Success then SCO_FootfallReset(state); return end
    local waterLevel
    if hasWater then
        waterCode, waterLevel = Engine.GetWaterLevel()
        if waterCode ~= EngineErrorCode.Success or not SCO_FootfallFinite(waterLevel) then
            SCO_FootfallReset(state)
            return
        end
    end
    for _, foot in ipairs(state.feet) do
        if not foot.id or not Engine.IsValidLocalID(foot.id) then
            foot.id = self:GetBoneId(foot.spec.boneName)
        end
        local matrixCode = EngineErrorCode.InvalidLocalID
        if foot.id and Engine.IsValidLocalID(foot.id) then
            matrixCode = Engine.GetLocalEntityWorldMatrix(foot.id, foot.matrix)
        end
        local valid = matrixCode == EngineErrorCode.Success
        if valid then
            for _, column in ipairs({foot.matrix.c0, foot.matrix.c1, foot.matrix.c2, foot.matrix.c3}) do
                valid = valid and SCO_FootfallVector(column)
            end
        end
        if valid then
            local point = SCO_FootfallPoint(foot.matrix, foot.spec.contactOffset)
            local groundCode, ground = Engine.SampleTerrainHeight(point)
            if groundCode == EngineErrorCode.Success and SCO_FootfallFinite(ground)
                and (not hasWater or ground >= waterLevel - 0.01) then
                -- Native Ground movement positions the head at
                -- terrain + preferredAltitude. Preserve that authored offset.
                local clearance = point.y - ground - profile.groundOffset
                if self.tpId == "usl4004" then
                    if foot.clearance and clearance >= foot.spec.liftHeight then
                        foot.audioRaised = true
                    elseif foot.audioRaised and clearance <= 0 and foot.clearance
                        and clearance <= foot.clearance and clearance >= foot.spec.minimumHeight then
                        SCO_YthothaAudioGuard(self, SCO_YthothaPlayContact, point, ground, now)
                        foot.audioRaised = false
                    end
                end
                -- One stamp after a real lift and downward return. Independent feet
                -- inherit the actual animation's phase, reverse motion and cadence.
                if foot.clearance and clearance >= foot.spec.liftHeight then
                    foot.raised = true
                elseif foot.raised and clearance <= foot.spec.plantHeight
                    and clearance >= foot.spec.minimumHeight
                    and clearance <= foot.clearance then
                    SCO_FootfallStamp(foot, point, ground, now)
                    foot.raised = false
                end
                foot.clearance = clearance
            else
                foot.raised = false
                foot.audioRaised = false
                foot.clearance = nil
            end
        else
            foot.id = nil
            foot.raised = false
            foot.audioRaised = false
            foot.clearance = nil
        end
    end
end

function SCO_UpdateGroundFootfalls(self)
    SCO_YthothaAudioGuard(self, SCO_YthothaAudioUpdate)
    if self.scoGroundFootfallsDisabled then return end
    local ok, message = pcall(SCO_FootfallUpdate, self)
    if not ok then
        self.scoGroundFootfallsDisabled = true
        self.scoGroundFootfallState = nil
        local unitType = self.tpId or "unknown"
        if not SCO_FootfallWarnings[unitType] then
            SCO_FootfallWarnings[unitType] = true
            Engine.Warn("SCOM footprints disabled for " .. tostring(unitType)
                .. ": " .. tostring(message))
        end
    end
end

function SCO_ClearGroundFootfalls(self)
    SCO_YthothaAudioGuard(self, SCO_YthothaClearAudio)
    self.scoGroundFootfallState = nil
end
end

-- Terrain projectors follow measured contacts; the native decal owns fading/deletion.
do
local Decals = Import("client/entities/decal.lua")
local HierarchyLoader = Import("common/loading/hierarchyTemplateLoader.lua")
local Prefabs, Warnings = {}, {}
local Active, NextSlot = {}, 1
-- 128 marks/tick * 10 ticks/s * 12 seconds = 15360 live marks, plus headroom.
local MaximumMarks, MarksPerTick, Lifetime, SampleInterval = 16384, 128, 12, 0.1
local PeakOpacity, FadeInSeconds, StartImpressions = 0.7, 0.3, 3
local QueueHead, QueueTail, DrainTime
local Prints = {
    tread = {path = "Environment/SCOM/GroundTracks/tread.sandecal", width = 83 / 128, center = 59.5 / 128},
    wheel = {path = "Environment/SCOM/GroundTracks/wheel.sandecal", width = 123 / 128, center = 63.5 / 128},
}

local function finite(n)
    return type(n) == "number" and n == n and math.abs(n) < math.huge
end

local function vector(p)
    return type(p) == "table" and finite(p.x) and finite(p.y) and finite(p.z)
end

local function removeQueued(contact)
    if not contact.queued then return end
    if contact.queuePrevious then contact.queuePrevious.queueNext = contact.queueNext
    else QueueHead = contact.queueNext end
    if contact.queueNext then contact.queueNext.queuePrevious = contact.queuePrevious
    else QueueTail = contact.queuePrevious end
    contact.queued, contact.queuePrevious, contact.queueNext = nil, nil, nil
end

local function enqueue(contact)
    if contact.queued then return end
    contact.queued, contact.queuePrevious = true, QueueTail
    if QueueTail then QueueTail.queueNext = contact else QueueHead = contact end
    QueueTail = contact
end

local function resetContact(contact)
    removeQueued(contact)
    contact.previous, contact.distance, contact.impressions = nil, 0, 0
    contact.pending = {}
end

local function reset(state)
    for _, contact in ipairs(state.contacts) do
        resetContact(contact)
    end
end

local function initialize(unit, profile)
    local model = unit.tp.general.modelTpId or unit.tpId
    local path = "Units/" .. model .. "/LOD0/" .. model .. "_lod0.sanmodel"
    if SCO_SourceBodyModel then path = SCO_SourceBodyModel(unit.tp, path) end
    assert(profile.unit == unit.tpId and profile.modelPath == path
        and profile.boneName == "Root", "ground-track model changed")
    local contacts = {}
    for _, spec in ipairs(profile.trails) do
        assert(Prints[spec.pattern] and finite(spec.width) and spec.width > 0
            and spec.width < 20 and vector(spec.positionOffset), "invalid ground-track contact")
        contacts[#contacts + 1] = {spec = spec, distance = 0, pending = {}, unit = unit}
    end
    assert(#contacts > 0 and #contacts <= 16, "invalid ground-track contact count")
    local state = {profile = profile, contacts = contacts, time = -math.huge,
        matrix = {c0 = {}, c1 = {}, c2 = {}, c3 = {}}}
    for _, contact in ipairs(contacts) do contact.state = state end
    return state
end

local function createPrefab(path)
    -- Embedded assets live in gamedata, not Lua's FilesCache. The two registered
    -- track decals both use fadeFactor=1; native DecalTemplate loads their assets.
    local decal = EngineClasses.DecalTemplate(TemplateHeadEntityName, path,
        EngineClasses.float3(1, 1, 1), 1, true)
    local prefabTemplate = EngineClasses.PrefabTemplate("scom_ground_" .. path:match("([^/]+)%.sandecal$"),
        EngineClasses.HierarchyTemplate(HierarchyLoader.GetHierarchyEntities()),
        EngineClasses.GlobalTemplate(),
        EngineClasses.LocalTemplate(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, {decal}))
    local prefab = {}
    local code = Engine.CreatePrefab(prefabTemplate, prefab)
    assert(code == EngineErrorCode.Success, "ground-track prefab creation failed: " .. tostring(code))
    return prefab
end

local function setTrackOpacity(mark, opacity)
    -- Shape the native lifetime's opacity; retain its single fade/deletion thread.
    local fadeIn = math.min(1, (1 - opacity) * Lifetime / FadeInSeconds)
    fadeIn = fadeIn * fadeIn * (3 - 2 * fadeIn)
    Decals.Decal.SetOpacity(mark, opacity * mark.scoTrackOpacity * fadeIn)
end

local function fadeTrack(mark, seconds)
    -- Keep native lifetime/garbage ownership. Only new marks need 10 Hz fades;
    -- a 0.5-second step changes a mature mark's alpha by less than 0.03.
    local ticks, tick = seconds * 10, 0
    while tick < ticks do
        mark:SetOpacity(1 - tick / ticks)
        local delay = math.min(ticks - tick, tick < 3 and 1 or (5 - tick % 5))
        WaitTicks(delay)
        tick = tick + delay
    end
end

local function stamp(contact, segment)
    local old = Active[NextSlot]
    -- Never reclaim a fresh mark to serve another vehicle. The admission rate
    -- leaves enough capacity for the full lifetime, including one delayed tick.
    if old and not old.deleted then return false end
    local point, ground, dx, dz, scale = segment.point, segment.ground, segment.dx, segment.dz, segment.scale
    local print = Prints[contact.spec.pattern]
    local prefab = Prefabs[print.path]
    if not prefab then
        prefab = createPrefab(print.path)
        Prefabs[print.path] = prefab
    end
    local width = contact.spec.width * scale
    local quadWidth = width / print.width
    -- Stock trail textures run along U. Rotate the projector 90 degrees and
    -- compensate the painted strip's off-center V bounds without editing DDS.
    local shift = (print.center - 0.5) * quadWidth
    local center = EngineClasses.float3(point.x + shift * dz, ground, point.z - shift * dx)
    local length = segment.length * 1.15
    local mark = Decals.CreateDecal(prefab, center,
        EngineClasses.float3(length, quadWidth, math.max(0.35, width + length * 0.5)),
        math.deg(math.atan2(dx, dz)) + 90)
    -- Register before setting up fading so a setter failure cannot orphan it.
    Active[NextSlot] = mark
    NextSlot = NextSlot % MaximumMarks + 1
    contact.impressions = math.min(StartImpressions, (contact.impressions or 0) + 1)
    mark.scoTrackOpacity = PeakOpacity * contact.impressions / StartImpressions
    mark.SetOpacity = setTrackOpacity
    mark.FadeOverTime = fadeTrack
    local ok, message = pcall(function()
        mark:SetOpacity(1)
        mark:SetLifeTime(Lifetime)
    end)
    if not ok then mark:Delete(); error(message) end
    return true
end

local function mergeSegments(a, b, width)
    if math.abs(a.scale - b.scale) > 0.000001 or a.dx * b.dx + a.dz * b.dz < 0.999 then return end
    local x, z = b.point.x - a.point.x, b.point.z - a.point.z
    local along = x * a.dx + z * a.dz
    local gap = along - (a.length + b.length) * 0.5
    local length = along + (a.length + b.length) * 0.5
    -- Compare against the whole span, avoiding chords across gradual turns.
    if along <= 0 or math.abs(x * a.dz - z * a.dx) > math.min(0.08, width * 0.15)
        or math.abs(gap) > b.spacing * 0.25 or length > math.min(12, b.spacing * 8)
        or math.abs(a.ground - b.ground) > 0.15 then return end
    local shift = (length - a.length) * 0.5
    return {point = {x = a.point.x + a.dx * shift, y = b.point.y, z = a.point.z + a.dz * shift},
        ground = (a.ground + b.ground) * 0.5, dx = a.dx, dz = a.dz, scale = b.scale,
        spacing = b.spacing, length = length, time = a.time}
end

local function queueStamp(contact, point, ground, dx, dz, spacing, scale, now)
    local pending = contact.pending
    pending[#pending + 1] = {point = point, ground = ground, dx = dx, dz = dz,
        spacing = spacing, length = spacing, scale = scale, time = now}
    -- Only coalesce a backlog. At ordinary density every original impression
    -- keeps its calibrated length. Under load straight spans retain coverage.
    if pending[1].time < now then
        local i = 1
        while i < #pending do
            local merged = mergeSegments(pending[i], pending[i + 1], contact.spec.width * scale)
            if merged then pending[i] = merged; table.remove(pending, i + 1)
            else i = i + 1 end
        end
    end
    if #pending > 8 then table.remove(pending, 1) end
    enqueue(contact)
end

local function eligible(unit)
    return not (unit.dead or unit.deleted or unit.scoCargoCarrierID or unit.scoAirStorageHidden
        or unit.scoGroundTracksDisabled or not unit:IsCompleted() or unit:IsPlacementGhost()
        or not unit:IsIntelVisionVisible() or not Engine.IsValidLocalID(unit.localId))
end

local function disable(unit, message)
    if unit.scoGroundTrackState then reset(unit.scoGroundTrackState) end
    unit.scoGroundTracksDisabled, unit.scoGroundTrackState = true, nil
    if not Warnings[unit.tpId] then
        Warnings[unit.tpId] = true
        Engine.Warn("SCOM terrain tracks disabled for " .. tostring(unit.tpId) .. ": " .. tostring(message))
    end
end

local function drain(now)
    if DrainTime and now >= DrainTime and now - DrainTime + 0.000001 < SampleInterval then return end
    if DrainTime and now < DrainTime then
        while QueueHead do resetContact(QueueHead) end
        for _, mark in pairs(Active) do if not mark.deleted then mark:Delete() end end
        Active, NextSlot = {}, 1
    end
    DrainTime = now
    -- Intrusive FIFO: one entry per contact, one mark per turn. Both successful
    -- emissions and invalid entries consume budget; no scan or backlog grows
    -- with time. Pending state is removed by unit reset/destruction hooks.
    for _ = 1, MarksPerTick do
        local contact = QueueHead
        if not contact then break end
        removeQueued(contact)
        local ok, emitted = pcall(function()
            local unit = contact.unit
            local state = unit.scoGroundTrackState
            local profile = unit.tp and unit.tp.additions and unit.tp.additions.scoGroundTracks
            if state ~= contact.state or profile ~= state.profile or now < state.time
                or now - state.time > 0.5 or not eligible(unit) then
                resetContact(contact); return true
            end
            if not stamp(contact, contact.pending[1]) then return false end
            table.remove(contact.pending, 1)
            return true
        end)
        if not ok then disable(contact.unit, emitted)
        elseif #contact.pending > 0 then enqueue(contact) end
        if ok and not emitted then break end
    end
end

local function update(unit, profile)
    local state = unit.scoGroundTrackState
    if not state or state.profile ~= profile then
        if state then reset(state) end
        state = initialize(unit, profile)
        unit.scoGroundTrackState = state
    end
    local now = Engine.GetSimulationTime()
    if not finite(now) then return end
    if now >= state.time and now - state.time + 0.000001 < SampleInterval then return end
    local elapsed = now - state.time
    state.time = now
    if elapsed < 0 or elapsed > 0.5 then reset(state) end
    if not eligible(unit) then reset(state); return end
    local waterCode, hasWater = Engine.HasWater()
    if waterCode ~= EngineErrorCode.Success then reset(state); return end
    local waterLevel
    if hasWater then
        waterCode, waterLevel = Engine.GetWaterLevel()
        if waterCode ~= EngineErrorCode.Success or not finite(waterLevel) then reset(state); return end
    end
    if not state.bone or not Engine.IsValidLocalID(state.bone) then
        state.bone = unit:GetBoneId(profile.boneName)
    end
    if not state.bone or not Engine.IsValidLocalID(state.bone)
        or Engine.GetLocalEntityWorldMatrix(state.bone, state.matrix) ~= EngineErrorCode.Success then
        reset(state); return
    end
    local m = state.matrix
    if not vector(m.c0) or not vector(m.c1) or not vector(m.c2) or not vector(m.c3) then
        reset(state); return
    end
    local scale = math.sqrt(m.c0.x * m.c0.x + m.c0.y * m.c0.y + m.c0.z * m.c0.z)
    if not finite(scale) or scale <= 0 or scale > 10 then reset(state); return end
    local code, speed = Engine.GetMovementCurrentSpeed(unit.id)
    if code ~= EngineErrorCode.Success or not finite(speed) then reset(state); return end
    local jumpLimit = math.max(2, math.abs(speed) * math.max(0, elapsed) * 4 + 1)
    local altitude = unit.tp.movement and unit.tp.movement.preferredAltitude or 0
    for _, contact in ipairs(state.contacts) do
        local p = contact.spec.positionOffset
        local point = {x = m.c3.x + m.c0.x * p.x + m.c1.x * p.y + m.c2.x * p.z,
            y = m.c3.y + m.c0.y * p.x + m.c1.y * p.y + m.c2.y * p.z,
            z = m.c3.z + m.c0.z * p.x + m.c1.z * p.y + m.c2.z * p.z}
        local groundCode, ground = Engine.SampleTerrainHeight(point)
        local previous = contact.previous
        contact.previous = point
        local tolerance = math.max(0.35, contact.spec.width * scale)
        if groundCode ~= EngineErrorCode.Success or not finite(ground)
            or (hasWater and ground < waterLevel - 0.01)
            or math.abs(point.y - ground - altitude) > tolerance then
            resetContact(contact)
        elseif previous then
            local dx, dz = point.x - previous.x, point.z - previous.z
            local distance = math.sqrt(dx * dx + dz * dz)
            if distance > jumpLimit then
                resetContact(contact)
                contact.previous = point
            elseif distance > 0.0001 then
                dx, dz = dx / distance, dz / distance
                local spacing = math.max(0.3, math.min(2.4, contact.spec.width * scale * 1.75))
                local nextDistance = spacing - contact.distance
                local count = 0
                while nextDistance <= distance and count < 8 do
                    local at = {x = previous.x + dx * nextDistance,
                        y = point.y, z = previous.z + dz * nextDistance}
                    local result, height = Engine.SampleTerrainHeight(at)
                    if result == EngineErrorCode.Success and finite(height)
                        and (not hasWater or height >= waterLevel - 0.01) then
                        queueStamp(contact, at, height, dx, dz, spacing, scale, now)
                    else
                        -- A water/terrain gap must never be bridged by coalescing.
                        resetContact(contact)
                        contact.previous = point
                    end
                    nextDistance, count = nextDistance + spacing, count + 1
                end
                contact.distance = (contact.distance + distance) % spacing
            end
        end
    end
end

function SCO_UpdateGroundTracks(unit)
    local now = Engine.GetSimulationTime()
    if finite(now) then drain(now) end
    local profile = unit.tp and unit.tp.additions and unit.tp.additions.scoGroundTracks
    if not profile or unit.scoGroundTracksDisabled then return end
    local ok, message = pcall(update, unit, profile)
    if not ok then disable(unit, message) end
end

function SCO_ClearGroundTracks(unit)
    if unit.scoGroundTrackState then reset(unit.scoGroundTrackState) end
    unit.scoGroundTrackState = nil
end
end

function ClientUnit:RenderUpdateBeams(...)
    local result = SCO_FieldFixStockRenderUpdateBeams(self, ...)
    if self.scoFaArtilleryRecoil ~= nil then
        SCO_FieldFixApplyFaArtilleryRecoil(
            self,
            Engine.GetSimulationTime())
    end
    SCO_FieldFixUpdatePlacementGuide(self)
    SCO_UpdateGroundFootfalls(self)
    SCO_UpdateGroundTracks(self)
    SCO_UpdateDamageSmoke(self)
    return result
end

function ClientUnit:UpdateProgressBars(...)
    local result = SCO_FieldFixStockUpdateProgressBars(self, ...)
    local bar = self.constructionProgressBar
    local commanderState = self.scoCommanderEnhancementState
    local commanderActive = type(commanderState) == "table"
        and commanderState.active
    local commanderFraction = type(commanderActive) == "table"
        and commanderActive.fraction
    if bar
        and type(commanderFraction) == "number"
        and commanderFraction == commanderFraction
        and commanderFraction > -math.huge
        and commanderFraction < math.huge
    then
        local progress = math.max(0, math.min(1, commanderFraction))
        bar:SetMaxValue(1)
        bar:SetValue(progress)
        bar:SetEnabled(true)
        -- Keep the health row visible so the upgrade has a stable row beneath it.
        if self.healthProgressBar then
            self.healthProgressBar:SetValue(self:GetHealth())
            self.healthProgressBar:SetEnabled(true)
        end
    else
        local getState = _G.SCO_GetStrategicSiloClientState
        local state = type(getState) == "function" and getState(self)
        if state and state.building and bar then
            local progress = 0
            if type(state.work) == "number"
                and type(state.buildTime) == "number"
                and state.buildTime > 0
            then
                progress = math.max(0, math.min(1, state.work / state.buildTime))
            end
            bar:SetValue(progress)
            bar:SetEnabled(true)
        end
    end
    -- A factory and its unfinished product share the build pad. The product
    -- already owns its health/construction rows; the factory's copy overlaps it.
    local target = self.buildTarget
    local additions = self.tp and self.tp.additions
    if bar and additions and additions.scoFactoryEgress
        and self:IsCompleted() and target and not target.dead
        and target.isIntelVisionVisible and not target:IsPlacementGhost()
        and not target:IsCompleted() and target.constructionProgressBar
    then
        bar:SetEnabled(false)
    end
    return result
end

-- SCOM naval death UI retirement 1.0.0
local function SCO_NavalDeathUiRetired(unit)
    return unit.dead and unit:HasTags(Tags.NAVAL) and not unit:HasTags(Tags.STRUCTURE)
end

local SCO_NavalDeathSetSelectionEnabled = ClientUnit.SetSelectionEnabled
function ClientUnit:SetSelectionEnabled(enabled)
    return SCO_NavalDeathSetSelectionEnabled(self,
        enabled and not SCO_NavalDeathUiRetired(self))
end

local SCO_NavalDeathSetSelectionBracketEnabled = ClientUnit.SetSelectionBracketEnabled
function ClientUnit:SetSelectionBracketEnabled(enabled)
    return SCO_NavalDeathSetSelectionBracketEnabled(self,
        enabled and not SCO_NavalDeathUiRetired(self))
end

local SCO_NavalDeathOnIntelVision = ClientUnit.OnIntelVision
function ClientUnit:OnIntelVision(...)
    local visionResult = SCO_NavalDeathOnIntelVision(self, ...)
    if SCO_NavalDeathUiRetired(self) then
        Engine.SetRangeRingsEnabled(self.localId, false)
    end
    return visionResult
end

-- Three health stages mirror Forged Alliance's 75/50/25 percent damage bands.
-- Critical fires share the same native ownership and suppression rules.
-- Native particle children follow the unit; no temporary prefabs or threads.
do
local Warnings = {}

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function setEnabled(effect, enabled)
    if effect.enabled == enabled then return end
    if Engine.IsValidLocalID(effect.id) then
        local code = Engine.SetParticleCanEmit(effect.id, enabled)
        assert(code == EngineErrorCode.Success, "damage effect emitter toggle failed: " .. tostring(code))
    end
    effect.enabled = enabled
end

local function stop(unit)
    local state = unit.scoDamageSmoke
    if not state then return end
    for _, effect in ipairs(state.effects) do setEnabled(effect, false) end
end

local function update(unit)
    local state = unit.scoDamageSmoke
    if not state then return end
    local allowed = not (unit.dead or unit.deleted or unit.scoCargoCarrierID or unit.scoAirStorageHidden)
        and unit.persistentEffectsEnabled == true and unit:IsCompleted()
        and not unit:IsPlacementGhost() and unit:IsIntelVisionVisible()
        and Engine.IsValidLocalID(unit.localId)
    if not allowed then stop(unit); return end
    local health, maximum = unit:GetHealth(), unit:GetMaxHealth()
    local ratio = finite(health) and finite(maximum) and maximum > 0 and health > 0 and health / maximum or 1
    if ratio >= 0.75 then stop(unit); return end
    local code, hasWater = Engine.HasWater()
    if code ~= EngineErrorCode.Success then stop(unit); return end
    local waterLevel, position
    if hasWater then
        code, waterLevel = Engine.GetWaterLevel()
        if code ~= EngineErrorCode.Success or not finite(waterLevel) then stop(unit); return end
        position = unit:GetPosition()
        if not position or not finite(position.y) then stop(unit); return end
    end
    for _, effect in ipairs(state.effects) do
        setEnabled(effect, ratio < effect.threshold
            and (not hasWater or position.y + effect.height > waterLevel + 0.01))
    end
end

local function warn(unit, message)
    if not Warnings[unit.tpId] then
        Warnings[unit.tpId] = true
        Engine.Warn("SCOM damage effects: " .. tostring(unit.tpId) .. ": " .. tostring(message))
    end
end

local function refresh(unit, force)
    local state = unit.scoDamageSmoke
    if not state then return end
    local now = Engine.GetSimulationTime()
    if not finite(now) then return end
    if not force and now >= state.time and now - state.time < 0.2 then return end
    state.time = now
    local ok, message = pcall(update, unit)
    if not ok then
        -- Stop each child independently so one invalid entity cannot strand others.
        for _, effect in ipairs(state.effects) do pcall(setEnabled, effect, false) end
        warn(unit, message)
    end
end

local previousSetup = ClientUnit.SetUpPersistentEffects
function ClientUnit:SetUpPersistentEffects()
    previousSetup(self)
    local effects = self.tp.visuals and self.tp.visuals.effectsPersistent or {}
    local normal, smoke = {}, {}
    for _, effect in ipairs(effects) do
        if effect.scoDamageSmoke or effect.scoDamageFire then
            local id = self:GetBoneId(effect.effectEntityName)
            if Engine.IsValidLocalID(id) then
                smoke[#smoke + 1] = {id = id, threshold = effect.scoDamageSmoke or effect.scoDamageFire,
                    height = effect.positionOffset.y, enabled = false}
            else
                warn(self, "missing effect entity " .. tostring(effect.effectEntityName))
            end
        else
            normal[#normal + 1] = effect
        end
    end
    if #normal ~= #effects then
        -- Generic exhaust enable/disable must never enable healthy-unit damage effects.
        self.persistentEffects = self:CalculatePersistentEffectIds(normal)
        self.scoDamageSmoke = {effects = smoke, time = -math.huge}
    end
end

function SCO_UpdateDamageSmoke(unit)
    refresh(unit, false)
end

local previousPersistent = ClientUnit.RecalculatePersistentEffectsState
function ClientUnit:RecalculatePersistentEffectsState(...)
    previousPersistent(self, ...)
    refresh(self, true)
end

local previousRadar = ClientUnit.OnIntelRadar
function ClientUnit:OnIntelRadar(...)
    previousRadar(self, ...)
    refresh(self, true)
end

function SCO_ClearDamageSmoke(unit)
    local state = unit.scoDamageSmoke
    if state then
        for _, effect in ipairs(state.effects) do
            local ok, message = pcall(setEnabled, effect, false)
            if not ok then warn(unit, message) end
        end
        unit.scoDamageSmoke = nil
    end
end

end

-- SCOM FA faction construction presentation 1.0.0
do
local SCO_FactionConstructionRenderer = {}
-- Independent presentation roots: never translate the unit, its bones, or its collider.
local constructionPath = "VFX/SCOM/FAConstruction/"
local constructionPrefabs, constructionBounds = {}, {}
local constructionPrefabSerial = 0
local function checked(code, value)
    if code ~= EngineErrorCode.Success then error("construction native error " .. tostring(code)) end
    return value
end
local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < 1e12
end
local function vec(x, y, z) return EngineClasses.float3(x, y, z) end
local function clamp(value, low, high) return math.max(low, math.min(high, value)) end
local function tag(unit, name)
    if unit.tp.hasTags and unit.tp.hasTags[name] then return true end
    for _, value in ipairs(unit.tp.tags or {}) do if value == name then return true end end
    return false
end
local function bounds(path)
    local callbackResult = constructionBounds[path]
    if callbackResult then return callbackResult end
    local code, center, size = Engine.GetMeshBounds(path)
    checked(code)
    for _, key in ipairs({"x", "y", "z"}) do
        if not finite(center[key]) or not finite(size[key]) or size[key] <= 0 then
            error("invalid construction mesh bounds: " .. path)
        end
    end
    callbackResult = {center = center, size = size}
    constructionBounds[path] = callbackResult
    return callbackResult
end
local function readPose(state)
    local position = checked(Engine.GetLocalEntityWorldPosition(state.sourceId))
    local rotation = checked(Engine.GetLocalEntityWorldRotation(state.sourceId))
    local matrix = checked(Engine.GetLocalEntityWorldMatrix(state.sourceId))
    local function length(column)
        local value = math.sqrt(column.x * column.x + column.y * column.y + column.z * column.z)
        if not finite(value) or value <= 0 then error("invalid construction root scale") end
        return value
    end
    state.position, state.rotation = position, rotation
    state.scale = vec(length(matrix.c0), length(matrix.c1), length(matrix.c2))
end
local function offset(state, x, y, z)
    x, y, z = x * state.scale.x, y * state.scale.y, z * state.scale.z
    local q = state.rotation.value
    local tx, ty, tz = 2 * (q.y * z - q.z * y), 2 * (q.z * x - q.x * z), 2 * (q.x * y - q.y * x)
    return vec(state.position.x + x + q.w * tx + q.y * tz - q.z * ty,
        state.position.y + y + q.w * ty + q.z * tx - q.x * tz,
        state.position.z + z + q.w * tz + q.x * ty - q.y * tx)
end
local function prefab(mesh, material, particle, finiteEffect)
    local key = particle or (mesh .. ":" .. material)
    local callbackResult = constructionPrefabs[key]
    if callbackResult then return callbackResult end
    local head = EngineClasses.EntityTemplate(TemplateHeadEntityName, nil, vec(0, 0, 0), 1,
        EngineClasses.quaternion(EngineClasses.float4(0, 0, 0, 1)), false)
    local localTemplate = EngineClasses.LocalTemplate()
    if particle then
        if Engine.LoadEffect(particle) ~= true then error("construction effect load failed: " .. particle) end
        localTemplate.particleTemplates = {
            EngineClasses.ParticleTemplate(TemplateHeadEntityName, particle, finiteEffect, true)}
    else
        localTemplate.meshTemplates = {EngineClasses.MeshTemplate(TemplateHeadEntityName, mesh, material,
            vec(1, 1, 1), ShadowCastingMode.Off, EngineClasses.float4(0, 0, 0, 0),
            EngineClasses.float4(0, 0, 0, 0), false)}
    end
    -- Native names hold only 61 UTF-8 bytes. Keep material-variant paths in
    -- the Lua cache key; each creation attempt gets a short unique native name.
    constructionPrefabSerial = constructionPrefabSerial + 1
    local template = EngineClasses.PrefabTemplate("SCOM_FAC_" .. tostring(constructionPrefabSerial),
        EngineClasses.HierarchyTemplate({head}), EngineClasses.GlobalTemplate(), localTemplate)
    callbackResult = checked(Engine.CreatePrefab(template))
    -- CreatePrefab can return Success with Null (65535), including duplicates.
    -- Never cache that sentinel or pass it to InstantiatePrefab.
    local prefabValue = callbackResult and callbackResult.Value
    if type(prefabValue) ~= "number" or prefabValue < 0 or prefabValue >= 65535
        or prefabValue ~= math.floor(prefabValue) then
        error("construction prefab creation returned an invalid ID")
    end
    constructionPrefabs[key] = callbackResult
    return callbackResult
end
local function instantiate(state, definition, position, scale, rotation)
    local code, id = Engine.InstantiatePrefab(definition, position, scale, rotation)
    -- Even an error with an allocated output must remain owned by cleanup.
    if id and Engine.IsValidLocalID(id) then state.instances[#state.instances + 1] = id end
    checked(code)
    if not id or not Engine.IsValidLocalID(id) then error("construction instance missing") end
    return id
end
local function remove(state, id)
    if Engine.IsValidLocalID(id) then checked(Engine.DeletePrefabInstance(id)) end
    for index, owned in ipairs(state.instances) do
        if owned.index == id.index and owned.version == id.version then
            table.remove(state.instances, index)
            return
        end
    end
end
-- A slice revisits the same small set of fade materials. Keep at most one
-- hidden instance per material instead of rebuilding it for every new layer.
local function releaseMesh(state, part)
    local pool = state.slicePool
    if part.recyclable and not pool[part.material] then
        checked(Engine.SetRendererEnabled(part.id, false))
        pool[part.material] = part
    else
        remove(state, part.id)
    end
end
local function mesh(state, slot, model, material, position, scale, recyclable)
    local previous = state[slot]
    if not previous or previous.material ~= material then
        local pooled = recyclable and state.slicePool[material]
        local id
        if pooled then
            state.slicePool[material] = nil
            id = pooled.id
            checked(Engine.SetLocalEntityLocalPosition(id, position))
            checked(Engine.SetLocalEntityLocalRotation(id, state.rotation))
        else
            id = instantiate(state, prefab(model, material), position, vec(1, 1, 1), state.rotation)
        end
        checked(Engine.SetRendererInstanceData0(id, state.color))
        checked(Engine.SetMeshRendererScale(id, scale))
        if pooled then checked(Engine.SetRendererEnabled(id, true)) end
        state[slot] = {id = id, material = material, recyclable = recyclable}
        if previous then releaseMesh(state, previous) end
    else
        checked(Engine.SetLocalEntityLocalPosition(previous.id, position))
        checked(Engine.SetLocalEntityLocalRotation(previous.id, state.rotation))
        checked(Engine.SetMeshRendererScale(previous.id, scale))
        checked(Engine.SetRendererInstanceData0(previous.id, state.color))
    end
    return state[slot]
end
local function discard(state, slot)
    if state[slot] then releaseMesh(state, state[slot]); state[slot] = nil end
end
local function normalizedMesh(state, slot, model, material, x, y, z, width, height, depth, recyclable)
    local shape = bounds(model)
    local sx, sy, sz = width / shape.size.x, height / shape.size.y, depth / shape.size.z
    local lowY = shape.center.y - shape.size.y * .5
    return mesh(state, slot, model, material,
        offset(state, x - shape.center.x * sx, y - lowY * sy, z - shape.center.z * sz),
        vec(sx * state.scale.x, sy * state.scale.y, sz * state.scale.z), recyclable)
end
local function stepMaterial(path, index)
    return constructionPath .. path .. string.format("%02d", index) .. ".sanmaterial"
end
local function clock(state)
    local now = Engine.GetSimulationTime()
    if not finite(now) then error("invalid construction clock") end
    now = math.max(now, state.lastTime or now)
    state.lastTime = now
    return now, math.max(0, now - state.epoch)
end
local function uefBuildBody(state, fraction)
    local current = checked(Engine.GetRendererInstanceData1(state.sourceId))
    -- The UEF material route preserves native animation and textures while
    -- displaying FA's full-body construction grid. Cybran owns [2,3].
    local marker = 4 + fraction
    state.uefBuild = true
    if math.abs(current.x - marker) > .000001 then
        current.x = marker
        checked(Engine.SetRendererInstanceData1(state.sourceId, current))
    end
end
local function hideOriginal(state)
    checked(Engine.SetRendererEnabled(state.sourceId, false))
    state.hiddenOriginal = true
end
local function body(state, material, factor, heightOffset)
    state.bodyOffset = heightOffset or 0
    mesh(state, "body", state.model, material, offset(state, 0, heightOffset or 0, 0),
        vec(state.scale.x * factor, state.scale.y * factor, state.scale.z * factor))
end
local function slider(state, unit, now, elapsed, fraction)
    local height = state.height * state.scale.y
    if state.factory and fraction >= .8 then
        -- The lifecycle records this transition even while the unit is in fog.
        -- Recreated render state therefore continues the same source slider.
        state.finishTime = unit.scoFactionConstructionFinishAt or state.finishTime or now
    end
    local remaining = state.finishTime
        and math.max(0, height - math.max(0, state.finishTime - state.epoch) * .05
            - math.max(0, now - state.finishTime) * 2)
        or math.max(0, height - elapsed * .05)
    return remaining / state.scale.y
end
-- Publish the exact rendered cube volume for commander slice-beam contacts.
local function drawBuildCube(state, model, bottom, height)
    local b = state.bounds
    local width, depth = b.size.x * 1.05, b.size.z * 1.05
    normalizedMesh(state, "cube", model, constructionPath .. "UEF/Cube.sanmaterial",
        b.center.x, bottom, b.center.z, width, height, depth)
    local volume = state.cubeBuildVolume or {}
    volume.centerX, volume.centerZ = b.center.x, b.center.z
    volume.bottom, volume.height = bottom, height
    volume.width, volume.depth = width, depth
    state.cubeBuildVolume = volume
end
local function updateCube(state, now, elapsed, fraction)
    local model = constructionPath .. "UEF/Cube.sanmodel"
    local b = state.bounds
    local cubeBase = state.bottom
    if elapsed < .6 then
        -- FA starts with a shallow flash at the foundation before cube rise.
        normalizedMesh(state, "startup", constructionPath .. "UEF/Slice.sanmodel",
            stepMaterial("UEF/Slice", math.floor(clamp((elapsed - .08) / .52, 0, 1) * 7 + .5)),
            b.center.x, cubeBase, b.center.z, b.size.x * 1.05,
            state.height * .2, b.size.z * 1.05, true)
    else
        discard(state, "startup")
    end
    if elapsed < .9 then
        drawBuildCube(state, model,
            cubeBase - state.height * (1 - clamp((elapsed - .1) / .8, 0, 1)), state.height)
        hideOriginal(state)
        return
    end
    uefBuildBody(state, fraction)
    if state.hiddenOriginal then checked(Engine.SetRendererEnabled(state.sourceId, state.wasEnabled)) end
    -- FA removes a slab when it samples progress, rather than shrinking between
    -- samples. Keep the flash brief so old slabs cannot form a floating shell.
    local bucket = math.floor(elapsed / 1.2)
    if fraction < state.sliceProgress then
        -- A corrected/reversed progress sample must not grow the cube through
        -- old slice volumes and leave coincident faces behind.
        for _, layer in ipairs(state.slices) do discard(state, layer.slot) end
        state.slices = {}
        state.sliceBucket, state.sliceProgress = bucket, fraction
    end
    if bucket > state.sliceBucket then
        local previousHeight = math.max(.001, state.height * (1 - state.sliceProgress))
        local nextHeight = math.max(.001, state.height * (1 - fraction))
        local removedHeight = math.max(0, previousHeight - nextHeight)
        state.sliceBucket, state.sliceProgress = bucket, fraction
        if removedHeight > 0 then
            while #state.slices >= 5 do
                local expired = table.remove(state.slices, 1)
                discard(state, expired.slot)
            end
            state.sliceSerial = state.sliceSerial + 1
            state.slices[#state.slices + 1] = {slot = "slice" .. state.sliceSerial,
                born = now, top = nextHeight, height = removedHeight}
        end
    end
    drawBuildCube(state, model, cubeBase,
        math.max(.001, state.height * (1 - state.sliceProgress)))
    for index = #state.slices, 1, -1 do
        local layer = state.slices[index]
        local age = now - layer.born
        if age >= .6 then
            discard(state, layer.slot)
            table.remove(state.slices, index)
        else
            normalizedMesh(state, layer.slot, constructionPath .. "UEF/Slice.sanmodel",
                stepMaterial("UEF/Slice", math.floor(clamp((age - .08) / .52, 0, 1) * 7 + .5)),
                b.center.x, cubeBase + layer.top, b.center.z,
                b.size.x * 1.05, layer.height, b.size.z * 1.05, true)
        end
    end
end
local function factoryPoolAnchorPosition(anchor)
    if anchor.boneId and Engine.IsValidLocalID(anchor.boneId) then
        local status, position = Engine.GetLocalEntityWorldPosition(anchor.boneId)
        if status == EngineErrorCode.Success then
            anchor.position = vec(position.x, position.y, position.z)
            return anchor.position
        end
    end
    if Engine.IsValidLocalID(anchor.rootId) then
        local status, matrix = Engine.GetLocalEntityWorldMatrix(anchor.rootId)
        if status == EngineErrorCode.Success then
            local p = anchor.offset
            anchor.position = vec(
                matrix.c3.x + matrix.c0.x * p.x + matrix.c1.x * p.y + matrix.c2.x * p.z,
                matrix.c3.y + matrix.c0.y * p.x + matrix.c1.y * p.y + matrix.c2.y * p.z,
                matrix.c3.z + matrix.c0.z * p.x + matrix.c1.z * p.y + matrix.c2.z * p.z)
        end
    end
    -- Losing the factory must not move its puddle onto the product's hover height.
    return anchor.position
end
function SCO_FactionConstructionRenderer.AnchorFactoryPool(unit, factory)
    local additions = factory.tp.additions or {}
    local boneName = additions.buildStagingBoneName
    if not boneName and factory.tpId == "ucs2510" then boneName = "Attachpoint" end
    local anchor = {rootId = EngineClasses.LocalID(factory.localId.index, factory.localId.version),
        offset = additions.buildStagingOffset or vec(0, 0, 0)}
    if boneName then
        local ok, boneId = pcall(factory.GetBoneId, factory, boneName)
        if ok and boneId and Engine.IsValidLocalID(boneId) then
            anchor.boneId = EngineClasses.LocalID(boneId.index, boneId.version)
        end
    end
    factoryPoolAnchorPosition(anchor)
    unit.scoFaConstructionFactoryAnchor = anchor
end
local function ambient(state)
    if not state.ambient then
        local footprint = math.max(state.bounds.size.x * state.scale.x, state.bounds.size.z * state.scale.z)
        local size = math.min(20, 1 + footprint * .65 * state.fraction)
        state.ambient = {id = instantiate(state,
            prefab(nil, nil, constructionPath .. "Seraphim/Ambient.sanvfx", false),
            state.position, vec(size, size, size), state.rotation)}
    else
        checked(Engine.SetLocalEntityLocalPosition(state.ambient.id, state.position))
        checked(Engine.SetLocalEntityLocalRotation(state.ambient.id, state.rotation))
    end
end
function SCO_FactionConstructionRenderer.Create(state, unit)
    state.sourceId = EngineClasses.LocalID(unit.localId.index, unit.localId.version)
    state.wasEnabled = checked(Engine.GetRendererEnabled(state.sourceId))
    state.color = checked(Engine.GetRendererInstanceData0(state.sourceId))
    state.tpId = unit.tp.general.tpId
    state.model = "Units/" .. state.tpId .. "/LOD0/" .. state.tpId .. "_lod0.sanmodel"
    state.bounds = bounds(state.model)
    state.bottom = math.max(0, state.bounds.center.y - state.bounds.size.y * .5)
    state.height = math.max(.01, state.bounds.center.y + state.bounds.size.y * .5 - state.bottom)
    state.structure = tag(unit, "STRUCTURE")
    state.cubeEligible = state.faction == "UEF" and (state.structure
        or state.tpId == "uel4511" or state.tpId == "uen4001")
    state.epoch = state.epoch or Engine.GetSimulationTime()
    state.slices, state.sliceSerial, state.slicePool = {}, 0, {}
    local _, elapsed = clock(state)
    -- A new rising cube is full-height until its first sampled slab removal.
    -- An existing construction rediscovered in fog starts at its current size.
    state.sliceBucket = math.floor(elapsed / 1.2)
    state.sliceProgress = elapsed < .9 and 0 or state.fraction
    readPose(state)
    return true
end
function SCO_FactionConstructionRenderer.Update(state, unit, fraction)
    -- UEF mobiles share the build material without the structure's cube rise.
    -- The cube belongs to structures and explicit factory/submarine overrides.
    if state.faction == "UEF" and not state.cubeEligible then
        uefBuildBody(state, fraction)
        return true
    end
    readPose(state)
    state.color = checked(Engine.GetRendererInstanceData0(state.sourceId))
    local now, elapsed = clock(state)
    if state.faction == "UEF" then
        updateCube(state, now, elapsed, fraction)
    elseif state.faction == "Cybran" then
        -- Keep the animated textured body. The native fade route owns only
        -- data1.x in [2,3]; its shader decodes paid progress as x - 2.
        local fade = clamp((fraction - .95) * 20, 0, 1)
        local circuitIndex = math.floor(fade * 7 + .5)
        if circuitIndex >= 7 then
            discard(state, "circuits")
        else
            mesh(state, "circuits", state.model, stepMaterial("Cybran/Circuits", circuitIndex),
                state.position, vec(state.scale.x * 1.002, state.scale.y * 1.002, state.scale.z * 1.002))
        end
        local current = checked(Engine.GetRendererInstanceData1(state.sourceId))
        local marker = 2 + fraction
        state.cybranFade = true
        if math.abs(current.x - marker) > .000001 then
            current.x = marker
            checked(Engine.SetRendererInstanceData1(state.sourceId, current))
        end
    elseif state.faction == "Aeon" then
        local hasPool = state.structure or state.factory
        local rise = hasPool and -slider(state, unit, now, elapsed, fraction) or 0
        body(state, constructionPath .. "Bodies/" .. state.tpId .. ".sanmaterial", math.max(.75, fraction), rise)
        local shrinkTime = state.factory and state.finishTime and math.max(0, now - state.finishTime) or 0
        if hasPool and shrinkTime < .5 then
            local poolPosition = offset(state, state.bounds.center.x, state.factory and -.05 or 0, state.bounds.center.z)
            local anchor = state.factory and unit.scoFaConstructionFactoryAnchor
            local factoryPosition = anchor and factoryPoolAnchorPosition(anchor)
            if factoryPosition then
                -- FA attaches the puddle to the factory's build bone, below its floor.
                poolPosition = vec(factoryPosition.x, factoryPosition.y - .05, factoryPosition.z)
            end
            -- FA scales the authored puddle directly: its roughly 1.54-wide
            -- mesh intentionally extends beyond the body's footprint.
            mesh(state, "pool", constructionPath .. "Aeon/Pool.sanmodel", stepMaterial("Aeon/Pool", 0),
                poolPosition,
                vec(math.max(.001, state.bounds.size.x * state.scale.x - .6 * shrinkTime),
                    math.max(.001, (state.factory and 1 or state.height * 1.5) * state.scale.y - .6 * shrinkTime),
                    math.max(.001, state.bounds.size.z * state.scale.z - .6 * shrinkTime)))
        else discard(state, "pool") end
        hideOriginal(state)
    elseif state.faction == "Seraphim" then
        body(state, constructionPath .. "Bodies/" .. state.tpId .. ".sanmaterial",
            .25 + .75 * fraction,
            state.factory and slider(state, unit, now, elapsed, fraction) or 0)
        -- FA preserves coloured surfaces and uses progress alone for opacity.
        -- This private body owns its marker; the animated source is untouched.
        checked(Engine.SetRendererInstanceData1(state.body.id,
            EngineClasses.float4(6 + fraction, 0, 0, 0)))
        if state.structure or state.factory then ambient(state) end
        hideOriginal(state)
    end
    return true
end
function SCO_FactionConstructionRenderer.BeginCompletion(state, unit)
    if state.faction ~= "Aeon" or not state.structure or state.failed or not state.body
        or not state.bodyOffset or state.bodyOffset >= -.001 then return false end
    state.completionTime = clock(state)
    state.completionDistance = -state.bodyOffset * state.scale.y
    return true
end
function SCO_FactionConstructionRenderer.UpdateCompletion(state, unit)
    readPose(state)
    state.color = checked(Engine.GetRendererInstanceData0(state.sourceId))
    local now = clock(state)
    local elapsed = math.max(0, now - state.completionTime)
    local remaining = math.max(0, state.completionDistance - 2 * elapsed)
    body(state, constructionPath .. "Bodies/" .. state.tpId .. ".sanmaterial", 1,
        -remaining / state.scale.y)
    hideOriginal(state)
    if state.pool and elapsed < .5 then
        mesh(state, "pool", constructionPath .. "Aeon/Pool.sanmodel", stepMaterial("Aeon/Pool", 0),
            offset(state, state.bounds.center.x, 0, state.bounds.center.z),
            vec(math.max(.001, state.bounds.size.x * state.scale.x - .6 * elapsed),
                math.max(.001, state.height * 1.5 * state.scale.y - .6 * elapsed),
                math.max(.001, state.bounds.size.z * state.scale.z - .6 * elapsed)))
    else discard(state, "pool") end
    return remaining <= .001
end
function SCO_FactionConstructionRenderer.Dispose(state, unit, reason)
    state.cubeBuildVolume = nil
    local visible = not unit.dead and not unit.deleted and not unit.scoFactionConstructionRetired
        and unit:IsIntelVisionVisible() == true
        and not unit.scoFieldFixProgressUpgradeTargetHidden
        and not unit.scoFieldFixProgressUpgradeSourceRetiring
    if state.sourceId and Engine.IsValidLocalID(state.sourceId) then
        if state.cybranFade then
            local current = checked(Engine.GetRendererInstanceData1(state.sourceId))
            -- A later native owner may already have cleared the marker.
            if current.x >= 2 and current.x <= 3 then
                current.x = reason == "completed" and 0 or 1 - clamp(state.fraction, 0, 1)
                checked(Engine.SetRendererInstanceData1(state.sourceId, current))
            end
            state.cybranFade = nil
        end
        if state.uefBuild then
            local current = checked(Engine.GetRendererInstanceData1(state.sourceId))
            if current.x >= 4 and current.x <= 5 then
                current.x = reason == "completed" and 0 or 1 - clamp(state.fraction, 0, 1)
                checked(Engine.SetRendererInstanceData1(state.sourceId, current))
            end
            state.uefBuild = nil
        end
        if state.hiddenOriginal and visible then
            checked(Engine.SetRendererEnabled(state.sourceId, state.wasEnabled))
        end
    end
    if reason == "completed" and state.faction == "Seraphim" and not state.failed
        and visible and state.position and (state.structure or state.factory) then
        -- The finite particle owns its native destruction after this state is
        -- gone. No detached Lua task, timer, or unit callback survives cleanup.
        local definition = prefab(nil, nil, constructionPath .. "Seraphim/Completed.sanvfx", true)
        local width = math.max(state.bounds.size.x * state.scale.x, state.bounds.size.z * state.scale.z)
        local size = clamp(width, .1, 20)
        local code, id = Engine.InstantiatePrefab(definition, state.position, vec(size, size, size), state.rotation)
        if code ~= EngineErrorCode.Success then
            if id and Engine.IsValidLocalID(id) then state.instances[#state.instances + 1] = id end
            checked(code)
        end
    end
end


local factionTags = {
    {"SCFA_UEF", "UEF"}, {"SCFA_CYBRAN", "Cybran"},
    {"SCFA_AEON", "Aeon"}, {"SCFA_SERAPHIM", "Seraphim"},
}

local function hasTag(tp, name)
    if tp.hasTags and tp.hasTags[name] then return true end
    for _, tag in ipairs(tp.tags or {}) do
        if tag == name then return true end
    end
    return false
end

local function faction(unit)
    local tp = unit.tp
    local id = tp and tp.general and tp.general.tpId
    -- Current SCOM source roster uses these seven-character IDs. Wyvern can
    -- inherit SCFA tags; its w* IDs and SC2R's sc2r_* IDs are separate owners.
    if type(id) ~= "string" or not id:match("^u[ecgs][alns]%d%d%d%d$")
        or not hasTag(tp, "SCFA_ALLUNITS") then return nil end
    local special = tp.additions and tp.additions.scoSpecial
    -- Split bodies have separately animated shell renderers. Leave their
    -- existing construction presentation intact until the copies include them.
    if special and special.splitMesh then return nil end
    local callbackResult
    for _, row in ipairs(factionTags) do
        if hasTag(tp, row[1]) then
            if callbackResult then return nil end
            callbackResult = row[2]
        end
    end
    return callbackResult
end

local function identity(unit)
    local globalId, localId = unit.id, unit.localId
    if not globalId or not localId or not Engine.IsValidLocalID(localId) then return nil end
    return table.concat({tostring(globalId.index), tostring(globalId.version),
        tostring(localId.index), tostring(localId.version), tostring(unit.armyId),
        tostring(unit.tp and unit.tp.general and unit.tp.general.tpId)}, ":")
end

local function report(unit, key, message)
    if unit.scoFactionConstructionReported == key then return end
    unit.scoFactionConstructionReported = key
    pcall(Engine.Error, "SCOM faction construction presentation stopped for "
        .. tostring(unit.tpId) .. ": " .. tostring(message))
end

local function dispose(unit, reason, keepFailure)
    local state = unit.scoFactionConstruction
    if not state then return end
    if SCO_FactionConstructionRenderer.Dispose then
        local ok, message = pcall(SCO_FactionConstructionRenderer.Dispose, state, unit, reason)
        if not ok then report(unit, state.identity, message) end
    end
    for _, id in ipairs(state.instances) do
        if Engine.IsValidLocalID(id) then
            local ok, code = pcall(Engine.DeletePrefabInstance, id)
            if not ok or code ~= EngineErrorCode.Success then
                report(unit, state.identity, "temporary prefab cleanup failed")
            end
        end
    end
    state.instances = {}
    if keepFailure then
        state.failed = true
    else
        unit.scoFactionConstruction = nil
    end
end

local function clearCompletionMetadata(unit)
    unit.scoFaConstructionFactory = nil
    unit.scoFaConstructionFactoryAnchor = nil
    unit.scoFactionConstructionStartedAt = nil
    unit.scoFactionConstructionFinishAt = nil
end

local function complete(unit)
    local state = unit.scoFactionConstruction
    if state and state.identity ~= identity(unit) then
        dispose(unit, "identity")
        clearCompletionMetadata(unit)
        return
    end
    if state and state.completing then return end
    if state and state.faction == "Aeon" and not state.factory and not state.failed
        and not unit.dead and not unit.deleted and not unit.scoFactionConstructionRetired
        and unit:IsIntelVisionVisible() == true and not unit:IsUpgrade() and not unit:IsUpgrading()
        and not unit.scoFieldFixProgressUpgradeTargetHidden
        and not unit.scoFieldFixProgressUpgradeSourceRetiring
        and SCO_FactionConstructionRenderer.BeginCompletion then
        local ok, retained = pcall(SCO_FactionConstructionRenderer.BeginCompletion, state, unit)
        if not ok then
            report(unit, state.identity, retained)
            dispose(unit, "failure")
            clearCompletionMetadata(unit)
            return
        end
        if retained == true then
            state.completing = true
            return
        end
    end
    dispose(unit, "completed")
    clearCompletionMetadata(unit)
end

local function update(unit, fractionComplete)
    local state = unit.scoFactionConstruction
    -- The existing render callback visits the whole army. Finished units with
    -- no owned effect must not allocate identity keys or cross native APIs.
    if not state and (unit.scoFactionConstructionRetired or unit.dead or unit.deleted
        or unit.isInitialized == false or unit:IsPlacementGhost() or unit:IsCompleted()) then
        return
    end
    local currentIdentity = identity(unit)
    if currentIdentity and unit.scoFactionConstructionEpochIdentity ~= currentIdentity then
        unit.scoFactionConstructionEpochIdentity = currentIdentity
        unit.scoFactionConstructionStartedAt = nil
        unit.scoFactionConstructionFinishAt = nil
    end
    if state and state.identity ~= currentIdentity then
        dispose(unit, "identity")
        state = nil
    end
    local selected = faction(unit)
    local fraction = fractionComplete
    if fraction == nil and selected and currentIdentity and unit.isInitialized ~= false then
        fraction = unit:GetFractionComplete()
    end
    local paidIncomplete = type(fraction) == "number" and fraction == fraction
        and fraction > 0 and fraction < 1
    if selected and currentIdentity and paidIncomplete and not unit:IsPlacementGhost()
        and not unit.dead and not unit.deleted and unit.isInitialized ~= false
        and unit.scoFactionConstructionStartedAt == nil then
        -- Record progress received in fog as well, without creating visuals.
        unit.scoFactionConstructionStartedAt = Engine.GetSimulationTime()
    end
    if selected and currentIdentity and paidIncomplete and fraction >= .8
        and unit.scoFaConstructionFactory == true and not unit.dead and not unit.deleted
        and not unit:IsPlacementGhost() and unit.isInitialized ~= false
        and unit.scoFactionConstructionFinishAt == nil then
        -- Keep the source factory's final fast slide through fog transitions.
        unit.scoFactionConstructionFinishAt = Engine.GetSimulationTime()
    end
    if not selected or not currentIdentity or unit.scoFactionConstructionRetired
        or unit.dead or unit.deleted or unit.isInitialized == false
        or unit:IsPlacementGhost() or unit:IsUpgrade() or unit:IsUpgrading()
        or unit.scoFieldFixProgressUpgradeTargetHidden
        or unit.scoFieldFixProgressUpgradeSourceRetiring
        or unit:IsIntelVisionVisible() ~= true then
        dispose(unit, "ineligible")
        if unit:IsCompleted() then clearCompletionMetadata(unit) end
        return
    end
    if unit:IsCompleted() then
        complete(unit)
        state = unit.scoFactionConstruction
    end
    if state and state.completing then
        local ok, done = pcall(SCO_FactionConstructionRenderer.UpdateCompletion, state, unit)
        if not ok then
            report(unit, state.identity, done)
            dispose(unit, "failure")
            clearCompletionMetadata(unit)
        elseif done == true then
            dispose(unit, "handoff")
            clearCompletionMetadata(unit)
        end
        return
    end
    if unit:IsCompleted() then return end
    if not paidIncomplete then
        dispose(unit, "progress")
        return
    end
    if state and (state.faction ~= selected
        or state.factory ~= (unit.scoFaConstructionFactory == true)) then
        dispose(unit, "presentation")
        state = nil
    end
    if state and state.failed then return end
    if not state then
        -- Fog discards local instances, not the construction's visual epoch.
        -- A returning observer must not restart source startup effects.
        state = {identity = currentIdentity, faction = selected, instances = {}, fraction = fraction,
            factory = unit.scoFaConstructionFactory == true, epoch = unit.scoFactionConstructionStartedAt}
        unit.scoFactionConstruction = state
        local ok, created = pcall(SCO_FactionConstructionRenderer.Create, state, unit)
        if not ok or created ~= true then
            report(unit, currentIdentity, ok and "temporary prefab creation failed" or created)
            dispose(unit, "failure", true)
            return
        end
    end
    state.fraction = fraction
    local ok, callbackResult = pcall(SCO_FactionConstructionRenderer.Update, state, unit, fraction)
    if not ok or callbackResult == false then
        report(unit, currentIdentity, ok and "temporary prefab update failed" or callbackResult)
        dispose(unit, "failure", true)
    end
end

local previousInit = ClientUnit.__init
ClientUnit.__init = function(self, ...)
    local callbackResult = previousInit(self, ...)
    update(self)
    return callbackResult
end

local previousProgress = ClientUnit.SetRenderBuildProgress
ClientUnit.SetRenderBuildProgress = function(self, fractionComplete)
    local callbackResult = previousProgress(self, fractionComplete)
    update(self, fractionComplete)
    return callbackResult
end

local previousRender = ClientUnit.RenderUpdateBeams
ClientUnit.RenderUpdateBeams = function(self, ...)
    local callbackResult = previousRender(self, ...)
    update(self)
    return callbackResult
end

local previousStartBuild = ClientUnit.OnStartBuildRoutine
ClientUnit.OnStartBuildRoutine = function(self, ...)
    local callbackResult = previousStartBuild(self, ...)
    local target = self.buildTarget
    if faction(self) and hasTag(self.tp, "FACTORY") and target and faction(target)
        and not self:IsUpgrading() and not target:IsUpgrade() then
        -- Remember origin on the target, not the assisting engineer. Factory
        -- stop/death and later assistance must not change the build-in style.
        target.scoFaConstructionFactory = true
        if faction(target) == "Aeon" then
            SCO_FactionConstructionRenderer.AnchorFactoryPool(target, self)
        end
        update(target)
    end
    return callbackResult
end

local previousCompleted = ClientUnit.OnCompleted
ClientUnit.OnCompleted = function(self, ...)
    complete(self)
    return previousCompleted(self, ...)
end

local previousVision = ClientUnit.OnIntelVision
ClientUnit.OnIntelVision = function(self, ...)
    local callbackResult = previousVision(self, ...)
    update(self)
    return callbackResult
end

for _, name in ipairs({"OnIntelHidden", "OnIntelRadar", "OnIntelSonar"}) do
    local previous = ClientUnit[name]
    ClientUnit[name] = function(self, ...)
        dispose(self, "intel")
        if self:IsCompleted() then clearCompletionMetadata(self) end
        return previous(self, ...)
    end
end

for _, name in ipairs({"OnStartUpgrade", "OnEndUpgrade", "OnStartUpgrading", "OnEndUpgrading"}) do
    local previous = ClientUnit[name]
    ClientUnit[name] = function(self, ...)
        local callbackResult = previous(self, ...)
        update(self)
        return callbackResult
    end
end

local previousCaptured = ClientUnit.ClientOnCaptured
ClientUnit.ClientOnCaptured = function(self, ...)
    -- This callback also ends a builder's capture work; it does not prove
    -- that this unit was replaced. ID/version/army changes own replacement.
    dispose(self, "capture")
    return previousCaptured(self, ...)
end

for _, name in ipairs({"OnDestroy", "OnDelete"}) do
    local previous = ClientUnit[name]
    ClientUnit[name] = function(self, ...)
        self.scoFactionConstructionRetired = true
        dispose(self, name)
        self.scoFaConstructionFactory = nil
        self.scoFaConstructionFactoryAnchor = nil
        self.scoFactionConstructionStartedAt = nil
        self.scoFactionConstructionFinishAt = nil
        return previous(self, ...)
    end
end
end

local SCO_ConstructionTargets
local SCO_ConstructionContact = Import("client/entities/scoConstructionContact.lua")
function ClientUnit:SCO_GetConstructionTargetPosition(origin, hopState, builder)
    if not SCO_ConstructionTargets then
        SCO_ConstructionTargets = Import("common/systems/scoConstructionTarget.lua")
    end
    return SCO_ConstructionTargets.GetPosition(self, origin, hopState, builder)
end

-- Bind the existing visual controllers at the accepted-work callback boundary.
-- Factory classes prepare their loose roots before delegating to these methods.
local function SCO_BindConstructionBeamOwner(controller, owner)
    if not controller then return end
    if controller.scoConstructionBuilder ~= owner then
        controller.scoConstructionHop = nil
        SCO_ConstructionContact.ClearTree(controller)
    end
    controller.scoConstructionBuilder = owner
    if controller.beams then
        for _, state in ipairs(controller.beams) do
            if state.beam then SCO_BindConstructionBeamOwner(state.beam, owner) end
        end
    end
    if controller.stockBeam then SCO_BindConstructionBeamOwner(controller.stockBeam, owner) end
end

local SCO_HopStartBuild = ClientUnit.OnStartBuildRoutine
function ClientUnit:OnStartBuildRoutine(buildableId)
    SCO_BindConstructionBeamOwner(self.constructionBeam, self)
    return SCO_HopStartBuild(self, buildableId)
end

local SCO_HopStartRepair = ClientUnit.ClientOnStartRepair
function ClientUnit:ClientOnStartRepair(targetId)
    SCO_BindConstructionBeamOwner(self.constructionBeam, self)
    return SCO_HopStartRepair(self, targetId)
end

local SCO_HopStopBuild = ClientUnit.ClientOnStopBuilding
function ClientUnit:ClientOnStopBuilding()
    SCO_BindConstructionBeamOwner(self.constructionBeam, nil)
    return SCO_HopStopBuild(self)
end

local SCO_HopStopRepair = ClientUnit.ClientOnStopRepair
function ClientUnit:ClientOnStopRepair()
    SCO_BindConstructionBeamOwner(self.constructionBeam, nil)
    return SCO_HopStopRepair(self)
end

local SCO_HopStartReclaim = ClientUnit.ClientOnStartReclaim
function ClientUnit:ClientOnStartReclaim(targetId)
    SCO_BindConstructionBeamOwner(self.constructionBeam, nil)
    return SCO_HopStartReclaim(self, targetId)
end

local SCO_HopStartCapture = ClientUnit.ClientOnStartCapture
function ClientUnit:ClientOnStartCapture(targetId)
    SCO_BindConstructionBeamOwner(self.constructionBeam, nil)
    return SCO_HopStartCapture(self, targetId)
end

-- Client-only URA0001 cosmetics. The stock beam still owns construction work.
local SCO_CybranDroneCounts = {
    ugl0000 = 5, ugl5004 = 3, ugl1501 = 1, ugl2501 = 2, ugl3501 = 3,
    ugl1002 = 1, ugs2501 = 1, ugs5026 = 2, ugs3501 = 3,
}
local SCO_CybranDroneAssets = "VFX/SCOM/CybranBuildDrones/"
local SCO_CybranDronePrefabID
local SCO_CybranDronePrefabFailed = false
-- Source Muzzle01/02: one independent construction beam from each U-shaped tip.
local SCO_CybranDroneTips = {
    EngineClasses.float3(0.030318549819102057, 0.014646331338563775, 0.09672103778084387),
    EngineClasses.float3(-0.03031496315658866, 0.01464632088439643, 0.09672103497740887),
}
local SCO_CybranDroneBeamWidth = 0.008
-- The static URA0001 mesh fits a .102504 sphere about its origin in every pose.
local SCO_CybranDroneRadius = 0.11
local SCO_CybranDroneSeparation = 2 * SCO_CybranDroneRadius + 0.04
local SCO_CybranDroneCellSize = 0.30
local SCO_CybranDroneColumns = {}
local SCO_CybranDroneGroup = {}
SCO_CybranDroneGroup.__index = SCO_CybranDroneGroup

local function SCO_DroneValid(id)
    return id ~= nil and Engine.IsValidLocalID(id)
end

local function SCO_DroneAlive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
        and SCO_DroneValid(unit.localId)
end

local function SCO_DroneRandom(group)
    -- Private visual state: never consume the shared Lua RNG or host state.
    group.randomSeed = group.randomSeed * 48271 % 2147483647
    return group.randomSeed / 2147483647
end

local function SCO_DroneCount(unit)
    return SCO_CybranDroneCounts[unit.tpId]
end

local function SCO_DroneClearPosition(drone)
    local key = drone.columnKey
    if key then
        local column = SCO_CybranDroneColumns[key]
        column[drone] = nil
        if next(column) == nil then SCO_CybranDroneColumns[key] = nil end
    end
    drone.columnKey, drone.position = nil, nil
end

local function SCO_DronePlace(drone, position)
    local cellX = math.floor(position.x / SCO_CybranDroneCellSize)
    local cellZ = math.floor(position.z / SCO_CybranDroneCellSize)
    -- Nearby columns include other builders working on this or adjacent targets.
    for x = cellX - 1, cellX + 1 do
        for z = cellZ - 1, cellZ + 1 do
            local column = SCO_CybranDroneColumns[x .. ":" .. z]
            if column then
                for other in pairs(column) do
                    if other ~= drone then
                        local p = other.position
                        if (position.x - p.x)^2 + (position.y - p.y)^2
                            + (position.z - p.z)^2 < SCO_CybranDroneSeparation^2 then
                            return false
                        end
                    end
                end
            end
        end
    end
    SCO_DroneClearPosition(drone)
    local key = cellX .. ":" .. cellZ
    local column = SCO_CybranDroneColumns[key] or {}
    SCO_CybranDroneColumns[key] = column
    column[drone], drone.columnKey = true, key
    drone.position = position
    return true
end

local function SCO_DroneFinite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function SCO_DroneTerrainFloor(position, waterLevel)
    local highest = waterLevel
    -- Bilinear terrain reaches its maximum at each clipped rectangle's corners.
    -- Endpoints plus interior grid lines cover the whole sphere's XZ footprint
    -- without sampling remote cell vertices that cause abrupt height changes.
    local minX, maxX = position.x - SCO_CybranDroneRadius, position.x + SCO_CybranDroneRadius
    local minZ, maxZ = position.z - SCO_CybranDroneRadius, position.z + SCO_CybranDroneRadius
    local xs, zs = {minX, maxX}, {minZ, maxZ}
    for x = math.floor(minX) + 1, math.ceil(maxX) - 1 do xs[#xs + 1] = x end
    for z = math.floor(minZ) + 1, math.ceil(maxZ) - 1 do zs[#zs + 1] = z end
    for _, x in ipairs(xs) do
        for _, z in ipairs(zs) do
            local status, height = Engine.SampleTerrainHeight(EngineClasses.float3(x, 0, z))
            if status ~= EngineErrorCode.Success or not SCO_DroneFinite(height) then return nil end
            highest = math.max(highest, height)
        end
    end
    return highest + SCO_CybranDroneRadius + 0.05
end

local function SCO_DroneHide(drone)
    for _, contact in ipairs(drone.contacts or {}) do SCO_ConstructionContact.Clear(contact) end
    SCO_DroneClearPosition(drone)
    if SCO_DroneValid(drone.rootId) then Engine.SetRendererEnabled(drone.rootId, false) end
    for _, id in ipairs(drone.beamIds) do
        if SCO_DroneValid(id) then Engine.SetRendererEnabled(id, false) end
    end
end

local function SCO_DroneStock(group, method, ...)
    local stock = group.stockBeam
    if stock and type(stock[method]) == "function" then
        return stock[method](stock, ...)
    end
end

local function SCO_DroneAddBeam(prefab, name, position, rotation, shrink, length)
    table.insert(prefab.hierarchyTemplate.entities, EngineClasses.EntityTemplate(
        name, TemplateHeadEntityName, position, 1, rotation, false))
    table.insert(prefab.localTemplate.meshTemplates, EngineClasses.MeshTemplate(
        name, "VFX/Models/Static/ConstructionBeam.sanmodel",
        SCO_CybranDroneAssets .. "build_beam.sanmaterial",
        EngineClasses.float3(shrink, 1, length), ShadowCastingMode.Off,
        EngineClasses.float4(), EngineClasses.float4(), true))
end

local function SCO_DroneGetPrefab()
    if SCO_CybranDronePrefabID or SCO_CybranDronePrefabFailed then
        return SCO_CybranDronePrefabID
    end
    -- No health, movement, collision, animation, rotator, or global components.
    local prefab = EngineClasses.PrefabTemplate("SCOM_CybranBuildDrone_URA0001")
    table.insert(prefab.hierarchyTemplate.entities, EngineClasses.EntityTemplate(
        TemplateHeadEntityName, nil, EngineClasses.float3(), 1,
        GetIdentityQuaternion(), false))
    table.insert(prefab.localTemplate.meshTemplates, EngineClasses.MeshTemplate(
        TemplateHeadEntityName, SCO_CybranDroneAssets .. "ura0001.sanmodel",
        SCO_CybranDroneAssets .. "ura0001.sanmaterial", EngineClasses.float3(1, 1, 1),
        ShadowCastingMode.Off, EngineClasses.float4(1, 1, 1, 1),
        EngineClasses.float4(0, 0, 0, 0), true))

    for index, tip in ipairs(SCO_CybranDroneTips) do
        SCO_DroneAddBeam(prefab, "Drone Tip Beam " .. index, tip,
            GetIdentityQuaternion(), SCO_CybranDroneBeamWidth, 1)
    end
    local status, id = Engine.CreatePrefab(prefab)
    if status ~= EngineErrorCode.Success or id == nil then
        SCO_CybranDronePrefabFailed = true
        Engine.Error("SCOM Cybran build-drone prefab could not be created; stock beam retained.")
        return nil
    end
    SCO_CybranDronePrefabID = id
    return id
end

function SCO_CybranDroneGroup:ClearInstances()
    for _, drone in ipairs(self.drones) do
        for _, contact in ipairs(drone.contacts or {}) do SCO_ConstructionContact.Clear(contact) end
        SCO_DroneClearPosition(drone)
        if SCO_DroneValid(drone.rootId) then Engine.DeletePrefabInstance(drone.rootId) end
    end
    self.drones = {}
    self.lastClock = nil
    self.elapsed = 0
end

function SCO_CybranDroneGroup:Fail()
    self:ClearInstances()
    if not self.failed then
        self.failed = true
        Engine.Error("SCOM Cybran build-drone instance failed; stock beam retained.")
    end
end

function SCO_CybranDroneGroup:CanRender()
    local owner, target = self.owner, self.targetUnit
    if self.deleted or self.failed or not self.enabled
        or not SCO_DroneAlive(owner) or owner.isReclaiming or owner.isCapturing
    then return false end
    -- Reclaim can target a prop, which has no unit upgrade methods. Leave that
    -- work to the stock beam and reject stale work targets before unit queries.
    if not ((owner.isBuilding and owner.buildTarget == target)
        or (owner.isRepairing and owner.repairTarget == target))
        or not SCO_DroneAlive(target) or target.entityType ~= "unit"
    then return false end
    if owner:GetPause() or owner:IsUpgrading() or target:IsUpgrading() or target:IsUpgrade()
        or not owner:IsCompleted() or owner:IsPlacementGhost()
        or owner:IsIntelVisionVisible() ~= true or target:IsIntelVisionVisible() ~= true
    then return false end
    return true
end

function SCO_CybranDroneGroup:SetTarget(target)
    if self.deleted then return end
    if self.targetUnit ~= target then
        self:ClearInstances()
        self.targetUnit = target
        self.boundsTarget = nil
    end
    return SCO_DroneStock(self, "SetTarget", target)
end

function SCO_CybranDroneGroup:RemoveTarget()
    if self.deleted then return end
    self:ClearInstances()
    self.targetUnit = nil
    self.boundsTarget = nil
    self.enabled = false
    return SCO_DroneStock(self, "RemoveTarget")
end

function SCO_CybranDroneGroup:SetEnabled(enabled)
    if self.deleted then return end
    self.enabled = enabled == true
    local inheritedResult = SCO_DroneStock(self, "SetEnabled", enabled)
    if self.enabled then self:RenderUpdate() else self:ClearInstances() end
    return inheritedResult
end

function SCO_CybranDroneGroup:Update()
    if not self.deleted then return SCO_DroneStock(self, "Update") end
end

function SCO_CybranDroneGroup:MeasureTarget()
    if self.boundsTarget == self.targetUnit then return end
    local target = self.targetUnit
    local collision = target.tp.collisionInfo
    local size, offset = collision.collisionSize, collision.centerOffset or {}
    local footprint = target.tp.footprint or {}
    local halfX = math.max(size.x, footprint.x or 0) * 0.5
    local halfZ = math.max(size.z, footprint.z or footprint.y or 0) * 0.5
    local offsetRadius = math.sqrt((offset.x or 0)^2 + (offset.z or 0)^2)
    -- The native beam keeps this offset in world axes. Bound all target yaws
    -- around that same center, including the rotated collider's displacement.
    local radius = math.sqrt(halfX^2 + halfZ^2) + 2 * offsetRadius
    local general = target.tp.general
    local modelId = general.modelTpId or general.tpId
    local path = "Units/" .. modelId .. "/LOD0/" .. modelId .. "_lod0.sanmodel"
    local status, center, meshSize = Engine.GetMeshBounds(path)
    if status == EngineErrorCode.Success and center and meshSize then
        local x = math.abs(center.x) + meshSize.x * 0.5
        local z = math.abs(center.z) + meshSize.z * 0.5
        radius = math.max(radius, math.sqrt(x^2 + z^2) + offsetRadius)
    end
    self.radius = radius + 0.35
    -- Visible vertical excursions without returning to roof-height or skyward
    -- orbits. Terrain/water clearance remains independent of the target height.
    self.hoverCeiling = math.max(0.65, math.min(1.35, size.y * 0.5))
    self.boundsTarget = target
end

function SCO_CybranDroneGroup:CreateInstances(center, now)
    local prefab = SCO_DroneGetPrefab()
    if prefab == nil then self.failed = true; return false end
    local ownerPosition = self.owner:GetPosition()
    local bones = self.owner.tp.additions and self.owner.tp.additions.buildBeamBones
    if bones and bones[1] then
        local bone = self.owner:GetBoneId(bones[1])
        if SCO_DroneValid(bone) then
            local _, muzzlePosition = Engine.GetLocalEntityWorldPosition(bone)
            ownerPosition = muzzlePosition
        end
    end
    local dx, dz = ownerPosition.x - center.x, ownerPosition.z - center.z
    self.startAngle = math.atan2(dz, dx)
    self.startRadius = math.max(self.radius, math.sqrt(dx^2 + dz^2))
    self.lastClock = now
    self.elapsed = 0
    for index = 1, self.count do
        local status, rootId = Engine.InstantiatePrefab(prefab, center,
            EngineClasses.float3(1, 1, 1), GetIdentityQuaternion())
        if status ~= EngineErrorCode.Success or not SCO_DroneValid(rootId) then
            if SCO_DroneValid(rootId) then Engine.DeletePrefabInstance(rootId) end
            self:Fail()
            return false
        end
        local drone = {rootId = rootId, beamIds = {}, constructionHop = {emitterId = rootId},
            angle = self.startAngle + (SCO_DroneRandom(self) * 2 - 1) * math.pi,
            angularVelocity = 0, desiredVelocity = 0, nextDecision = 0,
            radiusOffset = 0.10 + 0.55 * SCO_DroneRandom(self),
            radiusPhase = SCO_DroneRandom(self) * 2 * math.pi,
            radiusRate = 0.30 + 0.40 * SCO_DroneRandom(self),
            hover = 0.15 + (self.hoverCeiling - 0.15) * SCO_DroneRandom(self),
            nextHeightDecision = 0.3 + 1.2 * SCO_DroneRandom(self)}
        self.drones[index] = drone
        for tipIndex = 1, #SCO_CybranDroneTips do
            local _, id = Engine.GetLocalBone(rootId, "Drone Tip Beam " .. tipIndex)
            if not SCO_DroneValid(id) then self:Fail(); return false end
            drone.beamIds[tipIndex] = id
        end
    end
    return true
end

function SCO_CybranDroneGroup:RenderUpdate()
    if self.deleted then return end
    SCO_DroneStock(self, "RenderUpdate")
    if not self:CanRender() then
        self:ClearInstances()
        return
    end
    local count = SCO_DroneCount(self.owner)
    if self.count ~= count then self:ClearInstances(); self.count = count end
    self:MeasureTarget()
    local target = self.targetUnit
    local position = target:GetPosition()
    local collision = target.tp.collisionInfo
    local offset = collision.centerOffset or {}
    local center = EngineClasses.float3(position.x + (offset.x or 0),
        position.y + (offset.y or 0), position.z + (offset.z or 0))
    local now = Engine.GetSimulationTime()
    if #self.drones == 0 and not self:CreateInstances(center, now) then
        return
    end
    -- Render-context simulation time is interpolated by TxRenderSystem_Time.
    -- Clamp stalls and ignore older sim-callback timestamps without a phase jump.
    local dt = math.max(0, math.min(0.1, now - self.lastClock))
    self.elapsed = self.elapsed + dt
    self.lastClock = math.max(self.lastClock, now)
    local fraction = math.max(0, math.min(1, target:GetFractionComplete()))
    local color = self.owner:GetColor()
    local waterStatus, hasWater = Engine.HasWater()
    local waterLevel = -math.huge
    if waterStatus == EngineErrorCode.Success and hasWater then
        waterStatus, waterLevel = Engine.GetWaterLevel()
        if not SCO_DroneFinite(waterLevel) then waterStatus = nil end
    end
    if waterStatus ~= EngineErrorCode.Success then
        for _, drone in ipairs(self.drones) do SCO_DroneHide(drone) end
        return
    end
    for index, drone in ipairs(self.drones) do
        if not SCO_DroneValid(drone.rootId) then self:Fail(); return end
        local elapsed = math.max(0, self.elapsed - (index - 1) * 0.08)
        local progress = math.min(1, elapsed / 0.9)
        local ease = progress * progress * (3 - 2 * progress)
        -- Each drone changes direction, speed and dwell time independently.
        if self.elapsed >= drone.nextDecision then
            drone.nextDecision = self.elapsed + 0.7 + 1.6 * SCO_DroneRandom(self)
            local choice = SCO_DroneRandom(self)
            drone.desiredVelocity = choice < 0.18 and 0
                or (choice < 0.59 and -1 or 1) * (0.22 + 0.40 * SCO_DroneRandom(self))
        end
        drone.angularVelocity = drone.angularVelocity
            + (drone.desiredVelocity - drone.angularVelocity) * math.min(1, dt * 3)
        drone.angle = drone.angle + drone.angularVelocity * dt * ease
        -- Radial emergence stays outside the target; no chord cuts through it.
        local angle = self.startAngle + ease * (drone.angle - self.startAngle)
        local orbitRadius = self.radius + drone.radiusOffset
            + 0.12 * (0.5 + 0.5 * math.sin(elapsed * drone.radiusRate + drone.radiusPhase))
        local radius = self.startRadius + (orbitRadius - self.startRadius) * ease
        -- Height decisions have their own clock, destination and dwell. Cubic
        -- easing gives each rise/dip a soft start/stop and caps speed at .6 m/s.
        if self.elapsed >= drone.nextHeightDecision then
            drone.heightFrom = drone.hover
            drone.heightGoal = 0.15 + (self.hoverCeiling - 0.15) * SCO_DroneRandom(self)
            drone.heightDuration = math.max(1.6 + 2.2 * SCO_DroneRandom(self),
                math.abs(drone.heightGoal - drone.heightFrom) * 2.5)
            drone.heightStarted = self.elapsed
            drone.nextHeightDecision = self.elapsed + drone.heightDuration
                + 0.2 + 0.8 * SCO_DroneRandom(self)
        end
        if drone.heightStarted then
            local heightProgress = math.min(1, (self.elapsed - drone.heightStarted) / drone.heightDuration)
            local heightEase = heightProgress * heightProgress * (3 - 2 * heightProgress)
            drone.hover = drone.heightFrom + (drone.heightGoal - drone.heightFrom) * heightEase
        end
        local hover = drone.hover
        local dronePosition, placed
        local previous = drone.position
        if progress > 0 then
            -- Spread sideways in a bounded annulus instead of stacking skyward.
            -- All candidates remain beyond the target, in the same hover band.
            for attempt = 0, 24 do
                local ring = math.floor(attempt / 9)
                local slot = attempt % 9
                local side = slot % 2 == 0 and 1 or -1
                local candidateAngle = angle + side * math.ceil(slot / 2) * 0.28 / radius
                local candidateRadius = radius + ring * 0.28
                if previous then
                    local dx, dz = previous.x - center.x, previous.z - center.z
                    local previousAngle = math.atan2(dz, dx)
                    local previousRadius = math.sqrt(dx^2 + dz^2)
                    local maxStep = 0.8 * dt
                    local turn = (candidateAngle - previousAngle + math.pi) % (2 * math.pi) - math.pi
                    local maxTurn = maxStep / math.max(self.radius, previousRadius)
                    candidateAngle = previousAngle + math.max(-maxTurn, math.min(maxTurn, turn))
                    candidateRadius = math.max(self.radius, previousRadius
                        + math.max(-maxStep, math.min(maxStep, candidateRadius - previousRadius)))
                end
                local candidate = EngineClasses.float3(center.x + math.cos(candidateAngle) * candidateRadius,
                    0, center.z + math.sin(candidateAngle) * candidateRadius)
                local floor = SCO_DroneTerrainFloor(candidate, waterLevel)
                if floor then
                    candidate.y = floor + hover
                    if SCO_DronePlace(drone, candidate) then
                        dronePosition, placed = candidate, true
                        break
                    end
                end
            end
            -- Let the other drone pass instead of teleporting or climbing over it.
            if not placed and previous then
                local dx, dz = previous.x - center.x, previous.z - center.z
                local floor = SCO_DroneTerrainFloor(previous, waterLevel)
                if floor and dx^2 + dz^2 >= self.radius^2 then
                    local candidate = EngineClasses.float3(previous.x, floor + hover, previous.z)
                    if SCO_DronePlace(drone, candidate) then
                        dronePosition, placed = candidate, true
                        drone.desiredVelocity = -drone.desiredVelocity
                        drone.nextDecision = self.elapsed + 0.4 + SCO_DroneRandom(self)
                    end
                end
            end
        end
        if not placed then SCO_DroneHide(drone) end
        dronePosition = dronePosition or center
        local aim = target.SCO_GetConstructionTargetPosition
            and target:SCO_GetConstructionTargetPosition(dronePosition, drone.constructionHop, self.owner)
            or EngineClasses.float3(center.x,
                center.y + collision.collisionSize.y * (fraction - 0.5), center.z)
        local direction = EngineClasses.float3(aim.x - dronePosition.x,
            aim.y - dronePosition.y, aim.z - dronePosition.z)
        Engine.SetLocalEntityLocalPosition(drone.rootId, dronePosition)
        local rotation = Engine.QuaternionLookRotationSafe(direction, EngineClasses.float3(0, 1, 0))
        Engine.SetLocalEntityLocalRotation(drone.rootId, rotation)
        Engine.SetMeshRendererScale(drone.rootId, EngineClasses.float3(ease, ease, ease))
        Engine.SetRendererInstanceData0(drone.rootId, color)
        Engine.SetRendererEnabled(drone.rootId, placed == true)
        -- Parallel beams keep the tip separation through to the build plane;
        -- neither beam converges into a shared center beam.
        local working = placed == true and progress >= 1
        local distance = math.sqrt(direction.x^2 + direction.y^2 + direction.z^2)
        drone.contacts = drone.contacts or {}
        for tipIndex, id in ipairs(drone.beamIds) do
            if not SCO_DroneValid(id) then self:Fail(); return end
            local length = math.max(0, distance - SCO_CybranDroneTips[tipIndex].z)
            Engine.SetMeshRendererScale(id,
                EngineClasses.float3(SCO_CybranDroneBeamWidth, 1, length))
            Engine.SetRendererEnabled(id, working and length > 0)
            -- Preserve the two parallel tips at the target, including their
            -- sideways offsets after rotating the drone toward the build plane.
            local tip = SCO_CybranDroneTips[tipIndex]
            local offset = Engine.QuaternionRotateVector(rotation, EngineClasses.float3(tip.x, tip.y, 0))
            local contactPoint = EngineClasses.float3(aim.x + offset.x, aim.y + offset.y, aim.z + offset.z)
            local contact = drone.contacts[tipIndex] or {}
            drone.contacts[tipIndex] = contact
            local tipOrigin = Engine.QuaternionRotateVector(rotation, EngineClasses.float3(tip.x, tip.y, tip.z))
            local contactOrigin = EngineClasses.float3(dronePosition.x + tipOrigin.x,
                dronePosition.y + tipOrigin.y, dronePosition.z + tipOrigin.z)
            SCO_ConstructionContact.Update(contact, self.owner, target, contactPoint, contactOrigin,
                working and length > 0)
        end
    end
end

function SCO_CybranDroneGroup:Delete()
    if self.deleted then return end
    self:ClearInstances()
    SCO_DroneStock(self, "RemoveTarget")
    SCO_DroneStock(self, "SetEnabled", false)
    if self.stockBeam and self.stockBeam.scoMultiConstructionBeam then
        SCO_DroneStock(self, "Delete")
    end
    self.deleted = true
    self.enabled = false
    self.targetUnit = nil
end

local function SCO_CreateCybranBuildDroneBeam(unit, stockBeam)
    local count = SCO_DroneCount(unit)
    if not count or unit:HasTags(Tags.FACTORY) then return nil end
    local id = unit.localId
    return setmetatable({owner = unit, stockBeam = stockBeam, count = count,
        drones = {}, enabled = false, deleted = false, failed = false,
        randomSeed = ((id.index or 0) * 131 + (id.version or 0) * 57) % 2147483646 + 1,
        scoCybranBuildDrones = true}, SCO_CybranDroneGroup)
end

local SCO_CybranDroneStockOnIntelRadar = ClientUnit.OnIntelRadar
function ClientUnit:OnIntelRadar(...)
    local inheritedResult = SCO_CybranDroneStockOnIntelRadar(self, ...)
    local beam = self.constructionBeam
    if beam and beam.scoCybranBuildDrones then beam:SetEnabled(false) end
    return inheritedResult
end

-- Stop loose contact emitters immediately when their owner leaves vision.
for _, callback in ipairs({"OnIntelHidden", "OnIntelRadar", "OnIntelSonar"}) do
    local previous = ClientUnit[callback]
    ClientUnit[callback] = function(self, ...)
        SCO_ConstructionContact.ClearTree(self.constructionBeam)
        return previous(self, ...)
    end
end

-- SCOM Field Fix: opt-in multi-endpoint construction beams 1.0.0
-- Sanctuary creates one embedded construction beam. Imported FA rigs can
-- declare several animated build endpoints, so replace that single controller
-- only when the template supplies an explicit multiConstructionBeam contract.
local SCO_MultiBeamStockSetUpConstructionBeam =
    ClientUnit.SetUpConstructionBeam
local SCO_MultiBeamStockRenderUpdateBeams = ClientUnit.RenderUpdateBeams
local SCO_MultiBeamStockOnDestroy = ClientUnit.OnDestroy
local SCO_MultiBeamStockOnDelete = ClientUnit.OnDelete

_G.SCO_MultiConstructionBeamPrefabIDs =
    _G.SCO_MultiConstructionBeamPrefabIDs or {}
local SCO_MultiBeamPrefabIDs = _G.SCO_MultiConstructionBeamPrefabIDs
local SCO_MultiBeamCreateConstructionBeam = nil

local SCO_MultiBeamGroup = {}
SCO_MultiBeamGroup.__index = SCO_MultiBeamGroup

local function SCO_MultiBeamValidLocalID(localId)
    return localId ~= nil and Engine.IsValidLocalID(localId)
end

local function SCO_MultiBeamController(rootId)
    if not SCO_MultiBeamCreateConstructionBeam then
        SCO_MultiBeamCreateConstructionBeam =
            Import("client/entities/constructionBeam.lua")
                .CreateConstructionBeam
    end
    return SCO_MultiBeamCreateConstructionBeam(rootId)
end

local function SCO_MultiBeamGetPrefabID(config)
    local prefabName = config.prefabName
    local materialPath = config.materialPath
    local shrink = config.shrink
    if type(prefabName) ~= "string" or prefabName == ""
        or type(materialPath) ~= "string" or materialPath == ""
        or type(shrink) ~= "number" or shrink <= 0
    then
        Engine.Error("Invalid multi-construction-beam prefab contract.")
        return nil
    end

    local key = prefabName .. "|" .. materialPath .. "|" .. tostring(shrink)
    local existing = SCO_MultiBeamPrefabIDs[key]
    if existing then return existing end

    local prefab = EngineClasses.PrefabTemplate(prefabName)
    local head = EngineClasses.EntityTemplate()
    head.entityName = TemplateHeadEntityName
    head.localTranslation = EngineClasses.float3(0, 0, 0)
    head.localScale = 1
    head.localRotation = GetIdentityQuaternion()
    head.forceSimulated = false
    table.insert(prefab.hierarchyTemplate.entities, head)

    local beamEntity = EngineClasses.EntityTemplate()
    beamEntity.entityName = "Construction Beam"
    beamEntity.parentEntityName = TemplateHeadEntityName
    beamEntity.localTranslation = EngineClasses.float3(0, 0, 0)
    beamEntity.localScale = 1
    beamEntity.localRotation = GetIdentityQuaternion()
    beamEntity.forceSimulated = false
    table.insert(prefab.hierarchyTemplate.entities, beamEntity)

    table.insert(prefab.localTemplate.meshTemplates, EngineClasses.MeshTemplate(
        "Construction Beam",
        "VFX/Models/Static/ConstructionBeam.sanmodel",
        materialPath,
        EngineClasses.float3(shrink, 1, 1),
        ShadowCastingMode.Off,
        EngineClasses.float4(),
        EngineClasses.float4(),
        false
    ))

    local errorCode, prefabId = Engine.CreatePrefab(prefab)
    if errorCode ~= EngineErrorCode.Success or prefabId == nil then
        Engine.Error("Unable to create a multi-construction-beam prefab.")
        return nil
    end
    SCO_MultiBeamPrefabIDs[key] = prefabId
    return prefabId
end

function SCO_MultiBeamGroup:SetTarget(target)
    if self.deleted then return end
    if target == nil or not SCO_MultiBeamValidLocalID(target.localId) then
        self:RemoveTarget()
        return
    end
    for _, state in ipairs(self.beams) do
        state.beam:SetTarget(target)
    end
    self:RenderUpdate()
end

function SCO_MultiBeamGroup:RemoveTarget()
    if self.deleted then return end
    self.enabled = false
    for _, state in ipairs(self.beams) do
        state.beam:SetEnabled(false)
        state.beam:RemoveTarget()
    end
end

function SCO_MultiBeamGroup:SetEnabled(enabled)
    if self.deleted then return end
    self.enabled = enabled == true
    for _, state in ipairs(self.beams) do
        state.beam:SetEnabled(
            self.enabled and state.beam.targetUnit ~= nil)
    end
    self:RenderUpdate()
end

function SCO_MultiBeamGroup:Update()
    -- Stock BuildThread owns this simulation-rate call. Animated loose roots
    -- are pinned and aimed once per rendered frame below.
end

function SCO_MultiBeamGroup:RenderUpdate()
    if self.deleted or not self.enabled then return end
    for _, state in ipairs(self.beams) do
        local target = state.beam.targetUnit
        if SCO_MultiBeamValidLocalID(state.rootId)
            and SCO_MultiBeamValidLocalID(state.muzzleId)
            and target ~= nil
            and SCO_MultiBeamValidLocalID(target.localId)
        then
            Engine.GetLocalEntityWorldPosition(
                state.muzzleId,
                state.muzzlePosition)
            Engine.SetLocalEntityLocalPosition(
                state.rootId,
                state.muzzlePosition)
            state.beam:Update()
        else
            state.beam:SetEnabled(false)
            state.beam:RemoveTarget()
        end
    end
end

function SCO_MultiBeamGroup:Delete()
    if self.deleted then return end
    self.deleted = true
    self.enabled = false
    for _, state in ipairs(self.beams) do
        state.beam:SetEnabled(false)
        state.beam:RemoveTarget()
        if SCO_MultiBeamValidLocalID(state.rootId) then
            Engine.DeletePrefabInstance(state.rootId)
        end
    end
    self.beams = {}
end

local function SCO_MultiBeamCreateGroup(unit, config)
    local bones = unit.tp.additions and unit.tp.additions.buildBeamBones
    if type(bones) ~= "table" or #bones == 0 then
        Engine.Error("Multi-construction-beam endpoints are missing.")
        return nil
    end

    local sliceBeams = config.uefSliceBeams == true
    if sliceBeams and #bones ~= 1 then
        Engine.Error("UEF slice beams require one shared build-arm muzzle.")
        return nil
    end
    local prefabId = SCO_MultiBeamGetPrefabID(config)
    if prefabId == nil then return nil end

    local group = setmetatable({
        beams = {},
        deleted = false,
        enabled = false,
        scoMultiConstructionBeam = true,
    }, SCO_MultiBeamGroup)
    local initialPosition = unit:GetPosition()
    local seenBones = {}

    for beamIndex = 1, (sliceBeams and 2 or #bones) do
        local boneName = bones[sliceBeams and 1 or beamIndex]
        if type(boneName) ~= "string" or boneName == ""
            or (seenBones[boneName] and not sliceBeams)
        then
            group:Delete()
            Engine.Error("Invalid or duplicate multi-construction-beam endpoint.")
            return nil
        end
        seenBones[boneName] = true

        local muzzleId = unit:GetBoneId(boneName)
        if not SCO_MultiBeamValidLocalID(muzzleId) then
            group:Delete()
            Engine.Error("Missing multi-construction-beam bone " .. boneName .. ".")
            return nil
        end

        local errorCode, rootId = Engine.InstantiatePrefab(
            prefabId,
            initialPosition,
            EngineClasses.float3(1, 1, 1),
            GetIdentityQuaternion())
        if errorCode ~= EngineErrorCode.Success
            or not SCO_MultiBeamValidLocalID(rootId)
        then
            if SCO_MultiBeamValidLocalID(rootId) then
                Engine.DeletePrefabInstance(rootId)
            end
            group:Delete()
            Engine.Error(
                "Unable to instantiate multi-construction beam for "
                .. boneName .. ".")
            return nil
        end

        local beamEntityId = EngineClasses.LocalID()
        Engine.GetLocalBone(rootId, "Construction Beam", beamEntityId)
        if not SCO_MultiBeamValidLocalID(beamEntityId) then
            Engine.DeletePrefabInstance(rootId)
            group:Delete()
            Engine.Error("Multi-construction-beam prefab has no beam entity.")
            return nil
        end

        local ok, beam = pcall(SCO_MultiBeamController, rootId)
        if not ok or beam == nil then
            Engine.DeletePrefabInstance(rootId)
            group:Delete()
            Engine.Error("Multi-construction-beam controller creation failed.")
            return nil
        end

        beam.scoUefSliceIndex = sliceBeams and beamIndex or nil
        table.insert(group.beams, {
            rootId = rootId,
            muzzleId = muzzleId,
            muzzlePosition = EngineClasses.float3(),
            beam = beam,
        })
    end
    return group
end

local function SCO_MultiBeamDisableEmbedded(beam)
    if beam == nil then return end
    if type(beam.SetEnabled) == "function" then beam:SetEnabled(false) end
    if type(beam.RemoveTarget) == "function" then beam:RemoveTarget() end
end

local function SCO_MultiBeamDispose(unit)
    local beam = unit.constructionBeam
    SCO_ConstructionContact.ClearTree(beam)
    if beam and (beam.scoMultiConstructionBeam or beam.scoCybranBuildDrones) then
        unit.constructionBeam = nil
        unit.constructionBeamEnabled = false
        beam:Delete()
    end
end

function ClientUnit:SetUpConstructionBeam()
    SCO_MultiBeamDispose(self)
    local result = SCO_MultiBeamStockSetUpConstructionBeam(self)
    local additions = self.tp and self.tp.additions
    local config = additions and additions.multiConstructionBeam
    if config ~= nil then
        SCO_MultiBeamDisableEmbedded(self.constructionBeam)
        self.constructionBeam = nil
        self.constructionBeamEnabled = false
        if type(config) ~= "table" then
            Engine.Error("Malformed multi-construction-beam unit contract.")
            return result
        end
        self.constructionBeam = SCO_MultiBeamCreateGroup(self, config)
    end
    -- Drone cosmetics must wrap the animated muzzle controller, not bypass it
    -- and keep Sanctuary's single embedded beam at the model origin.
    local drones = SCO_CreateCybranBuildDroneBeam
        and SCO_CreateCybranBuildDroneBeam(self, self.constructionBeam)
    if drones then self.constructionBeam = drones end
    return result
end

function ClientUnit:RenderUpdateBeams()
    local result = SCO_MultiBeamStockRenderUpdateBeams(self)
    local beam = self.constructionBeam
    if beam and (beam.scoMultiConstructionBeam or beam.scoCybranBuildDrones) then
        beam:RenderUpdate()
    end
    return result
end

function ClientUnit:OnDestroy(destroyType)
    SCO_MultiBeamDispose(self)
    return SCO_MultiBeamStockOnDestroy(self, destroyType)
end

function ClientUnit:OnDelete()
    SCO_MultiBeamDispose(self)
    return SCO_MultiBeamStockOnDelete(self)
end
-- Source emitter instances and Novax shell renderer visibility.
local SpecialVFX=Import("common/loading/vfxTemplateLoader.lua")
local function Config(unit)
    return unit.tp and unit.tp.additions and unit.tp.additions.scoSpecial
end
local function SyncNovaxShells(unit, visible)
    local cfg = Config(unit)
    if not cfg or cfg.kind ~= "novaxSatellite" then return end
    local enabled = visible and not unit.dead and not unit.deleted
        and not unit.scoSpecialHideShells and not unit.scoSpecialShellsDisposed
    local color, state
    if enabled then
        -- Native renderer setters affect only the addressed component. Shells
        -- must receive the body's team/build state before becoming visible.
        local colorStatus, bodyColor = Engine.GetRendererInstanceData0(unit.localId)
        local stateStatus, bodyState = Engine.GetRendererInstanceData1(unit.localId)
        if colorStatus ~= EngineErrorCode.Success or stateStatus ~= EngineErrorCode.Success then return end
        color, state = bodyColor, bodyState
    end
    for _, name in ipairs(cfg.hideRenderers or {}) do
        local id = unit:GetBoneId(name)
        if Engine.IsValidLocalID(id) then
            if enabled then
                Engine.SetRendererInstanceData0(id, color)
                Engine.SetRendererInstanceData1(id, state)
            end
            Engine.SetRendererEnabled(id, enabled == true)
        end
    end
end

local PreviousColor = ClientUnit.SetColor
function ClientUnit:SetColor(color)
    local inherited = PreviousColor(self, color)
    SyncNovaxShells(self, self:IsIntelVisionVisible())
    return inherited
end
local PreviousBuildProgress = ClientUnit.SetRenderBuildProgress
function ClientUnit:SetRenderBuildProgress(progress)
    local inherited = PreviousBuildProgress(self, progress)
    SyncNovaxShells(self, self:IsIntelVisionVisible())
    return inherited
end
for _, callback in ipairs({"OnIntelVision", "OnIntelRadar", "OnIntelHidden"}) do
    local previous = ClientUnit[callback]
    local visible = callback == "OnIntelVision"
    ClientUnit[callback] = function(self, ...)
        local inherited = previous(self, ...)
        SyncNovaxShells(self, visible)
        return inherited
    end
end
local PreviousDestroy = ClientUnit.OnDestroy
function ClientUnit:OnDestroy(...)
    SyncNovaxShells(self, false)
    return PreviousDestroy(self, ...)
end

local function Stop(effect)
    if Engine.IsValidLocalID(effect.id) then
        Engine.SetParticleCanEmit(effect.id,false)
        Engine.SetDestroyUponCompletion(effect.id,true)
    end
end
function ClientUnit:SCOSpecialEvent(name,boneOverride)
    local cfg=Config(self)
    if not cfg then return end
    if name=="hideShells" then
        self.scoSpecialHideShells=true
        SyncNovaxShells(self, false)
        return
    end
    if name=="hideModel" then self.scoSpecialHideModel=true;self.isSelectable=false;return end
    local effect=cfg.effects[name]
    if not effect then return end
    local bone=self:GetBoneId(boneOverride~="" and boneOverride or effect.bone)
    if not Engine.IsValidLocalID(bone) then return end
    local prefab=SpecialVFX.GetOrCreateVFXPrefab(effect.path)
    local _,position=Engine.GetLocalEntityWorldPosition(bone)
    local _,rotation=Engine.GetLocalEntityWorldRotation(bone)
    local _,id=Engine.InstantiatePrefab(prefab,position,EngineClasses.float3(1,1,1),rotation)
    if not Engine.IsValidLocalID(id) then return end
    Engine.SetDestroyUponCompletion(id,not effect.loop)
    Engine.SetParticleCanEmit(id,self:IsIntelVisionVisible())
    self.scoSpecialEffects=self.scoSpecialEffects or {}
    self.scoSpecialEffects[#self.scoSpecialEffects+1]={id=id,bone=bone,offset=effect.offset}
end

local PreviousRender=ClientUnit.RenderUpdateBeams
function ClientUnit:RenderUpdateBeams()
    local result=PreviousRender(self)
    local cfg=Config(self)
    if not cfg then return result end
    if self.scoSpecialHideModel then Engine.SetRendererEnabled(self.localId,false) end
    for i=#(self.scoSpecialEffects or {}),1,-1 do
        local effect=self.scoSpecialEffects[i]
        if not Engine.IsValidLocalID(effect.id) then table.remove(self.scoSpecialEffects,i)
        elseif Engine.IsValidLocalID(effect.bone) then
            local _,position=Engine.GetLocalEntityWorldPosition(effect.bone)
            local _,rotation=Engine.GetLocalEntityWorldRotation(effect.bone)
            local offset=Engine.QuaternionRotateVector(rotation,EngineClasses.float3(unpack(effect.offset)))
            Engine.SetLocalEntityLocalPosition(effect.id,EngineClasses.float3(position.x+offset.x,position.y+offset.y,position.z+offset.z))
            Engine.SetLocalEntityLocalRotation(effect.id,rotation)
            Engine.SetParticleCanEmit(effect.id,self:IsIntelVisionVisible())
        else Stop(effect);table.remove(self.scoSpecialEffects,i) end
    end
    return result
end
local PreviousDelete=ClientUnit.Delete
function ClientUnit:Delete()
    local cfg = Config(self)
    if cfg and cfg.kind == "novaxSatellite" then self.scoSpecialShellsDisposed = true end
    SyncNovaxShells(self, false)
    for _,effect in ipairs(self.scoSpecialEffects or {}) do Stop(effect) end
    self.scoSpecialEffects=nil
    return PreviousDelete(self)
end
local PreviousSelectable=ClientUnit.IsSelectable
function ClientUnit:IsSelectable()
    local cfg=Config(self)
    if cfg and cfg.kind=="othuy" then return false end
    return PreviousSelectable(self)
end
-- SCOM optional-pack inherited visuals: opt1
local SecondaryVFX=Import('common/loading/vfxTemplateLoader.lua')
local function SecondaryConfig(unit)
  local c=unit.tp and unit.tp.additions and unit.tp.additions.scoSourceSecondaryVisuals
  local optionalId=unit.tpId
  if c and type(c.targetId)=='string'
      and c.targetId:match('^u[ecgs]%a%d+$')
      and type(optionalId)=='string'
      and (optionalId:match('^w%a%a%d+$') or optionalId:match('^sc2r_')) then
      return
  end
  if c then assert(c.targetId==unit.tpId,'Secondary client identity drift') end
  return c
end
local function SecondaryVisible(unit,definition)
  if unit.dead or unit.scoSecondaryDeleted or unit:IsPlacementGhost() or not unit:IsIntelVisionVisible() then return false end
  if definition.when=='complete' and not unit:IsCompleted() then return false end
  if definition.delay and definition.delay>0 and
      (not unit.scoSecondaryCompletedAt or Engine.GetSimulationTime()-unit.scoSecondaryCompletedAt<definition.delay) then return false end
  if definition.condition=='shield' then
      for _,shield in ipairs(unit.shields or {}) do if shield:IsEnabled() then return true end end
      return false
  elseif definition.condition=='land' or definition.condition=='seabed' then
      local _,water=Engine.GetWaterLevel()
      local _,position=Engine.GetLocalEntityWorldPosition(unit.localId)
      return (position.y<water)==(definition.condition=='seabed')
  end
  return true
end
local function SecondaryStop(effect)
  if effect.id and Engine.IsValidLocalID(effect.id) then Engine.DeletePrefabInstance(effect.id) end
  effect.id=nil
end
function ClientUnit:SCOUpdateSecondaryVisuals()
  local cfg=SecondaryConfig(self)
  if not cfg then return end
  local now=Engine.GetSimulationTime()
  local delta=self.scoSecondaryLastTime and math.max(0,now-self.scoSecondaryLastTime) or 0
  self.scoSecondaryLastTime=now
  if self:IsCompleted() and not self.scoSecondaryCompletedAt then self.scoSecondaryCompletedAt=now end
  if not self.scoSecondaryCreatedAt then self.scoSecondaryCreatedAt=now end
  self.scoSecondarySliders=self.scoSecondarySliders or {}
  if not self.dead and not self.scoSecondaryDeleted then
      for index,definition in ipairs(cfg.sliders or {}) do
          local current=self.scoSecondarySliders[index]
          if not current then current={unpack(definition.closedOffset)};self.scoSecondarySliders[index]=current end
          local open=self:IsCompleted() and (definition.condition~='production' or
              (self:GetProductionToggle() and not self:GetPause()))
          local goal=open and {0,0,0} or definition.closedOffset
          local distance=0
          for axis=1,3 do distance=distance+(goal[axis]-current[axis])^2 end
          distance=math.sqrt(distance)
          local fraction=distance==0 and 1 or math.min(1,delta*definition.speed/distance)
          for axis=1,3 do current[axis]=current[axis]+(goal[axis]-current[axis])*fraction end
          local bone=self:GetBoneId(definition.bone)
          if Engine.IsValidLocalID(bone) then
              Engine.SetLocalEntityLocalPosition(bone,EngineClasses.float3(
                  definition.basePosition[1]+current[1],definition.basePosition[2]+current[2],definition.basePosition[3]+current[3]))
          end
      end
  end
  for _,beam in ipairs(cfg.beams or {}) do
      local id=self:GetBoneId(beam.entityName)
      if Engine.IsValidLocalID(id) then
          local visible=SecondaryVisible(self,beam)
          Engine.SetRendererEnabled(id,visible)
          if visible then
              local _,start=Engine.GetLocalEntityWorldPosition(self:GetBoneId(beam.bone))
              local _,finish=Engine.GetLocalEntityWorldPosition(self:GetBoneId(beam.endBone))
              local _,rotation=Engine.GetLocalEntityWorldRotation(self:GetBoneId(beam.bone))
              local q=rotation.value
              local inverse=EngineClasses.quaternion(EngineClasses.float4(-q.x,-q.y,-q.z,q.w))
              local direction=EngineClasses.float3(finish.x-start.x,finish.y-start.y,finish.z-start.z)
              local length=math.sqrt(direction.x^2+direction.y^2+direction.z^2)
              local lifetime=now-(beam.when=='complete' and self.scoSecondaryCompletedAt or self.scoSecondaryCreatedAt)-(beam.delay or 0)
              local height=0
              if beam.travel then
                  local phase=lifetime%(2*beam.travel.halfPeriod)
                  height=beam.travel.worldYOffset+beam.travel.speed*math.min(phase,2*beam.travel.halfPeriod-phase)
              end
              local offset=Engine.QuaternionRotateVector(inverse,EngineClasses.float3(0,height,0))
              local forward=Engine.QuaternionRotateVector(inverse,direction)
              local up=Engine.QuaternionRotateVector(inverse,EngineClasses.float3(0,1,0))
              Engine.SetLocalEntityLocalPosition(id,offset)
              Engine.SetLocalEntityLocalRotation(id,Engine.QuaternionLookRotationSafe(forward,up))
              Engine.SetRendererInstanceData0(id,EngineClasses.float4(length,lifetime,1,1))
          end
      end
  end
  for _,mesh in ipairs(cfg.meshes or {}) do
      local id=self:GetBoneId(mesh.entityName)
      if Engine.IsValidLocalID(id) then Engine.SetRendererEnabled(id,SecondaryVisible(self,mesh)) end
  end
  self.scoSecondaryEffects=self.scoSecondaryEffects or {}
  for index,definition in ipairs(cfg.effects or {}) do
      local effect=self.scoSecondaryEffects[index] or {}
      self.scoSecondaryEffects[index]=effect
      local bone=self:GetBoneId(definition.bone)
      if not SecondaryVisible(self,definition) or not Engine.IsValidLocalID(bone) then
          SecondaryStop(effect)
      else
          local _,position=Engine.GetLocalEntityWorldPosition(bone)
          local _,rotation=Engine.GetLocalEntityWorldRotation(bone)
          local offset=Engine.QuaternionRotateVector(rotation,EngineClasses.float3(unpack(definition.offset)))
          position=EngineClasses.float3(position.x+offset.x,position.y+offset.y,position.z+offset.z)
          if not effect.id or not Engine.IsValidLocalID(effect.id) then
              local prefab=SecondaryVFX.GetOrCreateVFXPrefab(definition.path)
              local _,id=Engine.InstantiatePrefab(prefab,position,EngineClasses.float3(1,1,1),rotation)
              effect.id=id
              if Engine.IsValidLocalID(id) then
                  Engine.SetDestroyUponCompletion(id,false)
                  Engine.SetParticleCanEmit(id,true)
              end
          else
              Engine.SetLocalEntityLocalPosition(effect.id,position)
              Engine.SetLocalEntityLocalRotation(effect.id,rotation)
          end
      end
  end
end
local SecondaryPreviousRender=ClientUnit.RenderUpdateBeams
function ClientUnit:RenderUpdateBeams(...)
  local result=SecondaryPreviousRender(self,...)
  self:SCOUpdateSecondaryVisuals()
  return result
end
local SecondaryPreviousDestroy=ClientUnit.OnDestroy
function ClientUnit:OnDestroy(...)
  local result=SecondaryPreviousDestroy(self,...)
  self:SCOUpdateSecondaryVisuals()
  return result
end
local SecondaryPreviousDelete=ClientUnit.OnDelete
function ClientUnit:OnDelete(...)
  self.scoSecondaryDeleted=true
  self:SCOUpdateSecondaryVisuals()
  return SecondaryPreviousDelete(self,...)
end
-- Visual-only host events retain ID versions and never outlive their owner.
local DynamicVFX=Import('common/loading/vfxTemplateLoader.lua')
local DynamicPending={}
local function DynamicConfig(unit)
    return unit.tp and unit.tp.additions and unit.tp.additions.scoSourceDynamicVisuals
end
local function DynamicState(unit)
    if not unit.scoDynamicClient then unit.scoDynamicClient={serial={},effects={}} end
    return unit.scoDynamicClient
end
local function DynamicStop(effect)
    if effect.id and Engine.IsValidLocalID(effect.id) then Engine.DeletePrefabInstance(effect.id) end
    effect.id=nil
end
local function DynamicApply(unit,event)
    local c=DynamicConfig(unit);if not c or unit.dead or unit.scoDynamicDeleted then return end
    if event.kind==1 and not c.exhaust or event.kind==2 and not (c.barrel and c.barrel.steamGraph)
        or event.kind==3 and not c.wings or event.kind==4 and not c.barrels then return end
    local s=DynamicState(unit)
    if event.serial<=(s.serial[event.kind] or 0) then return end
    s.serial[event.kind]=event.serial
    if event.kind==1 then s.exhaustOn=event.enabled
    elseif event.kind==3 then s.wingPose=event
    elseif event.kind==4 then s.barrelGoals={event.left,event.right}
    elseif event.enabled and Engine.GetSimulationTime()-event.time<.5 then
        s.effects[#s.effects+1]={bone=c.barrel.steamBone,path=c.barrel.steamGraph.path,
            expires=event.time+c.barrel.steamLifetime}
    end
end
function _G.SCO_SourceDynamicEvent(event)
    if type(event)~='table' or type(event.unitID)~='table' or type(event.enabled)~='boolean'
        or (event.kind~=1 and event.kind~=2 and event.kind~=3 and event.kind~=4) or type(event.serial)~='number' or event.serial~=math.floor(event.serial)
        or event.serial<1 or type(event.time)~='number' or event.time~=event.time or math.abs(event.time)==math.huge then return end
    if event.kind==4 and ((event.left~=0 and event.left~=1) or (event.right~=0 and event.right~=1)) then return end
    if event.kind==3 then
        for _,key in ipairs({'left','right','leftGoal','rightGoal'}) do
            if type(event[key])~='number' or event[key]~=event[key] or math.abs(event[key])>180 then return end
        end
    end
    local id=event.unitID
    for _,key in ipairs({'index','version'}) do
        if type(id[key])~='number' or id[key]~=math.floor(id[key]) or id[key]<0 or id[key]>4294967295 then return end
    end
    local unit=__Entities.Units[id.index]
    if unit and unit.id.version>=id.version then
        if unit.id.version==id.version then DynamicApply(unit,event) end
        return
    end
    local now=Engine.GetSimulationTime()
    for index,pending in pairs(DynamicPending) do if now-pending.received>10 then DynamicPending[index]=nil end end
    local pending=DynamicPending[id.index]
    if not pending or pending.version<id.version then
        pending={version=id.version,received=now,events={}};DynamicPending[id.index]=pending
    end
    if pending.version==id.version then
        local previous=pending.events[event.kind]
        if not previous or previous.serial<event.serial then pending.events[event.kind]=event end
    end
end
local function DynamicAttach(unit,effect)
    local bone=unit:GetBoneId(effect.bone)
    if not Engine.IsValidLocalID(bone) then return end
    local _,position=Engine.GetLocalEntityWorldPosition(bone)
    local _,rotation=Engine.GetLocalEntityWorldRotation(bone)
    if not effect.id then
        local prefab=DynamicVFX.GetOrCreateVFXPrefab(effect.path)
        local _,id=Engine.InstantiatePrefab(prefab,position,EngineClasses.float3(1,1,1),rotation)
        if Engine.IsValidLocalID(id) then
            effect.id=id;Engine.SetDestroyUponCompletion(id,false);Engine.SetParticleCanEmit(id,true)
        end
    elseif Engine.IsValidLocalID(effect.id) then
        Engine.SetLocalEntityLocalPosition(effect.id,position)
        Engine.SetLocalEntityLocalRotation(effect.id,rotation)
    end
end
local function DynamicSimulationBasis(unit,name)
    local result,global=Engine.GetGlobalBone(unit.id,name)
    if result~=EngineErrorCode.Success or not Engine.IsValidGlobalID(global) then return end
    local status,basis=Engine.GetGlobalEntityLocalRotation(global)
    if status==EngineErrorCode.Success then return basis end
end
local function DynamicThrust(unit,c,s,now,visible)
    if not visible then s.thrust=nil;return end
    local pose=s.thrust
    if not pose then pose={time=now,pitch=0,bank=0,yaw=0};s.thrust=pose end
    local delta=math.max(0,now-pose.time);pose.time=now
    -- CurrentSpeed is distance per simulation tick (also used by native audio).
    -- This bounded visual adapter approximates FA's closed thrust controller.
    local _,speed=Engine.GetMovementCurrentSpeed(unit.id)
    local _,roll=Engine.GetMovementRollDegrees(unit.id)
    local maximum=unit.tp.movement.speed*Constants.TickTimeStep
    local fraction=math.max(0,math.min(1,(speed or 0)/maximum))
    local bank=math.max(-1,math.min(1,(roll or 0)/c.nativeBankReferenceDegrees*c.turnMultiplier))
    local step=delta*c.responseRadiansPerSecond
    local function approach(value,goal)
        if value<goal then return math.min(goal,value+step) end
        return math.max(goal,value-step)
    end
    pose.pitch=approach(pose.pitch,-fraction*c.pitchEnvelopeRadians)
    pose.bank=approach(pose.bank,bank*c.bankEnvelopeRadians)
    pose.yaw=approach(pose.yaw,bank*(c.yawEnvelopeRadians or 0))
    local offset=Engine.QuaternionMultiply(
        Engine.QuaternionAxisAngle(EngineClasses.float3(1,0,0),pose.pitch),
        Engine.QuaternionMultiply(
            Engine.QuaternionAxisAngle(EngineClasses.float3(0,1,0),pose.yaw),
            Engine.QuaternionAxisAngle(EngineClasses.float3(0,0,1),pose.bank)))
    for index,name in ipairs(c.bones) do
        local id=unit:GetBoneId(name)
        if Engine.IsValidLocalID(id) then
            local basis
            if c.simulationBasis then
                -- C14's reversible landing clip owns these same engine bones.
                basis=DynamicSimulationBasis(unit,name)
            else
                local bind=c.bindRotations[index]
                basis=EngineClasses.quaternion(EngineClasses.float4(bind.x,bind.y,bind.z,bind.w))
            end
            if basis then Engine.SetLocalEntityLocalRotation(id,Engine.QuaternionMultiply(basis,offset)) end
        end
    end
end
local function DynamicBarrels(unit,c,s,now,visible)
    if not visible then s.barrelPose=nil;return end
    local pose=s.barrelPose
    if not pose then pose={time=now,parts={}};s.barrelPose=pose end
    local delta=math.max(0,math.min(.5,now-pose.time));pose.time=now
    for index,definition in ipairs(c) do
        local part=pose.parts[index]
        if not part then part={speed=0,angle=0};pose.parts[index]=part end
        local active=s.barrelGoals and s.barrelGoals[index]==1
        if active and not part.active and not part.created then
            part.speed=definition.initialSpeed;part.created=true
        end
        part.active=active
        local goal=active and definition.speed or 0
        local step=delta*definition.acceleration
        local nextSpeed=part.speed<goal and math.min(goal,part.speed+step) or math.max(goal,part.speed-step)
        part.angle=(part.angle+(part.speed+nextSpeed)*.5*delta)%360
        part.speed=nextSpeed
        local bone=unit:GetBoneId(definition.bone)
        local basis=DynamicSimulationBasis(unit,definition.bone)
        if basis and Engine.IsValidLocalID(bone) then
            local offset=Engine.QuaternionAxisAngle(EngineClasses.float3(0,0,1),part.angle*math.pi/180)
            Engine.SetLocalEntityLocalRotation(bone,Engine.QuaternionMultiply(basis,offset))
        end
    end
end
function ClientUnit:SCOUpdateDynamicVisuals()
    local c=DynamicConfig(self);if not c then return end
    local s=DynamicState(self)
    local visible=not self.dead and not self.scoDynamicDeleted and not self:IsPlacementGhost()
        and self:IsIntelVisionVisible() and self:IsCompleted()
    local now=Engine.GetSimulationTime()
    if c.thrust then DynamicThrust(self,c.thrust,s,now,visible) end
    if c.barrels then DynamicBarrels(self,c.barrels,s,now,visible) end
    if c.wings and s.wingPose and not self.dead and not self.scoDynamicDeleted and not self:IsPlacementGhost() then
        local pose=s.wingPose
        local delta=math.max(0,now-pose.time)*c.wings.speed
        local angles={pose.left,pose.right};local goals={pose.leftGoal,pose.rightGoal}
        local axis={x=0,y=0,z=0};axis[c.wings.axis]=1
        for index,name in ipairs(c.wings.bones) do
            local bone=self:GetBoneId(name)
            if Engine.IsValidLocalID(bone) then
                local angle=angles[index]<goals[index] and math.min(angles[index]+delta,goals[index])
                    or math.max(angles[index]-delta,goals[index])
                local bind=c.wings.bindRotations[index]
                local basis=EngineClasses.quaternion(EngineClasses.float4(bind.x,bind.y,bind.z,bind.w))
                local offset=Engine.QuaternionAxisAngle(EngineClasses.float3(axis.x,axis.y,axis.z),angle*math.pi/180)
                -- Native Rest animation writes these bones every frame. Compose
                -- once from the pinned bind basis after that job, never from last frame.
                Engine.SetLocalEntityLocalRotation(bone,Engine.QuaternionMultiply(basis,offset))
            end
        end
    end
    if c.exhaust then
        s.exhaust=s.exhaust or {}
        if visible and s.exhaustOn then
            if #s.exhaust==0 then
                for _,bone in ipairs(c.exhaust.bones) do
                    s.exhaust[#s.exhaust+1]={bone=bone,path=c.exhaust.graph.path}
                    -- Source creates a beam inside each of its two emitter iterations.
                    for _=1,c.exhaust.beamInstancesPerBone do
                        s.exhaust[#s.exhaust+1]={bone=bone,path=c.exhaust.beamGraph.path}
                    end
                end
            end
            for _,effect in ipairs(s.exhaust) do DynamicAttach(self,effect) end
        else
            for _,effect in ipairs(s.exhaust) do DynamicStop(effect) end
            s.exhaust={}
        end
    end
    for index=#s.effects,1,-1 do
        local effect=s.effects[index]
        if not visible or now>=effect.expires then
            DynamicStop(effect);table.remove(s.effects,index)
        else DynamicAttach(self,effect) end
    end
end
local DynamicInit,DynamicRender,DynamicDestroy,DynamicDelete=ClientUnit.__init,ClientUnit.RenderUpdateBeams,ClientUnit.OnDestroy,ClientUnit.OnDelete
function ClientUnit:__init(...)
    local result=DynamicInit(self,...)
    local pending=DynamicPending[self.id.index]
    if pending and pending.version<=self.id.version then
        DynamicPending[self.id.index]=nil
        if pending.version==self.id.version then for _,event in pairs(pending.events) do DynamicApply(self,event) end end
    end
    return result
end
function ClientUnit:RenderUpdateBeams(...)
    local result=DynamicRender(self,...);self:SCOUpdateDynamicVisuals();return result
end
function ClientUnit:OnDestroy(...)
    local result=DynamicDestroy(self,...);self:SCOUpdateDynamicVisuals();return result
end
function ClientUnit:OnDelete(...)
    self.scoDynamicDeleted=true;self:SCOUpdateDynamicVisuals()
    local pending=DynamicPending[self.id.index]
    if pending and pending.version<=self.id.version then DynamicPending[self.id.index]=nil end
    return DynamicDelete(self,...)
end
-- Finite, host-timed joint motion applied after native animation transforms.
local ClearancePending={}
local function ClearanceRig(unit)
    local additions=unit.tp and unit.tp.additions
    local posture=additions and additions.scoFactoryPosture
    local config=additions and (additions.scoFactoryEgress or posture)
    return config and config.clearanceRig,posture~=nil
end
local function ClearanceAccept(unit,event)
    if not ClearanceRig(unit) or unit.dead or unit.scoClearanceDeleted then return end
    local previous=unit.scoClearanceEvent
    if not previous or previous.serial<event.serial then unit.scoClearanceEvent=event end
end
local function ClearanceNumber(value,minimum,maximum)
    return type(value)=='number' and value==value and value>=minimum and value<=maximum
end
function _G.SCO_FactoryClearanceEvent(event)
    if type(event)~='table' or type(event.unitID)~='table'
        or not ClearanceNumber(event.serial,1,2147483647) or event.serial~=math.floor(event.serial)
        or not ClearanceNumber(event.time,0,1e12)
        or not ClearanceNumber(event.fromPhase,0,1) or not ClearanceNumber(event.goalPhase,0,1) then return end
    local id=event.unitID
    for _,key in ipairs({'index','version'}) do
        if not ClearanceNumber(id[key],0,4294967295) or id[key]~=math.floor(id[key]) then return end
    end
    local unit=__Entities.Units[id.index]
    if unit and unit.id.version>=id.version then
        if unit.id.version==id.version then ClearanceAccept(unit,event) end
        return
    end
    local now=Engine.GetSimulationTime()
    for index,pending in pairs(ClearancePending) do
        if now-pending.received>10 then ClearancePending[index]=nil end
    end
    local previous=ClearancePending[id.index]
    if not previous or previous.event.unitID.version<id.version
        or previous.event.unitID.version==id.version and previous.event.serial<event.serial then
        ClearancePending[id.index]={event=event,received=now}
    end
end
function ClientUnit:SCOUpdateFactoryClearance()
    local rig,posture=ClearanceRig(self)
    local event=self.scoClearanceEvent
    if not rig or not event or self.dead or self.scoClearanceDeleted or self:IsPlacementGhost()
        or self:IsUpgrading() or self:IsUpgrade() then return end
    local duration=rig.duration*math.abs(event.goalPhase-event.fromPhase)
    local t=duration>0 and math.min(1,math.max(0,Engine.GetSimulationTime()-event.time)/duration) or 1
    local phase=event.fromPhase+(event.goalPhase-event.fromPhase)*t*t*(3-2*t)
    local released=posture and event.goalPhase==0 and t==1
    if released and self.scoClearanceReleasedSerial==event.serial then return end
    for _,spec in ipairs(rig.bones) do
        local bone=self:GetBoneId(spec.boneName)
        if Engine.IsValidLocalID(bone) then
            if not spec.translationOnly then
                local axis=spec.axis
                if type(axis)=='string' then local key=axis;axis={x=0,y=0,z=0};axis[key]=1 end
                local bind=spec.bindRotation
                local basis=EngineClasses.quaternion(EngineClasses.float4(bind.x,bind.y,bind.z,bind.w))
                local offset=Engine.QuaternionAxisAngle(EngineClasses.float3(axis.x,axis.y,axis.z),spec.degrees*phase*math.pi/180)
                Engine.SetLocalEntityLocalRotation(bone,Engine.QuaternionMultiply(basis,offset))
            end
            if spec.translation then
                local bind,delta=spec.bindPosition,spec.translation
                Engine.SetLocalEntityLocalPosition(bone,EngineClasses.float3(bind.x+delta.x*phase,
                    bind.y+delta.y*phase,bind.z+delta.z*phase))
            end
        end
    end
    if released then self.scoClearanceReleasedSerial=event.serial end
end
local ClearanceInit,ClearanceRender,ClearanceDelete=ClientUnit.__init,ClientUnit.RenderUpdateBeams,ClientUnit.OnDelete
function ClientUnit:__init(...)
    local result=ClearanceInit(self,...)
    local pending=ClearancePending[self.id.index]
    if pending and pending.event.unitID.version<=self.id.version then
        ClearancePending[self.id.index]=nil
        if pending.event.unitID.version==self.id.version then ClearanceAccept(self,pending.event) end
    end
    return result
end
function ClientUnit:RenderUpdateBeams(...)
    local result=ClearanceRender(self,...)
    self:SCOUpdateFactoryClearance()
    return result
end
function ClientUnit:OnDelete(...)
    self.scoClearanceDeleted=true
    self.scoClearanceEvent=nil
    local pending=ClearancePending[self.id.index]
    if pending and pending.event.unitID.version<=self.id.version then ClearancePending[self.id.index]=nil end
    return ClearanceDelete(self,...)
end
-- SCOM faction tarmacs 1.0.0
Import("common/systems/scoFactionTarmacs.lua").Install(ClientUnit)
-- Repose the installed rigid Nuke bone after native animation; never add a mesh.
do
    local pending = {}
    local function Integer(value, minimum)
        return type(value) == 'number' and value == math.floor(value) and value >= minimum and value <= 2147483647
    end
    local function Apply(unit, event)
        if unit.tpId ~= 'uss4102' or unit.dead or unit.scoYolonaDeleted then return end
        local previous = unit.scoYolonaMissilePose
        if not previous or event.sequence > previous.sequence then unit.scoYolonaMissilePose = event end
    end
    function _G.SCO_ApplyYolonaMissilePose(value)
        if type(value) ~= 'table' or type(value.unitId) ~= 'table'
            or not Integer(value.unitId.index, 1) or not Integer(value.unitId.version, 0)
            or not Integer(value.sequence, 1) or type(value.visible) ~= 'boolean'
            or type(value.fraction) ~= 'number' or value.fraction ~= value.fraction
            or value.fraction < 0 or value.fraction > 1 then return end
        local event = {unitId = {index = value.unitId.index, version = value.unitId.version},
            sequence = value.sequence, visible = value.visible, fraction = value.fraction}
        local unit = __Entities.Units[event.unitId.index]
        if unit and unit.id.version >= event.unitId.version then
            if unit.id.version == event.unitId.version then
                Apply(unit, event)
                unit:SCOUpdateYolonaMissile()
            end
            return
        end
        local now = Engine.GetSimulationTime()
        for index, entry in pairs(pending) do if now - entry.received > 10 then pending[index] = nil end end
        local old = pending[event.unitId.index]
        if not old or old.event.unitId.version < event.unitId.version
            or old.event.unitId.version == event.unitId.version and old.event.sequence < event.sequence then
            pending[event.unitId.index] = {event = event, received = now}
        end
    end
    function ClientUnit:SCOUpdateYolonaMissile()
        if self.tpId ~= 'uss4102' or self.scoYolonaDeleted then return end
        local c = self.tp and self.tp.additions and self.tp.additions.scoYolonaMissile
        if not c then return end
        local bone = self:GetBoneId(c.bone)
        if not bone or not Engine.IsValidLocalID(bone) then return end
        local pose = self.scoYolonaMissilePose
        local visible = pose and pose.visible and not self.dead and self:IsCompleted()
            and not self:IsPlacementGhost() and self:IsIntelVisionVisible()
        local p = c.position
        Engine.SetLocalEntityLocalPosition(bone,
            EngineClasses.float3(p.x, visible and p.y + c.lift * pose.fraction or -64, p.z))
    end
    local init, render, destroy, delete = ClientUnit.__init, ClientUnit.RenderUpdateBeams,
        ClientUnit.OnDestroy, ClientUnit.OnDelete
    function ClientUnit:__init(...)
        local result = init(self, ...)
        if self.tpId == 'uss4102' then
            local entry = pending[self.id.index]
            if entry and entry.event.unitId.version <= self.id.version then
                pending[self.id.index] = nil
                if entry.event.unitId.version == self.id.version then Apply(self, entry.event) end
            end
            self:SCOUpdateYolonaMissile()
        end
        return result
    end
    function ClientUnit:RenderUpdateBeams(...)
        local result = render(self, ...)
        self:SCOUpdateYolonaMissile()
        return result
    end
    function ClientUnit:OnDestroy(...)
        local result = destroy(self, ...)
        self:SCOUpdateYolonaMissile()
        return result
    end
    function ClientUnit:OnDelete(...)
        if self.tpId == 'uss4102' then
            self.scoYolonaDeleted = true
            local entry = pending[self.id.index]
            if entry and entry.event.unitId.version <= self.id.version then pending[self.id.index] = nil end
        end
        return delete(self, ...)
    end
end
-- Aircraft stored inside Atlantis follow the existing authenticated cargo state.
function ClientUnit:SCOSetAirStorageHidden(hidden)
    self.scoAirStorageHidden = hidden == true
    self:RecalculateIntel(true)
end

local PreviousVision = ClientUnit.IsIntelVisionVisible
function ClientUnit:IsIntelVisionVisible()
    return not self.scoAirStorageHidden and PreviousVision(self)
end

local PreviousSelection = ClientUnit.SetSelectionEnabled
function ClientUnit:SetSelectionEnabled(enabled)
    return PreviousSelection(self, enabled and not self.scoAirStorageHidden)
end

local PreviousIcons = ClientUnit.RecalculateUnitIconState
function ClientUnit:RecalculateUnitIconState()
    PreviousIcons(self)
    if self.scoAirStorageHidden then
        self.icons.StrategicIcon:SetEnabled(false)
        self.icons.RadarIcon:SetEnabled(false)
    end
end

for _, name in ipairs({"OnIntelVision", "OnIntelRadar"}) do
    local previous = ClientUnit[name]
    ClientUnit[name] = function(self, ...)
        if self.scoAirStorageHidden then return self:OnIntelHidden() end
        return previous(self, ...)
    end
end
-- The native AIR-tag audio gate also runs on parked aircraft. HostAirUnit
-- changes the replicated navigation layer on takeoff and completed landing.
local SCO_InterceptorStockSetAudioSourceEmitting = ClientUnit.SetAudioSourceEmitting

function ClientUnit:SetAudioSourceEmitting(source, emitting)
    if self.tpId == 'uea1201' and source == self.motorAudio and emitting then
        local result, layer = Engine.GetMovementNavigationLayer(self.id)
        emitting = result == EngineErrorCode.Success
            and layer == self.tp.general.navigationLayer
            and not self.dead and self:IsCompleted()
    end
    return SCO_InterceptorStockSetAudioSourceEmitting(self, source, emitting)
end

-- FA StructureUnit.LandBuiltHiddenBones hides Floatation on land.
do
local supported = {
    ucs1201 = true, ucs1701 = true, ucs2001 = true, ucs2201 = true,
    ucs2402 = true, ucs2701 = true, ucs3201 = true, ucs3402 = true, ucs3701 = true,
    ues1201 = true, ues1512 = true, ues1612 = true, ues2201 = true,
    ues2402 = true, ues2512 = true, ues3201 = true, ues3512 = true,
    ues5014 = true, ues5023 = true,
    ugs1201 = true, ugs1512 = true, ugs2001 = true, ugs2201 = true,
    ugs2402 = true, ugs2512 = true, ugs3201 = true, ugs3512 = true,
    ugs5002 = true, ugs5015 = true,
}
local hiddenPosition = {x = 0, y = -64, z = 0}

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function disable(unit, reason)
    unit.scoLandFlotation = false
    Engine.Warn("SCOM land flotation: " .. tostring(unit.tpId) .. ": " .. reason)
end

local function initialize(unit)
    -- Structures stay at their build site. Cache the classification and bone;
    -- water units never need a transform override or another terrain query.
    unit.scoLandFlotation = false
    local code, hasWater = Engine.HasWater()
    if code ~= EngineErrorCode.Success then disable(unit, "water query failed"); return end
    if hasWater then
        local levelCode, level = Engine.GetWaterLevel()
        if levelCode ~= EngineErrorCode.Success or not finite(level) then
            disable(unit, "water level unavailable"); return
        end
        local positionCode, position = Engine.GetLocalEntityWorldPosition(unit.localId)
        if positionCode ~= EngineErrorCode.Success or not position
            or not finite(position.x) or not finite(position.y) or not finite(position.z) then
            disable(unit, "build position unavailable"); return
        end
        -- Construction can lower the visual root below the surface. Classify
        -- the terrain at XZ, never the current animated model height.
        local terrainCode, terrain = Engine.SampleTerrainHeight(position)
        if terrainCode ~= EngineErrorCode.Success or not finite(terrain) then
            disable(unit, "terrain height unavailable"); return
        end
        if terrain < level then return end
    end
    local boneCode, bone = Engine.GetLocalBone(unit.localId, "Floatation")
    if boneCode ~= EngineErrorCode.Success or not Engine.IsValidLocalID(bone) then
        disable(unit, "Floatation bone unavailable"); return
    end
    unit.scoLandFlotation = bone
end

local previousRender = ClientUnit.RenderUpdateBeams
function ClientUnit:RenderUpdateBeams(...)
    local result = previousRender(self, ...)
    if self.deleted or self.scoLandFlotation == false then return result end
    if self.scoLandFlotation == nil then
        if not supported[self.tpId] then self.scoLandFlotation = false; return result end
        -- A placement ghost may still move between land and water.
        if self:IsPlacementGhost() then return result end
        initialize(self)
    end
    local bone = self.scoLandFlotation
    if bone then
        -- Native animation/replication owns the normal pose. Reapply only this
        -- cached bone after it runs, including construction and upgrade poses.
        local code = Engine.SetLocalEntityLocalPosition(bone, hiddenPosition)
        if code ~= EngineErrorCode.Success then disable(self, "bone position update failed") end
    end
    return result
end
end
