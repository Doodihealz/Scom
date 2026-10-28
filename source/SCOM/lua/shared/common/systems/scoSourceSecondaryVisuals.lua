-- SCOM optional-pack inherited visuals: opt1
local M={}
local function Config(unit)
    local c=unit.tp and unit.tp.additions and unit.tp.additions.scoSourceSecondaryVisuals
    if not c or (not c.rotators and not c.animationState and not c.airAnimation) then return end
    local optionalId=unit.tpId
    if type(c.targetId)=='string'
        and c.targetId:match('^u[ecgs]%a%d+$')
        and type(optionalId)=='string'
        and (optionalId:match('^w%a%a%d+$') or optionalId:match('^sc2r_')) then
        return
    end
    assert(c.targetId==unit.tpId,'Secondary rotator identity drift')
    return c
end
local function Active(unit,condition)
    if condition=='shield' then
        for _,shield in ipairs(unit.shields or {}) do if shield:IsEnabled() then return true end end
        return false
    elseif condition=='production' then
        return unit:GetProductionToggle() and not unit:GetPause()
    elseif condition=='build' then
        if unit.IsBuildRoutineEnabled and unit:IsBuildRoutineEnabled() then return true end
        return false
    elseif condition=='constructionWork' then
        return (unit.IsBuildRoutineEnabled and unit:IsBuildRoutineEnabled())
            or (unit.IsRepairRoutineEnabled and unit:IsRepairRoutineEnabled())
    end
    return true
end
local function Approach(value,target,step)
    if value<target then return math.min(value+step,target) end
    return math.max(value-step,target)
end
local function Available(unit)
    return not unit.dead and not unit.deleted and not unit.upgradeTarget and not unit.scoProgressBoundUpgradeTarget
end
local function AirPhase(config,state,now)
    local clip=config.clips[state.role]
    state.phase=math.max(0,math.min(clip.duration,state.phase+math.max(0,now-state.time)*state.rate))
    state.time=now
end
function M.AirEvent(unit,event,now,abortedLanding)
    local c=Config(unit);local config=c and c.airAnimation
    if not config or not Available(unit) or not unit:IsCompleted() then return end
    local state=unit.scoSecondaryAir
    if state then AirPhase(config,state,now) end
    if config.kind=='reversible' then
        state=state or {role='land',phase=0,time=now}
        state.rate=event=='land' and -1 or 1
    elseif event=='takeoff' and abortedLanding and state and state.role=='land' then
        state.rate=-1
    else
        state={role=event,phase=0,time=now,rate=event=='land' and 1.5 or 1}
    end
    unit.scoSecondaryAir=state
end
local function SampleAir(unit,config,now)
    local state=unit.scoSecondaryAir
    if not state then return end
    if not Available(unit) or unit.scoCargoCarrier then state.time=now;return end
    AirPhase(config,state,now)
    local expected=config.clips[state.role]
    local animation=unit.tp.visuals.animations[expected.key]
    assert(animation and animation.id and animation.clipName==expected.clipName and animation.authoredSpeed==1,
        'Source aircraft animation identity drift')
    local result=Engine.PlayAnimation(unit.id,animation.id,-10000+state.phase)
    assert(result==EngineErrorCode.Success,'Source aircraft exact sample failed')
end
function M.Tick(unit,now)
    local c=Config(unit)
    if not c then return end
    local state=unit.scoSecondaryRotators
    if not state then state={axes={},applied={},last=now};unit.scoSecondaryRotators=state end
    local delta=math.max(0,now-state.last);state.last=now
    local completedNow=state.completedAt==nil and unit:IsCompleted()
    if completedNow then state.completedAt=now end
    if c.airAnimation then
        if completedNow and c.airAnimation.initial and not unit.scoSecondaryAir then M.AirEvent(unit,'takeoff',now,false) end
        SampleAir(unit,c.airAnimation,now)
    end
    local animation=c.animationState
    local upgraded=unit.upgradeTarget~=nil or unit.scoProgressBoundUpgradeTarget~=nil
    if animation and not unit.dead and not unit.deleted and not upgraded then
        local phase=state.phase or 0
        local active=state.completedAt~=nil and Active(unit,animation.condition)
        local animationDelta=(completedNow or state.animationReset) and 0 or delta
        state.animationReset=nil
        if animation.condition=='build' and active and not state.animationCondition then phase=0;animationDelta=0 end
        local advancing = active
        if animation.condition == 'constructionWork' then
            -- Work callbacks arrive after their flags change. Advance to the
            -- event using the previous direction before reversing at now.
            advancing = state.animationCondition == true
            if state.wasUpgrading then animationDelta = 0 end
        end
        phase=math.max(0,math.min(animation.duration,phase+animationDelta*(advancing and animation.forwardRate or animation.reverseRate)))
        state.animationCondition=active
        state.phase=phase
        local binding=unit.tp.visuals.animations[animation.key]
        assert(binding and binding.id and binding.clipName==animation.clipName and binding.authoredSpeed==1,
            'Secondary source animation binding drift')
        local result=Engine.PlayAnimation(unit.id,binding.id,-10000+phase)
        assert(result==EngineErrorCode.Success,'Secondary exact source animation sampling failed')
        state.sampledPhase,state.sampledAnimation=phase,binding.id
    end
    state.wasUpgrading=upgraded
    local groups={}
    for index,definition in ipairs(c.rotators or {}) do
        local current=state.axes[index]
        local created=false
        local available=state.completedAt~=nil and now-state.completedAt>=definition.delay and not unit.dead and not unit.deleted
        if not current and available then
            local speed=definition.speed
            if definition.randomRange then
                speed=speed+math.random(0,definition.randomRange)*(math.random(0,2)>1 and 1 or -1)
            elseif definition.randomAddRange then
                speed=speed+math.random(0,definition.randomAddRange)
            end
            current={speed=definition.initialSpeed,target=speed,condition=Active(unit,definition.condition)}
            state.axes[index]=current
            created=true
        end
        local enabled=available and current~=nil
        if current and enabled then
            local active=Active(unit,definition.condition)
            if active~=current.condition then current.condition=active;current.transitioned=true end
            local target=active and current.target or 0
            if definition.initialTarget and not current.transitioned then target=definition.initialTarget end
            local acceleration=active and definition.acceleration or definition.disabledAcceleration
            current.speed=Approach(current.speed,target,(created and 0 or delta)*acceleration)
        end
        local group=groups[definition.bone] or {speed={x=0,y=0,z=0},enabled=false}
        group.speed[definition.axis]=enabled and current.speed or 0
        group.enabled=group.enabled or enabled;groups[definition.bone]=group
    end
    for name,group in pairs(groups) do
        local id=unit:GetBoneId(name)
        if id and Engine.IsValidGlobalID(id) then
            local previous=state.applied[name]
            if not previous or previous.speed.x~=group.speed.x or previous.speed.y~=group.speed.y or previous.speed.z~=group.speed.z then
                Engine.SetRotatorSpeed(id,EngineClasses.float3(group.speed.x,group.speed.y,group.speed.z))
            end
            if not previous or previous.enabled~=group.enabled then Engine.SetRotatorEnabled(id,group.enabled) end
            state.applied[name]=group
        end
    end
end
function M.InstallUnit(class)
    if class.scoSecondaryHostInstalled then return end
    class.scoSecondaryHostInstalled=true
    local previous=class.__init
    class.__init=function(self,...)
        previous(self,...)
        if Config(self) then
            if Config(self).airAnimation then
                local takeoff,landing=self.TakeoffBehaviourStart,self.LandingBehaviorStart
                self.TakeoffBehaviourStart=function(unit,...)
                    local wasActive,wasLanding=unit.takeoffBehaviorIsActive,unit.landingBehaviorIsActive
                    local result=takeoff(unit,...)
                    if not wasActive and unit.takeoffBehaviorIsActive then
                        M.AirEvent(unit,'takeoff',Engine.GetSimulationTime(),wasLanding)
                    end
                    return result
                end
                self.LandingBehaviorStart=function(unit,...)
                    local wasActive=unit.landingBehaviorIsActive
                    local result=landing(unit,...)
                    if not wasActive and unit.landingBehaviorIsActive then M.AirEvent(unit,'land',Engine.GetSimulationTime(),false) end
                    return result
                end
            end
            self:NewThread(function(unit)
                repeat
                    M.Tick(unit,Engine.GetSimulationTime())
                    if unit.dead or unit.deleted then return end
                    WaitSeconds(.1)
                until false
            end)
        end
    end
    local destroy=class.OnDestroy
    class.OnDestroy=function(self,...)
        local result=destroy(self,...)
        if Config(self) then M.Tick(self,Engine.GetSimulationTime()) end
        return result
    end
    local update=class.UpdateAnimations
    class.UpdateAnimations=function(self,...)
        local result=update(self,...)
        local c=Config(self)
        if c and (c.animationState or (c.airAnimation and self.scoSecondaryAir)) and
            not self.dead and not self.deleted and not self.upgradeTarget and
            not self.scoProgressBoundUpgradeTarget then
            M.Tick(self,Engine.GetSimulationTime())
        end
        return result
    end
    local startBuild=class.OnStartBuildRoutine
    class.OnStartBuildRoutine=function(self,...)
        local result=startBuild(self,...)
        local c=Config(self)
        if c and c.animationState and c.animationState.condition=='build' then
            local state=self.scoSecondaryRotators
            if state then state.phase=0;state.sampledPhase=nil;state.animationReset=true end
            M.Tick(self,Engine.GetSimulationTime())
        end
        return result
    end
    -- Hives reverse the same one-second source clip from its current phase.
    -- Build and HP repair share this owner; changing targets never restarts it.
    for _, callback in ipairs({'OnStartBuildRoutine', 'OnStopBuildRoutine',
        'OnStartRepairRoutine', 'OnStopRepairRoutine'}) do
        local previous = class[callback]
        class[callback] = function(self, ...)
            local result = previous(self, ...)
            local c = Config(self)
            if c and c.animationState and c.animationState.condition == 'constructionWork' then
                M.Tick(self, Engine.GetSimulationTime())
            end
            return result
        end
    end
end
local moduleEnvironment = getfenv(1)
for name, value in pairs(M) do moduleEnvironment[name] = value end
return M
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                