using System;
using System.Collections.Generic;
using UnityEngine;

namespace ScomShatter;

// The wet approach slopes toward the moving rim. ShorelineMesh combines this
// hydraulic surface with the local slab motion on each clipped triangle.
internal sealed class InletDrawdown
{
    private const float DryDepth = .02f, CrestDrop = 5f, Support = 30f, MaximumGrade = .4f;
    private const float MaximumFaceGrade = .58f;
    private readonly int nx, nz;
    private readonly Vector2[] offsets;
    private readonly Vector3[] edgeLimits;
    private readonly float[] wetDepth, reserve, drivers;
    private readonly int[] source, active, drivenSources;
    private readonly Crest[] crests;
    private readonly (int A, int B, float Limit)[] divides;
    private readonly (int Wet, int Dry, float Fraction, float Limit)[] shoreEdges;
    private readonly Heap repair;
    internal float[] Potential { get; }

    private readonly struct Crest
    {
        internal readonly int A, B;
        internal readonly float Blend, Target, Length;
        internal Crest(int a, int b, float blend, float depth)
        {
            A = a; B = b; Blend = blend;
            // Start the approach far enough upstream to reach the sinking lip.
            // Shallow inlets can drain only their available column above the bed.
            Target = CrestDrop + Mathf.Min(2f, .65f * depth);
            Length = 4f * Target;
        }
    }

    internal InletDrawdown(int nx, int nz, Vector2[] offsets, float[] wetDepth, float[] finalDrop)
    {
        if (nx < 2 || nz < 2) throw new ArgumentOutOfRangeException(nameof(nx));
        int count = checked(nx * nz);
        if (offsets == null || wetDepth == null || finalDrop == null ||
            offsets.Length != count || wetDepth.Length != count || finalDrop.Length != count)
            throw new ArgumentException("Drawdown arrays must match the source lattice.");
        this.nx = nx; this.nz = nz; this.offsets = offsets; this.wetDepth = wetDepth;
        Potential = new float[count]; source = new int[count];
        reserve = new float[count];
        var distance = new float[count];
        for (int i = 0; i < count; i++)
        {
            if (!Finite(offsets[i].x) || !Finite(offsets[i].y) || !Finite(wetDepth[i]) || !Finite(finalDrop[i]))
                throw new ArgumentException("Drawdown samples must be finite.");
            distance[i] = float.PositiveInfinity; source[i] = -1;
            reserve[i] = Reserved(wetDepth[i]);
        }
        var seeds = new List<Crest>();
        var heap = new Heap(distance);
        for (int z = 0; z < nz; z++)
        for (int x = 0; x < nx; x++)
        {
            int a = z * nx + x;
            if (x + 1 < nx) Seed(a, a + 1);
            if (z + 1 < nz) Seed(a, a + nx);
            if (x + 1 < nx && z > 0) Seed(a, a - nx + 1);
        }
        crests = seeds.ToArray();
        drivers = new float[crests.Length];
        if (crests.Length == 0)
        {
            active = drivenSources = Array.Empty<int>();
            return;
        }
        Flood(distance, source, heap);

        bool reachesEdge = false;
        for (int z = 0; z < nz; z++)
        for (int x = 0; x < nx; x++)
            if ((x == 0 || x == nx - 1 || z == 0 || z == nz - 1) && source[z * nx + x] >= 0)
                reachesEdge = true;
        float[] boundary = null;
        if (reachesEdge)
        {
            boundary = new float[count];
            var boundaryHeap = new Heap(boundary);
            for (int i = 0; i < count; i++) boundary[i] = float.PositiveInfinity;
            for (int z = 0; z < nz; z++)
            for (int x = 0; x < nx; x++)
                if ((x == 0 || x == nx - 1 || z == 0 || z == nz - 1) && wetDepth[z * nx + x] > DryDepth)
                {
                    int i = z * nx + x;
                    boundary[i] = 0f; boundaryHeap.Decrease(i);
                }
            Flood(boundary, null, boundaryHeap);
        }
        var activeNodes = new List<int>();
        var used = new bool[crests.Length];
        var sourceNodes = new List<int>();
        for (int i = 0; i < count; i++)
        {
            if (source[i] < 0 || wetDepth[i] <= DryDepth) continue;
            Crest crest = crests[source[i]];
            // Retain a short constant band inside the crest, then retire the
            // bank field within the same finite support as the wet approach.
            float approach = finalDrop[i] >= CrestDrop
                ? Fade(Mathf.Max(0f, distance[i] - 2f) / (crest.Length - 2f))
                : Fade(distance[i] / crest.Length);
            float edge = boundary == null ? 1f : Mathf.SmoothStep(0f, 1f, Mathf.Clamp01(boundary[i] / crest.Length));
            float desired = crest.Target * approach * edge;
            Potential[i] = Mathf.Min(desired, Available(wetDepth[i], finalDrop[i]));
            if (Potential[i] <= 0f) continue;
            activeNodes.Add(i);
            if (!used[source[i]])
            {
                used[source[i]] = true;
                sourceNodes.Add(source[i]);
            }
        }
        edgeLimits = BuildEdgeLimits();
        shoreEdges = LimitSlopes(Potential,finalDrop);
        activeNodes.RemoveAll(i => Potential[i] <= 0f);
        active = activeNodes.ToArray(); drivenSources = sourceNodes.ToArray();
        // Each section follows the crest it feeds. Only boundaries between
        // different drivers can acquire a new kink as their slabs move apart.
        var boundaries = new List<(int, int, float)>();
        foreach (int a in active)
        {
            int x = a % nx, z = a / nx;
            if (x+1 < nx) Boundary(a,a+1);
            if (z+1 < nz) Boundary(a,a+nx);
            if (x+1 < nx && z > 0) Boundary(a,a-nx+1);
        }
        divides = boundaries.ToArray();
        repair = new Heap(Potential);

        void Boundary(int a,int b)
        {
            if (Potential[b] > 0f && source[a] != source[b])
                boundaries.Add((a,b,EdgeLimit(a,b)));
        }

        void Seed(int a, int b)
        {
            float da = finalDrop[a], db = finalDrop[b];
            if ((da < CrestDrop) == (db < CrestDrop)) return;
            float blend = (CrestDrop - da) / (db - da);
            float depth = Mathf.LerpUnclamped(wetDepth[a], wetDepth[b], blend);
            if (depth <= DryDepth) return;
            int id = seeds.Count;
            float length = (offsets[b] - offsets[a]).magnitude;
            seeds.Add(new Crest(a, b, blend, depth));
            Offer(a, length * blend); Offer(b, length * (1f - blend));
            void Offer(int node, float candidate)
            {
                if (wetDepth[node] <= DryDepth || candidate > Support || candidate >= distance[node]) return;
                distance[node] = candidate; source[node] = id; heap.Decrease(node);
            }
        }
    }

    internal void Evaluate(float[] animatedDrops, float[] lowering)
    {
        if (animatedDrops == null || lowering == null || animatedDrops.Length != Potential.Length || lowering.Length != Potential.Length)
            throw new ArgumentException("Animated drawdown arrays must match the source lattice.");
        if (ReferenceEquals(animatedDrops, lowering) || ReferenceEquals(Potential, lowering))
            throw new ArgumentException("Drawdown output must not overwrite motion or bank potential.");
        Array.Clear(lowering, 0, lowering.Length);
        bool moving = false;
        foreach (int id in drivenSources)
        {
            Crest crest = crests[id];
            if (!Finite(animatedDrops[crest.A]) || !Finite(animatedDrops[crest.B]))
                throw new ArgumentException("Animated crest displacement must be finite.");
            float motion = Mathf.LerpUnclamped(animatedDrops[crest.A], animatedDrops[crest.B], crest.Blend);
            drivers[id] = Mathf.SmoothStep(0f, 1f, Mathf.Clamp01(motion / CrestDrop));
            moving |= drivers[id] > 0f;
        }
        if (!moving) return;
        repair.Reset(lowering);
        foreach (int i in active)
        {
            float driver = drivers[source[i]];
            if (driver <= 0f) continue;
            if (!Finite(animatedDrops[i])) throw new ArgumentException("Animated drawdown must be finite.");
            float bed = Mathf.Max(0f, wetDepth[i] + animatedDrops[i] - reserve[i]);
            float desired = Potential[i] * driver;
            lowering[i] = Mathf.Min(desired, bed);
            if (bed < desired) repair.Decrease(i);
        }
        foreach (var shore in shoreEdges)
        {
            float coast = Mathf.LerpUnclamped(animatedDrops[shore.Wet],animatedDrops[shore.Dry],shore.Fraction);
            float limit = coast + shore.Limit;
            if (lowering[shore.Wet] <= limit) continue;
            lowering[shore.Wet] = limit;
            repair.Decrease(shore.Wet);
        }
        foreach (var edge in divides)
        {
            int a = edge.A, b = edge.B;
            if (lowering[a] > lowering[b]) (a,b) = (b,a);
            float limit = lowering[a] + edge.Limit;
            if (lowering[b] <= limit) continue;
            lowering[b] = limit;
            repair.Decrease(b);
        }
        RepairSlopes(lowering);
    }

    // The owner clears the output when a shoreline is reclassified. Its
    // inactive cells stay at sea level in both cached authored frames.
    internal void Blend(float[] from, float[] to, float blend, float[] output)
    {
        foreach (int i in active) output[i] = Mathf.LerpUnclamped(from[i],to[i],blend);
    }

    // A shallower receiver or a still-moving neighboring crest can lower the
    // allowed approach at a boundary. Propagate only the affected edges.
    private void RepairSlopes(float[] values)
    {
        while (repair.Count > 0)
        {
            int a = repair.Pop(), x = a % nx, z = a / nx;
            if (x > 0) RepairEdge(a, a - 1, values);
            if (x + 1 < nx) RepairEdge(a, a + 1, values);
            if (z > 0) RepairEdge(a, a - nx, values);
            if (z + 1 < nz) RepairEdge(a, a + nx, values);
            if (x + 1 < nx && z > 0) RepairEdge(a, a - nx + 1, values);
            if (x > 0 && z + 1 < nz) RepairEdge(a, a + nx - 1, values);
        }
    }

    private void RepairEdge(int a, int b, float[] values)
    {
        if (Potential[b] <= 0f) return;
        float limit = values[a] + EdgeLimit(a,b);
        if (values[b] <= limit) return;
        values[b] = limit;
        repair.Decrease(b);
    }

    // The lower envelope is the largest field below every original target
    // whose wet-edge grade stays bounded. Only excessive heights are reduced.
    private (int Wet, int Dry, float Fraction, float Limit)[] LimitSlopes(float[] values,float[] finalDrop)
    {
        var shores = new List<(int, int, float, float)>();
        for (int z = 0; z < nz; z++)
        for (int x = 0; x < nx; x++)
        {
            int a = z * nx + x;
            if (x + 1 < nx) Shore(a, a + 1);
            if (z + 1 < nz) Shore(a, a + nx);
            if (x + 1 < nx && z > 0) Shore(a, a - nx + 1);
        }
        var heap = new Heap(values);
        for (int i = 0; i < values.Length; i++) if (wetDepth[i] > DryDepth) heap.Decrease(i);
        while (heap.Count > 0)
        {
            int a = heap.Pop(), x = a % nx, z = a / nx;
            if (x > 0) Constrain(a, a - 1);
            if (x + 1 < nx) Constrain(a, a + 1);
            if (z > 0) Constrain(a, a - nx);
            if (z + 1 < nz) Constrain(a, a + nx);
            if (x + 1 < nx && z > 0) Constrain(a, a - nx + 1);
            if (x > 0 && z + 1 < nz) Constrain(a, a + nx - 1);
            void Constrain(int from, int to)
            {
                if (wetDepth[to] <= DryDepth) return;
                float limit = values[from] + EdgeLimit(from,to);
                if (values[to] <= limit) return;
                values[to] = limit; heap.Decrease(to);
            }
        }
        return shores.ToArray();

        void Shore(int a, int b)
        {
            bool wa = wetDepth[a] > DryDepth, wb = wetDepth[b] > DryDepth;
            if (wa == wb) return;
            if (!wa) (a, b) = (b, a);
            if (values[a] <= 0f) return;
            // The original coast stays fixed in XZ but moves vertically with
            // its slab. Anchor the approach at the actual wet/dry crossing.
            float wetFraction = (wetDepth[a] - DryDepth) / (wetDepth[a] - wetDepth[b]);
            float allowance = wetFraction * EdgeLimit(a,b);
            float coast = Mathf.LerpUnclamped(finalDrop[a],finalDrop[b],wetFraction);
            values[a] = Mathf.Min(values[a], coast + allowance);
            shores.Add((a,b,wetFraction,allowance));
        }
    }

    // On a sheared fault the three edges can point in nearly the same
    // direction. Small height changes along all three can still tilt the
    // triangle steeply across its narrow dimension. For a triangle whose
    // largest angle is A, at least one edge sees cos(A/2) of any gradient.
    private Vector3[] BuildEdgeLimits()
    {
        var limits = new Vector3[offsets.Length];
        for (int i = 0; i < limits.Length; i++) limits[i] = Vector3.positiveInfinity;
        for (int z = 0; z < nz-1; z++)
        for (int x = 0; x < nx-1; x++)
        {
            int a = z*nx+x, b = a+1, c = a+nx, d = c+1;
            float diagonal = (offsets[c]-offsets[b]).magnitude;
            float ab = (offsets[b]-offsets[a]).magnitude, ac = (offsets[c]-offsets[a]).magnitude;
            float bd = (offsets[d]-offsets[b]).magnitude, cd = (offsets[d]-offsets[c]).magnitude;
            float lower = FaceEdgeGrade(ab,ac,diagonal), upper = FaceEdgeGrade(bd,cd,diagonal);
            limits[a].x = Mathf.Min(limits[a].x, lower*ab);
            limits[a].y = Mathf.Min(limits[a].y, lower*ac);
            limits[a].z = Mathf.Min(lower,upper)*diagonal;
            limits[b].y = Mathf.Min(limits[b].y, upper*bd);
            limits[c].x = Mathf.Min(limits[c].x, upper*cd);
        }
        return limits;
    }

    private static float FaceEdgeGrade(double a, double b, double c)
    {
        // Half-angle formula with c opposite the largest angle.
        if (a > c) (a,c) = (c,a);
        if (b > c) (b,c) = (c,b);
        if (a*b <= 0d) return 0f;
        double s = (a+b+c)*.5d;
        double cosine = Math.Sqrt(Math.Max(0d,s*(s-c)/(a*b)));
        return Mathf.Min(MaximumGrade,(float)(MaximumFaceGrade*cosine));
    }

    private float EdgeLimit(int a,int b)
    {
        int lo = Math.Min(a,b), hi = Math.Max(a,b);
        if (hi-lo == nx) return edgeLimits[lo].y;
        if (hi-lo == 1 && lo%nx < nx-1) return edgeLimits[lo].x;
        return edgeLimits[lo-1].z;
    }

    private void Flood(float[] distance, int[] ownership, Heap heap)
    {
        while (heap.Count > 0)
        {
            int a = heap.Pop(), x = a % nx, z = a / nx;
            if (x > 0) Relax(a, a - 1, distance, ownership, heap);
            if (x + 1 < nx) Relax(a, a + 1, distance, ownership, heap);
            if (z > 0) Relax(a, a - nx, distance, ownership, heap);
            if (z + 1 < nz) Relax(a, a + nx, distance, ownership, heap);
            if (x + 1 < nx && z > 0) Relax(a, a - nx + 1, distance, ownership, heap);
            if (x > 0 && z + 1 < nz) Relax(a, a + nx - 1, distance, ownership, heap);
        }
    }

    private void Relax(int a, int b, float[] distance, int[] ownership, Heap heap)
    {
        if (wetDepth[b] <= DryDepth) return;
        float candidate = distance[a] + (offsets[b] - offsets[a]).magnitude;
        if (candidate > Support || candidate >= distance[b]) return;
        distance[b] = candidate;
        if (ownership != null) ownership[b] = ownership[a];
        heap.Decrease(b);
    }

    // Preserve the intact shallow column, up to 35cm for native depth fade.
    // Originally dry shoreline samples remain dry regardless of core depth.
    internal static float Available(float originalDepth, float terrainDrop) => originalDepth <= DryDepth ? 0f
        : Mathf.Max(0f, originalDepth + terrainDrop - Reserved(originalDepth));

    private static float Reserved(float originalDepth) => Mathf.Max(DryDepth, Mathf.Min(.35f, originalDepth));

    private static float Fade(float distance) => 1f - Mathf.SmoothStep(0f, 1f, Mathf.Clamp01(distance));
    private static bool Finite(float value) => !float.IsNaN(value) && !float.IsInfinity(value);

    // Bounded decrease-key queue: each lattice node occupies at most one slot.
    private sealed class Heap
    {
        private readonly int[] nodes, slots;
        private float[] distance;
        internal int Count { get; private set; }
        internal Heap(float[] distance)
        {
            this.distance = distance;
            nodes = new int[distance.Length]; slots = new int[distance.Length];
            for (int i = 0; i < slots.Length; i++) slots[i] = -1;
        }
        internal void Reset(float[] values)
        {
            while (Count > 0) slots[nodes[--Count]] = -1;
            distance = values;
        }
        internal void Decrease(int node)
        {
            int slot = slots[node];
            if (slot < 0) { slot = Count++; nodes[slot] = node; slots[node] = slot; }
            while (slot > 0)
            {
                int parent = (slot - 1) / 2;
                if (distance[nodes[parent]] <= distance[node]) break;
                Swap(slot, parent); slot = parent;
            }
        }
        internal int Pop()
        {
            int node = nodes[0];
            Count--;
            slots[node] = -1;
            if (Count == 0) return node;
            nodes[0] = nodes[Count]; slots[nodes[0]] = 0;
            int slot = 0;
            while (slot * 2 + 1 < Count)
            {
                int next = slot * 2 + 1;
                if (next + 1 < Count && distance[nodes[next + 1]] < distance[nodes[next]]) next++;
                if (distance[nodes[slot]] <= distance[nodes[next]]) break;
                Swap(slot, next); slot = next;
            }
            return node;
        }
        private void Swap(int a, int b)
        {
            int node = nodes[a]; nodes[a] = nodes[b]; nodes[b] = node;
            slots[nodes[a]] = a; slots[nodes[b]] = b;
        }
    }
}
