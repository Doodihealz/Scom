-- Army-owned strategic adaptation. Inputs are public starts/relationships,
-- our completed force, and the controller's observer-filtered threat census.
-- Decisions spend native resources; this module never changes lobby difficulty.
Version = "10.0.0"
Config = {Enabled=true, TopologySeconds=5, DecisionSeconds=2, ModeHoldSeconds=12,
    NearSpawnDistance=240, FarSpawnDistance=700, ThreatMemorySeconds=45}
local MG = Import("AI/AIMarkerGenerator.lua")
local function Number(n,default)
    if type(n)=="number" and n==n and math.abs(n)<math.huge then return n end
    return default or 0
end
local function Clamp(n,lo,hi) return math.max(lo,math.min(hi,n)) end
local function Valid(p)
    return type(p)=="table" and Number(p.x,-math.huge)>-math.huge
        and Number(p.z,-math.huge)>-math.huge
end
local function Distance(a,b) return math.sqrt((a.x-b.x)^2+(a.z-b.z)^2) end
local function State(army)
    local now=GetGameTimeSeconds()
    local s=army.ai.rushAdaptive
    if not s or s.at and now<s.at then
        s={};army.ai.rushAdaptive=s
    end
    return s,now
end
local function Connected(homeArea,position)
    if not homeArea or not Valid(position) then return nil end
    local area=MG.GetGraphAreaAtPosition(position,"Land",true)
    if not area then return nil end
    return area==homeArea
end
function Topology(army)
    if not army or not army.ai then return nil end
    local state,now=State(army)
    local base=army.ai.bases and army.ai.bases.MAIN
    local home=base and base.position
    local spawn=GameInfo and GameInfo.MapData and GameInfo.MapData.markers
        and GameInfo.MapData.markers.Spawn
    local starts=spawn and spawn.transforms
    local ready=type(MG.IsMarkerGridPresent)=="function" and MG.IsMarkerGridPresent()
    local old=state.topology
    if old and now>=old.at and now-old.at<Config.TopologySeconds
        and old.base==base and old.starts==starts and old.navigationReady==ready then return old end
    local t={at=now,base=base,starts=starts,navigationReady=ready,
        enemyCount=0,allyCount=0,enemies={},allies={}}
    local own=starts and starts[army.name]
    local origin=own and Valid(own.position) and own.position or home
    if Valid(origin) then t.home={x=origin.x,y=origin.y or 0,z=origin.z} end
    local homeArea=ready and Valid(home) and MG.GetGraphAreaAtPosition(home,"Land",true)
    for _,other in pairs(Armies or {}) do
        if other~=army and other:IsAlive() then
            local enemy,ally=army:IsEnemy(other),army:IsAlly(other)
            if enemy or ally then
                local list=enemy and t.enemies or t.allies
                local marker=starts and starts[other.name]
                local p=marker and marker.position
                local r={id=other.id}
                if Valid(p) then
                    r.position={x=p.x,y=p.y or 0,z=p.z}
                    r.distance=t.home and Distance(t.home,p)
                    r.connected=Connected(homeArea,p)
                end
                list[#list+1]=r
            end
        end
    end
    local function nearer(a,b)
        local da,db=a.distance or math.huge,b.distance or math.huge
        return da==db and a.id<b.id or da<db
    end
    table.sort(t.enemies,nearer);table.sort(t.allies,nearer)
    t.enemyCount,t.allyCount=#t.enemies,#t.allies
    t.nearestEnemyDistance=t.enemies[1] and t.enemies[1].distance
    t.nearestAllyDistance=t.allies[1] and t.allies[1].distance
    for _,enemy in ipairs(t.enemies) do
        if enemy.connected~=false and enemy.distance then
            t.nearestGroundEnemyDistance=enemy.distance;break
        end
    end
    -- Distant opponents and allies on a different landmass do not exert the
    -- same immediate ground pressure as neighbours. Unknown starts stay neutral.
    local reference=t.nearestGroundEnemyDistance or Config.FarSpawnDistance
    local opponents,support=0,0
    for _,e in ipairs(t.enemies) do
        local weight=e.distance and Clamp(reference/math.max(1,e.distance),0.25,1) or 0.5
        opponents=opponents+weight*(e.connected==false and 0.25 or 1)
    end
    for _,a in ipairs(t.allies) do
        if a.distance and a.connected==true then
            support=support+Clamp(reference/(reference+a.distance),0,0.8)
        end
    end
    t.exposure=Clamp(opponents/(1+support),0.35,3)
    t.nearbyAllySupport=support
    state.topology=t
    return t
end
function Get(army)
    if not Config.Enabled then return nil end
    local s=army and army.ai and army.ai.rushAdaptive
    return s and s.policy
end
function Update(army,snapshot)
    if not army or not army.ai or not snapshot then return nil end
    if not Config.Enabled then snapshot.adaptive=nil;return nil end
    local state,now=State(army)
    local t=Topology(army)
    local panic=snapshot.mainRaid or snapshot.mainBombardment or snapshot.localLandThreat
        or snapshot.airRaid or snapshot.airPanic and (snapshot.localAirCombatCount or 0)>0
    local own=math.max(0,Number(snapshot.groundThreat))
    local losses=state.ownThreat and state.ownThreat>0 and Clamp((state.ownThreat-own)/state.ownThreat,0,1) or 0
    local urgentLoss=losses>=0.20
    if state.policy and state.at and now-state.at<Config.DecisionSeconds and not urgentLoss
        and state.policy.topology==t
        and not (panic and state.policy.mode~="defend") then
        snapshot.adaptive=state.policy;return state.policy
    end
    local dt=state.at and math.max(0,now-state.at) or Config.DecisionSeconds
    local composition=snapshot.enemyComposition or {}
    local observed=Number(composition.landMobileThreat)+Number(composition.landDefenseThreat)*0.20
    local remembered=Number(state.observedThreat)*math.exp(-dt/Config.ThreatMemorySeconds)
    state.observedThreat=math.max(observed,remembered)
    if observed>0 then state.lastContact=now end
    state.lossPressure=math.max(losses,Number(state.lossPressure)*math.exp(-dt/20))
    local ratio=state.observedThreat/math.max(1,own)
    local known=state.lastContact and now-state.lastContact<=Config.ThreatMemorySeconds
    local distance=t.nearestGroundEnemyDistance
    local close=distance and Clamp((Config.FarSpawnDistance-distance)
        /(Config.FarSpawnDistance-Config.NearSpawnDistance),0,1) or 0.5
    if snapshot.landDisconnected then close=0 end
    local target=Clamp((ratio-0.65)*0.45+math.max(0,t.exposure-1)*0.25
        +state.lossPressure*1.5+(snapshot.landPressure and 0.20 or 0),0,1)
    state.challenge=state.challenge and state.challenge+(target-state.challenge)*(1-math.exp(-dt/10)) or target
    local a,e=snapshot.alloy or {},snapshot.energy or {}
    local stalled=Number(a.ratio,1)<0.15 and Number(a.balance)-Number(a.reserved)<0
        or Number(e.ratio,1)<0.15 and Number(e.balance)-Number(e.reserved)<0
    local mode
    if panic then mode="defend"
    elseif state.lossPressure>0.18 or stalled then mode="recover"
    elseif known and own>state.observedThreat*1.35 and Number(snapshot.groundReady)>=6 then mode="pressure"
    else mode="develop" end
    local previous=state.policy
    if previous and mode~=previous.mode and mode~="defend" and not (mode=="recover" and urgentLoss)
        and now-Number(state.modeSince,now)<Config.ModeHoldSeconds then mode=previous.mode end
    if not previous or previous.mode~=mode then state.modeSince=now end
    local difficulty=army.ai.settings and army.ai.settings.difficulty or "hard"
    local skill=difficulty=="easy" and 0.65 or difficulty=="medium" and 0.85 or 1
    local challenge=state.challenge
    local ground=Clamp(math.ceil(4+Number(snapshot.landFactories)*1.5+close*3
        +math.max(0,t.exposure-1)*3+challenge*3),4,20)
    local policy={topology=t,mode=mode,challenge=challenge,difficulty=difficulty,
        groundFloor=ground,
        militaryGoal=Clamp(ground+math.ceil(close*3+challenge*4),6,28),
        techGroundMinimum=Clamp(math.ceil(7+close*5+challenge*5+state.lossPressure*8),6,22),
        raidGroundMinimum=Clamp(ground+3,8,20),
        raidGroups=mode=="defend" and 0 or math.min(4,math.max(1,t.enemyCount+1)),
        raidShare=mode=="recover" and 0.20 or mode=="pressure" and 0.45 or 0.35,
        raiderShare=mode=="defend" and 0.15 or mode=="pressure" and 0.30 or 0.23,
        expansionLimit=mode=="defend" and 1 or mode=="recover" and 2 or 3,
        engineerBias=mode=="develop" and math.floor((1-close)*100) or mode=="defend" and -100 or 0,
        combatBias=(mode=="defend" or mode=="recover") and math.floor(50+challenge*80) or 0,
        landScouts=math.min(3,math.max(1,math.ceil(t.enemyCount/2)+(distance and distance>700 and 1 or 0))),
        airScouts=math.min(3,math.max(1,math.ceil(t.enemyCount/2))),
        attackAdjustment=(mode=="pressure" and 7 or mode=="defend" and -7 or 0)*skill
            -challenge*8-(1-skill)*12}
    if snapshot.landDisconnected then policy.raidGroups=0 end
    state.policy=policy;state.ownThreat=own;state.at=now
    snapshot.adaptive=policy
    return policy
end
function AttackStrength(army,basePercent)
    local p=Get(army)
    local base=Number(basePercent,80)
    return p and Clamp(base+p.attackAdjustment,50,110) or base
end
function RaidBias(army,position)
    if not Config.Enabled or not Valid(position) then return 0 end
    local t=Topology(army)
    if not t or not t.home then return 0 end
    local enemyDistance
    for _,enemy in ipairs(t.enemies) do
        if enemy.position and enemy.connected~=false then
            local d=Distance(position,enemy.position)
            enemyDistance=enemyDistance and math.min(enemyDistance,d) or d
        end
    end
    if not enemyDistance then return 0 end
    local homeDistance=Distance(position,t.home)
    -- Geography suggests where to scout; it never asserts enemy ownership.
    return Clamp((enemyDistance-homeDistance)*0.30,-160,160)
end
