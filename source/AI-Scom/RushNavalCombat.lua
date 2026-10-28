-- Bounded naval operations use each group's actual native movement capability.
-- Walking ships retain sea combat and can exploit safe, gun-reachable inland targets.
Version = "9.0.12-rc13"
local Selection=Import("AI/mods/AI-Scom/RushSelection.lua")
local AF=Import("AI/AIFunctions.lua")
local MG=Import("AI/AIMarkerGenerator.lua")
local TM=Import("AI/AITargetManager.lua")
local Intel=Import("AI/mods/AI-Scom/RushCombatIntel.lua")
local Heavy=Import("AI/mods/AI-Scom/RushHeavyConstruction.lua")
local HeavyPolicy=Import("AI/mods/AI-Scom/RushHeavyPolicy.lua")
local Budget=Import("AI/mods/AI-Scom/RushPathBudget.lua")
local Movement=Import("AI/mods/AI-Scom/RushMovement.lua")
local Orders=Import("host/managers/orders/hostOrderManager.lua")
local Tasks=Import("common/commonOrders.lua").OrderTasks
local Log=Import("AI/debugUtilities.lua").AILog
local Targeting=Import("common/layers.lua").TargetingLayer
local Bit=require("bit")
local function Now() return GetGameTimeSeconds() end
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local function Copy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function Own(p,u) return u and u.id and not u.dead and not u.deleted and u.army==p.army
    and p.army.units[u.id.index]==u and u.platoon==p and not u.CaptureInProgress and not u.ReclaimInProgress
    and not (u.ai and u.ai.eState=="RepairHome") and not (u.toggles and u.toggles.Pause) end
local function Live(p) return p and not p.dead and not p.deleted and p.ai and p.army and p.army.ai
    and p.army.ai.isAlive~=false and p.army:PlatoonExists(p) end
local function State(a)
    a.ai.rushNavalCombat=a.ai.rushNavalCombat or {operations={},paths=0}
    local state=a.ai.rushNavalCombat
    if Now()>=(state.nextPrune or 0) or Now()<(state.lastTime or 0) then
        state.nextPrune=Now()+1
        for id,p in pairs(state.operations) do
            if p.army~=a or not Live(p) or not p.ai or not p.ai.rushFleet then state.operations[id]=nil end
        end
    end
    state.lastTime=Now()
    if state.recoveryPool and (Now()<state.recoveryPool.at or Now()>=state.recoveryPool.at+2) then state.recoveryPool=nil end
    return state
end
local nodeCaches={}
local NODE_CELL=64
local COASTAL_LAYERS={"Land","WaterSurface"}
local function Nodes(layer)
    layer=layer or "Water"
    local grid=MG.GetMarkerTable(layer)
    local hasLifecycle=type(MG.IsMarkerGridPresent)=="function" and type(MG.IsMarkerGridUpdating)=="function"
    if hasLifecycle and (MG.IsMarkerGridUpdating() or not MG.IsMarkerGridPresent()) then
        nodeCaches={}
        return {},{}
    end
    -- Native ready marker coordinates are static for the generation. A host
    -- without lifecycle APIs gets only exact-clock-epoch reuse, not a permanent
    -- assumption about a partially populated/mutable grid.
    local cache=nodeCaches[layer]
    if cache and grid==cache.grid and (hasLifecycle or cache.at==Now()) then return cache.nodes,cache end
    cache={grid=grid,nodes={},cells={},ordinal={},at=Now()};nodeCaches[layer]=cache
    local cachedNodes,cachedCells,cachedOrdinal=cache.nodes,cache.cells,cache.ordinal
    for _,row in pairs(grid or {}) do
        if type(row)=="table" then for _,n in pairs(row) do
            if type(n)=="table" and n.GraphArea and n.position then
                cachedNodes[#cachedNodes+1]=n
            end
        end end
    end
    table.sort(cachedNodes,function(a,b)
        return a.position.x==b.position.x and a.position.z<b.position.z or a.position.x<b.position.x
    end)
    for i,n in ipairs(cachedNodes) do
        cachedOrdinal[n]=i
        local x,z=math.floor(n.position.x/NODE_CELL),math.floor(n.position.z/NODE_CELL)
        local row=cachedCells[x]
        if not row then row={};cachedCells[x]=row end
        local cell=row[z]
        if not cell then cell={};row[z]=cell end
        cell[#cell+1]=n
    end
    return cachedNodes,cache
end
local function Graph(p,layer)
    local grid=MG.GetMarkerTable(layer or "Water")
    local x,z=MG.GetMarkerGridIndexFromWorldPosition(p)
    return x and z and grid and grid[x] and grid[x][z] and grid[x][z].GraphArea
end
local function Wet(p)
    if type(SnapToGround)~="function" or not Engine or type(Engine.GetWaterLevel)~="function" then return nil end
    local code,water=Engine.GetWaterLevel()
    if EngineErrorCode and code~=EngineErrorCode.Success then return nil end
    local ground=SnapToGround(Copy(p))
    if type(water)~="number" or not ground or type(ground.y)~="number" then return nil end
    return ground.y<water
end
local function Layers(p) return p.ai.rushFleet.threatLayers or (p.ai.rushAmphibiousNaval and COASTAL_LAYERS or "WaterSurface") end
local function Surface(p,pos) return p.ai.rushAmphibiousNaval and Wet(pos)==false and "Land" or "WaterSurface" end
local function PositionAllowed(p,pos)
    local ai=p.ai;local layer=ai.movementLayer
    if Graph(pos,layer)~=ai.rushFleet.graph then return false end
    local wet=Wet(pos)
    return wet~=nil and (layer~="Water" or wet)
end
function IsAmphibiousNaval(u)
    if not u or u.dead or u.deleted then return false end
    local heavy=HeavyPolicy.IsCombatExperimental(u.tp) and HeavyPolicy.Domain(u.tp)=="naval"
    if not heavy and not u:HasTags(Tags.MOBILE*Tags.NAVAL-Tags.ENGINEER-Tags.COMMAND) then return false end
    local layer=Movement.UnitMovementLayer(u)
    return (layer=="Hover" or layer=="Seabed")
        and (AF.GetUnitThreatValueByLayer(u,"Land",false) or 0)>0
        and (AF.GetUnitMaximumWeaponRangeByLayer(u,"Land") or 0)>0
end
local function Offensive(u)
    for _,weapon in ipairs(u.weapons or {}) do
        local tp=weapon.tp or weapon
        if weapon.enabled and not weapon.isDeathExplosion and (tp.rangeMax or 0)>0
            and ((tp.damage or 0)>0 or (tp.damageOverTimePulseCount or 0)*(tp.damageOverTimePulseDamage or 0)>0) then
            local limits=tp.layerTargetLimits
            if not limits or #limits==0 then return true end
            for _,layer in ipairs(limits) do
                if layer=="Land" or layer=="WaterSurface" or layer=="Water" or layer=="Seabed" then return true end
            end
        end
    end
    return false
end
local function Compatible(u,layer,legacy)
    local actual=Movement.UnitMovementLayer(u)
    return actual==layer or legacy and not actual and layer=="Water"
        or layer=="Water" and actual=="Hover" and not IsAmphibiousNaval(u)
end
local function Available(army,u,heavy)
    local orders=u and u.orders
    return u and u.id and not u.dead and not u.deleted and u.army==army and army.units[u.id.index]==u
        and not u.platoon and u:IsCompleted() and not u.CaptureInProgress and not u.ReclaimInProgress
        and (heavy or not HeavyPolicy.IsT4(u.tp))
        and not (u.toggles and u.toggles.Pause) and not (u.ai and u.ai.eState=="RepairHome")
        and not u.unitBeingBuilt and not u.unitBeingAssist and not u.unitBeingRepair
        and not (u.buildQueue and u.buildQueue[1])
        and not (orders and (orders.activeOrder or next(orders.queuedOrders or {})))
end
local function RecoveryPool(army,baseName)
    local state=State(army);local pool=state.recoveryPool;local now=Now()
    if not pool or now<pool.at or now>=pool.at+2 then
        pool={at=now,bases={}};state.recoveryPool=pool
        -- Reuse the shared native-intel owner shard. This is not another scan
        -- of army.units for every base and every former scheduler pass.
        for _,shard in ipairs(Intel.Get(army).friendlyShards) do
            if shard.owner==army then
                for _,record in ipairs(shard.data.records) do
                    local u=record.unit;local name=u.assignedToBase
                    local base=name and army.ai.bases[name]
                    if base and Available(army,u) and IsAmphibiousNaval(u) then
                        local entry=pool.bases[name]
                        if not entry then entry={base=base,units={}};pool.bases[name]=entry end
                        entry.units[#entry.units+1]=u
                    end
                end
                break
            end
        end
    end
    local entry=pool.bases[baseName]
    return entry and entry.base==army.ai.bases[baseName] and entry.units or {}
end
-- CheckNeedUnits and Run share this exact candidate partition. A water-only
-- escort can never turn a walking strike group back into a water-only fleet.
function GetUnits(index,baseName,former)
    local army=Armies[index];local base=army and army.ai and army.ai.bases[baseName]
    if not base then return false end
    if former.RushHeavyCombat then
        local units,minimum,maximum,reserve,graph=Heavy.GetCombatUnits(index,baseName,former)
        local layer="Water"
        local actual=units and #units==1 and Movement.UnitMovementLayer(units[1])
        if actual=="Hover" or actual=="Seabed" then
            local actualGraph=Graph(units[1]:GetPosition(),actual)
            if actualGraph then layer,graph=actual,actualGraph end
        end
        return units,minimum,maximum,reserve,graph,layer
    end
    local units,minimum,maximum,reserve=AF.GetNeedUnits(index,baseName,former)
    local definition=former.NeedUnits and former.NeedUnits[1]
    if not definition then return false end
    minimum,maximum,reserve=minimum or definition[2],maximum or definition[3],reserve or definition[4]
    local amphibious=former.RushAmphibiousNaval==true;local sourceGraph
    if not amphibious then
        if type(AF.GetNavalGraphAreaForBase)=="function" then sourceGraph=AF.GetNavalGraphAreaForBase(index,baseName) end
        sourceGraph=sourceGraph or base.waterGraphArea or (Wet(base.position) and Graph(base.position))
    end
    local groups,fallback,offensive,seen={},{},{},{}
    local function add(u)
        if seen[u] then return end
        seen[u]=true
        if not Available(army,u) then return end
        local walks=IsAmphibiousNaval(u)
        if amphibious and not walks then return end
        local layer=walks and Movement.UnitMovementLayer(u) or "Water"
        local pos=Copy(u:GetPosition());local graph=Graph(pos,layer)
        if not graph or not Compatible(u,layer,false) or Wet(pos)==nil
            or not walks and (not Wet(pos) or sourceGraph and graph~=sourceGraph) then return end
        local partition=not amphibious and walks and fallback or groups
        local key=layer..":"..tostring(graph);local group=partition[key]
        if not group then group={units={},layer=layer,graph=graph,offensive=false,key=key};partition[key]=group end
        group.units[#group.units+1]=u;offensive[u]=Offensive(u)
        group.offensive=group.offensive or offensive[u]
    end
    local function choose(partition)
        local best
        for _,g in pairs(partition) do
            if g.offensive and #g.units>=math.max(1,minimum or 1)+math.max(0,reserve or 0)
                and (not best or #g.units>#best.units or #g.units==#best.units and g.key<best.key) then best=g end
        end
        return best
    end
    for _,u in ipairs(units or {}) do add(u) end
    local best=choose(groups)
    if amphibious or not best then
        -- Recovery uses exact native source membership, including landed ships
        -- outside the old naval radius, with no per-base army-table rescan.
        for _,u in ipairs(RecoveryPool(army,baseName)) do
            if u.assignedToBase==baseName and u:HasTags(definition[1]) then add(u) end
        end
        best=choose(groups)
    end
    -- Dedicated walking fleets have first scheduler priority. If those slots
    -- are occupied, an ordinary slot can launch a pure walking group instead
    -- of permanently stranding additional ships or mixing in water-only escorts.
    best=best or not amphibious and choose(fallback)
    if not best then return false end
    table.sort(best.units,function(a,b)
        if offensive[a]~=offensive[b] then return offensive[a] end
        return a.id.index<b.id.index
    end)
    return best.units,minimum,maximum,reserve,best.graph,best.layer
end
local function Units(p)
    local us={}
    for _,u in pairs(p:GetUnits()) do if Own(p,u) then us[#us+1]=u end end
    return us
end
local function WatchMicroOrders(p,u)
    local ai=p.ai
    u.ai.rushFleetMicroOrders={owner=p.army,armyAI=p.army.ai,platoon=p,pai=ai,
        operation=ai.rushOperation,fleet=ai.rushFleet,ai=u.ai,orders={}}
end
local function CompatibleFleet(p)
    local units=Units(p)
    if #units==0 then return false end
    for _,u in ipairs(units) do
        if not Compatible(u,p.ai.movementLayer,p.ai.formerTable.RushHeavyCombat) then return false end
    end
    return true
end
-- Use the weapons that can actually hit THIS target. A long torpedo range
-- does not authorize a distant shore bombardment by a short-range deck gun.
local function TargetRange(p,t,units)
    local range,minimum=0,0
    for _,u in ipairs(units or Units(p)) do
        if not Movement.Suspended(u) then
            for _,w in ipairs(u.weapons or {}) do
                if w.enabled and not w.isDeathExplosion and w:CanShootAt(t) then
                    local tp=w.tp or w;local maximum=tp.rangeMax or w.rangeMax or 0
                    local inner=tp.rangeMin or 0
                    if maximum>inner and maximum>range then range,minimum=maximum,inner end
                end
            end
        end
    end
    return range,minimum
end
-- Micro asks for a firing position for its selected gun, not the fleet's
-- longest torpedo or an unrelated siege weapon. No native path search here.
function MicroFiringPosition(p,u,target,minimum,maximum)
    if not Live(p) or not p.ai.rushFleet or not Own(p,u) or Movement.Suspended(u) or not Intel.Visible(p.army,target)
        or not Compatible(u,p.ai.movementLayer,p.ai.formerTable.RushHeavyCombat) then return nil end
    minimum=math.max(1,(minimum or 0)+1);maximum=(maximum or 0)-1
    if maximum<=minimum then return nil end
    local origin=Copy(u:GetPosition());local position=Copy(target:GetPosition())
    local dx,dz=origin.x-position.x,origin.z-position.z
    local distance=math.sqrt(dx*dx+dz*dz);if distance<1 then dx,dz,distance=1,0,1 end
    for _,radius in ipairs({maximum,math.max(minimum,maximum*0.7)}) do
        for _,angle in ipairs({0,0.7,-0.7,1.4,-1.4}) do
            local c,s=math.cos(angle),math.sin(angle)
            local point=Copy(AF.GetPositionWithinPlayableArea({x=position.x+(dx*c-dz*s)/distance*radius,y=position.y,
                z=position.z+(dx*s+dz*c)/distance*radius}))
            local separation=D2(point,position)
            if separation>=minimum^2 and separation<=maximum^2 and PositionAllowed(p,point)
                and Intel.ClearRendezvous(p.army,point,4) then return point end
        end
    end
end
-- Contact filtering is non-yielding and bounded. A shot already in native
-- weapon range remains valid across terrain that the ship cannot traverse.
function CanEngage(p,unit,target)
    if not Live(p) or not p.ai.rushFleet or not Intel.Visible(p.army,target) then return false end
    local layer=p.ai.movementLayer;local targetPos=Copy(target:GetPosition());local shooters={}
    for _,u in ipairs(unit and {unit} or Units(p)) do
        if Own(p,u) and not Movement.Suspended(u) and Compatible(u,layer,p.ai.formerTable.RushHeavyCombat) then
            local reach,minimum=0,0
            for _,weapon in ipairs(u.weapons or {}) do
                if weapon.enabled and not weapon.isDeathExplosion and weapon:CanShootAt(target) then
                    if weapon:IsTargetInRange(target) then return true end
                    local tp=weapon.tp or weapon;local maximum,inner=tp.rangeMax or 0,tp.rangeMin or 0
                    if maximum>inner and maximum>reach then reach,minimum=maximum,inner end
                end
            end
            if reach>minimum+2 then
                local origin=Copy(u:GetPosition());local score=math.sqrt(D2(origin,targetPos))-reach
                local entry={pos=origin,range=reach,minimum=minimum,score=score,id=u.id.index}
                local first=shooters[1]
                if not first or score<first.score or score==first.score and entry.id<first.id then
                    shooters[2],shooters[1]=first,entry
                else
                    local second=shooters[2]
                    if not second or score<second.score or score==second.score and entry.id<second.id then shooters[2]=entry end
                end
            end
        end
    end
    if #shooters==0 then return false end
    if PositionAllowed(p,targetPos) then return true end
    -- This broad contact gate samples at most two shooters and three graph
    -- positions each. Detailed obstacle placement belongs to selected-gun micro.
    for _,entry in ipairs(shooters) do
        local dx,dz=entry.pos.x-targetPos.x,entry.pos.z-targetPos.z
        local distance=math.sqrt(dx*dx+dz*dz);if distance<1 then dx,dz,distance=1,0,1 end
        for _,angle in ipairs({0,0.7,-0.7}) do
            local c,s=math.cos(angle),math.sin(angle)
            local point={x=targetPos.x+(dx*c-dz*s)/distance*(entry.range-2),y=targetPos.y,
                z=targetPos.z+(dx*s+dz*c)/distance*(entry.range-2)}
            if PositionAllowed(p,point) then return true,point end
        end
    end
    return false
end
local function RefreshThreatLayers(p,units)
    local op=p.ai.rushFleet;local seen={}
    if p.ai.rushAmphibiousNaval then seen.Land=true;seen.WaterSurface=true end
    for _,u in ipairs(units) do
        local mask=u.targetingLayer or u.tp and u.tp.general and u.tp.general.targetingLayer
        local known=false
        if type(mask)=="number" then
            for _,name in ipairs({"Land","WaterSurface","Water","Seabed"}) do
                if Targeting[name] and Bit.band(mask,Targeting[name])~=0 then seen[name]=true;known=true end
            end
        end
        if not known then seen.WaterSurface=true end
    end
    local list=op.threatLayerList or {};op.threatLayerList=list
    for i=#list,1,-1 do list[i]=nil end
    for _,name in ipairs({"Land","WaterSurface","Water","Seabed"}) do if seen[name] then list[#list+1]=name end end
    op.threatLayers=#list==1 and list[1] or list
end
local function Geometry(p)
    local active={}
    for _,u in ipairs(Units(p)) do if not Movement.Suspended(u) then active[#active+1]=u end end
    local layer=Surface(p,active[1] and active[1]:GetPosition() or p:GetPosition())
    local g=Intel.Geometry(p,layer,active)
    local currentSurface=Surface(p,g.position)
    if currentSurface~=layer then layer=currentSurface;g=Intel.Geometry(p,layer,active) end
    p.ai.rushSurfaceLayer=layer
    local own,nominal,range=0,0,0
    for _,item in ipairs(g.points) do
        if Own(p,item.unit) and not Movement.Suspended(item.unit) then
            if layer=="WaterSurface" then
                item.threat=math.max(item.threat,AF.GetUnitThreatValueByLayer(item.unit,"Water",false) or 0,
                    AF.GetUnitThreatValueByLayer(item.unit,"Seabed",false) or 0)
                item.range=math.max(item.range,AF.GetUnitMaximumWeaponRangeByLayer(item.unit,"Water") or 0,
                    AF.GetUnitMaximumWeaponRangeByLayer(item.unit,"Seabed") or 0)
            end
            nominal=nominal+item.threat
            if item.distance<=math.max(40,g.radius+item.range+16) then
                own=own+item.threat
                for _,weapon in ipairs(item.unit.weapons or {}) do
                    local tp=weapon.tp or weapon
                    if weapon.enabled and not weapon.isDeathExplosion and tp.rangeRingType~="AntiAir" then
                        range=math.max(range,tp.rangeMax or 0)
                    end
                end
            end
        end
    end
    g.own,g.nominal,g.range=own,nominal,range
    return g.position,g.own,range,g
end
local function Blocked(op,pos)
    for i=#op.blocked,1,-1 do
        if Now()>=op.blocked[i].untilTime then table.remove(op.blocked,i)
        elseif D2(pos,op.blocked[i].pos)<32^2 then return true end
    end
    return false
end
local function Reject(op,pos)
    if not pos then return end
    if #op.blocked>=12 then table.remove(op.blocked,1) end
    op.blocked[#op.blocked+1]={pos=Copy(pos),untilTime=Now()+45}
end
local function TargetStrength(p,t,units)
    local mask=t.targetingLayer or t.tp and t.tp.general and t.tp.general.targetingLayer
    local layers={}
    if type(mask)=="number" then
        for _,name in ipairs({"Land","WaterSurface","Water","Seabed"}) do
            if Targeting[name] and Bit.band(mask,Targeting[name])~=0 then layers[#layers+1]=name end
        end
    end
    if #layers==0 then layers[1]=t:HasTags(Tags.NAVAL) and "WaterSurface" or "Land" end
    local strength=0;local geometry=p.ai.rushGeometry
    for _,u in ipairs(units or Units(p)) do
        if not Movement.Suspended(u) then
            for _,w in ipairs(u.weapons or {}) do
                if w.enabled and not w.isDeathExplosion and w:CanShootAt(t) then
                    local value,reach=0,0
                    for _,layer in ipairs(layers) do
                        value=math.max(value,AF.GetUnitThreatValueByLayer(u,layer,false) or 0)
                        reach=math.max(reach,AF.GetUnitMaximumWeaponRangeByLayer(u,layer) or 0)
                    end
                    if not geometry or D2(u:GetPosition(),geometry.position)<=math.max(40,geometry.radius+reach+16)^2 then
                        strength=strength+value
                    end
                    break
                end
            end
        end
    end
    return strength
end
local function Support(p,pos,layer)
    -- The native friendly census may include a shore army that cannot join a
    -- naval fight. Count only nearby weapons already able to cover this area.
    local strength=0
    for _,u in ipairs(Intel.FriendlyUnitsInRadius(p.army,pos,80)) do
        local ai=u.platoon and u.platoon.ai
        if u.platoon~=p and not (u.ai and u.ai.eState=="RepairHome")
            and not (u.toggles and u.toggles.Pause) and not (ai and (ai.withdraw or ai.eState=="Withdraw"
                or ai.rushOperation and ai.rushOperation.policy and ai.rushOperation.policy.phase=="Retreat")) then
            local range=AF.GetUnitMaximumWeaponRangeByLayer(u,layer) or 0
            if D2(u:GetPosition(),pos)<=range*range then strength=strength+math.max(0,AF.GetUnitThreatValueByLayer(u,layer,false) or 0) end
        end
    end
    return strength
end
local function Approach(p,pos,target,range,strength,minimum)
    local layer=p.ai.movementLayer;local graph=p.ai.rushFleet.graph
    local reach=math.max(0,range-3);local reach2=reach*reach
    minimum=math.max(1,(minimum or 0)+1)
    if reach<=minimum then return nil end
    local choices={};local nodes,cache=Nodes(layer)
    local function consider(point,order)
        local distance=D2(point,target)
        if distance<=reach2 and distance>=minimum^2
            and PositionAllowed(p,point)
            and Intel.ClearRendezvous(p.army,point,4) then
            choices[#choices+1]={pos=Copy(point),score=math.sqrt(D2(pos,point))+math.max(0,reach-math.sqrt(distance))*0.3,order=order}
        end
    end
    consider(pos,0)
    local dx,dz=pos.x-target.x,pos.z-target.z;local distance=math.sqrt(dx*dx+dz*dz)
    if distance<1 then dx,dz,distance=1,0,1 end
    local order=1
    for _,factor in ipairs({1,0.68}) do
        for _,angle in ipairs({0,0.55,-0.55,1.1,-1.1,1.65,-1.65,math.pi}) do
            local c,s=math.cos(angle),math.sin(angle)
            local point=AF.GetPositionWithinPlayableArea({x=target.x+(dx*c-dz*s)/distance*reach*factor,
                y=target.y,z=target.z+(dx*s+dz*c)/distance*reach*factor})
            consider(point,order);order=order+1
        end
    end
    local function node(n)
        if n.GraphArea==graph and D2(n.position,target)<=reach2 then consider(n.position,(cache.ordinal[n] or 0)+32) end
    end
    local x0,x1=math.floor((target.x-reach)/NODE_CELL),math.floor((target.x+reach)/NODE_CELL)
    local z0,z1=math.floor((target.z-reach)/NODE_CELL),math.floor((target.z+reach)/NODE_CELL)
    if (x1-x0+1)*(z1-z0+1)>#nodes+16 then
        for _,n in ipairs(nodes) do node(n) end
    else
        for x=x0,x1 do
            local row=cache.cells and cache.cells[x]
            if row then for z=z0,z1 do for _,n in ipairs(row[z] or {}) do node(n) end end end
        end
    end
    choices=Selection.Top(choices,4,function(a,b) return a.score==b.score and a.order<b.order or a.score<b.score end)
    for _,choice in ipairs(choices) do
        local own=math.max(0,strength or 0);local surface=Surface(p,choice.pos)
        local guard=Intel.EnemyThreat(p.army,choice.pos,Layers(p),12,32)
        if guard<=math.max(1,own)*1.2 or guard<=math.max(1,own+Support(p,choice.pos,surface))*1.2 then return choice.pos end
    end
end
local function Commitment(p,operations,target,pos)
    local penalty=0
    for _,other in pairs(operations) do
        local op=other.ai and other.ai.rushFleet;local goal=op and (op.goal or op.pendingRoute)
        if other~=p and Live(other) and not other.ai.withdraw and goal and goal.kind=="attack" then
            if goal.unit==target then penalty=penalty+120
            elseif goal.targetPos and D2(goal.targetPos,pos)<80^2 then penalty=penalty+50 end
        end
    end
    return math.min(240,penalty)
end
local function HomeDanger(p,pos)
    for _,base in pairs(p.army.ai.bases or {}) do
        if base.position and D2(pos,base.position)<=((base.radius or 40)+40)^2 then return 150 end
    end
    return 0
end
local function Visit(op,key)
    op.visitedOrder=op.visitedOrder or {}
    local expires=Now()+120;op.visited[key]=expires
    op.visitedOrder[#op.visitedOrder+1]={key=key,expires=expires}
    while #op.visitedOrder>48 or op.visitedOrder[1] and op.visitedOrder[1].expires<=Now() do
        local old=table.remove(op.visitedOrder,1)
        if op.visited[old.key]==old.expires then op.visited[old.key]=nil end
    end
end
function SelectGoal(p,pos,own,range)
    local op=p.ai.rushFleet;local candidates={};local enemies=Intel.Get(p.army).enemy
    local units=#enemies>0 and Units(p) or nil
    local operations=State(p.army).operations
    for _,r in ipairs(enemies) do
        local u=r.unit
        if Intel.Visible(p.army,u) and not u:HasTags(Tags.AIR) then
            local reach,minimum=TargetRange(p,u,units)
            if reach>0 then
                local value=u:HasTags(Tags.ALLOYS_EXTRACTION) and 120 or u:HasTags(Tags.FACTORY) and 150
                    or u:HasTags(Tags.ENGINEER) and 100 or u:HasTags(Tags.NAVAL) and 90 or 40
                candidates[#candidates+1]={unit=u,pos=r.pos,range=reach,minimum=minimum,
                    score=math.sqrt(D2(pos,r.pos))-value-HomeDanger(p,r.pos)+Commitment(p,operations,u,r.pos)}
            end
        end
    end
    table.sort(candidates,function(a,b) return a.score==b.score and a.unit.id.index<b.unit.id.index or a.score<b.score end)
    local offset=op.targetOffset or 0
    for i=1,math.min(8,#candidates) do
        local t=candidates[((offset+i-1)%#candidates)+1]
        local strength=TargetStrength(p,t.unit,units)
        local approach=strength>0 and Approach(p,pos,t.pos,t.range,strength,t.minimum)
        if approach and not Blocked(op,approach) then
            op.targetOffset=0
            return {pos=approach,unit=t.unit,targetPos=Copy(t.pos),kind="attack"}
        end
    end
    op.targetOffset=#candidates>0 and (offset+8)%#candidates or 0
    -- No blind inland marches: without a visible objective, scout connected
    -- water that this exact native movement group can actually traverse.
    local patrol={}
    for _,n in ipairs(Nodes("Water")) do
        if Graph(n.position,p.ai.movementLayer)==op.graph and D2(pos,n.position)>48^2 and not Blocked(op,n.position) then
            local key=n.position.x..":"..n.position.z
            if Now()>=(op.visited[key] or 0) then
                patrol[#patrol+1]={pos=n.position,key=key,score=math.sqrt(D2(pos,n.position))}
            end
        end
    end
    patrol=Selection.Top(patrol,12,function(a,b) return a.score==b.score and a.key<b.key or a.score>b.score end)
    for i=1,math.min(12,#patrol) do
        local c=patrol[((i+p.id-2)%math.max(1,math.min(12,#patrol)))+1]
        if Wet(c.pos) and Intel.EnemyThreat(p.army,c.pos,Layers(p),12,32)<=math.max(1,own)*1.1 then
            Visit(op,c.key)
            return {pos=Copy(c.pos),kind="patrol"}
        end
    end
end
local function ProgressLeg(pos,path)
    local prefix={};local previous=pos;local remaining=128
    for _,node in ipairs(path) do
        local distance=math.sqrt(D2(previous,node))
        if distance>0.01 then
            if distance>remaining then
                local fraction=remaining/distance
                prefix[#prefix+1]={x=previous.x+(node.x-previous.x)*fraction,
                    y=(previous.y or 0)+((node.y or 0)-(previous.y or 0))*fraction,z=previous.z+(node.z-previous.z)*fraction}
                break
            end
            prefix[#prefix+1]=Copy(node);remaining=remaining-distance
            if remaining<1 or #prefix>=64 then break end
        end
        previous=node
    end
    return #prefix>0 and D2(pos,prefix[#prefix])>8^2 and prefix or nil
end
local function CheckedPath(p,pos,path,layer,maximum,request)
    path=Movement.CopyPath(path)
    if #path==0 then return nil,"invalid-path" end
    if not p.ai.rushAmphibiousNaval then return path,false end
    local safe,reason=Movement.PathThreatSafe(p,pos,path,layer,maximum,request)
    if safe then return path,false end
    if reason=="heat-budget" then
        local prefix=ProgressLeg(pos,path)
        if prefix and PositionAllowed(p,prefix[#prefix]) then
            safe,reason=Movement.PathThreatSafe(p,pos,prefix,layer,maximum,request)
            if safe then return prefix,true end
        end
    end
    return nil,reason
end
local function StartRoute(p,goal,pos,own)
    local army,ai=p.army,p.ai;local state,op=State(army),ai.rushFleet
    local armyAI=army.ai;local maxThreat=math.max(1,own*1.2)
    pos=Copy(pos)
    if not PositionAllowed(p,goal.pos) then Reject(op,goal.pos);return false end
    local layer=ai.movementLayer
    local waterFallback=op.pendingWater==goal and layer=="Hover" and Wet(pos) and Wet(goal.pos)
        and Graph(pos,"Water") and Graph(pos,"Water")==Graph(goal.pos,"Water")
    if not waterFallback then op.pendingWater=nil end
    local function current() return Live(p) and p.army==army and army.ai==armyAI and p.ai==ai
        and ai.rushFleet==op and ai.movementLayer==layer end
    if goal.kind=="retreat" and ai.rushAmphibiousNaval then
        -- An escape starts inside existing danger. Never reject every escape
        -- because its very first native heat cell already exceeds own strength.
        for _,heatLayer in ipairs({layer,"Water"}) do
            local ok,value=pcall(TM.GetThreatFromHeatMapPosition,army.id,pos,heatLayer)
            if ok and type(value)=="number" and value>=0 and value<math.huge then maxThreat=math.max(maxThreat,value) end
        end
    end
    if not Budget.Acquire(p) then op.pendingRoute=goal;return nil end
    local request=Movement.Capture(p)
    if not request then return false,"stale-request" end
    op.pendingRoute,op.pendingWater=nil,nil;state.paths=state.paths+1
    local path=MG.GeneratePathTo(army.id,pos,goal.pos,waterFallback and "Water" or layer,true,maxThreat)
    if not current() then return false,"stale-request" end
    if type(path)~="table" or #path==0 then Reject(op,goal.pos);return false end
    if waterFallback then
        for _,node in ipairs(path) do
            if Graph(node,layer)~=op.graph then Reject(op,goal.pos);return false end
        end
    end
    if goal.unit and (not Intel.Visible(army,goal.unit) or TargetRange(p,goal.unit)<=0) then return false end
    if goal.kind~="retreat" then
        local surface=Surface(p,goal.pos)
        local present=goal.unit and TargetStrength(p,goal.unit) or Intel.Geometry(p,surface,Units(p)).own
        local support=Support(p,goal.pos,surface)
        if Intel.EnemyThreat(army,goal.pos,Layers(p),12,32)>math.max(1,present+support)*1.2 then return false end
    end
    path=MG.StraightenPath(Movement.CopyPath(path))
    if not current() then return false,"stale-request" end
    path=Movement.ShortenPath(p,pos,path,layer,maxThreat,request)
    if not current() then return false,"stale-request" end
    local acceptedPath,continuation=CheckedPath(p,pos,path,layer,maxThreat,request)
    if not acceptedPath and continuation=="unsafe-threat" and not waterFallback and layer=="Hover" and Wet(pos) and Wet(goal.pos)
        and Graph(pos,"Water") and Graph(pos,"Water")==Graph(goal.pos,"Water") then
        -- Hover heat omits native torpedoes. Try one real water route when
        -- both ends share an ocean; never change the ship's native capability.
        if not Budget.Extra(p,1) then
            -- The next fair ticket pays for Water directly; do not rerun the
            -- known-unsafe Hover query forever while optional slots are busy.
            op.pendingRoute,op.pendingWater=goal,goal;return nil
        end
        state.paths=state.paths+1
        path=MG.GeneratePathTo(army.id,pos,goal.pos,"Water",true,maxThreat)
        if not current() then return false,"stale-request" end
        path=Movement.CopyPath(path)
        for _,node in ipairs(path) do
            if Graph(node,layer)~=op.graph then path={};break end
        end
        path=MG.StraightenPath(path)
        if not current() then return false,"stale-request" end
        path=Movement.ShortenPath(p,pos,path,layer,maxThreat,request)
        if not current() then return false,"stale-request" end
        acceptedPath,continuation=CheckedPath(p,pos,path,layer,maxThreat,request)
    end
    if not acceptedPath then
        if continuation=="unsafe-threat" or continuation=="invalid-path" then Reject(op,goal.pos) end
        return false,continuation
    end
    if not CompatibleFleet(p) then return false,"capability-changed" end
    if goal.unit and (not Intel.Visible(army,goal.unit) or TargetRange(p,goal.unit)<=0) then return false end
    path=acceptedPath
    local routeEnd=continuation and Copy(path[#path]) or Copy(goal.pos)
    local oldPath=ai.path;ai.path=path
    local accepted,reason=Movement.Begin(p,path,routeEnd,goal.kind=="retreat" and Tasks.MOVE or Tasks.ATTACKMOVE,request)
    if not accepted then
        if ai.path==path then ai.path=oldPath end
        return false,reason
    end
    local tracking=op.goal and goal.unit and op.goal.unit==goal.unit
    local length,previous=0,pos
    for _,node in ipairs(path) do length=length+math.sqrt(D2(previous,node));previous=node end
    op.goal,op.path,op.routeEnd,op.continueRoute=goal,path,routeEnd,continuation
    if not tracking then
        op.began,op.progressAt,op.position=Now(),Now(),Copy(pos)
        op.deadline=Now()+math.min(900,math.max(120,length*2+60))
    end
    op.nextAcquire=Now()
    ai.path=path;ai.primaryTargetAreaPos=goal.pos;ai.gatherPoint=routeEnd
    ai.rushMovementThreat=maxThreat;ai.pathUsesAggressiveMove=goal.kind~="retreat"
    ai.withdraw=goal.kind=="retreat";ai.eState=ai.withdraw and "Withdraw" or "MoveToTargetArea"
    return true
end
local function Stop(p,hooks)
    local army,ai=p.army,p.ai;local armyAI,op=p.army.ai,p.ai.rushFleet
    local function current() return Live(p) and p.army==army and army.ai==armyAI and p.ai==ai and ai.rushFleet==op end
    for _,u in ipairs(Units(p)) do
        if not current() then return false end
        if Movement.Suspended(u) then Movement.Forget(u,true)
        else
            local unitAI=u.ai
            Movement.Forget(u,false)
            -- Tactical handoffs clear normal orders, never a mobile factory's
            -- paid production queue (which HostClearOrder would also cancel).
            Orders.ClearOrdersForUnit(u)
            if current() and Own(p,u) and u.ai==unitAI then
                if hooks.Reset then hooks.Reset(u,"RushFleetHandoff") end
                if current() and Own(p,u) and u.ai and u.ai==unitAI then
                    u.ai.eState="PlatoonControlled"
                    WatchMicroOrders(p,u)
                end
            end
        end
    end
    return current()
end
local function Release(p,hooks,delay)
    local op=p.ai.rushFleet
    local withdrawing=p.ai.withdraw and Now()<(op.retreatUntil or 0)
    if not Stop(p,hooks) then return false end
    Budget.Cancel(p)
    op.goal,op.path,op.microTarget,op.microSince,op.sent,op.pendingRoute=nil,nil,nil,nil,nil,nil
    op.routeEnd,op.continueRoute,op.pendingWater=nil,nil,nil
    op.nextAcquire=Now()+(delay or 0)
    p.ai.path,p.ai.primaryTargetAreaPos,p.ai.microTarget,p.ai.withdraw=false,false,false,withdrawing
    if withdrawing then p.ai.eState="Withdraw" end
    return true
end
local function EndEncounter(p,hooks)
    local ai,op=p.ai,p.ai.rushFleet
    local army,armyAI=p.army,p.army.ai
    if not op.microSince then return end
    if not Stop(p,hooks) then return end
    local elapsed=Now()-op.microSince
    if op.deadline then op.deadline=op.deadline+elapsed end
    op.progressAt,op.position=Now(),Copy(p:GetPosition())
    op.microTarget,op.microSince=nil,nil
    ai.microTarget=false
    if op.path and op.goal then
        local request=Movement.Capture(p)
        local suffix=Movement.Suffix(op.position,op.path,p,ai.movementLayer,ai.rushMovementThreat or 0,request)
        local straight=suffix and MG.StraightenPath(suffix)
        if not Live(p) or p.army~=army or army.ai~=armyAI or p.ai~=ai or ai.rushFleet~=op then return end
        if op.goal.unit and (not Intel.Visible(army,op.goal.unit) or TargetRange(p,op.goal.unit)<=0) then
            Release(p,hooks,0);return
        end
        if straight and ai.rushAmphibiousNaval then
            local safe=Movement.PathThreatSafe(p,op.position,straight,ai.movementLayer,ai.rushMovementThreat or 0,request)
            if not safe then straight=nil end
        end
        if straight and CompatibleFleet(p) then
            if not Movement.Begin(p,straight,op.routeEnd or op.goal.pos,
                op.goal.kind=="retreat" and Tasks.MOVE or Tasks.ATTACKMOVE,request) then
                op.pendingRoute=op.goal
            end
        else op.pendingRoute=op.goal end
    end
end
local function CompleteRoute(p)
    local op=p.ai.rushFleet
    Budget.Cancel(p)
    local continuation=op.continueRoute and op.goal or nil
    op.goal,op.path,op.pendingRoute=nil,nil,continuation
    op.routeEnd,op.continueRoute,op.pendingWater=nil,nil,nil
    op.nextAcquire=Now()
    p.ai.primaryTargetAreaPos=false
    -- The final native leg can finish while the next safe route is chosen.
end

local function EncounterTarget(p,pos,range,g)
    local op=p.ai.rushFleet;local radius=math.max(40,g.radius+range+12)
    local units=Units(p);local candidates={}
    for _,u in ipairs(Intel.EnemiesInRadius(p.army,pos,radius,true)) do
        if not u:HasTags(Tags.AIR) then
            local targetPos=Copy(u:GetPosition())
            local score=math.sqrt(D2(pos,targetPos))-(u==op.microTarget and 16 or 0)
            candidates[#candidates+1]={unit=u,pos=targetPos,score=score}
        end
    end
    local function less(a,b) return a.score==b.score and a.unit.id.index<b.unit.id.index or a.score<b.score end
    local count=#candidates;local offset=count>0 and (op.encounterOffset or 0)%count or 0
    if offset==0 then candidates=Selection.Top(candidates,12,less) else table.sort(candidates,less) end
    for index=1,math.min(12,count) do
        local c=candidates[(offset+index-1)%count+1]
        local reach,minimum=TargetRange(p,c.unit,units)
        if reach>0 then
            local inRange=false
            for _,u in ipairs(units) do
                if not Movement.Suspended(u) then
                    for _,weapon in ipairs(u.weapons or {}) do
                        if weapon.enabled and not weapon.isDeathExplosion and weapon:CanShootAt(c.unit)
                            and weapon:IsTargetInRange(c.unit) then inRange=true;break end
                    end
                end
                if inRange then break end
            end
            if inRange then op.encounterOffset=0;return c.unit end
            local firing=Approach(p,pos,c.pos,reach,TargetStrength(p,c.unit,units),minimum)
            if firing and (not Blocked(op,firing) or Intel.InWeaponRange(g,c.unit)) then
                op.encounterOffset=0;return c.unit
            end
        end
    end
    op.encounterOffset=count>0 and (offset+12)%count or 0
end
local function Retreat(p,pos,own,exposure,hooks)
    local op=p.ai.rushFleet;local center=exposure.center;local home=op.home
    local dx,dz=center and pos.x-center.x or home.x-pos.x,center and pos.z-center.z or home.z-pos.z
    local d=math.sqrt(dx*dx+dz*dz);if d<1 then dx,dz,d=1,0,1 end
    local best,bestScore
    local function consider(to)
        if D2(pos,to)>18^2 and PositionAllowed(p,to) and Intel.ClearRendezvous(p.army,to,4) then
            local threat=Intel.EnemyThreat(p.army,to,Layers(p),12,32)
            local score=threat*32+math.sqrt(D2(to,home))*0.15+math.sqrt(D2(to,pos))*0.05
            if (not bestScore or score<bestScore) and threat<math.max(1,exposure.total) then best,bestScore=Copy(to),score end
        end
    end
    consider(home)
    for _,angle in ipairs({0,0.70,-0.70,1.40,-1.40,math.pi}) do
        local c,s=math.cos(angle),math.sin(angle)
        consider(Copy(AF.GetPositionWithinPlayableArea({x=pos.x+(dx*c-dz*s)/d*72,y=pos.y,z=pos.z+(dx*s+dz*c)/d*72})))
    end
    if not Release(p,hooks,2) then return end
    op.retreatUntil,op.nextRetreat=Now()+24,Now()+2;p.ai.withdraw=true
    if best then StartRoute(p,{pos=best,kind="retreat"},pos,math.max(own,exposure.total)) end
end
local function Refill(p,g,hooks,now)
    local army,ai=p.army,p.ai;local armyAI,op=army.ai,ai.rushFleet
    local former=ai.formerTable;local need=former.NeedUnits and former.NeedUnits[1]
    if not ai.rushAmphibiousNaval or former.RushHeavyCombat or ai.withdraw
        or now<(op.nextRefill or 0) or not need or army.ai.bases[ai.baseName]~=op.sourceBase then return false end
    op.nextRefill=now+5
    local assigned=0
    for _,u in ipairs(p:GetUnits()) do
        if u and u.id and not u.dead and not u.deleted and u.army==army and u.platoon==p
            and army.units[u.id.index]==u then assigned=assigned+1 end
    end
    local room=math.min(need[3] or 8,16)-assigned
    if room<=0 then return false end
    local candidates={}
    for _,u in ipairs(Intel.FriendlyUnitsInRadius(army,g.position,48)) do
        if Available(army,u) and u:HasTags(need[1]) and IsAmphibiousNaval(u)
            and Compatible(u,ai.movementLayer,false) and Graph(u:GetPosition(),ai.movementLayer)==op.graph
            and (not u.assignedToBase or u.assignedToBase==ai.baseName) then candidates[#candidates+1]=u end
    end
    local take=math.min(room,2,math.max(0,#candidates-math.max(0,need[4] or 0)))
    if take<1 then return false end
    local additions={}
    for i=1,take do additions[i]=candidates[i] end
    p:AssignUnits(additions)
    local function current() return Live(p) and p.army==army and army.ai==armyAI and p.ai==ai and ai.rushFleet==op end
    for _,u in ipairs(additions) do
        if not current() then return false end
        if Own(p,u) then
            if hooks.Reset then hooks.Reset(u,"RushFleetRefill") end
            if not current() then return false end
            if Own(p,u) then
                u.ai=u.ai or {};u.ai.eState="PlatoonControlled";WatchMicroOrders(p,u)
                if op.path and op.goal and not op.microSince then
                    Movement.Resume(u,p,op.routeEnd or op.goal.pos)
                    if not current() then return false end
                end
            end
        end
    end
    return current()
end
function Tick(p,hooks)
    if not Live(p) or #Units(p)==0 then return false end
    local army,ai=p.army,p.ai;local op=ai.rushFleet
    local armyAI=army.ai
    local function current() return Live(p) and p.army==army and army.ai==armyAI and p.ai==ai and ai.rushFleet==op end
    local units=Units(p);RefreshThreatLayers(p,units)
    local now=Now();local pos,own,range,g=Geometry(p);ai.rushGeometry=g
    if g.count==0 then Budget.Cancel(p);return true end
    if Refill(p,g,hooks,now) then
        if not current() then return false end
        units=Units(p);RefreshThreatLayers(p,units);pos,own,range,g=Geometry(p);ai.rushGeometry=g
    end
    if not current() then return false end
    for _,u in ipairs(units) do
        if not Compatible(u,ai.movementLayer,ai.formerTable.RushHeavyCombat) then return false end
    end
    local exposure=Intel.Exposure(army,pos,Layers(p),g.radius+6)
    local enemy=exposure.total
    local friendly=Support(p,pos,ai.rushSurfaceLayer)
    local effective=math.max(1,own+friendly)
    ai.threat,ai.closeEnemyThreat,ai.nearbyFriendlyThreat=g.nominal,enemy,friendly
    local withdrawing=(op.goal and op.goal.kind=="retreat")
        or (op.pendingRoute and op.pendingRoute.kind=="retreat")
        or now<(op.retreatUntil or 0) and ai.withdraw
    if (not withdrawing and (enemy>effective*1.8 or op.microSince and enemy>effective*1.5))
        or withdrawing and not op.path and not op.pendingRoute and now>=(op.nextRetreat or 0) and enemy>effective*0.6 then
        Retreat(p,pos,own,exposure,hooks)
        if not current() then return false end
        withdrawing=true
    end
    if op.pendingRoute and not op.microSince then
        local pending=op.pendingRoute
        if pending.unit and not Intel.Visible(army,pending.unit) then Release(p,hooks,0)
        else
            local result,reason=StartRoute(p,pending,pos,pending.kind=="retreat" and math.max(own,enemy) or own)
            if not current() then return false end
            if result==false and reason~="stale-request" then Release(p,hooks,2) end
        end
    end
    if op.goal and op.goal.unit and not Intel.Visible(army,op.goal.unit) then Release(p,hooks,0) end
    if not current() then return false end
    if not withdrawing then
        local target=EncounterTarget(p,pos,range,g)
        if target and enemy<=effective*(op.microSince and 1.5 or 1.2) then
            if not op.microSince then
                if not Stop(p,hooks) then return false end
                Budget.Cancel(p);op.microSince=now
            end
            local health=target:GetHealth()
            for _,shield in ipairs(target.shields or {}) do
                if shield:IsEnabled() then health=health+math.max(0,shield:GetHealth()) end
            end
            local distance=math.sqrt(D2(pos,target:GetPosition()))
            if target~=op.microTarget then
                op.microTarget,op.microHealth,op.microDistance,op.microProgressAt=target,health,distance,now
            elseif health<op.microHealth-1 or distance<op.microDistance-4 then
                op.microHealth,op.microDistance,op.microProgressAt=math.min(health,op.microHealth),math.min(distance,op.microDistance),now
            end
            if now-(op.microProgressAt or now)<60 then
                ai.microTarget,ai.withdraw,ai.eState=target,false,"MicroingPlatoon"
                local state=hooks.Micro(p)
                if not current() then return false end
                if state=="WithdrawInit" then Retreat(p,pos,own,exposure,hooks)
                elseif state=="SelectMainTarget" then EndEncounter(p,hooks) end
                return current()
            end
            Reject(op,target:GetPosition())
            if op.goal and op.goal.unit==target then Release(p,hooks,2) else EndEncounter(p,hooks) end
        else EndEncounter(p,hooks) end
    end
    if not current() then return false end
    -- EndEncounter can yield while reconnecting the fleet. Revalidate target
    -- ownership, visibility and layer before any live position read afterward.
    if op.goal and op.goal.unit and (not Intel.Visible(army,op.goal.unit) or TargetRange(p,op.goal.unit)<=0) then
        Release(p,hooks,0)
    end
    if not current() then return false end
    if op.goal and op.goal.unit and now>=(op.nextTrack or 0) then
        local target=op.goal.unit;local targetPos=Copy(target:GetPosition())
        if D2(op.goal.targetPos or op.goal.pos,targetPos)>32^2 then
            op.nextTrack=now+8
            local reach,minimum=TargetRange(p,target)
            local destination=reach>0 and Approach(p,pos,targetPos,reach,TargetStrength(p,target),minimum)
            local support=destination and Support(p,destination,Surface(p,destination)) or 0
            if destination and Intel.EnemyThreat(army,destination,Layers(p),12,32)<=math.max(1,TargetStrength(p,target)+support)*1.2 then
                local moved,reason=StartRoute(p,{pos=destination,unit=target,targetPos=Copy(targetPos),kind="attack"},pos,own)
                if not current() then return false end
                if moved==false and reason~="stale-request" then Release(p,hooks,2) end
            else Release(p,hooks,2) end
        end
    end
    if op.goal and (now>=(op.deadline or math.huge)
        or op.goal.kind=="retreat" and now>=(op.retreatUntil or 0)) then
        if op.goal.kind~="retreat" then Reject(op,op.goal.pos) end
        Release(p,hooks,2)
    end
    if not current() then return false end
    if op.path then
        if D2(pos,op.position)>8^2 then op.position=Copy(pos);op.progressAt=now end
        if now-op.progressAt>30 then
            Reject(op,op.goal.pos);Release(p,hooks,2)
        else
            Movement.Maintain(p)
            local units=Units(p);local reached=0
            for _,u in ipairs(units) do
                Movement.RecoverOrderless(u,p,op.routeEnd or op.goal.pos)
                if not current() then return false end
                if Own(p,u) and D2(u:GetPosition(),op.routeEnd or op.goal.pos)<18^2 then reached=reached+1 end
            end
            if reached>=math.max(1,math.ceil(#units*0.6)) then CompleteRoute(p) end
        end
    end
    if not current() then return false end
    if not op.path and not op.pendingRoute and now>=(op.nextAcquire or 0) then
        if now<(op.retreatUntil or 0) and enemy>effective*0.6 then ai.withdraw=true;ai.eState="Withdraw"
        else
            ai.withdraw=false;op.nextAcquire=now+6
            local goal=SelectGoal(p,pos,own,range)
            if goal then StartRoute(p,goal,pos,own) end
            if not current() then return false end
            if not op.path then ai.eState="SelectMainTarget" end
        end
    end
    if now>=(op.nextLog or 0) then
        op.nextLog=now+60
        Log("[RushFleet] army="..army.id.." platoon="..p.id.." units="..#Units(p).." state="..tostring(ai.eState)
            .." goal="..tostring(op.goal and op.goal.kind).." paths="..State(army).paths,true)
    end
    return true
end
function Run(p,index,baseName,former,hooks)
    local army=p.army;local base=army.ai.bases[baseName]
    local armyAI,initialAI=army.ai,p.ai
    if not base then hooks.Exit(p);return end
    local units,minimum,maximum,reserve,graph,layer=GetUnits(index,baseName,former)
    if p.army~=army or army.ai~=armyAI or p.ai~=initialAI then return end
    if not Live(p) or army.ai.bases[baseName]~=base then hooks.Exit(p);return end
    local selected={};local available=0
    for _,u in ipairs(units or {}) do
        if Available(army,u,former.RushHeavyCombat) and Graph(u:GetPosition(),layer)==graph
            and Compatible(u,layer,former.RushHeavyCombat) then
            available=available+1
            if #selected<math.min(maximum or 16,16) then selected[#selected+1]=u end
        end
    end
    local limit=math.max(0,available-math.max(0,reserve or 0))
    while #selected>limit do selected[#selected]=nil end
    if #selected<math.max(1,minimum or 1) then hooks.Exit(p);return end
    p:AssignUnits(selected)
    for _,u in ipairs(selected) do if hooks.Reset then hooks.Reset(u,"RushFleet") end;u.ai=u.ai or {};u.ai.eState="PlatoonControlled" end
    p.ai={formerTable=former,baseName=baseName,basePosition=Copy(selected[1]:GetPosition()),baseRadius=base.radius,
        movementLayer=layer,targetLayer="WaterSurface",isNavalPlatoon=true,waterGraphArea=layer=="Water" and graph or nil,
        rushAmphibiousNaval=layer=="Hover" or layer=="Seabed",rushSurfaceLayer="WaterSurface",
        eState="SelectMainTarget",creationTime=GetFormatedGameTime(),
        rushFleet={home=Copy(selected[1]:GetPosition()),sourceBase=base,graph=graph,blocked={},visited={},nextAcquire=Now(),nextLog=Now()}}
    for _,u in ipairs(selected) do if Own(p,u) and u.ai then WatchMicroOrders(p,u) end end
    p:SetUniqueName("RushFleet-"..p.id)
    State(army).operations[p.id]=p
    local ai,operation=p.ai,p.ai.rushFleet
    local function current() return p.army==army and army.ai==armyAI and p.ai==ai and ai.rushFleet==operation end
    while current() and Tick(p,hooks) do
        local nextSense=Now()+1
        repeat
            local moving=operation.path and not operation.microSince
            WaitTicks(math.max(1,math.floor(((Constants and Constants.TickRate) or 10)
                *math.min(nextSense-Now(),moving and 0.2 or 1)+0.5)))
            if current() and Live(p) and not operation.microSince then Movement.Maintain(p) end
        until not current() or not Live(p) or Now()>=nextSense
    end
    if army.ai~=armyAI then return end
    local state=State(army)
    if state.operations[p.id]==p and (p.ai==ai or not Live(p) or not p.ai or not p.ai.rushFleet) then
        state.operations[p.id]=nil
    end
    if current() then Budget.Cancel(p);hooks.Exit(p) end
end
