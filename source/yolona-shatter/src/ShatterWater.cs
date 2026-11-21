using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using EM.Map;
using UnityEngine;
using static ScomShatter.CampaignMotion;

namespace ScomShatter;

// The original shoreline and final crest stay fixed in XZ. The connected sea
// draws down toward that crest as the slab moves. Jets start at its settled lip.
internal sealed class ShatterWater : IDisposable
{
    private const float Width = CampaignSurfaceAssets.NativeWidth, Length = CampaignSurfaceAssets.NativeLength;
    private static readonly float[] upstreamDistances = { .02f, .08f, .25f, .5f, .75f };
    private const int CellsX = CampaignWaterHeights.Columns - 1, CellsZ = CampaignWaterHeights.Rows - 1;
    private static readonly List<ShatterWater> activeCuts = new List<ShatterWater>();
    private readonly Transform site;
    private readonly Rect patch, worldBounds;
    private readonly FractureLayout layout;
    private readonly Func<Vector2, Vector2> toSite;
    private readonly Func<Vector2, float> terrainHeight;
    private readonly Vector2 origin;
    private const int nx = CellsX + 1, nz = CellsZ + 1;
    private Point[] grid;
    private Vector2[] offsets;
    private float[] drops, wetDepth, ownership, sharedDrops;
    private InletDrawdown drawdown;
    private float[] waterReach, guardedReach, bankLowering, sharedBank;
    private float[] bankProfileA, bankProfileB;
    private int bankFrameA = -1, bankFrameB = -1;
    private readonly List<ShatterWaterfall.Segment> spills = new List<ShatterWaterfall.Segment>();
    private readonly List<OverlapNode> overlap = new List<OverlapNode>();
    private readonly List<ShatterWater> neighbors = new List<ShatterWater>();
    private ShatterWaterSurface surface;
    private ShatterWaterfall falls;
    private ShatterInlet inlet;
    private ShorelineMesh shoreline;
    private ShorelineMesh.Prepared prepared;
    private WaterSupply supply, sampledSupply;
    private Task preparation;
    private bool hasWater, preparedFrozen;
    private bool registered, topologyDirty = true, fallsDirty = true, disabled, frozen;
    private bool inletUnavailable, bindingFallback, waitingForFinalCut, fallsUnavailable, neighborMotion;
    private float lastPhase = -1f, waterLevel;

    private struct Point
    {
        internal Vector2 Native, Offset;
    }

    // All layouts transport the same authored vertex lattice. Share its rest
    // coordinates and envelopes across impacts, including different map sizes.
    private static class Lattice
    {
        internal static readonly Vector2[] Source = new Vector2[nx*nz];
        internal static readonly float[] Reach = new float[nx*nz], Final = new float[nx*nz];
        internal static readonly int[] Moving;
        static Lattice()
        {
            var active = new List<int>();
            for (int z = 0; z < nz; z++)
            for (int x = 0; x < nx; x++)
            {
                int i = z*nx+x;
                Vector2 source = new Vector2(((float)x/CellsX-.5f)*Width, ((float)z/CellsZ-.5f)*Length);
                Source[i] = source;
                float ex = 2f*source.x/SurfaceOpening.Width, ez = 2f*(source.y-SurfaceOpening.OffsetZ)/SurfaceOpening.Length;
                if (ex*ex + ez*ez > 1f) continue;
                Reach[i] = CampaignWaterHeights.VertexPeak(i);
                Final[i] = CampaignWaterHeights.VertexFinal(i);
                if (Reach[i] > .0051f) active.Add(i);
            }
            Moving = active.ToArray();
        }
    }

    private struct OverlapNode
    {
        internal ShatterWater Other;
        internal int Node, A;
        internal float Fx, Fz;
    }

    internal ShatterWater(Transform site, Rect patch, FractureLayout layout, Func<Vector2,Vector2> toSite, Func<Vector2,float> terrainHeight)
    {
        this.site = site;
        this.patch = patch;
        this.layout = layout;
        this.toSite = toSite;
        this.terrainHeight = terrainHeight;
        origin = new Vector2(site.position.x, site.position.z);
        Rect local = layout.SiteBounds(patch);
        worldBounds = new Rect(local.x + origin.x, local.y + origin.y, local.width, local.height);
        // Capture before the visual animation or its terrain-change callbacks.
        try
        {
            if (MapWater.TryCapture(out var map) && map.HasWater)
            {
                supply = WaterSupply.Capture(MapManager.Terrain, worldBounds, map.WorldLevel);
                // Spend the impact wind-up reading immutable managed heights.
                // Mesh creation and every Unity object access stay on the main thread.
                WaterSupply original = supply;
                preparedFrozen = map.IsFullyFrozen;
                preparation = Task.Run(() => {
                    PrepareGrid(original);
                    prepared = PrepareShoreline(preparedFrozen);
                });
            }
        }
        catch (Exception error) { Disable(error); }
    }

    // The receiving ledge can change. Its new height must never wet an old beach.
    internal void InvalidateHeights() { fallsDirty = true; }

    internal void Update(float progress, float age, bool visible)
    {
        if (disabled) return;
        try
        {
            if (!visible || progress <= 0f || !MapWater.TryCapture(out var map) || !map.HasWater)
            {
                SetRegistered(false);
                surface?.SetVisible(false, 0f);
                inlet?.SetVisible(false);
                falls?.SetAge(age, false, 0f);
                return;
            }
            progress = Mathf.Clamp01(progress);
            if (preparation != null)
            {
                if (!preparation.IsCompleted) return;
                preparation.GetAwaiter().GetResult();
                preparation = null;
            }
            else if (grid == null) PrepareGrid(supply);
            if (supply == null || Mathf.Abs(map.WorldLevel - supply.WorldLevel) > .01f)
            {
                supply = supply == null ? WaterSupply.Capture(MapManager.Terrain, worldBounds, map.WorldLevel)
                    : supply.AtLevel(map.WorldLevel);
                topologyDirty = true;
            }
            waterLevel = supply.WorldLevel - site.position.y;
            if (frozen != map.IsFullyFrozen) { frozen = map.IsFullyFrozen; topologyDirty = true; }
            if (!frozen && inlet != null && inlet.Ready == bindingFallback) topologyDirty = true;
            if (waitingForFinalCut && progress >= 1f) topologyDirty = true;
            SetRegistered(true);
            bool rebuild = topologyDirty;
            if (rebuild) RebuildShoreline(progress);

            // Advance only height/opacity buffers. The sea cut and inlet XZ
            // topology do not follow the passing wave of deformation.
            bool moving = progress != lastPhase;
            if (rebuild || moving || neighborMotion)
            {
                bool animateInlet = inlet != null && !bindingFallback && !frozen && shoreline.Inlet.vertexCount > 0;
                bool sampled = moving || rebuild;
                if (sampled)
                {
                    if (animateInlet || neighbors.Count > 0) SampleMotion(progress);
                    lastPhase = progress;
                    foreach (var other in neighbors)
                    {
                        other.neighborMotion = true;
                        if (progress >= 1f && moving) other.fallsDirty = true;
                    }
                }
                if (animateInlet)
                {
                    CombineOverlaps();
                    shoreline.Update(sharedDrops ?? drops, sharedBank ?? bankLowering, waterLevel, progress);
                    if (rebuild) inlet.SetMesh(shoreline.Inlet);
                }
                neighborMotion = false;
            }
            bool show = surface != null && surface.Available;
            surface?.SetVisible(true, waterLevel);
            inlet?.SetVisible(show && !bindingFallback && !frozen);
            if (progress >= 1f && fallsDirty && show) BuildFalls();
            float arrival = Mathf.Clamp01((age - CampaignTimeline.AnimationDelay - CampaignTimeline.AnimationDuration) / .75f);
            falls?.SetAge(age, show && progress >= 1f && !frozen, (1f - map.FreezeAmount) * Mathf.SmoothStep(0f,1f,arrival));
        }
        catch (Exception error) { Disable(error); }
    }

    private void PrepareGrid(WaterSupply original)
    {
        int count = nx*nz;
        grid = new Point[count]; offsets = new Vector2[count];
        wetDepth = new float[count]; ownership = new float[count]; drops = new float[count];
        bankLowering = new float[count];
        for (int i = 0; i < count; i++)
        {
            Vector2 native = layout.SourceToNative(Lattice.Source[i]);
            offsets[i] = toSite(native);
            grid[i] = new Point { Native = native, Offset = offsets[i] };
            ownership[i] = 100f;
        }
        if (original != null) SampleShore(original);
    }

    private void SampleShore(WaterSupply original)
    {
        hasWater = false;
        for (int i = 0; i < offsets.Length; i++)
        {
            Vector2 world = origin + offsets[i];
            // Extrapolate the last real shoreline texel to the ghost vertices
            // of clipped map-edge cells. Geometry is clipped at the real edge.
            world.x = Mathf.Clamp(world.x,worldBounds.xMin,worldBounds.xMax);
            world.y = Mathf.Clamp(world.y,worldBounds.yMin,worldBounds.yMax);
            wetDepth[i] = original.TryDepth(world,out float depth) ? depth : -1f;
            if (wetDepth[i] > .02f) hasWater = true;
        }
        sampledSupply = original;
        drawdown = hasWater ? new InletDrawdown(nx,nz,offsets,wetDepth,Lattice.Final) : null;
        waterReach = drawdown == null ? Lattice.Reach : ShorelineMesh.FeederReach(nx,nz,Lattice.Reach,drawdown.Potential);
        guardedReach = hasWater ? ShorelineMesh.WaveGuard(nx,nz,waterReach) : waterReach;
        Array.Clear(bankLowering,0,bankLowering.Length);
        bankFrameA = bankFrameB = -1;
    }

    private void RebuildShoreline(float progress)
    {
        bool hadNeighbors = neighbors.Count > 0;
        neighbors.Clear();
        overlap.Clear();
        for (int n = 0; n < activeCuts.Count; n++)
        {
            var other = activeCuts[n];
            if (other != this && worldBounds.Overlaps(other.worldBounds)) neighbors.Add(other);
        }
        bool originalShore = sampledSupply == supply;
        if (!originalShore) SampleShore(supply);
        if (hadNeighbors || neighbors.Count > 0) PrepareOverlap();
        bool ice = frozen || inletUnavailable;
        if (!ice && inlet == null && hasWater)
        {
            try { inlet = new ShatterInlet(site); }
            catch (Exception error)
            {
                inletUnavailable = ice = true;
                Debug.LogWarning("[SCOM Yolona shatter] Sloping inlet material unavailable: " + error.Message);
            }
        }
        bindingFallback = inlet != null && !inlet.Ready;
        ice |= bindingFallback;
        waitingForFinalCut = !frozen && ice && progress < 1f;
        bool reuse = prepared != null && originalShore && !hadNeighbors && neighbors.Count == 0 &&
            ice == preparedFrozen && !waitingForFinalCut;
        var next = new ShorelineMesh(reuse ? prepared : PrepareShoreline(ice,waitingForFinalCut));
        prepared = null;
        var previous = shoreline;
        shoreline = next;
        if (surface == null) surface = new ShatterWaterSurface(site, next.Aperture, worldBounds);
        else surface.SetAperture(next.Aperture);
        surface.SetInlet(ice ? null : inlet);
        inlet?.SetMesh(null);
        previous?.Dispose();
        fallsDirty = true;
        topologyDirty = false;
    }

    private ShorelineMesh.Prepared PrepareShoreline(bool ice, bool dryOnly = false)
    {
        bool clipped = patch.width < Width-.001f || patch.height < Length-.001f;
        Rect? clip = clipped ? layout.SiteBounds(patch) : (Rect?)null;
        return ShorelineMesh.Prepare(nx,nz,origin,offsets,wetDepth,waterReach,Lattice.Final,ownership,ice,layout.IsFault,clip,dryOnly,guardedReach);
    }

    private bool SameLattice(ShatterWater other) => origin.Equals(other.origin) &&
        layout.FaultProfile == other.layout.FaultProfile && layout.QuarterTurns == other.layout.QuarterTurns &&
        layout.ScaleX == other.layout.ScaleX && layout.ScaleZ == other.layout.ScaleZ;

    private void SampleMotion(float progress)
    {
        Frame(progress,out int frame,out float blend);
        if (progress >= 1f) { frame = Frames-1; blend = 0f; }
        if (drawdown != null)
        {
            int next = Math.Min(frame+1,Frames-1);
            float[] from = BankProfile(frame,next);
            float[] to = blend == 0f ? from : BankProfile(next,frame);
            drawdown.Blend(from,to,blend,bankLowering);
        }
        // Cache misses borrow this buffer for authored endpoints. Always restore
        // the presented terrain phase before the inlet or neighbours read it.
        SampleDrops(frame,blend);
    }

    private void SampleDrops(int frame,float blend)
    {
        foreach (int i in Lattice.Moving)
            drops[i] = frame == Frames-1 ? Lattice.Final[i] : CampaignWaterHeights.VertexDrop(frame,blend,i);
    }

    private float[] BankProfile(int frame,int preserveFrame)
    {
        if (bankFrameA == frame) return bankProfileA;
        if (bankFrameB == frame) return bankProfileB;
        if (bankProfileA == null)
        {
            bankProfileA = new float[drops.Length];
            bankProfileB = new float[drops.Length];
        }
        // Keep the other requested endpoint when advancing, rewinding or
        // skipping frames. Cache storage remains bounded to two profiles.
        bool useA = bankFrameA != preserveFrame;
        float[] profile = useA ? bankProfileA : bankProfileB;
        SampleDrops(frame,0f);
        drawdown.Evaluate(drops,profile);
        if (useA) bankFrameA = frame; else bankFrameB = frame;
        return profile;
    }

    private void PrepareOverlap()
    {
        for (int i = 0; i < ownership.Length; i++) ownership[i] = 100f;
        int priority = activeCuts.IndexOf(this);
        foreach (var other in neighbors)
        {
            bool aligned = SameLattice(other);
            bool earlier = activeCuts.IndexOf(other) < priority;
            for (int i = 0; i < grid.Length; i++)
            {
                int a;
                float x, z;
                if (aligned)
                {
                    if (earlier) ownership[i] = -100f;
                    int ix = i%nx, iz = i/nx;
                    a = Math.Min(iz,CellsZ-1)*nx + Math.Min(ix,CellsX-1);
                    x = ix == CellsX ? 1f : 0f;
                    z = iz == CellsZ ? 1f : 0f;
                }
                else if (!other.Locate(other.ToNative(origin + offsets[i] - other.origin),out a,out x,out z)) continue;
                float otherPeak = aligned ? other.guardedReach[i] : Interpolate(other.guardedReach,a,x,z);
                if (otherPeak < .15f) continue;
                if (!aligned)
                {
                    float otherFinal = Interpolate(Lattice.Final,a,x,z);
                    float difference = Lattice.Final[i] - otherFinal;
                    if (Lattice.Final[i] <= LipDrop && otherFinal <= LipDrop)
                    {
                        float ownBank = drawdown == null ? 0f : drawdown.Potential[i];
                        float otherBank = other.drawdown == null ? 0f : Interpolate(other.drawdown.Potential,a,x,z);
                        float ownTarget = ShorelineMesh.AboveBed(ownBank,wetDepth[i],Lattice.Final[i]);
                        float otherTarget = ShorelineMesh.AboveBed(otherBank,Interpolate(other.wetDepth,a,x,z),otherFinal);
                        difference = ownTarget - otherTarget;
                    }
                    ownership[i] = Mathf.Min(ownership[i], difference + (earlier ? -.0001f : .0001f));
                }
                overlap.Add(new OverlapNode { Node = i, Other = other, A = a, Fx = x, Fz = z });
            }
        }
        if (overlap.Count == 0) sharedDrops = sharedBank = null;
        else if (sharedDrops == null)
        {
            sharedDrops = new float[drops.Length];
            sharedBank = new float[drops.Length];
        }
    }

    private void CombineOverlaps()
    {
        if (overlap.Count == 0) return;
        // Each field read here belongs to exactly one animation. Keep the
        // combined water heights separate so a rebounding neighbour can rise.
        Array.Copy(drops, sharedDrops, drops.Length);
        Array.Copy(bankLowering, sharedBank, bankLowering.Length);
        foreach (var item in overlap)
        {
            float depth = Interpolate(item.Other.drops,item.A,item.Fx,item.Fz);
            sharedDrops[item.Node] = Mathf.Max(sharedDrops[item.Node],depth);
            float lowering = Interpolate(item.Other.bankLowering,item.A,item.Fx,item.Fz);
            sharedBank[item.Node] = Mathf.Max(sharedBank[item.Node],lowering);
        }
    }

    private void BuildFalls()
    {
        spills.Clear();
        if (!frozen && inlet != null && shoreline.Inlet.vertexCount != 0 && supply.HasSupply)
        {
            for (int z = 0; z < nz-1; z++)
            for (int x = 0; x < nx-1; x++)
            {
                int a = z*nx+x, b = a+1, c = a+nx, d = c+1;
                Crest(a,b,c);
                Crest(b,d,c);
            }
            if (spills.Count > 0 && falls == null && !fallsUnavailable)
            {
                try { falls = new ShatterWaterfall(site,ClearanceAt); }
                catch (Exception error)
                {
                    fallsUnavailable = true;
                    Debug.LogWarning("[SCOM Yolona shatter] Waterfall material unavailable: " + error.Message);
                }
            }
        }
        falls?.SetGeometry(spills, waterLevel, 1f);
        surface.SetWaterfall(falls);
        fallsDirty = false;
    }

    private void Crest(int a, int b, int c)
    {
        bool pa=Lattice.Final[a]>=LipDrop, pb=Lattice.Final[b]>=LipDrop, pc=Lattice.Final[c]>=LipDrop;
        if (pa == pb && pb == pc) return;
        if (pa == pb) (a,b,c)=(c,a,b);
        else if (pa == pc) (a,b,c)=(b,c,a);
        Point m=Crossing(a,b), n=Crossing(a,c);
        if ((m.Offset-n.Offset).sqrMagnitude < .000001f) return;
        Vector2 inward=Inward(m.Offset,n.Offset,grid[a].Offset,Lattice.Final[a]>=LipDrop);
        AddSpill(m,n,inward,SourceHead(m,inward),SourceHead(n,inward));
    }

    private void AddSpill(Point a,Point b,Vector2 inward,float headA,float headB)
    {
        // Inspect the interior even when the two endpoints agree. Keep a fully
        // wet span whole so fine shoreline detection does not multiply the
        // expensive ballistic columns along a long uninterrupted ocean rim.
        int samples=Mathf.Max(1,Mathf.CeilToInt((b.Offset-a.Offset).magnitude/.25f));
        bool wet=headA>0f;
        Point start=a, previous=a;
        float startHead=headA, previousHead=headA;
        for(int i=1;i<=samples;i++)
        {
            Point point=i==samples ? b : Between(a,b,(float)i/samples);
            float head=i==samples ? headB : SourceHead(point,inward);
            bool nextWet=head>0f;
            if(nextWet!=wet)
            {
                Point boundary=SupplyBoundary(previous,point,inward,previousHead>0f);
                if(wet) EmitSpill(start,boundary,inward,startHead,0f);
                else { start=boundary; startHead=0f; }
                wet=nextWet;
            }
            previous=point; previousHead=head;
        }
        if(wet) EmitSpill(start,b,inward,startHead,headB);
    }

    private Point SupplyBoundary(Point a,Point b,Vector2 inward,bool wetA)
    {
        // Predicate boundaries include clipping and overlapping openings, not
        // only a linearly interpolated terrain shoreline.
        float lo=0f, hi=1f;
        for(int step=0;step<8;step++)
        {
            float mid=(lo+hi)*.5f;
            if((SourceHead(Between(a,b,mid),inward)>0f)==wetA) lo=mid;
            else hi=mid;
        }
        return Between(a,b,wetA ? lo : hi);
    }

    private void EmitSpill(Point a,Point b,Vector2 inward,float headA,float headB)
    {
        if((b.Offset-a.Offset).sqrMagnitude<.001f) return;
        if (!TryCrestHeight(a,out float crestA) || !TryCrestHeight(b,out float crestB)) return;
        spills.Add(new ShatterWaterfall.Segment(a.Offset,b.Offset,inward,headA,headB,crestA,crestB));
    }

    private bool TryCrestHeight(Point lip,out float height)
    {
        height = waterLevel;
        if (!Locate(lip.Native,out int cell,out float x,out float z)) return false;
        height = BankHeight(cell,x,z);
        return true;
    }

    private float BankHeight(int cell,float x,float z)
    {
        if (shoreline != null && shoreline.TryBankHeight(cell,x,z,out float rendered)) return rendered;
        float bank = Interpolate(sharedBank ?? bankLowering,cell,x,z);
        float bed = Interpolate(wetDepth,cell,x,z);
        float drop = Interpolate(sharedDrops ?? drops,cell,x,z);
        return waterLevel-ShorelineMesh.AboveBed(bank,bed,drop);
    }

    private float SourceHead(Point lip,Vector2 inward)
    {
        if (!Locate(lip.Native,out int cell,out float x,out float z) ||
            Interpolate(wetDepth,cell,x,z) <= .02f || Interpolate(ownership,cell,x,z) < 0f ||
            CoveredLip(lip.Offset,inward)) return 0f;
        // Check the actual native shore as well as the interpolated wet sheet.
        if(!supply.TryDepth(origin+lip.Offset,out float lipDepth) || lipDepth<=.02f) return 0f;
        float head=0f;
        Vector2 previous=origin+lip.Offset;
        foreach (float distance in upstreamDistances)
        {
            Vector2 offset=lip.Offset-inward*distance;
            Vector2 native=ToNative(offset);
            // Stop at the first solid bank/opening. A narrow connected channel
            // need not stay wet for an arbitrary 1.25m along the rim normal.
            Vector2 world=origin+offset;
            if(InOpening(native) || OtherCut(offset) || !supply.TryDepth(world,out float wetDepth) || wetDepth<=0f) break;
            if (!Locate(native,out int upstream,out float ux,out float uz) || !shoreline.CanFeed(upstream,ux,uz)) break;
            if(!supply.AllowsFlow(previous,world)) break;
            if(supply.TryGetHead(world,out float depth)) head=Mathf.Max(head,depth);
            previous=world;
        }
        return head;
    }

    private Point Crossing(int a,int b)
    {
        if (a>b) (a,b)=(b,a);
        return Between(grid[a],grid[b],(LipDrop-Lattice.Final[a])/(Lattice.Final[b]-Lattice.Final[a]));
    }

    private static Point Between(Point a,Point b,float t) => new Point {
        Native=Vector2.LerpUnclamped(a.Native,b.Native,t), Offset=Vector2.LerpUnclamped(a.Offset,b.Offset,t)
    };
    private static Vector2 Inward(Vector2 a,Vector2 b,Vector2 odd,bool inside)
    {
        var edge=b-a;
        var normal=new Vector2(-edge.y,edge.x).normalized;
        return (Vector2.Dot(normal,odd-a)>=0f)==inside ? normal : -normal;
    }

    private bool CoveredLip(Vector2 offset,Vector2 inward)
    {
        Vector2 world=origin+offset;
        int priority=registered ? activeCuts.IndexOf(this) : activeCuts.Count;
        for(int i=0;i<activeCuts.Count;i++)
        {
            var other=activeCuts[i];
            if (other != this && SameLattice(other)) { if(i<priority) return true; continue; }
            if(other==this || !other.worldBounds.Contains(world) ||
                !other.TryDrop(other.ToNative(world-other.origin),out float middle)) continue;
            // A contour point can round to either side of 5m. Compare a narrow
            // strip on both sides before assigning a coincident rim to its first
            // registered owner. A true overlapping interior still blocks both.
            const float probe=.04f;
            bool hasInner=other.TryDrop(other.ToNative(world-other.origin+inward*probe),out float inner);
            bool hasOuter=other.TryDrop(other.ToNative(world-other.origin-inward*probe),out float outer);
            float tolerance=.0001f+Mathf.Abs(inner-outer)*.025f;
            bool coincident=hasInner && hasOuter && inner>LipDrop && outer<LipDrop &&
                Mathf.Abs(middle-LipDrop)<=tolerance;
            if(coincident) { if(i<priority) return true; }
            else if(middle>LipDrop) return true;
        }
        return false;
    }

    private bool OtherCut(Vector2 offset)
    {
        Vector2 world = origin+offset;
        foreach (var other in neighbors)
            if (!SameLattice(other) && other.InOpening(other.ToNative(world-other.origin))) return true;
        return false;
    }

    private void SetRegistered(bool value)
    {
        if (registered == value) return;
        registered = value;
        if (value) activeCuts.Add(this); else activeCuts.Remove(this);
        topologyDirty = true;
        foreach (var other in activeCuts)
            if (other != this && worldBounds.Overlaps(other.worldBounds)) other.topologyDirty = true;
    }

    private Vector2 ToNative(Vector2 offset) => layout.ToNative(offset);
    private bool InOpening(Vector2 native) => TryDrop(native,out float d) && d>LipDrop;

    private bool TryDrop(Vector2 native,out float drop)
    {
        drop = 0f;
        if (!Locate(native,out int a,out float x,out float z)) return false;
        drop = Interpolate(Lattice.Final,a,x,z);
        return true;
    }

    private bool Locate(Vector2 native,out int a,out float fx,out float fz)
    {
        a = 0; fx = fz = 0f;
        if (grid == null || native.x < patch.xMin || native.x > patch.xMax ||
            native.y < patch.yMin || native.y > patch.yMax) return false;
        Vector2 source = layout.IsFault ? layout.NativeToSource(native) : native;
        float gx = (source.x/Width+.5f)*CellsX, gz = (source.y/Length+.5f)*CellsZ;
        int x = Mathf.Clamp(Mathf.FloorToInt(gx),0,CellsX-1), z = Mathf.Clamp(Mathf.FloorToInt(gz),0,CellsZ-1);
        a = z*nx+x;
        if (!layout.IsFault)
        {
            fx = Mathf.Clamp01(gx-x); fz = Mathf.Clamp01(gz-z);
            return true;
        }
        // The analytic inverse locates the cell to within a fraction of one
        // vertex. Interpolate in the actual straight-sided rendered triangles.
        if (Weights(a,native,out fx,out fz)) return true;
        for (int iz = Mathf.Max(0,z-1); iz <= Mathf.Min(CellsZ-1,z+1); iz++)
        for (int ix = Mathf.Max(0,x-1); ix <= Mathf.Min(CellsX-1,x+1); ix++)
        {
            a = iz*nx+ix;
            if (Weights(a,native,out fx,out fz)) return true;
        }
        return false;
    }

    private bool Weights(int a, Vector2 point,out float x,out float z)
    {
        Vector2 b = grid[a+1].Native, c = grid[a+nx].Native;
        if (Inside(grid[a].Native,b,c,point,out x,out z)) return true;
        if (!Inside(grid[a+nx+1].Native,c,b,point,out x,out z)) return false;
        x = 1f-x; z = 1f-z;
        return true;
    }

    private static bool Inside(Vector2 corner,Vector2 b,Vector2 c,Vector2 point,out float x,out float z)
    {
        b -= corner; c -= corner; point -= corner;
        float det = b.x*c.y-b.y*c.x;
        x = (point.x*c.y-point.y*c.x)/det;
        z = (b.x*point.y-b.y*point.x)/det;
        const float epsilon = .00003f;
        return x >= -epsilon && z >= -epsilon && x+z <= 1f+epsilon;
    }

    private static float Interpolate(float[] field,int a,float x,float z) => x+z <= 1f
        ? (1f-x-z)*field[a] + x*field[a+1] + z*field[a+nx]
        : (x+z-1f)*field[a+nx+1] + (1f-x)*field[a+nx] + (1f-z)*field[a+1];

    private float ClearanceAt(Vector2 offset)
    {
        Vector2 world = origin+offset;
        Vector2 native = ToNative(offset);
        bool known = TryBedClearance(native,world,out float depth);
        float water = float.PositiveInfinity;
        if (TryWaterClearance(native,world,out float liquid)) water = liquid;
        foreach (var other in neighbors)
        {
            Vector2 address = other.ToNative(world-other.origin);
            if (other.TryBedClearance(address,world,out float floor))
            {
                depth = known ? Mathf.Max(depth,floor) : floor;
                known = true;
            }
            if (other.TryWaterClearance(address,world,out liquid)) water = Mathf.Min(water,liquid);
        }
        return known ? Mathf.Min(depth,water) : 0f;
    }

    private bool TryBedClearance(Vector2 native,Vector2 world,out float depth)
    {
        depth = 0f;
        // The immutable source snapshot also bounds the real map. Do not let
        // clamped ghost vertices invent a receiver beyond its sampled terrain.
        if (supply == null || !supply.TryDepth(world,out float original)) return false;
        // Five metres defines the inlet's lip, not a solid wall. Retained slabs
        // below that threshold still have a real displaced receiving surface.
        depth = TryDrop(native,out float drop) ? Mathf.Max(0f,waterLevel-terrainHeight(native)+drop)
            : Mathf.Max(0f,original);
        return true;
    }

    private bool TryWaterClearance(Vector2 native,Vector2 world,out float depth)
    {
        depth = 0f;
        if (frozen || bindingFallback || inlet == null || shoreline == null ||
            !Locate(native,out int cell,out float x,out float z) ||
            !shoreline.HoldsWater(cell,x,z) || Interpolate(ownership,cell,x,z) < 0f ||
            Interpolate(wetDepth,cell,x,z) <= ShorelineMesh.DryDepth ||
            Interpolate(Lattice.Final,cell,x,z) >= LipDrop-.001f ||
            !supply.TryDepth(world,out float original) || original <= ShorelineMesh.DryDepth) return false;
        // Exclude the exact emitting lip so a nearly vertical stream can leave
        // its own interface. Elsewhere, visible bank water receives the jet
        // before its submerged bed, including across a neighbouring opening.
        depth = Mathf.Max(0f,waterLevel-BankHeight(cell,x,z));
        return true;
    }

    private void Disable(Exception error)
    {
        Dispose();
        Debug.LogWarning("[SCOM Yolona shatter] Water rendering disabled for this impact: " + error.Message);
    }

    public void Dispose()
    {
        if (disabled) return;
        disabled=true;
        SetRegistered(false);
        falls?.Dispose(); inlet?.Dispose(); surface?.Dispose(); shoreline?.Dispose();
    }
}
