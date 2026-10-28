-- Native Sanctuary tactical policy. Enemy knowledge is the existing AI's knowledge;
-- no new visibility grants, map reveals, movement bypasses or weapon modifications.
Version = "9.0.25-rc30"
local AF=Import("AI/AIFunctions.lua")
local MG=Import("AI/AIMarkerGenerator.lua")
local TM=Import("AI/AITargetManager.lua")
local Orders=Import("host/managers/orders/hostOrderManager.lua")
local Tasks=Import("common/commonOrders.lua").OrderTasks
local Reliability=Import("AI/mods/AI-Scom/RushReliability.lua")
local PathBudget=Import("AI/mods/AI-Scom/RushPathBudget.lua")
local Intel=Import("AI/mods/AI-Scom/RushCombatIntel.lua")
local Development=Import("AI/mods/AI-Scom/RushDevelopment.lua")
local bit=require("bit")
local function Now() return GetGameTimeSeconds() end
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local function D3(a,b) return D2(a,b)+((a.y or 0)-(b.y or 0))^2 end
local function Copy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function Has(tp,tag)
    if not tp then return false end
    if tp.hasTags and tp.hasTags[tag] then return true end
    for _,v in ipairs(tp.tags or {}) do if v==tag then return true end end
    return false
end
local function Heat(army,pos,layer)
    if type(TM.GetThreatFromHeatMapPosition)~="function" then return nil end
    local ok,v=pcall(TM.GetThreatFromHeatMapPosition,army.id,pos,layer)
    return ok and type(v)=="number" and math.max(0,v) or nil
end
local function VisibleEnemy(army,unit)
    return unit and not unit.dead and not unit.deleted and not unit.CaptureInProgress
        and not unit.ReclaimInProgress and unit.army and army:IsEnemy(unit.army)
        and ((type(unit.IsIntelVisionVisible)=="function" and unit:IsIntelVisionVisible(army))
            or (type(unit.IsIntelRadarVisible)=="function" and unit:IsIntelRadarVisible(army))) or false
end
local function Enemies(army)
    return AF.GetEnemyUnitsOnMap(army.id)
end
function ValidAirTarget(platoon,target)
    if not VisibleEnemy(platoon.army,target) or target.isAirborne~=true
        or not Has(target.tp,"AIR") then return false end
    for _,u in pairs(platoon:GetUnits()) do
        if not u.dead and not u.deleted and u.army==platoon.army and u.platoon==platoon
            and not u.CaptureInProgress and not u.ReclaimInProgress
            and not (u.ai and u.ai.eState=="RepairHome") then
            for _,w in ipairs(u.weapons or {}) do
                if w.enabled and not w.isDeathExplosion and type(w.CanShootAt)=="function"
                    and w:CanShootAt(target) then return true end
            end
        end
    end
    return false
end
local aaCache=setmetatable({},{__mode="k"})
local function GroundAA(army,pos)
    local cache=aaCache[army]
    if not cache or Now()<cache.at or Now()-cache.at>=2 then
        cache={at=Now(),weapons={},cells={}};aaCache[army]=cache
        for _,enemy in ipairs(Enemies(army)) do
            if VisibleEnemy(army,enemy) and enemy:IsCompleted() and not Has(enemy.tp,"AIR") then
                for _,weapon in ipairs(enemy.weapons or {}) do
                    local w=weapon.tp or weapon
                    if weapon.enabled~=false and not weapon.isDeathExplosion
                        and (w.rangeRingType=="AntiAir" or weapon.rangeRingType=="AntiAir")
                        and type(w.rangeMax)=="number" then
                        local damage=type(w.damage)=="number" and w.damage or 0
                        local rate=type(w.reloadTime)=="number" and w.reloadTime>0 and 1/w.reloadTime or 1
                        cache.weapons[#cache.weapons+1]={unit=enemy,weapon=weapon,pos=Copy(enemy:GetPosition()),
                            radius=w.rangeMax+12,damage=math.max(1,damage*rate)}
                    end
                end
            end
        end
    end
    local key=math.floor(pos.x/8)..":"..math.floor(pos.z/8)
    if cache.cells[key]~=nil then return cache.cells[key] end
    local threat=0
    for _,w in ipairs(cache.weapons) do
        if not w.unit.dead and not w.unit.deleted and army:IsEnemy(w.unit.army)
            and not w.unit.CaptureInProgress and not w.unit.ReclaimInProgress
            and w.weapon.enabled~=false then
            local distance=math.sqrt(D2(pos,w.pos))
            if distance<w.radius then threat=threat+w.damage*(1-distance/w.radius) end
        end
    end
    cache.cells[key]=threat
    return threat
end
local function Fallback(platoon)
    local army=platoon.army
    local origin=platoon.ai.basePosition or army.ai.bases.MAIN.position
    local best=origin
    local bestHeat=Heat(army,origin,"Air") or math.huge
    for _,base in pairs(army.ai.bases or {}) do
        local h=Heat(army,base.position,"Air")
        if h and h<bestHeat then best,bestHeat=base.position,h end
    end
    return {x=best.x,y=best.y,z=best.z}
end
function AirTarget(platoon,position,radius)
    local army=platoon.army
    local origin=Copy(position or platoon:GetPosition())
    local base=platoon.ai.basePosition or origin
    local best,bestScore
    local ownThreat=math.max(1,platoon.ai.threat or 0)
    local enemies=Enemies(army)
    radius=radius or 2048
    for _,enemy in ipairs(enemies) do
        if VisibleEnemy(army,enemy) and enemy.isAirborne==true and Has(enemy.tp,"AIR") then
            local p=Copy(enemy:GetPosition())
            local distance=D2(origin,p)
            if distance<=radius*radius and ValidAirTarget(platoon,enemy) then
                local airHeat=Heat(army,p,"Air")
                local groundAA=GroundAA(army,p)
                local home=D2(base,p)<math.max(60,platoon.ai.baseRadius or 90)^2
                -- Do not turn an air interception into a permanent ground-AA dive.
                if airHeat and airHeat<=ownThreat*(home and 1.6 or 0.95)
                    and (home or groundAA<math.max(8,ownThreat*0.03)) then
                    local value=(enemy.tp.economy and enemy.tp.economy.cost and enemy.tp.economy.cost.alloys) or 50
                    local score=(home and 300 or 0)+(Has(enemy.tp,"BOMBER") and 160 or 0)
                        +(Has(enemy.tp,"GUNSHIP") and 140 or 0)+math.sqrt(value)*3
                        -math.sqrt(distance)*0.30-groundAA*2
                    if enemy==platoon.ai.rushAirTarget then score=score+35 end
                    if not bestScore or score>bestScore or (score==bestScore and enemy.id.index<best.id.index) then
                        best,bestScore=enemy,score
                    end
                end
            end
        end
    end
    platoon.ai.rushAirTarget=best
    return best
end
function AirArea(platoon)
    local target=AirTarget(platoon)
    if target then return Copy(target:GetPosition()) end
    return Fallback(platoon)
end
function AirGuard(platoon)
    local now=Now()
    if now<(platoon.ai.rushAirGuardUntil or 0) then return true end
    local pos=Copy(platoon:GetPosition())
    local own=math.max(1,platoon.ai.threat or 0)
    local bad=GroundAA(platoon.army,pos)>math.max(10,own*0.03)
    local injured,total=0,0
    local units={}
    for _,u in pairs(platoon:GetUnits()) do
        if Reliability.Own(platoon.army,u) and u.platoon==platoon
            and not u.CaptureInProgress and not u.ReclaimInProgress
            and not (u.ai and u.ai.eState=="RepairHome") then
            units[#units+1]=u
            total=total+1
            if type(u.GetHealth)=="function" and type(u.GetMaxHealth)=="function"
                and u:GetHealth()<u:GetMaxHealth()*0.38 then injured=injured+1 end
        end
    end
    local noUsefulTarget=not ValidAirTarget(platoon,platoon.ai.microTarget)
    if bad and (noUsefulTarget or injured>=math.max(1,total*0.25)) then
        local dest=Fallback(platoon)
        if D2(pos,dest)>35*35 then
            Orders.HostIssueOrder(Tasks.MOVE,units,false,dest,nil)
            for _,u in ipairs(units) do
                if type(u.SetWeaponPreferredTarget)=="function" then u:SetWeaponPreferredTarget(nil) end
            end
            platoon.ai.rushAirGuardUntil=now+8
            platoon.ai.primaryTargetAreaPos=dest
            platoon.ai.microTarget=false
            return true
        end
    end
    return false
end
local function PathCost(army,path,start,layer,ownThreat)
    local last=start
    local distance,exposure=0,0
    local stride=math.max(1,math.floor(#path/16))
    for i,node in ipairs(path) do
        distance=distance+math.sqrt(D2(last,node));last=node
        if i%stride==0 or i==#path then
            local h=Heat(army,node,layer)
            if not h then return math.huge,math.huge end
            exposure=exposure+h/math.max(1,ownThreat)
        end
    end
    return distance+exposure*65,distance
end
-- Compare connected native routes via opposite approach corridors. Every leg is
-- generated by the normal threat-aware graph. No direct orders through cliffs.
function FlankPath(platoon,start,destination,layer,maxThreat,direct)
    local ai,owner=platoon.ai,platoon.army;local operation=ai.rushOperation
    local armyAI=owner.ai;local movementLayer=ai.movementLayer
    local withdrawing=ai.withdraw;local phase=operation and operation.policy and operation.policy.phase
    start,destination=Copy(start),Copy(destination)
    local function current()
        return not platoon.dead and not platoon.deleted and platoon.ai==ai and platoon.army==owner
            and ai.rushOperation==operation and owner.ai==armyAI and armyAI.isAlive~=false
            and ai.movementLayer==movementLayer and ai.withdraw==withdrawing
            and (operation and operation.policy and operation.policy.phase)==phase and owner:PlatoonExists(platoon)
    end
    local data=ai.formerTable and ai.formerTable.AIPlanData
    if type(direct)~="table" or #direct==0 or not data or not data.RushFlank or layer=="Air"
        or ai.isNavalPlatoon or ai.emergencyTargetActive or ai.withdraw
        or (operation and operation.policy and operation.policy.phase=="Retreat")
        or (ai.eState and (ai.eState:find("Withdraw",1,true)
            or ai.eState:find("Grouping",1,true))) then return direct end
    local distance=math.sqrt(D2(start,destination))
    if distance<100 then ai.rushFlankCorridor=nil;return direct end
    local corridor=ai.rushFlankCorridor
    if Now()<(ai.rushNextFlank or 0) then
        -- A normal target refresh must not replace a just-selected flank with
        -- the direct route before the platoon even reaches its approach point.
        if corridor and D2(corridor.destination,destination)<25*25
            and D2(start,corridor.via)>20*20
            and (corridor.via.x-start.x)*(destination.x-start.x)
                +(corridor.via.z-start.z)*(destination.z-start.z)>0 then
            if ai.rushOperation and not PathBudget.Extra(platoon,2) then return direct end
            local first=MG.GeneratePathTo(owner.id,start,corridor.via,layer,true,maxThreat)
            if not current() then return nil,"stale-request" end
            local second=first and MG.GeneratePathTo(owner.id,corridor.via,destination,layer,true,maxThreat)
            if not current() then return nil,"stale-request" end
            if type(first)=="table" and #first>0 and type(second)=="table" and #second>0 then
                local combined={}
                for _,node in ipairs(first) do combined[#combined+1]=Copy(node) end
                for _,node in ipairs(second) do combined[#combined+1]=Copy(node) end
                local score,length=PathCost(owner,combined,start,layer,maxThreat)
                local directScore,directLength=PathCost(owner,direct,start,layer,maxThreat)
                -- A remembered corridor expires when progress makes it a long
                -- backward lap or its original threat advantage has disappeared.
                if score<math.huge and length<math.huge and directScore<math.huge and directLength<math.huge
                    and length<=directLength*1.5 and score<=directScore*1.1 then return combined end
            end
        end
        ai.rushFlankCorridor=nil
        return direct
    end
    ai.rushNextFlank=Now()+18
    ai.rushFlankCorridor=nil
    local best=direct
    local bestScore,directDistance=PathCost(platoon.army,direct,start,layer,maxThreat)
    local dx,dz=(destination.x-start.x)/distance,(destination.z-start.z)/distance
    local offset=math.min(110,distance*0.30)
    local prefer=(tonumber(platoon.id) or 0)%2==0 and 1 or -1
    for _,side in ipairs({prefer,-prefer}) do
        local via={x=start.x+dx*distance*0.65-dz*offset*side,y=destination.y,
            z=start.z+dz*distance*0.65+dx*offset*side}
        local inside=type(AF.isPosWithinPlayableArea)=="function" and AF.isPosWithinPlayableArea(via)
        if inside and MG.CanGraphAreaTo(start,via,layer) and MG.CanGraphAreaTo(via,destination,layer) then
            if ai.rushOperation and not PathBudget.Extra(platoon,2) then break end
            local first=MG.GeneratePathTo(owner.id,start,via,layer,true,maxThreat)
            if not current() then return nil,"stale-request" end
            local second=first and MG.GeneratePathTo(owner.id,via,destination,layer,true,maxThreat)
            if not current() then return nil,"stale-request" end
            if type(first)=="table" and #first>0 and type(second)=="table" and #second>0 then
                local combined={}
                for _,node in ipairs(first) do combined[#combined+1]=Copy(node) end
                for _,node in ipairs(second) do combined[#combined+1]=Copy(node) end
                local score,length=PathCost(platoon.army,combined,start,layer,maxThreat)
                -- A modest corridor preference spreads groups without accepting huge detours.
                score=score*(side==prefer and 0.90 or 1)
                if length<=directDistance*1.5 and score<bestScore then
                    best,bestScore=combined,score;ai.rushApproachSide=side
                    ai.rushFlankCorridor={via=via,
                        destination={x=destination.x,y=destination.y,z=destination.z}}
                end
            end
        end
    end
    return best
end

function ReclaimTarget(builder,reserved,unreachable)
    local platoon,army=builder.platoon,builder.army
    local unitAI,platoonAI=builder.ai,platoon and platoon.ai
    if not Reliability.CurrentAssignment(builder,army,platoon,unitAI,platoonAI) then return nil end
    local origin=Copy(builder:GetPosition())
    local candidates={}
    for _,prop in pairs(__Entities.Props or {}) do
        local blocked=unreachable[prop]
        if type(blocked)=="number" and Now()-blocked>60 then unreachable[prop]=nil;blocked=nil end
        if not prop.dead and not prop.deleted and not blocked and not (prop.reclaimers and next(prop.reclaimers)) then
            local p=Copy(prop:GetPosition());local clear=true
            for _,r in ipairs(reserved or {}) do if D2(p,r)<=100 then clear=false;break end end
            local harvest=prop.tp and prop.tp.economy and prop.tp.economy.harvest
            local value=harvest and (harvest.alloys or 0) or 0
            if clear and value>0 and Reliability.Inside(p,1) then
                -- Valuable wreck clusters can beat nearby low-value rocks.
                local score=math.sqrt(value)/(30+math.sqrt(D2(origin,p)))
                candidates[#candidates+1]={prop=prop,pos=p,score=score}
            end
        end
    end
    table.sort(candidates,function(a,b)
        if a.score~=b.score then return a.score>b.score end
        return a.prop.id.index<b.prop.id.index
    end)
    local pathChecks=0
    for _,item in ipairs(candidates) do
        local land=Heat(army,item.pos,"Land")
        local air=Heat(army,item.pos,"Air")
        if land and land==0 and air and air==0 then
            pathChecks=pathChecks+1
            local path=MG.GeneratePathTo(army.id,origin,item.pos,platoon.ai.movementLayer,true,0)
            if not Reliability.CurrentAssignment(builder,army,platoon,unitAI,platoonAI) then return nil end
            if not item.prop.dead and not item.prop.deleted then
                if type(path)=="table" and #path>0 and not (item.prop.reclaimers and next(item.prop.reclaimers)) then
                    return item.prop,path
                end
                if type(path)~="table" or #path==0 then unreachable[item.prop]=Now() end
            end
            if pathChecks>=8 then break end
        end
    end
    return nil
end

local function CurrentCommander(platoon,unit)
    return platoon and not platoon.deleted and platoon.ai and unit and unit.ai
        and (Has(unit.tp,"COMMAND") or Has(unit.tp,"SCFA_COMMAND"))
        and Reliability.CurrentAssignment(unit,platoon.army,platoon,unit.ai,platoon.ai)
        and not unit.CaptureInProgress and not unit.ReclaimInProgress
end
local function KnownCommanderEnemy(army,unit)
    return VisibleEnemy(army,unit)
end
local function WeaponDPS(weapon)
    return math.max(0,AF.GetWeaponDamagePerSecond(weapon.tp or weapon) or 0)
end
local function ShieldEnabled(shield)
    return shield and not shield.deleted and type(shield.IsEnabled)=="function" and shield:IsEnabled()
        and type(shield.GetHealth)=="function" and shield:GetHealth()>0
end
-- Share known weapon/shield candidates with the existing half-second intel epoch.
-- Final health, enabled state and visibility are still checked live.
local commanderIntel=setmetatable({},{__mode="k"})
local function CommanderIntel(army)
    local shared=Intel.Get(army);local cached=commanderIntel[army]
    if cached and cached.shared==shared then return cached end
    cached={shared=shared,weapons={},shields={}};commanderIntel[army]=cached
    for _,record in ipairs(shared.enemy) do
        local enemy=record.unit
        if KnownCommanderEnemy(army,enemy) and enemy:IsCompleted() then
            for _,weapon in ipairs(enemy.weapons or {}) do
                local tp=weapon.tp or weapon
                if not weapon.isDeathExplosion and (tp.rangeMax or 0)>0 then
                    local dps=WeaponDPS(weapon)
                    if dps>0 then cached.weapons[#cached.weapons+1]={unit=enemy,weapon=weapon,
                        position=record.pos,range=tp.rangeMax,dps=dps} end
                end
            end
            for _,shield in ipairs(enemy.shields or {}) do
                local tp=shield.tp;local radii=tp and tp.radii
                if tp and (tp.type=="Personal" or tp.type=="Bubble" and radii
                    and (radii.x or 0)>0 and (radii.z or radii.x)>0) then
                    cached.shields[#cached.shields+1]={unit=enemy,shield=shield,position=record.pos,
                        personal=tp.type=="Personal",offset=tp.offset or {},
                        x=radii and radii.x,z=radii and (radii.z or radii.x)}
                end
            end
        end
    end
    return cached
end
local function CommanderTargetHealth(army,target,known)
    local health=math.max(0,target:GetHealth());local position=Copy(target:GetPosition())
    for _,record in ipairs(known.shields) do
        if KnownCommanderEnemy(army,record.unit) and ShieldEnabled(record.shield) then
            local covers=record.personal and record.unit==target
            if not record.personal then
                local dx=(position.x-record.position.x-(record.offset.x or 0))/record.x
                local dz=(position.z-record.position.z-(record.offset.z or 0))/record.z
                covers=dx*dx+dz*dz<=1
            end
            if covers then health=health+record.shield:GetHealth() end
        end
    end
    return health
end
local function IncomingCommanderDPS(army,unit,position,seconds,known)
    local damage=0
    for _,record in ipairs(known.weapons) do
        local weapon,enemy=record.weapon,record.unit
        if weapon.enabled and KnownCommanderEnemy(army,enemy) then
            local targetMask=weapon.layerTargetLimitsMask
            local weaponMask=weapon.layerWeaponLimitsMask
            local compatible=(not targetMask or targetMask==0 or not unit.targetingLayer
                    or bit.band(unit.targetingLayer,targetMask)~=0)
                and (not weaponMask or weaponMask==0 or not enemy.targetingLayer
                    or bit.band(enemy.targetingLayer,weaponMask)~=0)
            local speed=Has(enemy.tp,"MOBILE") and enemy.tp.movement and enemy.tp.movement.speed or 0
            local reach=record.range+math.max(0,speed or 0)*math.min(6,seconds)
            if compatible and D2(position,record.position)<=reach*reach then damage=damage+record.dps end
        end
    end
    return damage
end
local function DeathBlast(target,range)
    local damage=0
    -- Match native CreateDeathExplosions: these authored template weapons,
    -- including their real radius, are separate from normal enabled guns.
    for _,weapon in ipairs(target.tp.weapons or {}) do
        if weapon.category=="DeathExplosion" and (weapon.damageRadius or 0)>=range then
            damage=damage+math.max(0,weapon.damage or 0)
        end
    end
    return damage
end
local function AttackPoint(origin,target,range,minimum)
    local dx,dz=target.x-origin.x,target.z-origin.z;local distance=math.sqrt(dx*dx+dz*dz)
    local stand=math.min(range-0.5,math.max(minimum+1,range*0.85))
    local travel=math.max(0,distance-math.max(1,stand))
    if distance<=0 then return {x=origin.x,y=origin.y,z=origin.z},0,stand end
    return {x=origin.x+dx/distance*travel,y=origin.y,z=origin.z+dz/distance*travel},travel,stand
end
-- Read-only policy for both target selection and native per-unit micro. A short
-- range laser must not be selected by one controller while another holds gun range.
function CommanderCombatProfile(platoon,unit,target)
    if not CurrentCommander(platoon,unit) then return nil end
    local intent=Development.CommanderRole(unit) or {role="offense",niche="line"}
    local support=intent.role=="support"
    local profile={role=intent.role,niche=intent.niche,scoreBonus=0,canAdvance=true,
        healthFloor=support and 0.70 or 0.55,searchScale=support and 0.65 or 1,
        strengthScale=support and 0.85 or 1}
    if target and not KnownCommanderEnemy(platoon.army,target) then profile.canAdvance=false;return profile end
    local weapons={};local longest,strongest
    local layer=platoon.ai.targetLayer or "Land"
    for _,weapon in ipairs(unit.weapons or {}) do
        local tp=weapon.tp or weapon;local range=tp.rangeMax or 0
        local allowed=target and type(weapon.CanShootAt)=="function" and weapon:CanShootAt(target)
        if not target and tp.rangeRingType~="AntiAir" then
            local limits=tp.layerTargetLimits or {}
            allowed=#limits==0
            for _,candidate in ipairs(limits) do if candidate==layer then allowed=true;break end end
            local mask=weapon.layerWeaponLimitsMask
            if mask and mask~=0 and unit.targetingLayer and bit.band(unit.targetingLayer,mask)==0 then allowed=false end
        end
        if weapon.enabled and not weapon.isDeathExplosion and range>0 and allowed then
            local dps=WeaponDPS(weapon)
            if dps>0 then
                local record={weapon=weapon,range=range,minimum=tp.rangeMin or 0,dps=dps}
                weapons[#weapons+1]=record
                if not longest or range>longest.range or range==longest.range and dps>longest.dps then longest=record end
                if not strongest or dps>strongest.dps or dps==strongest.dps and range>strongest.range then strongest=record end
            end
        end
    end
    if not longest then profile.canAdvance=false;return profile end
    local selected=longest
    local health,maxHealth=unit:GetHealth(),math.max(1,unit:GetMaxHealth())
    profile.canAdvance=health>=maxHealth*profile.healthFloor
        and not platoon.ai.commanderFacesLethalDamage
    if target then
        local position=Copy(unit:GetPosition());local targetPosition=Copy(target:GetPosition())
        local distance=math.sqrt(D2(position,targetPosition))
        local commandTarget=Has(target.tp,"COMMAND") or Has(target.tp,"SCFA_COMMAND")
        local inContact=type(strongest.weapon.IsTargetInRange)=="function"
            and strongest.weapon:IsTargetInRange(target)
        local seekClose=not support and profile.canAdvance and health>=maxHealth*0.70
            and distance<=longest.range+20
        if commandTarget or strongest~=longest and (inContact or seekClose) then
            local known=CommanderIntel(platoon.army)
            local targetHealth=CommanderTargetHealth(platoon.army,target,known)
            local speed=math.max(1,unit.tp.movement and unit.tp.movement.speed or 1)
            local function viable(record)
                local destination,travel,stand=AttackPoint(position,targetPosition,record.range,record.minimum)
                local approach=travel/speed;local dps,delay=0,0
                for _,gun in ipairs(weapons) do
                    if gun.range>=stand and gun.minimum<=stand then
                        local weapon=gun.weapon
                        local wait=math.max(0,(weapon.reloadTimer or 0)-approach)
                        if (weapon.salvosRemaining or 0)>0 or (weapon.beamLifetimeCountdown or 0)>0 then wait=0 end
                        dps=dps+gun.dps;delay=delay+gun.dps*wait
                    end
                end
                local seconds=(targetHealth+delay)/math.max(1,dps*0.75)
                local exposed=seconds+approach+2
                local incoming=IncomingCommanderDPS(platoon.army,unit,destination,exposed,known)
                local remains=health-incoming*exposed-DeathBlast(target,math.min(distance,stand))
                return seconds<=12 and remains>=maxHealth*0.40,seconds,seconds+approach
            end
            local safeRanged,rangedSeconds,rangedTotal=viable(longest)
            local safeClose,closeSeconds,closeTotal=safeRanged,rangedSeconds,rangedTotal
            if strongest~=longest then safeClose,closeSeconds,closeTotal=viable(strongest) end
            -- Shooting the gun now is preferable to walking into laser range when
            -- the approach erases the beam's damage advantage.
            if profile.canAdvance and safeClose and (inContact or seekClose and closeTotal<rangedTotal*0.85) then selected=strongest end
            profile.killSeconds=selected==strongest and closeSeconds or rangedSeconds
            if commandTarget then
                local safeKill=selected==strongest and safeClose or selected~=strongest and safeRanged
                if safeKill and profile.canAdvance then profile.scoreBonus=240+math.max(0,12-profile.killSeconds)*20
                elseif support then profile.scoreBonus=-120 end
            end
        end
        local destination=AttackPoint(position,targetPosition,selected.range,selected.minimum)
        local base=platoon.ai.basePosition
        if support and base and D2(destination,base)>(platoon.ai.baseRadius or 60)^2 then
            local cover=Intel.FriendlyThreat(platoon,destination,55,"Land",true)
            local own=math.max(1,AF.GetUnitThreatValueByLayer(unit,"Land"))
            if cover<own*0.50 then profile.canAdvance=false end
        end
    end
    profile.weapon,profile.range,profile.minRange=selected.weapon,selected.range,selected.minimum
    return profile
end
local function CommanderCoverRadius(unit,intent)
    local state=unit.scoCommanderEnhancements;local shieldRadius,auraRadius=0,0
    if intent.ready and intent.ready.aura and state and state._auraThread and state._auraSignature then
        local contract=rawget(_G,"SCO_CommanderEnhancementContract")
        if not contract then
            local ok,loaded=pcall(Import,"common/systems/scoCommanderEnhancements.lua")
            if ok and type(loaded)=="table" then contract=loaded.SCO_CommanderEnhancementContract or loaded end
        end
        local commander=contract and contract.commanders and contract.commanders[unit.tpId]
        local rule=commander and commander.enhancements[state._auraSignature]
        local aura=rule and rule.effects and rule.effects.aura
        if aura and (aura.regenPerSecond or 0)>0 then auraRadius=aura.radius or 0 end
    end
    if intent.ready and intent.ready.shield then
        for _,shield in ipairs(unit.shields or {}) do
            local tp=shield.tp;local radii=tp and tp.radii
            if tp and tp.type=="Bubble" and radii and ShieldEnabled(shield) then
                local offset=tp.offset or {}
                local centered=math.min(radii.x or 0,radii.z or radii.x or 0)
                    -math.sqrt((offset.x or 0)^2+(offset.z or 0)^2)
                shieldRadius=math.max(shieldRadius,centered)
            end
        end
    end
    local footprint=unit.tp.footprint or {}
    local minimum=math.max(footprint.x or 0,footprint.y or 0)*0.5+5
    if shieldRadius<=minimum then shieldRadius=0 end
    if auraRadius<=minimum then auraRadius=0 end
    return shieldRadius,auraRadius
end
local function SupportTroop(army,unit)
    local ai=unit.platoon and unit.platoon.ai
    local operation=ai and ai.rushOperation
    return Reliability.Own(army,unit) and unit:IsCompleted() and not unit.CaptureInProgress and not unit.ReclaimInProgress
        and Has(unit.tp,"MOBILE") and not Has(unit.tp,"AIR") and not Has(unit.tp,"NAVAL")
        and not Has(unit.tp,"ENGINEER") and not Has(unit.tp,"COMMAND") and not Has(unit.tp,"SCFA_COMMAND")
        and not Has(unit.tp,"SCOUT") and (AF.GetUnitThreatValueByLayer(unit,"Land")>0 or AF.GetUnitThreatValueByLayer(unit,"Air")>0)
        and not (unit.ai and unit.ai.eState=="RepairHome") and not (unit.toggles and unit.GetPause and unit:GetPause())
        and not (ai and (ai.withdraw or ai.eState=="Withdraw" or operation and operation.policy and operation.policy.phase=="Retreat"))
end
-- Position an actual aura/area shield with useful own troops. The caller owns
-- movement and rechecks this anchor; engineering-only support keeps doing home work.
function CommanderSupportPosition(platoon,unit)
    if not CurrentCommander(platoon,unit) then return nil end
    local army,unitAI,data=platoon.army,unit.ai,platoon.ai
    local intent=Development.CommanderRole(unit)
    if not intent or intent.role~="support" then return nil end
    local shieldRadius,auraRadius=CommanderCoverRadius(unit,intent)
    if math.max(shieldRadius,auraRadius)<=0 or data.commanderFacesLethalDamage or data.commanderIsInImmediateDanger
        or data.commanderUnderAttack or unit:GetHealth()<unit:GetMaxHealth()*0.75 then return nil end
    local origin,base=Copy(unit:GetPosition()),data.basePosition
    if not base then return nil end
    local reach=math.min(160,math.max(80,(data.baseRadius or 60)*2))
    local candidates={};local own=math.max(1,AF.GetUnitThreatValueByLayer(unit,"Land"))
    for _,friend in ipairs(Intel.FriendlyUnitsInRadius(army,origin,reach)) do
        if friend~=unit and SupportTroop(army,friend) then
            local position=Copy(friend:GetPosition());local missing=1-friend:GetHealth()/math.max(1,friend:GetMaxHealth())
            local auraAllowed=auraRadius>0 and (not Tags or not Tags.BUILDABLE_BY_T3_FACTORY
                or friend:HasTags(Tags.BUILDABLE_BY_T3_FACTORY))
            local radius=math.max(shieldRadius,auraAllowed and auraRadius or 0)
            local exposure=Intel.Exposure(army,position,"Land",radius)
            if exposure.total<=0 then radius=missing>0.05 and auraAllowed and auraRadius or 0 end
            if radius>0 and (not data.commanderStaysHome or D2(position,base)<=(data.baseRadius or 60)^2) then
                local threat=exposure.center or position
                local dx,dz=base.x-threat.x,base.z-threat.z;local length=math.sqrt(dx*dx+dz*dz)
                if length<1 then dx,dz,length=origin.x-position.x,origin.z-position.z,math.sqrt(D2(origin,position)) end
                local offset=radius*0.55
                local destination={x=position.x+(length>0 and dx/length*offset or 0),y=position.y,
                    z=position.z+(length>0 and dz/length*offset or 0)}
                SnapToGround(destination,destination)
                if D3(origin,position)<=(radius*0.70)^2 then destination={x=origin.x,y=origin.y,z=origin.z} end
                local cover=Intel.FriendlyThreat(platoon,destination,55,"Land",true)
                local danger=Intel.Exposure(army,destination,"Land",6)
                local air=Intel.FriendlyThreat(platoon,destination,55,"Air",false)
                if D3(destination,position)<=(radius*0.80)^2
                    and cover>=own*0.50 and danger.total<=cover*0.75 and (danger.air or 0)<=air*0.75
                    and (not data.commanderStaysHome or D2(destination,base)<=(data.baseRadius or 60)^2)
                    and Reliability.Inside(destination,2) and Intel.ClearRendezvous(army,destination,4) then
                    local score=missing*200+math.min(150,cover/own*30)-math.sqrt(D2(origin,destination))
                        +(friend==data.rushCommanderSupportAnchor and 90 or 0)
                    candidates[#candidates+1]={position=destination,unit=friend,score=score,radius=radius}
                end
            end
        end
    end
    table.sort(candidates,function(a,b) return a.score>b.score or a.score==b.score and a.unit.id.index<b.unit.id.index end)
    for _,candidate in ipairs(candidates) do
        local connected=MG.CanGraphAreaTo(origin,candidate.position,data.movementLayer)
        if not Reliability.CurrentAssignment(unit,army,platoon,unitAI,data) then return nil end
        if connected and SupportTroop(army,candidate.unit)
            and D3(candidate.position,candidate.unit:GetPosition())<=(candidate.radius*0.80)^2 then
            return candidate.position,candidate.unit,candidate.radius
        end
    end
end

-- A defensive stance is not a permanent retreat order. Evaluate the units that
-- can actually take part at home, while retaining the lethal-damage veto.
function CanDefendHome(platoon,lethal)
    if lethal or not platoon or not platoon.ai then return false end
    local commander=platoon:GetUnits()[1]
    if not CurrentCommander(platoon,commander)
        or commander:GetHealth()<commander:GetMaxHealth()*0.50 then return false end
    local base=platoon.ai.basePosition
    local pos=Copy(commander:GetPosition())
    if not base or D2(pos,base)>(platoon.ai.baseRadius or 60)^2 then return false end
    local cached=platoon.ai.rushHomeDefence
    if cached and Now()>=cached.at and Now()-cached.at<1
        and (not cached.allowed or VisibleEnemy(platoon.army,cached.target)) then return cached.allowed end
    local land,air,enemyLand,enemyAir=0,0,0,0
    local target
    for _,u in pairs(platoon.army.units) do
        if Reliability.Own(platoon.army,u) and u:IsCompleted()
            and not u.CaptureInProgress and not u.ReclaimInProgress
            and not (u.ai and u.ai.eState=="RepairHome")
            and not (u.platoon and u.platoon.ai and u.platoon.ai.withdraw)
            and D2(pos,u:GetPosition())<=55*55 then
            land=land+AF.GetUnitThreatValueByLayer(u,"Land")
            air=air+AF.GetUnitThreatValueByLayer(u,"Air")
        end
    end
    for _,u in ipairs(Enemies(platoon.army)) do
        if VisibleEnemy(platoon.army,u) and D2(pos,u:GetPosition())<=60*60 then
            local value=AF.GetUnitThreatValueByLayer(u,"Land")
            if Has(u.tp,"AIR") then enemyAir=enemyAir+value else enemyLand=enemyLand+value end
            if value>0 and not Has(u.tp,"AIR") and D2(base,u:GetPosition())<=70*70 then
                for _,weapon in ipairs(commander.weapons or {}) do
                    if weapon.enabled and not weapon.isDeathExplosion and weapon.CanShootAt and weapon:CanShootAt(u) then target=u;break end
                end
            end
        end
    end
    local allowed=target~=nil and land>0 and enemyLand<=land*1.15 and enemyAir<=math.max(80,air*1.15)
    platoon.ai.rushHomeDefence={at=Now(),allowed=allowed,target=target}
    return allowed
end

-- Prefer an exposed, currently targetable commander to another lap around a
-- ruined base. Never pursue a hidden unit or cross disconnected terrain.
function FinishCommanderTarget(platoon)
    if platoon.ai.isNavalPlatoon or platoon.ai.targetLayer~="Land" then return nil end
    local pos=Copy(platoon:GetPosition());local own=platoon.ai.threat or 0
    if own<=0 then return nil end
    local records=Enemies(platoon.army)
    local structures={}
    for _,u in ipairs(records) do
        if VisibleEnemy(platoon.army,u) and Has(u.tp,"STRUCTURE") and not Has(u.tp,"ALLOYS_EXTRACTION") then
            structures[u.army.id]=(structures[u.army.id] or 0)+1
        end
    end
    local best,score
    for _,target in ipairs(records) do
        if VisibleEnemy(platoon.army,target) and (Has(target.tp,"COMMAND") or Has(target.tp,"SCFA_COMMAND"))
            and target.isTargetable~=false then
            local p=Copy(target:GetPosition());local distance=math.sqrt(D2(pos,p))
            local health=target:GetHealth()/math.max(1,target:GetMaxHealth())
            local exposed=(structures[target.army.id] or 0)<=2 or health<0.45
            local targetable=false
            if exposed and distance<=220 then
                for _,unit in ipairs(platoon:GetUnits()) do
                    for _,weapon in ipairs(unit.weapons or {}) do
                        if not unit.dead and weapon.enabled and not weapon.isDeathExplosion
                            and weapon.CanShootAt and weapon:CanShootAt(target) then targetable=true;break end
                    end
                    if targetable then break end
                end
                local enemy=Heat(platoon.army,p,"Land")
                if targetable and enemy and own>=enemy*1.10
                    and MG.CanGraphAreaTo(pos,p,platoon.ai.movementLayer) then
                    local value=1000-distance-health*150
                    if platoon.ai.rushFinishTarget==target then value=value+120 end
                    if not score or value>score then best=target;score=value end
                end
            end
        end
    end
    if best then platoon.ai.priorityTarget=best
    elseif platoon.ai.priorityTarget==platoon.ai.rushFinishTarget then platoon.ai.priorityTarget=false end
    platoon.ai.rushFinishTarget=best
    return best and Copy(best:GetPosition()) or nil
end
