-- A produced unit owns its release thread. Stopping a factory cannot strand it.
local Curve = Import("host/curves.lua").Curve
local Orders = Import("host/managers/orders/hostOrderManager.lua")
local OrderTasks = Import("common/commonOrders.lua").OrderTasks
local ModelBounds = Import("common/systems/scoFactoryProductBounds.lua")
local Layers = Import("common/layers.lua")
local M = {}
local installed = {}
local reservations = {}
local heldProducts = {}
local CloseIfIdle
local identities = {}
for faction, prefix in pairs({c="UAB",e="UEB",g="URB",s="XSB"}) do
    for tier=1,3 do
        for domain=1,3 do
            identities["u"..faction.."s"..tier.."51"..domain] = prefix.."0"..tier.."0"..domain
        end
    end
end

-- Quantum gateways share the native factory lifecycle and source exit routes.
identities.ues5014 = "UEB0304"
identities.ucs2510 = "UAB0304"
identities.ugs5002 = "URB0304"
identities.uss2510 = "XSB0304"

local function Alive(unit)
    return unit and not unit.dead and not unit.deleted
end

local function Config(factory)
    local config = factory.tp.additions and factory.tp.additions.scoFactoryEgress
    if not config then return end
    local expected = factory and identities[factory.tpId]
    if expected then
        assert(config.targetId==factory.tpId and config.sourceId==expected, "Factory egress source identity drift")
    else
        local targetExpected=identities[config.targetId]
        local source=factory.tp.additions and factory.tp.additions.faSourceContract
        local nativeSourceAlias=targetExpected and config.sourceId==targetExpected and source
            and source.mapping==config.sourceId.." -> "..config.targetId
        if not nativeSourceAlias then return end
        expected=targetExpected
    end
    assert(config.buildOffset and config.exitRoutes and #config.exitRoutes>0, "Factory egress route missing")
    return config
end

local function Mobile(factory, unit)
    return Alive(unit) and unit:HasTags(Tags.MOBILE)
        and factory.upgradeBehaviorTargetUnit~=unit and factory.upgradeTarget~=unit
        and not (unit.IsUpgrade and unit:IsUpgrade())
end

local function ProductConfig(config,tpId)
    local override=config.productOverrides and config.productOverrides[tpId]
    if not override then return config end
    local selected={}
    for key,value in pairs(config) do selected[key]=value end
    for _,key in ipairs({"buildOffset","exitRoutes","platformClip"}) do
        if override[key]~=nil then selected[key]=override[key] end
    end
    return selected
end

local function Copy(point)
    return EngineClasses.float3(point.x, point.y, point.z)
end

local function Frame(factory)
    return {position=Copy(factory:GetPosition()), rotation=factory:GetOrientation()}
end

local function World(frame, point)
    local rotated = Engine.QuaternionRotateVector(frame.rotation, EngineClasses.float3(point.x,point.y,point.z))
    return EngineClasses.float3(frame.position.x+rotated.x,frame.position.y+rotated.y,frame.position.z+rotated.z)
end

local function Distance(a,b)
    return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2+(a.z-b.z)^2)
end

local function Key(unit)
    return tostring(unit.id.index)..":"..tostring(unit.id.version)
end

local function ProductBounds(config, unit)
    local measured = (config.productBounds and config.productBounds[unit.tpId]) or ModelBounds[unit.tpId]
    if measured then return measured end
    local collider = assert(unit.tp.collisionInfo, "Factory product has no measured bounds or collider")
    local size,center = collider.collisionSize,collider.centerOffset or {x=0,y=0,z=0}
    return {min={x=center.x-size.x/2,y=center.y-size.y/2,z=center.z-size.z/2},
        max={x=center.x+size.x/2,y=center.y+size.y/2,z=center.z+size.z/2}}
end

local function Extents(bounds, heading)
    local angle = math.rad(heading or 0)
    local c,s = math.cos(angle),math.sin(angle)
    local x,z = 0,0
    for _,bx in ipairs({bounds.min.x,bounds.max.x}) do
        for _,bz in ipairs({bounds.min.z,bounds.max.z}) do
            x=math.max(x,math.abs(c*bx+s*bz))
            z=math.max(z,math.abs(-s*bx+c*bz))
        end
    end
    return x,z
end

local function RotatedBounds(bounds,rotation)
    local minimum={x=math.huge,y=math.huge,z=math.huge}
    local maximum={x=-math.huge,y=-math.huge,z=-math.huge}
    for _,x in ipairs({bounds.min.x,bounds.max.x}) do
        for _,y in ipairs({bounds.min.y,bounds.max.y}) do
            for _,z in ipairs({bounds.min.z,bounds.max.z}) do
                local p=Engine.QuaternionRotateVector(rotation,EngineClasses.float3(x,y,z))
                for _,axis in ipairs({"x","y","z"}) do
                    minimum[axis]=math.min(minimum[axis],p[axis])
                    maximum[axis]=math.max(maximum[axis],p[axis])
                end
            end
        end
    end
    return {min=minimum,max=maximum}
end

local function CollisionBounds(config,unit)
    local measured=ProductBounds(config,unit)
    local bounds={min=Copy(measured.min),max=Copy(measured.max)}
    local info=unit.tp.collisionInfo
    if info then
        local center,size=info.centerOffset or {x=0,y=0,z=0},info.collisionSize
        for _,axis in ipairs({"x","y","z"}) do
            bounds.min[axis]=math.min(bounds.min[axis],center[axis]-size[axis]/2)
            bounds.max[axis]=math.max(bounds.max[axis],center[axis]+size[axis]/2)
        end
    end
    return bounds
end

local function OutDistance(state, direction, initial)
    local bounds=state.config.bounds
    local separation=math.huge
    if bounds then
        local offset=state.spawnLocal
        if math.abs(direction.x)>.001 then
            local edge=direction.x>0 and bounds.max.x or bounds.min.x
            separation=math.min(separation,(edge-offset.x)/direction.x+(state.extentX+.25)/math.abs(direction.x))
        end
        if math.abs(direction.z)>.001 then
            local edge=direction.z>0 and bounds.max.z or bounds.min.z
            separation=math.min(separation,(edge-offset.z)/direction.z+(state.extentZ+.25)/math.abs(direction.z))
        end
    end
    -- One separating axis clears the whole hull. Project its margin into path
    -- distance without extending a near-cardinal route to the other boundary.
    return separation<math.huge and math.max(initial,separation) or initial
end

local function WaterLevel()
    local status,hasWater=Engine.HasWater()
    if status~=EngineErrorCode.Success or not hasWater then return end
    local levelStatus,level=Engine.GetWaterLevel()
    if levelStatus==EngineErrorCode.Success then return level end
end

local function ClearancePhase(state, now)
    local duration=state.duration*math.abs(state.goal-state.from)
    local t=duration>0 and math.min(1,math.max(0,now-state.time)/duration) or 1
    return state.from+(state.goal-state.from)*t*t*(3-2*t),t>=1
end

local function PostureRig(factory,unit)
    local additions=unit.tp.additions
    local posture=additions and additions.scoFactoryPosture
    if not posture or unit.tpId~="ugl3001" or factory.tpId~="ugs3511" then return end
    local source=additions.faSourceContract
    assert(posture.targetId=="ugl3001" and posture.sourceId=="XRL0305"
        and posture.allowedFactoryId=="ugs3511" and source
        and source.sourceBlueprint=="units/XRL0305/XRL0305_unit.bp","Factory product posture identity drift")
    local rig=posture.clearanceRig
    assert(rig and rig.adaptation==true and type(rig.duration)=="number"
        and rig.duration>0 and rig.duration<math.huge,"Factory product posture duration missing")
    return rig
end

local function PostureGoal(state,goal,force)
    local rig=state.postureRig
    if not rig then return end
    local unit,now=state.unit,Engine.GetSimulationTime()
    local clock=state.postureClock or unit.scoFactoryPostureClock
    if not clock then clock={duration=rig.duration,from=0,goal=0,time=now,serial=0} end
    state.postureClock,unit.scoFactoryPostureClock=clock,clock
    if clock.goal~=goal then
        clock.from=ClearancePhase(clock,now)
        clock.goal,clock.time=goal,now
        force=true
    end
    -- A finite clock survives replay and release; it contains no factory or
    -- coroutine reference. Late clients receive the original transition time.
    if Alive(unit) and (force or not clock.lastBroadcast or now-clock.lastBroadcast>=.5) then
        clock.serial=clock.serial+1
        clock.lastBroadcast=now
        Import("common/commands/definitions/units.lua").SCOFactoryClearance.Send(
            unit.id,clock.serial,clock.time,clock.from,clock.goal)
    end
    return clock
end

local function PostureReady(state)
    local clock=state.postureClock
    if not clock then return true end
    -- Include one native render interval, even when construction completes in
    -- the same tick as Prepare. Source gait starts only after the hips settle.
    return clock.goal==1 and Engine.GetSimulationTime()>=
        clock.time+clock.duration*math.abs(clock.goal-clock.from)+.1
end

local function ClearanceGoal(factory, goal)
    local config=Config(factory)
    local rig=config and config.clearanceRig
    if not rig or not Alive(factory) then return end
    assert(rig.adaptation==true and type(rig.duration)=="number" and rig.duration>0
        and rig.duration<math.huge,"Factory clearance rig duration missing")
    local now=Engine.GetSimulationTime()
    local state=factory.scoFactoryClearance
    if not state then
        state={duration=rig.duration,from=0,goal=0,time=now,serial=0}
        factory.scoFactoryClearance=state
    end
    if state.goal~=goal then
        state.from=ClearancePhase(state,now)
        state.goal,state.time=goal,now
    end
    -- Rebroadcast the same clock, without restarting a transition, for clients
    -- initialized after the factory's completion event.
    state.serial=state.serial+1
    Import("common/commands/definitions/units.lua").SCOFactoryClearance.Send(
        factory.id,state.serial,state.time,state.from,state.goal)
    return state
end

local function AwaitClearance(factory, goal, valid)
    local state=ClearanceGoal(factory,goal)
    if not state then return Alive(factory) end
    while Alive(factory) and (not valid or valid()) do
        if factory.scoFactoryClearance~=state or state.goal~=goal then return false end
        local _,complete=ClearancePhase(state,Engine.GetSimulationTime())
        if complete then return true end
        WaitTicks(1)
    end
    return false
end

local function MinimumWaterDepth(factory,config)
    local source=factory.tp.additions and factory.tp.additions.faSourceContract
    local depth=source and source.minimumWaterDepth
    if type(depth)=="number" and depth>=0 then return depth end
    if type(config.minimumWaterDepth)=="number" and config.minimumWaterDepth>=0 then
        return config.minimumWaterDepth
    end
    -- All twelve scoped naval BPs declare Footprint.MinWaterDepth=1.5.
    -- This is also the established SeaParity fallback, not product mesh height.
    return 1.5
end

local function SubmergedLine(factory,config,origin,destination)
    local level=WaterLevel()
    if level==nil then return false end
    local depth=MinimumWaterDepth(factory,config)
    local length=math.sqrt((destination.x-origin.x)^2+(destination.z-origin.z)^2)
    local steps=math.max(1,math.ceil(length/.5))
    for step=0,steps do
        local t=step/steps
        local point=EngineClasses.float3(origin.x+(destination.x-origin.x)*t,level,
            origin.z+(destination.z-origin.z)*t)
        local status,height=Engine.SampleTerrainHeight(point)
        if status~=EngineErrorCode.Success or height>level-depth then return false end
    end
    return true
end

local function NavalRouteClear(factory,config,frame,route,unit)
    local origin=World(frame,config.buildOffset)
    for _,point in ipairs(route.waypoints) do
        local destination=World(frame,point)
        if not SubmergedLine(factory,config,origin,destination) then return false end
        origin=destination
    end
    -- The actual route also extends beyond its authored endpoint for large hulls.
    local bounds=ProductBounds(config,unit)
    local extentX,extentZ=Extents(bounds,route.headingDegrees)
    local info=unit.tp.collisionInfo
    if info then
        local center,size=info.centerOffset or {x=0,z=0},info.collisionSize
        local x,z=Extents({min={x=center.x-size.x/2,z=center.z-size.z/2},
            max={x=center.x+size.x/2,z=center.z+size.z/2}},route.headingDegrees)
        extentX,extentZ=math.max(extentX,x),math.max(extentZ,z)
    end
    local last=route.waypoints[#route.waypoints]
    local dx,dz=last.x-config.buildOffset.x,last.z-config.buildOffset.z
    local length=math.sqrt(dx*dx+dz*dz)
    if length<.001 then return false end
    local direction={x=dx/length,z=dz/length}
    local distance=OutDistance({config=config,spawnLocal=config.buildOffset,extentX=extentX,extentZ=extentZ},direction,length)
    local destination=World(frame,{x=config.buildOffset.x+direction.x*distance,y=last.y,
        z=config.buildOffset.z+direction.z*distance})
    return SubmergedLine(factory,config,origin,destination)
end

local function SelectRoute(factory, config, frame, naval, unit)
    local source = factory.unitBeingBuiltSource or factory
    local rally = source.rallyPoint
    local best, distance
    for _,route in ipairs(config.exitRoutes) do
        if not naval or NavalRouteClear(factory,config,frame,route,unit) then
            local point = World(frame, route.waypoints[#route.waypoints])
            local d = rally and ((point.x-rally.x)^2+(point.z-rally.z)^2) or 0
            if not distance or d<distance then best,distance=route,d end
        end
    end
    -- No submerged route retains the first source corridor and its build pose.
    -- The child driver waits there until that frozen corridor becomes navigable.
    return best or config.exitRoutes[1], rally and Copy(rally)
end

local function Preferred(unit)
    return unit.tp.movement.preferredAltitude or 0
end

local function SpawnLocal(config,unit,route,engineerTransfer,air,naval,bounds)
    local release=engineerTransfer and config.engineerRoute or nil
    local spawn=Copy(release and release.buildOffset or config.buildOffset)
    local clearance=math.max(Preferred(unit),-bounds.min.y,0)
    if release and release.buildBottomClearance then
        spawn.y=math.max(spawn.y,release.buildBottomClearance+clearance)
    elseif not air and not naval then
        spawn.y=math.max(spawn.y,route.waypoints[1].y+clearance)
    end
    return spawn,clearance,release
end

local function Ground(state, point)
    if state.naval then
        local level=WaterLevel()
        return level and level+Preferred(state.unit) or point.y
    end
    local status,height=Engine.SampleTerrainHeight(point)
    assert(status==EngineErrorCode.Success,"Factory egress terrain sample failed")
    local movement=state.unit.tp.movement
    if movement.referenceAltitude=="GroundOrWater" then
        local waterStatus,hasWater=Engine.HasWater()
        if waterStatus==EngineErrorCode.Success and hasWater then
            local levelStatus,level=Engine.GetWaterLevel()
            if levelStatus==EngineErrorCode.Success then height=math.max(height,level) end
        end
    end
    return height+state.surfaceClearance
end

local function Platform(state)
    local clip=state.platformClip
    if not clip or state.detached or not Alive(state.factory) or state.factory.upgradeBehaviorIsActive then return end
    -- The native UEF construction sampler owns the raised pad and moving arms.
    -- Do not compete with that full-pose writer before completion.
    if clip.attachmentPath and state.unit and not state.completionSeen
        and state.factory.faAirFactoryBuildTarget==state.unit then return end
    local animations=state.factory.tp.visuals and state.factory.tp.visuals.animations
    local animation=animations and animations[clip.animationKey]
    assert(animation and animation.id,"Factory source platform clip missing")
    Engine.PlayAnimation(state.factory.id,animation.id,-10000+math.max(0,math.min(state.platformTime or clip.time,clip.duration)))
end

local function HoldWeapons(state)
    if not state.completionSeen or state.weaponEnableIntent then return end
    local weapons=state.unit.weapons or {}
    state.weaponEnableIntent={}
    for index,weapon in ipairs(weapons) do
        state.weaponEnableIntent[index]=weapon.wantsEnabled==true
        weapon:SetEnabled(false)
    end
end

local function RestoreWeapons(state)
    local intents=state.weaponEnableIntent
    if not intents or not Alive(state.unit) then return end
    for index,weapon in ipairs(state.unit.weapons or {}) do
        weapon:SetEnabled(intents[index]==true)
    end
    state.weaponEnableIntent=nil
end

local function Hold(state, position)
    if not Alive(state.unit) or state.finished then return end
    local unit=state.unit
    -- Native completion enables weapons before the product has cleared its
    -- factory. Keep targeters and muzzles disabled for the whole owned egress,
    -- then restore the exact native enable intent at handoff.
    HoldWeapons(state)
    unit.scoFactoryColliderPinOwner=state.factory
    Engine.SetMovementEnabled(unit.id,false)
    Engine.SetVolumeColliderEnabled(unit.id,false)
    Engine.SetGlobalEntityLocalRotation(unit.id,state.orientation)
    if position then
        -- Retain our last submitted position. Native world transforms lag a tick.
        state.position=Copy(position)
        Engine.SetGlobalEntityPosition(unit.id,position)
    end
    Platform(state)
    PostureGoal(state,1,false)
end

local methods={"OnStopBeingBuilt","UpdateAnimations","OnDestroy","Delete","SetPosition","SetOrientation",
    "TakeoffBehaviourStart","LandingBehaviorStart","MoveIntoRangeBehaviorIsValidFor"}

local function HandoffPoint(state)
    -- Keep the physical route frozen, but honor rally edits made while building
    -- or waiting for clearance. Retain the producing master if stop cleared it.
    local source=state.factory.unitBeingBuiltSource or state.rallySource or state.factory
    if source.rallyPoint then return Copy(source.rallyPoint) end
    local direction=state.engineerTransfer and state.config.engineerRoute.direction
    if not direction then
        local last=state.route.waypoints[#state.route.waypoints]
        direction={x=last.x-state.spawnLocal.x,z=last.z-state.spawnLocal.z}
    end
    local world=Engine.QuaternionRotateVector(state.frame.rotation,
        EngineClasses.float3(direction.x,0,direction.z))
    local magnitude=math.sqrt(world.x^2+world.z^2)
    assert(magnitude>.001,"Factory native handoff has no outward direction")
    local bounds=state.worldCollisionBounds
    local radiusX=math.max(math.abs(bounds.min.x),math.abs(bounds.max.x))
    local radiusZ=math.max(math.abs(bounds.min.z),math.abs(bounds.max.z))
    local distance=math.max(2,2*math.sqrt(radiusX^2+radiusZ^2)+.5)
    if state.air then
        -- Aircraft begin flight on the platform; their default destination must
        -- still clear the factory before native idle/landing behavior can run.
        local length=math.sqrt(direction.x^2+direction.z^2)
        distance=distance+OutDistance(state,{x=direction.x/length,z=direction.z/length},0)
    end
    -- Native navigation owns crowd avoidance beyond the factory. Leaving a
    -- no-rally product on the release endpoint would obstruct the next product.
    return EngineClasses.float3(state.position.x+world.x/magnitude*distance,state.position.y,
        state.position.z+world.z/magnitude*distance)
end

local function Restore(state, released)
    if state.finished then return end
    PostureGoal(state,0,true)
    state.finished=true
    reservations[state]=nil
    heldProducts[state]=nil
    state.structurePassThrough=nil
    state.phasedStructures=nil
    state.phaseEndpoint=nil
    state.phaseEnvelope=nil
    state.phaseTerrainCache=nil
    state.phaseTerrainTime=nil
    state.phaseBlockedSince=nil
    state.phaseNextAttempt=nil
    state.phaseExtending=nil
    state.phaseNextExtension=nil
    state.egressWaypointIndex=nil
    local unit,factory=state.unit,state.factory
    if unit.scoFactoryEgressState==state then
        for _,name in ipairs(methods) do unit[name]=state.original[name] end
        unit.scoFactoryEgressState=nil
    end
    if unit.scoFactoryColliderPinOwner==factory then unit.scoFactoryColliderPinOwner=nil end
    if unit.scoSeaParityFactoryPinOwner==factory then unit.scoSeaParityFactoryPinOwner=nil end
    if factory.scoFactoryEgressState==state then
        factory.scoFactoryEgressState=nil
        factory.scoFactoryLastEgress=state
    end
    -- Legacy pin fields may have been set by the original build callback.
    for _,name in ipairs({"guardCybranPinnedBuildTarget","edaUefPinnedBuildTarget","scoAeonFactoryPinnedBuildTarget"}) do
        if factory[name]==unit then factory[name]=nil end
    end
    RestoreWeapons(state)
    if released and Alive(unit) then
        Engine.SetVolumeColliderEnabled(unit.id,state.colliderOnRelease)
        -- The native completed mobile lifecycle enables movement. AIR delegates
        -- its takeoff curve instead of having this adapter force an airborne state.
        Engine.SetMovementEnabled(unit.id,true)
        if state.takeoffPending and state.resolved.TakeoffBehaviourStart then
            state.resolved.TakeoffBehaviourStart(unit)
        end
        unit:UpdateAnimations()
        -- BUILD can be accepted while the product is pinned. Its native thread
        -- resumes after these methods are restored; replacing it with MOVE
        -- would cancel the player's active order and every queued build ghost.
        local orders=unit.orders
        if not orders or (not orders.activeOrder and #(orders.queuedOrders or {})==0) then
            state.handoffPoint=HandoffPoint(state)
            Orders.HostIssueOrder(OrderTasks.MOVE,{unit},false,state.handoffPoint,nil)
        end
    end
    if state.platformClip and not state.detached and Alive(factory) and not factory.upgradeBehaviorIsActive then
        local animations=factory.tp.visuals and factory.tp.visuals.animations
        local rest=animations and (animations.rest or animations.walk)
        if rest and rest.id then Engine.PlayAnimation(factory.id,rest.id,.1) end
    end
    -- Begin closing as soon as the final product clears; the native roll-off
    -- pause can overlap this transition before the next queued build.
    CloseIfIdle(factory,true)
end

local function SameID(a,b)
    return a and b and a.index==b.index and a.version==b.version
end

local function CorridorClear(state,destination,strict)
    local origin,bounds=state.position,state.worldCollisionBounds
    local center,size={},{}
    for _,axis in ipairs({"x","y","z"}) do
        local low=math.min(origin[axis],destination[axis])+bounds.min[axis]-.025
        local high=math.max(origin[axis],destination[axis])+bounds.max[axis]+.025
        center[axis]=(low+high)/2;size[axis]=high-low
    end
    -- Sweep the entire submitted interval, not only its endpoint. This world
    -- AABB conservatively contains the rotated product at both ends of the tick.
    local hits=Engine.BoxCast(CollisionWorld.Collision,EngineClasses.float3(center.x,center.y,center.z),
        EngineClasses.float3(size.x,size.y,size.z),state.identityRotation,
        Layers.CollisionLayer.Units+Layers.CollisionLayer.Props)
    for _,hit in ipairs(hits) do
        local id=hit.colliderGlobalID
        if id and id.index~=0 and Engine.IsValidGlobalID(id) then
            local status,root=Engine.GetGlobalEntityRoot(id)
            local owned=SameID(id,state.unit.id) or SameID(id,state.factory.id)
                or (status==EngineErrorCode.Success and
                    (SameID(root,state.unit.id) or SameID(root,state.factory.id)))
            if not owned then
                local other=not strict and state.structurePassThrough
                    and status==EngineErrorCode.Success and Engine.IsValidGlobalID(root)
                    and GetUnitById(root) or nil
                if not strict and state.structurePassThrough and Alive(other)
                    and SameID(other.id,root) and other:HasTags(Tags.STRUCTURE)
                    and not other:HasTags(Tags.MOBILE) then
                    state.phasedStructures[Key(other)]=other
                else return false end
            end
        elseif strict or state.structurePassThrough then
            -- A stale or unregistered collider is never a structure exemption.
            return false
        end
    end
    -- Held products have disabled native colliders. Their submitted hulls still
    -- obstruct other products, including a successor using the same factory.
    for other in pairs(heldProducts) do
        if other.unit~=state.unit and Alive(other.unit) and not other.finished then
            local overlap=true
            for _,axis in ipairs({"x","y","z"}) do
                local low=center[axis]-size[axis]/2
                local high=center[axis]+size[axis]/2
                local otherLow=other.position[axis]+other.worldCollisionBounds.min[axis]
                local otherHigh=other.position[axis]+other.worldCollisionBounds.max[axis]
                if low>=otherHigh or high<=otherLow then overlap=false;break end
            end
            if overlap then return false end
        end
    end
    return true
end

local function PhaseEnvelope(state)
    local bounds=state.collisionBounds
    local x=math.max(math.abs(bounds.min.x),math.abs(bounds.max.x))
    local z=math.max(math.abs(bounds.min.z),math.abs(bounds.max.z))
    local size=state.unit.tp.collisionInfo.collisionSize
    local radius=math.max(math.sqrt(x*x+z*z),math.max(size.x,size.z)/2)
    return {min={x=-radius,y=state.worldCollisionBounds.min.y,z=-radius},
        max={x=radius,y=state.worldCollisionBounds.max.y,z=radius}}
end

local function PhaseTransitBounds(state)
    local bounds={min=Copy(state.worldCollisionBounds.min),max=Copy(state.worldCollisionBounds.max)}
    local size=state.unit.tp.collisionInfo.collisionSize
    local reach=math.max(size.x,size.z)/2
    for _,axis in ipairs({"x","z"}) do
        bounds.min[axis]=math.min(bounds.min[axis],-reach)
        bounds.max[axis]=math.max(bounds.max[axis],reach)
    end
    return bounds
end

local function PhaseTerrainClear(state,point,turning)
    local map=GameInfo and GameInfo.MapInfo and GameInfo.MapInfo.size
    local bounds=turning and state.phaseEnvelope or state.worldCollisionBounds
    if not map or point.x+bounds.min.x<1.1 or point.z+bounds.min.z<1.1
        or point.x+bounds.max.x>map[1]-1.1 or point.z+bounds.max.z>map[2]-1.1 then return false end
    -- Match native pathfinding normals while structure nav cells are deliberately
    -- crossed. Cache only this attempt/tick's integer terrain samples.
    if state.phaseTerrainTime~=_G.Time then
        state.phaseTerrainTime=_G.Time;state.phaseTerrainCache={}
    end
    local cache=state.phaseTerrainCache
    local function height(x,z)
        local key=x..":"..z
        if cache[key]~=nil then return cache[key] end
        if x<0 or z<0 or x>=map[1] or z>=map[2] then return end
        local status,value=Engine.SampleTerrainHeight(EngineClasses.float3(x,0,z))
        if status~=EngineErrorCode.Success or value~=value or math.abs(value)==math.huge then return end
        cache[key]=value;return value
    end
    local cx,cz=math.floor(point.x),math.floor(point.z)
    for x=cx-1,cx+1 do
        for z=cz-1,cz+1 do
            local left,right,back,front=height(x-1,z),height(x+1,z),height(x,z-1),height(x,z+1)
            if not left or not right or not back or not front then return false end
            local gx,gz=(left-right)*.5,(back-front)*.5
            if gx*gx+gz*gz>1/3 then return false end
        end
    end
    local water=WaterLevel()
    local status,terrain=Engine.SampleTerrainHeight(EngineClasses.float3(cx+.5,0,cz+.5))
    return status==EngineErrorCode.Success and terrain==terrain and math.abs(terrain)<math.huge
        and (not water or terrain>=water
        or state.unit.tp.movement.referenceAltitude=="GroundOrWater")
end

local function OutsideSkirt(point,bounds,position,skirt)
    local minX=math.floor(position.x)-math.floor(math.max(1,math.floor(skirt.x))/2)
    local minZ=math.floor(position.z)-math.floor(math.max(1,math.floor(skirt.y))/2)
    local maxX,maxZ=minX+math.max(1,math.floor(skirt.x)),minZ+math.max(1,math.floor(skirt.y))
    return point.x+bounds.max.x+.25<minX or point.x+bounds.min.x-.25>maxX
        or point.z+bounds.max.z+.25<minZ or point.z+bounds.min.z-.25>maxZ
end

local function PhaseReleaseClear(state)
    local point,bounds=state.position,state.phaseEnvelope
    if not PhaseTerrainClear(state,point,true) then return false end
    local skirt=state.factory.tp.skirtSize
    if not skirt or not OutsideSkirt(point,bounds,state.frame.position,skirt) then return false end
    local physical={min=Copy(state.config.bounds.min),max=Copy(state.config.bounds.max)}
    local info=state.factory.tp.collisionInfo
    if info then
        local center=info.centerOffset or {x=0,y=0,z=0}
        for _,axis in ipairs({"x","y","z"}) do
            physical.min[axis]=math.min(physical.min[axis],center[axis]-info.collisionSize[axis]/2)
            physical.max[axis]=math.max(physical.max[axis],center[axis]+info.collisionSize[axis]/2)
        end
    end
    physical=RotatedBounds(physical,state.frame.rotation)
    if not (point.x+bounds.max.x+.025<state.frame.position.x+physical.min.x
        or point.x+bounds.min.x-.025>state.frame.position.x+physical.max.x
        or point.z+bounds.max.z+.025<state.frame.position.z+physical.min.z
        or point.z+bounds.min.z-.025>state.frame.position.z+physical.max.z) then return false end
    -- Native rotation resumes at release. Clear each crossed structure's visible
    -- mesh as well as its root collider before restoring the full turn envelope.
    for _,other in pairs(state.phasedStructures) do
        if Alive(other) and Engine.IsValidGlobalID(other.id) and GetUnitById(other.id)==other then
            local otherBounds=RotatedBounds(CollisionBounds({},other),other:GetOrientation())
            local position=other:GetPosition()
            if other.tp.skirtSize and not OutsideSkirt(point,bounds,position,other.tp.skirtSize) then return false end
            local overlap=true
            for _,axis in ipairs({"x","y","z"}) do
                if point[axis]+bounds.max[axis]+.025<position[axis]+otherBounds.min[axis]
                    or point[axis]+bounds.min[axis]-.025>position[axis]+otherBounds.max[axis] then overlap=false;break end
            end
            if overlap then return false end
        end
    end
    local probe={factory=state.factory,unit=state.unit,position=point,
        worldCollisionBounds=bounds,identityRotation=state.identityRotation}
    if not CorridorClear(probe,point,true) then return false end
    local status,layer=Engine.GetMovementNavigationLayer(state.unit.id)
    if status~=EngineErrorCode.Success then return false end
    local navPoint=EngineClasses.float2(point.x,point.z)
    local navStatus,result=Engine.NavmapLineCast(navPoint,navPoint,layer)
    return navStatus==EngineErrorCode.Success and result==NavmapLineCastResult.NoHit
end

local function BuildPadClear(factory,item,fallback)
    local config=Config(factory)
    local template=item and __Templates and __Templates.Units and __Templates.Units[item.tpId]
    if not config then return true end
    local probe
    if template and template.movement then
        config=ProductConfig(config,item.tpId)
        local unit={tpId=item.tpId,tp=template}
        local frame=Frame(factory)
        local air=Tags.AIR[item.tpId]==true
        local naval=not air and (Tags.NAVAL[item.tpId] or not Tags.LAND[item.tpId])
            and (config.domain=="naval" or config.domain=="sea")
        local transfer=not air and config.domain=="air" and config.engineerRoute~=nil
        local route=SelectRoute(factory,config,frame,naval,unit)
        local heading=route.headingDegrees or 0
        if transfer then
            local direction=config.engineerRoute.direction
            heading=math.deg(math.atan2(direction.x,direction.z))
        end
        local point=SpawnLocal(config,unit,route,transfer,air,naval,ProductBounds(config,unit))
        probe={factory=factory,unit=unit,position=World(frame,point),
            worldCollisionBounds=RotatedBounds(CollisionBounds(config,unit),
                Engine.QuaternionRotateY(frame.rotation,math.rad(heading)))}
    elseif fallback then
        probe={factory=factory,unit={},position=World(fallback.frame,fallback.spawnLocal),
            worldCollisionBounds=fallback.worldCollisionBounds}
    else return true end
    probe.identityRotation=Engine.EulerToQuaternion(EngineClasses.float3(0,0,0),RotationOrder.Default)
    return CorridorClear(probe,probe.position)
end

local function PlatformVacated(state)
    if not state.platformClip then return true end
    local start=World(state.frame,state.spawnLocal)
    local bounds=state.worldCollisionBounds
    for _,axis in ipairs({"x","z"}) do
        if state.position[axis]+bounds.max[axis]+.025<start[axis]+bounds.min[axis]
            or state.position[axis]+bounds.min[axis]-.025>start[axis]+bounds.max[axis] then return true end
    end
    return false
end

local function ReleaseBuildPad(state,item)
    if state.detached or state.finished then return true end
    -- The child retains its physical transfer/order owner. A blockage outside
    -- the next build volume need not keep the production queue, even after Stop
    -- has killed the original parent RollOffUnit coroutine.
    if not state.air and state.blocked and state.egressing and not state.platformLowering and PlatformVacated(state)
        and BuildPadClear(state.factory,item,state) then
        local factory=state.factory
        state.detached=true
        if factory.scoFactoryEgressState==state then factory.scoFactoryEgressState=nil end
        factory.scoFactoryLastEgress=state
        if state.platformClip and Alive(factory) and not factory.upgradeBehaviorIsActive then
            local animations=factory.tp.visuals and factory.tp.visuals.animations
            local rest=animations and (animations.rest or animations.walk)
            if rest and rest.id then Engine.PlayAnimation(factory.id,rest.id,.1) end
        end
        return true
    end
    return false
end

local function HasDepartingProduct(factory)
    for state in pairs(heldProducts) do
        if state.factory==factory and not state.finished then return true end
    end
    return false
end

local function DeparturesClearPad(factory,item)
    for state in pairs(heldProducts) do
        if state.factory==factory and not state.finished
            and not (state.detached and state.factoryEnvelopeCleared and not state.platformLowering
                and PlatformVacated(state) and BuildPadClear(factory,item,state)) then return false end
    end
    return true
end

-- Keep these repaired land factories closed at rest. Production and upgrades
-- still use the existing clearance transition before moving a product.
local LoweredIdle={ucs3511=true,ugs1511=true,ugs2511=true,ugs3511=true}
CloseIfIdle=function(factory,afterEgress)
    if not Alive(factory) or not LoweredIdle[factory.tpId] or not factory:IsCompleted()
        or factory.upgradeBehaviorIsActive or (factory.IsUpgrading and factory:IsUpgrading())
        or (HasDepartingProduct(factory)
            and not DeparturesClearPad(factory,factory.buildQueue and factory.buildQueue[1]))
        or (not afterEgress and (factory.productionBehaviorTargetUnit
            or (factory.productionBehaviorIsActive and factory.buildQueue and factory.buildQueue[1]))) then return end
    local config=Config(factory)
    if config and config.clearanceRig then ClearanceGoal(factory,0) end
end

local function Gait(state)
    if state.air or state.naval or state.engineerTransfer then return end
    if state.unit.tpId=="ugl4002" and state.unit.scoMegalithAwakeControl==true then return end
    local animations=state.unit.tp.visuals and state.unit.tp.visuals.animations
    local walk=animations and (animations.run or animations.walk)
    if walk and walk.id then
        -- Native animation scaling follows SimVelocity from curve position writes.
        Engine.PlayAnimation(state.unit.id,walk.id,.1)
        state.unit.isWalking=animations.run==nil
    end
end

local function UsesEngineerReleasePoint(state)
    local id=state.factory.tpId
    local product=state.unit.tpId
    return (id=="ugs1511" or id=="ugs2511" or id=="ugs3511")
        and (product=="ugl1501" or product=="ugl2501" or product=="ugl3501")
end

local function EngineerReleaseDistance(state,direction)
    local template=state.factory.tp
    local skirt=assert(template.skirtSize,"Factory navigation footprint missing")
    local bounds={min={},max={}}
    local collider=template.collisionInfo
    local center=collider and collider.centerOffset or {x=0,z=0}
    for _,axis in ipairs({"x","z"}) do
        bounds.min[axis]=state.config.bounds.min[axis]
        bounds.max[axis]=state.config.bounds.max[axis]
        if collider then
            bounds.min[axis]=math.min(bounds.min[axis],center[axis]-collider.collisionSize[axis]/2)
            bounds.max[axis]=math.max(bounds.max[axis],center[axis]+collider.collisionSize[axis]/2)
        end
    end
    local physical=OutDistance({config={bounds=bounds},spawnLocal=state.spawnLocal,
        extentX=state.extentX,extentZ=state.extentZ},direction,0)
    local origin=World(state.frame,state.spawnLocal)
    local forward=Engine.QuaternionRotateVector(state.frame.rotation,
        EngineClasses.float3(direction.x,0,direction.z))
    local size=state.unit.tp.collisionInfo.collisionSize
    -- Native avoidance radius + half capsule length equals max(x,z)/2.
    -- Use this conservative support in every world direction, including when
    -- the capsule's long axis differs from the visual/collision box's long axis.
    local capsuleReach=math.max(size.x,size.z)/2
    local navigation=math.huge
    for _,axis in ipairs({"x","z"}) do
        if math.abs(forward[axis])>.001 then
            -- NavmapUtils.GetModifierRect rasterizes an unrotated world AABB.
            local count=math.max(math.floor(axis=="x" and skirt.x or skirt.y),1)
            local minimum=math.floor(state.frame.position[axis])-math.floor(count/2)
            local edge
            if forward[axis]>0 then
                edge=minimum+count+math.max(capsuleReach,-state.worldCollisionBounds.min[axis])+.25
            else
                edge=minimum-math.max(capsuleReach,state.worldCollisionBounds.max[axis])-.25
            end
            navigation=math.min(navigation,(edge-origin[axis])/forward[axis])
        end
    end
    return math.max(physical,navigation)
end

local function LandReleaseDestination(state,destination)
    if state.phaseExtending then return destination end
    if not UsesEngineerReleasePoint(state) then return destination end
    local last=state.route.waypoints[#state.route.waypoints]
    local dx,dz=last.x-state.spawnLocal.x,last.z-state.spawnLocal.z
    local length=math.sqrt(dx*dx+dz*dz)
    local direction={x=dx/length,z=dz/length}
    local distance=EngineerReleaseDistance(state,direction)
    local origin=World(state.frame,state.spawnLocal)
    local forward=Engine.QuaternionRotateVector(state.frame.rotation,
        EngineClasses.float3(direction.x,0,direction.z))
    local projected=(destination.x-origin.x)*forward.x+(destination.z-origin.z)*forward.z
    if projected<distance then return destination end
    -- The entire product clears the hull and nav obstacle with the .25 margin.
    -- Native navigation owns obstacles beyond this ground-safe release point;
    -- holding to the old distant waypoint could reject commands indefinitely.
    local point=EngineClasses.float3(origin.x+forward.x*distance,destination.y,origin.z+forward.z*distance)
    point.y=Ground(state,point)
    return point
end

local function RouteWaypoint(state,point)
    local localPoint={x=point.x,y=point.y,z=point.z}
    if not state.air and not state.naval then
        -- The product's rear must clear the high deck before its root descends.
        local surface=point.y
        if not state.route.footprintSupportAlreadyApplied then
            local radius=math.max(state.extentX,state.extentZ)
            for _,other in ipairs(state.route.waypoints) do
                if (other.x-point.x)^2+(other.z-point.z)^2<=(radius+.13)^2 then
                    surface=math.max(surface,other.y)
                end
            end
        end
        localPoint.y=surface+state.surfaceClearance
    end
    local destination=World(state.frame,localPoint)
    if state.naval then destination.y=Ground(state,destination) end
    return destination
end

local function LandSegmentClear(probe,destination)
    destination=LandReleaseDestination(probe,destination)
    local origin=Copy(probe.position)
    local steps=math.max(1,math.ceil(Distance(origin,destination)/.125))
    for step=1,steps do
        local t=step/steps
        local point=EngineClasses.float3(origin.x+(destination.x-origin.x)*t,
            origin.y+(destination.y-origin.y)*t,origin.z+(destination.z-origin.z)*t)
        point.y=math.max(point.y,Ground(probe,point))
        if not CorridorClear(probe,point)
            or (probe.structurePassThrough and not PhaseTerrainClear(probe,point)) then return false end
        probe.position=point
    end
    return true
end

local function AuthoredLandExitClear(probe,destination)
    for _,point in ipairs(probe.route.waypoints) do
        if not LandSegmentClear(probe,RouteWaypoint(probe,point)) then return false end
    end
    -- Match the driver's outward extension followed by ground lowering.
    destination=Copy(destination);destination.y=probe.position.y
    if not LandSegmentClear(probe,destination) then return false end
    destination=Copy(probe.position);destination.y=Ground(probe,destination)
    return LandSegmentClear(probe,destination)
end

local BeginStructureTransit
local function Segment(state, destination, speed)
    destination=LandReleaseDestination(state,destination)
    local origin=state.position
    local length=Distance(origin,destination)
    if length<.00001 then return true end
    local duration=length/math.max(.1,speed)
    local curve=Curve.Play(state.unit,{duration=duration,position={mode=Curve.Absolute,
        x=Curve.Linear(origin.x,destination.x),y=Curve.Linear(origin.y,destination.y),z=Curve.Linear(origin.z,destination.z)}})
    local previousTime=_G.Time
    while Alive(state.unit) and not state.finished do
        local elapsed=math.max(0,_G.Time-previousTime);previousTime=_G.Time
        local fraction=math.min(1,math.max(0,(_G.Time-curve.startTime)/duration))
        local sample=curve:Sample(fraction)
        if not state.air then sample.y=math.max(sample.y,Ground(state,sample)) end
        local waterClear=not state.naval or SubmergedLine(state.factory,state.config,state.position,sample)
        if waterClear and CorridorClear(state,sample)
            and (not state.structurePassThrough or PhaseTerrainClear(state,sample)) then
            state.blocked=false
            state.phaseBlockedSince=nil
            Hold(state,sample)
            if fraction>=1 then return true end
        else
            -- Keep the curve's phase stationary while blocked; no timeout snap.
            state.blocked=true
            local planningStart=_G.Time
            if not state.structurePassThrough and BeginStructureTransit then
                BeginStructureTransit(state,destination)
            end
            curve.startTime=curve.startTime+elapsed+math.max(0,_G.Time-planningStart)
            previousTime=_G.Time
            Hold(state,state.position)
        end
        WaitTicks(1)
    end
    return false
end

local function Reserve(state)
    if reservations[state] then return true end
    local positions={state.position}
    if state.phaseEndpoint then
        for _,point in ipairs(state.route.waypoints) do positions[#positions+1]=World(state.frame,point) end
        positions[#positions+1]=state.phaseEndpoint
    elseif state.engineerTransfer then
        local release=state.config.engineerRoute
        local direction=release.direction
        local magnitude=math.sqrt(direction.x^2+direction.z^2)
        direction={x=direction.x/magnitude,z=direction.z/magnitude}
        local distance=OutDistance(state,direction,math.max(release.sourceOutDistance or 3,release.minimumOutDistance or 0))
        positions[#positions+1]=World(state.frame,{x=state.spawnLocal.x+direction.x*distance,y=state.spawnLocal.y,
            z=state.spawnLocal.z+direction.z*distance})
    else
        for _,point in ipairs(state.route.waypoints) do
            positions[#positions+1]=LandReleaseDestination(state,World(state.frame,point))
        end
        local last=state.route.waypoints[#state.route.waypoints]
        local dx,dz=last.x-state.spawnLocal.x,last.z-state.spawnLocal.z
        local length=math.sqrt(dx*dx+dz*dz)
        if length>.001 then
            local direction={x=dx/length,z=dz/length}
            local distance=UsesEngineerReleasePoint(state) and EngineerReleaseDistance(state,direction)
                or OutDistance(state,direction,length)
            positions[#positions+1]=LandReleaseDestination(state,World(state.frame,
                {x=state.spawnLocal.x+direction.x*distance,y=state.spawnLocal.y,
                z=state.spawnLocal.z+direction.z*distance}))
        end
    end
    local box={minX=math.huge,maxX=-math.huge,minZ=math.huge,maxZ=-math.huge}
    for _,position in ipairs(positions) do
        box.minX=math.min(box.minX,position.x+state.worldCollisionBounds.min.x-.05)
        box.maxX=math.max(box.maxX,position.x+state.worldCollisionBounds.max.x+.05)
        box.minZ=math.min(box.minZ,position.z+state.worldCollisionBounds.min.z-.05)
        box.maxZ=math.max(box.maxZ,position.z+state.worldCollisionBounds.max.z+.05)
    end
    for other,reserved in pairs(reservations) do
        if other.factory~=state.factory and Alive(other.unit) and not other.finished and box.minX<reserved.maxX and box.maxX>reserved.minX
            and box.minZ<reserved.maxZ and box.maxZ>reserved.minZ then return false end
    end
    reservations[state]=box
    return true
end

local function ReserveClearExit(state)
    if state.air or state.naval or state.engineerTransfer or state.config.domain~="land" then
        return Reserve(state)
    end
    -- Check every authored land exit before transit. A permanent obstruction
    -- must not commit Seraphim or other factories to an unusable first route.
    -- Keep the physical deck/ramp paths; never cut through factory geometry.
    local chosen=state.route
    local routes={chosen}
    for _,route in ipairs(state.config.exitRoutes) do
        if route~=chosen then routes[#routes+1]=route end
    end
    for _,route in ipairs(routes) do
        local heading=route.headingDegrees or 0
        local orientation=Engine.QuaternionRotateY(state.frame.rotation,math.rad(heading))
        local bounds=RotatedBounds(state.collisionBounds,orientation)
        local extentX,extentZ=Extents(state.collisionBounds,heading)
        local last=route.waypoints[#route.waypoints]
        local dx,dz=last.x-state.spawnLocal.x,last.z-state.spawnLocal.z
        local length=math.sqrt(dx*dx+dz*dz)
        assert(length>.001,"Factory clearance route has no horizontal exit")
        local probe={factory=state.factory,unit=state.unit,config=state.config,frame=state.frame,
            spawnLocal=state.spawnLocal,extentX=extentX,extentZ=extentZ,
            route=route,surfaceClearance=state.surfaceClearance,
            worldCollisionBounds=bounds,identityRotation=state.identityRotation}
        local direction={x=dx/length,z=dz/length}
        local distance=UsesEngineerReleasePoint(state) and EngineerReleaseDistance(probe,direction)
            or OutDistance(probe,direction,length)
        local destination=World(state.frame,{x=state.spawnLocal.x+dx/length*distance,
            y=last.y,z=state.spawnLocal.z+dz/length*distance})
        destination.y=Ground(state,destination)
        probe.position=Copy(state.position)
        for _,point in ipairs(route.waypoints) do
            probe.position.y=math.max(probe.position.y,
                state.frame.position.y+point.y+state.surfaceClearance)
        end
        -- This straight-ramp envelope includes every deck/ramp height and the
        -- final lowering. Per-step sweeps still protect against later arrivals.
        local clear=CorridorClear(probe,destination)
        if not clear then
            -- A rotated whole-route AABB can contain adjacent structures that
            -- never intersect the authored ramp. Refine only that failed broad
            -- sweep; transit still checks every actual submitted interval.
            probe.position=Copy(state.position)
            clear=AuthoredLandExitClear(probe,destination)
        end
        if clear then
            local previous={state.route,state.orientation,state.worldCollisionBounds,state.extentX,state.extentZ}
            state.route,state.orientation,state.worldCollisionBounds,state.extentX,state.extentZ=
                route,orientation,bounds,extentX,extentZ
            if Reserve(state) then
                Hold(state,state.position)
                return true
            end
            state.route,state.orientation,state.worldCollisionBounds,state.extentX,state.extentZ=unpack(previous)
        end
    end
    state.blocked=true
    return false
end

local function FindPhaseEndpoint(probe,owner)
    local last=probe.route.waypoints[#probe.route.waypoints]
    local dx,dz=last.x-probe.spawnLocal.x,last.z-probe.spawnLocal.z
    local length=math.sqrt(dx*dx+dz*dz)
    local forward=Engine.QuaternionRotateVector(probe.frame.rotation,EngineClasses.float3(dx/length,0,dz/length))
    probe.phaseExtending=true
    local steps=0
    while Alive(owner.unit) and not owner.finished do
        if PhaseReleaseClear(probe) then return true end
        local nextPoint=EngineClasses.float3(probe.position.x+forward.x*.25,probe.position.y,
            probe.position.z+forward.z*.25)
        if not PhaseTerrainClear(probe,nextPoint) or not LandSegmentClear(probe,nextPoint) then return false end
        steps=steps+1
        if steps%64==0 then Hold(owner,owner.position);WaitTicks(1) end
    end
    return false
end

local function ExtendPhaseExit(state,speed)
    if _G.Time<(state.phaseNextExtension or 0) then return false end
    state.phaseNextExtension=_G.Time+.5
    local probe={}
    for key,value in pairs(state) do probe[key]=value end
    probe.position=Copy(state.position)
    probe.phasedStructures={}
    for key,value in pairs(state.phasedStructures) do probe.phasedStructures[key]=value end
    probe.phaseTerrainCache=nil;probe.phaseTerrainTime=nil
    if not FindPhaseEndpoint(probe,state) or Distance(state.position,probe.position)<.00001 then return false end
    local endpoint,reserved,crossed=state.phaseEndpoint,reservations[state],state.phasedStructures
    state.phaseEndpoint=Copy(probe.position);state.phasedStructures=probe.phasedStructures
    reservations[state]=nil
    if not Reserve(state) then
        state.phaseEndpoint=endpoint;state.phasedStructures=crossed;reservations[state]=reserved
        return false
    end
    if not Segment(state,state.phaseEndpoint,speed) then return false end
    WaitTicks(1)
    return true
end

local function ReserveStructureExit(state)
    if state.air or state.naval or state.engineerTransfer or state.config.domain~="land"
        or not state.releaseRequested or not state.completionSeen or not state.unit:IsCompleted() then return false end
    local now=_G.Time
    state.phaseBlockedSince=state.phaseBlockedSince or now
    if now-state.phaseBlockedSince<1 or now<(state.phaseNextAttempt or 0) then return false end
    state.phaseNextAttempt=now+.5
    local routes={state.route}
    for _,route in ipairs(state.config.exitRoutes) do
        if route~=state.route then routes[#routes+1]=route end
    end
    for _,route in ipairs(routes) do
        local heading=route.headingDegrees or 0
        local orientation=Engine.QuaternionRotateY(state.frame.rotation,math.rad(heading))
        local extentX,extentZ=Extents(state.collisionBounds,heading)
        local probe={factory=state.factory,unit=state.unit,config=state.config,frame=state.frame,
            spawnLocal=state.spawnLocal,route=route,surfaceClearance=state.surfaceClearance,
            extentX=extentX,extentZ=extentZ,collisionBounds=state.collisionBounds,
            worldCollisionBounds=RotatedBounds(state.collisionBounds,orientation),
            identityRotation=state.identityRotation,position=Copy(state.position),
            structurePassThrough=true,phasedStructures={}}
        probe.phaseEnvelope=PhaseEnvelope(probe)
        probe.worldCollisionBounds=PhaseTransitBounds(probe)
        local last=route.waypoints[#route.waypoints]
        local dx,dz=last.x-state.spawnLocal.x,last.z-state.spawnLocal.z
        local length=math.sqrt(dx*dx+dz*dz)
        local direction={x=dx/length,z=dz/length}
        local distance=UsesEngineerReleasePoint(state) and EngineerReleaseDistance(probe,direction)
            or OutDistance(probe,direction,length)
        local endpoint=World(state.frame,{x=state.spawnLocal.x+direction.x*distance,y=last.y,
            z=state.spawnLocal.z+direction.z*distance})
        if AuthoredLandExitClear(probe,endpoint) then
            local found=FindPhaseEndpoint(probe,state)
            if found and Alive(state.unit) and not state.finished then
                local previous={state.route,state.orientation,state.worldCollisionBounds,state.extentX,state.extentZ}
                state.route,state.orientation,state.worldCollisionBounds,state.extentX,state.extentZ=
                    route,orientation,probe.worldCollisionBounds,extentX,extentZ
                state.structurePassThrough=true
                state.phasedStructures=probe.phasedStructures
                state.phaseEnvelope=probe.phaseEnvelope
                state.phaseEndpoint=Copy(probe.position)
                if Reserve(state) then
                    state.phaseBlockedSince=nil
                    Hold(state,state.position)
                    return true
                end
                state.structurePassThrough=nil;state.phasedStructures=nil;state.phaseEnvelope=nil;state.phaseEndpoint=nil
                state.route,state.orientation,state.worldCollisionBounds,state.extentX,state.extentZ=unpack(previous)
            end
        end
    end
    return false
end

BeginStructureTransit=function(state,destination)
    if state.air or state.naval or state.engineerTransfer or state.config.domain~="land"
        or not state.completionSeen or not state.unit:IsCompleted() then return false end
    local now=_G.Time
    state.phaseBlockedSince=state.phaseBlockedSince or now
    if now-state.phaseBlockedSince<1 or now<(state.phaseNextAttempt or 0) then return false end
    state.phaseNextAttempt=now+.5
    local probe={}
    for key,value in pairs(state) do probe[key]=value end
    probe.position=Copy(state.position);probe.structurePassThrough=true;probe.phasedStructures={}
    probe.phaseEnvelope=PhaseEnvelope(probe);probe.worldCollisionBounds=PhaseTransitBounds(probe)
    probe.phaseTerrainCache=nil;probe.phaseTerrainTime=nil
    if not LandSegmentClear(probe,destination) then return false end
    for index=(state.egressWaypointIndex or #state.route.waypoints)+1,#state.route.waypoints do
        if not LandSegmentClear(probe,RouteWaypoint(probe,state.route.waypoints[index])) then return false end
    end
    local last=state.route.waypoints[#state.route.waypoints]
    local dx,dz=last.x-state.spawnLocal.x,last.z-state.spawnLocal.z
    local length=math.sqrt(dx*dx+dz*dz)
    local direction={x=dx/length,z=dz/length}
    local distance=UsesEngineerReleasePoint(state) and EngineerReleaseDistance(probe,direction)
        or OutDistance(probe,direction,length)
    local final=World(state.frame,{x=state.spawnLocal.x+direction.x*distance,y=state.spawnLocal.y,
        z=state.spawnLocal.z+direction.z*distance})
    final.y=probe.position.y
    if not LandSegmentClear(probe,final) then return false end
    final=Copy(probe.position);final.y=Ground(probe,final)
    if not LandSegmentClear(probe,final) or not FindPhaseEndpoint(probe,state) then return false end
    local reserved=reservations[state]
    local priorBounds=state.worldCollisionBounds
    state.structurePassThrough=true;state.phasedStructures=probe.phasedStructures
    state.phaseEnvelope=probe.phaseEnvelope;state.phaseEndpoint=Copy(probe.position)
    state.worldCollisionBounds=probe.worldCollisionBounds
    reservations[state]=nil
    if not Reserve(state) then
        state.structurePassThrough=nil;state.phasedStructures=nil;state.phaseEnvelope=nil;state.phaseEndpoint=nil
        state.worldCollisionBounds=priorBounds;reservations[state]=reserved
        return false
    end
    state.phaseBlockedSince=nil
    return true
end

local function LowerPlatform(state)
    local clip=state.platformClip
    if not clip or not clip.attachmentPath then return true end
    state.platformLowering=true
    local path=clip.attachmentPath
    local start=path[1].position
    local base=Copy(state.position)
    local elapsed,previousTime=0,_G.Time
    while Alive(state.unit) and not state.finished do
        local delta=math.max(0,_G.Time-previousTime);previousTime=_G.Time
        local time=math.min(clip.duration,elapsed+delta)
        local point=path[#path].position
        for index=2,#path do
            local left,right=path[index-1],path[index]
            if time<=right.time then
                local t=(time-left.time)/(right.time-left.time)
                point={x=left.position.x+(right.position.x-left.position.x)*t,
                    y=left.position.y+(right.position.y-left.position.y)*t,
                    z=left.position.z+(right.position.z-left.position.z)*t}
                break
            end
        end
        local offset=Engine.QuaternionRotateVector(state.frame.rotation,
            EngineClasses.float3(point.x-start.x,point.y-start.y,point.z-start.z))
        local destination=EngineClasses.float3(base.x+offset.x,base.y+offset.y,base.z+offset.z)
        if CorridorClear(state,destination) then
            elapsed,state.platformTime,state.blocked=time,time,false
            Hold(state,destination)
            if time>=clip.duration then state.platformLowering=false;return true end
        else
            state.blocked=true
            Hold(state,state.position)
        end
        WaitTicks(1)
    end
    return false
end

local function ReleasePath(state)
    local config,unit=state.config,state.unit
    if state.air then
        -- Native takeoff owns the vertical curve and airborne layers. Ground
        -- ramps and their reservations must never become an aircraft runway.
        WaitTicks(1)
        while Alive(unit) and not state.finished do
            local point=Copy(state.position)
            local status,height=Engine.SampleTerrainHeight(point)
            assert(status==EngineErrorCode.Success,"Factory takeoff terrain sample failed")
            point.y=height+Preferred(unit)
            if CorridorClear(state,point) then
                state.blocked=false
                Restore(state,true)
                return
            end
            state.blocked=true
            Hold(state,state.position)
            WaitTicks(1)
        end
        return
    end
    local speed=math.max(.1,unit.tp.movement.speed or 1.5)
    if state.engineerTransfer then
        local release=config.engineerRoute
        local direction=release.direction
        local magnitude=math.sqrt(direction.x^2+direction.z^2)
        assert(magnitude>.001,"Factory engineer release direction missing")
        direction={x=direction.x/magnitude,z=direction.z/magnitude}
        local distance=OutDistance(state,direction,math.max(release.sourceOutDistance or 3,release.minimumOutDistance or 0))
        if not LowerPlatform(state) then return end
        local start=state.spawnLocal
        local point=World(state.frame,{x=start.x+direction.x*distance,y=start.y,z=start.z+direction.z*distance})
        point.y=state.position.y
        if not Segment(state,point,release.sourceSpeed or 1.5) then return end
        -- Lower only after the whole product, including its trailing extent, clears.
        local ground=Copy(point);ground.y=Ground(state,ground)
        if not Segment(state,ground,release.sourceSpeed or 1.5) then return end
    else
        Gait(state)
        local points=state.route.waypoints
        for index,point in ipairs(points) do
            state.egressWaypointIndex=index
            local destination=RouteWaypoint(state,point)
            if not Segment(state,destination,speed) then return end
        end
        local last=points[#points]
        state.egressWaypointIndex=#points+1
        local dx,dz=last.x-state.spawnLocal.x,last.z-state.spawnLocal.z
        local length=math.sqrt(dx*dx+dz*dz)
        assert(length>.001,"Factory clearance route has no horizontal exit")
        local direction={x=dx/length,z=dz/length}
        local clearance=UsesEngineerReleasePoint(state) and EngineerReleaseDistance(state,direction)
            or OutDistance(state,direction,length)
        local final=World(state.frame,{x=state.spawnLocal.x+direction.x*clearance,y=state.spawnLocal.y,
            z=state.spawnLocal.z+direction.z*clearance})
        final.y=state.position.y
        if not Segment(state,final,speed) then return end
        -- OutDistance includes the entire product extent and a .25 margin
        -- beyond the factory's swept horizontal bounds.
        if LoweredIdle[state.factory.tpId] then state.factoryEnvelopeCleared=true end
        final=Copy(final);final.y=Ground(state,final)
        if not Segment(state,final,speed) then return end
    end
    if state.phaseEndpoint then
        state.phaseExtending=true
        if not Segment(state,state.phaseEndpoint,speed) then return end
    end
    -- Do not release collision before the final transform reaches native world state.
    WaitTicks(1)
    while Alive(unit) and not state.finished do
        local waterClear=not state.naval or SubmergedLine(state.factory,state.config,state.position,state.position)
        if waterClear and (state.structurePassThrough and PhaseReleaseClear(state)
            or not state.structurePassThrough and CorridorClear(state,state.position)) then
            state.blocked=false
            Restore(state,true)
            return
        end
        -- Another unit may have entered during the transform synchronization tick.
        state.blocked=true
        Hold(state,state.position)
        if state.structurePassThrough then
            ExtendPhaseExit(state,speed)
        elseif BeginStructureTransit(state,state.position) then
            state.phaseExtending=true
            if not Segment(state,state.phaseEndpoint,speed) then return end
            WaitTicks(1)
        end
        WaitTicks(1)
    end
end

local function Driver(unit,state)
    while Alive(unit) and not state.finished do
        if state.releaseRequested and unit:IsCompleted() and state.completionSeen and PostureReady(state)
            and not (unit.tpId=="ugl4002" and unit.scoMegalithAwakeControl==true) then
            local routeReady=true
            if LoweredIdle[state.factory.tpId] and state.config.clearanceRig and Alive(state.factory) then
                if not state.clearanceReady then
                    Hold(state,state.position)
                    state.clearanceReady=AwaitClearance(state.factory,1,function()
                        return state.releaseRequested and Alive(unit) and not state.finished
                    end)
                end
                routeReady=state.clearanceReady or not Alive(state.factory)
            end
            if routeReady then
                local waterClear=not state.naval or NavalRouteClear(state.factory,state.config,state.frame,state.route,unit)
                if waterClear and (state.air or ReserveClearExit(state) or ReserveStructureExit(state)) then
                    state.phaseBlockedSince=nil
                    state.egressing=true
                    PostureGoal(state,1,true)
                    ReleasePath(state)
                    if not state.finished then Restore(state,false) end
                    return
                end
            end
        end
        if not Alive(state.factory) and not unit:IsCompleted() then
            Restore(state,false)
            if Alive(unit) then unit:Delete() end
            return
        end
        Hold(state,state.position)
        WaitTicks(1)
    end
    Restore(state,false)
end

local function Prepare(factory,unit,config)
    local previous=factory.scoFactoryEgressState
    if previous and not previous.finished then
        assert(previous.unit==unit and previous.key==Key(unit),"Factory attempted overlapping products")
        Hold(previous,previous.position)
        return previous
    end
    config=ProductConfig(config,unit.tpId)
    local frame=Frame(factory)
    local air=unit:HasTags(Tags.AIR)
    local naval=not air and (unit:HasTags(Tags.NAVAL) or not unit:HasTags(Tags.LAND))
        and (config.domain=="naval" or config.domain=="sea")
    local route,rally=SelectRoute(factory,config,frame,naval,unit)
    local engineerTransfer=not air and config.domain=="air" and config.engineerRoute~=nil
    local heading=route.headingDegrees or 0
    if engineerTransfer then
        local direction=config.engineerRoute.direction
        heading=math.deg(math.atan2(direction.x,direction.z))
    end
    local bounds=ProductBounds(config,unit)
    local collisionBounds=CollisionBounds(config,unit)
    local extentX,extentZ=Extents(collisionBounds,heading)
    local spawn,surfaceClearance,release=SpawnLocal(config,unit,route,engineerTransfer,air,naval,bounds)
    local _,collider=Engine.GetVolumeColliderEnabled(unit.id)
    local state={factory=factory,unit=unit,config=config,key=Key(unit),frame=frame,route=route,rally=rally,
        rallySource=factory.unitBeingBuiltSource or factory,
        bounds=bounds,collisionBounds=collisionBounds,extentX=extentX,extentZ=extentZ,surfaceClearance=surfaceClearance,
        air=air,naval=naval,engineerTransfer=engineerTransfer,spawnLocal=spawn,position=World(frame,spawn),
        orientation=Engine.QuaternionRotateY(frame.rotation,math.rad(heading)),
        platformClip=(release and release.platformClip) or config.platformClip,original={},resolved={},
        colliderOnRelease=collider==true or (unit.IsPlacementGhost and unit:IsPlacementGhost())==true,
        completionSeen=false,postureRig=PostureRig(factory,unit)}
    state.worldCollisionBounds=RotatedBounds(collisionBounds,state.orientation)
    state.identityRotation=Engine.EulerToQuaternion(EngineClasses.float3(0,0,0),RotationOrder.Default)
    for _,name in ipairs(methods) do state.original[name]=rawget(unit,name);state.resolved[name]=unit[name] end
    factory.scoFactoryEgressState=state
    factory.scoFactoryLastEgress=nil
    unit.scoFactoryEgressState=state
    heldProducts[state]=true
    unit.OnStopBeingBuilt=function(child,...)
        if state.completionSeen then return end
        state.completionSeen=true
        state.resolved.OnStopBeingBuilt(child,...)
        -- Pause retains the native build sampler, even if assistance completes
        -- the product. Completed platform transfer now owns this factory pose.
        if state.platformClip and state.platformClip.attachmentPath
            and factory.faAirFactoryBuildTarget==child then
            local lifecycle=_G.SCOFaAirFactoryLifecycle
            if lifecycle then lifecycle.CancelBuild(factory) end
        end
        Hold(state,state.position)
    end
    unit.UpdateAnimations=function() end
    unit.SetPosition=function() end
    unit.SetOrientation=function() end
    unit.MoveIntoRangeBehaviorIsValidFor=function() return false end
    if state.resolved.TakeoffBehaviourStart then
        unit.TakeoffBehaviourStart=function() state.takeoffPending=true end
    end
    if state.resolved.LandingBehaviorStart then unit.LandingBehaviorStart=function() end end
    unit.OnDestroy=function(child,...)
        Restore(state,false)
        return state.resolved.OnDestroy(child,...)
    end
    unit.Delete=function(child,...)
        Restore(state,false)
        return state.resolved.Delete(child,...)
    end
    PostureGoal(state,1,true)
    Hold(state,state.position)
    state.thread=unit:NewThread(Driver,state)
    return state
end

local function Interrupt(factory)
    local state=factory.scoFactoryEgressState
    if not state or state.finished then return end
    if Alive(state.unit) and state.unit:IsCompleted() then
        state.releaseRequested=true
    else
        Restore(state,false)
    end
end

function M.Install(class,mobileStopBase)
    if installed[class] then return end
    installed[class]=true
    local completed=class.OnStopBeingBuilt
    if completed then
        class.OnStopBeingBuilt=function(self,...)
            local result=completed(self,...)
            if Alive(self) and self:IsCompleted() then
                if LoweredIdle[self.tpId] then ClearanceGoal(self,0)
                else ClearanceGoal(self,1) end
            end
            return result
        end
    end
    local buildOne=class.ProductionBehaviorBuildOne
    if buildOne then
        class.ProductionBehaviorBuildOne=function(self,item,...)
            local config=Config(self)
            if config then
                while Alive(self) and self.buildQueue and self.buildQueue[1]==item
                    and HasDepartingProduct(self)
                    and not (LoweredIdle[self.tpId] and DeparturesClearPad(self,item)
                        or not LoweredIdle[self.tpId] and BuildPadClear(self,item)) do WaitTicks(1) end
                if not Alive(self) or not self.buildQueue or self.buildQueue[1]~=item then return end
            end
            if config and config.clearanceRig then
                local function valid()
                    return self.buildQueue and self.buildQueue[1]==item
                        and not self.upgradeBehaviorIsActive
                        and not (self.IsUpgrading and self:IsUpgrading())
                end
                local goal=LoweredIdle[self.tpId] and 0 or 1
                if not valid() or not AwaitClearance(self,goal,valid) then return end
            end
            local result=buildOne(self,item,...)
            CloseIfIdle(self)
            return result
        end
    end
    local upgradeThread=class.UpgradeBehaviorThread
    if upgradeThread then
        class.UpgradeBehaviorThread=function(self,...)
            local config=Config(self)
            if config then
                -- A replacement factory must not close around an owned departure.
                while Alive(self) and HasDepartingProduct(self) do WaitTicks(1) end
            end
            if config and config.clearanceRig then
                local function valid() return self.upgradeBehaviorIsActive==true end
                if not valid() or not AwaitClearance(self,0,valid) then return end
            end
            return upgradeThread(self,...)
        end
    end
    local upgradeStop=class.UpgradeBehaviorStop
    if upgradeStop then
        class.UpgradeBehaviorStop=function(self,...)
            local wasActive=self.upgradeBehaviorIsActive
            local result=upgradeStop(self,...)
            if wasActive and Alive(self) and self:IsCompleted() then
                if LoweredIdle[self.tpId] then CloseIfIdle(self)
                else ClearanceGoal(self,1) end
            end
            return result
        end
    end
    local spawn=class.GetConstructionSpawnPoint
    class.GetConstructionSpawnPoint=function(self,...)
        local config=Config(self)
        if not config then return spawn(self,...) end
        local frame=Frame(self)
        local item=self.buildQueue and self.buildQueue[1]
        local template=item and __Templates and __Templates.Units and __Templates.Units[item.tpId]
        if not template then return World(frame,config.buildOffset) end
        config=ProductConfig(config,item.tpId)
        local product={tpId=item.tpId,tp=template}
        local air=Tags.AIR[item.tpId]==true
        local naval=not air and (Tags.NAVAL[item.tpId] or not Tags.LAND[item.tpId])
            and (config.domain=="naval" or config.domain=="sea")
        local transfer=not air and config.domain=="air" and config.engineerRoute~=nil
        local route=SelectRoute(self,config,frame,naval,product)
        local point,_,release=SpawnLocal(config,product,route,transfer,air,naval,ProductBounds(config,product))
        local clip=(release and release.platformClip) or config.platformClip
        if clip then
            Platform({factory=self,platformClip=clip})
        end
        return World(frame,point)
    end
    local start=class.OnStartBuildRoutine
    class.OnStartBuildRoutine=function(self,unit,...)
        local config=Config(self)
        if not config or not Mobile(self,unit) or self.scoEgressStartDepth then return start(self,unit,...) end
        self.scoEgressStartDepth=true
        local state=Prepare(self,unit,config)
        local result=start(self,unit,...)
        self.scoEgressStartDepth=nil
        Hold(state,state.position)
        return result
    end
    local stop=class.OnStopBuildRoutine
    class.OnStopBuildRoutine=function(self,unit,...)
        local state=self.scoFactoryEgressState
        if not state or state.unit~=unit or state.finished or self.scoEgressStopDepth then return stop(self,unit,...) end
        self.scoEgressStopDepth=true
        local result=(mobileStopBase or stop)(self,unit,...)
        self.scoEgressStopDepth=nil
        if Alive(unit) then
            if unit:IsCompleted() then state.releaseRequested=true end
            Hold(state,state.position)
        else Restore(state,false) end
        return result
    end
    for _,name in ipairs({"ReleaseBuiltUnit","ReleaseAeonFactoryBuiltUnit"}) do
        local original=class[name]
        if original then
            class[name]=function(self,unit,...)
                local state=self.scoFactoryEgressState
                if state and state.unit==unit and not state.finished then
                    Hold(state,state.position)
                    return false -- Held, not released; skip legacy collider-verifier threads.
                end
                return original(self,unit,...)
            end
        end
    end
    local roll=class.RollOffUnit
    class.RollOffUnit=function(self,unit,...)
        local config=Config(self)
        if config and not Alive(unit) then return end
        if not config or not Mobile(self,unit) then return roll(self,unit,...) end
        local state=self.scoFactoryEgressState
        if not state then
            local completed=self.scoFactoryLastEgress
            if completed and completed.unit==unit and completed.key==Key(unit) and completed.finished then return end
        end
        assert(state and state.unit==unit and state.key==Key(unit),"Completed factory product lost release owner")
        state.releaseRequested=true
        while not state.finished and Alive(unit) do
            if ReleaseBuildPad(state,self.buildQueue and self.buildQueue[1]) then return end
            WaitTicks(1)
        end
    end
    local valid=class.ProductionBehaviorIsValidFor
    class.ProductionBehaviorIsValidFor=function(self,...)
        local state=self.scoFactoryEgressState
        if state and not state.finished and (state.egressing or state.releaseRequested)
            and not ReleaseBuildPad(state,self.buildQueue and self.buildQueue[1]) then return false end
        return valid(self,...)
    end
    local productionStop=class.ProductionBehaviorStop
    class.ProductionBehaviorStop=function(self,...)
        local prior=self.scoFactoryEgressState
        Interrupt(self)
        local result=productionStop(self,...)
        if prior and not Alive(self) and Alive(prior.unit) and not prior.unit:IsCompleted() then prior.unit:Delete() end
        local state=self.scoFactoryEgressState
        if state then Hold(state,state.position) end
        CloseIfIdle(self)
        return result
    end
    local destroy=class.OnDestroy
    class.OnDestroy=function(self,...)
        local prior=self.scoFactoryEgressState
        Interrupt(self)
        local result=destroy(self,...)
        if prior and Alive(prior.unit) and not prior.unit:IsCompleted() then prior.unit:Delete() end
        return result
    end
    local animation=class.UpdateAnimations
    if animation then
        class.UpdateAnimations=function(self,...)
            local state=self.scoFactoryEgressState
            if state and not state.finished and state.platformClip then Platform(state);return end
            return animation(self,...)
        end
    end
end

-- Native Import returns this module environment; plain Lua loaders keep the return API.
local moduleEnvironment = getfenv(1)
for name, value in pairs(M) do moduleEnvironment[name] = value end
return M
