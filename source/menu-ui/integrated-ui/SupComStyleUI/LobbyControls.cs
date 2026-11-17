using System;
using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

namespace SupComStyleUI;

internal sealed class LobbyControls
{
    public readonly LobbyPreferences Theme;
    private readonly TMP_FontAsset font;
    private readonly bool compact;
    public LobbyControls(LobbyPreferences theme, TMP_FontAsset font, bool compact = false) { Theme = theme; this.font = font; this.compact = compact; }

    // The dense editor needs quiet controls and readable status labels. Its
    // context is separate from the lobby toolbar's larger action buttons.
    public LobbyControls ForUnitManager() => compact ? this : new LobbyControls(Theme, font, true);

    public static RectTransform Rect(string name, Transform parent, float x, float y, float width, float height)
    {
        var rect = new GameObject(name, typeof(RectTransform)).GetComponent<RectTransform>();
        rect.SetParent(parent, false);
        rect.anchorMin = rect.anchorMax = rect.pivot = new Vector2(0, 1);
        rect.anchoredPosition = new Vector2(x, -y);
        rect.sizeDelta = new Vector2(width, height);
        return rect;
    }

    public static void Stretch(RectTransform rect, float inset = 0)
    {
        rect.anchorMin = Vector2.zero;
        rect.anchorMax = Vector2.one;
        rect.offsetMin = new Vector2(inset, inset);
        rect.offsetMax = new Vector2(-inset, -inset);
    }

    public ChamferPanelGraphic Panel(RectTransform rect, bool raycast = false)
    {
        var graphic = rect.gameObject.AddComponent<ChamferPanelGraphic>();
        StylePanel(graphic);
        graphic.BorderWidth = 1;
        graphic.Chamfer = 0;
        graphic.ChamferAllCorners = true;
        graphic.AcceptRaycasts = raycast;
        return graphic;
    }

    public void StylePanel(ChamferPanelGraphic graphic)
    {
        graphic.FillColor = Theme.Panel;
        graphic.BorderColor = Theme.Accent;
    }

    public TextMeshProUGUI Label(Transform parent, string text, float x, float y, float width, float height, float size = 0)
    {
        var label = Rect("Label", parent, x, y, width, height).gameObject.AddComponent<TextMeshProUGUI>();
        label.font = font;
        label.fontSize = size > 0 ? size : Theme.FontSize.Value;
        label.text = text;
        label.color = Theme.Text;
        label.richText = false;
        label.raycastTarget = false;
        label.textWrappingMode = TextWrappingModes.NoWrap;
        label.overflowMode = TextOverflowModes.Ellipsis;
        label.alignment = TextAlignmentOptions.MidlineLeft;
        return label;
    }

    public TextMeshProUGUI Heading(Transform parent, string text, float x, float y, float width, float height, float size = 15, bool tab = false)
    {
        var rect = Rect(text, parent, x, y, width, height);
        if (tab)
        {
            var background = rect.gameObject.AddComponent<Image>();
            background.color = Theme.Accent;
            background.raycastTarget = false;
        }
        var label = Label(rect, text, tab ? 8 : 0, 0, width - (tab ? 16 : 0), height, size);
        label.fontStyle = FontStyles.UpperCase;
        label.characterSpacing = 2;
        label.color = tab ? Theme.Control : Theme.Accent;
        return label;
    }

    public Button Button(Transform parent, string title, float x, float y, float width, float height, UnityAction click)
    {
        var rect = Rect(title, parent, x, y, width, height);
        var bg = Panel(rect, true);
        var button = rect.gameObject.AddComponent<Button>();
        button.navigation = new Navigation { mode = Navigation.Mode.None };
        button.targetGraphic = bg;
        var colors = button.colors;
        colors.normalColor = Color.white;
        colors.highlightedColor = new Color(.78f, .9f, 1, 1);
        colors.selectedColor = colors.highlightedColor;
        colors.pressedColor = new Color(.55f, .72f, .9f, 1);
        colors.disabledColor = new Color(.4f, .4f, .4f, 1);
        button.colors = colors;
        var label = Label(rect, title, 8, 0, width - 16, height);
        if (compact)
        {
            Stretch(label.rectTransform);
            label.rectTransform.offsetMin = new Vector2(10, 0);
            label.rectTransform.offsetMax = new Vector2(-10, 0);
        }
        label.alignment = TextAlignmentOptions.Center;
        label.fontStyle = FontStyles.UpperCase;
        label.characterSpacing = 1.5f;
        label.fontSize = 16;
        StyleButton(button);
        button.onClick.AddListener(click);
        return button;
    }

    public void StyleButton(Button button, bool selected = false)
    {
        var background = (ChamferPanelGraphic)button.targetGraphic;
        if (compact)
        {
            ClassicLobbySkin.StyleOwnedButton(button, selected, false);
            background.GoldButtonTheme = false;
            background.FillColor = Theme.Enabled.Value ? ClassicLobbyGraphic.ButtonFill : selected ? Color.Lerp(Theme.Control, Theme.Accent, .16f) : Theme.Control;
            background.BorderColor = selected ? Theme.Accent : Color.Lerp(Theme.Control, Theme.Accent, .50f);
            background.BorderWidth = selected ? 1.5f : 1f;
            background.Chamfer = 4;
            var compactLabel = button.GetComponentInChildren<TextMeshProUGUI>(true);
            compactLabel.color = Theme.Enabled.Value ? new Color32(235, 211, 143, 255) : Theme.Text;
            compactLabel.fontStyle &= ~FontStyles.UpperCase;
            compactLabel.characterSpacing = .2f;
            var colors = button.colors;
            colors.normalColor = Color.white;
            colors.highlightedColor = new Color(1.16f, 1.16f, 1.12f, 1);
            colors.selectedColor = Color.white;
            colors.pressedColor = new Color(.78f, .78f, .74f, 1);
            colors.disabledColor = new Color(.65f, .65f, .65f, .75f);
            colors.fadeDuration = .08f;
            button.colors = colors;
            return;
        }
        background.GoldButtonTheme = Theme.Enabled.Value;
        background.FillColor = selected ? Color.Lerp(Theme.Control, Theme.Accent, .28f) : Theme.Control;
        background.BorderColor = Theme.Accent;
        var label = button.GetComponentInChildren<TextMeshProUGUI>();
        label.color = Theme.Accent;
        label.fontStyle = FontStyles.UpperCase;
        label.characterSpacing = 1.5f;
        ClassicLobbySkin.StyleOwnedButton(button, selected, Theme.Enabled.Value);
    }

    public void StyleStateButton(Button button, bool restricted, bool locked = false)
    {
        StyleButton(button);
        if (!compact) return;
        var background = (ChamferPanelGraphic)button.targetGraphic;
        background.FillColor = Theme.Enabled.Value ? ClassicLobbyGraphic.ButtonFill : restricted ? new Color32(48, 31, 26, 255) : new Color32(25, 33, 27, 255);
        background.BorderColor = Theme.Enabled.Value ? Theme.Accent : restricted ? new Color32(170, 115, 86, 255) : new Color32(105, 127, 92, 255);
        var label = button.GetComponentInChildren<TextMeshProUGUI>(true);
        label.color = Theme.Enabled.Value ? new Color32(235, 211, 143, 255) : restricted ? new Color32(255, 205, 182, 255) : new Color32(224, 240, 215, 255);
        label.fontStyle = FontStyles.Bold;
        label.characterSpacing = .1f;
        // Group/linked restrictions are status readouts as well as controls.
        // Their text remains clear when native interactivity is disabled.
        if (locked)
        {
            var colors = button.colors;
            colors.disabledColor = new Color(.82f, .82f, .82f, 1);
            button.colors = colors;
        }
    }

    public TMP_InputField Search(Transform parent, float x, float y, float width, float height, UnityAction<string> changed)
    {
        var rect = Rect("Search", parent, x, y, width, height);
        var bg = Panel(rect, true);
        bg.GoldButtonTheme = false;
        bg.FillColor = Theme.Control;
        bg.BorderColor = compact ? Color.Lerp(Theme.Control, Theme.Accent, .55f) : Theme.Accent;
        bg.BorderWidth = 1;
        bg.Chamfer = 4;
        var field = rect.gameObject.AddComponent<TMP_InputField>();
        field.navigation = new Navigation { mode = Navigation.Mode.None };
        var viewport = Rect("Viewport", rect, 12, 0, width - 24, height);
        Stretch(viewport);
        viewport.offsetMin = new Vector2(12, 0);
        viewport.offsetMax = new Vector2(-12, 0);
        viewport.gameObject.AddComponent<RectMask2D>();
        field.textViewport = viewport;
        field.textComponent = Label(viewport, "", 0, 0, width - 24, height);
        Stretch(field.textComponent.rectTransform);
        var placeholder = Label(viewport, "Search name, ID, faction, tier or tag...", 0, 0, width - 24, height);
        Stretch(placeholder.rectTransform);
        placeholder.color = Theme.MutedText;
        field.placeholder = placeholder;
        field.targetGraphic = bg;
        field.customCaretColor = true;
        field.caretColor = Theme.Accent;
        field.selectionColor = new Color(Theme.Accent.r, Theme.Accent.g, Theme.Accent.b, .3f);
        field.characterLimit = 100;
        field.onValueChanged.AddListener(changed);
        return field;
    }
}
