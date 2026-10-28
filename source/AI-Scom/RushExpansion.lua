-- RC15: persistent, bounded Alloy expansion across all four factions.
-- Native field generation, faction permissions, placement and pathfinding are
-- retained. Reservations describe OWN builders, never hidden enemy positions.
Version = "9.0.21-rc22"
local AF=Import("AI/AIFunctions.lua")
local Movement=Import("AI/mods/AI-Scom/RushMovement.lua")
local MG=Import("AI/AIMarkerGenerator.lua")
local TM=Import("AI/AITargetManager.lua")
local R=Import("AI/mods/AI-Scom/RushReliability.lua")
local Log=Import("AI/debugUtilities.lua").AILog
local Factions={"EDA","CHOSEN","GUARD","SERAPHIM"}
local OWNER="alloy-expansion"
local function Now() return GetGameTimeSeconds() end
local function Finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function Valid(p)
    return type(p)=="table" and type(p.x)=="number" and type(p.z)=="number"
        and p.x==p.x and p.z==p.z and math.abs(p.x)<math.huge and math.abs(p.z)<math.huge
end
local function Key(p) return math.floor(p.x).."-"..math.floor(p.z) end
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local function Copy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function Profile(army)
    local settings=army and army.ai and army.ai.settings
    local path=tostring(settings and settings.modDirectory or ""):gsub("\\","/"):gsub("/+$","")
    return settings and (path=="AI/mods/AI-Scom" or path:sub(-#"/AI-Scom")=="/AI-Scom"
        or path=="" and settings.modName=="AI-Scom")
end
local function State(army)
    army.ai.rushExpansion=army.ai.rushExpansion or {nextScan=0,nextRecall=0,active=0,wanted=0,
        safe=0,requests={},owned={},blocked={},routes={},lastReport=-100}
    return army.ai.rushExpansion
end
local function Extractor(army,builders,state)
    local previous=state.extractor;local builder=state.extractorBuilder
    local previousTemplate=previous and __Templates.Units[previous]
    if R.Own(army,builder) and builder:IsCompleted() and R.Has(previousTemplate,Factions[army.faction])
        and R.Has(previousTemplate,"TECH1") and R.Has(previousTemplate,"ALLOYS_EXTRACTION")
        and R.AllowedTarget(previous,false) and R.Footprint(previousTemplate)
        and R.CanBuilderBuild(builder,previous) then return previous,builder end
    local candidates={}
    for id,tp in pairs(__Templates and __Templates.Units or {}) do
        if R.Has(tp,Factions[army.faction]) and R.Has(tp,"TECH1") and R.Has(tp,"ALLOYS_EXTRACTION")
            and R.AllowedTarget(id,false) and R.Footprint(tp) then candidates[#candidates+1]=id end
    end
    table.sort(candidates,function(a,b)
        local ac=((__Templates.Units[a].economy or {}).cost or {}).alloys or math.huge
        local bc=((__Templates.Units[b].economy or {}).cost or {}).alloys or math.huge
        return ac==bc and a<b or ac<bc
    end)
    -- The placement probe must be a real construction option. A visible port
    -- template can coexist with another extractor outside this army's menus.
    for _,id in ipairs(candidates) do
        for _,u in ipairs(builders or {}) do
            if R.Own(army,u) and R.CanBuilderBuild(u,id) then return id,u end
        end
    end
end
local function IdleBuilder(army,u,recallOwner)
    if not R.Own(army,u) or not army.ai or army.ai.isAlive==false or u.platoon
        or not R.Has(u.tp,"MOBILE") or not R.Has(u.tp,"ENGINEER") or not u:IsCompleted()
        or R.Has(u.tp,"COMMAND") or R.Has(u.tp,"TECH4") or R.Has(u.tp,"EXPERIMENTAL")
        or R.Has(u.tp,"SCFA_EXPERIMENTAL") or u.scoCommanderPodOwner or u.scoSourcePodOwner
        or u.CaptureInProgress or u.ReclaimInProgress or R.Working(u) or u.buildBehaviorIsActive
        or u.reclaimBehaviorIsActive or u.toggles and u.toggles.Pause
        or type(u.GetPause)=="function" and u:GetPause() then return nil end
    local tier=u.tp.general and u.tp.general.techNumber
    local construction=u.construction
    if Finite(tier) and (tier<1 or tier>3) or not construction
        or not Finite(construction.buildPower) or construction.buildPower<=0
        or not u.tp.construction or not u.tp.construction.canBuild then return nil end
    local data=u.ai;local recall=data and data.rushBuilderRecall
    if data and (data.eState=="RepairHome" or data.reservedEco)
        or army.ai.ecoReserve and army.ai.ecoReserve[u.id.index]
        or recall and (not Finite(recall.expires) or recall.expires>Now())
            and (not recallOwner or recall.owner~=recallOwner) then return nil end
    local orders=u.orders or {}
    if orders.activeOrder or next(orders.queuedOrders or {}) then return nil end
    local name=u.assignedToBase;local base=name and army.ai.bases and army.ai.bases[name]
    if not base or not Valid(base.position) or not Finite(base.radius) or base.radius<=0 then return nil end
    local pos=u:GetPosition()
    if not Valid(pos) then return nil end
    local distance=D2(pos,base.position)
    if distance>(base.radius+50)^2 then return nil end
    return name,base,Copy(pos),distance
end
local function GapReachable(u,pos,base)
    local layer=Movement.UnitMovementLayer(u)
    return (layer=="Land" or layer=="Hover" or layer=="Seabed")
        and type(MG.CanGraphAreaToStrict)=="function"
        and MG.CanGraphAreaToStrict(pos,base.position,layer)==true
end
local function CurrentRoster(army,state)
    local now=Now()
    return state and state.armyAI==army.ai and state.base==army.ai.bases.MAIN
        and state.at and now>=state.at and now-state.at<6
end
-- Shared by production staffing and construction selection. Only the bounded
-- current fringe roster widens the native pool; the read never clears work.
function IdleEngineerBase(army,u)
    local name,base,pos,distance=IdleBuilder(army,u)
    if not name then return nil end
    if distance<=base.radius^2 then return name,base end
    local state=army.ai.rushExpansion
    if not CurrentRoster(army,state) then return nil end
    for _,entry in ipairs(state.recruits or {}) do
        if entry.unit==u and entry.ai==u.ai and entry.base==base and entry.baseName==name
            and GapReachable(u,pos,base) then return name,base end
    end
end
local function KeepCandidate(list,entry,cursor)
    list[#list+1]=entry
    table.sort(list,function(a,b)
        local ai,bi=a.unit.id.index,b.unit.id.index
        local aw,bw=cursor and ai<=cursor or false,cursor and bi<=cursor or false
        if aw~=bw then return not aw end
        return ai<bi
    end)
    if #list>12 then list[13]=nil end
end
function Safe(army,pos,layer)
    if not Valid(pos) or type(TM.GetThreatFromHeatMapPosition)~="function" then return false end
    -- Heatmap layers describe the layer BEING ATTACKED, not the enemy type.
    -- Land therefore includes known bombers/gunships. Pure anti-air alone must
    -- not scare a ground engineer away from otherwise safe expansion.
    local ok,value=pcall(TM.GetThreatFromHeatMapPosition,army.id,pos,"Land")
    if not ok or type(value)~="number" or value~=0 then return false end
    if layer and layer~="Land" and layer~="Air" then
        ok,value=pcall(TM.GetThreatFromHeatMapPosition,army.id,pos,layer)
        if not ok or type(value)~="number" or value~=0 then return false end
    end
    return true
end
function SpotAllowed(army,pos,id,fieldKey)
    -- The native capture plan stores a FACTION -> template mapping, whereas
    -- controller snapshots carry a string. Accept both contracts explicitly.
    if type(id)=="table" then id=id[Factions[army.faction]] end
    if type(id)~="string" or not R.AllowedTarget(id,false)
        or not R.Has(__Templates.Units[id],Factions[army.faction])
        or not Valid(pos) or type(AF.CanBuildStructureAt)~="function" or not R.Inside(pos) then return false end
    local blacklist=army.ai.alloyFieldBlacklist or {}
    if blacklist[Key(pos)] or fieldKey and blacklist[fieldKey] then return false end
    local state=army.ai.rushExpansion
    if state and (state.blocked[Key(pos)] or 0)>Now() then return false end
    if not Safe(army,pos) then return false end
    return AF.CanBuildStructureAt(army.id,id,pos,0)==true
end
function Defer(army,pos,seconds,builder)
    if not Valid(pos) then return end
    local state=State(army);local untilTime=Now()+(seconds or 30)
    if R.Own(army,builder) then
        -- A failed approach belongs to this builder and origin, not the spot.
        -- Other engineers, movement layers and islands remain eligible.
        state.routes=state.routes or {}
        local start=builder:GetPosition();local layer=(Movement.UnitMovementLayer(builder) or "Land")
        local route=state.routes[builder]
        if not route or route.layer~=layer or D2(route.origin,start)>24^2 then
            route={origin=Copy(start),layer=layer,blocked={}};state.routes[builder]=route
        end
        route.blocked[Key(pos)]=untilTime
    else state.blocked[Key(pos)]=untilTime end
end
local function Active(army,state)
    local count,pending,requests,owned=0,0,{},{}
    local recruits,builders,menusByTemplate={},{},{}
    for _,u in pairs(army.units or {}) do
        if R.Own(army,u) then
            if R.Has(u.tp,"ALLOYS_EXTRACTION") and u:IsCompleted() then
                local p=u:GetPosition();if Valid(p) then owned[Key(p)]=true end
            end
            -- Reuse this existing census. Native return-home tolerates an
            -- extra 50 units that its builder pool does not recruit from.
            local name,source,pos,distance=IdleBuilder(army,u)
            if name and distance>source.radius^2 and GapReachable(u,pos,source) then
                KeepCandidate(recruits,{unit=u,ai=u.ai,base=source,baseName=name},state.recruitCursor)
            end
            if R.Has(u.tp,"MOBILE") and R.Has(u.tp,"ENGINEER") and not R.Has(u.tp,"COMMAND")
                and not R.Has(u.tp,"TECH4") and R.Has(u.tp,Factions[army.faction])
                and u.construction and u:IsCompleted() and not u.scoCommanderPodOwner and not u.scoSourcePodOwner then
                local previous=menusByTemplate[u.tp]
                if not previous or u.id.index<previous.id.index then menusByTemplate[u.tp]=u end
            end
            local data=u.ai;local p=u.platoon
            local f=p and p.ai and p.ai.formerTable
            if f and not p.dead and f.AIPlan=="planEngineerCapAlloySpot" and data and data.eState~="Disband" then
                count=count+1
                local spot=data.nextResourceSpot
                if spot and Valid(spot.position) then requests[Key(spot.position)]={position=Copy(spot.position),builder=u,expires=Now()+10} end
            elseif data and data.rushBuilderRecall and data.rushBuilderRecall.owner==OWNER
                and data.rushBuilderRecall.expires>Now() then pending=pending+1 end
        end
    end
    for _,u in pairs(menusByTemplate) do KeepCandidate(builders,{unit=u},state.menuCursor) end
    -- Rotate the bounded tranche: permanently unreachable early unit IDs
    -- cannot hide later hover workers or a different legal construction menu.
    if recruits[#recruits] then state.recruitCursor=recruits[#recruits].unit.id.index end
    if builders[#builders] then state.menuCursor=builders[#builders].unit.id.index end
    local menus={}
    for _,entry in ipairs(builders) do menus[#menus+1]=entry.unit end
    return count,pending,requests,owned,recruits,menus
end
function Refresh(army,snapshot,force)
    if not Profile(army) or army.ai.isAlive==false then return nil end
    local ai=army.ai;local state=State(army);local now=Now()
    if state.at and now<state.at then
        state.recruits={};state.spots={};state.routes={};state.blocked={};state.nextRecall=0;state.nextScan=now
        state.recruitCursor=nil;state.menuCursor=nil;state.extractorBuilder=nil
    end
    if not force and now>=state.nextScan-3 and now<state.nextScan then return state end
    state.nextScan=now+3
    local base=ai.bases and ai.bases.MAIN
    if not base or not Valid(base.position) then
        state.safe=0;state.wanted=0;state.recruits={};state.spots={};state.base=nil;state.extractorBuilder=nil;return state
    end
    -- Refresh the same native fields the capture plans consume, even after all
    -- old capture strategies have gone inactive. Never replace a newer AI/base.
    if type(MG.CreateAlloyFields)=="function" and
        (not ai.alloyFields or not ai.lastAlloyUpdate or now<ai.lastAlloyUpdate or now-ai.lastAlloyUpdate>=5) then
        local fields=MG.CreateAlloyFields(army.id)
        if army.ai~=ai or ai.isAlive==false or ai.bases.MAIN~=base then return nil end
        if type(fields)=="table" then ai.alloyFields=fields;ai.lastAlloyUpdate=Now() end
    end
    state.at=Now()
    local builders
    state.active,state.pending,state.requests,state.owned,state.recruits,builders=Active(army,state)
    state.base=base;state.armyAI=ai
    for key,untilTime in pairs(state.blocked) do if untilTime<=now then state.blocked[key]=nil end end
    for builder,route in pairs(state.routes or {}) do
        for key,untilTime in pairs(route.blocked) do if untilTime<=now then route.blocked[key]=nil end end
        if not R.Own(army,builder) or not next(route.blocked) then state.routes[builder]=nil end
    end
    local id,builder=Extractor(army,builders,state);state.extractor=id;state.extractorBuilder=builder
    state.safe,state.wanted,state.first,state.spots=0,0,nil,{}
    if not id or type(AF.CanBuildStructureAt)~="function" then return state end
    local candidates,seen={},{}
    for _,field in pairs(ai.alloyFields or {}) do
        if type(field)=="table" then
            for _,spot in pairs(field) do
                local pos=type(spot)=="table" and spot.position
                if Valid(pos) and not seen[Key(pos)] and D2(base.position,pos)<=1500^2 then
                    seen[Key(pos)]=true
                    if not state.requests[Key(pos)] and not state.owned[Key(pos)] then
                        candidates[#candidates+1]={position=Copy(pos),fieldKey=field.key,distance=D2(base.position,pos)}
                    end
                end
            end
        end
    end
    table.sort(candidates,function(a,b)
        if a.distance~=b.distance then return a.distance<b.distance end
        return a.position.x==b.position.x and a.position.z<b.position.z or a.position.x<b.position.x
    end)
    -- Scan a near-home tranche plus a rotating tranche. Native placement/threat
    -- queries are bounded without letting a blocked cluster hide the rest of the map.
    local tested={};local n=#candidates;local offset=n>0 and (state.offset or 0)%n or 0
    local function inspect(i)
        if tested[i] then return end;tested[i]=true
        local c=candidates[i]
        if c and SpotAllowed(army,c.position,id,c.fieldKey) then
            state.safe=state.safe+1;state.spots[#state.spots+1]=c
            if not state.first or c.distance<state.first.distance then state.first=c end
        end
    end
    for i=1,math.min(12,n) do inspect(i) end
    for i=1,math.min(12,n) do inspect((offset+i-1)%n+1) end
    state.offset=n>0 and (offset+12)%n or 0
    local constructors=snapshot.engineersComplete or (snapshot.roles and snapshot.roles.engineer) or 0
    local slots=math.min(3,math.max(1,math.floor((constructors-1)/2)))
    if (snapshot.completeFactories or 0)<1 or (snapshot.extractors or 0)<1 then slots=0 end
    if constructors<=1 and (snapshot.extractors or 0)>=4 then slots=0 end
    if snapshot.energy and snapshot.energy.ratio<0.12 and snapshot.energy.balance<0 then slots=0 end
    state.wanted=math.min(slots,state.active+state.safe)
    if now-state.lastReport>=30 then
        state.lastReport=now
        Log(("[RushExpansion] army=%s active=%d wanted=%d safeSample=%d recall=%d engineers=%d")
            :format(tostring(army.id),state.active,state.wanted,state.safe,state.pending,constructors),true)
    end
    return state
end
-- A capture assignment evaluates at most 24 candidate spots and four native
-- paths, with fresh placement/threat/claim rechecks after any yielding path. Failed near spots cannot hide distant free sites:
-- they receive short per-army exclusions and a second tranche rotates outward.
function FindSpot(platoon,builder,reservations)
    local army,unitAI,planAI=builder.army,builder.ai,platoon.ai
    local state=State(army);local start=builder:GetPosition()
    local route=state.routes and state.routes[builder]
    if route and (route.layer~=planAI.movementLayer or D2(route.origin,start)>24^2) then
        state.routes[builder]=nil;route=nil
    end
    local reserved=reservations(platoon);local candidates,seen={},{}
    local base=planAI.basePosition;local inner=(planAI.capRadiusMin or 0)^2
    local outer=(planAI.capRadiusMax or 1500)^2
    for _,field in pairs(army.ai.alloyFields or {}) do
        if type(field)=="table" then
            for _,spot in pairs(field) do
                local pos=type(spot)=="table" and spot.position
                if Valid(pos) then
                    local key=Key(pos);local distance=D2(base,pos)
                    if not seen[key] and not reserved[key] and distance>=inner and distance<=outer
                        and (state.blocked[key] or 0)<=Now()
                        and (not route or (route.blocked[key] or 0)<=Now()) then
                        seen[key]=true;candidates[#candidates+1]={field=field,spot=spot,key=key,distance=D2(start,pos)}
                    end
                end
            end
        end
    end
    table.sort(candidates,function(a,b)
        if a.distance~=b.distance then return a.distance<b.distance end
        return a.key<b.key
    end)
    local n=#candidates;if n==0 then return nil end
    local order,tested={},{};local offset=(state.selectOffset or 0)%n
    local function add(i) if not tested[i] then tested[i]=true;order[#order+1]=i end end
    for i=1,math.min(12,n) do add(i) end
    for i=1,math.min(12,n) do add((offset+i-1)%n+1) end
    state.selectOffset=(offset+12)%n
    local attempts=0
    for _,i in ipairs(order) do
        local c=candidates[i];local pos=c.spot.position
        if not R.CurrentAssignment(builder,army,platoon,unitAI,planAI) then return nil end
        if SpotAllowed(army,pos,planAI.nextBuildingtpId,c.field.key) then
            attempts=attempts+1
            local threat=AF.GetUnitThreatValueByLayer(builder,"Land")
            local path=MG.GeneratePathTo(army.id,start,pos,planAI.movementLayer,true,threat)
            if not R.CurrentAssignment(builder,army,platoon,unitAI,planAI) then return nil end
            if type(path)=="table" and next(path) then
                local distance=MG.GetPathDistance(path)
                if type(distance)=="number" and distance==distance and distance<math.huge
                    and not reservations(platoon)[c.key]
                    and SpotAllowed(army,pos,planAI.nextBuildingtpId,c.field.key) then
                    return c.field,c.spot,path,distance
                end
            else Defer(army,pos,30,builder) end
            if attempts>=4 then break end
        end
    end
    return nil
end
-- Recruit only idle workers stranded in the native return/recruit radius gap.
-- No orders, path searches or base reassignment occur here. The existing plan
-- retains its actual structure menu, funding, placement and path checks.
function Builders(army,baseName,former,units,tags)
    local result={}
    for _,u in ipairs(units or {}) do result[#result+1]=u end
    local state=army and army.ai and army.ai.rushExpansion
    local base=army and army.ai and army.ai.bases and army.ai.bases[baseName]
    if not former.WantStructures or not base or not CurrentRoster(army,state) then return result end
    local capture=former.RushPersistentExpansion
    if capture and (not state.extractor or state.safe<=0) then return result end
    local seen={}
    for _,u in ipairs(result) do seen[u]=true end
    for _,entry in ipairs(state.recruits or {}) do
        local u=entry.unit
        local name,source,pos,distance=IdleBuilder(army,u,former.RushBuilderRecallOwner)
        if not seen[u] and name==baseName and source==base and entry.base==base and entry.baseName==baseName
            and u.ai==entry.ai and (not tags or u:HasTags(tags)) and distance>base.radius^2
            and GapReachable(u,pos,base) then
            local reachable=not capture
            if capture and R.CanBuilderBuild(u,state.extractor) then
                local layer=Movement.UnitMovementLayer(u)
                local route=state.routes and state.routes[u]
                if route and (route.layer~=layer or D2(route.origin,pos)>24^2) then route=nil end
                for _,spot in ipairs(state.spots or {}) do
                    local key=Key(spot.position)
                    if (state.blocked[key] or 0)<=Now()
                        and (not route or (route.blocked[key] or 0)<=Now())
                        and MG.CanGraphAreaToStrict(pos,spot.position,layer) then reachable=true;break end
                end
            end
            if reachable then result[#result+1]=u;seen[u]=true end
        end
    end
    return result
end
function Needed(army,snapshot)
    local state=Refresh(army,snapshot)
    return state and state.safe>0 and state.active<state.wanted or false
end
function Maintain(army,snapshot)
    local state=Refresh(army,snapshot)
    if not state or state.safe==0 or state.active>=state.wanted or state.pending>0 or not state.first then return end
    if Now()<state.nextRecall then return end
    state.nextRecall=Now()+5
    -- Distant, paused or externally ordered engineers are not available to
    -- this base. Query the same guarded selector that will execute the job.
    if state.former and AF.GetNeedMobileBuilder(army.id,"MAIN",state.former) then return end
    -- Only a travelling/orderless reclaimer is eligible; active paid work stays
    -- with its owner. The old coroutine performs the eventual release itself.
    R.RequestConstructionBuilder(army,state.extractor,state.first.position,OWNER,true)
end
function AddFormer(army,formers)
    for _,f in pairs(formers) do
        if f.RushPersistentExpansion then State(army).former=f;return formers end
    end
    local former={FormerName="R15 persistent Alloy expansion",AIPlan="planEngineerCapAlloySpot",
        Priority=9430,FormNumInstances=3,RushDevelopment=true,RushPersistentExpansion=true,
        RushBuilderRecallOwner=OWNER,DebugPlatoon=false,AIdifficulty={easy=true,medium=true,hard=true},
        RunOnBaseType={MAIN=true,EXPANSION=false,OUTPOST=false,NAVAL=false},RunWithStrategyName={},
        AIPlanData={SearchInnerRing=0,SearchOuterRing=1500},
        NeedMobileBuilder={{Tags.ENGINEER*Tags.MOBILE-Tags.COMMAND-Tags.TECH4,1,1,0}},
        WantStructures={Tags.ALLOYS_EXTRACTION*Tags.TECH1*Tags[Factions[army.faction]]},
        FormerConditions={},AllowEcoStorageDrain=true}
    formers[#formers+1]=former;State(army).former=former
    return formers
end
