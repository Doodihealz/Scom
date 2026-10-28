-- Idle ACU construction, repair and salvage remain owned by its combat platoon.
-- Native orders dispatch shoulder pods; no pod is created or directly retasked.
Version = "9.0.25-rc30"
local Rules=Import("AI/mods/AI-Scom/RushBalance.lua")
local HeavyPolicy=Import("AI/mods/AI-Scom/RushHeavyPolicy.lua")
local AF=Import("AI/AIFunctions.lua")
local MG=Import("AI/AIMarkerGenerator.lua")
local Orders=Import("host/managers/orders/hostOrderManager.lua")
local Tasks=Import("common/commonOrders.lua").OrderTasks
local R=Import("AI/mods/AI-Scom/RushReliability.lua")
local Safe=Import("AI/mods/AI-Scom/RushExpansion.lua").Safe
local Log=Import("AI/debugUtilities.lua").AILog
local function Now() return GetGameTimeSeconds() end
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local function Copy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function Valid(u) return u and not u.dead and not u.deleted end
local function Busy(u) return u.orders and (u.orders.activeOrder or (u.orders.queuedOrders and next(u.orders.queuedOrders))) end
local function ExclusiveOrder(unit,order)
    if not order then return false end
    local orders=unit.orders or {};local found=orders.activeOrder==order
    if orders.activeOrder and not found then return false end
    for _,queued in pairs(orders.queuedOrders or {}) do
        if queued~=order then return false end
        found=true
    end
    return found
end
local function ServiceAssignment(platoon,unit,data,record)
    return record and platoon and unit and data and record.unit==unit
        and record.army==unit.army and unit.army.ai==record.armyAI
        and record.platoon==platoon and record.platoonAI==data and record.unitAI==unit.ai
        and R.CurrentAssignment(unit,record.army,platoon,record.unitAI,data)
end
local function ReleaseServiceOrder(platoon,unit,data,record)
    if not ServiceAssignment(platoon,unit,data,record) or not record.order then return end
    local orders=unit.orders or {}
    for i=#(orders.queuedOrders or {}),1,-1 do
        if orders.queuedOrders[i]==record.order then
            Orders.RemoveUnitFromQueuedOrder(unit,record.order)
        end
    end
    if orders.activeOrder==record.order then
        Orders.RemoveUnitFromActiveOrder(unit)
        if ServiceAssignment(platoon,unit,data,record) then Orders.TryStartNextOrderForUnit(unit) end
    end
end
local function ActiveWork(target)
    if not Valid(target) or target.CaptureInProgress or target.ReclaimInProgress
        or target.scoCommanderPodOwner or target.scoSourcePodOwner then return nil end
    local factory=target:IsCompleted() and R.Has(target.tp,"FACTORY") and R.Has(target.tp,"STRUCTURE")
    local product
    if factory then
        if R.UpgradeTarget(target) or target.upgradeBehaviorIsActive
            or type(target.GetPause)=="function" and target:GetPause() then return nil end
        product=target.productionBehaviorIsActive and target.productionBehaviorTargetUnit or target.unitBeingBuilt
    elseif not target:IsCompleted() and (R.Has(target.tp,"STRUCTURE") or HeavyPolicy.IsFirstTarget(target))
        and not (R.Has(target.tp,"FACTORY") and target.upgrader) then product=target
    end
    if not Rules.Own(target.army,product) or product:IsCompleted()
        or product.hasBeenPromotedFromPlacementGhost~=true then return nil end
    local tp=product.tp
    if not factory then return (R.Has(tp,"STRUCTURE") or HeavyPolicy.IsFirstTarget(product)) and product or nil end
    if not R.Has(tp,"MOBILE") or R.Has(tp,"COMMAND")
        or R.Has(tp,"SCOUT") or R.Has(tp,"TRANSPORT") then return nil end
    if R.Has(tp,"ENGINEER") then return product end
    for _,weapon in ipairs(tp.weapons or {}) do
        if (AF.GetWeaponDamagePerSecond(weapon) or 0)>0 then return product end
    end
end
local function PaidStructure(unit,target)
    if target and (Rules.Own(unit.army,target) and R.Has(target.tp,"STRUCTURE")
        or HeavyPolicy.CanAssistFirst(unit.army,target))
        and target.hasBeenPromotedFromPlacementGhost==true and not target:IsCompleted() then return target end
end
-- Native ownership survives a paused beam or a one-tick completion handoff.
-- A different active order is authoritative; stale builder fields never override it.
function ConstructionTarget(unit)
    if not Valid(unit) or not unit.army then return nil end
    local orders=unit.orders or {}
    local function fromOrder(order)
        if order.orderTask==Tasks.BUILD then return PaidStructure(unit,order.unitGettingBuilt) end
        if order.orderTask==Tasks.ASSISTUNIT or order.orderTask==Tasks.REPAIR then
            local target=PaidStructure(unit,order.targetUnit)
            if target then return target end
            if order.orderTask==Tasks.ASSISTUNIT and unit.assistBehaviorIsActive
                and unit.assistBehaviorAssistedUnit==order.targetUnit then
                return PaidStructure(unit,unit.unitBeingBuilt)
                    or unit.buildBehaviorIsActive and PaidStructure(unit,unit.buildBehaviorActualUnit)
            end
        end
    end
    if orders.activeOrder then return fromOrder(orders.activeOrder) end
    if orders.queuedOrders and next(orders.queuedOrders) then
        for _,order in ipairs(orders.queuedOrders) do
            local target=fromOrder(order)
            if target then return target end
        end
        return nil
    end
    return PaidStructure(unit,unit.unitBeingBuilt)
        or unit.buildBehaviorIsActive and PaidStructure(unit,unit.buildBehaviorActualUnit) or nil
end
-- Price every pod that native assistance can engage, but credit only builders
-- registered in the native paid routine, never an approach to the product.
function AssistRates(unit,product)
    local econ=product and product.tp and product.tp.economy
    local cost=econ and econ.cost;local bt=econ and econ.buildTime
    if type(bt)~="number" or bt<=0 or type(cost)~="table" then return nil end
    local power,active,activeMass,activeEnergy=0,0,0,0
    local seen={}
    local function add(builder)
        if not Rules.Own(unit.army,builder) or not builder.construction or seen[builder] then return end
        seen[builder]=true
        power=power+math.max(0,builder.construction.buildPower or 0)
        local mass,energy,registered=0,0,0
        if builder.unitBeingBuilt==product then
            mass,energy,registered=Rules.RegisteredBuildRates(builder)
        elseif builder.unitBeingRepaired==product then
            mass,energy,registered=Rules.RegisteredBuildRates(builder,product)
        end
        active=active+registered
        activeMass=activeMass+mass;activeEnergy=activeEnergy+energy
    end
    add(unit)
    for _,pod in pairs(unit.scoCommanderEnhancements and unit.scoCommanderEnhancements._pods or {}) do
        if Valid(pod) and pod.scoCommanderPodOwner==unit.id then add(pod) end
    end
    if power<=0 then return nil end
    local mass,energy=(cost.alloys or 0)/bt,(cost.energy or 0)/bt
    return power*mass,power*energy,activeMass,activeEnergy,power,active
end
local function Affordable(unit,product,mass,energy,repair)
    local mr,er,activeMass,activeEnergy,power,active=AssistRates(unit,product)
    if not mr or not mass or not energy then return false end
    -- Fund only this current product. A factory changing products is rechecked
    -- before assistance continues; storage never underwrites its whole queue.
    local fraction=not repair and type(product.GetFractionComplete)=="function" and product:GetFractionComplete() or 0
    local remaining=math.max(0,1-fraction)
    local duration=math.max(5,product.tp.economy.buildTime*remaining/power)
    if not repair then
        local cost=product.tp.economy.cost
        -- The final fraction cannot consume five full seconds of construction.
        mr=math.min(mr,(cost.alloys or 0)*remaining/duration)
        er=math.min(er,(cost.energy or 0)*remaining/duration)
    end
    local function cover(resource,rate,credit)
        local bank=math.max(0,resource.current-resource.storage*0.25)/duration
        return Rules.Balance(resource)+credit+bank>=rate
    end
    return cover(mass,mr,activeMass) and cover(energy,er,activeEnergy),active>0
end
local function ClearReservation(unit,record)
    HeavyPolicy.ReleaseFirstAssist(record.firstAssist);record.firstAssist=nil
    local army,armyAI=record.army,record.armyAI
    local owner=record.unit or unit
    local index=owner and owner.id and owner.id.index
    local reserves=armyAI and armyAI.ecoReserve
    if record.reservation and reserves and index and reserves[index]==record.reservation then
        if army.ai==armyAI and Rules.Own(army,owner) and owner.ai==record.unitAI then
            AF.ClearReserveEco(army.id,index)
        else reserves[index]=nil end
    end
    record.reservation=nil
end
local function Block(unit,target,product,seconds)
    local blocked=unit.ai.rushServiceBlocked
    if not blocked then blocked=setmetatable({},{__mode="k"});unit.ai.rushServiceBlocked=blocked end
    blocked[target]={product=product~=target and product or nil,untilTime=Now()+seconds}
end
local function Blocked(unit,target,product)
    local blocked=unit.ai.rushServiceBlocked
    local entry=blocked and blocked[target]
    if not entry then return false end
    if entry.untilTime<=Now() or (entry.product or target)~=product then blocked[target]=nil;return false end
    return true
end
function Stop(platoon,unit,reason,expectedAI)
    local data=expectedAI or platoon and platoon.ai
    local record=data and data.rushCommanderService
    local owned=platoon and unit and ServiceAssignment(platoon,unit,data,record)
    if data then
        data.rushCommanderService=nil
        data.commanderProductionAssistFactory=nil
        data.commanderProductionAssistObservedUnit=nil
    end
    if not record then return false end
    -- The reservation belongs to the old record even after a platoon handoff.
    ClearReservation(unit,record)
    if owned then
        if not ServiceAssignment(platoon,unit,data,record) then return true end
        local active=unit.scoCommanderEnhancements and unit.scoCommanderEnhancements.active
        -- Finish old metadata before native UnitStart can publish replacement work.
        if record.kind=="reclaim" and unit.unitToReclaim==record.target then unit.unitToReclaim=nil end
        if record.kind=="repair" and unit.unitNeedRepair==record.target then unit.unitNeedRepair=nil end
        unit.ai=unit.ai or {}
        unit.ai.rushServiceRetry=0
        local delay=reason=="budget" and 8 or reason=="stalled" and 30
            or reason=="unsafe" and 15 or reason=="rejected" and 8
        if delay and Valid(record.target) then Block(unit,record.target,record.product,delay) end
        -- Withdraw only our exact order and let a queued replacement proceed.
        -- An enhancement or a new assignment always retains its own commands.
        if not active then ReleaseServiceOrder(platoon,unit,data,record) end
    end
    return true
end
local function CanAssist(unit,target)
    return type(unit.AssistBehaviorIsValidFor)=="function" and unit:AssistBehaviorIsValidFor(target)
end
local function NeedsRepair(army,target)
    return Rules.Own(army,target) and R.Has(target.tp,"STRUCTURE") and target:IsCompleted()
        and not R.UpgradeTarget(target) and not target.upgradeBehaviorIsActive
        and (target:GetHealth()<target:GetMaxHealth() or (target.captureProgress or 0)>0
            or (target.reclaimProgress or 0)>0)
end
local function ReclaimValue(target,mass)
    if not Valid(target) or not mass or mass.storage<=0 or mass.current>=mass.storage*0.90 then return 0 end
    local harvest=target.tp and target.tp.economy and target.tp.economy.harvest
    local value=harvest and harvest.alloys
    return type(value)=="number" and math.max(0,math.min(value,mass.storage-mass.current)) or 0
end
local function Progress(kind,target)
    if kind=="repair" then
        return target:GetHealth()/math.max(1,target:GetMaxHealth())
            -(target.captureProgress or 0)-(target.reclaimProgress or 0)
    elseif kind=="reclaim" then return target.reclaimProgress or 0 end
    return type(target.progress)=="number" and target.progress
        or type(target.GetFractionComplete)=="function" and target:GetFractionComplete() or 0
end
-- Include approaches and queued native orders, not just builders already firing
-- a reclaim beam. Allied engineers retain the same ten-unit salvage exclusion.
local function ClaimedWork(army,unit)
    local repairs,reclaims,seen={},{},{}
    local function reclaim(target)
        if Valid(target) and not seen[target] then
            seen[target]=true;reclaims[#reclaims+1]=Copy(target:GetPosition())
        end
    end
    for _,ally in pairs(Armies or {}) do
        if ally==army or army:IsAlly(ally) then
            for _,builder in pairs(ally.units or {}) do
                if builder~=unit and Rules.Own(ally,builder) then
                    for _,target in pairs({builder.unitNeedRepair,builder.unitBeingRepaired,
                        builder.repairBehaviorIsActive and builder.repairBehaviorTarget}) do
                        if Valid(target) then repairs[target]=true end
                    end
                    reclaim(builder.unitToReclaim);reclaim(builder.unitBeingReclaimed)
                    if builder.reclaimBehaviorIsActive then reclaim(builder.reclaimBehaviorTarget) end
                    local orders=builder.orders or {}
                    local function orderClaim(order)
                        if order and order.orderTask==Tasks.RECLAIM then reclaim(order.targetUnit)
                        elseif order and order.orderTask==Tasks.REPAIR and Valid(order.targetUnit) then repairs[order.targetUnit]=true end
                    end
                    orderClaim(orders.activeOrder)
                    for _,order in pairs(orders.queuedOrders or {}) do orderClaim(order) end
                end
            end
        end
    end
    return repairs,reclaims
end
local function Reserve(unit,record)
    if record.first then
        if record.firstAssist then return HeavyPolicy.RefreshFirstAssist(record.firstAssist) end
        record.firstAssist=HeavyPolicy.ReserveFirstAssist(unit,record.product)
        return record.firstAssist~=nil
    end
    local mass,energy,activeMass,activeEnergy=AssistRates(unit,record.product)
    if not mass then return false end
    mass=math.max(0,mass-activeMass);energy=math.max(0,energy-activeEnergy)
    if mass<=0 and energy<=0 then ClearReservation(unit,record);return true end
    local reserves=unit.army.ai.ecoReserve
    if reserves and reserves[unit.id.index] and reserves[unit.id.index]~=record.reservation then return false end
    if not record.reservation then
        AF.SetReserveEco(unit.army.id,unit.id.index,record.product.tpId,record.product:GetPosition())
        record.reservation=unit.army.ai.ecoReserve and unit.army.ai.ecoReserve[unit.id.index]
    end
    if record.reservation then
        record.reservation.resourcePerSecond=mass;record.reservation.energyPerSecond=energy
        record.reservation.rushCommanderService=record
    end
    return record.reservation~=nil
end
function Update(platoon,unit,sheltered)
    if not Valid(unit) or not Rules.Enabled(unit.army) or unit.army.ai.isAlive==false
        or not Rules.Own(unit.army,unit) then return false end
    unit.ai=unit.ai or {}
    local army,unitAI,data=unit.army,unit.ai,platoon and platoon.ai
    local armyAI=army.ai
    local function current()
        return army.ai==armyAI and R.CurrentAssignment(unit,army,platoon,unitAI,data)
    end
    if not current() then return false end
    local function savingUpgrade()
        local intent=unitAI.rushEnhanceIntent
        return intent and intent.phase=="funding" and intent.army==army and intent.armyAI==armyAI
            and intent.unit==unit and intent.unitAI==unitAI and intent.platoon==platoon and intent.platoonAI==data
            and armyAI.bases and intent.home==armyAI.bases.MAIN and intent.state==unit.scoCommanderEnhancements
            and type(intent.expires)=="number" and Now()<intent.expires
    end
    local abilities=unit.scoCommanderAbilities
    local enhancing=unit.scoCommanderEnhancements and unit.scoCommanderEnhancements.active
    if enhancing or (abilities and (abilities.teleport or abilities.missileLaunch)) then
        Stop(platoon,unit,"ability",data);return false
    end
    local paused=type(unit.GetPause)=="function" and unit:GetPause()
    if data.commanderFacesLethalDamage or data.commanderIsInImmediateDanger or data.commanderWithdrawalPhase
        or not (data.formerTable.AIPlanData or {}).AssistProductionWhenIdle then
        Stop(platoon,unit,"defence",data);return false
    end
    local base=data.basePosition;local pos=Copy(unit:GetPosition())
    local baseRadius=data.baseRadius or 60
    if not base or D2(pos,base)>baseRadius^2 or not Safe(army,pos) then
        Stop(platoon,unit,"unsafe",data);return false
    end
    local range=math.max(1,((unit.construction and unit.construction.range)
        or (unit.tp.construction and unit.tp.construction.range) or 10)-0.5)
    local travel=sheltered and range or math.max(range,math.min(60,baseRadius))
    local mass,energy=Rules.Resources(army,unit)
    local function inArea(target,product,checkRoute)
        local targetPos=Copy(target:GetPosition());local workPos=Copy(product:GetPosition())
        local distance=D2(pos,workPos)
        if distance>travel^2 or D2(pos,targetPos)>travel^2
            or D2(base,targetPos)>baseRadius^2 or D2(base,workPos)>baseRadius^2
            or not Safe(army,targetPos) or not Safe(army,workPos) then return false end
        if checkRoute and distance>range^2 and (not MG.CanGraphAreaTo(pos,workPos,data.movementLayer)
            or not Safe(army,{x=(pos.x+workPos.x)*0.5,y=pos.y,z=(pos.z+workPos.z)*0.5})) then return false end
        return true,distance
    end
    local function firstWork()
        if savingUpgrade() then return nil end
        local own=HeavyPolicy.FirstTarget(army)
        if own and not Blocked(unit,own,own) and HeavyPolicy.CanAssistFirst(army,own) and CanAssist(unit,own)
            and inArea(own,own,true) and HeavyPolicy.FirstAssistAffordable(unit,own) then return own end
        for _,ally in pairs(Armies or {}) do
            if ally~=army and army:IsAlly(ally) then
                local target=HeavyPolicy.FirstTarget(ally)
                if target and not Blocked(unit,target,target) and HeavyPolicy.CanAssistFirst(army,target) and CanAssist(unit,target)
                    and inArea(target,target,true) and HeavyPolicy.FirstAssistAffordable(unit,target) then return target end
            end
        end
    end
    local record=data.rushCommanderService
    if record then
        local kind=record.kind or "assist"
        if not ServiceAssignment(platoon,unit,data,record) or not ExclusiveOrder(unit,record.order) then
            Stop(platoon,unit,"replaced",data)
        else
            local product
            if kind=="assist" then
                if record.first then
                    product=HeavyPolicy.CanAssistFirst(army,record.target) and ActiveWork(record.target)
                else product=Rules.Own(army,record.target) and ActiveWork(record.target) end
            elseif kind=="repair" then product=NeedsRepair(army,record.target) and record.target
            elseif kind=="reclaim" then product=ReclaimValue(record.target,mass)>0 and record.target end
            local construction=kind=="assist" and product==record.target and ConstructionTarget(unit)==product
            local firstProduct=kind=="assist" and product and HeavyPolicy.IsFirstTarget(product)
            if firstProduct and not record.first and product==record.target then
                -- A foundation may enter the cached first-project census after
                -- this assist began. Adopt the exact order without interrupting it.
                ClearReservation(unit,record)
                record.first=true
                record.firstAssist=HeavyPolicy.ReserveFirstAssist(unit,product,record.order)
            end
            local reason
            if not product or kind=="assist" and not CanAssist(unit,record.target) then reason="complete"
            elseif record.first and paused then reason="paused"
            elseif record.first and (not record.firstAssist or not HeavyPolicy.CanAssistFirst(army,product)) then reason="budget"
            elseif firstProduct and not record.first then reason="first-experimental"
            elseif not inArea(record.target,product,false) then reason="unsafe"
            elseif not record.first and kind=="assist" and product~=record.target
                and not paused and firstWork() then reason="first-experimental"
            elseif not record.first and not construction and not paused and kind~="reclaim"
                and not Affordable(unit,product,mass,energy,kind=="repair") then reason="budget" end
            if not reason then
                local distance=D2(pos,product:GetPosition());local progress=Progress(kind,product)
                if record.product~=product then
                    record.product=product;record.progress=progress
                    record.bestDistance=distance;record.lastProgress=Now()
                elseif progress>record.progress or distance<record.bestDistance-1 then
                    record.progress=progress;record.bestDistance=math.min(record.bestDistance,distance)
                    record.lastProgress=Now()
                elseif not paused and Now()-record.lastProgress>=(construction and 30 or 15) then
                    local _,_,_,_,_,active=AssistRates(unit,product)
                    if record.first then
                        local entity=product.resourceEntities and product.resourceEntities.construction
                        local source=entity and entity.buildPowerSources and entity.buildPowerSources[unit.id]
                        active=source and source.buildPower or 0
                    end
                    -- Supply-limited paid construction retains its native order.
                    -- Only a stalled approach with no registered builder is released.
                    if not construction or not active or active<=0 then reason="stalled" end
                end
                if paused then record.lastProgress=Now() end
                if not reason and kind~="reclaim" then
                    if paused then ClearReservation(unit,record)
                    elseif not Reserve(unit,record) and (record.first or not construction) then
                        reason=record.first and "budget" or "reservation"
                    end
                end
            end
            if reason then Stop(platoon,unit,reason,data)
            else
                if kind=="assist" then data.commanderProductionAssistObservedUnit=product end
                return true
            end
        end
        -- Completed/rejected work can hand off now; its old product alone is
        -- deferred. Native cleanup may need a tick before another order is legal.
    end
    if R.Working(unit) or Busy(unit) or unit.buildBehaviorIsActive then return true end
    if paused or Now()<(unitAI.rushServiceRetry or 0) then return false end
    if unitAI.reservedEco or army.ai.ecoReserve and army.ai.ecoReserve[unit.id.index] then return false end
    local candidates={}
    local repairs,reclaims=ClaimedWork(army,unit)
    local canRepair=type(unit.CanConstructOthers)=="function" and unit:CanConstructOthers()
    local function add(kind,target,product,score,finish,first)
        if Blocked(unit,target,product) then return end
        local allowed,distance=inArea(target,product,true)
        if allowed then candidates[#candidates+1]={kind=kind,target=target,product=product,first=first,
            finish=first and 2 or finish and distance<=range^2 and 1 or 0,
            score=score+(distance<=range^2 and 100 or 0)-math.sqrt(distance)*4} end
    end
    -- Saving owns no new paid service; safe salvage remains useful. An old
    -- accepted job was handled above and is never cancelled by this flag alone.
    if not savingUpgrade() then
    for _,target in pairs(army.units or {}) do
        if target~=unit and Rules.Own(army,target) then
            local product=ActiveWork(target)
            local tp=product and product.tp
            local first=product and HeavyPolicy.IsFirstTarget(product)
            if product and CanAssist(unit,target) and (first and product==target and HeavyPolicy.FirstAssistAffordable(unit,product)
                or not first and Affordable(unit,product,mass,energy)) then
                local power=R.Has(tp,"ENERGY_PRODUCTION") and not R.Has(tp,"ALLOYS_EXTRACTION")
                local economy=R.Has(tp,"ALLOYS_EXTRACTION")
                local urgent=power and energy and (energy.ratio<0.35 or Rules.Balance(energy)<0)
                    or economy and mass and (mass.ratio<0.25 or Rules.Balance(mass)<0)
                local fraction=type(product.GetFractionComplete)=="function" and product:GetFractionComplete() or 0
                add("assist",target,product,(first and 1600 or urgent and 1050 or R.Has(tp,"ENGINEER") and 930
                    or economy and 900 or R.Has(tp,"FACTORY") and 860
                    or power and 810 or R.Has(tp,"TECH4") and 800 or R.Has(tp,"TECH3") and 740 or 650)
                    +math.max(0,math.min(1,fraction))*80,target==product and fraction>=0.90,first)
            end
            if canRepair and not repairs[target] and NeedsRepair(army,target)
                and Affordable(unit,target,mass,energy,true) then
                local fraction=target:GetHealth()/math.max(1,target:GetMaxHealth())
                if fraction<0.98 or (target.captureProgress or 0)>0 or (target.reclaimProgress or 0)>0 then
                    add("repair",target,target,540+(1-fraction)*220
                        +((R.Has(target.tp,"FACTORY") or R.Has(target.tp,"ENERGY_PRODUCTION")
                            or R.Has(target.tp,"ALLOYS_EXTRACTION") or R.Has(target.tp,"SHIELD")) and 100 or 0))
                end
            end
        end
    end
    for _,ally in pairs(Armies or {}) do
        if ally~=army and army:IsAlly(ally) then
            local target=HeavyPolicy.FirstTarget(ally)
            if target and HeavyPolicy.CanAssistFirst(army,target) and CanAssist(unit,target)
                and HeavyPolicy.FirstAssistAffordable(unit,target) then
                add("assist",target,target,1300,false,true)
            end
        end
    end
    end
    -- Salvage costs no new construction budget. Consider only native props,
    -- only when Alloy has storage headroom, and only outside other builders' claims.
    if #candidates==0 and canRepair and mass and mass.ratio<0.90 then
        for _,prop in pairs(__Entities and __Entities.Props or {}) do
            local value=ReclaimValue(prop,mass)
            if value>0 and not (prop.reclaimers and next(prop.reclaimers)) then
                local clear=true;local position=prop:GetPosition()
                for _,claimed in ipairs(reclaims) do if D2(position,claimed)<=100 then clear=false;break end end
                if clear then add("reclaim",prop,prop,500+math.min(160,math.sqrt(value)*8)) end
            end
        end
    end
    table.sort(candidates,function(a,b)
        return a.finish>b.finish or a.finish==b.finish
            and (a.score>b.score or a.score==b.score and a.target.id.index<b.target.id.index)
    end)
    for _,candidate in ipairs(candidates) do
        if not current() then return false end
        if R.Working(unit) or Busy(unit) or unit.buildBehaviorIsActive then return true end
        local target,product,kind=candidate.target,candidate.product,candidate.kind
        local task=kind=="assist" and Tasks.ASSISTUNIT or kind=="repair" and Tasks.REPAIR or Tasks.RECLAIM
        mass,energy=Rules.Resources(army,unit)
        pos=Copy(unit:GetPosition())
        local eligible=kind=="assist" and (candidate.first and HeavyPolicy.CanAssistFirst(army,target)
            or not candidate.first and Rules.Own(army,target)) and ActiveWork(target)==product and CanAssist(unit,target)
            or kind=="repair" and NeedsRepair(army,target)
            or kind=="reclaim" and ReclaimValue(target,mass)>0 and not (target.reclaimers and next(target.reclaimers))
        if eligible and (kind=="reclaim" or not savingUpgrade()) and inArea(target,product,false) then
            local nextRecord={kind=kind,target=target,product=product,first=candidate.first,lastProgress=Now(),
                unit=unit,unitAI=unitAI,army=army,armyAI=armyAI,platoon=platoon,platoonAI=data,
                bestDistance=D2(pos,product:GetPosition()),progress=Progress(kind,product)}
            if kind=="reclaim" or (candidate.first and HeavyPolicy.FirstAssistAffordable(unit,product)
                or not candidate.first and Affordable(unit,product,mass,energy,kind=="repair")) and Reserve(unit,nextRecord) then
                if kind=="reclaim" then unit.unitToReclaim=target
                elseif kind=="repair" then unit.unitNeedRepair=target end
                Orders.HostIssueOrder(task,{unit},false,Copy(target:GetPosition()),{targetGlobalId=target.id})
                if not current() then
                    ClearReservation(unit,nextRecord)
                    return false
                end
                local orders=unit.orders or {};local order=orders.activeOrder
                if not order or order.orderTask~=task or order.targetUnit~=target then
                    order=nil
                    for _,queued in pairs(orders.queuedOrders or {}) do
                        if queued.orderTask==task and queued.targetUnit==target then order=queued;break end
                    end
                end
                nextRecord.order=order
                if order and (not candidate.first or HeavyPolicy.CommitFirstAssist(nextRecord.firstAssist,order)) then
                    data.rushCommanderService=nextRecord
                    if kind=="assist" then
                        -- Enhancement accounting may credit only this actual assistance.
                        data.commanderProductionAssistFactory=target
                        data.commanderProductionAssistObservedUnit=product
                    end
                    Log("[RushV9] army="..army.id.." commander useful "..kind.."="..tostring(target.tpId)
                        .." unit="..target.id.index,true)
                    return true
                end
                ReleaseServiceOrder(platoon,unit,data,nextRecord)
                ClearReservation(unit,nextRecord)
                if kind=="reclaim" and unit.unitToReclaim==target then unit.unitToReclaim=nil end
                if kind=="repair" and unit.unitNeedRepair==target then unit.unitNeedRepair=nil end
            end
        end
        Block(unit,target,product,8)
    end
    unitAI.rushServiceRetry=Now()+3
    return false
end
