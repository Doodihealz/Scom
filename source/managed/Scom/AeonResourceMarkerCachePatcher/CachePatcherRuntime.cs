using System;
using System.Collections;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace AeonResourceMarkerCachePatcher;

public static class CachePatcherRuntime
{
	internal const string OverrideMarker = "-- Supreme Commander Overhaul Aeon resource-marker pairing 1.2.3";

	internal const string TargetRelativePath = "LJ/lua/common/commands/definitions/resourceSpots.lua";

	private const string TargetPathSuffix = "/LJ/lua/common/commands/definitions/resourceSpots.lua";

	internal const string CommandsOverride = "\n\n-- Supreme Commander Overhaul Aeon resource-marker pairing 1.2.3\nlocal scoAeonPendingResourceSpotPairings = {}\nlocal scoAeonResourceSpotPairingThread = nil\nlocal scoAeonFallbackResourceSpotPrefabId = nil\nlocal scoAeonSuppressedMalformedResourceSpots = {}\n\n-- Importing this module performs no prefab creation.  The wrapper records the\n-- normal client ResourceSpot prefab when map setup creates it, so the fallback\n-- never allocates a divergent client-only prefab at command-receive time.\nlocal scoAeonResourceSpotLoader =\n    Import(\"common/loading/resourceSpotTemplateLoader.lua\")\nlocal scoAeonCreateResourceSpotPrefab =\n    scoAeonResourceSpotLoader.CreateResourceSpotPrefab\nlocal scoAeonResourceSpotUtils =\n    Import(\"common/resourceSpot.lua\")\nfunction scoAeonResourceSpotLoader.CreateResourceSpotPrefab(resType)\n    local prefabId = scoAeonCreateResourceSpotPrefab(resType)\n    if IsClient and resType == \"alloys\" then\n        scoAeonFallbackResourceSpotPrefabId = prefabId\n    end\n    return prefabId\nend\n\nlocal function scoAeonResourceSpotKey(globalId)\n    return tostring(globalId.index) .. \":\" .. tostring(globalId.version)\nend\n\nlocal function scoAeonHasRegisteredResourceSpot(globalId)\n    local existing = scoAeonResourceSpotUtils.resourceSpots[globalId.index]\n    return existing\n        and existing.id\n        and existing.id.index == globalId.index\n        and existing.id.version == globalId.version\nend\n\nlocal function scoAeonGetPairedLocalId(globalId)\n    local localId = {}\n    local pairError = Engine.GetGlobalEntityPairedLocalID(globalId, localId)\n    if pairError ~= EngineErrorCode.Success\n        or not Engine.IsValidLocalID(localId)\n    then\n        return nil\n    end\n    return localId\nend\n\nlocal function scoAeonIsBidirectionalPairing(globalId, localId)\n    local reverseGlobalId = {}\n    local reverseError = Engine.GetLocalEntityGlobalID(localId, reverseGlobalId)\n    return reverseError == EngineErrorCode.Success\n        and reverseGlobalId.index == globalId.index\n        and reverseGlobalId.version == globalId.version\nend\n\nlocal function scoAeonHasResourceSpotVisuals(localId)\n    local planeId = {}\n    local planeError = Engine.GetLocalBone(localId, \"Plane\", planeId)\n    if planeError ~= EngineErrorCode.Success\n        or not Engine.IsValidLocalID(planeId)\n    then\n        return false\n    end\n\n    local billboardId = {}\n    local billboardError = Engine.GetLocalBone(localId, \"Billboard\", billboardId)\n    return billboardError == EngineErrorCode.Success\n        and Engine.IsValidLocalID(billboardId)\nend\n\nlocal function scoAeonTryRegisterResourceSpot(globalId)\n    if scoAeonHasRegisteredResourceSpot(globalId) then\n        return true, false\n    end\n\n    -- The forward pairing can briefly resolve to another valid client entity\n    -- during map initialization. Require the candidate to map back to this\n    -- exact global entity before the ResourceSpot visual signature is checked.\n    local localId = scoAeonGetPairedLocalId(globalId)\n    if not localId\n    then\n        return false, false\n    end\n    if not scoAeonIsBidirectionalPairing(globalId, localId) then\n        return false, false\n    end\n    if not scoAeonHasResourceSpotVisuals(localId) then\n        -- The authoritative resource global already has an exact local root,\n        -- but that root is visibly malformed (for example, a tank). This is\n        -- safe to rebuild immediately; incomplete or mismatched pairings\n        -- retain the bounded retry below.\n        return false, true\n    end\n\n    ResourceSpotsUpdate.RegisterResourceSpot(globalId, localId, \"alloys\")\n    return scoAeonHasRegisteredResourceSpot(globalId), false\nend\n\nlocal function scoAeonSuppressMalformedResourceSpotPresentation(globalId)\n    local localId = scoAeonGetPairedLocalId(globalId)\n    if not localId\n        or not scoAeonIsBidirectionalPairing(globalId, localId)\n        or scoAeonHasResourceSpotVisuals(localId)\n    then\n        return false\n    end\n\n    local key = scoAeonResourceSpotKey(globalId)\n    if scoAeonSuppressedMalformedResourceSpots[key] then\n        return false\n    end\n\n    scoAeonSuppressedMalformedResourceSpots[key] = true\n    -- The command is authoritative and this root maps back to that exact\n    -- resource global, so do not delete or move it. The four master toggles\n    -- suppress only its malformed client presentation.\n    Engine.SetRendererEnabled(localId, false)\n    Engine.SetIconsEnabled(localId, false)\n    Engine.SetRangeRingsEnabled(localId, false)\n    Engine.SetProgressBarsEnabled(localId, false)\n    return true\nend\n\nlocal function scoAeonTryRegisterFallbackResourceSpot(\n    globalId,\n    requireMalformedPair)\n    if scoAeonHasRegisteredResourceSpot(globalId) then\n        return false, false, false\n    end\n    if not scoAeonFallbackResourceSpotPrefabId then\n        return false, false, false\n    end\n    if requireMalformedPair then\n        local pairedLocalId = scoAeonGetPairedLocalId(globalId)\n        if not pairedLocalId\n            or not scoAeonIsBidirectionalPairing(globalId, pairedLocalId)\n            or scoAeonHasResourceSpotVisuals(pairedLocalId)\n        then\n            return false, false, false\n        end\n    end\n\n    local position = {}\n    local positionError =\n        Engine.GetGlobalEntityWorldPosition(globalId, position)\n    if positionError ~= EngineErrorCode.Success then\n        return false, false, false\n    end\n\n    local instantiateError, localId = Engine.InstantiatePrefab(\n        scoAeonFallbackResourceSpotPrefabId,\n        position,\n        EngineClasses.float3(2, 2, 2),\n        GetIdentityQuaternion())\n    if instantiateError ~= EngineErrorCode.Success\n        or not Engine.IsValidLocalID(localId)\n        or not scoAeonHasResourceSpotVisuals(localId)\n    then\n        if Engine.IsValidLocalID(localId) then\n            Engine.DeletePrefabInstance(localId)\n        end\n        return false, false, true\n    end\n\n    ResourceSpotsUpdate.RegisterResourceSpot(globalId, localId, \"alloys\")\n    if not scoAeonHasRegisteredResourceSpot(globalId) then\n        Engine.DeletePrefabInstance(localId)\n        return false, false, true\n    end\n\n    return true, scoAeonSuppressMalformedResourceSpotPresentation(globalId), true\nend\n\nlocal function scoAeonTryResolvePendingResourceSpot(entry)\n    local registered, malformedPairedPresentation =\n        scoAeonTryRegisterResourceSpot(entry)\n    if registered then\n        return true, false, false\n    end\n    if not malformedPairedPresentation or entry.fallbackAttempted then\n        return false, false, false\n    end\n\n    -- No Lua yield occurs between these checks and InstantiatePrefab. Recheck\n    -- the exact malformed pair before creating a local-only replacement, then\n    -- remember only an actual instantiate attempt so unavailable prerequisites\n    -- can still recover on a later retry tick.\n    local rebuilt, suppressedPresentation, attempted =\n        scoAeonTryRegisterFallbackResourceSpot(entry, true)\n    if attempted then\n        entry.fallbackAttempted = true\n    end\n    return rebuilt, rebuilt, suppressedPresentation\nend\n\nlocal function scoAeonCountPendingResourceSpots()\n    local count = 0\n    for _ in pairs(scoAeonPendingResourceSpotPairings) do\n        count = count + 1\n    end\n    return count\nend\n\nlocal function scoAeonLogFallbackRecovery(\n    fallbackRecovered,\n    malformedPresentationsSuppressed)\n    if fallbackRecovered > 0 then\n        Log(\n            \"[Aeon Resource Markers] Rebuilt \"\n            .. tostring(fallbackRecovered)\n            .. \" client resource spots and suppressed \"\n            .. tostring(malformedPresentationsSuppressed)\n            .. \" malformed paired presentations.\")\n    end\nend\n\nlocal function scoAeonResolvePendingResourceSpots()\n    local recovered = 0\n    local fallbackRecovered = 0\n    local malformedPresentationsSuppressed = 0\n    for _ = 1, 120 do\n        local unresolved = false\n        for key, globalId in pairs(scoAeonPendingResourceSpotPairings) do\n            local registered, rebuilt, suppressedPresentation =\n                scoAeonTryResolvePendingResourceSpot(globalId)\n            if registered then\n                scoAeonPendingResourceSpotPairings[key] = nil\n                if rebuilt then\n                    fallbackRecovered = fallbackRecovered + 1\n                    if suppressedPresentation then\n                        malformedPresentationsSuppressed =\n                            malformedPresentationsSuppressed + 1\n                    end\n                else\n                    recovered = recovered + 1\n                end\n            else\n                unresolved = true\n            end\n        end\n\n        if not unresolved then\n            scoAeonResourceSpotPairingThread = nil\n            if recovered > 0 then\n                Log(\n                    \"[Aeon Resource Markers] Recovered \"\n                    .. tostring(recovered)\n                    .. \" delayed client resource-spot pairings.\")\n            end\n            scoAeonLogFallbackRecovery(\n                fallbackRecovered,\n                malformedPresentationsSuppressed)\n            return\n        end\n        WaitTicks(1)\n    end\n\n    for key, globalId in pairs(scoAeonPendingResourceSpotPairings) do\n        local registered = scoAeonTryRegisterResourceSpot(globalId)\n        if registered then\n            scoAeonPendingResourceSpotPairings[key] = nil\n            recovered = recovered + 1\n        elseif not globalId.fallbackAttempted then\n            local recoveredFallback, suppressedPresentation, attempted =\n                scoAeonTryRegisterFallbackResourceSpot(globalId, false)\n            if attempted then\n                globalId.fallbackAttempted = true\n            end\n            if recoveredFallback then\n                scoAeonPendingResourceSpotPairings[key] = nil\n                fallbackRecovered = fallbackRecovered + 1\n                if suppressedPresentation then\n                    malformedPresentationsSuppressed =\n                        malformedPresentationsSuppressed + 1\n                end\n            end\n        end\n    end\n\n    local unresolvedCount = scoAeonCountPendingResourceSpots()\n    for key in pairs(scoAeonPendingResourceSpotPairings) do\n        scoAeonPendingResourceSpotPairings[key] = nil\n    end\n    scoAeonResourceSpotPairingThread = nil\n\n    if recovered > 0 then\n        Log(\n            \"[Aeon Resource Markers] Recovered \"\n            .. tostring(recovered)\n            .. \" delayed client resource-spot pairings.\")\n    end\n    scoAeonLogFallbackRecovery(\n        fallbackRecovered,\n        malformedPresentationsSuppressed)\n    if unresolvedCount > 0 then\n        Engine.Error(\n            \"[Aeon Resource Markers] Timed out waiting for \"\n            .. tostring(unresolvedCount)\n            .. \" client resource-spot pairings; the cached fallback could not be created.\")\n    end\nend\n\nlocal function scoAeonReceiveCreateResourceSpotCommand(data)\n    local globalId = data.resourceSpotGlobalID\n    local key = scoAeonResourceSpotKey(globalId)\n    local pending = scoAeonPendingResourceSpotPairings[key]\n    if not pending then\n        pending = {\n            index = globalId.index,\n            version = globalId.version,\n            fallbackAttempted = false,\n        }\n        scoAeonPendingResourceSpotPairings[key] = pending\n    end\n\n    local registered = scoAeonTryResolvePendingResourceSpot(pending)\n    if registered then\n        scoAeonPendingResourceSpotPairings[key] = nil\n        return\n    end\n\n    if not scoAeonResourceSpotPairingThread then\n        -- The true sentinel also handles a scheduler that starts the thread\n        -- before NewThread returns.\n        scoAeonResourceSpotPairingThread = true\n        local thread = NewThread(scoAeonResolvePendingResourceSpots)\n        if scoAeonResourceSpotPairingThread then\n            scoAeonResourceSpotPairingThread = thread\n        end\n    end\nend\n\nCreateResourceSpot.Receive = scoAeonReceiveCreateResourceSpotCommand";

	public static void Apply()
	{
		object obj = null;
		object target = null;
		object obj2 = null;
		string targetPath = null;
		bool flag = false;
		bool flag2 = false;
		try
		{
			obj2 = GetLuaFileCache();
			if (!TryGetTarget(obj2, out targetPath, out target))
			{
				throw new FileNotFoundException("Sanctuary's resourceSpots.lua was absent from the Lua cache.", "LJ/lua/common/commands/definitions/resourceSpots.lua");
			}
			byte[] nativeArrayBytes = GetNativeArrayBytes(target.GetType(), target);
			string text = Encoding.UTF8.GetString(nativeArrayBytes);
			if (text.IndexOf("-- Supreme Commander Overhaul Aeon resource-marker pairing 1.2.3", StringComparison.Ordinal) >= 0)
			{
				ValidatePatchedSource(text);
				Log("The client resource-marker pairing repair is already active.");
				return;
			}
			ValidateStockSource(text);
			obj = NativeArrayByteFactory.CreatePersistent(target.GetType(), nativeArrayBytes, Encoding.UTF8.GetBytes("\n\n-- Supreme Commander Overhaul Aeon resource-marker pairing 1.2.3\nlocal scoAeonPendingResourceSpotPairings = {}\nlocal scoAeonResourceSpotPairingThread = nil\nlocal scoAeonFallbackResourceSpotPrefabId = nil\nlocal scoAeonSuppressedMalformedResourceSpots = {}\n\n-- Importing this module performs no prefab creation.  The wrapper records the\n-- normal client ResourceSpot prefab when map setup creates it, so the fallback\n-- never allocates a divergent client-only prefab at command-receive time.\nlocal scoAeonResourceSpotLoader =\n    Import(\"common/loading/resourceSpotTemplateLoader.lua\")\nlocal scoAeonCreateResourceSpotPrefab =\n    scoAeonResourceSpotLoader.CreateResourceSpotPrefab\nlocal scoAeonResourceSpotUtils =\n    Import(\"common/resourceSpot.lua\")\nfunction scoAeonResourceSpotLoader.CreateResourceSpotPrefab(resType)\n    local prefabId = scoAeonCreateResourceSpotPrefab(resType)\n    if IsClient and resType == \"alloys\" then\n        scoAeonFallbackResourceSpotPrefabId = prefabId\n    end\n    return prefabId\nend\n\nlocal function scoAeonResourceSpotKey(globalId)\n    return tostring(globalId.index) .. \":\" .. tostring(globalId.version)\nend\n\nlocal function scoAeonHasRegisteredResourceSpot(globalId)\n    local existing = scoAeonResourceSpotUtils.resourceSpots[globalId.index]\n    return existing\n        and existing.id\n        and existing.id.index == globalId.index\n        and existing.id.version == globalId.version\nend\n\nlocal function scoAeonGetPairedLocalId(globalId)\n    local localId = {}\n    local pairError = Engine.GetGlobalEntityPairedLocalID(globalId, localId)\n    if pairError ~= EngineErrorCode.Success\n        or not Engine.IsValidLocalID(localId)\n    then\n        return nil\n    end\n    return localId\nend\n\nlocal function scoAeonIsBidirectionalPairing(globalId, localId)\n    local reverseGlobalId = {}\n    local reverseError = Engine.GetLocalEntityGlobalID(localId, reverseGlobalId)\n    return reverseError == EngineErrorCode.Success\n        and reverseGlobalId.index == globalId.index\n        and reverseGlobalId.version == globalId.version\nend\n\nlocal function scoAeonHasResourceSpotVisuals(localId)\n    local planeId = {}\n    local planeError = Engine.GetLocalBone(localId, \"Plane\", planeId)\n    if planeError ~= EngineErrorCode.Success\n        or not Engine.IsValidLocalID(planeId)\n    then\n        return false\n    end\n\n    local billboardId = {}\n    local billboardError = Engine.GetLocalBone(localId, \"Billboard\", billboardId)\n    return billboardError == EngineErrorCode.Success\n        and Engine.IsValidLocalID(billboardId)\nend\n\nlocal function scoAeonTryRegisterResourceSpot(globalId)\n    if scoAeonHasRegisteredResourceSpot(globalId) then\n        return true, false\n    end\n\n    -- The forward pairing can briefly resolve to another valid client entity\n    -- during map initialization. Require the candidate to map back to this\n    -- exact global entity before the ResourceSpot visual signature is checked.\n    local localId = scoAeonGetPairedLocalId(globalId)\n    if not localId\n    then\n        return false, false\n    end\n    if not scoAeonIsBidirectionalPairing(globalId, localId) then\n        return false, false\n    end\n    if not scoAeonHasResourceSpotVisuals(localId) then\n        -- The authoritative resource global already has an exact local root,\n        -- but that root is visibly malformed (for example, a tank). This is\n        -- safe to rebuild immediately; incomplete or mismatched pairings\n        -- retain the bounded retry below.\n        return false, true\n    end\n\n    ResourceSpotsUpdate.RegisterResourceSpot(globalId, localId, \"alloys\")\n    return scoAeonHasRegisteredResourceSpot(globalId), false\nend\n\nlocal function scoAeonSuppressMalformedResourceSpotPresentation(globalId)\n    local localId = scoAeonGetPairedLocalId(globalId)\n    if not localId\n        or not scoAeonIsBidirectionalPairing(globalId, localId)\n        or scoAeonHasResourceSpotVisuals(localId)\n    then\n        return false\n    end\n\n    local key = scoAeonResourceSpotKey(globalId)\n    if scoAeonSuppressedMalformedResourceSpots[key] then\n        return false\n    end\n\n    scoAeonSuppressedMalformedResourceSpots[key] = true\n    -- The command is authoritative and this root maps back to that exact\n    -- resource global, so do not delete or move it. The four master toggles\n    -- suppress only its malformed client presentation.\n    Engine.SetRendererEnabled(localId, false)\n    Engine.SetIconsEnabled(localId, false)\n    Engine.SetRangeRingsEnabled(localId, false)\n    Engine.SetProgressBarsEnabled(localId, false)\n    return true\nend\n\nlocal function scoAeonTryRegisterFallbackResourceSpot(\n    globalId,\n    requireMalformedPair)\n    if scoAeonHasRegisteredResourceSpot(globalId) then\n        return false, false, false\n    end\n    if not scoAeonFallbackResourceSpotPrefabId then\n        return false, false, false\n    end\n    if requireMalformedPair then\n        local pairedLocalId = scoAeonGetPairedLocalId(globalId)\n        if not pairedLocalId\n            or not scoAeonIsBidirectionalPairing(globalId, pairedLocalId)\n            or scoAeonHasResourceSpotVisuals(pairedLocalId)\n        then\n            return false, false, false\n        end\n    end\n\n    local position = {}\n    local positionError =\n        Engine.GetGlobalEntityWorldPosition(globalId, position)\n    if positionError ~= EngineErrorCode.Success then\n        return false, false, false\n    end\n\n    local instantiateError, localId = Engine.InstantiatePrefab(\n        scoAeonFallbackResourceSpotPrefabId,\n        position,\n        EngineClasses.float3(2, 2, 2),\n        GetIdentityQuaternion())\n    if instantiateError ~= EngineErrorCode.Success\n        or not Engine.IsValidLocalID(localId)\n        or not scoAeonHasResourceSpotVisuals(localId)\n    then\n        if Engine.IsValidLocalID(localId) then\n            Engine.DeletePrefabInstance(localId)\n        end\n        return false, false, true\n    end\n\n    ResourceSpotsUpdate.RegisterResourceSpot(globalId, localId, \"alloys\")\n    if not scoAeonHasRegisteredResourceSpot(globalId) then\n        Engine.DeletePrefabInstance(localId)\n        return false, false, true\n    end\n\n    return true, scoAeonSuppressMalformedResourceSpotPresentation(globalId), true\nend\n\nlocal function scoAeonTryResolvePendingResourceSpot(entry)\n    local registered, malformedPairedPresentation =\n        scoAeonTryRegisterResourceSpot(entry)\n    if registered then\n        return true, false, false\n    end\n    if not malformedPairedPresentation or entry.fallbackAttempted then\n        return false, false, false\n    end\n\n    -- No Lua yield occurs between these checks and InstantiatePrefab. Recheck\n    -- the exact malformed pair before creating a local-only replacement, then\n    -- remember only an actual instantiate attempt so unavailable prerequisites\n    -- can still recover on a later retry tick.\n    local rebuilt, suppressedPresentation, attempted =\n        scoAeonTryRegisterFallbackResourceSpot(entry, true)\n    if attempted then\n        entry.fallbackAttempted = true\n    end\n    return rebuilt, rebuilt, suppressedPresentation\nend\n\nlocal function scoAeonCountPendingResourceSpots()\n    local count = 0\n    for _ in pairs(scoAeonPendingResourceSpotPairings) do\n        count = count + 1\n    end\n    return count\nend\n\nlocal function scoAeonLogFallbackRecovery(\n    fallbackRecovered,\n    malformedPresentationsSuppressed)\n    if fallbackRecovered > 0 then\n        Log(\n            \"[Aeon Resource Markers] Rebuilt \"\n            .. tostring(fallbackRecovered)\n            .. \" client resource spots and suppressed \"\n            .. tostring(malformedPresentationsSuppressed)\n            .. \" malformed paired presentations.\")\n    end\nend\n\nlocal function scoAeonResolvePendingResourceSpots()\n    local recovered = 0\n    local fallbackRecovered = 0\n    local malformedPresentationsSuppressed = 0\n    for _ = 1, 120 do\n        local unresolved = false\n        for key, globalId in pairs(scoAeonPendingResourceSpotPairings) do\n            local registered, rebuilt, suppressedPresentation =\n                scoAeonTryResolvePendingResourceSpot(globalId)\n            if registered then\n                scoAeonPendingResourceSpotPairings[key] = nil\n                if rebuilt then\n                    fallbackRecovered = fallbackRecovered + 1\n                    if suppressedPresentation then\n                        malformedPresentationsSuppressed =\n                            malformedPresentationsSuppressed + 1\n                    end\n                else\n                    recovered = recovered + 1\n                end\n            else\n                unresolved = true\n            end\n        end\n\n        if not unresolved then\n            scoAeonResourceSpotPairingThread = nil\n            if recovered > 0 then\n                Log(\n                    \"[Aeon Resource Markers] Recovered \"\n                    .. tostring(recovered)\n                    .. \" delayed client resource-spot pairings.\")\n            end\n            scoAeonLogFallbackRecovery(\n                fallbackRecovered,\n                malformedPresentationsSuppressed)\n            return\n        end\n        WaitTicks(1)\n    end\n\n    for key, globalId in pairs(scoAeonPendingResourceSpotPairings) do\n        local registered = scoAeonTryRegisterResourceSpot(globalId)\n        if registered then\n            scoAeonPendingResourceSpotPairings[key] = nil\n            recovered = recovered + 1\n        elseif not globalId.fallbackAttempted then\n            local recoveredFallback, suppressedPresentation, attempted =\n                scoAeonTryRegisterFallbackResourceSpot(globalId, false)\n            if attempted then\n                globalId.fallbackAttempted = true\n            end\n            if recoveredFallback then\n                scoAeonPendingResourceSpotPairings[key] = nil\n                fallbackRecovered = fallbackRecovered + 1\n                if suppressedPresentation then\n                    malformedPresentationsSuppressed =\n                        malformedPresentationsSuppressed + 1\n                end\n            end\n        end\n    end\n\n    local unresolvedCount = scoAeonCountPendingResourceSpots()\n    for key in pairs(scoAeonPendingResourceSpotPairings) do\n        scoAeonPendingResourceSpotPairings[key] = nil\n    end\n    scoAeonResourceSpotPairingThread = nil\n\n    if recovered > 0 then\n        Log(\n            \"[Aeon Resource Markers] Recovered \"\n            .. tostring(recovered)\n            .. \" delayed client resource-spot pairings.\")\n    end\n    scoAeonLogFallbackRecovery(\n        fallbackRecovered,\n        malformedPresentationsSuppressed)\n    if unresolvedCount > 0 then\n        Engine.Error(\n            \"[Aeon Resource Markers] Timed out waiting for \"\n            .. tostring(unresolvedCount)\n            .. \" client resource-spot pairings; the cached fallback could not be created.\")\n    end\nend\n\nlocal function scoAeonReceiveCreateResourceSpotCommand(data)\n    local globalId = data.resourceSpotGlobalID\n    local key = scoAeonResourceSpotKey(globalId)\n    local pending = scoAeonPendingResourceSpotPairings[key]\n    if not pending then\n        pending = {\n            index = globalId.index,\n            version = globalId.version,\n            fallbackAttempted = false,\n        }\n        scoAeonPendingResourceSpotPairings[key] = pending\n    end\n\n    local registered = scoAeonTryResolvePendingResourceSpot(pending)\n    if registered then\n        scoAeonPendingResourceSpotPairings[key] = nil\n        return\n    end\n\n    if not scoAeonResourceSpotPairingThread then\n        -- The true sentinel also handles a scheduler that starts the thread\n        -- before NewThread returns.\n        scoAeonResourceSpotPairingThread = true\n        local thread = NewThread(scoAeonResolvePendingResourceSpots)\n        if scoAeonResourceSpotPairingThread then\n            scoAeonResourceSpotPairingThread = thread\n        end\n    end\nend\n\nCreateResourceSpot.Receive = scoAeonReceiveCreateResourceSpotCommand"));
			ValidatePatchedSource(Encoding.UTF8.GetString(GetNativeArrayBytes(obj.GetType(), obj)));
			flag = true;
			SetCachedResource(obj2, targetPath, obj);
			ValidateAssignedIdentity(obj2, targetPath, obj);
			flag2 = true;
			DisposeNativeArray(target.GetType(), target);
			target = null;
			Log("Installed immediate malformed-pair resource-spot recovery with bounded incomplete-pair retries and no host command changes.");
		}
		catch (Exception ex)
		{
			Exception ex2 = null;
			if (flag && !flag2 && obj2 != null && targetPath != null && target != null)
			{
				try
				{
					SetCachedResource(obj2, targetPath, target);
					ValidateAssignedIdentity(obj2, targetPath, target);
					flag = false;
				}
				catch (Exception ex3)
				{
					ex2 = ex3;
				}
			}
			if (!flag && obj != null && IsNativeArrayCreated(obj))
			{
				DisposeNativeArray(obj.GetType(), obj);
			}
			Exception ex4 = ((ex2 == null) ? ex : new AggregateException(ex, ex2));
			Log("Failed to install the client resource-marker pairing repair: " + ex4);
			throw new InvalidOperationException("The Aeon resource-marker cache transaction did not commit.", ex4);
		}
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static bool TryGetTarget(object cache, out string targetPath, out object target)
	{
		Type type = cache.GetType();
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		targetPath = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), "LJ/lua/common/commands/definitions/resourceSpots.lua"));
		if ((bool)obj.Invoke(cache, new object[1] { targetPath }))
		{
			target = propertyInfo.GetValue(cache, new object[1] { targetPath }) ?? throw new InvalidOperationException("Cached resourceSpots.lua has no value.");
			EnsureNativeArray(target);
			return true;
		}
		string text = null;
		object obj2 = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			string text2 = (string)type2.GetProperty("Key")?.GetValue(item);
			if (text2 != null && text2.Replace('\\', '/').EndsWith("/LJ/lua/common/commands/definitions/resourceSpots.lua", StringComparison.OrdinalIgnoreCase))
			{
				if (text != null)
				{
					throw new InvalidOperationException("More than one cached resource matches resourceSpots.lua.");
				}
				text = text2;
				obj2 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("Cached resourceSpots.lua has no value.");
				EnsureNativeArray(obj2);
			}
		}
		if (text == null || obj2 == null)
		{
			target = null;
			return false;
		}
		targetPath = text;
		target = obj2;
		return true;
	}

	private static void ValidateStockSource(string source)
	{
		RequireCount(source, "function CreateResourceSpot.Receive(data)", 1, "stock resource-spot receive function");
		RequireCount(source, "CreateResourceSpot = Registry.RegisterCommand", 1, "stock resource-spot command registration");
		RequireCount(source, "ResourceSpotsUpdate.RegisterResourceSpot(data.resourceSpotGlobalID, resourceSpotLocalID, data.resourceType)", 1, "stock resource-spot client receiver");
	}

	private static void ValidatePatchedSource(string source)
	{
		ValidateStockSource(source);
		RequireCount(source, "-- Supreme Commander Overhaul Aeon resource-marker pairing 1.2.3", 1, "resource-marker override marker");
		RequireCount(source, "Import(\"common/loading/resourceSpotTemplateLoader.lua\")", 1, "stock resource-spot loader import");
		RequireCount(source, "scoAeonFallbackResourceSpotPrefabId = prefabId", 1, "cached stock client resource prefab");
		RequireCount(source, "Engine.GetGlobalEntityPairedLocalID(globalId, localId)", 1, "checked global-to-local pairing");
		RequireCount(source, "Engine.GetLocalEntityGlobalID(localId, reverseGlobalId)", 1, "checked local-to-global pairing");
		RequireCount(source, "Engine.GetLocalBone(localId, \"Plane\", planeId)", 1, "resource-spot plane validation");
		RequireCount(source, "Engine.GetLocalBone(localId, \"Billboard\", billboardId)", 1, "resource-spot billboard validation");
		RequireCount(source, "local registered, malformedPairedPresentation =", 1, "immediate malformed-pair decision");
		RequireCount(source, "local function scoAeonTryResolvePendingResourceSpot(entry)", 1, "per-resource immediate malformed-pair resolver");
		RequireCount(source, "fallbackAttempted = false", 1, "per-resource fallback-attempt state");
		RequireCount(source, "scoAeonTryRegisterFallbackResourceSpot(entry, true)", 1, "immediate malformed-pair fallback");
		RequireCount(source, "scoAeonTryRegisterFallbackResourceSpot(globalId, false)", 1, "last-chance incomplete-pair fallback");
		RequireCount(source, "for _ = 1, 120 do", 1, "bounded pairing retry");
		RequireCount(source, "Engine.InstantiatePrefab(", 1, "cached local resource-spot fallback");
		RequireCount(source, "Engine.SetRendererEnabled(localId, false)", 1, "malformed paired renderer suppression");
		RequireCount(source, "Engine.SetIconsEnabled(localId, false)", 1, "malformed paired icon suppression");
		RequireCount(source, "Engine.SetRangeRingsEnabled(localId, false)", 1, "malformed paired range-ring suppression");
		RequireCount(source, "Engine.SetProgressBarsEnabled(localId, false)", 1, "malformed paired progress-bar suppression");
		RequireCount(source, "scoAeonHasExpectedResourceSpotPrefab", 0, "removed prefab-ID fallback gate");
		RequireCount(source, "Engine.GetLocalEntityWorldPosition(localId, localPosition)", 0, "removed position fallback gate");
		RequireCount(source, "ResourceSpotsUpdate.RegisterResourceSpot(globalId, localId, \"alloys\")", 2, "normal and fallback resource-spot registrations");
		RequireCount(source, "CreateResourceSpot.Receive = scoAeonReceiveCreateResourceSpotCommand", 1, "client command receiver rebinding");
		RequireCount(source, "local function scoAeonReceiveCreateResourceSpotCommand(data)", 1, "decoded resource-spot receiver");
	}

	private static void RequireCount(string source, string value, int expected, string description)
	{
		int num = 0;
		int startIndex = 0;
		while ((startIndex = source.IndexOf(value, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += value.Length;
		}
		if (num != expected)
		{
			throw new InvalidOperationException($"Expected {expected} {description}; found {num}.");
		}
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void ValidateAssignedIdentity(object cache, string path, object expected)
	{
		object obj = (cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException("Cached resourceSpots.lua has no assigned value.");
		EnsureNativeArray(obj);
		byte[] nativeArrayBytes = GetNativeArrayBytes(expected.GetType(), expected);
		if (!GetNativeArrayBytes(obj.GetType(), obj).SequenceEqual(nativeArrayBytes))
		{
			throw new InvalidOperationException("Cached resourceSpots.lua failed byte-identity validation.");
		}
	}

	private static void EnsureNativeArray(object value)
	{
		if (!IsNativeArrayCreated(value))
		{
			throw new InvalidOperationException("Cached resourceSpots.lua is not a created NativeArray<byte>.");
		}
	}

	private static byte[] GetNativeArrayBytes(Type type, object value)
	{
		return (byte[])(type.GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(type.FullName, "ToArray")).Invoke(value, null);
	}

	private static bool IsNativeArrayCreated(object value)
	{
		return (bool)(value.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(value.GetType().FullName, "IsCreated")).GetValue(value);
	}

	private static void DisposeNativeArray(Type type, object value)
	{
		(type.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(type.FullName, "Dispose")).Invoke(value, null);
	}

	private static void Log(string message)
	{
		string text = "[Aeon Resource Marker Cache Patcher] " + message;
		Console.WriteLine(text);
		try
		{
			(from assembly in AppDomain.CurrentDomain.GetAssemblies()
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type type) => (object)type != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}
}
