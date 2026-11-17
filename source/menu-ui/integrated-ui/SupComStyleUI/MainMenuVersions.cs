using System;
using System.Reflection;
using EM.UI;
using TMPro;
using UnityEngine;

namespace SupComStyleUI;

internal static class MainMenuVersions
{
    private static readonly FieldInfo VersionNumber = typeof(HomeInterface).GetField("versionNumber", BindingFlags.Instance | BindingFlags.NonPublic);

    public static void Ensure(HomeInterface home)
    {
        if (home == null) return;
        var text = VersionNumber?.GetValue(home) as TMP_Text;
        if (text == null) return;
        text.text = "Mod version: " + ModVersion() + "\nGame version: Beta v" + Application.version;
        text.alignment = TextAlignmentOptions.BottomRight;
        text.textWrappingMode = TextWrappingModes.NoWrap;
        text.enableAutoSizing = false;
        text.raycastTarget = false;
        var rect = text.rectTransform;
        rect.anchorMin = rect.anchorMax = Vector2.right;
        rect.pivot = Vector2.right;
        rect.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, 650);
        rect.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, 100);
    }

    private static string ModVersion()
    {
        foreach (Assembly assembly in AppDomain.CurrentDomain.GetAssemblies())
        {
            if (!string.Equals(assembly.GetName().Name, "SupremeCommanderOverhaul-CachePatcher", StringComparison.OrdinalIgnoreCase)) continue;
            // The release label can use three parts while the CLR identity uses four.
            var release = Attribute.GetCustomAttribute(assembly, typeof(AssemblyInformationalVersionAttribute)) as AssemblyInformationalVersionAttribute;
            if (!string.IsNullOrEmpty(release?.InformationalVersion)) return release.InformationalVersion;
            return assembly.GetName().Version.ToString();
        }
        return "unknown";
    }
}
