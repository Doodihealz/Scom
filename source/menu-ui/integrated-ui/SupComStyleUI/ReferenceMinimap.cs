using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using EM.Controls.Cameras;
using EM.Lua.Client;
using EM.Map;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace SupComStyleUI;

/// <summary>
/// A clean terrain overview and the client's currently intel-visible units.
/// It never changes the rendering camera or reads host-only unit information.
/// Lua calls run only from the existing client RenderUpdate postfix.
/// </summary>
internal sealed class ReferenceMinimap : MaskableGraphic, IPointerDownHandler, IDragHandler
{
    private struct Blip
    {
        public float x;
        public float z;
        public Color color;
        public bool experimental;
    }

    private const string BridgeName = "__SCOMReferenceMinimap";
    private const int Globals = -10002;
    private const int MaximumBlips = 4096;
    private const int MaximumPayload = 1048576;
    private const string Script = @"
local bridge = { version = 2 }
local rows = {}
local function experimental(unit)
    if type(unit.HasTags) ~= 'function' or type(Tags) ~= 'table' then return false end
    for _, name in ipairs({'TECH4', 'TECH5', 'EXPERIMENTAL', 'SCFA_EXPERIMENTAL'}) do
        local tag = Tags[name]
        if type(tag) == 'table' and unit:HasTags(tag) then return true end
    end
    return false
end
function bridge.Sample()
    local units = __Entities and __Entities.Units
    if type(units) ~= 'table' then return '' end
    local count = 0
    for _, unit in pairs(units) do
        if type(unit) == 'table' and type(unit.GetPosition) == 'function' and
           type(unit.IsPlacementGhost) == 'function' and type(unit.IsUpgrade) == 'function' and
           not unit.dead and not unit.deleted and unit.isInitialized and
           not unit:IsPlacementGhost() and not unit:IsUpgrade() then
            local vision = unit.isIntelVisionVisible == true
            local contact = unit.isIntelRadarVisible == true or unit.isIntelSonarVisible == true
            -- Native radar icons use this same client's local entity position.
            -- Contact intel authorizes position, not army or experimental class.
            -- Spectators follow native flags too, without ownership overrides.
            if vision or contact then
                local position = unit:GetPosition()
                if position then
                    local color = vision and unit.army and unit.army.color
                    local r, g, b = 1, 1, 1
                    if color then r, g, b = color.x, color.y, color.z end
                    count = count + 1
                    rows[count] = string.format('%.5f\t%.5f\t%.4f\t%.4f\t%.4f\t%d',
                        position.x, position.z, r, g, b, vision and experimental(unit) and 1 or 0)
                    if count >= 4096 then break end
                end
            end
        end
    end
    for i = #rows, count + 1, -1 do rows[i] = nil end
    return table.concat(rows, '\n')
end
function bridge.Focus(x, z)
    if type(x) ~= 'number' or type(z) ~= 'number' then return end
    Import('client/input/cameraController.lua').FitCameraToPositions({EngineClasses.float3(x, 0, z)})
end
_G.__SCOMReferenceMinimap = bridge
return bridge
";

    private static readonly byte[] ScriptBytes = Encoding.UTF8.GetBytes(Script);
    private readonly List<Blip> blips = new List<Blip>();
    private readonly Vector2[] footprint = new Vector2[4];
    private Image previewImage;
    private Sprite ownedSprite;
    private Texture2D ownedTexture;
    private SanMap currentMap;
    private float nextPreviewAttempt;
    private float mapWidth;
    private float mapLength;
    private Vector2 mapOrigin;
    private bool footprintValid;
    private lua_State loadedState;
    private float nextSample;
    private bool focusPending;
    private Vector2 focusPosition;

    public string LastError { get; private set; } = string.Empty;

    public static ReferenceMinimap Create(RectTransform host)
    {
        GameObject imageObject = new GameObject("SCOM Map Preview", typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
        RectTransform imageRect = (RectTransform)imageObject.transform;
        FillHost(imageRect, host);
        Image image = imageObject.GetComponent<Image>();
        image.raycastTarget = false;
        image.preserveAspect = true;
        image.enabled = false;

        GameObject overlayObject = new GameObject("SCOM Live Minimap", typeof(RectTransform), typeof(CanvasRenderer), typeof(ReferenceMinimap));
        FillHost((RectTransform)overlayObject.transform, host);
        ReferenceMinimap result = overlayObject.GetComponent<ReferenceMinimap>();
        result.previewImage = image;
        result.color = Color.white;
        result.raycastTarget = true;
        return result;
    }

    private static void FillHost(RectTransform rect, RectTransform host)
    {
        rect.gameObject.layer = host.gameObject.layer;
        rect.SetParent(host, false);
        rect.anchorMin = Vector2.zero;
        rect.anchorMax = Vector2.one;
        rect.offsetMin = Vector2.zero;
        rect.offsetMax = Vector2.zero;
        rect.localScale = Vector3.one;
    }

    public void TickFromClientLua()
    {
        if (!isActiveAndEnabled)
        {
            return;
        }
        try
        {
            RefreshMap();
            if (currentMap == null || mapWidth <= 0f || mapLength <= 0f)
            {
                return;
            }
            if (!focusPending && Time.unscaledTime < nextSample)
            {
                return;
            }
            lua_State state = ClientLuaInterface.Data.luaState;
            if (state.IsNull)
            {
                ClearBlips("The client Lua state is not initialized.");
                nextSample = Time.unscaledTime + 1f;
                return;
            }
            if (!EnsureBridge(state))
            {
                ClearBlips(LastError);
                nextSample = Time.unscaledTime + 1f;
                return;
            }
            if (focusPending)
            {
                focusPending = false;
                FocusCamera(state, focusPosition);
            }
            if (Time.unscaledTime < nextSample)
            {
                return;
            }
            nextSample = Time.unscaledTime + 0.10f;
            if (!Sample(state))
            {
                blips.Clear();
                nextSample = Time.unscaledTime + 1f;
            }
            SetVerticesDirty();
        }
        catch (Exception ex)
        {
            ClearBlips(ex.Message);
            nextSample = Time.unscaledTime + 1f;
        }
    }

    private void RefreshMap()
    {
        SanMap map = MapManager.IsMapLoadedForClient ? MapManager.mapFile : null;
        if (ReferenceEquals(map, currentMap))
        {
            if (map != null && ownedSprite == null && Time.unscaledTime >= nextPreviewAttempt)
                CreateTerrainOverview();
            return;
        }
        currentMap = map;
        blips.Clear();
        focusPending = false;
        footprintValid = false;
        nextSample = 0f;
        SetVerticesDirty();
        mapWidth = map == null ? 0f : map.width;
        mapLength = map == null ? 0f : map.length;
        Vector3 origin = MapManager.Terrain != null ? MapManager.Terrain.GetPosition() : Vector3.zero;
        mapOrigin = new Vector2(origin.x, origin.z);
        // Keep the overview and unit coordinates on the native playable area.
        if (map != null && map.areas != null && map.areas.TryGetValue("PlayableArea", out SanMap.Area area) &&
            area != null && area.width > 0f && area.height > 0f)
        {
            mapOrigin += new Vector2(area.x, area.y);
            mapWidth = area.width;
            mapLength = area.height;
        }
        ReleasePreview();
        if (map == null)
        {
            return;
        }
        CreateTerrainOverview();
    }

    private void CreateTerrainOverview()
    {
        nextPreviewAttempt = Time.unscaledTime + 1f;
        var terrain = MapManager.Terrain;
        var tint = MapManager.tintMap;
        if (terrain == null || terrain.terrainData == null || currentMap == null ||
            currentMap.layers03 == null || currentMap.layers47 == null ||
            tint == null || !currentMap.layers03.IsCreated() || !currentMap.layers47.IsCreated() || !tint.IsCreated())
        {
            LastError = "The loaded map's terrain overview is not ready.";
            return;
        }
        // Lobby preview.png embeds numbered spawns. Build a macro overview from
        // the live stratum blend masks and each layer's own albedo. The native
        // tint input alone cannot represent the blended terrain materials.
        // This samples map textures directly; it never renders scene objects.
        const int resolution = 256;
        float longest = Mathf.Max(mapWidth, mapLength);
        int width = Mathf.Clamp(Mathf.RoundToInt(resolution * mapWidth / longest), 2, resolution);
        int height = Mathf.Clamp(Mathf.RoundToInt(resolution * mapLength / longest), 2, resolution);
        Vector3 origin = terrain.GetPosition();
        Vector3 size = terrain.terrainData.size;
        if (size.x <= 0 || size.z <= 0) return;
        var scale = new Vector2(mapWidth / size.x, mapLength / size.z);
        var offset = new Vector2((mapOrigin.x - origin.x) / size.x, (mapOrigin.y - origin.z) / size.z);
        var previous = RenderTexture.active;
        RenderTexture maskTarget = null;
        Texture2D firstMask = null;
        Texture2D secondMask = null;
        Texture2D tintPixelsTexture = null;
        Texture2D overview = null;
        try
        {
            maskTarget = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
            firstMask = new Texture2D(width, height, TextureFormat.RGBA32, false, true);
            secondMask = new Texture2D(width, height, TextureFormat.RGBA32, false, true);
            Vector2 firstMaskScale = scale;
            Vector2 firstMaskOffset = offset;
            if (currentMap.layers03_format.verticalFlip)
            {
                firstMaskScale.y = -scale.y;
                firstMaskOffset.y = 1f - offset.y;
            }
            Vector2 secondMaskScale = scale;
            Vector2 secondMaskOffset = offset;
            if (currentMap.layers47_format.verticalFlip)
            {
                secondMaskScale.y = -scale.y;
                secondMaskOffset.y = 1f - offset.y;
            }
            Graphics.Blit(currentMap.layers03, maskTarget, firstMaskScale, firstMaskOffset);
            RenderTexture.active = maskTarget;
            firstMask.ReadPixels(new Rect(0, 0, width, height), 0, 0);
            firstMask.Apply(false, false);
            Graphics.Blit(currentMap.layers47, maskTarget, secondMaskScale, secondMaskOffset);
            RenderTexture.active = maskTarget;
            secondMask.ReadPixels(new Rect(0, 0, width, height), 0, 0);
            secondMask.Apply(false, false);
            Vector2 tintScale = scale;
            Vector2 tintOffset = offset;
            if (currentMap.tintColors_format.verticalFlip)
            {
                tintScale.y = -scale.y;
                tintOffset.y = 1f - offset.y;
            }
            Graphics.Blit(tint, maskTarget, tintScale, tintOffset);
            RenderTexture.active = maskTarget;
            tintPixelsTexture = new Texture2D(width, height, TextureFormat.RGBA32, false, true);
            tintPixelsTexture.ReadPixels(new Rect(0, 0, width, height), 0, 0);
            tintPixelsTexture.Apply(false, false);

            Color[] firstWeights = firstMask.GetPixels();
            Color[] secondWeights = secondMask.GetPixels();
            Color[] tintPixels = tintPixelsTexture.GetPixels();
            Destroy(tintPixelsTexture);
            tintPixelsTexture = null;
            Color[] layerColors = GetLayerOverviewColors(currentMap);
            if (layerColors == null)
            {
                LastError = "The loaded map's terrain materials are not ready.";
                return;
            }
            Color[] pixels = new Color[width * height];
            float[,] heights = terrain.terrainData.GetInterpolatedHeights(offset.x + scale.x / (2 * width), offset.y + scale.y / (2 * height),
                width, height, scale.x / width, scale.y / height);
            for (int i = 0; i < pixels.Length; i++)
            {
                Color a = firstWeights[i];
                Color b = secondWeights[i];
                float w1 = Mathf.Clamp01(a.r), w2 = Mathf.Clamp01(a.g), w3 = Mathf.Clamp01(a.b), w4 = Mathf.Clamp01(a.a);
                float w5 = Mathf.Clamp01(b.r), w6 = Mathf.Clamp01(b.g), w7 = Mathf.Clamp01(b.b), w8 = Mathf.Clamp01(b.a);
                float layerWeight = w1 + w2 + w3 + w4 + w5 + w6 + w7 + w8;
                float w0 = Mathf.Max(0f, 1f - layerWeight);
                float total = Mathf.Max(1f, layerWeight);
                Color land = (layerColors[0] * w0 + layerColors[1] * w1 + layerColors[2] * w2 +
                    layerColors[3] * w3 + layerColors[4] * w4 + layerColors[5] * w5 +
                    layerColors[6] * w6 + layerColors[7] * w7 + layerColors[8] * w8) / total;
                Color macroTint = tintPixels[i];
                // Overview calibration: treat neutral 0.5 RGB as unity scale.
                // Bound the overview's macro tint so the sampled material hues
                // remain readable at this scale.
                Color tintMultiplier = new Color(Mathf.Clamp(2f * macroTint.r, .55f, 1.45f),
                    Mathf.Clamp(2f * macroTint.g, .55f, 1.45f), Mathf.Clamp(2f * macroTint.b, .55f, 1.45f));
                float tintStrength = Mathf.Clamp01(macroTint.a) * .35f;
                land *= Color.Lerp(Color.white, tintMultiplier, tintStrength);

                int y = i / width;
                int x = i - y * width;
                float slopeX = (heights[y, Mathf.Min(width - 1, x + 1)] - heights[y, Mathf.Max(0, x - 1)]) /
                    Mathf.Max(.001f, 2f * mapWidth / width);
                float slopeZ = (heights[Mathf.Min(height - 1, y + 1), x] - heights[Mathf.Max(0, y - 1), x]) /
                    Mathf.Max(.001f, 2f * mapLength / height);
                float hillshade = Mathf.Clamp(1f + (-slopeX * .10f + slopeZ * .07f), .86f, 1.14f);
                land *= hillshade;
                float peak = Mathf.Max(land.r, Mathf.Max(land.g, land.b));
                if (peak > .92f) land *= .92f / peak;

                if (currentMap.hasWater)
                {
                    float depth = currentMap.waterLevel - (origin.y + heights[y, x]);
                    if (depth > 0f)
                    {
                        float deep = Mathf.Clamp01(depth / 40f);
                        Color water = Color.Lerp(new Color(.13f, .28f, .31f), new Color(.035f, .095f, .14f), deep);
                        // Keep the shallow edge tied to local land, so snow and
                        // desert maps retain their own palette at the shoreline.
                        float shoreline = Mathf.Clamp01(depth / Mathf.Max(0.01f, currentMap.waterShoreDepthOffset));
                        land = Color.Lerp(land, water, shoreline);
                    }
                }
                pixels[i] = land;
            }
            overview = new Texture2D(width, height, TextureFormat.RGB24, false, true);
            overview.name = "SCOM Current Terrain Overview";
            overview.SetPixels(pixels);
            overview.Apply(false, true);
            overview.wrapMode = TextureWrapMode.Clamp;
            overview.filterMode = FilterMode.Bilinear;
            ownedSprite = Sprite.Create(overview, new Rect(0, 0, width, height), new Vector2(.5f, .5f));
            ownedSprite.name = "SCOM Clean Map Overview";
            ownedTexture = overview;
            overview = null;
            previewImage.sprite = ownedSprite;
            previewImage.enabled = true;
            LastError = string.Empty;
        }
        finally
        {
            if (overview != null) Destroy(overview);
            if (tintPixelsTexture != null) Destroy(tintPixelsTexture);
            RenderTexture.active = previous;
            if (maskTarget != null) RenderTexture.ReleaseTemporary(maskTarget);
            if (firstMask != null) Destroy(firstMask);
            if (secondMask != null) Destroy(secondMask);
        }
    }

    private static Color[] GetLayerOverviewColors(SanMap map)
    {
        Color[] colors = new Color[SanMap.STRATUM_COUNT];
        for (int layer = 0; layer < colors.Length; layer++)
        {
            SanMap.Stratum stratum = map.stratumLayers != null && layer < map.stratumLayers.Length
                ? map.stratumLayers[layer]
                : null;
            if (stratum == null || string.IsNullOrEmpty(stratum.albedo.path))
            {
                colors[layer] = Color.black;
                continue;
            }
            Texture2D albedo = stratum.albedo.Texture as Texture2D;
            if (albedo == null)
            {
                return null;
            }

            // Reduce the real albedo on the GPU once per map/layer; runtime
            // game textures are not guaranteed to be CPU-readable.
            const int samples = 8;
            RenderTexture previous = RenderTexture.active;
            RenderTexture reduced = null;
            Texture2D readback = null;
            try
            {
                reduced = RenderTexture.GetTemporary(samples, samples, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
                readback = new Texture2D(samples, samples, TextureFormat.RGBA32, false, true);
                Graphics.Blit(albedo, reduced);
                RenderTexture.active = reduced;
                readback.ReadPixels(new Rect(0, 0, samples, samples), 0, 0);
                readback.Apply(false, false);
                Color[] samplePixels = readback.GetPixels();
                Color sum = Color.black;
                for (int i = 0; i < samplePixels.Length; i++) sum += samplePixels[i];
                Color remapScale = new Color(Mathf.Clamp(2f * stratum.diffuseRemap.r, 0f, 1.5f),
                    Mathf.Clamp(2f * stratum.diffuseRemap.g, 0f, 1.5f), Mathf.Clamp(2f * stratum.diffuseRemap.b, 0f, 1.5f));
                colors[layer] = (sum / samplePixels.Length) * remapScale;
            }
            finally
            {
                RenderTexture.active = previous;
                if (reduced != null) RenderTexture.ReleaseTemporary(reduced);
                if (readback != null) Destroy(readback);
            }
        }
        return colors;
    }


    private bool EnsureBridge(lua_State state)
    {
        int top = LuaJIT.lua_gettop(state);
        try
        {
            if (LuaJIT.lua_checkstack(state, 24) == 0)
            {
                LastError = "The client Lua stack cannot reserve minimap workspace.";
                return false;
            }
            PushField(state, Globals, BridgeName);
            bool exists = LuaJIT.lua_istable(state, -1) != 0;
            LuaJIT.lua_pop(state, 1);
            if (loadedState == state && exists)
            {
                return true;
            }
            if (LuaJIT.luaL_loadbuffer(state, ScriptBytes, (ulong)ScriptBytes.Length, "@SCOM/ReferenceMinimap.lua") != 0 ||
                LuaJIT.lua_pcall(state, 0, 1, 0) != 0)
            {
                LastError = LuaJIT.lua_tostring(state, -1) ?? "The minimap Lua bridge could not load.";
                return false;
            }
            loadedState = state;
            return LuaJIT.lua_istable(state, -1) != 0;
        }
        finally
        {
            LuaJIT.lua_settop(state, top);
        }
    }

    private bool Sample(lua_State state)
    {
        int top = LuaJIT.lua_gettop(state);
        try
        {
            if (!PushFunction(state, "Sample") || LuaJIT.lua_pcall(state, 0, 1, 0) != 0)
            {
                LastError = LuaJIT.lua_tostring(state, -1) ?? "The minimap sample failed.";
                return false;
            }
            if (LuaJIT.lua_type(state, -1) != 4 || LuaJIT.lua_objlen(state, -1) > MaximumPayload)
            {
                LastError = "The minimap sample exceeded its supported size.";
                return false;
            }
            string payload = LuaJIT.lua_tostring(state, -1) ?? string.Empty;
            blips.Clear();
            int position = 0;
            int rowCount = 0;
            while (position < payload.Length && rowCount++ < MaximumBlips)
            {
                int end = payload.IndexOf('\n', position);
                if (end < 0) end = payload.Length;
                ReadOnlySpan<char> row = payload.AsSpan(position, end - position);
                position = end + 1;
                if (!ReadNumber(ref row, out float x) || !ReadNumber(ref row, out float z) ||
                    !ReadNumber(ref row, out float r) || !ReadNumber(ref row, out float g) || !ReadNumber(ref row, out float b) ||
                    !ReadNumber(ref row, out float experimental) || !row.IsEmpty || experimental != 0f && experimental != 1f)
                {
                    continue;
                }
                if (x < mapOrigin.x || z < mapOrigin.y || x > mapOrigin.x + mapWidth || z > mapOrigin.y + mapLength)
                {
                    continue;
                }
                blips.Add(new Blip
                {
                    x = x,
                    z = z,
                    color = new Color(Mathf.Clamp01(r), Mathf.Clamp01(g), Mathf.Clamp01(b), 1f),
                    experimental = experimental == 1f
                });
            }
            LastError = ownedSprite == null ? "The loaded map's terrain overview is not ready." : string.Empty;
            return true;
        }
        finally
        {
            LuaJIT.lua_settop(state, top);
        }
    }

    private static bool ReadNumber(ref ReadOnlySpan<char> row, out float value)
    {
        int separator = row.IndexOf('\t');
        ReadOnlySpan<char> field = separator < 0 ? row : row.Slice(0, separator);
        row = separator < 0 ? ReadOnlySpan<char>.Empty : row.Slice(separator + 1);
        return float.TryParse(field, NumberStyles.Float, CultureInfo.InvariantCulture, out value) && !float.IsNaN(value) && !float.IsInfinity(value);
    }

    private bool FocusCamera(lua_State state, Vector2 position)
    {
        int top = LuaJIT.lua_gettop(state);
        try
        {
            if (!PushFunction(state, "Focus"))
            {
                return false;
            }
            LuaJIT.lua_pushnumber(state, position.x);
            LuaJIT.lua_pushnumber(state, position.y);
            if (LuaJIT.lua_pcall(state, 2, 0, 0) != 0)
            {
                LastError = LuaJIT.lua_tostring(state, -1) ?? "The minimap could not focus the camera.";
                return false;
            }
            return true;
        }
        finally
        {
            LuaJIT.lua_settop(state, top);
        }
    }

    private static bool PushFunction(lua_State state, string name)
    {
        PushField(state, Globals, BridgeName);
        if (LuaJIT.lua_istable(state, -1) == 0)
        {
            return false;
        }
        int index = LuaJIT.lua_gettop(state);
        PushField(state, index, name);
        return LuaJIT.lua_isfunction(state, -1) != 0;
    }

    private static void PushField(lua_State state, int table, string name)
    {
        LuaJIT.lua_pushstring(state, name);
        LuaJIT.lua_rawget(state, table);
    }

    private void LateUpdate()
    {
        bool wasValid = footprintValid;
        if (currentMap == null || MainCamera.Cam == null || mapWidth <= 0f || mapLength <= 0f)
        {
            footprintValid = false;
            if (wasValid) SetVerticesDirty();
            return;
        }
        Plane plane = MainCamera.TerrainRaycastPlane;
        bool changed = !wasValid;
        for (int i = 0; i < 4; i++)
        {
            Vector2 viewport = i == 0 ? Vector2.zero : i == 1 ? Vector2.right : i == 2 ? Vector2.one : Vector2.up;
            Ray ray = MainCamera.ViewportPointToRay(viewport);
            if (!plane.Raycast(ray, out float distance) || distance <= 0f)
            {
                footprintValid = false;
                if (wasValid) SetVerticesDirty();
                return;
            }
            Vector3 point = ray.GetPoint(distance);
            Vector2 projected = MapPoint(point.x, point.z);
            if ((projected - footprint[i]).sqrMagnitude > 0.04f)
            {
                footprint[i] = projected;
                changed = true;
            }
        }
        footprintValid = true;
        if (changed) SetVerticesDirty();
    }

    private Rect OverviewRect()
    {
        Rect rect = rectTransform.rect;
        float aspect = ownedSprite != null ? ownedSprite.rect.width / ownedSprite.rect.height : (mapLength > 0f ? mapWidth / mapLength : 1f);
        if (rect.width / Mathf.Max(1f, rect.height) > aspect)
        {
            float width = rect.height * aspect;
            return new Rect(rect.center.x - width * 0.5f, rect.yMin, width, rect.height);
        }
        float height = rect.width / Mathf.Max(0.001f, aspect);
        return new Rect(rect.xMin, rect.center.y - height * 0.5f, rect.width, height);
    }

    private Vector2 MapPoint(float x, float z)
    {
        Rect rect = OverviewRect();
        return new Vector2(rect.xMin + (x - mapOrigin.x) / mapWidth * rect.width,
            rect.yMin + (z - mapOrigin.y) / mapLength * rect.height);
    }

    protected override void OnPopulateMesh(VertexHelper vh)
    {
        vh.Clear();
        if (currentMap == null || mapWidth <= 0f || mapLength <= 0f)
        {
            return;
        }
        Rect bounds = OverviewRect();
        foreach (Blip blip in blips)
        {
            if (vh.currentVertCount > 64980) break;
            Vector2 point = MapPoint(blip.x, blip.z);
            Circle(vh, point, blip.experimental ? 3.2f : 1.6f, blip.color, bounds);
        }
        if (footprintValid)
        {
            for (int i = 0; i < 4; i++)
            {
                Line(vh, footprint[i], footprint[(i + 1) % 4], new Color(0.66f, 0.96f, 1f, 0.95f), bounds);
            }
        }
    }

    private static void Circle(VertexHelper vh, Vector2 point, float radius, Color tint, Rect clip)
    {
        const int segments = 12;
        int start = vh.currentVertCount;
        vh.AddVert(point, tint, Vector2.zero);
        for (int index = 0; index < segments; index++)
        {
            float angle = 2f * Mathf.PI * index / segments;
            var edge = new Vector2(Mathf.Clamp(point.x + Mathf.Cos(angle) * radius, clip.xMin, clip.xMax),
                Mathf.Clamp(point.y + Mathf.Sin(angle) * radius, clip.yMin, clip.yMax));
            vh.AddVert(edge, tint, Vector2.zero);
            vh.AddTriangle(start, start + 1 + index, start + 1 + (index + 1) % segments);
        }
    }

    private static void Line(VertexHelper vh, Vector2 a, Vector2 b, Color tint, Rect clip)
    {
        float begin = 0f;
        float end = 1f;
        Vector2 delta = b - a;
        if (!Clip(-delta.x, a.x - clip.xMin, ref begin, ref end) || !Clip(delta.x, clip.xMax - a.x, ref begin, ref end) ||
            !Clip(-delta.y, a.y - clip.yMin, ref begin, ref end) || !Clip(delta.y, clip.yMax - a.y, ref begin, ref end)) return;
        b = a + delta * end;
        a += delta * begin;
        Vector2 offset = new Vector2(-(b - a).y, (b - a).x).normalized * 0.65f;
        int start = vh.currentVertCount;
        vh.AddVert(a - offset, tint, Vector2.zero);
        vh.AddVert(a + offset, tint, Vector2.zero);
        vh.AddVert(b + offset, tint, Vector2.zero);
        vh.AddVert(b - offset, tint, Vector2.zero);
        vh.AddTriangle(start, start + 1, start + 2);
        vh.AddTriangle(start, start + 2, start + 3);
    }

    private static bool Clip(float p, float q, ref float begin, ref float end)
    {
        if (Mathf.Abs(p) < 0.00001f) return q >= 0f;
        float t = q / p;
        if (p < 0f) { if (t > end) return false; begin = Mathf.Max(begin, t); }
        else { if (t < begin) return false; end = Mathf.Min(end, t); }
        return true;
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        QueueFocus(eventData);
    }

    public void OnDrag(PointerEventData eventData)
    {
        QueueFocus(eventData);
    }

    private void QueueFocus(PointerEventData eventData)
    {
        if (eventData.button != PointerEventData.InputButton.Left || currentMap == null || mapWidth <= 0f || mapLength <= 0f ||
            !RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTransform, eventData.position, eventData.pressEventCamera, out Vector2 local))
        {
            return;
        }
        Rect bounds = OverviewRect();
        if (!bounds.Contains(local)) return;
        focusPosition = new Vector2(mapOrigin.x + Mathf.Clamp01((local.x - bounds.xMin) / bounds.width) * mapWidth,
            mapOrigin.y + Mathf.Clamp01((local.y - bounds.yMin) / bounds.height) * mapLength);
        focusPending = true;
        eventData.Use();
    }

    public override bool Raycast(Vector2 screenPoint, Camera eventCamera)
    {
        return currentMap != null && RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTransform, screenPoint, eventCamera, out Vector2 local) &&
            OverviewRect().Contains(local) && base.Raycast(screenPoint, eventCamera);
    }

    private void ClearBlips(string error)
    {
        blips.Clear();
        LastError = error;
        SetVerticesDirty();
    }

    private void ReleasePreview()
    {
        if (previewImage != null)
        {
            previewImage.sprite = null;
            previewImage.enabled = false;
        }
        if (ownedSprite != null) Destroy(ownedSprite);
        if (ownedTexture != null) Destroy(ownedTexture);
        ownedSprite = null;
        ownedTexture = null;
    }

    protected override void OnDisable()
    {
        focusPending = false;
        blips.Clear();
        footprintValid = false;
        base.OnDisable();
    }

    protected override void OnDestroy()
    {
        ReleasePreview();
        loadedState = default(lua_State);
        base.OnDestroy();
    }
}
