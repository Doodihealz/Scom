using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

namespace SupComStyleUI;

internal sealed class CatalogUnit
{
    public string Id;
    public string Name;
    public string Faction;
    public string Tier;
    public HashSet<string> Tags;
    public string[] RequiredProducts;
    public string SearchText;
}

internal sealed class RestrictionGroup
{
    public string Key;
    public string Label;
    public string Section;
    public HashSet<string> UnitIds;
}

internal sealed class UnitCatalog
{
    private static readonly Regex Identifier = new Regex("^[a-z][a-z0-9_]{1,63}$", RegexOptions.CultureInvariant);
    private static readonly Regex TagsBlock = new Regex("\\[\"tags\"\\]\\s*=\\s*\\{([^}]*)\\}", RegexOptions.Singleline);
    private static readonly Regex TagValue = new Regex("\\[\\d+\\]\\s*=\\s*\"([A-Z0-9_]+)\"");
    private static readonly Regex DisplayName = new Regex("\\[\"displayName\"\\]\\s*=\\s*\"((?:[^\"\\\\]|\\\\.)*)\"");
    public readonly List<CatalogUnit> Units = new List<CatalogUnit>();
    public readonly List<RestrictionGroup> Groups = new List<RestrictionGroup>();
    public readonly HashSet<string> Ids = new HashSet<string>(StringComparer.Ordinal);

    public static UnitCatalog Load(string unitDirectory, string customGroups)
    {
        if (!Directory.Exists(unitDirectory)) throw new DirectoryNotFoundException("SCOM units folder was not found: " + unitDirectory);
        var catalog = new UnitCatalog();
        var directories = Directory.GetDirectories(unitDirectory);
        if (directories.Length > 4096) throw new InvalidDataException("SCOM unit count exceeds 4096.");
        foreach (var directory in directories.OrderBy(p => p, StringComparer.Ordinal))
        {
            string id = Path.GetFileName(directory).ToLowerInvariant();
            string path = Path.Combine(directory, "template.lua");
            if (!File.Exists(path)) continue;
            if (!Identifier.IsMatch(id)) throw new InvalidDataException("Invalid unit ID: " + id);
            if (new FileInfo(path).Length > 2 * 1024 * 1024) throw new InvalidDataException("Unit template is too large: " + id);
            string source = File.ReadAllText(path);
            Match block = TagsBlock.Match(source);
            if (!block.Success) throw new InvalidDataException("Unit has no readable tag list: " + id);
            var tags = new HashSet<string>(TagValue.Matches(block.Groups[1].Value).Cast<Match>().Select(m => m.Groups[1].Value), StringComparer.Ordinal);
            Match name = DisplayName.Match(source);
            var unit = new CatalogUnit
            {
                Id = id,
                Name = name.Success ? name.Groups[1].Value.Replace("\\\"", "\"").Replace("\\\\", "\\") : id,
                Tags = tags,
                RequiredProducts = ReadRequiredProducts(source),
                Faction = tags.Contains("SCFA_UEF") ? "UEF" : tags.Contains("SCFA_AEON") ? "Aeon" : tags.Contains("SCFA_CYBRAN") ? "Cybran" : tags.Contains("SCFA_SERAPHIM") ? "Seraphim" : "Other",
                Tier = ReadTier(tags)
            };
            unit.SearchText = (unit.Id + " " + unit.Name + " " + unit.Faction + " " + unit.Tier + " " + string.Join(" ", tags)).ToLowerInvariant();
            catalog.Units.Add(unit);
            catalog.Ids.Add(id);
        }
        if (catalog.Units.Count == 0) throw new InvalidDataException("No SCOM unit definitions were found.");
        catalog.Units.Sort((a, b) => { int order = string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase); return order != 0 ? order : string.CompareOrdinal(a.Id, b.Id); });
        catalog.AddTier("t1", "No T1", "T1");
        catalog.AddTier("t2", "No T2", "T2");
        catalog.AddTier("t3", "No T3", "T3");
        catalog.AddTier("experimental", "No experimentals", "Experimental");
        catalog.Add("nukes", "No nukes", "Weapons", "NUKE", "SCFA_NUKE");
        catalog.Add("tactical", "No tactical missiles", "Weapons", "SCFA_TACTICALMISSILEPLATFORM");
        catalog.Add("artillery", "No artillery", "Weapons", "ARTILLERY", "SCFA_ARTILLERY");
        catalog.Add("antiair", "No anti-air", "Weapons", "ANTI_AIR", "SCFA_ANTIAIR");
        catalog.Add("antimissile", "No missile defence", "Weapons", "ANTI_PROJECTILE", "SCFA_ANTIMISSILE");
        catalog.Add("air", "No air units", "Unit types", "AIR", "SCFA_AIR");
        catalog.Add("land", "No land units / buildings", "Unit types", "LAND", "SCFA_LAND");
        catalog.Add("naval", "No naval units", "Unit types", "NAVAL", "SCFA_NAVAL");
        catalog.Add("bomber", "No bombers", "Unit types", "BOMBER", "SCFA_BOMBER", "TORPEDO_BOMBER");
        catalog.Add("gunship", "No gunships", "Unit types", "GUNSHIP", "SCFA_GROUNDATTACK");
        catalog.Add("transport", "No transports", "Unit types", "TRANSPORT", "SCFA_TRANSPORTATION");
        catalog.Add("submarines", "No submarines", "Unit types", "SUBMARINE", "SCFA_SUBMERSIBLE");
        catalog.Add("amphibious", "No amphibious / hover", "Unit types", "AMPHIBIOUS", "HOVER", "SCFA_HOVER");
        catalog.Add("support", "No support commanders", "Unit types", "SCFA_SUBCOMMANDER");
        catalog.Add("orbital", "No orbital units", "Unit types", "SCFA_SATELLITE", "SCFA_ORBITALSYSTEM");
        catalog.Add("engineer", "No engineers", "Construction", "ENGINEER", "SCFA_ENGINEER");
        catalog.Add("station", "No engineering stations", "Construction", "ENGINEERING_STATION", "SCFA_ENGINEERSTATION");
        catalog.Add("factory", "No factories", "Construction", "FACTORY", "SCFA_FACTORY");
        catalog.Add("structures", "No structures", "Construction", "STRUCTURE");
        catalog.Add("defence", "No static defence", "Construction", "DEFENCE", "SCFA_DEFENSE");
        catalog.Groups.Last().UnitIds.RemoveWhere(id => !catalog.Units.First(u => u.Id == id).Tags.Contains("STRUCTURE"));
        catalog.Add("walls", "No walls", "Construction", "WALL", "SCFA_WALL");
        catalog.Add("shields", "No shields", "Support", "SHIELD", "SCFA_SHIELD");
        catalog.Add("intel", "No intelligence units", "Support", "INTEL", "SCFA_INTELLIGENCE");
        catalog.Add("radar", "No radar / sonar", "Support", "RADAR", "SONAR", "SCFA_RADAR", "SCFA_SONAR", "SCFA_OMNI");
        catalog.Add("stealth", "No counterintelligence", "Support", "STEALTH_FIELD", "SCFA_COUNTERINTELLIGENCE");
        catalog.Add("scouts", "No scouts", "Support", "SCOUT", "SCFA_SCOUT");
        catalog.Add("massfabs", "No mass fabricators", "Economy", "SCFA_MASSFABRICATION");
        catalog.Add("extractors", "No mass extractors", "Economy", "ALLOYS_EXTRACTION", "SCFA_MASSEXTRACTION");
        catalog.Add("power", "No power generators", "Economy", "ENERGY_PRODUCTION", "SCFA_ENERGYPRODUCTION");
        catalog.Add("storage", "No resource storage", "Economy", "ENERGY_STORAGE", "SCFA_MASSSTORAGE", "SCFA_ENERGYSTORAGE");
        catalog.Add("uef", "No UEF", "Factions", "SCFA_UEF");
        catalog.Add("aeon", "No Aeon", "Factions", "SCFA_AEON");
        catalog.Add("cybran", "No Cybran", "Factions", "SCFA_CYBRAN");
        catalog.Add("seraphim", "No Seraphim", "Factions", "SCFA_SERAPHIM");
        catalog.Add("civilian", "No civilian units", "Other", "CIVILIAN", "SCFA_CIVILIAN");
        catalog.AddCustomGroups(customGroups ?? "");
        return catalog;
    }

    private void Add(string key, string label, string section, params string[] tags)
    {
        var ids = new HashSet<string>(Units.Where(u => tags.Any(t => u.Tags.Contains(t))).Select(u => u.Id), StringComparer.Ordinal);
        Groups.Add(new RestrictionGroup { Key = key, Label = label, Section = section, UnitIds = ids });
    }

    // These units create their product directly, rather than through a factory queue.
    // Read the editable metadata so changing an egg/product keeps the restriction linked.
    private static string[] ReadRequiredProducts(string source)
    {
        var products = new HashSet<string>(StringComparer.Ordinal);
        string egg = ReadTable(source, "megalithEgg");
        string product = ReadString(egg, "product");
        if (Identifier.IsMatch(product)) products.Add(product);
        string special = ReadTable(source, "scoSpecial");
        if (ReadString(special, "kind") == "novaxLauncher")
        {
            product = ReadString(special, "child");
            if (Identifier.IsMatch(product)) products.Add(product);
        }
        string pods = ReadTable(source, "scoSourcePods");
        if (ReadString(pods, "kind") == "tower")
            foreach (Match match in Regex.Matches(pods, "\\[\"template\"\\]\\s*=\\s*\"([a-z][a-z0-9_]{1,63})\""))
                products.Add(match.Groups[1].Value);
        return products.OrderBy(id => id, StringComparer.Ordinal).ToArray();
    }

    private static string ReadString(string source, string key) =>
        Regex.Match(source, "\\[\"" + Regex.Escape(key) + "\"\\]\\s*=\\s*\"([^\"]*)\"").Groups[1].Value;

    private static string ReadTable(string source, string key)
    {
        var start = Regex.Match(source, "\\[\"" + Regex.Escape(key) + "\"\\]\\s*=\\s*\\{");
        if (!start.Success) return "";
        int depth = 1, content = start.Index + start.Length;
        char quote = '\0';
        for (int i = content; i < source.Length; i++)
        {
            char c = source[i];
            if (quote != '\0')
            {
                if (c == '\\') i++;
                else if (c == quote) quote = '\0';
            }
            else if (c == '\"' || c == '\'') quote = c;
            else if (c == '-' && i + 1 < source.Length && source[i + 1] == '-')
            {
                int end = source.IndexOf('\n', i);
                if (end < 0) break;
                i = end;
            }
            else if (c == '{') depth++;
            else if (c == '}' && --depth == 0) return source.Substring(content, i - content);
        }
        throw new InvalidDataException("Unclosed unit metadata table: " + key);
    }

    private static string ReadTier(HashSet<string> tags)
    {
        if (tags.Contains("TECH4") || tags.Contains("EXPERIMENTAL") || tags.Contains("SCFA_EXPERIMENTAL")) return "Experimental";
        foreach (int tier in new[] { 3, 2, 1 }) if (tags.Contains("TECH" + tier)) return "T" + tier;
        foreach (int tier in new[] { 3, 2, 1 }) if (tags.Contains("SCFA_TECH" + tier)) return "T" + tier;
        return "Special";
    }

    private void AddTier(string key, string label, string tier)
    {
        Groups.Add(new RestrictionGroup { Key = key, Label = label, Section = "Technology", UnitIds = new HashSet<string>(Units.Where(u => u.Tier == tier).Select(u => u.Id), StringComparer.Ordinal) });
    }

    private void AddCustomGroups(string definition)
    {
        if (definition.Length > 8192) throw new InvalidDataException("Custom groups exceed 8192 characters.");
        var entries = definition.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries);
        if (entries.Length > 32) throw new InvalidDataException("At most 32 custom groups are supported.");
        foreach (string entry in entries)
        {
            int split = entry.IndexOf(':');
            if (split < 1) throw new InvalidDataException("Custom groups use Label:TAG|TAG or Label:unit_id.");
            string label = entry.Substring(0, split).Trim();
            string[] selectors = entry.Substring(split + 1).Split('|').Select(v => v.Trim()).ToArray();
            if (label.Length == 0 || label.Length > 48 || selectors.Length > 32 || selectors.Any(s => !Regex.IsMatch(s, "^[a-zA-Z0-9_]{1,64}$")))
                throw new InvalidDataException("Invalid custom restriction group: " + label);
            if (Groups.Any(g => g.Key == "custom:" + label)) throw new InvalidDataException("Duplicate custom group: " + label);
            foreach (string selector in selectors)
                if (!Ids.Contains(selector) && !Units.Any(u => u.Tags.Contains(selector)))
                    throw new InvalidDataException("Unknown custom group tag or unit ID: " + selector);
            Groups.Add(new RestrictionGroup { Key = "custom:" + label, Label = label, Section = "Custom", UnitIds = new HashSet<string>(Units.Where(u => selectors.Any(s => u.Id == s || u.Tags.Contains(s))).Select(u => u.Id), StringComparer.Ordinal) });
        }
    }

    public HashSet<string> Resolve(IEnumerable<string> groups, IEnumerable<string> individual)
    {
        var result = new HashSet<string>(individual.Where(Ids.Contains), StringComparer.Ordinal);
        var selected = new HashSet<string>(groups, StringComparer.Ordinal);
        foreach (var group in Groups) if (selected.Contains(group.Key)) result.UnionWith(group.UnitIds);
        bool expanded;
        do
        {
            expanded = false;
            foreach (var unit in Units)
                if (!result.Contains(unit.Id) && unit.RequiredProducts.Any(result.Contains))
                    expanded |= result.Add(unit.Id);
        } while (expanded);
        return result;
    }
}
