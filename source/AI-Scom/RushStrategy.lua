-- Snapshot-only strategic policy for Sanctuary. The controller supplies our
-- paid/queued army, public map topology and observer-filtered enemy contacts.
-- General ideas researched in M28AI: useful spending capacity, map-dependent
-- investment and finite counter deficits. This is independent Sanctuary code;
-- no Supreme Commander APIs, source implementation or numeric rules are used.
Version = "10.0.0"
Config = {Enabled=true, ThreatMemorySeconds=30, SiegeMemorySeconds=18,
    NearSpawnDistance=320, FarSpawnDistance=800}

local function Number(value, fallback)
    if type(value)=="number" and value==value and math.abs(value)<math.huge then return value end
    return fallback or 0
end
local function Clamp(value, low, high) return math.max(low,math.min(high,value)) end
local function Count(t,key) return math.max(0,Number(t and t[key])) end
local function LocalView(s) return s.rushBeachheadBase or s.rushSupportCensus end
local function LayerEnabled(army,domain)
    local settings=army and army.ai and army.ai.settings
    local layers=settings and settings.useLayer
    return not layers or layers[domain=="naval" and "water" or domain]~=false
end
local function Shares(army,s,close,homeGround)
    local land,air,naval=0.78,0.22,0
    if s.landDisconnected then land,air,naval=0.05,0.70,0.25
    elseif homeGround then land,air=0.90,0.10
    elseif close>=0.75 then land,air=0.86,0.14
    elseif close<=0.15 then land,air=0.65,0.35 end
    if not s.landDisconnected and (s.navalThreat or s.navalPanic) then
        naval=0.15;land,air=land*(1-naval),air*(1-naval)
    end
    -- A real air raid needs a funded air response without abandoning the land
    -- army. Merely being inside a map-wide panic zone does not change domains.
    if s.airRaid then
        local addition=math.min(0.15,land*0.25)
        land,air=land-addition,air+addition
    end
    if not LayerEnabled(army,"land") then land=0 end
    if not LayerEnabled(army,"air") then air=0 end
    if not LayerEnabled(army,"naval") then naval=0 end
    local total=land+air+naval
    -- A single enabled domain remains useful even when the usual mix assigned
    -- it no share (for example a naval-only lobby).
    if total<=0 then
        if LayerEnabled(army,"land") then land=1
        elseif LayerEnabled(army,"air") then air=1
        elseif LayerEnabled(army,"naval") then naval=1 end
        total=land+air+naval
    end
    if total>0 then return land/total,air/total,naval/total end
    return 0,0,0
end

function Get(army)
    local state=army and army.ai and army.ai.rushStrategy
    return Config.Enabled and state and state.policy or nil
end

function Update(army,s)
    if not army or not army.ai or not s then return nil end
    if not Config.Enabled then s.strategy=nil;return nil end
    -- A beachhead's smaller census must not overwrite the whole-army decision.
    -- Its own former and funding policies already have local force thresholds.
    if LocalView(s) then return nil end
    local now=GetGameTimeSeconds()
    local state=army.ai.rushStrategy
    if not state or state.at and now<state.at then state={};army.ai.rushStrategy=state end
    local dt=state.at and math.max(0,now-state.at) or 0
    local r=s.roles or {}
    local front=Count(r,"frontline")+Count(r,"raider")
    local ready=math.max(0,Number(s.groundReady))
    local own=math.max(0,Number(s.groundThreat))
    local composition=s.enemyComposition or {}
    local mobile=Count(composition,"landMobileThreat")
    local defense=Count(composition,"landDefenseThreat")
    local defenses=Count(composition,"landDefenseCount")
    local topology=s.adaptive and s.adaptive.topology or {}
    local distance=Number(topology.nearestGroundEnemyDistance,-1)
    local close=distance>=0 and Clamp((Config.FarSpawnDistance-distance)
        /(Config.FarSpawnDistance-Config.NearSpawnDistance),0,1) or 0.5
    local landActive=LayerEnabled(army,"land") and not s.landDisconnected
    local homeGround=s.mainRaid==true or s.mainBombardment==true or s.localLandThreat==true
    if not landActive then close=0 end

    -- Briefly retain observed mobile strength through a vision gap. This is
    -- production guidance only: global strength never authorizes an attack.
    state.mobileThreat=math.max(mobile,Number(state.mobileThreat)
        *math.exp(-dt/Config.ThreatMemorySeconds))
    if mobile>0 or defense>0 then state.lastContact=now end
    local known=state.lastContact~=nil and now-state.lastContact<=Config.ThreatMemorySeconds
    if not known then state.mobileThreat=0 end
    local enemy=state.mobileThreat
    local ratio=own>0 and enemy/own or enemy>0 and 4 or 0
    local loss=Number(state.ownThreat)>0 and Clamp((state.ownThreat-own)/state.ownThreat,0,1) or 0
    state.lossPressure=math.max(loss,Number(state.lossPressure)*math.exp(-dt/12))

    local wallVisible=defenses>=2 and defense>=math.max(1,mobile)*0.50
    if wallVisible or s.mainBombardment then state.lastWall=now end
    local siege=state.lastWall~=nil and now-state.lastWall<=Config.SiegeMemorySeconds
    local mode
    if homeGround then mode="defend"
    elseif not landActive then mode="project"
    elseif state.lossPressure>=0.35 and ready<8 then mode="recover"
    elseif siege then mode="siege"
    elseif known and ready>=6 and own>enemy*1.30 then mode="pressure"
    else mode="contest" end

    -- Separate the first usable attacking group, emergency replacement floor,
    -- and ongoing production demand. A larger factory network must not move
    -- the technology/attack launch requirement further away every time it grows.
    local factories=math.max(0,Number(s.landFactories))
    local core=Clamp(5+math.min(3,factories)+math.floor(close+0.25),6,10)
    if homeGround or known and ratio>1.5 then core=math.min(12,core+2) end
    local floor=Clamp(math.ceil(core*0.5),3,6)
    local military=math.max(core,math.min(36,6+factories*3))
    if known and own>0 and ready>=4 then
        military=math.max(military,math.min(40,math.ceil(enemy/(own/ready)*1.15)))
    end
    local tech=close>=0.75 and 8 or close<=0.15 and 4 or 6
    if siege and not homeGround then tech=math.min(tech,6) end
    if homeGround then tech=math.min(10,tech+2) end
    if not landActive and not homeGround then core,floor,military,tech=0,0,0,0 end

    local raiderShare=mode=="defend" and 0.12 or mode=="pressure" and 0.28 or 0.20
    local raiderGoal=front>0 and math.max(1,math.ceil(front*raiderShare)) or 1
    local artilleryGoal=front>=4 and math.min(16,siege and math.max(2,math.ceil(front*0.25))
        or math.floor(front*0.10)) or 0
    local aaGoal=math.min(4,math.floor(front/20))
    if s.airThreat then aaGoal=math.min(16,math.max(2,math.ceil(front*0.18))) end
    if s.airRaid then aaGoal=math.min(20,math.max(2,math.ceil(front*0.25))) end
    local enemies=math.max(1,Number(topology.enemyCount,1))
    local scouts=landActive and Clamp(math.ceil(enemies/2),1,3) or 0
    local airScouts=LayerEnabled(army,"air") and Clamp(math.ceil(enemies/2),1,3) or 0
    local landShare,airShare,navalShare=Shares(army,s,close,homeGround)
    local policy={at=now,mode=mode,knownContact=known,forceRatio=ratio,
        homeGround=homeGround,siege=siege,close=close,
        groundFloor=floor,groundCore=core,militaryGoal=military,techGroundMinimum=tech,
        raiderGoal=raiderGoal,raiderShare=raiderShare,artilleryGoal=artilleryGoal,
        mobileAAGoal=aaGoal,scoutGoal=scouts,airScoutGoal=airScouts,
        landShare=landShare,airShare=airShare,navalShare=navalShare}
    state.policy=policy;state.ownThreat=own;state.at=now
    s.strategy=policy
    return policy
end

function LandCoreGoal(s)
    if not s or LocalView(s) then return 6 end
    return s.strategy and s.strategy.groundCore or 6
end

function RoleBias(army,s,role,tier)
    if not Config.Enabled or not s or LocalView(s) then return 0 end
    local p=s.strategy or Update(army,s)
    if not p then return 0 end
    local r=s.roles or {}
    local front=Count(r,"frontline")+Count(r,"raider")
    if role=="frontline" then
        local bias=front<p.militaryGoal and 35 or 0
        if p.homeGround then bias=bias+35
        elseif p.mode=="pressure" then bias=bias+20 end
        if Count(r,"frontline")<math.max(2,math.ceil(front*(1-p.raiderShare))) then bias=bias+35 end
        return math.min(105,bias)
    elseif role=="raider" then
        return Count(r,role)<p.raiderGoal and (p.homeGround and 5 or 55) or -90
    elseif role=="artillery" then
        return Count(r,role)<p.artilleryGoal and (p.siege and 25 or 10) or -120
    elseif role=="mobileAA" then
        return Count(r,role)<p.mobileAAGoal and (s.airRaid and 25 or s.airThreat and 35 or 0) or -120
    elseif role=="landScout" then
        return Count(r,role)<p.scoutGoal and not p.homeGround and (p.knownContact and 0 or 20) or -120
    elseif role=="airScout" then
        return Count(r,role)<p.airScoutGoal and not s.airRaid and (p.knownContact and 0 or 15) or -120
    elseif role=="fighter" then
        return s.airRaid and 20 or 0
    end
    -- Workforce recovery, exact tier suitability, launch funding and unit
    -- permissions stay with the existing native product selection contracts.
    return 0
end
