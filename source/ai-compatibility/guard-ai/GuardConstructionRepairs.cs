using System;
using System.Collections.Generic;
using System.IO;

// Runs after AiRepairs; preserves the stock profile's construction policy.
public static class GuardConstructionRepairs
{
    private const string Marker = "-- SCOM assigned construction crew compatibility 1.0.0";
    private const string BuildBefore = "local assignedBuilderOverride = (formerTable.UseAssignedBuildersForWantStructures or formerTable.UseStoredSurplusBuildBudget or formerTable.BuildNavalSupportStructure or Armies[armyIndex].ai.bases[baseName].baseType == \"NAVAL\") and platoon:GetUnits() or nil";
    private const string BuildAfter = "local assignedBuilderOverride = platoon:GetUnits()";
    private const string CaptureBefore = "AIFunctions.GetWantStructures(armyIndex, baseName, formerTable, formerTable.AIPlanData.UseTransport and platoon:GetUnits() or nil, maxUnits)";
    private const string CaptureAfter = "AIFunctions.GetWantStructures(armyIndex, baseName, formerTable, platoon:GetUnits(), maxUnits)";
    private const string ExpansionBefore = "local unitBuildList = AIFunctions.GetWantStructures(armyIndex, baseName, formerTable)";
    private const string ExpansionAfter = "local unitBuildList = AIFunctions.GetWantStructures(armyIndex, baseName, formerTable, platoon:GetUnits(), maxUnits)";

    public static void Apply(string engineRoot, IDictionary<string, byte[]> stock, Dictionary<string, byte[]> result)
    {
        string path = Path.Combine(engineRoot, "lua", "AI", "mods", "AI-Sanctuary-Rush", "AIPlatoonFunctions.lua");
        // This edit builds specifically on the Rush module published by AiRepairs.
        if (result.ContainsKey(path))
            OptionalAiSource.Apply(path, stock, result, Repair);
    }

    private static string Repair(string source)
    {
        if (!source.Contains("-- SCOM native faction AI compatibility 1.0.0")) throw new InvalidDataException("Assigned construction crew repair requires AiRepairs first.");
        if (source.Contains(Marker))
        {
            ValidatePatched(source);
            return source;
        }
        source = Replace(source, BuildBefore, BuildAfter, "engineer construction crew");
        source = Replace(source, CaptureBefore, CaptureAfter, "alloy capture crew");
        source = Replace(source, ExpansionBefore, ExpansionAfter, "expansion construction crew");
        source = Marker + "\n" + source;
        ValidatePatched(source);
        return source;
    }

    private static string Replace(string source, string before, string after, string description)
    {
        int start = source.IndexOf(before, StringComparison.Ordinal);
        if (start < 0 || source.IndexOf(before, start + before.Length, StringComparison.Ordinal) >= 0)
            throw new InvalidDataException("Assigned construction crew anchor changed: " + description);
        return source.Substring(0, start) + after + source.Substring(start + before.Length);
    }

    private static void ValidatePatched(string source)
    {
        if (source.Contains(BuildBefore) || source.Contains(CaptureBefore) || source.Contains(ExpansionBefore)
            || !source.Contains(BuildAfter) || !source.Contains(CaptureAfter) || !source.Contains(ExpansionAfter))
            throw new InvalidDataException("Assigned construction crew repair is incomplete.");
    }
}
