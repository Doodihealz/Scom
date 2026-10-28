-- Host-to-client prop creation and the capture/reclaim progress shown on units and props.

local Registry = Import("common/commands/registry.lua")
local Layouts  = Import("common/commands/layouts.lua")

local Props = __Entities.Props

--== Layouts ===================================================================

-- Named propID for historical reasons; capture and reclaim progress are reported for units too.
local propProgressLayout = {
    { key = "propID",   type = Layouts.GlobalID },
    { key = "progress", type = "float" },
}

--== Creation ==================================================================

---@class CreateProp : Command
CreateProp = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "propGlobalID",       type = Layouts.GlobalID },
    { key = "sourceUnitGlobalID", type = Layouts.GlobalID },
})

---@param sourceUnitGlobalID GlobalID The unit the prop came from, for tarmac placement.
---@param propGlobalID GlobalID
function CreateProp.Send(sourceUnitGlobalID, propGlobalID)
    return { propGlobalID = propGlobalID, sourceUnitGlobalID = sourceUnitGlobalID }
end

-- SCOM brief dry-ground wreck smoke 1.0.0. The lease includes the particle tail,
-- even when reclaim/deletion stops its emitter early; no wreck scanning is needed.
local wreckSmokeCount = 0
local wreckSmokePrefab
local wreckSmokePath = "VFX/SCOM/WreckSmoke/brief.sanvfx"

local function CreateWreckSmoke(prop, sourceID)
    local source = sourceID and __Entities.Units[sourceID.index]
    if not source or source.id.version ~= sourceID.version or source.deleted
        or not prop.tp or not prop.tp.general.unitTpId
        or not source.tp.hasTags or not source.tp.hasTags.SCFA_ALLUNITS
        or not source:IsIntelVisionVisible() or prop.scoWreckSmokeAttempted then return end
    prop.scoWreckSmokeAttempted = true
    if wreckSmokeCount >= 4 or math.random(1, 10) ~= 1 then return end

    local positionResult, position = Engine.GetGlobalEntityWorldPosition(prop.id)
    if positionResult ~= EngineErrorCode.Success then return end
    local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)
    if terrainResult ~= EngineErrorCode.Success or math.abs(position.y - terrainHeight) > 1 then return end
    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success then return end
    if hasWater then
        local levelResult, waterLevel = Engine.GetWaterLevel()
        if levelResult ~= EngineErrorCode.Success or terrainHeight <= waterLevel then return end
    end

    if wreckSmokePrefab == nil then
        wreckSmokePrefab = false
        if Engine.LoadEffect(wreckSmokePath) then
            wreckSmokePrefab = Import("common/loading/vfxTemplateLoader.lua")
                .GetOrCreateVFXPrefab(wreckSmokePath) or false
        else
            Warn("[SCOM Wreck Smoke] Could not load " .. wreckSmokePath)
        end
    end
    if not wreckSmokePrefab then return end

    local record = {}
    function record:Delete()
        self.deleted = true
        local localID = self.localID
        self.localID = nil
        if localID and Engine.IsValidLocalID(localID) then
            Engine.DeletePrefabInstance(localID)
        end
        prop.scoWreckSmoke = nil
    end
    prop.scoWreckSmoke = record
    prop.garbage:Add(record)
    wreckSmokeCount = wreckSmokeCount + 1
    local focus = focusArmyID

    -- Independent finite lease: prop garbage deletes the emitter, but must not
    -- cancel the release timer while already-emitted particles are fading.
    NewThread(function()
        WaitTickEnd()
        if record.deleted or prop.deleted or focusArmyID ~= focus then
            record:Delete()
            wreckSmokeCount = wreckSmokeCount - 1
            return
        end
        local localID = {}
        local result = Engine.InstantiatePrefab(wreckSmokePrefab, position,
            EngineClasses.float3(1, 1, 1), GetIdentityQuaternion(), localID)
        record.localID = localID
        if result ~= EngineErrorCode.Success then
            record:Delete()
            wreckSmokeCount = wreckSmokeCount - 1
            return
        end
        -- Native one-shot prefabs suppress rate-over-time subparticle emission.
        -- Keep this emitter owned until the finite lease deletes it instead.
        Engine.SetDestroyUponCompletion(localID, false)
        for step = 1, 24 do
            WaitSeconds(0.25)
            if focusArmyID ~= focus then record:Delete() end
            if record.deleted then
                WaitSeconds((24 - step) * 0.25)
                break
            end
            if step == 12 then Engine.SetParticleCanEmit(localID, false) end
        end
        record:Delete()
        wreckSmokeCount = wreckSmokeCount - 1
    end)
end

function CreateProp.Receive(data)
    local _, propLocalID = Engine.GetGlobalEntityPairedLocalID(data.propGlobalID)
    local _, prefabID = Engine.GetGlobalEntityPrefabID(data.propGlobalID)

    local tpId = GetTemplateId(prefabID)
    local prop = GetClass(tpId, "Props")(data.propGlobalID, propLocalID)

    Props[prop.id.index] = prop

    local template = GetTemplate(tpId, "Props")
    if template and prop.ApplyTemplate then
        prop:ApplyTemplate(template)
    end

    if data.sourceUnitGlobalID and prop.ClientCreateTarmacFromSourceUnit then
        prop:ClientCreateTarmacFromSourceUnit(data.propGlobalID, data.sourceUnitGlobalID)
        CreateWreckSmoke(prop, data.sourceUnitGlobalID)
    end
end

--== Progress ==================================================================

---@class SetCaptureProgress : Command
SetCaptureProgress = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, propProgressLayout)

---@param propID GlobalID
---@param captureProgress number
function SetCaptureProgress.Send(propID, captureProgress)
    return { propID = propID, progress = captureProgress }
end

function SetCaptureProgress.Receive(data)
    GetUnitById(data.propID).captureProgress = data.progress
end

---@class SetReclaimProgress : Command
SetReclaimProgress = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, propProgressLayout)

---@param propID GlobalID
---@param reclaimProgress number
function SetReclaimProgress.Send(propID, reclaimProgress)
    return { propID = propID, progress = reclaimProgress }
end

function SetReclaimProgress.Receive(data)
    GetUnitOrPropByGlobalId(data.propID).reclaimProgress = data.progress
end

-- SCOM naval wreck presentation 1.1.0
SCO_NavalWreckPhase = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "propID", type = Layouts.GlobalID },
    { key = "settled", type = "bool" },
    { key = "sourceUnitID", type = Layouts.GlobalID },
})

function SCO_NavalWreckPhase.Send(propID, settled, sourceUnitID)
    return {
        propID = propID,
        settled = settled,
        sourceUnitID = sourceUnitID or propID,
    }
end

-- The collider continues to own reclaim interaction after settlement. Only
-- this wreck's decorative renderer is permanently retired.
local function SCO_NavalWreckSetSelectionBracketEnabled(prop)
    if prop.selectionBracketID then
        Engine.SetRendererEnabled(prop.selectionBracketID, false)
    end
end

function SCO_NavalWreckPhase.Receive(data)
    local prop = Props[data.propID.index]
    if not prop or prop.deleted then return end
    prop.SetSelectionBracketEnabled = SCO_NavalWreckSetSelectionBracketEnabled
    prop:SetSelectionBracketEnabled(false)

    -- Only the initial SCOM naval-sinking phase carries a distinct source unit.
    -- Copy while that renderer is still paired; the later unit deletion must not
    -- reset the wreck to its template's neutral color.
    local sourceID = data.sourceUnitID
    local hasDistinctSource = not data.settled and sourceID
        and (sourceID.index ~= data.propID.index
            or sourceID.version ~= data.propID.version)
    if hasDistinctSource then
        local sourceResult, sourceLocalID =
            Engine.GetGlobalEntityPairedLocalID(sourceID)
        if sourceResult == EngineErrorCode.Success then
            local colorResult, teamColor =
                Engine.GetRendererInstanceData0(sourceLocalID)
            if colorResult == EngineErrorCode.Success and teamColor then
                Engine.SetRendererInstanceData0(prop.localId, teamColor)
            end
        end
    end

    local _, instanceData = Engine.GetRendererInstanceData1(prop.localId)
    instanceData.y = data.settled and 1 or 0
    Engine.SetRendererInstanceData1(prop.localId, instanceData)

    prop.isSelectable = data.settled
    -- Prop selection is on the root, unlike the unit's Selection Collider bone.
    Engine.SetVolumeColliderEnabled(prop.localId, data.settled)
end
