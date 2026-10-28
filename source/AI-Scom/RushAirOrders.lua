-- RC19: ground-attack aircraft must not become idle in a combat operation.
-- Use native orders only: preserve live attacks/routes, repair missing orders
-- per aircraft, and queue flight legs after an attack so target death does not
-- leave an empty queue. Never change flight flags, weapon stats or visibility.
Version = "9.0.20-rc21"
local BomberPass = Import("AI/mods/AI-Scom/RushBomberPass.lua")
local HeavyPolicy = Import("AI/mods/AI-Scom/RushHeavyPolicy.lua")
local AF = Import("AI/AIFunctions.lua")
local Orders = Import("host/managers/orders/hostOrderManager.lua")
local Tasks = Import("common/commonOrders.lua").OrderTasks
local ACK_SECONDS, GROUND_SECONDS, WAKE_SECONDS = 2, 3, 8
local function Now() return GetGameTimeSeconds() end
local function Finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function Valid(p) return p and Finite(p.x) and Finite(p.z) end
local function Copy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local function Has(u,tag)
    local tp=u.tp
    if not tp then return false end
    if tp.hasTags and tp.hasTags[tag] then return true end
    for _,v in ipairs(tp.tags or {}) do if v==tag then return true end end
    return false
end
local function Live(p)
    return p and not p.dead and not p.deleted and p.ai and p.army and p.army.ai
        and p.army.ai.isAlive~=false and p.army:PlatoonExists(p)
end
local function Controlled(p,u)
    if not (Live(p) and u and not u.dead and not u.deleted and u.army==p.army
        and u.id and p.army.units and p.army.units[u.id.index]==u and u.platoon==p
        and not u.CaptureInProgress and not u.ReclaimInProgress
        and u.ai and u.ai.eState=="PlatoonControlled" and u:IsCompleted()
        and not (u.toggles and u.toggles.Pause)) then return false end
    local former=p.ai.formerTable
    local heavy=former and former.RushHeavyCombat=="air"
        and HeavyPolicy.IsCombatExperimental(u.tp) and HeavyPolicy.Domain(u.tp)=="air"
    -- Armed experimental carriers use this combat plan through their actual
    -- air capability. Ordinary transports and active factory products stay out.
    return (heavy or Has(u,"AIR") and not Has(u,"TRANSPORT") and not Has(u,"SCFA_TRANSPORT"))
        and not u.unitBeingBuilt and not u.unitBeingRepaired and not u.unitBeingCaptured
        and not u.unitBeingReclaimed and not (u.buildQueue and next(u.buildQueue))
        and not (u.productionBehaviorIsActive and u.productionBehaviorTargetUnit
            and not u.productionBehaviorTargetUnit.dead)
end
function Visible(p,target)
    return Live(p) and target and not target.dead and not target.deleted
        and not target.CaptureInProgress and not target.ReclaimInProgress and target.army and p.army:IsEnemy(target.army)
        and ((type(target.IsIntelVisionVisible)=="function" and target:IsIntelVisionVisible(p.army))
            or (type(target.IsIntelRadarVisible)=="function" and target:IsIntelRadarVisible(p.army))) or false
end
local function Current(p,u,r)
    return r and Controlled(p,u) and r.platoon==p and r.platoonAI==p.ai and r.unitAI==u.ai
        and r.armyAI==p.army.ai and r.operation==p.ai.rushOperation and r.bomber==p.ai.rushBomber
        and u.ai.rushAirOrders==r
end
local function Record(p,u)
    local r=u.ai.rushAirOrders
    if not Current(p,u,r) then
        r={platoon=p,platoonAI=p.ai,unitAI=u.ai,armyAI=p.army.ai,
            operation=p.ai.rushOperation,bomber=p.ai.rushBomber};u.ai.rushAirOrders=r
    end
    return r
end
local function Issue(p,u,r,task,append,pos,payload)
    if not Current(p,u,r) or not Valid(pos) then return nil end
    local before={};local orders=u.orders or {}
    if orders.activeOrder then before[orders.activeOrder]=true end
    for _,order in ipairs(orders.queuedOrders or {}) do before[order]=true end
    Orders.HostIssueOrder(task,{u},append,Copy(pos),payload)
    if not Current(p,u,r) then return nil end
    -- Native HostIssueOrder returns nothing; rejected orders must not become
    -- fictional flight legs, completed attacks or a fresh acknowledgement timer.
    orders=u.orders or {};local accepted
    if orders.activeOrder and orders.activeOrder.orderTask==task and not before[orders.activeOrder] then accepted=orders.activeOrder end
    if not accepted then
        for _,order in ipairs(orders.queuedOrders or {}) do
            if order.orderTask==task and not before[order] then accepted=order;break end
        end
    end
    if accepted then
        -- Keep exact ownership only for orders still in the native queue.
        -- Every new issue replaces this bounded set, never a command history.
        local previous=r.ownedOrders or {};local owned={}
        if orders.activeOrder and previous[orders.activeOrder] then owned[orders.activeOrder]=true end
        for _,order in ipairs(orders.queuedOrders or {}) do if previous[order] then owned[order]=true end end
        owned[accepted]=true;r.ownedOrders=owned
        return accepted
    end
end
local function SameId(a,b)
    if a==b then return true end
    -- Native orders normally expose targetUnit. A copied global ID is accepted
    -- only when every field matches, not merely its reusable unit index.
    if type(a)~="table" or type(b)~="table" or a.index==nil or b.index==nil then return false end
    for k,v in pairs(a) do if b[k]~=v then return false end end
    for k,v in pairs(b) do if a[k]~=v then return false end end
    return true
end
local function Matches(order,target,r)
    if not order or order.orderTask~=Tasks.ATTACKUNIT then return false end
    if order.targetUnit then return order.targetUnit==target end
    if order.targetGlobalId then return SameId(order.targetGlobalId,target.id) end
    -- Some host versions expose the task but resolve its target internally.
    return r.target==target
end
local function AttackPresent(u,target,r)
    local orders=u.orders or {}
    local found=Matches(orders.activeOrder,target,r)
    local followed=false
    for _,order in ipairs(orders.queuedOrders or {}) do
        if found then followed=true end
        if Matches(order,target,r) then found=true end
    end
    return found,followed
end
local function Busy(u)
    return u.orders and (u.orders.activeOrder or next(u.orders.queuedOrders or {}))
end
local function Clamp(p)
    if not Valid(p) then return nil end
    local q=AF.GetPositionWithinPlayableArea(Copy(p))
    if not Valid(q) then return nil end
    q=Copy(q) -- the native clamp may reuse its return table
    if type(AF.isPosWithinPlayableArea)=="function" and not AF.isPosWithinPlayableArea(q) then return nil end
    return q
end
local function FlightPoints(p,u,origin)
    if not Valid(origin) then return nil end
    origin=Copy(origin)
    local home=p.ai.basePosition
    local dx,dz=0,0
    if Valid(home) then dx,dz=home.x-origin.x,home.z-origin.z end
    local length=math.sqrt(dx*dx+dz*dz)
    if length<1 then
        local angle=(u.id.index%8)*math.pi/4;dx,dz=math.cos(angle),math.sin(angle)
    else dx,dz=dx/length,dz/length end
    local speed=u.tp.movement and u.tp.movement.speed or 16
    if not Finite(speed) then speed=16 end
    local stride=math.max(48,math.min(120,speed*3))
    -- Start homeward, not deeper into the target. Try alternate headings only
    -- when the playable-area clamp collapses a leg at an edge or corner.
    for _,angle in ipairs({0,math.pi/4,-math.pi/4,math.pi/2,-math.pi/2,math.pi}) do
        local x=dx*math.cos(angle)-dz*math.sin(angle)
        local z=dx*math.sin(angle)+dz*math.cos(angle)
        local first=Clamp({x=origin.x+x*stride,y=origin.y,z=origin.z+z*stride})
        local second=Clamp({x=origin.x+x*stride*2,y=origin.y,z=origin.z+z*stride*2})
        if first and second and D2(origin,first)>=64 and D2(first,second)>=64 then return first,second end
    end
end
local function Tail(p,u,r,origin,append)
    local first,second=FlightPoints(p,u,origin)
    if not first or not Current(p,u,r) then return false end
    local firstOrder=Issue(p,u,r,Tasks.MOVE,append,first,nil)
    if not firstOrder then return false end
    local secondOrder=Issue(p,u,r,Tasks.MOVE,true,second,nil)
    r.flightFirst,r.flightLast=first,secondOrder and second or first
    r.flightFirstOrder,r.flightLastOrder=firstOrder,secondOrder or firstOrder;r.issuedAt=Now()
    return true
end
local function OwnFlight(order,r)
    return order and order.orderTask==Tasks.MOVE
        and (order==r.flightFirstOrder or order==r.flightLastOrder)
end
local function OrdersOwned(u,r)
    local orders=u.orders or {};local pass=r.bomberPass
    local function owned(order)
        return r.ownedOrders and r.ownedOrders[order] or r.musterOrders and r.musterOrders[order]
            or OwnFlight(order,r) or pass and pass.routeOrders and pass.routeOrders[order]
    end
    if orders.activeOrder and not owned(orders.activeOrder) then return false end
    for _,order in ipairs(orders.queuedOrders or {}) do if not owned(order) then return false end end
    return true
end
function MusterOverridden(p,u)
    local r=u.ai and u.ai.rushAirOrders
    return Current(p,u,r) and (r.musterOrders~=nil or r.musterGuard) and not OrdersOwned(u,r) or false
end
function CanMuster(p,u)
    if not Controlled(p,u) then return false end
    local r=Record(p,u)
    if OrdersOwned(u,r) then return true end
    -- First admission also needs proof, even if this unit has never orbited.
    -- The guard survives target changes until the newer native queue drains.
    r.musterGuard=true
    return false
end
local PassAPI={Controlled=Controlled,Current=Current,Issue=Issue,Visible=Visible,Clamp=Clamp,FlightPoints=FlightPoints,
    Matches=Matches,AttackPresent=AttackPresent}
-- Registered by the raid module after its visibility-limited AA estimator loads.
-- Avoid a circular import and share that same estimator with ordinary bombers.
function SetPassRiskEvaluator(fn) PassAPI.Risk=fn end
function ClearPass(p,units)
    for _,u in ipairs(units or p:GetUnits()) do
        if Controlled(p,u) and not MusterOverridden(p,u) then
            local r=Record(p,u);r.bomberPass=nil;r.musterOrders=nil;r.musterCenter=nil;r.musterOwner=nil
        end
    end
end
-- A bomber's visible committed target remains valid while its turn takes it
-- outside the ordinary local acquisition radius. Threat-driven retreat still
-- wins in the caller. Gunships and units without a committed pass are ignored.
function CommittedTarget(p)
    if not Live(p) then return nil end
    for _,u in ipairs(p:GetUnits() or {}) do
        if Controlled(p,u) then
            local r=u.ai.rushAirOrders;local s=r and r.bomberPass
            if Current(p,u,r) and s and s.phase~="Search" then
                local target=s.requested or s.target
                if Visible(p,target) then return target end
            end
        end
    end
end
function RemainingPassRoute(p,u)
    if not Controlled(p,u) then return nil end
    local r=u.ai.rushAirOrders
    return Current(p,u,r) and BomberPass.RemainingRoute(u,r) or nil
end
-- Count only native attacks or their accepted, still-owned turn legs in a
-- coordinated salvo. A rejected order is never additional covering firepower.
function CommittedTo(p,u,target)
    if not Controlled(p,u) then return false end
    local r=u.ai.rushAirOrders
    if not Current(p,u,r) then return false end
    if AttackPresent(u,target,r) then return true end
    local pass=r.bomberPass;local active=u.orders and u.orders.activeOrder
    return pass and pass.target==target and pass.phase~="Search" and active
        and ((pass.routeOrders and pass.routeOrders[active]) or OwnFlight(active,r)) or false
end
-- Called immediately after the raid controller's route + attack issue. Preserve
-- all approach waypoints and append only the target-loss flight continuation.
function TrackAttack(p,units,target,nodes)
    if not Visible(p,target) then return end
    local pos=Copy(target:GetPosition())
    for _,u in ipairs(units or {}) do
        if Controlled(p,u) then
            local r=Record(p,u);r.target=target;r.issuedAt=Now();r.groundSince=nil
            if not BomberPass.Track(p,u,r,target,Now(),PassAPI,nodes) then Tail(p,u,r,pos,true) end
        end
    end
end
-- Do not overwrite a bomber's outward/turning leg when its next target is
-- acquired. Other wing members can start independently; no group-wide stop.
function RouteAttack(p,units,target,nodes)
    if not Visible(p,target) then return 0 end
    local issued=0
    for _,u in ipairs(units or {}) do
        if Controlled(p,u) and not MusterOverridden(p,u) then
            local r=Record(p,u);r.musterOrders=nil;r.musterCenter=nil;r.musterOwner=nil
            if not BomberPass.DeferRoute(r,target,nodes) then
                r.bomberPass=nil
                local append,accepted=false,true
                for i=2,#(nodes or {})-1 do
                    if not Issue(p,u,r,Tasks.MOVE,append,nodes[i],nil) then accepted=false;break end
                    append=true
                end
                if accepted and Issue(p,u,r,Tasks.ATTACKUNIT,append,target:GetPosition(),{targetGlobalId=target.id}) then
                    TrackAttack(p,{u},target,nodes);issued=issued+1
                end
            else issued=issued+1 end
        end
    end
    return issued
end
function RouteMove(p,units,nodes,destination)
    if not Live(p) or not Valid(destination) then return 0 end
    local issued=0
    for _,u in ipairs(units or {}) do
        if Controlled(p,u) and not MusterOverridden(p,u) then
            local r=Record(p,u);local append,accepted=false,true
            for i=2,#(nodes or {})-1 do
                if not Issue(p,u,r,Tasks.MOVE,append,nodes[i],nil) then accepted=false;break end
                append=true
            end
            if accepted and Issue(p,u,r,Tasks.MOVE,append,destination,nil) then issued=issued+1 end
        end
    end
    return issued
end
function Attack(p,target,units)
    if not Visible(p,target) or p.ai.withdraw or p.ai.eState=="Withdraw"
        or p.ai.eState=="WithdrawInit" or p.ai.eState=="Disband" then return 0 end
    local now=Now();local issued=0
    for _,u in ipairs(units or p:GetUnits()) do
        if Controlled(p,u) and not MusterOverridden(p,u) then
            local r=Record(p,u)
            local present,followed=AttackPresent(u,target,r)
            if u.isAirborne==false then r.groundSince=r.groundSince or now else r.groundSince=nil end
            local wake=r.groundSince and now-r.groundSince>=GROUND_SECONDS and now>=(r.wakeAfter or 0)
            local pending=r.target==target and r.issuedAt and now-r.issuedAt<ACK_SECONDS
            local before=r.bomberAttacksIssued or 0
            local passHandled=not wake and BomberPass.Step(p,u,r,target,now,PassAPI)
            if passHandled then
                issued=issued+(r.bomberAttacksIssued or 0)-before
            elseif present and not wake then
                r.target=target
                if not followed and not pending then Tail(p,u,r,Copy(target:GetPosition()),true) end
            elseif not pending then
                local targetPos=Copy(target:GetPosition())
                if Valid(targetPos) and Controlled(p,u) then
                    local append=false
                    if wake then
                        r.bomberPass=nil
                        local launch=FlightPoints(p,u,Copy(u:GetPosition()))
                        if launch then
                            if Issue(p,u,r,Tasks.MOVE,false,launch,nil) then
                                append=true;r.wakeAfter=now+WAKE_SECONDS;r.groundSince=now
                            end
                        end
                    end
                    if Issue(p,u,r,Tasks.ATTACKUNIT,append,targetPos,{targetGlobalId=target.id}) then
                        r.target=target;r.issuedAt=now
                        Tail(p,u,r,targetPos,true)
                        issued=issued+1
                    end
                end
            end
        end
    end
    return issued
end
-- An ended/dead/hidden objective is replaced atomically with flight orders, not
-- CLEAR/STOP followed by a multi-tick acquisition pause over hostile ground.
function BreakOff(p,units,reason)
    if not Live(p) then return end
    for _,u in ipairs(units or p:GetUnits()) do
        if Controlled(p,u) and not MusterOverridden(p,u) then
            local r=Record(p,u);r.musterOrders=nil;r.musterCenter=nil;r.musterOwner=nil
            local urgent=reason=="anti-air" or reason=="contact-lost" or reason=="attack-deadline"
                or reason=="no-effective-pass" or p.ai.withdraw
            if not urgent and BomberPass.BreakOff(p,u,r,Now(),PassAPI) then
                r.groundSince=nil
            else
                r.bomberPass=nil
                if Tail(p,u,r,Copy(u:GetPosition()),false) then r.target=nil;r.groundSince=nil end
            end
        end
    end
end
function MusterRadius(u)
    local movement=u.tp and u.tp.movement or {};local speed=movement.speed
    local rotation=movement.rotationSpeed
    if not Finite(speed) or speed<=0 or not Finite(rotation) or rotation<=0 then return math.huge end
    -- Native movement uses degrees/second. Keep the orbit comfortably outside
    -- the template's minimum turn radius without changing flight parameters.
    return math.max(32,speed*2,speed/(rotation*math.pi/180)*1.5,
        Finite(movement.orbitRange) and movement.orbitRange or 0)
end
function Mustered(p,u,response)
    if not Controlled(p,u) then return false end
    local r=u.ai.rushAirOrders;local orders=u.orders or {}
    if not Current(p,u,r) or r.musterOwner~=response or not r.musterOrders then return false end
    local present=false
    if orders.activeOrder then
        if not r.musterOrders[orders.activeOrder] then return false end
        present=true
    end
    for _,order in ipairs(orders.queuedOrders or {}) do
        if not r.musterOrders[order] then return false end
        present=true
    end
    return present
end
-- Each wing owns its own short orbit while a shared artillery salvo assembles.
-- Refill only an accepted orbit or an empty queue; a newer foreign order wins.
function Muster(p,units,center,ingress)
    if not Live(p) or not Valid(center) or not p.ai.rushBomber then return 0 end
    local response=p.ai.rushBomber.response
    if not response then return 0 end
    local controlled,unsafe=0,false
    for _,u in ipairs(units or {}) do
        if Controlled(p,u) then
            local r=Record(p,u);local orders=u.orders or {}
            local same=r.musterOwner==response and r.musterCenter and D2(r.musterCenter,center)<4
            local busy=orders.activeOrder or next(orders.queuedOrders or {})
            local owned=OrdersOwned(u,r)
            if not owned then
                r.musterGuard=true
                -- Keep the old proof across response changes. A new artillery
                -- target does not authorize overwriting a newer native order.
            elseif same and busy and Mustered(p,u,response)
                and (next(orders.queuedOrders or {}) or Now()-(r.musterAt or 0)<ACK_SECONDS) then
                controlled=controlled+1
            else
                local radius=MusterRadius(u)
                local phase=0;local route={}
                local append=same and orders.activeOrder and Mustered(p,u,response) or false
                local tail=append and orders.activeOrder
                if not same then
                    for i=2,#(ingress or {})-1 do route[#route+1]=Copy(ingress[i]) end
                end
                if radius<=160 then
                    for i=0,2 do
                        local angle=phase+i*2*math.pi/3
                        local pos=Clamp({x=center.x+math.cos(angle)*radius,y=center.y,z=center.z+math.sin(angle)*radius})
                        if pos and (#route==0 or D2(route[#route],pos)>=64) then route[#route+1]=pos end
                    end
                end
                local safe=true
                if #route>=2 and PassAPI.Risk then
                    local approach={Copy(u:GetPosition())}
                    local tailPosition=tail and r.musterOrders and r.musterOrders[tail]
                    if type(tailPosition)=="table" and Valid(tailPosition) then approach[#approach+1]=Copy(tailPosition) end
                    for _,pos in ipairs(route) do approach[#approach+1]=pos end
                    local risk=PassAPI.Risk(p,u,approach)
                    safe=Finite(risk) and risk*1.5<=math.max(0,u:GetHealth() or 0)*0.65
                    if not safe then unsafe=true end
                end
                if #route>=2 and safe then
                    r.bomberPass=nil;r.target=nil
                    local accepted={};local count=0
                    if tail then accepted[tail]=r.musterOrders[tail] end
                    for i,pos in ipairs(route) do
                        local order=Issue(p,u,r,Tasks.MOVE,append or i>1,pos,nil)
                        if not order then break end
                        accepted[order]=Copy(pos);count=count+1
                    end
                    if count>0 then
                        r.musterOwner=response;r.musterCenter=Copy(center);r.musterOrders=accepted;r.musterAt=Now()
                        controlled=controlled+1
                    end
                end
            end
        end
    end
    return controlled,unsafe
end
function KeepFlying(p,units)
    if not Live(p) or p.ai.eState=="Disband" then return end
    for _,u in ipairs(units or p:GetUnits()) do
        if Controlled(p,u) then
            local r=Record(p,u);local now=Now()
            local keepPass=p.ai.eState=="MicroingPlatoon" or p.ai.eState=="SelectMainTarget"
            if not keepPass or p.ai.withdraw then r.bomberPass=nil end
            local passHandled=r.bomberPass and BomberPass.Step(p,u,r,nil,now,PassAPI)
            -- A disabled weapon or newly unshootable target must not strand a
            -- bomber at the end of its turn. Search waits without attack orders,
            -- while the ordinary flight-continuation guard remains active.
            if r.bomberPass and r.bomberPass.phase=="Search" then passHandled=false end
            local orders=u.orders or {}
            local pending=r.issuedAt and now-r.issuedAt<ACK_SECONDS
            local ownFlight=OwnFlight(orders.activeOrder,r)
            -- Preserve native attack, retreat, scouting and approach orders. Only
            -- refill our own continuation or an actually empty aircraft queue.
            if not passHandled and not pending and (not Busy(u) or (ownFlight and not next(orders.queuedOrders or {}))) then
                local home=p.ai.basePosition
                local pos=Copy(u:GetPosition())
                local returning=p.ai.eState=="Withdraw" or p.ai.eState=="WithdrawInit"
                local atHome=Valid(home) and D2(pos,home)<=math.max(30,p.ai.baseRadius or 30)^2
                if not (returning and atHome) then
                    local origin=ownFlight and r.flightLast or pos
                    if Tail(p,u,r,origin,ownFlight and true or false) then r.target=nil end
                end
            end
        end
    end
end
