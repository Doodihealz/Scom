using System;
using System.Collections.Generic;
using System.Reflection;
using HarmonyLib;
using EM.Controls.Cameras;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering.RendererUtils;

namespace ScomShatter;

// The playtest sea is WaterFFT rendered by WaterPass, not HDRP WaterSurface.
// Scope a private stencil target to that pass; never change the shared ocean material,
// FFT property block, terrain height, or gameplay water classification.
internal sealed class ShatterWaterSurface : IDisposable
{
    private const int ExclusionBit = 1; // This lives in our target, never the camera stencil.
    private const string PatchId = "local.scom.yolona-shatter.water-apertures";
    private static readonly List<ShatterWaterSurface> sites = new List<ShatterWaterSurface>();
    private static readonly List<(float Distance, ShatterWaterfall Fall)> visibleFalls = new List<(float, ShatterWaterfall)>();
    private static readonly ShaderTagId[] ForwardTags = {
        new ShaderTagId("Forward"), new ShaderTagId("ForwardOnly"),
        new ShaderTagId("SRPDefaultUnlit"), new ShaderTagId("FirstPass"), new ShaderTagId("")
    };
    private static readonly ShaderTagId[] InletGuardTags = { new ShaderTagId("SCOMWaterInletGuard") };
    private static readonly ShaderTagId[] InletLoweredTags = { new ShaderTagId("SCOMWaterInletLowered") };
    private static readonly int WaterLevel = Shader.PropertyToID("_WaterLevel");
    private static readonly int HoleBuffer = Shader.PropertyToID("_HoleBuffer");
    private static readonly int SceneColorRect = Shader.PropertyToID("_CustomSceneColorRect");
    private static readonly RenderStateBlock ExcludedWater = new RenderStateBlock(RenderStateMask.Depth | RenderStateMask.Stencil) {
        depthState = new DepthState(true, CompareFunction.LessEqual),
        stencilState = new StencilState(true, ExclusionBit, 0, CompareFunction.Equal,
            StencilOp.Keep, StencilOp.Keep, StencilOp.Keep),
        stencilReference = 0
    };
    private static readonly RenderStateBlock NativeWaterDepth = new RenderStateBlock(RenderStateMask.Depth) {
        depthState = new DepthState(false, CompareFunction.LessEqual)
    };
    private static readonly RenderStateBlock IncludedInlet = new RenderStateBlock(RenderStateMask.Depth | RenderStateMask.Stencil) {
        depthState = new DepthState(true, CompareFunction.LessEqual),
        stencilState = new StencilState(true, ExclusionBit, 0, CompareFunction.Equal,
            StencilOp.Keep, StencilOp.Keep, StencilOp.Keep),
        stencilReference = ExclusionBit
    };
    private static readonly RenderStateBlock LoweredInlet = new RenderStateBlock(RenderStateMask.Depth | RenderStateMask.Stencil) {
        depthState = new DepthState(true, CompareFunction.LessEqual),
        stencilState = new StencilState(false)
    };

    private static Material maskMaterial;
    private static RTHandle cameraStencil;
    private static RTHandle oceanHoles;
    private static RenderTexture terrainHoles;
    private static FieldInfo nativeHoleTarget;
    private static int holeSession;
    private static bool holeWarning;
    private static GraphicsFormat stencilFormat;
    private static bool mainLayoutSupported = true;
    private static readonly Plane[] viewPlanes = new Plane[6];
    private static int maskPass;
    private static Harmony patches;
    private static bool installAttempted;
    private static bool renderFailed;

    internal bool Available => patches != null && !renderFailed && mainLayoutSupported;

    private readonly Transform parent;
    private readonly Rect worldFootprint;
    private Mesh aperture;
    private ShatterInlet inlet;
    private ShatterWaterfall waterfall;
    private readonly int session;
    private float localWaterY;
    private bool visible, disposed;

    // The caller owns the dynamic triangle mesh. Its X/Z are world-unit offsets
    // from parent.position, its Y is zero; site yaw/scale are already baked in.
    internal ShatterWaterSurface(Transform parent, Mesh aperture, Rect worldFootprint)
    {
        if (parent == null) throw new ArgumentNullException(nameof(parent));
        if (aperture == null) throw new ArgumentNullException(nameof(aperture));
        this.parent = parent;
        this.aperture = aperture;
        this.worldFootprint = worldFootprint;
        session = Surface.SessionId;
        if (sites.Count == 0 && !installAttempted)
        {
            installAttempted = true;
            try { Install(); }
            catch (Exception exception)
            {
                Debug.LogWarning("[SCOM Yolona shatter] Sea exclusion unavailable: " + exception.Message);
            }
        }
        sites.Add(this);
    }

    internal void SetVisible(bool value, float waterY)
    {
        if (disposed) return;
        visible = value && Surface.IsReady && Surface.SessionId == session &&
            !float.IsNaN(waterY) && !float.IsInfinity(waterY);
        localWaterY = waterY;
    }

    internal void SetAperture(Mesh mesh) => aperture = mesh;
    internal void SetInlet(ShatterInlet water) => inlet = water;
    internal void SetWaterfall(ShatterWaterfall falls) => waterfall = falls;

    private bool IsVisible(int currentSession) => !disposed && visible && session == currentSession &&
        parent != null && parent.gameObject.activeInHierarchy && aperture != null;

    private static void Install()
    {
        try
        {
            Shader unlit = Shader.Find("HDRP/Unlit");
            if (unlit == null || !unlit.isSupported)
                throw new NotSupportedException("Native water aperture stencil shaders are unavailable.");
            maskMaterial = new Material(unlit) { name = "Shatter sea exclusion", hideFlags = HideFlags.HideAndDontSave };
            maskPass = maskMaterial.FindPass("ForwardOnly");
            if (maskPass < 0) throw new NotSupportedException("Native unlit stencil pass is unavailable.");
            // Native ForwardOnly uses Replace/Always stencil. Zero/One blending
            // preserves camera color; no depth write means the interior stays visible.
            maskMaterial.SetInt("_StencilRef", ExclusionBit);
            maskMaterial.SetInt("_StencilWriteMask", ExclusionBit);
            maskMaterial.SetInt("_ZWrite", 0);
            maskMaterial.SetInt("_ZTestDepthEqualForOpaque", (int)CompareFunction.Always);
            maskMaterial.SetInt("_CullMode", (int)CullMode.Off);
            maskMaterial.SetInt("_SrcBlend", (int)BlendMode.Zero);
            maskMaterial.SetInt("_DstBlend", (int)BlendMode.One);
            maskMaterial.SetInt("_AlphaSrcBlend", (int)BlendMode.Zero);
            maskMaterial.SetInt("_AlphaDstBlend", (int)BlendMode.One);
            stencilFormat = SystemInfo.IsFormatSupported(GraphicsFormat.D24_UNorm_S8_UInt, GraphicsFormatUsage.Render)
                ? GraphicsFormat.D24_UNorm_S8_UInt : GraphicsFormat.D32_SFloat_S8_UInt;
            if (!SystemInfo.IsFormatSupported(stencilFormat, GraphicsFormatUsage.Render))
                throw new NotSupportedException("A private stencil target is unavailable for sea exclusion.");
            Type waterPass = AccessTools.TypeByName("WaterPass");
            var execute = waterPass == null ? null : AccessTools.DeclaredMethod(waterPass, "Execute", new[] { typeof(CustomPassContext) });
            if (execute == null || AccessTools.Field(waterPass, "customSceneColor") == null ||
                AccessTools.Field(waterPass, "layerMask") == null || AccessTools.Field(waterPass, "shoreLayerMask") == null)
                throw new NotSupportedException("Native WaterPass no longer matches the installed playtest contract.");
            Type rangesPass = AccessTools.TypeByName("RangesPass");
            var drawHoles = rangesPass == null ? null : AccessTools.DeclaredMethod(rangesPass, "DrawHoles");
            var targetType = rangesPass?.GetNestedType("RenderTextureTarget", BindingFlags.NonPublic);
            nativeHoleTarget = targetType == null ? null : AccessTools.Field(targetType, "rtHandle");
            if (drawHoles == null || nativeHoleTarget?.FieldType != typeof(RTHandle) ||
                AccessTools.Field(rangesPass, "_forwardShaderTags")?.FieldType != typeof(ShaderTagId[]))
                throw new NotSupportedException("Native terrain-hole rendering is unavailable.");
            patches = new Harmony(PatchId);
            patches.Patch(drawHoles, prefix: new HarmonyMethod(typeof(ShatterWaterSurface), nameof(CaptureOceanHoles)));
            patches.Patch(execute, prefix: new HarmonyMethod(typeof(ShatterWaterSurface), nameof(RenderWater)));
        }
        catch
        {
            Release();
            throw;
        }
    }

    // RangesPass is already inside its native top-down camera override here.
    // Reproduce its unit/map-hole draw with the same projection, culling, pass
    // tags, queue and depth encoding. The original method immediately draws
    // the complete terrain mask into its own target.
    private static void CaptureOceanHoles(CustomPassContext ctx, RangesRenderer.RangeRingConfig? config,
        object targetDepth, LayerMask layermask, Color clearColor, bool draw, ShaderTagId[] ____forwardShaderTags)
    {
        if (renderFailed || !Surface.IsReady) return;
        int currentSession = Surface.SessionId;
        bool active = false;
        foreach (var site in sites)
            if (site.IsVisible(currentSession)) { active = true; break; }
        if (!active) return;
        try
        {
            var original = (nativeHoleTarget.GetValue(targetDepth) as RTHandle)?.rt;
            if (original == null || Shader.GetGlobalTexture(HoleBuffer) != original) return;
            terrainHoles = null;
            if (!original.IsCreated()) return;
            if (oceanHoles == null || !MatchingLayout(oceanHoles.rt, original) ||
                oceanHoles.rt.depthStencilFormat != original.depthStencilFormat)
            {
                var descriptor = original.descriptor;
                var next = RTHandles.Alloc(in descriptor, original.filterMode, original.wrapMode,
                    anisoLevel: original.anisoLevel, name: "Shatter ocean unit holes");
                oceanHoles?.Release();
                oceanHoles = next;
            }
            RendererList list = default;
            if (draw && config.HasValue)
            {
                var desc = new RendererListDesc(____forwardShaderTags, ctx.cullingResults, ctx.hdCamera.camera) {
                    layerMask = layermask, renderingLayerMask = ~SurfaceOpening.FractureRenderingLayer,
                    rendererConfiguration = PerObjectData.None,
                    renderQueueRange = config.Value.GetRenderQueueRange(RangesRenderer.RangeRingSelection.Normal)
                };
                list = ctx.renderContext.CreateRendererList(desc);
            }
            CoreUtils.SetRenderTarget(ctx.cmd, oceanHoles, ClearFlag.Depth, clearColor);
            if (draw && config.HasValue) CoreUtils.DrawRendererList(ctx.cmd, list);
            terrainHoles = original;
            holeSession = currentSession;
        }
        catch (Exception error)
        {
            terrainHoles = null;
            if (!holeWarning) Debug.LogWarning("[SCOM Yolona shatter] Ocean hole mask unavailable: " + error.Message);
            holeWarning = true;
        }
    }

    private static bool RenderWater(CustomPassContext ctx, RTHandle ___customSceneColor,
        LayerMask ___layerMask, LayerMask ___shoreLayerMask)
    {
        if (renderFailed) return true;
        try
        {
            return RenderWaterCore(ctx, ___customSceneColor, ___layerMask, ___shoreLayerMask);
        }
        catch (Exception exception)
        {
            // A disposed target or changed later-map layout must not unwind the
            // native rendering loop. Stop submitting our draws for this session.
            renderFailed = true;
            Debug.LogWarning("[SCOM Yolona shatter] Sea exclusion stopped: " + exception.Message);
            try { CoreUtils.SetRenderTarget(ctx.cmd, ctx.cameraColorBuffer); }
            catch (Exception) { /* Native Execute will bind its own targets. */ }
            return true;
        }
    }

    private static bool RenderWaterCore(CustomPassContext ctx, RTHandle sceneColor,
        LayerMask waterLayer, LayerMask shoreLayer)
    {
        if (!Surface.IsReady || sceneColor == null ||
            Shader.GetGlobalVector(WaterLevel).w <= 0f) return true;
        int currentSession = Surface.SessionId;
        Camera view = ctx.hdCamera.camera;
        GeometryUtility.CalculateFrustumPlanes(view,viewPlanes);
        bool any = false;
        for (int i = 0; i < sites.Count; i++)
            if (sites[i].InView(currentSession)) { any = true; break; }
        if (!any) return true;

        // The game's color-copy path uses resolved targets. Auxiliary cameras
        // may use a different target layout from the main view.
        RenderTexture shore = sceneColor.rt;
        RenderTexture camera = ctx.cameraColorBuffer == null ? null : ctx.cameraColorBuffer.rt;
        RenderTexture depth = ctx.cameraDepthBuffer == null ? null : ctx.cameraDepthBuffer.rt;
        bool supported = Supported(shore) && Supported(camera) && Supported(depth) &&
            camera.width == depth.width && camera.height == depth.height && camera.dimension == depth.dimension;
        if (view == MainCamera.Cam) mainLayoutSupported = supported;
        if (!supported) return true;
        EnsureAttachment(ref cameraStencil,camera);

        // Resolve both lists before recording commands, so culling/layout errors
        // defer without leaving a partly rendered aperture in the camera buffer.
        var shoreList = CreateWaterList(ctx, shoreLayer, ForwardTags, NativeWaterDepth);
        var waterList = CreateWaterList(ctx, waterLayer, ForwardTags, ExcludedWater);
        var guards = CreateWaterList(ctx, waterLayer, InletGuardTags, IncludedInlet);
        var lowered = CreateWaterList(ctx, waterLayer, InletLoweredTags, LoweredInlet);

        // Native WaterPass binds color-only targets. The private attachment adds
        // exclusion and water-surface occlusion using a copy of opaque depth;
        // camera depth/stencil stays unchanged. Keeping the color copy and
        // viewport rect preserves water/shore refraction.
        bool useOceanHoles = holeSession == currentSession && oceanHoles != null && terrainHoles != null &&
            Shader.GetGlobalTexture(HoleBuffer) == terrainHoles;
        try
        {
            if (useOceanHoles) ctx.cmd.SetGlobalTexture(HoleBuffer, oceanHoles);
            // The first target stores the game's shore-wave input for the
            // water shader. Both the map sea and the lowered inlet sample it.
            CoreUtils.SetRenderTarget(ctx.cmd, sceneColor, ClearFlag.Color);
            CoreUtils.DrawRendererList(ctx.cmd, shoreList);
            // Preserve opaque scene occlusion in our attachment. The original
            // camera depth/stencil remains untouched by every water draw.
            CoreUtils.SetRenderTarget(ctx.cmd, cameraStencil, ClearFlag.DepthStencil);
            var fullScreen = new Vector4(1f,1f,0f,0f);
            var depthRegion = fullScreen;
            if (ctx.cameraColorBuffer.useScaling)
            {
                // Our attachment has fixed backing dimensions. HDRP draws the
                // water into the camera's active viewport, which can be smaller.
                var viewport = ctx.cameraColorBuffer.GetScaledSize(ctx.cameraColorBuffer.rtHandleProperties.currentViewportSize);
                depthRegion = new Vector4((float)viewport.x/camera.width,(float)viewport.y/camera.height,0f,0f);
            }
            CustomPassUtils.Copy(in ctx, ctx.cameraDepthBuffer, cameraStencil, fullScreen, depthRegion);
            CoreUtils.SetRenderTarget(ctx.cmd, ctx.cameraColorBuffer, cameraStencil);
            DrawMasks(ctx.cmd,currentSession);
            CoreUtils.DrawRendererList(ctx.cmd, waterList);
            // The untouched FFT guard fills only the original sea cut. Lowered
            // water owns its actual geometry instead of the flat stencil's
            // screen projection. Its depth test also respects foreground sea.
            CoreUtils.DrawRendererList(ctx.cmd, guards);
            CoreUtils.DrawRendererList(ctx.cmd, lowered);
        }
        finally
        {
            try
            {
                if (useOceanHoles) ctx.cmd.SetGlobalTexture(HoleBuffer, terrainHoles);
            }
            finally
            {
                // Later native passes must not inherit our depth/stencil target.
                CoreUtils.SetRenderTarget(ctx.cmd, ctx.cameraColorBuffer);
            }
        }
        CustomPassUtils.Copy(in ctx, ctx.cameraColorBuffer, sceneColor);
        var referenceSize = new Vector2Int(ctx.hdCamera.camera.pixelWidth, ctx.hdCamera.camera.pixelHeight);
        Vector2Int scaledSize = sceneColor.GetScaledSize(referenceSize);
        Shader.SetGlobalVector(SceneColorRect, new Vector4(scaledSize.x, scaledSize.y,
            sceneColor.rt.width, sceneColor.rt.height));
        // Capture native refraction input before the transparent falls. Their
        // usual camera depth has no ocean, so use the populated private depth.
        DrawWaterfalls(in ctx,view,currentSession);
        return false;
    }

    private bool InView(int currentSession)
    {
        if(!IsVisible(currentSession)) return false;
        // A submerged site with a pending FFT binding can have no dry pixels
        // to mask. It still needs the native ocean exempt from the terrain cut.
        var center = worldFootprint.center;
        Bounds bounds = new Bounds(new Vector3(center.x,parent.position.y+localWaterY,center.y),
            new Vector3(worldFootprint.width,0f,worldFootprint.height));
        bounds.Expand(2f);
        return GeometryUtility.TestPlanesAABB(viewPlanes,bounds) || inlet?.InView(viewPlanes) == true ||
            waterfall?.InView(viewPlanes) == true;
    }

    private static void DrawMasks(CommandBuffer cmd,int session)
    {
        foreach(var site in sites)
        {
            if(!site.InView(session) || site.aperture.vertexCount == 0) continue;
            Vector3 position=site.parent.position+Vector3.up*site.localWaterY;
            cmd.DrawMesh(site.aperture,Matrix4x4.Translate(position),maskMaterial,0,maskPass);
        }
    }

    private static void DrawWaterfalls(in CustomPassContext ctx,Camera view,int session)
    {
        visibleFalls.Clear();
        var eye = view.transform.position;
        foreach (var site in sites)
        {
            if (!site.IsVisible(session) || site.waterfall == null ||
                (view.cullingMask & (1 << site.parent.gameObject.layer)) == 0 || !site.waterfall.InView(viewPlanes)) continue;
            float distance = (site.waterfall.WorldBounds.center-eye).sqrMagnitude;
            visibleFalls.Add((distance,site.waterfall));
        }
        if (visibleFalls.Count == 0) return;
        if (visibleFalls.Count > 1) visibleFalls.Sort((a,b) => b.Distance.CompareTo(a.Distance));
        try
        {
            // Blend the translucent curtain and crest against the populated ocean depth.
            CoreUtils.SetRenderTarget(ctx.cmd,ctx.cameraColorBuffer,cameraStencil);
            foreach (var entry in visibleFalls) entry.Fall.DrawVisible(ctx.cmd,viewPlanes);
        }
        finally
        {
            visibleFalls.Clear();
            CoreUtils.SetRenderTarget(ctx.cmd,ctx.cameraColorBuffer);
        }
    }

    private static bool Supported(RenderTexture rt) => rt!=null && rt.antiAliasing==1 && rt.volumeDepth==1 &&
        (rt.dimension==TextureDimension.Tex2D || rt.dimension==TextureDimension.Tex2DArray);

    private static bool MatchingLayout(RenderTexture a,RenderTexture b) => a!=null && a.width==b.width &&
        a.height==b.height && a.dimension==b.dimension && a.useDynamicScale==b.useDynamicScale &&
        a.useDynamicScaleExplicit==b.useDynamicScaleExplicit;

    private static void EnsureAttachment(ref RTHandle attachment,RenderTexture color)
    {
        if(attachment!=null && MatchingLayout(attachment.rt,color)) return;
        var next=RTHandles.Alloc(color.width,color.height,stencilFormat,dimension:color.dimension,
            useDynamicScale:color.useDynamicScale,useDynamicScaleExplicit:color.useDynamicScaleExplicit,
            name:"Shatter water aperture stencil");
        attachment?.Release();
        attachment=next;
    }

    private static RendererList CreateWaterList(CustomPassContext ctx, LayerMask layer,
        ShaderTagId[] tags, RenderStateBlock state)
    {
        var descriptor = new RendererListDesc(tags, ctx.cullingResults, ctx.hdCamera.camera) {
            rendererConfiguration = HDUtils.GetRendererConfiguration(
                ctx.hdCamera.frameSettings.IsEnabled(FrameSettingsField.AdaptiveProbeVolume),
                ctx.hdCamera.frameSettings.IsEnabled(FrameSettingsField.Shadowmask)),
            renderQueueRange = RenderQueueRange.all,
            sortingCriteria = SortingCriteria.BackToFront,
            excludeObjectMotionVectors = false,
            stateBlock = state,
            layerMask = layer
        };
        return ctx.renderContext.CreateRendererList(descriptor);
    }

    public void Dispose()
    {
        if (disposed) return;
        disposed = true;
        visible = false;
        sites.Remove(this);
        if (sites.Count == 0)
        {
            Release();
            installAttempted = false;
            renderFailed = false;
            mainLayoutSupported = true;
        }
    }

    private static void Release()
    {
        visibleFalls.Clear();
        patches?.UnpatchSelf();
        patches = null;
        if (maskMaterial != null) UnityEngine.Object.Destroy(maskMaterial);
        cameraStencil?.Release();
        oceanHoles?.Release();
        maskMaterial = null;
        cameraStencil = oceanHoles = null;
        terrainHoles = null;
        nativeHoleTarget = null;
        holeWarning = false;
    }
}
