using System;
using System.IO;
using System.Reflection;
using EM.Map;
using UnityEngine;
using UnityEngine.Rendering;
using Object = UnityEngine.Object;

namespace ScomShatter;

// Only the private inlet renderer lists can draw this shader. A real
// renderer lets Unity supply the native ocean's probe and per-object lighting.
// The caller owns UV2 (opacity, native wave strength, logical lowering metres).
internal sealed class ShatterInlet : IDisposable
{
    private static readonly FieldInfo MapInstance = typeof(MapManager).GetField("Instance", BindingFlags.Static | BindingFlags.NonPublic);
    private static readonly FieldInfo WaterRenderer = typeof(WaterFFT).GetField("waterRenderer", BindingFlags.Instance | BindingFlags.NonPublic);
    private static readonly int TessellationFactor = Shader.PropertyToID("_TesselationFactor");
    private static readonly int[] FftTextures = {
        Shader.PropertyToID("_Displacement_c0"), Shader.PropertyToID("_Derivatives_c0"), Shader.PropertyToID("_Turbulence_c0"),
        Shader.PropertyToID("_Displacement_c1"), Shader.PropertyToID("_Derivatives_c1"), Shader.PropertyToID("_Turbulence_c1"),
        Shader.PropertyToID("_Displacement_c2"), Shader.PropertyToID("_Derivatives_c2"), Shader.PropertyToID("_Turbulence_c2")
    };
    private static AssetBundle shaderBundle;
    private static Stream shaderStream;
    private static Shader inletShader;
    private static int shaderUsers;

    private readonly Transform parent;
    private readonly int session;
    private readonly MaterialPropertyBlock properties = new MaterialPropertyBlock();
    private Material material;
    private Mesh mesh;
    private GameObject root;
    private MeshFilter filter;
    private MeshRenderer renderer;
    private Transform probeAnchor;
    private WaterFFT water;
    private MeshRenderer sourceRenderer;
    private int validatedFrame = -1;
    private bool ready;
    private bool visible, ownsShader, warned, disposed;

    internal ShatterInlet(Transform parent)
    {
        if (parent == null) throw new ArgumentNullException(nameof(parent));
        this.parent = parent;
        session = Surface.SessionId;
        try
        {
            Shader shader = AcquireShader();
            ownsShader = true;
            material = new Material(shader) {
                name = "Native fracture seawater inlet",
                hideFlags = HideFlags.HideAndDontSave
            };
            if (material.FindPass("Forward") < 0 || material.FindPass("InletGuard") < 0 || !material.HasProperty(TessellationFactor))
                throw new NotSupportedException("The native inlet shader no longer matches its material contract.");
            root = new GameObject("Native seawater inlet") {
                layer = parent.gameObject.layer, hideFlags = HideFlags.HideAndDontSave
            };
            root.transform.SetParent(parent, false);
            filter = root.AddComponent<MeshFilter>();
            renderer = root.AddComponent<MeshRenderer>();
            renderer.sharedMaterial = material;
            renderer.shadowCastingMode = ShadowCastingMode.Off;
            renderer.motionVectorGenerationMode = MotionVectorGenerationMode.ForceNoMotion;
            renderer.allowOcclusionWhenDynamic = false;
            renderer.enabled = false;
        }
        catch { Dispose(); throw; }
    }

    // Call before recording aperture draws. Missing live FFT inputs leave the
    // caller free to retain the native sea for this camera instead.
    internal bool Ready
    {
        get
        {
            if (disposed || parent == null || !Surface.IsReady || Surface.SessionId != session)
            {
                if (renderer != null) renderer.enabled = false;
                return false;
            }
            if (validatedFrame != Time.frameCount)
            {
                ready = TryRefresh();
                validatedFrame = Time.frameCount;
                if (!ready && renderer != null) renderer.enabled = false;
            }
            return ready;
        }
    }

    internal void SetMesh(Mesh value)
    {
        if (disposed) return;
        bool populated = value != null && value.vertexCount != 0 && value.subMeshCount != 0 && value.GetIndexCount(0) != 0;
        if (populated && (value.GetTopology(0) != MeshTopology.Triangles ||
            !value.HasVertexAttribute(VertexAttribute.Normal) || !value.HasVertexAttribute(VertexAttribute.Tangent) ||
            !value.HasVertexAttribute(VertexAttribute.TexCoord0) || !value.HasVertexAttribute(VertexAttribute.TexCoord2) ||
            value.GetVertexAttributeDimension(VertexAttribute.TexCoord2) < 3))
            throw new ArgumentException("A native inlet needs triangles, normals, tangents, UV0 and UV2.", nameof(value));
        mesh = populated ? value : null;
        filter.sharedMesh = mesh;
        renderer.enabled = visible && mesh != null && Ready;
    }

    internal void SetVisible(bool value)
    {
        if (disposed) return;
        visible = value && Surface.IsReady && Surface.SessionId == session;
        renderer.enabled = visible && mesh != null && Ready;
    }

    internal bool InView(Plane[] planes)
    {
        if (disposed || !visible || mesh == null || parent == null || !parent.gameObject.activeInHierarchy) return false;
        Bounds bounds = mesh.bounds;
        bounds.center += parent.position;
        // ShorelineMesh already includes the native wave displacement apron.
        return GeometryUtility.TestPlanesAABB(planes, bounds);
    }

    private Material ResolveSource()
    {
        if (!Surface.IsReady || Surface.SessionId != session || MapInstance == null || WaterRenderer == null)
            throw new NotSupportedException("The current map's native water owner is unavailable.");
        var manager = MapInstance.GetValue(null) as MapManager;
        if (manager == null || manager.waterTerrainValues == null || manager.water == null ||
            manager.waterTerrainValues.water != manager.water)
            throw new NotSupportedException("The current map's native water owner no longer matches.");
        water = manager.water;
        sourceRenderer = WaterRenderer.GetValue(water) as MeshRenderer;
        Material source = sourceRenderer == null ? null : sourceRenderer.sharedMaterial;
        if (source == null || source.shader == null || !source.shader.isSupported || source.shader.name != "RTS/WaterFFT")
            throw new NotSupportedException("The current map's native sea material is unavailable.");
        return source;
    }

    private bool TryRefresh()
    {
        try
        {
            if (material == null || inletShader == null || !inletShader.isSupported)
                throw new NotSupportedException("The native inlet shader is unavailable.");
            Material source = ResolveSource();
            if (!water.isActiveAndEnabled || !sourceRenderer.enabled || !sourceRenderer.gameObject.activeInHierarchy)
                return false;
            properties.Clear();
            sourceRenderer.GetPropertyBlock(properties);
            foreach (int id in FftTextures)
            {
                Texture texture = properties.GetTexture(id);
                if (texture == null || (texture is RenderTexture target && !target.IsCreated())) return false;
            }
            // Copies live map color, foam, freezing and keywords, while Unity's
            // CopyPropertiesFromMaterial deliberately retains our private shader.
            material.CopyPropertiesFromMaterial(source);
            material.shaderKeywords = source.shaderKeywords;
            if (material.shader != inletShader)
                throw new InvalidOperationException("The native inlet shader binding changed.");
            // The inlet already has the authored dense lattice. Preserve native
            // waves, but avoid multiplying every one of its small triangles.
            material.SetFloat(TessellationFactor, 1f);
            properties.SetFloat(TessellationFactor, 1f);
            SyncRenderer();
            renderer.SetPropertyBlock(properties);
            return true;
        }
        catch (Exception error)
        {
            if (!warned) Debug.LogWarning("[SCOM Yolona shatter] Native inlet temporarily unavailable: " + error.Message);
            warned = true;
            return false;
        }
    }

    private void SyncRenderer()
    {
        root.layer = sourceRenderer.gameObject.layer;
        renderer.receiveShadows = sourceRenderer.receiveShadows;
        renderer.renderingLayerMask = sourceRenderer.renderingLayerMask;
        renderer.lightProbeUsage = sourceRenderer.lightProbeUsage;
        renderer.reflectionProbeUsage = sourceRenderer.reflectionProbeUsage;
        renderer.lightProbeProxyVolumeOverride = sourceRenderer.lightProbeProxyVolumeOverride;
        Transform anchor = sourceRenderer.probeAnchor;
        if (anchor == null)
        {
            if (probeAnchor == null)
            {
                var owner = new GameObject("Native sea probe anchor") { hideFlags = HideFlags.HideAndDontSave };
                probeAnchor = owner.transform;
                probeAnchor.SetParent(root.transform, false);
            }
            // A renderer without an explicit anchor samples at its bounds
            // center. Preserve that source position, not our smaller inlet's.
            probeAnchor.position = sourceRenderer.bounds.center;
            anchor = probeAnchor;
        }
        renderer.probeAnchor = anchor;
    }

    private static Shader AcquireShader()
    {
        if (shaderBundle == null)
        {
            Stream stream = null;
            AssetBundle loaded = null;
            try
            {
                stream = typeof(ShatterInlet).Assembly.GetManifestResourceStream("InletWater.bundle")
                    ?? throw new InvalidDataException("Missing native inlet shader bundle.");
                loaded = AssetBundle.LoadFromStream(stream);
                Shader shader = loaded == null ? null : loaded.LoadAsset<Shader>("assets/campaign/inlet-water.shader");
                if (shader == null || !shader.isSupported || shader.name != "SCOM/WaterFFT Inlet" || !PrivatePasses(shader))
                    throw new NotSupportedException("The native inlet shader is unavailable.");
                shaderBundle = loaded; shaderStream = stream; inletShader = shader;
            }
            catch
            {
                if (loaded != null) loaded.Unload(true);
                stream?.Dispose();
                throw;
            }
        }
        shaderUsers++;
        return inletShader;
    }

    private static bool PrivatePasses(Shader shader)
    {
        if (shader.passCount != 2) return false;
        var lightMode = new ShaderTagId("LightMode");
        var first = shader.FindPassTagValue(0, lightMode);
        var second = shader.FindPassTagValue(1, lightMode);
        var guard = new ShaderTagId("SCOMWaterInletGuard");
        var lowered = new ShaderTagId("SCOMWaterInletLowered");
        return (first == guard && second == lowered) || (first == lowered && second == guard);
    }

    public void Dispose()
    {
        if (disposed) return;
        disposed = true;
        visible = false;
        mesh = null;
        properties.Clear();
        if (renderer != null) renderer.enabled = false;
        if (filter != null) filter.sharedMesh = null;
        if (root != null) Object.Destroy(root);
        if (material != null) Object.Destroy(material);
        root = null; filter = null; renderer = null; probeAnchor = null;
        material = null; water = null; sourceRenderer = null;
        if (ownsShader && --shaderUsers == 0)
        {
            // Unity may destroy the native bundle before the last site during shutdown.
            if (shaderBundle != null) shaderBundle.Unload(true);
            shaderStream?.Dispose();
            shaderBundle = null; shaderStream = null; inletShader = null;
        }
        ownsShader = false;
    }
}
