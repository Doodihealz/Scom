using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

public static class ReclaimWorkSavings
{
    public static void Apply(string engineRoot, IDictionary<string, byte[]> stock, Dictionary<string, byte[]> result)
    {
        string hostUnits = Path.Combine(engineRoot, "lua", "scom", "gameplay", "host", "units", "unitsClasses", "unitsBaseClass.lua");
        string platoons = Path.Combine(engineRoot, "lua", "AI", "mods", "AI-Scom", "AIPlatoonFunctions.lua");
        var encoding = new UTF8Encoding(false, true);
        string host = encoding.GetString(Read(hostUnits, stock, result));
        host = Replace(host, @"    local entities = __Entities.Props
    local filtered = FilterEntitiesAroundPosition(self:GetPosition(), radius, entities)

    -- this is just picking the first one for now
    if #filtered then
        return filtered[1]
    else
        return nil
    end", @"    local origin = self:GetPosition()
    for _, prop in pairs(__Entities.Props) do
        if math3D.distance(origin, prop:GetPosition()) <= radius then
            return prop
        end
    end
    return nil", "\n", "attack-move reclaim");

        result[hostUnits] = encoding.GetBytes(host);
        OptionalAiSource.Apply(platoons, stock, result, RepairAiReclaim);
    }

    private static string RepairAiReclaim(string ai)
    {
        ai = Replace(ai, @"local function GetReservedMapReclaimTargetPositions(platoon)
    local reclaimTargetPositions = {}
    for _, armyUnit", @"local function GetReservedMapReclaimTargetPositions(platoon)
    local reclaimTargetPositions, positions = {}, {}
    local function append(target)
        local position = positions[target]
        if not position then
            position = target:GetPosition()
            positions[target] = position
        end
        reclaimTargetPositions[#reclaimTargetPositions + 1] = { x = position.x, z = position.z }
    end
    for _, armyUnit", "\n", "reclaim reservation snapshot");
        ai = Replace(ai, @"                local reclaimTargetPosition = reclaimTarget:GetPosition()
                reclaimTargetPositions[#reclaimTargetPositions + 1] = { x = reclaimTargetPosition.x, z = reclaimTargetPosition.z }",
            @"                append(reclaimTarget)", "\n", "assigned reclaim reservations");
        ai = Replace(ai, @"            local position = prop:GetPosition()
            reclaimTargetPositions[#reclaimTargetPositions + 1] = { x = position.x, z = position.z }",
            @"            append(prop)", "\n", "active reclaim reservations");
        ai = Replace(ai, @"        platoon.ai.reclaimTargetPositions = GetReservedMapReclaimTargetPositions(platoon)
        if formerTable.DebugPlatoon then
            AILog(""* Fn planReclaimMap():", @"        local reservationsReady = false
        if formerTable.DebugPlatoon then
            platoon.ai.reclaimTargetPositions = GetReservedMapReclaimTargetPositions(platoon)
            reservationsReady = true
            AILog(""* Fn planReclaimMap():", "\n", "reclaim debug census");
        ai = Replace(ai, @"            elseif IsCompletedMapReclaim(builder) then
                ContinueMapReclaim(builder, platoon, true)
            elseif builder.ai.eState", @"            elseif IsCompletedMapReclaim(builder) then
                ContinueMapReclaim(builder, platoon, true)
                reservationsReady = true
            elseif builder.ai.eState", "\n", "completed reclaim handoff");
        ai = Replace(ai, @"            elseif not builder.ai.eState then
                RushReliability.ApplyBuilderStep(builder, platoon, subPlanSetMapReclaimTarget)",
            @"            elseif not builder.ai.eState then
                -- Only target selection needs the world-unit reservation scan.
                if not reservationsReady then
                    platoon.ai.reclaimTargetPositions = GetReservedMapReclaimTargetPositions(platoon)
                    reservationsReady = true
                end
                RushReliability.ApplyBuilderStep(builder, platoon, subPlanSetMapReclaimTarget)",
            "\n", "idle reclaimer census");

        return ai;
    }

    private static byte[] Read(string path, IDictionary<string, byte[]> stock, Dictionary<string, byte[]> result)
    {
        if (!result.TryGetValue(path, out byte[] bytes) && !stock.TryGetValue(path, out bytes))
            throw new InvalidDataException("Missing SCOM reclaim source " + path);
        return bytes;
    }

    private static string Replace(string source, string before, string after, string newline, string name)
    {
        before = before.Replace("\n", "\n").Replace("\n", newline);
        after = after.Replace("\n", "\n").Replace("\n", newline);
        int start = source.IndexOf(before, StringComparison.Ordinal);
        if (start < 0)
        {
            int patched = source.IndexOf(after, StringComparison.Ordinal);
            if (patched >= 0 && source.IndexOf(after, patched + after.Length, StringComparison.Ordinal) < 0)
                return source;
        }
        if (start < 0 || source.IndexOf(before, start + before.Length, StringComparison.Ordinal) >= 0)
            throw new InvalidDataException("Expected one SCOM source anchor for " + name);
        return source.Substring(0, start) + after + source.Substring(start + before.Length);
    }
}
