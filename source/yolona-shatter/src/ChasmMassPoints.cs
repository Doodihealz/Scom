using System;
using EM.Lua;
using UnityEngine;

namespace ScomShatter;

internal static class ChasmMassPoints
{
    internal static readonly LuaJIT.lua_CFunction LossTick = ReadLossTick;

    // Only anchors inside the permanent opening are lost. Remove their markers
    // at the first downward motion, before the five-metre navigation cutoff.
    internal static long FirstLossTick(ChasmWorld.Site site, float x, float z)
    {
        if (site == null || !site.Bounds.Contains(new Vector2(x, z))) return -1;
        Vector2 native = site.Layout.ToNative(new Vector2(x - site.Position.x, z - site.Position.z));
        if (!site.Layout.TryAddress(native, out int pixel, out float u, out float v) ||
            CampaignMotion.Final(pixel, u, v) < CampaignMotion.LipDrop) return -1;
        for (int elapsed = 1; elapsed <= ChasmWorld.SettledTicks; elapsed++)
        {
            float progress = CampaignTimeline.Progress(elapsed * .1);
            if (progress <= 0f) continue;
            CampaignMotion.Frame(progress, out int frame, out float blend);
            if (progress >= 1f || CampaignMotion.Drop(frame, blend, pixel, u, v) > 0f)
                return (long)site.ImpactTick + elapsed;
        }
        return -1;
    }

    private static int ReadLossTick(lua_State state)
    {
        long tick = -1;
        try
        {
            if (LuaJIT.lua_gettop(state) == 4)
            {
                for (int i = 1; i <= 4; i++)
                    if (LuaJIT.lua_type(state, i) != LuaJIT.LUA_TNUMBER) { LuaJIT.lua_pushnil(state); return 1; }
                double index = LuaJIT.lua_tonumber(state, 1), version = LuaJIT.lua_tonumber(state, 2);
                float x = (float)LuaJIT.lua_tonumber(state, 3), z = (float)LuaJIT.lua_tonumber(state, 4);
                if (index >= 1 && index <= uint.MaxValue && Math.Floor(index) == index &&
                    version >= 0 && version <= uint.MaxValue && Math.Floor(version) == version &&
                    !float.IsNaN(x) && !float.IsNaN(z) && !float.IsInfinity(x) && !float.IsInfinity(z))
                    tick = FirstLossTick(ChasmWorld.HostImpact((uint)index, (uint)version), x, z);
            }
        }
        catch (Exception error) { Debug.LogError("SCOM chasm mass point lookup failed: " + error); }
        if (tick < 0) LuaJIT.lua_pushnil(state);
        else LuaJIT.lua_pushnumber(state, tick);
        return 1;
    }

    internal const string HostPrelude = @"
local function scoRemoveMapMassMarkers(removed)
    local markers = GameInfo.MapData and GameInfo.MapData.markers
    local alloys = markers and markers.Alloys
    if not alloys or not alloys.transforms then return end
    local survivors, changed = {}, false
    for name, marker in pairs(alloys.transforms) do
        local p = marker.position
        if p and removed[p.x] and removed[p.x][p.z] then changed = true
        else survivors[name] = marker end
    end
    if changed then
        -- The map loader writes snapped world X/Z back into these records.
        -- Publishing a new table also invalidates SCOM's cached marker list.
        alloys.transforms = survivors
        for _, army in pairs(Armies or {}) do
            if army.ai then army.ai.lastAlloyUpdate = nil end
        end
    end
end

local function scoRemoveUnsupportedMass(projectileIndex, projectileVersion)
    local spots = Import(""common/resourceSpot.lua"").resourceSpots
    local pending = {}
    local position = {}
    for index, spot in pairs(spots) do
        if spot.type == 'alloys' then
            local status, p = Engine.GetGlobalEntityWorldPosition(spot.id, position)
            if status == EngineErrorCode.Success and p then
                local tick = Engine.SCOChasmMassLossTick(projectileIndex, projectileVersion, p.x, p.z)
                if tick then
                    pending[#pending + 1] = {tick = tick, index = index, spot = spot, x = p.x, z = p.z}
                end
            end
        end
    end
    table.sort(pending, function(a, b)
        if a.tick == b.tick then return a.index < b.index end
        return a.tick < b.tick
    end)
    local i = 1
    while i <= #pending do
        local due = pending[i].tick
        local remaining = due - Engine.GetSimulationTick()
        if remaining > 0 then WaitTicks(remaining) end
        local removed = {}
        repeat
            local entry = pending[i]
            -- Another impact or a scenario may already have removed this entity
            -- and the engine can reuse its index for a different resource.
            if spots[entry.index] == entry.spot then
                local status, p = Engine.GetGlobalEntityWorldPosition(entry.spot.id, position)
                if status == EngineErrorCode.Success and p and p.x == entry.x and p.z == entry.z then
                    RemoveResourceSpot(entry.spot)
                    local row = removed[entry.x] or {}
                    row[entry.z] = true
                    removed[entry.x] = row
                end
            end
            i = i + 1
        until i > #pending or pending[i].tick ~= due
        if next(removed) then scoRemoveMapMassMarkers(removed) end
    end
end
";
}
