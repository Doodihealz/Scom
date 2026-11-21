using System;
using System.Collections.Generic;
using System.IO;
using EM.Controls.Cameras;
using EM.Map;
using UnityEngine;
using Object = UnityEngine.Object;

namespace ScomShatter;

// The collapse keeps its authored vertex animation and cutouts. Its surface
// programs read the same map-owned textures as RTS/TerrainLit on the intact bank.
internal static class MapSurfaceMaterial
{
    private const string Resource = "TerrainSurface.bundle";
    private const string MaterialKey = "assets/campaign/map-surface.mat";
    private const int Width = 8, Height = 17, MaxLayers = 9;
    private static readonly Color[] parameters = new Color[Width * Height];
    private sealed class Draw
    {
        internal Material Material;
        internal Renderer Renderer;
        internal MaterialPropertyBlock Inputs;

        internal void BindMap()
        {
            if (Renderer == null || Material == null) return;
            foreach (var pair in textures) Inputs.SetTexture(pair.Key, pair.Value);
            Inputs.SetTexture("_ScomParams", table);
            Inputs.SetTexture("_ScomMacroNormal", nativeNormals != null ? nativeNormals : Material.GetTexture("_Normals"));
            Renderer.SetPropertyBlock(Inputs);
        }
    }

    private static readonly Dictionary<Material, Draw> users = new Dictionary<Material, Draw>();
    private static readonly int[] albedo = LayerIds("_ScomAlbedo"), normal = LayerIds("_ScomNormal"), mask = LayerIds("_ScomMask");
    private static readonly int[] gameAlbedo = LayerIds("_LayerAlbedo"), gameNormal = LayerIds("_LayerNormal"), gameMask = LayerIds("_LayerMask");
    private static readonly int[] tiling = LayerIds("_LayerTilling"), farTiling = LayerIds("_LayerTillingFar");
    private static readonly int[] normalScale = LayerIds("_LayerNormalScale"), flip = LayerIds("_LayerTextureFlip");
    private static readonly int[] remap = LayerIds("_LayerDiffuseRemapScale"), farRemap = LayerIds("_LayerDiffuseFarRemapScale");
    private static readonly int[] maskMin = LayerIds("_LayerMaskMapRemapOffset"), maskMax = LayerIds("_LayerMaskMapRemapScale");
    private static readonly int visibility1 = Shader.PropertyToID("_TerrainVisibilityLayer14");
    private static readonly int visibility2 = Shader.PropertyToID("_TerrainVisibilityLayer58");
    private static readonly int tintVisibility = Shader.PropertyToID("_TerrainVisibilityTints");
    private static readonly int waterLevel = Shader.PropertyToID("_WaterLevel"), freezing = Shader.PropertyToID("_WaterFreezing");

    private static Material terrainMaterial;
    private static AssetBundle bundle;
    private static Stream bundleStream;
    private static Material template;
    private static string rejectedShader;
    private static int rejectedQuality;
    private static Texture2D table, neutralNormal, neutralTint, clear;
    private static Texture nativeNormals;
    private static readonly Dictionary<int, Texture> textures = new Dictionary<int, Texture>();
    private static float nextCheck;
    private static bool tableChanged, texturesChanged, warned, reported;

    private static int[] LayerIds(string name)
    {
        var result = new int[MaxLayers];
        for (int i = 0; i < result.Length; i++) result[i] = Shader.PropertyToID(name + i);
        return result;
    }

    internal static Material TryCreate(Material campaign, CampaignGround ground, Renderer renderer)
    {
        Material result = null;
        bool attached = false;
        try
        {
            var source = MapManager.Terrain.materialTemplate;
            if (source == null || source.shader == null || source.shader.name != "RTS/TerrainLit")
                throw new NotSupportedException("The map uses " + (source != null && source.shader != null ? source.shader.name : "no terrain shader") + ".");
            if (MapManager.mapFile.stratumLayers == null || !source.HasProperty(gameAlbedo[0]) || source.GetTexture(gameAlbedo[0]) == null)
                throw new InvalidDataException("The map has no base stratum texture.");
            if (!SystemInfo.SupportsTextureFormat(TextureFormat.RGBAFloat))
                throw new NotSupportedException("The renderer cannot sample the fracture coordinate table.");
            EnsureTemplate();
            EnsureTextures();
            RefreshMap(source);
            UpdateView();
            result = new Material(template) { name = "Campaign fracture with map strata" };
            foreach (string name in CampaignSurfaceAssets.RequiredTextures)
            {
                result.SetTexture(name, campaign.GetTexture(name));
                result.SetTextureScale(name, campaign.GetTextureScale(name));
                result.SetTextureOffset(name, campaign.GetTextureOffset(name));
            }
            result.SetFloat("_Height_Depth", campaign.GetFloat("_Height_Depth"));
            result.SetFloat("_Height_Offset", campaign.GetFloat("_Height_Offset"));
            result.SetFloat(CampaignTimeline.AnimationProperty, campaign.GetFloat(CampaignTimeline.AnimationProperty));
            var draw = new Draw { Material = result, Renderer = renderer, Inputs = new MaterialPropertyBlock() };
            // This renderer belongs exclusively to the campaign slab at this site.
            renderer.sharedMaterial = result;
            attached = true;
            renderer.GetPropertyBlock(draw.Inputs);
            draw.Inputs.SetTexture("_ScomRest", ground.EnsureRestCoordinates());
            draw.BindMap();
            users.Add(result, draw);
            if (!reported)
            {
                Debug.Log("[SCOM Yolona shatter] Bound native map textures to the fracture on " + MapManager.mapFile.filePath);
                reported = true;
            }
            return result;
        }
        catch (Exception ex)
        {
            if (attached)
            {
                renderer.SetPropertyBlock(null);
                renderer.sharedMaterial = campaign;
                users.Remove(result);
            }
            if (result != null) Object.Destroy(result);
            if (!warned) Debug.LogWarning("[SCOM Yolona shatter] Using the baked terrain material: " + ex.Message);
            warned = true;
            return null;
        }
    }

    private static void EnsureTemplate()
    {
        if (template != null) return;
        int quality = QualitySettings.GetQualityLevel();
        if (rejectedShader != null && rejectedQuality == quality) throw new NotSupportedException(rejectedShader);
        var stream = typeof(MapSurfaceMaterial).Assembly.GetManifestResourceStream(Resource)
            ?? throw new InvalidDataException("Missing embedded map surface shader.");
        AssetBundle loaded = null;
        try
        {
            loaded = AssetBundle.LoadFromStream(stream);
            if (loaded == null) throw new InvalidDataException("Map surface shader bundle could not be opened.");
            var asset = loaded.LoadAsset<Material>(MaterialKey);
            if (asset == null || asset.shader == null || asset.shader.name != "SCOM/Terrain Land Collapse")
                throw new InvalidDataException("Missing fracture material or its serialized shader reference.");
            var activePasses = new string[asset.passCount];
            bool colorPass = false;
            for (int i = 0; i < activePasses.Length; i++)
            {
                activePasses[i] = asset.GetPassName(i);
                colorPass |= string.Equals(activePasses[i], "GBuffer", StringComparison.OrdinalIgnoreCase) ||
                             string.Equals(activePasses[i], "Forward", StringComparison.OrdinalIgnoreCase);
            }
            if (!asset.shader.isSupported || !colorPass)
            {
                rejectedQuality = quality;
                rejectedShader = "Fracture shader " + asset.shader.name + " on " +
                    SystemInfo.graphicsDeviceType + " reports supported=" + asset.shader.isSupported +
                    ", active passes=[" + string.Join(", ", activePasses) + "].";
                throw new NotSupportedException(rejectedShader);
            }
            template = asset; bundle = loaded; bundleStream = stream;
        }
        catch
        {
            if (loaded != null) loaded.Unload(true);
            stream.Dispose();
            throw;
        }
    }

    private static void EnsureTextures()
    {
        if (table == null)
        {
            table = new Texture2D(Width, Height, TextureFormat.RGBAFloat, false, true)
                { name = "Fracture map material parameters", filterMode = FilterMode.Point, wrapMode = TextureWrapMode.Clamp };
            tableChanged = true;
        }
        if (neutralNormal == null) neutralNormal = Constant(new Color(.5f, .5f, 1f, 1f));
        if (neutralTint == null) neutralTint = Constant(new Color(.5f, .5f, .5f, .5f));
        if (clear == null) clear = Constant(Color.clear);
    }

    private static Texture2D Constant(Color value)
    {
        var texture = new Texture2D(1, 1, TextureFormat.RGBAFloat, false, true) { name = "Fracture material default" };
        texture.SetPixel(0, 0, value);
        texture.Apply(false, true);
        return texture;
    }

    private static void Parameter(int column, int row, Vector4 value)
    {
        int index = row * Width + column;
        Color color = value;
        if (parameters[index].Equals(color)) return;
        parameters[index] = color;
        tableChanged = true;
    }

    private static void Bind(int id, Texture value)
    {
        if (textures.TryGetValue(id, out var old) && old == value) return;
        textures[id] = value;
        texturesChanged = true;
    }

    private static Vector4 Read(Material source, int id, Vector4 fallback)
        => source.HasProperty(id) ? source.GetVector(id) : fallback;

    private static void RefreshMap(Material source)
    {
        terrainMaterial = source;
        nextCheck = Time.unscaledTime + 1f;
        Terrain terrain = MapManager.Terrain;
        Vector3 origin = terrain.GetPosition(), size = terrain.terrainData.size;
        Texture splat0 = MapManager.splat0, splat1 = MapManager.splat1, tint = MapManager.tintMap;
        Bind(Shader.PropertyToID("_ScomSplat0"), splat0 != null ? splat0 : clear);
        Bind(Shader.PropertyToID("_ScomSplat1"), splat1 != null ? splat1 : clear);
        Bind(Shader.PropertyToID("_ScomTint"), tint != null ? tint : neutralTint);
        Bind(Shader.PropertyToID("_ScomNormalTint"), MapManager.normalTintMap != null ? MapManager.normalTintMap : neutralNormal);
        var depth = source.GetTexture("_WaterDepthMask");
        Bind(Shader.PropertyToID("_ScomWaterDepth"), depth != null ? depth : clear);
        Vector4 visibility = Read(source, tintVisibility, Vector4.zero);
        Parameter(0, 2, new Vector4(source.GetFloat("_FadeStartDistance"), Mathf.Max(.1f, source.GetFloat("_FadeDistance")),
            source.GetFloat("_HeightTransition"), visibility.x));
        Parameter(0, 3, Read(source, visibility1, Vector4.zero));
        Parameter(0, 4, Read(source, visibility2, Vector4.zero));
        Parameter(0, 5, new Vector4(origin.x, origin.z, 1f / size.x, 1f / size.z));
        Texture mapNormals = terrain.drawInstanced && source.IsKeywordEnabled("_TERRAIN_INSTANCED_PERPIXEL_NORMAL")
            ? terrain.normalmapTexture : null;
        if (nativeNormals != mapNormals)
        {
            nativeNormals = mapNormals;
            texturesChanged = true;
        }
        float normalTexel = mapNormals != null ? 1f / terrain.terrainData.heightmapResolution : 0f;
        Parameter(0, 6, new Vector4(splat0 != null ? 1f / splat0.width : 0f, splat0 != null ? 1f / splat0.height : 0f,
            normalTexel, normalTexel));
        int count = Math.Min(MapManager.mapFile.stratumLayers.Length, source.IsKeywordEnabled("_TERRAIN_8_LAYERS_RTS") ? MaxLayers : 5);
        bool nearUsesFarNormals = false;
        for (int i = 0; i < MaxLayers; i++)
        {
            bool active = i < count && MapManager.mapFile.stratumLayers[i] != null;
            var diffuse = active ? source.GetTexture(gameAlbedo[i]) : null;
            var bumps = active ? source.GetTexture(gameNormal[i]) : null;
            var masks = active ? source.GetTexture(gameMask[i]) : null;
            Bind(albedo[i], diffuse != null ? diffuse : Texture2D.whiteTexture);
            Bind(normal[i], bumps != null ? bumps : neutralNormal);
            Bind(mask[i], masks != null ? masks : Texture2D.whiteTexture);
            if (!active || diffuse == null) { Parameter(1, 8 + i, Vector4.zero); continue; }
            var layer = MapManager.mapFile.stratumLayers[i];
            var near = Read(source, tiling[i], new Vector4(1f / Mathf.Max(.001f, layer.tileSize.x), 1f / Mathf.Max(.001f, layer.tileSize.y), 0, 0));
            var far = Read(source, farTiling[i], new Vector4(1f / Mathf.Max(.001f, layer.tileSizeFar.x), 1f / Mathf.Max(.001f, layer.tileSizeFar.y), 0, 0));
            var scales = Read(source, normalScale[i], new Vector4(layer.normalScale, layer.normalScaleFar, layer.normalFarNearBlend, 1));
            var flips = Read(source, flip[i], Vector4.zero);
            int row = 8 + i;
            Parameter(0, row, new Vector4(near.x, near.y, far.x, far.y));
            Parameter(1, row, new Vector4(scales.x, scales.y, scales.z, 1f));
            Parameter(2, row, Read(source, remap[i], layer.diffuseRemap));
            Parameter(3, row, Read(source, farRemap[i], layer.farColorRemap.linear));
            Parameter(4, row, Read(source, maskMin[i], layer.maskRemapMin));
            Parameter(5, row, Read(source, maskMax[i], layer.maskRemapMax));
            Parameter(6, row, flips);
            nearUsesFarNormals |= scales.z > 0f;
        }
        Parameter(0, 7, new Vector4(visibility.y, visibility.z, count, nearUsesFarNormals ? 1f : 0f));
        // The adapter reuses the original named samplers. Retain map filtering
        // and anisotropy for tiled strata; auxiliary map/coordinate textures clamp.
        Bind(Shader.PropertyToID("_Surface_Detail_Diffuse"), source.GetTexture(gameAlbedo[0]) ?? Texture2D.whiteTexture);
        Bind(Shader.PropertyToID("_Surface_Detail_Normals"), source.GetTexture(gameNormal[0]) ?? source.GetTexture(gameAlbedo[0]));
        if (texturesChanged)
        {
            foreach (var draw in users.Values) draw.BindMap();
            texturesChanged = false;
        }
    }

    private static void UpdateView()
    {
        Camera camera = MainCamera.Cam;
        Vector3 eye = camera != null ? camera.transform.position : Vector3.zero;
        Parameter(0, 0, new Vector4(eye.x, eye.y, eye.z, Shader.GetGlobalFloat(freezing)));
        Parameter(0, 1, Shader.GetGlobalVector(waterLevel));
        if (!tableChanged) return;
        table.SetPixelData(parameters, 0);
        table.Apply(false, false);
        tableChanged = false;
    }

    internal static void Update()
    {
        if (users.Count == 0 || !MapManager.IsMapLoadedForClient || MapManager.Terrain == null) return;
        try
        {
            var source = MapManager.Terrain.materialTemplate;
            if (source != null && (terrainMaterial != source || Time.unscaledTime >= nextCheck)) RefreshMap(source);
            UpdateView();
        }
        catch (Exception ex)
        {
            // A replaced map texture must not interrupt the shared collapse update.
            if (!warned) Debug.LogWarning("[SCOM Yolona shatter] Map material refresh delayed: " + ex.Message);
            warned = true;
        }
    }

    internal static void Forget(Material material) { users.Remove(material); }

    internal static void Release()
    {
        users.Clear(); textures.Clear();
        if (table != null) Object.Destroy(table);
        if (clear != null) Object.Destroy(clear);
        if (neutralTint != null) Object.Destroy(neutralTint);
        if (neutralNormal != null) Object.Destroy(neutralNormal);
        table = clear = neutralTint = neutralNormal = null;
        terrainMaterial = null; nativeNormals = null; template = null; rejectedShader = null;
        tableChanged = texturesChanged = warned = reported = false;
        if (bundle != null) bundle.Unload(true);
        bundle = null;
        bundleStream?.Dispose(); bundleStream = null;
    }
}
