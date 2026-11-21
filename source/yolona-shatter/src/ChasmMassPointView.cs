using System.Text;

namespace ScomShatter;

// Aeon's fallback marker is local-only and therefore is not released by the
// authoritative prefab's linked deletion. Keep that ownership in its Lua module.
internal static class ChasmMassPointView
{
    private const string Marker = "-- SCOM chasm resource fallback lifecycle 1";
    private const string DeclarationAnchor = "local function scoAeonTryRegisterFallbackResourceSpot(\n";
    private const string Declaration = "local scoChasmFallbackResourceSpots = {}\n\n";
    private const string Success = "    return true, scoAeonSuppressMalformedResourceSpotPresentation(globalId), true\n";
    private const string Capture = @"
    scoChasmFallbackResourceSpots[scoAeonResourceSpotKey(globalId)] = localId
";
    private const string Lifecycle = @"

-- SCOM chasm resource fallback lifecycle 1
if IsClient then
    local previousDelete = DeleteResourceSpot.Receive
    function DeleteResourceSpot.Receive(data)
        local globalId = data.resourceSpotGlobalID
        local key = scoAeonResourceSpotKey(globalId)
        -- Cancel a delayed pairing before its next retry can recreate the marker.
        scoAeonPendingResourceSpotPairings[key] = nil
        scoAeonSuppressedMalformedResourceSpots[key] = nil
        local fallback = scoChasmFallbackResourceSpots[key]
        scoChasmFallbackResourceSpots[key] = nil

        -- A stale deletion must not deregister a reused global index.
        if scoAeonHasRegisteredResourceSpot(globalId) then previousDelete(data) end
        if fallback and Engine.IsValidLocalID(fallback) then
            Engine.DeletePrefabInstance(fallback)
        end
    end
end
";

    internal static string ReadHookScript()
    {
        var script = new StringBuilder(@"
if not Engine.SCOChasmResourceViewHookInstalled then
    local read = Engine.GetFileContent
    local warned = false
    local function once(source, fragment)
        local first, last = source:find(fragment, 1, true)
        assert(first and not source:find(fragment, last + 1, true),
            'SCOM resource fallback lifecycle contract changed')
        return first, last
    end
    local function transform(source)
        local normalized = source:gsub('\r\n', '\n')
        if not normalized:find('scoAeon', 1, true)
            and not normalized:find('Aeon resource-marker pairing', 1, true) then return source end
");
        script.Append("        local marker, anchor, declaration, success, capture, lifecycle = ")
            .Append(Quote(Marker)).Append(", ").Append(Quote(DeclarationAnchor)).Append(", ")
            .Append(Quote(Declaration)).Append(", ").Append(Quote(Success)).Append(", ")
            .Append(Quote(Capture)).Append(", ").Append(Quote(Lifecycle)).Append(@"
        if normalized:find(marker, 1, true) then
            once(normalized, declaration .. anchor)
            once(normalized, capture .. success)
            once(normalized, lifecycle)
            return source
        end
        once(normalized, '-- Supreme Commander Overhaul Aeon resource-marker pairing 1.2.3')
        once(normalized, 'CreateResourceSpot.Receive = scoAeonReceiveCreateResourceSpotCommand')
        once(normalized, 'local scoAeonPendingResourceSpotPairings = {}')
        once(normalized, 'local scoAeonSuppressedMalformedResourceSpots = {}')
        local first, last = once(normalized, success)
        normalized = normalized:sub(1, first - 1) .. capture .. success .. normalized:sub(last + 1)
        first, last = once(normalized, anchor)
        normalized = normalized:sub(1, first - 1) .. declaration .. normalized:sub(first)
        normalized = normalized .. lifecycle
        if source:find('\r\n', 1, true) then normalized = normalized:gsub('\n', '\r\n') end
        return normalized
    end
    Engine.GetFileContent = function(path)
        local source = read(path)
        if type(source) ~= 'string' or type(path) ~= 'string' then return source end
        local target = '/common/commands/definitions/resourcespots.lua'
        local normalizedPath = path:gsub('\\', '/'):lower()
        if normalizedPath:sub(-#target) ~= target then return source end
        local ok, changed = pcall(transform, source)
        if ok then return changed end
        if not warned then
            warned = true
            Engine.Warn('[SCOM shatter] Resource fallback source changed; optional marker cleanup was skipped.')
        end
        return source
    end
    Engine.SCOChasmResourceViewHookInstalled = true
end
");
        return script.ToString();
    }

    private static string Quote(string value) => "\"" + value.Replace("\\", "\\\\").Replace("\"", "\\\"")
        .Replace("\r", "\\r").Replace("\n", "\\n") + "\"";
}
