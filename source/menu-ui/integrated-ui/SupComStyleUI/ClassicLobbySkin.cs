using System;
using System.Collections.Generic;
using System.Reflection;
using EM.UI;
using EM.Network;
using EM.Core;
using Michsky.UI.Beam;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using Object = UnityEngine.Object;

namespace SupComStyleUI;

// Reversible native-lobby decoration. This runs only on lobby lifecycle/data
// callbacks and explicit preference changes, never from a polling Update loop.
internal sealed class ClassicLobbySkin
{
    private sealed class ImageState
    {
        public Image Image;
        public Color Color;
        public UIManagerImage Manager;
        public bool CustomColor;
    }
    private sealed class TextState
    {
        public TMP_Text Text;
        public Color Color;
        public float Size;
        public float Spacing;
        public FontStyles Style;
        public UIManagerText Manager;
        public bool CustomColor;
    }
    private readonly Transform root;
    private readonly Dictionary<int, ImageState> images = new Dictionary<int, ImageState>();
    private readonly Dictionary<int, TextState> texts = new Dictionary<int, TextState>();
    private readonly Dictionary<int, ClassicLobbyGraphic> metals = new Dictionary<int, ClassicLobbyGraphic>();
    private readonly Dictionary<int, ClassicPickButtonFeedback> picks = new Dictionary<int, ClassicPickButtonFeedback>();
    private readonly Dictionary<int, ClassicReadyButtonGlow> readyGlows = new Dictionary<int, ClassicReadyButtonGlow>();
    private readonly LobbyInterface lobby;
    private static readonly List<ClassicLobbySkin> instances = new List<ClassicLobbySkin>();
    private ScrollRect[] nativeLists;
    private int structureSignature;
    private bool applied;
    private bool generatedFailed;
    private static readonly Color PaleText = new Color32(255, 249, 229, 255);
    private static readonly Color MetalLine = new Color32(215, 187, 112, 255);
    private static readonly Color Gold = new Color32(235, 211, 143, 255);
    private static readonly Color ButtonText = new Color32(235, 211, 143, 255);
    private static readonly FieldInfo ManagedImage = typeof(UIManagerImage).GetField("objImage", BindingFlags.Instance | BindingFlags.NonPublic);
    private static readonly FieldInfo ManagedText = typeof(UIManagerText).GetField("objText", BindingFlags.Instance | BindingFlags.NonPublic);
    private static readonly MethodInfo UpdateManagedImage = typeof(UIManagerImage).GetMethod("UpdateImage", BindingFlags.Instance | BindingFlags.NonPublic);
    private static readonly MethodInfo UpdateManagedText = typeof(UIManagerText).GetMethod("UpdateText", BindingFlags.Instance | BindingFlags.NonPublic);
    private static readonly FieldInfo NativePickButton = typeof(PlayerListItem).GetField("pickButton", BindingFlags.Instance | BindingFlags.NonPublic);
    private static readonly FieldInfo NativeReadyButton = typeof(LobbyInterface).GetField("readyButton", BindingFlags.Instance | BindingFlags.NonPublic);
    private static readonly FieldInfo NativeHostReadyButton = typeof(LobbyInterface).GetField("hostReadyButton", BindingFlags.Instance | BindingFlags.NonPublic);

    public ClassicLobbySkin(Transform root) { this.root = root; lobby = root.GetComponent<LobbyInterface>(); instances.Add(this); }

    internal static void RefreshGenerated(Transform control)
    {
        if (control == null) return;
        foreach (var skin in instances)
            if (skin.applied && !skin.generatedFailed && skin.root != null && (control == skin.root || control.IsChildOf(skin.root)))
            {
                // Dropdown.Initialize parents new buttons after their Awake.
                // Style just this rebuilt control instead of the whole lobby.
                try { skin.StyleSubtree(control); }
                catch (Exception error)
                {
                    // Appearance must not break the native dropdown callback.
                    // Emit one warning until the UI preference is reset.
                    skin.generatedFailed = true;
                    Debug.LogWarning("[SCOM UI] A generated lobby control could not be styled: " + error.Message);
                }
                break;
            }
    }

    public void Apply(bool enabled, bool force = false)
    {
        if (!enabled) { Restore(); return; }
        foreach (var pick in picks.Values) if (pick != null) pick.Refresh();
        RefreshReadySelection();
        // Player-data refreshes reuse native pooled rows. Their content text can
        // change without recreating any chrome, so do not rescan thousands of
        // descendants or allocate hierarchy paths on each network callback.
        if (applied && !force && ComputeStructureSignature() == structureSignature) return;
        applied = true;
        StyleSubtree(root);
        RefreshReadySelection();

        // Native map lists and dropdowns rebuild below existing ScrollRects.
        nativeLists = root.GetComponentsInChildren<ScrollRect>(true);
        structureSignature = ComputeStructureSignature();
    }

    private void StyleSubtree(Transform scope)
    {
        foreach (Image image in scope.GetComponentsInChildren<Image>(true))
        {
            string path = PathOf(image.transform);
            if (Skip(path) || SemanticImage(image, path)) continue;
            string name = image.name;
            bool arrowRoot = name == "Top Arrow" || name == "Bottom Arrow" || name == "Expand Icon" || name == "ExpandIcon";
            bool arrowGroup = IsArrowPath(path);
            bool arrow = arrowGroup && (name == "Icon" || name == "Arrow") || arrowRoot && !HasArrowGlyphChild(image.transform);
            bool option = DropdownOptionFor(image.transform) != null;
            bool titlePlate = name == "Title" && path.Contains("/Header/") || name == "Header" && path.Contains("/MainContent/");
            bool infoIcon = name == "Icon" && path.Contains("/LobbyInfoProperties/");
            bool actionIcon = name == "Icon" && (path.Contains("/Normal/") || path.Contains("/Highlighted/") || path.Contains("/Disabled/"));
            // These are overlays drawn above the whole row/control. They must
            // stay translucent; native ButtonManager's separate "Highlighted"
            // state backgrounds are behind that state's own text and can be solid.
            bool overlay = path.Contains("/Highlight/") || path.Contains("/Selection/") || path.Contains("/Selected/");
            bool background = name == "Background" || name == "Solid" || name == "Filler" || name == "Highlight" || titlePlate || arrowRoot;
            bool frame = name == "Frame" || name == "Border";
            bool separator = path.Contains("/Separator/") || name == "Separator";
            bool scrollbar = !arrowRoot && (path.Contains("/Scrollbar/") || path.EndsWith("/Scrollbar", StringComparison.Ordinal));
            if (!arrow && !background && !frame && !separator && !scrollbar && !infoIcon && !actionIcon) continue;
            Capture(image);
            var manager = images[image.GetInstanceID()].Manager;
            if (manager != null) manager.useCustomColor = true;
            // Beam cross-fades state groups whose plate rectangles differ.
            // Pick gets one plate on the stable button root instead, so hovering
            // cannot briefly render two staggered frames over one another.
            if ((background || frame) && PickFor(image.transform) != null)
            {
                image.color = Color.clear;
                continue;
            }
            if (overlay && background) { image.color = new Color32(244, 213, 152, 25); continue; }
            if (arrow) { image.color = Gold; continue; }
            if (actionIcon) { image.color = ButtonText; continue; }
            if (infoIcon) { image.color = MetalLine; continue; }
            if (separator || scrollbar) { image.color = MetalLine; continue; }
            // State-background meshes keep their bevel on hover. Suppress the
            // extra native outline that is present in Normal only.
            if (frame && arrowGroup)
            {
                // The native faction Expand Icon has no root Image and no
                // Background child: its Frame is the only plate under Icon.
                // Replace that frame rather than simply hiding its outline.
                Transform parent = image.transform.parent;
                bool hasPlate = parent != null && (parent.GetComponent<Image>() != null || parent.Find("Background")?.GetComponent<Image>() != null);
                if (!hasPlate) AddMetal(image, ClassicLobbyGraphic.Surface.ArrowButton, path.Contains("/Highlighted/"), path.Contains("/Disabled/"));
                image.color = Color.clear;
                continue;
            }
            if (frame && HasSkinnedButtonBackground(image.transform)) { image.color = Color.clear; continue; }
            if (frame) { image.color = new Color32(235, 212, 153, 225); continue; }
            if (name == "Highlight") { image.color = new Color32(244, 213, 152, 70); continue; }

            bool stateButton = arrowRoot || path.Contains("/Normal/") || path.Contains("/Highlighted/") || path.Contains("/Disabled/");
            bool dropdown = path.Contains("Dropdown/") || path.Contains("/Dropdown/");
            bool row = path.Contains("PlayerListItem") && path.EndsWith("/Background", StringComparison.Ordinal) && !stateButton && !dropdown;
            bool header = titlePlate || path.Contains("/Header/") || path.Contains("/Top/");
            // Header action fillers are narrow animated accent bars, not plates.
            if (name == "Filler") { image.color = new Color32(186, 161, 91, 170); continue; }
            var kind = option ? ClassicLobbyGraphic.Surface.DropdownOption : arrowRoot || arrowGroup ? ClassicLobbyGraphic.Surface.ArrowButton : stateButton ? ClassicLobbyGraphic.Surface.Button : row ? ClassicLobbyGraphic.Surface.Row : header ? ClassicLobbyGraphic.Surface.Header : dropdown ? ClassicLobbyGraphic.Surface.Inset : ClassicLobbyGraphic.Surface.Panel;
            AddMetal(image, kind, path.Contains("/Highlighted/"), path.Contains("/Disabled/"));
            image.color = Color.clear;
        }

        foreach (TMP_Text text in scope.GetComponentsInChildren<TMP_Text>(true))
        {
            string path = PathOf(text.transform);
            if (Skip(path) || path.Contains("/Avatar/") || path.Contains("/ReadyText") || path.Contains("/NotReadyText")) continue;
            int id = text.GetInstanceID();
            if (!texts.ContainsKey(id))
            {
                var manager = text.GetComponent<UIManagerText>();
                texts.Add(id, new TextState { Text = text, Color = text.color, Size = text.fontSize, Spacing = text.characterSpacing, Style = text.fontStyle, Manager = manager, CustomColor = manager != null && manager.useCustomColor });
            }
            if (texts[id].Manager != null) texts[id].Manager.useCustomColor = true;
            bool buttonText = path.Contains("/Normal/") || path.Contains("/Highlighted/") || path.Contains("/Disabled/") || IsArrowPath(path);
            text.color = buttonText || DropdownOptionFor(text.transform) != null ? ButtonText : PaleText;
            text.characterSpacing = .35f;
            text.fontStyle &= ~FontStyles.UpperCase;
            // A compact header and row label rhythm, while retaining native hitboxes.
            if (path.Contains("/Header/Title/") || path.Contains("/Top/")) text.fontSize = Mathf.Min(text.fontSize, 20f);
            else if (path.Contains("PlayerListItem")) text.fontSize = Mathf.Min(text.fontSize, 17f);
        }

        foreach (PlayerListItem row in scope.GetComponentsInChildren<PlayerListItem>(true))
        {
            var button = NativePickButton?.GetValue(row) as ButtonManager;
            if (button == null) continue;
            int id = button.GetInstanceID();
            if (!picks.TryGetValue(id, out var feedback) || feedback == null)
            {
                feedback = button.GetComponent<ClassicPickButtonFeedback>() ?? button.gameObject.AddComponent<ClassicPickButtonFeedback>();
                picks[id] = feedback;
            }
            feedback.SetEnabled(true);
        }

    }

    private int ComputeStructureSignature()
    {
        if (nativeLists == null) return 0;
        unchecked
        {
            int signature = nativeLists.Length;
            for (int index = 0; index < nativeLists.Length; index++)
            {
                ScrollRect list = nativeLists[index];
                if (list == null || list.content == null) { signature = signature * 31; continue; }
                RectTransform content = list.content;
                int count = content.childCount;
                signature = signature * 31 + content.GetInstanceID();
                signature = signature * 31 + count;
                if (count != 0)
                {
                    signature = signature * 31 + content.GetChild(0).GetInstanceID();
                    signature = signature * 31 + content.GetChild(count - 1).GetInstanceID();
                }
            }
            return signature;
        }
    }

    private void Capture(Image image)
    {
        int id = image.GetInstanceID();
        if (!images.ContainsKey(id))
        {
            var manager = image.GetComponent<UIManagerImage>();
            images.Add(id, new ImageState { Image = image, Color = image.color, Manager = manager, CustomColor = manager != null && manager.useCustomColor });
        }
    }

    private void AddMetal(Image image, ClassicLobbyGraphic.Surface kind, bool highlight, bool disabled)
    {
        int id = image.GetInstanceID();
        if (!metals.TryGetValue(id, out var metal) || metal == null)
        {
            var rect = LobbyControls.Rect("SCOM Classic Metal", image.transform, 0, 0, 0, 0);
            rect.gameObject.layer = image.gameObject.layer;
            LobbyControls.Stretch(rect);
            rect.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
            rect.SetAsFirstSibling();
            metal = rect.gameObject.AddComponent<ClassicLobbyGraphic>();
            // Beam controls inspect the native hit object. Decoration must never
            // become a pointer target; the native Image keeps its raycast flag.
            metal.raycastTarget = false;
            metals[id] = metal;
        }
        metal.gameObject.SetActive(true);
        metal.Configure(kind, highlight, disabled);
    }

    private string PathOf(Transform item)
    {
        string path = item.name;
        while (item.parent != null && item.parent != root) { item = item.parent; path = item.name + "/" + path; }
        return path;
    }

    private static bool Skip(string path)
        => path.Contains("SCOM Gold Faction Logo") || path.Contains("SCOM UI Local Preference") || path.Contains("SupCom lobby") || path.Contains("SupCom modal") ||
           path.Contains("SupCom Unit Manager") || path.Contains("SCOM Classic");

    private static bool HasSkinnedButtonBackground(Transform image)
    {
        Transform state = image.parent;
        return state != null && (state.name == "Normal" || state.name == "Highlighted" || state.name == "Disabled") &&
            state.Find("Background")?.GetComponent<Image>() != null &&
            (state.GetComponentInParent<ButtonManager>() != null || state.GetComponentInParent<PanelButton>() != null);
    }

    private static bool SemanticImage(Image image, string path)
        => path.Contains("/Avatar/") || path.Contains("/AiAvatar/") || path.Contains("/HostIcon") ||
           path.Contains("/Faction/") && !IsArrowPath(path) && (path.EndsWith("/Icon", StringComparison.Ordinal) || path.Contains("/Icon Parent/")) ||
           IsNativeDropdownIcon(image) ||
           path.Contains("/Ready/") || path.Contains("/NotReady/") || path.Contains("/Color/") || path.Contains("/Colour/");

    private static bool IsArrowPath(string path)
        => path.Contains("/Expand Icon/") || path.Contains("/ExpandIcon/") || path.Contains("/Top Arrow/") || path.Contains("/Bottom Arrow/") ||
           path.EndsWith("/Expand Icon", StringComparison.Ordinal) || path.EndsWith("/ExpandIcon", StringComparison.Ordinal);

    private static bool HasArrowGlyphChild(Transform root)
    {
        foreach (Image child in root.GetComponentsInChildren<Image>(true))
            if (child.transform != root && (child.name == "Icon" || child.name == "Arrow")) return true;
        return false;
    }

    private static bool IsNativeDropdownIcon(Image image)
    {
        var dropdown = image.GetComponentInParent<Michsky.UI.Beam.Dropdown>();
        if (dropdown == null) return false;
        if (image == dropdown.headerImage) return true;
        var option = DropdownOptionFor(image.transform);
        return option != null && (image == option.normalImageObj || image == option.highlightImageObj || image == option.disabledImageObj);
    }

    private static ButtonManager DropdownOptionFor(Transform item)
    {
        var button = item.GetComponentInParent<ButtonManager>();
        var dropdown = item.GetComponentInParent<Michsky.UI.Beam.Dropdown>();
        return button != null && dropdown != null && dropdown.itemParent != null && button.transform.IsChildOf(dropdown.itemParent) ? button : null;
    }

    private static ButtonManager PickFor(Transform item)
    {
        var row = item.GetComponentInParent<PlayerListItem>();
        var button = row != null ? NativePickButton?.GetValue(row) as ButtonManager : null;
        return button != null && (item == button.transform || item.IsChildOf(button.transform)) ? button : null;
    }

    private void RefreshReadySelection(bool restore = false)
    {
        if (lobby == null) return;
        var local = !restore && LobbyManager.IsInLobby && LobbyManager.lobbyGameStatus == LobbyManager.LobbyGameStatus.lobby ?
            LobbyManager.CurrentState?.GetPlayer(LobbyManager.localPlayerID) : null;
        bool selected = local != null && local.isReady && local.type != PlayerType.Observer;
        RefreshReadyButton(NativeReadyButton?.GetValue(lobby) as ButtonManager, selected);
        RefreshReadyButton(NativeHostReadyButton?.GetValue(lobby) as ButtonManager, selected);
    }

    private void RefreshReadyButton(ButtonManager button, bool selected)
    {
        if (button == null) return;
        // UpdateButtons activates only the checked host/client variant. The
        // unchecked buttons keep their normal native hover and action behavior.
        selected &= button.gameObject.activeSelf;
        int id = button.GetInstanceID();
        if (!readyGlows.TryGetValue(id, out var glow) || glow == null)
        {
            if (selected)
            {
                glow = button.GetComponent<ClassicReadyButtonGlow>() ?? button.gameObject.AddComponent<ClassicReadyButtonGlow>();
                readyGlows[id] = glow;
            }
        }
        if (glow != null) glow.SetReady(selected);
        foreach (Image image in button.GetComponentsInChildren<Image>(true))
            if (metals.TryGetValue(image.GetInstanceID(), out var metal) && metal != null)
            {
                string state = image.transform.parent != null ? image.transform.parent.name : string.Empty;
                metal.Configure(ClassicLobbyGraphic.Surface.Button, selected || state == "Highlighted", state == "Disabled");
            }
    }

    public void Restore()
    {
        if (!applied) return;
        RefreshReadySelection(true);
        foreach (var pick in picks.Values) if (pick != null) pick.SetEnabled(false);
        foreach (var state in images.Values)
        {
            if (state.Image != null) state.Image.color = state.Color;
            if (state.Manager == null) continue;
            state.Manager.useCustomColor = state.CustomColor;
            // Some inactive dropdown-state children have not awakened yet. Only
            // refresh initialized managers; the others initialize natively later.
            if (!state.CustomColor && state.Manager.UIManagerAsset != null && ManagedImage != null && ManagedImage.GetValue(state.Manager) != null)
                try { UpdateManagedImage?.Invoke(state.Manager, null); } catch (TargetInvocationException) { }
        }
        foreach (var state in texts.Values)
        {
            if (state.Text != null) { state.Text.color = state.Color; state.Text.fontSize = state.Size; state.Text.characterSpacing = state.Spacing; state.Text.fontStyle = state.Style; }
            if (state.Manager == null) continue;
            state.Manager.useCustomColor = state.CustomColor;
            if (!state.CustomColor && state.Manager.UIManagerAsset != null && ManagedText != null && ManagedText.GetValue(state.Manager) != null)
                try { UpdateManagedText?.Invoke(state.Manager, null); } catch (TargetInvocationException) { }
        }
        foreach (var metal in metals.Values) if (metal != null) metal.gameObject.SetActive(false);
        images.Clear(); texts.Clear();
        nativeLists = null;
        applied = false;
        generatedFailed = false;
    }

    public void Dispose()
    {
        Restore();
        instances.Remove(this);
        foreach (var metal in metals.Values) if (metal != null) { metal.gameObject.SetActive(false); Object.Destroy(metal.gameObject); }
        metals.Clear();
        foreach (var pick in picks.Values) if (pick != null) { pick.Dispose(); Object.Destroy(pick); }
        picks.Clear();
        foreach (var glow in readyGlows.Values) if (glow != null) { glow.Dispose(); Object.Destroy(glow); }
        readyGlows.Clear();
    }

    internal static void StyleOwnedButton(Button button, bool selected = false, bool enabled = true)
    {
        if (button == null) return;
        var feedback = button.GetComponent<ClassicOwnedButtonFeedback>();
        if (!enabled) { if (feedback != null) feedback.SetEnabled(false, selected); return; }
        if (feedback == null) feedback = button.gameObject.AddComponent<ClassicOwnedButtonFeedback>();
        var background = button.GetComponent<ChamferPanelGraphic>();
        if (background != null) { background.FillColor = Color.clear; background.BorderColor = Color.clear; }
        var label = button.GetComponentInChildren<TextMeshProUGUI>(true);
        if (label != null) { label.color = ButtonText; label.characterSpacing = .2f; label.fontStyle &= ~FontStyles.UpperCase; }
        feedback.SetEnabled(true, selected);
    }
}

// Only player-slot Pick buttons use this plate. Their native Beam callbacks,
// state labels, pointer targets and availability rules remain authoritative.
internal sealed class ClassicPickButtonFeedback : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerDownHandler, IPointerUpHandler, ISelectHandler, IDeselectHandler
{
    private ButtonManager button;
    private ClassicLobbyGraphic metal;
    private bool active;
    private bool hovered;
    private bool pressed;
    private float oldTextSize;
    private int oldSpacing, oldLeft, oldRight, oldTop, oldBottom;

    public void SetEnabled(bool value)
    {
        button = GetComponent<ButtonManager>();
        if (button == null) return;
        if (value && !active)
        {
            oldTextSize = button.textSize;
            oldSpacing = button.spacing;
            if (button.padding != null)
            {
                oldLeft = button.padding.left; oldRight = button.padding.right;
                oldTop = button.padding.top; oldBottom = button.padding.bottom;
                button.padding.left = button.padding.right = 10;
                button.padding.top = button.padding.bottom = 2;
            }
            button.textSize = 18;
            button.spacing = 6;
            button.UpdateUI();
        }
        else if (!value && active)
        {
            button.textSize = oldTextSize;
            button.spacing = oldSpacing;
            if (button.padding != null)
            {
                button.padding.left = oldLeft; button.padding.right = oldRight;
                button.padding.top = oldTop; button.padding.bottom = oldBottom;
            }
            button.UpdateUI();
        }
        if (metal == null && value)
        {
            var rect = LobbyControls.Rect("SCOM Classic Pick Surface", transform, 0, 0, 0, 0);
            rect.gameObject.layer = gameObject.layer;
            LobbyControls.Stretch(rect);
            rect.offsetMin = new Vector2(4, 6);
            rect.offsetMax = new Vector2(-4, -6);
            rect.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
            rect.SetAsFirstSibling();
            metal = rect.gameObject.AddComponent<ClassicLobbyGraphic>();
            metal.raycastTarget = false;
        }
        active = value;
        enabled = value;
        if (metal != null) metal.gameObject.SetActive(value);
        if (value)
        {
            StyleLabel(button.normalTextObj);
            StyleLabel(button.highlightTextObj);
            StyleLabel(button.disabledTextObj);
        }
        Refresh();
    }

    private static void StyleLabel(TextMeshProUGUI label)
    {
        if (label == null) return;
        label.fontSize = 18;
        label.characterSpacing = .1f;
        label.fontStyle = (label.fontStyle & ~FontStyles.UpperCase) | FontStyles.Bold;
        label.color = new Color32(235, 211, 143, 255);
    }

    public void Refresh()
    {
        if (!active || metal == null || button == null) return;
        bool available = button.isInteractable;
        metal.Configure(ClassicLobbyGraphic.Surface.PickButton, available && (hovered || pressed), !available);
        metal.color = pressed && available ? new Color(.92f, .86f, .72f, 1) : Color.white;
    }

    public void OnPointerEnter(PointerEventData data) { hovered = true; Refresh(); }
    public void OnPointerExit(PointerEventData data) { hovered = pressed = false; Refresh(); }
    public void OnPointerDown(PointerEventData data) { pressed = true; Refresh(); }
    public void OnPointerUp(PointerEventData data) { pressed = false; Refresh(); }
    public void OnSelect(BaseEventData data) { hovered = true; Refresh(); }
    public void OnDeselect(BaseEventData data) { hovered = pressed = false; Refresh(); }
    private void OnEnable() { Refresh(); }
    private void OnDisable() { hovered = pressed = false; }
    public void Dispose() { SetEnabled(false); if (metal != null) { Object.Destroy(metal.gameObject); metal = null; } }
}

internal sealed class ClassicOwnedButtonFeedback : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerDownHandler, IPointerUpHandler
{
    private ClassicLobbyGraphic metal;
    private Button button;
    private bool selected;
    private bool hovered;
    private bool pressed;

    public void SetEnabled(bool value, bool selected)
    {
        this.selected = selected;
        button = GetComponent<Button>();
        if (metal == null && value)
        {
            var rect = LobbyControls.Rect("SCOM Classic Button", transform, 0, 0, 0, 0);
            LobbyControls.Stretch(rect);
            rect.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
            rect.SetAsFirstSibling();
            metal = rect.gameObject.AddComponent<ClassicLobbyGraphic>();
            metal.raycastTarget = false;
        }
        enabled = value;
        if (metal != null) metal.gameObject.SetActive(value);
        Refresh();
    }

    private void Refresh()
    {
        if (metal == null) return;
        bool interactable = button != null && button.IsInteractable();
        metal.Configure(ClassicLobbyGraphic.Surface.Button, interactable && (selected || hovered || pressed), !interactable);
        metal.color = pressed ? new Color(.82f, .72f, .53f, 1) : Color.white;
    }
    public void OnPointerEnter(PointerEventData data) { hovered = true; Refresh(); }
    public void OnPointerExit(PointerEventData data) { hovered = pressed = false; Refresh(); }
    public void OnPointerDown(PointerEventData data) { pressed = true; Refresh(); }
    public void OnPointerUp(PointerEventData data) { pressed = false; Refresh(); }
    private void OnEnable() { Refresh(); }
    private void OnDisable() { hovered = pressed = false; }
}
