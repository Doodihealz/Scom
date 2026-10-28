--- This file contains default EDA units classes.

-- Default EDA units classes definitions
local unitsDefault = Import("host/units/unitsClasses/unitsDefault.lua")
Structure = unitsDefault.HostStructure
TechCentre = unitsDefault.HostTechCentre
NavalStructure = unitsDefault.HostNavalStructure
NavalTechCentre = unitsDefault.HostNavalTechCentre
EngineeringStation = unitsDefault.HostEngineeringStation
Storage = unitsDefault.HostStorage
AirFactory = unitsDefault.HostAirFactory
LandFactory = unitsDefault.HostLandFactory
NavalFactory = unitsDefault.HostNavalFactory
AlloyExtractor = unitsDefault.HostAlloyExtractor
EnergyGenerator = unitsDefault.HostEnergyGenerator
MobileUnit = unitsDefault.HostMobileUnit
AirUnit = unitsDefault.HostAirUnit
LandUnit = unitsDefault.HostLandUnit
NavalUnit = unitsDefault.HostNavalUnit
Engineer = unitsDefault.HostEngineer
Submarine = unitsDefault.HostSubmarineUnit
Commander = unitsDefault.HostCommander



----------------------
-- EDA Structure class
----------------------
HostEDAStructure = Class("EDAStructure", Structure)



-------------------------------
-- EDA Naval Structure class
-------------------------------
HostEDANavalStructure = Class("EDANavalStructure", NavalStructure)



----------------------
-- EDA Structure class
----------------------
HostEDATechCentre = Class("EDATechCentre", TechCentre)



--------------------------------
-- EDA Naval TechCentre class
--------------------------------
HostEDANavalTechCentre = Class("EDANavalTechCentre", NavalTechCentre)



--------------------------------
-- EDA Engineering Station class
--------------------------------
HostEDAEngineeringStation = Class("EDAEngineeringStation", EngineeringStation)



--------------------
-- EDA Storage class
--------------------
HostEDAStorage = Class("Storage", Storage)



------------------------
-- EDA Air Factory class
------------------------
HostEDAAirFactory = Class("EDAAirFactory", AirFactory)



-------------------------
-- EDA Land Factory class
-------------------------
HostEDALandFactory = Class("EDALandFactory", LandFactory)



--------------------------
-- EDA Naval Factory class
--------------------------
HostEDANavalFactory = Class("EDANavalFactory", NavalFactory)



----------------------
-- EDA Alloy Extractor
----------------------
HostEDAAlloyExtractor = Class("EDAAlloyExtractor", AlloyExtractor)



-----------------------
-- EDA Energy Generator
-----------------------
HostEDAEnergyGenerator = Class("EDAEnergyGenerator", EnergyGenerator)



-----------------
-- Air Unit class
-----------------
HostEDAAirUnit = Class("EDAAirUnit", AirUnit)



------------------
-- Land Unit class
------------------
HostEDALandUnit = Class("EDALandUnit", LandUnit)

-------------------
-- Naval Unit class
-------------------
HostEDANavalUnit = Class("EDANavalUnit", NavalUnit)



------------------
-- Submarine class
------------------
HostEDASubmarine = Class("EDASubmarine", Submarine)



---------------------
-- EDA Engineer class
---------------------
HostEDAEngineer = Class("EDAEngineer", Engineer)



----------------------
-- EDA Commander class
----------------------
HostEDACommander = Class("EDACommander", Commander)

-- Guard/EDA Engineer Cache Patcher 1.2.1
-- The corrected Rest pose is AnimBuild[0] and AnimClose[end].
-- Exact-time sampling preserves the current tool pose across pause, cancel,
-- and restart instead of replaying either transition from its endpoint.
local EDAEngineer = HostEDAEngineer or EDAEngineer
if not EDAEngineer then
    error("SCO could not resolve the host EDA engineer base class.")
end
HostEDAUefEngineer = Class("EDAUefEngineer", EDAEngineer)
local EDAUefEngineer = HostEDAUefEngineer
local SCO_UefEngineerBuildSentinelBase = -10000

local function SCO_UefEngineerBuildAlive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
end

local function SCO_UefEngineerBuildConfig(unit)
    local additions = unit.tp and unit.tp.additions
    local config = additions and additions.uefEngineerBuildAnimation
    if not config then
        return nil
    end

    local animations = unit.tp.visuals and unit.tp.visuals.animations
    local opening = animations and animations[config.openAnimationKey]
    local closing = animations and animations[config.closeAnimationKey]
    local rest = animations and animations[config.restAnimationKey]
    if type(config.durationSeconds) ~= "number"
        or config.durationSeconds <= 0
        or type(config.authoredRate) ~= "number"
        or config.authoredRate <= 0
        or not opening or opening.id == nil
        or not closing or closing.id == nil
        or not rest or rest.id == nil
    then
        error((unit.tpId or "UEF engineer")
            .. " has an invalid reversible build-animation contract")
    end
    return config, opening, closing, rest
end

local function SCO_UefEngineerBuildSample(unit, animation, seconds)
    Engine.PlayAnimation(
        unit.id,
        animation.id,
        SCO_UefEngineerBuildSentinelBase + seconds)
end

function EDAUefEngineer:SetupAnimations()
    local result = EDAEngineer.SetupAnimations(self)
    local config, _, _, rest = SCO_UefEngineerBuildConfig(self)
    if config then
        -- Native prefabs keep the animator disabled until construction ends,
        -- exposing this rig's extended bind pose on the factory floor.
        self.scoUefEngineerBuildSample = 0
        self.scoUefEngineerBuildAtRest = true
        self:SetAnimatorEnabled(true)
        SCO_UefEngineerBuildSample(self, rest, 0)
    end
    return result
end

local function SCO_UefEngineerBuildTransitionThread(
    unit,
    generation,
    opening)
    local config, openAnimation, closeAnimation, rest =
        SCO_UefEngineerBuildConfig(unit)
    if not config then
        return
    end

    local duration = config.durationSeconds
    local sample = math.max(
        0,
        math.min(duration, unit.scoUefEngineerBuildSample or 0))
    while SCO_UefEngineerBuildAlive(unit)
        and unit.scoUefEngineerBuildGeneration == generation
        and ((opening and sample < duration)
            or (not opening and sample > 0))
    do
        if opening then
            -- Exact-time ownership begins at the Rest-facing frame. Keeping
            -- frame zero sampled until the next scheduler slice makes a
            -- first-tick pause/cancel reverse from the pose actually shown.
            SCO_UefEngineerBuildSample(unit, openAnimation, sample)
            unit.scoUefEngineerBuildAtRest = nil
        else
            SCO_UefEngineerBuildSample(
                unit,
                closeAnimation,
                duration - sample)
        end
        unit.scoUefEngineerBuildSample = sample
        WaitTicks(1)
        local delta = Constants.TickTimeStep * config.authoredRate
        if opening then
            sample = math.min(duration, sample + delta)
        else
            sample = math.max(0, sample - delta)
        end
    end

    if not SCO_UefEngineerBuildAlive(unit)
        or unit.scoUefEngineerBuildGeneration ~= generation
    then
        return
    end

    unit.scoUefEngineerBuildSample = sample
    if opening then
        SCO_UefEngineerBuildSample(unit, openAnimation, sample)
        unit.scoUefEngineerBuildAtRest = nil
    else
        Engine.PlayAnimation(unit.id, rest.id, 0.1)
        unit.scoUefEngineerBuildAtRest = true
    end
end

function EDAUefEngineer:SCO_SetBuildAnimationState(opening)
    local additions = self.tp and self.tp.additions
    if not additions or not additions.uefEngineerBuildAnimation then
        return
    end
    self.scoUefEngineerBuildGeneration =
        (self.scoUefEngineerBuildGeneration or 0) + 1
    self:NewThread(
        SCO_UefEngineerBuildTransitionThread,
        self.scoUefEngineerBuildGeneration,
        opening)
end

function EDAUefEngineer:OnStopBeingBuilt(...)
    local result = EDAEngineer.OnStopBeingBuilt(self, ...)
    local additions = self.tp and self.tp.additions
    if additions and additions.uefEngineerBuildAnimation then
        self.scoUefEngineerBuildGeneration =
            (self.scoUefEngineerBuildGeneration or 0) + 1
        self.scoUefEngineerBuildSample = 0
        self.scoUefEngineerBuildAtRest = true
    end
    return result
end

function EDAUefEngineer:OnStartBuildRoutine(targetUnit)
    local result = EDAEngineer.OnStartBuildRoutine(self, targetUnit)
    self:SCO_SetBuildAnimationState(true)
    return result
end

function EDAUefEngineer:OnStopBuildRoutine(targetUnit)
    local result = EDAEngineer.OnStopBuildRoutine(self, targetUnit)
    if not self:IsRepairRoutineEnabled()
        and not self:IsReclaimRoutineEnabled()
    then
        self:SCO_SetBuildAnimationState(false)
    end
    return result
end

-- Native construction assistance uses build callbacks; completed-target repair
-- and reclaim use their own routine callbacks and need the same reversible
-- tool transition. A stop closes the arm only after every native work routine
-- has released it.
function EDAUefEngineer:OnStartRepairRoutine(targetUnit)
    local result = EDAEngineer.OnStartRepairRoutine(self, targetUnit)
    self:SCO_SetBuildAnimationState(true)
    return result
end

function EDAUefEngineer:OnStopRepairRoutine(targetUnit)
    local result = EDAEngineer.OnStopRepairRoutine(self, targetUnit)
    if not self:IsBuildRoutineEnabled()
        and not self:IsReclaimRoutineEnabled()
    then
        self:SCO_SetBuildAnimationState(false)
    end
    return result
end

function EDAUefEngineer:OnStartReclaimRoutine(targetUnit)
    local result = EDAEngineer.OnStartReclaimRoutine(self, targetUnit)
    self:SCO_SetBuildAnimationState(true)
    return result
end

function EDAUefEngineer:OnStopReclaimRoutine(targetUnit)
    local result = EDAEngineer.OnStopReclaimRoutine(self, targetUnit)
    if not self:IsBuildRoutineEnabled()
        and not self:IsRepairRoutineEnabled()
    then
        self:SCO_SetBuildAnimationState(false)
    end
    return result
end

function EDAUefEngineer:OnDestroy(...)
    self.scoUefEngineerBuildGeneration =
        (self.scoUefEngineerBuildGeneration or 0) + 1
    return EDAEngineer.OnDestroy(self, ...)
end

-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1
local OrderTasks = Import("common/commonOrders.lua").OrderTasks
local HostOrderManager = Import("host/managers/orders/hostOrderManager.lua")

-- UEF factory rigs are static Sanctuary rigs. The native EDA factory
-- behavior stays authoritative; only its build staging and extra exit
-- reservation are adapted to the imported model.
local EDALandFactory = HostEDALandFactory or EDALandFactory
if not EDALandFactory then
    error("SCO could not resolve the host EDA land-factory base class.")
end
HostEDAUefLandFactory = Class("EDAUefLandFactory", EDALandFactory)
local EDAUefLandFactory = HostEDAUefLandFactory

function EDAUefLandFactory:UpdateAnimations()
    -- Static factories have no Movement component. The personal UEF
    -- factory contract intentionally registers no walk/run animations.
end

function EDAUefLandFactory:GetConstructionSpawnPoint()
    local offset = self.tp.additions and self.tp.additions.buildStagingOffset
    if not offset then
        return EDALandFactory.GetConstructionSpawnPoint(self)
    end

    local rotated = Engine.QuaternionRotateVector(
        self:GetOrientation(),
        EngineClasses.float3(
            offset.x or 0,
            offset.y or 0,
            offset.z or 0))
    local origin = self:GetPosition()
    return EngineClasses.float3(
        origin.x + rotated.x,
        origin.y + rotated.y,
        origin.z + rotated.z)
end

local function GetEdaUefFactoryRollOffRamps(factory)
    local additions = factory.tp.additions
    return additions and additions.rollOffRamps
end

local function GetEdaUefFactoryRollOffRampPosition(factory, offset)
    local rotated = Engine.QuaternionRotateVector(
        factory:GetOrientation(),
        EngineClasses.float3(
            offset.x or 0,
            offset.y or 0,
            offset.z or 0))
    local origin = factory:GetPosition()
    return EngineClasses.float3(
        origin.x + rotated.x,
        origin.y + rotated.y,
        origin.z + rotated.z)
end

local function GetEdaUefFactoryRollOffTargetKey(targetUnit)
    local id = targetUnit and targetUnit.id
    if not id then
        return nil
    end
    return tostring(id.index) .. ":" .. tostring(id.version)
end

local function SelectEdaUefFactoryRollOffRamp(factory, targetUnit)
    local ramps = GetEdaUefFactoryRollOffRamps(factory)
    if not ramps or #ramps == 0 then
        return nil
    end

    local key = GetEdaUefFactoryRollOffTargetKey(targetUnit)
    local selectedIndexes = factory.edaUefRollOffRampIndexes
    local selectedIndex = key and selectedIndexes and selectedIndexes[key]
    if selectedIndex then
        return ramps[selectedIndex]
    end

    local source = factory.unitBeingBuiltSource or factory
    local rallyPoint = source.rallyPoint
    if rallyPoint then
        local closestDistanceSquared = nil
        for index, ramp in ipairs(ramps) do
            local clearancePosition = GetEdaUefFactoryRollOffRampPosition(factory, ramp.clearanceOffset or ramp.rampOffset)
            local deltaX = clearancePosition.x - rallyPoint.x
            local deltaZ = clearancePosition.z - rallyPoint.z
            local distanceSquared = (deltaX * deltaX) + (deltaZ * deltaZ)
            if not closestDistanceSquared or distanceSquared < closestDistanceSquared then
                closestDistanceSquared = distanceSquared
                selectedIndex = index
            end
        end
    else
        selectedIndex = factory.edaUefNextRollOffRampIndex or 1
        if selectedIndex < 1 or selectedIndex > #ramps then
            selectedIndex = 1
        end
        factory.edaUefNextRollOffRampIndex = selectedIndex + 1
        if factory.edaUefNextRollOffRampIndex > #ramps then
            factory.edaUefNextRollOffRampIndex = 1
        end
    end

    if key then
        factory.edaUefRollOffRampIndexes = selectedIndexes or {}
        factory.edaUefRollOffRampIndexes[key] = selectedIndex
    end
    return ramps[selectedIndex]
end

local function FaceEdaUefFactoryUnitTowardRamp(factory, targetUnit, ramp)
    if not targetUnit or not ramp then
        return
    end

    if ramp.headingDegrees then
        local localOrientation = Engine.EulerToQuaternion(
            EngineClasses.float3(0, math.rad(ramp.headingDegrees), 0),
            RotationOrder.Default)
        local orientation = Engine.QuaternionMultiply(
            factory:GetOrientation(),
            localOrientation)
        targetUnit:SetOrientation(orientation)
        return
    end

    local unitPosition = targetUnit:GetPosition()
    local rampPosition = GetEdaUefFactoryRollOffRampPosition(factory, ramp.rampOffset)
    local forward = EngineClasses.float3(
        rampPosition.x - unitPosition.x,
        0,
        rampPosition.z - unitPosition.z
    )
    if forward.x == 0 and forward.z == 0 then
        return
    end

    local orientation = EngineClasses.quaternion()
    Engine.QuaternionLookRotation(
        math3D.normalize(forward),
        EngineClasses.float3(0, 1, 0),
        orientation
    )
    Engine.SetGlobalEntityLocalRotation(targetUnit.id, orientation)
end

local function PrepareEdaUefFactoryRollOff(factory, targetUnit)
    if not targetUnit or not targetUnit:HasTags(Tags.MOBILE) then
        return
    end
    FaceEdaUefFactoryUnitTowardRamp(factory, targetUnit, SelectEdaUefFactoryRollOffRamp(factory, targetUnit))
end

local function EdaUefFactoryUnitIsAlive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
end

local function GetEdaUefFactoryClearancePoint(factory, ramp)
    if not ramp then
        return nil
    end

    local clearancePosition = GetEdaUefFactoryRollOffRampPosition(
        factory,
        ramp.clearanceOffset or ramp.rampOffset
    )
    local _, terrainHeight = Engine.SampleTerrainHeight(
        EngineClasses.float3(clearancePosition.x, 0, clearancePosition.z)
    )
    return EngineClasses.float3(clearancePosition.x, terrainHeight, clearancePosition.z)
end

function EDAUefLandFactory:StopBuildColliderPin(targetUnit)
    if targetUnit ~= nil and self.edaUefPinnedBuildTarget ~= targetUnit then
        return
    end

    local pinnedTarget = self.edaUefPinnedBuildTarget
    self.edaUefPinnedBuildTarget = nil
    if pinnedTarget and pinnedTarget.scoFactoryColliderPinOwner == self then
        pinnedTarget.scoFactoryColliderPinOwner = nil
    end
end

function EDAUefLandFactory:PinBuildCollider(targetUnit)
    self:StopBuildColliderPin()
    if not EdaUefFactoryUnitIsAlive(targetUnit)
        or not targetUnit:HasTags(Tags.MOBILE)
        or targetUnit:IsCompleted()
    then
        return
    end

    self.edaUefPinnedBuildTarget = targetUnit
    targetUnit.scoFactoryColliderPinOwner = self
    Engine.SetVolumeColliderEnabled(targetUnit.id, false)
end

function EDAUefLandFactory:ReleaseBuiltUnit(targetUnit, ramp)
    if not EdaUefFactoryUnitIsAlive(targetUnit)
        or not targetUnit:HasTags(Tags.MOBILE)
        or not targetUnit:IsCompleted()
    then
        return false
    end

    local clearancePoint = GetEdaUefFactoryClearancePoint(self, ramp)
    if not clearancePoint then
        return false
    end

    -- Relocate before collision returns. Enabling it at the staging point
    -- allows the finished unit to intersect, sink through, or roll through
    -- the converted factory hull.
    FaceEdaUefFactoryUnitTowardRamp(self, targetUnit, ramp)
    targetUnit:SetPosition(clearancePoint)
    self:StopBuildColliderPin(targetUnit)
    if EdaUefFactoryUnitIsAlive(targetUnit) then
        Engine.SetVolumeColliderEnabled(targetUnit.id, true)
    end
    return true
end

function EDAUefLandFactory:OnStartBuildRoutine(targetUnit)
    self:PinBuildCollider(targetUnit)
    EDALandFactory.OnStartBuildRoutine(self, targetUnit)
    PrepareEdaUefFactoryRollOff(self, targetUnit)
    if EdaUefFactoryUnitIsAlive(targetUnit)
        and targetUnit:HasTags(Tags.MOBILE)
        and not targetUnit:IsCompleted()
    then
        Engine.SetVolumeColliderEnabled(targetUnit.id, false)
    end
end

function EDAUefLandFactory:OnStopBuildRoutine(targetUnit)
    local completed = EdaUefFactoryUnitIsAlive(targetUnit) and targetUnit:IsCompleted()
    if completed then
        -- The base callback notifies clients and restores local collision,
        -- so the host must put a completed child clear of the hull first.
        self:ReleaseBuiltUnit(targetUnit, SelectEdaUefFactoryRollOffRamp(self, targetUnit))
    elseif EdaUefFactoryUnitIsAlive(targetUnit) and targetUnit:HasTags(Tags.MOBILE) then
        Engine.SetVolumeColliderEnabled(targetUnit.id, false)
    end
    EDALandFactory.OnStopBuildRoutine(self, targetUnit)
end

function EDAUefLandFactory:RollOffUnit(targetUnit)
    local ramp = SelectEdaUefFactoryRollOffRamp(self, targetUnit)
    if not ramp then
        EDALandFactory.RollOffUnit(self, targetUnit)
        return
    end

    FaceEdaUefFactoryUnitTowardRamp(self, targetUnit, ramp)
    local rampPosition = GetEdaUefFactoryRollOffRampPosition(self, ramp.rampOffset)
    local clearancePosition = GetEdaUefFactoryRollOffRampPosition(self, ramp.clearanceOffset or ramp.rampOffset)
    local released = self:ReleaseBuiltUnit(targetUnit, ramp)
    if not released then
        HostOrderManager.HostIssueOrder(OrderTasks.MOVE, {targetUnit}, false, rampPosition, nil)
        HostOrderManager.HostIssueOrder(OrderTasks.MOVE, {targetUnit}, true, clearancePosition, nil)
    end

    local source = self.unitBeingBuiltSource or self
    if source.rallyPoint then
        HostOrderManager.HostIssueOrder(OrderTasks.MOVE, {targetUnit}, true, source.rallyPoint, nil)
    end

    local key = GetEdaUefFactoryRollOffTargetKey(targetUnit)
    if key and self.edaUefRollOffRampIndexes then
        self.edaUefRollOffRampIndexes[key] = nil
    end
end

function EDAUefLandFactory:ProductionBehaviorStop()
    local targetUnit = self.productionBehaviorTargetUnit
    self:StopBuildColliderPin(targetUnit)
    EDALandFactory.ProductionBehaviorStop(self)
end

function EDAUefLandFactory:OnCancelConstruction()
    self:StopBuildColliderPin()
    EDALandFactory.OnCancelConstruction(self)
end

-- The 6x6 art core uses the normal factory grid modifier. Two distinct
-- 6x4 roots protect the left and right UEF roll-off lanes.
local PlacementLayer = Import("common/layers.lua").PlacementLayer
local EdaUefFactoryRollOffReservationPrefabID = nil
_G.SupremeCommanderOverhaulFactoryReservationOwners = _G.SupremeCommanderOverhaulFactoryReservationOwners or {}

local function OverhaulFactoryReservationKey(id)
    return tostring(id.index) .. ":" .. tostring(id.version)
end

local function GetEdaUefFactoryRollOffReservationPrefabID()
    if EdaUefFactoryRollOffReservationPrefabID then
        return EdaUefFactoryRollOffReservationPrefabID
    end

    local prefab = EngineClasses.PrefabTemplate("SupremeCommanderOverhaulEdaUefFactoryRollOffGlobal")
    local head = EngineClasses.EntityTemplate()
    head.entityName = TemplateHeadEntityName
    head.localTranslation = EngineClasses.float3(0, 0, 0)
    head.localScale = 1
    head.localRotation = GetIdentityQuaternion()
    head.forceSimulated = false
    table.insert(prefab.hierarchyTemplate.entities, head)
    table.insert(prefab.globalTemplate.gridModifierTemplates, EngineClasses.GridModifierTemplate(
        TemplateHeadEntityName,
        EngineClasses.int2(0, 0),
        EngineClasses.int2(0, 0),
        _G.globalBuildingPlacementGridID,
        PlacementLayer.Default,
        PlacementLayer.None,
        false
    ))

    local errorCode, prefabID = Engine.CreatePrefab(prefab)
    if errorCode ~= EngineErrorCode.Success then
        Engine.Error("Unable to create the EDA UEF factory roll-off reservation prefab.")
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
        _G.SupremeCommanderOverhaulFactoryReservationOwners[OverhaulFactoryReservationKey(reservationID)] = nil
        if Engine.IsValidGlobalID(reservationID) then
            Engine.SetGlobalGridModifierEnabled(reservationID, false)
            Engine.DeletePrefabInstance(reservationID)
        end
    end
end

function EDAUefLandFactory:CreateRollOffReservation()
    if self.edaUefRollOffReservationIDs then
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
            Engine.Error("EDA UEF factory roll-off reservation is missing a size.")
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
        if errorCode ~= EngineErrorCode.Success or not Engine.IsValidGlobalID(reservationID) then
            if Engine.IsValidGlobalID(reservationID) then
                Engine.DeletePrefabInstance(reservationID)
            end
            DestroyEdaUefFactoryRollOffReservationIDs(reservationIDs)
            Engine.Error("Unable to create an EDA UEF factory roll-off reservation.")
            return
        end

        Engine.SetGlobalGridModifierSize(reservationID, EngineClasses.float2(size.x, size.y))
        table.insert(reservationIDs, reservationID)
    end

    self.edaUefRollOffReservationIDs = reservationIDs
    for _, reservationID in ipairs(reservationIDs) do
        _G.SupremeCommanderOverhaulFactoryReservationOwners[OverhaulFactoryReservationKey(reservationID)] = self.id
        Engine.SetGlobalGridModifierEnabled(reservationID, true)
    end
end

function EDAUefLandFactory:DestroyRollOffReservation()
    DestroyEdaUefFactoryRollOffReservationIDs(self.edaUefRollOffReservationIDs)
    self.edaUefRollOffReservationIDs = nil
end

function EDAUefLandFactory:PromoteToUnit()
    EDALandFactory.PromoteToUnit(self)
    self:CreateRollOffReservation()
end

function EDAUefLandFactory:OnDestroy(isDelete)
    self:StopBuildColliderPin()
    self:DestroyRollOffReservation()
    EDALandFactory.OnDestroy(self, isDelete)
end

-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0
local EDAStructure = HostEDAStructure or EDAStructure
local EDAAlloyExtractor = HostEDAAlloyExtractor or EDAAlloyExtractor
local EDAEnergyGenerator = HostEDAEnergyGenerator or EDAEnergyGenerator
local EDALandUnit = HostEDALandUnit or EDALandUnit
if not EDAStructure or not EDAAlloyExtractor or not EDAEnergyGenerator or not EDALandUnit then
    error("SCO could not resolve the host EDA base classes.")
end
HostEDAImportedAnimatedStructure = Class("EDAImportedAnimatedStructure", EDAStructure)
local EDAImportedAnimatedStructure = HostEDAImportedAnimatedStructure

function EDAImportedAnimatedStructure:UpdateAnimations()
    -- Imported static clips are behavior-driven; these units have no Movement component.
end

HostEDAImportedAnimatedAlloyExtractor = Class("EDAImportedAnimatedAlloyExtractor", EDAAlloyExtractor)
local EDAImportedAnimatedAlloyExtractor = HostEDAImportedAnimatedAlloyExtractor

function EDAImportedAnimatedAlloyExtractor:UpdateAnimations()
    -- Imported static clips are behavior-driven; these units have no Movement component.
end

HostEDAImportedAnimatedEnergyGenerator = Class("EDAImportedAnimatedEnergyGenerator", EDAEnergyGenerator)
local EDAImportedAnimatedEnergyGenerator = HostEDAImportedAnimatedEnergyGenerator

function EDAImportedAnimatedEnergyGenerator:__init(id, army, template, fractionCompleted)
    EDAEnergyGenerator.__init(self, id, army, template, fractionCompleted)
    if self.tpId == "ues1611" then
        local generator = self
        self:AddCallback(function(amount)
            generator:SCO_OnFaT1PowerDamaged(amount)
        end, "OnDamaged")
    end
end

function EDAImportedAnimatedEnergyGenerator:UpdateAnimations()
    -- The default activation clip is renderer-owned; this structure has no Movement component.
end

function EDAImportedAnimatedEnergyGenerator:SCO_BeginFaT1PowerOpening(generation)
    if self.dead or self.tpId ~= "ues1611" or self.scoFaT1PowerLifecycleGeneration ~= generation then
        return
    end
    self.scoFaT1PowerDamageRecoveryPending = false
    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations
    local activation = animations and animations.walk
    if not activation or not activation.id then
        error("ues1611 requires its source procedural activation clip")
    end
    self:SetRotatorsEnabled(false)
    Engine.PlayAnimation(self.id, activation.id, 0.1)
    self:NewThread(self.SCO_FinishFaT1PowerOpeningThread, generation)
end

function EDAImportedAnimatedEnergyGenerator:SCO_FinishFaT1PowerOpeningThread(generation)
    WaitSeconds(0.6)
    if not self.dead and self.scoFaT1PowerLifecycleGeneration == generation then
        self:SetRotatorsEnabled(true)
    end
end

function EDAImportedAnimatedEnergyGenerator:SCO_RestoreFaT1PowerThread(generation)
    WaitSeconds(10)
    if not self.dead and self.scoFaT1PowerLifecycleGeneration == generation then
        self:SCO_BeginFaT1PowerOpening(generation)
    end
end

function EDAImportedAnimatedEnergyGenerator:SCO_OnFaT1PowerDamaged(_amount)
    if self.dead or self.tpId ~= "ues1611" or not self:IsCompleted() then
        return
    end
    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations
    local rest = animations and animations.rest
    if not rest or not rest.id then
        error("ues1611 requires its source procedural rest pose")
    end
    self.scoFaT1PowerLifecycleGeneration = (self.scoFaT1PowerLifecycleGeneration or 0) + 1
    local generation = self.scoFaT1PowerLifecycleGeneration
    self.scoFaT1PowerDamageRecoveryPending = true
    self:SetRotatorsEnabled(false)
    Engine.PlayAnimation(self.id, rest.id, 0.1)
    self:NewThread(self.SCO_RestoreFaT1PowerThread, generation)
end

function EDAImportedAnimatedEnergyGenerator:OnStopBeingBuilt()
    EDAEnergyGenerator.OnStopBeingBuilt(self)
    if self.tpId ~= "ues1611" then
        return
    end
    if self.scoFaT1PowerDamageRecoveryPending then
        self:SetRotatorsEnabled(false)
        return
    end
    self.scoFaT1PowerLifecycleGeneration = (self.scoFaT1PowerLifecycleGeneration or 0) + 1
    self:SCO_BeginFaT1PowerOpening(self.scoFaT1PowerLifecycleGeneration)
end

HostEDAImportedFaLandUnit = Class("EDAImportedFaLandUnit", EDALandUnit)
local EDAImportedFaLandUnit = HostEDAImportedFaLandUnit

function EDAImportedFaLandUnit:UpdateAnimations()
    local deploy = self.tp and self.tp.additions and self.tp.additions.faWeaponDeploy
    local weapon = self.weapons and self.weapons[1]
    if deploy and weapon and not self.dead then
        local now = GetGameTimeSeconds()
        if weapon:HasTarget() then
            self.scoFaLastWeaponTargetTime = now
            if not self.scoFaWeaponDeployed then
                local animation = self.tp.visuals.animations[deploy.deployAnimationKey]
                if not animation or not animation.id then
                    error(self.tpId .. " requires its source deploy animation")
                end
                Engine.PlayAnimation(self.id, animation.id, 0.1)
                self.scoFaWeaponDeployed = true
                self.scoFaWeaponReadyTime = now + deploy.deploySeconds
                if deploy.sourceWeaponUnpackLocksMotion then
                    self.scoFaWeaponMovementLocked = true
                    Engine.SetMovementEnabled(self.id, false)
                end
            end
        elseif self.scoFaWeaponDeployed
            and now >= (self.scoFaLastWeaponTargetTime or now) + deploy.repackSeconds
        then
            local animation = self.tp.visuals.animations[deploy.packAnimationKey]
            if not animation or not animation.id then
                error(self.tpId .. " requires its source pack animation")
            end
            Engine.PlayAnimation(self.id, animation.id, 0.1)
            self.scoFaWeaponDeployed = false
            self.scoFaWeaponReadyTime = nil
            if self.scoFaWeaponMovementLocked then
                self.scoFaWeaponMovementLocked = false
                Engine.SetMovementEnabled(self.id, true)
            end
        end
    end
    return EDALandUnit.UpdateAnimations(self)
end

function EDAImportedFaLandUnit:DeathThread(overkillRatio)
    if self.tpId == "uel1002" then
        local animations = self.tp and self.tp.visuals and self.tp.visuals.animations
        local useFirst = ((self.id and self.id.index) or 0) % 2 == 0
        local death = animations and (useFirst and animations.death01 or animations.death02)
        if not death or not death.id then
            error("uel1002 requires both source death animations")
        end
        Engine.PlayAnimation(self.id, death.id, 0.1)
        WaitSeconds(0.8)
    end
    return EDALandUnit.DeathThread(self, overkillRatio)
end

-- Keep the real UEL0106 death pose active until the wreck hierarchy is copied.
function EDAImportedFaLandUnit:DeathThread(overkillRatio)
    if self.tpId ~= "uel1002" then
        return EDALandUnit.DeathThread(self, overkillRatio)
    end
    if self.deleted or self.scoMechMarineDeathStarted then return end
    assert(self.dead, "uel1002 death must run after native OnDestroy")
    self.scoMechMarineDeathStarted = true
    self.isAnimated = false
    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations
    local useFirst = ((self.id and self.id.index) or 0) % 2 == 0
    local death = animations and (useFirst and animations.death01 or animations.death02)
    assert(death and death.id and death.playbackMode == AnimationPlaybackMode.Clamp,
        "uel1002 requires both source death animations registered with Clamp")
    Engine.SetMovementCollisionMask(self.id, 0)
    Engine.SetAnimatorEnabled(self.id, true)
    local durationSeconds = 0.8
    local elapsed = 0
    while not self.deleted and elapsed < durationSeconds do
        Engine.PlayAnimation(self.id, death.id, -10000 + elapsed)
        local step = math.min(0.1, durationSeconds - elapsed)
        WaitSeconds(step)
        elapsed = math.min(durationSeconds, elapsed + step)
    end
    if not self.deleted then
        Engine.PlayAnimation(self.id, death.id, -10000 + durationSeconds)
        return EDALandUnit.DeathThread(self, overkillRatio)
    end
end

-- Supreme Commander Overhaul FA Air Factories 1.0.0
local SCOFaAirFactoryHostBase = HostEDAAirFactory or EDAAirFactory
local SCOFaAirFactoryLifecycle = _G.SCOFaAirFactoryLifecycle
if not SCOFaAirFactoryHostBase or not SCOFaAirFactoryLifecycle then
    error("FA air-factory host dependencies are unavailable.")
end
HostEDAFaUefAirFactory = Class("EDAFaUefAirFactory", SCOFaAirFactoryHostBase)
local SCOFaAirFactoryHostClass = HostEDAFaUefAirFactory

function SCOFaAirFactoryHostClass:__init(id, army, template, progress, builder)
    SCOFaAirFactoryHostBase.__init(self, id, army, template, progress, builder)
    SCOFaAirFactoryLifecycle.BindPlatform(self)
end

function SCOFaAirFactoryHostClass:UpdateAnimations()
    -- Static factory clips have one lifecycle writer and no Movement state.
end

function SCOFaAirFactoryHostClass:OnStartBuildRoutine(targetUnit)
    SCOFaAirFactoryHostBase.OnStartBuildRoutine(self, targetUnit)
    SCOFaAirFactoryLifecycle.StartBuild(self, targetUnit)
end

function SCOFaAirFactoryHostClass:OnStopBuildRoutine(targetUnit)
    SCOFaAirFactoryHostBase.OnStopBuildRoutine(self, targetUnit)
    SCOFaAirFactoryLifecycle.StopBuild(self, targetUnit)
end

function SCOFaAirFactoryHostClass:OnPauseProduction()
    SCOFaAirFactoryHostBase.OnPauseProduction(self)
end

function SCOFaAirFactoryHostClass:OnUnpauseProduction()
    SCOFaAirFactoryHostBase.OnUnpauseProduction(self)
end

function SCOFaAirFactoryHostClass:OnDestroy(isDelete)
    SCOFaAirFactoryLifecycle.CancelBuild(self)
    SCOFaAirFactoryHostBase.OnDestroy(self, isDelete)
end
-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0
local SCOFaEngineerWaterLifecycle = _G.SCOFaEngineerWaterLifecycle
local SCOFaEngineerWaterEda = HostEDAUefEngineer or EDAUefEngineer
if not SCOFaEngineerWaterLifecycle or not SCOFaEngineerWaterEda then
    error("FA engineer water lifecycle could not resolve EDA dependencies")
end
local SCOFaEngineerWaterEdaStopBuilt = SCOFaEngineerWaterEda.OnStopBeingBuilt
local SCOFaEngineerWaterEdaStartBuild = SCOFaEngineerWaterEda.OnStartBuildRoutine
local SCOFaEngineerWaterEdaStopBuild = SCOFaEngineerWaterEda.OnStopBuildRoutine
local SCOFaEngineerWaterEdaDestroy = SCOFaEngineerWaterEda.OnDestroy

function SCOFaEngineerWaterEda:OnStopBeingBuilt(...)
    SCOFaEngineerWaterEdaStopBuilt(self, ...)
    SCOFaEngineerWaterLifecycle.Start(self)
end

function SCOFaEngineerWaterEda:OnStartBuildRoutine(targetUnit)
    SCOFaEngineerWaterLifecycle.Suspend(self)
    return SCOFaEngineerWaterEdaStartBuild(self, targetUnit)
end

function SCOFaEngineerWaterEda:OnStopBuildRoutine(targetUnit)
    local result = SCOFaEngineerWaterEdaStopBuild(self, targetUnit)
    if not self:IsRepairRoutineEnabled()
        and not self:IsReclaimRoutineEnabled()
        and SCOFaEngineerWaterLifecycle.IsSupported(self)
    then
        local config = self.tp.additions.faEngineerWaterAnimation
        SCOFaEngineerWaterLifecycle.ResumeAfter(self, config.buildCloseSeconds + Constants.TickTimeStep)
    end
    return result
end

function SCOFaEngineerWaterEda:OnDestroy(...)
    local result = SCOFaEngineerWaterEdaDestroy(self, ...)
    if SCOFaEngineerWaterLifecycle.IsSupported(self) then
        SCOFaEngineerWaterLifecycle.Stop(self)
    end
    return result
end
-- Repair shares the same one-component pose ownership as construction.
local SCOFaEngineerWaterEdaStartRepair = SCOFaEngineerWaterEda.OnStartRepairRoutine
local SCOFaEngineerWaterEdaStopRepair = SCOFaEngineerWaterEda.OnStopRepairRoutine

function SCOFaEngineerWaterEda:OnStartRepairRoutine(targetUnit)
    SCOFaEngineerWaterLifecycle.Suspend(self)
    return SCOFaEngineerWaterEdaStartRepair(self, targetUnit)
end

function SCOFaEngineerWaterEda:OnStopRepairRoutine(targetUnit)
    local result = SCOFaEngineerWaterEdaStopRepair(self, targetUnit)
    if not self:IsBuildRoutineEnabled()
        and not self:IsReclaimRoutineEnabled()
        and SCOFaEngineerWaterLifecycle.IsSupported(self)
    then
        local config = self.tp.additions.faEngineerWaterAnimation
        SCOFaEngineerWaterLifecycle.ResumeAfter(self, config.buildCloseSeconds + Constants.TickTimeStep)
    end
    return result
end

-- Reclaim is a native work routine with the same UEF arm and water-pose owner.
local SCOFaEngineerWaterEdaStartReclaim = SCOFaEngineerWaterEda.OnStartReclaimRoutine
local SCOFaEngineerWaterEdaStopReclaim = SCOFaEngineerWaterEda.OnStopReclaimRoutine

function SCOFaEngineerWaterEda:OnStartReclaimRoutine(targetUnit)
    SCOFaEngineerWaterLifecycle.Suspend(self)
    return SCOFaEngineerWaterEdaStartReclaim(self, targetUnit)
end

function SCOFaEngineerWaterEda:OnStopReclaimRoutine(targetUnit)
    local result = SCOFaEngineerWaterEdaStopReclaim(self, targetUnit)
    if not self:IsBuildRoutineEnabled()
        and not self:IsRepairRoutineEnabled()
        and SCOFaEngineerWaterLifecycle.IsSupported(self)
    then
        local config = self.tp.additions.faEngineerWaterAnimation
        SCOFaEngineerWaterLifecycle.ResumeAfter(self, config.buildCloseSeconds + Constants.TickTimeStep)
    end
    return result
end


-- Supreme Commander Overhaul FA Direct Structures 1.0.0
local SCO_EDAAlloyExtractor = HostEDAAlloyExtractor or EDAAlloyExtractor
local SCO_EDAEngineeringStation = HostEDAEngineeringStation or EDAEngineeringStation
if not SCO_EDAAlloyExtractor or not SCO_EDAEngineeringStation then
    error("SCO direct structures could not resolve host EDA bases.")
end

local function SCO_FabricatorIsActive(self)
    return self:IsCompleted()
        and self:GetProductionToggle()
        and not self.army.economy.isEnergyDown
end

HostEDASupComMassFabricator = Class("EDASupComMassFabricator", SCO_EDAAlloyExtractor)
local EDASupComMassFabricator = HostEDASupComMassFabricator

function EDASupComMassFabricator:RotatorsEnabledOnConstruction()
    return false
end

function EDASupComMassFabricator:SCOSetFabricatorRotorTarget(targetSpeed)
    if self.scoFabricatorRotorTarget == targetSpeed and self.scoFabricatorRotorThread then
        return
    end
    if self.scoFabricatorRotorThread then
        KillThread(self.scoFabricatorRotorThread)
    end
    self.scoFabricatorRotorTarget = targetSpeed
    self.scoFabricatorRotorThread = self:NewThread(self.SCOFabricatorRotorRampThread, targetSpeed)
end

function EDASupComMassFabricator:SCOFabricatorRotorRampThread(targetSpeed)
    local rotor = self.rotatorIds and self.rotatorIds[1]
    if not rotor then
        error("UEB1303 Spinner rotator is missing.")
    end
    local speed = self.scoFabricatorRotorSpeed or 0
    self:SetRotatorsEnabled(true)
    while not self.dead and math.abs(targetSpeed - speed) > 0.000001 do
        local delta = math.min(math.abs(targetSpeed - speed), 1)
        speed = speed + (targetSpeed > speed and delta or -delta)
        self.scoFabricatorRotorSpeed = speed
        Engine.SetRotatorSpeed(rotor, EngineClasses.float3(0, 0, speed))
        WaitSeconds(0.1)
    end
    if targetSpeed == 0 then
        self:SetRotatorsEnabled(false)
    end
    self.scoFabricatorRotorThread = nil
end

function EDASupComMassFabricator:CheckProductionState()
    local active = SCO_FabricatorIsActive(self)
    if self.resourceEntities.production then
        self.resourceEntities.production:SetEnabled(active)
    end
    if self.rotatorIds and self.rotatorIds[1] then
        self:SCOSetFabricatorRotorTarget(active and 40 or 0)
    end
end

function EDASupComMassFabricator:OnStopBeingBuilt()
    SCO_EDAAlloyExtractor.OnStopBeingBuilt(self)
    self:CheckProductionState()
end

function EDASupComMassFabricator:OnEnergyDown()
    SCO_EDAAlloyExtractor.OnEnergyDown(self)
    self:CheckProductionState()
end

function EDASupComMassFabricator:OnEnergyUp()
    SCO_EDAAlloyExtractor.OnEnergyUp(self)
    self:CheckProductionState()
end

HostEDASupComKennelT2 = Class("EDASupComKennelT2", SCO_EDAEngineeringStation)
local EDASupComKennelT2 = HostEDASupComKennelT2

function EDASupComKennelT2:UpdateAnimations()
end

function EDASupComKennelT2:OnStartBuildRoutine(targetUnit)
    SCO_EDAEngineeringStation.OnStartBuildRoutine(self, targetUnit)
    if self:IsUpgrading() or self.scoKennelPodOpen then
        return
    end
    local animation = self.tp.visuals.animations.podOpen
    self.scoKennelPodOpen = true
    Engine.PlayAnimation(self.id, animation.id, 0.1)
end

function EDASupComKennelT2:OnStopBuildRoutine(targetUnit)
    SCO_EDAEngineeringStation.OnStopBuildRoutine(self, targetUnit)
    if self:IsUpgrading() or not self.scoKennelPodOpen then
        return
    end
    local animation = self.tp.visuals.animations.podResume
    self.scoKennelPodOpen = false
    Engine.PlayAnimation(self.id, animation.id, 0.1)
end

HostEDASupComKennelT3 = Class("EDASupComKennelT3", SCO_EDAEngineeringStation)
local EDASupComKennelT3 = HostEDASupComKennelT3

function EDASupComKennelT3:UpdateAnimations()
end

function EDASupComKennelT3:OnStopBeingBuilt()
    SCO_EDAEngineeringStation.OnStopBeingBuilt(self)
    local animation = self.tp.visuals.animations.open
    Engine.PlayAnimation(self.id, animation.id, 0.1)
end
-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0
-- Keep uel3001 on its stock EDALandUnit class.  Stock completion owns its
-- initially enabled personal shield; this appendix only owns Titan deaths.
local SCO_FaRoleStockEdaDeathThread = HostEDALandUnit.DeathThread

function HostEDALandUnit:DeathThread(overkillRatio)
    if self.tpId ~= "uel3001" then
        return SCO_FaRoleStockEdaDeathThread(self, overkillRatio)
    end

    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations
    local useFirst = ((self.id and self.id.index) or 0) % 2 == 0
    local death = animations and (useFirst and animations.death01 or animations.death02)
    if not death or not death.id then
        error("UEL3001 Titan requires both hash-pinned source death clips")
    end
    Engine.PlayAnimation(self.id, death.id, 0.1)
    WaitSeconds(useFirst and 3.4 or 1.9)
    return SCO_FaRoleStockEdaDeathThread(self, overkillRatio)
end
-- Supreme Commander Overhaul UEF Percival 1.0.0
-- HostUnit:Destroy marks the unit dead before starting DeathThread. Preserve
-- the three equal-weight FA terminal clips while collision is disabled.
local SCO_PercivalStockDeathThread = HostEDALandUnit.DeathThread
function HostEDALandUnit:DeathThread(overkillRatio)
    if self.tpId ~= "uel3401" then
        return SCO_PercivalStockDeathThread(self, overkillRatio)
    end
    if not self.dead then
        error("UEL3401 Percival death animation must run after HostUnit:OnDestroy")
    end
    Engine.SetMovementCollisionMask(self.id, 0)
    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations
    local bucket = ((self.id and self.id.index) or 0) % 3
    local death = animations and (bucket == 0 and animations.death01
        or bucket == 1 and animations.death02 or animations.death03)
    if not death or not death.id then
        error("UEL3401 Percival requires all three source-pinned death clips")
    end
    Engine.PlayAnimation(self.id, death.id, 0.1)
    WaitSeconds(bucket == 1 and 2.3333332538604736 or 2)
    return SCO_PercivalStockDeathThread(self, overkillRatio)
end

-- Supreme Commander Overhaul sea parity 1.0.0
local SCOSeaParityNavalFactoryHostBase = HostEDANavalFactory
local SCOSeaParityFactoryLifecycle = _G.SCOFaAirFactoryLifecycle
local SCOSeaParityHostOrderManager = Import("host/managers/orders/hostOrderManager.lua")
local SCOSeaParityOrderTasks = Import("common/commonOrders.lua").OrderTasks
if not SCOSeaParityNavalFactoryHostBase or not SCOSeaParityFactoryLifecycle then
    error("Sea-parity naval-factory host dependencies are unavailable.")
end

HostEDAFaUefNavalFactory = Class("EDAFaUefNavalFactory", SCOSeaParityNavalFactoryHostBase)
local SCOSeaParityNavalFactoryHostClass = HostEDAFaUefNavalFactory

local function SCOSeaParityRotateFactoryOffset(factory, offset, scale, waterLevel)
    local rotated = Engine.QuaternionRotateVector(
        factory:GetOrientation(),
        EngineClasses.float3(
            (offset.x or 0) * scale,
            (offset.y or 0) * scale,
            (offset.z or 0) * scale))
    local origin = factory:GetPosition()
    return EngineClasses.float3(
        origin.x + rotated.x,
        waterLevel or origin.y + rotated.y,
        origin.z + rotated.z)
end

-- Supreme Commander Overhaul usable naval factory rolloff 1.0.0
local function SCOSeaParityRolloffMinimumDepth(factory)
    local additions = factory.tp and factory.tp.additions
    local faContract = additions and additions.faSourceContract
    local authored = faContract and faContract.minimumWaterDepth
    if type(authored) == "number" and authored >= 0 then
        return authored
    end
    return 1.5
end

local function SCOSeaParityRolloffRouteIsSubmerged(
    factory, route, waterLevel, minimumDepth)
    if not route or not route.offset then return false end
    local routePoint = SCOSeaParityRotateFactoryOffset(
        factory, route.offset, 1, waterLevel)
    local exitPoint = SCOSeaParityRotateFactoryOffset(
        factory, route.offset, route.exitScale or 2, waterLevel)
    local routeError, routeTerrain = Engine.SampleTerrainHeight(routePoint)
    local exitError, exitTerrain = Engine.SampleTerrainHeight(exitPoint)
    return routeError == EngineErrorCode.Success
        and exitError == EngineErrorCode.Success
        and routeTerrain <= waterLevel - minimumDepth
        and exitTerrain <= waterLevel - minimumDepth
end

local function SCOSeaParitySelectRolloffRoute(factory, rallyPoint, waterLevel)
    local routes = factory.tp.construction and factory.tp.construction.rollOffPoints
    if not routes or #routes ~= 2 then
        error("Sea-parity naval factory lost its two-route contract.")
    end
    local minimumDepth = SCOSeaParityRolloffMinimumDepth(factory)
    local selected = nil
    local selectedDistance = nil
    for _, route in ipairs(routes) do
        if SCOSeaParityRolloffRouteIsSubmerged(
            factory, route, waterLevel, minimumDepth)
        then
            if rallyPoint == nil then return route end
            local point = SCOSeaParityRotateFactoryOffset(
                factory, route.offset, 1, waterLevel)
            local dx = point.x - rallyPoint.x
            local dz = point.z - rallyPoint.z
            local distance = dx * dx + dz * dz
            if selectedDistance == nil or distance < selectedDistance then
                selected = route
                selectedDistance = distance
            end
        end
    end
    if selected == nil then
        error("Sea-parity naval factory has no submerged rolloff route.")
    end
    return selected
end

function SCOSeaParityNavalFactoryHostClass:__init(id, army, template, progress, builder)
    SCOSeaParityNavalFactoryHostBase.__init(self, id, army, template, progress, builder)
    SCOSeaParityFactoryLifecycle.BindPlatform(self)
end

function SCOSeaParityNavalFactoryHostClass:UpdateAnimations()
    -- Static factory animation is owned by the SCOM sentinel sampler.
end

function SCOSeaParityNavalFactoryHostClass:OnStartBuildRoutine(targetUnit)
    if targetUnit and targetUnit:HasTags(Tags.MOBILE)
        and not targetUnit:IsCompleted()
    then
        targetUnit.scoSeaParityFactoryPinOwner = self
        targetUnit:SetOrientation(self:GetOrientation())
        targetUnit:SetPosition(self:GetConstructionSpawnPoint())
        Engine.SetVolumeColliderEnabled(targetUnit.id, false)
    end
    SCOSeaParityNavalFactoryHostBase.OnStartBuildRoutine(self, targetUnit)
    SCOSeaParityFactoryLifecycle.StartBuild(self, targetUnit)
end

function SCOSeaParityNavalFactoryHostClass:OnStopBuildRoutine(targetUnit)
    SCOSeaParityNavalFactoryHostBase.OnStopBuildRoutine(self, targetUnit)
    SCOSeaParityFactoryLifecycle.StopBuild(self, targetUnit)
end

function SCOSeaParityNavalFactoryHostClass:RollOffUnit(targetUnit)
    local source = self.unitBeingBuiltSource or self
    local rallyPoint = source.rallyPoint
    local waterLevel = nil
    local waterError, hasWater = Engine.HasWater()
    if waterError == EngineErrorCode.Success and hasWater then
        local levelError, level = Engine.GetWaterLevel()
        if levelError == EngineErrorCode.Success then waterLevel = level end
    end
    if waterLevel == nil then error("Sea-parity naval rolloff has no water level.") end
    local route = SCOSeaParitySelectRolloffRoute(self, rallyPoint, waterLevel)

    local exitScale = route.exitScale or 2
    local routePoint = SCOSeaParityRotateFactoryOffset(
        self, route.offset, 1, waterLevel)
    local exitPoint = SCOSeaParityRotateFactoryOffset(
        self, route.offset, exitScale, waterLevel)
    local localOrientation = Engine.EulerToQuaternion(
        EngineClasses.float3(0, math.rad(route.unitSpin or 0), 0),
        RotationOrder.Default)
    targetUnit:SetOrientation(Engine.QuaternionMultiply(
        self:GetOrientation(), localOrientation))
    targetUnit:SetPosition(routePoint)
    if targetUnit.scoSeaParityFactoryPinOwner == self then
        targetUnit.scoSeaParityFactoryPinOwner = nil
    end
    Engine.SetVolumeColliderEnabled(targetUnit.id, true)
    SCOSeaParityHostOrderManager.HostIssueOrder(
        SCOSeaParityOrderTasks.MOVE, {targetUnit}, false, exitPoint, nil)
    if rallyPoint then
        rallyPoint = EngineClasses.float3(rallyPoint.x, waterLevel, rallyPoint.z)
        SCOSeaParityHostOrderManager.HostIssueOrder(
            SCOSeaParityOrderTasks.MOVE, {targetUnit}, true, rallyPoint, nil)
    end
end

function SCOSeaParityNavalFactoryHostClass:OnDestroy(isDelete)
    SCOSeaParityFactoryLifecycle.CancelBuild(self)
    local target = self.productionBehaviorTargetUnit
    if target and target.scoSeaParityFactoryPinOwner == self
        and not target.dead and not target.deleted
    then
        target.scoSeaParityFactoryPinOwner = nil
        Engine.SetVolumeColliderEnabled(target.id, true)
    end
    SCOSeaParityNavalFactoryHostBase.OnDestroy(self, isDelete)
end

-- Supreme Commander Overhaul factory staging hook 1.0.2
-- SCOM Field Fix: Demolisher reversible source deployment 1.3.1
local SCODemolisherImportedLandUnit = HostEDAImportedFaLandUnit
local SCODemolisherNativeLandUnit = HostEDALandUnit
local SCODemolisherMoveTask = Import("common/commonOrders.lua").OrderTasks.MOVE
if not SCODemolisherImportedLandUnit
    or not SCODemolisherImportedLandUnit.UpdateAnimations
    or not SCODemolisherNativeLandUnit
    or not SCODemolisherNativeLandUnit.UpdateAnimations
then
    error("Demolisher could not resolve its EDA land animation owners")
end

local SCODemolisherStockUpdateAnimations =
    SCODemolisherImportedLandUnit.UpdateAnimations
local SCODemolisherNativeUpdateAnimations =
    SCODemolisherNativeLandUnit.UpdateAnimations
local SCODemolisherSampleBase = -10000

local function SCODemolisherSetMovementLock(unit, locked)
    local speed
    if locked then
        local status
        status, speed = Engine.GetMovementMaxSpeed(unit.id)
        if status ~= EngineErrorCode.Success
            or type(speed) ~= "number" or speed < 0
        then
            error("UEL3101 Demolisher could not read its packed movement speed")
        end
        local stop = Engine.MovementStop(unit.id, EngineClasses.float2(0, 0))
        if stop ~= EngineErrorCode.Success then
            error("UEL3101 Demolisher could not stop before deployment")
        end
    else
        speed = unit.scoDemolisherPackedSpeed
        if type(speed) ~= "number" or speed < 0 then
            error("UEL3101 Demolisher lost its packed movement speed")
        end
    end
    -- Disabling movement removes the unit from Sanctuary's hard collision grid.
    -- A zero speed keeps its movement collider present while the gun is deployed.
    local result = Engine.SetMovementMaxSpeed(unit.id, locked and 0 or speed)
    if result ~= EngineErrorCode.Success then
        error("UEL3101 Demolisher movement speed lock update failed")
    end
    unit.scoDemolisherPackedSpeed = locked and speed or nil
end

local function SCODemolisherSample(unit, animation, phase)
    local result = Engine.PlayAnimation(
        unit.id, animation.id, SCODemolisherSampleBase + phase)
    if result ~= EngineErrorCode.Success then
        error("UEL3101 Demolisher source deploy sample failed")
    end
end

function SCODemolisherImportedLandUnit:UpdateAnimations()
    local deploy = self.tp and self.tp.additions
        and self.tp.additions.faWeaponDeploy
    if self.tpId ~= "uel3101" or self.dead or self.deleted then
        return SCODemolisherStockUpdateAnimations(self)
    end
    if not deploy
        or deploy.keepAnimatorEnabledForAim ~= true
        or deploy.deployAnimationKey ~= "deploy"
        or deploy.deploySeconds ~= 1
        or deploy.sourceWeaponUnpackLocksMotion ~= true
    then
        error("UEL3101 Demolisher deployment contract drifted")
    end

    local animations = self.tp.visuals and self.tp.visuals.animations
    local animation = animations and animations.deploy
    local rest = animations and animations.walk
    if not animation or animation.id == nil
        or animation.playbackMode ~= AnimationPlaybackMode.Clamp
        or not rest or rest.id == nil
    then
        error("UEL3101 Demolisher source animation is unavailable")
    end

    local weapon = self.weapons and self.weapons[1]
    local hasTarget = weapon and weapon:HasTarget() or false
    local activeOrder = self.orders and self.orders.activeOrder
    local moveRequested = activeOrder
        and activeOrder.orderTask == SCODemolisherMoveTask
    local now = Engine.GetSimulationTime()
    local previousTime = self.scoDemolisherSampleTime or now
    local phase = self.scoDemolisherDeployPhase or 0
    local direction = self.scoDemolisherDeployDirection

    local shouldDeploy = hasTarget and not moveRequested
    if direction ~= shouldDeploy then
        direction = shouldDeploy
        previousTime = now
        self.scoDemolisherDeployDirection = direction
        if shouldDeploy and not self.scoDemolisherMovementLocked then
            local result = Engine.SetAnimatorEnabled(self.id, true)
            if result ~= EngineErrorCode.Success then
                error("UEL3101 Demolisher could not enable its source animator")
            end
            SCODemolisherSetMovementLock(self, true)
            self.scoDemolisherMovementLocked = true
            if not self.scoDemolisherFirstShotPrepared then
                weapon.reloadTimer = 0
                self.scoDemolisherFirstShotPrepared = true
            end
        end
    end

    local elapsed = math.max(0, now - previousTime)
    self.scoDemolisherSampleTime = now
    if direction then
        phase = math.min(deploy.deploySeconds, phase + elapsed)
    else
        phase = math.max(0, phase - elapsed)
    end
    self.scoDemolisherDeployPhase = phase

    if direction or phase > 0 or self.scoDemolisherMovementLocked then
        -- The Clamp sample is resent while deployed so aim composes from the
        -- authored stabilizer pose rather than last frame's aimed rotation.
        SCODemolisherSample(self, animation, phase)
    end

    if moveRequested or (direction and phase < deploy.deploySeconds) then
        -- The upstream FA weapon wrapper compares an integer clock to this
        -- field. Keep it in the future until the sampled pose is fully open,
        -- and throughout an explicit move while the target may remain valid.
        self.scoFaWeaponReadyTime = now + deploy.deploySeconds
    else
        self.scoFaWeaponReadyTime = nil
    end

    if not direction and phase == 0 and self.scoDemolisherMovementLocked then
        local result = Engine.PlayAnimation(self.id, rest.id, 0.1)
        if result ~= EngineErrorCode.Success then
            error("UEL3101 Demolisher could not restore its packed pose")
        end
        SCODemolisherSetMovementLock(self, false)
        self.scoDemolisherMovementLocked = false
    end

    return SCODemolisherNativeUpdateAnimations(self)
end
-- Retail UES0302 equal-weight death variants; nominal playback rate.
-- Delay final wreck/delete through the existing native DeathThread lifecycle.
-- Scoped unit guard preserves all other faction and previously patched units.
local SCOM_PreviousDeath_uen3001 = HostEDANavalUnit.DeathThread
local SCOM_DeathVariants_uen3001 = {
    { name = "death01", duration = 39.2999992 },
    { name = "death02", duration = 16.666666 },
    { name = "death03", duration = 39.2999992 }
}
function HostEDANavalUnit:DeathThread(overkillRatio)
    if self.tpId ~= "uen3001" then
        return SCOM_PreviousDeath_uen3001(self, overkillRatio)
    end
    if not self.dead then error("uen3001: death animation dispatched before destruction") end
    local variant = SCOM_DeathVariants_uen3001[((self.id.index or 0) % #SCOM_DeathVariants_uen3001) + 1]
    local animation = self.tp.visuals.animations[variant.name]
    if not animation or not animation.id then error("uen3001: source death clip is not registered") end
    Engine.PlayAnimation(self.id, animation.id, 0.1)
    WaitSeconds(variant.duration)
    return SCOM_PreviousDeath_uen3001(self, overkillRatio)
end
-- SCOM factory egress EDA installation 1.0.0
local factoryEgress = Import("common/systems/scoFactoryEgress.lua")
factoryEgress.Install(HostEDAUefLandFactory)
factoryEgress.Install(HostEDAFaUefAirFactory)
factoryEgress.Install(HostEDAFaUefNavalFactory)

-- Append to host/units/unitsClasses/unitsDefaultEDA.lua.
local SCOFaT3Shield = Import("host/shield.lua")
local SCOFaT3EdaSetUpShields = HostEDALandUnit.SetUpShields
local SCOFaT3EdaCheckShieldState = HostEDALandUnit.CheckShieldState

function HostEDALandUnit:SetUpShields()
    SCOFaT3EdaSetUpShields(self)
    if self.tpId == "uel3001" then SCOFaT3Shield.SCOFaT3InstallShield(self) end
end

function HostEDALandUnit:CheckShieldState(skipRecharge)
    if self.tpId == "uel3001" then
        return SCOFaT3Shield.SCOFaT3CheckShieldState(self, skipRecharge)
    end
    return SCOFaT3EdaCheckShieldState(self, skipRecharge)
end

