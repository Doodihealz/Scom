-- RC17: paid early air production and independent, visibility-limited bomber raids.
-- T1 raids punish exposed artillery and follow the resource chain; advanced wings value strategic strikes.
-- This controller issues ordinary MOVE / ATTACKUNIT orders. It never changes
-- weapon damage, reload, build permissions, resources or fog of war.
Version = "9.0.22-rc26"
Config = { OpeningSeconds=90, WingLimit=3, WingInstances=48, IntelSeconds=1, VisionGraceSeconds=8,
    AcquireSeconds=4, TargetLimit=12, NoDamageSeconds=32, AttackSeconds=90,
    ScoutSeconds=45, EgressSeconds=8, RiskFraction=0.65 }
local AirOrders = Import("AI/mods/AI-Scom/RushAirOrders.lua")
local Selection = Import("AI/mods/AI-Scom/RushSelection.lua")
local AF = Import("AI/AIFunctions.lua")
local Pressure = Import("AI/mods/AI-Scom/RushPressure.lua")
local Frontline = Import("AI/mods/AI-Scom/RushFrontline.lua")
local Log = Import("AI/debugUtilities.lua").AILog
local function Now() return GetGameTimeSeconds() end
local function Finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function Valid(p) return p and Finite(p.x) and Finite(p.z) end
local function Copy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local function Has(tp,tag)
    if not tp then return false end
    if tp.hasTags and tp.hasTags[tag] then return true end
    for _,t in ipairs(tp.tags or {}) do if t==tag then return true end end
    return false
end
local function Tier(tp)
    for t=4,1,-1 do if Has(tp,"TECH"..t) or Has(tp,"SCFA_TECH"..t) then return t end end
    return tp and tp.general and tp.general.techNumber or 1
end
local function Own(army,u) return u and not u.dead and not u.deleted and u.army==army
    and u.id and army.units and army.units[u.id.index]==u
    and not u.CaptureInProgress and not u.ReclaimInProgress end
function Visible(army,u)
    if not u or u.dead or u.deleted or u.CaptureInProgress or u.ReclaimInProgress
        or not u.army or not army:IsEnemy(u.army) then return false end
    -- Do not assume that GetEnemyUnitsOnMap is fog-filtered. Some native versions
    -- return all enemy records. Visibility is checked BEFORE position/health access.
    return (type(u.IsIntelVisionVisible)=="function" and u:IsIntelVisionVisible(army))
        or (type(u.IsIntelRadarVisible)=="function" and u:IsIntelRadarVisible(army)) or false
end
-- Naval-air tags outrank the broad BOMBER / ANTI_SURFACE tags. A torpedo
-- aircraft cannot fill a land-strike role merely because it has both tags.
function IsNavalAttackAircraft(tp)
    return Has(tp,"AIR") and (Has(tp,"MOBILE") or Has(tp,"SCFA_MOBILE"))
        and (Has(tp,"TORPEDO_BOMBER") or Has(tp,"ANTI_NAVAL") or Has(tp,"ANTI_NAVY") or Has(tp,"SCFA_ANTINAVY"))
end
function IsBomber(tp)
    return Has(tp,"AIR") and Has(tp,"MOBILE") and Has(tp,"BOMBER")
        and Tier(tp)<=3 and not Has(tp,"GUNSHIP") and not Has(tp,"TRANSPORT")
        and not IsNavalAttackAircraft(tp)
end
local function State(army)
    local s=army.ai.rushBombers
    if not s then
        s={wings=setmetatable({},{__mode="k"}),claims={},visited={},nextIntel=-1,records={},aa={},intelBuilds=0}
        army.ai.rushBombers=s
    end
    s.responseBlocked=s.responseBlocked or setmetatable({},{__mode="k"})
    return s
end
local function Ready(army,u)
    return Own(army,u) and u:IsCompleted() and IsBomber(u.tp)
        and not (u.toggles and u.toggles.Pause)
        and not (u.ai and u.ai.eState=="RepairHome")
end
local function Units(p)
    local us={}
    for _,u in ipairs(p:GetUnits() or {}) do
        if Ready(p.army,u) and u.platoon==p and u.ai and u.ai.eState=="PlatoonControlled"
            and not AirOrders.MusterOverridden(p,u) then us[#us+1]=u end
    end
    return us
end
-- Existence checks need no temporary array and stop at the first eligible unit.
local function HasUnit(p)
    for _,u in ipairs(p:GetUnits() or {}) do
        if Ready(p.army,u) and u.platoon==p then return true end
    end
    return false
end
local function Live(p) return p and not p.dead and not p.deleted and p.army and p.army.ai and p.army.ai.isAlive~=false
    and p.army:PlatoonExists(p) end
local function ClaimLive(army,c,now)
    local p=c.platoon
    return now<c.untilTime and Live(p) and p.army==army and c.armyAI==army.ai
        and p.ai==c.platoonAI and p.ai.rushBomber==c.operation and HasUnit(p)
end
local function Position(us)
    local p={x=0,y=0,z=0}
    for _,u in ipairs(us) do local q=u:GetPosition();p.x=p.x+q.x;p.y=p.y+(q.y or 0);p.z=p.z+q.z end
    p.x,p.y,p.z=p.x/#us,p.y/#us,p.z/#us;return p
end
local function Health(u) return math.max(0,u:GetHealth() or 0) end
local function Strength(us)
    local health,speed=math.huge,math.huge
    for _,u in ipairs(us) do
        health=math.min(health,Health(u))
        speed=math.min(speed,math.max(1,(u.tp.movement and u.tp.movement.speed) or 8))
    end
    return health,speed
end
local function Inside(p)
    return Valid(p) and (type(AF.isPosWithinPlayableArea)~="function" or AF.isPosWithinPlayableArea(p))
end
local function Clamp(p)
    if type(AF.GetPositionWithinPlayableArea)=="function" then p=AF.GetPositionWithinPlayableArea(p) end
    return Inside(p) and Copy(p) or nil
end
function WantsOpening(army,snapshot)
    local a,e=snapshot.alloy,snapshot.energy
    local layers=army.ai.settings and army.ai.settings.useLayer
    if layers and layers.air~=true then return false end
    if (snapshot.airFactories or 0)>0
        or (snapshot.airFactoriesBuilding or 0)>0 or not a or not e then return false end
    if not snapshot.landDisconnected and (not layers or layers.land~=false)
        and (snapshot.landFactories or 0)<2 then return false end
    if (not layers or layers.land~=false) and (snapshot.roles.engineer or 0)<2 then return false end
    if (snapshot.extractors or 0)<3 then return false end
    -- The first airfield competes with optional expansion, not the first ground
    -- factory or emergency power. Its full cost still goes through native BUILD.
    local eb=e.balance-(e.reserved or 0)
    return a.income>=7 and e.income>=70 and a.current>=140 and e.current>=450
        and (eb>=0 or e.current>=-eb*20)
end
function BomberGoal(snapshot,tier)
    local income=snapshot.alloy and snapshot.alloy.income or 0
    local goal=math.min(24,math.max(2,math.floor(income/5)))
    return tier and tier>1 and math.max(1,math.ceil(goal/tier)) or goal
end
local function BomberCount(snapshot,tier)
    local count=0
    for t=tier or 1,3 do
        local amount
        if snapshot.bomberTiers then amount=snapshot.bomberTiers[t]
        elseif snapshot.tiers then amount=snapshot.tiers["bomber:"..t] end
        count=count+(amount or 0)
    end
    return count
end
-- No tier means the role's highest outstanding request. The production selector
-- must use the candidate's actual tier after checking its native factory menu.
function BomberPriority(snapshot,tier)
    if not tier then
        local priority
        for t=1,3 do
            local score=BomberPriority(snapshot,t)
            if score and (not priority or score>priority) then priority=score end
        end
        return priority
    end
    if tier<1 or tier>3 then return nil end
    local count=snapshot.actualBombers or BomberCount(snapshot)
    if not snapshot.bomberTiers and not snapshot.tiers then count=snapshot.roles.bomber or 0 end
    if count>=Config.WingInstances then return nil end
    if count<2 then return 940 end -- only the opening fighter screen and urgent defense come first
    -- Higher-tech aircraft satisfy lower-tech strike demand. T1 survivors never
    -- substitute for the first paid advanced wings, and pending products count.
    for needed=tier,2,-1 do
        if BomberCount(snapshot,needed)<BomberGoal(snapshot,needed) then return 800+needed*20 end
    end
    if count<BomberGoal(snapshot) then return 710 end
    -- Stop optional filler once funded goals are met. Even the largest T1, T2
    -- and T3 allocations together fit inside the existing one-unit wing ceiling.
    return nil
end
-- Conservative per-salvo damage from the smallest simultaneous muzzle group.
-- Native weapons fire all muzzles in a group, then advance one group per salvo.
-- Do not multiply by EVERY group or count optimistic splash/chain damage.
local function Volley(w)
    local t=w.tp or w;local count=math.huge
    for _,g in pairs(w.muzzleGroups or t.muzzleGroups or {}) do
        local muzzles=g.muzzles or g
        if type(muzzles)=="table" and #muzzles>0 then count=math.min(count,#muzzles) end
    end
    if count==math.huge then count=1 end
    return math.max(0,t.damage or w.damage or 0)*count*math.max(1,t.muzzleSalvoSize or 1)
end
local function Weapons(us)
    local result={}
    for _,u in ipairs(us) do
        for _,w in pairs(u.weapons or {}) do result[#result+1]={weapon=w} end
    end
    return result
end
local function DamageTo(weapons,target)
    local damage=0
    for _,item in ipairs(weapons) do
        local w=item.weapon;local t=w.tp or w
        if w.enabled~=false and not w.isDeathExplosion and t.rangeRingType~="AntiAir"
            and type(w.CanShootAt)=="function" and w:CanShootAt(target) then
            -- Reused only during this non-yielding selection. Future selections
            -- reread enabled weapons/muzzles; no permanent blueprint assumption.
            if item.damage==nil then item.damage=Volley(w) end
            damage=damage+item.damage
        end
    end
    return damage
end
function PassDamage(us,target) return DamageTo(Weapons(us),target) end

local function Value(u)
    -- Commanders also carry engineer/economy/power tags. Classify them first so
    -- these secondary tags can never promote them ahead of the four economy tiers.
    if Has(u.tp,"COMMAND") or Has(u.tp,"SCFA_COMMAND") then return 300,"commander",5 end
    -- Air/naval factories carry domain tags too, but remain bombable structures.
    if Has(u.tp,"MOBILE") and (Has(u.tp,"AIR") or Has(u.tp,"NAVAL")) then return nil end
    local cost=u.tp.economy and u.tp.economy.cost and u.tp.economy.cost.alloys or 0
    if Has(u.tp,"MOBILE") and (Has(u.tp,"ARTILLERY") or Has(u.tp,"INDIRECT_FIRE") or Has(u.tp,"SCFA_ARTILLERY")) then
        return 500+math.min(1500,cost)*1.2,"artillery",0
    end
    if Has(u.tp,"ALLOYS_EXTRACTION") then return 550+math.min(1600,cost)*0.7,"alloy",1 end
    if Has(u.tp,"ENGINEER") then return 200+math.min(1000,cost)*0.5,"engineer",2 end
    if Has(u.tp,"ENERGY_PRODUCTION") and Has(u.tp,"STRUCTURE") then return 260+math.min(3000,cost)*0.6,"power",3 end
    if Has(u.tp,"FACTORY") and Has(u.tp,"STRUCTURE") then return 230+math.min(3000,cost)*0.4,"factory",4 end
    -- Other generic combat units do not replace the economic raid chain.
end
local function Refresh(army)
    local s=State(army);local now=Now()
    if now<s.nextIntel and now>=s.nextIntel-Config.IntelSeconds then return s end
    local previousMotion=s.artilleryMotion or {}
    s.records,s.byPriority,s.aa,s.shields,s.artilleryMotion={},{},{},{},{}
    s.targetHealth,s.targetHealthAt={},now
    s.nextIntel=now+Config.IntelSeconds;s.intelBuilds=s.intelBuilds+1
    local seen={}
    for _,u in pairs(AF.GetEnemyUnitsOnMap(army.id) or {}) do
        if not seen[u] and Visible(army,u) and u.id and u.tp then
            seen[u]=true
            local pos=Copy(u:GetPosition())
            if Valid(pos) then
                local value,kind,priority=Value(u)
                if value and Inside(pos) then
                    local record={unit=u,pos=Copy(pos),value=value,kind=kind,priority=priority}
                    if kind=="artillery" then
                        local prior=previousMotion[u]
                        local steady=prior and now>=prior.at and now-prior.at<=Config.IntelSeconds*2
                            and D2(pos,prior.anchor)<=4
                        local observation={anchor=steady and prior.anchor or Copy(pos),
                            since=steady and prior.since or now,at=now}
                        s.artilleryMotion[u]=observation;record.stationarySince=observation.since
                    end
                    s.records[#s.records+1]=record
                    local tier=s.byPriority[priority]
                    if not tier then tier={};s.byPriority[priority]=tier end
                    tier[#tier+1]=record
                end
                for _,shield in ipairs(u.shields or {}) do
                    local tp=shield.tp;local radii=tp and tp.radii
                    if tp and (tp.type=="Personal" or tp.type=="Bubble" and radii
                        and (radii.x or 0)>0 and (radii.z or radii.x)>0) then
                        s.shields[#s.shields+1]={unit=u,shield=shield,pos=Copy(pos),personal=tp.type=="Personal",
                            offset=tp.offset or {},x=radii and radii.x,y=radii and (radii.y or radii.x),
                            z=radii and (radii.z or radii.x)}
                    end
                end
                local range,dps,splashDps=0,0,0
                for _,w in pairs(u.weapons or {}) do
                    local t=w.tp or w
                    if w.enabled~=false and not w.isDeathExplosion and (t.rangeRingType=="AntiAir" or w.rangeRingType=="AntiAir") then
                        range=math.max(range,t.rangeMax or w.rangeMax or 0)
                        local damage=Volley(w)/math.max(0.1,t.reloadTime or 1)
                        if type(AF.GetWeaponDamagePerSecond)=="function" then
                            local native=AF.GetWeaponDamagePerSecond(t)
                            if Finite(native) then damage=math.max(damage,native) end
                        end
                        dps=dps+damage
                        if (t.damageRadius or 0)>0 then splashDps=splashDps+damage end
                    end
                end
                if range>0 and dps>0 then
                    s.aa[#s.aa+1]={unit=u,pos=Copy(pos),range=range,dps=dps,splashDps=splashDps,mobile=Has(u.tp,"AIR")}
                end
            end
        end
    end
    -- No arbitrary AA-count cap: distant long-range weapons remain represented.
    for key,c in pairs(s.claims) do
        if not ClaimLive(army,c,now) or (c.unit and not Visible(army,c.unit)) then s.claims[key]=nil end
    end
    for key,t in pairs(s.visited) do if now>=t then s.visited[key]=nil end end
    for unit,expiry in pairs(s.responseBlocked) do
        if now>=expiry or unit.dead or unit.deleted then s.responseBlocked[unit]=nil end
    end
    return s
end
local function StrikeHealth(army,target,s)
    local now=Now()
    if s.targetHealthAt~=now then s.targetHealth,s.targetHealthAt={},now end
    if s.targetHealth[target] then return s.targetHealth[target] end
    local health=Health(target);local pos=Copy(target:GetPosition())
    for _,r in ipairs(s.shields or {}) do
        local shield=r.shield
        if Visible(army,r.unit) and not shield.deleted and type(shield.IsEnabled)=="function"
            and shield:IsEnabled() and type(shield.GetHealth)=="function" then
            local covers=r.personal and r.unit==target
            if not r.personal and r.unit.army:IsAlly(target.army) then
                -- The native shield entity includes its animated bone/offset.
                -- Read only a visible owner's current center, including motion.
                local center=type(shield.GetPosition)=="function" and shield:GetPosition()
                if not Valid(center) then
                    local owner=Copy(r.unit:GetPosition())
                    center={x=owner.x+(r.offset.x or 0),y=owner.y+(r.offset.y or 0),z=owner.z+(r.offset.z or 0)}
                end
                local dx=(pos.x-center.x)/r.x;local dz=(pos.z-center.z)/r.z
                local horizontal=dx*dx+dz*dz
                -- An overhead bomb can hit a bubble above a low target. A unit
                -- on a cliff above its upper surface receives no such cover.
                covers=horizontal<=1 and r.y>0
                    and pos.y<=(center.y or 0)+r.y*math.sqrt(math.max(0,1-horizontal))
            end
            if covers then health=health+math.max(0,shield:GetHealth()) end
        end
    end
    s.targetHealth[target]=health
    return health
end

local function CounterTarget(army,alarm)
    local state=State(army);local now=Now();local current=state.response
    if current and now>=(state.responseBlocked[current.target] or 0) then
        for _,record in ipairs(alarm.artilleryTargets or {}) do
            if record.unit==current.target and Visible(army,record.unit) then return record end
        end
    end
    local cached=state.counterChoice
    if cached and cached.alarm==alarm and (not cached.record or Visible(army,cached.record.unit)
        and now>=(state.responseBlocked[cached.record.unit] or 0)) then return cached.record end
    local best,score;local intel=Refresh(army)
    for _,record in ipairs(alarm.artilleryTargets or {}) do
        local unit=record.unit
        if Visible(army,unit) and now>=(state.responseBlocked[unit] or 0) then
            local pos=Copy(unit:GetPosition());local health=StrikeHealth(army,unit,intel)
            local risk,splash=RouteRisk(army,{alarm.base,pos},10,{intel=intel,visible={}})
            local value=(health+risk*2+splash*8)*(1+math.sqrt(D2(alarm.base,pos))/1500)
            if not score or value<score then best,score=record,value end
        end
    end
    state.counterChoice={alarm=alarm,record=best}
    return best
end

-- A finite, paid counter-battery cohort. Actual factory menus/funding remain
-- authoritative in the production selector; templates only size the request.
function ResponsePriority(army,snapshot,tp)
    if not army or not army.ai or not snapshot or not IsBomber(tp) then return nil end
    local tier=Tier(tp)
    if tier<2 or tier>3 or (snapshot.actualBombers or 0)>=Config.WingInstances then return nil end
    local alarm=Frontline.MainAlarm(army)
    if not alarm.bombardment then return nil end
    local damage=0
    for _,weapon in ipairs(tp.weapons or {}) do
        if weapon.category~="DeathExplosion" and weapon.rangeRingType~="AntiAir" then
            for _,layer in ipairs(weapon.layerTargetLimits or {}) do
                if layer=="Land" then damage=damage+Volley(weapon);break end
            end
        end
    end
    if damage<=0 then return nil end
    local health=0;local intel=Refresh(army);local record=CounterTarget(army,alarm)
    if record and Visible(army,record.unit) then health=StrikeHealth(army,record.unit,intel) end
    local goal=health>0 and math.max(4,math.min(24,math.ceil(health*1.35/damage))) or 6
    if BomberCount(snapshot,tier)<goal then return 970+tier end
end

local function Key(pos) return math.floor(pos.x/12)..":"..math.floor(pos.z/12) end
local function ClaimTotals(s,p,now)
    local totals={}
    for _,c in pairs(s.claims) do
        if c.platoon~=p and c.unit and ClaimLive(p.army,c,now) and Visible(p.army,c.unit) then
            totals[c.unit]=(totals[c.unit] or 0)+c.damage
        end
    end
    return totals
end

function Release(p)
    local s=State(p.army)
    s.claims[p]=nil
    local op=p.ai and p.ai.rushBomber
    if op and op.response then op.response.members[p]=nil;op.response=nil end
end
-- Length of a route segment inside a known AA circle. Avoiding only the target
-- endpoint would send bombers straight through defended bases on the way there.
local function Exposure(a,b,c,r)
    local dx,dz=b.x-a.x,b.z-a.z;local l2=dx*dx+dz*dz
    if l2<0.0001 then return D2(a,c)<=r*r and r or 0 end
    local ux,uz=a.x-c.x,a.z-c.z
    local q=(ux*dx+uz*dz)/l2
    local disc=q*q-(ux*ux+uz*uz-r*r)/l2
    if disc<=0 then return 0 end
    local root=math.sqrt(disc)
    return math.max(0,math.min(1,-q+root)-math.max(0,-q-root))*math.sqrt(l2)
end
function RouteRisk(army,route,speed,decision)
    local risk,splash=0,0;local s=decision and decision.intel or Refresh(army)
    local xmin,zmin,xmax,zmax=math.huge,math.huge,-math.huge,-math.huge
    for _,node in ipairs(route) do
        xmin,zmin=math.min(xmin,node.x),math.min(zmin,node.z)
        xmax,zmax=math.max(xmax,node.x),math.max(zmax,node.z)
    end
    for _,aa in ipairs(s.aa) do
        local r=aa.range+(aa.mobile and 20 or 3)
        -- Reject non-overlapping bounding boxes before circle/segment math.
        -- This is exact pruning, not a nearest-N or weapon-range truncation.
        if aa.pos.x+r>=xmin and aa.pos.x-r<=xmax and aa.pos.z+r>=zmin and aa.pos.z-r<=zmax
            then
            local visible=decision and decision.visible[aa.unit]
            if visible==nil then
                visible=Visible(army,aa.unit)
                if decision then decision.visible[aa.unit]=visible end
            end
            if visible then
                local exposed=0
                for i=2,#route do exposed=exposed+Exposure(route[i-1],route[i],aa.pos,r) end
                if exposed>0 then
                    local time=exposed/speed+(aa.mobile and 2 or 0.75)
                    risk=risk+aa.dps*time;splash=splash+(aa.splashDps or 0)*time
                end
            end
        end
    end
    return risk,splash
end
-- Used only at a pass transition to choose the lower-risk turn direction.
-- Reuse the observer-private intel cache; no per-aircraft polling threads.
local ResponseRiskScale
AirOrders.SetPassRiskEvaluator(function(p,u,route)
    local speed=u.tp and u.tp.movement and u.tp.movement.speed or 16
    if not Finite(speed) then speed=16 end
    local risk,splash=RouteRisk(p.army,route,math.max(1,speed))
    -- Flak can damage several aircraft with the same shot; only direct-fire
    -- exposure may share the physically present salvo's casualty budget.
    return (risk-splash)*(ResponseRiskScale and ResponseRiskScale(p,u) or 1)+splash
end)
local function PassRouteRisk(p,us)
    local risk=0;local denied=false
    for _,u in ipairs(us) do
        local r=u.ai and u.ai.rushAirOrders
        if r and r.bomberPassRouteDenied then r.bomberPassRouteDenied=nil;denied=true end
        local route=AirOrders.RemainingPassRoute(p,u)
        if route then
            local speed=u.tp and u.tp.movement and u.tp.movement.speed or 16
            local total,splash=RouteRisk(p.army,route,math.max(1,speed))
            risk=math.max(risk,(total-splash)*(ResponseRiskScale and ResponseRiskScale(p,u) or 1)+splash)
        end
    end
    return risk,denied
end
local function Route(p,start,finish,speed,decision)
    local distance=math.sqrt(D2(start,finish));local dx,dz=finish.x-start.x,finish.z-start.z
    local direct={Copy(start),Copy(finish)}
    local directRisk,directSplash=RouteRisk(p.army,direct,speed,decision)
    local best={nodes=direct,risk=directRisk,splash=directSplash,length=distance}
    if best.risk<=0 or distance<50 then return best end
    -- Two bounded doglegs, clamped using the actual playable rectangle (including
    -- cropped map origins). Ordinary air movement needs no ground path search.
    local offset=math.min(100,math.max(40,distance*0.35))
    for _,sign in ipairs({-1,1}) do
        local mid=Clamp({x=(start.x+finish.x)/2-sign*dz/distance*offset,y=start.y,z=(start.z+finish.z)/2+sign*dx/distance*offset})
        if mid then
            local nodes={Copy(start),mid,Copy(finish)}
            local length=math.sqrt(D2(start,mid))+math.sqrt(D2(mid,finish))
            local risk,splash=RouteRisk(p.army,nodes,speed,decision)
            if risk+length*0.03<best.risk+best.length*0.03 then best={nodes=nodes,risk=risk,splash=splash,length=length} end
        end
    end
    return best
end
-- RouteRisk charges at least the AA's response term whenever any segment
-- crosses its circle. An endpoint strictly INSIDE that circle guarantees a
-- crossing on every ingress, including doglegs. Reject only when this lower
-- bound ALONE exceeds the unchanged safety budget; never weaken an AA check.
local function FatalAA(aa,hp)
    local fatal={}
    for _,entry in ipairs(aa) do
        if entry.dps*(entry.mobile and 2 or 0.75)*1.5>hp*Config.RiskFraction then
            fatal[#fatal+1]=entry
        end
    end
    return fatal
end
local function InsideFatalAA(army,pos,decision)
    for _,aa in ipairs(decision.fatal) do
        local r=aa.range+(aa.mobile and 20 or 3)
        if D2(pos,aa.pos)<r*r then
            local visible=decision.visible[aa.unit]
            if visible==nil then visible=Visible(army,aa.unit);decision.visible[aa.unit]=visible end
            if visible then return true end
        end
    end
    return false
end
local function BetterTarget(a,b)
    if a.score~=b.score then return a.score>b.score end
    return a.unit.id.index<b.unit.id.index
end
-- A detected MAIN attacker precedes economic harassment, including a moving
-- artillery raider. Native shootability, observed shields and AA still apply.
local function HomeDefenseTarget(p,us,alarm)
    if not alarm.localRaid then return nil end
    local intel=Refresh(p.army);local now=Now();local pos=Position(us)
    local hp,speed=Strength(us);local weapons=Weapons(us);local claimed=ClaimTotals(intel,p,now)
    local decision={intel=intel,visible={}};local candidates={}
    for _,record in ipairs(alarm.raiders or {}) do
        local unit=record.unit
        if Visible(p.army,unit) and now>=(p.ai.rushBomber.blocked[unit] or 0) then
            local damage=DamageTo(weapons,unit);local health=StrikeHealth(p.army,unit,intel)
            if damage>0 and health>0 and damage*4>=health and (claimed[unit] or 0)<health*0.95 then
                local target=Copy(unit:GetPosition())
                if Inside(target) then
                    candidates[#candidates+1]={unit=unit,pos=target,kind="main-defense",damage=damage,health=health,
                        score=(1000+(record.threat or 0)*20)/(1+math.sqrt(D2(pos,target))/180)
                            /(1+math.max(0,health/damage-1)*0.25)}
                end
            end
        end
    end
    for _,candidate in ipairs(Selection.Top(candidates,6,BetterTarget)) do
        local route=Route(p,pos,candidate.pos,speed,decision)
        if route.risk*1.5<=hp*Config.RiskFraction then candidate.route=route;return candidate end
    end
end
function SelectTarget(p,us)
    local s=Refresh(p.army);us=Units(p);if not Live(p) or #us==0 then return nil end
    local defense=HomeDefenseTarget(p,us,Frontline.MainAlarm(p.army))
    if defense then return defense end
    local pos=Position(us);local hp,speed=Strength(us)
    local now=Now();local claimed=ClaimTotals(s,p,now);local weapons=Weapons(us)
    local strategic=true
    for _,u in ipairs(us) do if Tier(u.tp)<2 then strategic=false;break end end
    -- T1 compares an easy artillery strike with the first safe economic tier.
    -- Stationarity comes from consecutive visible positions, never enemy orders.
    -- Advanced wings still compare all categories by actual strike value.
    for target,untilTime in pairs(p.ai.rushBomber.blocked) do
        if now>=untilTime or target.dead or target.deleted then p.ai.rushBomber.blocked[target]=nil end
    end
    local decision={intel=s,visible={},fatal=FatalAA(s.aa,hp)}
    local hasFatal=#decision.fatal>0
    if hasFatal and InsideFatalAA(p.army,pos,decision) then return nil end
    local best
    for priority=0,5 do
        local records=s.byPriority[priority]
        if records then
            local candidates={}
            for _,r in ipairs(records) do
                local u=r.unit
                if Visible(p.army,u) and now>=(p.ai.rushBomber.blocked[u] or 0) then
                    local current=Copy(u:GetPosition())
                    if Inside(current) and not (hasFatal and InsideFatalAA(p.army,current,decision)) then
                        local damage=DamageTo(weapons,u);local health=StrikeHealth(p.army,u,s)
                        if damage>0 and health>0 and (claimed[u] or 0)<health*0.9 then
                            local passes=math.max(1,math.ceil(health/damage))
                            -- A surviving commander is a final objective, not an
                            -- expensive resource to skip forever. It may need more
                            -- than 16 passes; live AA, no-damage and absolute attack
                            -- deadlines below still apply without any damage bonus.
                            local stationary=r.kind=="artillery" and r.stationarySince
                                and now-r.stationarySince>=1.5 and D2(current,r.pos)<=4
                            if r.kind=="artillery" and stationary and passes<=2
                                or r.kind~="artillery" and (passes<=16 or r.kind=="commander") then
                                local value=r.value
                                if strategic then
                                    if r.kind=="commander" then
                                        -- A credible finishing strike competes with economic
                                        -- targets; protracted assassination stays low value.
                                        if passes<=2 then value=value*6 end
                                    else value=value*math.min(3,Tier(u.tp)) end
                                end
                                local score=value/(1+math.sqrt(D2(pos,current))/240)/(1+(passes-1)*0.55)
                                candidates[#candidates+1]={unit=u,pos=Copy(current),kind=r.kind,priority=priority,
                                    damage=damage,health=health,score=score}
                            end
                        end
                    end
                end
            end
            candidates=Selection.Top(candidates,Config.TargetLimit,BetterTarget)
            local categoryBest
            for _,c in ipairs(candidates) do
                -- Risk can only reduce score. Keep the shortlist and geometric
                -- route exposure checks bounded for each current category.
                if categoryBest and c.score<categoryBest.score then break end
                if strategic and best and c.score<best.score then break end
                local route=Route(p,pos,c.pos,speed,decision)
                if route.risk*1.5<=hp*Config.RiskFraction then
                    c.route=route;c.score=c.score/(1+route.risk/math.max(1,hp)*5)
                    if not categoryBest or BetterTarget(c,categoryBest) then categoryBest=c end
                end
            end
            if categoryBest and (not best or BetterTarget(categoryBest,best)) then best=categoryBest end
            if not strategic and priority>0 and categoryBest then return best end
        end
    end
    return best
end
function SelectScout(p,us)
    -- Survival has no enemy resource economy; wait for visible wave targets.
    if Pressure.SurvivalMap() then return nil end
    local s=Refresh(p.army);us=Units(p);if not Live(p) or #us==0 then return nil end
    local op=p.ai.rushBomber;local pos=Position(us);local hp,speed=Strength(us)
    local home=op.home;local candidates={};local owned={};local reservedMarkers={}
    local decision={intel=s,visible={}};local now=Now()
    for _,claim in pairs(s.claims) do
        if claim.platoon~=p and claim.marker and ClaimLive(p.army,claim,now) then reservedMarkers[claim.marker]=true end
    end
    for _,u in pairs(p.army.units or {}) do
        if Own(p.army,u) and Has(u.tp,"ALLOYS_EXTRACTION") then owned[#owned+1]=Copy(u:GetPosition()) end
    end
    for _,m in ipairs(Pressure.AlloyMarkers()) do
        local key=Key(m)
        if Inside(m) and D2(home,m)>70^2 and D2(pos,m)>24^2 and not reservedMarkers[key] and Now()>=(s.visited[key] or 0) then
            local ours=false;for _,q in ipairs(owned) do if D2(q,m)<12^2 then ours=true;break end end
            if not ours then
                -- Prefer scouting outward, not circling the home extractor ring.
                candidates[#candidates+1]={pos=Copy(m),marker=key,score=math.sqrt(D2(pos,m))-math.sqrt(D2(home,m))*0.55}
            end
        end
    end
    table.sort(candidates,function(a,b) return a.score==b.score and a.marker<b.marker or a.score<b.score end)
    for i=1,math.min(Config.TargetLimit,#candidates) do
        local c=candidates[i];local route=Route(p,pos,c.pos,speed,decision)
        if route.risk*1.5<=hp*Config.RiskFraction then c.route=route;c.kind="scout-alloy";return c end
    end
end
local function Send(p,us,goal)
    us=Units(p)
    if not Live(p) or #us==0 or (goal.unit and not Visible(p.army,goal.unit)) then return false end
    local op=p.ai.rushBomber;local nodes=goal.route.nodes
    if goal.unit then
        if AirOrders.RouteAttack(p,us,goal.unit,nodes)<=0 then return false end
        p.ai.eState="MicroingPlatoon";op.health=StrikeHealth(p.army,goal.unit,Refresh(p.army))
    else
        AirOrders.ClearPass(p,us)
        if AirOrders.RouteMove(p,us,nodes,goal.pos)<=0 then return false end
        p.ai.eState="MoveToTargetArea"
    end
    op.goal=goal;op.started=Now();op.progressAt=Now();op.unseenAt=nil;op.position=Position(us)
    p.ai.path=nodes;p.ai.gatherPoint=goal.pos;p.ai.primaryTarget=goal.unit or false
    State(p.army).claims[p]={platoon=p,platoonAI=p.ai,armyAI=p.army.ai,operation=op,unit=goal.unit,marker=goal.marker,
        damage=goal.damage or 0,untilTime=Now()+Config.ScoutSeconds+10}
    Log("[RushBomber] army="..p.army.id.." platoon="..p.id.." event="..goal.kind.." units="..#us
        .." target="..tostring(goal.unit and goal.unit.tpId or goal.marker).." risk="..math.floor(goal.route.risk)
        .." targetId="..tostring(goal.unit and goal.unit.id.index).." position="..string.format("%.1f,%.1f",goal.pos.x,goal.pos.z),true)
    return true
end
local function EndGoal(p,us,reason,block)
    local op=p.ai.rushBomber;local g=op.goal
    if g then
        if g.unit and block then op.blocked[g.unit]=Now()+block end
        if g.marker then State(p.army).visited[g.marker]=Now()+45 end
    end
    Release(p);op.goal=nil;p.ai.primaryTarget=false;p.ai.path=false
    op.nextAcquire=Now();op.unseenAt=nil;p.ai.eState="SelectMainTarget"
    if #us>0 then AirOrders.BreakOff(p,us,reason) end
    Log("[RushBomber] army="..p.army.id.." platoon="..p.id.." event=retarget reason="..reason.." targetId="..tostring(g and g.unit and g.unit.id.index),true)
end
local RESPONSE_LIMIT=24
local function MemberCurrent(army,response,p,member,now)
    return member and Live(p) and p.army==army and p.ai==member.ai and army.ai==response.armyAI
        and p.ai.rushBomber==member.operation and member.operation.response==response
        and now<member.expires and HasUnit(p)
end
local function Advanced(us)
    for _,u in ipairs(us) do
        if Tier(u.tp)<2 or AirOrders.MusterRadius(u)>160 then return false end
    end
    return #us>0
end
local function ResponseUnits(p,target)
    local result={}
    for _,u in ipairs(Units(p)) do
        if AirOrders.CommittedTo(p,u,target) then result[#result+1]=u end
    end
    return result
end
ResponseRiskScale=function(p,unit)
    local op=p.ai and p.ai.rushBomber;local response=op and op.goal and op.goal.response
    local state=p.army.ai and p.army.ai.rushBombers
    if not response or not state or state.response~=response or response.phase~="attack"
        or not Visible(p.army,response.target) or not AirOrders.CommittedTo(p,unit,response.target) then return 1 end
    local now=Now();local position=unit:GetPosition();local health=0
    for other,member in pairs(response.members) do
        if member.sent and MemberCurrent(p.army,response,other,member,now)
            and member.operation.goal and member.operation.goal.response==response then
            for _,u in ipairs(other:GetUnits() or {}) do
                -- Only a physically concentrated, accepted strike shares the AA
                -- casualty budget. Distant, dead or diverted wings add nothing.
                if Ready(p.army,u) and u.platoon==other and u.isAirborne~=false
                    and AirOrders.CommittedTo(other,u,response.target) and D2(position,u:GetPosition())<=192^2 then
                    health=health+Health(u)
                end
            end
        end
    end
    return math.min(1,Health(unit)/math.max(1,health))
end
local function GatherSite(army,alarm,target)
    local home=alarm.base;local aim=target:GetPosition()
    local dx,dz=home.x-aim.x,home.z-aim.z;local length=math.sqrt(dx*dx+dz*dz)
    if length<1 then dx,dz,length=1,0,1 end
    local radius=math.min(48,math.max(24,(alarm.radius or 100)*0.25))
    local best,score
    for _,angle in ipairs({0,math.pi/3,-math.pi/3,math.pi}) do
        local x,z=(dx*math.cos(angle)-dz*math.sin(angle))/length,(dx*math.sin(angle)+dz*math.cos(angle))/length
        local pos=Clamp({x=home.x+x*radius,y=home.y,z=home.z+z*radius})
        if pos then
            local risk=RouteRisk(army,{pos,pos},10)
            if not score or risk<score then best,score=pos,risk end
        end
    end
    return best
end
local function Response(army,alarm)
    local state=State(army);local now=Now();local response=state.response
    if response and response.armyAI==army.ai and response.baseRef==alarm.baseRef then
        local visible=Visible(army,response.target)
        if visible then response.lastSeen=now end
        if response.phase=="attack" and now<response.deadline and response.lastSeen
            and now-response.lastSeen<Config.VisionGraceSeconds then
            -- Existing accepted attacks tolerate a short contact flicker. The
            -- caller cannot launch another wing or read a hidden target here.
            for platoon,member in pairs(response.members) do
                if MemberCurrent(army,response,platoon,member,now) then return response end
            end
        end
        if response.phase=="attack" and now>=response.deadline then
            state.responseBlocked[response.target]=now+30;state.counterChoice=nil
        end
        if response.phase=="gather" and visible and alarm.bombardment then
            if now-response.created>=120 or response.fullSince and now-response.fullSince>=20 then
                state.responseBlocked[response.target]=now+45;state.counterChoice=nil
            else
                for _,record in ipairs(alarm.artilleryTargets or {}) do
                    if record.unit==response.target then return response end
                end
            end
        end
    end
    state.response=nil
    if not alarm.bombardment or not Valid(alarm.base) then return nil end
    local record=CounterTarget(army,alarm)
    if record and Visible(army,record.unit) then
        local site=GatherSite(army,alarm,record.unit)
        if site then
            response={target=record.unit,armyAI=army.ai,baseRef=alarm.baseRef,home=Copy(alarm.base),rally=site,
                phase="gather",created=now,lastSeen=now,members={},reviewAt=0}
            state.response=response;return response
        end
    end
end
local function MemberLess(a,b)
    if a.damage~=b.damage then return a.damage>b.damage end
    return a.platoon.id<b.platoon.id
end
local function SharedRoute(army,response,start,speed,intel)
    local nodes={Copy(start)};local length=0
    for i=2,#response.nodes do nodes[#nodes+1]=Copy(response.nodes[i]) end
    for i=2,#nodes do length=length+math.sqrt(D2(nodes[i-1],nodes[i])) end
    local risk,splash=RouteRisk(army,nodes,speed,{intel=intel,visible={}})
    return {nodes=nodes,length=length,risk=risk,splash=splash}
end
local function ReviewSalvo(army,response)
    local now=Now()
    if response.phase~="gather" or now<response.reviewAt or not Visible(army,response.target) then return end
    response.reviewAt=now+1
    local ready={};local intel=Refresh(army);local slowest=math.huge
    for platoon,member in pairs(response.members) do
        if not MemberCurrent(army,response,platoon,member,now) then response.members[platoon]=nil
        elseif member.ready then
            local us=Units(platoon);local close=Advanced(us);local health=0
            for _,unit in ipairs(us) do
                health=health+Health(unit)
                if D2(unit:GetPosition(),response.rally)>(AirOrders.MusterRadius(unit)+24)^2 or unit.isAirborne==false
                    or not AirOrders.Mustered(platoon,unit,response) then close=false end
            end
            if close then
                member.position=Position(us);member.count=#us;member.health=health
                member.damage=PassDamage(us,response.target);member.platoon=platoon
                local _,speed=Strength(us);member.speed=speed;slowest=math.min(slowest,speed)
                if member.damage>0 then ready[#ready+1]=member end
            end
        end
    end
    local readyCount=0
    for _,member in ipairs(ready) do readyCount=readyCount+member.count end
    if readyCount>=RESPONSE_LIMIT then response.fullSince=response.fullSince or now else response.fullSince=nil end
    if #ready==0 then return end
    table.sort(ready,MemberLess)
    response.nodes=Route(ready[1].platoon,response.rally,Copy(response.target:GetPosition()),slowest,
        {intel=intel,visible={}}).nodes
    local chosen={};local count,damage,health,direct,splash,travel=0,0,0,0,0,0
    local earliest
    for _,member in ipairs(ready) do
        local route=SharedRoute(army,response,member.position,member.speed,intel)
        local eta=route.length/member.speed
        -- Similar arrival times keep the actual flight together. A distant or
        -- slow wing never lends imaginary survivability to an earlier attack.
        if count+member.count<=RESPONSE_LIMIT and (not earliest or math.abs(eta-earliest)<=3) then
            earliest=earliest or eta;member.route=route
            chosen[#chosen+1]=member;count=count+member.count;damage=damage+member.damage
            health=health+member.health;direct=math.max(direct,route.risk-route.splash)
            splash=math.max(splash,route.splash);travel=math.max(travel,eta)
        end
    end
    local targetHealth=StrikeHealth(army,response.target,intel)
    local risk=(direct+splash*count)*1.5
    if count<2 or health<=0 or targetHealth<=0 then return end
    -- Prefer a finishing salvo; a two-pass attack is acceptable only after
    -- gathering and with enough real health for the additional AA exposure.
    local passes=damage*(1-risk/health)>=targetHealth*1.10 and 1 or 2
    if passes==2 and (now-response.created<10 or damage*(1-risk*2/health)*2<targetHealth*1.25) then return end
    if risk*passes>health*0.35 then return end
    response.phase="attack";response.arrivalAt=now+1+travel;response.deadline=response.arrivalAt+Config.AttackSeconds
    local selected={}
    for _,member in ipairs(chosen) do
        member.launchAt=now+1;member.sent=false;selected[member.platoon]=member
    end
    response.members=selected
end
local function ServiceResponse(p,us,alarm)
    local op=p.ai.rushBomber;local now=Now();local response=Response(p.army,alarm)
    if op.response and op.response~=response then
        if op.goal and op.goal.response then EndGoal(p,us,"artillery-contact-changed") end
        op.response=nil
    end
    if not response or not Advanced(us) or op.egressUntil
        or op.goal and op.goal.kind=="main-defense" then return false end
    local member=response.members[p]
    if member and not MemberCurrent(p.army,response,p,member,now) then response.members[p]=nil;member=nil end
    if response.phase=="attack" then
        if not MemberCurrent(p.army,response,p,member,now) then
            if op.goal and op.goal.response==response then EndGoal(p,us,"artillery-wing-detached") end
            if op.response==response then op.response=nil end
            return false
        end
        member.expires=now+3
        if member.sent then return false end
        if now<member.launchAt then
            p.ai.eState="BomberMuster";AirOrders.Muster(p,us,response.rally);return true
        end
        if not Visible(p.army,response.target) then
            response.members[p]=nil;op.response=nil;return false
        end
        for _,unit in ipairs(us) do
            if not AirOrders.Mustered(p,unit,response)
                or D2(unit:GetPosition(),response.rally)>(AirOrders.MusterRadius(unit)+32)^2 then
                response.members[p]=nil;op.response=nil;return false
            end
        end
        local target=Copy(response.target:GetPosition());local hp,speed=Strength(us)
        local route=SharedRoute(p.army,response,Position(us),speed,Refresh(p.army))
        -- New AA invalidates the assembled route; do not hide it behind the
        -- older shared casualty budget or force a late, isolated launch.
        if now>member.launchAt+3 or route.risk>member.route.risk*1.25+hp*0.10
            or route.splash>member.route.splash*1.25+hp*0.05 then
            response.members[p]=nil;op.response=nil;return false
        end
        local goal={unit=response.target,pos=target,kind="artillery-response",response=response,
            damage=PassDamage(us,response.target),health=StrikeHealth(p.army,response.target,Refresh(p.army)),route=route}
        if goal.damage<=0 or not Send(p,us,goal) then response.members[p]=nil;op.response=nil;return false end
        member.sent=true
        local claim=State(p.army).claims[p]
        if claim then claim.damage=PassDamage(ResponseUnits(p,response.target),response.target) end
        return true
    end
    if not member then
        if now<(op.blocked[response.target] or 0) then
            if op.response==response then op.response=nil end
            return false
        end
        for _,unit in ipairs(us) do if not AirOrders.CanMuster(p,unit) then return true end end
        local hp,speed=Strength(us);local position=Position(us)
        local stage=Route(p,position,response.rally,speed,{intel=Refresh(p.army),visible={}})
        if stage.risk*1.5>hp*Config.RiskFraction then return false end
        local count=0
        for other,current in pairs(response.members) do
            if MemberCurrent(p.army,response,other,current,now) then count=count+(current.count or 0)
            else response.members[other]=nil end
        end
        if count+#us>RESPONSE_LIMIT then
            local perUnit=PassDamage(us,response.target)/#us
            for _=1,Config.WingLimit do
                if count+#us<=RESPONSE_LIMIT then break end
                local weakest,score
                for other,current in pairs(response.members) do
                    local value=(current.damage or 0)/math.max(1,current.count or 0)
                    if other~=p and perUnit>value*1.25 and (not score or value<score) then weakest,score=other,value end
                end
                if not weakest then break end
                count=count-(response.members[weakest].count or 0);response.members[weakest]=nil
            end
        end
        if count+#us>RESPONSE_LIMIT then
            if op.response==response then op.response=nil end
            return false
        end
        if op.goal then EndGoal(p,us,"artillery-muster") end
        op.response=response;member={ai=p.ai,operation=op,expires=now+3,count=#us,stage=stage.nodes,
            joined=now,progressAt=now,bestDistance=D2(position,response.rally)};response.members[p]=member
    end
    op.response=response;member.expires=now+3;p.ai.eState="BomberMuster"
    local controlled,unsafe=AirOrders.Muster(p,us,response.rally,member.stage)
    if unsafe then
        Release(p);AirOrders.BreakOff(p,us,"anti-air")
        op.egressUntil=now+Config.EgressSeconds;p.ai.eState="Withdraw";return true
    end
    local damage,health,close=0,0,controlled==#us
    for _,unit in ipairs(us) do
        health=health+Health(unit)
        if D2(unit:GetPosition(),response.rally)>(AirOrders.MusterRadius(unit)+24)^2 or unit.isAirborne==false then close=false end
    end
    if Visible(p.army,response.target) then damage=PassDamage(us,response.target) end
    local distance=D2(Position(us),response.rally)
    if distance+64<(member.bestDistance or math.huge) then member.bestDistance=distance;member.progressAt=now end
    if not close and (now-member.joined>60 or now-member.progressAt>20) then
        Release(p);op.blocked[response.target]=now+15
        if controlled==#us then AirOrders.BreakOff(p,us,"artillery-gather-stalled") end
        p.ai.eState="SelectMainTarget";op.nextAcquire=now;return false
    end
    local _,speed=Strength(us)
    member.count,member.damage,member.health,member.speed,member.ready=#us,damage,health,speed,close and damage>0
    ReviewSalvo(p.army,response)
    return true
end
function Tick(p)
    if not Live(p) then return false end
    local us=Units(p)
    if #us==0 then
        -- An overridden orbit belongs to its newer order until that queue
        -- drains. Release claims without Exit/Reset touching the foreign work.
        Release(p);return HasUnit(p)
    end
    local op=p.ai.rushBomber;local now=Now();Refresh(p.army)
    us=Units(p);if not Live(p) then return false end
    if #us==0 then Release(p);return HasUnit(p) end
    local alarm=Frontline.MainAlarm(p.army)
    if alarm.active then
        for _,unit in ipairs(us) do AirOrders.CanMuster(p,unit) end
        us=Units(p)
        if #us==0 then Release(p);return HasUnit(p) end
    end
    local pos=Position(us)
    if not op.egressUntil and not (op.goal and op.goal.response) then
        local current=op.goal and op.goal.kind=="main-defense" and op.goal.unit
        local stillRaiding=false
        if current and Visible(p.army,current) and Valid(alarm.base)
            and D2(current:GetPosition(),alarm.base)>((alarm.radius or 100)+64)^2 then
            EndGoal(p,us,"main-raid-contained");current=nil
        end
        if current then
            for _,record in ipairs(alarm.raiders or {}) do if record.unit==current then stillRaiding=true;break end end
        end
        if alarm.localRaid and not stillRaiding then
            local defense=HomeDefenseTarget(p,us,alarm)
            if defense then
                if op.goal or op.response then EndGoal(p,us,"main-base-raid") end
                Send(p,us,defense)
            end
        end
    end
    if ServiceResponse(p,us,alarm) then return true end
    if op.egressUntil then
        if now<op.egressUntil then AirOrders.KeepFlying(p,us);return true end
        op.egressUntil=nil;op.nextAcquire=now
    end
    local g=op.goal
    if g and g.unit then
        if now-op.started>Config.AttackSeconds then
            EndGoal(p,us,"attack-deadline",20)
        elseif g.unit.dead or g.unit.deleted or g.unit.CaptureInProgress or g.unit.ReclaimInProgress
            or not p.army:IsEnemy(g.unit.army) then
            EndGoal(p,us,"target-dead-or-captured")
        elseif not Visible(p.army,g.unit) then
            -- A brief vision flicker during a turn must not restart the bombing
            -- run. Keep the already-issued native order only; do not read hidden
            -- position/health, select a hidden target or force a weapon to fire.
            op.unseenAt=op.unseenAt or now
            if now-op.unseenAt>=Config.VisionGraceSeconds then EndGoal(p,us,"contact-lost") end
        elseif PassDamage(us,g.unit)<=0 then
            -- Submerging, landing or a disabled loadout can remove every legal
            -- weapon without killing the target. Release the claim immediately.
            EndGoal(p,us,"target-unshootable",8)
        else
            op.unseenAt=nil
            local health=StrikeHealth(p.army,g.unit,Refresh(p.army))
            if health<op.health-1 then op.progressAt=now end
            op.health=health
            local hp,speed=Strength(us)
            local scale=1
            if g.response then
                scale=0
                for _,unit in ipairs(us) do scale=math.max(scale,ResponseRiskScale(p,unit)) end
            end
            local totalRisk,splash=RouteRisk(p.army,{pos,g.unit:GetPosition()},speed)
            local risk=((totalRisk-splash)*scale+splash)*1.5
            local passRisk,routeDenied=PassRouteRisk(p,us)
            risk=math.max(risk,passRisk)
            if routeDenied or risk>hp*0.85 then
                EndGoal(p,us,"anti-air",25)
                local toward=Clamp({x=pos.x+(op.home.x-pos.x)*0.35,y=pos.y,z=pos.z+(op.home.z-pos.z)*0.35})
                if toward then AirOrders.RouteMove(p,us,{pos,toward},toward) end
                op.egressUntil=now+Config.EgressSeconds;p.ai.eState="Withdraw"
            elseif now-op.progressAt>Config.NoDamageSeconds+g.route.length/speed then
                EndGoal(p,us,"no-effective-pass",20)
            else
                -- Complete one native attack pass, extend, turn, and re-enter.
                -- Other wing members' healthy runs and AA doglegs are retained.
                AirOrders.Attack(p,g.unit,us)
                local claims=State(p.army).claims
                local claim=claims[p] or {};claims[p]=claim
                claim.platoon,claim.platoonAI,claim.armyAI,claim.operation,claim.unit,claim.marker=p,p.ai,p.army.ai,op,g.unit,nil
                claim.damage,claim.untilTime=PassDamage(g.response and ResponseUnits(p,g.unit) or us,g.unit),now+10
            end
        end
    elseif g then
        if D2(pos,g.pos)<24^2 or now-op.started>Config.ScoutSeconds then EndGoal(p,us,"scout-leg-finished")
        elseif now>=(op.nextAcquire or 0) then
            op.nextAcquire=now+Config.AcquireSeconds
            local target=SelectTarget(p,us)
            if target then Release(p);Send(p,us,target) end
        end
    end
    if not op.goal and not op.egressUntil and now>=(op.nextAcquire or 0) then
        op.nextAcquire=now+Config.AcquireSeconds
        local goal=SelectTarget(p,us) or SelectScout(p,us)
        if goal then Send(p,us,goal) else p.ai.eState="SelectMainTarget" end
    end
    AirOrders.KeepFlying(p,us)
    return true
end
function Run(p,index,baseName,former,hooks)
    local army,initialAI=p.army,p.ai
    local armyAI=army and army.ai
    local base=army and army.ai and army.ai.bases and army.ai.bases[baseName]
    if not base or army.ai.isAlive==false then hooks.Exit(p);return end
    local units,minimum,maximum,reserve=AF.GetNeedUnits(index,baseName,former)
    if p.army~=army or army.ai~=armyAI or p.ai~=initialAI then return end
    if not Live(p) or army.ai.bases[baseName]~=base then hooks.Exit(p);return end
    local selected={};local available={};local byTier={}
    for _,u in ipairs(units or {}) do
        if Ready(army,u) and not u.platoon
            and not u.unitBeingBuilt and not (u.buildQueue and next(u.buildQueue)) then
            available[#available+1]=u
            local tier=Tier(u.tp)
            byTier[tier]=byTier[tier] or {};byTier[tier][#byTier[tier]+1]=u
        end
    end
    local limit=math.min(#available-math.max(0,reserve or 0),maximum or Config.WingLimit,Config.WingLimit)
    minimum=math.max(1,minimum or 1)
    -- Different tech levels fly separate wings: a surviving T1 escort must not
    -- impose its health/speed risk limit on an otherwise capable T2/T3 strike.
    for tier=3,1,-1 do
        local candidates=byTier[tier]
        if candidates and math.min(#candidates,limit)>=minimum then
            table.sort(candidates,function(a,b) return a.id.index<b.id.index end)
            for i=1,math.min(#candidates,limit) do selected[#selected+1]=candidates[i] end
            break
        end
    end
    if #selected<minimum then hooks.Exit(p);return end
    p:AssignUnits(selected)
    for _,u in ipairs(selected) do if hooks.Reset then hooks.Reset(u,"RushBomber") end;u.ai=u.ai or {};u.ai.eState="PlatoonControlled" end
    p.ai={formerTable=former,baseName=baseName,basePosition=Copy(base.position),baseRadius=base.radius,
        movementLayer="Air",targetLayer="Land",eState="SelectMainTarget",creationTime=GetFormatedGameTime(),
        rushBomber={home=Copy(base.position),blocked=setmetatable({},{__mode="k"}),nextAcquire=Now()}}
    local ai=p.ai
    p:SetUniqueName("RushBomber-"..p.id);State(army).wings[p]=ai
    while Live(p) and p.army==army and army.ai==armyAI and p.ai==ai and Tick(p) do
        WaitTicks((Constants and Constants.TickRate) or 10)
    end
    if army.ai==armyAI and State(army).wings[p]==ai then State(army).wings[p]=nil end
    if p.army==army and army.ai==armyAI and p.ai==ai then Release(p);hooks.Exit(p) end
end
