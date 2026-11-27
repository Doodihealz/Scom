using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Scom.Playtest26880003
{
    public static class GroundContacts
    {
        private static readonly Encoding Utf8 = new UTF8Encoding(false);

        public static void Apply(string engine, string mod, IDictionary<string, byte[]> stock, Dictionary<string, byte[]> result)
        {
            var helper = File.ReadAllBytes(Key(mod, "lua/native/groundPresentation.lua"));
            result[Key(engine, "lua/scom/groundPresentation.lua")] = helper;
            var clientPath = Key(engine, "lua/scom/gameplay/client/units/unitsClasses/unitsBaseClass.lua");
            var client = Utf8.GetString(result[clientPath]).Replace("\r\n", "\n");
            client = Replace(client, "local SCO_FootfallLoader = Import(\"common/loading/decalTemplateLoader.lua\")",
                "local SCO_FootfallLoader = Import('scom/groundPresentation.lua')");
            var start = client.IndexOf("local function createPrefab(path)\n", StringComparison.Ordinal);
            var end = start < 0 ? -1 : client.IndexOf("\nlocal function setTrackOpacity", start, StringComparison.Ordinal);
            if (start < 0 || end < 0) throw new InvalidDataException("SCOM terrain-track prefab boundary changed.");
            client = client.Substring(0, start) + @"local function createPrefab(path)
    return assert(Import('scom/groundPresentation.lua').CreateDecalPrefab(path), 'ground-track decal unavailable: '..path)
end
" + client.Substring(end);
            client = Replace(client, @"    assert(profile.referenceAltitude == ""Ground"" and ReferenceAltitude
        and unit.tp.movement.referenceAltitude == ReferenceAltitude.Ground,",
                @"    assert(ReferenceAltitude and unit.tp.movement.referenceAltitude == ReferenceAltitude[profile.referenceAltitude]
        and (profile.referenceAltitude == 'Ground' or (unit.tpId == 'ugn2001' and profile.referenceAltitude == 'GroundOrWater')),");
            client = Replace(client, "    if not profile then return end\n    local state = self.scoGroundFootfallState",
                "    if not profile then return end\n    if profile.landOnly and not Import('scom/groundPresentation.lua').IsDryLand(self) then\n        self.scoGroundFootfallState = nil\n        return\n    end\n    local state = self.scoGroundFootfallState");
            result[clientPath] = Utf8.GetBytes(client);
            var loaderPath = Key(engine, "lua/common/loading/unitTemplateLoader.lua");
            var loader = Utf8.GetString(result[loaderPath]).Replace("\r\n", "\n");
            loader = Replace(loader, "        SCOM_PrepareWeaponAudio(tp)\n",
                "        SCOM_PrepareWeaponAudio(tp)\n        Import('scom/groundPresentation.lua').Prepare(tp)\n");
            result[loaderPath] = Utf8.GetBytes(loader);
        }

        private static string Key(string root, string route) =>
            Path.GetFullPath(Path.Combine(root, route.Replace('/', Path.DirectorySeparatorChar)));

        private static string Replace(string text, string before, string after)
        {
            var at = text.IndexOf(before, StringComparison.Ordinal);
            if (at < 0 || text.IndexOf(before, at + before.Length, StringComparison.Ordinal) >= 0)
                throw new InvalidDataException("SCOM ground presentation anchor changed: " + before);
            return text.Substring(0, at) + after + text.Substring(at + before.Length);
        }
    }
}
