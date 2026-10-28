-- RC22 SCOM adaptation of Balance Rules. State predicates, not build timers.
-- Costs, construction power, faction menus and host availability remain native.
Version = "9.0.22-rc26"
Config = { PrimaryStrength=80, AirStrength=70, RaidStrength=70,
    RaidMinimum=3, RaidMaximum=10, RaidInstances=6, RaidMainShare=0.5,
    RaidGroundMinimum=20, OpeningLandFactories=6, TechLandFactories=3,
    TechGroundUnits=10, OpeningFighters=2, FighterMinimum=6,
    HighEnergy=0.75, CapacityEnergy=0.20, HomeExtractors=4,
    CombatShare=0.75, HeavyShare=0.30 }
local Availability=Import("common/units/availableUnits.lua").AvailableUnits
local Snapshot, Reliability, InvestmentReserve, CommanderReserve, HeavyReserve, FirstExperimentalPolicy, FabricationPolicy
local factions={"EDA","CHOSEN","GUARD","SERAPHIM"}
function Configure(snapshot,reserve,commanderReserve,heavyReserve)
    Snapshot=snapshot;InvestmentReserve=reserve;CommanderReserve=commanderReserve;HeavyReserve=heavyReserve
end
local function Number(v,default)
    if type(v)=="number" and v==v and math.abs(v)<math.huge then return v end
    return default or 0
end
function Has(tp,tag)
    if not tp then return false end
    if tp.hasTags and tp.hasTags[tag] then return true end
    for _,t in ipairs(tp.tags or {}) do if t==tag then return true end end
    return false
end
function Tier(tp)
    for t=4,1,-1 do if Has(tp,"TECH"..t) then return t end end
    return Number(tp and tp.general and tp.general.techNumber,1)
end
function Own(a,u)
    return a and u and not u.dead and not u.deleted and u.army==a and u.id
        and a.units and a.units[u.id.index]==u and not u.CaptureInProgress and not u.ReclaimInProgress
end
function Enabled(a)
    local s=a and a.ai and a.ai.settings
    if not s then return false end
    local d=tostring(s.modDirectory or ""):gsub("\\","/"):gsub("/+$","")
    return d=="AI/mods/AI-Scom" or d:sub(-#"/AI-Scom")=="/AI-Scom"
        or d=="" and s.modName=="AI-Scom"
end
function Ready(index,base)
    local a=Armies and Armies[index]
    return a and a.ai and a.ai.isAlive~=false and a.ai.bases and a.ai.bases[base]~=nil or false
end
local function Template(id) return __Templates and __Templates.Units and __Templates.Units[id] end
local function Complete(u) return type(u.IsCompleted)=="function" and u:IsCompleted() end
local function Power(tp) return Has(tp,"STRUCTURE") and Has(tp,"ENERGY_PRODUCTION") and not Has(tp,"ALLOYS_EXTRACTION") end
local function Busy(u)
    local o=u.orders
    return u.platoon or u.unitBeingBuilt or u.upgradeTarget or u.buildBehaviorIsActive
        or u.buildQueue and next(u.buildQueue) or o and (o.activeOrder or o.queuedOrders and next(o.queuedOrders))
end
function Balance(r) return Number(r and r.balance)-Number(r and r.reserved) end
function ProjectRates(u,id)
    local tp=Template(id);local e=tp and tp.economy;local c=e and e.cost
    local construction=u and (u.construction or u.tp and u.tp.construction)
    local bp=construction and construction.buildPower
    if not c or Number(e.buildTime)<=0 or Number(bp)<=0 then return nil end
    local mass,energy=Number(c.alloys or 0,-1),Number(c.energy or 0,-1)
    if mass<0 or energy<0 then return nil end
    local duration=e.buildTime/bp
    return mass/duration,energy/duration,duration
end
-- Credit only the registered builder's actual native request. Adjacency is
-- captured on the resource source, and availability scaling affects outcome,
-- not requested demand. A missing registration cannot finance another job.
-- Completed targets are creditable only through their exact registered repairer.
function RegisteredBuildRates(u,repairTarget)
    local a=u and u.army;local target=repairTarget or u and u.unitBeingBuilt
    local repairing=repairTarget~=nil and u and u.unitBeingRepaired==repairTarget
    if not Own(a,u) or not Own(a,target) or repairTarget~=nil and not repairing
        or Complete(target) and not repairing
        or type(u.GetPause)=="function" and u:GetPause()
        or u.toggles and u.toggles.Pause then return 0,0,0 end
    local entity=target.resourceEntities and target.resourceEntities.construction
    local economy=entity and entity.economy
    local source=entity and entity.buildPowerSources and entity.buildPowerSources[u.id]
    local cost=entity and entity.originalCost
    local duration=entity and Number(entity.originalBuildTime)
    local power=source and Number(source.buildPower)
    local multiplier=entity and Number(entity.userMultiplier)
    if not entity or entity.enabled~=true or entity.category~="construction"
        or entity.unitId~=target.id or entity.armyId~=a.id
        or not economy or economy~=a.economy or economy.armyId~=a.id
        or not economy.resourceEntities or not economy.resourceEntities.construction
        or economy.resourceEntities.construction[entity.id]~=entity
        or not source or type(cost)~="table"
        or not duration or duration<=0 or not power or power<=0
        or not multiplier or multiplier<=0 then return 0,0,0 end
    local tick=Constants and Constants.TickRate or 10
    local function request(name)
        local discount=source.discount and source.discount[name]
        if discount==nil then discount=1 end
        discount=Number(discount,-1)
        local amount=Number(cost[name],-1)
        if discount<0 or amount<0 then return 0 end
        local own=amount*power/duration*discount*multiplier
        local total=math.max(0,Number(entity.outcome and entity.outcome[name]))*tick*multiplier
        return math.min(own,total)
    end
    return request("alloys"),request("energy"),power
end

-- Read reservations exactly once per requested budget. A live construction
-- target is already included in native requests; an approach reserve is not.
function Resources(a,except)
    local totals=a and a.economy and a.economy.totals;local tick=Constants and Constants.TickRate or 10
    if not totals then return nil end
    local nativeTick=type(Tick)=="number" and Tick==Tick and Tick>=0 and Tick<math.huge and Tick or nil
    local sample={tick=nativeTick,seconds=GetGameTimeSeconds()}
    local result={}
    for _,name in ipairs({"alloys","energy"}) do
        local r=totals[name]
        if not r or Number(r.income,-1)<0 or Number(r.request,-1)<0
            or Number(r.current,-1)<0 or Number(r.storage,-1)<0 then return nil end
        result[name]={income=r.income*tick,request=r.request*tick,current=r.current,
            storage=r.storage,ratio=r.storage>0 and r.current/r.storage or 0,
            balance=(r.income-r.request)*tick,reserved=0,commanderReserved=0,
            commanderOwner=nil,commanderId=nil,commanderSample=sample}
    end
    local fabricationSeen={}
    for index,r in pairs(a.ai.ecoReserve or {}) do
        local owner=a.units[index]
        if owner~=except and Own(a,owner) then
            local service=r.rushCommanderService
            local data=owner.platoon and owner.platoon.ai
            local serviceOwned=service and data and data.rushCommanderService==service
                and service.reservation==r and service.order and owner.orders
            if serviceOwned then
                serviceOwned=owner.orders.activeOrder==service.order
                if not serviceOwned then
                    for _,order in pairs(owner.orders.queuedOrders or {}) do
                        if order==service.order then serviceOwned=true;break end
                    end
                end
            end
            -- Serial queues reserve their largest rate, never the sum of jobs
            -- that cannot run together. Credit only this owner's registered beam.
            local construction,production=r.rushConstructionQueue,r.rushProductionQueue
            local serial=construction or production
            local serialOwned=serial and serial.reservation==r and owner.ai==serial.unitAI
                and owner.platoon==serial.platoon and data==serial.platoonAI
                and a==serial.army and a.ai==serial.armyAI
            if serialOwned and construction then
                serialOwned=owner==serial.unit and owner.ai.rushConstructionQueue==serial
                    and data.rushConstructionQueue==serial.queue
                local orders=owner.orders or {}
                if serialOwned and orders.activeOrder and not serial.orders[orders.activeOrder] then serialOwned=false end
                if serialOwned then
                    for _,order in pairs(orders.queuedOrders or {}) do
                        if not serial.orders[order] then serialOwned=false;break end
                    end
                end
            elseif serialOwned then
                serialOwned=owner==serial.factory and owner.ai.rushProductionQueue==serial
                    and owner.buildQueue==serial.queue
            end
            if serialOwned and construction then
                local tp=Template(r.tpId)
                local queue=construction.queue
                local head=construction.reservedEntry
                local target=head and head.target
                local maintenance=tp and tp.economy and tp.economy.maintenanceConsumption
                local upkeep=math.max(0,Number(maintenance and maintenance.energy))
                -- Construction requests exclude the completed fabricator's
                -- future upkeep. Charge that same owned serial project once,
                -- without adding another army scan to this shared ledger.
                if queue and not fabricationSeen[queue] and upkeep>0
                    and not (Own(a,target) and Complete(target)) then
                    FabricationPolicy=FabricationPolicy or Import("AI/mods/AI-Scom/RushMassFabrication.lua")
                    if FabricationPolicy.IsFabricator(tp) then
                        fabricationSeen[queue]=true
                        result.energy.reserved=result.energy.reserved+upkeep
                        result.energy.fabricationReserved=Number(result.energy.fabricationReserved)+upkeep
                    end
                end
            end
            if serialOwned then
                local mass,energy=0,0
                local target=owner.unitBeingBuilt
                if Own(a,target) and not Complete(target)
                    and (not production or owner.productionBehaviorIsActive and not owner.upgradeBehaviorIsActive) then
                    mass,energy=RegisteredBuildRates(owner)
                end
                result.alloys.reserved=result.alloys.reserved+math.max(0,Number(r.resourcePerSecond)-Number(mass))
                result.energy.reserved=result.energy.reserved+math.max(0,Number(r.energyPerSecond)-Number(energy))
            -- Service rows already contain only ACU/pod power not drawing resources.
            elseif not serial and (serviceOwned or not service and not owner.unitBeingBuilt and not owner.upgradeTarget) then
                result.alloys.reserved=result.alloys.reserved+math.max(0,Number(r.resourcePerSecond))
                result.energy.reserved=result.energy.reserved+math.max(0,Number(r.energyPerSecond))
            end
        end
    end
    -- Dispatch precedes the native production reservation. Every consumer uses
    -- this same commitment ledger, including assists, upgrades and new sites.
    local pending=a.ai.rushController and a.ai.rushController.pending
    if pending and next(pending) then
        Reliability=Reliability or Import("AI/mods/AI-Scom/RushReliability.lua")
        local now=GetGameTimeSeconds()
        for index,order in pairs(pending) do
            local owner=a.units[index]
            local reserve=a.ai.ecoReserve and a.ai.ecoReserve[index]
            if owner~=except and Own(a,owner) and owner==order.factory and now<=order.expires
                and not Reliability.Working(owner) and (not reserve or reserve.tpId~=order.id) then
                local mass,energy=ProjectRates(owner,order.id)
                if mass then
                    result.alloys.reserved=result.alloys.reserved+mass
                    result.energy.reserved=result.energy.reserved+energy
                end
            end
        end
    end
    if InvestmentReserve then
        local mass,energy,owner,id=InvestmentReserve(a,except)
        for _,entry in ipairs({{result.alloys,mass},{result.energy,energy}}) do
            local resource=entry[1]
            resource.techReserved=math.max(0,Number(entry[2]))
            resource.techOwner,resource.techId=owner,id
            resource.reserved=resource.reserved+resource.techReserved
        end
    end
    if CommanderReserve then
        local mass,energy,owner,id=CommanderReserve(a,except,sample)
        for _,entry in ipairs({{result.alloys,mass},{result.energy,energy}}) do
            local resource=entry[1]
            resource.commanderReserved=math.max(0,Number(entry[2]))
            resource.commanderOwner,resource.commanderId=owner,id
            resource.reserved=resource.reserved+resource.commanderReserved
        end
    end
    if HeavyReserve then
        local mass,energy,owner,id=HeavyReserve(a,except)
        for _,entry in ipairs({{result.alloys,mass},{result.energy,energy}}) do
            local resource=entry[1]
            resource.heavyReserved=math.max(0,Number(entry[2]))
            resource.heavyOwner,resource.heavyId=owner,id
            resource.reserved=resource.reserved+resource.heavyReserved
        end
    end
    FirstExperimentalPolicy=FirstExperimentalPolicy or Import("AI/mods/AI-Scom/RushHeavyPolicy.lua")
    local firstMass,firstEnergy=FirstExperimentalPolicy.FirstAssistReserved(a,except)
    result.alloys.reserved=result.alloys.reserved+firstMass
    result.energy.reserved=result.energy.reserved+firstEnergy
    return result.alloys,result.energy
end
-- A commitment can be selected, or its owned queue trimmed, after this census
-- was sampled. Replace only its recorded share; preserve all other commitments.
function RefreshInvestment(a,s)
    if not s or not s.alloy or not s.energy then return end
    if InvestmentReserve then
        local mass,energy,owner,id=InvestmentReserve(a)
        for _,entry in ipairs({{s.alloy,mass},{s.energy,energy}}) do
            local resource=entry[1]
            local amount=math.max(0,Number(entry[2]))
            resource.reserved=math.max(0,Number(resource.reserved)-Number(resource.techReserved))+amount
            resource.techReserved=amount
            resource.techOwner,resource.techId=owner,id
        end
    end
    local mass,energy,owner,id
    if CommanderReserve then mass,energy,owner,id=CommanderReserve(a,nil,s.alloy.commanderSample) end
    for _,entry in ipairs({{s.alloy,mass},{s.energy,energy}}) do
        local resource=entry[1]
        local amount=math.max(0,Number(entry[2]))
        resource.reserved=math.max(0,Number(resource.reserved)-Number(resource.commanderReserved))+amount
        resource.commanderReserved=amount
        resource.commanderOwner,resource.commanderId=owner,id
    end
    mass,energy,owner,id=nil,nil,nil,nil
    if HeavyReserve then mass,energy,owner,id=HeavyReserve(a) end
    for _,entry in ipairs({{s.alloy,mass},{s.energy,energy}}) do
        local resource=entry[1]
        local amount=math.max(0,Number(entry[2]))
        resource.reserved=math.max(0,Number(resource.reserved)-Number(resource.heavyReserved))+amount
        resource.heavyReserved=amount
        resource.heavyOwner,resource.heavyId=owner,id
    end
end
function CanBuild(u,id)
    local tp=Template(id);local a=u and u.army
    if not Own(a,u) or not tp or Availability[id]~=true or not Has(tp,factions[a.faction])
        or not buildQueueUtils or type(buildQueueUtils.CanBuild)~="function" then return false end
    local ok,allowed=pcall(buildQueueUtils.CanBuild,u,id,1,false)
    return ok and allowed==true
end
function Affordable(u,id)
    local mr,er=ProjectRates(u,id)
    if not mr then return false end
    local a,e=Resources(u.army,u)
    return a and Balance(a)>=mr and Balance(e)>=er or false
end
function StoredCost(u,id)
    local mr=ProjectRates(u,id);local tp=Template(id)
    if not mr then return false end
    local a,e=Resources(u.army,u)
    return a and a.current>=tp.economy.cost.alloys and e.current>=tp.economy.cost.energy or false
end
function FactoryDomain(tp)
    if not Has(tp,"STRUCTURE") or not Has(tp,"FACTORY") then return nil end
    if Has(tp,"NAVAL_FACTORY") then return "naval" end
    if Has(tp,"AIR_FACTORY") then return "air" end
    if Has(tp,"LAND_FACTORY") then return "land" end
end
function FormerKind(f)
    local domain,power,tier
    for _,line in ipairs(f.WantStructures or {}) do
        for id,on in pairs(line) do
            local tp=on and Template(id)
            if tp then
                if Power(tp) then power=true;tier=math.max(tier or 0,Tier(tp)) end
                domain=domain or FactoryDomain(tp)
            end
        end
    end
    return domain,power and tier or nil
end
function InitSnapshot(s)
    s.powerComplete={};s.powerPending={};s.engineersByTier={};s.landFactoryTiers={}
    s.factoryPending={land=0,air=0,naval=0};s.balanceEngineers={};s.balanceProjects={}
    s.productAlloyRate=0;s.productEnergyRate=0
end
function ObserveUnit(s,u)
    local tp,t,complete=u.tp,Tier(u.tp),Complete(u)
    if Power(tp) then
        local field=complete and s.powerComplete or s.powerPending
        field[t]=(field[t] or 0)+1
    end
    local d=FactoryDomain(tp)
    if d then
        if not complete then s.factoryPending[d]=s.factoryPending[d]+1
        elseif d=="land" then s.landFactoryTiers[t]=(s.landFactoryTiers[t] or 0)+1 end
        local target=u.unitBeingBuilt or u.productionBehaviorTargetUnit
        local id=target and target.tpId or u.buildQueue and u.buildQueue[1] and u.buildQueue[1].tpId
        if id and Has(Template(id),"MOBILE") and not Has(Template(id),"ENGINEER") then
            local mr,er=ProjectRates(u,id)
            if mr then s.productAlloyRate=s.productAlloyRate+mr;s.productEnergyRate=s.productEnergyRate+er end
        end
    end
    if complete and Has(tp,"ENGINEER") and Has(tp,"MOBILE") and not Has(tp,"COMMAND") and t<=3
        and not u.scoCommanderPodOwner and not u.scoSourcePodOwner then
        s.engineersByTier[t]=(s.engineersByTier[t] or 0)+1
        if not Busy(u) and not (u.toggles and u.toggles.Pause) then s.balanceEngineers[#s.balanceEngineers+1]=u end
    end
end
function ObserveReservation(s,u,reserve)
    -- Assistance and repair fund an existing unit, never another foundation.
    if reserve.rushCommanderService or reserve.rushConstructionQueue or reserve.rushProductionQueue
        or u.unitBeingBuilt or u.upgradeTarget then return end
    local id=reserve.tpId;local tp=Template(id)
    if not tp then return end
    -- Some queues expose their placement target before unitBeingBuilt. Do not
    -- count that same foundation again as a speculative project.
    local order=u.orders and u.orders.activeOrder
    local target=order and order.unitGettingBuilt or u.buildBehaviorActualUnit
    if target and Own(u.army,target) and target.tpId==id then return end
    if s.balanceProjects[u] then return end;s.balanceProjects[u]=true
    if Power(tp) then local t=Tier(tp);s.powerPending[t]=(s.powerPending[t] or 0)+1 end
    local d=FactoryDomain(tp)
    if d then s.factoryPending[d]=s.factoryPending[d]+1 end
end
function PowerSurplusDuringAlloyShortage(s)
    local a,e=s.alloy,s.energy
    return a and e and Number(a.ratio)<0.20 and Number(e.ratio)>=Config.HighEnergy
        and Balance(e)>=0 or false
end
function FirstPowerTier(s)
    local power=s.powerComplete or {};local engineers=s.engineersByTier or {}
    -- Do not reserve an advanced engineer for a generator while stored
    -- energy is full and rising, especially when alloy is depleted.
    if not s.techPowerNeeded and PowerSurplusDuringAlloyShortage(s) then return nil end
    local e=s.energy
    if not s.techPowerNeeded and e and Number(e.ratio)>=Config.HighEnergy
        and Balance(e)>=math.max(40,Number(e.income)*0.15) then return nil end
    if Number(engineers[3])>0 and Number(power[3])==0 then return 3 end
    if Number(engineers[2])>0 and Number(power[2])+Number(power[3])==0 then return 2 end
end
function FinishSnapshot(s)
    s.firstPowerTier=FirstPowerTier(s)
    if s.productAlloyRate>0 then s.productionEnergyPerAlloy=s.productEnergyRate/s.productAlloyRate end
    table.sort(s.balanceEngineers,function(a,b) return a.id.index<b.id.index end)
end
-- Protect one idle, legal advanced power builder, not every advanced engineer.
-- Existing assignments and paid work are never seized by this rule.
function PowerBuilderMaximum(a,f,maximum)
    local _,tier=FormerKind(f)
    local s=tier and Snapshot and Snapshot(a)
    if s and tier>=2 and tier==FirstPowerTier(s) and Number(s.powerPending[tier])==0 then
        return math.min(maximum,1)
    end
    return maximum
end
function ProtectedPowerBuilder(a,f)
    if not Snapshot or not Enabled(a) then return nil end
    local s=Snapshot(a);local t=FirstPowerTier(s)
    if not t or Number(s.powerPending and s.powerPending[t])>0 then return nil end
    local _,ft=FormerKind(f)
    if ft and ft>=t then return nil end
    s.powerTemplateIds=s.powerTemplateIds or {}
    local ids=s.powerTemplateIds[t]
    if not ids then
        ids={};s.powerTemplateIds[t]=ids
        for id,tp in pairs(__Templates.Units) do
            if Power(tp) and Tier(tp)==t and Availability[id]==true and Has(tp,factions[a.faction]) then ids[#ids+1]=id end
        end
        table.sort(ids)
    end
    for _,u in ipairs(s.balanceEngineers or {}) do
        local base=u.assignedToBase and a.ai.bases and a.ai.bases[u.assignedToBase]
        if Own(a,u) and Complete(u) and not Busy(u) and Tier(u.tp)>=t
            and base and base.baseType~="NAVAL" and base.position and Number(base.radius)>0
            and not (u.ai and (u.ai.eState=="RepairHome" or u.ai.rushBuilderRecall)) then
            local pos=u:GetPosition()
            if (pos.x-base.position.x)^2+(pos.z-base.position.z)^2<=base.radius^2 then
                for _,id in ipairs(ids) do if CanBuild(u,id) then return u end end
            end
        end
    end
end
function HomeUpgradeCandidates(a,units)
    if not Enabled(a) or a.ai.settings.difficulty~="hard" then return units end
    local base=a.ai.bases and a.ai.bases.MAIN
    if not base or not base.position then return units end
    local ranked={};local center=base.position;local radius=Number(base.radius,60)
    for _,u in pairs(a.units or {}) do
        if Own(a,u) and Complete(u) and Has(u.tp,"ALLOYS_EXTRACTION") then
            local p=u:GetPosition();local d=(p.x-center.x)^2+(p.z-center.z)^2
            u.rangeToBase=d -- native upgrade diagnostics/selection read this field
            ranked[#ranked+1]={unit=u,distance=d,home=d<=radius^2,tier=Tier(u.tp)}
        end
    end
    table.sort(ranked,function(x,y)
        if x.home~=y.home then return x.home end
        return x.distance==y.distance and x.unit.id.index<y.unit.id.index or x.distance<y.distance
    end)
    for i,r in ipairs(ranked) do
        -- The nearest four retain their T2-then-T3 priority. Home growth and
        -- remote rollout remain candidates when a preferred step cannot start.
        r.priority=(r.home and (i<=Config.HomeExtractors and 0 or 2) or 4)+math.min(3,r.tier)
    end
    table.sort(ranked,function(x,y)
        if x.priority~=y.priority then return x.priority<y.priority end
        return x.distance==y.distance and x.unit.id.index<y.unit.id.index or x.distance<y.distance
    end)
    local result,eligible={},{}
    for _,u in ipairs(units or {}) do
        if not Has(u.tp,"ALLOYS_EXTRACTION") then result[#result+1]=u
        else eligible[u]=true end
    end
    for _,r in ipairs(ranked) do
        if eligible[r.unit] then result[#result+1]=r.unit end
    end
    return result
end
-- The RC21 army uses primary + independently operating task forces, not the
-- historical monolithic primary. Count all valid non-raiding main-force units;
-- cap the combined legacy Hunter and Alloy Pressure pool against that force.
function RaidAllocation(a)
    local main,raids,groups,primary=0,0,0,0
    for _,p in pairs(a.platoons or {}) do
        local ai=p.ai;local f=ai and ai.formerTable
        if f and not p.dead and not p.deleted and ai.eState~="Disband" and a:PlatoonExists(p) then
            local raid=f.RushRaider or f.FormerName=="F123 Land Alloy Hunter"
            local force=raid or (f.AIPlanData and f.AIPlanData.RushCombatPolicy) or f.FormerName=="F123 Land Sup ratio"
            local n=0
            if force then
                for _,u in pairs(p:GetUnits()) do
                    if Own(a,u) and u.platoon==p and Complete(u) and Has(u.tp,"LAND") and Has(u.tp,"MOBILE")
                        and not Has(u.tp,"COMMAND") and not Has(u.tp,"ENGINEER") and not Has(u.tp,"TECH4")
                        and not (u.ai and u.ai.eState=="RepairHome") then n=n+1 end
                end
                if raid then raids=raids+n;if n>0 then groups=groups+1 end
                else main=main+n end
                if f.FormerName=="F123 Land Primary" then primary=primary+n end
            end
        end
    end
    return main,raids,groups,primary
end
function CanDispatchRaid(a,s)
    if Number(s.groundReady)<Config.RaidGroundMinimum then return false end
    local main,raids,groups,primary=RaidAllocation(a)
    return primary>0 and main>=Config.RaidMinimum and groups<Config.RaidInstances and raids<main*Config.RaidMainShare
end
function FighterBudget(s,mr,er,panic)
    if panic then return true end
    local a,e=s.alloy,s.energy
    if not a or not e then return false end
    -- Native requests include other commitments. No exemption for a proactive
    -- minimum: both income share and the ordinary product funding test apply.
    return Number(s.productAlloyRate)+mr<=a.income*Config.CombatShare
        and Balance(e)+math.max(0,e.current-e.storage*0.08)/12>=er
end
function CapacityAffordable(u,id)
    local mr,er,duration=ProjectRates(u,id)
    if not mr or not Own(u and u.army,u) or not FactoryDomain(Template(id)) then return false end
    local a,e=Resources(u.army,u)
    return a and a.income>0 and e.income>0
        and Balance(a)+math.max(0,a.current-a.storage*0.30)/duration>=mr
        and Balance(e)+math.max(0,e.current-e.storage*0.30)/duration>=er or false
end
local function ProtectTechFromConstruction(f,s,powerTier)
    -- Targeted point defense always pays its native rate from real surplus or
    -- bank above the 15% reserve, including during an unrelated global panic.
    if f.RushGroundDefense or f.RushAdjacencyStorage or f.RushMassFabrication or f.RushBeachhead
        or f.RushEmergencyShield then return true end
    if not (s.alloy and (s.alloy.techOwner or s.alloy.commanderOwner or s.alloy.heavyOwner))
        and Number(s.upgrades)==0 then return false end
    -- Power and extractor expansion establish the income needed by technology;
    -- local emergency defenses retain their existing native funding policy.
    if powerTier or f.RushTechProject or f.AIPlan=="planEngineerCapAlloySpot"
        or f.AIPlan=="planAlloyExtractorUpgrade" then return false end
    if s.landPanic and f.RushBaseDefense=="ground" then return false end
    if (s.airPanic or s.airRaid) and (f.RushBaseDefense=="air" or f.RushAirDefense) then return false end
    return f.NeedUpgradeableUnit~=nil or f.NeedMobileBuilder~=nil and f.WantStructures~=nil
end
function ConstructionNeedsTechBudget(a,f)
    local s=Snapshot and Snapshot(a)
    if not s then return f and f.RushGroundDefense~=nil or false end
    RefreshInvestment(a,s)
    local _,powerTier=FormerKind(f)
    return ProtectTechFromConstruction(f,s,powerTier)
end
local function ProtectedProjectAffordable(u,id)
    local mass,energy,duration=ProjectRates(u,id)
    if not mass then return false end
    local a,e=Resources(u.army,u)
    return a and a.income>0 and e.income>0
        and Balance(a)+math.max(0,a.current-a.storage*0.15)/duration>=mass
        and Balance(e)+math.max(0,e.current-e.storage*0.15)/duration>=energy or false
end
-- Idle source ranking may reuse its census. Selection and actual admission
-- omit that view and price the chosen native builder against live reservations.
function CanFundGroundDefense(u,id,snapshot)
    local army=u and u.army
    if not Own(army,u) or u.CaptureInProgress or u.ReclaimInProgress then return false end
    Reliability=Reliability or Import("AI/mods/AI-Scom/RushReliability.lua")
    if not Reliability.AllowedTarget(id,false) or not Reliability.CanBuilderBuild(u,id) then return false end
    local mass,energy,duration=ProjectRates(u,id)
    if not mass then return false end
    local a,e
    if snapshot then
        if Busy(u) then return false end
        a,e=snapshot.alloy,snapshot.energy
    else a,e=Resources(army,u) end
    return a and e and a.income>0 and e.income>0
        and Balance(a)+math.max(0,a.current-a.storage*0.15)/duration>=mass
        and Balance(e)+math.max(0,e.current-e.storage*0.15)/duration>=energy or false
end
-- Storage uses exact native prices and rates. One bounded supply-limited
-- investment may proceed when ordinary production consumes the spare income.
function CanFundAdjacencyStorage(u,id,snapshot)
    local army=u and u.army
    if not Own(army,u) then return false end
    local layout=Import("AI/mods/AI-Scom/RushBaseLayout.lua")
    if not layout.StorageKind(Template(id)) then return false end
    Reliability=Reliability or Import("AI/mods/AI-Scom/RushReliability.lua")
    if not Reliability.AllowedTarget(id,false) or not Reliability.CanBuilderBuild(u,id) then return false end
    local mass,energy,duration=ProjectRates(u,id)
    if not mass then return false end
    local a,e
    if snapshot then
        if Busy(u) then return false end
        a,e=snapshot.alloy,snapshot.energy
    else a,e=Resources(army,u) end
    if not a or not e or a.income<=0 or e.income<=0 then return false end
    local massBank=math.max(0,a.current-a.storage*0.15)/duration
    local energyBank=math.max(0,e.current-e.storage*0.15)/duration
    if Balance(a)+massBank>=mass and Balance(e)+energyBank>=energy then return true end
    -- One finite storage investment can proceed while cheap army production
    -- consumes the surplus. Keep native rates in its real queue reservation;
    -- this allowance never changes prices or interrupts a paid factory unit.
    local s=snapshot or CurrentSnapshot(army,false)
    local economy=Import("AI/mods/AI-Scom/RushEconomyPolicy.lua")
    if not s or a.techOwner or a.heavyOwner or Number(s.upgrades)>0 or army.economy.isEnergyDown
        or not layout.StorageBudgetOpen(army,u)
        or economy.LandEnabled(army) and economy.GroundStrength(s)<Config.TechGroundUnits then return false end
    if a.request+a.reserved>a.income*2 or e.request+e.reserved>e.income*1.5 then return false end
    -- Rearranged income-plus-bank coverage at 20 percent of the native rate.
    -- A larger builder must still have a supportable finite project horizon.
    return a.income*0.20>=math.max(0,mass-massBank)*0.20
        and e.income*0.15>=math.max(0,energy-energyBank)*0.20
end
function UpgradePreservesTechBudget(u,id)
    if not Own(u and u.army,u) then return false end
    local s=Snapshot and Snapshot(u.army)
    local a=Resources(u.army,u)
    if not a then return false end
    if not a.techOwner and not a.commanderOwner and not a.heavyOwner and Number(s and s.upgrades)==0 then return true end
    return id~=nil and ProtectedProjectAffordable(u,id)
end
function ConstructionBudget(a,base,f,s,AF)
    local domain,powerTier=FormerKind(f)
    RefreshInvestment(a,s)
    local protected=ProtectTechFromConstruction(f,s,powerTier)
    local funded=f.RushStoredCost==true or domain=="land" and Number(s.landFactories)==1
    if not funded and not f.RushCapacityDomain and not protected then return true end
    local shieldLayout=f.RushEmergencyShield and Import("AI/mods/AI-Scom/RushBaseLayout.lua")
    local groundLayout=f.RushGroundDefense and Import("AI/mods/AI-Scom/RushBaseLayout.lua")
    local storageLayout=f.RushAdjacencyStorage and Import("AI/mods/AI-Scom/RushBaseLayout.lua")
    local fabrication=f.RushMassFabrication and Import("AI/mods/AI-Scom/RushMassFabrication.lua")
    local beachhead=f.RushBeachhead and Import("AI/mods/AI-Scom/RushBeachhead.lua")
    local units
    if f.NeedUpgradeableUnit then units=AF.GetNeedUpgradeableUnit(a.id,base,f)
    else units=AF.GetNeedMobileBuilder(a.id,base,f) end
    if not units then return false end
    for _,u in ipairs(units) do
        if Own(a,u) then
            if f.NeedUpgradeableUnit then
                local id=type(u.GetUpgradeTpId)=="function" and u:GetUpgradeTpId() or u.tp.construction and u.tp.construction.upgradesTo
                if id and CanBuild(u,id) and (not funded or StoredCost(u,id))
                    and (not protected or ProtectedProjectAffordable(u,id)) then return true end
            else
                local totalA,totalE,valid=0,0,true
                for _,line in ipairs(f.WantStructures or {}) do
                    local best
                    for id,on in pairs(line) do
                        local tp=on and Template(id)
                        local affordable
                        if shieldLayout then
                            affordable=tp and shieldLayout.IsEmergencyShieldTemplate(tp)
                                and shieldLayout.CanFundEmergencyShield(u,id)
                        elseif groundLayout then
                            affordable=tp and groundLayout.IsGroundDefenseTemplate(tp,f.RushGroundDefense)
                                and CanFundGroundDefense(u,id)
                        elseif storageLayout then
                            affordable=tp and storageLayout.StorageKind(tp)==f.RushAdjacencyStorage
                                and CanFundAdjacencyStorage(u,id)
                        elseif fabrication then
                            affordable=tp and fabrication.IsFabricator(tp) and fabrication.CanFund(u,id,s)
                        elseif beachhead then affordable=tp and beachhead.CanFund(u,id)
                        else
                            affordable=tp and CanBuild(u,id) and ProjectRates(u,id)
                                and (not f.RushCapacityDomain or CapacityAffordable(u,id))
                                and (not protected or ProtectedProjectAffordable(u,id))
                        end
                        if affordable and (not best or tp.economy.cost.alloys<best.economy.cost.alloys) then best=tp end
                    end
                    if not best then valid=false;break end
                    totalA=totalA+best.economy.cost.alloys;totalE=totalE+best.economy.cost.energy
                end
                local ca,ce=Resources(a,u)
                if valid and totalA>0 and ca and (not funded or ca.current>=totalA and ce.current>=totalE) then return true end
            end
        end
    end
    return false
end

function CurrentSnapshot(a,force) return Snapshot and Snapshot(a,force~=false) end
function EarlyExpansionRequired(index,baseName)
    local a=Armies[index]
    if not a or not a.ai then return false end
    for _,p in pairs(a.platoons or {}) do
        local ai=p.ai;local f=ai and ai.formerTable
        if f and ai.baseName==baseName and not p.dead and ai.eState~="Disband" and a:PlatoonExists(p)
            and (f.FormerName=="B1 Cap Alloys Range 30-1500" or f.RushPersistentExpansion) then
            for _,u in pairs(p:GetUnits()) do
                if Own(a,u) and Complete(u) and u.platoon==p and Has(u.tp,"ENGINEER")
                    and not (u.ai and u.ai.eState=="Disband") then return false end
            end
        end
    end
    return true
end

function HeavyReady(a,s)
    if not s or not s.alloy or not s.energy or s.landPanic or s.airPanic or s.navalPanic
        or FirstPowerTier(s) or a.economy.isEnergyDown then return false end
    local layer=a.ai.settings.useLayer
    if not s.landDisconnected and (not layer or layer.land~=false) then
        local economy=Import("AI/mods/AI-Scom/RushEconomyPolicy.lua")
        -- Advanced fighting strength can establish readiness without requiring
        -- six opening factories or twenty cheap units in every developed army.
        if Number(s.landFactories)<Config.TechLandFactories
            or economy.GroundReady(s)<math.max(8,economy.GroundFloor(s))
            or economy.GroundStrength(s)<20 then return false end
    end
    return s.alloy.income>0 and s.energy.income>0 and s.energy.ratio>=0.25
end
-- Quote one actual engineer's native rate before its finite funding window.
-- Readiness is shared; a quote never treats prospective income as available.
function HeavyInvestmentBudget(a,u,id,snapshot)
    local s=snapshot or Snapshot and Snapshot(a,true)
    if not HeavyReady(a,s) or not Own(a,u) or not Complete(u)
        or type(u.GetPause)=="function" and u:GetPause() then return nil end
    Reliability=Reliability or Import("AI/mods/AI-Scom/RushReliability.lua")
    if not Reliability.AllowedTarget(id,true) or not Reliability.CanBuilderBuild(u,id) then return nil end
    local mr,er,duration=ProjectRates(u,id);local m,e=Resources(a,u)
    if not mr or not m or not e or m.income<=0 or e.income<=0 or e.ratio<0.25 then return nil end
    local horizon=math.max(30,math.min(120,duration))
    local function possible(resource,rate)
        local bank=math.max(0,resource.current-resource.storage*0.20)/horizon
        local other=Number(resource.techReserved)+Number(resource.commanderReserved)
        -- Pending development shares must leave room for ordinary production;
        -- paid native work is still counted by the actual start check below.
        return rate<=resource.income*Config.HeavyShare+bank
            and rate+other<=resource.income*0.60+bank
    end
    if not possible(m,mr) or not possible(e,er) then return nil end
    local function fund(resource,rate)
        local bank=math.max(0,resource.current-resource.storage*0.20)/horizon
        return Balance(resource)+bank>=rate
    end
    return {mass=mr,energy=er,duration=duration,horizon=horizon,ready=fund(m,mr) and fund(e,er)}
end
function HeavyBuildBudget(a,u,id,snapshot)
    local budget=HeavyInvestmentBudget(a,u,id,snapshot)
    return budget and budget.ready or false
end
function HeavyBuildPower(a,id,currentPower)
    local tp=Template(id);local m,e=Resources(a)
    if not tp or not m then return 0 end
    local cost=tp.economy and tp.economy.cost;local bt=tp.economy and tp.economy.buildTime
    if not cost or Number(bt)<=0 or Number(cost.alloys)<=0 or Number(cost.energy)<=0 then return 0 end
    -- Current builders are already in requests. Fund only additions from the
    -- remaining budget; a storage/income fall never destroys the paid foundation.
    local prior=math.max(0,Number(currentPower))
    local am=math.max(0,math.min(m.income*Config.HeavyShare,Balance(m)+prior*cost.alloys/bt))
    local ae=math.max(0,math.min(e.income*Config.HeavyShare,Balance(e)+prior*cost.energy/bt))
    return math.min(am*bt/cost.alloys,ae*bt/cost.energy)
end

function OpeningFocus(a)
    if not Enabled(a) or not a.ai or a.ai.settings.difficulty~="hard" then return false end
    local factories,extractors,power=0,0,0
    for _,u in pairs(a.units or {}) do
        if Own(a,u) and Complete(u) then
            if FactoryDomain(u.tp) then factories=factories+1 end
            if Has(u.tp,"ALLOYS_EXTRACTION") then extractors=extractors+1 end
            if Power(u.tp) then power=power+1 end
        end
    end
    return factories<2 or extractors<1 or power<1
end

function AssistAffordable(u,target,current)
    if not Own(u and u.army,target) then return false end
    local product=target.upgradeTarget or target.upgradeBehaviorTargetUnit or target
    if not Own(u.army,product) or Complete(product) then return false end
    local mr,er=ProjectRates(u,product.tpId);local m,e=Resources(u.army,u)
    if not mr or not m then return false end
    local active=current and (u.unitBeingBuilt==product or u.buildBehaviorActualUnit==product)
    return Balance(m)+(active and mr or 0)>=mr and Balance(e)+(active and er or 0)>=er
end
