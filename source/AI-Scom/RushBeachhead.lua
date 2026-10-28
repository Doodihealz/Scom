-- One native amphibious construction detachment establishes a coastal base.
-- Native queues own travel, paid construction and recovery; no transport API is assumed.
local AF=Import("AI/AIFunctions.lua")
local MG=Import("AI/AIMarkerGenerator.lua")
local TM=Import("AI/AITargetManager.lua")
local Creator=Import("AI/AILocationCreator.lua")
local Rules=Import("AI/mods/AI-Scom/RushBalance.lua")
local R=Import("AI/mods/AI-Scom/RushReliability.lua")
local Layout=Import("AI/mods/AI-Scom/RushBaseLayout.lua")
local Economy=Import("AI/mods/AI-Scom/RushEconomyPolicy.lua")
local Movement=Import("AI/mods/AI-Scom/RushMovement.lua")
local Budget=Import("AI/mods/AI-Scom/RushPathBudget.lua")
local Orders=Import("host/managers/orders/hostOrderManager.lua")
local Tasks=Import("common/commonOrders.lua").OrderTasks
local Log=Import("AI/debugUtilities.lua").AILog
local Controller
local catalogue={}
local catalogueTemplates
local ReleaseMove
local RefreshBases
function Configure(controller) Controller=controller end
local function Now() return GetGameTimeSeconds() end
local function Finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function Position(p) return p and Finite(p.x) and Finite(p.z) end
local function Copy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local function Template(id) return __Templates and __Templates.Units and __Templates.Units[id] end
local function Enabled(army)
    return Controller and army and army.ai and army.ai.isAlive~=false and Controller.IsRushArmy(army)
end
local function HasOrders(u)
    local o=u.orders or {}
    return o.activeOrder or next(o.queuedOrders or {})
end
local function Current(op)
    local a,p,u=op.army,op.platoon,op.builder
    if a.ai==op.armyAI and RefreshBases and a.ai.bases
        and (op.baseName and a.ai.bases[op.baseName]~=op.baseRef
            or not op.baseName and a.ai.bases[op.sourceName]~=op.sourceBaseRef) then RefreshBases(a) end
    return a.ai==op.armyAI and op.armyAI.isAlive~=false and op.armyAI.rushBeachhead
        and op.armyAI.rushBeachhead.operation==op
        and (not op.baseName or a.ai.bases and a.ai.bases[op.baseName]==op.baseRef and u.assignedToBase==op.baseName)
        and R.CurrentAssignment(u,a,p,op.builderAI,op.platoonAI)
        and not u.CaptureInProgress and not u.ReclaimInProgress
end
local function ReleaseStartup(op)
    local rows=op.armyAI.ecoReserve
    if op.reservation and rows and rows[op.builder.id.index]==op.reservation then
        if op.army.ai==op.armyAI and R.Own(op.army,op.builder) and op.builder.ai==op.builderAI then
            AF.ClearReserveEco(op.army.id,op.builder.id.index)
        else rows[op.builder.id.index]=nil end
    end
    op.reservation=nil
    if op.callback then op.builder:RemoveCallback(op.callback,"OnDestroyed");op.callback=nil end
end
local function Block(state,key,delay)
    state.blocked[key]=Now()+delay
    local count,oldest,expiry=0
    for k,value in pairs(state.blocked) do
        count=count+1
        if k~=key and (not expiry or value<expiry or value==expiry and k<oldest) then oldest,expiry=k,value end
    end
    if count>32 and oldest then state.blocked[oldest]=nil end
end
RefreshBases=function(army)
    local state=army.ai.rushBeachhead;local bases=army.ai.bases;local main=bases and bases.MAIN
    if not state or not main or main.baseType~="MAIN" or not Position(main.position) then return end
    local function promotion(name,base,position,proof)
        return name and name~="MAIN" and not bases[name] and base and base~=main
            and rawequal(base.position,main.position) and Position(position) and D2(position,main.position)<0.01
            and R.Own(army,proof) and proof.assignedToBase=="MAIN"
    end
    local function renamePlatoons(name)
        for _,platoon in pairs(army.platoons or {}) do
            local data=platoon.ai
            if data and data.baseName==name and platoon.army==army and not platoon.dead
                and army:PlatoonExists(platoon) then
                for _,unit in ipairs(platoon:GetUnits()) do
                    if R.Own(army,unit) and unit.platoon==platoon and unit.assignedToBase=="MAIN" then
                        data.baseName="MAIN";data.baseRadius=main.radius;break
                    end
                end
            end
        end
    end
    -- The native promotion allocates a new MAIN table but reuses the exact old
    -- position object. Neither a reused name nor nearby coordinates suffice.
    for name,record in pairs(state.bases) do
        if record.armyAI==army.ai then
            local matched=false
            for _,field in ipairs({"builder","productionFactory","factory"}) do
                if promotion(name,record.baseRef,record.position,record[field]) then matched=true;break end
            end
            if matched then
                renamePlatoons(name)
                record.baseRef=main;state.bases.MAIN=record;state.bases[name]=nil
            end
        end
    end
    local op=state.operation
    if not op or op.armyAI~=army.ai
        or not R.CurrentAssignment(op.builder,army,op.platoon,op.builderAI,op.platoonAI) then return end
    local mainRecord=state.bases.MAIN
    if mainRecord and mainRecord.baseRef==main
        and promotion(op.baseName,op.baseRef,op.basePosition,op.builder) then
        op.baseName,op.baseRef="MAIN",main
        op.platoonAI.baseName="MAIN";op.platoonAI.baseRadius=main.radius
    end
    if promotion(op.sourceName,op.sourceBaseRef,op.site.source,op.builder) then
        renamePlatoons(op.sourceName)
        op.sourceName,op.sourceBaseRef="MAIN",main
        op.site.sourceName,op.site.sourceBaseRef="MAIN",main
        if not op.baseName then op.platoonAI.baseName="MAIN" end
    end
end
local function State(army)
    local s=army.ai.rushBeachhead
    if not s then s={blocked={},bases={},scans={},nextMission=0};army.ai.rushBeachhead=s end
    RefreshBases(army)
    local now=Now();s.scans=s.scans or {}
    for name in pairs(s.scans) do if not (army.ai.bases and army.ai.bases[name]) then s.scans[name]=nil end end
    for key,expiry in pairs(s.blocked) do if now>=expiry then s.blocked[key]=nil end end
    for name,record in pairs(s.bases) do
        if record.armyAI~=army.ai or (not army.ai.bases or army.ai.bases[name]~=record.baseRef) then s.bases[name]=nil end
        if record.builder and (not R.Own(army,record.builder) or record.builder.assignedToBase~=name) then record.builder=nil end
    end
    local op=s.operation
    if op then
        local thread=op.platoon.aiThread
        local stale=op.phase=="claimed" and now-op.started>10
            or thread and type(thread)=="thread" and coroutine.status(thread)=="dead"
        if not Current(op) or stale then
            ReleaseStartup(op)
            if ReleaseMove then ReleaseMove(op) end
            if op.platoon.ai==op.platoonAI then R.ReleaseConstructionQueue(op.platoon,true) end
            if stale and R.Own(army,op.builder) and op.builder.platoon==op.platoon
                and op.platoon.ai==op.platoonAI then op.platoon:OnUnitRemoved(op.builder) end
            if op.platoonAI.rushBeachhead==op then op.platoonAI.rushBeachhead=nil end
            Block(s,op.site.key,60);s.operation=nil;s.nextMission=now+15
        end
    end
    if s.proposal and (now>s.proposal.expires or not R.Own(army,s.proposal.builder)
        or s.proposal.builder.ai~=s.proposal.site.builderAI) then s.proposal=nil end
    return s
end
local function Kind(tp)
    local tier=Rules.Tier(tp)
    if not R.Has(tp,"STRUCTURE") or tier<1 or tier>2 then return nil end
    if Rules.FactoryDomain(tp)=="land" and tier==1 then return "factory" end
    if Layout.IsGroundDefenseTemplate(tp,tier) then return "defense" end
    if R.Has(tp,"DEFENCE") and R.Has(tp,"ANTI_AIR") and tier==1 then return "aa" end
    if R.Has(tp,"WALL") and tier==1 then return "wall" end
end
local function Catalogue()
    local templates=__Templates and __Templates.Units
    if catalogueTemplates==templates then return catalogue end
    catalogueTemplates=templates;catalogue={factory={},defense={},aa={},wall={}}
    for id,tp in pairs(templates or {}) do
        local kind=Kind(tp)
        local economy=tp.economy;local cost=economy and economy.cost
        if kind and cost and Finite(cost.alloys) and cost.alloys>=0 and Finite(cost.energy) and cost.energy>=0
            and Finite(economy.buildTime) and economy.buildTime>0
            and R.AllowedTarget(id,false) and R.Footprint(tp) then catalogue[kind][#catalogue[kind]+1]=id end
    end
    for _,ids in pairs(catalogue) do
        table.sort(ids,function(a,b)
            local x,y=Template(a),Template(b)
            local tx,ty=Rules.Tier(x),Rules.Tier(y)
            if tx~=ty then return tx>ty end
            local cx,cy=x.economy.cost,y.economy.cost
            if cx.alloys~=cy.alloys then return cx.alloys<cy.alloys end
            if cx.energy~=cy.energy then return cx.energy<cy.energy end
            return a<b
        end)
    end
    return catalogue
end
local function BuildCredit(builder)
    local w=builder.ai and builder.ai.rushConstructionQueue
    if not w or w.unit~=builder or w.unitAI~=builder.ai or w.army~=builder.army
        or w.armyAI~=builder.army.ai or w.platoon~=builder.platoon or not builder.platoon
        or w.platoonAI~=builder.platoon.ai or w.platoonAI.rushConstructionQueue~=w.queue then return 0,0 end
    for _,entry in ipairs(w.queue.entries) do
        if builder.unitBeingBuilt==entry.target and R.Own(builder.army,entry.target)
            and not entry.target:IsCompleted() then return Rules.RegisteredBuildRates(builder) end
    end
    return 0,0
end
function CanFund(builder,id)
    local army=builder and builder.army;local tp=Template(id)
    if not Enabled(army) or not R.Own(army,builder) or not builder:IsCompleted()
        or builder.CaptureInProgress or builder.ReclaimInProgress or not Kind(tp)
        or not R.AllowedTarget(id,false) or not R.CanBuilderBuild(builder,id)
        or type(builder.GetPause)=="function" and builder:GetPause() then return false end
    local mass,energy,duration=Rules.ProjectRates(builder,id)
    if not mass or not duration or duration<=0 then return false end
    local a,e=Rules.Resources(army,builder)
    if not a or not e or a.income<=0 or e.income<=0 or army.economy.isEnergyDown then return false end
    local mCredit,eCredit=BuildCredit(builder)
    return Rules.Balance(a)+(mCredit or 0)+math.max(0,a.current-a.storage*0.15)/duration>=mass
        and Rules.Balance(e)+(eCredit or 0)+math.max(0,e.current-e.storage*0.15)/duration>=energy
end
local function Products(builder)
    local result={}
    for kind,ids in pairs(Catalogue()) do
        for _,id in ipairs(ids) do
            if R.CanBuilderBuild(builder,id) and CanFund(builder,id) then result[kind]=id;break end
        end
    end
    if not result.factory or not result.defense then return nil end
    local a,e=Rules.Resources(builder.army,builder)
    if not a or not e then return nil end
    local mass,energy,duration=0,0,0
    for _,id in ipairs({result.defense,result.factory}) do
        local m,n,d=Rules.ProjectRates(builder,id)
        if not m then return nil end
        mass=mass+m*d;energy=energy+n*d;duration=duration+d
    end
    if Rules.Balance(a)*duration+math.max(0,a.current-a.storage*0.15)<mass
        or Rules.Balance(e)*duration+math.max(0,e.current-e.storage*0.15)<energy then return nil end
    return result
end
local function EconomyReady(army,s)
    if not Enabled(army) or not s or not s.alloy or not s.energy or not army.ai.bases or not army.ai.bases.MAIN
        or not s.underCap
        or (s.completeFactories or 0)<3 or (s.engineersComplete or 0)<math.max(5,Economy.EngineerFloor(s)+1)
        or s.landPanic or s.airPanic or army.economy.isEnergyDown or s.techPowerNeeded then return false end
    if Economy.LandEnabled(army) and Economy.GroundReady(s)<math.max(12,Economy.GroundFloor(s)) then return false end
    return s.alloy.income>0 and s.energy.income>0 and s.energy.ratio>=0.30
end
local function Recruitable(army,baseName,u)
    local base=army.ai.bases[baseName]
    local layer=Movement.UnitMovementLayer(u)
    return base and base.baseType~="NAVAL" and Position(base.position) and Finite(base.radius)
        and base.radius>0 and R.Own(army,u)
        and u.ai and u:IsCompleted() and R.Has(u.tp,"ENGINEER") and not R.Has(u.tp,"COMMAND")
        and not R.Has(u.tp,"TECH4") and not u.scoCommanderPodOwner and not u.scoSourcePodOwner
        and not u.platoon and not R.Working(u) and not HasOrders(u) and not AF.IsUnderAttack(u)
        and not u.CaptureInProgress and not u.ReclaimInProgress
        and not (type(u.GetPause)=="function" and u:GetPause())
        and not (army.ai.ecoReserve and army.ai.ecoReserve[u.id.index])
        and u.assignedToBase==baseName and D2(u:GetPosition(),base.position)<=base.radius^2
        and (layer=="Hover" or layer=="Seabed")
end
function Builders(army,baseName,units)
    if not Enabled(army) then return {} end
    local s=State(army);local snapshot=Controller.Snapshot(army)
    if s.operation or Now()<s.nextMission or not EconomyReady(army,snapshot) or #(units or {})<2 then return {} end
    local selected=s.proposal
    if selected and selected.baseName==baseName and Recruitable(army,baseName,selected.builder) then
        for _,u in ipairs(units) do if u==selected.builder then return {u} end end
    end
    if selected and Recruitable(army,selected.baseName,selected.builder) then return {} end
    if Now()<(s.scans[baseName] or 0) then return {} end
    s.scans[baseName]=Now()+10;s.proposal=nil
    local valid={}
    for _,u in ipairs(units) do if Recruitable(army,baseName,u) then valid[#valid+1]=u end end
    table.sort(valid,function(a,b)
        local x,y=Rules.Tier(a.tp),Rules.Tier(b.tp)
        return x==y and a.id.index<b.id.index or x<y
    end)
    for i=1,math.min(2,#valid) do
        local u=valid[i];local products=Products(u)
        if products then
            local candidates=Layout.BeachheadCandidates(army,snapshot,u,products.factory,s.blocked)
            if not Enabled(army) or army.ai.rushBeachhead~=s or s.operation then return {} end
            if Recruitable(army,baseName,u) and candidates[1] then
                s.proposal={builder=u,baseName=baseName,site=candidates[1],products=products,expires=Now()+10}
                return {u}
            end
        end
    end
    return {}
end
function Ready(army,snapshot,baseName)
    if not Enabled(army) then return false end
    local s=State(army)
    if s.operation or Now()<s.nextMission or not EconomyReady(army,snapshot) then return false end
    local former
    for _,f in pairs(army.ai.formerpool or {}) do if f.RushBeachhead then former=f;break end end
    if not former then return false end
    local units=AF.GetNeedMobileBuilder(army.id,baseName,former)
    return units and #units>0 or false
end
function Check(index,baseName)
    local army=Armies[index]
    return Enabled(army) and Ready(army,Controller.Snapshot(army),baseName) or false
end
function AddFormers(army,formers)
    for _,f in pairs(formers) do if f.RushBeachhead then return formers end end
    formers[#formers+1]={FormerName="Coastal beachhead",AIPlan="planBeachhead",Priority=9380,FormNumInstances=1,
        RushBeachhead=true,RushDevelopment=true,InvestmentType="Beachhead",RunWithStrategyName={},
        AIdifficulty={easy=true,medium=true,hard=true},
        RunOnBaseType={MAIN=true,EXPANSION=true,OUTPOST=true,NAVAL=false},
        NeedMobileBuilder={{Tags.MOBILE*Tags.ENGINEER*(Tags.TECH1+Tags.TECH2+Tags.TECH3)-Tags.COMMAND-Tags.TECH4,1,1,0}},
        WantStructures={Tags.STRUCTURE*Tags.LAND_FACTORY*Tags.TECH1},WantStructuresSpacing=3,
        FormerConditions={{Check,{}}},AllowEcoStorageDrain=true,DebugPlatoon=false}
    return formers
end
function Claim(platoon,index,baseName,former)
    local army=Armies[index]
    if not Enabled(army) or platoon.army~=army or not platoon.ai or platoon.dead then return false end
    local s=State(army);local choice=s.proposal
    if s.operation or not choice or choice.baseName~=baseName or choice.expires<Now()
        or not Recruitable(army,baseName,choice.builder) or not EconomyReady(army,Controller.Snapshot(army))
        or choice.builder==Rules.ProtectedPowerBuilder(army,former)
        or R.BuilderRecallReserved(choice.builder,former.RushBuilderRecallOwner) then return false end
    local products=Products(choice.builder)
    if not products or products.factory~=choice.site.factoryId then return false end
    local builder,data=choice.builder,platoon.ai
    local op={army=army,armyAI=army.ai,platoon=platoon,platoonAI=data,builder=builder,builderAI=builder.ai,
        site=choice.site,products=products,sourceName=baseName,sourceBaseRef=army.ai.bases[baseName],
        phase="claimed",started=Now(),admitUntil=Now()+180,targets={}}
    s.operation=op;s.proposal=nil
    data.formerTable=former;data.baseName=baseName;data.basePosition=Copy(op.site.position)
    data.baseRadius=60;data.movementLayer=Movement.UnitMovementLayer(builder);data.rushBeachhead=op
    platoon:AssignUnits({builder})
    if not Current(op) then s.operation=nil;return false end
    AF.SetReserveEco(army.id,builder.id.index,op.products.defense,op.site.position)
    op.reservation=army.ai.ecoReserve and army.ai.ecoReserve[builder.id.index]
    if not op.reservation then platoon:OnUnitRemoved(builder);s.operation=nil;return false end
    op.callback=function() ReleaseStartup(op) end
    builder:AddCallback(op.callback,"OnDestroyed")
    return true
end
local function PathAdmission(op)
    local untilTime=Now()+2
    repeat
        if not Current(op) then return false end
        if Budget.Extra(op.platoon,1) then return true end
        WaitTicks(1)
    until Now()>=untilTime
    return false
end
local function SafePath(op,path)
    if type(path)~="table" or #path<1 or #path>192 then return false end
    for _,pos in ipairs(path) do
        if not Position(pos) then return false end
        for _,layer in ipairs({op.platoonAI.movementLayer,"Land"}) do
            local threat=TM.GetThreatFromHeatMapPosition(op.army.id,pos,layer)
            if not Finite(threat) or threat>1 then return false end
        end
    end
    return true
end
local function NativeWater(pos)
    if not Engine or not EngineErrorCode or type(Engine.GetWaterLevel)~="function"
        or type(Engine.SampleTerrainHeight)~="function" then return false end
    local ok,code,water=pcall(Engine.GetWaterLevel)
    local sampled,heightCode,height=pcall(Engine.SampleTerrainHeight,pos)
    return ok and sampled and code==EngineErrorCode.Success and heightCode==EngineErrorCode.Success
        and Finite(water) and Finite(height) and height<water-1
end
local function Observe(op,lead)
    if lead~=op.builder or not Current(op) or op.baseName or op.crossed then return false end
    local pos=Copy(lead:GetPosition())
    -- A coarse coast cell may contain dry land too: sample the actual terrain.
    local wet=NativeWater(pos) and MG.CanGraphAreaToStrict(pos,op.site.sourceWater,"Water")
    if wet then op.enteredWater=true end
    if op.enteredWater and D2(pos,op.site.shore)<=24^2 then op.reachedShore=true end
    local target=op.targets["defense:1"]
    if R.Own(op.army,target) and lead.unitBeingBuilt==target and target.hasBeenPromotedFromPlacementGhost then
        local _,_,power=Rules.RegisteredBuildRates(lead)
        if power and power>0 then op.crossed=true end
    end
    if op.reachedShore and D2(pos,op.site.position)<=128^2
        and MG.CanGraphAreaToStrict(pos,op.site.position,"Land") then op.crossed=true end
    return wet
end
local function Route(op,destination)
    if not Current(op) then return false end
    local wet=Observe(op,op.builder)
    local start=Copy(op.builder:GetPosition());local layer=op.platoonAI.movementLayer
    if layer~=Movement.UnitMovementLayer(op.builder) then return false end
    local goals
    if op.baseName or op.crossed then goals={destination}
    elseif op.enteredWater and wet then
        goals={op.site.shore,op.site.position,destination}
    else goals={op.site.sourceWater,op.site.shore,op.site.position,destination} end
    local path={}
    for _,goal in ipairs(goals) do
        if D2(start,goal)>4 then
            if not PathAdmission(op) then return false end
            local leg=MG.GeneratePathTo(op.army.id,start,goal,layer,true,0)
            if not Current(op) or not SafePath(op,leg) then return false end
            local length,previous=0,start
            for _,node in ipairs(leg) do length=length+math.sqrt(D2(previous,node));previous=node end
            -- A globally connected coast may hide a cliff or a distant bridge.
            -- Reject approaches whose native route is an excessive detour.
            if length>math.sqrt(D2(start,goal))*2.5+64 then return false end
            for _,node in ipairs(leg) do
                if #path>=192 then return false end
                if not path[#path] or D2(path[#path],node)>0.01 then path[#path+1]=Copy(node) end
            end
        end
        start=Copy(goal)
    end
    if #path==0 then path[1]=Copy(destination) end
    return Current(op) and SafePath(op,path) and path or false
end
ReleaseMove=function(op)
    local u=op.builder;local q=u.ai==op.builderAI and u.ai.rushMoveQueue
    if not q or q.platoon~=op.platoon or q.pai~=op.platoonAI or q.owner~=op.army
        or q.armyAI~=op.armyAI or q.ai~=op.builderAI then return end
    if op.army.ai~=op.armyAI or not R.Own(op.army,u) or u.platoon~=op.platoon
        or op.platoon.ai~=op.platoonAI then Movement.Forget(u,false);return end
    local active=u.orders and u.orders.activeOrder
    local owned=active and q.orders[active]
    Movement.Forget(u,true)
    if owned and R.Own(op.army,u) and u.ai==op.builderAI and u.platoon==op.platoon
        and op.platoon.ai==op.platoonAI and u.orders.activeOrder==active then
        Orders.RemoveUnitFromActiveOrder(u);Orders.TryStartNextOrderForUnit(u)
    end
end
local function MoveBuilder(op,destination,range)
    local u,data=op.builder,op.platoonAI
    if not Current(op) or HasOrders(u) or R.Working(u) or not PathAdmission(op) then return false end
    local request=Movement.Capture(op.platoon,{u})
    local start=Copy(u:GetPosition())
    local path=MG.GeneratePathTo(op.army.id,start,destination,data.movementLayer,true,0)
    if not Current(op) or not SafePath(op,path) then return false end
    path=Movement.ShortenPath(op.platoon,start,path,data.movementLayer,0,request)
    if not Current(op) then return false end
    data.path=Movement.CopyPath(MG.StraightenPath(path));data.rushMovementThreat=0
    if not Movement.Begin(op.platoon,data.path,destination,Tasks.MOVE,request) then return false end
    local untilTime=Now()+180;local last=Now();local best=D2(start,destination)
    while Current(op) and Now()<untilTime do
        if Movement.Suspended(u) then return false end
        Movement.Maintain(op.platoon)
        local distance=D2(u:GetPosition(),destination)
        if distance<=range^2 then ReleaseMove(op);return true end
        if distance<best-1 then best,last=distance,Now() elseif Now()-last>20 then break end
        WaitTicks(math.max(1,math.floor(((Constants and Constants.TickRate) or 10)*0.2)))
    end
    ReleaseMove(op);return false
end
local function StagingClear(op,pos)
    local f=R.Footprint(Template(op.site.factoryId));local mobile=R.Footprint(op.builder.tp)
    if not f or not mobile or not Position(pos) or D2(pos,op.site.factoryPosition)>26^2
        or not R.Inside(pos,math.max(mobile.x,mobile.y)/2+1)
        or not MG.CanGraphAreaToStrict(pos,op.site.factoryPosition,"Land") then return false end
    local center=op.site.factoryPosition
    if math.abs(pos.x-center.x)<(f.x+mobile.x)/2+1.5
        and math.abs(pos.z-center.z)<(f.y+mobile.y)/2+1.5 then return false end
    if not op.baseName then
        for _,base in pairs(op.armyAI.bases or {}) do
            if base.baseType~="NAVAL" and Position(base.position) and Finite(base.radius)
                and D2(pos,base.position)<=(base.radius+32)^2 then return false end
        end
    end
    return true
end
local function StageAtFactory(op)
    if not Current(op) then return false end
    local origin=Copy(op.builder:GetPosition())
    if StagingClear(op,origin) then return true end
    local f=R.Footprint(Template(op.site.factoryId));local mobile=R.Footprint(op.builder.tp)
    if not f or not mobile then return false end
    local center=op.site.factoryPosition;local candidates={}
    -- Native base radii can shrink to 30. Register beside the factory, with
    -- enough clearance for both the engineer and its move arrival tolerance.
    for _,direction in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
        local pos={x=center.x+direction[1]*((f.x+mobile.x)/2+5),y=center.y,
            z=center.z+direction[2]*((f.y+mobile.y)/2+5)}
        if D2(pos,center)<=23^2 and StagingClear(op,pos) then candidates[#candidates+1]=pos end
    end
    table.sort(candidates,function(a,b)
        local x,y=D2(origin,a),D2(origin,b)
        return x==y and (a.x==b.x and a.z<b.z or a.x<b.x) or x<y
    end)
    for i=1,math.min(2,#candidates) do
        if not Current(op) then return false end
        if MoveBuilder(op,candidates[i],3) and StagingClear(op,op.builder:GetPosition()) then return true end
    end
    return false
end
local function RegisterBase(op)
    local army,u=op.army,op.builder
    if not Current(op) or not StagingClear(op,u:GetPosition()) then return false end
    AF.SetUnitBaseAssignment(army.id,u,nil)
    Creator.AddUnitToClosestManager(army.id,u)
    if not Current(op) then return false end
    local name=u.assignedToBase;local base=name and army.ai.bases[name]
    -- The creator can write assignedToBase directly. Refresh membership through
    -- the current native/compatibility helper after the host chooses the base.
    if base then AF.SetUnitBaseAssignment(army.id,u,nil);AF.SetUnitBaseAssignment(army.id,u,name) end
    if not base or base==op.sourceBaseRef or base.baseType=="NAVAL" or not Position(base.position)
        or not Finite(base.radius) or base.radius<=0
        or D2(base.position,op.site.factoryPosition)>base.radius^2 then return false end
    op.baseName,op.baseRef,op.basePosition=name,base,Copy(base.position)
    local data=op.platoonAI;data.baseName=name;data.basePosition=Copy(op.site.position);data.baseRadius=base.radius
    State(army).bases[name]={armyAI=army.ai,baseRef=base,position=Copy(base.position),landGoal=Copy(op.site.landGoal),
        site={armyAI=army.ai,factoryId=op.site.factoryId,factoryPosition=Copy(op.site.factoryPosition),
            landGoal=Copy(op.site.landGoal),shore=Copy(op.site.shore)},builder=u,factory=nil}
    for _,target in pairs(op.targets) do
        if R.Own(army,target) and not target.CaptureInProgress and not target.ReclaimInProgress then
            AF.SetUnitBaseAssignment(army.id,target,name)
        end
    end
    return true
end
function BaseConnected(army,baseName,factory)
    if not Enabled(army) then return false end
    local state=army.ai.rushBeachhead;local record=state and state.bases[baseName]
    local base=army.ai.bases and army.ai.bases[baseName]
    if state and baseName=="MAIN" and (not record or record.baseRef~=base) then
        RefreshBases(army);record=state.bases[baseName]
    end
    if not record or record.armyAI~=army.ai or base~=record.baseRef or not base or base.baseType=="NAVAL"
        or not Position(base.position) or not Finite(base.radius) or base.radius<=0
        or not Position(record.landGoal) or not MG.IsMarkerGridPresent() then return false end
    for _,field in ipairs({"builder","factory","productionFactory"}) do
        if record[field] and not R.Own(army,record[field]) then record[field]=nil end
    end
    local function present(u,kind)
        return R.Own(army,u) and u:IsCompleted() and not u.CaptureInProgress and not u.ReclaimInProgress
            and u.assignedToBase==baseName and D2(u:GetPosition(),base.position)<=base.radius^2
            and (kind~="factory" or Rules.FactoryDomain(u.tp)=="land")
            and MG.CanGraphAreaToStrict(Copy(u:GetPosition()),record.landGoal,"Land")
    end
    if factory then
        if not present(factory,"factory") then return false end
        record.productionFactory=factory
        if record.site and D2(factory:GetPosition(),record.site.factoryPosition)<1 then record.factory=factory end
    end
    if not present(record.productionFactory,"factory") and present(record.factory,"factory") then
        record.productionFactory=record.factory
    end
    if not present(record.productionFactory,"factory") and Now()>=(record.nextResolve or 0) then
        -- Native upgrades replace the entity. Resolve from real base membership
        -- independently of the combat census, avoiding circular exclusion after
        -- the first engineer/factory dies while another shore factory survives.
        record.nextResolve=Now()+5
        if not present(record.factory,"factory") then record.factory=nil end
        if not present(record.productionFactory,"factory") then record.productionFactory=nil end
        for _,unit in ipairs(AF.GetUnitsAssignedToBase(army.id,baseName,Tags.STRUCTURE*Tags.FACTORY,1) or {}) do
            if present(unit,"factory") then
                if not record.productionFactory or unit.id.index<record.productionFactory.id.index then
                    record.productionFactory=unit
                end
                if record.site and D2(unit:GetPosition(),record.site.factoryPosition)<1 then record.factory=unit end
            end
        end
    end
    local proof=factory or present(record.productionFactory,"factory") and record.productionFactory
        or present(record.factory,"factory") and record.factory or present(record.builder,"builder") and record.builder
    return proof and MG.CanGraphAreaToStrict(Copy(proof:GetPosition()),record.landGoal,"Land") or false
end
function ActiveSite(army)
    if not Enabled(army) then return nil end
    local op=State(army).operation
    return op and Current(op) and op.site or nil
end
local function RunStage(op,definitions)
    local jobs,list,placements={},{},{}
    for _,definition in ipairs(definitions) do
        local id=op.products[definition[1]]
        if id then
            local ids={[op.builder.factionTag]=id}
            local job={id=id,kind=definition[1],index=definition[2] or 1,ids=ids}
            jobs[ids]=job;list[#list+1]=ids
        end
    end
    if #list==0 then return true end
    ReleaseStartup(op)
    return R.RunConstructionQueue(op.platoon,list,1,{
        minimum=1,
        observe=function(lead) Observe(op,lead) end,
        route=function(lead,pos) return lead==op.builder and Route(op,pos) or false end,
        place=function(ids,lead)
            local job=jobs[ids]
            if not Current(op) or Now()>op.admitUntil or lead~=op.builder or not job then return false end
            local pos=Layout.FindBeachhead(op.platoon,lead,job.id,op.site,job.kind,job.index)
            if not Current(op) or not Position(pos) then return false end
            placements[#placements+1]={job=job,position=Copy(pos)}
            if #placements>12 then table.remove(placements,1) end
            return pos,job.kind=="wall" and 0 or job.kind=="factory" and 3 or 2
        end,
        valid=function(id,pos,lead)
            if not Current(op) or Now()>op.admitUntil or lead~=op.builder or not CanFund(lead,id) then return false end
            for i=#placements,1,-1 do
                local p=placements[i]
                if p.job.id==id and D2(p.position,pos)<0.01 then
                    return Layout.ValidateBeachhead(op.platoon,lead,id,op.site,p.job.kind,p.job.index,pos)
                end
            end
            return false
        end,
        started=function(_,target)
            if not Current(op) or not R.Own(op.army,target) then return end
            local pos=target:GetPosition()
            for i=#placements,1,-1 do
                local p=placements[i];local job=p.job
                if job.id==target.tpId and D2(p.position,pos)<1 then
                    op.targets[job.kind..":"..job.index]=target
                    if op.baseName and op.army.ai.bases[op.baseName]==op.baseRef then
                        AF.SetUnitBaseAssignment(op.army.id,target,op.baseName)
                        if job.kind=="factory" then State(op.army).bases[op.baseName].factory=target end
                    end
                    break
                end
            end
        end,
    })
end
function Plan(platoon,index,baseName,former)
    local army=Armies[index]
    if not Enabled(army) then return end
    local op=State(army).operation
    if not op or op.platoon~=platoon then
        if not Claim(platoon,index,baseName,former) then return end
        op=State(army).operation
    end
    if not Current(op) then return end
    local success=false
    local ok,err=pcall(function()
        op.phase="landing";op.platoonAI.eState="BeachheadLanding"
        RunStage(op,{{"defense",1}})
        local defense=op.targets["defense:1"]
        if not Current(op) or not R.Own(army,defense) or not defense:IsCompleted()
            or defense.CaptureInProgress or defense.ReclaimInProgress or not StageAtFactory(op) then return end
        if not RegisterBase(op) then return end
        op.phase="fortifying";op.platoonAI.eState="BeachheadConstruction";op.admitUntil=Now()+180
        -- Paid defense secures the landing first. The indispensable factory
        -- precedes optional geometry, so an unavailable wall cannot block it.
        RunStage(op,{{"factory",1},{"aa",1},{"wall",1},{"wall",2},{"wall",3},{"wall",4},{"wall",5},{"wall",6}})
        local built=op.targets["factory:1"]
        local ready=R.Own(army,built) and built:IsCompleted() and built or nil
        if Current(op) and BaseConnected(army,op.baseName,ready) then
            local record=State(army).bases[op.baseName]
            local factory=record and record.productionFactory
            success=R.Own(army,factory) and factory:IsCompleted() and BaseConnected(army,op.baseName,factory)
            for _,target in pairs(op.targets) do
                if R.Own(army,target) and not target.CaptureInProgress and not target.ReclaimInProgress then
                    AF.SetUnitBaseAssignment(army.id,target,op.baseName)
                end
            end
        end
    end)
    ReleaseStartup(op)
    if platoon.ai==op.platoonAI then R.ReleaseConstructionQueue(platoon,true) end
    if not success and Current(op) and op.baseName and not HasOrders(op.builder) and not R.Working(op.builder) then
        local recovered,recoveryError=pcall(StageAtFactory,op)
        if not recovered and ok then ok,err=false,recoveryError end
    end
    if Current(op) and not op.baseName and army.ai.bases[op.sourceName]==op.sourceBaseRef
        and not HasOrders(op.builder) and not R.Working(op.builder) then
        op.phase="returning";op.platoonAI.eState="BeachheadReturn"
        MoveBuilder(op,op.site.source,20)
    end
    ReleaseMove(op)
    local state=army.ai==op.armyAI and army.ai.rushBeachhead
    if state and state.operation==op then
        Block(state,op.site.key,success and 120 or 60)
        state.operation=nil;state.nextMission=Now()+(success and 30 or 15)
    end
    if op.platoonAI.rushBeachhead==op then op.platoonAI.rushBeachhead=nil end
    if R.Own(army,op.builder) and op.builder.platoon==platoon and platoon.ai==op.platoonAI then
        platoon:OnUnitRemoved(op.builder)
    end
    if army:PlatoonExists(platoon) and platoon.ai==op.platoonAI and platoon:GetNumOfUnits()==0 then army:DisbandPlatoon(platoon) end
    if not ok then Log("[RushBeachhead] army="..tostring(index).." construction failed: "..tostring(err),true) end
end
