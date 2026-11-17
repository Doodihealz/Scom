using System;
using System.Collections.Generic;
using System.Linq;
using EM.UI;
using HarmonyLib;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using Object = UnityEngine.Object;

namespace SupComStyleUI;

// This local preference stays available in the native lobby, including for
// clients whose host-owned game-settings button is hidden by Sanctuary.
internal static class ScomUiSettings
{
    private static LobbyPreferences preferences;
    private static Action refreshSurfaces;
    private static readonly List<ScomUiSettingsControl> controls = new List<ScomUiSettingsControl>();

    public static void Install(Harmony harmony, LobbyPreferences settings, Action refresh)
    {
        Dispose();
        preferences = settings;
        refreshSurfaces = refresh;
        preferences.Enabled.SettingChanged += LobbyPreferenceChanged;
        preferences.HudEnabled.SettingChanged += HudPreferenceChanged;
        foreach (var method in new[] {
            AccessTools.Method(typeof(LobbyInterface), "Start"),
            AccessTools.Method(typeof(LobbyInterface), "UpdateData"),
            AccessTools.Method(typeof(LobbySettingsInterface), "Start"),
            AccessTools.Method(typeof(LobbySettingsInterface), "CreateData"),
            AccessTools.Method(typeof(LobbySettingsInterface), "UpdateData"),
            AccessTools.Method(typeof(LobbySettingsInterface), "UpdateMapList") })
        {
            if (method == null) throw new MissingMethodException("The native lobby does not expose its local UI preference hooks.");
            harmony.Patch(method, postfix: new HarmonyMethod(typeof(ScomUiSettings), nameof(Attach)));
        }
        if (LobbyInterface.Instance != null) Attach(LobbyInterface.Instance);
        if (LobbySettingsInterface.Instance != null) Attach(LobbySettingsInterface.Instance);
    }

    private static void Attach(MonoBehaviour __instance)
    {
        if (__instance == null || preferences == null) return;
        try
        {
            var control = __instance.GetComponent<ScomUiSettingsControl>();
            if (control == null)
            {
                control = __instance.gameObject.AddComponent<ScomUiSettingsControl>();
                try
                {
                    control.Initialize(preferences);
                    controls.Add(control);
                }
                catch
                {
                    control.DisposeOwned();
                    Object.Destroy(control);
                    throw;
                }
            }
            control.Sync();
        }
        catch (Exception error)
        {
            Debug.LogWarning("[SCOM UI] Local UI preference control could not be attached: " + error.Message);
        }
    }

    private static void LobbyPreferenceChanged(object sender, EventArgs args)
    {
        try { refreshSurfaces?.Invoke(); }
        catch (Exception error) { Debug.LogWarning("[SCOM UI] Lobby preference refresh failed: " + error.Message); }
        SyncControls();
    }

    private static void HudPreferenceChanged(object sender, EventArgs args) => SyncControls();

    private static void SyncControls()
    {
        controls.RemoveAll(control => control == null);
        foreach (var control in controls) control.Sync();
    }

    public static void Dispose()
    {
        if (preferences != null)
        {
            preferences.Enabled.SettingChanged -= LobbyPreferenceChanged;
            preferences.HudEnabled.SettingChanged -= HudPreferenceChanged;
        }
        foreach (var control in controls)
            if (control != null) { control.DisposeOwned(); Object.Destroy(control); }
        controls.Clear();
        preferences = null;
        refreshSurfaces = null;
    }
}

internal sealed class ScomUiSettingsControl : MonoBehaviour
{
    private sealed class PreferenceRow
    {
        public Toggle Toggle;
        public Image Background;
        public Image Checkbox;
        public Image Selected;
        public TextMeshProUGUI Label;
        public TextMeshProUGUI State;
        public UnityEngine.Events.UnityAction<bool> Change;
        public readonly List<Image> Outline = new List<Image>();
    }

    private LobbyPreferences preferences;
    private RectTransform owned;
    private PreferenceRow lobbyRow;
    private PreferenceRow hudRow;
    private bool initialized;

    public void Initialize(LobbyPreferences settings)
    {
        preferences = settings;
        var footer = transform.Find("Content/VerticalLayout/Bottom/Left") as RectTransform;
        if (footer == null) throw new MissingMemberException("The native lobby footer was not found.");
        TMP_FontAsset font = GetComponentsInChildren<TMP_Text>(true)
            .Select(text => text.font).FirstOrDefault(asset => asset != null) ?? TMP_Settings.defaultFontAsset;
        owned = LobbyControls.Rect("SCOM UI Local Preferences", footer, 0, 0, 290, 64);
        owned.anchorMin = owned.anchorMax = owned.pivot = new Vector2(.5f, .5f);
        owned.anchoredPosition = Vector2.zero;
        owned.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
        lobbyRow = CreateRow("SCOM UI", font, 0, ChangeLobby);
        hudRow = CreateRow("In-game UI", font, 34, ChangeHud);
        initialized = true;
        Sync();
    }

    private PreferenceRow CreateRow(string title, TMP_FontAsset font, float y,
        UnityEngine.Events.UnityAction<bool> change)
    {
        var row = new PreferenceRow { Change = change };
        var rect = LobbyControls.Rect(title, owned, 0, y, 290, 30);
        row.Background = rect.gameObject.AddComponent<Image>();
        row.Background.raycastTarget = true;
        row.Toggle = rect.gameObject.AddComponent<Toggle>();
        row.Toggle.targetGraphic = row.Background;
        row.Toggle.navigation = new Navigation { mode = Navigation.Mode.None };
        var colors = row.Toggle.colors;
        colors.normalColor = Color.white;
        colors.highlightedColor = new Color(1f, .95f, .82f, 1f);
        colors.selectedColor = colors.highlightedColor;
        colors.pressedColor = new Color(.82f, .7f, .47f, 1f);
        colors.disabledColor = new Color(.5f, .47f, .4f, .7f);
        colors.fadeDuration = .1f;
        row.Toggle.colors = colors;
        row.Checkbox = Image("Checkbox", rect, 7, 4, 22, 22);
        row.Outline.Add(Image("Top", row.Checkbox.rectTransform, 0, 0, 22, 1));
        row.Outline.Add(Image("Bottom", row.Checkbox.rectTransform, 0, 21, 22, 1));
        row.Outline.Add(Image("Left", row.Checkbox.rectTransform, 0, 0, 1, 22));
        row.Outline.Add(Image("Right", row.Checkbox.rectTransform, 21, 0, 1, 22));
        row.Selected = Image("Selected", row.Checkbox.rectTransform, 5, 5, 12, 12);
        row.Toggle.graphic = row.Selected;
        row.Label = Label(rect, font, title, 40, 0, 180, 30, 18);
        row.State = Label(rect, font, "Off", 222, 0, 58, 30, 16);
        row.State.alignment = TextAlignmentOptions.MidlineRight;
        row.Toggle.onValueChanged.AddListener(change);
        return row;
    }

    private static Image Image(string name, Transform parent, float x, float y, float width, float height)
    {
        var graphic = LobbyControls.Rect(name, parent, x, y, width, height).gameObject.AddComponent<Image>();
        graphic.raycastTarget = false;
        return graphic;
    }

    private static TextMeshProUGUI Label(Transform parent, TMP_FontAsset font, string value,
        float x, float y, float width, float height, float size)
    {
        var text = LobbyControls.Rect("Label", parent, x, y, width, height).gameObject.AddComponent<TextMeshProUGUI>();
        text.font = font;
        text.text = value;
        text.fontSize = size;
        text.fontStyle = FontStyles.Normal;
        text.richText = false;
        text.textWrappingMode = TextWrappingModes.NoWrap;
        text.overflowMode = TextOverflowModes.Ellipsis;
        text.alignment = TextAlignmentOptions.MidlineLeft;
        text.raycastTarget = false;
        return text;
    }

    private void ChangeLobby(bool enabled) => Change(enabled, false);
    private void ChangeHud(bool enabled) => Change(enabled, true);

    private void Change(bool enabled, bool hud)
    {
        try
        {
            if (hud) preferences.SetHudEnabled(enabled);
            else preferences.SetEnabled(enabled);
        }
        catch (Exception error)
        {
            Debug.LogWarning("[SCOM UI] UI preference could not be saved: " + error.Message);
            Sync();
        }
    }

    public void Sync()
    {
        if (!initialized || preferences == null) return;
        SyncRow(lobbyRow, preferences.Enabled.Value, preferences);
        SyncRow(hudRow, preferences.HudEnabled.Value, preferences);
        GetComponent<LobbySurface>()?.ArrangeFooter();
    }

    private static void SyncRow(PreferenceRow row, bool enabled, LobbyPreferences theme)
    {
        if (row == null || row.Toggle == null) return;
        row.Toggle.SetIsOnWithoutNotify(enabled);
        Color background = Color.Lerp(theme.Panel, theme.Accent, enabled ? .10f : 0f);
        background.a = 235f / 255f;
        row.Background.color = background;
        row.Checkbox.color = Color.Lerp(theme.Panel, Color.black, .45f);
        row.Selected.color = theme.Accent;
        Color border = enabled ? Color.Lerp(theme.Accent, theme.Text, .24f) : theme.Accent;
        foreach (var edge in row.Outline) if (edge != null) edge.color = border;
        row.Label.color = theme.Text;
        row.State.text = enabled ? "On" : "Off";
        row.State.color = enabled ? theme.Accent : theme.MutedText;
    }

    private void OnEnable() { Sync(); }
    private void OnDestroy() { DisposeOwned(); }

    public void DisposeOwned()
    {
        initialized = false;
        foreach (var row in new[] { lobbyRow, hudRow })
            if (row != null && row.Toggle != null) row.Toggle.onValueChanged.RemoveListener(row.Change);
        lobbyRow = hudRow = null;
        if (owned != null) { owned.gameObject.SetActive(false); Object.Destroy(owned.gameObject); owned = null; }
        preferences = null;
    }
}
