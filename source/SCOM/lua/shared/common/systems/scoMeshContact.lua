-- Projectile-only broad phase follows the same rigid skin bones as the mesh.
-- Targeting, selection, area damage and beams keep their native collider policy.
local bit = bit
local index = Import('common/systems/scoMeshGeometryIndex.lua').GeometryIndex
local models, owners, colliderOwners = {}, {}, {}
local success = EngineErrorCode.Success
local layer = 536870912
local prefix = 'SCOM_Contact_'
local spherePrefix = 'SCOM_ContactSphere_'
local stack = {}
local batchSerial = 0
local alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local digits = {}
for i = 1, #alphabet do digits[alphabet:byte(i)] = i - 1 end

ProjectileLayer = layer

local function same(a, b)
    return a and b and a.index == b.index and a.version == b.version
end

local function decode(bone)
    if bone.vertices then return end
    local encoded = assert(bone.data, 'Missing SCOM mesh geometry: ' .. bone.name)
    assert(#encoded % 4 == 0, 'Unsupported SCOM mesh encoding')
    local padding = encoded:sub(-2) == '==' and 2 or (encoded:sub(-1) == '=' and 1 or 0)
    local size = #encoded / 4 * 3 - padding
    assert(size >= 12, 'Truncated SCOM mesh header: ' .. bone.name)
    local chunks = {}
    for i = 1, #encoded, 4 do
        local a, b, c, d = encoded:byte(i, i + 3)
        a, b = assert(digits[a]), assert(digits[b])
        c, d = digits[c] or 0, digits[d] or 0
        local value = a * 262144 + b * 4096 + c * 64 + d
        chunks[#chunks+1] = string.char(bit.rshift(value, 16),
            bit.band(bit.rshift(value, 8), 255), bit.band(value, 255))
    end
    local buffer = table.concat(chunks):sub(1, size)
    chunks = nil
    -- The game sandbox forbids mod FFI. Its public binary readers remain
    -- available: decode once into shared numeric arrays, never per ray.
    local readUInt, readInt, readFloat = Engine.DeserializeUInt, Engine.DeserializeInt, Engine.DeserializeFloat
    local vertexCount, cursor = readUInt(buffer, 1)
    local indexCount, nodeCount
    indexCount, cursor = readUInt(buffer, cursor)
    nodeCount, cursor = readUInt(buffer, cursor)
    assert(indexCount % 3 == 0 and nodeCount > 0
        and size == 12 + vertexCount * 12 + indexCount * 4 + nodeCount * 36,
        'Invalid SCOM mesh buffer: ' .. bone.name)
    local vertices, indices, nodes = {}, {}, {}
    for i = 0, vertexCount * 3 - 1 do
        local value
        value, cursor = readFloat(buffer, cursor)
        assert(value == value and math.abs(value) < math.huge, 'Nonfinite SCOM mesh vertex')
        vertices[i] = value
    end
    for i = 0, indexCount - 1 do
        local value
        value, cursor = readUInt(buffer, cursor)
        assert(value < vertexCount, 'Invalid SCOM mesh index')
        indices[i] = value
    end
    for node = 0, nodeCount - 1 do
        local n = node * 9
        for field = 0, 5 do nodes[n+field], cursor = readFloat(buffer, cursor) end
        for field = 6, 8 do nodes[n+field], cursor = readInt(buffer, cursor) end
    end
    assert(cursor == size+1, 'SCOM mesh buffer length mismatch')
    local function validateNode(node, depth)
        assert(node < nodeCount and depth < 64, 'Invalid SCOM mesh tree')
        local n = node * 9
        for axis = 0, 2 do
            local low, high = nodes[n+axis], nodes[n+axis+3]
            assert(low <= high and math.abs(low) < math.huge and math.abs(high) < math.huge,
                'Invalid SCOM mesh bounds')
        end
        local start, count, right = nodes[n+6], nodes[n+7], nodes[n+8]
        if count > 0 then
            assert(count <= 8 and start >= 0 and (start+count)*3 <= indexCount, 'Invalid SCOM mesh leaf')
            return node + 1
        end
        assert(count == 0 and right > node+1 and right < nodeCount, 'Invalid SCOM mesh branch')
        assert(validateNode(node+1, depth+1) == right, 'Overlapping SCOM mesh tree')
        return validateNode(right, depth+1)
    end
    assert(validateNode(0, 0) == nodeCount, 'Unreachable SCOM mesh nodes')
    bone.vertices, bone.indices, bone.nodes = vertices, indices, nodes
    bone.nodeInts, bone.nodeCount = nodes, nodeCount
    bone.data = nil
end

local function modelFor(id)
    local path = index.units[id]
    if not path then return nil end
    local model = models[id]
    if not model then
        model = Import(path).Geometry
        assert(model and model.modelPath and model.bones and #model.bones > 0, 'Missing SCOM collision model: ' .. id)
        if IsHost then for _, bone in ipairs(model.bones) do decode(bone) end end
        models[id] = model
    end
    return model
end

function Prepare(tp, prefab, meshPath)
    local id = tp.general.tpId
    local model = modelFor(id)
    if not model then return end
    assert(model.modelPath == meshPath, 'SCOM collision/render model mismatch: ' .. id)
    local hierarchy = prefab.hierarchyTemplate.entities
    local colliders = prefab.globalTemplate.volumeColliderTemplates
    local names = {}
    for _, entity in ipairs(hierarchy) do names[entity.entityName] = entity end
    for i, bone in ipairs(model.bones) do
        local parent = assert(names[bone.name], 'Missing SCOM mesh bone: ' .. id .. '/' .. bone.name)
        local name = prefix .. i
        assert(not names[name], 'Duplicate SCOM mesh collider: ' .. id)
        parent.forceSimulated = true
        hierarchy[#hierarchy + 1] = EngineClasses.EntityTemplate(name, bone.name,
            EngineClasses.float3(), 1, GetIdentityQuaternion(), true)
        local sphereName = spherePrefix .. i
        assert(not names[sphereName], 'Duplicate SCOM mesh sphere: ' .. id)
        hierarchy[#hierarchy + 1] = EngineClasses.EntityTemplate(sphereName, bone.name,
            EngineClasses.float3(), 1, GetIdentityQuaternion(), true)
        local b = bone.bounds
        -- Native boxes/spheres report boundary crossings only. Circles also
        -- report zero-distance overlaps, covering short rays wholly inside a
        -- bound and projectiles created inside it. The exact 3D BVH rejects
        -- their deliberately height-unbounded broad-phase candidates.
        local hx, hy, hz = (b[4]-b[1])*.5, (b[5]-b[2])*.5, (b[6]-b[3])*.5
        bone.radius = math.sqrt(hx*hx + hy*hy + hz*hz) + .0002
        colliders[#colliders + 1] = EngineClasses.VolumeColliderTemplate(name,
            EngineClasses.float3(bone.radius+.0002, 0, 0),
            EngineClasses.float3((b[1] + b[4]) * .5, (b[2] + b[5]) * .5, (b[3] + b[6]) * .5),
            ColliderType.Circle, CollisionWorld.Collision, layer, 0, ColliderFlags.Disabled)
        -- The sphere covers outside-to-inside crossings even when the native
        -- circle solver treats a nearly vertical direction as exactly vertical.
        colliders[#colliders + 1] = EngineClasses.VolumeColliderTemplate(sphereName,
            EngineClasses.float3(bone.radius, 0, 0),
            EngineClasses.float3((b[1]+b[4])*.5, (b[2]+b[5])*.5, (b[3]+b[6])*.5),
            ColliderType.Sphere, CollisionWorld.Collision, layer, 0, ColliderFlags.Disabled)
    end
    tp.scoMeshContactId = id
end

local function matrixStorage()
    return {c0={}, c1={}, c2={}, c3={}}
end

local function scaleBounds(state)
    local status, matrix = Engine.GetGlobalEntityWorldMatrix(state.id, state.rootMatrix)
    if status ~= success then error('SCOM mesh root pose unavailable') end
    state.rootMatrix = matrix
    local a, b, c = matrix.c0, matrix.c1, matrix.c2
    local aa, bb, cc = a.x*a.x+a.y*a.y+a.z*a.z, b.x*b.x+b.y*b.y+b.z*b.z, c.x*c.x+c.y*c.y+c.z*c.z
    local ab, ac, bc = a.x*b.x+a.y*b.y+a.z*b.z, a.x*c.x+a.y*c.y+a.z*c.z, b.x*c.x+b.y*c.y+b.z*c.z
    local largest = math.max(aa, bb, cc)
    local bound
    local orthogonal = math.max(math.abs(ab), math.abs(ac), math.abs(bc)) <= largest * 1e-6
    if orthogonal then
        bound = math.sqrt(largest) * 1.000002
    else
        -- Frobenius norm bounds the spectral norm even for attached/sheared roots.
        bound = math.sqrt(aa + bb + cc)
    end
    if not (bound == bound and bound < math.huge) then error('Invalid SCOM mesh root scale') end
    if state.scale == bound then return end
    for i, bone in ipairs(state.model.bones) do
        local radius = bone.radius * bound
        local id = state.colliders[i]
        if Engine.SetVolumeColliderSize(id, EngineClasses.float3(radius+.0002, 0, 0)) ~= success then
            error('SCOM mesh collider scale initialization failed')
        end
        if Engine.SetVolumeColliderSize(state.sphereColliders[i], EngineClasses.float3(radius, 0, 0)) ~= success then
            error('SCOM mesh sphere scale initialization failed')
        end
    end
    state.scale = bound
end

local function register(unit, setEnabled)
    local model = unit.tp.scoMeshContactId and modelFor(unit.tp.scoMeshContactId)
    if not model then return end
    local state = {id = unit.id, unit = unit, model = model, bones = {}, colliders = {}, sphereColliders = {}, poses = {}, rootMatrix = matrixStorage()}
    for i, bone in ipairs(model.bones) do
        local status, boneId = Engine.GetGlobalBone(unit.id, bone.name)
        assert(status == success and Engine.IsValidGlobalID(boneId), 'SCOM mesh bone was not simulated: ' .. bone.name)
        state.bones[i] = {index = boneId.index, version = boneId.version}
        status, boneId = Engine.GetGlobalBone(unit.id, prefix .. i)
        assert(status == success and Engine.IsValidGlobalID(boneId), 'SCOM mesh collider was not created')
        state.colliders[i] = {index = boneId.index, version = boneId.version}
        status, boneId = Engine.GetGlobalBone(unit.id, spherePrefix .. i)
        assert(status == success and Engine.IsValidGlobalID(boneId), 'SCOM mesh sphere was not created')
        state.sphereColliders[i] = {index = boneId.index, version = boneId.version}
    end
    local boneCount = #model.bones
    for i, id in ipairs(state.sphereColliders) do state.colliders[boneCount+i] = id end
    local status, enabled = Engine.GetVolumeColliderEnabled(unit.id)
    assert(status == success, 'SCOM mesh collider state unavailable')
    -- Authored SCOM animation scale curves are fixed at one. A root scale bound
    -- therefore encloses every rotated bone; native circle radii ignore scale.
    scaleBounds(state)
    for _, id in ipairs(state.colliders) do
        assert(setEnabled(id, enabled) == success, 'SCOM mesh collider initialization failed')
    end
    for i, id in ipairs(state.colliders) do
        colliderOwners[id.index] = {id = id, state = state, bone = (i-1)%boneCount+1}
    end
    owners[unit.id.index] = state
    unit.scoMeshContact = state
end

function InstallHost(class)
    if class.scoMeshContactInstalled then return end
    class.scoMeshContactInstalled = true
    local setEnabled = Engine.SetVolumeColliderEnabled
    -- Cargo, capture, construction and several unit classes toggle the root
    -- collider directly. Mirror that single authority, not selected callbacks.
    function Engine.SetVolumeColliderEnabled(id, enabled)
        local status = setEnabled(id, enabled)
        local state = owners[id.index]
        if status == success and state and same(state.id, id) then
            if enabled then scaleBounds(state) end
            for _, child in ipairs(state.colliders) do
                assert(setEnabled(child, enabled) == success, 'SCOM mesh collider lifecycle failed')
            end
        end
        return status
    end
    local init, delete = class.__init, class.Delete
    function class:__init(...)
        init(self, ...)
        register(self, setEnabled)
    end
    function class:Delete(...)
        local state = owners[self.id.index]
        if state and same(state.id, self.id) then
            owners[self.id.index] = nil
            for _, id in ipairs(state.colliders) do
                local entry = colliderOwners[id.index]
                if entry and same(entry.id, id) then colliderOwners[id.index] = nil end
            end
        end
        self.scoMeshContact = nil
        return delete(self, ...)
    end
end

-- Invert the full affine bone transform. Do not normalize the transformed ray:
-- its parameter must remain world distance even under animated/nonuniform scale.
local function inversePose(state, index, epoch)
    local poses = state.poses
    if not poses then poses = {}; state.poses = poses end
    local pose = poses[index]
    if not pose then pose = {matrix=matrixStorage()}; poses[index] = pose end
    if epoch and pose.epoch == epoch then return pose.valid and pose or nil end
    local status, matrix = Engine.GetGlobalEntityWorldMatrix(state.bones[index], pose.matrix)
    if status ~= success then error('SCOM collision bone pose unavailable: ' .. state.model.bones[index].name) end
    pose.matrix, pose.epoch = matrix, epoch
    local a, b, c, p = matrix.c0, matrix.c1, matrix.c2, matrix.c3
    local r00, r01, r02 = b.y*c.z-b.z*c.y, b.z*c.x-b.x*c.z, b.x*c.y-b.y*c.x
    local r10, r11, r12 = c.y*a.z-c.z*a.y, c.z*a.x-c.x*a.z, c.x*a.y-c.y*a.x
    local r20, r21, r22 = a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x
    local det = a.x*r00 + a.y*r01 + a.z*r02
    pose.valid = math.abs(det) >= 1e-12
    if not pose.valid then return end -- Hidden/collapsed geometry has no surface.
    pose[1],pose[2],pose[3] = r00/det,r01/det,r02/det
    pose[4],pose[5],pose[6] = r10/det,r11/det,r12/det
    pose[7],pose[8],pose[9] = r20/det,r21/det,r22/det
    pose[10],pose[11],pose[12] = p.x,p.y,p.z
    return pose
end

local function localRay(pose, origin, direction)
    local x, y, z = origin.x-pose[10], origin.y-pose[11], origin.z-pose[12]
    local dx, dy, dz = direction.x, direction.y, direction.z
    return pose[1]*x+pose[2]*y+pose[3]*z, pose[4]*x+pose[5]*y+pose[6]*z, pose[7]*x+pose[8]*y+pose[9]*z,
        pose[1]*dx+pose[2]*dy+pose[3]*dz, pose[4]*dx+pose[5]*dy+pose[6]*dz, pose[7]*dx+pose[8]*dy+pose[9]*dz
end

local function slab(low, high, origin, direction, first, last)
    if math.abs(direction) < 1e-15 then
        if origin < low - 1e-6 or origin > high + 1e-6 then return nil end
        return first, last
    end
    local a, b = (low-origin)/direction, (high-origin)/direction
    if a > b then a, b = b, a end
    first, last = math.max(first, a), math.min(last, b)
    if first > last + 1e-6 then return nil end
    return first, last
end

local function intersectBone(bone, ox, oy, oz, dx, dy, dz, maximum)
    local nodes, ints, vertices, indices = bone.nodes, bone.nodeInts, bone.vertices, bone.indices
    local top, nearest, found = 1, maximum, false
    stack[1] = 0
    while top > 0 do
        local node = stack[top]; top = top - 1
        local n = node * 9
        local first, last = slab(nodes[n], nodes[n+3], ox, dx, 0, nearest)
        if first then first, last = slab(nodes[n+1], nodes[n+4], oy, dy, first, last) end
        if first then first, last = slab(nodes[n+2], nodes[n+5], oz, dz, first, last) end
        if first then
            local count = tonumber(ints[n+7])
            if count == 0 then
                top = top + 1; stack[top] = tonumber(ints[n+8])
                top = top + 1; stack[top] = node + 1
            else
                local start = tonumber(ints[n+6]) * 3
                for triangle = start, start + count * 3 - 1, 3 do
                    local ai, bi, ci = indices[triangle]*3, indices[triangle+1]*3, indices[triangle+2]*3
                    local ax, ay, az = vertices[ai], vertices[ai+1], vertices[ai+2]
                    local ex, ey, ez = vertices[bi]-ax, vertices[bi+1]-ay, vertices[bi+2]-az
                    local fx, fy, fz = vertices[ci]-ax, vertices[ci+1]-ay, vertices[ci+2]-az
                    local px, py, pz = dy*fz-dz*fy, dz*fx-dx*fz, dx*fy-dy*fx
                    local det = ex*px + ey*py + ez*pz
                    if math.abs(det) > 1e-12 then
                        local tx, ty, tz = ox-ax, oy-ay, oz-az
                        local u = (tx*px+ty*py+tz*pz)/det
                        if u >= -1e-7 and u <= 1.0000001 then
                            local qx, qy, qz = ty*ez-tz*ey, tz*ex-tx*ez, tx*ey-ty*ex
                            local v = (dx*qx+dy*qy+dz*qz)/det
                            if v >= -1e-7 and u+v <= 1.0000001 then
                                local distance = (fx*qx+fy*qy+fz*qz)/det
                                if distance >= -1e-6 and distance <= nearest then
                                    nearest, found = math.max(0, distance), true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return found and nearest or nil
end

function Intersect(state, origin, direction, maximum, candidates, epoch)
    local nearest, found, hitBone, hitPoint = maximum, false
    local count = candidates and #candidates or #state.model.bones
    for candidate = 1, count do
        local i = candidates and candidates[candidate] or candidate
        local bone = state.model.bones[i]
        local pose = inversePose(state, i, epoch)
        if pose then
            local ox, oy, oz, dx, dy, dz = localRay(pose, origin, direction)
            local distance = intersectBone(bone, ox, oy, oz, dx, dy, dz, nearest)
            if distance then
                nearest, found, hitBone = distance, true, bone.name
                hitPoint = {x=ox+dx*distance, y=oy+dy*distance, z=oz+dz*distance}
            end
        end
    end
    return found and nearest or nil, hitBone, hitPoint
end

local function unitFor(id)
    if not id or id.index == 0 then return end
    -- A shield is a child of its unit, but owns its spherical collision surface.
    local shield = __Entities.Shields and __Entities.Shields[id.index]
    if shield and same(shield.id, id) then return end
    local units = __Entities.Units
    local contact = colliderOwners[id.index]
    if contact and same(contact.id, id) then
        local unit = contact.state.unit
        if units[unit.id.index] == unit then return unit, contact.bone end
        return
    end
    local unit = units[id.index]
    if not (unit and same(unit.id, id)) then
        local status, root = Engine.GetGlobalEntityRoot(id)
        if status ~= success then return end
        unit = units[root.index]
        if not unit or not same(unit.id, root) then return end
    end
    return unit
end

local function refine(event, unit, candidates, epoch)
    local state = unit.scoMeshContact
    if unit.dead or unit.deleted or not state or not same(state.id, unit.id) then return nil end
    local status, enabled = Engine.GetVolumeColliderEnabled(unit.id)
    if status ~= success or not enabled then return nil end
    local distance, bone, point = Intersect(state, event.rayOrigin, event.rayDirection, event.rayMaxDistance, candidates, epoch)
    -- Broad-phase overlap is only a candidate. Damage and impact effects must
    -- wait for the current ray segment to reach an actual mesh surface.
    if not distance then return nil end
    return {rayGlobalID=event.rayGlobalID, otherGlobalID=unit.id,
        rayOrigin=event.rayOrigin, rayDirection=event.rayDirection,
        rayMaxDistance=event.rayMaxDistance, hitDistance=distance,
        hitPosition={x=event.rayOrigin.x+event.rayDirection.x*distance,
            y=event.rayOrigin.y+event.rayDirection.y*distance, z=event.rayOrigin.z+event.rayDirection.z*distance},
        hitNormal=event.hitNormal, totalColliderHitCount=1, colliderHitIndex=0,
        scoMeshContact=true, scoImpactBone=bone, scoImpactBonePosition=point}
end

function Refine(event)
    if event.scoMeshContact then return event end
    local unit, bone = unitFor(event.otherGlobalID)
    if not unit or not unit.tp.scoMeshContactId then return event end
    batchSerial = batchSerial + 1
    return refine(event, unit, bone and {bone} or nil, batchSerial)
end

function RefineAll(events)
    local result, grouped, pending = {}, {}, {}
    batchSerial = batchSerial + 1
    local epoch = batchSerial
    for sequence, event in ipairs(events) do
        local unit, bone = unitFor(event.otherGlobalID)
        if unit and unit.tp.scoMeshContactId then
            local ray = event.rayGlobalID
            local key = ray.index .. ':' .. ray.version .. '/' .. unit.id.index .. ':' .. unit.id.version
            local row = grouped[key]
            if not row then
                row = {event=event, unit=unit, sequence=sequence, candidates={}, seen={}}
                grouped[key] = row
                pending[#pending+1] = row
            end
            if not bone then
                -- Root overlap requires checking every bone; auxiliary
                -- candidates may cover only part of the visible mesh.
                row.allBones = true
            elseif not row.seen[bone] then
                row.seen[bone] = true
                row.candidates[#row.candidates+1] = bone
            end
        else
            result[#result+1] = {event=event, sequence=sequence}
        end
    end
    for _, row in ipairs(pending) do
        -- Refine ordinary collider hits against the entire mesh, never against
        -- the box itself. Child-only hits keep the bounded candidate fast path.
        if row.allBones or #row.candidates > 0 then
            local candidates
            if not row.allBones then candidates = row.candidates end
            local accepted = refine(row.event, row.unit, candidates, epoch)
            if accepted then result[#result+1] = {event=accepted, sequence=row.sequence} end
        end
    end
    -- A padded box can precede a shield or another unit while its mesh lies
    -- behind them. Re-sort actual contacts before any damage owner executes.
    table.sort(result, function(a, b)
        local x, y = a.event, b.event
        if x.rayGlobalID.index ~= y.rayGlobalID.index then return x.rayGlobalID.index < y.rayGlobalID.index end
        if x.rayGlobalID.version ~= y.rayGlobalID.version then return x.rayGlobalID.version < y.rayGlobalID.version end
        if x.hitDistance ~= y.hitDistance then return x.hitDistance < y.hitDistance end
        return a.sequence < b.sequence
    end)
    for i, row in ipairs(result) do result[i] = row.event end
    return result
end
