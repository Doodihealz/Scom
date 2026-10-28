-- RC15: spend on a sustainable field army before optional development.
-- Inputs are the controller's per-second, owned-unit snapshot. This module
-- never changes income, prices, build power, paid work, or native permissions.
Version = "9.0.24-rc29"
local Rules=Import("AI/mods/AI-Scom/RushBalance.lua")
local Pressure=Import("AI/mods/AI-Scom/RushPressure.lua")
local AF=Import("AI/AIFunctions.lua")
local Reliability
local function Number(n, default)
    if type(n)=="number" and n==n and math.abs(n)<math.huge then return n end
    return default or 0
end
local function Balance(r)
    return Number(r.balance,Number(r.income)-Number(r.request))-Number(r.reserved)
end
function LandEnabled(army)
    local settings=army and army.ai and army.ai.settings
    return (not settings or not settings.useLayer or settings.useLayer.land~=false)
        and Pressure.EnemyLandConnection(army)~=false
end
function GroundReady(s)
    if s.groundReady~=nil then return Number(s.groundReady) end
    local r=s.completeRoles or s.roles or {}
    return Number(r.frontline)+Number(r.raider)+Number(r.artillery)
end
-- Completed advanced troops count toward development readiness; queued units
-- do not. Share this one cached census value across production and upgrades.
function GroundStrength(s)
    if s.techGroundStrength~=nil then return s.techGroundStrength end
    local strength=0
    for tier,weight in ipairs({1,2,4,8}) do
        for _,role in ipairs({"frontline","raider","artillery"}) do
            strength=strength+Number(s.completeTiers and s.completeTiers[role..":"..tier])*weight
        end
    end
    s.techGroundStrength=math.max(GroundReady(s),strength)
    return s.techGroundStrength
end
function EngineerFloor(s)
    if Number(s.landFactories)<=1 and Number(s.extractors)<3 and GroundReady(s)<2 then return 2 end
    return math.min(8,math.max(4,math.ceil(Number(s.extractors)*0.35+Number(s.landFactories)*0.25)))
end
function GroundFloor(s)
    return math.min(16,math.max(6,Number(s.landFactories)*2))
end
-- A technology unlock is not a field replacement. Count only completed
-- fighting units; unfinished orders and an engineer do not form a combat tier.
local function CombatAtTier(s,tier)
    local count=0
    for t=tier,4 do
        for _,role in ipairs({"frontline","raider"}) do
            count=count+Number(s.completeTiers and s.completeTiers[role..":"..t])
        end
    end
    return count
end
function GroundTransitionReady(s,tier)
    if tier~=2 and tier~=3 then return false end
    local minimum=math.max(Rules.Config.TechGroundUnits,GroundFloor(s),tier==3 and 16 or 0)
    if s.landPressure or s.landPanic then minimum=minimum+4 end
    if GroundReady(s)<minimum then return false end
    return tier==2 or CombatAtTier(s,2)>=math.max(6,math.ceil(minimum*0.35))
end
function GroundReplacementReady(s,tier)
    if tier~=2 and tier~=3 or GroundReady(s)<GroundFloor(s) then return false end
    -- Keep the replacement target finite while inexpensive lines reinforce;
    -- lateral upgrades must not wait on a ratio that their own delay enlarges.
    local required=math.max(tier==3 and 6 or 8,math.min(tier==3 and 12 or 16,
        math.ceil(CombatAtTier(s,1)*(tier==3 and 0.40 or 0.50))))
    return CombatAtTier(s,tier)>=required
end
function AlloyStalled(s,releasedMass)
    local a=s and s.alloy
    if not a then return true end
    local income=Number(a.income)
    if income<=0 then return true end
    local reserve=math.max(24,math.min(Number(a.storage)*0.75,income*6))
    return Number(a.current)<reserve
        and Balance(a)+Number(releasedMass)<-math.max(1,income*0.15)
end
function NeedsGroundRecovery(army,s)
    return (s.rushBeachheadBase or LandEnabled(army)) and Number(s.landFactories)>0
        and GroundReady(s)<GroundFloor(s)
end
function CanStartTech(army,s,releasedMass,releasedEnergy)
    local a,e=s.alloy,s.energy
    if not a or not e or Number(a.income)<=0 or Number(e.income)<=0 then return false end
    if AlloyStalled(s,releasedMass) then return false end
    -- Development can run while the army replaces losses. NeedTech still
    -- requires its minimum force; only a nearly wiped army pauses investment.
    if NeedsGroundRecovery(army,s) and GroundReady(s)<2 then return false end
    local mass=Balance(a)+Number(releasedMass)
    local energy=Balance(e)+Number(releasedEnergy)
    local affordable=mass>=math.max(3,Number(a.income)*0.12)
        or (Number(a.current)>=math.max(120,math.min(Number(a.storage)*0.75,Number(a.income)*6))
            and Number(a.current)>=math.max(0,-mass)*25)
    local powered=Number(e.ratio)>=0.25 and (energy>=0 or Number(e.current)>=-energy*30)
    return affordable and powered
end
function PowerHeadroom(s)
    local e=s.energy
    if not e then return 0 end
    local headroom=math.max(30,math.min(120,Number(e.income)*0.15),
        math.min(120,Number(s.landFactories)*12+Number(s.airFactories)*20))
    -- Do not fund an imaginary future factory bank while real tanks lack Alloy.
    if AlloyStalled(s) then headroom=math.min(headroom,math.max(25,Number(e.income)*0.10)) end
    local r=s.roles or {}
    if Number(s.airFactories)+Number(s.airFactoriesBuilding)>0 and Number(r.bomber)<2
        and not AlloyStalled(s) then headroom=math.max(headroom,90) end
    -- Prepare for spending currently unspent Alloy, using the actual active
    -- production mix rather than assuming a stock Energy/Alloy conversion.
    local a=s.alloy
    if a and Number(a.storage)>0 and Balance(a)>0
        and Number(a.current)+Balance(a)*45>=Number(a.storage)*0.90 then
        local ratio=Number(s.productionEnergyPerAlloy)
        if ratio<=0 and Number(a.request)>0 then ratio=Number(e.request)/Number(a.request) end
        headroom=math.max(headroom,Balance(a)*math.max(0,ratio))
    end
    return math.max(headroom,Number(s.mainShieldPowerNeed))
end
function NeedsPower(s)
    local e=s.energy
    if not e then return false end
    -- The generator must not claim another builder when alloy has collapsed
    -- but stored energy and its current income cover live demand.
    local shieldPower=Number(s.mainShieldPowerNeed)>0 and Number(s.mainShieldPowerNeed)>Balance(e)
    if not s.techPowerNeeded and not shieldPower and Rules.PowerSurplusDuringAlloyShortage(s) then return false end
    local income=Number(e.income)
    if income<=0 then return true end
    local balance=Balance(e)
    local headroom=math.max(PowerHeadroom(s),Number(s.techPowerHeadroom))
    local a=s.alloy
    local filling=a and Number(a.storage)>0 and Balance(a)>0
        and Number(a.current)+Balance(a)*45>=Number(a.storage)*0.90
    local depletion=balance<0 and Number(e.current)+balance*45<=Number(e.storage)*0.20
    if Number(e.ratio)>Rules.Config.HighEnergy and not depletion and not filling
        and not s.techPowerNeeded and not shieldPower then return false end
    return balance<headroom
        or (Number(e.ratio)<0.35 and balance<math.max(40,income*0.25))
end
function CanAddCapacity(army,s,domain)
    if not s.alloy or not s.energy then return false end
    if domain=="land" and Number(s.landFactories)<2 then
        if Number(s.landFactories)==0 then return true end
        if s.rushBeachheadBase then
            return Number(s.energy.ratio)>=Rules.Config.CapacityEnergy and Balance(s.energy)>=0 and not AlloyStalled(s)
        end
        local generators=0
        for _,n in pairs(s.powerComplete or {}) do generators=generators+Number(n) end
        for _,n in pairs(s.powerPending or {}) do generators=generators+Number(n) end
        return Number(s.extractors)>0 and generators>0
    end
    if domain=="air" and LandEnabled(army) and Number(s.landFactories)<2 then return false end
    -- Only new ordinary capacity: never cancel a paid foundation. Current
    -- Energy plus already committed work must support another factory.
    return Number(s.energy.ratio)>=Rules.Config.CapacityEnergy and Balance(s.energy)>=0
        and not AlloyStalled(s)
end
function CanRecoverEngineer(s,massRate,energyRate,tier,engineersIdle)
    if tier~=1 or not s.alloy or not s.energy then return false end
    local r=s.roles or {}
    local ready=s.engineersComplete~=nil and Number(s.engineersComplete) or Number(r.engineer)
    local queued=s.engineersQueued~=nil and Number(s.engineersQueued) or 0
    if queued>0 or ready>=EngineerFloor(s) or Number(engineersIdle,Number(s.engineersIdle))>=2 then return false end
    local a,e=s.alloy,s.energy
    return Number(a.income)>0 and Number(e.income)>0
        and massRate<=math.max(5,Number(a.income)*0.75)
        and energyRate<=math.max(40,Number(e.income)*0.50)
end

-- One real advanced builder opens the next power/economy tier. Completed,
-- queued and dispatched builders all count; a higher-tier builder covers a
-- lower-tier gap. This is an unlock/replacement, not an unlimited engineer line.
function NeedsTechEngineer(s,tier)
    if tier~=2 and tier~=3 then return false end
    for t=tier,3 do
        if Number(s.tiers and s.tiers["engineer:"..t])>0 then return false end
    end
    return true
end
function CanRecoverTechEngineer(s,massRate,energyRate,tier)
    if not NeedsTechEngineer(s,tier) or not s.alloy or not s.energy
        or Number(massRate,-1)<0 or Number(energyRate,-1)<0 then return false end
    if not s.landDisconnected and (s.landPanic or s.airPanic) and GroundReady(s)<2 then return false end
    local a,e=s.alloy,s.energy
    return Number(a.income)>0 and Number(e.income)>0
        and massRate<=math.max(6,Number(a.income)*1.25)
        and energyRate<=math.max(60,Number(e.income))
end

function CanRecoverGround(s,massRate,energyRate,tier)
    if (tier~=1 and tier~=2 and tier~=3) or not s.alloy or not s.energy
        or Number(massRate,-1)<0 or Number(energyRate,-1)<0 then return false end
    local ground=GroundReady(s)
    local floor=math.max(GroundFloor(s),Rules.Config.TechGroundUnits)
    local pressure=s.landPressure or s.landPanic
    local technology=s.alloy.techOwner or s.alloy.commanderOwner or s.alloy.heavyOwner or Number(s.upgrades)>0
    if ground>=floor and not pressure
        and not AlloyStalled(s,Number(s.alloy.techReserved)+Number(s.alloy.commanderReserved)
            +Number(s.alloy.heavyReserved)) then return false end
    -- Paid technology stays intact, but cannot suppress every affordable
    -- defender until only one unit remains. Recovery is still bounded by the
    -- actual queued/unfinished force and the shared committed resource view.
    if technology and ground>=floor and not pressure then return false end
    local limit=technology and pressure and 2 or 1
    local roles,ready=s.roles or {},s.completeRoles or {}
    local queued=0
    for _,role in ipairs({"frontline","raider","artillery","mobileAA"}) do
        queued=queued+math.max(0,Number(roles[role])-Number(ready[role]))
    end
    if queued>=limit then return false end
    local a,e=s.alloy,s.energy
    if Number(a.income)<=0 or Number(e.income)<=0 then return false end
    if technology and ground>=2 then
        -- Keep a small T1/T2 line affordable beside the native upgrade. Do not
        -- grant its reserved income to another expensive advanced project.
        return tier<=2 and massRate<=math.max(3,Number(a.income)*0.35/limit)
            and energyRate<=math.max(30,Number(e.income)*0.40/limit)
            and Number(a.request)+Number(a.reserved)+massRate<=Number(a.income)*2
            and Number(e.request)+Number(e.reserved)+energyRate<=Number(e.income)*1.5
    end
    return massRate<=math.max(8,Number(a.income)*1.25)
        and energyRate<=math.max(tier==1 and 40 or 60,Number(e.income)*(tier==1 and 0.50 or 0.75))
end

-- The persistent extractor manager and one-shot development formers use the
-- same native candidate and budget. A distant raid does not freeze safe home
-- income, and legacy fair-share shortcuts cannot spend a factory commitment.
function CanUpgradeExtractor(unit,s)
    local army=unit and unit.army
    if not Rules.Own(army,unit) or not unit:IsCompleted()
        or not Rules.Has(unit.tp,"STRUCTURE") or not Rules.Has(unit.tp,"ALLOYS_EXTRACTION")
        or AF.IsUnderAttack(unit) or type(unit.GetPause)=="function" and unit:GetPause()
        or type(unit.GetUpgradeTpId)~="function" then return false end
    Reliability=Reliability or Import("AI/mods/AI-Scom/RushReliability.lua")
    local orders=unit.orders
    if Reliability.Working(unit) or orders and (orders.activeOrder or orders.queuedOrders and next(orders.queuedOrders)) then return false end
    local id=unit:GetUpgradeTpId()
    local target=id and __Templates and __Templates.Units and __Templates.Units[id]
    local tier=Rules.Tier(unit.tp)
    if (tier~=1 and tier~=2) or not target or Rules.Tier(target)~=tier+1
        or not Rules.Has(target,"ALLOYS_EXTRACTION") or not Reliability.AllowedTarget(id,false)
        or not Reliability.CanBuilderBuild(unit,id) then return false end
    s=s or Rules.CurrentSnapshot(army,false)
    if not s or Number(s.extractors)<2 then return false end
    local ground=GroundStrength(s)
    if LandEnabled(army) and ground<math.min(4,GroundFloor(s)) then return false end
    local a,e=Rules.Resources(army,unit)
    if not a or not e or a.income<=0 or e.income<=0 or e.ratio<0.20 then return false end
    local active=Number(s.development and s.development.mexUpgrades)
    if s.development and s.development.mexUnregistered then return false end
    if active>=math.max(1,math.min(2,math.floor(a.income/35))) then return false end
    local mass,energy,duration=Rules.ProjectRates(unit,id)
    if not mass or not duration or duration<=0 then return false end
    local massBank=math.max(0,a.current-a.storage*0.15)/duration
    local energyBank=math.max(0,e.current-e.storage*0.15)/duration
    if mass>a.income*0.40+massBank or energy>e.income*0.50+energyBank then return false end
    local powered=Balance(e)+energyBank>=energy
    if Balance(a)+massBank>=mass and powered then return true,id end
    -- Steady production must not consume every future extractor upgrade.
    -- Admit just one modest native project alongside a field-ready army;
    -- actual paid scaling remains with the host and accepted work is untouched.
    if active>0 or not powered or e.ratio<0.35 or army.economy.isEnergyDown
        or a.techOwner or a.commanderOwner or a.heavyOwner or Number(s.upgrades)>0
        or Number(s.development and s.development.factoryUpgrades)>0
        or Number(s.development and s.development.experimentalBuilding)>0
        or s.landPanic or s.airPanic or s.navalPanic
        or LandEnabled(army) and ground<GroundFloor(s) then return false end
    local demand=Number(a.request)+Number(a.reserved)
    return mass<=a.income*0.30+massBank and demand<=a.income*1.10
        and demand+mass<=a.income*1.40+massBank,id
end

function ExtractorShare(army,s,currentUpgradeCost)
    if not s or not s.alloy or not s.energy then return 0 end
    if LandEnabled(army) and GroundReady(s)<4 then return 0 end
    local a,e=s.alloy,s.energy
    if Number(a.income)<=0 or Number(e.income)<=0 then return 0 end
    local bank=math.max(0,Number(a.current)-Number(a.storage)*0.15)/60
    return math.min(0.40,math.max(0,(Balance(a)+bank+Number(currentUpgradeCost))/Number(a.income)))
end
