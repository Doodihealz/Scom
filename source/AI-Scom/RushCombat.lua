-- RC10 bounded land operations. Uses the host's existing movement and weapon
-- micro helpers through explicit callbacks; it does not implement fake orders.
Version = "9.0.23-rc28"
local Pressure = Import("AI/mods/AI-Scom/RushPressure.lua")
local Policy = Import("AI/mods/AI-Scom/RushCombatPolicy.lua")
local HeavyPolicy = Import("AI/mods/AI-Scom/RushHeavyPolicy.lua")
local Intel = Import("AI/mods/AI-Scom/RushCombatIntel.lua")
local AF = Import("AI/AIFunctions.lua")
local MG = Import("AI/AIMarkerGenerator.lua")
local Selection = Import("AI/mods/AI-Scom/RushSelection.lua")
local Front = Import("AI/mods/AI-Scom/RushFrontline.lua")
local Budget = Import("AI/mods/AI-Scom/RushPathBudget.lua")
local Movement = Import("AI/mods/AI-Scom/RushMovement.lua")
local C = Policy.Config
local STATE_NAMES={Group="Grouping",Advance="MoveToTargetArea",Engage="MicroingPlatoon",
    Retreat="Withdraw",Acquire="SelectMainTarget",Hold="SelectMainTarget"}
local RETREAT_DIRECTIONS={{1,0},{math.cos(0.7),math.sin(0.7)},{math.cos(-0.7),math.sin(-0.7)}}
local FRONT_RADIUS=80
local function Now() return GetGameTimeSeconds() end
local function Copy(p) return {x=p.x,y=p.y,z=p.z} end
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local function Count(p) return p:GetNumOfUnits() end
local function Live(p) return p and not p.dead and not p.deleted and p.army and p.army.ai
    and p.army.ai.isAlive~=false and p.ai and p.army:PlatoonExists(p) and Count(p)>0 end
local function Current(p,army,armyAI,ai,op)
    return Live(p) and p.army==army and army.ai==armyAI and p.ai==ai and ai.rushOperation==op
end
local function QueueResumeRetry(p,reason)
    local op=p.ai.rushOperation
    if reason=="foreign-orders" or reason=="stale-request" or not op or not op.moveGoal then return false end
    if not op.pendingMove then
        op.pendingMove={pos=Copy(op.moveGoal),aggressive=op.moveAggressive==true,
            checkAttackRoute=op.moveCheckAttackRoute==true}
    end
    return true
end
local function RefreshMovementLayer(p)
    local ai=p.ai;local old=ai.movementLayer
    ai.movementLayer=Movement.MovementLayer(p)
    local op=ai.rushOperation
    if old~=ai.movementLayer and op and op.moveGoal then
        -- A new restrictive recruit must not inherit a route generated for the
        -- previous composition. Keep the old native leg until a fresh route wins.
        if not op.pendingMove then
            op.pendingMove={pos=Copy(op.moveGoal),aggressive=op.moveAggressive==true,
                checkAttackRoute=op.moveCheckAttackRoute==true}
        end
        ai.rushMoving=false
    end
    return old==ai.movementLayer
end
local function State(army)
    army.ai.rushCombat=army.ai.rushCombat or {operations={},supports={},lastReport=0,
        stats={merges=0,detached=0,goals=0,repaths=0,retreats=0,rejected=0}}
    return army.ai.rushCombat
end
local function IsRaider(former)
    return former.RushRaider or former.FormerName=="F123 Land Alloy Hunter"
end
local ASSAULT_LIMIT,ASSAULT_RADIUS,ASSAULT_SECONDS=128,160,90
local function AssaultOfferCurrent(p,now)
    if not Live(p) then return nil end
    local ai=p.ai;local op=ai.rushOperation;local offer=op and op.assaultOffer
    now=now or Now()
    if not offer or offer.armyAI~=p.army.ai or offer.platoonAI~=ai or offer.operation~=op
        or now>=offer.expires or now>=(offer.safeUntil or 0) or op.supportSince or op.defenseClaim
        or op.policy.phase=="Retreat" or op.policy.phase=="Engage"
        or not Intel.Visible(p.army,offer.unit) or D2(offer.pos,offer.unit:GetPosition())>FRONT_RADIUS^2 then return nil end
    return offer
end
local function Limit(p)
    local data=p.ai and p.ai.formerTable and p.ai.formerTable.AIPlanData or {}
    local maximum=data.RushUnitLimit or C.PrimaryLimit
    if AssaultOfferCurrent(p) then maximum=math.max(maximum,ASSAULT_LIMIT) end
    if #Front.Defense(p.army).fronts>1 then maximum=math.min(maximum,24) end
    return maximum
end
local function Position(p)
    return p.ai.rushGeometry and p.ai.rushGeometry.position or p:GetPosition()
end
local function CanReceiveSupport(platoon)
    local former=platoon.ai.formerTable or {}
    return not former.RushSiege and not IsRaider(former)
end
local function Prune(state)
    for _,pool in ipairs({state.operations,state.supports}) do
        for id,p in pairs(pool) do
            local op=p.ai and p.ai.rushOperation
            if not Live(p) or not op or op.registry~=pool or op.registeredAI~=p.ai
                or op.registeredArmyAI~=p.army.ai then pool[id]=nil end
        end
    end
end

function Register(platoon,support)
    local state=State(platoon.army)
    Prune(state)
    local pool=state[support and "supports" or "operations"]
    pool[platoon.id]=platoon
    local op=platoon.ai.rushOperation
    if op then op.registry,op.registeredAI,op.registeredArmyAI=pool,platoon.ai,platoon.army.ai end
end
function Unregister(platoon)
    local state=State(platoon.army)
    state.operations[platoon.id],state.supports[platoon.id]=nil,nil
    platoon.ai.rushReceiver=nil
    local op=platoon.ai.rushOperation
    if op then op.defenseClaim=nil;op.defensePending=nil;op.registry=nil end
    Budget.Cancel(platoon)
end
function Capacity(platoon) return math.max(0,Limit(platoon)-Count(platoon)) end

-- Formation gates include incoming reservations, not just current membership.
-- A support cannot claim the last twelve slots already promised to another one.
function AvailableRoom(army,receiver,except)
    local room=Capacity(receiver)
    local state=State(army);Prune(state)
    for _,s in pairs(state.supports) do
        if s~=except and Live(s) and s.ai.rushReceiver==receiver then room=room-Count(s) end
    end
    return math.max(0,room)
end
-- Reservations are read once per selection, not once per candidate receiver.
-- This is a local calculation, never a cross-tick cache: transfers, deaths and
-- reassignment are visible to the very next caller in the same game tick.
local function Reservations(state,except)
    local totals={}
    for _,p in pairs(state.supports) do
        local receiver=p.ai.rushReceiver
        if p~=except and receiver and Live(p) then
            totals[receiver]=(totals[receiver] or 0)+Count(p)
        end
    end
    return totals
end
function SupportAvailable(army)
    local state=State(army);Prune(state)
    if #Front.Defense(army).fronts>0 then return true end
    local reserved=Reservations(state)
    for _,p in pairs(state.operations) do
        if CanReceiveSupport(p) and Capacity(p)-(reserved[p] or 0)>=2 then return true end
    end
    return false
end
function SupportReceiver(platoon)
    local state=State(platoon.army);Prune(state)
    local reserved=Reservations(state,platoon)
    local old=platoon.ai.rushReceiver
    if Live(old) and state.operations[old.id]==old and old.army==platoon.army
        and CanReceiveSupport(old) and Capacity(old)-(reserved[old] or 0)>0 then return old end
    local pos=Copy(Position(platoon))
    local candidates={}
    for _,p in pairs(state.operations) do
        if p~=platoon and Live(p) and CanReceiveSupport(p) and Capacity(p)-(reserved[p] or 0)>0 then
            local destination=Copy(Position(p))
            candidates[#candidates+1]={platoon=p,pos=destination,distance=D2(pos,destination)}
        end
    end
    table.sort(candidates,function(a,b)
        if a.distance~=b.distance then return a.distance<b.distance end
        return a.platoon.id<b.platoon.id
    end)
    for _,candidate in ipairs(candidates) do
        if MG.CanGraphAreaTo(pos,candidate.pos,platoon.ai.movementLayer) then
            platoon.ai.rushReceiver=candidate.platoon
            return candidate.platoon
        end
    end
    platoon.ai.rushReceiver=nil
end

-- Prefer a two-thirds damage core, then nearby AA/support. This remains a
-- preference when fewer damage units exist; native eligibility/reserves apply.
local function RecruitDistanceLess(a,b)
    if a.distance~=b.distance then return a.distance<b.distance end
    return a.id<b.id
end
local function RecruitDamageLess(a,b)
    if a.damage~=b.damage then return a.damage end
    return RecruitDistanceLess(a,b)
end
function SelectRecruits(units,maximum,position,receiver)
    local army=units[1] and units[1].army
    local fronts=not receiver and army and #Front.Defense(army).fronts or 0
    if fronts>1 then maximum=math.min(maximum,math.max(4,math.ceil(#units/math.min(4,fronts))),24) end
    maximum=math.min(maximum,#units)
    local existing,damage=0,0
    if receiver then
        for _,unit in pairs(receiver:GetUnits()) do
            if not unit.dead and not unit.deleted and unit.army==receiver.army and unit.platoon==receiver
                and receiver.army.units[unit.id.index]==unit and not unit.CaptureInProgress and not unit.ReclaimInProgress then
                existing=existing+1
                if not (unit.ai and unit.ai.eState=="RepairHome") and not (unit.GetPause and unit:GetPause())
                    and (AF.GetUnitThreatValueByLayer(unit,"Land",false) or 0)>0 then damage=damage+1 end
            end
        end
    end
    local desired=math.min(maximum,math.max(0,math.ceil((existing+maximum)*2/3)-damage))
    local candidates={}
    for _,u in ipairs(units) do
        -- Engine/native reads belong outside a sort comparator. They are done
        -- once per eligible recruit, with no persistent cache of health/position.
        candidates[#candidates+1]={unit=u,id=u.id.index,
            damage=(AF.GetUnitThreatValueByLayer(u,"Land",false) or 0)>0,
            distance=D2(u:GetPosition(),position)}
    end
    local chosen,used={},{}
    for _,r in ipairs(Selection.Top(candidates,desired,RecruitDamageLess)) do
        chosen[#chosen+1]=r.unit;used[r.unit]=true
    end
    for _,r in ipairs(Selection.Top(candidates,maximum,RecruitDistanceLess)) do
        if #chosen>=maximum then break end
        if not used[r.unit] then chosen[#chosen+1]=r.unit end
    end
    return chosen
end

local function OwnedMovementOrIdle(unit,platoon)
    local orders=unit.orders or {}
    if not orders.activeOrder and not next(orders.queuedOrders or {}) then return true end
    local queue=unit.ai and unit.ai.rushMoveQueue
    if not queue or queue.owner~=platoon.army or queue.armyAI~=platoon.army.ai
        or queue.platoon~=platoon or queue.ai~=unit.ai or queue.pai~=platoon.ai
        or queue.operation~=platoon.ai.rushOperation or queue.source~=platoon.ai.path
        or queue.layer~=platoon.ai.movementLayer or unit.ai.path~=queue.path then return false end
    if orders.activeOrder and not queue.orders[orders.activeOrder] then return false end
    for _,order in ipairs(orders.queuedOrders or {}) do if not queue.orders[order] then return false end end
    return true
end
local function RegroupOrdersOwned(platoon)
    for _,unit in pairs(platoon:GetUnits()) do
        if not unit.dead and not unit.deleted and unit.army==platoon.army and unit.platoon==platoon
            and (platoon.army.units[unit.id.index]~=unit or unit.CaptureInProgress or unit.ReclaimInProgress
                or unit.GetPause and unit:GetPause() or unit.ai and unit.ai.eState=="RepairHome"
                or Movement.Suspended(unit) or not OwnedMovementOrIdle(unit,platoon)) then return false end
    end
    return true
end

-- Transfer only physically arrived units, at a hard membership cap. AssignUnits
-- may mutate the donor's array, so never iterate that array while assigning.
function Transfer(source,receiver,hooks)
    if not Live(source) or not Live(receiver) or source.army~=receiver.army then return 0 end
    local army,armyAI=source.army,source.army.ai
    local sourceAI,receiverAI=source.ai,receiver.ai
    local sourceOp,receiverOp=sourceAI.rushOperation,receiverAI.rushOperation
    local promised=sourceOp and sourceOp.assaultReceiverOffer
    if promised and (AssaultOfferCurrent(receiver)~=promised or not RegroupOrdersOwned(source)
        or not RegroupOrdersOwned(receiver)) then return 0 end
    local room=Capacity(receiver)
    if room==0 then sourceAI.rushReceiver=nil;return 0 end
    local pos=Copy(Position(receiver));local arrived={}
    for _,u in pairs(source:GetUnits()) do
        if not u.dead and not u.deleted and u.army==source.army and u.platoon==source
            and source.army.units[u.id.index]==u and not u.CaptureInProgress and not u.ReclaimInProgress
            and not (u.ai and u.ai.eState=="RepairHome") and not Movement.Suspended(u)
            and (not promised or not (u.GetPause and u:GetPause()) and OwnedMovementOrIdle(u,source)) then
            local unitPosition=u:GetPosition()
            if D2(unitPosition,pos)<=40*40 and MG.CanGraphAreaTo(unitPosition,pos,source.ai.movementLayer) then
                arrived[#arrived+1]=u
            end
        end
    end
    arrived=SelectRecruits(arrived,room,pos,receiver)
    if #arrived==0 or not Current(source,army,armyAI,sourceAI,sourceOp)
        or not Current(receiver,army,armyAI,receiverAI,receiverOp) then return 0 end
    if promised and (AssaultOfferCurrent(receiver)~=promised or not RegroupOrdersOwned(source)
        or not RegroupOrdersOwned(receiver)) then return 0 end
    receiver:AssignUnits(arrived)
    for _,u in ipairs(arrived) do
        if not u.dead and not u.deleted and u.army==receiver.army and u.platoon==receiver
            and not u.CaptureInProgress and not u.ReclaimInProgress then
            hooks.ResetUnit(u,"RushCombatTransfer")
            u.ai=u.ai or {};u.ai.eState="PlatoonControlled"
        end
    end
    local sameLayer=RefreshMovementLayer(receiver)
    State(army).stats.merges=State(army).stats.merges+#arrived
    if Capacity(receiver)==0 and source.ai==sourceAI then sourceAI.rushReceiver=nil end
    -- Reset every transferred unit before the first yielding resume. The donor
    -- can legitimately become empty; its replacement assignment cannot be used.
    for _,u in ipairs(arrived) do
        if not Current(receiver,army,armyAI,receiverAI,receiverOp) or source.army~=army
            or source.ai~=sourceAI or sourceAI.rushOperation~=sourceOp then break end
        if sameLayer and receiverAI.rushMoving and receiverOp and receiverOp.moveGoal and hooks.ResumeUnit
            and not u.dead and not u.deleted and u.army==army and u.platoon==receiver then
            local accepted,reason=hooks.ResumeUnit(u,receiver,receiverOp.moveGoal)
            if not Current(receiver,army,armyAI,receiverAI,receiverOp) then break end
            if not accepted and QueueResumeRetry(receiver,reason) then break end
        end
    end
    return #arrived
end

local function IsBlocked(op,pos,now)
    for i=#op.blocked,1,-1 do
        local b=op.blocked[i]
        if now>=b.untilTime then table.remove(op.blocked,i)
        elseif D2(b.pos,pos)<48*48 then return true end
    end
    return false
end
local function Reject(platoon,pos,now)
    local op=platoon.ai.rushOperation
    if pos then
        if #op.blocked>=16 then table.remove(op.blocked,1) end
        op.blocked[#op.blocked+1]={pos=Copy(pos),untilTime=now+C.ObjectiveCooldown}
    end
    State(platoon.army).stats.rejected=State(platoon.army).stats.rejected+1
end
local function TargetValid(platoon,u)
    return u and Intel.Visible(platoon.army,u) and not u:HasTags(Tags.AIR)
end
local function NearTarget(platoon,g,hooks)
    local old=platoon.ai.microTarget
    local radius=math.max(40,g.radius+g.range+12)
    local function allowed(u)
        local pos=u:GetPosition()
        local claim=platoon.ai.rushOperation.defenseClaim
        if claim then
            local view=Front.Defense(platoon.army)
            local assigned=Front.DefenseMatch(view,claim)
            if assigned and view.byUnit[u]~=assigned and D2(pos,assigned.pos)>48^2
                and not Intel.InWeaponRange(g,u) then return false end
        end
        if not IsBlocked(platoon.ai.rushOperation,pos,Now())
            and not Front.Blocked(platoon.army,pos,g.own) then return true end
        -- Test weapon ranges only for an otherwise excluded approach. Ordinary
        -- nearby selection keeps RC13's bounded permission-check workload.
        return Intel.InWeaponRange(g,u)
    end
    if TargetValid(platoon,old) and D2(g.position,old:GetPosition())<=radius*radius
        and allowed(old) and hooks.CanShoot(platoon,old) then return old end
    local nearby={}
    for _,u in ipairs(Intel.EnemiesInRadius(platoon.army,g.position,radius,true)) do
        if allowed(u) then
            local pos=u:GetPosition()
            nearby[#nearby+1]={unit=u,distance=D2(g.position,pos)}
        end
    end
    nearby=Selection.Top(nearby,12,function(a,b)
        if a.distance~=b.distance then return a.distance<b.distance end
        return a.unit.id.index<b.unit.id.index
    end)
    for i=1,math.min(12,#nearby) do
        if hooks.CanShoot(platoon,nearby[i].unit) then return nearby[i].unit end
    end
end

-- Cheap ranking first; expensive reachability and threat queries only for a
-- rotating bounded shortlist. Rotation prevents twelve unreachable targets
-- from hiding the thirteenth reachable one forever.
local function ObjectiveLess(a,b)
    -- Keep every survival MAIN incursion ahead of ordinary objectives.
    if a.breach~=b.breach then return a.breach end
    if a.regroup~=b.regroup then return a.regroup end
    if a.score~=b.score then return a.score<b.score end
    return a.unit.id.index<b.unit.id.index
end
-- Defense reservations belong to this exact running assignment. They count
-- while travelling, before a yielding path request, and disappear promptly on
-- retreat, reassignment, death, cleared threats or a stopped controller.
local function DefenseEligible(platoon,front)
    local former=platoon.ai.formerTable or {}
    if former.RushSiege or platoon.ai.isNavalPlatoon then return false end
    if not IsRaider(former) and (Pressure.SurvivalMap()
        or not (former.AIPlanData and former.AIPlanData.IgnoreLandEmergencyTargets)) then return true end
    local alarm=Front.MainAlarm(platoon.army)
    return alarm.localRaid and alarm.base and (not front or front.own and front.baseName=="MAIN")
        and D2(Position(platoon),alarm.base)<=(alarm.radius+160)^2
end
local function DefenseCounterFit(platoon,front,view)
    view.counterFit=view.counterFit or {}
    local cache=view.counterFit[platoon]
    local geometry=platoon.ai.rushGeometry
    local count=Count(platoon)
    if not cache or cache.ai~=platoon.ai or cache.count~=count or cache.geometry~=geometry then
        cache={ai=platoon.ai,count=count,geometry=geometry,fronts={}};view.counterFit[platoon]=cache
    end
    local previous=cache.fronts[front.key]
    if previous then return previous.strength,previous.coverage end
    local strength,coverage=0,0
    for _,item in ipairs(geometry and geometry.points or {}) do
        local unit=item.unit
        if item.distance<=math.max(40,geometry.radius+item.range+16)
            and not unit.dead and not unit.deleted and unit.platoon==platoon and unit.army==platoon.army
            and not unit.CaptureInProgress and not unit.ReclaimInProgress
            and not (unit.ai and unit.ai.eState=="RepairHome")
            and not (unit.toggles and unit.GetPause and unit:GetPause()) then
            local canShoot,inRange,approach=false,false,math.huge
            for _,weapon in ipairs(unit.weapons or {}) do
                if weapon.enabled and not weapon.isDeathExplosion then
                    for _,target in ipairs(front.targets) do
                        if TargetValid(platoon,target.unit) and weapon:CanShootAt(target.unit) then
                            canShoot=true
                            if weapon:IsTargetInRange(target.unit) then inRange=true;break end
                            local range=weapon.tp and weapon.tp.rangeMax or item.range
                            approach=math.min(approach,math.max(0,math.sqrt(D2(item.pos,target.pos))-(range or 0)))
                        end
                    end
                end
                if inRange then break end
            end
            if canShoot then
                strength=strength+item.threat
                local speed=math.max(1,unit.tp.movement and unit.tp.movement.speed or 1)
                local eta=inRange and 0 or approach/speed
                -- Incoming orders reserve their side immediately, but an army
                -- forty seconds away cannot stand in for nearby base defense.
                local arrival=math.max(0.15,1/(1+math.max(0,eta-4)/8))
                coverage=coverage+item.threat*arrival
            end
        end
    end
    cache.fronts[front.key]={strength=strength,coverage=coverage}
    return strength,coverage
end
local function DefenseCoverage(platoon,view,now,observer)
    observer=observer or platoon.army
    local coverage={}
    for _,front in ipairs(view.fronts) do
        local fixed=0
        for _,entry in ipairs(front.fixedUnits or {}) do
            local unit=entry.unit;local data=unit.platoon and unit.platoon.ai
            if not unit.dead and not unit.deleted and unit.army==entry.owner and unit.platoon==entry.platoon
                and unit.army.ai==entry.armyAI and unit.ai==entry.unitAI and data==entry.platoonAI
                and (unit.army==observer or observer:IsAlly(unit.army))
                and not (data and (data.rushOperation or data.withdraw or data.eState=="Withdraw" or data.eState=="Disband"))
                and not (unit.ai and unit.ai.eState=="RepairHome")
                and not unit.CaptureInProgress and not unit.ReclaimInProgress
                and not (unit.toggles and unit.GetPause and unit:GetPause()) then fixed=fixed+entry.threat end
        end
        coverage[front.key]=fixed
    end
    local seen={}
    for _,army in pairs(Armies or {}) do
        if army==observer or observer:IsAlly(army) then
            local state=army.ai and army.ai.rushCombat
            for _,pool in ipairs({state and state.operations or {},state and state.supports or {}}) do
                for _,other in pairs(pool) do
                    if other~=platoon and not seen[other] and Live(other) then
                        seen[other]=true
                        local data=other.ai;local op=data and data.rushOperation
                        local geometry=data and data.rushGeometry
                        if op and geometry and now<(op.lastTick or 0)+4
                            and op.policy.phase~="Retreat" and not data.withdraw then
                            local claim=op.defenseClaim;local front
                            if claim and claim.ai==data and claim.armyAI==other.army.ai
                                and claim.operation==op and now<(claim.expires or 0) then
                                front=Front.DefenseMatch(view,claim)
                            end
                            local goal=op.goal
                            if not front and goal and goal.kind=="attack" and goal.unit then front=view.byUnit[goal.unit] end
                            if not front then
                                local distance
                                for _,candidate in ipairs(view.fronts) do
                                    local d=D2(geometry.position,candidate.pos)
                                    if d<=72^2 and (not distance or d<distance) then front,distance=candidate,d end
                                end
                            end
                            if front then
                                local _,arriving=DefenseCounterFit(other,front,view)
                                coverage[front.key]=(coverage[front.key] or 0)
                                    +math.min(math.max(0,geometry.own or 0),arriving)
                            end
                        end
                    end
                end
            end
        end
    end
    return coverage
end
local function DefenseOptions(platoon,g,now)
    local view=Front.Defense(platoon.army)
    local result={}
    if not DefenseEligible(platoon) or g.own<=0 or #view.fronts==0 then return result,view,{} end
    local coverage=DefenseCoverage(platoon,view,now)
    local op=platoon.ai.rushOperation
    local current=op and Front.DefenseMatch(view,op.defenseClaim)
    local ratio=(platoon.ai.formerTable.AIPlanData.AttackEnemyStrength or 105)/100
    for _,front in ipairs(view.fronts) do
        local threat=platoon.ai.formerTable.RushMainDefense and (front.landRaidThreat or 0) or front.threat
        local required=threat/math.max(0.1,ratio)*(front.emergency and 1.18 or 1.08)
        local supplied=coverage[front.key] or 0
        local deficit=required-supplied
        if DefenseEligible(platoon,front) and (not platoon.ai.formerTable.RushMainDefense
                or front.own and front.baseName=="MAIN" and front.landRaid)
            and deficit>math.max(front.emergency and 0.1 or 2,required*0.06)
            and DefenseCounterFit(platoon,front,view)>0 then
            local distance=math.sqrt(D2(g.position,front.pos))
            result[#result+1]={front=front,required=required,deficit=deficit,
                score=supplied/math.max(1,required)+distance/1000-front.urgency/math.max(1,front.threat)*0.12
                    -(front.emergency and 0.45 or 0)-(current==front and 0.12 or 0)}
        end
    end
    table.sort(result,function(a,b)
        if a.score~=b.score then return a.score<b.score end
        return a.front.key<b.front.key
    end)
    return result,view,coverage
end
-- The factory/base scheduler uses the same live reservations as movement.
-- Passing no requester counts every existing group, so new responders stop
-- consuming the idle pool as soon as the threatened MAIN side is covered.
function MainResponseRequired(army,attackRatio)
    if not army or not army.ai or not Front.MainAlarm(army).localRaid then return false end
    local view=Front.Defense(army);local coverage=DefenseCoverage(nil,view,Now(),army)
    local ratio=math.max(0.1,attackRatio or 1.05)
    for _,front in ipairs(view.fronts) do
        if front.own and front.baseName=="MAIN" and front.emergency and front.landRaid then
            local required=(front.landRaidThreat or 0)/ratio*1.18
            if required-(coverage[front.key] or 0)>math.max(0.1,required*0.06) then return true end
        end
    end
    return false
end
local function ReserveDefense(platoon,goal,g,now)
    local op=platoon.ai.rushOperation
    local claim=goal and goal.defense
    if not claim then op.defenseClaim=nil;op.defensePending=nil;return end
    local reserve=Front.DefenseClaim(claim)
    reserve.ai,reserve.armyAI,reserve.operation,reserve.expires=platoon.ai,platoon.army.ai,op,now+4
    op.defenseClaim=reserve;op.defensePending=true
    return reserve
end
local function RefreshDefense(platoon,g,now)
    local op=platoon.ai.rushOperation;local claim=op.defenseClaim
    if not claim then return end
    if claim.ai~=platoon.ai or claim.armyAI~=platoon.army.ai or claim.operation~=op or op.policy.phase=="Retreat"
        or not (op.defensePending or op.goal and op.goal.defense)
        or not Front.DefenseMatch(Front.Defense(platoon.army),claim) then
        op.defenseClaim=nil;op.defensePending=nil
    else claim.expires=now+4 end
end
local function SelectDefenseObjective(platoon,g,hooks,now,excluded)
    local options,view,coverage=DefenseOptions(platoon,g,now)
    local ai,op=platoon.ai,platoon.ai.rushOperation
    local ratio=(ai.formerTable.AIPlanData.AttackEnemyStrength or 105)/100
    for _,option in ipairs(options) do
        local front=option.front
        if front~=excluded and (not ai.formerTable.RushMainDefense or front.own and front.baseName=="MAIN")
            and not IsBlocked(op,front.pos,now)
            and MG.CanGraphAreaTo(g.position,front.pos,ai.movementLayer) then
            local shootable=false
            for _,candidate in ipairs(front.targets) do
                local unit=candidate.unit
                local allowed=TargetValid(platoon,unit) and not IsBlocked(op,candidate.pos,now) and hooks.CanShoot(platoon,unit)
                if not Live(platoon) or platoon.ai~=ai or ai.rushOperation~=op then return nil,view,coverage end
                if allowed and TargetValid(platoon,unit) then
                    shootable=true
                    local support=Intel.FriendlyThreat(platoon,candidate.pos,64,"Land")
                    local compatible=DefenseCounterFit(platoon,front,view)
                    local own=math.min(g.own,compatible)
                    if Intel.Exposure(platoon.army,candidate.pos,"Land",12).total<=(own+support)*ratio then
                        return {pos=Copy(candidate.pos),unit=unit,kind="attack",defense=Front.DefenseClaim(front)},view,coverage
                    end
                end
            end
            if shootable then
                local position=Front.DefensePosition(platoon,g,front)
                if position and not IsBlocked(op,position,now) then
                    return {pos=position,kind="defend",defense=Front.DefenseClaim(front)},view,coverage
                end
            end
        end
    end
    return nil,view,coverage
end
local function RegroupEligible(platoon)
    local former=platoon.ai.formerTable or {}
    return not platoon.ai.isNavalPlatoon and not former.RushMainDefense and not former.RushSiege
        and not former.RushBeachheadAssault and not platoon.ai.rushDefenseDetached and not IsRaider(former)
end
local function RegroupSafe(platoon,g,now)
    local op=platoon.ai.rushOperation;local goal=op.goal
    if not RegroupEligible(platoon) or op.policy.phase=="Retreat" or op.policy.phase=="Engage"
        or op.defenseClaim or goal and goal.defense or op.lastDamageAt and now-op.lastDamageAt<=3
        or not RegroupOrdersOwned(platoon) then return false end
    if goal and goal.kind~="stage" and goal.kind~="deploy" and goal.kind~="rally" then return false end
    if TargetValid(platoon,platoon.ai.microTarget) and Intel.InWeaponRange(g,platoon.ai.microTarget) then return false end
    local options=DefenseOptions(platoon,g,now)
    if #options>0 then return false end
    local friendly=Intel.FriendlyThreat(platoon,g.position,math.max(48,g.radius+32),"Land")
    return Intel.Exposure(platoon.army,g.position,"Land",g.radius+6).total<=math.max(1,g.own+friendly)*1.8
end
local function OfferAssault(platoon,g,candidate,now)
    local op=platoon.ai.rushOperation
    if not candidate or g.own<=0 or now<(op.assaultRetry or 0) or not RegroupSafe(platoon,g,now) then
        op.assaultOffer=nil;return
    end
    local old=op.assaultOffer
    if old and now>=old.expires then op.assaultOffer=nil;op.assaultRetry=now+20;return end
    if old and old.unit==candidate.unit and D2(old.pos,candidate.pos)<=FRONT_RADIUS^2 then
        old.pos=Copy(candidate.pos);old.guard=candidate.guard;old.safeUntil=now+4
        return
    end
    op.assaultOffer={unit=candidate.unit,pos=Copy(candidate.pos),guard=candidate.guard,
        armyAI=platoon.army.ai,platoonAI=platoon.ai,operation=op,expires=now+ASSAULT_SECONDS,safeUntil=now+4}
end

function SelectObjective(platoon,g,hooks,now,focus)
    local op=platoon.ai.rushOperation;local state=State(platoon.army)
    local candidates,claims={},{}
    local knownGround=false
    local offered=AssaultOfferCurrent(platoon,now)
    if offered and IsBlocked(op,offered.pos,now) then op.assaultOffer=nil;offered=nil end
    local survival=Pressure.SurvivalMap()
    local defense,defenseView,defenseCoverage
    if not focus then
        defense,defenseView,defenseCoverage=SelectDefenseObjective(platoon,g,hooks,now)
        if not Live(platoon) or platoon.ai.rushOperation~=op then return nil end
        if defense then op.assaultOffer=nil;return defense end
    end
    -- Temporary responders stay available at MAIN once its other side is
    -- covered. Normal combat formers resume ownership when the alarm clears.
    if platoon.ai.formerTable.RushMainDefense then return nil end
    local intel=Intel.Get(platoon.army)
    for _,other in pairs(state.operations) do
        local goal=Live(other) and other.ai.rushOperation and other.ai.rushOperation.goal
        if other~=platoon and goal and goal.unit then claims[goal.unit]=(claims[goal.unit] or 0)+1 end
    end
    for _,r in ipairs(intel.enemy) do
        local u=r.unit
        -- A real ground contact remains relevant even during its cooldown.
        -- Aircraft alone cannot suppress the native land scouting fallback.
        if TargetValid(platoon,u) then knownGround=true end
        local front=defenseView and defenseView.byUnit[u]
        local ratio=(platoon.ai.formerTable.AIPlanData.AttackEnemyStrength or 105)/100
        local covered=front and DefenseEligible(platoon,front)
            and (defenseCoverage[front.key] or 0)>=front.threat/math.max(0.1,ratio)*1.02
        if not covered and (not focus or D2(r.pos,focus)<=FRONT_RADIUS^2)
            and TargetValid(platoon,u) and not IsBlocked(op,r.pos,now) then
            local distance=math.sqrt(D2(g.position,r.pos))
            local value=u:HasTags(Tags.ECONOMIC) and 100 or u:HasTags(Tags.FACTORY) and 140 or 60
            if u:HasTags(Tags.COMMAND) then value=180 end
            -- Local base intrusion wins over a distant economic raid. This
            -- remains bounded to an actual known unit, not a sticky panic flag.
            local breach=front and DefenseEligible(platoon,front) or false
            if breach then value=value+240 end
            local penalty=(claims[u] or 0)*90
            candidates[#candidates+1]={unit=u,pos=r.pos,breach=survival and breach,
                regroup=offered~=nil and offered.unit==u,score=distance-value+penalty}
        end
    end
    local n=#candidates
    local offset=n>0 and not focus and not offered and (op.selectionOffset or 0)%n or 0
    -- RC20: the first page needs only the exact first twelve sorted entries.
    -- Still score EVERY candidate and keep the original total for rotation.
    -- Later pages retain the full sort, including wraparound and fallback.
    -- Small lists are cheaper to sort directly; this threshold changes only
    -- the lookup algorithm, never how many targets are inspected.
    if offset==0 and n>64 then
        local prefix=Selection.Top(candidates,12,ObjectiveLess)
        -- Native live IDs are unique, but preserve the original full-sort tie
        -- behaviour even for duplicate/stale IDs in a supplied enemy record set.
        -- Lua's sort is not stable: adding a new tie-break would change choices.
        local tied=false
        for i=2,#prefix do
            local a,b=prefix[i-1],prefix[i]
            if a.score==b.score and a.unit.id.index==b.unit.id.index then tied=true;break end
        end
        if not tied then
            local last=prefix[#prefix]
            for _,candidate in ipairs(candidates) do
                if candidate~=last and candidate.score==last.score
                    and candidate.unit.id.index==last.unit.id.index then tied=true;break end
            end
        end
        if tied then table.sort(candidates,ObjectiveLess) else candidates=prefix end
    else
        table.sort(candidates,ObjectiveLess)
    end
    local staging,resisted,approached
    for j=1,math.min(12,n) do
        local c=candidates[(offset+j-1)%n+1]
        if MG.CanGraphAreaTo(g.position,c.pos,platoon.ai.movementLayer) and hooks.CanShoot(platoon,c.unit) then
            local assessment=Intel.Exposure(platoon.army,c.pos,"Land",12)
            local guard=assessment.total
            local support=Intel.FriendlyThreat(platoon,c.pos,64,"Land",true)
            -- Only forces at this front can support the destination. Units
            -- left at home or heading elsewhere cannot fund a remote assault.
            local attacking=g.own+support
            if g.own>0 and guard<=attacking*((platoon.ai.formerTable.AIPlanData.AttackEnemyStrength or 105)/100) then
                op.selectionOffset=0;op.assaultOffer=nil
                return {pos=Copy(c.pos),unit=c.unit,kind="attack"}
            end
            resisted=resisted or {unit=c.unit,pos=Copy(c.pos),guard=guard}
            local front=Front.Remember(platoon.army,assessment,attacking)
            if not staging and front and g.nominal>0 then
                -- Base-wide threat is not a reason to run home. Find an actual
                -- reachable, clear firing/containment position outside return fire.
                staging=Front.Stage(platoon,g,assessment.staticUnit,assessment)
            end
            if not staging and not approached and not focus and not platoon.ai.formerTable.RushSiege then
                approached=true
                staging=Front.Approach(platoon,g,c.unit)
            end
        end
    end
    if not focus then op.selectionOffset=n>0 and (offset+12)%n or 0 end
    if focus then return nil end
    OfferAssault(platoon,g,resisted,now)
    if staging and platoon.ai.formerTable.RushSiege then return staging end
    if g.nominal>0 then
        op.visitedAlloy=op.visitedAlloy or {}
        local raids=Pressure.RaidCandidates(platoon.army,platoon.ai.basePosition,g.position,platoon.ai.movementLayer)
        local raidOffset=#raids>0 and (op.raidOffset or 0)%#raids or 0
        op.raidOffset=#raids>0 and (raidOffset+24)%#raids or 0
        for i=1,math.min(24,#raids) do
            local candidate=raids[(raidOffset+i-1)%#raids+1]
            local p=candidate.pos;local key=p.x..":"..p.z
            if now>=(op.visitedAlloy[key] or 0) and not IsBlocked(op,p,now)
                and not Front.Blocked(platoon.army,p,g.own) then
                local claimed=false
                for _,other in pairs(state.operations) do
                    local goal=other~=platoon and Live(other) and other.ai.rushOperation and other.ai.rushOperation.goal
                    if goal and goal.kind=="alloy-patrol" and D2(goal.pos,p)<35^2 then claimed=true;break end
                end
                if not claimed and MG.CanGraphAreaTo(g.position,p,platoon.ai.movementLayer)
                    and Intel.EnemyThreat(platoon.army,p,"Land",12,24)<=
                        (g.own+Intel.FriendlyThreat(platoon,p,64,"Land",true))
                        *((platoon.ai.formerTable.AIPlanData.AttackEnemyStrength or 105)/100) then
                    op.visitedAlloy[key]=now+120
                    return {pos=Copy(p),kind="alloy-patrol"}
                end
            end
        end
    end
    if staging then return staging end
    if Pressure.SurvivalMap() and g.nominal>0 and platoon.ai.basePosition
        and D2(g.position,platoon.ai.basePosition)>40^2
        and MG.CanGraphAreaTo(g.position,platoon.ai.basePosition,platoon.ai.movementLayer) then
        return {pos=Copy(platoon.ai.basePosition),kind="rally"}
    end
    if Front.Active(platoon.army) then
        local deploy=Front.Deploy(platoon,g)
        if deploy then return deploy end
    end
    -- Only probe the existing native active-enemy-base fallback when no known
    -- completed target exists. Never replace a defended target with a blind
    -- charge at that same base, nor treat unoccupied lobby slots as enemies.
    if not Pressure.SurvivalMap() and n==0 and not knownGround
        and now>=(op.nextProbe or 0) and g.nominal>0 then
        op.nextProbe=now+30
        local base=hooks.Fallback and hooks.Fallback(platoon)
        if base and not IsBlocked(op,base,now) and D2(base,g.position)>40*40 then
            return {pos=Copy(base),kind="probe"}
        end
    end
end

local function Clear(platoon,hooks)
    hooks.ClearFormation(platoon)
    if hooks.Stop then hooks.Stop(platoon) end
    platoon.ai.path=false;platoon.ai.rushMoving=false
    platoon.ai.rushOperation.pendingMove=nil;Budget.Cancel(platoon)
    platoon.ai.primaryTargetAreaPos=false
    for _,u in pairs(platoon:GetUnits()) do
        if not u.dead and not u.deleted and u.army==platoon.army and u.platoon==platoon and u.ai
            and u.ai.eState~="RepairHome" and not Movement.Suspended(u) then
            u.ai.path=false;u.ai.moveToDestinationReached=false;u.ai.eState="PlatoonControlled"
        end
    end
end
-- Check a fixed number of points on the native route before keeping an attack
-- order. Target exposure alone cannot reveal an overwhelming approach corridor.
local function AttackRouteSafe(platoon,path)
    if type(path)~="table" or #path==0 then return false end
    -- Native path generation may yield while units die or reinforcement arrives.
    local g=Intel.Geometry(platoon)
    platoon.ai.rushGeometry=g
    if g.own<=0 then return false end
    local checks=math.min(#path,6)
    for sample=1,checks do
        local index=checks==1 and 1 or math.floor((sample-1)*(#path-1)/(checks-1)+0.5)+1
        local pos=path[index]
        local enemy=Intel.EnemyThreat(platoon.army,pos,"Land",g.radius+6)
        if enemy>g.own*1.8 then
            local friendly=Intel.FriendlyThreat(platoon,pos,48,"Land")
            if enemy>math.max(1,g.own+friendly)*1.8 then return false end
        end
    end
    return true
end

local function StartMove(platoon,pos,aggressive,hooks,now,checkAttackRoute)
    local army,ai=platoon.army,platoon.ai
    local armyAI,op,layer=army.ai,ai.rushOperation,ai.movementLayer
    pos=Copy(pos)
    local g=ai.rushGeometry
    local nearby=Intel.FriendlyThreat(platoon,g.position,72,"Land",true)
    platoon.ai.withdraw=op.policy.phase=="Retreat"
    platoon.ai.rushPathThreat=aggressive and math.max(g.nominal,g.own+nearby)
        or math.max(g.nominal,platoon.ai.closeEnemyThreat or 0)
    local ok,reason=hooks.Move(platoon,pos,aggressive,false)
    if not Current(platoon,army,armyAI,ai,op) or ai.movementLayer~=layer then return false,"stale-request" end
    if ok==nil and reason=="path-budget" then
        op.pendingMove={pos=Copy(pos),aggressive=aggressive,checkAttackRoute=checkAttackRoute}
        op.moveGoal=Copy(pos)
        op.moveAggressive,op.moveCheckAttackRoute=aggressive,checkAttackRoute
        return nil -- deferred, not failed; the caller owns existing orders
    end
    op.pendingMove=nil
    if not ok then
        if reason~="stale-request" then Clear(platoon,hooks) end
        return false,reason or "path-failed"
    end
    if checkAttackRoute and not AttackRouteSafe(platoon,platoon.ai.path) then
        Clear(platoon,hooks)
        return false,"route-overmatched"
    end
    hooks.ClearFormation(platoon)
    platoon.ai.rushMoving=true
    op.moveGoal=Copy(pos);op.lastMoveAt=now;op.bestPathIndex=0
    op.moveAggressive,op.moveCheckAttackRoute=aggressive,checkAttackRoute
    op.progressPosition=Copy(Position(platoon))
    for _,u in pairs(platoon:GetUnits()) do
        if not u.dead and not u.deleted and u.army==platoon.army and u.platoon==platoon and u.ai
            and u.ai.eState~="RepairHome" and not Movement.Suspended(u) then u.ai.eState="PlatoonControlled" end
    end
    return true
end

local function ResolvePending(platoon,hooks)
    local op=platoon.ai.rushOperation
    if not op.pendingMove then return end
    local pending=op.pendingMove
    local ok,reason=StartMove(platoon,pending.pos,pending.aggressive,hooks,Now(),pending.checkAttackRoute)
    if ok==false and reason~="stale-request" and Live(platoon) and platoon.ai.rushOperation==op then
        Reject(platoon,pending.pos,Now());op.goal=nil;op.defenseClaim=nil;op.defensePending=nil
        Policy.Hold(op.policy,Now(),reason or "path-failed")
    end
end
local function MoveUnits(platoon,g,hooks)
    local army,ai=platoon.army,platoon.ai
    local armyAI,op=army.ai,ai.rushOperation
    ResolvePending(platoon,hooks)
    if not Current(platoon,army,armyAI,ai,op) then return end
    local goal=op.moveGoal
    if not goal or not platoon.ai.rushMoving or op.pendingMove then return end
    for _,item in ipairs(g.points) do
        local u=item.unit
        if not Current(platoon,army,armyAI,ai,op) then return end
        if not u.dead and not u.deleted and u.army==army and u.platoon==platoon and u.ai
            and not Movement.Suspended(u) then
            local unitAI=u.ai
            if unitAI.eState=="MoveToPlatoonCenter" and hooks.Join then
                local state=hooks.Join(u,platoon)
                if not Current(platoon,army,armyAI,ai,op) or u.ai~=unitAI or u.platoon~=platoon then return end
                unitAI.eState=state
                if state=="PlatoonControlled" and hooks.ResumeUnit then
                    local accepted,reason=hooks.ResumeUnit(u,platoon,goal)
                    if not Current(platoon,army,armyAI,ai,op) then return end
                    if not accepted and QueueResumeRetry(platoon,reason) then return end
                end
            elseif unitAI.eState==nil and hooks.JoinInit then
                local state=hooks.JoinInit(u,platoon)
                if not Current(platoon,army,armyAI,ai,op) or u.ai~=unitAI or u.platoon~=platoon then return end
                unitAI.eState=state
            else hooks.MoveUnit(u,goal) end
        end
    end
end
local function Reached(g,pos)
    if not pos then return true end
    local arrived=0
    for _,item in ipairs(g.points) do if D2(item.pos,pos)<=30*30 then arrived=arrived+1 end end
    return arrived>=math.max(1,math.ceil(g.count*0.70))
end
local function ObserveProgress(platoon,g,now)
    local op=platoon.ai.rushOperation
    -- Displacement is real progress through a winding native path. Merely
    -- refreshing orders or receiving more units must not reset the watchdog.
    local moved=0
    for _,item in ipairs(g.points) do
        local health=item.unit:GetHealth()
        local previousHealth=op.unitHealth[item.unit]
        if previousHealth and health<previousHealth then op.lastDamageAt=now end
        op.unitHealth[item.unit]=health
        local previous=op.unitPositions[item.unit]
        if previous and D2(previous,item.pos)>=4*4 then moved=moved+1;op.unitPositions[item.unit]=Copy(item.pos)
        elseif not previous then op.unitPositions[item.unit]=Copy(item.pos) end
    end
    if moved>=math.max(1,math.ceil(g.count*0.35)) then Policy.Progress(op.policy,now) end
    for u in pairs(op.unitPositions) do
        if u.dead or u.platoon~=platoon then
            if u.dead then op.lastDamageAt=now end
            op.unitPositions[u]=nil;op.unitHealth[u]=nil
        end
    end
end
local function Retreat(platoon,g,hooks,now)
    local army,ai=platoon.army,platoon.ai
    local armyAI,op=army.ai,ai.rushOperation;local goal=op.goal
    local exposure=op.exposure or Intel.Exposure(platoon.army,g.position,"Land",g.radius+6)
    Front.Remember(platoon.army,exposure,g.own+(platoon.ai.nearbyFriendlyThreat or 0))
    local target=platoon.ai.microTarget
    Reject(platoon,goal and goal.pos or (TargetValid(platoon,target) and target:GetPosition()),now)
    -- Stop the old attack immediately, even if the retreat path must wait for a slot.
    op.goal=nil;op.defenseClaim=nil;op.defensePending=nil
    platoon.ai.microTarget=false;Clear(platoon,hooks)
    -- Retreat away from the observed threat, NOT invariably toward MAIN. This
    -- also avoids sending a flanking force back through the enemy to reach home.
    local home=platoon.ai.basePosition
    local center=exposure.center
    local dx,dz=center and g.position.x-center.x or home.x-g.position.x,
        center and g.position.z-center.z or home.z-g.position.z
    local d=math.sqrt(dx*dx+dz*dz)
    if d<1 then dx,dz,d=1,0,1 end
    local best,score
    for _,direction in ipairs(RETREAT_DIRECTIONS) do
        local cosine,sine=direction[1],direction[2]
        local x,z=dx/d*cosine-dz/d*sine,dx/d*sine+dz/d*cosine
        local length=math.min(C.RetreatDistance,math.max(36,d))
        local p=AF.GetPositionWithinPlayableArea({x=g.position.x+x*length,y=g.position.y,z=g.position.z+z*length})
        if D2(g.position,p)>12*12 and Intel.ClearRendezvous(platoon.army,p,10)
            and MG.CanGraphAreaTo(g.position,p,platoon.ai.movementLayer) then
            local threat=Intel.Exposure(platoon.army,p,"Land",g.radius+6).total
            local value=threat
            -- Prefer an equally safe flank rather than the crowded factory core.
            if D2(home,p)<48^2 then value=value+math.max(1,g.own)*0.1 end
            if not score or value<score then best,score=Copy(p),value end
        end
    end
    State(platoon.army).stats.retreats=State(platoon.army).stats.retreats+1
    if best then
        local ok=StartMove(platoon,best,false,hooks,now)
        if not Current(platoon,army,armyAI,ai,op) or ok~=false then return end
    end
    Policy.Hold(op.policy,now,"no-safe-route")
end

local function AdoptGoal(platoon,goal,hooks,now,input)
    local army,ai=platoon.army,platoon.ai
    local armyAI,op=army.ai,ai.rushOperation
    local defensive=goal.kind=="stage" or goal.kind=="siege" or goal.kind=="deploy" or goal.kind=="rally" or goal.kind=="defend"
    -- A distant objective can look weak while survivors remain under stronger
    -- local fire. Wait for reinforcements or a safer objective before attacking.
    if not defensive and input.enemy>0 and not Policy.CanEngage(op.policy,input,false) then
        return false,"local-threat"
    end
    local previousClaim=op.defenseClaim
    local reserve=ReserveDefense(platoon,goal,platoon.ai.rushGeometry,now)
    if defensive and Reached(platoon.ai.rushGeometry,goal.pos) then
        if platoon.ai.rushMoving then Clear(platoon,hooks) end
        op.goal=goal;op.moveGoal=Copy(goal.pos);op.defensePending=nil
        Policy.Hold(op.policy,now,goal.kind=="defend" and "defense-cover" or "containment")
        return true
    end
    local accepted,reason=StartMove(platoon,goal.pos,not defensive,hooks,now,not defensive or goal.approach==true)
    if not Current(platoon,army,armyAI,ai,op) then return false,"stale-request" end
    if accepted~=false then
        op.goal=goal;op.defensePending=nil;Policy.GoalStarted(op.policy,now)
        if reserve and (not previousClaim or previousClaim.key~=reserve.key) then op.defenseChangedAt=now end
        local distance=0;local previous=Position(platoon)
        for _,node in ipairs(not op.pendingMove and platoon.ai.path or {goal.pos}) do
            distance=distance+math.sqrt(D2(previous,node));previous=node
        end
        op.goalDeadline=now+math.min(900,math.max(120,distance*2+60))
        platoon.ai.primaryTargetAreaPos=goal.pos
        State(platoon.army).stats.goals=State(platoon.army).stats.goals+1
        return true
    end
    if op.defenseClaim==reserve then op.defenseClaim=previousClaim;op.defensePending=nil end
    if reason~="stale-request" then Reject(platoon,goal.pos,now) end
    return false,reason
end

local function DetachSupport(platoon)
    local op=platoon.ai.rushOperation
    if not op.supportSince then return end
    Unregister(platoon);Register(platoon,false)
    op.supportSince=nil;op.assaultReceiverOffer=nil;op.detached=true;platoon.ai.rushReceiver=nil
    State(platoon.army).stats.detached=State(platoon.army).stats.detached+1
end
local function EndAssaultSupport(platoon,hooks,now)
    local ai,op=platoon.ai,platoon.ai.rushOperation
    local owned=RegroupOrdersOwned(platoon)
    DetachSupport(platoon)
    if owned then Clear(platoon,hooks);Policy.Acquire(op.policy,now)
    else
        op.assaultYield=true;op.pendingMove=nil;ai.rushMoving=false
        Policy.Hold(op.policy,now,"newer-orders")
    end
end
local function Micro(platoon,g,hooks,input,previous)
    local army,ai=platoon.army,platoon.ai
    local armyAI,op=army.ai,ai.rushOperation
    if op.assaultReceiverOffer then DetachSupport(platoon) end
    platoon.ai.withdraw=false;platoon.ai.eState="MicroingPlatoon"
    if previous~="Engage" then
        Clear(platoon,hooks);platoon.ai.microTarget=input.target
    end
    local nativeState=hooks.Micro(platoon)
    if not Current(platoon,army,armyAI,ai,op) then return false end
    if nativeState=="WithdrawInit" then
        DetachSupport(platoon)
        Policy.Retreat(op.policy,input,"micro-threat")
        Retreat(platoon,g,hooks,Now())
    elseif nativeState=="SelectMainTarget" then
        Clear(platoon,hooks);platoon.ai.microTarget=false
        op.resumeMission=op.goal~=nil
        Policy.Acquire(op.policy,Now())
    end
    return true
end
local function SupportTick(platoon,g,hooks,now)
    local army,ai=platoon.army,platoon.ai
    local armyAI,op=army.ai,ai.rushOperation
    local promised=op.assaultReceiverOffer
    local receiver
    if promised then
        receiver=ai.rushReceiver
        local ready=Live(receiver) and AssaultOfferCurrent(receiver,now)==promised
            and RegroupSafe(receiver,receiver.ai.rushGeometry or Intel.Geometry(receiver),now)
            and RegroupSafe(platoon,g,now) and AvailableRoom(army,receiver,platoon)>0
        if not ready then EndAssaultSupport(platoon,hooks,now);return false end
    else receiver=SupportReceiver(platoon) end
    if receiver then
        local receiverAI,receiverOp=receiver.ai,receiver.ai.rushOperation
        Transfer(platoon,receiver,hooks)
        if not Current(platoon,army,armyAI,ai,op) then return true end
        -- Receiver-unit resumes can yield after physical transfer. A remaining
        -- donor's newer native order must survive the next clear/repath too.
        if promised and (not Current(receiver,army,armyAI,receiverAI,receiverOp)
            or AssaultOfferCurrent(receiver)~=promised or not RegroupOrdersOwned(platoon)
            or not RegroupOrdersOwned(receiver)) then
            EndAssaultSupport(platoon,hooks,Now());return false
        end
        if not Current(receiver,army,armyAI,receiverAI,receiverOp) then
            ai.rushReceiver=nil;DetachSupport(platoon);Clear(platoon,hooks);Policy.Acquire(op.policy,Now())
            return false
        end
        local p=Copy(Position(receiver))
        if (not op.moveGoal or D2(op.moveGoal,p)>32*32 or not platoon.ai.rushMoving)
            and now>=(op.nextSupportPath or 0) then
            op.nextSupportPath=now+8
            if StartMove(platoon,p,true,hooks,now) then op.policy.lastProgressAt=op.policy.lastProgressAt or now end
        end
        if not Current(platoon,army,armyAI,ai,op) then return true end
        MoveUnits(platoon,g,hooks)
        if not Current(platoon,army,armyAI,ai,op) then return true end
    end
    if not receiver or now-op.supportSince>=150 or now-op.policy.lastProgressAt>=C.AbandonSeconds then
        -- The SAME coroutine keeps its own units. No orphaned support and no
        -- out-of-band stealing from another running platoon.
        if promised then EndAssaultSupport(platoon,hooks,Now())
        else DetachSupport(platoon);Clear(platoon,hooks);Policy.Acquire(op.policy,now) end
        return false
    end
    platoon.ai.eState="MoveToPrimaryPlatoon"
    return true
end

-- Only the running owner may split its own idle/advancing core. This keeps a
-- large early primary from being the sole indivisible answer to two flanks.
-- A minority leaves, at most four such native platoons exist, and units already
-- firing, retreating, repairing, captured or controlled elsewhere never transfer.
local function SplitDefense(platoon,g,hooks,input,now)
    local op=platoon.ai.rushOperation
    if not DefenseEligible(platoon) or op.supportSince or op.defenseDetached or g.count<12
        or input.contact or input.underFire or op.policy.phase=="Engage" or op.policy.phase=="Retreat"
        or now<(op.nextDefenseSplit or 0) then return false end
    local options,view,coverage=DefenseOptions(platoon,g,now)
    if #view.fronts<2 then return false end
    op.nextDefenseSplit=now+4
    local state=State(platoon.army);Prune(state)
    local detached=0
    for _,other in pairs(platoon.army.platoons or {}) do
        if Live(other) and other.ai and other.ai.rushDefenseDetached then detached=detached+1 end
    end
    if detached>=4 then return false end
    local current=Front.DefenseMatch(view,op.defenseClaim)
        or (op.goal and op.goal.unit and view.byUnit[op.goal.unit])
    if not current then
        local distance
        for _,front in ipairs(view.fronts) do
            local d=D2(g.position,front.pos)
            if not distance or d<distance then current,distance=front,d end
        end
    end
    local destination
    for _,option in ipairs(options) do
        if option.front~=current and D2(option.front.pos,current.pos)>60^2
            and MG.CanGraphAreaTo(g.position,option.front.pos,platoon.ai.movementLayer) then destination=option;break end
    end
    if not destination then return false end
    local ratio=(platoon.ai.formerTable.AIPlanData.AttackEnemyStrength or 105)/100
    local retained=math.max(g.own*0.55,current.threat/math.max(0.1,ratio)*1.08-(coverage[current.key] or 0))
    local allowance=math.min(g.own-retained,destination.deficit*1.15)
    if allowance<=0 then return false end
    local candidates={}
    for _,item in ipairs(g.points) do
        local unit=item.unit
        if item.distance<=math.max(40,g.radius+16) and unit.army==platoon.army and unit.platoon==platoon
            and not unit.dead and not unit.deleted and not unit.CaptureInProgress and not unit.ReclaimInProgress
            and not unit:HasTags(Tags.ENGINEER+Tags.COMMAND+Tags.TECH4) and not HeavyPolicy.IsT4(unit.tp)
            and not (unit.toggles and unit.GetPause and unit:GetPause())
            and not (unit.ai and unit.ai.eState=="RepairHome") and OwnedMovementOrIdle(unit,platoon) then
            local damaging=false
            for _,weapon in ipairs(unit.weapons or {}) do
                if weapon.enabled and not weapon.isDeathExplosion then
                    for _,target in ipairs(destination.front.targets) do
                        if TargetValid(platoon,target.unit) and weapon:CanShootAt(target.unit) then damaging=true;break end
                    end
                end
                if damaging then break end
            end
            candidates[#candidates+1]={unit=unit,threat=item.threat,damage=damaging,
                distance=D2(item.pos,destination.front.pos),id=unit.id.index}
        end
    end
    table.sort(candidates,RecruitDamageLess)
    local chosen,threat,damage={},0,0
    local maximum=math.min(24,math.floor(g.count*0.45))
    for _,item in ipairs(candidates) do
        if #chosen>=maximum then break end
        if threat+item.threat<=allowance and (item.damage or damage>=2) then
            chosen[#chosen+1]=item.unit;threat=threat+item.threat
            if item.damage then damage=damage+1 end
        end
    end
    if #chosen<4 or damage<2 or threat<=0 then return false end
    local ai=platoon.ai
    local former={};for key,value in pairs(ai.formerTable) do former[key]=value end
    local plan={};for key,value in pairs(former.AIPlanData or {}) do plan[key]=value end
    former.AIPlanData=plan;former.FormerName="F123 Land Defense Detachment"
    former.RushIndependent=true;former.RushSupportCap=nil;former.RushSupportPrimary=nil
    plan.RushUnitLimit=24;plan.IgnoreLandEmergencyTargets=false
    local child=platoon.army:CreatePlatoon(former.FormerName)
    child.ai={formerTable=former,baseName=ai.baseName,basePosition=Copy(ai.basePosition),baseRadius=ai.baseRadius,
        creationTime=GetFormatedGameTime(),targetLayer="Land",isNavalPlatoon=false,ignoreLandEmergencyTargets=false,
        approachingPlatoons={},mergingPlatoons={},gatherPoint=false,primaryTargetAreaPos=false,
        rushDefenseSeed=Front.DefenseClaim(destination.front),rushDefenseDetached=true}
    local childAI=child.ai
    child:AssignUnits(chosen)
    for _,unit in ipairs(chosen) do
        if unit.platoon==child and not unit.dead then
            hooks.ResetUnit(unit,"RushDefenseDetachment");unit.ai=unit.ai or {};unit.ai.eState="PlatoonControlled"
        end
    end
    child.ai.movementLayer=Movement.MovementLayer(child)
    platoon.ai.movementLayer=Movement.MovementLayer(platoon)
    platoon.ai.rushGeometry=Intel.Geometry(platoon)
    child:StartAIFunction(function(p)
        local ok,err=pcall(Run,p,hooks,false)
        if not ok and p.ai==childAI then
            Unregister(p)
            if Live(p) then hooks.Exit(p) end
            Warn("AI-Scom defense detachment: "..tostring(err))
        end
    end)
    state.stats.defenseSplits=(state.stats.defenseSplits or 0)+1
    return true
end

-- A blocked donor joins through its own existing controller. Only a local,
-- exact offered receiver gains members, and native transfer waits for arrival.
local function RegroupAssault(platoon,g,hooks,now)
    local ai,army=platoon.ai,platoon.army;local op=platoon.ai.rushOperation
    if op.supportSince or now<(op.nextAssaultRegroup or 0) or not RegroupSafe(platoon,g,now) then return false end
    op.nextAssaultRegroup=now+4
    local own=AssaultOfferCurrent(platoon,now)
    if not own and (op.goal or not op.idleSince or now-op.idleSince<20) then return false end
    local state=State(army);Prune(state)
    local reserved=Reservations(state,platoon);local candidates={}
    for _,other in pairs(state.operations) do
        -- Offered receivers elect one direction. A targetless donor has no
        -- receiving offer, so it can also join a newer useful offensive core.
        local candidate=other~=platoon and (not own or other.id<platoon.id) and AssaultOfferCurrent(other,now)
        local geometry=candidate and other.ai.rushGeometry
        if candidate and geometry and Capacity(other)-(reserved[other] or 0)>=math.min(6,g.count)
            and (not own or own.unit==candidate.unit or D2(own.pos,candidate.pos)<=FRONT_RADIUS^2)
            and D2(g.position,geometry.position)<=ASSAULT_RADIUS^2 then
            candidates[#candidates+1]={platoon=other,offer=candidate,geometry=geometry}
        end
    end
    -- Rank without native reads, then recheck only a bounded few receivers.
    -- Many held waves must not multiply the full defense/exposure scan.
    local receiver,offer
    for _,candidate in ipairs(Selection.Top(candidates,3,function(a,b) return a.platoon.id<b.platoon.id end)) do
        local other=candidate.platoon
        if RegroupSafe(other,candidate.geometry,now)
            and MG.CanGraphAreaTo(g.position,candidate.geometry.position,ai.movementLayer) then
            receiver,offer=other,candidate.offer;break
        end
    end
    if not receiver then return false end
    local armyAI=army.ai
    if not Current(platoon,army,armyAI,ai,op) or AssaultOfferCurrent(receiver)~=offer
        or not RegroupOrdersOwned(platoon) then return false end
    Unregister(platoon);Register(platoon,true)
    ai.rushReceiver=receiver;op.assaultReceiverOffer=offer;op.assaultOffer=nil
    op.supportSince=now;op.policy.lastProgressAt=now;op.nextSupportPath=nil;op.goal=nil
    Clear(platoon,hooks);Policy.Acquire(op.policy,now)
    SupportTick(platoon,g,hooks,now)
    return Current(platoon,army,armyAI,ai,op)
end

function Initialize(platoon,hooks,support)
    local now=Now()
    platoon.ai.rushOperation={policy=Policy.New(now),blocked={},unitPositions={},unitHealth={},supportSince=support and now or nil}
    local operation=platoon.ai.rushOperation
    operation.lastTick=now
    platoon.ai.approachingPlatoons=platoon.ai.approachingPlatoons or {}
    platoon.ai.mergingPlatoons=platoon.ai.mergingPlatoons or {}
    Register(platoon,support)
    local g=Intel.Geometry(platoon);platoon.ai.rushGeometry=g
    platoon.ai.threat=g.nominal
    operation.defenseDetached=platoon.ai.rushDefenseDetached==true
    local seed=platoon.ai.rushDefenseSeed;platoon.ai.rushDefenseSeed=nil
    if not seed and platoon.ai.formerTable.RushMainDefense then
        local options=DefenseOptions(platoon,g,now)
        for _,option in ipairs(options) do
            if option.front.own and option.front.baseName=="MAIN" then seed=Front.DefenseClaim(option.front);break end
        end
        -- No formation timer may keep freshly available home defenders idle.
        Policy.Acquire(operation.policy,now)
    end
    if seed and Front.DefenseMatch(Front.Defense(platoon.army),seed) then
        operation.goal={pos=Copy(g.position),kind="defend",defense=seed}
        ReserveDefense(platoon,operation.goal,g,now);operation.defensePending=nil
        Policy.Acquire(operation.policy,now)
    end
    -- Local gathering, never a trip to a fixed, map-centre rally point.
    if not support and not platoon.ai.formerTable.RushMainDefense and not Reached(g,g.position) then
        StartMove(platoon,g.position,false,hooks,now)
    end
    return operation
end

-- Refill physically adjacent understrength operations from the unassigned
-- pool, even when former instance limits are occupied. No waiting for a minimum
-- wave, no taking another platoon's units, and no restarting the receiver path.
local function Refill(platoon,g,hooks,now)
    local army,ai=platoon.army,platoon.ai
    local armyAI,op,former=army.ai,ai.rushOperation,ai.formerTable
    if op.supportSince or IsRaider(former) or op.policy.phase=="Retreat"
        or now<(op.nextRefill or 0) or Capacity(platoon)==0 then return false end
    op.nextRefill=now+5
    local room=AvailableRoom(platoon.army,platoon);local units={}
    if room==0 then return false end
    local need=former.NeedUnits and former.NeedUnits[1] and former.NeedUnits[1][1]
    local protected={}
    local beachhead=Import("AI/mods/AI-Scom/RushBeachhead.lua")
    for name,base in pairs(army.ai.bases or {}) do
        if D2(g.position,base.position)<=((base.radius or 64)+40)^2 and beachhead.BaseConnected(army,name) then
            local defenders={}
            for _,u in ipairs(Intel.FriendlyUnitsInRadius(army,base.position,base.radius or 64)) do
                if u.army==army and army.units[u.id.index]==u and not u.dead and not u.deleted and not u.platoon
                    and u:IsCompleted() and not u.CaptureInProgress and not u.ReclaimInProgress
                    and u:HasTags(Tags.MOBILE*Tags.LAND-Tags.ENGINEER-Tags.COMMAND-Tags.SCOUT-Tags.TECH4)
                    and not HeavyPolicy.IsT4(u.tp)
                    and not (u.toggles and u.GetPause and u:GetPause())
                    and not (u.ai and u.ai.eState=="RepairHome")
                    and not (army.ai.ecoReserve and army.ai.ecoReserve[u.id.index])
                    and (not u.assignedToBase or u.assignedToBase==name)
                    and (AF.GetUnitThreatValueByLayer(u,"Land",false) or 0)>0
                    and MG.CanGraphAreaTo(u:GetPosition(),base.position,"Land") then
                    defenders[#defenders+1]={unit=u,id=u.id.index,distance=D2(u:GetPosition(),base.position)}
                end
            end
            for _,r in ipairs(Selection.Top(defenders,2,RecruitDistanceLess)) do protected[r.unit]=true end
        end
    end
    for _,u in ipairs(Intel.FriendlyUnitsInRadius(platoon.army,g.position,40)) do
        if not protected[u] and u.army==platoon.army and army.units[u.id.index]==u
            and not u.dead and not u.deleted and not u.platoon and u:IsCompleted()
            and u:HasTags(Tags.MOBILE*Tags.LAND-Tags.ENGINEER-Tags.COMMAND-Tags.SCOUT-Tags.TECH4)
            and not HeavyPolicy.IsT4(u.tp)
            and (not need or u:HasTags(need)) and not (u.ai and u.ai.eState=="RepairHome")
            and not u.CaptureInProgress and not u.ReclaimInProgress and not (u.toggles and u.GetPause and u:GetPause())
            and not (platoon.army.ai.ecoReserve and platoon.army.ai.ecoReserve[u.id.index])
            and (not u.assignedToBase or u.assignedToBase==platoon.ai.baseName)
            and D2(u:GetPosition(),g.position)<=40^2
            and MG.CanGraphAreaTo(u:GetPosition(),g.position,platoon.ai.movementLayer) then units[#units+1]=u end
    end
    units=SelectRecruits(units,room,g.position,platoon)
    if #units==0 or not Current(platoon,army,armyAI,ai,op) then return false end
    platoon:AssignUnits(units)
    for _,u in ipairs(units) do
        if u.platoon==platoon and not u.dead then
            hooks.ResetUnit(u,"RushPoolRefill");u.ai=u.ai or {};u.ai.eState="PlatoonControlled"
        end
    end
    local sameLayer=RefreshMovementLayer(platoon)
    local state=State(army);state.stats.poolRefills=(state.stats.poolRefills or 0)+#units
    for _,u in ipairs(units) do
        if not Current(platoon,army,armyAI,ai,op) then return false end
        if sameLayer and ai.rushMoving and op.moveGoal and hooks.ResumeUnit
            and not u.dead and not u.deleted and u.army==army and u.platoon==platoon then
            local accepted,reason=hooks.ResumeUnit(u,platoon,op.moveGoal)
            if not Current(platoon,army,armyAI,ai,op) then return false end
            if not accepted and QueueResumeRetry(platoon,reason) then break end
        end
    end
    return Current(platoon,army,armyAI,ai,op)
end

function Tick(platoon,hooks)
    if not Live(platoon) then return false end
    local now=Now();local army,ai=platoon.army,platoon.ai
    local armyAI,op=army.ai,ai.rushOperation
    op.lastTick=now
    ai.withdraw=op.policy.phase=="Retreat"
    if op.assaultReceiverOffer and not RegroupOrdersOwned(platoon) then
        EndAssaultSupport(platoon,hooks,now);return true
    end
    if op.assaultYield then
        if not RegroupOrdersOwned(platoon) then return true end
        op.assaultYield=nil;Clear(platoon,hooks);Policy.Acquire(op.policy,now)
    end
    local g=Intel.Geometry(platoon);platoon.ai.rushGeometry=g
    if g.count==0 then return false end
    local refilled=Refill(platoon,g,hooks,now)
    if not Current(platoon,army,armyAI,ai,op) then return false end
    if refilled then g=Intel.Geometry(platoon);ai.rushGeometry=g end
    ObserveProgress(platoon,g,now)
    RefreshDefense(platoon,g,now)
    local target=NearTarget(platoon,g,hooks)
    local exposure=Intel.Exposure(platoon.army,g.position,"Land",g.radius+6)
    op.exposure=exposure
    local enemy=exposure.total
    if ai.formerTable.RushMainDefense and not Front.MainAlarm(army).localRaid and not target
        and not (op.lastDamageAt and now-op.lastDamageAt<=3) then
        local remaining=enemy
        if remaining>0 then
            -- This only releases an ended temporary mission. Normal combat
            -- exposure/retreat still counts every gun, including distant siege.
            remaining=Intel.EnemyThreat(army,g.position,"Land",g.radius+6,0,function(unit,position)
                return Front.IsStrategicArtillery(unit) and D2(g.position,position)>(128+g.radius)^2
            end)
        end
        if remaining==0 then return false end
    end
    local friendly=Intel.FriendlyThreat(platoon,g.position,math.max(48,g.radius+32),"Land")
    local idle=not op.supportSince and not op.goal and (op.policy.phase=="Hold" or op.policy.phase=="Acquire")
    op.idleSince=idle and (op.idleSince or now) or nil
    if op.assaultOffer then
        if now>=op.assaultOffer.expires then op.assaultOffer=nil;op.assaultRetry=now+20
        elseif not RegroupSafe(platoon,g,now) or not Intel.Visible(army,op.assaultOffer.unit) then op.assaultOffer=nil
        else op.assaultOffer.safeUntil=now+4 end
    end
    -- Locally consolidate depleted waves instead of filling all operation slots
    -- with permanent tiny remnants. Fresh independent waves deploy first;
    -- aged targetless groups can also regroup after a real idle interval.
    local independent = platoon.ai.formerTable.RushIndependent or IsRaider(platoon.ai.formerTable)
    local depletedIndependent = independent and g.count<3
        and (op.policy.lastTargetAt or op.policy.retreats>0)
    local agedIndependent=independent and not IsRaider(ai.formerTable) and op.idleSince and now-op.idleSince>=30
    if not op.supportSince and #Front.Defense(platoon.army).fronts<2 and g.count<6 and not target
        and enemy<=math.max(1,g.own+friendly)*0.60 and not (op.lastDamageAt and now-op.lastDamageAt<=3)
        and RegroupOrdersOwned(platoon) and (not independent or depletedIndependent or agedIndependent)
        and op.policy.phase~="Retreat" and now>=(op.nextConsolidate or 0) then
        op.nextConsolidate=now+30
        local receiver=SupportReceiver(platoon)
        if receiver and (Count(receiver)>=6 or receiver.id<platoon.id)
            and D2(g.position,Position(receiver))<=240*240 then
            Unregister(platoon);Register(platoon,true)
            platoon.ai.rushReceiver=receiver;op.supportSince=now
            -- This is a new local consolidation job, not another extension of
            -- an existing chase. An old idle timer must not disband its units.
            op.policy.lastProgressAt=now
            if SupportTick(platoon,g,hooks,now) then return Live(platoon) end
        end
        platoon.ai.rushReceiver=nil
    end
    platoon.ai.threat,platoon.ai.closeEnemyThreat=g.nominal,enemy
    platoon.ai.nearbyFriendlyThreat=friendly
    platoon.ai.microTarget=target or false
    local goal=op.goal
    local goalValid=goal and (not goal.unit or TargetValid(platoon,goal.unit))
        and (not goal.defense or Front.DefenseMatch(Front.Defense(platoon.army),goal.defense)) or false
    if goal and goal.defense and not goalValid and op.policy.phase=="Hold" then Policy.Acquire(op.policy,now) end
    local input={now=now,count=g.count,own=g.own,friendly=friendly,enemy=enemy,
        nearTarget=target and true or false,contact=target and Intel.InWeaponRange(g,target) or false,
        target=target,targetDistance=target and math.sqrt(D2(g.position,target:GetPosition())) or nil,
        underFire=op.lastDamageAt and now-op.lastDamageAt<=3 or false,
        arrived=Reached(g,op.moveGoal),goalValid=goalValid,pathPending=op.pendingMove~=nil,
        attackRatio=(platoon.ai.formerTable.AIPlanData.AttackEnemyStrength or 105)/100,
        primary=platoon.ai.formerTable.FormerName=="F123 Land Primary",
        raider=IsRaider(platoon.ai.formerTable)==true,
        goalMoved=goalValid and goal.kind=="attack" and goal.unit
            and D2(goal.pos,goal.unit:GetPosition())>32^2 or false,
        goalExpired=goal and op.goalDeadline and now>=op.goalDeadline or false}
    if SplitDefense(platoon,g,hooks,input,now) then return true end
    if DefenseEligible(platoon) and op.policy.phase~="Retreat" and not input.contact and not input.underFire
        and now>=(op.nextDefenseCheck or 0) then
        op.nextDefenseCheck=now+1
        local replacement=SelectDefenseObjective(platoon,g,hooks,now)
        if not Current(platoon,army,armyAI,ai,op) then return false end
        local oldFront=goal and goal.defense and Front.DefenseMatch(Front.Defense(platoon.army),goal.defense)
        local newFront=replacement and Front.DefenseMatch(Front.Defense(platoon.army),replacement.defense)
        local changed=replacement and (op.supportSince or not oldFront or oldFront~=newFront
            or goal.kind=="defend" and replacement.kind=="attack")
        if changed and (not oldFront or not goalValid or newFront and newFront.emergency and not oldFront.emergency
            or now>=(op.defenseChangedAt or 0)+4) then
            local wasSupport=op.supportSince
            if wasSupport then DetachSupport(platoon) end
            local accepted,blocked=AdoptGoal(platoon,replacement,hooks,now,input)
            if not Current(platoon,army,armyAI,ai,op) then return false end
            if accepted then
                op.lastAction,op.lastReason="redirect","defense-front"
                platoon.ai.eState=STATE_NAMES[op.policy.phase]
                if hooks.Report then hooks.Report(platoon,op.policy.phase,"defense-front") end
                return true
            elseif blocked=="stale-request" then return true end
        end
    end
    if RegroupAssault(platoon,g,hooks,now) then return true end
    if not Current(platoon,army,armyAI,ai,op) then return false end
    if op.supportSince then
        -- Ordinary reinforcements keep their receiver through local combat;
        -- explicit assault assembly detaches before native micro takes over.
        -- The same engagement policy owns micro and retreat for every land group.
        local previous=op.policy.phase
        input.goalValid,input.goalExpired,input.arrived=true,false,false
        local action,reason
        if enemy>math.max(1,g.own+friendly)*1.8 then
            action,reason=Policy.Retreat(op.policy,input,"support-overmatched")
        else action,reason=Policy.Step(op.policy,input) end
        op.lastAction,op.lastReason=action,reason
        if action=="micro" then
            if not Micro(platoon,g,hooks,input,previous) then return false end
        elseif action=="retreat" then
            DetachSupport(platoon);Retreat(platoon,g,hooks,now)
        else
            if action=="reject" then
                Reject(platoon,target and target:GetPosition(),now)
                Policy.Acquire(op.policy,now)
            end
            if previous=="Engage" or action=="reject" then
                Clear(platoon,hooks);platoon.ai.microTarget=false
                Policy.Acquire(op.policy,now)
            end
            SupportTick(platoon,g,hooks,now)
        end
        if not Current(platoon,army,armyAI,ai,op) then return false end
        if op.policy.phase=="Engage" or op.policy.phase=="Retreat" then
            platoon.ai.eState=STATE_NAMES[op.policy.phase]
        end
        if hooks.Report then hooks.Report(platoon,previous,reason) end
        return true
    end
    local previous=op.policy.phase
    local action,reason=Policy.Step(op.policy,input)
    op.lastAction,op.lastReason=action,reason
    if action=="finish" then return false
    elseif action=="retreat" then Retreat(platoon,g,hooks,now)
    elseif action=="retreat-finished" then
        Clear(platoon,hooks);op.goal=nil;op.defenseClaim=nil
        if op.policy.phase=="Acquire" then
            local nextGoal=SelectObjective(platoon,g,hooks,now)
            if not Current(platoon,army,armyAI,ai,op) then return false end
            if nextGoal then
                local accepted,blocked=AdoptGoal(platoon,nextGoal,hooks,now,input)
                if not accepted and blocked~="stale-request" then Policy.Hold(op.policy,now,blocked or "no-safe-objective") end
            else Policy.Hold(op.policy,now,"no-safe-objective") end
        end
    elseif action=="reject" then
        local rejected=reason=="no-weapon-contact" and target and target:GetPosition()
            or (goal and goal.pos) or (target and target:GetPosition())
        Reject(platoon,rejected,now)
        op.goal=nil;op.defenseClaim=nil;op.defensePending=nil;Clear(platoon,hooks)
        Policy.Hold(op.policy,now,reason)
    elseif action=="acquire" then
        -- The last accepted safe leg may finish while its successor obtains a
        -- path slot. Rejected goals, lost contacts and combat orders still stop
        -- immediately; an ordinary arrival needs no clear-and-idle interlude.
        local keepApproach=platoon.ai.rushMoving and previous=="Advance" and reason=="objective-reached"
            and goalValid and not input.goalExpired and not input.underFire
            and enemy<=math.max(1,g.own+friendly)*0.8
        if goal and goal.kind=="stage" and Reached(g,goal.pos) then op.lastStage=Copy(goal.pos) end
        if not keepApproach and (platoon.ai.rushMoving or previous=="Engage") then Clear(platoon,hooks) end
        local nextGoal=(previous=="Engage" or op.resumeMission) and goalValid and not input.goalExpired and goal or nil
        op.goal,op.resumeMission=nil,nil
        if nextGoal and nextGoal.kind=="attack" then
            nextGoal.pos=Copy(nextGoal.unit:GetPosition())
            local support=Intel.FriendlyThreat(platoon,nextGoal.pos,64,"Land",true)
            if Intel.EnemyThreat(platoon.army,nextGoal.pos,"Land",12,24)>(g.own+support)*input.attackRatio then nextGoal=nil end
        end
        if not nextGoal then nextGoal=SelectObjective(platoon,g,hooks,now) end
        if not Current(platoon,army,armyAI,ai,op) then return false end
        if not nextGoal then
            if keepApproach then Clear(platoon,hooks) end
            op.defenseClaim=nil;op.defensePending=nil
            Policy.Hold(op.policy,now,"no-safe-objective")
        else
            local accepted,blocked=AdoptGoal(platoon,nextGoal,hooks,now,input)
            if not accepted and blocked~="stale-request" then Policy.Hold(op.policy,now,blocked or "no-safe-objective") end
        end
    elseif action=="repath" then
        State(platoon.army).stats.repaths=State(platoon.army).stats.repaths+1
        if goal then
            local defensive=goal.kind=="stage" or goal.kind=="siege" or goal.kind=="deploy" or goal.kind=="rally" or goal.kind=="defend"
            local destination=reason=="target-moved" and Copy(goal.unit:GetPosition()) or goal.pos
            local supported=g.own+Intel.FriendlyThreat(platoon,destination,64,"Land",true)
            local moved,blocked
            if reason=="target-moved" and (not TargetValid(platoon,goal.unit)
                or not MG.CanGraphAreaTo(g.position,destination,platoon.ai.movementLayer)
                or Intel.EnemyThreat(platoon.army,destination,"Land",12,24)>supported*input.attackRatio) then
                Clear(platoon,hooks)
                moved,blocked=false,"target-retreated-into-threat"
            else
                moved,blocked=StartMove(platoon,destination,not defensive,hooks,now,not defensive or goal.approach==true)
                if moved~=false then goal.pos=Copy(destination);platoon.ai.primaryTargetAreaPos=goal.pos end
            end
            if moved==false then
                if not Current(platoon,army,armyAI,ai,op) then return false end
                if blocked~="stale-request" then
                    Reject(platoon,goal.pos,now);op.goal=nil;op.defenseClaim=nil;op.defensePending=nil
                    Policy.Hold(op.policy,now,blocked or "path-failed")
                end
            end
        end
    elseif action=="micro" then
        if not Micro(platoon,g,hooks,input,previous) then return false end
    elseif action=="move" then MoveUnits(platoon,g,hooks)
    end
    if not Current(platoon,army,armyAI,ai,op) then return false end
    platoon.ai.withdraw=op.policy.phase=="Retreat"
    platoon.ai.eState=STATE_NAMES[op.policy.phase] or "SelectMainTarget"
    if hooks.Report then hooks.Report(platoon,previous,reason) end
    return true
end

function Run(platoon,hooks,support)
    local army,ai=platoon.army,platoon.ai
    local armyAI=army.ai
    local operation=Initialize(platoon,hooks,support)
    local function current()
        return platoon.army==army and army.ai==armyAI and platoon.ai==ai and ai.rushOperation==operation
    end
    while current() and Tick(platoon,hooks) do
        local rate=(Constants and Constants.TickRate) or 10
        local nextSense=Now()+(operation.policy.phase=="Acquire" and 0.1 or 1)
        repeat
            local delay=math.min(nextSense-Now(),(operation.pendingMove or ai.rushMoving) and 0.2 or 1)
            WaitTicks(math.max(1,math.floor(rate*delay+0.5)))
            -- Queue admission is cheap; do not repeat the entire geometry,
            -- target and threat pass five times per second just while waiting.
            if current() and Live(platoon) and Now()<nextSense then
                ResolvePending(platoon,hooks)
                if current() and Live(platoon) and ai.rushMoving and hooks.MaintainMovement then hooks.MaintainMovement(platoon) end
            end
        until not current() or not Live(platoon) or Now()>=nextSense
    end
    -- A yielding path helper may have been replaced by a different plan. The
    -- old coroutine must not unregister or disband that replacement's army.
    if current() then Unregister(platoon);hooks.Exit(platoon) end
end

function Summary(army)
    local state=State(army);Prune(state)
    local forces,largest,units,holding=0,0,0,0
    for _,p in pairs(state.operations) do
        forces=forces+1;local n=Count(p);largest=math.max(largest,n);units=units+n
        if p.ai.rushOperation and p.ai.rushOperation.policy.phase=="Hold" then holding=holding+1 end
    end
    return {forces=forces,largest=largest,units=units,holding=holding,stats=state.stats,intel=Intel.Stats(army),
        fronts=Front.Summary(army),paths=Budget.Summary(),deployment=Intel.DeploymentStats(army)}
end
