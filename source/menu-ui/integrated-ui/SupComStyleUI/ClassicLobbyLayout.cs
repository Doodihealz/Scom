using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace SupComStyleUI;

// A reversible setup-dialog arrangement. Native controls remain in their original
// hierarchy; scaling a whole panel keeps its graphics and pointer geometry aligned.
internal sealed class ClassicLobbyLayout : IDisposable
{
    private sealed class RectState
    {
        public RectTransform Rect;
        public Vector2 Min, Max, Pivot, Position, Size;
        public Vector3 Scale;
    }
    private sealed class BehaviourState
    {
        public Behaviour Behaviour;
        public bool Enabled;
    }
    private readonly RectTransform root;
    private readonly Dictionary<int, RectState> rects = new Dictionary<int, RectState>();
    private readonly Dictionary<int, BehaviourState> behaviours = new Dictionary<int, BehaviourState>();
    private bool applied;
    private bool changing;
    private Vector2 previousSize;
    private float footerHeight = 64;

    internal bool SetFooterHeight(float height)
    {
        height = Mathf.Max(64, height);
        if (Mathf.Approximately(footerHeight, height)) return false;
        footerHeight = height;
        return true;
    }

    public ClassicLobbyLayout(Transform root)
    {
        this.root = root as RectTransform;
    }

    public void Apply(bool enabled, bool force = false)
    {
        if (changing || root == null) return;
        if (!enabled) { Restore(); return; }
        Vector2 size = root.rect.size;
        if (size.x < 100 || size.y < 100) return;
        if (applied && !force && (previousSize - size).sqrMagnitude < .1f) return;
        changing = true;
        try
        {
            RectTransform content = Find("Content");
            RectTransform layout = Find("Content/VerticalLayout");
            RectTransform top = Find("Content/VerticalLayout/Top");
            RectTransform middle = Find("Content/VerticalLayout/Middle");
            RectTransform left = Find("Content/VerticalLayout/Middle/LeftSide");
            RectTransform right = Find("Content/VerticalLayout/Middle/RightSide");
            RectTransform bottom = Find("Content/VerticalLayout/Bottom");
            if (content == null || layout == null || top == null || middle == null || left == null || right == null || bottom == null) return;

            applied = true;
            previousSize = size;
            // The original setup is a compact central window, with the player
            // table and chat sharing the left side and map/properties on the right.
            float height = Mathf.Min(size.y * .86f, 920f);
            float width = Mathf.Min(size.x * .94f, height * 1.50f);
            float innerWidth = width - 32f;
            float innerHeight = height - 32f;
            const float topHeight = 50f;
            float bottomHeight = footerHeight;
            const float gap = 12f;
            float middleHeight = innerHeight - topHeight - bottomHeight - gap * 2;
            float rightWidth = Mathf.Clamp(innerWidth * .255f, 260f, 360f);
            float leftWidth = innerWidth - rightWidth - gap;

            // Beam animates Content itself. Keep that native coordinate contract
            // untouched, and center the compact children inside its full-size rect.
            // Changing Content's anchors/pivot made native show animations reset
            // its geometry and required a visible late reflow.
            DisableLayout(layout);
            Center(layout, innerWidth, innerHeight);
            var backdrop = content.Find("Background Shadow") as RectTransform;
            if (backdrop != null) Center(backdrop, width, height);
            var frame = content.Find("SupCom lobby frame") as RectTransform;
            if (frame != null) Center(frame, width, height);
            Box(top, 0, 0, innerWidth, topHeight);
            Rebuild(top);
            DisableLayout(middle);
            Box(middle, 0, topHeight + gap, innerWidth, middleHeight);
            Box(left, 0, 0, leftWidth, middleHeight);
            Box(right, leftWidth + gap, 0, rightWidth, middleHeight);

            RectTransform list = left.Find("ListPanel") as RectTransform;
            RectTransform chat = left.Find("ChatPanel") as RectTransform;
            if (list != null && chat != null)
            {
                DisableLayout(left);
                float chatHeight = Mathf.Clamp(middleHeight * .29f, 150f, 220f);
                float tableHeight = middleHeight - chatHeight - gap;
                // Scale every row, avatar, dropdown and header together. Merely
                // reducing row height would leave native 50px child controls overlapping.
                float tableScale = Mathf.Clamp(leftWidth / 1260f, .66f, .85f);
                Box(list, 0, 0, leftWidth, tableHeight, tableScale);
                Box(chat, 0, tableHeight + gap, leftWidth, chatHeight, .86f);
                Rebuild(list);
                Rebuild(chat);
            }
            else
            {
                // Lobby Settings has its own game-settings/map-list stack. Keep
                // that native layout while making its contents a little denser.
                Box(left, 0, 0, leftWidth, middleHeight, .90f);
                Rebuild(left);
            }

            ArrangeInfo(right, rightWidth, middleHeight);
            // Preserve the native button group and client/host visibility rules.
            // A uniform footer scale leaves room for the saved local UI checkbox.
            Box(bottom, 0, innerHeight - bottomHeight, innerWidth, bottomHeight, .84f);
            Rebuild(bottom);
            // The native outer groups are disabled while this arrangement owns
            // their rectangles. Rebuild each enabled inner group explicitly:
            // marking the disabled ancestor would leave old driven child widths.
            Canvas.ForceUpdateCanvases();
        }
        finally { changing = false; }
    }

    private void ArrangeInfo(RectTransform right, float width, float height)
    {
        var panel = right.Find("LobbyInfoPanel") as RectTransform;
        if (panel == null) return;
        const float scale = .86f;
        float virtualWidth = width / scale;
        float virtualHeight = height / scale;
        DisableLayout(panel);
        Box(panel, 0, 0, width, height, scale);
        var header = panel.Find("Header") as RectTransform;
        var content = panel.Find("Content") as RectTransform;
        if (header != null) Box(header, 0, 0, virtualWidth, 28);
        if (content == null) return;
        Box(content, 0, 28, virtualWidth, virtualHeight - 28);
        var info = content.Find("LobbyInfo") as RectTransform;
        if (info == null) return;
        DisableLayout(info);
        Box(info, 0, 0, virtualWidth, virtualHeight - 28);
        var map = info.Find("MapImage") as RectTransform;
        var image = info.Find("MapImage/Image Parent") as RectTransform;
        var properties = info.Find("LobbyInfoProperties") as RectTransform;
        if (map != null) Box(map, 0, 0, virtualWidth, virtualWidth);
        if (image != null)
        {
            DisableLayout(image);
            Box(image, 0, 0, virtualWidth, virtualWidth);
        }
        if (properties != null)
        {
            Box(properties, 0, virtualWidth + 8, virtualWidth, Mathf.Max(100, virtualHeight - 36 - virtualWidth));
            Rebuild(properties);
        }
        if (map != null) Rebuild(map);
    }

    private RectTransform Find(string path) => root.Find(path) as RectTransform;

    private void Capture(RectTransform rect)
    {
        int id = rect.GetInstanceID();
        if (!rects.ContainsKey(id))
            rects.Add(id, new RectState { Rect = rect, Min = rect.anchorMin, Max = rect.anchorMax,
                Pivot = rect.pivot, Position = rect.anchoredPosition, Size = rect.sizeDelta, Scale = rect.localScale });
    }

    private void DisableLayout(RectTransform rect)
    {
        foreach (Behaviour behaviour in rect.GetComponents<Behaviour>())
        {
            if (!(behaviour is LayoutGroup) && !(behaviour is ContentSizeFitter) && !(behaviour is AspectRatioFitter)) continue;
            int id = behaviour.GetInstanceID();
            if (!behaviours.ContainsKey(id)) behaviours.Add(id, new BehaviourState { Behaviour = behaviour, Enabled = behaviour.enabled });
            behaviour.enabled = false;
        }
    }

    private void Center(RectTransform rect, float width, float height)
    {
        Capture(rect);
        DisableFitters(rect);
        rect.anchorMin = rect.anchorMax = rect.pivot = new Vector2(.5f, .5f);
        rect.anchoredPosition = Vector2.zero;
        rect.sizeDelta = new Vector2(width, height);
        rect.localScale = Vector3.one;
    }

    private void DisableFitters(RectTransform rect)
    {
        foreach (Behaviour behaviour in rect.GetComponents<Behaviour>())
        {
            if (!(behaviour is ContentSizeFitter) && !(behaviour is AspectRatioFitter)) continue;
            int id = behaviour.GetInstanceID();
            if (!behaviours.ContainsKey(id)) behaviours.Add(id, new BehaviourState { Behaviour = behaviour, Enabled = behaviour.enabled });
            behaviour.enabled = false;
        }
    }

    private void Box(RectTransform rect, float x, float y, float width, float height, float scale = 1)
    {
        Capture(rect);
        // An explicitly sized rectangle must not be resized again by a fitter.
        // Keep its child LayoutGroup active so native controls arrange normally.
        DisableFitters(rect);
        rect.anchorMin = rect.anchorMax = rect.pivot = new Vector2(0, 1);
        rect.anchoredPosition = new Vector2(x, -y);
        rect.sizeDelta = new Vector2(width / scale, height / scale);
        rect.localScale = new Vector3(scale, scale, 1);
    }

    private static void Rebuild(RectTransform rect)
    {
        if (rect != null) LayoutRebuilder.ForceRebuildLayoutImmediate(rect);
    }

    public void Restore()
    {
        if (!applied || changing) return;
        changing = true;
        try
        {
            foreach (var state in rects.Values)
            {
                if (state.Rect == null) continue;
                state.Rect.anchorMin = state.Min; state.Rect.anchorMax = state.Max;
                state.Rect.pivot = state.Pivot; state.Rect.anchoredPosition = state.Position;
                state.Rect.sizeDelta = state.Size; state.Rect.localScale = state.Scale;
            }
            foreach (var state in behaviours.Values)
                if (state.Behaviour != null) state.Behaviour.enabled = state.Enabled;
            rects.Clear(); behaviours.Clear();
            applied = false;
            var layout = Find("Content/VerticalLayout");
            if (layout != null) LayoutRebuilder.MarkLayoutForRebuild(layout);
        }
        finally { changing = false; }
    }

    public void Dispose() => Restore();
}
