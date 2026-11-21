using System;
using System.Collections.Generic;
using UnityEngine;

namespace ScomShatter;

// The RTS movement grid and Unity TerrainCollider have separate backing data.
// Commit the settled contour to TerrainData on Unity's main thread. The game's
// Terrain object is reused between matches, so restore only cells we removed.
internal static class ChasmTerrain
{
    private sealed class Edit
    {
        internal TerrainData Data;
        internal int Resolution;
        internal RectInt Area;
        internal List<int> Removed;
    }

    private static readonly List<Edit> edits = new List<Edit>();

    internal static void Commit(Terrain terrain, ChasmWorld.Site site)
    {
        var data = terrain.terrainData;
        int res = data.holesResolution;
        Vector3 origin = terrain.GetPosition(), size = data.size;
        Rect bounds = site.Bounds;
        float dx = size.x / res, dz = size.z / res;
        int x0 = Mathf.Clamp(Mathf.FloorToInt((bounds.xMin - origin.x) / dx), 0, res);
        int z0 = Mathf.Clamp(Mathf.FloorToInt((bounds.yMin - origin.z) / dz), 0, res);
        int x1 = Mathf.Clamp(Mathf.CeilToInt((bounds.xMax - origin.x) / dx), 0, res);
        int z1 = Mathf.Clamp(Mathf.CeilToInt((bounds.yMax - origin.z) / dz), 0, res);
        if (x1 <= x0 || z1 <= z0) return;
        int width = x1 - x0, height = z1 - z0;
        bool[,] solid = data.GetHoles(x0, z0, width, height);
        var removed = new List<int>();
        // The staged navigation runs already classify these exact world-space
        // cell centres. Other hole resolutions/origins keep the native sampler.
        if (site.SettledRuns != null && size.x == res && size.z == res
            && Aligned(origin.x, res) && Aligned(origin.z, res))
        {
            int worldX = (int)origin.x + x0, worldZ = (int)origin.z + z0;
            foreach (var stage in site.SettledRuns)
            {
                foreach (RectInt run in stage)
                {
                    int left = Math.Max(run.xMin, worldX), right = Math.Min(run.xMax, worldX + width);
                    int top = Math.Max(run.yMin, worldZ), bottom = Math.Min(run.yMax, worldZ + height);
                    for (int z = top - worldZ; z < bottom - worldZ; z++)
                        for (int x = left - worldX; x < right - worldX; x++)
                        {
                            if (!solid[z, x]) continue;
                            solid[z, x] = false;
                            removed.Add(z * width + x);
                        }
                }
            }
        }
        else
        {
            for (int z = 0; z < height; z++)
            {
                float worldZ = origin.z + (z0 + z + .5f) * dz;
                for (int x = 0; x < width; x++)
                {
                    if (!solid[z, x] || !site.Contains(origin.x + (x0 + x + .5f) * dx, worldZ, 1f)) continue;
                    solid[z, x] = false;
                    removed.Add(z * width + x);
                }
            }
        }
        if (removed.Count == 0) return;
        data.SetHoles(x0, z0, solid);
        edits.Add(new Edit { Data = data, Resolution = res, Area = new RectInt(x0, z0, width, height), Removed = removed });
        terrain.Flush();
    }

    // Half-metre centres must also be exactly representable in float, as they
    // were when navigation classified the integer world cells.
    private static bool Aligned(float origin, int resolution) => origin == Math.Floor(origin)
        && origin >= -8388608f && (double)origin + resolution <= 8388608d;

    internal static void Clear()
    {
        for (int i = edits.Count - 1; i >= 0; i--)
        {
            Edit edit = edits[i];
            if (edit.Data == null || edit.Data.holesResolution != edit.Resolution) continue;
            try
            {
                RectInt a = edit.Area;
                var solid = edit.Data.GetHoles(a.x, a.y, a.width, a.height);
                foreach (int cell in edit.Removed) solid[cell / a.width, cell % a.width] = true;
                edit.Data.SetHoles(a.x, a.y, solid);
            }
            catch (Exception error)
            {
                Debug.LogWarning("[SCOM Yolona shatter] Terrain hole cleanup: " + error.Message);
            }
        }
        edits.Clear();
    }
}
