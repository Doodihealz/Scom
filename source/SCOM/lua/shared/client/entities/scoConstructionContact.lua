-- Each visible construction beam owns one moving weld effect. Particle motion
-- stays in world space so a beam hop leaves only a brief, fading spark trail.
local prefabs = {}
local contactBounds = {}
local axes = {"x", "y", "z"}
local effects = {
    uef = "VFX/SCOM/ConstructionContact/UEF.sanvfx",
    cybran = "VFX/SCOM/ConstructionContact/Cybran.sanvfx",
}

local function valid(id)
    return id ~= nil and Engine.IsValidLocalID(id)
end

local function hasTag(unit, tag)
    local tp = unit and unit.tp
    if not tp then return false end
    if tp.hasTags and tp.hasTags[tag] then return true end
    for _, name in ipairs(tp.tags or {}) do if name == tag then return true end end
    return false
end

local function faction(builder, target)
    if not builder or not target or not valid(builder.localId) or not valid(target.localId)
        or builder.dead or builder.deleted or target.dead or target.deleted
        or target.entityType ~= "unit" or builder.isReclaiming or builder.isCapturing
        or not hasTag(builder, "SCFA_CONSTRUCTION") then return nil end
    if not ((builder.isBuilding and builder.buildTarget == target)
        or (builder.isRepairing and builder.repairTarget == target)) then return nil end
    if builder:GetPause() or builder:IsUpgrading() or target:IsUpgrading() or target:IsUpgrade()
        or not builder:IsCompleted() or builder:IsPlacementGhost()
        or builder:IsIntelVisionVisible() ~= true or target:IsIntelVisionVisible() ~= true
        or (not builder.isRepairing and target:GetFractionComplete() >= 1) then return nil end
    if hasTag(builder, "SCFA_CYBRAN") then return "cybran" end
    if hasTag(builder, "SCFA_UEF") then return "uef" end
end

function Clear(holder)
    local state = holder.scoConstructionContact
    holder.scoConstructionContact = nil
    if state and valid(state.id) then Engine.DeletePrefabInstance(state.id) end
end

function ClearTree(controller)
    if not controller then return end
    Clear(controller)
    for _, state in ipairs(controller.beams or {}) do ClearTree(state.beam) end
    for _, drone in ipairs(controller.drones or {}) do
        for _, contact in ipairs(drone.contacts or {}) do Clear(contact) end
    end
    if controller.stockBeam then ClearTree(controller.stockBeam) end
end

local function prefabFor(kind)
    if prefabs[kind] ~= nil then return prefabs[kind] or nil end
    if Engine.LoadEffect(effects[kind]) ~= true then
        prefabs[kind] = false
        Engine.Error("SCOM construction contact effect failed to load: " .. kind)
        return nil
    end
    local prefab = EngineClasses.PrefabTemplate("SCOM_ConstructionContact_" .. kind)
    table.insert(prefab.hierarchyTemplate.entities, EngineClasses.EntityTemplate(
        TemplateHeadEntityName, nil, EngineClasses.float3(), 1, GetIdentityQuaternion(), false))
    table.insert(prefab.localTemplate.particleTemplates, EngineClasses.ParticleTemplate(
        TemplateHeadEntityName, effects[kind], false, true))
    local status, id = Engine.CreatePrefab(prefab)
    -- Native PrefabID.Null is 65535, even when a loader reports success.
    local value = type(id) == "table" and id.Value
    if status ~= EngineErrorCode.Success or type(value) ~= "number"
        or value < 0 or value >= 65535 or value % 1 ~= 0 then
        prefabs[kind] = false
        Engine.Error("SCOM construction contact prefab failed: " .. kind)
        return nil
    end
    prefabs[kind] = id
    return id
end

local function finitePoint(point)
    if not point then return false end
    for _, axis in ipairs({"x", "y", "z"}) do
        local n = point[axis]
        if type(n) ~= "number" or n ~= n or math.abs(n) == math.huge then return false end
    end
    return true
end

local function surfacePoint(target, point, origin)
    local general = target.tp.general or {}
    local model = general.modelTpId or general.tpId or target.tpId
    if not model then return point end
    local bounds = contactBounds[model]
    if bounds == nil then
        local status, center, size = Engine.GetMeshBounds(
            "Units/" .. model .. "/LOD0/" .. model .. "_lod0.sanmodel")
        bounds = false
        if status == EngineErrorCode.Success and finitePoint(center) and finitePoint(size)
            and size.x > 0 and size.y > 0 and size.z > 0 then
            bounds = {min = {}, max = {}}
            for _, axis in ipairs(axes) do
                bounds.min[axis] = center[axis] - size[axis] * 0.5
                bounds.max[axis] = center[axis] + size[axis] * 0.5
            end
        end
        contactBounds[model] = bounds
    end
    if not bounds then return point end
    local positionCode, root = Engine.GetLocalEntityWorldPosition(target.localId)
    local rotationCode, orientation = Engine.GetLocalEntityWorldRotation(target.localId)
    local matrixCode, matrix = Engine.GetLocalEntityWorldMatrix(target.localId)
    if positionCode ~= EngineErrorCode.Success or rotationCode ~= EngineErrorCode.Success
        or matrixCode ~= EngineErrorCode.Success or not matrix then return point end
    local scale = {}
    for index, axis in ipairs(axes) do
        local column = matrix["c" .. tostring(index - 1)]
        if not finitePoint(column) then return point end
        local length = math.sqrt(column.x*column.x + column.y*column.y + column.z*column.z)
        if length < 0.000001 or length == math.huge then return point end
        scale[axis] = length
    end
    local q = orientation and orientation.value
    if not finitePoint(root) or not finitePoint(q) or type(q.w) ~= "number"
        or q.w ~= q.w or math.abs(q.w) == math.huge then return point end
    local norm = q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w
    if norm < 0.000001 or norm == math.huge then return point end
    local inverseNorm = 1 / math.sqrt(norm)
    local inverse = EngineClasses.quaternion(EngineClasses.float4(
        -q.x * inverseNorm, -q.y * inverseNorm, -q.z * inverseNorm, q.w * inverseNorm))
    local localOrigin = Engine.QuaternionRotateVector(inverse, EngineClasses.float3(
        origin.x - root.x, origin.y - root.y, origin.z - root.z))
    local localPoint = Engine.QuaternionRotateVector(inverse, EngineClasses.float3(
        point.x - root.x, point.y - root.y, point.z - root.z))
    if not finitePoint(localOrigin) or not finitePoint(localPoint) then return point end
    -- Render bounds approximate the visible surface without querying gameplay
    -- colliders. Cybran's whole-body fade renders full height at every progress.
    local enter, leave = 0, 1
    for _, axis in ipairs(axes) do
        local start = localOrigin[axis] / scale[axis]
        local delta = localPoint[axis] / scale[axis] - start
        if math.abs(delta) < 0.000001 then
            if start < bounds.min[axis] or start > bounds.max[axis] then return point end
        else
            local near = (bounds.min[axis] - start) / delta
            local far = (bounds.max[axis] - start) / delta
            if near > far then near, far = far, near end
            enter, leave = math.max(enter, near), math.min(leave, far)
            if enter > leave then return point end
        end
    end
    -- An emitter already inside the body has no incoming surface along this
    -- segment. Retain its endpoint instead of moving the effect behind it.
    if enter <= 0 then return point end
    local dx, dy, dz = point.x - origin.x, point.y - origin.y, point.z - origin.z
    local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
    if distance < 0.000001 or distance == math.huge then return point end
    local fraction = math.max(0, enter - 0.035 / distance)
    return EngineClasses.float3(origin.x + dx*fraction, origin.y + dy*fraction, origin.z + dz*fraction)
end

function Update(holder, builder, target, point, origin, enabled)
    local kind = enabled and faction(builder, target)
    if not kind or not finitePoint(point) or not finitePoint(origin) then Clear(holder); return end
    local state = holder.scoConstructionContact
    if state and (state.target ~= target or state.builder ~= builder or state.faction ~= kind) then
        Clear(holder)
        state = nil
    end
    if state and state.failed then return end
    if kind == "cybran" and hasTag(target, "SCFA_CYBRAN") then
        point = surfacePoint(target, point, origin)
    end
    local direction = EngineClasses.float3(origin.x - point.x, origin.y - point.y, origin.z - point.z)
    local rotation = Engine.QuaternionLookRotationSafe(direction, EngineClasses.float3(0, 1, 0))
    if not state or not valid(state.id) then
        local prefab = prefabFor(kind)
        if not prefab then return end
        state = {target = target, builder = builder, faction = kind}
        holder.scoConstructionContact = state
        local status, id = Engine.InstantiatePrefab(prefab, point, EngineClasses.float3(1, 1, 1), rotation)
        if status ~= EngineErrorCode.Success or not valid(id) then
            if valid(id) then Engine.DeletePrefabInstance(id) end
            state.failed = true
            Engine.Error("SCOM construction contact instance failed: " .. kind)
            return
        end
        state.id = id
    end
    Engine.SetLocalEntityLocalPosition(state.id, point)
    Engine.SetLocalEntityLocalRotation(state.id, rotation)
end

return {Update = Update, Clear = Clear, ClearTree = ClearTree}
