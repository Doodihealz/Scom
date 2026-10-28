-- Atlantis uses native paid factory production and submarine navigation.
local Defaults = Import("host/units/unitsClasses/unitsDefault.lua")
local Factory, Submarine = Defaults.HostFactory, Defaults.HostSubmarineUnit
local Orders = Import("host/managers/orders/hostOrderManager.lua")
local Tasks = Import("common/commonOrders.lua").OrderTasks
local Commands = Import("common/commands/definitions/units.lua")

HostSCOMAtlantisCarrier = Class("SCOMAtlantisCarrier", Factory)
local Carrier = HostSCOMAtlantisCarrier

-- Preserve the native sensor/dive implementation; Factory owns only production.
for _, name in ipairs({"DefaultTargetingLayer", "GroundedNavigationLayerName",
    "SetUpWaterSensors", "PromoteToUnit", "OnSpawnWreckage", "SetSurfacedLayers",
    "SetSubmergedLayers", "OnHullCrossedWaterline", "DiveBehaviorIsValidFor",
    "SurfaceBehaviorIsValidFor", "SetSubmerged", "DiveBehaviorStart",
    "DiveBehaviorStop", "SurfaceBehaviorStart", "SurfaceBehaviorStop", "OnAltitudeReached"}) do
    Carrier[name] = Submarine[name]
end

local function Alive(unit)
    return unit and not unit.dead and not unit.deleted
end

function Carrier:__init(id, army, template, progress, builder)
    -- Native construction may synchronously call OnStopBeingBuilt.
    self.adjacentUnits = {}
    self.buildQueue = {}
    self.buildQueueIdCounter = 1073741823
    self.isSurfaced = true
    Submarine.__init(self, id, army, template, progress, builder)
end

function Carrier:OnStopBeingBuilt()
    Submarine.OnStopBeingBuilt(self)
    self:SetSurfacedLayers()
    if not self.productionMonitorThread then
        self.productionMonitorThread = self:NewThread(self.ProductionMonitorThread)
    end
end

function Carrier:CanBeSlaveFactory() return false end
function Carrier:CanBeMasterFactory() return false end
function Carrier:UpdateAnimations() end

function Carrier:ProductionBehaviorIsValidFor()
    if self.scoAirProduct and not Alive(self.scoAirProduct) then
        self:SCOReleaseAirProduct(self.scoAirProduct)
    end
    if self.scoAirProduct and self.scoAirProduct:IsCompleted() then return false end
    return Factory.ProductionBehaviorIsValidFor(self)
end

function Carrier:SCOAirDeckAvailable()
    return Alive(self) and self:IsCompleted() and self.isSurfaced == true
        and not self.diveBehaviorIsActive and not self.surfaceBehaviorIsActive
end

function Carrier:GetConstructionSpawnPoint()
    return self:GetPosition()
end

function Carrier:SCOAirLaunchPoint(target)
    local hull = self.tp.collisionInfo
    local child = target.tp.collisionInfo
    local clearance = hull.collisionSize.z / 2 + child.collisionSize.z / 2 + 2
    local rotated = Engine.QuaternionRotateVector(self:GetOrientation(),
        EngineClasses.float3(0, 0, -clearance))
    local origin = self:GetPosition()
    local status, water = Engine.GetWaterLevel()
    assert(status == EngineErrorCode.Success, "Atlantis launch requires water level")
    return EngineClasses.float3(origin.x + rotated.x,
        water + math.max(target.tp.movement.preferredAltitude or 0, child.collisionSize.y + 1),
        origin.z + rotated.z)
end

function Carrier:SCOHoldAirProduct(target)
    if not Alive(target) then return end
    target:SCOStopAirStorageFlight()
    target:SetShieldToggle(false)
    for _, weapon in ipairs(target.weapons or {}) do
        if weapon.wantsEnabled then weapon:SetEnabled(false) end
    end
    Engine.SetMovementEnabled(target.id, false)
    target:SetTargetable(false)
    Engine.SetVolumeColliderEnabled(target.id, false)
    target:SetPosition(self:GetConstructionSpawnPoint())
    target:SetOrientation(self:GetOrientation())
end

local function WeaponRequests(target)
    local states = {}
    for _, weapon in ipairs(target.weapons or {}) do
        states[#states + 1] = {weapon = weapon, wanted = weapon.wantsEnabled == true}
    end
    return states
end

function Carrier:SCOPinAirProduct(target)
    if self.scoAirProduct == target then self:SCOHoldAirProduct(target); return end
    if self.scoAirProduct and not Alive(self.scoAirProduct) then
        self:SCOReleaseAirProduct(self.scoAirProduct)
    end
    assert(self.scoAirProduct == nil, "Atlantis has two production targets")
    self.scoAirProduct = target
    self.scoAirProductCallbacks = {
        completed = rawget(target, "OnStopBeingBuilt"),
        animations = rawget(target, "UpdateAnimations"),
        weapons = WeaponRequests(target),
        shieldToggle = target:GetShieldToggle(),
    }
    local completed = target.OnStopBeingBuilt
    target.OnStopBeingBuilt = function(unit, ...)
        completed(unit, ...)
        if self.scoAirProduct == unit then
            -- Native completion enables the aircraft battery. Preserve that
            -- requested state, then suppress it until this paid unit is released.
            self.scoAirProductCallbacks.weapons = WeaponRequests(unit)
            self:SCOHoldAirProduct(unit)
        end
    end
    target.UpdateAnimations = function() end
    target.scoFactoryColliderPinOwner = self
    target.scoCargoCarrier = self
    self:SCOHoldAirProduct(target)
    Commands.SCOSourceCargoState.Send(self.id, target.id, true, #(self.scoCargo or {}))
    self.scoAirProductThread = self:NewThread(function(factory)
        while Alive(factory) and Alive(target) and factory.scoAirProduct == target do
            factory:SCOHoldAirProduct(target)
            WaitTicks(1)
        end
    end)
end

function Carrier:SCOReleaseAirProduct(target)
    if self.scoAirProduct ~= target then return end
    if self.scoAirProductThread then KillThread(self.scoAirProductThread) end
    self.scoAirProductThread = nil
    local callbacks = self.scoAirProductCallbacks
    target.OnStopBeingBuilt = callbacks.completed
    target.UpdateAnimations = callbacks.animations
    target.scoFactoryColliderPinOwner = nil
    if target.scoCargoCarrier == self then target.scoCargoCarrier = nil end
    self.scoAirProduct, self.scoAirProductCallbacks = nil, nil
    if Alive(target) then
        target:SetShieldToggle(callbacks.shieldToggle)
        for _, state in ipairs(callbacks.weapons) do state.weapon:SetEnabled(state.wanted) end
        target:SetTargetable(true)
        Engine.SetVolumeColliderEnabled(target.id, true)
        Engine.SetMovementEnabled(target.id, true)
    end
end

function Carrier:OnStartBuildRoutine(target)
    self:SCOPinAirProduct(target)
    Factory.OnStartBuildRoutine(self, target)
end

function Carrier:OnStopBuildRoutine(target)
    Factory.OnStopBuildRoutine(self, target)
    if self.scoAirProduct == target then
        if Alive(target) then self:SCOHoldAirProduct(target)
        else self:SCOReleaseAirProduct(target) end
    end
end

function Carrier:RollOffUnit(target)
    -- Products stay protected inside a submerged/full carrier until a slot or
    -- a surfaced launch is available; the native queue charges each product once.
    while Alive(self) and Alive(target) do
        local slot = self:SCOCargoChooseSlot(target)
        if slot then
            self:SCOReleaseAirProduct(target)
            assert(self:SCOCargoAttach(target, slot, true), "Atlantis could not store its completed aircraft")
            self:SCOStartCargoDriver()
            return
        end
        if self:SCOAirDeckAvailable() then
            local point = self:SCOAirLaunchPoint(target)
            target:SetPosition(point)
            self:SCOReleaseAirProduct(target)
            target:SCOResumeAirStorageFlight()
            Commands.SCOSourceCargoState.Send(self.id, target.id, false, #(self.scoCargo or {}))
            Orders.HostIssueOrder(Tasks.MOVE, {target}, false, self.rallyPoint or point)
            return
        end
        WaitTicks(1)
    end
    self:SCOReleaseAirProduct(target)
end

function Carrier:ProductionBehaviorStop()
    local target = self.scoAirProduct
    Factory.ProductionBehaviorStop(self)
    if target then
        if Alive(self) and not self.scoAirDisposing and Alive(target) and target:IsCompleted() then
            -- Native production already charged and removed this queue item.
            -- Canceling the queue must retain its completed, unlaunched output.
            if not self.scoAirPendingReleaseThread then
                self.scoAirPendingReleaseThread = self:NewThread(function(factory)
                    factory:RollOffUnit(target)
                    factory.scoAirPendingReleaseThread = nil
                end)
            end
            return
        end
        self:SCOReleaseAirProduct(target)
        if Alive(target) then
            target:Delete()
        end
    end
end

function Carrier:SCODisposeAirProduction()
    self.scoAirDisposing = true
    if self.scoAirPendingReleaseThread then KillThread(self.scoAirPendingReleaseThread) end
    self.scoAirPendingReleaseThread = nil
    if self.productionMonitorThread then KillThread(self.productionMonitorThread) end
    self.productionMonitorThread = nil
    self:ProductionBehaviorStop()
end

function Carrier:OnDestroy(destroyType)
    self:SCODisposeAirProduction()
    return Factory.OnDestroy(self, destroyType)
end

function Carrier:Delete()
    self:SCODisposeAirProduction()
    return Submarine.Delete(self)
end

-- SCOM source surface-carrier production 1.0.0.
-- Share the paid Atlantis production/storage owner. The source naval class
-- retains presentation, water sensors, movement and destruction behavior.
local function SCOCreateSurfaceCarrier(name, naval)
    assert(naval and naval.__init and naval.OnStopBeingBuilt and naval.Delete,
        "Source surface carrier naval lifecycle is unavailable: " .. name)
    local surface = Class(name, naval, HostSCOMAtlantisCarrier)

    function surface:__init(id, army, template, progress, builder)
        self.adjacentUnits = {}
        self.buildQueue = {}
        self.buildQueueIdCounter = 1073741823
        naval.__init(self, id, army, template, progress, builder)
    end

    function surface:OnStopBeingBuilt()
        naval.OnStopBeingBuilt(self)
        if not self.productionMonitorThread then
            self.productionMonitorThread = self:NewThread(self.ProductionMonitorThread)
        end
    end

    -- Multiple inheritance resolves direct members before remote ancestors.
    -- Explicitly retain these source naval members instead of Atlantis' dive
    -- delegates; a surface carrier must never acquire submarine behavior.
    surface.DefaultTargetingLayer = naval.DefaultTargetingLayer
    surface.SetUpWaterSensors = naval.SetUpWaterSensors
    surface.PromoteToUnit = naval.PromoteToUnit
    surface.OnSpawnWreckage = naval.OnSpawnWreckage
    surface.OnHullCrossedWaterline = naval.OnHullCrossedWaterline
    surface.UpdateAnimations = naval.UpdateAnimations
    function surface:DiveBehaviorIsValidFor() return false end
    function surface:SurfaceBehaviorIsValidFor() return false end
    function surface:SetSubmerged() return false end
    function surface:SCOAirDeckAvailable()
        return not self.dead and not self.deleted and self:IsCompleted()
    end

    function surface:OnDestroy(destroyType)
        self:SCODisposeAirProduction()
        return naval.OnDestroy(self, destroyType)
    end

    function surface:Delete()
        self:SCODisposeAirProduction()
        return naval.Delete(self)
    end

    return surface
end

HostSCOMAeonCarrier = SCOCreateSurfaceCarrier("SCOMAeonCarrier",
    Import("host/units/unitsClasses/unitsDefaultChosen.lua").HostAeonPortNavalUnit)
HostSCOMSeraphimCarrier = SCOCreateSurfaceCarrier("SCOMSeraphimCarrier",
    Import("host/units/unitsClasses/unitsDefaultSeraphim.lua").HostSeraphimNavalUnit)
HostSCOMCybranCarrier = SCOCreateSurfaceCarrier("SCOMCybranCarrier",
    Import("host/units/unitsClasses/unitsDefaultGuard.lua").HostGuardNavalUnit)
