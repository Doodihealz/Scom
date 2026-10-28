-- Profile-owned development policy. Native selectors, prices, build permissions,
-- path finding and host enhancement validation remain authoritative.
-- Design references: M28AI's separate economic investment and construction-power
-- policies. This is an independent Sanctuary implementation, not an M28AI port.
Version = "9.0.25-rc30"
local Rules=Import("AI/mods/AI-Scom/RushBalance.lua")
local AF = Import("AI/AIFunctions.lua")
local MG = Import("AI/AIMarkerGenerator.lua")
local TM = Import("AI/AITargetManager.lua")
local Orders = Import("host/managers/orders/hostOrderManager.lua")
local Log = Import("AI/debugUtilities.lua").AILog
local Factions = {"EDA", "CHOSEN", "GUARD", "SERAPHIM"}
local Availability=Import("common/units/availableUnits.lua").AvailableUnits
local Reliability = Import("AI/mods/AI-Scom/RushReliability.lua")
local Tasks = Import("common/commonOrders.lua").OrderTasks
local Heavy = Import("AI/mods/AI-Scom/RushHeavyConstruction.lua")
local HeavyPolicy = Import("AI/mods/AI-Scom/RushHeavyPolicy.lua")
local EconomyPolicy=Import("AI/mods/AI-Scom/RushEconomyPolicy.lua")
local MassFabrication=Import("AI/mods/AI-Scom/RushMassFabrication.lua")
local Expansion=Import("AI/mods/AI-Scom/RushExpansion.lua")
local CommanderWork=Import("AI/mods/AI-Scom/RushCommanderWork.lua")
local Controller
function Configure(controller)
    Controller = controller
    MassFabrication.Configure(controller)
end
local Pressure=Import("AI/mods/AI-Scom/RushPressure.lua")
local Bombers=Import("AI/mods/AI-Scom/RushBomberHarassment.lua")
local function Now() return GetGameTimeSeconds() end
local function Finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function Has(tp, tag)
    if not tp then return false end
    if tp.hasTags and tp.hasTags[tag] then return true end
    for _, t in ipairs(tp.tags or {}) do if t == tag then return true end end
    return false
end
local function Tier(tp)
    for i = 4, 1, -1 do if Has(tp, "TECH" .. i) then return i end end
    return tp and tp.general and tp.general.techNumber or 1
end
local function State(army)
    army.ai.rushDevelopment = army.ai.rushDevelopment or {
        blacklisted = {}, shieldControl = {}, idle = {},
        projectRetry = {}, reservations = {}, lastStatus = -100,
    }
    return army.ai.rushDevelopment
end
local function Own(army, unit)
    return unit and not unit.dead and not unit.deleted and unit.army == army and unit.id
        and army.units[unit.id.index] == unit
end
local function Working(unit) return Reliability.Working(unit) end
local function BusyOrder(unit)
    return unit.orders and (unit.orders.activeOrder
        or (unit.orders.queuedOrders and next(unit.orders.queuedOrders)))
end
local function Distance2(a, b) return (a.x-b.x)^2 + (a.z-b.z)^2 end
local function Safe(army, pos, layer, maximum)
    if type(TM.GetThreatFromHeatMapPosition) ~= "function" then return false end
    local ok, threat = pcall(TM.GetThreatFromHeatMapPosition, army.id, pos, layer or "Land")
    return ok and type(threat) == "number" and threat <= (maximum or 0)
end
local function Template(id) return __Templates.Units[id] end
local function DevelopmentBase(unit)
    local bases=unit.army.ai.bases or {}
    local pos=unit:GetPosition()
    local assigned=unit.assignedToBase
    local base=assigned and bases[assigned]
    if base and base.position and type(base.radius)=="number"
        and Distance2(pos,base.position)<=base.radius*base.radius then return assigned end
    local selected,best
    for name,candidate in pairs(bases) do
        if candidate.position and type(candidate.radius)=="number" then
            local distance=Distance2(pos,candidate.position)
            if distance<=candidate.radius*candidate.radius and (not best or distance<best
                or distance==best and tostring(name)<tostring(selected)) then selected,best=name,distance end
        end
    end
    return selected
end
function InitSnapshot(snapshot)
    snapshot.development={factory={},engineer={},power={},mex={},experimental=0,
        experimentalBuilding=0,factoryUpgrades=0,mexUpgrades=0,mexUnregistered=false,totalFactories=0,
        constructors=0,military=0,naval=0,powerBuilding=0,landFactories=0,
        airFactories=0,navalFactories=0,
        stations=0,stationsPending=0,stationUpgrades=0,factoryBases={},stationBases={}}
end
function ObserveUnit(snapshot,u)
    local c=snapshot.development
    local tp, t, complete = u.tp, Tier(u.tp), u:IsCompleted()
    if Has(tp,"ENGINEER") and Has(tp,"MOBILE") and not HeavyPolicy.IsT4(tp) and not u.scoCommanderPodOwner and not u.scoSourcePodOwner and complete then
        c.engineer[t]=(c.engineer[t] or 0)+1; c.constructors=c.constructors+1
    end
    if Has(tp,"MOBILE") and (not Has(tp,"ENGINEER") or HeavyPolicy.IsCombatExperimental(tp)) and not Has(tp,"COMMAND")
        and not Has(tp,"SCOUT") and complete then c.military=c.military+1 end
    if complete and Has(tp,"NAVAL") and Has(tp,"MOBILE") and not Has(tp,"ENGINEER")
        and not Has(tp,"SCOUT") and not Has(tp,"TRANSPORT") then c.naval=c.naval+1 end
    if HeavyPolicy.IsExperimental(tp) then
        if complete then c.experimental=c.experimental+1
        else c.experimentalBuilding=c.experimentalBuilding+1 end
    end
    local domain=Rules.FactoryDomain(tp)
    if domain and complete then
        c.factory[domain..t]=(c.factory[domain..t] or 0)+1
        c[domain.."Factories"]=c[domain.."Factories"]+1
        c.totalFactories=c.totalFactories+1
        local base=DevelopmentBase(u)
        if base then c.factoryBases[base]=(c.factoryBases[base] or 0)+1 end
        local platoon=u.platoon;local data=platoon and platoon.ai
        local former=data and data.formerTable
        local assigned=former and not platoon.dead and not platoon.deleted and data.eState~="Disband"
            and former.AIPlan=="planUpgradeStructure"
        if Reliability.UpgradeTarget(u) or (u.ai and u.ai.rushUpgradeId) or assigned then
            c.factoryUpgrades=c.factoryUpgrades+1
        end
    end
    if Has(tp,"STRUCTURE") and Has(tp,"ENERGY_PRODUCTION") and not Has(tp,"ALLOYS_EXTRACTION") then
        if complete then c.power[t]=(c.power[t] or 0)+1
        else c.powerBuilding=c.powerBuilding+1 end
    end
    if Has(tp,"ALLOYS_EXTRACTION") then
        if complete then c.mex[t]=(c.mex[t] or 0)+1 end
        local target=Reliability.UpgradeTarget(u)
        local upgrading=target or u.ai and u.ai.rushUpgradeId
        local accepted=target~=nil and target~=false
        if type(u.GetUpgradeTpId)=="function" then
            local id=u:GetUpgradeTpId()
            if id then
                for _,item in ipairs(u.buildQueue or {}) do
                    if item.tpId==id then upgrading,accepted=true,true;break end
                end
            end
        end
        if upgrading then c.mexUpgrades=c.mexUpgrades+1 end
        if accepted then
            local mass,energy=Rules.RegisteredBuildRates(u)
            if mass<=0 and energy<=0 then c.mexUnregistered=true end
        end
    end
    if Has(tp,"STRUCTURE") and Has(tp,"SCFA_ENGINEERSTATION") then
        -- A native upgrade target is the existing station's replacement, not
        -- a second hive foundation competing for the next factory pair.
        if Own(u.army,u.upgrader) and Has(u.upgrader.tp,"SCFA_ENGINEERSTATION") then return end
        if complete then c.stations=c.stations+1 else c.stationsPending=c.stationsPending+1 end
        local base=DevelopmentBase(u)
        if base then c.stationBases[base]=(c.stationBases[base] or 0)+1 end
        local platoon=u.platoon;local data=platoon and platoon.ai
        local former=data and data.formerTable
        local assigned=former and not platoon.dead and not platoon.deleted and data.eState~="Disband"
            and former.AIPlan=="planUpgradeStructure"
        if Reliability.UpgradeTarget(u) or u.ai and u.ai.rushUpgradeId or assigned then
            c.stationUpgrades=c.stationUpgrades+1
        end
    end
end
local function Get(army)
    local snapshot=Controller.Snapshot(army)
    return State(army),snapshot.development,snapshot
end
local function EconomyUsable(snapshot)
    return snapshot.alloy and snapshot.energy and snapshot.alloy.income > 0 and snapshot.energy.income > 0
end
local function EnergyHealthy(e,credit)
    local balance=e and Rules.Balance(e)+(credit or 0)
    return e and e.ratio>=0.25 and (balance>=0 or e.current>=-balance*30)
end
local function HighestEngineer(c)
    for t=3,1,-1 do if (c.engineer[t] or 0)>0 then return t end end
    return 1
end
function SupportLandTech(army,snapshot)
    local c=snapshot.development
    return snapshot.landDisconnected==true and c and c.landFactories>=1
        and c.totalFactories>=2 and c.constructors>=2 or false
end
function LandT2UpgradeFieldReady(army,snapshot)
    if snapshot.rushBeachheadBase then
        return (snapshot.landFactories or 0)>=2 and EconomyPolicy.GroundTransitionReady(snapshot,2)
    end
    if SupportLandTech(army,snapshot) then return true end
    return EconomyPolicy.LandEnabled(army)
        and (snapshot.landFactories or 0)>=Rules.Config.TechLandFactories
        and EconomyPolicy.GroundTransitionReady(snapshot,2)
end
-- Product metadata is static during a match; the readiness check itself only
-- inspects the controller's cached snapshot and completed-factory list.
local airT3Catalogue={templates=nil,byFaction={}}
local function AirT3Products(faction)
    local units=__Templates and __Templates.Units
    if airT3Catalogue.templates~=units then
        airT3Catalogue={templates=units,byFaction={}}
    end
    if not faction then return {} end
    local cached=airT3Catalogue.byFaction[faction]
    if cached then return cached end
    local products={}
    for id,tp in pairs(units or {}) do
        local economy=tp.economy
        local cost=economy and economy.cost
        if Availability[id]==true and tp.general and tp.general.tpId==id
            and not Has(tp,"DEMO_UI_ONLY") and not Has(tp,"SCFA_CIVILIAN")
            and not Has(tp,"SCFA_UNSELECTABLE") and not Has(tp,"SCFA_INSIGNIFICANTUNIT")
            and Has(tp,faction) and Has(tp,"TECH3") and Has(tp,"AIR")
            and Has(tp,"MOBILE") and not Has(tp,"ENGINEER") and not Has(tp,"SCOUT") and not Has(tp,"TRANSPORT")
            and (Has(tp,"GUNSHIP") or Has(tp,"BOMBER") or Has(tp,"FIGHTER")
                or Has(tp,"ANTI_SURFACE") or Has(tp,"ANTI_AIR")
                or Has(tp,"ANTI_NAVAL") or Has(tp,"ANTI_NAVY") or Has(tp,"SCFA_ANTINAVY"))
            and cost and Finite(cost.alloys) and cost.alloys>=0
            and Finite(cost.energy) and cost.energy>=0
            and Finite(economy.buildTime) and economy.buildTime>0 then
            products[#products+1]={id=id,mass=cost.alloys/economy.buildTime,
                energy=cost.energy/economy.buildTime}
        end
    end
    airT3Catalogue.byFaction[faction]=products
    return products
end

-- This factory's current product finishes before an upgrade begins. Credit
-- only its live demand, never a queued product or another factory's budget.
local function ReleasedProduction(unit)
    local target=unit.unitBeingBuilt
    if unit.productionBehaviorIsActive and Own(unit.army,target) and not target:IsCompleted()
        and not Reliability.UpgradeTarget(unit)
        and not (type(unit.GetPause)=="function" and unit:GetPause()) then
        return Rules.RegisteredBuildRates(unit)
    end
    return 0,0
end

local function UpgradeResources(unit,snapshot)
    if snapshot and snapshot.time==Now() then return snapshot.alloy,snapshot.energy end
    return Rules.Resources(unit.army,unit)
end

local function OwnedProductionReserve(unit)
    local record=unit.ai and unit.ai.rushProductionQueue
    local reserve=unit.army.ai.ecoReserve and unit.army.ai.ecoReserve[unit.id.index]
    if not record or not reserve or reserve.rushProductionQueue~=record
        or record.reservation~=reserve or record.factory~=unit or record.unitAI~=unit.ai
        or record.army~=unit.army or record.armyAI~=unit.army.ai or record.platoon~=unit.platoon
        or not unit.platoon or unit.platoon.ai~=record.platoonAI or record.queue~=unit.buildQueue
        or type(record.queue)~="table" or type(record.entries)~="table" then return nil end
    local count=0
    for _,item in ipairs(record.queue) do
        if type(item.entryIds)~="table" or #item.entryIds<1 then return nil end
        for _,entry in ipairs(item.entryIds) do
            count=count+1
            if record.entries[entry]~=item.tpId or count>3 then return nil end
        end
    end
    return reserve
end
local function ReleasedFunding(unit,snapshot)
    local mass,energy=ReleasedProduction(unit)
    -- Live Resources(except) already excludes this serial reserve. A same-tick
    -- census needs only the exact sampled remainder, not the entire queue again.
    if snapshot and snapshot.time==Now() then
        local reserve=OwnedProductionReserve(unit)
        local funding=snapshot.factoryFunding and snapshot.factoryFunding[unit]
        mass=math.min(mass,funding and funding.mass or 0)
        energy=math.min(energy,funding and funding.energy or 0)
        if reserve and funding then
            mass=mass+math.max(0,math.min(reserve.resourcePerSecond or 0,funding.reservedMass or 0))
            energy=energy+math.max(0,math.min(reserve.energyPerSecond or 0,funding.reservedEnergy or 0))
        end
    end
    return mass,energy
end
local function LeaseOwned(army,lease)
    local unit=lease and lease.unit
    return lease and lease.armyAI==army.ai and Own(army,unit) and unit.ai==lease.unitAI
        and unit.tpId==lease.fromId and not unit.CaptureInProgress and not unit.ReclaimInProgress
        and not (type(unit.GetPause)=="function" and unit:GetPause())
        and Availability[lease.id]==true
        and type(unit.GetUpgradeTpId)=="function" and unit:GetUpgradeTpId()==lease.id
end
local function NativeUpgradeFunded(unit,id)
    local target=Reliability.UpgradeTarget(unit)
    if not target or target.tpId~=id or unit.unitBeingBuilt~=target then return false end
    local mass,energy=Rules.RegisteredBuildRates(unit)
    return mass>0 or energy>0
end
local AirT3Ready
local function UpgradeBudget(unit,id,snapshot,rollout)
    local mass,energy,duration=Controller.ProductionRates(unit,id)
    if not Finite(mass) or not Finite(energy) or not Finite(duration)
        or mass<0 or energy<0 or duration<=0 then return nil end
    local a,e=snapshot.alloy,snapshot.energy
    if not a or not e or a.income<=0 or e.income<=0 then return nil end
    -- One native upgrade may run supply-limited while the other lines fight.
    -- Stored resources finance only their actual share of this finite project.
    local minimum=rollout and 0.60 or 0.50
    local function supported(resource,rate,share)
        local remaining=rate-math.max(0,resource.current-resource.storage*0.15)/duration
        if remaining<=0 then return 1 end
        return math.min(1,resource.income*share/remaining)
    end
    local massScale=supported(a,mass,rollout and 0.35 or 0.45)
    if massScale<minimum then return nil end
    local energyScale=supported(e,energy,rollout and 0.45 or 0.55)
    local scale=math.min(massScale,math.max(minimum,energyScale))
    local productEnergy=0
    if Tier(Template(id))==3 and Has(unit.tp,"AIR_FACTORY") then
        local allowed,required=AirT3Ready(unit.army,snapshot,unit)
        if not allowed then return nil end
        productEnergy=required or 0
    end
    return {mass=mass*scale,energy=energy*scale,duration=duration,horizon=duration/scale,scale=scale,
        fundable=energyScale>=minimum and e.income>=productEnergy,
        powerEnergy=math.max(energy*scale,productEnergy)}
end
function CanFundFactoryUpgrade(unit,snapshot)
    if not Controller or not unit or not Own(unit.army,unit) or not unit:IsCompleted() or unit.isSlaveFactory
        or unit.CaptureInProgress or unit.ReclaimInProgress or AF.IsUnderAttack(unit)
        or type(unit.GetPause)=="function" and unit:GetPause()
        or not Has(unit.tp,"FACTORY") or type(unit.GetUpgradeTpId)~="function" then return false end
    local id=unit:GetUpgradeTpId()
    if not id or not Template(id) or NativeUpgradeFunded(unit,id) then return false end
    local lease=State(unit.army).factoryLease
    local selected=LeaseOwned(unit.army,lease) and lease.unit==unit and lease.id==id and lease.expires>Now()
    local former=unit.platoon and unit.platoon.ai and unit.platoon.ai.formerTable
    if former and former.RushTechProject and not selected then return false end
    if LeaseOwned(unit.army,lease) and lease.expires>Now() and not selected then return false end
    local mass,energy,duration=Controller.ProductionRates(unit,id)
    if not mass or not duration or duration<=0 then return false end
    if selected then mass,energy,duration=lease.mass,lease.energy,lease.horizon end
    local a,e=UpgradeResources(unit,snapshot)
    if not a or not e or a.income<=0 or e.income<=0 then return false end
    local releasedMass,releasedEnergy=ReleasedFunding(unit,snapshot)
    if selected and snapshot and snapshot.time==Now() then
        if a.techOwner==unit and a.techId==id then releasedMass=releasedMass+(a.techReserved or 0) end
        if e.techOwner==unit and e.techId==id then releasedEnergy=releasedEnergy+(e.techReserved or 0) end
    end
    local freeMass=Rules.Balance(a)+releasedMass
    local freeEnergy=Rules.Balance(e)+releasedEnergy
    return EnergyHealthy(e,releasedEnergy)
        and freeMass+math.max(0,a.current-a.storage*0.15)/duration>=mass
        and freeEnergy+math.max(0,e.current-e.storage*0.15)/duration>=energy
end

local function AirTechDefenseReady(army,snapshot,selected,tier)
    if not snapshot.airPanic and not snapshot.airRaid then return true end
    local screen=tier==2 and Rules.Config.OpeningFighters or Rules.Config.FighterMinimum
    if (snapshot.completeRoles.fighter or 0)<math.max(screen,snapshot.airRaidFighters or 0) then return false end
    local remaining=0
    for _,factory in ipairs(snapshot.factories or {}) do
        if factory~=selected and Own(army,factory) and Has(factory.tp,"AIR_FACTORY") and factory:IsCompleted()
            and not factory.CaptureInProgress and not factory.ReclaimInProgress
            and not Reliability.UpgradeTarget(factory) and not (factory.ai and factory.ai.rushUpgradeId)
            and not AF.IsUnderAttack(factory)
            and not (type(factory.GetPause)=="function" and factory:GetPause()) then remaining=remaining+1 end
    end
    return remaining>=(selected and 1 or 2)
end
AirT3Ready=function(army,snapshot,selectedFactory)
    local a,e=snapshot.alloy,snapshot.energy
    if not a or not e or (snapshot.completeRoles.fighter or 0)<Rules.Config.FighterMinimum
        or not AirTechDefenseReady(army,snapshot,selectedFactory) then return false end
    local requiredEnergy
    for _,factory in ipairs(snapshot.factories or {}) do
        if (not selectedFactory or factory==selectedFactory)
            and Own(army,factory) and Tier(factory.tp)==2 and Has(factory.tp,"AIR_FACTORY")
            and not factory.CaptureInProgress and not factory.ReclaimInProgress
            and not (type(factory.GetPause)=="function" and factory:GetPause())
            and not Reliability.UpgradeTarget(factory)
            and type(factory.GetUpgradeTpId)=="function" then
            local products=AirT3Products(factory.factionTag)
            local id=factory:GetUpgradeTpId()
            local target=id and Template(id)
            local construction=target and target.construction
            local power=construction and construction.buildPower
            local productsAllowed=construction and construction.canBuild
            if type(productsAllowed)=="string" and type(ParseTagsFromString)=="function" then
                local ok,menu=pcall(ParseTagsFromString,productsAllowed)
                productsAllowed=ok and menu or nil
            end
            if target and Has(target,"AIR_FACTORY") and Tier(target)==3
                and type(productsAllowed)=="table" and Finite(power) and power>0 then
                for _,product in ipairs(products) do
                    -- A real affordable aircraft must follow the unlock.
                    -- Forecast its power before that income exists, otherwise
                    -- the low-tech power goal can block its own replacement.
                    if productsAllowed[product.id] and a.income>=product.mass*power*0.60 then
                        local demand=product.energy*power*0.60
                        if not requiredEnergy or demand<requiredEnergy then requiredEnergy=demand end
                    end
                end
            end
        end
    end
    return requiredEnergy~=nil,requiredEnergy
end

function CanUpgradeAirToT3(army,snapshot)
    snapshot=snapshot or Controller.Snapshot(army)
    local ready,required=AirT3Ready(army,snapshot)
    -- Legacy admission needs the actual income; only the private planning
    -- path may use an unfunded product to forecast preparatory power.
    return ready and snapshot.energy.income>=required or false
end
local function AssignedUpgrade(unit)
    local platoon=unit and unit.platoon
    local data=platoon and platoon.ai
    local former=data and data.formerTable
    return former and not platoon.dead and not platoon.deleted and data.eState~="Disband"
        and former.AIPlan=="planUpgradeStructure"
end
local function OtherFactoryUpgrade(army,snapshot,selected)
    for _,unit in ipairs(snapshot.globalFactories or snapshot.factories or {}) do
        if unit~=selected and Own(army,unit) and (Reliability.UpgradeTarget(unit)
            or unit.ai and unit.ai.rushUpgradeId or AssignedUpgrade(unit)) then return true end
    end
    return false
end
local function OtherProductionReady(army,snapshot,domain,selected,minTier)
    local count=0
    for _,unit in ipairs(snapshot.factories or {}) do
        if unit~=selected and Own(army,unit) and unit:IsCompleted() and not unit.isSlaveFactory
            and Rules.FactoryDomain(unit.tp)==domain and (not minTier or Tier(unit.tp)>=minTier)
            and not unit.CaptureInProgress and not unit.ReclaimInProgress
            and not Reliability.UpgradeTarget(unit) and not (unit.ai and unit.ai.rushUpgradeId)
            and not AssignedUpgrade(unit) and not AF.IsUnderAttack(unit)
            and not (type(unit.GetPause)=="function" and unit:GetPause()) then count=count+1 end
    end
    local required=not minTier and domain=="land" and (snapshot.landPressure or snapshot.landPanic) and 2 or 1
    return count>=required+(selected and 0 or 1)
end
local function TechFieldReady(army,c,snapshot,tier,domain,factory)
    if not EconomyUsable(snapshot) or OtherFactoryUpgrade(army,snapshot,factory) or c.totalFactories<2 then return false end
    local layers=army.ai.settings.useLayer
    local shore=domain=="land" and snapshot.rushBeachheadBase~=nil
    local support=domain=="land" and not shore and SupportLandTech(army,snapshot)
    if layers and layers[domain=="naval" and "water" or domain]~=true and not support and not shore then return false end
    if domain=="land" and tier==2 then
        if not LandT2UpgradeFieldReady(army,snapshot) then return false end
    elseif domain~="naval" and (shore or EconomyPolicy.LandEnabled(army))
        and not EconomyPolicy.GroundTransitionReady(snapshot,domain=="land" and tier or 2) then return false end
    -- Every combat transition leaves a working production line behind; a
    -- pressured front keeps two. Disconnected support tech retains its route
    -- to advanced engineers when only one land factory is useful.
    if domain=="land" and not support then
        if not OtherProductionReady(army,snapshot,domain,factory) then return false end
        -- The first T3 upgrade must leave an advanced combat line producing;
        -- surviving T2 troops alone cannot replace that production during it.
        if tier==3 and not OtherProductionReady(army,snapshot,domain,factory,2) then return false end
    end
    -- Let the first advanced factory deliver the engineer that turns its
    -- unlock into economy and power before taking that same line offline again.
    if tier==3 and (c.engineer[2] or 0)+(c.engineer[3] or 0)<1 then return false end
    if domain=="air" and (not AirTechDefenseReady(army,snapshot,factory,tier)
        or c.airFactories<2 and (snapshot.completeRoles.fighter or 0)
            <(tier==2 and Rules.Config.OpeningFighters or Rules.Config.FighterMinimum)) then return false end
    if domain=="naval" then
        if c.naval<2 then return false end
        if snapshot.navalPanic and not OtherProductionReady(army,snapshot,domain,factory) then return false end
    end
    if domain=="air" and tier==3 and not AirT3Ready(army,snapshot,factory) then return false end
    return (c.factory[domain..(tier-1)] or 0)>0
        and snapshot.alloy.income>=(tier==2 and 7 or 16)
end
local function NeedTechAt(army,c,snapshot,tier,domain,factory)
    local higher=(c.factory[domain..tier] or 0)+(tier==2 and (c.factory[domain..3] or 0) or 0)
    return higher==0 and TechFieldReady(army,c,snapshot,tier,domain,factory)
end
local function RolloutShare(c,tier,domain)
    local advanced=(c.factory[domain..tier] or 0)+(tier==2 and (c.factory[domain..3] or 0) or 0)
    local share=domain=="land" and (tier==3 and 0.50 or 0.60) or 0.80
    local minimum=domain=="land" and 1 or 2
    local goal=math.min(c[domain.."Factories"],math.max(minimum,math.ceil(c[domain.."Factories"]*share)))
    return advanced,goal
end
local function NeedRolloutAt(army,c,snapshot,tier,domain,factory)
    if domain=="land" then
        if not (snapshot.rushBeachheadBase or EconomyPolicy.LandEnabled(army))
            or not EconomyPolicy.GroundReplacementReady(snapshot,tier) then return false end
        if (snapshot.landPressure or snapshot.landPanic) and EconomyPolicy.NeedsGroundRecovery(army,snapshot) then return false end
    end
    local advanced,goal=RolloutShare(c,tier,domain)
    return advanced>=1 and advanced<goal
        and TechFieldReady(army,c,snapshot,tier,domain,factory)
end

-- Forward combat and disconnected home support share one upgrade lease,
-- but their technology gaps and usable units belong to their own locations.
local function ScopedFactoryNeed(check,army,c,snapshot,tier,domain,factory)
    if domain~="land" or not Controller.SnapshotForFactory then
        return check(army,c,snapshot,tier,domain,factory)
    end
    if factory then
        local view=Controller.SnapshotForFactory(army,snapshot,factory)
        return check(army,view and view.development or c,view or snapshot,tier,domain,factory)
    end
    if check(army,c,snapshot,tier,domain) then return true end
    for _,unit in ipairs(snapshot.factories or {}) do
        if Rules.FactoryDomain(unit.tp)=="land" and Tier(unit.tp)==tier-1 then
            local view=Controller.SnapshotForFactory(army,snapshot,unit)
            if view and check(army,view.development,view,tier,domain,unit) then return true end
        end
    end
    return false
end
local function NeedTech(army,c,snapshot,tier,domain,factory)
    return ScopedFactoryNeed(NeedTechAt,army,c,snapshot,tier,domain,factory)
end
local function NeedRollout(army,c,snapshot,tier,domain,factory)
    return ScopedFactoryNeed(NeedRolloutAt,army,c,snapshot,tier,domain,factory)
end

-- Funded technology precedes optional capacity. First power and immediate
-- base defense still lead; rollout follows the remaining useful tier deficit.
function FactoryUpgradePriority(snapshot,domain,tier,rollout)
    if not rollout then
        if domain=="land" then return tier==3 and 9680 or 9660 end
        if domain=="air" then return tier==3 and 9630 or 9620 end
        return tier==3 and 9615 or 9610
    end
    local priority=domain=="land" and 9540 or domain=="air" and 9530 or 9520
    local c=snapshot and snapshot.development
    if not c then return priority end
    local advanced,goal=RolloutShare(c,tier,domain)
    local deficit=math.max(0,goal-advanced)/math.max(1,goal)
    return priority+math.floor(deficit*40)+(tier==3 and 4 or 0)
end

-- Parallel capacity uses spare builders and real committed resources. Native
-- selection still prices the chosen factory with its actual builders.
function CapacityLimit(snapshot,domain)
    local a,e=snapshot.alloy,snapshot.energy
    if not a or not e or (snapshot[domain.."Factories"] or 0)<2 then return 1 end
    local mass=Rules.Balance(a)+math.max(0,a.current-a.storage*0.30)/30
    local energy=Rules.Balance(e)+math.max(0,e.current-e.storage*0.30)/30
    return math.max(1,math.min(3,1+math.floor(math.max(0,(snapshot.engineersIdle or 0)-1)/2),
        1+math.floor(math.max(0,mass)/12),1+math.floor(math.max(0,energy)/150)))
end

function Check(armyIndex, baseName, kind, tier, domain)
    local army=Armies[armyIndex]
    if not Controller or not army or not Controller.IsRushArmy(army) then return false end
    local state,c,snapshot=Get(army)
    if not EconomyUsable(snapshot) then return false end
    local a,e=snapshot.alloy,snapshot.energy
    local shore=domain=="land" and Controller.SnapshotForBase and Controller.SnapshotForBase(army,snapshot,baseName)
    local support=kind=="capacity" and domain=="land" and not shore
        and Controller.SnapshotForSupport and Controller.SnapshotForSupport(snapshot)
    local rebuildSupport=support and (support.landFactories or 0)+(support.factoryPending.land or 0)==0
    if domain and army.ai.settings.useLayer
        and army.ai.settings.useLayer[domain=="naval" and "water" or domain]~=true
        and not shore and not rebuildSupport and not (kind=="tech" and domain=="land" and SupportLandTech(army,snapshot)) then return false end
    if kind=="tech" then return CanStartFactoryTech(army,snapshot,domain,tier,false) end
    if kind=="rollout" then
        return CanStartFactoryTech(army,snapshot,domain,tier,true)
    elseif kind=="power" then
        local techPower,techHeadroom=NeedsTechPower(army,snapshot)
        local first=tier==Rules.FirstPowerTier(snapshot)
        if first then return (snapshot.powerPending and snapshot.powerPending[tier] or 0)==0
            and (EconomyPolicy.NeedsPower(snapshot) or techPower) end
        if not EconomyPolicy.NeedsPower(snapshot) and not techPower then return false end
        -- A bounded T1 bridge remains available during the first advanced plant.
        local bridge=tier==1 and ((c.power[2] or 0)+(c.power[3] or 0)==0)
            and ((snapshot.tiers["engineer:2"] or 0)+(snapshot.tiers["engineer:3"] or 0)>0)
            and Rules.Balance(e)<0
        if not bridge and tier~=HighestEngineer(c) then return false end
        if (snapshot.powerPending and snapshot.powerPending[tier] or 0)>= (bridge and 1 or math.min(3,1+math.floor(c.constructors/4))) then return false end
        -- Keep the same forecast through the dispatch gate: a smaller local
        -- margin must not discard the anticipated cost of spending stored Alloy.
        local headroom=math.max(40, e.income*0.25, c.totalFactories*18,
            EconomyPolicy.PowerHeadroom(snapshot),techHeadroom)
        -- Provision the first paid bomber line before it consumes its buffer.
        -- This is real generator demand, not a production pause or resource grant.
        if (snapshot.airFactories or 0)+(snapshot.airFactoriesBuilding or 0)>0
            and (snapshot.roles.bomber or 0)<2 and c.totalFactories>=1 then
            headroom=math.max(headroom,90)
        end
        if tier>=2 and (c.power[tier] or 0)<1 then headroom=math.max(headroom,e.income*0.40) end
        local bank=(c.power[tier] or 0)<(tier==1 and Pressure.GeneratorGoal(c.totalFactories) or math.max(2,math.ceil(c.totalFactories/4)))
        -- Bank targets do not commandeer the Alloy budget when power is already ample.
        local bankBudget=bank and a.ratio>=0.55 and a.balance>=math.max(2,a.income*0.10)
            and e.balance<math.max(headroom,e.income*0.50)
        return bankBudget or e.ratio<0.65 or e.balance-e.reserved<headroom
    elseif kind=="mex" then
        if c.mexUpgrades>=math.max(1,math.min(3,math.floor(a.income/25))) or not EnergyHealthy(e) then return false end
        if (c.mex[tier-1] or 0)==0 then return false end
        local main=army.ai.bases[baseName]
        if not main then return false end
        -- Upgrade one extractor at a time while retaining a production budget.
        return a.income>=(tier==2 and 7 or 18)
            and e.income>=(tier==2 and 120 or 450)
            and (a.current>=(tier==2 and 65 or 120) or a.balance>=3)
    elseif kind=="capacity" then
        if shore then snapshot,c=shore,shore.development end
        if rebuildSupport then snapshot,c=support,support.development end
        if domain=="land" and snapshot.landDisconnected and not rebuildSupport then return false end
        if not EconomyPolicy.CanAddCapacity(army,snapshot,domain) or not EnergyHealthy(e) then return false end
        local pending=snapshot.factoryPending and snapshot.factoryPending[domain] or 0
        if pending>=CapacityLimit(snapshot,domain) then return false end
        local current=c[domain.."Factories"]
        if current>0 and (snapshot.idleFactoriesByDomain and snapshot.idleFactoriesByDomain[domain] or 0)>0 then return false end
        if domain=="naval" then
            local navalState=army.ai.rushNavalConstruction and army.ai.rushNavalConstruction[baseName]
            if navalState and Now()<(navalState.retryAt or 0) then return false end
            if current==0 then
                return c.totalFactories>=1 and c.constructors>=2
                    and a.income>=5 and e.income>=60 and a.ratio>=0.15
                    and (Rules.Balance(a)>=0 or a.current>=100)
            end
            if c.naval<math.min(4,current*2) and not snapshot.navalPanic then return false end
        elseif domain=="air" and not snapshot.landDisconnected
            and c.landFactories<3 and not snapshot.airPanic then return false end
        if domain=="land" and current<2 then return true end
        -- Once existing lines are occupied, let actual surplus and stored
        -- resources fund expansion instead of a fixed shipyard/airfield ceiling.
        local mass=Rules.Balance(a)+math.max(0,a.current-a.storage*0.30)/45
        local energy=Rules.Balance(e)+math.max(0,e.current-e.storage*0.30)/45
        return mass>=math.max(2,a.income*0.08) and energy>=math.max(20,e.income*0.05)
    elseif kind=="experimental" then
        if snapshot.landDisconnected then return false end
        if (c.engineer[3] or 0)<1 or c.experimentalBuilding>0 or not EconomyPolicy.CanStartTech(army,snapshot) then return false end
        local wanted=math.max(1,math.min(6,math.floor(a.income/45)))
        return c.experimental<wanted and EnergyHealthy(e) and a.income>=30 and e.income>=900
            and (a.current>=100 or a.balance>=5) and not (snapshot.landPanic and c.military<12)
    elseif kind=="station" or kind=="stationUpgrade" then
        if army.faction~=1 and army.faction~=3 then return false end
        if HighestEngineer(c)<2 or not EnergyHealthy(e) or a.income<16 or e.income<300 then return false end
        if kind=="stationUpgrade" then
            return c.stations>0 and c.stationUpgrades==0 and c.factoryUpgrades==0 and a.income>=30
                and a.current>=100 and e.ratio>=0.6
        end
        local wanted=army.faction==3 and math.floor(c.totalFactories/2)
            or math.min(4,math.max(1,math.floor(c.totalFactories/4)))
        if c.stationsPending>0 or c.stations>=wanted or a.current<100 or c.totalFactories<2 then return false end
        if army.faction==3 then
            local factories=c.factoryBases[baseName] or 0
            -- Global floor enforces one per pair; the local ceiling lets a
            -- useful base receive the next hive when factory counts are odd.
            return factories>0 and (c.stationBases[baseName] or 0)<math.ceil(factories/2)
        end
        return true
    elseif kind=="assist" then
        -- Assisting is productive only while the economy can supply the extra build power.
        return e.ratio>=0.20 and (a.current>=80 or a.balance>=3)
    elseif kind=="reclaim" then
        return c.constructors>=3 and a.ratio<0.80
            and type(AF.HasReclaimablePropsOnMap)=="function" and AF.HasReclaimablePropsOnMap()
    end
    return false
end

function AddFormers(army, formers)
    formers=MassFabrication.AddFormers(army,formers)
    -- RushDevelopment marks strategy-independent combat formers too. Testing
    -- that broad flag suppressed this entire catalogue after RC11 added raids.
    for _,f in pairs(formers) do if f.RushDevelopmentCatalogue then return formers end end
    local function append(name,plan,priority,extra,check)
        local f={FormerName=name, AIPlan=plan, Priority=priority, FormNumInstances=1,
            AIdifficulty={easy=true,medium=true,hard=true},
            RunOnBaseType={MAIN=true,EXPANSION=false,OUTPOST=false,NAVAL=false},
            RunWithStrategyName={}, RushDevelopment=true, RushDevelopmentCatalogue=true, DebugPlatoon=false,
            FormerConditions={{Check,check}}, AllowEcoStorageDrain=true}
        for k,v in pairs(extra or {}) do f[k]=v end
        for i,line in ipairs(f.WantStructures or {}) do
            f.WantStructures[i]=line*Tags[Factions[army.faction]]
        end
        formers[#formers+1]=f
        return f
    end
    for _,domain in ipairs({"land","air","naval"}) do
        local tag=domain=="land" and Tags.LAND_FACTORY or domain=="air" and Tags.AIR_FACTORY or Tags.NAVAL_FACTORY
        local upgradeBases={MAIN=true,EXPANSION=true,OUTPOST=true,NAVAL=true}
        for tier=2,3 do
            local techPriority=FactoryUpgradePriority(nil,domain,tier,false)
            append("R8 "..domain.." tech "..tier,"planUpgradeStructure",techPriority,
                {NeedUpgradeableUnit={{tag*Tags["TECH"..(tier-1)],1,1,0}},
                    InvestmentType="FactoryDevelopment",RushTechProject=true,RushUpgradeDomain=domain,RushUpgradeTier=tier,
                    RunOnBaseType=upgradeBases}, {"tech",tier,domain})
            append("R8 "..domain.." upgrade rollout "..tier,"planUpgradeStructure",FactoryUpgradePriority(nil,domain,tier,true),
                {NeedUpgradeableUnit={{tag*Tags["TECH"..(tier-1)],1,1,0}},
                    InvestmentType="FactoryDevelopment",RushTechProject=true,RushUpgradeDomain=domain,
                    RushUpgradeTier=tier,RushUpgradeRollout=true,
                    RunOnBaseType=upgradeBases}, {"rollout",tier,domain})
        end
        if domain~="naval" then
            append("R8 "..domain.." production capacity","planBuildWithEngineer",domain=="land" and 9150 or 7600,
                {NeedMobileBuilder={{Tags.ENGINEER*Tags.MOBILE,1,1,0}},
                    WantStructures={tag*Tags.TECH1},WantStructuresSpacing=2,FormNumInstances=3,RushCapacityDomain=domain,
                    RunOnBaseType={MAIN=true,EXPANSION=true,OUTPOST=domain=="land",NAVAL=false}}, {"capacity",1,domain})
        end
    end
    for tier=1,3 do
        local powerFormer=append("R8 proactive T"..tier.." power","planBuildWithEngineer",9200,
            {NeedMobileBuilder={{Tags.ENGINEER*Tags.MOBILE*Tags["TECH"..tier],1,1,0}},
                WantStructures={Tags.ENERGY_PRODUCTION*Tags.STRUCTURE*Tags["TECH"..tier]},
                WantStructuresSpacing=1, MaximumAlloyIncomeRatio=0.30,FormNumInstances=1,
                RunOnBaseType={MAIN=true,EXPANSION=true,OUTPOST=true,NAVAL=false},
                InvestmentType="RushPower"..tier}, {"power",tier})
        -- The opening former owns the first generator. A parallel request can
        -- consume its only engineer and pending-generator slot.
        if tier==1 then
            powerFormer.FormerConditions[#powerFormer.FormerConditions+1]=
                {"BlockIfStrategyActive",{"OpeningEconomyFocus"}}
        end
    end
    for tier=2,3 do
        append("R8 extractor development "..tier,"planUpgradeStructure",8650,
            {NeedUpgradeableUnit={{Tags.ALLOYS_EXTRACTION*Tags["TECH"..(tier-1)],1,1,0}},
                InvestmentType="ExtractorDevelopment"}, {"mex",tier})
    end
    append("R8 first and sustained experimental","planBuildWithEngineer",9300,
        {NeedMobileBuilder={{Tags.ENGINEER*Tags.MOBILE*Tags.TECH3,1,4,0}},
            InvestmentType="ExperimentalDevelopment",LoadedTech4Domain="LAND",
            BuildBehindBase=20,WantStructuresSpacing=4,MaximumAlloyIncomeRatio=0.30}, {"experimental"})
    append("R9 engineering stations","planBuildWithEngineer",7750,
        {NeedMobileBuilder={{Tags.ENGINEER*Tags.MOBILE*(Tags.TECH2+Tags.TECH3),1,1,0}},
            WantStructures={Tags.SCFA_ENGINEERSTATION*Tags.STRUCTURE*Tags.TECH2},
            AdjacentToStructure={Tags.FACTORY*Tags.STRUCTURE},
            InvestmentType="EngineeringStationConstruction",
            RunOnBaseType={MAIN=true,EXPANSION=army.faction==3,OUTPOST=army.faction==3,NAVAL=army.faction==3},
            WantStructuresSpacing=2}, {"station"})
    append("R9 engineering station development","planUpgradeStructure",7850,
        {NeedUpgradeableUnit={{Tags.SCFA_ENGINEERSTATION*(Tags.TECH2+Tags.TECH3),1,1,0}},
            InvestmentType="EngineeringStationDevelopment",
            RunOnBaseType={MAIN=true,EXPANSION=army.faction==3,OUTPOST=army.faction==3,NAVAL=army.faction==3}}, {"stationUpgrade"})
    append("R8 economic construction assistance","planAssistBuilding",1450,
        {NeedMobileBuilder={{Tags.ENGINEER*Tags.MOBILE*(Tags.TECH1+Tags.TECH2),1,2,0}},
            AssistBuildUnits={Tags.TECH4*Tags.MOBILE,Tags.ENERGY_PRODUCTION*Tags.STRUCTURE,
                Tags.FACTORY*Tags.STRUCTURE,Tags.STRUCTURE}, FormNumInstances=4,
            AllowEcoStorageDrain=false}, {"assist"})
    append("R8 upgrade assistance","planAssistBuilding",1550,
        {NeedMobileBuilder={{Tags.ENGINEER*Tags.MOBILE*Tags.TECH1,1,1,0}},
            AssistUpgradeUnits={Tags.ALLOYS_EXTRACTION},FormNumInstances=1,
            AllowEcoStorageDrain=false}, {"assist"})
    append("R8 battlefield salvage","planReclaimMap",1500,
        {NeedMobileBuilder={{Tags.ENGINEER*Tags.MOBILE*Tags.TECH1,1,2,1}},
            FormNumInstances=3}, {"reclaim"})
    return formers
end

-- Select one next-cycle technology investment before routine spending consumes
-- every surplus. The native paid head still finishes before its factory yields.
local function CanLeaseFactory(army,u,tier,domain,retaining)
    if not Own(army,u) or not u:IsCompleted() or u.isSlaveFactory or Tier(u.tp)~=tier-1
        or not Has(u.tp,domain=="land" and "LAND_FACTORY" or domain=="air" and "AIR_FACTORY" or "NAVAL_FACTORY")
        or u.CaptureInProgress or u.ReclaimInProgress
        or Reliability.UpgradeTarget(u) or (u.ai and u.ai.rushUpgradeId)
        or type(u.GetPause)=="function" and u:GetPause()
        or Now()<(u.ai and u.ai.rushUpgradeRetry or 0)
        or type(u.GetUpgradeTpId)~="function" then return false end
    -- Only our owned serial production can promise its future cycle. An
    -- unrelated native queue remains under its existing command owner.
    if u.buildQueue and next(u.buildQueue) and not OwnedProductionReserve(u) then return false end
    local former=u.platoon and u.platoon.ai and u.platoon.ai.formerTable
    if u.platoon and not (former and (former.RushControlled
        or retaining and former.RushTechProject and former.RushUpgradeDomain==domain
            and former.RushUpgradeTier==tier)) then return false end
    local id=u:GetUpgradeTpId()
    local target=id and Template(id)
    if not target or Tier(target)~=tier or Rules.FactoryDomain(target)~=domain or not Reliability.CanBuilderBuild(u,id)
        or AF.IsUnderAttack(u) then return false end
    local pos=u:GetPosition()
    for _,base in pairs(army.ai.bases or {}) do
        if base.position and type(base.radius)=="number"
            and Distance2(pos,base.position)<=base.radius*base.radius then return id end
    end
    return false
end
local function SubmittedUpgrade(lease)
    local unit=lease.unit
    if Reliability.UpgradeTarget(unit) then return true end
    if unit.ai.rushUpgradeId==lease.id then
        for _,item in ipairs(unit.buildQueue or {}) do if item.tpId==lease.id then return true end end
    end
    return false
end
local function PublishTechPower(army,snapshot,record)
    local energy=0
    if record and LeaseOwned(army,record) and record.expires>Now() then
        local _,released=ReleasedProduction(record.unit)
        local reserve=OwnedProductionReserve(record.unit)
        if reserve then released=math.max(released,reserve.energyPerSecond or 0) end
        energy=math.max(0,(record.powerEnergy or record.energy)-released)
    end
    local e=snapshot.energy
    local headroom=energy>0 and energy+EconomyPolicy.PowerHeadroom(snapshot) or 0
    snapshot.techPowerHeadroom=headroom
    snapshot.techPowerNeeded=e and energy>0 and Rules.Balance(e)+(e.techReserved or 0)<headroom or false
end
function TechCommitment(army,snapshot)
    if not Controller or not army or not army.ai then return nil end
    snapshot=snapshot or Controller.Snapshot(army)
    local state,c=State(army),snapshot.development
    local function finish(lease,forecast)
        state.factoryLease,state.factoryForecast=lease,forecast
        PublishTechPower(army,snapshot,lease or forecast)
        return lease
    end
    if not c or not EconomyUsable(snapshot) then return finish(nil,nil) end
    local now=Now()
    local lease=state.factoryLease
    local retained
    if lease and LeaseOwned(army,lease) then
        if NativeUpgradeFunded(lease.unit,lease.id) then
            lease.registeredAt=lease.registeredAt or now
            -- Native requests settle on the economy tick. A cached census
            -- taken before registration still needs the planned handoff budget.
            if now>lease.registeredAt and snapshot.time>lease.registeredAt then return finish(nil,nil) end
            lease.expires=now+30;lease.ready=false
            return finish(lease,nil)
        elseif SubmittedUpgrade(lease) then
            lease.expires=now+30;lease.ready=false
            return finish(lease,nil)
        end
        local eligible=lease.rollout and NeedRollout or NeedTech
        local id=CanLeaseFactory(army,lease.unit,lease.tier,lease.domain,true)
        local budget=id and id==lease.id and UpgradeBudget(lease.unit,id,snapshot,lease.rollout)
        if budget and budget.fundable and eligible(army,c,snapshot,lease.tier,lease.domain,lease.unit) then
            lease.mass,lease.energy,lease.powerEnergy=budget.mass,budget.energy,budget.powerEnergy
            lease.duration,lease.horizon,lease.scale=budget.duration,budget.horizon,budget.scale
            local massStored,energyStored=snapshot.alloy.current,snapshot.energy.current
            local saving=massStored>(lease.massStored or 0)+1 or energyStored>(lease.energyStored or 0)+1
            if Working(lease.unit) or BusyOrder(lease.unit) or saving then lease.expires=now+30 end
            if saving then
                lease.massStored=math.max(lease.massStored or 0,massStored)
                lease.energyStored=math.max(lease.energyStored or 0,energyStored)
            end
            lease.ready=CanFundFactoryUpgrade(lease.unit,snapshot)
            if lease.expires>now then
                retained=lease
                if AssignedUpgrade(lease.unit) then return finish(lease,nil) end
            else lease.unit.ai.rushUpgradeRetry=now+20 end
        end
    end
    state.factoryLease=retained
    if state.factoryLeaseScan==snapshot and state.factoryLeaseScanTime==now then
        return finish(retained,not retained and state.factoryForecast or nil)
    end
    state.factoryLeaseScan,state.factoryLeaseScanTime=snapshot,now
    local projects={}
    for phase=1,2 do
        for tier=3,2,-1 do
            for order,domain in ipairs({"land","air","naval"}) do
                projects[#projects+1]={tier=tier,domain=domain,order=order,rollout=phase==2,
                    priority=FactoryUpgradePriority(snapshot,domain,tier,phase==2)}
            end
        end
    end
    table.sort(projects,function(a,b)
        if a.priority~=b.priority then return a.priority>b.priority end
        if a.tier~=b.tier then return a.tier>b.tier end
        return a.order<b.order
    end)
    local forecast
    for _,project in ipairs(projects) do
        local tier,domain=project.tier,project.domain
        -- Prepare a missing tier before repeating lateral upgrades. Other
        -- affordable first-tech domains can still make useful progress above.
        if project.rollout and forecast and not forecast.rollout then return finish(nil,forecast) end
        if retained and retained.domain==domain and retained.tier==tier and retained.rollout==project.rollout then
            return finish(retained,nil)
        end
        local eligible=project.rollout and NeedRollout or NeedTech
        if eligible(army,c,snapshot,tier,domain) then
            local selected,selectedBusy,prospective,prospectiveBusy
            for _,u in ipairs(snapshot.factories or {}) do
                local id=CanLeaseFactory(army,u,tier,domain)
                local budget=id and UpgradeBudget(u,id,snapshot,project.rollout)
                if budget and eligible(army,c,snapshot,tier,domain,u) then
                    local busy=Working(u) and 1 or 0
                    local previous,previousBusy=prospective,prospectiveBusy
                    if budget.fundable then previous,previousBusy=selected,selectedBusy end
                    if not previous or busy<previousBusy or busy==previousBusy and u.id.index<previous.unit.id.index then
                        u.ai=u.ai or {}
                        budget.unit,budget.id,budget.fromId,budget.unitAI=u,id,u.tpId,u.ai
                        budget.armyAI,budget.domain,budget.tier=army.ai,domain,tier
                        budget.rollout,budget.expires=project.rollout,now+30
                        budget.massStored,budget.energyStored=snapshot.alloy.current,snapshot.energy.current
                        if budget.fundable then selected,selectedBusy=budget,busy
                        else prospective,prospectiveBusy=budget,busy end
                    end
                end
            end
            if selected then
                state.factoryLease=selected
                selected.ready=CanFundFactoryUpgrade(selected.unit,snapshot)
                return finish(selected,nil)
            end
            -- At most one exact native project can ask for preparatory power.
            -- It holds no factory or resource reservation until actually funded.
            forecast=forecast or prospective
        end
    end
    return finish(nil,forecast)
end
function FactoryReserved(army,factory)
    local lease=TechCommitment(army)
    return lease and lease.unit==factory or false
end
function CanStartFactoryTech(army,snapshot,domain,tier,rollout)
    local lease=TechCommitment(army,snapshot)
    return lease and lease.ready and (not domain or lease.domain==domain)
        and (not tier or lease.tier==tier) and (rollout==nil or lease.rollout==rollout) or false
end
function IsCommittedFactory(army,unit,former,snapshot)
    local lease=TechCommitment(army,snapshot)
    return lease and lease.unit==unit and lease.ready
        and (not former or (not former.RushUpgradeDomain or former.RushUpgradeDomain==lease.domain)
            and (not former.RushUpgradeTier or former.RushUpgradeTier==lease.tier)
            and (former.RushUpgradeRollout==true)==lease.rollout) or false
end
-- Pure callback for the shared budget ledger: never constructs a snapshot or
-- calls Resources. The selected owner's own budget is excluded on request.
function PendingInvestmentReserve(army,except)
    local lease=army.ai and army.ai.rushDevelopment and army.ai.rushDevelopment.factoryLease
    if not LeaseOwned(army,lease) or lease.expires<=Now() then return 0,0 end
    if lease.unit==except then return 0,0,lease.unit,lease.id end
    if NativeUpgradeFunded(lease.unit,lease.id) then
        return lease.mass,lease.energy,lease.unit,lease.id
    end
    local mass,energy=ReleasedProduction(lease.unit)
    local reserve=OwnedProductionReserve(lease.unit)
    if reserve then
        mass=math.max(mass,reserve.resourcePerSecond or 0)
        energy=math.max(energy,reserve.energyPerSecond or 0)
    end
    return math.max(0,lease.mass-mass),math.max(0,lease.energy-energy),lease.unit,lease.id
end
function InvestmentReserve(army,snapshot)
    TechCommitment(army,snapshot)
    return PendingInvestmentReserve(army)
end
function NeedsTechPower(army,snapshot)
    snapshot=snapshot or Controller.Snapshot(army)
    TechCommitment(army,snapshot)
    return snapshot.techPowerNeeded==true,snapshot.techPowerHeadroom or 0
end

-- The Alloys category contains metadata (including resource=true); positions
-- are records in Alloys.transforms, as consumed by Sanctuary's map loader.
-- Do not interpret category flags as marker records or change the source data.
local function AlloyMarkerPositions()
    local map=GameInfo and GameInfo.MapData
    local category=map and map.markers and map.markers.Alloys
    local transforms=type(category)=="table" and category.transforms
    local positions={}
    if type(transforms)~="table" then return positions end
    for _,marker in pairs(transforms) do
        local p=type(marker)=="table" and marker.position
        if type(p)=="table" and type(p.x)=="number" and type(p.z)=="number"
            and p.x==p.x and p.z==p.z and math.abs(p.x)<math.huge and math.abs(p.z)<math.huge then
            positions[#positions+1]=p
        end
    end
    table.sort(positions,function(a,b) return a.x==b.x and a.z<b.z or a.x<b.x end)
    return positions
end

local function RepairBlacklist(army,state)
    if Now()<(state.nextBlacklist or 0) then return end
    state.nextBlacklist=Now()+15
    local blacklist=army.ai.alloyFieldBlacklist
    if type(blacklist)~="table" or type(AF.CanBuildStructureAt)~="function" then return end
    if next(blacklist)==nil then state.blacklisted={};return end
    local byKey={}
    for _,p in ipairs(AlloyMarkerPositions()) do
        local key=math.floor(p.x).."-"..math.floor(p.z)
        byKey[key]=byKey[key] or {}
        byKey[key][#byKey[key]+1]=p
    end
    for _,field in pairs(army.ai.alloyFields or {}) do
        if type(field)=="table" and field.key then
            local spots={}
            for _,spot in pairs(field) do
                if type(spot)=="table" and type(spot.position)=="table" then spots[#spots+1]=spot.position end
            end
            if #spots>0 then byKey[field.key]=spots end
        end
    end
    local extractor
    for id,tp in pairs(__Templates.Units) do
        if Has(tp,Factions[army.faction]) and Has(tp,"ALLOYS_EXTRACTION") and Has(tp,"TECH1") then
            if not extractor or id<extractor then extractor=id end
        end
    end
    if not extractor then return end
    for key,value in pairs(blacklist) do
        state.blacklisted[key]=state.blacklisted[key] or Now()
        if byKey[key] and Now()-state.blacklisted[key]>=60 then
            for _,p in ipairs(byKey[key]) do
                if Reliability.Inside(p) and Safe(army,p,"Land",0) and Safe(army,p,"Air",0) then
                    local ok,free=pcall(AF.CanBuildStructureAt,army.id,extractor,p,0)
                    if ok and free then
                        blacklist[key]=nil;state.blacklisted[key]=nil;army.ai.lastAlloyUpdate=nil
                        break
                    end
                end
            end
        end
    end
    for key in pairs(state.blacklisted) do if blacklist[key]==nil then state.blacklisted[key]=nil end end
end

local function ShieldBudget(army,state,e)
    if not e then return 0 end
    local free,resumed=Rules.Balance(e),0
    local units={}
    for _,u in pairs(army.units) do
        if Own(army,u) and u:IsCompleted() and Has(u.tp,"MOBILE") and Has(u.tp,"SHIELD")
            and not Has(u.tp,"COMMAND") and type(u.GetShieldToggle)=="function"
            and type(u.SetShieldToggle)=="function" and type(u.CheckShieldState)=="function" then units[#units+1]=u end
    end
    table.sort(units,function(a,b) return a.id.index<b.id.index end)
    for _,u in ipairs(units) do
        local key=u.id.index
        local record=state.shieldControl[key]
        if record and record.unit~=u then record=nil; state.shieldControl[key]=nil end
        if not record then record={unit=u,last=-100};state.shieldControl[key]=record end
        local wantOff=e.ratio<0.04 and (free<0 or army.economy.isEnergyDown==true)
        if wantOff then record.lowSince=record.lowSince or Now()
        elseif e.ratio>=0.12 then record.lowSince=nil end
        local drain=math.max(0,((u.tp.economy or {}).maintenanceConsumption or {}).energy or 0)
        -- Debounce power starvation, never refresh shield health or bypass recharge.
        if u:GetShieldToggle() and record.lowSince and Now()-record.lowSince>=3
            and Now()-record.last>=15 then
            u:SetShieldToggle(false);u:CheckShieldState();record.disabled=true;record.last=Now()
        elseif record.disabled and not u:GetShieldToggle() and e.ratio>=0.40
            and free>=math.max(5,drain)
            and Now()-record.last>=15 then
            u:SetShieldToggle(true);u:CheckShieldState();record.disabled=nil;record.last=Now()
            free=free-drain;resumed=resumed+drain
        end
    end
    for key,r in pairs(state.shieldControl) do if not Own(army,r.unit) then state.shieldControl[key]=nil end end
    return resumed
end

local function ReleaseRecoveryPauses(army,state,c,snapshot)
    local records=state.recoveryPaused
    if not records then return end
    local need=c.constructors==0 or (c.totalFactories==0 and c.constructors<2)
    for key,record in pairs(records) do
        local factory,commander=record.unit,record.commander
        if not Own(army,factory) then records[key]=nil
        elseif not factory:GetPause() then records[key]=nil
        else
            local product=factory.unitBeingBuilt or factory.productionBehaviorTargetUnit
            local queued=factory.buildQueue and factory.buildQueue[1]
            local tp=product and product.tp or queued and Template(queued.tpId)
            local protected=Reliability.UpgradeTarget(factory) or factory.ai and factory.ai.rushUpgradeId
                or not tp or not Has(tp,"MOBILE") or Has(tp,"ENGINEER") or Has(tp,"COMMAND")
            if protected or not need or not Rules.Own(army,commander) or commander.ai~=record.unitAI
                or commander.platoon~=record.platoon or not record.platoon
                or record.platoon.ai~=record.platoonAI or not army:PlatoonExists(record.platoon)
                or snapshot.energy and snapshot.energy.ratio>0.5
                    and snapshot.alloy and snapshot.alloy.income>=7 then
                local energy=state.energyPaused and state.energyPaused[key]
                if not energy or energy.unit~=factory then factory:SetPause(false) end
                records[key]=nil
            end
        end
    end
end

-- New orders were budgeted, but already-paid factory queues could still keep
-- energy at zero. Temporarily park only ordinary combat production; never clear
-- its queue, pause engineers/upgrades, or take ownership of a manual pause.
function EnergyRecoveryBudget(army,snapshot)
    local state=State(army);state.energyPaused=state.energyPaused or {}
    local records=state.energyPaused;local e=snapshot.energy
    if not e then return end
    local free=Rules.Balance(e);local list={}
    local low=e.ratio<0.08 and free < -math.max(10,e.income*0.05)
    for _,u in ipairs(snapshot.factories or {}) do
        if Own(army,u) and not u.deleted and type(u.GetPause)=="function" and type(u.SetPause)=="function" then
            local product=u.unitBeingBuilt or u.productionBehaviorTargetUnit
            local queue=u.buildQueue and u.buildQueue[1]
            local tp=product and product.tp or queue and Template(queue.tpId)
            local lease=state.factoryLease
            local protected=Reliability.UpgradeTarget(u) or u.ai and u.ai.rushUpgradeId
                or lease and lease.unit==u and lease.expires>Now()
                or Has(u.tp,"LAND_FACTORY")
                or (Has(u.tp,"AIR_FACTORY") and snapshot.airRaid and Has(tp,"FIGHTER"))
                or (Has(u.tp,"AIR_FACTORY") and Bombers.IsBomber(tp)
                    and ((snapshot.roles and snapshot.roles.bomber) or 0)<=2)
                or not tp or Has(tp,"ENGINEER") or HeavyPolicy.IsT4(tp) or not Has(tp,"MOBILE")
            local record=records[u.id.index]
            if record and record.unit~=u then records[u.id.index]=nil;record=nil end
            local recovery=state.recoveryPaused and state.recoveryPaused[u.id.index]
            local recoveryOwned=recovery and recovery.unit==u
            if record and recoveryOwned then records[u.id.index]=nil;record=nil end
            local eco=tp and tp.economy;local work=eco and eco.buildTime
            local bp=u.construction and u.construction.buildPower
            local drain=work and work>0 and bp and bp>0 and (eco.cost and eco.cost.energy or 0)*bp/work or 0
            if record and (protected or army.ai.isAlive==false) then
                if u:GetPause() then u:SetPause(false);free=free-drain end
                records[u.id.index]=nil;record=nil
            end
            if not protected and not recoveryOwned and drain>0 then list[#list+1]={unit=u,drain=drain} end
        end
    end
    table.sort(list,function(x,y)
        return x.drain==y.drain and x.unit.id.index<y.unit.id.index or x.drain>y.drain
    end)
    -- Keep one existing defender queue for a threatened domain. Emergency power
    -- and engineer queues are protected independently of these combat choices.
    local keepLand,keepAir
    for i=#list,1,-1 do local u=list[i].unit
        if (not u:GetPause() or records[u.id.index]) and snapshot.landPanic and Has(u.tp,"LAND_FACTORY") and not keepLand then keepLand=u end
        if (not u:GetPause() or records[u.id.index]) and snapshot.airPanic and Has(u.tp,"AIR_FACTORY") and not keepAir then keepAir=u end
    end
    for _,item in ipairs(list) do
        local u,drain=item.unit,item.drain;local record=records[u.id.index]
        if u==keepLand or u==keepAir then
            if record then
                if u:GetPause() then u:SetPause(false);free=free-drain end
                records[u.id.index]=nil
            end
        elseif low and free<math.max(10,e.income*0.1) and not u:GetPause() then
            u:SetPause(true);records[u.id.index]={unit=u,since=Now()};free=free+drain
            Log("[RushWork] army="..tostring(army.id).." event=energy-production-paused factory="..u.id.index,true)
        elseif record and Now()-record.since>=15 and e.ratio>=0.35 and free>=drain*1.1+10 then
            if u:GetPause() then u:SetPause(false);free=free-drain end
            records[u.id.index]=nil
            Log("[RushWork] army="..tostring(army.id).." event=energy-production-resumed factory="..u.id.index,true)
        end
    end
    for key,r in pairs(records) do if not Own(army,r.unit) or r.unit.deleted then records[key]=nil end end
end

function Maintenance(army, plans)
    if not Controller or not Controller.IsRushArmy(army) then return end
    local state,c,snapshot=Get(army)
    if Now()<(state.nextMaintenance or 0) then return end
    state.nextMaintenance=Now()+3
    -- Recovery ownership can end with the ACU's death or platoon handoff.
    -- Its factories must be released even when CommanderRecoveryStep stops running.
    ReleaseRecoveryPauses(army,state,c,snapshot)
    Reliability.ExpireBuildMoveFailures(army)
    RepairBlacklist(army,state)
    Expansion.Maintain(army,snapshot)
    local _,fabricationEnergy=MassFabrication.Update(army,snapshot,plans)
    local energy=fabricationEnergy or snapshot.energy
    local shieldSpend=ShieldBudget(army,state,energy)
    if fabricationEnergy or shieldSpend>0 then
        local adjusted={}
        for key,value in pairs(snapshot) do adjusted[key]=value end
        adjusted.energy={}
        for key,value in pairs(energy) do adjusted.energy[key]=value end
        adjusted.energy.balance=energy.balance-shieldSpend
        adjusted.energy.request=energy.request+shieldSpend
        snapshot=adjusted
    end
    EnergyRecoveryBudget(army,snapshot)
    for _,u in pairs(army.units) do
        if Own(army,u) and Has(u.tp,"ENGINEER") and not HeavyPolicy.IsT4(u.tp) and u:IsCompleted()
            and not u.scoCommanderPodOwner and not u.scoSourcePodOwner then
            if not u.platoon then Reliability.PrepareIdleBuilder(u,plans) end
            local p=u.platoon;local f=p and p.ai and p.ai.formerTable
            if f and not f.RushT4Project and not BusyOrder(u) and not Working(u) and not u.unitToReclaim
                and not u.unitBeingRepaired and not u.unitBeingCaptured and not u.unitBeingReclaimed
                and not (u.ai and u.ai.reservedEco) then
                local r=state.idle[u.id.index]
                local pos=u:GetPosition()
                if not r or r.unit~=u or Distance2(r.pos,pos)>4 then
                    state.idle[u.id.index]={unit=u,pos={x=pos.x,z=pos.z},since=Now()}
                elseif Now()-r.since>=35 then
                    -- Only an orderless, stationary, nonworking unit is released.
                    if type(plans.ClearUnitTemporaryPlatoonData)=="function" then
                        plans.ClearUnitTemporaryPlatoonData(u,"R8 orphan recovery")
                    end
                    p:OnUnitRemoved(u);state.idle[u.id.index]=nil
                end
            else state.idle[u.id.index]=nil end
        end
    end
    for key,r in pairs(state.idle) do if not Own(army,r.unit) then state.idle[key]=nil end end
    state.combatIdle=state.combatIdle or {}
    for key,p in pairs(army.platoons) do
        local data=p.ai
        local f=data and data.formerTable
        local plan=f and f.AIPlan or ""
        local ground=data and data.targetLayer=="Land" and not data.isNavalPlatoon
        local combat=plan=="planLandAttackPrimary" or plan=="planLandAttack" or plan=="planSupportLandPrimaryPlatoon"
        if ground and combat and not data.rushOperation and not p.dead and p:GetNumOfUnits()>0 then
            local busy=false
            for _,u in ipairs(p:GetUnits()) do
                if Has(u.tp,"COMMAND") or Working(u) then busy=true;break end
                for _,w in ipairs(u.weapons or {}) do
                    if w.enabled and w.targetUnit and not w.targetUnit.dead then busy=true;break end
                end
                if busy then break end
            end
            local pos=p:GetPosition();local r=state.combatIdle[key]
            if busy or not r or r.platoon~=p or Distance2(r.pos,pos)>9 then
                state.combatIdle[key]={platoon=p,pos={x=pos.x,z=pos.z},since=Now()}
            elseif Now()-r.since>=35 then
                -- Repath the SAME platoon through its ordinary state machine.
                -- No teleport, forced merge or loss of paid/native work.
                data.path=nil;data.rushFlankCorridor=nil;data.rushSupportSince=nil
                data.rushSupportCooldown=Now()+20
                data.eState="SelectMainTarget"
                state.combatIdle[key]=nil
            end
        else state.combatIdle[key]=nil end
    end
    for key,r in pairs(state.combatIdle) do if not army:PlatoonExists(r.platoon) then state.combatIdle[key]=nil end end
end

local CommanderRoles={uel0000="support",ucl0000="offense",ugl0000="offense",usl0000="support"}
local enhancementWork
local function NativeEnhancement(unit)
    if not enhancementWork then enhancementWork=Import("AI/mods/AI-Scom/RushEnhancementWork.lua") end
    return enhancementWork.APIFor(unit)
end
local function Contract()
    local c=rawget(_G,"SCO_CommanderEnhancementContract")
    if not c then
        local ok,m=pcall(Import,"common/systems/scoCommanderEnhancements.lua")
        if ok and type(m)=="table" then c=m.SCO_CommanderEnhancementContract or m end
    end
    return c and c.commanders and c or nil
end
local function CopyValues(source)
    local result={};for key,value in pairs(source or {}) do result[key]=value end
    return result
end
local function SameValues(a,b)
    for key,value in pairs(a or {}) do if b[key]~=value then return false end end
    for key in pairs(b) do if (a or {})[key]==nil then return false end end
    return true
end
local function EnhancementTraits(commander,rule)
    local effects=rule.effects or {};local traits={}
    local engineering=effects.engineering
    if engineering then
        traits.engineering=(engineering.tier or 1)>1
            or (engineering.buildRateSet or 0)>(commander.base.buildRate or 0)
        traits.resilience=(engineering.maxHealthAdd or 0)>0 or (engineering.regenRateAdd or 0)>0
            or (engineering.regenRateSet or 0)>(commander.base.regenRate or 0)
    end
    traits.economy=effects.economy and ((effects.economy.massProductionAdd or 0)>0
        or (effects.economy.energyProductionAdd or 0)>0) or false
    traits.shield=type(effects.shield)=="table"
    traits.aura=effects.aura and (effects.aura.radius or 0)>0 and (effects.aura.regenPerSecond or 0)>0 or false
    traits.vision=effects.intel and (effects.intel.visionRadiusSet or 0)>(commander.base.visionRadius or 0) or false
    for _,spec in ipairs(effects.weapon and effects.weapon.weapons or {}) do
        if spec.label~="OverCharge" then
            traits.weapon=true
            if not spec.conditionalOnEnhancement and (spec.damageAdd or spec.maxRadiusSet
                or spec.rateOfFireSet or spec.damageRadiusAdd) then traits.gun=true end
        end
    end
    -- This extra automatic beam is implemented by the supplied paid adapter.
    traits.laser=traits.weapon and rule.id=="MicrowaveLaserGenerator" or false
    return traits
end
local function EnhancementScore(role,traits)
    local weights=role=="offense"
        and {gun=120,laser=115,weapon=105,resilience=94,shield=90,aura=85,vision=75,engineering=45,economy=35}
        or {aura=120,shield=110,engineering=100,resilience=90,economy=85,gun=70,weapon=65,vision=60}
    local score=0
    for kind,weight in pairs(weights) do if traits[kind] then score=math.max(score,weight) end end
    return score
end
local function CommanderContext(snapshot)
    if snapshot and (snapshot.landDisconnected or Pressure.SurvivalMap()) then return "support" end
    if snapshot and snapshot.landPressure and (snapshot.groundReady or 0)>=6 then return "offense" end
    return "default"
end
-- A commander commits to a compatible native build, not an affordable sequence
-- that can occupy the gun/shield/aura slot needed by its own later upgrades.
function CommanderRole(unit,snapshot)
    if not unit or not CommanderRoles[unit.tpId] or not Rules.Own(unit.army,unit) then return nil end
    -- The private adapter may safely initialize a genuine AI ACU whose core
    -- enhancement state has not yet been created. Do this before the state gate.
    local api=NativeEnhancement(unit)
    if not api then return nil end
    local state=unit.scoCommanderEnhancements;local contract=Contract()
    local commander=contract and contract.commanders[unit.tpId]
    if not state or not commander or not state.capabilities or state.version~=contract.version then return nil end
    unit.ai=unit.ai or {}
    local old=unit.ai.rushCommanderRole
    local same=old and old.owner==unit.army and old.state==state and old.contract==contract and old.commander==commander
        and old.rules==commander.enhancements and old.capabilities==state.capabilities
    if same and SameValues(state.installed,old.installed) and SameValues(state.slots,old.slots)
        and (old.locked or not snapshot or old.context==CommanderContext(snapshot)) then return old end
    if type(api.supports)~="function" then return nil end
    local nodes,ready={},{}
    for id,rule in pairs(commander.enhancements or {}) do
        local cap=state.capabilities.enhancements and state.capabilities.enhancements[id]
        if cap and cap.install==true and rule.id==id and type(rule.slot)=="string"
            and api.supports(rule) and api.validate(rule,false) then
            local traits=EnhancementTraits(commander,rule)
            nodes[id]={rule=rule,traits=traits}
            if (state.installed or {})[id] then
                for kind,value in pairs(traits) do if value then ready[kind]=true end end
            end
        end
    end
    snapshot=snapshot or Controller and Controller.Snapshot(unit.army)
    local locked=same and old.locked
    local context=CommanderContext(snapshot)
    local role=locked and old.role or context~="default" and context or CommanderRoles[unit.tpId]
    if not locked then
        if ready.laser or ready.weapon and not ready.engineering and not ready.aura then role="offense"
        elseif ready.engineering or ready.aura then role="support" end
    end
    local candidates={}
    for id,node in pairs(nodes) do
        local score=EnhancementScore(role,node.traits)
        if score>0 then candidates[#candidates+1]={id=id,score=score} end
    end
    table.sort(candidates,function(a,b) return a.score>b.score or a.score==b.score and a.id<b.id end)
    local chosen,slots=CopyValues(state.installed),CopyValues(state.slots)
    local steps,selected={},{}
    local function addGoal(goal)
        local trial,positions=CopyValues(chosen),CopyValues(slots)
        local path,visiting={},{}
        local function add(id)
            if trial[id] then return true end
            local node=nodes[id]
            if not node or visiting[id] then return false end
            visiting[id]=true
            local rule=node.rule
            if rule.prerequisite and not add(rule.prerequisite) then return false end
            if positions[rule.slot] and positions[rule.slot]~=rule.prerequisite then return false end
            for _,other in ipairs(rule.conflicts or {}) do if trial[other] then return false end end
            local parents={};local ancestor=rule.prerequisite
            while ancestor and not parents[ancestor] do
                parents[ancestor]=true
                local parent=commander.enhancements[ancestor];ancestor=parent and parent.prerequisite
            end
            for other,on in pairs(trial) do
                local previous=on and not parents[other] and commander.enhancements[other]
                for _,conflict in ipairs(previous and previous.conflicts or {}) do
                    if conflict==id then return false end
                end
            end
            trial[id]=true;positions[rule.slot]=id;path[#path+1]=id;visiting[id]=nil
            return true
        end
        if not add(goal) then return end
        chosen,slots=trial,positions
        for _,id in ipairs(path) do steps[#steps+1]=id;selected[id]=true end
    end
    if state.active and state.active.kind=="install" then addGoal(state.active.id) end
    for _,candidate in ipairs(candidates) do addGoal(candidate.id) end
    local planned=CopyValues(ready)
    for id in pairs(selected) do
        for kind,value in pairs(nodes[id].traits) do if value then planned[kind]=true end end
    end
    local niche=role=="offense" and "assault" or planned.aura and "aura"
        or planned.engineering and "engineer" or planned.shield and "shield" or "support"
    local profile={owner=unit.army,state=state,contract=contract,commander=commander,rules=commander.enhancements,
        capabilities=state.capabilities,installed=CopyValues(state.installed),slots=CopyValues(state.slots),
        context=context,locked=locked,
        role=role,niche=niche,steps=steps,selected=selected,ready={}}
    for _,kind in ipairs({"weapon","laser","shield","aura","engineering","resilience"}) do
        if ready[kind] then profile.ready[kind]=true end
    end
    unit.ai.rushCommanderRole=profile
    return profile
end
local function EnhancementFrame()
    return Finite(Tick) and Tick>=0 and Tick or nil
end
local function EnhancementIntentCurrent(army,intent)
    local unit=intent and intent.unit
    return intent and intent.army==army and intent.armyAI==army.ai and army.ai.isAlive~=false
        and Rules.Own(army,unit) and unit.ai==intent.unitAI and unit.ai.rushEnhanceIntent==intent
        and unit.scoCommanderEnhancements==intent.state
        and Reliability.CurrentAssignment(unit,army,intent.platoon,intent.unitAI,intent.platoonAI)
        and army.ai.bases and army.ai.bases.MAIN==intent.home
        and intent.home.position and Distance2(intent.home.position,intent.homePosition)<1
end
local function ReleaseEnhancementIntent(army,unitAI,intent,retry)
    local development=army.ai and army.ai.rushDevelopment
    if development and development.commanderLease==intent then development.commanderLease=nil end
    if unitAI and unitAI.rushEnhanceIntent==intent then
        unitAI.rushEnhanceIntent=nil
        if retry then unitAI.rushEnhanceRetry=Now()+retry end
    end
end
-- Pure budget callback: no snapshot, path search, resource read or order issue.
-- A pre-start census retains the promised rate until its actual native sample
-- can include this exact paid entity. Ongoing work is never charged twice.
function PendingCommanderReserve(army,except,sample)
    local development=army and army.ai and army.ai.rushDevelopment
    local lease=development and development.commanderLease
    if not lease or not EnhancementIntentCurrent(army,lease) or Now()>=lease.expires
        or lease.phase=="return" then return 0,0 end
    local unit=lease.unit
    if type(unit.GetPause)=="function" and unit:GetPause() then return 0,0 end
    if unit==except then return 0,0,unit,lease.id end
    local mass,energy=lease.mass,lease.energy
    if lease.phase=="active" then
        if lease.state.active~=lease.active then return 0,0 end
        local sampled=sample and (lease.startedTick and sample.tick and sample.tick>lease.startedTick
            or not lease.startedTick and sample.seconds and sample.seconds>lease.startedAt)
        local entity=unit.resourceEntities and unit.resourceEntities.scoCommanderEnhancement
        local registry=army.economy and army.economy.resourceEntities and army.economy.resourceEntities.construction
        if sampled and entity and entity==lease.entity and entity.enabled==true
            and entity.armyId==army.id and entity.unitId==unit.id and entity.economy==army.economy
            and registry and registry[entity.id]==entity and Finite(entity.userMultiplier)
            and entity.userMultiplier>=0 then
            -- A cached sample may precede later changes to the native rate.
            -- Once registration was sampled, its own request owns all running
            -- cost; never subtract today's multiplier from yesterday's census.
            mass,energy=0,0
        end
    end
    return mass,energy+(lease.upkeep or 0),unit,lease.id
end
function CleanupCommanderInvestment(army)
    local development=army and army.ai and army.ai.rushDevelopment
    local lease=development and development.commanderLease
    if lease and (not EnhancementIntentCurrent(army,lease) or Now()>=lease.expires
        or lease.phase=="active" and lease.state.active~=lease.active) then
        ReleaseEnhancementIntent(army,lease.unitAI,lease)
    end
end
local function EnhancementOrdersOwned(platoon,unit)
    local data=platoon.ai;local orders=unit.orders or {}
    local service=data.rushCommanderService
    local serviceOwned=service and service.unit==unit and service.army==unit.army
        and service.armyAI==unit.army.ai and service.platoon==platoon and service.platoonAI==data
        and service.unitAI==unit.ai
    local move=unit.ai.rushMoveQueue
    local moveOwned=move and move.owner==unit.army and move.armyAI==unit.army.ai
        and move.platoon==platoon and move.pai==data and move.ai==unit.ai
        and move.operation==data.rushOperation and move.fleet==data.rushFleet
        and move.layer==data.movementLayer and unit.ai.path==move.path and data.path==move.source
    local support=data.rushCommanderSupport
    local micro=unit.ai.weaponMicroData
    local microOwned=micro and micro.commanderPath==data.path and micro.commanderUnitPath==unit.ai.path
    local function owned(order)
        return serviceOwned and service.order==order
            or moveOwned and move.orders and move.orders[order]
            or support and support.orders and support.orders[order]
            or microOwned and micro.commanderOrders and micro.commanderOrders[order]
    end
    if orders.activeOrder and not owned(orders.activeOrder) then return false end
    for _,order in pairs(orders.queuedOrders or {}) do if not owned(order) then return false end end
    return true
end
local function PrepareEnhancementOrders(platoon,unit,prepare)
    local army,unitAI,data=unit.army,unit.ai,platoon.ai
    local armyAI=army.ai;local path,unitPath=data.path,unitAI.path
    local function current()
        return army.ai==armyAI and Reliability.CurrentAssignment(unit,army,platoon,unitAI,data)
    end
    if not current() or not EnhancementOrdersOwned(platoon,unit) then return false end
    prepare(platoon,unit)
    if not current() or not EnhancementOrdersOwned(platoon,unit) then return false end
    Orders.HostClearOrder({unit})
    Import("AI/mods/AI-Scom/RushMovement.lua").Forget(unit,false)
    if not current() then return false end
    -- Retire only the old route. An abandoned path must not later authorize
    -- ordinary selection to clear a newer native command during this handoff.
    if data.path==path then data.path=false end
    if unitAI.path==unitPath then unitAI.path=false;unitAI.moveToDestinationReached=nil end
    data.primaryTarget=false;data.commanderApproachWatch=nil
    return true
end
local function EnhancementResources(unit,snapshot,creditAssist)
    local a,e=Rules.Resources(unit.army,unit)
    if not a or not e then return nil end
    local result={}
    for key,value in pairs(snapshot) do result[key]=value end
    result.alloy,result.energy=a,e
    local data=unit.platoon and unit.platoon.ai
    local service=data and data.rushCommanderService
    if creditAssist and service and (service.kind or "assist")=="assist"
        and service.unit==unit and service.unitAI==unit.ai and service.armyAI==unit.army.ai
        and service.platoon==unit.platoon and service.platoonAI==data
        and service.target==data.commanderProductionAssistFactory
        and service.product==data.commanderProductionAssistObservedUnit
        and service.order== (unit.orders and unit.orders.activeOrder)
        and not next(unit.orders.queuedOrders or {}) and Rules.Own(unit.army,service.product)
        and not service.product:IsCompleted() then
        local _,_,mass,energy=CommanderWork.AssistRates(unit,service.product)
        a.balance=a.balance+(mass or 0);e.balance=e.balance+(energy or 0)
    end
    return result
end
local function EnhancementFieldReady(unit,snapshot)
    if not EconomyUsable(snapshot) or (snapshot.completeFactories or 0)<2
        or (snapshot.engineersComplete or 0)<1 or snapshot.mainRaid
        or EconomyPolicy.NeedsGroundRecovery(unit.army,snapshot) then return false end
    local roles=snapshot.completeRoles or {}
    if EconomyPolicy.LandEnabled(unit.army) and not snapshot.landDisconnected then
        if (snapshot.groundReady or 0)<6 then return false end
    elseif (roles.fighter or 0)+(roles.bomber or 0)+(roles.gunship or 0)
        +(roles.naval or 0)+(roles.submarine or 0)<4 then return false end
    if snapshot.airPanic and (roles.fighter or 0)<2 then return false end
    return snapshot.energy.ratio>=0.15 and not (unit.army.economy and unit.army.economy.isEnergyDown)
end
local function ShieldMaintenanceDelta(unit,rule)
    local shield=rule.effects and rule.effects.shield
    if not shield then return 0 end
    local upkeep=shield.maintenanceEnergy or 0
    if not Finite(upkeep) or upkeep<0 then return nil end
    local state=unit.scoCommanderEnhancements
    local entity=unit.resourceEntities and unit.resourceEntities.scoCommanderShieldConsumption
    local registered=entity and entity.economy and entity.economy.resourceEntities
        and entity.economy.resourceEntities.consumption
    local existing=state and state._shieldMaintenance
    local paid=entity and entity.outcome and entity.outcome.energy
    local credit=0
    -- Credit only upkeep already requested by this commander's active native
    -- consumption entity. A disabled shield cannot fund its replacement.
    if state and state._activeShieldId and Finite(existing) and existing>0
        and entity and entity.enabled==true and entity.category=="consumption"
        and entity.armyId==unit.army.id and entity.unitId==unit.id
        and registered and registered[entity.id]==entity and Finite(paid) and paid>0 then
        credit=math.min(existing,paid*((Constants and Constants.TickRate) or 10))
    end
    return math.max(0,upkeep-credit)
end
local function EnhancementOffer(unit,snapshot,id,profile)
    local api=NativeEnhancement(unit);local state=unit.scoCommanderEnhancements
    local rule=api and api.allowed(state,profile.commander,id)
    if not rule or not profile.selected[id] or not api.supports(rule) then return nil end
    local cost=api.validate(rule,false)
    if not cost then return nil end
    local a,e=snapshot.alloy,snapshot.energy
    local mass,energy,seconds,authored=Pressure.EnhancementForecast(unit,id,cost,a,e)
    local ceiling=math.max(rule.prerequisite and 600 or id=="MicrowaveLaserGenerator" and 600 or 360,
        (authored or 0)*2)
    local upkeep=ShieldMaintenanceDelta(unit,rule)
    if not seconds or not Finite(seconds) or seconds<=0 or seconds>ceiling or upkeep==nil then return nil end
    -- An elective permanent shield still needs real ongoing power. Stored
    -- energy may finance construction, never its indefinite upkeep.
    if upkeep>0 and Rules.Balance(e)<upkeep+math.max(15,e.income*0.03) then return nil end
    return {id=id,cost=cost,mass=mass,energy=energy,seconds=seconds,authored=authored,upkeep=upkeep}
end
function ChooseEnhancement(unit,snapshot,planning)
    local profile=CommanderRole(unit,snapshot)
    if not profile or not EnhancementFieldReady(unit,snapshot) then return nil end
    local a,e=snapshot.alloy,snapshot.energy
    for _,id in ipairs(profile.steps) do
        local offer=EnhancementOffer(unit,snapshot,id,profile)
        if offer then
            local seconds=offer.seconds
            local funded=e.ratio>=0.25
                and Rules.Balance(a)+math.max(0,a.current-a.storage*0.20)/seconds>=offer.mass
                and Rules.Balance(e)+math.max(0,e.current-e.storage*0.20)/seconds>=offer.energy+offer.upkeep
            if planning or funded then return id,seconds,offer end
        end
    end
    return nil
end
local function TrustedCommander(unit)
    if IsHost~=true or not unit or not unit.army or not Controller
        or not Controller.IsRushArmy(unit.army) or not Own(unit.army,unit)
        or not CommanderRoles[unit.tpId] then return false end
    -- Never provide a non-client route to a human-controlled army.
    local lobby=Import("common/lobby.lua")
    if lobby.ArmyToPlayer and lobby.ArmyToPlayer[unit.army.id] then return false end
    return unit.army.ai.isAlive==true
end
function StartAIEnhancement(unit,id)
    if not TrustedCommander(unit) or type(id)~="string" or #id>96 then return false,"not-ai-owner" end
    local api=NativeEnhancement(unit)
    if not api then return false,"native-ai-contract-unavailable" end
    local abilities=unit.scoCommanderAbilities
    if abilities and (abilities.teleport or abilities.missileLaunch
        or (abilities.missileBuild and abilities.missileBuild.autoBuild~=true)) then return false,"ability-busy" end
    local state,commander=api.ensure(unit)
    if state.active then return false,"busy" end
    if not api.complete(unit) then return false,"under-construction" end
    if not api.idle(unit) then return false,"unit-not-idle" end
    local rule,reason=api.allowed(state,commander,id)
    if not rule then return false,reason end
    local cost,costReason=api.validate(rule,false)
    if not cost then return false,costReason end
    -- This is the original resource-entity and progress-thread implementation.
    return api.begin(unit,state,id,"install",cost,nil)
end
function CancelAIEnhancement(unit)
    if not TrustedCommander(unit) then return false,"not-ai-owner" end
    local api=NativeEnhancement(unit)
    if not api then return false,"native-ai-contract-unavailable" end
    local state=api.ensure(unit)
    if not state.active then return false,"not-busy" end
    api.stop(unit,true);api.publish(unit)
    return true
end

-- Called from the commander plan itself: a single owner coordinates combat,
-- assists and enhancements, so their order loops cannot cancel each other.
function CommanderStep(platoon,unit,danger,prepare)
    if not Controller or not unit or not Rules.Own(unit.army,unit) or not Controller.IsRushArmy(unit.army) then return false end
    unit.ai=unit.ai or {}
    local army,unitAI,data=unit.army,unit.ai,platoon and platoon.ai
    local armyAI=army.ai
    local function current()
        return army.ai==armyAI and Rules.Own(army,unit)
            and Reliability.CurrentAssignment(unit,army,platoon,unitAI,data)
    end
    if not current() then return false end
    local player=Import("common/lobby.lua").ArmyToPlayer
    player=player and player[unit.army.id]
    local clientID=player and player.clientID
    local start=rawget(_G,"SCO_CommanderEnhancementHostStart")
    local cancel=rawget(_G,"SCO_CommanderEnhancementHostCancel")
    if clientID==nil and TrustedCommander(unit) then
        if NativeEnhancement(unit) then
            start=function(_,_,id) return StartAIEnhancement(unit,id) end
            cancel=function() return CancelAIEnhancement(unit) end
            clientID=0 -- Local dispatch placeholder; never submitted as a lobby owner.
        elseif not unit.ai.rushNativeEnhancementWarning then
            unit.ai.rushNativeEnhancementWarning=true
            Log("[RushV9] commander enhancement state not ready for AI work: "..unit.tpId,true)
        end
    end
    local state=unit.scoCommanderEnhancements
    if type(state)~="table" or type(start)~="function" or type(cancel)~="function"
        or type(clientID)~="number" then return false end
    local active=state.active
    if active~=nil and (type(active)~="table" or not Finite(active.progress)
        or not Finite(active.buildTime) or active.buildTime<=0) then return false end
    if active then
        local abandon=danger
        local abortReason
        local now=Now()
        local progress=active.progress or 0
        local watch=unit.ai.rushEnhanceWatch
        if not watch or watch.active~=active then
            watch={active=active,progress=progress,advanced=now}
            unit.ai.rushEnhanceWatch=watch
        elseif progress>watch.progress+0.001 then
            watch.progress=progress;watch.advanced=now
        end
        local paused=active.paused==true or unit:GetPause()==true
        if paused then
            watch.pausedAt=watch.pausedAt or now
        elseif watch.pausedAt then
            -- Intentional pause preserves paid work and the remaining watchdog
            -- time. A final already-paid tick may advance progress while pausing.
            local held=math.max(0,now-watch.pausedAt)
            watch.advanced=math.min(now,watch.advanced+held)
            watch.pausedAt=nil
        end
        if not paused and now-watch.advanced>=(progress>0 and 90 or 45) then
            abortReason="stalled"
        end
        -- Resource satisfaction can extend a paid upgrade beyond its forecast.
        -- Continue while useful progress is being paid; local danger still wins.
        local investment=unit.ai.rushEnhanceIntent
        if investment and EnhancementIntentCurrent(army,investment) and investment.phase=="active"
            and investment.active==active then investment.expires=now+120 end
        abandon=abandon or abortReason~=nil
        if abandon and type(cancel)=="function" and type(clientID)=="number" then
            local ok,done=pcall(cancel,clientID,unit.id)
            if not current() then return false end
            if ok and done then
                if abortReason and not danger then
                    Log(("[RushV9] commander=%s enhancement=%s cancelled reason=%s progress=%.2f/%.2f")
                        :format(unit.tpId,active.id,abortReason,active.progress or 0,active.buildTime or 0),true)
                end
                ReleaseEnhancementIntent(army,unit.ai,unit.ai.rushEnhanceIntent)
                unit.ai.rushEnhanceWatch=nil;unit.ai.rushEnhancing=nil
                unit.ai.rushEnhanceExpectedSeconds=nil;unit.ai.rushEnhanceRetry=Now()+(danger and 30 or 45)
                platoon.ai.eState=danger and "StartWithdraw" or "SelectMainTarget"
                return false
            end
        end
        platoon.ai.eState="Enhancing";unit.ai.rushEnhancing=true
        return true
    end
    unit.ai.rushEnhanceWatch=nil
    if unit.ai.rushEnhancing then
        ReleaseEnhancementIntent(army,unit.ai,unit.ai.rushEnhanceIntent)
        unit.ai.rushEnhancing=nil;unit.ai.rushEnhanceExpectedSeconds=nil
        unit.ai.rushEnhanceRetry=math.max(unit.ai.rushEnhanceRetry or 0,Now()+15)
        platoon.ai.eState="SelectMainTarget"
        platoon.ai.path=nil;platoon.ai.primaryTarget=false
        unit.ai.path=nil;unit.ai.moveToDestinationReached=nil
        unit.ai.rushServiceStall=nil
    end
    local intent=unitAI.rushEnhanceIntent
    if intent and (not EnhancementIntentCurrent(army,intent) or Now()>=intent.expires) then
        local replacedHome=army.ai.bases and intent.home~=army.ai.bases.MAIN
        ReleaseEnhancementIntent(army,unitAI,intent,replacedHome and 0 or 15);intent=nil
    end
    if danger or type(start)~="function" or type(clientID)~="number"
        or type(unit.GetPause)=="function" and unit:GetPause() then
        ReleaseEnhancementIntent(army,unitAI,intent);return false
    end
    if CommanderWork.ConstructionTarget(unit) then
        ReleaseEnhancementIntent(army,unitAI,intent);return false
    end
    local pos=unit:GetPosition();local home=army.ai.bases and army.ai.bases.MAIN
    if not home or not home.position or data.commanderUnderAttack
        or unit:GetHealth()<unit:GetMaxHealth()*0.70 or not Expansion.Safe(army,pos) then
        ReleaseEnhancementIntent(army,unitAI,intent);return false
    end
    for _,weapon in ipairs(unit.weapons or {}) do
        local target=weapon.targetUnit
        if weapon.enabled and not weapon.isDeathExplosion and target and not target.dead and not target.deleted and target.army
            and army:IsEnemy(target.army) and weapon:CanShootAt(target)
            and weapon:IsTargetInRange(target) then
            ReleaseEnhancementIntent(army,unitAI,intent);return false
        end
    end
    if not EnhancementOrdersOwned(platoon,unit) then
        ReleaseEnhancementIntent(army,unitAI,intent)
        -- Returning false would let normal target selection clear the very
        -- replacement order rejected here. Its owner keeps this safe turn.
        return true
    end
    local changedHome=data.rushEnhanceHome and data.rushEnhanceHome~=home
        or not data.basePosition or Distance2(data.basePosition,home.position)>=1
    if changedHome then
        if not PrepareEnhancementOrders(platoon,unit,prepare) then
            ReleaseEnhancementIntent(army,unitAI,intent);return current()
        end
        ReleaseEnhancementIntent(army,unitAI,intent);intent=nil
        data.commanderWithdrawalPhase=nil;data.commanderWithdrawalNeedsEmergencySupport=nil
        data.eState="SelectMainTarget"
    end
    data.rushEnhanceHome=home
    data.basePosition={x=home.position.x,y=home.position.y,z=home.position.z};data.baseRadius=home.radius
    if Now()<(unitAI.rushEnhanceRetry or 0) then return false end
    local snapshot=Controller.Snapshot(army)
    snapshot=EnhancementResources(unit,snapshot,true)
    if not current() or not snapshot or not EnhancementFieldReady(unit,snapshot) then
        ReleaseEnhancementIntent(army,unitAI,intent);return false
    end
    local development=State(army);local other=development.commanderLease
    if other and other~=intent then
        if EnhancementIntentCurrent(army,other) and Now()<other.expires then return false end
        development.commanderLease=nil
    end
    local id,expectedSeconds,offer
    if intent then
        local profile=CommanderRole(unit,snapshot)
        offer=profile and EnhancementOffer(unit,snapshot,intent.id,profile)
        if offer then id,expectedSeconds=offer.id,offer.seconds end
    else id,expectedSeconds,offer=ChooseEnhancement(unit,snapshot,true) end
    if not current() then return false end
    if not offer then ReleaseEnhancementIntent(army,unitAI,intent,5);return false end
    local atHome=Distance2(pos,home.position)<=(home.radius or 60)^2
    if data.commanderWithdrawalPhase and (not intent or intent.phase~="return") then return false end
    if not intent then
        intent={army=army,armyAI=armyAI,unit=unit,unitAI=unitAI,platoon=platoon,platoonAI=data,
            home=home,homePosition={x=home.position.x,y=home.position.y,z=home.position.z},state=unit.scoCommanderEnhancements,
            id=id,at=Now(),phase=atHome and "funding" or "return",expires=Now()+(atHome and 60 or 120)}
        unitAI.rushEnhanceIntent=intent
        if intent.phase=="return" then
            prepare(platoon,unit)
            if not current() or not EnhancementOrdersOwned(platoon,unit) then
                ReleaseEnhancementIntent(army,unitAI,intent);return current()
            end
            data.commanderForwardPressure=nil
            return true,"return"
        end
    end
    if intent.phase=="return" then
        if not atHome or data.commanderWithdrawalPhase then return true,"return" end
        intent.phase="funding";intent.at=Now();intent.expires=Now()+60
    elseif not atHome then
        ReleaseEnhancementIntent(army,unitAI,intent,10);return false
    end
    intent.mass,intent.energy,intent.upkeep,intent.expected=offer.mass,offer.energy,offer.upkeep,expectedSeconds
    development.commanderLease=intent
    if not intent.prepared then
        if not PrepareEnhancementOrders(platoon,unit,prepare) then
            ReleaseEnhancementIntent(army,unitAI,intent);return current()
        end
        intent.prepared=true;intent.handoffTick=EnhancementFrame();intent.handoffAt=Now()
        data.commanderForwardPressure=nil;data.commanderWithdrawalPhase=nil
        data.eState="SelectMainTarget"
        return true
    end
    local frame=EnhancementFrame()
    local settled=intent.handoffTick and frame and frame>intent.handoffTick
        or not intent.handoffTick and Now()>intent.handoffAt
    if not settled then return true end
    -- Read fresh native totals after the released assist has left the economy.
    -- Never rerun this handoff against the stale one-second census balance.
    snapshot=EnhancementResources(unit,snapshot,false)
    local a,e=snapshot and snapshot.alloy,snapshot and snapshot.energy
    local funded=a and e and e.ratio>=0.25
        and Rules.Balance(a)+math.max(0,a.current-a.storage*0.20)/expectedSeconds>=offer.mass
        and Rules.Balance(e)+math.max(0,e.current-e.storage*0.20)/expectedSeconds>=offer.energy+offer.upkeep
    if not funded then
        if intent.phase=="start" then intent.phase="funding" end
        data.eState="SelectMainTarget"
        CommanderWork.Update(platoon,unit,true)
        return current()
    end
    if intent.phase~="start" then
        if not PrepareEnhancementOrders(platoon,unit,prepare) then
            ReleaseEnhancementIntent(army,unitAI,intent);return current()
        end
        intent.phase="start";intent.startAt=Now();intent.handoffTick=EnhancementFrame();intent.handoffAt=Now()
        return true
    end
    if BusyOrder(unit) then
        if Now()-(intent.startAt or Now())>4 then ReleaseEnhancementIntent(army,unitAI,intent,10);return false end
        return true
    end
    local ok,accepted,reason=pcall(start,clientID,unit.id,id)
    if not current() then return false end
    unitAI.rushEnhanceRetry=Now()+(ok and accepted and 15 or 20)
    if ok and accepted then
        local role=unitAI.rushCommanderRole
        if role and role.selected[id] then role.locked=true end
        intent.phase="active";intent.active=unit.scoCommanderEnhancements.active
        intent.entity=unit.resourceEntities and unit.resourceEntities.scoCommanderEnhancement
        intent.startedTick=EnhancementFrame();intent.startedAt=Now();intent.expires=Now()+120
        unitAI.rushEnhanceExpectedSeconds=expectedSeconds
        unitAI.rushEnhancing=true;data.eState="Enhancing";data.commanderForwardPressure=nil
        Log("[RushV9] commander="..unit.tpId.." enhancement="..id.." started",true)
        return true
    end
    ReleaseEnhancementIntent(army,unitAI,intent)
    Log("[RushV9] commander enhancement deferred: "..tostring(ok and reason or accepted),true)
    return false
end


-- Rebuild using the surviving ACU itself. The combat platoon remains the only
-- owner of the commander, so a separate engineer thread cannot cancel this job.
local function ClearRecoveryReservation(army,unit,work)
    local reserve=army.ai.ecoReserve and army.ai.ecoReserve[unit.id.index]
    if reserve and reserve==work.reservation then
        AF.ClearReserveEco(army.id,unit.id.index)
    end
end
function CommanderRecoveryStep(platoon,unit,danger,prepare)
    if not Controller or not unit or not Rules.Own(unit.army,unit) or not Controller.IsRushArmy(unit.army) then return false end
    unit.ai=unit.ai or {}
    local army,unitAI,data=unit.army,unit.ai,platoon and platoon.ai
    local armyAI=army.ai
    local function current()
        return army.ai==armyAI and Rules.Own(army,unit)
            and Reliability.CurrentAssignment(unit,army,platoon,unitAI,data)
    end
    if not current() then return false end
    local state,c,snapshot=Get(army)
    if not current() then return false end
    local need=c.constructors==0 or (c.totalFactories==0 and c.constructors<2)
    local work=unit.ai.rushRecoveryWork
    -- Stop economic collapse from being prolonged by a surviving air factory
    -- spending the last income on a fighter instead of the first replacement builder.
    state.recoveryPaused=state.recoveryPaused or {}
    ReleaseRecoveryPauses(army,state,c,snapshot)
    if need and EconomyUsable(snapshot) then
        for _,factory in pairs(army.units) do
            if Rules.Own(army,factory) and Has(factory.tp,"FACTORY") and Has(factory.tp,"STRUCTURE")
                and type(factory.SetPause)=="function" and type(factory.GetPause)=="function" then
                local product=factory.unitBeingBuilt
                local queued=factory.buildQueue and factory.buildQueue[1]
                local tp=product and product.tp or (queued and Template(queued.tpId))
                local energy=state.energyPaused and state.energyPaused[factory.id.index]
                if tp and Has(tp,"MOBILE") and not Has(tp,"ENGINEER") and not Has(tp,"COMMAND")
                    and not Reliability.UpgradeTarget(factory) and not factory:GetPause()
                    and (not energy or energy.unit~=factory)
                    and (snapshot.energy.ratio<0.2 or snapshot.alloy.income<5) then
                    factory:SetPause(true)
                    state.recoveryPaused[factory.id.index]={unit=factory,commander=unit,unitAI=unitAI,
                        platoon=platoon,platoonAI=data}
                end
            end
        end
    end
    if not current() then return false end
    if work then
        local orders=unit.orders or {}
        local ownsOrder=work.order and orders.activeOrder==work.order
        local pending,exclusiveOrder=ownsOrder,ownsOrder
        for _,order in pairs(orders.queuedOrders or {}) do
            if order==work.order then pending=true else exclusiveOrder=false end
        end
        local building=unit.unitBeingBuilt
            or (unit.buildBehaviorIsActive and unit.buildBehaviorActualUnit)
        local target=work.order and work.order.unitGettingBuilt
        if not target and pending and building and building.tpId==work.id then target=building end
        local ownTarget=Rules.Own(army,target) and target.tpId==work.id
        local constructing=ownTarget and building==target and (not orders.activeOrder or ownsOrder)
        if danger then
            -- Preserve the unfinished structure; another builder can finish it.
            if exclusiveOrder then Orders.HostClearOrder({unit}) end
            ClearRecoveryReservation(army,unit,work)
            unit.ai.rushRecoveryWork=nil;unit.ai.rushRecoveryRetry=Now()+15
            platoon.ai.eState="StartWithdraw";return false
        end
        if ownTarget then
            ClearRecoveryReservation(army,unit,work)
            if target:IsCompleted() then
                if exclusiveOrder then Orders.HostClearOrder({unit}) end
                unit.ai.rushRecoveryWork=nil;Controller.Snapshot(army,true)
                if current() then data.eState="SelectMainTarget" end
                return false
            end
        end
        local progress=ownTarget and target.progress
        if ownTarget and type(progress)~="number" and type(target.GetFractionComplete)=="function" then
            progress=target:GetFractionComplete()
        end
        local distance=work.position and Distance2(unit:GetPosition(),work.position) or math.huge
        if work.target~=target or not work.progressAt then
            work.target,work.progress,work.bestDistance,work.progressAt=target,progress,distance,Now()
        elseif type(progress)=="number" and (type(work.progress)~="number" or progress>work.progress)
            or not constructing and distance<work.bestDistance-1 then
            work.progress,work.bestDistance,work.progressAt=progress,math.min(distance,work.bestDistance),Now()
        end
        local paused=type(unit.GetPause)=="function" and unit:GetPause()
        if paused then work.pausedAt=work.pausedAt or Now()
        elseif work.pausedAt then
            work.progressAt=math.min(Now(),work.progressAt+math.max(0,Now()-work.pausedAt))
            work.pausedAt=nil
        end
        -- Intentional pauses preserve the remaining watchdog time. Danger still
        -- interrupts above; only an unpaused stalled approach/build is released.
        local stalled=not paused and Now()-work.progressAt>=(constructing and 60 or 25)
        if constructing and (type(progress)~="number" or not stalled)
            or pending and not stalled and not (target and not ownTarget) then
            data.eState="CommanderRebuild";return true
        end
        -- Preserve the foundation and any newer order while releasing this job.
        if exclusiveOrder then Orders.HostClearOrder({unit}) end
        ClearRecoveryReservation(army,unit,work)
        unit.ai.rushRecoveryWork=nil;unit.ai.rushRecoveryRetry=Now()+5
        platoon.ai.eState="SelectMainTarget"
    end
    if not need or danger or type(unit.GetPause)=="function" and unit:GetPause()
        or Now()<(unit.ai.rushRecoveryRetry or 0) then return false end
    if unit.scoCommanderEnhancements and unit.scoCommanderEnhancements.active then
        CancelAIEnhancement(unit)
        if not current() then return false end
        return true
    end
    if Working(unit) and not platoon.ai.commanderProductionAssistFactory then return false end
    local expectedOrder=unit.orders and unit.orders.activeOrder
    local observed=unit:GetPosition()
    local pos={x=observed.x,y=observed.y or 0,z=observed.z}
    if not Expansion.Safe(army,pos) then return false end
    local enemy=AF.GetClosestEnemy(army.id,pos,35,Tags.MOBILE-Tags.AIR,data.movementLayer,false)
    if enemy and not enemy.dead and not enemy.deleted then
        for _,weapon in ipairs(enemy.weapons or {}) do
            if weapon.enabled and not weapon.isDeathExplosion and weapon:CanShootAt(unit) then return false end
        end
    end
    local a,e=snapshot.alloy,snapshot.energy
    if not a or not e then return false end
    local kind
    if (c.power[1] or 0)+(c.power[2] or 0)+(c.power[3] or 0)<2 and (e.income<50 or e.ratio<0.25) then kind="ENERGY_PRODUCTION"
    elseif (c.mex[1] or 0)+(c.mex[2] or 0)+(c.mex[3] or 0)<3 and Now()>=(unit.ai.rushRecoveryMexRetry or 0) then kind="ALLOYS_EXTRACTION"
    elseif c.totalFactories==0 then kind="LAND_FACTORY"
    elseif e.balance<10 and (c.power[1] or 0)<5 then kind="ENERGY_PRODUCTION"
    elseif c.landFactories==0 and c.constructors==0 then kind="LAND_FACTORY"
    else return false end
    local id
    for candidate,tp in pairs(__Templates.Units) do
        if Has(tp,kind) and Has(tp,"TECH1") and Has(tp,"STRUCTURE") and Reliability.AllowedTarget(candidate,false)
            and Reliability.Footprint(tp) and Reliability.CanBuilderBuild(unit,candidate) then
            if not id or ((tp.economy or {}).cost or {}).alloys<((Template(id).economy or {}).cost or {}).alloys then id=candidate end
        end
    end
    if not id then unit.ai.rushRecoveryRetry=Now()+15;return false end
    local cost=Template(id).economy.cost
    if a.current<math.min(cost.alloys,40) and a.income<3 then return false end
    local place
    if kind=="ALLOYS_EXTRACTION" then
        local best
        for _,p in ipairs(AlloyMarkerPositions()) do
            if Reliability.Inside(p) and Distance2(pos,p)<120*120 and Expansion.Safe(army,p)
                and MG.CanGraphAreaTo(pos,p,data.movementLayer) and AF.CanBuildStructureAt(army.id,id,p,0) then
                local d=Distance2(pos,p)
                if not best or d<best then best=d;place=p end
            end
        end
    else
        place=AF.FindPlaceToBuild(army.id,id,Reliability.Clamp(pos,10),2,false,30)
    end
    if not current() or (unit.orders and unit.orders.activeOrder)~=expectedOrder then return false end
    if not place then
        if kind=="ALLOYS_EXTRACTION" then unit.ai.rushRecoveryMexRetry=Now()+30 end
        unit.ai.rushRecoveryRetry=Now()+3;return false
    end
    if not Reliability.Inside(place) or not Expansion.Safe(army,place)
        or not MG.CanGraphAreaTo(pos,place,data.movementLayer) then return false end
    place={x=place.x,y=place.y or 0,z=place.z}
    if not current() or (unit.orders and unit.orders.activeOrder)~=expectedOrder
        or unit.orders and unit.orders.queuedOrders and next(unit.orders.queuedOrders) then return false end
    prepare(platoon,unit)
    if not current() then return false end
    local orders=unit.orders or {}
    if orders.activeOrder and orders.activeOrder~=expectedOrder
        or orders.queuedOrders and next(orders.queuedOrders) then return false end
    Orders.HostClearOrder({unit})
    AF.SetReserveEco(army.id,unit.id.index,id)
    local reservation=army.ai.ecoReserve and army.ai.ecoReserve[unit.id.index]
    Orders.HostIssueOrder(Tasks.BUILD,{unit},false,place,{tpId=id,armyId=army.id})
    if not current() then
        if Rules.Own(army,unit) then ClearRecoveryReservation(army,unit,{reservation=reservation}) end
        return false
    end
    local order=unit.orders and unit.orders.activeOrder
    if order and order.orderTask==Tasks.BUILD then
        unit.ai.rushRecoveryWork={id=id,at=Now(),order=order,position=place,
            reservation=reservation}
        platoon.ai.eState="CommanderRebuild"
        Log("[RushV9] army="..army.id.." commander rebuild="..id,true)
        return true
    end
    ClearRecoveryReservation(army,unit,{id=id,reservation=reservation});unit.ai.rushRecoveryRetry=Now()+8
    return false
end
