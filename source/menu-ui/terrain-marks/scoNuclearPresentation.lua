-- Native Sanctuary nuclear visuals; gameplay damage remains with host systems.
local prefabs, decalPrefabs, impulses = {}, {}, {}
local reportedAssetFailures = {}
local clock, match, generation, serial = nil, nil, 0, 0
local groundAnchors, anchorThread = {}, nil
local scorchRotationSeed = 104729
local cloudDuration = 36.5
local success = EngineErrorCode.Success
local graphs = {
    full = 'VFX/SCOM/Nuclear/uef_detonation.sanvfx',
    pulse = 'VFX/SCOM/Nuclear/thermal_pulse.sanvfx',
    largePulse = 'VFX/SCOM/Nuclear/thermal_pulse_large.sanvfx',
}
local cybranScorchLayers = {
    {path='Environment/SCOM/Nuclear/cybran_scorch.sandecal', diameter=120, rotation=0},
}
local cybranPresentations = {
    acu = {path='VFX/SCOM/Nuclear/cybran_acu.sanvfx', duration=32, scorchLayers=cybranScorchLayers},
    strategic = {path='VFX/SCOM/Nuclear/cybran_strategic.sanvfx', duration=32, scorchLayers=cybranScorchLayers},
}
local scorchLayers = {
    {path='Environment/SCOM/Nuclear/scorch_outer.sandecal', diameter=120, rotation=0},
    {path='Environment/SCOM/Nuclear/scorch_outer.sandecal', diameter=116, rotation=47},
    {path='Environment/SCOM/Nuclear/scorch_core.sandecal', diameter=104, rotation=19},
    {path='Environment/SCOM/Nuclear/scorch_core.sandecal', diameter=76, rotation=83},
}

local function finite(n)
    return type(n) == 'number' and n == n and math.abs(n) < math.huge
end

local function vector(p)
    return p and finite(p.x) and finite(p.y) and finite(p.z)
end

local function copy(p)
    return EngineClasses.float3(p.x, p.y, p.z)
end

local function reportAssetFailure(path, stage, status)
    local key = path .. ":" .. stage
    if reportedAssetFailures[key] then return end
    reportedAssetFailures[key] = true
    local detail = status ~= nil and (" (status " .. tostring(status) .. ")") or ""
    Engine.Warn("[SCOM nuclear] " .. stage .. " failed for " .. path .. detail
        .. ". The custom effect could not play; the existing fallback remains active.")
end

local function syncClock()
    local now = Engine.GetSimulationTime()
    local currentMatch = GameInfo and GameInfo.MapInfo
    if currentMatch ~= match or (clock and now < clock) then
        generation = generation + 1
        prefabs, decalPrefabs, impulses = {}, {}, {}
        groundAnchors, anchorThread = {}, nil
    end
    clock, match = now, currentMatch
    return now
end

local function effectPrefab(path)
    local prefab = prefabs[path]
    if not prefab then
        if not Engine.LoadEffect(path) then
            reportAssetFailure(path, "Asset load")
            return
        end
        prefab = Import('common/loading/vfxTemplateLoader.lua').GetOrCreateVFXPrefab(path)
        if not prefab or not prefab.Value or prefab.Value == 0 then
            reportAssetFailure(path, "Prefab creation")
            return
        end
        prefabs[path] = prefab
    end
    return prefab
end

local function createScorchPrefab(path)
    -- Packed .sandecals belong to gamedata; Lua FilesCache cannot read them.
    local hierarchy = Import('common/loading/hierarchyTemplateLoader.lua')
    local decal = EngineClasses.DecalTemplate(TemplateHeadEntityName, path,
        EngineClasses.float3(1, 1, 1), 1, true)
    local template = EngineClasses.PrefabTemplate("scom_nuclear_" .. path:match("([^/]+)%.sandecal$"),
        EngineClasses.HierarchyTemplate(hierarchy.GetHierarchyEntities()),
        EngineClasses.GlobalTemplate(),
        EngineClasses.LocalTemplate(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, {decal}))
    local prefab = {}
    local status = Engine.CreatePrefab(template, prefab)
    if status == success and prefab.Value and prefab.Value ~= 0 then return prefab end
end

local function groundScorch(position, scale, presentation)
    local status, height = Engine.SampleTerrainHeight(position)
    if status ~= success then return end
    -- SCOM terrain scorch projection 1.0.0
    -- Project every faction's burn onto terrain, including dry crater floors
    -- below the global sea level. Connected water covers the terrain decal.
    local decals = Import('client/entities/decal.lua')
    local center = EngineClasses.float3(position.x, height, position.z)
    local layers, rotationOffset = scorchLayers, nil
    if presentation and presentation.scorchLayers then
        layers = presentation.scorchLayers
        -- Private visual PRNG: do not consume the simulation's random stream.
        scorchRotationSeed = (scorchRotationSeed * 16807) % 2147483647
        rotationOffset = scorchRotationSeed * (360 / 2147483647)
    end
    -- Overlapping irregular native masks deepen the burn without a hard disk.
    for _, layer in ipairs(layers) do
        local path = layer.path
        local prefab = decalPrefabs[path]
        if not prefab then
            prefab = createScorchPrefab(path)
            decalPrefabs[path] = prefab
        end
        if prefab then
            local diameter = layer.diameter * scale
            local rotation = layer.rotation
            if rotationOffset then rotation = (rotation + rotationOffset) % 360 end
            decals.CreateDecal(prefab, center,
                EngineClasses.float3(diameter, diameter, 64 * scale), rotation, 600)
        end
    end
end

local function anchorSurface(position, landOrigin)
    local status, height = Engine.SampleTerrainHeight(position)
    if status ~= success or not finite(height) then return end
    -- A land-origin cloud follows the crater even below global sea level.
    -- Water-origin detonations retain their original surface anchoring.
    if landOrigin then return height, true end
    local waterStatus, hasWater = Engine.HasWater()
    if waterStatus ~= success then return end
    if hasWater then
        local levelStatus, level = Engine.GetWaterLevel()
        if levelStatus ~= success or not finite(level) then return end
        if height < level then return level, false end
    end
    return height, true
end

local function followCrater(expectedGeneration)
    while generation == expectedGeneration and #groundAnchors > 0 do
        WaitTicks(1)
        local now = syncClock()
        if generation ~= expectedGeneration then return end
        for index = #groundAnchors, 1, -1 do
            local anchor = groundAnchors[index]
            if now >= anchor.expires or not Engine.IsValidLocalID(anchor.id) then
                table.remove(groundAnchors, index)
            else
                local height = anchorSurface(anchor.position, anchor.landOrigin)
                if height == nil then
                    Engine.Warn("[SCOM nuclear] Could not sample cloud terrain anchor.")
                    table.remove(groundAnchors, index)
                else
                    -- Retain the original impact offset; only committed terrain
                    -- movement translates the existing cloud, cap and stem together.
                    local y = anchor.position.y + height - anchor.initialHeight
                    if math.abs(y - anchor.y) > 0.00001 then
                        local status = Engine.SetLocalEntityLocalPosition(anchor.id,
                            EngineClasses.float3(anchor.position.x, y, anchor.position.z))
                        if status ~= success then
                            Engine.Warn("[SCOM nuclear] Cloud terrain anchor rejected: " .. tostring(status))
                            table.remove(groundAnchors, index)
                        else
                            anchor.y = y
                        end
                    end
                end
            end
        end
    end
    if generation == expectedGeneration then anchorThread = nil end
end

local function trackCrater(id, position, now, duration)
    local height, landOrigin = anchorSurface(position)
    if height == nil then
        Engine.Warn("[SCOM nuclear] Could not initialize cloud terrain anchor.")
        return
    end
    groundAnchors[#groundAnchors + 1] = {id = id, position = copy(position),
        initialHeight = height, landOrigin = landOrigin, y = position.y,
        expires = now + (duration or cloudDuration)}
    if not anchorThread then anchorThread = NewThread(followCrater, generation) end
end

local function playNow(position, full, scale, scorchScale, presentation)
    local now = syncClock()
    local path = full and graphs.full or (scale >= 1.5 and graphs.largePulse or graphs.pulse)
    if presentation then path = presentation.path end
    local prefab = effectPrefab(path)
    if not prefab then return false end
    local status, id = Engine.InstantiatePrefab(prefab, position,
        EngineClasses.float3(scale, scale, scale), GetIdentityQuaternion())
    if status ~= success or not id or not Engine.IsValidLocalID(id) then
        reportAssetFailure(path, "Effect instantiation", status)
        return false
    end
    -- Both graphs are finite native destroyUponCompletion effects. Do not
    -- delete their handles: local IDs can be recycled after native cleanup.
    if full then trackCrater(id, position, now) end
    if not full and presentation and presentation.duration then trackCrater(id, position, now, presentation.duration) end
    serial = serial + 1
    if #impulses == 8 then table.remove(impulses, 1) end
    impulses[#impulses + 1] = {position=copy(position), time=now, scale=scale, phase=serial * 2.399963}
    groundScorch(position, scorchScale, presentation)
    return true
end

local function play(position, full, scale, delay, completed, scorchScale, presentation)
    if not vector(position) then return false end
    scale, delay = scale or 1, delay or 0
    scorchScale = scorchScale or scale
    if not finite(scale) or scale <= 0 or not finite(delay) or delay < 0 then return false end
    if not finite(scorchScale) or scorchScale <= 0 then return false end
    local point = copy(position)
    local now = syncClock()
    if delay == 0 then
        local played = playNow(point, full, scale, scorchScale, presentation)
        if completed then completed(played) end
        return played
    end
    local expectedGeneration, expectedMatch = generation, match
    -- Standalone ownership lets delayed effects outlive the impacted missile.
    NewThread(function()
        WaitSeconds(delay)
        local current = syncClock()
        if generation ~= expectedGeneration or match ~= expectedMatch or current < now then
            if completed then completed(false) end
            return
        end
        local played = playNow(point, full, scale, scorchScale, presentation)
        if completed then completed(played) end
    end)
    return true
end

function Play(position, full, scale, delay)
    return play(position, full, scale, delay)
end

function PlayAeon(position, scale)
    return play(position, false, scale, 0, nil, nil,
        {path='VFX/SCOM/Source/AeonNuke/thermal_pulse_large.sanvfx'})
end

function ApplyCamera(position, rotation)
    local now = syncClock()
    if #impulses == 0 then return position, rotation end
    local x, y, z = 0, 0, 0
    for i = #impulses, 1, -1 do
        local impulse = impulses[i]
        local age = now - impulse.time
        if age >= 4.5 or age < 0 then
            table.remove(impulses, i)
        else
            local p = impulse.position
            local dx, dy, dz = position.x-p.x, position.y-p.y, position.z-p.z
            local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
            local radius = 261 * impulse.scale
            if distance < radius then
                local falloff = (1 - distance/radius)^2
                local envelope = math.exp(-age * 1.25) * math.min(1, (4.5-age)/.5)
                local amount = .65 * falloff * envelope
                local phase = impulse.phase
                x = x + amount * math.sin(age*93 + phase)
                y = y + amount * .55 * math.sin(age*117 + phase*.7)
                z = z + amount * .7 * math.sin(age*79 + phase*1.3)
            end
        end
    end
    local magnitude = math.sqrt(x*x + y*y + z*z)
    if magnitude == 0 then return position, rotation end
    local cap = math.min(1, .65/magnitude)
    -- Offset only this frame's final pose; never feed shake into the camera rig.
    return EngineClasses.float3(position.x+x*cap, position.y+y*cap, position.z+z*cap), rotation
end

local commanders = {uel0000=true, ugl0000=true, ucl0000=true, usl0000=true}

function InstallCommander(class)
    if class.scoNuclearPresentationInstalled then return end
    class.scoNuclearPresentationInstalled = true
    local previous = class.CreateOnDeathEffect
    function class:CreateOnDeathEffect(...)
        local id = self.tpId or (self.tp and self.tp.general.tpId)
        if not commanders[id] then return previous(self, ...) end
        if not self:IsIntelVisionVisible() then return end
        if self.scoNuclearPresentationPlayed then return end
        if id == 'ugl0000' and play(self:GetSimPosition(), false, 1, 0, nil, nil, cybranPresentations.acu) then
            self.scoNuclearPresentationPlayed = true
            return
        end
        local full = id == 'uel0000'
        if not full then previous(self, ...) end
        if play(self:GetSimPosition(), full, 1, 0) then
            self.scoNuclearPresentationPlayed = true
        elseif full then
            return previous(self, ...)
        end
    end
end

local projectileProfiles = {
    psf0040 = {full=true, source='tifmissilenuke01'},
    psf0180 = {full=true, source='tifmissilenuke02'},
    psf0020 = {source='cifempfluxwarhead01', presentation=cybranPresentations.strategic},
    psf0181 = {source='cifempfluxwarhead04', presentation=cybranPresentations.strategic},
    psf0182 = {},
    psf0136 = {delay=3.5, scale=1.5, scorchScale=2},
}

local function collisionEntity(entities, id)
    if not id or id.index == 0 then return end
    local entity = entities[id.index]
    if entity and entity.id and entity.id.index == id.index and entity.id.version == id.version then
        return entity
    end
    if not Engine.IsValidGlobalID(id) then return end
    local status, root = Engine.GetGlobalEntityRoot(id)
    if status ~= success then return end
    entity = entities[root.index]
    if entity and entity.id and entity.id.index == root.index and entity.id.version == root.version then
        return entity
    end
end

function InstallProjectile(class)
    if class.scoNuclearPresentationInstalled then return end
    class.scoNuclearPresentationInstalled = true
    local previous = class.CreateImpactEffects
    function class:CreateImpactEffects(position, orientation, hitGlobalId, ...)
        local profile = projectileProfiles[self.tpId]
        if not profile or not self:IsIntelVisionVisible() then
            return previous(self, position, orientation, hitGlobalId, ...)
        end
        if profile.source then
            local source = self.tp.additions and self.tp.additions.scoSourceProjectile
            if not source or type(source.sourceId) ~= 'string' or source.sourceId:lower() ~= profile.source then
                return previous(self, position, orientation, hitGlobalId, ...)
            end
        end
        if collisionEntity(__Entities.Shields, hitGlobalId)
            or collisionEntity(__Entities.Projectiles, hitGlobalId) then
            return previous(self, position, orientation, hitGlobalId, ...)
        end
        if self.scoNuclearPresentationPlayed or self.scoNuclearPresentationPending then return end
        if profile.presentation then
            self.scoNuclearPresentationPending = true
            local accepted = play(position, false, 1, 0, nil, profile.scorchScale, profile.presentation)
            self.scoNuclearPresentationPending = nil
            if accepted then
                self.scoNuclearPresentationPlayed = true
                local audio = Import('client/audio/audioManager.lua')
                audio.NotifyCombatActivity()
                local impact = self.tp.audio and self.tp.audio.onImpact
                if impact and impact.prefabID then audio.PlayOneShot(impact.prefabID, position, orientation) end
                return
            end
        end
        if not profile.full then previous(self, position, orientation, hitGlobalId, ...) end
        self.scoNuclearPresentationPending = true
        local accepted = play(position, profile.full, profile.scale, profile.delay, function(played)
            self.scoNuclearPresentationPending = nil
            if played then self.scoNuclearPresentationPlayed = true end
        end, profile.scorchScale)
        if not accepted then
            self.scoNuclearPresentationPending = nil
            if profile.full then return previous(self, position, orientation, hitGlobalId, ...) end
        elseif profile.full then
            -- Match the native non-shield audio branch after replacing its VFX.
            local audio = Import('client/audio/audioManager.lua')
            audio.NotifyCombatActivity()
            local impact = self.tp.audio and self.tp.audio.onImpact
            if impact and impact.prefabID then audio.PlayOneShot(impact.prefabID, position, orientation) end
        end
    end
end

