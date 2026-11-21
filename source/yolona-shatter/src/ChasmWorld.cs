using System;
using System.Collections.Generic;
using UnityEngine;

namespace ScomShatter;

internal static class ChasmWorld
{
    internal const int SettledTicks = 108; // Includes the last campaign edge-light particles.
    private const float ProjectileCullDepth = 160f;

    internal sealed class Site
    {
        internal readonly Vector3 Position;
        internal readonly FractureLayout Layout;
        internal readonly Rect Bounds;
        internal readonly int ImpactTick;
        internal int NavStage;
        internal NavigationFootprint Navigation;
        internal List<RectInt>[] SettledRuns;
        internal float CurrentProgress;
        internal volatile bool PresentImpact;

        internal Site(Vector3 position, uint index, uint generation, int impactTick)
        {
            Position = position;
            ImpactTick = impactTick;
            uint seed = unchecked(index * 747796405u ^ generation * 2891336453u ^ (uint)impactTick);
            Layout = FractureLayout.Create(position, seed);
            const float w = CampaignSurfaceAssets.NativeWidth, h = CampaignSurfaceAssets.NativeLength;
            var local = Layout.SiteBounds(new Rect(-w * .5f, -h * .5f, w, h));
            Bounds = new Rect(position.x + local.x, position.z + local.y, local.width, local.height);
        }

        internal float Progress(int tick) => CampaignTimeline.Progress((tick - (double)ImpactTick) * .1);

        internal bool Contains(float x, float z, float progress)
        {
            if (progress <= 0f || x < Bounds.xMin || x > Bounds.xMax || z < Bounds.yMin || z > Bounds.yMax)
                return false;
            Vector2 p = Layout.ToNative(new Vector2(x - Position.x, z - Position.z));
            return Layout.LostSupport(p, progress);
        }
    }

    private sealed class Side
    {
        internal readonly Dictionary<ulong, Site> Impacts = new Dictionary<ulong, Site>();
        internal readonly Dictionary<Vector2Int, List<Site>> Contacts = new Dictionary<Vector2Int, List<Site>>();
        internal readonly List<Site> Animating = new List<Site>();
        internal readonly Queue<Site> Visuals = new Queue<Site>(), Settled = new Queue<Site>();
        internal int Tick;
        internal float DepthLimit = float.NegativeInfinity;
    }

    private static readonly Side Host = new Side(), Client = new Side();

    internal static bool Register(bool isHost, Vector3 position, uint index, uint generation, int impactTick)
    {
        if (index == 0 || impactTick < 0 || !Finite(position.x) || !Finite(position.y) || !Finite(position.z))
            return false;
        Side side = isHost ? Host : Client;
        ulong key = ((ulong)generation << 32) | index;
        lock (side)
        {
            if (side.Impacts.TryGetValue(key, out var old))
                return old.ImpactTick == impactTick && old.Position.Equals(position);
            var site = new Site(position, index, generation, impactTick);
            site.CurrentProgress = site.Progress(side.Tick);
            side.Impacts.Add(key, site);
            if (isHost)
            {
                Vector2Int first = ContactCell(site.Bounds.xMin, site.Bounds.yMin);
                Vector2Int last = ContactCell(site.Bounds.xMax, site.Bounds.yMax);
                for (int z = first.y; z <= last.y; z++)
                    for (int x = first.x; x <= last.x; x++)
                    {
                        var cell = new Vector2Int(x, z);
                        if (!side.Contacts.TryGetValue(cell, out var nearby))
                            side.Contacts.Add(cell, nearby = new List<Site>());
                        nearby.Add(site);
                    }
            }
            side.Animating.Add(site);
            if (!isHost) side.Visuals.Enqueue(site);
            return true;
        }
    }

    private static bool Finite(float value) => !float.IsNaN(value) && !float.IsInfinity(value);

    internal static void Advance(bool isHost, int tick)
    {
        Side side = isHost ? Host : Client;
        lock (side)
        {
            side.Tick = tick;
            for (int i = side.Animating.Count - 1; i >= 0; --i)
            {
                Site site = side.Animating[i];
                bool settled = tick - site.ImpactTick >= SettledTicks;
                // Reserve the next section just before support fails so a route
                // never deliberately sends a land unit onto an already-open slab.
                site.CurrentProgress = site.Progress(tick);
                int stage = settled ? NavigationFootprint.Stages : (int)Math.Ceiling(site.CurrentProgress * NavigationFootprint.Stages);
                site.Navigation ??= new NavigationFootprint(site);
                if (site.NavStage == 0) site.Navigation.Prepare(stage > 0);
                if (!settled && stage <= site.NavStage) continue;
                ChasmNavigation.Advance(isHost, site, stage, settled);
                site.NavStage = stage;
                side.DepthLimit = Math.Max(side.DepthLimit, site.Position.y - ProjectileCullDepth);
                if (!settled) continue;
                side.Animating.RemoveAt(i);
                if (!isHost)
                {
                    site.SettledRuns = site.Navigation.Runs;
                    side.Settled.Enqueue(site);
                }
                site.Navigation = null;
            }
        }
    }

    internal static float ProjectileDepthLimit { get { lock (Host) return Host.DepthLimit; } }

    internal static Site HostImpact(uint index, uint version)
    {
        lock (Host)
            return Host.Impacts.TryGetValue(((ulong)version << 32) | index, out var site) ? site : null;
    }

    internal static bool Contains(float x, float z) => QueryHost(x, z, false, 0);
    internal static bool ShouldRemoveProjectile(float x, float y, float z) => QueryHost(x, z, true, y);

    private static Vector2Int ContactCell(float x, float z) => new Vector2Int(Mathf.FloorToInt(x / 128f), Mathf.FloorToInt(z / 128f));

    private static bool QueryHost(float x, float z, bool cull, float y)
    {
        lock (Host)
        {
            if (!Host.Contacts.TryGetValue(ContactCell(x, z), out var nearby)) return false;
            foreach (var site in nearby)
                if ((!cull || y <= site.Position.y - ProjectileCullDepth) && site.Contains(x, z, site.CurrentProgress))
                    return true;
            return false;
        }
    }

    internal static bool MarkVisibleImpact(uint index, uint generation)
    {
        lock (Client)
        {
            if (!Client.Impacts.TryGetValue(((ulong)generation << 32) | index, out var site)) return false;
            site.PresentImpact = true;
            return true;
        }
    }

    internal static bool TryDequeue(bool settled, out Site site)
    {
        lock (Client)
        {
            var queue = settled ? Client.Settled : Client.Visuals;
            site = queue.Count == 0 ? null : queue.Dequeue();
            return site != null;
        }
    }

    internal static void Reset(bool isHost)
    {
        Side side = isHost ? Host : Client;
        lock (side)
        {
            ChasmNavigation.Reset(isHost);
            side.Impacts.Clear();
            side.Contacts.Clear();
            side.Animating.Clear();
            side.Visuals.Clear();
            side.Settled.Clear();
            side.Tick = 0;
            side.DepthLimit = float.NegativeInfinity;
        }
    }
}
