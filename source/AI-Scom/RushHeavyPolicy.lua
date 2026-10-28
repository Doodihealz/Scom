-- Runtime faction rosters and capability-based heavy investment. Native menus,
-- availability, prices and host construction permissions remain authoritative.
Version = "9.0.7-rc8"
Factions = {"EDA", "CHOSEN", "GUARD", "SERAPHIM"}
local factionAliases={"SCFA_UEF","SCFA_AEON","SCFA_CYBRAN","SCFA_SERAPHIM"}
local profiles=setmetatable({},{__mode="k"})
local function Has(tp,tag)
    if type(tp)~="table" then return false end
    if tp.hasTags and tp.hasTags[tag] then return true end
    for _,t in ipairs(tp.tags or {}) do if t==tag then return true end end
    return false
end
local function Value(n)
    return type(n)=="number" and n==n and math.abs(n)<math.huge and n or 0
end
local function Significant(tp)
    return type(tp)=="table" and not Has(tp,"COMMAND") and not Has(tp,"SCFA_COMMAND")
        and not Has(tp,"SCFA_SUBCOMMANDER") and not Has(tp,"INSIGNIFICANTUNIT")
        and not Has(tp,"SCFA_INSIGNIFICANTUNIT") and not Has(tp,"SCFA_UNSELECTABLE")
        and not Has(tp,"SCFA_CIVILIAN") and not Has(tp,"DEMO_UI_ONLY")
end
function Enabled(a)
    local s=a and a.ai and a.ai.settings
    if not s then return false end
    local d=tostring(s.modDirectory or ""):gsub("\\","/"):gsub("/+$","")
    return d=="AI/mods/AI-Scom" or d:sub(-#"/AI-Scom")=="/AI-Scom"
        or (d=="" and s.modName=="AI-Scom")
end
function IsT4(tp)
    return Has(tp,"TECH4") or Has(tp,"SCFA_EXPERIMENTAL") or Has(tp,"EXPERIMENTAL")
        or Value(tp and tp.general and tonumber(tp.general.techNumber))>=4
end
function IsExperimental(tp) return Significant(tp) and IsT4(tp) or false end
function IsArtillery(tp)
    return Has(tp,"ARTILLERY") or Has(tp,"SCFA_ARTILLERY")
end
function Domain(tp)
    local movement=tp and tp.movement or {};local kind=movement.type
    if movement.air or Has(tp,"AIR") or Has(tp,"SCFA_AIR") or kind=="Plane" or kind=="Gunship" then return "air" end
    if Has(tp,"NAVAL") or Has(tp,"SCFA_NAVAL") or kind=="UnderWater"
        or kind=="TracksWater" or kind=="WaterSurface" or kind=="Sea" or kind=="Submarine" then return "naval" end
    return "land"
end
function Profile(tp)
    if type(tp)~="table" then return nil end
    local cached=profiles[tp];if cached then return cached end
    local e=tp.economy or {};local output=e.production or {}
    local movement=tp.movement or {};local mt=movement.type
    local health=tp.defence and tp.defence.health
    health=type(health)=="table" and Value(health.max) or Value(health)
    local profile={domain=Domain(tp),mobile=Has(tp,"MOBILE") or Has(tp,"SCFA_MOBILE"),
        structure=Has(tp,"STRUCTURE") or Has(tp,"SCFA_STRUCTURE"),
        massOutput=math.max(0,Value(output.alloys)),energyOutput=math.max(0,Value(output.energy)),
        health=health,
        speed=math.max(0,Value(movement.speed)),range=0,area=0,armed=false,
        amphibious=mt=="Hover" or mt=="TracksAmphibious" or mt=="LegsAmphibious"
            or mt=="TracksSeabed" or mt=="LegsSeabed",
        factory=Has(tp,"FACTORY") or Has(tp,"SCFA_FACTORY") or tp.construction
            and type(tp.construction.canBuild)=="table" and next(tp.construction.canBuild)~=nil}
    for _,w in ipairs(tp.weapons or {}) do
        local damage=Value(w.damage)+Value(w.damageOverTimePulseCount)*Value(w.damageOverTimePulseDamage)
        if w.category~="DeathExplosion" and not w.isDeathExplosion and damage>0 and Value(w.rangeMax)>0 then
            profile.armed=true
            profile.range=math.max(profile.range,Value(w.rangeMax))
            profile.area=math.max(profile.area,Value(w.damageRadius))
        end
    end
    profile.shield=Has(tp,"SHIELD") or Has(tp,"SCFA_SHIELD")
        or type(tp.defence and tp.defence.shields)=="table" and next(tp.defence.shields)~=nil
    profile.economic=profile.massOutput>0 or profile.energyOutput>0 or Has(tp,"ECONOMIC")
        or Has(tp,"SCFA_ECONOMIC") or Has(tp,"ALLOYS_PRODUCTION") or Has(tp,"ENERGY_PRODUCTION")
    profile.artillery=IsArtillery(tp)
    profile.nuclear=Has(tp,"NUKE") or Has(tp,"SCFA_NUKE")
    profile.strategic=profile.nuclear or Has(tp,"STRATEGIC") or Has(tp,"SCFA_STRATEGIC")
    profiles[tp]=profile
    return profile
end
function IsCombatExperimental(tp)
    local p=IsExperimental(tp) and Profile(tp)
    return p and p.mobile and p.armed or false
end
function AllowsTarget(a,id)
    if not Enabled(a) then return true end
    local tp=__Templates and __Templates.Units and __Templates.Units[id]
    if not tp then return false end
    -- Captured native builders still use their own real faction build menu.
    -- No experimental name whitelist restricts an otherwise legal template.
    return not IsT4(tp) or IsExperimental(tp)
end
function FactionMatches(a,tp)
    local index=type(a)=="number" and a or a and a.faction
    local faction=Factions[index]
    return faction and (Has(tp,faction) or Has(tp,factionAliases[index])) or false
end
function Kind(a,tp)
    if not FactionMatches(a,tp) or not tp.general or not tp.general.tpId or not Significant(tp) then return nil end
    local p=Profile(tp)
    if not IsT4(tp) then
        local t3=Has(tp,"TECH3") or Has(tp,"SCFA_TECH3") or Value(tonumber(tp.general.techNumber))==3
        if p.structure and p.artillery and t3 and not p.mobile then return "artillery" end
        return nil
    end
    -- Armed mobile factories/carriers remain combat units even when a broad
    -- ECONOMIC tag also describes their construction capability.
    if p.mobile and p.armed then return p.domain end
    if p.structure and not p.mobile then
        if p.nuclear then return "strategic" end
        if p.artillery and p.armed then return "siege" end
        if p.strategic and p.armed then return "strategic" end
        if p.economic then return "economy" end
        if p.strategic then return "strategic" end
        if p.shield then return "shield" end
        return "utility"
    end
    if p.economic then return "economy" end
    if p.mobile and p.shield then return "shield" end
    return "utility"
end
local function NativeInvestmentScale(tp,s,horizon)
    local cost=tp and tp.economy and tp.economy.cost or {}
    local mass,energy=Value(cost.alloys),Value(cost.energy)
    local mr=math.max(0,Value(s and s.alloy and s.alloy.income))*0.30*horizon
    local er=math.max(0,Value(s and s.energy and s.energy.income))*0.30*horizon
    local massShare=mass>0 and mr/mass or math.huge
    local energyShare=energy>0 and er/energy or math.huge
    return math.min(8,massShare,energyShare)
end
function ArtilleryGoal(a,tp,s,c)
    return math.max(1,math.min(4,1+math.floor(NativeInvestmentScale(tp,s,900))))
end
function DesiredCount(a,tp,s,c)
    local kind=Kind(a,tp)
    if not kind then return 0 end
    if kind=="artillery" then return ArtilleryGoal(a,tp,s,c) end
    if kind=="economy" or kind=="shield" or kind=="utility" then return 1 end
    if kind=="siege" or kind=="strategic" then
        return math.max(1,math.min(2,math.floor(NativeInvestmentScale(tp,s,1200))))
    end
    return math.max(1,math.min(3,1+math.floor(NativeInvestmentScale(tp,s,600))))
end
function ChoiceScore(a,tp,s,c)
    local kind=Kind(a,tp);if not kind then return nil end
    s=s or {};c=c or {}
    local p=Profile(tp);local counts=c.counts or c.countsKind or {}
    local id=tp.general.tpId;local same=Value(c.byId and c.byId[id])
    local count=Value(counts[kind]);local total=Value(c.experimentalTotal)
    if same>=DesiredCount(a,tp,s,c) then return nil end
    if kind=="artillery" and count>=ArtilleryGoal(a,tp,s,c) then return nil end
    local siege=c.siegePressure==true
    local pressure=s.landPressure or s.localLandThreat
    local allies=Value(c.allyCount);local teamNeed=math.min(3,Value(c.teamPressure))
    local known=math.min(8,Value(c.knownTargets));local static=math.min(6,Value(c.staticTargets))
    local score
    if kind=="economy" then
        if s.landPanic or s.airPanic or s.navalPanic or pressure then return nil end
        local mass=s.alloy or {};local energy=s.energy or {}
        local utilized=Value(mass.request)>=Value(mass.income)*0.85
            or Value(energy.request)>=Value(energy.income)*0.85
        score=410+(utilized and 60 or 0)+(allies>0 and 30 or 0)+teamNeed*55
            +(Value(c.mobileTotal)>0 and 70 or 0)+(Value(s.groundReady)>=40 and 60 or 0)
            +(p.massOutput>0 and p.energyOutput>0 and 60 or 0)
        if Value(mass.ratio)>0.90 and Value(energy.ratio)>0.90 then score=score-90 end
        score=score-count*260
    elseif kind=="land" then
        score=420+(pressure and 170 or 0)+(siege and 70 or 0)+(Value(c.mobileTotal)==0 and 100 or 0)
            +math.min(50,math.sqrt(math.max(0,p.health))/15)
        if siege then score=score+math.min(60,p.range*0.45) else score=score+math.min(35,p.speed*8) end
        if s.landDisconnected and p.amphibious then score=score+70 end
        score=score-count*45
    elseif kind=="air" then
        local fighters=Value(s.roles and s.roles.fighter)
        score=400+(s.landDisconnected and 150 or 0)+(siege and 85 or 0)+(pressure and 60 or 0)
            +math.min(60,p.area*8)+math.min(40,p.speed*5)
        if s.airThreat and fighters<4 then score=score-150 end
        if fighters>=6 then score=score+50 end
        score=score-count*65
    elseif kind=="naval" then
        if c.hasHarbor==false then return nil end
        score=350+(s.navalThreat and 180 or 0)+(s.landDisconnected and 150 or 0)
            +(p.amphibious and pressure and 100 or 0)+math.min(60,p.range*0.4)-count*65
    elseif kind=="artillery" then
        score=(count==0 and 595 or 390)+(siege and 125 or 0)+static*16+known*4
            +(s.landDisconnected and 70 or 0)-count*45
    elseif kind=="siege" or kind=="strategic" then
        score=340+(siege and 180 or 0)+static*18+known*6+teamNeed*20
            +(s.landDisconnected and 70 or 0)-count*90
    elseif kind=="shield" then
        score=275+(pressure and 180 or 0)+(s.airThreat and 100 or 0)+teamNeed*40
            +math.min(90,Value(c.mobileTotal)*35)-count*170
    else
        -- Specialized factories, carriers and other native utilities remain
        -- candidates even when they expose no direct weapon/economy metadata.
        score=235+(p.factory and 85 or 0)+(allies>0 and 40 or 0)+teamNeed*25
            +math.min(100,total*30)-count*140
    end
    -- Establish or replace an experimental presence before ordinary artillery
    -- repeatedly consumes the only heavy slot. Native affordability and actual
    -- situation still decide which legal experimental can receive this priority.
    if IsExperimental(tp) and total==0 then score=score+180 end
    -- Distinct native variants remain eligible; repeated purchases lose priority.
    return math.max(1,score-same*115)
end

-- One first-experimental focus per owner, including allied human owners. This
-- is shared by all helping AIs; it never issues orders or changes native costs.
local FirstRules,FirstTasks
local function Number(v,default)
    return type(v)=="number" and v==v and math.abs(v)<math.huge and v or default or 0
end
local function Frame()
    return type(Tick)=="number" and Tick==Tick and Tick>=0 and Tick<math.huge and Tick or nil
end
local function Now()
    local frame=Frame()
    return frame and frame/(Constants and Constants.TickRate or 10) or GetGameTimeSeconds()
end
local function Own(a,u)
    return a and u and not u.dead and not u.deleted and u.army==a and u.id
        and a.units and a.units[u.id.index]==u
end
local function Paused(u)
    return u.toggles and u.toggles.Pause or type(u.GetPause)=="function" and u:GetPause()
end
local function Experimental(tp) return IsExperimental(tp) end
local function FirstState(a)
    if not a or not a.units then return nil end
    local now=Now();local s=a.rushFirstExperimental
    if not s or now<(s.observedAt or now) then
        s={scanAt=-1,claims={}};a.rushFirstExperimental=s
    end
    s.observedAt=now
    return s
end
local function CompletedFirst(s)
    s.completed=true;s.target=nil;s.claims={}
    s.ownerActive=nil;s.ownerPaused=nil
    s.releasedFrame=nil;s.releasedMass=nil;s.releasedEnergy=nil
end
function FirstTarget(a)
    local s=FirstState(a)
    if not s or s.completed then return nil end
    local target=s.target
    -- A finished unit may die before the next census. Native finished-only
    -- active/lost statistics below also retain that history after object removal.
    if target and target.army==a and target:IsCompleted() then CompletedFirst(s);return nil end
    if target and not Own(a,target) then s.target=nil;target=nil;s.scanAt=-1 end
    if Now()<s.scanAt then return target end
    s.scanAt=Now()+2
    local stats=a.stats and a.stats.units or {}
    for _,field in ipairs({"active","lost"}) do
        for id,count in pairs(stats[field] or {}) do
            local tp=__Templates and __Templates.Units and __Templates.Units[id]
            if Number(count)>0 and Experimental(tp) then CompletedFirst(s);return nil end
        end
    end
    local candidate
    for _,u in pairs(a.units) do
        if Own(a,u) and Experimental(u.tp) and not u.scoCommanderPodOwner and not u.scoSourcePodOwner then
            if u:IsCompleted() then CompletedFirst(s);return nil end
            local e=u.tp.economy;local cost=e and e.cost
            if u.hasBeenPromotedFromPlacementGhost==true and Number(e and e.buildTime)>0
                and cost and Number(cost.alloys,-1)>=0 and Number(cost.energy,-1)>=0
                and (not candidate or u.id.index<candidate.id.index) then candidate=u end
        end
    end
    s.target=target or candidate;target=s.target
    s.ownerActive=false;s.ownerPaused=false
    if target then
        FirstTasks=FirstTasks or Import("common/commonOrders.lua").OrderTasks
        for _,u in pairs(a.units) do
            if Own(a,u) and u~=target and u:IsCompleted() and not s.claims[u]
                and not u.scoCommanderPodOwner and not u.scoSourcePodOwner
                and not u.CaptureInProgress and not u.ReclaimInProgress then
                local order=u.orders and u.orders.activeOrder
                local committed=u.buildBehaviorIsActive and u.buildBehaviorActualUnit==target
                    or u.productionBehaviorIsActive and u.productionBehaviorTargetUnit==target
                    or order and (order.orderTask==FirstTasks.BUILD and order.unitGettingBuilt==target
                        or order.orderTask==FirstTasks.ASSISTUNIT and order.targetUnit==target)
                if committed then
                    if Paused(u) then s.ownerPaused=true else s.ownerActive=true end
                end
            end
        end
    end
    return target
end
function IsFirstTarget(target)
    return target and FirstTarget(target.army)==target or false
end
local function ConstructionEntity(target)
    local a=target and target.army
    local entity=target and target.resourceEntities and target.resourceEntities.construction
    local economy=a and a.economy
    return entity and entity.enabled==true and entity.category=="construction" and entity.unitId==target.id
        and economy and entity.armyId==a.id and entity.economy==economy and economy.armyId==a.id
        and economy.resourceEntities and economy.resourceEntities.construction
        and economy.resourceEntities.construction[entity.id]==entity
        and Number(entity.originalBuildTime)>0 and type(entity.originalCost)=="table"
        and Number(entity.userMultiplier)>0 and entity or nil
end
function CanAssistFirst(a,target)
    if not Enabled(a) or a.ai.isAlive==false or not target or not Own(target.army,target)
        or target.CaptureInProgress or target.ReclaimInProgress or Paused(target)
        or target.hasBeenPromotedFromPlacementGhost~=true or not IsFirstTarget(target)
        or not ConstructionEntity(target) then return false end
    local owner=target.army;local s=owner.rushFirstExperimental
    if owner.ai and owner.ai.isAlive==false then return false end
    if owner~=a and (type(a.IsAlly)~="function" or not a:IsAlly(owner)
        or type(owner.IsAlly)~="function" or not owner:IsAlly(a)) then return false end
    -- Do not override a paused lead, or restart an allied player's abandoned
    -- project. Own abandoned foundations remain resumable when nobody paused it.
    return not (s.ownerPaused and not s.ownerActive) and (owner==a or s.ownerActive)
end
local function Eligible(builder,target)
    local a=builder and builder.army
    return Own(a,builder) and builder:IsCompleted() and not builder.CaptureInProgress
        and not builder.ReclaimInProgress and not Paused(builder) and CanAssistFirst(a,target)
        and type(builder.CanConstructOthers)=="function" and builder:CanConstructOthers()
        and type(builder.AssistBehaviorIsValidFor)=="function" and builder:AssistBehaviorIsValidFor(target)
end
local function AssistRates(builder,target)
    local entity=ConstructionEntity(target)
    if not entity then return nil end
    local cost=entity.originalCost;local bt=entity.originalBuildTime
    local mass,energy=Number(cost.alloys,-1),Number(cost.energy,-1)
    if mass<0 or energy<0 then return nil end
    local mr,er,cm,ce,power,registeredPower,seen=0,0,0,0,0,0,{}
    local tick=Constants and Constants.TickRate or 10
    local function add(u)
        if not Own(builder.army,u) or seen[u] or Paused(u) or not u:IsCompleted()
            or u.CaptureInProgress or u.ReclaimInProgress then return end
        seen[u]=true
        local bp=Number(u.construction and u.construction.buildPower)
        if bp<=0 then return end
        local source=u.unitBeingBuilt==target and entity.buildPowerSources and entity.buildPowerSources[u.id]
        local discount=source and source.discount or u.adjacencyBonus or {}
        local dm,de=Number(discount.alloys,1),Number(discount.energy,1)
        if dm<0 or de<0 then return end
        power=power+bp
        mr=mr+mass*bp/bt*dm*entity.userMultiplier
        er=er+energy*bp/bt*de*entity.userMultiplier
        if source and Number(source.buildPower)>0 then
            registeredPower=registeredPower+source.buildPower
            cm=cm+mass*source.buildPower/bt*dm*entity.userMultiplier
            ce=ce+energy*source.buildPower/bt*de*entity.userMultiplier
        end
    end
    add(builder)
    for _,pod in pairs(builder.scoCommanderEnhancements and builder.scoCommanderEnhancements._pods or {}) do
        if pod and pod.scoCommanderPodOwner==builder.id then add(pod) end
    end
    if power<=0 then return nil end
    cm=math.min(cm,math.max(0,Number(entity.outcome and entity.outcome.alloys))*tick*entity.userMultiplier)
    ce=math.min(ce,math.max(0,Number(entity.outcome and entity.outcome.energy))*tick*entity.userMultiplier)
    return mr,er,cm,ce,power,registeredPower
end
local function ClaimCurrent(r,tentative)
    local u=r and r.unit;local a=u and u.army;local p=u and u.platoon
    local s=r and r.owner and r.owner.rushFirstExperimental
    if not r or not s or s.claims[u]~=r or s.target~=r.target or s.completed
        or not Own(a,u) or a~=r.army or a.ai~=r.armyAI or a.ai.isAlive==false
        or u.ai~=r.unitAI or p~=r.platoon or not p or p.dead or p.deleted
        or p.ai~=r.platoonAI or not a:PlatoonExists(p) or Now()>r.expires
        or not Own(r.owner,r.target) or r.target:IsCompleted() or Paused(u) then return false end
    if not r.order then return tentative and Now()<=r.created+1 end
    local orders=u.orders or {};local found=orders.activeOrder==r.order
    if orders.activeOrder and not found then return false end
    for _,order in pairs(orders.queuedOrders or {}) do
        if order~=r.order then return false end
        found=true
    end
    return found and r.order.targetUnit==r.target
end
function ReleaseFirstAssist(r)
    local s=r and r.owner and r.owner.rushFirstExperimental
    if s and s.claims[r.unit]==r then s.claims[r.unit]=nil end
end
-- Native source changes are immediate; economy totals are sampled next tick.
-- Keep new demand pending until that sample can include the registered beam.
local function MatureCredit(r,mass,energy)
    if not r then return 0,0 end
    local now=Now()
    if r.observedMass~=mass or r.observedEnergy~=energy then
        r.creditMass=math.min(r.creditMass or 0,mass)
        r.creditEnergy=math.min(r.creditEnergy or 0,energy)
        r.observedMass=mass;r.observedEnergy=energy;r.creditAt=now
    elseif now>(r.creditAt or now)+1/(Constants and Constants.TickRate or 10) then
        r.creditMass=mass;r.creditEnergy=energy
    end
    return r.creditMass or 0,r.creditEnergy or 0
end
-- Only pending, unregistered demand is added to the target owner's ledger.
-- Native requests already include beams from every allied army.
function FirstAssistReserved(a,except)
    local s=a and a.rushFirstExperimental;local mass,energy=0,0
    for u,r in pairs(s and s.claims or {}) do
        if not ClaimCurrent(r,true) then s.claims[u]=nil
        elseif u~=except then
            local mr,er,cm,ce=AssistRates(u,r.target)
            if mr then
                cm,ce=MatureCredit(r,cm,ce)
                mass=mass+math.max(0,mr-cm);energy=energy+math.max(0,er-ce)
            end
        end
    end
    return mass,energy
end
local function OwnerResources(a,except)
    FirstRules=FirstRules or Import("AI/mods/AI-Scom/RushBalance.lua")
    if a.ai then return FirstRules.Resources(a,except) end
    local totals=a.economy and a.economy.totals
    if not totals then return nil end
    local resources={};local tick=Constants and Constants.TickRate or 10
    for _,name in ipairs({"alloys","energy"}) do
        local r=totals[name]
        if not r or Number(r.income,-1)<0 or Number(r.request,-1)<0
            or Number(r.current,-1)<0 or Number(r.storage,-1)<0 then return nil end
        resources[#resources+1]={income=r.income*tick,current=r.current,storage=r.storage,
            balance=(r.income-r.request)*tick,reserved=0}
    end
    resources[1].reserved,resources[2].reserved=FirstAssistReserved(a,except)
    return resources[1],resources[2]
end
function FirstAssistAffordable(builder,target)
    if not Eligible(builder,target) then return false end
    local mr,er,cm,ce,power,registeredPower=AssistRates(builder,target)
    local claim=target.army.rushFirstExperimental.claims[builder]
    if claim and (claim.target~=target or not ClaimCurrent(claim,false)) then claim=nil end
    local rawMass,rawEnergy=cm or 0,ce or 0
    cm,ce=MatureCredit(claim,rawMass,rawEnergy)
    local mass,energy=OwnerResources(target.army,builder)
    if not mr or not mass or not energy then return false end
    local entity=ConstructionEntity(target)
    local fraction=type(target.GetFractionComplete)=="function" and Number(target:GetFractionComplete()) or 0
    local remaining=math.max(0,1-math.min(1,fraction))
    local active=Number(entity.buildPower)*(Constants and Constants.TickRate or 10)
    local seconds=math.max(5,math.min(30,entity.originalBuildTime*remaining
        /math.max(1,active+math.max(0,power-registeredPower))))
    local state=target.army.rushFirstExperimental
    local frame=Frame()
    local released=claim and frame and state.releasedFrame==frame
    local function cover(r,rate,credit,relief)
        -- Rate-derived remaining cost retains native discounts/multipliers.
        local needed=math.min(rate,rate*entity.originalBuildTime*remaining/power/seconds)
        local bank=math.max(0,r.current-r.storage*0.20)/seconds
        return r.balance-r.reserved+credit+bank+(released and Number(relief) or 0)>=needed
    end
    if cover(mass,mr,cm,state.releasedMass) and cover(energy,er,ce,state.releasedEnergy) then return true end
    -- An already accepted beam gets one observation of grace while its newly
    -- seen source matures. Other consumers still reserve its whole pending rate.
    return claim and Now()<=(claim.creditAt or -1)+1/(Constants and Constants.TickRate or 10)
        and (rawMass>cm or rawEnergy>ce) and cover(mass,mr,rawMass,state.releasedMass)
        and cover(energy,er,rawEnergy,state.releasedEnergy) or false
end
function ReserveFirstAssist(builder,target,existingOrder)
    if not Eligible(builder,target) or not existingOrder and not FirstAssistAffordable(builder,target) then return nil end
    FirstAssistReserved(target.army)
    local s=target.army.rushFirstExperimental;local p=builder.platoon
    if not p or not p.ai or s.claims[builder] then return nil end
    local count=0;for _ in pairs(s.claims) do count=count+1 end
    if count>=32 then return nil end
    local now=Now()
    local r={unit=builder,unitAI=builder.ai,army=builder.army,armyAI=builder.army.ai,
        platoon=p,platoonAI=p.ai,owner=target.army,target=target,created=now,expires=now+1}
    s.claims[builder]=r
    if existingOrder and (not CommitFirstAssist(r,existingOrder) or not FirstAssistAffordable(builder,target)) then
        ReleaseFirstAssist(r);return nil
    end
    return r
end
function CommitFirstAssist(r,order)
    FirstTasks=FirstTasks or Import("common/commonOrders.lua").OrderTasks
    if not ClaimCurrent(r,true) or not order or order.orderTask~=FirstTasks.ASSISTUNIT
        or order.targetUnit~=r.target then ReleaseFirstAssist(r);return false end
    r.order=order;r.expires=Now()+4
    if not ClaimCurrent(r,false) then ReleaseFirstAssist(r);return false end
    local _,_,mass,energy=AssistRates(r.unit,r.target)
    MatureCredit(r,mass or 0,energy or 0)
    return true
end
function RefreshFirstAssist(r)
    if not ClaimCurrent(r,false) or not Eligible(r.unit,r.target) then ReleaseFirstAssist(r);return false end
    if not FirstAssistAffordable(r.unit,r.target) then
        -- Native totals retain a withdrawn beam until the next tick. Credit
        -- that released request only to existing helpers, never new admissions,
        -- so a small shortfall does not dismiss the entire team in one loop.
        local s=r.owner.rushFirstExperimental;local frame=Frame()
        if frame then
            if s.releasedFrame~=frame then s.releasedFrame=frame;s.releasedMass=0;s.releasedEnergy=0 end
            s.releasedMass=s.releasedMass+(r.creditMass or 0)
            s.releasedEnergy=s.releasedEnergy+(r.creditEnergy or 0)
        end
        ReleaseFirstAssist(r);return false
    end
    r.expires=Now()+4
    return true
end
