using System;
using System.Collections.Generic;
using System.IO;

public static class AiRepairs
{
    private const string Marker = "-- SCOM native faction AI compatibility 1.0.0";
    private const string ThreeFactionMap = "{\n        [1] = \"EDA\",\n        [2] = \"CHOSEN\",\n        [3] = \"GUARD\"\n    }";
    private const string FourFactionMap = "{\n        [1] = \"EDA\",\n        [2] = \"CHOSEN\",\n        [3] = \"GUARD\",\n        [4] = \"SERAPHIM\"\n    }";
    private const string FactionHelper = @"
local function SCOM_AiFactionIndex(faction)
    if faction == 5 or faction == 6 or faction == 7 then return faction - 4 end
    return faction
end
";
    private const string RosterHelpers = @"
-- Native and imported templates share faction tags but are separate build rosters.
-- Compare actual builders, including captured factories and engineers.
local function SCOM_AiSameRoster(builder, identifier)
    local native, imported = Tags.NATIVE_ONLY, Tags.SCOM_ONLY
    if not native or not imported or not builder or not builder.tpId then return true end
    if native[builder.tpId] then return not imported[identifier] end
    if imported[builder.tpId] then return not native[identifier] end
    return true
end

local function SCOM_AiBuilderRosterCandidate(builders, identifier)
    for _, builder in ipairs(builders or {}) do
        if not builder.dead and builder.factionTag and Tags[builder.factionTag][identifier]
            and SCOM_AiSameRoster(builder, identifier) then return true end
    end
    return false
end

local function SCOM_AiFactoryRosterCandidate(factories, identifier)
    for _, factory in ipairs(factories) do
        if Tags[factory.factionTag][identifier] and SCOM_AiSameRoster(factory, identifier) then return true end
    end
    return false
end
";

    public static void Apply(string engineRoot, IDictionary<string, byte[]> stock, Dictionary<string, byte[]> result)
    {
        string ai = Path.Combine(engineRoot, "lua", "AI");
        string helpers = Path.Combine(ai, "AIFunctions.lua");
        OptionalAiSource.Apply(helpers, stock, result, RepairFactionHelpers);

        string markers = Path.Combine(ai, "AIMarkerGenerator.lua");
        string rush = Path.Combine(ai, "mods", "AI-Sanctuary-Rush", "AIPlatoonFunctions.lua");
        OptionalAiSource.Apply(rush, stock, result, RepairRushSpacing);
        if (OptionalAiSource.TryPrepare(markers, stock, result, RepairMarkers, out var markerBytes))
        {
            result[markers] = markerBytes;
            OptionalAiSource.Apply(rush, stock, result, RepairRaidRange);
        }
        else
        {
            OptionalAiSource.Apply(rush, stock, result, GuardMissingRaidLookup);
        }
    }

    private static string RepairFactionHelpers(string source)
    {
        if (source.Contains(Marker)) throw new InvalidDataException("Unexpected already-modified AI helper input.");
        source = Replace(source, ThreeFactionMap, FourFactionMap, 4, "four shared faction maps");
        source = Replace(source, "({\"EDA\", \"CHOSEN\", \"GUARD\"})[army.faction]", "({\"EDA\", \"CHOSEN\", \"GUARD\", \"SERAPHIM\"})[SCOM_AiFactionIndex(army.faction)]", 1, "opening factory faction map");
        source = Replace(source, "})[army.faction]", "})[SCOM_AiFactionIndex(army.faction)]", 1, "perimeter faction lookup");
        source = Replace(source, "FactionIndexToName[Armies[armyIndex].faction]", "FactionIndexToName[SCOM_AiFactionIndex(Armies[armyIndex].faction)]", 2, "structure faction lookups");
        source = Replace(source, "factionNames[army.faction]", "factionNames[SCOM_AiFactionIndex(army.faction)]", 1, "factory faction lookup");
        source = ReplaceInFunction(source, "CanFactoryBuildFormerUnits", "if AvailableUnits[identifier] then", "if AvailableUnits[identifier] and SCOM_AiSameRoster(factory, identifier) then");
        source = ReplaceInFunction(source, "GetFactoryFormerFactions", "function GetFactoryFormerFactions(armyIndex, baseName, formerTable)", "function GetFactoryFormerFactions(armyIndex, baseName, formerTable, rosterFactories)");
        source = ReplaceInFunction(source, "GetFactoryFormerFactions", "if factory:HasTags(needed[1]) then factions[factory.factionTag] = true; break end", "if factory:HasTags(needed[1]) then\n                        factions[factory.factionTag] = true\n                        if rosterFactories then rosterFactories[#rosterFactories + 1] = factory end\n                        break\n                    end");
        source = ReplaceInFunction(source, "GetWantUnits", "local factions, factionOrder = GetFactoryFormerFactions(armyIndex, baseName, formerTable)", "local rosterFactories = {}\n    local factions, factionOrder = GetFactoryFormerFactions(armyIndex, baseName, formerTable, rosterFactories)");
        source = ReplaceInFunction(source, "GetWantUnits", "if AvailableUnits[tpId] then", "if AvailableUnits[tpId] and SCOM_AiFactoryRosterCandidate(rosterFactories, tpId) then");
        source = ReplaceInFunction(source, "GetWantStructures", "if Tags[factionName][tpId] and AvailableUnits[tpId] and capableBuilder then", "if Tags[factionName][tpId] and AvailableUnits[tpId] and capableBuilder\n                        and SCOM_AiBuilderRosterCandidate(useBuilder, tpId) then");
        // Imported tags include structures without upgrades, such as ucs2401.
        // They cannot contribute an upgrade's maintenance cost.
        source = ReplaceInFunction(source, "CheckEnergyTrendCanCoverMaintenanceConsumption",
            @"                local energyConsumption = UnitTemplates[upgradeUnitTemplateIdentifier].economy.maintenanceConsumption.energy
                local unitName = UnitTemplates[upgradeUnitTemplateIdentifier].general.unitTypeName
                if GetFormerDebugFlag(formerTable) then
                    AILog(""* Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): [A:""..armyIndex..""] upgrade [""..upgradeUnitTemplateIdentifier..""] (""..unitName.."") maintenanceEnergy=""..energyConsumption.."" availableEnergyTrend=""..energyTrend.."" result=""..tostring(energyTrend > energyConsumption))
                end
                if maximumEnergyConsumption < energyConsumption then
                    maximumEnergyConsumption = energyConsumption
                end",
            @"                local upgradeTemplate = upgradeUnitTemplateIdentifier and UnitTemplates[upgradeUnitTemplateIdentifier]
                if upgradeTemplate then
                    local energyConsumption = upgradeTemplate.economy.maintenanceConsumption.energy
                    local unitName = upgradeTemplate.general.unitTypeName
                    if GetFormerDebugFlag(formerTable) then
                        AILog(""* Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): [A:""..armyIndex..""] upgrade [""..upgradeUnitTemplateIdentifier..""] (""..unitName.."") maintenanceEnergy=""..energyConsumption.."" availableEnergyTrend=""..energyTrend.."" result=""..tostring(energyTrend > energyConsumption))
                    end
                    if maximumEnergyConsumption < energyConsumption then
                        maximumEnergyConsumption = energyConsumption
                    end
                end");
        return Marker + "\n" + FactionHelper + RosterHelpers + source;
    }

    private static string RepairMarkers(string markerSource)
    {
        const string originalCache = @"    local markers = GameInfo.MapData.markers and GameInfo.MapData.markers.Alloys
    if not markers then return {} end
    if AlloyFieldMarkers ~= markers then
        if not MarkerGridPresent then return {} end
        local grid = MarkerGrid.Hover
        local groups = CollectAlloyFields(armyIndex, true)
        if not MarkerGridPresent or MarkerGrid.Hover ~= grid then return {} end
        AlloyFieldGroups, AlloyFieldMarkers = groups, markers
    end";
        const string sharedCache = @"    if not EnsureAlloyFieldGroups() then return {} end";
        const string insertionPoint = "---Refresh the available spots without changing Rush's field membership.";
        const string radius = @"    -- Older Rush callers pass true when no engineer-specific range is available.
    local radius = type(searchRadius) == ""number"" and searchRadius or (searchRadius == true and 6 or 0)
    local maximumDistanceSquared = radius^2";
        const string lookup = @"-- Raids and capture use the same stable full-map fields, independent of occupation and army blacklists.
local function EnsureAlloyFieldGroups()
    local markers = GameInfo.MapData.markers and GameInfo.MapData.markers.Alloys
    if not markers or not MarkerGridPresent then return false end
    if AlloyFieldMarkers ~= markers then
        local grid = MarkerGrid.Hover
        local groups = CollectAlloyFields(nil, true)
        if not MarkerGridPresent or MarkerGrid.Hover ~= grid then return false end
        AlloyFieldGroups, AlloyFieldMarkers = groups, markers
    end
    return true
end

---Returns the field containing an extractor spot or the nearest reachable spot inside an engineer's construction range.
---@param position table World position
---@param searchRadius number|nil Construction range; omitted for exact extractor matching
---@return table|nil field Stable field shared with alloy capture
function GetAlloyFieldAtPosition(position, searchRadius)
    if not EnsureAlloyFieldGroups() then return nil end
    local nearestField, nearestDistanceSquared
" + radius + @"
    for _, field in ipairs(AlloyFieldGroups) do
        for _, spot in ipairs(field) do
            local point = spot.position
            local distanceSquared = (position.x - point.x)^2 + (position.z - point.z)^2
            if distanceSquared <= maximumDistanceSquared and (not nearestDistanceSquared or distanceSquared < nearestDistanceSquared)
                and (distanceSquared == 0 or CanGraphAreaTo(position, point, ""Hover"")) then
                nearestField, nearestDistanceSquared = field, distanceSquared
            end
        end
    end
    return nearestField
end

";
        if (markerSource.Contains("function GetAlloyFieldAtPosition("))
        {
            // Accept only the complete helper we shipped, including its field-cache wiring.
            if (markerSource.Contains(originalCache) || !markerSource.Contains(sharedCache))
                throw new InvalidDataException("The marker module supplies a different field cache.");
            string legacyLookup = lookup.Replace(radius, "    local maximumDistanceSquared = (searchRadius or 0)^2");
            if (markerSource.Contains(legacyLookup))
                return Replace(markerSource, legacyLookup, lookup, 1, "legacy raid field lookup");
            return Replace(markerSource, lookup, lookup, 1, "existing raid field lookup");
        }
        markerSource = Replace(markerSource, originalCache, sharedCache, 1, "shared stable alloy field cache");
        return Replace(markerSource, insertionPoint, lookup + insertionPoint, 1, "raid alloy field lookup");
    }

    private static string RepairRushSpacing(string text)
    {
        if (text.Contains(Marker))
            throw new InvalidDataException("The Rush module already contains SCOM faction edits.");
        text = Replace(text, "local factionIndexToName = " + ThreeFactionMap, "local factionIndexToName = " + FourFactionMap, 1, "Rush spacing faction map");
        text = Replace(text, "factionIndexToName[Armies[platoon.army.id].faction]", "factionIndexToName[Armies[platoon.army.id].faction >= 5 and Armies[platoon.army.id].faction <= 7 and Armies[platoon.army.id].faction - 4 or Armies[platoon.army.id].faction]", 1, "Rush spacing faction lookup");
        return Marker + "\n" + text;
    }

    private static string RepairRaidRange(string text)
    {
        const string legacy = "AIMarkerGenerator.GetAlloyFieldAtPosition(position, true)";
        if (!text.Contains(legacy)) return text;
        return ReplaceInFunction(text, "GetAlloyRaidArea", legacy,
            "AIMarkerGenerator.GetAlloyFieldAtPosition(position, target.tp.construction.range or 6)");
    }

    private static string GuardMissingRaidLookup(string text)
    {
        const string lookup = "AIMarkerGenerator.GetAlloyFieldAtPosition";
        const string guard = "if platoon.ai.denyAlloyFields and type(" + lookup + ") == \"function\" then";
        if (!text.Contains(lookup + "(") || text.Contains(guard)) return text;
        return ReplaceInFunction(text, "GetAlloyRaidArea", "if platoon.ai.denyAlloyFields then", guard);
    }

    private static string ReplaceInFunction(string source, string function, string before, string after)
    {
        string anchor = "\nfunction " + function + "(";
        int start = source.IndexOf(anchor, StringComparison.Ordinal);
        if (start < 0 || source.IndexOf(anchor, start + anchor.Length, StringComparison.Ordinal) >= 0)
            throw new InvalidDataException("Expected one AI function " + function);
        int end = source.IndexOf("\nfunction ", start + anchor.Length, StringComparison.Ordinal);
        if (end < 0) end = source.Length;
        string block = source.Substring(start, end - start);
        return source.Substring(0, start) + Replace(block, before, after, 1, function) + source.Substring(end);
    }

    private static string Replace(string source, string before, string after, int expected, string description)
    {
        int count = 0, cursor = 0;
        while ((cursor = source.IndexOf(before, cursor, StringComparison.Ordinal)) >= 0) { count++; cursor += before.Length; }
        if (count != expected) throw new InvalidDataException("AI compatibility anchor changed: " + description + "; expected " + expected + ", found " + count);
        return source.Replace(before, after);
    }
}
