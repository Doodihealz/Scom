local RushUnitState = Import("AI/mods/AI-Scom/RushUnitState.lua")
-- Profile-owned static fire support. Construction, ammunition and firing use
-- the installed Sanctuary host contracts; no template or visibility changes.
Version = "9.1.1"
local Rules=Import("AI/mods/AI-Scom/RushBalance.lua")
local Economy=Import("AI/mods/AI-Scom/RushEconomyPolicy.lua")
local R=Import("AI/mods/AI-Scom/RushReliability.lua")
local Intel=Import("AI/mods/AI-Scom/RushCombatIntel.lua")
local Layout=Import("AI/mods/AI-Scom/RushBaseLayout.lua")
local Movement=Import("AI/mods/AI-Scom/RushMovement.lua")
local AF=Import("AI/AIFunctions.lua")
local MG=Import("AI/AIMarkerGenerator.lua")
local Orders=Import("host/managers/orders/hostOrderManager.lua")
local Tasks=Import("common/commonOrders.lua").OrderTasks
local Log=Import("AI/debugUtilities.lua").AILog
local function Now() return GetGameTimeSeconds() end
local function Copy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local function TargetKey(target) return target.id.index..":"..target.id.version end
local function Template(id) return __Templates.Units[id] end
local Has=Rules.Has
local function Tactical(tp) return tp and tp.additions and tp.additions.scoTactical end
function Kind(tp)
    if not Has(tp,"STRUCTURE") or Has(tp,"MOBILE") or Has(tp,"NUKE") or Rules.Tier(tp)>=4 then return nil end
    local c=Tactical(tp)
    if c and c.role=="launcher" and not c.autoIntercept and Rules.Tier(tp)==2 then return "tactical" end
    if Has(tp,"ARTILLERY") and Rules.Tier(tp)>=2 and not c then return "artillery" end
end
local function State(army)
    local s=army.ai.rushFireSupport
    if not s then s={units={},shots={},stationary={}};army.ai.rushFireSupport=s end
    return s
end
local function Range(tp)
    local c=Tactical(tp)
    if c then return c.rangeMin or 0,c.rangeMax or 0 end
    local minimum,maximum=0,0
    for _,w in ipairs(tp.weapons or {}) do
        if w.rangeRingType~="AntiAir" and (AF.GetWeaponDamagePerSecond(w) or 0)>0
            and (w.rangeMax or 0)>maximum then minimum,maximum=w.rangeMin or 0,w.rangeMax end
    end
    return minimum,maximum
end
local function GroundTarget(army,u)
    return Intel.Visible(army,u) and not Has(u.tp,"AIR") and not Has(u.tp,"NAVAL")
        and not (type(u.IsPlacementGhost)=="function" and u:IsPlacementGhost())
end
local function Objective(army,position,minimum,maximum,spatial)
    for _,record in ipairs(Intel.Get(army).enemy) do
        local target=record.unit
        if GroundTarget(army,target) and Has(target.tp,"STRUCTURE") then
            local targetPosition=target:GetPosition()
            local d=D2(position,targetPosition)
            if spatial then d=d+((position.y or 0)-(targetPosition.y or 0))^2 end
            if d>=(minimum+4)^2 and d<=math.max(0,maximum-4)^2 then return true end
        end
    end
    return false
end
local function AmmoRates(tp)
    local c=Tactical(tp);local bp=tp.construction and tp.construction.buildPower
    if not c or not c.cost or not bp or bp<=0 or not c.buildTime or c.buildTime<=0 then return nil end
    return (c.cost.alloys or 0)*bp/c.buildTime,(c.cost.energy or 0)*bp/c.buildTime,c.buildTime/bp
end
function CanFund(builder,id,snapshot,baseName)
    local army=builder and builder.army;local tp=Template(id)
    if not Rules.Own(army,builder) or not Kind(tp) or not R.CanBuilderBuild(builder,id) then return false end
    local base=army.ai.bases[baseName or builder.assignedToBase]
    local minimum,maximum=Range(tp)
    if not base or not Objective(army,base.position,math.max(0,minimum-math.min(base.radius,80)),
        maximum+math.min(base.radius,80)) then return false end
    local s=snapshot or Rules.CurrentSnapshot(army,false)
    if not s or not s.alloy or not s.energy or not Economy.CanStartTech(army,s)
        or s.alloy.techOwner or s.alloy.commanderOwner or s.alloy.heavyOwner or (s.upgrades or 0)>0
        or s.landPanic and Economy.GroundReady(s)<Economy.GroundFloor(s) then return false end
    local a,e=Rules.Resources(army,builder)
    local mass,energy,duration=Rules.ProjectRates(builder,id)
    if not a or not e or not mass or e.ratio<0.35 or a.income<12 or e.income<120 then return false end
    if Kind(tp)=="tactical" then
        local am,ae=AmmoRates(tp)
        if not am then return false end
        mass,energy=mass+am,energy+ae
    end
    duration=math.max(30,duration)
    return Rules.Balance(a)+math.max(0,a.current-a.storage*0.25)/duration>=mass
        and Rules.Balance(e)+math.max(0,e.current-e.storage*0.25)/duration>=energy
end
function Priority(army,snapshot,baseName,kind)
    local base=army.ai.bases[baseName]
    if not base or base.baseType=="NAVAL" or not snapshot.alloy or not snapshot.energy
        or snapshot.energy.ratio<0.35 or Economy.AlloyStalled(snapshot)
        or Economy.LandEnabled(army) and Economy.GroundReady(snapshot)<Economy.GroundFloor(snapshot) then return nil end
    local count,localCount=0,0
    for _,u in ipairs(snapshot.fireSupportUnits or {}) do
        if Rules.Own(army,u) and Kind(u.tp)==kind then
            count=count+1
            if D2(base.position,u:GetPosition())<=base.radius^2 then localCount=localCount+1 end
        end
    end
    for _,p in pairs(army.platoons or {}) do
        local f=p.ai and p.ai.formerTable
        if f and f.RushFireSupport==kind and not p.dead and army:PlatoonExists(p) then
            -- A spawned foundation is already included in the owned census.
            local spawned=false
            for _,u in pairs(p:GetUnits()) do if Rules.Own(army,u.unitBeingBuilt) then spawned=true;break end end
            if not spawned then count=count+1;if p.ai.baseName==baseName then localCount=localCount+1 end end
        end
    end
    if localCount>=1 or count>=(kind=="tactical" and 2 or 3) then return nil end
    for _,f in pairs(army.ai.formerpool or {}) do
        if f.RushFireSupport==kind then
            for id,on in pairs(f.WantStructures and f.WantStructures[1] or {}) do
                if on and Kind(Template(id))==kind then
                    -- CanFund already checks this template's observed
                    -- objective, base envelope and current native commitments.
                    for _,builder in ipairs(snapshot.balanceEngineers or {}) do
                        if builder.assignedToBase==baseName and CanFund(builder,id,snapshot,baseName) then return 7200 end
                    end
                end
            end
        end
    end
    return nil
end
function AddFormers(army,formers)
    local sets={tactical={},artillery={}};local names={}
    for _,f in pairs(formers) do names[f.FormerName]=true end
    for id,tp in pairs(__Templates.Units) do
        local kind=Kind(tp)
        if kind and R.AllowedTarget(id,false) then sets[kind][id]=true end
    end
    for _,kind in ipairs({"tactical","artillery"}) do
        local name="Static Fire Support "..kind
        if next(sets[kind]) and not names[name] then
            formers[#formers+1]={FormerName=name,AIPlan="planBuildWithEngineer",Priority=7200,
                RushFireSupport=kind,RushDevelopment=true,InvestmentType="FireSupportDevelopment",FormNumInstances=1,
                AIdifficulty={easy=true,medium=true,hard=true},AIlayer={land=true,air=true,water=true},
                RunWithStrategyName={},RunOnBaseType={MAIN=true,EXPANSION=true,OUTPOST=true,NAVAL=false},
                NeedMobileBuilder={{Tags.MOBILE*Tags.ENGINEER*(Tags.TECH2+Tags.TECH3),1,1,0}},
                WantStructures={sets[kind]},WantStructuresSpacing=2,AllowEcoStorageDrain=true,FormerConditions={}}
        end
    end
end
function ValidateBuild(platoon,builder,id,pos)
    local army,data=platoon.army,platoon.ai;local base=army.ai.bases[data.baseName]
    local tp=Template(id)
    if not base or not Rules.Own(army,builder) or builder.platoon~=platoon
        or Kind(tp)~=data.formerTable.RushFireSupport or not R.CanBuilderBuild(builder,id)
        or D2(pos,base.position)>math.min(80,base.radius)^2 then return false end
    local minimum,maximum=Range(tp)
    if not Objective(army,pos,minimum,maximum,Kind(tp)=="tactical") then return false end
    local exposure=Intel.Exposure(army,pos,"Land",12).total
    local friendly=Intel.FriendlyThreat(platoon,pos,64,"Land",true)
    return exposure<=math.max(1,friendly)*0.8
        and MG.CanGraphAreaTo(builder:GetPosition(),pos,Movement.UnitMovementLayer(builder))
        and CanFund(builder,id,nil,data.baseName)
end
function FindPosition(platoon,builder,id)
    local data=platoon.ai;local base=platoon.army.ai.bases[data.baseName]
    if not base then return false end
    local position=Layout.Find(platoon.army.id,id,Copy(base.position),2,nil,math.min(80,base.radius),nil,nil,
        {builder=builder,exceptPlatoon=platoon,accept=function(pos) return ValidateBuild(platoon,builder,id,pos) end})
    return position and ValidateBuild(platoon,builder,id,position) and position or false
end
local function Exclusive(unit,record)
    local orders=unit.orders or {}
    if orders.activeOrder and orders.activeOrder~=record.order then return false end
    for _,o in pairs(orders.queuedOrders or {}) do if o~=record.order then return false end end
    return true
end
local function Health(target)
    local health=math.max(0,target:GetHealth())
    for _,shield in ipairs(target.shields or {}) do if shield:IsEnabled() then health=health+math.max(0,shield:GetHealth()) end end
    return health
end
local function Score(target)
    local tp=target.tp
    if Has(tp,"COMMAND") then return 1000 end
    if Has(tp,"ARTILLERY") or Kind(tp)=="tactical" then return 950 end
    if Has(tp,"SHIELD") then return 900 end
    if Has(tp,"FACTORY") then return 850 end
    if Has(tp,"ENGINEER") then return 800 end
    if Has(tp,"ALLOYS_EXTRACTION") then return 750 end
    if Has(tp,"ENERGY_PRODUCTION") then return 700 end
    return Has(tp,"STRUCTURE") and 600 or 500
end
local function SafeBlast(army,position,radius)
    return #Intel.FriendlyUnitsInRadius(army,position,math.max(3,radius+2))==0
end
local function CanFire(unit,target,kind)
    if not GroundTarget(unit.army,target) then return false end
    local position=target:GetPosition();local minimum,maximum=Range(unit.tp)
    local origin=unit:GetPosition();local distance=D2(origin,position)
    if kind=="tactical" then
        distance=distance+((origin.y or 0)-(position.y or 0))^2
        if distance<minimum^2 or distance>maximum^2 then return false end
        local c=unit.scoTactical and unit.scoTactical.contract
        return c and (Has(target.tp,"STRUCTURE") or Has(target.tp,"COMMAND"))
            and (not c.damageFriendly or SafeBlast(unit.army,position,c.damageRadius or 0))
    end
    for _,w in ipairs(unit.weapons or {}) do
        local tp=w.tp or w
        if w.enabled and not w.isDeathExplosion and (AF.GetWeaponDamagePerSecond(tp) or 0)>0
            and distance>=(tp.rangeMin or 0)^2 and Intel.CanShootAt(unit.army,w,target)
            and Intel.IsTargetInRange(unit.army,w,target)
            and (not tp.damageFriendly or SafeBlast(unit.army,position,tp.damageRadius or 0)) then return true end
    end
    return false
end
local function SelectTarget(unit,kind,state,claimedDamage)
    local best,score;local now=Now()
    for _,r in ipairs(Intel.Get(unit.army).enemy) do
        local target=Intel.Detected(unit.army,r.unit) and r.unit or Intel.Contact(unit.army,r.unit)
        if GroundTarget(unit.army,target) then
            local pos=target:GetPosition();local stationary=true
            if kind=="tactical" and not Has(target.tp,"STRUCTURE") then
                local watch=state.stationary[target]
                if not watch or D2(watch.pos,pos)>1 then watch={pos=Copy(pos),since=now};state.stationary[target]=watch end
                stationary=now-watch.since>=3
            end
            local claimed=claimedDamage[TargetKey(target)] or 0
            if stationary and (kind~="tactical" or claimed<Health(target)*1.25) and CanFire(unit,target,kind) then
                local value=Score(target)-math.sqrt(D2(unit:GetPosition(),pos))*0.05
                if not score or value>score or value==score and target.id.index<best.id.index then best,score=target,value end
            end
        end
    end
    return best
end
function Tick(army,snapshot)
    if not army.ai or army.ai.isAlive==false then return end
    local state=State(army);local now=Now()
    for i=#state.shots,1,-1 do
        local shot=state.shots[i]
        if now>=shot.expires or shot.target.dead or shot.target.deleted then table.remove(state.shots,i) end
    end
    for target in pairs(state.stationary) do if not Intel.Visible(army,target) then state.stationary[target]=nil end end
    local units={}
    for _,u in ipairs(snapshot.fireSupportUnits or {}) do if Rules.Own(army,u) and u:IsCompleted() then units[#units+1]=u end end
    table.sort(units,function(a,b) return a.id.index<b.id.index end)
    -- Aggregate in original shot order, then update immediately after
    -- each accepted launch so later silos see the same commitments.
    local claimedDamage={}
    for _,shot in ipairs(state.shots) do
        -- Vision/radar transitions replace the contact object, not the target.
        local key=TargetKey(shot.target)
        claimedDamage[key]=(claimedDamage[key] or 0)+shot.damage
    end
    local committedMass,committedEnergy=0,0
    for _,u in ipairs(units) do
        local kind=Kind(u.tp);local record=state.units[u]
        if not record or record.ai~=u.ai or record.armyAI~=army.ai then
            record={ai=u.ai,armyAI=army.ai};state.units[u]=record
        end
        local plan=u.platoon and u.platoon.ai and u.platoon.ai.formerTable
        if kind and not u.CaptureInProgress and not u.ReclaimInProgress and not RushUnitState.IsPaused(u)
            and (not u.platoon or plan and plan.AIPlan=="planAttackArtillery") and Exclusive(u,record) then
            local target=SelectTarget(u,kind,state,claimedDamage)
            if kind=="tactical" then
                local silo=u.scoTactical
                if silo and type(u.SCOSetNukeAutoBuild)=="function" and type(u.SCOQueueNuke)=="function"
                    and type(u.SCOLaunchNuke)=="function" then
                    -- Retain paid work, but queue at most one budgeted round at
                    -- a time instead of filling every default 12-missile stockpile.
                    if silo.autoBuild then u:SCOSetNukeAutoBuild(false) end
                    local a,e=Rules.Resources(army)
                    local mass,energy,duration=AmmoRates(u.tp)
                    if (target or silo.ammo<1) and mass and a and e and not silo.building and silo.queued==0 and silo.ammo<2
                        and not Economy.AlloyStalled({alloy=a}) and e.ratio>=0.35
                        and Rules.Balance(a)-committedMass+math.max(0,a.current-a.storage*0.25)/math.max(30,duration)>=mass
                        and Rules.Balance(e)-committedEnergy+math.max(0,e.current-e.storage*0.25)/math.max(30,duration)>=energy
                        and u:SCOQueueNuke(1) then
                        committedMass,committedEnergy=committedMass+mass,committedEnergy+energy
                    end
                    if target and silo.ammo>0 and CanFire(u,target,kind) then
                        local pos=Copy(target:GetPosition())
                        if u:SCOLaunchNuke(pos) then
                            local c=silo.contract
                            local key=TargetKey(target)
                            claimedDamage[key]=(claimedDamage[key] or 0)+(c.damage or 0)
                            state.shots[#state.shots+1]={target=target,damage=c.damage or 0,
                                expires=now+math.min(90,math.sqrt(D2(u:GetPosition(),pos))/math.max(1,c.muzzleVelocity or 10)
                                    +(c.deployDuration or 0)/math.max(0.01,c.deployRate or 1)+(c.charge or 0)+5)}
                            Log("[RushFireSupport] army="..army.id.." tactical="..u.id.index.." target="..target.id.index,true)
                        end
                    end
                end
            elseif target then
                local active=u.orders and u.orders.activeOrder
                if not (active==record.order and active and Intel.SameTarget(active.targetUnit,target)) then
                    Orders.HostIssueOrder(Tasks.ATTACKUNIT,{u},false,Copy(target:GetPosition()),{targetGlobalId=target.id})
                    local order=u.orders and u.orders.activeOrder
                    if order and order.orderTask==Tasks.ATTACKUNIT and Intel.SameTarget(order.targetUnit,target) then record.order=order end
                end
            elseif record.order then
                Orders.HostClearOrder({u});record.order=nil
            end
        end
    end
    for u in pairs(state.units) do if not Rules.Own(army,u) then state.units[u]=nil end end
end
