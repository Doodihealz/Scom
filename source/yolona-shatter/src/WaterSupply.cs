using System;
using System.Collections.Generic;
using UnityEngine;

namespace ScomShatter;

// Original map heights, before the visual slabs fall. A private regional copy
// keeps inlet tests on managed memory and retains the native heightmap cells.
internal sealed class WaterSupply
{
    internal const float MinimumHead = .035f;
    private const float MinimumArea = 2f;
    private readonly float[,] heights;
    private readonly int[] components;
    private readonly bool[] supplied;
    private readonly Vector2 origin, spacing;
    private readonly float level;
    private readonly int columns, rows;
    internal bool HasSupply { get; }
    internal float WorldLevel => level;

    // A level change can expose the original beach. Reclassify the same
    // pre-impact terrain rather than reading back an already damaged map.
    internal WaterSupply AtLevel(float worldLevel) => new WaterSupply(heights, origin, spacing, worldLevel);

    // Heights are world Y; the first array index is Z. No Unity sampling occurs
    // after construction, including when an animated rim changes shape.
    internal WaterSupply(float[,] heights, Vector2 origin, Vector2 spacing, float worldLevel)
    {
        this.heights = heights;
        this.origin = origin;
        this.spacing = spacing;
        level = worldLevel;
        rows = heights.GetLength(0); columns = heights.GetLength(1);
        if (rows < 2 || columns < 2 || spacing.x <= 0f || spacing.y <= 0f)
            throw new ArgumentException("Water supply requires a regular height field.");
        bool anyWet = false;
        for (int z = 0; z < rows && !anyWet; z++)
        for (int x = 0; x < columns; x++)
            if (level - heights[z, x] > MinimumHead) { anyWet = true; break; }
        if (!anyWet)
        {
            components = Array.Empty<int>(); supplied = Array.Empty<bool>();
            return;
        }
        components = new int[rows * columns];
        var queue = new int[components.Length];
        var areas = new List<float> { 0f };
        int count = 0;
        float cellArea = spacing.x * spacing.y;
        for (int start = 0; start < components.Length; start++)
        {
            if (components[start] != 0 || !Wet(start)) continue;
            int component = ++count, read = 0, write = 0;
            float area = 0f;
            components[start] = component; queue[write++] = start;
            while (read < write)
            {
                int index = queue[read++], x = index % columns, z = index / columns;
                // Boundary vertices own half a cell along that axis. This rejects
                // isolated wet pinholes without rejecting shallow connected bays,
                // one-cell-wide channels, or ponds disconnected from the ocean.
                area += cellArea * (x == 0 || x == columns - 1 ? .5f : 1f)
                    * (z == 0 || z == rows - 1 ? .5f : 1f);
                if (x > 0) Enqueue(index - 1);
                if (x + 1 < columns) Enqueue(index + 1);
                if (z > 0) Enqueue(index - columns);
                if (z + 1 < rows) Enqueue(index + columns);
            }
            areas.Add(area);
            void Enqueue(int index)
            {
                if (components[index] != 0 || !Wet(index)) return;
                components[index] = component; queue[write++] = index;
            }
        }
        supplied = new bool[count + 1];
        for (int i = 1; i <= count; i++)
            if (areas[i] >= MinimumArea) { supplied[i] = true; HasSupply = true; }
    }

    internal static WaterSupply Capture(Terrain terrain, Rect footprint, float worldLevel)
    {
        var data = terrain.terrainData;
        Vector3 position = terrain.GetPosition(), size = data.size;
        int resolution = data.heightmapResolution - 1;
        Vector2 step = new Vector2(size.x / resolution, size.z / resolution);
        // Source water can lie beyond the effect's clipped render patch. Preserve
        // an exterior apron, clipped only to the real map rather than the crater.
        const float apron = 4f;
        int x0 = Mathf.Clamp(Mathf.FloorToInt((footprint.xMin - apron - position.x) / step.x), 0, resolution - 1);
        int z0 = Mathf.Clamp(Mathf.FloorToInt((footprint.yMin - apron - position.z) / step.y), 0, resolution - 1);
        int x1 = Mathf.Clamp(Mathf.CeilToInt((footprint.xMax + apron - position.x) / step.x), x0 + 1, resolution);
        int z1 = Mathf.Clamp(Mathf.CeilToInt((footprint.yMax + apron - position.z) / step.y), z0 + 1, resolution);
        float[,] heights = data.GetHeights(x0, z0, x1 - x0 + 1, z1 - z0 + 1);
        for (int z = 0; z < heights.GetLength(0); z++)
        for (int x = 0; x < heights.GetLength(1); x++)
            heights[z, x] = heights[z, x] * size.y + position.y;
        return new WaterSupply(heights, new Vector2(position.x + x0 * step.x, position.z + z0 * step.y), step, worldLevel);
    }

    private bool Wet(int index) => level - heights[index / columns, index % columns] > MinimumHead;

    internal bool TryDepth(Vector2 world, out float depth)
    {
        depth = 0f;
        if (!Address(world, out int x, out int z, out float fx, out float fz)) return false;
        depth = level - Mathf.Lerp(Mathf.Lerp(heights[z, x], heights[z, x + 1], fx),
            Mathf.Lerp(heights[z + 1, x], heights[z + 1, x + 1], fx), fz);
        return !float.IsNaN(depth) && !float.IsInfinity(depth);
    }

    internal bool TryGetHead(Vector2 world, out float head)
    {
        head = 0f;
        if (!HasSupply || !Address(world, out int x, out int z, out float fx, out float fz)) return false;
        float depth = level - Mathf.Lerp(Mathf.Lerp(heights[z, x], heights[z, x + 1], fx),
            Mathf.Lerp(heights[z + 1, x], heights[z + 1, x + 1], fx), fz);
        if (!(depth > MinimumHead)) return false;
        int a = z * columns + x;
        bool connected = (fx < 1f && fz < 1f && supplied[components[a]])
            || (fx > 0f && fz < 1f && supplied[components[a + 1]])
            || (fx < 1f && fz > 0f && supplied[components[a + columns]])
            || (fx > 0f && fz > 0f && supplied[components[a + columns + 1]]);
        if (!connected) return false;
        head = depth * Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(MinimumHead, .12f, depth));
        return head > 0f;
    }

    // Along a straight line, one bilinear terrain cell is a quadratic. Testing
    // its endpoints and interior minimum prevents an upstream probe jumping a
    // narrow dry ridge between sample positions.
    internal bool AllowsFlow(Vector2 start, Vector2 end)
    {
        if (!Address(start, out _, out _, out _, out _) || !Address(end, out _, out _, out _, out _)) return false;
        float u = (start.x - origin.x) / spacing.x, v = (start.y - origin.y) / spacing.y;
        float du = (end.x - start.x) / spacing.x, dv = (end.y - start.y) / spacing.y;
        float tx = du > 0f ? (Mathf.Floor(u) + 1f - u) / du
            : du < 0f ? (Mathf.Ceil(u) - 1f - u) / du : float.PositiveInfinity;
        float tz = dv > 0f ? (Mathf.Floor(v) + 1f - v) / dv
            : dv < 0f ? (Mathf.Ceil(v) - 1f - v) / dv : float.PositiveInfinity;
        float stepX = du == 0f ? float.PositiveInfinity : 1f / Mathf.Abs(du);
        float stepZ = dv == 0f ? float.PositiveInfinity : 1f / Mathf.Abs(dv);
        float t = 0f;
        Vector2 delta = end - start;
        for (int cell = 0; cell < rows + columns && t < 1f; cell++)
        {
            float next = Mathf.Min(1f, Mathf.Min(tx, tz)), middle = (t + next) * .5f;
            Address(start + delta * middle, out int x, out int z, out _, out _);
            // Bilinear interpolation cannot exceed its four corner heights.
            if (heights[z, x] > level + .005f || heights[z, x + 1] > level + .005f
                || heights[z + 1, x] > level + .005f || heights[z + 1, x + 1] > level + .005f)
            {
                TryDepth(start + delta * t, out float a);
                TryDepth(start + delta * middle, out float m);
                TryDepth(start + delta * next, out float b);
                if (a < -.005f || m < -.005f || b < -.005f) return false;
                float quadratic = 2f * (a + b - 2f * m);
                float linear = 4f * m - 3f * a - b;
                if (quadratic > 0f)
                {
                    float extremum = -linear / (2f * quadratic);
                    if (extremum > 0f && extremum < 1f
                        && a + linear * extremum + quadratic * extremum * extremum < -.005f) return false;
                }
            }
            t = next;
            if (tx <= next) tx += stepX;
            if (tz <= next) tz += stepZ;
        }
        return t >= 1f;
    }

    private bool Address(Vector2 world, out int x, out int z, out float fx, out float fz)
    {
        float u = (world.x - origin.x) / spacing.x, v = (world.y - origin.y) / spacing.y;
        x = z = 0; fx = fz = 0f;
        if (!(u >= 0f && v >= 0f && u <= columns - 1 && v <= rows - 1)) return false;
        x = Math.Min((int)u, columns - 2); z = Math.Min((int)v, rows - 2);
        fx = u - x; fz = v - z;
        return true;
    }
}
