using System;
using EM.Gamedata;
using UnityEngine;
using UnityEngine.Rendering;
using Object = UnityEngine.Object;

namespace ScomShatter;

// Owns the material instances; the small immutable texture pair is shared only
// while waterfalls exist. No native map material or texture is modified.
internal sealed class WaterfallMaterial : IDisposable
{
    private const string SourcePath = "VFX/Materials/Water/Water Splash Medium.sanmaterial";
    private static readonly int CompTexture = Shader.PropertyToID("_CompTexture");
    private static readonly int Opacity = Shader.PropertyToID("_Opacity");
    private static Texture2D sheetTexture, crestTexture;
    private static int textureUsers;
    private bool ownsTextures, disposed;
    private float lastAge = float.NaN, lastLiquid = float.NaN;

    internal Material Sheet { get; private set; }
    internal Material Crest { get; private set; }
    internal int SheetPass { get; private set; }
    internal int CrestPass { get; private set; }

    internal WaterfallMaterial()
    {
        try
        {
            var source = Load.LoadGamedataMaterial(Data.GetFileEntry(SourcePath))?.GetMaterial();
            if (source == null || source.shader == null || !source.shader.isSupported ||
                source.shader.name != "Shader Graphs/Particle Composite Generic_Master" ||
                source.FindPass("ForwardOnly") < 0 || !source.HasProperty(CompTexture) ||
                !source.HasProperty(Opacity))
                throw new NotSupportedException("Native waterfall composite shader is unavailable.");
            AcquireTextures();
            ownsTextures = true;
            Sheet = Create(source, sheetTexture, false);
            Crest = Create(source, crestTexture, true);
            // The private water pass submits these materials explicitly. Keep
            // the original shader and visual properties on both layers.
            SheetPass = Sheet.FindPass("ForwardOnly");
            CrestPass = Crest.FindPass("ForwardOnly");
            if (SheetPass < 0 || CrestPass < 0)
                throw new NotSupportedException("The native waterfall colour pass is unavailable.");
            SetAge(0f, 0f);
        }
        catch
        {
            Dispose();
            throw;
        }
    }

    private static Material Create(Material source, Texture texture, bool foam)
    {
        var material = new Material(source) {
            name = foam ? "Fracture waterfall aeration" : "Fracture flowing water",
            hideFlags = HideFlags.HideAndDontSave
        };
        try
        {
            // Shipped splash RGB is grayscale with independent alpha. Its
            // compiled ForwardOnly program binds _CompTexture_ST, so offsets
            // reach the sampled UVs without rebuilding the mesh each frame.
            material.SetTexture(CompTexture, texture);
            material.SetTextureScale(CompTexture, Vector2.one);
            material.SetTextureOffset(CompTexture, Vector2.zero);
            material.SetFloat("_X", 1f);
            material.SetFloat("_Y", 1f);
            material.SetFloat("_Animation_by_Time", 0f);
            material.SetFloat("_MotionVectorIntensity", 0f);
            material.SetFloat("_FlameBoost", 0f);
            material.SetFloat("_Custom_Flame_Gradient_Intensity", 0f);
            material.SetFloat("_MicroDetailer_Intensity", 0f);
            material.SetFloat("_Trail_Shadows", 0f);
            material.SetFloat("_Self_Shadow_Intensity", 0f);
            material.SetFloat("_FresnelOpacity", 0f);
            material.SetFloat("_Mask_Alpha_Contribution", 0f);
            material.SetFloat("_Mask_Diffuse_Contribution", 0f);
            material.SetFloat("_OpacityCrunch", 0f);
            material.SetFloat("_DepthFade", .08f);
            material.SetFloat("_DepthFadePower", 1f);
            // The native splash deliberately vanishes below sea level. Its
            // ForwardOnly program multiplies RGB and alpha by this height
            // ramp; move the ramp below every supported map/chasm elevation.
            material.SetVector("_WaterHeightFade", new Vector4(-100000f, -99999f, 0f, 0f));
            material.SetFloat("_Depth_Contact_Additive", 0f);
            material.SetVector("_Texture_Offset_by_R", Vector4.zero);
            material.SetVector("_Comp_Remap_Min", Vector4.zero);
            material.SetVector("_Comp_Remap_Max", Vector4.one);
            material.SetColor("_FlameColor", Color.clear);
            material.SetColor("_DiffuseColor", foam ? new Color(.82f, .94f, .94f, 0f)
                : new Color(.34f, .64f, .68f, 0f));
            material.SetColor("_AmbientColor", foam ? new Color(.64f, .79f, .81f, 0f)
                : new Color(.25f, .47f, .53f, 0f));
            material.DisableKeyword("_ALPHATEST_ON");
            material.EnableKeyword("_SURFACE_TYPE_TRANSPARENT");
            material.EnableKeyword("_DOUBLESIDED_ON");
            material.SetFloat("_AlphaCutoffEnable", 0f);
            material.SetFloat("_DoubleSidedEnable", 1f);
            material.SetInt("_CullMode", (int)CullMode.Off);
            material.SetInt("_CullModeForward", (int)CullMode.Off);
            material.SetInt("_ZWrite", 0);
            material.SetInt("_TransparentZWrite", 0);
            material.SetShaderPassEnabled("ShadowCaster", false);
            material.SetShaderPassEnabled("DepthForwardOnly", false);
            material.SetShaderPassEnabled("MotionVectors", false);
            return material;
        }
        catch
        {
            Object.Destroy(material);
            throw;
        }
    }

    // Both composite layers scroll in the same direction. Simulation age keeps
    // the animation deterministic through pause and replay.
    internal void SetAge(float simulationAge, float liquidFraction)
    {
        if (disposed) return;
        float liquid = Finite(liquidFraction) ? Mathf.Clamp01(liquidFraction) : 0f;
        if (!Finite(simulationAge) || simulationAge < 0f) { simulationAge = 0f; liquid = 0f; }
        if (liquid != lastLiquid)
        {
            Sheet.SetFloat(Opacity, .9f * liquid);
            Crest.SetFloat(Opacity, .92f * liquid);
            lastLiquid = liquid;
        }
        if (simulationAge == lastAge) return;
        lastAge = simulationAge;
        Sheet.SetTextureOffset(CompTexture, new Vector2(0f, Mathf.Repeat(simulationAge * .72f, 1f)));
        Crest.SetTextureOffset(CompTexture, new Vector2(Mathf.Repeat(simulationAge * .035f, 1f),
            Mathf.Repeat(simulationAge * .43f, 1f)));
    }

    private static void AcquireTextures()
    {
        if (textureUsers == 0)
        {
            Texture2D sheet = null, crest = null;
            try
            {
                sheet = MakeTexture(false);
                crest = MakeTexture(true);
                sheetTexture = sheet;
                crestTexture = crest;
            }
            catch
            {
                if (sheet != null) Object.Destroy(sheet);
                if (crest != null) Object.Destroy(crest);
                throw;
            }
        }
        textureUsers++;
    }

    private static Texture2D MakeTexture(bool foam)
    {
        const int width = 128;
        int height = foam ? 128 : 256;
        var texture = new Texture2D(width, height, TextureFormat.RGBA32, true, false) {
            name = foam ? "Waterfall broken foam" : "Waterfall flowing streaks",
            hideFlags = HideFlags.HideAndDontSave,
            wrapMode = TextureWrapMode.Repeat,
            filterMode = FilterMode.Trilinear,
            anisoLevel = 2
        };
        try
        {
            var pixels = new Color32[width * height];
            for (int y = 0; y < height; y++)
                for (int x = 0; x < width; x++)
                {
                    float u = x / (float)width, v = y / (float)height;
                    float grain = Noise(u, v, 32, 32);
                    float alpha, light;
                    if (foam)
                    {
                        float cells = .65f * Noise(u, v, 12, 10) + .35f * grain;
                        float froth = Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(.34f, .7f, cells));
                        alpha = froth * .88f;
                        light = .56f + .44f * froth;
                    }
                    else
                    {
                        // Periodic sideways drift bends long ropes of aerated
                        // water. Coarser downflow gaps keep them from reading
                        // as fixed parallel lines at strategic camera distance.
                        float drift = .035f * Mathf.Sin(v * Mathf.PI * 4f) +
                            .018f * Mathf.Sin(v * Mathf.PI * 10f + u * Mathf.PI * 2f);
                        float ropes = Noise(u + drift, v, 24, 3);
                        float broad = Noise(u, v, 7, 5);
                        float breaks = Noise(u + drift, v, 11, 14);
                        float streak = Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(.32f, .79f, ropes));
                        float aeration = streak * (.4f + .6f * breaks);
                        alpha = Mathf.Clamp01(.29f + .38f * broad + .34f * aeration);
                        light = Mathf.Clamp01(.31f + .6f * aeration + .13f * grain);
                    }
                    byte intensity = (byte)Mathf.RoundToInt(light * 255f);
                    pixels[y * width + x] = new Color32(intensity, intensity, intensity,
                        (byte)Mathf.RoundToInt(alpha * 255f));
                }
            texture.SetPixels32(pixels);
            texture.Apply(true, true);
            return texture;
        }
        catch
        {
            Object.Destroy(texture);
            throw;
        }
    }

    // Tileable value noise: integer lattice periods guarantee both texture
    // seams match, including after scrolling and mip generation.
    private static float Noise(float u, float v, int columns, int rows)
    {
        float x = Mathf.Repeat(u, 1f) * columns, y = Mathf.Repeat(v, 1f) * rows;
        int ix = Mathf.FloorToInt(x), iy = Mathf.FloorToInt(y);
        float tx = x - ix, ty = y - iy;
        tx = tx * tx * (3f - 2f * tx);
        ty = ty * ty * (3f - 2f * ty);
        return Mathf.Lerp(Mathf.Lerp(Hash(ix, iy), Hash((ix + 1) % columns, iy), tx),
            Mathf.Lerp(Hash(ix, (iy + 1) % rows), Hash((ix + 1) % columns, (iy + 1) % rows), tx), ty);
    }

    private static float Hash(int x, int y)
    {
        unchecked
        {
            uint h = (uint)x * 374761393u + (uint)y * 668265263u + 279470273u;
            h = (h ^ (h >> 13)) * 1274126177u;
            return ((h ^ (h >> 16)) & 65535u) / 65535f;
        }
    }

    private static bool Finite(float value) => !float.IsNaN(value) && !float.IsInfinity(value);

    public void Dispose()
    {
        if (disposed) return;
        disposed = true;
        if (Sheet != null) Object.Destroy(Sheet);
        if (Crest != null) Object.Destroy(Crest);
        Sheet = Crest = null;
        if (!ownsTextures) return;
        ownsTextures = false;
        if (--textureUsers != 0) return;
        if (sheetTexture != null) Object.Destroy(sheetTexture);
        if (crestTexture != null) Object.Destroy(crestTexture);
        sheetTexture = crestTexture = null;
    }
}
