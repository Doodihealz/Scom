-- RC16: short-lived, army-private memory of observed static resistance.
-- Failed approaches produce siege/containment objectives, not endless home laps.
-- Nothing here reveals enemy units, issues orders, or creates artificial strength.
Version = "9.0.17-rc18"
Config={MemorySeconds=180,MaximumFronts=24,FrontRadius=80,ProbeSeconds=30,BatteryLimit=12,BatteryInstances=12}
local Intel=Import("AI/mods/AI-Scom/RushCombatIntel.lua")
local AF=Import("AI/AIFunctions.lua")
local MG=Import("AI/AIMarkerGenerator.lua")
local function Now() return GetGameTimeSeconds() end
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local function Copy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function State(army)
    local now=Now();local s=army.ai.rushFronts
    if not s or now<(s.at or now) then
        s={at=now,fronts={},observations=0,avoided=0,sites=0};army.ai.rushFronts=s
    end
    s.at=now
    for i=#s.fronts,1,-1 do if now>=s.fronts[i].expires then table.remove(s.fronts,i) end end
    return s
end
function Remember(army,assessment,strength)
    if not assessment or assessment.static<=0 or assessment.static<assessment.total*0.60
        or assessment.total<=math.max(1,strength)*1.20 or not assessment.staticPosition then return nil end
    local s=State(army);local pos=assessment.staticPosition;local now=Now()
    local front
    for _,f in ipairs(s.fronts) do if D2(f.pos,pos)<=Config.FrontRadius^2 then front=f;break end end
    if not front then
        if #s.fronts>=Config.MaximumFronts then table.remove(s.fronts,1) end
        front={pos=Copy(pos),first=now};s.fronts[#s.fronts+1]=front
    end
    front.strength,front.range,front.unit=assessment.static,assessment.maxStaticRange,assessment.staticUnit
    front.expires=now+Config.MemorySeconds;front.probeAt=now+Config.ProbeSeconds
    s.observations=s.observations+1
    army.ai.rushCombat=army.ai.rushCombat or {operations={},supports={},lastReport=0,
        stats={merges=0,detached=0,goals=0,repaths=0,retreats=0,rejected=0}}
    army.ai.rushCombat.siegeUntil=front.expires
    return front
end
function Active(army)
    for _,f in ipairs(State(army).fronts) do if (f.strength or 0)>0 then return true end end
    return false
end
function Blocked(army,pos,strength)
    local s=State(army);local now=Now()
    for _,f in ipairs(s.fronts) do
        if D2(pos,f.pos)<=Config.FrontRadius^2 then
            -- Reobserve using the native known-enemy set. No old estimate can
            -- veto a newly opened breach forever, and reinforcement may attack
            -- immediately when enough mobile strength is physically assembled.
            if now>=f.probeAt then
                local a=Intel.Exposure(army,f.pos,"Land",12)
                f.strength=a.static;f.probeAt=now+Config.ProbeSeconds
            end
            if f.strength>math.max(1,strength)*1.20 then s.avoided=s.avoided+1;return true,f end
        end
    end
    return false
end
local function Claims(platoon)
    local result={}
    for _,army in pairs(Armies or {}) do
        if army==platoon.army or platoon.army:IsAlly(army) then
            local state=army.ai and army.ai.rushCombat
            for _,p in pairs(state and state.operations or {}) do
                local op=p.ai and p.ai.rushOperation
                if p~=platoon and not p.dead and not p.deleted and army:PlatoonExists(p) and op then
                    local goal=op.goal
                    if goal and (goal.kind=="stage" or goal.kind=="deploy" or goal.kind=="siege") then
                        result[#result+1]=goal.pos
                    end
                end
            end
        end
    end
    return result
end
local function Rejected(platoon,pos)
    local op=platoon.ai.rushOperation;local now=Now()
    for _,b in ipairs(op and op.blocked or {}) do
        if now<b.untilTime and D2(b.pos,pos)<48^2 then return true end
    end
    return false
end
local function ChooseSite(platoon,g,candidates,kind,target)
    local claims=Claims(platoon);local best,bestScore
    for _,candidate in ipairs(candidates) do
        local pos=Copy(AF.GetPositionWithinPlayableArea(Copy(candidate)))
        -- Clamping is not authority to use a different (possibly stacked) site.
        if D2(pos,candidate)<1 and not Rejected(platoon,pos) and Intel.ClearRendezvous(platoon.army,pos,12)
            and MG.CanGraphAreaTo(g.position,pos,platoon.ai.movementLayer) then
            local exposure=Intel.Exposure(platoon.army,pos,"Land",g.radius+6)
            if exposure.total<=math.max(1,g.own)*0.35 then
                local crowd=0
                for _,p in ipairs(claims) do if D2(p,pos)<48^2 then crowd=crowd+1 end end
                local score=math.sqrt(D2(pos,g.position))+crowd*160+exposure.total
                if not bestScore or score<bestScore then best,bestScore=Copy(pos),score end
            end
        end
    end
    if best then
        State(platoon.army).sites=State(platoon.army).sites+1
        return {pos=Copy(best),kind=kind,unit=target}
    end
end
function Stage(platoon,g,target,assessment)
    if not target or not Intel.Visible(platoon.army,target) or not Intel.IsStatic(target) then return nil end
    local tp=Copy(target:GetPosition());local dx,dz=g.position.x-tp.x,g.position.z-tp.z
    local distance=math.sqrt(dx*dx+dz*dz);if distance<1 then return nil end
    local battery=platoon.ai.formerTable.RushSiege==true
    local radius=battery and math.max(20,g.range-10)
        or math.max(80,(assessment and assessment.maxStaticRange or 0)+g.radius+36)
    local sites={};local phase=((tonumber(platoon.id) or 0)%3-1)*0.18
    for _,offset in ipairs({0,0.45,-0.45,0.90,-0.90,1.25,-1.25}) do
        local c,s=math.cos(offset+phase),math.sin(offset+phase)
        sites[#sites+1]={x=tp.x+(dx*c-dz*s)/distance*radius,y=tp.y,z=tp.z+(dx*s+dz*c)/distance*radius}
    end
    return ChooseSite(platoon,g,sites,battery and "siege" or "stage",target)
end
-- A rejected assault can still make safe forward progress against mobile
-- resistance or a modest strength deficit. This does not admit the attack:
-- each real site must remain clear, reachable and outside strong exposure.
function Approach(platoon,g,target)
    if not target or not Intel.Visible(platoon.army,target) or target:HasTags(Tags.AIR) or g.own<=0 then return nil end
    local destination=Copy(target:GetPosition())
    local dx,dz=destination.x-g.position.x,destination.z-g.position.z
    local distance=math.sqrt(dx*dx+dz*dz)
    if distance<=48 then return nil end
    local lastStep
    for _,length in ipairs({96,64,48}) do
        local step=math.min(length,distance-40)
        if step>=40 and step~=lastStep then
            lastStep=step
            local sites={}
            for _,offset in ipairs({0,0.60,-0.60}) do
                local c,s=math.cos(offset),math.sin(offset)
                local pos={x=g.position.x+(dx*c-dz*s)/distance*step,y=g.position.y,
                    z=g.position.z+(dx*s+dz*c)/distance*step}
                if distance-math.sqrt(D2(pos,destination))>=24 then
                    local arrived=0
                    local needed=math.max(1,math.ceil(g.count*0.70))
                    for _,item in ipairs(g.points) do
                        if D2(item.pos,pos)<=30^2 then arrived=arrived+1 end
                        if arrived>=needed then break end
                    end
                    if arrived<needed then sites[#sites+1]=pos end
                end
            end
            local goal=ChooseSite(platoon,g,sites,"stage",target)
            if goal then goal.approach=true;return goal end
        end
    end
end
function Deploy(platoon,g)
    -- Only a backlog near production needs a perimeter rendezvous. Front-line
    -- groups already containing a fortress must not be sent back to base.
    local home=platoon.ai.basePosition;local radius=math.max(72,math.min(180,(platoon.ai.baseRadius or 100)*0.70))
    if D2(home,g.position)>radius^2 or g.count<4 then return nil end
    local sites={};local phase=((tonumber(platoon.id) or 0)*2.3999632297287+(tonumber(platoon.army.id) or 0))%(2*math.pi)
    for i=0,11 do
        local angle=phase+i*math.pi/6
        local pos={x=home.x+math.cos(angle)*radius,y=g.position.y,z=home.z+math.sin(angle)*radius}
        if D2(pos,g.position)>40^2 then sites[#sites+1]=pos end
    end
    return ChooseSite(platoon,g,sites,"deploy")
end
-- MAIN alarms share the ordinary intel epoch. Only owned health/shields and
-- currently observed enemy weapons supply evidence; no damage-source oracle.
local function Has(tp,tag)
    if not tp then return false end
    if tp.hasTags and tp.hasTags[tag] then return true end
    for _,value in ipairs(tp.tags or {}) do if value==tag then return true end end
    return false
end
local function StaticTemplate(tp)
    return Has(tp,"STRUCTURE") or Has(tp,"SCFA_STRUCTURE")
        or Has(tp,"DEFENCE") and not Has(tp,"MOBILE") and not Has(tp,"SCFA_MOBILE")
end
function IsStrategicArtillery(unit)
    local tp=unit and unit.tp
    local tier=tp and tp.general and tp.general.techNumber
    if not tp or not StaticTemplate(tp) or not (Has(tp,"ARTILLERY") or Has(tp,"SCFA_ARTILLERY"))
        or not (Has(tp,"TECH3") or Has(tp,"SCFA_TECH3") or Has(tp,"TECH4")
            or Has(tp,"EXPERIMENTAL") or Has(tp,"SCFA_EXPERIMENTAL") or type(tier)=="number" and tier>=3) then return false end
    return (AF.GetUnitThreatValueByLayer(unit,"Land",false) or 0)>0
        and (AF.GetUnitMaximumWeaponRangeByLayer(unit,"Land") or 0)>0
end
local function MainOwned(army,unit)
    return unit and not unit.dead and not unit.deleted and unit.army==army
        and unit.id and army.units and army.units[unit.id.index]==unit
        and not unit.CaptureInProgress and not unit.ReclaimInProgress and not unit:IsPlacementGhost()
end
local function DamagingWeapon(weapon)
    return weapon.enabled and not weapon.isDeathExplosion and weapon.tp
        and type(weapon.tp.damage)=="number" and weapon.tp.damage>0
end
local function AimingAtHome(unit,assets)
    for _,weapon in ipairs(unit.weapons or {}) do
        local target=weapon.targetUnit
        if target and assets[target] and DamagingWeapon(weapon)
            and weapon:CanShootAt(target) and weapon:IsTargetInRange(target)
            and type(weapon.IsWeaponOnTarget)=="function" and weapon:IsWeaponOnTarget() then return true end
    end
    return false
end
local function CanHitAsset(unit,asset)
    for _,weapon in ipairs(unit.weapons or {}) do
        if DamagingWeapon(weapon) and weapon:CanShootAt(asset) and weapon:IsTargetInRange(asset) then return true end
    end
    return false
end
local function AlarmTargetLess(a,b)
    if a.confirmed~=b.confirmed then return a.confirmed==true end
    if a.distance~=b.distance then return a.distance<b.distance end
    return a.unit.id.index<b.unit.id.index
end
local function EmptyAlarm()
    return {active=false,localRaid=false,landRaid=false,raidThreat=0,bombardment=false,recentUntil=0,
        artilleryTargets={},raiders={},byRaider={},damagedAssets={}}
end
function MainAlarm(army)
    local ai=army and army.ai;local base=ai and ai.bases and ai.bases.MAIN
    if not ai or ai.isAlive==false or not base or not base.position then
        if ai then ai.rushMainAlarm=nil end
        return EmptyAlarm()
    end
    local intel=Intel.Get(army);local now=Now();local state=ai.rushMainAlarm
    if not state or state.baseRef~=base or not state.base or D2(state.base,base.position)>0
        or now<(state.at or now) then
        state={baseRef=base,base=Copy(base.position),at=now,samples={},sources={},bombardmentUntil=0}
        ai.rushMainAlarm=state
    end
    if state.intel==intel then return state.view end
    local view=EmptyAlarm();view.at=now;view.baseRef=base;view.base=Copy(base.position)
    view.radius=math.max(64,math.min(180,base.radius or 100))
    state.intel,state.view,state.at=intel,view,now
    local assets,samples={},{};local hit=false
    for _,unit in pairs(army.units or {}) do
        if MainOwned(army,unit) and (StaticTemplate(unit.tp) or unit:HasTags(Tags.COMMAND)) then
            local pos=Copy(unit:GetPosition())
            if D2(pos,view.base)<=view.radius^2 then
                local previous=state.samples[unit];local health,maxHealth=unit:GetHealth(),unit:GetMaxHealth()
                local sample={health=health,maxHealth=maxHealth,shields={},lastHit=previous and previous.lastHit}
                local damaged=previous and previous.maxHealth==maxHealth and health<previous.health-math.max(1,maxHealth*0.001)
                for _,shield in ipairs(unit.shields or {}) do
                    if not shield.deleted and type(shield.GetHealth)=="function" then
                        local hp=shield:GetHealth();local old=previous and previous.shields[shield]
                        local timeout=shield.regenTimeOutTick
                        -- Energy shutdown also zeros shield HP. Only an enableable
                        -- shield or an advancing native damage timer is evidence.
                        if old and shield.isEnableable~=false and
                            (hp<old.health-1 or type(timeout)=="number" and timeout>(old.timeout or -math.huge)) then damaged=true end
                        sample.shields[shield]={health=hp,timeout=timeout}
                    end
                end
                if damaged then sample.lastHit=now;hit=true end
                samples[unit]=sample;assets[unit]={unit=unit,pos=pos}
                if sample.lastHit and now-sample.lastHit<=6 then view.damagedAssets[#view.damagedAssets+1]=assets[unit] end
            end
        end
    end
    -- Replace samples, rather than accumulating dead/captured/removed assets.
    state.samples=samples
    table.sort(view.damagedAssets,function(a,b) return a.unit.id.index<b.unit.id.index end)
    for i=#view.damagedAssets,25,-1 do view.damagedAssets[i]=nil end
    local artillery={};local localCause=false
    for _,record in ipairs(intel.enemy) do
        local unit=record.unit
        if record.completed~=false and Intel.Visible(army,unit) then
            local threat=Intel.KnownThreat(army,unit,"Land")
            if threat>0 then
                local range=math.max(0,AF.GetUnitMaximumWeaponRangeByLayer(unit,"Land") or 0)
                local distance=D2(record.pos,view.base)
                if distance<=(view.radius+range+32)^2 then
                    local aiming=AimingAtHome(unit,assets)
                    if IsStrategicArtillery(unit) then
                        artillery[#artillery+1]={unit=unit,pos=Copy(record.pos),range=range,
                            distance=distance,confirmed=aiming}
                    else
                        local static=StaticTemplate(unit.tp)
                        if aiming or not static and distance<=(view.radius+48)^2 then localCause=true end
                        if not unit:HasTags(Tags.AIR) and not static and
                            (aiming or distance<=(view.radius+48)^2) then
                            local raid={unit=unit,pos=Copy(record.pos),range=range,threat=threat,
                                distance=distance,confirmed=aiming}
                            view.raiders[#view.raiders+1]=raid;view.byRaider[unit]=raid
                            view.raidThreat=view.raidThreat+threat;view.localRaid=true
                            local naval=Has(unit.tp,"NAVAL") or Has(unit.tp,"SCFA_NAVAL")
                            local connected=MG.CanGraphAreaTo
                            if naval then connected=MG.CanGraphAreaToStrict end
                            raid.landReachable=type(connected)=="function" and connected(view.base,record.pos,"Land") or false
                            view.landRaid=view.landRaid or raid.landReachable
                        end
                    end
                end
            end
        end
    end
    table.sort(artillery,AlarmTargetLess)
    for i=#artillery,13,-1 do artillery[i]=nil end
    local sources={};local confirmed=false
    for unit,expiry in pairs(state.sources) do if expiry>now then sources[unit]=expiry end end
    for _,record in ipairs(artillery) do
        local unit=record.unit
        if not record.confirmed and hit and not localCause then
            for _,asset in ipairs(view.damagedAssets) do
                if CanHitAsset(unit,asset.unit) then record.confirmed=true;break end
            end
        end
        if record.confirmed then sources[unit]=now+45;confirmed=true end
        if sources[unit] then
            record.confirmed=true;view.artilleryTargets[#view.artilleryTargets+1]=record
        end
    end
    local retained={}
    for unit,expiry in pairs(sources) do retained[#retained+1]={unit=unit,expiry=expiry} end
    table.sort(retained,function(a,b)
        if a.expiry~=b.expiry then return a.expiry>b.expiry end
        return a.unit.id.index<b.unit.id.index
    end)
    state.sources={}
    for i=1,math.min(12,#retained) do state.sources[retained[i].unit]=retained[i].expiry end
    if confirmed then state.bombardmentUntil=now+45 end
    if localCause then
        state.unknownHits,state.lastUnknownHit=0,nil
    elseif hit then
        state.unknownHits=state.lastUnknownHit and now-state.lastUnknownHit<=45 and math.min(2,(state.unknownHits or 0)+1) or 1
        state.lastUnknownHit=now
        if state.unknownHits>=2 then
            -- Repeated unexplained impacts justify protection, never a fabricated
            -- artillery identity or blind air strike through fog of war.
            state.bombardmentUntil=math.max(state.bombardmentUntil,now+45)
            view.unattributedFire=not confirmed
        end
    end
    table.sort(view.artilleryTargets,AlarmTargetLess);table.sort(view.raiders,AlarmTargetLess)
    for i=#view.raiders,25,-1 do view.raiders[i]=nil end
    view.recentUntil=state.bombardmentUntil
    view.bombardment=now<state.bombardmentUntil
    view.active=view.localRaid or view.bombardment
    return view
end

-- A defense front is a threatened side of a REAL friendly base. Opposite
-- approaches never collapse into one radius around MAIN. This shared view is
-- rebuilt only with native known-enemy intel; it owns no orders or threads.
local DEFENSE_LIMIT=12
local function DefenseSector(base,pos)
    return math.floor((math.atan2(pos.z-base.z,pos.x-base.x)+math.pi/8)*4/math.pi)%8
end
local function DefenseLess(a,b)
    if a.urgency~=b.urgency then return a.urgency>b.urgency end
    return a.key<b.key
end
local function TargetLess(a,b)
    if (a.attacking==true)~=(b.attacking==true) then return a.attacking==true end
    if a.distance~=b.distance then return a.distance<b.distance end
    return a.unit.id.index<b.unit.id.index
end
function Defense(army)
    local intel=Intel.Get(army)
    if intel.defense then return intel.defense end
    local view={fronts={},byKey={},byUnit={},pressureFronts={},at=intel.at}
    intel.defense=view
    local alarm=MainAlarm(army)
    local bases={};local pressureByKey={}
    for _,owner in pairs(Armies or {}) do
        if (owner==army or army:IsAlly(owner)) and owner.ai and owner.ai.isAlive~=false then
            for name,base in pairs(owner.ai.bases or {}) do
                if base.position and base.baseType~="NAVAL" then
                    bases[#bases+1]={key=tostring(owner.id)..":"..tostring(name),name=name,ref=base,pos=Copy(base.position),
                        radius=math.max(80,math.min(180,(base.radius or 100)+32)),own=owner==army,main=owner==army and name=="MAIN"}
                end
            end
        end
    end
    table.sort(bases,function(a,b) return a.key<b.key end)
    for _,record in ipairs(intel.enemy) do
        local unit=record.unit
        if record.completed~=false and Intel.Visible(army,unit) and not unit:HasTags(Tags.AIR)
            and (not unit:HasTags(Tags.ENGINEER) or unit:HasTags(Tags.COMMAND) or alarm.byRaider[unit]) then
            local threat=Intel.KnownThreat(army,unit,"Land")
            if threat>0 then
                local closest,distance
                local range=math.max(0,AF.GetUnitMaximumWeaponRangeByLayer(unit,"Land") or 0)
                for _,base in ipairs(bases) do
                    local d=D2(base.pos,record.pos)
                    local reach=Intel.IsStatic(unit) and range+24 or math.max(base.radius+32,range+24)
                    local mainAttack=alarm.byRaider[unit] and alarm.byRaider[unit].confirmed
                    if (mainAttack and base.main or d<=reach*reach) and (mainAttack and base.main or not distance
                        or not (mainAttack and closest.main) and d<distance) then closest,distance=base,d end
                end
                if closest then
                    local sector=DefenseSector(closest.pos,record.pos)
                    local key=closest.key..":"..sector
                    -- Remote strategic guns belong to air retaliation/shields;
                    -- do not send the ground army across the map after them.
                    local remoteArtillery=IsStrategicArtillery(unit) and distance>(closest.radius+64)^2
                    local emergency=closest.main and alarm.byRaider[unit]~=nil
                    if not remoteArtillery and (not unit:HasTags(Tags.ENGINEER) or emergency) then
                        local front=view.byKey[key]
                        if not front then
                            front={key=key,baseKey=closest.key,baseName=closest.name,baseRef=closest.ref,
                                base=closest.pos,sector=sector,radius=closest.radius,own=closest.own,pos=Copy(record.pos),
                                nearest=distance,threat=0,maxRange=0,targets={}}
                            view.byKey[key]=front;view.fronts[#view.fronts+1]=front
                        end
                        front.threat=front.threat+threat;front.maxRange=math.max(front.maxRange,range)
                        front.emergency=front.emergency or emergency
                        front.landRaid=front.landRaid or emergency and alarm.byRaider[unit].landReachable
                        if emergency and alarm.byRaider[unit].landReachable then
                            front.landRaidThreat=(front.landRaidThreat or 0)+threat
                        end
                        if distance<front.nearest then front.nearest=distance;front.pos=Copy(record.pos) end
                        local target={unit=unit,pos=record.pos,distance=distance,attacking=emergency and alarm.byRaider[unit].confirmed}
                        local targets=front.targets;targets[#targets+1]=target
                        table.sort(targets,TargetLess)
                        if #targets>6 then targets[7]=nil end
                        view.byUnit[unit]=front
                    end
                    -- Shore bombardment remains a mobile-defense problem; a
                    -- ship's Land damage cannot request land point defense.
                    -- The separate numeric view includes armed commanders,
                    -- shares this observation, and keeps no enemy unit.
                    if closest.own and not remoteArtillery and not unit:HasTags(Tags.NAVAL) then
                        local pressure=pressureByKey[key]
                        if not pressure then
                            pressure={key=key,baseKey=closest.key,baseName=closest.name,baseRef=closest.ref,
                                base=closest.pos,sector=sector,radius=closest.radius,own=true,
                                pos=Copy(record.pos),nearest=distance,threat=0,maxRange=0,contacts=0}
                            pressureByKey[key]=pressure;view.pressureFronts[#view.pressureFronts+1]=pressure
                        end
                        pressure.threat=pressure.threat+threat;pressure.maxRange=math.max(pressure.maxRange,range)
                        pressure.contacts=math.min(12,pressure.contacts+1)
                        if distance<pressure.nearest then pressure.nearest=distance;pressure.pos=Copy(record.pos) end
                    end
                end
            end
        end
    end
    for _,front in ipairs(view.fronts) do
        front.urgency=front.threat*(1+math.max(0,1-math.sqrt(front.nearest)/front.radius))*(front.own and 1.1 or 1)*(front.emergency and 1.65 or 1)
        front.fixedUnits={}
    end
    table.sort(view.fronts,DefenseLess)
    -- Construction keeps a separate bounded own-base view before the mobile
    -- coordinator trims allied/current fronts. Allied urgency cannot erase an
    -- observed own-base attack from the defensive construction history.
    for _,pressure in ipairs(view.pressureFronts) do
        pressure.urgency=pressure.threat*(1+math.max(0,1-math.sqrt(pressure.nearest)/pressure.radius))*1.1
    end
    table.sort(view.pressureFronts,DefenseLess)
    view.pressureComplete=#view.pressureFronts<=24
    for i=#view.pressureFronts,25,-1 do view.pressureFronts[i]=nil end
    -- At most twelve independently threatened sides persist, regardless of map
    -- size or enemy count. Overflow drops the least urgent fronts only for this
    -- snapshot; the next snapshot ranks the complete known set again.
    for i=#view.fronts,DEFENSE_LIMIT+1,-1 do
        view.byKey[view.fronts[i].key]=nil;view.fronts[i]=nil
    end
    for unit,front in pairs(view.byUnit) do if not view.byKey[front.key] then view.byUnit[unit]=nil end end
    -- Unmanaged nearby defenders count once, on their nearest front. Managed
    -- platoons are accounted separately by exact live mission reservations.
    local support={}
    for _,front in ipairs(view.fronts) do
        for _,unit in ipairs(Intel.FriendlyUnitsInRadius(army,front.pos,80)) do
            local data=unit.platoon and unit.platoon.ai
            if not (data and data.rushOperation) and not unit.dead and not unit.deleted
                and not unit.CaptureInProgress and not unit.ReclaimInProgress
                and not unit:HasTags(Tags.AIR+Tags.ENGINEER+Tags.COMMAND)
                and not (unit.ai and unit.ai.eState=="RepairHome")
                and not (data and (data.withdraw or data.eState=="Withdraw"))
                and not (unit.toggles and unit.GetPause and unit:GetPause()) then
                local distance=D2(unit:GetPosition(),front.pos)
                if not support[unit] or distance<support[unit].distance then
                    local firing=false
                    for _,weapon in ipairs(unit.weapons or {}) do
                        if weapon.enabled and not weapon.isDeathExplosion then
                            for _,target in ipairs(front.targets) do
                                if Intel.Visible(army,target.unit) and weapon:CanShootAt(target.unit)
                                    and weapon:IsTargetInRange(target.unit) then firing=true;break end
                            end
                        end
                        if firing then break end
                    end
                    if firing then support[unit]={front=front,distance=distance} end
                end
            end
        end
    end
    for unit,entry in pairs(support) do
        local fixed=entry.front.fixedUnits
        fixed[#fixed+1]={unit=unit,owner=unit.army,armyAI=unit.army.ai,platoon=unit.platoon,
            unitAI=unit.ai,platoonAI=unit.platoon and unit.platoon.ai,
            threat=math.max(0,AF.GetUnitThreatValueByLayer(unit,"Land",false) or 0)}
    end
    return view
end
-- Construction remembers observed approaches between waves. This is separate
-- from siege memory and from mobile-defense claims; it owns no enemy unit,
-- orders, or thread, and a single observation cannot manufacture repeated raids.
local PRESSURE_LIMIT=24
local PRESSURE_MEMORY=180
local function PressureBaseCurrent(army,record)
    local base=army.ai.bases and army.ai.bases[record.baseName]
    return base==record.baseRef and base and base.baseType~="NAVAL" and base.position
        and base.position.x==record.base.x and base.position.z==record.base.z
end
local function PressureLess(a,b)
    if a.active~=b.active then return a.active end
    if a.repeated~=b.repeated then return a.repeated end
    if a.urgency~=b.urgency then return a.urgency>b.urgency end
    if a.lastSeen~=b.lastSeen then return a.lastSeen>b.lastSeen end
    return a.key<b.key
end
function DefensePressure(army)
    if not army or not army.ai then return {} end
    if army.ai.isAlive==false then army.ai.rushDefensePressure=nil;return {} end
    local now=Now();local state=army.ai.rushDefensePressure
    if not state or now<(state.at or now) then
        state={at=now,nextScan=0,serial=0,records={}};army.ai.rushDefensePressure=state
    end
    state.at=now
    local records=state.records
    -- Even a cached result loses authority immediately when its exact friendly
    -- base is removed, replaced, relocated, or converted into a naval base.
    for i=#records,1,-1 do
        local r=records[i]
        if now-r.lastSeen>=PRESSURE_MEMORY or not PressureBaseCurrent(army,r) then table.remove(records,i) end
    end
    if now<state.nextScan then return records end
    state.nextScan=now+1
    for _,r in ipairs(records) do r.active=false end
    local observed={};local defense=Defense(army)
    for _,front in ipairs(defense.pressureFronts or defense.fronts) do
        if front.own and front.baseName and front.baseRef
            and army.ai.bases and army.ai.bases[front.baseName]==front.baseRef
            and front.baseRef.position and front.baseRef.position.x==front.base.x
            and front.baseRef.position.z==front.base.z then
            local selected,distance,exact
            for _,r in ipairs(records) do
                if r.baseRef==front.baseRef then
                    local delta=math.abs(r.sector-front.sector);delta=math.min(delta,8-delta)
                    local d=D2(r.pos,front.pos);local same=delta==0
                    -- Match against the previous representative, not an updated
                    -- position, so adjacent sectors cannot chain around a base.
                    if same or delta==1 and d<=64^2 then
                        if not selected or same and not exact or same==exact and
                            (d<distance or d==distance and r.key<selected.key) then
                            selected,distance,exact=r,d,same
                        end
                    end
                end
            end
            if not selected then
                state.serial=state.serial+1
                selected={key=front.baseKey..":pressure:"..state.serial,baseName=front.baseName,
                    baseRef=front.baseRef,base=Copy(front.base),sector=front.sector,pos=Copy(front.pos),
                    lastSeen=now,observedSeconds=0,contactSeconds=0,contacts=0,encounters=0,repeated=false,active=false}
                records[#records+1]=selected
            end
            local sample=observed[selected]
            if not sample then
                sample={threat=0,maxRange=0,contacts=0,nearest=front.nearest,pos=front.pos,sector=front.sector,urgency=0}
                observed[selected]=sample
            end
            sample.threat=sample.threat+front.threat
            sample.contacts=math.min(12,sample.contacts+(front.contacts or #(front.targets or {})))
            sample.maxRange=math.max(sample.maxRange,front.maxRange)
            sample.urgency=sample.urgency+front.urgency
            if front.nearest<sample.nearest then
                sample.nearest=front.nearest;sample.pos=front.pos;sample.sector=front.sector
            end
        end
    end
    for r,sample in pairs(observed) do
        local gap=now-r.lastSeen
        if r.encounters==0 or r.missingSince and now-r.missingSince>=10 then
            r.encounters=math.min(2,r.encounters+1)
        elseif not r.missingSince and gap<=2.5 then
            -- A skipped observation interval supplies no invented continuous
            -- contact. Separate short observations may still accumulate.
            r.observedSeconds=math.min(60,r.observedSeconds+math.max(0,gap))
        end
        r.contactSeconds=r.observedSeconds;r.contacts=sample.contacts
        r.repeated=r.repeated or r.observedSeconds>=8 or r.encounters>=2
        r.active=true;r.missingSince=nil;r.lastSeen=now;r.pos=Copy(sample.pos);r.sector=sample.sector
        r.threat=sample.threat;r.maxRange=sample.maxRange;r.nearest=sample.nearest;r.urgency=sample.urgency
    end
    for _,r in ipairs(records) do
        -- A delayed caller is not evidence that a wave ended. Only a sampled
        -- absence can start the ten-second separation between encounters.
        if not observed[r] and not r.missingSince and defense.pressureComplete~=false then r.missingSince=now end
    end
    table.sort(records,PressureLess)
    -- Retain only the twenty-four strongest current/recent own approaches
    -- after merging jitter; one scan can add at most twenty-four records.
    for i=#records,PRESSURE_LIMIT+1,-1 do records[i]=nil end
    return records
end
function DefenseMatch(view,claim)
    if not claim then return nil end
    local exact=view.byKey[claim.key]
    if exact and (not claim.baseRef or exact.baseRef==claim.baseRef) then return exact end
    -- A wave crossing one sector boundary keeps its commitment. A cleared left
    -- flank must never transfer its reservation to the opposite side of a base.
    local best,distance
    for _,front in ipairs(view.fronts) do
        local delta=math.abs(front.sector-(claim.sector or front.sector));delta=math.min(delta,8-delta)
        local d=claim.pos and D2(front.pos,claim.pos)
        if front.baseKey==claim.baseKey and (not claim.baseRef or front.baseRef==claim.baseRef)
            and delta<=1 and d and d<=64^2
            and (not distance or d<distance) then best,distance=front,d end
    end
    return best
end
function DefenseClaim(front)
    return {key=front.key,baseKey=front.baseKey,baseRef=front.baseRef,sector=front.sector,pos=Copy(front.pos)}
end
function DefensePosition(platoon,g,front)
    local dx,dz=front.base.x-front.pos.x,front.base.z-front.pos.z
    local length=math.sqrt(dx*dx+dz*dz)
    if length<1 then dx,dz=g.position.x-front.pos.x,g.position.z-front.pos.z;length=math.sqrt(dx*dx+dz*dz) end
    if length<1 then return nil end
    local radius=math.max(42,front.maxRange+g.radius+18)
    for _,angle in ipairs({0,0.55,-0.55}) do
        local c,s=math.cos(angle),math.sin(angle)
        local pos={x=front.pos.x+(dx*c-dz*s)*radius/length,y=g.position.y,
            z=front.pos.z+(dx*s+dz*c)*radius/length}
        local clamped=AF.GetPositionWithinPlayableArea(Copy(pos))
        if D2(pos,clamped)<1 and Intel.ClearRendezvous(platoon.army,pos,10)
            and MG.CanGraphAreaTo(g.position,pos,platoon.ai.movementLayer) then
            local strength=g.own+Intel.FriendlyThreat(platoon,pos,48,"Land")
            if Intel.Exposure(platoon.army,pos,"Land",g.radius+6).total<=math.max(1,strength)*0.8 then
                return Copy(pos)
            end
        end
    end
end
function Summary(army)
    local s=State(army)
    return {fronts=#s.fronts,observations=s.observations,avoided=s.avoided,sites=s.sites}
end
