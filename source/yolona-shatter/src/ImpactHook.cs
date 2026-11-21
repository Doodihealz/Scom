using System;
using System.Text;

namespace ScomShatter
{
    internal static class ImpactHook
    {
        internal const string Marker = "-- SCOM Yolona shatter impact 3.0.0";
        private const string Original =
            "        if not profile.full then previous(self, position, orientation, hitGlobalId, ...) end\n" +
            "        self.scoNuclearPresentationPending = true\n" +
            "        local accepted = play(position, profile.full, profile.scale, profile.delay, function(played)\n" +
            "            self.scoNuclearPresentationPending = nil\n" +
            "            if played then self.scoNuclearPresentationPlayed = true end\n" +
            "        end, profile.scorchScale)";
        private const string Replacement =
            "        " + Marker + "\n" +
            "        local shatterSource = self.tp.additions and self.tp.additions.scoSourceProjectile\n" +
            "        if self.tpId == 'psf0136' and shatterSource\n" +
            "            and type(shatterSource.sourceId) == 'string'\n" +
            "            and shatterSource.sourceId:lower() == 'sifexperimentalstrategicmissile01'\n" +
            "            and type(Engine.SCOShatter) == 'function' and vector(position) then\n" +
            "            self.scoNuclearPresentationPending = true\n" +
            "            local ok, accepted = pcall(Engine.SCOShatter, position.x, position.y, position.z, self.id.index, self.id.version)\n" +
            "            self.scoNuclearPresentationPending = nil\n" +
            "            if ok and accepted == true then\n" +
            "                self.scoNuclearPresentationPlayed = true\n" +
            "                local audio = Import('client/audio/audioManager.lua')\n" +
            "                audio.NotifyCombatActivity()\n" +
            "                local impact = self.tp.audio and self.tp.audio.onImpact\n" +
            "                if impact and impact.prefabID then audio.PlayOneShot(impact.prefabID, position, orientation) end\n" +
            "                return\n" +
            "            end\n" +
            "        end\n" + Original;
        private static readonly string[] RequiredFragments = {
            "    if presentation and presentation.scorchLayers then\n        layers = presentation.scorchLayers",
            "    if presentation then path = presentation.path end",
            "    psf0136 = {delay=3.5, scale=1.5, scorchScale=2},",
            "        if collisionEntity(__Entities.Shields, hitGlobalId)\n            or collisionEntity(__Entities.Projectiles, hitGlobalId) then",
            "        if self.scoNuclearPresentationPlayed or self.scoNuclearPresentationPending then return end",
            "        if not profile or not self:IsIntelVisionVisible() then"
        };

        // Engine.GetFileContent has already copied its native array into a Lua
        // string. Transform that string, never its backing game cache allocation.
        internal static string ReadHookScript()
        {
            var script = new StringBuilder(@"
if not Engine.SCOShatterReadHookInstalled then
    local read = Engine.GetFileContent
    local warned = false
    local function once(source, fragment)
        local first, last = source:find(fragment, 1, true)
        if not first or source:find(fragment, last + 1, true) then
            error('Yolona impact source contract changed')
        end
        return first, last
    end
    local function transform(source)
        local normalized = source:gsub('\r\n', '\n')
");
            foreach (string fragment in RequiredFragments)
                script.Append("        once(normalized, ").Append(Quote(fragment)).Append(")\n");
            script.Append("        local original, replacement, marker = ")
                .Append(Quote(Original)).Append(", ").Append(Quote(Replacement)).Append(", ").Append(Quote(Marker)).Append(@"
        if normalized:find(marker, 1, true) then
            once(normalized, replacement)
            return source
        end
        local first, last = once(normalized, original)
        local changed = normalized:sub(1, first - 1) .. replacement .. normalized:sub(last + 1)
        if source:find('\r\n', 1, true) then changed = changed:gsub('\n', '\r\n') end
        return changed
    end
    Engine.GetFileContent = function(path)
        local source = read(path)
        if type(source) ~= 'string' or type(path) ~= 'string' then return source end
        local target = '/common/systems/sconuclearpresentation.lua'
        local normalizedPath = path:gsub('\\', '/'):lower()
        if normalizedPath:sub(-#target) ~= target then return source end
        local ok, changed = pcall(transform, source)
        if ok then return changed end
        if not warned then
            warned = true
            Engine.Warn('[SCOM shatter] Impact source changed; optional shatter hook was skipped.')
        end
        return source
    end
    Engine.SCOShatterReadHookInstalled = true
end
");
            return script.ToString();
        }

        private static string Quote(string value)
        {
            return "\"" + value.Replace("\\", "\\\\").Replace("\"", "\\\"")
                .Replace("\r", "\\r").Replace("\n", "\\n") + "\"";
        }
    }
}
