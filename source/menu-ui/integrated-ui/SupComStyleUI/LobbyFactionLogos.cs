using System;
using System.Collections.Generic;
using System.Reflection;
using EM.Core;
using EM.UI;
using HarmonyLib;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using Object = UnityEngine.Object;
using Dropdown = Michsky.UI.Beam.Dropdown;

namespace SupComStyleUI;

// Faction identity stays visible independently of the optional gold UI theme.
// Native SCOM dropdown items remain the sole owners of faction names/sprites.
internal static class LobbyFactionLogos
{
    private static readonly FieldInfo FactionDropdown = AccessTools.Field(typeof(PlayerListItem), "factionDropdown");
    private static readonly FieldInfo FactionText = AccessTools.Field(typeof(PlayerListItem), "factionText");
    private static readonly List<LobbyFactionLogoRow> rows = new List<LobbyFactionLogoRow>();
    private static Action<string> warning;
    private static bool installed, warned;

    public static void Install(Harmony harmony, Action<string> warn)
    {
        if (installed) return;
        warning = warn;
        warned = false;
        try
        {
            var awake = AccessTools.Method(typeof(PlayerListItem), "Awake");
            var update = AccessTools.Method(typeof(PlayerListItem), "UpdateData");
            var select = AccessTools.Method(typeof(Dropdown), "SetDropdownIndex", new[] { typeof(int) });
            var initialize = AccessTools.Method(typeof(Dropdown), "Initialize", Type.EmptyTypes);
            if (FactionDropdown == null || FactionText == null || awake == null || update == null || select == null || initialize == null)
                throw new MissingMemberException("The native lobby faction display contract was not found.");
            harmony.Patch(awake, postfix: new HarmonyMethod(typeof(LobbyFactionLogos), nameof(Attach)));
            harmony.Patch(update, postfix: new HarmonyMethod(typeof(LobbyFactionLogos), nameof(Attach)));
            harmony.Patch(select, postfix: new HarmonyMethod(typeof(LobbyFactionLogos), nameof(Selected)));
            harmony.Patch(initialize, postfix: new HarmonyMethod(typeof(LobbyFactionLogos), nameof(OptionsCreated)));
            installed = true;
            if (LobbyInterface.Instance != null)
                foreach (var row in LobbyInterface.Instance.GetComponentsInChildren<PlayerListItem>(true)) Attach(row);
        }
        catch (Exception error) { Warn(error); }
    }

    private static void Attach(PlayerListItem __instance)
    {
        if (!installed || __instance == null) return;
        try
        {
            var view = __instance.GetComponent<LobbyFactionLogoRow>();
            if (view == null)
            {
                var dropdown = FactionDropdown.GetValue(__instance) as Dropdown;
                var text = FactionText.GetValue(__instance) as TextMeshProUGUI;
                if (dropdown == null || dropdown.headerText == null || text == null) return;
                view = __instance.gameObject.AddComponent<LobbyFactionLogoRow>();
                try { view.Initialize(__instance, dropdown, text); }
                catch { view.DisposeOwned(); Object.Destroy(view); throw; }
                rows.RemoveAll(item => item == null);
                rows.Add(view);
            }
            view.Refresh((int)__instance.player.faction);
        }
        catch (Exception error) { Warn(error); }
    }

    private static LobbyFactionLogoRow ViewFor(Dropdown dropdown)
    {
        if (!installed || dropdown == null) return null;
        var row = dropdown.GetComponentInParent<PlayerListItem>(true);
        // Team/type selectors must retain their native icons and layout.
        return row != null && ReferenceEquals(FactionDropdown.GetValue(row), dropdown) ? row.GetComponent<LobbyFactionLogoRow>() : null;
    }

    private static void Selected(Dropdown __instance, int itemIndex)
    {
        try { ViewFor(__instance)?.Refresh(itemIndex); }
        catch (Exception error) { Warn(error); }
    }

    private static void OptionsCreated(Dropdown __instance)
    {
        try { ViewFor(__instance)?.RefreshOptions(); }
        catch (Exception error) { Warn(error); }
    }

    private static void Warn(Exception error)
    {
        if (warned) return;
        warned = true;
        warning?.Invoke("Lobby faction logos could not be refreshed: " + error.Message);
    }

    public static void Dispose()
    {
        installed = false;
        foreach (var row in rows)
            if (row != null) { row.DisposeOwned(); Object.Destroy(row); }
        rows.Clear();
        warning = null;
    }
}

internal sealed class LobbyFactionLogoRow : MonoBehaviour
{
    private sealed class Badge
    {
        private const float LogoSize = 22;
        private const float Gap = 4;
        private const float Inset = 2;
        private readonly TextMeshProUGUI text;
        private readonly Vector4 margin;
        private readonly TextOverflowModes overflow;
        private readonly TextWrappingModes wrapping;
        private readonly Image image;

        public Badge(TextMeshProUGUI caption)
        {
            text = caption;
            margin = text.margin;
            overflow = text.overflowMode;
            wrapping = text.textWrappingMode;
            var rect = LobbyControls.Rect("SCOM Gold Faction Logo", caption.transform, 0, 0, LogoSize, LogoSize);
            rect.gameObject.layer = caption.gameObject.layer;
            rect.anchorMin = rect.anchorMax = rect.pivot = new Vector2(0, .5f);
            rect.anchoredPosition = new Vector2(margin.x + Inset, 0);
            rect.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
            image = rect.gameObject.AddComponent<Image>();
            image.raycastTarget = false;
            image.preserveAspect = true;
            image.color = Color.white;
            TMPro_EventManager.TEXT_CHANGED_EVENT.Add(OnTextChanged);
            Set(null);
        }

        public void Set(Sprite sprite)
        {
            if (text == null || image == null) return;
            bool visible = sprite != null;
            var nextMargin = visible ? new Vector4(margin.x + LogoSize + Gap + Inset, margin.y, margin.z, margin.w) : margin;
            if (text.margin != nextMargin) text.margin = nextMargin;
            var nextOverflow = visible ? TextOverflowModes.Ellipsis : overflow;
            if (text.overflowMode != nextOverflow) text.overflowMode = nextOverflow;
            var nextWrapping = visible ? TextWrappingModes.NoWrap : wrapping;
            if (text.textWrappingMode != nextWrapping) text.textWrappingMode = nextWrapping;
            image.sprite = sprite;
            // A hidden/content-sized caption can report zero width before its
            // first layout. Sprite presence alone controls the anchored icon.
            image.gameObject.SetActive(visible);
            if (visible)
            {
                text.ForceMeshUpdate(true);
                PlaceBeforeName();
            }
        }

        private void OnTextChanged(Object changed)
        {
            if (ReferenceEquals(changed, text) && image != null && image.gameObject.activeSelf) PlaceBeforeName();
        }

        private void PlaceBeforeName()
        {
            if (text == null || image == null) return;
            var info = text.textInfo;
            if (info == null || info.characterInfo == null) return;
            for (int index = 0; index < info.characterCount; index++)
            {
                var character = info.characterInfo[index];
                if (!character.isVisible) continue;
                // The native caption rectangle can overhang the field. Use the
                // drawn name's left edge, not that rectangle's left anchor.
                float left = Mathf.Min(character.bottomLeft.x, character.topLeft.x);
                image.rectTransform.anchoredPosition = new Vector2(left - text.rectTransform.rect.xMin - LogoSize - Gap, 0);
                return;
            }
        }

        public void Dispose()
        {
            TMPro_EventManager.TEXT_CHANGED_EVENT.Remove(OnTextChanged);
            if (text != null) { text.margin = margin; text.overflowMode = overflow; text.textWrappingMode = wrapping; }
            if (image == null) return;
            image.gameObject.SetActive(false);
            image.transform.SetParent(null, false);
            Object.Destroy(image.gameObject);
        }
    }

    private readonly Dictionary<Transform, int> optionOrder = new Dictionary<Transform, int>();
    private PlayerListItem row;
    private Dropdown dropdown;
    private Badge selected, locked;
    private bool originalEnableIcon, originalHeaderActive;
    private bool initialized;

    public void Initialize(PlayerListItem owner, Dropdown selector, TextMeshProUGUI caption)
    {
        row = owner;
        dropdown = selector;
        originalEnableIcon = dropdown.enableIcon;
        originalHeaderActive = dropdown.headerImage != null && dropdown.headerImage.gameObject.activeSelf;
        initialized = true;
        selected = new Badge(dropdown.headerText);
        locked = new Badge(caption);
        RefreshOptions();
    }

    internal static bool HasFaction(PlayerType type, int army)
        => army > 0 && (type == PlayerType.Player || type == PlayerType.AI);

    private Sprite SpriteAt(int index)
    {
        if (dropdown == null || index < 0 || index >= dropdown.items.Count) return null;
        var item = dropdown.items[index];
        if (item == null) return null;
        return item.itemIcon != null ? item.itemIcon :
            item.itemButton != null && item.itemButton.enableIcon ? item.itemButton.buttonIcon : null;
    }

    public void Refresh(int index)
    {
        if (!initialized || row == null || dropdown == null) return;
        var sprite = HasFaction(row.player.type, row.player.armyID) ? SpriteAt(index) : null;
        // Own the selected badge so Beam cannot hide it when swapping to the
        // ready/remote text-only branch, or move it back left on selection.
        dropdown.enableIcon = false;
        if (dropdown.headerImage != null) dropdown.headerImage.gameObject.SetActive(false);
        selected?.Set(sprite);
        locked?.Set(sprite);
    }

    public void RefreshOptions()
    {
        if (!initialized || dropdown == null) return;
        var stale = new List<Transform>();
        foreach (var item in optionOrder) if (item.Key == null) stale.Add(item.Key);
        foreach (var item in stale) optionOrder.Remove(item);
        foreach (var item in dropdown.items)
        {
            var button = item?.itemButton;
            if (button == null) continue;
            MoveOptionIcon(button.normalImageObj);
            MoveOptionIcon(button.highlightImageObj);
            MoveOptionIcon(button.disabledImageObj);
        }
    }

    private void MoveOptionIcon(Image image)
    {
        if (image == null || image.transform.parent == null || image.transform.parent.parent == null) return;
        var parent = image.transform.parent;
        if (!optionOrder.ContainsKey(parent)) optionOrder.Add(parent, parent.GetSiblingIndex());
        if (parent.GetSiblingIndex() != 0) parent.SetAsFirstSibling();
    }

    private void OnEnable()
    {
        if (initialized && row != null) Refresh((int)row.player.faction);
    }

    public void DisposeOwned()
    {
        if (!initialized) return;
        initialized = false;
        selected?.Dispose(); locked?.Dispose();
        selected = locked = null;
        if (dropdown != null)
        {
            dropdown.enableIcon = originalEnableIcon;
            if (dropdown.headerImage != null) dropdown.headerImage.gameObject.SetActive(originalHeaderActive);
        }
        foreach (var item in optionOrder) if (item.Key != null) item.Key.SetSiblingIndex(item.Value);
        optionOrder.Clear();
        row = null;
        dropdown = null;
    }

    private void OnDestroy() => DisposeOwned();
}
