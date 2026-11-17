-- Hand finished land products to their local scheduler after native roll-off.
-- Watches only factory outputs; never cancels movement or creates a second plan.
local UnitState=Import("AI/mods/AI-Scom/RushUnitState.lua")
local Balance=Import("AI/mods/AI-Scom/RushBalance.lua")
local AF=Import("AI/AIFunctions.lua")
local Diagnostics=Import("AI/mods/AI-Scom/RushDiagnostics.lua")
local MAX_PENDING=256
local function Now()
    -- The host's seconds helper floors Tick/10; deadlines here need tick precision.
    if type(Tick)=="number" then return Tick/((Constants and Constants.TickRate) or 10) end
    return GetGameTimeSeconds()
end
local function Own(army,unit)
    return army and unit and not unit.dead and not unit.deleted and unit.army==army
        and unit.id and army.units and army.units[unit.id.index]==unit
end
local function State(army)
    local state=army.ai.rushFactoryHandoff
    if not state then state={pending={},count=0};army.ai.rushFactoryHandoff=state end
    return state
end
function Ready(unit)
    if not Own(unit and unit.army,unit) or not unit:IsCompleted() or unit.platoon
        or unit.CaptureInProgress or unit.ReclaimInProgress or unit.unitBeingBuilt or unit.upgradeTarget
        or unit.buildBehaviorIsActive or unit.repairBehaviorIsActive or unit.reclaimBehaviorIsActive
        or unit.assistBehaviorIsActive or unit.captureBehaviorIsActive
        or unit.buildQueue and next(unit.buildQueue)
        or UnitState.IsPaused(unit) then return false end
    local orders=unit.orders
    return not (orders and (orders.activeOrder or orders.queuedOrders and next(orders.queuedOrders)))
end
function Available(unit)
    -- Expiring the notification must not expose a still-moving rally unit.
    -- Explicit transfers from named platoons retain their existing ownership.
    return not (unit and unit.rushFactoryOutput and not unit.platoon) or Ready(unit)
end
local function Register(factory,unit)
    local army=factory.army
    if not Balance.Enabled(army) or army.ai.isAlive==false or not Own(army,unit)
        or not Balance.Has(unit.tp,"MOBILE") or not Balance.Has(unit.tp,"LAND")
        or Balance.Has(unit.tp,"COMMAND") then return end
    unit.rushFactoryOutput=true
    local source=factory.unitBeingBuiltSource or factory
    local baseName=source.assignedToBase or factory.assignedToBase
    local base=baseName and army.ai.bases and army.ai.bases[baseName]
    if not base then return end
    local engineer=Balance.Has(unit.tp,"ENGINEER")
    if engineer and not unit.assignedToBase then
        local pos=unit:GetPosition()
        if (pos.x-base.position.x)^2+(pos.z-base.position.z)^2<=(base.radius or 64)^2 then
            -- Affiliation is bookkeeping, not an order. Native roll-off keeps
            -- ownership while the builder is already indexed for its home base.
            AF.SetUnitBaseAssignment(army.id,unit,baseName)
        end
    end
    local state=State(army)
    if state.pending[unit] then return end
    if state.count>=MAX_PENDING then
        Diagnostics.Count(army,"factory_handoff","pending-cap");return
    end
    state.pending[unit]={baseName=baseName,base=base,created=Now(),factory=source.id and source.id.index}
    state.count=state.count+1
    Diagnostics.Event(army,"factory_unit_produced",{unit=unit.id.index,version=unit.id.version,template=unit.tpId,
        factory=source.id and source.id.index,base=baseName,role=engineer and "engineer" or "combat",tick=Tick})
end
function WatchFactory(army,factory)
    if not Balance.Enabled(army) or not Own(army,factory) or type(factory.RollOffUnit)~="function" then return end
    local previous=factory.rushHandoffHook
    if previous and factory.RollOffUnit==previous then return end
    local native=factory.RollOffUnit
    local hook=function(self,unit,...)
        local result=native(self,unit,...)
        local ok,err=pcall(Register,self,unit)
        if not ok then Diagnostics.Event(self.army,"error",{where="factory-handoff-register",error=err},"handoff-register",30) end
        return result
    end
    factory.rushHandoffHook=hook;factory.RollOffUnit=hook
end
function Poll(army)
    if not Balance.Enabled(army) or army.ai.isAlive==false then return nil end
    local state=army.ai.rushFactoryHandoff
    if not state or state.count==0 then return nil end
    local now=Now()
    local stamp=type(Tick)=="number" and Tick or now
    if state.polledAt==stamp then return nil end
    state.polledAt=stamp
    local ready={}
    for unit,record in pairs(state.pending) do
        if now<record.created then record.created=now end
        local remove=not Own(army,unit) or not not unit.platoon or now-record.created>30
        if Own(army,unit) and unit.platoon then
            local plan=unit.platoon.ai or {}
            Diagnostics.Event(army,"factory_unit_assigned",{unit=unit.id.index,template=unit.tpId,base=unit.assignedToBase,
                platoon=unit.platoon.id,former=plan.formerTable and plan.formerTable.FormerName,
                state=plan.eState,secondsSinceProduction=now-record.created,tick=Tick})
        elseif remove and Own(army,unit) then
            local orders=unit.orders or {}
            Diagnostics.Event(army,"factory_handoff_wait",{unit=unit.id.index,template=unit.tpId,
                secondsSinceProduction=now-record.created,activeOrder=orders.activeOrder~=nil,
                queuedOrders=orders.queuedOrders and next(orders.queuedOrders)~=nil,
                paused=UnitState.IsPaused(unit),tick=Tick})
        end
        if not remove and Ready(unit) then
            local name=unit.assignedToBase or record.baseName
            local base=army.ai.bases and army.ai.bases[name]
            -- Do not attach a surviving output to a replacement base's lease.
            if name==record.baseName and base~=record.base then base=nil end
            local pos=base and unit:GetPosition()
            if base and (pos.x-base.position.x)^2+(pos.z-base.position.z)^2<=(base.radius or 64)^2 then
                local engineer=Balance.Has(unit.tp,"ENGINEER")
                if engineer and not unit.assignedToBase then AF.SetUnitBaseAssignment(army.id,unit,name) end
                ready[name]=ready[name] or {base=base}
                ready[name][engineer and "engineer" or "combat"]=true
                Diagnostics.Event(army,"factory_unit_ready",{unit=unit.id.index,template=unit.tpId,
                    factory=record.factory,base=name,role=engineer and "engineer" or "combat",
                    rolloffSeconds=now-record.created,tick=Tick})
            else Diagnostics.Count(army,"factory_handoff","base-changed-or-rally-outside-base",unit.tpId) end
            remove=true
        end
        if remove then state.pending[unit]=nil;state.count=state.count-1 end
    end
    return next(ready) and ready or nil
end
