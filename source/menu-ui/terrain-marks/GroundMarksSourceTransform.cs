using System;
using System.Text;

namespace ScomGroundMarks
{
    /// <summary>Upgrade-safe visual-only correction after editable Lua is read.</summary>
    public static class SourceTransform
    {
        public const string Version = "1.0.0";
        private const string Target = "/common/systems/scoNuclearPresentation.lua";
        private const string Marker = "-- SCOM terrain scorch projection 1.0.0";
        private static readonly UTF8Encoding Utf8 = new UTF8Encoding(false, true);
        private static bool unsupportedReported;
        public static string LastError { get; private set; }

        private const string Before =
            "    local waterStatus, hasWater = Engine.HasWater()\n" +
            "    if waterStatus ~= success then return end\n" +
            "    -- Cybran burns project onto terrain, including dry crater floors below the\n" +
            "    -- map's water level. Connected water renders over the underlying decal.\n" +
            "    if hasWater and not (presentation and presentation.scorchLayers == cybranScorchLayers) then\n" +
            "        local levelStatus, level = Engine.GetWaterLevel()\n" +
            "        if levelStatus ~= success or height < level then return end\n" +
            "    end\n";

        private const string After =
            "    " + Marker + "\n" +
            "    -- Project every faction's burn onto terrain, including dry crater floors\n" +
            "    -- below the global sea level. Connected water covers the terrain decal.\n";

        private const string ContactTarget = "/client/units/unitsClasses/unitsBaseClass.lua";
        private static readonly string[] NuclearBefore = { Before };
        private static readonly string[] NuclearAfter = { After };
        private static readonly string[] ContactBefore = {
            "    local waterCode, hasWater = Engine.HasWater()\n    if waterCode ~= EngineErrorCode.Success then SCO_FootfallReset(state); return end\n    local waterLevel\n    if hasWater then\n        waterCode, waterLevel = Engine.GetWaterLevel()\n        if waterCode ~= EngineErrorCode.Success or not SCO_FootfallFinite(waterLevel) then\n            SCO_FootfallReset(state)\n            return\n        end\n    end\n",
            "            if groundCode == EngineErrorCode.Success and SCO_FootfallFinite(ground)\n                and (not hasWater or ground >= waterLevel - 0.01) then\n",
            "    local waterCode, hasWater = Engine.HasWater()\n    if waterCode ~= EngineErrorCode.Success then reset(state); return end\n    local waterLevel\n    if hasWater then\n        waterCode, waterLevel = Engine.GetWaterLevel()\n        if waterCode ~= EngineErrorCode.Success or not finite(waterLevel) then reset(state); return end\n    end\n",
            "        if groundCode ~= EngineErrorCode.Success or not finite(ground)\n            or (hasWater and ground < waterLevel - 0.01)\n            or math.abs(point.y - ground - altitude) > tolerance then\n",
            "                    if result == EngineErrorCode.Success and finite(height)\n                        and (not hasWater or height >= waterLevel - 0.01) then\n"
        };
        private static readonly string[] ContactAfter = {
            "    -- SCOM terrain footfall projection 1.0.0\n    -- Actual bone/terrain contact owns stamps, including dry below-sea craters.\n",
            "            if groundCode == EngineErrorCode.Success and SCO_FootfallFinite(ground) then\n",
            "    -- SCOM terrain track projection 1.0.0\n    -- Sampled contact clearance rejects floating/airborne units without a sea-level heuristic.\n",
            "        if groundCode ~= EngineErrorCode.Success or not finite(ground)\n            or math.abs(point.y - ground - altitude) > tolerance then\n",
            "                    if result == EngineErrorCode.Success and finite(height) then\n"
        };

        public static byte[] Transform(byte[] source, string path)
        {
            if (source == null) throw new ArgumentNullException("source");
            if (path == null) return source;
            string normalized = path.Replace('\\', '/');
            bool contact = normalized.EndsWith(ContactTarget, StringComparison.Ordinal);
            if (!contact && !normalized.EndsWith(Target, StringComparison.Ordinal)) return source;
            string module = contact ? "terrain contact" : "nuclear presentation";
            string text;
            try { text = Utf8.GetString(source); }
            catch (DecoderFallbackException)
            {
                ReportUnsupported("The " + module + " source is not valid UTF-8; its original bytes were preserved.");
                return source;
            }
            string newline = text.IndexOf("\r\n", StringComparison.Ordinal) >= 0 ? "\r\n" : "\n";
            string[] before = contact ? ContactBefore : NuclearBefore;
            string[] after = contact ? ContactAfter : NuclearAfter;
            bool original = true, repaired = true;
            for (int i = 0; i < before.Length; i++)
            {
                string oldBlock = before[i].Replace("\n", newline);
                string newBlock = after[i].Replace("\n", newline);
                int index = text.IndexOf(oldBlock, StringComparison.Ordinal);
                int repairedIndex = text.IndexOf(newBlock, StringComparison.Ordinal);
                original &= index >= 0 && text.IndexOf(oldBlock, index + oldBlock.Length, StringComparison.Ordinal) < 0 && repairedIndex < 0;
                repaired &= index < 0 && repairedIndex >= 0 && text.IndexOf(newBlock, repairedIndex + newBlock.Length, StringComparison.Ordinal) < 0;
            }
            if (original)
            {
                for (int i = 0; i < before.Length; i++)
                    text = text.Replace(before[i].Replace("\n", newline), after[i].Replace("\n", newline));
                LastError = null;
                return Utf8.GetBytes(text);
            }
            // A packaged fixed source or a previously rebuilt cache is already correct.
            if (repaired)
            {
                LastError = null;
                return source;
            }
            // Preserve unsupported local edits atomically; never replace an entire module.
            ReportUnsupported("The customized " + module + " source did not match the supported terrain-mark blocks; it was preserved.");
            return source;
        }

        private static void ReportUnsupported(string message)
        {
            LastError = message;
            if (unsupportedReported) return;
            unsupportedReported = true;
            Console.WriteLine("[SCOM terrain marks] " + message);
        }
    }
}
