-- Shared construction point. Beam callers supply an emitter position so their
-- endpoint reaches the visible body; existing arm aim keeps its center point.
local boundsByModel = {}

-- These three land factories share the same stationary Root mesh. Their full
-- bind bounds also contain floating pods and buried upgrade parts, so their
-- bounding-box center above the main body is not a construction surface.
local seraphimLandFactoryBody = {
    x = 0, z = -0.15578019618988037, bottom = 0.02, top = 1.6912387609481812,
}
local constructionBodies = {
    uss1511 = seraphimLandFactoryBody,
    uss2511 = seraphimLandFactoryBody,
    uss3511 = seraphimLandFactoryBody,
}

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function getBounds(unit)
    local general = unit.tp.general or {}
    local modelId = general.modelTpId or general.tpId or unit.tpId
    local bounds = modelId and boundsByModel[modelId]
    if modelId and bounds == nil then
        local path = "Units/" .. modelId .. "/LOD0/" .. modelId .. "_lod0.sanmodel"
        local status, center, size = Engine.GetMeshBounds(path)
        bounds = false
        if status == EngineErrorCode.Success and center and size
            and finite(center.x) and finite(center.y) and finite(center.z)
            and finite(size.x) and size.x > 0
            and finite(size.y) and size.y > 0
            and finite(size.z) and size.z > 0 then
            local body = constructionBodies[modelId]
            bounds = {x = body and body.x or center.x, z = body and body.z or center.z,
                halfX = size.x * 0.5, halfZ = size.z * 0.5,
                bottom = body and body.bottom or center.y - size.y * 0.5,
                top = body and body.top or center.y + size.y * 0.5,
                -- The shader still reveals the original full mesh by this height.
                height = size.y}
        end
        boundsByModel[modelId] = bounds
    end
    if bounds then return bounds end
    -- Missing render bounds must not send work effects below the foundation.
    local collision = unit.tp.collisionInfo
    local offset, size = collision.centerOffset, collision.collisionSize
    local bottom = math.max(0, offset.y - size.y * 0.5)
    local top = math.max(bottom + 0.02, offset.y + size.y * 0.5)
    return {x = offset.x, z = offset.z,
        halfX = math.max(0.01, size.x * 0.5),
        halfZ = math.max(0.01, size.z * 0.5),
        bottom = bottom, top = top, height = top - bottom}
end

local function hasTag(unit, name)
    local tp = unit and unit.tp
    if not tp then return false end
    if tp.hasTags and tp.hasTags[name] then return true end
    for _, tag in ipairs(tp.tags or {}) do if tag == name then return true end end
    return false
end

local function hopFaction(builder, target, fraction)
    if not builder or not target or target.entityType ~= "unit" or fraction >= 1
        or builder.dead or builder.deleted or target.dead or target.deleted
        or builder.isReclaiming or builder.isCapturing
        or not hasTag(builder, "SCFA_CONSTRUCTION") then return nil end
    if not ((builder.isBuilding and builder.buildTarget == target)
        or (builder.isRepairing and builder.repairTarget == target)) then return nil end
    if builder.GetPause and builder:GetPause() then return nil end
    if (builder.IsUpgrading and builder:IsUpgrading())
        or (target.IsUpgrading and target:IsUpgrading())
        or (target.IsUpgrade and target:IsUpgrade()) then return nil end
    if hasTag(builder, "SCFA_UEF") then return "uef" end
    if hasTag(builder, "SCFA_CYBRAN") then return "cybran" end
end

local function nextRandom(seed)
    seed = (seed * 16807) % 2147483647
    return seed, (seed - 1) / 2147483646
end

local function sampleHop(state, builder, target, faction, now)
    local builderId, targetId = builder.id or builder.localId, target.id or target.localId
    local emitterId = state.emitterId
    if not builderId or not targetId or not emitterId or not finite(now) then return nil end
    if state.builder ~= builder or state.target ~= target or state.faction ~= faction
        or state.builderIndex ~= builderId.index or state.builderVersion ~= builderId.version
        or state.targetIndex ~= targetId.index or state.targetVersion ~= targetId.version
        or state.emitterIndex ~= emitterId.index or state.emitterVersion ~= emitterId.version then
        state.builder, state.target, state.faction = builder, target, faction
        state.builderIndex, state.builderVersion = builderId.index, builderId.version
        state.targetIndex, state.targetVersion = targetId.index, targetId.version
        state.emitterIndex, state.emitterVersion = emitterId.index, emitterId.version
        local key = table.concat({tostring(builderId.index), tostring(builderId.version),
            tostring(targetId.index), tostring(targetId.version),
            tostring(emitterId.index), tostring(emitterId.version)}, ":")
        local seed = 5381
        for index = 1, #key do seed = (seed * 33 + key:byte(index)) % 2147483646 end
        state.seed = seed + 1
        local cadence, phase
        seed, cadence = nextRandom(state.seed)
        seed, phase = nextRandom(seed)
        state.interval = faction == "uef" and (0.3 + 1.2 * cadence) or 0.2
        state.phase, state.epoch, state.sampleIndex = phase * state.interval, now, nil
        state.lastTime = nil
    end
    -- Render interpolation can briefly lead the next simulation callback.
    -- Keep the same hop deadline when that callback supplies an older time.
    if state.lastTime then now = math.max(now, state.lastTime) end
    state.lastTime = now
    -- Deadlines stay on the activation's game-time grid. A long render gap
    -- skips directly to its sample without frame-rate drift or catch-up work.
    local sampleIndex = math.floor((now - state.epoch + state.phase) / state.interval)
    if state.sampleIndex ~= sampleIndex then
        local seed = (state.seed + (sampleIndex % 2147483646) * 104729) % 2147483646 + 1
        -- Fold the counter nonlinearly so successive hops do not form a
        -- regular spatial sweep. All integer intermediates stay exact in Lua.
        seed = ((seed % 65536)^2 + math.floor(seed / 65536) * 48271) % 2147483646 + 1
        local x, y, z
        seed, x = nextRandom(seed)
        seed, y = nextRandom(seed)
        seed, z = nextRandom(seed)
        state.x, state.y, state.z = x * 2 - 1, 0.25 + y * 0.75, z * 2 - 1
        state.sampleIndex = sampleIndex
    end
    return state.x, state.y, state.z
end

local cubeCorners = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}

local function cubePoint(cube, volume, x, z)
    -- The renderer owns the cube's rise, slab removal and native root pose.
    -- A small top-normal offset keeps the contact out of the opaque surface.
    local rotated = Engine.QuaternionRotateVector(cube.rotation, EngineClasses.float3(
        (volume.centerX + x * volume.width * 0.5) * cube.scale.x,
        (volume.bottom + volume.height) * cube.scale.y + 0.02,
        (volume.centerZ + z * volume.depth * 0.5) * cube.scale.z))
    return EngineClasses.float3(cube.position.x + rotated.x,
        cube.position.y + rotated.y, cube.position.z + rotated.z)
end

local function uefCubePosition(unit, origin, hopState, builder, fraction)
    local index = hopState and hopState.uefSliceIndex
    local cube = unit.scoFactionConstruction
    local volume = cube and cube.cubeBuildVolume
    if (index ~= 1 and index ~= 2) or not origin
        or not finite(origin.x) or not finite(origin.y) or not finite(origin.z)
        or hopFaction(builder, unit, fraction) ~= "uef"
        or not cube or cube.faction ~= "UEF" or not cube.cubeEligible or cube.failed
        or not volume then
        if hopState then hopState.uefSliceScan = nil end
        return nil
    end
    local now = Engine.GetSimulationTime()
    if not finite(now) or not finite(cube.epoch) then return nil end
    local scan = hopState.uefSliceScan
    if not scan or scan.cube ~= cube or scan.builder ~= builder then
        local first, second, nearest, nextNearest
        for _, corner in ipairs(cubeCorners) do
            local point = cubePoint(cube, volume, corner[1], corner[2])
            local dx, dy, dz = point.x - origin.x, point.y - origin.y, point.z - origin.z
            local distance = dx * dx + dy * dy + dz * dz
            if not nearest or distance < nearest then
                second, nextNearest = first, nearest
                first, nearest = corner, distance
            elseif not nextNearest or distance < nextNearest then
                second, nextNearest = corner, distance
            end
        end
        -- FA fixes the nearest edge at activation. Arm animation must not
        -- switch its endpoints to another face halfway through a scan.
        scan = {cube = cube, builder = builder, first = first, second = second}
        hopState.uefSliceScan = scan
    end
    if scan.lastTime then now = math.max(now, scan.lastTime) end
    scan.lastTime = now
    -- Both beams share the presentation epoch, including FA's .8s startup.
    -- Source velocity traverses the edge in .5s and resets after .6s. Bound
    -- its final .1s to the corner instead of overshooting outside the cube.
    local elapsed = math.max(0, now - cube.epoch - 0.8)
    local leg = math.floor(elapsed / 0.6)
    local travel = math.min(1, (elapsed - leg * 0.6) * 2)
    if leg % 2 == 1 then travel = 1 - travel end
    if index == 2 then travel = 1 - travel end
    local a, b = scan.first, scan.second
    local point = cubePoint(cube, volume,
        a[1] + (b[1] - a[1]) * travel, a[2] + (b[2] - a[2]) * travel)
    local status, terrain = Engine.SampleTerrainHeight(point)
    if status == EngineErrorCode.Success and finite(terrain) then
        point.y = math.max(point.y, terrain + 0.02)
    end
    return point
end

function GetPosition(unit, origin, hopState, builder)
    if not origin and not (unit.tp.hasTags and unit.tp.hasTags.SCFA_STRUCTURE) then
        return nil
    end
    local fraction = math.max(0, math.min(1, unit:GetFractionComplete()))
    local cubePosition = uefCubePosition(unit, origin, hopState, builder, fraction)
    if cubePosition then return cubePosition end
    local bounds = getBounds(unit)
    local bottom = math.max(0.02, bounds.bottom)
    local top = math.max(bottom, bounds.top)
    -- RTS/Unit clips original model Y at fraction * (_BoundsSize.y + .1).
    -- Negative bind-pose geometry must not lower this plane beneath terrain.
    local height = math.max(bottom, math.min(top, fraction * (bounds.height + 0.1)))
    if fraction >= 1 then height = (bottom + top) * 0.5 end -- repair the visible body
    -- Full mesh bounds include detached pads, appendages and hidden parts. A
    -- beam ending at their near AABB face can stop in empty space. Send the
    -- endpoint into the body so it crosses rendered geometry before it ends.
    local x, z = bounds.x, bounds.z
    local root = unit:GetPosition()
    local orientation = unit:GetOrientation()
    if origin and finite(origin.x) and finite(origin.y) and finite(origin.z) then
        -- Construction reveals a horizontal plane; stay below it while
        -- traversing the visible body instead of shooting across the roof.
        if fraction < 1 then
            height = math.min(height, bottom + (top - bottom) * 0.65)
        end
    end
    if hopState then
        local faction = hopFaction(builder, unit, fraction)
        if faction and origin then
            local sx, sy, sz = sampleHop(hopState, builder, unit, faction, Engine.GetSimulationTime())
            if sx then
                -- Work across the central visible body, not detached outer
                -- pads/appendages in full bind bounds. Collision data limits
                -- only this cosmetic region; gameplay bounds are untouched.
                local collision = unit.tp.collisionInfo and unit.tp.collisionInfo.collisionSize
                local halfX, halfZ = bounds.halfX, bounds.halfZ
                if collision and finite(collision.x) and collision.x > 0 then
                    halfX = math.min(halfX, collision.x * 0.5)
                end
                if collision and finite(collision.z) and collision.z > 0 then
                    halfZ = math.min(halfZ, collision.z * 0.5)
                end
                x, z = x + sx * halfX * 0.65, z + sz * halfZ * 0.65
                height = bottom + (height - bottom) * sy
            end
        else
            -- Eligibility can end without a native target replacement, e.g.
            -- completion, pause, or a transition into reclaim/capture.
            hopState.target = nil
        end
    end
    local localPoint = EngineClasses.float3(x, height, z)
    local rotated = Engine.QuaternionRotateVector(orientation, localPoint)
    local point = EngineClasses.float3(root.x + rotated.x, root.y + rotated.y, root.z + rotated.z)
    local status, terrain = Engine.SampleTerrainHeight(point)
    if status == EngineErrorCode.Success and finite(terrain) then
        point.y = math.max(point.y, terrain + 0.02)
    end
    return point
end

return {GetPosition = GetPosition}
