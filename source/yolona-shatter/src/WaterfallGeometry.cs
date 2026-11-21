using System;
using System.Collections.Generic;
using UnityEngine;

namespace ScomShatter;

// The horizontal velocity at the lip and gravity determine each stream's arc.
// Intersect that arc with the displaced ground before submitting the water mesh.
internal sealed class WaterfallGeometry
{
    internal sealed class Surface
    {
        internal readonly List<Vector3> Vertices = new List<Vector3>(), Normals = new List<Vector3>();
        internal readonly List<Vector4> Tangents = new List<Vector4>(), UV = new List<Vector4>();
        internal readonly List<Color> Colors = new List<Color>();
        internal readonly List<int> Indices = new List<int>();

        internal void Clear()
        {
            Vertices.Clear(); Normals.Clear(); Tangents.Clear(); UV.Clear(); Colors.Clear(); Indices.Clear();
        }

        internal void Vertex(Vector3 p, Vector3 normal, Vector2 tangent, float u, float v, float alpha)
        {
            Vertices.Add(p);
            Normals.Add(normal);
            Tangents.Add(new Vector4(tangent.x, 0f, tangent.y, 1f));
            UV.Add(new Vector4(u, v, 0f, 0f));
            Colors.Add(new Color(1f, 1f, 1f, Mathf.Clamp01(alpha)));
        }

        internal void Connect(int start, int rowCount)
        {
            for (int r = 1; r < rowCount; ++r)
            {
                int a = start + (r - 1) * 2;
                Indices.Add(a); Indices.Add(a + 2); Indices.Add(a + 1);
                Indices.Add(a + 1); Indices.Add(a + 2); Indices.Add(a + 3);
            }
        }
    }

    internal readonly Surface Sheet = new Surface(), Foam = new Surface();
    private const float Gravity = 9.81f, MaxFlight = 4.8f;
    private static readonly float[] SheetRows = { 0f, .09f, .22f, .4f, .61f, .8f, .93f, 1f };
    private static readonly float[] SheetAlpha = { .10f, .65f, .93f, .98f, .92f, .77f, .55f, 0f };
    private static readonly float[] FoamRows = { .015f, .09f, .19f, .35f, .56f, .71f };
    private static readonly float[] FoamAlpha = { 0f, .40f, .77f, .59f, .21f, 0f };
    private readonly Func<Vector2, float> clearance;
    private readonly List<Column> columns = new List<Column>();
    private readonly Dictionary<Vector2Int, int> weld = new Dictionary<Vector2Int, int>();
    private readonly List<Edge> edges = new List<Edge>();
    private readonly List<int> run = new List<int>();
    private const int PathSteps = 20;
    private const float TimeStep = MaxFlight / PathSteps;
    private float[] travel = Array.Empty<float>();
    private readonly List<float> rowTimes = new List<float>(48);
    private float level;

    private struct Column
    {
        internal Vector2 Lip, Inward;
        internal float Head, Crest, Flow, Whitewater, Speed, Flight, CornerLimit;
        internal int Neighbours, Incoming, FirstOut, PathStart;
        internal bool Landed;
    }

    private struct Edge
    {
        internal int A, B, NextOut;
        internal bool Visited;
        internal float Length, TravelDifference;
    }

    internal WaterfallGeometry(Func<Vector2, float> clearance)
    {
        this.clearance = clearance ?? throw new ArgumentNullException(nameof(clearance));
    }

    internal void Rebuild(IReadOnlyList<ShatterWaterfall.Segment> rim, float localWaterY)
    {
        Sheet.Clear(); Foam.Clear(); weld.Clear(); columns.Clear(); edges.Clear();
        level = localWaterY;
        for (int i = 0; i < rim.Count; ++i)
        {
            var s = rim[i];
            Vector2 span = s.B - s.A;
            float length = span.magnitude;
            if (length < .01f || s.Inward.sqrMagnitude < .01f) continue;
            Vector2 n = s.Inward.normalized;
            // Orient every edge with the opening on the same side. Marching
            // triangles alternate which corner is inside and can reverse winding.
            bool forward = span.x * n.y - span.y * n.x > 0f;
            int a = AddColumn(forward ? s.A : s.B, n, forward ? s.HeadA : s.HeadB, forward ? s.CrestA : s.CrestB);
            int b = AddColumn(forward ? s.B : s.A, n, forward ? s.HeadB : s.HeadA, forward ? s.CrestB : s.CrestA);
            if (a == b) continue;
            var ca = columns[a]; var cb = columns[b];
            edges.Add(new Edge { A = a, B = b, Length = length, NextOut = ca.FirstOut });
            ca.FirstOut = edges.Count - 1; cb.Incoming++;
            columns[a] = ca; columns[b] = cb;
        }
        // Start at the shore ends, then process closed ocean rims. Arc-length
        // UVs stay continuous even on sections aligned with a texture axis.
        for (int i = 0; i < edges.Count; ++i)
            if (columns[edges[i].A].Incoming == 0) DrawRun(i);
        for (int i = 0; i < edges.Count; ++i) DrawRun(i);
    }

    private int AddColumn(Vector2 lip, Vector2 inward, float head, float crest)
    {
        var key = new Vector2Int(Mathf.RoundToInt(lip.x * 256f), Mathf.RoundToInt(lip.y * 256f));
        if (!weld.TryGetValue(key, out int index))
        {
            index = columns.Count;
            weld.Add(key, index);
            columns.Add(new Column { Lip = lip, FirstOut = -1 });
        }
        var c = columns[index];
        c.Inward += inward;
        c.Head += Mathf.Max(0f, head);
        c.Crest += (crest - c.Crest) / (c.Neighbours + 1);
        c.Neighbours++;
        columns[index] = c;
        return index;
    }

    private static Column Discharge(Column c)
    {
        c.Inward = c.Inward.normalized;
        c.Flight = c.Flow = c.Whitewater = 0f;
        c.Landed = false;
        c.Speed = 3f;
        float head = c.Head / c.Neighbours;
        if (head <= .006f || c.Inward.sqrMagnitude < .5f) return c;
        float supply = Mathf.Sqrt(head / (head + 2.5f));
        Vector2 p = c.Lip;
        // Coherent tongues of faster and slower water split the crest. Use
        // position so outlets do not jump as neighbouring contour segments form.
        float channel = .47f + .25f * Mathf.Sin(.082f * p.x + .111f * p.y)
            + .20f * Mathf.Sin(.143f * p.x - .045f * p.y + 1.6f)
            + .08f * Mathf.Sin(.19f * p.y - .027f * p.x);
        c.Flow = supply * Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(.16f, .75f, channel + .12f * supply));
        c.Whitewater = Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(.27f, .82f, c.Flow));
        c.Speed = 3f + 11f * c.Flow;
        return c;
    }

    private Column Trace(Column c)
    {
        if (c.Flow < .035f) return c;
        // Ignore the boundary vertex itself: its clearance is zero precisely
        // on the cut. Check a quarter-metre inside before extending a stream.
        float speed = c.Speed;
        float lo = .25f / speed;
        if (Clearance(c, lo) <= Drop(lo)) return c;
        float step = Mathf.Min(.19f, 1.6f / speed);
        while (lo < MaxFlight)
        {
            float hi = Mathf.Min(lo + step, MaxFlight);
            if (Clearance(c, hi) <= Drop(hi))
            {
                for (int i = 0; i < 6; ++i)
                {
                    float mid = (lo + hi) * .5f;
                    if (Clearance(c, mid) > Drop(mid)) lo = mid;
                    else hi = mid;
                }
                c.Flight = lo;
                // Spray only at a receiving ledge, not at a lateral clipping
                // boundary or arbitrarily at the bottom of a very deep hole.
                float floor = Clearance(c, lo);
                c.Landed = floor > 0f && floor - Drop(lo) < .75f;
                return c;
            }
            lo = hi;
        }
        c.Flight = MaxFlight;
        return c;
    }

    private float Clearance(Column c, float seconds)
    {
        float depth = clearance(c.Lip + Offset(c, seconds));
        return depth > 0f ? depth + c.Crest - level : 0f;
    }

    private static float Drop(float seconds) => .5f * Gravity * seconds * seconds;

    private void DrawRun(int first)
    {
        if (edges[first].Visited) return;
        run.Clear();
        int i = first;
        float total = 0f;
        while (i >= 0 && !edges[i].Visited)
        {
            Edge e = edges[i]; e.Visited = true; edges[i] = e;
            total += e.Length; run.Add(i);
            i = columns[e.B].FirstOut;
            while (i >= 0 && edges[i].Visited) i = edges[i].NextOut;
        }
        bool loop = edges[run[0]].A == edges[run[run.Count - 1]].B;
        int count = loop ? run.Count : run.Count + 1;
        for (int j = 0; j < count; j++)
        {
            int id = RunNode(j);
            Column c = columns[id];
            Vector2 tangent = AlongRun(j, 1, loop) - AlongRun(j, -1, loop);
            Vector2 local = c.Inward.normalized;
            Vector2 smoothed = new Vector2(-tangent.y, tangent.x).normalized;
            c.Inward = Vector2.Dot(local, smoothed) > .25f ? smoothed : local;
            c.CornerLimit = float.PositiveInfinity;
            c.PathStart = j * (PathSteps + 1);
            columns[id] = Discharge(c);
        }
        BuildTrajectories(count, loop);
        for (int j = 0; j < count; j++)
        {
            int id = RunNode(j);
            columns[id] = Trace(columns[id]);
        }
        float tilesPerMetre = loop ? Mathf.Max(1, Mathf.RoundToInt(total / 11f)) / total : 1f / 11f;
        Vector2 anchor = columns[edges[first].A].Lip;
        float u = Mathf.Repeat(anchor.x * .071f + anchor.y * .037f, 1f);
        foreach (int edgeIndex in run)
        {
            Edge e = edges[edgeIndex];
            float next = u + e.Length * tilesPerMetre;
            var a = columns[e.A]; var b = columns[e.B];
            if (Mathf.Max(a.Flight, b.Flight) > .18f)
            {
                AddSheet(Sheet, a, b, u, next, false);
                if (Mathf.Max(a.Whitewater, b.Whitewater) > .015f) AddSheet(Foam, a, b, u, next, true);
                if (a.Landed && b.Landed && Mathf.Max(a.Whitewater, b.Whitewater) > .10f
                    && (StreamPosition(a, a.Flight) - StreamPosition(b, b.Flight)).sqrMagnitude
                        <= Mathf.Pow(Mathf.Max(.75f, 2.5f * e.Length), 2f))
                    AddSpray(a, b, u, next);
            }
            u = next;
        }
    }

    // Limit relative travel across the crest. At bends the water turns down
    // before neighbouring jets cross. A broad, straight reach keeps its throw.
    private void BuildTrajectories(int count, bool loop)
    {
        int samples = count * (PathSteps + 1);
        if (travel.Length < samples) travel = new float[samples];
        foreach (int edge in run)
        {
            Edge e = edges[edge];
            Column a = columns[e.A], b = columns[e.B];
            Vector2 along = (b.Lip - a.Lip).normalized;
            Vector2 turn = a.Inward - b.Inward;
            // Sideways convergence can fold a sheet. A difference in forward
            // throw on parallel jets just stretches it, so allow more there.
            float lateral = Mathf.Max(Mathf.Abs(Vector2.Dot(a.Inward, along)), Mathf.Abs(Vector2.Dot(b.Inward, along)));
            e.TravelDifference = e.Length * Mathf.Min(2f, .38f / Mathf.Max(.001f, lateral));
            edges[edge] = e;
            float limit = e.Length / Mathf.Max(.000001f, Mathf.Max(Vector2.Dot(turn, along) / .55f, turn.magnitude / 1.75f));
            a.CornerLimit = Mathf.Min(limit, a.CornerLimit);
            b.CornerLimit = Mathf.Min(limit, b.CornerLimit);
            columns[e.A] = a; columns[e.B] = b;
        }
        for (int j = 0; j < count; j++)
        {
            Column c = columns[RunNode(j)];
            for (int k = 0; k <= PathSteps; k++)
            {
                float distance = k * TimeStep * c.Speed;
                float half = c.CornerLimit * .5f;
                travel[c.PathStart + k] = distance <= half ? distance : c.CornerLimit - half * (half / distance);
            }
        }
        // An early turn on one side must also slow the neighbouring jet.
        // One circuit in each direction includes both paths round a closed rim.
        int passes = loop ? 2 : 1;
        for (int p = 0; p < passes; p++)
            for (int i = 0; i < run.Count; i++) LimitTravel(edges[run[i]], true);
        for (int p = 0; p < passes; p++)
            for (int i = run.Count - 1; i >= 0; i--) LimitTravel(edges[run[i]], false);
    }

    private void LimitTravel(Edge edge, bool forward)
    {
        int from = columns[forward ? edge.A : edge.B].PathStart;
        int to = columns[forward ? edge.B : edge.A].PathStart;
        float difference = edge.TravelDifference;
        for (int k = 1; k <= PathSteps; k++)
            travel[to + k] = Mathf.Min(travel[to + k], travel[from + k] + difference);
    }

    private Vector2 Offset(Column c, float t)
    {
        float sample = t / TimeStep;
        int k = Mathf.Min((int)sample, PathSteps - 1);
        return c.Inward * Mathf.Lerp(travel[c.PathStart + k], travel[c.PathStart + k + 1], sample - k);
    }

    private Vector2 VelocityAt(Column c, float t)
    {
        int k = c.PathStart + Mathf.Min((int)(t / TimeStep), PathSteps - 1);
        return c.Inward * ((travel[k + 1] - travel[k]) / TimeStep);
    }

    private int RunNode(int j) => j < run.Count ? edges[run[j]].A : edges[run[run.Count - 1]].B;

    private Vector2 AlongRun(int j, int direction, bool loop)
    {
        // Smooth in metres along the connected wet rim, never across a dry gap.
        float remaining = 5.5f;
        int node = j;
        for (int i = 0; i < run.Count; i++)
        {
            int k = direction > 0 ? node : node - 1;
            if (k < 0 || k >= run.Count)
            {
                if (!loop) return columns[RunNode(node)].Lip;
                k = k < 0 ? run.Count - 1 : 0;
            }
            Edge e = edges[run[k]];
            Vector2 a = columns[direction > 0 ? e.A : e.B].Lip;
            Vector2 b = columns[direction > 0 ? e.B : e.A].Lip;
            if (remaining <= e.Length) return Vector2.LerpUnclamped(a, b, remaining / e.Length);
            remaining -= e.Length;
            node = direction > 0 ? k + 1 : k;
        }
        return columns[RunNode(j)].Lip;
    }

    private Vector3 StreamPosition(Column c, float t)
    {
        Vector2 p = c.Lip + Offset(c, t);
        return new Vector3(p.x, c.Crest + .055f - Drop(t), p.y);
    }

    private void AddSheet(Surface mesh, Column a, Column b, float u0, float u1, bool foam)
    {
        float[] rows = foam ? FoamRows : SheetRows;
        float[] alpha = foam ? FoamAlpha : SheetAlpha;
        float end = rows[rows.Length - 1];
        float stopA = a.Flight * end, stopB = b.Flight * end;
        // Connect streams at equal travel time. Beyond the first landing, clip
        // each row against the sloping contact line down to a single tip.
        rowTimes.Clear();
        float last = Mathf.Max(stopA, stopB);
        rowTimes.Add(0f);
        rowTimes.Add(stopA);
        rowTimes.Add(stopB);
        // Short falls still need their early aeration and fade. Deep falls
        // share the same absolute rows along the whole reach.
        if (last < 1f)
        {
            for (int i = 1; i < rows.Length - 1; i++)
                rowTimes.Add(last * rows[i] / end);
        }
        else
        {
            rowTimes.Add(.06f);
            rowTimes.Add(.14f);
        }
        for (int k = 1; k * TimeStep < last; k++) rowTimes.Add(k * TimeStep);
        rowTimes.Sort();
        int prevLeft = -1, prevRight = -1;
        float previous = -1f;
        for (int i = 0; i < rowTimes.Count; i++)
        {
            float t = rowTimes[i];
            if (t == previous || (t - previous <= .00001f && t < last)) continue;
            previous = t;
            float left = 0f, right = 1f;
            if (t > Mathf.Min(stopA, stopB))
            {
                float contact = Mathf.Clamp01((t - stopA) / (stopB - stopA));
                if (stopA < stopB) left = contact;
                else right = contact;
            }
            int l = mesh.Vertices.Count;
            AddStreamVertex(mesh, a, b, u0, u1, left, t, rows, alpha, foam);
            int r = l;
            if (right > left)
            {
                r = mesh.Vertices.Count;
                AddStreamVertex(mesh, a, b, u0, u1, right, t, rows, alpha, foam);
            }
            if (prevLeft >= 0)
            {
                mesh.Indices.Add(prevLeft); mesh.Indices.Add(l); mesh.Indices.Add(prevRight);
                if (l != r)
                {
                    mesh.Indices.Add(prevRight); mesh.Indices.Add(l); mesh.Indices.Add(r);
                }
            }
            prevLeft = l; prevRight = r;
        }
    }

    private void AddStreamVertex(Surface mesh, Column a, Column b, float u0, float u1,
        float side, float t, float[] rows, float[] alpha, bool foam)
    {
        float flight = Mathf.Lerp(a.Flight, b.Flight, side);
        float fraction = flight > 0f ? t / flight : 1f;
        float opacity = 0f;
        for (int i = 1; i < rows.Length; i++)
        {
            if (fraction > rows[i]) continue;
            if (fraction >= rows[0])
                opacity = Mathf.Lerp(alpha[i - 1], alpha[i], Mathf.InverseLerp(rows[i - 1], rows[i], fraction));
            break;
        }
        Vector2 vA = VelocityAt(a, t), vB = VelocityAt(b, t);
        Vector2 velocity = Vector2.Lerp(vA, vB, side);
        Vector2 inward = Vector2.Lerp(a.Inward, b.Inward, side).normalized;
        Vector2 tangent = new Vector2(inward.y, -inward.x);
        Vector3 pA = StreamPosition(a, t), pB = StreamPosition(b, t);
        Vector3 down = new Vector3(velocity.x, -Gravity * t, velocity.y);
        Vector3 normal = Vector3.Cross(down, pB - pA).normalized;
        if (normal.sqrMagnitude < .01f) normal = Vector3.up;
        Vector3 vertex = Vector3.Lerp(pA, pB, side);
        // Foam draws over the sheet in a separate transparent pass. A uniform
        // clearance keeps it connected even where crest samples are millimetres apart.
        if (foam) vertex.y += .04f;
        float strengthA = a.Flight <= .12f ? 0f : foam ? a.Whitewater : a.Flow;
        float strengthB = b.Flight <= .12f ? 0f : foam ? b.Whitewater : b.Flow;
        mesh.Vertex(vertex, normal, tangent, Mathf.Lerp(u0, u1, side), t * .72f,
            Mathf.Lerp(strengthA, strengthB, side) * opacity);
    }

    private void AddSpray(Column a, Column b, float u0, float u1)
    {
        int start = Foam.Vertices.Count;
        for (int row = 0; row < 4; ++row)
        {
            SprayVertex(a, u0, row);
            SprayVertex(b, u1, row);
        }
        Foam.Connect(start, 4);
    }

    private void SprayVertex(Column c, float u, int row)
    {
        float f = row / 3f;
        float size = Mathf.Min(3.6f, .13f * Drop(c.Flight)) * c.Whitewater;
        // The plume rises and folds back towards the incoming water. Its base
        // is anchored above the measured impact with the receiving terrain.
        Vector2 p = c.Lip + Offset(c, c.Flight) - c.Inward * (size * f * .85f);
        float y = c.Crest - Drop(c.Flight) + .24f + size * Mathf.Sin(f * 2.25f);
        float opacity = row == 1 ? .72f : row == 2 ? .34f : 0f;
        Foam.Vertex(new Vector3(p.x, y, p.y), Vector3.up, new Vector2(c.Inward.y, -c.Inward.x),
            u, c.Flight * .72f + f * .7f, c.Landed ? opacity * c.Whitewater : 0f);
    }
}
