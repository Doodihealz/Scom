-- RC18: owned movement snapshots and bounded, individual route resumption.
-- Native clamping/position accessors may return reused tables. Never retain one
-- across another native call, a coroutine yield, or a later simulation update.
Version="9.0.17-rc18"
local AF=Import("AI/AIFunctions.lua")
local MG=Import("AI/AIMarkerGenerator.lua")
local TM=Import("AI/AITargetManager.lua")
local Layers=Import("common/layers.lua")
local Budget=Import("AI/mods/AI-Scom/RushPathBudget.lua")
local Orders=Import("host/managers/orders/hostOrderManager.lua")
local Tasks=Import("common/commonOrders.lua").OrderTasks
function Copy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function Valid(p)
    return type(p)=="table" and type(p.x)=="number" and type(p.z)=="number"
        and p.x==p.x and p.z==p.z and math.abs(p.x)<math.huge and math.abs(p.z)<math.huge
        and (p.y==nil or type(p.y)=="number" and p.y==p.y and math.abs(p.y)<math.huge)
end
function Clamp(p) return Copy(AF.GetPositionWithinPlayableArea(p)) end
function CopyPath(path)
    local result={}
    if type(path)~="table" then return result end
    for _,node in ipairs(path) do
        if not Valid(node) then return {} end
        result[#result+1]=Copy(node)
    end
    return result
end
-- Keep only three accepted native waypoints per unit. The remaining immutable
-- route is shared by its platoon; refilling never runs pathfinding or sensing.
local QUEUE_LIMIT=3
local function Live(p,owner,pai,armyAI,operation,fleet)
    return owner and owner.ai==armyAI and armyAI and armyAI.isAlive~=false
        and p and not p.dead and not p.deleted and p.army==owner and p.ai==pai
        and owner:PlatoonExists(p) and pai.rushOperation==operation and pai.rushFleet==fleet
end
local function UnitCurrent(u,p,owner,ai,pai,armyAI,operation,fleet)
    return Live(p,owner,pai,armyAI,operation,fleet) and u and u.id
        and owner.units and owner.units[u.id.index]==u and not u.dead and not u.deleted
        and u.army==owner and u.platoon==p and u.ai==ai and ai
        and ai.eState~="RepairHome" and not u.CaptureInProgress and not u.ReclaimInProgress
end
local function OrderSet(u)
    local result={};local orders=u.orders or {}
    if orders.activeOrder then result[orders.activeOrder]=true end
    for _,order in ipairs(orders.queuedOrders or {}) do result[order]=true end
    return result
end
local function OnlyOrders(u,known)
    local orders=u.orders or {}
    if orders.activeOrder and not known[orders.activeOrder] then return false end
    for _,order in ipairs(orders.queuedOrders or {}) do if not known[order] then return false end end
    return true
end
local function Suspend(u)
    local p=u.platoon;local ai=u.ai
    ai.rushMoveSuspended={owner=u.army,armyAI=u.army.ai,platoon=p,pai=p and p.ai}
end
function Suspended(u)
    local ai=u and u.ai;local s=ai and ai.rushMoveSuspended
    local micro=ai and ai.rushFleetMicroOrders
    if micro then
        if not micro.fleet or not UnitCurrent(u,micro.platoon,micro.owner,micro.ai,micro.pai,
            micro.armyAI,micro.operation,micro.fleet) then ai.rushFleetMicroOrders=nil
        elseif not OnlyOrders(u,micro.orders or {}) and (not s or s.owner~=micro.owner
            or s.armyAI~=micro.armyAI or s.platoon~=micro.platoon or s.pai~=micro.pai) then
            Suspend(u);s=ai.rushMoveSuspended
        end
    end
    local r=ai and ai.rushMoveQueue
    if not s and r and r.ai==ai and u.army==r.owner and not u.dead and not u.deleted
        and not OnlyOrders(u,r.orders) then Suspend(u);s=ai.rushMoveSuspended end
    if not s then return false end
    local p=u.platoon;local orders=u.orders or {}
    if u.army==s.owner and s.owner.ai==s.armyAI and p==s.platoon and p and p.ai==s.pai
        and not u.dead and not u.deleted and (orders.activeOrder or next(orders.queuedOrders or {})) then return true end
    ai.rushMoveSuspended=nil
    return false
end
function Capture(p,units)
    if not p or not p.ai or not p.army then return nil end
    local owner,pai=p.army,p.ai
    local r={platoon=p,owner=owner,armyAI=owner.ai,pai=pai,operation=pai.rushOperation,fleet=pai.rushFleet,layer=pai.movementLayer,units={}}
    if not Live(p,owner,pai,r.armyAI,r.operation,r.fleet) then return nil end
    for _,u in ipairs(units or p:GetUnits()) do
        if UnitCurrent(u,p,owner,u.ai,pai,r.armyAI,r.operation,r.fleet) and not Suspended(u)
            and not (u.toggles and u.toggles.Pause) then
            r.units[#r.units+1]={unit=u,ai=u.ai,orders=OrderSet(u)}
        end
    end
    return r
end
local function RequestCurrent(r)
    return r and Live(r.platoon,r.owner,r.pai,r.armyAI,r.operation,r.fleet) and r.pai.movementLayer==r.layer
end
-- A graph connection is not a straight corridor. Shortcuts require the native
-- blocker ray on every participating navigation layer, footprint edge clearance,
-- and known heat no worse than the replaced route. Missing evidence keeps A*.
local function Finite(v) return type(v)=="number" and v==v and math.abs(v)<math.huge end
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local ThreatLayers={Land=true,Air=true,Water=true,Hover=true,Seabed=true}
local LayerPriority={Land=1,Water=2,Seabed=3,Hover=4,Air=5}
local TypeLayer={Plane="Air",Gunship="Air",LegsLand="Land",TracksLand="Land",Hover="Hover",
    LegsSeabed="Seabed",TracksSeabed="Seabed",TracksAmphibious="Hover",LegsAmphibious="Hover",
    UnderWater="Water",TracksWater="Water",WaterSurface="Water",Ship="Water",Submarine="Water"}
local function NavigationLayer(tp,index)
    local typed=TypeLayer[tp.movement and tp.movement.type]
    -- Landed aircraft switch back to Air when their move takes off.
    if typed=="Air" then return "Air" end
    local native=Layers.NavigationLayers or {}
    if index~=nil then
        if index==native.Land then return "Land"
        elseif index==native.Sea or index==native.Submarine then return "Water"
        elseif index==native.Amphibious then
            -- Native Amphibious contains both seabed walkers and surface
            -- amphibians. Only explicit surface types use the Hover graph,
            -- which includes deep water; the Seabed graph excludes abyss.
            return typed=="Hover" and "Hover" or "Seabed"
        elseif index==native.Hover then return "Hover"
        elseif index==native.Air then return "Air" end
    end
    return typed
end
function TemplateMovementLayer(tp)
    tp=tp or {}
    return NavigationLayer(tp,tp.general and tp.general.navigationLayer)
end
function UnitMovementLayer(u)
    if not u or u.dead or u.deleted then return nil end
    local tp=u.tp or {};local index=tp.general and tp.general.navigationLayer
    if TypeLayer[tp.movement and tp.movement.type]~="Air" and Engine and EngineErrorCode
        and type(Engine.GetMovementNavigationLayer)=="function" and u.id then
        local ok,code,current=pcall(Engine.GetMovementNavigationLayer,u.id)
        if ok and code==EngineErrorCode.Success then index=current end
    end
    -- Live Sea/Land morphs remain restrictive even for an amphibious template.
    -- Shortcut checks separately retain the exact native index and footprint.
    return NavigationLayer(tp,index)
end
function MovementLayer(p)
    local selected,unknown,land,water=nil,false,false,false
    local existing=p and p.ai and p.ai.movementLayer
    for _,u in ipairs(p and p:GetUnits() or {}) do
        if not u.dead and not u.deleted and u.platoon==p and u.army==p.army then
            local layer=UnitMovementLayer(u)
            if layer then
                land=land or layer=="Land";water=water or layer=="Water"
                if not selected or LayerPriority[layer]<LayerPriority[selected] then selected=layer end
            else unknown=true end
        end
    end
    if unknown or not selected then
        local fallback=LayerPriority[existing] and existing or "Land"
        if not selected or LayerPriority[fallback]<LayerPriority[selected] then selected=fallback end
    end
    return selected,not unknown and not (land and water)
end
local function RouteContext(p,layer,maximum,request)
    local r=request or Capture(p)
    if not RequestCurrent(r) or r.platoon~=p or not Finite(maximum) or maximum<0
        or not ThreatLayers[layer] or not Engine or type(Engine.NavmapLineCast)~="function"
        or type(Engine.GetMovementNavigationLayer)~="function" or not EngineErrorCode or not NavmapLineCastResult
        or type(TM.GetHeatMapGridSizeXZ)~="function" or type(TM.GetThreatFromHeatMapGrid)~="function"
        or type(TM.GetHeatMapGridIndexFromWorldPosition)~="function"
        or type(TM.GetWorldPositionFromHeatMapGridIndexFast)~="function" then return nil end
    local ok,sx,sz=pcall(TM.GetHeatMapGridSizeXZ)
    local centerOK,center=pcall(TM.GetWorldPositionFromHeatMapGridIndexFast,0,0)
    if not ok or not Finite(sx) or not Finite(sz) or sx<=0 or sz<=0 or not centerOK or not Valid(center) then return nil end
    local profiles={}
    for _,entry in ipairs(r.units) do
        local u=entry.unit
        if UnitCurrent(u,p,r.owner,entry.ai,r.pai,r.armyAI,r.operation,r.fleet) then
            local ok,code,index=pcall(Engine.GetMovementNavigationLayer,u.id)
            if not ok or code~=EngineErrorCode.Success or not Finite(index)
                or index==Layers.NavigationLayer.Invalid then return nil end
            local tp=u.tp or {};local f=tp.footprint or {};local b=tp.collisionInfo and tp.collisionInfo.collisionSize or {}
            local radius=0
            for _,v in ipairs({f.x or 0,f.y or 0,b.x or 0,b.z or 0}) do
                if not Finite(v) or v<0 then return nil end
                radius=math.max(radius,v*0.5)
            end
            if radius<=0 then return nil end
            profiles[index]=math.max(profiles[index] or 0,radius+0.25)
        end
    end
    if not next(profiles) then return nil end
    return {request=r,army=r.owner,layer=layer,maximum=maximum,profiles=profiles,
        waterHeat=r.pai.rushAmphibiousNaval==true and layer~="Water",
        sizeX=sx,sizeZ=sz,originX=center.x-sx*0.5,originZ=center.z-sz*0.5,casts=0,samples=0,attempts=0,checks=0}
end
local function ClearCorridor(c,a,b)
    local distance=math.sqrt(D2(a,b))
    if not Finite(distance) then return false end
    local dx,dz=0,0
    if distance>0 then dx,dz=-(b.z-a.z)/distance,(b.x-a.x)/distance end
    for index,radius in pairs(c.profiles) do
        for _,offset in ipairs({0,-radius,radius}) do
            if c.casts>=48 then return false end
            c.casts=c.casts+1
            local ok,code,result=pcall(Engine.NavmapLineCast,
                {x=a.x+dx*offset,y=a.z+dz*offset},{x=b.x+dx*offset,y=b.z+dz*offset},index)
            if not ok or code~=EngineErrorCode.Success or result~=NavmapLineCastResult.NoHit then return false end
        end
    end
    return true
end
local function MeasureHeat(c,a,b,limited)
    local distance=math.sqrt(D2(a,b))
    if not Finite(distance) then return nil end
    local ok,x,z=pcall(TM.GetHeatMapGridIndexFromWorldPosition,a)
    local endOK,endX,endZ=pcall(TM.GetHeatMapGridIndexFromWorldPosition,b)
    if not ok or not endOK or not Finite(x) or not Finite(z) or not Finite(endX) or not Finite(endZ) then return nil end
    if math.abs(endX-x)+math.abs(endZ-z)+2>256-c.samples then c.heatFailure="heat-budget";return nil end
    local function heatAt(gx,gz)
        if c.samples>=256 then c.heatFailure="heat-budget";return nil end
        c.samples=c.samples+1
        local grid={gx,gz}
        local valid,heat=pcall(TM.GetThreatFromHeatMapGrid,c.army.id,grid,c.layer)
        if not valid or not Finite(heat) or heat<0 then return nil end
        if c.waterHeat then
            -- Hover heat omits torpedoes; walking ships remain vulnerable
            -- during their water legs. Reuse the same bounded cell traversal.
            local waterOK,water=pcall(TM.GetThreatFromHeatMapGrid,c.army.id,grid,"Water")
            if not waterOK or not Finite(water) or water<0 then return nil end
            heat=math.max(heat,water)
        end
        if limited and heat>c.maximum then c.heatFailure="unsafe-threat";return nil end
        return heat
    end
    local dx,dz=b.x-a.x,b.z-a.z
    local stepX=dx>0 and 1 or dx<0 and -1 or 0
    local stepZ=dz>0 and 1 or dz<0 and -1 or 0
    local deltaX=stepX~=0 and c.sizeX/math.abs(dx) or math.huge
    local deltaZ=stepZ~=0 and c.sizeZ/math.abs(dz) or math.huge
    local tx=stepX~=0 and (c.originX+(x+(stepX>0 and 1 or 0))*c.sizeX-a.x)/dx or math.huge
    local tz=stepZ~=0 and (c.originZ+(z+(stepZ>0 and 1 or 0))*c.sizeZ-a.z)/dz or math.huge
    local t,peak,exposure=0,0,0
    -- Native heat is constant inside each grid cell. Visit every crossed cell,
    -- including thin corner crossings, instead of skipping between samples.
    while true do
        local heat=heatAt(x,z)
        if not heat then return nil end
        local nextT=math.min(1,tx,tz)
        if nextT<t-1e-7 then return nil end
        nextT=math.max(t,nextT)
        peak=math.max(peak,heat);exposure=exposure+heat*(nextT-t)*distance
        if nextT>=1 then
            if x~=endX or z~=endZ then
                local finish=heatAt(endX,endZ)
                if not finish then return nil end
                peak=math.max(peak,finish)
            end
            return peak,exposure
        end
        local crossX,crossZ=tx<=tz,tz<=tx
        if crossX then x=x+stepX;tx=tx+deltaX end
        if crossZ then z=z+stepZ;tz=tz+deltaZ end
        t=nextT
    end
end
-- Validate native heat along a complete accepted route without claiming it is
-- a straight physical corridor. Native orders still use each unit's real layer.
function PathThreatSafe(p,start,path,layer,maximum,request)
    if not Valid(start) then return false,"invalid-path" end
    path=CopyPath(path)
    if #path==0 then return false,"invalid-path" end
    local c=RouteContext(p,layer,maximum,request)
    if not c then return false,"invalid-context" end
    local previous=Copy(start)
    for _,node in ipairs(path) do
        if not MeasureHeat(c,previous,node,true) then return false,c.heatFailure or "invalid-heat" end
        previous=node
    end
    if not RequestCurrent(c.request) then return false,"stale-request" end
    return true
end
local function SafeChord(c,a,b,path,first,last)
    if c.attempts>=12 then return false end
    c.attempts=c.attempts+1
    if not ClearCorridor(c,a,b) then return false end
    local peak,exposure=MeasureHeat(c,a,b,true)
    if not peak then return false end
    if peak==0 then return RequestCurrent(c.request) end
    local oldPeak,oldExposure,previous=0,0,a
    for i=first,last do
        local h,e=MeasureHeat(c,previous,path[i],false)
        if not h then return false end
        oldPeak=math.max(oldPeak,h);oldExposure=oldExposure+e;previous=path[i]
    end
    return peak<=oldPeak and exposure<=oldExposure and RequestCurrent(c.request)
end
function ShortenPath(p,start,path,layer,maximum,request)
    path=CopyPath(path)
    if #path<2 or not Valid(start) then return path end
    start=Copy(start)
    local c=RouteContext(p,layer,maximum,request)
    if not c then return path end
    local lengths,total,last={},0,start
    for i,node in ipairs(path) do total=total+math.sqrt(D2(last,node));lengths[i]=total;last=node end
    local result,first,previous={},1,start
    while first<=#path do
        local chosen=first
        if c.checks<12 then
            -- Try the destination first, then progressively shorter skips. A
            -- failed or over-budget shortcut leaves every native leg intact.
            local candidate=#path
            while candidate>first and c.checks<12 do
                c.checks=c.checks+1
                if lengths[candidate]-(lengths[first-1] or 0)>math.sqrt(D2(previous,path[candidate]))+0.5
                    and SafeChord(c,previous,path[candidate],path,first,candidate) then chosen=candidate;break end
                candidate=first+math.floor((candidate-first)/2)
            end
        end
        result[#result+1]=path[chosen];previous=path[chosen];first=chosen+1
        if c.checks>=12 then
            for i=first,#path do result[#result+1]=path[i] end
            break
        end
    end
    return RequestCurrent(c.request) and result or path
end
function Suffix(position,path,p,layer,maximum,request)
    if not Valid(position) then return nil end
    path=CopyPath(path)
    if #path==0 then return nil end
    local c=RouteContext(p,layer,maximum,request)
    if not c then return nil end
    local candidates={}
    local function add(index,distance)
        local found=false
        for _,v in ipairs(candidates) do
            if v.index==index then v.distance=math.min(v.distance,distance);found=true;break end
        end
        if not found then candidates[#candidates+1]={index=index,distance=distance} end
        table.sort(candidates,function(a,b) return a.distance==b.distance and a.index>b.index or a.distance<b.distance end)
        if #candidates>8 then table.remove(candidates) end
    end
    add(1,D2(position,path[1]))
    for i=2,#path do
        local a,b=path[i-1],path[i];local dx,dz=b.x-a.x,b.z-a.z
        local length=dx*dx+dz*dz
        local t=length>0 and math.max(0,math.min(1,((position.x-a.x)*dx+(position.z-a.z)*dz)/length)) or 1
        local projection={x=a.x+dx*t,z=a.z+dz*t}
        add(t>0 and i or i-1,D2(position,projection))
    end
    for _,candidate in ipairs(candidates) do
        local first=candidate.index
        if SafeChord(c,position,path[first],path,math.max(1,first-1),first) then
            local result={}
            for i=first,#path do result[#result+1]=path[i] end
            return result
        end
    end
end
local function RecordCurrent(u,r)
    return UnitCurrent(u,r.platoon,r.owner,r.ai,r.pai,r.armyAI,r.operation,r.fleet)
        and r.ai.rushMoveQueue==r and r.ai.path==r.path and r.pai.path==r.source and r.pai.movementLayer==r.layer
end
local function Prune(u,r)
    local active=(u.orders or {}).activeOrder;local queued=(u.orders or {}).queuedOrders or {}
    local count=0
    for order in pairs(r.orders) do
        local found=order==active
        if not found then for _,q in ipairs(queued) do if q==order then found=true;break end end end
        if found then count=count+1 else r.orders[order]=nil end
    end
    return count
end
-- Never clear a replacement order or another assignment's route. A queued
-- tail can be withdrawn exactly without interrupting an accepted active order.
function Forget(u,removeTail)
    local ai=u and u.ai;local r=ai and ai.rushMoveQueue
    if not r then return end
    if removeTail and u and u.id and u.ai==r.ai and u.army==r.owner
        and r.owner.units and r.owner.units[u.id.index]==u and not u.dead and not u.deleted
        and type(Orders.RemoveUnitFromQueuedOrder)=="function" then
        local queued=(u.orders or {}).queuedOrders or {}
        for i=#queued,1,-1 do
            if r.orders[queued[i]] then Orders.RemoveUnitFromQueuedOrder(u,queued[i]) end
        end
    end
    if ai.rushMoveQueue==r then ai.rushMoveQueue=nil end
end
local function Accepted(u,before,task,pos)
    local orders=u.orders or {}
    local function match(order)
        local q=order and order.positionFloat3
        return order and not before[order] and order.orderTask==task and Valid(q)
            and (q.x-pos.x)^2+(q.z-pos.z)^2<1
    end
    if match(orders.activeOrder) then return orders.activeOrder end
    for _,order in ipairs(orders.queuedOrders or {}) do if match(order) then return order end end
end
function Begin(p,path,goal,task,request)
    local r=request or Capture(p)
    if not RequestCurrent(r) or r.platoon~=p then return false,"stale-request" end
    if not Valid(goal) then return false,"invalid-path" end
    path=CopyPath(path)
    if #path==0 then return false,"invalid-path" end
    local entries,units={},{}
    for _,entry in ipairs(r.units) do
        local u=entry.unit
        if UnitCurrent(u,p,r.owner,entry.ai,r.pai,r.armyAI,r.operation,r.fleet) and not Suspended(u)
            and not (u.toggles and u.toggles.Pause) and OnlyOrders(u,entry.orders) then
            local queue={platoon=p,owner=r.owner,armyAI=r.armyAI,pai=r.pai,operation=r.operation,fleet=r.fleet,
                ai=entry.ai,path=path,source=r.pai.path,layer=r.layer,goal=Copy(goal),task=task,nextIndex=1,orders={}}
            entries[#entries+1]={unit=u,queue=queue,before=entry.orders};units[#units+1]=u
        end
    end
    if #units==0 then return false,"stale-request" end
    local accepted=false
    for index=1,math.min(QUEUE_LIMIT,#path) do
        if #units==0 then break end
        Orders.HostIssueOrder(task,units,index>1,path[index],nil)
        local nextUnits,nextEntries={},{}
        for _,entry in ipairs(entries) do
            local u,q=entry.unit,entry.queue
            local current=RequestCurrent(r) and UnitCurrent(u,p,r.owner,q.ai,r.pai,r.armyAI,r.operation,r.fleet)
            local order=current and Accepted(u,entry.before,task,path[index])
            if order then
                q.orders[order]=true;q.nextIndex=index+1
                q.ai.rushFleetMicroOrders=nil
                q.ai.rushMoveQueue=q;q.ai.rushMoveSuspended=nil;q.ai.path=path;q.ai.moveToDestinationReached=false
                q.ai.lastProgressPosition=Copy(u:GetPosition());q.ai.progressCheckTicks=0;q.ai.stuckCount=0
                q.ai.rushMoveProgressAt=GetGameTimeSeconds()
                q.ai.rushOrderlessSince=nil
                accepted=true
                if OnlyOrders(u,q.orders) then
                    entry.before=q.orders;nextUnits[#nextUnits+1]=u;nextEntries[#nextEntries+1]=entry
                else Suspend(u);Forget(u,true) end
            end
        end
        units,entries=nextUnits,nextEntries
    end
    return accepted,not accepted and "order-rejected" or nil
end
function MaintainUnit(u)
    local r=u and u.ai and u.ai.rushMoveQueue
    if not r then return false end
    if not RecordCurrent(u,r) then
        if u.ai==r.ai and u.army==r.owner and not OnlyOrders(u,r.orders) then Suspend(u) end
        Forget(u,true);return false
    end
    if u.toggles and u.toggles.Pause then return false end
    if not OnlyOrders(u,r.orders) then Suspend(u);Forget(u,true);return false end
    local count=Prune(u,r)
    local now=GetGameTimeSeconds()
    if now<(r.retryAt or 0) then return count>0 end
    while count<QUEUE_LIMIT and r.nextIndex<=#r.path do
        local pos=r.path[r.nextIndex]
        Orders.HostIssueOrder(r.task,{u},true,pos,nil)
        if not RecordCurrent(u,r) then return false end
        local order=Accepted(u,r.orders,r.task,pos)
        if not order then r.retryAt=now+0.5;break end
        r.orders[order]=true;r.nextIndex=r.nextIndex+1;count=count+1
    end
    if count==0 and r.nextIndex>#r.path then Forget(u,false) end
    return count>0
end
function Maintain(p)
    if not p or not p.ai then return end
    for _,u in ipairs(p:GetUnits()) do
        if u.platoon==p and u.ai and u.ai.rushMoveQueue then MaintainUnit(u) end
    end
end
function Resume(u,p,goal,admitted)
    if Suspended(u) then return false,"foreign-orders" end
    local request=Capture(p,{u})
    if not request or #request.units==0 then return false,"stale-request" end
    if not Valid(goal) then return false,"invalid-path" end
    if not admitted and not Budget.Recovery(u) then return false,"path-budget" end
    local pos=Copy(u:GetPosition())
    local queue=u.ai.rushMoveQueue
    local source=queue and RecordCurrent(u,queue) and queue.path or p.ai.path
    local path=Suffix(pos,source,p,p.ai.movementLayer,p.ai.rushMovementThreat or 0,request)
    if not RequestCurrent(request) or not UnitCurrent(u,p,request.owner,request.units[1].ai,
        request.pai,request.armyAI,request.operation,request.fleet) then return false,"stale-request" end
    if not path or #path==0 then return false,"route-unavailable" end
    local straight=MG.StraightenPath(path)
    if not RequestCurrent(request) then return false,"stale-request" end
    if request.pai.rushAmphibiousNaval then
        local safe,reason=PathThreatSafe(p,pos,straight,p.ai.movementLayer,p.ai.rushMovementThreat or 0,request)
        if not safe then return false,reason end
    end
    local data=p.ai.formerTable and p.ai.formerTable.AIPlanData
    local task=p.ai.pathUsesAggressiveMove and data and data.AggressiveMove and Tasks.ATTACKMOVE or Tasks.MOVE
    return Begin(p,straight,goal,task,request)
end
function RecoverOrderless(u,p,goal)
    if not u or not u.ai or not u.army or not p or not p.ai
        or not UnitCurrent(u,p,u.army,u.ai,p.ai,u.army.ai,p.ai.rushOperation,p.ai.rushFleet) then return false end
    local ai=u.ai;local orders=u.orders
    if Suspended(u) then return false end
    local now=GetGameTimeSeconds()
    if not orders or orders.activeOrder or next(orders.queuedOrders or {})
        or not Valid(goal) or u.toggles and u.toggles.Pause then
        MaintainUnit(u);ai.rushOrderlessSince=nil;return false
    end
    if MaintainUnit(u) then return true end
    local pos=u:GetPosition()
    if (pos.x-goal.x)^2+(pos.z-goal.z)^2<=900 then ai.rushOrderlessSince=nil;return false end
    if now<(ai.rushResumeAfter or 0) or not Budget.Recovery(u) then return false end
    ai.rushResumeAfter=now+1 -- retry admission is bounded; a normal empty queue need not idle first
    return Resume(u,p,goal,true)
end
