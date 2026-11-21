using System;
using System.Collections.Generic;
using UnityEngine;

namespace ScomShatter;

// Compute each cell's first unsupported stage once. Prepare successive strips
// during the impact flash, before the first slab loses support.
internal sealed class NavigationFootprint
{
    internal const int Stages = 8;
    internal readonly List<RectInt>[] Runs = new List<RectInt>[Stages];
    internal readonly HashSet<Vector2Int> Affected = new HashSet<Vector2Int>();
    private readonly FractureLayout layout;
    private readonly Vector3 center;
    private readonly int minX, maxX, endZ, rowsPerTick;
    private int nextZ;

    internal NavigationFootprint(ChasmWorld.Site site)
    {
        layout = site.Layout;
        center = site.Position;
        minX = Mathf.FloorToInt(site.Bounds.xMin);
        maxX = Mathf.CeilToInt(site.Bounds.xMax);
        nextZ = Mathf.FloorToInt(site.Bounds.yMin);
        endZ = Mathf.CeilToInt(site.Bounds.yMax);
        rowsPerTick = Math.Max(1, (endZ - nextZ + 11) / 12);
        for (int i = 0; i < Runs.Length; i++) Runs[i] = new List<RectInt>();
    }

    internal void Prepare(bool finish)
    {
        int stop = finish ? endZ : Math.Min(endZ, nextZ + rowsPerTick);
        for (; nextZ < stop; nextZ++)
        {
            float z = nextZ + .5f - center.z;
            int previous = 0, start = minX;
            for (int x = minX; x < maxX; x++)
            {
                int stage = FirstStage(layout.ToNative(new Vector2(x + .5f - center.x, z)));
                if (stage == previous) continue;
                if (previous != 0) Runs[previous - 1].Add(new RectInt(start, nextZ, x - start, 1));
                previous = stage;
                start = x;
            }
            if (previous != 0) Runs[previous - 1].Add(new RectInt(start, nextZ, maxX - start, 1));
        }
    }

    private int FirstStage(Vector2 native)
    {
        if (!layout.TryAddress(native, out int pixel, out float x, out float z) ||
            CampaignMotion.Final(pixel, x, z) < CampaignMotion.LipDrop) return 0;
        for (int stage = 1; stage < Stages; stage++)
        {
            if (CampaignMotion.OpensDuring(stage, pixel, x, z)) return stage;
        }
        return Stages;
    }
}

// A native nav chunk contains 16 by 16 one-metre cells. Merge its solid bits
// into disjoint rectangles so the engine can test a full chunk as one obstacle.
internal sealed class ChasmBlockers
{
    private readonly ushort[] rows = new ushort[16];

    internal bool Add(int x, int z, int width)
    {
        int bits = ((1 << width) - 1) << x;
        ushort row = (ushort)(rows[z] | bits);
        if (row == rows[z]) return false;
        rows[z] = row;
        return true;
    }

    internal void Rectangles(Vector2Int chunk, HashSet<RectInt> result, ushort[] remaining)
    {
        Array.Copy(rows, remaining, rows.Length);
        for (int z = 0; z < 16; z++)
        {
            int x = 0;
            while (remaining[z] != 0)
            {
                while ((remaining[z] & (1 << x)) == 0) x++;
                int right = x + 1;
                while (right < 16 && (remaining[z] & (1 << right)) != 0) right++;
                int mask = ((1 << (right - x)) - 1) << x;
                int bottom = z;
                while (bottom < 16 && (remaining[bottom] & mask) == mask)
                {
                    remaining[bottom] = (ushort)(remaining[bottom] & ~mask);
                    bottom++;
                }
                result.Add(new RectInt(chunk.x * 16 + x, chunk.y * 16 + z, right - x, bottom - z));
                x = right;
            }
        }
    }
}
