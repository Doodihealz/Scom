local Native = Import('host/units/unitsClasses/unitsDefault.lua').HostTransportUnit
local Attachments = Import('common/units/transportAttachments.lua')
local methods = {
    'ReserveAttachPoint','ReleaseAttachPoint','OnCargoDestroyed','FindAttachPoint','CargoUnits','CanDropAt',
    'EnterLoadAltitude','ExitLoadAltitude','OnAltitudeReached','ShouldStayAtLoadAltitude',
    'LoadBehaviorIsValidFor','LoadBehaviorStart','LoadBehaviorThread','LoadBehaviorFinish','IsLiftingCargo',
    'CanReplaceOrders','LoadBehaviorStop','UnloadBehaviorIsValidFor','IsDroppingCargo',
    'UnloadBehaviorStart','UnloadBehaviorThread','UnloadBehaviorFinish','UnloadBehaviorStop',
}
function Derive(base, name)
    local cls = Import('scom/units/behavior.lua').Derive(name, base)
    for _, method in ipairs(methods) do cls[method] = assert(Native[method], method) end
    function cls:__init(...)
        base.__init(self, ...)
        self.attachGroups = Attachments.BuildAttachPoints(self)
        self.cargoDestroyedCallbacks = {}
        self.loadBehaviorIsActive, self.unloadBehaviorIsActive = false, false
        self.isAtLoadAltitude, self.loadAltitudeReached = false, false
    end
    function cls:LandingBehaviorIsValidFor()
        return #Attachments.OccupiedPoints(self.attachGroups) == 0 and base.LandingBehaviorIsValidFor(self)
    end
    function cls:OnBecameIdle()
        self:ExitLoadAltitude()
        return base.OnBecameIdle(self)
    end
    function cls:OnDestroy(...)
        for _, unit in ipairs(self:CargoUnits()) do unit:BeginCrashing() end
        self:LoadBehaviorStop()
        self:UnloadBehaviorStop()
        for _, point in ipairs(Attachments.OccupiedPoints(self.attachGroups)) do self:ReleaseAttachPoint(point) end
        return base.OnDestroy(self, ...)
    end
    local loadIsValid = cls.LoadBehaviorIsValidFor
    function cls:LoadBehaviorIsValidFor(unit)
        return loadIsValid(self, unit) and not unit.scoTractorTargetKey
            and not unit.scoCargoCarrier and not unit.scoCargoReleasing
            and not unit.scoCargoPendingCarrier and not unit.scoFactoryColliderPinOwner
    end
    return cls
end
