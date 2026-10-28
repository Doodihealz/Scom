-- Profile-scoped construction and work ownership fixes. No global template edits.
Version = "9.0.25-rc30"
local Rules=Import("AI/mods/AI-Scom/RushBalance.lua")
local AF = Import("AI/AIFunctions.lua")
local HeavyPolicy = Import("AI/mods/AI-Scom/RushHeavyPolicy.lua")
local Available = Import("common/units/availableUnits.lua").AvailableUnits
local MG = Import("AI/AIMarkerGenerator.lua")
local Movement=Import("AI/mods/AI-Scom/RushMovement.lua")
local Log = Import("AI/debugUtilities.lua").AILog
local Factions = {"EDA", "CHOSEN", "GUARD", "SERAPHIM"}
local IsRushArmy
local installed = false
local CleanupPlans
local placementWarnings = {}
function ConfigureCleanup(plans) CleanupPlans = plans end
local function Now() return GetGameTimeSeconds() end
local function Finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
function Has(tp, tag)
    if type(tp)~="table" then return false end
    if tp.hasTags and tp.hasTags[tag] then return true end
    for _,v in ipairs(tp.tags or {}) do if v==tag then return true end end
    return false
end
function Own(army,u)
    return army and u and not u.dead and not u.deleted and u.id and u.army==army
        and army.units and army.units[u.id.index]==u
end
-- Ownership is a lease, not merely a non-nil platoon pointer. Helpers may yield
-- while the host destroys, captures, removes, or reassigns an engineer.
function CurrentAssignment(u,a,p,unitAI,platoonAI)
    return Own(a,u) and unitAI and platoonAI and a.ai and a.ai.isAlive~=false and p and not p.dead
        and u.platoon==p and u.ai==unitAI and p.ai==platoonAI
        and (type(a.PlatoonExists)~="function" or a:PlatoonExists(p))
end
function ApplyBuilderStep(u,p,step,...)
    local a,unitAI,platoonAI=u.army,u.ai,p.ai
    if not CurrentAssignment(u,a,p,unitAI,platoonAI) then return false end
    local state=step(u,...)
    if not CurrentAssignment(u,a,p,unitAI,platoonAI) then return false end
    unitAI.eState=state
    return true
end
-- Defeated armies can retain their unit table briefly during host cleanup.
-- Do not turn those stale entries into a request for their deleted MAIN base.
function HasLivingUnits(a)
    if not a or a.ai and a.ai.isAlive==false then return false end
    for _,u in pairs(a.units or {}) do
        if u and not u.dead and not u.deleted and u.army==a then return true end
    end
    return false
end
function MainBasePosition(index)
    local a=Armies[index]
    if not a or a.ai and a.ai.isAlive==false then return nil end
    local base=a.ai and a.ai.bases and a.ai.bases.MAIN
    if base then return base.position end
    -- A living human, or an AI rebuilding after losing MAIN, can still have a
    -- public spawn position. Preserve that native fallback without pretending
    -- a defeated opponent has a functioning base. Missing spawn diagnostics
    -- remain the responsibility of GetArmyStartPosition itself.
    if a.name and type(AF.GetArmyStartPosition)=="function" then
        return AF.GetArmyStartPosition(a.name)
    end
    return nil
end
function UpgradeTarget(u)
    for _,name in ipairs({"upgradeBehaviorTargetUnit","upgradeTarget"}) do
        local target=u[name]
        if type(target)=="table" and not target.dead and not target.deleted then return target end
    end
    local target=u.unitBeingBuilt
    if target and not target.dead and u.ai and target.tpId==u.ai.rushUpgradeId then return target end
end
function Working(u)
    return u.unitBeingBuilt or UpgradeTarget(u) or (u.buildQueue and next(u.buildQueue))
        or (u.productionBehaviorIsActive and u.productionBehaviorTargetUnit and not u.productionBehaviorTargetUnit.dead)
        or u.unitBeingRepaired or u.unitBeingCaptured or u.unitBeingReclaimed
        or (u.scoCommanderEnhancements and u.scoCommanderEnhancements.active)
end
-- A submitted command is not necessarily active in the same simulation tick.
-- Track the actual order queue and movement separately from paid construction.
function ConstructionStartFailure(u,j,now)
    local tasks=Import("common/commonOrders.lua").OrderTasks
    local orders=u.orders or {};local active=orders.activeOrder
    local pending=active and (active.orderTask==tasks.BUILD or active.orderTask==tasks.ASSISTUNIT)
    for _,o in pairs(orders.queuedOrders or {}) do
        if o.orderTask==tasks.BUILD or o.orderTask==tasks.ASSISTUNIT then pending=true end
    end
    local w=j.startWatch
    if not w then w={progressAt=j.phaseAt};j.startWatch=w end
    local pos=u:GetPosition();local site=j.site and j.site.position
    if site then
        local d=math.sqrt((pos.x-site.x)^2+(pos.z-site.z)^2)
        if not w.bestDistance or d<w.bestDistance-1 then w.bestDistance=d;w.progressAt=now end
    end
    if pending or u.buildBehaviorIsActive then w.emptySince=nil
    else w.emptySince=w.emptySince or now end
    -- Fifteen seconds covers delayed host acceptance, but never holds an absent
    -- order forever. Queued BUILD/ASSIST is not mistaken for an empty queue.
    if now-j.phaseAt>=15 and w.emptySince and now-w.emptySince>=15 then return "order-not-accepted-or-ended" end
    if now-j.phaseAt>=180 then return "startup-time-limit" end
    local noProgressLimit=j.noProgressLimit or 60
    if now-j.phaseAt>=noProgressLimit and now-w.progressAt>=noProgressLimit then return "startup-no-progress" end
end
-- Wait only for this builder's exact accepted construction/assist order.
-- A completed target is success even when the host has already removed its
-- order. A changed owner/assignment is never permission to touch the new job.
function WaitForConstructionStart(u,target,order,noProgressLimit)
    local a,p,unitAI=u.army,u.platoon,u.ai
    local platoonAI=p and p.ai
    if not CurrentAssignment(u,a,p,unitAI,platoonAI) then return "Detached",0,"assignment-changed" end
    if not Own(a,target) then return "Canceled",0,"target-lost" end
    unitAI.stuckCount=0
    local watch={phaseAt=Now(),site={position=target:GetPosition()},noProgressLimit=noProgressLimit}
    local ticks=0
    while CurrentAssignment(u,a,p,unitAI,platoonAI) do
        if not Own(a,target) then return "Canceled",ticks,"target-lost" end
        if target:IsCompleted() then return "Finished",ticks end
        if u.unitBeingBuilt==target then return "Working",ticks end
        if not order or not u.orders or u.orders.activeOrder~=order then
            return "Canceled",ticks,"order-replaced"
        end
        local failure=ConstructionStartFailure(u,watch,Now())
        if failure then return "TimedOut",ticks,failure end
        ticks=ticks+1;unitAI.stuckCount=ticks
        WaitTicks(1)
    end
    return "Detached",ticks,"assignment-changed"
end
function ConstructionDetails(j)
    local u=j and j.lead;local p=u and not u.dead and not u.deleted and u:GetPosition()
    local site=j and j.site and j.site.position;local o=u and u.orders
    local queued=0;for _ in pairs(o and o.queuedOrders or {}) do queued=queued+1 end
    return string.format(" phase=%s elapsed=%.1f attempt=%d position=%s,%s site=%s,%s active=%s queued=%d buildBehavior=%s",
        tostring(j and j.phase),j and (Now()-(j.phaseAt or Now())) or 0,j and j.siteAttempts or 0,
        tostring(p and p.x),tostring(p and p.z),tostring(site and site.x),tostring(site and site.z),
        tostring(o and o.activeOrder and o.activeOrder.orderTask),queued,tostring(u and u.buildBehaviorIsActive))
end
-- Native BUILD orders promote the next queued target in the same host update.
-- Keep at most three structures, with one live reservation per assigned worker.
-- No callback/thread is added per target and completed orders are forgotten.
local function ConstructionPosition(position)
    return position and {x=position.x,y=position.y,z=position.z} or nil
end
local function ConstructionReachSquared(unit)
    local range=unit and unit.construction and unit.construction.range
    if not Finite(range) or range<=0.5 then return nil end
    -- A conservative live reach permits native BUILD without a movement route.
    -- Missing construction data cannot grant a made-up default build radius.
    return (range-0.5)^2
end
local function ConstructionOrders(u,reuse)
    local result=reuse or {};if reuse then table.clear(result) end
    local orders=u.orders or {}
    if orders.activeOrder then result[orders.activeOrder]=true end
    for _,order in pairs(orders.queuedOrders or {}) do result[order]=true end
    return result
end
local function ConstructionWorkerCurrent(w)
    return w.army.ai==w.armyAI and CurrentAssignment(w.unit,w.army,w.platoon,w.unitAI,w.platoonAI)
        and w.unitAI.rushConstructionQueue==w and w.platoonAI.rushConstructionQueue==w.queue
end
local function ConstructionOrdersOwned(w)
    if not ConstructionWorkerCurrent(w) then return false end
    local live=ConstructionOrders(w.unit,w.live)
    for order in pairs(live) do if not w.orders[order] then return false end end
    for order in pairs(w.orders) do if not live[order] then w.orders[order]=nil end end
    return true
end
local function ConstructionReleaseReserve(w)
    local reserves=w.armyAI.ecoReserve
    if w.reservation and reserves and reserves[w.unit.id.index]==w.reservation then
        if w.army.ai==w.armyAI and Own(w.army,w.unit) and w.unit.ai==w.unitAI then
            AF.ClearReserveEco(w.army.id,w.unit.id.index)
        else reserves[w.unit.id.index]=nil end
    end
    if w.callbackRegistered then
        w.unit:RemoveCallback(w.callback,"OnDestroyed");w.callbackRegistered=false
    end
    w.reservation=nil;w.reservedEntry=nil
end
local function ConstructionRemoveOrders(w,selected)
    if not ConstructionWorkerCurrent(w) then return end
    local manager=Import("host/managers/orders/hostOrderManager.lua")
    local orders=w.unit.orders or {}
    -- Remove only exact queued objects. Clearing the entire queue could erase
    -- a replacement combat/retreat command issued while a path search yielded.
    for i=#(orders.queuedOrders or {}),1,-1 do
        local order=orders.queuedOrders[i]
        if w.orders[order] and (not selected or selected[order]) then
            manager.RemoveUnitFromQueuedOrder(w.unit,order);w.orders[order]=nil
        end
    end
    local active=orders.activeOrder
    if active and w.orders[active] and (not selected or selected[active]) then
        manager.RemoveUnitFromActiveOrder(w.unit);w.orders[active]=nil
        manager.TryStartNextOrderForUnit(w.unit)
    end
end
local function ConstructionReleaseWorker(w,preservePaid)
    local selected
    if preservePaid then
        selected={}
        for order in pairs(w.orders) do
            local target=order.unitGettingBuilt or order.targetUnit
            if not (Own(w.army,target) and target.hasBeenPromotedFromPlacementGhost and not target:IsCompleted()) then
                selected[order]=true
            end
        end
        for _,entry in ipairs(w.queue.entries) do
            local target=entry.target
            if Own(w.army,target) and target.hasBeenPromotedFromPlacementGhost and not target:IsCompleted() then
                for order in pairs(entry.orders) do selected[order]=nil end
            end
        end
    end
    ConstructionRemoveOrders(w,selected);ConstructionReleaseReserve(w)
    if w.unitAI.rushConstructionQueue==w then
        w.unitAI.rushConstructionQueue=nil
        if w.unitAI.eState=="ConstructionQueue" then w.unitAI.eState=nil end
    end
end
function ReleaseConstructionQueueUnit(unit)
    local w=unit and unit.ai and unit.ai.rushConstructionQueue
    if not w or w.unit~=unit then return false end
    ConstructionReleaseWorker(w,false)
    return true
end
function ReleaseConstructionQueue(platoon,preservePaid)
    local data=platoon and platoon.ai
    local q=data and data.rushConstructionQueue
    if not q or q.platoon~=platoon or q.platoonAI~=data then return false end
    -- A failed selector cannot leave unpaid successors and death callbacks
    -- behind. Keep the exact native orders finishing paid foundations.
    for _,w in ipairs(q.workers) do ConstructionReleaseWorker(w,preservePaid) end
    if data.rushConstructionQueue==q then
        data.rushConstructionQueue=nil;data.placeToBuild=nil;data.buildedUnit=nil
    end
    return true
end
local function ConstructionRates(q,w,extra)
    local mass,energy=0,0
    for _,entry in ipairs(q.entries) do
        if not entry.participants or entry.participants[w] then
            local m,e=Rules.ProjectRates(w.unit,entry.id)
            mass=math.max(mass,m or 0);energy=math.max(energy,e or 0)
        end
    end
    if extra then
        local m,e=Rules.ProjectRates(w.unit,extra)
        if not m then return nil end
        mass=math.max(mass,m);energy=math.max(energy,e)
    end
    return mass,energy
end
local function ConstructionReserve(q)
    for _,w in ipairs(q.workers) do
        if ConstructionWorkerCurrent(w) then
            local mass,energy=ConstructionRates(q,w)
            if q.suspended or mass<=0 and energy<=0 then ConstructionReleaseReserve(w)
            else
                local reserves=q.armyAI.ecoReserve
                if not reserves or not reserves[w.unit.id.index] or reserves[w.unit.id.index]==w.reservation then
                    local head=q.entries[1]
                    if not w.reservation or w.reservedEntry~=head then
                        AF.SetReserveEco(q.army.id,w.unit.id.index,head.id,head.position)
                        w.reservation=q.armyAI.ecoReserve and q.armyAI.ecoReserve[w.unit.id.index]
                        w.reservedEntry=head
                        if w.reservation and not w.callbackRegistered then
                            w.unit:AddCallback(w.callback,"OnDestroyed");w.callbackRegistered=true
                        end
                    end
                    if w.reservation then
                        w.reservation.resourcePerSecond=mass;w.reservation.energyPerSecond=energy
                        w.reservation.rushConstructionQueue=w
                    end
                end
            end
        end
    end
end
local function ConstructionAffordable(q,id)
    if q.former.RushAdjacencyStorage or q.former.RushMassFabrication or q.former.RushBeachhead
        or q.former.RushEmergencyShield then
        local worker=q.workers[1]
        if #q.workers~=1 or not worker or not ConstructionWorkerCurrent(worker) then return false end
        if q.former.RushEmergencyShield then
            return Import("AI/mods/AI-Scom/RushBaseLayout.lua").CanFundEmergencyShield(worker.unit,id)
        end
        if q.former.RushAdjacencyStorage then return Rules.CanFundAdjacencyStorage(worker.unit,id) end
        if q.former.RushBeachhead then return Import("AI/mods/AI-Scom/RushBeachhead.lua").CanFund(worker.unit,id) end
        return Import("AI/mods/AI-Scom/RushMassFabrication.lua").CanFund(worker.unit,id)
    end
    local protected=Rules.ConstructionNeedsTechBudget(q.army,q.former)
    if q.former.AllowEcoStorageDrain and not q.former.RushCapacityDomain and not protected then return true end
    local mass,energy=Rules.Resources(q.army)
    if not mass then return false end
    local extraMass,extraEnergy,duration=0,0,1
    for _,w in ipairs(q.workers) do
        local m,e=ConstructionRates(q,w,id)
        if not m then return false end
        local oldM,oldE=ConstructionRates(q,w)
        extraMass=extraMass+math.max(0,m-oldM);extraEnergy=extraEnergy+math.max(0,e-oldE)
        local _,_,seconds=Rules.ProjectRates(w.unit,id);duration=math.max(duration,seconds or 1)
    end
    local storedMass,storedEnergy=0,0
    if q.former.RushCapacityDomain then
        storedMass=math.max(0,mass.current-mass.storage*0.30)/duration
        storedEnergy=math.max(0,energy.current-energy.storage*0.30)/duration
    elseif protected then
        storedMass=math.max(0,mass.current-mass.storage*0.15)/duration
        storedEnergy=math.max(0,energy.current-energy.storage*0.15)/duration
    end
    return Rules.Balance(mass)+storedMass>=extraMass and Rules.Balance(energy)+storedEnergy>=extraEnergy
end
local function ConstructionPublish(q)
    local head=q.entries[1];local data=q.platoonAI
    if head then
        data.nextBuildingtpIds=head.ids;data.nextBuildingtpId=head.id
        data.constructionSpacing=head.spacing;data.placeToBuild=head.position;data.buildedUnit=head.target
    else data.placeToBuild=nil;data.buildedUnit=nil end
end
local function ConstructionIssue(q,task,position,payload,selected,only)
    position=ConstructionPosition(position)
    local manager=Import("host/managers/orders/hostOrderManager.lua")
    local units,before={},{ }
    for _,w in ipairs(q.workers) do
        if (not only or only==w) and ConstructionOrdersOwned(w) then
            units[#units+1]=w.unit;before[w]=ConstructionOrders(w.unit)
        end
    end
    if #units==0 then return nil end
    manager.HostIssueOrder(task,units,true,position,payload)
    local accepted
    for _,w in ipairs(q.workers) do
        if before[w] and ConstructionWorkerCurrent(w) then
            for order in pairs(ConstructionOrders(w.unit)) do
                if not before[w][order] and order.orderTask==task then
                    w.orders[order]=true;accepted=order
                    if selected then selected[order]=true end
                end
            end
        end
    end
    return accepted
end
local function ConstructionClearEntry(q,entry)
    for _,w in ipairs(q.workers) do ConstructionRemoveOrders(w,entry.orders) end
end
local function ConstructionPrune(q,all)
    for i=#q.entries,(all and 1 or 2),-1 do
        local entry=q.entries[i];local target=entry.target
        local paid=Own(q.army,target) and target.hasBeenPromotedFromPlacementGhost
        if all or not paid then
            ConstructionClearEntry(q,entry)
            if not paid then
                table.insert(q.remaining,1,entry.ids);table.remove(q.entries,i)
            else entry.order=nil;entry.orders={} end
        end
    end
    ConstructionPublish(q);ConstructionReserve(q)
end
function RunConstructionQueue(platoon,buildList,maxUnits,hooks)
    local army,data=platoon.army,platoon.ai
    if not IsRushArmy or not IsRushArmy(army) or not data or not hooks or not hooks.place then return false end
    -- Mobile experimentals and shoreline projects retain their specialised controller.
    for _,ids in ipairs(buildList) do
        for _,id in pairs(ids) do if not Has(__Templates.Units[id],"STRUCTURE") then return false end end
    end
    local tasks=Import("common/commonOrders.lua").OrderTasks
    local intel=Import("AI/mods/AI-Scom/RushCombatIntel.lua")
    local q={army=army,armyAI=army.ai,platoon=platoon,platoonAI=data,former=data.formerTable,
        workers={},entries={},remaining=buildList,nextPlan=0,nextSafety=0}
    local function current()
        return army.ai==q.armyAI and q.armyAI.isAlive~=false and platoon.ai==data
            and not platoon.dead and army:PlatoonExists(platoon) and data.rushConstructionQueue==q
    end
    data.rushConstructionQueue=q
    local units=platoon:GetUnits();local first=buildList[1]
    local basePosition=ConstructionPosition(data.basePosition)
    table.sort(units,function(a,b)
        local aa=first and first[a.factionTag] and CanBuilderBuild(a,first[a.factionTag]) or false
        local bb=first and first[b.factionTag] and CanBuilderBuild(b,first[b.factionTag]) or false
        if q.former.RushEmergencyShield then
            local layout=Import("AI/mods/AI-Scom/RushBaseLayout.lua")
            aa=aa and layout.CanFundEmergencyShield(a,first[a.factionTag]) or false
            bb=bb and layout.CanFundEmergencyShield(b,first[b.factionTag]) or false
        end
        if aa~=bb then return aa end
        local ap=ConstructionPosition(a:GetPosition())
        local bp=ConstructionPosition(b:GetPosition());local base=basePosition
        local ad=(ap.x-base.x)^2+(ap.z-base.z)^2;local bd=(bp.x-base.x)^2+(bp.z-base.z)^2
        return ad<bd or ad==bd and a.id.index<b.id.index
    end)
    if hooks.trim then hooks.trim(platoon,units,maxUnits) end
    for _,u in ipairs(units) do
        if CurrentAssignment(u,army,platoon,u.ai,data) and not next(ConstructionOrders(u)) then
            local w={unit=u,army=army,armyAI=army.ai,unitAI=u.ai,platoon=platoon,platoonAI=data,
                queue=q,orders={},live={}}
            w.callback=function() ConstructionReleaseReserve(w) end
            u.ai.rushConstructionQueue=w;u.ai.eState="ConstructionQueue";q.workers[#q.workers+1]=w
        elseif u.platoon==platoon then
            -- An order accepted after recruitment already belongs to its issuer.
            platoon:OnUnitRemoved(u)
        end
    end
    local function owned()
        if not current() then return false end
        for _,w in ipairs(q.workers) do if not ConstructionOrdersOwned(w) then return false end end
        return #q.workers>0
    end
    local function dangerAt(position)
        position=ConstructionPosition(position)
        local enemy=q.former.RushEmergencyShield
            and Import("AI/mods/AI-Scom/RushBaseLayout.lua").EmergencyShieldThreat(army,position)
            or intel.EnemyThreat(army,position,"Land",4,0)
        local friendly=intel.FriendlyThreat(platoon,position,48,"Land",false)
        for _,w in ipairs(q.workers) do
            local p=w.unit:GetPosition()
            if (p.x-position.x)^2+(p.z-position.z)^2<=48^2 then
                friendly=friendly+math.max(0,AF.GetUnitThreatValueByLayer(w.unit,"Land",false) or 0)
            end
        end
        return enemy,friendly
    end
    local function participants(entry)
        entry.participants={}
        for _,w in ipairs(q.workers) do
            if w.orders[entry.order] then entry.participants[w]=true
            elseif ConstructionOrdersOwned(w) and Own(army,entry.target) then
                -- BUILD normally accepts low-tier helpers after the lead promotes
                -- its ghost. A rejected helper can use the native finishing repair.
                local order=ConstructionIssue(q,tasks.REPAIR,entry.position,{targetGlobalId=entry.target.id},entry.orders,w)
                if order then entry.participants[w]=true end
            end
        end
    end
    local function issueHead(entry,selectedLead)
        local lead=selectedLead or q.workers[1] and q.workers[1].unit
        if not lead then return false end
        local start=ConstructionPosition(lead:GetPosition());local reach=ConstructionReachSquared(lead)
        if not reach then return false end
        if (start.x-entry.position.x)^2+(start.z-entry.position.z)^2>reach then
            local path
            if hooks.route then path=hooks.route(lead,entry.position)
            else path=MG.GeneratePathTo(army.id,start,entry.position,data.movementLayer,true,
                math.max(0,AF.GetUnitThreatValueByLayer(lead,"Land",false) or 0)) end
            if not owned() then return false end
            if not path then return false end
            path=MG.StraightenPath(path)
            if not owned() then return false end
            for _,node in ipairs(path) do
                if (node.x-entry.position.x)^2+(node.z-entry.position.z)^2>reach then
                    ConstructionIssue(q,tasks.MOVE,node,nil,entry.orders)
                end
            end
        end
        if entry.target then
            if not owned() or not Own(army,entry.target) or entry.target:IsCompleted() then return false end
            entry.order=ConstructionIssue(q,tasks.REPAIR,entry.position,{targetGlobalId=entry.target.id},entry.orders)
        else
            -- Placement and route helpers may yield. Reprice only this unpaid
            -- start against current commitments; an existing foundation keeps working.
            if not CanBuilderBuild(lead,entry.id)
                or not AF.CanBuildStructureAt(army.id,entry.id,entry.position,0)
                or not owned() or not ConstructionAffordable(q,entry.id) or not owned() then return false end
            -- Revalidate dynamic requests after path generation yielded. A paid
            -- target resumes through REPAIR above and is never cancelled here.
            if hooks.valid and not hooks.valid(entry.id,entry.position,lead) then return false end
            if not owned() then return false end
            entry.order=ConstructionIssue(q,tasks.BUILD,entry.position,{tpId=entry.id,armyId=army.id},entry.orders)
            entry.target=entry.order and entry.order.unitGettingBuilt
        end
        if entry.order and Own(army,entry.target) then participants(entry);return true end
        return false
    end
    while current() do
        for i=#q.workers,1,-1 do
            local w=q.workers[i]
            if not ConstructionOrdersOwned(w) then
                ConstructionReleaseWorker(w,false)
                -- The new command survives; only this expired AI assignment ends.
                if w.unit.platoon==platoon and platoon.ai==data then platoon:OnUnitRemoved(w.unit) end
                table.remove(q.workers,i)
            end
        end
        if #q.workers==0 then break end
        -- This inexpensive completion check does not rerun former selection or paths.
        while q.entries[1] and (not Own(army,q.entries[1].target) or q.entries[1].target:IsCompleted()) do
            local entry=table.remove(q.entries,1)
            ConstructionClearEntry(q,entry)
            q.nextPlan=0
        end
        ConstructionPublish(q)
        local now=Now()
        if now>=q.nextSafety then
            q.nextSafety=now+0.5
            if hooks.observe then
                hooks.observe(q.workers[1].unit)
                if not owned() then break end
            end
            local danger=false
            for _,w in ipairs(q.workers) do
                local u=w.unit;local enemy,friendly=dangerAt(u:GetPosition())
                local damaged=AF.IsUnderAttack(u)
                local health=u:GetHealth()/math.max(1,u:GetMaxHealth())
                if q.former.RushEmergencyShield and damaged and health<0.50 then
                    -- Remote guns may be discounted to zero for construction.
                    -- Actual low-health damage still owns this queue's retreat.
                    q.shellRetreat=true
                    local stamp=Finite(u.lastDamaged) and u.lastDamaged or now
                    if q.shellDamageStamp~=stamp then
                        q.shellDamageStamp=stamp;q.shellImpact=ConstructionPosition(u:GetPosition());q.nextEscape=0
                    end
                    danger=true;break
                end
                if enemy>0 and (Has(u.tp,"COMMAND") and (enemy>math.max(8,friendly)*1.4
                    or damaged and health<0.55) or not Has(u.tp,"COMMAND") and (damaged or enemy>friendly*1.25+5)) then
                    danger=true;break
                end
            end
            if danger and not q.suspended then
                q.suspended=true;q.suspendedAt=now;q.nextEscape=0
                ConstructionPrune(q,true)
            end
            if q.suspended then
                local head=q.entries[1];local site=head and head.position or basePosition
                local enemy,friendly=dangerAt(site)
                local shellSafe=true
                if q.shellRetreat then
                    local layout=Import("AI/mods/AI-Scom/RushBaseLayout.lua")
                    for _,w in ipairs(q.workers) do
                        if not layout.EmergencyShieldSafeToResume(w.unit,head and head.position) then shellSafe=false;break end
                    end
                end
                if not danger and shellSafe and enemy<=friendly*0.8 and now-q.suspendedAt>=1 then
                    for _,w in ipairs(q.workers) do ConstructionRemoveOrders(w) end
                    q.suspended=false;q.nextPlan=0
                    q.shellRetreat=nil;q.shellDamageStamp=nil;q.shellImpact=nil;q.shellMovePosition=nil
                    for _,entry in ipairs(q.entries) do entry.progressAt=now;entry.distance=nil end
                elseif now-q.suspendedAt>60 then break
                elseif now>=(q.nextEscape or 0) then
                    q.nextEscape=now+5
                    local path
                    if q.shellRetreat then
                        local worker=q.workers[1];local u=worker.unit
                        local position=ConstructionPosition(u:GetPosition())
                        local active=u.orders and u.orders.activeOrder
                        local moving=active and active.orderTask==tasks.MOVE and worker.orders[active]
                        local old=q.shellMovePosition
                        local progressed=old and (position.x-old.x)^2+(position.z-old.z)^2>4
                        q.shellMovePosition=position
                        -- Keep a progressing owned escape; fresh damage or a
                        -- stalled native move may select another local refuge.
                        if danger or not moving or not progressed then
                            local retry
                            path,retry=Import("AI/mods/AI-Scom/RushBaseLayout.lua").EmergencyShieldEscape(
                                platoon,u,q.shellImpact,head and head.position)
                            if retry then q.nextEscape=now+0.5 end
                        end
                    else
                        local origin=ConstructionPosition(q.workers[1].unit:GetPosition());local risk=dangerAt(origin)
                        local candidates={basePosition}
                        for i=0,7 do
                            local angle=i*math.pi/4
                            candidates[#candidates+1]=ConstructionPosition(Clamp({x=origin.x+math.cos(angle)*32,y=origin.y,z=origin.z+math.sin(angle)*32},4))
                        end
                        local best,bestRisk
                        for _,pos in ipairs(candidates) do
                            if pos and MG.CanGraphAreaTo(origin,pos,data.movementLayer) then
                                local r=dangerAt(pos)
                                if r<risk and (not bestRisk or r<bestRisk) then best,bestRisk=pos,r end
                            end
                        end
                        if best then path=MG.GeneratePathTo(army.id,origin,best,data.movementLayer,true,0) end
                    end
                    if not owned() then break end
                    if path then
                        path=MG.StraightenPath(path)
                        if not owned() then break end
                        for _,w in ipairs(q.workers) do ConstructionRemoveOrders(w) end
                        for _,node in ipairs(path) do ConstructionIssue(q,tasks.MOVE,node,nil) end
                    end
                end
            elseif #q.entries>1 and not ConstructionAffordable(q,q.entries[#q.entries].id) then
                ConstructionPrune(q,false)
            end
        end
        if not current() then break end
        if not q.suspended and now>=q.nextPlan then
            q.nextPlan=now+0.5
            local head=q.entries[1]
            local resumed=true
            for i,entry in ipairs(q.entries) do
                if not entry.order then
                    if i==1 then resumed=issueHead(entry)
                    else entry.order=ConstructionIssue(q,tasks.REPAIR,entry.position,{targetGlobalId=entry.target.id},entry.orders)
                        resumed=entry.order~=nil
                        if resumed then participants(entry) end
                    end
                    if not resumed then break end
                end
            end
            if not resumed then break end
            -- One placement/path search per wake; the second successor is planned
            -- during the current build, never through a separate polling thread.
            if #q.entries<3 and q.remaining[1] then
                local ids=q.remaining[1];local lead,id
                for _,w in ipairs(q.workers) do
                    local candidate=ids[w.unit.factionTag]
                    if candidate and CanBuilderBuild(w.unit,candidate) then lead,id=w.unit,candidate;break end
                end
                if not id then
                    -- Losing the only capable lead for a later project must not
                    -- interrupt the paid structure the remaining helpers can finish.
                    q.remaining={}
                else
                -- Keep the selected lead, but don't let unaffordable optional
                -- helpers prevent a funded first structure from starting.
                while not q.entries[1] and #q.workers>(hooks.minimum or 1) and not ConstructionAffordable(q,id) do
                    local index=#q.workers
                    while index>0 and q.workers[index].unit==lead do index=index-1 end
                    if index==0 then break end
                    local w=table.remove(q.workers,index)
                    ReleaseConstructionQueueUnit(w.unit)
                    if w.unit.platoon==platoon then platoon:OnUnitRemoved(w.unit) end
                end
                if ConstructionAffordable(q,id) then
                    local position,spacing=hooks.place(ids,lead)
                    position=ConstructionPosition(position)
                    if not owned() then break end
                    if position and PlacementContract(id,position) and AF.CanBuildStructureAt(army.id,id,position,0) then
                        local previous=q.entries[#q.entries]
                        local origin=previous and previous.position or ConstructionPosition(lead:GetPosition())
                        local nearby=not previous or (origin.x-position.x)^2+(origin.z-position.z)^2<=48^2
                        local enemy,friendly=dangerAt(position)
                        local reach=not previous and ConstructionReachSquared(lead)
                        local direct=reach and (origin.x-position.x)^2+(origin.z-position.z)^2<=reach
                        -- A first structure already inside the lead's build reach
                        -- needs no navigation graph. Queued successors still do.
                        if nearby and enemy<=friendly*0.9+1 and (direct or MG.CanGraphAreaTo(origin,position,data.movementLayer)) then
                            local entry={ids=ids,id=id,spacing=spacing,position=ConstructionPosition(position),orders={},started=now,progressAt=now}
                            local accepted
                            if previous then
                                if owned() and CanBuilderBuild(lead,id)
                                    and AF.CanBuildStructureAt(army.id,id,position,0)
                                    and owned() and ConstructionAffordable(q,id) and owned()
                                    and (not hooks.valid or hooks.valid(id,position,lead)) and owned() then
                                    entry.order=ConstructionIssue(q,tasks.BUILD,position,{tpId=id,armyId=army.id},entry.orders)
                                    entry.target=entry.order and entry.order.unitGettingBuilt
                                    accepted=entry.order and Own(army,entry.target)
                                    if accepted then participants(entry) end
                                end
                            else accepted=issueHead(entry,lead) end
                            if accepted then
                                table.remove(q.remaining,1);q.entries[#q.entries+1]=entry
                                if hooks.started then hooks.started(army.id,entry.target) end
                                ConstructionPublish(q);ConstructionReserve(q)
                            else ConstructionClearEntry(q,entry);q.nextPlan=now+2 end
                        elseif not q.entries[1] then break
                        else q.nextPlan=now+2 end
                    elseif not q.entries[1] then break
                    else q.nextPlan=now+2 end
                elseif not q.entries[1] then break
                else q.nextPlan=now+2 end
                end
            end
            head=q.entries[1]
            if head and Own(army,head.target) and not head.target:IsCompleted() then
                local progress=head.target:GetFractionComplete()
                local distance=math.huge;local working=false;local paused=false
                for _,w in ipairs(q.workers) do
                    local u=w.unit;local pos=u:GetPosition()
                    distance=math.min(distance,(pos.x-head.position.x)^2+(pos.z-head.position.z)^2)
                    working=working or u.unitBeingBuilt==head.target
                    paused=paused or type(u.GetPause)=="function" and u:GetPause()
                end
                if progress>(head.progress or -1) or not head.distance or distance<head.distance-1 then
                    head.progressAt=now;head.progress=progress;head.distance=distance
                end
                if not paused and not working and now-head.progressAt>30 then
                    -- Preserve paid progress but release an unreachable/stalled job.
                    break
                end
            end
            ConstructionReserve(q)
        end
        if not q.entries[1] and not q.remaining[1] then break end
        WaitTicks(math.max(1,math.floor(((Constants and Constants.TickRate) or 10)*0.2)))
    end
    for _,w in ipairs(q.workers) do
        local stillOwned=ConstructionOrdersOwned(w)
        ConstructionReleaseWorker(w,false)
        if not stillOwned and w.unit.platoon==platoon and platoon.ai==data then
            platoon:OnUnitRemoved(w.unit)
        end
    end
    if platoon.ai==data and data.rushConstructionQueue==q then
        data.rushConstructionQueue=nil;data.placeToBuild=nil;data.buildedUnit=nil
    end
    return true
end

-- A recall request is cooperative: the reclaim coroutine releases its own unit
-- at its next loop boundary. Never detach a builder while that coroutine yields
-- inside a pathfinding/order helper; it could otherwise overwrite the new job.
function BuilderRecallReserved(u,owner)
    local r=u and u.ai and u.ai.rushBuilderRecall
    if r and r.expires<=Now() then u.ai.rushBuilderRecall=nil;r=nil end
    return r and (not owner or r.owner~=owner)
end
local function Recallable(a,u,allowLowTier)
    if not Own(a,u) or not u:IsCompleted() or not Has(u.tp,"ENGINEER")
        or not (Has(u.tp,"TECH3") or allowLowTier and (Has(u.tp,"TECH1") or Has(u.tp,"TECH2")))
        or Has(u.tp,"COMMAND") or HeavyPolicy.IsT4(u.tp) or u.scoCommanderPodOwner or u.scoSourcePodOwner
        or Working(u) or u.buildBehaviorIsActive or u.ai and u.ai.reservedEco
        or a.ai.ecoReserve and a.ai.ecoReserve[u.id.index]
        or type(u.GetPause)=="function" and u:GetPause() then return false end
    local f=u.platoon and u.platoon.ai and u.platoon.ai.formerTable
    if not f or f.AIPlan~="planReclaimMap" then return false end
    local tasks=Import("common/commonOrders.lua").OrderTasks
    local orders=u.orders or {}
    if orders.activeOrder and orders.activeOrder.orderTask~=tasks.MOVE then return false end
    for _,o in pairs(orders.queuedOrders or {}) do if o.orderTask~=tasks.MOVE then return false end end
    return true
end
function RequestConstructionBuilder(a,id,pos,owner,allowLowTier)
    local best,bestD
    for _,u in pairs(a.units or {}) do
        if Recallable(a,u,allowLowTier==true and owner=="alloy-expansion")
            and not BuilderRecallReserved(u,owner) and CanBuilderBuild(u,id) then
            local p=u:GetPosition();local d=(p.x-pos.x)^2+(p.z-pos.z)^2
            if d<=192^2 and (not bestD or d<bestD or d==bestD and u.id.index<best.id.index) then best=u;bestD=d end
        end
    end
    if not best then return false end
    best.ai=best.ai or {}
    local r=best.ai.rushBuilderRecall
    if not r then
        best.ai.rushBuilderRecall={owner=owner,id=id,expires=Now()+20}
        Log("[RushWork] army="..tostring(a.id).." event=recall-request builder="..tostring(best.id.index).." owner="..owner.." unit="..id,true)
    end
    return true
end
function ReleaseRecalledBuilder(u,p,plans)
    local r=u.ai and u.ai.rushBuilderRecall
    if not r then return false end
    if r.expires<=Now() then u.ai.rushBuilderRecall=nil;return false end
    if u.platoon~=p or not Recallable(u.army,u,r.owner=="alloy-expansion") then u.ai.rushBuilderRecall=nil;return false end
    -- This is called by the OLD owning coroutine, with no yield before removal.
    Import("host/managers/orders/hostOrderManager.lua").HostClearOrder({u})
    u.unitToReclaim=nil
    plans=plans or CleanupPlans
    if plans and plans.ClearUnitTemporaryPlatoonData then plans.ClearUnitTemporaryPlatoonData(u,"cooperative construction recall") end
    u.ai.rushBuilderRecall=r;r.expires=Now()+20
    p:OnUnitRemoved(u)
    Log("[RushWork] army="..tostring(u.army.id).." event=recalled builder="..tostring(u.id.index).." owner="..r.owner,true)
    return true
end
-- Retain construction intent across generic movement recovery. A path retry
-- must not turn a MOVE -> BUILD queue into an endless MOVE-only assignment.
function BeginBuildMove(u,id,pos,issueBuild)
    u.ai.rushBuildMove={platoon=u.platoon,id=id,position={x=pos.x,y=pos.y,z=pos.z},
        issueBuild=issueBuild==true,retries=0}
end
local function TravelTarget(u,w)
    local function match(t)
        return Own(u.army,t) and t.tpId==w.id and (t:GetPosition().x-w.position.x)^2
            +(t:GetPosition().z-w.position.z)^2<9
    end
    for _,t in pairs({u.unitBeingBuilt,u.buildBehaviorActualUnit,u.platoon.ai.buildedUnit}) do
        if match(t) then return t end
    end
    local orders=u.orders or {}
    if orders.activeOrder and match(orders.activeOrder.unitGettingBuilt) then return orders.activeOrder.unitGettingBuilt end
    for _,o in pairs(orders.queuedOrders or {}) do if match(o.unitGettingBuilt) then return o.unitGettingBuilt end end
end
function ExpireBuildMoveFailures(a)
    local blocked=a.ai.blacklistedBuildPlaces or {}
    for key,r in pairs(a.ai.rushBuildMoveRejected or {}) do
        if r.expires<=Now() then
            if blocked[key]==r.marker then blocked[key]=nil end
            a.ai.rushBuildMoveRejected[key]=nil
        end
    end
end
local function FailBuildMove(u,w,reason)
    -- A marker table is truthy for the native blacklist and gives this timeout
    -- identity ownership; expiry never erases another policy's newer exclusion.
    local a=u.army;local key=math.floor(w.position.x).."-"..math.floor(w.position.z)
    a.ai.blacklistedBuildPlaces=a.ai.blacklistedBuildPlaces or {}
    a.ai.rushBuildMoveRejected=a.ai.rushBuildMoveRejected or {}
    if not a.ai.blacklistedBuildPlaces[key] then
        local marker={rushBuildRecovery=true}
        a.ai.blacklistedBuildPlaces[key]=marker
        a.ai.rushBuildMoveRejected[key]={marker=marker,expires=Now()+120}
    end
    Log("[RushWork] army="..tostring(a.id).." event=construction-released reason="..reason
        .." builder="..tostring(u.id.index).." unit="..tostring(w.id).." retries="..w.retries,true)
    return "Disband"
end
function ReleaseFailedConstructionStart(u,id,position,reason,blockSite)
    if not Own(u.army,u) or not u.platoon or not u.ai then return "Disband" end
    if u.unitBeingBuilt then return "Building" end
    Import("host/managers/orders/hostOrderManager.lua").HostClearOrder({u})
    if blockSite and position then
        return FailBuildMove(u,{id=id,position=position,retries=0},reason)
    end
    Log("[RushWork] army="..tostring(u.army.id).." event=construction-released reason="..reason
        .." builder="..tostring(u.id.index).." unit="..tostring(id),true)
    return "Disband"
end
function RecoverBuildMove(u,destination,threat)
    local w=u.ai and u.ai.rushBuildMove
    if not w or not Own(u.army,u) or u.platoon~=w.platoon then return "Disband" end
    if (destination.x-w.position.x)^2+(destination.z-w.position.z)^2>0.01 then return "Disband" end
    local orders=Import("host/managers/orders/hostOrderManager.lua")
    local tasks=Import("common/commonOrders.lua").OrderTasks
    local target=TravelTarget(u,w)
    if target and target:IsCompleted() then return "MovingDestinationReached" end
    -- Never cancel accepted construction just because a path anchor is stale.
    if target and u.buildBehaviorIsActive then return "MovingDestinationReached" end
    if w.retries>=3 then return FailBuildMove(u,w,"movement-retry-limit") end
    w.retries=w.retries+1
    if target then
        local f=type(target.GetFractionComplete)=="function" and target:GetFractionComplete() or 0
        if f<=0 then return "MovingToDestination" end -- keep the accepted placeholder/order intact
        orders.HostIssueOrder(tasks.ASSISTUNIT,{u},false,target:GetPosition(),{targetGlobalId=target.id})
        return "MovingToDestination"
    end
    local tp=__Templates.Units[w.id];local skirt=Footprint(tp)
    if not skirt or not CanBuilderBuild(u,w.id) then return FailBuildMove(u,w,"invalid-build-intent") end
    local uf=Footprint(u.tp) or {x=1,y=1};local gap=math.max(uf.x,uf.y)/2+1
    local rx,rz=skirt.x/2+gap,skirt.y/2+gap
    local offsets={{rx,0},{-rx,0},{0,rz},{0,-rz},{rx,rz},{-rx,rz},{rx,-rz},{-rx,-rz}}
    local start=u:GetPosition();local layer=Movement.UnitMovementLayer(u) or "Land"
    table.sort(offsets,function(x,y)
        local dx=(destination.x+x[1]-start.x)^2+(destination.z+x[2]-start.z)^2
        local dy=(destination.x+y[1]-start.x)^2+(destination.z+y[2]-start.z)^2
        return dx==dy and (x[1]==y[1] and x[2]<y[2] or x[1]<y[1]) or dx<dy
    end)
    local path
    for _,o in ipairs(offsets) do
        local q=SnapToGround({x=destination.x+o[1],y=0,z=destination.z+o[2]})
        if Inside(q,gap) and MG.IsPathable(q.x,q.z) and MG.CanGraphAreaToStrict(start,q,layer) then
            local candidate=MG.GeneratePathTo(u.army.id,start,q,layer,true,threat)
            if type(candidate)=="table" and #candidate>0 then path=MG.StraightenPath(candidate);break end
        end
    end
    -- Native pathfinding can yield. It does not grant ownership of a new job.
    if not Own(u.army,u) or u.platoon~=w.platoon or u.ai.rushBuildMove~=w then return "Disband" end
    if TravelTarget(u,w) or u.buildBehaviorIsActive then return "MovingToDestination" end
    if not path or #path==0 then return FailBuildMove(u,w,"no-reachable-approach") end
    if w.issueBuild and AF.CanBuildStructureAt(u.army.id,w.id,destination,0)~=true then
        return FailBuildMove(u,w,"placement-rejected")
    end
    orders.HostClearOrder({u})
    for _,pos in ipairs(path) do orders.HostIssueOrder(tasks.MOVE,{u},true,pos,nil) end
    if w.issueBuild then
        orders.HostIssueOrder(tasks.BUILD,{u},true,destination,{tpId=w.id,armyId=u.army.id})
    end
    u.ai.path=path
    Log("[RushWork] army="..tostring(u.army.id).." event=construction-repath builder="..tostring(u.id.index)
        .." unit="..tostring(w.id).." retry="..w.retries.." buildQueued="..tostring(w.issueBuild),true)
    return "MovingToDestination"
end
function Inside(p,margin)
    if not p or not Finite(p.x) or not Finite(p.z) then return false end
    local a=AF.GetPlayableArea(); margin=margin or 0
    return p.x>=a.x+margin and p.z>=a.y+margin and p.x<=a.x+a.width-margin and p.z<=a.y+a.height-margin
end
function Clamp(p,margin)
    if not p or not Finite(p.x) or not Finite(p.z) then return nil end
    local a=AF.GetPlayableArea();margin=math.min(margin or 2,a.width/4,a.height/4)
    local q={x=math.max(a.x+margin,math.min(a.x+a.width-margin,p.x)),
        y=p.y or 0,z=math.max(a.y+margin,math.min(a.y+a.height-margin,p.z))}
    return SnapToGround(q)
end
function Footprint(tp)
    if type(tp)~="table" then return nil end
    for _,key in ipairs({"skirtSize","footprint"}) do
        local f=tp[key]
        if type(f)=="table" and Finite(f.x) and Finite(f.y) and f.x>0 and f.y>0 then return f end
    end
end
-- Mirror the shipped Hive host-order guard BEFORE reserving an engineer. An
-- invalid core template cannot be made legal by changing the AI's build priority.
function PlacementContract(id,position)
    local tp=__Templates.Units[id]
    if not tp then return false,"missing-template" end
    local a=tp.additions
    if a==nil then return true end
    if type(a)~="table" then return false,"malformed-additions" end
    local c=a.scoFieldFixHivePlacement
    if c==nil then return true end
    local f=tp.skirtSize
    local offset=type(c)=="table" and c.offset
    local valid=type(c)=="table" and (id=="ugs2501" or id=="ugs3501")
        and tp.general and tp.general.tpId==id and c.version=="1.0.0"
        and c.owner=="SCO_FieldFixHivePlacementRuntime"
        and type(offset)=="table" and offset.x==-0.5 and offset.z==-0.5
        and type(f)=="table" and f.x==2 and f.y==2
    if not valid then
        return false,"hive-template-contract"
    end
    if position and not (Finite(position.x) and Finite(position.y) and Finite(position.z)) then
        return false,"hive-position-contract"
    end
    return true
end
function PlacementReady(id)
    local valid,reason=PlacementContract(id)
    if not valid and placementWarnings[id]~=reason then
        placementWarnings[id]=reason
        local tp=__Templates.Units[id] or {};local f=tp.skirtSize
        Log("[RushV9] construction deferred before assignment: "..tostring(id).." "..tostring(reason)
            .." skirt="..(type(f)=="table" and (tostring(f.x).."x"..tostring(f.y)) or type(f)),true)
    elseif valid then placementWarnings[id]=nil end
    return valid
end
-- Only unassigned and genuinely idle engineers may lose abandoned plan data.
-- Paid work and explicit orders are never made idle merely to satisfy a former.
function PrepareIdleBuilder(u,plans)
    plans=plans or CleanupPlans
    if not u or u.platoon or not Own(u.army,u) or Working(u) or u.buildBehaviorIsActive or u.reclaimBehaviorIsActive
        or u.CaptureInProgress or u.ReclaimInProgress or u.toggles and u.toggles.Pause
        or type(u.GetPause)=="function" and u:GetPause() then return false end
    if u.scoCommanderPodOwner or u.scoSourcePodOwner then return false end
    local orders=u.orders
    if orders and (orders.activeOrder or (orders.queuedOrders and next(orders.queuedOrders))) then return false end
    -- Failed reclaim plans may leave only this AI intent behind. With no
    -- owning platoon, native work or accepted order it must not block reuse.
    u.unitToReclaim=nil
    if not plans or type(plans.ClearUnitTemporaryPlatoonData)~="function" then return true end
    local ai=u.ai
    if ai and (ai.reservedEco or ai.eState or ai.path or ai.buildRange or ai.rushAbandonedWork) then
        if type(plans.ClearConstructionBuilderEconomyReservation)=="function" then
            plans.ClearConstructionBuilderEconomyReservation(u)
        elseif ai.reservedEco then AF.ClearReserveEco(u.army.id,u.id.index) end
        plans.ClearUnitTemporaryPlatoonData(u,"RC3 abandoned idle assignment")
        ai.rushAbandonedWork=nil
    end
    return true
end
function AllowedTarget(id,private)
    local tp=__Templates.Units[id]
    if not tp or (Available[id]~=true and not(private and Available[id]==nil)) then return false end
    if Has(tp,"DEMO_UI_ONLY") or Has(tp,"SCFA_CIVILIAN") or Has(tp,"SCFA_UNSELECTABLE")
        or Has(tp,"SCFA_INSIGNIFICANTUNIT") or Has(tp,"HYDROCARBON")
        or Has(tp,"SCFA_HYDROCARBON") then return false end
    local addition=tp.additions or {}
    if addition.faHydrocarbonPlacement or addition.scoMockHydro
        or (addition.scoHydroPlacement and addition.scoHydroPlacement.normalConstructionSupported==false) then return false end
    if id=="ucs1614" or id=="uss1614" then return false end
    return PlacementReady(id)
end
function CanBuilderBuild(u,id)
    if not u or u.dead or not buildQueueUtils or type(buildQueueUtils.CanBuild)~="function" then return false end
    local tp=__Templates.Units[id]
    if not tp or not u.construction or not HeavyPolicy.AllowsTarget(u.army,id) then return false end
    local faction
    for index in ipairs(Factions) do
        if HeavyPolicy.FactionMatches(index,u.tp) then faction=index;break end
    end
    if not faction or not HeavyPolicy.FactionMatches(faction,tp) then return false end
    local ok,allowed=pcall(buildQueueUtils.CanBuild,u,id,1,false)
    return ok and allowed==true
end

-- Select only a target that an actual selected builder can construct. The old
-- category-only random choice admitted hidden hydrocarbons and unavailable ports.
function SelectStructures(armyIndex,baseName,former,override,maxUnits)
    local army=Armies[armyIndex]
    local builders=override or AF.GetNeedMobileBuilder(armyIndex,baseName,former)
    if not army or not builders then return false end
    local shieldLayout=former.RushEmergencyShield and Import("AI/mods/AI-Scom/RushBaseLayout.lua")
    local groundLayout=former.RushGroundDefense and Import("AI/mods/AI-Scom/RushBaseLayout.lua")
    local storageLayout=former.RushAdjacencyStorage and Import("AI/mods/AI-Scom/RushBaseLayout.lua")
    local fabrication=former.RushMassFabrication and Import("AI/mods/AI-Scom/RushMassFabrication.lua")
    local beachhead=former.RushBeachhead and Import("AI/mods/AI-Scom/RushBeachhead.lua")
    local function funded(u,id)
        if shieldLayout then return shieldLayout.CanFundEmergencyShield(u,id) end
        if groundLayout then return Rules.CanFundGroundDefense(u,id) end
        if storageLayout then return Rules.CanFundAdjacencyStorage(u,id) end
        if fabrication then return fabrication.CanFund(u,id) end
        if beachhead then return beachhead.CanFund(u,id) end
        return former.AllowEcoStorageDrain or Rules.Affordable(u,id)
    end
    local result={}
    for _,line in ipairs(former.WantStructures or {}) do
        local choices={}
        for id,enabled in pairs(line) do
            local tp=__Templates.Units[id]
            if enabled and AllowedTarget(id,false) and Footprint(tp)
                and (not shieldLayout or shieldLayout.IsEmergencyShieldTemplate(tp))
                and (not groundLayout or groundLayout.IsGroundDefenseTemplate(tp,former.RushGroundDefense))
                and (not storageLayout or storageLayout.StorageKind(tp)==former.RushAdjacencyStorage)
                and (not fabrication or fabrication.IsFabricator(tp)) then
                for _,u in ipairs(builders) do
                    if Own(army,u) and CanBuilderBuild(u,id)
                        and funded(u,id) then
                        for _,faction in ipairs(Factions) do
                            if Has(u.tp,faction) then
                                choices[faction]=choices[faction] or {}
                                choices[faction][#choices[faction]+1]=id
                                break
                            end
                        end
                        break
                    end
                end
            end
        end
        local selected={}
        for faction,ids in pairs(choices) do
            -- Ordinary requests keep the least expensive valid option. A funded
            -- bombardment response ranks real Bubble coverage/strength first.
            table.sort(ids,function(a,b)
                if shieldLayout then
                    local ap=shieldLayout.EmergencyShieldPreference(__Templates.Units[a])
                    local bp=shieldLayout.EmergencyShieldPreference(__Templates.Units[b])
                    if ap~=bp then return ap>bp end
                end
                local ac=((__Templates.Units[a].economy or {}).cost or {}).alloys or math.huge
                local bc=((__Templates.Units[b].economy or {}).cost or {}).alloys or math.huge
                return ac==bc and a<b or ac<bc
            end)
            selected[faction]=ids[1]
        end
        if next(selected) then result[#result+1]=selected end
    end
    return #result>0 and #result==#(former.WantStructures or {}) and result or false
end

-- A mobile experimental has a footprint but need not have a structure skirt.
-- Feed that footprint to the SAME native placement validator without editing the
-- shared template. Terrain, resource spots, collisions and playable bounds remain.
function MobilePlacement(armyIndex,id,pos,spacing)
    local army=Armies[armyIndex];local tp=__Templates.Units[id]
    local f=Footprint(tp)
    if not army or not f or not pos or not Inside(pos) then return false end
    spacing=spacing or 0
    local a=AF.GetPlayableArea();local sx,sz=f.x+spacing,f.y+spacing
    if pos.x-sx/2<a.x or pos.z-sz/2<a.y or pos.x+sx/2>a.x+a.width or pos.z+sz/2>a.y+a.height then return false end
    local key=math.floor(pos.x).."-"..math.floor(pos.z)
    if army.ai.blacklistedBuildPlaces and army.ai.blacklistedBuildPlaces[key] then return false end
    if not MG.IsPathMapPathable(pos) then return false end
    local terrain=Has(tp,"NAVAL") and not Has(tp,"LAND") and 3 or 2
    return AF.CheckBuildStructureAt(SnapToGround(pos),f,terrain,Has(tp,"ALLOYS_EXTRACTION"))==true
end

local Development,EconomyPolicy
local function ExtractorUpgradeFunded(u,force)
    EconomyPolicy=EconomyPolicy or Import("AI/mods/AI-Scom/RushEconomyPolicy.lua")
    return EconomyPolicy.CanUpgradeExtractor(u,force and Rules.CurrentSnapshot(u.army,true) or nil)
end
local function DevelopmentUpgradeFunded(u,former)
    if not Development then Development=Import("AI/mods/AI-Scom/RushDevelopment.lua") end
    return not AF.IsUnderAttack(u)
        and (not former or Development.IsCommittedFactory(u.army,u,former))
        and Development.CanFundFactoryUpgrade(u)
end

function StartUpgrade(u)
    u.ai=u.ai or {}
    if u.dead or Now()<(u.ai.rushUpgradeRetry or 0) then return "Disband" end
    local data=u.platoon and u.platoon.ai
    if data then data.rushUpgradeHeartbeat=Now() end
    local f=data and data.formerTable
    local id=type(u.GetUpgradeTpId)=="function" and u:GetUpgradeTpId()
    if not f or not id or not __Templates.Units[id] then return "Disband" end
    if UpgradeTarget(u) then return "Upgrading" end
    -- Finish the present product first, never discard a factory's paid queue.
    if u.buildQueue and next(u.buildQueue) then
        for _,item in ipairs(u.buildQueue) do if item.tpId==id then u.ai.rushUpgradeId=id;return "Upgrading" end end
        return "Disband"
    end
    if IsRushArmy and IsRushArmy(u.army) and Rules.FactoryDomain(u.tp) and not f.RushTechProject then return "Disband" end
    if not CanBuilderBuild(u,id) then u.ai.rushUpgradeRetry=Now()+30;return "Disband" end
    if not f.AllowEcoStorageDrain and not AF.IsBuildableWithoutEconStorageDrain(u.army.id,u.tpId,id) then return "Disband" end
    if f.RushTechProject then
        if not DevelopmentUpgradeFunded(u,f) then return "Disband" end
    elseif Has(u.tp,"ALLOYS_EXTRACTION") then
        if not ExtractorUpgradeFunded(u,true) then return "Disband" end
    elseif not Rules.UpgradePreservesTechBudget(u,id) then return "Disband" end
    u.ai.rushUpgradeId=id;u.ai.rushUpgradeSubmitted=Now();u.ai.rushUpgradeMissingSince=nil
    local queued=buildQueueUtils.AddToBuildQueue(u,id,buildQueueUtils.NewEntryIds(1))
    if queued or UpgradeTarget(u) or (u.buildQueue and next(u.buildQueue)) then return "Upgrading" end
    u.ai.rushUpgradeRetry=Now()+30;u.ai.rushUpgradeId=nil
    return "Disband"
end
-- A stopped upgrade owner can outlive its native work. Retire only its
-- abandoned assignment/metadata; orders, native queues and paid targets stay.
function ReconcileUpgrade(u)
    if not u or not Own(u.army,u) then return end
    local ai=u.ai;local id=ai and ai.rushUpgradeId
    local p=u.platoon;local data=p and p.ai;local f=data and data.formerTable
    local owner=p and not p.dead and not p.deleted and u.army:PlatoonExists(p)
        and data and f and f.AIPlan=="planUpgradeStructure"
    if not ai or not id and not owner then return end
    local nativeId=type(u.GetUpgradeTpId)=="function" and u:GetUpgradeTpId()
    local live=UpgradeTarget(u)~=nil
    for _,item in ipairs(u.buildQueue or {}) do
        if item.tpId==id or item.tpId==nativeId then live=true;break end
    end
    local now=Now();local thread=owner and p.aiThread
    local heartbeat=owner and data.rushUpgradeHeartbeat
    if owner and thread and (type(thread)~="thread" or coroutine.status(thread)~="dead")
        and heartbeat and now>=heartbeat and now-heartbeat<=10 then live=true end
    if live then ai.rushUpgradeOrphan=nil;return end
    local orphan=ai.rushUpgradeOrphan
    if not orphan or orphan.id~=id or orphan.owner~=p or orphan.ownerAI~=data
        or orphan.armyAI~=u.army.ai or now<orphan.since then
        ai.rushUpgradeOrphan={id=id,owner=p,ownerAI=data,armyAI=u.army.ai,since=now}
    elseif now-orphan.since>=10 then
        ai.rushUpgradeId=nil;ai.rushUpgradeSubmitted=nil;ai.rushUpgradeMissingSince=nil
        ai.rushUpgradeOrphan=nil
        ai.rushUpgradeRetry=now+20
        if owner and u.platoon==p and p.ai==data then
            if type(thread)=="thread" and coroutine.status(thread)~="dead" then KillThread(thread) end
            if p.aiThread==thread then p.aiThread=nil end
            ai.eState=nil
            p:OnUnitRemoved(u)
        end
    end
end
function UpdateUpgrade(u)
    if u.dead then return "Disband" end
    local data=u.platoon and u.platoon.ai
    if data then data.rushUpgradeHeartbeat=Now() end
    local target=UpgradeTarget(u)
    if target then
        if target:IsCompleted() then u.ai.rushUpgradeId=nil;return "Disband" end
        -- Pausing, damage, and resource starvation do not invalidate paid work.
        u.ai.rushUpgradeMissingSince=nil
        return "Upgrading"
    end
    for _,item in ipairs(u.buildQueue or {}) do
        if item.tpId==u.ai.rushUpgradeId then return "Upgrading" end
    end
    if u.tpId==u.ai.rushUpgradeId then u.ai.rushUpgradeId=nil;return "Disband" end
    u.ai.rushUpgradeMissingSince=u.ai.rushUpgradeMissingSince or Now()
    if Now()-u.ai.rushUpgradeMissingSince<10 then return "Upgrading" end
    u.ai.rushUpgradeRetry=Now()+20;u.ai.rushUpgradeId=nil
    return "Disband"
end

function Install(isRush)
    IsRushArmy=isRush
    if installed then return end
    installed=true
    -- Older supplied hosts use only this field for native base membership.
    -- Newer hosts retain their own setter and any indexed bookkeeping.
    if AF.SetUnitBaseAssignment==nil then
        AF.SetUnitBaseAssignment=function(index,unit,baseName)
            local army=Armies[index]
            if not army or not army.ai or not Own(army,unit)
                or baseName~=nil and not (army.ai.bases and army.ai.bases[baseName]) then return false end
            unit.assignedToBase=baseName
            return true
        end
    end
    local oldStrategy=AF.IsStrategyActive
    AF.IsStrategyActive=function(index,base,name,...)
        if IsRushArmy(Armies[index]) and name=="OpeningEconomyFocus" then return Rules.OpeningFocus(Armies[index]) end
        return oldStrategy(index,base,name,...)
    end
    local oldSelect=AF.GetWantStructures
    AF.GetWantStructures=function(index,base,former,...)
        if IsRushArmy(Armies[index]) then return SelectStructures(index,base,former,...) end
        return oldSelect(index,base,former,...)
    end
    local oldClear=AF.ClearReserveEco
    AF.ClearReserveEco=function(index,id)
        local army=Armies[index]
        if IsRushArmy(army) and not (army.ai.ecoReserve or {})[id] then
            local u=army.units[id];if u and u.ai then u.ai.reservedEco=nil end
            return
        end
        return oldClear(index,id)
    end
    local oldPlace=AF.CanBuildStructureAt
    AF.CanBuildStructureAt=function(index,id,pos,spacing)
        local tp=__Templates.Units[id]
        if IsRushArmy(Armies[index]) and not PlacementContract(id,pos) then return false end
        if IsRushArmy(Armies[index]) and tp and not tp.skirtSize then
            return MobilePlacement(index,id,pos,spacing)
        end
        return oldPlace(index,id,pos,spacing)
    end
    local oldUnits=AF.GetNeedUnits
    AF.GetNeedUnits=function(index,base,former)
        if not IsRushArmy(Armies[index]) then return oldUnits(index,base,former) end
        if former.RushHeavyCombat then
            return Import("AI/mods/AI-Scom/RushHeavyConstruction.lua").GetCombatUnits(index,base,former)
        end
        if not former.NeedUnits then return oldUnits(index,base,former) end
        local single={};for key,value in pairs(former) do single[key]=value end
        for _,line in ipairs(former.NeedUnits) do
            single.NeedUnits={line}
            local units,minimum,maximum,reserve=oldUnits(index,base,single)
            if units then
                local valid={}
                for _,u in ipairs(units) do
                    if not HeavyPolicy.IsT4(u.tp) then valid[#valid+1]=u end
                end
                if #valid>=(minimum or 1)+(reserve or 0) then return valid,minimum,maximum,reserve end
            end
        end
        return false
    end
    local oldBuilders=AF.GetNeedMobileBuilder
    AF.GetNeedMobileBuilder=function(index,base,former)
        if not IsRushArmy(Armies[index]) then return oldBuilders(index,base,former) end
        local need=former.NeedMobileBuilder
        if not need then return oldBuilders(index,base,former) end
        for _,line in ipairs(need) do
            local minimum,maximum,reserve=line[2] or 1,line[3] or 1,line[4] or 0
            maximum=math.max(minimum,Rules.PowerBuilderMaximum(Armies[index],former,maximum))
            -- Retain partial native teams before adding bounded idle workers
            -- in the native return/recruit radius gap; enforce reserves below.
            local all=AF.GetEngineersAssignedToBasePool(index,base,line[1],former.WantStructures and 0 or minimum+reserve)
            if former.WantStructures then
                all=Import("AI/mods/AI-Scom/RushExpansion.lua").Builders(Armies[index],base,former,all,line[1])
            end
            local valid={}
            local protected=Rules.ProtectedPowerBuilder(Armies[index],former)
            for _,u in ipairs(all or {}) do
                local orders=u.orders
                if u~=protected and not HeavyPolicy.IsT4(u.tp)
                    and not u.scoCommanderPodOwner and not u.scoSourcePodOwner
                    and not BuilderRecallReserved(u,former.RushBuilderRecallOwner) and not Working(u) and not (orders and (orders.activeOrder
                    or (orders.queuedOrders and next(orders.queuedOrders)))) and PrepareIdleBuilder(u) then valid[#valid+1]=u end
            end
            if former.RushEmergencyShield then
                local layout=Import("AI/mods/AI-Scom/RushBaseLayout.lua")
                valid=layout.EmergencyShieldBuilders(Armies[index],base,valid) or {}
            elseif former.RushGroundDefense then
                local layout=Import("AI/mods/AI-Scom/RushBaseLayout.lua")
                valid=layout.GroundDefenseBuilders(Armies[index],base,former.RushGroundDefense,valid) or {}
            elseif former.RushAdjacencyStorage then
                local layout=Import("AI/mods/AI-Scom/RushBaseLayout.lua")
                valid=layout.StorageBuilders(Armies[index],base,former.RushAdjacencyStorage,valid) or {}
            elseif former.RushBeachhead then
                valid=Import("AI/mods/AI-Scom/RushBeachhead.lua").Builders(Armies[index],base,valid) or {}
            end
            if #valid>=minimum+reserve then
                if not former.RushGroundDefense and not former.RushAdjacencyStorage
                    and not former.RushBeachhead and not former.RushEmergencyShield then
                    table.sort(valid,function(a,b)
                        local function tier(u)
                            if Has(u.tp,"COMMAND") then return 4 end
                            for t=3,1,-1 do if Has(u.tp,"TECH"..t) then return t end end
                            return 1
                        end
                        local at,bt=tier(a),tier(b)
                        return at==bt and a.id.index<b.id.index or at<bt
                    end)
                end
                -- Don't include spare T3 engineers in a T1 job's oversized
                -- candidate group. Explicit high-tier formers retain their builders.
                local last=valid[math.min(#valid,maximum+reserve)]
                local limit=last and ((last.tp.general or {}).techNumber or (Has(last.tp,"TECH3") and 3 or Has(last.tp,"TECH2") and 2 or 1))
                if former.WantStructures and limit and not former.LoadedTech4Domain then
                    local canLow=true
                    for _,targets in ipairs(former.WantStructures) do
                        local found=false
                        for id,on in pairs(targets) do
                            if on and AllowedTarget(id,false) then
                                for i=1,math.min(#valid,maximum+reserve) do
                                    if CanBuilderBuild(valid[i],id) then found=true;break end
                                end
                            end
                            if found then break end
                        end
                        if not found then canLow=false;break end
                    end
                    if canLow then
                        local low={}
                        for i=1,math.min(#valid,maximum+reserve) do low[#low+1]=valid[i] end
                        valid=low
                    end
                end
                return valid,minimum,maximum,reserve
            end
        end
        return false
    end
    local oldEco=AF.CheckEcoStorageDrain
    AF.CheckEcoStorageDrain=function(index,base,former)
        if IsRushArmy(Armies[index]) and former.NeedMobileBuilder and former.WantStructures
            and former.AllowEcoStorageDrain==false then
            local list=SelectStructures(index,base,former)
            return list and #list==#former.WantStructures or false
        end
        if IsRushArmy(Armies[index]) and former.NeedMobileBuilder and not former.WantStructures
            and former.AllowEcoStorageDrain==false and (former.AssistBuildUnits or former.AssistUpgradeUnits) then
            local targets
            if former.AssistBuildUnits then targets=AF.GetUnitsThatDesiresBuildAssistAtBase(index,base,former)
            else targets=AF.GetUnitsThatDesiresUpgradeAssistAtBase(index,base,former) end
            local builders=AF.GetNeedMobileBuilder(index,base,former)
            for _,u in ipairs(builders or {}) do
                for _,target in pairs(targets or {}) do if Rules.AssistAffordable(u,target,false) then return true end end
            end
            return false
        end
        return oldEco(index,base,former)
    end
    local oldUpgrade=AF.GetNeedUpgradeableUnit
    AF.GetNeedUpgradeableUnit=function(index,base,former)
        local units,min,max,reserve=oldUpgrade(index,base,former)
        local army=Armies[index]
        if IsRushArmy(army) and former.AIPlan=="planAlloyExtractorUpgrade" then
            -- This one persistent MAIN owner manages extractors army-wide.
            -- Its startup cannot depend on an unfinished home technology tier.
            local need=former.NeedUpgradeableUnit and former.NeedUpgradeableUnit[1]
            if need and army.ai.bases and army.ai.bases[base] then
                units={};min,max,reserve=need[2],need[3],need[4]
                for _,u in pairs(army.units or {}) do
                    local orders=u.orders
                    if Rules.Own(army,u) and not u.platoon and u:IsCompleted()
                        and u:HasTags(need[1]) and not Working(u)
                        and not (type(u.GetPause)=="function" and u:GetPause())
                        and not (orders and (orders.activeOrder or orders.queuedOrders and next(orders.queuedOrders))) then
                        local id=type(u.GetUpgradeTpId)=="function" and u:GetUpgradeTpId()
                        if id and AllowedTarget(id,false) and CanBuilderBuild(u,id) then units[#units+1]=u end
                    end
                end
            end
        end
        if not units or not IsRushArmy(army) then return units,min,max,reserve end
        local valid={}
        units=Rules.HomeUpgradeCandidates(army,units)
        for _,u in ipairs(units) do
            if not Working(u) and Now()>=(u.ai and u.ai.rushUpgradeRetry or 0)
                and (not Rules.FactoryDomain(u.tp) or former.RushTechProject)
                and (not Has(u.tp,"ALLOYS_EXTRACTION") or former.AIPlan=="planAlloyExtractorUpgrade" or ExtractorUpgradeFunded(u))
                and (former.AIPlan=="planAlloyExtractorUpgrade"
                    or former.RushTechProject and DevelopmentUpgradeFunded(u,former)
                    or not former.RushTechProject and Rules.UpgradePreservesTechBudget(u,
                        type(u.GetUpgradeTpId)=="function" and u:GetUpgradeTpId())) then valid[#valid+1]=u end
        end
        if #valid<(min or 1)+(reserve or 0) then return false end
        return valid,min,max,reserve
    end
end
