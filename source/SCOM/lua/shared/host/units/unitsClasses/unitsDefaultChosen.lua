--- This file contains default Chosen units classes.

-- Default Chosen units classes definitions
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



-------------------------
-- Chosen Structure class
-------------------------
HostChosenStructure = Class("ChosenStructure", Structure)



-------------------------------
-- Chosen Naval Structure class
-------------------------------
HostChosenNavalStructure = Class("ChosenNavalStructure", NavalStructure)



-------------------------
-- Chosen Structure class
-------------------------
HostChosenTechCentre = Class("ChosenTechCentre", TechCentre)



--------------------------------
-- Chosen Naval TechCentre class
--------------------------------
HostChosenNavalTechCentre = Class("ChosenNavalTechCentre", NavalTechCentre)



-----------------------------------
-- Chosen Engineering Station class
-----------------------------------
HostChosenEngineeringStation = Class("ChosenEngineeringStation", EngineeringStation)



-----------------------
-- Chosen Storage class
-----------------------
HostChosenStorage = Class("Storage", Storage)



---------------------------
-- Chosen Air Factory class
---------------------------
HostChosenAirFactory = Class("ChosenAirFactory", AirFactory)



----------------------------
-- Chosen Land Factory class
----------------------------
HostChosenLandFactory = Class("ChosenLandFactory", LandFactory)



-----------------------------
-- Chosen Naval Factory class
-----------------------------
HostChosenNavalFactory = Class("ChosenNavalFactory", NavalFactory)



------------------------
-- Chosen Alloy Extractor
------------------------
HostChosenAlloyExtractor = Class("ChosenAlloyExtractor", AlloyExtractor)



-------------------------
-- Chosen Energy Generator
-------------------------
HostChosenEnergyGenerator = Class("ChosenEnergyGenerator", EnergyGenerator)



------------------------
-- Chosen Air Unit class
------------------------
HostChosenAirUnit = Class("ChosenAirUnit", AirUnit)



-------------------------
-- Chosen Land Unit class
-------------------------
HostChosenLandUnit = Class("ChosenLandUnit", LandUnit)



--------------------------
-- Chosen Naval Unit class
--------------------------
HostChosenNavalUnit = Class("ChosenNavalUnit", NavalUnit)



--------------------------
-- Chosen Submarine class
--------------------------
HostChosenSubmarine = Class("ChosenSubmarine", Submarine)



------------------------
-- Chosen Engineer class
------------------------
HostChosenEngineer = Class("ChosenEngineer", Engineer)



-------------------------
-- Chosen Commander class
-------------------------
HostChosenCommander = Class("ChosenCommander", Commander)


-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0
-- The stock Chosen module exports realm-prefixed classes. Keep the
-- established short names local to this generated appendix so every
-- Aeon port and its later lifecycle delegates resolve the Host class.
local ChosenStructure = HostChosenStructure
local ChosenEngineeringStation = HostChosenEngineeringStation
local ChosenStorage = HostChosenStorage
local ChosenAirFactory = HostChosenAirFactory
local ChosenLandFactory = HostChosenLandFactory
local ChosenNavalFactory = HostChosenNavalFactory
local ChosenAlloyExtractor = HostChosenAlloyExtractor
local ChosenEnergyGenerator = HostChosenEnergyGenerator
local ChosenAirUnit = HostChosenAirUnit
local ChosenLandUnit = HostChosenLandUnit
local ChosenNavalUnit = HostChosenNavalUnit
local ChosenEngineer = HostChosenEngineer

HostAeonPortLandUnit = Class("AeonPortLandUnit", ChosenLandUnit)
HostAeonPortAirUnit = Class("AeonPortAirUnit", ChosenAirUnit)
HostAeonPortNavalUnit = Class("AeonPortNavalUnit", ChosenNavalUnit)
HostAeonPortEngineer = Class("AeonPortEngineer", ChosenEngineer)
HostAeonPortStructure = Class("AeonPortStructure", ChosenStructure)
HostAeonPortStorage = Class("AeonPortStorage", ChosenStorage)
HostAeonPortAlloyExtractor = Class("AeonPortAlloyExtractor", ChosenAlloyExtractor)
HostAeonPortEnergyGenerator = Class("AeonPortEnergyGenerator", ChosenEnergyGenerator)
HostAeonPortEngineeringStation = Class("AeonPortEngineeringStation", ChosenEngineeringStation)
HostAeonPortLandFactory = Class("AeonPortLandFactory", ChosenLandFactory)
HostAeonPortAirFactory = Class("AeonPortAirFactory", ChosenAirFactory)
HostAeonPortNavalFactory = Class("AeonPortNavalFactory", ChosenNavalFactory)

local AeonPortLandUnit = HostAeonPortLandUnit
local AeonPortAirUnit = HostAeonPortAirUnit
local AeonPortNavalUnit = HostAeonPortNavalUnit
local AeonPortEngineer = HostAeonPortEngineer
local AeonPortStructure = HostAeonPortStructure
local AeonPortStorage = HostAeonPortStorage
local AeonPortAlloyExtractor = HostAeonPortAlloyExtractor
local AeonPortEnergyGenerator = HostAeonPortEnergyGenerator
local AeonPortEngineeringStation = HostAeonPortEngineeringStation
local AeonPortLandFactory = HostAeonPortLandFactory
local AeonPortAirFactory = HostAeonPortAirFactory
local AeonPortNavalFactory = HostAeonPortNavalFactory

local scoAeonFactoryOrderTasks =
    Import("common/commonOrders.lua").OrderTasks
local scoAeonFactoryHostOrderManager =
    Import("host/managers/orders/hostOrderManager.lua")
local scoAeonFactoryUnits = __Entities.Units

local function scoAeonFactoryIsAlive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
end

local function scoAeonFactoryIsCurrent(unit)
    local id = unit and unit.id
    return scoAeonFactoryIsAlive(unit)
        and id ~= nil
        and scoAeonFactoryUnits[id.index] == unit
end

local function scoAeonFactoryWorldPoint(factory, offset)
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

local function scoAeonFactoryGetTargetKey(targetUnit)
    local id = targetUnit and targetUnit.id
    if id == nil then
        return nil
    end
    return tostring(id.index) .. ":" .. tostring(id.version)
end

local function scoAeonFactoryIsFiniteNumber(value)
    return type(value) == "number"
        and value == value
        and value > -math.huge
        and value < math.huge
end

local function scoAeonFactoryIsFiniteVector(value)
    return type(value) == "table"
        and scoAeonFactoryIsFiniteNumber(value.x)
        and scoAeonFactoryIsFiniteNumber(value.y)
        and scoAeonFactoryIsFiniteNumber(value.z)
end

local function scoAeonFactoryHasRouting(factory)
    local additions = factory.tp.additions
    local staging = additions and additions.buildStagingOffset
    if staging == nil then
        local construction = factory.tp.construction
        local donorPoints =
            construction and construction.rollOffPoints
        if donorPoints
            and donorPoints[1]
            and scoAeonFactoryIsFiniteVector(
                donorPoints[1].offset)
        then
            -- UAB0304 is a separately scoped SACU gateway that
            -- shares this class and intentionally retains stock
            -- staging/roll-off metadata.
            return false
        end
        error(
            "Factory has neither exact Aeon routing nor a valid donor roll-off point: "
                .. tostring(factory.tpId))
    end

    local ramps = additions.rollOffRamps
    local surfacePolicy = additions.rollOffSurfacePolicy
    local valid = scoAeonFactoryIsFiniteVector(staging)
        and type(ramps) == "table"
        and #ramps == 2
        and (
            surfacePolicy == "terrain"
            or surfacePolicy == "factory")
    if valid then
        for _, ramp in ipairs(ramps) do
            if not scoAeonFactoryIsFiniteVector(ramp.rampOffset)
                or not scoAeonFactoryIsFiniteVector(
                    ramp.clearanceOffset)
                or not scoAeonFactoryIsFiniteNumber(
                    ramp.headingDegrees)
            then
                valid = false
                break
            end
        end
    end
    if not valid then
        error(
            "Imported Aeon factory routing metadata is malformed: "
                .. tostring(factory.tpId))
    end
    return true
end

local function scoAeonFactoryGetRamps(factory)
    if not scoAeonFactoryHasRouting(factory) then
        error("Stock-routed factory has no authored Aeon ramps.")
    end
    return factory.tp.additions.rollOffRamps
end

local function scoAeonFactoryRoutePoint(factory, offset)
    local point = scoAeonFactoryWorldPoint(factory, offset)
    local policy = factory.tp.additions.rollOffSurfacePolicy
    if policy == "terrain" then
        local _, terrainHeight = Engine.SampleTerrainHeight(
            EngineClasses.float3(point.x, 0, point.z))
        point.y = terrainHeight
    elseif policy ~= "factory" then
        error(
            "Imported Aeon factory has an invalid surface policy: "
                .. tostring(factory.tpId))
    end
    return point
end

local function scoAeonFactorySelectRamp(factory, targetUnit)
    local ramps = scoAeonFactoryGetRamps(factory)
    local key = scoAeonFactoryGetTargetKey(targetUnit)
    local selectedIndexes = factory.scoAeonFactoryRollOffRampIndexes
    local selectedIndex =
        key and selectedIndexes and selectedIndexes[key]
    if selectedIndex then
        return ramps[selectedIndex]
    end

    local source = factory.unitBeingBuiltSource or factory
    local rallyPoint = source.rallyPoint
    if rallyPoint then
        local closestDistanceSquared = nil
        for index, ramp in ipairs(ramps) do
            local clearancePoint = scoAeonFactoryRoutePoint(
                factory,
                ramp.clearanceOffset or ramp.rampOffset)
            local deltaX = clearancePoint.x - rallyPoint.x
            local deltaZ = clearancePoint.z - rallyPoint.z
            local distanceSquared =
                (deltaX * deltaX) + (deltaZ * deltaZ)
            if closestDistanceSquared == nil
                or distanceSquared < closestDistanceSquared
            then
                closestDistanceSquared = distanceSquared
                selectedIndex = index
            end
        end
    else
        selectedIndex = factory.scoAeonFactoryNextRollOffRampIndex or 1
        if selectedIndex < 1 or selectedIndex > #ramps then
            selectedIndex = 1
        end
        factory.scoAeonFactoryNextRollOffRampIndex = selectedIndex + 1
        if factory.scoAeonFactoryNextRollOffRampIndex > #ramps then
            factory.scoAeonFactoryNextRollOffRampIndex = 1
        end
    end

    if key then
        factory.scoAeonFactoryRollOffRampIndexes =
            selectedIndexes or {}
        factory.scoAeonFactoryRollOffRampIndexes[key] = selectedIndex
    end
    return ramps[selectedIndex]
end

local function scoAeonFactoryForgetRamp(factory, targetUnit)
    local key = scoAeonFactoryGetTargetKey(targetUnit)
    local selectedIndexes = factory.scoAeonFactoryRollOffRampIndexes
    if key and selectedIndexes then
        selectedIndexes[key] = nil
    end
end

local function scoAeonFactoryFaceRamp(factory, targetUnit, ramp)
    if not scoAeonFactoryIsAlive(targetUnit) or ramp == nil then
        return
    end
    local localOrientation = Engine.EulerToQuaternion(
        EngineClasses.float3(
            0,
            math.rad(ramp.headingDegrees or 0),
            0),
        RotationOrder.Default)
    local orientation = Engine.QuaternionMultiply(
        factory:GetOrientation(),
        localOrientation)
    targetUnit:SetOrientation(orientation)
end

local function scoAeonFactoryFinishLandRollOff(
    targetUnit,
    factory,
    clearancePoint)
    if not scoAeonFactoryIsCurrent(targetUnit) then
        return
    end
    -- Pin the final terrain height before collision returns. This
    -- also provides a bounded safe fallback if movement is ever
    -- interrupted before the clearance waypoint is reached.
    targetUnit:SetPosition(clearancePoint)
    if targetUnit.scoFactoryColliderPinOwner == factory then
        targetUnit.scoFactoryColliderPinOwner = nil
    end
    Engine.SetVolumeColliderEnabled(targetUnit.id, true)
end

local function scoAeonFactoryLandRollOffReleaseThread(
    targetUnit,
    factory,
    clearancePoint)
    local remainingTicks = 300
    while scoAeonFactoryIsCurrent(targetUnit)
        and remainingTicks > 0
    do
        local position = targetUnit:GetPosition()
        local deltaX = position.x - clearancePoint.x
        local deltaZ = position.z - clearancePoint.z
        if (deltaX * deltaX) + (deltaZ * deltaZ) <= 1 then
            scoAeonFactoryFinishLandRollOff(
                targetUnit,
                factory,
                clearancePoint)
            targetUnit.scoAeonFactoryLandRollOffThread = nil
            return
        end
        remainingTicks = remainingTicks - 1
        WaitTicks(1)
    end
    scoAeonFactoryFinishLandRollOff(
        targetUnit,
        factory,
        clearancePoint)
    if scoAeonFactoryIsCurrent(targetUnit) then
        targetUnit.scoAeonFactoryLandRollOffThread = nil
    end
end

local function scoAdaptAeonFactoryClass(factoryClass, baseClass)
    factoryClass.GetConstructionSpawnPoint = function(self)
        if not scoAeonFactoryHasRouting(self) then
            return baseClass.GetConstructionSpawnPoint(self)
        end
        return scoAeonFactoryWorldPoint(
            self,
            self.tp.additions.buildStagingOffset)
    end

    factoryClass.StopAeonFactoryBuildColliderPin = function(
        self,
        targetUnit)
        if targetUnit ~= nil
            and self.scoAeonFactoryPinnedBuildTarget ~= targetUnit
        then
            return
        end
        local pinnedTarget = self.scoAeonFactoryPinnedBuildTarget
        self.scoAeonFactoryPinnedBuildTarget = nil
        if pinnedTarget
            and pinnedTarget.scoFactoryColliderPinOwner == self
        then
            pinnedTarget.scoFactoryColliderPinOwner = nil
        end
    end

    factoryClass.PinAeonFactoryBuildCollider = function(
        self,
        targetUnit)
        self:StopAeonFactoryBuildColliderPin()
        if not scoAeonFactoryIsAlive(targetUnit)
            or not targetUnit:HasTags(Tags.MOBILE)
            or targetUnit:IsCompleted()
        then
            return
        end

        self.scoAeonFactoryPinnedBuildTarget = targetUnit
        targetUnit.scoFactoryColliderPinOwner = self
        targetUnit:SetOrientation(self:GetOrientation())
        targetUnit:SetPosition(self:GetConstructionSpawnPoint())
        Engine.SetVolumeColliderEnabled(targetUnit.id, false)
    end

    factoryClass.StopAeonFactoryBuildTargetWatchThread = function(
        self)
        local thread = self.scoAeonFactoryBuildTargetWatchThread
        self.scoAeonFactoryBuildTargetWatchThread = nil
        if thread ~= nil then
            KillThread(thread)
        end
    end

    factoryClass.ScoAeonFactoryBuildTargetWatchThread = function(
        self,
        targetUnit)
        while not self.dead
            and self.scoAeonFactoryPinnedBuildTarget == targetUnit
            and scoAeonFactoryIsCurrent(targetUnit)
            and not targetUnit:IsCompleted()
        do
            WaitTicks(1)
        end
        self.scoAeonFactoryBuildTargetWatchThread = nil
        if not scoAeonFactoryIsCurrent(targetUnit) then
            self:StopAeonFactoryBuildColliderPin(targetUnit)
            scoAeonFactoryForgetRamp(self, targetUnit)
        end
    end

    factoryClass.StartAeonFactoryBuildTargetWatchThread = function(
        self,
        targetUnit)
        self:StopAeonFactoryBuildTargetWatchThread()
        if scoAeonFactoryIsAlive(targetUnit)
            and targetUnit:HasTags(Tags.MOBILE)
            and not targetUnit:IsCompleted()
        then
            self.scoAeonFactoryBuildTargetWatchThread =
                self:NewThread(
                    self.ScoAeonFactoryBuildTargetWatchThread,
                    targetUnit)
        end
    end

    factoryClass.ReleaseAeonFactoryBuiltUnit = function(
        self,
        targetUnit,
        ramp)
        if not scoAeonFactoryIsAlive(targetUnit)
            or not targetUnit:HasTags(Tags.MOBILE)
            or not targetUnit:IsCompleted()
            or ramp == nil
        then
            return false
        end

        local clearancePoint = scoAeonFactoryRoutePoint(
            self,
            ramp.clearanceOffset or ramp.rampOffset)
        -- Move clear before the stock callback restores paired
        -- collision. Restoring collision at the build bone lets
        -- large units intersect or sink through the factory hull.
        scoAeonFactoryFaceRamp(self, targetUnit, ramp)
        targetUnit:SetPosition(clearancePoint)
        self:StopAeonFactoryBuildColliderPin(targetUnit)
        if scoAeonFactoryIsAlive(targetUnit) then
            Engine.SetVolumeColliderEnabled(targetUnit.id, true)
        end
        return true
    end

    factoryClass.OnStartBuildRoutine = function(self, targetUnit)
        if not scoAeonFactoryHasRouting(self) then
            baseClass.OnStartBuildRoutine(self, targetUnit)
            return
        end
        self:PinAeonFactoryBuildCollider(targetUnit)
        self:StartAeonFactoryBuildTargetWatchThread(targetUnit)
        baseClass.OnStartBuildRoutine(self, targetUnit)
        -- Self-upgrade targets are structures. They share this
        -- callback but must retain the factory's authored rotation
        -- and must not consume a production-child ramp slot.
        if scoAeonFactoryIsAlive(targetUnit)
            and targetUnit:HasTags(Tags.MOBILE)
            and not targetUnit:IsCompleted()
        then
            local ramp = scoAeonFactorySelectRamp(self, targetUnit)
            scoAeonFactoryFaceRamp(self, targetUnit, ramp)
            targetUnit:SetPosition(self:GetConstructionSpawnPoint())
            Engine.SetVolumeColliderEnabled(targetUnit.id, false)
        end
    end

    factoryClass.OnStopBuildRoutine = function(self, targetUnit)
        if not scoAeonFactoryHasRouting(self) then
            baseClass.OnStopBuildRoutine(self, targetUnit)
            return
        end
        self:StopAeonFactoryBuildTargetWatchThread()
        local completed = scoAeonFactoryIsAlive(targetUnit)
            and targetUnit:HasTags(Tags.MOBILE)
            and targetUnit:IsCompleted()
        local landRollOff = completed
            and self.tp.additions.rollOffSurfacePolicy == "terrain"
        if completed and not landRollOff then
            self:ReleaseAeonFactoryBuiltUnit(
                targetUnit,
                scoAeonFactorySelectRamp(self, targetUnit))
        elseif landRollOff then
            -- Keep collision pinned while RollOffUnit drives the
            -- completed land child through the authored exit.
            Engine.SetVolumeColliderEnabled(targetUnit.id, false)
        elseif scoAeonFactoryIsAlive(targetUnit)
            and targetUnit:HasTags(Tags.MOBILE)
        then
            Engine.SetVolumeColliderEnabled(targetUnit.id, false)
        else
            self:StopAeonFactoryBuildColliderPin(targetUnit)
            scoAeonFactoryForgetRamp(self, targetUnit)
        end
        baseClass.OnStopBuildRoutine(self, targetUnit)
        if (not completed or landRollOff)
            and scoAeonFactoryIsAlive(targetUnit)
            and targetUnit:HasTags(Tags.MOBILE)
        then
            Engine.SetVolumeColliderEnabled(targetUnit.id, false)
            if not completed then
                -- A pause can leave the partial child alive; keep
                -- watching until resume or later abort/delete so
                -- collider/ramp ownership cannot become stale.
                self:StartAeonFactoryBuildTargetWatchThread(
                    targetUnit)
            end
        end
    end

    factoryClass.RollOffUnit = function(self, targetUnit)
        if not scoAeonFactoryHasRouting(self) then
            baseClass.RollOffUnit(self, targetUnit)
            return
        end
        if not scoAeonFactoryIsAlive(targetUnit)
            or not targetUnit:HasTags(Tags.MOBILE)
        then
            scoAeonFactoryForgetRamp(self, targetUnit)
            return
        end

        local ramp = scoAeonFactorySelectRamp(self, targetUnit)
        local rampPoint = scoAeonFactoryRoutePoint(
            self,
            ramp.rampOffset)
        local clearancePoint = scoAeonFactoryRoutePoint(
            self,
            ramp.clearanceOffset or ramp.rampOffset)
        scoAeonFactoryFaceRamp(self, targetUnit, ramp)
        local landRollOff =
            self.tp.additions.rollOffSurfacePolicy == "terrain"
        local queuedRoute = false
        if landRollOff then
            -- The completed land child crosses the real source
            -- ramp with collision disabled, then the child-owned
            -- watcher restores collision at terrain clearance.
            Engine.SetVolumeColliderEnabled(targetUnit.id, false)
            self:StopAeonFactoryBuildColliderPin(targetUnit)
            if targetUnit.scoAeonFactoryLandRollOffThread == nil then
                targetUnit.scoAeonFactoryLandRollOffThread =
                    targetUnit:NewThread(
                        scoAeonFactoryLandRollOffReleaseThread,
                        self,
                        clearancePoint)
            end
            scoAeonFactoryHostOrderManager.HostIssueOrder(
                scoAeonFactoryOrderTasks.MOVE,
                { targetUnit },
                false,
                rampPoint,
                nil)
            scoAeonFactoryHostOrderManager.HostIssueOrder(
                scoAeonFactoryOrderTasks.MOVE,
                { targetUnit },
                true,
                clearancePoint,
                nil)
            queuedRoute = true
        else
            local released = self:ReleaseAeonFactoryBuiltUnit(
                targetUnit,
                ramp)
            if not released then
                scoAeonFactoryHostOrderManager.HostIssueOrder(
                    scoAeonFactoryOrderTasks.MOVE,
                    { targetUnit },
                    false,
                    rampPoint,
                    nil)
                scoAeonFactoryHostOrderManager.HostIssueOrder(
                    scoAeonFactoryOrderTasks.MOVE,
                    { targetUnit },
                    true,
                    clearancePoint,
                    nil)
                queuedRoute = true
            end
        end

        local source = self.unitBeingBuiltSource or self
        if source.rallyPoint then
            scoAeonFactoryHostOrderManager.HostIssueOrder(
                scoAeonFactoryOrderTasks.MOVE,
                { targetUnit },
                queuedRoute,
                source.rallyPoint,
                nil)
        end
        scoAeonFactoryForgetRamp(self, targetUnit)
    end

    factoryClass.ProductionBehaviorStop = function(self)
        local targetUnit = self.productionBehaviorTargetUnit
        self:StopAeonFactoryBuildTargetWatchThread()
        self:StopAeonFactoryBuildColliderPin(targetUnit)
        scoAeonFactoryForgetRamp(self, targetUnit)
        baseClass.ProductionBehaviorStop(self)
    end

    factoryClass.OnCancelConstruction = function(self)
        self:StopAeonFactoryBuildTargetWatchThread()
        self:StopAeonFactoryBuildColliderPin()
        self.scoAeonFactoryRollOffRampIndexes = nil
        self.scoAeonFactoryNextRollOffRampIndex = nil
        baseClass.OnCancelConstruction(self)
    end

    factoryClass.OnDestroy = function(self, isDelete)
        self:StopAeonFactoryBuildTargetWatchThread()
        self:StopAeonFactoryBuildColliderPin()
        self.scoAeonFactoryRollOffRampIndexes = nil
        self.scoAeonFactoryNextRollOffRampIndex = nil
        baseClass.OnDestroy(self, isDelete)
    end
end

scoAdaptAeonFactoryClass(
    AeonPortLandFactory,
    ChosenLandFactory)
scoAdaptAeonFactoryClass(
    AeonPortAirFactory,
    ChosenAirFactory)
scoAdaptAeonFactoryClass(
    AeonPortNavalFactory,
    ChosenNavalFactory)

local scoCzarProcessAreaDamage =
    Import("host/collisionUpdate.lua").ProcessAreaDamage
local scoCzarOrderTasks =
    Import("common/commonOrders.lua").OrderTasks
local scoCzarTargetingLayers =
    Import("common/layers.lua").TargetingLayer
local scoCzarHostOrderManager =
    Import("host/managers/orders/hostOrderManager.lua")
local scoCzarOverheadRange = 0.3

local function scoCzarIsAlive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
end

local function scoCzarWorldPoint(factory, x, y, z)
    local rotated = Engine.QuaternionRotateVector(
        factory:GetOrientation(),
        EngineClasses.float3(x, y, z))
    local origin = factory:GetPosition()
    return EngineClasses.float3(
        origin.x + rotated.x,
        origin.y + rotated.y,
        origin.z + rotated.z)
end

local function scoCzarIsDirectLandAttack(czar, targetUnit)
    local orders = czar.orders
    local activeOrder = orders and orders.activeOrder
    return targetUnit ~= nil
        and targetUnit.targetingLayer
            == scoCzarTargetingLayers.Land
        and activeOrder ~= nil
        and activeOrder.orderTask
            == scoCzarOrderTasks.ATTACKUNIT
end

-- Retain stock Factory ownership of queue/production state, then
-- delegate only the mobile lifecycle exactly as the existing
-- Sanctuary mobile-factory composition does.
HostAeonPortCzar = Class("AeonPortCzar", ChosenAirFactory)
local AeonPortCzar = HostAeonPortCzar

function AeonPortCzar:__init(id, army, template, fractionCompleted, builder)
    ChosenAirFactory.__init(
        self,
        id,
        army,
        template,
        fractionCompleted,
        builder)

    self.scoCzarCenterMuzzle = self:GetBoneId(
        "Center_Muzzle")
    if not self.scoCzarCenterMuzzle
        or not Engine.IsValidGlobalID(self.scoCzarCenterMuzzle)
    then
        error("Czar requires exact Center_Muzzle; no Root fallback is allowed.")
    end

    local weapon = self:GetWeapon(1)
    local muzzle = weapon and weapon.muzzles and weapon.muzzles[1]
    local beam = muzzle and muzzle.beam
    if not weapon
        or not weapon.isBeamWeapon
        or #weapon.aimControllerIds ~= 0
        or not beam
    then
        error("Czar primary Center_Muzzle beam was not created.")
    end

    -- The shared source-continuous weapon owns alignment, beam enable state,
    -- collision pulses and damage. Do not replace it with a terrain-damage loop.
    self.scoCzarBeam = beam
    self.scoCzarGroundAttackFollow = false
    self.scoCzarMovementLocked = false
end

function AeonPortCzar:CanBeSlaveFactory()
    return false
end

function AeonPortCzar:CanBeMasterFactory()
    return false
end

function AeonPortCzar:PromoteToUnit()
    ChosenAirUnit.PromoteToUnit(self)
end

function AeonPortCzar:AttackBehaviorStart(targetUnit, range)
    if not self:AttackBehaviorIsValidFor(targetUnit, range) then
        return
    end
    if self.attackBehaviorIsActive then
        self:AttackBehaviorStop()
    end

    local followGroundTarget =
        scoCzarIsDirectLandAttack(self, targetUnit)
    self:SetCzarGroundAttackFollow(followGroundTarget)
    ChosenAirFactory.AttackBehaviorStart(
        self,
        targetUnit,
        followGroundTarget and scoCzarOverheadRange or range)
    self:RefreshCzarMovementEnabled()
end

function AeonPortCzar:AttackBehaviorStop()
    ChosenAirFactory.AttackBehaviorStop(self)
    self:SetCzarGroundAttackFollow(false)
end

function AeonPortCzar:FollowBehaviorThread()
    if not self.scoCzarGroundAttackFollow then
        ChosenAirFactory.FollowBehaviorThread(self)
        return
    end

    while self.scoCzarGroundAttackFollow
        and self:FollowBehaviorIsValidFor(
            self.followBehaviorTargetUnit,
            self.followBehaviorRange)
        and self.attackBehaviorTargetUnit
            == self.followBehaviorTargetUnit
    do
        local targetPosition =
            self:FollowBehaviorGetTargetPosition()
        local currentPosition = self:GetPosition()
        local offsetX = targetPosition.x - currentPosition.x
        local offsetZ = targetPosition.y - currentPosition.z
        local distance = math.sqrt(
            offsetX * offsetX + offsetZ * offsetZ)
        if distance > 0 then
            local maxStep =
                self.tp.movement.speed
                * Constants.TickTimeStep
            local step = math.min(distance, maxStep)
            currentPosition.x = currentPosition.x
                + offsetX / distance * step
            currentPosition.z = currentPosition.z
                + offsetZ / distance * step
            self:SetPosition(currentPosition)
        end
        WaitTicks(1)
    end

    self:FollowBehaviorStop()
end

function AeonPortCzar:OnStopBeingBuilt()
    ChosenAirFactory.OnStopBeingBuilt(self)
    Engine.SetNavmapModifierEnabled(self.id, false)
    Engine.SetGlobalGridModifierEnabled(self.id, false)
    self.scoCzarGroundAttackFollow = false
    self.scoCzarMovementLocked = false
    self:RefreshCzarMovementEnabled()
end

function AeonPortCzar:RefreshCzarMovementEnabled()
    -- Sanctuary's native movement separation is two-dimensional:
    -- altitude does not keep this radius-10 Czar capsule from
    -- shoving a land target. Direct land attacks therefore use
    -- the bounded host movement above while all hit/selection
    -- colliders remain enabled.
    Engine.SetMovementEnabled(
        self.id,
        not self.scoCzarMovementLocked
            and not self.scoCzarGroundAttackFollow)
end

function AeonPortCzar:SetCzarGroundAttackFollow(enabled)
    self.scoCzarGroundAttackFollow = enabled
    self:RefreshCzarMovementEnabled()
end

function AeonPortCzar:SetCzarMovementLocked(locked)
    self.scoCzarMovementLocked = locked
    self:RefreshCzarMovementEnabled()
end

function AeonPortCzar:StopCzarBuildColliderPin(targetUnit)
    if targetUnit ~= nil
        and self.scoCzarPinnedBuildTarget ~= targetUnit
    then
        return
    end
    local pinnedTarget = self.scoCzarPinnedBuildTarget
    self.scoCzarPinnedBuildTarget = nil
    if self.scoCzarBuildColliderPinThread ~= nil then
        KillThread(self.scoCzarBuildColliderPinThread)
        self.scoCzarBuildColliderPinThread = nil
    end
    if pinnedTarget
        and pinnedTarget.scoFactoryColliderPinOwner == self
    then
        pinnedTarget.scoFactoryColliderPinOwner = nil
    end
end

function AeonPortCzar:PinCzarBuildCollider(targetUnit)
    self:StopCzarBuildColliderPin()
    if not scoCzarIsAlive(targetUnit)
        or targetUnit:IsCompleted()
    then
        return
    end
    self.scoCzarPinnedBuildTarget = targetUnit
    targetUnit.scoFactoryColliderPinOwner = self
    local buildPosition = scoCzarWorldPoint(self, 0, 0, 0)
    targetUnit:SetOrientation(self:GetOrientation())
    targetUnit:SetPosition(buildPosition)
    Engine.SetVolumeColliderEnabled(targetUnit.id, false)
    self.scoCzarBuildColliderPinThread = self:NewThread(
        self.CzarBuildColliderPinThread,
        targetUnit)
end

function AeonPortCzar:CzarBuildColliderPinThread(targetUnit)
    while self.scoCzarPinnedBuildTarget == targetUnit
        and scoCzarIsAlive(self)
        and scoCzarIsAlive(targetUnit)
        and not targetUnit:IsCompleted()
    do
        targetUnit:SetOrientation(self:GetOrientation())
        targetUnit:SetPosition(scoCzarWorldPoint(self, 0, 0, 0))
        WaitTicks(1)
    end
    self.scoCzarBuildColliderPinThread = nil
end

function AeonPortCzar:ReleaseCzarBuiltUnit(targetUnit)
    if not scoCzarIsAlive(targetUnit)
        or not targetUnit:IsCompleted()
    then
        return false
    end
    local releasePosition = scoCzarWorldPoint(
        self,
        0,
        0,
        -20)
    targetUnit:SetOrientation(self:GetOrientation())
    targetUnit:SetPosition(releasePosition)
    self:StopCzarBuildColliderPin(targetUnit)
    if scoCzarIsAlive(targetUnit) then
        Engine.SetVolumeColliderEnabled(targetUnit.id, true)
    end
    return true
end

function AeonPortCzar:RotatorsEnabledOnConstruction()
    return true
end

function AeonPortCzar:GetConstructionSpawnPoint()
    return scoCzarWorldPoint(self, 0, 0, 0)
end

function AeonPortCzar:OnStartBuildRoutine(targetUnit)
    self:StopCzarBuildTargetWatchThread()
    if scoCzarIsAlive(targetUnit) then
        self:PinCzarBuildCollider(targetUnit)
    end
    self:SetCzarMovementLocked(true)
    ChosenAirFactory.OnStartBuildRoutine(self, targetUnit)
    if scoCzarIsAlive(targetUnit)
        and not targetUnit:IsCompleted()
    then
        Engine.SetVolumeColliderEnabled(targetUnit.id, false)
    end
end

function AeonPortCzar:OnStopBuildRoutine(targetUnit)
    local completed = scoCzarIsAlive(targetUnit)
        and targetUnit:IsCompleted()
    if completed then
        -- Move clear before the base callback restores the paired
        -- client collider.
        self:ReleaseCzarBuiltUnit(targetUnit)
    elseif scoCzarIsAlive(targetUnit) then
        Engine.SetVolumeColliderEnabled(targetUnit.id, false)
    end
    ChosenAirFactory.OnStopBuildRoutine(self, targetUnit)
    if not completed and scoCzarIsAlive(targetUnit) then
        Engine.SetVolumeColliderEnabled(targetUnit.id, false)
    end
end

function AeonPortCzar:StopCzarBuildTargetWatchThread()
    local thread = self.scoCzarBuildTargetWatchThread
    self.scoCzarBuildTargetWatchThread = nil
    if thread ~= nil then
        KillThread(thread)
    end
end

function AeonPortCzar:ScoCzarBuildTargetWatchThread()
    while not self.dead and self.productionBehaviorIsActive do
        local targetUnit = self.productionBehaviorTargetUnit
        if scoCzarIsAlive(targetUnit)
            and not targetUnit:IsCompleted()
        then
            self:PinCzarBuildCollider(targetUnit)
            self.scoCzarBuildTargetWatchThread = nil
            return
        end
        WaitTicks(1)
    end
    self.scoCzarBuildTargetWatchThread = nil
end

function AeonPortCzar:ProductionBehaviorBuildOne(item)
    self:SetCzarMovementLocked(true)
    self:StopCzarBuildTargetWatchThread()
    self.scoCzarBuildTargetWatchThread =
        self:NewThread(self.ScoCzarBuildTargetWatchThread)
    ChosenAirFactory.ProductionBehaviorBuildOne(self, item)
    self:StopCzarBuildTargetWatchThread()
    self:SetCzarMovementLocked(false)
end

function AeonPortCzar:RollOffUnit(targetUnit)
    if not scoCzarIsAlive(targetUnit) then
        self:SetCzarMovementLocked(false)
        return
    end
    self:ReleaseCzarBuiltUnit(targetUnit)
    local rollOffPoint = self.rallyPoint
    if not rollOffPoint then
        rollOffPoint = scoCzarWorldPoint(
            self,
            0,
            0,
            -40)
    end

    scoCzarHostOrderManager.HostIssueOrder(
        scoCzarOrderTasks.MOVE,
        { targetUnit },
        false,
        rollOffPoint,
        nil)
    self:SetCzarMovementLocked(false)
end

function AeonPortCzar:ProductionBehaviorStop()
    local targetUnit = self.productionBehaviorTargetUnit
    self:StopCzarBuildTargetWatchThread()
    self:StopCzarBuildColliderPin(targetUnit)
    ChosenAirFactory.ProductionBehaviorStop(self)
    self:SetCzarMovementLocked(false)
    if not self.dead and self:IsCompleted() then
        -- Stock factories disable all rotators when production
        -- ends; the combat Czar must keep its weapon rotators live.
        self:SetRotatorsEnabled(true)
    end
end

function AeonPortCzar:OnCancelConstruction()
    self:StopCzarBuildTargetWatchThread()
    self:StopCzarBuildColliderPin()
    ChosenAirFactory.OnCancelConstruction(self)
    self:SetCzarMovementLocked(false)
end

function AeonPortCzar:OnDestroy(isDelete)
    self:StopCzarBuildTargetWatchThread()
    self:StopCzarBuildColliderPin()
    self:SetCzarMovementLocked(false)
    if self.scoCzarBeam then
        self.scoCzarBeam:SetBeamEnabled(false, true)
    end
    ChosenAirFactory.OnDestroy(self, isDelete)
end

-- Append to host/units/unitsClasses/unitsDefaultChosen.lua.
local SCOFaT3Shield = Import("host/shield.lua")
local SCOFaT3ChosenSetUpShields = HostAeonPortLandUnit.SetUpShields
local SCOFaT3ChosenCheckShieldState = HostAeonPortLandUnit.CheckShieldState

function HostAeonPortLandUnit:SetUpShields()
    SCOFaT3ChosenSetUpShields(self)
    if self.tpId == "ucl3001" then SCOFaT3Shield.SCOFaT3InstallShield(self) end
end

function HostAeonPortLandUnit:CheckShieldState(skipRecharge)
    if self.tpId == "ucl3001" then
        return SCOFaT3Shield.SCOFaT3CheckShieldState(self, skipRecharge)
    end
    return SCOFaT3ChosenCheckShieldState(self, skipRecharge)
end

-- FA UAA0310 always remains in its airborne destruction path until
-- perimeter/terrain contact. Sanctuary normally explodes DeathExplosion
-- weapons in OnDestroy and then drops a wreck, so defer only this Czar's
-- authored damage and own its host-authoritative edge-first fall.
local function scoCzarCrashContract(czar)
    local additions = czar.tp and czar.tp.additions
    local contract = additions and additions.scoFaCzarCrash
    if contract == nil
        or contract.version ~= "1.0.0"
        or contract.sourceUnitId ~= "UAA0310"
        or contract.sourceScriptSha256
            ~= "af2458bd797acffbe8c28ca9d683a020d17aa9a7e0ed6df3780e58274e82e3f2"
        or contract.sourceDefaultAirUnitSha256
            ~= "fce73da5a37ca4b68ef9e4c317316189e9196d172f9f4d172df3cc825d079447"
        or contract.sourceDestroyNoFallRandomChance ~= 1.1
        or contract.impactDamage ~= 15000
        or contract.impactRadius ~= 15
        or contract.impactDamageFriendly ~= true
        or contract.perimeterDamage ~= 1000
        or contract.perimeterRadius ~= 5
        or contract.perimeterDamageFriendly ~= true
        or type(contract.sourceWatchedBones) ~= "table"
        or #contract.sourceWatchedBones ~= 8
        or contract.sourceWaterImpactAppliesDamage ~= true
        or contract.runtimeMode ~= "HostWreckEdgeFirstFall"
        or contract.runtimeSideSelection ~= "EntityIndexParity"
        or contract.runtimePerimeterContactMode ~= "SingleLeadingEdgePulse"
        or contract.runtimeImpactDebounce ~= "ExactlyOnce"
        or contract.runtimeTiltDegrees ~= 32
        or contract.runtimeTiltRateDegrees ~= 16
        or contract.runtimeLeadingEdgeOffset ~= 13.45
        or contract.runtimeLevelClearance ~= 2.8341667652130127
        or contract.runtimeFallAcceleration ~= 10
        or contract.runtimeMaximumFallSeconds ~= 30
    then
        error("Malformed SCOM FA Czar crash contract")
    end

    local expectedWatchedBones = {
        "Left_Turret01_Muzzle",
        "Right_Turret01_Muzzle",
        "Left_Turret02_WepFocus",
        "Right_Turret02_WepFocus",
        "Left_Turret03_Muzzle",
        "Right_Turret03_Muzzle",
        "Attachpoint01",
        "Attachpoint02",
    }
    for index, boneName in ipairs(expectedWatchedBones) do
        if contract.sourceWatchedBones[index] ~= boneName then
            error("Czar perimeter-contact bone contract drifted")
        end
    end

    local deathImpact = nil
    for _, weapon in ipairs(czar.tp.weapons or {}) do
        if weapon.category == "DeathExplosion" then
            if deathImpact ~= nil then
                error("Czar owns more than one DeathExplosion weapon")
            end
            deathImpact = weapon
        end
    end
    if deathImpact == nil
        or deathImpact.damage ~= contract.impactDamage
        or deathImpact.damageRadius ~= contract.impactRadius
        or deathImpact.damageFriendly ~= true
        or deathImpact.damageType ~= "Normal"
    then
        error("Czar DeathImpact weapon drifted from FA")
    end
    return contract
end

local function scoCzarCrashRotation(yawRadians, rollRadians)
    local up = EngineClasses.float3(0, 1, 0)
    local forward = EngineClasses.float3(0, 0, 1)
    return Engine.QuaternionMultiply(
        Engine.QuaternionAxisAngle(up, yawRadians),
        Engine.QuaternionAxisAngle(forward, rollRadians))
end

local function scoCzarCrashApplyDamage(
    wreck,
    contract,
    army,
    center,
    yawRadians,
    sideSign)
    if wreck.scoFaCzarCrashImpactApplied == true then
        return false
    end
    wreck.scoFaCzarCrashImpactApplied = true

    -- Positive local-forward roll raises the right edge, so the
    -- opposite parity-selected edge is the first perimeter contact.
    local rightX = math.cos(yawRadians)
    local rightZ = -math.sin(yawRadians)
    local edge = EngineClasses.float3(
        center.x - sideSign * rightX
            * contract.runtimeLeadingEdgeOffset,
        center.y,
        center.z - sideSign * rightZ
            * contract.runtimeLeadingEdgeOffset)
    scoCzarProcessAreaDamage(
        edge,
        contract.perimeterRadius,
        contract.perimeterDamage,
        army,
        contract.perimeterDamageFriendly)
    scoCzarProcessAreaDamage(
        center,
        contract.impactRadius,
        contract.impactDamage,
        army,
        contract.impactDamageFriendly)
    return true
end

local function scoCzarCrashSurface(position, hasWater, waterLevel)
    local _, terrainHeight = Engine.SampleTerrainHeight(position)
    if type(terrainHeight) ~= "number" then
        error("Czar crash terrain height is unavailable")
    end
    if hasWater and terrainHeight < waterLevel then
        return waterLevel, true
    end
    return terrainHeight, false
end

local function scoCzarCrashWreckThread(
    wreck,
    position,
    velocity,
    yawRadians,
    sideSign,
    deleteWreckAtRest,
    contract,
    army)
    local dt = Constants.TickTimeStep
    local targetRoll = math.rad(contract.runtimeTiltDegrees) * sideSign
    local rollRadians = math.rad(6) * sideSign
    local rollRate = math.rad(contract.runtimeTiltRateDegrees)
    local elapsed = 0
    local _, hasWater = Engine.HasWater()
    local waterLevel = 0
    if hasWater then
        _, waterLevel = Engine.GetWaterLevel()
        if type(waterLevel) ~= "number" then
            error("Czar crash water level is unavailable")
        end
    end

    Engine.SetRayColliderEnabled(wreck.id, false)
    Engine.SetGlobalEntityLocalRotation(
        wreck.id,
        scoCzarCrashRotation(yawRadians, rollRadians))

    while true do
        WaitTicks(1)
        if wreck.deleted then
            return
        end

        elapsed = elapsed + dt
        velocity.y = velocity.y
            - contract.runtimeFallAcceleration * dt

        local nextRollMagnitude = math.min(
            math.abs(targetRoll),
            math.abs(rollRadians) + rollRate * dt)
        rollRadians = nextRollMagnitude * sideSign

        position.x = position.x + velocity.x * dt
        position.y = position.y + velocity.y * dt
        position.z = position.z + velocity.z * dt

        local surfaceHeight, overWater =
            scoCzarCrashSurface(position, hasWater, waterLevel)
        -- The pinned Czar mesh spans local Y -2.8341667652130127 to
        -- 3.0966575145721436. Its local hull midpoint follows the roll;
        -- placing it on the surface buries about half the rendered hull.
        local hullMidpoint = 0.13124537467956543 * math.cos(rollRadians)
        local contactHeight = surfaceHeight - hullMidpoint
        local contacted = position.y <= contactHeight

        local rotation = scoCzarCrashRotation(
            yawRadians,
            rollRadians)
        if contacted then
            position.y = contactHeight
            Engine.SetGlobalEntityPosition(wreck.id, position)
            Engine.SetGlobalEntityLocalRotation(wreck.id, rotation)
            local impactCenter = EngineClasses.float3(
                position.x,
                surfaceHeight,
                position.z)
            local impactApplied = scoCzarCrashApplyDamage(
                wreck,
                contract,
                army,
                impactCenter,
                yawRadians,
                sideSign)
            -- SCO_CzarCrashScorchContact_v1: the falling wreck owns impact.
            if impactApplied and not overWater then
                Import("common/loading/unitTemplateLoader.lua").SCOMTreeKnockdown.Impact(
                    impactCenter, contract.impactRadius)
                SendToAllClients(
                    {
                        position = {
                            x = impactCenter.x,
                            y = impactCenter.y,
                            z = impactCenter.z,
                        },
                    },
                    "SCOCzarCrashImpactScorch")
            end
            if deleteWreckAtRest then
                wreck.scoWaterWreckSettling = false
                wreck:Delete()
            elseif overWater then
                Import("host/props/wreckCrash.lua").SinkAircraftWreck(
                    wreck, position, velocity, yawRadians, rollRadians, deleteWreckAtRest)
            else
                wreck.scoWaterWreckSettling = false
            end
            return
        end

        Engine.SetGlobalEntityPosition(wreck.id, position)
        Engine.SetGlobalEntityLocalRotation(wreck.id, rotation)
    end
end

local scoCzarStockOnStopBeingBuilt = AeonPortCzar.OnStopBeingBuilt
function AeonPortCzar:OnStopBeingBuilt()
    scoCzarStockOnStopBeingBuilt(self)
    self.isAirborne = true
    ChosenAirUnit.SetAirborneLayers(self)
end

function AeonPortCzar:CreateDeathExplosions()
    if not self:IsCompleted() then
        return ChosenAirFactory.CreateDeathExplosions(self)
    end
    -- Validate now, but apply at terrain/water contact below.
    scoCzarCrashContract(self)
end

local function scoCzarCrashThread(czar, overkillRatio)
    if not czar:IsCompleted() then
        return ChosenAirFactory.DeathThread(czar, overkillRatio)
    end

    local contract = scoCzarCrashContract(czar)
    local dt = Constants.TickTimeStep
    local _, speedPerTick = Engine.GetMovementCurrentSpeed(czar.id)
    local _, headingDegrees = Engine.GetMovementHeadingDegrees(czar.id)
    local headingRadians = math.rad(headingDegrees)
    local speed = speedPerTick / dt
    local velocity = EngineClasses.float3(
        math.sin(headingRadians) * speed,
        0,
        math.cos(headingRadians) * speed)
    if czar.scoAircraftCrashVelocity then
        local sourceVelocity = czar.scoAircraftCrashVelocity
        velocity = EngineClasses.float3(
            sourceVelocity.x, sourceVelocity.y, sourceVelocity.z)
    end
    local _, position = Engine.GetGlobalEntityWorldPosition(czar.id)
    local sideSign = (czar.id.index % 2 == 0) and 1 or -1
    local deleteWreckAtRest = (overkillRatio or 0) >= 1
        or not czar.spawnsWreck
        or czar:GetFractionComplete() < 0.5
    local army = czar.army
    local wreckage = CreateWreckageFromUnit(czar)
    if wreckage == nil then
        -- Asset creation failures must not strand a dead unit. This
        -- fallback retains exact damage, while the verifier requires
        -- the normal falling wreck route to be constructible.
        local surfaceHeight = scoCzarCrashSurface(position, false, 0)
        local impact = EngineClasses.float3(
            position.x,
            surfaceHeight,
            position.z)
        scoCzarCrashApplyDamage(
            {}, contract, army, impact, headingRadians, sideSign)
        czar:Delete()
        return
    end

    wreckage.scoWaterWreckSettling = true
    wreckage:NewThread(function()
        scoCzarCrashWreckThread(
            wreckage,
            position,
            velocity,
            headingRadians,
            sideSign,
            deleteWreckAtRest,
            contract,
            army)
    end)
    czar:Delete()
end

function AeonPortCzar:CrashThread(overkillRatio)
    return scoCzarCrashThread(self, overkillRatio)
end

function AeonPortCzar:DeathThread(overkillRatio)
    return scoCzarCrashThread(self, overkillRatio)
end

-- SCO_AeonEngineerBuildAnimation 1.0.0
-- FA drives the same source clip forward while building and backward
-- when construction stops. Exact-time sampling preserves continuity
-- when an engineer changes state before either transition completes.
local SCO_AeonEngineerBuildSentinelBase = -10000

local function SCO_AeonEngineerBuildAlive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
end

local function SCO_AeonEngineerBuildConfig(unit)
    local additions = unit.tp and unit.tp.additions
    local config = additions and additions.aeonEngineerBuildAnimation
    if not config then
        return nil
    end

    local animations = unit.tp.visuals and unit.tp.visuals.animations
    local animation = animations and animations[config.animationKey]
    if type(config.durationSeconds) ~= "number"
        or config.durationSeconds <= 0
        or type(config.authoredRate) ~= "number"
        or config.authoredRate <= 0
        or not animation
        or animation.id == nil
    then
        error(unit.tpId .. " has an invalid Aeon engineer build-animation contract")
    end
    return config, animation
end

local function SCO_AeonEngineerBuildSample(unit, animation, seconds)
    Engine.PlayAnimation(
        unit.id,
        animation.id,
        SCO_AeonEngineerBuildSentinelBase + seconds)
end

local function SCO_AeonEngineerBuildPlayRest(unit, config)
    local animations = unit.tp.visuals and unit.tp.visuals.animations
    local rest = animations and animations[config.restAnimationKey]
    if not rest or rest.id == nil then
        error(unit.tpId .. " has no Aeon engineer rest animation")
    end
    Engine.PlayAnimation(unit.id, rest.id, 0.1)
end

local function SCO_AeonEngineerBuildTransitionThread(
    unit,
    generation,
    opening)
    local config, animation = SCO_AeonEngineerBuildConfig(unit)
    if not config then
        return
    end

    local duration = config.durationSeconds
    local sample = math.max(
        0,
        math.min(duration, unit.scoAeonEngineerBuildSample or 0))
    while SCO_AeonEngineerBuildAlive(unit)
        and unit.scoAeonEngineerBuildGeneration == generation
        and ((opening and sample < duration)
            or (not opening and sample > 0))
    do
        SCO_AeonEngineerBuildSample(unit, animation, sample)
        unit.scoAeonEngineerBuildSample = sample
        WaitTicks(1)
        local delta = Constants.TickTimeStep * config.authoredRate
        if opening then
            sample = math.min(duration, sample + delta)
        else
            sample = math.max(0, sample - delta)
        end
    end

    if not SCO_AeonEngineerBuildAlive(unit)
        or unit.scoAeonEngineerBuildGeneration ~= generation
    then
        return
    end

    unit.scoAeonEngineerBuildSample = sample
    if opening then
        SCO_AeonEngineerBuildSample(unit, animation, sample)
    else
        SCO_AeonEngineerBuildPlayRest(unit, config)
    end
end

function AeonPortEngineer:SCO_SetBuildAnimationState(opening)
    local additions = self.tp and self.tp.additions
    if not additions or not additions.aeonEngineerBuildAnimation then
        return
    end
    self.scoAeonEngineerBuildGeneration =
        (self.scoAeonEngineerBuildGeneration or 0) + 1
    self:NewThread(
        SCO_AeonEngineerBuildTransitionThread,
        self.scoAeonEngineerBuildGeneration,
        opening)
end

function AeonPortEngineer:OnStopBeingBuilt()
    local result = ChosenEngineer.OnStopBeingBuilt(self)
    local additions = self.tp and self.tp.additions
    if additions and additions.aeonEngineerBuildAnimation then
        self.scoAeonEngineerBuildGeneration =
            (self.scoAeonEngineerBuildGeneration or 0) + 1
        self.scoAeonEngineerBuildSample = 0
    end
    return result
end

function AeonPortEngineer:OnStartBuildRoutine(targetUnit)
    local result = ChosenEngineer.OnStartBuildRoutine(self, targetUnit)
    self:SCO_SetBuildAnimationState(true)
    return result
end

function AeonPortEngineer:OnStopBuildRoutine(targetUnit)
    local result = ChosenEngineer.OnStopBuildRoutine(self, targetUnit)
    self:SCO_SetBuildAnimationState(false)
    return result
end

function AeonPortEngineer:OnDestroy(isDelete)
    self.scoAeonEngineerBuildGeneration =
        (self.scoAeonEngineerBuildGeneration or 0) + 1
    return ChosenEngineer.OnDestroy(self, isDelete)
end


-- Supreme Commander Overhaul FA animation closure 1.0.1
local SCO_AnimationClosureSentinelBase = -10000

local function SCO_AnimationClosureAlive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
end

local function SCO_AnimationClosureSample(unit, key, seconds)
    local animations = unit.tp.visuals and unit.tp.visuals.animations
    local animation = animations and animations[key]
    if not animation or not animation.id then
        error(unit.tpId .. " requires source animation " .. tostring(key))
    end
    Engine.PlayAnimation(
        unit.id,
        animation.id,
        SCO_AnimationClosureSentinelBase + seconds)
end

local function SCO_AnimationClosureConstructionOpenThread(unit, generation)
    local deploy = unit.tp.additions.faAnimationClosureWeaponDeploy
    local config = deploy and deploy.constructionOpen
    if not config then return end
    local elapsed = 0
    while SCO_AnimationClosureAlive(unit)
        and unit.scoFaConstructionOpenGeneration == generation
        and elapsed < config.authoredDurationSeconds
    do
        SCO_AnimationClosureSample(unit, config.animationKey, elapsed)
        WaitTicks(1)
        elapsed = math.min(
            config.authoredDurationSeconds,
            elapsed + Constants.TickTimeStep * config.authoredRate)
    end
    if SCO_AnimationClosureAlive(unit)
        and unit.scoFaConstructionOpenGeneration == generation
    then
        SCO_AnimationClosureSample(
            unit,
            config.animationKey,
            config.authoredDurationSeconds)
        unit.scoFaAnimationConstructionReady = true
    end
end

function AeonPortStructure:OnStopBeingBuilt()
    ChosenStructure.OnStopBeingBuilt(self)
    local deploy = self.tp.additions
        and self.tp.additions.faAnimationClosureWeaponDeploy
    if not deploy or not deploy.constructionOpen then return end
    self.scoFaAnimationConstructionReady = false
    self.scoFaConstructionOpenGeneration =
        (self.scoFaConstructionOpenGeneration or 0) + 1
    self:NewThread(
        SCO_AnimationClosureConstructionOpenThread,
        self.scoFaConstructionOpenGeneration)
end

-- Supreme Commander Overhaul factory staging hook 1.0.2
-- Supreme Commander Overhaul Aeon Structure Motion Closure 1.0.0
-- Body only. CachePatcherRuntime prepends the authoritative version marker.
local SCO_ASM_SENTINEL = -10000
local SCO_ASM_LOOP_SENTINEL = -20000

local function SCO_ASM_Contract(unit)
    local additions = unit.tp and unit.tp.additions
    return additions and additions.aeonStructureMotion
end

local function SCO_ASM_Alive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
end

local function SCO_ASM_Animation(unit, key)
    local animations = unit.tp
        and unit.tp.visuals
        and unit.tp.visuals.animations
    local animation = animations and animations[key]
    if not animation or not animation.id then
        error(unit.tpId .. " requires Aeon structure-motion clip " .. tostring(key))
    end
    return animation
end

local function SCO_ASM_Sample(unit, key, seconds)
    local animation = SCO_ASM_Animation(unit, key)
    Engine.PlayAnimation(unit.id, animation.id, SCO_ASM_SENTINEL + seconds)
end

local function SCO_ASM_PlayClamp(unit, key)
    local animation = SCO_ASM_Animation(unit, key)
    Engine.PlayAnimation(unit.id, animation.id, 0.1)
end

local function SCO_ASM_SamplePump(unit, key, elapsed)
    local animation = SCO_ASM_Animation(unit, key)
    -- Rendering interpolates these clocks before applying Loop. Never wrap the
    -- transmitted clock; the negative encoding also avoids the legacy 1000s limit.
    Engine.PlayAnimation(unit.id, animation.id, SCO_ASM_LOOP_SENTINEL - elapsed)
end

local function SCO_ASM_SetRotator(unit, index, x, y, z)
    local rotatorId = unit.rotatorIds and unit.rotatorIds[index]
    if not rotatorId then
        error(unit.tpId .. " lost required Aeon structure-motion rotator " .. index)
    end
    Engine.SetRotatorSpeed(rotatorId, EngineClasses.float3(x, y, z))
end

local function SCO_ASM_ZeroRotators(unit)
    local contract = SCO_ASM_Contract(unit)
    for index = 1, (contract and contract.rotatorCount or 0) do
        SCO_ASM_SetRotator(unit, index, 0, 0, 0)
    end
    if contract and contract.rotatorCount > 0 then
        unit:SetRotatorsEnabled(false)
    end
    unit.scoAsmRotatorsStopped = true
end

local function SCO_ASM_EnableRotators(unit)
    local contract = SCO_ASM_Contract(unit)
    if contract and contract.rotatorCount > 0 then
        unit:SetRotatorsEnabled(true)
        unit.scoAsmRotatorsStopped = false
    end
end

local function SCO_ASM_UnitIndex(unit)
    return (unit.id and unit.id.index) or 0
end

local function SCO_ASM_Bounded(unit, salt, minimum, maximum)
    local span = maximum - minimum + 1
    return minimum + ((SCO_ASM_UnitIndex(unit) * 37 + salt * 53) % span)
end

local function SCO_ASM_SourceSign(unit, salt)
    -- Source GetRandomDir returns +1 only for Random(0, 2) > 1.
    return ((SCO_ASM_UnitIndex(unit) + salt) % 3 == 2) and 1 or -1
end

local function SCO_ASM_Cleanup(unit)
    unit.scoAsmGeneration = (unit.scoAsmGeneration or 0) + 1
    if unit.scoAsmThread then
        KillThread(unit.scoAsmThread)
        unit.scoAsmThread = nil
    end
    if unit.scoAsmDomeThread then
        KillThread(unit.scoAsmDomeThread)
        unit.scoAsmDomeThread = nil
    end
    unit.scoAsmDomeQueue = 0
    unit.scoAsmShieldEnabled = false
    unit.scoAsmShieldPodSpeed = 0
    unit.scoAsmShieldOrbPrimarySpeed = 0
    unit.scoAsmShieldOrbZSpeed = 0
    unit.scoAsmIntelEnabled = nil
    unit.scoAsmStorageRatio = nil
    unit.scoAsmRotatorSpeeds = nil
    unit.scoAsmRotatorsStopped = nil
    unit.scoAsmFabricatorProductionEnabled = nil
    SCO_ASM_ZeroRotators(unit)
end

local function SCO_ASM_StartThread(unit, worker)
    unit.scoAsmGeneration = (unit.scoAsmGeneration or 0) + 1
    if unit.scoAsmThread then
        KillThread(unit.scoAsmThread)
    end
    local generation = unit.scoAsmGeneration
    unit.scoAsmThread = unit:NewThread(worker, generation)
end

local function SCO_ASM_Approach(value, target, delta)
    if value < target then
        return math.min(target, value + delta)
    end
    if value > target then
        return math.max(target, value - delta)
    end
    return value
end

local function SCO_ASM_AdvanceLoopSample(sample, clip)
    sample = sample + Constants.TickTimeStep * clip.rate
    while sample >= clip.durationSeconds do
        sample = sample - clip.durationSeconds
    end
    return sample
end

local function SCO_ASM_IsManagedRotatorKind(kind)
    return kind == "rotating_power_death"
        or kind == "fabricator_rotators"
        or kind == "paragon_rotor_death"
        or kind == "intel_rotor_upgrade"
        or kind == "intel_rotor_triple"
        or kind == "intel_rotor_pair_upgrade"
end

local function SCO_ASM_RotatorGoals(unit, contract)
    local goals = {}
    local kind = contract.kind
    if kind == "rotating_power_death" then
        goals[1] = {
            x = SCO_ASM_Bounded(unit, 1, 80, 100),
            y = SCO_ASM_Bounded(unit, 2, 80, 100),
            z = SCO_ASM_Bounded(unit, 3, 80, 100),
        }
    elseif kind == "fabricator_rotators" then
        local cycle = unit.scoAsmFabricatorCycle or 0
        local sign = SCO_ASM_SourceSign(unit, 4 + cycle * 11)
        goals[1] = { x = 45, y = 0, z = 0 }
        goals[2] = { x = -45, y = 0, z = 0 }
        goals[3] = {
            x = 0,
            y = 80 + SCO_ASM_Bounded(unit, 5 + cycle * 11, 0, 20) * sign,
            z = 0,
        }
        goals[4] = {
            x = 80 + SCO_ASM_Bounded(unit, 6 + cycle * 11, 0, 20) * sign,
            y = 80 + SCO_ASM_Bounded(unit, 7 + cycle * 11, 0, 20) * sign,
            z = 80 + SCO_ASM_Bounded(unit, 8 + cycle * 11, 0, 20) * sign,
        }
    elseif kind == "intel_rotor_upgrade" then
        goals[1] = { x = 0, y = 30, z = 0 }
    elseif kind == "intel_rotor_triple" then
        goals[1] = { x = 0, y = 30, z = 0 }
        goals[2] = { x = 0, y = 60, z = 0 }
        goals[3] = { x = 0, y = 120, z = 0 }
    elseif kind == "intel_rotor_pair_upgrade" then
        goals[1] = { x = 0, y = 30, z = 0 }
        goals[2] = { x = 0, y = 60, z = 0 }
    elseif kind == "paragon_rotor_death" then
        local sign = SCO_ASM_SourceSign(unit, 9)
        goals[1] = {
            x = 0,
            y = 80 + SCO_ASM_Bounded(unit, 10, 0, 20) * sign,
            z = 0,
        }
    end
    return goals
end

local function SCO_ASM_RotatorActive(unit, kind)
    if kind == "rotating_power_death" or kind == "paragon_rotor_death" then
        return true
    end
    if kind == "fabricator_rotators" then
        return unit:GetProductionToggle() == true
    end
    return unit.scoAsmIntelEnabled == true
end

local function SCO_ASM_RotatorAcceleration(kind, active)
    if kind == "rotating_power_death"
        or kind == "fabricator_rotators"
        or kind == "paragon_rotor_death"
    then
        return 15
    end
    if kind == "intel_rotor_pair_upgrade" and not active then
        return 60
    end
    return 20
end

local function SCO_ASM_RotatorThread(unit, generation)
    local contract = SCO_ASM_Contract(unit)
    if not contract or not SCO_ASM_IsManagedRotatorKind(contract.kind) then return end
    local speeds = unit.scoAsmRotatorSpeeds or {}
    for index = 1, contract.rotatorCount do
        speeds[index] = speeds[index] or { x = 0, y = 0, z = 0 }
    end
    unit.scoAsmRotatorSpeeds = speeds

    while SCO_ASM_Alive(unit) and unit.scoAsmGeneration == generation do
        local active = SCO_ASM_RotatorActive(unit, contract.kind)
        local goals = SCO_ASM_RotatorGoals(unit, contract)
        local delta = SCO_ASM_RotatorAcceleration(contract.kind, active)
            * Constants.TickTimeStep
        local moving = false
        local speedChanged = false
        for index = 1, contract.rotatorCount do
            local goal = goals[index] or { x = 0, y = 0, z = 0 }
            if not active then goal = { x = 0, y = 0, z = 0 } end
            local speed = speeds[index]
            local oldX, oldY, oldZ = speed.x, speed.y, speed.z
            speed.x = SCO_ASM_Approach(speed.x, goal.x, delta)
            speed.y = SCO_ASM_Approach(speed.y, goal.y, delta)
            speed.z = SCO_ASM_Approach(speed.z, goal.z, delta)
            if speed.x ~= oldX or speed.y ~= oldY or speed.z ~= oldZ then
                speedChanged = true
            end
            if speed.x ~= 0 or speed.y ~= 0 or speed.z ~= 0
                or goal.x ~= 0 or goal.y ~= 0 or goal.z ~= 0
            then
                moving = true
            end
        end

        if moving then
            local wasStopped = unit.scoAsmRotatorsStopped ~= false
            local fabricator = contract.kind == "fabricator_rotators"
            if not fabricator or wasStopped then
                SCO_ASM_EnableRotators(unit)
            end
            if not fabricator or speedChanged or wasStopped then
                for index = 1, contract.rotatorCount do
                    local speed = speeds[index]
                    SCO_ASM_SetRotator(unit, index, speed.x, speed.y, speed.z)
                end
            end
        elseif not unit.scoAsmRotatorsStopped then
            SCO_ASM_ZeroRotators(unit)
        end
        WaitTicks(1)
    end
end

local function SCO_ASM_PumpLoopThread(unit, generation)
    local contract = SCO_ASM_Contract(unit)
    local clip = contract and contract.primaryClip
    if not clip then return end
    local sample = unit.scoAsmSample or 0
    local elapsed = unit.scoAsmPumpElapsed or sample
    while SCO_ASM_Alive(unit) and unit.scoAsmGeneration == generation do
        SCO_ASM_SamplePump(unit, clip.key, elapsed)
        if not unit:GetPause() and not unit.scoAsmUpgradeSuspended then
            sample = SCO_ASM_AdvanceLoopSample(sample, clip)
            elapsed = elapsed + Constants.TickTimeStep * clip.rate
            unit.scoAsmSample = sample
            unit.scoAsmPumpElapsed = elapsed
        end
        WaitTicks(1)
    end
end

local function SCO_ASM_PumpStateThread(unit, generation)
    local contract = SCO_ASM_Contract(unit)
    local clip = contract and contract.primaryClip
    if not clip then return end
    local sample = unit.scoAsmSample or 0
    local elapsed = unit.scoAsmPumpElapsed or sample
    local phase = unit.scoAsmPumpPhase or "forward"
    while SCO_ASM_Alive(unit) and unit.scoAsmGeneration == generation do
        local paused = unit:GetPause() or unit.scoAsmUpgradeSuspended
        if not paused then
            if phase == "stopped" then sample = 0 end
            phase = "forward"
            SCO_ASM_SamplePump(unit, clip.key, elapsed)
            sample = SCO_ASM_AdvanceLoopSample(sample, clip)
            elapsed = elapsed + Constants.TickTimeStep * clip.rate
        elseif phase == "forward" or phase == "finish" then
            phase = "finish"
            SCO_ASM_SamplePump(unit, clip.key, elapsed)
            local step = math.min(Constants.TickTimeStep * clip.rate,
                clip.durationSeconds - sample)
            sample = sample + step
            elapsed = elapsed + step
            if sample >= clip.durationSeconds then
                SCO_ASM_SamplePump(unit, clip.key, elapsed)
                phase = "stopped"
            end
        else
            -- The native compiled job may still advance its local clock. Refresh
            -- the held sample so paused T3 pumps cannot start another cycle.
            SCO_ASM_SamplePump(unit, clip.key, elapsed)
        end
        unit.scoAsmSample = sample
        unit.scoAsmPumpElapsed = elapsed
        unit.scoAsmPumpPhase = phase
        WaitTicks(1)
    end
end

local function SCO_ASM_AlternatingThread(unit, generation)
    local contract = SCO_ASM_Contract(unit)
    local clip = contract and contract.primaryClip
    if not clip then return end
    local sample = unit.scoAsmSample or 0
    local speed = unit.scoAsmRotorSpeed or 0
    local cycle = unit.scoAsmRotorCycle or 0
    local target = unit.scoAsmRotorTarget or 0
    local phase = unit.scoAsmRotorPhase or "accelerate"
    while SCO_ASM_Alive(unit) and unit.scoAsmGeneration == generation do
        local active = unit:GetProductionToggle() == true
            and not unit:GetPause() and not unit.scoAsmUpgradeSuspended
        if active and sample < clip.durationSeconds then
            sample = math.min(
                clip.durationSeconds,
                sample + Constants.TickTimeStep * clip.rate)
            SCO_ASM_Sample(unit, clip.key, sample)
            speed = SCO_ASM_Approach(speed, 0, 50 * Constants.TickTimeStep)
        elseif active then
            if target == 0 and phase == "accelerate" then
                local goal = SCO_ASM_Bounded(unit, 20 + cycle, 120, 300)
                target = ((cycle % 2) == 0) and -goal or goal
            end
            speed = SCO_ASM_Approach(speed, target, 50 * Constants.TickTimeStep)
            if speed == target and phase == "accelerate" then
                phase = "decelerate"
                target = 0
            elseif speed == 0 and phase == "decelerate" then
                cycle = cycle + 1
                phase = "accelerate"
            end
        else
            speed = SCO_ASM_Approach(speed, 0, 50 * Constants.TickTimeStep)
            if speed == 0 and sample > 0 then
                sample = math.max(0, sample - Constants.TickTimeStep * clip.rate)
                SCO_ASM_Sample(unit, clip.key, sample)
            end
            target = 0
            phase = "accelerate"
        end

        SCO_ASM_EnableRotators(unit)
        SCO_ASM_SetRotator(unit, 1, 0, 0, speed)
        unit.scoAsmSample = sample
        unit.scoAsmRotorSpeed = speed
        unit.scoAsmRotorCycle = cycle
        unit.scoAsmRotorTarget = target
        unit.scoAsmRotorPhase = phase
        WaitTicks(1)
    end
end

local function SCO_ASM_JammerThread(unit, generation)
    local contract = SCO_ASM_Contract(unit)
    local clip = contract and contract.primaryClip
    if not clip then return end
    local sample = unit.scoAsmSample or 0
    local speed = unit.scoAsmRotorSpeed or 0
    while SCO_ASM_Alive(unit) and unit.scoAsmGeneration == generation do
        local enabled = unit.scoAsmIntelEnabled == true
        if enabled then
            sample = math.min(
                clip.durationSeconds,
                sample + Constants.TickTimeStep * clip.rate)
        else
            sample = math.max(0, sample - Constants.TickTimeStep * clip.rate)
        end
        speed = SCO_ASM_Approach(
            speed,
            enabled and 60 or 0,
            50 * Constants.TickTimeStep)
        SCO_ASM_Sample(unit, clip.key, sample)
        if enabled or speed ~= 0 then
            SCO_ASM_EnableRotators(unit)
            SCO_ASM_SetRotator(unit, 1, 0, 0, speed)
        elseif not unit.scoAsmRotatorsStopped then
            SCO_ASM_ZeroRotators(unit)
        end
        unit.scoAsmSample = sample
        unit.scoAsmRotorSpeed = speed
        WaitTicks(1)
    end
end

local function SCO_ASM_IsIntelKind(kind)
    return kind == "intel_rotor_upgrade"
        or kind == "intel_rotor_triple"
        or kind == "intel_rotor_pair_upgrade"
        or kind == "jammer"
end

local function SCO_ASM_RadarEnabled(unit)
    return unit.radarDetector ~= nil
        and unit.radarDetector:GetEnabled() == true
end

local function SCO_ASM_JammerEnabled(unit)
    local playerEnabled = true
    if unit.toggles and unit.toggles.Intel ~= nil then
        playerEnabled = unit:GetIntelToggle() == true
    end
    return unit:IsCompleted()
        and playerEnabled
        and unit.army ~= nil
        and unit.army.economy ~= nil
        and not unit.army.economy.isEnergyDown
end

local function SCO_ASM_IntelEnabled(unit, kind)
    if kind == "jammer" then
        -- Sanctuary does not implement FA radar-stealth fields, so ucs2711
        -- has no radarDetector. Track its source visual operating intent from
        -- completion, the optional Intel toggle, and army energy instead.
        return SCO_ASM_JammerEnabled(unit)
    end
    return SCO_ASM_RadarEnabled(unit)
end

local function SCO_ASM_UpdateIntelState(unit)
    local contract = SCO_ASM_Contract(unit)
    if not contract or not SCO_ASM_IsIntelKind(contract.kind) then return end
    if unit.progress == nil then return end
    local enabled = SCO_ASM_IntelEnabled(unit, contract.kind)
    unit.scoAsmIntelEnabled = enabled
    if not unit:IsCompleted() or unit.scoAsmInStopBeingBuilt then return end
    if contract.kind == "jammer" then
        if not unit.scoAsmThread then
            SCO_ASM_StartThread(unit, SCO_ASM_JammerThread)
        end
    elseif not unit.scoAsmThread then
        SCO_ASM_StartThread(unit, SCO_ASM_RotatorThread)
    end
end

local function SCO_ASM_StorageThread(unit, generation)
    local contract = SCO_ASM_Contract(unit)
    local clip = contract and contract.storageClip
    if not clip then return end
    while SCO_ASM_Alive(unit) and unit.scoAsmGeneration == generation do
        local economy = unit:GetEconomy()
        if not economy or not economy.GetResourceStoredRatio then
            error(unit.tpId .. " requires an economy storage-ratio provider")
        end
        local ratio = economy:GetResourceStoredRatio(clip.resource)
        if type(ratio) ~= "number" or ratio ~= ratio then
            error(unit.tpId .. " received an invalid " .. clip.resource .. " storage ratio")
        end
        ratio = math.max(0, math.min(1, ratio))
        if unit.scoAsmStorageRatio ~= ratio then
            SCO_ASM_Sample(unit, clip.key, ratio * clip.durationSeconds)
            unit.scoAsmStorageRatio = ratio
        end
        WaitTicks(1)
    end
    if unit.scoAsmGeneration == generation then
        unit.scoAsmThread = nil
    end
end

local function SCO_ASM_IsShieldKind(kind)
    return kind == "shield_rotators_t2" or kind == "shield_rotators_t3"
end

local function SCO_ASM_ShieldEffectiveUp(unit)
    return unit:IsCompleted()
        and unit:GetShieldToggle()
        and unit.army
        and unit.army.economy
        and not unit.army.economy.isEnergyDown
end

local function SCO_ASM_ShieldThread(unit, generation)
    local contract = SCO_ASM_Contract(unit)
    if not contract or not SCO_ASM_IsShieldKind(contract.kind) then return end
    local pod = unit.scoAsmShieldPodSpeed or 0
    local orbPrimary = unit.scoAsmShieldOrbPrimarySpeed or 0
    local orbZ = unit.scoAsmShieldOrbZSpeed or 0
    while SCO_ASM_Alive(unit) and unit.scoAsmGeneration == generation do
        local enabled = unit.scoAsmShieldEnabled == true
        local tick = Constants.TickTimeStep
        pod = SCO_ASM_Approach(pod, enabled and 60 or 0, 50 * tick)
        orbPrimary = SCO_ASM_Approach(
            orbPrimary, enabled and -45 or 0, 45 * tick)
        orbZ = SCO_ASM_Approach(orbZ, enabled and 45 or 0, 45 * tick)

        unit.scoAsmShieldPodSpeed = pod
        unit.scoAsmShieldOrbPrimarySpeed = orbPrimary
        unit.scoAsmShieldOrbZSpeed = orbZ
        if enabled or pod ~= 0 or orbPrimary ~= 0 or orbZ ~= 0 then
            SCO_ASM_EnableRotators(unit)
            SCO_ASM_SetRotator(unit, 1, 0, 0, pod)
            if contract.kind == "shield_rotators_t2" then
                SCO_ASM_SetRotator(unit, 2, orbPrimary, 0, orbZ)
            else
                SCO_ASM_SetRotator(unit, 2, 0, orbPrimary, orbZ)
            end
        else
            SCO_ASM_ZeroRotators(unit)
            unit.scoAsmThread = nil
            return
        end
        WaitTicks(1)
    end
end

local function SCO_ASM_UpdateShieldState(unit)
    local contract = SCO_ASM_Contract(unit)
    if not contract or not SCO_ASM_IsShieldKind(contract.kind) then return end
    if unit.progress == nil or unit.shields == nil then return end
    unit.scoAsmShieldEnabled = SCO_ASM_ShieldEffectiveUp(unit)
    if unit:IsCompleted()
        and not unit.scoAsmInStopBeingBuilt
        and not unit.scoAsmThread
    then
        SCO_ASM_StartThread(unit, SCO_ASM_ShieldThread)
    end
end

local function SCO_ASM_StartConfigured(unit)
    local contract = SCO_ASM_Contract(unit)
    if not contract or not unit:IsCompleted() then return end
    local kind = contract.kind
    if kind == "pump_loop_upgrade" then
        SCO_ASM_StartThread(unit, SCO_ASM_PumpLoopThread)
    elseif kind == "pump_state_machine" then
        SCO_ASM_StartThread(unit, SCO_ASM_PumpStateThread)
    elseif kind == "alternating_fabricator" then
        SCO_ASM_StartThread(unit, SCO_ASM_AlternatingThread)
    elseif kind == "permanent_open" then
        SCO_ASM_PlayClamp(unit, contract.primaryClip.key)
    elseif SCO_ASM_IsManagedRotatorKind(kind) then
        if SCO_ASM_IsIntelKind(kind) then
            unit.scoAsmIntelEnabled = SCO_ASM_IntelEnabled(unit, kind)
        end
        if kind == "fabricator_rotators" then
            unit.scoAsmFabricatorProductionEnabled =
                unit:GetProductionToggle() == true
        end
        SCO_ASM_StartThread(unit, SCO_ASM_RotatorThread)
    elseif kind == "jammer" then
        unit.scoAsmIntelEnabled = SCO_ASM_IntelEnabled(unit, kind)
        SCO_ASM_StartThread(unit, SCO_ASM_JammerThread)
    elseif kind == "storage_level" then
        SCO_ASM_StartThread(unit, SCO_ASM_StorageThread)
    elseif SCO_ASM_IsShieldKind(kind) then
        SCO_ASM_UpdateShieldState(unit)
    end
end

local function SCO_ASM_DomeThread(unit, generation)
    while SCO_ASM_Alive(unit)
        and unit.scoAsmGeneration == generation
        and (unit.scoAsmDomeQueue or 0) > 0
    do
        unit.scoAsmDomeQueue = unit.scoAsmDomeQueue - 1
        unit.scoAsmDomeCounter = (unit.scoAsmDomeCounter or 0) + 1
        SCO_ASM_EnableRotators(unit)
        -- 11 * 0.1 * 40 + 1 * 0.1 * 10 = exactly 45 degrees.
        for _ = 1, 11 do
            if not SCO_ASM_Alive(unit) or unit.scoAsmGeneration ~= generation then
                return
            end
            SCO_ASM_SetRotator(unit, 1, 0, 0, 40)
            WaitTicks(1)
        end
        SCO_ASM_SetRotator(unit, 1, 0, 0, 10)
        WaitTicks(1)
        SCO_ASM_SetRotator(unit, 1, 0, 0, 0)
        if unit.scoAsmDomeCounter == 8 then
            unit.scoAsmDomeCounter = 0
        end
    end
    unit.scoAsmDomeThread = nil
end

local function SCO_ASM_DomeStep(unit)
    local contract = SCO_ASM_Contract(unit)
    if not contract or contract.kind ~= "dome_recoil" then return end
    unit.scoAsmDomeQueue = (unit.scoAsmDomeQueue or 0) + 1
    if not unit.scoAsmDomeThread then
        local generation = unit.scoAsmGeneration or 0
        unit.scoAsmDomeThread = unit:NewThread(SCO_ASM_DomeThread, generation)
    end
end

local function SCO_ASM_PreservesRotatorsDuringUpgrade(contract)
    return contract.kind == "intel_rotor_upgrade"
        or contract.kind == "intel_rotor_pair_upgrade"
end

local function SCO_ASM_Death(unit, inherited, overkillRatio)
    local contract = SCO_ASM_Contract(unit)
    local death = contract and contract.deathClip
    if not contract or unit.deleted then
        return inherited(unit, overkillRatio)
    end
    SCO_ASM_Cleanup(unit)
    if not death or not unit:IsCompleted() then
        return inherited(unit, overkillRatio)
    end
    local elapsed = 0
    while not unit.deleted and elapsed < death.durationSeconds do
        SCO_ASM_Sample(unit, death.key, elapsed)
        WaitTicks(1)
        elapsed = math.min(
            death.durationSeconds,
            elapsed + Constants.TickTimeStep * death.rate)
    end
    if not unit.deleted then
        SCO_ASM_Sample(unit, death.key, death.durationSeconds)
    end
    return inherited(unit, overkillRatio)
end

local function SCO_ASM_Install(unitClass, className)
    if not unitClass then
        error("Aeon structure motion could not resolve " .. className)
    end
    local stockStop = unitClass.OnStopBeingBuilt
    local stockPause = unitClass.SetPause
    local stockCheckProductionState = unitClass.CheckProductionState
    local stockCheckRadarState = unitClass.CheckRadarState
    local stockCheckShieldState = unitClass.CheckShieldState
    local stockStartUpgrading = unitClass.OnStartUpgrading
    local stockEndUpgrading = unitClass.OnEndUpgrading
    local stockStartUpgrade = unitClass.OnStartUpgrade
    local stockEndUpgrade = unitClass.OnEndUpgrade
    local stockDestroy = unitClass.OnDestroy
    local stockDelete = unitClass.Delete
    local stockDeath = unitClass.DeathThread
    if not stockStop or not stockPause or not stockCheckProductionState
        or not stockCheckRadarState
        or not stockCheckShieldState
        or not stockStartUpgrading or not stockEndUpgrading
        or not stockStartUpgrade or not stockEndUpgrade
        or not stockDestroy or not stockDelete or not stockDeath
    then
        error("Aeon structure motion found an incomplete lifecycle on " .. className)
    end

    function unitClass:OnStopBeingBuilt()
        self.scoAsmInStopBeingBuilt = true
        local result = stockStop(self)
        self.scoAsmInStopBeingBuilt = false
        if SCO_ASM_Contract(self) then
            SCO_ASM_Cleanup(self)
            self.scoAsmUpgradeSuspended = false
            SCO_ASM_StartConfigured(self)
        end
        return result
    end

    function unitClass:CheckShieldState(skipRecharge)
        local result = stockCheckShieldState(self, skipRecharge)
        SCO_ASM_UpdateShieldState(self)
        return result
    end

    function unitClass:SetPause(value)
        return stockPause(self, value)
    end

    function unitClass:CheckProductionState()
        local result = stockCheckProductionState(self)
        local contract = SCO_ASM_Contract(self)
        if contract and self:IsCompleted()
            and contract.kind == "fabricator_rotators"
        then
            local enabled = self:GetProductionToggle() == true
            if self.scoAsmFabricatorProductionEnabled == true and not enabled then
                self.scoAsmFabricatorCycle =
                    (self.scoAsmFabricatorCycle or 0) + 1
            end
            self.scoAsmFabricatorProductionEnabled = enabled
            if not self.scoAsmThread then
                SCO_ASM_StartThread(self, SCO_ASM_RotatorThread)
            end
        end
        return result
    end

    function unitClass:CheckRadarState()
        local result = stockCheckRadarState(self)
        SCO_ASM_UpdateIntelState(self)
        return result
    end

    function unitClass:OnStartUpgrading(upgrade)
        local result = stockStartUpgrading(self, upgrade)
        local contract = SCO_ASM_Contract(self)
        if contract then
            self.scoAsmUpgradeSuspended = true
            if not SCO_ASM_PreservesRotatorsDuringUpgrade(contract) then
                SCO_ASM_Cleanup(self)
            end
        end
        return result
    end

    function unitClass:OnEndUpgrading(upgrade)
        local result = stockEndUpgrading(self, upgrade)
        if SCO_ASM_Contract(self) and SCO_ASM_Alive(self) then
            self.scoAsmUpgradeSuspended = false
            SCO_ASM_StartConfigured(self)
        end
        return result
    end

    function unitClass:OnStartUpgrade(upgrader)
        local result = stockStartUpgrade(self, upgrader)
        local contract = SCO_ASM_Contract(self)
        if contract then
            self.scoAsmUpgradeSuspended = true
            if not SCO_ASM_PreservesRotatorsDuringUpgrade(contract) then
                SCO_ASM_Cleanup(self)
            end
        end
        return result
    end

    function unitClass:OnEndUpgrade(upgrader)
        local result = stockEndUpgrade(self, upgrader)
        if SCO_ASM_Contract(self) and SCO_ASM_Alive(self) then
            self.scoAsmUpgradeSuspended = false
            SCO_ASM_StartConfigured(self)
        end
        return result
    end

    function unitClass:OnDestroy(destroyType)
        if SCO_ASM_Contract(self) then SCO_ASM_Cleanup(self) end
        return stockDestroy(self, destroyType)
    end

    function unitClass:Delete()
        if SCO_ASM_Contract(self) then SCO_ASM_Cleanup(self) end
        return stockDelete(self)
    end

    function unitClass:DeathThread(overkillRatio)
        return SCO_ASM_Death(self, stockDeath, overkillRatio)
    end

    unitClass.SCO_AeonStructureMotionDomeStep = SCO_ASM_DomeStep
end

local SCO_ASM_ENVIRONMENT =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCO_ASM_INSTALL_VERSION = "1.0.2"
local SCO_ASM_INSTALLED = rawget(
    SCO_ASM_ENVIRONMENT,
    "SupremeCommanderOverhaulAeonStructureMotionInstalled")
if SCO_ASM_INSTALLED ~= nil
    and SCO_ASM_INSTALLED ~= SCO_ASM_INSTALL_VERSION
then
    error("Unsupported Aeon Structure Motion lifecycle marker "
        .. tostring(SCO_ASM_INSTALLED))
end
if SCO_ASM_INSTALLED == nil then
    SCO_ASM_Install(AeonPortStructure, "AeonPortStructure")
    SCO_ASM_Install(AeonPortStorage, "AeonPortStorage")
    SCO_ASM_Install(AeonPortAlloyExtractor, "AeonPortAlloyExtractor")
    SCO_ASM_Install(AeonPortEnergyGenerator, "AeonPortEnergyGenerator")

    rawset(
        SCO_ASM_ENVIRONMENT,
        "SupremeCommanderOverhaulAeonStructureMotionInstalled",
        SCO_ASM_INSTALL_VERSION)
    -- Diagnostic only: a fresh import environment must still install wrappers
    -- for its new class tables even when this process-global version persists.
    _G.SupremeCommanderOverhaulAeonStructureMotionInstalled =
        SCO_ASM_INSTALL_VERSION
end
-- SCOM Field Fixes 1.0.5 - grounded Chosen/Aeon host consumers.
local SCO_FieldFixChosenHostVersion = "1.0.5"
local SCO_FieldFixChosenHostInstalled = _G.SCO_FieldFixChosenHostInstalled
if SCO_FieldFixChosenHostInstalled ~= nil
    and SCO_FieldFixChosenHostInstalled ~= SCO_FieldFixChosenHostVersion
then
    error("SCOM Field Fixes found an unsupported Chosen host consumer version")
end
if SCO_FieldFixChosenHostInstalled == nil then

    -- script.lua loads networking through require(), so Import sees a
    -- boolean package-cache entry. Its send API is already global.
    local SCO_FieldFixChosenSendToAllClients = SendToAllClients
    if type(SCO_FieldFixChosenSendToAllClients) ~= "function" then
        error("SCOM Field Fixes could not resolve host networking")
    end

    -- The stock movement collision layers occupy bits 0-6. Bit 30 is a
    -- deterministic, collision-neutral marker because marked units already
    -- share LandSmall; the native preloader consumes it only for engaged Circle facing.
    local SCO_FieldFixHoverFacingMarkerMask = 1073741824

    local function SCO_FieldFixChosenContract(unit, name)
        local additions = unit.tp and unit.tp.additions
        if not additions
            or additions.scoFieldFixAeonSeraphim ~= "1.0.0"
        then
            return nil
        end
        local contract = additions[name]
        if type(contract) == "table" and contract.version == "1.0.0" then
            return contract
        end
        return nil
    end

    local function SCO_FieldFixChosenAlive(unit)
        return unit ~= nil and not unit.dead and not unit.deleted
    end

    local function SCO_FieldFixChosenPlay(unit, key, blendTime)
        local animations = unit.tp
            and unit.tp.visuals
            and unit.tp.visuals.animations
        local animation = animations and animations[key]
        if not animation or not animation.id then
            error(unit.tpId .. " requires field-fix animation " .. tostring(key))
        end
        Engine.PlayAnimation(unit.id, animation.id, blendTime or 0.1)
    end

    if type(AeonPortNavalUnit) ~= "table"
        or type(AeonPortNavalUnit.OnStopBeingBuilt) ~= "function"
    then
        error("SCOM Field Fixes could not resolve AeonPortNavalUnit host lifecycle")
    end

    local SCO_FieldFixChosenNavalStopBeingBuilt =
        AeonPortNavalUnit.OnStopBeingBuilt

    function AeonPortNavalUnit:OnStopBeingBuilt()
        local result = SCO_FieldFixChosenNavalStopBeingBuilt(self)
        local contract = SCO_FieldFixChosenContract(self, "scoFieldFixTempest")
        if contract then
            SCO_FieldFixChosenPlay(self, contract.openAnimationKey, 0)
        end
        return result
    end

    if type(AeonPortStructure) ~= "table"
        or type(AeonPortStructure.OnStopBeingBuilt) ~= "function"
    then
        error("SCOM Field Fixes could not resolve AeonPortStructure host lifecycle")
    end

    local SCO_FieldFixChosenStructureStopBeingBuilt =
        AeonPortStructure.OnStopBeingBuilt

    local function SCO_FieldFixReadyCreativeApocalypse(unit)
        if unit.tpId ~= "ucs3102"
            or _G.SCO_FieldFixCreativeSpawnContext ~= "1.0.0"
        then
            return false
        end

        local additions = unit.tp and unit.tp.additions
        local silo = additions and additions.scoStrategicSilo
        local deploy = additions and additions.faAnimationClosureWeaponDeploy
        local construction = deploy and deploy.constructionOpen
        local animations = unit.tp
            and unit.tp.visuals
            and unit.tp.visuals.animations
        local animation = construction
            and animations
            and animations[construction.animationKey]
        if type(silo) ~= "table"
            or silo.version ~= "1.0.0"
            or silo.creativeSpawnAmmo ~= 5
            or type(silo.launchAnimation) ~= "table"
            or silo.launchAnimation.key ~= "fa_deploy"
            or silo.launchAnimation.packedKey ~= "fa_packed"
            or silo.launchAnimation.duration ~= 10
            or type(deploy) ~= "table"
            or deploy.deployAnimationKey ~= "fa_deploy"
            or deploy.packedAnimationKey ~= "fa_packed"
            or deploy.authoredDurationSeconds ~= 10
            or type(construction) ~= "table"
            or construction.animationKey ~= "fa_construction_open"
            or construction.authoredDurationSeconds ~= 16.6666660308838
            or construction.authoredRate ~= 1
            or type(animation) ~= "table"
            or animation.id == nil
        then
            error("SCOM Field Fixes found a drifted Creative Apocalypse readiness contract")
        end

        -- The upstream FA animation closure opens a normally built structure over
        -- 16.67 seconds. Creative has already created the completed structure, so
        -- cancel that generation and sample its authored open endpoint immediately.
        unit.scoFaConstructionOpenGeneration =
            (unit.scoFaConstructionOpenGeneration or 0) + 1
        Engine.PlayAnimation(
            unit.id,
            animation.id,
            -10000 + construction.authoredDurationSeconds)
        unit.scoFaAnimationConstructionReady = true
        Log("[SCOM Strategic Silo] Creative Apocalypse animation ready: tp=ucs3102 id="
            .. tostring(unit.id))
        return true
    end

    function AeonPortStructure:OnStopBeingBuilt(...)
        -- Direct/Creative creation marks this before stock completion clears its
        -- bypass state. Make only the imported Emissary ready immediately; its
        -- unchanged 20-second reload still governs every subsequent shot.
        local bypassedBuild = self.bypassedBuildProcess == true
        local result = SCO_FieldFixChosenStructureStopBeingBuilt(self, ...)
        SCO_FieldFixReadyCreativeApocalypse(self)
        local contract = SCO_FieldFixChosenContract(
            self, "scoFieldFixEmissaryArtillery")
        if contract and bypassedBuild then
            local weapon = self.weapons and self.weapons[1]
            if self.tpId ~= "ucs3101"
                or contract.creativeSpawnStartsReady ~= true
                or contract.rangeMin ~= 150
                or contract.rangeMax ~= 900
                or contract.pitchMax ~= 85
                or contract.projectileSpeed ~= 67
                or not weapon
                or not weapon.tp
                or weapon.tp ~= self.tp.weapons[1]
                or weapon.tp.reloadTime ~= 20
            then
                error("SCOM Field Fixes found a drifted Emissary ready-state contract")
            end
            weapon.reloadTimer = 0
        end
        return result
    end

    if type(AeonPortLandUnit) ~= "table"
        or type(AeonPortLandUnit.Hold) ~= "function"
        or type(AeonPortLandUnit.AttackBehaviorStart) ~= "function"
        or type(AeonPortLandUnit.AttackBehaviorStop) ~= "function"
        or type(AeonPortLandUnit.AttackMoveEngageTargets) ~= "function"
    then
        error("SCOM Field Fixes could not resolve AeonPortLandUnit host combat lifecycle")
    end

    local SCO_FieldFixChosenLandHold = AeonPortLandUnit.Hold
    local SCO_FieldFixChosenLandAttackStart = AeonPortLandUnit.AttackBehaviorStart
    local SCO_FieldFixChosenLandAttackStop = AeonPortLandUnit.AttackBehaviorStop
    local SCO_FieldFixChosenLandAttackMoveEngage =
        AeonPortLandUnit.AttackMoveEngageTargets

    local function SCO_FieldFixChosenHoverFacingDefaultMask(unit, contract)
        if contract.targetBodyFacingWhileOrbiting ~= true then
            return nil
        end
        if contract.nativeFacingMarkerMask
                ~= SCO_FieldFixHoverFacingMarkerMask
            or contract.faceTurnRateMultiplier ~= (4 / 3)
            or contract.runtimeNativeStrafeChassisPatchRequired ~= true
        then
            error("SCOM Field Fixes found a drifted hover-facing contract")
        end
        local movement = unit.tp and unit.tp.movement
        local defaultMask = movement and movement.collisionMaskDefault
        if type(defaultMask) ~= "number"
            or defaultMask < 0
            or defaultMask >= SCO_FieldFixHoverFacingMarkerMask
            or defaultMask ~= math.floor(defaultMask)
        then
            error("SCOM Field Fixes could not resolve the hover collision mask")
        end
        return defaultMask
    end

    local function SCO_FieldFixChosenApplyHoverFacingMarker(unit, contract)
        local defaultMask = SCO_FieldFixChosenHoverFacingDefaultMask(
            unit, contract)
        if defaultMask == nil then
            return false
        end
        if unit.scoFieldFixHoverFacingDefaultMask ~= nil then
            if unit.scoFieldFixHoverFacingDefaultMask ~= defaultMask then
                error("SCOM Field Fixes found a changed active hover collision mask")
            end
            return false
        end
        Engine.SetMovementCollisionMask(
            unit.id,
            defaultMask + SCO_FieldFixHoverFacingMarkerMask)
        unit.scoFieldFixHoverFacingDefaultMask = defaultMask
        return true
    end

    local function SCO_FieldFixChosenRestoreHoverFacingMarker(unit)
        local defaultMask = unit.scoFieldFixHoverFacingDefaultMask
        unit.scoFieldFixHoverFacingDefaultMask = nil
        if defaultMask ~= nil
            and SCO_FieldFixChosenAlive(unit)
            and unit.id ~= nil
        then
            Engine.SetMovementCollisionMask(unit.id, defaultMask)
        end
    end

    local SCO_FieldFixZeroAlignment = EngineClasses.float2(0, 0)

    local function SCO_FieldFixChosenStartHoverOrbit(unit, target)
        local contract = SCO_FieldFixChosenContract(
            unit, "scoFieldFixHoverStrafe")
        if not contract
            or not SCO_FieldFixChosenAlive(unit)
            or unit.id == nil
            or not SCO_FieldFixChosenAlive(target)
            or target.id == nil
        then
            return false
        end
        local movement = unit.tp.movement
        local patternID = movement.patternIDs and movement.patternIDs.scomHoverOrbit
        if not patternID or patternID == 0 then
            error("SCOM hover circle pattern was not created")
        end
        -- Validate the marker contract before changing native movement state.
        SCO_FieldFixChosenHoverFacingDefaultMask(unit, contract)
        if Engine.SetMovementPatterns(unit.id, 0, patternID) ~= EngineErrorCode.Success then
            return false
        end
        unit.movePatternID, unit.goalPatternID = 0, patternID
        SCO_FieldFixChosenApplyHoverFacingMarker(unit, contract)
        local started = Engine.MovementMoveToTarget(unit.id, target.id, contract.orbitRange)
            == EngineErrorCode.Success
        if started then
            unit.scoFieldFixHoverOrbitActive = true
        else
            local wasActive = unit.scoFieldFixHoverOrbitActive == true
            unit.scoFieldFixHoverOrbitActive = nil
            SCO_FieldFixChosenRestoreHoverFacingMarker(unit)
            unit:SetMovementPatterns("hold")
            if wasActive then Engine.MovementStop(unit.id, SCO_FieldFixZeroAlignment) end
        end
        return started
    end

    local function SCO_FieldFixChosenStopHoverOrbit(unit)
        local orbitWasActive = unit.scoFieldFixHoverOrbitActive == true
        if not orbitWasActive
            and unit.scoFieldFixHoverFacingDefaultMask == nil
        then
            return
        end
        unit.scoFieldFixHoverOrbitActive = nil
        SCO_FieldFixChosenRestoreHoverFacingMarker(unit)
        if orbitWasActive
            and SCO_FieldFixChosenAlive(unit)
            and unit.id ~= nil
        then
            unit:SetMovementPatterns("hold")
            Engine.MovementStop(unit.id, SCO_FieldFixZeroAlignment)
        end
    end

    function AeonPortLandUnit:Hold()
        if SCO_FieldFixChosenStartHoverOrbit(
            self,
            self.attackBehaviorTargetUnit)
        then
            return
        end
        SCO_FieldFixChosenStopHoverOrbit(self)
        return SCO_FieldFixChosenLandHold(self)
    end

    function AeonPortLandUnit:AttackBehaviorStart(targetUnit, range)
        local result = SCO_FieldFixChosenLandAttackStart(self, targetUnit, range)
        if self.attackBehaviorIsActive then
            SCO_FieldFixChosenStartHoverOrbit(self, targetUnit)
        end
        return result
    end

    function AeonPortLandUnit:AttackBehaviorStop(...)
        local fieldOrbitWasActive = self.scoFieldFixHoverOrbitActive == true
        local facingDefaultMask = self.scoFieldFixHoverFacingDefaultMask
        self.scoFieldFixHoverOrbitActive = nil
        self.scoFieldFixHoverFacingDefaultMask = nil
        local result = SCO_FieldFixChosenLandAttackStop(self, ...)
        if SCO_FieldFixChosenAlive(self) and self.id ~= nil then
            if facingDefaultMask ~= nil then
                Engine.SetMovementCollisionMask(self.id, facingDefaultMask)
            end
            if fieldOrbitWasActive then
                self:SetMovementPatterns("hold")
                Engine.MovementStop(self.id, SCO_FieldFixZeroAlignment)
            end
        end
        return result
    end

    function AeonPortLandUnit:AttackMoveEngageTargets()
        if not SCO_FieldFixChosenContract(self, "scoFieldFixHoverStrafe") then
            return SCO_FieldFixChosenLandAttackMoveEngage(self)
        end

        local orbitTarget = nil
        local target = self:GetMainWeaponTarget()
        while target ~= nil do
            if target ~= orbitTarget then
                if not SCO_FieldFixChosenStartHoverOrbit(self, target) then
                    SCO_FieldFixChosenStopHoverOrbit(self)
                    return SCO_FieldFixChosenLandAttackMoveEngage(self)
                end
                orbitTarget = target
            end
            WaitTicks(1)
            target = self:GetMainWeaponTarget()
        end
        self:Hold()
    end

    -- The converted Fervor mesh measures 0.4366 x 0.2891 x 0.8484 at
    -- (0, 0.1544, 0.0840). Keep a small gameplay margin while preserving the
    -- source unit's narrow lateral profile.
    local function SCO_FieldFixFervorSetCollider(
        unit,
        enabled,
        tolerateFailure)
        if Engine.SetVolumeColliderSize(
            unit.id,
            EngineClasses.float3(0.55, 0.32, 0.90))
                ~= EngineErrorCode.Success
            or Engine.SetVolumeColliderOffset(
                unit.id,
                EngineClasses.float3(0, 0.16, 0.084))
                ~= EngineErrorCode.Success
        then
            if tolerateFailure then return false end
            error("Fervor measured collider policy could not be applied")
        end
        if enabled ~= nil then
            local result = Engine.SetVolumeColliderEnabled(unit.id, enabled)
            if result ~= EngineErrorCode.Success then
                if tolerateFailure then return false end
                error("Fervor collider enabled state could not be applied")
            end
        end
        return true
    end

    local function SCO_FieldFixFervorVerifyEnabled(unit)
        for attempt = 1, 3 do
            if not scoAeonFactoryIsCurrent(unit) then
                return false
            end
            if SCO_FieldFixFervorSetCollider(unit, true, true) then
                local result, enabled =
                    Engine.GetVolumeColliderEnabled(unit.id)
                if result == EngineErrorCode.Success and enabled == true then
                    return true
                end
            end
            if attempt < 3 then
                WaitTicks(1)
            end
        end
        unit:Destroy(0)
        error("Fervor collider did not read back enabled after roll-off")
    end

    local function SCO_FieldFixFervorRollOffThread(
        targetUnit,
        factory,
        clearancePoint)
        local position = targetUnit:GetPosition()
        local deltaX = clearancePoint.x - position.x
        local deltaZ = clearancePoint.z - position.z
        local routeDistance = math.sqrt(
            (deltaX * deltaX) + (deltaZ * deltaZ))
        local movement = targetUnit.tp and targetUnit.tp.movement or {}
        local speed = movement.speedMax or 2.7
        local acceleration = movement.acceleration or 2.7
        local tickStep = Constants and Constants.TickTimeStep or (1 / 30)
        local travelSeconds = (routeDistance / math.max(speed, 0.01))
            + (2 * speed / math.max(acceleration, 0.01))
            + 2
        local remainingTicks = math.max(
            1,
            math.ceil(travelSeconds / tickStep))

        while scoAeonFactoryIsCurrent(targetUnit)
            and remainingTicks > 0
        do
            position = targetUnit:GetPosition()
            deltaX = position.x - clearancePoint.x
            deltaZ = position.z - clearancePoint.z
            if (deltaX * deltaX) + (deltaZ * deltaZ) <= 0.25 then
                break
            end
            remainingTicks = remainingTicks - 1
            WaitTicks(1)
        end

        if not scoAeonFactoryIsCurrent(targetUnit) then
            return
        end
        -- At natural arrival and at the bounded timeout, pin to the factory's
        -- authored terrain clearance before restoring collision.
        targetUnit:SetPosition(clearancePoint)
        if targetUnit.scoFactoryColliderPinOwner == factory then
            targetUnit.scoFactoryColliderPinOwner = nil
        end
        targetUnit.scoFieldFixFervorColliderThread = nil
        SCO_FieldFixFervorVerifyEnabled(targetUnit)
    end

    if type(AeonPortLandUnit.__init) == "function" then
        local SCO_FieldFixChosenLandInit = AeonPortLandUnit.__init
        function AeonPortLandUnit:__init(...)
            SCO_FieldFixChosenLandInit(self, ...)
            if self.tpId == "ucl1101" then
                SCO_FieldFixFervorSetCollider(self, nil)
            end
        end
    end

    if type(AeonPortLandFactory) == "table"
        and type(AeonPortLandFactory.RollOffUnit) == "function"
    then
        local SCO_FieldFixChosenLandFactoryRollOff =
            AeonPortLandFactory.RollOffUnit

        function AeonPortLandFactory:RollOffUnit(targetUnit)
            local isFervor = targetUnit
                and targetUnit.tpId == "ucl1101"
                and self.tp
                and self.tp.additions
                and self.tp.additions.rollOffSurfacePolicy == "terrain"
            local ramp = nil
            if isFervor then
                ramp = scoAeonFactorySelectRamp(self, targetUnit)
            end

            local result = SCO_FieldFixChosenLandFactoryRollOff(
                self,
                targetUnit)
            if not isFervor
                or not ramp
                or not scoAeonFactoryIsCurrent(targetUnit)
            then
                return result
            end

            local clearancePoint = scoAeonFactoryRoutePoint(
                self,
                ramp.clearanceOffset or ramp.rampOffset)
            -- Core already pinned the child. Treat a transient geometry/state
            -- write as recoverable so the verifier thread is always scheduled.
            SCO_FieldFixFervorSetCollider(targetUnit, false, true)
            if targetUnit.scoFieldFixFervorColliderThread ~= nil then
                KillThread(targetUnit.scoFieldFixFervorColliderThread)
            end
            targetUnit.scoFieldFixFervorColliderThread =
                targetUnit:NewThread(
                    SCO_FieldFixFervorRollOffThread,
                    self,
                    clearancePoint)
            return result
        end
    end

    -- Imported Aeon land factories keep a child collider disabled while the
    -- completed unit traverses the real model ramp. The core release thread
    -- previously treated SetVolumeColliderEnabled as fire-and-forget, and a
    -- production-stop race could clear factory ownership without restoring
    -- collision. A stranded child remained selectable but projectiles could
    -- never hit it. Preserve the animated exit, then require a successful,
    -- readable collider state at the authored terrain-clearance point.
    local function SCO_FieldFixAeonLandColliderIsEnabled(unit)
        local result, enabled = Engine.GetVolumeColliderEnabled(unit.id)
        return result == EngineErrorCode.Success and enabled == true
    end

    local function SCO_FieldFixAeonLandFactoryUsesTerrainRouting(factory)
        local template = factory and factory.tp
        local additions = template and template.additions
        return additions
            and additions.rollOffSurfacePolicy == "terrain"
    end

    local function SCO_FieldFixAeonLandColliderVerifyThread(
        targetUnit,
        factory,
        clearancePoint,
        generation)
        local remainingTicks = 330
        while scoAeonFactoryIsCurrent(targetUnit)
            and targetUnit.scoAeonFactoryLandRollOffThread ~= nil
            and remainingTicks > 0
        do
            remainingTicks = remainingTicks - 1
            WaitTicks(1)
        end

        if not scoAeonFactoryIsCurrent(targetUnit)
            or targetUnit.scoFieldFixAeonColliderGeneration ~= generation
        then
            return
        end

        local stalledThread =
            targetUnit.scoAeonFactoryLandRollOffThread
        if stalledThread ~= nil then
            KillThread(stalledThread)
            targetUnit.scoAeonFactoryLandRollOffThread = nil
        end

        if SCO_FieldFixAeonLandColliderIsEnabled(targetUnit) then
            return
        end

        -- The core release path normally owns this exact snap. Repeating it
        -- only after a failed/stalled restore keeps collision activation away
        -- from the factory hull while retaining the visible ramp traversal.
        targetUnit:SetPosition(clearancePoint)
        if targetUnit.scoFactoryColliderPinOwner == factory then
            targetUnit.scoFactoryColliderPinOwner = nil
        end

        for attempt = 1, 3 do
            if not scoAeonFactoryIsCurrent(targetUnit)
                or targetUnit.scoFieldFixAeonColliderGeneration ~= generation
            then
                return
            end
            local result = Engine.SetVolumeColliderEnabled(
                targetUnit.id,
                true)
            if result == EngineErrorCode.Success
                and SCO_FieldFixAeonLandColliderIsEnabled(targetUnit)
            then
                return
            end
            if attempt < 3 then
                WaitTicks(1)
            end
        end

        local failure = tostring(targetUnit.tpId)
            .. " completed Aeon land-factory roll-off without a collider"
        -- A completed, targetable unit without its authoritative damage
        -- collider must never survive as an immortal simulation entity.
        -- Persistent engine rejection is exceptional; fail closed after the
        -- bounded retries so the unit cannot poison the match indefinitely.
        targetUnit:Destroy(0)
        error(failure)
    end

    local function SCO_FieldFixVerifyAeonLandCollider(
        targetUnit,
        factory,
        clearancePoint)
        if not scoAeonFactoryIsCurrent(targetUnit)
            or not targetUnit:IsCompleted()
            or clearancePoint == nil
        then
            return
        end
        local generation =
            (targetUnit.scoFieldFixAeonColliderGeneration or 0) + 1
        targetUnit.scoFieldFixAeonColliderGeneration = generation
        targetUnit:NewThread(
            SCO_FieldFixAeonLandColliderVerifyThread,
            factory,
            clearancePoint,
            generation)
    end

    local function SCO_FieldFixReleaseStrandedAeonLandChild(
        factory,
        targetUnit)
        targetUnit = targetUnit
            or factory.scoAeonFactoryPinnedBuildTarget
        if not scoAeonFactoryIsCurrent(targetUnit)
            or not targetUnit:HasTags(Tags.MOBILE)
            or not targetUnit:IsCompleted()
            or targetUnit.scoAeonFactoryLandRollOffThread ~= nil
            or targetUnit.scoFieldFixFervorColliderThread ~= nil
            or not SCO_FieldFixAeonLandFactoryUsesTerrainRouting(factory)
        then
            return false
        end

        if SCO_FieldFixAeonLandColliderIsEnabled(targetUnit) then
            if targetUnit.scoFactoryColliderPinOwner == factory then
                targetUnit.scoFactoryColliderPinOwner = nil
            end
            return true
        end

        local ramp = scoAeonFactorySelectRamp(factory, targetUnit)
        local clearancePoint = scoAeonFactoryRoutePoint(
            factory,
            ramp.clearanceOffset or ramp.rampOffset)
        if not factory:ReleaseAeonFactoryBuiltUnit(targetUnit, ramp) then
            return false
        end
        scoAeonFactoryForgetRamp(factory, targetUnit)
        SCO_FieldFixVerifyAeonLandCollider(
            targetUnit,
            factory,
            clearancePoint)
        return true
    end

    if type(AeonPortLandFactory) == "table"
        and type(AeonPortLandFactory.RollOffUnit) == "function"
        and type(AeonPortLandFactory.ProductionBehaviorStop) == "function"
        and type(AeonPortLandFactory.OnCancelConstruction) == "function"
        and type(AeonPortLandFactory.OnDestroy) == "function"
    then
        local SCO_FieldFixAeonLandFactoryRollOff =
            AeonPortLandFactory.RollOffUnit
        local SCO_FieldFixAeonLandFactoryProductionStop =
            AeonPortLandFactory.ProductionBehaviorStop
        local SCO_FieldFixAeonLandFactoryCancel =
            AeonPortLandFactory.OnCancelConstruction
        local SCO_FieldFixAeonLandFactoryDestroy =
            AeonPortLandFactory.OnDestroy

        function AeonPortLandFactory:RollOffUnit(targetUnit)
            local clearancePoint = nil
            if scoAeonFactoryIsCurrent(targetUnit)
                and targetUnit:HasTags(Tags.MOBILE)
                and targetUnit:IsCompleted()
                and targetUnit.tpId ~= "ucl1101"
                and SCO_FieldFixAeonLandFactoryUsesTerrainRouting(self)
            then
                local ramp = scoAeonFactorySelectRamp(self, targetUnit)
                clearancePoint = scoAeonFactoryRoutePoint(
                    self,
                    ramp.clearanceOffset or ramp.rampOffset)
            end

            local result = SCO_FieldFixAeonLandFactoryRollOff(
                self,
                targetUnit)
            SCO_FieldFixVerifyAeonLandCollider(
                targetUnit,
                self,
                clearancePoint)
            return result
        end

        function AeonPortLandFactory:ProductionBehaviorStop()
            local targetUnit = self.productionBehaviorTargetUnit
                or self.scoAeonFactoryPinnedBuildTarget
            SCO_FieldFixReleaseStrandedAeonLandChild(self, targetUnit)
            return SCO_FieldFixAeonLandFactoryProductionStop(self)
        end

        function AeonPortLandFactory:OnCancelConstruction()
            local targetUnit = self.productionBehaviorTargetUnit
                or self.scoAeonFactoryPinnedBuildTarget
            SCO_FieldFixReleaseStrandedAeonLandChild(
                self,
                targetUnit)
            return SCO_FieldFixAeonLandFactoryCancel(self)
        end

        function AeonPortLandFactory:OnDestroy(isDelete)
            local targetUnit = self.productionBehaviorTargetUnit
                or self.scoAeonFactoryPinnedBuildTarget
            SCO_FieldFixReleaseStrandedAeonLandChild(self, targetUnit)
            return SCO_FieldFixAeonLandFactoryDestroy(self, isDelete)
        end
    end

    -- UAL0401 authors one death clip (Adeath01): 179 frames at 30 Hz.
    -- Its terminal root transform is copied to the wreck by
    -- CreateWreckageFromUnit/Engine.CopyHierarchy.
    local SCO_FieldFixColossusDeathAnimationKey =
        "source_animadeath01"
    local SCO_FieldFixColossusDeathVFXCommand =
        "SCOFieldFixColossusDeathVFX"
    local SCO_FieldFixColossusWreckCommand =
        "SCOFieldFixColossusWreckBounds"

    local function SCO_FieldFixColossusSampleTransform(entityId)
        if entityId == nil then return nil end
        local positionCall, positionResult, position = pcall(
            Engine.GetGlobalEntityWorldPosition,
            entityId)
        if not positionCall
            or positionResult ~= EngineErrorCode.Success
            or position == nil
        then
            return nil
        end
        local orientationCall, orientation = pcall(EngineClasses.quaternion)
        if not orientationCall or orientation == nil then return nil end
        local rotationCall, rotationResult = pcall(
            Engine.GetGlobalEntityWorldRotation,
            entityId,
            orientation)
        if not rotationCall
            or rotationResult ~= EngineErrorCode.Success
        then
            return nil
        end
        return position, orientation
    end

    local function SCO_FieldFixColossusSendBoneVFX(unit, boneName, scale, kind)
        local boneId
        if type(unit.GetBoneId) == "function" then
            local boneCall, result = pcall(unit.GetBoneId, unit, boneName)
            if boneCall then boneId = result end
        end
        local position, orientation =
            SCO_FieldFixColossusSampleTransform(boneId)
        if position == nil then
            position, orientation =
                SCO_FieldFixColossusSampleTransform(unit.id)
        end
        if position == nil then return false end
        SCO_FieldFixChosenSendToAllClients({
            unitIndex = unit.id.index,
            unitVersion = unit.id.version,
            tpId = unit.tpId,
            kind = kind,
            scale = scale,
            position = {
                x = position.x,
                y = position.y,
                z = position.z,
            },
            orientation = {
                x = orientation.x,
                y = orientation.y,
                z = orientation.z,
                w = orientation.w,
            },
        }, SCO_FieldFixColossusDeathVFXCommand)
        return true
    end

    local function SCO_FieldFixColossusSendWreckBounds(wreckage)
        if wreckage == nil or wreckage.id == nil then
            return
        end
        SCO_FieldFixChosenSendToAllClients({
            propIndex = wreckage.id.index,
            propVersion = wreckage.id.version,
            tpId = "ucl4004_Wreckage",
            -- Conservative terminal-pose envelope derived from the authored
            -- root fall: x=3.94, z=7.23, centered 3.25 forward.
            size = { x = 4.0, y = 3.4, z = 7.4 },
            offset = { x = 0, y = 1.7, z = 3.25 },
        }, SCO_FieldFixColossusWreckCommand)
    end

    if type(AeonPortLandUnit.OnDestroy) == "function"
        and type(AeonPortLandUnit.CreateDeathExplosions) == "function"
        and type(AeonPortLandUnit.DeathThread) == "function"
        and type(AeonPortLandUnit.CreateWreckage) == "function"
    then
        local SCO_FieldFixChosenLandOnDestroy =
            AeonPortLandUnit.OnDestroy
        local SCO_FieldFixChosenLandCreateDeathExplosions =
            AeonPortLandUnit.CreateDeathExplosions
        local SCO_FieldFixChosenLandDeathThread =
            AeonPortLandUnit.DeathThread
        local SCO_FieldFixChosenLandCreateWreckage =
            AeonPortLandUnit.CreateWreckage

        function AeonPortLandUnit:OnDestroy(destroyType)
            local isFallDeath = self.tpId == "ucl4004"
                and self:IsCompleted()
                and not self:IsPlacementGhost()
                and (destroyType == DestroyType.Unspecified
                    or destroyType == DestroyType.Kinetic)
            if isFallDeath then
                local animations = self.tp
                    and self.tp.visuals
                    and self.tp.visuals.animations
                local deathAnimation = animations
                    and animations[SCO_FieldFixColossusDeathAnimationKey]
                if not deathAnimation or not deathAnimation.id then
                    error("Galactic Colossus requires authored Adeath01")
                end
                self.scoFieldFixColossusFallDeath = true
            end
            return SCO_FieldFixChosenLandOnDestroy(self, destroyType)
        end

        function AeonPortLandUnit:CreateDeathExplosions()
            if self.scoFieldFixColossusFallDeath
                and not self.scoFieldFixColossusReleaseDeathDamage
            then
                return
            end
            return SCO_FieldFixChosenLandCreateDeathExplosions(self)
        end

        function AeonPortLandUnit:CreateWreckage(overkillRatio)
            if not self.scoFieldFixColossusFallDeath then
                return SCO_FieldFixChosenLandCreateWreckage(
                    self,
                    overkillRatio)
            end
            if overkillRatio < 1 then
                local wreckage = CreateWreckageFromUnit(self)
                SCO_FieldFixColossusSendWreckBounds(wreckage)
                return wreckage
            end
        end

        function AeonPortLandUnit:DeathThread(overkillRatio)
            if not self.scoFieldFixColossusFallDeath then
                return SCO_FieldFixChosenLandDeathThread(
                    self,
                    overkillRatio)
            end

            self.isAnimated = false
            Engine.SetMovementEnabled(self.id, false)
            Engine.SetMovementCollisionMask(self.id, 0)
            Engine.SetVolumeColliderEnabled(self.id, false)
            Engine.SetAnimatorEnabled(self.id, true)
            SCO_FieldFixChosenPlay(
                self,
                SCO_FieldFixColossusDeathAnimationKey,
                0)

            SCO_FieldFixColossusSendBoneVFX(
                self,
                "Torso",
                4,
                "large")
            WaitSeconds(2)
            SCO_FieldFixColossusSendBoneVFX(
                self,
                "Right_Leg_B02",
                1,
                "small")
            WaitSeconds(0.1)
            SCO_FieldFixColossusSendBoneVFX(
                self,
                "Right_Leg_B01",
                1,
                "small")
            WaitSeconds(0.1)
            SCO_FieldFixColossusSendBoneVFX(
                self,
                "Left_Arm_B02",
                1,
                "small")
            WaitSeconds(0.3)
            SCO_FieldFixColossusSendBoneVFX(
                self,
                "Right_Arm_B01",
                1,
                "small")
            SCO_FieldFixColossusSendBoneVFX(
                self,
                "Right_Leg_B01",
                1,
                "small")
            WaitSeconds(3.5)
            SCO_FieldFixColossusSendBoneVFX(
                self,
                "Torso",
                5,
                "large")

            self.scoFieldFixColossusReleaseDeathDamage = true
            SCO_FieldFixChosenLandCreateDeathExplosions(self)
            if self:GetFractionComplete() >= 0.5 and self.spawnsWreck then
                self:CreateWreckage(overkillRatio or 0)
            end
            self:Delete()
        end
    end

    _G.SCO_FieldFixChosenHostInstalled = SCO_FieldFixChosenHostVersion
end
-- SCOM factory egress Chosen installation 1.0.0
local factoryEgress = Import("common/systems/scoFactoryEgress.lua")
factoryEgress.Install(HostAeonPortLandFactory)
factoryEgress.Install(HostAeonPortAirFactory)
factoryEgress.Install(HostAeonPortNavalFactory)
