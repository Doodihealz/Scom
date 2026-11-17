local RushUnitState = Import("AI/mods/AI-Scom/RushUnitState.lua")
-- Naval-only construction, with separate build and engineer approach positions.
-- Native water-area selection, placement checks, canBuild and host orders stay authoritative.
Version = "9.2.8"
local AF = Import("AI/AIFunctions.lua")
local Movement=Import("AI/mods/AI-Scom/RushMovement.lua")
local MG = Import("AI/AIMarkerGenerator.lua")
local R = Import("AI/mods/AI-Scom/RushReliability.lua")
local Layout = Import("AI/mods/AI-Scom/RushBaseLayout.lua")
local Expansion = Import("AI/mods/AI-Scom/RushExpansion.lua")
local Balance = Import("AI/mods/AI-Scom/RushBalance.lua")
local Orders = Import("host/managers/orders/hostOrderManager.lua")
local Tasks = Import("common/commonOrders.lua").OrderTasks
local Log = Import("AI/debugUtilities.lua").AILog
local RADIUS, STEP, SITE_LIMIT = 192, 6, 3
local COOLDOWN, MAX_COOLDOWN, REJECT_TTL = 20, 120, 180
-- These are the installed host modules, including any SCOM placement override.
-- IsOrderValid reads placement; constructing/starting an order would create a ghost.
local hostOK,HostBuild=pcall(Import,"host/managers/orders/orderClasses/hostBuildOrder.lua")
local placementOK,Placement=pcall(Import,"common/systems/placementUtils.lua")
HostBuild=hostOK and type(HostBuild)=="table" and HostBuild.HostBuildOrder or nil
Placement=placementOK and type(Placement)=="table" and Placement or nil
local graphLookupInstalled=false
local function WaterOffset(tp)
    local construction=tp and tp.construction
    local point=construction and construction.rollOffPoints and construction.rollOffPoints[1]
    if point and point.offset then return point.offset end
    -- The editable Chosen shipyard supplies authored ramps instead of native
    -- rollOffPoints. Read its actual exit without rewriting the unit template.
    local ramps=tp and tp.additions and tp.additions.rollOffRamps
    local ramp=ramps and ramps[1]
    if tp and tp.general and tp.general.requiresWaterPlacement and ramp then return ramp.rampOffset end
end
function GraphAreaAtPosition(position,id)
    local offset=WaterOffset(__Templates.Units[id])
    if not offset then return nil end
    local water={x=position.x+offset.x,y=(position.y or 0)+offset.y,z=position.z+offset.z}
    local graph,marker=MG.GetGraphAreaAtPosition(water,"Water",false)
    return graph,marker and marker.position or nil
end
function Install(isRush)
    if graphLookupInstalled then return end
    graphLookupInstalled=true
    local original=AF.GetNavalUnitGraphArea
    AF.GetNavalUnitGraphArea=function(unit)
        local tp=unit and unit.tp
        if unit and R.Own(unit.army,unit) and isRush(unit.army)
            and R.Has(tp,"NAVAL_FACTORY") and R.Has(tp,"SCFA_STRUCTURE")
            and tp.general and tp.general.requiresWaterPlacement then
            return GraphAreaAtPosition(unit:GetPosition(),unit.tpId)
        end
        return original(unit)
    end
end
local function Now() return GetGameTimeSeconds() end
local function Dist(a,b) return math.sqrt((a.x-b.x)^2+(a.z-b.z)^2) end
local function Copy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function Pos(p) return p and string.format("%.1f,%.1f",p.x,p.z) or "none" end
local function State(army,base)
    army.ai.rushNavalConstruction = army.ai.rushNavalConstruction or {}
    local s=army.ai.rushNavalConstruction[base]
    local current=army.ai.bases and army.ai.bases[base]
    local now=Now()
    if not s or s.armyAI~=army.ai or s.baseObject~=current or now<(s.lastTime or now) then
        s={retryAt=0,rejected={},cursor=1,failedJobs=0,armyAI=army.ai,baseObject=current}
        army.ai.rushNavalConstruction[base]=s
    end
    s.lastTime=now
    return s
end
function Ready(army,base)
    return Now()>=(State(army,base).retryAt or 0)
end
local function Valid(w)
    local valid=R.Own(w.army,w.builder) and w.builder.platoon==w.platoon
        and w.army.ai==w.armyAI and w.armyAI.isAlive~=false
        and w.platoon.army==w.army and w.platoon.ai==w.pai and not w.platoon.dead and not w.platoon.deleted
        and w.builder.ai==w.uai and not w.builder.CaptureInProgress and not w.builder.ReclaimInProgress
        and w.uai.eState~="RepairHome" and w.armyAI.bases[w.base]==w.baseObject
        and w.army:PlatoonExists(w.platoon) and Now()>=w.began
    if valid then w.lastPosition=Copy(w.builder:GetPosition()) end
    return valid
end
local function OrderSet(u)
    local state=u.orders
    if state==nil then return {} end
    if type(state)~="table" or state.activeOrder~=nil and type(state.activeOrder)~="table"
        or state.queuedOrders~=nil and type(state.queuedOrders)~="table" then return nil end
    local result={};local queued=state.queuedOrders or {};local count=0
    if state.activeOrder then result[state.activeOrder]=true end
    for index,order in pairs(queued) do
        if type(index)~="number" or index<1 or index%1~=0 or type(order)~="table" then return nil end
        count=count+1;result[order]=true
    end
    if count~=#queued then return nil end
    return result
end
local function OwnOrders(w)
    if w.foreignOrders then return false end
    local current=OrderSet(w.builder)
    if not current then w.foreignOrders=true;return false end
    local route=w.uai.rushMoveQueue
    if route and route==w.moveQueue then
        for order in pairs(route.orders) do w.orders[order]=true end
    end
    for order in pairs(current) do
        if not w.orders[order] then w.foreignOrders=true;return false end
    end
    w.orders=current
    return true
end
local function Event(w,event,reason,target)
    local u=w.builder
    local state=u and type(u.orders)=="table" and u.orders or {}
    local order=type(state.activeOrder)=="table" and state.activeOrder or nil
    local queued=type(state.queuedOrders)=="table" and #state.queuedOrders or 0
    local fraction=target and not target.dead and not target.deleted and target:GetFractionComplete() or 0
    local position=R.Own(w.army,u) and Copy(u:GetPosition()) or w.lastPosition
    local overlap="unknown"
    local detector=u and u.constructionDetectorCollider
    if target and R.Own(w.army,u) and R.Own(w.army,target) and detector and type(detector.IsOverlappingUnit)=="function" then
        local ok,value=pcall(detector.IsOverlappingUnit,detector,target)
        if ok then overlap=tostring(value) end
    end
    Log(string.format("[RushNaval] army=%s base=%s builder=%s/%s layer=%s event=%s reason=%s site=%s approach=%s position=%s order=%s queued=%d accepted=%s target=%s fraction=%.4f preflight=%s rejected=%d repaths=%d range=%s overlap=%s",
        tostring(w.army.id),tostring(w.base),tostring(u and u.tpId),tostring(u and u.id.index),tostring(w.layer),event,reason or "none",
        Pos(w.site and w.site.position),Pos(w.site and w.site.approach),Pos(position),
        tostring(order and order.orderTask),queued,tostring(w.buildAccepted),tostring(target and target.id.index),fraction,
        w.preflight or "unchecked",w.preflightRejected or 0,w.repaths or 0,
        tostring(u and (u.construction and u.construction.range or u.tp.construction and u.tp.construction.range)),overlap))
end
local function ClearReservation(w)
    local reserves=w.armyAI.ecoReserve
    local current=reserves and reserves[w.builder.id.index]
    if w.reservation and current==w.reservation then
        if w.army.ai==w.armyAI and w.builder.ai==w.uai and R.Own(w.army,w.builder)
            and type(AF.ClearReserveEco)=="function" then
            AF.ClearReserveEco(w.army.id,w.builder.id.index)
        else reserves[w.builder.id.index]=nil end
    end
    -- A private callback can be removed after reassignment without unregistering
    -- another job's otherwise identical economy callback.
    if w.callback then
        w.builder:RemoveCallback(w.callback,"OnDestroyed");w.callback=nil
    end
    w.reservation=nil
end
local function Stop(w)
    if Valid(w) then
        local owned=OwnOrders(w)
        if w.moveQueue and w.uai.rushMoveQueue==w.moveQueue then
            -- A malformed replacement queue is foreign too. Forget its old AI
            -- route without asking the movement helper to inspect native tails.
            Movement.Forget(w.builder,OrderSet(w.builder)~=nil)
        end
        w.moveQueue=nil
        if owned and next(w.orders) then Orders.HostClearOrder({w.builder});w.orders={} end
    end
    ClearReservation(w)
end
-- ExitPlatoon must not run its generic order/temporary-data cleanup on a newer
-- assignment. Return true only when that remaining cleanup is still ours.
function ReleaseUnit(unit,platoon)
    local w=platoon.ai and platoon.ai.rushNavalJob
    if not w or w.builder~=unit or w.platoon~=platoon then return false end
    local safe=Valid(w) and OwnOrders(w)
    local reserve=w.army.ai.ecoReserve and w.army.ai.ecoReserve[unit.id.index]
    safe=safe and (reserve==nil or reserve==w.reservation)
    Stop(w)
    if platoon.ai==w.pai and w.pai.rushNavalJob==w then w.pai.rushNavalJob=nil end
    return safe
end
local function NativePlacement(w,position)
    if w.preflightUnavailable then return true,position end
    if not HostBuild or type(HostBuild.IsOrderValid)~="function" or not Placement
        or type(Placement.SnapToBuildGrid)~="function" or type(Placement.GetPlacementHeight)~="function" then
        w.preflight="unavailable";w.preflightUnavailable=true;return true,position
    end
    local ok,valid,normalized=pcall(function()
        local tp=__Templates.Units[w.id]
        local p=Copy(Placement.SnapToBuildGrid(tp,Copy(position)))
        p.y=Placement.GetPlacementHeight(tp,p.x,p.z)
        local order={tpId=w.id,tp=tp,armyId=w.army.id,positionFloat3=p}
        return HostBuild.IsOrderValid(order),p
    end)
    if not ok or type(valid)~="boolean" then
        -- Optional compatibility optimization only: ordinary BUILD still calls
        -- the installed authoritative validator and owns the actual range check.
        w.preflight="unavailable-error";w.preflightUnavailable=true;return true,position
    end
    w.preflight=valid and "accepted" or "rejected"
    if not valid then w.preflightRejected=(w.preflightRejected or 0)+1 end
    return valid,normalized
end
local function IsRejected(w,p)
    for i=#w.state.rejected,1,-1 do
        local r=w.state.rejected[i]
        if r.untilTime<=Now() then table.remove(w.state.rejected,i)
        elseif Dist(p,r.position)<r.radius then return true end
    end
    return false
end
local function Reject(w,p)
    local rs=w.state.rejected
    rs[#rs+1]={position=p,radius=math.max(12,math.min(w.skirt.x,w.skirt.y)),untilTime=Now()+REJECT_TTL}
    if #rs>24 then table.remove(rs,1) end
end
local function AvailableAreas(w)
    local areas={}
    local base=w.army.ai.bases[w.base]
    local required=w.capacity and base and base.baseType=="NAVAL" and base.waterGraphArea
    for graph,area in pairs(AF.GetNavalAreaData(w.army.id,true)) do
        local count=area.factoryCount+area.incompleteFactoryCount+area.queuedFactoryCount
        if (w.capacity and area.factoryCount>0 or not w.capacity and count<1)
            and (not required or graph==required) then
            areas[graph]={expansions=area.expansions,count=count,yards={}}
        end
    end
    if w.capacity then
        for _,u in pairs(w.army.units or {}) do
            if R.Own(w.army,u) and u:IsCompleted() and R.Has(u.tp,"NAVAL_FACTORY") then
                local graph=AF.GetNavalUnitGraphArea(u)
                if areas[graph] then areas[graph].yards[#areas[graph].yards+1]=u:GetPosition() end
            end
        end
    end
    return areas
end
local function SiteClear(w,position)
    local exits=Layout.FactoryExits(__Templates.Units[w.id],position)
    local function overlaps(p,x,z,q,qx,qz)
        return math.abs(p.x-q.x)<(x+qx)/2+0.5 and math.abs(p.z-q.z)<(z+qz)/2+0.5
    end
    local function clear(tp,p,unit)
        local f=R.Footprint(tp);if not f then return true end
        if overlaps(position,w.skirt.x,w.skirt.y,p,f.x,f.y) then return false end
        for _,exit in ipairs(exits) do
            if overlaps(exit.pos,exit.x,exit.z,p,f.x,f.y) then return false end
        end
        if R.Has(tp,"NAVAL_FACTORY") then
            for _,exit in ipairs(Layout.FactoryExits(tp,p,unit)) do
                if overlaps(position,w.skirt.x,w.skirt.y,exit.pos,exit.x,exit.z) then return false end
            end
        end
        return true
    end
    for _,u in pairs(w.army.units or {}) do
        if R.Own(w.army,u) and R.Has(u.tp,"STRUCTURE") and not clear(u.tp,u:GetPosition(),u) then return false end
    end
    for _,p in pairs(w.army.platoons or {}) do
        local ai=p.ai;local tp=ai and __Templates.Units[ai.nextBuildingtpId]
        if p~=w.platoon and not p.dead and not p.deleted and tp and R.Has(tp,"STRUCTURE")
            and ai.placeToBuild and not clear(tp,ai.placeToBuild) then return false end
    end
    return true
end
local function SortedCandidates(w,nativePosition)
    local list,seen,distances,priorities={},{},{},{}
    local function add(x,z,allowDistant,priority)
        -- Grid anchoring follows the actual skirt, including odd-sized half-cell centres.
        x=math.floor(x-w.skirt.x/2+0.5)+w.skirt.x/2
        z=math.floor(z-w.skirt.y/2+0.5)+w.skirt.y/2
        local p={x=x,y=0,z=z};local key=x..":"..z
        if not seen[key] then
            local distance = Dist(p,w.origin)
            if (allowDistant or distance<=RADIUS) and R.Inside(p,math.max(w.skirt.x,w.skirt.y)/2+1) then
                seen[key]=p;list[#list+1]=p;distances[p]=distance;priorities[p]=priority or 1
                return p
            end
        elseif priority and priority<priorities[seen[key]] then priorities[seen[key]]=priority end
    end
    local native=nativePosition and add(nativePosition.x,nativePosition.z,true)
    -- Imported shipyards occupy water. The native shoreline finder requires a
    -- Land graph at the factory center, which rejects these legal templates.
    -- Keep each water area's nearest authored expansion as a distant option;
    -- actual placement and the engineer's own approach layer are checked later.
    local rollOff=WaterOffset(__Templates.Units[w.id])
    for _,area in pairs(w.areas or {}) do
        -- Established shipyards supply real, reachable shoreline anchors for
        -- additional capacity in the same basin; the first-yard finder cannot.
        for _,yard in ipairs(area.yards) do
            local reach=math.max(48,math.min(96,math.max(w.skirt.x,w.skirt.y)*2+12))
            for dx=-reach,reach,STEP do
                for dz=-reach,reach,STEP do add(yard.x+dx,yard.z+dz,true,0) end
            end
        end
        local closest,distance
        for _,expansion in pairs(area.expansions or {}) do
            local d=Dist(expansion,w.origin)
            if not distance or d<distance or d==distance and (expansion.x<closest.x
                or expansion.x==closest.x and expansion.z<closest.z) then
                closest,distance=expansion,d
            end
        end
        if closest then
            local x,z=closest.x-rollOff.x,closest.z-rollOff.z
            add(x,z,true)
            for dx=-24,24,STEP do
                for dz=-24,24,STEP do add(x+dx,z+dz,true) end
            end
        end
    end
    for dx=-RADIUS,RADIUS,STEP do
        for dz=-RADIUS,RADIUS,STEP do add(w.origin.x+dx,w.origin.z+dz) end
    end
    table.sort(list,function(a,b)
        if a==native then return b~=native end
        if b==native then return false end
        if priorities[a]~=priorities[b] then return priorities[a]<priorities[b] end
        local ad,bd=distances[a],distances[b]
        if ad~=bd then return ad<bd end
        return a.x==b.x and a.z<b.z or a.x<b.x
    end)
    return list
end
local function Approach(w,p)
    -- Stand OUTSIDE the construction skirt. The host then performs its own
    -- collider/range approach; MOVE must never target the reserved factory centre.
    local f=R.Footprint(w.builder.tp) or {x=1,y=1}
    local gap=math.max(f.x,f.y)/2+1
    local x,z=w.skirt.x/2+gap,w.skirt.y/2+gap
    local offsets={{x,0},{-x,0},{0,z},{0,-z},{x,z},{x,-z},{-x,z},{-x,-z}}
    local options={}
    for _,o in ipairs(offsets) do
        local q=Copy(SnapToGround({x=p.x+o[1],y=0,z=p.z+o[2]}))
        if R.Inside(q,gap) and MG.IsPathable(q.x,q.z) then options[#options+1]=q end
    end
    local start=Copy(w.builder:GetPosition())
    local distances={}
    for _,q in ipairs(options) do distances[q]=Dist(q,start) end
    table.sort(options,function(a,b)
        local ad,bd=distances[a],distances[b]
        if ad~=bd then return ad<bd end
        return a.x==b.x and a.z<b.z or a.x<b.x
    end)
    for _,q in ipairs(options) do
        if w.pathChecks>=16 then return nil,"path-search-budget" end
        -- This is the BUILDER's movement layer, not the ship/factory water layer.
        -- Strict graph matching rejects the neighbour-cell fallback at a cliff.
        if MG.CanGraphAreaToStrict(start,q,w.layer) then
            w.pathChecks=w.pathChecks+1
            local path=Movement.CopyPath(MG.GeneratePathTo(w.army.id,start,q,w.layer,true,1))
            WaitTicks(1)
            if not Valid(w) then return nil,"builder-unavailable" end
            if not OwnOrders(w) then return nil,"foreign-orders" end
            if type(path)=="table" and #path>0 then
                return {position=p,approach=q,path=Movement.CopyPath(MG.StraightenPath(path))}
            end
        end
    end
    return nil,"no-reachable-approach"
end
local function SelectSite(w)
    local checked=0
    while w.cursor<=#w.candidates do
        local p=w.candidates[w.cursor];w.cursor=w.cursor+1
        w.state.cursor=w.cursor
        checked=checked+1
        if checked%32==0 then WaitTicks(1) end
        if not Valid(w) then return nil,"builder-unavailable" end
        if not OwnOrders(w) then return nil,"foreign-orders" end
        -- The factory serves the water graph at its roll-off point, not at its shoreline centre.
        local graph,waterPosition=GraphAreaAtPosition(p,w.id)
        if not IsRejected(w,p) and (w.areas and w.areas[graph] or not w.areas and graph==w.graph) then
            w.placementChecks=w.placementChecks+1
            if w.placementChecks>128 then
                w.cursor=w.cursor-1;w.state.cursor=w.cursor
                return nil,"placement-search-budget"
            end
            p=Copy(SnapToGround(p))
            if R.PlacementContract(w.id,p) and AF.CanBuildStructureAt(w.army.id,w.id,p,0)
                and Expansion.Safe(w.army,p,"Water") and SiteClear(w,p) then
                local nativeOK,normalized=NativePlacement(w,p)
                if nativeOK then
                    graph,waterPosition=GraphAreaAtPosition(normalized,w.id)
                    nativeOK=w.areas and w.areas[graph] or not w.areas and graph==w.graph
                end
                if nativeOK then
                    p=normalized
                    local site,reason=Approach(w,p)
                    if site and AF.CanBuildStructureAt(w.army.id,w.id,p,0)
                        and NativePlacement(w,p) and Expansion.Safe(w.army,p,"Water") and SiteClear(w,p) then
                        site.graph=graph;site.waterPosition=waterPosition and Copy(waterPosition);return site
                    end
                    if not site and reason~="no-reachable-approach" then
                        if reason=="path-search-budget" then w.cursor=w.cursor-1;w.state.cursor=w.cursor end
                        return nil,reason
                    end
                end
            end
        end
    end
    w.state.cursor=1
    return nil,"no-local-buildable-reachable-site"
end
local function Travel(w)
    local u=w.builder
    if not Valid(w) then return false,"builder-unavailable" end
    if not OwnOrders(w) then return false,"foreign-orders" end
    w.uai.eState="NavalApproach"
    local began,last,position=Now(),Now(),Copy(u:GetPosition())
    local path=w.site.path
    local function route(points)
        local remaining={};local skip=true;local current=u:GetPosition()
        for _,p in ipairs(points) do
            if not skip or Dist(current,p)>1.5 then skip=false;remaining[#remaining+1]=p end
        end
        if #remaining==0 then return Dist(u:GetPosition(),w.site.approach)<=1.5 end
        w.pai.path=remaining
        local accepted=Movement.Begin(w.platoon,remaining,w.site.approach,Tasks.MOVE,
            Movement.Capture(w.platoon,{u}))
        w.moveQueue=w.uai.rushMoveQueue
        if not Valid(w) or not OwnOrders(w) then return false end
        return accepted or Dist(u:GetPosition(),w.site.approach)<=1.5
    end
    if not route(path) then
        return false,w.foreignOrders and "foreign-orders" or not Valid(w) and "builder-unavailable" or "approach-order-rejected"
    end
    local repaths=0
    while Valid(w) do
        if not OwnOrders(w) then return false,"foreign-orders" end
        if Dist(u:GetPosition(),w.site.approach)<=1.5 then
            -- BUILD owns final collider/range admission and may approach further.
            -- Retain accepted MOVE identities until BUILD replaces them or Stop.
            if w.moveQueue and w.uai.rushMoveQueue==w.moveQueue then Movement.Forget(u,false) end
            w.moveQueue=nil;return true
        end
        Movement.MaintainUnit(u)
        if not Valid(w) then return false,"builder-unavailable" end
        if not OwnOrders(w) then return false,"foreign-orders" end
        local current=Copy(u:GetPosition())
        if Dist(current,position)>=1 then position,last=current,Now() end
        if Now()-last>=25 or Now()-began>=180 then return false,"approach-no-progress" end
        if not next(w.orders) then
            -- Native MOVE can finish at its best reachable point. Its bounded
            -- queue advances past intermediate waypoints; a failed final approach
            -- receives at most two fresh native routes, never a wider build range.
            if repaths>=2 or w.pathChecks>=16 then return false,"approach-route-ended" end
            repaths=repaths+1;w.repaths=(w.repaths or 0)+1;w.pathChecks=w.pathChecks+1
            if not MG.CanGraphAreaToStrict(current,w.site.approach,w.layer) then return false,"approach-route-ended" end
            path=Movement.CopyPath(MG.GeneratePathTo(w.army.id,current,w.site.approach,w.layer,true,1))
            WaitTicks(1)
            if not Valid(w) then return false,"builder-unavailable" end
            if not OwnOrders(w) then return false,"foreign-orders" end
            if #path==0 or not route(Movement.CopyPath(MG.StraightenPath(path))) then
                return false,w.foreignOrders and "foreign-orders" or "approach-order-rejected"
            end
            Event(w,"repath","final-approach-ended")
        end
        WaitTicks(5)
    end
    return false,"builder-unavailable"
end
local function Matches(w,target)
    if type(target)~="table" or type(target.id)~="table" or type(target.GetPosition)~="function"
        or type(target.GetFractionComplete)~="function" or type(target.IsCompleted)~="function"
        or not R.Own(w.army,target) or target.tpId~=w.id then return false end
    local p=target:GetPosition()
    return type(p)=="table" and type(p.x)=="number" and type(p.z)=="number"
        and Dist(p,w.site.position)<2
end
local function Target(w)
    local u=w.builder
    if Matches(w,w.target) then return w.target end
    local order=u.orders and u.orders.activeOrder
    for _,field in ipairs({"unitBeingBuilt","buildBehaviorActualUnit"}) do
        if Matches(w,u[field]) then w.target=u[field];return w.target end
    end
    if order and Matches(w,order.unitGettingBuilt) then w.target=order.unitGettingBuilt;return w.target end
    for _,queued in ipairs(u.orders and u.orders.queuedOrders or {}) do
        if Matches(w,queued.unitGettingBuilt) then w.target=queued.unitGettingBuilt;return w.target end
    end
    -- A very short host build can finish between polls. Recover the exact own
    -- target at this site even after the host has cleared its order fields.
    if not w.lastTargetScan or Now()-w.lastTargetScan>=2 then
        w.lastTargetScan=Now()
        for _,target in pairs(w.army.units or {}) do
            if Matches(w,target) then w.target=target;return target end
        end
    end
end
local function ResourceWait(w)
    local totals=w.army.economy and w.army.economy.totals
    for _,key in ipairs({"energy","alloys"}) do
        local r=totals and totals[key]
        if r and type(r.current)=="number" and r.current<1 then return true end
    end
    return RushUnitState.IsPaused(w.builder)==true
end
local function IssueConstruction(w,task,target)
    if not Valid(w) or not OwnOrders(w) then return false end
    local before=OrderSet(w.builder)
    local position=target and Copy(target:GetPosition()) or w.site.position
    local payload=target and {targetGlobalId=target.id} or {tpId=w.id,armyId=w.army.id}
    Orders.HostIssueOrder(task,{w.builder},false,position,payload)
    if not Valid(w) then return false end
    local current=OrderSet(w.builder)
    if not current then w.foreignOrders=true;return false end
    local accepted=false
    for order in pairs(current) do
        local p=order.positionFloat3
        local matches=task==Tasks.BUILD and order.tpId==w.id and order.armyId==w.army.id
            and type(p)=="table" and type(p.x)=="number" and type(p.z)=="number" and Dist(p,position)<1
            or task==Tasks.ASSISTUNIT and order.targetUnit==target
        if not before[order] and order.orderTask==task and matches then
            w.orders[order]=true;accepted=true
        end
    end
    OwnOrders(w)
    return accepted
end
local function ConstructionActive(w)
    for order in pairs(w.orders) do
        if order.orderTask==Tasks.BUILD or order.orderTask==Tasks.ASSISTUNIT then return true end
    end
    return false
end
local function Build(w)
    local u=w.builder
    if not Valid(w) then return false,"builder-unavailable" end
    if not OwnOrders(w) then return false,"foreign-orders" end
    if not R.CanBuilderBuild(u,w.id) then return false,"builder-cannot-build" end
    if w.capacity and not Balance.CapacityAffordable(u,w.id) then return false,"capacity-budget-changed" end
    if not AF.CanBuildStructureAt(w.army.id,w.id,w.site.position,0) or not SiteClear(w,w.site.position) then return false,"placement-changed" end
    if not Expansion.Safe(w.army,w.site.position,"Water") then return false,"site-threatened" end
    if not NativePlacement(w,w.site.position) then return false,"native-placement-changed" end
    -- A single BUILD starts the host approach. Do not replace it merely because
    -- unitBeingBuilt is nil while the host creates/acknowledges its target.
    w.buildAccepted=IssueConstruction(w,Tasks.BUILD)
    if not Valid(w) then return false,"builder-unavailable" end
    if not OwnOrders(w) then return false,"foreign-orders" end
    local issued,lastProgress,bestDistance=Now(),Now(),math.huge
    local fraction,target,started,assists=0,Target(w),false,0
    w.uai.eState="NavalStarting"
    Event(w,"build-issued",nil,target)
    while Valid(w) do
        WaitTicks(5)
        if not Valid(w) then return false,"builder-unavailable" end
        if not OwnOrders(w) then return false,"foreign-orders",target end
        if target and not Matches(w,target) then return false,"target-lost",target end
        local current=Target(w)
        if current then target=current end
        if target and not Matches(w,target) then return false,"target-lost",target end
        if target then
            w.pai.buildedUnit=target
            if target:IsCompleted() then
                w.paidProgress=true;w.state.failedJobs=0
                Event(w,"completed",nil,target);return true
            end
            local f=target:GetFractionComplete()
            if f>fraction+0.000001 then fraction,lastProgress=f,Now() end
            if f>0 and not started then
                started=true;w.paidProgress=true;w.state.failedJobs=0
                ClearReservation(w);w.uai.eState="Building";Event(w,"started",nil,target)
            end
        end
        local d=Dist(u:GetPosition(),w.site.position)
        if not started and d<bestDistance-1 then bestDistance,lastProgress=d,Now() end
        local active=ConstructionActive(w)
        local elapsed=Now()-issued
        -- A queued BUILD/ASSIST is accepted work too. An invalid host BUILD can
        -- leave the previous MOVE intact, so task-less/old MOVE is not an ack.
        if elapsed>=3 and not active and not u.buildBehaviorIsActive then
            if target and fraction>0 and assists<2 then
                -- Reattach to the paid foundation, never create a duplicate BUILD.
                assists=assists+1
                IssueConstruction(w,Tasks.ASSISTUNIT,target)
                if not Valid(w) then return false,"builder-unavailable",target end
                if not OwnOrders(w) then return false,"foreign-orders",target end
                issued=Now();Event(w,"resume","paid-foundation",target)
            else
                return false,started and "paid-foundation-order-ended" or "build-order-rejected-or-ended",target
            end
        end
        if not started then
            local limit=ResourceWait(w) and 180 or 45
            if elapsed>=limit or Now()-lastProgress>=30 and not ResourceWait(w) then
                return false,"construction-never-started",target
            end
        elseif Now()-lastProgress>=(ResourceWait(w) and 300 or 180) then
            return false,"paid-foundation-no-progress",target
        end
    end
    return false,"builder-unavailable",target
end

-- Called after the standard selector has assigned a buildable native faction
-- template and idle engineers. ExitPlatoon remains the sole owner of disbanding.
function Run(platoon,request)
    local army=platoon.army
    local base=platoon.ai.baseName
    local state=State(army,base)
    if not Ready(army,base) then return false end
    local units={}
    for _,u in ipairs(platoon:GetUnits()) do units[#units+1]=u end
    table.sort(units,function(a,b) return a.id.index<b.id.index end)
    local builder,id
    for _,u in ipairs(units) do
        local candidate=request and request[u.factionTag]
        local orders=OrderSet(u)
        if R.Own(army,u) and u:IsCompleted() and not R.Has(u.tp,"COMMAND")
            and R.Has(u.tp,"MOBILE") and R.Has(u.tp,"ENGINEER")
            and u.ai and u.platoon==platoon and not u.CaptureInProgress and not u.ReclaimInProgress
            and orders and not next(orders) and not (army.ai.ecoReserve and army.ai.ecoReserve[u.id.index])
            and candidate and R.Has(__Templates.Units[candidate],"NAVAL_FACTORY")
            and R.AllowedTarget(candidate,false) and R.CanBuilderBuild(u,candidate) then builder,id=u,candidate;break end
    end
    local w={army=army,base=base,state=state,platoon=platoon,builder=builder,id=id,
        armyAI=army.ai,pai=platoon.ai,uai=builder and builder.ai,baseObject=army.ai.bases[base],
        origin=Copy(platoon.ai.basePosition),placementChecks=0,pathChecks=0,orders={},began=Now(),
        capacity=platoon.ai.formerTable.RushNavalCapacity==true}
    -- This only backs off failed site/host attempts, never the opening policy.
    state.retryAt=Now()+COOLDOWN
    if not builder then Event(w,"aborted","no-legal-noncommander-engineer");return false end
    w.pai.rushNavalJob=w
    w.lastPosition=Copy(builder:GetPosition())
    -- Never keep extra idle constructors assigned to a one-engineer naval job.
    for _,u in ipairs(units) do
        -- Native RemoveUnits also clears orders. These workers have never
        -- received a naval command; detach them without touching their queue.
        if u~=builder and u.platoon==platoon then platoon:OnUnitRemoved(u) end
    end
    w.skirt=R.Footprint(__Templates.Units[id])
    w.layer=(Movement.UnitMovementLayer(builder) or "Land")
    platoon.ai.movementLayer=w.layer
    if not w.skirt or not w.layer then Event(w,"aborted","missing-footprint-or-movement-layer");return false end
    local tp=__Templates.Units[id]
    if not WaterOffset(tp) then Event(w,"aborted","missing-naval-rolloff");return false end
    local nativePosition,graph,navalPosition
    local graphKey
    if w.capacity or tp.general and tp.general.requiresWaterPlacement then
        w.areas=AvailableAreas(w)
        if not next(w.areas) then Event(w,"aborted",w.capacity and "no-established-water-area" or "no-unserved-water-area");return false end
        local keys={}
        for key,area in pairs(w.areas) do keys[#keys+1]=tostring(key)..":"..area.count end
        table.sort(keys)
        graphKey=(w.capacity and "capacity:" or "opening:")..table.concat(keys,",")
    else
        nativePosition,graph,navalPosition=AF.FindNavalFactoryBuildPosition(army.id,id,w.origin)
        nativePosition=nativePosition and Copy(nativePosition);navalPosition=navalPosition and Copy(navalPosition)
        if not nativePosition or not graph then Event(w,"aborted","native-no-naval-site");return false end
        graphKey=tostring(graph)
    end
    if not Valid(w) or not OwnOrders(w) then Stop(w);return false end
    w.graph=graph
    platoon.ai.nextBuildingtpIds=request;platoon.ai.nextBuildingtpId=id
    platoon.ai.waterGraphArea=graph;platoon.ai.navalPosition=navalPosition
    -- Candidate geometry is base-local and reusable. Occupancy, terrain,
    -- build permissions and approach paths are ALWAYS revalidated in SelectSite.
    local key=id..":"..Pos(w.origin)..":"..graphKey..":"..w.skirt.x..":"..w.skirt.y..":"..Pos(nativePosition)
    if state.key~=key then state.key=key;state.cursor=1;state.candidates=nil end
    if not state.candidates then state.candidates=SortedCandidates(w,nativePosition) end
    w.candidates=state.candidates
    w.cursor=math.min(state.cursor or 1,#w.candidates+1)
    local success,reason=false,"site-attempt-limit"
    for attempt=1,SITE_LIMIT do
        w.target=nil;w.lastTargetScan=nil;w.buildAccepted=nil
        w.site,reason=SelectSite(w)
        if not w.site then break end
        local p=w.site.position
        w.graph=w.site.graph
        platoon.ai.waterGraphArea=w.graph;platoon.ai.navalPosition=w.site.waterPosition
        platoon.ai.placeToBuild=p;platoon.ai.buildApproachPosition=w.site.approach
        platoon.ai.buildedUnit=nil
        Event(w,"site", "local-reachable-water-area")
        if AF.SetReserveEco then
            AF.SetReserveEco(army.id,builder.id.index,id,p)
            w.reservation=army.ai.ecoReserve and army.ai.ecoReserve[builder.id.index]
            if w.reservation then
                w.callback=function() ClearReservation(w) end
                builder:AddCallback(w.callback,"OnDestroyed")
            end
        end
        success,reason=Travel(w)
        local target
        if success then
            ClearReservation(w)
            success,reason,target=Build(w)
        end
        if success then break end
        Event(w,"retry",reason,target)
        if reason=="build-order-rejected-or-ended" and not w.paidProgress then w.hostRejected=true end
        if Valid(w) and not w.foreignOrders then Reject(w,p) end
        Stop(w)
        -- An already paid structure must be preserved. Native repair/assist
        -- routines can recover it; this job must not spawn additional foundations.
        if target and Matches(w,target) and target:GetFractionComplete()>0 then break end
        if not Valid(w) or w.foreignOrders then break end
    end
    Stop(w)
    if platoon.ai==w.pai then
        w.pai.placeToBuild=nil;w.pai.buildApproachPosition=nil
        w.pai.waterGraphArea=nil;w.pai.navalPosition=nil;w.pai.buildedUnit=nil
    end
    if Valid(w) and not w.foreignOrders then w.uai.eState="Disband" end
    -- Native rejection is not permission to retry every spare engineer. Keep
    -- geometry/host validation authoritative, release this worker, and adapt
    -- with a bounded delay. Real paid progress clears the failure history.
    if success or w.paidProgress then state.failedJobs=0
    elseif w.hostRejected then state.failedJobs=math.min(3,(state.failedJobs or 0)+1) end
    local delay=success and 5 or math.min(MAX_COOLDOWN,COOLDOWN*2^(state.failedJobs or 0))
    state.retryAt=Now()+delay
    state.lastTime=Now()
    if success then state.cursor=1 else Event(w,"aborted",reason) end
    return success
end
