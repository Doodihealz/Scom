using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using Object = UnityEngine.Object;

namespace ScomShatter;

internal sealed class ShatterWaterfall : IDisposable
{
    internal readonly struct Segment
    {
        internal readonly Vector2 A, B, Inward;
        // Head is the available upstream water depth in metres.
        internal readonly float HeadA, HeadB;
        // Crest heights are local Y coordinates, including any lowered waterline.
        internal readonly float CrestA, CrestB;
        internal Segment(Vector2 a, Vector2 b, Vector2 inward, float headA, float headB, float crestA, float crestB)
        { A = a; B = b; Inward = inward; HeadA = headA; HeadB = headB; CrestA = crestA; CrestB = crestB; }
    }

    private readonly WaterfallGeometry geometry;
    private readonly Batch sheet = new Batch(), foam = new Batch();
    private WaterfallMaterial materials;
    private GameObject root;
    private Bounds localBounds;
    private float liquid, age, lastAge = float.NegativeInfinity, lastLiquid = -1f;
    private bool visible, hasBounds, disposed;

    internal Bounds WorldBounds => root != null && hasBounds
        ? TransformBounds(localBounds, root.transform.localToWorldMatrix) : default;

    private sealed class Batch
    {
        private Mesh mesh;
        private Material material;
        private int pass;
        internal bool HasTriangles { get; private set; }
        internal Bounds LocalBounds { get; private set; }

        internal void Create(string name, Material material, int pass)
        {
            this.material = material;
            this.pass = pass;
            mesh = new Mesh { name = name, indexFormat = IndexFormat.UInt32, hideFlags = HideFlags.HideAndDontSave };
            mesh.MarkDynamic();
        }

        internal void Upload(WaterfallGeometry.Surface data)
        {
            mesh.Clear(false);
            HasTriangles = data.Indices.Count != 0;
            if (!HasTriangles) { LocalBounds = default; return; }
            mesh.SetVertices(data.Vertices);
            mesh.SetNormals(data.Normals);
            mesh.SetTangents(data.Tangents);
            mesh.SetUVs(0, data.UV);
            mesh.SetColors(data.Colors);
            mesh.SetTriangles(data.Indices, 0, true);
            LocalBounds = mesh.bounds;
        }

        internal bool InView(Plane[] planes, Matrix4x4 matrix) => HasTriangles && mesh != null &&
            GeometryUtility.TestPlanesAABB(planes, TransformBounds(LocalBounds, matrix));

        internal void Draw(CommandBuffer command, Matrix4x4 matrix)
        {
            command.DrawMesh(mesh, matrix, material, 0, pass);
        }

        internal void Dispose()
        {
            if (mesh != null) Object.Destroy(mesh);
            mesh = null; material = null; HasTriangles = false;
        }
    }

    internal ShatterWaterfall(Transform site, Func<Vector2, float> clearance)
    {
        if (site == null) throw new ArgumentNullException(nameof(site));
        geometry = new WaterfallGeometry(clearance);
        try
        {
            materials = new WaterfallMaterial();
            root = new GameObject("Chasm waterfalls") { layer = site.gameObject.layer, hideFlags = HideFlags.HideAndDontSave };
            root.transform.SetParent(site, false);
            // These meshes have no live renderers. Their sole submission is
            // after native water, against the bridge's opaque-and-sea depth.
            sheet.Create("Falling water", materials.Sheet, materials.SheetPass);
            foam.Create("Waterfall whitewater and spray", materials.Crest, materials.CrestPass);
        }
        catch { Dispose(); throw; }
    }

    internal void SetGeometry(IReadOnlyList<Segment> wetRim, float localWaterY, float liquidFraction)
    {
        if (disposed) return;
        liquid = Mathf.Clamp01(liquidFraction);
        // The curtain is built only on a settled crest. Opacity/texture travel
        // can subsequently change without rebuilding the ballistic columns.
        geometry.Rebuild(wetRim, localWaterY);
        sheet.Upload(geometry.Sheet);
        foam.Upload(geometry.Foam);
        hasBounds = sheet.HasTriangles || foam.HasTriangles;
        localBounds = sheet.HasTriangles ? sheet.LocalBounds : foam.LocalBounds;
        if (sheet.HasTriangles && foam.HasTriangles) localBounds.Encapsulate(foam.LocalBounds);
    }

    internal void SetAge(float age, bool active, float liquidFraction)
    {
        if (disposed) return;
        liquid = float.IsNaN(liquidFraction) || float.IsInfinity(liquidFraction) ? 0f : Mathf.Clamp01(liquidFraction);
        visible = active && liquid > .005f && age >= 0f && !float.IsInfinity(age);
        this.age = age;
    }

    internal bool InView(Plane[] planes) => !disposed && visible && hasBounds && root != null &&
        root.activeInHierarchy && GeometryUtility.TestPlanesAABB(planes, WorldBounds);

    // The caller owns the per-camera target/depth binding and draw order. With
    // an unavailable bridge there is deliberately no automatic HDRP fallback:
    // a late transparent draw would overpaint nearer sea on submerged cameras.
    internal void DrawVisible(CommandBuffer command, Plane[] planes)
    {
        if (!InView(planes)) return;
        Matrix4x4 matrix = root.transform.localToWorldMatrix;
        bool drawSheet = sheet.InView(planes, matrix), drawFoam = foam.InView(planes, matrix);
        if (!drawSheet && !drawFoam) return;
        RefreshMaterial();
        if (drawSheet) sheet.Draw(command, matrix);
        if (drawFoam) foam.Draw(command, matrix);
    }

    private void RefreshMaterial()
    {
        // The clock already supplies interpolated presentation time and stops
        // on pause. Advance the falling texture on every distinct visible frame.
        if (liquid != lastLiquid || age != lastAge)
        {
            materials.SetAge(age, liquid);
            lastAge = age; lastLiquid = liquid;
        }
    }

    private static Bounds TransformBounds(Bounds bounds, Matrix4x4 matrix)
    {
        Vector3 e = bounds.extents;
        Vector3 size = new Vector3(
            Mathf.Abs(matrix.m00) * e.x + Mathf.Abs(matrix.m01) * e.y + Mathf.Abs(matrix.m02) * e.z,
            Mathf.Abs(matrix.m10) * e.x + Mathf.Abs(matrix.m11) * e.y + Mathf.Abs(matrix.m12) * e.z,
            Mathf.Abs(matrix.m20) * e.x + Mathf.Abs(matrix.m21) * e.y + Mathf.Abs(matrix.m22) * e.z) * 2f;
        return new Bounds(matrix.MultiplyPoint3x4(bounds.center), size);
    }

    public void Dispose()
    {
        if (disposed) return;
        disposed = true;
        if (root != null) root.SetActive(false);
        sheet.Dispose(); foam.Dispose();
        materials?.Dispose();
        if (root != null) Object.Destroy(root);
        root = null; materials = null; visible = hasBounds = false;
    }
}
