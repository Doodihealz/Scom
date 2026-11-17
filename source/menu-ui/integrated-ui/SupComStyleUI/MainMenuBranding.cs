using EM.UI;
using HarmonyLib;
using Michsky.UI.Beam;
using TMPro;
using UnityEngine;
using Object = UnityEngine.Object;

namespace SupComStyleUI;

// Subtitle branding remains permanent; the optional front-end presentation
// also positions the title group within the space beside the commander.
internal static class MainMenuBranding
{
    private const string SubtitlePath = "Content/logotext/SCOM Main Menu Subtitle";
    private const string Caption = "<color=#EBD38F>Supreme Commander</color> <color=#FFFFFF>Overhaul Mod</color>";
    private static RectTransform appliedSubtitle;
    private static RectTransform layoutWordmark;
    private static RectTransform layoutSymbol;
    private static Vector2 originalWordmarkPosition;
    private static Vector2 originalSymbolPosition;
    private static bool layoutEnabled;
    private const float TitleShiftCanvasUnits = 57.5f;

    public static void Install(Harmony harmony)
    {
        var awake = AccessTools.Method(typeof(HomeInterface), "Awake");
        var callback = AccessTools.Method(typeof(MainMenuBranding), nameof(AfterHomeAwake));
        bool patched = false;
        var info = Harmony.GetPatchInfo(awake);
        if (info != null)
            foreach (Patch patch in info.Postfixes)
                if (patch.owner == harmony.Id && patch.PatchMethod == callback) { patched = true; break; }
        if (!patched) harmony.Patch(awake, postfix: new HarmonyMethod(callback));
        Ensure(HomeInterface.Instance);
    }

    private static void AfterHomeAwake(HomeInterface __instance) => Ensure(__instance);

    public static void Ensure(HomeInterface home)
    {
        if (home == null) return;
        if (layoutEnabled) ApplyLayout(home);
        // These identify the active overhaul, independently of its appearance switch.
        foreach (SocialsWidget widget in home.GetComponentsInChildren<SocialsWidget>(true))
            if (widget != null && widget.gameObject.activeSelf) widget.gameObject.SetActive(false);
        MainMenuVersions.Ensure(home);
        var subtitle = home.transform.Find(SubtitlePath) as RectTransform;
        if (subtitle == null || subtitle == appliedSubtitle) return;
        var text = subtitle.Find("Subtitle Text")?.GetComponent<TMP_Text>();
        if (text == null) return;

        var badge = subtitle.Find("SCOM Logo");
        if (badge != null)
        {
            badge.gameObject.SetActive(false);
            badge.SetParent(null, false);
            Object.Destroy(badge.gameObject);
        }

        text.text = Caption;
        text.richText = true;
        text.overrideColorTags = false;
        text.color = Color.white;
        text.enableVertexGradient = false;
        text.fontStyle &= ~FontStyles.Underline;
        text.alignment = TextAlignmentOptions.Center;
        var textRect = text.rectTransform;
        var inset = textRect.offsetMin;
        inset.x = 0;
        textRect.offsetMin = inset;
        var shine = subtitle.GetComponent<MainMenuTextShine>();
        if (shine == null) shine = subtitle.gameObject.AddComponent<MainMenuTextShine>();
        shine.Bind(text);
        appliedSubtitle = subtitle;
    }

    public static void SetLayout(bool useScom)
    {
        layoutEnabled = useScom;
        if (useScom) { ApplyLayout(HomeInterface.Instance); return; }
        if (layoutWordmark != null) layoutWordmark.anchoredPosition = originalWordmarkPosition;
        if (layoutSymbol != null) layoutSymbol.anchoredPosition = originalSymbolPosition;
    }

    private static void ApplyLayout(HomeInterface home)
    {
        if (home == null) return;
        var wordmark = home.transform.Find("Content/logotext") as RectTransform;
        var symbol = home.transform.Find("Content/logosymbol") as RectTransform;
        if (wordmark != layoutWordmark)
        {
            if (layoutWordmark != null) layoutWordmark.anchoredPosition = originalWordmarkPosition;
            layoutWordmark = wordmark;
            if (wordmark != null) originalWordmarkPosition = wordmark.anchoredPosition;
        }
        if (symbol != layoutSymbol)
        {
            if (layoutSymbol != null) layoutSymbol.anchoredPosition = originalSymbolPosition;
            layoutSymbol = symbol;
            if (symbol != null) originalSymbolPosition = symbol.anchoredPosition;
        }
        // Canvas units already follow the native CanvasScaler. Derive from the
        // captured positions on every call so toggles and resizes cannot drift.
        if (layoutWordmark != null)
            layoutWordmark.anchoredPosition = new Vector2(originalWordmarkPosition.x - TitleShiftCanvasUnits, originalWordmarkPosition.y);
        if (layoutSymbol != null)
            layoutSymbol.anchoredPosition = new Vector2(originalSymbolPosition.x - TitleShiftCanvasUnits, originalSymbolPosition.y);
    }
}
