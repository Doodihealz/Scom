using System;
using System.Collections.Generic;
using EM.Gamedata;
using HarmonyLib;
using UnityEngine;

namespace SupComStyleUI;

// Resource identity is part of the mod's palette, independent of optional HUD
// layout. These materials belong only to native alloy deposit marker geometry.
internal static class ResourceMarkerColors
{
    private const string MaterialRoot = "VFX/Objective Markers/";
    private const string FrameColor = "_Frame_Color";
    private const string BaseColor = "_Base_Tiling_Color";
    private static readonly Color Alloy = new Color32(158, 213, 70, 255);
    private static readonly Dictionary<int, MaterialState> originals = new Dictionary<int, MaterialState>();
    private static Action<string> warning;
    private static bool installed;
    private static bool warned;

    private sealed class MaterialState
    {
        public Material Material;
        public bool HasFrame, HasBase;
        public Color Frame, Base;
    }

    public static void Install(Harmony harmony, Action<string> warn)
    {
        if (installed) return;
        warning = warn;
        warned = false;
        try
        {
            var method = AccessTools.DeclaredMethod(typeof(Data.SanMaterial), "GetMaterial", Type.EmptyTypes);
            if (method == null || method.ReturnType != typeof(Material))
                throw new MissingMethodException("The native resource marker material hook was not found.");
            harmony.Patch(method, postfix: new HarmonyMethod(typeof(ResourceMarkerColors), nameof(OnMaterialReady)));
            installed = true;
        }
        catch (Exception error) { WarnOnce("Alloy deposit marker colors could not be installed: " + error.Message); }
    }

    private static bool IsAlloyMarker(string path)
    {
        if (string.IsNullOrEmpty(path)) return false;
        path = path.Replace('\\', '/');
        return Matches(path, MaterialRoot + "Resource Marker_Alloy_Billboard.sanmaterial") ||
            Matches(path, MaterialRoot + "Resource Marker_Alloy_Flat.sanmaterial") ||
            Matches(path, MaterialRoot + "Resource Marker_Alloy_Flat_Elevate.sanmaterial");
    }

    private static bool Matches(string path, string target)
        => string.Equals(path, target, StringComparison.OrdinalIgnoreCase) || path.EndsWith("/" + target, StringComparison.OrdinalIgnoreCase);

    private static void OnMaterialReady(Data.SanMaterial __instance, Material __result)
    {
        if (!installed || __instance == null || __result == null || !IsAlloyMarker(__instance.LoadedPath)) return;
        try
        {
            int id = __result.GetInstanceID();
            if (!originals.TryGetValue(id, out var state) || !ReferenceEquals(state.Material, __result))
            {
                state = new MaterialState
                {
                    Material = __result,
                    HasFrame = __result.HasProperty(FrameColor),
                    HasBase = __result.HasProperty(BaseColor)
                };
                if (state.HasFrame) state.Frame = __result.GetColor(FrameColor);
                if (state.HasBase) state.Base = __result.GetColor(BaseColor);
                originals[id] = state;
            }
            // Keep the shader's authored alpha/HDR intensity, opacity, masks,
            // queues and all renderer state; only the alloy marker hue changes.
            if (state.HasFrame) SetHue(__result, FrameColor);
            if (state.HasBase) SetHue(__result, BaseColor);
        }
        catch (Exception error) { WarnOnce("An alloy deposit marker could not be recolored: " + error.Message); }
    }

    private static void SetHue(Material material, string property)
    {
        Color current = material.GetColor(property);
        Color next = new Color(Alloy.r, Alloy.g, Alloy.b, current.a);
        if (current != next) material.SetColor(property, next);
    }

    private static void WarnOnce(string message)
    {
        if (warned) return;
        warned = true;
        warning?.Invoke(message);
    }

    public static void Dispose()
    {
        installed = false;
        foreach (var state in originals.Values)
        {
            if (state.Material == null) continue;
            if (state.HasFrame) state.Material.SetColor(FrameColor, state.Frame);
            if (state.HasBase) state.Material.SetColor(BaseColor, state.Base);
        }
        originals.Clear();
        warning = null;
    }
}
