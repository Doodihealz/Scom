--- This file contains default Guard units classes.

-- Default Guard units classes definitions
local unitsDefault = Import("host/units/unitsClasses/unitsDefault.lua")
Structure = unitsDefault.HostStructure
TechCentre = unitsDefault.HostTechCentre
NavalStructure = unitsDefault.HostNavalStructure
NavalTechCentre = unitsDefault.HostNavalTechCentre
EngineeringStation = unitsDefault.HostEngineeringStation
Airfield = unitsDefault.HostAirfield
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



------------------------
-- Guard Structure class
------------------------
HostGuardStructure = Class("GuardStructure", Structure)



-------------------------------
-- Guard Naval Structure class
-------------------------------
HostGuardNavalStructure = Class("GuardNavalStructure", NavalStructure)



------------------------
-- Guard Structure class
------------------------
HostGuardTechCentre = Class("GuardTechCentre", TechCentre)



--------------------------------
-- Guard Naval TechCentre class
--------------------------------
HostGuardNavalTechCentre = Class("GuardNavalTechCentre", NavalTechCentre)



----------------------------------
-- Guard Engineering Station class
----------------------------------
HostGuardEngineeringStation = Class("GuardEngineeringStation", EngineeringStation)



----------------------------------
-- Guard Engineering Station class
----------------------------------
HostGuardAirfield = Class("GuardAirfield", Airfield)



----------------------
-- Guard Storage class
----------------------
HostGuardStorage = Class("Storage", Storage)



--------------------------
-- Guard Air Factory class
--------------------------
HostGuardAirFactory = Class("GuardAirFactory", AirFactory)



---------------------------
-- Guard Land Factory class
---------------------------
HostGuardLandFactory = Class("GuardLandFactory", LandFactory)



----------------------------
-- Guard Naval Factory class
----------------------------
HostGuardNavalFactory = Class("GuardNavalFactory", NavalFactory)



------------------------
-- Guard Alloy Extractor
------------------------
HostGuardAlloyExtractor = Class("GuardAlloyExtractor", AlloyExtractor)



-------------------------
-- Guard Energy Generator
-------------------------
HostGuardEnergyGenerator = Class("GuardEnergyGenerator", EnergyGenerator)



-----------------------
-- Guard Air Unit class
-----------------------
HostGuardAirUnit = Class("GuardAirUnit", AirUnit)



------------------------
-- Guard Land Unit class
------------------------
HostGuardLandUnit = Class("GuardLandUnit", LandUnit)



-------------------------
-- Guard Naval Unit class
-------------------------
HostGuardNavalUnit = Class("GuardNavalUnit", NavalUnit)



------------------------
-- Guard Submarine class
------------------------
HostGuardSubmarine = Class("GuardSubmarine", Submarine)



-----------------------
-- Guard Engineer class
-----------------------
HostGuardEngineer = Class("GuardEngineer", Engineer)



------------------------
-- Guard Commander class
------------------------
HostGuardCommander = Class("GuardCommander", Commander)


-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1
local OrderTasks = Import("common/commonOrders.lua").OrderTasks
local HostOrderManager = Import("host/managers/orders/hostOrderManager.lua")

-- Cybran land factories retain their own native animated rigs. Normal
-- production owns the build clip; exact self-upgrades belong exclusively to
-- the shared progress-bound animation sampler.
local GuardLandFactory = HostGuardLandFactory or GuardLandFactory
if not GuardLandFactory then
    error("SCO could not resolve the host Guard land-factory base class.")
end
HostGuardCybranLandFactory = Class("GuardCybranLandFactory", GuardLandFactory)
local GuardCybranLandFactory = HostGuardCybranLandFactory

function GuardCybranLandFactory:UpdateAnimations()
    -- Static factories have no Movement component. Their authored build
    -- clips are driven explicitly by the lifecycle methods below.
end

-- Sanctuary currently uses GetConstructionSpawnPoint for the initial build spawn.
-- Keep the real roll-off table unchanged so completed units still exit.
function GuardCybranLandFactory:GetConstructionSpawnPoint()
    local offset = self.tp.additions and self.tp.additions.buildStagingOffset
    if not offset then
        return GuardLandFactory.GetConstructionSpawnPoint(self)
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

local function GetCybranFactoryRollOffRamps(factory)
    local additions = factory.tp.additions
    return additions and additions.rollOffRamps
end

local function GetCybranFactoryRollOffRampPosition(factory, offset)
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

local function GetCybranFactoryRollOffTargetKey(targetUnit)
    local id = targetUnit and targetUnit.id
    if not id then
        return nil
    end
    return tostring(id.index) .. ":" .. tostring(id.version)
end

local function SelectCybranFactoryRollOffRamp(factory, targetUnit)
    local ramps = GetCybranFactoryRollOffRamps(factory)
    if not ramps or #ramps == 0 then
        return nil
    end

    local key = GetCybranFactoryRollOffTargetKey(targetUnit)
    local selectedIndexes = factory.guardCybranRollOffRampIndexes
    local selectedIndex = key and selectedIndexes and selectedIndexes[key]
    if selectedIndex then
        return ramps[selectedIndex]
    end

    local source = factory.unitBeingBuiltSource or factory
    local rallyPoint = source.rallyPoint
    if rallyPoint then
        local closestDistanceSquared = nil
        for index, ramp in ipairs(ramps) do
            local clearancePosition = GetCybranFactoryRollOffRampPosition(factory, ramp.clearanceOffset or ramp.rampOffset)
            local deltaX = clearancePosition.x - rallyPoint.x
            local deltaZ = clearancePosition.z - rallyPoint.z
            local distanceSquared = (deltaX * deltaX) + (deltaZ * deltaZ)
            if not closestDistanceSquared or distanceSquared < closestDistanceSquared then
                closestDistanceSquared = distanceSquared
                selectedIndex = index
            end
        end
    else
        selectedIndex = factory.guardCybranNextRollOffRampIndex or 1
        if selectedIndex < 1 or selectedIndex > #ramps then
            selectedIndex = 1
        end
        factory.guardCybranNextRollOffRampIndex = selectedIndex + 1
        if factory.guardCybranNextRollOffRampIndex > #ramps then
            factory.guardCybranNextRollOffRampIndex = 1
        end
    end

    if key then
        factory.guardCybranRollOffRampIndexes = selectedIndexes or {}
        factory.guardCybranRollOffRampIndexes[key] = selectedIndex
    end
    return ramps[selectedIndex]
end

local function FaceCybranFactoryUnitTowardRamp(factory, targetUnit, ramp)
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
    local rampPosition = GetCybranFactoryRollOffRampPosition(factory, ramp.rampOffset)
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

local function PrepareCybranFactoryRollOff(factory, targetUnit)
    if not targetUnit or not targetUnit:HasTags(Tags.MOBILE) then
        return
    end
    FaceCybranFactoryUnitTowardRamp(factory, targetUnit, SelectCybranFactoryRollOffRamp(factory, targetUnit))
end

local function CybranFactoryUnitIsAlive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
end

local function GetCybranFactoryClearancePoint(factory, ramp)
    if not ramp then
        return nil
    end

    local clearancePosition = GetCybranFactoryRollOffRampPosition(
        factory,
        ramp.clearanceOffset or ramp.rampOffset
    )
    local _, terrainHeight = Engine.SampleTerrainHeight(
        EngineClasses.float3(clearancePosition.x, 0, clearancePosition.z)
    )
    return EngineClasses.float3(clearancePosition.x, terrainHeight, clearancePosition.z)
end

function GuardCybranLandFactory:StopBuildColliderPin(targetUnit)
    if targetUnit ~= nil and self.guardCybranPinnedBuildTarget ~= targetUnit then
        return
    end

    local pinnedTarget = self.guardCybranPinnedBuildTarget
    self.guardCybranPinnedBuildTarget = nil
    if pinnedTarget and pinnedTarget.scoFactoryColliderPinOwner == self then
        pinnedTarget.scoFactoryColliderPinOwner = nil
    end
end

function GuardCybranLandFactory:PinBuildCollider(targetUnit)
    self:StopBuildColliderPin()
    if not CybranFactoryUnitIsAlive(targetUnit)
        or not targetUnit:HasTags(Tags.MOBILE)
        or targetUnit:IsCompleted()
    then
        return
    end

    self.guardCybranPinnedBuildTarget = targetUnit
    targetUnit.scoFactoryColliderPinOwner = self
    Engine.SetVolumeColliderEnabled(targetUnit.id, false)
end

function GuardCybranLandFactory:ReleaseBuiltUnit(targetUnit, ramp)
    if not CybranFactoryUnitIsAlive(targetUnit)
        or not targetUnit:HasTags(Tags.MOBILE)
        or not targetUnit:IsCompleted()
    then
        return false
    end

    local clearancePoint = GetCybranFactoryClearancePoint(self, ramp)
    if not clearancePoint then
        return false
    end

    -- Relocate before collision returns. Enabling it at the staging point
    -- allows the finished unit to intersect, sink through, or roll through
    -- the converted factory hull.
    FaceCybranFactoryUnitTowardRamp(self, targetUnit, ramp)
    targetUnit:SetPosition(clearancePoint)
    self:StopBuildColliderPin(targetUnit)
    if CybranFactoryUnitIsAlive(targetUnit) then
        Engine.SetVolumeColliderEnabled(targetUnit.id, true)
    end
    return true
end

function GuardCybranLandFactory:OnStartBuildRoutine(targetUnit)
    self:PinBuildCollider(targetUnit)
    GuardLandFactory.OnStartBuildRoutine(self, targetUnit)
    PrepareCybranFactoryRollOff(self, targetUnit)
    if CybranFactoryUnitIsAlive(targetUnit)
        and targetUnit:HasTags(Tags.MOBILE)
        and not targetUnit:IsCompleted()
    then
        Engine.SetVolumeColliderEnabled(targetUnit.id, false)
    end
    local isUpgradeBuild = self:IsUpgrading()
        and self.upgradeTarget == targetUnit
    local animations = self.tp.visuals and self.tp.visuals.animations
    if not isUpgradeBuild and animations and animations.build then
        Engine.PlayAnimation(self.id, animations.build.id, 0.1)
    end
end

function GuardCybranLandFactory:OnStopBuildRoutine(targetUnit)
    local completed = CybranFactoryUnitIsAlive(targetUnit) and targetUnit:IsCompleted()
    if completed then
        -- The base callback notifies clients and restores local collision,
        -- so the host must put a completed child clear of the hull first.
        self:ReleaseBuiltUnit(targetUnit, SelectCybranFactoryRollOffRamp(self, targetUnit))
    elseif CybranFactoryUnitIsAlive(targetUnit) and targetUnit:HasTags(Tags.MOBILE) then
        Engine.SetVolumeColliderEnabled(targetUnit.id, false)
    end
    GuardLandFactory.OnStopBuildRoutine(self, targetUnit)
    local animations = self.tp.visuals and self.tp.visuals.animations
    if animations and animations.walk then
        Engine.PlayAnimation(self.id, animations.walk.id, 0.1)
    end
end

function GuardCybranLandFactory:RollOffUnit(targetUnit)
    local ramp = SelectCybranFactoryRollOffRamp(self, targetUnit)
    if not ramp then
        GuardLandFactory.RollOffUnit(self, targetUnit)
        return
    end

    FaceCybranFactoryUnitTowardRamp(self, targetUnit, ramp)
    local rampPosition = GetCybranFactoryRollOffRampPosition(self, ramp.rampOffset)
    local clearancePosition = GetCybranFactoryRollOffRampPosition(self, ramp.clearanceOffset or ramp.rampOffset)
    local released = self:ReleaseBuiltUnit(targetUnit, ramp)
    if not released then
        HostOrderManager.HostIssueOrder(OrderTasks.MOVE, {targetUnit}, false, rampPosition, nil)
        HostOrderManager.HostIssueOrder(OrderTasks.MOVE, {targetUnit}, true, clearancePosition, nil)
    end

    local source = self.unitBeingBuiltSource or self
    if source.rallyPoint then
        HostOrderManager.HostIssueOrder(OrderTasks.MOVE, {targetUnit}, true, source.rallyPoint, nil)
    end

    local key = GetCybranFactoryRollOffTargetKey(targetUnit)
    if key and self.guardCybranRollOffRampIndexes then
        self.guardCybranRollOffRampIndexes[key] = nil
    end
end

function GuardCybranLandFactory:ProductionBehaviorStop()
    local targetUnit = self.productionBehaviorTargetUnit
    self:StopBuildColliderPin(targetUnit)
    GuardLandFactory.ProductionBehaviorStop(self)
end

function GuardCybranLandFactory:OnCancelConstruction()
    self:StopBuildColliderPin()
    GuardLandFactory.OnCancelConstruction(self)
end

-- The factory's 6x6 art core is its real model footprint. Two separate
-- Default-grid roots protect the angled left and right roll-off lanes.
-- Each root avoids the engine's one-grid-modifier-per-prefab-root
-- limitation and deliberately has no navmap modifier.
local PlacementLayer = Import("common/layers.lua").PlacementLayer
local CybranFactoryRollOffReservationPrefabID = nil
_G.SupremeCommanderOverhaulFactoryReservationOwners = _G.SupremeCommanderOverhaulFactoryReservationOwners or {}

local function OverhaulFactoryReservationKey(id)
    return tostring(id.index) .. ":" .. tostring(id.version)
end

local function GetCybranFactoryRollOffReservationPrefabID()
    if CybranFactoryRollOffReservationPrefabID then
        return CybranFactoryRollOffReservationPrefabID
    end

    local prefab = EngineClasses.PrefabTemplate("SupremeCommanderOverhaulCybranFactoryRollOffGlobal")
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
        Engine.Error("Unable to create the Cybran factory roll-off reservation prefab.")
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
        _G.SupremeCommanderOverhaulFactoryReservationOwners[OverhaulFactoryReservationKey(reservationID)] = nil
        if Engine.IsValidGlobalID(reservationID) then
            Engine.SetGlobalGridModifierEnabled(reservationID, false)
            Engine.DeletePrefabInstance(reservationID)
        end
    end
end

function GuardCybranLandFactory:CreateRollOffReservation()
    if self.guardCybranRollOffReservationIDs then
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
            Engine.Error("Cybran factory roll-off reservation is missing a size.")
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
            DestroyCybranFactoryRollOffReservationIDs(reservationIDs)
            Engine.Error("Unable to create a Cybran factory roll-off reservation.")
            return
        end

        Engine.SetGlobalGridModifierSize(reservationID, EngineClasses.float2(size.x, size.y))
        table.insert(reservationIDs, reservationID)
    end

    self.guardCybranRollOffReservationIDs = reservationIDs
    for _, reservationID in ipairs(reservationIDs) do
        _G.SupremeCommanderOverhaulFactoryReservationOwners[OverhaulFactoryReservationKey(reservationID)] = self.id
        Engine.SetGlobalGridModifierEnabled(reservationID, true)
    end
end

function GuardCybranLandFactory:DestroyRollOffReservation()
    DestroyCybranFactoryRollOffReservationIDs(self.guardCybranRollOffReservationIDs)
    self.guardCybranRollOffReservationIDs = nil
end

function GuardCybranLandFactory:PromoteToUnit()
    GuardLandFactory.PromoteToUnit(self)
    self:CreateRollOffReservation()
end

function GuardCybranLandFactory:OnDestroy(isDelete)
    self:StopBuildColliderPin()
    self:DestroyRollOffReservation()
    GuardLandFactory.OnDestroy(self, isDelete)
end

-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0
local GuardStructure = HostGuardStructure or GuardStructure
local GuardAlloyExtractor = HostGuardAlloyExtractor or GuardAlloyExtractor
local GuardCybranLandFactory = HostGuardCybranLandFactory or GuardCybranLandFactory
if not GuardStructure or not GuardAlloyExtractor or not GuardCybranLandFactory then
    error("SCO could not resolve the host Guard base classes.")
end
HostGuardImportedAnimatedStructure = Class("GuardImportedAnimatedStructure", GuardStructure)
local GuardImportedAnimatedStructure = HostGuardImportedAnimatedStructure

function GuardImportedAnimatedStructure:UpdateAnimations()
    -- Imported static clips are behavior-driven; these units have no Movement component.
end

HostGuardImportedAnimatedAlloyExtractor = Class("GuardImportedAnimatedAlloyExtractor", GuardAlloyExtractor)
local GuardImportedAnimatedAlloyExtractor = HostGuardImportedAnimatedAlloyExtractor

function GuardImportedAnimatedAlloyExtractor:UpdateAnimations()
    -- Imported static clips are behavior-driven; these units have no Movement component.
end

HostGuardCybranAnimatedLandFactory = Class("GuardCybranAnimatedLandFactory", GuardCybranLandFactory)
-- Guard Cybran Monkeylord Cache Patcher 1.4.0
local SCO_MonkeylordLayers = Import("common/layers.lua")
local SCO_MonkeylordStockGuardUpdateAnimations =
    HostGuardLandUnit.UpdateAnimations
HostGuardMonkeylord = Class("GuardMonkeylord", HostGuardLandUnit)

function HostGuardMonkeylord:RotatorsEnabledOnConstruction()
    -- The microwave barrel starts only when its persistent beam does.
    return false
end

local SCO_MonkeylordActivationDuration = 4.333333492279053
local SCO_MonkeylordDeathDuration = 5.666666507720947

function HostGuardMonkeylord:SetupAnimations()
    HostGuardLandUnit.SetupAnimations(self)
    if not self:IsCompleted() then
        self.scoMonkeylordAnimationPhase = "construction"
        self:SetAnimatorEnabled(true)
        Engine.PlayAnimation(self.id, self.tp.visuals.animations.construction.id, 0)
    end
end

function HostGuardMonkeylord:RestoreLocomotionAnimation()
    self.scoMonkeylordAnimationPhase = "ready"
    self.isWalking = true
    Engine.PlayAnimation(self.id, self.tp.visuals.animations.walk.id, 0.1)
    self:UpdateAnimations()
end

function HostGuardMonkeylord:CancelActivationThread()
    self.scoMonkeylordAnimationGeneration =
        (self.scoMonkeylordAnimationGeneration or 0) + 1
    if self.scoMonkeylordActivationThread then
        KillThread(self.scoMonkeylordActivationThread)
        self.scoMonkeylordActivationThread = nil
    end
end

function HostGuardMonkeylord:ActivationThread(generation)
    WaitSeconds(SCO_MonkeylordActivationDuration)
    if self.dead or self.deleted
        or self.scoMonkeylordAnimationGeneration ~= generation
        or self.scoMonkeylordAnimationPhase ~= "activating"
    then
        return
    end
    self.scoMonkeylordActivationThread = nil
    self:RestoreLocomotionAnimation()
end

function HostGuardMonkeylord:OnStopBeingBuilt()
    if self.dead or self.deleted or self.scoMonkeylordCompletionHandled then return end
    self.scoMonkeylordCompletionHandled = true
    local bypassed = self.bypassedBuildProcess
    HostGuardLandUnit.OnStopBeingBuilt(self)
    local resourceEntities = self.resourceEntities
    local consumption = resourceEntities and resourceEntities.consumption
    if consumption == nil then
        error("Monkeylord maintenance resource was not created")
    end
    consumption:SetEnabled(true)
    if bypassed then
        self:RestoreLocomotionAnimation()
        return
    end
    self.scoMonkeylordAnimationPhase = "activating"
    self.scoMonkeylordAnimationGeneration =
        (self.scoMonkeylordAnimationGeneration or 0) + 1
    self:UpdateAnimations()
    if self.scoMonkeylordAnimationPhase ~= "activating" then return end
    Engine.PlayAnimation(self.id, self.tp.visuals.animations.activate.id, 0.1)
    self.scoMonkeylordActivationThread = self:NewThread(
        self.ActivationThread, self.scoMonkeylordAnimationGeneration)
end

function HostGuardMonkeylord:UpdateAnimations()
    -- URL0402's source layer callback enables its torpedo only on the
    -- seabed. Sanctuary weapon masks consume targetingLayer directly,
    -- so derive that layer from the current water/terrain contract.
    if not self.dead then
        local targetLayer = SCO_MonkeylordLayers.TargetingLayer.Land
        local waterResult, hasWater = Engine.HasWater()
        if waterResult == EngineErrorCode.Success and hasWater then
            local levelResult, waterLevel = Engine.GetWaterLevel()
            local position = self:GetPosition()
            if levelResult == EngineErrorCode.Success
                and waterLevel ~= nil
                and position ~= nil
            then
                local terrainResult, terrainHeight =
                    Engine.SampleTerrainHeight(position)
                if terrainResult == EngineErrorCode.Success
                    and terrainHeight < waterLevel - 0.05
                    and position.y < waterLevel - 0.05
                then
                    targetLayer =
                        SCO_MonkeylordLayers.TargetingLayer.Seabed
                end
            end
        end
        if self.targetingLayer ~= targetLayer then
            self:SetTargetingLayer(targetLayer)
        end
    end
    if self.dead or self.scoMonkeylordAnimationPhase == "construction" then return end
    if self.scoMonkeylordAnimationPhase == "activating" then
        -- Completion already enabled native movement and weapons. Yield the
        -- deploy pose when either takes ownership, instead of sliding the rig.
        local speedResult, speed = Engine.GetMovementCurrentSpeed(self.id)
        local active = speedResult == EngineErrorCode.Success and speed > 0
        if not active then
            for _, weapon in ipairs(self.weapons or {}) do
                local target = weapon:GetAimTarget()
                if weapon:IsEnabled() and target and not target.dead and not target.deleted then
                    active = true
                    break
                end
            end
        end
        if not active then return end
        self:CancelActivationThread()
        return self:RestoreLocomotionAnimation()
    end
    return SCO_MonkeylordStockGuardUpdateAnimations(self)
end

function HostGuardMonkeylord:OnDestroy(destroyType)
    self.scoMonkeylordDeathAnimationPending = self:IsCompleted()
        and not self:IsPlacementGhost()
        and (destroyType == DestroyType.Kinetic or destroyType == DestroyType.Unspecified)
    self.scoMonkeylordAnimationPhase = "dead"
    self:CancelActivationThread()
    self:SetRotatorsEnabled(false)
    -- The native unit updater retains dead units until Delete. Quiesce before
    -- native deletion so neither it nor aim controllers touch deleted weapons.
    for _, weapon in ipairs(self.weapons or {}) do
        weapon:SetEnabled(false)
        weapon:SetAimTarget(nil)
    end
    local result = HostGuardLandUnit.OnDestroy(self, destroyType)
    self.weapons = {}
    return result
end

function HostGuardMonkeylord:DeathThread(overkillRatio)
    if not self.scoMonkeylordDeathAnimationPending then
        return HostGuardLandUnit.DeathThread(self, overkillRatio)
    end
    self.scoMonkeylordDeathAnimationPending = nil
    self.scoMonkeylordAnimationPhase = "dying"
    -- Native OnDestroy has already ended combat, economy and targeting.
    Engine.SetMovementEnabled(self.id, false)
    Engine.SetMovementCollisionMask(self.id, 0)
    self:SetAnimatorEnabled(true)
    Engine.PlayAnimation(self.id, self.tp.visuals.animations.death.id, 0.1)
    WaitSeconds(SCO_MonkeylordDeathDuration)
    if not self.deleted then
        -- Keep native fraction/overkill/wreck rules; only defer their execution.
        return HostGuardLandUnit.DeathThread(self, overkillRatio)
    end
end


-- Supreme Commander Overhaul FA Cybran Land Scout 1.0.0
-- Keep the template's stock GuardLandUnit class. This ID-gated wrapper
-- delays only the Mole's stock wreck/delete path for one exact source
-- Adeath play. The loader currently exposes clips as Loop; deletion at
-- the 0.5-second source endpoint prevents an observable second cycle.
local SCO_FaMoleCommands = Import("common/commands/definitions/units.lua")
local SCO_FaMoleStockCheckRadarState = HostGuardLandUnit.CheckRadarState
function HostGuardLandUnit:CheckRadarState()
    if self.tpId ~= "ugl1701" then
        return SCO_FaMoleStockCheckRadarState(self)
    end
    if not self.radarDetector or self.progress == nil then
        return
    end

    -- URL0101 creates and enables a separate, free RadarEnt. It has no
    -- radar toggle and does not shut down on an army energy stall.
    local isRadarActive = self:IsCompleted()
    if self.radarDetector:GetEnabled() ~= isRadarActive then
        self.radarDetector:SetEnabled(isRadarActive)
        SCO_FaMoleCommands.SetRadarActive.Send(self.id, isRadarActive)
    end
end

local SCO_FaMoleStockDeathThread = HostGuardLandUnit.DeathThread
function HostGuardLandUnit:DeathThread(overkillRatio)
    if self.tpId ~= "ugl1701" then
        return SCO_FaMoleStockDeathThread(self, overkillRatio)
    end

    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations
    local death = animations and animations.death
    if not death or not death.id then
        error("UGL1701 Mole requires its hash-pinned AnimDeath clip")
    end
    Engine.PlayAnimation(self.id, death.id, 0.1)
    WaitSeconds(0.5)
    return SCO_FaMoleStockDeathThread(self, overkillRatio)
end


-- Supreme Commander Overhaul FA Air Factories 1.0.0
local SCOFaAirFactoryHostBase = HostGuardAirFactory or GuardAirFactory
local SCOFaAirFactoryLifecycle = _G.SCOFaAirFactoryLifecycle
if not SCOFaAirFactoryHostBase or not SCOFaAirFactoryLifecycle then
    error("FA air-factory host dependencies are unavailable.")
end
HostGuardFaCybranAirFactory = Class("GuardFaCybranAirFactory", SCOFaAirFactoryHostBase)
local SCOFaAirFactoryHostClass = HostGuardFaCybranAirFactory

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
local SCOFaEngineerWaterGuard = HostGuardEngineer or GuardEngineer
if not SCOFaEngineerWaterLifecycle or not SCOFaEngineerWaterGuard then
    error("FA engineer water lifecycle could not resolve Guard dependencies")
end
local SCOFaEngineerWaterGuardStopBuilt = SCOFaEngineerWaterGuard.OnStopBeingBuilt
local SCOFaEngineerWaterGuardDestroy = SCOFaEngineerWaterGuard.OnDestroy

function SCOFaEngineerWaterGuard:OnStopBeingBuilt(...)
    SCOFaEngineerWaterGuardStopBuilt(self, ...)
    SCOFaEngineerWaterLifecycle.Start(self)
end

function SCOFaEngineerWaterGuard:OnDestroy(...)
    if SCOFaEngineerWaterLifecycle.IsSupported(self) then
        SCOFaEngineerWaterLifecycle.Stop(self)
    end
    return SCOFaEngineerWaterGuardDestroy(self, ...)
end


-- Supreme Commander Overhaul FA Direct Structures 1.0.0
local SCO_GuardStructure = HostGuardStructure or GuardStructure
local SCO_GuardAlloyExtractor = HostGuardAlloyExtractor or GuardAlloyExtractor
local SCO_GuardEngineeringStation = HostGuardEngineeringStation or GuardEngineeringStation
if not SCO_GuardStructure or not SCO_GuardAlloyExtractor or not SCO_GuardEngineeringStation then
    error("SCO direct structures could not resolve host Guard bases.")
end

local function SCO_GuardFabricatorIsActive(self)
    return self:IsCompleted()
        and self:GetProductionToggle()
        and not self.army.economy.isEnergyDown
end

HostGuardSupComMassFabricator = Class("GuardSupComMassFabricator", SCO_GuardAlloyExtractor)
local GuardSupComMassFabricator = HostGuardSupComMassFabricator

function GuardSupComMassFabricator:RotatorsEnabledOnConstruction()
    return false
end

function GuardSupComMassFabricator:SCOSetFabricatorRotorTarget(targetSpeed)
    if self.scoFabricatorRotorTarget == targetSpeed and self.scoFabricatorRotorThread then
        return
    end
    if self.scoFabricatorRotorThread then
        KillThread(self.scoFabricatorRotorThread)
    end
    self.scoFabricatorRotorTarget = targetSpeed
    self.scoFabricatorRotorThread = self:NewThread(self.SCOFabricatorRotorRampThread, targetSpeed)
end

function GuardSupComMassFabricator:SCOFabricatorRotorRampThread(targetSpeed)
    local rotor = self.rotatorIds and self.rotatorIds[1]
    if not rotor then
        error("URB1303 Spinner rotator is missing.")
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

function GuardSupComMassFabricator:CheckProductionState()
    local active = SCO_GuardFabricatorIsActive(self)
    if self.resourceEntities.production then
        self.resourceEntities.production:SetEnabled(active)
    end
    if self.rotatorIds and self.rotatorIds[1] then
        self:SCOSetFabricatorRotorTarget(active and 60 or 0)
    end
end

function GuardSupComMassFabricator:OnStopBeingBuilt()
    SCO_GuardAlloyExtractor.OnStopBeingBuilt(self)
    self:CheckProductionState()
end

function GuardSupComMassFabricator:OnEnergyDown()
    SCO_GuardAlloyExtractor.OnEnergyDown(self)
    self:CheckProductionState()
end

function GuardSupComMassFabricator:OnEnergyUp()
    SCO_GuardAlloyExtractor.OnEnergyUp(self)
    self:CheckProductionState()
end

-- The shared source sampler owns Hive doors for both build and HP repair.
HostGuardSupComHiveT2 = Class("GuardSupComHiveT2", SCO_GuardEngineeringStation)
HostGuardSupComHiveFinal = Class("GuardSupComHiveFinal", SCO_GuardEngineeringStation)

HostGuardSupComShieldFinal = Class("GuardSupComShieldFinal", SCO_GuardStructure)
local GuardSupComShieldFinal = HostGuardSupComShieldFinal

function GuardSupComShieldFinal:UpdateAnimations()
end

function GuardSupComShieldFinal:SCOSetShieldRotorTarget(targetSpeed)
    if self.scoShieldRotorTarget == targetSpeed and self.scoShieldRotorThread then
        return
    end
    if self.scoShieldRotorThread then
        KillThread(self.scoShieldRotorThread)
    end
    self.scoShieldRotorTarget = targetSpeed
    self.scoShieldRotorThread = self:NewThread(self.SCOShieldRotorRampThread, targetSpeed)
end

function GuardSupComShieldFinal:SCOShieldRotorRampThread(targetSpeed)
    local rotor = self.rotatorIds and self.rotatorIds[1]
    if not rotor then
        error("URB4207 Shaft rotator is missing.")
    end
    local speed = self.scoShieldRotorSpeed or 0
    self:SetRotatorsEnabled(true)
    while not self.dead and math.abs(targetSpeed - speed) > 0.000001 do
        local delta = math.min(math.abs(targetSpeed - speed), 0.5)
        speed = speed + (targetSpeed > speed and delta or -delta)
        self.scoShieldRotorSpeed = speed
        Engine.SetRotatorSpeed(rotor, EngineClasses.float3(0, 0, speed))
        WaitSeconds(0.1)
    end
    if targetSpeed == 0 then
        self:SetRotatorsEnabled(false)
    end
    self.scoShieldRotorThread = nil
end

function GuardSupComShieldFinal:SCOOnDirectShieldEnabledChanged(enabled)
    if not self.scoShieldRotorReady then
        return
    end
    self:SCOSetShieldRotorTarget(enabled and 10 or 0)
end

function GuardSupComShieldFinal:OnStopBeingBuilt()
    SCO_GuardStructure.OnStopBeingBuilt(self)
    local rotor = self.rotatorIds and self.rotatorIds[1]
    if not rotor then
        error("URB4207 Shaft rotator is missing after construction.")
    end
    self.scoShieldRotorReady = true
    local active = self:GetShieldToggle() and not self.army.economy.isEnergyDown
    local initialSpeed = active and 30 or 0
    self.scoShieldRotorSpeed = initialSpeed
    self.scoShieldRotorTarget = initialSpeed
    Engine.SetRotatorSpeed(rotor, EngineClasses.float3(0, 0, initialSpeed))
    self:SetRotatorsEnabled(active)
end

-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.1.0
-- Retail URL0107 owns two equal-weight death states. Unit-index parity is
-- deterministic and multiplayer-safe. Sanctuary's Host PlayAnimation API
-- exposes cross-fade time but no playback-rate control, so FA's randomized
-- 0.75-1.25 rate range is retained as evidence and played at nominal 1x.
local SCO_MantisStockDeathThread = HostGuardLandUnit.DeathThread
function HostGuardLandUnit:DeathThread(overkillRatio)
    if self.tpId ~= "ugl1002" then
        return SCO_MantisStockDeathThread(self, overkillRatio)
    end
    if not self.dead then
        error("UGL1002 Mantis death animation must run after HostUnit:OnDestroy")
    end

    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations
    local useFirst = ((self.id and self.id.index) or 0) % 2 == 0
    local death
    if animations then
        if useFirst then
            death = animations.death01
        else
            death = animations.death02
        end
    end
    if not death or not death.id then
        error("UGL1002 Mantis requires both source-pinned death clips")
    end
    Engine.PlayAnimation(self.id, death.id, 0.1)
    WaitSeconds(1)
    return SCO_MantisStockDeathThread(self, overkillRatio)
end
-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0
-- Keep ugl2002 on GuardLandUnit. Its source layer callback switches
-- land guns and torpedoes; reproduce that state through the native
-- targeting layer, which the weapon masks consume directly.
local SCO_FaRoleLayers = Import("common/layers.lua")
local SCO_FaRoleStockGuardUpdateAnimations = HostGuardLandUnit.UpdateAnimations
function HostGuardLandUnit:UpdateAnimations()
    if self.tpId == "ugl2002" and not self.dead then
        local targetLayer = SCO_FaRoleLayers.TargetingLayer.Land
        local waterResult, hasWater = Engine.HasWater()
        if waterResult == EngineErrorCode.Success and hasWater then
            local levelResult, waterLevel = Engine.GetWaterLevel()
            local position = self:GetPosition()
            if levelResult == EngineErrorCode.Success and waterLevel ~= nil and position ~= nil then
                local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)
                if terrainResult == EngineErrorCode.Success
                    and terrainHeight < waterLevel - 0.05
                    and position.y < waterLevel - 0.05
                then
                    targetLayer = SCO_FaRoleLayers.TargetingLayer.Seabed
                end
            end
        end
        if self.targetingLayer ~= targetLayer then
            self:SetTargetingLayer(targetLayer)
        end
    end
    return SCO_FaRoleStockGuardUpdateAnimations(self)
end
-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0
-- Preserve the exact two source death clips and their 10/90 weighting.
-- Unit-index buckets are deterministic and multiplayer-safe.
local SCO_FaHunterStockDeathThread = HostGuardLandUnit.DeathThread
function HostGuardLandUnit:DeathThread(overkillRatio)
    if self.tpId ~= "ugl1001" then
        return SCO_FaHunterStockDeathThread(self, overkillRatio)
    end

    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations
    local bucket = ((self.id and self.id.index) or 0) % 10
    local death = animations and (bucket == 0 and animations.death01 or animations.death02)
    if not death or not death.id then
        error("UGL1001 Hunter requires both hash-pinned source death clips")
    end
    Engine.PlayAnimation(self.id, death.id, 0.1)
    WaitSeconds(0.46666666865348816)
    return SCO_FaHunterStockDeathThread(self, overkillRatio)
end
-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0
local SCO_FaCybranT3Layers = Import("common/layers.lua")
local SCO_FaCybranT3StockUpdateAnimations = HostGuardLandUnit.UpdateAnimations
function HostGuardLandUnit:UpdateAnimations()
    if self.tpId == "ugl3001" and not self.dead then
        local targetLayer = SCO_FaCybranT3Layers.TargetingLayer.Land
        local waterResult, hasWater = Engine.HasWater()
        if waterResult == EngineErrorCode.Success and hasWater then
            local levelResult, waterLevel = Engine.GetWaterLevel()
            local position = self:GetPosition()
            if levelResult == EngineErrorCode.Success and waterLevel ~= nil and position ~= nil then
                local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)
                if terrainResult == EngineErrorCode.Success
                    and terrainHeight < waterLevel - 0.05
                    and position.y < waterLevel - 0.05
                then
                    targetLayer = SCO_FaCybranT3Layers.TargetingLayer.Seabed
                end
            end
        end
        if self.targetingLayer ~= targetLayer then self:SetTargetingLayer(targetLayer) end
    end
    return SCO_FaCybranT3StockUpdateAnimations(self)
end

-- HostUnit:Destroy calls OnDestroy before it starts DeathThread.
-- Hash-pinned unitsBaseClass.lua SHA-256
-- 45ec82463ae6a39460eb661700fe20105fc068b8bab07592326ae712d003b5be
-- sets self.dead, deletes
-- every weapon and targetCollider there. Clear the remaining movement
-- collision mask before preserving the visible source death delay.
local SCO_FaCybranT3StockDeathThread = HostGuardLandUnit.DeathThread
function HostGuardLandUnit:DeathThread(overkillRatio)
    if self.tpId ~= "ugl3001" and self.tpId ~= "ugl3002" then
        return SCO_FaCybranT3StockDeathThread(self, overkillRatio)
    end
    if not self.dead then
        error("Cybran T3 source death animation must run after HostUnit:OnDestroy")
    end
    Engine.SetMovementCollisionMask(self.id, 0)
    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations
    local index = (self.id and self.id.index) or 0
    local death = nil
    local duration = 0
    if self.tpId == "ugl3001" then
        local bucket = index % 3
        death = animations and (bucket == 0 and animations.death01
            or bucket == 1 and animations.death02 or animations.death03)
        duration = 2.3333332538604736
    else
        death = animations and (index % 2 == 0 and animations.death01 or animations.death02)
        duration = 1
    end
    if not death or not death.id then error("Cybran T3 role unit requires every hash-pinned source death clip") end
    Engine.PlayAnimation(self.id, death.id, 0.1)
    WaitSeconds(duration)
    return SCO_FaCybranT3StockDeathThread(self, overkillRatio)
end
-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0
local SCO_EggGuardLandUnit = HostGuardLandUnit or GuardLandUnit
if not SCO_EggGuardLandUnit then error("Trebuchet requires GuardLandUnit") end
HostGuardTrebuchet = Class("GuardTrebuchet", SCO_EggGuardLandUnit)
local GuardTrebuchet = HostGuardTrebuchet

function GuardTrebuchet:UpdateAnimations()
    -- URL0304 has no locomotion SCA. Its sole active clip is weapon-owned.
end

function GuardTrebuchet:OnStopBeingBuilt()
    SCO_EggGuardLandUnit.OnStopBeingBuilt(self)
    local rest = self.tp.visuals and self.tp.visuals.animations
        and self.tp.visuals.animations.walk
    if not rest or not rest.id then
        error("Trebuchet requires its hash-pinned Rest clip")
    end
    Engine.PlayAnimation(self.id, rest.id, 0.1)
end
-- Supreme Commander Overhaul FA Cybran Megalith Cache Patcher 1.0.0
-- This appendix owns only ugl4002 and ugs4902-ugs4905. It never mutates a
-- shared Guard base class, so stock units and other ports retain their owners.
local SCO_MegalithLayers = Import("common/layers.lua").TargetingLayer
local SCO_MegalithEngineer = HostGuardEngineer or GuardEngineer
local SCO_MegalithStructure = HostGuardStructure or GuardStructure
if not SCO_MegalithEngineer or not SCO_MegalithStructure then
    error("FA Megalith could not resolve Guard Engineer/Structure bases")
end

local SCO_MegalithWalkBlendSeconds = 0.35
local SCO_MegalithRestBlendSeconds = 0.2
local SCO_MegalithWalkStartSpeed = 0.05
local SCO_MegalithWalkStopSpeed = 0.02
local SCO_MegalithWalkStartYaw = 0.1
local SCO_MegalithWalkStopYaw = 0.05

local function SCO_MegalithAnimation(unit, key, blendSeconds)
    local animations = unit.tp and unit.tp.visuals and unit.tp.visuals.animations
    local animation = animations and animations[key]
    if not animation or not animation.id then
        error("FA Megalith requires source animation " .. tostring(key))
    end
    if unit.scoMegalithAnimation == key then return end
    local result = Engine.PlayAnimation(
        unit.id, animation.id, blendSeconds or 0.1)
    if result ~= nil and result ~= EngineErrorCode.Success then
        error("FA Megalith animation failed: " .. tostring(key))
    end
    unit.scoMegalithAnimation = key
end

local function SCO_MegalithIsSeabed(unit)
    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success then return nil end
    if not hasWater then return false end
    local levelResult, waterLevel = Engine.GetWaterLevel()
    local position = unit:GetPosition()
    if levelResult ~= EngineErrorCode.Success
        or waterLevel == nil
        or position == nil
    then
        return nil
    end
    local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)
    if terrainResult ~= EngineErrorCode.Success or terrainHeight == nil then
        return nil
    end
    return terrainHeight < waterLevel - 0.05
        and position.y < waterLevel - 0.05
end

HostGuardFaCybranMegalith = Class(
    "GuardFaCybranMegalith",
    SCO_MegalithEngineer)
local GuardFaCybranMegalith = HostGuardFaCybranMegalith

local function SCO_MegalithSetAwakeControl(unit, locked)
    if locked then
        if unit.scoMegalithAwakeControl ~= nil then
            error("FA Megalith Awake control may be acquired only once")
        end
        -- Set the order gate before the external movement call. A movement API
        -- failure therefore leaves the unit fail-closed instead of orderable.
        unit.scoMegalithAwakeControl = true
        local result = Engine.SetMovementEnabled(unit.id, false)
        if result ~= nil and result ~= EngineErrorCode.Success then
            error("FA Megalith could not suppress movement during Awake")
        end
        return
    end

    if unit.scoMegalithAwakeControl ~= true then return end
    local result = Engine.SetMovementEnabled(unit.id, true)
    if result ~= nil and result ~= EngineErrorCode.Success then
        error("FA Megalith could not restore movement after Awake")
    end
    unit.scoMegalithAwakeControl = false
end

local function SCO_MegalithCancelAwake(unit)
    if unit.scoMegalithAwakeThread then
        KillThread(unit.scoMegalithAwakeThread)
        unit.scoMegalithAwakeThread = nil
    end
    SCO_MegalithSetAwakeControl(unit, false)
end

function GuardFaCybranMegalith:SCORefreshLayerAndSpeed()
    if self.tpId ~= "ugl4002" or self.dead then return end
    local isSeabed = SCO_MegalithIsSeabed(self)
    if isSeabed == nil then return end
    local layer = isSeabed
        and SCO_MegalithLayers.Seabed
        or SCO_MegalithLayers.Land
    if self.targetingLayer ~= layer then self:SetTargetingLayer(layer) end
    local speed = isSeabed and 2.5 or 2
    if self.scoMegalithMaxSpeed ~= speed then
        local result = Engine.SetMovementMaxSpeed(self.id, speed)
        if result ~= nil and result ~= EngineErrorCode.Success then
            error("FA Megalith could not apply source water speed")
        end
        self.scoMegalithMaxSpeed = speed
    end
end

function GuardFaCybranMegalith:SCOAwakeThread()
    WaitSeconds(5)
    if not self.dead and not self.scoMegalithTerminal then
        SCO_MegalithSetAwakeControl(self, false)
        self.scoMegalithAwakeThread = nil
        self.scoMegalithAnimation = nil
        -- FA destroys the Awake animator here and returns to the model's bind
        -- pose. XRL0403_aidle01 exists in the archive but is never routed by
        -- the source unit or its walking base class.
        SCO_MegalithAnimation(
            self, "rest", SCO_MegalithRestBlendSeconds)
    end
end

function GuardFaCybranMegalith:CanBeAssignedToOrder(order)
    if self.scoMegalithAwakeControl == true then return false end
    local baseGate = SCO_MegalithEngineer.CanBeAssignedToOrder
    if type(baseGate) ~= "function" then
        error("FA Megalith could not resolve the base order gate")
    end
    return baseGate(self, order)
end

function GuardFaCybranMegalith:OnStopBeingBuilt(...)
    if self.tpId ~= "ugl4002" then
        error("GuardFaCybranMegalith may own only ugl4002")
    end
    if self.scoMegalithAwakeControl ~= nil then
        error("FA Megalith Awake lifecycle may start only once")
    end
    SCO_MegalithEngineer.OnStopBeingBuilt(self, ...)
    SCO_MegalithSetAwakeControl(self, true)
    self:SCORefreshLayerAndSpeed()
    SCO_MegalithAnimation(self, "awake")
    self.scoMegalithAwakeThread = self:NewThread(self.SCOAwakeThread)
end

function GuardFaCybranMegalith:UpdateAnimations()
    self:SCORefreshLayerAndSpeed()
    if self.dead or self.scoMegalithTerminal
        or self.scoMegalithAwakeControl == true
    then
        return
    end
    local speedResult, speed = Engine.GetMovementCurrentSpeed(self.id)
    if speedResult ~= EngineErrorCode.Success or type(speed) ~= "number" then
        -- A failed movement sample must not tear down an active gait.
        return
    end
    local yawResult, yaw = Engine.GetMovementChassisYawDegrees(self.id)
    local walking = self.scoMegalithAnimation == "walk"
    local speedThreshold = walking
        and SCO_MegalithWalkStopSpeed or SCO_MegalithWalkStartSpeed
    local yawThreshold = walking
        and SCO_MegalithWalkStopYaw or SCO_MegalithWalkStartYaw
    local moving = math.abs(speed) > speedThreshold
    if yawResult == EngineErrorCode.Success and type(yaw) == "number" then
        if self.scoMegalithLastYaw ~= nil then
            local delta = (yaw - self.scoMegalithLastYaw + 180) % 360 - 180
            moving = moving or math.abs(delta) > yawThreshold
        end
        self.scoMegalithLastYaw = yaw
    end
    if moving then
        SCO_MegalithAnimation(
            self, "walk", SCO_MegalithWalkBlendSeconds)
    else
        SCO_MegalithAnimation(
            self, "rest", SCO_MegalithRestBlendSeconds)
    end
end

function GuardFaCybranMegalith:OnDestroy(destroyType)
    self.scoMegalithTerminal = true
    SCO_MegalithCancelAwake(self)
    return SCO_MegalithEngineer.OnDestroy(self, destroyType)
end

function GuardFaCybranMegalith:DeathThread(overkillRatio)
    if self.tpId ~= "ugl4002" then
        return SCO_MegalithEngineer.DeathThread(self, overkillRatio)
    end
    self.scoMegalithTerminal = true
    SCO_MegalithCancelAwake(self)
    self.scoMegalithAnimation = nil
    Engine.SetMovementCollisionMask(self.id, 0)
    SCO_MegalithAnimation(self, "death")
    -- The source death clip clamps at 2.5 s; source 7500/r4/friendly damage
    -- occurs at 3.2 s when the stock terminal explosion is delegated below.
    WaitSeconds(3.2)
    return SCO_MegalithEngineer.DeathThread(self, overkillRatio)
end

local SCO_MegalithEggProducts = {
    ugs4902 = "ugl3501",
    ugs4903 = "ugl3001",
    ugs4904 = "ugl2201",
    ugs4905 = "ugl3101",
}

HostGuardMegalithEgg = Class("GuardMegalithEgg", SCO_MegalithStructure)
local GuardMegalithEgg = HostGuardMegalithEgg

local function SCO_MegalithEggBecomeVisualShell(self)
    -- HostStructure promotion makes a completed structure targetable and adds
    -- volume, navmap, and global placement-grid blockers. The FA egg instead
    -- becomes a visual hatch around its immediately spawned product.
    if self.productionMonitorThread then
        KillThread(self.productionMonitorThread)
        self.productionMonitorThread = nil
    end
    self:SetTargetable(false)
    Engine.SetVolumeColliderEnabled(self.id, false)
    self:SetNavmapModifiersEnabled(false)
    Engine.SetGlobalGridModifierEnabled(self.id, false)
end

function GuardMegalithEgg:SCOHatchThread()
    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations
    local open = animations and animations.open
    if not open or not open.id then
        error("Megalith egg requires the source-pinned Open clip")
    end
    local result = Engine.PlayAnimation(self.id, open.id, 0.1)
    if result ~= nil and result ~= EngineErrorCode.Success then
        error("Megalith egg Open animation failed")
    end
    WaitSeconds(6.666666865348816)
    for _ = 1, 40 do
        if self.dead or self.deleted then return end
        local position = self:GetPosition()
        if position == nil then error("Megalith egg lost its sink position") end
        self:SetPosition(EngineClasses.float3(
            position.x, position.y - 0.5, position.z))
        WaitTicks(1)
    end
    if not self.dead and not self.deleted then
        self:Destroy(0, DestroyType.Kinetic)
    end
end

function GuardMegalithEgg:OnStopBeingBuilt(...)
    SCO_MegalithStructure.OnStopBeingBuilt(self, ...)
    local product = SCO_MegalithEggProducts[self.tpId]
    local configured = self.tp and self.tp.additions
        and self.tp.additions.megalithEgg
        and self.tp.additions.megalithEgg.product
    if product == nil or configured ~= product then
        error("GuardMegalithEgg received an unowned or mismatched template")
    end
    if self.scoMegalithEggSpawned then
        error("Megalith egg completion attempted to duplicate its child")
    end
    -- Set the one-shot guard before the external creation call. A thrown
    -- creation error therefore fails closed and cannot duplicate on retry.
    self.scoMegalithEggSpawned = true
    SCO_MegalithEggBecomeVisualShell(self)
    CreateUnit(self.army.id, product, self:GetPosition());
    self.scoMegalithEggHatchThread = self:NewThread(self.SCOHatchThread)
end
-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0
local SCO_ScathisGuardLandUnit = HostGuardLandUnit or GuardLandUnit
if not SCO_ScathisGuardLandUnit then error("Scathis requires GuardLandUnit") end
HostGuardScathis = Class("GuardScathis", SCO_ScathisGuardLandUnit)
local GuardScathis = HostGuardScathis

function GuardScathis:RotatorsEnabledOnConstruction()
    return false
end

function GuardScathis:UpdateAnimations()
    -- URL0401 is tracked. Its only source clip is weapon-driven unpacking.
end

function GuardScathis:OnStopBeingBuilt()
    SCO_ScathisGuardLandUnit.OnStopBeingBuilt(self)
    local rest = self.tp.visuals and self.tp.visuals.animations
        and self.tp.visuals.animations.walk
    if not rest or not rest.id then error("Scathis requires its hash-pinned Rest clip") end
    Engine.PlayAnimation(self.id, rest.id, 0.1)
    self:SetRotatorsEnabled(false)
end

-- Supreme Commander Overhaul sea parity 1.0.0
local SCOSeaParityNavalFactoryHostBase = HostGuardNavalFactory
local SCOSeaParityFactoryLifecycle = _G.SCOFaAirFactoryLifecycle
local SCOSeaParityHostOrderManager = Import("host/managers/orders/hostOrderManager.lua")
local SCOSeaParityOrderTasks = Import("common/commonOrders.lua").OrderTasks
if not SCOSeaParityNavalFactoryHostBase or not SCOSeaParityFactoryLifecycle then
    error("Sea-parity naval-factory host dependencies are unavailable.")
end

HostGuardFaCybranNavalFactory = Class("GuardFaCybranNavalFactory", SCOSeaParityNavalFactoryHostBase)
local SCOSeaParityNavalFactoryHostClass = HostGuardFaCybranNavalFactory

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

-- Supreme Commander Overhaul Salem amphibious parity 1.0.0
local SCOSeaParitySalemBase = HostGuardNavalUnit
local SCOSeaParitySalemSentinelBase = -10000
local SCOSeaParitySalemLifecycle = {}
if not SCOSeaParitySalemBase then
    error("Salem amphibious host base is unavailable")
end
local SCOSeaParitySalemBaseOnStopBeingBuilt =
    SCOSeaParitySalemBase.OnStopBeingBuilt
local SCOSeaParitySalemBaseUpdateAnimations =
    SCOSeaParitySalemBase.UpdateAnimations
local SCOSeaParitySalemBaseOnDestroy =
    SCOSeaParitySalemBase.OnDestroy
local SCOSeaParitySalemBaseDeathThread =
    SCOSeaParitySalemBase.DeathThread
if not SCOSeaParitySalemBaseOnStopBeingBuilt
    or not SCOSeaParitySalemBaseUpdateAnimations
    or not SCOSeaParitySalemBaseOnDestroy
    or not SCOSeaParitySalemBaseDeathThread
then
    error("Salem amphibious host lifecycle hooks are unavailable")
end

local function SCOSeaParitySalemAlive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
end

local function SCOSeaParitySalemConfig(unit)
    local additions = unit.tp and unit.tp.additions
    return additions and additions.faSalemAmphibious
end

local function SCOSeaParitySalemAnimations(unit)
    local visuals = unit.tp and unit.tp.visuals
    return visuals and visuals.animations
end

function SCOSeaParitySalemLifecycle.IsSupported(unit)
    local config = SCOSeaParitySalemConfig(unit)
    return config ~= nil
        and unit.tp ~= nil
        and unit.tp.movement ~= nil
        and config.transformSourceClip == "AnimTransform02"
        and config.transformDurationSeconds == 7
        and config.transformSourceRate == 2
        and config.transformReverseSourceRate == -2
        and config.landRestAnimationKey == "salemLandRest"
        and config.landRestCrossFadeSeconds == 0.2
        and config.waterSpeed == 5
        and config.landSpeed == 2.5
        and config.waterColliderOffsetY == 0.36
        and config.landColliderOffsetY == 1.01
        and config.waterTerrainAlignmentFactor == 0
        and config.landTerrainAlignmentFactor == 1
        and config.landDeathPlaybackSeconds == 3
        and config.waterDeathSourceDurationSeconds == 21.7
        and config.waterDeathRateMin == 0.5
        and config.waterDeathRateMax == 1.5
        and config.waterDeathRateSteps == 101
        and config.waterPostWreckSeconds == 5
        and config.mediumDebounceTicks == 3
        and config.waterEnterDepth == 0.05
        and config.waterExitDepth == 0.01
end

function SCOSeaParitySalemLifecycle.Probe(unit, previousWater, position)
    local config = SCOSeaParitySalemConfig(unit)
    if not config then return nil end
    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success then return nil end
    if not hasWater then return false end
    local levelResult, waterLevel = Engine.GetWaterLevel()
    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return nil end
    local positionResult = Engine.GetGlobalEntityWorldPosition(unit.id, position)
    if positionResult ~= EngineErrorCode.Success then return nil end
    local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)
    if terrainResult ~= EngineErrorCode.Success or terrainHeight == nil then return nil end
    local requiredDepth = previousWater
        and config.waterExitDepth or config.waterEnterDepth
    -- Bathymetry alone misclassifies a Salem standing above submerged terrain.
    if position.y > waterLevel + requiredDepth then return false end
    return terrainHeight < waterLevel - requiredDepth
end

function SCOSeaParitySalemLifecycle.AcceptProbe(unit, probed, config)
    if probed == nil or probed == unit.scoSeaParitySalemMediumWater then
        unit.scoSeaParitySalemCandidateWater = nil
        unit.scoSeaParitySalemCandidateTicks = 0
        return
    end
    if unit.scoSeaParitySalemCandidateWater == probed then
        unit.scoSeaParitySalemCandidateTicks =
            unit.scoSeaParitySalemCandidateTicks + 1
    else
        unit.scoSeaParitySalemCandidateWater = probed
        unit.scoSeaParitySalemCandidateTicks = 1
    end
    if unit.scoSeaParitySalemCandidateTicks >= config.mediumDebounceTicks then
        unit.scoSeaParitySalemMediumWater = probed
        unit.scoSeaParitySalemCandidateWater = nil
        unit.scoSeaParitySalemCandidateTicks = 0
    end
end

function SCOSeaParitySalemLifecycle.SampleTransform(unit, elapsed, animation)
    unit.scoSeaParitySalemTransformElapsed = elapsed
    unit.scoSeaParitySalemAnimationOwner = "transform"
    Engine.PlayAnimation(
        unit.id, animation.id, SCOSeaParitySalemSentinelBase + elapsed)
end

function SCOSeaParitySalemLifecycle.ApplyTerrainAlignment(unit, water, config)
    local factor = water
        and config.waterTerrainAlignmentFactor
        or config.landTerrainAlignmentFactor
    if unit.scoSeaParitySalemTerrainAlignmentFactor == factor then return end
    local result = Engine.SetMovementTerrainAlignmentFactor(unit.id, factor)
    if result ~= EngineErrorCode.Success then
        error("Salem terrain-alignment transition failed")
    end
    unit.scoSeaParitySalemTerrainAlignmentFactor = factor
end

function SCOSeaParitySalemLifecycle.BeginTransform(
    unit, elapsed, animation, targetWater, config)
    SCOSeaParitySalemLifecycle.ApplyTerrainAlignment(
        unit, targetWater, config)
    if not unit.scoSeaParitySalemTransforming then
        Engine.SetMovementEnabled(unit.id, false)
        unit.scoSeaParitySalemTransforming = true
        unit.isWalking = true
        SCOSeaParitySalemLifecycle.SampleTransform(unit, elapsed, animation)
    end
end

function SCOSeaParitySalemLifecycle.PlayWaterRest(unit, animations)
    unit.scoSeaParitySalemAnimationOwner = "water-rest"
    unit.isWalking = true
    Engine.PlayAnimation(unit.id, animations.walk.id, 0.1)
end

function SCOSeaParitySalemLifecycle.PlayLandRest(unit, config, animations)
    unit.scoSeaParitySalemTransformElapsed = config.transformDurationSeconds
    unit.scoSeaParitySalemAnimationOwner = "land-rest"
    unit.isWalking = true
    Engine.PlayAnimation(
        unit.id,
        animations.salemLandRest.id,
        config.landRestCrossFadeSeconds)
end

function SCOSeaParitySalemLifecycle.PlayLandWalk(unit, animations)
    unit.scoSeaParitySalemAnimationOwner = "land-walk"
    unit.isWalking = false
    Engine.PlayAnimation(unit.id, animations.run.id, 0.1)
end

function SCOSeaParitySalemLifecycle.EnterStablePose(unit, water, config, animations)
    unit.scoSeaParitySalemTransforming = nil
    SCOSeaParitySalemLifecycle.ApplyTerrainAlignment(unit, water, config)
    Engine.SetMovementMaxSpeed(unit.id, water and config.waterSpeed or config.landSpeed)
    local colliderResult = Engine.SetVolumeColliderOffset(
        unit.id,
        EngineClasses.float3(
            0,
            water and config.waterColliderOffsetY or config.landColliderOffsetY,
            0))
    if colliderResult ~= EngineErrorCode.Success then
        error("Salem collider-offset transition failed")
    end
    if water then
        SCOSeaParitySalemLifecycle.PlayWaterRest(unit, animations)
    else
        SCOSeaParitySalemLifecycle.PlayLandRest(unit, config, animations)
    end
    Engine.SetMovementEnabled(unit.id, true)
end

function SCOSeaParitySalemLifecycle.MediumThread(unit)
    local config = SCOSeaParitySalemConfig(unit)
    local animations = SCOSeaParitySalemAnimations(unit)
    local transform = animations and animations.salemTransform
    if not SCOSeaParitySalemLifecycle.IsSupported(unit)
        or not animations.walk or not animations.walk.id
        or not animations.run or not animations.run.id
        or not animations.salemLandRest or not animations.salemLandRest.id
        or not transform or not transform.id
    then
        error("Salem amphibious runtime contract is incomplete")
    end

    local position = EngineClasses.float3()
    local initialWater = SCOSeaParitySalemLifecycle.Probe(unit, true, position)
    if initialWater == nil then initialWater = true end
    local elapsed = 0
    unit.scoSeaParitySalemMediumWater = initialWater
    unit.scoSeaParitySalemCandidateWater = nil
    unit.scoSeaParitySalemCandidateTicks = 0
    unit.scoSeaParitySalemTransformElapsed = elapsed
    if initialWater then
        SCOSeaParitySalemLifecycle.EnterStablePose(
            unit, true, config, animations)
    else
        SCOSeaParitySalemLifecycle.BeginTransform(
            unit, elapsed, transform, false, config)
    end

    while SCOSeaParitySalemAlive(unit)
        and unit.scoSeaParitySalemMovementActive == true
    do
        WaitTicks(1)
        if not SCOSeaParitySalemAlive(unit) then break end
        local probed = SCOSeaParitySalemLifecycle.Probe(
            unit, unit.scoSeaParitySalemMediumWater, position)
        SCOSeaParitySalemLifecycle.AcceptProbe(unit, probed, config)

        local target = unit.scoSeaParitySalemMediumWater
            and 0 or config.transformDurationSeconds
        if elapsed ~= target then
            SCOSeaParitySalemLifecycle.BeginTransform(
                unit, elapsed, transform,
                unit.scoSeaParitySalemMediumWater, config)
            local sourceRate = target > elapsed
                and config.transformSourceRate
                or config.transformReverseSourceRate
            elapsed = math.max(0, math.min(
                config.transformDurationSeconds,
                elapsed + sourceRate * Constants.TickTimeStep))
            SCOSeaParitySalemLifecycle.SampleTransform(unit, elapsed, transform)
            if elapsed == target then
                SCOSeaParitySalemLifecycle.EnterStablePose(
                    unit, unit.scoSeaParitySalemMediumWater, config, animations)
            end
        end
    end
    unit.scoSeaParitySalemMediumThread = nil
end

function SCOSeaParitySalemLifecycle.Start(unit)
    if not SCOSeaParitySalemConfig(unit) then return false end
    if unit.scoSeaParitySalemMovementUnavailable then return false end
    if not SCOSeaParitySalemLifecycle.IsSupported(unit) then
        error("Salem amphibious runtime contract is incomplete")
    end
    SCOSeaParitySalemLifecycle.Stop(unit)
    unit.scoSeaParitySalemMovementActive = true
    unit.scoSeaParitySalemMediumThread =
        unit:NewThread(SCOSeaParitySalemLifecycle.MediumThread)
    return true
end

function SCOSeaParitySalemLifecycle.Stop(unit, movementUnavailable)
    if unit.scoSeaParitySalemMediumThread then
        KillThread(unit.scoSeaParitySalemMediumThread)
    end
    unit.scoSeaParitySalemMediumThread = nil
    unit.scoSeaParitySalemMovementActive = nil
    if movementUnavailable then
        unit.scoSeaParitySalemMovementUnavailable = true
    end
    unit.scoSeaParitySalemCandidateWater = nil
    unit.scoSeaParitySalemCandidateTicks = nil
    unit.scoSeaParitySalemTransforming = nil
    unit.scoSeaParitySalemAnimationOwner = nil
    unit.scoSeaParitySalemTerrainAlignmentFactor = nil
end

function SCOSeaParitySalemLifecycle.SelectWaterDeath(unit, config)
    local keys = config.waterDeathAnimationKeys
    if not keys or #keys ~= 2 or config.waterDeathRateSteps < 2 then
        error("Salem water-death selection contract is incomplete")
    end
    local identity = unit.id and unit.id.index or 0
    local key = keys[(identity % 2) + 1]
    local step = math.floor(identity / 2) % config.waterDeathRateSteps
    local rate = config.waterDeathRateMin
        + (config.waterDeathRateMax - config.waterDeathRateMin)
            * step / (config.waterDeathRateSteps - 1)
    return key, rate
end

function SCOSeaParitySalemLifecycle.SampleWaterDeath(unit, animation, elapsed)
    unit.scoSeaParitySalemDeathElapsed = elapsed
    unit.scoSeaParitySalemAnimationOwner = "water-death"
    Engine.PlayAnimation(
        unit.id, animation.id, SCOSeaParitySalemSentinelBase + elapsed)
end

function SCOSeaParitySalemLifecycle.PlayWaterDeath(unit, animation, config, rate)
    local elapsed = 0
    SCOSeaParitySalemLifecycle.SampleWaterDeath(unit, animation, elapsed)
    while elapsed < config.waterDeathSourceDurationSeconds do
        WaitTicks(1)
        if unit.deleted then return false end
        elapsed = math.min(
            config.waterDeathSourceDurationSeconds,
            elapsed + rate * Constants.TickTimeStep)
        SCOSeaParitySalemLifecycle.SampleWaterDeath(unit, animation, elapsed)
    end
    return true
end

function SCOSeaParitySalemBase:OnStopBeingBuilt(...)
    SCOSeaParitySalemBaseOnStopBeingBuilt(self, ...)
    if SCOSeaParitySalemConfig(self) then
        self.scoSeaParitySalemMovementUnavailable = nil
        SCOSeaParitySalemLifecycle.Start(self)
    end
end

function SCOSeaParitySalemBase:UpdateAnimations()
    if not SCOSeaParitySalemConfig(self) then
        return SCOSeaParitySalemBaseUpdateAnimations(self)
    end
    if not SCOSeaParitySalemLifecycle.IsSupported(self) then
        error("Salem amphibious runtime contract is incomplete")
    end
    if self.dead or self.deleted or not self:IsCompleted() then return end
    if not self.scoSeaParitySalemMediumThread then
        SCOSeaParitySalemLifecycle.Start(self)
        return
    end
    if self.scoSeaParitySalemMovementActive ~= true then return end
    if self.scoSeaParitySalemTransforming then return end
    if self.scoSeaParitySalemMediumWater then
        if self.scoSeaParitySalemAnimationOwner ~= "water-rest" then
            local animations = SCOSeaParitySalemAnimations(self)
            if animations and animations.walk and animations.walk.id then
                SCOSeaParitySalemLifecycle.PlayWaterRest(self, animations)
            end
        end
        return
    end
    local config = SCOSeaParitySalemConfig(self)
    local animations = SCOSeaParitySalemAnimations(self)
    if not config or not animations or not animations.run or not animations.run.id
        or not animations.salemLandRest or not animations.salemLandRest.id
    then
        error("Salem land-animation contract is incomplete")
    end
    local movementResult, movementSpeed = Engine.GetMovementCurrentSpeed(self.id)
    if movementResult ~= EngineErrorCode.Success
        or type(movementSpeed) ~= "number"
    then
        -- The engine removes Movement before every remaining Lua callback is
        -- necessarily drained. Make the first failed sample terminal so the
        -- global animation dispatcher cannot query the missing component again.
        SCOSeaParitySalemLifecycle.Stop(self, true)
        return
    end
    if movementSpeed >= (animations.run.startSpeed or 0) then
        if self.scoSeaParitySalemAnimationOwner ~= "land-walk" then
            SCOSeaParitySalemLifecycle.PlayLandWalk(self, animations)
        end
    elseif self.scoSeaParitySalemAnimationOwner ~= "land-rest" then
        SCOSeaParitySalemLifecycle.PlayLandRest(self, config, animations)
    end
end

function SCOSeaParitySalemBase:OnDestroy(...)
    if not SCOSeaParitySalemConfig(self) then
        return SCOSeaParitySalemBaseOnDestroy(self, ...)
    end
    local position = EngineClasses.float3()
    local deathWater = self.scoSeaParitySalemMediumWater == true
    local probed = SCOSeaParitySalemLifecycle.Probe(self, deathWater, position)
    if probed ~= nil then deathWater = probed end
    self.scoSeaParitySalemDeathWater = deathWater
    SCOSeaParitySalemLifecycle.Stop(self)
    return SCOSeaParitySalemBaseOnDestroy(self, ...)
end

function SCOSeaParitySalemBase:DeathThread(overkillRatio)
    local config = SCOSeaParitySalemConfig(self)
    if not config then
        return SCOSeaParitySalemBaseDeathThread(self, overkillRatio)
    end
    if not SCOSeaParitySalemLifecycle.IsSupported(self) then
        error("Salem amphibious runtime contract is incomplete")
    end
    local animations = SCOSeaParitySalemAnimations(self)
    if not animations then
        error("Salem death animation contract is incomplete")
    end
    Engine.SetMovementEnabled(self.id, false)
    if self.scoSeaParitySalemDeathWater then
        local key, rate = SCOSeaParitySalemLifecycle.SelectWaterDeath(self, config)
        local animation = animations[key]
        if not animation or not animation.id then
            error("Salem water-death animation contract is incomplete")
        end
        self.scoSeaParitySalemWaterDeathKey = key
        self.scoSeaParitySalemWaterDeathRate = rate
        if not SCOSeaParitySalemLifecycle.PlayWaterDeath(
            self, animation, config, rate)
        then
            return
        end
        if self:GetFractionComplete() >= 0.5 and self.spawnsWreck then
            self:CreateWreckage(overkillRatio or 0)
        end
        WaitSeconds(config.waterPostWreckSeconds)
    else
        local animation = animations[config.landDeathAnimationKey]
        if not animation or not animation.id then
            error("Salem land-death animation contract is incomplete")
        end
        self.scoSeaParitySalemAnimationOwner = "land-death"
        Engine.PlayAnimation(self.id, animation.id, 0.1)
        WaitSeconds(config.landDeathPlaybackSeconds)
        if self:GetFractionComplete() >= 0.5 and self.spawnsWreck then
            self:CreateWreckage(0.1)
        end
    end
    self:Delete()
end

-- The named class remains the canonical template binding, while the
-- faSalemAmphibious contract on HostGuardNavalUnit owns every lifecycle
-- hook.  This also repairs a completed Salem instantiated through the
-- default GuardNavalUnit class without double-starting its monitor.
HostGuardFaCybranSalem = Class("GuardFaCybranSalem", SCOSeaParitySalemBase)

_G.SCOSeaParitySalemLifecycle = SCOSeaParitySalemLifecycle

-- Supreme Commander Overhaul factory staging hook 1.0.2
-- Retail DRL0204 equal-weight death variants; nominal playback rate.
-- Delay final wreck/delete through the existing native DeathThread lifecycle.
-- Scoped unit guard preserves all other faction and previously patched units.
local SCOM_PreviousDeath_ugl2101 = HostGuardLandUnit.DeathThread
local SCOM_DeathVariants_ugl2101 = {
    { name = "death", duration = 1.66666663 },
    { name = "death01", duration = 1.66666663 },
    { name = "death02", duration = 1.66666663 }
}
function HostGuardLandUnit:DeathThread(overkillRatio)
    if self.tpId ~= "ugl2101" then
        return SCOM_PreviousDeath_ugl2101(self, overkillRatio)
    end
    if not self.dead then error("ugl2101: death animation dispatched before destruction") end
    local variant = SCOM_DeathVariants_ugl2101[((self.id.index or 0) % #SCOM_DeathVariants_ugl2101) + 1]
    local animation = self.tp.visuals.animations[variant.name]
    if not animation or not animation.id then error("ugl2101: source death clip is not registered") end
    Engine.PlayAnimation(self.id, animation.id, 0.1)
    WaitSeconds(variant.duration)
    return SCOM_PreviousDeath_ugl2101(self, overkillRatio)
end
-- SCOM factory egress Guard installation 1.0.0
local factoryEgress = Import("common/systems/scoFactoryEgress.lua")
factoryEgress.Install(HostGuardCybranLandFactory)
factoryEgress.Install(HostGuardFaCybranAirFactory)
factoryEgress.Install(HostGuardFaCybranNavalFactory)

-- FA pauses each Cybran land factory's Abuild animator on production stop.
-- Sanctuary has no exposed animator-rate setter. Its native animation clock
-- advances after each elapsed sample, so repeat the held phase every tick while
-- idle and continue from that phase when the next product begins.
-- Keep the transmitted clock continuous: rendering interpolates raw times
-- before applying Loop. Wrapping at the 10-second clip seam sweeps backward.
local CybranElapsedSampleBase = -20000

local function CybranBuildAnimation(factory)
    local animations = factory.tp.visuals and factory.tp.visuals.animations
    local build = animations and animations.build
    assert(build and build.id and build.clipName == "AnimBuild",
        "Cybran factory Abuild animation contract changed")
    return build
end

local SampleCybranBuild

local function StopCybranBuildSampler(factory, hold, expectedTarget)
    local state = factory.scoCybranBuildPose
    if not state then return end
    if expectedTarget and state.target and state.target ~= expectedTarget then
        -- A delayed callback for an earlier product must not stop the current one.
        if hold and not factory.dead and not factory.deleted then
            Engine.PlayAnimation(factory.id, state.animationId,
                CybranElapsedSampleBase - state.elapsedSeconds)
        end
        return
    end
    state.active = false
    state.target = nil
    if hold and not factory.dead and not factory.deleted then
        state.hold = true
        Engine.PlayAnimation(factory.id, state.animationId,
            CybranElapsedSampleBase - state.elapsedSeconds)
        if not state.thread then
            state.thread = factory:NewThread(SampleCybranBuild, state)
        end
    else
        state.hold = false
        if state.thread then KillThread(state.thread) end
        state.thread = nil
    end
end

SampleCybranBuild = function(factory, state)
    while (state.active or state.hold) and not factory.dead and not factory.deleted
        and (not state.active or (state.target and not state.target.dead and not state.target.deleted))
    do
        Engine.PlayAnimation(factory.id, state.animationId,
            CybranElapsedSampleBase - state.elapsedSeconds)
        WaitTicks(1)
        if state.active and not factory:GetPause()
            and state.target and not state.target.dead and not state.target.deleted
            and factory:IsBuilding(state.target)
        then
            state.elapsedSeconds = state.elapsedSeconds + Constants.TickTimeStep
        end
    end
    if factory.scoCybranBuildPose == state then
        state.active = false
        state.hold = false
        state.thread = nil
        state.target = nil
    end
end

local function InstallCybranBuildPose(class)
    local start = class.OnStartBuildRoutine
    class.OnStartBuildRoutine = function(self, target, ...)
        local upgrading = self:IsUpgrading() and self.upgradeTarget == target
        local result = start(self, target, ...)
        if upgrading then
            StopCybranBuildSampler(self, false)
            return result
        end
        if not target or target.dead or target.deleted then return result end
        local build = CybranBuildAnimation(self)
        local state = self.scoCybranBuildPose
        if not state then
            state = {elapsedSeconds = 0}
            self.scoCybranBuildPose = state
        end
        if state.thread then KillThread(state.thread) end
        state.animationId = build.id
        state.target = target
        state.hold = false
        state.active = true
        state.thread = self:NewThread(SampleCybranBuild, state)
        return result
    end

    local stop = class.OnStopBuildRoutine
    class.OnStopBuildRoutine = function(self, target, ...)
        local upgrading = self:IsUpgrading() and self.upgradeTarget == target
        local result = stop(self, target, ...)
        StopCybranBuildSampler(self, not upgrading, target)
        return result
    end

    local productionStop = class.ProductionBehaviorStop
    class.ProductionBehaviorStop = function(self, ...)
        local result = productionStop(self, ...)
        StopCybranBuildSampler(self, not self:IsUpgrading())
        return result
    end

    local cancel = class.OnCancelConstruction
    class.OnCancelConstruction = function(self, ...)
        local result = cancel(self, ...)
        StopCybranBuildSampler(self, not self:IsUpgrading())
        return result
    end

    local destroy = class.OnDestroy
    class.OnDestroy = function(self, ...)
        StopCybranBuildSampler(self, false)
        return destroy(self, ...)
    end
end

InstallCybranBuildPose(HostGuardCybranLandFactory)
-- The animated factory derives from the base. Install its egress wrapper only
-- after it can capture the base's single pose wrapper; a second pose install
-- would start two sampling threads for one production event.
factoryEgress.Install(HostGuardCybranAnimatedLandFactory)
