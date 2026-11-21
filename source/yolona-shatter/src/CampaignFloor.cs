using System;
using System.Collections.Generic;
using UnityEngine;
using Object = UnityEngine.Object;

namespace ScomShatter
{
    // Project a sampled terrain aperture onto the native distant machinery plane.
    // Its opaque shader makes overlapping projected triangles a harmless union.
    internal sealed class CampaignFloor : IDisposable
    {
        private const int RimSamples = 96, RingCount = 6;
        private const int DiskTriangleCount = RimSamples * (RingCount * 2 - 1);
        private const double MinimumW = .0001;
        private readonly Vector3 impact;
        private readonly FractureLayout layout;
        private readonly Rect mapBounds, floorBounds;
        private readonly Vector2[] disk = new Vector2[1 + RingCount * RimSamples];
        private readonly Vector3[] sampledPolygon = new Vector3[8];
        private readonly List<GroundTriangle> aperture = new List<GroundTriangle>(DiskTriangleCount * 2);
        private List<Vector2> polygon = new List<Vector2>(8), clipping = new List<Vector2>(8);
        private List<ProjectedPoint> projected = new List<ProjectedPoint>(12), projectedClipping = new List<ProjectedPoint>(12);
        private readonly List<Vector3> vertices = new List<Vector3>(DiskTriangleCount * 12);
        private readonly List<Vector2> uv = new List<Vector2>(DiskTriangleCount * 12);
        private readonly List<Vector3> normals = new List<Vector3>(DiskTriangleCount * 12);
        private readonly List<Vector4> tangents = new List<Vector4>(DiskTriangleCount * 12);
        private readonly List<int> triangles = new List<int>(DiskTriangleCount * 12);
        // Source sharedassets2 mesh 4192 ("Quad Forward"). The floor we draw is
        // generated from the projected aperture; its source quad has this fixed basis.
        private const float QuadHalfWidth = .49999991059303284f;
        private const float QuadHalfHeight = .5f;
        private const float QuadTilt = 8.821881891662997e-8f;
        private static readonly Vector4 QuadTangent = new Vector4(-1f, 0f, 0f, -1f);
        private float lastFloorY;
        private Vector3 lastEye, lastDirection;
        private bool dirty = true, lastOrthographic, hasGeometry, disposed;

        private struct GroundTriangle
        {
            internal Vector3 A, B, C;
            internal GroundTriangle(Vector3 a, Vector3 b, Vector3 c) { A = a; B = b; C = c; }
        }

        private struct ProjectedPoint
        {
            internal double X, Z, W, AboveFloor;
            internal ProjectedPoint(double x, double z, double w, double aboveFloor)
            { X = x; Z = z; W = w; AboveFloor = aboveFloor; }
            internal static ProjectedPoint Lerp(ProjectedPoint a, ProjectedPoint b, double t)
            {
                return new ProjectedPoint(a.X + (b.X - a.X) * t, a.Z + (b.Z - a.Z) * t,
                    a.W + (b.W - a.W) * t, a.AboveFloor + (b.AboveFloor - a.AboveFloor) * t);
            }
        }

        internal Mesh Mesh { get; }

        internal CampaignFloor(Vector3 impact, Rect mapLocal, FractureLayout layout)
        {
            this.impact = impact;
            this.layout = layout;
            mapBounds = mapLocal;
            const float halfWidth = QuadHalfWidth * CampaignInterior.FloorScale;
            const float halfHeight = QuadHalfHeight * CampaignInterior.FloorScale;
            floorBounds = Rect.MinMaxRect(Mathf.Max(mapLocal.xMin, -halfWidth),
                Mathf.Max(mapLocal.yMin, CampaignInterior.RootZ - halfHeight),
                Mathf.Min(mapLocal.xMax, halfWidth), Mathf.Min(mapLocal.yMax, CampaignInterior.RootZ + halfHeight));
            Vector2 openingCenter = new Vector2(0f, SurfaceOpening.OffsetZ);
            Vector2 openingSize = new Vector2(SurfaceOpening.Width, SurfaceOpening.Length);
            disk[0] = layout.SourceToNative(openingCenter);
            for (int ring = 1; ring <= RingCount; ring++)
                for (int i = 0; i < RimSamples; i++)
                {
                    float angle = i * (2f * Mathf.PI / RimSamples), radius = (float)ring / RingCount;
                    disk[RingIndex(ring, i)] = layout.SourceToNative(new Vector2(
                        openingCenter.x + Mathf.Cos(angle) * (openingSize.x * .5f + .75f) * radius,
                        openingCenter.y + Mathf.Sin(angle) * (openingSize.y * .5f + .75f) * radius));
                }
            Mesh = new Mesh { name = "Campaign machinery through aperture",
                indexFormat = UnityEngine.Rendering.IndexFormat.UInt32 };
            Mesh.MarkDynamic();
        }

        internal void RefreshRim(CampaignGround ground)
        {
            if (disposed) return;
            if (ground == null) throw new ArgumentNullException(nameof(ground));
            aperture.Clear();
            if (mapBounds.width > 0 && mapBounds.height > 0)
                for (int i = 0; i < RimSamples; i++)
                {
                    int next = (i + 1) % RimSamples;
                    CacheTriangle(disk[0], disk[RingIndex(1, i)], disk[RingIndex(1, next)], ground);
                    for (int ring = 2; ring <= RingCount; ring++)
                    {
                        Vector2 a = disk[RingIndex(ring - 1, i)], b = disk[RingIndex(ring, i)];
                        Vector2 c = disk[RingIndex(ring - 1, next)], d = disk[RingIndex(ring, next)];
                        CacheTriangle(a, b, d, ground);
                        CacheTriangle(a, d, c, ground);
                    }
                }
            dirty = true;
        }

        private static int RingIndex(int ring, int sample) { return 1 + (ring - 1) * RimSamples + sample; }

        private void CacheTriangle(Vector2 a, Vector2 b, Vector2 c, CampaignGround ground)
        {
            polygon.Clear(); polygon.Add(a); polygon.Add(b); polygon.Add(c);
            for (int edge = 0; edge < 4 && polygon.Count != 0; edge++)
            {
                clipping.Clear();
                Vector2 previous = polygon[polygon.Count - 1];
                float previousDistance = EdgeDistance(previous, mapBounds, edge);
                foreach (var current in polygon)
                {
                    float currentDistance = EdgeDistance(current, mapBounds, edge);
                    if ((previousDistance >= 0) != (currentDistance >= 0))
                    {
                        double t = previousDistance / ((double)previousDistance - currentDistance);
                        clipping.Add(new Vector2((float)(previous.x + ((double)current.x - previous.x) * t),
                            (float)(previous.y + ((double)current.y - previous.y) * t)));
                    }
                    if (currentDistance >= 0) clipping.Add(current);
                    previous = current; previousDistance = currentDistance;
                }
                var swap = polygon; polygon = clipping; clipping = swap;
            }
            for (int i = 0; i < polygon.Count; i++)
            {
                Vector2 p = polygon[i];
                float y = ground.Sample(p.x, p.y);
                if (!Finite(y)) return;
                sampledPolygon[i] = new Vector3(p.x, y, p.y);
            }
            for (int i = 1; i + 1 < polygon.Count; i++)
                if (Mathf.Abs(Cross(polygon[i] - polygon[0], polygon[i + 1] - polygon[0])) > 1e-6f)
                    aperture.Add(new GroundTriangle(sampledPolygon[0], sampledPolygon[i], sampledPolygon[i + 1]));
        }

        internal void Update(Camera camera, float localFloorY)
        {
            if (disposed) return;
            if (camera == null) { Hide(); dirty = true; return; }
            Vector3 eye = layout.ToNative(camera.transform.position - impact),
                direction = layout.ToNative(camera.transform.forward);
            bool orthographic = camera.orthographic;
            if (!dirty && eye.Equals(lastEye) && orthographic == lastOrthographic
                && localFloorY.Equals(lastFloorY) && (!orthographic || direction.Equals(lastDirection))) return;
            lastEye = eye; lastDirection = direction; lastFloorY = localFloorY; lastOrthographic = orthographic;
            dirty = false;
            if (aperture.Count == 0 || floorBounds.width <= 0 || floorBounds.height <= 0
                || !Finite(localFloorY) || !Finite(eye.x) || !Finite(eye.y) || !Finite(eye.z)
                || (orthographic && (!Finite(direction.x) || !Finite(direction.y) || !Finite(direction.z) || direction.y >= -.01f)))
            { Hide(); return; }

            vertices.Clear(); uv.Clear(); normals.Clear(); tangents.Clear(); triangles.Clear();
            foreach (var triangle in aperture)
            {
                ProjectedPoint pa = Project(triangle.A, eye, direction, localFloorY, orthographic);
                ProjectedPoint pb = Project(triangle.B, eye, direction, localFloorY, orthographic);
                ProjectedPoint pc = Project(triangle.C, eye, direction, localFloorY, orthographic);
                int oa = Outcode(pa), ob = Outcode(pb), oc = Outcode(pc);
                if ((oa & ob & oc) != 0) continue;
                if ((oa | ob | oc) == 0 && pa.W > MinimumW && pb.W > MinimumW && pc.W > MinimumW)
                {
                    EmitTriangle(Divide(pa), Divide(pb), Divide(pc));
                    continue;
                }
                projected.Clear();
                projected.Add(pa); projected.Add(pb); projected.Add(pc);
                for (int edge = 0; edge < 6 && projected.Count != 0; edge++) ClipProjected(edge);
                if (projected.Count < 3) continue;
                Vector2 a = Divide(projected[0]);
                for (int i = 1; i + 1 < projected.Count; i++)
                {
                    EmitTriangle(a, Divide(projected[i]), Divide(projected[i + 1]));
                }
            }
            if (triangles.Count == 0) { Hide(); return; }
            Mesh.Clear();
            Mesh.SetVertices(vertices); Mesh.SetUVs(0, uv); Mesh.SetNormals(normals); Mesh.SetTangents(tangents);
            Mesh.SetTriangles(triangles, 0, true);
            hasGeometry = true;
        }

        private static ProjectedPoint Project(Vector3 point, Vector3 eye, Vector3 direction, float floorY, bool orthographic)
        {
            double aboveFloor = (double)point.y - floorY;
            if (orthographic)
            {
                double distance = -aboveFloor / direction.y;
                return new ProjectedPoint(point.x + direction.x * distance, point.z + direction.z * distance, 1, aboveFloor);
            }
            double w = (double)eye.y - point.y, height = (double)eye.y - floorY;
            return new ProjectedPoint(eye.x * w + ((double)point.x - eye.x) * height,
                eye.z * w + ((double)point.z - eye.z) * height, w, aboveFloor);
        }

        private void ClipProjected(int edge)
        {
            projectedClipping.Clear();
            ProjectedPoint previous = projected[projected.Count - 1];
            double previousDistance = ProjectedDistance(previous, edge);
            foreach (var current in projected)
            {
                double currentDistance = ProjectedDistance(current, edge);
                if ((previousDistance >= 0) != (currentDistance >= 0))
                {
                    var intersection = ProjectedPoint.Lerp(previous, current,
                        previousDistance / (previousDistance - currentDistance));
                    // Keep a near-horizon intersection exactly on its clip plane.
                    switch (edge)
                    {
                        case 0: intersection.W = MinimumW; break;
                        case 1: intersection.AboveFloor = 0; break;
                        case 2: intersection.X = floorBounds.xMin * intersection.W; break;
                        case 3: intersection.X = floorBounds.xMax * intersection.W; break;
                        case 4: intersection.Z = floorBounds.yMin * intersection.W; break;
                        default: intersection.Z = floorBounds.yMax * intersection.W; break;
                    }
                    projectedClipping.Add(intersection);
                }
                if (currentDistance >= 0) projectedClipping.Add(current);
                previous = current; previousDistance = currentDistance;
            }
            var swap = projected; projected = projectedClipping; projectedClipping = swap;
        }

        private double ProjectedDistance(ProjectedPoint p, int edge)
        {
            switch (edge)
            {
                case 0: return p.W - MinimumW;
                // A floor hit before the sampled aperture is not a ray through it.
                case 1: return p.AboveFloor;
                case 2: return p.X - floorBounds.xMin * p.W;
                case 3: return floorBounds.xMax * p.W - p.X;
                case 4: return p.Z - floorBounds.yMin * p.W;
                default: return floorBounds.yMax * p.W - p.Z;
            }
        }

        private int Outcode(ProjectedPoint point)
        {
            int code = 0;
            for (int edge = 0; edge < 6; edge++)
                if (ProjectedDistance(point, edge) < 0) code |= 1 << edge;
            return code;
        }

        private void EmitTriangle(Vector2 a, Vector2 b, Vector2 c)
        {
            double area = ((double)b.x - a.x) * ((double)c.y - a.y)
                - ((double)b.y - a.y) * ((double)c.x - a.x);
            if (double.IsNaN(area) || double.IsInfinity(area) || Math.Abs(area) <= 1e-6) return;
            int first = vertices.Count;
            AddVertex(a); AddVertex(b); AddVertex(c);
            triangles.Add(first);
            triangles.Add(first + (area < 0 ? 1 : 2));
            triangles.Add(first + (area < 0 ? 2 : 1));
        }

        private static Vector2 Divide(ProjectedPoint p) { return new Vector2((float)(p.X / p.W), (float)(p.Z / p.W)); }

        private void AddVertex(Vector2 point)
        {
            var local = new Vector2(point.x / CampaignInterior.FloorScale,
                (point.y - CampaignInterior.RootZ) / CampaignInterior.FloorScale);
            vertices.Add(new Vector3(local.x, local.y, local.y * QuadTilt));
            uv.Add(new Vector2(.5f - local.x / (2f * QuadHalfWidth), .5f - local.y));
            normals.Add(Vector3.back);
            tangents.Add(QuadTangent);
        }

        private static float EdgeDistance(Vector2 p, Rect bounds, int edge)
        {
            switch (edge)
            {
                case 0: return p.x - bounds.xMin;
                case 1: return bounds.xMax - p.x;
                case 2: return p.y - bounds.yMin;
                default: return bounds.yMax - p.y;
            }
        }

        private static float Cross(Vector2 a, Vector2 b) { return a.x * b.y - a.y * b.x; }
        private static bool Finite(float value) { return !float.IsNaN(value) && !float.IsInfinity(value); }
        private void Hide() { if (hasGeometry) Mesh.Clear(); hasGeometry = false; }

        public void Dispose()
        {
            if (disposed) return;
            disposed = true;
            Object.Destroy(Mesh);
        }
    }
}
