-- Shared, short-lived spatial view of the NATIVE AI's enemy knowledge.
-- Never reads enemy armies' unit tables. No telemetry/ground-truth input.
Version = "9.0.25-rc30"
local AF = Import("AI/AIFunctions.lua")
local Policy = Import("AI/mods/AI-Scom/RushCombatPolicy.lua")
local CELL = 64
local caches = setmetatable({}, { __mode = "k" })
local ownerCaches = setmetatable({}, { __mode = "k" })
local function Now() return GetGameTimeSeconds() end
local function D2(a,b) return (a.x-b.x)^2 + (a.z-b.z)^2 end
local function Copy(p) return {x=p.x,y=p.y,z=p.z} end
local function Position(u)
    return Copy(AF.GetUnitPositionForCurrentSimulationTick and AF.GetUnitPositionForCurrentSimulationTick(u) or u:GetPosition())
end
local function Id(u) return u.id and tonumber(u.id.index) or 0 end
local function Live(r)
    local u=r.unit
    return not u.dead and not u.deleted and u.army==r.owner and not u.CaptureInProgress and not u.ReclaimInProgress
end
local function Add(grid,r)
    local x,z=math.floor(r.pos.x/CELL),math.floor(r.pos.z/CELL)
    grid[x]=grid[x] or {};grid[x][z]=grid[x][z] or {}
    local cell=grid[x][z];cell[#cell+1]=r
end
local function Record(u)
    -- Most friendly records never contribute to a query. Allocate layer caches
    -- only when used rather than two empty tables per unit every snapshot.
    return {unit=u,owner=u.army,pos=Position(u)}
end
local function RecordLess(a,b) return a.sortId<b.sortId end
local function Observed(army,u)
    return u and not u.dead and not u.deleted and not u.CaptureInProgress and not u.ReclaimInProgress
        and u.army and army:IsEnemy(u.army)
        and ((type(u.IsIntelVisionVisible)=="function" and u:IsIntelVisionVisible(army))
            or (type(u.IsIntelRadarVisible)=="function" and u:IsIntelRadarVisible(army))) or false
end
local function AppendRecords(result,seen,units,army)
    for _,u in pairs(units or {}) do
        if u and not seen[u] and Observed(army,u) then
            local completed=u:IsCompleted()
            if not u:IsPlacementGhost()
                and not u.CaptureInProgress and not u.ReclaimInProgress then
                seen[u]=true
                -- RC20: sample the immutable native ID once, rather than repeatedly
                -- resolving/converting it in the O(n log n) sort comparisons.
                -- Completion belongs to this same half-second snapshot. Reuse it
                -- for all layers; started construction is a target, not firepower.
                local r=Record(u);r.sortId=Id(u);r.completed=completed
                result[#result+1]=r
            end
        end
    end
end
local function SortedRecords(units,army)
    local result={}
    AppendRecords(result,{},units,army)
    table.sort(result,RecordLess)
    return result
end
local function Value(r,layer)
    r.values=r.values or {}
    if r.values[layer]==nil then
        r.values[layer]=r.completed~=false and math.max(0,AF.GetUnitThreatValueByLayer(r.unit,layer,false) or 0) or 0
    end
    return r.values[layer]
end
-- Reuse the same native half-second record for defensive force accounting.
-- The caller must still decide whether the unit can reach or shoot its objective.
function KnownThreat(army,unit,layer)
    local r=unit and Get(army).byEnemy[unit]
    if r and Live(r) and Observed(army,unit) then return Value(r,layer or "Land") end
    return 0
end
function IsStatic(unit)
    return unit:HasTags(Tags.STRUCTURE)
        or (unit:HasTags(Tags.DEFENCE) and not unit:HasTags(Tags.MOBILE))
end
local function Footprint(tp)
    for _,key in ipairs({"skirtSize","footprint"}) do
        local f=tp and tp[key]
        if f and type(f.x)=="number" and type(f.y)=="number"
            and f.x>0 and f.y>0 and f.x<math.huge and f.y<math.huge then
            -- Rotation-independent conservative extent; rendezvous sites need
            -- clearance, not the building's unrotated axis-aligned footprint.
            return math.sqrt(f.x*f.x+f.y*f.y)/2
        end
    end
end
local function Range(r,layer)
    r.ranges=r.ranges or {}
    if r.ranges[layer]==nil then
        r.ranges[layer]=math.max(0,AF.GetUnitMaximumWeaponRangeByLayer(r.unit,layer) or 0)
    end
    return r.ranges[layer]
end

-- Owned/allied positions are shared by owner, not copied and sorted once for
-- every allied AI. Enemy knowledge remains strictly viewer-specific. A viewer
-- expires no later than its oldest shard: sharing never adds another half-second
-- of staleness. Live ownership, allegiance and assignments are still checked.
local function OwnerShard(owner, now)
    local shard=ownerCaches[owner]
    if shard and now>=shard.at and now<shard.expires and shard.units==owner.units then return shard,false end
    shard={at=now,expires=now+Policy.Config.SnapshotSeconds,units=owner.units,
        records={},grid={},byUnit={},obstacles={},obstacleGrid={},obstacleRadius=0}
    for _,u in pairs(owner.units or {}) do
        if u and not u.dead and not u.deleted and u.army==owner and not shard.byUnit[u] then
            local r
            if u:IsCompleted() and not u.CaptureInProgress and not u.ReclaimInProgress then
                r=Record(u);shard.records[#shard.records+1]=r;shard.byUnit[u]=r;Add(shard.grid,r)
            end
            if u:HasTags(Tags.STRUCTURE) then
                local half=Footprint(u.tp)
                if half then
                    local obstacle=r or Record(u)
                    obstacle.halfX,obstacle.halfZ=half,half
                    shard.obstacles[#shard.obstacles+1]=obstacle;Add(shard.obstacleGrid,obstacle)
                    shard.obstacleRadius=math.max(shard.obstacleRadius,half)
                end
            end
        end
    end
    ownerCaches[owner]=shard
    return shard,true
end
function Get(army)
    local now=Now()
    local cache=caches[army]
    if cache and now>=cache.at and now<cache.expires then return cache end
    local stats=cache and cache.stats or {builds=0,enemyCandidates=0,friendlyCandidates=0,queries=0,
        ownerBuilds=0,ownerReuses=0}
    stats.builds=stats.builds+1
    cache={at=now,expires=now+Policy.Config.SnapshotSeconds,
        enemy=SortedRecords(AF.GetEnemyUnitsOnMap(army.id),army),friendlyShards={},
        enemyGrid={},byEnemy={},maximumRange={},enemyLayers={},stats=stats}
    for _,r in ipairs(cache.enemy) do Add(cache.enemyGrid,r);cache.byEnemy[r.unit]=r end
    local owners={}
    for _,other in pairs(Armies or {}) do
        if other==army or army:IsAlly(other) then owners[#owners+1]=other end
    end
    table.sort(owners,function(a,b) return a.id<b.id end)
    for _,owner in ipairs(owners) do
        local shard,built=OwnerShard(owner,now)
        cache.friendlyShards[#cache.friendlyShards+1]={owner=owner,data=shard}
        cache.expires=math.min(cache.expires,shard.expires)
        local key=built and "ownerBuilds" or "ownerReuses"
        stats[key]=(stats[key] or 0)+1
    end
    -- Retain diagnostic lookup compatibility without constructing an N-unit
    -- merged table for each ally. This table is not used by the hot query path.
    cache.byFriendly=setmetatable({},{__index=function(_,u)
        for _,entry in ipairs(cache.friendlyShards) do
            local r=entry.data.byUnit[u];if r then return r end
        end
    end})
    caches[army]=cache
    return cache
end

local function Visit(grid,records,pos,radius,fn)
    local x0,x1=math.floor((pos.x-radius)/CELL),math.floor((pos.x+radius)/CELL)
    local z0,z1=math.floor((pos.z-radius)/CELL),math.floor((pos.z+radius)/CELL)
    -- A map-spanning artillery weapon must still count. Fall back to one linear
    -- pass rather than visiting thousands of empty cells; never truncate threats.
    if (x1-x0+1)*(z1-z0+1)>#records+16 then
        for _,r in ipairs(records) do fn(r) end
    else
        for x=x0,x1 do
            local row=grid[x]
            if row then
                for z=z0,z1 do
                    local cell=row[z]
                    if cell then for _,r in ipairs(cell) do fn(r) end end
                end
            end
        end
    end
end

function Visible(army,unit)
    -- Cached membership is last observation, never permission to read a unit's
    -- live hidden position after it leaves vision/radar between snapshots.
    local r=unit and Get(army).byEnemy[unit]
    return r and Live(r) and Observed(army,unit) or false
end

-- Disjoint range bands avoid letting ONE map-range weapon turn every local
-- query into a full-army scan. Every damaging record belongs to exactly one
-- band. No maximum range, nearest-N filter or reduced sensing rate is used.
local function AddToBand(bands,r,layer)
    if Value(r,layer)<=0 then return end
    local reach=Range(r,layer)
    if bands.general then
        bands.maximumRange=math.max(bands.maximumRange,reach)
        bands[1].range=bands.maximumRange
        return
    end
    local bound=CELL
    while reach>bound do bound=bound*2 end
    local band=bands.byBound[bound]
    if not band then
        band={bound=bound,range=0,records={},grid={}}
        bands.byBound[bound]=band;bands[#bands+1]=band
    end
    band.range=math.max(band.range,reach)
    bands.maximumRange=math.max(bands.maximumRange,reach)
    band.records[#band.records+1]=r;Add(band.grid,r)
end
local function BandLess(a,b) return a.bound<b.bound end
local function EnemyLayer(c,layer,army)
    local bands=c.enemyLayers[layer]
    if not bands then
        bands={byBound={},pending={},maximumRange=0,general=#c.enemy<128}
        -- Small forces use the already-built general grid. Splitting a handful
        -- of medium-range units into sparse bands costs more than it saves.
        -- This changes only the lookup algorithm: all threats are still tested.
        if bands.general then bands[1]={range=0,bound=0,records=c.enemy,grid=c.enemyGrid} end
        for _,r in ipairs(c.enemy) do
            if Live(r) and Observed(army,r.unit) then AddToBand(bands,r,layer)
            else bands.pending[#bands.pending+1]=r end
        end
        table.sort(bands,BandLess)
        c.enemyLayers[layer]=bands
    elseif #bands.pending>0 then
        -- A snapshot record may be temporarily in capture/reclaim when a layer
        -- is first queried. Keep that small deferred set, so cancellation or
        -- restoration of ownership is observed without a full-army rescan.
        local changed=false
        for i=#bands.pending,1,-1 do
            local r=bands.pending[i]
            if Live(r) and Observed(army,r.unit) then
                table.remove(bands.pending,i);AddToBand(bands,r,layer);changed=true
            end
        end
        if changed then table.sort(bands,BandLess) end
    end
    c.maximumRange[layer]=bands.maximumRange
    return bands
end
-- Amphibious transitions can expose a force to both land guns and naval
-- weapons. Reuse the cached range bands and count each enemy once, at its
-- strongest applicable value, instead of double counting dual-purpose guns.
local function VisitThreat(army,pos,layers,formationRadius,minimumRange,fn)
    local c=Get(army);local multiple=type(layers)=="table"
    formationRadius,minimumRange=formationRadius or 0,minimumRange or 0
    c.stats.queries=c.stats.queries+1
    local seen=multiple and {} or nil
    local function visit(r)
        if seen and seen[r] then return end
        if seen then seen[r]=true end
        c.stats.enemyCandidates=c.stats.enemyCandidates+1
        if not Live(r) or not Observed(army,r.unit) then return end
        local distance=D2(pos,r.pos);local value,range=0,0
        if multiple then
            for _,layer in ipairs(layers) do
                local reach=Range(r,layer)
                if distance<=(formationRadius+math.max(reach,minimumRange))^2 then
                    local strength=Value(r,layer)
                    if strength>0 then value=math.max(value,strength);range=math.max(range,reach) end
                end
            end
        else
            range=Range(r,layers)
            if distance<=(formationRadius+math.max(range,minimumRange))^2 then value=Value(r,layers) end
        end
        if value>0 then fn(r,value,range) end
    end
    local function visitLayer(layer)
        for _,band in ipairs(EnemyLayer(c,layer,army)) do
            Visit(band.grid,band.records,pos,formationRadius+math.max(band.range,minimumRange),visit)
        end
    end
    if multiple then for _,layer in ipairs(layers) do visitLayer(layer) end
    else visitLayer(layers) end
end
function EnemyThreat(army,pos,layer,formationRadius,minimumRange,ignore)
    local threat=0
    VisitThreat(army,pos,layer,formationRadius,minimumRange,function(record,value,range)
        if not ignore or not ignore(record.unit,record.pos,range) then threat=threat+value end
    end)
    return threat
end

local function VisitFriendly(army,pos,radius,fn)
    local c=Get(army)
    for _,entry in ipairs(c.friendlyShards) do
        if entry.owner==army or army:IsAlly(entry.owner) then
            local shard=entry.data
            Visit(shard.grid,shard.records,pos,radius,function(r)
                c.stats.friendlyCandidates=c.stats.friendlyCandidates+1
                if Live(r) and (r.owner==army or army:IsAlly(r.owner)) and D2(pos,r.pos)<=radius*radius then fn(r) end
            end)
        end
    end
end
function FriendlyThreat(platoon,pos,radius,layer,mobileOnly)
    local threat,allied=0,0
    VisitFriendly(platoon.army,pos,radius,function(r)
        local u=r.unit
        -- An escaping force cannot underwrite a fresh assault or keep a
        -- supported primary committed after that force has disengaged.
        local supportPlatoon=u.platoon
        local supporting=supportPlatoon and supportPlatoon.ai
        local operation=supporting and supporting.rushOperation
        local withdrawing=supporting and (supporting.withdraw or supporting.eState=="Withdraw"
            or operation and operation.policy and operation.policy.phase=="Retreat")
        if operation and operation.policy and operation.registeredAI==supporting
            and operation.registeredArmyAI==u.army.ai and operation.registry
            and operation.registry[supportPlatoon.id]==supportPlatoon and supportPlatoon.army==u.army
            and not supportPlatoon.dead and not supportPlatoon.deleted
            and u.army:PlatoonExists(supportPlatoon)==supportPlatoon then
            -- The live managed phase owns retreat. A legacy flag from an ended
            -- withdrawal cannot permanently hide a regrouped nearby force.
            withdrawing=operation.policy.phase=="Retreat"
        end
        if u.platoon~=platoon and not (u.ai and u.ai.eState=="RepairHome")
            and not withdrawing and not (u.toggles and u.GetPause and u:GetPause())
            and (not IsStatic(u) or D2(r.pos,pos)<=Range(r,layer)^2)
            and (not mobileOnly or (u:HasTags(Tags.MOBILE) and not u:HasTags(Tags.ENGINEER+Tags.COMMAND))) then
            local v=Value(r,layer);threat=threat+v
            if u.army~=platoon.army then allied=allied+v end
        end
    end)
    return threat,allied
end
function FriendlyUnitsInRadius(army,pos,radius)
    local units={}
    VisitFriendly(army,pos,radius,function(r) units[#units+1]=r.unit end)
    table.sort(units,function(a,b) return Id(a)<Id(b) end)
    return units
end
-- Reject rendezvous points inside known friendly construction footprints. This
-- complements, never replaces, the host's movement graph and native path check.
function ClearRendezvous(army,pos,margin)
    local clear=true;margin=margin or 10
    for _,entry in ipairs(Get(army).friendlyShards) do
        if entry.owner==army or army:IsAlly(entry.owner) then
            local shard=entry.data
            Visit(shard.obstacleGrid,shard.obstacles,pos,shard.obstacleRadius+margin,function(r)
                if not r.unit.dead and not r.unit.deleted and r.unit.army==r.owner
                    and math.abs(pos.x-r.pos.x)<=r.halfX+margin and math.abs(pos.z-r.pos.z)<=r.halfZ+margin then clear=false end
            end)
        end
    end
    return clear
end
-- Current exposure uses ENEMY weapon reach, not our longest artillery range.
-- Projected assault strength may still call EnemyThreat with a broader minimum.
-- Details share the same range-band traversal; no second full-army query.
function Exposure(army,pos,layer,formationRadius)
    local r={total=0,static=0,mobile=0,air=0,x=0,z=0,maxStaticRange=0}
    VisitThreat(army,pos,layer,formationRadius,0,function(record,value,range)
        r.total=r.total+value;r.x=r.x+record.pos.x*value;r.z=r.z+record.pos.z*value
        if record.air==nil then record.air=record.unit:HasTags(Tags.AIR) end
        if record.air then r.air=r.air+value end
        if record.static==nil then record.static=IsStatic(record.unit) end
        if record.static then
            r.static=r.static+value;r.maxStaticRange=math.max(r.maxStaticRange,range)
            if not r.staticUnit or value>r.staticValue or (value==r.staticValue and Id(record.unit)<Id(r.staticUnit)) then
                r.staticUnit,r.staticValue,r.staticPosition=record.unit,value,record.pos
            end
        else r.mobile=r.mobile+value end
    end)
    if r.total>0 then r.center={x=r.x/r.total,y=pos.y,z=r.z/r.total} end
    return r
end

-- Geometry for bounded operations only. Keep the actual spread for telemetry;
-- an isolated trailing unit must not project a map-sized enemy-threat circle.
local function GeometryPointLess(a,b)
    if a.medianDistance~=b.medianDistance then return a.medianDistance<b.medianDistance end
    return a.sortId<b.sortId
end
function Geometry(platoon,layer,units)
    layer=layer or "Land"
    -- Numeric scratch is private and never returned. Geometry results and their
    -- point records remain independent snapshots, safe across yielding movement.
    local scratch=platoon.ai.rushGeometryScratch
    if not scratch then scratch={xs={},zs={}};platoon.ai.rushGeometryScratch=scratch end
    local points,xs,zs={},scratch.xs,scratch.zs
    local count=0
    for _,u in pairs(units or platoon:GetUnits()) do
        if not u.dead and not u.deleted and u.army==platoon.army and u.platoon==platoon
            and not u.CaptureInProgress and not u.ReclaimInProgress
            and not (u.ai and u.ai.eState=="RepairHome") then
            local p=Position(u)
            count=count+1
            points[count]={unit=u,pos=p,sortId=Id(u)};xs[count]=p.x;zs[count]=p.z
        end
    end
    for i=#xs,count+1,-1 do xs[i]=nil;zs[i]=nil end
    local n=#points
    if n==0 then return {position=Copy(platoon:GetPosition()),radius=0,actualRadius=0,
        own=0,nominal=0,range=0,count=0,points={},coreCount=0} end
    table.sort(xs);table.sort(zs)
    local median={x=xs[math.ceil(n/2)],y=points[1].pos.y,z=zs[math.ceil(n/2)]}
    for _,item in ipairs(points) do item.medianDistance=D2(item.pos,median) end
    table.sort(points,GeometryPointLess)
    local coreCount=n<=2 and n or math.max(2,math.floor(n*0.75))
    local pos={x=0,y=0,z=0}
    for i=1,coreCount do
        local p=points[i].pos;pos.x=pos.x+p.x;pos.y=pos.y+p.y;pos.z=pos.z+p.z
    end
    pos.x,pos.y,pos.z=pos.x/coreCount,pos.y/coreCount,pos.z/coreCount
    local actual,core,range,nominal,own=0,0,0,0,0
    for i,item in ipairs(points) do
        item.distance=math.sqrt(D2(pos,item.pos))
        actual=math.max(actual,item.distance)
        if i<=coreCount then core=math.max(core,item.distance) end
        item.threat=math.max(0,AF.GetUnitThreatValueByLayer(item.unit,layer,false) or 0)
        item.range=math.max(0,AF.GetUnitMaximumWeaponRangeByLayer(item.unit,layer) or 0)
        nominal=nominal+item.threat
        if i<=coreCount then range=math.max(range,item.range) end
    end
    core=math.min(Policy.Config.CoreRadiusLimit,core)
    for _,item in ipairs(points) do
        if item.distance<=math.max(40,core+item.range+16) then
            own=own+item.threat;range=math.max(range,item.range)
        end
    end
    return {position=pos,radius=core,actualRadius=actual,own=own,nominal=nominal,
        range=range,count=n,points=points,coreCount=coreCount}
end

function InWeaponRange(geometry,target)
    if not target or target.dead or target.deleted then return false end
    for _,item in ipairs(geometry.points) do
        for _,weapon in ipairs(item.unit.weapons or {}) do
            if weapon.enabled and not weapon.isDeathExplosion and weapon:CanShootAt(target)
                and weapon:IsTargetInRange(target) then return true end
        end
    end
    return false
end

function Stats(army) return Get(army).stats end

function EnemiesInRadius(army,pos,radius,unsorted)
    local c=Get(army);local result={}
    Visit(c.enemyGrid,c.enemy,pos,radius,function(r)
        c.stats.enemyCandidates=c.stats.enemyCandidates+1
        if Live(r) and Observed(army,r.unit) and not r.unit:HasTags(Tags.AIR)
            and D2(pos,r.pos)<=radius*radius then result[#result+1]=r.unit end
    end)
    if not unsorted then table.sort(result,function(a,b) return Id(a)<Id(b) end) end
    return result
end

-- Telemetry only, called on the existing 60-second combat report cadence.
-- Uses the current owned shard rather than another full set of native reads.
function DeploymentStats(army)
    local result={ground=0,unassigned=0,atBase=0,idleAtBase=0}
    for _,entry in ipairs(Get(army).friendlyShards) do
        if entry.owner==army then
            for _,r in ipairs(entry.data.records) do
                local u=r.unit
                if Live(r) and u:HasTags(Tags.MOBILE*Tags.LAND-Tags.ENGINEER-Tags.COMMAND-Tags.SCOUT) then
                    result.ground=result.ground+1
                    if not u.platoon then result.unassigned=result.unassigned+1 end
                    for _,base in pairs(army.ai.bases or {}) do
                        if base.position and D2(r.pos,base.position)<=64^2 then
                            result.atBase=result.atBase+1
                            if not u.platoon then result.idleAtBase=result.idleAtBase+1 end
                            break
                        end
                    end
                end
            end
        end
    end
    return result
end
