local SimpleEvents = Import("client/clientSimpleEvent.lua")
local DebugUI = Import("client/ui/debugUI.lua")
local ClientWinCondition = Import("client/winCondition.lua")
local Area = Import("common/area.lua").Area

functions = {}

---Dispatches a simple event to the client event system.
---@param data table
function functions.SimpleEvent(data)
    SimpleEvents.CallEvent(data)
end

---Verifies that this client built the same command tables as the host. A mismatch means commands
---would silently misroute, so it is fatal rather than a warning.
---@param data table<string, string[]> The host's command manifest.
function functions.VerifyCommandManifest(data)
    local matches, difference = Import("common/commands/registry.lua").CompareManifest(data)

    if not matches then
        Engine.Error("Command manifest mismatch between host and client: " .. tostring(difference) .. ". Host and client must be running the same build.")
    end
end

---Initialises the client lobby state on game start.
---@param data table
function functions.InitClient(data)
    InitLobby(data)
end

---Receives unit group templates from the host and registers them in the debug UI.
---@param data string[]
function functions.DebugUIAddUnitGroups(data)
    for _, name in ipairs(data) do
        DebugUI.AddGroupTemplate(name)
    end
end

---Triggers the nuke-at-home simple event at the given world position.
---@param data table
function functions.NukeAtHome(data)
    Import("client/simpleEvents.lua").NukeAtHome(data.position)
end

---Receives a win condition update from the host for a given army.
---@param data { armyID: ArmyId, condition: WinCondition }
function functions.WinConditionUpdate(data)
    ClientWinCondition.WinConditionUpdate(data)
end

---Receives a playable area change from the host.
---@param data { position: float2, size: float2 }
function functions.PlayableAreaUpdate(data)
    local area = Area.new(
        EngineClasses.float2(data.position.x, data.position.y),
        EngineClasses.float2(data.size.x, data.size.y))

    Import("client/managers/playableArea/clientPlayableAreaManager.lua").SetPlayableArea(area)
end


-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0
-- SCO_GalacticColossusTractorCrushClient
-- Host simulation sends only the authoritative capture position;
-- this listener creates no gameplay state and owns one finite VFX.
local scoTractorCrushHierarchyTemplateLoader =
    Import("common/loading/hierarchyTemplateLoader.lua")
local scoTractorCrushEffectPrefabs =
    _G.SCO_GalacticColossusEffectPrefabs or {}
_G.SCO_GalacticColossusEffectPrefabs = scoTractorCrushEffectPrefabs
local scoTractorCrushEffect =
    "VFX/AeonProjectiles/GalacticColossus/galactic_colossus_tractor_crush.sanvfx"
local scoTractorCrushPrefabName = "SCO.GC.TractorCrush"
local scoTractorCrushScale = EngineClasses.float3(1, 1, 1)
local scoTractorCrushOrientation = EngineClasses.quaternion()

local function scoTractorCrushGetPrefab()
    local prefab = scoTractorCrushEffectPrefabs[scoTractorCrushEffect]
    if prefab == false then
        return nil
    end
    if prefab ~= nil then
        return prefab
    end

    local particleTemplates = {
        EngineClasses.ParticleTemplate(
            TemplateHeadEntityName,
            scoTractorCrushEffect,
            true,
            true)
    }
    local prefabTemplate = EngineClasses.PrefabTemplate(
        scoTractorCrushPrefabName,
        EngineClasses.HierarchyTemplate(
            scoTractorCrushHierarchyTemplateLoader.GetHierarchyEntities(nil)),
        EngineClasses.GlobalTemplate(),
        EngineClasses.LocalTemplate(
            nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil,
            particleTemplates))
    local result, createdPrefab = Engine.CreatePrefab(prefabTemplate)
    if result ~= EngineErrorCode.Success
        or createdPrefab == nil
        or createdPrefab.Value == nil
        or createdPrefab.Value == 65535
    then
        scoTractorCrushEffectPrefabs[scoTractorCrushEffect] = false
        return nil
    end
    scoTractorCrushEffectPrefabs[scoTractorCrushEffect] = createdPrefab
    return createdPrefab
end

local function scoTractorFiniteCoordinate(value)
    return type(value) == "number"
        and value == value
        and math.abs(value) < 1000000
end

function functions.SCOGalacticColossusTractorCrush(data)
    local position = data and data.position
    if position == nil
        or not scoTractorFiniteCoordinate(position.x)
        or not scoTractorFiniteCoordinate(position.y)
        or not scoTractorFiniteCoordinate(position.z)
    then
        return
    end
    local prefab = scoTractorCrushGetPrefab()
    if prefab == nil then
        return
    end
    local result, localId = Engine.InstantiatePrefab(
        prefab,
        EngineClasses.float3(position.x, position.y, position.z),
        scoTractorCrushScale,
        scoTractorCrushOrientation)
    if result ~= EngineErrorCode.Success
        or localId == nil
        or not Engine.IsValidLocalID(localId)
    then
        return
    end
    Engine.SetParticleCanEmit(localId, true)
    Engine.SetDestroyUponCompletion(localId, true)
end

-- Aircraft and the specialized Czar crash retain native decal appearance and lifetime.
local function scoCreateCrashImpactScorch(data, tpId)
    if type(data) ~= "table" then
        return
    end
    local position = data and data.position
    if type(position) ~= "table"
        or not scoTractorFiniteCoordinate(position.x)
        or not scoTractorFiniteCoordinate(position.y)
        or not scoTractorFiniteCoordinate(position.z)
    then
        return
    end
    local template = __Templates
        and __Templates.Units
        and __Templates.Units[tpId]
    if template == nil then
        return
    end

    local unitClass =
        Import("client/units/unitsClasses/unitsBaseClass.lua").ClientUnit
    local impactPosition =
        EngineClasses.float3(position.x, position.y, position.z)
    local scorchSource = {
        tp = template,
        CreateDecal = unitClass.CreateDecal,
        GetSimPosition = function()
            return impactPosition
        end,
    }
    -- The aircraft was already deleted. An independent finite thread
    -- waits for its falling wreck to interpolate to the contact pose.
    NewThread(function()
        WaitTickEnd()
        unitClass.CreateRandomScorchmark(scorchSource)
    end)
end

-- SCO_CzarCrashScorchContact_v1 keeps its specialized physics contact owner.
function functions.SCOCzarCrashImpactScorch(data)
    scoCreateCrashImpactScorch(data, "uca4011")
end

function functions.SCOAircraftCrashImpactScorch(data)
    if type(data) ~= "table" or type(data.tpId) ~= "string" then return end
    scoCreateCrashImpactScorch(data, data.tpId)
end

-- SCOM initial commander arrival visuals 2.0.0.
-- Append to client/clientListeners.lua. Begin precedes native CreateUnit commands.
-- The host owns the cohort and every reveal/release decision; this is presentation only.
-- SCO_CommanderArrivalVisuals_v1
local arrivalVersion = "2.0.0"
local installedArrival = rawget(_G, "SCO_CommanderArrivalVisuals")
if installedArrival ~= nil then
    assert(type(installedArrival) == "table" and installedArrival.version == arrivalVersion,
        "Unsupported SCOM commander arrival visuals")
else
    local supported = { uel0000 = true, ugl0000 = true, ucl0000 = true, usl0000 = true }
    local arrivalFactions = { uel0000 = "uef", ugl0000 = "cybran", ucl0000 = "aeon", usl0000 = "seraphim" }
    local api = { version = arrivalVersion }
    local session, previousSequence, unitClass = nil, 0, nil
    local nativeVision, nativeRadar
    local effectPrefabs, effectLoaded = {}, {}
    local groundScorches = {}
    local cleanupQueue, pendingRecords = {}, {}
    local requestPump, startPump, pumpRunning, pumpRequested, presentationBoundary = nil, nil, false, false, false

    local function finite(value)
        return type(value) == "number" and value == value
            and value ~= math.huge and value ~= -math.huge
    end

    local function integer(value, minimum, maximum)
        return finite(value) and value == math.floor(value)
            and value >= minimum and value <= maximum
    end

    local function position(value)
        if type(value) ~= "table" then return nil end
        for _, name in ipairs({ "x", "y", "z" }) do
            if not finite(value[name]) or math.abs(value[name]) > 1048576 then return nil end
        end
        return { x = value.x, y = value.y, z = value.z }
    end

    local function identity(value)
        if type(value) ~= "table" or not integer(value.index, 0, 4294967295)
            or not integer(value.version, 0, 4294967295)
            or (value.index == 0 and value.version == 0) then return nil end
        return { index = value.index, version = value.version }
    end

    local function sameIdentity(left, right)
        return left ~= nil and right ~= nil
            and left.index == right.index and left.version == right.version
    end

    local function validLocal(value)
        return value ~= nil and Engine.IsValidLocalID(value)
    end

    local function tick()
        local value = Engine.GetSimulationTick()
        return integer(value, 0, 2147483647) and value or nil
    end

    local function activeRecord(unit)
        local record = unit.scoCommanderArrivalRecord
        if record and record.unit == unit and not record.cancelled and not record.deleted
            and (unit.id == nil or sameIdentity(record.unitId, unit.id)) then return record end
    end

    local function hidden(unit)
        local record = activeRecord(unit)
        return record ~= nil and not record.revealed and not record.released
    end

    local function blocked(unit)
        local record = activeRecord(unit)
        return record ~= nil and not record.released
    end

    local function hideDisplay(unit)
        if unit.isInitialized == false or not validLocal(unit.localId) then return end
        Engine.SetRendererEnabled(unit.localId, false)
        Engine.SetRangeRingsEnabled(unit.localId, false)
        Engine.SetIconsEnabled(unit.localId, false)
        unit:SetSelectionEnabled(false)
        unit:SetProgressBarsEnabled(false)
        unit:RecalculateConstructionBeamState()
        unit:RecalculateBuildEffectsState()
        unit:RecalculatePersistentEffectsState()
        unit:RecalculateAudioSourcesState()
        unit:RecalculateShieldEffectsState()
    end

    local function liveUnit(record)
        local unit = record.unit
        if unit == nil and record.unitId and __Entities and __Entities.Units then
            unit = __Entities.Units[record.unitId.index]
            if not sameIdentity(unit and unit.id, record.unitId) then unit = nil end
        end
        if unit == nil or unit.dead or unit.deleted or not validLocal(unit.localId)
            or not sameIdentity(unit.id, record.unitId) then return nil end
        return unit
    end

    local function grounded(record)
        local point = position(record.position)
        local code, height = Engine.SampleTerrainHeight(point)
        if code == EngineErrorCode.Success and finite(height) then point.y = height end
        return point
    end

    local function renderable(unit)
        return unit.isInitialized ~= false and nativeVision(unit) == true
    end

    local function getEffectPrefab(path, name)
        if effectPrefabs[path] ~= nil then return effectPrefabs[path] or nil end
        if effectLoaded[path] == nil then
            effectLoaded[path] = Engine.LoadEffect(path) == true
            if not effectLoaded[path] then
                Engine.Error("[SCOM Arrival] Arrival effect loading failed: " .. path)
            end
        end
        if not effectLoaded[path] then return nil end
        local hierarchy = Import("common/loading/hierarchyTemplateLoader.lua")
        -- Match the native VFX loader, with a private name and explicit ownership.
        -- This persistent root must remain alive until the presentation pump deletes it.
        local particles = { EngineClasses.ParticleTemplate(TemplateHeadEntityName,
            path, false, true) }
        local template = EngineClasses.PrefabTemplate(name,
            EngineClasses.HierarchyTemplate(hierarchy.GetHierarchyEntities(nil)),
            EngineClasses.GlobalTemplate(),
            EngineClasses.LocalTemplate(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, particles))
        local code, prefab = Engine.CreatePrefab(template)
        effectPrefabs[path] = false
        if code == EngineErrorCode.Success and type(prefab) == "table"
            and integer(prefab.Value, 0, 65534) then effectPrefabs[path] = prefab end
        return effectPrefabs[path] or nil
    end

    local function stopPortal(record)
        local instance = record.teleportId
        record.teleportId = nil
        if validLocal(instance) then Engine.DeletePrefabInstance(instance) end
    end

    local function stopImpact(record)
        local instance = record.impactId
        record.impactId = nil
        if validLocal(instance) then Engine.DeletePrefabInstance(instance) end
    end

    local function effectFaction(record, unit)
        local tpId = unit.tp and unit.tp.general and unit.tp.general.tpId
        return tpId == record.tpId and arrivalFactions[tpId] or nil
    end

    local function arrivalPortal(record, unit)
        if record.portalAttempted then return end
        record.portalAttempted = true
        local faction = effectFaction(record, unit)
        if faction == nil then
            Engine.Error("[SCOM Arrival] Teleport faction unavailable; arrival remains held.")
            return
        end
        local suffix = faction == "uef" and "" or "_" .. faction
        local prefab = getEffectPrefab(
            "VFX/SCOM/Commanders/Arrival/commander_arrival_portal" .. suffix .. ".sanvfx",
            "SCOM_CommanderArrivalTeleport_v2_" .. faction)
        if prefab == nil then
            Engine.Error("[SCOM Arrival] Teleport prefab creation failed; arrival remains held.")
            return
        end
        local code, instance = Engine.InstantiatePrefab(prefab, grounded(record),
            EngineClasses.float3(1, 1, 1), GetIdentityQuaternion())
        if code == EngineErrorCode.Success and identity(instance) then
            record.teleportId = instance
            Engine.Log("[SCOM Arrival] Teleport effect instantiated for army " .. tostring(record.armyId))
        else
            Engine.Error("[SCOM Arrival] Teleport instance creation failed; arrival remains held.")
        end
    end

    local function arrivalImpact(record, unit)
        if record.impactAttempted then return end
        record.impactAttempted = true
        if not renderable(unit) then return end
        local faction = effectFaction(record, unit)
        if faction == nil then
            Engine.Error("[SCOM Arrival] Reveal impact faction unavailable.")
            return
        end
        local suffix = faction == "uef" and "" or "_" .. faction
        local prefab = getEffectPrefab(
            "VFX/SCOM/Commanders/Arrival/commander_arrival_impact" .. suffix .. ".sanvfx",
            "SCOM_CommanderArrivalImpact_v1_" .. faction)
        if prefab == nil then
            Engine.Error("[SCOM Arrival] Reveal impact prefab creation failed.")
            return
        end
        local code, instance = Engine.InstantiatePrefab(prefab, grounded(record),
            EngineClasses.float3(1, 1, 1), GetIdentityQuaternion())
        if code == EngineErrorCode.Success and identity(instance) then
            record.impactId = instance
        else
            Engine.Error("[SCOM Arrival] Reveal impact instance creation failed.")
        end
    end

    local function arrivalScorch(record, unit)
        record.scorchDone = true
        if not renderable(unit) then return end
        local point = grounded(record)
        local waterCode, hasWater = Engine.HasWater()
        if waterCode == EngineErrorCode.Success and hasWater then
            local code, water = Engine.GetWaterLevel()
            if code == EngineErrorCode.Success and finite(water) and point.y < water then return end
        end
        local size = unit.tp.collisionInfo and unit.tp.collisionInfo.collisionSize
        local width = 1
        if size and finite(size.x) and finite(size.z) then
            width = math.max(1, size.x, size.z)
        end
        -- Index 4 is the stock radial scorch also used by native unit deaths.
        -- The native projector has unit extents, so this is a 6*width footprint.
        local prefab = type(ScorchmarkDecalPrefabIDs) == "table" and ScorchmarkDecalPrefabIDs[4]
        if not prefab then
            Engine.Error("[SCOM Arrival] Native radial scorch prefab unavailable.")
            return
        end
        local yaw = (record.armyId * 73) % 360 - 180
        local rotation = Engine.EulerToQuaternion(EngineClasses.float3(math.pi / 2,
            math.rad(yaw), 0), RotationOrder.Default)
        local diameter = width * 6
        -- CreateDecal discards the native result; validate the same stock prefab
        -- route before giving its instance to the native Decal entity.
        local code, instance = Engine.InstantiatePrefab(prefab, point,
            EngineClasses.float3(diameter, diameter, diameter), rotation)
        if code ~= EngineErrorCode.Success or not identity(instance) or not validLocal(instance) then
            Engine.Error("[SCOM Arrival] Native radial scorch instance creation failed.")
            return
        end
        local componentCode, enabled = Engine.GetDecalEnabled(instance)
        if componentCode ~= EngineErrorCode.Success or not enabled then
            Engine.DeletePrefabInstance(instance)
            Engine.Error("[SCOM Arrival] Native radial scorch component unavailable; discarded owned instance.")
            return
        end
        local decals = Import("client/entities/decal.lua")
        local clientEntity = Import("client/entities/entity.lua").ClientEntity
        local decal = decals.Decal(instance)
        local nativeDelete, nativeSetOpacity = decal.Delete, decal.SetOpacity
        -- These guards belong only to this mark. Native entity garbage still
        -- owns its lifetime coroutine, including after an external ID deletion.
        function decal:Delete()
            if self.deleted then return end
            if validLocal(self.localId) then nativeDelete(self)
            else clientEntity.Delete(self) end
        end
        function decal:SetOpacity(opacity)
            if self.deleted then return end
            if not validLocal(self.localId) then self:Delete(); return end
            nativeSetOpacity(self, opacity)
        end
        function decal:LifeTimeThread(seconds)
            -- Native FadeOverTime(600) truncates its capped step delays to
            -- 588.8s. A 595s hold plus its exact 50-tick fade lasts 600s.
            WaitTicks((seconds - 5) * Constants.TickRate)
            if self.deleted then return end
            if not validLocal(self.localId) then self:Delete(); return end
            self:FadeOverTime(5)
            self:Delete()
        end
        decal:SetLifeTime(600)
        groundScorches[#groundScorches + 1] = decal
    end

    local function restoreDisplay(record, unit)
        if unit.isInitialized ~= false then unit:RecalculateIntel(true) end
    end

    local function finishPresentation(record, unit)
        if not record.revealed then return end
        if unit.isInitialized == false then return end
        arrivalImpact(record, unit)
        if not record.scorchDone then arrivalScorch(record, unit) end
        if validLocal(record.teleportId) or validLocal(record.impactId) then
            if not record.portalFading then
                -- Stop new particles, then reveal the commander inside the finite
                -- particles already rendered. Simulation catchup cannot end this fade.
                if validLocal(record.teleportId) then
                    Engine.SetParticleCanEmit(record.teleportId, false)
                end
                record.portalFading, record.renderedPortalFade = true, 0
            end
            if not record.portalFadeReady then return end
        end
        stopPortal(record)
        -- The impact's one-shot world-space particles continue their finite
        -- lifetimes after its emission root is disposed, including the steam.
        stopImpact(record)
    end

    local function queueRecord(record)
        pendingRecords[record] = true
        requestPump()
    end

    local function queueCleanup(record, restore)
        if not record.cleanupQueued then
            record.cleanupQueued = { record = record }
            cleanupQueue[#cleanupQueue + 1] = record.cleanupQueued
        end
        record.cleanupQueued.restore = record.cleanupQueued.restore or restore
        pendingRecords[record] = nil
        requestPump()
    end

    local function cancelUnit(unit)
        local record = activeRecord(unit)
        if record == nil then return end
        record.deleted = true
        unit.scoCommanderArrivalRecord = nil
        queueCleanup(record, false)
    end

    local function claim(unit, globalId, armyId, template)
        if session == nil or session.cancelled then return nil end
        local tpId = template and template.general and template.general.tpId
        for _, record in ipairs(session.records) do
            if not record.deleted and record.armyId == armyId and record.tpId == tpId
                and (sameIdentity(record.unitId, globalId)
                    or (record.unitId == nil and record.unit == nil)) then
                record.unitId = identity(globalId)
                record.unit = unit
                local now = tick()
                if now and session.revealRequested and now >= session.revealTick then record.revealed = true end
                if now and session.releaseRequested and now >= session.releaseTick then record.released = true end
                unit.scoCommanderArrivalRecord = record
                return record
            end
        end
    end

    local function installHooks()
        if unitClass then return end
        local previousFlush = _G.ThreadDispatcherFlush
        assert(type(previousFlush) == "function", "SCOM commander arrival needs native tick-end dispatch")
        function _G.ThreadDispatcherFlush(...)
            if pumpRequested and not pumpRunning then
                pumpRequested = false
                startPump()
            end
            return previousFlush(...)
        end
        -- Begin runs after InitClient, when clientListeners has finished importing.
        unitClass = Import("client/units/unitsClasses/unitsBaseClass.lua").ClientUnit
        assert(type(unitClass) == "table", "SCOM commander arrival needs ClientUnit")
        nativeVision, nativeRadar = unitClass.IsIntelVisionVisible, unitClass.IsIntelRadarVisible
        local function wrapConstructor(class)
            local previous = class.__init
            function class:__init(globalId, localId, armyId, template, fractionComplete)
                local record = claim(self, globalId, armyId, template)
                local result = previous(self, globalId, localId, armyId, template, fractionComplete)
                if record then queueRecord(record) end
                return result
            end
        end
        -- Native Class copies __init without propagating later changes. The already-defined
        -- Commander constructor explicitly calls this captured mobile constructor.
        local mobileClass = Import("client/units/unitsClasses/unitsDefault.lua").ClientMobileUnit
        assert(type(mobileClass) == "table", "SCOM commander arrival needs ClientMobileUnit")
        wrapConstructor(unitClass)
        wrapConstructor(mobileClass)
        function unitClass:IsIntelVisionVisible()
            return not hidden(self) and nativeVision(self)
        end
        function unitClass:IsIntelRadarVisible()
            return not hidden(self) and nativeRadar(self)
        end
        for _, name in ipairs({ "IsSelectable", "IsHighlightable" }) do
            local previous = unitClass[name]
            unitClass[name] = function(self, ...)
                if blocked(self) then return false end
                return previous(self, ...)
            end
        end
        local previousSelection = unitClass.SetSelectionEnabled
        function unitClass:SetSelectionEnabled(enabled)
            if blocked(self) then
                if presentationBoundary and self.isInitialized ~= false then
                    return previousSelection(self, false)
                end
                local record = activeRecord(self)
                if self.isInitialized ~= false then queueRecord(record) end
                return
            end
            return previousSelection(self, enabled)
        end
        local previousIcons = unitClass.RecalculateUnitIconState
        function unitClass:RecalculateUnitIconState(...)
            if hidden(self) then
                if presentationBoundary and self.isInitialized ~= false and validLocal(self.localId) then
                    Engine.SetIconsEnabled(self.localId, false)
                elseif self.isInitialized ~= false then queueRecord(activeRecord(self)) end
                return
            end
            return previousIcons(self, ...)
        end
        local previousHidden = unitClass.OnIntelHidden
        for _, name in ipairs({ "OnIntelVision", "OnIntelRadar", "OnIntelHidden" }) do
            local previous = unitClass[name]
            unitClass[name] = function(self, ...)
                if hidden(self) then
                    if presentationBoundary and self.isInitialized ~= false then
                        previousHidden(self)
                    elseif self.isInitialized ~= false then queueRecord(activeRecord(self)) end
                    return
                end
                return previous(self, ...)
            end
        end
        local previousDestroy, previousDelete = unitClass.OnDestroy, unitClass.OnDelete
        local previousSimCreate = unitClass.SimCreateThread
        function unitClass:SimCreateThread(...)
            local result = previousSimCreate(self, ...)
            local record = activeRecord(self)
            if record then queueRecord(record) end
            return result
        end
        function unitClass:OnDestroy(...)
            cancelUnit(self)
            return previousDestroy(self, ...)
        end
        function unitClass:OnDelete(...)
            cancelUnit(self)
            return previousDelete(self, ...)
        end
    end

    local function phasePayload(value)
        return type(value) == "table" and value.version == 2 and session ~= nil
            and value.sequence == session.sequence and not session.cancelled
    end

    function api.Begin(value)
        if type(value) ~= "table" or value.version ~= 2 or value.phase ~= "pan"
            or not integer(value.sequence, 1, 2147483647) or value.sequence <= previousSequence
            or not integer(value.startTick, 0, 2147483647)
            or not integer(Constants.TickRate, 1, 1000)
            or type(value.units) ~= "table" or #value.units < 1 or #value.units > 64 then return false end
        local records, plans, planIds = {}, {}, {}
        for key in pairs(value.units) do
            if not integer(key, 1, #value.units) then return false end
        end
        for _, entry in ipairs(value.units) do
            if type(entry) ~= "table" or not integer(entry.armyId, 0, 255)
                or not supported[entry.tpId] then return false end
            local point, unitId = position(entry.position), identity(entry.unitId)
            local key = entry.armyId .. ":" .. entry.tpId
            if point == nil or plans[key] or (entry.unitId ~= nil and unitId == nil) then return false end
            if unitId then
                local idKey = unitId.index .. ":" .. unitId.version
                if planIds[idKey] then return false end
                planIds[idKey] = true
            end
            plans[key] = true
            records[#records + 1] = { armyId = entry.armyId, tpId = entry.tpId,
                position = point, unitId = unitId }
        end
        if #records ~= #value.units then return false end
        if session ~= nil then return false end
        installHooks()
        previousSequence = value.sequence
        session = { sequence = value.sequence, startTick = value.startTick,
            phase = "pan", records = records,
            gameInfo = GameInfo, mapInfo = GameInfo and GameInfo.MapInfo }
        for _, record in ipairs(records) do
            local unit = liveUnit(record)
            if unit then claim(unit, unit.id, unit.armyId, unit.tp) end
        end
        api.Update()
        return true
    end

    function api.Bind(value)
        if not phasePayload(value) or value.phase ~= "teleport"
            or not integer(value.effectTick, session.startTick, 2147483647)
            or type(value.units) ~= "table"
            or #value.units ~= #session.records then return false end
        for key in pairs(value.units) do
            if not integer(key, 1, #value.units) then return false end
        end
        local pending, seen, seenIds = {}, {}, {}
        for _, entry in ipairs(value.units) do
            local unitId = type(entry) == "table" and identity(entry.unitId)
            if not unitId or not integer(entry.armyId, 0, 255)
                or not supported[entry.tpId] then return false end
            local point = entry.position ~= nil and position(entry.position) or nil
            if entry.position ~= nil and point == nil then return false end
            local idKey = unitId.index .. ":" .. unitId.version
            if seenIds[idKey] then return false end
            seenIds[idKey] = true
            local selected
            for _, record in ipairs(session.records) do
                if record.armyId == entry.armyId and record.tpId == entry.tpId then selected = record; break end
            end
            if not selected or seen[selected] or (selected.unitId and not sameIdentity(selected.unitId, unitId)) then return false end
            seen[selected] = true
            pending[#pending + 1] = { record = selected, unitId = unitId, position = point }
        end
        if #pending ~= #session.records then return false end
        for _, item in ipairs(pending) do
            item.record.unitId = item.unitId
            if item.position then item.record.position = item.position end
            local unit = liveUnit(item.record)
            if unit then
                claim(unit, unit.id, unit.armyId, unit.tp)
            end
        end
        session.phase, session.effectTick = "teleport", value.effectTick
        session.lastEffectRender, session.renderedEffectTime = nil, 0
        api.Update()
        return true
    end

    function api.Reveal(value)
        if not phasePayload(value) or value.phase ~= "released"
            or not integer(value.releaseTick, session.effectTick or session.startTick, 2147483647) then return false end
        session.revealTick, session.releaseTick = value.releaseTick, value.releaseTick
        session.revealRequested = true
        api.Update()
        return true
    end

    function api.Release(value)
        if not phasePayload(value) or value.phase ~= "released"
            or not integer(value.releaseTick, session.effectTick or session.startTick, 2147483647) then return false end
        session.revealTick, session.releaseTick = value.releaseTick, value.releaseTick
        session.phase = "released"
        session.revealRequested, session.releaseRequested = true, true
        api.Update()
        return true
    end

    function api.Reset()
        if session then
            session.cancelled = true
            for _, record in ipairs(session.records) do
                record.cancelled = true
                local unit = record.unit
                if unit then
                    unit.scoCommanderArrivalRecord = nil
                end
                queueCleanup(record, true)
            end
        end
        for _, decal in ipairs(groundScorches) do cleanupQueue[#cleanupQueue + 1] = { decal = decal } end
        if session and session.cameraStarted then
            cleanupQueue[#cleanupQueue + 1] = { camera = true }
        end
        groundScorches, session, previousSequence = {}, nil, 0
        if #cleanupQueue > 0 then requestPump() end
    end

    function api.Cancel(value)
        if not phasePayload(value) then return false end
        local sequence = previousSequence
        api.Reset()
        previousSequence = sequence
        return true
    end

    local function presentSession()
        if session == nil then return end
        if GameInfo ~= session.gameInfo or (GameInfo and GameInfo.MapInfo) ~= session.mapInfo then api.Reset(); return end
        local now = tick()
        if now == nil then return end
        if session.completed then return end
        local complete = session.releaseRequested == true and now >= session.releaseTick
        for _, record in ipairs(session.records) do
            if not record.cancelled and not record.deleted then
                local unit = liveUnit(record)
                local restore = false
                if session.revealRequested and now >= session.revealTick and not record.revealed then
                    record.revealed, restore = true, true
                end
                if session.releaseRequested and now >= session.releaseTick and not record.released then
                    record.released, restore = true, true
                end
                if unit then
                    if not renderable(unit) then
                        stopPortal(record)
                        stopImpact(record)
                    elseif not record.revealed and not record.released and session.phase == "teleport" then
                        arrivalPortal(record, unit)
                    end
                    if restore then restoreDisplay(record, unit) end
                    finishPresentation(record, unit)
                    if hidden(unit) then hideDisplay(unit) end
                elseif record.unit and __Entities and __Entities.Units
                    and __Entities.Units[record.unitId.index] ~= record.unit then
                    cancelUnit(record.unit)
                end
            end
            if not record.released and not record.deleted and not record.cancelled then complete = false end
            if validLocal(record.teleportId) then complete = false end
            if validLocal(record.impactId) then complete = false end
        end
        if session.releaseRequested and now >= session.releaseTick and not session.cameraEnded then
            session.cameraEnded = true
            if session.cameraStarted then
                Import("client/input/cameraController.lua").StopSCOMCommanderArrivalCamera(true)
            end
        end
        if complete then session.completed = true end
    end

    startPump = function()
        -- SCO_CommanderArrivalPresentationPump_v1
        if pumpRunning then return end
        pumpRunning = true
        -- Native prefab jobs and predicted unit poses finish at this boundary.
        -- Render callbacks and command listeners only request this one owned pump.
        NewThread(function()
            while true do
                WaitTickEnd()
                presentationBoundary = true
                local cleanups = cleanupQueue
                cleanupQueue = {}
                for _, item in ipairs(cleanups) do
                    if item.record then
                        local record = item.record
                        record.cleanupQueued = nil
                        stopPortal(record)
                        stopImpact(record)
                        local unit = record.unit
                        if item.restore and unit and not unit.dead and not unit.deleted
                            and validLocal(unit.localId) then restoreDisplay(record, unit) end
                    elseif item.decal then
                        item.decal:Delete()
                    elseif item.camera then
                        Import("client/input/cameraController.lua").StopSCOMCommanderArrivalCamera()
                    end
                end
                local records = pendingRecords
                pendingRecords = {}
                presentSession()
                for record in pairs(records) do
                    if not record.cancelled and not record.deleted then
                        local unit = liveUnit(record)
                        if unit then
                            if hidden(unit) then hideDisplay(unit) end
                            finishPresentation(record, unit)
                        end
                    end
                end
                presentationBoundary = false
                if (session == nil or session.completed) and #cleanupQueue == 0
                    and next(pendingRecords) == nil then break end
                -- WaitTickEnd alone can resume repeatedly within one native flush.
                WaitTicks(1)
            end
            pumpRunning = false
        end)
    end

    requestPump = function()
        -- A post-render request can follow disposal of the current thread bucket.
        -- Start the worker at native tick-end dispatch, where that bucket is still live.
        if not pumpRunning then pumpRequested = true end
    end

    function api.Update()
        if session and (GameInfo ~= session.gameInfo
            or (GameInfo and GameInfo.MapInfo) ~= session.mapInfo) then api.Reset() end
        if (session and not session.completed) or #cleanupQueue > 0
            or next(pendingRecords) ~= nil then requestPump() end
    end

    local function acknowledge(phase)
        Import("common/commands/definitions/session.lua").ExecuteHostFunction.Send(
            "SCOCommanderArrivalReady", {version=2, sequence=session.sequence, phase=phase})
        Engine.Warn("[SCOM Arrival] Rendered " .. phase .. " complete; acknowledgment sent.")
    end

    function api.RenderUpdate()
        if not session or session.cancelled or session.completed or Engine.IsReplayPlayback() then return end
        if GameInfo ~= session.gameInfo or GameInfo.MapInfo ~= session.mapInfo then return end
        local renderTime = Engine.GetCurrentRealtimeInSeconds()
        if finite(renderTime) then
            for _, record in ipairs(session.records) do
                if record.portalFading and not record.portalFadeReady
                    and not record.deleted and not record.cancelled then
                    if record.lastPortalRender then
                        record.renderedPortalFade = record.renderedPortalFade
                            + math.clamp(renderTime - record.lastPortalRender, 0, 0.1)
                    end
                    record.lastPortalRender = renderTime
                    if record.renderedPortalFade >= 0.6 then
                        record.portalFadeReady = true
                        requestPump()
                    end
                end
            end
        end
        if session.phase == "pan" and not session.panAcknowledged then
            local camera = Import("client/input/cameraController.lua")
            if IsObserver() then
                session.panAcknowledged = true
                acknowledge("pan")
                return
            end
            if not session.cameraStarted then
                for _, record in ipairs(session.records) do
                    if record.armyId == GetFocusArmy() then
                        session.cameraStarted = camera.StartSCOMCommanderArrivalCamera(
                            record.armyId, position(record.position), 4.5)
                        if session.cameraStarted then
                            Engine.Warn("[SCOM Arrival] First rendered frame; empty-spawn camera pan started.")
                        end
                        break
                    end
                end
            elseif camera.IsSCOMCommanderArrivalPanComplete() then
                session.panAcknowledged = true
                acknowledge("pan")
            end
        elseif session.phase == "teleport" and not session.teleportAcknowledged then
            local presented = IsObserver()
            for _, record in ipairs(session.records) do
                if record.armyId == GetFocusArmy() then
                    local unit = liveUnit(record)
                    -- Invisible terrain has no portal to wait for. Visible own
                    -- commanders must have their native effect allocated first.
                    presented = unit ~= nil and (not renderable(unit) or validLocal(record.teleportId))
                    break
                end
            end
            if not presented then return end
            local now = renderTime
            if not finite(now) then return end
            if session.lastEffectRender then
                session.renderedEffectTime = session.renderedEffectTime
                    + math.clamp(now - session.lastEffectRender, 0, 0.1)
            end
            session.lastEffectRender = now
            if session.renderedEffectTime >= 2.5 then
                session.teleportAcknowledged = true
                acknowledge("teleport")
            end
        end
    end

    _G.SCO_CommanderArrivalVisuals = api
    Engine.Log("[SCOM Arrival] Rendered arrival listeners installed: 2.1.0.")
    for _, name in ipairs({ "Begin", "Bind", "Reveal", "Release", "Cancel" }) do
        local callback = "SCOCommanderArrival" .. name
        assert(functions[callback] == nil, "Occupied SCOM arrival listener: " .. callback)
        functions[callback] = api[name]
    end
end

-- Surface wakes and occasional destruction splashes, owned entirely by the client.
if not rawget(_G, "SCO_NavalWaterEffects_v1") then
    local unitClass = Import("client/units/unitsClasses/unitsBaseClass.lua").ClientUnit
    local unitsUpdate = Import("client/units/unitsUpdate.lua")
    local records, pending, fading, splashes = {}, {}, {}, {}
    local pumpRunning, pumpRequested = false, false
    local prefabs = {}
    local failedPrefabs = {}
    local reportedBoat, reportedWake = false, false
    local surfaceBias, fadeSeconds = 0.25, 2.6
    local sampleInterval, minimumSpeed, maximumCameraHeight = 0.1, 0.5, 350
    local one = EngineClasses.float3(1, 1, 1)
    local up = EngineClasses.float3(0, 1, 0)
    local smallPath = "VFX/SCOM/Naval/boat_wake.sanvfx"
    local mediumPath = "VFX/SCOM/Naval/boat_wake_medium.sanvfx"
    local largePath = "VFX/SCOM/Naval/boat_wake_large.sanvfx"
    local splashPath = "VFX/Environment/vxi5301_water_splash_large_impact.sanvfx"
    local startPump, requestPump

    local function finite(value)
        return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
    end

    local function valid(id)
        return id ~= nil and Engine.IsValidLocalID(id)
    end

    local function isBoat(unit)
        local movement = unit.tp and unit.tp.movement
        if not movement or unit:HasTags(Tags.STRUCTURE) then return false end
        return movement.type == "WaterSurface"
            or (movement.type == "TracksAmphibious" and unit:HasTags(Tags.NAVAL))
    end

    local function waterPoint(unit, water)
        local position = unit:GetPosition()
        if not position or not finite(position.x) or not finite(position.z) then return nil end
        local code, terrain = Engine.SampleTerrainHeight(position)
        if code ~= EngineErrorCode.Success or not finite(terrain) or terrain >= water then return nil end
        return EngineClasses.float3(position.x, water + surfaceBias, position.z)
    end

    local function waterLevel()
        local code, exists = Engine.HasWater()
        if code ~= EngineErrorCode.Success or not exists then return nil end
        local levelCode, level = Engine.GetWaterLevel()
        if levelCode == EngineErrorCode.Success and finite(level) then return level end
    end

    local function getPrefab(path)
        if prefabs[path] then return prefabs[path] end
        if failedPrefabs[path] then return nil end
        -- CreatePrefab only references effects registered with the native renderer.
        if not Engine.LoadEffect(path) then
            failedPrefabs[path] = true
            Engine.Error("[SCOM Naval] Could not load effect: " .. path)
            return nil
        end
        local hierarchy = Import("common/loading/hierarchyTemplateLoader.lua")
        local prefab = EngineClasses.PrefabTemplate("SCOM_Naval_" .. path:match("([^/]+)%.sanvfx$"),
            EngineClasses.HierarchyTemplate(hierarchy.GetHierarchyEntities(nil)),
            EngineClasses.GlobalTemplate(),
            EngineClasses.LocalTemplate(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                { EngineClasses.ParticleTemplate(TemplateHeadEntityName, path, path == splashPath, true) }))
        local code, id = Engine.CreatePrefab(prefab)
        if code ~= EngineErrorCode.Success or type(id) ~= "table" or not finite(id.Value)
            or id.Value < 0 or id.Value >= 65535 then
            failedPrefabs[path] = true
            Engine.Error("[SCOM Naval] Could not create effect prefab: " .. path)
            return nil
        end
        prefabs[path] = id
        return id
    end

    local function createTrail(path, position, rotation)
        local prefab = getPrefab(path)
        if not prefab then return nil end
        local code, id = Engine.InstantiatePrefab(prefab, position, one, rotation)
        if code == EngineErrorCode.Success and valid(id) then return id end
        prefabs[path], failedPrefabs[path] = nil, true
        Engine.Error("[SCOM Naval] Effect instantiation failed; path disabled: " .. path)
    end

    local function deleteTrail(item)
        if valid(item.id) then Engine.DeletePrefabInstance(item.id) end
        fading[item] = nil
    end

    local function retire(record, now, purge)
        if record.active then
            local item = { id = record.active, expires = now + fadeSeconds }
            record.active = nil
            if purge then
                deleteTrail(item)
            else
                if valid(item.id) then Engine.SetParticleCanEmit(item.id, false) end
                -- Completion is measured from the original spawn time by the engine.
                -- Keep auto-deletion disabled and own the short tail explicitly.
                fading[item] = true
                table.insert(record.retired, item)
            end
        end
        for index = #record.retired, 1, -1 do
            if not fading[record.retired[index]] then table.remove(record.retired, index) end
        end
        if purge then
            for _, item in ipairs(record.retired) do deleteTrail(item) end
            record.retired = {}
        elseif #record.retired > 1 then
            deleteTrail(table.remove(record.retired, 1))
        end
    end

    startPump = function()
        if pumpRunning then return end
        pumpRunning = true
        NewThread(function()
            while true do
                WaitTickEnd()
                local now = Engine.GetCurrentRealtimeInSeconds()
                if not finite(now) then now = 0 end
                local work = pending
                pending = {}
                for record in pairs(work) do
                    if record.purge or record.want == nil or record.breakTrail then
                        retire(record, now, record.purge)
                    end
                    record.breakTrail = nil
                    if record.want and not record.purge and not record.finished and not valid(record.active) then
                        record.active = createTrail(record.path, record.want, record.rotation)
                        if record.active and not reportedWake then
                            reportedWake = true
                            Engine.Log("[SCOM Naval] First surface wake instantiated for " .. tostring(record.unit.tpId))
                        end
                    end
                    record.purge = nil
                end
                for item in pairs(fading) do
                    if now >= item.expires or not valid(item.id) then deleteTrail(item) end
                end
                local deaths = splashes
                splashes = {}
                for _, position in ipairs(deaths) do
                    local prefab = getPrefab(splashPath)
                    if prefab then Engine.InstantiatePrefab(prefab, position, one, GetIdentityQuaternion()) end
                end
                if next(pending) == nil and next(fading) == nil and #splashes == 0 then break end
                WaitTicks(1)
            end
            pumpRunning = false
        end)
    end

    local function request(record)
        pending[record] = true
        requestPump()
    end

    requestPump = function()
        -- Render callbacks can run after their tick's native thread bucket closed.
        -- Start the coroutine only inside the next tick-end flush.
        if not pumpRunning then pumpRequested = true end
    end

    local function track(unit)
        if not isBoat(unit) or unit.scoNavalWakeRecord then return end
        local collision = unit.tp.collisionInfo and unit.tp.collisionInfo.collisionSize
        local offset = unit.tp.collisionInfo and unit.tp.collisionInfo.centerOffset
        local length = collision and collision.z or 4
        local width = collision and collision.x or 1
        if not finite(length) then length = 4 end
        if not finite(width) then width = 1 end
        local record = { unit = unit, length = math.max(1, math.min(length, 64)),
            width = math.max(0.3, math.min(width, 32)), retired = {},
            offsetX = offset and finite(offset.x) and offset.x or 0,
            offsetZ = offset and finite(offset.z) and offset.z or 0 }
        -- Native delayed particles discard instance scale; sizes are authored per bin.
        record.path = record.width <= 1.8 and smallPath or (record.width <= 4.5 and mediumPath or largePath)
        unit.scoNavalWakeRecord = record
        records[unit] = record
        if not reportedBoat then
            reportedBoat = true
            Engine.Log("[SCOM Naval] First surface boat tracked: " .. tostring(unit.tpId))
        end
    end

    local function stop(unit, purge, finished)
        local record = unit.scoNavalWakeRecord
        if not record then return end
        record.want, record.lastPosition = nil, nil
        record.purge = record.purge or purge
        if finished then record.finished = true; records[unit] = nil end
        request(record)
    end

    local function updateWakes()
        local now = Engine.GetCurrentRealtimeInSeconds()
        local water = waterLevel()
        local cameraHeight = Engine.GetCameraWorldSpaceHeight()
        local nearby = water ~= nil and finite(cameraHeight) and cameraHeight - water <= maximumCameraHeight
        for unit, record in pairs(records) do
            local unitValid = valid(unit.localId)
            local purge = unit.dead or unit.deleted or not unitValid or not unit:IsIntelVisionVisible()
                or water == nil
            if purge then
                record.want, record.lastPosition = nil, nil
                record.purge = true
                if unit.dead or unit.deleted or not unitValid then
                    record.finished = true
                    records[unit] = nil
                end
                if record.active or #record.retired > 0 then request(record) end
            elseif finite(now) and (not record.nextSample or now >= record.nextSample or now < record.lastSample) then
                -- Foam emits only four times a second. Ten pose samples per second are
                -- sufficient to follow the hull without four native writes every frame.
                record.lastSample, record.nextSample = now, now + sampleInterval
                local point
                if nearby and unit.isInitialized ~= false and not unit:IsPlacementGhost() then
                    local speedCode, speed = Engine.GetMovementCurrentSpeed(unit.id)
                    -- Native movement speed is distance per simulation tick.
                    local step = Constants.TickTimeStep or (1 / Constants.TickRate)
                    if speedCode == EngineErrorCode.Success and finite(speed) and speed >= minimumSpeed * step then
                        point = waterPoint(unit, water)
                    end
                end
                if point then
                    local previous = record.lastPosition
                    record.lastPosition = EngineClasses.float3(point.x, point.y, point.z)
                    if previous then
                        local dx, dz = point.x - previous.x, point.z - previous.z
                        if dx * dx + dz * dz > math.max(4, record.length * 2) ^ 2 then
                            record.breakTrail = true
                        end
                    end
                    local code, forward = Engine.GetLocalEntityForwardDirection(unit.localId)
                    local heading = code == EngineErrorCode.Success and forward
                        and finite(forward.x) and finite(forward.z)
                        and math.sqrt(forward.x * forward.x + forward.z * forward.z) or 0
                    if heading > 0.0001 then
                        local x, z = forward.x / heading, forward.z / heading
                        record.rotation = Engine.QuaternionLookRotationSafe(EngineClasses.float3(x, 0, z), up)
                        point.x, point.z = point.x + z * record.offsetX + x * record.offsetZ - x * record.length * 0.5,
                            point.z - x * record.offsetX + z * record.offsetZ - z * record.length * 0.5
                        local terrainCode, terrain = Engine.SampleTerrainHeight(point)
                        if terrainCode ~= EngineErrorCode.Success or not finite(terrain) or terrain >= water then point = nil end
                    else
                        point = nil
                    end
                end
                record.want = point
                if point and valid(record.active) and not record.breakTrail then
                    Engine.SetLocalEntityLocalPosition(record.active, point)
                    Engine.SetLocalEntityLocalRotation(record.active, record.rotation)
                elseif point or record.active then
                    if record.active or #record.retired > 0 or not failedPrefabs[record.path] then request(record) end
                end
                if not point then record.lastPosition = nil end
            end
        end
    end

    local function splashRoll(id)
        if type(id) ~= "table" or not finite(id.index) or not finite(id.version) then return false end
        -- Identity hashing keeps this cosmetic roll consistent across clients/replays
        -- and never advances the gameplay or ordinary death-effect random stream.
        local seed = (id.index * 48271 + id.version * 69621 + 17) % 2147483647
        seed = (seed * 48271 + 1) % 2147483647
        seed = (seed * 48271 + 1) % 2147483647
        return seed % 4 == 0
    end

    local previousCreate = unitClass.SimCreateThread
    function unitClass:SimCreateThread(...)
        local result = previousCreate(self, ...)
        track(self)
        return result
    end

    local previousDestroy = unitClass.OnDestroy
    function unitClass:OnDestroy(destroyType, ...)
        local death = destroyType == DestroyType.Kinetic or destroyType == DestroyType.Unspecified
        if not self.scoNavalDeathHandled then
            self.scoNavalDeathHandled = true
            if death and isBoat(self) and not self.dead and not self.deleted
                and valid(self.localId) and not self:IsPlacementGhost() and self:IsIntelVisionVisible()
                and splashRoll(self.id) then
                local water = waterLevel()
                local position = water ~= nil and waterPoint(self, water)
                if position then table.insert(splashes, position); requestPump() end
            end
        end
        stop(self, not death, true)
        return previousDestroy(self, destroyType, ...)
    end

    local previousDelete = unitClass.OnDelete
    function unitClass:OnDelete(...)
        stop(self, not self.dead, true)
        return previousDelete(self, ...)
    end

    local previousHidden = unitClass.OnIntelHidden
    function unitClass:OnIntelHidden(...)
        stop(self, true, false)
        return previousHidden(self, ...)
    end

    local previousRender = unitsUpdate.RenderUpdateUnits
    unitsUpdate.RenderUpdateUnits = function(...)
        local result = previousRender(...)
        updateWakes()
        return result
    end
    local previousFlush = _G.ThreadDispatcherFlush
    assert(type(previousFlush) == "function", "SCOM naval effects need native tick-end dispatch")
    function _G.ThreadDispatcherFlush(...)
        if pumpRequested and not pumpRunning then
            pumpRequested = false
            startPump()
        end
        return previousFlush(...)
    end
    _G.SCO_NavalWaterEffects_v1 = { version = "1.4.0" }
    Engine.Log("[SCOM Naval] Surface wakes and 25% destruction splashes installed: 1.4.0.")
end

-- FA TDFRiot02 uses one of three tank ribbon variants per projectile.
-- psf0035 is shared by Fatboy riotguns and uel5005; simulation is untouched.
do
    local class = Import("client/projectiles/projectilesClasses/projectilesBaseClass.lua").ClientProjectile
    if not class.scoRiotRibbonSelection then
        local setup = assert(class.SetUpPersistentEffects)
        function class:SetUpPersistentEffects()
            setup(self)
            if self.tpId ~= "psf0035" then return end
            assert(self.tp.visuals.scoRandomPolyTrails == 1, "Riot ribbon selection contract missing")
            local bones = {}
            for index = 0, 2 do
                local bone = self:GetBoneId("SCO_SourceRibbon_" .. index)
                assert(Engine.IsValidLocalID(bone), "Riot ribbon owner missing")
                bones[index + 1] = bone
            end
            assert(#self.persistentEffects == 3, "Riot ribbon owner count changed")
            -- This cosmetic seed uses bounded integer arithmetic exact in LuaJIT.
            -- It avoids consuming the game's shared random state.
            local seed = (tonumber(self.id.index) + tonumber(self.id.version) * 104729) % 2147483647
            seed = (seed * 48271) % 2147483647
            local selected = seed % 3 + 1
            for index, bone in ipairs(bones) do
                Engine.SetParticleCanEmit(bone, index == selected)
            end
            self.persistentEffects = { bones[selected] }
        end
        class.scoRiotRibbonSelection = true
    end
end

-- SCOM support commander scope 9ba13eb34106cb566e3f2014d1b56ae08bf67f1c2465a353068631779ed325aa 5AEB68F76F5E409CC27E7C2BAF02EC8FC754333EC7594AC10C3C95A747BE039A
-- Supreme Commander Overhaul commander enhancements 1.0.0
-- Receives owner-targeted authority plus a minimal peer visual projection,
-- rejects stale GlobalID revisions, and drives imported ACU upgrade submeshes
-- without ever hiding a root entity.
local SCOCommanderEnhancementClientEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderEnhancementClientMarker = rawget(
    SCOCommanderEnhancementClientEnvironment,
    "SCO_CommanderEnhancementClientListenerInstalled")
if SCOCommanderEnhancementClientMarker ~= nil
    and SCOCommanderEnhancementClientMarker ~= "1.6.0"
then
    error("Unsupported SCOM commander-enhancement client-listener marker "
        .. tostring(SCOCommanderEnhancementClientMarker))
end
if SCOCommanderEnhancementClientMarker == nil then
    -- Host and client have separate Lua states; load the shared visual rules
    -- before the first commander renders or receives an enhancement snapshot.
    Import("common/systems/scoCommanderEnhancements.lua")

    if type(functions) ~= "table"
        or type(__Entities) ~= "table"
        or type(__Entities.Units) ~= "table"
        or type(GetFocusArmy) ~= "function"
    then
        error("SCOM commander enhancements could not resolve client listener state")
    end

    local SCOSupportedCommanders = {
        uel0000 = true,
        ugl0000 = true,
        ucl0000 = true,
        usl0000 = true,
    }
    local SCOFallbackVisualSlots = {
        uel0000 = {
            LCH = { "Left_Upgrade" },
            RCH = { "Right_Upgrade" },
            Back = { "Back_Upgrade_B01" },
        },
        ugl0000 = {
            LCH = { "Right_Upgrade" },
            RCH = { "Chest_Right", "Chest_Left" },
            Back = { "Back_Upgrade" },
        },
        ucl0000 = {
            LCH = { "Left_Upgrade" },
            RCH = { "Right_Upgrade" },
            Back = { "Back_Upgrade" },
        },
        usl0000 = {
            LCH = { "Left_Upgrade" },
            RCH = { "Right_Upgrade" },
            Back = { "Back_Upgrade" },
        },
    }
SCOSupportedCommanders.ucl4002 = true
SCOSupportedCommanders.uel5007 = true
SCOSupportedCommanders.ugl5004 = true
SCOSupportedCommanders.usl4002 = true
SCOFallbackVisualSlots.ucl4002 = {Back={"Turbine"}}
SCOFallbackVisualSlots.uel5007 = {Back={"Jetpack","SAM"}}
SCOFallbackVisualSlots.ugl5004 = {Back={"AA_Gun","Power_Pack","Rez_Protocol","Torpedo","Turbine"}}
SCOFallbackVisualSlots.usl4002 = {Back={"Back_Upgrade"}}

    local SCOAllowedVisualBones = {}
    for tpId, slots in pairs(SCOFallbackVisualSlots) do
        local allowed = {}
        for _, bones in pairs(slots) do
            for _, boneName in ipairs(bones) do
                allowed[boneName] = true
            end
        end
        SCOAllowedVisualBones[tpId] = allowed
    end

    local SCOMaxPendingStates = 64
    local SCOMaxEnhancements = 32
    local SCOMaxSlots = 16
    local SCOMaxCapabilityDomains = 16
    local SCOMaxReasonLength = 256
    local SCOPodBones = {
        LeftPod = "AttachSpecial02",
        RightPod = "AttachSpecial01",
    }
    local SCOPodDockRotationOffsets = {}
    -- Sanctuary imports each ACU as one skinned renderer. Upgrade bones own
    -- rigid vertex islands, but do not own renderers, so renderer toggles on
    -- the bones cannot hide them. Project hidden islands below the model and
    -- reapply the projection after animation on every render update.
    local SCOHiddenBonePosition = { x = 0, y = -64, z = 0 }
    local SCOHiddenBoneTolerance = 0.001
    local SCOPendingStates = {}
    local SCOPendingStateCount = 0
    local SCOPendingVisualStates = {}
    local SCOPendingVisualStateCount = 0
    local SCOStateRequestCooldowns = {}
    local SCOVisualStateRequestCooldowns = {}

    local function SCOFinite(value)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
    end

    local function SCOFiniteVector(value)
        return type(value) == "table"
            and SCOFinite(value.x)
            and SCOFinite(value.y)
            and SCOFinite(value.z)
    end

    local function SCOQuaternionComponents(value)
        if type(value) ~= "table" then return nil end
        local components = type(value.value) == "table"
            and value.value or value
        if not SCOFinite(components.x)
            or not SCOFinite(components.y)
            or not SCOFinite(components.z)
            or not SCOFinite(components.w)
        then
            return nil
        end
        return components
    end

    local function SCOFiniteQuaternion(value)
        return SCOQuaternionComponents(value) ~= nil
    end

    local function SCOCopyQuaternion(value)
        local components = SCOQuaternionComponents(value)
        if components == nil then return nil end
        local copy = {
            x = components.x,
            y = components.y,
            z = components.z,
            w = components.w,
        }
        if type(value.value) == "table" then
            return { value = copy }
        end
        return copy
    end

    local function SCOInteger(value, minimum, maximum)
        return SCOFinite(value)
            and value == math.floor(value)
            and value >= minimum
            and value <= maximum
    end

    local function SCODeepCopy(value, seen)
        if type(value) ~= "table" then return value end
        seen = seen or {}
        if seen[value] then return seen[value] end
        local copy = {}
        seen[value] = copy
        for key, item in pairs(value) do
            copy[SCODeepCopy(key, seen)] = SCODeepCopy(item, seen)
        end
        return copy
    end

    local function SCOIdentifier(value)
        return type(value) == "string"
            and #value >= 1
            and #value <= 96
            and string.match(value, "^[%w_%-]+$") ~= nil
    end

    local function SCOCommanderContract(tpId)
        local contract = _G.SCO_CommanderEnhancementContract
        local commanders = type(contract) == "table" and contract.commanders
        local commander = type(commanders) == "table" and commanders[tpId]
        if type(commander) ~= "table"
            or type(commander.enhancements) ~= "table"
        then
            return nil
        end
        return commander
    end

    local function SCOResolvePodDockRotationOffset(logicalName)
        local cached = SCOPodDockRotationOffsets[logicalName]
        if cached ~= nil then return cached end

        local commander = SCOCommanderContract("uel0000")
        local enhancement = commander
            and commander.enhancements[logicalName]
        local effects = type(enhancement) == "table" and enhancement.effects
        local spawn = type(effects) == "table" and effects.spawn
        local degrees = type(spawn) == "table"
            and spawn.dockRotationDegrees
        if not SCOFiniteVector(degrees) then return nil end
        local ok, offset = pcall(
            Engine.EulerToQuaternion,
            EngineClasses.float3(
                math.rad(degrees.x),
                math.rad(degrees.y),
                math.rad(degrees.z)),
            RotationOrder.Default)
        if not ok or type(offset) ~= "table" then return nil end
        SCOPodDockRotationOffsets[logicalName] = offset
        return offset
    end

    local function SCOComposePodDockRotation(logicalName, boneRotation)
        if type(boneRotation) ~= "table" then return nil end
        local offset = SCOResolvePodDockRotationOffset(logicalName)
        if offset == nil then return nil end
        local ok, rotation = pcall(
            Engine.QuaternionMultiply,
            boneRotation,
            offset)
        if not ok or type(rotation) ~= "table" then return nil end
        return rotation
    end

    local function SCOCanonicalInstalled(value)
        if type(value) ~= "table" then return nil end
        local result = {}
        local count = 0
        for enhancementId, installed in pairs(value) do
            if not SCOIdentifier(enhancementId) or installed ~= true then
                return nil
            end
            count = count + 1
            if count > SCOMaxEnhancements then return nil end
            result[enhancementId] = true
        end
        return result
    end

    local function SCOCanonicalSlots(value)
        if type(value) ~= "table" then return nil end
        local result = {}
        local count = 0
        for slot, enhancementId in pairs(value) do
            if not SCOIdentifier(slot) or not SCOIdentifier(enhancementId) then
                return nil
            end
            count = count + 1
            if count > SCOMaxSlots then return nil end
            result[slot] = enhancementId
        end
        return result
    end

    local function SCOCanonicalVisualHidden(value, tpId)
        if type(value) ~= "table" then return nil end
        local allowed = SCOAllowedVisualBones[tpId]
        if type(allowed) ~= "table" then return nil end
        local result = {}
        local count = 0
        for boneName, hidden in pairs(value) do
            if allowed[boneName] ~= true or hidden ~= true then return nil end
            count = count + 1
            if count > SCOMaxSlots then return nil end
            result[boneName] = true
        end
        return result
    end

    local function SCOCanonicalActive(value)
        if value == nil then return nil, true end
        if type(value) ~= "table"
            or not SCOIdentifier(value.id)
            or (value.kind ~= "install" and value.kind ~= "remove")
            or type(value.paused) ~= "boolean"
            or not SCOFinite(value.progress)
            or not SCOFinite(value.buildTime)
            or not SCOFinite(value.fraction)
            or not SCOFinite(value.buildPower)
            or not SCOFinite(value.estimatedSeconds)
            or value.buildTime <= 0
            or value.buildTime > 1000000000
            or value.progress < 0
            or value.progress > value.buildTime
            or value.fraction < 0
            or value.fraction > 1
            or value.buildPower <= 0
            or value.buildPower > 1000000000
            or value.estimatedSeconds < 0
            or value.estimatedSeconds > 1000000000
        then
            return nil, false
        end
        return {
            id = value.id,
            kind = value.kind,
            paused = value.paused,
            progress = value.progress,
            buildTime = value.buildTime,
            fraction = value.fraction,
            buildPower = value.buildPower,
            estimatedSeconds = value.estimatedSeconds,
        }, true
    end

    local function SCOCanonicalEnhancementCapabilities(value)
        if type(value) ~= "table" then return nil end
        local result = {}
        local enhancementCount = 0
        for enhancementId, capability in pairs(value) do
            if not SCOIdentifier(enhancementId)
                or type(capability) ~= "table"
                or type(capability.install) ~= "boolean"
                or type(capability.partial) ~= "boolean"
                or type(capability.domains) ~= "table"
                or (capability.reason ~= nil
                    and (type(capability.reason) ~= "string"
                        or #capability.reason > SCOMaxReasonLength))
            then
                return nil
            end
            enhancementCount = enhancementCount + 1
            if enhancementCount > SCOMaxEnhancements then return nil end

            local domains = {}
            local domainCount = 0
            for domain, supported in pairs(capability.domains) do
                if not SCOIdentifier(domain) or type(supported) ~= "boolean" then
                    return nil
                end
                domainCount = domainCount + 1
                if domainCount > SCOMaxCapabilityDomains then return nil end
                domains[domain] = supported
            end
            result[enhancementId] = {
                install = capability.install,
                partial = capability.partial,
                domains = domains,
                reason = capability.reason,
            }
        end
        return result
    end

    local function SCOCanonicalAbilityValue(value, depth, budget)
        local valueType = type(value)
        if valueType == "boolean" then return value end
        if valueType == "number" then
            return SCOFinite(value) and value or nil
        end
        if valueType == "string" then
            return #value <= SCOMaxReasonLength and value or nil
        end
        if valueType ~= "table" or depth >= 3 then return nil end
        local result = {}
        for key, entry in pairs(value) do
            -- Missile racks, teleport, cloak, and Overcharge share this snapshot.
            if budget.count >= 96 then return nil end
            local validKey = (type(key) == "string" and SCOIdentifier(key))
                or SCOInteger(key, 1, 32)
            if not validKey then return nil end
            local canonical = SCOCanonicalAbilityValue(
                entry,
                depth + 1,
                budget)
            if canonical == nil and entry ~= nil then return nil end
            budget.count = budget.count + 1
            result[key] = canonical
        end
        return result
    end

    local function SCOCanonicalAbilities(value)
        if value == nil then return {} end
        return SCOCanonicalAbilityValue(value, 0, { count = 0 })
    end

    local function SCOCanonicalPods(value)
        if value == nil then return {} end
        if type(value) ~= "table" then return nil end
        local result = {}
        local count = 0
        for logicalName, pod in pairs(value) do
            if SCOPodBones[logicalName] == nil
                or type(pod) ~= "table"
                or type(pod.unitId) ~= "table"
                or not SCOInteger(pod.unitId.index, 1, 2147483647)
                or not SCOInteger(pod.unitId.version, 0, 2147483647)
                or type(pod.docked) ~= "boolean"
            then
                return nil
            end
            count = count + 1
            if count > 2 then return nil end
            result[logicalName] = {
                unitId = {
                    index = pod.unitId.index,
                    version = pod.unitId.version,
                },
                docked = pod.docked,
            }
        end
        return result
    end

    local function SCOCanonicalSnapshot(value)
        if type(value) ~= "table"
            or value.version ~= "1.0.0"
            or not SCOSupportedCommanders[value.tpId]
            or type(value.unitId) ~= "table"
            or not SCOInteger(value.unitId.index, 1, 2147483647)
            or not SCOInteger(value.unitId.version, 0, 2147483647)
            or not SCOInteger(value.revision, 0, 2147483647)
            or type(value.idle) ~= "boolean"
            or type(value.capabilities) ~= "table"
            or not SCOInteger(value.capabilities.engineeringTier, 1, 3)
        then
            return nil
        end
        local installed = SCOCanonicalInstalled(value.installed)
        local slots = SCOCanonicalSlots(value.slots)
        local visualHidden =
            SCOCanonicalVisualHidden(value.visualHidden, value.tpId)
        local active, activeValid = SCOCanonicalActive(value.active)
        local enhancementCapabilities =
            SCOCanonicalEnhancementCapabilities(value.capabilities.enhancements)
        local abilities = SCOCanonicalAbilities(value.abilities)
        local pods = SCOCanonicalPods(value.pods)
        if not installed
            or not slots
            or not visualHidden
            or not activeValid
            or not enhancementCapabilities
            or not abilities
            or not pods
            or (value.tpId ~= "uel0000" and next(pods) ~= nil)
        then
            return nil
        end
        return {
            version = "1.0.0",
            tpId = value.tpId,
            unitId = {
                index = value.unitId.index,
                version = value.unitId.version,
            },
            revision = value.revision,
            idle = value.idle,
            installed = installed,
            slots = slots,
            visualHidden = visualHidden,
            active = active,
            abilities = abilities,
            pods = pods,
            capabilities = {
                engineeringTier = value.capabilities.engineeringTier,
                enhancements = enhancementCapabilities,
            },
        }
    end

    local function SCOCanonicalVisualSnapshot(value)
        if type(value) ~= "table"
            or value.version ~= "1.0.0"
            or not SCOSupportedCommanders[value.tpId]
            or type(value.unitId) ~= "table"
            or not SCOInteger(value.unitId.index, 1, 2147483647)
            or not SCOInteger(value.unitId.version, 0, 2147483647)
            or not SCOInteger(value.revision, 0, 2147483647)
        then
            return nil
        end
        local installed = SCOCanonicalInstalled(value.installed)
        local slots = SCOCanonicalSlots(value.slots)
        local visualHidden =
            SCOCanonicalVisualHidden(value.visualHidden, value.tpId)
        local abilities = SCOCanonicalAbilities(value.abilities)
        local pods = SCOCanonicalPods(value.pods)
        if not installed
            or not slots
            or not visualHidden
            or not abilities
            or not pods
            or (value.tpId ~= "uel0000" and next(pods) ~= nil)
        then
            return nil
        end
        return {
            version = "1.0.0",
            tpId = value.tpId,
            unitId = {
                index = value.unitId.index,
                version = value.unitId.version,
            },
            revision = value.revision,
            installed = installed,
            slots = slots,
            visualHidden = visualHidden,
            abilities = abilities,
            pods = pods,
        }
    end

    local function SCOUnitTpId(unit)
        return unit and (unit.tpId
            or (unit.tp and unit.tp.general and unit.tp.general.tpId))
    end

    local function SCOPodsMatchInstalledState(state)
        local seen = {}
        for logicalName, pod in pairs(state.pods or {}) do
            if state.tpId ~= "uel0000"
                or state.installed[logicalName] ~= true
                or type(pod) ~= "table"
                or type(pod.unitId) ~= "table"
            then
                return false
            end
            local key = tostring(pod.unitId.index)
                .. ":" .. tostring(pod.unitId.version)
            if seen[key]
                or (pod.unitId.index == state.unitId.index
                    and pod.unitId.version == state.unitId.version)
            then
                return false
            end
            seen[key] = true
        end
        return true
    end

    local function SCOStateMatchesContract(state, commander)
        local rules = commander.enhancements
        for enhancementId in pairs(state.installed) do
            local rule = rules[enhancementId]
            if type(rule) ~= "table"
                or (rule.id ~= nil and rule.id ~= enhancementId)
            then
                return false
            end
            local slot = rule.slot
            if not SCOIdentifier(slot)
                or state.slots[slot] == nil
            then
                return false
            end
        end
        for slot, enhancementId in pairs(state.slots) do
            local rule = rules[enhancementId]
            if not state.installed[enhancementId]
                or type(rule) ~= "table"
                or rule.slot ~= slot
            then
                return false
            end
        end
        for enhancementId in pairs(state.capabilities.enhancements) do
            if type(rules[enhancementId]) ~= "table" then return false end
        end
        return SCOPodsMatchInstalledState(state)
            and (state.active == nil
                or type(rules[state.active.id]) == "table")
    end

    local function SCOUnitAcceptsState(unit, state)
        if unit == nil
            or unit.id == nil
            or unit.id.index ~= state.unitId.index
            or unit.id.version ~= state.unitId.version
            or unit.armyId ~= GetFocusArmy()
            or unit.dead == true
            or SCOUnitTpId(unit) ~= state.tpId
        then
            return false
        end
        local commander = SCOCommanderContract(state.tpId)
        return commander ~= nil and SCOStateMatchesContract(state, commander)
    end

    local function SCOUnitAcceptsVisualState(unit, state)
        if unit == nil
            or unit.id == nil
            or unit.id.index ~= state.unitId.index
            or unit.id.version ~= state.unitId.version
            or unit.dead == true
            or SCOUnitTpId(unit) ~= state.tpId
        then
            return false
        end
        local commander = SCOCommanderContract(state.tpId)
        if commander == nil then return false end
        for enhancementId in pairs(state.installed) do
            local rule = commander.enhancements[enhancementId]
            if type(rule) ~= "table"
                or state.slots[rule.slot] == nil
            then
                return false
            end
        end
        for slot, enhancementId in pairs(state.slots) do
            local rule = commander.enhancements[enhancementId]
            if not state.installed[enhancementId]
                or type(rule) ~= "table"
                or rule.slot ~= slot
            then
                return false
            end
        end
        return SCOPodsMatchInstalledState(state)
    end

    local function SCOVisualSlots(tpId, commander)
        local slots = commander and commander.visualSlots
        if type(slots) ~= "table" then
            slots = SCOFallbackVisualSlots[tpId]
        end
        return slots
    end

    local function SCOApplyClientWeaponState(unit, state)
        if SCOUnitTpId(unit) ~= "ugl0000" then return end
        local additions = unit.tp and unit.tp.additions
        local indexes = additions
            and additions.scoCommanderEnhancementWeapons
        local weaponIndex = type(indexes) == "table" and indexes.MLG
        local weapon = type(weaponIndex) == "number"
            and unit.weapons
            and unit.weapons[weaponIndex]
        if type(weapon) ~= "table" or type(weapon.tp) ~= "table" then
            return
        end
        if weapon.scoCommanderEnhancementPrivateTemplate ~= true then
            weapon.tp = SCODeepCopy(weapon.tp)
            weapon.scoCommanderEnhancementPrivateTemplate = true
        end
        local installed = type(state) == "table" and state.installed or {}
        weapon.tp.rangeMax = installed.MicrowaveLaserGenerator
            and installed.CoolingUpgrade
            and 30
            or 22
        -- Widen this commander beam only; its shared Monkeylord mesh and
        -- longitudinal scale remain unchanged.
        for _, muzzle in ipairs(weapon.muzzles or {}) do
            local beam = muzzle.beam
            for _, submeshId in ipairs(beam and beam.submeshes or {}) do
                Engine.SetMeshRendererScale(submeshId, EngineClasses.float3(2, 2, 1))
            end
        end
    end

    local function SCOSetClientRangeRing(unit, materialName, radius, enabled)
        local materials = rawget(_G, "RangeRingMaterial")
        local rings = unit and unit.rangeRings
        if type(materials) ~= "table" or type(rings) ~= "table" then
            return
        end
        local material = materials[materialName]
        local ring = material ~= nil and rings[material]
        if ring == nil then return end
        if type(radius) == "number"
            and type(ring.SetOuterRadius) == "function"
        then
            pcall(ring.SetOuterRadius, ring, radius)
        end
        if type(enabled) == "boolean"
            and type(ring.SetEnabled) == "function"
        then
            pcall(ring.SetEnabled, ring, enabled)
        end
    end

    local function SCOApplyClientRangeRingState(unit, state)
        local tpId = SCOUnitTpId(unit)
        local installed = type(state) == "table" and state.installed or {}
        local directRadius = 22
        if tpId == "uel0000" and installed.HeavyAntiMatterCannon then
            directRadius = 30
        elseif tpId == "ucl0000" and installed.CrysalisBeam then
            directRadius = 35
        elseif tpId == "ugl0000" and installed.CoolingUpgrade then
            directRadius = 30
        elseif tpId == "usl0000" and installed.RateOfFire then
            directRadius = 30
        end
        SCOSetClientRangeRing(unit, "AttackDirect", directRadius)

        if tpId == "ucl0000" then
            local sensorRadius = installed.EnhancedSensors and 50 or 26
            SCOSetClientRangeRing(unit, "Vision", sensorRadius)
            SCOSetClientRangeRing(unit, "FogOfWar", sensorRadius)
        elseif tpId == "ugl0000" then
            -- The torpedo weapon exists from template load so it can be
            -- activated host-side without mutating shared templates. Its
            -- native naval ring must not advertise an uninstalled weapon.
            SCOSetClientRangeRing(
                unit,
                "AttackAntiNavy",
                60,
                installed.NaniteTorpedoTube == true)
        end
    end

    local function SCOEngineCallSucceeded(errorCode)
        local success = type(EngineErrorCode) == "table"
            and EngineErrorCode.Success or nil
        if success ~= nil then return errorCode == success end
        return errorCode == nil or errorCode == 0
    end

    local function SCOValidLocalId(localId)
        if type(localId) ~= "table" then return false end
        if type(Engine.IsValidLocalID) ~= "function" then return true end
        local checked, valid = pcall(Engine.IsValidLocalID, localId)
        return checked and valid == true
    end

    local function SCOClonePosition(position)
        return { x = position.x, y = position.y, z = position.z }
    end

    local function SCOIsHiddenPosition(position)
        return math.abs(position.x - SCOHiddenBonePosition.x)
                <= SCOHiddenBoneTolerance
            and math.abs(position.y - SCOHiddenBonePosition.y)
                <= SCOHiddenBoneTolerance
            and math.abs(position.z - SCOHiddenBonePosition.z)
                <= SCOHiddenBoneTolerance
    end

    local function SCOResolveVisualBone(unit, boneName)
        local bones = unit.scoCommanderEnhancementVisualBones
        if type(bones) ~= "table" then
            bones = {}
            unit.scoCommanderEnhancementVisualBones = bones
        end
        local bone = bones[boneName]
        if type(bone) == "table" and SCOValidLocalId(bone.id) then
            return bone
        end
        bones[boneName] = nil

        local resolved, errorCode, boneId = pcall(
            Engine.GetLocalBone,
            unit.localId,
            boneName)
        if not resolved
            or not SCOEngineCallSucceeded(errorCode)
            or not SCOValidLocalId(boneId)
        then
            return nil
        end
        bone = {
            id = boneId,
            lastVisiblePosition = nil,
            hiddenApplied = false,
        }
        bones[boneName] = bone
        return bone
    end

    local function SCOReadVisualBonePosition(bone)
        local read, errorCode, position = pcall(
            Engine.GetLocalEntityLocalPosition,
            bone.id)
        if not read
            or not SCOEngineCallSucceeded(errorCode)
            or type(position) ~= "table"
            or not SCOFinite(position.x)
            or not SCOFinite(position.y)
            or not SCOFinite(position.z)
        then
            return nil
        end
        return position
    end

    local function SCOSetVisualBonePosition(bone, position)
        local applied, errorCode = pcall(
            Engine.SetLocalEntityLocalPosition,
            bone.id,
            position)
        return applied and SCOEngineCallSucceeded(errorCode)
    end

    local function SCOApplyVisualBoneState(unit, boneName, enabled)
        local bone = SCOResolveVisualBone(unit, boneName)
        if bone == nil then return false end
        local current = SCOReadVisualBonePosition(bone)
        if current == nil then return false end

        if enabled then
            if SCOIsHiddenPosition(current) then
                if type(bone.lastVisiblePosition) ~= "table"
                    or not SCOSetVisualBonePosition(
                        bone,
                        bone.lastVisiblePosition)
                then
                    return false
                end
            else
                -- Animation may already have restored the live transform.
                bone.lastVisiblePosition = SCOClonePosition(current)
            end
            bone.hiddenApplied = false
            return true
        end

        if not SCOIsHiddenPosition(current) then
            -- Cache this frame's animated local transform. This is required for
            -- the walking Cybran chest panels, whose positions are not static.
            bone.lastVisiblePosition = SCOClonePosition(current)
        end
        if not SCOSetVisualBonePosition(bone, SCOHiddenBonePosition) then
            return false
        end
        bone.hiddenApplied = true
        return true
    end

    local function SCORefreshVisualBoneTransforms(unit, enabledByBone)
        if type(Engine) ~= "table"
            or type(Engine.GetLocalBone) ~= "function"
            or type(Engine.GetLocalEntityLocalPosition) ~= "function"
            or type(Engine.SetLocalEntityLocalPosition) ~= "function"
        then
            return false
        end
        local allVisualBonesResolved = true
        for boneName, enabled in pairs(enabledByBone) do
            if not SCOApplyVisualBoneState(unit, boneName, enabled) then
                allVisualBonesResolved = false
            end
        end
        return allVisualBonesResolved
    end

    local function SCOApplyVisualState(unit, state)
        if type(unit) ~= "table"
            or type(unit.localId) ~= "table"
        then
            return false
        end
        local tpId = SCOUnitTpId(unit)
        local allowed = SCOAllowedVisualBones[tpId]
        local commander = SCOCommanderContract(tpId)
        if not allowed or not commander then return false end
        -- ClientBeam raycasts through its owning ClientWeapon's live tp. Keep
        -- this per-instance copy in sync for both owner and peer projections;
        -- never mutate the shared UnitTemplate weapon table.
        SCOApplyClientWeaponState(unit, state)
        SCOApplyClientRangeRingState(unit, state)
        local visualKey = "bone-position-v1:"
            .. tostring(unit.localId.index)
            .. ":" .. tostring(unit.localId.version)
            .. ":" .. tostring(state and state.revision or "none")
        if unit.scoCommanderEnhancementVisualKey == visualKey
            and type(unit.scoCommanderEnhancementDesiredVisualBones) == "table"
        then
            return true
        end

        local enabledByBone = {}
        for boneName in pairs(allowed) do
            enabledByBone[boneName] = false
        end

        -- Cybran chest panels are stock base geometry. The relevant RCH rules
        -- carry declarative hide operations; no state means the panels remain.
        if tpId == "ugl0000" then
            enabledByBone.Chest_Left = true
            enabledByBone.Chest_Right = true
        end

        if state ~= nil then
            for slot, bones in pairs(SCOVisualSlots(tpId, commander) or {}) do
                if type(slot) == "string"
                    and type(bones) == "table"
                    and state.slots[slot] ~= nil
                then
                    for _, boneName in ipairs(bones) do
                        local useSlotDefault =
                            not (tpId == "ugl0000" and slot == "RCH")
                        if useSlotDefault and allowed[boneName] then
                            enabledByBone[boneName] = true
                        end
                    end
                end
            end

            local explicitlyHidden = {}
            for enhancementId in pairs(state.installed) do
                local rule = commander.enhancements[enhancementId]
                local visual = type(rule) == "table" and rule.visual
                if type(visual) == "table" then
                    for _, boneName in ipairs(visual.show or {}) do
                        if allowed[boneName] then
                            enabledByBone[boneName] = true
                        end
                    end
                    for _, boneName in ipairs(visual.hide or {}) do
                        if allowed[boneName] then
                            explicitlyHidden[boneName] = true
                        end
                    end
                end
            end
            for boneName in pairs(explicitlyHidden) do
                enabledByBone[boneName] = false
            end
            for boneName in pairs(state.visualHidden or {}) do
                if allowed[boneName] then enabledByBone[boneName] = false end
            end
        end
        unit.scoCommanderEnhancementDesiredVisualBones = enabledByBone
        local allVisualBonesResolved =
            SCORefreshVisualBoneTransforms(unit, enabledByBone)
        -- Local bones can appear a frame after the replicated unit. Do not
        -- memoize a partial pass; the visual monitor and owner panel refreshes
        -- can retry the same revision until every upgrade bone resolves.
        if allVisualBonesResolved then
            unit.scoCommanderEnhancementVisualKey = visualKey
        end
        return allVisualBonesResolved
    end

    local function SCORefreshCommanderEnhancementVisuals(unit)
        if type(unit) ~= "table"
            or not SCOSupportedCommanders[SCOUnitTpId(unit)]
        then
            return false
        end
        local desired = unit.scoCommanderEnhancementDesiredVisualBones
        if type(desired) == "table" then
            return SCORefreshVisualBoneTransforms(unit, desired)
        end

        local state = unit.scoCommanderEnhancementState
        if type(state) ~= "table" or not SCOUnitAcceptsState(unit, state) then
            state = unit.scoCommanderEnhancementVisualState
            if type(state) ~= "table"
                or not SCOUnitAcceptsVisualState(unit, state)
            then
                state = nil
            end
        end
        return SCOApplyVisualState(unit, state)
    end

    local function SCOCurrentCommanderPodState(unit)
        local state = unit.scoCommanderEnhancementState
        if type(state) == "table" and SCOUnitAcceptsState(unit, state) then
            return state
        end
        state = unit.scoCommanderEnhancementVisualState
        if type(state) == "table"
            and SCOUnitAcceptsVisualState(unit, state)
        then
            return state
        end
        return nil
    end

    local function SCOResolveCommanderPodBone(unit, logicalName)
        local cache = unit.scoCommanderPodDockBones
        if type(cache) ~= "table" then
            cache = {}
            unit.scoCommanderPodDockBones = cache
        end
        local boneId = cache[logicalName]
        if SCOValidLocalId(boneId) then return boneId end
        cache[logicalName] = nil
        local resolved, errorCode, candidate = pcall(
            Engine.GetLocalBone,
            unit.localId,
            SCOPodBones[logicalName])
        if not resolved
            or not SCOEngineCallSucceeded(errorCode)
            or not SCOValidLocalId(candidate)
        then
            return nil
        end
        cache[logicalName] = candidate
        return candidate
    end

    local function SCOResolveCommanderPodLocalId(podState)
        local unitId = podState and podState.unitId
        if type(unitId) ~= "table" then return nil end
        local pod = __Entities.Units[unitId.index]
        if pod ~= nil then
            if type(pod.id) ~= "table"
                or pod.id.index ~= unitId.index
                or pod.id.version ~= unitId.version
                or pod.dead == true
                or SCOUnitTpId(pod) ~= "uea0001"
                or not SCOValidLocalId(pod.localId)
            then
                return nil
            end
            return pod.localId
        end
        local resolved, errorCode, localId = pcall(
            Engine.GetGlobalEntityPairedLocalID,
            unitId)
        if not resolved
            or not SCOEngineCallSucceeded(errorCode)
            or not SCOValidLocalId(localId)
        then
            return nil
        end
        return localId
    end

    local function SCOResolveCommanderPodUnit(podState)
        local unitId = podState and podState.unitId
        if type(unitId) ~= "table" then return nil end
        local pod = __Entities.Units[unitId.index]
        if type(pod) ~= "table"
            or type(pod.id) ~= "table"
            or pod.id.index ~= unitId.index
            or pod.id.version ~= unitId.version
            or pod.dead == true
            or SCOUnitTpId(pod) ~= "uea0001"
            or not SCOValidLocalId(pod.localId)
        then
            return nil
        end
        return pod
    end

    local function SCOResolveCommanderPodVisualRoot(pod)
        local root = pod.scoCommanderPodVisualRoot
        if SCOValidLocalId(root) then return root end
        pod.scoCommanderPodVisualRoot = nil
        local resolved, errorCode, candidate = pcall(
            Engine.GetLocalBone,
            pod.localId,
            "Root")
        if not resolved
            or not SCOEngineCallSucceeded(errorCode)
            or not SCOValidLocalId(candidate)
        then
            return nil
        end
        pod.scoCommanderPodVisualRoot = candidate
        return candidate
    end

    local function SCOEnsureCommanderPodVisualRest(pod, root)
        local rest = pod.scoCommanderPodVisualRestRotation
        if SCOFiniteQuaternion(rest) then return rest end
        pod.scoCommanderPodVisualRestRotation = nil
        local read, errorCode, rotation = pcall(
            Engine.GetLocalEntityLocalRotation,
            root)
        if not read
            or not SCOEngineCallSucceeded(errorCode)
            or not SCOFiniteQuaternion(rotation)
        then
            return nil
        end
        rest = SCOCopyQuaternion(rotation)
        pod.scoCommanderPodVisualRestRotation = rest
        return rest
    end

    local function SCOInvertQuaternion(rotation)
        local components = SCOQuaternionComponents(rotation)
        if components == nil then return nil end
        local lengthSquared = components.x * components.x
            + components.y * components.y
            + components.z * components.z
            + components.w * components.w
        if not SCOFinite(lengthSquared) or lengthSquared <= 0.000001 then
            return nil
        end
        local inverse = {
            x = -components.x / lengthSquared,
            y = -components.y / lengthSquared,
            z = -components.z / lengthSquared,
            w = components.w / lengthSquared,
        }
        if type(rotation.value) == "table" then
            return { value = inverse }
        end
        return inverse
    end

    local function SCORestoreCommanderPodVisualRoot(pod)
        if pod.scoCommanderPodVisualFacing ~= true then return true end
        local root = SCOResolveCommanderPodVisualRoot(pod)
        local rest = root ~= nil
            and SCOEnsureCommanderPodVisualRest(pod, root) or nil
        if root == nil or rest == nil then return false end
        local set, errorCode = pcall(
            Engine.SetLocalEntityLocalRotation,
            root,
            rest)
        if not set or not SCOEngineCallSucceeded(errorCode) then return false end
        pod.scoCommanderPodVisualFacing = false
        return true
    end

    local function SCOFaceCommanderPodFlight(pod)
        local root = SCOResolveCommanderPodVisualRoot(pod)
        local rest = root ~= nil
            and SCOEnsureCommanderPodVisualRest(pod, root) or nil
        if root == nil or rest == nil then return false end
        -- UEA0001's imported Root rests at 180 degrees. Native plane movement
        -- faces +Z; use the same visual forward basis as construction in flight.
        -- Keep the authored rest cached for the separate shoulder docking pose.
        local set, errorCode = pcall(
            Engine.SetLocalEntityLocalRotation,
            root,
            { x = 0, y = 0, z = 0, w = 1 })
        if not set or not SCOEngineCallSucceeded(errorCode) then return false end
        pod.scoCommanderPodVisualFacing = true
        return true
    end

    local function SCOFaceCommanderPodBuildTarget(pod)
        local target = pod.buildTarget
        if pod.isBuilding ~= true
            or type(target) ~= "table"
            or target.dead == true
            or type(target.GetPosition) ~= "function"
        then
            return SCOFaceCommanderPodFlight(pod)
        end

        local root = SCOResolveCommanderPodVisualRoot(pod)
        local rest = root ~= nil
            and SCOEnsureCommanderPodVisualRest(pod, root) or nil
        if root == nil or rest == nil then return false end
        local targetRead, targetPosition = pcall(target.GetPosition, target)
        local podRead, podCode, podPosition = pcall(
            Engine.GetLocalEntityWorldPosition,
            pod.localId)
        local rotationRead, rotationCode, podWorldRotation = pcall(
            Engine.GetLocalEntityWorldRotation,
            pod.localId)
        if not targetRead
            or not SCOFiniteVector(targetPosition)
            or not podRead
            or not SCOEngineCallSucceeded(podCode)
            or not SCOFiniteVector(podPosition)
            or not rotationRead
            or not SCOEngineCallSucceeded(rotationCode)
            or not SCOFiniteQuaternion(podWorldRotation)
        then
            return false
        end

        local x = targetPosition.x - podPosition.x
        local z = targetPosition.z - podPosition.z
        if x * x + z * z <= 0.000001 then return true end
        local lookRead, targetWorldRotation = pcall(
            Engine.QuaternionLookRotationSafe,
            EngineClasses.float3(x, 0, z),
            EngineClasses.float3(0, 1, 0))
        local inverse = SCOInvertQuaternion(podWorldRotation)
        if not lookRead
            or not SCOFiniteQuaternion(targetWorldRotation)
            or inverse == nil
        then
            return false
        end
        local localRead, rootLocalRotation = pcall(
            Engine.QuaternionMultiply,
            inverse,
            targetWorldRotation)
        if not localRead or not SCOFiniteQuaternion(rootLocalRotation) then
            return false
        end
        local set, errorCode = pcall(
            Engine.SetLocalEntityLocalRotation,
            root,
            rootLocalRotation)
        if not set or not SCOEngineCallSucceeded(errorCode) then return false end
        pod.scoCommanderPodVisualFacing = true
        return true
    end

    local function SCOSetCommanderPodDockInteraction(podState, docked)
        local pod = SCOResolveCommanderPodUnit(podState)
        if pod == nil
            or type(pod.SetSelectionEnabled) ~= "function"
            or type(pod.IsSelectable) ~= "function"
            or type(pod.IsHighlightable) ~= "function"
        then
            return false
        end

        if type(pod.scoCommanderPodBaseIsSelectable) ~= "function" then
            pod.scoCommanderPodBaseIsSelectable = pod.IsSelectable
            pod.scoCommanderPodBaseIsHighlightable = pod.IsHighlightable
            pod.IsSelectable = function(self)
                if self.scoCommanderPodDocked == true then return false end
                return self.scoCommanderPodBaseIsSelectable(self)
            end
            pod.IsHighlightable = function(self)
                if self.scoCommanderPodDocked == true then return false end
                return self.scoCommanderPodBaseIsHighlightable(self)
            end
        end

        local shouldEnableSelection = docked ~= true
        if pod.scoCommanderPodSelectionEnabled ~= shouldEnableSelection then
            local enabled = pcall(
                pod.SetSelectionEnabled,
                pod,
                shouldEnableSelection)
            if not enabled then return false end
            pod.scoCommanderPodSelectionEnabled = shouldEnableSelection
        end
        pod.scoCommanderPodDocked = docked == true
        return true
    end

    local function SCOReadCommanderPodDockPose(boneId)
        local positionRead, positionCode, position = pcall(
            Engine.GetLocalEntityWorldPosition,
            boneId)
        local rotationRead, rotationCode, rotation = pcall(
            Engine.GetLocalEntityWorldRotation,
            boneId)
        if not positionRead
            or not rotationRead
            or not SCOEngineCallSucceeded(positionCode)
            or not SCOEngineCallSucceeded(rotationCode)
            or not SCOFiniteVector(position)
            or type(rotation) ~= "table"
        then
            return nil, nil
        end
        return position, rotation
    end

    local function SCOApplyCommanderPodDockVisual(
        unit, logicalName, podState)
        local boneId = SCOResolveCommanderPodBone(unit, logicalName)
        local podLocalId = SCOResolveCommanderPodLocalId(podState)
        if boneId == nil or podLocalId == nil then return false end
        local position, rotation = SCOReadCommanderPodDockPose(boneId)
        if position == nil or rotation == nil then return false end
        rotation = SCOComposePodDockRotation(logicalName, rotation)
        if rotation == nil then return false end
        local positionSet, positionCode = pcall(
            Engine.SetLocalEntityLocalPosition,
            podLocalId,
            position)
        local rotationSet, rotationCode = pcall(
            Engine.SetLocalEntityLocalRotation,
            podLocalId,
            rotation)
        return positionSet
            and rotationSet
            and SCOEngineCallSucceeded(positionCode)
            and SCOEngineCallSucceeded(rotationCode)
    end

    local function SCORefreshCommanderPodDockVisuals(unit)
        if type(unit) ~= "table"
            or SCOUnitTpId(unit) ~= "uel0000"
            or type(unit.localId) ~= "table"
            or type(Engine) ~= "table"
            or type(Engine.GetLocalBone) ~= "function"
            or type(Engine.GetGlobalEntityPairedLocalID) ~= "function"
            or type(Engine.GetLocalEntityLocalRotation) ~= "function"
            or type(Engine.GetLocalEntityWorldPosition) ~= "function"
            or type(Engine.GetLocalEntityWorldRotation) ~= "function"
            or type(Engine.EulerToQuaternion) ~= "function"
            or type(Engine.QuaternionLookRotationSafe) ~= "function"
            or type(Engine.QuaternionMultiply) ~= "function"
            or type(Engine.SetLocalEntityLocalPosition) ~= "function"
            or type(Engine.SetLocalEntityLocalRotation) ~= "function"
            or type(EngineClasses) ~= "table"
            or type(EngineClasses.float3) ~= "function"
            or type(RotationOrder) ~= "table"
            or RotationOrder.Default == nil
        then
            return false
        end
        local state = SCOCurrentCommanderPodState(unit)
        if type(state) ~= "table" then return false end
        local allApplied = true
        for logicalName, podState in pairs(state.pods or {}) do
            if not SCOSetCommanderPodDockInteraction(
                podState,
                podState.docked == true)
            then
                allApplied = false
            end
            local pod = SCOResolveCommanderPodUnit(podState)
            if podState.docked == true then
                if pod ~= nil
                    and not SCORestoreCommanderPodVisualRoot(pod)
                then
                    allApplied = false
                end
                if not SCOApplyCommanderPodDockVisual(
                    unit, logicalName, podState)
                then
                    allApplied = false
                end
            elseif pod == nil
                or not SCOFaceCommanderPodBuildTarget(pod)
            then
                allApplied = false
            end
        end
        return allApplied
    end

    local function SCOAttachState(unit, state)
        if not SCOUnitAcceptsState(unit, state) then return false end
        local current = unit.scoCommanderEnhancementState
        if type(current) == "table"
            and current.unitId
            and current.unitId.version == state.unitId.version
            and SCOInteger(current.revision, 0, 2147483647)
            and current.revision >= state.revision
        then
            SCOApplyVisualState(unit, current)
            return false
        end
        unit.scoCommanderEnhancementState = state
        SCOStateRequestCooldowns[state.unitId.index] = nil
        SCOApplyVisualState(unit, state)
        if type(unit.SetUIDirtyIfSelected) == "function" then
            unit:SetUIDirtyIfSelected()
        end
        return true
    end

-- Insert before the listener's SCOAttachVisualState, after SCOAttachState.
local supportAttachState = SCOAttachState
SCOAttachState = function(unit, state)
    local accepted = supportAttachState(unit, state)
    if unit and unit.tpId == "uel5007" then
        local current = unit.scoCommanderEnhancementState
        if current then
            unit.scoSourcePodInstalled = current.installed.Pod == true
            unit.scoSourcePodWorking = current.active and current.active.id == "Pod" or false
            unit.scoSourcePodProgress = unit.scoSourcePodWorking and (current.active.fraction or 0) or 0
        end
    end
    return accepted
end
local supportRanges = SCOApplyClientRangeRingState
SCOApplyClientRangeRingState = function(unit, state)
    local additions = unit.tp and unit.tp.additions
    if not (additions and additions.scoSupportCommanderEnhancements) then return supportRanges(unit, state) end
    local commander = SCOCommanderContract(SCOUnitTpId(unit))
    local vision = commander.base.visionRadius
    for id in pairs(state and state.installed or {}) do
        local effect = commander.enhancements[id].effects.intel
        if effect and effect.visionRadiusSet then vision = effect.visionRadiusSet end
    end
    SCOSetClientRangeRing(unit, "Vision", vision)
    SCOSetClientRangeRing(unit, "FogOfWar", vision)
    SCOSetClientRangeRing(unit, "AttackIndirect", 256, state and state.installed.Missile == true or false)
end

    local function SCOAttachVisualState(unit, state)
        if not SCOUnitAcceptsVisualState(unit, state) then return false end
        local current = unit.scoCommanderEnhancementVisualState
        if type(current) == "table"
            and current.unitId
            and current.unitId.version == state.unitId.version
            and SCOInteger(current.revision, 0, 2147483647)
            and current.revision >= state.revision
        then
            SCOApplyVisualState(unit, current)
            return false
        end
        unit.scoCommanderEnhancementVisualState = state
        SCOApplyVisualState(unit, state)
        return true
    end

    local function SCOStorePending(state)
        local index = state.unitId.index
        local current = SCOPendingStates[index]
        if current ~= nil then
            if current.unitId.version > state.unitId.version
                or (current.unitId.version == state.unitId.version
                    and current.revision >= state.revision)
            then
                return false
            end
        elseif SCOPendingStateCount >= SCOMaxPendingStates then
            return false
        else
            SCOPendingStateCount = SCOPendingStateCount + 1
        end
        SCOPendingStates[index] = state
        return true
    end

    local function SCOReceiveCommanderEnhancementState(value)
        local state = SCOCanonicalSnapshot(value)
        if not state then return false end
        local unit = __Entities.Units[state.unitId.index]
        if unit ~= nil and not SCOUnitAcceptsState(unit, state) then
            return false
        end
        if not SCOStorePending(state) then return false end
        return unit ~= nil and SCOAttachState(unit, state) or true
    end

    local function SCOStorePendingVisualState(state)
        local index = state.unitId.index
        local current = SCOPendingVisualStates[index]
        if current ~= nil then
            if current.unitId.version > state.unitId.version
                or (current.unitId.version == state.unitId.version
                    and current.revision >= state.revision)
            then
                return false
            end
        elseif SCOPendingVisualStateCount >= SCOMaxPendingStates then
            return false
        else
            SCOPendingVisualStateCount = SCOPendingVisualStateCount + 1
        end
        SCOPendingVisualStates[index] = state
        return true
    end

    local function SCOReceiveCommanderEnhancementVisualState(value)
        local state = SCOCanonicalVisualSnapshot(value)
        if not state then return false end
        local unit = __Entities.Units[state.unitId.index]
        if unit ~= nil and not SCOUnitAcceptsVisualState(unit, state) then
            return false
        end
        if not SCOStorePendingVisualState(state) then return false end
        return unit ~= nil and SCOAttachVisualState(unit, state) or true
    end

    local function SCOGetCommanderEnhancementClientState(unit)
        local tpId = SCOUnitTpId(unit)
        if not SCOSupportedCommanders[tpId]
            or unit == nil
            or unit.id == nil
            or unit.armyId ~= GetFocusArmy()
        then
            return nil
        end
        local pending = SCOPendingStates[unit.id.index]
        if pending ~= nil
            and pending.unitId.version == unit.id.version
            and SCOUnitAcceptsState(unit, pending)
        then
            SCOAttachState(unit, pending)
        end
        local current = unit.scoCommanderEnhancementState
        if type(current) == "table" and SCOUnitAcceptsState(unit, current) then
            SCOApplyVisualState(unit, current)
            return current
        end
        local visual = unit.scoCommanderEnhancementVisualState
        if type(visual) == "table"
            and SCOUnitAcceptsVisualState(unit, visual)
        then
            SCOApplyVisualState(unit, visual)
        else
            -- Imported ACUs ship upgrade submeshes in the base rig. Hide only
            -- the known upgrade bones until replicated visual state arrives.
            SCOApplyVisualState(unit, nil)
        end
        return nil
    end

    local SCOStateDispatcher = _G.SCO_CommanderEnhancementStateDispatcher
    if SCOStateDispatcher ~= nil and type(SCOStateDispatcher) ~= "function" then
        error("SCOM commander-enhancement state dispatcher is occupied")
    end
    if SCOStateDispatcher == nil then
        SCOStateDispatcher = function(value)
            local handler = _G.SCO_CommanderEnhancementStateHandler
            if type(handler) ~= "function" then return false end
            return handler(value)
        end
        _G.SCO_CommanderEnhancementStateDispatcher = SCOStateDispatcher
    end
    _G.SCO_CommanderEnhancementStateHandler =
        SCOReceiveCommanderEnhancementState
    functions.SCOCommanderEnhancementState = SCOStateDispatcher

    local SCOVisualStateDispatcher =
        _G.SCO_CommanderEnhancementVisualStateDispatcher
    if SCOVisualStateDispatcher ~= nil
        and type(SCOVisualStateDispatcher) ~= "function"
    then
        error("SCOM commander-enhancement visual-state dispatcher is occupied")
    end
    if SCOVisualStateDispatcher == nil then
        SCOVisualStateDispatcher = function(value)
            local handler =
                _G.SCO_CommanderEnhancementVisualStateHandler
            if type(handler) ~= "function" then return false end
            return handler(value)
        end
        _G.SCO_CommanderEnhancementVisualStateDispatcher =
            SCOVisualStateDispatcher
    end
    _G.SCO_CommanderEnhancementVisualStateHandler =
        SCOReceiveCommanderEnhancementVisualState
    functions.SCOCommanderEnhancementVisualState =
        SCOVisualStateDispatcher

    local SCOStateGetter = _G.SCO_GetCommanderEnhancementClientState
    if SCOStateGetter ~= nil and type(SCOStateGetter) ~= "function" then
        error("SCOM commander-enhancement client-state getter is occupied")
    end
    if SCOStateGetter == nil then
        SCOStateGetter = function(unit)
            local handler = _G.SCO_CommanderEnhancementClientStateGetterHandler
            if type(handler) ~= "function" then return nil end
            return handler(unit)
        end
        _G.SCO_GetCommanderEnhancementClientState = SCOStateGetter
    end
    _G.SCO_CommanderEnhancementClientStateGetterHandler =
        SCOGetCommanderEnhancementClientState

    local SCOVisualRefreshDispatcher =
        _G.SCO_RefreshCommanderEnhancementVisuals
    if SCOVisualRefreshDispatcher ~= nil
        and type(SCOVisualRefreshDispatcher) ~= "function"
    then
        error("SCOM commander-enhancement visual refresh is occupied")
    end
    if SCOVisualRefreshDispatcher == nil then
        SCOVisualRefreshDispatcher = function(unit)
            local handler =
                _G.SCO_CommanderEnhancementVisualRefreshHandler
            if type(handler) ~= "function" then return false end
            return handler(unit)
        end
        _G.SCO_RefreshCommanderEnhancementVisuals =
            SCOVisualRefreshDispatcher
    end
    _G.SCO_CommanderEnhancementVisualRefreshHandler =
        SCORefreshCommanderEnhancementVisuals

    local SCOPodVisualRefreshDispatcher =
        _G.SCO_RefreshCommanderPodDockVisuals
    if SCOPodVisualRefreshDispatcher ~= nil
        and type(SCOPodVisualRefreshDispatcher) ~= "function"
    then
        error("SCOM commander-pod visual refresh is occupied")
    end
    if SCOPodVisualRefreshDispatcher == nil then
        SCOPodVisualRefreshDispatcher = function(unit)
            local handler = _G.SCO_CommanderPodVisualRefreshHandler
            if type(handler) ~= "function" then return false end
            return handler(unit)
        end
        _G.SCO_RefreshCommanderPodDockVisuals =
            SCOPodVisualRefreshDispatcher
    end
    _G.SCO_CommanderPodVisualRefreshHandler =
        SCORefreshCommanderPodDockVisuals

    local function SCOMonitorCommanderVisuals()
        while true do
            for index, unit in pairs(__Entities.Units) do
                if unit ~= nil
                    and unit.id ~= nil
                    and SCOSupportedCommanders[SCOUnitTpId(unit)]
                then
                    local pendingVisual = SCOPendingVisualStates[index]
                    if pendingVisual
                        and pendingVisual.unitId.version == unit.id.version
                        and SCOUnitAcceptsVisualState(unit, pendingVisual)
                    then
                        SCOAttachVisualState(unit, pendingVisual)
                    end
                    local visual = unit.scoCommanderEnhancementVisualState
                    local hasVisual = type(visual) == "table"
                        and SCOUnitAcceptsVisualState(unit, visual)
                    if hasVisual then
                        SCOApplyVisualState(unit, visual)
                        SCOVisualStateRequestCooldowns[index] = nil
                    else
                        SCOApplyVisualState(unit, nil)
                    end

                    if unit.armyId == GetFocusArmy() then
                        SCOGetCommanderEnhancementClientState(unit)
                        local cooldown = SCOStateRequestCooldowns[index]
                        if type(cooldown) ~= "table"
                            or cooldown.version ~= unit.id.version
                            or cooldown.scansRemaining <= 0
                        then
                            local request =
                                _G.SCO_CommanderEnhancementClientRequest
                            if type(request) == "function"
                                and request("state", unit.id) == true
                            then
                                -- The monitor runs every 20 ticks; one skipped
                                -- scan gives a bounded 40-tick retry interval.
                                SCOStateRequestCooldowns[index] = {
                                    version = unit.id.version,
                                    scansRemaining = 1,
                                }
                            end
                        else
                            cooldown.scansRemaining =
                                cooldown.scansRemaining - 1
                        end
                    elseif not hasVisual then
                        local cooldown =
                            SCOVisualStateRequestCooldowns[index]
                        if type(cooldown) ~= "table"
                            or cooldown.version ~= unit.id.version
                            or cooldown.scansRemaining <= 0
                        then
                            local request =
                                _G.SCO_CommanderEnhancementClientRequest
                            if type(request) == "function"
                                and request("visual", unit.id) == true
                            then
                                -- Late peers and observers need a minimal
                                -- visual snapshot even when no upgrade changed
                                -- after they joined.
                                SCOVisualStateRequestCooldowns[index] = {
                                    version = unit.id.version,
                                    scansRemaining = 1,
                                }
                            end
                        else
                            cooldown.scansRemaining =
                                cooldown.scansRemaining - 1
                        end
                    end
                end
            end
            for index, cooldown in pairs(SCOStateRequestCooldowns) do
                local unit = __Entities.Units[index]
                if unit == nil
                    or unit.id == nil
                    or unit.id.version ~= cooldown.version
                    or unit.armyId ~= GetFocusArmy()
                    or not SCOSupportedCommanders[SCOUnitTpId(unit)]
                then
                    SCOStateRequestCooldowns[index] = nil
                end
            end
            for index, cooldown in pairs(SCOVisualStateRequestCooldowns) do
                local unit = __Entities.Units[index]
                if unit == nil
                    or unit.id == nil
                    or unit.id.version ~= cooldown.version
                    or unit.armyId == GetFocusArmy()
                    or not SCOSupportedCommanders[SCOUnitTpId(unit)]
                then
                    SCOVisualStateRequestCooldowns[index] = nil
                end
            end
            WaitTicks(20)
        end
    end
    if type(NewThread) == "function" and type(WaitTicks) == "function" then
        NewThread(SCOMonitorCommanderVisuals)
    end

    rawset(
        SCOCommanderEnhancementClientEnvironment,
        "SCO_CommanderEnhancementClientListenerInstalled",
        "1.6.0")
end

-- SCOM support commander scope 9c1378f202fcc1fb204a125426ef87dfb5ed29b8d9b42d94a0a5a61aaf8e3ab3 6410F07F19A2A178F2EC25D908B3989F9E0933FEF0DFBA8DA6E303846C860704
-- Supreme Commander Overhaul commander ability target input 1.0.2
-- Intended target: append to client/clientListeners.lua after the commander
-- enhancement client listener. This resource owns only cursor capture and a
-- validated hand-off to a separately installed host request handler.
local SCOCommanderAbilityInputEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderAbilityInputMarker = rawget(
    SCOCommanderAbilityInputEnvironment,
    "SCO_CommanderAbilityTargetInputInstalled")
if SCOCommanderAbilityInputMarker ~= nil
    and SCOCommanderAbilityInputMarker ~= "1.0.2"
then
    error("Unsupported SCOM commander-ability target-input marker "
        .. tostring(SCOCommanderAbilityInputMarker))
end
if SCOCommanderAbilityInputMarker == nil then
    if rawget(
            SCOCommanderAbilityInputEnvironment,
            "SCO_CommanderEnhancementClientListenerInstalled") ~= "1.6.0"
        or type(functions) ~= "table"
        or type(__Entities) ~= "table"
        or type(__Entities.Units) ~= "table"
        or type(GetFocusArmy) ~= "function"
        or type(Import) ~= "function"
    then
        error("SCOM commander ability input requires the enhancement client listener")
    end

    local SCOInputEvents = Import("client/inputEventsFunctions.lua")
    local SCOMouseCursor = Import("client/input/mouseCursor.lua")
    if type(SCOInputEvents) ~= "table"
        or type(SCOInputEvents.OnMouseLeftDown) ~= "function"
        or type(SCOInputEvents.OnMouseLeftUp) ~= "function"
        or type(SCOInputEvents.OnMouseRightDown) ~= "function"
        or type(SCOInputEvents.OnMouseRightUp) ~= "function"
        or type(SCOMouseCursor) ~= "table"
        or type(SCOMouseCursor.IsCursorInGameView) ~= "function"
        or type(SCOMouseCursor.GetMousePosition) ~= "function"
        or type(Engine) ~= "table"
        or type(Engine.IsMouseOverUI) ~= "function"
    then
        error("SCOM commander ability input could not resolve cursor contracts")
    end

    local SCOSupportedCommanders = {
        uel0000 = true,
        ucl0000 = true,
        ugl0000 = true,
        usl0000 = true,
    }
SCOSupportedCommanders.ucl4002 = true
SCOSupportedCommanders.uel5007 = true
SCOSupportedCommanders.ugl5004 = true
SCOSupportedCommanders.usl4002 = true

    local SCOAbilityRules = {
        Overcharge = { unitTarget = true },
        Teleport = {
            enhancementId = "Teleporter",
            capabilityDomain = "teleport",
        },
        MissileLaunch = {
            dynamicMissile = true,
        },
    }
    local SCOActiveTargetInput = nil
    local SCOPointerDown = false

    local function SCOFinite(value)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
    end

    local function SCOInteger(value, minimum, maximum)
        return SCOFinite(value)
            and value == math.floor(value)
            and value >= minimum
            and value <= maximum
    end

    local function SCOGlobalId(value)
        if type(value) ~= "table"
            or not SCOInteger(value.index, 1, 2147483647)
            or not SCOInteger(value.version, 0, 2147483647)
        then
            return nil
        end
        return { index = value.index, version = value.version }
    end

    local function SCOPosition(value)
        if type(value) ~= "table"
            or not SCOFinite(value.x)
            or not SCOFinite(value.y)
            or not SCOFinite(value.z)
        then
            return nil
        end
        return { x = value.x, y = value.y, z = value.z }
    end

    local function SCOUnitTpId(unit)
        return unit and (unit.tpId
            or (unit.tp and unit.tp.general and unit.tp.general.tpId))
    end

    local function SCOResolveOwnedCommander(unitId)
        local canonicalId = SCOGlobalId(unitId)
        if canonicalId == nil then return nil end
        local unit = __Entities.Units[canonicalId.index]
        if unit == nil
            or unit.id == nil
            or unit.id.version ~= canonicalId.version
            or unit.dead == true
            or unit.armyId ~= GetFocusArmy()
            or not SCOSupportedCommanders[SCOUnitTpId(unit)]
        then
            return nil
        end
        if type(IsObserver) == "function" and IsObserver() then return nil end
        return unit
    end

    local function SCOGetAuthorityState(unit)
        local getter = rawget(_G, "SCO_GetCommanderEnhancementClientState")
        if type(getter) ~= "function" then return nil end
        local ok, state = pcall(getter, unit)
        if not ok
            or type(state) ~= "table"
            or type(state.unitId) ~= "table"
            or state.unitId.index ~= unit.id.index
            or state.unitId.version ~= unit.id.version
            or type(state.installed) ~= "table"
            or type(state.capabilities) ~= "table"
            or type(state.capabilities.enhancements) ~= "table"
        then
            return nil
        end
        return state
    end

    local function SCOCanTargetAbility(unit, abilityId)
        local rule = SCOAbilityRules[abilityId]
        if type(rule) ~= "table" or unit == nil then return false end
        local state = SCOGetAuthorityState(unit)
        if type(state) ~= "table" or state.active ~= nil then return false end
        if rule.unitTarget then
            local tpId = SCOUnitTpId(unit)
            if tpId ~= "uel0000" and tpId ~= "ucl0000"
                and tpId ~= "ugl0000" and tpId ~= "usl0000"
            then return false end
            local selected = Import("client/input/selectionSystem.lua").GetSelectedUnits()
            local count, current = 0, nil
            for _, candidate in pairs(selected or {}) do
                count, current = count + 1, candidate
            end
            if count ~= 1 or current ~= unit then return false end
            local overcharge = type(state.abilities) == "table"
                and state.abilities.overcharge
            return type(overcharge) == "table"
                and overcharge.available == true
                and overcharge.ready == true
        end
        if rule.dynamicMissile == true then
            local abilities = state.abilities
            local missile = type(abilities) == "table" and abilities.missile
            return type(missile) == "table"
                and missile.available == true
                and type(missile.ammo) == "number"
                and missile.ammo >= 1
                and missile.building ~= true
                and (type(missile.cooldownRemaining) ~= "number"
                    or missile.cooldownRemaining <= 0)
                and type(missile.rangeMin) == "number"
                and type(missile.rangeMax) == "number"
        end
        local capability =
            state.capabilities.enhancements[rule.enhancementId]
        return state.installed[rule.enhancementId] == true
            and type(capability) == "table"
            and type(capability.domains) == "table"
            and capability.domains[rule.capabilityDomain] == true
    end

    local function SCONotifyTargetInput(reason)
        local callback = rawget(_G, "SCO_CommanderAbilityTargetingChanged")
        if type(callback) ~= "function" then return end
        local snapshot = nil
        if SCOActiveTargetInput ~= nil then
            snapshot = {
                abilityId = SCOActiveTargetInput.abilityId,
                unitId = SCOGlobalId(SCOActiveTargetInput.unitId),
            }
        end
        pcall(callback, snapshot, reason)
    end

    local function SCOCancelStrategicTargetInput(reason)
        local cancel = rawget(_G, "SCO_CancelStrategicSiloTargetMode")
        return type(cancel) == "function"
            and cancel(reason or "commander-targeting") == true
    end

    local function SCOCancelTargetInput(reason)
        local wasActive = SCOActiveTargetInput ~= nil
        SCOActiveTargetInput = nil
        SCOPointerDown = false
        if wasActive then SCONotifyTargetInput(reason or "cancelled") end
        return wasActive
    end

    local function SCOBeginTargetInput(unit, abilityId)
        if type(unit) ~= "table"
            or not SCOAbilityRules[abilityId]
            or unit.id == nil
        then
            return false
        end
        local ownedUnit = SCOResolveOwnedCommander(unit.id)
        if ownedUnit ~= unit or not SCOCanTargetAbility(unit, abilityId) then
            return false
        end
        SCOCancelStrategicTargetInput("commander-begin")
        SCOActiveTargetInput = {
            abilityId = abilityId,
            unitId = SCOGlobalId(unit.id),
        }
        SCOPointerDown = false
        SCONotifyTargetInput("started")
        return true
    end

    local function SCOGetTargetInputState()
        if SCOActiveTargetInput == nil then return nil end
        return {
            abilityId = SCOActiveTargetInput.abilityId,
            unitId = SCOGlobalId(SCOActiveTargetInput.unitId),
        }
    end

    local SCOAbilityRequestDispatcher =
        rawget(_G, "SCO_CommanderAbilityClientRequest")
    if SCOAbilityRequestDispatcher ~= nil
        and type(SCOAbilityRequestDispatcher) ~= "function"
    then
        error("SCOM commander ability client-request dispatcher is occupied")
    end
    if SCOAbilityRequestDispatcher == nil then
        SCOAbilityRequestDispatcher = function(abilityId, unitId, target)
            local handler = rawget(
                _G,
                "SCO_CommanderAbilityClientRequestHandler")
            if type(handler) ~= "function" then return false end
            return handler(abilityId, unitId, target)
        end
        _G.SCO_CommanderAbilityClientRequest = SCOAbilityRequestDispatcher
    end

    local function SCOConfirmTargetInput(target)
        local active = SCOActiveTargetInput
        local canonicalTarget
        if active and active.abilityId == "Overcharge" then
            canonicalTarget = SCOGlobalId(target)
        else
            canonicalTarget = SCOPosition(target)
        end
        if active == nil or canonicalTarget == nil then return false end
        SCOCancelStrategicTargetInput("commander-submit")
        local unit = SCOResolveOwnedCommander(active.unitId)
        if unit == nil or not SCOCanTargetAbility(unit, active.abilityId) then
            SCOCancelTargetInput("state-changed")
            return false
        end
        local ok, accepted = pcall(
            SCOAbilityRequestDispatcher,
            active.abilityId,
            SCOGlobalId(active.unitId),
            canonicalTarget)
        if not ok or accepted ~= true then return false end
        SCOCancelTargetInput("submitted")
        return true
    end

    local function SCOInstallDispatcher(name, handlerName, handler)
        local dispatcher = rawget(_G, name)
        if dispatcher ~= nil and type(dispatcher) ~= "function" then
            error("SCOM commander ability dispatcher is occupied: " .. name)
        end
        if dispatcher == nil then
            dispatcher = function(...)
                local current = rawget(_G, handlerName)
                if type(current) ~= "function" then return false end
                return current(...)
            end
            rawset(_G, name, dispatcher)
        end
        rawset(_G, handlerName, handler)
    end

    SCOInstallDispatcher(
        "SCO_CommanderAbilityTargetInputBegin",
        "SCO_CommanderAbilityTargetInputBeginHandler",
        SCOBeginTargetInput)
    SCOInstallDispatcher(
        "SCO_CommanderAbilityTargetInputCancel",
        "SCO_CommanderAbilityTargetInputCancelHandler",
        SCOCancelTargetInput)
    SCOInstallDispatcher(
        "SCO_GetCommanderAbilityTargetInputState",
        "SCO_GetCommanderAbilityTargetInputStateHandler",
        SCOGetTargetInputState)

    local SCOStockMouseLeftDown = SCOInputEvents.OnMouseLeftDown
    local SCOStockMouseLeftUp = SCOInputEvents.OnMouseLeftUp
    local SCOStockMouseRightDown = SCOInputEvents.OnMouseRightDown
    local SCOStockMouseRightUp = SCOInputEvents.OnMouseRightUp

    SCOInputEvents.OnMouseLeftDown = function(...)
        if SCOActiveTargetInput == nil
            or not SCOMouseCursor.IsCursorInGameView()
            or Engine.IsMouseOverUI()
        then
            SCOPointerDown = false
            return SCOStockMouseLeftDown(...)
        end
        SCOCancelStrategicTargetInput("commander-left-down")
        SCOPointerDown = true
    end

    SCOInputEvents.OnMouseLeftUp = function(...)
        if SCOActiveTargetInput == nil
            or not SCOMouseCursor.IsCursorInGameView()
            or Engine.IsMouseOverUI()
        then
            SCOPointerDown = false
            return SCOStockMouseLeftUp(...)
        end
        local shouldConfirm = SCOPointerDown
        SCOPointerDown = false
        if shouldConfirm then
            if SCOActiveTargetInput.abilityId == "Overcharge" then
                -- Input batches can precede the normal hover refresh.
                local pointer = Engine.GetMousePositionInPixels()
                SCOMouseCursor.SetMousePositionX(pointer.x)
                SCOMouseCursor.SetMousePositionY(pointer.y)
                SCOMouseCursor.UpdateMouseRayCastPosition()
                local selection = Import("client/input/selectionSystem.lua")
                selection.UpdateSelectionSystem()
                local target = SCOInputEvents.GetHoverUnit()
                if target and target.entityType == "unit"
                    and not target.dead and target.id
                    and SCOMouseCursor.IsCursorInGameView()
                    and not Engine.IsMouseOverUI()
                then
                    SCOConfirmTargetInput(target.id)
                end
            else
                SCOConfirmTargetInput(SCOMouseCursor.GetMousePosition())
            end
        end
    end

    SCOInputEvents.OnMouseRightDown = function(...)
        if SCOActiveTargetInput == nil
            or not SCOMouseCursor.IsCursorInGameView()
            or Engine.IsMouseOverUI()
        then
            return SCOStockMouseRightDown(...)
        end
        SCOCancelStrategicTargetInput("commander-right-down")
        SCOPointerDown = false
    end

    SCOInputEvents.OnMouseRightUp = function(...)
        if SCOActiveTargetInput == nil
            or not SCOMouseCursor.IsCursorInGameView()
            or Engine.IsMouseOverUI()
        then
            return SCOStockMouseRightUp(...)
        end
        SCOCancelStrategicTargetInput("commander-right-click")
        SCOCancelTargetInput("right-click")
    end

    if functions.SCOCommanderAbilityVisualEvent ~= nil then
        error("SCOM commander ability visual-event listener is occupied")
    end
    functions.SCOCommanderAbilityVisualEvent = function(value)
        local dispatcher = rawget(_G, "SCO_CommanderAbilityVisualEvent")
        if type(dispatcher) ~= "function" then return false end
        return dispatcher(value)
    end

    rawset(
        SCOCommanderAbilityInputEnvironment,
        "SCO_CommanderAbilityTargetInputInstalled",
        "1.0.2")
end
-- SCOM Field Fixes 1.0.8 - source nuclear impacts and silo state.
local SCOFieldFixStrategicSiloClientEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOFieldFixStrategicSiloClientMarker = rawget(
    SCOFieldFixStrategicSiloClientEnvironment,
    "SCO_FieldFixStrategicSiloClientListenerInstalled")
if SCOFieldFixStrategicSiloClientMarker ~= nil
    and SCOFieldFixStrategicSiloClientMarker ~= "1.0.8"
then
    error("Unsupported SCOM strategic silo client-listener marker "
        .. tostring(SCOFieldFixStrategicSiloClientMarker))
end
if SCOFieldFixStrategicSiloClientMarker == nil then
    if type(functions) ~= "table"
        or type(__Entities) ~= "table"
        or type(__Entities.Units) ~= "table"
    then
        error("SCOM strategic silo client listener could not resolve listener table")
    end
    local SCOAudioManager = Import("client/audio/audioManager.lua")
    if type(SCOAudioManager) ~= "table"
        or type(SCOAudioManager.NotifyCombatActivity) ~= "function"
        or type(SCOAudioManager.PlayOneShot) ~= "function"
    then
        error("SCOM Apocalypse commander audio manager was unavailable")
    end
    if type(functions.NukeAtHome) ~= "function" then
        error("SCOM strategic nuke impact listener was unavailable")
    end
    local SCOStrategicNukeImpactPrefabID =
        _G.SCO_StrategicNukeImpactVFXPrefabID
    if SCOStrategicNukeImpactPrefabID == nil then
        error("SCOM strategic nuke impact prefab was not registered")
    end
    local SCOStockNukeAtHome = functions.NukeAtHome

    local SCOClientSiloMaxAmmo = {
        ues3102 = 5,
        ugs3102 = 5,
        ucs3102 = 5,
        uss3102 = 5,
        ucl4001 = 3,
    }
    local SCOPendingSiloStates = {}
    local SCORecentApocalypsePresentationTicks = {}
    local SCOApocalypsePresentationCellSize = 16
    local SCOApocalypsePresentationWindowTicks = 8

    local function SCOFinite(value)
        return type(value) == "number"
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
    end

    local function SCOInteger(value, minimum, maximum)
        return SCOFinite(value)
            and value == math.floor(value)
            and value >= minimum
            and value <= maximum
    end

    local function SCOShouldPresentApocalypseImpact(x, z)
        local tick = Engine.GetSimulationTick()
        if not SCOInteger(tick, 0, 2147483647) then
            return true
        end
        for key, previousTick in pairs(SCORecentApocalypsePresentationTicks) do
            if tick < previousTick
                or tick - previousTick > SCOApocalypsePresentationWindowTicks
            then
                SCORecentApocalypsePresentationTicks[key] = nil
            end
        end
        local cellX = math.floor(x / SCOApocalypsePresentationCellSize + 0.5)
        local cellZ = math.floor(z / SCOApocalypsePresentationCellSize + 0.5)
        local key = tostring(cellX) .. ":" .. tostring(cellZ)
        local previousTick = SCORecentApocalypsePresentationTicks[key]
        if previousTick ~= nil
            and tick >= previousTick
            and tick - previousTick <= SCOApocalypsePresentationWindowTicks
        then
            return false
        end
        SCORecentApocalypsePresentationTicks[key] = tick
        return true
    end

    local function SCOCanonicalState(data)
        if type(data) ~= "table"
            or type(data.unitId) ~= "table"
            or not SCOInteger(data.unitId.index, 1, 2147483647)
            or not SCOInteger(data.unitId.version, 0, 2147483647)
            or type(data.tpId) ~= "string"
        then
            return nil
        end
        local maxAmmo = SCOClientSiloMaxAmmo[data.tpId]
        if not maxAmmo
            or not SCOInteger(data.ammo, 0, maxAmmo)
            or data.maxAmmo ~= maxAmmo
            or not SCOInteger(data.queued, 0, maxAmmo)
            or not SCOFinite(data.work)
            or data.work < 0
            or data.work > 324000
            or data.buildTime ~= 324000
            or type(data.autoBuild) ~= "boolean"
            or type(data.building) ~= "boolean"
            or type(data.paused) ~= "boolean"
            or type(data.launchPending) ~= "boolean"
            or type(data.animationReady) ~= "boolean"
            or not SCOInteger(data.sequence, 1, 2147483647)
        then
            return nil
        end
        return {
            unitId = {
                index = data.unitId.index,
                version = data.unitId.version,
            },
            tpId = data.tpId,
            ammo = data.ammo,
            maxAmmo = maxAmmo,
            queued = data.queued,
            work = data.work,
            buildTime = data.buildTime,
            autoBuild = data.autoBuild,
            building = data.building,
            paused = data.paused,
            launchPending = data.launchPending,
            animationReady = data.animationReady,
            sequence = data.sequence,
        }
    end

    local function SCOUnitMatchesState(unit, state)
        return unit ~= nil
            and unit.id ~= nil
            and unit.id.index == state.unitId.index
            and unit.id.version == state.unitId.version
            and unit.tpId == state.tpId
            and unit.tp ~= nil
            and unit.tp.additions ~= nil
            and unit.tp.additions.scoStrategicSilo ~= nil
            and unit.tp.additions.scoStrategicSilo.version == "1.0.0"
    end

    local function SCOReceiveStrategicSiloState(data)
        local state = SCOCanonicalState(data)
        if not state then return end
        local unit = __Entities.Units[state.unitId.index]
        local unitMatches = SCOUnitMatchesState(unit, state)
        local liveState = unitMatches and unit.scoStrategicSiloState
        if type(liveState) == "table"
            and SCOInteger(liveState.sequence, 1, 2147483647)
            and liveState.sequence >= state.sequence
        then
            return
        end
        local statesByVersion = SCOPendingSiloStates[state.unitId.index]
        if not statesByVersion then
            statesByVersion = {}
            SCOPendingSiloStates[state.unitId.index] = statesByVersion
        end
        local current = statesByVersion[state.unitId.version]
        if current
            and current.sequence >= state.sequence
        then
            return
        end
        statesByVersion[state.unitId.version] = state
        if unitMatches then
            unit.scoStrategicSiloState = state
            if type(unit.SetUIDirtyIfSelected) == "function" then
                unit:SetUIDirtyIfSelected()
            end
        end
    end

    -- clientMain registers listener functions once. Keep that registered
    -- identity stable across OnFileChange while routing into the newest module
    -- environment and its matching state getter.
    local SCOStateDispatcher =
        _G.SCO_FieldFixStrategicSiloStateDispatcher
    if SCOStateDispatcher ~= nil
        and type(SCOStateDispatcher) ~= "function"
    then
        error("SCOM strategic silo state dispatcher is occupied by a non-function")
    end
    if SCOStateDispatcher == nil then
        SCOStateDispatcher = function(data)
            local handler = _G.SCO_FieldFixStrategicSiloStateHandler
            if type(handler) == "function" then
                return handler(data)
            end
        end
        _G.SCO_FieldFixStrategicSiloStateDispatcher = SCOStateDispatcher
    end
    _G.SCO_FieldFixStrategicSiloStateHandler =
        SCOReceiveStrategicSiloState
    functions.SCOStrategicSiloState = SCOStateDispatcher

    local function SCOReceiveApocalypseNukeImpact(data)
        -- Network float3 values are engine-backed userdata/cdata in the live
        -- client. Read them structurally and reject malformed payloads.
        local ok, x, y, z = pcall(function()
            local position = data.position
            return position.x, position.y, position.z
        end)
        if not ok
            or not SCOFinite(x)
            or not SCOFinite(y)
            or not SCOFinite(z)
        then
            return
        end
        local prefabId = _G.SCO_ApocalypseNukeVFXPrefabID
        if prefabId == nil then
            error("SCOM Apocalypse nuke VFX prefab was not loaded")
        end
        local audioPrefabId =
            _G.SCO_ApocalypseCommanderExplosionAudioPrefabID
        if audioPrefabId == nil then
            error("SCOM Apocalypse commander explosion audio was not loaded")
        end
        if not SCOShouldPresentApocalypseImpact(x, z) then
            return
        end
        local impactPosition = EngineClasses.float3(x, y, z)
        local impactRotation = GetIdentityQuaternion()
        local instantiatedId = {}
        Engine.InstantiatePrefab(
            prefabId,
            impactPosition,
            EngineClasses.float3(1, 1, 1),
            impactRotation,
            instantiatedId)
        SCOAudioManager.NotifyCombatActivity()
        SCOAudioManager.PlayOneShot(
            audioPrefabId,
            impactPosition,
            impactRotation)
    end

    local SCOImpactDispatcher =
        _G.SCO_FieldFixApocalypseNukeImpactDispatcher
    if SCOImpactDispatcher ~= nil
        and type(SCOImpactDispatcher) ~= "function"
    then
        error("SCOM Apocalypse nuke impact dispatcher is occupied by a non-function")
    end
    if SCOImpactDispatcher == nil then
        SCOImpactDispatcher = function(data)
            local handler = _G.SCO_FieldFixApocalypseNukeImpactHandler
            if type(handler) == "function" then
                return handler(data)
            end
        end
        _G.SCO_FieldFixApocalypseNukeImpactDispatcher = SCOImpactDispatcher
    end
    _G.SCO_FieldFixApocalypseNukeImpactHandler =
        SCOReceiveApocalypseNukeImpact
    functions.SCOApocalypseNukeAtHome = SCOImpactDispatcher

    local function SCOReceiveNukeAtHome(data)
        if type(data) ~= "table" or data.scoStrategicNuke ~= true then
            return SCOStockNukeAtHome(data)
        end
        local ok, x, y, z = pcall(function()
            local position = data.position
            return position.x, position.y, position.z
        end)
        if not ok
            or not SCOFinite(x)
            or not SCOFinite(y)
            or not SCOFinite(z)
        then
            return
        end
        local instantiatedId = {}
        Engine.InstantiatePrefab(
            SCOStrategicNukeImpactPrefabID,
            EngineClasses.float3(x, y, z),
            EngineClasses.float3(1, 1, 1),
            GetIdentityQuaternion(),
            instantiatedId)
    end

    -- clientMain registers listeners once, so keep the event identity stable
    -- while refreshing its implementation when clientListeners is reimported.
    local SCONukeAtHomeDispatcher =
        _G.SCO_FieldFixStrategicNukeAtHomeDispatcher
    if SCONukeAtHomeDispatcher ~= nil
        and type(SCONukeAtHomeDispatcher) ~= "function"
    then
        error("SCOM strategic nuke impact dispatcher is occupied")
    end
    if SCONukeAtHomeDispatcher == nil then
        SCONukeAtHomeDispatcher = function(data)
            local handler = _G.SCO_FieldFixStrategicNukeAtHomeHandler
            if type(handler) == "function" then
                return handler(data)
            end
        end
        _G.SCO_FieldFixStrategicNukeAtHomeDispatcher =
            SCONukeAtHomeDispatcher
    end
    _G.SCO_FieldFixStrategicNukeAtHomeHandler = SCOReceiveNukeAtHome
    functions.NukeAtHome = SCONukeAtHomeDispatcher

    function _G.SCO_GetStrategicSiloClientState(unit)
        if not unit or not unit.id then return nil end
        local statesByVersion = SCOPendingSiloStates[unit.id.index]
        local pending = statesByVersion and statesByVersion[unit.id.version]
        if pending and SCOUnitMatchesState(unit, pending) then
            local current = unit.scoStrategicSiloState
            if not current or pending.sequence > current.sequence then
                unit.scoStrategicSiloState = pending
            end
        end
        return unit.scoStrategicSiloState
    end

    rawset(
        SCOFieldFixStrategicSiloClientEnvironment,
        "SCO_FieldFixStrategicSiloClientListenerInstalled",
        "1.0.8")
    _G.SCO_FieldFixStrategicSiloClientListenerInstalled = "1.0.8"
end
-- SCOM tactical missiles 1.0.0. Append after strategic client listener.
do
    if _G.SCO_TacticalClientInstalled and _G.SCO_TacticalClientInstalled ~= "1.0.0" then
        error("Unsupported tactical client version")
    end
    if not _G.SCO_TacticalClientInstalled then
        local maxima={ues2102=12,ucs2102=16,ugs2102=10,uss2102=20,ues3102=5,ugs5007=5,ues5023=7,ugs5015=7,ucs3402=7,uss3402=7,uen3004=3,ugn3004=3,usn3001=5,uss4102=1}
        local buildTimes={ues3102=324000,ugs5007=324000,ues5023=259200,ugs5015=259200,ucs3402=259200,uss3402=259200,uen3004=324000,ugn3004=324000,usn3001=518400,uss4102=129600}
        local pending={}
        local function integer(value,min,max)
            return type(value)=="number" and value==math.floor(value) and value>=min and value<=max
        end
        local function matches(unit,state)
            local c=unit and unit.tp and unit.tp.additions and unit.tp.additions.scoTactical
            return c and c.version=="1.0.0" and c.role=="launcher" and unit.tpId==state.tpId
                and unit.id.index==state.unitId.index and unit.id.version==state.unitId.version
        end
        functions.SCOTacticalSiloState=function(value)
            if type(value)~="table" or type(value.unitId)~="table"
                or not integer(value.unitId.index,1,2147483647)
                or not integer(value.unitId.version,0,2147483647) then return end
            local max=maxima[value.tpId]
            local buildTime=buildTimes[value.tpId] or 2400
            if not max or value.maxAmmo~=max or value.buildTime~=buildTime
                or not integer(value.ammo,0,max) or not integer(value.queued,0,max)
                or type(value.work)~="number" or value.work~=value.work or value.work<0 or value.work>buildTime
                or not integer(value.sequence,1,2147483647) then return end
            for _,key in ipairs({"autoBuild","building","paused","launchPending","animationReady"}) do
                if type(value[key])~="boolean" then return end
            end
            local previous=pending[value.unitId.index]
            if previous and previous.unitId.version==value.unitId.version and previous.sequence>=value.sequence then return end
            local state={unitId={index=value.unitId.index,version=value.unitId.version}}
            for _,key in ipairs({"tpId","ammo","maxAmmo","queued","work","buildTime","autoBuild","building","paused","launchPending","animationReady","sequence"}) do state[key]=value[key] end
            pending[state.unitId.index]=state
            local unit=__Entities.Units[state.unitId.index]
            if matches(unit,state) then unit.scoTacticalSiloState=state end
        end
        local oldGet=_G.SCO_GetStrategicSiloClientState
        function _G.SCO_GetStrategicSiloClientState(unit)
            local state=unit and unit.id and pending[unit.id.index]
            if state and matches(unit,state) then return state end
            if oldGet then return oldGet(unit) end
        end
        functions.SCOTacticalBeam=function(value)
            if type(value)~="table" or type(value.unitId)~="table" or type(value.muzzleId)~="table"
                or type(value.targetPosition)~="table" or not integer(value.sequence,1,2147483647) then return end
            local unit=__Entities.Units[value.unitId.index]
            local muzzle=__Muzzles and __Muzzles[value.muzzleId.index]
            local beamUnits={ugs2402=true,ugn2002=true,ugn3001=true,ugn3003=true}
            if not unit or not beamUnits[unit.tpId] or unit.id.version~=value.unitId.version
                or not muzzle or not muzzle.globalId or muzzle.globalId.version~=value.muzzleId.version
                or not muzzle.weapon or muzzle.weapon.unit~=unit or not muzzle.weapon.tp.scoTacticalBeam
                or not muzzle.beam or value.sequence<=(muzzle.scoTacticalBeamSequence or 0) then return end
            for _,axis in ipairs({"x","y","z"}) do
                local coordinate=value.targetPosition[axis]
                if type(coordinate)~="number" or coordinate~=coordinate or math.abs(coordinate)>1000000 then return end
            end
            muzzle.scoTacticalBeamSequence=value.sequence
            local target=value.targetPosition
            local beam=muzzle.beam
            beam.Raycast=function(self)
                local _,origin=Engine.GetLocalEntityWorldPosition(muzzle.localId)
                if not origin then return end
                local dx,dy,dz=target.x-origin.x,target.y-origin.y,target.z-origin.z
                self.length=math.sqrt(dx*dx+dy*dy+dz*dz)
                self.hasImpact=false
                self.lastForward=EngineClasses.float3(dx,dy,dz)
            end
            -- Native pulse lifetime is one tick. Arm immediately so the standard
            -- one-tick enable gate cannot suppress the entire source pulse.
            beam.pendingEnable=false
            beam:Raycast()
        end
        functions.SCOSourceNukePhase=function(value)
            assert(_G.SCO_SetSourceNukePhase,'Source nuclear client owner missing')(value)
        end
        functions.SCOYolonaMissilePose=function(value)
            assert(_G.SCO_ApplyYolonaMissilePose,'Yolona missile client owner missing')(value)
        end
        _G.SCO_TacticalClientInstalled="1.0.0"
    end
end
-- SCOM factory rally visibility client state 1.0.0
function functions.FactoryRallyPoint(data)
    if type(data) ~= "table" then
        return
    end
    local index, version = data.unitIndex, data.unitVersion
    if type(index) ~= "number" or type(version) ~= "number"
        or index < 0 or version < 0 or index ~= math.floor(index) or version ~= math.floor(version) then
        return
    end
    local unit = __Entities.Units[index]
    if unit == nil or unit.id.index ~= index or unit.id.version ~= version or not unit:HasTags(Tags.FACTORY) then
        return
    end

    local point = nil
    if data.hasExplicit == true then
        local x, y, z = data.x, data.y, data.z
        if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number"
            or x ~= x or y ~= y or z ~= z then
            return
        end
        point = EngineClasses.float3(x, y, z)
    end
    unit.scoFactoryRallyState = {
        isSlave = data.isSlave == true,
        point = point,
        hasExplicit = data.hasExplicit == true,
        fatboyMovementLocked = data.fatboyMovementLocked == true,
    }
end
