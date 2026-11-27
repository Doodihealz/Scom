using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Reflection;
using System.Runtime.Loader;
using System.Text;

// Exercises the real complete composition pipeline without touching the installed engine.
internal static class VerifyAiDrift
{
    private static string engine, mod;
    private static int passed, failed;
    private static readonly string[] Targets = {
        "AI/AIFunctions.lua", "AI/AIMarkerGenerator.lua",
        "AI/mods/AI-Sanctuary-Rush/AIPlatoonFunctions.lua",
        "AI/mods/AI-Scom/RushReliability.lua", "AI/mods/AI-Scom/AIPlatoonFunctions.lua",
        "AI/AITransport.lua"
    };
    private static string Key(string route) => Path.Combine(engine, "lua", route.Replace('/', Path.DirectorySeparatorChar));
    private static bool Ai(string path) => path.StartsWith(Key("AI/"), StringComparison.Ordinal);
    private static Dictionary<string, byte[]> Clone(Dictionary<string, byte[]> data) => new(data, StringComparer.Ordinal);
    private static void Require(bool condition, string detail) { if (!condition) throw new Exception(detail); }
    private static void Case(string name, Action test)
    {
        try { test(); ++passed; Console.WriteLine("PASS " + name); }
        catch (Exception e) { ++failed; Console.WriteLine("FAIL " + name + ": " + e.Message); }
    }
    private static Func<Dictionary<string, byte[]>, Dictionary<string, byte[]>> Composer(string dll)
    {
        var context = new AssemblyLoadContext(Path.GetFileName(dll), true);
        var assembly = context.LoadFromAssemblyPath(Path.GetFullPath(dll));
        if (assembly.GetType("Scom.Playtest26880003.LuaTransplant") == null) {
            using var resource = assembly.GetManifestResourceStream("SCOM.Playtest.Runtime.dll");
            if (resource == null) throw new InvalidDataException("Missing embedded runtime");
            using var buffer = new MemoryStream(); resource.CopyTo(buffer); buffer.Position = 0;
            assembly = context.LoadFromStream(buffer);
        }
        var method = assembly.GetType("Scom.Playtest26880003.LuaTransplant", true).GetMethod("ComposeGameplay");
        return input => {
            try { return (Dictionary<string, byte[]>)method.Invoke(null, new object[] {engine, mod, input}); }
            catch (TargetInvocationException e) { throw e.InnerException ?? e; }
        };
    }
    private static byte[] Effective(Dictionary<string, byte[]> input, Dictionary<string, byte[]> output, string path)
        => output.TryGetValue(path, out var bytes) ? bytes : input.TryGetValue(path, out bytes) ? bytes : null;
    private static void Same(byte[] expected, byte[] actual, string message)
        => Require(expected == null ? actual == null : actual != null && expected.SequenceEqual(actual), message);
    private static void Core(Dictionary<string, byte[]> baseline, Dictionary<string, byte[]> actual)
    {
        var expectedKeys = baseline.Keys.Where(k => !Ai(k)).OrderBy(k => k).ToArray();
        Require(expectedKeys.SequenceEqual(actual.Keys.Where(k => !Ai(k)).OrderBy(k => k)), "non-AI output keys changed");
        foreach (var key in expectedKeys) Same(baseline[key], actual[key], "non-AI bytes changed: " + key);
        foreach (var side in new[] {"host", "client"}) {
            string route = "scom/gameplay/" + side + "/units/unitsClasses/unitsDefault.lua";
            Require(actual.ContainsKey(Key(route)), side + " commander class unavailable");
            Require(Encoding.UTF8.GetString(actual[Key(route)]).Contains(side == "host" ? "HostCommander" : "ClientCommander"), side + " UEF commander extension missing");
            string commander = "scom/units/uel0000/" + side + ".lua";
            Require(actual.ContainsKey(Key(commander)), side + " UEF commander module unavailable");
            Require(Encoding.UTF8.GetString(actual[Key("common/commonFunctions.lua")]).Contains("scom/units/"), "commander class routing missing");
        }
        Require(Encoding.UTF8.GetString(actual[Key("scom/units/index.lua")]).Contains("uel0000"), "commander registration missing");
    }
    public static int Main(string[] args)
    {
        if (args.Length != 4) throw new ArgumentException("ENGINE MOD BASELINE_DLL CANDIDATE_DLL");
        engine = Path.GetFullPath(args[0]); mod = Path.GetFullPath(args[1]);
        var stock = Directory.EnumerateFiles(Path.Combine(engine, "lua"), "*.lua", SearchOption.AllDirectories)
            .ToDictionary(p => p, File.ReadAllBytes, StringComparer.Ordinal);
        var oldCompose = Composer(args[2]); var compose = Composer(args[3]);
        Dictionary<string, byte[]> baseline = oldCompose(stock), current = compose(stock);
        Case("known fixture byte-identical complete cache", () => {
            Require(baseline.Count == current.Count, "output count changed");
            foreach (var item in baseline) { Require(current.ContainsKey(item.Key), "missing output " + item.Key); if (item.Key != Key("AI/AIMarkerGenerator.lua") && item.Key != Key("common/units/transportAttachments.lua")) Same(item.Value, current[item.Key], "baseline bytes changed " + item.Key); }
            Core(current, current);
        });
        foreach (var route in Targets) {
            string key = Key(route); Require(stock.ContainsKey(key), "fixture missing " + route);
            foreach (var mutation in new[] {"missing", "edited", "ambiguous", "invalid-UTF8", "bare-CR", "replayed", "compatible-comment"}) {
                Case(route + " " + mutation, () => {
                    var input = Clone(stock);
                    if (mutation == "missing") input.Remove(key);
                    else if (mutation == "edited") input[key] = Encoding.UTF8.GetBytes("-- unrelated independent AI implementation\nreturn {}\n");
                    else if (mutation == "ambiguous") input[key] = stock[key].Concat(stock[key]).ToArray();
                    else if (mutation == "invalid-UTF8") input[key] = new byte[] {0xff, 0xfe, 0x80};
                    else if (mutation == "bare-CR") input[key] = Encoding.UTF8.GetBytes("-- unsupported\rreturn {}\n");
                    else if (mutation == "replayed") input[key] = Effective(stock, current, key);
                    else input[key] = stock[key].Concat(Encoding.UTF8.GetBytes("\r\n-- independent compatibility fixture\r\n")).ToArray();
                    var output = compose(input); Core(current, output);
                    if (mutation == "compatible-comment") Require(Encoding.UTF8.GetString(Effective(input, output, key)).Contains("-- independent compatibility fixture"), "compatible independent comment lost");
                    else if (mutation != "replayed") Same(input.TryGetValue(key, out var expected) ? expected : null,
                        Effective(input, output, key), "unsupported AI input was overwritten");
                    else Same(input[key], Effective(input, output, key), "replayed bytes changed");
                });
            }
        }
        Case("helper drift preserves independent marker and Rush repairs", () => {
            var input = Clone(stock); input.Remove(Key(Targets[0])); var output = compose(input);
            foreach (var route in new[] {Targets[1], Targets[2]}) Same(current[Key(route)], Effective(input, output, Key(route)), "independent repair lost: " + route);
        });
        Case("marker drift preserves independent helper repair", () => {
            var input = Clone(stock); input[Key(Targets[1])] = new byte[] {0xff}; var output = compose(input);
            Same(current[Key(Targets[0])], Effective(input, output, Key(Targets[0])), "helper repair lost");
        });
        foreach (var missingMarker in new[] {false, true})
            Case("unsupported marker keeps Rush spacing, legacy true range and native field fallback " + (missingMarker ? "missing" : "edited"), () => {
                var input = Clone(stock); string markerKey = Key(Targets[1]); string rushKey = Key(Targets[2]);
                if (missingMarker) input.Remove(markerKey); else input[markerKey] = Encoding.UTF8.GetBytes("-- independent marker provider\nreturn {}\n");
                var output = compose(input); Core(current, output);
                string rush = Encoding.UTF8.GetString(Effective(input, output, rushKey));
                Require(rush.Contains("factionIndexToName[Armies[platoon.army.id].faction >= 5"), "independent Rush spacing missing");
                Require(rush.Contains("AIMarkerGenerator.GetAlloyFieldAtPosition(position, true)"), "unsupported marker received numeric range migration");
                Require(rush.Contains("if platoon.ai.denyAlloyFields and type(AIMarkerGenerator.GetAlloyFieldAtPosition) == \"function\" then"), "missing lookup is unguarded");
                Require(rush.Contains("return field and field.id or math.floor(position.x / areaSize)..\":\"..math.floor(position.z / areaSize), field"), "native area-grid fallback lost");
                Same(input.TryGetValue(markerKey, out var bytes) ? bytes : null, Effective(input, output, markerKey), "unsupported marker provider overwritten");
            });
        Case("known previous marker helper migrates safely on replay", () => {
            var input = Clone(stock); string key = Key(Targets[1]); input[key] = baseline[key];
            var output = compose(input); Core(current, output);
            Same(current[key], Effective(input, output, key), "known prior marker helper was not upgraded");
            Require(Encoding.UTF8.GetString(output[key]).Contains("searchRadius == true and 6 or 0"), "boolean compatibility missing");
        });
        Case("unsupported Rush spacing does not block independent marker repair", () => {
            var input = Clone(stock); string key = Key(Targets[2]); input[key] = Encoding.UTF8.GetBytes("-- independent Rush profile\nreturn {}\n");
            var output = compose(input); Core(current, output);
            Same(current[Key(Targets[1])], Effective(input, output, Key(Targets[1])), "independent marker repair lost");
            Same(input[key], Effective(input, output, key), "independent Rush profile overwritten");
        });
        Case("later Rush guard failure preserves successful earlier faction repair", () => {
            var input = Clone(stock); string key = Key(Targets[2]);
            string text = Encoding.UTF8.GetString(input[key]);
            string anchor = "local assignedBuilderOverride = (formerTable.UseAssignedBuildersForWantStructures";
            Require(text.Contains(anchor), "guard fixture missing");
            input[key] = Encoding.UTF8.GetBytes(text.Replace(anchor, "local independentBuilderOverride = (formerTable.UseAssignedBuildersForWantStructures"));
            bool oldFailed = false; try { oldCompose(input); } catch { oldFailed = true; }
            Require(oldFailed, "old release did not reproduce strict crew-anchor failure");
            var output = compose(input); Core(current, output);
            string composed = Encoding.UTF8.GetString(Effective(input, output, key));
            Require(composed.Contains("-- SCOM native faction AI compatibility 1.0.0"), "earlier faction repair lost");
            Require(!composed.Contains("-- SCOM assigned construction crew compatibility 1.0.0"), "failed guard stage partially published");
        });
        Case("mixed drift keeps core", () => {
            var input = Clone(stock); input.Remove(Key(Targets[0])); input[Key(Targets[1])] = new byte[] {0xff};
            input[Key(Targets[2])] = stock[Key(Targets[2])].Concat(stock[Key(Targets[2])]).ToArray();
            input[Key(Targets[3])] = Encoding.UTF8.GetBytes("return {}\n");
            input[Key(Targets[4])] = new byte[] {0xff}; input.Remove(Key(Targets[5])); Core(current, compose(input));
        });
        Case("all AI files absent keeps core", () => { var input = Clone(stock); foreach (var key in input.Keys.Where(Ai).ToArray()) input.Remove(key); Core(current, compose(input)); });
        Case("non-AI required gameplay module remains strict", () => {
            var input = Clone(stock); input.Remove(Key("host/units/unitsClasses/unitsBaseClass.lua"));
            bool threw = false; try { compose(input); } catch (InvalidDataException) { threw = true; } catch (KeyNotFoundException) { threw = true; }
            Require(threw, "required non-AI missing input did not throw");
        });
        Case("non-AI collision anchor drift remains strict", () => {
            var input = Clone(stock); string key = Key("host/collisionUpdate.lua");
            string text = Encoding.UTF8.GetString(input[key]);
            const string anchor = "local function GetDamageThroughShields(";
            Require(text.Contains(anchor), "core collision fixture missing");
            input[key] = Encoding.UTF8.GetBytes(text.Replace(anchor, "local function DriftedDamageThroughShields("));
            bool threw = false; try { compose(input); } catch (InvalidDataException) { threw = true; }
            Require(threw, "required non-AI anchor drift did not throw");
        });
        Case("prior independent result survives unsupported AI stage", () => {
            var context = new AssemblyLoadContext("direct-stage", true); var assembly = context.LoadFromAssemblyPath(Path.GetFullPath(args[3]));
            if (assembly.GetType("AiRepairs") == null) {
                using var resource = assembly.GetManifestResourceStream("SCOM.Playtest.Runtime.dll");
                using var buffer = new MemoryStream(); resource.CopyTo(buffer); buffer.Position = 0; assembly = context.LoadFromStream(buffer);
            }
            var apply = assembly.GetType("AiRepairs", true).GetMethod("Apply");
            var input = Clone(stock); input[Key(Targets[0])] = new byte[] {0xff};
            var sentinel = Encoding.UTF8.GetBytes("-- previous independent composition\n");
            var result = new Dictionary<string, byte[]> { [Key(Targets[0])] = sentinel };
            apply.Invoke(null, new object[] {engine, input, result}); Same(sentinel, result[Key(Targets[0])], "prior stage bytes lost");
        });
        foreach (var profile in new[] {("CompetitiveProfile", "SCOM.CompetitiveAi.profile.zip"), ("Scom.CompetitiveAI.StrategicProfile", "SCOM.AI.Strategy.zip")})
            Case(profile.Item1 + " preserves drift skip", () => {
                var context = new AssemblyLoadContext(profile.Item1, true);
                var assembly = context.LoadFromAssemblyPath(Path.GetFullPath(args[3]));
                if (assembly.GetType(profile.Item1) == null) {
                    using var embedded = assembly.GetManifestResourceStream("SCOM.Playtest.Runtime.dll");
                    using var buffer = new MemoryStream(); embedded.CopyTo(buffer); buffer.Position = 0; assembly = context.LoadFromStream(buffer);
                }
                using var resource = assembly.GetManifestResourceStream(profile.Item2);
                using var archive = new ZipArchive(resource);
                using var manifest = new StreamReader(archive.GetEntry("sources.tsv").Open());
                string first = manifest.ReadLine().Split('\t')[0];
                var input = Clone(stock); string key = Key("AI/mods/AI-Scom/" + first);
                input[key] = Encoding.UTF8.GetBytes("-- locally edited optional profile\nreturn {}\n");
                var sentinel = Encoding.UTF8.GetBytes("previous independent bytes");
                var output = new Dictionary<string, byte[]> { [Key("test-independent.lua")] = sentinel };
                assembly.GetType(profile.Item1, true).GetMethod("Apply").Invoke(null, new object[] {engine, input, output});
                Require(output.Count == 1, "drifted optional profile published output");
                Same(sentinel, output[Key("test-independent.lua")], "optional skip lost prior independent result");
            });
        Case("missing legacy raid call remains supported", () => {
            var input = Clone(stock); string key = Key(Targets[2]);
            string text = Encoding.UTF8.GetString(input[key]);
            const string call = "AIMarkerGenerator.GetAlloyFieldAtPosition(position, true)";
            Require(text.Contains(call), "regression fixture call absent");
            input[key] = Encoding.UTF8.GetBytes(text.Replace(call, "nil -- drifted raid API"));
            Core(current, compose(input));
        });
        Console.WriteLine($"RESULT {passed} passed, {failed} failed"); return failed == 0 ? 0 : 1;
    }
}
