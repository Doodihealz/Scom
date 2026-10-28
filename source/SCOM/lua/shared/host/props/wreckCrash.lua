-- SCOM naval seabed settling 2.4.0
--- Ballistic crash motion for the wreckage an air or naval unit leaves behind.
---
--- The wreck IS the crash actor: it is spawned in the unit's pose at death and the unit is deleted
--- immediately, so everything below animates a HostWreckage prop, not a unit.
---
--- A crash runs as at most two phases on the wreck's own thread:
---   fall - ballistic arc with air drag, tumble and lateral drift, until the wreck hits terrain or
---          crosses the water surface;
---   sink - buoyancy-damped descent with a wobble about the attitude it entered the water with,
---          until it reaches the seabed.
--- Naval units skip straight to the sink phase - they are already in the water.
---

local Water = Import("common/water.lua")
local MapUtils = Import("common/mapUtils.lua")

-- Crash constants
local CrashGravity                            = 10.0 -- fall acceleration (world units / s^2)
local CrashDrag                               = 0.3  -- horizontal speed decay (fraction / s)
local CrashDragGrowthRate                     = 0.6  -- exponential growth of air drag (per second)
local CrashSpinRollDegreesStandardDeviation   = 240  -- standard deviation of tumble rate about the forward axis (degrees / s)
local CrashSpiralYawDegreesStandardDeviation  = 75   -- standard deviation of visual yaw spin (degrees / s)
local CrashLateralDriftSpeedStandardDeviation = 1.5  -- standard deviation of lateral drift speed (world units / s)
local CrashPitchInRate                        = 45   -- how fast the nose drops toward the velocity vector (degrees / s)
local CrashMaxPitchDown                       = 70   -- pitch-down clamp (degrees)
local CrashMaxSeconds                         = 30   -- end the crash after this long no matter what
local CrashScaleDefault                       = 1.0  -- baseline crash scale; scales fall accel, rotation, and drift
local CrashScaleLarge                         = 0.33 -- crash scale for T4/T5 air units

-- Sinking constants
local CrashWaterEntryDragInitial              = 8.0  -- water drag applied at the moment of impact
local CrashWaterEntryDragDuration             = 0.4  -- seconds to transition from entry drag to normal sink drag
local CrashSinkGravity                        = 4.0  -- buoyancy-damped sink acceleration (world units / s^2)
local CrashSinkDrag                           = 1.5  -- water drag (fraction / s)
local CrashSinkWobbleDegrees                  = 20   -- amplitude of the underwater rocking (degrees)
local CrashSinkWobbleDegreesLarge             = 5    -- subdued rocking for large aircraft
local CrashSinkWobblePitchRate                = 2.2  -- pitch wobble angular frequency (radians / s)
local CrashSinkWobbleRollRate                 = 2.7  -- roll wobble angular frequency (radians / s)

local SnapWreckToUp = false -- flatten the settled wreck to upright (yaw-only); false keeps its final crash pose

local Up = EngineClasses.float3(0, 1, 0)
local Right = EngineClasses.float3(1, 0, 0)
local Forward = EngineClasses.float3(0, 0, 1)

--- Returns a sample from an approximated standard normal distribution.
local function RandomGaussian()
    return (math.random() + math.random() + math.random()) * 2.0 - 3.0
end

--- Returns a normally distributed rotation rate in radians per second.
local function RandomGaussianRateRadians(standardDeviationDegrees)
    return math.rad(standardDeviationDegrees) * RandomGaussian()
end

---@class WreckCrash State shared by both crash phases.
---@field wreck HostWreckage The wreck being animated.
---@field position float3 Current world position, mutated in place.
---@field velocity float3 Current velocity (world units / s), mutated in place.
---@field deleteAtRest boolean Delete the wreck once it settles.
---@field crashScale number Scales fall/sink acceleration, rotation, and drift (lower = slower, heavier-feeling crash).
---@field elapsed number Seconds since the crash began. One budget across BOTH phases - see CrashMaxSeconds.
---@field driftX number Lateral drift folded into the velocity on water entry.
---@field driftZ number
---@field yawRadians number Current pose, written to the wreck every tick.
---@field pitchRadians number
---@field rollRadians number
---@field sinkPitchRadians number Attitude the wreck entered the water with; the wobble oscillates about it.
---@field sinkRollRadians number

---Builds the state both crash phases share.
---@return WreckCrash
local function NewWreckCrash(wreck, position, velocity, headingRadians, deleteAtRest, crashScale)
    local hasWater = Water.HasWater()
    local waterLevel = Water.GetLevel() or 0

    return {
        wreck = wreck,
        position = position,
        velocity = velocity,
        deleteAtRest = deleteAtRest,
        crashScale = crashScale,

        hasWater = hasWater,
        waterLevel = waterLevel,

        elapsed = 0,
        driftX = 0,
        driftZ = 0,

        yawRadians = headingRadians,
        pitchRadians = 0,
        rollRadians = 0,
        sinkPitchRadians = 0,
        sinkRollRadians = 0,
    }
end

---Ends the crashing.
---@param crash WreckCrash
---@param impactPosition float3
local function SettleWreck(crash, impactPosition)
    local wreck = crash.wreck
    wreck.scoWaterWreckSettling = false

    if crash.scoNaval then
        wreck.scoNavalSinking = false
        Import("common/commands/definitions/props.lua").SCO_NavalWreckPhase.Send(wreck.id, true)
        wreck:StartReclaimProcess()
    end
    Engine.SetRayColliderEnabled(wreck.id, false)
    Engine.SetGlobalEntityPosition(wreck.id, impactPosition)

    if SnapWreckToUp then
        Engine.SetGlobalEntityLocalRotation(wreck.id, Engine.QuaternionAxisAngle(Up, crash.yawRadians))
    end

    if crash.deleteAtRest then
        wreck:Delete()
    end
end

---Integrats wreackage position, tests for impact, and push the pose
---to the engine. Common to both crash phases (falling/sinking).
---@param crash WreckCrash
---@return boolean settled True when the crash has ended and the phase loop should stop.
local function PublishAircraftCrashContact(crash, position, dryGroundContact)
    local wreck = crash.wreck
    if not crash.scoAircraft or wreck.scoAircraftCrashContactPosition then return end
    wreck.scoAircraftCrashContactPosition = EngineClasses.float3(
        position.x, position.y, position.z)
    -- The contact latch also prevents water entry/seabed and repeated impact
    -- callbacks from creating extra decals. Publish before damage can delete the actor.
    if dryGroundContact and crash.scoAircraftCrashScorch then
        SendToAllClients({
            tpId = wreck.unitTpId,
            position = { x = position.x, y = position.y, z = position.z },
        }, "SCOAircraftCrashImpactScorch")
    end
    if dryGroundContact and crash.scoTreeImpactRadius then
        Import("common/loading/unitTemplateLoader.lua").SCOMTreeKnockdown.Impact(
            position, crash.scoTreeImpactRadius)
    end
    -- Damage observers consume the physics-owned contact before an overkill
    -- wreck can be deleted. Retained ray events never authorize this call.
    Import("host/collisionUpdate.lua").SCO_ApplyAircraftCrashContact(wreck)
end

local function WreckCrashStep(crash)
    local dt = Constants.TickTimeStep
    local position = crash.position
    local velocity = crash.velocity

    position.x = position.x + (velocity.x + crash.driftX) * dt
    position.y = position.y + velocity.y * dt * (crash.scoNaval and 0.4 or 1)
    position.z = position.z + (velocity.z + crash.driftZ) * dt

    -- Terrain samples fail beyond the map. Stop lateral drift at the edge so
    -- aircraft and naval wrecks can finish their physical landing/sinking.
    local width, length = MapUtils.GetMapSize()
    local x = math.max(0.01, math.min(width - 0.01, position.x))
    local z = math.max(0.01, math.min(length - 0.01, position.z))
    if position.x ~= x then
        position.x, velocity.x, crash.driftX = x, 0, 0
    end
    if position.z ~= z then
        position.z, velocity.z, crash.driftZ = z, 0, 0
    end

    local impactPosition = crash.wreck.crashImpactPosition
    if crash.scoNaval then
        local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)
        if terrainResult == EngineErrorCode.Success then
            crash.scoNavalLastTerrainHeight = terrainHeight
        else
            terrainHeight = crash.scoNavalLastTerrainHeight
        end
        -- Current terrain owns contact. The death-time sample remains a safe
        -- fallback if drift leaves the map or a later query becomes unavailable.
        impactPosition = nil
        if terrainHeight ~= nil then
            local previousY = position.y - velocity.y * dt * 0.4
            local clearance = math.max(0, previousY - terrainHeight)
            local remaining = math.max(dt, CrashMaxSeconds - crash.elapsed)
            local descent = math.max(0, -velocity.y * dt * 0.4,
                clearance * dt / remaining)
            position.y = math.max(terrainHeight, previousY - descent)
            if position.y <= terrainHeight + 0.01 then
                impactPosition = EngineClasses.float3(position.x, terrainHeight, position.z)
            end
        end

        if impactPosition then
            SettleWreck(crash, impactPosition)
            return true
        end

        if not crash.scoNavalRotation then
            local result, rotation = Engine.GetGlobalEntityLocalRotation(crash.wreck.id)
            if result == EngineErrorCode.Success then crash.scoNavalRotation = rotation end
        end
        local entry = math.min(crash.elapsed, 1)
        local clearance = terrainHeight ~= nil
            and math.max(0, position.y - terrainHeight) or 4
        local seabed = math.min(clearance / 4, 1)
        local amplitude = math.rad(5) * (entry * entry * (3 - 2 * entry))
            * (seabed * seabed * (3 - 2 * seabed))
        local wobbleTime = crash.elapsed * 0.5
        local baseRotation = crash.scoNavalRotation
            or Engine.QuaternionAxisAngle(Up, crash.yawRadians)
        local pitch = Engine.QuaternionAxisAngle(Right,
            math.sin(wobbleTime * CrashSinkWobblePitchRate) * amplitude)
        local roll = Engine.QuaternionAxisAngle(Forward,
            math.sin(wobbleTime * CrashSinkWobbleRollRate) * amplitude)
        local rotation = Engine.QuaternionMultiply(baseRotation,
            Engine.QuaternionMultiply(pitch, roll))
        Engine.SetGlobalEntityPosition(crash.wreck.id, position)
        Engine.SetGlobalEntityLocalRotation(crash.wreck.id, rotation)
        return false
    end
    if crash.scoAircraft then
        -- Retained ray hits can arrive ahead of the falling root. Terrain
        -- contact owns the end of this ballistic arc, never a stale hit pose.
        local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)
        impactPosition = nil
        if crash.scoRetainWaterWreck and terrainResult == EngineErrorCode.Success then
            crash.scoWaterWreckTerrainHeight = terrainHeight
        end
        if crash.scoRetainWaterWreck and crash.wreck.scoWaterWreckEnteredWater then
            if terrainResult ~= EngineErrorCode.Success then
                terrainHeight = crash.scoWaterWreckTerrainHeight
            end
            -- Heavy aircraft sink slowly. Reach the current seabed within the
            -- sinking budget instead of expiring halfway down a deep water column.
            if terrainHeight ~= nil then
                local previousY = position.y - velocity.y * dt
                local clearance = math.max(0, previousY - terrainHeight)
                local remaining = math.max(dt, CrashMaxSeconds - crash.sinkElapsed)
                local descent = math.max(0, -velocity.y * dt, clearance * dt / remaining)
                position.y = math.max(terrainHeight, previousY - descent)
            end
        end
        if terrainHeight ~= nil and (terrainResult == EngineErrorCode.Success
            or crash.scoWaterWreckTerrainHeight ~= nil) and position.y <= terrainHeight then
            impactPosition = EngineClasses.float3(position.x, terrainHeight, position.z)
        end
    end

    if not impactPosition and not crash.scoAircraft and not crash.scoNaval and crash.elapsed > CrashMaxSeconds then
        local _, terrainHeight = Engine.SampleTerrainHeight(position)
        impactPosition = EngineClasses.float3(position.x, terrainHeight, position.z)
    end

    if impactPosition then
        if crash.scoAircraft then
            Engine.SetGlobalEntityPosition(crash.wreck.id, impactPosition)
            PublishAircraftCrashContact(crash, impactPosition,
                not crash.hasWater or impactPosition.y >= crash.waterLevel)
        end
        SettleWreck(crash, impactPosition)
        return true
    end

    Engine.SetGlobalEntityPosition(crash.wreck.id, position)

    local yawRotation = Engine.QuaternionAxisAngle(Up, crash.yawRadians)
    local pitchRotation = Engine.QuaternionAxisAngle(Right, crash.pitchRadians)
    local rollRotation = Engine.QuaternionAxisAngle(Forward, crash.rollRadians)
    local rotation = Engine.QuaternionMultiply(yawRotation, Engine.QuaternionMultiply(pitchRotation, rollRotation))
    Engine.SetGlobalEntityLocalRotation(crash.wreck.id, rotation)

    return false
end

---Begins the sinking phase of the wreckage.
---@param crash WreckCrash
local function BeginSinking(crash)
    if crash.scoRetainWaterWreck then
        crash.wreck.scoWaterWreckEnteredWater = true
        local result, terrainHeight = Engine.SampleTerrainHeight(crash.position)
        if result == EngineErrorCode.Success then
            crash.scoWaterWreckTerrainHeight = terrainHeight
        end
    end
    if crash.scoAircraft then
        PublishAircraftCrashContact(crash, EngineClasses.float3(
            crash.position.x, crash.waterLevel, crash.position.z))
    end
    crash.velocity.x = crash.velocity.x + crash.driftX
    crash.velocity.z = crash.velocity.z + crash.driftZ
    crash.driftX, crash.driftZ = 0, 0

    crash.sinkPitchRadians = crash.pitchRadians
    crash.sinkRollRadians = crash.rollRadians
end

---Falls and tumbles the wreckage through the air.
---@param crash WreckCrash
---@return "settled"|"water"|"gone"
local function WreckCrashFall(crash)
    local dt = Constants.TickTimeStep

    local spinRollRate = RandomGaussianRateRadians(CrashSpinRollDegreesStandardDeviation) * crash.crashScale
    local spiralYawRate = RandomGaussianRateRadians(CrashSpiralYawDegreesStandardDeviation) * crash.crashScale

    local driftStandardDeviation = CrashLateralDriftSpeedStandardDeviation * crash.crashScale
    if crash.scoAircraft then
        crash.driftX, crash.driftZ = 0, 0
    else
        crash.driftX = RandomGaussian() * driftStandardDeviation
        crash.driftZ = RandomGaussian() * driftStandardDeviation
    end

    local fallAccel = CrashGravity * (crash.scoAircraft and 1 or crash.crashScale)
    local airDragRate = CrashDrag
    local airDragGrowthPerTick = math.exp(CrashDragGrowthRate * dt)

    while true do
        WaitTicks(1)

        if crash.wreck.deleted then return "gone" end

        crash.elapsed = crash.elapsed + dt

        local velocity = crash.velocity
        velocity.y = velocity.y - fallAccel * dt

        if not crash.scoAircraft then
            airDragRate = airDragRate * airDragGrowthPerTick
            local drag = math.max(0, 1 - airDragRate * dt)
            velocity.x = velocity.x * drag
            velocity.z = velocity.z * drag
        end

        crash.rollRadians = crash.rollRadians + spinRollRate * dt
        crash.yawRadians = crash.yawRadians + spiralYawRate * dt

        local horizontalSpeed = math.sqrt(velocity.x * velocity.x + velocity.z * velocity.z)
        local targetPitch = math.min(math.atan2(-velocity.y, horizontalSpeed), math.rad(CrashMaxPitchDown))
        crash.pitchRadians = math.min(crash.pitchRadians + math.rad(CrashPitchInRate) * dt, targetPitch)

        if WreckCrashStep(crash) then return "settled" end

        -- The terrain check keeps a wreck landing on ground that sits below sea level from "sinking".
        if crash.hasWater and crash.position.y <= crash.waterLevel then
            local result, terrainHeight = Engine.SampleTerrainHeight(crash.position)
            if result == EngineErrorCode.Success and terrainHeight < crash.waterLevel then
                BeginSinking(crash)
                return "water"
            end
        end
    end
end

---Sinks wreckage through the water column.
---@param crash WreckCrash
---@return "settled"|"gone"
local function WreckCrashSink(crash)
    local dt = Constants.TickTimeStep
    local sinkAccel = CrashSinkGravity * crash.crashScale
    local wobbleDegrees = crash.scoRetainWaterWreck and CrashSinkWobbleDegreesLarge or CrashSinkWobbleDegrees
    local wobbleAmplitude = math.rad(crash.scoNaval and 5 or wobbleDegrees)
    local sinkElapsed = 0

    while true do
        WaitTicks(1)

        if crash.wreck.deleted then return "gone" end

        crash.elapsed = crash.elapsed + dt
        sinkElapsed = sinkElapsed + dt
        crash.sinkElapsed = sinkElapsed

        local velocity = crash.velocity
        velocity.y = velocity.y - sinkAccel * dt

        local entryBlend = math.min(sinkElapsed / CrashWaterEntryDragDuration, 1.0)
        local currentDrag = CrashWaterEntryDragInitial + (CrashSinkDrag - CrashWaterEntryDragInitial) * entryBlend
        local drag = math.max(0, 1 - currentDrag * dt)
        velocity.x = velocity.x * drag
        velocity.y = velocity.y * drag
        velocity.z = velocity.z * drag

        if not crash.scoNaval then
            crash.pitchRadians = crash.sinkPitchRadians + math.sin(sinkElapsed * CrashSinkWobblePitchRate) * wobbleAmplitude
            crash.rollRadians = crash.sinkRollRadians + math.sin(sinkElapsed * CrashSinkWobbleRollRate) * wobbleAmplitude
        end

        if WreckCrashStep(crash) then return "settled" end
    end
end

---Runs the crash to completion. The ray collider is enabled for the whole crash - it is what
---reports the terrain hit that ends the fall, and the seabed hit that ends the sink.
---@param crash WreckCrash
---@param startSinking boolean? Skip the fall, for a wreck that is already in the water.
local function WreckCrashThread(crash, startSinking)
    Engine.SetRayColliderEnabled(crash.wreck.id, true)

    if startSinking or WreckCrashFall(crash) == "water" then
        WreckCrashSink(crash)
    end
end

---Spawns the unit's wreckage and starts its crash on the wreck's own thread.
---@param unit HostMobileUnit The dying unit; its pose and velocity seed the crash.
---@param overkillRatio number? Damage beyond what was needed to kill; >= 1 leaves no wreck behind.
---@param startSinking boolean? True for units that die already in the water, which skip the fall.
function StartWreckCrash(unit, overkillRatio, startSinking)
    local dt = Constants.TickTimeStep

    local _, speedPerTick = Engine.GetMovementCurrentSpeed(unit.id)
    local _, headingDegrees = Engine.GetMovementHeadingDegrees(unit.id)
    local headingRadians = math.rad(headingDegrees)
    local speed = speedPerTick / dt
    local velocity = EngineClasses.float3(math.sin(headingRadians) * speed, 0, math.cos(headingRadians) * speed)
    local _, position = Engine.GetGlobalEntityWorldPosition(unit.id)

    local deleteAtRest = (overkillRatio or 0) >= 1 or not unit.spawnsWreck or unit:GetFractionComplete() < 0.5
    local crashScale = (unit:HasTags(Tags.TECH4) or unit:HasTags(Tags.TECH5)) and CrashScaleLarge or CrashScaleDefault

    local wreckage = CreateWreckageFromUnit(unit)
    if not wreckage then
        return
    end

    local crash = NewWreckCrash(wreckage, position, velocity, headingRadians, deleteAtRest, crashScale)
    crash.scoNaval = startSinking == true
    crash.scoAircraft = not crash.scoNaval and unit:HasTags(Tags.AIR)
        and not unit:HasTags(Tags.NAVAL) and not unit:HasTags(Tags.ORBITAL)
    crash.scoRetainWaterWreck = crash.scoAircraft and (crashScale == CrashScaleLarge
        or (Tags.EXPERIMENTAL ~= nil and unit:HasTags(Tags.EXPERIMENTAL)))
    if crash.scoRetainWaterWreck then
        local size = unit.tp.collisionInfo and unit.tp.collisionInfo.collisionSize
        if size then
            -- A falling hull clears its horizontal footprint at ground contact.
            crash.scoTreeImpactRadius = math.sqrt(size.x * size.x + size.z * size.z) * 0.5
        end
        -- Set before the wreck's first lifetime tick, including the airborne phase.
        wreckage.scoWaterWreckSettling = true
    end
    if crash.scoAircraft then
        wreckage.scoAircraftCrashActive = true
        crash.scoAircraftCrashScorch = unit.scoAircraftCrashScorch == true
        if unit.scoAircraftCrashVelocity then
            local sourceVelocity = unit.scoAircraftCrashVelocity
            crash.velocity = EngineClasses.float3(
                sourceVelocity.x, sourceVelocity.y, sourceVelocity.z)
        end
    end
    if crash.scoNaval then
        crash.scoNavalLastTerrainHeight = unit.scoNavalWreckTerrainHeight
        wreckage.scoNavalSinking = true
        Import("common/commands/definitions/props.lua").SCO_NavalWreckPhase.Send(
            wreckage.id, false, unit.id)
    end

    wreckage:NewThread(function()
        WreckCrashThread(crash, startSinking)
    end)
end

---Continue the Czar's impact actor below water without spawning another wreck.
function SinkAircraftWreck(wreck, position, velocity, headingRadians, rollRadians, deleteAtRest)
    local crash = NewWreckCrash(wreck, position, velocity, headingRadians, deleteAtRest, CrashScaleLarge)
    crash.scoAircraft = true
    crash.scoRetainWaterWreck = true
    crash.rollRadians = rollRadians
    wreck.scoWaterWreckSettling = true
    BeginSinking(crash)
    WreckCrashThread(crash, true)
end

-- Only for annotations
return {
    StartWreckCrash = StartWreckCrash,
    SinkAircraftWreck = SinkAircraftWreck,
}
