-- Sanctuary Rush 9.0.6-rc7: profile-owned, four-faction reactive scheduling.
-- No template edits, resource grants, visibility changes, or permission bypasses.
-- Economy totals.income/request are per tick; totals.balance is already per second.
-- All production still goes through the game's CanBuild and AddToBuildQueue.
Version = "9.0.25-rc30"

local Balance = Import("AI/mods/AI-Scom/RushBalance.lua")
local Pressure = Import("AI/mods/AI-Scom/RushPressure.lua")
local Bombers = Import("AI/mods/AI-Scom/RushBomberHarassment.lua")
local AirDefense = Import("AI/mods/AI-Scom/RushAirDefense.lua")
local Combat = Import("AI/mods/AI-Scom/RushCombat.lua")
local Frontline = Import("AI/mods/AI-Scom/RushFrontline.lua")
local CombatPolicy = Import("AI/mods/AI-Scom/RushCombatPolicy.lua")
local AF = Import("AI/AIFunctions.lua")
local MG = Import("AI/AIMarkerGenerator.lua")
local TM = Import("AI/AITargetManager.lua")
local Log = Import("AI/debugUtilities.lua").AILog
local Availability = Import("common/units/availableUnits.lua").AvailableUnits
local unpackArgs = table.unpack or unpack
local installed = false
local rosterCache = nil
local factionRosters = {}
local rosterTable = nil
local rosterAt = -100
local Heavy = Import("AI/mods/AI-Scom/RushHeavyConstruction.lua")
local HeavyPolicy = Import("AI/mods/AI-Scom/RushHeavyPolicy.lua")
local Development = Import("AI/mods/AI-Scom/RushDevelopment.lua")
local EconomyPolicy = Import("AI/mods/AI-Scom/RushEconomyPolicy.lua")
local Expansion = Import("AI/mods/AI-Scom/RushExpansion.lua")
local Beachhead = Import("AI/mods/AI-Scom/RushBeachhead.lua")
local Reliability = Import("AI/mods/AI-Scom/RushReliability.lua")
local Layout = Import("AI/mods/AI-Scom/RushBaseLayout.lua")
local NavalConstruction = Import("AI/mods/AI-Scom/RushNavalConstruction.lua")
local NavalCombat = Import("AI/mods/AI-Scom/RushNavalCombat.lua")
local Movement = Import("AI/mods/AI-Scom/RushMovement.lua")
local Health = Import("AI/mods/AI-Scom/RushProductionHealth.lua")
local AdoptBase, EnsureSupervisor
local Orders = Import("host/managers/orders/hostOrderManager.lua")
local ERROR_RETRY = 20
local SENSE_SECONDS = 1
local STRATEGY_SECONDS = 2

local function Now() return GetGameTimeSeconds() end
local function TickRate() return (Constants and Constants.TickRate) or 10 end
local function Ticks(seconds) return math.max(1, math.floor(seconds * TickRate() + 0.5)) end
local function Finite(n) return type(n) == "number" and n == n and math.abs(n) < math.huge end
local Has = Balance.Has
local function Template(id) return __Templates and __Templates.Units and __Templates.Units[id] end
local OwnUnit = Reliability.Own
local function Complete(unit) return unit and unit:IsCompleted() end
local function QueuePresent(unit) return unit.buildQueue and next(unit.buildQueue) ~= nil end
local function Working(unit) return Reliability.Working(unit) end
local function OrderPresent(unit)
    return unit.orders and (unit.orders.activeOrder ~= nil
        or (unit.orders.queuedOrders and next(unit.orders.queuedOrders) ~= nil))
end

local function ProductionCurrent(record)
    local factory,army=record and record.factory,record and record.army
    return factory and OwnUnit(army,factory) and army.ai==record.armyAI and army.ai.isAlive~=false
        and factory.ai==record.unitAI and factory.ai.rushProductionQueue==record
        and factory.platoon==record.platoon and record.platoon.ai==record.platoonAI
        and army:PlatoonExists(record.platoon) and factory.buildQueue==record.queue
end

local function RegisteredProduction(factory)
    local target=factory.unitBeingBuilt
    if factory.productionBehaviorIsActive and OwnUnit(factory.army,target) and not target:IsCompleted()
        and not Reliability.UpgradeTarget(factory) and not factory:GetPause() then
        return Balance.RegisteredBuildRates(factory)
    end
    return 0,0
end

-- This is sampled with the shared census, so a rolling queue credits only
-- the exact factory demand already included in that census's native totals.
local function FactoryFunding(factory)
    local mass,energy=RegisteredProduction(factory)
    mass,energy=mass or 0,energy or 0
    local reserve=factory.army.ai.ecoReserve and factory.army.ai.ecoReserve[factory.id.index]
    local rm,re=0,0
    if reserve then
        local record=reserve.rushProductionQueue
        if record and ProductionCurrent(record) and record.reservation==reserve then
            rm=math.max(0,(reserve.resourcePerSecond or 0)-mass)
            re=math.max(0,(reserve.energyPerSecond or 0)-energy)
        elseif not record and not factory.unitBeingBuilt and not factory.upgradeTarget then
            rm,re=reserve.resourcePerSecond or 0,reserve.energyPerSecond or 0
        end
    end
    local target=factory.unitBeingBuilt or factory.productionBehaviorTargetUnit
    local id=target and target.tpId or factory.buildQueue and factory.buildQueue[1] and factory.buildQueue[1].tpId
    local pm,pe=0,0
    if id and Has(Template(id),"MOBILE") and not Has(Template(id),"ENGINEER") then
        pm,pe=Balance.ProjectRates(factory,id)
    end
    return {mass=mass,energy=energy,reservedMass=rm,reservedEnergy=re,
        productMass=pm or 0,productEnergy=pe or 0,working=Working(factory) and true or false}
end

IsRushArmy = Balance.Enabled

local function State(army)
    local state = army.ai.rushController
    if not state then
        state = { version = Version, errors = {}, retry = {}, idleReservations = {},
            dispatched = 0, submitted = 0, failedChecks = 0,
            productionByRole = {}, pending = {}, lastTelemetry = -100,
            factoryCursor = {}, blockedFactories = {} }
        army.ai.rushController = state
    end
    return state
end

local function Report(army, key, message)
    local state, now = State(army), Now()
    state.failedChecks = state.failedChecks + 1
    if not state.errors[key] or now - state.errors[key] >= 30 then
        state.errors[key] = now
        Log("[RushV9] army=" .. tostring(army.id) .. " " .. key .. ": " .. tostring(message), true)
    end
end

-- Check failures reject only that decision. They never turn a failed check into success.
local function Call(army, key, fn, ...)
    if type(fn) ~= "function" then
        Report(army, key, "required AI function is missing; decision deferred")
        return false, nil
    end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then Report(army, key, a); return false, nil end
    return true, a, b, c, d
end

local function Roles(template)
    local mobile = Has(template, "MOBILE") or Has(template, "SCFA_MOBILE")
    if not mobile or Has(template, "COMMAND") then return nil end
    if HeavyPolicy.IsT4(template) then
        if not HeavyPolicy.IsCombatExperimental(template) then return nil end
        local domain=HeavyPolicy.Domain(template)
        return domain=="naval" and "naval" or domain=="air" and (Has(template,"GUNSHIP") and "gunship" or "bomber") or "frontline"
    end
    if Has(template, "ENGINEER") then return "engineer" end
    if Has(template, "AIR") then
        if Has(template, "SCOUT") then return "airScout" end
        if Has(template, "TRANSPORT") then return nil end -- only explicit specialist plans request transports
        if Bombers.IsNavalAttackAircraft(template) then return "torpedo" end
        if Has(template, "GUNSHIP") then return "gunship" end
        if Has(template, "BOMBER") then return "bomber" end
        if Has(template, "FIGHTER") or Has(template, "ANTI_AIR") then return "fighter" end
        if Has(template, "ANTI_SURFACE") then return "bomber" end
    elseif Has(template, "NAVAL") then
        if Has(template, "SUBMARINE") then return "submarine" end
        if Has(template, "ANTI_AIR") and Has(template, "SCFA_CRUISER") then return "navalAA" end
        if Has(template, "SCOUT") then return "navalScout" end
        if Has(template, "ANTI_SURFACE") or Has(template, "DIRECT_FIRE") or Has(template, "ARTILLERY") then return "naval" end
        if Has(template, "ANTI_NAVAL") or Has(template, "ANTI_NAVY") or Has(template, "SCFA_ANTINAVY") then return "submarine" end
        if Has(template, "ANTI_AIR") then return "navalAA" end
    elseif Has(template, "LAND") or Has(template, "HOVER") or Has(template, "AMPHIBIOUS") then
        if Has(template, "SCOUT") then return "landScout" end
        if Has(template, "ARTILLERY") or Has(template, "INDIRECT_FIRE") then return "artillery" end
        if Has(template, "ANTI_AIR") and not Has(template, "ANTI_SURFACE") then return "mobileAA" end
        if Has(template,"SCFA_CYBRAN") and template.general and template.general.tpId=="ugl1002"
            and Has(template,"TECH1") and Has(template,"BOT") then return "frontline" end
        if Has(template, "TECH1") and (Has(template, "BOT") or Has(template, "RAIDER"))
            and not Has(template, "TANK") then return "raider" end
        if Has(template, "DIRECT_FIRE") or Has(template, "ANTI_SURFACE") or Has(template, "TANK") or Has(template, "BOT") then return "frontline" end
        if Has(template, "SHIELD") then return "shield" end
    end
    return nil
end

local function Tier(template)
    local n = template and template.general and template.general.techNumber
    if Finite(n) then return n end
    for i = 4, 1, -1 do if Has(template, "TECH" .. i) then return i end end
    return 1
end

-- Production reserves a small real amphibious naval cohort; capability comes
-- from the native template, never a faction/name alias or an assumed toggle.
local function AmphibiousShip(template)
    if Roles(template)~="naval" or Tier(template)<2 or Tier(template)>3 then return false end
    local layer=Movement.TemplateMovementLayer(template)
    if layer~="Hover" and layer~="Seabed" then return false end
    for _,weapon in ipairs(template.weapons or {}) do
        if weapon.category~="DeathExplosion" and (weapon.damage or 0)>0 and (weapon.rangeMax or 0)>0 then
            for _,targetLayer in ipairs(weapon.layerTargetLimits or {}) do
                if targetLayer=="Land" then return true end
            end
        end
    end
    return false
end

local function Playable(id, template)
    if not template or not template.general or template.general.tpId ~= id
        or Availability[id] ~= true then return false end
    for _, tag in ipairs({ "DEMO_UI_ONLY", "SCFA_CIVILIAN", "SCFA_UNSELECTABLE", "SCFA_INSIGNIFICANTUNIT" }) do
        if Has(template, tag) then return false end
    end
    return true
end

local function FactoryKind(unit) return Balance.FactoryDomain(unit.tp) end

-- Staffing shares the native and bounded fringe pool used by construction.
local function CountIdleEngineer(snapshot,name,base)
    if not name then return end
    snapshot.engineersIdle=snapshot.engineersIdle+1
    snapshot.idleEngineersByBase[name]=(snapshot.idleEngineersByBase[name] or 0)+1
    snapshot.idleEngineerBases[name]=base
end
local function FactoryIdleEngineers(snapshot,factory)
    local counts=snapshot.idleEngineersByBase
    if not counts then return snapshot.engineersIdle or 0 end
    local name=factory.assignedToBase
    local base=name and factory.army.ai.bases and factory.army.ai.bases[name]
    if not base or not snapshot.idleEngineerBases or snapshot.idleEngineerBases[name]~=base then return 0 end
    return counts[name] or 0
end

local function Roster(factionTag)
    local templates = __Templates.Units
    local now = Now()
    if not rosterCache or rosterTable ~= templates or now < rosterAt or now - rosterAt >= 30 then
        rosterTable, rosterCache, rosterAt, factionRosters = templates, {}, now, {}
        for id, template in pairs(templates) do
            local role = Playable(id, template) and Roles(template)
            if role then rosterCache[#rosterCache + 1] = { id = id, role = role, tier = Tier(template) } end
        end
        table.sort(rosterCache, function(a, b)
            if a.tier ~= b.tier then return a.tier > b.tier end
            return a.id < b.id
        end)
    end
    if not factionTag then return rosterCache end
    local roster = factionRosters[factionTag]
    if not roster then
        roster = {}
        for _, entry in ipairs(rosterCache) do
            if Has(Template(entry.id), factionTag) then roster[#roster + 1] = entry end
        end
        factionRosters[factionTag] = roster
    end
    return roster
end

-- Removes only demonstrably abandoned reservations. Travelling builders and live queues keep theirs.
function ReconcileReservations(army)
    local state, now = State(army), Now()
    if now >= (state.nextRecordCleanup or 0) then
        state.nextRecordCleanup = now + 30
        for key, at in pairs(state.errors) do if now-at >= 30 then state.errors[key]=nil end end
        for key, expires in pairs(state.retry) do if expires <= now then state.retry[key]=nil end end
        for index, expires in pairs(state.blockedFactories) do
            if expires <= now or not OwnUnit(army,army.units[index]) then state.blockedFactories[index]=nil end
        end
        for name in pairs(state.factoryCursor) do
            if not army.ai.bases[name] then state.factoryCursor[name]=nil end
        end
    end
    local remove = {}
    for index in pairs(army.ai.ecoReserve or {}) do
        local unit = army.units[index]
        if not OwnUnit(army, unit) then
            remove[#remove + 1] = index
        elseif not unit.platoon and not Working(unit) and not OrderPresent(unit) then
            state.idleReservations[index] = state.idleReservations[index] or now
            if now - state.idleReservations[index] >= 5 then remove[#remove + 1] = index end
        else
            state.idleReservations[index] = nil
        end
    end
    for _, index in ipairs(remove) do
        local unit = army.units[index]
        if OwnUnit(army, unit) and unit.ai then
            Call(army, "reservation cleanup", AF.ClearReserveEco, army.id, index)
        else
            army.ai.ecoReserve[index] = nil
        end
        state.idleReservations[index] = nil
    end
    for index in pairs(state.idleReservations) do
        if not army.ai.ecoReserve[index] then state.idleReservations[index] = nil end
    end
    if #remove > 0 then
        Log("[RushV9] army=" .. army.id .. " abandonedReservationsReleased=" .. #remove, true)
    end
    return #remove
end

-- RC20: only template-derived role/tier metadata is reused, and only inside
-- this non-yielding Snapshot call. Live unit state, queues and reservations are
-- still read individually. No metadata survives into a later/forced snapshot.
local function AddCount(snapshot, template, count, roleMetadata)
    local info = template and roleMetadata[template]
    if info == nil then
        local role = Roles(template)
        local tier=Tier(template)
        info = role and {role=role, tierKey=role .. ":" .. tier,
            bomberTier=Bombers.IsBomber(template) and tier or nil,amphibiousNaval=AmphibiousShip(template)} or false
        if template then roleMetadata[template] = info end
    end
    if info then
        local role, key = info.role, info.tierKey
        snapshot.roles[role] = (snapshot.roles[role] or 0) + count
        snapshot.tiers[key] = (snapshot.tiers[key] or 0) + count
        if info.amphibiousNaval then snapshot.amphibiousNaval=math.max(0,(snapshot.amphibiousNaval or 0)+count) end
        if info.bomberTier then
            snapshot.actualBombers=snapshot.actualBombers+count
            snapshot.bomberTiers[info.bomberTier]=(snapshot.bomberTiers[info.bomberTier] or 0)+count
        end
        return role
    end
end

-- Beach armies and disconnected home support need separate force counts;
-- resources and the upgrade owner stay shared. Reuse the existing unit scan.
local function BeachCensus(base)
    local s={base=base,roles={},completeRoles={},tiers={},completeTiers={},bomberTiers={},actualBombers=0,
        factories={},completeFactories=0,landFactories=0,airFactories=0,navalFactories=0,
        engineersComplete=0,engineersQueued=0,engineersIdle=0,extractors=0,groundReady=0,
        idleEngineersByBase={},idleEngineerBases={},idleFactoriesByDomain={land=0,air=0,naval=0},advancedCapacity={}}
    Balance.InitSnapshot(s);Development.InitSnapshot(s)
    return s
end
local function BeachCensusForUnit(snapshot,unit)
    local bases=snapshot.beachheadBases
    if not bases or not next(bases) then return nil end
    local pos=unit:GetPosition();local selected,distance
    local economic=Has(unit.tp,"ENGINEER") or Has(unit.tp,"STRUCTURE")
    local assigned=unit.assignedToBase
    local mission=not economic and unit.platoon and unit.platoon.ai and unit.platoon.ai.baseName
    if mission and bases[mission] then return bases[mission] end
    for name,c in pairs(bases) do
        local base=c.base
        local d=(pos.x-base.position.x)^2+(pos.z-base.position.z)^2
        if d<=base.radius^2 and (not economic or not assigned or assigned==name)
            and (not distance or d<distance) then selected,distance=c,d end
    end
    return selected
end
local function LocalCensusForUnit(snapshot,unit)
    local shore=BeachCensusForUnit(snapshot,unit)
    if shore then return shore end
    -- A forward engineer outside its hub is still unavailable at home.
    if snapshot.beachheadBases and snapshot.beachheadBases[unit.assignedToBase] then return nil end
    return snapshot.landSupport
end
local function ObserveBeachUnit(c,unit,metadata,idleBase,idleBaseData)
    Balance.ObserveUnit(c,unit);Development.ObserveUnit(c,unit)
    if not unit.scoCommanderPodOwner and not unit.scoSourcePodOwner then
        local role=AddCount(c,unit.tp,1,metadata)
        if role and Complete(unit) then
            c.completeRoles[role]=(c.completeRoles[role] or 0)+1
            local key=role..":"..Tier(unit.tp)
            c.completeTiers[key]=(c.completeTiers[key] or 0)+1
        end
    end
    if Has(unit.tp,"ALLOYS_EXTRACTION") and Complete(unit) then c.extractors=c.extractors+1 end
    CountIdleEngineer(c,idleBase,idleBaseData)
    local kind=FactoryKind(unit)
    if kind and Complete(unit) then
        c.factories[#c.factories+1]=unit;c.completeFactories=c.completeFactories+1
        c[kind.."Factories"]=c[kind.."Factories"]+1
        if not unit.platoon and not Working(unit) and not OrderPresent(unit) then
            c.idleFactoriesByDomain[kind]=c.idleFactoriesByDomain[kind]+1
        end
    end
end
local function FinishBeachCensus(c)
    c.groundReady=(c.completeRoles.frontline or 0)+(c.completeRoles.raider or 0)+(c.completeRoles.artillery or 0)
    c.engineersComplete=c.completeRoles.engineer or 0
    c.engineersQueued=math.max(0,(c.roles.engineer or 0)-c.engineersComplete)
end
local function CensusView(snapshot,c)
    local view={}
    for key,value in pairs(snapshot) do view[key]=value end
    for _,key in ipairs({"roles","completeRoles","tiers","completeTiers","bomberTiers"}) do
        view[key]={};for name,value in pairs(c[key]) do view[key][name]=value end
    end
    for _,key in ipairs({"factories","completeFactories","landFactories","airFactories","navalFactories",
        "engineersComplete","engineersQueued","engineersIdle","idleEngineersByBase","idleEngineerBases","extractors","groundReady",
        "idleFactoriesByDomain","development","powerComplete","powerPending","factoryPending",
        "balanceEngineers","engineersByTier","landFactoryTiers","actualBombers","amphibiousNaval"}) do view[key]=c[key] end
    view.globalFactories=snapshot.globalFactories or snapshot.factories
    view.globalSnapshot=snapshot.globalSnapshot or snapshot
    view.advancedCapacity={};view.techGroundStrength=nil
    return view
end
function SnapshotForBase(army,snapshot,baseName,factory)
    local existing=snapshot.rushFactoryView
    if existing and existing.rushBeachheadName==baseName
        and Beachhead.BaseConnected(army,baseName,factory) then return existing end
    local c=snapshot.beachheadBases and snapshot.beachheadBases[baseName]
    if not c or army.ai.bases[baseName]~=c.base or not Beachhead.BaseConnected(army,baseName,factory) then return nil end
    local view=CensusView(snapshot,c)
    view.rushBeachheadName=baseName;view.rushBeachheadBase=c.base
    view.landDisconnected=false
    local heat=TM.GetThreatFromHeatMapPosition(army.id,c.base.position,"Land")
    view.localLandThreat=type(heat)=="number" and heat>0
    view.landPanic=view.localLandThreat or snapshot.landPanic
    view.landPressure=view.localLandThreat or snapshot.landPressure
    return view
end
local function SupportView(snapshot)
    local c=snapshot.landSupport
    if not snapshot.landDisconnected or not c then return nil end
    local existing=snapshot.rushFactoryView
    if existing and existing.rushSupportCensus==c then return existing end
    local view=CensusView(snapshot,c)
    view.rushSupportCensus=c;view.landDisconnected=true
    return view
end
function SnapshotForFactory(army,snapshot,factory)
    if not OwnUnit(army,factory) or FactoryKind(factory)~="land" then return nil end
    local name=factory.assignedToBase;local base=name and army.ai.bases[name]
    if not base or base.baseType=="NAVAL" then return nil end
    local shore=SnapshotForBase(army,snapshot,name,factory)
    if shore then return shore end
    if Beachhead.BaseConnected(army,name) then return nil end
    return SupportView(snapshot)
end

function Snapshot(army, force)
    local state, now = State(army), Now()
    if not force and state.snapshot and now >= state.snapshot.time
        and now - state.snapshot.time < SENSE_SECONDS then return state.snapshot end
    local alloy, energy = Balance.Resources(army)
    state.snapshotSerial=(state.snapshotSerial or 0)+1
    local snapshot = { time = now, serial=state.snapshotSerial, roles = {}, completeRoles = {}, completeTiers = {}, tiers = {}, bomberTiers = {}, actualBombers = 0,
        advancedCapacity = {}, beachheadBases = {},
        factories = {}, factoryFunding = {}, idleFactories = 0,
        groundReady = 0, engineersComplete = 0, engineersQueued = 0, landProductionActive = 0,
        completeFactories = 0, landFactories = 0, airFactories = 0, navalFactories = 0,
        idleFactoriesByDomain = {land=0,air=0,naval=0},
        unassignedFactories = 0, pausedFactories = 0,
        unfinishedFactories = 0, navalFactoriesBuilding = 0, airFactoriesBuilding = 0,
        engineersIdle = 0, idleEngineersByBase = {}, idleEngineerBases = {}, extractors = 0, powerBuilding = 0,
        mobileCount = 0, productionActive = 0, upgrades = 0,
        alloy = alloy, energy = energy }
    Balance.InitSnapshot(snapshot)
    Development.InitSnapshot(snapshot)
    snapshot.landDisconnected = Pressure.EnemyLandConnection(army) == false
    for name,base in pairs(army.ai.bases or {}) do
        if Beachhead.BaseConnected(army,name) then snapshot.beachheadBases[name]=BeachCensus(base) end
    end
    if snapshot.landDisconnected and next(snapshot.beachheadBases) then snapshot.landSupport=BeachCensus(nil) end
    local seenTargets, roleMetadata = {}, {}
    for _, unit in pairs(army.units or {}) do
        if OwnUnit(army, unit) then
            seenTargets[unit] = true
            Reliability.ReconcileUpgrade(unit)
            Balance.ObserveUnit(snapshot, unit)
            Development.ObserveUnit(snapshot, unit)
            Layout.ObserveDefenseAsset(snapshot, unit)
            local idleBase,idleBaseData=Expansion.IdleEngineerBase(army,unit)
            -- A proven recruit in the return-radius fringe is still local
            -- construction power for its own beach, never for the home base.
            local beach=idleBase and snapshot.beachheadBases[idleBase]
            if not beach or beach.base~=idleBaseData then beach=LocalCensusForUnit(snapshot,unit) end
            if beach then ObserveBeachUnit(beach,unit,roleMetadata,idleBase,idleBaseData) end
            if not unit.scoCommanderPodOwner and not unit.scoSourcePodOwner then
                local role=AddCount(snapshot, unit.tp, 1, roleMetadata)
                if role and Complete(unit) then
                    snapshot.completeRoles[role]=(snapshot.completeRoles[role] or 0)+1
                    local key=role..":"..Tier(unit.tp)
                    snapshot.completeTiers[key]=(snapshot.completeTiers[key] or 0)+1
                end
            end
            if Has(unit.tp, "MOBILE") or Has(unit.tp, "SCFA_MOBILE") then snapshot.mobileCount = snapshot.mobileCount + 1 end
            CountIdleEngineer(snapshot,idleBase,idleBaseData)
            if Has(unit.tp, "ALLOYS_EXTRACTION") and Complete(unit) then snapshot.extractors = snapshot.extractors + 1 end
            if Has(unit.tp, "STRUCTURE") and Has(unit.tp, "ENERGY_PRODUCTION") and not Complete(unit) then
                snapshot.powerBuilding = snapshot.powerBuilding + 1
            end
            local kind = FactoryKind(unit)
            if kind then
                if Complete(unit) then
                    snapshot.completeFactories = snapshot.completeFactories + 1
                    snapshot[kind .. "Factories"] = snapshot[kind .. "Factories"] + 1
                    snapshot.factories[#snapshot.factories + 1] = unit
                    snapshot.factoryFunding[unit]=FactoryFunding(unit)
                    if not unit.assignedToBase or not army.ai.bases[unit.assignedToBase] then
                        snapshot.unassignedFactories = snapshot.unassignedFactories + 1
                    end
                    if unit.GetPause and unit:GetPause() then snapshot.pausedFactories = snapshot.pausedFactories + 1 end
                    if not unit.platoon and not Working(unit) and not OrderPresent(unit) then
                        snapshot.idleFactories = snapshot.idleFactories + 1
                        snapshot.idleFactoriesByDomain[kind] = snapshot.idleFactoriesByDomain[kind] + 1
                    end
                else
                    snapshot.unfinishedFactories = snapshot.unfinishedFactories + 1
                    if kind == "naval" then snapshot.navalFactoriesBuilding = snapshot.navalFactoriesBuilding + 1 end
                    if kind == "air" then snapshot.airFactoriesBuilding = snapshot.airFactoriesBuilding + 1 end
                end
                if Working(unit) then
                    snapshot.productionActive = snapshot.productionActive + 1
                    if kind=="land" and not Reliability.UpgradeTarget(unit) then
                        snapshot.landProductionActive=snapshot.landProductionActive+1
                    end
                end
                if Reliability.UpgradeTarget(unit) then snapshot.upgrades = snapshot.upgrades + 1 end
            end
        end
    end
    -- Count queued-but-not-spawned products; never count a production target twice.
    for _, factory in ipairs(snapshot.factories) do
        for i, item in ipairs(factory.buildQueue or {}) do
            -- Census can observe native queues created outside this selector.
            -- Older hosts expose count; only exact entryIds authorize mutation.
            local count = type(item.entryIds)=="table" and #item.entryIds
                or Finite(item.count) and math.max(0,math.floor(item.count)) or 0
            local target = factory.unitBeingBuilt or factory.productionBehaviorTargetUnit
            if i == 1 and target and seenTargets[target] and not target:IsCompleted()
                and target.tpId == item.tpId then count = math.max(0, count - 1) end
            if count > 0 then
                AddCount(snapshot,Template(item.tpId),count,roleMetadata)
                local beach=LocalCensusForUnit(snapshot,factory)
                if beach then AddCount(beach,Template(item.tpId),count,roleMetadata) end
            end
        end
    end
    for index, pending in pairs(state.pending) do
        local unit = army.units[index]
        if not OwnUnit(army, unit) or unit ~= pending.factory or now > pending.expires then
            state.pending[index] = nil
        elseif not Working(unit) then
            AddCount(snapshot, Template(pending.id), 1, roleMetadata)
            local beach=LocalCensusForUnit(snapshot,unit)
            if beach then AddCount(beach,Template(pending.id),1,roleMetadata) end
        end
    end
    for index, reserve in pairs(army.ai.ecoReserve or {}) do
        local owner = army.units[index]
        if OwnUnit(army, owner) then
            Balance.ObserveReservation(snapshot,owner,reserve)
            local beach=LocalCensusForUnit(snapshot,owner)
            if beach then Balance.ObserveReservation(beach,owner,reserve) end
        end
    end
    -- A dispatched construction plan claims capacity before its coroutine has
    -- placed a foundation or published the native reservation. Count it once.
    for _, platoon in pairs(army.platoons or {}) do
        local ai = platoon.ai
        local former = ai and ai.formerTable
        local domain = former and former.NeedMobileBuilder and Balance.FormerKind(former)
        if domain and not former.RushBeachhead and not platoon.dead and army:PlatoonExists(platoon) then
            local accounted = OwnUnit(army, ai.buildedUnit) and FactoryKind(ai.buildedUnit) == domain
            for _, builder in ipairs(platoon:GetUnits()) do
                if not accounted and OwnUnit(army,builder) and builder.platoon==platoon then
                    local reserve = army.ai.ecoReserve and army.ai.ecoReserve[builder.id.index]
                    local order = builder.orders and builder.orders.activeOrder
                    accounted = reserve and Balance.FactoryDomain(Template(reserve.tpId))==domain
                    for _, target in pairs({builder.unitBeingBuilt,builder.buildBehaviorActualUnit,
                        order and order.unitGettingBuilt}) do
                        if OwnUnit(army,target) and FactoryKind(target)==domain then accounted=true;break end
                    end
                end
            end
            if not accounted then
                snapshot.factoryPending[domain]=snapshot.factoryPending[domain]+1
                local beach=snapshot.beachheadBases[ai.baseName] or snapshot.landSupport
                if beach then beach.factoryPending[domain]=beach.factoryPending[domain]+1 end
            end
        end
    end
    for _,beach in pairs(snapshot.beachheadBases) do FinishBeachCensus(beach) end
    if snapshot.landSupport then FinishBeachCensus(snapshot.landSupport) end
    snapshot.groundReady=(snapshot.completeRoles.frontline or 0)+(snapshot.completeRoles.raider or 0)+(snapshot.completeRoles.artillery or 0)
    snapshot.engineersComplete=snapshot.completeRoles.engineer or 0
    snapshot.engineersQueued=math.max(0,(snapshot.roles.engineer or 0)-snapshot.engineersComplete)
    local switches = army.ai.strategySwitches or {}
    local function flag(name)
        if type(TM.getTargetManagerStrategyFlag) == "function" then
            local ok, result = Call(army, "sense " .. name, TM.getTargetManagerStrategyFlag, army.id, name)
            if ok then return result == true end
        end
        return switches[name] == true
    end
    snapshot.landPanic = flag("EnemyInLandPanicZone")
    snapshot.airPanic = flag("EnemyInAirPanicZone")
    snapshot.navalPanic = flag("EnemyInNavalPanicZone")
    snapshot.airThreat = snapshot.airPanic or flag("EnemyInAirMilitaryZone") or flag("EnemyHasAirAttackUnits")
    snapshot.navalThreat = snapshot.navalPanic or flag("EnemyHasNavalAttackUnits")
    snapshot.landPressure = snapshot.landPanic or flag("EnemyInLandMilitaryZone")
    snapshot.localLandThreat = snapshot.landDisconnected and snapshot.landPanic
        and Pressure.LocalLandThreat(army) or false
    -- Publish only the same target-manager flags used by the stock strategy brain.
    switches.EnemyInLandPanicZone = snapshot.landPanic
    switches.EnemyInAirPanicZone = snapshot.airPanic
    switches.EnemyInNavalPanicZone = snapshot.navalPanic
    -- Local observation can react before the periodic native strategy flags.
    -- Keep that evidence private; do not manufacture target-manager flags.
    local alarm=Frontline.MainAlarm(army)
    snapshot.mainRaid=alarm.localRaid==true
    snapshot.mainBombardment=alarm.bombardment==true
    if snapshot.mainRaid then
        snapshot.landPanic=true;snapshot.landPressure=true
        if snapshot.landDisconnected and alarm.landRaid then snapshot.localLandThreat=true end
    end
    snapshot.mainShieldPowerNeed=Layout.EmergencyShieldPowerNeed(army,snapshot)
    snapshot.underCap = army:HasUnitCapSpace() and snapshot.mobileCount < 2000
    table.sort(snapshot.factories, function(a, b) return a.id.index < b.id.index end)
    Balance.FinishSnapshot(snapshot)
    AirDefense.Observe(army,snapshot)
    state.snapshot = snapshot
    return snapshot
end

ProductionRates = Balance.ProjectRates

local function TierCount(snapshot,role,tier,complete)
    local counts=snapshot.tiers
    if complete then counts=snapshot.completeTiers end
    local count=0
    for t=tier,4 do count=count+(counts and counts[role..":"..t] or 0) end
    return count
end
local function TechScreenReady(snapshot)
    return EconomyPolicy.GroundTransitionReady(snapshot,2)
end
local function PreserveGroundProduction(snapshot,tier)
    return snapshot.landPressure or snapshot.landPanic
        or not EconomyPolicy.GroundReplacementReady(snapshot,tier+1)
end
local function SavingForTech(snapshot,lease,tier)
    return lease and tier<lease.tier and not Reliability.UpgradeTarget(lease.unit)
        and EconomyPolicy.GroundTransitionReady(snapshot,lease.domain=="land" and lease.tier or 2)
end
local function AdvancedLaunchBudget(snapshot,mass,energy,duration)
    local a,e=snapshot.alloy,snapshot.energy
    if not a or not e or a.income<=0 or e.income<=0
        or not Finite(mass) or not Finite(energy) or not Finite(duration)
        or mass<0 or energy<0 or duration<=0 then return false end
    local horizon=math.max(12,duration*2)
    if a.income*0.75+math.max(0,a.current-a.storage*0.15)/horizon<mass*0.50
        or e.income*0.75+math.max(0,e.current-e.storage*0.15)/horizon<energy*0.50 then return false end
    -- The first advanced order still pays against all real live commitments.
    return a.request+a.reserved+mass*0.50<=a.income*2.0
        and e.request+e.reserved+energy*0.50<=e.income*1.5
end
local function AdvancedFactoryReady(army,factory,tier)
    return OwnUnit(army,factory) and Complete(factory) and Tier(factory.tp)>=tier
        and not factory.isSlaveFactory and not factory.CaptureInProgress and not factory.ReclaimInProgress
        and not Reliability.UpgradeTarget(factory) and not (factory.ai and factory.ai.rushUpgradeId)
        and not (factory.GetPause and factory:GetPause()) and not OrderPresent(factory)
end
local function AdvancedCombatCapacity(army,snapshot,tier)
    -- This is only a production handoff, so an actual usable native combat
    -- menu is required. A paused/captured/engineer-only factory cannot retire
    -- the remaining T1 army. Cache the bounded lookup in the shared census.
    local cache=snapshot.advancedCapacity
    local known=cache and cache[tier]
    if known~=nil then
        return known and FactoryKind(known.factory)=="land" and AdvancedFactoryReady(army,known.factory,tier)
            and CanFactoryBuild(army,known.factory,known.id) or false
    end
    for _,factory in ipairs(snapshot.factories or {}) do
        if FactoryKind(factory)=="land" and AdvancedFactoryReady(army,factory,tier) then
            for _,entry in ipairs(Roster(factory.factionTag)) do
                if entry.tier>=tier and entry.tier<=3 and entry.role=="frontline"
                    and CanFactoryBuild(army,factory,entry.id) then
                    if cache then cache[tier]={factory=factory,id=entry.id} end
                    return true
                end
            end
        end
    end
    if cache then cache[tier]=false end
    return false
end
local function AssaultQueueAllowed(army,snapshot,entry)
    if entry.role~="frontline" and entry.role~="raider" then return true end
    if entry.tier>=3 or PreserveGroundProduction(snapshot,entry.tier)
        or not AdvancedCombatCapacity(army,snapshot,entry.tier+1) then return true end
    -- Retain cheap supporting lines after actual replacements reach the field.
    -- A technology lease never collapses the whole lower-tier army to one head;
    -- T1 orders also cannot consume the separate T2 allowance.
    local limit=math.max(3,math.ceil((snapshot.landFactories or 0)*(entry.tier==1 and 0.50 or 0.65)))
    local queued=0
    for _,role in ipairs({"frontline","raider"}) do
        local key=role..":"..entry.tier
        queued=queued+math.max(0,(snapshot.tiers[key] or 0)
            -(snapshot.completeTiers and snapshot.completeTiers[key] or 0))
    end
    return queued<limit
end

function CanFund(snapshot, factory, id, critical, lease, localCombat)
    if not snapshot.alloy or not snapshot.energy then return false end
    local massRate, energyRate, duration = ProductionRates(factory, id)
    if not massRate then return false end
    local horizon = math.min(12, math.max(4, duration))
    Balance.RefreshInvestment(factory.army,snapshot)
    local techProtected=lease~=nil or snapshot.alloy.techOwner~=nil or snapshot.alloy.commanderOwner~=nil
        or snapshot.alloy.heavyOwner~=nil or (snapshot.upgrades or 0)>0
    local tp=Template(id)
    local role,tier=Roles(tp),Tier(tp)
    local combatSnapshot=localCombat or snapshot
    local core = role=="frontline" or role=="raider" or role=="artillery" or role=="mobileAA"
    local saving=(role=="frontline" or role=="raider") and SavingForTech(snapshot,lease,tier)
    local heavyProtected=snapshot.alloy.heavyOwner~=nil
    if saving then horizon=math.max(30,math.min(90,lease.horizon or 30)) end
    if heavyProtected then horizon=math.max(30,horizon) end
    if role=="fighter" and not Balance.FighterBudget(snapshot,massRate,energyRate,
        snapshot.airPanic or snapshot.airRaid) then return false end
    local function covered(resource, rate)
        local floor = heavyProtected and resource.storage*0.20 or saving and resource.storage*0.15 or critical and 0
            or math.min(resource.storage*0.06,rate*2)
        local available = resource.balance - resource.reserved + math.max(0, resource.current - floor) / horizon
        return available >= rate * 0.90
    end
    if covered(snapshot.alloy,massRate) and covered(snapshot.energy,energyRate) then return true end
    -- Launch one actual newly unlocked frontline unit on a bounded native
    -- supply-limited budget. Old T1 requests must not make a completed T2/T3
    -- factory permanently unusable; queued/paid advanced units close this gate.
    if not techProtected and FactoryKind(factory)=="land" and role=="frontline"
        and tier>=2 and tier<=3 and TierCount(combatSnapshot,role,tier)==0 and TechScreenReady(combatSnapshot)
        and AdvancedLaunchBudget(snapshot,massRate,energyRate,duration) then return true end
    if core and FactoryKind(factory)=="land" and not techProtected
        and (tier>1 or PreserveGroundProduction(combatSnapshot,1))
        and snapshot.alloy.income>0 and snapshot.energy.income>0
        and snapshot.alloy.request+snapshot.alloy.reserved+massRate<=snapshot.alloy.income*2.0
        and snapshot.energy.request+snapshot.energy.reserved+energyRate<=snapshot.energy.income*1.5 then return true end
    -- An active air/engineer/upgrade queue is not an active ground combat line.
    -- Keep bounded inexpensive replacements in production even while an
    -- upgrade is paid. Recovery uses actual requests and queued defenders,
    -- and does not wait for the field army to be nearly wiped out.
    if (critical or EconomyPolicy.AlloyStalled(snapshot) or snapshot.landPressure or techProtected)
        and core and FactoryKind(factory)=="land"
        and EconomyPolicy.CanRecoverGround(combatSnapshot,massRate,energyRate,tier) then return true end
    -- A single paid T1 recovery engineer may coexist with an active army line.
    -- Queued/pending engineers are counted, so several factories cannot all
    -- take this exception before the first replacement reaches the field.
    if critical and role=="engineer" and FactoryKind(factory)=="land"
        and EconomyPolicy.CanRecoverEngineer(combatSnapshot,massRate,energyRate,Tier(Template(id)),
            FactoryIdleEngineers(combatSnapshot,factory)) then return true end
    if critical and role=="fighter" and FactoryKind(factory)=="air"
        and AirDefense.CanFundInterceptor(snapshot,massRate,energyRate,Tier(Template(id))) then return true end
    -- A single cheap recovery line may run supply-limited; never idle every factory
    -- merely because an army with positive income cannot fund full-speed production.
    return not techProtected and critical and snapshot.productionActive == 0 and snapshot.alloy.income > 0
        and snapshot.energy.income > 0 and massRate <= math.max(3, snapshot.alloy.income * 1.5)
        and energyRate <= math.max(30, snapshot.energy.income * 1.5)
end

local function GunshipPriority(snapshot,tier)
    if tier<1 or tier>3 then return nil end
    local goal=math.max(2,math.ceil(Bombers.BomberGoal(snapshot)*0.5))
    local count=snapshot.roles.gunship or 0
    -- Higher tiers cover lower-tier requests. Old T1 gunships must not block
    -- a native T2/T3 alternative when a faction has no bomber at that tier.
    if count<2 then return 930 end
    for needed=tier,2,-1 do
        local advanced=0
        for t=needed,3 do advanced=advanced+(snapshot.tiers["gunship:"..t] or 0) end
        if advanced<math.max(2,math.ceil(goal/needed)) then return 790+needed*20 end
    end
    if count<goal then return 560 end
    return nil
end

local function AdvancedCombatPriority(snapshot,kind,entry,priority)
    local tier,role=entry.tier,entry.role
    if tier<2 or tier>3 then return priority end
    if kind=="land" and snapshot.landDisconnected and not snapshot.localLandThreat then return priority end
    if kind=="naval" and (not snapshot.alloy or not snapshot.energy
        or snapshot.alloy.income<=0 or snapshot.energy.income<=0) then return priority end
    local r=snapshot.roles
    local score,critical
    if kind=="land" then
        local front=(r.frontline or 0)+(r.raider or 0)
        if role=="frontline" then
            local goal=math.max(tier==3 and 3 or 4,
                math.min(tier==3 and 24 or 32,math.ceil(front*(tier==3 and 0.45 or 0.60))))
            -- A generic T1 raider score must never keep an advanced factory
            -- making assault bots once its real frontline menu is affordable.
            score=TierCount(snapshot,role,tier)<goal and 890+tier*5 or 550+tier*25
        elseif role=="artillery" and front>=4 then
            local goal=math.max(1,math.min(tier==3 and 8 or 10,math.ceil(front*(tier==3 and 0.08 or 0.12))))
            if TierCount(snapshot,role,tier)<goal then score=770+tier*5 end
        elseif role=="mobileAA" and (front>=6 or snapshot.airThreat) then
            local share=snapshot.airThreat and 0.16 or 0.08
            local goal=math.max(1,math.min(tier==3 and 6 or 8,math.ceil(front*share/(tier==3 and 1.5 or 1))))
            if TierCount(snapshot,role,tier)<goal then
                score=snapshot.airPanic and 960 or 730+tier*5
                critical=snapshot.airPanic
            end
        end
    elseif kind=="naval" then
        local ships=(r.naval or 0)+(r.submarine or 0)+(r.navalAA or 0)
        if role=="naval" then
            local goal=math.max(2,math.min(12,math.ceil(ships*(tier==3 and 0.45 or 0.60))))
            score=TierCount(snapshot,role,tier)<goal and 890+tier*5 or 550+tier*25
        elseif role=="submarine" and ships>=2 then
            local goal=math.max(1,math.min(4,math.ceil(ships*(snapshot.navalThreat and 0.20 or 0.12))))
            if TierCount(snapshot,role,tier)<goal then score=(snapshot.navalThreat and 930 or 760)+tier*5 end
        elseif role=="navalAA" and snapshot.airThreat and ships>=3 then
            if TierCount(snapshot,role,tier)<math.max(1,math.min(4,math.ceil(ships*0.15))) then
                score=snapshot.airPanic and 960 or 930+tier*5
                critical=snapshot.airPanic
            end
        end
    elseif kind=="air" and role=="fighter" then
        local strike=(r.bomber or 0)+(r.gunship or 0)
        if strike>=2 or snapshot.airThreat then
            local goal=math.max(2,math.min(Balance.Config.FighterMinimum,math.ceil(strike*0.25)))
            if TierCount(snapshot,role,tier)<goal then
                score=snapshot.airRaid and 1040 or 780+tier*20
                critical=snapshot.airRaid or snapshot.airPanic
            end
        end
    end
    if score and (not priority or score>priority.score) then
        return {score=score,critical=critical==true or priority and priority.critical==true}
    end
    return priority
end

function RolePriority(army, snapshot, kind, engineersIdle)
    engineersIdle=engineersIdle or snapshot.engineersIdle or 0
    local roles = snapshot.roles
    local front = (roles.frontline or 0) + (roles.raider or 0)
    local engineers = roles.engineer or 0
    local pressure = snapshot.landPanic or snapshot.airPanic or snapshot.navalPanic
    local priorities = {}
    local function want(role, score, critical) priorities[role] = { score = score, critical = critical == true } end
    if kind == "land" then
        local engineerGoal = math.min(60, math.max(6, math.ceil(snapshot.extractors * 0.65 + snapshot.completeFactories * 1.8)))
        local recoveryFloor = EconomyPolicy.EngineerFloor(snapshot)
        -- Rebuild a damaged economy even while emergency flags remain set.
        if engineers < recoveryFloor and engineersIdle < 2
            and (snapshot.engineersQueued or 0)==0 then want("engineer", 1000, true)
        elseif engineers < engineerGoal and engineersIdle < 3
            and not EconomyPolicy.AlloyStalled(snapshot)
            and (snapshot.landDisconnected or front >= math.max(2, (engineers - 3)))
            and (snapshot.engineersQueued or 0)==0 then want("engineer", 720) end
        -- Tier advancement requires actual tier-appropriate construction power.
        local minimumFront = math.min(24,math.max(6,snapshot.landFactories*3))
        local strongFront = front >= minimumFront
        local recoveringFront=EconomyPolicy.GroundReady(snapshot)<EconomyPolicy.GroundFloor(snapshot)
        if (snapshot.landDisconnected or front >= 4 and (strongFront or not snapshot.landPanic))
            and EconomyPolicy.CanStartTech(army,snapshot) then
            priorities.advancedEngineer = { score = strongFront and 840 or 650, critical = engineers < recoveryFloor }
        end
        -- One land factory remains available for construction engineers.
        if snapshot.landDisconnected and not snapshot.localLandThreat then return priorities end
        local tankDeficit = (army.faction==1 or army.faction==3) and (roles.frontline or 0)<math.max(3,math.ceil(front*0.65))
        local combatRecovery = front<minimumFront and (engineers>=2 or (snapshot.engineersQueued or 0)>0)
        want("frontline", combatRecovery and 880 or tankDeficit and 735 or 500,
            recoveringFront or snapshot.landPanic)
        -- Light raiders complement, rather than replace, the sustained combat line.
        local raiderGoal = math.max(1, math.floor(front * 0.25))
        local raiderScore
        if army.faction==1 then
            raiderScore = combatRecovery and 875 or (roles.raider or 0)<raiderGoal and 515 or 470
        elseif army.faction==3 then
            raiderScore = tankDeficit and 440 or 515
        else
            raiderScore = combatRecovery and 875 or (roles.raider or 0)<raiderGoal and 515 or 470
        end
        want("raider", raiderScore,
            recoveringFront or snapshot.landPanic)
        if (roles.landScout or 0) < 1 and engineers >= 2 and front >= 1 and not pressure then want("landScout", 800) end
        local aaGoal = snapshot.airThreat and math.max(2, math.ceil(front * 0.22)) or math.floor(front * 0.12)
        if snapshot.airPanic then aaGoal = math.max(3, aaGoal) end
        if (roles.mobileAA or 0) < aaGoal then want("mobileAA", snapshot.airPanic and 960 or 680, snapshot.airPanic) end
        local siege = army.ai.rushCombat and Now() < (army.ai.rushCombat.siegeUntil or 0)
        local artilleryGoal = front >= 4 and math.max(1, math.floor(front * (siege and 0.30 or 0.18))) or 0
        if (roles.artillery or 0) < artilleryGoal then want("artillery", siege and 740 or 640) end
        if Frontline.Active(army) and front>=8 then
            -- An observed wall calls for a real paid counter, not another batch
            -- of cheap direct-fire units that make the same failed approach.
            local needed=math.min(Frontline.Config.BatteryLimit*Frontline.Config.BatteryInstances,math.max(4,math.ceil(front*0.35)))
            if (roles.artillery or 0)<needed then want("artillery",930,snapshot.landPanic) end
        end
        if front >= 12 and (roles.shield or 0) < math.floor(front / 12)
            and snapshot.energy and snapshot.energy.ratio >= 0.50
            and snapshot.energy.balance >= math.max(30, snapshot.energy.income * 0.12) then want("shield", 620) end
    elseif kind == "air" then
        local ground = (roles.bomber or 0) + (roles.gunship or 0)
        local factories=snapshot.development and snapshot.development.factory or {}
        local mature=(factories.air2 or 0)+(factories.air3 or 0)>0
        local observed=snapshot.airCombatCount or 0
        local counterGoal=observed>0 and math.min(24,math.ceil(observed*1.25)) or 0
        local fighterGoal=math.max(Balance.Config.OpeningFighters,math.ceil(ground*0.25),counterGoal,
            snapshot.airRaid and (snapshot.airRaidFighters or 0) or 0,
            mature and Balance.Config.FighterMinimum or 0)
        local fighters=roles.fighter or 0
        local localCombat=snapshot.airPanic and (snapshot.localAirCombatCount or 0)>0
        if (roles.airScout or 0)<1 and not pressure then want("airScout",780) end
        if fighters<fighterGoal then
            -- Establish a small usable screen, then launch strike aircraft.
            -- Mature coverage still reaches the six-fighter T3 safety gate.
            local score=localCombat and 990 or fighters<Balance.Config.OpeningFighters and 980
                or fighters<counterGoal and 920 or mature and ground>=2 and 870 or 740
            want("fighter",score,localCombat)
        end
        -- Nonstandard attack-air products keep their existing bounded role
        -- demand; only actual bomber candidates receive tier-specific requests.
        local bomberCount=roles.bomber or 0
        local bomberPriority=bomberCount<Bombers.Config.WingInstances
            and (bomberCount<2 and 940 or bomberCount<Bombers.BomberGoal(snapshot) and 710 or 480)
        if bomberPriority then want("bomber", bomberPriority, snapshot.landPanic) end
        want("gunship",560,snapshot.landPanic) -- each native candidate gets its tier-specific request below
        if snapshot.navalThreat and (roles.torpedo or 0) < math.max(2, ground * 0.4) then want("torpedo", 750, snapshot.navalPanic) end
        if snapshot.airRaid and (roles.fighter or 0)<math.max(2,snapshot.airRaidFighters or 0) then
            want("fighter",1040,true)
        end
    elseif kind == "naval" then
        -- A completed shipyard can produce immediately. CanFactoryBuild and
        -- CanFund still validate every product against the live native template,
        -- build permissions, income, storage and existing reservations.
        -- Never park a working naval opening behind a second time/economy gate.
        if not snapshot.alloy or not snapshot.energy
            or snapshot.alloy.income <= 0 or snapshot.energy.income <= 0 then return priorities end
        local ships = (roles.naval or 0) + (roles.submarine or 0) + (roles.navalAA or 0)
        want("naval", 500, snapshot.navalPanic or ships < 2)
        local submarineGoal = snapshot.navalThreat and math.max(2, math.ceil(ships * 0.30))
            or ships >= 2 and math.max(1, math.floor(ships * 0.20)) or 0
        want("submarine", (roles.submarine or 0) < submarineGoal
            and (snapshot.navalThreat and 935 or 545) or 480, snapshot.navalPanic)
        -- A required counter stays eligible even when the native menu has only
        -- a lower-tier version; advanced surface production cannot bury it.
        if snapshot.airThreat and (roles.navalAA or 0) < math.max(1, math.ceil(ships / 4)) then want("navalAA", 945, snapshot.airPanic) end
    end
    return priorities
end

function CanFactoryBuild(army, factory, id)
    local template = Template(id)
    if not HeavyPolicy.AllowsTarget(army,id) or not Playable(id, template) or not factory.tp or not factory.tp.construction
        or not factory.tp.construction.canBuild or not factory.factionTag
        or not Has(template, factory.factionTag) then return false end
    local ok, allowed = Call(army, "CanBuild " .. factory.tpId .. " -> " .. id,
        buildQueueUtils and buildQueueUtils.CanBuild, factory, id, 1, false)
    return ok and allowed == true
end

function SelectProduct(army, factory, snapshot, production)
    local continuing=production and ProductionCurrent(production)
    if not OwnUnit(army, factory) or not Complete(factory)
        or not continuing and (factory.platoon or Working(factory) or State(army).pending[factory.id.index])
        or production and not continuing or Reliability.UpgradeTarget(factory) or factory.isSlaveFactory
        or OrderPresent(factory) or factory.CaptureInProgress or factory.ReclaimInProgress
        or not snapshot.underCap then return nil end
    local kind = FactoryKind(factory)
    if not kind then return nil end
    local localCombat=kind=="land" and SnapshotForFactory(army,snapshot,factory)
    local combatSnapshot=localCombat or snapshot
    local layers = army.ai.settings.useLayer
    local layerEnabled=localCombat and localCombat.rushBeachheadBase~=nil
        or not layers or layers[kind=="naval" and "water" or kind]==true
    local supportLand=kind=="land" and snapshot.landDisconnected
    if not layerEnabled and not supportLand then return nil end
    local lease=Development.TechCommitment(army)
    if lease and lease.unit==factory then return nil end
    if factory.GetPause and factory:GetPause() then return nil end
    local engineer
    if not EconomyPolicy.AlloyStalled(snapshot) and not EconomyPolicy.NeedsGroundRecovery(army,combatSnapshot)
        and (not localCombat or not localCombat.rushBeachheadBase
            or EconomyPolicy.GroundReady(localCombat)>=EconomyPolicy.GroundFloor(localCombat)) then
        engineer = Heavy.EngineerProduct(army, factory, snapshot)
    end
    if engineer and CanFactoryBuild(army, factory, engineer) and snapshot.alloy and snapshot.energy
        and snapshot.alloy.income > 0 and snapshot.energy.income > 0 then
        -- One finite, legal T2/T3 engineer order may run supply-limited. Waiting
        -- for spare full-speed income here can deadlock the tech/economy chain.
        return engineer, "engineer",850,false
    end
    local priorities = RolePriority(army,combatSnapshot,kind,FactoryIdleEngineers(combatSnapshot,factory))
    local roster = Roster(factory.factionTag)
    do
        local bootstrap,bootstrapTier,bootstrapDuration=nil,0,math.huge
        for _,entry in ipairs(roster) do
            if entry.role=="engineer" and EconomyPolicy.NeedsTechEngineer(combatSnapshot,entry.tier)
                and CanFactoryBuild(army,factory,entry.id) then
                local mass,energy,duration=ProductionRates(factory,entry.id)
                if mass and (CanFund(snapshot,factory,entry.id,false,lease,localCombat)
                    or EconomyPolicy.CanRecoverTechEngineer(combatSnapshot,mass,energy,entry.tier))
                    and (entry.tier>bootstrapTier or entry.tier==bootstrapTier and duration<bootstrapDuration) then
                    bootstrap,bootstrapTier,bootstrapDuration=entry.id,entry.tier,duration
                end
            end
        end
        if bootstrap then return bootstrap,"engineer",1000,false end
    end
    if not layerEnabled then
        for role in pairs(priorities) do
            if role~="engineer" and role~="advancedEngineer" then priorities[role]=nil end
        end
    end
    local selected, bestScore, bestTier, bestDuration, bestCritical = nil, -1, -1, math.huge, false
    for _, entry in ipairs(roster) do
        local priority = priorities[entry.role]
        if layerEnabled and entry.role=="bomber" then
            if Bombers.IsNavalAttackAircraft(Template(entry.id)) then
                -- Recheck cached roster entries too: torpedoes never inherit
                -- the generic first-bomber priority or ground-strike budget.
                priority=nil
            elseif Bombers.IsBomber(Template(entry.id)) then
                local score=Bombers.BomberPriority(snapshot,entry.tier)
                local response=Bombers.ResponsePriority(army,snapshot,Template(entry.id))
                if response then score=math.max(score or 0,response) end
                priority=score and {score=score,critical=snapshot.landPanic or response~=nil} or nil
            end
        elseif layerEnabled and entry.role=="gunship" then
            local score=not Bombers.IsNavalAttackAircraft(Template(entry.id)) and GunshipPriority(snapshot,entry.tier)
            priority=score and {score=score,critical=snapshot.landPanic} or nil
        end
        if layerEnabled then priority=AdvancedCombatPriority(combatSnapshot,kind,entry,priority) end
        if layerEnabled and kind=="naval" and priority and not snapshot.navalPanic and not snapshot.airPanic
            and (snapshot.landDisconnected or snapshot.landPanic or next(snapshot.beachheadBases or {}))
            and AmphibiousShip(Template(entry.id)) then
            local goal=math.max(2,math.min(6,math.ceil((snapshot.roles.naval or 0)*0.30)))
            if (snapshot.amphibiousNaval or 0)<goal then
                -- Native costs, queues and tech reserves still apply. Urgent
                -- anti-submarine and AA demand stays above this bounded cohort.
                priority={score=math.max(priority.score,915+entry.tier*5),critical=priority.critical}
            end
        end
        -- Economic recovery must not silently prefer an expensive T2/T3 engineer
        -- merely because the ordinary engineer priority is shared by all tiers.
        if entry.role=="engineer" and entry.tier>1 and priority and priority.critical then
            priority={score=priority.score-200,critical=priority.critical}
        end
        if entry.role == "engineer" and entry.tier > 1 and priorities.advancedEngineer
            and (not priority or priority.score < priorities.advancedEngineer.score)
            and (combatSnapshot.tiers["engineer:" .. entry.tier] or 0)
                < (entry.tier == 3 and math.min(6, 2 + math.floor(snapshot.completeFactories / 6)) or 3) then
            priority = priorities.advancedEngineer
        end
        if priority and priority.score >= bestScore
            and (kind~="land" or AssaultQueueAllowed(army,combatSnapshot,entry))
            and CanFactoryBuild(army,factory,entry.id)
            and CanFund(snapshot,factory,entry.id,priority.critical,lease,localCombat) then
            local _, _, duration = ProductionRates(factory, entry.id)
            if priority.score > bestScore or entry.tier > bestTier
                or (entry.tier == bestTier and duration < bestDuration)
                or (entry.tier == bestTier and duration == bestDuration and (not selected or entry.id < selected.id)) then
                selected, bestScore, bestTier, bestDuration = entry, priority.score, entry.tier, duration
                bestCritical=priority.critical
            end
        end
    end
    return selected and selected.id, selected and selected.role, bestScore, bestCritical
end

local function ReleaseReservation(army, factory, reservation)
    if reservation and army.ai.ecoReserve and army.ai.ecoReserve[factory.id.index] == reservation then
        Call(army, "production reservation", AF.ClearReserveEco, army.id, factory.id.index)
    end
end

-- Only this assignment's native entry IDs are mutable. Never touch the
-- first native group: it can already own a paid product or merged repeats.
local function OwnedProductionQueue(record)
    if not ProductionCurrent(record) then return nil end
    local present,count=record.seen or {},0
    record.seen=present
    for entry in pairs(present) do present[entry]=nil end
    for _,item in ipairs(record.queue) do
        if type(item.entryIds)~="table" or #item.entryIds<1 then return nil end
        for _,entry in ipairs(item.entryIds) do
            if record.entries[entry]~=item.tpId or present[entry] then return nil end
            present[entry]=item.tpId;count=count+1
            if count>3 then return nil end
        end
    end
    for entry in pairs(record.entries) do
        if not present[entry] then record.entries[entry]=nil end
    end
    return count
end

local function QueueCount(snapshot,id,delta,factory)
    AddCount(snapshot,Template(id),delta,{})
    snapshot.engineersQueued=math.max(0,(snapshot.roles.engineer or 0)-snapshot.engineersComplete)
    local localCombat=snapshot.rushFactoryView
        or factory and LocalCensusForUnit(snapshot,factory)
    if localCombat then
        AddCount(localCombat,Template(id),delta,{})
        localCombat.engineersQueued=math.max(0,(localCombat.roles.engineer or 0)-localCombat.engineersComplete)
    end
end

local function ProductionTarget(factory)
    local target=factory.unitBeingBuilt or factory.productionBehaviorTargetUnit
    if OwnUnit(factory.army,target) and not target:IsCompleted() then return target end
end

local function QueueBudget(record,snapshot)
    if not ProductionCurrent(record) then return false end
    local factory,army=record.factory,record.army
    local mass,energy,id=0,0,nil
    local target=ProductionTarget(factory)
    if target then
        mass,energy=ProductionRates(factory,target.tpId)
        mass,energy,id=mass or 0,energy or 0,target.tpId
    end
    for _,item in ipairs(record.queue) do
        local m,e=ProductionRates(factory,item.tpId)
        if not m then return false end
        mass,energy=math.max(mass,m),math.max(energy,e)
        id=id or item.tpId
    end
    local current=army.ai.ecoReserve and army.ai.ecoReserve[factory.id.index]
    if current and current~=record.reservation then return false end
    if id then
        if not record.reservation then
            AF.SetReserveEco(army.id,factory.id.index,id,factory:GetPosition())
            record.reservation=army.ai.ecoReserve and army.ai.ecoReserve[factory.id.index]
            if not record.reservation then return false end
        end
        local reserve=record.reservation
        reserve.rushProductionQueue=record
        reserve.tpId=id
        reserve.resourcePerSecond,reserve.energyPerSecond=mass,energy
    else
        ReleaseReservation(army,factory,record.reservation)
        record.reservation=nil
    end
    -- Queue changes update the shared census in place. Do not force a full
    -- army scan per factory or price three serial products as three factories.
    local funding=snapshot and snapshot.factoryFunding[factory]
    if funding and snapshot.alloy and snapshot.energy then
        local rm=id and math.max(0,mass-funding.mass) or 0
        local re=id and math.max(0,energy-funding.energy) or 0
        snapshot.alloy.reserved=math.max(0,snapshot.alloy.reserved+rm-funding.reservedMass)
        snapshot.energy.reserved=math.max(0,snapshot.energy.reserved+re-funding.reservedEnergy)
        funding.reservedMass,funding.reservedEnergy=rm,re
        local live=FactoryFunding(factory)
        snapshot.productAlloyRate=math.max(0,snapshot.productAlloyRate+live.productMass-funding.productMass)
        snapshot.productEnergyRate=math.max(0,snapshot.productEnergyRate+live.productEnergy-funding.productEnergy)
        funding.productMass,funding.productEnergy=live.productMass,live.productEnergy
        if live.working~=funding.working then
            local delta=live.working and 1 or -1
            snapshot.productionActive=math.max(0,snapshot.productionActive+delta)
            if FactoryKind(factory)=="land" then
                snapshot.landProductionActive=math.max(0,snapshot.landProductionActive+delta)
            end
            funding.working=live.working
        end
    end
    Balance.RefreshInvestment(army,snapshot)
    return true
end

local function ProductionView(record,snapshot)
    local view={}
    for key,value in pairs(snapshot) do view[key]=value end
    for _,key in ipairs({"roles","tiers","bomberTiers","alloy","energy"}) do
        if snapshot[key] then
            view[key]={}
            for name,value in pairs(snapshot[key]) do view[key][name]=value end
        end
    end
    local funding=snapshot.factoryFunding[record.factory]
    if not funding or not view.alloy or not view.energy then return nil end
    view.rushFactoryView=SnapshotForFactory(record.army,view,record.factory)
    view.alloy.balance=view.alloy.balance+funding.mass
    view.energy.balance=view.energy.balance+funding.energy
    view.alloy.request=math.max(0,view.alloy.request-funding.mass)
    view.energy.request=math.max(0,view.energy.request-funding.energy)
    view.alloy.reserved=math.max(0,view.alloy.reserved-funding.reservedMass)
    view.energy.reserved=math.max(0,view.energy.reserved-funding.reservedEnergy)
    view.productAlloyRate=math.max(0,view.productAlloyRate-funding.productMass)
    view.productEnergyRate=math.max(0,view.productEnergyRate-funding.productEnergy)
    -- Re-evaluate only unpaid successors. The protected head and real units
    -- stay in every role goal, including fighter, engineer and bomber tiers.
    for i=2,#record.queue do
        local item=record.queue[i]
        QueueCount(view,item.tpId,-#item.entryIds)
    end
    return view
end

local function TrimProductionTail(record,keep,snapshot)
    if keep<1 or not OwnedProductionQueue(record) then return false end
    if #record.queue<=keep then return true end
    local factory,head=record.factory,record.queue[1]
    if type(factory.SendUpdateBuildQueueCommand)~="function" then return false end
    -- Native queue removal only cancels production when the head changes.
    -- Every removed group is ours, still buildable, and strictly after it.
    local removed={}
    for i=#record.queue,keep+1,-1 do removed[#removed+1]=table.remove(record.queue,i) end
    local ok,err=pcall(factory.SendUpdateBuildQueueCommand,factory)
    if not ok then
        for i=#removed,1,-1 do record.queue[#record.queue+1]=removed[i] end
        Report(record.army,"production queue sync",err)
        return false
    end
    if not ProductionCurrent(record) or record.queue[1]~=head then return false end
    for _,item in ipairs(removed) do
        for _,entry in ipairs(item.entryIds) do record.entries[entry]=nil end
        QueueCount(snapshot,item.tpId,-#item.entryIds,record.factory)
    end
    return true
end

local function AppendProduction(record,id,role,snapshot)
    local factory,army=record.factory,record.army
    local count=OwnedProductionQueue(record)
    if not count or count>=3 or not CanFactoryBuild(army,factory,id) then return false end
    local last=record.queue[#record.queue]
    -- Repeats merge into the protected head in the native engine. Refill a
    -- homogeneous line at completion during roll-off instead of locking an
    -- urgent fighter/upgrade behind several inseparable copies of a tank.
    if last and last.tpId==id then return false end
    local entries=buildQueueUtils.NewEntryIds(1)
    if type(entries)~="table" or #entries~=1 or record.entries[entries[1]] then return false end
    record.entries[entries[1]]=id
    buildQueueUtils.AddToBuildQueue(factory,id,entries)
    local after=OwnedProductionQueue(record)
    if not after or not record.entries[entries[1]] then return false end
    QueueCount(snapshot,id,1,record.factory)
    if not QueueBudget(record,snapshot) then return false end
    local state=State(army)
    state.submitted=state.submitted+1
    state.productionByRole[role]=(state.productionByRole[role] or 0)+1
    return true
end

local function RefillProduction(record,snapshot)
    local factory=record.factory
    local count=OwnedProductionQueue(record)
    if not count then return false end
    -- Some hosts expose a live product after consuming its entry. Wait for
    -- that product to finish instead of mistaking an empty queue for idle.
    if count==0 and ProductionTarget(factory) then return QueueBudget(record,snapshot) end
    local view=ProductionView(record,snapshot)
    if not view then return false end
    local head=record.queue[1]
    local protected=head and #head.entryIds or 0
    local desired,last={},head and head.tpId
    local limit=type(factory.SendUpdateBuildQueueCommand)=="function" and 3 or 1
    local target=ProductionTarget(factory)
    if target and head and target.tpId~=head.tpId then limit=limit-1 end
    for _=protected+1,limit do
        local id,role=SelectProduct(record.army,factory,view,record)
        if not id or id==last then break end
        desired[#desired+1]={id=id,role=role}
        QueueCount(view,id,1)
        last=id
    end
    local keep=head and 1 or 0
    local kept=0
    for _,choice in ipairs(desired) do
        local item=record.queue[keep+1]
        if not item or item.tpId~=choice.id or #item.entryIds~=1 then break end
        keep,kept=keep+1,kept+1
    end
    if head and not TrimProductionTail(record,keep,snapshot) then return false end
    for i=kept+1,#desired do
        local choice=desired[i]
        if not AppendProduction(record,choice.id,choice.role,snapshot) then return false end
    end
    return QueueBudget(record,snapshot)
end

-- Persistent ownership bridges product completion and native roll-off. The
-- existing five-Hz watcher stays cheap; selection reuses the one-second census
-- and runs early only when the native head actually changes or becomes empty.
function PlanProduction(platoon, armyIndex, baseName, former)
    local army = Armies[armyIndex]
    if not army or not army.ai or army.ai.isAlive == false then return end
    local factory=former.RushFactory
    local state=State(army)
    local pending,index=former.RushPending,factory and factory.id and factory.id.index
    local function releasePending()
        if index and state.pending[index]==pending then state.pending[index]=nil end
    end
    platoon.ai={formerTable=former,baseName=baseName,creationTime=GetFormatedGameTime(),eState="Validate"}
    if not pending or state.pending[index]~=pending or Now()>pending.expires
        or not OwnUnit(army,factory) or factory.platoon or Working(factory) or OrderPresent(factory)
        or factory.CaptureInProgress or factory.ReclaimInProgress or factory.isSlaveFactory
        or not CanFactoryBuild(army,factory,former.RushProduct) then
        releasePending();army:DisbandPlatoon(platoon);return
    end
    factory.ai=factory.ai or {}
    platoon:AssignUnits({factory})
    local record={factory=factory,army=army,armyAI=army.ai,platoon=platoon,platoonAI=platoon.ai,
        unitAI=factory.ai,queue=factory.buildQueue,entries={}}
    factory.ai.rushProductionQueue=record
    releasePending()
    state.snapshot=nil
    local ok,err=pcall(function()
        if factory.GetRepeatBuild and factory:GetRepeatBuild() then factory:SetRepeatBuild(false) end
        record.platoonAI.eState="Producing"
        while ProductionCurrent(record) do
            record.platoonAI.rushProductionHeartbeat=Now()
            if factory.CaptureInProgress or factory.ReclaimInProgress or factory.isSlaveFactory
                or OrderPresent(factory) or Reliability.UpgradeTarget(factory) then break end
            local count=OwnedProductionQueue(record)
            if not count then break end
            if not factory:GetPause() then
                local snapshot=Snapshot(army)
                if record.snapshotSerial~=snapshot.serial or record.head~=record.queue[1] or count==0 then
                    if not RefillProduction(record,snapshot) then break end
                    record.snapshotSerial,record.head=snapshot.serial,record.queue[1]
                end
            end
            if not Working(factory) then break end
            WaitTicks(Ticks(0.2))
        end
    end)
    releasePending()
    if OwnUnit(army,factory) and factory.ai==record.unitAI then
        ReleaseReservation(army,factory,record.reservation)
        if factory.ai.rushProductionQueue==record then factory.ai.rushProductionQueue=nil end
        if factory.platoon==platoon and platoon.ai==record.platoonAI then
            factory.ai.eState=nil
            platoon:OnUnitRemoved(factory)
        end
    end
    if not ok then
        state.blockedFactories[index]=Now()+5
        Report(army,"production "..tostring(former.RushProduct),err)
    end
    if army:PlatoonExists(platoon) and platoon.ai==record.platoonAI then army:DisbandPlatoon(platoon) end
    state.snapshot=nil
end

local function Enabled(settings, entry, beachhead)
    if entry.AIdifficulty and entry.AIdifficulty[settings.difficulty] ~= true then return false end
    if entry.AIbehavior and settings.behavior and entry.AIbehavior[settings.behavior] ~= true then return false end
    if entry.AIlayer and settings.useLayer then
        local match = beachhead and entry.AIlayer.land==true or false
        for layer, enabled in pairs(settings.useLayer) do if enabled and entry.AIlayer[layer] then match = true end end
        if not match then return false end
    end
    return true
end


-- Missing optional zero-maintenance tables must not throw or force every faction
-- to use the highest maintenance requirement of another faction's template.
local function MaintenanceAffordable(army, baseName, former)
    local snapshot=Snapshot(army)
    if not snapshot.energy then return false end
    local faction=({"EDA","CHOSEN","GUARD","SERAPHIM"})[army.faction]
    local total,found=0,false
    for _,line in ipairs(former.WantStructures or {}) do
        local maximum=0
        for id in pairs(line) do
            local tp=Template(id)
            if tp and Has(tp,faction) then
                found=true
                maximum=math.max(maximum, (tp.economy and tp.economy.maintenanceConsumption or {}).energy or 0)
            end
        end
        total=total+maximum
    end
    for _,line in ipairs(former.NeedUpgradeableUnit or {}) do
        local maximum=0
        for id in pairs(line[1] or {}) do
            local old=Template(id)
            local tp=old and old.construction and Template(old.construction.upgradesTo)
            if tp and Has(tp,faction) then
                found=true
                maximum=math.max(maximum,(tp.economy and tp.economy.maintenanceConsumption or {}).energy or 0)
            end
        end
        total=total+maximum
    end
    if not found then return false end
    local allowed=snapshot.energy.balance-snapshot.energy.reserved>=total
    army.ai.strategySwitches=army.ai.strategySwitches or {}
    local state=State(army)
    if not allowed then
        state.maintenanceDemand=math.max(state.maintenanceDemand or 0,total)
        army.ai.strategySwitches.NeedMoreEnergyForMaintenance=true
    elseif snapshot.energy.balance-snapshot.energy.reserved>=(state.maintenanceDemand or 0) then
        state.maintenanceDemand=nil
        army.ai.strategySwitches.NeedMoreEnergyForMaintenance=false
    end
    return allowed
end

local function BaseAlive(army, baseName, expected)
    local base=army and army.ai and army.ai.bases and army.ai.bases[baseName]
    return base and army.ai.isAlive~=false and (not expected or base==expected)
end

-- Bootstrap only an empty MAIN. Read live native commitments so an accepted
-- factory order or placement ghost closes this path before the census refresh.
local function EmptyFactoryOpening(army,baseName)
    if baseName~="MAIN" or not BaseAlive(army,baseName) then return false end
    local snapshot=army.ai.rushController and army.ai.rushController.snapshot
    -- Cached presence can reject this optional path cheaply. Admission still
    -- checks every live commitment below; cached absence never authorizes it.
    if snapshot and ((snapshot.completeFactories or 0)>0 or (snapshot.unfinishedFactories or 0)>0) then return false end
    local function factory(tp) return Has(tp,"FACTORY") or Has(tp,"SCFA_FACTORY") end
    local function committed(order)
        return order and factory(Template(order.tpId))
    end
    for _,unit in pairs(army.units or {}) do
        if OwnUnit(army,unit) then
            if factory(unit.tp) then return false end
            for _,target in pairs({unit.unitBeingBuilt,unit.buildBehaviorActualUnit,unit.productionBehaviorTargetUnit}) do
                if target and not target.dead and not target.deleted and target.army==army and factory(target.tp) then return false end
            end
            local orders=unit.orders or {}
            if committed(orders.activeOrder) then return false end
            for _,order in pairs(orders.queuedOrders or {}) do if committed(order) then return false end end
            for _,entry in pairs(unit.buildQueue or {}) do if factory(Template(entry.tpId)) then return false end end
            local reserve=army.ai.ecoReserve and army.ai.ecoReserve[unit.id.index]
            if reserve and factory(Template(reserve.tpId)) then return false end
        end
    end
    return true
end
local function FormerErrorRetry(army,baseName,former)
    return former.RushFirstFactory and EmptyFactoryOpening(army,baseName) and 1 or ERROR_RETRY
end

local function CheckConditions(army, baseName, conditions, key)
    local base=army.ai.bases and army.ai.bases[baseName]
    if not BaseAlive(army,baseName,base) then return false,false end
    for _, condition in ipairs(conditions or {}) do
        local fn = type(condition[1]) == "function" and condition[1] or AF[condition[1]]
        if IsRushArmy(army) and (condition[1]=="MoreThanGameTimeSeconds" or condition[1]=="LessThanGameTimeSeconds") then
            fn=Balance.Ready
        end
        local ok, result = Call(army, key .. "/" .. tostring(condition[1]), fn, army.id, baseName, unpackArgs(condition[2] or {}))
        if not BaseAlive(army,baseName,base) then return false,false end
        if not ok then return false, true end
        if not result then return false, false end
    end
    return true, false
end

function ActiveStrategies(army)
    if not BaseAlive(army,"MAIN") then return {} end
    local state, now = State(army), Now()
    if state.strategies and now - (state.strategiesAt or -100) < STRATEGY_SECONDS then return state.strategies end
    local result = {}
    for _, strategy in pairs(army.ai.strategypool or {}) do
        if not BaseAlive(army,"MAIN") then return {} end
        if Enabled(army.ai.settings, strategy)
            and not (army.ai.blockedStrategies and army.ai.blockedStrategies[strategy.StrategyName]) then
            local valid = CheckConditions(army, "MAIN", strategy.StrategyConditions, "strategy " .. strategy.StrategyName)
            if valid then result[strategy.StrategyName] = true end
        end
    end
    state.strategies, state.strategiesAt = result, now
    return result
end

local CHECKS = {
    {"NeedMobileBuilder", "GetNeedMobileBuilder"}, {"NeedFactory", "GetNeedFactory"},
    {"NeedUnits", "CheckNeedUnits"}, {"NeedUpgradeableUnit", "GetNeedUpgradeableUnit"},
    {"WantUnits", "GetWantUnits"}, {"WantStructures", "GetWantStructures"},
    {"AllowEcoStorageDrain", "CheckEcoStorageDrain"},
    {"EnergyTrendCanCoverMaintenanceConsumption", "CheckEnergyTrendCanCoverMaintenanceConsumption"},
    {"AssistBuildUnits", "CheckAssistBuildUnits"}, {"AssistUpgradeUnits", "CheckAssistUpgradeUnits"},
    {"RepairStructures", "GetUnitsThatDesiresRepairAtBase"},
    {"ReclaimUnits", "GetReclaimAbleUnitsAtBase"}, {"RechargeShields", "GetShieldStructuresThatDesiresRechargeAtBase"},
}

local function Lane(former)
    if former.AIPlan == "planBuildInFactory" then
        for _, line in ipairs(former.WantUnits or {}) do
            for id, wanted in pairs(line) do
                if wanted and Playable(id, Template(id)) and not Roles(Template(id)) then return "specialProduction" end
            end
        end
        return "production"
    end
    if former.NeedUnits and not former.NeedMobileBuilder and not former.NeedUpgradeableUnit
        and former.AIPlan ~= "planAlloyExtractorUpgrade" then return "combat" end
    return "construction"
end

local function Activity(army)
    local counts, investments = {}, {}
    for _, platoon in pairs(army.platoons or {}) do
        if not platoon.dead and army:PlatoonExists(platoon) then
            local former = platoon.ai and platoon.ai.formerTable
            local name = platoon.name or (former and former.FormerName)
            if name then counts[name] = (counts[name] or 0) + 1 end
            if former and former.InvestmentType then investments[former.InvestmentType] = true end
        end
    end
    return counts, investments
end

local function IsPowerFormer(former)
    if not former.WantStructures then return false end
    local found = false
    for _, line in ipairs(former.WantStructures) do
        for id in pairs(line) do
            local template = Template(id)
            if template then
                if not Has(template, "ENERGY_PRODUCTION") or Has(template, "ALLOYS_EXTRACTION") then return false end
                found = true
            end
        end
    end
    return found
end

local function CommanderOwnerReady(army,snapshot,baseName)
    local main=army.ai.bases and army.ai.bases.MAIN
    if baseName~="MAIN" or not main or not main.position
        or (snapshot.completeFactories or 0)<1 or (snapshot.extractors or 0)<1 then return false end
    local radius=(main.radius or 60)+50
    for _,builder in ipairs(snapshot.balanceEngineers or {}) do
        if OwnUnit(army,builder) and Complete(builder) and builder.assignedToBase=="MAIN"
            and not Has(builder.tp,"COMMAND") and not builder.CaptureInProgress and not builder.ReclaimInProgress
            and not (builder.toggles and builder.toggles.Pause)
            and builder.construction and Finite(builder.construction.buildPower) and builder.construction.buildPower>0
            and Finite(builder.construction.range) and builder.construction.range>0
            and type(builder.CanConstructOthers)=="function" and builder:CanConstructOthers() then
            local pos=builder:GetPosition()
            if (pos.x-main.position.x)^2+(pos.z-main.position.z)^2<=radius^2 then return true end
        end
    end
    return false
end

function PolicyAllowsFormer(army, former, snapshot, baseName)
    if former.RushCommanderOwner and not CommanderOwnerReady(army,snapshot,baseName) then return false end
    local shore=Beachhead.BaseConnected(army,baseName)
    local localView=shore and SnapshotForBase(army,snapshot,baseName)
    if former.RushBeachhead and not Beachhead.Ready(army,snapshot,baseName) then return false end
    if former.RushBeachheadAssault then
        if not localView then return false end
        local active=0
        for _,p in pairs(army.platoons or {}) do
            if not p.dead and army:PlatoonExists(p) and p.ai and p.ai.baseName==baseName
                and p.ai.formerTable and p.ai.formerTable.RushBeachheadAssault then active=active+1 end
        end
        if active>=2 then return false end
    elseif shore then
        local plan=former.AIPlan
        local landCombat=plan=="planSupportLandPrimaryPlatoon" or plan=="planLandAttackPrimary"
            or plan=="planLandAttack" and not former.NavalAttack or former.RushRaider
            or former.RushFieldRecovery or former.RushIdleSweep
        local localPanic=former.FormerName=="F123 Land Panic Response" and localView and localView.localLandThreat
        if landCombat and not localPanic then return false end
    end
    if former.AIPlan == "planLandSingleAttack"
        and Now() < (army.ai.rushCommanderWorkYieldUntil or 0)
        and not (snapshot.landDisconnected and snapshot.localLandThreat
            or not snapshot.landDisconnected and snapshot.landPanic) then return false end
    if snapshot.landDisconnected and not shore then
        if former.LoadedTech4Domain=="LAND" then return false end
        local plan=former.AIPlan
        if not snapshot.localLandThreat and not former.RushHeavyCombat and (plan=="planLandAttack"
            or plan=="planLandAttackPrimary" or plan=="planSupportLandPrimaryPlatoon") then return false end
    end
    if former.RushMainDefense and (baseName~="MAIN" or not Frontline.MainAlarm(army).landRaid
        or not Combat.MainResponseRequired(army,(former.AIPlanData.AttackEnemyStrength or 80)/100)) then return false end
    if former.RushEmergencyShield and not Layout.EmergencyShieldPriority(army,snapshot,baseName) then return false end
    if former.RushGunshipBaseDefense and
        (not Pressure.SurvivalMap() or not snapshot.landPressure) then return false end
    if former.RushSurvivalDefense then
        local a,e=snapshot.alloy,snapshot.energy
        if not Pressure.SurvivalMap() or (snapshot.landFactories or 0)<3
            or not a or not e or a.income<25 or e.income<300
            or e.ratio<0.65 or e.balance<0 then return false end
    end
    if former.RushGroundDefense and not Layout.GroundDefensePriority(army,snapshot,baseName,former.RushGroundDefense) then return false end
    if former.RushAdjacencyStorage and not Layout.StoragePriority(army,snapshot,baseName,former.RushAdjacencyStorage) then return false end
    if former.RushBaseDefense and not Layout.DefenseInvestment(army,snapshot,baseName,former.RushBaseDefense) then return false end
    if former.RushAirDefense and not AirDefense.Allows(army,snapshot,baseName,former.RushAirDefense) then return false end
    if former.RushSiege and not Frontline.Active(army) then return false end
    if former.FormerName=="F123 Air Patrol Wing" then
        local primary=army:GetPlatoonWithUniqueName("PrimaryAirPlatoon")
        local n=0
        if primary and not primary.dead and army:PlatoonExists(primary) then
            for _,u in pairs(primary:GetUnits()) do
                if OwnUnit(army,u) and u.platoon==primary and Complete(u) then n=n+1 end
            end
        end
        if n<Balance.Config.FighterMinimum then return false end
    end
    if (former.RushRaider or former.FormerName=="F123 Land Alloy Hunter")
        and not Balance.CanDispatchRaid(army,snapshot) then return false end
    if former.RushPersistentExpansion and not Expansion.Needed(army,snapshot) then return false end
    if former.RushTechProject then
        if not Development.CanStartFactoryTech(army,snapshot,former.RushUpgradeDomain,
            former.RushUpgradeTier,former.RushUpgradeRollout==true) then return false end
    elseif former.RushAnyFactoryUpgrade then
        -- One owned development path governs every new factory transition.
        -- Legacy formers cannot race its field, production or budget gates.
        return false
    end
    local factoryDomain,powerTier=Balance.FormerKind(former)
    local firstPower=powerTier and powerTier==Balance.FirstPowerTier(snapshot)
    local powerFormer=IsPowerFormer(former)
    if powerFormer and not EconomyPolicy.NeedsPower(snapshot)
        and not Development.NeedsTechPower(army,snapshot) then return false end
    if firstPower and (snapshot.powerPending and snapshot.powerPending[powerTier] or 0)>0 then return false end
    local factoryBuild = factoryDomain ~= nil and not former.RushBeachhead
    local capacityView=localView or factoryDomain=="land" and SupportView(snapshot) or snapshot
    if factoryBuild then
        if factoryDomain=="land" and snapshot.landDisconnected and not shore then
            local homeCapacity=snapshot.landFactories+(snapshot.factoryPending.land or 0)
            for _,c in pairs(snapshot.beachheadBases or {}) do
                homeCapacity=homeCapacity-c.landFactories-(c.factoryPending.land or 0)
            end
            if homeCapacity>=1 then return false end
        end
        if (snapshot.factoryPending[factoryDomain] or 0)>=Development.CapacityLimit(snapshot,factoryDomain) then return false end
        if factoryDomain=="naval" then
            if not Development.Check(army.id,baseName,"capacity",1,"naval") then return false end
        elseif former.RushAirDefense~="airfield"
            and not EconomyPolicy.CanAddCapacity(army,capacityView,factoryDomain) then return false end
    end
    if former.RushEarlyAir and not Bombers.WantsOpening(army,snapshot) then return false end
    if former.AssistBuildUnits or former.WantStructures and (former.LoadedTech4Domain
        or former.InvestmentType=="ExperimentalDevelopment" or former.InvestmentType=="StrategicDevelopment") then
        local first=HeavyPolicy.FirstTarget(army)
        if first then
            if former.WantStructures then return false end
            for _,tags in ipairs(former.AssistBuildUnits) do if first:HasTags(tags) then return false end end
        end
    end
    if not Heavy.AllowsFormer(army,former) then return false end
    if former.RushSupportCap then
        if not Combat.SupportAvailable(army) then return false end
    elseif former.RushSupportPrimary then
        local primary = army:GetPlatoonWithUniqueName(former.RushSupportPrimary)
        if not primary or primary.dead or not army:PlatoonExists(primary) then return false end
        local cap = primary.ai and primary.ai.formerTable and primary.ai.formerTable.AIPlanData.RushUnitLimit
        if cap and primary:GetNumOfUnits() >= cap then return false end
    end
    if former.RushNeedsGroundDamage then
        local ready, required = 0, (former.RushIdleSweep or former.RushMainDefense) and 1 or 2
        local state = State(army)
        state.combatIdleSince = state.combatIdleSince or setmetatable({}, {__mode="k"})
        -- Build this roster once per one-second controller snapshot, not once
        -- per combat former / base. Never query a destroyed unit's position.
        local roster = snapshot.rushReadyGround
        if not roster then
            roster = {}
            for _, unit in pairs(army.units or {}) do
                if OwnUnit(army, unit) and Complete(unit) and not unit.platoon then
                    local role = Roles(unit.tp)
                    if (role == "frontline" or role == "raider" or role == "artillery")
                        and not HeavyPolicy.IsT4(unit.tp) then
                        local since = state.combatIdleSince[unit] or Now()
                        state.combatIdleSince[unit] = since
                        roster[#roster + 1] = {unit=unit, position=unit:GetPosition(), since=since}
                    end
                else state.combatIdleSince[unit] = nil end
            end
            snapshot.rushReadyGround = roster
        end
        local base = baseName and army.ai.bases[baseName]
        for _, entry in ipairs(roster) do
            local u, pos = entry.unit, entry.position
            local nearby = not baseName or (base and (pos.x-base.position.x)^2 + (pos.z-base.position.z)^2 <= base.radius^2)
            if nearby and OwnUnit(army, u) and Complete(u) and not u.platoon
                and (not former.RushIdleSweep or Now()-entry.since >= 30) then
                ready = ready + 1
                if ready >= required then break end
            end
        end
        if ready < required then return false end
    end
    local energy = snapshot.energy
    local recovering = energy and (energy.ratio < 0.12
        and energy.balance-energy.reserved+(energy.techReserved or 0)<0)
    if factoryBuild and snapshot.completeFactories > 0 then
        if recovering then return false end
        -- Idle aircraft or shipyards do not suppress useful land expansion.
        local count = capacityView[factoryDomain.."Factories"] or 0
        local idle = capacityView.idleFactoriesByDomain[factoryDomain] or 0
        if count>0 and idle>math.max(1,count*0.30) then return false end
    end
    if powerFormer and snapshot.powerBuilding >= 6 then return false end
    if recovering and former.InvestmentType and not powerFormer
        and former.AIPlan ~= "planEngineerCapAlloySpot" and former.AIPlan ~= "planAlloyExtractorUpgrade" then return false end
    return true
end

local function ConstructionPriority(army, baseName, former, snapshot)
    local priority = former.Priority
    if former.RushEmergencyShield then return Layout.EmergencyShieldPriority(army,snapshot,baseName) or 0 end
    if former.RushBomberHarassment and (snapshot.mainRaid or snapshot.mainBombardment) then
        priority=math.max(priority,9900)
    end
    if former.RushGroundDefense then
        return Layout.GroundDefensePriority(army,snapshot,baseName,former.RushGroundDefense) or 0
    end
    if former.RushAdjacencyStorage then
        return Layout.StoragePriority(army,snapshot,baseName,former.RushAdjacencyStorage) or 0
    end
    if former.RushTechProject and former.RushUpgradeDomain and former.RushUpgradeTier then
        priority=Development.FactoryUpgradePriority(snapshot,former.RushUpgradeDomain,
            former.RushUpgradeTier,former.RushUpgradeRollout)
        if snapshot.mainBombardment and former.RushUpgradeDomain=="air" and not former.RushUpgradeRollout then
            priority=math.max(priority,9850)
        end
    end
    local domain,powerTier=Balance.FormerKind(former)
    local powerFormer = IsPowerFormer(former)
    if powerTier and powerTier==Balance.FirstPowerTier(snapshot) then priority=math.max(priority,9700) end
    if former.RushEarlyAir and snapshot.landDisconnected and snapshot.airFactories==0 then
        priority=math.max(priority,9600)
    end
    local alloy, energy = snapshot.alloy, snapshot.energy
    if powerFormer and former.FormerName:find("R8 proactive T", 1, true) == 1
        and alloy and energy and alloy.ratio >= 0.90 and energy.ratio >= 0.75
        and energy.balance - energy.reserved < math.max(40, energy.income * 0.25) then
        -- Prepare power ahead of expansion, after usable land capacity.
        priority = math.max(priority, 9490)
    end
    if former.RushEarlyAir and snapshot.airFactories == 0 and snapshot.landFactories >= 2
        and alloy and energy and alloy.ratio >= 0.90 and energy.ratio >= 0.75 then
        -- Open the first fighter line before another optional extractor trip.
        priority = math.max(priority, 9560)
    end
    if domain=="land" and snapshot.alloy and snapshot.energy and snapshot.alloy.ratio>=0.75
        and snapshot.energy.ratio>=0.80 then
        local advanced=(snapshot.landFactoryTiers[2] or 0)+(snapshot.landFactoryTiers[3] or 0)>0
        priority=math.max(priority,advanced and 9300 or 9100)
        if snapshot.alloy.ratio >= 0.90 and snapshot.landFactories < Balance.Config.OpeningLandFactories then
            -- A capped bank with few factories needs spending capacity before more expansion.
            priority = math.max(priority, 9500)
        end
    end
    if former.BuildNavalFactory == true and snapshot.navalFactories == 0 then
        -- Establish two land factories before prioritizing a first yard. Emergency power,
        -- land tech and the bounded full-bank land bootstrap still take priority.
        -- Only a candidate that passes its real water-area, builder, template and
        -- economy checks is dispatched; this does not force navy on a dry map.
        priority = math.max(priority, snapshot.landDisconnected and 9550
            or (snapshot.landFactories>=2 and 9350 or 6800))
    end
    if powerFormer and (snapshot.mainShieldPowerNeed or 0)>0 and snapshot.energy
        and Balance.Balance(snapshot.energy)<snapshot.mainShieldPowerNeed then
        priority=math.max(priority,9950)
    end
    if powerFormer and snapshot.energy and snapshot.energy.ratio < 0.20 then
        priority = priority + 4000
    end
    return priority
end

-- Cheap eligibility first, then expensive selectors. Each bad former has an independent retry window.
local function AirPrimaryForSnapshot(state, former, snapshot)
    if former.FormerName ~= "F123 Air Primary" or not (snapshot.airRaid or snapshot.airPanic)
        or not former.NeedUnits or not former.NeedUnits[1] then return former end
    local cached = state.emergencyAirPrimary
    if cached and cached.source == former then return cached.former end
    local adapted, needUnits, first = {}, {}, {}
    for key, value in pairs(former) do adapted[key] = value end
    for i, line in ipairs(former.NeedUnits) do needUnits[i] = line end
    for key, value in pairs(needUnits[1]) do first[key] = value end
    first[2] = 1
    needUnits[1] = first
    adapted.NeedUnits = needUnits
    state.emergencyAirPrimary = { source = former, former = adapted }
    return adapted
end

function SelectFormer(army, baseName, lane, plans, snapshot)
    local base = army.ai.bases[baseName]
    if not BaseAlive(army,baseName,base) then return nil end
    local state, now = State(army), Now()
    local strategies = ActiveStrategies(army)
    if not BaseAlive(army,baseName,base) then return nil end
    Development.TechCommitment(army,snapshot)
    Balance.RefreshInvestment(army,snapshot)
    local counts, investments = Activity(army)
    local shore=Beachhead.BaseConnected(army,baseName)
    local opening=lane=="construction" and EmptyFactoryOpening(army,baseName)
    local candidates,bootstrapOnly = {},{}
    for _, former in pairs(army.ai.formerpool or {}) do
        local bootstrap=former.RushFirstFactory and opening
        local key=baseName.."/"..tostring(former.FormerName or "")
        -- A rejected zero-progress ghost may disappear after failure cleanup.
        -- Once MAIN is empty again, it cannot retain the ordinary 20s cooldown.
        if bootstrap and (state.retry[key] or 0)>now+1 then state.retry[key]=now+1 end
        if (former.Priority or 0) > 0 and former.RunOnBaseType and former.RunOnBaseType[base.baseType]
            and Lane(former) == lane and Enabled(army.ai.settings, former,shore)
            and (counts[former.FormerName] or 0) < (former.FormNumInstances or 1)
            and not (former.InvestmentType and investments[former.InvestmentType])
            and now >= (state.retry[baseName .. "/" .. former.FormerName] or 0) then
            local active = former.RushDevelopment == true
            for name, enabled in pairs(former.RunWithStrategyName or {}) do if enabled and strategies[name] then active = true; break end end
            if (active or bootstrap) and PolicyAllowsFormer(army, former, snapshot, baseName) then
                candidates[#candidates+1]=former;bootstrapOnly[former]=bootstrap and not active
            end
        end
    end
    -- Priorities depend on this snapshot and live former metadata, not on the
    -- comparisons. Compute once after eligibility, never cache across dispatches.
    local priorities = {}
    for _, former in ipairs(candidates) do priorities[former] = ConstructionPriority(army, baseName, former, snapshot) end
    table.sort(candidates, function(a, b)
        local pa, pb = priorities[a], priorities[b]
        if pa ~= pb then return pa > pb end
        return a.FormerName < b.FormerName
    end)
    local fresh
    for i, candidate in ipairs(candidates) do
        -- Launch the ordinary two-fighter screen; during a known raid,
        -- dispatch even one available fighter through the same guarded plan.
        local former = AirPrimaryForSnapshot(state, candidate, snapshot)
        if not BaseAlive(army,baseName,base) then return nil end
        local key = baseName .. "/" .. former.FormerName
        local valid, failed = CheckConditions(army, baseName, former.FormerConditions, "former " .. key)
        if valid and type(plans[former.AIPlan]) ~= "function" then
            Report(army, key, "plan " .. tostring(former.AIPlan) .. " is unavailable")
            valid, failed = false, true
        end
        if valid then
            local structureDrainAlreadyChecked = type(former.AllowEcoStorageDrain) == "boolean"
                and former.WantStructures and former.NeedMobileBuilder
                and not former.NeedFactory and not former.NeedUpgradeableUnit and not former.RepairStructures
            for _, check in ipairs(CHECKS) do
                if not BaseAlive(army,baseName,base) then return nil end
                if former[check[1]] ~= nil and not (check[1] == "AllowEcoStorageDrain" and structureDrainAlreadyChecked) then
                    local ok, passed
                    if check[2] == "CheckNeedUnits" and former.RushFieldRecovery then
                        ok, passed = Call(army,key.."/field-recovery",GetFieldRecruits,army.id,baseName,former)
                    elseif check[2] == "CheckNeedUnits" and former.RushHeavyCombat then
                        ok, passed = Call(army, key .. "/heavy-combat-units", Heavy.GetCombatUnits, army.id, baseName, former)
                    elseif check[2] == "CheckNeedUnits" and former.RushFleet then
                        ok, passed = Call(army,key.."/fleet-units",NavalCombat.GetUnits,army.id,baseName,former)
                    elseif check[2] == "CheckEnergyTrendCanCoverMaintenanceConsumption" then
                        ok, passed = Call(army, key .. "/maintenance", MaintenanceAffordable, army, baseName, former)
                    else
                        ok, passed = Call(army, key .. "/" .. check[2], AF[check[2]], army.id, baseName, former)
                    end
                    if not ok or not passed then valid, failed = false, not ok; break end
                end
            end
        end
        if failed then state.retry[key]=Now()+FormerErrorRetry(army,baseName,former) end
        if valid and BaseAlive(army,baseName,base) then
            -- Native selectors can yield. Re-read commitments after any yield
            -- or dispatch instead of reusing another base's obsolete budget.
            if not fresh or fresh.time ~= Now() or state.snapshot ~= fresh then
                fresh = Snapshot(army,true)
                Development.TechCommitment(army,fresh)
                Balance.RefreshInvestment(army,fresh)
                counts, investments = Activity(army)
            end
            if (counts[former.FormerName] or 0) < (former.FormNumInstances or 1)
                and not (former.InvestmentType and investments[former.InvestmentType])
                and (former == candidate or fresh.airRaid or fresh.airPanic)
                and (not bootstrapOnly[candidate] or EmptyFactoryOpening(army,baseName))
                and PolicyAllowsFormer(army,former,fresh,baseName)
                and Balance.ConstructionBudget(army,baseName,former,fresh,AF) then return former end
        end
        if i % 12 == 0 then WaitTicks(1); fresh=nil end
    end
    return nil
end

-- One cached scan per army, independent of the number of dispatching bases.
-- Orders left by an intentional detached assignment are not commandeered.
function GetFieldRecruits(armyIndex,baseName,former)
    local army=Armies[armyIndex]
    if not army or army.ai.isAlive==false or baseName~="MAIN" then return false end
    local state,now=State(army),Now()
    state.fieldIdleSince=state.fieldIdleSince or setmetatable({},{__mode="k"})
    local function eligible(u)
        if not OwnUnit(army,u) or u.deleted or not Complete(u) or u.platoon or OrderPresent(u)
            or Working(u) or HeavyPolicy.IsT4(u.tp) or u.CaptureInProgress or u.ReclaimInProgress
            or (u.toggles and u.toggles.Pause) or u.ai and (u.ai.eState=="RepairHome" or u.ai.reservedEco)
            or army.ai.ecoReserve and army.ai.ecoReserve[u.id.index] then return false end
        local role=Roles(u.tp)
        return role=="frontline" or role=="raider" or role=="artillery" or role=="mobileAA"
    end
    if state.fieldScan and now<state.fieldScan then state.fieldIdleSince=setmetatable({},{__mode="k"}) end
    if not state.fieldPool or now<(state.fieldScan or 0) or now-(state.fieldScan or 0)>=2 then
        state.fieldPool={};state.fieldScan=now
        for _,u in pairs(army.units or {}) do
            if eligible(u) then
                state.fieldIdleSince[u]=state.fieldIdleSince[u] or now
                local pos=u:GetPosition();local inBase=false
                for _,base in pairs(army.ai.bases or {}) do
                    if (pos.x-base.position.x)^2+(pos.z-base.position.z)^2<=(base.radius or 64)^2 then inBase=true;break end
                end
                if not inBase then state.fieldPool[#state.fieldPool+1]={unit=u,position={x=pos.x,y=pos.y,z=pos.z}} end
            else state.fieldIdleSince[u]=nil end
        end
        table.sort(state.fieldPool,function(x,y) return x.unit.id.index<y.unit.id.index end)
    end
    local anchor
    for _,r in ipairs(state.fieldPool) do
        if eligible(r.unit) and Roles(r.unit.tp)~="mobileAA" and now-(state.fieldIdleSince[r.unit] or now)>=10 then anchor=r;break end
    end
    if not anchor then return false end
    local units={anchor.unit}
    for _,r in ipairs(state.fieldPool) do
        if r~=anchor and eligible(r.unit) and now-(state.fieldIdleSince[r.unit] or now)>=10
            and (r.position.x-anchor.position.x)^2+(r.position.z-anchor.position.z)^2<=64^2
            and MG.CanGraphAreaTo(anchor.position,r.position,"Land") then
            units[#units+1]=r.unit
        end
    end
    return units,1,CombatPolicy.Config.WaveLimit,0
end

function CleanupFailedPlan(army, platoon, plans)
    local construction=Reliability.ReleaseConstructionQueue(platoon,true)
    if not army:PlatoonExists(platoon) then return end
    if platoon.ai and platoon.ai.rushOperation then Combat.Unregister(platoon) end
    local ok, units = pcall(platoon.GetUnits, platoon)
    if ok then
        -- OnUnitRemoved can mutate the returned array; copy it before removal.
        local copy={};for _,unit in pairs(units) do copy[#copy+1]=unit end
        for _, unit in ipairs(copy) do
            if OwnUnit(army, unit) and unit.platoon == platoon then
                unit.ai=unit.ai or {}
                if construction then
                    -- The queue released only its own unpaid orders above.
                    -- Native paid work and newer commands retain their ownership.
                    unit.ai.rushAbandonedWork=true
                elseif not Working(unit) then
                    -- Cancel only orders owned by this FAILED assignment, not a
                    -- factory queue or already running construction/upgrade.
                    if OrderPresent(unit) then Call(army,"failed plan order cleanup",Orders.HostClearOrder,{unit}) end
                    Call(army,"failed plan reservation cleanup",plans.ClearConstructionBuilderEconomyReservation,unit)
                    if not Working(unit) and not OrderPresent(unit) then
                        Call(army,"failed plan cleanup",plans.ClearUnitTemporaryPlatoonData,unit,"RC3 failed assignment")
                    else unit.ai.rushAbandonedWork=true end
                else
                    unit.ai.rushAbandonedWork=true
                end
                platoon:OnUnitRemoved(unit)
            end
        end
    end
    if army:PlatoonExists(platoon) then army:DisbandPlatoon(platoon) end
end

local function Dispatch(army, baseName, former, fn, plans)
    local state = State(army)
    if not BaseAlive(army,baseName) then return false end
    if not former.RushControlled then
        local counts, investments = Activity(army)
        if (counts[former.FormerName] or 0) >= (former.FormNumInstances or 1)
            or former.InvestmentType and investments[former.InvestmentType] then return false end
    end
    if former.RushGroundDefense and not Layout.GroundDefenseSlotAvailable(army) then return false end
    if former.RushAdjacencyStorage and not Layout.StorageSlotAvailable(army) then return false end
    local platoon = army:CreatePlatoon(former.FormerName)
    platoon.ai = { formerTable = former, baseName = baseName, creationTime = GetFormatedGameTime() }
    if former.RushBeachhead and not Beachhead.Claim(platoon,army.id,baseName,former) then
        army:DisbandPlatoon(platoon);return false
    end
    if former.RushGroundDefense then platoon.ai.rushGroundDefenseStartup=Now() end
    if former.RushAdjacencyStorage then platoon.ai.rushStorageStartup=Now() end
    state.dispatched = state.dispatched + 1
    state.retry[baseName .. "/" .. former.FormerName] = Now() + 1
    platoon:StartAIFunction(function(p, index, name, f)
        local ok, err = pcall(fn, p, index, name, f)
        if not ok then
            Report(army, "plan " .. f.FormerName, err)
            state.retry[name .. "/" .. f.FormerName] = Now() + ERROR_RETRY
            CleanupFailedPlan(army, p, plans)
            state.retry[name .. "/" .. f.FormerName] = Now() + FormerErrorRetry(army,name,f)
        end
    end, army.id, baseName, former)
    state.snapshot = nil
    return true
end

function DispatchProduction(army, baseName, plans)
    local snapshot, state = Snapshot(army), State(army)
    local cursor = state.factoryCursor[baseName] or 0
    local candidates = {}
    for _, factory in ipairs(snapshot.factories) do
        if factory.assignedToBase == baseName and not factory.platoon and not Working(factory)
            and Now() >= (state.blockedFactories[factory.id.index] or 0) then candidates[#candidates + 1] = factory end
    end
    -- Preserve the existing fair rotation for ordinary production.
    local first, count = 1, #candidates
    for i, factory in ipairs(candidates) do
        if factory.id.index > cursor then first = i; break end
    end
    local decisions={}
    local function product(factory)
        local choice=decisions[factory]
        if not choice then choice={SelectProduct(army,factory,snapshot)};decisions[factory]=choice end
        return choice[1],choice[2],choice[3],choice[4]
    end
    local selected,id,role
    local bestScore,bestTier=-1,-1
    -- Fund the unlocked combat tier before another routine T1 refill. Real
    -- urgent counters and the first advanced builder retain their higher role
    -- priority, even under long-lived survival pressure. Equal choices keep
    -- the native fair rotation; this stage creates no speculative reservation.
    for offset=0,count-1 do
        local factory=candidates[(first+offset-1)%count+1]
        local candidate,candidateRole,score,critical=product(factory)
        local tier=candidate and Tier(Template(candidate)) or 0
        if candidate and (tier>=2 and candidateRole~="engineer" or critical or (score or 0)>=900)
            and ((score or 0)>bestScore or score==bestScore and tier>bestTier) then
            selected,id,role=factory,candidate,candidateRole
            bestScore,bestTier=score or 0,tier
        end
    end
    if not selected then
        for offset=0,count-1 do
            local factory=candidates[(first+offset-1)%count+1]
            local candidate,candidateRole=product(factory)
            if candidate then selected,id,role=factory,candidate,candidateRole;break end
        end
    end
    if not selected then return false end
    local former = { FormerName = "R7 Adaptive " .. FactoryKind(selected) .. " production",
        AIPlan = "RushV7Production", RushFactory = selected, RushProduct = id, RushRole = role,
        DebugPlatoon = false, RushControlled = true }
    local pending = { factory = selected, id = id, expires = Now() + 5 }
    former.RushPending = pending
    state.pending[selected.id.index] = pending
    state.factoryCursor[baseName] = selected.id.index
    if Dispatch(army, baseName, former, PlanProduction, plans) then return true end
    if state.pending[selected.id.index] == pending then state.pending[selected.id.index] = nil end
    return false
end

local function Telemetry(army)
    local state, now = State(army), Now()
    if now - state.lastTelemetry < 30 then return end
    state.lastTelemetry = now
    local s = Snapshot(army, true)
    local x=army.ai.rushExpansion or {}
    Log(("[RushEconomy] army=%s groundReady=%d engineersReady=%d engineersQueued=%d landWorking=%d "
        .."alloyIncome=%.2f alloyRequest=%.2f alloyReserved=%.2f alloyStored=%.2f alloyStalled=%s expansion=%d/%d")
        :format(tostring(army.id),s.groundReady,s.engineersComplete,s.engineersQueued,s.landProductionActive,
            s.alloy and s.alloy.income or 0,s.alloy and s.alloy.request or 0,s.alloy and s.alloy.reserved or 0,
            s.alloy and s.alloy.current or 0,tostring(EconomyPolicy.AlloyStalled(s)),x.active or 0,x.wanted or 0),true)
    Log(("[RushV9] army=%s faction=%s factories=%d idle=%d army=%d engineers=%d "
        .. "submitted=%d decisions=%d checkFailures=%d pressure=land:%s/air:%s energy=%.2f "
        .. "navalFactories=%d navalBuilding=%d navalShips=%d waterEnabled=%s landDisconnected=%s localLandThreat=%s "
        .. "unassigned=%d paused=%d capSpace=%s")
        :format(tostring(army.id), tostring(army.faction), s.completeFactories, s.idleFactories,
            (s.roles.frontline or 0) + (s.roles.raider or 0) + (s.roles.artillery or 0) + (s.roles.mobileAA or 0)
                + (s.roles.bomber or 0) + (s.roles.gunship or 0) + (s.roles.fighter or 0) + (s.roles.naval or 0),
            s.roles.engineer or 0, state.submitted, state.dispatched, state.failedChecks,
            tostring(s.landPanic), tostring(s.airPanic), s.energy and s.energy.ratio or -1,
            s.navalFactories, s.navalFactoriesBuilding,
            (s.roles.naval or 0) + (s.roles.submarine or 0) + (s.roles.navalAA or 0),
            tostring(not army.ai.settings.useLayer or army.ai.settings.useLayer.water == true),
            tostring(s.landDisconnected),tostring(s.localLandThreat),
            s.unassignedFactories,s.pausedFactories,tostring(s.underCap)), true)
end

function ProductionThread(armyIndex, baseName)
    local army=Armies[armyIndex];local ai=army and army.ai
    local base=ai and ai.bases and ai.bases[baseName]
    if not base or not IsRushArmy(army) then return end
    local plans=Import(ai.settings.modDirectory.."/AIPlatoonFunctions.lua")
    local worker = coroutine.running()
    while Armies[armyIndex]==army and army.ai==ai and ai.isAlive~=false and ai.bases[baseName]==base
        and base.luaThreads.RushProductionThread == worker do
        base.rushProductionHeartbeat = Now()
        EnsureSupervisor(army)
        local ok,err=pcall(DispatchProduction,army,baseName,plans)
        if not ok then Report(army,"production lane "..baseName,err) end
        WaitTicks(Ticks(0.2))
    end
end

function LocationThread(armyIndex, baseName)
    local army = Armies[armyIndex]
    local ai = army and army.ai
    local base = ai and ai.bases[baseName]
    if not base or not IsRushArmy(army) then return end
    local plans = Import(ai.settings.modDirectory .. "/AIPlatoonFunctions.lua")
    Reliability.ConfigureCleanup(plans)
    Log("[RushV9] army=" .. armyIndex .. " faction=" .. tostring(army.faction)
        .. " base=" .. baseName .. " scheduler=" .. Version, true)
    local worker = coroutine.running()
    local function alive() return Armies[armyIndex] == army and army.ai == ai
        and ai.isAlive ~= false and ai.bases[baseName] == base
        and base.luaThreads.AILocationManagerThread == worker end
    while alive() do
        base.rushLocationHeartbeat = Now()
        EnsureSupervisor(army)
        -- Independent protected lanes: a broken construction selector cannot suppress production.
        local function lane(name, fn)
            if not alive() then return end
            base.rushLocationHeartbeat = Now()
            local ok, err = pcall(fn)
            if not ok then Report(army, "scheduler " .. baseName .. "/" .. name, err) end
        end
        lane("first-experimental-assist", function()
            if baseName == "MAIN" then Heavy.UpdateFirstAssist(army, Snapshot(army), plans) end
        end)
        lane("heavy-construction", function()
            if baseName == "MAIN" then Heavy.Update(army, Snapshot(army), plans) end
        end)
        lane("maintenance", function()
            if baseName == "MAIN" then
                ReconcileReservations(army)
                Development.Maintenance(army, plans)
            end
        end)
        for _, kind in ipairs({"combat", "construction", "specialProduction"}) do
            lane(kind, function()
                local former = SelectFormer(army, baseName, kind, plans, Snapshot(army))
                if former and alive() and Dispatch(army, baseName, former, plans[former.AIPlan], plans) then
                    WaitTicks(1)
                end
            end)
        end
        lane("telemetry", function() if baseName == "MAIN" then Telemetry(army) end end)
        local difficulty = ai.settings.difficulty
        WaitTicks(Ticks(difficulty == "easy" and 2 or difficulty == "medium" and 1 or 0.5))
    end
end

local function Clone(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local result = {}; seen[value] = result
    for key, nested in pairs(value) do
        if key ~= "_cacheByArmy" and key ~= "_resolvedFunction" then result[key] = Clone(nested, seen) end
    end
    return setmetatable(result, getmetatable(value))
end

function NormalizeFormers(army, formers)
    if not IsRushArmy(army) or type(formers) ~= "table" or not next(formers) then return formers end
    local result = Clone(formers)
    local landPrimary, airPrimary, gunshipEconomy, navalPrimary
    local navalAir=Tags.TORPEDO_BOMBER+Tags.ANTI_NAVAL+Tags.ANTI_NAVY+Tags.SCFA_ANTINAVY
    local landBombers=Tags.MOBILE*Tags.AIR*Tags.BOMBER-Tags.TECH4-Tags.TRANSPORT-Tags.GUNSHIP-navalAir
    local strikeAir=landBombers+Tags.MOBILE*Tags.AIR*(Tags.GUNSHIP+navalAir)
    local survival=Pressure.SurvivalMap()
    for _, former in pairs(result) do
        local name = former.FormerName or ""
        if name=="BC123 Factory Land Recover good ECO" or name=="BC123 Factory Land Recover 1st" then
            former.RushFirstFactory=true
        end
        if name=="F0 Commander Attack" then
            -- The existing commander owner also handles support and development.
            -- Opening infrastructure and a usable home builder still come first.
            former.RushCommanderOwner,former.RushDevelopment=true,true
            former.RunWithStrategyName={};former.FormerConditions={}
        end
        if name=="F123 Naval Primary" then navalPrimary=former end
        if former.BuildNavalFactory == true then
            -- The opening has its own economy and water-area checks. A global
            -- panic flag or another factory upgrade must not disable naval access.
            former.RushDevelopment = true
            if former.RushNavalCapacity then former.InvestmentType = nil
            else former.InvestmentType = "RushNavalCapacity" end
        end
        if survival and name=="T2 Shield First" then
            -- Preserve the funded Survival shield starter. Ground defense uses
            -- the same directional/site policy as every other map.
            former.RushDevelopment,former.RushSurvivalDefense=true,true
            former.RushBaseDefense=nil
            former.Priority=9580
            former.InvestmentType="SurvivalDefense"
            former.RunOnBaseType={MAIN=true,EXPANSION=false,OUTPOST=false,NAVAL=false}
            former.AllowEcoStorageDrain=true
            local shields=Tags.STRUCTURE*Tags.SHIELD
            former.FormerConditions={
                {"LessThanUnitsBeingBuiltAtBase",{1,shields}},
                {"LessThanUnitsInArmyAtBase",{1,shields,true}},
            }
        end
        if survival and name == "F2 Air Gunship Economy Attack" then
            gunshipEconomy = former
            former.Priority = 0
        end
        if former.NeedUpgradeableUnit and name:find("Factory", 1, true) then
            former.RushAnyFactoryUpgrade = true
            former.RushUpgradeDomain = name:find("Naval",1,true) and "naval"
                or name:find("Air",1,true) and "air" or "land"
        end
        -- One-step bootstrap and continuous production are now the factory controller's responsibility.
        if former.AIPlan == "planBuildInFactory" then former.RushLegacyProduction = true end
        if name == "F123 Land Primary" and former.NeedUnits then
            landPrimary = former
            former.RushDevelopment=true
            former.FormerConditions={}
            former.NeedUnits[1][2], former.NeedUnits[1][3] = 2, CombatPolicy.Config.PrimaryLimit
            former.RushNeedsGroundDamage = true
            former.AIPlanData = former.AIPlanData or {}
            former.AIPlanData.AttackEnemyStrength = Balance.Config.PrimaryStrength
            former.AIPlanData.IgnoreLandEmergencyTargets = not survival
            former.AIPlanData.RushCombatPolicy = true
            former.AIPlanData.RushUnitLimit = CombatPolicy.Config.PrimaryLimit
            former.AIPlanData.AggressiveMove = true
        elseif name == "F123 Land Panic Response" and former.NeedUnits then
            -- Keep the native immediate/allied-base defense plan, but never
            -- let a sticky panic flag collect a 500-unit second primary.
            former.NeedUnits[1][3] = CombatPolicy.Config.PrimaryLimit
        elseif name == "F123 Air Primary" and former.NeedUnits then
            airPrimary = former
            -- Secondary AA weapons do not turn strike aircraft into the
            -- interceptor screen; retain their ground/naval assignments.
            former.NeedUnits[1][1]=former.NeedUnits[1][1]-strikeAir
            former.NeedUnits[1][2], former.NeedUnits[1][3] = Balance.Config.OpeningFighters, 96
            former.AIPlanData = former.AIPlanData or {}
            former.AIPlanData.RushUnitLimit = 96
            former.AIPlanData.AttackEnemyStrength = Balance.Config.AirStrength
            former.AIPlanData.AggressiveMove = false
        elseif name == "F123 Land Sup ratio" or name == "F123 Air Sup ratio" then
            former.RushSupportPrimary = name == "F123 Land Sup ratio" and "PrimaryLandPlatoon" or "PrimaryAirPlatoon"
            if former.NeedUnits then
                former.NeedUnits[1][2], former.NeedUnits[1][3] = name=="F123 Air Sup ratio" and 1 or 2, CombatPolicy.Config.SupportLimit
                if name=="F123 Air Sup ratio" then former.NeedUnits[1][1]=former.NeedUnits[1][1]-strikeAir end
            end
            former.FormNumInstances = CombatPolicy.Config.SupportInstances
            if name == "F123 Land Sup ratio" then
                former.RushSupportCap = true
                former.RushDevelopment = true
                former.RushNeedsGroundDamage = true
                former.AIPlanData = former.AIPlanData or {}
                former.AIPlanData.RushUnitLimit = CombatPolicy.Config.WaveLimit
                former.AIPlanData.AttackEnemyStrength = Balance.Config.PrimaryStrength
                former.AIPlanData.AggressiveMove = true
            end
            local kept = {}
            for _, condition in ipairs(former.FormerConditions or {}) do
                if condition[1] ~= "AtLeastPrimaryPlatoonUnitRatioAtBase" then kept[#kept + 1] = condition end
            end
            former.FormerConditions = kept
        end
        if former.AIPlanData and not former.NavalAttack and not former.UseNavalAreaUnits
            and not tostring(former.AIPlan):find("Naval", 1, true) then
            former.AIPlanData.RushGroupingSeconds = 4
        end
        if name == "U1 Factory Land Upgrade 1->2 Economic Start"
            or name == "U1 Factory Land Upgrade 1->2 Stored Start"
            or name == "U1 Factory Land Upgrade 1->2 Transition Start" then
            former.RushFactoryUpgrade = true
            if name=="U1 Factory Land Upgrade 1->2 Stored Start" then
                former.RushStoredCost=true
                local kept={}
                for _,condition in ipairs(former.FormerConditions or {}) do
                    if condition[1]~="MoreThanEcoStorageAmount" then kept[#kept+1]=condition end
                end
                former.FormerConditions=kept
            end
        end
        if name == "T1 Factory Air 1st" or name == "T1 Factory Air 1st without Land Layer" then
            former.Priority = 6600
            former.RushEarlyAir, former.RushDevelopment = true, true
            former.InvestmentType = "RushFirstAirfield"
            former.FormerConditions = {
                {"LayerSettingMatches",{"air",true}},
                {"LayerSettingMatches",{"land",name=="T1 Factory Air 1st"}},
                {"LessThanUnitsInArmyAtBase",{1,Tags.AIR_FACTORY,false}},
                {"LessThanUnitsBeingBuiltAtBase",{1,Tags.AIR_FACTORY}},
            }
        end
        if name == "F123 Air Bomber Eco Attack Alloy" then
            former.FormerName = "F123 Bomber Resource Harassment"
            former.AIdifficulty = {easy=true,medium=true,hard=true}
            former.RushDevelopment, former.RushBomberHarassment = true, true
            former.AIPlan = "planRushBomberHarassment"
            former.Priority, former.FormNumInstances = 9560, Bombers.Config.WingInstances
            former.InvestmentType = nil
            former.FormerConditions = {{"LayerSettingMatches",{"air",true}}}
            former.NeedUnits = {{landBombers,1,Bombers.Config.WingLimit,0}}
            former.AIPlanData = {IgnoreLandEmergencyTargets=true,RushUnitLimit=Bombers.Config.WingLimit}
        elseif name == "F123 Air Bomber Eco Attack Equal" then
            -- The new resource controller serves both old resource lists. Do not
            -- let the second legacy former park the same bomber pool at home.
            former.Priority = 0
        end
        if former.AIPlan == "planEngineerCapAlloySpot" and former.AIPlanData
            and (former.AIPlanData.SearchOuterRing or 0)>100
            and name~="B1 Cap Alloys Early Parallel Range 30-1500"
            and name~="B1 Cap Alloys Rich Map Range 30-1500" then
            former.FormNumInstances=math.max(former.FormNumInstances or 1, 3)
            former.InvestmentType=nil
            for _,line in ipairs(former.NeedMobileBuilder or {}) do
                line[3]=math.min(line[3],3)
            end
        end
        if former.AIPlan == "planReclaimMap" then
            former.FormNumInstances=math.max(2,former.FormNumInstances or 1)
            for _,line in ipairs(former.NeedMobileBuilder or {}) do line[3]=math.min(line[3],2) end
        end
        if name == "F123 Land Alloy Hunter" then
            if survival then former.Priority=0 end
            former.FormNumInstances=Balance.Config.RaidInstances
            former.NeedUnits={{Tags.LAND*Tags.MOBILE*(Tags.DIRECT_FIRE+Tags.INDIRECT_FIRE+Tags.ANTI_SURFACE)
                -Tags.ENGINEER-Tags.COMMAND-Tags.SCOUT-Tags.TECH4,Balance.Config.RaidMinimum,Balance.Config.RaidMaximum,0}}
            local kept={}
            for _,condition in ipairs(former.FormerConditions or {}) do
                if condition[1]~="AtLeastSupportPlatoonUnitRatioToPrimaryPlatoon"
                    and condition[1]~="LessThanSupportPlatoonUnitRatioToPrimaryPlatoon" then kept[#kept+1]=condition end
            end
            former.FormerConditions=kept
            former.AIPlanData.RushFlank=true
            former.AIPlanData.AttackEnemyStrength=Balance.Config.RaidStrength
            former.AIPlanData.PathEnemyStrength=Balance.Config.RaidStrength
        elseif name == "F123 Land Primary" then
            former.AIPlanData.RushFlank=true
        end
        -- A disabled, missing idle-position plan should not generate startup warnings.
        if name == "Z9 Engineer Maintenance Position" then former.Priority = 0 end
    end
    -- Additional operational consumers are essential: a merge cap on its own
    -- would simply move the hoard from a primary platoon into the idle pool.
    local names = {}
    for _, f in pairs(result) do names[f.FormerName] = true end
    -- Survival retains a higher-priority local defense consumer ahead of
    -- the ordinary economic and general combat gunship groups.
    if survival and gunshipEconomy and not names["F123 Air Gunship Base Defense"] then
        local defense = Clone(gunshipEconomy)
        defense.FormerName, defense.Priority, defense.FormNumInstances = "F123 Air Gunship Base Defense", 9660, 16
        defense.RushGunshipBaseDefense, defense.RushDevelopment = true, true
        defense.RunWithStrategyName = {}
        defense.RunOnBaseType = {MAIN=true, EXPANSION=false, OUTPOST=false, NAVAL=false}
        defense.NeedUnits = {{Tags.MOBILE*Tags.AIR*Tags.GUNSHIP*Tags.ANTI_SURFACE
            *(Tags.TECH1+Tags.TECH2+Tags.TECH3)-navalAir,1,12,0}}
        defense.FormerConditions = {}
        defense.AIPlanData = {
            TargetSearchRadius = 160, GetTargetsFromBase = true, AggressiveMove = true,
            AttackEnemyStrength = 70, IgnoreLandEmergencyTargets = true,
            SelectFarthestTargetFromEnemyBase = false, AvoidDuplicateTargets = false,
            RequireMatchingTarget = true, TargetSearchCategory = Tags.MOBILE*Tags.LAND-Tags.SCOUT-Tags.ENGINEER,
            WeaponTargetPriority = {Tags.COMMAND, Tags.ANTI_AIR, Tags.ALL_UNITS},
            RushGroupingSeconds = 4,
        }
        result[#result+1] = defense
    end
    if landPrimary and not names["F123 Main Base Response"] then
        local defense=Clone(landPrimary)
        defense.FormerName,defense.Priority,defense.FormNumInstances="F123 Main Base Response",9920,4
        defense.AIPlan="planLandAttackPrimary"
        defense.RushMainDefense,defense.RushIndependent,defense.RushDevelopment=true,true,true
        defense.RunOnBaseType={MAIN=true,EXPANSION=false,OUTPOST=false,NAVAL=false}
        defense.RunWithStrategyName={};defense.FormerConditions={};defense.InvestmentType=nil
        defense.NeedUnits[1][2],defense.NeedUnits[1][3],defense.NeedUnits[1][4]=1,12,0
        defense.AIPlanData.RushUnitLimit=12
        defense.AIPlanData.RushGroupingSeconds=0
        defense.AIPlanData.IgnoreLandEmergencyTargets=false
        result[#result+1]=defense
    end
    if not names["Main Base Artillery Shield"] then
        result[#result+1]={FormerName="Main Base Artillery Shield",AIPlan="planBuildWithEngineer",
            Priority=9910,FormNumInstances=2,RushDevelopment=true,RushEmergencyShield=true,
            AIdifficulty={easy=true,medium=true,hard=true},
            RunOnBaseType={MAIN=true,EXPANSION=false,OUTPOST=false,NAVAL=false},
            RunWithStrategyName={},FormerConditions={},DebugPlatoon=false,AllowEcoStorageDrain=true,
            NeedMobileBuilder={{Tags.MOBILE*Tags.ENGINEER*(Tags.TECH2+Tags.TECH3)-Tags.COMMAND-Tags.TECH4,1,1,0}},
            WantStructures={Tags.STRUCTURE*Tags.SHIELD*(Tags.TECH2+Tags.TECH3)},WantStructuresSpacing=1,
            AvoidStructureWithinDistance={{Tags.STRUCTURE*Tags.ALLOYS_EXTRACTION,2}}}
    end
    if landPrimary and not names["F123 Siege Battery"] then
        local battery=Clone(landPrimary)
        battery.FormerName,battery.Priority,battery.FormNumInstances="F123 Siege Battery",9625,Frontline.Config.BatteryInstances
        battery.RushIndependent,battery.RushSiege,battery.RushDevelopment=true,true,true
        battery.RushNeedsGroundDamage=nil
        battery.RunOnBaseType.EXPANSION,battery.RunOnBaseType.OUTPOST=true,true
        battery.FormerConditions={}
        battery.NeedUnits={{Tags.MOBILE*Tags.LAND*(Tags.ARTILLERY+Tags.INDIRECT_FIRE)
            -Tags.ENGINEER-Tags.COMMAND-Tags.SCOUT-Tags.TECH4,1,Frontline.Config.BatteryLimit,0}}
        battery.AIPlanData.RushUnitLimit=Frontline.Config.BatteryLimit
        result[#result+1]=battery
    end
    if landPrimary and not names["F123 Land Task Force"] then
        local wave = Clone(landPrimary)
        wave.FormerName, wave.Priority, wave.FormNumInstances = "F123 Land Task Force", 9525, CombatPolicy.Config.WaveInstances
        wave.RushIndependent = true
        wave.RunOnBaseType.EXPANSION, wave.RunOnBaseType.OUTPOST = true, true
        wave.NeedUnits[1][2], wave.NeedUnits[1][3] = 4, CombatPolicy.Config.WaveLimit
        wave.AIPlanData.RushUnitLimit = CombatPolicy.Config.WaveLimit
        result[#result + 1] = wave
    end
    if landPrimary and not names["F123 Field Recovery"] then
        local field=Clone(landPrimary)
        field.FormerName,field.Priority,field.FormNumInstances="F123 Field Recovery",9530,8
        field.RushIndependent,field.RushFieldRecovery,field.RushDevelopment=true,true,true
        field.RushNeedsGroundDamage=nil
        field.RunOnBaseType={MAIN=true,EXPANSION=false,OUTPOST=false,NAVAL=false}
        field.FormerConditions={}
        field.NeedUnits[1][2],field.NeedUnits[1][3],field.NeedUnits[1][4]=1,CombatPolicy.Config.WaveLimit,0
        field.AIPlanData.RushUnitLimit=CombatPolicy.Config.WaveLimit
        result[#result+1]=field
    end
    if landPrimary and not names["F123 Land Rearguard Sweep"] then
        local sweep = Clone(landPrimary)
        sweep.FormerName, sweep.Priority, sweep.FormNumInstances = "F123 Land Rearguard Sweep", 9515, survival and 1 or 8
        sweep.RushIndependent, sweep.RushIdleSweep = true, true
        sweep.RunOnBaseType.EXPANSION, sweep.RunOnBaseType.OUTPOST = true, true
        sweep.NeedUnits[1][2], sweep.NeedUnits[1][3] = 1, 12
        -- NeedUnits caps intake; RushUnitLimit also caps later refills and merges.
        sweep.AIPlanData.RushUnitLimit = survival and 12 or CombatPolicy.Config.WaveLimit
        result[#result + 1] = sweep
    end
    if landPrimary and not survival and not names["F123 Alloy Pressure"] then
        local raid=Clone(landPrimary)
        raid.FormerName,raid.Priority,raid.FormNumInstances="F123 Alloy Pressure",9540,6
        raid.RushIndependent,raid.RushRaider,raid.RushDevelopment=true,true,true
        raid.FormerConditions={}
        raid.RunOnBaseType.EXPANSION,raid.RunOnBaseType.OUTPOST=true,true
        raid.NeedUnits={{Tags.MOBILE*Tags.LAND*(Tags.DIRECT_FIRE+Tags.ANTI_SURFACE)-Tags.ENGINEER-Tags.COMMAND-Tags.SCOUT-Tags.TECH4,Balance.Config.RaidMinimum,Balance.Config.RaidMaximum,0}}
        raid.AIPlanData.RushUnitLimit=Balance.Config.RaidMaximum
        raid.AIPlanData.AttackEnemyStrength=Balance.Config.RaidStrength
        raid.AIPlanData.PathEnemyStrength=Balance.Config.RaidStrength
        raid.AIPlanData.IgnoreLandEmergencyTargets=true
        result[#result+1]=raid
    end
    if airPrimary and not names["F123 Air Patrol Wing"] then
        local wing = Clone(airPrimary)
        wing.FormerName, wing.Priority, wing.FormNumInstances = "F123 Air Patrol Wing", 9525, 16
        wing.RushIndependent = true
        wing.NeedUnits[1][2], wing.NeedUnits[1][3] = 2, 48
        wing.AIPlanData.RushUnitLimit = 48
        result[#result + 1] = wing
    end
    result=Heavy.NormalizeFormers(army,Development.AddFormers(army,result))
    result=Expansion.AddFormer(army,result)
    result=Beachhead.AddFormers(army,result)
    if landPrimary and not names["Beachhead inland army"] then
        local assault=Clone(landPrimary)
        assault.FormerName="Beachhead inland army";assault.Priority=9585;assault.FormNumInstances=4
        assault.RushBeachheadAssault=true;assault.RushIndependent=true;assault.RushDevelopment=true
        assault.RushSupportCap=nil;assault.RushSupportPrimary=nil;assault.RushFieldRecovery=nil;assault.RushIdleSweep=nil
        assault.RunOnBaseType={MAIN=true,EXPANSION=true,OUTPOST=true,NAVAL=false}
        assault.RunWithStrategyName={};assault.FormerConditions={}
        assault.NeedUnits={{Tags.MOBILE*Tags.LAND-Tags.ENGINEER-Tags.COMMAND-Tags.SCOUT-Tags.TECH4,4,18,2}}
        assault.AIPlanData.RushCombatPolicy=true;assault.AIPlanData.RushUnitLimit=18
        assault.AIPlanData.IgnoreLandEmergencyTargets=false
        result[#result+1]=assault
    end
    if navalPrimary and not names["Amphibious naval assault"] then
        local assault=Clone(navalPrimary)
        assault.FormerName="Amphibious naval assault";assault.Priority=9640;assault.FormNumInstances=12
        assault.AIPlan="planNavalAttack";assault.RushAmphibiousNaval=true;assault.RushIndependent=true
        assault.RunWithStrategyName={};assault.FormerConditions={};assault.UseNavalAreaUnits=nil
        assault.RunOnBaseType={MAIN=true,EXPANSION=true,OUTPOST=true,NAVAL=true}
        assault.NeedUnits={{Tags.MOBILE*Tags.NAVAL-Tags.ENGINEER-Tags.SCOUT-Tags.TECH4,1,8,0}}
        result[#result+1]=assault
    end
    result=AirDefense.AddFormers(army,result)
    for _,f in pairs(result) do
        local kept={}
        for _,condition in ipairs(f.FormerConditions or {}) do
            if condition[1]~="MoreThanGameTimeSeconds" and condition[1]~="LessThanGameTimeSeconds" then kept[#kept+1]=condition end
        end
        f.FormerConditions=kept
        local name=f.FormerName or ""
        if name=="T1 Factory Air 1:2 Ratio Land" or f.RushEarlyAir then f.AllowEcoStorageDrain=false end
        if name=="B1 Energy Maintenance" or name=="B1 Energy Generator <-100% Urgent" then
            for _,condition in ipairs(f.FormerConditions) do
                if condition[1]=="LessThanEcoStorageLevel" then condition[2][2]=75 end
            end
        end
        if name=="B1 Factory Land Sixth Economic Start" or name=="BC123 Factory Land Recover 2nd good ECO" then
            f.RushStoredCost=true
            local conditions={}
            for _,condition in ipairs(f.FormerConditions) do
                if condition[1]~="MoreThanEcoStorageAmount" then conditions[#conditions+1]=condition end
            end
            f.FormerConditions=conditions
        end
        if f.NeedUpgradeableUnit then
            for _,line in ipairs(f.NeedUpgradeableUnit) do
                for id in pairs(line[1] or {}) do
                    local tp=Template(id)
                    if Balance.FactoryDomain(tp) then f.RushAnyFactoryUpgrade=true end
                    if Has(tp,"LAND_FACTORY") and Has(tp,"TECH1") then f.RushLandT1Upgrade=true end
                    if Has(tp,"AIR_FACTORY") and Has(tp,"TECH2") then f.RushAirT3Upgrade=true end
                end
            end
        end
        if f.RushAnyFactoryUpgrade and not f.RushTechProject then
            f.Priority,f.FormNumInstances=0,0
        end
        if f.AIPlan=="planNavalAttack" or f.AIPlan=="planNavalAttackPrimary" or f.AIPlan=="planSupportNavalPrimaryPlatoon" then
            f.RushFleet=true;f.RushDevelopment=true
            f.FormerConditions={}
            f.FormNumInstances=f.RushAmphibiousNaval and 12 or 24
            if f.NeedUnits then for _,line in ipairs(f.NeedUnits) do line[2]=1;line[3]=math.min(line[3],16);line[4]=0 end end
            f.AIPlanData=f.AIPlanData or {};f.AIPlanData.AttackEnemyStrength=120
        end
    end
    return result
end

-- Native KillThread leaves a suspended coroutine behind. Heartbeats detect that
-- case as well as errors, while worker-handle and base identity fence old owners.
local function StaleThread(thread, heartbeat, timeout)
    return thread == nil or type(thread) == "thread" and
        (coroutine.status(thread) == "dead" or heartbeat and Now() - heartbeat > timeout)
end

AdoptBase = function(armyIndex, baseName)
    local army = Armies[armyIndex]
    if not IsRushArmy(army) or army.ai.isAlive == false then return end
    local base = army.ai.bases and army.ai.bases[baseName]
    if not base then return end
    local first = base.rushControllerVersion ~= Version
    if first then Layout.ResizeBase(army, baseName, base) end
    base.luaThreads = base.luaThreads or {}
    local function maintain(key, heartbeat, fn, timeout)
        local old = base.luaThreads[key]
        if old and type(old) ~= "thread" then
            Report(army, "base adoption " .. baseName, "unknown thread handle; original manager retained")
            return
        end
        if first or StaleThread(old, base[heartbeat], timeout) then
            if old then KillThread(old) end
            base[heartbeat] = Now()
            base.luaThreads[key] = NewThread(fn, armyIndex, baseName)
            if not first then
                Log("[RushRecovery] army=" .. armyIndex .. " event=scheduler-restarted base=" .. baseName .. " lane=" .. key, true)
            end
        end
    end
    maintain("RushProductionThread", "rushProductionHeartbeat", ProductionThread, 10)
    -- Selection can yield during navigation/placement. Allow a generous window;
    -- terminating this selector never cancels the independently dispatched work.
    maintain("AILocationManagerThread", "rushLocationHeartbeat", LocationThread, 90)
    base.rushControllerVersion = Version
    EnsureSupervisor(army)
end

local function ClearUnavailableMainResponse(army)
    local ai=army and army.ai
    if not ai or IsRushArmy(army) and ai.isAlive~=false and ai.bases and ai.bases.MAIN then return end
    ai.rushMainAlarm=nil
    local bombers=ai.rushBombers;local response=bombers and bombers.response
    if response and response.armyAI==ai then
        response.members={};bombers.response=nil
    end
end
function MaintainProduction(army)
    ClearUnavailableMainResponse(army)
    Development.CleanupCommanderInvestment(army)
    Heavy.CleanupUnavailable(army)
    if not IsRushArmy(army) or army.ai.isAlive == false then return end
    local names = {}
    for name in pairs(army.ai.bases or {}) do names[#names + 1] = name end
    table.sort(names)
    for _, name in ipairs(names) do
        local ok, err = pcall(AdoptBase, army.id, name)
        if not ok then Report(army, "base recovery " .. name, err) end
    end
    if Health.RecoverFactories(army, Snapshot(army).factories, CanFactoryBuild, Report) then State(army).snapshot = nil end
end

function SupervisionThread(armyIndex)
    local army = Armies[armyIndex]
    local ai = army and army.ai
    if not ai or not IsRushArmy(army) then return end
    local state, worker = State(army), coroutine.running()
    while Armies[armyIndex] == army and army.ai == ai and ai.isAlive ~= false and state.supervisor == worker do
        state.supervisorHeartbeat = Now()
        local ok, err = pcall(MaintainProduction, army)
        if not ok then Report(army, "production supervision", err) end
        WaitTicks(Ticks(2))
    end
    if Armies[armyIndex]==army and army.ai==ai then
        ClearUnavailableMainResponse(army)
        Development.CleanupCommanderInvestment(army)
        local ok,err=pcall(Heavy.CleanupUnavailable,army)
        if not ok then Report(army,"heavy service shutdown",err) end
    end
end

EnsureSupervisor = function(army)
    local state = State(army)
    if StaleThread(state.supervisor, state.supervisorHeartbeat, 15) then
        if type(state.supervisor) == "thread" then KillThread(state.supervisor) end
        state.supervisorHeartbeat = Now()
        state.supervisor = NewThread(SupervisionThread, army.id)
    end
end

function Install()
    if installed then return end
    local creator = Import("AI/AILocationCreator.lua")
    if type(creator.CreateExpansion) ~= "function" or type(AF.GetFormersFromFile) ~= "function"
        or type(NewThread) ~= "function" or type(KillThread) ~= "function" then
        Log("[RushV9] Required base/thread API is unavailable; original AI retained.", true)
        return
    end
    installed = true
    Reliability.Install(IsRushArmy)
    Health.Install(IsRushArmy)
    Layout.Install(IsRushArmy)
    NavalConstruction.Install(IsRushArmy)
    Beachhead.Configure({Snapshot=Snapshot,IsRushArmy=IsRushArmy,ProductionRates=ProductionRates})
    Development.Configure({Snapshot=Snapshot, SnapshotForBase=SnapshotForBase, SnapshotForFactory=SnapshotForFactory, SnapshotForSupport=SupportView, IsRushArmy=IsRushArmy, ProductionRates=ProductionRates})
    Balance.Configure(Snapshot,Development.PendingInvestmentReserve,Development.PendingCommanderReserve,Heavy.PendingInvestmentReserve)
    local originalRanger = creator.BaseRanger
    if type(originalRanger) == "function" then
        creator.BaseRanger = function(armyIndex, ...)
            originalRanger(armyIndex, ...)
            local army=Armies[armyIndex]
            if not IsRushArmy(army) then return end
            for name,base in pairs(army.ai.bases or {}) do
                -- Each base keeps its own growth envelope, without compounding
                -- radius scaling every time the native ranger is recomputed.
                Layout.ResizeBase(army,name,base)
            end
        end
    end
    local originalCreate = creator.CreateExpansion
    creator.CreateExpansion = function(armyIndex, baseName, position, baseType, ...)
        originalCreate(armyIndex, baseName, position, baseType, ...)
        AdoptBase(armyIndex, baseName)
    end
    local originalFormers = AF.GetFormersFromFile
    AF.GetFormersFromFile = function(armyIndex, ...)
        local result = originalFormers(armyIndex, ...)
        return NormalizeFormers(Armies[armyIndex], result)
    end
    for index, army in pairs(Armies or {}) do
        if IsRushArmy(army) then
            local pool = army.ai.formerpool
            if pool and next(pool) then
                local normalized = NormalizeFormers(army, pool)
                for key in pairs(pool) do pool[key] = nil end
                for key, former in pairs(normalized) do pool[key] = former end
            end
            for name in pairs(army.ai.bases or {}) do AdoptBase(index, name) end
        end
    end
end

Development.Configure({Snapshot=Snapshot, SnapshotForBase=SnapshotForBase, SnapshotForFactory=SnapshotForFactory, SnapshotForSupport=SupportView, IsRushArmy=IsRushArmy, ProductionRates=ProductionRates})
Balance.Configure(Snapshot,Development.PendingInvestmentReserve,Development.PendingCommanderReserve,Heavy.PendingInvestmentReserve)
Beachhead.Configure({Snapshot=Snapshot,IsRushArmy=IsRushArmy,ProductionRates=ProductionRates})
