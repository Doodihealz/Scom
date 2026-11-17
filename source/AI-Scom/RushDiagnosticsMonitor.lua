local RushUnitState = Import("AI/mods/AI-Scom/RushUnitState.lua")
-- Observational diagnostics only. Never feeds measurements back into AI policy.
local Diagnostics = Import("AI/mods/AI-Scom/RushDiagnostics.lua")
local EconomyPolicy = Import("AI/mods/AI-Scom/RushEconomyPolicy.lua")
local watched = {}
local worker
local function Now() return GetGameTimeSeconds() end
local function Number(value) return type(value)=="number" and value==value and math.abs(value)<math.huge and value or 0 end
local function Total(values)
    local n=0;for _,value in pairs(values or {}) do n=n+Number(value) end;return n
end
local function Stats(army)
    local s=army.stats and army.stats.units or {}
    return Total(s.lost),Total(s.destroyed)
end
local function Identity(army)
    local lobby=army.lobbyOptions or {}
    local settings=lobby.aiSettings or army.ai and army.ai.settings or {}
    local markers=GameInfo and GameInfo.MapData and GameInfo.MapData.markers
    local transform=markers and markers.Spawn and markers.Spawn.transforms and markers.Spawn.transforms[army.name]
    local p=transform and transform.position or {}
    -- Lobby metadata is public; no enemy unit census or hidden economy reads.
    return {id=army.id,name=army.name,faction=army.faction,profile=settings.modName,
        difficulty=settings.difficulty,team=lobby.team,color=lobby.color or lobby.colour,
        spawnX=p.x,spawnZ=p.z,unitCap=army.maximumUnitCount,
        incomeAndBuildMultiplier=army.economy and army.economy.incomeAndBuildMultiplier}
end
local function Alert(army,state,key,condition,delay,fields)
    local now=Now();local previous=state.alerts[key]
    if not condition then
        if previous and previous.reported then
            Diagnostics.Event(army,"inefficiency_cleared",{reason=key,duration=now-previous.since})
        end
        state.alerts[key]=nil;return
    end
    if not previous or now<previous.since then previous={since=now};state.alerts[key]=previous end
    if now-previous.since>=delay and (not previous.reported or now-previous.reported>=60) then
        fields=fields or {};fields.reason=key;fields.duration=now-previous.since
        Diagnostics.Event(army,"inefficiency",fields)
        previous.reported=now
    end
end
local function ObserveImpl(army,s,controller)
    local state=watched[army.id]
    if not state or state.army~=army or state.ai~=army.ai then return end
    local now=Now()
    state.heartbeat=now
    if state.sampleAt and now>=state.sampleAt and now-state.sampleAt<10 then return end
    local elapsed=state.sampleAt and math.max(0,now-state.sampleAt) or 0
    if state.sampleAt and now<state.sampleAt then state.alerts={};state.previous=nil end
    state.sampleAt=now
    local a,e=s.alloy or {},s.energy or {}
    local totals=army.economy and army.economy.totals or {}
    local nativeAlloy,nativeEnergy=totals.alloys or {},totals.energy or {}
    local rate=Constants and Constants.TickRate or 10
    local lost,destroyed=Stats(army)
    local previous=state.previous or {}
    local adaptive=s.adaptive or {};local topology=adaptive.topology or {}
    local expansion=army.ai.rushExpansion or {}
    Diagnostics.Event(army,"economy",{sampleSeconds=elapsed,snapshotAge=now-(s.time or now),
        alloyIncome=a.income,alloyRequest=a.request,alloySpent=Number(nativeAlloy.outcome)*rate,
        alloyStored=a.current,alloyCapacity=a.storage,alloyReserved=a.reserved,alloySatisfaction=nativeAlloy.satisfaction,
        energyIncome=e.income,energyRequest=e.request,energySpent=Number(nativeEnergy.outcome)*rate,
        energyStored=e.current,energyCapacity=e.storage,energyReserved=e.reserved,energySatisfaction=nativeEnergy.satisfaction,
        factories=s.completeFactories,activeFactories=s.productionActive,idleFactories=s.idleFactories,
        pausedFactories=s.pausedFactories,unassignedFactories=s.unassignedFactories,upgrades=s.upgrades,
        landFactories=s.landFactories,airFactories=s.airFactories,navalFactories=s.navalFactories,
        unfinishedFactories=s.unfinishedFactories,navalBuilding=s.navalFactoriesBuilding,
        engineers=s.engineersComplete,idleEngineers=s.engineersIdle,queuedEngineers=s.engineersQueued,
        extractors=s.extractors,unitCount=army.currentUnitCount,capSpace=s.underCap,
        submitted=controller.submitted,submittedDelta=controller.submitted-(previous.submitted or controller.submitted),
        decisions=controller.dispatched,errors=controller.failedChecks,expansions=expansion.active,expansionGoal=expansion.wanted})
    Diagnostics.Event(army,"strategy",{mode=adaptive.mode,difficulty=adaptive.difficulty,challenge=adaptive.challenge,
        enemies=topology.enemyCount,allies=topology.allyCount,enemyDistance=topology.nearestEnemyDistance,
        allyDistance=topology.nearestAllyDistance,groundEnemyDistance=topology.nearestGroundEnemyDistance,
        exposure=topology.exposure,groundFloor=adaptive.groundFloor,techGroundMinimum=adaptive.techGroundMinimum,
        groundReady=s.groundReady,groundThreat=s.groundThreat,groundDelta=s.groundReady-(previous.ground or s.groundReady),
        nativeLost=lost,nativeLostDelta=lost-(previous.lost or lost),nativeDestroyed=destroyed,
        landDisconnected=s.landDisconnected,landPanic=s.landPanic,airPanic=s.airPanic,navalPanic=s.navalPanic,
        localLandThreat=s.localLandThreat,mainRaid=s.mainRaid,mainBombardment=s.mainBombardment})
    Diagnostics.Event(army,"composition",s.completeRoles or {})
    local extractorReady,extractorReason=EconomyPolicy.ExtractorInvestmentReady(army,s)
    Diagnostics.Event(army,"investment_policy",{openingFactories=EconomyPolicy.OpeningFactoryGoal(army,s),
        nextFactory=EconomyPolicy.OpeningFactoryDomain(army,s),extractorReady=extractorReady,
        extractorReason=extractorReason,mexUpgrades=s.development and s.development.mexUpgrades,
        homeIdleEngineers=s.idleEngineersByBase and s.idleEngineersByBase.MAIN})
    local capped=Number(a.ratio)>=0.95 and Number(a.income)>0
    local underSpending=Number(nativeAlloy.outcome)*rate<Number(a.income)*0.65
    Alert(army,state,"alloy_overflow_low_spending",capped and underSpending,20,
        {income=a.income,spent=Number(nativeAlloy.outcome)*rate,request=a.request,reserved=a.reserved,
            activeFactories=s.productionActive,idleFactories=s.idleFactories,capSpace=s.underCap})
    Alert(army,state,"alloy_starvation",Number(a.ratio)<0.05 and Number(a.request)>Number(a.income)*1.1,20)
    Alert(army,state,"energy_starvation",Number(e.ratio)<0.05 and Number(e.request)>Number(e.income)*1.1,20)
    Alert(army,state,"idle_factories",Number(s.idleFactories)>0 and s.underCap==true,20,{count=s.idleFactories})
    Alert(army,state,"idle_builders",Number(s.engineersIdle)>=2,30,{count=s.engineersIdle})
    Alert(army,state,"unassigned_factories",Number(s.unassignedFactories)>0,20,{count=s.unassignedFactories})
    Alert(army,state,"unit_cap",s.underCap==false,20)
    Alert(army,state,"stale_census",s.time and now-s.time>5,10,{age=s.time and now-s.time})
    Alert(army,state,"no_naval_capacity_on_disconnected_map",s.landDisconnected==true
        and Number(s.navalFactories)==0 and Number(s.navalFactoriesBuilding)==0,60)
    if previous.ground and previous.ground>=6 and s.groundReady<=previous.ground*0.70 then
        Diagnostics.Event(army,"ground_force_drop",{before=previous.ground,after=s.groundReady,
            seconds=elapsed,nativeLostDelta=lost-(previous.lost or lost),mode=adaptive.mode})
    end
    -- Fixed sample cap; the aggregate above still covers every factory.
    local detailCount=0
    for _,factory in ipairs(s.factories or {}) do
        local funding=s.factoryFunding and s.factoryFunding[factory] or {}
        if not funding.working and detailCount<12 then
            local queue=factory.buildQueue or {};local head=queue[1] or {}
            local platoon=factory.platoon;local ai=platoon and platoon.ai or {}
            Diagnostics.Event(army,"inactive_factory",{factory=factory.id and factory.id.index,
                template=factory.tpId,base=factory.assignedToBase,platoon=platoon and platoon.id,
                plan=ai.formerTable and ai.formerTable.FormerName,state=ai.eState,
                queueGroups=#queue,product=head.tpId,paused=RushUnitState.IsPaused(factory),
                reservedAlloy=funding.reservedMass,reservedEnergy=funding.reservedEnergy})
            detailCount=detailCount+1
        end
    end
    for name,base in pairs(army.ai.bases or {}) do
        local locationAge=base.rushLocationHeartbeat and now-base.rushLocationHeartbeat
        local productionAge=base.rushProductionHeartbeat and now-base.rushProductionHeartbeat
        if locationAge and locationAge>10 or productionAge and productionAge>10 then
            Diagnostics.Event(army,"stale_base_worker",{base=name,locationAge=locationAge,productionAge=productionAge},"base:"..name,30)
        end
    end
    -- Rotate through other plans as well: naval/air operations and construction
    -- retain their native state names without requiring another unit census.
    local plans={}
    for _,platoon in pairs(army.platoons or {}) do
        if platoon.ai and not platoon.ai.rushOperation and not platoon.dead and not platoon.deleted then
            plans[#plans+1]=platoon
        end
    end
    table.sort(plans,function(a,b) return a.id<b.id end)
    local first=1
    for i,platoon in ipairs(plans) do if platoon.id>(state.planCursor or -1) then first=i;break end end
    for offset=0,math.min(12,#plans)-1 do
        local platoon=plans[(first+offset-1)%#plans+1];local ai=platoon.ai
        local fleet=ai.rushFleet or {};local goal=fleet.goal or {}
        Diagnostics.Event(army,"plan_sample",{platoon=platoon.id,base=ai.baseName,
            former=ai.formerTable and ai.formerTable.FormerName,state=ai.eState,
            units=platoon:GetNumOfUnits(),goal=goal.kind,
            productionHeartbeatAge=ai.rushProductionHeartbeat and now-ai.rushProductionHeartbeat})
        state.planCursor=platoon.id
    end
    state.previous={ground=s.groundReady,lost=lost,submitted=controller.submitted}
end
function Observe(army,s,controller)
    if Diagnostics.Config and Diagnostics.Config.Enabled==false then return end
    local ok,err=pcall(ObserveImpl,army,s,controller)
    if not ok then Diagnostics.Event(army,"diagnostics_error",{where="snapshot",error=err},"snapshot-error",30) end
end
local function Poll()
    local now=Now()
    for id,state in pairs(watched) do
        local army=state.army
        local replaced=not Armies or Armies[id]~=army or army.ai~=state.ai
        local alive=not replaced and state.ai.isAlive~=false and (not army.IsAlive or army:IsAlive())
        if not alive then
            local lost,destroyed=Stats(army)
            Diagnostics.Event(army,"army_stopped",{reason=replaced and "army_or_ai_replaced" or "army_inactive",
                nativeLost=lost,nativeDestroyed=destroyed,unitCount=army.currentUnitCount})
            Diagnostics.End(army,replaced and "replaced" or "inactive")
            watched[id]=nil
        else
            if now<state.heartbeat then state.heartbeat=now end
            if now-state.heartbeat>=15 then
                Diagnostics.Event(army,"supervisor_stale",{heartbeatAge=now-state.heartbeat},"supervisor-stale",30)
            end
            Diagnostics.Tick(army)
        end
    end
    Diagnostics.Flush()
end
function Watch(army)
    if Diagnostics.Config and Diagnostics.Config.Enabled==false then return end
    local ok,err=pcall(function()
        local state=watched[army.id]
        if not state or state.army~=army or state.ai~=army.ai then
            if state then Diagnostics.End(state.army,"replaced") end
            watched[army.id]={army=army,ai=army.ai,heartbeat=Now(),alerts={}}
            Diagnostics.Event(army,"army_started",Identity(army))
            for _,other in pairs(Armies or {}) do Diagnostics.Event(army,"lobby_army",Identity(other)) end
        end
        if not worker or coroutine.status(worker)=="dead" then
            worker=NewThread(function()
                repeat
                    local success,failure=pcall(Poll)
                    if not success then Diagnostics.Event(nil,"diagnostics_error",{where="watcher",error=failure},"watcher-error",30) end
                    if not next(watched) then break end
                    WaitTicks(math.max(1,(Constants and Constants.TickRate or 10)*2))
                until false
                Diagnostics.Flush()
                worker=nil
            end)
        end
    end)
    if not ok then Diagnostics.Event(army,"diagnostics_error",{where="watch-start",error=err},"watch-start",30) end
end

-- Uses the combat controller's existing sensed geometry, not another threat scan.
function Combat(platoon,action,reason,terminal)
    if Diagnostics.Config and Diagnostics.Config.Enabled==false then return end
    local ok,err=pcall(function()
        local ai=platoon.ai or {};local op=ai.rushOperation
        if not op then return end
        local now=Now();local policy=op.policy or {};local g=ai.rushGeometry or {}
        local d=op.diagnostics
        if not d then d={started=now,initialCount=g.count,initialThreat=g.nominal};op.diagnostics=d end
        if d.ended then return end
        local finalReason=terminal and reason or policy.phase=="Hold" and policy.holdReason or reason or op.lastReason
        local signature=tostring(policy.phase)..":"..tostring(action)..":"..tostring(finalReason)
        if not terminal and d.at and now>=d.at and now-d.at<10 and signature==d.signature then return end
        d.at,d.signature=now,signature
        local goal=op.goal or {};local pos=g.position or {};local dest=goal.pos or op.moveGoal or {}
        local deaths,departures=op.diagnosticDeaths or 0,op.diagnosticDepartures or 0
        if terminal then
            for unit in pairs(op.unitPositions or {}) do
                if unit.dead then deaths=deaths+1 elseif unit.platoon~=platoon then departures=departures+1 end
            end
        end
        Diagnostics.Event(platoon.army,terminal and "combat_end" or "combat",{
            platoon=platoon.id,former=ai.formerTable and ai.formerTable.FormerName,
            phase=policy.phase,action=action,reason=finalReason,policyReason=reason,
            lifetime=now-d.started,phaseSeconds=now-(policy.phaseAt or now),progressAge=now-(policy.lastProgressAt or now),
            initialCount=d.initialCount,initialThreat=d.initialThreat,units=platoon:GetNumOfUnits(),
            present=g.count,own=g.own,nominal=g.nominal,friendly=ai.nearbyFriendlyThreat,
            enemy=op.exposure and op.exposure.total,observedDeaths=deaths,departures=departures,
            goal=goal.kind,target=goal.unit and goal.unit.id and goal.unit.id.index,
            x=pos.x,z=pos.z,targetX=dest.x,targetZ=dest.z,
            pendingPath=op.pendingMove~=nil,pathBudget=ai.rushPathThreat,
            movementAge=op.lastMoveAt and now-op.lastMoveAt})
        if terminal then d.ended=true end
        if not terminal and policy.phase=="Hold" and now-(policy.phaseAt or now)>=30 then
            Diagnostics.Event(platoon.army,"combat_held",{platoon=platoon.id,reason=finalReason,
                seconds=now-policy.phaseAt,units=g.count},"combat-held:"..tostring(platoon.id),30)
        end
    end)
    if not ok then Diagnostics.Event(type(platoon)=="table" and platoon.army or nil,
        "diagnostics_error",{where="combat",error=err},"combat-error",30) end
end
