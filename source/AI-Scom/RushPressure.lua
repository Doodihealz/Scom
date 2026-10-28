-- RC11: army-first policy and public-map exploration. No hidden unit access.
Version = "9.0.22-rc26"
local MG = Import("AI/AIMarkerGenerator.lua")
local P = Import("AI/mods/AI-Scom/RushHeavyPolicy.lua")
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local function Valid(p) return type(p)=="table" and type(p.x)=="number" and type(p.z)=="number"
    and p.x==p.x and p.z==p.z and math.abs(p.x)<math.huge and math.abs(p.z)<math.huge end
local markerSource, markerCache
function SurvivalMap()
    local info=GameInfo and GameInfo.MapInfo
    return type(info and info.dataName)=="string"
        and info.dataName:find("_Survival_",1,true)~=nil
end
function AlloyMarkers()
    local c=GameInfo and GameInfo.MapData and GameInfo.MapData.markers and GameInfo.MapData.markers.Alloys
    local source=type(c)=="table" and c.transforms
    if source==markerSource and markerCache then return markerCache end
    markerSource,markerCache=source,{}
    for _,m in pairs(type(source)=="table" and source or {}) do
        local p=type(m)=="table" and m.position
        if Valid(p) then markerCache[#markerCache+1]={x=p.x,y=p.y or 0,z=p.z} end
    end
    table.sort(markerCache,function(a,b) return a.x==b.x and a.z<b.z or a.x<b.x end)
    return markerCache
end
-- Public resource locations are scouting destinations, NOT evidence of enemy ownership.
function RaidCandidates(army,home,position,layer)
    local result={}
    -- Scripted survival waves have no opponent economy to raid. Keep the
    -- ground force available for observed attackers near its own base.
    if SurvivalMap() or not Valid(home) or not Valid(position) then return result end
    local expansion=army.ai and army.ai.rushExpansion
    local now=GetGameTimeSeconds()
    for _,p in ipairs(AlloyMarkers()) do
        local key=math.floor(p.x).."-"..math.floor(p.z)
        local request=expansion and expansion.requests and expansion.requests[key]
        local builder=request and request.builder
        local wanted=request and request.expires>now and builder and not builder.dead and not builder.deleted
            and builder.army==army and builder.platoon and builder.ai and builder.ai.nextResourceSpot
            and builder.ai.nextResourceSpot.position
            and D2(builder.ai.nextResourceSpot.position,p)<4
        local held=expansion and expansion.at and now>=expansion.at and now-expansion.at<=6
            and expansion.owned and expansion.owned[key]
        if (wanted or not held) and D2(home,p)>50^2 and D2(position,p)>30^2 then
            -- Patrols support a current expansion destination instead of walking
            -- repeatedly around an already-owned extractor. Enemy acquisition,
            -- local combat and checked retreat rules remain authoritative.
            result[#result+1]={pos=p,score=math.sqrt(D2(position,p))
                -math.min(180,math.sqrt(D2(home,p)))*0.20-(wanted and 70 or 0)}
        end
    end
    table.sort(result,function(a,b)
        if a.score~=b.score then return a.score<b.score end
        return a.pos.x==b.pos.x and a.pos.z<b.pos.z or a.pos.x<b.pos.x
    end)
    return result
end
-- Cap the rate of PAID enhancement work. Applied only by the Rush-private adapter.
-- Entity buildPower and resource totals.income are per tick in Sanctuary.
function EnhancementBudget(unit,id)
    local role=unit and unit.ai and unit.ai.rushCommanderRole
    if role and role.owner==unit.army and role.selected and role.selected[id] then
        if role.role=="offense" then return 0.25,0.30 end
        return 0.20,0.25
    end
    -- Preserve an already-running gun upgrade that predates role selection.
    if unit and unit.tpId=="ugl0000" and id=="CoolingUpgrade" then return 0.25,0.30 end
    return 0.12,0.15
end
local function EnhancementFinite(value)
    return type(value)=="number" and value==value and math.abs(value)<math.huge
end
local function EnhancementFunding(resource,share,horizon,tick)
    if not resource or not EnhancementFinite(resource.income) or resource.income<0
        or not EnhancementFinite(resource.current) or resource.current<0
        or not EnhancementFinite(resource.storage) or resource.storage<0 then return nil end
    local bank=math.max(0,resource.current-resource.storage*0.20)
    local amount=resource.income*tick*share+bank/horizon
    return EnhancementFinite(amount) and amount or nil
end
-- Forecast and paid progress use this same native-rate cap. Finite stored
-- resources above the reserve may accelerate work; they are never new income.
local function EnhancementScale(cost,buildTime,power,a,e,massShare,energyShare,horizon,tick)
    if not cost or not EnhancementFinite(cost.mass) or cost.mass<0
        or not EnhancementFinite(cost.energy) or cost.energy<0
        or not EnhancementFinite(buildTime) or buildTime<=0
        or not EnhancementFinite(power) or power<=0 then return nil end
    local mass=EnhancementFunding(a,massShare,horizon,tick)
    local energy=EnhancementFunding(e,energyShare,horizon,tick)
    if not mass or not energy then return nil end
    local mr,er=power*cost.mass/buildTime,power*cost.energy/buildTime
    if not EnhancementFinite(mr) or not EnhancementFinite(er) then return nil end
    local scale=1
    if mr>0 then scale=math.min(scale,mass/mr) end
    if er>0 then scale=math.min(scale,energy/er) end
    return math.max(0,math.min(1,scale)),mr,er
end
function EnhancementForecast(unit,id,cost,a,e)
    local power=unit and unit.construction and unit.construction.buildPower
    if not cost or not EnhancementFinite(cost.buildTime) or cost.buildTime<=0
        or not EnhancementFinite(power) or power<=0 then return nil end
    local authored=cost.buildTime/power
    if not EnhancementFinite(authored) or authored<=0 then return nil end
    local massShare,energyShare=EnhancementBudget(unit,id)
    -- Rules.Resources exposes per-second income; native entities use per-tick
    -- power/income below. Storage is an absolute amount in both representations.
    local scale,mass,energy=EnhancementScale(cost,cost.buildTime,power,a,e,massShare,energyShare,
        math.max(10,authored),1)
    if not scale or scale<=0 then return nil end
    local seconds=authored/scale
    if not EnhancementFinite(seconds) then return nil end
    return mass*scale,energy*scale,seconds,authored
end
function EnhancementMultiplier(unit,active,entity)
    if not P.Enabled(unit and unit.army) then return 1 end
    if not active or not active.cost or not EnhancementFinite(active.buildTime) or active.buildTime<=0
        or not EnhancementFinite(active.progress) then return 0 end
    local tick=Constants and Constants.TickRate
    if not EnhancementFinite(tick) or tick<=0 then return 0 end
    local owners={};local totalPower=0
    local function add(army,source)
        local economy=army and army.economy
        local registered=economy and economy.resourceEntities and economy.resourceEntities.construction
        if not army or not source or source.enabled~=true or source.economy~=economy or source.armyId~=army.id
            or not registered or registered[source.id]~=source
            or not EnhancementFinite(source.buildPower) or source.buildPower<=0 then return false end
        local power=source.buildPower*tick
        owners[army]=(owners[army] or 0)+power;totalPower=totalPower+power
        return true
    end
    if not add(unit.army,entity) then return 0 end
    for _,contribution in pairs(active.assistEntities or {}) do
        add(contribution.builder and contribution.builder.army,contribution.entity)
    end
    local remaining=math.max(0,active.buildTime-active.progress)
    if remaining<=0 then return 0 end
    local horizon=math.max(10,remaining/totalPower)
    local scale=1;local massShare,energyShare=EnhancementBudget(unit,active.id)
    for army,power in pairs(owners) do
        local totals=army.economy and army.economy.totals
        local ownerScale=EnhancementScale(active.cost,active.buildTime,power,
            totals and totals.alloys,totals and totals.energy,massShare,energyShare,horizon,tick)
        if not ownerScale then return 0 end
        scale=math.min(scale,ownerScale)
    end
    return math.max(0,math.min(1,scale))
end
function LandFactoryGoal(income)
    return math.min(128,math.max(3,math.floor(math.max(0,income or 0)/4))*4)
end
function GeneratorGoal(factories)
    return math.min(512,math.max(8,(factories or 1)*8))
end
-- Spawn markers and Land graph labels describe the map without running A*.
-- Unknown stays nil until the asynchronous navigation grid and every enemy
-- anchor resolve, so ordinary ground production remains available.
function EnemyLandConnection(army)
    if not army or not army.ai or not army.ai.bases or not army.ai.bases.MAIN then return nil end
    if type(MG.IsMarkerGridPresent)~="function" or not MG.IsMarkerGridPresent()
        or type(MG.GetGraphAreaAtPosition)~="function" then return nil end
    local now=GetGameTimeSeconds()
    local cached=army.ai.rushLandConnection
    if cached and now>=cached.at and now-cached.at<(cached.value==nil and 5 or 30) then
        return cached.value
    end
    local home=army.ai.bases.MAIN.position
    local homeArea=Valid(home) and MG.GetGraphAreaAtPosition(home,"Land",true)
    if not homeArea then
        army.ai.rushLandConnection={at=now,value=nil}
        return nil
    end
    local found,unknown=false,false
    local spawn=GameInfo and GameInfo.MapData and GameInfo.MapData.markers
        and GameInfo.MapData.markers.Spawn
    local starts=spawn and spawn.transforms
    for _,enemy in pairs(Armies or {}) do
        if enemy~=army and enemy.units and next(enemy.units) and army:IsEnemy(enemy) then
            -- A scripted wave army has no Spawn marker. Reading map metadata
            -- directly keeps the unknown result without logging every poll.
            local marker=starts and starts[enemy.name]
            local start=marker and marker.position
            local area=Valid(start) and MG.GetGraphAreaAtPosition(start,"Land",true)
            if area then
                found=true
                if area==homeArea then
                    army.ai.rushLandConnection={at=now,value=true}
                    return true
                end
            else
                unknown=true
            end
        end
    end
    local value
    if found and not unknown then value=false end
    army.ai.rushLandConnection={at=now,value=value}
    return value
end
-- The target manager already publishes one current panic target per army.
-- Check its graph label so a nearby enemy across a channel is not local.
function LocalLandThreat(army)
    if not army or not army.ai or not army.ai.bases or not army.ai.bases.MAIN
        or not MG.IsMarkerGridPresent() then return false end
    local home=army.ai.bases.MAIN.position
    local homeArea=Valid(home) and MG.GetGraphAreaAtPosition(home,"Land",true)
    if not homeArea then return false end
    for _,target in ipairs(army.ai.emergencyTargets or {}) do
        if target.reason=="PanicLandTarget" and target.armyIndex==army.id
            and Valid(target.targetPosition)
            and MG.GetGraphAreaAtPosition(target.targetPosition,"Land",true)==homeArea then
            return true
        end
    end
    return false
end
