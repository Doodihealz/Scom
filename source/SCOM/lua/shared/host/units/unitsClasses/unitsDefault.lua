local AdjacencyBuffs = Import("host/systems/adjacencyBuffs.lua").AdjacencyBuffs
local Buffs = Import("host/systems/buffs.lua")

local OrderTasks = Import("common/commonOrders.lua").OrderTasks
local HostOrderManager = Import("host/managers/orders/hostOrderManager.lua")
local BuildQueueCommands = Import("common/commands/definitions/buildQueue.lua")
local SessionCommands    = Import("common/commands/definitions/session.lua")
local Layers = Import("common/layers.lua")
local Water = Import("common/water.lua")

local Curve = Import("host/curves.lua").Curve
local WreckCrash = Import("host/props/wreckCrash.lua")

-- Base unit class that we're gonna use.
local HostUnit = Import("host/units/unitsClasses/unitsBaseClass.lua").HostUnit

------------------
-- Structure class
------------------

---@class HostStructure: HostUnit
HostStructure = Class("Structure", HostUnit)

function HostStructure:__init(id, army, template, fractionCompleted)
    HostUnit.__init(self, id, army, template, fractionCompleted)

    -- Keep track of adjacent units.
    self.adjacentUnits = {}
    self.buildQueue = {} -- List of tps to build: [i] = {tpId = "unitID", entryIds = {id, ...}}, one entry id per queued unit, in build order
end

function HostStructure:SendUpdateBuildQueueCommand()
    BuildQueueCommands.UpdateBuildQueue.Send(self.id, self.buildQueue)
end

-- Called by buildQueueUtils when the head of the queue changes (e.g., the in-progress
-- item is removed). The production loop owns the build routine, so cancellation flows
-- through stopping the active behavior. Pause is preserved (the behavior tracks it).
function HostStructure:OnCancelConstruction()
    self:UpgradeBehaviorStop()
    self:ProductionBehaviorStop()
end

---@param destroyType DestroyType
function HostStructure:OnDestroy(destroyType)

    -- Inform all adjacent units that we are dead.
    local units = table.shallowCopy(self.adjacentUnits)
    for _, unit in pairs(units) do
        unit:OnNotAdjacentTo(self)
        self:OnNotAdjacentTo(unit)
    end

    -- todo: when engineering station is dead, it kills in progress units

    -- Stop the production monitor thread; structure death means no further work.
    if self.productionMonitorThread then
        KillThread(self.productionMonitorThread)
        self.productionMonitorThread = nil
    end

    -- Stop active production/upgrade behaviors before HostUnit.OnDestroy runs EndBuildRoutine
    -- so the behavior layer cleans up its state first.
    self:ProductionBehaviorStop()
    self:UpgradeBehaviorStop()

    HostUnit.OnDestroy(self, destroyType)
end

function HostStructure:PromoteToUnit()
    HostUnit.PromoteToUnit(self)

    -- Real things can influence the navmap.
    self:SetNavmapModifiersEnabled(true)
    Engine.SetGlobalGridModifierEnabled(self.id, true)
end

function HostStructure:OnAdjacentTo(adjacentUnit)
    --Log("Unit: "..self.id.." tpId: "..self.tpId.." is adjacent to: "..adjacentUnit.id.." tpId: "..adjacentUnit.tpId)
    local adjName = self.tp.adjacency
    if not adjName then
        return
    end

    for _, buffName in pairs(AdjacencyBuffs[adjName]) do
        Buffs.ApplyBuff(buffName, adjacentUnit)
    end

    table.insert(self.adjacentUnits, adjacentUnit)
end

function HostStructure:OnNotAdjacentTo(adjacentUnit)
    --Log("Unit: "..self.id.." tpId: "..self.tpId.." is not adjacent to: "..adjacentUnit.id.." tpId: "..adjacentUnit.tpId)
    local adjName = self.tp.adjacency
    if not adjName then
        return
    end

    for _, buffName in pairs(AdjacencyBuffs[adjName]) do
        if Buffs.HasBuff(buffName, adjacentUnit) then
            Buffs.RemoveBuff(buffName, adjacentUnit)
        end
    end

    table.removeByValue(self.adjacentUnits, adjacentUnit)
end

function HostStructure:ClearBuildQueue()
    if self.buildQueue[1] then
        self:OnCancelConstruction()
        self.buildQueue = {}
        self:SendUpdateBuildQueueCommand()
    end
end

function HostStructure:OnStopBeingBuilt()
    HostUnit.OnStopBeingBuilt(self)

    if self.tp.movement ~= nil then
        Engine.SetMovementEnabled(self.id, false)
    end

    self.productionMonitorThread = self:NewThread(self.ProductionMonitorThread)
end


--# production monitor ==================
-- Lightweight queue watcher that ticks once per simulation tick and kicks off
-- the relevant behavior when work appears. Pause is owned by the behaviors
-- themselves (Rule R4); the monitor is pause-agnostic.
--
-- Factory overrides this to start ProductionBehavior. The Structure default
-- only handles self-upgrades (extractors and similar).
function HostStructure:ProductionMonitorThread()
    while not self.dead do        
        if not self.upgradeBehaviorIsActive and self:UpgradeBehaviorIsValidFor() then
            self:UpgradeBehaviorStart()
        end
        WaitTicks(1)
    end
end

--# upgrade behaviour ==================
--* not valid if structure is dead, incomplete, already upgrading, or the queued
--  item is not the upgrade target tpId.
--* spawns the upgrade unit at the structure's own position, marks self.upgrading,
--  drives the build routine, polls GetPause to suspend across pause.
--* on completion: the upgrade unit's OnStopBeingBuilt copies the structure's
--  queue / orders / toggles to itself and Deletes the original structure, which
--  kills this thread along with the rest of the original unit.
--* on external abort (Stop): ends the routine and clears upgrading flag. Does
--  not delete the partial upgrade unit -- Factory overrides Stop to do that, as
--  the prior behavior for factory upgrade cancellation was to delete the partial.
function HostStructure:UpgradeBehaviorIsValidFor()
    if self.dead then return false end
    if not self:IsCompleted() then return false end
    if self.upgradeBehaviorIsActive then return false end
    if self:IsUpgrading() then return false end
    local upgradesTo = self.construction and self.construction.upgradesTo
    if not upgradesTo then return false end
    local head = self.buildQueue[1]
    if not head or head.tpId ~= upgradesTo then return false end
    return true
end

function HostStructure:UpgradeBehaviorStart()
    if not self:UpgradeBehaviorIsValidFor() then return end

    self.upgradeBehaviorIsActive = true
    self.upgradeBehaviorThread = self:NewThread(self.UpgradeBehaviorThread)
end

---@private If the upgrade thread can continue.
---@return boolean
function HostStructure:IsUpgradeValid()
    return not self.dead and not self.upgradeBehaviorTargetUnit.dead and not self.upgradeBehaviorTargetUnit:IsCompleted()
end

function HostStructure:UpgradeBehaviorThread()

    -- Wait till we are unpaused to start the behavior. Or exit if we are dead.
    WaitUntil(function() return self.dead or not self:GetPause() end)

    if self.dead then
        self:UpgradeBehaviorStop()
        return
    end

    local head = self.buildQueue[1]
    self.upgradeBehaviorTargetUnit = CreateUnit(self.army.id, head.tpId, self:GetPosition(), nil, 0.0)    
    self:StartUpgrading(self.upgradeBehaviorTargetUnit)

    while self:IsUpgradeValid() do

        -- Hold until unpaused or upgrade becomes invalid.
        WaitUntil(function() return not self:IsUpgradeValid() or not self:GetPause() end)

        -- We should exit loop if the reason for waiting was upgrade became invalid.
        if not self:IsUpgradeValid() then break end

        self:StartBuildRoutine(self.upgradeBehaviorTargetUnit)

        -- Build until paused, or the routine ends (process completes / upgrade dies).
        WaitUntil(function()
            return self:GetPause() or not self:IsBuilding(self.upgradeBehaviorTargetUnit)
        end)

        -- End our contribution. If the process already ended it, IsBuilding is false
        -- and EndBuildRoutine must not run again (Rule R1).
        if self:IsBuilding(self.upgradeBehaviorTargetUnit) then
            self:EndBuildRoutine(self.upgradeBehaviorTargetUnit)
        end
    end

    self:UpgradeBehaviorStop()
end

function HostStructure:UpgradeBehaviorStop()
    if not self.upgradeBehaviorIsActive then return end

    local upgrade = self.upgradeBehaviorTargetUnit

    if self:IsUpgrading() then
        self:EndUpgrading()
    end

    -- This behavior owns the build routine: end it if the process has not already (Rule B2).
    if upgrade and self:IsBuilding(upgrade) then
        self:EndBuildRoutine(upgrade)
    end

    if self.upgradeBehaviorThread then
        KillThread(self.upgradeBehaviorThread)
        self.upgradeBehaviorThread = nil
    end
    self.upgradeBehaviorIsActive = false
    self.upgradeBehaviorTargetUnit = nil
end

---@protected Called when this unit (built as an upgrade) stops being upgraded by `upgrader`. On completion it inherits the upgrader's build queue, toggles, rally point and orders, then deletes the upgrader; if the upgrade was cancelled it deletes itself instead.
---@param upgrader HostStructure The unit that was upgrading into this one.
function HostStructure:OnEndUpgrade(upgrader)
    local completedUpgrade = self:IsCompleted() and not upgrader.dead

    -- Transfer the state of the structure first before calling the base class's OnEndUpgrade.
    -- This ensures that the structure's state is correctly transferred before any potential changes made by the base class's OnEndUpgrade.
    if completedUpgrade then
        table.remove(upgrader.buildQueue, 1)
        self.buildQueue = table.deepCopy(upgrader.buildQueue)

        self.rallyPoint = upgrader.rallyPoint
    end

    HostUnit.OnEndUpgrade(self, upgrader)

    -- If we completed our upgrade then we delete the upgrader. Otherwise, we canceled, delete ourselves.
    if completedUpgrade then
        self:SendUpdateBuildQueueCommand()
        upgrader:Delete()
    else
        if not self.dead then
            self:Delete()
        end
    end
end

-- Structures do not run a production behavior by default; Factory overrides this.
-- Defined here as an idempotent no-op so Structure-level code (OnDestroy, OnCancelConstruction)
-- can call it polymorphically without checking for Factory specifically.
function HostStructure:ProductionBehaviorStop() end

function HostStructure:DesiresAssistance(fromUnit)
    if not HostUnit.DesiresAssistance(self, fromUnit) then
        return false
    end

    -- todo: damaged buildings need repair
    -- # always help factories and engineering stations forever
    if self:IsFactory() or self:IsEngineeringStation() then return true end
    -- # help finish unfinished buildings
    if not self:IsCompleted() then return true end
    -- # help finish upgrading buildings like extractors
    if self.buildQueue and #self.buildQueue > 0 then return true end

    return false
end

------------------------
-- Naval Structure class
------------------------

---@class HostNavalStructure: HostStructure
HostNavalStructure = Class("NavalStructure", HostStructure)

HostNavalStructure.DefaultTargetingLayer = Layers.TargetingLayer.WaterSurface
HostNavalStructure.DefaultIsInWater = true

----------------
-- TechCentre class
----------------

---@class HostTechCenter: HostStructure
HostTechCentre = Class("TechCentre", HostStructure)

---Returns the production domain unlocked by this technology centre.
---@return string
function HostTechCentre:GetTechnologyDomainTag()
    if self:HasTags(Tags.AIR_TECH_CENTRE) then
        return "AIR"
    elseif self:HasTags(Tags.LAND_TECH_CENTRE) then
        return "LAND"
    elseif self:HasTags(Tags.NAVAL_TECH_CENTRE) then
        return "NAVAL"
    end
    error("Tech centre "..self.tpId.." is missing a technology domain tag.")
end

function HostTechCentre:OnStopBeingBuilt()
    HostStructure.OnStopBeingBuilt(self)

    Armies[self.army.id]:AddTechCentre(self.factionTag, self:GetTechnologyDomainTag(), self.techTag)
end

---@param destroyType DestroyType
function HostTechCentre:OnDestroy(destroyType)

    Armies[self.army.id]:RemoveTechCentre(self.factionTag, self:GetTechnologyDomainTag(), self.techTag)

    HostStructure.OnDestroy(self, destroyType)
end

---------------------------
-- Naval TechCentre class
---------------------------

---@class HostNavalTechCentre: HostTechCenter
HostNavalTechCentre = Class("NavalTechCentre", HostTechCentre)

HostNavalTechCentre.DefaultTargetingLayer = Layers.TargetingLayer.WaterSurface

----------------
-- Storage class
----------------

---@class HostStorage: HostStructure
HostStorage = Class("Storage", HostStructure)

function HostStorage:OnStopBeingBuilt()
    local tpEco = self.tp.economy
    if tpEco.storage then
        self:GetEconomy():AddStorage(self.id, tpEco.storage)
    end

    HostStructure.OnStopBeingBuilt(self)
end

----------------------------
-- Engineering Station class
----------------------------

---@class HostEngineeringStation: HostStructure
HostEngineeringStation = Class("EngineeringStation", HostStructure)

function HostEngineeringStation:__init(id, army, template, progress, builder)
    HostStructure.__init(self, id, army, template, progress, builder)
end

function HostEngineeringStation:StartBuild(tpId, position)
    tpId, position = self:GetNextInBuildQueue()

    if not buildQueueUtils.CanBuild(self, tpId) then
        Warn("Invalid blueprint ID given to engineer: "..tpId)
        return
    elseif not position then
        Warn("EngineeringStation missing position to build: "..tpId)
        return
    end

    --Log(string.format("EngineeringStation id: %d, tpId: %s starting to build unit: %s", self.id, self.tpId, tpId))

    local unit = CreateUnit(self.army.id, tpId, position, nil, 0.0)
    self:StartBuildRoutine(unit)
end

function HostEngineeringStation:GetNextInBuildQueue()
    if not self.buildQueue[1] then
        return false
    end

    return self.buildQueue[1].tpId, self.buildQueue[1].position
end

----------------------------
-- Engineering Station class
----------------------------

---@class HostAirfield: HostStructure
HostAirfield = Class("Airfield", HostStructure)

----------------
-- Factory class
----------------

---@class HostFactory: HostStructure
HostFactory = Class("Factory", HostStructure)

function HostFactory:__init(id, army, template, progress, builder)
    HostStructure.__init(self, id, army, template, progress, builder)
    self.unitBeingBuiltSource = nil -- for slave factories keeps track of it this unit was from our queue, or a master factory
end

function HostFactory:CompleteBuildQueueItem(index)
    local item = self.buildQueue[index]
    local entryId = table.remove(item.entryIds, 1)
    if not item.entryIds[1] then
        table.remove(self.buildQueue, index)
    end

    -- Repeat moves the entry to the back under the same id, so client requests naming it still find it
    if self:GetRepeatBuild() then
        table.insert(self.buildQueue, {tpId = item.tpId, entryIds = {entryId}})
    end
end

function HostFactory:CanBeSlaveFactory()
    return true
end

function HostFactory:CanBeMasterFactory()
    return true
end

function HostFactory:RotatorsEnabledOnConstruction()
    return false
end

-- Factory overrides Structure's monitor to start ProductionBehavior. The factory's
-- ProductionBehavior handles both unit production and self-upgrades (by delegating
-- to UpgradeBehavior internally), so we do not also start UpgradeBehavior here.
function HostFactory:ProductionMonitorThread()
    while not self.dead do
        if not self.productionBehaviorIsActive and self:ProductionBehaviorIsValidFor() then
            self:ProductionBehaviorStart()
        end
        WaitTicks(1)
    end
end

--# production behaviour ==================
-- Long-running orchestration of factory output. Drives the build-roll-off-repeat
-- loop while the factory has queued work (or is a slave factory that may pull
-- from a master). Owns pause: the loop polls GetPause() to suspend new builds
--
-- Per-iteration shape:
--   1. If queue is empty and we are a slave, try to pull from master. If still
--      empty, exit (monitor restarts us when work arrives or slave master gets work).
--   2. Wait for unpause before kicking off a new item.
--   3. If the head item is the self-upgrade tpId, delegate to UpgradeBehavior.
--   4. Otherwise, spawn the unit at the roll-off point, run the build routine,
--      poll for pause / completion, and on completion do roll-off + 2s hold.
function HostFactory:ProductionBehaviorIsValidFor()
    if self.dead then return false end
    if not self:IsCompleted() then return false end
    -- Stay alive as long as we have work, or we are a slave that may pull from a master.
    return self.buildQueue[1] ~= nil or self.isSlaveFactory
end

function HostFactory:ProductionBehaviorStart()
    if not self:ProductionBehaviorIsValidFor() then return end

    if self.productionBehaviorIsActive then
        error("Trying to start production beahvior when it is already active.")
    end

    self.productionBehaviorIsActive = true
    self:SetRotatorsEnabled(true)
    self.productionBehaviorThread = self:NewThread(self.ProductionBehaviorThread)
end

function HostFactory:ProductionBehaviorThread()
    while self:ProductionBehaviorIsValidFor() do
        -- Slave factory with nothing in its own queue: try to pull one item from
        -- the master factory chain. If the master has no work, idle a tick and
        -- re-poll; we stay alive because IsValidFor still returns true for slaves.
        if not self.buildQueue[1] then
            if self.isSlaveFactory then
                local index, queueItem, masterFac = self:GetNextInMasterFacBuildQueue()
                if queueItem then
                    masterFac:CompleteBuildQueueItem(index)
                    buildQueueUtils.CleanUpAndMergeQueueItems(masterFac)
                    masterFac:SendUpdateBuildQueueCommand()
                    buildQueueUtils.AddToBuildQueue(self, queueItem.tpId, buildQueueUtils.NewEntryIds(1))
                    self.unitBeingBuiltSource = masterFac
                else
                    WaitTicks(1)
                end
            else
                break  -- nothing left to build and we have no master to pull from
            end
        else
            -- Wait for unpause before starting the next queued item.
            WaitUntil(function() return self.dead or not self:GetPause() end)
            if self.dead then break end

            local item = self.buildQueue[1]
            if not item then
                -- The queue was cleared while we waited for unpause; loop and re-evaluate.
            elseif self.construction.upgradesTo and item.tpId == self.construction.upgradesTo then
                -- Self-upgrade: delegate to UpgradeBehavior (Rule B4).
                self:UpgradeBehaviorStart()
                WaitUntil(function()
                    return self.dead or not self.upgradeBehaviorIsActive
                end)
                -- The upgrade may have completed -- in which case OnStopBeingBuilt on the
                -- upgrade unit Deletes us and this thread will not iterate again.
            else
                self:ProductionBehaviorBuildOne(item)
            end
        end
    end

    self:ProductionBehaviorStop()
end

---@protected Build a single non-upgrade item from the head of the queue.
---@param item table Head build queue item (tpId, entryIds).
function HostFactory:ProductionBehaviorBuildOne(item)
    -- Keep the queue intact while waiting for unit cap space.
    while not self.dead and (self:GetPause() or not self.army:HasUnitCapSpace()) do
        WaitTicks(5)
    end
    if self.dead then return end
    self.unitBeingBuiltSource = self.unitBeingBuiltSource or self

    local spawnPoint = self:GetConstructionSpawnPoint()
    local unit = CreateUnit(self.army.id, item.tpId, spawnPoint, nil, 0.0)
    self.productionBehaviorTargetUnit = unit

    -- Build loop: suspend across pause, exit on completion / death.
    while not unit:IsCompleted() and not unit.dead and not self.dead do

        -- Hold until unpaused (or the unit died / completed via an assister).
        WaitUntil(function()
            return self.dead or unit.dead or unit:IsCompleted() or not self:GetPause()
        end)

        if self.dead or unit.dead or unit:IsCompleted() then break end

        self:StartBuildRoutine(unit)

        -- Build until paused, or the routine ends (process completes / target dies).
        WaitUntil(function()
            return self:GetPause() or not self:IsBuilding(unit)
        end)

        -- End our contribution if the process did not already (Rule R1).
        if self:IsBuilding(unit) then
            self:EndBuildRoutine(unit)
        end
    end

    if unit:IsCompleted() then
        self:CompleteBuildQueueItem(1)
        buildQueueUtils.CleanUpAndMergeQueueItems(self)
        self:SendUpdateBuildQueueCommand()
        if unit:HasTags(Tags.MOBILE) then
            self:RollOffUnit(unit)
        end
        self.productionBehaviorTargetUnit = nil
        self.unitBeingBuiltSource = nil
        -- Hold for the roll-off animation window before kicking off the next build.
        WaitSeconds(2)
    else
        -- The unit died (or factory is dying). The death path handles deletion;
        -- leave the queue item in place so the next iteration can retry.
        self.productionBehaviorTargetUnit = nil
        self.unitBeingBuiltSource = nil
    end
end

function HostFactory:ProductionBehaviorStop()
    if not self.productionBehaviorIsActive then return end

    self:SetRotatorsEnabled(false)

    -- This behavior owns the build routine on the in-progress target (Rule B2).
    local target = self.productionBehaviorTargetUnit
    if target and self:IsBuilding(target) then
        self:EndBuildRoutine(target)
    end

    -- Stop the sub-behavior in case we were running a self-upgrade.
    self:UpgradeBehaviorStop()

    if self.productionBehaviorThread then
        KillThread(self.productionBehaviorThread)
        self.productionBehaviorThread = nil
    end
    self.productionBehaviorIsActive = false

    -- Factories have historically deleted partial unit builds on abort (the old
    -- HostFactory:OnStopBuildRoutine did this). Preserve that: on an external stop,
    -- delete any non-upgrade partial the behavior was driving.
    if target and not self.dead
       and not target.dead
       and not target.deleted
       and not target:IsCompleted()
    then
        target:Delete()
    end

    self.productionBehaviorTargetUnit = nil
    self.unitBeingBuiltSource = nil
end

-- Factory upgrade cancellation has historically deleted the partial upgrade unit
-- (the old HostFactory:OnStopBuildRoutine did this for any non-completed target).
-- Preserve that by extending HostStructure:UpgradeBehaviorStop with the deletion.
function HostFactory:UpgradeBehaviorStop()
    if not self.upgradeBehaviorIsActive then return end

    local upgrade = self.upgradeBehaviorTargetUnit
    HostStructure.UpgradeBehaviorStop(self)

    if upgrade and not self.dead
       and not upgrade.dead
       and not upgrade.deleted
       and not upgrade:IsCompleted()
    then
        upgrade:Delete()
    end
end

-- Empty hooks. The thread owns the pause transition via GetPause() polling.
function HostFactory:OnPauseProduction() end
function HostFactory:OnUnpauseProduction() end

---@protected Get the spawn position for a unit being constructed by this factory.
---@return float3 spawnPoint World position of the factory's platform bone, or the template roll-off offset if it has none.
function HostFactory:GetConstructionSpawnPoint()
    if self.platformBone then
        local _, platformPosition = Engine.GetGlobalEntityWorldPosition(self.platformBone)
        return platformPosition
    end

    -- Fallback for factories without a platform bone: offset from the factory by the first roll-off point.
    local tpRollOff = self.tp.construction.rollOffPoints[1].offset
    local rollOffPoint = self:GetPosition()
    rollOffPoint.x = rollOffPoint.x + tpRollOff.x
    rollOffPoint.y = rollOffPoint.y + tpRollOff.y
    rollOffPoint.z = rollOffPoint.z + tpRollOff.z
    return rollOffPoint
end

---@protected Tell a unit to move to the rally point.
---@param targetUnit HostUnit The unit to rolloff.
function HostFactory:RollOffUnit(targetUnit)
    -- todo: if factory was paused and engineer finished it, there is no roll off

    -- choose if using this rally point or master factory
    local source = self.unitBeingBuiltSource or self
    local tpRollOff = source.tp.construction.rollOffPoints[1].offset
    local rollOffPoint = source.rallyPoint
    if rollOffPoint == nil then
        rollOffPoint = source:GetPosition()
        rollOffPoint.x = rollOffPoint.x + tpRollOff.x
        rollOffPoint.y = rollOffPoint.y + tpRollOff.y
        rollOffPoint.z = rollOffPoint.z + (tpRollOff.z * 2)
    end

    HostOrderManager.HostIssueOrder(OrderTasks.MOVE, {targetUnit}, false, rollOffPoint, nil)
end

function HostFactory:SetRallyPoint(position)
    self.rallyPoint = position
end

---comment
---@return integer
---@return unknown
---@return Factory assistedFactory
function HostFactory:GetNextInMasterFacBuildQueue()
    local assistedFac = self.masterFactory
    local checkedFactories = { } -- avoid infinite loops when factory assists its own assister

    repeat

        checkedFactories[assistedFac] = true

        for index, queueItem in ipairs(assistedFac.buildQueue) do

            local canBuild = true

            -- its not an upgrade
            if queueItem.tpId == self.construction.upgradesTo then canBuild = false end

            -- this type of factory can build it (eg t1 slave cant build t2 units of t2 master)
            if not buildQueueUtils.CanBuild(self, queueItem.tpId) then canBuild = false end

            -- dont build items already under construction by the master, unless its a repeating single item
            local isMasterWorkingOnThis =
                index == 1 and -- first item
                #queueItem.entryIds == 1 and -- with a count of 1 inside it
                assistedFac:IsBuildRoutineEnabled()  -- master is working on something, must be this

            local isRepeatingSingleItem =
                #assistedFac.buildQueue == 1 and
                assistedFac:GetRepeatBuild()

            if isMasterWorkingOnThis and not isRepeatingSingleItem then
                canBuild = false
            end

            if canBuild then
                return index, queueItem, assistedFac
            end
        end

        -- check next factory in the assistance chain. dont allow infinite recursive loops
        assistedFac = assistedFac.masterFactory

    until assistedFac == nil or checkedFactories[assistedFac] == true

    return nil, nil, nil
end

--------------------
-- Air Factory class
--------------------

---@class HostAirFactory: HostFactory
HostAirFactory = Class("AirFactory", HostFactory)



---------------------
-- Land Factory class
---------------------

---@class HostLandFactory: HostFactory
HostLandFactory = Class("LandFactory", HostFactory)



----------------------
-- Naval Factory class
----------------------

---@class HostNavalFactory: HostFactory
HostNavalFactory = Class("NavalFactory", HostFactory)

HostNavalFactory.DefaultTargetingLayer = Layers.TargetingLayer.WaterSurface
HostNavalFactory.DefaultIsInWater = true



------------------------
-- Alloy Extractor class
------------------------

---@class HostAlloyExtractor: HostStructure
HostAlloyExtractor = Class("AlloyExtractor", HostStructure)

function HostAlloyExtractor:PauseProduction()
    local ent = self.resourceEntities.production
    ent:SetResources({}, {})
end

function HostAlloyExtractor:UnPauseProduction()
    local tpEco = self.tp.economy
    local ent = self.resourceEntities.production
    ent:SetResources(tpEco.production, tpEco.maintenanceConsumption)
end



-------------------
-- Energy Generator
-------------------

---@class HostEnergyGenerator: HostStructure
HostEnergyGenerator = Class("EnergyGenerator", HostStructure)



--------------------
-- Mobile Unit class
--------------------

---@class HostMobileUnit: HostUnit
HostMobileUnit = Class("MobileUnit", HostUnit)

local HullWaterSensorName = "HullWaterSensor"

function HostMobileUnit:__init(id, army, template, progress, builder)
    HostUnit.__init(self, id, army, template, progress, builder)

    self:SetUpWaterSensors()
end

---@protected Picks up the hull water sensor, if the template declares one in `movement.hullWaterSensor`.
---Only a hull that can go under the surface needs one; weapon sensors are registered by the weapons
---themselves, since those are declared per weapon.
function HostMobileUnit:SetUpWaterSensors()
    local sensorID = self:GetBoneId(HullWaterSensorName)
    if sensorID then
        self.hullWaterSensorIndex = sensorID.index
    end
end

---@public The unit's hull crossed the surface. Default is the amphibious/seabed walker rule: fully
---under means it is only reachable by what is underwater with it. Submarines override this.
---@param isUnderWater boolean True when fully submerged.
function HostMobileUnit:OnHullCrossedWaterline(isUnderWater)
    self:SetTargetingLayer(isUnderWater and Layers.TargetingLayer.Seabed or Layers.TargetingLayer.Land)
    self:SetInWater(isUnderWater)
    self:SetUnderWater(isUnderWater)
end

function HostMobileUnit:PromoteToUnit()
    HostUnit.PromoteToUnit(self)

    if self:HasTags(Tags.TECH4) or self:HasTags(Tags.TECH5) then
        self:SetNavmapModifiersEnabled(true)
        Engine.SetGlobalGridModifierEnabled(self.id, true)
    end
end

function HostMobileUnit:OnStopBeingBuilt()
    HostUnit.OnStopBeingBuilt(self)
    Engine.SetMovementEnabled(self.id, true)

    if self:HasTags(Tags.TECH4) or self:HasTags(Tags.TECH5) then
        self:SetNavmapModifiersEnabled(false)
        Engine.SetGlobalGridModifierEnabled(self.id, false)
    end
end



-----------------
-- Air Unit class
-----------------

---@class HostAirUnit: HostMobileUnit
HostAirUnit = Class("AirUnit", HostMobileUnit)

HostAirUnit.DefaultTargetingLayer = Layers.TargetingLayer.Land + Layers.TargetingLayer.LandedAir
HostAirUnit.GroundedNavigationLayerName = "Land"
HostAirUnit.IsAutoLandEnabled = false

---@param id GlobalID
---@param army integer
---@param template UnitTemplate
---@param progress number Build progress, 0 to 1
---@param builder any Unused
function HostAirUnit:__init(id, army, template, progress, builder)
    HostMobileUnit.__init(self, id, army, template, progress, builder)
    self.isAirborne = false
end

---Moves the aircraft onto its airborne navigation and targeting layers and applies its template's flight movement settings.
function HostAirUnit:SetAirborneLayers()
    self:SetNavigationLayer(self.tp.general.navigationLayer)
    self:SetTargetingLayer(Layers.TargetingLayer.Air)
    self:SetInWater(false)
    self:SetUnderWater(false)
    local movement = self.tp.movement
    Engine.SetMovementCollisionMask(self.id, movement.collisionMaskDefault)
    Engine.SetMovementReferenceAltitude(self.id, movement.referenceAltitude)
    Engine.SetMovementPreferredAltitude(self.id, movement.preferredAltitude)
    Engine.SetMovementTerrainAlignmentFactor(self.id, movement.terrainAlignmentFactor)
    Engine.SetMovementMaxBankDegrees(self.id, movement.maxBankDegrees)
end

---Moves the aircraft onto its grounded navigation and targeting layers and applies the grounded movement settings.
function HostAirUnit:SetLandedLayers()
    self:SetNavigationLayer(Layers.GetNavigationLayerByName(self.GroundedNavigationLayerName))
    self:SetTargetingLayer(self.DefaultTargetingLayer)
    self:SetInWater(self.DefaultIsInWater)
    self:SetUnderWater(false)
    local groundedConfig = Layers.GroundedMovementConfig
    Engine.SetMovementCollisionMask(self.id, self.tp.movement.collisionMaskSpawn)
    Engine.SetMovementReferenceAltitude(self.id, groundedConfig.referenceAltitude)
    Engine.SetMovementPreferredAltitude(self.id, groundedConfig.preferredAltitude)
    Engine.SetMovementTerrainAlignmentFactor(self.id, groundedConfig.terrainAlignmentFactor)
    Engine.SetMovementMaxBankDegrees(self.id, groundedConfig.maxBankDegrees)
end

---Returns whether the aircraft can take off, which it can only do while landed.
---@return boolean
function HostAirUnit:TakeoffBehaviorIsValidFor()
    return self.isAirborne == false
end

---Returns whether the aircraft is above water.
---@return boolean
function HostAirUnit:IsOverWater()
    local waterLevel = Water.GetLevel()
    if waterLevel == nil then return false end

    local _, position = Engine.GetGlobalEntityWorldPosition(self.id)
    local _, terrainHeight = Engine.SampleTerrainHeight(position)
    return terrainHeight < waterLevel
end

---Returns whether the ground under the aircraft is passable on its grounded navigation layer.
---@return boolean
function HostAirUnit:IsLandingSpotPassable()
    local layerIndex = Layers.GetNavigationLayerByName(self.GroundedNavigationLayerName)
    local _, position = Engine.GetGlobalEntityWorldPosition(self.id)
    local xz = EngineClasses.float2(position.x, position.z)
    local errorCode, result = Engine.NavmapLineCast(xz, xz, layerIndex)
    return errorCode == EngineErrorCode.Success and result == NavmapLineCastResult.NoHit
end

---Returns whether the aircraft can land: it is airborne, not over water, and above passable ground.
---@return boolean
function HostAirUnit:LandingBehaviorIsValidFor()
    return self.isAirborne == true and not self:IsOverWater() and self:IsLandingSpotPassable()
end

---Returns the ID of the movement pattern the aircraft flies in a situation, or None while it is landed.
---@param situation '"move"'|'"hold"'|'"attack"'|'"assist"'
---@return integer patternID
function HostAirUnit:GetPatternID(situation)
    if not self.isAirborne then return Constants.MovementPatternNone end
    return HostMobileUnit.GetPatternID(self, situation)
end

---Returns whether the aircraft's hold pattern is a Circle pattern, so it never stands still to align.
---@return boolean
function HostAirUnit:CirclesWhenHolding()
    return self:GetPatternMode(self:GetPatternID("hold")) == "Circle"
end

---Called when the aircraft runs out of orders. Holds in place unless it is still aligning, and starts the land-when-idle timer.
function HostAirUnit:OnBecameIdle()
    if not self.isAirborne or self.takeoffBehaviorIsActive then return end
    if not self.alignBehaviorIsActive and not self.moveIntoRangeAwaitingAlign then
        self:Hold()
    end
    if self.landWhenIdleThread then return end
    self.landWhenIdleThread = self:NewThread(self.LandWhenIdleThread)
end

---Waits until the aircraft is built, then lands it after its template's landWhenIdleSeconds if it is still idle and auto-land is enabled.
function HostAirUnit:LandWhenIdleThread()
    WaitUntil(function() return self:IsCompleted() end)

    local seconds = self.tp.movement.landWhenIdleSeconds or 0
    if not self.IsAutoLandEnabled or seconds <= 0 then return end

    WaitSeconds(seconds)
    self.landWhenIdleThread = nil

    if self.orders.activeOrder == nil and #self.orders.queuedOrders == 0
        and self.isAirborne and not self.takeoffBehaviorIsActive then
        self:LandingBehaviorStart()
    end
end

---Stops the land-when-idle timer.
function HostAirUnit:CancelLandWhenIdle()
    if self.landWhenIdleThread then
        KillThread(self.landWhenIdleThread)
        self.landWhenIdleThread = nil
    end
end

---Called once the aircraft is built. It starts landed with movement disabled and takes off.
function HostAirUnit:OnStopBeingBuilt()
    HostMobileUnit.OnStopBeingBuilt(self)
    self.isAirborne = false
    Engine.SetMovementEnabled(self.id, false)
    self:TakeoffBehaviourStart()
end

---Returns whether the aircraft is airborne and not taking off or landing.
---@return boolean
function HostAirUnit:IsReadyToFly()
    return self.isAirborne and not self.takeoffBehaviorIsActive and not self.landingBehaviorIsActive
end

---@class HostAirUnitPendingMovement
---@field situation '"hold"'|'"attack"'|'"assist"' The situation the movement was queued for
---@field targetUnit HostUnit? The unit to pursue
---@field range number? The range to pursue targetUnit at
---@field start fun(self: HostAirUnit, targetUnit: HostUnit, range: number?)? Starts the pursuit
---@field requestedPosition float2? The position to move to
---@field goalRadius number?
---@field alignDirection float2? Direction to face on arrival, or nil to not align
---@field brakeOnApproach boolean?

---Stores a movement to start once the aircraft is airborne, replacing any already stored, and starts the thread that takes off and runs it.
---@param pending HostAirUnitPendingMovement
function HostAirUnit:QueuePendingMovement(pending)
    self.pendingMovement = pending

    if not self.pendingMovementThread then
        self.pendingMovementThread = self:NewThread(self.PendingMovementThread)
    end
end

---Drops the stored movement if it was queued for the situation.
---@param situation '"hold"'|'"attack"'|'"assist"'
function HostAirUnit:CancelPendingMovement(situation)
    local pending = self.pendingMovement
    if pending == nil or pending.situation ~= situation then return end

    self.pendingMovement = nil
    if self.pendingMovementThread then
        KillThread(self.pendingMovementThread)
        self.pendingMovementThread = nil
    end
end

---Waits until the aircraft is built and not landing, takes off, then starts the stored movement.
function HostAirUnit:PendingMovementThread()
    WaitUntil(function() return self:IsCompleted() end)

    WaitUntil(function() return not self.landingBehaviorIsActive end)

    self:TakeoffBehaviourStart()
    WaitUntil(function() return self.isAirborne and not self.takeoffBehaviorIsActive end)

    local pending = self.pendingMovement
    self.pendingMovement = nil
    self.pendingMovementThread = nil
    if pending == nil then return end

    if pending.targetUnit then
        if not pending.targetUnit.dead then
            pending.start(self, pending.targetUnit, pending.range)
        end
        return
    end

    self.moveIntoRangeBehaviorIsActive = false
    self.moveIntoRangeAwaitingAlign = nil
    self.moveIntoRangeAlignIssued = nil
    HostMobileUnit.MoveIntoRangeBehaviorStart(self, pending.requestedPosition, pending.goalRadius, pending.alignDirection, pending.brakeOnApproach)

    if not self.moveIntoRangeBehaviorIsActive then
        self:MoveIntoRangeBehaviorEnteredRange(MovementEventType.Arrived)
    end
end

---Starts pursuing a unit now if the aircraft is ready to fly, otherwise once it has taken off.
---@param targetUnit HostUnit
---@param range number?
---@param situation '"attack"'|'"assist"'
---@param start fun(self: HostAirUnit, targetUnit: HostUnit, range: number?) Starts the pursuit
function HostAirUnit:StartPursuit(targetUnit, range, situation, start)
    self:CancelLandWhenIdle()

    if self:IsReadyToFly() then
        start(self, targetUnit, range)
        return
    end

    self:QueuePendingMovement({ situation = situation, targetUnit = targetUnit, range = range, start = start })
end

---Moves to a position now if the aircraft is ready to fly, otherwise once it has taken off.
---@param requestedPosition float2
---@param goalRadius number
---@param alignDirection float2? Direction to face on arrival, or nil to not align
---@param brakeOnApproach boolean?
function HostAirUnit:MoveIntoRangeBehaviorStart(requestedPosition, goalRadius, alignDirection, brakeOnApproach)
    self:CancelLandWhenIdle()

    if self:IsReadyToFly() then
        HostMobileUnit.MoveIntoRangeBehaviorStart(self, requestedPosition, goalRadius, alignDirection, brakeOnApproach)
        return
    end

    self.moveIntoRangeBehaviorIsActive = true
    self:QueuePendingMovement({ situation = "hold", requestedPosition = requestedPosition, goalRadius = goalRadius, alignDirection = alignDirection, brakeOnApproach = brakeOnApproach })
end

---Changes whether the move brakes into its destination, applying it to the stored move if it has not started yet.
---@param brakeOnApproach boolean
function HostAirUnit:SetMoveIntoRangeBrakeOnApproach(brakeOnApproach)
    local pending = self.pendingMovement
    if pending then
        if pending.situation == "hold" then
            pending.brakeOnApproach = brakeOnApproach
        end
        return
    end
    HostMobileUnit.SetMoveIntoRangeBrakeOnApproach(self, brakeOnApproach)
end

---Drops a stored move and stops the active one.
function HostAirUnit:MoveIntoRangeBehaviorStop()
    self:CancelPendingMovement("hold")
    HostMobileUnit.MoveIntoRangeBehaviorStop(self)
end

--# attack behaviour ==================
---Fraction of weapon range a Strafe attack pattern engages at.
local StrafeDesiredRangeFraction = 0.8
---Multiple of the turn radius an aircraft without weapons attacks from.
local NoWeaponDesiredRangeScale = 3
---Multiple of attack range searched for targets to engage.
local EngageAcquireRangeScale = 2.0
---Range an aircraft follows at when none is given, in world units.
local DefaultAssistRadius = 10

---Returns the aircraft's turn radius at top speed, in world units.
---@return number
function HostAirUnit:GetTurnRadius()
    return self.tp.movement.speed / math.rad(self.tp.movement.rotationSpeed)
end

---Returns the range the aircraft attacks from: its weapon range, scaled down for a Strafe pattern, or a multiple of its turn radius if it has no weapons.
---@param patternID integer The attack pattern ID
---@param range number? Weapon range, defaulting to the unit's attack range
---@return number radius
function HostAirUnit:GetAttackRadius(patternID, range)
    range = range or self.attackRange

    local radius = self:GetTurnRadius() * NoWeaponDesiredRangeScale
    if range > 0 then
        radius = self:GetPatternMode(patternID) == "Strafe" and range * StrafeDesiredRangeFraction or range
    end

    return radius
end

---Moves to a unit with the attack patterns, holding the attack radius from it.
---@param targetUnit HostUnit
---@param range number? Weapon range, defaulting to the unit's attack range
function HostAirUnit:PursueTarget(targetUnit, range)
    local attackID = self:GetPatternID("attack")
    self:SetMovementPatterns("attack")
    Engine.MovementMoveToTarget(self.id, targetUnit.id, self:GetAttackRadius(attackID, range))
end

---Follows a unit with the assist patterns.
---@param targetUnit HostUnit
---@param range number? Range to follow at, defaulting to DefaultAssistRadius
function HostAirUnit:AssistTarget(targetUnit, range)
    self:SetMovementPatterns("assist")
    Engine.MovementMoveToTarget(self.id, targetUnit.id, range or DefaultAssistRadius)
end

---Starts pursuing an attack target now if the aircraft is ready to fly, otherwise once it has taken off.
---@param targetUnit HostUnit
---@param range number?
function HostAirUnit:AttackBehaviorMoveStart(targetUnit, range)
    self:StartPursuit(targetUnit, range, "attack", self.PursueTarget)
end

function HostAirUnit:AttackBehaviorMoveStop()
    self:CancelPendingMovement("attack")
end

function HostAirUnit:AttackBehaviorStop()
    HostMobileUnit.AttackBehaviorStop(self)
    self:Hold()
end

function HostAirUnit:FollowBehaviorStart(targetUnit, range)
    if not self:FollowBehaviorIsValidFor(targetUnit, range) then return end

    self.followBehaviorIsActive = true
    self.followBehaviorTargetUnit = targetUnit
    self.followBehaviorRange = range
    self:StartPursuit(targetUnit, range, "assist", self.AssistTarget)
end

function HostAirUnit:FollowBehaviorStop()
    local wasFollowing = self.followBehaviorIsActive

    self:CancelPendingMovement("assist")
    self.followBehaviorIsActive = false
    self.followBehaviorTargetUnit = nil
    self.followBehaviorRange = nil

    if wasFollowing then
        self:Hold()
    end
end

function HostAirUnit:CanEngage(unit)
    if not unit or unit.dead or not unit.isTargetable then
        return false
    end
    if not self.army:IsEnemy(unit.army) then
        return false
    end
    for _, weapon in ipairs(self.weapons) do
        if weapon:CanShootAt(unit) then
            return true
        end
    end
    return false
end

function HostAirUnit:DistanceToUnit(unit)
    return math3D.distanceToFloat2(self:GetPosition(), math3D.tofloat2(unit:GetPosition()))
end

function HostAirUnit:FindNearestEngageableUnit(radius)
    local nearest = nil
    local nearestDistance = radius
    for _, unit in ipairs(FilterEntitiesAroundPosition(self:GetPosition(), radius, __Entities.Units)) do
        if unit ~= self and self:CanEngage(unit) then
            local distance = self:DistanceToUnit(unit)
            if distance <= nearestDistance then
                nearest = unit
                nearestDistance = distance
            end
        end
    end
    return nearest
end

function HostAirUnit:AttackMoveEngageTargets()
    local target = self:GetMainWeaponTarget()
    while target ~= nil do
        local pursuing = false

        while not target.dead and target.isTargetable and self.army:IsEnemy(target.army) do
            if self.isAirborne and not pursuing then
                self:PursueTarget(target)
                self:SetWeaponPreferredTarget(target)
                pursuing = true
            end
            WaitTicks(1)
        end

        WaitTicks(1)

        target = self:GetMainWeaponTarget()
        if target == nil and self.isAirborne then
            target = self:FindNearestEngageableUnit(self.attackRange * EngageAcquireRangeScale)
        end
    end

    self:SetWeaponPreferredTarget(nil)
    self:Hold()
end

--# takeoff / landing behaviour ==================
-- Only aircraft take off and land; these behaviors transition the unit between its grounded and
-- airborne layers (see SetLandedLayers / SetAirborneLayers) with a vertical curve.

function HostAirUnit:TakeoffBehaviourStart()
    if not self:TakeoffBehaviorIsValidFor() then
        return
    end

    if self.takeoffBehaviorIsActive then return end

    self:LandingBehaviorStop()

    self.takeoffBehaviorIsActive = true
    self.takeoffBehaviorThread = self:NewThread(self.TakeoffBehaviorThread)
end

function HostAirUnit:TakeoffBehaviorThread()
    WaitUntil(function() return self:IsCompleted() end)

    self.isAirborne = true
    self:SetAirborneLayers()
    Engine.SetMovementEnabled(self.id, false)

    local _, position = Engine.GetGlobalEntityWorldPosition(self.id)
    local _, targetAltitude = Engine.GetMovementCurrentAltitude(self.id)

    local _, forward = Engine.GetGlobalEntityForwardDirection(self.id)
    local uprightRotation = Engine.QuaternionLookRotationSafe(
        math3D.normalize(EngineClasses.float3(forward.x, 0, forward.z)),
        EngineClasses.float3(0, 1, 0))

    local curve = Curve.Play(self, {
        duration = 1.5,
        position = {
            mode = Curve.Absolute,
            y = Curve.EaseInOut(position.y, targetAltitude),
        },
        rotation = { target = uprightRotation, ease = Curve.Ease.EaseInOut },
    });

    while not curve:Update() do
        WaitTicks(1)
    end

    Engine.SetMovementEnabled(self.id, true)

    self:TakeoffBehaviourStop()

    if self.orders.activeOrder == nil and #self.orders.queuedOrders == 0 then
        self:OnBecameIdle()
    end
end

function HostAirUnit:TakeoffBehaviourStop()
    if not self.takeoffBehaviorIsActive then
        return
    end

    self.takeoffBehaviorIsActive = false

    if self.takeoffBehaviorThread then
        KillThread(self.takeoffBehaviorThread)
        self.takeoffBehaviorThread = nil
    end
end

function HostAirUnit:LandingBehaviorStart()
    if not self:LandingBehaviorIsValidFor() then
        return
    end

    if self.landingBehaviorIsActive then return end

    self:TakeoffBehaviourStop()

    self.landingBehaviorIsActive = true
    self.landingBehaviorThread = self:NewThread(self.LandingBehaviorThread)
end

function HostAirUnit:LandingBehaviorThread()
    WaitUntil(function() return self:IsCompleted() end)

    Engine.SetMovementEnabled(self.id, false)

    local _, position = Engine.GetGlobalEntityWorldPosition(self.id)
    local _, terrainHeight = Engine.SampleTerrainHeight(position)

    local _, forward = Engine.GetGlobalEntityForwardDirection(self.id)
    local _, landedRotation = Engine.GetTerrainAlignedRotation(forward, EngineClasses.float2(position.x, position.z))

    local curve = Curve.Play(self, {
        duration = 1.5,
        position = {
            mode = Curve.Absolute,
            y = Curve.EaseInOut(position.y, terrainHeight),
        },
        rotation = { target = landedRotation, ease = Curve.Ease.EaseInOut },
    });

    while not curve:Update() do
        WaitTicks(1)
    end

    self.isAirborne = false
    self:SetLandedLayers()

    self:Hold()

    Engine.SetMovementEnabled(self.id, true)

    self:LandingBehaviorStop()
end

function HostAirUnit:LandingBehaviorStop()
    if not self.landingBehaviorIsActive then
        return
    end

    self.landingBehaviorIsActive = false

    if self.landingBehaviorThread then
        KillThread(self.landingBehaviorThread)
        self.landingBehaviorThread = nil
    end
end

---@param overkillRatio number
function HostAirUnit:OnSpawnWreckage(overkillRatio)
    if not self.isAirborne then
        return HostUnit.OnSpawnWreckage(self, overkillRatio)
    end

    WreckCrash.StartWreckCrash(self, overkillRatio, false)
end

------------------
-- Land Unit class
------------------

---@class HostLandUnit: HostMobileUnit
HostLandUnit = Class("LandUnit", HostMobileUnit)



-------------------
-- Naval Unit class
-------------------

---@class HostNavalUnit: HostMobileUnit
HostNavalUnit = Class("NavalUnit", HostMobileUnit)

HostNavalUnit.DefaultTargetingLayer = Layers.TargetingLayer.WaterSurface
HostNavalUnit.DefaultIsInWater = true

---@param overkillRatio number
function HostNavalUnit:OnSpawnWreckage(overkillRatio)
    local hasWater = Water.HasWater()

    if not hasWater then
        return HostUnit.OnSpawnWreckage(self, overkillRatio)
    end

    WreckCrash.StartWreckCrash(self, overkillRatio, true)
end


---@class HostSubmarineUnit: HostNavalUnit
HostSubmarineUnit = Class("SubmarineUnit", HostNavalUnit)

HostSubmarineUnit.GroundedNavigationLayerName = "Sea"

function HostSubmarineUnit:__init(id, army, template, progress, builder)
    HostNavalUnit.__init(self, id, army, template, progress, builder)
    self.isSurfaced = true
end

local SubmarineTransitTargetingLayers = Layers.TargetingLayer.WaterSurface + Layers.TargetingLayer.Water

---@private Applied by the hull sensor once the hull is fully clear of the water.
function HostSubmarineUnit:SetSurfacedLayers()
    self:SetNavigationLayer(Layers.GetNavigationLayerByName(self.GroundedNavigationLayerName))
    Engine.SetMovementCollisionMask(self.id, self.tp.movement.collisionMaskSpawn)
    Engine.SetMovementMaxBankDegrees(self.id, self.tp.movement.maxBankDegrees)
end

---@private Applied by the hull sensor once the hull is fully submerged.
function HostSubmarineUnit:SetSubmergedLayers()
    self:SetNavigationLayer(self.tp.general.navigationLayer)
    Engine.SetMovementCollisionMask(self.id, self.tp.movement.collisionMaskDefault)
    Engine.SetMovementMaxBankDegrees(self.id, 0)
end

---The hull crossed the surface.
---@param isUnderWater boolean True when the hull is fully submerged.
function HostSubmarineUnit:OnHullCrossedWaterline(isUnderWater)
    if isUnderWater then
        self:SetSubmergedLayers()
        self:SetTargetingLayer(Layers.TargetingLayer.Water)
        self:SetUnderWater(true)
        return
    end

    self:SetSurfacedLayers()
    self:SetUnderWater(false)

    if not self.surfaceBehaviorIsActive then
        self:SetTargetingLayer(Layers.TargetingLayer.WaterSurface)
    end
end

function HostSubmarineUnit:DiveBehaviorIsValidFor()
    local hasWater = Water.HasWater()
    return hasWater and (self.isSurfaced or self.surfaceBehaviorIsActive == true)
end

function HostSubmarineUnit:SurfaceBehaviorIsValidFor()
    return not self.isSurfaced
end

function HostSubmarineUnit:SetSubmerged(value)
    if value then
        if self:DiveBehaviorStart() then
            return true
        end

        return not self.isSurfaced
    end

    self:SurfaceBehaviorStart()
    
    return false
end

function HostSubmarineUnit:DiveBehaviorStart()
    if self.diveBehaviorIsActive then return true end
    if not self:DiveBehaviorIsValidFor() then return false end

    self:SurfaceBehaviorStop()

    self.diveBehaviorIsActive = true
    self.isSurfaced = false

    self:SetTargetingLayer(SubmarineTransitTargetingLayers)
    Engine.SetMovementReferenceAltitude(self.id, ReferenceAltitude.Water)
    Engine.SetMovementPreferredAltitude(self.id, self.tp.movement.submergedAltitude)

    return true
end

function HostSubmarineUnit:DiveBehaviorStop()
    self.diveBehaviorIsActive = false
end

function HostSubmarineUnit:SurfaceBehaviorStart()
    if not self:SurfaceBehaviorIsValidFor() then return end
    if self.surfaceBehaviorIsActive then return end

    self:DiveBehaviorStop()

    self.surfaceBehaviorIsActive = true

    self:SetTargetingLayer(SubmarineTransitTargetingLayers)
    Engine.SetMovementPreferredAltitude(self.id, 0)
end

function HostSubmarineUnit:SurfaceBehaviorStop()
    self.surfaceBehaviorIsActive = false
end

function HostSubmarineUnit:OnAltitudeReached()
    if self.surfaceBehaviorIsActive then
        self.isSurfaced = true
        self:SurfaceBehaviorStop()

        self:SetTargetingLayer(Layers.TargetingLayer.WaterSurface)
        Engine.SetMovementReferenceAltitude(self.id, ReferenceAltitude.GroundOrWater)
    end

    self:DiveBehaviorStop()
end



-----------------
-- Engineer class
-----------------

---@class HostEngineer: HostMobileUnit
HostEngineer = Class("Engineer", HostMobileUnit)

function HostEngineer:__init(id, army, template, progress, builder)
    HostMobileUnit.__init(self, id, army, template, progress, builder)
    self.buildQueue = {} -- List of tps to build: [i] = {tpId = "unitID", count = int, position = float3},

    --[[
    self.buildQueue = {
        [1] =  {tpId = "FactoryLandT3_01", count = 1, position = float3(20, 0, 20)}
    }
    --]]
end

function HostEngineer:OnStopBuilding(targetUnit)
    self:RemoveFromBuildQueue(1, false)

    HostMobileUnit.OnStopBuilding(self, targetUnit)
end

function HostEngineer:AddToBuildQueue(tpId, position)
    if not buildQueueUtils.CanBuild(self, tpId) then
        Warn("Engineer: "..self.id.." can't build tpId: "..tpId)
        return
    end

    table.insert(self.buildQueue, {tpId = tpId, position = position})
end

function HostEngineer:RemoveFromBuildQueue(position, repeatBuild)
    if not self.buildQueue[position] then
        --Warn("Build queue: trying to remove from position: "..position.." but the build queue is only "..#self.buildQueue.." long!")
        return
    end

    -- Remove the required element
    local last = table.remove(self.buildQueue, position)
end

function HostEngineer:ClearBuildQueue()
    if not self.buildQueue[1] then
        return
    end

    -- TODO: Stop the current build
    self.buildQueue = {}
end

function HostEngineer:GetNextInBuildQueue()
    if not self.buildQueue[1] then
        return false
    end

    return self.buildQueue[1].tpId, self.buildQueue[1].position
end

-----------------
-- Commander class
-----------------

---@class HostCommander: HostEngineer
HostCommander = Class("Commander", HostEngineer)

function HostCommander:OnStopBeingBuilt()
    local tpEco = self.tp.economy
    if tpEco.storage then
        self:GetEconomy():AddStorage(self.id, tpEco.storage)
        for name, amount in pairs(tpEco.storage) do
            Armies[self.army.id]:GiveResources(name, amount / 2)
        end
    end

    HostEngineer.OnStopBeingBuilt(self)
end

---comment
---@param overkillRatio number
---@param destroyType DestroyType?
function HostCommander:Destroy(overkillRatio, destroyType, instigator)
    HostUnit.Destroy(self, overkillRatio, destroyType, instigator)
    local lobbyInfo = Armies[self.army.id].lobbyOptions

    if lobbyInfo == nil or lobbyInfo.playerName == nil then
        SessionCommands.AddLog.Send("Commander destroyed: Army " .. self.army.id)
    else
        SessionCommands.AddLog.Send("Commander destroyed: " .. lobbyInfo.playerName)
    end

    self.army:Destroy()
end

function HostCommander:DashBehaviorIsValidFor()
    return self:CanMove()
end


-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1
-- Engine.PlayAnimation normally owns clip time. The coordinator's native
-- bridge recognizes this negative cross-fade range as an exact, replicated
-- authored frame instead, so a source structure follows its upgrade target.
local ProgressAnimationSentinelBase = -10000
local ProgressAnimationSentinelMaximumDuration = 1000
local ProgressAnimationEpsilon = 0.000001
-- Imported clips are authored at a low visible frame rate. Sampling more
-- often only repeats native animation bridge calls between visible frames.
local ProgressAnimationSampleIntervalSeconds = 0.1
local mathAbs = math.abs
local mathMax = math.max
local mathMin = math.min

-- Current Sanctuary names this base HostUnit; older builds exposed
-- Unit. Keep one explicit compatibility binding rather than assuming
-- either global is present.
local SCOProgressAnimationUnit = HostUnit or Unit
if not SCOProgressAnimationUnit then
    error("SCO progress animation bridge could not resolve the host unit base class.")
end

local StockUnitOnStartUpgrading = SCOProgressAnimationUnit.OnStartUpgrading
local StockUnitOnEndUpgrading = SCOProgressAnimationUnit.OnEndUpgrading
local StockUnitPromoteToUnit = SCOProgressAnimationUnit.PromoteToUnit
local StockUnitUpdateAnimations = SCOProgressAnimationUnit.UpdateAnimations

-- Imported factory children occupy custom hull geometry while they build.
-- Stock promotion enables their collider once; make that one transition
-- respect the owning factory instead of polling the native bridge each tick.
if not _G.SupremeCommanderOverhaulFactoryColliderPromotionHookInstalled then
    _G.SupremeCommanderOverhaulFactoryColliderPromotionHookInstalled = true
    function SCOProgressAnimationUnit:PromoteToUnit()
        StockUnitPromoteToUnit(self)
        if self.scoFactoryColliderPinOwner ~= nil then
            Engine.SetVolumeColliderEnabled(self.id, false)
        end
    end
end

-- Stock base UpdateAnimations queries Movement before checking whether a
-- run transition even exists. Rest-only imported rigs have no such path,
-- so skip that native query without changing any observable animation.
function SCOProgressAnimationUnit:UpdateAnimations()
    if not self.isAnimated then
        return
    end
    local animations = self.tp.visuals and self.tp.visuals.animations
    if not animations or not animations.run then
        return
    end
    StockUnitUpdateAnimations(self)
end

function SCOProgressAnimationUnit:ProgressBoundUpgradeAnimationThread(targetUnit, animationId, durationSeconds)
    local lastFraction = nil
    while not self.dead
        and not self.deleted
        and not targetUnit.dead
        and not targetUnit.deleted
        and self:IsUpgrading()
        and self.upgradeTarget == targetUnit
    do
        local fraction = mathMin(mathMax(targetUnit:GetFractionComplete(), 0), 1)
        if lastFraction == nil or mathAbs(fraction - lastFraction) > ProgressAnimationEpsilon then
            Engine.PlayAnimation(
                self.id,
                animationId,
                ProgressAnimationSentinelBase + (fraction * durationSeconds)
            )
            lastFraction = fraction
        end
        WaitSeconds(ProgressAnimationSampleIntervalSeconds)
    end

    if self.scoProgressBoundUpgradeTarget == targetUnit then
        self.scoProgressBoundUpgradeThread = nil
    end
end

function SCOProgressAnimationUnit:StartProgressBoundUpgradeAnimation(targetUnit)
    local additions = self.tp.additions
    local binding = additions and additions.progressBoundUpgradeAnimation
    local animations = self.tp.visuals and self.tp.visuals.animations
    local animation = binding and animations and animations[binding.animationKey]
    local durationSeconds = binding and binding.durationSeconds
    if not animation
        or not animation.id
        or type(durationSeconds) ~= "number"
        or durationSeconds <= 0
        or durationSeconds >= ProgressAnimationSentinelMaximumDuration
    then
        return
    end

    if self.scoProgressBoundUpgradeThread then
        KillThread(self.scoProgressBoundUpgradeThread)
    end
    self.scoProgressBoundUpgradeTarget = targetUnit
    self.scoProgressBoundUpgradeRestAnimationKey = binding.restAnimationKey or "walk"
    self.scoProgressBoundUpgradeThread = self:NewThread(
        self.ProgressBoundUpgradeAnimationThread,
        targetUnit,
        animation.id,
        durationSeconds
    )
end

function SCOProgressAnimationUnit:OnStartUpgrading(targetUnit)
    StockUnitOnStartUpgrading(self, targetUnit)
    self:StartProgressBoundUpgradeAnimation(targetUnit)
end

function SCOProgressAnimationUnit:OnEndUpgrading(targetUnit)
    local activeTarget = self.scoProgressBoundUpgradeTarget
    local activeThread = self.scoProgressBoundUpgradeThread
    local restAnimationKey = self.scoProgressBoundUpgradeRestAnimationKey

    StockUnitOnEndUpgrading(self, targetUnit)

    if activeTarget ~= targetUnit then
        return
    end

    if activeThread then
        KillThread(activeThread)
    end
    self.scoProgressBoundUpgradeTarget = nil
    self.scoProgressBoundUpgradeThread = nil
    self.scoProgressBoundUpgradeRestAnimationKey = nil

    if self.dead or self.deleted then
        return
    end

    local animations = self.tp.visuals and self.tp.visuals.animations
    local restAnimation = animations and animations[restAnimationKey]
    if restAnimation and restAnimation.id then
        Engine.PlayAnimation(self.id, restAnimation.id, 0.1)
    end
end


-- Supreme Commander Overhaul FA Air Factories 1.0.0
-- Generic host sampler for authored or script-derived factory build clips.
-- Keep the sampled clock continuous: native rendering interpolates clip time
-- before applying Loop. Resend the held sample during pause because native
-- simulation may still advance its local clock between host samples.
local SCOFaAirFactoryElapsedSentinelBase = -20000
local SCOFaAirFactorySampleSeconds = 0.1
local SCOFaAirFactoryLifecycle = {}

local function SCOFaAirFactoryIsAlive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
end

local function SCOFaAirFactoryIsUpgrade(factory, targetUnit)
    local upgradesTo = factory.tp.construction and factory.tp.construction.upgradesTo
    return upgradesTo ~= nil and targetUnit ~= nil and targetUnit.tpId == upgradesTo
end

function SCOFaAirFactoryLifecycle.BindPlatform(factory)
    local config = factory.tp.additions and factory.tp.additions.faAirFactoryLifecycle
    local boneName = config and config.platformBoneName
    if not boneName then
        error("FA air factory has no source platform-bone contract.")
    end
    local bone = factory:GetBoneId(boneName)
    if not bone then
        error("FA air factory could not resolve source platform bone " .. boneName .. ".")
    end
    factory.platformBone = bone
end

function SCOFaAirFactoryLifecycle.SampleBuildThread(factory, targetUnit, animationId)
    local elapsed = factory.faAirFactoryBuildElapsed or 0
    Engine.PlayAnimation(
        factory.id,
        animationId,
        SCOFaAirFactoryElapsedSentinelBase - elapsed
    )
    while SCOFaAirFactoryIsAlive(factory)
        and SCOFaAirFactoryIsAlive(targetUnit)
        and factory.faAirFactoryBuildTarget == targetUnit
    do
        WaitTicks(1)
        if not factory:GetPause() then
            if not factory:IsBuilding(targetUnit) then
                break
            end
            elapsed = elapsed + Constants.TickTimeStep
            factory.faAirFactoryBuildElapsed = elapsed
        end
        Engine.PlayAnimation(
            factory.id,
            animationId,
            SCOFaAirFactoryElapsedSentinelBase - elapsed
        )
    end
    if factory.faAirFactoryBuildTarget == targetUnit then
        factory.faAirFactoryBuildThread = nil
    end
end

function SCOFaAirFactoryLifecycle.StartBuild(factory, targetUnit)
    if SCOFaAirFactoryIsUpgrade(factory, targetUnit) then
        return
    end
    if factory.faAirFactoryBuildTarget == targetUnit
        and factory.faAirFactoryBuildThread
    then
        return
    end
    SCOFaAirFactoryLifecycle.CancelBuild(factory)
    local config = factory.tp.additions and factory.tp.additions.faAirFactoryLifecycle
    local animations = factory.tp.visuals and factory.tp.visuals.animations
    local animation = animations and animations.build
    local durationSeconds = config and config.buildDurationSeconds
    if not animation or not animation.id or type(durationSeconds) ~= "number" or durationSeconds <= 0 then
        error("FA air factory build-animation contract is incomplete.")
    end
    factory.faAirFactoryBuildTarget = targetUnit
    factory.faAirFactoryBuildElapsed = 0
    factory.faAirFactoryBuildThread = factory:NewThread(
        SCOFaAirFactoryLifecycle.SampleBuildThread,
        targetUnit,
        animation.id
    )
end

function SCOFaAirFactoryLifecycle.CancelBuild(factory)
    if factory.faAirFactoryBuildThread then
        KillThread(factory.faAirFactoryBuildThread)
    end
    factory.faAirFactoryBuildThread = nil
    factory.faAirFactoryBuildTarget = nil
    factory.faAirFactoryBuildElapsed = nil
end

function SCOFaAirFactoryLifecycle.StopBuild(factory, targetUnit)
    if factory.faAirFactoryBuildTarget ~= targetUnit then
        return
    end
    -- Sanctuary brackets a production pause with EndBuildRoutine followed by
    -- StartBuildRoutine.  FA pauses its animator rate at that boundary, so
    -- retain the same sampler thread and elapsed phase until production resumes.
    if factory:GetPause() then
        return
    end
    SCOFaAirFactoryLifecycle.CancelBuild(factory)
    if not SCOFaAirFactoryIsAlive(factory) then
        return
    end
    local config = factory.tp.additions and factory.tp.additions.faAirFactoryLifecycle
    local animations = factory.tp.visuals and factory.tp.visuals.animations
    local rest = animations and animations.walk
    if rest and rest.id then
        Engine.PlayAnimation(factory.id, rest.id, config.returnSeconds or 0.1)
    end
end

_G.SCOFaAirFactoryLifecycle = SCOFaAirFactoryLifecycle
-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0
-- FA CConstructionUnit/TConstructionUnit use one reversible Awheels animator.
-- The coordinator sentinel stores exact clip seconds in currentClipTime and
-- freezes automatic advancement, so interrupted shoreline reversal retains
-- the same authored pose at deterministic simulation ticks.
local SCOFaEngineerWaterSentinelBase = -10000
local SCOFaEngineerWaterEnterDepth = 0.05
local SCOFaEngineerWaterExitDepth = 0.01
local SCOFaEngineerWaterLifecycle = {}

local function SCOFaEngineerWaterAlive(unit)
    return unit ~= nil and not unit.dead and not unit.deleted
end

local function SCOFaEngineerWaterConfig(unit)
    local additions = unit.tp and unit.tp.additions
    return additions and additions.faEngineerWaterAnimation
end

function SCOFaEngineerWaterLifecycle.IsSupported(unit)
    local config = SCOFaEngineerWaterConfig(unit)
    return config ~= nil and config.sourceRate == 1
end

function SCOFaEngineerWaterLifecycle.SetTerrainAlignment(unit, inWater)
    local id = unit.tp and unit.tp.general and unit.tp.general.tpId
    if id ~= "uel1501" and id ~= "uel2501" and id ~= "uel3501" then return end
    local factor = inWater and 0 or unit.tp.movement.terrainAlignmentFactor
    local result = Engine.SetMovementTerrainAlignmentFactor(unit.id, factor)
    if result ~= EngineErrorCode.Success and not unit.scoFaEngineerWaterAlignmentWarned then
        unit.scoFaEngineerWaterAlignmentWarned = true
        Warn("UEF engineer water terrain alignment failed: " .. tostring(result))
    end
end

function SCOFaEngineerWaterLifecycle.Probe(unit, previous, position)
    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success then return nil end
    if not hasWater then return false end
    local levelResult, waterLevel = Engine.GetWaterLevel()
    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return nil end
    local positionResult = Engine.GetGlobalEntityWorldPosition(unit.id, position)
    if positionResult ~= EngineErrorCode.Success then return nil end
    local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)
    if terrainResult ~= EngineErrorCode.Success or terrainHeight == nil then return nil end
    local requiredDepth = previous and SCOFaEngineerWaterExitDepth or SCOFaEngineerWaterEnterDepth
    -- Bathymetry alone misclassifies units standing above submerged terrain.
    if position.y > waterLevel + requiredDepth then return false end
    return terrainHeight < waterLevel - requiredDepth
end

function SCOFaEngineerWaterLifecycle.PlayPose(unit, walk, water, elapsed, inWater)
    if not inWater and elapsed == 0 then
        Engine.PlayAnimation(unit.id, walk.id, 0)
        return
    end
    Engine.PlayAnimation(unit.id, water.id, SCOFaEngineerWaterSentinelBase + elapsed)
end

function SCOFaEngineerWaterLifecycle.SampleThread(unit)
    local config = SCOFaEngineerWaterConfig(unit)
    local animations = unit.tp and unit.tp.visuals and unit.tp.visuals.animations
    local walk = animations and animations.walk
    local water = animations and animations.waterTransform
    if not config or not walk or not walk.id or not water or not water.id
        or type(config.durationSeconds) ~= "number"
        or config.durationSeconds <= 0
        or config.durationSeconds >= 1000
    then
        error("FA engineer water-animation contract is incomplete")
    end

    local elapsed = unit.scoFaEngineerWaterElapsed or 0
    local inWater = unit.scoFaEngineerWaterState or false
    local position = EngineClasses.float3()
    local initialProbe = SCOFaEngineerWaterLifecycle.Probe(unit, inWater, position)
    if initialProbe ~= nil then inWater = initialProbe end
    unit.scoFaEngineerWaterElapsed = elapsed
    unit.scoFaEngineerWaterState = inWater
    SCOFaEngineerWaterLifecycle.SetTerrainAlignment(unit, inWater)
    if not unit.scoFaEngineerWaterSuspended then
        SCOFaEngineerWaterLifecycle.PlayPose(unit, walk, water, elapsed, inWater)
    end

    while SCOFaEngineerWaterAlive(unit) do
        WaitTicks(1)
        if not SCOFaEngineerWaterAlive(unit) then break end
        local probed = SCOFaEngineerWaterLifecycle.Probe(unit, inWater, position)
        if probed ~= nil then
            if probed ~= inWater then
                SCOFaEngineerWaterLifecycle.SetTerrainAlignment(unit, probed)
            end
            inWater = probed
            unit.scoFaEngineerWaterState = inWater
        end

        local previousElapsed = elapsed
        if inWater then
            elapsed = math.min(config.durationSeconds, elapsed + Constants.TickTimeStep)
        else
            elapsed = math.max(0, elapsed - Constants.TickTimeStep)
        end
        unit.scoFaEngineerWaterElapsed = elapsed
        if not unit.scoFaEngineerWaterSuspended
            and (elapsed ~= previousElapsed or unit.scoFaEngineerWaterForceSample)
        then
            unit.scoFaEngineerWaterForceSample = nil
            SCOFaEngineerWaterLifecycle.PlayPose(unit, walk, water, elapsed, inWater)
        end
    end
    unit.scoFaEngineerWaterThread = nil
end

function SCOFaEngineerWaterLifecycle.Stop(unit)
    if unit.scoFaEngineerWaterThread then KillThread(unit.scoFaEngineerWaterThread) end
    if unit.scoFaEngineerWaterRestoreThread then KillThread(unit.scoFaEngineerWaterRestoreThread) end
    if SCOFaEngineerWaterAlive(unit) then
        SCOFaEngineerWaterLifecycle.SetTerrainAlignment(unit, false)
    end
    unit.scoFaEngineerWaterThread = nil
    unit.scoFaEngineerWaterRestoreThread = nil
    unit.scoFaEngineerWaterElapsed = nil
    unit.scoFaEngineerWaterState = nil
    unit.scoFaEngineerWaterSuspended = nil
    unit.scoFaEngineerWaterForceSample = nil
end

function SCOFaEngineerWaterLifecycle.Start(unit)
    if not SCOFaEngineerWaterLifecycle.IsSupported(unit) then return end
    SCOFaEngineerWaterLifecycle.Stop(unit)
    unit.scoFaEngineerWaterElapsed = 0
    unit.scoFaEngineerWaterState = false
    unit.scoFaEngineerWaterThread = unit:NewThread(SCOFaEngineerWaterLifecycle.SampleThread)
end

function SCOFaEngineerWaterLifecycle.Suspend(unit)
    if not SCOFaEngineerWaterLifecycle.IsSupported(unit) then return end
    if unit.scoFaEngineerWaterRestoreThread then KillThread(unit.scoFaEngineerWaterRestoreThread) end
    unit.scoFaEngineerWaterRestoreThread = nil
    unit.scoFaEngineerWaterSuspended = true
end

function SCOFaEngineerWaterLifecycle.RestoreThread(unit, delay)
    WaitSeconds(delay)
    unit.scoFaEngineerWaterRestoreThread = nil
    if not SCOFaEngineerWaterAlive(unit) then return end
    unit.scoFaEngineerWaterSuspended = nil
    unit.scoFaEngineerWaterForceSample = true
end

function SCOFaEngineerWaterLifecycle.ResumeAfter(unit, delay)
    if not SCOFaEngineerWaterLifecycle.IsSupported(unit)
        or not SCOFaEngineerWaterAlive(unit) then return end
    if unit.scoFaEngineerWaterRestoreThread then KillThread(unit.scoFaEngineerWaterRestoreThread) end
    unit.scoFaEngineerWaterRestoreThread = unit:NewThread(
        SCOFaEngineerWaterLifecycle.RestoreThread,
        delay
    )
end

_G.SCOFaEngineerWaterLifecycle = SCOFaEngineerWaterLifecycle


-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0
-- A factory-owned child built inside imported carrier geometry must
-- remain non-colliding when placement promotion ordinarily enables
-- its collider. The mobile factory releases it only after moving it
-- clear. This shared guard is idempotent with the Fatboy patcher.
if not _G.SupremeCommanderOverhaulFactoryColliderPromotionHookInstalled then
    _G.SupremeCommanderOverhaulFactoryColliderPromotionHookInstalled = true
    local scoAeonColliderUnit = HostUnit or Unit
    if not scoAeonColliderUnit then
        error("SCO Aeon collider hook could not resolve the host unit base class")
    end
    local scoStockUnitPromoteToUnit = scoAeonColliderUnit.PromoteToUnit
    function scoAeonColliderUnit:PromoteToUnit()
        scoStockUnitPromoteToUnit(self)
        if self.scoFactoryColliderPinOwner ~= nil then
            Engine.SetVolumeColliderEnabled(self.id, false)
        end
    end
end

-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0
-- Stock Sanctuary aircraft pursue at an orbit-sized standoff. That is a
-- good default for gunships and fighters, but it makes fixed-forward FA
-- surface bombers brake beside the target after their first approach.
-- A zero ingress standoff keeps the source-pinned surface bombers nose-on.
-- Actual bomb creation then issues a forward breakoff leg beyond the target;
-- the stock Arrived callback naturally resumes pursuit. All other air
-- units, including both torpedo bombers, keep the stock behavior. Ahwassa's
-- source DeathImpact damage follows its spawned wreck so it occurs at the
-- later land or water impact instead of at the aircraft's destruction
-- altitude.
local SCO_FaBomberAttackRunEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCO_FaBomberAttackRunInstalled = rawget(
    SCO_FaBomberAttackRunEnvironment,
    "SCO_FaBomberAttackRunInstalled")
if SCO_FaBomberAttackRunInstalled ~= nil
    and SCO_FaBomberAttackRunInstalled ~= "1.0.0"
then
    error("Unsupported SCOM FA bomber attack-run runtime "
        .. tostring(SCO_FaBomberAttackRunInstalled))
end
if SCO_FaBomberAttackRunInstalled == nil then
    if type(HostAirUnit) ~= "table"
        or type(HostAirUnit.GetAttackRadius) ~= "function"
        or type(CreateWreckageFromUnit) ~= "function"
        or type(Engine.GetMovementHeadingDegrees) ~= "function"
        or type(Engine.MovementMove) ~= "function"
        or type(EngineClasses) ~= "table"
        or type(EngineClasses.float2) ~= "function"
    then
        error("SCOM FA bomber air runtime cannot resolve host functions")
    end

    local SCO_FaBomberStockGetAttackRadius =
        HostAirUnit.GetAttackRadius
    local SCO_FaBomberStockCreateWreckageFromUnit =
        CreateWreckageFromUnit
    local SCO_FaBomberAttackRunProfiles = {
        uca1001 = { breakOffDistance = 30, breakOffTrigger = 20 },
        uca3001 = { breakOffDistance = 60, breakOffTrigger = 30 },
        uea1001 = { breakOffDistance = 18, breakOffTrigger = 20 },
        uea3001 = { breakOffDistance = 60, breakOffTrigger = 30 },
        uga1001 = { breakOffDistance = 30, breakOffTrigger = 20 },
        uga3001 = { breakOffDistance = 60, breakOffTrigger = 30 },
        usa1001 = { breakOffDistance = 30, breakOffTrigger = 20 },
        usa2101 = { breakOffDistance = 40, breakOffTrigger = 20 },
        usa3001 = { breakOffDistance = 60, breakOffTrigger = 30 },
        usa4011 = { breakOffDistance = 60, breakOffTrigger = 30 },
    }
    local SCO_FaBomberCrashImpactProfiles = {
        usa4011 = { damage = 10000, radius = 8 },
    }

    local function SCO_FaBomberAttackRunContract(unit)
        local additions = unit and unit.tp and unit.tp.additions
        local contract = additions and additions.scoFaBomberAttackRun
        if contract == nil then return nil end
        local tpId = unit.tp.general and unit.tp.general.tpId
        local profile = SCO_FaBomberAttackRunProfiles[tpId]
        if profile == nil
            or contract.version ~= "1.0.0"
            or contract.sourceBreakOffDistance
                ~= profile.breakOffDistance
            or contract.sourceBreakOffIfNearNewTarget ~= true
            or contract.sourceBreakOffTrigger ~= profile.breakOffTrigger
            or contract.sourceEngageDistance ~= 50
            or contract.runtimePursueStandoff ~= 0
            or contract.runtimeMode ~= "ReleaseBreakOffReentry"
        then
            error("Malformed SCOM FA bomber attack-run contract")
        end
        return contract
    end

    function HostAirUnit:SCO_FaBomberOnBombReleased(projectileId)
        local contract = SCO_FaBomberAttackRunContract(self)
        local target = self.attackBehaviorTargetUnit
        if contract == nil
            or projectileId == nil
            or self.dead == true
            or self.attackBehaviorIsActive ~= true
            or type(target) ~= "table"
            or target.dead == true
            or type(self.GetPosition) ~= "function"
            or type(target.GetPosition) ~= "function"
        then
            return false
        end

        local position = self:GetPosition()
        local targetPosition = target:GetPosition()
        local _, heading = Engine.GetMovementHeadingDegrees(self.id)
        if type(position) ~= "table"
            or type(targetPosition) ~= "table"
            or type(heading) ~= "number"
        then
            return false
        end

        local radians = math.rad(heading)
        local forwardX = math.sin(radians)
        local forwardZ = math.cos(radians)
        local targetForwardDistance =
            (targetPosition.x - position.x) * forwardX
            + (targetPosition.z - position.z) * forwardZ
        local legLength = math.max(
            contract.sourceBreakOffDistance,
            targetForwardDistance + contract.sourceBreakOffDistance)
        local waypoint = EngineClasses.float2(
            position.x + forwardX * legLength,
            position.z + forwardZ * legLength)
        local result = Engine.MovementMove(
            self.id,
            waypoint,
            EngineClasses.float2(0, 0),
            0)
        local success = result == nil
            or result == 0
            or (type(EngineErrorCode) == "table"
                and result == EngineErrorCode.Success)
        if success then
            self.scoFaBomberAttackRunBreakOff = { target = target, waypoint = waypoint }
        end
        return success
    end

    local function SCO_FaBomberCrashImpactContract(unit)
        local additions = unit and unit.tp and unit.tp.additions
        local contract = additions and additions.scoFaBomberCrashImpact
        if contract == nil then return nil end
        local tpId = unit.tp.general and unit.tp.general.tpId
        local profile = SCO_FaBomberCrashImpactProfiles[tpId]
        if unit.tpId == "wra0401" or tpId == "wra0401" then
            local class = unit.tp.general.class
            local source = additions.faSurfaceBomberSourceContract
            if unit.tpId ~= tpId or type(class) ~= "table"
                or class[1] ~= "unitsDefaultSeraphim" or class[2] ~= "SeraphimAirUnit"
                or type(source) ~= "table" or source.sourceUnitId ~= "XSA0402"
                or source.targetUnitId ~= "usa4011"
                or source.sourceBlueprintSha256
                    ~= "19ad26d88df8e9b1e7ae5fbfd680e266d935659a843dea3c6931325b81e799c5"
            then
                error("Aircraft alias Ahwassa crash donor identity drift")
            end
            profile = SCO_FaBomberCrashImpactProfiles.usa4011
        end
        if profile == nil
            or contract.version ~= "1.0.0"
            or contract.sourceUnitId ~= "XSA0402"
            or contract.sourceLabel ~= "DeathImpact"
            or contract.damage ~= profile.damage
            or contract.damageRadius ~= profile.radius
            or contract.damageFriendly ~= true
            or contract.runtimeMode ~= "WreckImpactAreaDamage"
            or unit.army == nil
        then
            error("Malformed SCOM Ahwassa crash-impact contract")
        end
        return contract
    end

    -- Source surface bombers keep release-driven ingress and breakoff. The new
    -- native Strafe goal would start its runout independently of bomb release.
    local SCO_FaBomberStockGetPatternID = HostAirUnit.GetPatternID
    function HostAirUnit:GetPatternID(situation)
        if situation == "attack" and SCO_FaBomberAttackRunContract(self) then
            return 0
        end
        return SCO_FaBomberStockGetPatternID(self, situation)
    end

    local SCO_FaBomberStockAttackBehaviorStop = HostAirUnit.AttackBehaviorStop
    function HostAirUnit:AttackBehaviorStop()
        self.scoFaBomberAttackRunBreakOff = nil
        return SCO_FaBomberStockAttackBehaviorStop(self)
    end

    function HostAirUnit:GetAttackRadius(patternID, range)
        local contract = SCO_FaBomberAttackRunContract(self)
        if contract ~= nil then
            return contract.runtimePursueStandoff
        end
        return SCO_FaBomberStockGetAttackRadius(self, patternID, range)
    end

    function CreateWreckageFromUnit(unit)
        local contract = SCO_FaBomberCrashImpactContract(unit)
        local wreck = SCO_FaBomberStockCreateWreckageFromUnit(unit)
        if wreck ~= nil and contract ~= nil then
            wreck.scoFaBomberCrashImpact = {
                version = contract.version,
                sourceUnitId = contract.sourceUnitId,
                sourceLabel = contract.sourceLabel,
                damage = contract.damage,
                damageRadius = contract.damageRadius,
                damageFriendly = contract.damageFriendly,
                runtimeMode = contract.runtimeMode,
                army = unit.army,
            }
        end
        return wreck
    end

    rawset(
        SCO_FaBomberAttackRunEnvironment,
        "SCO_FaBomberAttackRunInstalled",
        "1.0.0")
end
-- Supreme Commander Overhaul FA Air Bomber Attack Move 1.1.0
-- Stock attack-move owns an auto-acquired weapon target, not an explicit
-- attackBehaviorTargetUnit. Complete the source breakoff for a released
-- bomb while preserving the stock pursuit loop for every other aircraft.
local SCO_FaBomberAttackMoveEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCO_FaBomberAttackMoveInstalled = rawget(
    SCO_FaBomberAttackMoveEnvironment,
    "SCO_FaBomberAttackMoveInstalled")
if SCO_FaBomberAttackMoveInstalled ~= nil
    and SCO_FaBomberAttackMoveInstalled ~= "1.1.0"
then
    error("Unsupported SCOM bomber attack-move runtime "
        .. tostring(SCO_FaBomberAttackMoveInstalled))
end
if SCO_FaBomberAttackMoveInstalled == nil then
    if type(HostAirUnit) ~= "table"
        or type(HostAirUnit.SCO_FaBomberOnBombReleased) ~= "function"
        or type(HostAirUnit.GetMainWeaponTarget) ~= "function"
        or type(HostAirUnit.MoveIntoRangeBehaviorEnteredRange) ~= "function"
        or type(HostAirUnit.AttackMoveBehaviorStop) ~= "function"
        or type(MovementEventType) ~= "table"
        or MovementEventType.Arrived == nil
        or type(Engine.GetMovementHeadingDegrees) ~= "function"
        or type(Engine.MovementMove) ~= "function"
        or type(Engine.MovementMoveToTarget) ~= "function"
        or MovementEventType.ArrivedBestEffort == nil
        or type(EngineClasses.float2) ~= "function"
    then
        error("SCOM bomber attack-move runtime cannot resolve host functions")
    end

    local SCO_FaBomberOriginalRelease =
        HostAirUnit.SCO_FaBomberOnBombReleased
    local SCO_FaBomberOriginalMainTarget =
        HostAirUnit.GetMainWeaponTarget
    local SCO_FaBomberOriginalEnteredRange =
        HostAirUnit.MoveIntoRangeBehaviorEnteredRange
    local SCO_FaBomberOriginalAttackMoveStop =
        HostAirUnit.AttackMoveBehaviorStop

    local function SCO_FaBomberAttackMoveBombTarget(unit)
        local bombWeapon = nil
        for _, weapon in ipairs(unit.weapons or {}) do
            if weapon.tp and weapon.tp.scoFaBombDrop then
                if bombWeapon ~= nil then return nil end
                bombWeapon = weapon
            end
        end
        return bombWeapon and bombWeapon:GetAimTarget() or nil
    end

    function HostAirUnit:GetMainWeaponTarget()
        local target = SCO_FaBomberOriginalMainTarget(self)
        local breakOff = self.scoFaBomberAttackMoveBreakOff
        if breakOff ~= nil and breakOff.target ~= target then
            self.scoFaBomberAttackMoveBreakOff = nil
            self.scoFaBomberAttackRunBreakOff = nil
        end
        return target
    end

    HostAirUnit.SCO_FaBomberOnBombReleased = function(self, projectileId)
        local handled = SCO_FaBomberOriginalRelease(self, projectileId)
        if handled
            or projectileId == nil
            or self.dead == true
            or self.isAirborne ~= true
            or self.attackBehaviorIsActive == true
            or self.attackMoveBehaviorIsActive ~= true
            or self.moveIntoRangeBehaviorIsActive == true
        then
            return handled
        end

        local additions = self.tp and self.tp.additions
        local contract = additions and additions.scoFaBomberAttackRun
        if contract == nil then return false end
        local target = SCO_FaBomberAttackMoveBombTarget(self)
        if target == nil
            or target.dead == true
            or target ~= self:GetMainWeaponTarget()
            or type(target.GetPosition) ~= "function"
        then
            return false
        end
        if self.scoFaBomberAttackMoveBreakOff ~= nil then
            return false
        end

        local position = self:GetPosition()
        local targetPosition = target:GetPosition()
        local _, heading = Engine.GetMovementHeadingDegrees(self.id)
        if type(position) ~= "table"
            or type(targetPosition) ~= "table"
            or type(heading) ~= "number"
        then
            return false
        end
        local radians = math.rad(heading)
        local forwardX = math.sin(radians)
        local forwardZ = math.cos(radians)
        local targetForwardDistance =
            (targetPosition.x - position.x) * forwardX
            + (targetPosition.z - position.z) * forwardZ
        local legLength = math.max(
    		contract.sourceBreakOffDistance,
    		targetForwardDistance + contract.sourceBreakOffDistance)
        local waypoint = EngineClasses.float2(
            position.x + forwardX * legLength,
            position.z + forwardZ * legLength)
        local result = Engine.MovementMove(self.id, waypoint, EngineClasses.float2(0, 0), 0)
        local success = result == nil
            or result == 0
            or (type(EngineErrorCode) == "table"
                and result == EngineErrorCode.Success)
        if success then
            self.scoFaBomberAttackMoveBreakOff = {
                target = target,
                waypoint = waypoint,
            }
        end
        return success
    end

    function HostAirUnit:MoveIntoRangeBehaviorEnteredRange(reason)
        local explicit = self.scoFaBomberAttackRunBreakOff
        local breakOff = explicit or self.scoFaBomberAttackMoveBreakOff
        if breakOff ~= nil and self.moveIntoRangeBehaviorIsActive == true then
            self.scoFaBomberAttackMoveBreakOff = nil
            self.scoFaBomberAttackRunBreakOff = nil
        elseif breakOff ~= nil
            and (reason == MovementEventType.Arrived
                or reason == MovementEventType.ArrivedBestEffort)
        then
            if reason == MovementEventType.Arrived then
                local position = self:GetPosition()
                -- World position uses x/z; the movement waypoint is
                -- float2 x/y. A previous pursuit's distant arrival
                -- cannot complete this breakoff leg.
                local nearWaypoint = type(position) == "table"
                    and type(position.x) == "number"
                    and type(position.z) == "number"
                    and (position.x - breakOff.waypoint.x) ^ 2
                        + (position.z - breakOff.waypoint.y) ^ 2 <= 25
                if not nearWaypoint then return end
            end
            -- BestEffort is terminal even when pathfinding stops
            -- farther from the waypoint; reenter instead of latching.
            self.scoFaBomberAttackMoveBreakOff = nil
            self.scoFaBomberAttackRunBreakOff = nil
            if self.dead ~= true
                and self.isAirborne == true
                and breakOff.target.dead ~= true
                and ((explicit ~= nil and self.attackBehaviorIsActive == true
                        and self.attackBehaviorTargetUnit == breakOff.target)
                    or (explicit == nil and self.attackMoveBehaviorIsActive == true
                        and self:GetMainWeaponTarget() == breakOff.target))
            then
                self:PursueTarget(breakOff.target)
                return
            end
        end
        return SCO_FaBomberOriginalEnteredRange(self, reason)
    end

    function HostAirUnit:AttackMoveBehaviorStop()
        self.scoFaBomberAttackMoveBreakOff = nil
        return SCO_FaBomberOriginalAttackMoveStop(self)
    end

    rawset(
        SCO_FaBomberAttackMoveEnvironment,
        "SCO_FaBomberAttackMoveInstalled",
        "1.1.0")
end

-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0

-- SCOM support commander scope 9fc8d67999b7250ebb0a79c7eaa355e50fac18cb0a6879dd61f35072ae646ca3 81E4133CEAA013633F25B3E74C28888AF6EFA0DE62AFEAF6437771901D6D0B6E
-- Supreme Commander Overhaul commander enhancements 1.0.0
-- Host-authoritative, per-unit enhancement runtime.  This appendix extends
-- commanders only; it deliberately does not enter Sanctuary's factory-upgrade
-- or ordinary construction paths.

local SCOCommanderEnhancementHostVersion = "1.0.0"
local SCOCommanderEnhancementHostEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderEnhancementHostMarker = rawget(
    SCOCommanderEnhancementHostEnvironment,
    "SCO_CommanderEnhancementHostInstalled")
if SCOCommanderEnhancementHostMarker ~= nil
    and SCOCommanderEnhancementHostMarker ~= SCOCommanderEnhancementHostVersion
then
    error("Unsupported SCOM commander-enhancement host marker "
        .. tostring(SCOCommanderEnhancementHostMarker))
end

if SCOCommanderEnhancementHostMarker == nil then
    if type(HostCommander) ~= "table" then
        error("SCOM commander enhancements could not resolve HostCommander")
    end

    local SCOResourceEntity =
        Import("host/systems/resourceEntity.lua").ResourceEntity
    local SCOLobby = Import("common/lobby.lua")
    local SCOLayers = Import("common/layers.lua")
    local SCOTickRate = Constants.TickRate
    local SCOCommanderIds = {
        uel0000 = true,
        ucl0000 = true,
        ugl0000 = true,
        usl0000 = true,
    }
    local SCOPrimaryWeaponLabels = {
        uel0000 = { RightZephyr = true },
        ucl0000 = { RightDisruptor = true },
        ugl0000 = { RightRipper = true },
        usl0000 = { ChronotronCannon = true },
    }
    local SCOShieldIdByEnhancement = {
        uel0000 = {
            Shield = "uefPersonal",
            ShieldGeneratorField = "uefField",
        },
        ucl0000 = {
            Shield = "aeonPersonal",
            ShieldHeavy = "aeonPersonal",
        },
    }
    local SCOUnsupportedGlobalCapabilities = {
        chronoStun = false,
        cloak = false,
        manualMissiles = false,
        omni = false,
        serialization = false,
        sonar = false,
        spawnPods = false,
        stealth = false,
        teleport = false,
    }

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

    local function SCOCopy(value, seen)
        if type(value) ~= "table" then return value end
        seen = seen or {}
        if seen[value] then return seen[value] end
        local result = {}
        seen[value] = result
        for key, item in pairs(value) do
            result[SCOCopy(key, seen)] = SCOCopy(item, seen)
        end
        return result
    end

    local function SCOSortedKeys(value)
        local result = {}
        for key in pairs(value or {}) do result[#result + 1] = key end
        table.sort(result, function(a, b) return tostring(a) < tostring(b) end)
        return result
    end

    local function SCOContract()
        local contract = rawget(_G, "SCO_CommanderEnhancementContract")
        if type(contract) ~= "table" then
            local ok, imported = pcall(
                Import,
                "common/systems/scoCommanderEnhancements.lua")
            if ok and type(imported) == "table" then
                contract = imported.SCO_CommanderEnhancementContract or imported
            end
        end
        if type(contract) ~= "table"
            or contract.version ~= SCOCommanderEnhancementHostVersion
            or type(contract.commanders) ~= "table"
        then
            error("SCOM commander enhancement contract is unavailable or incompatible")
        end
        return contract
    end

    local function SCOCommanderContract(unit)
        if type(unit) ~= "table" or not SCOCommanderIds[unit.tpId] then
            return nil
        end
        local commander = SCOContract().commanders[unit.tpId]
        local marker = unit.tp
            and unit.tp.additions
            and unit.tp.additions.scoCommanderEnhancements
        if type(commander) ~= "table"
            or type(commander.base) ~= "table"
            or type(commander.enhancements) ~= "table"
            or type(marker) ~= "table"
            or marker.version ~= SCOCommanderEnhancementHostVersion
            or marker.sourceId ~= commander.sourceId
            or marker.faction ~= commander.faction
        then
            error("SCOM commander enhancement template/contract drift on "
                .. tostring(unit.tpId))
        end
        return commander
    end

    local function SCOUnitIsCompleted(unit)
        return type(unit.IsCompleted) == "function" and unit:IsCompleted()
    end

    local function SCORequirementDepth(commander, enhancementId)
        local depth = 0
        local seen = {}
        local current = enhancementId
        while current do
            if seen[current] then return 1000000 end
            seen[current] = true
            local rule = commander.enhancements[current]
            if type(rule) ~= "table" then return 1000000 end
            current = rule.prerequisite
            depth = depth + 1
        end
        return depth
    end

    local function SCOInstalledIds(state, commander)
        local ids = {}
        for enhancementId, installed in pairs(state.installed or {}) do
            if installed == true and commander.enhancements[enhancementId] then
                ids[#ids + 1] = enhancementId
            end
        end
        table.sort(ids, function(a, b)
            local da = SCORequirementDepth(commander, a)
            local db = SCORequirementDepth(commander, b)
            if da == db then return a < b end
            return da < db
        end)
        return ids
    end

    local function SCOActiveDomainRules(state, commander, domain)
        local ids = SCOInstalledIds(state, commander)
        local suppressed = {}
        for _, enhancementId in ipairs(ids) do
            local rule = commander.enhancements[enhancementId]
            local effect = rule.effects and rule.effects[domain]
            if type(effect) == "table" and effect.replacesPrerequisiteEffect then
                local prerequisite = rule.prerequisite
                while prerequisite do
                    suppressed[prerequisite] = true
                    local parent = commander.enhancements[prerequisite]
                    prerequisite = parent and parent.prerequisite
                end
            end
        end
        local result = {}
        for _, enhancementId in ipairs(ids) do
            local rule = commander.enhancements[enhancementId]
            local effect = rule.effects and rule.effects[domain]
            if type(effect) == "table" and not suppressed[enhancementId] then
                result[#result + 1] = {
                    id = enhancementId,
                    rule = rule,
                    effect = effect,
                }
            end
        end
        return result
    end

    local function SCOAddReason(reasons, reason)
        if reason then reasons[reason] = true end
    end

    local function SCOEnhancementCapability(unit, rule)
        local result = {
            install = true,
            partial = false,
            domains = {},
        }
        local reasons = {}
        local domainCount = 0
        local supportedCount = 0
        local hardUnsupported = false

        for domain, effect in pairs(rule.effects or {}) do
            domainCount = domainCount + 1
            local supported = false
            local partial = false

            if domain == "engineering" then
                supported = type(effect) == "table"
            elseif domain == "economy" then
                supported = type(effect) == "table"
            elseif domain == "shield" then
                local map = SCOShieldIdByEnhancement[unit.tpId]
                supported = type(effect) == "table"
                    and map ~= nil
                    and map[rule.id] ~= nil
                if not supported then SCOAddReason(reasons, "shield-runtime-unavailable") end
                -- FA's basic UEF/Aeon shield blueprints expose
                -- RegenAssistMult=10. Sanctuary has no shield-assist callback
                -- or repair-cost API, so the shield itself remains available
                -- while that one auxiliary behavior is declared partial.
                if supported and effect.regenAssistMultiplier ~= nil then
                    partial = true
                    SCOAddReason(reasons, "shield-regen-assist-runtime-unavailable")
                end
            elseif domain == "aura" then
                supported = unit.tpId == "usl0000"
                    and type(effect) == "table"
                    and SCOFinite(effect.radius)
                    and SCOFinite(effect.regenPerSecond)
                -- Sanctuary has no FA category-expression evaluator.  The
                -- runtime uses the safe same-army mobile subset explicitly.
                partial = supported and effect.sourceCategoryExpression ~= nil
                if partial then SCOAddReason(reasons, "aura-category-adapted") end
            elseif domain == "intel" then
                local hasVision = SCOFinite(effect.visionRadiusSet)
                local hasUnsupported = effect.omniRadiusSet ~= nil
                    or effect.sonarRadiusSet ~= nil
                    or effect.radarStealth == true
                    or effect.sonarStealth == true
                    or effect.cloak == true
                    or effect.radarStealthFromPrerequisite == true
                    or effect.sonarStealthFromPrerequisite == true
                supported = hasVision
                partial = hasVision and hasUnsupported
                if effect.cloak == true
                    or effect.radarStealth == true
                    or effect.sonarStealth == true
                    or effect.radarStealthFromPrerequisite == true
                    or effect.sonarStealthFromPrerequisite == true
                then
                    hardUnsupported = true
                    SCOAddReason(reasons, "stealth-cloak-runtime-unavailable")
                elseif effect.omniRadiusSet ~= nil then
                    SCOAddReason(reasons, "omni-runtime-unavailable")
                elseif effect.sonarRadiusSet ~= nil then
                    SCOAddReason(reasons, "sonar-runtime-unavailable")
                end
            elseif domain == "weapon" then
                local supportedWeapons = 0
                local unsupportedWeapons = 0
                for _, weaponSpec in ipairs(effect.weapons or {}) do
                    local label = weaponSpec.label
                    local isPrimary = SCOPrimaryWeaponLabels[unit.tpId]
                        and SCOPrimaryWeaponLabels[unit.tpId][label]
                    local customIndex = unit.tp.additions
                        and unit.tp.additions.scoCommanderEnhancementWeapons
                        and unit.tp.additions.scoCommanderEnhancementWeapons[label]
                    if isPrimary or customIndex then
                        supportedWeapons = supportedWeapons + 1
                    else
                        unsupportedWeapons = unsupportedWeapons + 1
                        SCOAddReason(
                            reasons,
                            label == "OverCharge"
                                and "overcharge-runtime-unavailable"
                                or "weapon-runtime-unavailable")
                    end
                end
                supported = supportedWeapons > 0
                partial = supportedWeapons > 0 and unsupportedWeapons > 0
            elseif domain == "spawn" then
                hardUnsupported = true
                SCOAddReason(reasons, "spawn-runtime-unavailable")
            elseif domain == "teleport" then
                hardUnsupported = true
                SCOAddReason(reasons, "teleport-runtime-unavailable")
            else
                hardUnsupported = true
                SCOAddReason(reasons, "unknown-effect-domain")
            end

            result.domains[domain] = supported
            if supported then supportedCount = supportedCount + 1 end
            if partial then result.partial = true end
        end

        if domainCount == 0 or supportedCount == 0 or hardUnsupported then
            result.install = false
        elseif supportedCount < domainCount then
            result.partial = true
        end

        local reasonList = SCOSortedKeys(reasons)
        if #reasonList > 0 then result.reason = table.concat(reasonList, ",") end
        return result
    end

    local function SCOCapabilities(unit, commander)
        local capabilities = SCOCopy(SCOUnsupportedGlobalCapabilities)
        capabilities.engineeringTier = 1
        capabilities.enhancements = {}
        for _, enhancementId in ipairs(SCOSortedKeys(commander.enhancements)) do
            local rule = commander.enhancements[enhancementId]
            capabilities.enhancements[enhancementId] =
                SCOEnhancementCapability(unit, rule)
        end
        return capabilities
    end

    local function SCORebuildSlotsAndTier(state, commander)
        state.slots = {}
        local tier = 1
        for _, enhancementId in ipairs(SCOInstalledIds(state, commander)) do
            local rule = commander.enhancements[enhancementId]
            state.slots[rule.slot] = enhancementId
            local engineering = rule.effects and rule.effects.engineering
            if type(engineering) == "table"
                and SCOInteger(engineering.tier or 0, 1, 3)
            then
                tier = math.max(tier, engineering.tier)
            end
        end
        state.capabilities.engineeringTier = tier
    end

    local SCOIsIdle

    local function SCOStateSnapshot(unit)
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" then return nil end
        local idle = state.active == nil and SCOIsIdle(unit)
        if state._lastPublishedIdle == nil then
            state._lastPublishedIdle = idle
        elseif state._lastPublishedIdle ~= idle then
            state._lastPublishedIdle = idle
            state.revision = (state.revision + 1) % 2147483648
        end
        local active = nil
        if type(state.active) == "table" then
            local progress = math.max(0, state.active.progress or 0)
            local buildTime = state.active.buildTime
            active = {
                id = state.active.id,
                kind = state.active.kind,
                progress = progress,
                buildTime = buildTime,
                fraction = buildTime > 0
                    and math.min(1, progress / buildTime)
                    or 0,
                paused = unit:GetPause() == true,
                buildPower = state.active.buildPower,
                estimatedSeconds = state.active.estimatedSeconds,
            }
        end
        return {
            version = SCOCommanderEnhancementHostVersion,
            tpId = unit.tpId,
            unitId = { index = unit.id.index, version = unit.id.version },
            revision = state.revision,
            idle = idle,
            installed = SCOCopy(state.installed),
            slots = SCOCopy(state.slots),
            visualHidden = SCOCopy(state._visualHidden),
            active = active,
            capabilities = SCOCopy(state.capabilities),
        }
    end

    local function SCOVisualSnapshot(unit)
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" then return nil end
        return {
            version = SCOCommanderEnhancementHostVersion,
            tpId = unit.tpId,
            unitId = { index = unit.id.index, version = unit.id.version },
            revision = state.revision,
            installed = SCOCopy(state.installed),
            slots = SCOCopy(state.slots),
            visualHidden = SCOCopy(state._visualHidden),
        }
    end

    local function SCOOwnerClientId(unit)
        local player = type(SCOLobby) == "table"
            and type(SCOLobby.ArmyToPlayer) == "table"
            and unit.army
            and SCOLobby.ArmyToPlayer[unit.army.id]
        local clientID = player and player.clientID
        if SCOInteger(clientID, 0, 2147483647) then return clientID end
        return nil
    end

    local function SCOEmitState(unit)
        local emitter = rawget(_G, "SCO_CommanderEnhancementEmitState")
        local snapshot = SCOStateSnapshot(unit)
        local ownerClientID = SCOOwnerClientId(unit)
        local ownerSent = false
        if type(emitter) == "function"
            and snapshot
            and ownerClientID ~= nil
        then
            local ok, sent = pcall(emitter, ownerClientID, snapshot)
            ownerSent = ok and sent == true
        end

        -- Upgrade geometry is observable gameplay state, but economy,
        -- progress, and capabilities remain owner-only. Replicate only the
        -- minimal visual projection to peers and observers.
        local visualEmitter =
            rawget(_G, "SCO_CommanderEnhancementEmitVisualState")
        local visualSnapshot = SCOVisualSnapshot(unit)
        for _, clientID in ipairs(SCOSortedKeys(SCOLobby.Players or {})) do
            if type(visualEmitter) == "function"
                and visualSnapshot
                and SCOInteger(clientID, 0, 2147483647)
            then
                pcall(visualEmitter, clientID, visualSnapshot)
            end
        end
        return ownerSent
    end

    local function SCOBumpRevision(unit)
        local state = unit.scoCommanderEnhancements
        state.revision = (state.revision + 1) % 2147483648
        SCOEmitState(unit)
    end

    local function SCOSetDetectorRadius(detector, radius)
        if detector and detector.id and SCOFinite(radius) and radius > 0
            and EngineClasses and EngineClasses.float3
            and Engine and type(Engine.SetVolumeColliderSize) == "function"
        then
            pcall(
                Engine.SetVolumeColliderSize,
                detector.id,
                EngineClasses.float3(radius, 0, 0))
        end
    end

    local function SCOSetWeaponRange(weapon)
        local rangeMin = weapon.tp.rangeMin or 0
        local rangeMax = weapon.tp.rangeMax or 0
        if Engine then
            for index, aimControllerId in ipairs(weapon.aimControllerIds or {}) do
                if type(Engine.SetAimControllerMinRange) == "function" then
                    pcall(Engine.SetAimControllerMinRange, aimControllerId, rangeMin)
                end
                if type(Engine.SetAimControllerMaxRange) == "function" then
                    pcall(Engine.SetAimControllerMaxRange, aimControllerId, rangeMax)
                end
                local aim = weapon.tp.aimControllers
                    and weapon.tp.aimControllers[index]
                if type(aim) == "table"
                    and SCOFinite(aim.projectileSpeed)
                    and type(Engine.SetAimControllerProjectileSpeed) == "function"
                then
                    pcall(
                        Engine.SetAimControllerProjectileSpeed,
                        aimControllerId,
                        aim.projectileSpeed)
                end
            end
            if weapon.targeterCollider
                and weapon.targeterCollider.id
                and type(Engine.SetVolumeColliderSize) == "function"
            then
                pcall(
                    Engine.SetVolumeColliderSize,
                    weapon.targeterCollider.id,
                    EngineClasses.float3(rangeMax, 0, 0))
            end
        end
        -- HostBeam snapshots damage/range when its muzzle is constructed.
        -- Enhancement recomputes mutate the weapon template later, so keep the
        -- proven native beam object synchronized as well.
        if type(__Muzzles) == "table" then
            for _, muzzleGroup in ipairs(weapon.muzzleGroups or {}) do
                for _, muzzle in ipairs(muzzleGroup) do
                    local hostMuzzle = muzzle.id and __Muzzles[muzzle.id.index]
                    if hostMuzzle and hostMuzzle.beam then
                        hostMuzzle.beam.damage = weapon.tp.damage
                        hostMuzzle.beam.rangeMax = rangeMax
                    end
                end
            end
        end
    end

    local function SCOWeaponForLabel(unit, label)
        if SCOPrimaryWeaponLabels[unit.tpId]
            and SCOPrimaryWeaponLabels[unit.tpId][label]
        then
            return unit.weapons and unit.weapons[1]
        end
        local index = unit.tp.additions
            and unit.tp.additions.scoCommanderEnhancementWeapons
            and unit.tp.additions.scoCommanderEnhancementWeapons[label]
        return index and unit.weapons and unit.weapons[index] or nil
    end

    local function SCOApplyWeaponSpec(weapon, spec, modifiersOnly)
        if not weapon or type(spec) ~= "table" then return end
        local tp = weapon.tp
        if not modifiersOnly then
            if SCOFinite(spec.damage) then tp.damage = spec.damage end
            if SCOFinite(spec.damageRadius) then tp.damageRadius = spec.damageRadius end
            if type(spec.damageType) == "string" then tp.damageType = spec.damageType end
            if SCOFinite(spec.minRadius) then tp.rangeMin = spec.minRadius end
            if SCOFinite(spec.maxRadius) then tp.rangeMax = spec.maxRadius end
            if SCOFinite(spec.rateOfFire) and spec.rateOfFire > 0 then
                tp.reloadTime = 1 / spec.rateOfFire
            end
            if SCOFinite(spec.muzzleSalvoSize) then
                tp.muzzleSalvoSize = spec.muzzleSalvoSize
            end
            if SCOFinite(spec.muzzleSalvoDelay) then
                tp.muzzleSalvoDelay = spec.muzzleSalvoDelay
            end
            if SCOFinite(spec.projectileLifetime) then
                tp.projectileLifetime = spec.projectileLifetime
            end
            if SCOFinite(spec.muzzleVelocity) and spec.muzzleVelocity > 0 then
                for _, aim in ipairs(tp.aimControllers or {}) do
                    aim.projectileSpeed = spec.muzzleVelocity
                end
            end
            return
        end
        if SCOFinite(spec.damageAdd) then
            tp.damage = (tp.damage or 0) + spec.damageAdd
        end
        if SCOFinite(spec.damageRadiusAdd) then
            tp.damageRadius = (tp.damageRadius or 0) + spec.damageRadiusAdd
        end
        if SCOFinite(spec.maxRadiusSet) then tp.rangeMax = spec.maxRadiusSet end
        if SCOFinite(spec.rateOfFireSet) and spec.rateOfFireSet > 0 then
            tp.reloadTime = 1 / spec.rateOfFireSet
        end
    end

    local function SCOApplyWeapons(unit, state, commander)
        for index, weapon in ipairs(unit.weapons or {}) do
            weapon.tp = SCOCopy(state._base.weaponTemplates[index])
        end

        local weaponRules = SCOActiveDomainRules(state, commander, "weapon")
        -- Establish enhancement-owned weapons before applying cross-enhancement
        -- modifiers such as CoolingUpgrade's conditional MLG range change.
        for _, item in ipairs(weaponRules) do
            for _, spec in ipairs(item.effect.weapons or {}) do
                if spec.conditionalOnEnhancement == nil then
                    SCOApplyWeaponSpec(SCOWeaponForLabel(unit, spec.label), spec, false)
                end
            end
        end
        for _, item in ipairs(weaponRules) do
            for _, spec in ipairs(item.effect.weapons or {}) do
                if spec.conditionalOnEnhancement == nil
                    or state.installed[spec.conditionalOnEnhancement] == true
                then
                    SCOApplyWeaponSpec(SCOWeaponForLabel(unit, spec.label), spec, true)
                end
            end
        end

        if unit.tpId == "usl0000"
            and SCOFinite(state._seraphimChronotronRadiusAdd)
            and state._seraphimChronotronRadiusAdd ~= 0
        then
            local chronotron = SCOWeaponForLabel(unit, "ChronotronCannon")
            if chronotron then
                chronotron.tp.damageRadius =
                    (chronotron.tp.damageRadius or 0)
                    + state._seraphimChronotronRadiusAdd
            end
        end

        local attackRange = 0
        for _, weapon in ipairs(unit.weapons or {}) do
            local tp = weapon.tp
            local required = tp.scoCommanderEnhancementRequired
            local enabled = SCOUnitIsCompleted(unit)
                and not unit.dead
                and state.active == nil
            if tp.scoCommanderEnhancementUnsupported == true then
                enabled = false
            elseif required ~= nil then
                enabled = enabled and state.installed[required] == true
            end
            if type(weapon.SetEnabled) == "function" then
                weapon:SetEnabled(enabled)
            end
            SCOSetWeaponRange(weapon)
            if enabled and not weapon.isDeathExplosion then
                attackRange = math.max(attackRange, tp.rangeMax or 0)
            end
        end
        unit.attackRange = attackRange
        unit.canAttack = attackRange > 0
    end

    local function SCOSetMovementLock(unit, locked)
        if Engine and type(Engine.SetMovementEnabled) == "function"
            and unit.id
        then
            pcall(Engine.SetMovementEnabled, unit.id, not locked)
        end
    end

    local function SCOApplyHealthAndEngineering(unit, state, commander)
        local maximum = state._base.maxHealth
        local regen = state._base.regenRate
        local buildPower = state._base.buildRate
        local regenSet = nil
        for _, item in ipairs(SCOActiveDomainRules(state, commander, "engineering")) do
            local effect = item.effect
            local suppressed = unit.tpId == "usl0000"
                and item.id == "DamageStabilization"
                and state._suppressSeraphimBaseDamageStabilization == true
            if not suppressed then
                if SCOFinite(effect.maxHealthAdd) then maximum = maximum + effect.maxHealthAdd end
                if SCOFinite(effect.regenRateAdd) then regen = regen + effect.regenRateAdd end
                if SCOFinite(effect.regenRateSet) then regenSet = effect.regenRateSet end
                if SCOFinite(effect.buildRateSet) then buildPower = effect.buildRateSet end
            end
        end
        if regenSet ~= nil then regen = regenSet end

        local oldMaximum = unit:GetMaxHealth()
        local oldHealth = unit:GetHealth()
        local missing = math.max(0, oldMaximum - oldHealth)
        unit:SetMaxHealth(maximum)
        unit:SetHealthRegen(regen)
        -- The mandatory FA veterancy layer owns the final ranked values. Its
        -- base anchors must follow the enhancement-derived values or a rank
        -- change and an enhancement recompute will overwrite one another.
        if type(unit.SCOApplyVeterancyLevel) == "function" then
            unit.scoVeterancyBaseMaxHealth = maximum
            unit.scoVeterancyBaseRegen = regen
            unit:SCOApplyVeterancyLevel(unit.scoVeterancyLevel or 0)
        end
        -- Veterancy may change maximum health and may itself grant the max-HP
        -- delta. Override only the final current HP so enhancement changes
        -- preserve the exact pre-change missing-health amount at every rank.
        unit:SetHealth(math.max(1, unit:GetMaxHealth() - missing))
        if unit.construction and type(unit.SetBuildPower) == "function" then
            unit:SetBuildPower(buildPower)
        end
    end

    local function SCOApplyEconomy(unit, state, commander)
        local energy = state._base.energyProduction
        local mass = state._base.massProduction
        for _, item in ipairs(SCOActiveDomainRules(state, commander, "economy")) do
            local effect = item.effect
            if SCOFinite(effect.energyProductionAdd) then
                energy = energy + effect.energyProductionAdd
            end
            if SCOFinite(effect.massProductionAdd) then
                mass = mass + effect.massProductionAdd
            end
        end
        local generation = unit.resourceEntities
            and unit.resourceEntities.generation
        if generation then
            local shouldEnable = SCOUnitIsCompleted(unit) and not unit.dead
            -- SetResources asks the economy to update immediately and warns
            -- for an unregistered entity. Commanders recompute once during
            -- construction, while their stock generation entity is disabled.
            if not generation.enabled then generation:SetEnabled(true) end
            generation:SetResources({ alloys = mass, energy = energy }, nil)
            generation:SetEnabled(shouldEnable)
        end
    end

    local function SCOApplyIntel(unit, state, commander)
        local vision = state._base.visionRadius
        for _, item in ipairs(SCOActiveDomainRules(state, commander, "intel")) do
            if SCOFinite(item.effect.visionRadiusSet) then
                vision = item.effect.visionRadiusSet
            end
        end
        SCOSetDetectorRadius(unit.visionDetector, vision)
    end

    local function SCOSelectedShield(state, commander, tpId)
        local selectedId = nil
        local selectedEffect = nil
        local selectedEnhancementId = nil
        local map = SCOShieldIdByEnhancement[tpId]
        if not map then return nil, nil, nil end
        for _, item in ipairs(SCOActiveDomainRules(state, commander, "shield")) do
            local shieldId = map[item.id]
            if shieldId then
                selectedId = shieldId
                selectedEffect = item.effect
                selectedEnhancementId = item.id
            end
        end
        return selectedId, selectedEffect, selectedEnhancementId
    end

    local function SCOShieldObjectById(unit, shieldId)
        for _, shield in ipairs(unit.shields or {}) do
            if shield.tp
                and shield.tp.scoCommanderEnhancementShieldId == shieldId
            then
                return shield
            end
        end
        return nil
    end

    local function SCOSetResourceUserMultiplier(entity, value)
        if not entity then return end
        value = math.max(0, math.min(value or 1, 1))
        if type(entity.SetUserMultiplier) == "function" then
            entity:SetUserMultiplier(value)
        else
            entity.userMultiplier = value
        end
    end

    local function SCOSetResourceEntityActive(entity, enabled, outcome, recalculate)
        if not entity then return end
        if enabled then
            entity:SetEnabled(true)
            if outcome then entity:SetResources(nil, outcome) end
            if recalculate and type(entity.RecalculateBuildDrain) == "function" then
                entity:RecalculateBuildDrain()
            end
        else
            entity:SetEnabled(false)
            -- ResourceEntity:SetEnabled(false) unregisters the entity but keeps
            -- its last UI drain and satisfaction multiplier. Clear both just as
            -- Sanctuary's proven strategic-silo lifecycle does.
            entity.outcome = {}
            entity.prevOutcome = {}
            entity.productionMultiplier = 0
            SCOSetResourceUserMultiplier(entity, 1)
        end
    end

    local function SCOConfigureShieldConsumption(unit, energy)
        local key = "scoCommanderShieldConsumption"
        local entity = unit.resourceEntities[key]
        if energy and energy > 0 and not entity then
            entity = SCOResourceEntity(
                unit.army.id,
                unit.id,
                "consumption",
                nil,
                nil,
                false)
            unit.resourceEntities[key] = entity
        end
        return entity
    end

    local function SCOApplyShieldState(unit, skipRecharge)
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" or not unit.shields then return end
        local wantsShield = state._activeShieldId ~= nil
            and SCOUnitIsCompleted(unit)
            and not unit.dead
            and unit:GetShieldToggle() == true
        local consumption = SCOConfigureShieldConsumption(
            unit,
            state._shieldMaintenance)
        SCOSetResourceEntityActive(
            consumption,
            wantsShield,
            wantsShield and { energy = state._shieldMaintenance } or nil,
            false)
        for _, shield in ipairs(unit.shields) do
            local shieldId = shield.tp
                and shield.tp.scoCommanderEnhancementShieldId
            local desired = wantsShield and shieldId == state._activeShieldId
            shield:SetEnableable(
                desired,
                desired and skipRecharge or false)
            if desired
                and type(shield.SCOSetCommanderEnergyDown) == "function"
            then
                shield:SCOSetCommanderEnergyDown(
                    unit.army.economy.isEnergyDown == true)
            end
        end
        unit:UpdateUIValues()
    end

    local function SCOApplyShields(unit, state, commander)
        local previousShieldId = state._activeShieldId
        local previousEnhancementId = state._activeShieldEnhancementId
        local shieldId, effect, enhancementId =
            SCOSelectedShield(state, commander, unit.tpId)
        state._activeShieldId = shieldId
        state._activeShieldEnhancementId = enhancementId
        state._shieldMaintenance = effect and effect.maintenanceEnergy or nil
        for _, shield in ipairs(unit.shields or {}) do
            local id = shield.tp and shield.tp.scoCommanderEnhancementShieldId
            if id and id == shieldId then
                if enhancementId ~= previousEnhancementId
                    and shield.isEnableable == true
                then
                    shield:SetEnableable(false)
                end
                shield.tp = SCOCopy(shield.tp)
                local oldMaximum = shield:GetMaxHealth()
                local oldHealth = shield:GetHealth()
                local missing = math.max(0, oldMaximum - oldHealth)
                shield:SetMaxHealth(effect.maxHealth)
                shield:SetHealth(math.max(1, effect.maxHealth - missing))
                shield:SetHealthRegen(effect.regenRate)
                shield:SetRegenDelay(effect.regenStartTime or 1)
                shield:SetRechargeTime(effect.rechargeTime or 5)
                shield.tp.scoDamageRechargeTime = effect.rechargeTime or 5
                shield.tp.scoEnergyDrainRechargeTime =
                    effect.energyDrainRechargeTime or 5
            end
        end
        SCOApplyShieldState(
            unit,
            shieldId ~= nil
                and (previousShieldId ~= shieldId
                    or previousEnhancementId ~= enhancementId))
    end

    local function SCOCaptureShieldTransferState(unit, state, commander)
        local shieldId = SCOSelectedShield(state, commander, unit.tpId)
        if shieldId == nil then return nil, true end
        if state._activeShieldId ~= shieldId
            or type(unit.GetShieldToggle) ~= "function"
        then
            return nil, false
        end

        local shield = SCOShieldObjectById(unit, shieldId)
        if not shield
            or type(shield.GetHealth) ~= "function"
            or type(shield.GetMaxHealth) ~= "function"
            or type(shield.SetHealth) ~= "function"
            or type(shield.SetEnableable) ~= "function"
        then
            return nil, false
        end
        local toggle = unit:GetShieldToggle()
        local health = shield:GetHealth()
        local maximum = shield:GetMaxHealth()
        local enabled = shield.enabled
        local enableable = shield.isEnableable
        local recharging = shield.rechargeThread ~= nil
        if type(toggle) ~= "boolean"
            or not SCOFinite(health) or health < 0
            or not SCOFinite(maximum) or maximum <= 0
            or health > maximum + 0.000001
            or type(enabled) ~= "boolean"
            or type(enableable) ~= "boolean"
            or enableable ~= toggle
            or (enabled and (not enableable or recharging))
            or (enableable and not enabled and not recharging)
        then
            return nil, false
        end
        return {
            shieldId = shieldId,
            -- Forged Alliance capture transfers ShieldIsOn and current health,
            -- not an in-flight recharge coroutine. A popped shield therefore
            -- arrives OFF and must be explicitly enabled by its new owner.
            enabled = toggle and enabled,
            health = health,
        }, true
    end

    local function SCORestoreShieldTransferState(unit, snapshot)
        if type(snapshot) ~= "table"
            or type(unit.SetToggle) ~= "function"
            or type(unit.GetShieldToggle) ~= "function"
        then
            return false
        end
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table"
            or state._activeShieldId ~= snapshot.shieldId
        then
            return false
        end
        local shield = SCOShieldObjectById(unit, snapshot.shieldId)
        if not shield
            or type(snapshot.enabled) ~= "boolean"
            or not SCOFinite(snapshot.health)
            or snapshot.health < 0
            or type(shield.GetMaxHealth) ~= "function"
            or type(shield.SetHealth) ~= "function"
        then
            return false
        end

        -- Use Sanctuary's public host toggle route so the new owner's client
        -- receives the same authoritative Shield state as the simulation.
        local maximum = shield:GetMaxHealth()
        if not SCOFinite(maximum) or maximum <= 0 then return false end
        local health = math.max(0, math.min(maximum, snapshot.health))
        if snapshot.enabled then
            unit:SetToggle("Shield", true)
            if unit:GetShieldToggle() ~= true
                or shield.isEnableable ~= true
                or shield.enabled ~= true
            then
                return false
            end
            shield:SetHealth(health)
        else
            -- Set health first so the shield wrapper records this amount as
            -- the manual-OFF recovery target instead of the fresh full value.
            shield:SetHealth(health)
            unit:SetToggle("Shield", false)
            if unit:GetShieldToggle() ~= false
                or shield.isEnableable ~= false
                or shield.enabled ~= false
            then
                return false
            end
        end
        unit:UpdateUIValues()
        return true
    end

    local function SCOAuraTargetAllowed(source, target)
        if target == source or target.dead or not target.army
            or target.army.id ~= source.army.id
        then
            return false
        end
        if type(target.HasTags) == "function" and Tags then
            if Tags.COMMAND and target:HasTags(Tags.COMMAND) then return false end
            if Tags.MOBILE and not target:HasTags(Tags.MOBILE) then return false end
            -- FA targets BUILTBYTIER3FACTORY + BUILTBYQUANTUMGATE +
            -- NEEDMOBILEBUILD. Sanctuary exposes no quantum-gate or
            -- NEEDMOBILEBUILD tags; BUILDABLE_BY_T3_FACTORY is the exact
            -- available member and is substantially safer than every MOBILE.
            if Tags.BUILDABLE_BY_T3_FACTORY
                and not target:HasTags(Tags.BUILDABLE_BY_T3_FACTORY)
            then
                return false
            end
        end
        return true
    end

    local function SCOAuraThread(unit, signature, effect)
        local waitTicks = math.max(1, SCOTickRate)
        local pulseTicks = math.max(waitTicks, SCOTickRate * 5)
        local ticksUntilPulse = 0
        local activeTargets = {}
        while not unit.dead do
            local state = unit.scoCommanderEnhancements
            if type(state) ~= "table" or state._auraSignature ~= signature then
                return
            end
            if ticksUntilPulse <= 0 then
                local origin = unit:GetPosition()
                local radiusSquared = effect.radius * effect.radius
                for _, target in pairs(__Entities.Units or {}) do
                    if SCOAuraTargetAllowed(unit, target) then
                        local position = target:GetPosition()
                        local dx = origin.x - position.x
                        local dy = origin.y - position.y
                        local dz = origin.z - position.z
                        if dx * dx + dy * dy + dz * dz <= radiusSquared then
                            -- FA reapplies a five-second REPLACE buff every
                            -- five seconds. Track that lifetime explicitly so
                            -- a unit that leaves the radius keeps the paid-for
                            -- regeneration until its current pulse expires.
                            activeTargets[target] = pulseTicks
                        end
                    end
                end
                ticksUntilPulse = pulseTicks
            end
            for target, remainingTicks in pairs(activeTargets) do
                if target.dead or target.deleted then
                    activeTargets[target] = nil
                else
                    local rate = target:GetMaxHealth()
                        * effect.regenPerSecond
                        * (effect.maxHealthFactor or 1)
                    rate = math.max(effect.regenFloor or 0, rate)
                    rate = math.min(effect.regenCeiling or rate, rate)
                    if rate > 0 then target:AdjustHealth(rate) end
                    remainingTicks = remainingTicks - waitTicks
                    activeTargets[target] = remainingTicks > 0
                        and remainingTicks or nil
                end
            end
            ticksUntilPulse = ticksUntilPulse - waitTicks
            WaitTicks(waitTicks)
        end
    end

    local function SCOApplyAura(unit, state, commander)
        local selected = nil
        for _, item in ipairs(SCOActiveDomainRules(state, commander, "aura")) do
            selected = item
        end
        if selected
            and selected.id == "RegenAura"
            and state._suppressBaseRegenAura == true
        then
            selected = nil
        end
        local signature = selected and selected.id or nil
        if state._auraSignature == signature then return end
        if state._auraThread then
            KillThread(state._auraThread)
            state._auraThread = nil
        end
        state._auraSignature = signature
        if selected then
            state._auraThread = unit:NewThread(
                SCOAuraThread,
                signature,
                SCOCopy(selected.effect))
        end
    end

    local SCORecompute
    SCORecompute = function(unit)
        local state = unit.scoCommanderEnhancements
        local commander = SCOCommanderContract(unit)
        SCORebuildSlotsAndTier(state, commander)
        SCOApplyHealthAndEngineering(unit, state, commander)
        SCOApplyEconomy(unit, state, commander)
        SCOApplyIntel(unit, state, commander)
        SCOApplyWeapons(unit, state, commander)
        SCOApplyShields(unit, state, commander)
        SCOApplyAura(unit, state, commander)
        SCOSetMovementLock(unit, state.active ~= nil)
    end

    local function SCOEnsureState(unit)
        local commander = SCOCommanderContract(unit)
        local state = unit.scoCommanderEnhancements
        if state ~= nil then
            if type(state) ~= "table"
                or state.version ~= SCOCommanderEnhancementHostVersion
            then
                error("SCOM commander enhancement state marker is incompatible")
            end
            return state, commander
        end

        local base = commander.base
        if not SCOFinite(base.maxHealth)
            or not SCOFinite(base.regenRate)
            or not SCOFinite(base.buildRate)
            or not SCOFinite(base.energyProduction)
            or not SCOFinite(base.massProduction)
            or not SCOFinite(base.visionRadius)
        then
            error("SCOM commander enhancement base contract is invalid for "
                .. unit.tpId)
        end

        local weaponTemplates = {}
        for index, weapon in ipairs(unit.weapons or {}) do
            weapon.tp = SCOCopy(weapon.tp)
            weaponTemplates[index] = SCOCopy(weapon.tp)
        end
        state = {
            version = SCOCommanderEnhancementHostVersion,
            revision = 0,
            installed = {},
            slots = {},
            active = nil,
            capabilities = SCOCapabilities(unit, commander),
            _base = {
                maxHealth = base.maxHealth,
                regenRate = base.regenRate,
                buildRate = base.buildRate,
                energyProduction = base.energyProduction,
                massProduction = base.massProduction,
                visionRadius = base.visionRadius,
                weaponTemplates = weaponTemplates,
            },
            _activeShieldId = nil,
            _activeShieldEnhancementId = nil,
            _shieldMaintenance = nil,
            _auraSignature = nil,
            _auraThread = nil,
            _lastPublishedIdle = nil,
            _visualHidden = {},
            _seraphimChronotronRadiusAdd = 0,
            _suppressBaseRegenAura = false,
            _suppressSeraphimBaseDamageStabilization = false,
        }
        unit.scoCommanderEnhancements = state
        SCORecompute(unit)
        return state, commander
    end

    local function SCOValidateRule(rule, removal)
        if type(rule) ~= "table"
            or type(rule.id) ~= "string"
            or type(rule.slot) ~= "string"
            or type(rule.effects) ~= "table"
        then
            return nil, "invalid-rule"
        end
        local cost = removal and rule.removal and rule.removal.cost or rule.cost
        if type(cost) ~= "table"
            or not SCOFinite(cost.mass) or cost.mass < 0
            or not SCOFinite(cost.energy) or cost.energy < 0
            or not SCOFinite(cost.buildTime) or cost.buildTime <= 0
        then
            return nil, "invalid-cost"
        end
        return cost
    end

    local function SCOValidateOwner(clientID, unitId)
        if not SCOInteger(clientID, 0, 2147483647)
            or type(unitId) ~= "table"
            or not SCOInteger(unitId.index, 1, 2147483647)
            or not SCOInteger(unitId.version, 0, 2147483647)
        then
            return nil, "invalid-request"
        end
        local unit = GetUnitById(unitId)
        if not unit or not SCOCommanderIds[unit.tpId] then
            return nil, "unit-not-found"
        end
        if unit.dead then return nil, "unit-dead" end
        if SCOOwnerClientId(unit) ~= clientID then return nil, "not-owner" end
        local ok, state, commander = pcall(SCOEnsureState, unit)
        if not ok then return nil, "runtime-unavailable" end
        return unit, state, commander
    end

    SCOIsIdle = function(unit)
        local orders = unit.orders
        if orders and (orders.activeOrder ~= nil
            or (orders.queuedOrders and #orders.queuedOrders > 0))
        then
            return false
        end
        local busyFields = {
            "unitBeingBuilt",
            "unitBeingCaptured",
            "unitBeingReclaimed",
            "unitBeingRepaired",
            "dashBehaviorIsActive",
        }
        for _, field in ipairs(busyFields) do
            if unit[field] then return false end
        end
        return true
    end

    local function SCOInstallAllowed(state, commander, enhancementId)
        local rule = commander.enhancements[enhancementId]
        if type(rule) ~= "table" or rule.id ~= enhancementId then
            return nil, "unknown-enhancement"
        end
        local capability = state.capabilities.enhancements[enhancementId]
        if type(capability) ~= "table" or capability.install ~= true then
            return nil, capability and capability.reason or "unsupported"
        end
        if state.installed[enhancementId] then return nil, "already-installed" end
        if rule.prerequisite and not state.installed[rule.prerequisite] then
            return nil, "missing-prerequisite"
        end
        for _, conflict in ipairs(rule.conflicts or {}) do
            if state.installed[conflict] then return nil, "conflict" end
        end
        local occupant = state.slots[rule.slot]
        if occupant and occupant ~= rule.prerequisite then
            return nil, "slot-occupied"
        end
        return rule
    end

    local function SCORemovalSet(state, commander, enhancementId)
        local rule = commander.enhancements[enhancementId]
        if type(rule) ~= "table" or not state.installed[enhancementId] then
            return nil, nil, "not-installed"
        end
        local removeSet = {}
        for _, id in ipairs(rule.remove or {}) do
            if commander.enhancements[id] and state.installed[id] then
                removeSet[id] = true
            end
        end
        removeSet[enhancementId] = true
        for installedId in pairs(state.installed) do
            local current = commander.enhancements[installedId]
            local prerequisite = current and current.prerequisite
            while prerequisite do
                if removeSet[prerequisite] and not removeSet[installedId] then
                    return nil, nil, "dependent-installed"
                end
                current = commander.enhancements[prerequisite]
                prerequisite = current and current.prerequisite
            end
        end
        return rule, removeSet
    end

    local function SCONextConstructionSatisfaction(entity)
        local economy = entity and entity.economy
        local resources = economy and economy.resources
        local names = entity and entity.satisfactionTable
        if type(resources) == "table" and type(names) == "table" then
            local lowest = 1
            local found = false
            for _, name in ipairs(names) do
                local resource = resources[name]
                local satisfaction = resource and resource.satisfaction
                if SCOFinite(satisfaction) then
                    lowest = math.min(lowest, math.max(0, satisfaction))
                    found = true
                end
            end
            if found then return math.min(lowest, 1) end
        end

        -- Verifier doubles and older Sanctuary builds may not expose the
        -- economy table. Their current multiplier is the safest fallback.
        return math.max(0, math.min(
            entity and entity.productionMultiplier or 0,
            1))
    end

    local function SCOAssistOrderMatches(builder, unit)
        return (builder.assistBehaviorIsActive
                and builder.assistBehaviorAssistedUnit == unit)
            or (builder.repairBehaviorIsActive
                and builder.repairBehaviorTarget == unit)
    end

    local function SCOAssistCanWork(builder, unit)
        return builder and unit and builder ~= unit
            and not builder.dead and not builder.deleted
            and not unit.dead and not unit.deleted
            and builder:IsCompleted() and unit:IsCompleted()
            and builder:CanConstructOthers()
            and builder.army:IsAlly(unit.army)
            and unit.army:IsAlly(builder.army)
            and builder.construction
            and SCOFinite(builder.construction.buildPower)
            and builder.construction.buildPower > 0
            and not builder:GetPause() and not unit:GetPause()
            and SCOAssistOrderMatches(builder, unit)
            and builder.constructionDetectorCollider
            and builder.constructionDetectorCollider:IsOverlappingUnit(unit)
    end

    local function SCOAssistStop(builder, unit)
        local state = unit and unit.scoCommanderEnhancements
        local active = state and state.active
        if active and active.assistants then
            active.assistants[builder.id] = nil
        end
        if builder.scoCommanderEnhancementAssistTarget == unit then
            builder.scoCommanderEnhancementAssistTarget = nil
        end
        -- Contribution entities describe work already paid for this tick.
        -- Only the commander's progress thread may retire them.
    end

    local function SCOAssistStart(builder, unit)
        local state = unit and unit.scoCommanderEnhancements
        local active = state and state.active
        if not active or not SCOAssistCanWork(builder, unit) then return false end
        local previous = builder.scoCommanderEnhancementAssistTarget
        if previous and previous ~= unit then SCOAssistStop(builder, previous) end
        builder.scoCommanderEnhancementAssistTarget = unit
        active.assistants[builder.id] = builder
        return true
    end

    local function SCORetireAssistEntity(unit, active, id)
        local contribution = active.assistEntities[id]
        local builder, entity = contribution.builder, contribution.entity
        entity:SetEnabled(true)
        entity:RemoveBuilder(builder)
        SCOSetResourceEntityActive(entity, false, nil, false)
        if builder.resourceEntities.scoCommanderEnhancementAssist == entity then
            builder.resourceEntities.scoCommanderEnhancementAssist = nil
        end
        active.assistEntities[id] = nil
        if not builder.dead and not builder.deleted then builder:UpdateUIValues() end
    end

    local function SCOClearAssistants(unit, active)
        for id in pairs(active.assistEntities) do
            SCORetireAssistEntity(unit, active, id)
        end
        for _, builder in pairs(active.assistants) do
            if builder.scoCommanderEnhancementAssistTarget == unit then
                builder.scoCommanderEnhancementAssistTarget = nil
            end
        end
        active.assistants = {}
    end

    local function SCOReconcileAssistants(unit, active)
        for id, contribution in pairs(active.assistEntities) do
            local builder = active.assistants[id]
            if builder ~= contribution.builder
                or builder.scoCommanderEnhancementAssistTarget ~= unit
                or not SCOAssistCanWork(builder, unit)
                or builder.army.id ~= contribution.entity.armyId
            then
                SCORetireAssistEntity(unit, active, id)
            end
        end
        for id, builder in pairs(active.assistants) do
            if builder.scoCommanderEnhancementAssistTarget ~= unit
                or not SCOAssistCanWork(builder, unit)
            then
                SCOAssistStop(builder, unit)
            else
                local contribution = active.assistEntities[id]
                if not contribution then
                    -- FA charges each assisting builder's army. A separate
                    -- native entity also preserves independent economy stalls.
                    local entity = SCOResourceEntity(
                        builder.army.id, builder.id, "construction", nil, nil, false)
                    entity:SetCost({ alloys = active.cost.mass, energy = active.cost.energy })
                    entity:SetBuildTime(active.buildTime)
                    entity:SetEnabled(true)
                    entity:AddBuilder(builder)
                    contribution = { builder = builder, entity = entity,
                        buildPower = builder.construction.buildPower }
                    active.assistEntities[id] = contribution
                    builder.resourceEntities.scoCommanderEnhancementAssist = entity
                    builder:UpdateUIValues()
                elseif contribution.buildPower ~= builder.construction.buildPower then
                    contribution.entity:UpdateBuilder(builder)
                    contribution.buildPower = builder.construction.buildPower
                    builder:UpdateUIValues()
                end
            end
        end
        local buildPower = unit.construction.buildPower
        for _, contribution in pairs(active.assistEntities) do
            buildPower = buildPower + contribution.buildPower
        end
        if active.buildPower ~= buildPower then
            active.buildPower = buildPower
            active.estimatedSeconds = buildPower > 0 and active.buildTime / buildPower or nil
            SCOBumpRevision(unit)
        end
    end

    local function SCOPlanNextProgressTick(unit)
        local state = unit.scoCommanderEnhancements
        local active = state and state.active
        local entity = unit.resourceEntities.scoCommanderEnhancement
        if not active or not entity then return end
        local remaining = math.max(0, active.buildTime - active.progress)
        local fullWork = math.max(0, entity.buildPower or 0)
            * SCONextConstructionSatisfaction(entity)
        for _, contribution in pairs(active.assistEntities) do
            local helper = contribution.entity
            fullWork = fullWork + math.max(0, helper.buildPower or 0)
                * SCONextConstructionSatisfaction(helper)
        end
        local userMultiplier = 1
        if fullWork > 0 and remaining < fullWork then
            userMultiplier = remaining / fullWork
        end
        SCOSetResourceUserMultiplier(entity, userMultiplier)
        for _, contribution in pairs(active.assistEntities) do
            SCOSetResourceUserMultiplier(contribution.entity, userMultiplier)
        end
    end

    local function SCOSetProgressEntityEnabled(unit, enabled)
        local entity = unit.resourceEntities.scoCommanderEnhancement
        SCOSetResourceEntityActive(entity, enabled, nil, enabled)
        if enabled then SCOPlanNextProgressTick(unit) end
        unit:UpdateUIValues()
    end

    local function SCOReleaseActive(unit, killThread)
        local state = unit.scoCommanderEnhancements
        local active = state and state.active
        if not active then return end
        if killThread and active.thread then KillThread(active.thread) end
        active.thread = nil
        SCOClearAssistants(unit, active)
        local entity = unit.resourceEntities.scoCommanderEnhancement
        if entity then
            entity:SetEnabled(true)
            entity:RemoveBuilder(unit)
            SCOSetResourceEntityActive(entity, false, nil, false)
        end
        state.active = nil
        SCORecompute(unit)
        unit:UpdateUIValues()
    end

    local function SCOCompleteActive(unit, active)
        local state = unit.scoCommanderEnhancements
        if not state or state.active ~= active or unit.dead then return end
        local previous = SCOCopy(state.installed)
        local previousVisualHidden = SCOCopy(state._visualHidden)
        local previousRadiusAdd = state._seraphimChronotronRadiusAdd
        local previousAuraSuppression = state._suppressBaseRegenAura
        local previousDamageSuppression =
            state._suppressSeraphimBaseDamageStabilization
        active.thread = nil
        SCOClearAssistants(unit, active)
        local entity = unit.resourceEntities.scoCommanderEnhancement
        if entity then
            entity:SetEnabled(true)
            entity:RemoveBuilder(unit)
            SCOSetResourceEntityActive(entity, false, nil, false)
        end
        state.active = nil
        if active.kind == "install" then
            state.installed[active.id] = true
            local commander = SCOCommanderContract(unit)
            local rule = commander and commander.enhancements[active.id]
            if unit.tpId == "ugl0000" and rule and rule.slot == "Back" then
                state._visualHidden.Back_Upgrade = nil
            end
            if unit.tpId == "usl0000"
                and (active.id == "RegenAura"
                    or active.id == "AdvancedRegenAura")
            then
                state._suppressBaseRegenAura = false
            elseif unit.tpId == "usl0000"
                and active.id == "DamageStabilization"
            then
                -- A fresh base installation recreates the stock base buff.
                state._suppressSeraphimBaseDamageStabilization = false
            end
        else
            for enhancementId in pairs(active.removeSet or {}) do
                state.installed[enhancementId] = nil
            end
            if unit.tpId == "ugl0000"
                and active.id == "MicrowaveLaserGenerator"
            then
                -- URL0001's stock remover also hides Back_Upgrade.
                state._visualHidden.Back_Upgrade = true
            elseif unit.tpId == "usl0000" and active.id == "BlastAttack" then
                -- XSL0001 adds +2 on install, then its remover's absent
                -- NewDamageRadius falls back to +5 instead of subtracting.
                state._seraphimChronotronRadiusAdd =
                    state._seraphimChronotronRadiusAdd + 7
            elseif unit.tpId == "usl0000"
                and active.id == "AdvancedRegenAura"
            then
                state._suppressBaseRegenAura = true
            elseif unit.tpId == "usl0000" and active.id == "RegenAura" then
                state._suppressBaseRegenAura = false
            elseif unit.tpId == "usl0000"
                and active.id == "DamageStabilizationAdvanced"
            then
                -- XSL0001 removes both buff objects while retaining the base
                -- enhancement flag. Persist that discrepancy so reinstalling
                -- Advanced stacks only its +20000/+150 until the base stage is
                -- explicitly removed and installed again.
                state._suppressSeraphimBaseDamageStabilization = true
            elseif unit.tpId == "usl0000"
                and active.id == "DamageStabilization"
            then
                state._suppressSeraphimBaseDamageStabilization = false
            end
        end
        local ok = pcall(SCORecompute, unit)
        if not ok then
            state.installed = previous
            state._visualHidden = previousVisualHidden
            state._seraphimChronotronRadiusAdd = previousRadiusAdd
            state._suppressBaseRegenAura = previousAuraSuppression
            state._suppressSeraphimBaseDamageStabilization =
                previousDamageSuppression
            pcall(SCORecompute, unit)
        end
        unit:UpdateUIValues()
        SCOBumpRevision(unit)
    end

    local function SCOProgressThread(unit, active)
        while not unit.dead do
            local state = unit.scoCommanderEnhancements
            if not state or state.active ~= active then return end
            -- Economy.Update runs before client commands and Lua threads. The
            -- entity's current multiplier is therefore payment already made
            -- for this tick. Consume it before observing a new pause toggle;
            -- otherwise pausing between those phases would charge resources
            -- without granting the matching work.
            if not active.paused then
                local entity = unit.resourceEntities.scoCommanderEnhancement
                local currentBuildPower = unit.construction.buildPower
                local multiplier = entity.productionMultiplier or 0
                local userMultiplier = entity.userMultiplier or 1
                local paidWork = entity.buildPower * multiplier * userMultiplier
                for _, contribution in pairs(active.assistEntities) do
                    local helper = contribution.entity
                    paidWork = paidWork + helper.buildPower
                        * (helper.productionMultiplier or 0) * (helper.userMultiplier or 1)
                end
                active.progress = math.min(
                    active.buildTime,
                    active.progress + paidWork)
                local bucket = math.floor(math.min(1,
                    active.progress / active.buildTime) * 100)
                if bucket > active.lastPublishedBucket then
                    active.lastPublishedBucket = bucket
                    SCOBumpRevision(unit)
                end
                if active.progress + 0.000001 >= active.buildTime then
                    SCOCompleteActive(unit, active)
                    return
                end
                -- Economy.Update has already charged this tick using the
                -- entity's old builder contribution. Apply a build-power
                -- change only after consuming that paid work, so the next
                -- economy tick and the next progress tick stay identical.
                if currentBuildPower ~= active.sourceBuildPower then
                    entity:UpdateBuilder(unit)
                    active.sourceBuildPower = currentBuildPower
                end
            end
            SCOReconcileAssistants(unit, active)
            local paused = unit:GetPause() == true
            if paused ~= active.paused then
                active.paused = paused
                SCOSetProgressEntityEnabled(unit, not paused)
                SCOBumpRevision(unit)
            elseif not paused then
                -- Resource satisfactions describe the next economy tick.
                -- Clamp that tick to the remaining work so it cannot charge
                -- past the authored FA cost.
                SCOPlanNextProgressTick(unit)
            end
            WaitTicks(1)
        end
    end

    local function SCOStartWork(unit, state, enhancementId, kind, cost, removeSet)
        local entity = unit.resourceEntities.scoCommanderEnhancement
        if not entity then
            entity = SCOResourceEntity(
                unit.army.id,
                unit.id,
                "construction",
                nil,
                nil,
                false)
            unit.resourceEntities.scoCommanderEnhancement = entity
        end
        SCOSetResourceEntityActive(entity, false, nil, false)
        entity:SetCost({ alloys = cost.mass, energy = cost.energy })
        entity:SetBuildTime(cost.buildTime)
        -- ResourceEntity:AddBuilder calls RecalculateBuildDrain, whose economy
        -- update requires the entity to be registered first.
        entity:SetEnabled(true)
        entity:AddBuilder(unit)
        local buildPower = unit.construction.buildPower
        local active = {
            id = enhancementId,
            kind = kind,
            progress = 0,
            buildTime = cost.buildTime,
            buildPower = buildPower,
            sourceBuildPower = buildPower,
            cost = { mass = cost.mass, energy = cost.energy },
            assistants = {},
            assistEntities = {},
            estimatedSeconds = buildPower > 0 and cost.buildTime / buildPower or nil,
            paused = unit:GetPause() == true,
            lastPublishedBucket = 0,
            removeSet = removeSet,
            thread = nil,
        }
        state.active = active
        SCOApplyWeapons(unit, state, SCOCommanderContract(unit))
        SCOSetMovementLock(unit, true)
        SCOSetProgressEntityEnabled(unit, not active.paused)
        active.thread = unit:NewThread(SCOProgressThread, active)
        SCOBumpRevision(unit)
        return true
    end

    local function SCOHostStart(clientID, unitId, enhancementId)
        if type(enhancementId) ~= "string" or #enhancementId > 96 then
            return false, "invalid-enhancement"
        end
        local unit, state, commander = SCOValidateOwner(clientID, unitId)
        if not unit then return false, state end
        if state.active then return false, "busy" end
        if not SCOUnitIsCompleted(unit) then return false, "under-construction" end
        if not SCOIsIdle(unit) then return false, "unit-not-idle" end
        local rule, reason = SCOInstallAllowed(state, commander, enhancementId)
        if not rule then return false, reason end
        local cost, costReason = SCOValidateRule(rule, false)
        if not cost then return false, costReason end
        return SCOStartWork(unit, state, enhancementId, "install", cost, nil)
    end

    local function SCOHostRemove(clientID, unitId, enhancementId)
        if type(enhancementId) ~= "string" or #enhancementId > 96 then
            return false, "invalid-enhancement"
        end
        local unit, state, commander = SCOValidateOwner(clientID, unitId)
        if not unit then return false, state end
        if state.active then return false, "busy" end
        if not SCOUnitIsCompleted(unit) then return false, "under-construction" end
        if not SCOIsIdle(unit) then return false, "unit-not-idle" end
        local rule, removeSet, reason =
            SCORemovalSet(state, commander, enhancementId)
        if not rule then return false, reason end
        local cost, costReason = SCOValidateRule(rule, true)
        if not cost then return false, costReason end
        return SCOStartWork(
            unit,
            state,
            enhancementId,
            "remove",
            cost,
            removeSet)
    end

    local function SCOHostCancel(clientID, unitId)
        local unit, state = SCOValidateOwner(clientID, unitId)
        if not unit then return false, state end
        if not state.active then return false, "not-busy" end
        SCOReleaseActive(unit, true)
        SCOBumpRevision(unit)
        return true
    end

    local function SCOHostGetState(clientID, unitId)
        local unit, state = SCOValidateOwner(clientID, unitId)
        if not unit then return nil, state end
        return SCOStateSnapshot(unit)
    end

    local function SCOHostGetVisualState(clientID, unitId)
        if not SCOInteger(clientID, 0, 2147483647)
            or type(unitId) ~= "table"
            or not SCOInteger(unitId.index, 1, 2147483647)
            or not SCOInteger(unitId.version, 0, 2147483647)
        then
            return nil, "invalid-request"
        end
        local unit = GetUnitById(unitId)
        if not unit or not SCOCommanderIds[unit.tpId] then
            return nil, "unit-not-found"
        end
        if unit.dead then return nil, "unit-dead" end
        local ok = pcall(SCOEnsureState, unit)
        if not ok then return nil, "runtime-unavailable" end
        return SCOVisualSnapshot(unit)
    end

    local function SCOTransferInstalledSet(commander, candidate)
        if type(candidate) ~= "table" then return nil end
        local installed = {}
        local bySlot = {}
        for enhancementId, value in pairs(candidate) do
            local rule = type(enhancementId) == "string"
                and commander.enhancements[enhancementId]
            if value ~= true or type(rule) ~= "table" then return nil end
            installed[enhancementId] = true
            bySlot[rule.slot] = bySlot[rule.slot] or {}
            table.insert(bySlot[rule.slot], enhancementId)
        end
        for enhancementId in pairs(installed) do
            local rule = commander.enhancements[enhancementId]
            if rule.prerequisite and not installed[rule.prerequisite] then
                return nil
            end
            for _, conflict in ipairs(rule.conflicts or {}) do
                if installed[conflict] then return nil end
            end
        end
        local function isAncestor(ancestor, descendant)
            local current = descendant
            local seen = {}
            while current do
                if current == ancestor then return true end
                if seen[current] then return false end
                seen[current] = true
                local rule = commander.enhancements[current]
                current = rule and rule.prerequisite
            end
            return false
        end
        for _, members in pairs(bySlot) do
            for left = 1, #members do
                for right = left + 1, #members do
                    if not isAncestor(members[left], members[right])
                        and not isAncestor(members[right], members[left])
                    then
                        return nil
                    end
                end
            end
        end
        return installed
    end

    local function SCOHostTransfer(source, destination)
        if type(source) ~= "table"
            or type(destination) ~= "table"
            or source == destination
            or source.dead == true
            or destination.dead == true
            or not SCOCommanderIds[source.tpId]
            or source.tpId ~= destination.tpId
            or not SCOUnitIsCompleted(source)
            or not SCOUnitIsCompleted(destination)
        then
            return false
        end
        local sourceState = source.scoCommanderEnhancements
        if type(sourceState) ~= "table"
            or sourceState.version ~= SCOCommanderEnhancementHostVersion
        then
            return false
        end
        local contractOk, commander = pcall(SCOCommanderContract, source)
        local stateOk, destinationState, destinationCommander =
            pcall(SCOEnsureState, destination)
        if not contractOk or not stateOk or commander ~= destinationCommander
            or type(destinationState) ~= "table"
            or destinationState.version ~= SCOCommanderEnhancementHostVersion
            or destinationState.active ~= nil
            or next(destinationState.installed or {}) ~= nil
            or next(destinationState.slots or {}) ~= nil
        then
            return false
        end
        local installed = SCOTransferInstalledSet(
            commander,
            sourceState.installed)
        if not installed then return false end
        local shieldTransfer, shieldTransferOk =
            SCOCaptureShieldTransferState(source, sourceState, commander)
        if not shieldTransferOk then return false end
        if shieldTransfer
            and (type(destination.SetToggle) ~= "function"
                or type(destination.GetShieldToggle) ~= "function"
                or type(destination:GetShieldToggle()) ~= "boolean")
        then
            return false
        end

        local radiusAdd = sourceState._seraphimChronotronRadiusAdd or 0
        if not SCOFinite(radiusAdd) or radiusAdd < 0 or radiusAdd > 1000000 then
            return false
        end
        if (sourceState._suppressBaseRegenAura ~= nil
                and type(sourceState._suppressBaseRegenAura) ~= "boolean")
            or (sourceState._suppressSeraphimBaseDamageStabilization ~= nil
                and type(sourceState._suppressSeraphimBaseDamageStabilization)
                    ~= "boolean")
        then
            return false
        end
        local visualHidden = {}
        if source.tpId == "ugl0000"
            and type(sourceState._visualHidden) == "table"
            and sourceState._visualHidden.Back_Upgrade == true
        then
            visualHidden.Back_Upgrade = true
        end
        local previous = {
            installed = destinationState.installed,
            slots = destinationState.slots,
            engineeringTier = destinationState.capabilities.engineeringTier,
            visualHidden = destinationState._visualHidden,
            radiusAdd = destinationState._seraphimChronotronRadiusAdd,
            suppressAura = destinationState._suppressBaseRegenAura,
            suppressBaseDamage =
                destinationState._suppressSeraphimBaseDamageStabilization,
            shieldToggle = shieldTransfer
                and destination:GetShieldToggle() or nil,
        }
        destinationState.installed = installed
        destinationState._visualHidden = visualHidden
        destinationState._seraphimChronotronRadiusAdd = radiusAdd
        destinationState._suppressBaseRegenAura =
            sourceState._suppressBaseRegenAura == true
        destinationState._suppressSeraphimBaseDamageStabilization =
            sourceState._suppressSeraphimBaseDamageStabilization == true
        local applied = pcall(function()
            SCORecompute(destination)
            if shieldTransfer
                and not SCORestoreShieldTransferState(
                    destination,
                    shieldTransfer)
            then
                error("commander shield transfer could not be restored")
            end
        end)
        if not applied then
            destinationState.installed = previous.installed
            destinationState.slots = previous.slots
            destinationState.capabilities.engineeringTier =
                previous.engineeringTier
            destinationState._visualHidden = previous.visualHidden
            destinationState._seraphimChronotronRadiusAdd =
                previous.radiusAdd
            destinationState._suppressBaseRegenAura = previous.suppressAura
            destinationState._suppressSeraphimBaseDamageStabilization =
                previous.suppressBaseDamage
            pcall(SCORecompute, destination)
            if previous.shieldToggle ~= nil then
                pcall(
                    destination.SetToggle,
                    destination,
                    "Shield",
                    previous.shieldToggle)
            end
            return false
        end
        SCOBumpRevision(destination)
        return true
    end

-- Insert inside the enhancement host scope before its HostCommander hooks.
-- Private framework functions remain the single owner of authenticated payment.
local SCOSupportIds = {ucl4002=true,uel5007=true,ugl5004=true,usl4002=true}
for id in pairs(SCOSupportIds) do
    SCOCommanderIds[id] = true
    SCOShieldIdByEnhancement[id] = {}
    for enhancement, rule in pairs(SCOContract().commanders[id].enhancements) do
        if rule.effects.shield then
            SCOShieldIdByEnhancement[id][enhancement] = id.."_"..enhancement
        end
    end
end

local SCOSupportPreviousCapability = SCOEnhancementCapability
SCOEnhancementCapability = function(unit, rule)
    local capability = SCOSupportPreviousCapability(unit, rule)
    if not SCOSupportIds[unit.tpId] then return capability end
    if rule.unsupportedReason then
        capability.install = false
        capability.partial = false
        capability.reason = rule.unsupportedReason
    elseif rule.id == "Pod" then
        capability.install = type(unit.SCOApplyPaidPodEnhancement) == "function"
        capability.domains.spawn = capability.install
        if capability.install then capability.reason = nil
        else capability.reason = "Paid native Pod lifecycle unavailable." end
    elseif rule.id == "Teleporter" then
        -- The ability extension validates source cost, destination and ownership.
        capability.install, capability.partial = true, false
        capability.domains.teleport, capability.reason = true, nil
    elseif rule.limitations and #rule.limitations > 0 then
        capability.partial = true
        capability.reason = table.concat(rule.limitations, " ")
    end
    return capability
end

local SCOSupportPreviousRecompute = SCORecompute
SCORecompute = function(unit)
    if not SCOSupportIds[unit.tpId] then return SCOSupportPreviousRecompute(unit) end
    local state = unit.scoCommanderEnhancements
    local commander = SCOCommanderContract(unit)
    local previous = state._supportInstalled or {}
    local oldFocus = state._supportFocusRetained or 0
    local oldRadius = state._supportRadiusRetained or 0
    local focus, radius = oldFocus, oldRadius
    if previous.FocusConvertor and not state.installed.FocusConvertor then
        -- Stock URL0301 removes with AddDamageMod(0), retaining the old bonus.
        focus = focus + commander.enhancements.FocusConvertor.source.blueprint.NewDamageMod
    end
    if previous.HighExplosiveOrdnance and not state.installed.HighExplosiveOrdnance then
        local source = commander.enhancements.HighExplosiveOrdnance.source
        radius = radius + source.blueprint.NewDamageRadius + source.removal.NewDamageRadius
    end
    if unit.tpId == "uel5007" and (previous.Pod == true) ~= (state.installed.Pod == true) then
        if not unit:SCOApplyPaidPodEnhancement(state.installed.Pod ~= true) then
            error("Paid SACU Pod lifecycle rejected commit")
        end
    end
    SCOSupportPreviousRecompute(unit)
    state.capabilities.engineeringTier = 3
    local weapon = SCOWeaponForLabel(unit, unit.tpId == "ugl5004" and "RightDisintegrator" or "RightHeavyPlasmaCannon")
    if weapon then
        weapon.tp.damage = (weapon.tp.damage or 0) + focus
        weapon.tp.damageRadius = (weapon.tp.damageRadius or 0) + radius
    end
    -- Source HideBones removals remain hidden even when another slot previously
    -- showed the same part. A fresh show operation restores it.
    for id, rule in pairs(commander.enhancements) do
        if state.installed[id] and not previous[id] then
            for _, bone in ipairs(rule.visual.show or {}) do state._visualHidden[bone] = nil end
            for _, bone in ipairs(rule.visual.hide or {}) do state._visualHidden[bone] = true end
        elseif previous[id] and not state.installed[id] then
            for _, bone in ipairs(rule.source.removal.HideBones or {}) do state._visualHidden[bone] = true end
        end
    end
    state._supportFocusRetained, state._supportRadiusRetained = focus, radius
    state._supportInstalled = SCOCopy(state.installed)
end

-- All source SACUs derive from HostUnit subclasses, not HostCommander. Hooks
-- act only after the native base constructor has created weapons/economy.
local SCOSupportUnit = HostUnit or Import("host/units/unitsClasses/unitsBaseClass.lua").HostUnit
if type(SCOSupportUnit) ~= "table" then error("SACU HostUnit unavailable") end
local SCOSupportInit = SCOSupportUnit.__init
function SCOSupportUnit:__init(...)
    SCOSupportInit(self, ...)
    if SCOSupportIds[self.tpId] then SCOEnsureState(self) end
end
local SCOSupportFinish = SCOSupportUnit.OnStopBeingBuilt
function SCOSupportUnit:OnStopBeingBuilt(...)
    local result = SCOSupportFinish(self, ...)
    if SCOSupportIds[self.tpId] then
        SCOEnsureState(self)
        SCORecompute(self)
        SCOEmitState(self)
    end
    return result
end
local SCOSupportDestroy = SCOSupportUnit.OnDestroy
function SCOSupportUnit:OnDestroy(...)
    if SCOSupportIds[self.tpId] and self.scoCommanderEnhancements then
        if self.scoCommanderEnhancements.active then SCOReleaseActive(self, true) end
    end
    return SCOSupportDestroy(self, ...)
end
local SCOSupportShieldState = SCOSupportUnit.CheckShieldState
function SCOSupportUnit:CheckShieldState(skipRecharge)
    if not SCOSupportIds[self.tpId] then return SCOSupportShieldState(self, skipRecharge) end
    if self.scoCommanderEnhancements then return SCOApplyShieldState(self, skipRecharge) end
    for _, shield in ipairs(self.shields or {}) do
        if shield.tp.scoCommanderEnhancementShieldId then shield:SetEnableable(false) end
    end
end
for _, method in ipairs({"CanBeAssignedToOrder", "CanMove", "CanAttack"}) do
    local previousMethod = SCOSupportUnit[method]
    SCOSupportUnit[method] = function(self, ...)
        if SCOSupportIds[self.tpId] and self.scoCommanderEnhancements and self.scoCommanderEnhancements.active then return false end
        return previousMethod(self, ...)
    end
end
function SCOSupportUnit:SCOOnSourcePodLost()
    if self.tpId ~= "uel5007" or not self.scoCommanderEnhancements then return end
    local state = self.scoCommanderEnhancements
    state.installed.Pod = nil
    if state._supportInstalled then state._supportInstalled.Pod = nil end
    SCORecompute(self)
    SCOBumpRevision(self)
end

    local SCOPreviousCommanderInit = HostCommander.__init
    local SCOPreviousCommanderOnStopBeingBuilt = HostCommander.OnStopBeingBuilt
    local SCOPreviousCommanderOnDestroy = HostCommander.OnDestroy
    local SCOPreviousCommanderCheckShieldState = HostCommander.CheckShieldState
    local SCOPreviousCommanderCanBeAssignedToOrder =
        HostCommander.CanBeAssignedToOrder
    local SCOPreviousCommanderCanMove = HostCommander.CanMove
    local SCOPreviousCommanderCanAttack = HostCommander.CanAttack
    local SCOPreviousCommanderUpdateAnimations = HostCommander.UpdateAnimations
    if type(SCOPreviousCommanderUpdateAnimations) ~= "function"
        or type(SCOLayers) ~= "table"
        or type(SCOLayers.TargetingLayer) ~= "table"
    then
        error("SCOM commander enhancements could not resolve movement layers")
    end

    local function SCOUpdateCybranTargetingLayer(unit)
        if unit.tpId ~= "ugl0000" or unit.dead then return end
        local targetLayer = SCOLayers.TargetingLayer.Land
        local waterResult, hasWater = Engine.HasWater()
        if waterResult == EngineErrorCode.Success and hasWater then
            local levelResult, waterLevel = Engine.GetWaterLevel()
            local position = unit:GetPosition()
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
                    targetLayer = SCOLayers.TargetingLayer.Seabed
                end
            end
        end
        if unit.targetingLayer ~= targetLayer then
            unit:SetTargetingLayer(targetLayer)
        end
    end

    function HostCommander:__init(...)
        SCOPreviousCommanderInit(self, ...)
        if SCOCommanderIds[self.tpId] then
            SCOEnsureState(self)
            SCORecompute(self)
        end
    end

    function HostCommander:OnStopBeingBuilt(...)
        if SCOCommanderIds[self.tpId] then SCOEnsureState(self) end
        SCOPreviousCommanderOnStopBeingBuilt(self, ...)
        if SCOCommanderIds[self.tpId] then
            SCORecompute(self)
            SCOEmitState(self)
        end
    end

    function HostCommander:OnDestroy(...)
        if SCOCommanderIds[self.tpId] and self.scoCommanderEnhancements then
            local state = self.scoCommanderEnhancements
            if state._auraThread then
                KillThread(state._auraThread)
                state._auraThread = nil
            end
            if state.active then SCOReleaseActive(self, true) end
            state._activeShieldId = nil
            state._shieldMaintenance = nil
            SCOApplyShieldState(self, false)
        end
        return SCOPreviousCommanderOnDestroy(self, ...)
    end

    function HostCommander:CheckShieldState(skipRecharge)
        if not SCOCommanderIds[self.tpId] then
            return SCOPreviousCommanderCheckShieldState(self, skipRecharge)
        end
        if not self.scoCommanderEnhancements then
            -- During HostUnit construction, shields do not exist yet.  Once
            -- they do, keep every predeclared enhancement shield hard-down.
            for _, shield in ipairs(self.shields or {}) do
                if shield.tp and shield.tp.scoCommanderEnhancementShieldId then
                    shield:SetEnableable(false)
                end
            end
            return
        end
        SCOApplyShieldState(self, skipRecharge)
    end

    function HostCommander:CanBeAssignedToOrder(order)
        if self.scoCommanderEnhancements
            and self.scoCommanderEnhancements.active
        then
            return false
        end
        return SCOPreviousCommanderCanBeAssignedToOrder(self, order)
    end

    function HostCommander:CanMove()
        if self.scoCommanderEnhancements
            and self.scoCommanderEnhancements.active
        then
            return false
        end
        return SCOPreviousCommanderCanMove(self)
    end

    function HostCommander:CanAttack()
        if self.scoCommanderEnhancements
            and self.scoCommanderEnhancements.active
        then
            return false
        end
        return SCOPreviousCommanderCanAttack(self)
    end

    function HostCommander:UpdateAnimations(...)
        SCOUpdateCybranTargetingLayer(self)
        return SCOPreviousCommanderUpdateAnimations(self, ...)
    end

    local function SCOInstallExport(name, handler)
        local current = rawget(_G, name)
        if current ~= nil then
            error("SCOM commander enhancement host export is occupied: " .. name)
        end
        _G[name] = handler
    end

    SCOInstallExport("SCO_CommanderEnhancementHostStart", SCOHostStart)
    SCOInstallExport("SCO_CommanderEnhancementAssistStart", SCOAssistStart)
    SCOInstallExport("SCO_CommanderEnhancementAssistStop", SCOAssistStop)
    SCOInstallExport("SCO_CommanderEnhancementHostCancel", SCOHostCancel)
    SCOInstallExport("SCO_CommanderEnhancementHostRemove", SCOHostRemove)
    SCOInstallExport("SCO_CommanderEnhancementHostGetState", SCOHostGetState)
    SCOInstallExport(
        "SCO_CommanderEnhancementHostGetVisualState",
        SCOHostGetVisualState)
    SCOInstallExport("SCO_CommanderEnhancementHostTransfer", SCOHostTransfer)

    rawset(
        SCOCommanderEnhancementHostEnvironment,
        "SCO_CommanderEnhancementHostInstalled",
        SCOCommanderEnhancementHostVersion)
end

-- SCOM commander enhancement assist interactions 1.0.0
-- The enhancement owner accounts for paid work. This adapter owns only native
-- order intent, approach/range checks and construction-beam start/stop events.
local SCOAssistEnvironment = type(getfenv) == 'function' and getfenv(1) or _ENV
local SCOAssistMarker = rawget(SCOAssistEnvironment, 'SCO_CommanderEnhancementAssistInteractionsInstalled')
if SCOAssistMarker ~= nil and SCOAssistMarker ~= '1.0.0' then
    error('A different commander enhancement assist adapter is already installed')
end
if SCOAssistMarker == nil then
    local HostUnit = Import('host/units/unitsClasses/unitsBaseClass.lua').HostUnit
    local WorkCommands = Import('common/commands/definitions/work.lua')
    local Start = assert(SCO_CommanderEnhancementAssistStart,
        'Commander enhancement assist accounting must be loaded first')
    local Stop = assert(SCO_CommanderEnhancementAssistStop,
        'Commander enhancement assist accounting must be loaded first')
    local commanderIds = {uel0000=true, ugl0000=true, ucl0000=true, usl0000=true}

    local function ActiveWork(target)
        local state = target and commanderIds[target.tpId] and target.scoCommanderEnhancements
        return target and not target.dead and not target.deleted and state and state.active
    end

    function SCO_CommanderEnhancementHasActiveWork(target)
        local active = ActiveWork(target)
        return active ~= nil and active ~= false and not active.paused and not target:GetPause()
    end

    local function CanAssist(builder, target)
        return builder ~= target and not builder.dead and not builder.deleted
            and builder:IsCompleted() and builder:CanConstructOthers()
            and target and not target.dead and not target.deleted
            and builder.army:IsAlly(target.army)
    end

    function HostUnit:SCOHasCommanderEnhancementWork(target)
        return ActiveWork(target) and CanAssist(self, target)
    end

    function HostUnit:SCOStopCommanderEnhancementAssist()
        local target = self.scoCommanderEnhancementAssistTarget
        if target then Stop(self, target) end
        self.scoCommanderEnhancementAssistTarget = nil
        self.scoCommanderEnhancementAssistWork = nil
        self.scoCommanderEnhancementAssistMode = nil
        if self.scoCommanderEnhancementAssistBeam then
            self.scoCommanderEnhancementAssistBeam = nil
            WorkCommands.OnStopRepair.Send(self.id)
        end
    end

    local function HasOrder(builder, target, mode)
        if mode == 'repair' then
            return builder.repairBehaviorIsActive and builder.repairBehaviorTarget == target
        end
        return builder.assistBehaviorIsActive and builder.assistBehaviorAssistedUnit == target
    end

    function HostUnit:SCOAssistCommanderEnhancement(target, mode)
        self:SCOStopCommanderEnhancementAssist()
        self:FollowBehaviorStop()
        while HasOrder(self, target, mode) and self:SCOHasCommanderEnhancementWork(target) do
            if self:CanMove() and not self.followBehaviorIsActive then
                self:FollowBehaviorStart(target, self.construction.range)
            end
            local active = ActiveWork(target)
            local inRange = self.constructionDetectorCollider:IsOverlappingUnit(target)
            local ready = inRange and not self:GetPause()
                and SCO_CommanderEnhancementHasActiveWork(target)
            if self.scoCommanderEnhancementAssistWork ~= active or not ready then
                self:SCOStopCommanderEnhancementAssist()
            end
            if ready and self.scoCommanderEnhancementAssistTarget == nil then
                self.scoCommanderEnhancementAssistTarget = target
                self.scoCommanderEnhancementAssistWork = active
                self.scoCommanderEnhancementAssistMode = mode
                if Start(self, target) then
                    self.scoCommanderEnhancementAssistBeam = true
                    WorkCommands.OnStartRepair.Send(self.id, target.id)
                else
                    self:SCOStopCommanderEnhancementAssist()
                end
            end
            WaitTicks(1)
        end
        self:SCOStopCommanderEnhancementAssist()
        self:FollowBehaviorStop()
    end

    local repairValid = HostUnit.RepairBehaviorIsValidFor
    function HostUnit:RepairBehaviorIsValidFor(target)
        if self:SCOHasCommanderEnhancementWork(target) then return true end
        return repairValid(self, target)
    end

    local assistStop, repairStop, destroy = HostUnit.AssistBehaviorStop,
        HostUnit.RepairBehaviorStop, HostUnit.OnDestroy
    function HostUnit:AssistBehaviorStop(...)
        if self.scoCommanderEnhancementAssistMode == 'assist' then
            self:SCOStopCommanderEnhancementAssist()
        end
        return assistStop(self, ...)
    end
    function HostUnit:RepairBehaviorStop(...)
        if self.scoCommanderEnhancementAssistMode == 'repair' then
            self:SCOStopCommanderEnhancementAssist()
        end
        return repairStop(self, ...)
    end
    function HostUnit:OnDestroy(...)
        self:SCOStopCommanderEnhancementAssist()
        return destroy(self, ...)
    end
    rawset(SCOAssistEnvironment, 'SCO_CommanderEnhancementAssistInteractionsInstalled', '1.0.0')
end

-- Supreme Commander Overhaul commander shoulder-pod host 1.6.0
-- Loaded after commander_enhancement_host_appendix.lua. UEA0001 pods retain
-- their stock FA lifecycle: dock to their assigned ACU shoulder while idle,
-- release for explicit or automatic engineering work, then return to dock.
local SCOPodHostEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOPodHostVersion = "1.6.0"
local SCOPodHostMarker = rawget(
    SCOPodHostEnvironment,
    "SCO_CommanderPodHostInstalled")
if SCOPodHostMarker ~= nil and SCOPodHostMarker ~= SCOPodHostVersion then
    error("Unsupported SCOM commander-pod host marker "
        .. tostring(SCOPodHostMarker))
end

if SCOPodHostMarker == nil then
    if type(HostCommander) ~= "table" then
        error("SCOM commander pods could not resolve HostCommander")
    end

    local SCOLobby = Import("common/lobby.lua")
    local SCOOrderManager =
        Import("host/managers/orders/hostOrderManager.lua")
    local SCOOrderTasks = Import("common/commonOrders.lua").OrderTasks
    local SCOPodTemplateId = "uea0001"
    local SCOPodSpawnRetryLimit = 3
    local SCOPodCleanupRetryLimit = 3
    local SCOPodDockCaptureRange = 0.35
    local SCOPodBones = {
        LeftPod = "AttachSpecial02",
        RightPod = "AttachSpecial01",
    }
    local SCOPodDockRotationOffsets = {}

    local function SCOInteger(value, minimum, maximum)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
            and value == math.floor(value)
            and value >= minimum
            and value <= maximum
    end

    local function SCOEngineCallSucceeded(errorCode)
        local success = type(EngineErrorCode) == "table"
            and EngineErrorCode.Success or nil
        if success ~= nil then return errorCode == success end
        return errorCode == nil or errorCode == 0
    end

    local function SCOFiniteVector(value)
        return type(value) == "table"
            and type(value.x) == "number"
            and value.x == value.x
            and value.x ~= math.huge
            and value.x ~= -math.huge
            and type(value.y) == "number"
            and value.y == value.y
            and value.y ~= math.huge
            and value.y ~= -math.huge
            and type(value.z) == "number"
            and value.z == value.z
            and value.z ~= math.huge
            and value.z ~= -math.huge
    end

    local function SCOResolvePodDockRotationOffset(logicalName)
        local cached = SCOPodDockRotationOffsets[logicalName]
        if cached ~= nil then return cached end

        local contract = rawget(_G, "SCO_CommanderEnhancementContract")
        local commanders = type(contract) == "table" and contract.commanders
        local commander = type(commanders) == "table" and commanders.uel0000
        local enhancements = type(commander) == "table"
            and commander.enhancements
        local enhancement = type(enhancements) == "table"
            and enhancements[logicalName]
        local effects = type(enhancement) == "table" and enhancement.effects
        local spawn = type(effects) == "table" and effects.spawn
        local degrees = type(spawn) == "table"
            and spawn.dockRotationDegrees
        if not SCOFiniteVector(degrees) then
            return nil, "dock-rotation-contract-unavailable"
        end
        if type(Engine) ~= "table"
            or type(Engine.EulerToQuaternion) ~= "function"
            or type(EngineClasses) ~= "table"
            or type(EngineClasses.float3) ~= "function"
            or type(RotationOrder) ~= "table"
            or RotationOrder.Default == nil
        then
            return nil, "dock-rotation-api-unavailable"
        end

        local ok, offset = pcall(
            Engine.EulerToQuaternion,
            EngineClasses.float3(
                math.rad(degrees.x),
                math.rad(degrees.y),
                math.rad(degrees.z)),
            RotationOrder.Default)
        if not ok or type(offset) ~= "table" then
            return nil, "dock-rotation-offset-error: " .. tostring(offset)
        end
        SCOPodDockRotationOffsets[logicalName] = offset
        return offset
    end

    local function SCOComposePodDockRotation(logicalName, boneRotation)
        if type(boneRotation) ~= "table"
            or type(Engine) ~= "table"
            or type(Engine.QuaternionMultiply) ~= "function"
        then
            return nil, "dock-rotation-api-unavailable"
        end
        local offset, offsetError =
            SCOResolvePodDockRotationOffset(logicalName)
        if offset == nil then return nil, offsetError end
        local ok, rotation = pcall(
            Engine.QuaternionMultiply,
            boneRotation,
            offset)
        if not ok or type(rotation) ~= "table" then
            return nil, "dock-rotation-compose-error: " .. tostring(rotation)
        end
        return rotation
    end

    local function SCOPlanarDistanceSquared(left, right)
        if not SCOFiniteVector(left) or not SCOFiniteVector(right) then
            return nil
        end
        local x = left.x - right.x
        local z = left.z - right.z
        return x * x + z * z
    end

    local function SCOPlanarPosition(position)
        if not SCOFiniteVector(position)
            or type(EngineClasses) ~= "table"
            or type(EngineClasses.float2) ~= "function"
        then
            return nil, "planar-position-api-unavailable"
        end
        local ok, result = pcall(
            EngineClasses.float2,
            position.x,
            position.z)
        if not ok or result == nil then
            return nil, "planar-position-error: " .. tostring(result)
        end
        return result
    end

    local function SCOIsPodAlive(pod)
        return type(pod) == "table"
            and pod.tpId == SCOPodTemplateId
            and pod.dead ~= true
            and pod.deleted ~= true
    end

    local function SCOIsPodDestroyed(pod)
        return type(pod) == "table"
            and pod.tpId == SCOPodTemplateId
            and (pod.dead == true or pod.deleted == true)
    end

    local function SCOOwnerClientId(unit)
        local player = type(SCOLobby) == "table"
            and type(SCOLobby.ArmyToPlayer) == "table"
            and unit.army
            and SCOLobby.ArmyToPlayer[unit.army.id]
        local clientID = player and player.clientID
        if SCOInteger(clientID, 0, 2147483647) then return clientID end
        return nil
    end

    local function SCOEmitPodState(unit)
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" then return end
        state.revision = ((state.revision or 0) + 1) % 2147483648

        local ownerClientID = SCOOwnerClientId(unit)
        local getState = rawget(_G, "SCO_CommanderEnhancementHostGetState")
        local emitState = rawget(_G, "SCO_CommanderEnhancementEmitState")
        if ownerClientID ~= nil
            and type(getState) == "function"
            and type(emitState) == "function"
        then
            local ok, snapshot = pcall(getState, ownerClientID, unit.id)
            if ok and type(snapshot) == "table" then
                pcall(emitState, ownerClientID, snapshot)
            end
        end

        local getVisual =
            rawget(_G, "SCO_CommanderEnhancementHostGetVisualState")
        local emitVisual =
            rawget(_G, "SCO_CommanderEnhancementEmitVisualState")
        if type(getVisual) == "function" and type(emitVisual) == "function" then
            for clientID in pairs(SCOLobby.Players or {}) do
                if SCOInteger(clientID, 0, 2147483647) then
                    local ok, snapshot = pcall(getVisual, clientID, unit.id)
                    if ok and type(snapshot) == "table" then
                        pcall(emitVisual, clientID, snapshot)
                    end
                end
            end
        end
    end

    local function SCOEnablePodCapabilities(unit)
        if unit.tpId ~= "uel0000" then return false end
        local state = unit.scoCommanderEnhancements
        local capabilities = state and state.capabilities
        local enhancements = capabilities and capabilities.enhancements
        if type(enhancements) ~= "table" then return false end
        local changed = false
        if capabilities.spawnPods ~= true then
            capabilities.spawnPods = true
            changed = true
        end
        for _, enhancementId in ipairs({ "LeftPod", "RightPod" }) do
            local capability = enhancements[enhancementId]
            if type(capability) == "table" then
                if capability.install ~= true then
                    capability.install = true
                    changed = true
                end
                if capability.partial ~= false then
                    capability.partial = false
                    changed = true
                end
                if capability.reason ~= nil then
                    capability.reason = nil
                    changed = true
                end
                if type(capability.domains) ~= "table" then
                    capability.domains = {}
                    changed = true
                end
                if capability.domains.spawn ~= true then
                    capability.domains.spawn = true
                    changed = true
                end
            end
        end
        return changed
    end

    local function SCOPodDiagnosticValue(value)
        local text = string.gsub(tostring(value), "[\r\n]+", " ")
        if string.len(text) > 240 then
            return string.sub(text, 1, 240)
        end
        return text
    end

    local function SCOPodCommanderId(unit)
        local id = unit and unit.id
        if type(id) == "table" and id.index ~= nil then
            return SCOPodDiagnosticValue(id.index)
        end
        return SCOPodDiagnosticValue(id)
    end

    local function SCOWarnPod(unit, logicalName, event, attempt, detail)
        local warn = rawget(_G, "Warn")
        if type(warn) ~= "function" then return end
        local message = "[SCOM Commander Pods] event=" .. event
            .. " commander=" .. SCOPodCommanderId(unit)
            .. " slot=" .. tostring(logicalName)
            .. " template=" .. SCOPodTemplateId
            .. " bone=" .. tostring(SCOPodBones[logicalName])
        if attempt ~= nil then
            message = message .. " attempt=" .. tostring(attempt)
                .. "/" .. tostring(SCOPodSpawnRetryLimit)
        end
        if detail ~= nil then
            message = message .. " detail=" .. SCOPodDiagnosticValue(detail)
        end
        pcall(warn, message)
    end

    local function SCOGetBoneTransform(unit, boneName)
        if type(unit.GetBoneId) ~= "function" then
            return nil, "bone-api-unavailable"
        end
        local boneOk, boneId = pcall(unit.GetBoneId, unit, boneName)
        if not boneOk then return nil, "bone-lookup-error: " .. tostring(boneId) end
        if not boneId then return nil, "bone-not-found" end
        local positionOk, result, position = pcall(
            Engine.GetGlobalEntityWorldPosition,
            boneId)
        if not positionOk then
            return nil, "bone-position-error: " .. tostring(result)
        end
        if result ~= EngineErrorCode.Success or position == nil then
            return nil, "bone-position-unavailable: " .. tostring(result)
        end
        if not SCOFiniteVector(position) then
            return nil, "bone-position-invalid"
        end
        local rotationOk, rotationResult, rotation = pcall(
            Engine.GetGlobalEntityWorldRotation,
            boneId)
        if not rotationOk then
            return nil, "bone-rotation-error: " .. tostring(rotationResult)
        end
        if not SCOEngineCallSucceeded(rotationResult)
            or type(rotation) ~= "table"
        then
            return nil, "bone-rotation-unavailable: "
                .. tostring(rotationResult)
        end
        return {
            position = position,
            rotation = rotation,
        }
    end

    local function SCOPreflightPodTemplate()
        if type(GetTemplate) ~= "function" then
            return false, "template-api-unavailable"
        end
        local templateOk, template = pcall(
            GetTemplate,
            SCOPodTemplateId,
            "Units")
        if not templateOk then
            return false, "template-lookup-error: " .. tostring(template)
        end
        if type(template) ~= "table" or type(template.general) ~= "table" then
            return false, "template-unavailable"
        end
        if template.general.prefabID == nil then
            return false, "prefab-unavailable"
        end
        if type(GetClass) ~= "function" then
            return false, "class-api-unavailable"
        end
        local classOk, unitClass = pcall(
            GetClass,
            SCOPodTemplateId,
            "Units")
        if not classOk then
            return false, "class-lookup-error: " .. tostring(unitClass)
        end
        if type(unitClass) ~= "table" and type(unitClass) ~= "function" then
            return false, "class-unavailable"
        end
        return true
    end

    local function SCOSpawnPod(unit, logicalName)
        local ready, readinessError = SCOPreflightPodTemplate()
        if not ready then return nil, readinessError end
        local transform, transformError =
            SCOGetBoneTransform(unit, SCOPodBones[logicalName])
        if not transform then return nil, transformError end
        local ok, pod = pcall(
            CreateUnit,
            unit.army.id,
            SCOPodTemplateId,
            transform.position,
            nil,
            1)
        if not ok then return nil, "create-error: " .. tostring(pod) end
        if not SCOIsPodAlive(pod) then return nil, "invalid-create-result" end

        pod.scoCommanderPodOwner = unit.id
        pod.scoCommanderPodLogicalName = logicalName
        return pod
    end

    local function SCOEnsurePodRuntimeState(state)
        state._pods = state._pods or {}
        state._podConfirmed = state._podConfirmed or {}
        state._podPendingConfirmation =
            state._podPendingConfirmation or {}
        state._podSpawnAttempts = state._podSpawnAttempts or {}
        state._podSpawnExhausted = state._podSpawnExhausted or {}
        state._podPendingCleanup = state._podPendingCleanup or {}
        state._podCleanupAttempts = state._podCleanupAttempts or {}
        state._podCleanupExhausted = state._podCleanupExhausted or {}
        state._podDockModes = state._podDockModes or {}
        state._podAutoOrders = state._podAutoOrders or {}
        state._podDockWarnings = state._podDockWarnings or {}
    end

    local function SCOResetPodRuntimeTracking(state, logicalName, pod)
        SCOEnsurePodRuntimeState(state)
        state._podDockModes[logicalName] = nil
        state._podAutoOrders[logicalName] = nil
        state._podDockWarnings[logicalName] = nil
        if type(pod) == "table" then
            pod.scoCommanderPodDockMode = nil
        end
    end

    local function SCOReportPodRuntimeWarning(
        unit, state, logicalName, event, detail)
        SCOEnsurePodRuntimeState(state)
        local warnings = state._podDockWarnings[logicalName]
        if type(warnings) ~= "table" then
            warnings = {}
            state._podDockWarnings[logicalName] = warnings
        end
        local diagnostic = SCOPodDiagnosticValue(detail)
        if warnings[event] == diagnostic then return end
        warnings[event] = diagnostic
        SCOWarnPod(unit, logicalName, event, nil, diagnostic)
    end

    local function SCOClearPodRuntimeWarning(state, logicalName, event)
        local warnings = type(state._podDockWarnings) == "table"
            and state._podDockWarnings[logicalName] or nil
        if type(warnings) ~= "table" then return end
        warnings[event] = nil
        if next(warnings) == nil then
            state._podDockWarnings[logicalName] = nil
        end
    end

    local function SCOCallPodMethod(pod, methodName, ...)
        local method = type(pod) == "table" and pod[methodName]
        if type(method) ~= "function" then return true end
        return pcall(method, pod, ...)
    end

    local function SCOCallEngineSetter(functionName, ...)
        local method = type(Engine) == "table" and Engine[functionName]
        if type(method) ~= "function" then
            return false, functionName .. "-unavailable"
        end
        local ok, errorCode = pcall(method, ...)
        if not ok then return false, functionName .. "-error: " .. tostring(errorCode) end
        if not SCOEngineCallSucceeded(errorCode) then
            return false, functionName .. "-failed: " .. tostring(errorCode)
        end
        return true
    end

    local function SCOSetPodDockMode(unit, state, logicalName, pod, mode)
        SCOEnsurePodRuntimeState(state)
        local previous = state._podDockModes[logicalName]
        state._podDockModes[logicalName] = mode
        if type(pod) == "table" then pod.scoCommanderPodDockMode = mode end
        if (previous == "docked") ~= (mode == "docked") then
            SCOEmitPodState(unit)
        end
    end

    local function SCOPreparePodAirborne(pod)
        SCOCallPodMethod(pod, "CancelLandWhenIdle")
        SCOCallPodMethod(pod, "TakeoffBehaviourStop")
        SCOCallPodMethod(pod, "LandingBehaviorStop")
        pod.isAirborne = true
        SCOCallPodMethod(pod, "SetAirborneLayers")
    end

    local function SCOPodOrders(pod)
        local orders = type(pod) == "table" and pod.orders
        if type(orders) ~= "table" then return nil, nil, nil end
        local queued = type(orders.queuedOrders) == "table"
            and orders.queuedOrders or {}
        return orders, orders.activeOrder, queued
    end

    local function SCOCommanderNeedsPodAssistance(unit)
        -- Behavior flags include walking to a queued target. Native work
        -- routines own these targets only while construction/repair is active,
        -- and clear them on pause, loss of range, completion or cancellation.
        -- Enhancements have a separate active work owner; their queue alone
        -- never releases the shoulder pods.
        local enhancementWork = SCO_CommanderEnhancementHasActiveWork
        return (type(enhancementWork) == 'function' and enhancementWork(unit))
            or unit.unitBeingBuilt ~= nil
            or unit.unitBeingRepaired ~= nil
            or unit.unitBeingReclaimed ~= nil
            or unit.unitBeingCaptured ~= nil
    end

    local function SCOClearAutomaticPodOrder(
        unit, state, logicalName, pod, promoteQueued)
        local orders, active, queued = SCOPodOrders(pod)
        local automatic = state._podAutoOrders[logicalName]
        if orders == nil or automatic == nil then
            state._podAutoOrders[logicalName] = nil
            return true
        end
        if active == automatic then
            local remove = type(SCOOrderManager) == "table"
                and SCOOrderManager.RemoveUnitFromActiveOrder
            if type(remove) ~= "function" then
                SCOReportPodRuntimeWarning(
                    unit, state, logicalName,
                    "assist-clear-error", "order-remove-unavailable")
                return false
            end
            local ok, removeError = pcall(remove, pod)
            if not ok then
                SCOReportPodRuntimeWarning(
                    unit, state, logicalName,
                    "assist-clear-error", removeError)
                return false
            end
        end
        state._podAutoOrders[logicalName] = nil
        SCOClearPodRuntimeWarning(state, logicalName, "assist-clear-error")
        if promoteQueued and #queued > 0 and orders.activeOrder == nil then
            local promote = type(SCOOrderManager) == "table"
                and SCOOrderManager.TryStartNextOrderForUnit
            if type(promote) == "function" then
                local ok, promoteError = pcall(promote, pod)
                if not ok then
                    SCOReportPodRuntimeWarning(
                        unit, state, logicalName,
                        "order-promote-error", promoteError)
                    return false
                end
            end
        end
        SCOClearPodRuntimeWarning(state, logicalName, "order-promote-error")
        return true
    end

    local function SCOEnsureAutomaticPodOrder(unit, state, logicalName, pod)
        local orders, active, queued = SCOPodOrders(pod)
        if orders == nil or active ~= nil or #queued > 0 then return false end
        if type(SCOOrderManager) ~= "table"
            or type(SCOOrderManager.HostIssueOrder) ~= "function"
            or type(SCOOrderTasks) ~= "table"
            or SCOOrderTasks.ASSISTUNIT == nil
        then
            SCOReportPodRuntimeWarning(
                unit, state, logicalName,
                "assist-error", "assist-order-api-unavailable")
            return false
        end
        local orderOk, orderError = pcall(function()
            SCOOrderManager.HostIssueOrder(
                SCOOrderTasks.ASSISTUNIT,
                { pod },
                false,
                unit:GetPosition(),
                { targetGlobalId = unit.id })
        end)
        if not orderOk then
            SCOReportPodRuntimeWarning(
                unit, state, logicalName, "assist-error", orderError)
            return false
        end
        active = pod.orders and pod.orders.activeOrder
        if type(active) ~= "table"
            or active.orderTask ~= SCOOrderTasks.ASSISTUNIT
            or active.targetUnit ~= unit
        then
            SCOReportPodRuntimeWarning(
                unit, state, logicalName,
                "assist-error", "assist-order-rejected")
            return false
        end
        state._podAutoOrders[logicalName] = active
        SCOClearPodRuntimeWarning(state, logicalName, "assist-error")
        return true
    end

    local function SCORestorePodFlightSpeed(pod)
        local movement = type(pod.tp) == "table" and pod.tp.movement
        local minimum = type(movement) == "table"
            and movement.minSpeed or 0
        return SCOCallEngineSetter(
            "SetMovementMinSpeed",
            pod.id,
            minimum)
    end

    local function SCOReleasePodForWork(unit, state, logicalName, pod)
        SCOPreparePodAirborne(pod)
        local speedOk, speedError = SCORestorePodFlightSpeed(pod)
        local enabledOk, enabledError = SCOCallEngineSetter(
            "SetMovementEnabled",
            pod.id,
            true)
        if not speedOk or not enabledOk then
            SCOReportPodRuntimeWarning(
                unit, state, logicalName,
                "release-error", speedError or enabledError)
        else
            SCOClearPodRuntimeWarning(state, logicalName, "release-error")
        end
        SCOSetPodDockMode(unit, state, logicalName, pod, "working")
    end

    local function SCOSetDockedPodTransform(
        unit, state, logicalName, pod, transform)
        local dockRotation, dockRotationError = SCOComposePodDockRotation(
            logicalName,
            transform.rotation)
        if dockRotation == nil then
            SCOReportPodRuntimeWarning(
                unit, state, logicalName,
                "dock-transform-error", dockRotationError)
            return false
        end
        local positionOk, positionError = SCOCallEngineSetter(
            "SetGlobalEntityPosition",
            pod.id,
            transform.position)
        local rotationOk, rotationError = SCOCallEngineSetter(
            "SetGlobalEntityLocalRotation",
            pod.id,
            dockRotation)
        if positionOk and rotationOk then
            SCOClearPodRuntimeWarning(state, logicalName, "dock-transform-error")
            return true
        end
        SCOReportPodRuntimeWarning(
            unit, state, logicalName,
            "dock-transform-error", positionError or rotationError)
        return false
    end

    local function SCODockPod(unit, state, logicalName, pod, transform)
        if state._podDockModes[logicalName] == "docked" then
            if SCOSetDockedPodTransform(
                unit, state, logicalName, pod, transform)
            then
                return true
            end
            SCOReleasePodForWork(unit, state, logicalName, pod)
            SCOSetPodDockMode(unit, state, logicalName, pod, "returning")
            return false
        end

        SCOPreparePodAirborne(pod)
        SCOCallPodMethod(pod, "MoveIntoRangeBehaviorStop")
        SCOCallEngineSetter("MovementStop", pod.id)
        SCOCallEngineSetter("SetMovementMinSpeed", pod.id, 0)
        local disabledOk, disabledError = SCOCallEngineSetter(
            "SetMovementEnabled",
            pod.id,
            false)
        local transformOk = disabledOk and SCOSetDockedPodTransform(
            unit, state, logicalName, pod, transform)
        if disabledOk and transformOk then
            SCOClearPodRuntimeWarning(state, logicalName, "dock-error")
            SCOSetPodDockMode(unit, state, logicalName, pod, "docked")
            return true
        end
        SCOReportPodRuntimeWarning(
            unit, state, logicalName,
            "dock-error", disabledError or "transform-unavailable")
        SCOReleasePodForWork(unit, state, logicalName, pod)
        SCOSetPodDockMode(unit, state, logicalName, pod, "returning")
        return false
    end

    local function SCOReturnPod(unit, state, logicalName, pod, transform)
        local positionOk, positionResult, position = pcall(
            Engine.GetGlobalEntityWorldPosition,
            pod.id)
        local distance = positionOk
            and SCOEngineCallSucceeded(positionResult)
            and SCOPlanarDistanceSquared(position, transform.position) or nil
        if distance ~= nil
            and distance <= SCOPodDockCaptureRange * SCOPodDockCaptureRange
        then
            return SCODockPod(unit, state, logicalName, pod, transform)
        end

        SCOPreparePodAirborne(pod)
        SCOSetPodDockMode(unit, state, logicalName, pod, "returning")
        local target, targetError = SCOPlanarPosition(transform.position)
        local speedOk, speedError = SCOCallEngineSetter(
            "SetMovementMinSpeed",
            pod.id,
            0)
        local enabledOk, enabledError = SCOCallEngineSetter(
            "SetMovementEnabled",
            pod.id,
            true)
        local moveOk, moveError = false, targetError
        if target ~= nil then
            moveOk, moveError = SCOCallEngineSetter(
                "MovementMove",
                pod.id,
                target,
                SCOPodDockCaptureRange)
        end
        if not speedOk or not enabledOk or not moveOk then
            SCOReportPodRuntimeWarning(
                unit, state, logicalName,
                "return-error", speedError or enabledError or moveError)
            return false
        end
        SCOClearPodRuntimeWarning(state, logicalName, "return-error")
        return true
    end

    local function SCOUpdatePodDocking(unit, state, logicalName, pod)
        if state.installed[logicalName] ~= true
            or state._podConfirmed[logicalName] ~= pod
            or not SCOIsPodAlive(pod)
        then
            return
        end
        local transform, transformError = SCOGetBoneTransform(
            unit,
            SCOPodBones[logicalName])
        if not transform then
            SCOReportPodRuntimeWarning(
                unit, state, logicalName,
                "dock-bone-error", transformError)
            if state._podDockModes[logicalName] == "docked" then
                SCOReleasePodForWork(unit, state, logicalName, pod)
                SCOSetPodDockMode(unit, state, logicalName, pod, "returning")
            end
            return
        end
        SCOClearPodRuntimeWarning(state, logicalName, "dock-bone-error")

        local orders, active, queued = SCOPodOrders(pod)
        local automatic = state._podAutoOrders[logicalName]
        if orders ~= nil and active == automatic and #queued > 0 then
            if not SCOClearAutomaticPodOrder(
                unit, state, logicalName, pod, true)
            then
                SCOReleasePodForWork(unit, state, logicalName, pod)
                return
            end
            active = orders.activeOrder
            automatic = nil
        elseif automatic ~= nil and active ~= automatic then
            state._podAutoOrders[logicalName] = nil
            automatic = nil
        end

        if active ~= nil and active ~= automatic then
            SCOReleasePodForWork(unit, state, logicalName, pod)
            return
        end
        if orders ~= nil and active == nil and #queued > 0 then
            local promote = type(SCOOrderManager) == "table"
                and SCOOrderManager.TryStartNextOrderForUnit
            if type(promote) == "function" then pcall(promote, pod) end
            if orders.activeOrder ~= nil then
                SCOReleasePodForWork(unit, state, logicalName, pod)
                return
            end
        end

        if SCOCommanderNeedsPodAssistance(unit) then
            if active == automatic and automatic ~= nil then
                SCOReleasePodForWork(unit, state, logicalName, pod)
                return
            end
            if active == nil
                and SCOEnsureAutomaticPodOrder(
                    unit, state, logicalName, pod)
            then
                SCOReleasePodForWork(unit, state, logicalName, pod)
                return
            end
            SCOReturnPod(unit, state, logicalName, pod, transform)
            return
        end

        if active == automatic and automatic ~= nil then
            if not SCOClearAutomaticPodOrder(
                unit, state, logicalName, pod, true)
            then
                SCOReleasePodForWork(unit, state, logicalName, pod)
                return
            end
            active = orders and orders.activeOrder or nil
            if active ~= nil then
                SCOReleasePodForWork(unit, state, logicalName, pod)
                return
            end
        end
        SCOReturnPod(unit, state, logicalName, pod, transform)
    end

    local function SCOUpdateConfirmedPods(unit, state)
        for _, logicalName in ipairs({ "LeftPod", "RightPod" }) do
            local pod = state._pods[logicalName]
            SCOUpdatePodDocking(unit, state, logicalName, pod)
        end
    end

    local function SCOAttemptPodCleanup(unit, state, logicalName)
        SCOEnsurePodRuntimeState(state)
        local pod = state._podPendingCleanup[logicalName]
        if pod == nil then return true end
        if type(pod) == "table" and pod.deleted == true then
            state._podPendingCleanup[logicalName] = nil
            state._podCleanupAttempts[logicalName] = nil
            state._podCleanupExhausted[logicalName] = nil
            return true
        end
        if state._podCleanupExhausted[logicalName] == true then
            return false
        end

        local attempt = (state._podCleanupAttempts[logicalName] or 0) + 1
        if type(pod) ~= "table"
            or pod.tpId ~= SCOPodTemplateId
            or type(pod.Delete) ~= "function"
        then
            state._podCleanupAttempts[logicalName] = attempt
            state._podCleanupExhausted[logicalName] = true
            SCOWarnPod(
                unit,
                logicalName,
                "cleanup-invalid-handle",
                attempt)
            return false
        end

        local ok, deleteError = pcall(pod.Delete, pod)
        if ok and pod.deleted == true then
            state._podPendingCleanup[logicalName] = nil
            state._podCleanupAttempts[logicalName] = nil
            state._podCleanupExhausted[logicalName] = nil
            if attempt > 1 then
                SCOWarnPod(unit, logicalName, "cleanup-recovered", attempt)
            end
            return true
        end

        state._podCleanupAttempts[logicalName] = attempt
        if attempt >= SCOPodCleanupRetryLimit then
            state._podCleanupExhausted[logicalName] = true
        end
        local event = attempt >= SCOPodCleanupRetryLimit
            and "cleanup-exhausted" or "cleanup-retry"
        local detail = ok and "delete-returned-before-deleted" or deleteError
        SCOWarnPod(unit, logicalName, event, attempt, detail)
        return false
    end

    local function SCOQueuePodCleanup(unit, state, logicalName, pod)
        SCOEnsurePodRuntimeState(state)
        local pending = state._podPendingCleanup[logicalName]
        if pod == nil or (type(pod) == "table" and pod.deleted == true) then
            if pending == nil then return true end
            return SCOAttemptPodCleanup(unit, state, logicalName)
        end

        if pending == pod then
            return SCOAttemptPodCleanup(unit, state, logicalName)
        end
        if pending ~= nil and pending ~= pod then
            if not SCOAttemptPodCleanup(unit, state, logicalName) then
                SCOWarnPod(
                    unit,
                    logicalName,
                    "cleanup-queue-blocked")
                return false
            end
        end

        state._podPendingCleanup[logicalName] = pod
        state._podCleanupAttempts[logicalName] = nil
        state._podCleanupExhausted[logicalName] = nil
        return SCOAttemptPodCleanup(unit, state, logicalName)
    end

    local function SCOResetPodSpawnTracking(state, logicalName)
        if type(state._podSpawnAttempts) == "table" then
            state._podSpawnAttempts[logicalName] = nil
        end
        if type(state._podSpawnExhausted) == "table" then
            state._podSpawnExhausted[logicalName] = nil
        end
    end

    local function SCOTrySpawnPod(unit, state, logicalName)
        SCOEnsurePodRuntimeState(state)
        if state._podSpawnExhausted[logicalName] == true then return nil end

        local attempt = (state._podSpawnAttempts[logicalName] or 0) + 1
        local pod, spawnError = SCOSpawnPod(unit, logicalName)
        if pod then
            SCOResetPodRuntimeTracking(state, logicalName, pod)
            state._podConfirmed[logicalName] = nil
            state._podSpawnAttempts[logicalName] = attempt
            state._podPendingConfirmation[logicalName] = pod
            return pod
        end

        state._podPendingConfirmation[logicalName] = nil
        state._podSpawnAttempts[logicalName] = attempt
        local crossedMutatingBoundary = type(spawnError) == "string"
            and (string.find(spawnError, "create-error: ", 1, true) == 1
                or spawnError == "invalid-create-result")
        if crossedMutatingBoundary or attempt >= SCOPodSpawnRetryLimit then
            state._podSpawnExhausted[logicalName] = true
        end
        local event
        if crossedMutatingBoundary then
            event = "spawn-unsafe-exhausted"
        elseif attempt >= SCOPodSpawnRetryLimit then
            event = "spawn-exhausted"
        else
            event = "spawn-retry"
        end
        SCOWarnPod(unit, logicalName, event, attempt, spawnError)
        return nil
    end

    local function SCOObservePendingPod(unit, state, logicalName)
        local pending = state._podPendingConfirmation[logicalName]
        if pending == nil then return true end
        if state._podPendingCleanup[logicalName] ~= nil then return false end
        local attempt = state._podSpawnAttempts[logicalName] or 1

        if state._pods[logicalName] ~= pending then
            local current = state._pods[logicalName]
            local cleanupComplete =
                SCOQueuePodCleanup(unit, state, logicalName, current)
            state._pods[logicalName] = pending
            SCOWarnPod(
                unit,
                logicalName,
                "spawn-reference-mismatch",
                attempt)
            if not cleanupComplete then return false end
        end

        state._podPendingConfirmation[logicalName] = nil
        if SCOIsPodAlive(pending) then
            state._podConfirmed[logicalName] = pending
            SCOResetPodSpawnTracking(state, logicalName)
            SCOWarnPod(unit, logicalName, "spawn-confirmed", attempt)
            return true
        end

        state._pods[logicalName] = nil
        state._podConfirmed[logicalName] = nil
        SCOResetPodRuntimeTracking(state, logicalName, pending)
        if attempt >= SCOPodSpawnRetryLimit then
            state._podSpawnExhausted[logicalName] = true
        end
        local event = attempt >= SCOPodSpawnRetryLimit
            and "spawn-unconfirmed-exhausted"
            or "spawn-unconfirmed-retry"
        SCOWarnPod(unit, logicalName, event, attempt)
        return true
    end

    local function SCOReconcileConfirmedPodReference(unit, state, logicalName)
        local confirmed = state._podConfirmed[logicalName]
        if confirmed == nil then return true end
        if state._podPendingCleanup[logicalName] ~= nil then return false end
        if type(confirmed) ~= "table"
            or confirmed.tpId ~= SCOPodTemplateId
        then
            state._podConfirmed[logicalName] = nil
            SCOResetPodRuntimeTracking(state, logicalName, confirmed)
            SCOWarnPod(unit, logicalName, "confirmed-reference-invalid")
            return true
        end

        local current = state._pods[logicalName]
        if current == confirmed then return true end
        local cleanupComplete =
            SCOQueuePodCleanup(unit, state, logicalName, current)
        state._pods[logicalName] = confirmed
        SCOWarnPod(
            unit,
            logicalName,
            "confirmed-reference-restored",
            nil,
            current == nil and "missing" or "mismatched")
        return cleanupComplete
    end

    local function SCOSetPodSlot(state)
        if type(state.slots) ~= "table" then state.slots = {} end
        if state.installed.RightPod == true then
            state.slots.Back = "RightPod"
        elseif state.installed.LeftPod == true then
            state.slots.Back = "LeftPod"
        elseif state.slots.Back == "LeftPod" or state.slots.Back == "RightPod" then
            state.slots.Back = nil
        end
    end

    local function SCOClearPodEnhancements(unit, clearLeft, clearRight)
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" or type(state.installed) ~= "table" then
            return false
        end
        local changed = false
        if clearRight and state.installed.RightPod == true then
            state.installed.RightPod = nil
            changed = true
        end
        if clearLeft and state.installed.LeftPod == true then
            state.installed.LeftPod = nil
            changed = true
        end
        SCOSetPodSlot(state)
        return changed
    end

    local function SCOReconcilePods(unit)
        if unit.dead or unit.deleted or unit.tpId ~= "uel0000" then return end
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" or type(state.installed) ~= "table" then
            return
        end
        SCOEnsurePodRuntimeState(state)
        SCOAttemptPodCleanup(unit, state, "LeftPod")
        SCOAttemptPodCleanup(unit, state, "RightPod")
        if not SCOObservePendingPod(unit, state, "LeftPod") then return end
        if not SCOObservePendingPod(unit, state, "RightPod") then return end
        if not SCOReconcileConfirmedPodReference(
            unit,
            state,
            "LeftPod")
        then
            return
        end
        if not SCOReconcileConfirmedPodReference(
            unit,
            state,
            "RightPod")
        then
            return
        end
        local pods = state._pods
        local confirmed = state._podConfirmed
        local leftAlive = SCOIsPodAlive(pods.LeftPod)
        local rightAlive = SCOIsPodAlive(pods.RightPod)

        -- Only confirmed entities may enter the published dock lifecycle.
        -- This keeps startup failures and pre-confirmation deaths technical,
        -- not player-visible combat-loss or attachment events.
        SCOUpdateConfirmedPods(unit, state)

        -- Stock UEL0001 treats a combat loss differently from an explicit
        -- enhancement removal.  Left loss removes both; right loss retains a
        -- freshly recreated left pod and clears only RightPod.  A spawn
        -- exception is not a combat loss: only a pod previously confirmed
        -- alive can enter either branch.
        if state.installed.LeftPod == true
            and pods.LeftPod == confirmed.LeftPod
            and SCOIsPodDestroyed(confirmed.LeftPod)
            and state._podTeardown ~= true
        then
            SCOResetPodRuntimeTracking(state, "LeftPod", confirmed.LeftPod)
            SCOResetPodRuntimeTracking(state, "RightPod", confirmed.RightPod)
            pods.LeftPod = nil
            local right = pods.RightPod
            pods.RightPod = nil
            confirmed.LeftPod = nil
            confirmed.RightPod = nil
            state._podPendingConfirmation.LeftPod = nil
            state._podPendingConfirmation.RightPod = nil
            SCOResetPodSpawnTracking(state, "LeftPod")
            SCOResetPodSpawnTracking(state, "RightPod")
            SCOQueuePodCleanup(unit, state, "RightPod", right)
            if SCOClearPodEnhancements(unit, true, true) then
                SCOEmitPodState(unit)
            end
            return
        elseif state.installed.RightPod == true
            and pods.RightPod == confirmed.RightPod
            and SCOIsPodDestroyed(confirmed.RightPod)
            and state._podTeardown ~= true
        then
            SCOResetPodRuntimeTracking(state, "RightPod", confirmed.RightPod)
            pods.RightPod = nil
            confirmed.RightPod = nil
            state._podPendingConfirmation.RightPod = nil
            SCOResetPodSpawnTracking(state, "RightPod")
            local oldLeft = pods.LeftPod
            SCOResetPodRuntimeTracking(state, "LeftPod", oldLeft)
            pods.LeftPod = nil
            confirmed.LeftPod = nil
            state._podPendingConfirmation.LeftPod = nil
            SCOResetPodSpawnTracking(state, "LeftPod")
            local cleanupComplete =
                SCOQueuePodCleanup(unit, state, "LeftPod", oldLeft)
            local changed = SCOClearPodEnhancements(unit, false, true)
            if state.installed.LeftPod == true and cleanupComplete then
                pods.LeftPod = SCOTrySpawnPod(unit, state, "LeftPod")
            end
            if changed then SCOEmitPodState(unit) end
            return
        end

        local wantsLeft = state.installed.LeftPod == true
        local wantsRight = state.installed.RightPod == true
        if not wantsLeft then
            state._podTeardown = true
            local left = pods.LeftPod
            local right = pods.RightPod
            SCOResetPodRuntimeTracking(state, "LeftPod", left)
            SCOResetPodRuntimeTracking(state, "RightPod", right)
            pods.LeftPod = nil
            pods.RightPod = nil
            confirmed.LeftPod = nil
            confirmed.RightPod = nil
            state._podPendingConfirmation.LeftPod = nil
            state._podPendingConfirmation.RightPod = nil
            SCOResetPodSpawnTracking(state, "LeftPod")
            SCOResetPodSpawnTracking(state, "RightPod")
            SCOQueuePodCleanup(unit, state, "LeftPod", left)
            SCOQueuePodCleanup(unit, state, "RightPod", right)
            state._podTeardown = false
            return
        end

        if not leftAlive then
            if state._podPendingCleanup.LeftPod ~= nil then return end
            pods.LeftPod = SCOTrySpawnPod(unit, state, "LeftPod")
            if not pods.LeftPod then return end
        end
        if wantsRight and not rightAlive then
            if state._podPendingCleanup.RightPod ~= nil then return end
            pods.RightPod = SCOTrySpawnPod(unit, state, "RightPod")
            if not pods.RightPod then return end
        elseif not wantsRight and rightAlive then
            state._podTeardown = true
            local right = pods.RightPod
            SCOResetPodRuntimeTracking(state, "RightPod", right)
            pods.RightPod = nil
            confirmed.RightPod = nil
            state._podPendingConfirmation.RightPod = nil
            SCOResetPodSpawnTracking(state, "RightPod")
            SCOQueuePodCleanup(unit, state, "RightPod", right)
            state._podTeardown = false
        elseif not wantsRight then
            SCOResetPodRuntimeTracking(
                state,
                "RightPod",
                state._podPendingConfirmation.RightPod)
            confirmed.RightPod = nil
            state._podPendingConfirmation.RightPod = nil
            SCOResetPodSpawnTracking(state, "RightPod")
        end
    end

    local function SCOPodMonitorThread(unit)
        while not unit.dead and not unit.deleted do
            SCOEnablePodCapabilities(unit)
            SCOReconcilePods(unit)
            WaitTicks(1)
        end
    end

    local function SCOStartPodMonitor(unit)
        if unit.tpId ~= "uel0000" then return end
        SCOEnablePodCapabilities(unit)
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" or state._podMonitorThread then return end
        SCOEnsurePodRuntimeState(state)
        state._podMonitorThread = unit:NewThread(SCOPodMonitorThread)
    end

    local function SCOStopAndDeletePods(unit)
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" then return end
        if state._podMonitorThread then
            KillThread(state._podMonitorThread)
            state._podMonitorThread = nil
        end
        state._podTeardown = true
        local pods = state._pods or {}
        SCOResetPodRuntimeTracking(state, "LeftPod", pods.LeftPod)
        SCOResetPodRuntimeTracking(state, "RightPod", pods.RightPod)
        state._pods = {}
        state._podConfirmed = {}
        state._podPendingConfirmation = {}
        state._podSpawnAttempts = {}
        state._podSpawnExhausted = {}
        state._podDockModes = {}
        state._podAutoOrders = {}
        state._podDockWarnings = {}
        SCOEnsurePodRuntimeState(state)
        SCOQueuePodCleanup(unit, state, "LeftPod", pods.LeftPod)
        SCOQueuePodCleanup(unit, state, "RightPod", pods.RightPod)
        for _ = 2, SCOPodCleanupRetryLimit do
            SCOAttemptPodCleanup(unit, state, "LeftPod")
            SCOAttemptPodCleanup(unit, state, "RightPod")
        end
        state._podTeardown = false
    end

    local SCOPreviousCommanderInit = HostCommander.__init
    local SCOPreviousCommanderOnStopBeingBuilt =
        HostCommander.OnStopBeingBuilt
    local SCOPreviousCommanderOnDestroy = HostCommander.OnDestroy

    -- A commander pod never uses Sanctuary's ordinary land-when-idle path.
    -- Its monitor either keeps it airborne for work/return or snaps it to the
    -- assigned shoulder. This wrapper prevents a Stop/order completion from
    -- racing a stock landing thread before the next monitor tick.
    if type(HostAirUnit) == "table"
        and type(HostAirUnit.OnBecameIdle) == "function"
    then
        local SCOPreviousAirUnitOnBecameIdle = HostAirUnit.OnBecameIdle
        function HostAirUnit:OnBecameIdle(...)
            if self.scoCommanderPodOwner ~= nil then return end
            return SCOPreviousAirUnitOnBecameIdle(self, ...)
        end
    end

    function HostCommander:__init(...)
        local result = SCOPreviousCommanderInit(self, ...)
        SCOEnablePodCapabilities(self)
        -- The completed-unit constructor normally dispatches the wrapped
        -- OnStopBeingBuilt method.  Start again after the constructor returns
        -- as an idempotent recovery boundary so a missed/early virtual
        -- callback cannot leave a paid pod enhancement without a monitor.
        SCOStartPodMonitor(self)
        return result
    end

    function HostCommander:OnStopBeingBuilt(...)
        local result = SCOPreviousCommanderOnStopBeingBuilt(self, ...)
        SCOStartPodMonitor(self)
        return result
    end

    function HostCommander:OnDestroy(...)
        if self.tpId == "uel0000" then SCOStopAndDeletePods(self) end
        return SCOPreviousCommanderOnDestroy(self, ...)
    end

    local function SCOResolveSnapshotUnit(unitId)
        local getUnitById = rawget(_G, "GetUnitById")
        if type(getUnitById) ~= "function" then return nil end
        local ok, unit = pcall(getUnitById, unitId)
        if ok and type(unit) == "table" then return unit end
        return nil
    end

    local function SCOAugmentPodSnapshot(unit, snapshot)
        if type(snapshot) ~= "table" then return snapshot end
        local pods = {}
        snapshot.pods = pods
        if type(unit) ~= "table" or unit.tpId ~= "uel0000" then
            return snapshot
        end
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table"
            or type(state.installed) ~= "table"
            or type(state._pods) ~= "table"
            or type(state._podConfirmed) ~= "table"
        then
            return snapshot
        end
        for _, logicalName in ipairs({ "LeftPod", "RightPod" }) do
            local pod = state._pods[logicalName]
            local id = type(pod) == "table" and pod.id
            if state.installed[logicalName] == true
                and state._podConfirmed[logicalName] == pod
                and SCOIsPodAlive(pod)
                and type(id) == "table"
                and SCOInteger(id.index, 1, 2147483647)
                and SCOInteger(id.version, 0, 2147483647)
            then
                pods[logicalName] = {
                    unitId = {
                        index = id.index,
                        version = id.version,
                    },
                    docked = type(state._podDockModes) == "table"
                        and state._podDockModes[logicalName] == "docked",
                }
            end
        end
        return snapshot
    end

    local SCOPreviousGetState =
        rawget(_G, "SCO_CommanderEnhancementHostGetState")
    if type(SCOPreviousGetState) == "function" then
        _G.SCO_CommanderEnhancementHostGetState = function(clientID, unitId)
            local snapshot, reason = SCOPreviousGetState(clientID, unitId)
            return SCOAugmentPodSnapshot(
                SCOResolveSnapshotUnit(unitId),
                snapshot), reason
        end
    end

    local SCOPreviousGetVisualState =
        rawget(_G, "SCO_CommanderEnhancementHostGetVisualState")
    if type(SCOPreviousGetVisualState) == "function" then
        _G.SCO_CommanderEnhancementHostGetVisualState =
            function(clientID, unitId)
                local snapshot, reason =
                    SCOPreviousGetVisualState(clientID, unitId)
                return SCOAugmentPodSnapshot(
                    SCOResolveSnapshotUnit(unitId),
                    snapshot), reason
            end
    end

    local SCOPreviousTransfer =
        rawget(_G, "SCO_CommanderEnhancementHostTransfer")
    if type(SCOPreviousTransfer) == "function" then
        _G.SCO_CommanderEnhancementHostTransfer = function(source, destination)
            local transferred = SCOPreviousTransfer(source, destination)
            if transferred == true then
                SCOEnablePodCapabilities(destination)
                SCOStartPodMonitor(destination)
                SCOReconcilePods(destination)
            end
            return transferred
        end
    end

    -- Sanctuary may dispatch OnStopBeingBuilt from inside the native base
    -- constructor, before this outer __init wrapper can enable pod support on
    -- the host state.  Correct the owner projection at its single publication
    -- boundary so the first snapshot is already authoritative; the host state
    -- is enabled later in the same synchronous construction call.
    local SCOPreviousEmitState =
        rawget(_G, "SCO_CommanderEnhancementEmitState")
    if type(SCOPreviousEmitState) == "function" then
        _G.SCO_CommanderEnhancementEmitState = function(clientID, snapshot)
            if type(snapshot) == "table" and snapshot.tpId == "uel0000" then
                local capabilities = snapshot.capabilities
                local enhancements = capabilities and capabilities.enhancements
                if type(enhancements) == "table" then
                    capabilities.spawnPods = true
                    for _, enhancementId in ipairs({ "LeftPod", "RightPod" }) do
                        local capability = enhancements[enhancementId]
                        if type(capability) == "table" then
                            capability.install = true
                            capability.partial = false
                            capability.reason = nil
                            if type(capability.domains) ~= "table" then
                                capability.domains = {}
                            end
                            capability.domains.spawn = true
                        end
                    end
                end
            end
            return SCOPreviousEmitState(clientID, snapshot)
        end
    end

    rawset(
        SCOPodHostEnvironment,
        "SCO_CommanderPodHostInstalled",
        SCOPodHostVersion)
end

-- Supreme Commander Overhaul Cybran cloak adaptation host 1.0.1
-- Sanctuary has no FA cloak/stealth visibility API.  Preserve the exact
-- upgrade HP and upkeep economy while replicating the user-approved subtle
-- aura as an explicit, honest visual substitute.
local SCOCloakHostEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCloakHostVersion = "1.0.1"
local SCOCloakHostMarker = rawget(
    SCOCloakHostEnvironment,
    "SCO_CommanderCloakHostInstalled")
if SCOCloakHostMarker ~= nil and SCOCloakHostMarker ~= SCOCloakHostVersion then
    error("Unsupported SCOM commander-cloak host marker "
        .. tostring(SCOCloakHostMarker))
end

if SCOCloakHostMarker == nil then
    if type(HostCommander) ~= "table" then
        error("SCOM commander cloak could not resolve HostCommander")
    end
    local SCOResourceEntity =
        Import("host/systems/resourceEntity.lua").ResourceEntity
    local SCOLobby = Import("common/lobby.lua")

    local function SCOInteger(value, minimum, maximum)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
            and value == math.floor(value)
            and value >= minimum
            and value <= maximum
    end

    local function SCOOwnerClientId(unit)
        local player = type(SCOLobby) == "table"
            and type(SCOLobby.ArmyToPlayer) == "table"
            and unit.army
            and SCOLobby.ArmyToPlayer[unit.army.id]
        local clientID = player and player.clientID
        if SCOInteger(clientID, 0, 2147483647) then return clientID end
        return nil
    end

    local function SCOEnableCloakCapabilities(unit)
        if unit.tpId ~= "ugl0000" then return end
        local state = unit.scoCommanderEnhancements
        local capabilities = state and state.capabilities
        local enhancements = capabilities and capabilities.enhancements
        if type(enhancements) ~= "table" then return end
        capabilities.stealth = "visual-aura"
        capabilities.cloak = "visual-aura"
        for _, enhancementId in ipairs({
            "StealthGenerator",
            "CloakingGenerator",
        }) do
            local capability = enhancements[enhancementId]
            if type(capability) == "table" then
                capability.install = true
                capability.partial = true
                capability.reason = "stealth-cloak-visual-substitute"
                if type(capability.domains) ~= "table" then
                    capability.domains = {}
                end
                capability.domains.intel = true
            end
        end
    end

    local function SCOSetConsumption(entity, enabled, energy)
        if not entity then return end
        if enabled then
            entity:SetEnabled(true)
            entity:SetResources(nil, { energy = energy })
        else
            entity:SetEnabled(false)
            entity.outcome = {}
            entity.prevOutcome = {}
            entity.productionMultiplier = 0
            if type(entity.SetUserMultiplier) == "function" then
                entity:SetUserMultiplier(1)
            else
                entity.userMultiplier = 1
            end
        end
    end

    local function SCOCloakSnapshot(unit, snapshot)
        if type(snapshot) ~= "table" then return snapshot end
        snapshot.abilities = snapshot.abilities or {}
        local state = unit and unit.scoCommanderEnhancements
        snapshot.abilities.cloakAura = type(state) == "table"
            and state._cloakAuraActive == true
        snapshot.abilities.cloakMode = type(state) == "table"
            and state._cloakMode or nil
        if type(state) == "table" and state._cloakMode ~= nil then
            snapshot.abilities.cloakEnabled = state._cloakRequested == true
        else
            snapshot.abilities.cloakEnabled = nil
        end
        snapshot.abilities.cloakEnergyUpkeep = type(state) == "table"
            and state._cloakMode == "cloak" and 3000
            or (type(state) == "table"
                and state._cloakMode == "stealth" and 50 or nil)
        return snapshot
    end

    local function SCOGetUnit(unitId)
        if type(unitId) ~= "table"
            or not SCOInteger(unitId.index, 1, 2147483647)
            or not SCOInteger(unitId.version, 0, 2147483647)
        then
            return nil
        end
        local unit = GetUnitById({
            index = unitId.index,
            version = unitId.version,
        })
        if type(unit) == "table" and unit.tpId == "ugl0000" then return unit end
        return nil
    end

    local function SCOEmitCloakState(unit)
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" then return end
        state.revision = ((state.revision or 0) + 1) % 2147483648
        local ownerClientID = SCOOwnerClientId(unit)
        local getState = rawget(_G, "SCO_CommanderEnhancementHostGetState")
        local emitState = rawget(_G, "SCO_CommanderEnhancementEmitState")
        if ownerClientID ~= nil
            and type(getState) == "function"
            and type(emitState) == "function"
        then
            local ok, snapshot = pcall(getState, ownerClientID, unit.id)
            if ok and type(snapshot) == "table" then
                pcall(emitState, ownerClientID, snapshot)
            end
        end
        local getVisual =
            rawget(_G, "SCO_CommanderEnhancementHostGetVisualState")
        local emitVisual =
            rawget(_G, "SCO_CommanderEnhancementEmitVisualState")
        if type(getVisual) == "function" and type(emitVisual) == "function" then
            for clientID in pairs(SCOLobby.Players or {}) do
                if SCOInteger(clientID, 0, 2147483647) then
                    local ok, snapshot = pcall(getVisual, clientID, unit.id)
                    if ok and type(snapshot) == "table" then
                        pcall(emitVisual, clientID, snapshot)
                    end
                end
            end
        end
    end

    local function SCOReconcileCloak(unit)
        if unit.tpId ~= "ugl0000" or unit.dead or unit.deleted then return end
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" or type(state.installed) ~= "table" then
            return
        end
        SCOEnableCloakCapabilities(unit)
        local mode = nil
        local upkeep = nil
        if state.installed.CloakingGenerator == true then
            mode = "cloak"
            upkeep = 3000
        elseif state.installed.StealthGenerator == true then
            mode = "stealth"
            upkeep = 50
        end

        if mode == nil then
            state._cloakRequested = nil
        elseif state._cloakRequested == nil then
            -- FA enables the intel toggle when the hardware first completes.
            -- Preserve an explicit user choice while moving from the basic
            -- generator to the advanced generator.
            state._cloakRequested = true
        end
        local requested = mode ~= nil and state._cloakRequested == true

        local entity = unit.resourceEntities.scoCommanderCloakConsumption
        if mode and not entity then
            entity = SCOResourceEntity(
                unit.army.id,
                unit.id,
                "consumption",
                nil,
                nil,
                false)
            unit.resourceEntities.scoCommanderCloakConsumption = entity
        end
        SCOSetConsumption(entity, requested, upkeep)
        local active = requested
            and unit.army
            and unit.army.economy
            and unit.army.economy.isEnergyDown ~= true
            and entity
            and entity.enabled == true
        if state._cloakMode ~= mode
            or state._cloakAuraActive ~= active
            or state._cloakPublishedRequested ~= state._cloakRequested
        then
            state._cloakMode = mode
            state._cloakAuraActive = active
            state._cloakPublishedRequested = state._cloakRequested
            SCOEmitCloakState(unit)
        end
    end

    local function SCOHostToggleCloak(clientID, unitId)
        if not SCOInteger(clientID, 0, 2147483647) then
            return false, "invalid-client"
        end
        local unit = SCOGetUnit(unitId)
        if not unit or unit.dead or unit.deleted then
            return false, "invalid-unit"
        end
        if SCOOwnerClientId(unit) ~= clientID then
            return false, "not-owner"
        end
        SCOReconcileCloak(unit)
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" or state._cloakMode == nil then
            return false, "cloak-not-installed"
        end
        state._cloakRequested = state._cloakRequested ~= true
        SCOReconcileCloak(unit)
        return true
    end

    local function SCOCloakMonitorThread(unit)
        while not unit.dead and not unit.deleted do
            SCOReconcileCloak(unit)
            WaitTicks(1)
        end
    end

    local function SCOStartCloakMonitor(unit)
        if unit.tpId ~= "ugl0000" then return end
        SCOEnableCloakCapabilities(unit)
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" or state._cloakMonitorThread then return end
        state._cloakMonitorThread = unit:NewThread(SCOCloakMonitorThread)
    end

    local function SCOStopCloakMonitor(
        unit,
        preserveRequested,
        releaseConsumption)
        local state = unit.scoCommanderEnhancements
        if type(state) ~= "table" then return end
        local requested = state._cloakRequested
        if state._cloakMonitorThread then
            KillThread(state._cloakMonitorThread)
            state._cloakMonitorThread = nil
        end
        local entity = unit.resourceEntities.scoCommanderCloakConsumption
        SCOSetConsumption(entity, false, nil)
        if releaseConsumption then
            unit.resourceEntities.scoCommanderCloakConsumption = nil
        end
        state._cloakMode = nil
        state._cloakAuraActive = false
        if preserveRequested then
            state._cloakRequested = requested
        else
            state._cloakRequested = nil
        end
        state._cloakPublishedRequested = nil
    end

    local SCOPreviousCommanderInit = HostCommander.__init
    local SCOPreviousCommanderOnStopBeingBuilt =
        HostCommander.OnStopBeingBuilt
    local SCOPreviousCommanderOnDestroy = HostCommander.OnDestroy
    function HostCommander:__init(...)
        local result = SCOPreviousCommanderInit(self, ...)
        SCOEnableCloakCapabilities(self)
        return result
    end
    function HostCommander:OnStopBeingBuilt(...)
        local result = SCOPreviousCommanderOnStopBeingBuilt(self, ...)
        SCOStartCloakMonitor(self)
        return result
    end
    function HostCommander:OnDestroy(...)
        if self.tpId == "ugl0000" then SCOStopCloakMonitor(self) end
        return SCOPreviousCommanderOnDestroy(self, ...)
    end
    local SCOPreviousGetState =
        rawget(_G, "SCO_CommanderEnhancementHostGetState")
    if type(SCOPreviousGetState) == "function" then
        _G.SCO_CommanderEnhancementHostGetState = function(clientID, unitId)
            local snapshot, reason = SCOPreviousGetState(clientID, unitId)
            return SCOCloakSnapshot(SCOGetUnit(unitId), snapshot), reason
        end
    end
    local SCOPreviousGetVisualState =
        rawget(_G, "SCO_CommanderEnhancementHostGetVisualState")
    if type(SCOPreviousGetVisualState) == "function" then
        _G.SCO_CommanderEnhancementHostGetVisualState =
            function(clientID, unitId)
                local snapshot, reason =
                    SCOPreviousGetVisualState(clientID, unitId)
                return SCOCloakSnapshot(SCOGetUnit(unitId), snapshot), reason
            end
    end

    local SCOPreviousTransfer =
        rawget(_G, "SCO_CommanderEnhancementHostTransfer")
    if type(SCOPreviousTransfer) == "function" then
        _G.SCO_CommanderEnhancementHostTransfer = function(source, destination)
            local sourceState = type(source) == "table"
                and source.tpId == "ugl0000"
                and source.scoCommanderEnhancements or nil
            local requested = nil
            if type(sourceState) == "table" then
                requested = sourceState._cloakRequested
            end
            if requested ~= nil and type(requested) ~= "boolean" then
                return false
            end
            local transferred = SCOPreviousTransfer(source, destination)
            if transferred == true and type(sourceState) == "table" then
                SCOStopCloakMonitor(source, false, true)
                SCOStopCloakMonitor(destination, true, true)
                local destinationState = destination.scoCommanderEnhancements
                if type(destinationState) == "table" then
                    destinationState._cloakRequested = requested
                    SCOStartCloakMonitor(destination)
                    SCOReconcileCloak(destination)
                end
            end
            return transferred
        end
    end

    -- As with UEF pods, Sanctuary can publish the completed commander from
    -- inside the native base constructor. Correct that first owner projection
    -- before the outer cloak wrapper has returned and updated host state.
    local SCOPreviousEmitState =
        rawget(_G, "SCO_CommanderEnhancementEmitState")
    if type(SCOPreviousEmitState) == "function" then
        _G.SCO_CommanderEnhancementEmitState = function(clientID, snapshot)
            if type(snapshot) == "table" and snapshot.tpId == "ugl0000" then
                local capabilities = snapshot.capabilities
                local enhancements = capabilities and capabilities.enhancements
                if type(enhancements) == "table" then
                    capabilities.stealth = "visual-aura"
                    capabilities.cloak = "visual-aura"
                    for _, enhancementId in ipairs({
                        "StealthGenerator",
                        "CloakingGenerator",
                    }) do
                        local capability = enhancements[enhancementId]
                        if type(capability) == "table" then
                            capability.install = true
                            capability.partial = true
                            capability.reason =
                                "stealth-cloak-visual-substitute"
                            if type(capability.domains) ~= "table" then
                                capability.domains = {}
                            end
                            capability.domains.intel = true
                        end
                    end
                end
            end
            return SCOPreviousEmitState(clientID, snapshot)
        end
    end

    if rawget(_G, "SCO_CommanderAbilityHostToggleCloak") ~= nil then
        error("SCOM commander cloak toggle export is occupied")
    end
    _G.SCO_CommanderAbilityHostToggleCloak = SCOHostToggleCloak

    rawset(
        SCOCloakHostEnvironment,
        "SCO_CommanderCloakHostInstalled",
        SCOCloakHostVersion)
end

-- SCOM support commander scope 44ecf6afe927e4c495ca8f4edd48d068165dc7e87f61e6427bf15e566c4ceb05 9AF99F02FD647389DC3DD0BB74B0F63E522E3AE3F28AC461F99DF4FD8706101E
-- Supreme Commander Overhaul commander abilities 1.2.0
-- Load after commander_enhancement_host_appendix.lua.  This resource owns only
-- Host-authoritative personal teleport and counted commander missiles.  Client
-- commands remain a separate authenticated transport boundary.
local SCOCommanderAbilityEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderAbilityVersion = "1.2.0"
local SCOMissileCollisionContractVersion = "1.0.0"
local SCOAbilityVisualProtocolVersion = "1.1.0"
local SCOCommanderAbilityMarker = rawget(
    SCOCommanderAbilityEnvironment,
    "SCO_CommanderAbilityHostInstalled")
if SCOCommanderAbilityMarker ~= nil
    and SCOCommanderAbilityMarker ~= SCOCommanderAbilityVersion
then
    error("Unsupported SCOM commander-ability host marker "
        .. tostring(SCOCommanderAbilityMarker))
end

if SCOCommanderAbilityMarker == nil then
    if type(HostCommander) ~= "table"
        or rawget(SCOCommanderAbilityEnvironment,
            "SCO_CommanderEnhancementHostInstalled") ~= "1.0.0"
    then
        error("SCOM commander abilities require commander-enhancement host 1.0.0")
    end

    local SCOResourceEntity =
        Import("host/systems/resourceEntity.lua").ResourceEntity
    local SCOMapUtils = Import("common/mapUtils.lua")
    local SCOLayers = Import("common/layers.lua")
    local SCOLobby = Import("common/lobby.lua")
    local SCOCommands = Import("common/commands/definitions/projectiles.lua")
    local SCOHostProjectile = Import(
        "host/projectiles/projectilesClasses/projectilesBaseClass.lua")
        .HostProjectile
    local SCOProjectiles = __Entities.Projectiles
    local SCOTickRate = Constants.TickRate

    if type(SCOResourceEntity) ~= "table"
        or type(SCOMapUtils) ~= "table"
        or type(SCOLayers) ~= "table"
        or type(SCOLobby) ~= "table"
        or type(SCOLobby.ArmyToPlayer) ~= "table"
        or type(SCOHostProjectile) ~= "table"
        or type(SCOProjectiles) ~= "table"
        or type(SCOTickRate) ~= "number"
        or SCOTickRate <= 0
    then
        error("SCOM commander abilities could not resolve Host dependencies")
    end

    local SCOCommanderIds = {
        uel0000 = true,
        ucl0000 = true,
        ugl0000 = true,
        usl0000 = true,
    }

    -- Values below are copied from the installed Forged Alliance blueprints.
    -- The Sanctuary templates are deliberately distinct presentation donors;
    -- they are compatibility visuals, not claims of FA mesh/VFX parity.
    local SCOMissileProfiles = {
        uefTactical = {
            id = "uefTactical",
            unitTpId = "uel0000",
            enhancementId = "TacticalMissile",
            name = "Tactical Missile",
            muzzleBone = "Back_Upgrade_Muzzle",
            donorProjectile = "pei141",
            donorName = "EDA_Missile_Small",
            donorTrail =
                "VFX/Trails/vet2101_rocket_antitank_small_trail.sanvfx",
            buildCost = { alloys = 180, energy = 3600 },
            buildTime = 300,
            autoBuild = true,
            maxAmmo = 1,
            rangeMin = 5,
            rangeMax = 256,
            damage = 6000,
            damageRadius = 2,
            damageFriendly = true,
            projectileLifetime = 80,
            muzzleVelocity = 10,
            acceleration = 3,
            maximumSpeed = 12,
            initialTurnRate = 8,
            turnBehavior = "tactical",
            rateOfFire = 5,
            muzzleChargeDelay = 0,
            doorOpenSeconds = 2,
            rackFireTogether = false,
            rackReloadTimeout = 10,
            rackSalvoChargeTime = 0,
            rackSalvoReloadTime = 0,
            rackSalvoSize = 1,
            cooldownSeconds = 0.2,
        },
        uefBilly = {
            id = "uefBilly",
            unitTpId = "uel0000",
            enhancementId = "TacticalNukeMissile",
            name = "The Billy",
            muzzleBone = "Back_Upgrade_Muzzle",
            donorProjectile = "pei241",
            donorName = "EDA_Missile_Small",
            donorTrail = "VFX/Trails/vet5511_T5_rocket_trail.sanvfx",
            buildCost = { alloys = 3780, energy = 451800 },
            buildTime = 1800,
            autoBuild = true,
            maxAmmo = 1,
            rangeMin = 5,
            rangeMax = 256,
            damage = 0,
            damageRadius = 0,
            damageFriendly = true,
            innerRing = { damage = 12000, radius = 15, ticks = 24,
                totalTime = 0 },
            outerRing = { damage = 250, radius = 25, ticks = 20,
                totalTime = 0 },
            projectileLifetime = 80,
            muzzleVelocity = 10,
            acceleration = 3,
            maximumSpeed = 12,
            initialTurnRate = 8,
            turnBehavior = "billy",
            rateOfFire = 1,
            muzzleChargeDelay = 0,
            doorOpenSeconds = 2,
            rackFireTogether = false,
            rackReloadTimeout = 10,
            rackSalvoChargeTime = 0,
            rackSalvoReloadTime = 30,
            rackSalvoSize = 1,
            cooldownSeconds = 30,
        },
        seraphimTactical = {
            id = "seraphimTactical",
            unitTpId = "usl0000",
            enhancementId = "Missile",
            name = "Laanse Tactical Missile",
            muzzleBone = "Back_Missle",
            donorProjectile = "pca341",
            donorName = "Chosen_Missile_AntiAir_Large",
            donorTrail =
                "VFX/Trails/vct3301_missile_antiair_large_trail.sanvfx",
            buildCost = { alloys = 180, energy = 3600 },
            buildTime = 300,
            maxAmmo = 1,
            rangeMin = 5,
            rangeMax = 256,
            damage = 6000,
            damageRadius = 3,
            damageFriendly = true,
            projectileLifetime = 80,
            muzzleVelocity = 5,
            acceleration = 3,
            maximumSpeed = 12,
            initialTurnRate = 8,
            turnBehavior = "tactical",
            rateOfFire = 1,
            muzzleChargeDelay = 0.2,
            rackFireTogether = false,
            rackReloadTimeout = 10,
            rackSalvoChargeTime = 0,
            rackSalvoReloadTime = 0,
            rackSalvoSize = 1,
            cooldownSeconds = 1,
        },
    }

    local SCOTeleportCost = { energy = 150000 }
    local SCOTeleportBuildTime = 15
-- Early lexical helpers. Every existing ACU retains its original constants.
local function SCOSupportTeleportCost(unit)
    local additions = unit and unit.tp and unit.tp.additions
    if additions and additions.scoSupportCommanderEnhancements then
        local row = _G.SCO_CommanderEnhancementContract.commanders[unit.tpId].base.teleport
        return {energy=row.energy, alloys=row.mass}
    end
    return SCOTeleportCost
end
local function SCOSupportTeleportTime(unit)
    local additions = unit and unit.tp and unit.tp.additions
    if additions and additions.scoSupportCommanderEnhancements then
        return _G.SCO_CommanderEnhancementContract.commanders[unit.tpId].base.teleport.time
    end
    return SCOTeleportBuildTime
end

    local SCOTeleportFixedBuildPower = 1
    local SCOTeleportUnlockRetryTicks = SCOTickRate
    local SCOCancelMissileBuild
    local SCOCancelMissileLaunch
    local SCOCancelTeleport
    local SCOEnsureAutoMissileBuild
    local SCOSyncMissileBuildPause
    local SCOConsumeMissilePaidWork
    local SCOSendMissileDoorVisual

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

    local function SCOSameGlobalId(left, right)
        return left ~= nil and right ~= nil
            and left.index == right.index
            and left.version == right.version
    end

    local function SCOCopy(value, seen)
        if type(value) ~= "table" then return value end
        seen = seen or {}
        if seen[value] then return seen[value] end
        local result = {}
        seen[value] = result
        for key, item in pairs(value) do
            result[SCOCopy(key, seen)] = SCOCopy(item, seen)
        end
        return result
    end

    local function SCOGameTime()
        if type(GetGameTimeSeconds) == "function" then
            local ok, value = pcall(GetGameTimeSeconds)
            if ok and SCOFinite(value) then return value end
        end
        return SCOFinite(_G.Time) and _G.Time or 0
    end

    local function SCOGameTick()
        if type(Engine.GetSimulationTick) == "function" then
            local ok, value = pcall(Engine.GetSimulationTick)
            if ok and SCOFinite(value) then return math.floor(value) end
        end
        return math.floor(SCOGameTime() * SCOTickRate + 0.5)
    end

    local function SCOOwnerClientId(unit)
        local player = unit and unit.army
            and SCOLobby.ArmyToPlayer[unit.army.id]
        local clientID = player and player.clientID
        if SCOInteger(clientID, 0, 2147483647) then return clientID end
        return nil
    end

    local function SCOUnitIsCompleted(unit)
        return type(unit.IsCompleted) == "function" and unit:IsCompleted()
    end

    local function SCOUnitIsIdle(unit)
        local orders = unit.orders
        if orders and (orders.activeOrder ~= nil
            or (orders.queuedOrders and #orders.queuedOrders > 0))
        then
            return false
        end
        for _, field in ipairs({
            "unitBeingBuilt",
            "unitBeingCaptured",
            "unitBeingReclaimed",
            "unitBeingRepaired",
            "dashBehaviorIsActive",
        }) do
            if unit[field] then return false end
        end
        return true
    end

    local function SCOInstalled(unit, enhancementId)
        local state = unit.scoCommanderEnhancements
        return type(state) == "table"
            and type(state.installed) == "table"
            and state.installed[enhancementId] == true
    end

    local function SCOEnableAbilityCapabilities(unit)
        local state = unit.scoCommanderEnhancements
        local capabilities = state and state.capabilities
        local enhancements = capabilities and capabilities.enhancements
        if type(enhancements) ~= "table" then return false end

        capabilities.teleport = true
        local teleport = enhancements.Teleporter
        if type(teleport) == "table" then
            teleport.install = true
            teleport.partial = false
            teleport.reason = nil
            teleport.domains = teleport.domains or {}
            teleport.domains.teleport = true
        end

        local missileIds = nil
        if unit.tpId == "uel0000" then
            missileIds = { "TacticalMissile", "TacticalNukeMissile" }
        elseif unit.tpId == "usl0000" then
            missileIds = { "Missile" }
        end
        if missileIds then
            capabilities.manualMissiles = true
            for _, enhancementId in ipairs(missileIds) do
                local capability = enhancements[enhancementId]
                if type(capability) == "table" then
                    capability.install = true
                    capability.partial = true
                    capability.reason = "projectile-presentation-adapted"
                    capability.domains = capability.domains or {}
                    capability.domains.weapon = true
                end
            end
        end
        return true
    end

    local function SCOCurrentMissileProfile(unit)
        if unit.tpId == "uel0000" then
            if SCOInstalled(unit, "TacticalNukeMissile") then
                return SCOMissileProfiles.uefBilly
            end
            if SCOInstalled(unit, "TacticalMissile") then
                return SCOMissileProfiles.uefTactical
            end
        elseif unit.tpId == "usl0000" and SCOInstalled(unit, "Missile") then
            return SCOMissileProfiles.seraphimTactical
        end
        return nil
    end

    local function SCOEnsureAbilityState(unit)
        if type(unit) ~= "table" or not SCOCommanderIds[unit.tpId] then
            return nil
        end
        local state = unit.scoCommanderAbilities
        if state ~= nil then
            if type(state) ~= "table"
                or state.version ~= SCOCommanderAbilityVersion
            then
                error("SCOM commander-ability state marker is incompatible")
            end
            SCOEnableAbilityCapabilities(unit)
            return state
        end

        state = {
            version = SCOCommanderAbilityVersion,
            missileProfileId = nil,
            missileAmmo = {
                uefTactical = 0,
                uefBilly = 0,
                seraphimTactical = 0,
            },
            missileBuild = nil,
            missileLaunch = nil,
            missileCooldownUntil = 0,
            teleport = nil,
            visualSequence = 0,
            monitorThread = nil,
        }
        unit.scoCommanderAbilities = state
        SCOEnableAbilityCapabilities(unit)
        return state
    end

    local function SCOSetResourceUserMultiplier(entity, value)
        value = math.max(0, math.min(value or 1, 1))
        if type(entity.SetUserMultiplier) == "function" then
            entity:SetUserMultiplier(value)
        else
            entity.userMultiplier = value
        end
    end

    local function SCOSetResourceActive(entity, enabled)
        if not entity then return end
        if enabled then
            entity:SetEnabled(true)
            entity:RecalculateBuildDrain()
        else
            entity:SetEnabled(false)
            entity.outcome = {}
            entity.prevOutcome = {}
            entity.productionMultiplier = 0
            SCOSetResourceUserMultiplier(entity, 1)
        end
    end

    local function SCOCreateWorkEntity(unit, key, cost, buildTime, builder)
        if unit.resourceEntities[key] ~= nil then return nil end
        local ok, entity = pcall(
            SCOResourceEntity,
            unit.army.id,
            unit.id,
            "construction",
            nil,
            nil,
            false)
        if not ok or type(entity) ~= "table" or entity.economy == nil then
            return nil
        end
        local configured = pcall(function()
            entity:SetCost(SCOCopy(cost))
            entity:SetBuildTime(buildTime)
            entity:SetEnabled(true)
            entity:AddBuilder(builder)
        end)
        if not configured then
            pcall(entity.SetEnabled, entity, false)
            return nil
        end
        unit.resourceEntities[key] = entity
        return entity
    end

    local function SCOReleaseWorkEntity(unit, key, entity, builder)
        if not entity then return end
        pcall(function()
            if not entity.enabled then entity:SetEnabled(true) end
            entity:RemoveBuilder(builder)
            SCOSetResourceActive(entity, false)
        end)
        if unit.resourceEntities[key] == entity then
            unit.resourceEntities[key] = nil
        end
    end

    local function SCONextSatisfaction(entity)
        local economy = entity and entity.economy
        local resources = economy and economy.resources
        local names = entity and entity.satisfactionTable
        if type(resources) == "table" and type(names) == "table" then
            local lowest = 1
            local found = false
            for _, name in ipairs(names) do
                local satisfaction = resources[name]
                    and resources[name].satisfaction
                if SCOFinite(satisfaction) then
                    lowest = math.min(lowest, math.max(0, satisfaction))
                    found = true
                end
            end
            if found then return math.min(lowest, 1) end
        end
        return math.max(0, math.min(
            entity and entity.productionMultiplier or 0,
            1))
    end

    local function SCOPlanLastPaidTick(entity, remaining)
        local fullWork = math.max(0, entity.buildPower or 0)
            * SCONextSatisfaction(entity)
        local multiplier = 1
        if fullWork > 0 and remaining < fullWork then
            multiplier = remaining / fullWork
        end
        SCOSetResourceUserMultiplier(entity, multiplier)
    end

    local function SCOReconcileMissileProfile(unit)
        local state = SCOEnsureAbilityState(unit)
        local profile = SCOCurrentMissileProfile(unit)
        local nextId = profile and profile.id or nil
        local oldId = state.missileProfileId
        if oldId == nextId then return false end

        if state.missileBuild then SCOCancelMissileBuild(unit, true) end
        if state.missileLaunch then SCOCancelMissileLaunch(unit, true) end
        if unit.tpId == "uel0000" then
            if oldId == "uefTactical" and nextId == "uefBilly" then
                state.missileAmmo.uefTactical = 0
            elseif nextId == nil then
                state.missileAmmo.uefTactical = 0
                state.missileAmmo.uefBilly = 0
            end
        end
        -- XSL0001's stock MissileRemove does not purge stored ammunition.
        state.missileProfileId = nextId
        return true
    end

    local function SCOAbilitySnapshot(unit)
        local state = SCOEnsureAbilityState(unit)
        SCOReconcileMissileProfile(unit)
        local profile = state.missileProfileId
            and SCOMissileProfiles[state.missileProfileId] or nil
        local build = state.missileBuild
        local launch = state.missileLaunch
        local teleport = state.teleport
        local now = SCOGameTime()
        local cooldownUntil = state.missileCooldownUntil or 0
        if launch then
            cooldownUntil = math.max(cooldownUntil, launch.readyAt or now)
        end
        return {
            version = SCOCommanderAbilityVersion,
            missile = {
                available = profile ~= nil,
                profileId = profile and profile.id or nil,
                name = profile and profile.name or nil,
                muzzleBone = profile and profile.muzzleBone or nil,
                donorProjectile = profile and profile.donorProjectile or nil,
                presentationAdapted = profile ~= nil,
                ammo = profile and state.missileAmmo[profile.id] or 0,
                maxAmmo = profile and profile.maxAmmo or 0,
                rangeMin = profile and profile.rangeMin or nil,
                rangeMax = profile and profile.rangeMax or nil,
                damage = profile and profile.damage or nil,
                damageRadius = profile and profile.damageRadius or nil,
                damageFriendly = profile and profile.damageFriendly or nil,
                innerRing = profile and SCOCopy(profile.innerRing) or nil,
                outerRing = profile and SCOCopy(profile.outerRing) or nil,
                buildCost = profile and SCOCopy(profile.buildCost) or nil,
                buildTime = profile and profile.buildTime or nil,
                autoBuild = profile and profile.autoBuild == true,
                projectileLifetime = profile and profile.projectileLifetime or nil,
                muzzleVelocity = profile and profile.muzzleVelocity or nil,
                rateOfFire = profile and profile.rateOfFire or nil,
                rack = profile and {
                    count = 1,
                    muzzleCount = 1,
                    rackBone = profile.muzzleBone,
                    muzzleBone = profile.muzzleBone,
                    fireTogether = profile.rackFireTogether,
                    reloadTimeout = profile.rackReloadTimeout,
                    salvoChargeTime = profile.rackSalvoChargeTime,
                    salvoReloadTime = profile.rackSalvoReloadTime,
                    salvoSize = profile.rackSalvoSize,
                    muzzleChargeDelay = profile.muzzleChargeDelay,
                } or nil,
                building = build ~= nil,
                buildProfileId = build and build.profileId or nil,
                progress = build and build.progress or 0,
                fraction = build and math.min(
                    1, build.progress / build.buildTime) or 0,
                paused = build and build.paused or false,
                cooldownRemaining = math.max(
                    0, cooldownUntil - now),
            },
            teleport = {
                available = SCOInstalled(unit, "Teleporter"),
                active = teleport ~= nil,
                energyCost = SCOSupportTeleportCost(unit).energy,
                massCost = 0,
                duration = SCOSupportTeleportTime(unit),
                progress = teleport and teleport.progress or 0,
                fraction = teleport and math.min(
                    1, teleport.progress / SCOSupportTeleportTime(unit)) or 0,
                target = teleport and SCOCopy(teleport.target) or nil,
            },
        }
    end

    local function SCOValidateOwner(clientID, unitId)
        local canonicalId = SCOGlobalId(unitId)
        if not SCOInteger(clientID, 0, 2147483647) or not canonicalId then
            return nil, "invalid-request"
        end
        local unit = GetUnitById(canonicalId)
        if not unit or not SCOCommanderIds[unit.tpId] then
            return nil, "unit-not-found"
        end
        if unit.dead or unit.deleted then return nil, "unit-dead" end
        if SCOOwnerClientId(unit) ~= clientID then return nil, "not-owner" end
        local ok, state = pcall(SCOEnsureAbilityState, unit)
        if not ok then return nil, "runtime-unavailable" end
        return unit, state
    end

    local function SCOAugmentOwnerSnapshot(clientID, snapshot)
        if not SCOInteger(clientID, 0, 2147483647)
            or type(snapshot) ~= "table"
        then
            return snapshot
        end
        local unitId = SCOGlobalId(snapshot.unitId)
        local unit = unitId and GetUnitById(unitId) or nil
        if not unit or not SCOCommanderIds[unit.tpId]
            or unit.dead or unit.deleted
            or SCOOwnerClientId(unit) ~= clientID
        then
            return snapshot
        end
        local ok, abilities = pcall(SCOAbilitySnapshot, unit)
        if not ok or type(abilities) ~= "table" then return snapshot end
        -- Earlier composed host resources also own entries in this table
        -- (for example cloakAura and cloakMode).  Preserve every unknown
        -- predecessor field while keeping this resource authoritative for
        -- its version, missile, and teleport contracts.
        local previousAbilities = snapshot.abilities
        if type(previousAbilities) == "table" then
            for key, value in pairs(previousAbilities) do
                if abilities[key] == nil then abilities[key] = value end
            end
        end
        snapshot.abilities = abilities

        -- A direct snapshot produced before this isolated resource loaded may
        -- still contain the host's conservative unsupported capability copy.
        local capabilities = snapshot.capabilities
        local enhancements = capabilities and capabilities.enhancements
        if type(enhancements) == "table" then
            capabilities.teleport = true
            local teleport = enhancements.Teleporter
            if type(teleport) == "table" then
                teleport.install = true
                teleport.partial = false
                teleport.reason = nil
                teleport.domains = teleport.domains or {}
                teleport.domains.teleport = true
            end
            local missileIds = unit.tpId == "uel0000"
                and { "TacticalMissile", "TacticalNukeMissile" }
                or (unit.tpId == "usl0000" and { "Missile" } or nil)
            if missileIds then
                capabilities.manualMissiles = true
                for _, enhancementId in ipairs(missileIds) do
                    local capability = enhancements[enhancementId]
                    if type(capability) == "table" then
                        capability.install = true
                        capability.partial = true
                        capability.reason = "projectile-presentation-adapted"
                        capability.domains = capability.domains or {}
                        capability.domains.weapon = true
                    end
                end
            end
        end
        return snapshot
    end

    local function SCOEmitAbilityState(unit)
        local enhancementState = unit.scoCommanderEnhancements
        if type(enhancementState) == "table" then
            enhancementState.revision =
                ((enhancementState.revision or 0) + 1) % 2147483648
        end
        if type(unit.UpdateUIValues) == "function" then
            pcall(unit.UpdateUIValues, unit)
        end
        local clientID = SCOOwnerClientId(unit)
        local getState = rawget(_G, "SCO_CommanderEnhancementHostGetState")
        local emitState = rawget(_G, "SCO_CommanderEnhancementEmitState")
        if clientID ~= nil
            and type(getState) == "function"
            and type(emitState) == "function"
        then
            local ok, snapshot = pcall(getState, clientID, unit.id)
            if ok and type(snapshot) == "table" then
                pcall(emitState, clientID, snapshot)
            end
        end
    end

    local function SCOValidateMissileTarget(unit, profile, targetPosition)
        if type(targetPosition) ~= "table"
            or not SCOFinite(targetPosition.x)
            or not SCOFinite(targetPosition.y)
            or not SCOFinite(targetPosition.z)
        then
            return nil, "invalid-target"
        end
        local horizontal = EngineClasses.float3(
            targetPosition.x, 0, targetPosition.z)
        if not SCOMapUtils.IsPositionOnMap(horizontal) then
            return nil, "off-map"
        end
        local origin = unit:GetPosition()
        if not origin or not SCOFinite(origin.x) or not SCOFinite(origin.z) then
            return nil, "invalid-origin"
        end
        local dx = targetPosition.x - origin.x
        local dz = targetPosition.z - origin.z
        local range = math.sqrt(dx * dx + dz * dz)
        if range + 0.000001 < profile.rangeMin
            or range > profile.rangeMax + 0.000001
        then
            return nil, "out-of-range"
        end
        local result, terrainY = Engine.SampleTerrainHeight(horizontal)
        if result ~= EngineErrorCode.Success or not SCOFinite(terrainY) then
            return nil, "terrain-unavailable"
        end
        return EngineClasses.float3(
            targetPosition.x, terrainY, targetPosition.z)
    end

    local function SCOValidateDonor(profile)
        local template = __Templates.Projectiles[profile.donorProjectile]
        local general = template and template.general
        local effects = template and template.visuals
            and template.visuals.persistantEffects
        local trail = effects and effects[1] and effects[1].effects
            and effects[1].effects[1]
            and effects[1].effects[1].particleName
        if type(template) ~= "table"
            or type(general) ~= "table"
            or general.tpId ~= profile.donorProjectile
            or general.name ~= profile.donorName
            or type(general.prefabID) ~= "number"
            or trail ~= profile.donorTrail
        then
            return nil
        end
        return template
    end

    local function SCORequireEngineSuccess(result, operation)
        if result ~= EngineErrorCode.Success then
            error(operation .. " failed with engine code " .. tostring(result), 3)
        end
    end

    local function SCOConfigureMissileMotion(
        projectile, profile, muzzleRotation, targetPosition)
        SCORequireEngineSuccess(
            Engine.SetHomingProjectileTargetPosition(
                projectile.id, targetPosition),
            "commander missile target")
        SCORequireEngineSuccess(
            Engine.SetHomingProjectileTargetType(
                projectile.id, HomingType.TargetPosition),
            "commander missile target type")
        SCORequireEngineSuccess(
            Engine.SetHomingProjectileAcceleration(
                projectile.id, profile.acceleration),
            "commander missile acceleration")
        SCORequireEngineSuccess(
            Engine.SetHomingProjectileMaxSpeed(
                projectile.id, profile.maximumSpeed),
            "commander missile maximum speed")
        SCORequireEngineSuccess(
            Engine.SetHomingProjectileRotationSpeed(
                projectile.id, profile.initialTurnRate),
            "commander missile turn rate")
        SCORequireEngineSuccess(
            Engine.SetProjectileGravity(
                projectile.id, EngineClasses.float3(0, 0, 0)),
            "commander missile gravity")
        local velocity = Engine.QuaternionRotateVector(
            muzzleRotation, EngineClasses.float3(0, 0, 1))
        velocity = math3D.scale(velocity, profile.muzzleVelocity)
        SCORequireEngineSuccess(
            Engine.SetHomingProjectileVelocity(projectile.id, velocity),
            "commander missile velocity")
    end

    local function SCOMissileIsActive(projectile)
        local id = projectile and projectile.id
        return id ~= nil
            and SCOProjectiles[id.index] == projectile
            and Engine.IsValidGlobalID(id)
    end

    local function SCOWaitMissileTicks(projectile, deadline, budget, count)
        for _ = 1, count do
            if budget.remaining <= 0
                or SCOGameTime() >= deadline
                or not SCOMissileIsActive(projectile)
            then
                return false
            end
            budget.remaining = budget.remaining - 1
            WaitTicks(1)
        end
        return budget.remaining > 0
            and SCOGameTime() < deadline
            and SCOMissileIsActive(projectile)
    end

    local function SCOSetMissileTurnRate(projectile, rate)
        if not SCOMissileIsActive(projectile) then return false end
        return Engine.SetHomingProjectileRotationSpeed(projectile.id, rate)
            == EngineErrorCode.Success
    end

    local function SCOMissileDistance(projectile, targetPosition)
        local result, position =
            Engine.GetGlobalEntityWorldPosition(projectile.id)
        if result ~= EngineErrorCode.Success
            or type(position) ~= "table"
            or not SCOFinite(position.x)
            or not SCOFinite(position.z)
        then
            return nil
        end
        local dx = targetPosition.x - position.x
        local dz = targetPosition.z - position.z
        return math.sqrt(dx * dx + dz * dz)
    end

    local function SCOTacticalTurnStep(
        projectile, distance, deadline, budget)
        if distance > 50 then
            return SCOWaitMissileTicks(
                projectile, deadline, budget, 2 * SCOTickRate)
                and SCOSetMissileTurnRate(projectile, 10)
        elseif distance > 30 and distance <= 50 then
            if not SCOSetMissileTurnRate(projectile, 12) then return false end
            return SCOWaitMissileTicks(
                projectile, deadline, budget, 1.5 * SCOTickRate)
                and SCOSetMissileTurnRate(projectile, 12)
        elseif distance > 10 and distance <= 25 then
            return SCOWaitMissileTicks(
                projectile, deadline, budget, 0.3 * SCOTickRate)
                and SCOSetMissileTurnRate(projectile, 50)
        elseif distance > 0 and distance <= 10 then
            SCOSetMissileTurnRate(projectile, 100)
            return false
        end
        return true
    end

    local function SCOBillyTurnStep(
        projectile, distance, deadline, budget)
        if distance > 50 then
            return SCOWaitMissileTicks(
                projectile, deadline, budget, 2 * SCOTickRate)
                and SCOSetMissileTurnRate(projectile, 20)
        -- These bounds deliberately retain the installed FA script's branch
        -- order.  The >128 branch is unreachable after the >50 branch.
        elseif distance > 128 and distance <= 213 then
            if not SCOSetMissileTurnRate(projectile, 30) then return false end
            return SCOWaitMissileTicks(
                projectile, deadline, budget, 1.5 * SCOTickRate)
                and SCOSetMissileTurnRate(projectile, 30)
        elseif distance > 43 and distance <= 107 then
            return SCOWaitMissileTicks(
                projectile, deadline, budget, 0.3 * SCOTickRate)
                and SCOSetMissileTurnRate(projectile, 75)
        elseif distance > 0 and distance <= 43 then
            SCOSetMissileTurnRate(projectile, 200)
            return false
        end
        return true
    end

    local function SCOMissileMotionThread(
        projectile, profile, targetPosition)
        local deadline = projectile.spawnTime + profile.projectileLifetime
        local budget = {
            remaining = math.ceil(profile.projectileLifetime * SCOTickRate) + 1,
        }
        if not SCOWaitMissileTicks(
            projectile, deadline, budget, 0.3 * SCOTickRate)
        then
            return
        end
        while budget.remaining > 0
            and SCOGameTime() < deadline
            and SCOMissileIsActive(projectile)
        do
            local distance = SCOMissileDistance(projectile, targetPosition)
            local continue = true
            if distance ~= nil then
                if profile.turnBehavior == "billy" then
                    continue = SCOBillyTurnStep(
                        projectile, distance, deadline, budget)
                else
                    continue = SCOTacticalTurnStep(
                        projectile, distance, deadline, budget)
                end
            end
            if not continue
                or not SCOWaitMissileTicks(
                    projectile, deadline, budget, 0.1 * SCOTickRate)
            then
                return
            end
        end
    end

    local function SCODeleteCommanderMissile(projectile)
        if not projectile then return end
        local motionThread = projectile.scoCommanderMotionThread
        projectile.scoCommanderMotionThread = nil
        if motionThread then pcall(KillThread, motionThread) end

        local deleted, failure = pcall(projectile.Delete, projectile)
        if not deleted then
            SCOProjectiles[projectile.id.index] = nil
            pcall(Engine.DeletePrefabInstance, projectile.id)
            Warn("SCOM commander missile host delete failed: "
                .. tostring(failure))
        end
    end

    local function SCOProjectileImpactContract(profile, sourceId)
        return {
            version = SCOMissileCollisionContractVersion,
            profileId = profile.id,
            donorProjectile = profile.donorProjectile,
            sourceId = SCOGlobalId(sourceId),
            damage = profile.damage,
            damageRadius = profile.damageRadius,
            damageFriendly = profile.damageFriendly,
            innerRing = SCOCopy(profile.innerRing),
            outerRing = SCOCopy(profile.outerRing),
        }
    end

    local function SCOCommitMissileLaunch(unit, profile, targetPosition)
        local template = SCOValidateDonor(profile)
        if not template then return false, "projectile-donor-drift" end

        local muzzleId = type(unit.GetBoneId) == "function"
            and unit:GetBoneId(profile.muzzleBone) or nil
        if not muzzleId or not Engine.IsValidGlobalID(muzzleId) then
            return false, "muzzle-unavailable"
        end
        local positionResult, muzzlePosition =
            Engine.GetGlobalEntityWorldPosition(muzzleId)
        local rotationResult, muzzleRotation =
            Engine.GetGlobalEntityWorldRotation(muzzleId)
        if positionResult ~= EngineErrorCode.Success
            or rotationResult ~= EngineErrorCode.Success
            or not muzzlePosition or not muzzleRotation
            or not SCOFinite(muzzlePosition.x)
            or not SCOFinite(muzzlePosition.y)
            or not SCOFinite(muzzlePosition.z)
        then
            return false, "muzzle-transform"
        end
        local terrainResult, terrainY = Engine.SampleTerrainHeight(muzzlePosition)
        if terrainResult ~= EngineErrorCode.Success or not SCOFinite(terrainY) then
            return false, "terrain-unavailable"
        end
        local spawnPosition = EngineClasses.float3(
            muzzlePosition.x,
            math.max(muzzlePosition.y, terrainY + 0.25),
            muzzlePosition.z)
        local result, projectileId = Engine.InstantiatePrefab(
            template.general.prefabID,
            spawnPosition,
            EngineClasses.float3(1, 1, 1),
            muzzleRotation)
        if result ~= EngineErrorCode.Success
            or not projectileId
            or not Engine.IsValidGlobalID(projectileId)
        then
            return false, "instantiate-failed"
        end

        local projectile = nil
        local createSent = false
        local ok, failure = pcall(function()
            local runtimeTemplate = SCOCopy(template)
            runtimeTemplate.extraStages = nil
            if profile.id == "sacuSeraphimTactical" then
                runtimeTemplate.additions.scoTacticalProjectile = {version="1.0.0",owner="sacuCommanderAbility"}
                runtimeTemplate.additions.scoSourceProjectile.collisionRadius = 2
            end
            runtimeTemplate.movement = SCOCopy(runtimeTemplate.movement or {})
            runtimeTemplate.movement.acceleration = profile.acceleration
            runtimeTemplate.movement.alignToVelocity = true
            runtimeTemplate.movement.gravityMultiplier = 0
            runtimeTemplate.movement.rotationSpeed = profile.initialTurnRate
            runtimeTemplate.movement.speedMax = profile.maximumSpeed
            runtimeTemplate.movement.type = "LeadStaticPosition"
            SCOCommands.CreateProjectile.Send(projectileId, unit.army.id)
            createSent = true
            projectile = SCOHostProjectile(
                projectileId,
                unit.army.id,
                runtimeTemplate,
                profile.damage,
                profile.damageRadius,
                profile.projectileLifetime,
                muzzleId)
            projectile.damageFriendly = true
            projectile.sourceUnit = unit
            projectile.scoCommanderMissile =
                SCOProjectileImpactContract(profile, unit.id)
            SCOConfigureMissileMotion(
                projectile, profile, muzzleRotation, targetPosition)
            projectile.Update = function(self)
                if self.spawnTime + self.lifetime < SCOGameTime() then
                    SCODeleteCommanderMissile(self)
                end
            end
            SCOProjectiles[projectileId.index] = projectile
            local registeredMuzzle = __Muzzles and __Muzzles[muzzleId.index]
            if registeredMuzzle then
                SCOCommands.FireMuzzle.Send(muzzleId)
                registeredMuzzle:SetFiring(true)
            end
            local motionThread = NewThread(
                SCOMissileMotionThread,
                projectile,
                profile,
                targetPosition)
            if not motionThread then
                error("commander missile motion thread unavailable")
            end
            projectile.scoCommanderMotionThread = motionThread
        end)
        if not ok then
            if projectile then
                SCODeleteCommanderMissile(projectile)
            else
                if createSent then pcall(SCOCommands.DeleteProjectile.Send, projectileId) end
                pcall(Engine.DeletePrefabInstance, projectileId)
            end
            Warn("SCOM commander missile launch failed: " .. tostring(failure))
            return false, "spawn-failed"
        end
        return true, projectileId
    end

    SCOCancelMissileLaunch = function(unit, killThread)
        local state = unit.scoCommanderAbilities
        local active = state and state.missileLaunch
        if not active then return false end
        if killThread and active.thread then KillThread(active.thread) end
        active.thread = nil
        state.missileLaunch = nil
        if active.doorVisualOpen then
            SCOSendMissileDoorVisual(
                unit, "MissileDoorCancel", active.profileId)
            active.doorVisualOpen = false
        end
        return true
    end

    local function SCOFinishMissileLaunch(unit, active)
        local state = unit.scoCommanderAbilities
        if not state or state.missileLaunch ~= active then return false end

        local profile = SCOCurrentMissileProfile(unit)
        local valid = not unit.dead
            and not unit.deleted
            and SCOOwnerClientId(unit) == active.clientID
            and profile ~= nil
            and profile.id == active.profileId
            and SCOUnitIsCompleted(unit)
            and not (unit.scoCommanderEnhancements
                and unit.scoCommanderEnhancements.active)
            and state.teleport == nil
            and state.missileBuild == nil
            and state.missileAmmo[profile.id] >= 1
            and SCOGameTime() + 0.000001 >= state.missileCooldownUntil
        if not valid then
            active.thread = nil
            state.missileLaunch = nil
            if active.doorVisualOpen then
                SCOSendMissileDoorVisual(
                    unit, "MissileDoorCancel", active.profileId)
                active.doorVisualOpen = false
            end
            SCOEmitAbilityState(unit)
            return false
        end

        local canonicalTarget = SCOValidateMissileTarget(
            unit, profile, active.target)
        if not canonicalTarget then
            active.thread = nil
            state.missileLaunch = nil
            if active.doorVisualOpen then
                SCOSendMissileDoorVisual(
                    unit, "MissileDoorCancel", active.profileId)
                active.doorVisualOpen = false
            end
            SCOEmitAbilityState(unit)
            return false
        end

        local launched = SCOCommitMissileLaunch(
            unit, profile, canonicalTarget)
        active.thread = nil
        state.missileLaunch = nil
        if active.doorVisualOpen then
            SCOSendMissileDoorVisual(
                unit,
                launched and "MissileDoorClose" or "MissileDoorCancel",
                active.profileId)
            active.doorVisualOpen = false
        end
        if launched then
            state.missileAmmo[profile.id] =
                math.max(0, state.missileAmmo[profile.id] - 1)
            state.missileCooldownUntil =
                SCOGameTime() + profile.cooldownSeconds
            SCOEnsureAutoMissileBuild(unit, state, profile)
        end
        SCOEmitAbilityState(unit)
        return launched == true
    end

    local function SCOMissileLaunchThread(unit, active)
        for _ = 1, active.delayTicks do
            WaitTicks(1)
            local state = unit.scoCommanderAbilities
            if unit.dead or unit.deleted
                or not state
                or state.missileLaunch ~= active
            then
                if state and state.missileLaunch == active then
                    SCOCancelMissileLaunch(unit, false)
                    SCOEmitAbilityState(unit)
                end
                return
            end
        end
        SCOFinishMissileLaunch(unit, active)
    end

    SCOCancelMissileBuild = function(unit, killThread)
        local state = unit.scoCommanderAbilities
        local active = state and state.missileBuild
        if not active then return false end
        if killThread and active.thread then KillThread(active.thread) end
        active.thread = nil
        SCOReleaseWorkEntity(
            unit,
            "scoCommanderMissileAmmo",
            active.entity,
            unit)
        state.missileBuild = nil
        return true
    end

    local function SCOMissileBuildHasIncompatibleActivity(unit, state)
        return (unit.scoCommanderEnhancements
                and unit.scoCommanderEnhancements.active ~= nil)
            or state.teleport ~= nil
    end

    SCOConsumeMissilePaidWork = function(unit, active)
        local state = unit and unit.scoCommanderAbilities
        if not state or state.missileBuild ~= active then return false, true end

        local tick = math.floor(SCOGameTime() * SCOTickRate + 0.5)
        if active.lastConsumedTick == tick then return false, false end
        active.lastConsumedTick = tick
        if active.paused then return false, false end

        local entity = active.entity
        local multiplier = entity.productionMultiplier or 0
        local userMultiplier = entity.userMultiplier or 1
        active.progress = math.min(
            active.buildTime,
            active.progress + entity.buildPower * multiplier * userMultiplier)
        local published = false
        local bucket = math.floor(math.min(
            1, active.progress / active.buildTime) * 100)
        if bucket > active.lastPublishedBucket then
            active.lastPublishedBucket = bucket
            SCOEmitAbilityState(unit)
            published = true
        end
        if active.progress + 0.000001 >= active.buildTime then
            local profile = SCOMissileProfiles[active.profileId]
            active.thread = nil
            SCOReleaseWorkEntity(
                unit,
                "scoCommanderMissileAmmo",
                entity,
                unit)
            state.missileBuild = nil
            if profile then
                state.missileAmmo[profile.id] = profile.maxAmmo
            end
            SCOEmitAbilityState(unit)
            return true, true
        end

        -- Economy.Update charged this tick using the old builder contribution.
        -- Apply build-power changes only after consuming that paid work so the
        -- next drain and the next progress slice remain identical.
        local buildPower = unit.construction
            and unit.construction.buildPower or 0
        if buildPower ~= active.sourceBuildPower then
            entity:UpdateBuilder(unit)
            active.sourceBuildPower = buildPower
            SCOEmitAbilityState(unit)
            published = true
        end
        return published, false
    end

    SCOSyncMissileBuildPause = function(unit)
        local state = unit and unit.scoCommanderAbilities
        local active = state and state.missileBuild
        if not active then return false end
        local paused = unit:GetPause() == true
            or (active.autoBuild == true
                and SCOMissileBuildHasIncompatibleActivity(unit, state))
        if paused == active.paused then return false end
        -- Economy.Update precedes client commands and Lua threads. If a pause
        -- starts between those phases, consume the already-paid slice exactly
        -- once before disabling the entity. Unpause consumes nothing because
        -- the preceding economy pass saw the entity disabled.
        local _, completed = SCOConsumeMissilePaidWork(unit, active)
        if completed then return false end
        active.paused = paused
        SCOSetResourceActive(active.entity, not paused)
        return true
    end

    local function SCOMissileBuildThread(unit, active)
        while not unit.dead and not unit.deleted do
            local state = unit.scoCommanderAbilities
            if not state or state.missileBuild ~= active then return end
            local profile = SCOCurrentMissileProfile(unit)
            local incompatible =
                SCOMissileBuildHasIncompatibleActivity(unit, state)
            if not profile or profile.id ~= active.profileId
                or (active.autoBuild ~= true and incompatible) then
                SCOCancelMissileBuild(unit, false)
                SCOEmitAbilityState(unit)
                return
            end

            if SCOSyncMissileBuildPause(unit) then
                SCOEmitAbilityState(unit)
            end
            if state.missileBuild ~= active then return end

            if not active.paused then
                local _, completed = SCOConsumeMissilePaidWork(unit, active)
                if completed then return end
            end

            if not active.paused then
                SCOPlanLastPaidTick(
                    active.entity,
                    active.buildTime - active.progress)
            end
            WaitTicks(1)
        end
    end

    local function SCOStartMissileBuild(unit, state, profile, autoBuild)
        local entity = SCOCreateWorkEntity(
            unit,
            "scoCommanderMissileAmmo",
            profile.buildCost,
            profile.buildTime,
            unit)
        if not entity then return false, "economy-unavailable" end
        -- A monitor-created job can begin after the economy pass for this
        -- tick. Require the first real satisfaction outcome before granting
        -- work so automatic loading cannot receive one unpaid work slice.
        entity.productionMultiplier = 0
        local active = {
            profileId = profile.id,
            progress = 0,
            buildTime = profile.buildTime,
            sourceBuildPower = unit.construction
                and unit.construction.buildPower or 0,
            autoBuild = autoBuild == true,
            paused = false,
            lastPublishedBucket = 0,
            lastConsumedTick = nil,
            entity = entity,
            thread = nil,
        }
        state.missileBuild = active
        SCOSyncMissileBuildPause(unit)
        local started, thread = pcall(
            unit.NewThread,
            unit,
            SCOMissileBuildThread,
            active)
        if not started or not thread then
            SCOCancelMissileBuild(unit, false)
            return false, "build-thread-unavailable"
        end
        active.thread = thread
        return true
    end

    SCOEnsureAutoMissileBuild = function(unit, state, profile)
        state = state or SCOEnsureAbilityState(unit)
        profile = profile or SCOCurrentMissileProfile(unit)
        if not profile
            or profile.autoBuild ~= true
            or not SCOUnitIsCompleted(unit)
            or unit.dead
            or unit.deleted
            or state.missileProfileId ~= profile.id
            or state.missileBuild ~= nil
            or state.missileLaunch ~= nil
            or state.missileAmmo[profile.id] >= profile.maxAmmo
        then
            return false
        end
        return SCOStartMissileBuild(unit, state, profile, true)
    end

    local function SCOHostBuildMissile(clientID, unitId)
        local unit, state = SCOValidateOwner(clientID, unitId)
        if not unit then return false, state end
        SCOReconcileMissileProfile(unit)
        local profile = state.missileProfileId
            and SCOMissileProfiles[state.missileProfileId] or nil
        if not profile then return false, "missile-not-installed" end
        if profile.autoBuild == true then return false, "automatic-build" end
        if not SCOUnitIsCompleted(unit) then return false, "under-construction" end
        if unit.scoCommanderEnhancements
            and unit.scoCommanderEnhancements.active
        then
            return false, "enhancement-busy"
        end
        if state.teleport then return false, "teleport-busy" end
        if state.missileLaunch then return false, "missile-charging" end
        if state.missileBuild then return false, "already-building" end
        if state.missileAmmo[profile.id] >= profile.maxAmmo then
            return false, "storage-full"
        end

        local started, reason =
            SCOStartMissileBuild(unit, state, profile, false)
        if not started then return false, reason end
        SCOEmitAbilityState(unit)
        return true
    end

    local function SCOHostCancelMissile(clientID, unitId)
        local unit, state = SCOValidateOwner(clientID, unitId)
        if not unit then return false, state end
        if not state.missileBuild then return false, "not-building" end
        if state.missileBuild.autoBuild == true then
            return false, "automatic-build"
        end
        SCOCancelMissileBuild(unit, true)
        SCOEmitAbilityState(unit)
        return true
    end

    local function SCOHostLaunchMissile(clientID, unitId, targetPosition)
        local unit, state = SCOValidateOwner(clientID, unitId)
        if not unit then return false, state end
        SCOReconcileMissileProfile(unit)
        local profile = state.missileProfileId
            and SCOMissileProfiles[state.missileProfileId] or nil
        if not profile then return false, "missile-not-installed" end
        if not SCOUnitIsCompleted(unit) then return false, "under-construction" end
        if unit.scoCommanderEnhancements
            and unit.scoCommanderEnhancements.active
        then
            return false, "enhancement-busy"
        end
        if state.teleport then return false, "teleport-busy" end
        if state.missileLaunch then return false, "missile-charging" end
        if state.missileAmmo[profile.id] < 1 then return false, "no-ammo" end
        if SCOGameTime() + 0.000001 < state.missileCooldownUntil then
            return false, "rack-reloading"
        end
        local canonicalTarget, reason =
            SCOValidateMissileTarget(unit, profile, targetPosition)
        if not canonicalTarget then return false, reason end

        local presentationDelay = math.max(
            profile.muzzleChargeDelay or 0,
            profile.doorOpenSeconds or 0)
        if presentationDelay > 0 then
            local delayTicks = math.max(1, math.floor(
                presentationDelay * SCOTickRate + 0.5))
            local active = {
                clientID = clientID,
                profileId = profile.id,
                target = canonicalTarget,
                delayTicks = delayTicks,
                readyAt = SCOGameTime() + delayTicks / SCOTickRate,
                doorVisualOpen = false,
                thread = nil,
            }
            state.missileLaunch = active
            local started, thread = pcall(
                unit.NewThread,
                unit,
                SCOMissileLaunchThread,
                active)
            if not started or not thread then
                state.missileLaunch = nil
                return false, "launch-thread-unavailable"
            end
            active.thread = thread
            if profile.doorOpenSeconds then
                active.doorVisualOpen = true
                SCOSendMissileDoorVisual(
                    unit, "MissileDoorOpen", profile.id)
            end
            SCOEmitAbilityState(unit)
            return true
        end

        local launched, result =
            SCOCommitMissileLaunch(unit, profile, canonicalTarget)
        if not launched then return false, result end
        -- Consume storage only after registration and client announcement.
        state.missileAmmo[profile.id] =
            math.max(0, state.missileAmmo[profile.id] - 1)
        state.missileCooldownUntil = SCOGameTime() + profile.cooldownSeconds
        SCOEnsureAutoMissileBuild(unit, state, profile)
        SCOEmitAbilityState(unit)
        return true, result
    end

    local function SCOPlayableBounds(unit)
        local mapWidth, mapHeight = SCOMapUtils.GetMapSize()
        if not SCOFinite(mapWidth) or not SCOFinite(mapHeight) then return nil end
        local collision = unit.tp and unit.tp.collisionInfo
        local size = collision and collision.collisionSize
        if type(size) ~= "table"
            or not SCOFinite(size.x) or size.x <= 0
            or not SCOFinite(size.y) or size.y <= 0
            or not SCOFinite(size.z) or size.z <= 0
        then
            return nil
        end
        local marginX = size.x * 0.5 + 0.01
        local marginZ = size.z * 0.5 + 0.01
        local minX, minZ = marginX, marginZ
        local maxX, maxZ = mapWidth - marginX, mapHeight - marginZ
        local area = GameInfo and GameInfo.MapData and GameInfo.MapData.areas
            and GameInfo.MapData.areas.PlayableArea
        if type(area) == "table"
            and SCOFinite(area.x) and SCOFinite(area.y)
            and SCOFinite(area.width) and SCOFinite(area.height)
        then
            minX = math.max(minX, area.x + marginX)
            minZ = math.max(minZ, area.y + marginZ)
            maxX = math.min(maxX, area.x + area.width - marginX)
            maxZ = math.min(maxZ, area.y + area.height - marginZ)
        end
        if minX > maxX or minZ > maxZ then return nil end
        return minX, minZ, maxX, maxZ, size
    end

    local function SCOTeleportEndpoint(unit, targetPosition)
        if type(targetPosition) ~= "table"
            or not SCOFinite(targetPosition.x)
            or not SCOFinite(targetPosition.y)
            or not SCOFinite(targetPosition.z)
        then
            return nil, "invalid-target"
        end
        local minX, minZ, maxX, maxZ, collisionSize =
            SCOPlayableBounds(unit)
        if not minX
            or targetPosition.x < minX or targetPosition.x > maxX
            or targetPosition.z < minZ or targetPosition.z > maxZ
        then
            return nil, "outside-playable-area"
        end

        local horizontal = EngineClasses.float3(
            targetPosition.x, 0, targetPosition.z)
        local terrainResult, terrainY = Engine.SampleTerrainHeight(horizontal)
        if terrainResult ~= EngineErrorCode.Success or not SCOFinite(terrainY) then
            return nil, "terrain-unavailable"
        end
        local canonical = EngineClasses.float3(
            targetPosition.x, terrainY, targetPosition.z)

        local navigationLayer = unit.tp and unit.tp.general
            and unit.tp.general.navigationLayer
        if not SCOInteger(navigationLayer, 0, 254)
            or navigationLayer == SCOLayers.NavigationLayer.Invalid
        then
            return nil, "navigation-unavailable"
        end
        local probeRadius = math.max(
            0.5,
            math.max(collisionSize.x, collisionSize.z) * 0.5 + 0.2)
        local source = EngineClasses.float2(canonical.x, canonical.z)
        for _, offset in ipairs({
            { x = probeRadius, z = 0 },
            { x = -probeRadius, z = 0 },
            { x = 0, z = probeRadius },
            { x = 0, z = -probeRadius },
        }) do
            local destination = EngineClasses.float2(
                canonical.x + offset.x,
                canonical.z + offset.z)
            local code, result = Engine.NavmapLineCast(
                source, destination, navigationLayer)
            if code ~= EngineErrorCode.Success
                or result ~= NavmapLineCastResult.NoHit
            then
                return nil, "navigation-blocked"
            end
        end

        local rotationResult, rotation =
            Engine.GetGlobalEntityWorldRotation(unit.id)
        if rotationResult ~= EngineErrorCode.Success or not rotation then
            return nil, "rotation-unavailable"
        end
        local centerOffset = unit.tp.collisionInfo.centerOffset
            or EngineClasses.float3(0, 0, 0)
        if not SCOFinite(centerOffset.x)
            or not SCOFinite(centerOffset.y)
            or not SCOFinite(centerOffset.z)
        then
            return nil, "collision-contract"
        end
        local rotatedOffset = Engine.QuaternionRotateVector(
            rotation,
            EngineClasses.float3(
                centerOffset.x, centerOffset.y, centerOffset.z))
        local boxPosition = EngineClasses.float3(
            canonical.x + rotatedOffset.x,
            canonical.y + rotatedOffset.y,
            canonical.z + rotatedOffset.z)
        local ok, collisions = pcall(
            Engine.BoxCast,
            CollisionWorld.Collision,
            boxPosition,
            EngineClasses.float3(
                collisionSize.x, collisionSize.y, collisionSize.z),
            rotation,
            SCOLayers.CollisionLayer.Units + SCOLayers.CollisionLayer.Shields)
        if not ok or type(collisions) ~= "table" then
            return nil, "collision-query-failed"
        end
        for _, collision in ipairs(collisions) do
            local colliderId = collision.colliderGlobalID
            if colliderId
                and Engine.IsValidGlobalID(colliderId)
                and not SCOSameGlobalId(colliderId, unit.id)
            then
                return nil, "destination-occupied"
            end
        end
        return canonical
    end

    local function SCOSetTeleportMovementLock(unit, locked)
        local result = Engine.SetMovementEnabled(unit.id, not locked)
        return result == EngineErrorCode.Success
    end

    local function SCOSendAbilityVisual(
        unit, kind, source, destination, missileDoor)
        local state = unit.scoCommanderAbilities
        if type(state) ~= "table" or type(SendToAllClients) ~= "function" then
            return false
        end
        state.visualSequence = ((state.visualSequence or 0) + 1) % 2147483648
        local event = {
            version = SCOAbilityVisualProtocolVersion,
            kind = kind,
            sequence = state.visualSequence,
            unitId = SCOGlobalId(unit.id),
        }
        if kind == "TeleportCharge" or kind == "TeleportExecute" then
            if type(source) ~= "table" or type(destination) ~= "table" then
                return false
            end
            event.source = {
                x = source.x,
                y = source.y,
                z = source.z,
            }
            event.destination = {
                x = destination.x,
                y = destination.y,
                z = destination.z,
            }
        elseif kind == "MissileDoorOpen"
            or kind == "MissileDoorClose"
            or kind == "MissileDoorCancel"
        then
            if type(missileDoor) ~= "table"
                or (missileDoor.profileId ~= "uefTactical"
                    and missileDoor.profileId ~= "uefBilly")
            then
                return false
            end
            event.profileId = missileDoor.profileId
            event.phaseStartTick = SCOGameTick()
            event.durationTicks = math.floor(2 * SCOTickRate + 0.5)
            event.holdTicks = kind == "MissileDoorClose"
                and math.floor((4 / 3) * SCOTickRate + 0.5) or 0
        elseif kind ~= "TeleportCancel" then
            return false
        end
        local ok = pcall(
            SendToAllClients,
            event,
            "SCOCommanderAbilityVisualEvent")
        return ok
    end

    SCOSendMissileDoorVisual = function(unit, kind, profileId)
        return SCOSendAbilityVisual(
            unit, kind, nil, nil, { profileId = profileId })
    end

    local function SCOReleaseTeleportDrain(unit, active)
        if not active.entity then return end
        SCOReleaseWorkEntity(
            unit,
            "scoCommanderTeleport",
            active.entity,
            active.builder)
        active.entity = nil
    end

    local function SCOFinalizeTeleportUnlock(unit, active)
        local state = unit.scoCommanderAbilities
        if not state or state.teleport ~= active then return false end
        local recoveryThread = active.unlockThread
        active.unlockThread = nil
        if recoveryThread then KillThread(recoveryThread) end
        state.teleport = nil
        if active.finalKind == "execute" then
            SCOSendAbilityVisual(
                unit,
                "TeleportExecute",
                active.sourcePosition,
                active.destination)
        end
        SCOSyncMissileBuildPause(unit)
        return true
    end

    local function SCOTeleportUnlockRecoveryThread(unit, active)
        for _ = 1, SCOTeleportUnlockRetryTicks do
            WaitTicks(1)
            local state = unit.scoCommanderAbilities
            if unit.dead or unit.deleted
                or not state
                or state.teleport ~= active
            then
                return
            end
            if SCOSetTeleportMovementLock(unit, false) then
                active.unlockThread = nil
                SCOFinalizeTeleportUnlock(unit, active)
                SCOEmitAbilityState(unit)
                return
            end
        end
        active.unlockThread = nil
        active.unlockFailed = true
        Warn("SCOM commander teleport movement unlock exhausted retries")
        SCOEmitAbilityState(unit)
    end

    local function SCOStartTeleportUnlockRecovery(unit, active)
        if active.unlockThread then return true end
        active.unlockFailed = false
        local created, thread = pcall(
            unit.NewThread,
            unit,
            SCOTeleportUnlockRecoveryThread,
            active)
        if not created or not thread then
            active.unlockFailed = true
            Warn("SCOM commander teleport could not start unlock recovery: "
                .. tostring(thread))
            return false
        end
        active.unlockThread = thread
        return true
    end

    local function SCOResolveTeleportUnlock(unit, active)
        if SCOSetTeleportMovementLock(unit, false) then
            return SCOFinalizeTeleportUnlock(unit, active)
        end
        SCOStartTeleportUnlockRecovery(unit, active)
        return false
    end

    SCOCancelTeleport = function(unit, killThread, restoreMovement)
        local state = unit.scoCommanderAbilities
        local active = state and state.teleport
        if not active then return false end
        if killThread and active.thread then KillThread(active.thread) end
        active.thread = nil
        SCOReleaseTeleportDrain(unit, active)

        if not active.cancelVisualSent then
            SCOSendAbilityVisual(unit, "TeleportCancel")
            active.cancelVisualSent = true
        end
        if restoreMovement == false or unit.dead or unit.deleted then
            if active.unlockThread then KillThread(active.unlockThread) end
            active.unlockThread = nil
            state.teleport = nil
            return true
        end

        active.finalKind = active.finalKind or "cancel"
        SCOResolveTeleportUnlock(unit, active)
        return true
    end

    local function SCOCompleteTeleport(unit, active)
        local state = unit.scoCommanderAbilities
        if not state or state.teleport ~= active then return false end
        local canonical, reason = SCOTeleportEndpoint(unit, active.target)
        if not canonical then
            SCOCancelTeleport(unit, false, true)
            SCOEmitAbilityState(unit)
            return false, reason
        end

        local sourcePosition = unit:GetPosition()
        local result = Engine.SetGlobalEntityPosition(unit.id, canonical)
        if result ~= EngineErrorCode.Success then
            SCOCancelTeleport(unit, false, true)
            SCOEmitAbilityState(unit)
            return false, "position-set-failed"
        end
        active.thread = nil
        SCOReleaseTeleportDrain(unit, active)
        active.finalKind = "execute"
        active.sourcePosition = sourcePosition
        active.destination = canonical
        SCOResolveTeleportUnlock(unit, active)
        SCOEmitAbilityState(unit)
        return true
    end

    local function SCOTeleportThread(unit, active)
        while not unit.dead and not unit.deleted do
            local state = unit.scoCommanderAbilities
            if not state or state.teleport ~= active then return end
            if not SCOInstalled(unit, "Teleporter")
                or (unit.scoCommanderEnhancements
                    and unit.scoCommanderEnhancements.active)
            then
                SCOCancelTeleport(unit, false, true)
                SCOEmitAbilityState(unit)
                return
            end

            local entity = active.entity
            local multiplier = entity.productionMultiplier or 0
            local userMultiplier = entity.userMultiplier or 1
            active.progress = math.min(
                SCOSupportTeleportTime(unit),
                active.progress + entity.buildPower * multiplier * userMultiplier)
            local bucket = math.floor(math.min(
                1, active.progress / SCOSupportTeleportTime(unit)) * 100)
            if bucket > active.lastPublishedBucket then
                active.lastPublishedBucket = bucket
                SCOEmitAbilityState(unit)
            end
            if active.progress + 0.000001 >= SCOSupportTeleportTime(unit) then
                SCOCompleteTeleport(unit, active)
                return
            end
            SCOPlanLastPaidTick(
                entity,
                SCOSupportTeleportTime(unit) - active.progress)
            WaitTicks(1)
        end
    end

    local function SCOHostTeleport(clientID, unitId, targetPosition)
        local unit, state = SCOValidateOwner(clientID, unitId)
        if not unit then return false, state end
        if not SCOInstalled(unit, "Teleporter") then
            return false, "teleporter-not-installed"
        end
        if not SCOUnitIsCompleted(unit) then return false, "under-construction" end
        if unit.scoCommanderEnhancements
            and unit.scoCommanderEnhancements.active
        then
            return false, "enhancement-busy"
        end
        if state.teleport then return false, "already-teleporting" end
        if state.missileBuild
            and state.missileBuild.autoBuild ~= true
        then
            return false, "missile-build-busy"
        end
        if state.missileLaunch then return false, "missile-charging" end
        if not SCOUnitIsIdle(unit) then return false, "unit-not-idle" end
        local canonical, reason = SCOTeleportEndpoint(unit, targetPosition)
        if not canonical then return false, reason end

        local fixedBuilder = {
            id = unit.id,
            construction = { buildPower = SCOTeleportFixedBuildPower },
            adjacencyBonus = {},
        }
        local entity = SCOCreateWorkEntity(
            unit,
            "scoCommanderTeleport",
            SCOSupportTeleportCost(unit),
            SCOSupportTeleportTime(unit),
            fixedBuilder)
        if not entity then return false, "economy-unavailable" end
        if not SCOSetTeleportMovementLock(unit, true) then
            SCOReleaseWorkEntity(
                unit, "scoCommanderTeleport", entity, fixedBuilder)
            return false, "movement-lock-failed"
        end
        local active = {
            target = canonical,
            progress = 0,
            lastPublishedBucket = 0,
            builder = fixedBuilder,
            entity = entity,
            thread = nil,
        }
        state.teleport = active
        SCOSyncMissileBuildPause(unit)
        SCOSendAbilityVisual(
            unit,
            "TeleportCharge",
            unit:GetPosition(),
            canonical)
        active.thread = unit:NewThread(SCOTeleportThread, active)
        SCOEmitAbilityState(unit)
        return true
    end

    local function SCOHostCancelTeleport(clientID, unitId)
        local unit, state = SCOValidateOwner(clientID, unitId)
        if not unit then return false, state end
        if not state.teleport then return false, "not-teleporting" end
        SCOCancelTeleport(unit, true, true)
        SCOEmitAbilityState(unit)
        return true
    end

    local function SCOHostCancelAbility(clientID, unitId)
        local unit, state = SCOValidateOwner(clientID, unitId)
        if not unit then return false, state end
        if state.teleport then
            SCOCancelTeleport(unit, true, true)
        elseif state.missileLaunch then
            SCOCancelMissileLaunch(unit, true)
        elseif state.missileBuild
            and state.missileBuild.autoBuild ~= true
        then
            SCOCancelMissileBuild(unit, true)
        else
            return false, "not-busy"
        end
        SCOEmitAbilityState(unit)
        return true
    end

    local function SCOHostGetAbilityState(clientID, unitId)
        local unit, state = SCOValidateOwner(clientID, unitId)
        if not unit then return nil, state end
        return SCOAbilitySnapshot(unit)
    end

    local function SCOAbilityMonitorThread(unit)
        while not unit.dead and not unit.deleted do
            SCOEnableAbilityCapabilities(unit)
            local changed = SCOReconcileMissileProfile(unit)
            local state = unit.scoCommanderAbilities
            if SCOEnsureAutoMissileBuild(unit, state) then
                changed = true
            end
            if SCOSyncMissileBuildPause(unit) then
                changed = true
            end
            if state.teleport and not SCOInstalled(unit, "Teleporter") then
                SCOCancelTeleport(unit, false, true)
                changed = true
            end
            if changed then SCOEmitAbilityState(unit) end
            WaitTicks(1)
        end
    end

    local function SCOStartAbilityMonitor(unit)
        if not SCOCommanderIds[unit.tpId] or unit.dead or unit.deleted then return end
        local state = SCOEnsureAbilityState(unit)
        if state.monitorThread then return end
        state.monitorThread = unit:NewThread(SCOAbilityMonitorThread)
    end

    local function SCOStopAbilities(unit, restoreMovement)
        local state = unit.scoCommanderAbilities
        if not state then return end
        if state.monitorThread then
            KillThread(state.monitorThread)
            state.monitorThread = nil
        end
        if state.missileBuild then SCOCancelMissileBuild(unit, true) end
        if state.missileLaunch then SCOCancelMissileLaunch(unit, true) end
        if state.teleport then
            SCOCancelTeleport(unit, true, restoreMovement)
        end
    end

-- Insert into commander ability scope before its HostCommander hooks.
local SCOSupportAbilityIds = {ucl4002=true,uel5007=true,ugl5004=true,usl4002=true}
for id in pairs(SCOSupportAbilityIds) do SCOCommanderIds[id] = true end
local supportMissile = SCOCopy(SCOMissileProfiles.seraphimTactical)
supportMissile.id = "sacuSeraphimTactical"
supportMissile.unitTpId = "usl4002"
supportMissile.muzzleBone = "back_missile"
supportMissile.donorProjectile = "psf0141"
supportMissile.sourceId = "siflaansetacticalmissilescu"
supportMissile.blueprintSha256 = "fc6d640a7385c24fc60bc4b9614572461fa0eee4afb2de0b0120f4b92e6456c3"
supportMissile.buildTime = 1800
SCOMissileProfiles.sacuSeraphimTactical = supportMissile

local supportPreviousProfile = SCOCurrentMissileProfile
SCOCurrentMissileProfile = function(unit)
    if unit.tpId == "usl4002" and SCOInstalled(unit, "Missile") then return supportMissile end
    return supportPreviousProfile(unit)
end
local supportPreviousDonor = SCOValidateDonor
SCOValidateDonor = function(profile)
    if profile ~= supportMissile then return supportPreviousDonor(profile) end
    local template = __Templates.Projectiles[profile.donorProjectile]
    local metadata = template and template.additions and template.additions.scoSourceProjectile
    if not template or not template.general or template.general.tpId ~= profile.donorProjectile
        or type(template.general.prefabID) ~= "number" or not metadata
        or metadata.sourceId ~= profile.sourceId
        or metadata.blueprintSha256 ~= profile.blueprintSha256 then return nil end
    return template
end
local supportPreviousEnsure = SCOEnsureAbilityState
SCOEnsureAbilityState = function(unit)
    local state = supportPreviousEnsure(unit)
    if SCOSupportAbilityIds[unit.tpId] then
        state.missileAmmo.sacuSeraphimTactical = state.missileAmmo.sacuSeraphimTactical or 0
        if unit.tpId == "usl4002" then
            local capabilities = unit.scoCommanderEnhancements.capabilities
            capabilities.manualMissiles = true
            local missile = capabilities.enhancements.Missile
            missile.install, missile.partial, missile.reason = true, false, nil
            missile.domains.weapon = true
        end
    end
    return state
end
local supportUnit = HostUnit or Import("host/units/unitsClasses/unitsBaseClass.lua").HostUnit
local supportInit = supportUnit.__init
function supportUnit:__init(...)
    supportInit(self, ...)
    if SCOSupportAbilityIds[self.tpId] then
        SCOEnsureAbilityState(self)
        if SCOUnitIsCompleted(self) then SCOStartAbilityMonitor(self) end
    end
end
local supportFinish = supportUnit.OnStopBeingBuilt
function supportUnit:OnStopBeingBuilt(...)
    local result = supportFinish(self, ...)
    if SCOSupportAbilityIds[self.tpId] then SCOStartAbilityMonitor(self) end
    return result
end
local supportDestroy = supportUnit.OnDestroy
function supportUnit:OnDestroy(...)
    if SCOSupportAbilityIds[self.tpId] then SCOStopAbilities(self, false) end
    return supportDestroy(self, ...)
end
local supportPause = supportUnit.SetPause
function supportUnit:SetPause(value)
    local result = supportPause(self, value)
    if SCOSupportAbilityIds[self.tpId] and SCOSyncMissileBuildPause(self) then SCOEmitAbilityState(self) end
    return result
end
for _, method in ipairs({"CanBeAssignedToOrder", "CanMove", "CanAttack"}) do
    local old = supportUnit[method]
    supportUnit[method] = function(self, ...)
        if SCOSupportAbilityIds[self.tpId] and self.scoCommanderAbilities and self.scoCommanderAbilities.teleport then return false end
        return old(self, ...)
    end
end

    local SCOPreviousCommanderInit = HostCommander.__init
    local SCOPreviousCommanderOnStopBeingBuilt =
        HostCommander.OnStopBeingBuilt
    local SCOPreviousCommanderOnDestroy = HostCommander.OnDestroy
    local SCOPreviousCommanderSetArmy = HostCommander.SetArmy
    local SCOPreviousCommanderSetPause = HostCommander.SetPause
    local SCOPreviousCommanderCanBeAssignedToOrder =
        HostCommander.CanBeAssignedToOrder
    local SCOPreviousCommanderCanMove = HostCommander.CanMove
    local SCOPreviousCommanderCanAttack = HostCommander.CanAttack

    function HostCommander:__init(...)
        SCOPreviousCommanderInit(self, ...)
        if SCOCommanderIds[self.tpId] then
            SCOEnsureAbilityState(self)
            if SCOUnitIsCompleted(self) then SCOStartAbilityMonitor(self) end
        end
    end

    function HostCommander:OnStopBeingBuilt(...)
        local result = SCOPreviousCommanderOnStopBeingBuilt(self, ...)
        if SCOCommanderIds[self.tpId] then SCOStartAbilityMonitor(self) end
        return result
    end

    function HostCommander:OnDestroy(...)
        if SCOCommanderIds[self.tpId] then SCOStopAbilities(self, false) end
        return SCOPreviousCommanderOnDestroy(self, ...)
    end

    function HostCommander:SetArmy(army)
        -- Sanctuary represents capture by creating a fresh destination unit,
        -- transferring authoritative state, then deleting the source. A live
        -- unit's client armyId is immutable, so changing only the host army
        -- would split UI/target authority and economy ownership. Allow the
        -- constructor's initial assignment and same-army refreshes only.
        if self.army ~= nil then
            if type(self.army) ~= "table"
                or type(army) ~= "table"
                or self.army.id ~= army.id
            then
                return false
            end
            -- A same-owner refresh does not cross an authority boundary and
            -- must not cancel already-paid missile or teleport work.
            return SCOPreviousCommanderSetArmy(self, army)
        end
        local state = self.scoCommanderAbilities
        local ammo = state and SCOCopy(state.missileAmmo) or nil
        if state then SCOStopAbilities(self, true) end
        local result = SCOPreviousCommanderSetArmy(self, army)
        if state then
            state.missileAmmo = ammo
            SCOStartAbilityMonitor(self)
            SCOEmitAbilityState(self)
        end
        return result
    end

    function HostCommander:SetPause(value)
        local result = SCOPreviousCommanderSetPause(self, value)
        if SCOCommanderIds[self.tpId]
            and SCOSyncMissileBuildPause(self)
        then
            SCOEmitAbilityState(self)
        end
        return result
    end

    function HostCommander:CanBeAssignedToOrder(order)
        local state = self.scoCommanderAbilities
        if state and state.teleport then return false end
        return SCOPreviousCommanderCanBeAssignedToOrder(self, order)
    end

    function HostCommander:CanMove()
        local state = self.scoCommanderAbilities
        if state and state.teleport then return false end
        return SCOPreviousCommanderCanMove(self)
    end

    function HostCommander:CanAttack()
        local state = self.scoCommanderAbilities
        if state and state.teleport then return false end
        return SCOPreviousCommanderCanAttack(self)
    end

    local SCOPreviousEnhancementStart =
        rawget(_G, "SCO_CommanderEnhancementHostStart")
    local SCOPreviousEnhancementRemove =
        rawget(_G, "SCO_CommanderEnhancementHostRemove")
    local SCOPreviousEnhancementCancel =
        rawget(_G, "SCO_CommanderEnhancementHostCancel")
    local SCOPreviousEnhancementGetState =
        rawget(_G, "SCO_CommanderEnhancementHostGetState")
    local SCOPreviousEnhancementTransfer =
        rawget(_G, "SCO_CommanderEnhancementHostTransfer")
    if type(SCOPreviousEnhancementStart) ~= "function"
        or type(SCOPreviousEnhancementRemove) ~= "function"
        or type(SCOPreviousEnhancementCancel) ~= "function"
        or type(SCOPreviousEnhancementGetState) ~= "function"
        or type(SCOPreviousEnhancementTransfer) ~= "function"
    then
        error("SCOM commander abilities could not resolve enhancement exports")
    end

    local function SCOAbilityBusyForAuthenticatedOwner(clientID, unitId)
        local unit, state = SCOValidateOwner(clientID, unitId)
        if not unit then return false, nil end
        return state.teleport ~= nil
            or (state.missileBuild ~= nil
                and state.missileBuild.autoBuild ~= true)
            or state.missileLaunch ~= nil,
            unit
    end

    _G.SCO_CommanderEnhancementHostStart = function(
        clientID, unitId, enhancementId)
        local busy, unit = SCOAbilityBusyForAuthenticatedOwner(clientID, unitId)
        if busy then return false, "ability-busy" end
        if unit then SCOEnableAbilityCapabilities(unit) end
        local accepted, reason =
            SCOPreviousEnhancementStart(clientID, unitId, enhancementId)
        if accepted == true and unit
            and SCOSyncMissileBuildPause(unit)
        then
            SCOEmitAbilityState(unit)
        end
        return accepted, reason
    end

    _G.SCO_CommanderEnhancementHostRemove = function(
        clientID, unitId, enhancementId)
        local busy, unit = SCOAbilityBusyForAuthenticatedOwner(clientID, unitId)
        if busy then return false, "ability-busy" end
        if unit then SCOEnableAbilityCapabilities(unit) end
        local accepted, reason =
            SCOPreviousEnhancementRemove(clientID, unitId, enhancementId)
        if accepted == true and unit
            and SCOSyncMissileBuildPause(unit)
        then
            SCOEmitAbilityState(unit)
        end
        return accepted, reason
    end

    _G.SCO_CommanderEnhancementHostCancel = function(clientID, unitId)
        local unit, state = SCOValidateOwner(clientID, unitId)
        if unit and (state.teleport
                or (state.missileBuild
                    and state.missileBuild.autoBuild ~= true)
                or state.missileLaunch)
        then
            return SCOHostCancelAbility(clientID, unitId)
        end
        local accepted, reason =
            SCOPreviousEnhancementCancel(clientID, unitId)
        if accepted == true and unit
            and SCOSyncMissileBuildPause(unit)
        then
            SCOEmitAbilityState(unit)
        end
        return accepted, reason
    end

    _G.SCO_CommanderEnhancementHostGetState = function(clientID, unitId)
        local unit = SCOGlobalId(unitId) and GetUnitById(unitId) or nil
        if unit and SCOCommanderIds[unit.tpId]
            and SCOOwnerClientId(unit) == clientID
        then
            SCOEnsureAbilityState(unit)
            SCOEnableAbilityCapabilities(unit)
            SCOReconcileMissileProfile(unit)
        end
        local snapshot, reason =
            SCOPreviousEnhancementGetState(clientID, unitId)
        if type(snapshot) == "table" then
            snapshot = SCOAugmentOwnerSnapshot(clientID, snapshot)
        end
        return snapshot, reason
    end

    local function SCOAbilityTransferStateIsCompatible(unit)
        if type(unit) ~= "table" then return false end
        local state = unit.scoCommanderAbilities
        if state == nil then return true end
        return type(state) == "table"
            and state.version == SCOCommanderAbilityVersion
            and type(state.missileAmmo) == "table"
    end

    _G.SCO_CommanderEnhancementHostTransfer = function(source, destination)
        -- The predecessor commits enhancement and pod ownership atomically.
        -- Reject incompatible ability-state boundaries before that commit so a
        -- mixed-version unit cannot leave the two systems split across owners.
        if not SCOAbilityTransferStateIsCompatible(source)
            or not SCOAbilityTransferStateIsCompatible(destination)
        then
            return false
        end
        local sourceState = source and source.scoCommanderAbilities
        local completedAmmo = sourceState
            and SCOCopy(sourceState.missileAmmo) or nil
        local transferred = SCOPreviousEnhancementTransfer(source, destination)
        if transferred == true and completedAmmo then
            SCOStopAbilities(source, false)
            local destinationState = SCOEnsureAbilityState(destination)
            SCOStopAbilities(destination, true)
            destinationState.missileAmmo = completedAmmo
            SCOEnableAbilityCapabilities(destination)
            SCOReconcileMissileProfile(destination)
            SCOStartAbilityMonitor(destination)
            SCOEmitAbilityState(destination)
        end
        return transferred
    end

    local SCOPreviousEmitState =
        rawget(_G, "SCO_CommanderEnhancementEmitState")
    if type(SCOPreviousEmitState) == "function" then
        _G.SCO_CommanderEnhancementEmitState = function(clientID, snapshot)
            return SCOPreviousEmitState(
                clientID,
                SCOAugmentOwnerSnapshot(clientID, snapshot))
        end
    end

    local function SCOInstallExport(name, handler)
        if rawget(_G, name) ~= nil then
            error("SCOM commander-ability export is occupied: " .. name)
        end
        _G[name] = handler
    end

    SCOInstallExport(
        "SCO_CommanderAbilityHostBuildMissile", SCOHostBuildMissile)
    SCOInstallExport(
        "SCO_CommanderAbilityHostCancelMissile", SCOHostCancelMissile)
    SCOInstallExport(
        "SCO_CommanderAbilityHostLaunchMissile", SCOHostLaunchMissile)
    SCOInstallExport("SCO_CommanderAbilityHostTeleport", SCOHostTeleport)
    SCOInstallExport(
        "SCO_CommanderAbilityHostCancelTeleport", SCOHostCancelTeleport)
    SCOInstallExport("SCO_CommanderAbilityHostCancel", SCOHostCancelAbility)
    SCOInstallExport(
        "SCO_CommanderAbilityHostGetState", SCOHostGetAbilityState)
    SCOInstallExport(
        "SCO_CommanderAbilityAugmentOwnerSnapshot", SCOAugmentOwnerSnapshot)

    rawset(
        SCOCommanderAbilityEnvironment,
        "SCO_CommanderAbilityHostInstalled",
        SCOCommanderAbilityVersion)
end

-- Supreme Commander Overhaul engineer medium probe 1.0.0

-- Supreme Commander Overhaul naval wreck sinking 1.1.0

-- Supreme Commander Overhaul commander/engineer build facing 1.2.3
local SCO_BuildFacingStart = HostEngineer.OnStartBuildRoutine
local SCO_BuildFacingStop = HostEngineer.OnStopBuildRoutine
local SCO_BuildFacingRepairStart = HostEngineer.OnStartRepairRoutine
local SCO_BuildFacingRepairStop = HostEngineer.OnStopRepairRoutine
if type(SCO_BuildFacingStart) ~= "function"
    or type(SCO_BuildFacingStop) ~= "function"
    or type(SCO_BuildFacingRepairStart) ~= "function"
    or type(SCO_BuildFacingRepairStop) ~= "function"
then
    error("SCOM builder facing could not capture HostEngineer build callbacks")
end

local function SCO_BuildFacingIsACU(unit)
    return unit.tpId == 'uel0000' or unit.tpId == 'ugl0000'
        or unit.tpId == 'ucl0000' or unit.tpId == 'usl0000'
end

local function SCO_BuildFacingCanAimRepair(unit)
    return SCO_BuildFacingIsACU(unit) or unit.tpId == 'uel1501'
        or unit.tpId == 'uel2501' or unit.tpId == 'uel3501'
end

local function SCO_BuildFacingGetSpec(unit)
    local additions = unit.tp and unit.tp.additions
    local spec = type(additions) == "table" and additions.scomBuildFacing
    if type(spec) ~= "table" then return nil end
    return spec
end

local function SCO_BuildFacingResolveControllers(unit, spec)
    if type(spec.controllers) ~= "table" or spec.controllers[1] == nil then
        return nil
    end
    local controllerIDs = {}
    for _, controller in ipairs(spec.controllers) do
        local resultCode, controllerID = Engine.GetGlobalBone(unit.id, controller.aimBone)
        if resultCode ~= EngineErrorCode.Success then
            Warn("SCOM builder facing could not resolve " .. unit.tpId .. " bone " .. tostring(controller.aimBone))
            return nil
        end
        table.insert(controllerIDs, controllerID)
    end
    return controllerIDs
end

local function SCO_BuildFacingFaceWholeUnit(unit, targetUnit)
    local directionResult, forward = Engine.GetGlobalEntityForwardDirection(unit.id)
    local restoreDirection = nil
    if directionResult == EngineErrorCode.Success then
        local forwardLength = math.sqrt(forward.x * forward.x + forward.z * forward.z)
        if forwardLength > 0.000001 then
            restoreDirection = EngineClasses.float2(
                forward.x / forwardLength, forward.z / forwardLength)
        end
    end
    local source = unit:GetPosition()
    local target = targetUnit:GetPosition()
    local x = target.x - source.x
    local y = target.z - source.z
    local length = math.sqrt(x * x + y * y)
    if length <= 0.000001 then return nil end
    unit:SetMovementPatterns("hold")
    local faceResult = Engine.MovementStop(
        unit.id, EngineClasses.float2(x / length, y / length))
    if faceResult ~= EngineErrorCode.Success then return nil end
    return restoreDirection
end

local function SCO_BuildFacingRelease(unit, resolveMissing)
    local ownership = unit.scoBuildFacingOwnership
    if not ownership and resolveMissing then
        local spec = SCO_BuildFacingGetSpec(unit)
        if spec and not spec.faceWholeUnit then
            local controllerIDs = SCO_BuildFacingResolveControllers(unit, spec)
            if controllerIDs then
                ownership = { controllerIDs = controllerIDs }
                unit.scoBuildFacingOwnership = ownership
            end
        end
    end
    if not ownership then return true end
    if ownership.thread then
        KillThread(ownership.thread)
        ownership.thread = nil
    end
    local success = true
    if ownership.controllerIDs then
        local noTarget = EngineClasses.GlobalID()
        for _, controllerID in ipairs(ownership.controllerIDs) do
            local enabledResult = Engine.SetAimControllerEnabled(controllerID, true)
            local targetResult = Engine.SetAimControllerTarget(controllerID, noTarget)
            local stateResult = Engine.SetAimControllerState(
                controllerID, AimControllerState.Rest)
            if enabledResult ~= EngineErrorCode.Success
                or targetResult ~= EngineErrorCode.Success
                or stateResult ~= EngineErrorCode.Success
            then
                success = false
            end
        end
    elseif ownership.restoreDirection then
        success = Engine.MovementStop(unit.id, ownership.restoreDirection)
            == EngineErrorCode.Success
    end
    if success then
        unit.scoBuildFacingOwnership = nil
    else
        Warn("SCOM builder facing could not release " .. unit.tpId)
    end
    return success
end

local SCO_BuildFacingConstructionTarget
local SCO_BuildFacingAcuMarkerRange = 32
local SCO_BuildFacingAcuDeadZone = 0.25
local function SCO_BuildFacingGetTargetPosition(targetUnit)
    if not SCO_BuildFacingConstructionTarget then
        SCO_BuildFacingConstructionTarget = Import("common/systems/scoConstructionTarget.lua")
    end
    return SCO_BuildFacingConstructionTarget.GetPosition(targetUnit)
end

local function SCO_BuildFacingResolveControllerPoint(unit, spec, ownership, targetUnit)
    local point = SCO_BuildFacingGetTargetPosition(targetUnit)
    if not spec.torsoYawOnly then return point end
    point = point or targetUnit:GetPosition()
    if not point then return nil end
    local source = unit:GetPosition()
    local x = point.x - source.x
    local z = point.z - source.z
    local length = math.sqrt(x * x + z * z)
    local direction = ownership.lastDirection
    if length > SCO_BuildFacingAcuDeadZone then
        direction = EngineClasses.float2(x / length, z / length)
        ownership.lastDirection = direction
    elseif not direction then
        return nil
    end
    -- A distant horizontal target removes the close-range muzzle/yaw feedback
    -- loop while preserving the intended torso heading. Beam placement stays native.
    return EngineClasses.float3(
        source.x + direction.x * SCO_BuildFacingAcuMarkerRange,
        source.y,
        source.z + direction.y * SCO_BuildFacingAcuMarkerRange)
end

local function SCO_BuildFacingSetTargetPosition(unit, marker, point)
    -- GlobalID identifies the entity; this setter writes parent-local translation.
    -- The marker is a direct child of the unit head, spawned at unit scale.
    local offset = math3D.sub(point, unit:GetPosition())
    local rotation = math3D.invert(unit:GetOrientation())
    local localPoint = Engine.QuaternionRotateVector(rotation, offset)
    return Engine.SetGlobalEntityPosition(marker, localPoint)
end

local function SCO_BuildFacingTrackTarget(unit, spec, ownership, targetUnit)
    -- The controller belongs to this work routine, never to combat targeting.
    WaitTicks(1)
    while unit.scoBuildFacingOwnership == ownership do
        if unit.dead or unit.deleted or targetUnit.dead or targetUnit.deleted
            or unit:GetPause()
            or (not unit:IsBuilding(targetUnit) and not unit:IsRepairing(targetUnit))
        then
            break
        end
        local point = SCO_BuildFacingResolveControllerPoint(
            unit, spec, ownership, targetUnit)
        if not point then break end
        if SCO_BuildFacingSetTargetPosition(unit, ownership.marker, point) ~= EngineErrorCode.Success then
            Warn("SCOM builder facing could not update work point for " .. unit.tpId)
            break
        end
        WaitTicks(1)
    end
    ownership.thread = nil
    if unit.scoBuildFacingOwnership == ownership then
        SCO_BuildFacingRelease(unit, false)
    end
end

local function SCO_BuildFacingAim(self, targetUnit)
    if not SCO_BuildFacingRelease(self, false) then return end
    local spec = SCO_BuildFacingGetSpec(self)
    if not spec or not targetUnit or targetUnit.dead or targetUnit.deleted
        or (not SCO_BuildFacingIsACU(self) and self.tpId ~= 'uel2501' and not targetUnit:HasTags(Tags.STRUCTURE))
    then
        return
    end
    if spec.faceWholeUnit == true then
        local restoreDirection = SCO_BuildFacingFaceWholeUnit(self, targetUnit)
        if restoreDirection then
            self.scoBuildFacingOwnership = {
                restoreDirection = restoreDirection,
            }
        end
        return
    end
    local controllerIDs = SCO_BuildFacingResolveControllers(self, spec)
    local targetCollider = targetUnit.targetCollider
    if not controllerIDs or not targetCollider or not targetCollider.id then return end
    local ownership = { controllerIDs = controllerIDs }
    local targetID = targetCollider.id
    local point = SCO_BuildFacingResolveControllerPoint(
        self, spec, ownership, targetUnit)
    if spec.torsoYawOnly and not point then return end
    self.scoBuildFacingOwnership = ownership
    if point then
        local markerResult, marker = Engine.GetGlobalBone(self.id, "SCOConstructionTarget")
        if markerResult ~= EngineErrorCode.Success or not marker
            or SCO_BuildFacingSetTargetPosition(self, marker, point) ~= EngineErrorCode.Success
        then
            Warn("SCOM builder facing could not resolve work point for " .. self.tpId)
            SCO_BuildFacingRelease(self, false)
            return
        end
        ownership.marker = marker
        targetID = marker
    end
    for _, controllerID in ipairs(controllerIDs) do
        local targetResult = Engine.SetAimControllerTarget(
            controllerID, targetID)
        local enabledResult = Engine.SetAimControllerEnabled(controllerID, true)
        local stateResult = Engine.SetAimControllerState(
            controllerID, AimControllerState.Aiming)
        if targetResult ~= EngineErrorCode.Success
            or enabledResult ~= EngineErrorCode.Success
            or stateResult ~= EngineErrorCode.Success
        then
            Warn("SCOM builder facing could not activate " .. self.tpId)
            SCO_BuildFacingRelease(self, false)
            return
        end
    end
    if ownership.marker then
        ownership.thread = self:NewThread(
            SCO_BuildFacingTrackTarget, spec, ownership, targetUnit)
    end
end

function HostEngineer:OnStartBuildRoutine(targetUnit)
    SCO_BuildFacingStart(self, targetUnit)
    SCO_BuildFacingAim(self, targetUnit)
end

function HostEngineer:OnStopBuildRoutine(targetUnit)
    SCO_BuildFacingStop(self, targetUnit)
    SCO_BuildFacingRelease(self, true)
end

function HostEngineer:OnStartRepairRoutine(targetUnit)
    SCO_BuildFacingRepairStart(self, targetUnit)
    if SCO_BuildFacingCanAimRepair(self) then SCO_BuildFacingAim(self, targetUnit) end
end

function HostEngineer:OnStopRepairRoutine(targetUnit)
    SCO_BuildFacingRepairStop(self, targetUnit)
    if SCO_BuildFacingCanAimRepair(self) then SCO_BuildFacingRelease(self, true) end
end
-- SCOM Field Fixes 1.0.1 - completed structures request silo assistance.
local SCOFieldFixStrategicSiloStructureAssistEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOFieldFixStrategicSiloStructureAssistMarker = rawget(
    SCOFieldFixStrategicSiloStructureAssistEnvironment,
    "SCO_FieldFixStrategicSiloStructureAssistInstalled")
if SCOFieldFixStrategicSiloStructureAssistMarker ~= nil
    and SCOFieldFixStrategicSiloStructureAssistMarker ~= "1.0.1"
then
    error("Unsupported SCOM silo structure-assist marker "
        .. tostring(SCOFieldFixStrategicSiloStructureAssistMarker))
end
if SCOFieldFixStrategicSiloStructureAssistMarker == nil then
    if type(HostStructure) ~= "table"
        or type(HostStructure.DesiresAssistance) ~= "function"
    then
        error("SCOM silo structure assist could not resolve HostStructure")
    end
    local SCOStructureDesiresAssistance =
        HostStructure.DesiresAssistance

    function HostStructure:DesiresAssistance(fromUnit)
        -- Engineers can be assigned before the first missile is queued and
        -- remain ready for later stockpile work, as with a factory.
        if self.scoStrategicSilo then
            return true
        end
        local state = self.scoTactical
        if state and (state.building
            or state.queued > 0
            or (state.autoBuild
                and state.ammo < state.contract.maxAmmo))
        then
            return true
        end
        return SCOStructureDesiresAssistance(self, fromUnit)
    end

    rawset(
        SCOFieldFixStrategicSiloStructureAssistEnvironment,
        "SCO_FieldFixStrategicSiloStructureAssistInstalled",
        "1.0.1")
    _G.SCO_FieldFixStrategicSiloStructureAssistInstalled = "1.0.1"
end
-- Source sonar upgrades finish in mobile units; reuse Structure transfer/cleanup.
local SourceMobileUpgradePredecessors = {uen3005="ues5021", ugn3005="ugs5010"}
local SourcePreviousNavalEndUpgrade = HostNavalUnit.OnEndUpgrade
function HostNavalUnit:OnEndUpgrade(upgrader)
    if upgrader and SourceMobileUpgradePredecessors[self.tpId] == upgrader.tpId
        and upgrader.construction and upgrader.construction.upgradesTo == self.tpId then
        return HostStructure.OnEndUpgrade(self, upgrader)
    end
    return SourcePreviousNavalEndUpgrade(self, upgrader)
end


-- Match the Novax satellite's ascent to its four-second sail deployment.
-- All other aircraft retain the native 1.5-second takeoff.
local SourcePreviousTakeoffBehaviorThread = HostAirUnit.TakeoffBehaviorThread
function HostAirUnit:TakeoffBehaviorThread()
    if self.tpId ~= "uea5009" then
        return SourcePreviousTakeoffBehaviorThread(self)
    end

    self.isAirborne = true
    self:SetAirborneLayers()
    Engine.SetMovementEnabled(self.id, false)

    local _, position = Engine.GetGlobalEntityWorldPosition(self.id)
    local _, terrainHeight = Engine.SampleTerrainHeight(position)
    local preferredAltitude = self.tp.movement.preferredAltitude
    local _, forward = Engine.GetGlobalEntityForwardDirection(self.id)
    local uprightRotation = Engine.QuaternionLookRotationSafe(
        math3D.normalize(EngineClasses.float3(forward.x, 0, forward.z)),
        EngineClasses.float3(0, 1, 0))

    local curve = Curve.Play(self, {
        duration = 4.0,
        position = {
            mode = Curve.Absolute,
            y = Curve.EaseInOut(position.y, terrainHeight + preferredAltitude),
        },
        rotation = { target = uprightRotation, ease = Curve.Ease.EaseInOut },
    })
    while not curve:Update() do
        WaitTicks(1)
    end

    Engine.SetMovementEnabled(self.id, true)
    self:TakeoffBehaviourStop()
    if self.orders.activeOrder == nil and #self.orders.queuedOrders == 0 then
        self:OnBecameIdle()
    end
end

-- FA source adjacency integration for the SCOM host roster.
do
local SCO_FA_Manifest = (function()
-- Generated by build_manifest.py from the installed retail FA archives.
return {
  schema = "fa-retail-adjacency-to-scom-v1",
  adjacencyBuffsSha256 = "27a707a6f6226bec5b873747aaf8c529360215f3756a943a119c244369eb24df",
  stacks = "ALWAYS",
  duration = -1,
  mult = 1,
  providers = {
    ["ucs1601"] = { sourceId = "UAB1103", sourceBlueprintSha256 = "a689422b2297f98499348c07ad287c27814ca9c136c92043e055e16f82e3989f", tableName = "T1MassExtractorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ucs1602"] = { sourceId = "UAB1106", sourceBlueprintSha256 = "67fa5432484ba5a246f0ed1920b3de446472d3d424d06547bdae20977b38776d", tableName = "T1MassStorageAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ucs1611"] = { sourceId = "UAB1101", sourceBlueprintSha256 = "ee45b4f2d63480574a0d370ae2372cd5d44b20e88869cac5003b2500d479094d", tableName = "T1PowerGeneratorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ucs1612"] = { sourceId = "UAB1105", sourceBlueprintSha256 = "a956cc05ab2d449c1252d0d2e088f55347da95b85f91428c4dde955dbcd2bd7b", tableName = "T1EnergyStorageAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ucs1614"] = { sourceId = "UAB1102", sourceBlueprintSha256 = "226e38c51f687f906d0d30ba449d032223b40eed65aaff7bb8c0607b021f25b6", tableName = "HydrocarbonAdjacencyBuffs", sizeTag = "SCFA_SIZE12" },
    ["ucs2601"] = { sourceId = "UAB1202", sourceBlueprintSha256 = "79b006969a88b2e16acebe9cfd234890397b5fcd77a7e9c9f9e783efef0725d7", tableName = "T2MassExtractorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ucs2611"] = { sourceId = "UAB1201", sourceBlueprintSha256 = "780b0749722ac6c56861949cd03a8a40de76a3b0c1e026d07ea861460b99fc9f", tableName = "T2PowerGeneratorAdjacencyBuffs", sizeTag = "SCFA_SIZE12" },
    ["ucs2806"] = { sourceId = "UAB1104", sourceBlueprintSha256 = "3c4eb4cef01985a92ce78af0b587346f9df08d3fc471cb52f22b307e3e47ff5f", tableName = "T1MassFabricatorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ucs3601"] = { sourceId = "UAB1302", sourceBlueprintSha256 = "18a5d6b6e2a027d0d599dc47177e48883190de7fadc97e3da3eab25a0010ad83", tableName = "T3MassExtractorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ucs3603"] = { sourceId = "UAB1303", sourceBlueprintSha256 = "dfc725ed7309bf0bb00f1bd07b83cd25d356413cc9783cee81be55463f237be1", tableName = "T3MassFabricatorAdjacencyBuffs", sizeTag = "SCFA_SIZE12" },
    ["ucs3611"] = { sourceId = "UAB1301", sourceBlueprintSha256 = "96e85f646efd233848af22f3cd6c6bfc74afde1f5dd27e5d2975f1b0fd11dfcf", tableName = "T3PowerGeneratorAdjacencyBuffs", sizeTag = "SCFA_SIZE16" },
    ["ues1601"] = { sourceId = "UEB1103", sourceBlueprintSha256 = "86c7f83bd2c803cd1640e9a88785bf847aff377287ceabedbe7d7735083e55bf", tableName = "T1MassExtractorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ues1602"] = { sourceId = "UEB1106", sourceBlueprintSha256 = "3c728933dfe3567a969b4ee8a6663fac7e600dca163873e4eba6374fa0d549a7", tableName = "T1MassStorageAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ues1611"] = { sourceId = "UEB1101", sourceBlueprintSha256 = "0382700aa10d13a2ef2e02e5fd95e42baf51962f51268c61c929324860ca23ec", tableName = "T1PowerGeneratorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ues1612"] = { sourceId = "UEB1105", sourceBlueprintSha256 = "c034747eef467a9ce0895dcc670384b6ef404b2427e3fffa7ad0c3a6d4200384", tableName = "T1EnergyStorageAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ues2601"] = { sourceId = "UEB1202", sourceBlueprintSha256 = "a9cd0868668e03102cfa642387727daacb22fc6b1816c857ad1d95cd3efe02a2", tableName = "T2MassExtractorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ues2611"] = { sourceId = "UEB1201", sourceBlueprintSha256 = "49ea20d181b052fabd2563a799c87dadb89a71025233210ef59a944e34c95e17", tableName = "T2PowerGeneratorAdjacencyBuffs", sizeTag = "SCFA_SIZE12" },
    ["ues3601"] = { sourceId = "UEB1302", sourceBlueprintSha256 = "4f488f277b85b44ea8d422228e936d2933e8e667b690e633e89a13e6560558ef", tableName = "T3MassExtractorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ues3603"] = { sourceId = "UEB1303", sourceBlueprintSha256 = "fbb11aa62f87e520fea91e63f7f7f9bedb83fb1f2f59f7e78bd031522496ba4b", tableName = "T3MassFabricatorAdjacencyBuffs", sizeTag = "SCFA_SIZE12" },
    ["ues3611"] = { sourceId = "UEB1301", sourceBlueprintSha256 = "71e92d602bed2a04916c020662df4f1ac74030cd7de70eff0f962aa760cd57af", tableName = "T3PowerGeneratorAdjacencyBuffs", sizeTag = "SCFA_SIZE16" },
    ["ues5015"] = { sourceId = "UEB1102", sourceBlueprintSha256 = "c881c49165ff33b9644eb62910fad3ed2075fdf732f1fc5dceb028b673f710fc", tableName = "HydrocarbonAdjacencyBuffs", sizeTag = "SCFA_SIZE12" },
    ["ues5016"] = { sourceId = "UEB1104", sourceBlueprintSha256 = "c4ae102f6ed87c4e5c04b2ae019b16b5cf53244dc95ab865e3fc0d12286bdd52", tableName = "T1MassFabricatorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ugs1601"] = { sourceId = "URB1103", sourceBlueprintSha256 = "e723b2d7f3b916bd24f46587a9ef7c3691b60265830553bb234505cd162db1ef", tableName = "T1MassExtractorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ugs1602"] = { sourceId = "URB1106", sourceBlueprintSha256 = "323ac892e188940daad815df6ee42ffe2f75585376591ede1965706ca51055f7", tableName = "T1MassStorageAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ugs1611"] = { sourceId = "URB1101", sourceBlueprintSha256 = "734334190aa6eef78ac93913147b0849c9add39f9850e983cc79641a5bb601ba", tableName = "T1PowerGeneratorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ugs1612"] = { sourceId = "URB1105", sourceBlueprintSha256 = "5f7f46eea3ee0e1ddd37db354fb54ff30fe197aa5b2c45e04ab21706f0427e59", tableName = "T1EnergyStorageAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ugs2601"] = { sourceId = "URB1202", sourceBlueprintSha256 = "b89469f2fa005d292b134e78aa46bf36d3ba3693085bf4b2a991d84635924a9c", tableName = "T2MassExtractorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ugs2611"] = { sourceId = "URB1201", sourceBlueprintSha256 = "19cef2bfff64f1dd4f859db54272fbfd5753912baadefc8db898f6b31fc4c0cb", tableName = "T2PowerGeneratorAdjacencyBuffs", sizeTag = "SCFA_SIZE12" },
    ["ugs3601"] = { sourceId = "URB1302", sourceBlueprintSha256 = "8e6c44d30877de9829061ac604f160ed81797698d6bed13c3580dc98ea5baf8c", tableName = "T3MassExtractorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["ugs3603"] = { sourceId = "URB1303", sourceBlueprintSha256 = "bf7930986d1b416fc4db68e070f4b1249d2edce04c82415c03791f62ab79ae75", tableName = "T3MassFabricatorAdjacencyBuffs", sizeTag = "SCFA_SIZE12" },
    ["ugs3611"] = { sourceId = "URB1301", sourceBlueprintSha256 = "e1d59ee7ded7cae10c69bfde8fe4a76927de45449b35dd951de2ae3be9947439", tableName = "T3PowerGeneratorAdjacencyBuffs", sizeTag = "SCFA_SIZE16" },
    ["ugs5003"] = { sourceId = "URB1102", sourceBlueprintSha256 = "5d744a449a2f1c66a8523324b5f37581b2bea656169fc6c260b7d096316bcd99", tableName = "HydrocarbonAdjacencyBuffs", sizeTag = "SCFA_SIZE12" },
    ["ugs5004"] = { sourceId = "URB1104", sourceBlueprintSha256 = "8adf72c514ddbeade7f7b08a150f3dd9a894ad1459a0ff30f5efbb1651431f50", tableName = "T1MassFabricatorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["uss1601"] = { sourceId = "XSB1103", sourceBlueprintSha256 = "159d28c3cba3926678b7a63172fc1e6bcc0119da4252b873033a0b4c3270f0c4", tableName = "T1MassExtractorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["uss1602"] = { sourceId = "XSB1106", sourceBlueprintSha256 = "bf41d3107fb3a1cd6bcee688306fe496e7a07a87cac8e2a729f64108f5fc4336", tableName = "T1MassStorageAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["uss1611"] = { sourceId = "XSB1101", sourceBlueprintSha256 = "ba1ca690e52e57843cb4304a14e4e4bc361fbfb2018b6882d2b6d31da922027d", tableName = "T1PowerGeneratorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["uss1612"] = { sourceId = "XSB1105", sourceBlueprintSha256 = "c6aa766013df3f1d51c81d16a0d4662a317cd068cc026d73c9e9316762be3070", tableName = "T1EnergyStorageAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["uss1614"] = { sourceId = "XSB1102", sourceBlueprintSha256 = "3c83b8f1ac1224e0d65768164ff3e9b791e22ca81fa4a3d17a214a2130692473", tableName = "HydrocarbonAdjacencyBuffs", sizeTag = "SCFA_SIZE12" },
    ["uss2601"] = { sourceId = "XSB1202", sourceBlueprintSha256 = "91ad0dfaddeda2ff4ce374093402c9f49c7a3cd6942ad8336e32f24bdbb72787", tableName = "T2MassExtractorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["uss2611"] = { sourceId = "XSB1201", sourceBlueprintSha256 = "98233f21427098d2c34a7ef8334068200bf4da361a46a26feaf391384bd162ea", tableName = "T2PowerGeneratorAdjacencyBuffs", sizeTag = "SCFA_SIZE12" },
    ["uss2806"] = { sourceId = "XSB1104", sourceBlueprintSha256 = "06804bda7421af1fbb486f8da89c561c423e2951631d93dbf4e3915b64929514", tableName = "T1MassFabricatorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["uss3601"] = { sourceId = "XSB1302", sourceBlueprintSha256 = "6d4c49eac21e412bb284a515850a52f60a69c1c1cefc35a1bbf0cc83c72fd3c8", tableName = "T3MassExtractorAdjacencyBuffs", sizeTag = "SCFA_SIZE4" },
    ["uss3603"] = { sourceId = "XSB1303", sourceBlueprintSha256 = "009adb261deefbb544dba5abb8785da2bcf1c1e84ec6abcc12a314228755bf75", tableName = "T3MassFabricatorAdjacencyBuffs", sizeTag = "SCFA_SIZE12" },
    ["uss3611"] = { sourceId = "XSB1301", sourceBlueprintSha256 = "d3e64b6276d7da2404226e898e335bf91221602f27d46d7e2c78afdf8c6e6090", tableName = "T3PowerGeneratorAdjacencyBuffs", sizeTag = "SCFA_SIZE16" },
  },
  tables = {
    ["T1PowerGeneratorAdjacencyBuffs"] = {
      { name = "T1PowerEnergyBuildBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.0625 },
      { name = "T1PowerEnergyBuildBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.03125 },
      { name = "T1PowerEnergyBuildBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.020833 },
      { name = "T1PowerEnergyBuildBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.015625 },
      { name = "T1PowerEnergyBuildBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.0125 },
      { name = "T1PowerEnergyWeaponBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.025 },
      { name = "T1PowerEnergyWeaponBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.0125 },
      { name = "T1PowerEnergyWeaponBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.008333 },
      { name = "T1PowerEnergyWeaponBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.00625 },
      { name = "T1PowerEnergyWeaponBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.005 },
      { name = "T1PowerEnergyMaintenanceBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.0625 },
      { name = "T1PowerEnergyMaintenanceBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.03125 },
      { name = "T1PowerEnergyMaintenanceBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.020833 },
      { name = "T1PowerEnergyMaintenanceBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.015625 },
      { name = "T1PowerEnergyMaintenanceBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.0125 },
      { name = "T1PowerRateOfFireBonusSize4", targetCategory = "STRUCTURE SIZE4 ARTILLERY", buffType = "RATEOFFIREADJACENCY", checkFunction = "RateOfFireBuffCheck", affect = "RateOfFire", add = -0.025 },
    },
    ["HydrocarbonAdjacencyBuffs"] = {
      { name = "T2PowerEnergyBuildBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.125 },
      { name = "T2PowerEnergyBuildBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.125 },
      { name = "T2PowerEnergyBuildBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.125 },
      { name = "T2PowerEnergyBuildBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.125 },
      { name = "T2PowerEnergyBuildBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.0125 },
      { name = "T2PowerEnergyWeaponBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.05 },
      { name = "T2PowerEnergyWeaponBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.05 },
      { name = "T2PowerEnergyWeaponBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.05 },
      { name = "T2PowerEnergyWeaponBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.05 },
      { name = "T2PowerEnergyWeaponBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.05 },
      { name = "T2PowerEnergyMaintenanceBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.125 },
      { name = "T2PowerEnergyMaintenanceBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.125 },
      { name = "T2PowerEnergyMaintenanceBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.125 },
      { name = "T2PowerEnergyMaintenanceBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.125 },
      { name = "T2PowerEnergyMaintenanceBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.125 },
      { name = "T2PowerRateOfFireBonusSize4", targetCategory = "STRUCTURE SIZE4 ARTILLERY", buffType = "RATEOFFIREADJACENCY", checkFunction = "RateOfFireBuffCheck", affect = "RateOfFire", add = -0.05 },
    },
    ["T2PowerGeneratorAdjacencyBuffs"] = {
      { name = "T2PowerEnergyBuildBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.125 },
      { name = "T2PowerEnergyBuildBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.125 },
      { name = "T2PowerEnergyBuildBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.125 },
      { name = "T2PowerEnergyBuildBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.125 },
      { name = "T2PowerEnergyBuildBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.0125 },
      { name = "T2PowerEnergyWeaponBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.05 },
      { name = "T2PowerEnergyWeaponBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.05 },
      { name = "T2PowerEnergyWeaponBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.05 },
      { name = "T2PowerEnergyWeaponBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.05 },
      { name = "T2PowerEnergyWeaponBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.05 },
      { name = "T2PowerEnergyMaintenanceBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.125 },
      { name = "T2PowerEnergyMaintenanceBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.125 },
      { name = "T2PowerEnergyMaintenanceBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.125 },
      { name = "T2PowerEnergyMaintenanceBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.125 },
      { name = "T2PowerEnergyMaintenanceBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.125 },
      { name = "T2PowerRateOfFireBonusSize4", targetCategory = "STRUCTURE SIZE4 ARTILLERY", buffType = "RATEOFFIREADJACENCY", checkFunction = "RateOfFireBuffCheck", affect = "RateOfFire", add = -0.05 },
    },
    ["T3PowerGeneratorAdjacencyBuffs"] = {
      { name = "T3PowerEnergyBuildBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.1875 },
      { name = "T3PowerEnergyBuildBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.1875 },
      { name = "T3PowerEnergyBuildBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.1875 },
      { name = "T3PowerEnergyBuildBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.1875 },
      { name = "T3PowerEnergyBuildBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "ENERGYBUILDBONUS", checkFunction = "EnergyBuildBuffCheck", affect = "EnergyActive", add = -0.1875 },
      { name = "T3PowerEnergyWeaponBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.075 },
      { name = "T3PowerEnergyWeaponBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.075 },
      { name = "T3PowerEnergyWeaponBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.075 },
      { name = "T3PowerEnergyWeaponBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.075 },
      { name = "T3PowerEnergyWeaponBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "ENERGYWEAPONBONUS", checkFunction = "EnergyWeaponBuffCheck", affect = "EnergyWeapon", add = -0.075 },
      { name = "T3PowerEnergyMaintenanceBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.1875 },
      { name = "T3PowerEnergyMaintenanceBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.1875 },
      { name = "T3PowerEnergyMaintenanceBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.1875 },
      { name = "T3PowerEnergyMaintenanceBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.1875 },
      { name = "T3PowerEnergyMaintenanceBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "ENERGYMAINTENANCEBONUS", checkFunction = "EnergyMaintenanceBuffCheck", affect = "EnergyMaintenance", add = -0.1875 },
      { name = "T3PowerRateOfFireBonusSize4", targetCategory = "STRUCTURE SIZE4 ARTILLERY", buffType = "RATEOFFIREADJACENCY", checkFunction = "RateOfFireBuffCheck", affect = "RateOfFire", add = -0.075 },
    },
    ["T1MassExtractorAdjacencyBuffs"] = {
      { name = "T1MEXMassBuildBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.1 },
      { name = "T1MEXMassBuildBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.05 },
      { name = "T1MEXMassBuildBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.033333 },
      { name = "T1MEXMassBuildBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.025 },
      { name = "T1MEXMassBuildBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.02 },
    },
    ["T2MassExtractorAdjacencyBuffs"] = {
      { name = "T2MEXMassBuildBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.15 },
      { name = "T2MEXMassBuildBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.075 },
      { name = "T2MEXMassBuildBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.05 },
      { name = "T2MEXMassBuildBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.0375 },
      { name = "T2MEXMassBuildBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.03 },
    },
    ["T3MassExtractorAdjacencyBuffs"] = {
      { name = "T3MEXMassBuildBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.2 },
      { name = "T3MEXMassBuildBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.1 },
      { name = "T3MEXMassBuildBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.066667 },
      { name = "T3MEXMassBuildBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.05 },
      { name = "T3MEXMassBuildBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.04 },
    },
    ["T1MassFabricatorAdjacencyBuffs"] = {
      { name = "T1FabricatorMassBuildBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.025 },
      { name = "T1FabricatorMassBuildBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.0125 },
      { name = "T1FabricatorMassBuildBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.008333 },
      { name = "T1FabricatorMassBuildBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.00625 },
      { name = "T1FabricatorMassBuildBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.005 },
    },
    ["T3MassFabricatorAdjacencyBuffs"] = {
      { name = "T3FabricatorMassBuildBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.075 },
      { name = "T3FabricatorMassBuildBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.075 },
      { name = "T3FabricatorMassBuildBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.075 },
      { name = "T3FabricatorMassBuildBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.075 },
      { name = "T3FabricatorMassBuildBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "MASSBUILDBONUS", checkFunction = "MassBuildBuffCheck", affect = "MassActive", add = -0.075 },
    },
    ["T1EnergyStorageAdjacencyBuffs"] = {
      { name = "T1EnergyStorageEnergyProductionBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "MASSBUILDBONUS", checkFunction = "EnergyProductionBuffCheck", affect = "EnergyProduction", add = 0.125 },
      { name = "T1EnergyStorageEnergyProductionBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "MASSBUILDBONUS", checkFunction = "EnergyProductionBuffCheck", affect = "EnergyProduction", add = 0.0625 },
      { name = "T1EnergyStorageEnergyProductionBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "MASSBUILDBONUS", checkFunction = "EnergyProductionBuffCheck", affect = "EnergyProduction", add = 0.041667 },
      { name = "T1EnergyStorageEnergyProductionBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "MASSBUILDBONUS", checkFunction = "EnergyProductionBuffCheck", affect = "EnergyProduction", add = 0.03125 },
      { name = "T1EnergyStorageEnergyProductionBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "MASSBUILDBONUS", checkFunction = "EnergyProductionBuffCheck", affect = "EnergyProduction", add = 0.025 },
    },
    ["T1MassStorageAdjacencyBuffs"] = {
      { name = "T1MassStorageMassProductionBonusSize4", targetCategory = "STRUCTURE SIZE4", buffType = "MASSBUILDBONUS", checkFunction = "MassProductionBuffCheck", affect = "MassProduction", add = 0.125 },
      { name = "T1MassStorageMassProductionBonusSize8", targetCategory = "STRUCTURE SIZE8", buffType = "MASSBUILDBONUS", checkFunction = "MassProductionBuffCheck", affect = "MassProduction", add = 0.0625 },
      { name = "T1MassStorageMassProductionBonusSize12", targetCategory = "STRUCTURE SIZE12", buffType = "MASSBUILDBONUS", checkFunction = "MassProductionBuffCheck", affect = "MassProduction", add = 0.041667 },
      { name = "T1MassStorageMassProductionBonusSize16", targetCategory = "STRUCTURE SIZE16", buffType = "MASSBUILDBONUS", checkFunction = "MassProductionBuffCheck", affect = "MassProduction", add = 0.03125 },
      { name = "T1MassStorageMassProductionBonusSize20", targetCategory = "STRUCTURE SIZE20", buffType = "MASSBUILDBONUS", checkFunction = "MassProductionBuffCheck", affect = "MassProduction", add = 0.025 },
    },
  },
}
end)()
local SCO_FA_Recipients = (function()
-- Source-BP recipient facts for sized SCOM loose and embedded templates.
-- Runtime maintenance overrides and WeaponUsesEnergy() remain dynamic checks.
-- sourceWeaponCount and sourceEnergyWeaponFieldsPositive are BP facts, not runtime method results.
return {
  ["ucs1001"] = { sourceId = "UAB2101", sourceBlueprintSha256 = "aefde7f0fdc1f1a9054034603351377ef77ebcefa125f02a8286f561126b220d", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs1201"] = { sourceId = "UAB2104", sourceBlueprintSha256 = "692e8e43f7de6c75379bd7c6955ad3711157ff0f2a0574d3958e957fedf05311", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs1301"] = { sourceId = "UAB2109", sourceBlueprintSha256 = "49f595281ffbb407e2274945ef9768c95798d9ef6a69c6c6efae4b257cfbc05a", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs1511"] = { sourceId = "UAB0101", sourceBlueprintSha256 = "fc7b959e42555e8c9f70a33c837519b91bb234fb3963d88ac9022496e2302fc7", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs1512"] = { sourceId = "UAB0102", sourceBlueprintSha256 = "9b5583fba065681bed436f0777ab1e6187c10dda2da0e99e20b934aaa7bd84d8", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs1513"] = { sourceId = "UAB0103", sourceBlueprintSha256 = "c4a4ecbc0b8e053b8bb4d46a90fa47e19c137038f297572ea53db6b3e9deedb6", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs1601"] = { sourceId = "UAB1103", sourceBlueprintSha256 = "a689422b2297f98499348c07ad287c27814ca9c136c92043e055e16f82e3989f", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs1602"] = { sourceId = "UAB1106", sourceBlueprintSha256 = "67fa5432484ba5a246f0ed1920b3de446472d3d424d06547bdae20977b38776d", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs1611"] = { sourceId = "UAB1101", sourceBlueprintSha256 = "ee45b4f2d63480574a0d370ae2372cd5d44b20e88869cac5003b2500d479094d", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs1612"] = { sourceId = "UAB1105", sourceBlueprintSha256 = "a956cc05ab2d449c1252d0d2e088f55347da95b85f91428c4dde955dbcd2bd7b", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs1614"] = { sourceId = "UAB1102", sourceBlueprintSha256 = "226e38c51f687f906d0d30ba449d032223b40eed65aaff7bb8c0607b021f25b6", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs1701"] = { sourceId = "UAB3101", sourceBlueprintSha256 = "2e13daff88938b7da55e308ee696a4abcc2be3d01cd5023ecd32b79a4ae14262", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs1702"] = { sourceId = "UAB3102", sourceBlueprintSha256 = "cb7096bdf0dbbfd477ae6ec7625a37f339e3a6fb2f36b2b283f9d78af5cecb09", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2001"] = { sourceId = "UAB2301", sourceBlueprintSha256 = "26f1431c63b23a3d3f414331db4c1824d171527e1f59c7f637ec100b4f197f49", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2101"] = { sourceId = "UAB2303", sourceBlueprintSha256 = "f056166ac1588ee419d833f890aefbf3db56798f05bfc914925c44a8dfc98bac", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = true },
  ["ucs2102"] = { sourceId = "UAB2108", sourceBlueprintSha256 = "f957f075831aa8e18a1d2a67f93335d0593d94463b7b0b55d3c2c894ef4edeec", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = true, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2201"] = { sourceId = "UAB2204", sourceBlueprintSha256 = "ed67446216872bcd5678c401c84b0087b238d02dc5301ada7515296edaaa9458", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2301"] = { sourceId = "UAB2205", sourceBlueprintSha256 = "00f2eb18ab01337858a23dcf097b34ae08e5952cb6c6e23827160ed34b40a6f4", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2401"] = { sourceId = "UAB4202", sourceBlueprintSha256 = "c39cfe68ae22bc35afc3b0ad385f2c10cc9cc6d2c13c5150dab76a74bea5219a", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2402"] = { sourceId = "UAB4201", sourceBlueprintSha256 = "96d6ae783a48f8c18d929e707a710e0d0a54fa9df16fed6d27c3f986d764533a", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2510"] = { sourceId = "UAB0304", sourceBlueprintSha256 = "3e0029f156b49dd168a2f0bd3b46086c3f1e3be1c4f7ec4c899fa9e49f7a71d7", sizeTag = "SCFA_SIZE20", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2511"] = { sourceId = "UAB0201", sourceBlueprintSha256 = "1ca3d3a1df107982c346943ead1522fd6ad4108a440617cf1f08fed2e8e0ff7f", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2512"] = { sourceId = "UAB0202", sourceBlueprintSha256 = "24f7d32122abf9346431a991316c66c99e3e93feccc6309411a425d5c645785e", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2513"] = { sourceId = "UAB0203", sourceBlueprintSha256 = "374293416b2af4a97e4cb208eefa6edbd7824eca5bd9763e112f1425b7fe6cb3", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2601"] = { sourceId = "UAB1202", sourceBlueprintSha256 = "79b006969a88b2e16acebe9cfd234890397b5fcd77a7e9c9f9e783efef0725d7", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2611"] = { sourceId = "UAB1201", sourceBlueprintSha256 = "780b0749722ac6c56861949cd03a8a40de76a3b0c1e026d07ea861460b99fc9f", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2701"] = { sourceId = "UAB3201", sourceBlueprintSha256 = "1e03af433f4bdd50b7de22a2f4c53053c8b3551eb85b542336f4d3ce74611ea3", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2702"] = { sourceId = "UAB3202", sourceBlueprintSha256 = "d2ec861ba7994346569793b39236cfc8c4447adf80f3cdfc2cb8770511c2baa5", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2711"] = { sourceId = "UAB4203", sourceBlueprintSha256 = "4e6fc2e1040b81a2683494f85bfbadab1205f664f3d4a337a095ea236017a9b8", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2801"] = { sourceId = "UAB5103", sourceBlueprintSha256 = "ba6bfa88f60e79b2bcc76dcb1b8ee6ad12558ef7cfaa13e10be20a27dbc072af", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs2806"] = { sourceId = "UAB1104", sourceBlueprintSha256 = "3c4eb4cef01985a92ce78af0b587346f9df08d3fc471cb52f22b307e3e47ff5f", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs3001"] = { sourceId = "XAB2307", sourceBlueprintSha256 = "ea23580adb52cdaf56103f7ef9e73afa2094cb7f6032f16585a02b0fc48fed22", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = true },
  ["ucs3101"] = { sourceId = "UAB2302", sourceBlueprintSha256 = "8c8e58b4ea9a3b74aded12e3db0276383fe8b4db6adc2d92c703dd6bf8074999", sizeTag = "SCFA_SIZE16", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = true },
  ["ucs3102"] = { sourceId = "UAB2305", sourceBlueprintSha256 = "038993929f7375646f6173a401adc214417afc7766d97ce62dc4c50870bb59f2", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = true, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 2, sourceEnergyWeaponFieldsPositive = false },
  ["ucs3201"] = { sourceId = "UAB2304", sourceBlueprintSha256 = "66bec16f278856954b999095ca49e2a1eb5133b4efccb21756fdebd21218ccd7", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs3401"] = { sourceId = "UAB4301", sourceBlueprintSha256 = "10a69396b3f055763593e01f361fd6fd53b804707e92fc745607aa02e0122f0a", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs3402"] = { sourceId = "UAB4302", sourceBlueprintSha256 = "d72db5e3fc2233509f6de9b3cc3351b8c4e053351fd4c14b5be4aa9cea23ed5a", sizeTag = "SCFA_SIZE8", buildableCategory = false, siloStructure = true, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs3501"] = { sourceId = "UAB5202", sourceBlueprintSha256 = "9d5e85fde40b8fe631a3feb849f6aeb623629b7d8d068e7d6335aa80a5acba12", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs3511"] = { sourceId = "UAB0301", sourceBlueprintSha256 = "bc1c32309fd20def2b2e24bd71edf1532c07b28992ac228fc8e8995df57e63f9", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs3512"] = { sourceId = "UAB0302", sourceBlueprintSha256 = "d475f08ab1fc0434b548f6f2959c808750615bfb2dc9f7dc1dd25bf8f336abfd", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs3513"] = { sourceId = "UAB0303", sourceBlueprintSha256 = "7ab2f1b00839e1f449406dfd87ec8b1884a393ba857d1a2f59c258d02694c2c0", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs3601"] = { sourceId = "UAB1302", sourceBlueprintSha256 = "18a5d6b6e2a027d0d599dc47177e48883190de7fadc97e3da3eab25a0010ad83", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs3603"] = { sourceId = "UAB1303", sourceBlueprintSha256 = "dfc725ed7309bf0bb00f1bd07b83cd25d356413cc9783cee81be55463f237be1", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs3611"] = { sourceId = "UAB1301", sourceBlueprintSha256 = "96e85f646efd233848af22f3cd6c6bfc74afde1f5dd27e5d2975f1b0fd11dfcf", sizeTag = "SCFA_SIZE16", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ucs3701"] = { sourceId = "UAB3104", sourceBlueprintSha256 = "8516e303d6a5eebc125dff13ec3ab8d11f036d44c46c5b565f56ddd47daea626", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs3702"] = { sourceId = "XAB3301", sourceBlueprintSha256 = "f666e7fb908a73d315b27397b47550eed5ba36bac94326b99ca2509cfa0c1e9b", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ucs4102"] = { sourceId = "XAB1401", sourceBlueprintSha256 = "8002739b4c792f498d8dc4ed779f26bfdffe2c748e629163170158d0a66222b9", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues1001"] = { sourceId = "UEB2101", sourceBlueprintSha256 = "96819759123b21cac02aea99aaf5ceee1821801b3d0d6041d8811d1e4f8e01c5", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues1201"] = { sourceId = "UEB2104", sourceBlueprintSha256 = "05006a48235854f089ba007e1a2ef255d495155668a9c381dbc792349deb9d03", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues1511"] = { sourceId = "UEB0101", sourceBlueprintSha256 = "88ec9ff5ebf8cec522dd6c812bf776bc514ade33dc3859e2864caa8ddb4c64e1", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues1512"] = { sourceId = "UEB0102", sourceBlueprintSha256 = "af008440765ec6fe36c134c66892fffa7d1b3a969d03ee48d7e16ad7ab5450b1", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues1513"] = { sourceId = "UEB0103", sourceBlueprintSha256 = "535033cd33ed70440625920e37e3112e4ca33ac1476f5f32ca42e441230808ca", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues1601"] = { sourceId = "UEB1103", sourceBlueprintSha256 = "86c7f83bd2c803cd1640e9a88785bf847aff377287ceabedbe7d7735083e55bf", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues1602"] = { sourceId = "UEB1106", sourceBlueprintSha256 = "3c728933dfe3567a969b4ee8a6663fac7e600dca163873e4eba6374fa0d549a7", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues1611"] = { sourceId = "UEB1101", sourceBlueprintSha256 = "0382700aa10d13a2ef2e02e5fd95e42baf51962f51268c61c929324860ca23ec", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues1612"] = { sourceId = "UEB1105", sourceBlueprintSha256 = "c034747eef467a9ce0895dcc670384b6ef404b2427e3fffa7ad0c3a6d4200384", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues1701"] = { sourceId = "UEB3101", sourceBlueprintSha256 = "ee05e5e121a66c6e9f1fd13aa971044c6d9f5b553af6867683a02772ce96a5b3", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues2001"] = { sourceId = "UEB2301", sourceBlueprintSha256 = "97f831fed87fef94266593852b044fd26b7b09e2066b494b0c6bb15aa93d67b9", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues2101"] = { sourceId = "UEB2303", sourceBlueprintSha256 = "71c7238490b499fab6e2b978eea2192caa7b91659b929c163fe28602df55e90f", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = true },
  ["ues2102"] = { sourceId = "UEB2108", sourceBlueprintSha256 = "b4319b01cc8e3800dfcef613423a42f9732405b0146d4a8b8006c18b63c84b84", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = true, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues2201"] = { sourceId = "UEB2204", sourceBlueprintSha256 = "8e459e3d4f2528c88597b13df611cb6999ddd113e97d83237cd1049ab0788099", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues2401"] = { sourceId = "UEB4202", sourceBlueprintSha256 = "7b9219f640e6034389a5945c71d4d5b90d29f134a51e3a102d93b79003f6df56", sizeTag = "SCFA_SIZE12", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues2402"] = { sourceId = "UEB4201", sourceBlueprintSha256 = "c2b5b3e831873ddf4b8523a258c2d8cec40e837fa0f826972e00904e6cde8074", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues2511"] = { sourceId = "UEB0201", sourceBlueprintSha256 = "e80b2971a1073e6b501122bf2163c9b51c95d05f299bb6289358f94c3165cb7a", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues2512"] = { sourceId = "UEB0202", sourceBlueprintSha256 = "a548f94be1a5e5ef2022eb13d002aa3ead9a08be7d5124c93032416382490121", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues2513"] = { sourceId = "UEB0203", sourceBlueprintSha256 = "e62138506d22d27bc66ee009d1d8b10537183cf81fcc1971e38d3169d8af8470", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues2601"] = { sourceId = "UEB1202", sourceBlueprintSha256 = "a9cd0868668e03102cfa642387727daacb22fc6b1816c857ad1d95cd3efe02a2", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues2611"] = { sourceId = "UEB1201", sourceBlueprintSha256 = "49ea20d181b052fabd2563a799c87dadb89a71025233210ef59a944e34c95e17", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues2701"] = { sourceId = "UEB3201", sourceBlueprintSha256 = "be211ff99f795a86a2d21974e8c12e5f5358fd07aa4eeec000b6f56a9b14ed7f", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues3102"] = { sourceId = "UEB2305", sourceBlueprintSha256 = "1280c70907e8018dd57bc6566417163d9323f9174b2e787d9a7e2bbeaa309c20", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = true, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 2, sourceEnergyWeaponFieldsPositive = false },
  ["ues3201"] = { sourceId = "UEB2304", sourceBlueprintSha256 = "6a0bfa968a2df65ad01e877ef63235e93a3e8ed66b9a2fe2a53d9bb97c7dc878", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues3401"] = { sourceId = "UEB4301", sourceBlueprintSha256 = "8e86fefc485a76ad1aa1e55894d0dbb3823cec2f58b175dccfbc6d67c6b67e78", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues3511"] = { sourceId = "UEB0301", sourceBlueprintSha256 = "186d46f32f5fa1cd612ca22458a52d15f106f2d301971f49e78687ded747d55d", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues3512"] = { sourceId = "UEB0302", sourceBlueprintSha256 = "213ba2a3d9aac7127d7f4aeb8345eef367dfd298e3d078954a20a71fa666d2d7", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues3513"] = { sourceId = "UEB0303", sourceBlueprintSha256 = "2db53b3f328e08e5bd4308eb080e456c22e5242fef6dcf551c1ec29fb5f318b3", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues3601"] = { sourceId = "UEB1302", sourceBlueprintSha256 = "4f488f277b85b44ea8d422228e936d2933e8e667b690e633e89a13e6560558ef", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues3603"] = { sourceId = "UEB1303", sourceBlueprintSha256 = "fbb11aa62f87e520fea91e63f7f7f9bedb83fb1f2f59f7e78bd031522496ba4b", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues3611"] = { sourceId = "UEB1301", sourceBlueprintSha256 = "71e92d602bed2a04916c020662df4f1ac74030cd7de70eff0f962aa760cd57af", sizeTag = "SCFA_SIZE16", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues3701"] = { sourceId = "UEB3104", sourceBlueprintSha256 = "0850c6139f625e2bbe6ff575a0950f786c1526cfb2a59e2aaf5661c3b0e8e495", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues4101"] = { sourceId = "UEB2401", sourceBlueprintSha256 = "4e0242d1113c20d75f77426b35b40713b580f08500683ac92e8d17c22e794c6a", sizeTag = "SCFA_SIZE16", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = true },
  ["ugs1001"] = { sourceId = "URB2101", sourceBlueprintSha256 = "65793eefd69516a503a00c9dc6fd6ec53cbf3f6b41c1aeef042fafddcc29acee", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs1201"] = { sourceId = "URB2104", sourceBlueprintSha256 = "4e4cb9ea8dbc35a9a8967db16ab88111a545aa306ab764a875d3f7c0e9b35a1e", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs1511"] = { sourceId = "URB0101", sourceBlueprintSha256 = "18c4364985447ec26d436a9ce2a4e9b1265c32b02522883a1be93a016e8278f6", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs1512"] = { sourceId = "URB0102", sourceBlueprintSha256 = "a88242605a599b30590b8aaa6e190adf85683f9ae1ca6ccdd72796d9d36b68b8", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs1513"] = { sourceId = "URB0103", sourceBlueprintSha256 = "55ed3f51c07950c13f3f3ee87d3265ae9ca877666155ef0fc46ec9613845c0bc", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs1601"] = { sourceId = "URB1103", sourceBlueprintSha256 = "e723b2d7f3b916bd24f46587a9ef7c3691b60265830553bb234505cd162db1ef", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs1602"] = { sourceId = "URB1106", sourceBlueprintSha256 = "323ac892e188940daad815df6ee42ffe2f75585376591ede1965706ca51055f7", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs1611"] = { sourceId = "URB1101", sourceBlueprintSha256 = "734334190aa6eef78ac93913147b0849c9add39f9850e983cc79641a5bb601ba", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs1612"] = { sourceId = "URB1105", sourceBlueprintSha256 = "5f7f46eea3ee0e1ddd37db354fb54ff30fe197aa5b2c45e04ab21706f0427e59", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs1701"] = { sourceId = "URB3101", sourceBlueprintSha256 = "9ad39baea926509e420f233c500da4d9180404fd93ee5035aa435d6cbc4627ce", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs2001"] = { sourceId = "URB2301", sourceBlueprintSha256 = "6f61e9f0f4d02f1dcf9ca03ecd2206dd15aa1476709d470f448c4af3e6e69c0f", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs2101"] = { sourceId = "URB2303", sourceBlueprintSha256 = "f0f11960837abf5a856d885fcf5500a2e4cd47546752a8865f7bf22e4998cf0a", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = true },
  ["ugs2102"] = { sourceId = "URB2108", sourceBlueprintSha256 = "81fdb94e97fab4e849715671716c7c29360d945a8d4fce0a5fe44a478fd603af", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = true, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs2201"] = { sourceId = "URB2204", sourceBlueprintSha256 = "6794c891d2df57fb0f930c046bcbf88a229b29f057277eb1b0bb0504e4688499", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs2401"] = { sourceId = "URB4202", sourceBlueprintSha256 = "4053e6d1379b4bfa280932e1790346a4a722e8368dcf3be77325b5fa08bd12c4", sizeTag = "SCFA_SIZE12", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs2402"] = { sourceId = "URB4201", sourceBlueprintSha256 = "26cb4384af189c0172fe943bbd818b8252bc8a9eafc307608de9b2df49c7fd7a", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs2511"] = { sourceId = "URB0201", sourceBlueprintSha256 = "6effb19230c858876edfe84e5c263f67c10a75bb2c1f85a4d89678094963d281", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs2512"] = { sourceId = "URB0202", sourceBlueprintSha256 = "9f67bda320e5993f0987b1fb11b6c24e2871fc1c925177fb66971b6e6a17afef", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs2513"] = { sourceId = "URB0203", sourceBlueprintSha256 = "c4b8addd484ff90a4f5ff241621d4b12fcd05960df3fb5cc1b1b22b3f5f996e2", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs2601"] = { sourceId = "URB1202", sourceBlueprintSha256 = "b89469f2fa005d292b134e78aa46bf36d3ba3693085bf4b2a991d84635924a9c", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs2611"] = { sourceId = "URB1201", sourceBlueprintSha256 = "19cef2bfff64f1dd4f859db54272fbfd5753912baadefc8db898f6b31fc4c0cb", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs2701"] = { sourceId = "URB3201", sourceBlueprintSha256 = "3863c2abaae011903c08ba6921bec62e995c043fee8591d81591a807d5ba4b32", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs3101"] = { sourceId = "URB2302", sourceBlueprintSha256 = "0e77af840ac48c72e611750863ab7e282fed6b93d91da95e5f713768275f583c", sizeTag = "SCFA_SIZE16", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = true },
  ["ugs3201"] = { sourceId = "URB2304", sourceBlueprintSha256 = "1d9170532ed36fa790a5cd50931ad1888e50b039091ec5590d4aa74c2ff23b64", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs3401"] = { sourceId = "URB4207", sourceBlueprintSha256 = "7442a10729ab814418f0201aed463b1acda55a8dc135ead974b399d709e210e3", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs3511"] = { sourceId = "URB0301", sourceBlueprintSha256 = "5a0328ac3ca0569840812809d830b90fabbf97faca94bf583a1401c214af2e77", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs3512"] = { sourceId = "URB0302", sourceBlueprintSha256 = "e9aa49c6eed7fafde2fb543cb853e2ed8b53c10924481539d224d925c4bacae3", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs3513"] = { sourceId = "URB0303", sourceBlueprintSha256 = "9e28422355a170fe5a654e65fd27f22833147bd94f6638b13540850ffbe1f498", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs3601"] = { sourceId = "URB1302", sourceBlueprintSha256 = "8e6c44d30877de9829061ac604f160ed81797698d6bed13c3580dc98ea5baf8c", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs3603"] = { sourceId = "URB1303", sourceBlueprintSha256 = "bf7930986d1b416fc4db68e070f4b1249d2edce04c82415c03791f62ab79ae75", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs3611"] = { sourceId = "URB1301", sourceBlueprintSha256 = "e1d59ee7ded7cae10c69bfde8fe4a76927de45449b35dd951de2ae3be9947439", sizeTag = "SCFA_SIZE16", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs3701"] = { sourceId = "URB3104", sourceBlueprintSha256 = "d72ec56d15d1a0ff351a580ce5afabd127f16817d6e4a0134316d5193c3735fa", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss1001"] = { sourceId = "XSB2101", sourceBlueprintSha256 = "310b63fa6edc7843e7869de03ff3b531be27d61bdedf688aa442716e67658b0e", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss1201"] = { sourceId = "XSB2104", sourceBlueprintSha256 = "5881deb42eb5e45ea6b3c8a9c4854995b9a0a9c8c7c3fe6664bbe92119e79dda", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss1301"] = { sourceId = "XSB2109", sourceBlueprintSha256 = "eabbed08a1e2d71fffe3092d72e70ccbfcc57d416712104e41bf7ee089ed5cb9", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss1511"] = { sourceId = "XSB0101", sourceBlueprintSha256 = "735a0bfe28c059234f91adae703ae24d85d8a40a1bf981936ed7cee5c281a795", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss1512"] = { sourceId = "XSB0102", sourceBlueprintSha256 = "fe82df70dd790164f79960c9f510915dbfa0645f1b5d34ebdb2cbe129eaa38e2", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss1513"] = { sourceId = "XSB0103", sourceBlueprintSha256 = "b776a3da70b4081ee803cf450cccbcc32f35213ae63ba48e8ee1e37a634437c4", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss1601"] = { sourceId = "XSB1103", sourceBlueprintSha256 = "159d28c3cba3926678b7a63172fc1e6bcc0119da4252b873033a0b4c3270f0c4", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss1602"] = { sourceId = "XSB1106", sourceBlueprintSha256 = "bf41d3107fb3a1cd6bcee688306fe496e7a07a87cac8e2a729f64108f5fc4336", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss1611"] = { sourceId = "XSB1101", sourceBlueprintSha256 = "ba1ca690e52e57843cb4304a14e4e4bc361fbfb2018b6882d2b6d31da922027d", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss1612"] = { sourceId = "XSB1105", sourceBlueprintSha256 = "c6aa766013df3f1d51c81d16a0d4662a317cd068cc026d73c9e9316762be3070", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss1614"] = { sourceId = "XSB1102", sourceBlueprintSha256 = "3c83b8f1ac1224e0d65768164ff3e9b791e22ca81fa4a3d17a214a2130692473", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss1701"] = { sourceId = "XSB3101", sourceBlueprintSha256 = "29d3e25b538741a8c788574aa34f6f7701ed97bcc11c30ccfe825bf0b15f4d23", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss1702"] = { sourceId = "XSB3102", sourceBlueprintSha256 = "3b40e498a782429177172e5c9a8a56df8a0bc15bf2d0b0326823f7b42411dc0d", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss2001"] = { sourceId = "XSB2301", sourceBlueprintSha256 = "db0cecfa0f6db894e6fc0e72f5dcb8f105f459c605cc78e14b33caf8558776ab", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss2101"] = { sourceId = "XSB2303", sourceBlueprintSha256 = "e7476de490faacbd791b77524ef57de8b2d7c5aea761a4ffd35a4fa0094bc4f2", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = true },
  ["uss2102"] = { sourceId = "XSB2108", sourceBlueprintSha256 = "72d14324ce4c295fee7315e60272379a2d1c198cf6f88162eb222da660489f62", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = true, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss2201"] = { sourceId = "XSB2204", sourceBlueprintSha256 = "2f74bc09ac1dea5a42c9635d606687f4fd108fb85699868ad2590a9fd46a333d", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss2301"] = { sourceId = "XSB2205", sourceBlueprintSha256 = "6c3f623b8b3fed51f89d0e0823d6d84666e8c491fe90f914de11860d06b3f19e", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 2, sourceEnergyWeaponFieldsPositive = false },
  ["uss2401"] = { sourceId = "XSB4202", sourceBlueprintSha256 = "6492d7d79b574c9ad293ce94d4ee4db5fac83dcd35fae0e6dc45fd3061adfdd3", sizeTag = "SCFA_SIZE12", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss2402"] = { sourceId = "XSB4201", sourceBlueprintSha256 = "37f9d0f0ed0c2314306d99cdb71f4fe783ac0b94e7a3c8e55e337dcdead1b426", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss2510"] = { sourceId = "XSB0304", sourceBlueprintSha256 = "8e1f1c4d6c331c5f10e9ae27b48e3417d10c83c57d1990743d7e70a915d63660", sizeTag = "SCFA_SIZE20", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss2511"] = { sourceId = "XSB0201", sourceBlueprintSha256 = "39bd6e8e9102c031a2236e5fb14fbdc6b3c9254d45e8b9ad7ca34b1ee79ef0cf", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss2512"] = { sourceId = "XSB0202", sourceBlueprintSha256 = "ad9a1749d2df5935f3a84198af00059186006364dfdc7b9a2c4fc25b28057fd3", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss2513"] = { sourceId = "XSB0203", sourceBlueprintSha256 = "ed337d5007aa5743c4bc7a84217ef2323191297993d36f042c628dcfe33b5e2d", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss2601"] = { sourceId = "XSB1202", sourceBlueprintSha256 = "91ad0dfaddeda2ff4ce374093402c9f49c7a3cd6942ad8336e32f24bdbb72787", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss2611"] = { sourceId = "XSB1201", sourceBlueprintSha256 = "98233f21427098d2c34a7ef8334068200bf4da361a46a26feaf391384bd162ea", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss2701"] = { sourceId = "XSB3201", sourceBlueprintSha256 = "4a82eb63565acaf18558472ab3d970bdd2333d182f35f670d823923f6351a303", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss2702"] = { sourceId = "XSB3202", sourceBlueprintSha256 = "b76f16b2666035aed816b1fb07063cd99f8b3ba99eb160c11719d7964cfa3847", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss2711"] = { sourceId = "XSB4203", sourceBlueprintSha256 = "5316db526ce2e17a484c94612cc5e4adf654a73feff53a674d403be4d728b2ae", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss2806"] = { sourceId = "XSB1104", sourceBlueprintSha256 = "06804bda7421af1fbb486f8da89c561c423e2951631d93dbf4e3915b64929514", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss3101"] = { sourceId = "XSB2302", sourceBlueprintSha256 = "295debc2df24890246d7f94099db510562f572ccd05656b11ff8d56e3e6b4ce7", sizeTag = "SCFA_SIZE16", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = true },
  ["uss3102"] = { sourceId = "XSB2305", sourceBlueprintSha256 = "e3ded95d2d2b1b56235c70f3b2d6bae9e3cfb220bd02156a780f3f90c79b6017", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = true, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 2, sourceEnergyWeaponFieldsPositive = false },
  ["uss3201"] = { sourceId = "XSB2304", sourceBlueprintSha256 = "6b463a438facbd3b5fb394b92dd0562c13c93de36d9865d268fb8f05404aca07", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss3401"] = { sourceId = "XSB4301", sourceBlueprintSha256 = "7e994296bf46c5b1aef33acafeedff4c6a1219f1f80cc75f75973e4695095fdb", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss3402"] = { sourceId = "XSB4302", sourceBlueprintSha256 = "9e5ca1afd92f3725100af4b92a41bd145a945a9e35eb3daf1c3297436cdc43cc", sizeTag = "SCFA_SIZE8", buildableCategory = false, siloStructure = true, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss3501"] = { sourceId = "XSB5202", sourceBlueprintSha256 = "efbe8bc5f43be23ef1e0faeffed82386e0c02b58ead145314bc70de972d65ac9", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss3511"] = { sourceId = "XSB0301", sourceBlueprintSha256 = "9cd8ab27e4c539de6c1ca10c4171bb5121c59255c970b21c89e4d1ffd3095040", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss3512"] = { sourceId = "XSB0302", sourceBlueprintSha256 = "9028bb8f84820286493c258402f1d7b67ff87c3f352e69276c74f3dfc4541fdc", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss3513"] = { sourceId = "XSB0303", sourceBlueprintSha256 = "fd751204a99ef011c9f3a8f5488b7e87c31808da03923ee4b32e4906dd6d39bd", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss3601"] = { sourceId = "XSB1302", sourceBlueprintSha256 = "6d4c49eac21e412bb284a515850a52f60a69c1c1cefc35a1bbf0cc83c72fd3c8", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss3603"] = { sourceId = "XSB1303", sourceBlueprintSha256 = "009adb261deefbb544dba5abb8785da2bcf1c1e84ec6abcc12a314228755bf75", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss3611"] = { sourceId = "XSB1301", sourceBlueprintSha256 = "d3e64b6276d7da2404226e898e335bf91221602f27d46d7e2c78afdf8c6e6090", sizeTag = "SCFA_SIZE16", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["uss3701"] = { sourceId = "XSB3104", sourceBlueprintSha256 = "911ef4e4b79be8c03e70d49ab47b887e0284be2d4bde6304e42acaf540be166f", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["uss4102"] = { sourceId = "XSB2401", sourceBlueprintSha256 = "6057d01fa27374c0d56b38bbd5ab152d5a37f704ee4c4205f99dec4b0b4d5b36", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = true, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["wab1302"] = { sourceId = "XSB1303", sourceBlueprintSha256 = "009adb261deefbb544dba5abb8785da2bcf1c1e84ec6abcc12a314228755bf75", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["wab2303"] = { sourceId = "XSB4302", sourceBlueprintSha256 = "9e5ca1afd92f3725100af4b92a41bd145a945a9e35eb3daf1c3297436cdc43cc", sizeTag = "SCFA_SIZE8", buildableCategory = false, siloStructure = true, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["wrb0304"] = { sourceId = "URB0301", sourceBlueprintSha256 = "5a0328ac3ca0569840812809d830b90fabbf97faca94bf583a1401c214af2e77", sizeTag = "SCFA_SIZE16", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["wsb4205"] = { sourceId = "XSB4201", sourceBlueprintSha256 = "37f9d0f0ed0c2314306d99cdb71f4fe783ac0b94e7a3c8e55e337dcdead1b426", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues5014"] = { sourceId = "UEB0304", sourceBlueprintSha256 = "d312a74e9a6bb153922726e4995e28aa8cd43a031569661ce740e7847d1f25df", sizeTag = "SCFA_SIZE20", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues5015"] = { sourceId = "UEB1102", sourceBlueprintSha256 = "c881c49165ff33b9644eb62910fad3ed2075fdf732f1fc5dceb028b673f710fc", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues5016"] = { sourceId = "UEB1104", sourceBlueprintSha256 = "c4ae102f6ed87c4e5c04b2ae019b16b5cf53244dc95ab865e3fc0d12286bdd52", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues5017"] = { sourceId = "UEB2109", sourceBlueprintSha256 = "216a75e04cd219fb3c8e7e3ce8b29b4b8312b85c2666a5816d9255daab581ddd", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues5018"] = { sourceId = "UEB2205", sourceBlueprintSha256 = "144def7048066d54d63a44f853f7f2d5f33ea3c3134c7ff3b05b2918d63d1304", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues5019"] = { sourceId = "UEB2302", sourceBlueprintSha256 = "5a53f06668e0b28f1b260a922fc08ced19351acca338cc227ae3fb245c6e5300", sizeTag = "SCFA_SIZE16", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = true },
  ["ues5020"] = { sourceId = "UEB3102", sourceBlueprintSha256 = "17bcd5ab1edd7a57b1dc7923cfd8b0740a335e9f52008ab62fb1e78df7308a66", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues5021"] = { sourceId = "UEB3202", sourceBlueprintSha256 = "96d9618c3d88fe6582e3bfb814dd0a582bf19533a9861cac74b93ce37bfa2020", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues5022"] = { sourceId = "UEB4203", sourceBlueprintSha256 = "23fb4baadc09b09b7e2cf40bab743fe905be69a6ddb8c735bd95319d876c911a", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues5023"] = { sourceId = "UEB4302", sourceBlueprintSha256 = "83faa04034e547df7fe76433764fb34d29f0488f76a313dc4f27fc9f48cc3616", sizeTag = "SCFA_SIZE8", buildableCategory = false, siloStructure = true, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ues5025"] = { sourceId = "UEB5202", sourceBlueprintSha256 = "d78539fa14d7a0743fd45fc8c061827eaf82161762f3e8e06a428d7bb5847b90", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ues5042"] = { sourceId = "XEB2306", sourceBlueprintSha256 = "44010918c0950cf314a8fb013742976f0fe164f32ceeb4d0c7116d3c0b0869de", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = true },
  ["ugs5002"] = { sourceId = "URB0304", sourceBlueprintSha256 = "47eaa42c5914f06f5121d0638bf83d4fcbfe6f4b44d8f043180bfa89dd5aeded", sizeTag = "SCFA_SIZE20", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5003"] = { sourceId = "URB1102", sourceBlueprintSha256 = "5d744a449a2f1c66a8523324b5f37581b2bea656169fc6c260b7d096316bcd99", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = true, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5004"] = { sourceId = "URB1104", sourceBlueprintSha256 = "8adf72c514ddbeade7f7b08a150f3dd9a894ad1459a0ff30f5efbb1651431f50", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = true, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5005"] = { sourceId = "URB2109", sourceBlueprintSha256 = "4092cc413023e2beceba263de73acb6bd62de0d5fb691510631724780f98bb9a", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5006"] = { sourceId = "URB2205", sourceBlueprintSha256 = "61c8d8c06c39ab5e59da69170a15278d0171631dd0a7b73334c7d8d21a684d53", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5007"] = { sourceId = "URB2305", sourceBlueprintSha256 = "9ebee511eb5ae569c4bac6e1909f6753672f434e45ff234c6ad438f2ecf7ebe8", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = true, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 2, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5008"] = { sourceId = "URB3102", sourceBlueprintSha256 = "3467e9fecf5a278ba1987ec390f5cd270ce2d43fe2ec37babd91dca81ccd2827", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5009"] = { sourceId = "URB3103", sourceBlueprintSha256 = "2a708b559c898668156f4286878f87faac9d7ffe56be9e986e4e4c5d05ac0e02", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5010"] = { sourceId = "URB3202", sourceBlueprintSha256 = "e87775a04b66d376282913696ff67b8310b53fe17ff4233413b7ed51fe7f0c1a", sizeTag = "SCFA_SIZE4", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5011"] = { sourceId = "URB4203", sourceBlueprintSha256 = "3e5c88adee28a793f6c02989431eb6355af7d2229170204d92319e199af351d7", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5012"] = { sourceId = "URB4204", sourceBlueprintSha256 = "ffb34c53c36bf2ae438d1c041ba1ba9e1c089a327b93d173e9312def4006dfb9", sizeTag = "SCFA_SIZE12", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5013"] = { sourceId = "URB4205", sourceBlueprintSha256 = "1fca98ab7de7a06c63cd92ddec0ebe89f3fc2f61f21ded458cb9a2f5449cc172", sizeTag = "SCFA_SIZE12", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5014"] = { sourceId = "URB4206", sourceBlueprintSha256 = "ca7f4fa4691fc0a2ecab35f97b13f92d2d0811008f12e8595c4efdf4f51d8ece", sizeTag = "SCFA_SIZE12", buildableCategory = true, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5015"] = { sourceId = "URB4302", sourceBlueprintSha256 = "df076a703a00ee5ee5675134adf51f6148212472b714f090bea75e65128e0940", sizeTag = "SCFA_SIZE8", buildableCategory = false, siloStructure = true, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5017"] = { sourceId = "URB5202", sourceBlueprintSha256 = "adad2189c649922fa7ceb9a04176f1aa346b2594d6fa806edfa5485916a239d2", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5027"] = { sourceId = "XRB2308", sourceBlueprintSha256 = "f0abdd2162690dc3d0d959c71aeed5d34424e18fe5baf28f2a249d35fbaa66a3", sizeTag = "SCFA_SIZE4", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = false, energyProduction = false, massProduction = false, sourceWeaponCount = 1, sourceEnergyWeaponFieldsPositive = false },
  ["ugs5028"] = { sourceId = "XRB3301", sourceBlueprintSha256 = "84f4883c8f9584f26206dbeaf9d2b376294a453f07683b94e1fb26b51b6598a8", sizeTag = "SCFA_SIZE12", buildableCategory = false, siloStructure = false, hasEnergyMaintenance = true, energyProduction = false, massProduction = false, sourceWeaponCount = 0, sourceEnergyWeaponFieldsPositive = false },
}
end)()
local SCO_FA_Core = (function()
-- FA-source adjacency graph and host economy bridge.
-- The caller supplies the generated fa_adjacency_manifest.lua table.
local M = {}

local function unitKey(unit)
    return tostring(unit.id.index) .. ":" .. tostring(unit.id.version)
end

local function hasTag(unit, name)
    for _, value in ipairs(unit.tp.tags or {}) do
        if value == name then return true end
    end
    return false
end

local function bounds(unit)
    local skirt = unit.tp.skirtSize
    if not skirt then return nil end
    local pos = unit:GetPosition()
    local x = math.floor(pos.x - skirt.x / 2)
    local z = math.floor(pos.z - skirt.y / 2)
    return { x0 = x, x1 = x + skirt.x - 1, z0 = z, z1 = z + skirt.y - 1 }
end

local function edgeContact(a, b)
    local xOverlap = a.x0 <= b.x1 and b.x0 <= a.x1
    local zOverlap = a.z0 <= b.z1 and b.z0 <= a.z1
    return ((a.x1 + 1 == b.x0 or b.x1 + 1 == a.x0) and zOverlap)
        or ((a.z1 + 1 == b.z0 or b.z1 + 1 == a.z0) and xOverlap)
end

local function categoryMatches(unit, category, facts)
    local size = category:match("SIZE%d+")
    if not size or not hasTag(unit, "SCFA_STRUCTURE")
        or not hasTag(unit, "SCFA_" .. size)
        or not facts or facts.sizeTag ~= "SCFA_" .. size then return false end
    return not category:find("ARTILLERY", 1, true) or hasTag(unit, "SCFA_ARTILLERY")
end

local function check(unit, row, runtime)
    local facts = runtime.recipientFacts[unit.tpId]
    if not facts then return false end
    if row.checkFunction == "EnergyBuildBuffCheck"
        or row.checkFunction == "MassBuildBuffCheck" then
        return facts.buildableCategory or facts.siloStructure
    elseif row.checkFunction == "EnergyMaintenanceBuffCheck" then
        return facts.hasEnergyMaintenance or not not unit.EnergyMaintenanceConsumptionOverride
    elseif row.checkFunction == "EnergyProductionBuffCheck" then
        return facts.energyProduction
    elseif row.checkFunction == "MassProductionBuffCheck" then
        return facts.massProduction
    elseif row.checkFunction == "EnergyWeaponBuffCheck" then
        return runtime.weaponUsesEnergy and runtime.weaponUsesEnergy(unit) or false
    elseif row.checkFunction == "RateOfFireBuffCheck" then
        return unit.GetWeaponCount and unit:GetWeaponCount() > 0
            and unit.weapons and #unit.weapons > 0
    end
    error("Unknown FA adjacency check: " .. tostring(row.checkFunction))
end

local function eligible(unit)
    return unit and not unit.dead and unit:IsCompleted()
        and unit.tp.skirtSize and hasTag(unit, "SCFA_STRUCTURE")
end

local function resourceValuesPerSecond(values, tickRate)
    local result = {}
    for name, value in pairs(values) do result[name] = value * tickRate end
    return result
end

function M.New(runtime, manifest)
    assert(runtime and runtime.query and runtime.getUnit and runtime.tickRate
        and runtime.recipientFacts)
    assert(manifest and manifest.schema == "fa-retail-adjacency-to-scom-v1")
    local links, applied = {}, {}
    local self = {}

    local function entry(unit)
        local id = unitKey(unit)
        if not links[id] then links[id] = { unit = unit, peers = {} } end
        return links[id]
    end

    local function provider(unit)
        local source = manifest.providers[unit.tpId]
        if not source then return nil end
        if not hasTag(unit, source.sizeTag) then
            return nil
        end
        local sourceContract = unit.tp.additions and unit.tp.additions.faSourceContract
        if sourceContract and sourceContract.sourceId
            and sourceContract.sourceId:upper() ~= source.sourceId then
            return nil
        end
        if sourceContract and sourceContract.sourceBlueprintSha256
            and sourceContract.sourceBlueprintSha256:lower()
                ~= source.sourceBlueprintSha256 then
            return nil
        end
        if not sourceContract or not sourceContract.sourceBlueprintSha256 then
            local facts = runtime.recipientFacts[unit.tpId]
            if not facts or facts.sourceId ~= source.sourceId
                or facts.sourceBlueprintSha256
                    ~= source.sourceBlueprintSha256 then
                return nil
            end
        end
        return source
    end

    local function amounts(unit)
        local totals = {}
        local record = links[unitKey(unit)]
        if not record then return totals end
        local peerKeys = {}
        for id in pairs(record.peers) do peerKeys[#peerKeys + 1] = id end
        table.sort(peerKeys)
        for _, id in ipairs(peerKeys) do
            local source = record.peers[id]
            local sourceInfo = eligible(source) and provider(source)
            if sourceInfo then
                local sourceRows = manifest.tables[sourceInfo.tableName]
                assert(sourceRows, "Missing FA adjacency table: " .. sourceInfo.tableName)
                for _, row in ipairs(sourceRows) do
                    if categoryMatches(unit, row.targetCategory,
                        runtime.recipientFacts[unit.tpId]) and check(unit, row, runtime) then
                        totals[row.affect] = (totals[row.affect] or 0) + row.add
                    end
                end
            end
        end
        return totals
    end

    local function updateBuilder(unit, resource, old, new)
        if runtime.applyBuild then
            return runtime.applyBuild(unit, resource, old, new)
        end
        unit.adjacencyBonus = unit.adjacencyBonus or {}
        local previous = unit.adjacencyBonus[resource] or 1
        unit.adjacencyBonus[resource] = previous + new - old
        local target = unit.unitBeingBuilt
        if target and target.resourceEntities and target.resourceEntities.construction then
            target.resourceEntities.construction:UpdateBuilder(unit)
        end
    end

    local function updateResource(unit, category, resource, old, new)
        if unit.__scomFAProductionPaused then
            return true
        end
        if category == "EnergyMaintenance" and runtime.applyMaintenance then
            return runtime.applyMaintenance(unit, resource, old, new)
        end
        local eco = unit.tp.economy or {}
        local templateField = category == "EnergyMaintenance" and "maintenanceConsumption" or "production"
        local base = eco[templateField] and eco[templateField][resource]
        if not base then return false end
        local entities = unit.resourceEntities or {}
        local maintenance = category == "EnergyMaintenance"
        local entity = maintenance and (entities.consumption or entities.production)
            or (entities.generation or entities.production)
        if not entity then return false end
        local values = resourceValuesPerSecond(maintenance and entity.outcome or entity.income, runtime.tickRate)
        values[resource] = (values[resource] or 0) + base * (new - old)
        if maintenance then entity:SetResources(nil, values) else entity:SetResources(values, nil) end
        return true
    end

    local function apply(unit, prior, nextAmounts)
        local changed = false
        local names = {}
        for name in pairs(prior) do names[name] = true end
        for name in pairs(nextAmounts) do names[name] = true end
        for name in pairs(names) do
            local old, new = prior[name] or 0, nextAmounts[name] or 0
            if old ~= new then
                if name == "EnergyActive" then
                    updateBuilder(unit, "energy", old, new)
                elseif name == "MassActive" then
                    updateBuilder(unit, "alloys", old, new)
                elseif name == "EnergyMaintenance" then
                    if not updateResource(unit, name, "energy", old, new) then
                        nextAmounts[name] = old
                    end
                elseif name == "EnergyProduction" then
                    if not updateResource(unit, name, "energy", old, new) then
                        nextAmounts[name] = old
                    end
                elseif name == "MassProduction" then
                    if not updateResource(unit, name, "alloys", old, new) then
                        nextAmounts[name] = old
                    end
                elseif name == "EnergyWeapon" or name == "RateOfFire" then
                    -- HostWeapon consumers must read these exact per-unit modifiers.
                    unit.scomFAAdjacency = unit.scomFAAdjacency or {}
                    unit.scomFAAdjacency[name] = new
                    if runtime.updateWeapons then runtime.updateWeapons(unit, name, old, new) end
                else
                    error("Unknown FA adjacency affect: " .. tostring(name))
                end
                changed = true
            end
        end
        if changed then unit:UpdateUIValues() end
    end

    local function recalculate(unit)
        if not eligible(unit) then return end
        local id = unitKey(unit)
        local nextAmounts = amounts(unit)
        apply(unit, applied[id] or {}, nextAmounts)
        applied[id] = nextAmounts
    end

    local function unlink(a, b)
        local ae, be = links[unitKey(a)], links[unitKey(b)]
        if not ae or not ae.peers[unitKey(b)] then return end
        ae.peers[unitKey(b)] = nil
        be.peers[unitKey(a)] = nil
        recalculate(a)
        recalculate(b)
        if not next(ae.peers) then links[unitKey(a)], applied[unitKey(a)] = nil, nil end
        if not next(be.peers) then links[unitKey(b)], applied[unitKey(b)] = nil, nil end
    end

    local function link(a, b)
        local ae, be = entry(a), entry(b)
        if ae.peers[unitKey(b)] then return end
        ae.peers[unitKey(b)] = b
        be.peers[unitKey(a)] = a
        recalculate(a)
        recalculate(b)
    end

    function self:Refresh(unit)
        if not eligible(unit) then return end
        local area = bounds(unit)
        local ids = runtime.query({
            x0 = area.x0 - 1, x1 = area.x1 + 1,
            z0 = area.z0 - 1, z1 = area.z1 + 1,
        })
        local seen = {}
        for _, id in ipairs(ids) do
            local other = runtime.getUnit(id)
            if other and other ~= unit and other.army.id == unit.army.id
                and eligible(other) and edgeContact(area, bounds(other))
                and (provider(unit) or provider(other)) then
                seen[unitKey(other)] = true
                link(unit, other)
            end
        end
        local record = links[unitKey(unit)]
        if record then
            local removed = {}
            for id, other in pairs(record.peers) do
                if not seen[id] then removed[#removed + 1] = other end
            end
            for _, other in ipairs(removed) do unlink(unit, other) end
        end
        recalculate(unit)
    end

    function self:Forget(unit)
        local id = unitKey(unit)
        local record = links[id]
        if not record then return end
        local peers = {}
        for _, other in pairs(record.peers) do peers[#peers + 1] = other end
        for _, other in ipairs(peers) do unlink(unit, other) end
        links[id], applied[id] = nil, nil
    end

    function self:Disconnect(a, b)
        if a and b then unlink(a, b) end
    end

    function self:ReapplyExtractor(unit)
        if not eligible(unit) then return end
        local current = applied[unitKey(unit)] or {}
        for name, resource in pairs({
            EnergyProduction = "energy", MassProduction = "alloys",
            EnergyMaintenance = "energy",
        }) do
            local add = current[name]
            if add and add ~= 0 then
                updateResource(unit, name, resource, 0, add)
            end
        end
        unit:UpdateUIValues()
    end
    return self
end

function M.Install(hostStructure, runtime, manifest)
    assert(hostStructure and runtime.isRegistered)
    assert(runtime.weaponUsesEnergy and runtime.updateWeapons,
        "FA adjacency install requires energy-weapon and rate-of-fire consumers")
    assert(runtime.applyBuild and runtime.applyMaintenance,
        "FA adjacency install requires FA build minimum and maintenance floor consumers")
    if hostStructure.__scomFAAdjacency then return hostStructure.__scomFAAdjacency end
    local core = M.New(runtime, manifest)
    local oldCreate, oldComplete, oldDestroy = _G.CreateUnit,
        hostStructure.OnStopBeingBuilt, hostStructure.OnDestroy
    local oldAdjacent, oldNotAdjacent = hostStructure.OnAdjacentTo,
        hostStructure.OnNotAdjacentTo
    assert(oldCreate and oldComplete and oldDestroy
        and oldAdjacent and oldNotAdjacent)
    _G.CreateUnit = function(...)
        local unit = oldCreate(...)
        if unit and runtime.isRegistered(unit) then core:Refresh(unit) end
        return unit
    end
    hostStructure.OnStopBeingBuilt = function(unit, ...)
        local result = oldComplete(unit, ...)
        if runtime.isRegistered(unit) then core:Refresh(unit) end
        return result
    end
    hostStructure.OnDestroy = function(unit, ...)
        core:Forget(unit)
        return oldDestroy(unit, ...)
    end
    hostStructure.OnAdjacentTo = function(unit, other, ...)
        if manifest.providers[unit.tpId] then
            if runtime.isRegistered(unit) then core:Refresh(unit) end
            return
        end
        return oldAdjacent(unit, other, ...)
    end
    hostStructure.OnNotAdjacentTo = function(unit, other, ...)
        if manifest.providers[unit.tpId] then
            core:Disconnect(unit, other)
            return
        end
        return oldNotAdjacent(unit, other, ...)
    end
    hostStructure.__scomFAAdjacency = core
    return core
end

M.Bounds = bounds
M.EdgeContact = edgeContact
return M
end)()
local SCO_FA_Adapter = (function()
-- Host-only inputs for the FA adjacency core.
-- Concatenate this with the final host appendix; loose pack Import is unproven.
local M = {}

local function isMappedStructure(unit, facts)
    local source = unit and facts[unit.tpId]
    if not source or not unit.tp or not unit.tp.tags then return false end
    local structure, size = false, false
    for _, tag in ipairs(unit.tp.tags) do
        if tag == "SCFA_STRUCTURE" then structure = true end
        if tag == source.sizeTag then size = true end
    end
    return structure and size
end

-- The stock entity copies each builder's discount when it is added. Clamp the
-- copied factor to FA's minimum one resource per build, without changing the
-- builder's stored adjacency factor or any non-SCOM builder.
function M.InstallBuildClamp(resourceClass, recipientFacts)
    assert(resourceClass and resourceClass.AddBuilder and recipientFacts)
    if resourceClass.__scomFABuildClamp then return end
    local prior = resourceClass.AddBuilder
    resourceClass.AddBuilder = function(entity, builder)
        if not isMappedStructure(builder, recipientFacts) then
            return prior(entity, builder)
        end
        local original = builder.adjacencyBonus
        local clamped = {}
        for name, factor in pairs(original or {}) do clamped[name] = factor end
        for resource, cost in pairs(entity.originalCost or {}) do
            if cost > 0 then
                local factor = clamped[resource] or 1
                if cost * factor < 1 then clamped[resource] = 1 / cost end
            end
        end
        builder.adjacencyBonus = clamped
        local ok, result = pcall(prior, entity, builder)
        builder.adjacencyBonus = original
        if not ok then error(result) end
        return result
    end
    resourceClass.__scomFABuildClamp = true
end

function M.ApplyBuild(unit, resource, old, new)
    unit.adjacencyBonus = unit.adjacencyBonus or {}
    unit.adjacencyBonus[resource] =
        (unit.adjacencyBonus[resource] or 1) + new - old

    local seen = {}
    local function update(entity)
        if entity and not seen[entity] and entity.buildPowerSources
            and entity.buildPowerSources[unit.id] then
            entity:UpdateBuilder(unit)
            seen[entity] = true
        end
    end
    local target = unit.unitBeingBuilt
    if target and target.resourceEntities then
        update(target.resourceEntities.construction)
    end
    for _, name in ipairs({ "scoTactical", "scoStrategicSilo" }) do
        local state = unit[name]
        if state then update(state.resourceEntity or state.resource) end
    end
    update(unit.scoStrategicSiloAssistEntity)
end

function M.ApplyMaintenance(unit, resource, old, new)
    local eco = unit.tp and unit.tp.economy
    local base = eco and eco.maintenanceConsumption
        and eco.maintenanceConsumption[resource]
    local entities = unit.resourceEntities or {}
    local entity = entities.consumption or entities.production
    if base == nil or not entity then return false end
    local values = {}
    for name, value in pairs(entity.outcome) do
        values[name] = value * Constants.TickRate
    end
    values[resource] = (values[resource] or 0) + base * (new - old)
    entity:SetResources(nil, values)
    return true
end

function M.InstallExtractorReapply(extractorClass, core, recipientFacts)
    assert(extractorClass and extractorClass.PauseProduction
        and extractorClass.UnPauseProduction and core and recipientFacts)
    if extractorClass.__scomFAExtractorReapply then return end
    local oldPause, oldUnpause = extractorClass.PauseProduction,
        extractorClass.UnPauseProduction
    extractorClass.PauseProduction = function(unit, ...)
        local result = oldPause(unit, ...)
        if isMappedStructure(unit, recipientFacts) then
            unit.__scomFAProductionPaused = true
        end
        return result
    end
    extractorClass.UnPauseProduction = function(unit, ...)
        local result = oldUnpause(unit, ...)
        if isMappedStructure(unit, recipientFacts) then
            unit.__scomFAProductionPaused = nil
            core:ReapplyExtractor(unit)
        end
        return result
    end
    extractorClass.__scomFAExtractorReapply = true
end

function M.MakeRuntime(recipientFacts, consumers)
    assert(recipientFacts and consumers)
    assert(consumers.weaponUsesEnergy and consumers.updateWeapons)
    assert(consumers.resourceClass and consumers.resourceClass.__scomFABuildClamp,
        "FA build clamp must be installed before adjacency runtime")

    local runtime = {
        recipientFacts = recipientFacts,
        tickRate = Constants.TickRate,
        weaponUsesEnergy = consumers.weaponUsesEnergy,
        updateWeapons = consumers.updateWeapons,
        applyBuild = M.ApplyBuild,
        applyMaintenance = M.ApplyMaintenance,
    }

    function runtime.query(area)
        local min = EngineClasses.int2(area.x0, area.z0)
        local max = EngineClasses.int2(area.x1, area.z1)
        local code, ids = Engine.GetGlobalGridModifiers(
            _G.globalBuildingPlacementGridID, min, max,
            Layers.PlacementLayer.Default)
        assert(code == EngineErrorCode.Success and ids,
            "FA adjacency grid query failed")
        return ids
    end

    function runtime.getUnit(id)
        return GetUnitById(id)
    end

    function runtime.isRegistered(unit)
        return GetUnitById(unit.id) == unit
    end

    return runtime
end

return M
end)()
local weaponAPI = assert(_G.SCO_FA_AdjacencyWeaponAPI, "FA weapon appendix must load first")
assert(weaponAPI.version == "1.0.0" and weaponAPI.WeaponUsesEnergy and weaponAPI.UpdateWeapons)
local resourceClass = ResourceEntity or Import("host/systems/resourceEntity.lua").ResourceEntity
assert(resourceClass and HostStructure and HostAlloyExtractor)
SCO_FA_Adapter.InstallBuildClamp(resourceClass, SCO_FA_Recipients)
local runtime = SCO_FA_Adapter.MakeRuntime(SCO_FA_Recipients, {
    resourceClass = resourceClass,
    weaponUsesEnergy = weaponAPI.WeaponUsesEnergy,
    updateWeapons = weaponAPI.UpdateWeapons,
})
local adjacencyCore = SCO_FA_Core.Install(HostStructure, runtime, SCO_FA_Manifest)
SCO_FA_Adapter.InstallExtractorReapply(HostAlloyExtractor, adjacencyCore, SCO_FA_Recipients)
end
Import('common/systems/scoSourceSubmarineTargeting.lua').InstallNavalUnit(HostNavalUnit)
-- SCOM factory rally visibility host state 1.0.0
local RallyLobby = Import("common/lobby.lua")
local RallySession = Import("common/commands/definitions/session.lua")

function PublishFactoryRally(unit)
    if unit == nil or unit.dead or not unit:IsFactory() then
        return
    end

    local id = unit.id
    local point = unit.rallyPoint
    local data = {
        unitIndex = id.index,
        unitVersion = id.version,
        isSlave = unit.isSlaveFactory == true,
        hasExplicit = point ~= nil,
        fatboyMovementLocked = unit.fatboyMovementLocked == true,
    }
    if point ~= nil then
        data.x, data.y, data.z = point.x, point.y, point.z
    end

    -- The generic session bridge has a fixed command ID; target the unit's owner.
    for clientID, player in pairs(RallyLobby.Players) do
        if player.armyID == unit.army.id and player.playerType ~= PlayerType.Observer then
            RallySession.ExecuteClientFunction.SendTo(clientID, "FactoryRallyPoint", data)
        end
    end
end

local previousSetRallyPoint = HostFactory.SetRallyPoint
function HostFactory:SetRallyPoint(position)
    previousSetRallyPoint(self, position)
    PublishFactoryRally(self)
end

local previousSetMasterFactory = HostUnit.SetMasterFactory
function HostUnit:SetMasterFactory(master)
    previousSetMasterFactory(self, master)
    if self:IsFactory() then
        PublishFactoryRally(self)
    end
end

local previousClearMasterFactory = HostUnit.ClearMasterFactory
function HostUnit:ClearMasterFactory()
    previousClearMasterFactory(self)
    if self:IsFactory() then
        PublishFactoryRally(self)
    end
end

local previousEndUpgrade = HostStructure.OnEndUpgrade
function HostStructure:OnEndUpgrade(upgrader)
    previousEndUpgrade(self, upgrader)
    if self:IsFactory() and not self.dead then
        PublishFactoryRally(self)
    end
end

-- SCOM manual ACU Overcharge 1.0.0
Import('common/systems/scoOvercharge.lua').InstallHost(HostCommander)
