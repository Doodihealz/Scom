using System;
using System.Collections.Generic;
using System.IO;

// Compose after the AI repairs; affects only the imported SCOM profile.
public static class LocalConstructionRoutes
{
    private const string Marker = "-- Nearby construction keeps A* unless the existing movement validator";
    private const string Before = "            path=MG.StraightenPath(path)\n            if not owned() then return false end\n            for _,node in ipairs(path) do";
    private const string After = @"            path=MG.StraightenPath(path)
            -- Nearby construction keeps A* unless the existing movement validator
            -- proves a clear footprint-wide, threat-free direct corridor.
            if not hooks.route and data.movementLayer==""Land""
                and (start.x-entry.position.x)^2+(start.z-entry.position.z)^2<=48^2 then
                local direct=Movement.ShortenPath(platoon,start,path,data.movementLayer,0)
                if #direct==1 then path=direct end
            end
            if not owned() then return false end
            for _,node in ipairs(path) do";

    public static void Apply(string engineRoot, IDictionary<string, byte[]> stock, Dictionary<string, byte[]> result)
    {
        string path = Path.Combine(engineRoot, "lua", "AI", "mods", "AI-Scom", "RushReliability.lua");
        OptionalAiSource.Apply(path, stock, result, Repair);
    }

    private static string Repair(string source)
    {
        if (source.Contains(Marker))
        {
            if (!source.Contains(After) || source.Contains(Before))
                throw new InvalidDataException("Incomplete local construction route repair.");
            return source;
        }
        int start = source.IndexOf(Before, StringComparison.Ordinal);
        if (start < 0 || source.IndexOf(Before, start + Before.Length, StringComparison.Ordinal) >= 0)
            throw new InvalidDataException("Expected one initial SCOM construction queue route anchor.");
        return source.Substring(0, start) + After + source.Substring(start + Before.Length);
    }
}
