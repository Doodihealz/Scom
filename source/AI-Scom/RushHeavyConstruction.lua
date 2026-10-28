-- Shared faction-native experimental and T3 artillery construction.
-- Real menus, paid foundations, native placement and resource commitments win.
Version = "9.0.25-rc30"
local Rules = Import("AI/mods/AI-Scom/RushBalance.lua")
local AF=Import("AI/AIFunctions.lua")
local Movement=Import("AI/mods/AI-Scom/RushMovement.lua")
local MG=Import("AI/AIMarkerGenerator.lua")
local Expansion=Import("AI/mods/AI-Scom/RushExpansion.lua")
local R=Import("AI/mods/AI-Scom/RushReliability.lua")
local Layout=Import("AI/mods/AI-Scom/RushBaseLayout.lua")
local Pressure=Import("AI/mods/AI-Scom/RushPressure.lua")
local P=Import("AI/mods/AI-Scom/RushHeavyPolicy.lua")
local NavalConstruction=Import("AI/mods/AI-Scom/RushNavalConstruction.lua")
local Intel=Import("AI/mods/AI-Scom/RushCombatIntel.lua")
local Orders=Import("host/managers/orders/hostOrderManager.lua")
local Tasks=Import("common/commonOrders.lua").OrderTasks
local Log=Import("AI/debugUtilities.lua").AILog
local function Now() return GetGameTimeSeconds() end
local function Finite(x) return type(x)=="number" and x==x and math.abs(x)<math.huge end
local function Template(id) return __Templates and __Templates.Units and __Templates.Units[id] end
local function Has(tp,tag) return R.Has(tp,tag) or R.Has(tp,"SCFA_"..tag) end
local function Tier(tp)
    if P.IsT4(tp) then return 4 end
    for tier=3,1,-1 do if Has(tp,"TECH"..tier) then return tier end end
    local tier=tonumber(tp and tp.general and tp.general.techNumber)
    return Finite(tier) and tier or 0
end
local function EngineerTemplate(a,tp,t3)
    return P.FactionMatches(a,tp) and Has(tp,"ENGINEER") and Has(tp,"MOBILE")
        and not Has(tp,"COMMAND") and not P.IsT4(tp) and (not t3 or Tier(tp)==3)
end
local function HarborTemplate(tp)
    return Has(tp,"NAVAL_FACTORY") or Has(tp,"FACTORY") and Has(tp,"STRUCTURE") and P.Domain(tp)=="naval"
end
local function WaterProject(tp) return P.Domain(tp)=="naval" or tp.general and tp.general.requiresWaterPlacement end
local function Own(a,u) return R.Own(a,u) end
local function Dist(a,b) return math.sqrt((a.x-b.x)^2+(a.z-b.z)^2) end
local function Position(p)
    if type(p)~="table" or not Finite(p.x) or not Finite(p.z)
        or p.y~=nil and not Finite(p.y) then return nil end
    return Movement.Copy(p)
end
local function ServiceOwner(a)
    local ai=a.ai;local base=ai and ai.bases and ai.bases.MAIN
    local worker=coroutine.running()
    if not base or not worker or not base.luaThreads or base.luaThreads.AILocationManagerThread~=worker then return nil end
    return {armyAI=ai,base=base,worker=worker}
end
local function ServiceCurrent(a,s,owner)
    return type(owner)=="table" and s.running==owner and a.ai==owner.armyAI
        and owner.armyAI.isAlive~=false and owner.armyAI.bases and owner.armyAI.bases.MAIN==owner.base
        and owner.base.luaThreads and owner.base.luaThreads.AILocationManagerThread==owner.worker
end
local function Name(id) local t=Template(id);return t and t.general and t.general.name or id end
local function Horizon(kind) return kind=="economy" and 1800 or (kind=="siege" or kind=="strategic") and 1200 or kind=="artillery" and 900 or 600 end
local function State(a)
    a.ai.rushHeavyConstruction=a.ai.rushHeavyConstruction or
        {nextTick=0,nextStart=0,rejected={},retry={},completed={},lastLog=-100,fireOrders={}}
    return a.ai.rushHeavyConstruction
end
function Enabled(a) return P.Enabled(a) and P.Factions[a.faction]~=nil end
local function Legal(a,id)
    local t=Template(id);local e=t and t.economy;local c=e and e.cost
    return P.Kind(a,t) and R.AllowedTarget(id,true)
        and P.AllowsTarget(a,id) and R.Footprint(t) and e and Finite(e.buildTime) and e.buildTime>0
        and c and Finite(c.alloys) and c.alloys>=0 and Finite(c.energy) and c.energy>=0
end
local function Fraction(u)
    if u:IsCompleted() then return 1 end
    local f=type(u.GetFractionComplete)=="function" and u:GetFractionComplete() or 0
    return Finite(f) and math.max(0,math.min(1,f)) or 0
end
local StaticIntelTargets={shieldExperimental=true,shield=true,expgen=true,artillery=true,
    smd=true,nuke=true,energy=true,alloy=true,factory=true}
function Census(a)
    local c={counts={},byId={},unfinished={},other=false,t3=0,mobileTotal=0,experimentalTotal=0,
        builders={},harbors={},managed={},allyCount=0,teamPressure=0,knownTargets=0,staticTargets=0}
    for _,u in pairs(a.units or {}) do
        if Own(a,u) then
            local kind=P.Kind(a,u.tp)
            if kind then
                if u:IsCompleted() then
                    c.counts[kind]=(c.counts[kind] or 0)+1;c.byId[u.tpId]=(c.byId[u.tpId] or 0)+1
                    if P.IsExperimental(u.tp) then c.experimentalTotal=c.experimentalTotal+1 end
                    if P.IsCombatExperimental(u.tp) then c.mobileTotal=c.mobileTotal+1 end
                else c.unfinished[#c.unfinished+1]=u end
            elseif P.IsExperimental(u.tp) and not u:IsCompleted() then c.other=true end
            if EngineerTemplate(a,u.tp,true) and u:IsCompleted()
                and not u.scoCommanderPodOwner and not u.scoSourcePodOwner then
                c.t3=c.t3+1;c.builders[#c.builders+1]=u
            end
            if u:IsCompleted() and HarborTemplate(u.tp) then c.harbors[#c.harbors+1]=u end
            local orders=u.orders or {};local order=orders.activeOrder
            local target=u.unitBeingBuilt or u.buildBehaviorIsActive and u.buildBehaviorActualUnit
                or order and (order.orderTask==Tasks.BUILD and order.unitGettingBuilt
                    or order.orderTask==Tasks.ASSISTUNIT and order.targetUnit)
            if Own(a,target) and not target:IsCompleted() then c.managed[target]=true end
        end
    end
    c.hasHarbor=#c.harbors>0
    local first=P.FirstTarget(a)
    table.sort(c.unfinished,function(x,y)
        if x==first then return y~=first end
        if y==first then return false end
        local xf,yf=Fraction(x),Fraction(y);return xf==yf and x.id.index<y.id.index or xf>yf
    end)
    table.sort(c.harbors,function(x,y) return x.id.index<y.id.index end)
    for _,ally in pairs(Armies or {}) do
        if ally~=a and a:IsAlly(ally) and not (ally.ai and ally.ai.isAlive==false) then
            c.allyCount=c.allyCount+1
            local view=ally.ai and ally.ai.rushController and ally.ai.rushController.snapshot
            if view and Finite(view.time) and Now()-view.time>=0 and Now()-view.time<10
                and (view.landPanic or view.airPanic or view.navalPanic or view.landPressure) then c.teamPressure=c.teamPressure+1 end
        end
    end
    for i,r in ipairs(a.ai.targets and a.ai.targets.artilleryTargets or {}) do
        if i>24 then break end
        if r.pos and Finite(r.pos.x) and Finite(r.pos.z) then
            c.knownTargets=c.knownTargets+1
            if StaticIntelTargets[r.name] and not r.underWater then c.staticTargets=c.staticTargets+1 end
        end
    end
    local combat=a.ai.rushCombat
    c.siegePressure=combat and (combat.siegeUntil or 0)>Now() or false
    return c
end

local function Emit(a,event,reason,job)
    local s=State(a);job=job or s.job
    local key=event..":"..tostring(reason)
    if key==s.logKey and Now()-s.lastLog<30 then return end
    s.logKey=key;s.lastLog=Now()
    local t=job and job.target
    Log(string.format("[RushHeavy] army=%s event=%s reason=%s unit=%s builder=%s target=%s fraction=%.4f",
        tostring(a.id),event,tostring(reason),tostring(job and job.id or "none"),
        tostring(job and job.lead and job.lead.id.index),tostring(t and t.id.index),
        t and Own(a,t) and Fraction(t) or 0)..R.ConstructionDetails(job),true)
end
local function Reject(s,id,pos)
    s.rejected[#s.rejected+1]={id=id,pos=Position(pos),untilTime=Now()+180}
    if #s.rejected>32 then table.remove(s.rejected,1) end
end
local function Rejected(s,id,pos,f)
    for k=#s.rejected,1,-1 do
        local r=s.rejected[k]
        if r.untilTime<=Now() then table.remove(s.rejected,k)
        elseif r.id==id and Dist(r.pos,pos)<math.max(12,f.x,f.y) then return true end
    end
    return false
end
local function MarkerGraph(p,layer)
    if not p or type(MG.GetMarkerTable)~="function" or type(MG.GetMarkerGridIndexFromWorldPosition)~="function" then return nil end
    local grid=MG.GetMarkerTable(layer);local x,z=MG.GetMarkerGridIndexFromWorldPosition(p)
    local m=grid and x and z and grid[x] and grid[x][z]
    return m and m.GraphArea
end
local function WaterGraph(p) return MarkerGraph(p,"Water") end
local function Place(a,id,p,spacing,site)
    local t=Template(id);local f=R.Footprint(t)
    if not f or not R.PlacementContract(id,p) then return false end
    if WaterProject(t) then
        if not site or not Finite(site.waterLevel) or not site.graph or WaterGraph(p)~=site.graph then return false end
        for _,dx in ipairs({-f.x/2+0.5,0,f.x/2-0.5}) do
            for _,dz in ipairs({-f.y/2+0.5,0,f.y/2-0.5}) do
                local q=SnapToGround({x=p.x+dx,y=0,z=p.z+dz})
                if not q or not Finite(q.y) or q.y>=site.waterLevel-0.1 then return false end
            end
        end
    end
    if Has(t,"STRUCTURE") and t.skirtSize and type(AF.CanBuildStructureAt)=="function" then
        return AF.CanBuildStructureAt(a.id,id,p,spacing)==true
    end
    return R.MobilePlacement(a.id,id,p,spacing)==true
end
local function WeaponRange(tp,d)
    for _,w in ipairs(tp and tp.weapons or {}) do
        if Finite(w.rangeMax) and w.rangeMax>0 and not w.isDeathExplosion
            and (AF.GetWeaponDamagePerSecond(w) or 0)>0
            and d>=(w.rangeMin or 0)+2 and d<=w.rangeMax-2 then return true end
    end
    return false
end
local function InKnownRange(a,tp,pos)
    for i,r in ipairs(a.ai.targets and a.ai.targets.artilleryTargets or {}) do
        if i>24 then break end
        if r.pos and Finite(r.pos.x) and Finite(r.pos.z) and not r.underWater
            and WeaponRange(tp,Dist(pos,r.pos)) then return true end
    end
    return false
end
local function HarborSite(yard)
    local pos=Position(yard:GetPosition());if not pos then return nil end
    local graph=WaterGraph(pos)
    if type(MG.GetGraphAreaAtPosition)=="function" then
        local actual,waterPosition=NavalConstruction.GraphAreaAtPosition(pos,yard.tpId)
        if actual then graph=actual;pos=Position(waterPosition) or pos end
    end
    return pos,graph
end
local function LayerRange(tp,layer)
    local range=0
    for _,w in ipairs(tp.weapons or {}) do
        local limits=w.layerTargetLimits;local allowed=not limits or not next(limits)
        for _,name in ipairs(limits or {}) do if name==layer then allowed=true;break end end
        if allowed and not w.isDeathExplosion and (AF.GetWeaponDamagePerSecond(w) or 0)>0
            and Finite(w.rangeMax) then range=math.max(range,w.rangeMax) end
    end
    return range
end
local function NavalOpportunity(a,tp,pos,graph)
    if not pos or not graph then return false end
    local profile=P.Profile(tp)
    -- A native carrier/factory has a useful production role even while no fleet
    -- is spotted. Ordinary warships need a connected sea or coastal objective.
    if profile.factory or not P.IsCombatExperimental(tp) then return true end
    local seaRange=math.max(LayerRange(tp,"WaterSurface"),LayerRange(tp,"Seabed"),LayerRange(tp,"Water"))
    if seaRange>0 then
        for _,r in ipairs(Intel.Get(a).enemy) do
            if P.Domain(r.unit.tp)=="naval" and Intel.Visible(a,r.unit) and WaterGraph(r.pos)==graph then return true end
        end
    end
    local range=LayerRange(tp,"Land")-3
    if range<=2 then return false end
    local layer=profile.amphibious and Movement.TemplateMovementLayer(tp)
    for i,r in ipairs(a.ai.targets and a.ai.targets.artilleryTargets or {}) do
        if i>24 then break end
        local target=Position(r.pos)
        if target and not r.underWater then
            if layer and MG.CanGraphAreaToStrict(pos,target,layer) then return true end
            for _,fraction in ipairs({0.6,1}) do
                for angle=0,7 do
                    local phase=angle*math.pi/4
                    local point={x=target.x+math.cos(phase)*range*fraction,y=0,z=target.z+math.sin(phase)*range*fraction}
                    if R.Inside(point,2) and WaterGraph(point)==graph then return true end
                end
            end
        end
    end
    return false
end
local function NeedPowerBuilder(a,snapshot,id)
    local e=snapshot.energy;local t=Template(id)
    return not e or e.ratio<0.35 or e.income<t.economy.cost.energy/Horizon(P.Kind(a,t))*2
end
local function Order(u) return u.orders and u.orders.activeOrder end
local function OrdersPresent(u) return Order(u) or (u.orders and u.orders.queuedOrders and next(u.orders.queuedOrders)) end
local function Builder(a,u,t3)
    return Own(a,u) and u:IsCompleted() and EngineerTemplate(a,u.tp,t3)
        and not u.CaptureInProgress and not u.ReclaimInProgress
        and not u.scoCommanderPodOwner and not u.scoSourcePodOwner
end
local function Paused(u)
    return u.toggles and u.toggles.Pause or type(u.GetPause)=="function" and u:GetPause()==true
end
local function Power(u)
    local n=u.construction and u.construction.buildPower
    return Finite(n) and math.max(0,n) or 0
end
local function Assignment(a,j,u)
    return a.ai==j.armyAI and R.CurrentAssignment(u,a,j.platoon,j.unitAI[u],j.platoonAI)
end
local function OrdersOwned(j,u)
    local expected=j.orders[u];local orders=u.orders or {}
    if orders.activeOrder and orders.activeOrder~=expected then return false end
    for _,order in pairs(orders.queuedOrders or {}) do if order~=expected then return false end end
    return true
end
local function SaveOrder(a,j,u,task)
    if not Assignment(a,j,u) then return end
    local orders=u.orders or {};local order=orders.activeOrder
    if order and order.orderTask==task then j.orders[u]=order;return end
    for _,queued in pairs(orders.queuedOrders or {}) do
        if queued.orderTask==task then j.orders[u]=queued;return end
    end
end
local function ClearReserve(a,j,u)
    local r=j.reserves[u];local reserves=j.armyAI and j.armyAI.ecoReserve
    if r and reserves and reserves[u.id.index]==r then
        if a.ai==j.armyAI and Own(a,u) then AF.ClearReserveEco(a.id,u.id.index)
        else reserves[u.id.index]=nil end
    end
    j.reserves[u]=nil
end
local function Release(a,j,u,plans)
    ClearReserve(a,j,u)
    if Assignment(a,j,u) then
        local order=j.orders[u];local orders=u.orders or {}
        for i=#(orders.queuedOrders or {}),1,-1 do
            if orders.queuedOrders[i]==order then Orders.RemoveUnitFromQueuedOrder(u,order) end
        end
        if order and orders.activeOrder==order then
            Orders.RemoveUnitFromActiveOrder(u)
            if Assignment(a,j,u) then Orders.TryStartNextOrderForUnit(u) end
        end
        if Assignment(a,j,u) then
            if not OrdersPresent(u) and not R.Working(u) and plans and plans.ClearUnitTemporaryPlatoonData then
                plans.ClearUnitTemporaryPlatoonData(u,"heavy construction finished")
            end
            j.platoon:OnUnitRemoved(u)
        end
    end
    j.builders[u]=nil;j.issued[u]=nil;j.orders[u]=nil;j.unitAI[u]=nil
end

local function Finish(a,s,reason,plans)
    local j=s.job;if not j then return end
    local copy={};for u in pairs(j.builders) do copy[#copy+1]=u end
    for _,u in ipairs(copy) do Release(a,j,u,plans) end
    if j.platoon.ai==j.platoonAI and a:PlatoonExists(j.platoon) and not next(j.platoon.units or {}) then
        a:DisbandPlatoon(j.platoon)
    end
    s.job=nil;s.nextStart=Now()+20
    if reason~="control-handoff" then s.retry[j.id]=Now()+60 end
    Emit(a,"released",reason,j)
end
local function Candidates(a,pos,t3)
    local list={}
    local protected=Rules.ProtectedPowerBuilder(a,{})
    for _,u in pairs(a.units) do
        if u~=protected and Builder(a,u,t3) and not Paused(u) and not u.platoon and not R.Working(u) and not OrdersPresent(u)
            and not u.buildBehaviorIsActive and not u.reclaimBehaviorIsActive and not R.BuilderRecallReserved(u,"heavy")
            and Power(u)>0 and Dist(u:GetPosition(),pos)<=192 then
            list[#list+1]=u
        end
    end
    table.sort(list,function(x,y)
        local dx,dy=Dist(x:GetPosition(),pos),Dist(y:GetPosition(),pos)
        if dx~=dy then return dx<dy end
        return x.id.index<y.id.index
    end)
    return list
end
local function Attach(a,j,u,plans)
    if not Builder(a,u,false) or Paused(u) or u.platoon or R.Working(u) or OrdersPresent(u)
        or R.BuilderRecallReserved(u,"heavy") then return false end
    if not R.PrepareIdleBuilder(u,plans) then return false end
    j.platoon:AssignUnits({u});u.ai=u.ai or {};u.ai.eState="T4Reserved"
    j.unitAI[u]=u.ai;j.builders[u]=true;u.ai.rushBuilderRecall=nil
    return true
end
local function Approach(a,s,owner,u,pos,tp,platoon)
    local f=R.Footprint(tp);local uf=R.Footprint(u.tp) or {x=1,y=1}
    local gap=math.max(uf.x,uf.y)/2+1
    local rx,rz=f.x/2+gap,f.y/2+gap
    local points={{rx,0},{-rx,0},{0,rz},{0,-rz},{rx,rz},{-rx,rz},{rx,-rz},{-rx,-rz}}
    local start=Position(u:GetPosition());pos=Position(pos)
    if not start or not pos or not ServiceCurrent(a,s,owner) then return nil end
    local layer=(Movement.UnitMovementLayer(u) or "Land")
    local unitAI,armyAI,data=u.ai,a.ai,platoon and platoon.ai
    table.sort(points,function(x,y)
        local dx=(pos.x+x[1]-start.x)^2+(pos.z+x[2]-start.z)^2
        local dy=(pos.x+y[1]-start.x)^2+(pos.z+y[2]-start.z)^2
        return dx==dy and (x[1]==y[1] and x[2]<y[2] or x[1]<y[1]) or dx<dy
    end)
    for _,p in ipairs(points) do
        local q=Position(SnapToGround({x=pos.x+p[1],y=0,z=pos.z+p[2]}))
        if R.Inside(q,gap) and MG.IsPathable(q.x,q.z) and MG.CanGraphAreaToStrict(start,q,layer) then
            local path=MG.GeneratePathTo(a.id,start,q,layer,true,1)
            if not ServiceCurrent(a,s,owner) or a.ai~=armyAI or not R.CurrentAssignment(u,a,platoon,unitAI,data) then return nil end
            if not OrdersPresent(u) and not R.Working(u) and type(path)=="table" and #path>0 then
                local route=Movement.CopyPath(MG.StraightenPath(path))
                if #route>0 then return {position=pos,approach=q,path=route,layer=layer} end
            end
        end
    end
end
local function SelectSite(a,s,u,id,origin,ownerPlatoon)
    local tp=Template(id);local f=R.Footprint(tp);local kind=P.Kind(a,tp)
    local owner=s.running;local unitAI,platoonAI=u.ai,ownerPlatoon.ai
    local function current() return ServiceCurrent(a,s,owner)
        and R.CurrentAssignment(u,a,ownerPlatoon,unitAI,platoonAI) and not R.Working(u) and not OrdersPresent(u) end
    origin=Position(origin);if not origin or not current() then return nil end
    local anchors={{position=origin}};local water
    local naval=WaterProject(tp)
    local baseName=ownerPlatoon.ai.baseName;local base=a.ai.bases[baseName]
    local radius=Has(tp,"STRUCTURE") and math.min(160,base and base.radius or 60) or 160
    if Has(tp,"STRUCTURE") and not naval then
        local site
        local _,handled=Layout.Find(a.id,id,origin,2,nil,radius,nil,false,{exceptPlatoon=ownerPlatoon,builder=u,accept=function(pos)
            pos=Position(pos)
            if not pos or not current()
                or Rejected(s,id,pos,f) or not R.Inside(pos,math.max(f.x,f.y)/2+2)
                or not Expansion.Safe(a,pos) or not Place(a,id,pos,0)
                or (kind=="artillery" or kind=="siege") and not InKnownRange(a,tp,pos) then return false end
            local approach=Approach(a,s,owner,u,pos,tp,ownerPlatoon)
            if approach and current() and Expansion.Safe(a,pos) and Place(a,id,pos,0) then
                site=approach;return true
            end
            return false
        end})
        -- Ordinary structural sites use the same exit, storage-ring and pending
        -- foundation checks as adjacency. Never bypass them with a second finder.
        if not current() then return nil end
        if handled then return site end
    end
    if naval then
        anchors={}
        if not Engine or type(Engine.GetWaterLevel)~="function" then return nil end
        local _,level=Engine.GetWaterLevel();if not Finite(level) then return nil end
        water=level
        -- A completed local shipyard anchors a connected, developed body of water.
        for _,yard in pairs(a.units or {}) do
            if Own(a,yard) and yard:IsCompleted() and HarborTemplate(yard.tp)
                and Dist(yard:GetPosition(),origin)<=256 then
                local position,graph=HarborSite(yard)
                if NavalOpportunity(a,tp,position,graph) then
                    anchors[#anchors+1]={position=position,graph=graph,index=yard.id.index}
                end
            end
        end
        table.sort(anchors,function(x,y) return x.index<y.index end)
    end
    local offsets={}
    for _,radius in ipairs({24,40,64,96,128,160}) do
        for i=0,15 do local angle=i*math.pi/8
            offsets[#offsets+1]={math.cos(angle)*radius,math.sin(angle)*radius}
        end
    end
    local checked=0
    for _,anchor in ipairs(anchors) do
        for n=1,#offsets do
            local index=((s.cursor or 0)+n-1)%#offsets+1;local o=offsets[index]
            local pos=Position(SnapToGround({x=math.floor(anchor.position.x+o[1]-f.x/2+0.5)+f.x/2,y=0,
                z=math.floor(anchor.position.z+o[2]-f.y/2+0.5)+f.y/2}))
            checked=checked+1
            if checked%32==0 then WaitTicks(1) end
            if not current() then return nil end
            local context={waterLevel=water,graph=anchor.graph}
            if pos and Dist(pos,origin)<=(naval and 320 or radius) and not Rejected(s,id,pos,f)
                and R.Inside(pos,math.max(f.x,f.y)/2+2) and Expansion.Safe(a,pos,naval and "Water" or nil)
                and Place(a,id,pos,2,context)
                and (kind~="artillery" and kind~="siege" or InKnownRange(a,tp,pos)) then
                local site=Approach(a,s,owner,u,pos,tp,ownerPlatoon)
                if site and current() then
                    s.cursor=index;site.waterLevel=water;site.graph=anchor.graph
                    return site
                end
            end
        end
    end
end
local function Matches(a,j,u)
    return Own(a,u) and u.tpId==j.id and P.Kind(a,u.tp)~=nil
        and (not j.site or Dist(u:GetPosition(),j.site.position)<3)
end
local function FindTarget(a,j)
    -- A funding promise has no accepted foundation or placement. Without this
    -- guard a second project could accidentally adopt a completed first copy.
    if not j.target and not j.site then return nil end
    if Matches(a,j,j.target) then return j.target end
    for u in pairs(j.builders) do
        if Own(a,u) and u.platoon==j.platoon then
            for _,field in ipairs({"unitBeingBuilt","buildBehaviorActualUnit"}) do
                if Matches(a,j,u[field]) then return u[field] end
            end
            local o=Order(u)
            if o and Matches(a,j,o.unitGettingBuilt) then return o.unitGettingBuilt end
        end
    end
    for _,u in pairs(a.units) do if Matches(a,j,u) then return u end end
end
local function IssueAssist(a,j,u)
    if not Own(a,j.target) or not Builder(a,u,false) or u.platoon~=j.platoon then return end
    local now=Now();local o=Order(u)
    if OrdersPresent(u) or u.buildBehaviorIsActive then return end
    if now-(j.issued[u] or -100)<8 then return end
    Orders.HostIssueOrder(Tasks.ASSISTUNIT,{u},false,j.target:GetPosition(),{targetGlobalId=j.target.id})
    SaveOrder(a,j,u,Tasks.ASSISTUNIT)
    j.issued[u]=now;u.ai.eState="T4Assisting"
end
local function ProjectAnchor(a,id,target)
    local main=a.ai.bases.MAIN
    if target then
        local name=target.assignedToBase
        if not name or not a.ai.bases[name] then name="MAIN" end
        return Position(target:GetPosition()),name
    end
    local tp=Template(id)
    if not WaterProject(tp) then return Position(main.position),"MAIN" end
    local best,bestDistance,bestBase
    for _,yard in pairs(a.units or {}) do
        if Own(a,yard) and yard:IsCompleted() and HarborTemplate(yard.tp) then
            local pos,graph=HarborSite(yard)
            local useful=NavalOpportunity(a,tp,pos,graph)
            for _,u in pairs(a.units or {}) do
                if useful and Builder(a,u,true) and not Paused(u) and R.CanBuilderBuild(u,id) then
                    local d=Dist(u:GetPosition(),pos)
                    if d<=192 and (not bestDistance or d<bestDistance
                        or d==bestDistance and yard.id.index<best.id.index) then
                        best,bestDistance=yard,d
                        bestBase=yard.assignedToBase
                    end
                end
            end
        end
    end
    if not best then return nil end
    if not bestBase or not a.ai.bases[bestBase] then bestBase="MAIN" end
    return Position(best:GetPosition()),bestBase
end
local function NewJob(a,s,id,target,plans,snapshot)
    local owner=s.running;if not ServiceCurrent(a,s,owner) then return end
    -- A paid first experimental keeps the next expensive foundation from splitting its support.
    if not target and P.FirstTarget(a) then return end
    local origin,baseName=ProjectAnchor(a,id,target)
    if not origin then Emit(a,"blocked","no-local-native-harbor-builder");return end
    local base=a.ai.bases[baseName]
    local candidates=Candidates(a,origin,not target)
    local lead,quote,fallback,fallbackQuote
    for _,u in ipairs(candidates) do
        if target and type(u.AssistBehaviorIsValidFor)=="function" and u:AssistBehaviorIsValidFor(target) then
            lead=u;break
        elseif not target and R.CanBuilderBuild(u,id) then
            local available=Rules.HeavyInvestmentBudget(a,u,id,snapshot)
            if available then
                if available.ready then lead,quote=u,available;break end
                -- The nearest boosted engineer must not veto an affordable,
                -- slower native lead. Prefer the smaller pending draw if all
                -- legal candidates first need ordinary production to make room.
                if not fallbackQuote or available.mass<fallbackQuote.mass
                    or available.mass==fallbackQuote.mass and available.energy<fallbackQuote.energy then
                    fallback,fallbackQuote=u,available
                end
            end
        end
    end
    if not lead then lead,quote=fallback,fallbackQuote end
    if not lead then
        local requested=R.RequestConstructionBuilder(a,id,target and target:GetPosition() or origin,"heavy")
        Emit(a,requested and "waiting" or "blocked",requested and "T3-reclaim-recall-requested" or "no-idle-legal-T3-engineer")
        return
    end
    local site
    local p=a:CreatePlatoon("RC8 Heavy "..Name(id))
    p.ai={baseName=baseName,basePosition=origin,baseRadius=base.radius,
        creationTime=GetFormatedGameTime(),formerTable={FormerName="RC8 Heavy "..Name(id),
            AIPlan="RushHeavyConstructionDirector",RushT4Project=true,RushHeavyProject=true,InvestmentType="StrategicDevelopment"}}
    local j={id=id,platoon=p,platoonAI=p.ai,armyAI=a.ai,unitAI={},orders={},baseName=baseName,base=base,
        main=owner.base,worker=owner.worker,
        origin=origin,lead=lead,builders={},issued={},reserves={},target=target,site=site,
        phase=target and (Fraction(target)>0 and "building" or "starting") or "funding",began=Now(),phaseAt=Now(),progressAt=Now(),
        fraction=target and Fraction(target) or 0,pathIndex=1,siteAttempts=1,goal=Now()+Horizon(P.Kind(a,Template(id)))}
    s.job=j
    if not Attach(a,j,lead,plans) then Finish(a,s,"builder-race",plans);return end
    if not target then
        j.pendingInvestment={id=id,unit=lead,unitAI=lead.ai,armyAI=a.ai,main=owner.base,worker=owner.worker,
            mass=quote.mass,energy=quote.energy,created=Now(),expires=Now()+60}
        Emit(a,"funding",Name(id),j)
    else
        p.ai.buildedUnit=target;IssueAssist(a,j,lead)
        Emit(a,"adopted",Name(id),j)
    end
end
-- Keep the same lead for a bounded set of genuinely different sites. Releasing
-- it after each rejected BUILD let map reclaim capture it for several minutes.
local function RetryUnstarted(a,s,j,reason,plans)
    local owner=s.running;if not ServiceCurrent(a,s,owner) or s.job~=j then return end
    Emit(a,"start-failed",reason,j)
    if j.site then Reject(s,j.id,j.site.position) end
    if not j.site or (j.siteAttempts or 1)>=3 or not R.CanBuilderBuild(j.lead,j.id) then
        Finish(a,s,"construction-not-started",plans);return
    end
    local u=j.lead
    if not Own(a,u) or u.platoon~=j.platoon then Finish(a,s,"lead-lost-before-retry",plans);return end
    local old=FindTarget(a,j)
    if old and Fraction(old)>0 then j.target=old;j.phase="building";return end
    if not Assignment(a,j,u) or not OrdersOwned(j,u) then Finish(a,s,"builder-order-replaced",plans);return end
    local order=j.orders[u]
    if order and Order(u)==order then Orders.RemoveUnitFromActiveOrder(u) end
    j.orders[u]=nil;ClearReserve(a,j,u)
    -- An old zero-progress host placeholder must disappear before a new BUILD.
    if old and Own(a,old) then Finish(a,s,"zero-progress-foundation-retained",plans);return end
    j.target=nil;j.platoon.ai.buildedUnit=nil
    local site=SelectSite(a,s,u,j.id,j.origin,j.platoon)
    if not ServiceCurrent(a,s,owner) or s.job~=j then return end
    if not Assignment(a,j,u) then Finish(a,s,"builder-race",plans);return end
    if not site then Finish(a,s,"retry-sites-exhausted",plans);return end
    j.site=site;j.siteAttempts=(j.siteAttempts or 1)+1;j.phase="moving"
    j.began=Now();j.phaseAt=Now();j.progressAt=Now();j.pathIndex=1
    j.startWatch=nil;j.moveOrder=nil;j.bestDistance=nil;j.issued[u]=nil
    j.platoon.ai.placeToBuild=site.position;j.platoon.ai.movementLayer=site.layer
    local mass,energy=Rules.ProjectRates(u,j.id)
    if not mass then Finish(a,s,"construction-rate-unavailable",plans);return end
    AF.SetReserveEco(a.id,u.id.index,j.id,site.position)
    local reserve=a.ai.ecoReserve and a.ai.ecoReserve[u.id.index]
    if not reserve then Finish(a,s,"construction-reservation-failed",plans);return end
    reserve.resourcePerSecond,reserve.energyPerSecond=mass,energy
    j.reserves[u]=reserve
    Rules.CurrentSnapshot(a,true)
    u.ai.eState="T4Approach";Emit(a,"retry-site",reason,j)
end
local function Step(a,s,snapshot,plans)
    local j=s.job;if not j then return end
    local owner=s.running
    if not ServiceCurrent(a,s,owner) or j.armyAI~=a.ai or j.main~=owner.base or j.worker~=owner.worker then
        Finish(a,s,"scheduler-replaced",plans);return
    end
    if j.abortReason then Finish(a,s,j.abortReason,plans);return end
    local target=FindTarget(a,j)
    if j.target and not Own(a,j.target) then
        Finish(a,s,"target-destroyed-or-captured",plans);return
    end
    if target then
        j.target=target;j.platoon.ai.buildedUnit=target
        if target:IsCompleted() then
            s.completed[j.id]=(s.completed[j.id] or 0)+1
            s.firstCompletedAt=s.firstCompletedAt or Now()
            local name=a.ai.bases[j.baseName]==j.base and j.baseName or "MAIN"
            if not target.assignedToBase and a.ai.bases[name] then
                if type(AF.SetUnitBaseAssignment)=="function" then AF.SetUnitBaseAssignment(a.id,target,name)
                else target.assignedToBase=name end
            end
            Emit(a,"completed",Name(j.id),j)
            Finish(a,s,"control-handoff",plans);return
        end
        local f=Fraction(target)
        if f>j.fraction+0.000001 then j.progressAt=Now();j.fraction=f end
        if f==0 and j.phase=="moving" then
            -- A host-side foundation can appear before the BUILD call's caller resumes.
            j.phase="starting";j.phaseAt=Now()
        end
        if f>0 and j.phase~="building" then
            j.phase="building";j.phaseAt=Now();Emit(a,"started","paid-construction",j)
        end
        for u in pairs(j.reserves) do ClearReserve(a,j,u) end
    end
    -- Drop stale references without ordering a dead, captured or reassigned unit.
    for u in pairs(j.builders) do
        if not Builder(a,u,false) or not Assignment(a,j,u) or not OrdersOwned(j,u) then Release(a,j,u,plans) end
    end
    if not j.builders[j.lead] then
        if target then
            -- Preserve the paid target. A fresh director platoon will resume it next scan.
            Finish(a,s,"lead-lost-resume-foundation",plans)
        else Finish(a,s,"lead-lost-before-foundation",plans) end
        return
    end
    local u=j.lead
    if not target and j.phase=="funding" then
        local investment=j.pendingInvestment;local now=Now()
        if not investment or now>=investment.expires or now<investment.created then
            Finish(a,s,"funding-window-expired",plans);return
        end
        if P.FirstTarget(a) then Finish(a,s,"first-experimental-priority",plans);return end
        local quote=Rules.HeavyInvestmentBudget(a,u,j.id,snapshot)
        if not quote or not CanFund(a,j.id,snapshot,u) then
            Finish(a,s,"funding-readiness-changed",plans);return
        end
        investment.mass,investment.energy=quote.mass,quote.energy
        if not quote.ready then return end
        local owner=s.running
        j.phase="selecting"
        local site=SelectSite(a,s,u,j.id,j.origin,j.platoon)
        if not ServiceCurrent(a,s,owner) or s.job~=j then return end
        if not Assignment(a,j,u) or not OrdersOwned(j,u) then Finish(a,s,"builder-race",plans);return end
        if Now()>=investment.expires then Finish(a,s,"funding-window-expired",plans);return end
        if not site then Finish(a,s,"no-safe-reachable-site",plans);return end
        -- Placement/path searches can yield while the engineer's live power,
        -- native spending or another investment changes. Price this handoff now.
        quote=Rules.HeavyInvestmentBudget(a,u,j.id)
        if not quote or not quote.ready then Finish(a,s,"construction-budget-changed",plans);return end
        j.site=site;j.phase="moving";j.began=Now();j.progressAt=Now();j.phaseAt=Now()
        j.platoon.ai.placeToBuild=site.position;j.platoon.ai.nextBuildingtpId=j.id;j.platoon.ai.movementLayer=site.layer
        AF.SetReserveEco(a.id,u.id.index,j.id,site.position)
        local reserve=a.ai.ecoReserve and a.ai.ecoReserve[u.id.index]
        if not reserve then Finish(a,s,"construction-reservation-failed",plans);return end
        reserve.resourcePerSecond, reserve.energyPerSecond=quote.mass,quote.energy
        j.reserves[u]=reserve;j.pendingInvestment=nil
        -- Publish the native reservation before a cached census drops the
        -- preceding promise. Snapshot is synchronous and uses no new thread.
        Rules.CurrentSnapshot(a,true)
        Emit(a,"planned",Name(j.id),j)
        return
    end
    if not target and j.phase=="moving" then
        local q=j.site.path[j.pathIndex]
        if not q then
            -- Another project can begin while native placement or path services yield.
            if P.FirstTarget(a) then
                Finish(a,s,"first-experimental-priority",plans);return
            end
            if not R.CanBuilderBuild(u,j.id) or not Place(a,j.id,j.site.position,0,j.site) then
                Reject(s,j.id,j.site.position)
                Finish(a,s,"placement-or-buildability-changed",plans);return
            end
            -- Site selection and movement yield. Revalidate the global commitment
            -- immediately before BUILD, after any other producer could have acted.
            if not Rules.HeavyBuildBudget(a,u,j.id) or not CanFund(a,j.id,snapshot,u) then
                Finish(a,s,"construction-budget-changed",plans);return
            end
            Orders.HostIssueOrder(Tasks.BUILD,{u},false,j.site.position,{tpId=j.id,armyId=a.id})
            SaveOrder(a,j,u,Tasks.BUILD)
            j.issued[u]=Now();j.phase="starting";j.phaseAt=Now();j.progressAt=Now();j.startWatch=nil
            u.ai.eState="T4Starting";Emit(a,"build-issued",Name(j.id),j)
        elseif Dist(u:GetPosition(),q)<=2 then
            j.pathIndex=j.pathIndex+1;j.moveOrder=nil;j.progressAt=Now();j.bestDistance=nil
        else
            local d=Dist(u:GetPosition(),q)
            if not j.bestDistance or d<j.bestDistance-1 then j.bestDistance=d;j.progressAt=Now() end
            if not j.moveOrder or not Order(u) and Now()-(j.issued[u] or 0)>=8 then
                Orders.HostIssueOrder(Tasks.MOVE,{u},false,q,nil)
                SaveOrder(a,j,u,Tasks.MOVE)
                j.moveOrder=true;j.issued[u]=Now();u.ai.eState="T4Approach"
            end
            if Now()-j.progressAt>=35 or Now()-j.began>=180 then
                Reject(s,j.id,j.site.position)
                Finish(a,s,"approach-stalled",plans)
            end
        end
        return
    end
    if target and Fraction(target)>0 then
        local activePower=0
        for b in pairs(j.builders) do if not Paused(b) then activePower=activePower+Power(b) end end
        local desired=math.min(150,Rules.HeavyBuildPower(a,j.id,activePower))
        -- Do not consume the last free T3 power-builder to accelerate a project
        -- whose energy supply still needs development. Recover that builder if a
        -- later power loss makes an already assembled team too expensive.
        local needPowerBuilder=NeedPowerBuilder(a,snapshot,j.id)
        local available=Candidates(a,Position(target:GetPosition()),false)
        local freeT3=0
        for _,b in ipairs(available) do if Tier(b.tp)==3 then freeT3=freeT3+1 end end
        if needPowerBuilder and freeT3==0 then
            local release
            for b in pairs(j.builders) do
                if b~=j.lead and Tier(b.tp)==3 and (not release or b.id.index>release.id.index) then release=b end
            end
            if release then
                Release(a,j,release,plans);freeT3=1
                Emit(a,"assistant-released","T3-power-builder-reserved",j)
            end
        end
        local total,count=0,0
        for b in pairs(j.builders) do
            if not Paused(b) then total=total+Power(b);IssueAssist(a,j,b) end
            count=count+1
        end
        -- The shared first-project service owns extra recruitment and its budget.
        if not P.IsFirstTarget(target) and total<desired and count<10 then
            for _,b in ipairs(available) do
                local t3=Tier(b.tp)==3
                local layer=(Movement.UnitMovementLayer(b) or "Land")
                if total+Power(b)<=desired and not (needPowerBuilder and t3 and freeT3<=1)
                    and MG.CanGraphAreaToStrict(Position(b:GetPosition()),Position(u:GetPosition()),layer) and Attach(a,j,b,plans) then
                    if t3 then freeT3=freeT3-1 end
                    IssueAssist(a,j,b);total=total+Power(b);count=count+1
                    if total>=desired or count>=10 then break end
                end
            end
        end
        if Now()-j.progressAt>=60 then Emit(a,"stalled","paid-foundation-retained",j) end
        -- Resource starvation never deletes/restarts the paid construction.
        return
    end
    if j.phase=="starting" then
        local failure=R.ConstructionStartFailure(u,j,Now())
        if failure then RetryUnstarted(a,s,j,failure,plans) end
    end
end

local function PossibleRange(a,tp)
    local main=a.ai.bases.MAIN;local origin=main.position;local radius=math.min(160,main.radius or 60)
    for i,r in ipairs(a.ai.targets and a.ai.targets.artilleryTargets or {}) do
        if i>24 then break end
        if r.pos and Finite(r.pos.x) and Finite(r.pos.z) and not r.underWater then
            local d=Dist(origin,r.pos)
            for _,w in ipairs(tp.weapons or {}) do
                if Finite(w.rangeMax) and not w.isDeathExplosion and (AF.GetWeaponDamagePerSecond(w) or 0)>0
                    and d<=w.rangeMax+radius and d>=math.max(0,(w.rangeMin or 0)-radius) then return true end
            end
        end
    end
    return false
end
local function LayerAllows(a,tp)
    local layer=a.ai.settings.useLayer
    if not layer then return true end
    if WaterProject(tp) then return layer.water~=false end
    if Has(tp,"STRUCTURE") then return layer.land~=false or layer.air~=false or layer.water~=false end
    local domain=P.Domain(tp)
    return domain=="naval" and layer.water~=false or domain=="air" and layer.air~=false or domain=="land" and layer.land~=false
end
local function LandReachable(a,tp,snapshot)
    if P.Domain(tp)~="land" or not P.IsCombatExperimental(tp) or not snapshot.landDisconnected or snapshot.localLandThreat then return true end
    local profile=P.Profile(tp)
    if not profile or not profile.amphibious then return false end
    local layer=Movement.TemplateMovementLayer(tp)
    if not layer then return false end
    local origin=a.ai.bases.MAIN.position
    for i,r in ipairs(a.ai.targets and a.ai.targets.artilleryTargets or {}) do
        if i>24 then break end
        if r.pos and MG.CanGraphAreaToStrict(origin,r.pos,layer) then return true end
    end
    return false
end
local function Choices(a,snapshot,c)
    local choices={};local s=State(a)
    c.safeBase=not snapshot.landPanic and not snapshot.airPanic and not snapshot.navalPanic
    for id,tp in pairs(__Templates.Units) do
        local kind=P.Kind(a,tp)
        local count=c.byId[id] or 0
        local cap=kind and P.DesiredCount(a,tp,snapshot,c) or 0
        if kind and Legal(a,id) and LayerAllows(a,tp) and count<cap and LandReachable(a,tp,snapshot)
            and Now()>=(s.retry[id] or 0) and Rules.HeavyReady(a,snapshot)
            and (not WaterProject(tp) or c.hasHarbor)
            and (kind~="artillery" and kind~="siege" or PossibleRange(a,tp)) then
            local legal=false
            for _,u in ipairs(c.builders) do if R.CanBuilderBuild(u,id) then legal=true;break end end
            if legal and WaterProject(tp) then
                legal=false
                for _,yard in ipairs(c.harbors) do
                    local pos,graph=HarborSite(yard)
                    if NavalOpportunity(a,tp,pos,graph) then legal=true;break end
                end
            end
            local score=legal and P.ChoiceScore(a,tp,snapshot,c)
            if Finite(score) then choices[#choices+1]={id=id,kind=kind,score=score,cost=tp.economy.cost.alloys} end
        end
    end
    table.sort(choices,function(x,y)
        if x.score~=y.score then return x.score>y.score end
        if x.cost~=y.cost then return x.cost<y.cost end
        return x.id<y.id
    end)
    return choices
end
function CanFund(a,id,snapshot,except)
    if not Legal(a,id) or not snapshot.alloy or not snapshot.energy then return false end
    local m,e=Rules.Resources(a,except);local tp=Template(id)
    if not m or not e then return false end
    local horizon=Horizon(P.Kind(a,tp));local cost=tp.economy.cost
    local upkeep=tp.economy.maintenanceConsumption or {};local production=tp.economy.production or {}
    local massUpkeep=math.max(0,(Finite(upkeep.alloys) and upkeep.alloys or 0)
        -(Finite(production.alloys) and production.alloys or 0))
    local energyUpkeep=math.max(0,(Finite(upkeep.energy) and upkeep.energy or 0)
        -(Finite(production.energy) and production.energy or 0))
    -- Permanent upkeep needs existing surplus; prospective resource output does
    -- not pay construction. The selected builder is checked again before BUILD.
    return m.income>0 and e.income>0 and e.ratio>=0.25
        and (massUpkeep==0 or Rules.Balance(m)>=massUpkeep)
        and (energyUpkeep==0 or Rules.Balance(e)>=energyUpkeep)
        and (m.current>=80 or m.balance>=0)
        and cost.alloys<=m.income*Rules.Config.HeavyShare*horizon+m.current*0.8
        and cost.energy<=e.income*Rules.Config.HeavyShare*horizon+e.current*0.8
end

function EngineerProduct(a,factory,snapshot)
    if not Enabled(a) or not (Has(factory.tp,"LAND_FACTORY")
        or Has(factory.tp,"FACTORY") and Has(factory.tp,"STRUCTURE") and P.Domain(factory.tp)=="land") then return nil end
    if not snapshot.alloy or not snapshot.energy or snapshot.alloy.income<=0 or snapshot.energy.income<=0 then return nil end
    local tier=Tier(factory.tp)
    local state=a.ai.rushHeavyConstruction
    local needed=tier==3 and state and (state.job or state.intent) and Rules.HeavyReady(a,snapshot) and 3
        or tier==3 and 2 or 1
    if tier<2 or tier>3 or ((snapshot.tiers or {})["engineer:"..tier] or 0)>=needed then return nil end
    local ids={}
    for id,tp in pairs(__Templates.Units) do
        if EngineerTemplate(a,tp,false) and Tier(tp)==tier
            and R.AllowedTarget(id,false) and R.CanBuilderBuild(factory,id) then ids[#ids+1]=id end
    end
    table.sort(ids);return ids[1]
end
-- This read-only callback participates in the common economy census. Never
-- call Resources/Snapshot here: that would recurse into the same census.
function PendingInvestmentReserve(a,except)
    local state=a and a.ai and a.ai.rushHeavyConstruction
    local j=state and state.job;local u=j and j.lead
    if not j or not u or u==except or not Enabled(a) or a.ai.isAlive==false
        or not Assignment(a,j,u) or not a.ai.bases or a.ai.bases.MAIN~=j.main
        or not j.main or not j.main.luaThreads or j.main.luaThreads.AILocationManagerThread~=j.worker
        or not Builder(a,u,false) or Paused(u) or not OrdersOwned(j,u) then return 0,0 end
    local r=j.pendingInvestment
    if r then
        local now=Now()
        if r.unit~=u or r.id~=j.id or r.armyAI~=a.ai or r.unitAI~=u.ai or r.main~=j.main or r.worker~=j.worker
            or now<r.created or now>=r.expires or j.target
            or j.phase~="funding" and j.phase~="selecting" then return 0,0 end
        return r.mass,r.energy,u,r.id
    end
    -- Native reservations and paid entities already carry the numerical cost.
    -- Retain only ownership while this real project runs, so optional
    -- supply-limited production cannot reopen its oversized spending bypass.
    local reserve=j.reserves[u]
    if (j.phase=="moving" or j.phase=="starting") and j.site and reserve
        and a.ai.ecoReserve and a.ai.ecoReserve[u.id.index]==reserve and reserve.tpId==j.id then
        return 0,0,u,j.id
    end
    local target=j.target;local order=j.orders[u]
    if Matches(a,j,target) and not target:IsCompleted() and not Paused(target)
        and (Fraction(target)>0 or order and order.orderTask==Tasks.BUILD
            and (Order(u)==order or u.unitBeingBuilt==target or order.unitGettingBuilt==target)) then
        return 0,0,u,j.id
    end
    return 0,0
end

function PowerNeeded(a,snapshot)
    if not Enabled(a) then return false end
    local s=a.ai.rushHeavyConstruction;local id=s and (s.job and s.job.id or s.intent)
    return id and Legal(a,id) and NeedPowerBuilder(a,snapshot,id) or false
end
function AllowsFormer(a,f)
    if not Enabled(a) then return true end
    if f.RushHeavyOwned then return false end
    if f.LoadedTech4Domain then return false end
    local s=a.ai.rushHeavyConstruction
    if s and s.job and (f.InvestmentType=="ExperimentalDevelopment" or f.InvestmentType=="StrategicDevelopment") then return false end
    return true
end
-- Dispatch any actual armed experimental by its native domain. A ship built
-- beside a harbor need not be inside MAIN's land radius to join its naval plan.
function GetCombatUnits(armyIndex,baseName,former)
    local a=Armies[armyIndex]
    if not Enabled(a) or not former.RushHeavyCombat then return false end
    local base=a.ai.bases[baseName];if not base then return false end
    local domain=former.RushHeavyCombat;local candidates={}
    for _,u in pairs(a.units or {}) do
        if Own(a,u) and u:IsCompleted() and P.IsCombatExperimental(u.tp) and P.Domain(u.tp)==domain and not u.platoon
            and not Paused(u) and not R.Working(u) and not OrdersPresent(u)
            and not u.CaptureInProgress and not u.ReclaimInProgress
            and not (u.buildQueue and u.buildQueue[1]) then
            local layer=Movement.UnitMovementLayer(u)
            local walks=domain=="naval" and (layer=="Hover" or layer=="Seabed")
            local graph=domain=="naval" and MarkerGraph(u:GetPosition(),walks and layer or "Water") or nil
            local allowed=true
            if domain=="naval" then
                allowed=graph~=nil
                if base.baseType=="NAVAL" and not walks then
                    allowed=allowed and type(AF.GetNavalGraphAreaForBase)=="function"
                        and AF.GetNavalGraphAreaForBase(armyIndex,baseName)==graph
                end
            elseif domain=="land" and Pressure.EnemyLandConnection(a)==false then
                allowed=false;local layer=Movement.UnitMovementLayer(u)
                for i,r in ipairs(a.ai.targets and a.ai.targets.artilleryTargets or {}) do
                    if i>24 then break end
                    if layer and r.pos and MG.CanGraphAreaToStrict(u:GetPosition(),r.pos,layer) then allowed=true;break end
                end
            end
            if allowed then candidates[#candidates+1]={unit=u,graph=graph} end
        end
    end
    table.sort(candidates,function(x,y) return x.unit.id.index<y.unit.id.index end)
    if candidates[1] then return {candidates[1].unit},1,1,0,candidates[1].graph end
    return false
end
function NormalizeFormers(a,formers)
    if not Enabled(a) then return formers end
    local pools={land={},air={},naval={}};local experimentals={}
    for id,tp in pairs(__Templates.Units) do
        if P.IsT4(tp) then experimentals[id]=true end
        local domain=P.Domain(tp)
        if pools[domain] and P.Kind(a,tp) and P.IsCombatExperimental(tp) then pools[domain][id]=true end
    end
    for _,f in pairs(formers) do
        -- Mobile experimental factories retain their production and combat role.
        for _,line in ipairs(f.NeedMobileBuilder or {}) do line[1]=line[1]-experimentals end
        if f.NeedUnits and not tostring(f.AIPlan):find("Attack",1,true) then
            for _,line in ipairs(f.NeedUnits) do line[1]=line[1]-experimentals end
        end
        if f.FormerName=="T3 Artillery" then f.RushHeavyOwned=true end
        local domain=f.FormerName=="F4 Land Experimental Attack" and "land"
            or f.FormerName=="F4 Air Experimental Attack" and "air"
            or f.FormerName=="F4 Naval Experimental Attack" and "naval"
        if domain then
            f.RushDevelopment=true;f.AIdifficulty={easy=true,medium=true,hard=true}
            f.RushHeavyCombat=domain;f.SkipBusyProductionUnits=true
            f.RunOnBaseType.MAIN=true;f.UseNavalAreaUnits=nil
            f.NeedUnits={{pools[domain],1,1,0}}
            if domain=="air" then
                f.AIPlanData=f.AIPlanData or {};f.AIPlanData.RequireShootableTarget=true
            end
        end
    end
    return formers
end

-- Explicit targeting for fixed artillery. The old unused plan reads tp.Weapon
-- (a foreign schema) and never issues ATTACK. Use the live weapons array and
-- only enemy records already supplied by the target manager, never omniscient units.
function ControlArtillery(a)
    if not Enabled(a) or type(AF.GetEnemyUnitsAroundPosition)~="function" then return end
    local s=State(a)
    local function canFire(u,t)
        if not Own(a,u) or u.CaptureInProgress or u.ReclaimInProgress or R.Working(u)
            or not t or t.dead or t.deleted or t.CaptureInProgress or t.ReclaimInProgress then return false end
        local from,to=Position(u:GetPosition()),Position(t:GetPosition())
        if not from or not to then return false end
        local distance=Dist(from,to)
        for _,weapon in ipairs(u.weapons or {}) do
            local tp=weapon.tp or weapon
            if weapon.enabled and not weapon.isDeathExplosion and not tp.isDeathExplosion
                and (AF.GetWeaponDamagePerSecond(tp) or 0)>0 and type(weapon.CanShootAt)=="function"
                and Finite(tp.rangeMax) and distance>=math.max(0,tp.rangeMin or 0) and distance<=tp.rangeMax
                and weapon:CanShootAt(t)
                and (type(weapon.IsTargetInRange)~="function" or weapon:IsTargetInRange(t)) then return true end
        end
        return false
    end
    for _,u in pairs(a.units or {}) do
        local kind=P.Kind(a,u.tp)
        if Own(a,u) and u:IsCompleted() and not u.platoon and not Paused(u) and not R.Working(u)
            and not u.CaptureInProgress and not u.ReclaimInProgress
            and (kind=="artillery" or kind=="siege" or kind=="strategic") then
            local old=s.fireOrders[u];local active=Order(u)
            local queued=u.orders and u.orders.queuedOrders and next(u.orders.queuedOrders)
            if not queued and (not active or old and active==old.order) and (not old or Now()-old.at>=10) then
                local chosen,best
                for i,r in ipairs(a.ai.targets and a.ai.targets.artilleryTargets or {}) do
                    if i>24 then break end
                    if r.pos and r.tags and not r.underWater then
                        for _,t in ipairs(AF.GetEnemyUnitsAroundPosition(a.id,r.pos,2,r.tags,true) or {}) do
                            if canFire(u,t) then
                                local score=1000-i*10+(P.IsExperimental(t.tp) and 180 or 0)
                                    +(Has(t.tp,"ARTILLERY") and 120 or 0)+(Has(t.tp,"ENERGY_PRODUCTION") and 80 or 0)
                                if not best or score>best or score==best and t.id.index<chosen.id.index then chosen,best=t,score end
                            end
                        end
                    end
                end
                if chosen and canFire(u,chosen) and not u.platoon and not Paused(u)
                    and Order(u)==active and not (u.orders.queuedOrders and next(u.orders.queuedOrders)) then
                    if old and old.target==chosen and active==old.order then old.at=Now()
                    else
                        Orders.HostIssueOrder(Tasks.ATTACKUNIT,{u},false,chosen:GetPosition(),{targetGlobalId=chosen.id})
                        local accepted=Order(u)
                        if accepted and accepted.orderTask==Tasks.ATTACKUNIT and accepted.targetUnit==chosen then
                            s.fireOrders[u]={at=Now(),target=chosen,order=accepted}
                        end
                    end
                end
            end
        end
    end
    for u,r in pairs(s.fireOrders) do
        if not Own(a,u) or Order(u)~=r.order then s.fireOrders[u]=nil end
    end
end

local function UpdateInner(a,snapshot,plans,owner)
    if not Enabled(a) or a.ai.isAlive==false or not a.ai.bases.MAIN then
        local s=a and a.ai and a.ai.rushHeavyConstruction
        if s then Finish(a,s,"disabled-or-base-lost",plans);s.intent=nil end
        return
    end
    local s=State(a)
    if Now()<s.nextTick then return end
    s.nextTick=Now()+1
    if not s.announced then
        s.announced=true
        Emit(a,"policy","all-native-experimentals-and-T3-artillery")
    end
    if s.job then Step(a,s,snapshot,plans) end
    if not ServiceCurrent(a,s,owner) then return end
    if Now()>=(s.nextFire or 0) then s.nextFire=Now()+5;ControlArtillery(a) end
    if s.job or Now()<s.nextStart then return end
    local c=Census(a)
    if c.other then s.intent=nil;return end
    for _,u in ipairs(c.unfinished) do
        if not c.managed[u] and Legal(a,u.tpId) and Now()>=(s.retry[u.tpId] or 0) then
            NewJob(a,s,u.tpId,u,plans,snapshot);return
        end
    end
    -- Any paid foundation (even temporarily unbuildable) owns the expensive slot.
    if #c.unfinished>0 then s.intent=nil;return end
    if snapshot.landPanic or snapshot.airPanic then s.intent=nil;return end
    if not snapshot.underCap then s.intent=nil;Emit(a,"blocked","unit-cap");return end
    local choices=Choices(a,snapshot,c)
    s.intent=choices[1] and choices[1].id
    for _,choice in ipairs(choices) do
        if CanFund(a,choice.id,snapshot) then
            NewJob(a,s,choice.id,nil,plans,snapshot)
            if not ServiceCurrent(a,s,owner) then return end
            if s.job then
                s.intent=choice.id;Step(a,s,snapshot,plans);return
            end
        end
    end
    if s.intent then Emit(a,"saving",s.intent..":income-or-builder-or-site")
    else Emit(a,"waiting","no-legal-target-range-or-harbor") end
end

-- Site/path services may yield or throw. Keep one owner across base threads and
-- release that owner's claims before propagating a host error to the scheduler.
function Update(a,snapshot,plans)
    if not a or not a.ai then return end
    if CleanupUnavailable(a,plans) then return end
    local owner=ServiceOwner(a);if not owner then return end
    local s=State(a)
    if s.running then
        if ServiceCurrent(a,s,s.running) then return end
        -- A replaced location worker cannot keep its construction reservation.
        Finish(a,s,"scheduler-replaced",plans)
    end
    s.running=owner
    local ok,err=pcall(UpdateInner,a,snapshot,plans,owner)
    if s.running~=owner then return end
    s.running=nil
    if not ok then
        if s.job then
            s.job.abortReason="runtime-error-cleanup"
            pcall(Finish,a,s,"runtime-error-cleanup",plans)
        end
        s.nextStart=Now()+20
        Log("[RushHeavy] army="..tostring(a.id).." event=runtime-recovery reason="..tostring(err),true)
        error(err,0)
    end
end

-- One bounded completion team uses only idle AI engineers. Native assistance
-- pays the experimental owner's economy, including a nearby human ally.
local function FirstAssistPosition(u)
    local p=u and u:GetPosition()
    if type(p)~="table" or not Finite(p.x) or not Finite(p.z) then return nil end
    return {x=p.x,y=p.y or 0,z=p.z}
end
local function FirstAssistAssignment(a,s,w)
    return a.ai==s.armyAI and R.CurrentAssignment(w.unit,a,s.platoon,w.ai,s.platoonAI)
end
local function FirstAssistOnlyOrder(u,order)
    local orders=u.orders or {};local found=orders.activeOrder==order
    if orders.activeOrder and not found then return false end
    for _,queued in pairs(orders.queuedOrders or {}) do
        if queued~=order then return false end
        found=true
    end
    return order and found
end
local function ReleaseFirstWorker(a,s,w)
    if w.lease then P.ReleaseFirstAssist(w.lease);w.lease=nil end
    if FirstAssistAssignment(a,s,w) then
        local u=w.unit;local orders=u.orders or {}
        -- Withdrawing this order must never erase a queued replacement.
        for i=#(orders.queuedOrders or {}),1,-1 do
            if orders.queuedOrders[i]==w.order then Orders.RemoveUnitFromQueuedOrder(u,w.order) end
        end
        if w.order and orders.activeOrder==w.order then
            Orders.RemoveUnitFromActiveOrder(u)
            if FirstAssistAssignment(a,s,w) then Orders.TryStartNextOrderForUnit(u) end
        end
        if FirstAssistAssignment(a,s,w) then s.platoon:OnUnitRemoved(u) end
    end
    s.workers[w.unit]=nil
end
local function FirstAssistList(s)
    local list={};for _,w in pairs(s.workers) do list[#list+1]=w end
    table.sort(list,function(x,y) return x.unit.id.index<y.unit.id.index end)
    return list
end
local function DeferFirstWorker(s,u,now,corner)
    local prior=s.retry[u]
    s.retry[u]={untilTime=now+8,expires=now+120,corner=corner or prior and prior.corner or 0}
    local count,oldest,untilTime=0,nil,nil
    for unit,record in pairs(s.retry) do
        count=count+1
        if not untilTime or record.expires<untilTime or record.expires==untilTime and unit.id.index<oldest.id.index then
            oldest,untilTime=unit,record.expires
        end
    end
    if count>32 then s.retry[oldest]=nil end
end
local function FirstAssistReserveRemains(a,s,base,snapshot)
    local idle,assigned=0,0
    for _,u in ipairs(snapshot.balanceEngineers or {}) do
        local _,current=Expansion.IdleEngineerBase(a,u)
        if current==base then idle=idle+1 end
    end
    for _,w in pairs(s.workers) do
        if w.base==base and FirstAssistAssignment(a,s,w) then assigned=assigned+1 end
    end
    return idle>=((idle+assigned>=3) and 2 or 1)
end
local function FirstAssistTarget(a,s)
    local own=P.FirstTarget(a)
    if own and P.CanAssistFirst(a,own) then return own end
    if s.target and P.CanAssistFirst(a,s.target) then return s.target end
    local target,distance
    for _,ally in pairs(Armies or {}) do
        if ally~=a and a:IsAlly(ally) then
            local candidate=P.FirstTarget(ally)
            if candidate and P.CanAssistFirst(a,candidate) then
                local pos=FirstAssistPosition(candidate)
                for _,base in pairs(a.ai.bases or {}) do
                    if pos and base.position then
                        local d=Dist(pos,base.position)
                        if d<=192 and (not distance or d<distance
                            or d==distance and candidate.army.id<target.army.id) then target=candidate;distance=d end
                    end
                end
            end
        end
    end
    return target
end
local function FirstAssistRoute(a,s,owner,w,target,budget)
    local u=w.unit;local start,pos=FirstAssistPosition(u),FirstAssistPosition(target)
    local layer=Movement.UnitMovementLayer(u)
    if not start or not pos or not layer or not Expansion.Safe(a,start,layer)
        or not Expansion.Safe(a,pos,layer) then return false end
    local collider=u.constructionDetectorCollider
    if collider and type(collider.IsCollidingWithGlobalID)=="function"
        and collider:IsCollidingWithGlobalID(target.id) then return true end
    if Dist(start,pos)>192 then return false end
    if budget.paths>=2 then return nil,"deferred" end
    local f=R.Footprint(target.tp);local uf=R.Footprint(u.tp)
    if not f or not uf or type(MG.CanGraphAreaToStrict)~="function" then return false end
    local gap=math.max(uf.x,uf.y)/2+1;local rx,rz=f.x/2+gap,f.y/2+gap
    local points={{rx,0},{-rx,0},{0,rz},{0,-rz},{rx,rz},{-rx,rz},{rx,-rz},{-rx,-rz}}
    table.sort(points,function(x,y)
        local dx=(pos.x+x[1]-start.x)^2+(pos.z+x[2]-start.z)^2
        local dy=(pos.x+y[1]-start.x)^2+(pos.z+y[2]-start.z)^2
        return dx==dy and (x[1]==y[1] and x[2]<y[2] or x[1]<y[1]) or dx<dy
    end)
    local corner=s.retry[u] and s.retry[u].corner or 0
    for i=1,#points do
        local index=(corner+i-1)%#points+1;local offset=points[index]
        local q=Position(SnapToGround({x=pos.x+offset[1],y=0,z=pos.z+offset[2]}))
        if R.Inside(q,gap) and MG.CanGraphAreaToStrict(start,q,layer)
            and Expansion.Safe(a,q,layer) then
            if not Import("AI/mods/AI-Scom/RushPathBudget.lua").Recovery(u) then return nil,"deferred" end
            budget.paths=budget.paths+1;w.nextCorner=index%#points
            local request=Movement.Capture(s.platoon,{u})
            local path=MG.GeneratePathTo(a.id,start,q,layer,true,1)
            if not ServiceCurrent(a,s,owner) or not FirstAssistAssignment(a,s,w) or not P.CanAssistFirst(a,target)
                or R.Working(u) or OrdersPresent(u) or u.buildBehaviorIsActive or Paused(u) then return false end
            return type(path)=="table" and #path>0 and #path<=64
                and Movement.PathThreatSafe(s.platoon,start,path,layer,0,request)
                and Expansion.Safe(a,FirstAssistPosition(u),layer)
        end
    end
    return false
end
local function FirstAssistUpdate(a,s,snapshot,plans,owner)
    local now=Now();local target
    if Enabled(a) and a.ai==s.armyAI and a.ai.isAlive~=false and snapshot
        and not snapshot.landPanic and not snapshot.airPanic and not snapshot.navalPanic then
        target=FirstAssistTarget(a,s)
    end
    if target~=s.target then s.retry={};s.target=target end
    local count=0;local assigned={}
    for _,w in ipairs(FirstAssistList(s)) do
        local u=w.unit;local pos=Own(a,u) and FirstAssistPosition(u)
        local valid=target and w.target==target and FirstAssistAssignment(a,s,w)
            and a.ai.bases[w.baseName]==w.base and not Paused(u)
            and not u.CaptureInProgress and not u.ReclaimInProgress
            and FirstAssistOnlyOrder(u,w.order) and P.CanAssistFirst(a,target)
            and pos and Expansion.Safe(a,pos,Movement.UnitMovementLayer(u))
            and Expansion.Safe(a,FirstAssistPosition(target),Movement.UnitMovementLayer(u))
        if valid then
            local d=Dist(pos,FirstAssistPosition(target))
            local entity=target.resourceEntities and target.resourceEntities.construction
            local source=entity and entity.buildPowerSources and entity.buildPowerSources[u.id]
            if source or d<w.bestDistance-1 then w.bestDistance=math.min(w.bestDistance,d);w.progressAt=now end
            valid=now-w.progressAt<20 and w.lease and P.RefreshFirstAssist(w.lease)
        end
        if not valid then
            ReleaseFirstWorker(a,s,w)
            if target==w.target and Own(a,u) then DeferFirstWorker(s,u,now) end
        else count=count+1;assigned[w.base]=(assigned[w.base] or 0)+1 end
    end
    for u,record in pairs(s.retry) do
        if record.expires<=now or not Own(a,u) then s.retry[u]=nil end
    end
    if not target or count>=24 or a.ai~=s.armyAI then return end
    local pos=FirstAssistPosition(target);if not pos then return end
    local candidates,free,spare={},{},{}
    local protected=Rules.ProtectedPowerBuilder(a,{})
    for _,u in ipairs(snapshot.balanceEngineers or {}) do
        local name,base=Expansion.IdleEngineerBase(a,u)
        if name then
            free[base]=(free[base] or 0)+1
            if not spare[base] or Power(u)>Power(spare[base])
                or Power(u)==Power(spare[base]) and u.id.index<spare[base].id.index then spare[base]=u end
            local upos=FirstAssistPosition(u)
            if u~=protected and upos and Dist(upos,pos)<=192 and (not s.retry[u] or s.retry[u].untilTime<=now)
                and P.FirstAssistAffordable(u,target) then
                candidates[#candidates+1]={unit=u,base=base,baseName=name,distance=Dist(upos,pos),power=Power(u)}
            end
        end
    end
    table.sort(candidates,function(x,y)
        local xs,ys=x.power/(1+x.distance/24),y.power/(1+y.distance/24)
        return xs==ys and x.unit.id.index<y.unit.id.index or xs>ys
    end)
    local added,attempts=0,0;local budget={paths=0}
    for _,candidate in ipairs(candidates) do
        if count>=24 or added>=4 or attempts>=8 or not ServiceCurrent(a,s,owner) or s.target~=target then break end
        local u,base=candidate.unit,candidate.base
        local reserve=((free[base] or 0)+(assigned[base] or 0)>=3) and 2 or 1
        local name,current=Expansion.IdleEngineerBase(a,u)
        if u~=spare[base] and name==candidate.baseName and current==base
            and (free[base] or 0)>reserve and P.CanAssistFirst(a,target)
            and R.PrepareIdleBuilder(u,plans) then
            if not s.platoon or not a:PlatoonExists(s.platoon) then
                s.platoon=a:CreatePlatoon("First experimental completion")
                s.platoonAI={baseName=name,basePosition=base.position,baseRadius=base.radius,
                    formerTable={FormerName="First experimental completion",AIPlan="RushFirstExperimentalAssist",RushT4Project=true}}
                s.platoon.ai=s.platoonAI
            end
            local p=s.platoon;attempts=attempts+1
            p:AssignUnits({u});u.ai=u.ai or {}
            local w={unit=u,ai=u.ai,baseName=name,base=base,target=target,bestDistance=candidate.distance,progressAt=now}
            s.workers[u]=w;p.ai.movementLayer=Movement.MovementLayer(p)
            local reachable,routeReason=FirstAssistRoute(a,s,owner,w,target,budget)
            if not ServiceCurrent(a,s,owner) then return end
            if reachable and FirstAssistAssignment(a,s,w) and not R.Working(u) and not OrdersPresent(u)
                and not Paused(u) and not u.buildBehaviorIsActive
                and FirstAssistReserveRemains(a,s,base,snapshot) then
                w.lease=P.ReserveFirstAssist(u,target)
                if w.lease then
                    Orders.HostIssueOrder(Tasks.ASSISTUNIT,{u},false,FirstAssistPosition(target),{targetGlobalId=target.id})
                    local orders=u.orders or {};local order=orders.activeOrder
                    if not order or order.orderTask~=Tasks.ASSISTUNIT or order.targetUnit~=target then
                        order=nil
                        for _,queued in pairs(orders.queuedOrders or {}) do
                            if queued.orderTask==Tasks.ASSISTUNIT and queued.targetUnit==target then order=queued;break end
                        end
                    end
                    w.order=order
                    if not FirstAssistAssignment(a,s,w) or not FirstAssistOnlyOrder(u,order)
                        or not P.CommitFirstAssist(w.lease,order) then reachable=false end
                else reachable=false end
            else reachable=false end
            if reachable then
                s.retry[u]=nil
                count=count+1;added=added+1;free[base]=free[base]-1;assigned[base]=(assigned[base] or 0)+1
            else
                ReleaseFirstWorker(a,s,w)
                if routeReason=="deferred" then break end
                if Own(a,u) then DeferFirstWorker(s,u,now,w.nextCorner) end
            end
        end
    end
end
function UpdateFirstAssist(a,snapshot,plans)
    if not a or not a.ai then return end
    if CleanupUnavailable(a,plans) then return end
    local s=a.ai.rushFirstExperimentalAssist
    if not s then
        s={armyAI=a.ai,nextTick=0,workers={},retry={}}
        a.ai.rushFirstExperimentalAssist=s
    end
    local owner=ServiceOwner(a);if not owner then return end
    if s.running then
        if ServiceCurrent(a,s,s.running) then return end
        for _,w in ipairs(FirstAssistList(s)) do ReleaseFirstWorker(a,s,w) end
    end
    local now=Now()
    if s.lastTick and now<s.lastTick then
        s.retry={}
        for _,w in pairs(s.workers) do w.progressAt=now end
    elseif now<s.nextTick then return end
    s.lastTick=now;s.nextTick=now+1;s.running=owner
    local ok,err=pcall(FirstAssistUpdate,a,s,snapshot,plans,owner)
    if s.running~=owner then return end
    s.running=nil
    if not ok then
        for _,w in ipairs(FirstAssistList(s)) do pcall(ReleaseFirstWorker,a,s,w) end
        s.nextTick=Now()+4
        error(err,0)
    end
end

-- The supervisor can release these exact claims after MAIN's own loop ends.
-- No replacement thread or construction target is created or destroyed here.
function CleanupUnavailable(a,plans)
    if not a or not a.ai then return true end
    if Enabled(a) and a.ai.isAlive~=false and a.ai.bases and a.ai.bases.MAIN then return false end
    local heavy=a.ai.rushHeavyConstruction
    if heavy then
        heavy.running=nil;Finish(a,heavy,"disabled-or-base-lost",plans);heavy.intent=nil
    end
    local assist=a.ai.rushFirstExperimentalAssist
    if assist then
        assist.running=nil
        for _,w in ipairs(FirstAssistList(assist)) do ReleaseFirstWorker(a,assist,w) end
        assist.target=nil;assist.retry={}
    end
    return true
end
