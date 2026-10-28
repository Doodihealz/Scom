--- This file contains default Guard units classes.

-- Default Guard units classes definitions
local unitsDefault = Import("client/units/unitsClasses/unitsDefault.lua")
Structure = unitsDefault.ClientStructure
TechCentre = unitsDefault.ClientTechCentre
NavalStructure = unitsDefault.ClientNavalStructure
NavalTechCentre = unitsDefault.ClientNavalTechCentre
EngineeringStation = unitsDefault.ClientEngineeringStation
Airfield = unitsDefault.ClientAirfield
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



------------------------
-- Guard Structure class
------------------------
ClientGuardStructure = Class("GuardStructure", Structure)



-------------------------------
-- Guard Naval Structure class
-------------------------------
ClientGuardNavalStructure = Class("GuardNavalStructure", NavalStructure)



------------------------
-- Guard Structure class
------------------------
ClientGuardTechCentre = Class("GuardTechCentre", TechCentre)



--------------------------------
-- Guard Naval TechCentre class
--------------------------------
ClientGuardNavalTechCentre = Class("GuardNavalTechCentre", NavalTechCentre)



----------------------------------
-- Guard Engineering Station class
----------------------------------
ClientGuardEngineeringStation = Class("GuardEngineeringStation", EngineeringStation)



----------------------------------
-- Guard Engineering Station class
----------------------------------
ClientGuardAirfield = Class("GuardAirfield", Airfield)



----------------------
-- Guard Storage class
----------------------
ClientGuardStorage = Class("Storage", Storage)



--------------------------
-- Guard Air Factory class
--------------------------
ClientGuardAirFactory = Class("GuardAirFactory", AirFactory)



---------------------------
-- Guard Land Factory class
---------------------------
ClientGuardLandFactory = Class("GuardLandFactory", LandFactory)



----------------------------
-- Guard Naval Factory class
----------------------------
ClientGuardNavalFactory = Class("GuardNavalFactory", NavalFactory)



------------------------
-- Guard Alloy Extractor
------------------------
ClientGuardAlloyExtractor = Class("GuardAlloyExtractor", AlloyExtractor)



-------------------------
-- Guard Energy Generator
-------------------------
ClientGuardEnergyGenerator = Class("GuardEnergyGenerator", EnergyGenerator)



-----------------------
-- Guard Air Unit class
-----------------------
ClientGuardAirUnit = Class("GuardAirUnit", AirUnit)



------------------------
-- Guard Land Unit class
------------------------
ClientGuardLandUnit = Class("GuardLandUnit", LandUnit)



-------------------------
-- Guard Naval Unit class
-------------------------
ClientGuardNavalUnit = Class("GuardNavalUnit", NavalUnit)



------------------------
-- Guard Submarine class
------------------------
ClientGuardSubmarine = Class("GuardSubmarine", Submarine)



-----------------------
-- Guard Engineer class
-----------------------
ClientGuardEngineer = Class("GuardEngineer", Engineer)



------------------------
-- Guard Commander class
------------------------
ClientGuardCommander = Class("GuardCommander", Commander)


-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1
local CreateConstructionBeam = Import("client/entities/constructionBeam.lua").CreateConstructionBeam
local PlacementLayer = Import("common/layers.lua").PlacementLayer

-- SCOM Promethean factory beam isolation 1.0.0
local CybranFactoryConstructionBeamPrefabIDs = {}
local CybranFactoryRollOffReservationPrefabID = nil
local CybranFactoryConstructionBeamGroup = {}
CybranFactoryConstructionBeamGroup.__index = CybranFactoryConstructionBeamGroup

local function GetCybranFactoryConstructionBeamPrefabID(materialPath)
    local existing = CybranFactoryConstructionBeamPrefabIDs[materialPath]
    if existing then
        return existing
    end

    local prefabName = materialPath == "Prometheans/VFX/Materials/ConstructionBeams/Promethean_ConstructionBeam.sanmaterial"
        and "SupremeCommanderOverhaulPrometheanFactoryConstructionBeam"
        or "SupremeCommanderOverhaulCybranFactoryConstructionBeam"
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
        Engine.Error("Unable to create the Cybran factory construction-beam prefab.")
        return nil
    end

    CybranFactoryConstructionBeamPrefabIDs[materialPath] = prefabID
    return prefabID
end

local function GetCybranFactoryRollOffReservationPrefabID()
    if CybranFactoryRollOffReservationPrefabID then
        return CybranFactoryRollOffReservationPrefabID
    end

    local prefab = EngineClasses.PrefabTemplate("SupremeCommanderOverhaulCybranFactoryRollOffLocal")
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
        Engine.Error("Unable to create the Cybran factory local roll-off reservation prefab.")
        return nil
    end

    CybranFactoryRollOffReservationPrefabID = prefabID
    return prefabID
end

local function GetCybranFactoryRollOffReservations(factory)
    local additions = factory.tp.additions
    return additions and additions.placementReservations or {}
end

local function DestroyCybranFactoryRollOffReservationIDs(reservationIDs)
    for _, reservationID in ipairs(reservationIDs or {}) do
        if Engine.IsValidLocalID(reservationID) then
            Engine.SetLocalGridModifierEnabled(reservationID, false)
            Engine.DeletePrefabInstance(reservationID)
        end
    end
end

function CybranFactoryConstructionBeamGroup:SetTarget(target)
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

function CybranFactoryConstructionBeamGroup:RemoveTarget()
    self.enabled = false
    for _, state in ipairs(self.beams) do
        -- A detached loose root otherwise retains its default visible
        -- mesh when an intel event arrives after build completion.
        state.beam:SetEnabled(false)
        state.beam:RemoveTarget()
    end
end

function CybranFactoryConstructionBeamGroup:SetEnabled(enabled)
    if self.deleted then
        return
    end
    self.enabled = enabled == true
    for _, state in ipairs(self.beams) do
        state.beam:SetEnabled(self.enabled and state.beam.targetUnit ~= nil)
    end
    self:RenderUpdate()
end

function CybranFactoryConstructionBeamGroup:Update()
    -- Unit:BuildThread invokes constructionBeam:Update() every simulation
    -- tick. Loose visual roots are render-only, so that loop must not
    -- duplicate per-arm FFI work or allocations.
end

function CybranFactoryConstructionBeamGroup:RenderUpdate()
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

function CybranFactoryConstructionBeamGroup:Delete()
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

local function CreateCybranFactoryConstructionBeamGroup(factory, boneNames)
    local materialPath = factory:HasTags(Tags.PROMETHEAN)
        and "Prometheans/VFX/Materials/ConstructionBeams/Promethean_ConstructionBeam.sanmaterial"
        or "VFX/SCOM/ConstructionBeams/cybran.sanmaterial"
    local prefabID = GetCybranFactoryConstructionBeamPrefabID(materialPath)
    if not prefabID then
        return nil
    end

    local group = setmetatable({
        beams = {},
        deleted = false,
        enabled = false,
    }, CybranFactoryConstructionBeamGroup)
    local initialPosition = factory:GetPosition()
    for _, boneName in ipairs(boneNames) do
        local muzzleID = factory:GetBoneId(boneName)
        if not Engine.IsValidLocalID(muzzleID) then
            group:Delete()
            Engine.Error("Cybran factory is missing construction-beam bone " .. boneName .. ".")
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
            Engine.Error("Unable to instantiate a Cybran factory construction beam for " .. boneName .. ".")
            return nil
        end

        local beamEntityID = EngineClasses.LocalID()
        Engine.GetLocalBone(rootID, "Construction Beam", beamEntityID)
        if not Engine.IsValidLocalID(beamEntityID) then
            Engine.DeletePrefabInstance(rootID)
            group:Delete()
            Engine.Error("The Cybran factory construction-beam prefab has no renderer entity.")
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

local function DisposeCybranFactoryConstructionBeam(factory)
    local beam = factory.constructionBeam
    factory.constructionBeam = nil
    factory.constructionBeamEnabled = false
    if beam and beam.Delete then
        beam:Delete()
    end
end

-- The client owns cosmetic tarmac and beams plus local grid reservations
-- for both angled factory roll-off lanes.
local GuardLandFactory = ClientGuardLandFactory or GuardLandFactory
if not GuardLandFactory then
    error("SCO could not resolve the client Guard land-factory base class.")
end
ClientGuardCybranLandFactory = Class("GuardCybranLandFactory", GuardLandFactory)
local GuardCybranLandFactory = ClientGuardCybranLandFactory

function GuardCybranLandFactory:CreateTarmac()
    local tarmacSize = self.tp.additions and self.tp.additions.tarmacSize
    if not tarmacSize or not _G.TarmacGuardPrefabID then
        return
    end

    self.tarmac = self:CreateDecal(_G.TarmacGuardPrefabID, tarmacSize.x, tarmacSize.y, 0)
    if self.tarmac then
        self.tarmac:SetEnabled(false)
    end
end

function GuardCybranLandFactory:CreateRollOffReservation()
    if self.guardCybranRollOffReservationIDs or self:IsPlacementGhost() then
        return
    end

    local reservations = GetCybranFactoryRollOffReservations(self)
    if #reservations == 0 then
        return
    end

    local prefabID = GetCybranFactoryRollOffReservationPrefabID()
    if not prefabID then
        return
    end

    local reservationIDs = {}
    local factoryPosition = self:GetPosition()
    for _, reservation in ipairs(reservations) do
        local size = reservation.size
        if not size then
            DestroyCybranFactoryRollOffReservationIDs(reservationIDs)
            Engine.Error("Cybran factory local roll-off reservation is missing a size.")
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
            DestroyCybranFactoryRollOffReservationIDs(reservationIDs)
            Engine.Error("Unable to create a Cybran factory local roll-off reservation.")
            return
        end

        Engine.SetLocalGridModifierSize(reservationID, EngineClasses.float2(size.x, size.y))
        table.insert(reservationIDs, reservationID)
    end

    self.guardCybranRollOffReservationIDs = reservationIDs
    self:SetRollOffReservationEnabled(self:IsIntelVisionVisible())
end

function GuardCybranLandFactory:SetRollOffReservationEnabled(enabled)
    for _, reservationID in ipairs(self.guardCybranRollOffReservationIDs or {}) do
        if Engine.IsValidLocalID(reservationID) then
            Engine.SetLocalGridModifierEnabled(reservationID, enabled)
        end
    end
end

function GuardCybranLandFactory:DestroyRollOffReservation()
    DestroyCybranFactoryRollOffReservationIDs(self.guardCybranRollOffReservationIDs)
    self.guardCybranRollOffReservationIDs = nil
end

function GuardCybranLandFactory:__init(globalId, localId, armyId, template, progress)
    GuardLandFactory.__init(self, globalId, localId, armyId, template, progress)
    if not self:IsPlacementGhost() then
        self:CreateRollOffReservation()
    end
end

function GuardCybranLandFactory:OnPromoteToUnit()
    self:CreateRollOffReservation()
    GuardLandFactory.OnPromoteToUnit(self)
end

function GuardCybranLandFactory:OnIntelHidden()
    GuardLandFactory.OnIntelHidden(self)
    self:SetRollOffReservationEnabled(false)
end

function GuardCybranLandFactory:OnIntelVision()
    GuardLandFactory.OnIntelVision(self)
    self:CreateRollOffReservation()
    self:SetRollOffReservationEnabled(true)
end

function GuardCybranLandFactory:SetUpConstructionBeam()
    DisposeCybranFactoryConstructionBeam(self)
    local boneNames = self.tp.additions and self.tp.additions.buildBeamBones
    if boneNames and #boneNames > 0 then
        self.constructionBeam = CreateCybranFactoryConstructionBeamGroup(self, boneNames)
    end
end

function GuardCybranLandFactory:OnStartBuildRoutine(buildableId)
    self:SetUpConstructionBeam()
    GuardLandFactory.OnStartBuildRoutine(self, buildableId)
end

function GuardCybranLandFactory:ClientOnStopBuilding()
    GuardLandFactory.ClientOnStopBuilding(self)
    DisposeCybranFactoryConstructionBeam(self)
end

function GuardCybranLandFactory:OnEndUpgrading(upgrade)
    GuardLandFactory.OnEndUpgrading(self, upgrade)
    DisposeCybranFactoryConstructionBeam(self)
end

function GuardCybranLandFactory:RenderUpdateBeams()
    GuardLandFactory.RenderUpdateBeams(self)
    if self.constructionBeam then
        self.constructionBeam:RenderUpdate()
    end
end

function GuardCybranLandFactory:OnIntelRadar()
    GuardLandFactory.OnIntelRadar(self)
    self:RecalculateConstructionBeamState()
    self:SetRollOffReservationEnabled(false)
end

function GuardCybranLandFactory:OnDestroy(isDelete)
    self:DestroyRollOffReservation()
    DisposeCybranFactoryConstructionBeam(self)
    GuardLandFactory.OnDestroy(self, isDelete)
end

function GuardCybranLandFactory:OnDelete()
    self:DestroyRollOffReservation()
    DisposeCybranFactoryConstructionBeam(self)
    GuardLandFactory.OnDelete(self)
end

-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0
local GuardStructure = ClientGuardStructure or GuardStructure
local GuardAlloyExtractor = ClientGuardAlloyExtractor or GuardAlloyExtractor
local GuardCybranLandFactory = ClientGuardCybranLandFactory or GuardCybranLandFactory
if not GuardStructure or not GuardAlloyExtractor or not GuardCybranLandFactory then
    error("SCO could not resolve the client Guard base classes.")
end
ClientGuardImportedAnimatedStructure = Class("GuardImportedAnimatedStructure", GuardStructure)
ClientGuardImportedAnimatedAlloyExtractor = Class("GuardImportedAnimatedAlloyExtractor", GuardAlloyExtractor)
ClientGuardCybranAnimatedLandFactory = Class("GuardCybranAnimatedLandFactory", GuardCybranLandFactory)
-- Guard Cybran Monkeylord Cache Patcher 1.4.0
ClientGuardMonkeylord = Class("GuardMonkeylord", ClientGuardLandUnit)


-- Supreme Commander Overhaul FA Air Factories 1.0.0
local SCOFaAirFactoryClientBase = ClientGuardAirFactory or GuardAirFactory
local SCOFaAirFactoryClientLifecycle = _G.SCOFaAirFactoryClientLifecycle
if not SCOFaAirFactoryClientBase or not SCOFaAirFactoryClientLifecycle then
    error("FA air-factory client dependencies are unavailable.")
end
ClientGuardFaCybranAirFactory = Class("GuardFaCybranAirFactory", SCOFaAirFactoryClientBase)
local SCOFaAirFactoryClientClass = ClientGuardFaCybranAirFactory

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
local SCO_GuardStructure = ClientGuardStructure or GuardStructure
local SCO_GuardAlloyExtractor = ClientGuardAlloyExtractor or GuardAlloyExtractor
local SCO_GuardEngineeringStation = ClientGuardEngineeringStation or GuardEngineeringStation
if not SCO_GuardStructure or not SCO_GuardAlloyExtractor or not SCO_GuardEngineeringStation then
    error("SCO direct structures could not resolve client Guard bases.")
end
ClientGuardSupComMassFabricator = Class("GuardSupComMassFabricator", SCO_GuardAlloyExtractor)
ClientGuardSupComHiveT2 = Class("GuardSupComHiveT2", SCO_GuardEngineeringStation)
ClientGuardSupComHiveFinal = Class("GuardSupComHiveFinal", SCO_GuardEngineeringStation)
ClientGuardSupComShieldFinal = Class("GuardSupComShieldFinal", SCO_GuardStructure)
-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0
local SCO_EggClientGuardLandUnit = ClientGuardLandUnit or GuardLandUnit
if not SCO_EggClientGuardLandUnit then
    error("Trebuchet requires client GuardLandUnit")
end
ClientGuardTrebuchet = Class("GuardTrebuchet", SCO_EggClientGuardLandUnit)
-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0
-- Client classes are identity-only: the host exclusively owns child spawn,
-- Open/sink timing, deletion, targeting layers, speed, and lifecycle clips.
local SCO_MegalithClientEngineer = ClientGuardEngineer or GuardEngineer
local SCO_MegalithClientStructure = ClientGuardStructure or GuardStructure
if not SCO_MegalithClientEngineer or not SCO_MegalithClientStructure then
    error("FA Megalith client could not resolve Guard bases")
end
ClientGuardFaCybranMegalith = Class(
    "GuardFaCybranMegalith",
    SCO_MegalithClientEngineer)
ClientGuardMegalithEgg = Class(
    "GuardMegalithEgg",
    SCO_MegalithClientStructure)

local function SCO_MegalithSetLocalVolumeColliderEnabled(globalId, enabled)
    local localId = EngineClasses.LocalID()
    local errorCode = Engine.GetGlobalEntityPairedLocalID(globalId, localId)
    if errorCode == EngineErrorCode.Success
        and Engine.IsValidLocalID(localId)
    then
        Engine.SetVolumeColliderEnabled(localId, enabled)
    end
end

local function SCO_MegalithClampVisualShell(egg)
    if not egg or not egg.scoMegalithEggVisualShell then
        return
    end
    SCO_MegalithSetLocalVolumeColliderEnabled(egg.id, false)
    Engine.SetLocalGridModifierEnabled(egg.localId, false)
    egg:SetSelectionEnabled(false)
end

-- The FA construction egg is selectable while incomplete so a paused build
-- can be recovered. Once complete, it becomes a transient visual hatch shell;
-- the host exclusively owns child spawn, animation, sinking, and deletion.
function ClientGuardMegalithEgg:IsSelectable()
    if self.scoMegalithEggVisualShell then
        return false
    end
    return SCO_MegalithClientStructure.IsSelectable(self)
end

function ClientGuardMegalithEgg:IsHighlightable()
    if self.scoMegalithEggVisualShell then
        return false
    end
    return SCO_MegalithClientStructure.IsHighlightable(self)
end

function ClientGuardMegalithEgg:SetSelectionEnabled(enabled)
    return SCO_MegalithClientStructure.SetSelectionEnabled(
        self, enabled and not self.scoMegalithEggVisualShell)
end

function ClientGuardMegalithEgg:CreateTarmac()
end

function ClientGuardMegalithEgg:OnCompleted()
    self.scoMegalithEggVisualShell = true
    SCO_MegalithClientStructure.OnCompleted(self)
    SCO_MegalithClampVisualShell(self)
end

function ClientGuardMegalithEgg:OnIntelVision()
    SCO_MegalithClientStructure.OnIntelVision(self)
    SCO_MegalithClampVisualShell(self)
end

function ClientGuardFaCybranMegalith:ClientOnStopBuilding()
    local targetUnit = self.buildTarget
    SCO_MegalithClientEngineer.ClientOnStopBuilding(self)
    -- Stock restores the target's paired local collider after completion.
    -- Clamp the completed egg again after that parent callback returns.
    SCO_MegalithClampVisualShell(targetUnit)
end
-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0
local SCO_ScathisClientGuardLandUnit = ClientGuardLandUnit or GuardLandUnit
if not SCO_ScathisClientGuardLandUnit then error("Scathis requires client GuardLandUnit") end
ClientGuardScathis = Class("GuardScathis", SCO_ScathisClientGuardLandUnit)

-- Supreme Commander Overhaul sea parity 1.0.0
local SCOSeaParityNavalFactoryClientBase = ClientGuardNavalFactory
local SCOSeaParityFactoryClientLifecycle = _G.SCOFaAirFactoryClientLifecycle
if not SCOSeaParityNavalFactoryClientBase or not SCOSeaParityFactoryClientLifecycle then
    error("Sea-parity naval-factory client dependencies are unavailable.")
end

ClientGuardFaCybranNavalFactory = Class("GuardFaCybranNavalFactory", SCOSeaParityNavalFactoryClientBase)
local SCOSeaParityNavalFactoryClientClass = ClientGuardFaCybranNavalFactory

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

-- Supreme Commander Overhaul Salem amphibious parity 1.0.0
if not ClientGuardNavalUnit then
    error("Salem amphibious client base is unavailable")
end
ClientGuardFaCybranSalem = Class(
    "GuardFaCybranSalem", ClientGuardNavalUnit)
