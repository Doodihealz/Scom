using System;
using BepInEx;
using BepInEx.Configuration;
using EM.UI;
using HarmonyLib;
using UnityEngine;
using UnityEngine.UI;
using Object = UnityEngine.Object;

namespace SupComStyleUI;

// A transparent child covers the native Sanctuary symbol and shares the saved
// SCOM front-end preference without changing the native icon or its behavior.
internal static class MainMenuUiToggle
{
    private const string IconPath = "Content/Game Icon";
    private static ConfigFile config;
    private static ConfigEntry<bool> enabled;
    private static Action<string> warning;
    private static Transform icon;
    private static GameObject control;
    private static bool installed;

    public static void Install(Harmony harmony, MonoBehaviour owner, Action<string> warn)
    {
        if (installed) return;
        var plugin = owner as BaseUnityPlugin;
        if (plugin == null) throw new ArgumentException("SCOM's menu toggle requires its plugin configuration.", nameof(owner));
        config = plugin.Config;
        enabled = LobbyPreferences.BindLobbyEnabled(config);
        warning = warn;
        installed = true;

        var start = AccessTools.Method(typeof(SideBarInterface), "Start");
        var callback = AccessTools.Method(typeof(MainMenuUiToggle), nameof(AfterSidebarStart));
        bool patched = false;
        var info = Harmony.GetPatchInfo(start);
        if (info != null)
            foreach (Patch patch in info.Postfixes)
                if (patch.owner == harmony.Id && patch.PatchMethod == callback) { patched = true; break; }
        if (!patched) harmony.Patch(start, postfix: new HarmonyMethod(callback));
        Ensure();
    }

    private static void AfterSidebarStart() => Ensure();

    public static void Ensure()
    {
        if (!installed || SideBarInterface.Instance == null) return;
        var reportBug = SideBarInterface.Instance.transform.Find("Content/ReportBugButton");
        if (reportBug != null) reportBug.gameObject.SetActive(false);
        var nativeIcon = SideBarInterface.Instance.transform.Find(IconPath) as RectTransform;
        if (nativeIcon == null || nativeIcon.GetComponent<Image>() == null) return;
        if (icon == nativeIcon && control != null) return;
        RemoveControl();
        icon = nativeIcon;
        var rect = LobbyControls.Rect("SCOM Main Menu UI Toggle", nativeIcon, 0, 0, 0, 0);
        rect.gameObject.layer = nativeIcon.gameObject.layer;
        LobbyControls.Stretch(rect);
        rect.SetAsLastSibling();
        rect.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
        var image = rect.gameObject.AddComponent<Image>();
        image.color = Color.clear;
        image.raycastTarget = true;
        var button = rect.gameObject.AddComponent<Button>();
        button.targetGraphic = image;
        button.transition = Selectable.Transition.None;
        button.navigation = new Navigation { mode = Navigation.Mode.None };
        button.onClick.AddListener(Toggle);
        control = rect.gameObject;
    }

    private static void Toggle()
    {
        if (!installed || enabled == null || config == null) return;
        bool previous = enabled.Value;
        try
        {
            enabled.Value = !previous;
            config.Save();
        }
        catch (Exception error)
        {
            // The same setting listeners reverse any already-applied appearance
            // when a failed disk save returns the live entry to its old value.
            try { enabled.Value = previous; }
            catch (Exception rollbackError)
            {
                warning?.Invoke("SCOM UI choice could not be saved or restored: " + error.Message + "; " + rollbackError.Message);
                return;
            }
            warning?.Invoke("SCOM UI choice could not be saved; its previous value was restored. " + error.Message);
        }
    }

    private static void RemoveControl()
    {
        if (control != null)
        {
            control.SetActive(false);
            control.transform.SetParent(null, false);
            Object.Destroy(control);
            control = null;
        }
        icon = null;
    }

    public static void Dispose()
    {
        installed = false;
        RemoveControl();
        enabled = null;
        config = null;
        warning = null;
    }
}
