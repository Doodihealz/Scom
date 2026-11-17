using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using BepInEx.Configuration;
using EM.UI;
using EM.Network;
using HarmonyLib;
using Michsky.UI.Beam;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using Object = UnityEngine.Object;

namespace SupComStyleUI;

internal static class LobbyEnhancements
{
    private static LobbyPreferences preferences;
    private static UnitCatalog catalog;
    private static Action<string> log;
    private static readonly List<LobbySurface> surfaces = new List<LobbySurface>();
    private static string unitsPath;
    private static string catalogError;

    public static void Install(Harmony harmony, ConfigFile config, Action<string> warning)
    {
        log = warning;
        preferences = new LobbyPreferences(config);
        unitsPath = Path.Combine(BepInEx.Paths.GameRootPath, "SanctuaryMods", "SCOM", "units");
        // The catalog is only needed when opening Unit Manager. Keep default-off
        // UI startup free of a separate scan of all editable unit templates.
        BuildRestrictionBackend.Install(harmony, warning);
        LobbyFactionLogos.Install(harmony, warning);
        foreach (var method in new[] { AccessTools.Method(typeof(LobbyInterface), "Start"), AccessTools.Method(typeof(LobbyInterface), "UpdateData"), AccessTools.Method(typeof(LobbySettingsInterface), "Start"), AccessTools.Method(typeof(LobbySettingsInterface), "UpdateMapList") })
        {
            if (method == null) throw new MissingMethodException("The installed game does not expose the lobby styling hooks.");
            harmony.Patch(method, postfix: new HarmonyMethod(typeof(LobbyEnhancements), nameof(Attach)));
        }
        var transition = AccessTools.Method(typeof(InterfaceManager), "TransitionTo", new[] { typeof(InterfaceManager.Window) });
        if (transition == null) throw new MissingMethodException("The native menu transition hook was not found.");
        harmony.Patch(transition, prefix: new HarmonyMethod(typeof(LobbyEnhancements), nameof(BeforeTransition)),
            postfix: new HarmonyMethod(typeof(LobbyEnhancements), nameof(AfterTransition)));
        if (LobbyInterface.Instance != null) Attach(LobbyInterface.Instance);
        if (LobbySettingsInterface.Instance != null) Attach(LobbySettingsInterface.Instance);
        ScomUiSettings.Install(harmony, preferences, RefreshSurfaces);
    }

    private static void BeforeTransition(InterfaceManager.Window newWindow, InterfaceManager.Window ___currentWindow, out bool __state)
    {
        __state = newWindow != ___currentWindow;
    }

    private static void AfterTransition(InterfaceManager.Window newWindow, bool __state)
    {
        // Native TransitionTo returns early for an already selected page. Those
        // calls must not resize an open setup window or restart a delayed refresh.
        if (!__state) return;
        MonoBehaviour owner = newWindow == InterfaceManager.Window.Lobby ? (MonoBehaviour)LobbyInterface.Instance :
            newWindow == InterfaceManager.Window.LobbySettings ? LobbySettingsInterface.Instance : null;
        if (owner == null) return;
        Attach(owner);
        owner.GetComponent<LobbySurface>()?.ApplyTheme(true);
    }

    private static void LoadCatalog()
    {
        try
        {
            var loaded = UnitCatalog.Load(unitsPath, preferences.CustomGroups.Value);
            BuildRestrictionBackend.ConfigureAllowedIds(loaded.Ids);
            catalog = loaded;
            catalogError = null;
        }
        catch (Exception ex)
        {
            catalogError = "Custom edits were not loaded: " + ex.Message;
            log(catalogError);
            if (catalog != null) return;
            try
            {
                catalog = UnitCatalog.Load(unitsPath, "");
                BuildRestrictionBackend.ConfigureAllowedIds(catalog.Ids);
            }
            catch (Exception baseError) { catalogError = "SCOM catalog unavailable: " + baseError.Message; log(catalogError); }
        }
    }

    private static void Attach(MonoBehaviour __instance)
    {
        if (__instance == null) return;
        if (ScomTerrainOption.IsEnabled && !ScomTerrainOption.IsLocalLobby) ScomTerrainOption.Reset();
        try
        {
            var surface = __instance.GetComponent<LobbySurface>();
            if (surface == null)
            {
                surface = __instance.gameObject.AddComponent<LobbySurface>();
                try
                {
                    surface.Initialize(preferences, Open);
                    surfaces.Add(surface);
                }
                catch { surface.Restore(); Object.Destroy(surface); throw; }
            }
            surface.ApplyTheme();
        }
        catch (Exception ex) { log("Lobby styling could not be applied: " + ex.Message); }
    }

    private static void Open(LobbySurface surface)
    {
        try
        {
            // Refresh the manager's editable catalog and saved local preferences
            // when opened. Native gameplay templates keep their startup lifecycle.
            preferences.Reload();
            LoadCatalog();
            RefreshSurfaces();
            if (catalog == null) { surface.ShowStatus(catalogError ?? "SCOM catalog unavailable."); return; }
            surface.OpenManager(catalog, catalogError);
        }
        catch (Exception ex) { surface.ShowStatus("Unit Manager could not refresh: " + ex.Message); log(ex.ToString()); }
    }

    private static void RefreshSurfaces()
    {
        surfaces.RemoveAll(surface => surface == null);
        foreach (var surface in surfaces) surface.ApplyTheme(true);
    }

    public static void Dispose()
    {
        ScomUiSettings.Dispose();
        LobbyFactionLogos.Dispose();
        foreach (var surface in surfaces) if (surface != null) { surface.Restore(); Object.Destroy(surface); }
        surfaces.Clear();
        catalog = null;
    }
}

internal sealed class LobbySurface : MonoBehaviour
{
    private LobbyPreferences preferences;
    private LobbyControls ui;
    private Action<LobbySurface> open;
    private RectTransform decoration;
    private RectTransform toolbar;
    private UnitManagerWindow window;
    private bool initialized;
    private ChamferPanelGraphic frame;
    private ClassicLobbyGraphic classicFrame;
    private ClassicLobbySkin nativeSkin;
    private ClassicLobbyLayout nativeLayout;
    private bool arrangingFooter;
    private readonly Vector3[] footerCorners = new Vector3[4];
    private static readonly System.Reflection.FieldInfo SettingsButton = AccessTools.Field(typeof(LobbyInterface), "settingsButton");
    private LayoutElement footerSizing;
    private bool ownsFooterSizing;
    private float originalFooterMinHeight, originalFooterPreferredHeight;
    private RectTransform footerLeft;
    private float originalFooterLeftHeight;
    private HorizontalLayoutGroup footerGroup;
    private TextAnchor originalFooterAlignment;

    public void Initialize(LobbyPreferences preferences, Action<LobbySurface> open)
    {
        this.preferences = preferences;
        this.open = open;
        nativeSkin = new ClassicLobbySkin(transform);
        CreateControls();
        nativeLayout = new ClassicLobbyLayout(transform);
        initialized = true;
        ApplyTheme();
    }

    private void CreateControls()
    {
        var header = transform.Find("Content/VerticalLayout/Top");
        var font = header != null ? header.GetComponentsInChildren<TMP_Text>(true).Select(t => t.font).FirstOrDefault(f => f != null) : null;
        font = font ?? GetComponentsInChildren<TMP_Text>(true).Select(t => t.font).FirstOrDefault(f => f != null) ?? TMP_Settings.defaultFontAsset;
        ui = new LobbyControls(preferences, font);
        var content = transform.Find("Content") ?? transform;
        decoration = LobbyControls.Rect("SupCom lobby frame", content, 0, 0, 0, 0);
        LobbyControls.Stretch(decoration, 8);
        // Place our frame behind the native layout, without modifying its graphics.
        decoration.SetSiblingIndex(content.Find("Background Shadow") != null ? 1 : 0);
        frame = ui.Panel(decoration);
        frame.BorderWidth = 1.5f;
        frame.Chamfer = 16;
        var metalFrame = LobbyControls.Rect("SCOM Classic Outer Frame", decoration, 0, 0, 0, 0);
        LobbyControls.Stretch(metalFrame);
        classicFrame = metalFrame.gameObject.AddComponent<ClassicLobbyGraphic>();
        classicFrame.Configure(ClassicLobbyGraphic.Surface.Frame);
        var footer = transform.Find("Content/VerticalLayout/Bottom/Left") as RectTransform;
        if (footer == null) throw new MissingMemberException("The native lobby footer was not found.");
        footerLeft = footer;
        originalFooterLeftHeight = footer.sizeDelta.y;
        footerGroup = footer.parent.GetComponent<HorizontalLayoutGroup>();
        if (footerGroup != null) originalFooterAlignment = footerGroup.childAlignment;
        footerSizing = footer.parent.GetComponent<LayoutElement>();
        ownsFooterSizing = footerSizing == null;
        if (ownsFooterSizing) footerSizing = footer.parent.gameObject.AddComponent<LayoutElement>();
        originalFooterMinHeight = footerSizing.minHeight;
        originalFooterPreferredHeight = footerSizing.preferredHeight;
        toolbar = LobbyControls.Rect("SupCom lobby tools", footer, 0, 0, 180, 50);
        toolbar.anchorMin = toolbar.anchorMax = toolbar.pivot = new Vector2(1, 0);
        toolbar.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
        // Inherit the native canvas so its page CanvasGroup also controls input.
        // An override-sorting child canvas bypasses that ancestor during raycast
        // filtering, allowing an invisible lobby toolbar to intercept settings.
        toolbar.SetAsLastSibling();
        var managerButton = ui.Button(toolbar, "Unit Manager", 0, 0, 180, 50, () => open(this));
        LobbyControls.Stretch((RectTransform)managerButton.transform);
        var managerLabel = managerButton.GetComponentInChildren<TextMeshProUGUI>();
        LobbyControls.Stretch(managerLabel.rectTransform);
        managerLabel.rectTransform.offsetMin = new Vector2(8, 0);
        managerLabel.rectTransform.offsetMax = new Vector2(-8, 0);
        managerLabel.fontSize = 20;
    }

    public void ApplyTheme(bool forceSkin = false)
    {
        if (!initialized) return;
        decoration.gameObject.SetActive(preferences.Enabled.Value);
        ui.StylePanel(frame);
        if (preferences.Enabled.Value)
        {
            frame.FillColor = Color.clear;
            frame.BorderColor = Color.clear;
        }
        if (classicFrame != null) classicFrame.gameObject.SetActive(preferences.Enabled.Value);
        foreach (var button in toolbar.GetComponentsInChildren<Button>(true)) ui.StyleButton(button);
        nativeLayout?.Apply(preferences.Enabled.Value, forceSkin);
        nativeSkin?.Apply(preferences.Enabled.Value, forceSkin);
        ArrangeFooter();
    }

    internal void ArrangeFooter()
    {
        if (!initialized || arrangingFooter || toolbar == null) return;
        var left = toolbar.parent as RectTransform;
        if (left == null) return;
        arrangingFooter = true;
        try
        {
            // Native fitters own translated button widths. Read their finished
            // rectangles instead of assuming an English Settings/Leave width.
            var nativeButtons = left.GetComponentsInChildren<ButtonManager>(true);
            foreach (var nativeButton in nativeButtons)
                LayoutRebuilder.ForceRebuildLayoutImmediate((RectTransform)nativeButton.transform);
            if (left.parent is RectTransform bottom) LayoutRebuilder.ForceRebuildLayoutImmediate(bottom);
            var lobby = GetComponent<LobbyInterface>();
            var settings = lobby != null ? SettingsButton?.GetValue(lobby) as ButtonManager : null;
            const float gap = 14;
            const float managerWidth = 180;
            var localUi = left.Find("SCOM UI Local Preferences") as RectTransform;
            float managerRight = left.rect.xMax;
            float managerHeight = 50;
            if (settings != null && settings.gameObject.activeSelf)
            {
                Rect bounds = FooterBounds((RectTransform)settings.transform, left);
                managerRight = bounds.xMin - gap;
                managerHeight = bounds.height;
            }
            float freeLeft = left.rect.xMin;
            foreach (var nativeButton in nativeButtons)
            {
                if (nativeButton == settings || !nativeButton.gameObject.activeSelf) continue;
                freeLeft = Mathf.Max(freeLeft, FooterBounds((RectTransform)nativeButton.transform, left).xMax + gap);
            }
            float freeRight = managerRight - managerWidth - gap;
            if (left.rect.width <= 0) return;
            float available = Mathf.Max(0, freeRight - freeLeft);
            // Narrow footers reserve an extra row instead of hiding switches or
            // squeezing the native Leave/Settings/Ready/Start actions together.
            int rows = localUi == null || available >= 290 * .8f ? 0 :
                left.rect.width >= managerWidth + gap + 290 * .8f ? 1 : 2;
            float requiredHeight = rows == 0 ? 64 : rows == 1 ? 128 : 192;
            bool resize = footerSizing != null &&
                (!Mathf.Approximately(footerSizing.minHeight, Mathf.Max(originalFooterMinHeight, requiredHeight)) ||
                 !Mathf.Approximately(footerSizing.preferredHeight, Mathf.Max(originalFooterPreferredHeight, requiredHeight)));
            if (footerSizing != null)
            {
                footerSizing.minHeight = Mathf.Max(originalFooterMinHeight, requiredHeight);
                footerSizing.preferredHeight = Mathf.Max(originalFooterPreferredHeight, requiredHeight);
            }
            if (nativeLayout != null && nativeLayout.SetFooterHeight(requiredHeight * .84f) && preferences.Enabled.Value)
                nativeLayout.Apply(true, true);
            if (resize && !preferences.Enabled.Value && left.parent.parent is RectTransform nativeLayoutRoot)
                LayoutRebuilder.ForceRebuildLayoutImmediate(nativeLayoutRoot);
            if (left.parent is RectTransform footer)
            {
                // Native children keep fixed heights. Let Left fill the reserved
                // footer while the original 50px Right actions stay at the bottom.
                if (footerGroup != null) footerGroup.childAlignment = TextAnchor.LowerLeft;
                left.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, footer.rect.height);
                LayoutRebuilder.ForceRebuildLayoutImmediate(footer);
            }

            toolbar.localScale = Vector3.one;
            toolbar.sizeDelta = new Vector2(managerWidth, managerHeight);
            toolbar.anchorMin = toolbar.anchorMax = toolbar.pivot = new Vector2(1, 0);
            toolbar.anchoredPosition = new Vector2(managerRight - left.rect.xMax, 0);
            if (settings != null && settings.gameObject.activeSelf)
                toolbar.anchoredPosition = new Vector2(managerRight - left.rect.xMax,
                    FooterBounds((RectTransform)settings.transform, left).yMin - left.rect.yMin);
            if (localUi == null) return;
            float scale = Mathf.Min(1, available / 290f);
            Vector2 preferenceCenter = new Vector2((freeLeft + freeRight) * .5f, left.rect.center.y);
            if (rows > 0)
            {
                toolbar.anchorMin = toolbar.anchorMax = toolbar.pivot = Vector2.zero;
                toolbar.anchoredPosition = new Vector2(0, 64 + (rows == 1 ? 7 : 0));
                if (rows == 1)
                {
                    scale = Mathf.Min(1, (left.rect.width - managerWidth - gap) / 290f);
                    preferenceCenter = new Vector2(left.rect.xMin + (managerWidth + gap + left.rect.width) * .5f,
                        left.rect.yMin + 64 + 32);
                }
                else
                {
                    scale = Mathf.Min(1, left.rect.width / 290f);
                    preferenceCenter = new Vector2(left.rect.center.x, left.rect.yMin + 128 + 32);
                }
            }
            localUi.anchorMin = localUi.anchorMax = localUi.pivot = new Vector2(.5f, .5f);
            localUi.anchoredPosition = preferenceCenter - left.rect.center;
            localUi.localScale = new Vector3(scale, scale, 1);
        }
        finally { arrangingFooter = false; }
    }

    private Rect FooterBounds(RectTransform control, RectTransform parent)
    {
        control.GetWorldCorners(footerCorners);
        Vector2 min = parent.InverseTransformPoint(footerCorners[0]);
        Vector2 max = min;
        for (int i = 1; i < footerCorners.Length; i++)
        {
            Vector2 point = parent.InverseTransformPoint(footerCorners[i]);
            min = Vector2.Min(min, point);
            max = Vector2.Max(max, point);
        }
        return Rect.MinMaxRect(min.x, min.y, max.x, max.y);
    }

    public void OpenManager(UnitCatalog catalog, string warning)
    {
        CloseManager();
        // The last native-canvas sibling draws above the toolbar and blocks the
        // lobby beneath it while retaining the owning page's visibility/input gate.
        var selection = EventSystem.current != null ? EventSystem.current.currentSelectedGameObject : null;
        try
        {
            modalLayer = LobbyControls.Rect("SupCom modal layer", transform, 0, 0, 0, 0);
            LobbyControls.Stretch(modalLayer);
            modalLayer.SetAsLastSibling();
            window = new UnitManagerWindow(modalLayer, ui, catalog, CloseManager);
            if (warning != null) window.ShowStatus(warning);
        }
        catch (Exception ex)
        {
            CloseManager();
            if (EventSystem.current != null) EventSystem.current.SetSelectedGameObject(selection != null && selection.activeInHierarchy ? selection : null);
            ShowStatus("Unit Manager could not open: " + ex.Message);
            Debug.LogException(ex);
        }
    }

    private RectTransform modalLayer;
    private void CloseManager()
    {
        var closing = window;
        window = null;
        try { closing?.Dispose(); }
        finally
        {
            if (modalLayer != null) { modalLayer.gameObject.SetActive(false); Object.Destroy(modalLayer.gameObject); modalLayer = null; }
        }
    }

    public void ShowStatus(string message)
    {
        if (string.IsNullOrWhiteSpace(message)) return;
        if (InterfaceManager.Instance != null) InterfaceManager.Instance.ShowMessageModalWindow("Unit Manager", message);
        else Debug.LogWarning("[SCOM UI] " + message);
    }
    private void OnRectTransformDimensionsChange()
    {
        if (initialized) { nativeLayout?.Apply(preferences.Enabled.Value); ArrangeFooter(); }
        window?.Resize();
    }
    private void Update()
    {
        if (window != null && (LobbyManager.isLocked || (LobbyManager.IsInLobby && LobbyManager.lobbyGameStatus != LobbyManager.LobbyGameStatus.lobby) || !window.AuthorityUnchanged))
            CloseManager();
    }
    private void OnDisable() { CloseManager(); }
    private void OnDestroy() { Restore(); }
    private void OnEnable() { if (initialized) ApplyTheme(); }

    public void Restore()
    {
        CloseManager();
        nativeLayout?.Dispose();
        nativeLayout = null;
        if (footerGroup != null) { footerGroup.childAlignment = originalFooterAlignment; footerGroup = null; }
        if (footerLeft != null)
        {
            footerLeft.sizeDelta = new Vector2(footerLeft.sizeDelta.x, originalFooterLeftHeight);
            footerLeft = null;
        }
        if (footerSizing != null)
        {
            if (ownsFooterSizing) Object.Destroy(footerSizing);
            else { footerSizing.minHeight = originalFooterMinHeight; footerSizing.preferredHeight = originalFooterPreferredHeight; }
            footerSizing = null;
        }
        nativeSkin?.Dispose();
        nativeSkin = null;
        initialized = false;
        if (decoration != null) { decoration.gameObject.SetActive(false); Object.Destroy(decoration.gameObject); decoration = null; }
        if (toolbar != null) { toolbar.gameObject.SetActive(false); Object.Destroy(toolbar.gameObject); toolbar = null; }
    }
}
