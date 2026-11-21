using System;
using System.Collections.Generic;
using EM.Core;
using EM.Engine;
using EM.Pathfinding;
using HarmonyLib;
using Unity.Collections;
using Unity.Mathematics;
using UnityEngine;

namespace ScomShatter;

internal static class ChasmNavigation
{
    private sealed class Chunk
    {
        internal readonly ChasmBlockers Blockers = new ChasmBlockers();
        internal readonly Dictionary<RectInt, GlobalID[]> Installed = new Dictionary<RectInt, GlobalID[]>();
    }

    private sealed class Side
    {
        internal readonly Dictionary<Vector2Int, Chunk> Chunks = new Dictionary<Vector2Int, Chunk>();
        internal readonly HashSet<Vector2Int> Changed = new HashSet<Vector2Int>();
        internal readonly HashSet<Vector2Int> Dirty = new HashSet<Vector2Int>();
        internal readonly HashSet<RectInt> Desired = new HashSet<RectInt>();
        internal readonly List<RectInt> Removed = new List<RectInt>();
        internal readonly ushort[] Scratch = new ushort[16];
        internal NativeArray<bool> Identity;
        internal uint NextIdentity;

        internal void ForgetMap()
        {
            Identity = default;
            NextIdentity = 0;
            foreach (Chunk chunk in Chunks.Values) chunk.Installed.Clear();
        }
    }

    private static readonly Side Host = new Side(), Client = new Side();

    internal static void Install(Harmony harmony)
    {
        harmony.Patch(AccessTools.Method(typeof(GlobalEngineData), nameof(GlobalEngineData.ScheduleUpdate)),
            prefix: new HarmonyMethod(typeof(ChasmNavigation), nameof(BeforeSimulation)) { priority = Priority.Last });
        harmony.Patch(AccessTools.Method(typeof(Navmap), nameof(Navmap.Dispose)),
            prefix: new HarmonyMethod(typeof(ChasmNavigation), nameof(BeforeNavmapDisposed)));
    }

    private static void BeforeNavmapDisposed(ref Navmap __instance)
    {
        ForgetNativeMap(Host, in __instance);
        ForgetNativeMap(Client, in __instance);
    }

    private static void ForgetNativeMap(Side side, in Navmap navmap)
    {
        lock (side)
        {
            // Unity can reuse the same buffer address for the next navmap.
            if (side.Identity.IsCreated && side.Identity.Equals(navmap.layerData.blockedNodes)) side.ForgetMap();
        }
    }

    internal static void Advance(bool isHost, ChasmWorld.Site site, int stage, bool settled)
    {
        Side side = isHost ? Host : Client;
        var plan = site.Navigation;
        lock (side)
        {
            for (int i = site.NavStage; i < stage; i++)
            {
                foreach (RectInt span in plan.Runs[i])
                {
                    for (int x = span.xMin; x < span.xMax;)
                    {
                        var key = new Vector2Int(x >> 4, span.y >> 4);
                        int width = Math.Min(16 - (x & 15), span.xMax - x);
                        if (!side.Chunks.TryGetValue(key, out var chunk))
                            side.Chunks.Add(key, chunk = new Chunk());
                        if (chunk.Blockers.Add(x & 15, span.y & 15, width))
                        {
                            side.Changed.Add(key);
                            // Include portals immediately across a changed boundary.
                            for (int z = (span.y - 1) >> 4; z <= (span.y + 1) >> 4; z++)
                                for (int cx = (x - 1) >> 4; cx <= (x + width) >> 4; cx++)
                                {
                                    var affected = new Vector2Int(cx, z);
                                    side.Dirty.Add(affected);
                                    plan.Affected.Add(affected);
                                }
                        }
                        x += width;
                    }
                }
            }
            // Revalidate routes after the final animation, without rasterizing or
            // replacing the exact same obstacles for a second time.
            if (settled) side.Dirty.UnionWith(plan.Affected);
        }
    }

    private static void BeforeSimulation(ref GlobalEngineData globalEngineData, bool isHost)
    {
        Side side = isHost ? Host : Client;
        lock (side)
        {
            ref Navmap navmap = ref globalEngineData.globalNavmapManager.navmap;
            if (side.Chunks.Count == 0 || !navmap.IsCreated) return;
            bool replaced = !side.Identity.Equals(navmap.layerData.blockedNodes);
            if (!replaced && side.Dirty.Count == 0) return;

            globalEngineData.globalDependency.Complete();
            navmap.jobHandle.Complete();
            if (replaced)
            {
                side.ForgetMap();
                side.Identity = navmap.layerData.blockedNodes;
                side.Changed.UnionWith(side.Chunks.Keys);
                foreach (Vector2Int key in side.Chunks.Keys)
                    for (int dz = -1; dz <= 1; dz++)
                        for (int dx = -1; dx <= 1; dx++)
                            side.Dirty.Add(new Vector2Int(key.x + dx, key.y + dz));
            }

            List<byte> layers = SurfaceLayers(in navmap);
            foreach (Vector2Int key in side.Changed)
                if (OnMap(key, in navmap)) ApplyChunk(side, key, layers, ref navmap);
            Invalidate(side.Dirty, layers, ref navmap);
            side.Changed.Clear();
            side.Dirty.Clear();
        }
    }

    private static bool OnMap(Vector2Int key, in Navmap navmap) => key.x >= 0 && key.y >= 0 &&
        key.x < navmap.settings.navmapDimensions.x && key.y < navmap.settings.navmapDimensions.y;

    private static List<byte> SurfaceLayers(in Navmap navmap)
    {
        var layers = new List<byte>(5);
        for (int i = 0; i < navmap.settings.totalLayers; i++)
        {
            string name = navmap.layerData.layerConfig[i].name.ToString();
            if (name == "Land" || name == "Amphibious" || name == "Sea" || name == "Submarine" || name == "Hover")
                layers.Add((byte)i);
        }
        return layers;
    }

    private static void ApplyChunk(Side side, Vector2Int key, List<byte> layers, ref Navmap navmap)
    {
        Chunk chunk = side.Chunks[key];
        int index = NavmapUtils.ChunkCoordToFlatIndex(in navmap.settings, new int2(key.x, key.y));
        ref NavmapModiferData data = ref navmap.modifierData;
        var set = data.modifiersByChunk[index];
        side.Desired.Clear();
        chunk.Blockers.Rectangles(key, side.Desired, side.Scratch);
        side.Removed.Clear();
        foreach (RectInt rect in chunk.Installed.Keys)
            if (!side.Desired.Contains(rect)) side.Removed.Add(rect);

        foreach (RectInt rect in side.Removed)
        {
            foreach (GlobalID id in chunk.Installed[rect])
            {
                set.Remove(id);
                data.modifiers.Remove(id);
            }
            chunk.Installed.Remove(rect);
        }
        foreach (RectInt rect in side.Desired)
        {
            if (chunk.Installed.ContainsKey(rect)) continue;
            var ids = new GlobalID[layers.Count];
            for (int i = 0; i < ids.Length; i++)
            {
                GlobalID id;
                do
                {
                    if (side.NextIdentity == uint.MaxValue)
                        throw new InvalidOperationException("Chasm navigation obstacle identity space exhausted.");
                    id = new GlobalID(uint.MaxValue, ++side.NextIdentity);
                }
                while (data.modifiers.ContainsKey(id));
                // The native rectangle floors its centre before subtracting half its integer size.
                var modifier = new NavmapModifier
                {
                    globalID = id,
                    position = new float3(rect.x + rect.width / 2 + .5f, 0f, rect.y + rect.height / 2 + .5f),
                    size = new float2(rect.width, rect.height),
                    layerIndex = layers[i]
                };
                if (data.modifiers.Count >= data.modifiers.Capacity)
                    data.modifiers.Capacity = checked(Math.Max(16, data.modifiers.Capacity * 2));
                data.modifiers.Add(id, modifier);
                set.Add(id);
                ids[i] = id;
            }
            chunk.Installed.Add(rect, ids);
        }
        data.modifiersByChunk[index] = set;
    }

    private static void Invalidate(HashSet<Vector2Int> changed, List<byte> layers, ref Navmap navmap)
    {
        var dirty = new HashSet<int>();
        foreach (Vector2Int key in changed)
        {
            if (!OnMap(key, in navmap)) continue;
            int chunk = NavmapUtils.ChunkCoordToFlatIndex(in navmap.settings, new int2(key.x, key.y));
            NavmapDirtyFlags flags = navmap.chunkData.dirtyFlags[chunk];
            foreach (byte layer in layers) flags.SetLayerDirty(layer, true);
            navmap.chunkData.dirtyFlags[chunk] = flags;
            dirty.Add(chunk);
        }
        if (dirty.Count == 0) return;

        ref NavmapFlowfieldData flow = ref navmap.flowfieldData;
        using var keys = flow.flowfieldLookup.GetKeyArray(Allocator.Temp);
        foreach (NavmapPathKey key in keys)
        {
            if (!layers.Contains(key.layerIndex)) continue;
            int chunk = NavmapUtils.ChunkCoordToFlatIndex(in navmap.settings, key.ChunkCoord(in navmap.settings));
            if (!dirty.Contains(chunk)) continue;
            NavmapFlowfieldEntry entry = flow.flowfieldLookup[key];
            if (entry.pending) continue; // The queued request will see the new blockers in this dispatch.
            entry.version = flow.nextFlowfieldVersion.Value++;
            entry.pending = true;
            flow.flowfieldLookup[key] = entry;
            flow.flowfieldRequests.Add(new FlowfieldRequest { pathKey = key, version = entry.version });
        }
    }

    internal static void Reset(bool isHost)
    {
        Side side = isHost ? Host : Client;
        lock (side)
        {
            if (side.Identity.IsCreated) RemoveOwned(side, isHost);
            side.Chunks.Clear();
            side.Changed.Clear();
            side.Dirty.Clear();
            side.Removed.Clear();
            side.Desired.Clear();
            side.ForgetMap();
        }
    }

    private static void RemoveOwned(Side side, bool isHost)
    {
        ref GlobalEngineData global = ref (isHost ? ref HostEngine.Data.globalEngineData : ref ClientEngine.Data.globalEngineData);
        ref Navmap navmap = ref global.globalNavmapManager.navmap;
        if (navmap.IsCreated && side.Identity.Equals(navmap.layerData.blockedNodes))
        {
            global.globalDependency.Complete();
            navmap.jobHandle.Complete();
            foreach (var pair in side.Chunks)
            {
                if (!OnMap(pair.Key, in navmap)) continue;
                int index = NavmapUtils.ChunkCoordToFlatIndex(in navmap.settings, new int2(pair.Key.x, pair.Key.y));
                var set = navmap.modifierData.modifiersByChunk[index];
                foreach (GlobalID[] ids in pair.Value.Installed.Values)
                    foreach (GlobalID id in ids) { set.Remove(id); navmap.modifierData.modifiers.Remove(id); }
                navmap.modifierData.modifiersByChunk[index] = set;
                for (int dz = -1; dz <= 1; dz++)
                    for (int dx = -1; dx <= 1; dx++)
                        side.Dirty.Add(new Vector2Int(pair.Key.x + dx, pair.Key.y + dz));
            }
            Invalidate(side.Dirty, SurfaceLayers(in navmap), ref navmap);
        }
    }
}
