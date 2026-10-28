-- Base unit class that we're gonna use.
local ClientUnit = Import("client/units/unitsClasses/unitsBaseClass.lua").ClientUnit
local ClientBeamManager = Import("client/entities/beams/clientBeamManager.lua")

local ResourceSpotUtils = Import("common/resourceSpot.lua")

local PlacementLayer = Import("common/layers.lua").PlacementLayer
local PlacementDomain = Import("common/layers.lua").PlacementDomain
local PlacementUtils = Import("common/systems/placementUtils.lua")

------------------
-- Structure class
------------------

---@class ClientStructure: ClientUnit
ClientStructure = Class("Structure", ClientUnit)

function ClientStructure:__init(globalId, localId, armyId, template, progress)
    ClientUnit.__init(self, globalId, localId, armyId, template, progress)

    -- Keep track of adjacent units.
    self.adjacentUnits = {}
    self:CreateTarmac()
end

---@param destroyType DestroyType
function ClientStructure:OnDestroy(destroyType)
    -- Inform all adjacent units that we are dead.
    -- TODO: This will be replaced by the engine call from the building grid
    local units = table.shallowCopy(self.adjacentUnits)
    for _, unit in pairs(units) do
        unit:OnNotAdjacentTo(self)
        self:OnNotAdjacentTo(unit)
    end

    ClientUnit.OnDestroy(self, destroyType)
end

function ClientStructure:OnDelete()
    if self.tarmac then
        self.tarmac:SetLifeTime(300)
    end

    ClientUnit.OnDelete(self)
end

function ClientStructure:OnAdjacentTo(adjacentUnit)
    --Log("Unit: "..self.id.." tpId: "..self.tpId.." is adjacent to: "..adjacentUnit.id.." tpId: "..adjacentUnit.tpId)
    local adjName = self.tp.adjacency
    if not adjName then
        return
    end

    -- TODO: Create Adjacency effect here

    table.insert(self.adjacentUnits, adjacentUnit)
end

function ClientStructure:OnNotAdjacentTo(adjacentUnit)
    --Log("Unit: "..self.id.." tpId: "..self.tpId.." is not adjacent to: "..adjacentUnit.tpId tag: "..adjacentUnit.tpId)
    local adjName = self.tp.adjacency
    if not adjName then
        return
    end

    -- TODO: Remove Adjacency effect here

    table.removeByValue(self.adjacentUnits, adjacentUnit)
end

function ClientStructure:CreateTarmac()
    if PlacementUtils.GetPlacementDomain(self.tp) == PlacementDomain.Water then
        return
    end

    local tarmacs = {
        e = _G.TarmacEDAPrefabID,
        c = _G.TarmacChosenPrefabID,
        s = _G.TarmacChosenPrefabID,
        g = _G.TarmacGuardPrefabID,
    }
    local tarmac = tarmacs[string.sub(self.tpId, 2, 2)]
    if not tarmac then
        return
    end
    -- Supreme Commander Overhaul Structures Cache Patcher 1.6.1
    -- Visual ground decals follow measured art bounds; build reservations remain tp.skirtSize.
    local skirtSize = (self.tp.additions and self.tp.additions.tarmacSize) or self.tp.skirtSize
    
    ---@type Decal
    self.tarmac = self:CreateDecal(tarmac, skirtSize.x, skirtSize.y, 0)
    self.tarmac:SetEnabled(false)
end

---@protected Called whenever the the unit has no source of intel and should be "hidden" to the player.
function ClientStructure:OnIntelHidden()
    ClientUnit.OnIntelHidden(self)

    Engine.SetLocalGridModifierEnabled(self.localId, false)
    
    if self.tarmac then
        self.tarmac:SetEnabled(false)
    end

    if #self.holes > 0 then
        Engine.SetHolesEnabled(self.localId, false)
    end
end


---@protected Called to determine if the grid modifier can be enabled for this structure.
--- Override this function to set a custom condition for enabling the grid modifier.
--- This is because certain structures might have different restrictions for enabling the grid modifier.
--- @return boolean True if the grid modifier can be enabled
function ClientStructure:CanEnableGridModifier()
    return true
end

---@protected Called whenever the source of intel becomes vision.
function ClientStructure:OnIntelVision()
    ClientUnit.OnIntelVision(self)
    
    -- We want to enable the grid modifier if the structure allowes it.
    local canEnableGridModifier = self:CanEnableGridModifier()
    if canEnableGridModifier then
        Engine.SetLocalGridModifierEnabled(self.localId, true)
    end
    
    -- We should not show holes or tarmacs for placement ghosts.
    local isPlacementGhost = self:IsPlacementGhost()
    if self.tarmac then
        self.tarmac:SetEnabled(not isPlacementGhost)
    end

    if #self.holes > 0 then
        Engine.SetHolesEnabled(self.localId, not isPlacementGhost)
    end
end

---@protected Called whenever the source of intel becomes radar.
function ClientStructure:OnIntelRadar()
    ClientUnit.OnIntelRadar(self)

    Engine.SetLocalGridModifierEnabled(self.localId, false)

    if self.tarmac then
        self.tarmac:SetEnabled(false)
    end

    if #self.holes > 0 then
        Engine.SetHolesEnabled(self.localId, false)
    end
end

---@protected Called whenever the source of intel becomes sonar.
function ClientStructure:OnIntelSonar()
    ClientUnit.OnIntelSonar(self)

    Engine.SetLocalGridModifierEnabled(self.localId, false)

    if self.tarmac then
        self.tarmac:SetEnabled(false)
    end

    if #self.holes > 0 then
        Engine.SetHolesEnabled(self.localId, false)
    end
end

------------------------
-- Naval Structure class
------------------------

---@class ClientNavalStructure: ClientStructure
ClientNavalStructure = Class("NavalStructure", ClientStructure)



----------------
-- TechCentre class
----------------

---@class ClientTechCentre: ClientStructure
ClientTechCentre = Class("TechCentre", ClientStructure)



---------------------------
-- Naval TechCentre class
---------------------------

---@class ClientNavalTechCentre: ClientTechCentre
ClientNavalTechCentre = Class("NavalTechCentre", ClientTechCentre)



----------------
-- Storage class
----------------

---@class ClientStorage: ClientStructure
ClientStorage = Class("Storage", ClientStructure)



----------------------------
-- Engineering Station class
----------------------------

---@class ClientEngineeringStation: ClientStructure
ClientEngineeringStation = Class("EngineeringStation", ClientStructure)



----------------------------
-- Engineering Station class
----------------------------

---@class ClientAirfield: ClientStructure
ClientAirfield = Class("Airfield", ClientStructure)



----------------
-- Factory class
----------------

---@class ClientFactory: ClientStructure
ClientFactory = Class("Factory", ClientStructure)

function ClientFactory:CanShowIdleAdornment()
    return true
end

--------------------
-- Air Factory class
--------------------

---@class ClientAirFactory: ClientFactory
ClientAirFactory = Class("AirFactory", ClientFactory)



---------------------
-- Land Factory class
---------------------

---@class ClientLandFactory: ClientFactory
ClientLandFactory = Class("LandFactory", ClientFactory)



----------------------
-- Naval Factory class
----------------------

---@class ClientNavalFactory: ClientFactory
ClientNavalFactory = Class("NavalFactory", ClientFactory)



------------------------
-- Alloy Extractor class
------------------------

---@class ClientAlloyExtractor: ClientStructure
---@field protected resourceSpot ClientAlloyResourceSpot|nil
ClientAlloyExtractor = Class("AlloyExtractor", ClientStructure)

function ClientAlloyExtractor:__init(globalId, localId, armyId, template, progress)
    ClientStructure.__init(self, globalId, localId, armyId, template, progress)

    self.resourceSpot = self:GetClosestResourceSpot()

    if self.resourceSpot then
        self.resourceSpot:AddExtractor(self)
    end
end

---@param destroyType DestroyType
function ClientAlloyExtractor:OnDestroy(destroyType)

    if self.resourceSpot then
        self.resourceSpot:RemoveExtractor(self)
    end

    ClientStructure.OnDestroy(self, destroyType)
end

---comment
---@return ClientAlloyResourceSpot|nil
function ClientAlloyExtractor:GetClosestResourceSpot()
    local gridID = _G.localBuildingPlacementGridID

    local position = self:GetPosition()

    local errorCode, gridCoord = Engine.GetLocalGridCoordFromPosition(gridID, EngineClasses.float2(position.x, position.z))

    if errorCode == EngineErrorCode.Success then
        
        local _, modifiers = Engine.GetLocalGridModifiers(gridID, gridCoord, gridCoord, PlacementLayer.ResourceSpot)

        for _, localId in ipairs(modifiers or {}) do
            for _, resourceSpot in pairs(ResourceSpotUtils.resourceSpots) do
                if resourceSpot.localId.index == localId.index then
                    return resourceSpot
                end
            end
        end
    end

    return nil
end

function ClientAlloyExtractor:OnIntelHidden()
    ClientStructure.OnIntelHidden(self)
    self:DirtyResourceSpot()
end

function ClientAlloyExtractor:CanEnableGridModifier()
    return not self:IsPlacementGhost()
end

function ClientAlloyExtractor:OnIntelVision()
    ClientStructure.OnIntelVision(self)
    self:DirtyResourceSpot()
end

function ClientAlloyExtractor:OnIntelRadar()
    ClientStructure.OnIntelRadar(self)
    self:DirtyResourceSpot()
end

function ClientAlloyExtractor:DirtyResourceSpot()
    if self.resourceSpot then
        self.resourceSpot:RecalculateRendering()
    end
end

-------------------
-- Energy Generator
-------------------

---@class ClientEnergyGenerator: ClientStructure
ClientEnergyGenerator = Class("EnergyGenerator", ClientStructure)



--------------------
-- Mobile Unit class
--------------------

---@class ClientMobileUnit: ClientUnit
ClientMobileUnit = Class("MobileUnit", ClientUnit)

function ClientMobileUnit:OnPromoteToUnit()
    ClientUnit.OnPromoteToUnit(self)
    if self:HasTags(Tags.TECH4) or self:HasTags(Tags.TECH5) then
        Engine.SetLocalGridModifierEnabled(self.localId, true)
    end
end

function ClientMobileUnit:OnCompleted()
    ClientUnit.OnCompleted(self)
    if self:HasTags(Tags.TECH4) or self:HasTags(Tags.TECH5) then
        Engine.SetLocalGridModifierEnabled(self.localId, false)
    end
end

function ClientMobileUnit:IsHighlightable()
    if self:HasTags(Tags.TECH4) or self:HasTags(Tags.TECH5) then
        return ClientUnit.IsHighlightable(self)
    end
    -- Right now we are not allowed to highlight mobile units being built from factories.
    return self:IsCompleted() and ClientUnit.IsHighlightable(self)
end

function ClientMobileUnit:IsSelectable()
    if self:HasTags(Tags.TECH4) or self:HasTags(Tags.TECH5) then
        return ClientUnit.IsSelectable(self)
    end
    -- Right now we are not allowed to select mobile units being built from factories.
    return self:IsCompleted() and ClientUnit.IsSelectable(self)
end

-----------------
-- Air Unit class
-----------------

---@class ClientAirUnit: ClientMobileUnit
ClientAirUnit = Class("AirUnit", ClientMobileUnit)



------------------
-- Land Unit class
------------------

---@class ClientLandUnit: ClientMobileUnit
ClientLandUnit = Class("LandUnit", ClientMobileUnit)



-------------------
-- Naval Unit class
-------------------

---@class ClientNavalUnit: ClientMobileUnit
ClientNavalUnit = Class("NavalUnit", ClientMobileUnit)


---@class ClientSubmarineUnit: ClientNavalUnit
ClientSubmarineUnit = Class("SubmarineUnit", ClientNavalUnit)

function ClientSubmarineUnit:CanSubmerge()
    return true
end



-----------------
-- Engineer class
-----------------

---@class ClientEngineer: ClientUnit
ClientEngineer = Class("Engineer", ClientMobileUnit)

function ClientEngineer:CanShowIdleAdornment()
    return true
end

-----------------
-- Commander class
-----------------

---@class ClientCommander: ClientUnit
ClientCommander = Class("Commander", ClientMobileUnit)

function ClientCommander:__init(globalId, localId, armyId, template, progress)
    ClientMobileUnit.__init(self, globalId, localId, armyId, template, progress)
end

function ClientCommander:CanShowIdleAdornment()
    return true
end

function ClientCommander:DashBehaviorIsValidFor()
    return true
end

function ClientCommander:CreateDeathEffects()
    self:CreateOnDeathEffect()
    self:CreateSmokeEffect()
    self:CreateOnDestroyedAudioEffect()
end

---@param dashTarget float3 The desired end position of the dash.
function ClientCommander:OnStartCommanderDash(dashTarget)
    self.dashBehaviorIsActive = true
    
    -- Begin dash charging.
    local position = self:GetSimPosition()
    local direction = math3D.normalize(math3D.sub(dashTarget, position))
    local rotation = Engine.QuaternionLookRotation(direction, EngineClasses.float3(0, 1, 0))
    -- Start dash effect with proper center height of commander.
    position.y = position.y + self.tp.collisionInfo.collisionSize.y * 0.5
    Engine.InstantiatePrefab(DashChargeEffectPrefab, position, EngineClasses.float3(1.0, 1.0, 1.0), rotation)
end

---comment
---@param finalDashTarget float3 The final end position of the dash after colliding with units.
function ClientCommander:OnExecuteCommanderDash(finalDashTarget)
    
    local dashTarget = finalDashTarget
    local position = self:GetSimPosition()
    local direction = math3D.sub(dashTarget, position)
    local distance = math3D.length(direction)
    direction = math3D.normalize(math3D.sub(dashTarget, position))
    local rotation = Engine.QuaternionLookRotation(direction, EngineClasses.float3(0, 1, 0))
    -- Start dash effect with proper center height of commander.
    position.y = position.y + self.tp.collisionInfo.collisionSize.y * 0.5
    dashTarget.y = position.y + self.tp.collisionInfo.collisionSize.y * 0.5
    Engine.InstantiatePrefab(DashStartEffectPrefab, position, EngineClasses.float3(1.0, 1.0, 1.0), rotation)
    Engine.InstantiatePrefab(DashEndEffectPrefab, dashTarget, EngineClasses.float3(1.0, 1.0, 1.0), rotation)

    local _, dashBeamID = Engine.InstantiatePrefab(DashBeamPrefab, position, EngineClasses.float3(1.0, 1.0, 1.0), rotation)
    ---@cast dashBeamID LocalID
    ---@type ClientBeamPulse
    local dashBeam = ClientBeamManager.CreateBeam(dashBeamID, DashBeamTemplate)

    dashBeam:SetBeamEnabled(true)
    dashBeam:SetBeamEndpoints(position, math3D.add(position, math3D.scale(direction, distance)))
end

function ClientCommander:OnEndCommanderDash()
    self.dashBehaviorIsActive = false
end


-- Supreme Commander Overhaul FA Air Factories 1.0.0
-- Cosmetic construction beams only. Animation remains exclusively on the
-- replicated native host animation path above.
local SCOFaAirFactoryCreateConstructionBeam =
    Import("client/entities/constructionBeam.lua").CreateConstructionBeam
_G.SCOFaAirFactoryBeamPrefabIDs = _G.SCOFaAirFactoryBeamPrefabIDs or {}
local SCOFaAirFactoryBeamPrefabIDs = _G.SCOFaAirFactoryBeamPrefabIDs
local SCOFaAirFactoryBeamGroup = {}
SCOFaAirFactoryBeamGroup.__index = SCOFaAirFactoryBeamGroup

local function SCOFaAirFactoryBeamMaterial(factory)
    -- Supreme Commander Overhaul UEF air-factory beam palette 1.3.0
    if factory:HasTags(Tags.EDA) then
        return "VFX/SCOM/ConstructionBeams/uef.sanmaterial"
    end
    return "VFX/SCOM/ConstructionBeams/cybran.sanmaterial"
end

local function SCOFaAirFactoryGetBeamPrefabID(materialPath)
    local existing = SCOFaAirFactoryBeamPrefabIDs[materialPath]
    if existing then
        return existing
    end
    local prefabName = materialPath == "VFX/SCOM/ConstructionBeams/cybran.sanmaterial"
        and "SupremeCommanderOverhaulFaAirFactoryBeamGuard"
        or "SupremeCommanderOverhaulFaAirFactoryBeamEda"
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
        EngineClasses.float3(0.05, 1, 1),
        ShadowCastingMode.Off,
        EngineClasses.float4(),
        EngineClasses.float4(),
        false
    ))
    local errorCode, prefabID = Engine.CreatePrefab(prefab)
    if errorCode ~= EngineErrorCode.Success then
        Engine.Error("Unable to create the FA air-factory construction-beam prefab.")
        return nil
    end
    SCOFaAirFactoryBeamPrefabIDs[materialPath] = prefabID
    return prefabID
end

function SCOFaAirFactoryBeamGroup:SetTarget(target)
    if self.deleted then return end
    if target == nil or target.localId == nil
        or not Engine.IsValidLocalID(target.localId)
    then
        self:RemoveTarget()
        return
    end
    for _, state in ipairs(self.beams) do state.beam:SetTarget(target) end
    self:RenderUpdate()
end

function SCOFaAirFactoryBeamGroup:RemoveTarget()
    self.enabled = false
    for _, state in ipairs(self.beams) do
        state.beam:SetEnabled(false)
        state.beam:RemoveTarget()
    end
end

function SCOFaAirFactoryBeamGroup:SetEnabled(enabled)
    if self.deleted then return end
    self.enabled = enabled == true
    for _, state in ipairs(self.beams) do
        state.beam:SetEnabled(self.enabled and state.beam.targetUnit ~= nil)
    end
    self:RenderUpdate()
end

function SCOFaAirFactoryBeamGroup:Update()
    -- ClientUnit's simulation-rate BuildThread calls this. Loose visual roots
    -- are updated once in RenderUpdateBeams instead.
end

function SCOFaAirFactoryBeamGroup:RenderUpdate()
    if self.deleted or not self.enabled then return end
    for _, state in ipairs(self.beams) do
        local target = state.beam.targetUnit
        if target ~= nil and target.localId ~= nil
            and Engine.IsValidLocalID(target.localId)
            and Engine.IsValidLocalID(state.rootID)
            and Engine.IsValidLocalID(state.muzzleID)
        then
            Engine.GetLocalEntityWorldPosition(state.muzzleID, state.muzzlePosition)
            Engine.SetLocalEntityLocalPosition(state.rootID, state.muzzlePosition)
            state.beam:Update()
        else
            state.beam:SetEnabled(false)
            state.beam:RemoveTarget()
        end
    end
end

function SCOFaAirFactoryBeamGroup:Delete()
    if self.deleted then return end
    self.deleted = true
    self.enabled = false
    for _, state in ipairs(self.beams) do
        state.beam:SetEnabled(false)
        state.beam:RemoveTarget()
        if Engine.IsValidLocalID(state.rootID) then Engine.DeletePrefabInstance(state.rootID) end
    end
    self.beams = {}
end

local SCOFaAirFactoryClientLifecycle = {}

function SCOFaAirFactoryClientLifecycle.Dispose(factory)
    local group = factory.constructionBeam
    factory.constructionBeam = nil
    factory.constructionBeamEnabled = false
    if group and group.Delete then group:Delete() end
end

function SCOFaAirFactoryClientLifecycle.Prepare(factory)
    SCOFaAirFactoryClientLifecycle.Dispose(factory)
    local bones = factory.tp.additions and factory.tp.additions.buildBeamBones
    if not bones or #bones == 0 then return end
    local prefabID = SCOFaAirFactoryGetBeamPrefabID(SCOFaAirFactoryBeamMaterial(factory))
    if not prefabID then return end
    local group = setmetatable({ beams = {}, deleted = false, enabled = false }, SCOFaAirFactoryBeamGroup)
    local initialPosition = factory:GetPosition()
    for _, boneName in ipairs(bones) do
        local muzzleID = factory:GetBoneId(boneName)
        if not Engine.IsValidLocalID(muzzleID) then
            group:Delete()
            Engine.Error("FA air factory is missing build-beam bone " .. boneName .. ".")
            return
        end
        local errorCode, rootID = Engine.InstantiatePrefab(
            prefabID, initialPosition, EngineClasses.float3(1, 1, 1), GetIdentityQuaternion())
        if errorCode ~= EngineErrorCode.Success or not Engine.IsValidLocalID(rootID) then
            if Engine.IsValidLocalID(rootID) then Engine.DeletePrefabInstance(rootID) end
            group:Delete()
            Engine.Error("Unable to instantiate an FA air-factory construction beam.")
            return
        end
        table.insert(group.beams, {
            rootID = rootID,
            muzzleID = muzzleID,
            muzzlePosition = EngineClasses.float3(),
            beam = SCOFaAirFactoryCreateConstructionBeam(rootID),
        })
    end
    factory.constructionBeam = group
end

function SCOFaAirFactoryClientLifecycle.Render(factory)
    local group = factory.constructionBeam
    if group and group.RenderUpdate then group:RenderUpdate() end
end

_G.SCOFaAirFactoryClientLifecycle = SCOFaAirFactoryClientLifecycle

-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0

-- Supreme Commander Overhaul commander enhancements 1.0.0
-- Reapply the upgrade-bone projection after Sanctuary evaluates commander
-- animations. The listener owns all faction/state policy; this hook only
-- supplies the render-order boundary that a skinned bone transform requires.
local SCOCommanderEnhancementVisualEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderEnhancementVisualMarker = rawget(
    SCOCommanderEnhancementVisualEnvironment,
    "SCO_CommanderEnhancementClientVisualInstalled")
if SCOCommanderEnhancementVisualMarker ~= nil
    and SCOCommanderEnhancementVisualMarker ~= "1.2.0"
then
    error("Unsupported SCOM commander-enhancement client-visual marker "
        .. tostring(SCOCommanderEnhancementVisualMarker))
end
if SCOCommanderEnhancementVisualMarker == nil then
    if type(ClientCommander) ~= "table"
        or type(ClientCommander.RenderUpdateBeams) ~= "function"
        or type(ClientCommander.Delete) ~= "function"
    then
        error("SCOM commander enhancements could not resolve ClientCommander")
    end

    local SCOStockCommanderRenderUpdateBeams =
        ClientCommander.RenderUpdateBeams
    function ClientCommander:RenderUpdateBeams()
        SCOStockCommanderRenderUpdateBeams(self)
        local refresh = rawget(_G, "SCO_RefreshCommanderEnhancementVisuals")
        if type(refresh) == "function" then refresh(self) end
        local refreshPods = rawget(_G, "SCO_RefreshCommanderPodDockVisuals")
        if type(refreshPods) == "function" then refreshPods(self) end
    end

    -- DeleteUnit removes the commander from __Entities.Units immediately, but
    -- ClientUnit:Delete waits until tick end before deleting its interpolated
    -- renderer. Keep that retiring renderer in this tiny side registry so the
    -- animation pass cannot expose uninstalled upgrade islands during the gap.
    local SCORetiringCommanders = {}
    local SCOStockCommanderDelete = ClientCommander.Delete
    function ClientCommander:Delete(...)
        local refresh = rawget(_G, "SCO_RefreshCommanderEnhancementVisuals")
        if type(refresh) == "function" then
            local ok, refreshed = pcall(refresh, self)
            if ok and refreshed == true then
                SCORetiringCommanders[self] = true
            end
        end
        return SCOStockCommanderDelete(self, ...)
    end

    local occupiedRetirementRefresh = rawget(
        _G, "SCO_RefreshRetiringCommanderEnhancementVisuals")
    if occupiedRetirementRefresh ~= nil then
        error("SCOM retiring commander visual refresh is occupied")
    end
    rawset(_G, "SCO_RefreshRetiringCommanderEnhancementVisuals", function()
        local refresh = rawget(_G, "SCO_RefreshCommanderEnhancementVisuals")
        for unit in pairs(SCORetiringCommanders) do
            if type(unit) ~= "table" or unit.deleted == true then
                SCORetiringCommanders[unit] = nil
            elseif type(refresh) == "function" then
                pcall(refresh, unit)
            end
        end
    end)

    rawset(
        SCOCommanderEnhancementVisualEnvironment,
        "SCO_CommanderEnhancementClientVisualInstalled",
        "1.2.0")
end

-- Supreme Commander Overhaul commander ability visuals 1.2.0
-- Intended target: append to client/units/unitsClasses/unitsDefault.lua after
-- commander_enhancement_client_visual_appendix.lua. Gameplay authority and
-- effect assets remain outside this client-only presentation boundary.
local SCOCommanderAbilityVisualEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderAbilityVisualMarker = rawget(
    SCOCommanderAbilityVisualEnvironment,
    "SCO_CommanderAbilityClientVisualInstalled")
if SCOCommanderAbilityVisualMarker ~= nil
    and SCOCommanderAbilityVisualMarker ~= "1.2.0"
then
    error("Unsupported SCOM commander-ability client-visual marker "
        .. tostring(SCOCommanderAbilityVisualMarker))
end
if SCOCommanderAbilityVisualMarker == nil then
    if rawget(
            SCOCommanderAbilityVisualEnvironment,
            "SCO_CommanderEnhancementClientVisualInstalled") ~= "1.2.0"
        or type(ClientCommander) ~= "table"
        or type(ClientCommander.RenderUpdateBeams) ~= "function"
        or type(ClientCommander.RecalculatePersistentEffectsState) ~= "function"
        or type(ClientCommander.OnDestroy) ~= "function"
        or type(Engine) ~= "table"
        or type(Engine.InstantiatePrefab) ~= "function"
        or type(Engine.SetParticleCanEmit) ~= "function"
        or type(Engine.GetSimulationTick) ~= "function"
        or type(Engine.GetSimulationTime) ~= "function"
        or type(Engine.GetLocalBone) ~= "function"
        or type(Engine.SetLocalEntityLocalPosition) ~= "function"
        or type(EngineClasses) ~= "table"
        or type(EngineClasses.float3) ~= "function"
        or type(Constants) ~= "table"
        or type(Constants.TickTimeStep) ~= "number"
        or Constants.TickTimeStep <= 0
        or type(GetFocusArmy) ~= "function"
        or type(GetIdentityQuaternion) ~= "function"
        or type(Import) ~= "function"
    then
        error("SCOM commander ability visuals require the commander visual hook")
    end

    local SCOSupportedCommanders = {
        uel0000 = true,
        ucl0000 = true,
        ugl0000 = true,
        usl0000 = true,
    }
    local SCOOneScale = EngineClasses.float3(1, 1, 1)
    local SCOUp = EngineClasses.float3(0, 1, 0)
    -- Recovered from UEL0001_A003.sca. The authored clip moves only the
    -- Back_Upgrade_B02 door over two seconds and then holds for 4/3 seconds.
    local SCOMissileDoorClosedPosition = {
        x = 0.00141657982,
        y = 0.04973999783,
        z = 0.12608620524,
    }
    local SCOMissileDoorTravel = 0.1771047831

    local function SCOFinite(value)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
    end

    local function SCOInteger(value, minimum, maximum)
        return SCOFinite(value)
            and value == math.floor(value)
            and value >= minimum
            and value <= maximum
    end

    local function SCOGlobalId(value)
        if type(value) ~= "table"
            or not SCOInteger(value.index, 1, 2147483647)
            or not SCOInteger(value.version, 0, 2147483647)
        then
            return nil
        end
        return { index = value.index, version = value.version }
    end

    local function SCOPosition(value)
        if type(value) ~= "table"
            or not SCOFinite(value.x)
            or not SCOFinite(value.y)
            or not SCOFinite(value.z)
        then
            return nil
        end
        return { x = value.x, y = value.y, z = value.z }
    end

    local function SCOUnitTpId(unit)
        return unit and (unit.tpId
            or (unit.tp and unit.tp.general and unit.tp.general.tpId))
    end

    local function SCOUnitMatches(unit, unitId)
        return unit ~= nil
            and unit.id ~= nil
            and unit.id.index == unitId.index
            and unit.id.version == unitId.version
            and unit.dead ~= true
            and SCOSupportedCommanders[SCOUnitTpId(unit)] == true
    end

    local function SCOStateMatchesUnit(state, unit)
        return type(state) == "table"
            and type(state.unitId) == "table"
            and state.unitId.index == unit.id.index
            and state.unitId.version == unit.id.version
            and type(state.installed) == "table"
    end

    local function SCOVisualState(unit)
        local ownerState = unit.scoCommanderEnhancementState
        if SCOStateMatchesUnit(ownerState, unit) then return ownerState end
        local peerState = unit.scoCommanderEnhancementVisualState
        if SCOStateMatchesUnit(peerState, unit) then return peerState end
        return nil
    end

    local function SCOValidLocalId(localId)
        if type(localId) ~= "table" then return false end
        if type(Engine.IsValidLocalID) ~= "function" then
            return SCOInteger(localId.index, 1, 2147483647)
        end
        local checked, valid = pcall(Engine.IsValidLocalID, localId)
        return checked and valid == true
    end

    local function SCOEngineCallSucceeded(errorCode)
        local successCode = type(EngineErrorCode) == "table"
            and EngineErrorCode.Success or nil
        return successCode == nil
            or errorCode == nil
            or errorCode == successCode
            or errorCode == 0
    end

    -- particleTemplateLoader writes each deterministic effectEntityName back
    -- onto the real visuals.effectsPersistent descriptor. Resolve that exact
    -- descriptor rather than relying on a parallel additions-only copy.
    local function SCOConditionalEffectEntityName(unit, key, marker)
        local additions = unit.tp and unit.tp.additions
        local effects = additions and additions.scoCommanderAbilityEffects
        local descriptor = type(effects) == "table" and effects[key]
        if type(descriptor) == "string" then return descriptor end
        if type(descriptor) == "table" then
            local name = descriptor.effectEntityName or descriptor.entityName
            if type(name) == "string" and name ~= "" then return name end
        end
        local visuals = unit.tp and unit.tp.visuals
        local persistent = visuals and visuals.effectsPersistent
        if type(persistent) ~= "table" then return nil end
        for _, effect in ipairs(persistent) do
            if type(effect) == "table"
                and effect.scoCommanderConditionalEffect == marker
            then
                local name = effect.effectEntityName or effect.entityName
                if type(name) == "string" and name ~= "" then return name end
            end
        end
        return nil
    end

    local function SCOCloakEffectEntityName(unit)
        return SCOConditionalEffectEntityName(
            unit, "cloak", "CybranCloakAura")
    end

    local function SCOResolveCloakEffect(unit)
        local entityName = SCOCloakEffectEntityName(unit)
        if type(entityName) ~= "string" or entityName == "" then return nil end
        if unit.scoCommanderAbilityCloakEffectEntityName == entityName
            and SCOValidLocalId(unit.scoCommanderAbilityCloakEffectLocalId)
        then
            return unit.scoCommanderAbilityCloakEffectLocalId
        end
        local ok, localId = pcall(unit.GetBoneId, unit, entityName)
        if not ok or not SCOValidLocalId(localId) then return nil end
        unit.scoCommanderAbilityCloakEffectEntityName = entityName
        unit.scoCommanderAbilityCloakEffectLocalId = localId
        unit.scoCommanderAbilityCloakEmitting = nil
        return localId
    end

    local function SCOSetCloakEffect(unit, enabled)
        local localId = SCOResolveCloakEffect(unit)
        if localId == nil then return false end
        if unit.scoCommanderAbilityCloakEmitting == enabled then return true end
        local ok, errorCode = pcall(
            Engine.SetParticleCanEmit,
            localId,
            enabled)
        if not ok or not SCOEngineCallSucceeded(errorCode) then return false end
        unit.scoCommanderAbilityCloakEmitting = enabled
        return true
    end

    local function SCOAuraRadius(state, unit)
        if SCOUnitTpId(unit) ~= "usl0000" or state == nil then return nil end
        if state.installed.AdvancedRegenAura == true then return 25 end
        if state.installed.RegenAura == true then return 15 end
        return nil
    end

    local function SCOCreateRestorationRing(unit, radius)
        -- Sanctuary has no runtime particle tint API. Use a thin, otherwise
        -- unused ring material only for the focused Seraphim commander, and
        -- never take ownership of a ring already declared by the template.
        if type(RangeRingMaterial) ~= "table"
            or RangeRingMaterial.AttackAntiNavy == nil
            or (type(unit.rangeRings) == "table"
                and unit.rangeRings[RangeRingMaterial.AttackAntiNavy] ~= nil)
        then
            return nil
        end
        local ok, module = pcall(Import, "client/entities/rangeRing.lua")
        if not ok
            or type(module) ~= "table"
            or type(module.CreateRangeRing) ~= "function"
        then
            return nil
        end
        local created, ring = pcall(
            module.CreateRangeRing,
            unit.localId,
            RangeRingMaterial.AttackAntiNavy,
            {
                outerRadius = radius,
                innerRadius = math.max(0, radius - 0.35),
            })
        if not created or type(ring) ~= "table" then return nil end
        unit.scoCommanderAbilityRestorationRing = ring
        return ring
    end

    local function SCOSetRestorationRing(unit, state)
        local radius = SCOAuraRadius(state, unit)
        local visible = radius ~= nil
            and unit.dead ~= true
            and unit.armyId == GetFocusArmy()
            and type(unit.IsIntelVisionVisible) == "function"
            and unit:IsIntelVisionVisible() == true
        local ring = unit.scoCommanderAbilityRestorationRing
        if ring == nil and visible then
            ring = SCOCreateRestorationRing(unit, radius)
        end
        if type(ring) ~= "table" then return false end
        if visible then
            if type(ring.SetOuterRadius) == "function" then
                pcall(ring.SetOuterRadius, ring, radius)
            end
            if type(ring.SetInnerRadius) == "function" then
                pcall(ring.SetInnerRadius, ring, math.max(0, radius - 0.35))
            end
        end
        if unit.scoCommanderAbilityRestorationRingEnabled ~= visible
            and type(ring.SetEnabled) == "function"
        then
            local ok = pcall(ring.SetEnabled, ring, visible)
            if ok then
                unit.scoCommanderAbilityRestorationRingEnabled = visible
            end
        end
        return true
    end

    local function SCOCurrentSimulationTick()
        local timeOk, simulationTime = pcall(Engine.GetSimulationTime)
        if timeOk and SCOFinite(simulationTime) and simulationTime >= 0 then
            return simulationTime / Constants.TickTimeStep
        end
        local tickOk, simulationTick = pcall(Engine.GetSimulationTick)
        if tickOk and SCOInteger(simulationTick, 0, 2147483647) then
            return simulationTick
        end
        return nil
    end

    local function SCOSmoothStep(value)
        local clamped = math.max(0, math.min(1, value))
        return clamped * clamped * (3 - 2 * clamped)
    end

    local function SCOUpdateMissileDoorAmount(unit, nowTick)
        local amount = SCOFinite(unit.scoCommanderMissileDoorAmount)
            and math.max(0, math.min(1, unit.scoCommanderMissileDoorAmount))
            or 0
        local motion = unit.scoCommanderMissileDoorMotion
        if type(motion) ~= "table" or not SCOFinite(nowTick) then
            return amount
        end

        if motion.phase == "open" then
            amount = 1
        elseif motion.phase == "opening" then
            local duration = motion.durationTicks * (1 - motion.from)
            if duration <= 0 then
                amount = 1
                motion.phase = "open"
            else
                local progress = (nowTick - motion.startTick) / duration
                amount = motion.from
                    + (1 - motion.from) * SCOSmoothStep(progress)
                if progress >= 1 then
                    amount = 1
                    motion.phase = "open"
                end
            end
        elseif motion.phase == "closing" then
            local elapsed = nowTick - motion.startTick - motion.holdTicks
            local duration = motion.durationTicks * motion.from
            if elapsed <= 0 then
                amount = motion.from
            elseif duration <= 0 then
                amount = 0
                unit.scoCommanderMissileDoorMotion = nil
            else
                local progress = elapsed / duration
                amount = motion.from * (1 - SCOSmoothStep(progress))
                if progress >= 1 then
                    amount = 0
                    unit.scoCommanderMissileDoorMotion = nil
                end
            end
        end
        unit.scoCommanderMissileDoorAmount = amount
        return amount
    end

    local function SCOUefBackIsVisible(unit)
        local desired = unit.scoCommanderEnhancementDesiredVisualBones
        if type(desired) == "table" then
            return desired.Back_Upgrade_B01 == true
        end
        local state = SCOVisualState(unit)
        if type(state) == "table" and type(state.slots) == "table" then
            return state.slots.Back ~= nil
        end
        return nil
    end

    local function SCOResolveMissileDoorBone(unit)
        local boneId = unit.scoCommanderMissileDoorBoneId
        if SCOValidLocalId(boneId) then return boneId end
        unit.scoCommanderMissileDoorBoneId = nil
        if type(unit.localId) ~= "table" then return nil end
        local ok, errorCode, resolved = pcall(
            Engine.GetLocalBone,
            unit.localId,
            "Back_Upgrade_B02")
        if not ok
            or not SCOEngineCallSucceeded(errorCode)
            or not SCOValidLocalId(resolved)
        then
            return nil
        end
        unit.scoCommanderMissileDoorBoneId = resolved
        return resolved
    end

    local function SCOApplyUefMissileDoor(unit)
        if SCOUnitTpId(unit) ~= "uel0000" then return false end
        local visible = SCOUefBackIsVisible(unit)
        if visible == nil then return false end
        if not visible then
            unit.scoCommanderMissileDoorMotion = nil
            unit.scoCommanderMissileDoorAmount = 0
            return false
        end
        local nowTick = SCOCurrentSimulationTick()
        if nowTick == nil then return false end
        local amount = SCOUpdateMissileDoorAmount(unit, nowTick)
        local boneId = SCOResolveMissileDoorBone(unit)
        if boneId == nil then return false end
        local ok, errorCode = pcall(
            Engine.SetLocalEntityLocalPosition,
            boneId,
            EngineClasses.float3(
                SCOMissileDoorClosedPosition.x,
                SCOMissileDoorClosedPosition.y,
                SCOMissileDoorClosedPosition.z
                    + SCOMissileDoorTravel * amount))
        return ok and SCOEngineCallSucceeded(errorCode)
    end

    local function SCOStartMissileDoorMotion(unit, event)
        local nowTick = SCOCurrentSimulationTick()
        if nowTick == nil then return false end
        local amount = SCOUpdateMissileDoorAmount(unit, nowTick)
        if event.kind == "MissileDoorOpen" then
            unit.scoCommanderMissileDoorMotion = {
                phase = "opening",
                startTick = event.phaseStartTick,
                durationTicks = event.durationTicks,
                holdTicks = 0,
                from = amount,
            }
        else
            unit.scoCommanderMissileDoorMotion = {
                phase = "closing",
                startTick = event.phaseStartTick,
                durationTicks = event.durationTicks,
                holdTicks = event.holdTicks,
                from = amount,
            }
        end
        SCOApplyUefMissileDoor(unit)
        return true
    end

    local SCORefreshTeleportCharge
    local function SCORefreshCommanderAbilityVisuals(unit)
        if type(unit) ~= "table"
            or unit.id == nil
            or not SCOSupportedCommanders[SCOUnitTpId(unit)]
        then
            return false
        end
        local state = SCOVisualState(unit)
        local cloakEnabled = state ~= nil
            and (state.installed.StealthGenerator == true
                or state.installed.CloakingGenerator == true)
            and type(state.abilities) == "table"
            and state.abilities.cloakAura == true
            and unit.dead ~= true
            and type(unit.IsIntelVisionVisible) == "function"
            and unit:IsIntelVisionVisible() == true
        SCOSetCloakEffect(unit, cloakEnabled)
        SCOSetRestorationRing(unit, state)
        SCOApplyUefMissileDoor(unit)
        SCORefreshTeleportCharge(unit)
        return true
    end

    local function SCOCenteredPosition(unit, rootPosition)
        local position = SCOPosition(rootPosition)
        if position == nil then return nil end
        local collision = unit.tp and unit.tp.collisionInfo or {}
        local offset = collision.centerOffset or {}
        local localOffset = EngineClasses.float3(
            SCOFinite(offset.x) and offset.x or 0,
            SCOFinite(offset.y) and offset.y
                or ((collision.collisionSize and collision.collisionSize.y or 0) * 0.5),
            SCOFinite(offset.z) and offset.z or 0)
        local rotatedOffset = localOffset
        if type(unit.GetSimOrientation) == "function"
            and type(Engine.QuaternionRotateVector) == "function"
        then
            local orientationOk, orientation = pcall(unit.GetSimOrientation, unit)
            if orientationOk and type(orientation) == "table" then
                local rotatedOk, rotated = pcall(
                    Engine.QuaternionRotateVector,
                    orientation,
                    localOffset)
                if rotatedOk and type(rotated) == "table" then
                    rotatedOffset = rotated
                end
            end
        end
        return EngineClasses.float3(
            position.x + rotatedOffset.x,
            position.y + rotatedOffset.y,
            position.z + rotatedOffset.z)
    end

    local function SCOLookRotation(unit, source, destination)
        local direction = EngineClasses.float3(
            destination.x - source.x,
            0,
            destination.z - source.z)
        local magnitudeSquared = direction.x * direction.x
            + direction.z * direction.z
        if magnitudeSquared <= 0.000001 then
            if type(unit.GetSimOrientation) == "function" then
                local ok, orientation = pcall(unit.GetSimOrientation, unit)
                if ok and type(orientation) == "table" then return orientation end
            end
            return GetIdentityQuaternion()
        end
        if type(Engine.QuaternionLookRotationSafe) == "function" then
            return Engine.QuaternionLookRotationSafe(direction, SCOUp)
        end
        local inverseMagnitude = 1 / math.sqrt(magnitudeSquared)
        direction.x = direction.x * inverseMagnitude
        direction.z = direction.z * inverseMagnitude
        return Engine.QuaternionLookRotation(direction, SCOUp)
    end

    local function SCOInstantiate(prefabId, position, rotation)
        if prefabId == nil then return false end
        local called, errorCode, localId = pcall(
            Engine.InstantiatePrefab,
            prefabId,
            position,
            SCOOneScale,
            rotation)
        if not called then return false end
        return SCOEngineCallSucceeded(errorCode), localId
    end

    local function SCOClearTeleportCharge(unit)
        for _, effect in ipairs(unit.scoCommanderTeleportChargeEffects or {}) do
            if SCOValidLocalId(effect.id) then
                Engine.DeletePrefabInstance(effect.id)
            end
        end
        unit.scoCommanderTeleportChargeEffects = nil
        unit.scoCommanderTeleportChargeNextTime = nil
        unit.scoCommanderTeleportChargeSource = nil
        unit.scoCommanderTeleportChargeRotation = nil
        unit.scoCommanderAbilityTeleportCharging = false
    end

    SCORefreshTeleportCharge = function(unit)
        if unit.dead then SCOClearTeleportCharge(unit); return end
        if not unit.scoCommanderAbilityTeleportCharging then return end
        local now = Engine.GetSimulationTime()
        local rootPosition = unit.scoCommanderTeleportChargeSource
        if type(unit.GetSimPosition) == "function" then
            rootPosition = unit:GetSimPosition()
        end
        local position = SCOCenteredPosition(unit, rootPosition)
        if not SCOFinite(now) or position == nil then return end
        local effects = unit.scoCommanderTeleportChargeEffects or {}
        local active = {}
        for _, effect in ipairs(effects) do
            if SCOValidLocalId(effect.id) then
                if now - effect.started >= 5 then
                    Engine.DeletePrefabInstance(effect.id)
                else
                    Engine.SetLocalEntityLocalPosition(effect.id, position)
                    active[#active + 1] = effect
                end
            end
        end
        unit.scoCommanderTeleportChargeEffects = active
        if unit.scoCommanderTeleportChargeNextTime
            and now < unit.scoCommanderTeleportChargeNextTime then return true end
        -- The native charge flare lasts one second and does not loop. Refresh
        -- it on simulation time until the host confirms relocation or cancel.
        local ok, id = SCOInstantiate(DashChargeEffectPrefab, position,
            unit.scoCommanderTeleportChargeRotation)
        if ok and SCOValidLocalId(id) then
            active[#active + 1] = { id = id, started = now }
        end
        unit.scoCommanderTeleportChargeNextTime = now + 1
        return ok
    end

    local function SCOCanonicalVisualEvent(value)
        if type(value) ~= "table"
            or value.version ~= "1.1.0"
            or (value.kind ~= "TeleportCharge"
                and value.kind ~= "TeleportExecute"
                and value.kind ~= "TeleportCancel"
                and value.kind ~= "MissileDoorOpen"
                and value.kind ~= "MissileDoorClose"
                and value.kind ~= "MissileDoorCancel")
            or not SCOInteger(value.sequence, 0, 2147483647)
        then
            return nil
        end
        local unitId = SCOGlobalId(value.unitId)
        if unitId == nil then return nil end
        local source = nil
        local destination = nil
        local missileDoor = value.kind == "MissileDoorOpen"
            or value.kind == "MissileDoorClose"
            or value.kind == "MissileDoorCancel"
        if value.kind == "TeleportCharge" or value.kind == "TeleportExecute" then
            source = SCOPosition(value.source)
            destination = SCOPosition(value.destination)
            if source == nil or destination == nil then return nil end
        elseif missileDoor
            and ((value.profileId ~= "uefTactical"
                    and value.profileId ~= "uefBilly")
                or not SCOInteger(value.phaseStartTick, 0, 2147483647)
                or not SCOInteger(value.durationTicks, 1, 100)
                or not SCOInteger(value.holdTicks, 0, 100))
        then
            return nil
        end
        return {
            version = "1.1.0",
            kind = value.kind,
            sequence = value.sequence,
            unitId = unitId,
            source = source,
            destination = destination,
            profileId = missileDoor and value.profileId or nil,
            phaseStartTick = missileDoor and value.phaseStartTick or nil,
            durationTicks = missileDoor and value.durationTicks or nil,
            holdTicks = missileDoor and value.holdTicks or nil,
        }
    end

    local function SCOReceiveCommanderAbilityVisualEvent(value)
        local event = SCOCanonicalVisualEvent(value)
        if event == nil then return false end
        local unit = __Entities
            and __Entities.Units
            and __Entities.Units[event.unitId.index]
        if not SCOUnitMatches(unit, event.unitId) then return false end
        local missileDoor = event.kind == "MissileDoorOpen"
            or event.kind == "MissileDoorClose"
            or event.kind == "MissileDoorCancel"
        if missileDoor and SCOUnitTpId(unit) ~= "uel0000" then return false end
        local previousSequence = unit.scoCommanderAbilityVisualSequence
        if SCOInteger(previousSequence, 0, 2147483647)
            and previousSequence >= event.sequence
        then
            return false
        end
        unit.scoCommanderAbilityVisualSequence = event.sequence

        if missileDoor then
            return SCOStartMissileDoorMotion(unit, event)
        end

        if event.kind == "TeleportCancel" then
            SCOClearTeleportCharge(unit)
            return true
        end
        local source = SCOCenteredPosition(unit, event.source)
        local destination = SCOCenteredPosition(unit, event.destination)
        if source == nil or destination == nil then return false end
        local rotation = SCOLookRotation(unit, source, destination)
        if event.kind == "TeleportCharge" then
            SCOClearTeleportCharge(unit)
            unit.scoCommanderAbilityTeleportCharging = true
            unit.scoCommanderTeleportChargeSource = event.source
            unit.scoCommanderTeleportChargeRotation = rotation
            return SCORefreshTeleportCharge(unit)
        end

        SCOClearTeleportCharge(unit)
        local departed = SCOInstantiate(DashStartEffectPrefab, source, rotation)
        local arrived = SCOInstantiate(DashEndEffectPrefab, destination, rotation)
        return departed and arrived
    end

    local function SCOInstallDispatcher(name, handlerName, handler)
        local dispatcher = rawget(_G, name)
        if dispatcher ~= nil and type(dispatcher) ~= "function" then
            error("SCOM commander ability dispatcher is occupied: " .. name)
        end
        if dispatcher == nil then
            dispatcher = function(...)
                local current = rawget(_G, handlerName)
                if type(current) ~= "function" then return false end
                return current(...)
            end
            rawset(_G, name, dispatcher)
        end
        rawset(_G, handlerName, handler)
    end

    SCOInstallDispatcher(
        "SCO_RefreshCommanderAbilityVisuals",
        "SCO_CommanderAbilityVisualRefreshHandler",
        SCORefreshCommanderAbilityVisuals)
    SCOInstallDispatcher(
        "SCO_CommanderAbilityVisualEvent",
        "SCO_CommanderAbilityVisualEventHandler",
        SCOReceiveCommanderAbilityVisualEvent)

    local SCOPreviousRenderUpdateBeams = ClientCommander.RenderUpdateBeams
    function ClientCommander:RenderUpdateBeams()
        SCOPreviousRenderUpdateBeams(self)
        local refresh = rawget(_G, "SCO_RefreshCommanderAbilityVisuals")
        if type(refresh) == "function" then refresh(self) end
    end

    local SCOPreviousPersistentEffectsState =
        ClientCommander.RecalculatePersistentEffectsState
    function ClientCommander:RecalculatePersistentEffectsState()
        SCOPreviousPersistentEffectsState(self)
        local refresh = rawget(_G, "SCO_RefreshCommanderAbilityVisuals")
        if type(refresh) == "function" then refresh(self) end
    end

    local function SCOCleanupCommanderAbilityVisuals(unit)
        SCOSetCloakEffect(unit, false)
        local ring = unit.scoCommanderAbilityRestorationRing
        if type(ring) == "table" and type(ring.Delete) == "function" then
            pcall(ring.Delete, ring)
        end
        unit.scoCommanderAbilityRestorationRing = nil
        unit.scoCommanderAbilityRestorationRingEnabled = nil
        SCOClearTeleportCharge(unit)
        unit.scoCommanderMissileDoorMotion = nil
        unit.scoCommanderMissileDoorAmount = nil
        unit.scoCommanderMissileDoorBoneId = nil
    end

    local SCOPreviousCommanderOnDestroy = ClientCommander.OnDestroy
    function ClientCommander:OnDestroy(destroyType)
        SCOCleanupCommanderAbilityVisuals(self)
        return SCOPreviousCommanderOnDestroy(self, destroyType)
    end

    rawset(
        SCOCommanderAbilityVisualEnvironment,
        "SCO_CommanderAbilityClientVisualInstalled",
        "1.2.0")
end
