using System;
using System.Collections.Generic;
using EM.Components;
using EM.Core;
using EM.Engine;
using EM.Entities;
using EM.Map;
using EM.Prefabs;
using HarmonyLib;
using UnityEngine;

namespace ScomShatter;

// The simulation retains its props, collision and reclaim resources. Only each
// selected prop's client renderer is disabled during the native render dispatch.
internal sealed class FractureProps : IDisposable
{
    private static readonly List<FractureProps> Sites = new List<FractureProps>();
    private static readonly List<LocalID> Suppressed = new List<LocalID>();
    private static readonly HashSet<LocalID> Seen = new HashSet<LocalID>();
    private static readonly EntityQuery PropQuery = EntityQuery.Of<LocalToWorld>().With<RendererComponent>();
    private const float PositionTolerance = .1f;
    private readonly List<Candidate> candidates = new List<Candidate>();
    private readonly Rect footprint;
    private readonly Func<float, float, float> fallAgeWorld;
    private readonly Terrain terrain;
    private readonly int session;
    private bool active, cached, disposed;
    private float age;
    private static bool warned;

    internal FractureProps(Rect footprint, Func<float, float, float> fallAgeWorld)
    {
        this.footprint = footprint;
        this.fallAgeWorld = fallAgeWorld ?? throw new ArgumentNullException(nameof(fallAgeWorld));
        terrain = MapManager.Terrain;
        session = Surface.SessionId;
        Sites.Add(this);
    }

    internal static void Install(Harmony harmony)
    {
        harmony.Patch(AccessTools.Method(typeof(LocalEngineData), nameof(LocalEngineData.ScheduleAfterRenderUpdate)),
            prefix: new HarmonyMethod(typeof(FractureProps), nameof(BeforeRenderJobs)));
        harmony.Patch(AccessTools.Method(typeof(ClientEngine), nameof(ClientEngine.RenderUpdate)),
            finalizer: new HarmonyMethod(typeof(FractureProps), nameof(AfterRender)));
    }

    internal void SetAge(float age, bool active)
    {
        this.age = age;
        this.active = active && age >= 0f && !float.IsInfinity(age);
    }

    private readonly struct Candidate
    {
        internal readonly LocalID Id;
        internal readonly Vector2 OriginalPosition;
        internal readonly float FallAge;

        internal Candidate(LocalID id, Vector2 originalPosition, float fallAge)
        {
            Id = id;
            OriginalPosition = originalPosition;
            FallAge = fallAge;
        }
    }

    private bool IsCurrent => !disposed && terrain != null && terrain == MapManager.Terrain &&
        Surface.IsReady && Surface.SessionId == session && MapManager.IsMapLoadedForClient;

    private sealed class AuthoredPositions
    {
        private readonly struct Entry
        {
            internal readonly Vector2 Point;
            internal readonly float FallAge;

            internal Entry(Vector2 point, float fallAge) { Point = point; FallAge = fallAge; }
        }

        // Host transforms may quantize a serialized coordinate before the local
        // renderer receives it. Match the nearest authored prop within 10 cm.
        private readonly Dictionary<Vector2Int, List<Entry>> cells = new Dictionary<Vector2Int, List<Entry>>();
        private static Vector2Int Cell(Vector2 p) => new Vector2Int(
            Mathf.FloorToInt(p.x / PositionTolerance), Mathf.FloorToInt(p.y / PositionTolerance));

        internal void Add(Vector2 point, float fallAge)
        {
            var key = Cell(point);
            if (!cells.TryGetValue(key, out var points)) cells.Add(key, points = new List<Entry>(1));
            points.Add(new Entry(point, fallAge));
        }

        internal bool TryGetFallAge(Vector2 point, out float fallAge)
        {
            var center = Cell(point);
            float nearest = PositionTolerance * PositionTolerance;
            bool found = false;
            fallAge = float.PositiveInfinity;
            for (int z = -1; z <= 1; z++) for (int x = -1; x <= 1; x++)
            {
                if (!cells.TryGetValue(new Vector2Int(center.x + x, center.y + z), out var points)) continue;
                foreach (var entry in points)
                {
                    float distance = (entry.Point - point).sqrMagnitude;
                    if (distance > nearest) continue;
                    nearest = distance;
                    fallAge = entry.FallAge;
                    found = true;
                }
            }
            return found;
        }
    }

    private void Cache(ref World world)
    {
        // Require both a native scenery prefab name and an authored map position;
        // matching a mesh or material alone could also select units or wrecks.
        var positions = new Dictionary<string, AuthoredPositions>(StringComparer.OrdinalIgnoreCase);
        var props = MapManager.mapFile.props;
        if (props == null) return;
        foreach (var type in props)
        {
            var data = type.propData;
            if (data == null || data.general == null || data.visuals == null || data.visuals.isWreckage ||
                !NativeScenery(data.general.tpId) || type.blueprintPath == null ||
                !type.blueprintPath.StartsWith("Environment/", StringComparison.OrdinalIgnoreCase)) continue;
            if (type.transforms == null) continue;
            foreach (var transform in type.transforms)
            {
                var p = transform.position;
                var point = new Vector2(p.x, p.z);
                if (!footprint.Contains(point)) continue;
                float fallAge = fallAgeWorld(p.x, p.z);
                if (float.IsNaN(fallAge) || float.IsInfinity(fallAge) || fallAge < 0f) continue;
                if (!positions.TryGetValue(data.general.tpId, out var authored))
                {
                    authored = new AuthoredPositions();
                    positions.Add(data.general.tpId, authored);
                }
                authored.Add(point, fallAge);
            }
        }
        if (positions.Count != 0)
        {
            var names = new Dictionary<PrefabID, AuthoredPositions>();
            foreach (var instance in world.QueryInstances(PropQuery))
            {
                if (!instance.HasComponent<LocalToWorld>(0) || !instance.HasComponent<RendererComponent>(0)) continue;
                var prefab = instance.GetPrefabID(in world);
                if (!names.TryGetValue(prefab, out var authored))
                {
                    string name = instance.GetArchetypeData<ArchetypeData>(in world).prefabName.ToString();
                    positions.TryGetValue(name, out authored);
                    names.Add(prefab, authored);
                }
                if (authored == null) continue;
                var position = instance.GetComponent<LocalToWorld>(0).value.c3;
                var originalPosition = new Vector2(position.x, position.z);
                if (authored.TryGetFallAge(originalPosition, out float fallAge))
                    candidates.Add(new Candidate(instance.GetEntityID<LocalID>(0), originalPosition, fallAge));
            }
        }
        cached = true;
    }

    private static bool NativeScenery(string name)
    {
        // Verified Environment.sanpack families: biomass (trees/bushes) and
        // minerals (rocks). Fail closed for structures, mod props and wrecks.
        if (name == null || name.Length != 8) return false;
        string family = name.Substring(0, 4);
        if (family != "edbm" && family != "edbs" && family != "edml" && family != "edmm" && family != "edms")
            return false;
        for (int i = 4; i < name.Length; i++) if (name[i] < '0' || name[i] > '9') return false;
        return true;
    }

    private static void BeforeRenderJobs(ref LocalEngineData localEngineData)
    {
        if (Sites.Count == 0) return;
        try
        {
            // RenderUpdate completed interpolation and native Lua callbacks before
            // this call. Counts, culling and buffer writes have not been scheduled.
            ref World world = ref localEngineData.localWorld;
            bool builtCache = false;
            foreach (var site in Sites)
            {
                if (!site.active || !site.IsCurrent) continue;
                if (!site.cached)
                {
                    if (builtCache) continue;
                    site.Cache(ref world);
                    builtCache = true;
                }
                foreach (var candidate in site.candidates)
                {
                    if (site.age < candidate.FallAge || !world.TryGetComponent(candidate.Id, out LocalToWorld transform)) continue;
                    var position = new Vector2(transform.value.c3.x, transform.value.c3.z);
                    if ((position - candidate.OriginalPosition).sqrMagnitude > PositionTolerance * PositionTolerance) continue;
                    if (!Seen.Add(candidate.Id) || !world.TryGetComponentRW(candidate.Id, out ComponentRefRW<RendererComponent> renderer)) continue;
                    if (!renderer.ValueRO.Enable) continue;
                    Suppressed.Add(candidate.Id);
                    renderer.ValueRW.Enable = false;
                }
            }
        }
        catch (Exception error)
        {
            if (!warned)
            {
                warned = true;
                Debug.LogWarning("[SCOM Yolona shatter] Native scenery suppression skipped: " + error.Message);
            }
        }
    }

    private static void AfterRender()
    {
        if (Suppressed.Count == 0) { Seen.Clear(); return; }
        try
        {
            // Normal return follows every count/write job and draw dispatch. Also
            // finish pending jobs on an exceptional return before restoring flags.
            ref LocalEngineData local = ref ClientEngine.Data.localEngineData;
            local.localDependency.Complete();
            foreach (var id in Suppressed)
                if (local.localWorld.TryGetComponentRW(id, out ComponentRefRW<RendererComponent> renderer))
                    renderer.ValueRW.Enable = true;
        }
        finally
        {
            Suppressed.Clear();
            Seen.Clear();
        }
    }

    public void Dispose()
    {
        if (disposed) return;
        disposed = true;
        active = false;
        candidates.Clear();
        Sites.Remove(this);
    }

    internal static void Clear()
    {
        // No native flags persist between render calls. Dropping the owners is
        // sufficient for retirement, overlapping sites and map/session changes.
        for (int i = Sites.Count - 1; i >= 0; i--) Sites[i].Dispose();
        warned = false;
    }
}
