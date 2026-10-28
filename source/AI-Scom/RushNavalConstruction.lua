-- RC6: naval-only construction, with separate build and engineer approach positions.
-- Native water-area selection, placement checks, canBuild and host orders stay authoritative.
Version = "9.0.12-rc13"
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
local COOLDOWN, REJECT_TTL = 20, 180
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
local function Pos(p) return p and string.format("%.1f,%.1f",p.x,p.z) or "none" end
local function State(army,base)
    army.ai.rushNavalConstruction = army.ai.rushNavalConstruction or {}
    local s=army.ai.rushNavalConstruction[base]
    if not s then s={retryAt=0,rejected={},cursor=1};army.ai.rushNavalConstruction[base]=s end
    return s
end
function Ready(army,base)
    local s=army.ai.rushNavalConstruction and army.ai.rushNavalConstruction[base]
    return not s or Now()>=(s.retryAt or 0)
end
local function Valid(w)
    local valid=R.Own(w.army,w.builder) and w.builder.platoon==w.platoon
        and w.army.ai.isAlive~=false
    if valid then w.lastPosition=w.builder:GetPosition() end
    return valid
end
local function Event(w,event,reason,target)
    local u=w.builder
    local order=u and u.orders and u.orders.activeOrder
    local fraction=target and not target.dead and not target.deleted and target:GetFractionComplete() or 0
    local position=R.Own(w.army,u) and u:GetPosition() or w.lastPosition
    Log(string.format("[RushNaval] army=%s base=%s builder=%s/%s layer=%s event=%s reason=%s site=%s approach=%s position=%s order=%s target=%s fraction=%.4f",
        tostring(w.army.id),tostring(w.base),tostring(u and u.tpId),tostring(u and u.id.index),tostring(w.layer),event,reason or "none",
        Pos(w.site and w.site.position),Pos(w.site and w.site.approach),Pos(position),
        tostring(order and order.orderTask),tostring(target and target.id.index),fraction))
end
local function ClearReservation(w)
    local current=w.army.ai.ecoReserve and w.army.ai.ecoReserve[w.builder.id.index]
    -- A reassigned engineer may already have another job's reservation. Never
    -- remove that new owner's budget or its destruction callback.
    if w.reservation and (current==w.reservation or current==nil) then
        if w.hooks and w.hooks.clearReservation then w.hooks.clearReservation(w.builder) end
        if current==nil and w.hooks and w.hooks.reserveCallback then
            w.builder:RemoveCallback(w.hooks.reserveCallback,"OnDestroyed")
        end
    end
    w.reservation=nil
end
local function Stop(w)
    if R.Own(w.army,w.builder) and w.builder.platoon==w.platoon then
        Orders.HostClearOrder({w.builder})
    end
    ClearReservation(w)
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
        local q=SnapToGround({x=p.x+o[1],y=0,z=p.z+o[2]})
        if R.Inside(q,gap) and MG.IsPathable(q.x,q.z) then options[#options+1]=q end
    end
    local start=w.builder:GetPosition()
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
            local path=MG.GeneratePathTo(w.army.id,start,q,w.layer,true,1)
            WaitTicks(1)
            if not Valid(w) then return nil,"builder-unavailable" end
            if type(path)=="table" and #path>0 then
                return {position=p,approach=q,path=MG.StraightenPath(path)}
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
        -- The factory serves the water graph at its roll-off point, not at its shoreline centre.
        local graph,waterPosition=GraphAreaAtPosition(p,w.id)
        if not IsRejected(w,p) and (w.areas and w.areas[graph] or not w.areas and graph==w.graph) then
            w.placementChecks=w.placementChecks+1
            if w.placementChecks>128 then
                w.cursor=w.cursor-1;w.state.cursor=w.cursor
                return nil,"placement-search-budget"
            end
            p=SnapToGround(p)
            if R.PlacementContract(w.id,p) and AF.CanBuildStructureAt(w.army.id,w.id,p,0)
                and Expansion.Safe(w.army,p,"Water") and SiteClear(w,p) then
                local site,reason=Approach(w,p)
                if site and AF.CanBuildStructureAt(w.army.id,w.id,p,0)
                    and Expansion.Safe(w.army,p,"Water") and SiteClear(w,p) then
                    site.graph=graph;site.waterPosition=waterPosition;return site
                end
                if not site and reason~="no-reachable-approach" then
                    if reason=="path-search-budget" then w.cursor=w.cursor-1;w.state.cursor=w.cursor end
                    return nil,reason
                end
            end
        end
    end
    w.state.cursor=1
    return nil,"no-local-buildable-reachable-site"
end
local function Travel(w)
    local u=w.builder
    u.ai.eState="NavalApproach"
    local began=Now()
    local path=w.site.path
    -- The native path is ordered; pairs() must not reorder its waypoints.
    for _,q in ipairs(path) do
        if not Valid(w) then return false,"builder-unavailable" end
        if Dist(u:GetPosition(),q)>1.5 then
            Orders.HostIssueOrder(Tasks.MOVE,{u},false,q,nil)
            local best,last,issued=Dist(u:GetPosition(),q),Now(),Now()
            while Valid(w) and Dist(u:GetPosition(),q)>1.5 do
                WaitTicks(5)
                if not Valid(w) then return false,"builder-unavailable" end
                local d=Dist(u:GetPosition(),q)
                if d<best-1 then best,last=d,Now() end
                if Now()-last>=25 or Now()-began>=180 then return false,"approach-no-progress" end
                if d>1.5 and Now()-issued>=3 and not (u.orders and u.orders.activeOrder) then
                    return false,"approach-order-ended"
                end
            end
        end
    end
    return true
end
local function Matches(w,target)
    return R.Own(w.army,target) and target.tpId==w.id
        and Dist(target:GetPosition(),w.site.position)<2
end
local function Target(w)
    local u=w.builder
    local order=u.orders and u.orders.activeOrder
    for _,field in ipairs({"unitBeingBuilt","buildBehaviorActualUnit"}) do
        if Matches(w,u[field]) then return u[field] end
    end
    if order and Matches(w,order.unitGettingBuilt) then return order.unitGettingBuilt end
    -- A very short host build can finish between polls. Recover the exact own
    -- target at this site even after the host has cleared its order fields.
    for _,target in pairs(w.army.units or {}) do
        if Matches(w,target) then return target end
    end
end
local function ResourceWait(w)
    local totals=w.army.economy and w.army.economy.totals
    for _,key in ipairs({"energy","alloys"}) do
        local r=totals and totals[key]
        if r and type(r.current)=="number" and r.current<1 then return true end
    end
    return w.builder.GetPause and w.builder:GetPause()==true
end
local function Build(w)
    local u=w.builder
    if not R.CanBuilderBuild(u,w.id) then return false,"builder-cannot-build" end
    if w.capacity and not Balance.CapacityAffordable(u,w.id) then return false,"capacity-budget-changed" end
    if not AF.CanBuildStructureAt(w.army.id,w.id,w.site.position,0) or not SiteClear(w,w.site.position) then return false,"placement-changed" end
    if not Expansion.Safe(w.army,w.site.position,"Water") then return false,"site-threatened" end
    -- A single BUILD starts the host approach. Do not replace it merely because
    -- unitBeingBuilt is nil while the host creates/acknowledges its target.
    Orders.HostIssueOrder(Tasks.BUILD,{u},false,w.site.position,{tpId=w.id,armyId=w.army.id})
    local issued,lastProgress,bestDistance=Now(),Now(),math.huge
    local fraction,target,started,assists=0,Target(w),false,0
    u.ai.eState="NavalStarting"
    Event(w,"build-issued",nil,target)
    while Valid(w) do
        WaitTicks(5)
        if not Valid(w) then return false,"builder-unavailable" end
        local current=Target(w)
        if current then target=current end
        if target and not Matches(w,target) then return false,"target-lost",target end
        if target then
            w.platoon.ai.buildedUnit=target
            if target:IsCompleted() then Event(w,"completed",nil,target);return true end
            local f=target:GetFractionComplete()
            if f>fraction+0.000001 then fraction,lastProgress=f,Now() end
            if f>0 and not started then
                started=true;ClearReservation(w);u.ai.eState="Building";Event(w,"started",nil,target)
            end
        end
        local d=Dist(u:GetPosition(),w.site.position)
        if not started and d<bestDistance-1 then bestDistance,lastProgress=d,Now() end
        local order=u.orders and u.orders.activeOrder
        local active=order and (order.orderTask==Tasks.BUILD or order.orderTask==Tasks.ASSISTUNIT)
        local elapsed=Now()-issued
        -- Do not use the first synchronous activeOrder read as an acknowledgement.
        if elapsed>=3 and not active and not u.buildBehaviorIsActive then
            if target and fraction>0 and assists<2 then
                -- Reattach to the paid foundation, never create a duplicate BUILD.
                assists=assists+1
                Orders.HostIssueOrder(Tasks.ASSISTUNIT,{u},false,target:GetPosition(),{targetGlobalId=target.id})
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
        elseif Now()-lastProgress>=180 and not ResourceWait(w) then
            return false,"paid-foundation-no-progress",target
        end
    end
    return false,"builder-unavailable",target
end

-- Called after the standard selector has assigned a buildable native faction
-- template and idle engineers. ExitPlatoon remains the sole owner of disbanding.
function Run(platoon,request,hooks)
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
        if R.Own(army,u) and u:IsCompleted() and not R.Has(u.tp,"COMMAND")
            and R.Has(u.tp,"MOBILE") and R.Has(u.tp,"ENGINEER")
            and candidate and R.Has(__Templates.Units[candidate],"NAVAL_FACTORY")
            and R.AllowedTarget(candidate,false) and R.CanBuilderBuild(u,candidate) then builder,id=u,candidate;break end
    end
    local w={army=army,base=base,state=state,platoon=platoon,builder=builder,id=id,hooks=hooks,
        origin=platoon.ai.basePosition,placementChecks=0,pathChecks=0,
        capacity=platoon.ai.formerTable.RushNavalCapacity==true}
    -- This only backs off failed site/host attempts, never the opening policy.
    state.retryAt=Now()+COOLDOWN
    if not builder then Event(w,"aborted","no-legal-noncommander-engineer");return false end
    w.lastPosition=builder:GetPosition()
    -- Never keep extra idle constructors assigned to a one-engineer naval job.
    for _,u in ipairs(units) do
        if u~=builder then platoon:RemoveUnits({u}) end
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
        if not nativePosition or not graph then Event(w,"aborted","native-no-naval-site");return false end
        graphKey=tostring(graph)
    end
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
        w.site,reason=SelectSite(w)
        if not w.site then break end
        local p=w.site.position
        w.graph=w.site.graph
        platoon.ai.waterGraphArea=w.graph;platoon.ai.navalPosition=w.site.waterPosition
        platoon.ai.placeToBuild=p;platoon.ai.buildApproachPosition=w.site.approach
        platoon.ai.buildedUnit=nil
        Event(w,"site", "local-reachable-water-area")
        if AF.SetReserveEco and hooks and hooks.reserveCallback then
            AF.SetReserveEco(army.id,builder.id.index,id,p)
            w.reservation=army.ai.ecoReserve and army.ai.ecoReserve[builder.id.index]
            builder:AddCallback(hooks.reserveCallback,"OnDestroyed")
        end
        success,reason=Travel(w)
        local target
        if success then
            ClearReservation(w)
            success,reason,target=Build(w)
        end
        if success then break end
        Event(w,"retry",reason,target)
        Reject(w,p);Stop(w)
        -- An already paid structure must be preserved. Native repair/assist
        -- routines can recover it; this job must not spawn additional foundations.
        if target and Matches(w,target) and target:GetFractionComplete()>0 then break end
        if not Valid(w) then break end
    end
    Stop(w)
    platoon.ai.placeToBuild=nil;platoon.ai.buildApproachPosition=nil
    platoon.ai.waterGraphArea=nil;platoon.ai.navalPosition=nil;platoon.ai.buildedUnit=nil
    if builder.platoon==platoon then builder.ai.eState="Disband" end
    state.retryAt=Now()+(success and 5 or COOLDOWN)
    if success then state.cursor=1 else Event(w,"aborted",reason) end
    return success
end
