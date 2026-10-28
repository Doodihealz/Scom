-- Host-to-client resource spot lifecycle.

local Registry = Import("common/commands/registry.lua")
local Layouts  = Import("common/commands/layouts.lua")

local ResourceSpotsUpdate = nil
if IsClient then
    ResourceSpotsUpdate = Import("client/resourceSpots/resourceSpotsUpdate.lua")
end

---@class CreateResourceSpot : Command
CreateResourceSpot = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "resourceSpotGlobalID", type = Layouts.GlobalID },
    { key = "resourceType",         type = "string" },
})

---@param resourceSpotGlobalID GlobalID
---@param resourceType string
function CreateResourceSpot.Send(resourceSpotGlobalID, resourceType)
    return { resourceSpotGlobalID = resourceSpotGlobalID, resourceType = resourceType }
end

function CreateResourceSpot.Receive(data)
    local resourceSpotLocalID = {}
    Engine.GetGlobalEntityPairedLocalID(data.resourceSpotGlobalID, resourceSpotLocalID)

    ResourceSpotsUpdate.RegisterResourceSpot(data.resourceSpotGlobalID, resourceSpotLocalID, data.resourceType)
end

---@class SetResourceSpotEnabled : Command
SetResourceSpotEnabled = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "resourceSpotGlobalID", type = Layouts.GlobalID },
    { key = "enabled",              type = "bool" },
})

---@param resourceSpotGlobalID GlobalID
---@param enabled boolean
function SetResourceSpotEnabled.Send(resourceSpotGlobalID, enabled)
    return { resourceSpotGlobalID = resourceSpotGlobalID, enabled = enabled }
end

function SetResourceSpotEnabled.Receive(data)
    ResourceSpotsUpdate.SetResourceSpotEnabled(data.resourceSpotGlobalID, data.enabled)
end

---@class DeleteResourceSpot : Command
DeleteResourceSpot = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {
    { key = "resourceSpotGlobalID", type = Layouts.GlobalID },
})

---@param resourceSpotGlobalID GlobalID
function DeleteResourceSpot.Send(resourceSpotGlobalID)
    return { resourceSpotGlobalID = resourceSpotGlobalID }
end

function DeleteResourceSpot.Receive(data)
    ResourceSpotsUpdate.DeleteResourceSpot(data.resourceSpotGlobalID)
end


-- Supreme Commander Overhaul Aeon resource-marker pairing 1.2.3
local scoAeonPendingResourceSpotPairings = {}
local scoAeonResourceSpotPairingThread = nil
local scoAeonFallbackResourceSpotPrefabId = nil
local scoAeonSuppressedMalformedResourceSpots = {}

-- Importing this module performs no prefab creation.  The wrapper records the
-- normal client ResourceSpot prefab when map setup creates it, so the fallback
-- never allocates a divergent client-only prefab at command-receive time.
local scoAeonResourceSpotLoader =
    Import("common/loading/resourceSpotTemplateLoader.lua")
local scoAeonCreateResourceSpotPrefab =
    scoAeonResourceSpotLoader.CreateResourceSpotPrefab
local scoAeonResourceSpotUtils =
    Import("common/resourceSpot.lua")
function scoAeonResourceSpotLoader.CreateResourceSpotPrefab(resType)
    local prefabId = scoAeonCreateResourceSpotPrefab(resType)
    if IsClient and resType == "alloys" then
        scoAeonFallbackResourceSpotPrefabId = prefabId
    end
    return prefabId
end

local function scoAeonResourceSpotKey(globalId)
    return tostring(globalId.index) .. ":" .. tostring(globalId.version)
end

local function scoAeonHasRegisteredResourceSpot(globalId)
    local existing = scoAeonResourceSpotUtils.resourceSpots[globalId.index]
    return existing
        and existing.id
        and existing.id.index == globalId.index
        and existing.id.version == globalId.version
end

local function scoAeonGetPairedLocalId(globalId)
    local localId = {}
    local pairError = Engine.GetGlobalEntityPairedLocalID(globalId, localId)
    if pairError ~= EngineErrorCode.Success
        or not Engine.IsValidLocalID(localId)
    then
        return nil
    end
    return localId
end

local function scoAeonIsBidirectionalPairing(globalId, localId)
    local reverseGlobalId = {}
    local reverseError = Engine.GetLocalEntityGlobalID(localId, reverseGlobalId)
    return reverseError == EngineErrorCode.Success
        and reverseGlobalId.index == globalId.index
        and reverseGlobalId.version == globalId.version
end

local function scoAeonHasResourceSpotVisuals(localId)
    local planeId = {}
    local planeError = Engine.GetLocalBone(localId, "Plane", planeId)
    if planeError ~= EngineErrorCode.Success
        or not Engine.IsValidLocalID(planeId)
    then
        return false
    end

    local billboardId = {}
    local billboardError = Engine.GetLocalBone(localId, "Billboard", billboardId)
    return billboardError == EngineErrorCode.Success
        and Engine.IsValidLocalID(billboardId)
end

local function scoAeonTryRegisterResourceSpot(globalId)
    if scoAeonHasRegisteredResourceSpot(globalId) then
        return true, false
    end

    -- The forward pairing can briefly resolve to another valid client entity
    -- during map initialization. Require the candidate to map back to this
    -- exact global entity before the ResourceSpot visual signature is checked.
    local localId = scoAeonGetPairedLocalId(globalId)
    if not localId
    then
        return false, false
    end
    if not scoAeonIsBidirectionalPairing(globalId, localId) then
        return false, false
    end
    if not scoAeonHasResourceSpotVisuals(localId) then
        -- The authoritative resource global already has an exact local root,
        -- but that root is visibly malformed (for example, a tank). This is
        -- safe to rebuild immediately; incomplete or mismatched pairings
        -- retain the bounded retry below.
        return false, true
    end

    ResourceSpotsUpdate.RegisterResourceSpot(globalId, localId, "alloys")
    return scoAeonHasRegisteredResourceSpot(globalId), false
end

local function scoAeonSuppressMalformedResourceSpotPresentation(globalId)
    local localId = scoAeonGetPairedLocalId(globalId)
    if not localId
        or not scoAeonIsBidirectionalPairing(globalId, localId)
        or scoAeonHasResourceSpotVisuals(localId)
    then
        return false
    end

    local key = scoAeonResourceSpotKey(globalId)
    if scoAeonSuppressedMalformedResourceSpots[key] then
        return false
    end

    scoAeonSuppressedMalformedResourceSpots[key] = true
    -- The command is authoritative and this root maps back to that exact
    -- resource global, so do not delete or move it. The four master toggles
    -- suppress only its malformed client presentation.
    Engine.SetRendererEnabled(localId, false)
    Engine.SetIconsEnabled(localId, false)
    Engine.SetRangeRingsEnabled(localId, false)
    Engine.SetProgressBarsEnabled(localId, false)
    return true
end

local function scoAeonTryRegisterFallbackResourceSpot(
    globalId,
    requireMalformedPair)
    if scoAeonHasRegisteredResourceSpot(globalId) then
        return false, false, false
    end
    if not scoAeonFallbackResourceSpotPrefabId then
        return false, false, false
    end
    if requireMalformedPair then
        local pairedLocalId = scoAeonGetPairedLocalId(globalId)
        if not pairedLocalId
            or not scoAeonIsBidirectionalPairing(globalId, pairedLocalId)
            or scoAeonHasResourceSpotVisuals(pairedLocalId)
        then
            return false, false, false
        end
    end

    local position = {}
    local positionError =
        Engine.GetGlobalEntityWorldPosition(globalId, position)
    if positionError ~= EngineErrorCode.Success then
        return false, false, false
    end

    local instantiateError, localId = Engine.InstantiatePrefab(
        scoAeonFallbackResourceSpotPrefabId,
        position,
        EngineClasses.float3(2, 2, 2),
        GetIdentityQuaternion())
    if instantiateError ~= EngineErrorCode.Success
        or not Engine.IsValidLocalID(localId)
        or not scoAeonHasResourceSpotVisuals(localId)
    then
        if Engine.IsValidLocalID(localId) then
            Engine.DeletePrefabInstance(localId)
        end
        return false, false, true
    end

    ResourceSpotsUpdate.RegisterResourceSpot(globalId, localId, "alloys")
    if not scoAeonHasRegisteredResourceSpot(globalId) then
        Engine.DeletePrefabInstance(localId)
        return false, false, true
    end

    return true, scoAeonSuppressMalformedResourceSpotPresentation(globalId), true
end

local function scoAeonTryResolvePendingResourceSpot(entry)
    local registered, malformedPairedPresentation =
        scoAeonTryRegisterResourceSpot(entry)
    if registered then
        return true, false, false
    end
    if not malformedPairedPresentation or entry.fallbackAttempted then
        return false, false, false
    end

    -- No Lua yield occurs between these checks and InstantiatePrefab. Recheck
    -- the exact malformed pair before creating a local-only replacement, then
    -- remember only an actual instantiate attempt so unavailable prerequisites
    -- can still recover on a later retry tick.
    local rebuilt, suppressedPresentation, attempted =
        scoAeonTryRegisterFallbackResourceSpot(entry, true)
    if attempted then
        entry.fallbackAttempted = true
    end
    return rebuilt, rebuilt, suppressedPresentation
end

local function scoAeonCountPendingResourceSpots()
    local count = 0
    for _ in pairs(scoAeonPendingResourceSpotPairings) do
        count = count + 1
    end
    return count
end

local function scoAeonLogFallbackRecovery(
    fallbackRecovered,
    malformedPresentationsSuppressed)
    if fallbackRecovered > 0 then
        Log(
            "[Aeon Resource Markers] Rebuilt "
            .. tostring(fallbackRecovered)
            .. " client resource spots and suppressed "
            .. tostring(malformedPresentationsSuppressed)
            .. " malformed paired presentations.")
    end
end

local function scoAeonResolvePendingResourceSpots()
    local recovered = 0
    local fallbackRecovered = 0
    local malformedPresentationsSuppressed = 0
    for _ = 1, 120 do
        local unresolved = false
        for key, globalId in pairs(scoAeonPendingResourceSpotPairings) do
            local registered, rebuilt, suppressedPresentation =
                scoAeonTryResolvePendingResourceSpot(globalId)
            if registered then
                scoAeonPendingResourceSpotPairings[key] = nil
                if rebuilt then
                    fallbackRecovered = fallbackRecovered + 1
                    if suppressedPresentation then
                        malformedPresentationsSuppressed =
                            malformedPresentationsSuppressed + 1
                    end
                else
                    recovered = recovered + 1
                end
            else
                unresolved = true
            end
        end

        if not unresolved then
            scoAeonResourceSpotPairingThread = nil
            if recovered > 0 then
                Log(
                    "[Aeon Resource Markers] Recovered "
                    .. tostring(recovered)
                    .. " delayed client resource-spot pairings.")
            end
            scoAeonLogFallbackRecovery(
                fallbackRecovered,
                malformedPresentationsSuppressed)
            return
        end
        WaitTicks(1)
    end

    for key, globalId in pairs(scoAeonPendingResourceSpotPairings) do
        local registered = scoAeonTryRegisterResourceSpot(globalId)
        if registered then
            scoAeonPendingResourceSpotPairings[key] = nil
            recovered = recovered + 1
        elseif not globalId.fallbackAttempted then
            local recoveredFallback, suppressedPresentation, attempted =
                scoAeonTryRegisterFallbackResourceSpot(globalId, false)
            if attempted then
                globalId.fallbackAttempted = true
            end
            if recoveredFallback then
                scoAeonPendingResourceSpotPairings[key] = nil
                fallbackRecovered = fallbackRecovered + 1
                if suppressedPresentation then
                    malformedPresentationsSuppressed =
                        malformedPresentationsSuppressed + 1
                end
            end
        end
    end

    local unresolvedCount = scoAeonCountPendingResourceSpots()
    for key in pairs(scoAeonPendingResourceSpotPairings) do
        scoAeonPendingResourceSpotPairings[key] = nil
    end
    scoAeonResourceSpotPairingThread = nil

    if recovered > 0 then
        Log(
            "[Aeon Resource Markers] Recovered "
            .. tostring(recovered)
            .. " delayed client resource-spot pairings.")
    end
    scoAeonLogFallbackRecovery(
        fallbackRecovered,
        malformedPresentationsSuppressed)
    if unresolvedCount > 0 then
        Engine.Error(
            "[Aeon Resource Markers] Timed out waiting for "
            .. tostring(unresolvedCount)
            .. " client resource-spot pairings; the cached fallback could not be created.")
    end
end

local function scoAeonReceiveCreateResourceSpotCommand(data)
    local globalId = data.resourceSpotGlobalID
    local key = scoAeonResourceSpotKey(globalId)
    local pending = scoAeonPendingResourceSpotPairings[key]
    if not pending then
        pending = {
            index = globalId.index,
            version = globalId.version,
            fallbackAttempted = false,
        }
        scoAeonPendingResourceSpotPairings[key] = pending
    end

    local registered = scoAeonTryResolvePendingResourceSpot(pending)
    if registered then
        scoAeonPendingResourceSpotPairings[key] = nil
        return
    end

    if not scoAeonResourceSpotPairingThread then
        -- The true sentinel also handles a scheduler that starts the thread
        -- before NewThread returns.
        scoAeonResourceSpotPairingThread = true
        local thread = NewThread(scoAeonResolvePendingResourceSpots)
        if scoAeonResourceSpotPairingThread then
            scoAeonResourceSpotPairingThread = thread
        end
    end
end

CreateResourceSpot.Receive = scoAeonReceiveCreateResourceSpotCommand