using System.Collections.Generic;
using TMPro;
using UnityEngine;

namespace SupComStyleUI;

// Owned copies retain the font atlas while keeping native colored glows from
// overriding resource identity colors or blurring small hotkey labels.
internal static class HudTextMaterials
{
    private static readonly Dictionary<int, Material> materials = new Dictionary<int, Material>();

    internal static Material Crisp(TMP_FontAsset font, Material fallback)
    {
        if (font == null) return fallback;
        int id = font.GetInstanceID();
        if (materials.TryGetValue(id, out var cached) && cached != null) return cached;
        Material source = font.material != null ? font.material : fallback;
        if (source == null) return fallback;
        var material = new Material(source) { name = "SCOM Crisp HUD Text " + font.name };
        material.DisableKeyword("GLOW_ON");
        material.DisableKeyword("UNDERLAY_ON");
        material.DisableKeyword("UNDERLAY_INNER");
        if (material.HasProperty("_FaceColor")) material.SetColor("_FaceColor", Color.white);
        if (material.HasProperty("_FaceDilate")) material.SetFloat("_FaceDilate", 0f);
        if (material.HasProperty("_GlowPower")) material.SetFloat("_GlowPower", 0f);
        if (material.HasProperty("_OutlineWidth")) material.SetFloat("_OutlineWidth", 0f);
        materials[id] = material;
        return material;
    }

    internal static void Cleanup()
    {
        foreach (var material in materials.Values)
            if (material != null) Object.Destroy(material);
        materials.Clear();
    }
}
