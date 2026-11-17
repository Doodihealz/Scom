using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using BepInEx;
using BepInEx.Configuration;
using EM.UI;
using HarmonyLib;
using Michsky.UI.Beam;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using Object = UnityEngine.Object;

namespace SupComStyleUI;

// The saved SCOM UI switch controls menu/lobby/loading presentation together.
// Theme assets are cloned for our controls; the shared Beam asset and separate
// in-game HUD preference are never modified. The small logo subtitle is owned
// by the original branding runtime and is deliberately left intact.
internal static class MainMenuStyle
{
    private sealed class ImageState
    {
        public Image Image;
        public Color Color;
        public UIManagerImage Manager;
        public UIManager Theme;
        public bool CustomColor;
    }
    private sealed class TextState
    {
        public TMP_Text Text;
        public Color Color;
        public UIManagerText Manager;
        public UIManager Theme;
        public bool CustomColor;
    }
    private static readonly Dictionary<int, ImageState> images = new Dictionary<int, ImageState>();
    private static readonly Dictionary<int, TextState> texts = new Dictionary<int, TextState>();
    private static readonly Dictionary<UnityEngine.UI.Text, Color> legacyTexts = new Dictionary<UnityEngine.UI.Text, Color>();
    private static readonly Dictionary<Button, Graphic> buttonTargets = new Dictionary<Button, Graphic>();
    private static readonly Dictionary<int, UIManager> themes = new Dictionary<int, UIManager>();
    private static readonly Dictionary<int, UIManager> themeSources = new Dictionary<int, UIManager>();
    private static readonly HashSet<int> scannedRoots = new HashSet<int>();
    private static readonly List<Transform> menuRoots = new List<Transform>();
    private static readonly Dictionary<SocialsWidget.Item, Color> socialTints = new Dictionary<SocialsWidget.Item, Color>();
    private static readonly List<GameObject> decoration = new List<GameObject>();
    private static readonly List<ClassicLobbyGraphic> sharedButtonPlates = new List<ClassicLobbyGraphic>();
    private static readonly List<Graphic> sharedButtonForegrounds = new List<Graphic>();
    private static readonly FieldInfo WindowsList = AccessTools.Field(typeof(InterfaceManager), "windowsList");
    private static readonly FieldInfo ModalsList = AccessTools.Field(typeof(InterfaceManager), "modalsList");
    private static readonly FieldInfo CurrentWindow = AccessTools.Field(typeof(InterfaceManager), "currentWindow");
    private static readonly FieldInfo ReturnWindow = AccessTools.Field(typeof(InterfaceManager), "returnWindow");
    private static readonly FieldInfo ManagedImage = AccessTools.Field(typeof(UIManagerImage), "objImage");
    private static readonly FieldInfo ManagedText = AccessTools.Field(typeof(UIManagerText), "objText");
    private static readonly MethodInfo UpdateImage = AccessTools.Method(typeof(UIManagerImage), "UpdateImage");
    private static readonly MethodInfo UpdateText = AccessTools.Method(typeof(UIManagerText), "UpdateText");
    private static readonly Color Gold = new Color32(235, 211, 143, 255);
    private static readonly Color White = new Color32(247, 246, 240, 255);
    private static readonly Color WarmMuted = new Color32(192, 180, 145, 255);
    private static readonly Color Dark = new Color32(25, 24, 20, 255);
    private static Action<string> warning;
    private static Coroutine initialApply;
    private static Coroutine artworkFade;
    private static Coroutine mainSlideshow;
    private static Coroutine backgroundTransition;
    private static MonoBehaviour host;
    private static ConfigEntry<bool> enabled;
    private static ConfigFile configuration;
    private static MainMenuBackgroundPreferences backgroundPreferences;
    private static MainMenuBackgroundSelector backgroundSelector;
    private static MainMenuBackground appliedBackground;
    private static bool backgroundChoicePending;
    private static GameObject backdrop;
    private static GameObject loadingShade;
    private static Texture2D backgroundTexture;
    private static Texture2D battleshipTexture;
    private static Texture2D cityTexture;
    private static Texture2D lobbyTexture;
    private static readonly ScomMenuBackdrop[] mainPictures = new ScomMenuBackdrop[MainMenuBackgroundPlayback.SlideCount];
    private static ScomMenuBackdrop lobbyPicture;
    private static bool mainSlideshowEligible;
    private static bool loadingBackgroundEligible;
    private static float mainSlideshowPhase;
    private static float lobbyBlend;
    private static float artworkTarget;
    private const float ArtworkFadeSeconds = 1f;
    private static bool installed;
    private static bool failed;
    private static Transform sharedModalsRoot;
    private static bool sharedBlackButtons = true;

    public static void Install(Harmony harmony, MonoBehaviour owner, Action<string> warn)
    {
        if (installed) return;
        installed = true;
        failed = false;
        warning = warn;
        host = owner;
        var plugin = owner as BaseUnityPlugin;
        if (plugin == null) throw new ArgumentException("SCOM menu appearance requires its plugin configuration.", nameof(owner));
        enabled = LobbyPreferences.BindLobbyEnabled(plugin.Config);
        configuration = plugin.Config;
        backgroundPreferences = new MainMenuBackgroundPreferences(configuration);
        backgroundPreferences.Changed += OnBackgroundPreferenceChanged;
        backgroundChoicePending = true;
        MainMenuBranding.Install(harmony);
        MainMenuUiToggle.Install(harmony, owner, warn);
        harmony.Patch(AccessTools.Method(typeof(InterfaceManager), "TransitionTo"), postfix: new HarmonyMethod(typeof(MainMenuStyle), nameof(OnTransition)));
        harmony.Patch(AccessTools.Method(typeof(UIManagerImage), "Awake"), postfix: new HarmonyMethod(typeof(MainMenuStyle), nameof(OnImageAwake)));
        harmony.Patch(AccessTools.Method(typeof(UIManagerText), "Awake"), postfix: new HarmonyMethod(typeof(MainMenuStyle), nameof(OnTextAwake)));
        harmony.Patch(AccessTools.Method(typeof(AISettingsInterface), "Start"), postfix: new HarmonyMethod(typeof(MainMenuStyle), nameof(OnAISettingsUpdated)));
        harmony.Patch(AccessTools.Method(typeof(AISettingsInterface), "UpdateData"), postfix: new HarmonyMethod(typeof(MainMenuStyle), nameof(OnAISettingsUpdated)));
        // Beam instantiates dropdown entries and selector indicators before
        // parenting them. Their Awake callbacks cannot identify the menu yet.
        harmony.Patch(AccessTools.Method(typeof(Michsky.UI.Beam.Dropdown), "Initialize"), postfix: new HarmonyMethod(typeof(MainMenuStyle), nameof(OnMenuOptionsCreated)));
        harmony.Patch(AccessTools.Method(typeof(HorizontalSelector), "UpdateIndicators"), postfix: new HarmonyMethod(typeof(MainMenuStyle), nameof(OnMenuOptionsCreated)));
        enabled.SettingChanged += OnPreferenceChanged;
        // Installation occurs inside native Start. Its remaining instructions
        // initialize the windows before this one deferred pass runs.
        initialApply = owner.StartCoroutine(ApplyAfterNativeStartup());
    }

    private static IEnumerator ApplyAfterNativeStartup()
    {
        yield return null;
        initialApply = null;
        MainMenuBranding.Ensure(HomeInterface.Instance);
        MainMenuUiToggle.Ensure();
        Refresh(InterfaceManager.Instance);
    }

    private static void OnTransition(InterfaceManager __instance, InterfaceManager.Window newWindow)
    {
        Refresh(__instance, newWindow);
    }

    private static void OnPreferenceChanged(object sender, EventArgs args)
    {
        if (!installed || enabled == null) return;
        if (!enabled.Value)
        {
            Restore();
            return;
        }
        failed = false;
        Refresh(InterfaceManager.Instance);
    }

    private static void OnBackgroundPreferenceChanged()
    {
        if (!installed) return;
        backgroundChoicePending = true;
        CancelMainSlideshow();
        try { RefreshMainSlideshow(); }
        catch (Exception error) { Fail(error); }
    }

    private static void Refresh(InterfaceManager manager, InterfaceManager.Window? requestedWindow = null)
    {
        if (!installed || enabled == null || !enabled.Value || failed || manager == null) return;
        try
        {
            var window = requestedWindow ?? (InterfaceManager.Window)CurrentWindow.GetValue(manager);
            sharedBlackButtons = UsesFrontEndButtons(manager, window);
            MainMenuBranding.SetLayout(true);
            FindMenuRoots(manager);
            foreach (Transform root in menuRoots)
            {
                if (root == null || !scannedRoots.Add(root.GetInstanceID())) continue;
                StyleRoot(root);
            }
            RefreshSharedButtonPalette();
            EnsureBackdrop(manager);
            if (backgroundSelector == null)
                backgroundSelector = new MainMenuBackgroundSelector(configuration, backgroundPreferences, warning);
            SetArtwork(window);
            if (loadingShade != null) loadingShade.SetActive(window == InterfaceManager.Window.GameLoading);
        }
        catch (Exception error) { Fail(error); }
    }

    private static void StyleRoot(Transform root)
    {
        foreach (Image image in root.GetComponentsInChildren<Image>(true)) Style(image);
        foreach (TMP_Text text in root.GetComponentsInChildren<TMP_Text>(true)) Style(text);
        foreach (UnityEngine.UI.Text text in root.GetComponentsInChildren<UnityEngine.UI.Text>(true))
        {
            if (legacyTexts.ContainsKey(text)) continue;
            legacyTexts[text] = text.color;
            if (HasGoldButtonBackground(text.transform)) StyleButtonForeground(text);
            else text.color = new Color(White.r, White.g, White.b, text.color.a);
        }
        foreach (SocialsWidget widget in root.GetComponentsInChildren<SocialsWidget>(true))
            foreach (SocialsWidget.Item item in widget.socials)
            {
                if (item == null || socialTints.ContainsKey(item)) continue;
                socialTints[item] = item.backgroundTint;
                item.backgroundTint = new Color(Dark.r, Dark.g, Dark.b, .93f);
            }
    }

    private static void OnAISettingsUpdated(AISettingsInterface __instance)
    {
        if (!installed || enabled == null || !enabled.Value || failed || __instance == null) return;
        try
        {
            Transform root = __instance.transform;
            if (!menuRoots.Contains(root)) menuRoots.Add(root);
            // UpdateData rebuilds the AI implementation dropdown each time a
            // slot is opened, even if this window was already styled earlier.
            StyleRoot(root);
            scannedRoots.Add(root.GetInstanceID());
        }
        catch (Exception error) { Fail(error); }
    }

    private static void OnMenuOptionsCreated(MonoBehaviour __instance)
    {
        if (!installed || enabled == null || !enabled.Value || failed || __instance == null) return;
        ClassicLobbySkin.RefreshGenerated(__instance.transform);
        var ai = __instance.GetComponentInParent<AISettingsInterface>();
        if (ai != null && !menuRoots.Contains(ai.transform)) menuRoots.Add(ai.transform);
        if (!IsMenu(__instance.transform)) return;
        try { StyleRoot(__instance.transform); }
        catch (Exception error) { Fail(error); }
    }

    private static bool HasArtwork(InterfaceManager.Window window)
        => window == InterfaceManager.Window.Home || window == InterfaceManager.Window.Play ||
           window == InterfaceManager.Window.Replays || window == InterfaceManager.Window.Settings ||
           window == InterfaceManager.Window.TCPMultiplayer || window == InterfaceManager.Window.LobbyList ||
           window == InterfaceManager.Window.Background || window == InterfaceManager.Window.Lobby ||
           window == InterfaceManager.Window.LobbySettings || window == InterfaceManager.Window.AISettings ||
           window == InterfaceManager.Window.GameLoading;

    private static bool HasLobbyArtwork(InterfaceManager.Window window)
        => window == InterfaceManager.Window.LobbyList || window == InterfaceManager.Window.Lobby ||
           window == InterfaceManager.Window.LobbySettings || window == InterfaceManager.Window.AISettings;

    private static bool HasMainSlideshow(InterfaceManager.Window window)
        => window == InterfaceManager.Window.Home || window == InterfaceManager.Window.Play ||
           window == InterfaceManager.Window.TCPMultiplayer || window == InterfaceManager.Window.Replays ||
           window == InterfaceManager.Window.Background ||
           window == InterfaceManager.Window.Settings && sharedBlackButtons;

    private static void SetArtwork(InterfaceManager.Window window)
    {
        if (backdrop == null || lobbyPicture == null) return;
        mainSlideshowEligible = HasMainSlideshow(window);
        loadingBackgroundEligible = window == InterfaceManager.Window.GameLoading;
        if (!mainSlideshowEligible) CancelMainSlideshow();
        // Loading keeps the selected or frozen main-menu composite. Lobby
        // fades still reveal that frozen frame beneath the fixed lobby image.
        for (int index = 1; index < mainPictures.Length; index++)
            if (mainPictures[index] != null) mainPictures[index].enabled = mainSlideshowEligible || loadingBackgroundEligible || HasLobbyArtwork(window);
        if (!HasArtwork(window))
        {
            CancelArtworkFade();
            if (backgroundTransition != null) backgroundChoicePending = true;
            CancelBackgroundTransition();
            artworkTarget = 0;
            SetLobbyBlend(0);
            backdrop.SetActive(false);
            backgroundSelector?.SetVisible(null, false);
            return;
        }
        backdrop.SetActive(true);
        float target = HasLobbyArtwork(window) ? 1 : 0;
        if (target > 0 && lobbyPicture.texture == null)
        {
            lobbyPicture.texture = LobbyTexture();
            lobbyPicture.FitCover();
        }
        // Consecutive lobby windows share one target. A reversal starts from the
        // alpha already on screen rather than jumping to either full wallpaper.
        if (artworkTarget == target && (artworkFade != null || Mathf.Approximately(lobbyBlend, target)))
        {
            RefreshMainSlideshow();
            return;
        }
        CancelArtworkFade();
        artworkTarget = target;
        if (host == null || !backdrop.activeInHierarchy || Mathf.Approximately(lobbyBlend, target))
        {
            SetLobbyBlend(target);
            RefreshMainSlideshow();
            return;
        }
        artworkFade = host.StartCoroutine(FadeArtwork(target));
        RefreshMainSlideshow();
    }

    private static IEnumerator FadeArtwork(float target)
    {
        float from = lobbyBlend;
        float duration = ArtworkFadeSeconds * Mathf.Abs(target - from);
        float elapsed = 0;
        while (installed && enabled != null && enabled.Value && backdrop != null && lobbyPicture != null && elapsed < duration)
        {
            // Hold the displayed image for this frame. A busy menu-entry frame
            // must not consume the entire transition before either image renders.
            yield return null;
            elapsed = Mathf.Min(duration, elapsed + Mathf.Min(Time.unscaledDeltaTime, .05f));
            float progress = duration > 0 ? elapsed / duration : 1;
            float blend = progress * progress * (3 - 2 * progress);
            SetLobbyBlend(Mathf.Lerp(from, target, blend));
        }
        if (installed && enabled != null && enabled.Value && artworkTarget == target) SetLobbyBlend(target);
        artworkFade = null;
        RefreshMainSlideshow();
    }

    private static void SetLobbyBlend(float alpha)
    {
        lobbyBlend = Mathf.Clamp01(alpha);
        if (lobbyPicture != null) lobbyPicture.color = new Color(1, 1, 1, lobbyBlend);
    }

    private static void CancelArtworkFade()
    {
        if (host != null && artworkFade != null) host.StopCoroutine(artworkFade);
        artworkFade = null;
    }

    private static bool CanDisplayMainBackground()
        => installed && enabled != null && enabled.Value && host != null && mainSlideshowEligible &&
           backdrop != null && backdrop.activeInHierarchy && mainPictures[mainPictures.Length - 1] != null &&
           artworkFade == null && artworkTarget == 0 && lobbyBlend == 0;

    private static bool CanDisplayLoadingBackground()
        => installed && enabled != null && enabled.Value && loadingBackgroundEligible && backdrop != null && backdrop.activeInHierarchy;

    private static bool CanRunMainSlideshow()
        => CanDisplayMainBackground() && backgroundPreferences != null &&
           backgroundPreferences.Choice == MainMenuBackground.Slideshow && backgroundTransition == null;

    private static void RefreshMainSlideshow()
    {
        // Retain the displayed main-menu composite throughout both lobby fades.
        // A return resumes its exact phase only after the lobby layer is gone.
        bool mainVisible = CanDisplayMainBackground();
        var manager = InterfaceManager.Instance;
        backgroundSelector?.SetVisible(manager != null ? WindowsList.GetValue(manager) as GameObject : null, mainVisible);
        if (!mainVisible)
        {
            CancelMainSlideshow();
            if (CanDisplayLoadingBackground())
            {
                // Keep any visible selection fade running. Only an opaque
                // lobby image can conceal an immediate underlay update.
                if (backgroundChoicePending)
                    ApplyBackgroundChoice(!Mathf.Approximately(lobbyBlend, 1));
                return;
            }
            if (backgroundTransition != null)
            {
                backgroundChoicePending = true;
                CancelBackgroundTransition();
            }
            return;
        }
        if (backgroundChoicePending) ApplyBackgroundChoice(true);
        if (!CanRunMainSlideshow()) { CancelMainSlideshow(); return; }
        if (mainSlideshow == null) mainSlideshow = host.StartCoroutine(AdvanceMainSlideshow());
    }

    private static void ApplyBackgroundChoice(bool animate)
    {
        var choice = backgroundPreferences.Choice;
        int slideshowSlide = 0;
        float slideshowBlend = 0;
        if (choice == MainMenuBackground.Slideshow)
        {
            // Resume a static photo with its complete hold before advancing.
            if (appliedBackground != MainMenuBackground.Slideshow)
                mainSlideshowPhase = MainMenuBackgroundPlayback.StaticSlide(appliedBackground) * MainMenuBackgroundPlayback.LegSeconds;
            GetMainSlideshowBlend(out slideshowSlide, out slideshowBlend);
        }
        else
        {
            slideshowSlide = MainMenuBackgroundPlayback.StaticSlide(choice);
        }
        CancelBackgroundTransition();
        if (animate && (CanDisplayMainBackground() || CanDisplayLoadingBackground()))
            backgroundTransition = host.StartCoroutine(TransitionBackground(choice, slideshowSlide, slideshowBlend));
        else
            SetBackgroundBlend(choice, slideshowSlide, slideshowBlend);
        appliedBackground = choice;
        backgroundChoicePending = false;
    }

    private static IEnumerator TransitionBackground(MainMenuBackground choice, int slideshowSlide, float slideshowBlend)
    {
        var from = new float[MainMenuBackgroundPlayback.SlideCount];
        var target = new float[MainMenuBackgroundPlayback.SlideCount];
        var weights = new float[MainMenuBackgroundPlayback.SlideCount];
        MainMenuBackgroundPlayback.VisibleWeights(mainPictures[1].color.a, mainPictures[2].color.a, from);
        float targetBattleship = MainMenuBackgroundPlayback.TargetAlpha(1, choice, slideshowSlide, slideshowBlend);
        float targetCity = MainMenuBackgroundPlayback.TargetAlpha(2, choice, slideshowSlide, slideshowBlend);
        MainMenuBackgroundPlayback.VisibleWeights(targetBattleship, targetCity, target);
        float elapsed = 0;
        while (installed && enabled != null && enabled.Value && backdrop != null && backdrop.activeInHierarchy && elapsed < MainMenuBackgroundPlayback.FadeSeconds)
        {
            yield return null;
            elapsed = Mathf.Min(MainMenuBackgroundPlayback.FadeSeconds, elapsed + Mathf.Min(Time.unscaledDeltaTime, .05f));
            float progress = elapsed / MainMenuBackgroundPlayback.FadeSeconds;
            float blend = progress * progress * (3 - 2 * progress);
            for (int index = 0; index < weights.Length; index++)
                weights[index] = Mathf.Lerp(from[index], target[index], blend);
            MainMenuBackgroundPlayback.LayerAlphas(weights, out float battleshipAlpha, out float cityAlpha);
            mainPictures[1].color = new Color(1, 1, 1, battleshipAlpha);
            mainPictures[2].color = new Color(1, 1, 1, cityAlpha);
        }
        if (installed && enabled != null && enabled.Value) SetBackgroundBlend(choice, slideshowSlide, slideshowBlend);
        backgroundTransition = null;
        RefreshMainSlideshow();
    }

    private static void SetBackgroundBlend(MainMenuBackground choice, int slideshowSlide, float slideshowBlend)
    {
        for (int index = 0; index < mainPictures.Length; index++)
        {
            float alpha = MainMenuBackgroundPlayback.TargetAlpha(index, choice, slideshowSlide, slideshowBlend);
            mainPictures[index].color = new Color(1, 1, 1, alpha);
        }
    }

    private static void CancelBackgroundTransition()
    {
        if (host != null && backgroundTransition != null) host.StopCoroutine(backgroundTransition);
        backgroundTransition = null;
    }

    private static IEnumerator AdvanceMainSlideshow()
    {
        float leg = MainMenuBackgroundPlayback.LegSeconds;
        while (CanRunMainSlideshow())
        {
            yield return null;
            if (!CanRunMainSlideshow()) break;
            int slide = Mathf.FloorToInt(mainSlideshowPhase / leg);
            float currentPhase = mainSlideshowPhase - slide * leg;
            // Count the hold in real time, but never let a busy frame skip the
            // soft transition. Use the lobby fade's bounded step while fading.
            float hold = MainMenuBackgroundPlayback.HoldSeconds;
            float remaining = currentPhase < hold ? hold - currentPhase : leg - currentPhase;
            float step = currentPhase < hold ? Time.unscaledDeltaTime : Mathf.Min(Time.unscaledDeltaTime, .05f);
            mainSlideshowPhase = Mathf.Repeat(mainSlideshowPhase + Mathf.Min(step, remaining), leg * mainPictures.Length);
            SetMainSlideshowBlend();
        }
        mainSlideshow = null;
    }

    private static void SetMainSlideshowBlend()
    {
        GetMainSlideshowBlend(out int slide, out float blend);
        for (int index = 0; index < mainPictures.Length; index++)
            mainPictures[index].color = new Color(1, 1, 1, MainMenuBackgroundPlayback.Alpha(index, slide, blend));
    }

    private static void GetMainSlideshowBlend(out int slide, out float blend)
    {
        float leg = MainMenuBackgroundPlayback.LegSeconds;
        slide = Mathf.FloorToInt(mainSlideshowPhase / leg);
        float phase = mainSlideshowPhase - slide * leg;
        float progress = Mathf.Clamp01((phase - MainMenuBackgroundPlayback.HoldSeconds) / MainMenuBackgroundPlayback.FadeSeconds);
        blend = progress * progress * (3 - 2 * progress);
    }

    private static void CancelMainSlideshow()
    {
        if (host != null && mainSlideshow != null) host.StopCoroutine(mainSlideshow);
        mainSlideshow = null;
    }

    private static void FindMenuRoots(InterfaceManager manager)
    {
        var windows = WindowsList.GetValue(manager) as GameObject;
        if (windows != null)
        {
            foreach (Transform child in windows.transform)
            {
                bool allowed = false;
                foreach (MonoBehaviour component in child.GetComponents<MonoBehaviour>())
                {
                    if (component == null) continue;
                    string type = component.GetType().Name;
                    if (type == "HomeInterface" || type == "PlayInterface" || type == "TCPConnectionInterface" ||
                        type == "ReplayListInterface" || type == "SettingsInterface" || type == "LobbyListInterface" ||
                        type == "GameLoadingInterface" || type == "AISettingsInterface")
                    { allowed = true; break; }
                }
                if (allowed && !menuRoots.Contains(child)) menuRoots.Add(child);
            }
        }
        if (HomeInterface.Instance != null && !menuRoots.Contains(HomeInterface.Instance.transform)) menuRoots.Add(HomeInterface.Instance.transform);
        if (AISettingsInterface.Instance != null && !menuRoots.Contains(AISettingsInterface.Instance.transform)) menuRoots.Add(AISettingsInterface.Instance.transform);
        if (SideBarInterface.Instance != null && !menuRoots.Contains(SideBarInterface.Instance.transform)) menuRoots.Add(SideBarInterface.Instance.transform);
        // Shared confirmations retain their native messages, actions, and error
        // semantics, but use the fixed SCOM branding on their buttons as well.
        var modals = ModalsList.GetValue(manager) as GameObject;
        sharedModalsRoot = modals != null ? modals.transform : null;
        if (modals != null && !menuRoots.Contains(modals.transform)) menuRoots.Add(modals.transform);
    }

    private static bool UsesFrontEndButtons(InterfaceManager manager, InterfaceManager.Window window)
    {
        if (window == InterfaceManager.Window.None || window == InterfaceManager.Window.InGameMenu) return false;
        // Settings and modal objects are shared with gameplay. Native Settings
        // records its caller, so opening it from the pause menu keeps the prior
        // gold faces and dark foregrounds rather than the new front-end palette.
        return window != InterfaceManager.Window.Settings || ReturnWindow != null &&
            (InterfaceManager.Window)ReturnWindow.GetValue(manager) != InterfaceManager.Window.InGameMenu;
    }

    private static bool IsSharedControl(Transform item)
        => item != null && (item.GetComponentInParent<SanctuaryUI.SettingsInterface>(true) != null ||
            sharedModalsRoot != null && (item == sharedModalsRoot || item.IsChildOf(sharedModalsRoot)));

    private static void StyleButtonForeground(Graphic foreground)
    {
        bool shared = IsSharedControl(foreground.transform);
        if (shared) sharedButtonForegrounds.Add(foreground);
        SetButtonForeground(foreground, !shared || sharedBlackButtons ? Gold : Dark);
    }

    private static void SetButtonForeground(Graphic foreground, Color tint)
    {
        Color color = new Color(tint.r, tint.g, tint.b, foreground.color.a);
        if (foreground.color != color) foreground.color = color;
    }

    private static void RefreshSharedButtonPalette()
    {
        // Updating these few owned references also covers already-scanned roots.
        // Native HUD graphics, shared themes and all non-button plates stay put.
        foreach (ClassicLobbyGraphic plate in sharedButtonPlates)
            if (plate != null) plate.BlackButtons = sharedBlackButtons;
        foreach (Graphic foreground in sharedButtonForegrounds)
            if (foreground != null) SetButtonForeground(foreground, sharedBlackButtons ? Gold : Dark);
    }

    private static bool IsMenu(Transform item)
    {
        for (Transform current = item; current != null; current = current.parent)
            if (menuRoots.Contains(current)) return true;
        return false;
    }

    private static void OnImageAwake(UIManagerImage __instance)
    {
        if (!installed || enabled == null || !enabled.Value || failed || __instance == null || !IsMenu(__instance.transform)) return;
        try { Style(__instance.GetComponent<Image>()); }
        catch (Exception error) { Fail(error); }
    }

    private static void OnTextAwake(UIManagerText __instance)
    {
        if (!installed || enabled == null || !enabled.Value || failed || __instance == null || !IsMenu(__instance.transform)) return;
        try { Style(__instance.GetComponent<TMP_Text>()); }
        catch (Exception error) { Fail(error); }
    }

    private static void Fail(Exception error)
    {
        failed = true;
        warning?.Invoke("Main menu appearance was skipped: " + error.Message);
        Restore();
    }

    private static UIManager Theme(UIManager source)
    {
        if (source == null) source = Resources.Load<UIManager>("Beam UI Manager");
        if (source == null) return null;
        int id = source.GetInstanceID();
        if (themes.TryGetValue(id, out UIManager result)) return result;
        // Some dynamically-created controls copy an already-scoped theme.
        foreach (UIManager existing in themes.Values) if (existing == source) return source;
        result = Object.Instantiate(source);
        result.name = "SCOM Gold Main Menu Theme";
        result.hideFlags = HideFlags.HideAndDontSave;
        result.accentColor = Gold;
        result.accentColorInvert = Dark;
        result.primaryColor = White;
        result.secondaryColor = WarmMuted;
        result.backgroundColor = Dark;
        // Preserve semantic errors / negative actions.
        themes[id] = result;
        themeSources[result.GetInstanceID()] = source;
        return result;
    }

    private static UIManager OriginalTheme(UIManager source)
    {
        // Generated entries may inherit an already scoped clone. Their saved
        // restore target must be the native asset, since our clones are released
        // when the UI preference is switched off.
        return source != null && themeSources.TryGetValue(source.GetInstanceID(), out UIManager original) ? original : source;
    }

    private static void Style(Image image)
    {
        if (image == null || image.transform.name == "SCOM Main Menu Background" || image.transform.name.StartsWith("SCOM Gold ", StringComparison.Ordinal)) return;
        int id = image.GetInstanceID();
        if (images.ContainsKey(id)) return;
        UIManagerImage manager = image.GetComponent<UIManagerImage>();
        images[id] = new ImageState { Image = image, Color = image.color, Manager = manager, Theme = manager != null ? OriginalTheme(manager.UIManagerAsset) : null, CustomColor = manager != null && manager.useCustomColor };
        if (IsAIContainer(image))
        {
            if (manager != null) manager.useCustomColor = true;
            var rect = LobbyControls.Rect("SCOM Gold AI Panel", image.transform, 0, 0, 0, 0);
            rect.gameObject.layer = image.gameObject.layer;
            LobbyControls.Stretch(rect);
            rect.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
            rect.SetAsFirstSibling();
            var plate = rect.gameObject.AddComponent<ClassicLobbyGraphic>();
            plate.Configure(image.rectTransform.rect.height > 120 ? ClassicLobbyGraphic.Surface.Panel : ClassicLobbyGraphic.Surface.Row);
            plate.raycastTarget = false;
            decoration.Add(rect.gameObject);
            image.color = Color.clear;
            return;
        }
        // The native outline exists only in Normal. Our background mesh already
        // supplies the same bevel in every state, so avoid a border that vanishes
        // when Beam cross-fades into its borderless Highlighted state.
        bool buttonFrame = (image.name == "Frame" || image.name == "Border") &&
            IsButtonState(image.transform.parent) && image.transform.parent.Find("Background")?.GetComponent<Image>() != null;
        if (buttonFrame)
        {
            if (manager != null) manager.useCustomColor = true;
            image.color = Color.clear;
            return;
        }
        bool buttonBackground = image.name == "Background" && IsButtonState(image.transform.parent);
        bool sidebarIcon = image.name == "Icon" && image.sprite != null && image.GetComponentInParent<PanelButton>() != null;
        Button nativeButton = image.GetComponent<Button>();
        bool simpleButton = nativeButton != null && nativeButton.targetGraphic == image && image.color.a > .05f && image.GetComponent<ButtonManager>() == null && image.GetComponent<PanelButton>() == null;
        if (buttonBackground || sidebarIcon || simpleButton)
        {
            if (manager != null) manager.useCustomColor = true;
            var rect = LobbyControls.Rect("SCOM Gold Menu Button", image.transform, 0, 0, 0, 0);
            rect.gameObject.layer = image.gameObject.layer;
            LobbyControls.Stretch(rect);
            rect.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
            rect.SetAsFirstSibling();
            decoration.Add(rect.gameObject);
            if (buttonBackground || simpleButton)
            {
                var graphic = rect.gameObject.AddComponent<ClassicLobbyGraphic>();
                graphic.raycastTarget = false;
                // Plain Unity buttons use Selectable's tint for their live state.
                // Their native black plates are translucent; that alpha and a
                // hidden panel's temporary disabled state must not be baked in.
                graphic.Configure(ClassicLobbyGraphic.Surface.Button, image.transform.parent.name == "Highlighted", !simpleButton && image.transform.parent.name == "Disabled");
                if (IsSharedControl(image.transform))
                {
                    graphic.BlackButtons = sharedBlackButtons;
                    sharedButtonPlates.Add(graphic);
                }
                graphic.color = simpleButton ? Color.white : new Color(1, 1, 1, image.color.a);
                if (simpleButton)
                {
                    buttonTargets[nativeButton] = nativeButton.targetGraphic;
                    // ColorTint keeps native hover/press/disabled feedback. The
                    // unchanged native Image remains the pointer hit target.
                    nativeButton.targetGraphic = graphic;
                }
            }
            else
            {
                // Keep the sidebar's original unboxed, full-size gold glyphs.
                var graphic = rect.gameObject.AddComponent<ScomMenuGoldIcon>();
                graphic.sprite = image.sprite;
                graphic.type = image.type;
                graphic.preserveAspect = image.preserveAspect;
                graphic.raycastTarget = false;
                graphic.color = new Color(1, 1, 1, image.color.a);
            }
            image.color = Color.clear;
            return;
        }
        if (image.name == "Icon" && HasGoldButtonBackground(image.transform))
        {
            if (manager != null) manager.useCustomColor = true;
            StyleButtonForeground(image);
            return;
        }
        if (manager != null)
        {
            manager.UIManagerAsset = Theme(manager.UIManagerAsset);
            if (ManagedImage.GetValue(manager) != null) UpdateImage.Invoke(manager, null);
            if (manager.useCustomColor && IsBlue(image.color)) image.color = Warm(image.color);
        }
        else if (IsBlue(image.color)) image.color = Warm(image.color);
    }

    private static void Style(TMP_Text text)
    {
        if (text == null || text.transform.parent != null && text.transform.parent.name == "SCOM Main Menu Subtitle") return;
        int id = text.GetInstanceID();
        if (texts.ContainsKey(id)) return;
        UIManagerText manager = text.GetComponent<UIManagerText>();
        texts[id] = new TextState { Text = text, Color = text.color, Manager = manager, Theme = manager != null ? OriginalTheme(manager.UIManagerAsset) : null, CustomColor = manager != null && manager.useCustomColor };
        if (HasGoldButtonBackground(text.transform))
        {
            if (manager != null) manager.useCustomColor = true;
            StyleButtonForeground(text);
            return;
        }
        if (manager != null)
        {
            manager.UIManagerAsset = Theme(manager.UIManagerAsset);
            if (ManagedText.GetValue(manager) != null) UpdateText.Invoke(manager, null);
            if (manager.useCustomColor && IsBlue(text.color)) text.color = new Color(Gold.r, Gold.g, Gold.b, text.color.a);
        }
        else if (IsBlue(text.color)) text.color = new Color(Gold.r, Gold.g, Gold.b, text.color.a);
    }

    private static bool IsBlue(Color color) => color.b > .12f && color.b > color.r * 1.2f && color.b >= color.g * .95f;

    private static bool IsAIContainer(Image image)
    {
        if (image.GetComponentInParent<AISettingsInterface>() == null ||
            (image.name != "Background" && image.name != "Solid") || image.color.a < .05f) return false;
        // Preserve native slider fills, switch selections, scrollbar handles,
        // dropdown entries and hit targets. Only neutral window/row plates get
        // solid lobby chrome; the controls inherit the scoped gold Beam theme.
        return image.GetComponentInParent<ButtonManager>() == null &&
            image.GetComponentInParent<Michsky.UI.Beam.Dropdown>() == null &&
            image.GetComponentInParent<HorizontalSelector>() == null &&
            image.GetComponentInParent<SwitchManager>() == null &&
            image.GetComponentInParent<Slider>() == null &&
            image.GetComponentInParent<Scrollbar>() == null &&
            image.GetComponentInParent<TMP_InputField>() == null;
    }
    private static Color Warm(Color color)
    {
        Color value = color.maxColorComponent > .48f ? Gold : Dark;
        return new Color(value.r, value.g, value.b, color.a);
    }

    private static bool IsButtonState(Transform item)
    {
        if (item == null || (item.name != "Normal" && item.name != "Highlighted" && item.name != "Disabled" && item.name != "Selected")) return false;
        return item.GetComponentInParent<ButtonManager>() != null || item.GetComponentInParent<PanelButton>() != null;
    }

    private static bool HasGoldButtonBackground(Transform item)
    {
        for (Transform current = item.parent; current != null; current = current.parent)
        {
            if (IsButtonState(current) && current.Find("Background")?.GetComponent<Image>() != null) return true;
            var button = current.GetComponent<Button>();
            if (button != null && buttonTargets.ContainsKey(button)) return true;
        }
        return false;
    }

    private static void EnsureBackdrop(InterfaceManager manager)
    {
        if (backdrop != null || manager.background == null) return;
        CancelArtworkFade();
        CancelMainSlideshow();
        var parent = manager.background.transform as RectTransform;
        if (parent == null) throw new InvalidOperationException("The native menu background has no UI rectangle.");
        var rect = LobbyControls.Rect("SCOM Main Menu Background", parent, 0, 0, 0, 0);
        rect.gameObject.layer = parent.gameObject.layer;
        LobbyControls.Stretch(rect);
        rect.SetAsLastSibling();
        rect.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
        backdrop = rect.gameObject;
        var picture = backdrop.AddComponent<ScomMenuBackdrop>();
        mainPictures[0] = picture;
        picture.texture = BackgroundTexture();
        picture.color = Color.white;
        picture.raycastTarget = false;
        picture.FitCover();
        // Render the wallpaper's natural lighting directly. A silhouette-shaped
        // contrast layer leaves a bright gutter around the armor at cover scale.
        // The commander remains opaque beneath the slideshow. Its frozen
        // composite also stays beneath the separate native-lobby wallpaper.
        string[] names = { "Battleship", "City" };
        Texture2D[] textures = { BattleshipTexture(), CityTexture() };
        for (int index = 1; index < mainPictures.Length; index++)
        {
            var slideRect = LobbyControls.Rect("SCOM Main Menu " + names[index - 1], rect, 0, 0, 0, 0);
            slideRect.gameObject.layer = rect.gameObject.layer;
            LobbyControls.Stretch(slideRect);
            slideRect.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
            var slidePicture = slideRect.gameObject.AddComponent<ScomMenuBackdrop>();
            slidePicture.texture = textures[index - 1];
            slidePicture.color = new Color(1, 1, 1, 0);
            slidePicture.raycastTarget = false;
            slidePicture.FitCover();
            mainPictures[index] = slidePicture;
        }
        backgroundChoicePending = true;
        var lobbyRect = LobbyControls.Rect("SCOM Lobby Background", rect, 0, 0, 0, 0);
        lobbyRect.gameObject.layer = rect.gameObject.layer;
        LobbyControls.Stretch(lobbyRect);
        lobbyRect.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
        lobbyPicture = lobbyRect.gameObject.AddComponent<ScomMenuBackdrop>();
        lobbyPicture.raycastTarget = false;
        artworkTarget = 0;
        SetLobbyBlend(0);
        // Loading status and its white logo sit over the center of the artwork.
        // Shade that screen modestly while retaining the same cached image.
        var loadingRect = LobbyControls.Rect("SCOM Loading Artwork Shade", rect, 0, 0, 0, 0);
        LobbyControls.Stretch(loadingRect);
        var loadingGraphic = loadingRect.gameObject.AddComponent<Image>();
        loadingGraphic.color = new Color(.055f, .043f, .027f, .35f);
        loadingGraphic.raycastTarget = false;
        loadingShade = loadingRect.gameObject;
        loadingShade.SetActive(false);
        // Keep the original artwork's pixels intact. A separate native gradient
        // provides contrast behind the white logo without obscuring the commander.
        var nativeShade = parent.Find("Shadows/Left")?.GetComponent<Image>();
        if (nativeShade != null && nativeShade.sprite != null)
        {
            var shadeRect = LobbyControls.Rect("SCOM Menu Logo Shade", rect, 0, 0, 850, 0);
            shadeRect.anchorMin = Vector2.zero;
            shadeRect.anchorMax = new Vector2(0, 1);
            shadeRect.pivot = new Vector2(0, .5f);
            shadeRect.anchoredPosition = Vector2.zero;
            shadeRect.sizeDelta = new Vector2(850, 0);
            var shade = shadeRect.gameObject.AddComponent<Image>();
            shade.sprite = nativeShade.sprite;
            shade.type = nativeShade.type;
            shade.color = new Color(.055f, .043f, .027f, .70f);
            shade.raycastTarget = false;
        }
    }

    private static Texture2D BackgroundTexture()
    {
        if (backgroundTexture == null)
            backgroundTexture = LoadArtwork("SCOM.MainMenu.Gold.png", "SCOM Main Menu Gold Artwork");
        return backgroundTexture;
    }

    private static Texture2D LobbyTexture()
    {
        if (lobbyTexture == null)
            lobbyTexture = LoadArtwork("SCOM.Lobby.Gold.png", "SCOM Lobby Gold Artwork");
        return lobbyTexture;
    }

    private static Texture2D BattleshipTexture()
    {
        if (battleshipTexture == null)
            battleshipTexture = LoadArtwork("SCOM.MainMenu.Battleship.Gold.png", "SCOM Main Menu Battleship Gold Artwork");
        return battleshipTexture;
    }

    private static Texture2D CityTexture()
    {
        if (cityTexture == null)
            cityTexture = LoadArtwork("SCOM.MainMenu.City.Gold.png", "SCOM Main Menu City Gold Artwork");
        return cityTexture;
    }

    private static Texture2D LoadArtwork(string resource, string name)
    {
        byte[] data;
        using (Stream stream = typeof(MainMenuStyle).Assembly.GetManifestResourceStream(resource))
        {
            if (stream == null) throw new FileNotFoundException("The embedded SCOM artwork was not found: " + resource);
            using (var copy = new MemoryStream()) { stream.CopyTo(copy); data = copy.ToArray(); }
        }
        Texture2D texture = new Texture2D(2, 2, TextureFormat.RGBA32, false);
        texture.name = name;
        texture.hideFlags = HideFlags.HideAndDontSave;
        if (!ImageConversion.LoadImage(texture, data, true)) { Object.Destroy(texture); throw new InvalidDataException("The embedded SCOM artwork could not be decoded: " + resource); }
        texture.filterMode = FilterMode.Bilinear;
        texture.wrapMode = TextureWrapMode.Clamp;
        return texture;
    }

    private static void Restore(bool releaseTexture = false)
    {
        CancelArtworkFade();
        CancelMainSlideshow();
        CancelBackgroundTransition();
        backgroundSelector?.Dispose();
        backgroundSelector = null;
        MainMenuBranding.SetLayout(false);
        foreach (ImageState state in images.Values)
        {
            if (state.Image != null) state.Image.color = state.Color;
            if (state.Manager != null)
            {
                state.Manager.UIManagerAsset = state.Theme;
                state.Manager.useCustomColor = state.CustomColor;
                if (!state.CustomColor && state.Theme != null && ManagedImage.GetValue(state.Manager) != null)
                    try { UpdateImage.Invoke(state.Manager, null); } catch (TargetInvocationException) { }
            }
        }
        foreach (TextState state in texts.Values)
        {
            if (state.Text != null) state.Text.color = state.Color;
            if (state.Manager != null)
            {
                state.Manager.UIManagerAsset = state.Theme;
                state.Manager.useCustomColor = state.CustomColor;
                if (!state.CustomColor && state.Theme != null && ManagedText.GetValue(state.Manager) != null)
                    try { UpdateText.Invoke(state.Manager, null); } catch (TargetInvocationException) { }
            }
        }
        foreach (var pair in socialTints) if (pair.Key != null) pair.Key.backgroundTint = pair.Value;
        foreach (var pair in legacyTexts) if (pair.Key != null) pair.Key.color = pair.Value;
        foreach (var pair in buttonTargets) if (pair.Key != null) pair.Key.targetGraphic = pair.Value;
        images.Clear(); texts.Clear(); socialTints.Clear(); menuRoots.Clear(); scannedRoots.Clear();
        legacyTexts.Clear(); buttonTargets.Clear();
        sharedButtonPlates.Clear(); sharedButtonForegrounds.Clear();
        sharedModalsRoot = null;
        sharedBlackButtons = true;
        // Detach before deferred Destroy so an OFF->ON change in the same frame
        // cannot recapture the old owned graphics as part of the native UI.
        foreach (GameObject created in decoration) if (created != null) { created.SetActive(false); created.transform.SetParent(null, false); Object.Destroy(created); }
        decoration.Clear();
        foreach (UIManager theme in themes.Values) if (theme != null) Object.Destroy(theme);
        themes.Clear();
        themeSources.Clear();
        if (backdrop != null) { backdrop.SetActive(false); backdrop.transform.SetParent(null, false); Object.Destroy(backdrop); backdrop = null; }
        loadingShade = null;
        Array.Clear(mainPictures, 0, mainPictures.Length);
        lobbyPicture = null;
        artworkTarget = lobbyBlend = 0;
        mainSlideshowEligible = false;
        loadingBackgroundEligible = false;
        mainSlideshowPhase = 0;
        appliedBackground = MainMenuBackground.Slideshow;
        backgroundChoicePending = true;
        // Retain decoded artworks across appearance toggles. Only final
        // disposal releases their cached textures; OFF has no visible owned UI.
        if (releaseTexture && backgroundTexture != null) { Object.Destroy(backgroundTexture); backgroundTexture = null; }
        if (releaseTexture && battleshipTexture != null) { Object.Destroy(battleshipTexture); battleshipTexture = null; }
        if (releaseTexture && cityTexture != null) { Object.Destroy(cityTexture); cityTexture = null; }
        if (releaseTexture && lobbyTexture != null) { Object.Destroy(lobbyTexture); lobbyTexture = null; }
    }

    public static void Dispose()
    {
        installed = false;
        if (enabled != null) enabled.SettingChanged -= OnPreferenceChanged;
        enabled = null;
        if (backgroundPreferences != null)
        {
            backgroundPreferences.Changed -= OnBackgroundPreferenceChanged;
            backgroundPreferences.Dispose();
        }
        if (host != null && initialApply != null) host.StopCoroutine(initialApply);
        initialApply = null;
        Restore(true);
        backgroundPreferences = null;
        configuration = null;
        host = null;
        MainMenuUiToggle.Dispose();
    }
}

internal sealed class ScomMenuBackdrop : RawImage
{
    protected override void OnRectTransformDimensionsChange()
    {
        base.OnRectTransformDimensionsChange();
        FitCover();
    }
    public void FitCover()
    {
        if (texture == null || rectTransform.rect.width < 1 || rectTransform.rect.height < 1) return;
        float imageAspect = (float)texture.width / texture.height;
        float viewAspect = rectTransform.rect.width / rectTransform.rect.height;
        if (viewAspect < imageAspect)
        {
            float width = viewAspect / imageAspect;
            uvRect = new Rect((1 - width) * .5f, 0, width, 1);
        }
        else
        {
            float height = imageAspect / viewAspect;
            uvRect = new Rect(0, (1 - height) * .5f, 1, height);
        }
    }
}

// Keep native sprite geometry and pointer routing, while giving compact
// sidebar icon buttons the same flat gold treatment as the filled buttons.
internal sealed class ScomMenuGoldIcon : Image
{
    protected override void OnPopulateMesh(VertexHelper mesh)
    {
        base.OnPopulateMesh(mesh);
        UIVertex vertex = new UIVertex();
        for (int index = 0; index < mesh.currentVertCount; index++)
        {
            mesh.PopulateUIVertex(ref vertex, index);
            vertex.color = new Color32(202, 178, 112, vertex.color.a);
            mesh.SetUIVertex(vertex, index);
        }
    }
}
