-- Per-base industrial districts with varied shapes, sizes and open factory exits.
-- Layout preferences never replace the engine's build/grid/terrain validators.
Version = "9.0.25-rc30"
local AF = Import("AI/AIFunctions.lua")
local MG = Import("AI/AIMarkerGenerator.lua")
local TM = Import("AI/AITargetManager.lua")
local R = Import("AI/mods/AI-Scom/RushReliability.lua")
local Profiles = Import("AI/mods/AI-Scom/RushLayoutProfile.lua")
local EconomyPolicy = Import("AI/mods/AI-Scom/RushEconomyPolicy.lua")
local Rules = Import("AI/mods/AI-Scom/RushBalance.lua")
local HeavyPolicy = Import("AI/mods/AI-Scom/RushHeavyPolicy.lua")
local Intel = Import("AI/mods/AI-Scom/RushCombatIntel.lua")
local Frontline = Import("AI/mods/AI-Scom/RushFrontline.lua")
local Movement = Import("AI/mods/AI-Scom/RushMovement.lua")
local Pressure = Import("AI/mods/AI-Scom/RushPressure.lua")
local Log = Import("AI/debugUtilities.lua").AILog
local installed = false
local IsRush
local EmergencyShieldView
local FACTORY_OFFSETS = {{4,0},{-4,0},{0,4},{0,-4}}
local EXIT_PROBES = {2,6,10}
local function Has(tp,tag)
    if type(tp)~="table" then return false end
    if type(tp.hasTags)=="table" and tp.hasTags[tag] then return true end
    for _,value in ipairs(type(tp.tags)=="table" and tp.tags or {}) do
        if value==tag then return true end
    end
    return false
end
local function D2(a,b) return (a.x-b.x)^2+(a.z-b.z)^2 end
local function InRange(p,center,radius)
    local distance=D2(p,center)
    -- Expansion callers reject a center on the exact 30-unit boundary.
    return distance<radius^2 or (radius==0 and distance==0)
end
local function Finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function Position(p)
    local kind=type(p)
    return (kind=="table" or kind=="userdata") and Finite(p.x) and Finite(p.z)
end
local function Template(id)
    return type(__Templates)=="table" and type(__Templates.Units)=="table" and __Templates.Units[id]
end
local function Table(value) return type(value)=="table" and value or {} end
local function Own(army,u) return type(u)=="table" and R.Own(army,u) end
local function ProfileForBase(army,name,base)
    local profile=base.rushLayoutProfile
    if type(profile)~="table" or profile.version~=Profiles.Version
        or not Position(profile.home) or profile.home.x~=base.position.x or profile.home.z~=base.position.z then
        profile=Profiles.Create(army.id,army.faction,name,base.position,AF.GetPlayableArea())
        base.rushLayoutProfile=profile
        Log(("[RushLayout] army=%s base=%s style=%s seed=%d scale=%.2f width=%.2f depth=%.2f radiusScale=%.2f")
            :format(tostring(army.id),tostring(name),profile.name,profile.seed,profile.scale,
                profile.width,profile.depth,profile.radiusScale),true)
    end
    return profile
end
function GetProfile(army,center)
    if not army or not Position(center) then return nil end
    local best,name,distance
    for key,base in pairs(Table(army.ai and army.ai.bases)) do
        if type(base)=="table" and Position(base.position) then
            local d=D2(center,base.position)
            if d<=24^2 and (not best or d<distance or (d==distance and tostring(key)<tostring(name))) then
                best,name,distance=base,key,d
            end
        end
    end
    if best then return ProfileForBase(army,name,best),best end
    -- New expansion markers and recovery sites must not inherit the main base's
    -- grid. Unregistered positions are reproducible without accumulating a cache.
    local name="site:"..math.floor(center.x*2)..":"..math.floor(center.z*2)
    return Profiles.Create(army.id,army.faction,name,center,AF.GetPlayableArea())
end
function ResizeBase(army,name,base)
    if type(base)~="table" or not Position(base.position) or not Finite(base.radius) or base.radius<=0 then return end
    local profile=ProfileForBase(army,name,base)
    local native=base.radius
    -- BaseRanger may run again when expansions change. Never repeatedly enlarge
    -- a previously adjusted radius when the native ranger left it unchanged.
    if Finite(base.rushLayoutAppliedRadius) and math.abs(native-base.rushLayoutAppliedRadius)<0.00001
        and Finite(base.rushLayoutNativeRadius) then native=base.rushLayoutNativeRadius end
    base.rushLayoutNativeRadius=native
    base.radius=native*profile.radiusScale
    base.rushLayoutAppliedRadius=base.radius
end
local function Round(v,span)
    -- Match GetPlacementBounds: even skirts have integer centers, odd skirts
    -- half-integer centers. Never round an already valid center a second time.
    local half=span/2
    return math.floor(v-half+0.5)+half
end
local function IsFactory(tp)
    return Has(tp,"STRUCTURE") and Has(tp,"FACTORY") and not Has(tp,"NAVAL_FACTORY")
end
local function IsHiveFactory(tp)
    return Has(tp,"STRUCTURE") and Has(tp,"FACTORY")
        and (Has(tp,"LAND_FACTORY") or Has(tp,"AIR_FACTORY") or Has(tp,"NAVAL_FACTORY"))
end
local function IsEnergyProducer(tp)
    return Has(tp,"STRUCTURE") and Has(tp,"ENERGY_PRODUCTION")
        and not Has(tp,"ALLOYS_EXTRACTION")
end
local function IsGenerator(tp) return IsEnergyProducer(tp) and not Has(tp,"HYDROCARBON") end
local function IsPower(tp) return IsGenerator(tp) and Has(tp,"TECH1") end
local function IsMassStorage(tp)
    return Has(tp,"STRUCTURE") and Has(tp,"ALLOYS_STORAGE") and Has(tp,"TECH1")
        and not Has(tp,"FACTORY")
end
local function IsEnergyStorage(tp)
    return Has(tp,"STRUCTURE") and Has(tp,"ENERGY_STORAGE") and Has(tp,"TECH1")
        and not Has(tp,"FACTORY")
end
local function IsExtractor(tp)
    return Has(tp,"STRUCTURE") and Has(tp,"ALLOYS_EXTRACTION")
end
local function IsMassFabricator(tp)
    return Has(tp,"STRUCTURE") and (Has(tp,"ALLOYS_PRODUCTION") or Has(tp,"SCFA_MASSFABRICATION"))
        and not Has(tp,"ALLOYS_EXTRACTION")
end
local function IsBuilderStructure(tp)
    return IsFactory(tp) or Has(tp,"ENGINEERING_STATION") or Has(tp,"SCFA_ENGINEERSTATION")
end
local function UsesPower(tp)
    local economy=type(tp)=="table" and tp.economy
    local maintenance=type(economy)=="table" and economy.maintenanceConsumption
    return IsBuilderStructure(tp) or IsMassFabricator(tp)
        or (type(maintenance)=="table" and (tonumber(maintenance.energy) or 0)>0)
end
local function Tier(tp)
    return Has(tp,"TECH4") and 4 or Has(tp,"TECH3") and 3 or Has(tp,"TECH2") and 2 or 1
end
local function Overlap(a,ax,az,b,bx,bz,gap)
    return math.abs(a.x-b.x)<(ax+bx)/2+gap-0.001
        and math.abs(a.z-b.z)<(az+bz)/2+gap-0.001
end
local storageShapes={templates=nil,values={}}
local function StorageShape(army,kind)
    local templates=__Templates and __Templates.Units
    if storageShapes.templates~=templates then storageShapes={templates=templates,values={}} end
    local factions={"EDA","CHOSEN","GUARD","SERAPHIM"}
    local faction=factions[army.faction] or army.factionTag
    local key=tostring(faction)..":"..kind;local cached=storageShapes.values[key]
    local now=GetGameTimeSeconds()
    if cached and cached.id==false and now>=cached.at and now<cached.expires then return nil end
    if cached and cached.id and R.AllowedTarget(cached.id,false) then return cached.footprint end
    local best
    for id,tp in pairs(templates or {}) do
        if Has(tp,"SCFA_STRUCTURE") and Has(tp,faction)
            and (kind=="mass" and IsMassStorage(tp) or kind=="energy" and IsEnergyStorage(tp))
            and R.AllowedTarget(id,false) then
            local f=R.Footprint(tp)
            if f and (not best or f.x*f.y<best.footprint.x*best.footprint.y
                or f.x*f.y==best.footprint.x*best.footprint.y and id<best.id) then best={id=id,footprint=f} end
        end
    end
    storageShapes.values[key]=best or {id=false,at=now,expires=now+5}
    return best and best.footprint
end
local function IsProtection(tp)
    return Has(tp,"STRUCTURE") and (Has(tp,"SHIELD")
        or Has(tp,"DEFENCE") and (Has(tp,"DIRECT_FIRE") or Has(tp,"ANTI_AIR")))
end
local function BeachheadOperation(army)
    local operation=army.ai and army.ai.rushBeachhead and army.ai.rushBeachhead.operation
    local p=operation and operation.platoon
    local b=operation and operation.builder
    local site=operation and operation.site
    if not operation or operation.armyAI~=army.ai or not p or p.dead or p.deleted
        or not army:PlatoonExists(p) or p.ai~=operation.platoonAI or not Own(army,b)
        or b.platoon~=p or b.ai~=operation.builderAI or not site or site.armyAI~=army.ai
        or not Position(site.factoryPosition) or not Template(site.factoryId) then return nil end
    return operation
end
local function BeachheadLanes(site)
    local f=R.Footprint(Template(site.factoryId));local result={}
    if not f or not Position(site.factoryPosition) then return result end
    local center=site.factoryPosition
    for _,goal in ipairs({site.landGoal,site.shore}) do
        if Position(goal) then
            local dx,dz=goal.x-center.x,goal.z-center.z
            local distance=math.sqrt(dx*dx+dz*dz)
            if distance>1 then
                local nx,nz=dx/distance,dz/distance
                local edge=math.abs(nx)*f.x/2+math.abs(nz)*f.y/2+2
                if distance>edge+3 then
                    result[#result+1]={start={x=center.x+nx*edge,z=center.z+nz*edge},
                        nx=nx,nz=nz,length=math.min(64,distance-edge),half=5}
                end
            end
        end
    end
    return result
end
local function BlocksBeachheadLane(pos,f,lanes)
    for _,lane in ipairs(lanes or {}) do
        local dx,dz=pos.x-lane.start.x,pos.z-lane.start.z
        local along=dx*lane.nx+dz*lane.nz
        local cross=math.abs(dx*lane.nz-dz*lane.nx)
        local halfAlong=(math.abs(lane.nx)*f.x+math.abs(lane.nz)*f.y)/2
        local halfCross=(math.abs(lane.nz)*f.x+math.abs(lane.nx)*f.y)/2
        if along+halfAlong>0 and along-halfAlong<lane.length and cross<lane.half+halfCross then return true end
    end
    return false
end
local function Geometry(army,center,radius,avoid,footprint,gap,coverageBase,hiveRange,exceptPlatoon,ignoreBeachheadFactory)
    local structures,factories,mobiles,pending,exclusions,extractors,protectors={},{},{},{},{},{},{}
    local hiveFactories=hiveRange and {}
    local avoidList=type(avoid)=="table" and avoid or {}
    local reach=radius+math.sqrt(footprint.x^2+footprint.y^2)/2+math.max(1.5,gap)
    local function nearby(p,f)
        return Position(p) and D2(p,center)<=(reach+math.sqrt(f.x*f.x+f.y*f.y)/2)^2
    end
    for _,u in pairs(Table(army.units)) do
        if Own(army,u) and type(u.GetPosition)=="function" then
            local f=R.Footprint(u.tp)
            local p=f and u:GetPosition()
            if f and Position(p) then
                if Has(u.tp,"STRUCTURE") then
                    local q={pos=p,x=f.x,z=f.y,tp=u.tp,unit=u,id=u.tpId}
                    if nearby(p,f) or coverageBase and D2(p,coverageBase.position)<=coverageBase.radius^2 then
                        structures[#structures+1]=q
                    end
                    -- Authored exits may extend beyond a hub's footprint; retain
                    -- their complete geometry instead of guessing a search margin.
                    if IsFactory(u.tp) or hiveFactories and IsHiveFactory(u.tp) then factories[#factories+1]=q end
                    if hiveFactories and IsHiveFactory(u.tp) and u:IsCompleted()
                        and D2(p,center)<=(radius+hiveRange)^2
                        and type(u.GetConstructionSpawnPoint)=="function" then
                        -- Production can sit on an offset platform, especially
                        -- at shipyards. Use the host's actual build position.
                        local ok,work=pcall(u.GetConstructionSpawnPoint,u)
                        if ok and Position(work) then
                            q.workPos={x=work.x,y=work.y,z=work.z}
                            hiveFactories[#hiveFactories+1]=q
                        end
                    end
                    if Has(u.tp,"SCFA_STRUCTURE") and (IsExtractor(u.tp)
                        or IsGenerator(u.tp) and (Tier(u.tp)==2 or Tier(u.tp)==3)) then extractors[#extractors+1]=q end
                    if IsProtection(u.tp) then protectors[#protectors+1]=q end
                elseif nearby(p,f) and (Has(u.tp,"COMMAND") or Has(u.tp,"ENGINEER")) then
                    if not u.scoCommanderPodOwner and not u.scoSourcePodOwner then
                        mobiles[#mobiles+1]={pos=p,x=f.x,z=f.y,unit=u}
                    end
                end
            end
            for _,line in ipairs(avoidList) do
                if type(line)=="table" and type(line[1])=="table" and Finite(line[2])
                    and line[1][u.tpId] then
                    p=p or u:GetPosition()
                    if Position(p) and D2(p,center)<(radius+line[2])^2 then
                        exclusions[#exclusions+1]={pos=p,radiusSquared=line[2]^2}
                    end
                end
            end
            local w=Table(u.ai).rushRecoveryWork
            local tp=type(w)=="table" and Template(w.id)
            local wf=R.Footprint(tp)
            if wf and Position(w.position) and (nearby(w.position,wf) or IsFactory(tp)
                or hiveFactories and IsHiveFactory(tp) or IsProtection(tp)) then
                pending[#pending+1]={pos=w.position,x=wf.x,z=wf.y,tp=tp,id=w.id}
            end
        end
    end
    for _,p in pairs(Table(army.platoons)) do
        local a=type(p)=="table" and Table(p.ai)
        local tp=a and Template(a.nextBuildingtpId)
        local f=R.Footprint(tp)
        if p~=exceptPlatoon and a and not p.dead and not p.deleted and f and Position(a.placeToBuild)
            and (nearby(a.placeToBuild,f) or IsFactory(tp) or hiveFactories and IsHiveFactory(tp)
                or IsProtection(tp)) and Has(tp,"STRUCTURE") then
            pending[#pending+1]={pos=a.placeToBuild,x=f.x,z=f.y,tp=tp,
                id=a.nextBuildingtpId,platoon=p}
        end
        local claim=a and a.rushAdjacencyStorage
        local storage=claim and Template(claim.id)
        local sf=storage and R.Footprint(storage)
        if p~=exceptPlatoon and a and not p.dead and not p.deleted and sf and Position(claim.position)
            and claim.armyAI==army.ai and claim.platoonAI==a and Own(army,claim.builder)
            and claim.builder.ai==claim.builderAI and claim.builder.platoon==p
            and army.ai.bases[claim.baseName]==claim.baseRef and nearby(claim.position,sf) then
            pending[#pending+1]={pos=claim.position,x=sf.x,z=sf.y,tp=storage,id=claim.id,platoon=p}
        end
    end
    local beachhead=BeachheadOperation(army)
    local beachheadLanes={}
    if beachhead and not (ignoreBeachheadFactory and beachhead.platoon==exceptPlatoon) then
        local site=beachhead.site;local tp=Template(site.factoryId);local f=R.Footprint(tp)
        if f then
            pending[#pending+1]={pos=site.factoryPosition,x=f.x,z=f.y,tp=tp,id=site.factoryId,platoon=beachhead.platoon}
            beachheadLanes=BeachheadLanes(site)
        end
    end
    for name,record in pairs(army.ai.rushBeachhead and army.ai.rushBeachhead.bases or {}) do
        local base=army.ai.bases[name];local factory=record.factory;local site=record.site
        if record.armyAI==army.ai and base==record.baseRef and site and site.armyAI==army.ai
            and Own(army,factory) and factory:IsCompleted() and Has(factory.tp,"LAND_FACTORY")
            and factory.assignedToBase==name and Position(site.factoryPosition)
            and D2(factory:GetPosition(),site.factoryPosition)<1 then
            for _,lane in ipairs(BeachheadLanes(site)) do beachheadLanes[#beachheadLanes+1]=lane end
        end
    end
    table.sort(structures,function(a,b) return a.unit.id.index<b.unit.id.index end)
    table.sort(factories,function(a,b) return a.unit.id.index<b.unit.id.index end)
    if hiveFactories then table.sort(hiveFactories,function(a,b) return a.unit.id.index<b.unit.id.index end) end
    table.sort(pending,function(a,b)
        if a.pos.x~=b.pos.x then return a.pos.x<b.pos.x end
        if a.pos.z~=b.pos.z then return a.pos.z<b.pos.z end
        if a.x~=b.x then return a.x<b.x end
        return a.z<b.z
    end)
    local rings={}
    for _,q in ipairs(extractors) do
        if Has(q.tp,"SCFA_STRUCTURE") then
            local kind=IsExtractor(q.tp) and "mass" or "energy"
            local f=StorageShape(army,kind)
            if f then
                local x0,z0=math.floor(q.pos.x-q.x/2),math.floor(q.pos.z-q.z/2)
                for _,d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
                    local x=d[1]>0 and x0+q.x+f.x/2 or d[1]<0 and x0-f.x/2
                        or Round(q.pos.x,f.x)
                    local z=d[2]>0 and z0+q.z+f.y/2 or d[2]<0 and z0-f.y/2
                        or Round(q.pos.z,f.y)
                    local position={x=x,z=z}
                    if nearby(position,f) then rings[#rings+1]={pos=position,x=f.x,z=f.y,kind=kind} end
                end
            end
        end
    end
    return {army=army,coverageBase=coverageBase,exceptPlatoon=exceptPlatoon,structures=structures,factories=factories,mobiles=mobiles,pending=pending,beachheadLanes=beachheadLanes,
        exclusions=exclusions,rings=rings,protectors=protectors,hiveFactories=hiveFactories}
end
local function Avoid(p,geometry)
    for _,q in ipairs(geometry.exclusions) do
        if D2(p,q.pos)<=q.radiusSquared then return true end
    end
    return false
end
-- SCOM factories do not share one exit axis: Cybran/Seraphim may use
-- side ramps while UEF uses front/back roll-off points. Prefer authored ramps
-- over donor construction data, and rotate existing factories' local offsets.
local function Exits(factory)
    local tp=factory.tp or {}
    local additions=type(tp.additions)=="table" and tp.additions or {}
    local construction=type(tp.construction)=="table" and tp.construction or {}
    local ramps=type(additions.rollOffRamps)=="table" and additions.rollOffRamps
    local routes=ramps or (type(construction.rollOffPoints)=="table" and construction.rollOffPoints) or {}
    local exits,seen={},{}
    local function append(x,z)
        if not Finite(x) or not Finite(z) or x*x+z*z<0.1 then return end
        if factory.unit and type(factory.unit.GetOrientation)=="function"
            and Engine and type(Engine.QuaternionRotateVector)=="function" and EngineClasses and type(EngineClasses.float3)=="function" then
            local ok,result=pcall(Engine.QuaternionRotateVector,factory.unit:GetOrientation(),EngineClasses.float3(x,0,z))
            if ok and Position(result) then x,z=result.x,result.z end
        end
        local xAxis=math.abs(x)>math.abs(z)
        local direction=(xAxis and x or z)>0 and 1 or -1
        local key=(xAxis and "x" or "z")..direction
        if seen[key] then return end
        seen[key]=true
        local span=xAxis and factory.x or factory.z
        local transverse=xAxis and factory.z or factory.x
        local length=math.max(10,math.abs(xAxis and x or z)-span/2+4)
        local width=math.max(3,math.min(8,transverse*0.75))
        local cross=xAxis and z or x
        local ep={x=factory.pos.x,z=factory.pos.z}
        if xAxis then ep.x=ep.x+direction*(span/2+length/2);ep.z=ep.z+cross
        else ep.x=ep.x+cross;ep.z=ep.z+direction*(span/2+length/2) end
        exits[#exits+1]={pos=ep,x=xAxis and length or width,z=xAxis and width or length,
            xAxis=xAxis,direction=direction,cross=cross,edge=span/2,length=length}
    end
    for _,route in ipairs(routes) do
        local offset=type(route)=="table" and (route.clearanceOffset or route.rampOffset or route.offset)
        if type(offset)=="table" or type(offset)=="userdata" then append(offset.x or 0,offset.z or 0) end
    end
    if #exits==0 then append(0,factory.z/2+6);append(0,-factory.z/2-6) end
    return exits
end
function FactoryExits(tp,position,unit)
    local f=R.Footprint(tp)
    return f and Exits({tp=tp,pos=position,x=f.x,z=f.y,unit=unit}) or {}
end
local function ClearCandidate(army,tp,p,geometry,gap,avoid)
    local f=R.Footprint(tp)
    if not f or not Position(p) or not Finite(p.y) or not R.Inside(p,math.max(f.x,f.y)/2+0.5) or Avoid(p,geometry) then return false end
    if BlocksBeachheadLane(p,f,geometry.beachheadLanes) then return false end
    for _,s in ipairs(geometry.structures) do
        if Overlap(p,f.x,f.y,s.pos,s.x,s.z,gap) then return false end
    end
    for _,s in ipairs(geometry.pending) do
        if Overlap(p,f.x,f.y,s.pos,s.x,s.z,gap) then return false end
    end
    -- Reserve useful storage faces as industry grows. Power consumers may
    -- still share a generator edge; their native adjacency has value too.
    for _,slot in ipairs(geometry.rings) do
        local compatible=slot.kind=="mass" and IsMassStorage(tp)
            or slot.kind=="energy" and (IsEnergyStorage(tp) or UsesPower(tp))
        if not compatible and Overlap(p,f.x,f.y,slot.pos,slot.x,slot.z,0) then return false end
    end
    for _,m in ipairs(geometry.mobiles) do
        if Overlap(p,f.x,f.y,m.pos,m.x,m.z,m.clearance or 1.5) then return false end
    end
    for _,factory in ipairs(geometry.factories) do
        for _,exit in ipairs(factory.exits or Exits(factory)) do
            if Overlap(p,f.x,f.y,exit.pos,exit.x,exit.z,0.5) then return false end
        end
    end
    for _,factory in ipairs(geometry.pending) do
        if IsFactory(factory.tp) or geometry.hiveFactories and IsHiveFactory(factory.tp) then
            for _,exit in ipairs(factory.exits or Exits(factory)) do
                if Overlap(p,f.x,f.y,exit.pos,exit.x,exit.z,0.5) then return false end
            end
        end
    end
    if IsFactory(tp) then
        -- At least one clear, pathable production exit is required. Existing
        -- and queued structures are checked, not just terrain beneath the hub.
        local freeExit=false
        local candidate={pos=p,x=f.x,z=f.y,tp=tp}
        for _,exit in ipairs(Exits(candidate)) do
            local ep,ex,ez=exit.pos,exit.x,exit.z
            local clear=R.Inside(ep,math.max(ex,ez)/2+0.5)
            if clear then
                for _,s in ipairs(geometry.structures) do
                    if Overlap(ep,ex,ez,s.pos,s.x,s.z,0.5) then clear=false;break end
                end
            end
            if clear then
                for _,s in ipairs(geometry.pending) do
                    if Overlap(ep,ex,ez,s.pos,s.x,s.z,0.5) then clear=false;break end
                end
            end
            if clear then
                for _,step in ipairs(EXIT_PROBES) do
                    local probe={x=p.x,y=p.y,z=p.z}
                    if exit.xAxis then
                        probe.x=probe.x+exit.direction*(exit.edge+step);probe.z=probe.z+exit.cross
                    else
                        probe.z=probe.z+exit.direction*(exit.edge+step);probe.x=probe.x+exit.cross
                    end
                    if not MG.IsPathMapPathable(probe) then clear=false;break end
                    local _,height=Engine.SampleTerrainHeight(probe)
                    if not Finite(height) or math.abs(height-p.y)>1.5 then clear=false;break end
                end
            end
            if clear then freeExit=true;break end
        end
        if not freeExit then return false end
    end
    return true
end
local function BubbleProtection(shield,centered)
    local radii,offset=Table(shield and shield.radii),Table(shield and shield.offset)
    if not shield or shield.type~="Bubble" or not Finite(radii.x) or not Finite(radii.y)
        or not Finite(radii.z) or radii.x<=0 or radii.y<=0 or radii.z<=0 then return nil end
    return {radius=math.min(radii.x,radii.z),height=radii.y,
        x=centered and 0 or tonumber(offset.x) or 0,y=centered and 0 or tonumber(offset.y) or 0,
        z=centered and 0 or tonumber(offset.z) or 0}
end
local function Protection(tp,layer)
    if not tp then return nil end
    local result
    if Has(tp,"SHIELD") then
        for _,shield in ipairs(Table(Table(tp.defence).shields)) do
            local protection=BubbleProtection(shield)
            if protection and (not result or protection.radius>result.radius) then result=protection end
        end
    else
        layer=layer or (Has(tp,"ANTI_AIR") and "Air" or "Land")
        for _,weapon in ipairs(Table(tp.weapons)) do
            local matches=false
            for _,target in ipairs(Table(weapon.layerTargetLimits)) do
                if target==layer then matches=true;break end
            end
            local radius=tonumber(weapon.rangeMax) or 0
            if matches and (tonumber(weapon.damage) or 0)>0 and radius>0 and (not result or radius>result.radius) then
                result={radius=radius,x=0,z=0}
            end
        end
    end
    return result
end
local function Covers(p,protection,asset)
    if not protection then return false end
    local radius=protection.radius
    if protection.height then
        local vertical=((asset.pos.y or 0)-(p.y or 0)-(protection.y or 0))/protection.height
        if math.abs(vertical)>=1 then return false end
        radius=radius*math.sqrt(math.max(0,1-vertical*vertical))
    end
    radius=radius-asset.half
    return radius>0 and (p.x+protection.x-asset.pos.x)^2+(p.z+protection.z-asset.pos.z)^2<=radius^2
end
-- Completed shields use their native world-space bubble, including the bone
-- offset. Physical/queued coverage and functioning protection are separate:
-- a collapsed bubble permits one backup, never endless replacement buildings.
local function ShieldCoverage(record,asset)
    local u=record.unit
    if u then
        if not Own(record.army or u.army,u) then return false,false,false end
        if u:IsCompleted() then
            local present,working=false,false
            for _,shield in ipairs(u.shields or {}) do
                local protection=not shield.deleted and BubbleProtection(shield.tp,true)
                local p=protection and shield:GetPosition()
                if Position(p) and Covers(p,protection,asset) then
                    present=true
                    if shield:IsEnabled() and shield:GetHealth()>0 then working=true end
                end
            end
            return present,working,present
        end
        local entity=u.resourceEntities and u.resourceEntities.construction
        if u:IsPlacementGhost() and not u.hasBeenPromotedFromPlacementGhost
            and not (entity and next(entity.buildPowerSources or {})) then return false,false,false end
    end
    return Covers(record.pos,record.protection or Protection(record.tp),asset),false,false
end
local function PrepareProtection(tp,g)
    if not IsProtection(tp) then return end
    local layer=Has(tp,"ANTI_AIR") and "Air" or "Land"
    g.protection=Protection(tp,layer)
    if not g.protection then return end
    local main=g.army.ai and g.army.ai.bases and g.army.ai.bases.MAIN
    if Has(tp,"SHIELD") and (g.coverageBase==main or g.emergencyShield) then
        local emergency=EmergencyShieldView(g.army,Rules.CurrentSnapshot(g.army,false),g.exceptPlatoon)
        if emergency then
            g.assets=emergency.assets;g.needsCoverage=true
            return
        end
    end
    local protectors={}
    local function add(q)
        if Has(tp,"SHIELD") and Has(q.tp,"SHIELD")
            or not Has(tp,"SHIELD") and Has(q.tp,"DEFENCE")
                and (Has(tp,"ANTI_AIR") and Has(q.tp,"ANTI_AIR")
                    or not Has(tp,"ANTI_AIR") and Has(q.tp,"DIRECT_FIRE")) then
            protectors[#protectors+1]={pos=q.pos,protection=Protection(q.tp,layer),unit=q.unit,tp=q.tp,army=g.army}
        end
    end
    for _,q in ipairs(g.protectors) do add(q) end
    for _,q in ipairs(g.pending) do add(q) end
    g.assets={}
    for _,q in ipairs(g.structures) do
        if IsBuilderStructure(q.tp) or IsEnergyProducer(q.tp) or IsExtractor(q.tp)
            or IsMassFabricator(q.tp) or Has(q.tp,"SHIELD") or Has(q.tp,"ARTILLERY") then
            local cost=Table(Table(q.tp.economy).cost)
            local asset={pos=q.pos,half=math.sqrt(q.x*q.x+q.z*q.z)/2,
                value=1+math.sqrt(math.max(0,tonumber(cost.alloys) or 0))}
            local covered=false
            for _,protector in ipairs(protectors) do
                if Has(tp,"SHIELD") and ShieldCoverage(protector,asset)
                    or not Has(tp,"SHIELD") and Covers(protector.pos,protector.protection,asset) then
                    asset.value=asset.value*0.15;covered=true;break
                end
            end
            local important=IsFactory(q.tp) or Tier(q.tp)>=2
                and (IsEnergyProducer(q.tp) or IsExtractor(q.tp) or Has(q.tp,"ARTILLERY"))
            asset.uncovered=Has(tp,"SHIELD") and important and not covered
            if asset.uncovered then g.needsCoverage=true end
            g.assets[#g.assets+1]=asset
        end
    end
end
local function ProtectionValue(p,g)
    if not g.assets then return 0 end
    local score=0
    for _,asset in ipairs(g.assets) do
        if Covers(p,g.protection,asset) then score=score+asset.value end
    end
    return score
end
local function Candidates(army,id,center,radius,g,profile)
    local tp=Template(id);local f=R.Footprint(tp)
    local choices,seen={},{}
    local function add(x,z,priority)
        x,z=Round(x,f.x),Round(z,f.y)
        local p={x=x,y=center.y or 0,z=z}
        if not InRange(p,center,radius) then return end
        local key=x..":"..z
        local score=priority+D2(p,center)*0.006-ProtectionValue(p,g)*20
        if seen[key] then return end
        seen[key]=true
        choices[#choices+1]={pos=p,score=score,key=key}
    end
    if g.protection then
        -- Protect uncovered production/economy first; a shield count alone does
        -- not establish coverage, especially at a dispersed expansion.
        for _,asset in ipairs(g.assets) do
            for i=0,7 do
                local angle=i*math.pi/4
                local distance=math.max(4,g.protection.radius*0.35)
                add(asset.pos.x+math.cos(angle)*distance,
                    asset.pos.z+math.sin(angle)*distance,0)
            end
        end
    end
    if IsPower(tp) then
        local hubs={}
        for _,factory in ipairs(g.factories) do
            if D2(factory.pos,center)<(radius+12)^2 then hubs[#hubs+1]=factory end
        end
        -- A paid/planned factory is also a hub before the host creates its unit.
        for _,pending in ipairs(g.pending) do
            if IsFactory(pending.tp) and D2(pending.pos,center)<radius^2 then
                local duplicate=false
                for _,hub in ipairs(hubs) do if D2(hub.pos,pending.pos)<1 then duplicate=true;break end end
                if not duplicate then hubs[#hubs+1]=pending end
            end
        end
        table.sort(hubs,function(a,b)
            local da,db=D2(a.pos,profile.home),D2(b.pos,profile.home)
            if da~=db then return da<db end
            if a.pos.x~=b.pos.x then return a.pos.x<b.pos.x end
            return a.pos.z<b.pos.z
        end)
        for rank,factory in ipairs(hubs) do
            if rank>8 then break end
            for order=0,3 do
                local bank=(profile.bankStart+order*profile.bankDirection)%4
                local side=bank%2==0 and 1 or -1
                local axis=bank<2 and "x" or "z"
                local span=axis=="x" and factory.x or factory.z
                local transverse=axis=="x" and factory.z or factory.x
                local size=axis=="x" and f.x or f.y
                local crossSize=axis=="x" and f.y or f.x
                local columns=math.min(profile.bankColumns,math.max(2,math.floor(transverse/(crossSize+0.5))))
                for row=1,profile.bankRows do for i=1,columns do
                    local forward=side*(span/2+size/2+profile.bankGap+(row-1)*(size+0.5))
                    local cross=(i-(columns+1)/2)*(crossSize+0.5)
                    local x=factory.pos.x+(axis=="x" and forward or cross)
                    local z=factory.pos.z+(axis=="x" and cross or forward)
                    add(x,z,(rank-1)*100+order*16+row*5+i*0.1)
                end end
            end
        end
        -- Extra banks stay near the existing industry, rather than reverting to
        -- a universal north/south strip. Empty-base reserve banks use the profile.
        local anchor=hubs[1] and hubs[1].pos or profile.home
        local sx,sz=f.x+1,f.y+1
        for band=0,5 do for side=-1,1,2 do for column=1,profile.reserveWidth do
            local x,z=Profiles.Transform(profile,(column-(profile.reserveWidth+1)/2)*sx,
                side*(14+band*sz))
            add(anchor.x+x,anchor.z+z,1500+band*24+(side==profile.mirror and 0 or 8)+column)
        end end end
    else
        local sites = Profiles.FactorySites(profile,f)
        for _,site in ipairs(sites) do add(site.x,site.z,site.priority) end
        -- Small offsets around every district tolerate skirts/resource markers
        -- without changing the whole base into the old square fallback grid.
        for _,site in ipairs(sites) do
            for _,delta in ipairs(FACTORY_OFFSETS) do
                add(site.x+delta[1],site.z+delta[2],500+site.priority)
            end
        end
    end
    table.sort(choices,function(a,b) return a.score==b.score and a.key<b.key or a.score<b.score end)
    return choices
end
local function AdjacencyAnchors(tp,g,center,radius,developedOnly)
    if g.hiveFactories then return g.hiveFactories end
    local anchors={}
    if not Has(tp,"SCFA_STRUCTURE") then return anchors end
    local footprint=R.Footprint(tp)
    local reach=radius+math.sqrt(footprint.x^2+footprint.y^2)/2
    local power, massStorage, energyStorage, massFabricator=
        IsEnergyProducer(tp),IsMassStorage(tp),IsEnergyStorage(tp),IsMassFabricator(tp)
    local function add(q)
        if not Has(q.tp,"SCFA_STRUCTURE")
            or D2(q.pos,center)>(reach+math.sqrt(q.x*q.x+q.z*q.z)/2)^2 then return end
        if massStorage then
            if not q.unit or not q.unit:IsCompleted() then return end
            if not (IsExtractor(q.tp) and (not developedOnly or Tier(q.tp)>=2))
                and not (not developedOnly and IsMassFabricator(q.tp)) then return end
        elseif energyStorage then
            if not q.unit or not q.unit:IsCompleted() or not IsEnergyProducer(q.tp) then return end
        elseif power then
            if not UsesPower(q.tp) and not IsEnergyStorage(q.tp) then return end
        elseif massFabricator then
            if not IsEnergyProducer(q.tp) and not IsBuilderStructure(q.tp)
                and not IsMassStorage(q.tp) then return end
        elseif IsBuilderStructure(tp) then
            if not IsEnergyProducer(q.tp) and not IsExtractor(q.tp)
                and not IsMassFabricator(q.tp) then return end
        elseif UsesPower(tp) then
            if not IsEnergyProducer(q.tp) then return end
        else return end
        anchors[#anchors+1]=q
    end
    for _,q in ipairs(g.structures) do add(q) end
    if not massStorage and not energyStorage then
        for _,q in ipairs(g.pending) do add(q) end
    end
    table.sort(anchors,function(a,b)
        -- Fabricators should first lower their ongoing energy drain. Their own
        -- factory discount is useful when no generator edge remains available.
        if massFabricator then
            local pa,pb=IsEnergyProducer(a.tp),IsEnergyProducer(b.tp)
            if pa~=pb then return pa end
        end
        local ta,tb=Tier(a.tp),Tier(b.tp)
        if ta~=tb then return ta>tb end
        local da,db=D2(a.pos,center),D2(b.pos,center)
        if da~=db then return da<db end
        if a.pos.x~=b.pos.x then return a.pos.x<b.pos.x end
        if a.pos.z~=b.pos.z then return a.pos.z<b.pos.z end
        return tostring(a.id)<tostring(b.id)
    end)
    return anchors
end
local function FindAdjacent(tp,g,center,radius,try,developedOnly)
    local f=R.Footprint(tp)
    if not f then return nil end
    local directions={{1,0},{-1,0},{0,1},{0,-1}}
    local choices,seen,anchors={},{},{}
    for _,anchor in ipairs(AdjacencyAnchors(tp,g,center,radius,developedOnly)) do
        local anchorKey=anchor.pos.x..":"..anchor.pos.z..":"..anchor.x..":"..anchor.z
        if not anchors[anchorKey] then
            anchors[anchorKey]=true
            -- A full shared face beats a sliver; multiple useful neighbors add
            -- their benefit. Planned anchors count, but completed ones win ties.
            local weight=(1+Tier(anchor.tp)*2)*(anchor.unit and anchor.unit:IsCompleted() and 1 or 0.65)
            if IsMassFabricator(tp) and IsEnergyProducer(anchor.tp) then weight=weight*3 end
            local x0=math.floor(anchor.pos.x-anchor.x/2)
            local z0=math.floor(anchor.pos.z-anchor.z/2)
            for _,direction in ipairs(directions) do
                local dx,dz=direction[1],direction[2]
                local across=dx~=0 and f.y or f.x
                local start=dx~=0 and z0 or x0
                local span=dx~=0 and anchor.z or anchor.x
                local first,last=start-across+1,start+span-1
                if IsMassStorage(tp) or IsEnergyStorage(tp) then
                    first,last=start+math.min(0,span-across),start+math.max(0,span-across)
                end
                for cross=first,last do
                    local p
                    if dx~=0 then
                        p={x=(dx>0 and x0+anchor.x+f.x/2 or x0-f.x/2),z=cross+f.y/2}
                    else
                        p={x=cross+f.x/2,z=(dz>0 and z0+anchor.z+f.y/2 or z0-f.y/2)}
                    end
                    if InRange(p,center,radius) then
                        local key=p.x..":"..p.z
                        local candidate=seen[key]
                        if not candidate then
                            candidate={pos=p,benefit=0,key=key}
                            seen[key]=candidate;choices[#choices+1]=candidate
                        end
                        local edge=math.min(cross+across,start+span)-math.max(cross,start)
                        candidate.benefit=candidate.benefit+weight*edge/math.min(across,span)
                    end
                end
            end
        end
    end
    for _,candidate in ipairs(choices) do
        candidate.pos.y=center.y or 0
        candidate.score=candidate.benefit+ProtectionValue(candidate.pos,g)*4-D2(candidate.pos,center)*0.0001
    end
    table.sort(choices,function(a,b)
        return a.score==b.score and a.key<b.key or a.score>b.score
    end)
    for _,candidate in ipairs(choices) do
        local position=try(candidate.pos,0)
        if position then return position end
    end
end
local function RequiresDevelopedExtractor(adjacency,storageId)
    if type(adjacency)~="table" then return false end
    local t1Extractor=storageId:sub(1,3).."1601"
    local hasTargets=false
    for _,line in pairs(adjacency) do
        if type(line)=="table" then
            hasTargets=true
            if line[t1Extractor] then return false end
        end
    end
    return hasTargets
end
function Find(index,id,center,spacing,adjacency,radius,avoid,developedOnly,options)
    local army=Armies and Armies[index];local tp=Template(id)
    local hive=army and army.faction==3 and tp and Has(tp,"STRUCTURE")
        and Has(tp,"GUARD") and Has(tp,"SCFA_ENGINEERSTATION")
    local hiveRange=hive and Table(tp.construction).range
    if hive and (not Finite(hiveRange) or hiveRange<=0) then return false,true end
    local massStorage=tp and IsMassStorage(tp) and Has(tp,"SCFA_STRUCTURE")
    local energyStorage=tp and IsEnergyStorage(tp) and Has(tp,"SCFA_STRUCTURE")
    local generator=tp and IsGenerator(tp) and Has(tp,"SCFA_STRUCTURE")
    local massFabricator=tp and IsMassFabricator(tp) and Has(tp,"SCFA_STRUCTURE")
    local adjacencyConsumer=tp and Has(tp,"SCFA_STRUCTURE") and UsesPower(tp)
    local developedStorage=massStorage and RequiresDevelopedExtractor(adjacency,id)
    if not army or not tp or not (IsPower(tp) or IsFactory(tp)
        or massStorage or energyStorage or generator or massFabricator or adjacencyConsumer or hive
        or IsProtection(tp) or (Has(tp,"STRUCTURE") or Has(tp,"SCFA_STRUCTURE"))
            and (Has(tp,"WALL") or Has(tp,"ARTILLERY") or Has(tp,"SCFA_ARTILLERY") or HeavyPolicy.IsExperimental(tp))) then return nil,false end
    if not Position(center) or not R.Footprint(tp) then return false,true end
    -- Respect small marker/recovery radii exactly; never enlarge a caller's cap.
    radius=Finite(radius) and math.max(0,math.min(160,radius)) or 80
    local profile,coverageBase=GetProfile(army,center)
    if coverageBase and not Finite(coverageBase.radius) then coverageBase=nil end
    local requestedGap=tonumber(spacing)
    local gap=IsPower(tp) and 0.5 or math.max(IsFactory(tp) and 3 or 0,
        Finite(requestedGap) and requestedGap or 4)
    local f=R.Footprint(tp)
    local g=Geometry(army,center,radius,avoid,f,gap,IsProtection(tp) and coverageBase,hiveRange,
        options and options.exceptPlatoon,options and options.ignoreBeachheadFactory)
    if hive and #g.hiveFactories==0 then return false,true end
    g.emergencyShield=options and options.emergencyShield
    PrepareProtection(tp,g)
    for _,factory in ipairs(g.factories) do factory.exits=Exits(factory) end
    for _,pending in ipairs(g.pending) do if IsFactory(pending.tp) then pending.exits=Exits(pending) end end
    local main=army.ai and army.ai.bases and army.ai.bases.MAIN
    local mainPosition=main and main.position
    local nearbyFactory=false
    if IsFactory(tp) then
        for _,q in ipairs(g.structures) do
            if IsFactory(q.tp) then nearbyFactory=true;break end
        end
    end
    local protectMainSpawn=IsFactory(tp) and not nearbyFactory and Position(mainPosition)
        and D2(center,mainPosition)<1
    local builder=options and options.builder
    local openingCommander=protectMainSpawn and Own(army,builder) and Has(builder.tp,"COMMAND")
    local knownBuilder=false
    if openingCommander then
        for _,mobile in ipairs(g.mobiles) do
            if mobile.unit==builder then
                mobile.clearance=0.5;knownBuilder=true;break
            end
        end
    end
    local examined,visited=0,{}
    local function try(p,placementGap)
        p.x,p.z=Round(p.x,f.x),Round(p.z,f.y);p.y=0
        local key=p.x..":"..p.z
        if visited[key] then return nil end
        visited[key]=true
        -- Prefer the live commander's real footprint to a padded spawn marker.
        -- Unknown builders retain the conservative opening clearance.
        if protectMainSpawn and not knownBuilder and Overlap(p,f.x,f.y,mainPosition,3,3,3) then return nil end
        if not InRange(p,center,radius) or not R.Inside(p,math.max(f.x,f.y)/2+0.5) then return nil end
        if hive then
            local useful=false
            for _,factory in ipairs(g.hiveFactories) do
                -- Keeping both centers inside the authored radius is more
                -- conservative than assuming a skirt equals a build collider.
                if Own(army,factory.unit) and factory.unit:IsCompleted()
                    and D2(p,factory.pos)<hiveRange^2 and D2(p,factory.workPos)<hiveRange^2 then
                    useful=true;break
                end
            end
            if not useful then return nil end
        end
        local pos=SnapToGround(p)
        if g.needsCoverage then
            local improved=false
            for _,asset in ipairs(g.assets) do
                if Position(pos) and asset.uncovered and Covers(pos,g.protection,asset) then improved=true;break end
            end
            if not improved then return nil end
        end
        if Position(pos) and InRange(pos,center,radius)
            and ClearCandidate(army,tp,pos,g,placementGap or gap,avoid)
            and AF.CanBuildStructureAt(index,id,pos,0)
            and (not options or not options.accept or options.accept(pos)) then
            return pos
        end
    end
    if openingCommander then
        local start=builder:GetPosition()
        local range=tonumber(Table(builder.construction).range) or tonumber(Table(builder.tp.construction).range)
        if Position(start) and range and range>0 then
            range=math.max(1,range-0.5)
            -- The opening starts work from the commander's current position.
            -- Prefer a useful adjacent site already in reach, then the nearest
            -- legal grid site; district shapes must not cost opening travel time.
            local adjacent=FindAdjacent(tp,g,center,radius,function(p,placementGap)
                if D2(p,start)<=range^2 then return try(p,placementGap) end
            end,developedOnly or developedStorage)
            if adjacent then return adjacent,true end
            local choices={}
            local reach=math.min(radius,range+math.max(f.x,f.y)+4)
            for x=Round(start.x-reach,f.x),Round(start.x+reach,f.x) do
                for z=Round(start.z-reach,f.y),Round(start.z+reach,f.y) do
                    local p={x=x,z=z};local distance=D2(p,start)
                    if distance<=reach^2 and InRange(p,center,radius) then
                        choices[#choices+1]={pos=p,distance=distance}
                    end
                end
            end
            table.sort(choices,function(a,b)
                if a.distance~=b.distance then return a.distance<b.distance end
                return a.pos.x==b.pos.x and a.pos.z<b.pos.z or a.pos.x<b.pos.x
            end)
            for _,candidate in ipairs(choices) do
                local pos=try(candidate.pos,0)
                if pos then return pos,true end
            end
        end
    end
    if generator or massStorage or energyStorage or massFabricator or adjacencyConsumer or hive then
        local adjacent=FindAdjacent(tp,g,center,radius,try,developedOnly or developedStorage)
        if adjacent then return adjacent,true end
        -- A caller restricted to developed extractors must retain that
        -- restriction when every touching site is occupied.
        if developedStorage or developedOnly and massStorage then return false,true end
        -- Keep the same exit, reservation and footprint safeguards even when
        -- every adjacency edge is occupied. Capacity recovery can still place.
    end
    if options and options.adjacentOnly then return false,true end
    for _,c in ipairs(Candidates(army,id,center,radius,g,profile)) do
        examined=examined+1
        if examined>600 then break end
        local pos=try(c.pos)
        if pos then return pos,true end
    end
    -- Terrain rescue covers the full allowed radius, including narrow expansion
    -- markers. It never drops real footprint, pending-order or exit safeguards.
    -- Offset radial samples prevent all fallback bases sharing one square grid.
    for ring=0,15 do
        local r=radius*ring/15
        local samples=ring==0 and 1 or math.min(48,math.max(12,math.ceil(2*math.pi*r/4)))
        for i=0,samples-1 do
            local angle=2*math.pi*(i/samples+(profile.seed%31)/31)+(ring%2)*math.pi/samples
            local x,z=Profiles.Transform(profile,math.cos(angle)*r,math.sin(angle)*r)
            local pos=try({x=center.x+x,z=center.z+z})
            if pos then return pos,true end
        end
    end
    return false,true
end
-- Beachheads use public coast geometry and existing observed intelligence.
-- The operation owns movement, budgets and orders; layout only proposes sites.
local function BeachheadCopy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function BeachheadKey(p) return math.floor(p.x/24)..":"..math.floor(p.z/24) end
local function BeachheadSafe(army,pos,layer,platoon)
    if not Position(pos) or not R.Inside(pos,4) then return false end
    local allowed=platoon and Intel.FriendlyThreat(platoon,pos,48,"Land",false)*0.8+1 or 1
    local ok,threat=pcall(TM.GetThreatFromHeatMapPosition,army.id,pos,layer or "Land")
    if not ok or not Finite(threat) or threat>allowed then return false end
    return layer~="Land" or Intel.EnemyThreat(army,pos,"Land",6,0)<=allowed
end
local function BeachheadGoals(army,source,state)
    local result,seen={},{}
    local function add(pos,enemy,value)
        if not Position(pos) or not enemy or not army:IsEnemy(enemy) then return end
        local key=BeachheadKey(pos)
        if not seen[key] then
            seen[key]=true;result[#result+1]={position=BeachheadCopy(pos),enemy=enemy,value=value,distance=D2(source,pos)}
        end
    end
    local enemy=Intel.Get(army).enemy;local count=#enemy
    local offset=count>0 and (state.goalCursor or 0)%count or 0
    for i=1,math.min(64,count) do
        local r=enemy[(offset+i-1)%count+1]
        if Intel.Visible(army,r.unit) and Has(r.unit.tp,"STRUCTURE") and not Has(r.unit.tp,"NAVAL")
            and (Has(r.unit.tp,"FACTORY") or IsExtractor(r.unit.tp) or IsEnergyProducer(r.unit.tp)) then
            add(r.pos,r.owner,Has(r.unit.tp,"FACTORY") and 3 or 2)
        end
    end
    state.goalCursor=count>0 and (offset+64)%count or 0
    local starts=GameInfo and GameInfo.MapData and GameInfo.MapData.markers
        and GameInfo.MapData.markers.Spawn and GameInfo.MapData.markers.Spawn.transforms
    for _,enemy in pairs(Armies or {}) do
        local marker=starts and starts[enemy.name]
        if enemy~=army and not (enemy.ai and enemy.ai.isAlive==false) and marker then add(marker.position,enemy,1) end
    end
    table.sort(result,function(a,b)
        if a.value~=b.value then return a.value>b.value end
        if a.distance~=b.distance then return a.distance<b.distance end
        return a.position.x==b.position.x and a.position.z<b.position.z or a.position.x<b.position.x
    end)
    while #result>12 do table.remove(result) end
    return result
end
local function BeachheadOutsideBases(army,pos)
    for _,base in pairs(army.ai.bases or {}) do
        if base.baseType~="NAVAL" and Position(base.position)
            and D2(base.position,pos)<(math.max(0,tonumber(base.radius) or 0)+40)^2 then return false end
    end
    return true
end
local function BeachheadSiteCurrent(army,builder,site)
    if not army or not army.ai or army.ai.isAlive==false or not army.ai.bases
        or not site or site.armyAI~=army.ai then return false end
    local operation=BeachheadOperation(army);local baseCurrent
    if operation and operation.site==site and operation.baseName then
        local base=army.ai.bases[operation.baseName]
        -- A landed base keeps its own construction when the original shore is
        -- lost. A reused base name or reassigned engineer cannot inherit it.
        baseCurrent=base and base==operation.baseRef and base.baseType~="NAVAL"
            and builder==operation.builder and builder.assignedToBase==operation.baseName
            and R.CurrentAssignment(builder,army,operation.platoon,operation.builderAI,operation.platoonAI)
            and Position(site.factoryPosition)
            and MG.CanGraphAreaToStrict(builder:GetPosition(),site.factoryPosition,"Land")
    else
        baseCurrent=site and site.sourceBaseRef and army.ai.bases[site.sourceName]==site.sourceBaseRef
            and Position(site.sourceBaseRef.position) and Position(site.source)
            and D2(site.sourceBaseRef.position,site.source)<0.01
    end
    return baseCurrent and Own(army,builder)
        and not builder.CaptureInProgress and not builder.ReclaimInProgress
        and site.builder==builder and site.builderAI==builder.ai and builder:IsCompleted()
        and Position(site.position) and Position(site.factoryPosition) and Position(site.shore)
        and Position(site.sourceWater) and Position(site.landGoal) and army:IsEnemy(site.enemy)
        and R.CanBuilderBuild(builder,site.factoryId) and R.AllowedTarget(site.factoryId,false)
end
function BeachheadCandidates(army,snapshot,builder,factoryId,blocked)
    local result={};local tp=Template(factoryId)
    if not army or not army.ai or army.ai.isAlive==false or not Own(army,builder)
        or not builder.ai or not builder:IsCompleted() or not tp or not Has(tp,"LAND_FACTORY")
        or not R.CanBuilderBuild(builder,factoryId) or not R.AllowedTarget(factoryId,false)
        or not MG.IsMarkerGridPresent() or MG.IsMarkerGridUpdating and MG.IsMarkerGridUpdating() then return result end
    local sourceName=builder.assignedToBase;local source=army.ai.bases[sourceName]
    local layer=Movement.UnitMovementLayer(builder)
    if not source or source.baseType=="NAVAL" or not Position(source.position)
        or layer~="Hover" and layer~="Seabed" then return result end
    local land=MG.GetMarkerTable("Land");local native=MG.GetNavalExpansions()
    if type(land)~="table" or type(native)~="table" then return result end
    local shores={}
    for _,water in pairs(native) do
        if Position(water) and water.GraphArea then shores[#shores+1]=water end
    end
    table.sort(shores,function(a,b) return a.x==b.x and a.z<b.z or a.x<b.x end)
    if #shores<2 then return result end
    local origins={}
    for _,water in ipairs(shores) do
        local distance=D2(source.position,water)
        if distance<=320^2 then origins[#origins+1]={position=water,distance=distance} end
    end
    table.sort(origins,function(a,b)
        if a.distance~=b.distance then return a.distance<b.distance end
        return a.position.x==b.position.x and a.position.z<b.position.z or a.position.x<b.position.x
    end)
    local state=army.ai.rushBeachheadLayout
    if not state or state.armyAI~=army.ai then state={armyAI=army.ai,cursor=0};army.ai.rushBeachheadLayout=state end
    local sourceWaters,checked={},{}
    local originOffset=#origins>0 and (state.originCursor or 0)%#origins or 0
    for i=1,math.min(4,#origins) do
        local selected=i<=2 and i or (originOffset+i-3)%#origins+1
        if not checked[selected] then
            checked[selected]=true;local pos=origins[selected].position
            if MG.CanGraphAreaTo(builder:GetPosition(),pos,layer) and BeachheadSafe(army,pos,layer) then
                sourceWaters[#sourceWaters+1]=pos
            end
        end
    end
    state.originCursor=#origins>0 and (originOffset+2)%#origins or 0
    if #sourceWaters==0 then return result end
    local goals=BeachheadGoals(army,source.position,state);if #goals==0 then return result end
    local preliminary,seen={},{};local now=GetGameTimeSeconds()
    local offset=state.cursor%#shores
    for i=1,math.min(8,#shores) do
        local shore=shores[(offset+i-1)%#shores+1]
        local sourceWater,sourceDistance
        for _,water in ipairs(sourceWaters) do
            local distance=D2(water,shore)
            if distance>=80^2 and distance<=1200^2 and shore.GraphArea==water.GraphArea
                and (not sourceDistance or distance<sourceDistance)
                and MG.CanGraphAreaTo(water,shore,layer) then sourceWater,sourceDistance=water,distance end
        end
        if sourceWater and BeachheadSafe(army,shore,layer) then
            local gx,gz=MG.GetMarkerGridIndexFromWorldPosition(shore);local nearby={}
            for dx=-3,3 do for dz=-3,3 do
                local node=land[gx+dx] and land[gx+dx][gz+dz]
                if node and node.GraphArea and Position(node.position) then
                    nearby[#nearby+1]={node=node,distance=D2(node.position,shore)}
                end
            end end
            table.sort(nearby,function(a,b)
                if a.distance~=b.distance then return a.distance<b.distance end
                return a.node.position.x==b.node.position.x and a.node.position.z<b.node.position.z
                    or a.node.position.x<b.node.position.x
            end)
            for j=1,math.min(6,#nearby) do
                local node=nearby[j].node;local pos=node.position;local key=BeachheadKey(pos)
                if not seen[key] and (not blocked or (blocked[key] or 0)<=now)
                    and nearby[j].distance<=110^2 and BeachheadOutsideBases(army,pos)
                    and MG.CanGraphAreaTo(shore,pos,layer) and BeachheadSafe(army,pos,"Land") then
                    seen[key]=true
                    for _,goal in ipairs(goals) do
                        local inland=D2(pos,goal.position)
                        if inland>=64^2 and inland<=700^2 and inland<goal.distance*0.72
                            and MG.CanGraphAreaToStrict(pos,goal.position,"Land") then
                            local score=math.sqrt(sourceDistance)+math.sqrt(inland)*0.7-goal.value*12
                            preliminary[#preliminary+1]={key=key,position=BeachheadCopy(pos),shore=BeachheadCopy(shore),
                                landGoal=goal.position,enemy=goal.enemy,landArea=node.GraphArea,waterArea=shore.GraphArea,
                                score=score,armyAI=army.ai,builder=builder,builderAI=builder.ai,
                                factoryId=factoryId,sourceName=sourceName,sourceBaseRef=source,
                                source=BeachheadCopy(source.position),sourceWater=BeachheadCopy(sourceWater)}
                            break
                        end
                    end
                end
            end
        end
    end
    state.cursor=(offset+8)%#shores
    table.sort(preliminary,function(a,b) return a.score==b.score and a.key<b.key or a.score<b.score end)
    for i=1,math.min(4,#preliminary) do
        local site=preliminary[i]
        local dx,dz=site.position.x-site.shore.x,site.position.z-site.shore.z
        local distance=math.sqrt(dx*dx+dz*dz)
        local center=BeachheadCopy(site.position)
        if distance>1 then center.x=center.x+dx/distance*12;center.z=center.z+dz/distance*12 end
        local pos=Find(army.id,factoryId,center,3,nil,26,nil,false,{builder=builder,accept=function(p)
            return BeachheadOutsideBases(army,p) and MG.CanGraphAreaToStrict(p,site.landGoal,"Land")
                and MG.CanGraphAreaTo(site.position,p,layer) and BeachheadSafe(army,p,"Land")
        end})
        if pos and Own(army,builder) and builder.ai==site.builderAI and army.ai==site.armyAI then
            site.factoryPosition=BeachheadCopy(pos);result[#result+1]=site
        end
    end
    return result
end
local function BeachheadKind(tp,kind)
    if kind=="factory" then return Has(tp,"LAND_FACTORY") end
    if kind=="wall" then return Has(tp,"STRUCTURE") and Has(tp,"WALL") end
    if kind=="aa" then return IsProtection(tp) and Has(tp,"ANTI_AIR") and Protection(tp,"Air")~=nil end
    return kind=="defense" and IsProtection(tp) and not Has(tp,"ANTI_AIR") and Protection(tp,"Land")~=nil
end
local function BeachheadBuildCurrent(platoon,builder,id,site,kind,pos)
    local army=platoon and platoon.army;local data=platoon and platoon.ai;local tp=Template(id)
    local operation=army and BeachheadOperation(army)
    if not army or not data or not operation or operation.site~=site or operation.platoon~=platoon
        or not BeachheadSiteCurrent(army,builder,site) or builder.platoon~=platoon
        or not R.CurrentAssignment(builder,army,platoon,builder.ai,data)
        or not BeachheadKind(tp,kind) or not Position(pos) or not R.CanBuilderBuild(builder,id)
        or not R.AllowedTarget(id,false) or not BeachheadSafe(army,pos,"Land",platoon)
        or not MG.CanGraphAreaToStrict(pos,site.landGoal,"Land") then return false end
    if kind=="factory" then return id==site.factoryId and D2(pos,site.factoryPosition)<=0.01 end
    return D2(pos,site.factoryPosition)<=55^2
end
function ValidateBeachhead(platoon,builder,id,site,kind,index,pos)
    if not BeachheadBuildCurrent(platoon,builder,id,site,kind,pos) then return false end
    local army=platoon.army;local tp=Template(id);local f=R.Footprint(tp);if not f then return false end
    local g=Geometry(army,pos,55,nil,f,kind=="wall" and 0 or 2,nil,nil,platoon,kind=="factory")
    return ClearCandidate(army,tp,pos,g,kind=="wall" and 0 or kind=="factory" and 3 or 2)
        and AF.CanBuildStructureAt(army.id,id,pos,0)==true or false
end
function FindBeachhead(platoon,builder,id,site,kind,index)
    local army=platoon and platoon.army;local tp=Template(id)
    if not army or not BeachheadSiteCurrent(army,builder,site) or not BeachheadKind(tp,kind) then return false end
    if kind=="factory" then
        local pos=BeachheadCopy(site.factoryPosition)
        return ValidateBeachhead(platoon,builder,id,site,kind,index,pos) and pos or false
    end
    local dx,dz=site.landGoal.x-site.factoryPosition.x,site.landGoal.z-site.factoryPosition.z
    local distance=math.sqrt(dx*dx+dz*dz);if distance<1 then return false end
    local nx,nz=dx/distance,dz/distance
    local slot=math.max(1,math.min(12,math.floor(tonumber(index) or 1)))
    local side=slot%2==1 and -1 or 1
    local f=R.Footprint(tp);local factory=R.Footprint(Template(site.factoryId))
    if not f or not factory then return false end
    local edge=math.abs(nx)*factory.x/2+math.abs(nz)*factory.y/2
    local forward=kind=="aa" and -8 or edge+(kind=="wall" and 16 or 8)
    local across=side*(kind=="wall" and 10+math.floor((slot-1)/2)*math.max(f.x,f.y) or 12)
    local desired={x=site.factoryPosition.x+nx*forward-nz*across,y=site.factoryPosition.y,
        z=site.factoryPosition.z+nz*forward+nx*across}
    local pos=Find(army.id,id,desired,kind=="wall" and 0 or 2,nil,kind=="wall" and 2 or 8,nil,false,
        {builder=builder,exceptPlatoon=platoon,accept=function(p)
            return BeachheadBuildCurrent(platoon,builder,id,site,kind,p)
        end})
    return pos and ValidateBeachhead(platoon,builder,id,site,kind,index,pos) and pos or false
end

-- Ground defense is an objective with real weapon coverage, not a base-wide
-- turret count. The normal construction queue owns every builder and order.
local function GroundGun(tp)
    return Has(tp,"STRUCTURE") and Has(tp,"DEFENCE") and Has(tp,"DIRECT_FIRE")
        and not Has(tp,"ANTI_AIR") and not Has(tp,"ARTILLERY")
        and not Has(tp,"SCFA_ARTILLERY") and Protection(tp,"Land")~=nil
end
function IsGroundDefenseTemplate(tp,tier) return GroundGun(tp) and (not tier or Tier(tp)==tier) end
local function GroundCopy(p) return {x=p.x,y=p.y or 0,z=p.z} end
local function GroundState(army)
    local now=GetGameTimeSeconds();local s=army.ai.rushGroundDefense
    if not s or now<(s.at or now) then s={mex={},blocked={}};army.ai.rushGroundDefense=s end
    s.at=now
    for unit,r in pairs(s.mex) do
        if not Own(army,unit) or now-r.at>=180 then s.mex[unit]=nil end
    end
    for key,untilTime in pairs(s.blocked) do if now>=untilTime then s.blocked[key]=nil end end
    return s
end
local function GroundBlock(army,key)
    local s=GroundState(army);s.blocked[key]=GetGameTimeSeconds()+15
    local count,oldest,when=0
    for k,expiry in pairs(s.blocked) do
        count=count+1
        if k~=key and (not when or expiry<when or expiry==when and k<oldest) then oldest,when=k,expiry end
    end
    if count>64 and oldest then s.blocked[oldest]=nil end
end
local function GroundData(snapshot)
    snapshot.groundDefenseAssets=snapshot.groundDefenseAssets or {extractors={},guns={},assets={}}
    return snapshot.groundDefenseAssets
end
local function GroundCell(p,span) return math.floor(p.x/span)..":"..math.floor(p.z/span) end
local function GroundGridAdd(grid,record,span)
    local key=GroundCell(record.pos,span);grid[key]=grid[key] or {};grid[key][#grid[key]+1]=record
end
local function GroundNeighbors(grid,pos,span,fn)
    local x,z=math.floor(pos.x/span),math.floor(pos.z/span)
    for dx=-1,1 do for dz=-1,1 do
        for _,record in ipairs(grid[(x+dx)..":"..(z+dz)] or {}) do fn(record) end
    end end
end
local function GroundPlans(army,except)
    local result={active=0,claims={},guns={}}
    for _,p in pairs(army.platoons or {}) do
        local data=p.ai;local former=data and data.formerTable
        if p~=except and data and former and not p.dead and not p.deleted and army:PlatoonExists(p) then
            local claim=data.rushGroundDefense
            local id=data.nextBuildingtpId or claim and claim.id
            local tp=id and Template(id)
            if former.RushGroundDefense or former.RushBaseDefense=="ground" or GroundGun(tp) then
                local live=false
                for _,u in pairs(p:GetUnits()) do
                    if Own(army,u) and not u.CaptureInProgress and not u.ReclaimInProgress
                        and u.platoon==p and Has(u.tp,"ENGINEER") then live=true;break end
                end
                local started=data.rushGroundDefenseStartup;local now=GetGameTimeSeconds()
                local startup=former.RushGroundDefense and Finite(started) and now>=started and now-started<=2
                local target=data.buildedUnit
                if (live or startup) and not (Own(army,target) and target:IsCompleted()) then
                    -- Include startup platoons before their placement coroutine
                    -- publishes a claim; two bases cannot reserve four builders.
                    result.active=result.active+1
                    if claim and claim.armyAI==army.ai and claim.platoonAI==data
                        and Own(army,claim.builder) and claim.builder.platoon==p
                        and claim.builder.ai==claim.builderAI then
                        result.claims[#result.claims+1]=claim.objective
                    end
                    local pos=data.placeToBuild or claim and claim.position
                    if GroundGun(tp) and Position(pos) then
                        result.guns[#result.guns+1]={pos=pos,tp=tp,protection=Protection(tp,"Land"),pending=true}
                    end
                end
            end
        end
    end
    return result
end
function GroundDefenseSlotAvailable(army)
    return army and army.ai and army.ai.isAlive~=false and GroundPlans(army).active<2 or false
end
local function GroundCovers(pos,protection,objective)
    if not protection then return false end
    -- Extractors need full local coverage. A factory's exposed approach can be
    -- defended without requiring one gun to cover its whole diagonal footprint.
    local protects=objective.kind=="mex" and Covers(pos,protection,objective.asset)
        or objective.kind~="mex" and D2(pos,objective.asset.pos)<=(protection.radius+objective.asset.half)^2
    return protects and D2(pos,objective.point)<=math.max(0,protection.radius-2)^2
end
local function GroundCoverage(army,snapshot,objective,plans)
    local count={t1=0,advanced=0,advancedPower=0,pending=false};local positions={}
    local function add(gun)
        if gun.unit and (not Own(army,gun.unit) or gun.unit.CaptureInProgress or gun.unit.ReclaimInProgress) then return end
        if not GroundCovers(gun.pos,gun.protection,objective) then return end
        for _,p in ipairs(positions) do if D2(p,gun.pos)<1 then return end end
        positions[#positions+1]=gun.pos
        local tier=Tier(gun.tp)
        if tier>=2 then
            count.advanced=count.advanced+1;count.advancedPower=count.advancedPower+(tier>=3 and 2 or 1)
        else count.t1=count.t1+1 end
        if gun.pending or gun.unit and not gun.unit:IsCompleted() then count.pending=true end
    end
    for _,gun in ipairs(GroundData(snapshot).guns) do add(gun) end
    for _,gun in ipairs(plans.guns) do add(gun) end
    for _,claimed in ipairs(plans.claims) do
        if claimed and (claimed.key==objective.key
            or claimed.kind=="mex" and objective.kind=="mex" and D2(claimed.point,objective.point)<16^2
            or claimed.kind=="flank" and objective.kind=="flank"
                and claimed.defenseBaseRef==objective.defenseBaseRef
                and claimed.dx*objective.dx+claimed.dz*objective.dz>=0.70
                and D2(claimed.point,objective.point)<24^2) then
            count.pending=true
        end
    end
    return count
end
local function GroundCurrent(army,objective)
    local base=army.ai.bases and army.ai.bases[objective.baseName]
    local defended=objective.defenseBaseName and army.ai.bases[objective.defenseBaseName]
    return base==objective.baseRef and base and base.baseType~="NAVAL" and Position(base.position)
        and D2(base.position,objective.home)<1 and Own(army,objective.anchor)
        and not objective.anchor.CaptureInProgress and not objective.anchor.ReclaimInProgress
        and objective.anchor:IsCompleted() and D2(objective.anchor:GetPosition(),objective.asset.pos)<1
        and (not objective.defenseBaseName or defended and defended==objective.defenseBaseRef
            and defended.baseType~="NAVAL" and Position(defended.position) and D2(defended.position,objective.defenseHome)<1)
        and GetGameTimeSeconds()<objective.expires
end
local function GroundIdle(army,u)
    local orders=u and u.orders
    return Own(army,u) and not u.CaptureInProgress and not u.ReclaimInProgress
        and u:IsCompleted() and not u.platoon and not R.Working(u) and not u.buildBehaviorIsActive
        and not (orders and (orders.activeOrder or next(orders.queuedOrders or {})))
        and not (u.ai and (u.ai.reservedEco or u.ai.eState=="RepairHome"))
        and not (army.ai.ecoReserve and army.ai.ecoReserve[u.id.index])
        and not R.BuilderRecallReserved(u) and not (u.GetPause and u:GetPause())
end
local function GroundRecruitable(army,entry)
    local base=army.ai.bases[entry.name];local u=entry.unit
    return base==entry.base and base and base.baseType~="NAVAL" and Position(base.position)
        and Finite(base.radius) and base.radius>0 and GroundIdle(army,u)
        and u.assignedToBase==entry.name and D2(u:GetPosition(),base.position)<=base.radius^2
end
local function GroundBuilders(army,snapshot,tier)
    snapshot.groundDefenseBuilders=snapshot.groundDefenseBuilders or {}
    local cached=snapshot.groundDefenseBuilders[tier]
    if cached then return cached end
    cached={};snapshot.groundDefenseBuilders[tier]=cached
    local former
    for _,f in pairs(army.ai.formerpool or {}) do if f.RushGroundDefense==tier then former=f;break end end
    if not former then return cached end
    local ids={}
    for _,line in ipairs(former.WantStructures or {}) do
        for id,on in pairs(line) do
            if on and IsGroundDefenseTemplate(Template(id),tier) and R.AllowedTarget(id,false) then ids[#ids+1]=id end
        end
    end
    table.sort(ids)
    local protected=Rules.ProtectedPowerBuilder(army,former)
    -- Reuse the owned-unit census, including the native expansion assignment.
    -- A T1-only or busy outpost must not strand a viable T2 request from MAIN.
    for _,u in ipairs(snapshot.balanceEngineers or {}) do
        local base=u.assignedToBase and army.ai.bases[u.assignedToBase]
        if u~=protected and base and GroundRecruitable(army,{unit=u,name=u.assignedToBase,base=base}) and Tier(u.tp)>=tier then
            for _,id in ipairs(ids) do
                if R.CanBuilderBuild(u,id) and Rules.CanFundGroundDefense(u,id,snapshot) then
                    local layer=Movement.UnitMovementLayer(u)
                    if layer then cached[#cached+1]={unit=u,name=u.assignedToBase,base=base,layer=layer} end
                    break
                end
            end
        end
    end
    return cached
end
local function GroundSource(army,snapshot,objective,tier,builder,baseName)
    snapshot.groundDefenseSources=snapshot.groundDefenseSources or {[1]={},[2]={}}
    local cache=snapshot.groundDefenseSources[tier];local best=not builder and cache[objective]
    if best and not GroundRecruitable(army,best) then best=nil end
    local distance=best and D2(best.unit:GetPosition(),objective.asset.pos)
    local function consider(entry,assigned)
        local u=entry.unit
        if (assigned or GroundRecruitable(army,entry)) and army.ai.bases[entry.name]==entry.base then
            local pos=u:GetPosition();local d=D2(pos,objective.asset.pos)
            if (not distance or d<distance or d==distance and tostring(entry.name)<tostring(best.name))
                and MG.CanGraphAreaTo(pos,objective.asset.pos,entry.layer) then best,distance=entry,d end
        end
    end
    -- Source searches are shared across all base supervisors for this census.
    -- Re-evaluate only when the chosen worker becomes unavailable.
    if builder or best==nil then
        for _,entry in ipairs(GroundBuilders(army,snapshot,tier)) do
            -- Once recruited, this base must use the actual lead. Another
            -- idle amphibious engineer cannot stand in for an unreachable one.
            if not builder or entry.name~=baseName then consider(entry,false) end
        end
        if not builder then cache[objective]=best or false end
    end
    if Own(army,builder) and builder.platoon and army.ai.bases[baseName] then
        local layer=Movement.UnitMovementLayer(builder)
        if layer then consider({unit=builder,name=baseName,base=army.ai.bases[baseName],layer=layer},true) end
    end
    return best or nil
end

local function GroundRequests(army,snapshot)
    if snapshot.groundDefenseRequests then return snapshot.groundDefenseRequests end
    local requests={};snapshot.groundDefenseRequests=requests
    local main=army.ai.bases and army.ai.bases.MAIN
    if not main or not Position(main.position) or not MG.IsMarkerGridPresent() then return requests end
    local now=GetGameTimeSeconds();local state=GroundState(army);local data=GroundData(snapshot)
    local function append(kind,key,b,anchor,point,dx,dz,extra)
        local objective=extra or {}
        objective.kind,objective.key,objective.baseName,objective.baseRef=kind,key,b.name,b.base
        objective.home=GroundCopy(b.base.position);objective.anchor=anchor.unit
        if kind~="mex" then
            objective.defenseBaseName,objective.defenseBaseRef=b.name,b.base
            objective.defenseHome=GroundCopy(b.base.position)
        end
        objective.asset={pos=GroundCopy(anchor.pos),half=anchor.half}
        objective.point=GroundCopy(point);objective.dx,objective.dz=dx,dz
        objective.expires=objective.expires or now+180
        requests[#requests+1]=objective
    end
    for _,front in ipairs(Frontline.DefensePressure(army)) do
        if front.active or front.repeated then
            local base=front.baseRef;local dx,dz=front.pos.x-front.base.x,front.pos.z-front.base.z
            local length=math.sqrt(dx*dx+dz*dz)
            if length>1 then
                dx,dz=dx/length,dz/length
                local anchor,best
                for _,asset in ipairs(data.assets) do
                    local x,z=asset.pos.x-front.base.x,asset.pos.z-front.base.z
                    local forward=x*dx+z*dz;local side=math.abs(x*dz-z*dx)
                    if D2(asset.pos,front.base)<=math.min(180,base.radius or 100)^2
                        and side<=math.max(32,math.abs(forward)*0.65) then
                        local score=forward-side*0.8+(IsFactory(asset.tp) and 8 or 0)
                        if not best or score>best then anchor,best=asset,score end
                    end
                end
                if anchor and MG.CanGraphAreaTo(front.pos,anchor.pos,"Land") then
                    local contacts=front.contacts or 1
                    local heavy=front.repeated and front.active and contacts>=4
                        and ((front.contactSeconds or 0)>=20 or (front.encounters or 0)>=2)
                    local reach=math.max(10,anchor.half+6)
                    local point={x=anchor.pos.x+dx*reach,y=anchor.pos.y,z=anchor.pos.z+dz*reach}
                    append("flank",front.key,{name=front.baseName,base=base},anchor,point,dx,dz,
                        {active=front.active,repeated=front.repeated,contacts=contacts,
                         valuable=front.repeated or contacts>=3,desired=heavy and 2 or 1,
                         expires=front.lastSeen+180})
                end
            end
        end
    end
    -- A compact local grid reuses the existing visible-enemy census. Air-only
    -- raids and offshore ships do not create a ground-turret demand.
    local enemies,extractors={},{}
    for _,record in ipairs(Intel.Get(army).enemy) do
        local unit=record.unit
        if record.completed~=false and Intel.Visible(army,unit) and not Has(unit.tp,"AIR")
            and not Has(unit.tp,"NAVAL") and (not Has(unit.tp,"ENGINEER") or Has(unit.tp,"COMMAND"))
            and not Has(unit.tp,"SCOUT")
            and Intel.KnownThreat(army,unit,"Land")>0 then
            GroundGridAdd(enemies,{pos=record.pos,tier=Tier(unit.tp)},80)
        end
    end
    for _,mex in ipairs(data.extractors) do GroundGridAdd(extractors,mex,40) end
    table.sort(data.extractors,function(a,b) return a.unit.id.index<b.unit.id.index end)
    local remote=math.max(80,math.min(120,(main.rushLayoutNativeRadius or main.radius or 100)*0.65))
    for _,mex in ipairs(data.extractors) do
        local homeDistance=D2(mex.pos,main.position)
        if homeDistance>remote^2 and Own(army,mex.unit) then
            local cluster,contacts,advanced=0,0,false;local lastPos,nearest
            GroundNeighbors(extractors,mex.pos,40,function(other)
                if D2(mex.pos,other.pos)<=32^2 then cluster=cluster+1 end
            end)
            GroundNeighbors(enemies,mex.pos,80,function(enemy)
                local distance=D2(mex.pos,enemy.pos)
                if distance<=72^2 and MG.CanGraphAreaTo(enemy.pos,mex.pos,"Land") then
                    contacts=contacts+1;advanced=advanced or enemy.tier>=2
                    if not nearest or distance<nearest then lastPos,nearest=enemy.pos,distance end
                end
            end)
            if contacts>0 then
                state.mex[mex.unit]={at=now,contacts=contacts,advanced=advanced,pos=GroundCopy(lastPos)}
            end
            local raid=state.mex[mex.unit];local tier=Tier(mex.tp)
            -- Cheap cover for exposed clusters and valuable extractors; a lone
            -- remote T1 spot needs observed pressure or a mature spare economy.
            local isolated=snapshot.alloy and snapshot.alloy.income>=12 and homeDistance>=120^2
            if raid or tier>=2 or cluster>=2 or isolated then
                local b={name="MAIN",base=main}
                if b then
                    local direction=raid and raid.pos or mex.pos
                    local origin=raid and mex.pos or main.position
                    local dx,dz=direction.x-origin.x,direction.z-origin.z
                    local length=math.sqrt(dx*dx+dz*dz)
                    if length>1 then dx,dz=dx/length,dz/length else dx,dz=0,0 end
                    append("mex","mex:"..mex.unit.id.index,b,mex,mex.pos,dx,dz,
                        {active=contacts>0,pressured=raid~=nil,contacts=raid and raid.contacts or 0,
                         valuable=tier>=2 or cluster>=3 and raid~=nil or raid and raid.advanced,
                         cluster=cluster,desired=1,expires=raid and raid.at+180 or now+180})
                end
            end
        end
    end
    -- Keep the existing funded Survival starter, then let observed approaches
    -- choose every later gun. An advanced gun anywhere at MAIN satisfies it.
    if Pressure.SurvivalMap() then
        local present=false
        for _,gun in ipairs(data.guns) do
            if Tier(gun.tp)>=2 and D2(gun.pos,main.position)<=(main.radius or 100)^2 then present=true;break end
        end
        if not present then
            local anchor,distance
            for _,asset in ipairs(data.assets) do
                local d=D2(asset.pos,main.position)
                if IsFactory(asset.tp) and d<=(main.radius or 100)^2 and (not distance or d<distance) then anchor,distance=asset,d end
            end
            if anchor then append("starter","survival:MAIN",{name="MAIN",base=main},anchor,anchor.pos,0,0,
                {valuable=true,desired=1,starter=true}) end
        end
    end
    local histories={}
    for unit,r in pairs(state.mex) do histories[#histories+1]={unit=unit,at=r.at} end
    table.sort(histories,function(a,b) return a.at==b.at and a.unit.id.index<b.unit.id.index or a.at>b.at end)
    for i=65,#histories do state.mex[histories[i].unit]=nil end
    return requests
end
local function GroundEconomy(army,snapshot,objective,tier)
    local a,e=snapshot.alloy,snapshot.energy
    if not a or not e or a.income<(tier==2 and 8 or 3) or e.income<(tier==2 and 100 or 30) then return false end
    local urgent=objective.active or objective.repeated or objective.pressured
    if (snapshot.completeFactories or 0)<(urgent and 1 or 2)
        or a.ratio<(urgent and 0.15 or 0.30) or e.ratio<(urgent and 0.20 or 0.40) then return false end
    if not urgent and (EconomyPolicy.NeedsGroundRecovery(army,snapshot) or EconomyPolicy.AlloyStalled(snapshot)) then return false end
    if objective.kind=="mex" and not urgent and not EconomyPolicy.LandEnabled(army) then return false end
    if objective.starter then
        return tier==2 and (snapshot.landFactories or 0)>=3 and a.income>=25 and e.income>=300
            and e.ratio>=0.65 and Rules.Balance(e)>=0
    end
    return true
end
local function GroundNeed(army,snapshot,objective,tier,plans)
    if not GroundCurrent(army,objective) or not GroundEconomy(army,snapshot,objective,tier) then return false end
    local cover=GroundCoverage(army,snapshot,objective,plans)
    if cover.pending then return false end
    if tier==2 then
        return objective.valuable and cover.advancedPower<(objective.desired or 1)
    end
    return not objective.starter and cover.advanced==0 and cover.t1<(objective.repeated and 2 or 1)
end
local function GroundPriority(objective,tier)
    local priority=objective.kind=="flank" and (objective.active and 9820 or 9710)
        or objective.pressured and 9650 or objective.starter and 9570
        or objective.valuable and 9460 or 9340
    return priority+(tier==2 and 10 or 0)
end
local function GroundChoices(army,snapshot,baseName,tier,except,builder)
    local choices={};local plans=GroundPlans(army,except)
    if plans.active>=2 then return choices end
    local state=GroundState(army);local now=GetGameTimeSeconds()
    for _,request in ipairs(GroundRequests(army,snapshot)) do
        local source=GroundEconomy(army,snapshot,request,tier)
            and GroundSource(army,snapshot,request,tier,builder,baseName)
        if source and source.name==baseName then
            local objective={}
            for key,value in pairs(request) do objective[key]=value end
            objective.baseName,objective.baseRef=source.name,source.base
            objective.home=GroundCopy(source.base.position)
            local key=tostring(baseName)..":"..tier..":"..objective.key
            if now>=(state.blocked[key] or 0) and GroundNeed(army,snapshot,objective,tier,plans) then
                choices[#choices+1]={objective=objective,key=key,priority=GroundPriority(objective,tier)}
            end
        end
    end
    table.sort(choices,function(a,b) return a.priority==b.priority and a.key<b.key or a.priority>b.priority end)
    return choices
end
function GroundDefensePriority(army,snapshot,baseName,tier)
    if not army.ai or army.ai.isAlive==false or not snapshot or tier~=1 and tier~=2 then return nil end
    local best=GroundChoices(army,snapshot,baseName,tier)[1]
    return best and best.priority
end
-- Recruitment and placement must agree on the actual engineer, especially
-- when a base mixes land-only and amphibious builders or captured factions.
function GroundDefenseBuilders(army,baseName,tier,units)
    local snapshot=Rules.CurrentSnapshot(army,false)
    if not snapshot then return {} end
    local choices=GroundChoices(army,snapshot,baseName,tier)
    local eligible={}
    for _,entry in ipairs(GroundBuilders(army,snapshot,tier)) do
        if entry.name==baseName and GroundRecruitable(army,entry) then eligible[entry.unit]=entry end
    end
    local selected,scores={},{}
    for _,u in ipairs(units) do
        local entry=eligible[u]
        if entry then
            local origin=u:GetPosition()
            for _,choice in ipairs(choices) do
                if MG.CanGraphAreaTo(origin,choice.objective.asset.pos,entry.layer) then
                    local distance=D2(origin,choice.objective.asset.pos);local score=scores[u]
                    if not score or choice.priority>score.priority
                        or choice.priority==score.priority and distance<score.distance then
                        scores[u]={priority=choice.priority,distance=distance}
                    end
                end
            end
            if scores[u] then selected[#selected+1]=u end
        end
    end
    table.sort(selected,function(a,b)
        local x,y=scores[a],scores[b]
        if x.priority~=y.priority then return x.priority>y.priority end
        if x.distance~=y.distance then return x.distance<y.distance end
        local at,bt=Tier(a.tp),Tier(b.tp)
        return at==bt and a.id.index<b.id.index or at<bt
    end)
    return selected
end
local function GroundAssignment(platoon,builder,claim)
    return claim and platoon.ai==claim.platoonAI and platoon.army.ai==claim.armyAI
        and claim.armyAI.isAlive~=false and not platoon.dead and not platoon.deleted
        and platoon.army:PlatoonExists(platoon) and Own(platoon.army,builder)
        and not builder.CaptureInProgress and not builder.ReclaimInProgress
        and builder==claim.builder and builder.ai==claim.builderAI and builder.platoon==platoon
        and Finite(claim.started) and GetGameTimeSeconds()>=claim.started and platoon.ai.rushGroundDefense==claim
end
local function GroundSite(platoon,builder,id,objective,pos)
    local tp=Template(id);local protection=tp and Protection(tp,"Land")
    if not protection or not Position(pos) or not GroundCovers(pos,protection,objective) then return false end
    local x,z=pos.x-objective.asset.pos.x,pos.z-objective.asset.pos.z
    -- Stay at the friendly asset's edge; never chase an observed artillery
    -- position. Native exposure still rejects unsupported construction here.
    local forward=objective.kind=="mex" and math.min(6,protection.radius*0.20)
        or objective.asset.half+6
    if x*objective.dx+z*objective.dz>forward then return false end
    local layer=Movement.UnitMovementLayer(builder)
    if not layer or not MG.CanGraphAreaTo(builder:GetPosition(),pos,layer) then return false end
    local enemy=Intel.EnemyThreat(platoon.army,pos,"Land",4,0)
    local friendly=Intel.FriendlyThreat(platoon,pos,48,"Land",false)
    if D2(builder:GetPosition(),pos)<=48^2 then friendly=friendly+math.max(0,AF.GetUnitThreatValueByLayer(builder,"Land",false) or 0) end
    return enemy<=friendly*0.9+1
end
function ValidateGroundDefense(platoon,builder,id,pos)
    local claim=platoon.ai and platoon.ai.rushGroundDefense
    if not GroundAssignment(platoon,builder,claim) or claim.id~=id or not GroundGun(Template(id))
        or not GroundCurrent(platoon.army,claim.objective) then return false end
    -- No yielding path or placement work here. Recheck live assets and other
    -- builders after the queue's route yield, before accepting an unpaid BUILD.
    local snapshot=Rules.CurrentSnapshot(platoon.army);local plans=GroundPlans(platoon.army,platoon)
    return plans.active<2 and snapshot and GroundNeed(platoon.army,snapshot,claim.objective,Tier(Template(id)),plans)
        and GroundSite(platoon,builder,id,claim.objective,pos) or false
end
function FindGroundDefense(platoon,builder,id)
    local army,data=platoon.army,platoon.ai;local tp=Template(id)
    local tier=data and data.formerTable and data.formerTable.RushGroundDefense
    if tier~=1 and tier~=2 or not IsGroundDefenseTemplate(tp,tier) then return false end
    if not Own(army,builder) or builder.CaptureInProgress or builder.ReclaimInProgress
        or builder.platoon~=platoon or not GroundGun(tp) or not R.CanBuilderBuild(builder,id) then return false end
    local snapshot=Rules.CurrentSnapshot(army)
    if not snapshot then return false end
    local choices=GroundChoices(army,snapshot,data.baseName,Tier(tp),platoon,builder)
    -- Prefer short trips among equally urgent objectives. Site failures are
    -- cooled down per objective/tier, without accumulating permanent blacklist.
    local start=GroundCopy(builder:GetPosition())
    table.sort(choices,function(a,b)
        if a.priority~=b.priority then return a.priority>b.priority end
        local da,db=D2(start,a.objective.asset.pos),D2(start,b.objective.asset.pos)
        return da==db and a.key<b.key or da<db
    end)
    for i=1,math.min(4,#choices) do
        local choice=choices[i];local objective=choice.objective
        local claim={armyAI=army.ai,platoonAI=data,builder=builder,builderAI=builder.ai,id=id,objective=objective,started=GetGameTimeSeconds()}
        data.rushGroundDefense=claim
        GroundBlock(army,choice.key)
        local protection=Protection(tp,"Land")
        local radius=objective.kind=="mex" and math.min(28,protection.radius*0.70)
            or math.min(48,objective.asset.half+protection.radius*0.50)
        local pos=Find(army.id,id,GroundCopy(objective.asset.pos),1,nil,radius,
            {{Tags.STRUCTURE*Tags.DEFENCE*Tags.DIRECT_FIRE,8},{Tags.STRUCTURE*Tags.ALLOYS_EXTRACTION,2}},nil,
            {builder=builder,accept=function(candidate)
                return GroundAssignment(platoon,builder,claim) and GroundCurrent(army,objective)
                    and GroundSite(platoon,builder,id,objective,candidate)
            end})
        if not GroundAssignment(platoon,builder,claim) then return false end
        if pos and ValidateGroundDefense(platoon,builder,id,pos) then claim.position=GroundCopy(pos);return pos end
        data.rushGroundDefense=nil
    end
    return false
end

-- Storage is a standing adjacency objective. One queue owns one paid project;
-- completed structures and claimed slots are shared by every source base.
function StorageKind(tp)
    if IsMassStorage(tp) then return "mass" end
    if IsEnergyStorage(tp) then return "energy" end
end
local function StorageData(snapshot)
    snapshot.storageAdjacency=snapshot.storageAdjacency or {mass={},energy={},structures={}}
    return snapshot.storageAdjacency
end
local function StorageAnchorCurrent(army,anchor)
    local u=anchor.unit
    return Own(army,u) and not u.CaptureInProgress and not u.ReclaimInProgress and u:IsCompleted()
        and u.tp==anchor.tp and u.tpId==anchor.id and not R.UpgradeTarget(u)
        and not (u.ai and u.ai.rushUpgradeId) and D2(u:GetPosition(),anchor.pos)<0.01
end
local function StorageState(army)
    local now=GetGameTimeSeconds();local state=army.ai.rushStorageAdjacency
    if not state or now<(state.at or now) then state={blocked={}};army.ai.rushStorageAdjacency=state end
    state.at=now
    for key,expires in pairs(state.blocked) do if now>=expires then state.blocked[key]=nil end end
    return state
end
local function StorageBlock(army,key)
    local state=StorageState(army);state.blocked[key]=GetGameTimeSeconds()+15
    local count,oldest,when=0
    for k,expiry in pairs(state.blocked) do
        count=count+1
        if k~=key and (not when or expiry<when or expiry==when and k<oldest) then oldest,when=k,expiry end
    end
    if count>128 and oldest then state.blocked[oldest]=nil end
end
local function StoragePlans(army,except)
    local plans={active=0,anchors={},positions={}}
    for _,p in pairs(army.platoons or {}) do
        local data=p.ai;local former=data and data.formerTable
        if p~=except and former and former.RushAdjacencyStorage and not p.dead and not p.deleted
            and army:PlatoonExists(p) then
            local live=false
            for _,u in pairs(p:GetUnits()) do
                if Own(army,u) and u.platoon==p and not u.CaptureInProgress and not u.ReclaimInProgress
                    and Has(u.tp,"ENGINEER") then live=true;break end
            end
            local started=data.rushStorageStartup;local now=GetGameTimeSeconds()
            local startup=Finite(started) and now>=started and now-started<=2
            local target=data.buildedUnit
            if (live or startup) and not (Own(army,target) and target:IsCompleted()) then
                plans.active=plans.active+1
                local claim=data.rushAdjacencyStorage
                if claim and claim.armyAI==army.ai and claim.platoonAI==data
                    and Own(army,claim.builder) and claim.builder.platoon==p
                    and claim.builder.ai==claim.builderAI then
                    plans.anchors[claim.anchor.unit]=true
                    local f=R.Footprint(Template(claim.id))
                    if f and Position(claim.position) then
                        plans.positions[#plans.positions+1]={pos=claim.position,x=f.x,z=f.y}
                    end
                end
            end
        end
    end
    return plans
end
function StorageSlotAvailable(army)
    return army and army.ai and army.ai.isAlive~=false and StoragePlans(army).active<2 or false
end
function StorageBudgetOpen(army,builder)
    return army and army.ai and army.ai.isAlive~=false
        and StoragePlans(army,builder and builder.platoon).active==0 or false
end
local function StorageTouch(tp,pos,anchor)
    local f=R.Footprint(tp)
    if not f or not Position(pos) then return false end
    local dx,dz=math.abs(pos.x-anchor.pos.x),math.abs(pos.z-anchor.pos.z)
    return math.abs(dx-(f.x+anchor.x)/2)<0.05 and dz<(f.y+anchor.z)/2-0.05
        or math.abs(dz-(f.y+anchor.z)/2)<0.05 and dx<(f.x+anchor.x)/2-0.05
end
local function StorageGrid(snapshot)
    local data=StorageData(snapshot)
    if data.grid then return data.grid end
    local grid={};data.grid=grid
    for _,r in ipairs(data.structures) do
        for x=math.floor((r.pos.x-r.x/2)/32),math.floor((r.pos.x+r.x/2)/32) do
            for z=math.floor((r.pos.z-r.z/2)/32),math.floor((r.pos.z+r.z/2)/32) do
                local key=x..":"..z;grid[key]=grid[key] or {};grid[key][#grid[key]+1]=r
            end
        end
    end
    return grid
end
local function StorageOpen(army,snapshot,tp,pos,anchor,plans)
    local f=R.Footprint(tp)
    if not StorageAnchorCurrent(army,anchor) or not StorageTouch(tp,pos,anchor)
        or not R.Inside(pos,math.max(f.x,f.y)/2+0.5) then return false end
    local grid=StorageGrid(snapshot);local seen={}
    for x=math.floor((pos.x-f.x/2)/32),math.floor((pos.x+f.x/2)/32) do
        for z=math.floor((pos.z-f.y/2)/32),math.floor((pos.z+f.y/2)/32) do
            for _,r in ipairs(grid[x..":"..z] or {}) do
                if not seen[r] then
                    seen[r]=true
                    if Own(army,r.unit) and Overlap(pos,f.x,f.y,r.pos,r.x,r.z,0) then return false end
                end
            end
        end
    end
    for _,r in ipairs(plans.positions) do if Overlap(pos,f.x,f.y,r.pos,r.x,r.z,0) then return false end end
    return true
end
local function StorageHasSpace(army,snapshot,id,anchor,plans)
    local tp=Template(id);local f=tp and R.Footprint(tp)
    if not f then return false end
    local x0,z0=math.floor(anchor.pos.x-anchor.x/2),math.floor(anchor.pos.z-anchor.z/2)
    for _,d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
        local across=d[1]~=0 and f.y or f.x
        local start=d[1]~=0 and z0 or x0
        local span=d[1]~=0 and anchor.z or anchor.x
        for cross=start+math.min(0,span-across),start+math.max(0,span-across) do
            local p=d[1]~=0 and {x=d[1]>0 and x0+anchor.x+f.x/2 or x0-f.x/2,y=anchor.pos.y,z=cross+f.y/2}
                or {x=cross+f.x/2,y=anchor.pos.y,z=d[2]>0 and z0+anchor.z+f.y/2 or z0-f.y/2}
            if StorageOpen(army,snapshot,tp,p,anchor,plans) then return true end
        end
    end
    return false
end
local function StorageWorkers(army,snapshot,kind)
    local data=StorageData(snapshot);data.workers=data.workers or {}
    if data.workers[kind] then return data.workers[kind] end
    local result={};data.workers[kind]=result
    local former
    for _,f in pairs(army.ai.formerpool or {}) do if f.RushAdjacencyStorage==kind then former=f;break end end
    if not former then return result end
    local ids={}
    for _,line in ipairs(former.WantStructures or {}) do
        for id,on in pairs(line) do
            if on and StorageKind(Template(id))==kind and Has(Template(id),"SCFA_STRUCTURE")
                and R.AllowedTarget(id,false) then ids[#ids+1]=id end
        end
    end
    table.sort(ids)
    local protected=Rules.ProtectedPowerBuilder(army,former)
    for _,u in ipairs(snapshot.balanceEngineers or {}) do
        local entry={unit=u,name=u.assignedToBase,base=army.ai.bases[u.assignedToBase]}
        if u~=protected and GroundRecruitable(army,entry) then
            local layer=Movement.UnitMovementLayer(u);local buildable={}
            if layer then
                for _,id in ipairs(ids) do
                    if R.CanBuilderBuild(u,id) and Rules.CanFundAdjacencyStorage(u,id,snapshot) then buildable[#buildable+1]=id end
                end
            end
            if #buildable>0 then entry.layer,entry.ids=layer,buildable;result[#result+1]=entry end
        end
    end
    return result
end
local function StorageSource(army,snapshot,anchor,kind,builder,baseName,id,plans,blocked)
    local data=StorageData(snapshot);data.sources=data.sources or {}
    local best,distance;local now=GetGameTimeSeconds()
    local function available(entry,assigned)
        local key=kind..":"..anchor.unit.id.index..":"..tostring(entry.name)
        return now>=(blocked[key] or 0) and (assigned or GroundRecruitable(army,entry))
    end
    local function consider(entry,assigned)
        if available(entry,assigned) and Position(entry.unit:GetPosition()) then
            local p=entry.unit:GetPosition();local d=D2(p,anchor.pos)
            if (not distance or d<distance or d==distance and entry.unit.id.index<best.unit.id.index)
                and MG.CanGraphAreaTo(p,anchor.pos,entry.layer) then
                for _,storageId in ipairs(entry.ids) do
                    if StorageHasSpace(army,snapshot,storageId,anchor,plans) then best,distance=entry,d;break end
                end
            end
        end
    end
    if builder then
        local base=army.ai.bases[baseName];local layer=Movement.UnitMovementLayer(builder)
        if base and layer and Own(army,builder) and R.CanBuilderBuild(builder,id) then
            consider({unit=builder,name=baseName,base=base,layer=layer,ids={id}},true)
        end
    else
        local cached=data.sources[anchor.unit]
        if cached and available(cached,false) then
            for _,storageId in ipairs(cached.ids) do
                if StorageHasSpace(army,snapshot,storageId,anchor,plans) then return cached end
            end
        end
        for _,entry in ipairs(StorageWorkers(army,snapshot,kind)) do consider(entry,false) end
        data.sources[anchor.unit]=best or false
    end
    return best
end
local function StorageValue(snapshot,kind,anchor)
    local tier=Tier(anchor.tp)
    if kind=="energy" then
        local need=snapshot.techPowerNeeded or EconomyPolicy.NeedsPower(snapshot)
        return (need and 9600 or 9510)+(tier==3 and 10 or 0)
    end
    return tier>=2 and 9560+(tier==3 and 10 or 0) or 9460
end
local function StorageChoices(army,snapshot,baseName,kind,except,builder,id)
    local result={};local plans=StoragePlans(army,except)
    if plans.active>=2 or not MG.IsMarkerGridPresent() then return result,plans end
    local state=StorageState(army);local now=GetGameTimeSeconds()
    for _,anchor in ipairs(StorageData(snapshot)[kind] or {}) do
        local key=kind..":"..anchor.unit.id.index..":"..tostring(baseName)
        if not plans.anchors[anchor.unit] and now>=(state.blocked[key] or 0) and StorageAnchorCurrent(army,anchor) then
            local source=StorageSource(army,snapshot,anchor,kind,builder,baseName,id,plans,state.blocked)
            if source and source.name==baseName then
                for _,storageId in ipairs(source.ids) do
                    if StorageHasSpace(army,snapshot,storageId,anchor,plans) then
                        result[#result+1]={anchor=anchor,source=source,key=key,priority=StorageValue(snapshot,kind,anchor)}
                        break
                    end
                end
            end
        end
    end
    table.sort(result,function(a,b)
        if a.priority~=b.priority then return a.priority>b.priority end
        local da,db=D2(a.source.unit:GetPosition(),a.anchor.pos),D2(b.source.unit:GetPosition(),b.anchor.pos)
        return da==db and a.anchor.unit.id.index<b.anchor.unit.id.index or da<db
    end)
    return result,plans
end
function StoragePriority(army,snapshot,baseName,kind)
    if not army or not army.ai or not snapshot or army.ai.isAlive==false
        or kind~="mass" and kind~="energy" then return nil end
    local first=StorageChoices(army,snapshot,baseName,kind)[1]
    return first and first.priority
end
function StorageBuilders(army,baseName,kind,units)
    local snapshot=Rules.CurrentSnapshot(army,false)
    if not snapshot then return {} end
    local choices,plans=StorageChoices(army,snapshot,baseName,kind)
    local eligible,scores,result={},{},{}
    for _,entry in ipairs(StorageWorkers(army,snapshot,kind)) do
        if entry.name==baseName and GroundRecruitable(army,entry) then eligible[entry.unit]=entry end
    end
    for _,u in ipairs(units or {}) do
        local entry=eligible[u]
        if entry then
            for _,choice in ipairs(choices) do
                if MG.CanGraphAreaTo(u:GetPosition(),choice.anchor.pos,entry.layer) then
                    for _,storageId in ipairs(entry.ids) do
                        if StorageHasSpace(army,snapshot,storageId,choice.anchor,plans) then
                            local d=D2(u:GetPosition(),choice.anchor.pos);local old=scores[u]
                            if not old or choice.priority>old.priority or choice.priority==old.priority and d<old.distance then
                                scores[u]={priority=choice.priority,distance=d}
                            end
                            break
                        end
                    end
                end
            end
            if scores[u] then result[#result+1]=u end
        end
    end
    table.sort(result,function(a,b)
        local x,y=scores[a],scores[b]
        if x.priority~=y.priority then return x.priority>y.priority end
        if x.distance~=y.distance then return x.distance<y.distance end
        return Tier(a.tp)==Tier(b.tp) and a.id.index<b.id.index or Tier(a.tp)<Tier(b.tp)
    end)
    return result
end
local function StorageAssignment(platoon,builder,claim)
    return claim and platoon.ai==claim.platoonAI and platoon.army.ai==claim.armyAI
        and claim.armyAI.isAlive~=false and not platoon.dead and not platoon.deleted
        and platoon.army:PlatoonExists(platoon) and Own(platoon.army,builder)
        and not builder.CaptureInProgress and not builder.ReclaimInProgress
        and claim.builder==builder and claim.builderAI==builder.ai and builder.platoon==platoon
        and platoon.ai.rushAdjacencyStorage==claim and Finite(claim.started) and GetGameTimeSeconds()>=claim.started
        and platoon.army.ai.bases[claim.baseName]==claim.baseRef and claim.baseRef.baseType~="NAVAL"
        and Position(claim.baseRef.position) and D2(claim.baseRef.position,claim.home)<0.01
        and StorageAnchorCurrent(platoon.army,claim.anchor)
end
local function StorageSite(platoon,builder,id,anchor,pos)
    if not StorageTouch(Template(id),pos,anchor) then return false end
    local layer=Movement.UnitMovementLayer(builder)
    if not layer or not MG.CanGraphAreaTo(builder:GetPosition(),pos,layer) then return false end
    local enemy=Intel.EnemyThreat(platoon.army,pos,"Land",4,0)
    local friendly=Intel.FriendlyThreat(platoon,pos,48,"Land",false)
    if D2(builder:GetPosition(),pos)<=48^2 then friendly=friendly+math.max(0,AF.GetUnitThreatValueByLayer(builder,"Land",false) or 0) end
    return enemy<=friendly*0.9+1
end
function ValidateStorage(platoon,builder,id,pos)
    local claim=platoon.ai and platoon.ai.rushAdjacencyStorage
    if not StorageAssignment(platoon,builder,claim) or claim.id~=id or not Position(pos)
        or claim.position and D2(pos,claim.position)>0.01
        or not R.CanBuilderBuild(builder,id) or not Rules.CanFundAdjacencyStorage(builder,id) then return false end
    local snapshot=Rules.CurrentSnapshot(platoon.army);local plans=StoragePlans(platoon.army,platoon)
    local valid=snapshot and plans.active<2 and not plans.anchors[claim.anchor.unit]
        and StorageOpen(platoon.army,snapshot,Template(id),pos,claim.anchor,plans)
        and StorageSite(platoon,builder,id,claim.anchor,pos)
        and AF.CanBuildStructureAt(platoon.army.id,id,pos,0)==true or false
    if not valid then StorageBlock(platoon.army,claim.key) end
    return valid
end
function FindStorage(platoon,builder,id)
    local army,data=platoon.army,platoon.ai;local tp=Template(id)
    local kind=data and data.formerTable and data.formerTable.RushAdjacencyStorage
    if kind~=StorageKind(tp) or not Has(tp,"SCFA_STRUCTURE") or not Own(army,builder)
        or builder.platoon~=platoon or builder.CaptureInProgress or builder.ReclaimInProgress
        or not R.CanBuilderBuild(builder,id) then return false end
    local snapshot=Rules.CurrentSnapshot(army)
    if not snapshot then return false end
    local choices=StorageChoices(army,snapshot,data.baseName,kind,platoon,builder,id)
    for i=1,math.min(4,#choices) do
        local choice=choices[i];local anchor=choice.anchor
        local claim={armyAI=army.ai,platoonAI=data,builder=builder,builderAI=builder.ai,id=id,anchor=anchor,
            started=GetGameTimeSeconds(),key=choice.key,baseName=data.baseName,baseRef=army.ai.bases[data.baseName],
            home=GroundCopy(army.ai.bases[data.baseName].position)}
        data.rushAdjacencyStorage=claim;StorageBlock(army,choice.key)
        local f=R.Footprint(tp);local radius=math.sqrt(anchor.x^2+anchor.z^2)/2+math.max(f.x,f.y)+2
        local pos=Find(army.id,id,GroundCopy(anchor.pos),0,nil,radius,nil,false,
            {builder=builder,adjacentOnly=true,accept=function(candidate)
                return StorageAssignment(platoon,builder,claim) and StorageSite(platoon,builder,id,anchor,candidate)
            end})
        if not StorageAssignment(platoon,builder,claim) then return false end
        if pos and ValidateStorage(platoon,builder,id,pos) then
            claim.position=GroundCopy(pos);StorageState(army).blocked[choice.key]=nil
            return pos
        end
        data.rushAdjacencyStorage=nil
    end
    return false
end

-- Called from the controller's existing owned-unit census; no second army scan.
function ObserveDefenseAsset(snapshot,unit)
    if not Has(unit.tp,"STRUCTURE") or unit.CaptureInProgress or unit.ReclaimInProgress then return end
    local complete=unit:IsCompleted()
    local factory,extractor=IsFactory(unit.tp),IsExtractor(unit.tp)
    local gun=GroundGun(unit.tp)
    local position=unit:GetPosition()
    if not Position(position) then return end
    local footprint=R.Footprint(unit.tp)
    if footprint then
        local storage=StorageData(snapshot)
        local record={unit=unit,tp=unit.tp,id=unit.tpId,pos=GroundCopy(position),x=footprint.x,z=footprint.y}
        storage.structures[#storage.structures+1]=record
        if complete and Has(unit.tp,"SCFA_STRUCTURE") then
            if extractor then storage.mass[#storage.mass+1]=record
            elseif IsGenerator(unit.tp) and (Tier(unit.tp)==2 or Tier(unit.tp)==3) then storage.energy[#storage.energy+1]=record end
        end
    end
    if Has(unit.tp,"SHIELD") and Protection(unit.tp) then
        snapshot.defenseShields=snapshot.defenseShields or {}
        snapshot.defenseShields[#snapshot.defenseShields+1]={unit=unit,army=unit.army,tp=unit.tp,
            pos=GroundCopy(position),protection=Protection(unit.tp)}
    end
    if not complete and not gun then return end
    if gun or complete and (factory or extractor or IsEnergyProducer(unit.tp)) then
        local f=R.Footprint(unit.tp)
        if f then
            local record={unit=unit,tp=unit.tp,pos=GroundCopy(position),half=math.sqrt(f.x*f.x+f.y*f.y)/2}
            local ground=GroundData(snapshot)
            if gun then
                record.protection=Protection(unit.tp,"Land");ground.guns[#ground.guns+1]=record
            else ground.assets[#ground.assets+1]=record end
            if extractor then ground.extractors[#ground.extractors+1]=record end
        end
    end
    if not complete then return end
    local important=Tier(unit.tp)>=2 and (factory or IsEnergyProducer(unit.tp) or extractor or Has(unit.tp,"ARTILLERY"))
    if not factory and not extractor and not important and not Has(unit.tp,"SHIELD") then return end
    local bases=unit.army.ai.bases
    local name=unit.assignedToBase
    local base=name and bases[name]
    if not base or not Position(base.position) or not Finite(base.radius)
        or D2(position,base.position)>base.radius^2 then
        if not snapshot.defenseBases then
            snapshot.defenseBases={}
            for key,b in pairs(bases) do
                if Position(b.position) and Finite(b.radius) then
                    snapshot.defenseBases[#snapshot.defenseBases+1]={name=key,base=b}
                end
            end
            table.sort(snapshot.defenseBases,function(a,b) return tostring(a.name)<tostring(b.name) end)
        end
        name=nil
        local distance
        for _,entry in ipairs(snapshot.defenseBases) do
            local d=D2(position,entry.base.position)
            if d<=entry.base.radius^2 and (not distance or d<distance) then name,distance=entry.name,d end
        end
    end
    if not name then return end
    snapshot.baseDefenseAssets=snapshot.baseDefenseAssets or {}
    local assets=snapshot.baseDefenseAssets[name]
    if not assets then
        assets={factories=0,advanced=0,extractors=0,targets={}}
        snapshot.baseDefenseAssets[name]=assets
    end
    if factory then assets.factories=assets.factories+1 end
    if extractor then assets.extractors=assets.extractors+1 end
    if important then assets.advanced=assets.advanced+1 end
    local f=R.Footprint(unit.tp)
    if f and (factory or important) then
        assets.targets[#assets.targets+1]={unit=unit,tp=unit.tp,pos=GroundCopy(position),
            half=math.sqrt(f.x*f.x+f.y*f.y)/2}
    end
end
local function ShieldUpkeep(tp)
    local amount=Table(Table(tp and tp.economy).maintenanceConsumption).energy
    return Finite(amount) and math.max(0,amount) or 0
end
function IsEmergencyShieldTemplate(tp)
    return (Has(tp,"STRUCTURE") or Has(tp,"SCFA_STRUCTURE")) and Has(tp,"SHIELD")
        and (Rules.Tier(tp)==2 or Rules.Tier(tp)==3) and Protection(tp)~=nil
end
local function ShieldQueueCurrent(army,p,data,q,allowSuspended)
    if not q or q.army~=army or q.armyAI~=army.ai or q.platoon~=p or q.platoonAI~=data
        or data.rushConstructionQueue~=q or q.suspended and not allowSuspended then return false end
    for _,w in ipairs(q.workers or {}) do
        local u=w.unit;local orders=u and u.orders or {}
        if Own(army,u) and u.platoon==p and u.ai==w.unitAI and w.unitAI.rushConstructionQueue==w
            and w.queue==q and w.platoonAI==data then
            local owned=not orders.activeOrder or w.orders[orders.activeOrder]
            for _,order in pairs(orders.queuedOrders or {}) do if not w.orders[order] then owned=false;break end end
            if owned then return true end
        end
    end
    return false
end
local function ShieldProjectTarget(builder,id)
    local q=builder and builder.platoon and builder.platoon.ai and builder.platoon.ai.rushConstructionQueue
    local head=q and q.entries and q.entries[1]
    local target=head and head.id==id and head.target or builder and builder.unitBeingBuilt
    return Own(builder and builder.army,target) and target.tpId==id and not target:IsCompleted() and target or nil
end
local function ShieldRecords(army,snapshot,except,exceptTarget)
    local records,seen,projects={},{},{}
    local main=army.ai.bases.MAIN
    local function atMain(pos) return main and Position(pos) and D2(pos,main.position)<=main.radius^2 end
    local function add(record)
        if exceptTarget and record.unit==exceptTarget or not Position(record.pos) or not record.protection then return end
        local key=math.floor(record.pos.x*2+0.5)..":"..math.floor(record.pos.z*2+0.5)
        if seen[key] then return end
        seen[key]=true;records[#records+1]=record
    end
    for _,record in ipairs(snapshot.defenseShields or {}) do
        if Own(army,record.unit) then
            local entity=record.unit.resourceEntities and record.unit.resourceEntities.construction
            if not record.unit:IsPlacementGhost() or record.unit.hasBeenPromotedFromPlacementGhost
                or entity and next(entity.buildPowerSources or {}) then add(record) end
            if not record.unit:IsCompleted() and entity and next(entity.buildPowerSources or {})
                and record.unit~=exceptTarget and atMain(record.pos) then projects[record.unit]=true end
        end
    end
    for _,p in pairs(army.platoons or {}) do
        local data=p.ai
        if p~=except and data and p.army==army and not p.dead and not p.deleted and army:PlatoonExists(p) then
            local q=data.rushConstructionQueue;local current=ShieldQueueCurrent(army,p,data,q)
            if current then
                local hasShield=false
                for _,entry in ipairs(q.entries or {}) do
                    local tp=Template(entry.id);local protection=Protection(tp)
                    if Has(tp,"SHIELD") and protection then
                        hasShield=hasShield or atMain(entry.position)
                        add({tp=tp,pos=entry.position,protection=protection,pending=true})
                    end
                end
                if hasShield then projects[p]=true end
            end
            local claim=data.rushEmergencyShield
            local source=claim and claim.builder
            if claim and claim.armyAI==army.ai and claim.platoonAI==data and Own(army,source)
                and source.platoon==p and source.ai==claim.builderAI and army.ai.bases.MAIN==claim.baseRef then
                local tp=Template(claim.id)
                add({tp=tp,pos=claim.position,protection=Protection(tp),pending=true})
                projects[p]=true
            elseif not q and Has(Template(data.nextBuildingtpId),"SHIELD") and Position(data.placeToBuild) then
                -- A native legacy shield plan also reserves its future bubble.
                for _,u in ipairs(p:GetUnits()) do
                    if Own(army,u) and u.platoon==p and u.ai and u.ai.eState~="Disband" then
                        local tp=Template(data.nextBuildingtpId)
                        add({tp=tp,pos=data.placeToBuild,protection=Protection(tp),pending=true})
                        if atMain(data.placeToBuild) then projects[p]=true end
                        break
                    end
                end
            end
        end
    end
    local pending,upkeep=0,0
    for _,record in ipairs(records) do
        if not record.unit or not record.unit:IsCompleted() then upkeep=upkeep+ShieldUpkeep(record.tp) end
    end
    -- A foundation and its lead are one project, even with several assistants.
    local count={}
    for key in pairs(projects) do
        local queue=key.ai and key.ai.rushConstructionQueue
        local target=queue and queue.entries and queue.entries[1]
        target=target and target.target or key.ai and key.ai.buildedUnit
        count[Own(army,target) and target or key]=true
    end
    for _ in pairs(count) do pending=pending+1 end
    return records,pending,upkeep
end
EmergencyShieldView=function(army,snapshot,except,exceptTarget)
    local main=army and army.ai and army.ai.bases and army.ai.bases.MAIN
    if not main or not snapshot or not Position(main.position) or not Finite(main.radius)
        or main.radius<=0 or army.ai.isAlive==false then return nil end
    local alarm=Frontline.MainAlarm(army)
    if not alarm.bombardment or alarm.baseRef~=main then return nil end
    local assets=snapshot.baseDefenseAssets and snapshot.baseDefenseAssets.MAIN
    if not assets then return nil end
    local records,pending,upkeep=ShieldRecords(army,snapshot,except,exceptTarget)
    local result={base=main,alarm=alarm,assets={},pending=pending,upkeep=upkeep,needs=false}
    for _,target in ipairs(assets.targets or {}) do
        if Own(army,target.unit) and target.unit:IsCompleted() and D2(target.unit:GetPosition(),main.position)<=main.radius^2 then
            local physical,live,completed=0,0,0
            for _,record in ipairs(records) do
                local present,working,finished=ShieldCoverage(record,target)
                if present then physical=physical+1 end
                if working then live=live+1 end
                if finished then completed=completed+1 end
            end
            local hit=false
            for _,damage in ipairs(alarm.damagedAssets or {}) do
                if damage.unit==target.unit then hit=true;break end
                if Own(army,damage.unit) and Has(damage.unit.tp,"SHIELD") then
                    local cover=ShieldCoverage({army=army,unit=damage.unit,tp=damage.unit.tp,pos=damage.pos},target)
                    if cover then hit=true;break end
                end
            end
            local desired=(hit or completed>0 and live==0) and 2 or 1
            local value=1+math.sqrt(math.max(0,tonumber(Table(Table(target.tp.economy).cost).alloys) or 0))
            local uncovered=physical<desired
            result.assets[#result.assets+1]={unit=target.unit,pos=target.pos,half=target.half,
                value=value*(uncovered and (hit and 3 or 1) or 0.10),uncovered=uncovered}
            result.needs=result.needs or uncovered
        end
    end
    return result
end
function EmergencyShieldPriority(army,snapshot,baseName)
    if baseName~="MAIN" then return nil end
    local view=EmergencyShieldView(army,snapshot)
    return view and view.needs and view.pending<2 and 9910 or nil
end
local function EmergencyShieldFunding(builder,id,snapshot,view)
    local army=builder and builder.army;local tp=Template(id)
    if not Own(army,builder) or not IsEmergencyShieldTemplate(tp) or not R.AllowedTarget(id,false)
        or not R.CanBuilderBuild(builder,id) or army.economy and army.economy.isEnergyDown then return false end
    if view then
        -- Only the non-yielding idle recruitment pass shares this local view.
        -- Public selection/issue-time calls always rebuild current commitments.
        if not snapshot or not GroundIdle(army,builder) or view.base~=army.ai.bases.MAIN then return false end
    else
        view=EmergencyShieldView(army,snapshot or Rules.CurrentSnapshot(army,false),builder.platoon,ShieldProjectTarget(builder,id))
    end
    if not view or not view.needs or view.pending>=2
        or builder:GetHealth()<math.max(1,builder:GetMaxHealth())*0.60 then return false end
    local mass,energy,duration=Rules.ProjectRates(builder,id)
    if not mass or not Finite(duration) or duration<=0 then return false end
    local a,e
    if snapshot then a,e=snapshot.alloy,snapshot.energy else a,e=Rules.Resources(army,builder) end
    if not a or not e or a.income<=0 or e.income<=0 or a.ratio<0.10 or e.ratio<0.20 then return false end
    local upkeep=view.upkeep+ShieldUpkeep(tp)
    return Rules.Balance(e)>=upkeep
        and Rules.Balance(a)+math.max(0,a.current-a.storage*0.15)/duration>=mass
        and Rules.Balance(e)+math.max(0,e.current-e.storage*0.20)/duration>=energy+upkeep
end
function CanFundEmergencyShield(builder,id,snapshot)
    return EmergencyShieldFunding(builder,id,snapshot)
end
function EmergencyShieldPreference(tp)
    local best=0
    for _,shield in ipairs(Table(Table(tp and tp.defence).shields)) do
        local protection=BubbleProtection(shield)
        local health=tonumber(shield.max)
        if protection then best=math.max(best,protection.radius^2*math.sqrt(Finite(health) and math.max(1,health) or 1)) end
    end
    return best
end
function EmergencyShieldBuilders(army,baseName,units)
    if baseName~="MAIN" then return {} end
    local snapshot=Rules.CurrentSnapshot(army,false)
    local view=EmergencyShieldView(army,snapshot)
    if not view or not view.needs or view.pending>=2 then return {} end
    local former
    for _,f in pairs(army.ai.formerpool or {}) do if f.RushEmergencyShield then former=f;break end end
    if not former then return {} end
    local selected,scores={},{}
    for _,builder in ipairs(units or {}) do
        if GroundIdle(army,builder) and builder.assignedToBase=="MAIN"
            and D2(builder:GetPosition(),view.base.position)<=view.base.radius^2 then
            local score={preference=0,duration=math.huge,distance=math.huge}
            for _,line in ipairs(former.WantStructures or {}) do for id,on in pairs(line) do
                local tp=on and Template(id)
                if IsEmergencyShieldTemplate(tp) and EmergencyShieldFunding(builder,id,snapshot,view) then
                    local preference=EmergencyShieldPreference(tp)
                    local _,_,duration=Rules.ProjectRates(builder,id)
                    if preference>score.preference or preference==score.preference and duration<score.duration then
                        score.preference,score.duration=preference,duration
                    end
                end
            end end
            if score.preference>0 then
                for _,asset in ipairs(view.assets) do
                    if asset.uncovered then score.distance=math.min(score.distance,D2(builder:GetPosition(),asset.pos)) end
                end
                scores[builder]=score;selected[#selected+1]=builder
            end
        end
    end
    table.sort(selected,function(a,b)
        local x,y=scores[a],scores[b]
        if x.preference~=y.preference then return x.preference>y.preference end
        if x.duration~=y.duration then return x.duration<y.duration end
        return x.distance==y.distance and a.id.index<b.id.index or x.distance<y.distance
    end)
    return selected
end
function EmergencyShieldPowerNeed(army,snapshot)
    local view=EmergencyShieldView(army,snapshot)
    if not view or not view.needs or view.pending>=2 then return 0 end
    local former
    for _,f in pairs(army.ai.formerpool or {}) do if f.RushEmergencyShield then former=f;break end end
    if not former then return 0 end
    local best
    for _,builder in ipairs(snapshot.balanceEngineers or {}) do
        if GroundIdle(army,builder) and builder:GetHealth()>=math.max(1,builder:GetMaxHealth())*0.60
            and builder.assignedToBase=="MAIN"
            and D2(builder:GetPosition(),view.base.position)<=view.base.radius^2 then
            for _,line in ipairs(former.WantStructures or {}) do for id,on in pairs(line) do
                local tp=on and Template(id)
                if IsEmergencyShieldTemplate(tp) and R.AllowedTarget(id,false) and R.CanBuilderBuild(builder,id) then
                    local mass,energy,duration=Rules.ProjectRates(builder,id)
                    if mass and duration>0 then
                        local headroom=energy+ShieldUpkeep(tp)+view.upkeep
                        if not best or headroom<best then best=headroom end
                    end
                end
            end end
        end
    end
    return best or 0
end
function EmergencyShieldThreat(army,pos)
    local alarm=Frontline.MainAlarm(army);local main=army.ai and army.ai.bases and army.ai.bases.MAIN
    local remote=alarm.bombardment and alarm.baseRef==main and main and Position(pos)
        and Finite(main.radius) and D2(pos,main.position)<=math.min(160,main.radius)^2
    return Intel.EnemyThreat(army,pos,"Land",4,0,remote and function(unit,position)
        return Frontline.IsStrategicArtillery(unit) and D2(pos,position)>128^2
    end or nil)
end
local function ShieldAssignment(platoon,builder,claim)
    return claim and platoon.ai==claim.platoonAI and platoon.army.ai==claim.armyAI
        and claim.armyAI.isAlive~=false and not platoon.dead and not platoon.deleted
        and platoon.army:PlatoonExists(platoon) and Own(platoon.army,builder)
        and builder.platoon==platoon and builder.ai==claim.builderAI and claim.builder==builder
        and platoon.ai.rushEmergencyShield==claim and platoon.army.ai.bases.MAIN==claim.baseRef
        and D2(claim.baseRef.position,claim.home)<1
end
local function ShieldSite(platoon,builder,pos)
    local main=platoon.army.ai.bases.MAIN
    if not Position(pos) or D2(pos,main.position)>math.min(160,main.radius)^2 then return false end
    local start=builder:GetPosition();local reach=builder.construction and builder.construction.range
    if not (Finite(reach) and reach>0.5 and D2(start,pos)<=(reach-0.5)^2)
        and not MG.CanGraphAreaTo(start,pos,Movement.UnitMovementLayer(builder)) then return false end
    local enemy=EmergencyShieldThreat(platoon.army,pos)
    local friendly=Intel.FriendlyThreat(platoon,pos,48,"Land",false)
    if D2(start,pos)<=48^2 then friendly=friendly+math.max(0,AF.GetUnitThreatValueByLayer(builder,"Land",false) or 0) end
    return enemy<=friendly*0.9+1
end
function ValidateEmergencyShield(platoon,builder,id,pos)
    local claim=platoon.ai and platoon.ai.rushEmergencyShield
    if not ShieldAssignment(platoon,builder,claim) or claim.id~=id or not Position(pos) then return false end
    local target=ShieldProjectTarget(builder,id)
    if target and target.hasBeenPromotedFromPlacementGhost and D2(target:GetPosition(),pos)<1 then return true end
    local view=EmergencyShieldView(platoon.army,Rules.CurrentSnapshot(platoon.army),platoon,target)
    if not view or not view.needs or view.pending>=2 or not CanFundEmergencyShield(builder,id)
        or not ShieldSite(platoon,builder,pos) then return false end
    local protection=Protection(Template(id))
    for _,asset in ipairs(view.assets) do if asset.uncovered and Covers(pos,protection,asset) then return true end end
    return false
end
function FindEmergencyShield(platoon,builder,id)
    local army,data=platoon.army,platoon.ai;local main=army.ai.bases.MAIN
    if not main or data.baseName~="MAIN" or not CanFundEmergencyShield(builder,id) then return false end
    local claim={armyAI=army.ai,platoonAI=data,builder=builder,builderAI=builder.ai,id=id,
        baseRef=main,home=GroundCopy(main.position)}
    data.rushEmergencyShield=claim
    local pos=Find(army.id,id,GroundCopy(main.position),1,nil,math.min(160,main.radius),nil,false,
        {builder=builder,exceptPlatoon=platoon,emergencyShield=true,accept=function(candidate)
            return ShieldAssignment(platoon,builder,claim) and ShieldSite(platoon,builder,candidate)
        end})
    if pos and ShieldAssignment(platoon,builder,claim) and ValidateEmergencyShield(platoon,builder,id,pos) then
        claim.position=GroundCopy(pos);return pos
    end
    if data.rushEmergencyShield==claim then data.rushEmergencyShield=nil end
    return false
end
function EmergencyShieldRoute(platoon,builder,pos,escaping)
    local claim=platoon.ai and platoon.ai.rushEmergencyShield
    if not ShieldAssignment(platoon,builder,claim) or not ShieldSite(platoon,builder,pos) then return false end
    local budget=Import("AI/mods/AI-Scom/RushPathBudget.lua")
    if not (escaping and budget.Recovery(builder) or not escaping and budget.Extra(platoon)) then return false end
    local start=GroundCopy(builder:GetPosition());local layer=Movement.UnitMovementLayer(builder)
    local path=Movement.CopyPath(MG.GeneratePathTo(platoon.army.id,start,GroundCopy(pos),layer,true,math.huge))
    if not ShieldAssignment(platoon,builder,claim) or #path==0 or #path>48 then return false end
    local previous=start;local main=claim.baseRef
    for _,node in ipairs(path) do
        local midpoint={x=(previous.x+node.x)*0.5,y=(previous.y+node.y)*0.5,z=(previous.z+node.z)*0.5}
        if D2(node,main.position)>math.min(160,main.radius)^2 then return false end
        local radius=math.sqrt(D2(previous,node))*0.5+4
        local alarm=Frontline.MainAlarm(platoon.army)
        local enemy=Intel.EnemyThreat(platoon.army,midpoint,"Land",radius,0,alarm.bombardment and function(unit,position)
            return Frontline.IsStrategicArtillery(unit) and D2(midpoint,position)>(128+radius)^2
        end or nil)
        if enemy>Intel.FriendlyThreat(platoon,midpoint,48,"Land",false)*0.9+1 then return false end
        previous=node
    end
    return ShieldAssignment(platoon,builder,claim) and path or false
end
local function BuilderShieldAsset(builder,pos,margin)
    local footprint=R.Footprint(builder.tp)
    if not footprint or not Position(pos) then return nil end
    local collision=Table(Table(builder.tp.collisionInfo).collisionSize)
    local x=math.max(footprint.x,Finite(collision.x) and collision.x or 0)
    local z=math.max(footprint.y,Finite(collision.z) and collision.z or 0)
    return {pos=GroundCopy(pos),half=math.sqrt(x^2+z^2)/2+(margin or 0)}
end
local function ActiveBuilderCover(builder,pos,margin)
    local army=builder.army;local asset=BuilderShieldAsset(builder,pos,margin)
    local snapshot=asset and Rules.CurrentSnapshot(army,false)
    if not snapshot then return false end
    for _,record in ipairs(snapshot.defenseShields or {}) do
        if Own(army,record.unit) and record.unit:IsCompleted() then
            local _,working=ShieldCoverage(record,asset)
            if working then return true end
        end
    end
    return false
end
function EmergencyShieldSafeToResume(builder,site)
    if not Own(builder and builder.army,builder) then return false end
    if not Frontline.MainAlarm(builder.army).bombardment
        or builder:GetHealth()>=math.max(1,builder:GetMaxHealth())*0.60 then return true end
    local reach=builder.construction and builder.construction.range
    if not Position(site) or not Finite(reach) or reach<=0.5 then return false end
    local pos=builder:GetPosition()
    if D2(pos,site)<=(reach-0.5)^2 and ActiveBuilderCover(builder,pos) then return true end
    -- Native BUILD chooses its own standing point. Requiring the entire build
    -- reach disk to fit avoids claiming that a covered foundation covers its lead.
    return ActiveBuilderCover(builder,site,reach)
end
function EmergencyShieldEscape(platoon,builder,impact,site)
    local army,data=platoon.army,platoon.ai
    local claim=data and data.rushEmergencyShield
    if not claim and data and data.formerTable and data.formerTable.RushEmergencyShield
        and data.baseName=="MAIN" and ShieldQueueCurrent(army,platoon,data,data.rushConstructionQueue,true) then
        -- A hit may arrive before the first site is selected. The live worker
        -- still needs an owned escape, without inventing a construction target.
        local main=army.ai.bases.MAIN
        if main and Position(main.position) and Finite(main.radius) and Own(army,builder)
            and builder.platoon==platoon then
            claim={armyAI=army.ai,platoonAI=data,builder=builder,builderAI=builder.ai,
                baseRef=main,home=GroundCopy(main.position)}
            data.rushEmergencyShield=claim
        end
    end
    if not ShieldAssignment(platoon,builder,claim) then return false end
    local origin=GroundCopy(builder:GetPosition());local asset=BuilderShieldAsset(builder,origin)
    if not asset then return false end
    if ActiveBuilderCover(builder,origin) then return false end
    local snapshot=Rules.CurrentSnapshot(army,false);local candidates,seen={},{}
    local originRisk=EmergencyShieldThreat(army,origin)
    local function add(pos,shield,protection)
        if not Position(pos) then return end
        local ground=SnapToGround(GroundCopy(pos))
        if not Position(ground) then return end
        pos=GroundCopy(ground)
        if D2(pos,origin)<12^2 or D2(pos,origin)>128^2
            or D2(pos,claim.home)>math.min(160,claim.baseRef.radius)^2 then return end
        local key=math.floor(pos.x*2)..":"..math.floor(pos.z*2)
        if seen[key] then return end
        seen[key]=true
        local cover=shield and Own(army,shield.owner) and not shield.deleted and shield:IsEnabled() and shield:GetHealth()>0
            and Covers(shield:GetPosition(),protection,BuilderShieldAsset(builder,pos))
        if shield and not cover or not cover and EmergencyShieldThreat(army,pos)>originRisk then return end
        if not Intel.ClearRendezvous(army,pos,asset.half+1) or not ShieldSite(platoon,builder,pos) then return end
        local distance=D2(pos,origin)
        local away=Position(impact) and math.min(48^2,D2(pos,impact)) or 0
        local work=Position(site) and math.min(48^2,D2(pos,site)) or 0
        candidates[#candidates+1]={pos=pos,shield=shield,protection=protection,cover=cover==true,
            score=distance-away*0.25-work*0.15+D2(pos,claim.home)*0.05}
    end
    for _,record in ipairs(snapshot and snapshot.defenseShields or {}) do
        local unit=record.unit
        if Own(army,unit) and unit:IsCompleted() and D2(record.pos,origin)<=128^2 then
            for _,shield in ipairs(unit.shields or {}) do
                local protection=not shield.deleted and shield:IsEnabled() and shield:GetHealth()>0
                    and BubbleProtection(shield.tp,true)
                local center=protection and shield:GetPosition()
                if Position(center) then
                    center=GroundCopy(center)
                    local radius=math.max(0,protection.radius-asset.half-2)*0.65
                    if radius>asset.half+2 then
                        for i=0,7 do
                            local angle=i*math.pi/4
                            add({x=center.x+math.cos(angle)*radius,y=center.y,z=center.z+math.sin(angle)*radius},shield,protection)
                        end
                    end
                end
            end
        end
    end
    -- Zero discounted threat supplies no gradient. A legal lateral displacement
    -- can still evade the last impact; it never counts as protective coverage.
    for i=0,7 do
        local angle=i*math.pi/4
        add({x=origin.x+math.cos(angle)*32,y=origin.y,z=origin.z+math.sin(angle)*32})
    end
    table.sort(candidates,function(a,b)
        if a.cover~=b.cover then return a.cover end
        if a.score~=b.score then return a.score<b.score end
        return a.pos.x==b.pos.x and a.pos.z<b.pos.z or a.pos.x<b.pos.x
    end)
    local covered,lateral={},{}
    for _,candidate in ipairs(candidates) do
        local pool=candidate.cover and covered or lateral;pool[#pool+1]=candidate
    end
    local candidate
    if #covered>0 and not (claim.escapeUseLateral and #lateral>0) then
        local nextCover=(claim.escapeCoverCursor or 0)%#covered+1
        candidate=covered[nextCover];claim.escapeCoverCursor=nextCover
    elseif #lateral>0 then
        local nextLateral=(claim.escapeLateralCursor or 0)%#lateral+1
        candidate=lateral[nextLateral];claim.escapeLateralCursor=nextLateral
    end
    if not candidate then return false end
    -- Recovery admits one urgent search per native budget window. A failed
    -- shelter route tries the lateral fallback on the next bounded retry.
    local path=EmergencyShieldRoute(platoon,builder,candidate.pos,true)
    if not ShieldAssignment(platoon,builder,claim) then return false end
    local shield=candidate.shield
    if path and (not shield or Own(army,shield.owner) and not shield.deleted and shield:IsEnabled() and shield:GetHealth()>0
        and Covers(shield:GetPosition(),candidate.protection,BuilderShieldAsset(builder,candidate.pos))) then
        claim.escapeUseLateral=nil;return path
    end
    claim.escapeUseLateral=candidate.cover or nil
    return false,true
end
function DefenseInvestment(army,snapshot,baseName,kind)
    local assets=snapshot.baseDefenseAssets and snapshot.baseDefenseAssets[baseName]
    local a,e=snapshot.alloy,snapshot.energy
    if not assets or not a or not e or a.income<=0 or e.income<=0
        or (snapshot.completeFactories or 0)<2 or EconomyPolicy.NeedsGroundRecovery(army,snapshot)
        or EconomyPolicy.AlloyStalled(snapshot) then return false end
    local alloy=a.balance-(a.reserved or 0)
    local energy=e.balance-(e.reserved or 0)
    if a.ratio<0.35 or e.ratio<0.50 or energy<0
        or alloy<0 and a.current<-alloy*45 then return false end
    if not EconomyPolicy.LandEnabled(army) then
        if kind=="ground" and not snapshot.localLandThreat then return false end
        local roles=snapshot.completeRoles or {}
        if (roles.fighter or 0)+(roles.naval or 0)+(roles.submarine or 0)<4 then return false end
    end
    if kind=="shield" then
        if assets.advanced==0 and assets.factories<3 then return false end
        if assets.needsShield==nil then
            assets.needsShield=false
            for _,target in ipairs(assets.targets) do
                local covered=false
                for _,shield in ipairs(snapshot.defenseShields or {}) do
                    if ShieldCoverage(shield,target) then covered=true;break end
                end
                if not covered then assets.needsShield=true;break end
            end
        end
        return assets.needsShield
    end
    return assets.factories>0 or assets.advanced>0 and assets.extractors>=2
end
function Install(isRush)
    IsRush=isRush
    if installed then return end
    installed=true
    local old=AF.FindPlaceToBuild
    AF.FindPlaceToBuild=function(index,id,center,spacing,adjacency,radius,avoid,options)
        if IsRush(Armies[index]) then
            local result,handled=Find(index,id,center,spacing,adjacency,radius,avoid,nil,options)
            if handled then return result end
        end
        return old(index,id,center,spacing,adjacency,radius,avoid)
    end
end
