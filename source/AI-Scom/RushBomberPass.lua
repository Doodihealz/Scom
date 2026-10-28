-- RC21: one committed bomber run, then an outward leg and a wide return turn.
-- All movement/fire remains native. We observe own reload/salvo state, never
-- edit weapons or infer this bomber's release from somebody else's damage.
Version = "9.0.20-rc21"
local Tasks = Import("common/commonOrders.lua").OrderTasks
local Log = Import("AI/debugUtilities.lua").AILog
local function Finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function Valid(p) return p and Finite(p.x) and Finite(p.z) end
local function Copy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local function Bound(n,lo,hi) return math.max(lo,math.min(hi,n)) end
local function Has(u,tag)
    local tp=u.tp or {}
    if tp.hasTags and tp.hasTags[tag] then return true end
    for _,v in ipairs(tp.tags or {}) do if v==tag then return true end end
    return false
end
local function Weapon(w,target)
    local t=w.tp or w
    return w.enabled~=false and not w.isDeathExplosion and t.rangeRingType~="AntiAir"
        and w.rangeRingType~="AntiAir" and (t.damage or w.damage or 0)>0
        and type(w.CanShootAt)=="function" and w:CanShootAt(target)
end
function Eligible(u,target)
    if not Has(u,"AIR") or not Has(u,"MOBILE") or not Has(u,"BOMBER")
        or Has(u,"GUNSHIP") or Has(u,"TRANSPORT") or Has(u,"TORPEDO_BOMBER")
        or Has(u,"ANTI_NAVAL") or Has(u,"ANTI_NAVY") or Has(u,"SCFA_ANTINAVY")
        or (Has(target,"AIR") and Has(target,"MOBILE")) then return false end
    for _,w in pairs(u.weapons or {}) do if Weapon(w,target) then return true end end
    return false
end
local function Speed(u)
    local v=u.tp and u.tp.movement and u.tp.movement.speed
    return Finite(v) and math.max(1,v) or 16
end
local function Direction(a,b,u)
    local x,z=b.x-a.x,b.z-a.z;local d=math.sqrt(x*x+z*z)
    if d>0.01 then return x/d,z/d end
    local angle=(u.id.index%8)*math.pi/4
    return math.cos(angle),math.sin(angle)
end
-- Swept arrival also works when a fast aircraft crosses a waypoint between AI
-- updates. Merely waiting a fixed time never authorizes an early return attack.
local function Swept(a,b,p,r)
    if D2(b,p)<=r*r then return true end
    local x,z=b.x-a.x,b.z-a.z;local n=x*x+z*z
    if n<0.01 then return false end
    local t=Bound(((p.x-a.x)*x+(p.z-a.z)*z)/n,0,1)
    return (a.x+t*x-p.x)^2+(a.z+t*z-p.z)^2<=r*r
end
local function Trace(p,u,s,phase,reason,now)
    s.phase=phase
    local debug=(lobbyOptionsAI and lobbyOptionsAI.debugGameTelemetry)
        or (p.ai.formerTable and p.ai.formerTable.DebugPlatoon)
    if not debug or now<(p.ai.rushBomberPassLogAfter or 0) then return end
    p.ai.rushBomberPassLogAfter=now+10
    local pos=u:GetPosition()
    Log("[RushBomberPass] version="..Version.." army="..p.army.id.." platoon="..p.id
        .." unit="..u.id.index.." phase="..phase.." reason="..reason
        .." targetId="..tostring(s.target and s.target.id and s.target.id.index)
        .." position="..string.format("%.1f,%.1f",pos.x,pos.z),true)
end
local function New(p,u,r,target,aim,now,origin)
    local pos=Copy(u:GetPosition());local speed=Speed(u)
    local dx,dz=Direction(origin or pos,aim,u)
    local s={phase="Attack",target=target,requested=target,aim=Copy(aim),dx=dx,dz=dz,
        speed=speed,runIn=Bound(speed*2,36,90),extension=Bound(speed*4,64,180),
        width=Bound(speed*2,32,90),lastPos=pos,started=now,samples={},weapons={}}
    for _,w in pairs(u.weapons or {}) do
        if Weapon(w,target) then
            local t=w.tp or w
            local range=t.rangeMax or w.rangeMax or 0
            if Finite(range) then s.range=math.max(s.range or 0,range) end
            s.weapons[#s.weapons+1]=w
            s.samples[w]={reload=w.reloadTimer,salvos=w.salvosRemaining}
        end
    end
    r.bomberPass=s
    Trace(p,u,s,"Attack","run-in",now)
    return s
end
local function Issue(p,u,r,api,task,append,pos,payload,now)
    if not Valid(pos) or not api.Current(p,u,r) then return false end
    local order=api.Issue(p,u,r,task,append,pos,payload)
    if not order then return false end
    r.issuedAt=now
    if task==Tasks.ATTACKUNIT then r.bomberAttacksIssued=(r.bomberAttacksIssued or 0)+1 end
    return order
end
local function EscapeTail(p,u,r,s,api,now)
    local first=api.Clamp({x=s.aim.x+s.dx*s.extension,y=s.lastPos.y,z=s.aim.z+s.dz*s.extension})
    local second=api.Clamp({x=s.aim.x+s.dx*s.extension*1.5,y=s.lastPos.y,z=s.aim.z+s.dz*s.extension*1.5})
    if not first or not second or D2(s.aim,first)<64 or D2(first,second)<64 then
        first,second=api.FlightPoints(p,u,s.aim)
    end
    if first and second then
        local firstOrder=Issue(p,u,r,api,Tasks.MOVE,true,first,nil,now)
        if firstOrder then
            local secondOrder=Issue(p,u,r,api,Tasks.MOVE,true,second,nil,now)
            r.flightFirst,r.flightLast=first,secondOrder and second or first
            r.flightFirstOrder,r.flightLastOrder=firstOrder,secondOrder or firstOrder
        end
    end
end
-- Called only after a real native route/attack has been issued. It does not
-- cancel the route, including the last dogleg used to choose the attack axis.
function Track(p,u,r,target,now,api,nodes)
    if not Eligible(u,target) then r.bomberPass=nil;return false end
    local aim=Copy(target:GetPosition());if not Valid(aim) then return false end
    local origin=nodes and #nodes>2 and nodes[#nodes-1] or nil
    local s=New(p,u,r,target,aim,now,origin)
    r.target=target;r.bomberPassRouteDenied=nil
    EscapeTail(p,u,r,s,api,now)
    return true
end
function Maneuvering(r)
    local s=r.bomberPass
    return s and (s.phase=="Exit" or s.phase=="Turn") or false
end
local function RouteIndex(u,s)
    local o=u.orders and u.orders.activeOrder
    return o and s.routeOrders and s.routeOrders[o] or nil
end
local function QueueRoute(p,u,r,s,api,now)
    s.routeOrders={}
    for i=s.leg,#s.route do
        local order=Issue(p,u,r,api,Tasks.MOVE,i>s.leg,s.route[i],nil,now)
        if not order then return false end
        s.routeOrders[order]=i
        if i==#s.route-1 then r.flightFirstOrder=order end
        if i==#s.route then r.flightLastOrder=order end
    end
    r.target=nil;r.flightFirst=s.route[#s.route-1];r.flightLast=s.route[#s.route]
    s.recoverAfter=now+6
    return true
end
-- A lobe lives beyond the target, not around it. Its first point is straight
-- through the attack axis; the two return points supply turning room. At a
-- cropped edge, reject collapsed lobes and try bounded alternate headings.
local function MakeRoute(p,u,s,pos,api)
    local handed=u.id.index%2==0 and 1 or -1
    for _,scale in ipairs({1,0.65}) do
        for _,angle in ipairs({0,math.pi/3,-math.pi/3,math.pi/2,-math.pi/2,math.pi}) do
            local dx=s.dx*math.cos(angle)-s.dz*math.sin(angle)
            local dz=s.dx*math.sin(angle)+s.dz*math.cos(angle)
            local length,width=s.extension*scale,s.width*scale
            local best,bestCost
            for _,sign in ipairs({handed,-handed}) do
                local nx,nz=-dz*sign,dx*sign
                local raw={{length,0},{length+width*0.35,width},{length*0.65,width},{length*0.45,width*0.85}}
                local route={};local previous=pos;local ok=true
                for _,v in ipairs(raw) do
                    local q=api.Clamp({x=s.aim.x+dx*v[1]+nx*v[2],y=pos.y,z=s.aim.z+dz*v[1]+nz*v[2]})
                    if not q or D2(previous,q)<64 then ok=false;break end
                    route[#route+1]=q;previous=q
                end
                local clearance=math.max(32,length*0.7)
                if ok and D2(s.aim,route[1])>=clearance^2 and D2(s.aim,route[3])>=s.runIn^2 then
                    local ax,az=route[1].x-s.aim.x,route[1].z-s.aim.z
                    local bx,bz=route[3].x-s.aim.x,route[3].z-s.aim.z
                    if math.abs(ax*bz-az*bx)>length*width*0.15 then
                        local risk=0
                        if api.Risk then
                            risk=api.Risk(p,u,{Copy(pos),route[1],route[2],route[3],Copy(s.aim)}) or 0
                        end
                        if Finite(risk) and (not bestCost or risk<bestCost) then
                            best,bestCost={nodes=route,clearance=clearance},risk
                        end
                    end
                end
            end
            if best then return best end
        end
    end
end
local function Exit(p,u,r,s,api,now,reason)
    local pos=Copy(u:GetPosition())
    local route=MakeRoute(p,u,s,pos,api)
    if not route then
        -- No legal lobe fits: keep flying using native clamped points. Do not
        -- retry the attack from an impossibly small turn or clear the queue.
        local a,b=api.FlightPoints(p,u,pos)
        if not a then return false end
        route={nodes={a,b},clearance=0};s.noReturn=true
    end
    s.route=route.nodes;s.clearance=route.clearance;s.leg=1;s.lastPos=pos
    s.progressPos=pos;s.progressAt=now;s.maxClearance=math.sqrt(D2(pos,s.aim))
    Trace(p,u,s,"Exit",reason,now)
    return QueueRoute(p,u,r,s,api,now)
end
local function ObserveWeapons(u,s)
    local burst=false
    for _,w in ipairs(s.weapons) do
        local previous=s.samples[w]
        local reload,salvos=w.reloadTimer,w.salvosRemaining
        if w.enabled~=false and not w.isDeathExplosion and (not w.targetUnit or w.targetUnit==s.target) then
            if Finite(salvos) and salvos>0 then burst=true end
            if previous and ((Finite(reload) and Finite(previous.reload) and reload>previous.reload+0.05)
                or (Finite(salvos) and Finite(previous.salvos) and salvos~=previous.salvos)) then
                s.released=true
            end
        end
        previous=previous or {};s.samples[w]=previous
        previous.reload,previous.salvos=reload,salvos
    end
    return burst
end
local function StartRun(p,u,r,s,target,api,now)
    if not target or not api.Visible(p,target) or not Eligible(u,target) then return false end
    local aim=Copy(target:GetPosition());local pos=Copy(u:GetPosition())
    if not Valid(aim) then return false end
    if D2(pos,aim)<s.runIn^2 then
        -- The target moved into the turn. Extend again rather than command an
        -- immediate U-turn on top of it. No hidden-target reads are used.
        s.aim=aim;s.dx,s.dz=Direction(aim,pos,u)
        return Exit(p,u,r,s,api,now,"target-entered-turn")
    end
    local nodes=s.pendingRoute;local append=false
    -- A wing's center is not this bomber's re-entry point. Recheck both
    -- direct approaches and saved doglegs from its actual position before
    -- replacing the turn with a new attack.
    if api.Risk then
        local route={Copy(pos)}
        for i=2,#(nodes or {})-1 do route[#route+1]=Copy(nodes[i]) end
        route[#route+1]=Copy(aim)
        local risk=api.Risk(p,u,route)
        if not Finite(risk) or risk*1.5>math.max(0,u:GetHealth() or 0)*0.85 then
            s.pendingRoute=nil;s.requested=nil;s.phase="Search";r.bomberPassRouteDenied=true
            return false
        end
    end
    if nodes and #nodes>2 then
        for i=2,#nodes-1 do
            if not Issue(p,u,r,api,Tasks.MOVE,append,nodes[i],nil,now) then return false end
            append=true
        end
    end
    if not Issue(p,u,r,api,Tasks.ATTACKUNIT,append,aim,{targetGlobalId=target.id},now) then return false end
    Track(p,u,r,target,now,api,nodes)
    return true
end
local function UpdateTurn(p,u,r,s,target,api,now)
    local pos=Copy(u:GetPosition());local index=RouteIndex(u,s)
    local arrival=Bound(s.speed*0.6,8,20)
    s.maxClearance=math.max(s.maxClearance,math.sqrt(D2(pos,s.aim)))
    local final=s.noReturn and #s.route or #s.route-1
    while s.leg<=final and ((index and index>s.leg) or Swept(s.lastPos,pos,s.route[s.leg],arrival)) do
        s.leg=s.leg+1
    end
    if s.phase=="Exit" and s.leg>1 then Trace(p,u,s,"Turn","exit-cleared",now) end
    if s.leg>final then
        if s.noReturn then
            s.phase="Search";r.target=nil;return false
        end
        -- Native waypoint completion is sufficient even when a long simulation
        -- step skips every position sample at the outermost point.
        if index and index>1 then s.maxClearance=math.max(s.maxClearance,s.clearance) end
        if s.maxClearance>=s.clearance and target and api.Visible(p,target) then
            if not StartRun(p,u,r,s,target,api,now) then s.phase="Search";r.target=nil end
        else
            s.phase="Search";r.target=nil
        end
    else
        if D2(s.progressPos,pos)>16 then s.progressPos=pos;s.progressAt=now end
        local absent=not (u.orders and (u.orders.activeOrder or next(u.orders.queuedOrders or {})))
        if now-(r.issuedAt or -100)>=2 and (absent or (not index) or (now-s.progressAt>=6 and now>=s.recoverAfter)) then
            QueueRoute(p,u,r,s,api,now)
        end
        s.lastPos=pos
    end
    return true
end
-- api is supplied by RushAirOrders so its ownership/repair/pause checks remain
-- the single gate for both normal platoons and independent raid wings.
function Step(p,u,r,target,now,api)
    if not api.Current(p,u,r) then return false end
    local s=r.bomberPass
    if not s then
        if not target or not api.Visible(p,target) or not Eligible(u,target) then return false end
        local aim=Copy(target:GetPosition());if not Valid(aim) then return false end
        s=New(p,u,r,target,aim,now)
    end
    if target then s.requested=target end
    if s.lastStep==now then return true end
    s.lastStep=now
    if Maneuvering(r) then return UpdateTurn(p,u,r,s,s.requested,api,now) end
    if s.phase=="Search" then
        if target and api.Visible(p,target) then StartRun(p,u,r,s,target,api,now);return true end
        return false
    end
    local visible=api.Visible(p,s.target)
    local present,followed=api.AttackPresent(u,s.target,r)
    local active=api.Matches(u.orders and u.orders.activeOrder,s.target,r)
    local pos=Copy(u:GetPosition())
    if not active and present then
        -- Do not count transit/reload changes on the approach as a bombing pass.
        s.lastPos=pos;s.activeAt=nil;s.localAt=nil;s.nearAt=nil;s.released=nil
        for _,w in ipairs(s.weapons) do
            local sample=s.samples[w] or {};s.samples[w]=sample
            sample.reload,sample.salvos=w.reloadTimer,w.salvosRemaining
        end
        return true
    end
    if not present then
        if now-(r.issuedAt or -100)<2 then return true end
        if s.activeAt then
            -- Lost order after entering an attack run (including target death):
            -- finish the outward leg, not another attack on top of the target.
            Exit(p,u,r,s,api,now,"attack-ended");return true
        elseif target and api.Visible(p,target) then
            local aim=Copy(target:GetPosition())
            if not Issue(p,u,r,api,Tasks.ATTACKUNIT,false,aim,{targetGlobalId=target.id},now) then return false end
            Track(p,u,r,target,now,api);return true
        end
        return false
    end
    r.target=s.target
    if visible then
        local q=s.target:GetPosition();if Valid(q) then s.aim=Copy(q) end
    end
    s.activeAt=s.activeAt or now
    local distance=math.sqrt(D2(pos,s.aim))
    local nearby=math.max(32,math.min(s.range or 32,100)+s.speed*1.5)
    if distance<=nearby then s.localAt=s.localAt or now else s.localAt=nil end
    local contact=Bound(s.speed,12,26)
    if Swept(s.lastPos,pos,s.aim,contact) then s.nearAt=s.nearAt or now end
    local burst=ObserveWeapons(u,s)
    local crossed=s.nearAt and (pos.x-s.aim.x)*s.dx+(pos.z-s.aim.z)*s.dz>math.max(6,s.speed*0.35)
    local stalled=s.localAt and now-s.localAt>=8
    if not burst and now-s.activeAt>=0.5 and ((s.released and s.localAt) or crossed or stalled) then
        Exit(p,u,r,s,api,now,s.released and "salvo-complete" or (crossed and "target-crossed" or "run-reset"))
    elseif not followed and now-(r.issuedAt or -100)>=2 then
        EscapeTail(p,u,r,s,api,now)
    end
    s.lastPos=pos
    return true
end
function BreakOff(p,u,r,now,api)
    local s=r.bomberPass;if not s then return false end
    s.target=nil;s.requested=nil;s.pendingRoute=nil;r.target=nil
    if Maneuvering(r) then return true end
    return Exit(p,u,r,s,api,now,"target-ended")
end
function DeferRoute(r,target,nodes)
    if not Maneuvering(r) then return false end
    local s=r.bomberPass;s.requested=target;s.pendingRoute={}
    for _,pos in ipairs(nodes or {}) do s.pendingRoute[#s.pendingRoute+1]=Copy(pos) end
    return true
end
function RemainingRoute(u,r)
    local s=r and r.bomberPass
    if not s or not Maneuvering(r) then return nil end
    local route={Copy(u:GetPosition())}
    for i=s.leg,#s.route do route[#route+1]=Copy(s.route[i]) end
    return #route>1 and route or nil
end
