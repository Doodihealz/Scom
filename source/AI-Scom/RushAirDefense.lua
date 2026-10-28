-- RC18: observer-private memory of air raids, paid T1 cover and interception.
-- Memory retains a threat COUNT, not hidden positions or live hidden targets.
Version="9.0.22-rc24"
Config={MemorySeconds=180,ScanSeconds=1,ResourceScanSeconds=10,ResourceWatchRadius=64,
    MaxTurrets=4,MaxInterceptors=12}
local AF=Import("AI/AIFunctions.lua")
local Bombers=Import("AI/mods/AI-Scom/RushBomberHarassment.lua")
local R=Import("AI/mods/AI-Scom/RushReliability.lua")
local Log=Import("AI/debugUtilities.lua").AILog
local Factions={"EDA","CHOSEN","GUARD","SERAPHIM"}
local function Now() return GetGameTimeSeconds() end
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local function Copy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function Has(t,k) return R.Has(t,k) end
local function State(a)
    local s=a.ai.rushAirDefense
    if not s then s={expires=0,peak=0,nextScan=0,bases={},nextReport=0,
        nextResourceScan=0,resourcePositions={}};a.ai.rushAirDefense=s end
    return s
end
function Active(a)
    local s=a and a.ai and a.ai.rushAirDefense
    return s and a.ai.isAlive~=false and Now()<s.expires or false
end
function Observe(a,snapshot)
    local s=State(a);local now=Now()
    if s.lastTime and now<s.lastTime then
        s.expires=0;s.peak=0;s.nextScan=0;s.bases={};s.nextReport=0
        s.nextResourceScan=0;s.resourcePositions={}
    end
    s.lastTime=now
    if a.ai.isAlive==false then
        s.expires=0;s.bases={};snapshot.airRaid=false;snapshot.airRaidFighters=0;snapshot.airCombatCount=0;snapshot.localAirCombatCount=0;return s
    end
    if now>=s.nextScan or now<s.nextScan-Config.ScanSeconds then
        s.nextScan=now+Config.ScanSeconds
        if now>=s.expires then s.peak=0 end
        local total,combat,localCombat=0,0,0;local counts={}
        local function NearOwnedExtractor(position)
            if now>=(s.nextResourceScan or 0) then
                local positions={}
                for _,unit in pairs(a.units or {}) do
                    if R.Own(a,unit) and Has(unit.tp,"STRUCTURE")
                        and Has(unit.tp,"ALLOYS_EXTRACTION") then
                        positions[#positions+1]={unit=unit,pos=Copy(unit:GetPosition())}
                    end
                end
                s.resourcePositions=positions
                s.nextResourceScan=now+Config.ResourceScanSeconds
            end
            for _,site in ipairs(s.resourcePositions or {}) do
                if R.Own(a,site.unit) and D2(position,site.pos)<=Config.ResourceWatchRadius^2 then return true end
            end
            return false
        end
        -- Visible combat aircraft inform cover; only nearby ground attackers
        -- create a remembered raid. Scouts and unarmed transports do neither.
        for _,u in pairs(type(AF.GetEnemyUnitsOnMap)=="function" and AF.GetEnemyUnitsOnMap(a.id) or {}) do
            if Has(u.tp,"AIR") and Has(u.tp,"MOBILE") and not Has(u.tp,"SCOUT") and Bombers.Visible(a,u) then
                local groundAttack=not Bombers.IsNavalAttackAircraft(u.tp)
                    and (Bombers.IsBomber(u.tp) or Has(u.tp,"GUNSHIP") or Has(u.tp,"ANTI_SURFACE"))
                if groundAttack or Bombers.IsNavalAttackAircraft(u.tp)
                    or Has(u.tp,"FIGHTER") or Has(u.tp,"ANTI_AIR") then
                    combat=combat+1
                    local p=Copy(u:GetPosition());local closest,distance
                    for name,b in pairs(a.ai.bases or {}) do
                        local radius=math.max(128,math.min(220,(b.radius or 64)+80))
                        local d=D2(p,b.position)
                        if d<=radius^2 and (not distance or d<distance or d==distance and name<closest) then closest,distance=name,d end
                    end
                    local near=closest or groundAttack and NearOwnedExtractor(p)
                    if near then localCombat=localCombat+1 end
                    if groundAttack and near then
                        total=total+1
                        if closest then counts[closest]=(counts[closest] or 0)+1 end
                    end
                end
            end
        end
        if total>0 then s.expires=now+Config.MemorySeconds;s.peak=math.max(s.peak,total) end
        for name,count in pairs(counts) do
            local b=s.bases[name]
            if not b or now>=b.expires then b={peak=0};s.bases[name]=b end
            b.peak=math.max(b.peak,count);b.expires=now+Config.MemorySeconds
        end
        for name,b in pairs(s.bases) do if now>=b.expires or not a.ai.bases[name] then s.bases[name]=nil end end
        s.observed=total;s.observedCombat=combat;s.localCombat=localCombat
    end
    snapshot.airCombatCount=s.observedCombat or 0
    snapshot.localAirCombatCount=s.localCombat or 0
    snapshot.airRaid=now<s.expires
    snapshot.airRaidCount=s.peak
    snapshot.airRaidFighters=snapshot.airRaid and math.min(Config.MaxInterceptors,math.max(2,s.peak*2)) or 0
    if snapshot.airRaid and now>=s.nextReport then
        s.nextReport=now+30
        Log("[RushAirDefense] army="..tostring(a.id).." observed="..tostring(s.observed)
            .." recentPeak="..tostring(s.peak).." fighters="..tostring(snapshot.roles.fighter or 0)
            .." wanted="..tostring(snapshot.airRaidFighters).." airfields="..tostring(snapshot.airFactories or 0),true)
    end
    return s
end
local function StaticCover(a,baseName)
    local base=a.ai.bases and a.ai.bases[baseName]
    if not base then return 0,0 end
    local complete,unfinished,planned=0,0,0
    for _,u in pairs(a.units or {}) do
        if R.Own(a,u) and Has(u.tp,"STRUCTURE") and Has(u.tp,"ANTI_AIR")
            and D2(u:GetPosition(),base.position)<=math.max(96,base.radius or 0)^2 then
            if u:IsCompleted() then complete=complete+1 else unfinished=unfinished+1 end
        end
    end
    for _,p in pairs(a.platoons or {}) do
        local f=p.ai and p.ai.formerTable
        if not p.dead and f and f.RushAirDefense=="turret" and p.ai.baseName==baseName then planned=planned+1 end
    end
    return complete,math.max(unfinished,planned)
end
function Allows(a,snapshot,baseName,kind)
    if not a.ai or a.ai.isAlive==false then return false end
    local s=Observe(a,snapshot);local localRaid=s.bases[baseName]
    local alloy,energy=snapshot.alloy,snapshot.energy
    if not Active(a) or not alloy or not energy or alloy.income<=0 or energy.income<=0 then return false end
    if kind=="airfield" then
        local layers=a.ai.settings and a.ai.settings.useLayer
        if layers and layers.air==false then return false end
        if (snapshot.airFactories or 0)+(snapshot.airFactoriesBuilding or 0)>0 then return false end
        for _,p in pairs(a.platoons or {}) do
            local f=p.ai and p.ai.formerTable
            if not p.dead and f and (f.RushEarlyAir or f.RushAirDefense=="airfield") then return false end
        end
        -- A counter-air opening must survive losing its third extractor.
        -- No free resources: accept one supply-limited field with real income.
        return (snapshot.landFactories or 0)>=1 and (snapshot.roles.engineer or 0)>=1
            and alloy.income>=3 and energy.income>=60
            and (energy.balance>=0 or energy.current>=math.max(300,-energy.balance*12))
    elseif kind=="turret" then
        if not localRaid or Now()>=localRaid.expires then return false end
        local ready,pending=StaticCover(a,baseName)
        local desired=math.min(Config.MaxTurrets,math.max(2,math.ceil(localRaid.peak/2)+1))
        -- One active build at a time; incomplete turrets still reserve a slot.
        return pending==0 and ready<desired and (snapshot.roles.engineer or 0)>=1
            and (energy.income>=30 or energy.current>=200)
    end
    return false
end
function CanFundInterceptor(snapshot,massRate,energyRate,tier)
    if not snapshot.airRaid or tier~=1 or not snapshot.alloy or not snapshot.energy then return false end
    local ready=snapshot.completeRoles and snapshot.completeRoles.fighter or 0
    local queued=(snapshot.roles.fighter or 0)-ready
    return queued<=0 and ready<(snapshot.airRaidFighters or 2)
        and snapshot.alloy.income>0 and snapshot.energy.income>0
        and massRate<=math.max(3,snapshot.alloy.income)
        and energyRate<=math.max(90,snapshot.energy.income*1.5)
end
function AddFormers(a,formers)
    for _,f in pairs(formers) do if f.RushAirDefense then return formers end end
    for _,kind in ipairs({"turret","airfield"}) do
        local f={FormerName=kind=="turret" and "R18 Reactive T1 Anti Air" or "R18 Counter-Air Factory Air",
            AIPlan="planBuildWithEngineer",Priority=kind=="turret" and 9840 or 9780,FormNumInstances=1,
            RushDevelopment=true,RushAirDefense=kind,AIdifficulty={easy=true,medium=true,hard=true},
            RunOnBaseType={MAIN=true,EXPANSION=kind=="turret",OUTPOST=false,NAVAL=false},
            RunWithStrategyName={},FormerConditions={},DebugPlatoon=false,AllowEcoStorageDrain=true,
            NeedMobileBuilder={{Tags.MOBILE*Tags.ENGINEER-Tags.COMMAND-Tags.TECH4,1,1,0}},
            WantStructures={(kind=="turret" and Tags.STRUCTURE*Tags.DEFENCE*Tags.ANTI_AIR or Tags.AIR_FACTORY)
                *Tags.TECH1*Tags[Factions[a.faction]]},WantStructuresSpacing=1,
            AvoidStructureWithinDistance={{Tags.ALLOYS_EXTRACTION*Tags.STRUCTURE,2}}}
        if kind=="turret" then
            f.AdjacentToStructure={Tags.FACTORY}
            f.AvoidStructureWithinDistance[#f.AvoidStructureWithinDistance+1]={Tags.STRUCTURE*Tags.ANTI_AIR,14}
        else f.InvestmentType="RushFirstAirfield" end
        formers[#formers+1]=f
    end
    return formers
end
