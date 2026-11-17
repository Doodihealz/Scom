-- Planning-only credit for real power projects. Never modifies resource totals,
-- reservations, native orders, templates or current construction affordability.
Version = "9.2.7"
local UnitState=Import("AI/mods/AI-Scom/RushUnitState.lua")
local Tasks=Import("common/commonOrders.lua").OrderTasks
local START_SECONDS,ACCEPT_SECONDS,STALL_SECONDS,MAX_SECONDS=3,15,30,180
local State
local function Number(v,default)
    if type(v)=="number" and v==v and math.abs(v)<math.huge then return v end
    return default or 0
end
local function Position(p)
    return (type(p)=="table" or type(p)=="userdata")
        and Number(p.x,math.huge)<math.huge and Number(p.z,math.huge)<math.huge
end
local function Distance(a,b) return math.sqrt((a.x-b.x)^2+(a.z-b.z)^2) end
local function Has(tp,tag)
    if not tp then return false end
    if tp.hasTags and tp.hasTags[tag] then return true end
    for _,name in ipairs(tp.tags or {}) do if name==tag then return true end end
    return false
end
local function Power(tp)
    return Has(tp,"STRUCTURE") and Has(tp,"ENERGY_PRODUCTION") and not Has(tp,"ALLOYS_EXTRACTION")
end
local function Tier(tp)
    for t=4,1,-1 do if Has(tp,"TECH"..t) then return t end end
    return Number(tp and tp.general and tp.general.techNumber,1)
end
local function Own(a,u)
    return a and u and not u.dead and not u.deleted and not u.CaptureInProgress and not u.ReclaimInProgress
        and u.army==a and u.id and a.units and a.units[u.id.index]==u
end
local function Complete(u) return type(u.IsCompleted)=="function" and u:IsCompleted() end
local function Template(id) return __Templates and __Templates.Units and __Templates.Units[id] end
local function Fraction(u)
    if type(u.GetFractionComplete)~="function" then return nil end
    local value=u:GetFractionComplete()
    return type(value)=="number" and value==value and value>=0 and value<1 and value or nil
end
local function FormerTier(former)
    if not former or not former.NeedMobileBuilder or former.AIPlan~="planBuildWithEngineer" then return nil end
    local tier
    for _,line in ipairs(former.WantStructures or {}) do
        for id,on in pairs(line) do
            local tp=on and Template(id)
            if Power(tp) then tier=math.max(tier or 0,Tier(tp)) end
        end
    end
    return tier
end
local function LivePlatoon(army,p)
    return p and not p.dead and not p.deleted and p.ai and p.ai.eState~="Disband"
        and type(army.PlatoonExists)=="function" and army:PlatoonExists(p)
end
function MarkDispatch(army,platoon,tier)
    if not tier or not LivePlatoon(army,platoon) then return end
    local now=GetGameTimeSeconds()
    platoon.ai.rushPowerDispatch={armyAI=army.ai,platoonAI=platoon.ai,tier=tier,at=now,epoch=State(army,now).epoch}
end
local function Output(army,tp)
    local economy=tp and tp.economy
    local production=economy and economy.production
    local upkeep=economy and economy.maintenanceConsumption
    local gross=production and Number(production.energy)
    if not gross or gross<=0 then return 0 end
    local scale=Number(army.economy and army.economy.incomeAndBuildMultiplier)
    -- Unknown or reduced native multipliers cannot promise full template output.
    -- Higher cheat multipliers are deliberately not needed to justify a wait.
    if scale<=0 then return 0 end
    return math.max(0,gross-Number(upkeep and upkeep.energy))*math.min(1,scale)
end
State=function(army,now)
    local state=army.ai.rushPowerForecast
    if not state or state.armyAI~=army.ai then
        state={armyAI=army.ai,time=now,epoch=0,watches=setmetatable({}, {__mode="k"})}
        army.ai.rushPowerForecast=state
    elseif now<state.time then
        state.watches=setmetatable({}, {__mode="k"});state.invalidUntil=now+1;state.epoch=state.epoch+1
    end
    state.time=now
    return state
end
local function Duration(army,builder,target,tp)
    local fraction=target and Fraction(target) or 0
    if fraction==nil then return nil end
    local construction=builder.construction or builder.tp and builder.tp.construction
    local power=Number(construction and construction.buildPower)
    local work=Number(tp and tp.economy and tp.economy.buildTime)
    local scale=Number(army.economy and army.economy.incomeAndBuildMultiplier)
    local totals=army.economy and army.economy.totals
    local satisfaction=math.min(1,Number(totals and totals.alloys and totals.alloys.satisfaction),
        Number(totals and totals.energy and totals.energy.satisfaction))
    if power<=0 or work<=0 or scale<=0 or satisfaction<=0 then return nil end
    -- Use this live builder only, not speculative future assistance. Underfunded
    -- native satisfaction slows the prediction; extra cheat speed is not assumed.
    return work*(1-fraction)/(power*math.min(1,scale)*satisfaction)*1.25
end
local function Registered(army,builder,target)
    local entity=target.resourceEntities and target.resourceEntities.construction
    local economy=army.economy
    local source=entity and entity.buildPowerSources and entity.buildPowerSources[builder.id]
    return entity and entity.enabled==true and entity.category=="construction" and entity.unitId==target.id
        and entity.armyId==army.id and entity.economy==economy and economy and economy.armyId==army.id
        and economy.resourceEntities and economy.resourceEntities.construction
        and economy.resourceEntities.construction[entity.id]==entity and source and Number(source.buildPower)>0
end
local function BuildingTarget(builder)
    return builder.unitBeingBuilt or builder.unitBeingRepaired
        or builder.buildBehaviorIsActive and builder.buildBehaviorActualUnit
end
local function Watch(state,key,target,builder,position,now)
    local fraction=target and Fraction(target)
    local origin=type(builder.GetPosition)=="function" and builder:GetPosition()
    local distance=Position(origin) and Position(position) and Distance(origin,position) or nil
    local active=BuildingTarget(builder)
    local activeFraction=active and not Complete(active) and Fraction(active) or nil
    local w=state.watches[key]
    if not w then
        w={at=now,progressAt=now,fraction=fraction,distance=distance,active=active,activeFraction=activeFraction}
        state.watches[key]=w
    elseif fraction and (not w.fraction or fraction>w.fraction+0.000001)
        or distance and (not w.distance or distance<w.distance-0.5)
        or active==w.active and activeFraction and w.activeFraction and activeFraction>w.activeFraction+0.000001 then
        w.progressAt=now
    end
    w.fraction=fraction or w.fraction
    w.distance=distance and math.min(distance,w.distance or math.huge) or w.distance
    w.active,w.activeFraction=active,activeFraction
    return now-w.progressAt<STALL_SECONDS and (target~=nil or now-w.at<=ACCEPT_SECONDS)
end
-- Reuse the normal census for builder identities; validate orders, ownership,
-- pauses and progress live. New dispatches are visible before the next census.
function Read(army,snapshot)
    local result={projects={},counts={},starting={},accepted={}}
    if not army or not army.ai or army.ai.isAlive==false then return result end
    local now=GetGameTimeSeconds();local state=State(army,now)
    if state.invalidUntil and now<state.invalidUntil then return result end
    local census=snapshot and (snapshot.globalSnapshot or snapshot)
    if census==snapshot and snapshot and (snapshot.rushBeachheadBase or snapshot.rushSupportCensus) then
        census=army.ai.rushController and army.ai.rushController.snapshot
    end
    if census and census.powerForecastArmy and census.powerForecastArmy~=army then return result end
    local builders,seenBuilders,platoons,available={},{},{},{}
    local function addBuilder(u)
        if not seenBuilders[u] and Own(army,u) and Complete(u) and not UnitState.IsPaused(u) then
            seenBuilders[u]=true;builders[#builders+1]=u
        end
    end
    for _,builder in ipairs(census and census.powerForecastBuilders or {}) do addBuilder(builder) end
    for _,p in pairs(army.platoons or {}) do
        if LivePlatoon(army,p) and FormerTier(p.ai.formerTable) then
            platoons[#platoons+1]=p
            local assigned,ready=false,false
            for _,builder in ipairs(p:GetUnits()) do
                if builder.platoon==p and Own(army,builder) then
                    assigned=true;addBuilder(builder)
                    if not UnitState.IsPaused(builder) then ready=true end
                end
            end
            available[p]=not assigned or ready
        end
    end
    local seen,represented={},{ }
    local function observe(builder,target,order,delay)
        if target and (not Own(army,target) or Complete(target) or UnitState.IsPaused(target)) then return end
        local tp=target and target.tp or order and Template(order.tpId)
        if not Power(tp) then return end
        local position=target and type(target.GetPosition)=="function" and target:GetPosition()
            or order and order.positionFloat3
        local key=target or order
        if not key or not Watch(state,key,target,builder,position,now) then return end
        local site=Position(position) and tostring(tp.general and tp.general.tpId or target and target.tpId or order and order.tpId)
            ..":"..position.x..":"..position.z or key
        local record=seen[site]
        if not record then
            record={tier=Tier(tp),output=target and Output(army,tp) or 0,seconds=nil}
            seen[site]=record;result.projects[#result.projects+1]=record
            result.counts[record.tier]=(result.counts[record.tier] or 0)+1
        end
        -- The real foundation can be encountered after a targetless accepted
        -- order for the same site. Supply must not depend on builder iteration.
        if target then record.output=math.max(record.output,Output(army,tp));record.hasTarget=true end
        if not target then record.awaiting=true end
        if target and delay then
            local duration=Duration(army,builder,target,tp)
            local seconds=duration and duration+delay+5
            if seconds and seconds<=MAX_SECONDS and (not record.seconds or seconds<record.seconds) then record.seconds=seconds end
        end
        if builder.platoon then
            represented[builder.platoon]=true
            local mark=builder.platoon.ai and builder.platoon.ai.rushPowerDispatch
            if mark then mark.accepted=true end
        end
    end
    for _,builder in ipairs(builders) do
        local activeTarget=BuildingTarget(builder)
        if Own(army,activeTarget) and not Complete(activeTarget) and Registered(army,builder,activeTarget) then
            observe(builder,activeTarget,nil,0)
        end
        local orders=builder.orders or {};local sequence={}
        if orders.activeOrder then sequence[#sequence+1]=orders.activeOrder end
        for _,order in ipairs(orders.queuedOrders or {}) do sequence[#sequence+1]=order end
        local origin=type(builder.GetPosition)=="function" and builder:GetPosition()
        local speed=Number(builder.tp and builder.tp.movement and builder.tp.movement.speed)
        local delay=0
        for _,order in ipairs(sequence) do
            if order.orderTask==Tasks.MOVE then
                local p=order.positionFloat3
                if delay and Position(origin) and Position(p) and speed>0 then
                    delay=delay+Distance(origin,p)/speed*1.25;origin=p
                else delay=nil end
            elseif order.orderTask==Tasks.BUILD or order.orderTask==Tasks.REPAIR then
                local target=order.unitGettingBuilt or order.targetUnit
                if target and not Own(army,target) then delay=nil
                elseif target and Complete(target) then
                    -- A just-completed order contributes neither output nor work.
                else
                    local p=target and type(target.GetPosition)=="function" and target:GetPosition() or order.positionFloat3
                    local range=Number(builder.construction and builder.construction.range)
                    if delay and Position(origin) and Position(p) and Distance(origin,p)>range then
                        -- Follow the accepted route already queued by the host;
                        -- without it, straight-line travel is not a completion guarantee.
                        delay=nil
                    end
                    observe(builder,target,order,delay)
                    local duration=Duration(army,builder,target,target and target.tp or Template(order.tpId))
                    delay=delay and duration and delay+duration or nil
                end
            else delay=nil end
        end
    end
    for _,p in ipairs(platoons) do
        local mark=p.ai.rushPowerDispatch
        if not represented[p] and available[p] and mark and not mark.accepted
            and mark.armyAI==army.ai and mark.platoonAI==p.ai and mark.epoch==state.epoch
            and Number(mark.at,-math.huge)<=now and now-mark.at<=START_SECONDS then
            result.starting[mark.tier]=(result.starting[mark.tier] or 0)+1
            result.counts[mark.tier]=(result.counts[mark.tier] or 0)+1
        end
    end
    for _,record in ipairs(result.projects) do
        if record.awaiting and not record.hasTarget then
            result.accepted[record.tier]=(result.accepted[record.tier] or 0)+1
        end
    end
    table.sort(result.projects,function(a,b)
        if (a.seconds or math.huge)~=(b.seconds or math.huge) then return (a.seconds or math.huge)<(b.seconds or math.huge) end
        return a.tier<b.tier
    end)
    return result
end
function Count(army,snapshot,tier,forecast)
    local counts=(forecast or Read(army,snapshot)).counts
    if tier then return counts[tier] or 0 end
    local total=0;for _,count in pairs(counts) do total=total+count end
    return total
end
function Covers(army,snapshot,headroom,tier,forecast)
    local e=snapshot and snapshot.energy
    if not e or not army or not army.economy then return false end
    local census=snapshot.globalSnapshot or snapshot
    if census.powerForecastArmy and census.powerForecastArmy~=army then return false end
    local balance=Number(e.balance)-Number(e.reserved)
    local reserve=Number(e.storage)*0.20
    if army.economy.isEnergyDown or Number(e.income)<=0
        or balance<0 and (Number(e.ratio)<0.20 or Number(e.current)+balance*15<=reserve) then return false end
    forecast=forecast or Read(army,snapshot)
    local first=tier and tier>=2
    if first then
        for t=tier,4 do if Number(census.powerComplete and census.powerComplete[t])>0 then first=false;break end end
        if first then
            local sameTier=false
            for t=tier,4 do if Number(forecast.counts[t])>0 then sameTier=true;break end end
            if not sameTier then return false end
        end
    end
    -- A brief startup claim serializes dispatch, not future income. It expires
    -- if the selected coroutine does not publish a real owned construction order.
    for t,n in pairs(forecast.starting) do
        if n>0 and (not tier or t>=tier) and Number(e.current)+balance*START_SECONDS>reserve then return true end
    end
    -- A native BUILD already accepted without its foundation gets a separate
    -- bounded acknowledgement window; it supplies no invented production.
    for t,n in pairs(forecast.accepted) do
        if n>0 and (not tier or t>=tier) and Number(e.current)+balance*ACCEPT_SECONDS>reserve then return true end
    end
    local stored,time,credited=Number(e.current),0,0
    for _,project in ipairs(forecast.projects) do
        if project.seconds and project.output>0 then
            stored=math.min(Number(e.storage),stored+balance*(project.seconds-time))
            if stored<=reserve then return false end
            time=project.seconds;balance=balance+project.output;credited=credited+project.output
            if credited>0 and balance>=math.max(0,Number(headroom)) then return true end
        end
    end
    return false
end
