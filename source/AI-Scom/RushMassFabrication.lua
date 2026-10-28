-- Convert sustained spare Energy into Alloys through native construction and toggles.
local AF=Import("AI/AIFunctions.lua")
local Rules=Import("AI/mods/AI-Scom/RushBalance.lua")
local Reliability=Import("AI/mods/AI-Scom/RushReliability.lua")
local Economy=Import("AI/mods/AI-Scom/RushEconomyPolicy.lua")
local HeavyPolicy=Import("AI/mods/AI-Scom/RushHeavyPolicy.lua")
local Controller

function Configure(controller) Controller=controller end
local function Now() return GetGameTimeSeconds() end
local function Finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function Number(n) return Finite(n) and n or 0 end
local function Template(id) return __Templates and __Templates.Units and __Templates.Units[id] end
local function Has(tp,tag) return Reliability.Has(tp,tag) end
function Maintenance(tp)
    return math.max(0,Number(((tp and tp.economy or {}).maintenanceConsumption or {}).energy))
end
local function Production(tp)
    return math.max(0,Number(((tp and tp.economy or {}).production or {}).alloys))
end
function IsFabricator(tp)
    return Has(tp,"STRUCTURE") and (Has(tp,"SCFA_MASSFABRICATION") or Has(tp,"ALLOYS_PRODUCTION"))
        and not Has(tp,"ALLOYS_EXTRACTION") and not HeavyPolicy.IsT4(tp)
        and Maintenance(tp)>0 and Production(tp)>0 and not (tp.economy or {}).narutalProducer
end
local function Enabled(army)
    return Controller and army and army.ai and army.ai.isAlive~=false and Controller.IsRushArmy(army)
end
local function State(army)
    army.ai.rushMassFabrication=army.ai.rushMassFabrication or {paused={}}
    return army.ai.rushMassFabrication
end
local function Target(builder,id)
    local order=builder.orders and builder.orders.activeOrder
    local target=builder.unitBeingBuilt or builder.buildBehaviorIsActive and builder.buildBehaviorActualUnit
        or order and order.unitGettingBuilt
    if target and (not id or target.tpId==id) then return target end
    local work=builder.ai and builder.ai.rushConstructionQueue
    local queue=work and work.queue
    for _,entry in ipairs(queue and queue.entries or {}) do
        if (not id or entry.id==id) and Rules.Own(builder.army,entry.target) then return entry.target end
    end
end
local function Fabricators(army,snapshot)
    local units=snapshot.rushFabricators
    if not units then
        units={};snapshot.rushFabricators=units
        for _,unit in pairs(army.units or {}) do
            if Rules.Own(army,unit) and IsFabricator(unit.tp) then units[#units+1]=unit end
        end
    end
    return units
end
local function Selectors(tier)
    local engineers=Tags.MOBILE*Tags.ENGINEER*(tier==2 and (Tags.TECH2+Tags.TECH3) or Tags.TECH3)
    return engineers,Tags.STRUCTURE*(Tags.SCFA_MASSFABRICATION+Tags.ALLOYS_PRODUCTION)*Tags["TECH"..tier]
end

local function RecordOwned(army,record)
    return record and record.armyAI==army.ai and Rules.Own(army,record.unit)
        and record.unit.toggles==record.toggles and Finite(record.since) and record.since<=Now()
end

-- The shared census caches only the unit list. Completion, pending native
-- orders and new platoon assignments are checked live at each admission.
local function Commitments(army,except,snapshot)
    local upkeep,pending,disabled=0,false,false
    local seen,represented={},{}
    local function observe(unit)
        if not Rules.Own(army,unit) or not IsFabricator(unit.tp) then return false end
        if seen[unit] then return true end
        seen[unit]=true
        if not unit:IsCompleted() then upkeep=upkeep+Maintenance(unit.tp);pending=true
        elseif type(unit.GetProductionToggle)=="function" and not unit:GetProductionToggle()
            and not (type(unit.GetPause)=="function" and unit:GetPause()) then
            local records=army.ai.rushMassFabrication and army.ai.rushMassFabrication.paused
            local record=records and records[unit.id.index]
            -- Reuse capacity that we can actually restart. An explicitly off
            -- or captured-off unit is not an AI-owned pending investment.
            if record and record.unit==unit and RecordOwned(army,record) then disabled=true end
        end
        return true
    end
    for _,unit in ipairs(Fabricators(army,snapshot)) do observe(unit) end
    for index,reservation in pairs(army.ai.ecoReserve or {}) do
        local builder=army.units[index]
        local tp=Template(reservation.tpId)
        if builder~=except and Rules.Own(army,builder) and IsFabricator(tp) then
            if not observe(Target(builder,reservation.tpId)) then upkeep=upkeep+Maintenance(tp) end
            pending=true
            if builder.platoon then represented[builder.platoon]=true end
        end
    end
    for _,platoon in pairs(army.platoons or {}) do
        local data=platoon.ai
        local former=data and data.formerTable
        if not platoon.dead and not platoon.deleted and army:PlatoonExists(platoon)
            and data and data.eState~="Disband" and former and former.RushMassFabrication
            and (not except or platoon~=except.platoon) then
            local assigned,found=false,false
            for _,builder in ipairs(platoon:GetUnits()) do
                if Rules.Own(army,builder) and builder.platoon==platoon then
                    assigned=true
                    if observe(Target(builder)) then found=true end
                end
            end
            local foundation=observe(data.buildedUnit)
            -- The native plan selects a product before assigning its builder.
            -- Its own empty startup platoon has no resource commitment yet;
            -- the controller already serializes the investment itself.
            if assigned or foundation then
                pending=true
                if not represented[platoon] and not found and not foundation then
                    local maximum=0
                    for _,line in ipairs(former.WantStructures or {}) do
                        for id,on in pairs(line) do
                            local tp=on and Template(id)
                            if IsFabricator(tp) then maximum=math.max(maximum,Maintenance(tp)) end
                        end
                    end
                    upkeep=upkeep+maximum
                end
            end
        end
    end
    return upkeep,pending,disabled
end
local function Margin(snapshot,energy)
    -- The actual technology reserve is already deducted by Resources. Only
    -- its still-unreserved power forecast needs another margin here.
    return math.max(Economy.PowerHeadroom(snapshot),
        math.max(0,Number(snapshot.techPowerHeadroom)-Number(energy.techReserved)))
end
local function Useful(alloy)
    return alloy and (alloy.ratio<0.95 or Rules.Balance(alloy)<0)
end

-- Full native requests include construction stalled by missing Alloys. Only
-- credit that unused Energy while real storage and satisfaction prove it is
-- available, and price the work that extra fabricated Alloys can unlock.
-- This reads live registered entities; no snapshot can retain stale credit.
local function AlloyLimitedPower(army,alloy,energy,minimumRatio)
    local economy=army.economy
    local totals=economy and economy.totals
    local mass,power=totals and totals.alloys,totals and totals.energy
    if not mass or not power or economy.isEnergyDown or energy.ratio<minimumRatio
        or not Finite(mass.satisfaction) or mass.satisfaction<0 or mass.satisfaction>=1
        or not Finite(power.satisfaction) or power.satisfaction<1
        or alloy.request<=alloy.income or not Finite(power.outcome) or power.outcome<0
        or power.income<=power.outcome then return 0,0 end
    local tick=Constants and Constants.TickRate or 10
    if not Finite(tick) or tick<=0 then return 0,0 end
    local credit,ratio=0,0
    local entities=economy.resourceEntities and economy.resourceEntities.construction
    for key,entity in pairs(entities or {}) do
        local id=entity.unitId
        local kind=type(id)
        local index=(kind=="table" or kind=="userdata") and id.index
        -- Native economy events use a scalar sentinel instead of a unit ID.
        local unit=index and army.units[index]
        local rates=entity.outcome
        local scale,paid=entity.userMultiplier,entity.productionMultiplier
        if entity.id==key and entity.category=="construction" and entity.enabled==true
            and entity.armyId==army.id and entity.economy==economy and economy.armyId==army.id
            and Rules.Own(army,unit) and unit.id==entity.unitId and rates
            and Finite(rates.alloys) and rates.alloys>0 and Finite(rates.energy) and rates.energy>0
            and Finite(scale) and scale>0 and Finite(paid) and paid>=0 and paid<=1 then
            local limited,usesAlloys=true,false
            for _,name in pairs(entity.satisfactionTable or {}) do
                local resource=totals[name]
                if name=="alloys" then usesAlloys=true end
                if not resource or not Finite(resource.satisfaction)
                    or resource.satisfaction<mass.satisfaction then limited=false;break end
            end
            if limited and usesAlloys then
                ratio=math.max(ratio,rates.energy/rates.alloys)
                -- Totals publish next-tick satisfaction after paid outcomes.
                -- Recovering Alloy must not lend yesterday's unused power.
                credit=credit+rates.energy*tick*scale*(1-math.max(paid,mass.satisfaction))
            end
        end
    end
    -- Totals and entities can straddle a native handoff. Never credit more
    -- than the actual sampled gap between requested and paid Energy.
    credit=math.min(credit,math.max(0,(power.request-power.outcome)*tick))
    if not Finite(credit) or not Finite(ratio) then return 0,0 end
    return credit,ratio
end

function CanFund(builder,id,snapshot)
    local army=builder and builder.army
    local tp=Template(id)
    if not Enabled(army) or not Rules.Own(army,builder) or not builder:IsCompleted()
        or not IsFabricator(tp) or not Reliability.AllowedTarget(id,false)
        or not Reliability.CanBuilderBuild(builder,id) or AF.IsUnderAttack(builder)
        or type(builder.GetPause)=="function" and builder:GetPause()
        or not tp.general or not tp.general.toggles
        or type(tp.general.toggles.Production)~="boolean" then return false end
    local upkeep,output=Maintenance(tp),Production(tp)
    if upkeep<=0 or output<=0 then return false end
    snapshot=snapshot or Controller.Snapshot(army)
    if not snapshot then return false end
    local a,e=Rules.Resources(army,builder)
    if not a or not e or a.income<=0 or e.income<=0 or e.ratio<0.40
        or army.economy.isEnergyDown or not Useful(a) then return false end
    local committed,pending,disabled=Commitments(army,builder,snapshot)
    if pending or disabled then return false end
    local massRate,energyRate,duration=Rules.ProjectRates(builder,id)
    if not Finite(massRate) or not Finite(energyRate) or not Finite(duration)
        or massRate<0 or energyRate<0 or duration<=0 then return false end
    local massBank=math.max(0,a.current-a.storage*0.15)/duration
    local energyBank=math.max(0,e.current-e.storage*0.15)/duration
    local massCovered=Rules.Balance(a)+massBank>=massRate
    if not massCovered then
        -- One cheap fabricator may improve a mass-starved economy while native
        -- construction runs supply-limited. Technology commitments keep priority.
        if a.techOwner or a.commanderOwner or Number(snapshot.upgrades)>0
            or massRate>a.income*0.30+massBank
            or a.request+a.reserved+massRate>a.income*2 then return false end
    end
    local margin=Margin(snapshot,e)
    local free=Rules.Balance(e)-math.max(0,committed-Number(e.fabricationReserved))
    -- Upkeep needs sustained income; only the finite construction cost can
    -- borrow stored Energy. Never price an adjacency discount before it exists.
    if free>=upkeep+margin and free+energyBank>=energyRate+upkeep+margin then return true end
    local credit,ratio=AlloyLimitedPower(army,a,e,0.85)
    local unlocked=math.min(credit,output*ratio)
    free=free+credit
    return credit>0 and free>=upkeep+unlocked+margin
        and free+energyBank>=energyRate+upkeep+unlocked+margin
end

function Check(armyIndex,baseName,tier)
    local army=Armies[armyIndex]
    if not Enabled(army) then return false end
    local base=army.ai.bases and army.ai.bases[baseName]
    if not base or base.baseType=="NAVAL" or tier~=2 and tier~=3 then return false end
    local snapshot=Controller.Snapshot(army)
    if not snapshot or not Useful(snapshot.alloy) then return false end
    local engineers,products=Selectors(tier)
    local former={FormerName="Mass fabrication budget",NeedMobileBuilder={{engineers,1,1,0}},
        WantStructures={products},AllowEcoStorageDrain=true}
    for _,builder in ipairs(AF.GetNeedMobileBuilder(armyIndex,baseName,former) or {}) do
        for id,on in pairs(products) do
            if on and CanFund(builder,id,snapshot) then return true end
        end
    end
    return false
end

function AddFormers(army,formers)
    local present=false
    for _,former in pairs(formers) do
        if former.FormerName=="T1 Alloy Furnace" then former.Priority,former.FormNumInstances=0,0 end
        if former.RushMassFabrication then present=true end
    end
    if present then return formers end
    for tier=2,3 do
        local engineers,products=Selectors(tier)
        formers[#formers+1]={
            FormerName="R9 T"..tier.." mass fabrication",AIPlan="planBuildWithEngineer",
            Priority=tier==2 and 9592 or 9590,FormNumInstances=1,InvestmentType="MassFabrication",
            AIdifficulty={easy=true,medium=true,hard=true},
            RunOnBaseType={MAIN=true,EXPANSION=true,OUTPOST=true,NAVAL=false},
            RunWithStrategyName={},RushDevelopment=true,RushMassFabrication=true,
            NeedMobileBuilder={{engineers,1,1,0}},WantStructures={products},
            WantStructuresSpacing=0,FormerConditions={{Check,{tier}}},
            AllowEcoStorageDrain=true,DebugPlatoon=false,
        }
    end
    return formers
end

function ValidateBuild(platoon,builder,id,position)
    local army=builder and builder.army
    local data=platoon and platoon.ai
    local former=data and data.formerTable
    return former and former.RushMassFabrication and position
        and Finite(position.x) and Finite(position.z) and Rules.Own(army,builder)
        and Reliability.CurrentAssignment(builder,army,platoon,builder.ai,data)
        and CanFund(builder,id) or false
end

-- Only our accepted native construction can authorize startup of a blueprint
-- whose Production toggle defaults off. Existing/manual-off units stay alone.
function RegisterBuild(army,unit)
    if not Enabled(army) or not Rules.Own(army,unit) or not IsFabricator(unit.tp) then return end
    local snapshot=Controller.Snapshot(army)
    local units=snapshot and snapshot.rushFabricators
    if units then
        local present=false
        for _,existing in ipairs(units) do if existing==unit then present=true;break end end
        -- Keep the accepted foundation visible even if its builder is lost
        -- before the next census. A default-on blueprint needs this too.
        if not present then units[#units+1]=unit end
    end
    if not unit.tp.general or not unit.tp.general.toggles
        or unit.tp.general.toggles.Production~=false
        or type(unit.GetProductionToggle)~="function" or unit:GetProductionToggle() then return end
    local records=State(army).paused
    records[unit.id.index]={unit=unit,armyAI=army.ai,toggles=unit.toggles,since=Now(),startup=true}
end
local function Demand(unit)
    local army=unit.army
    local entity=unit.resourceEntities and unit.resourceEntities.production
    local economy=entity and entity.economy
    if entity and entity.category=="production" and entity.unitId==unit.id and entity.armyId==army.id
        and economy==army.economy and economy.armyId==army.id
        and entity.outcome and Finite(entity.outcome.energy) and entity.outcome.energy>=0
        and Finite(entity.userMultiplier) and entity.userMultiplier>=0 then
        local tick=Constants and Constants.TickRate or 10
        local registered=economy.resourceEntities and economy.resourceEntities.production
        local active=entity.enabled==true and registered and registered[entity.id]==entity
        local drain=entity.outcome.energy*tick*entity.userMultiplier
        local output=math.max(0,Number(entity.income and entity.income.alloys))*tick*entity.userMultiplier
        if Finite(drain) and Finite(output) then return drain,active,output end
    end
    return Maintenance(unit.tp),false,Production(unit.tp)
end

function Update(army,snapshot,plans)
    if not Enabled(army) then return end
    snapshot=snapshot or Controller.Snapshot(army)
    if not snapshot then return end
    local a,e=Rules.Resources(army)
    if not a or not e then return end
    local records,units=State(army).paused,{}
    local changed,released=false,0
    local upkeep=Commitments(army,nil,snapshot)
    upkeep=math.max(0,upkeep-Number(e.fabricationReserved))
    local strictFree,margin=Rules.Balance(e)-upkeep,Margin(snapshot,e)
    local credit,ratio=AlloyLimitedPower(army,a,e,0.50)
    local free=strictFree+credit
    local low=army.economy.isEnergyDown or free<0
        and (e.ratio<0.30 or e.current+free*20<e.storage*0.20)
    local waste=a.ratio>=0.97 and Rules.Balance(a)>0
    for _,unit in ipairs(Fabricators(army,snapshot)) do
        if Rules.Own(army,unit) and unit:IsCompleted() and type(unit.SetToggle)=="function"
            and type(unit.GetProductionToggle)=="function" then
            local drain,active,output=Demand(unit)
            units[#units+1]={unit=unit,drain=drain,active=active,output=output,
                efficiency=output>0 and drain/output or math.huge}
        end
    end
    -- Shed the least efficient drains first; resume efficient units against one
    -- shared live budget. The native entity already includes adjacency effects.
    table.sort(units,function(a,b)
        if a.efficiency~=b.efficiency then return a.efficiency>b.efficiency end
        return a.drain>b.drain or a.drain==b.drain and a.unit.id.index<b.unit.id.index
    end)
    for _,item in ipairs(units) do
        local unit=item.unit
        local key,record=unit.id.index,records[unit.id.index]
        if record and (record.unit~=unit or not RecordOwned(army,record)
            or type(unit.GetPause)=="function" and unit:GetPause()) then records[key]=nil;record=nil end
        -- Native completion may enable the production entity while leaving a
        -- default-off toggle untouched. Adopt only our accepted startup: its
        -- live drain is already running, so this costs no second upkeep charge.
        if record and record.startup and item.active and not unit:GetProductionToggle() then
            unit:SetToggle("Production",true)
            if unit:GetProductionToggle() then records[key]=nil;record=nil;changed=true end
        end
        if unit:GetProductionToggle() and not (type(unit.GetPause)=="function" and unit:GetPause()) then
            if record then records[key]=nil end
            if waste or low and free<margin then
                unit:SetToggle("Production",false)
                if not unit:GetProductionToggle() then
                    records[key]={unit=unit,armyAI=army.ai,toggles=unit.toggles,since=Now()}
                    changed=true
                    if item.active then
                        strictFree=strictFree+item.drain;free=strictFree+credit;released=released+item.drain
                    end
                end
            end
        end
    end
    for i=#units,1,-1 do
        local item=units[i];local unit=item.unit
        local record=records[unit.id.index]
        local addedDrain=item.active and 0 or item.drain
        local unlocked=item.active and 0 or math.min(credit,item.output*ratio)
        if RecordOwned(army,record) and not unit:GetProductionToggle()
            and not (type(unit.GetPause)=="function" and unit:GetPause())
            and (record.startup or Now()-record.since>=12) and not army.economy.isEnergyDown
            and (record.startup and Useful(a) or not record.startup and (a.ratio<0.80 or Rules.Balance(a)<0))
            and e.ratio>=(record.startup and 0.40 or 0.50)
            and (strictFree>=addedDrain+margin
                or e.ratio>=0.85 and free>=addedDrain+unlocked+margin) then
            unit:SetToggle("Production",true)
            if unit:GetProductionToggle() then
                records[unit.id.index]=nil
                strictFree=strictFree-addedDrain;credit=math.max(0,credit-unlocked)
                free=strictFree+credit;released=released-addedDrain;changed=true
            end
        end
    end
    for key,record in pairs(records) do
        if not RecordOwned(army,record) then records[key]=nil end
    end
    e.reserved=(e.reserved or 0)+upkeep
    e.fabricationReserved=Number(e.fabricationReserved)+upkeep
    if changed then
        e.balance=e.balance+released
        e.request=math.max(0,e.request-released)
    end
    return changed,e
end
