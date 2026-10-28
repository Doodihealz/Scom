--- This file contains default EDA units classes.

-- Default EDA units classes definitions
local unitsDefault = Import("client/units/unitsClasses/unitsDefault.lua")
Structure = unitsDefault.ClientStructure
TechCentre = unitsDefault.ClientTechCentre
NavalStructure = unitsDefault.ClientNavalStructure
NavalTechCentre = unitsDefault.ClientNavalTechCentre
EngineeringStation = unitsDefault.ClientEngineeringStation
Storage = unitsDefault.ClientStorage
AirFactory = unitsDefault.ClientAirFactory
LandFactory = unitsDefault.ClientLandFactory
NavalFactory = unitsDefault.ClientNavalFactory
AlloyExtractor = unitsDefault.ClientAlloyExtractor
EnergyGenerator = unitsDefault.ClientEnergyGenerator
MobileUnit = unitsDefault.ClientMobileUnit
AirUnit = unitsDefault.ClientAirUnit
LandUnit = unitsDefault.ClientLandUnit
NavalUnit = unitsDefault.ClientNavalUnit
Engineer = unitsDefault.ClientEngineer
Submarine = unitsDefault.ClientSubmarineUnit
Commander = unitsDefault.ClientCommander



----------------------
-- EDA Structure class
----------------------
ClientEDAStructure = Class("EDAStructure", Structure)



-------------------------------
-- EDA Naval Structure class
-------------------------------
ClientEDANavalStructure = Class("EDANavalStructure", NavalStructure)



----------------------
-- EDA Structure class
----------------------
ClientEDATechCentre = Class("EDATechCentre", TechCentre)



--------------------------------
-- EDA Naval TechCentre class
--------------------------------
ClientEDANavalTechCentre = Class("EDANavalTechCentre", NavalTechCentre)



--------------------------------
-- EDA Engineering Station class
--------------------------------
ClientEDAEngineeringStation = Class("EDAEngineeringStation", EngineeringStation)



--------------------
-- EDA Storage class
--------------------
ClientEDAStorage = Class("EDAStorage", Storage)



------------------------
-- EDA Air Factory class
------------------------
ClientEDAAirFactory = Class("EDAAirFactory", AirFactory)



-------------------------
-- EDA Land Factory class
-------------------------
ClientEDALandFactory = Class("EDALandFactory", LandFactory)



--------------------------
-- EDA Naval Factory class
--------------------------
ClientEDANavalFactory = Class("EDANavalFactory", NavalFactory)



----------------------
-- EDA Alloy Extractor
----------------------
ClientEDAAlloyExtractor = Class("EDAAlloyExtractor", AlloyExtractor)



-----------------------
-- EDA Energy Generator
-----------------------
ClientEDAEnergyGenerator = Class("EDAEnergyGenerator", EnergyGenerator)



-----------------
-- Air Unit class
-----------------
ClientEDAAirUnit = Class("EDAAirUnit", AirUnit)



------------------
-- Land Unit class
------------------
ClientEDALandUnit = Class("EDALandUnit", LandUnit)

-------------------
-- Naval Unit class
-------------------
ClientEDANavalUnit = Class("EDANavalUnit", NavalUnit)



------------------
-- Submarine class
------------------
ClientEDASubmarine = Class("EDASubmarine", Submarine)



---------------------
-- EDA Engineer class
---------------------
ClientEDAEngineer = Class("EDAEngineer", Engineer)



----------------------
-- EDA Commander class
----------------------
ClientEDACommander = Class("EDACommander", Commander)

-- Guard/EDA Engineer Cache Patcher 1.2.1
-- The client resolves the same subclass name declared by the patched
-- EDA engineer templates; build animation playback is host-authoritative.
local EDAEngineer = ClientEDAEngineer or EDAEngineer
if not EDAEngineer then
    error("SCO could not resolve the client EDA engineer base class.")
end
ClientEDAUefEngineer = Class("EDAUefEngineer", EDAEngineer)
local EDAUefEngineer = ClientEDAUefEngineer

-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1
local CreateConstructionBeam = Import("client/entities/constructionBeam.lua").CreateConstructionBeam
local PlacementLayer = Import("common/layers.lua").PlacementLayer

local EdaUefFactoryConstructionBeamPrefabID = nil
local EdaUefFactoryRollOffReservationPrefabID = nil
local EdaUefFactoryConstructionBeamGroup = {}
EdaUefFactoryConstructionBeamGroup.__index = EdaUefFactoryConstructionBeamGroup

local function GetEdaUefFactoryConstructionBeamPrefabID()
    if EdaUefFactoryConstructionBeamPrefabID then
        return EdaUefFactoryConstructionBeamPrefabID
    end

    local prefab = EngineClasses.PrefabTemplate("SupremeCommanderOverhaulEdaUefFactoryConstructionBeam")
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
        -- Supreme Commander Overhaul UEF land-factory beam palette 1.3.0
        "VFX/SCOM/ConstructionBeams/uef.sanmaterial",
        EngineClasses.float3(0.05, 1, 1),
        ShadowCastingMode.Off,
        EngineClasses.float4(),
        EngineClasses.float4(),
        false
    ))

    local errorCode, prefabID = Engine.CreatePrefab(prefab)
    if errorCode ~= EngineErrorCode.Success then
        Engine.Error("Unable to create the EDA UEF factory construction-beam prefab.")
        return nil
    end

    EdaUefFactoryConstructionBeamPrefabID = prefabID
    return prefabID
end

local function GetEdaUefFactoryRollOffReservationPrefabID()
    if EdaUefFactoryRollOffReservationPrefabID then
        return EdaUefFactoryRollOffReservationPrefabID
    end

    local prefab = EngineClasses.PrefabTemplate("SupremeCommanderOverhaulEdaUefFactoryRollOffLocal")
    local head = EngineClasses.EntityTemplate()
    head.entityName = TemplateHeadEntityName
    head.localTranslation = EngineClasses.float3(0, 0, 0)
    head.localScale = 1
    head.localRotation = GetIdentityQuaternion()
    head.forceSimulated = false
    table.insert(prefab.hierarchyTemplate.entities, head)
    table.insert(prefab.localTemplate.localGridModifierTemplates, EngineClasses.GridModifierTemplate(
        TemplateHeadEntityName,
        EngineClasses.int2(0, 0),
        EngineClasses.int2(0, 0),
        _G.localBuildingPlacementGridID,
        PlacementLayer.Default,
        PlacementLayer.None,
        false
    ))

    local errorCode, prefabID = Engine.CreatePrefab(prefab)
    if errorCode ~= EngineErrorCode.Success then
        Engine.Error("Unable to create the EDA UEF factory local roll-off reservation prefab.")
        return nil
    end

    EdaUefFactoryRollOffReservationPrefabID = prefabID
    return prefabID
end

local function GetEdaUefFactoryRollOffReservations(factory)
    local additions = factory.tp.additions
    return additions and additions.placementReservations or {}
end

local function DestroyEdaUefFactoryRollOffReservationIDs(reservationIDs)
    for _, reservationID in ipairs(reservationIDs or {}) do
        if Engine.IsValidLocalID(reservationID) then
            Engine.SetLocalGridModifierEnabled(reservationID, false)
            Engine.DeletePrefabInstance(reservationID)
        end
    end
end

function EdaUefFactoryConstructionBeamGroup:SetTarget(target)
    if self.deleted then
        return
    end

    if target == nil then
        self:RemoveTarget()
        return
    end

    for _, state in ipairs(self.beams) do
        -- ConstructionBeam owns the target's collision-center/progress
        -- interpolation. Passing the factory floor here made every arm
        -- aim backward/down into the imported structure instead.
        state.beam:SetTarget(target)
    end
    self:RenderUpdate()
end

function EdaUefFactoryConstructionBeamGroup:RemoveTarget()
    self.enabled = false
    for _, state in ipairs(self.beams) do
        -- A detached loose root otherwise retains its default visible
        -- mesh when an intel event arrives after build completion.
        state.beam:SetEnabled(false)
        state.beam:RemoveTarget()
    end
end

function EdaUefFactoryConstructionBeamGroup:SetEnabled(enabled)
    if self.deleted then
        return
    end
    self.enabled = enabled == true
    for _, state in ipairs(self.beams) do
        state.beam:SetEnabled(self.enabled and state.beam.targetUnit ~= nil)
    end
    self:RenderUpdate()
end

function EdaUefFactoryConstructionBeamGroup:Update()
    -- See the Cybran group: stock BuildThread owns this sim-rate call,
    -- while loose root transforms must remain render-only.
end

function EdaUefFactoryConstructionBeamGroup:RenderUpdate()
    if self.deleted or not self.enabled then
        return
    end
    for _, state in ipairs(self.beams) do
        if state.beam.targetUnit ~= nil
            and Engine.IsValidLocalID(state.rootID)
            and Engine.IsValidLocalID(state.muzzleID) then
            Engine.GetLocalEntityWorldPosition(state.muzzleID, state.muzzlePosition)
            Engine.SetLocalEntityLocalPosition(state.rootID, state.muzzlePosition)
            state.beam:Update()
        end
    end
end

function EdaUefFactoryConstructionBeamGroup:Delete()
    if self.deleted then
        return
    end
    self.deleted = true
    self.enabled = false

    for _, state in ipairs(self.beams) do
        state.beam:SetEnabled(false)
        state.beam:RemoveTarget()
        if Engine.IsValidLocalID(state.rootID) then
            Engine.DeletePrefabInstance(state.rootID)
        end
    end
    self.beams = {}
end

local function CreateEdaUefFactoryConstructionBeamGroup(factory, boneNames)
    local prefabID = GetEdaUefFactoryConstructionBeamPrefabID()
    if not prefabID then
        return nil
    end

    local group = setmetatable({
        beams = {},
        deleted = false,
        enabled = false,
    }, EdaUefFactoryConstructionBeamGroup)
    local initialPosition = factory:GetPosition()
    for _, boneName in ipairs(boneNames) do
        local muzzleID = factory:GetBoneId(boneName)
        if not Engine.IsValidLocalID(muzzleID) then
            group:Delete()
            Engine.Error("EDA UEF factory is missing construction-beam bone " .. boneName .. ".")
            return nil
        end

        local errorCode, rootID = Engine.InstantiatePrefab(
            prefabID,
            initialPosition,
            EngineClasses.float3(1, 1, 1),
            GetIdentityQuaternion()
        )
        if errorCode ~= EngineErrorCode.Success or not Engine.IsValidLocalID(rootID) then
            if Engine.IsValidLocalID(rootID) then
                Engine.DeletePrefabInstance(rootID)
            end
            group:Delete()
            Engine.Error("Unable to instantiate an EDA UEF factory construction beam for " .. boneName .. ".")
            return nil
        end

        local beamEntityID = EngineClasses.LocalID()
        Engine.GetLocalBone(rootID, "Construction Beam", beamEntityID)
        if not Engine.IsValidLocalID(beamEntityID) then
            Engine.DeletePrefabInstance(rootID)
            group:Delete()
            Engine.Error("The EDA UEF factory construction-beam prefab has no renderer entity.")
            return nil
        end

        table.insert(group.beams, {
            rootID = rootID,
            muzzleID = muzzleID,
            muzzlePosition = EngineClasses.float3(),
            beam = CreateConstructionBeam(rootID),
        })
    end

    return group
end

local function DisposeEdaUefFactoryConstructionBeam(factory)
    local beam = factory.constructionBeam
    factory.constructionBeam = nil
    factory.constructionBeamEnabled = false
    if beam and beam.Delete then
        beam:Delete()
    end
end

local EDALandFactory = ClientEDALandFactory or EDALandFactory
if not EDALandFactory then
    error("SCO could not resolve the client EDA land-factory base class.")
end
ClientEDAUefLandFactory = Class("EDAUefLandFactory", EDALandFactory)
local EDAUefLandFactory = ClientEDAUefLandFactory

function EDAUefLandFactory:CreateRollOffReservation()
    if self.edaUefRollOffReservationIDs or self:IsPlacementGhost() then
        return
    end

    local reservations = GetEdaUefFactoryRollOffReservations(self)
    if #reservations == 0 then
        return
    end

    local prefabID = GetEdaUefFactoryRollOffReservationPrefabID()
    if not prefabID then
        return
    end

    local reservationIDs = {}
    local factoryPosition = self:GetPosition()
    for _, reservation in ipairs(reservations) do
        local size = reservation.size
        if not size then
            DestroyEdaUefFactoryRollOffReservationIDs(reservationIDs)
            Engine.Error("EDA UEF factory local roll-off reservation is missing a size.")
            return
        end

        local offset = reservation.offset or {}
        local position = EngineClasses.float3(
            factoryPosition.x + (offset.x or 0),
            factoryPosition.y + (offset.y or 0),
            factoryPosition.z + (offset.z or 0)
        )
        local errorCode, reservationID = Engine.InstantiatePrefab(
            prefabID,
            position,
            EngineClasses.float3(1, 1, 1),
            GetIdentityQuaternion()
        )
        if errorCode ~= EngineErrorCode.Success or not Engine.IsValidLocalID(reservationID) then
            if Engine.IsValidLocalID(reservationID) then
                Engine.DeletePrefabInstance(reservationID)
            end
            DestroyEdaUefFactoryRollOffReservationIDs(reservationIDs)
            Engine.Error("Unable to create an EDA UEF factory local roll-off reservation.")
            return
        end

        Engine.SetLocalGridModifierSize(reservationID, EngineClasses.float2(size.x, size.y))
        table.insert(reservationIDs, reservationID)
    end

    self.edaUefRollOffReservationIDs = reservationIDs
    self:SetRollOffReservationEnabled(self:IsIntelVisionVisible())
end

function EDAUefLandFactory:SetRollOffReservationEnabled(enabled)
    for _, reservationID in ipairs(self.edaUefRollOffReservationIDs or {}) do
        if Engine.IsValidLocalID(reservationID) then
            Engine.SetLocalGridModifierEnabled(reservationID, enabled)
        end
    end
end

function EDAUefLandFactory:DestroyRollOffReservation()
    DestroyEdaUefFactoryRollOffReservationIDs(self.edaUefRollOffReservationIDs)
    self.edaUefRollOffReservationIDs = nil
end

function EDAUefLandFactory:__init(globalId, localId, armyId, template, progress)
    EDALandFactory.__init(self, globalId, localId, armyId, template, progress)
    if not self:IsPlacementGhost() then
        self:CreateRollOffReservation()
    end
end

function EDAUefLandFactory:OnPromoteToUnit()
    self:CreateRollOffReservation()
    EDALandFactory.OnPromoteToUnit(self)
end

function EDAUefLandFactory:OnIntelHidden()
    EDALandFactory.OnIntelHidden(self)
    self:SetRollOffReservationEnabled(false)
end

function EDAUefLandFactory:OnIntelVision()
    EDALandFactory.OnIntelVision(self)
    self:CreateRollOffReservation()
    self:SetRollOffReservationEnabled(true)
end

function EDAUefLandFactory:SetUpConstructionBeam()
    DisposeEdaUefFactoryConstructionBeam(self)
    local boneNames = self.tp.additions and self.tp.additions.buildBeamBones
    if boneNames and #boneNames > 0 then
        self.constructionBeam = CreateEdaUefFactoryConstructionBeamGroup(self, boneNames)
    end
end

function EDAUefLandFactory:OnStartBuildRoutine(buildableId)
    self:SetUpConstructionBeam()
    EDALandFactory.OnStartBuildRoutine(self, buildableId)
end

function EDAUefLandFactory:ClientOnStopBuilding()
    EDALandFactory.ClientOnStopBuilding(self)
    DisposeEdaUefFactoryConstructionBeam(self)
end

function EDAUefLandFactory:OnEndUpgrading(upgrade)
    EDALandFactory.OnEndUpgrading(self, upgrade)
    DisposeEdaUefFactoryConstructionBeam(self)
end

function EDAUefLandFactory:RenderUpdateBeams()
    EDALandFactory.RenderUpdateBeams(self)
    if self.constructionBeam then
        self.constructionBeam:RenderUpdate()
    end
end

function EDAUefLandFactory:OnIntelRadar()
    EDALandFactory.OnIntelRadar(self)
    self:RecalculateConstructionBeamState()
    self:SetRollOffReservationEnabled(false)
end

function EDAUefLandFactory:OnDestroy(isDelete)
    self:DestroyRollOffReservation()
    DisposeEdaUefFactoryConstructionBeam(self)
    EDALandFactory.OnDestroy(self, isDelete)
end

function EDAUefLandFactory:OnDelete()
    self:DestroyRollOffReservation()
    DisposeEdaUefFactoryConstructionBeam(self)
    EDALandFactory.OnDelete(self)
end

-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0
local EDAStructure = ClientEDAStructure or EDAStructure
local EDAAlloyExtractor = ClientEDAAlloyExtractor or EDAAlloyExtractor
local EDAEnergyGenerator = ClientEDAEnergyGenerator or EDAEnergyGenerator
local EDALandUnit = ClientEDALandUnit or EDALandUnit
if not EDAStructure or not EDAAlloyExtractor or not EDAEnergyGenerator or not EDALandUnit then
    error("SCO could not resolve the client EDA base classes.")
end
ClientEDAImportedAnimatedStructure = Class("EDAImportedAnimatedStructure", EDAStructure)
ClientEDAImportedAnimatedAlloyExtractor = Class("EDAImportedAnimatedAlloyExtractor", EDAAlloyExtractor)
ClientEDAImportedAnimatedEnergyGenerator = Class("EDAImportedAnimatedEnergyGenerator", EDAEnergyGenerator)
ClientEDAImportedFaLandUnit = Class("EDAImportedFaLandUnit", EDALandUnit)

-- Supreme Commander Overhaul FA Air Factories 1.0.0
local SCOFaAirFactoryClientBase = ClientEDAAirFactory or EDAAirFactory
local SCOFaAirFactoryClientLifecycle = _G.SCOFaAirFactoryClientLifecycle
if not SCOFaAirFactoryClientBase or not SCOFaAirFactoryClientLifecycle then
    error("FA air-factory client dependencies are unavailable.")
end
ClientEDAFaUefAirFactory = Class("EDAFaUefAirFactory", SCOFaAirFactoryClientBase)
local SCOFaAirFactoryClientClass = ClientEDAFaUefAirFactory

function SCOFaAirFactoryClientClass:OnStartBuildRoutine(buildableId)
    SCOFaAirFactoryClientLifecycle.Prepare(self)
    SCOFaAirFactoryClientBase.OnStartBuildRoutine(self, buildableId)
end

function SCOFaAirFactoryClientClass:ClientOnStopBuilding()
    SCOFaAirFactoryClientBase.ClientOnStopBuilding(self)
    SCOFaAirFactoryClientLifecycle.Dispose(self)
end

function SCOFaAirFactoryClientClass:OnEndUpgrading(upgrade)
    SCOFaAirFactoryClientBase.OnEndUpgrading(self, upgrade)
    SCOFaAirFactoryClientLifecycle.Dispose(self)
end

function SCOFaAirFactoryClientClass:RenderUpdateBeams()
    SCOFaAirFactoryClientBase.RenderUpdateBeams(self)
    SCOFaAirFactoryClientLifecycle.Render(self)
end

function SCOFaAirFactoryClientClass:OnDestroy(isDelete)
    SCOFaAirFactoryClientLifecycle.Dispose(self)
    SCOFaAirFactoryClientBase.OnDestroy(self, isDelete)
end


-- Supreme Commander Overhaul FA Direct Structures 1.0.0
local SCO_EDAAlloyExtractor = ClientEDAAlloyExtractor or EDAAlloyExtractor
local SCO_EDAEngineeringStation = ClientEDAEngineeringStation or EDAEngineeringStation
if not SCO_EDAAlloyExtractor or not SCO_EDAEngineeringStation then
    error("SCO direct structures could not resolve client EDA bases.")
end
ClientEDASupComMassFabricator = Class("EDASupComMassFabricator", SCO_EDAAlloyExtractor)
ClientEDASupComKennelT2 = Class("EDASupComKennelT2", SCO_EDAEngineeringStation)
ClientEDASupComKennelT3 = Class("EDASupComKennelT3", SCO_EDAEngineeringStation)

-- Supreme Commander Overhaul sea parity 1.0.0
local SCOSeaParityNavalFactoryClientBase = ClientEDANavalFactory
local SCOSeaParityFactoryClientLifecycle = _G.SCOFaAirFactoryClientLifecycle
if not SCOSeaParityNavalFactoryClientBase or not SCOSeaParityFactoryClientLifecycle then
    error("Sea-parity naval-factory client dependencies are unavailable.")
end

ClientEDAFaUefNavalFactory = Class("EDAFaUefNavalFactory", SCOSeaParityNavalFactoryClientBase)
local SCOSeaParityNavalFactoryClientClass = ClientEDAFaUefNavalFactory

function SCOSeaParityNavalFactoryClientClass:OnStartBuildRoutine(buildableId)
    SCOSeaParityFactoryClientLifecycle.Prepare(self)
    SCOSeaParityNavalFactoryClientBase.OnStartBuildRoutine(self, buildableId)
end

function SCOSeaParityNavalFactoryClientClass:ClientOnStopBuilding()
    SCOSeaParityNavalFactoryClientBase.ClientOnStopBuilding(self)
    SCOSeaParityFactoryClientLifecycle.Dispose(self)
end

function SCOSeaParityNavalFactoryClientClass:OnEndUpgrading(upgrade)
    SCOSeaParityNavalFactoryClientBase.OnEndUpgrading(self, upgrade)
    SCOSeaParityFactoryClientLifecycle.Dispose(self)
end

function SCOSeaParityNavalFactoryClientClass:RenderUpdateBeams()
    SCOSeaParityNavalFactoryClientBase.RenderUpdateBeams(self)
    SCOSeaParityFactoryClientLifecycle.Render(self)
end

function SCOSeaParityNavalFactoryClientClass:OnDestroy(isDelete)
    SCOSeaParityFactoryClientLifecycle.Dispose(self)
    SCOSeaParityNavalFactoryClientBase.OnDestroy(self, isDelete)
end
