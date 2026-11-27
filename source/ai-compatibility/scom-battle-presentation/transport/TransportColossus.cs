using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace Scom.CurrentRepairs
{
    // Runs last in the canonical SCOM gameplay composer, before its atomic cache commit.
    public static class TransportColossus
    {
        private const string Marker = "-- SCOM native transport and tractor 1";
        private static readonly UTF8Encoding Utf8 = new UTF8Encoding(false, true);
        public static void Apply(string engineRoot, string modRoot,
            IDictionary<string, byte[]> stock, Dictionary<string, byte[]> result)
        {
            engineRoot = Path.GetFullPath(engineRoot);
            var pending = new Dictionary<string, byte[]>(StringComparer.Ordinal);
            string Key(string route) => Path.GetFullPath(Path.Combine(engineRoot, "lua", route.Replace('\\', Path.DirectorySeparatorChar).Replace('/', Path.DirectorySeparatorChar)));
            string Read(string route)
            {
                string key = Key(route);
                byte[] bytes;
                if (!result.TryGetValue(key, out bytes) && !stock.TryGetValue(key, out bytes))
                    throw new InvalidDataException("Missing transport consumer: " + route);
                var value = Utf8.GetString(bytes).Replace("\r\n", "\n");
                if (value.Contains(Marker)) throw new InvalidDataException("Transport stage already composed: " + route);
                return value;
            }
            void Write(string route, string value) => pending.Add(Key(route), Utf8.GetBytes(value + "\n" + Marker + "\n"));
            string Payload(string name)
            {
                using (var stream = typeof(TransportColossus).Assembly.GetManifestResourceStream("Scom.TransportColossus." + name))
                {
                    if (stream == null) throw new InvalidDataException("Missing transport payload: " + name);
                    using (var reader = new StreamReader(stream, Utf8)) return reader.ReadToEnd();
                }
            }
            Write("scom/nativeTransportTemplate.lua", Payload("template.lua"));
            int transports = 0;
            foreach (var key in result.Keys.Where(IsTemplate).OrderBy(k=>k, StringComparer.Ordinal))
            {
                var route = key.Substring(Path.Combine(engineRoot,"lua").Length+1);
                var source = Read(route);
                Write(route, source + "\nImport('scom/nativeTransportTemplate.lua').Prepare(UnitTemplate)");
                bool transport = source.Contains("[\"Transport\"] = true") && !source.Contains("[\"airStorage\"] = true");
                if (!transport) continue;
                transports++;
                string hostRoute = route.Substring(0, route.Length-"template.lua".Length) + "host.lua";
                Write(hostRoute, Read(hostRoute) + "\nUnitClass = Import('scom/nativeTransport.lua').Derive(UnitClass, 'SCOM_NativeTransport_" + UnitId(key) + "')\n");
            }
            if (transports != 10) throw new InvalidDataException("Expected ten SCOM aerial transports, found " + transports);
            Write("scom/nativeTransport.lua", Payload("transport.lua"));
            Write("common/units/transportAttachments.lua", Read("common/units/transportAttachments.lua") + "\n" + Payload("attachments.lua"));
            const string aiRoute = "AI/AITransport.lua";
            string aiSlots = PrepareAiSlots(Key(aiRoute), stock, result);
            if (aiSlots != null) Write(aiRoute, aiSlots);
            string loader = Read("common/loading/unitTemplateLoader.lua");
            string anchor = "    if tp.transport then\n        for _, template in ipairs(hierarchyEntities) do";
            Write("common/loading/unitTemplateLoader.lua", Replace(loader, anchor, Payload("prefab.lua") + "\n" + anchor));
            const string weaponRoute = "scom/gameplay/host/units/weaponsClasses/weaponsBaseClass.lua";
            var weapon = Read(weaponRoute);
            var tractor = Payload("tractor.lua");
            foreach (string name in new[] {"scoTractorIsEligible", "scoTractorRelease", "scoTractorTryClaim", "scoTractorPull"})
                weapon = Replace(weapon, Function(weapon, name), Function(tractor, name));
            Write(weaponRoute, "local SessionCommands = Import('common/commands/definitions/session.lua')\n" + weapon);
            foreach (var item in pending) result[item.Key] = item.Value;
        }
        private static string PrepareAiSlots(string path, IDictionary<string, byte[]> stock, Dictionary<string, byte[]> result)
        {
            if (!result.TryGetValue(path, out var bytes))
                stock.TryGetValue(path, out bytes);
            if (bytes == null)
            {
                Console.WriteLine("[SCOM transport] Skipped " + path + " (module absent).");
                return null;
            }
            try
            {
                string source = Utf8.GetString(bytes).Replace("\r\n", "\n");
                if (source.IndexOf('\r') >= 0)
                    throw new InvalidDataException("Unexpected carriage return.");
                if (source.Contains(Marker) || source.Contains("scomOccupies"))
                {
                    Console.WriteLine("[SCOM transport] Kept existing attachment metadata in " + path + ".");
                    return null;
                }
                const string tech = "                tech = point.tech,";
                return Replace(source, tech, "                scomOccupies = point.scomOccupies,\n" + tech);
            }
            catch (InvalidDataException error)
            {
                Console.WriteLine("[SCOM transport] Skipped " + path + " (" + error.Message + ").");
            }
            catch (DecoderFallbackException)
            {
                Console.WriteLine("[SCOM transport] Skipped " + path + " (unsupported text encoding).");
            }
            return null;
        }

        private static bool IsTemplate(string path)
        {
            var normalized = path.Replace('\\', '/');
            return normalized.Contains("/lua/scom/units/") && normalized.EndsWith("/template.lua", StringComparison.Ordinal);
        }
        private static string UnitId(string path)
        {
            var pieces = path.Replace('\\', '/').Split('/');
            return pieces[pieces.Length - 2];
        }
        private static string Replace(string text, string oldText, string replacement)
        {
            int at=text.IndexOf(oldText,StringComparison.Ordinal);
            if(at<0 || text.IndexOf(oldText,at+oldText.Length,StringComparison.Ordinal)>=0)
                throw new InvalidDataException("Transport consumer contract changed: " + oldText.Substring(0,Math.Min(oldText.Length,100)));
            return text.Substring(0,at)+replacement+text.Substring(at+oldText.Length);
        }
        private static string Function(string source, string name)
        {
            var matches=Regex.Matches(source,"^local function "+name+@"\(",RegexOptions.Multiline);
            if(matches.Count!=1) throw new InvalidDataException("Tractor function contract changed: "+name);
            int start=matches[0].Index;
            var next=Regex.Match(source.Substring(start+matches[0].Length),@"^(?:local )?function ",RegexOptions.Multiline);
            return source.Substring(start,next.Success?matches[0].Length+next.Index:source.Length-start);
        }
    }
}
