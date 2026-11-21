using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using Object = UnityEngine.Object;

namespace ScomShatter;

// Horizontal cuts belong to the original shoreline and motion envelope. Only
// height/opacity change during collapse, so the sea never chases a moving cut.
internal sealed class ShorelineMesh : IDisposable
{
    internal const float DryDepth = .02f, MovingDrop = .15f;
    private const float FinalLip = CampaignMotion.LipDrop;
    // Zero denotes no positive-area wet bank polygon.
    private const byte SuppliedBank = 1, ClosedPond = 2, DrainingBank = 3, UnvisitedBank = 4, QueuedBank = 5;
    private readonly int sourceCount;
    private readonly Sample[] samples;
    private readonly Vector3[] positions;
    private readonly Vector3[] waterControls;
    private readonly float[] originalDepth;
    private readonly bool[] draining;
    private readonly byte[] supplyFaces;
    private readonly int[] fullIndices, bankIndices;
    private readonly int columns;
    private readonly int[] bankTriangleStarts;
    private readonly Vector2 minXZ, maxXZ;
    private bool trimmed, disposed;
    private float isolatedCoverage = 1f;

    internal Mesh Aperture { get; private set; }
    internal Mesh Inlet { get; private set; }

    internal ShorelineMesh(int nx, int nz, Vector2 origin, Vector2[] offsets,
        float[] wetDepth, float[] reach, float[] finalDrop, float[] ownership, bool frozen,
        bool warped = false, Rect? clipBounds = null)
        : this(Prepare(nx, nz, origin, offsets, wetDepth, reach, finalDrop, ownership, frozen, warped, clipBounds)) { }

    // Prepared buffers transfer to one live mesh owner; Update edits these
    // arrays in place. Preparation itself touches no Unity objects or resources.
    internal sealed class Prepared
    {
        internal int SourceCount, Columns;
        internal Vector3[] MaskVertices, InletVertices;
        internal int[] MaskIndices, FullIndices, BankIndices;
        internal int[] BankTriangleStarts;
        internal Vector2[] UV;
        internal float[] OriginalDepth;
        internal Vector3[] Normals;
        internal Vector4[] Tangents;
        internal Sample[] Samples;
        internal bool[] Draining;
        internal byte[] SupplyFaces;
        internal Vector2 MinXZ, MaxXZ;
        internal Bounds MaskBounds;
        internal bool Claimed;
    }

    internal ShorelineMesh(Prepared data)
    {
        if (data == null) throw new ArgumentNullException(nameof(data));
        if (data.Claimed) throw new InvalidOperationException("Prepared shoreline buffers already have an owner.");
        data.Claimed = true;
        sourceCount = data.SourceCount;
        samples = data.Samples;
        positions = data.InletVertices;
        originalDepth = data.OriginalDepth;
        draining = data.Draining;
        supplyFaces = data.SupplyFaces;
        waterControls = new Vector3[positions.Length];
        fullIndices = data.FullIndices;
        bankIndices = data.BankIndices;
        columns = data.Columns;
        bankTriangleStarts = data.BankTriangleStarts;
        minXZ = data.MinXZ; maxXZ = data.MaxXZ;
        try
        {
            Aperture = NewMesh("Fixed fracture sea aperture");
            Aperture.SetVertices(data.MaskVertices);
            Aperture.SetTriangles(data.MaskIndices, 0, false);
            Aperture.bounds = data.MaskBounds;
            Inlet = NewMesh("Sloping fracture sea inlet");
            Inlet.MarkDynamic();
            Inlet.SetVertices(positions);
            Inlet.SetNormals(data.Normals);
            Inlet.SetTangents(data.Tangents);
            Inlet.SetUVs(0, data.UV);
            Inlet.SetUVs(2, waterControls);
            Inlet.SetTriangles(fullIndices, 0, false);
            Inlet.bounds = new Bounds(new Vector3((minXZ.x + maxXZ.x) * .5f, 0f, (minXZ.y + maxXZ.y) * .5f),
                new Vector3(maxXZ.x - minXZ.x, 0f, maxXZ.y - minXZ.y));
        }
        catch { Dispose(); throw; }
    }

    internal static Prepared Prepare(int nx, int nz, Vector2 origin, Vector2[] offsets,
        float[] wetDepth, float[] reach, float[] finalDrop, float[] ownership, bool frozen,
        bool warped = false, Rect? clipBounds = null, bool dryOnly = false, float[] guardedReach = null)
    {
        if (nx < 2 || nz < 2) throw new ArgumentOutOfRangeException(nameof(nx));
        int sourceCount = checked(nx * nz);
        CheckLength(offsets, sourceCount, nameof(offsets));
        CheckLength(wetDepth, sourceCount, nameof(wetDepth));
        CheckLength(reach, sourceCount, nameof(reach));
        CheckLength(finalDrop, sourceCount, nameof(finalDrop));
        CheckLength(ownership, sourceCount, nameof(ownership));
        if (!Finite(origin.x) || !Finite(origin.y)) throw new ArgumentException("The inlet origin must be finite.", nameof(origin));
        if (clipBounds.HasValue)
        {
            Rect bounds = clipBounds.Value;
            if (!Finite(bounds.xMin) || !Finite(bounds.xMax) || !Finite(bounds.yMin) || !Finite(bounds.yMax) ||
                bounds.width <= 0f || bounds.height <= 0f)
                throw new ArgumentException("Shoreline clipping bounds must be finite and nonempty.", nameof(clipBounds));
        }
        for (int i = 0; i < sourceCount; i++)
            if (!Finite(offsets[i].x) || !Finite(offsets[i].y) || !Finite(wetDepth[i]) ||
                !Finite(reach[i]) || !Finite(finalDrop[i]) || !Finite(ownership[i]))
                throw new ArgumentException("Shoreline samples must be finite.");

        if (!frozen && guardedReach == null) guardedReach = WaveGuard(nx,nz,reach);
        var topology = new Topology(nx, nz, offsets, wetDepth, reach, guardedReach, finalDrop, ownership, warped, clipBounds);
        Builder mask = topology.BuildAperture(frozen,dryOnly);
        Builder inlet = topology.BuildInlet(frozen || dryOnly);
        var data = new Prepared {
            SourceCount = sourceCount, Columns = nx, Samples = inlet.Samples.ToArray(),
            MaskVertices = mask.Vertices.ToArray(), MaskIndices = mask.Bank.ToArray(),
            InletVertices = inlet.Vertices.ToArray(), BankIndices = inlet.Bank.ToArray()
        };
        data.Normals = new Vector3[data.InletVertices.Length];
        data.Tangents = new Vector4[data.InletVertices.Length];
        data.UV = new Vector2[data.InletVertices.Length];
        data.OriginalDepth = new float[data.InletVertices.Length];
        Vector2 low = data.InletVertices.Length == 0 ? Vector2.zero
            : new Vector2(data.InletVertices[0].x, data.InletVertices[0].z);
        Vector2 high = low;
        for (int i = 0; i < data.InletVertices.Length; i++)
        {
            Vector2 point = new Vector2(data.InletVertices[i].x, data.InletVertices[i].z);
            Sample sample = data.Samples[i];
            data.OriginalDepth[i] = sample.Value(wetDepth);
            low = Vector2.Min(low, point); high = Vector2.Max(high, point);
            // UV0 and tangent basis of the shipped 4096 m ocean plane. The
            // FFT samples itself are addressed in world XZ by the water shader.
            data.UV[i] = Vector2.one - (origin + point) / 4096f;
            data.Normals[i] = Vector3.up;
            data.Tangents[i] = new Vector4(-1f,0f,0f,-1f);
        }
        data.MinXZ = low; data.MaxXZ = high;
        if (data.MaskVertices.Length != 0)
        {
            Vector3 min = data.MaskVertices[0], max = min;
            for (int i = 1; i < data.MaskVertices.Length; i++)
            { min = Vector3.Min(min, data.MaskVertices[i]); max = Vector3.Max(max, data.MaskVertices[i]); }
            data.MaskBounds = new Bounds((min + max) * .5f, max - min);
        }
        data.FullIndices = new int[data.BankIndices.Length + inlet.Deep.Count];
        Array.Copy(data.BankIndices, data.FullIndices, data.BankIndices.Length);
        inlet.Deep.CopyTo(data.FullIndices, data.BankIndices.Length);
        // Builder emits each source face's clipped fan consecutively, in grid order.
        data.BankTriangleStarts = data.BankIndices.Length == 0 ? Array.Empty<int>() : new int[sourceCount * 2 + 1];
        foreach (int face in inlet.BankFaces) data.BankTriangleStarts[face + 1]++;
        for (int face = 1; face < data.BankTriangleStarts.Length; face++)
            data.BankTriangleStarts[face] += data.BankTriangleStarts[face - 1];
        data.SupplyFaces = frozen || dryOnly ? Array.Empty<byte>() : BankSupply(topology, nx, nz, wetDepth, finalDrop, ownership);
        data.Draining = new bool[data.InletVertices.Length];
        for (int face = 0; data.SupplyFaces.Length > 0 && face < inlet.BankFaces.Count; face++)
        {
            if (data.SupplyFaces[inlet.BankFaces[face]] != DrainingBank) continue;
            int first = face * 3;
            data.Draining[data.BankIndices[first]] = true;
            data.Draining[data.BankIndices[first + 1]] = true;
            data.Draining[data.BankIndices[first + 2]] = true;
        }
        return data;
    }

    internal bool CanFeed(int sourceCell, float x, float z)
    {
        int face = sourceCell * 2 + (x + z > 1f ? 1 : 0);
        return face >= 0 && face < supplyFaces.Length && supplyFaces[face] == SuppliedBank;
    }

    internal bool HoldsWater(int sourceCell, float x, float z)
    {
        int face = sourceCell * 2 + (x + z > 1f ? 1 : 0);
        if (face < 0 || face >= supplyFaces.Length) return false;
        byte state = supplyFaces[face];
        return state == SuppliedBank || state == ClosedPond ||
            (state == DrainingBank && isolatedCoverage >= .01f);
    }

    // Heights must interpolate the final clipped triangles. Applying AboveBed
    // to interpolated inputs instead can select a different clamp between vertices.
    internal bool TryBankHeight(int sourceCell, float x, float z, out float height)
    {
        height = 0f;
        const float epsilon = .00001f;
        if (disposed || bankTriangleStarts.Length == 0 || !Finite(x) || !Finite(z) || sourceCell < 0 ||
            sourceCell >= sourceCount - columns - 1 || sourceCell % columns >= columns - 1 ||
            x < -epsilon || x > 1f + epsilon || z < -epsilon || z > 1f + epsilon) return false;
        x = Mathf.Clamp01(x); z = Mathf.Clamp01(z);
        int col = sourceCell % columns, row = sourceCell / columns;
        int left = x <= epsilon && col > 0 ? -1 : 0;
        int right = x >= 1f - epsilon && col < columns - 2 ? 1 : 0;
        int bottom = z <= epsilon && row > 0 ? -1 : 0;
        int top = z >= 1f - epsilon && row < sourceCount / columns - 2 ? 1 : 0;
        if (TryCell(sourceCell, x, z, out height)) return true;
        // A clipped polygon can have positive area on only one side of a shared
        // edge. Visit neighbours only at that edge, never as an outside-face fallback.
        for (int dz = bottom; dz <= top; dz++) for (int dx = left; dx <= right; dx++)
            if ((dx != 0 || dz != 0) && TryCell(sourceCell + dz * columns + dx, x - dx, z - dz, out height)) return true;
        return false;
    }

    private bool TryCell(int cell, float x, float z, out float height)
    {
        int face = cell * 2 + (x + z > 1f ? 1 : 0);
        if (TryFace(face, cell, x, z, out height)) return true;
        return Mathf.Abs(x + z - 1f) <= .00001f && TryFace(face ^ 1, cell, x, z, out height);
    }

    private bool TryFace(int face, int cell, float x, float z, out float height)
    {
        height = 0f;
        for (int triangle = bankTriangleStarts[face]; triangle < bankTriangleStarts[face + 1]; triangle++)
        {
            int index = triangle * 3;
            int ia = bankIndices[index], ib = bankIndices[index + 1], ic = bankIndices[index + 2];
            Vector2 a = SourcePosition(samples[ia], cell), b = SourcePosition(samples[ib], cell), c = SourcePosition(samples[ic], cell);
            double bx = b.x - a.x, bz = b.y - a.y, cx = c.x - a.x, cz = c.y - a.y;
            double det = bx * cz - bz * cx;
            if (Math.Abs(det) < 1e-16) continue;
            double px = x - a.x, pz = z - a.y;
            double wb = (px * cz - pz * cx) / det, wc = (bx * pz - bz * px) / det, wa = 1d - wb - wc;
            if (wa < -.00001d || wb < -.00001d || wc < -.00001d) continue;
            // Clamp only rounding at an accepted boundary, rather than extrapolating.
            wa = Math.Max(0d, wa); wb = Math.Max(0d, wb); wc = Math.Max(0d, wc);
            double sum = wa + wb + wc;
            wa /= sum; wb /= sum; wc /= sum;
            double coverage = waterControls[ia].x * wa + waterControls[ib].x * wb + waterControls[ic].x * wc;
            if (coverage < .01d) continue;
            height = (float)(positions[ia].y * wa + positions[ib].y * wb + positions[ic].y * wc);
            return true;
        }
        return false;
    }

    private Vector2 SourcePosition(Sample sample, int cell)
    {
        int x = cell % columns, z = cell / columns;
        Vector3 w = sample.Weights;
        return new Vector2((sample.A % columns - x) * w.x + (sample.B % columns - x) * w.y + (sample.C % columns - x) * w.z,
            (sample.A / columns - z) * w.x + (sample.B / columns - z) * w.y + (sample.C / columns - z) * w.z);
    }

    // The two linear shoreline/crest constraints leave a convex bank polygon
    // in each source triangle. Join triangles only across a positive wet edge,
    // retaining channels that have no surviving original lattice corner.
    private static byte[] BankSupply(Topology topology, int nx, int nz, float[] depth, float[] final, float[] ownership)
    {
        int count = nx * nz * 2;
        var state = new byte[count];
        var queue = new int[count];
        for (int z = 0; z < nz - 1; z++)
        for (int x = 0; x < nx - 1; x++)
        {
            int p = z * nx + x;
            Mark(2 * p, p, p + 1, p + nx);
            Mark(2 * p + 1, p + 1, p + nx + 1, p + nx);
        }
        for (int start = 0; start < count; start++)
        {
            if (state[start] != UnvisitedBank) continue;
            int read = 0, written = 0;
            bool fed = false, outlet = false;
            state[start] = QueuedBank; queue[written++] = start;
            while (read < written)
            {
                int face = queue[read++], p = face / 2, x = p % nx, z = p / nx;
                int a, b, c;
                if ((face & 1) == 0)
                {
                    a = p; b = p + 1; c = p + nx;
                    Edge(a, b, z > 0 ? 2 * (p - nx) + 1 : -1);
                    Edge(a, c, x > 0 ? 2 * (p - 1) + 1 : -1);
                    Edge(b, c, face + 1);
                }
                else
                {
                    a = p + 1; b = p + nx + 1; c = p + nx;
                    Edge(a, b, x + 1 < nx - 1 ? 2 * (p + 1) : -1);
                    Edge(b, c, z + 1 < nz - 1 ? 2 * (p + nx) : -1);
                    Edge(a, c, face - 1);
                }
                // An overlap boundary may continue into a neighbouring site's
                // wet bank. Never drain that shared coast from this site alone.
                fed |= ownership[a] <= .0001f || ownership[b] <= .0001f || ownership[c] <= .0001f;
                fed |= topology.HasBank(a, b, c, true);
                outlet |= WetCrest(a, b) || WetCrest(b, c) || WetCrest(c, a);
                void Edge(int u, int v, int other)
                {
                    if (!topology.SupportEdge(u, v)) return;
                    if (other < 0) { fed = true; return; }
                    if (final[u] == FinalLip && final[v] == FinalLip)
                    {
                        int q = other / 2;
                        outlet |= (other & 1) == 0 ? topology.HasWetOpening(q, q + 1, q + nx)
                            : topology.HasWetOpening(q + 1, q + nx + 1, q + nx);
                    }
                    if (state[other] != UnvisitedBank) return;
                    state[other] = QueuedBank; queue[written++] = other;
                }
            }
            byte result = fed ? SuppliedBank : outlet ? DrainingBank : ClosedPond;
            for (int i = 0; i < written; i++) state[queue[i]] = result;
        }
        return state;

        void Mark(int face, int a, int b, int c)
        {
            if (topology.HasBank(a, b, c, false)) state[face] = UnvisitedBank;
        }
        bool WetCrest(int a, int b)
        {
            if (Mathf.Max(final[a], final[b]) <= FinalLip ||
                (final[a] < FinalLip) == (final[b] < FinalLip) || final[a] == final[b]) return false;
            float t = (FinalLip - final[a]) / (final[b] - final[a]);
            return Mathf.LerpUnclamped(depth[a], depth[b], t) > DryDepth;
        }
    }

    private static bool Interval(float a, float b, ref float lo, ref float hi)
    {
        if (a < 0f && b < 0f) return false;
        if (a >= 0f && b >= 0f) return true;
        float t = a / (a - b);
        if (a < 0f) lo = Mathf.Max(lo, t); else hi = Mathf.Min(hi, t);
        return hi > lo;
    }

    internal static float[] FeederReach(int nx, int nz, float[] slabReach, float[] target)
    {
        var reach = (float[])slabReach.Clone();
        // Include one ring of still water. Every triangle at the native sea
        // seam then has zero drawdown and full wave displacement.
        for (int i = 0; i < target.Length; i++)
        {
            if (target[i] <= 0f) continue;
            int x = i % nx, z = i / nx;
            for (int row = Math.Max(0,z-1); row <= Math.Min(nz-1,z+1); row++)
            for (int col = Math.Max(0,x-1); col <= Math.Min(nx-1,x+1); col++)
            {
                int j = row*nx+col;
                reach[j] = Mathf.Max(1f,reach[j]);
            }
        }
        return reach;
    }

    internal static float AboveBed(float lowering, float depth, float terrainDrop)
    {
        // The approaching current takes part of the hydraulic head. At the
        // falling lip the original water column travels fully with the rock.
        float available = depth <= DryDepth ? Mathf.Max(0f,terrainDrop) : InletDrawdown.Available(depth,terrainDrop);
        return Mathf.Min(Mathf.Max(terrainDrop,.6f*lowering),available);
    }

    // Waves move vertices sideways on the GPU. Give them spare geometry
    // outside the flat stencil edge; the private water pass clips the excess.
    internal static float[] WaveGuard(int nx, int nz, float[] aperture)
    {
        const int padding = 8;
        int stride = nx + 1;
        var counts = new int[stride * (nz + 1)];
        for (int z = 0; z < nz; z++)
        {
            int rowCount = 0;
            for (int x = 0; x < nx; x++)
            {
                if (aperture[z*nx+x] >= MovingDrop) rowCount++;
                counts[(z+1)*stride+x+1] = counts[z*stride+x+1] + rowCount;
            }
        }
        var result = new float[aperture.Length];
        for (int z = 0; z < nz; z++)
        {
            int top = Math.Max(0,z-padding)*stride, bottom = Math.Min(nz,z+padding+1)*stride;
            for (int x = 0; x < nx; x++)
            {
                int left = Math.Max(0,x-padding), right = Math.Min(nx,x+padding+1);
                int covered = counts[bottom+right]-counts[bottom+left]-counts[top+right]+counts[top+left];
                if (covered != 0) result[z*nx+x] = 1f;
            }
        }
        return result;
    }

    internal void Update(float[] drops, float[] bankLowering, float level, float progress)
    {
        if (disposed) return;
        CheckLength(drops, sourceCount, nameof(drops));
        CheckLength(bankLowering, sourceCount, nameof(bankLowering));
        if (!Finite(level) || !Finite(progress)) throw new ArgumentException("Inlet animation must be finite.");
        progress = Mathf.Clamp01(progress);
        bool settled = progress >= 1f;
        if (settled != trimmed)
        {
            // Do not retain triangles stretching from the bank to the chasm
            // floor after the transient falling sheet has disappeared.
            Inlet.SetTriangles(settled ? bankIndices : fullIndices, 0, false);
            trimmed = settled;
        }
        float drainage = Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(.82f, 1f, progress));
        isolatedCoverage = 1f - drainage;
        float minY = float.PositiveInfinity, maxY = float.NegativeInfinity;
        for (int i = 0; i < samples.Length; i++)
        {
            Sample sample = samples[i];
            float drop = sample.Value(drops);
            if (!Finite(drop)) throw new ArgumentException("Inlet displacement must be finite.", nameof(drops));
            float lowering = AboveBed(sample.Value(bankLowering), originalDepth[i], drop);
            float y = level - lowering;
            positions[i].y = y;
            if (settled && sample.Deep) { waterControls[i] = Vector3.zero; continue; }
            minY = Mathf.Min(minY, y); maxY = Mathf.Max(maxY, y);
            // The ordinary ocean owns its own shoreline transparency. Supply
            // full coverage until this water actually starts falling. Its live
            // FFT displacement tapers to zero where the waterfall takes over.
            // Full FFT motion belongs to the open sea. Once the bank is down
            // a metre, a wave must no longer lift the inlet above its ledge.
            float wave = Mathf.SmoothStep(1f, 0f, lowering);
            float coverage = sample.Deep ? (1f - drainage*(1f-wave)) *
                (1f - Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(6f, 14f, drop))) : 1f;
            if (draining[i]) coverage *= 1f - drainage;
            // Logical lowering separates the flat FFT guard from depressed
            // water in the private pass, without a camera-plane ownership test.
            waterControls[i] = new Vector3(coverage, wave, lowering);
        }
        Inlet.SetVertices(positions);
        Inlet.SetUVs(2, waterControls);
        if (float.IsPositiveInfinity(minY)) minY = maxY = level;
        var bounds = new Bounds(new Vector3((minXZ.x + maxXZ.x) * .5f, (minY + maxY) * .5f,
            (minXZ.y + maxXZ.y) * .5f), new Vector3(maxXZ.x - minXZ.x, maxY - minY, maxXZ.y - minXZ.y));
        // Native FFT waves displace the flat-side vertices on the GPU after culling.
        bounds.Expand(4f);
        Inlet.bounds = bounds;
    }

    private static Mesh NewMesh(string name) => new Mesh {
        name = name, indexFormat = IndexFormat.UInt32, hideFlags = HideFlags.HideAndDontSave
    };

    private static void CheckLength<T>(T[] values, int count, string name)
    {
        if (values == null || values.Length != count) throw new ArgumentException("Shoreline arrays must match the lattice.", name);
    }

    private static bool Finite(float value) => !float.IsNaN(value) && !float.IsInfinity(value);

    public void Dispose()
    {
        if (disposed) return;
        disposed = true;
        if (Aperture != null) Object.Destroy(Aperture);
        if (Inlet != null) Object.Destroy(Inlet);
        Aperture = Inlet = null;
    }

    internal readonly struct Sample
    {
        internal readonly int A, B, C;
        internal readonly Vector3 Weights;
        internal readonly bool Deep;
        internal Sample(int a, int b, int c, Vector3 weights, bool deep)
        { A = a; B = b; C = c; Weights = weights; Deep = deep; }
        internal float Value(float[] values) => A == B && B == C ? values[A]
            : values[A] * Weights.x + values[B] * Weights.y + values[C] * Weights.z;
    }

    private readonly struct Point
    {
        internal readonly Vector3 Weights;
        internal readonly int Corner;
        internal Point(Vector3 weights, int corner = -1) { Weights = weights; Corner = corner; }
    }

    private readonly struct EdgeKey : IEquatable<EdgeKey>
    {
        private readonly int a, b;
        private readonly float t;
        private readonly bool deep;
        internal EdgeKey(int a, int b, float t, bool deep) { this.a = a; this.b = b; this.t = t; this.deep = deep; }
        public bool Equals(EdgeKey other) => a == other.a && b == other.b && t == other.t && deep == other.deep;
        public override bool Equals(object other) => other is EdgeKey key && Equals(key);
        public override int GetHashCode() { unchecked { return (((a * 397) ^ b) * 397 ^ t.GetHashCode()) * 397 ^ (deep ? 1 : 0); } }
    }

    private sealed class Builder
    {
        internal readonly List<Vector3> Vertices = new List<Vector3>();
        internal readonly List<Sample> Samples = new List<Sample>();
        internal readonly List<int> Bank = new List<int>(), Deep = new List<int>();
        internal readonly List<int> BankFaces = new List<int>();
        private readonly Vector2[] offsets;
        private readonly bool animated;
        private readonly int[] bankCorners, deepCorners;
        private readonly Dictionary<EdgeKey, int> edges = new Dictionary<EdgeKey, int>();
        private readonly int[] polygonIndices = new int[12];
        private int sourceFace;

        internal Builder(Vector2[] offsets, bool animated)
        {
            this.offsets = offsets; this.animated = animated;
            bankCorners = new int[offsets.Length];
            deepCorners = animated ? new int[offsets.Length] : bankCorners;
            for (int i = 0; i < offsets.Length; i++) { bankCorners[i] = -1; deepCorners[i] = -1; }
        }

        internal void Quad(int a, int b, int c, int d)
        {
            int i = Vertex(new Point(Vector3.right, a), a, a, a, false);
            int j = Vertex(new Point(Vector3.right, b), b, b, b, false);
            int k = Vertex(new Point(Vector3.right, c), c, c, c, false);
            int l = Vertex(new Point(Vector3.right, d), d, d, d, false);
            Triangle(i, j, k, false); Triangle(j, l, k, false);
        }

        internal void Polygon(Point[] polygon, int count, int a, int b, int c, bool deep)
        {
            if (count < 3) return;
            sourceFace = b == a + 1 ? 2 * a : 2 * (a - 1) + 1;
            for (int i = 0; i < count; i++) polygonIndices[i] = Vertex(polygon[i], a, b, c, deep);
            for (int i = 1; i < count - 1; i++) Triangle(polygonIndices[0], polygonIndices[i], polygonIndices[i + 1], deep);
        }

        private int Vertex(Point point, int a, int b, int c, bool deep)
        {
            int[] corners = deep ? deepCorners : bankCorners;
            if (point.Corner >= 0 && corners[point.Corner] >= 0) return corners[point.Corner];
            Vector3 w = point.Weights;
            bool onEdge = false;
            EdgeKey key = default;
            if (point.Corner < 0)
            {
                int u = 0, v = 0; float wu = 0f, wv = 0f;
                if (w.x == 0f) { u = b; v = c; wu = w.y; wv = w.z; onEdge = true; }
                else if (w.y == 0f) { u = a; v = c; wu = w.x; wv = w.z; onEdge = true; }
                else if (w.z == 0f) { u = a; v = b; wu = w.x; wv = w.y; onEdge = true; }
                if (onEdge)
                {
                    key = u < v ? new EdgeKey(u, v, wv, deep) : new EdgeKey(v, u, wu, deep);
                    if (edges.TryGetValue(key, out int existing)) return existing;
                }
            }
            Vector2 offset = point.Corner >= 0 ? offsets[point.Corner]
                : offsets[a] * w.x + offsets[b] * w.y + offsets[c] * w.z;
            int index = Vertices.Count;
            Vertices.Add(new Vector3(offset.x, 0f, offset.y));
            if (animated)
            {
                if (point.Corner >= 0) { a = b = c = point.Corner; w = Vector3.right; }
                Samples.Add(new Sample(a, b, c, w, deep));
            }
            if (point.Corner >= 0) corners[point.Corner] = index;
            else if (onEdge) edges[key] = index;
            return index;
        }

        private void Triangle(int a, int b, int c, bool deep)
        {
            Vector3 x = Vertices[a], y = Vertices[b], z = Vertices[c];
            float area = (y.x - x.x) * (z.z - x.z) - (y.z - x.z) * (z.x - x.x);
            if (Mathf.Abs(area) < 1e-8f) return;
            List<int> target = deep ? Deep : Bank;
            target.Add(a);
            // A positive X/Z area has a negative Unity Y normal.
            target.Add(area > 0f ? c : b);
            target.Add(area > 0f ? b : c);
            if (animated && !deep) BankFaces.Add(sourceFace);
        }
    }

    private sealed class Topology
    {
        private readonly int nx, nz;
        private readonly Vector2[] offsets;
        private readonly float[] depth, reach, guard, final, ownership;
        private readonly bool warped;
        private readonly Rect? bounds;
        private readonly float[] xValues, zValues;
        private readonly Point[] first = new Point[12], second = new Point[12], saved = new Point[12];
        private readonly float[] distances = new float[12];
        private Point[] polygon, scratch;
        private int count, a, b, c;

        internal Topology(int nx, int nz, Vector2[] offsets, float[] depth, float[] reach, float[] guard, float[] final,
            float[] ownership, bool warped, Rect? bounds)
        {
            this.nx = nx; this.nz = nz; this.offsets = offsets;
            this.depth = depth; this.reach = reach; this.guard = guard; this.final = final; this.ownership = ownership;
            this.warped = warped; this.bounds = bounds;
            if (bounds.HasValue)
            {
                xValues = new float[offsets.Length]; zValues = new float[offsets.Length];
                for (int i = 0; i < offsets.Length; i++) { xValues[i] = offsets[i].x; zValues[i] = offsets[i].y; }
            }
        }

        internal Builder BuildAperture(bool frozen, bool dryOnly)
        {
            var result = new Builder(offsets, false);
            float[] moving = frozen ? final : reach;
            float threshold = frozen ? FinalLip : MovingDrop;
            for (int z = 0; z < nz - 1; z++)
            {
                int run = -1;
                for (int x = 0; x < nx; x++)
                {
                    int p = z * nx + x;
                    bool full = x < nx - 1 && (All(depth, p, DryDepth, false) || (!dryOnly && All(moving, p, threshold, true)));
                    bool inside = full && CellInsideBounds(p);
                    if (inside && !warped) { if (run < 0) run = p; continue; }
                    if (run >= 0) { result.Quad(run, p, run + nx, p + nx); run = -1; }
                    if (x == nx - 1) continue;
                    // Bent grid edges require every native lattice corner;
                    // merging a row would cut across the warped footprint.
                    if (inside) { result.Quad(p, p + 1, p + nx, p + nx + 1); continue; }
                    MaskTriangle(result, p, p + 1, p + nx, moving, threshold, dryOnly);
                    MaskTriangle(result, p + 1, p + nx + 1, p + nx, moving, threshold, dryOnly);
                }
            }
            return result;
        }

        private bool All(float[] field, int p, float threshold, bool above) => above
            ? field[p] >= threshold && field[p + 1] >= threshold && field[p + nx] >= threshold && field[p + nx + 1] >= threshold
            : field[p] <= threshold && field[p + 1] <= threshold && field[p + nx] <= threshold && field[p + nx + 1] <= threshold;

        private void MaskTriangle(Builder result, int i, int j, int k, float[] moving, float threshold, bool dryOnly)
        {
            if (OutsideBounds(i, j, k)) return;
            Begin(i, j, k);
            Clip(depth, DryDepth, false);
            ClipToBounds();
            result.Polygon(polygon, count, a, b, c, false);
            if (dryOnly) return;
            Begin(i, j, k);
            Clip(depth, DryDepth, true);
            Clip(moving, threshold, true);
            ClipToBounds();
            result.Polygon(polygon, count, a, b, c, false);
        }

        internal Builder BuildInlet(bool frozen)
        {
            var result = new Builder(offsets, true);
            if (frozen) return result;
            for (int z = 0; z < nz - 1; z++)
            for (int x = 0; x < nx - 1; x++)
            {
                int p = z * nx + x;
                InletTriangle(result, p, p + 1, p + nx);
                InletTriangle(result, p + 1, p + nx + 1, p + nx);
            }
            return result;
        }

        internal bool HasBank(int i, int j, int k, bool unmasked)
        {
            if (Mathf.Max(depth[i], Mathf.Max(depth[j], depth[k])) <= DryDepth || OutsideBounds(i, j, k)) return false;
            Begin(i, j, k);
            Clip(depth, DryDepth, true);
            Clip(final, FinalLip, false);
            ClipToBounds();
            if (unmasked) Clip(reach, MovingDrop - .00001f, false);
            return PositiveArea();
        }

        internal bool HasWetOpening(int i, int j, int k)
        {
            if (Mathf.Max(final[i], Mathf.Max(final[j], final[k])) <= FinalLip || OutsideBounds(i, j, k)) return false;
            Begin(i, j, k);
            Clip(depth, DryDepth, true);
            Clip(final, FinalLip, true);
            ClipToBounds();
            return PositiveArea();
        }

        private bool PositiveArea()
        {
            if (count < 3) return false;
            Vector2 origin = Offset(polygon[0]);
            float area = 0f;
            for (int n = 1; n < count - 1; n++)
            {
                Vector2 u = Offset(polygon[n]) - origin, v = Offset(polygon[n + 1]) - origin;
                area += Mathf.Abs(u.x * v.y - u.y * v.x);
            }
            return area > .000001f;
        }

        private Vector2 Offset(Point point) => point.Corner >= 0 ? offsets[point.Corner]
            : offsets[a] * point.Weights.x + offsets[b] * point.Weights.y + offsets[c] * point.Weights.z;

        internal bool SupportEdge(int i, int j)
        {
            if (i > j) (i, j) = (j, i);
            if (Mathf.Max(depth[i], depth[j]) <= DryDepth) return false;
            float lo = 0f, hi = 1f;
            if (!Interval(depth[i] - DryDepth, depth[j] - DryDepth, ref lo, ref hi) ||
                !Interval(FinalLip - final[i], FinalLip - final[j], ref lo, ref hi)) return false;
            if (bounds.HasValue)
            {
                Rect r = bounds.Value;
                if (!Interval(xValues[i] - r.xMin, xValues[j] - r.xMin, ref lo, ref hi) ||
                    !Interval(r.xMax - xValues[i], r.xMax - xValues[j], ref lo, ref hi) ||
                    !Interval(zValues[i] - r.yMin, zValues[j] - r.yMin, ref lo, ref hi) ||
                    !Interval(r.yMax - zValues[i], r.yMax - zValues[j], ref lo, ref hi)) return false;
            }
            return hi - lo > .00001f;
        }

        private void InletTriangle(Builder result, int i, int j, int k)
        {
            // A triangle lying entirely on the dry threshold belongs only to
            // the mask. Equality at an edge remains a shared zero-area border.
            if (depth[i] <= DryDepth && depth[j] <= DryDepth && depth[k] <= DryDepth) return;
            if ((guard[i] < MovingDrop && guard[j] < MovingDrop && guard[k] < MovingDrop) ||
                (ownership[i] < 0f && ownership[j] < 0f && ownership[k] < 0f) || OutsideBounds(i, j, k)) return;
            Begin(i, j, k);
            Clip(depth, DryDepth, true);
            Clip(guard, MovingDrop, true);
            Clip(ownership, 0f, true);
            ClipToBounds();
            if (count < 3) return;
            if (final[i] <= FinalLip && final[j] <= FinalLip && final[k] <= FinalLip)
            { result.Polygon(polygon, count, a, b, c, false); return; }
            if (final[i] > FinalLip && final[j] > FinalLip && final[k] > FinalLip)
            { result.Polygon(polygon, count, a, b, c, true); return; }
            int savedCount = count;
            Array.Copy(polygon, saved, count);
            Clip(final, FinalLip, false);
            result.Polygon(polygon, count, a, b, c, false);
            polygon = first; scratch = second; count = savedCount;
            Array.Copy(saved, polygon, count);
            Clip(final, FinalLip, true);
            result.Polygon(polygon, count, a, b, c, true);
        }

        private bool CellInsideBounds(int p) => !bounds.HasValue ||
            (InsideBounds(p) && InsideBounds(p + 1) && InsideBounds(p + nx) && InsideBounds(p + nx + 1));

        private bool InsideBounds(int p)
        {
            Rect r = bounds.Value;
            Vector2 v = offsets[p];
            return v.x >= r.xMin && v.x <= r.xMax && v.y >= r.yMin && v.y <= r.yMax;
        }

        private bool OutsideBounds(int i, int j, int k)
        {
            if (!bounds.HasValue) return false;
            Rect r = bounds.Value;
            return (xValues[i] < r.xMin && xValues[j] < r.xMin && xValues[k] < r.xMin) ||
                (xValues[i] > r.xMax && xValues[j] > r.xMax && xValues[k] > r.xMax) ||
                (zValues[i] < r.yMin && zValues[j] < r.yMin && zValues[k] < r.yMin) ||
                (zValues[i] > r.yMax && zValues[j] > r.yMax && zValues[k] > r.yMax);
        }

        private void ClipToBounds()
        {
            if (!bounds.HasValue || count == 0) return;
            Rect r = bounds.Value;
            Clip(xValues, r.xMin, true); Clip(xValues, r.xMax, false);
            Clip(zValues, r.yMin, true); Clip(zValues, r.yMax, false);
        }

        private void Begin(int i, int j, int k)
        {
            a = i; b = j; c = k; count = 3;
            polygon = first; scratch = second;
            polygon[0] = new Point(Vector3.right, a);
            polygon[1] = new Point(Vector3.up, b);
            polygon[2] = new Point(Vector3.forward, c);
        }

        private float Value(Point point, float[] field) => point.Corner >= 0 ? field[point.Corner]
            : field[a] * point.Weights.x + field[b] * point.Weights.y + field[c] * point.Weights.z;

        private void Clip(float[] field, float threshold, bool above)
        {
            if (count == 0) return;
            int inside = 0;
            for (int i = 0; i < count; i++)
            {
                float d = Value(polygon[i], field) - threshold;
                distances[i] = above ? d : -d;
                if (distances[i] >= 0f) inside++;
            }
            if (inside == count) return;
            if (inside == 0) { count = 0; return; }
            int written = 0;
            Point previous = polygon[count - 1];
            float previousDistance = distances[count - 1];
            for (int i = 0; i < count; i++)
            {
                Point current = polygon[i];
                float distance = distances[i];
                if ((distance >= 0f) != (previousDistance >= 0f))
                    Append(scratch, ref written, Crossing(previous, current, previousDistance, distance, field, threshold));
                if (distance >= 0f) Append(scratch, ref written, current);
                previous = current; previousDistance = distance;
            }
            if (written > 1 && scratch[0].Weights.Equals(scratch[written - 1].Weights)) written--;
            Point[] swap = polygon; polygon = scratch; scratch = swap;
            count = written;
        }

        private static void Append(Point[] target, ref int count, Point point)
        {
            if (count == 0 || !target[count - 1].Weights.Equals(point.Weights)) target[count++] = point;
        }

        private Point Crossing(Point left, Point right, float dl, float dr, float[] field, float threshold)
        {
            float t = dl / (dl - dr);
            if (t <= 0f) return left;
            if (t >= 1f) return right;
            Vector3 l = left.Weights, r = right.Weights;
            int u = -1, v = -1;
            if (l.x == 0f && r.x == 0f) { u = b; v = c; }
            else if (l.y == 0f && r.y == 0f) { u = a; v = c; }
            else if (l.z == 0f && r.z == 0f) { u = a; v = b; }
            if (u < 0) return new Point(Vector3.LerpUnclamped(l, r, t));
            // Canonical source-edge direction makes adjacent triangles share
            // identical contour positions, even after several clipping planes.
            if (u > v) (u, v) = (v, u);
            float span = field[v] - field[u];
            if (span == 0f) return new Point(Vector3.LerpUnclamped(l, r, t));
            t = Mathf.Clamp01((threshold - field[u]) / span);
            if (t == 0f) return Corner(u);
            if (t == 1f) return Corner(v);
            Vector3 weights = Vector3.zero;
            if (u == a) weights.x = 1f - t;
            else if (u == b) weights.y = 1f - t;
            else weights.z = 1f - t;
            if (v == a) weights.x = t;
            else if (v == b) weights.y = t;
            else weights.z = t;
            return new Point(weights);
        }

        private Point Corner(int index) => new Point(index == a ? Vector3.right : index == b ? Vector3.up : Vector3.forward, index);
    }
}
