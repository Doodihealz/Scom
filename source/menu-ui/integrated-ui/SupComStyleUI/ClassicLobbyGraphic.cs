using UnityEngine;
using UnityEngine.UI;

namespace SupComStyleUI;

// Small procedural meshes keep the lobby skin independent of copied game art.
// Geometry is rebuilt only when a rect or its visual state changes.
public sealed class ClassicLobbyGraphic : MaskableGraphic
{
    // Sampled from the approved main-menu wallpaper's foreground terrain.
    internal static readonly Color ButtonFill = new Color32(90, 77, 61, 255);
    internal static readonly Color ButtonBorder = new Color32(235, 211, 143, 255);
    internal const float ButtonBorderWidth = 2f;
    public enum Surface { Frame, Panel, Button, Row, Header, Inset, PickButton, DropdownOption, ArrowButton, ReadyGlow }
    private Surface surface;
    private bool highlighted;
    private bool disabled;
    private bool transparentFill;
    private bool blackButtons = true;

    internal bool BlackButtons
    {
        get => blackButtons;
        set { if (blackButtons != value) { blackButtons = value; SetVerticesDirty(); } }
    }

    public void Configure(Surface kind, bool highlight = false, bool inactive = false, bool clearFill = false)
    {
        if (surface == kind && highlighted == highlight && disabled == inactive && transparentFill == clearFill) return;
        surface = kind;
        highlighted = highlight;
        disabled = inactive;
        transparentFill = clearFill;
        SetVerticesDirty();
    }

    protected override void Awake() { base.Awake(); raycastTarget = false; }

    protected override void OnPopulateMesh(VertexHelper mesh)
    {
        Populate(mesh, GetPixelAdjustedRect(), surface, highlighted, disabled, transparentFill, color, blackButtons);
    }

    // Preserve the generic Chamfer fallback palette. Only front-end plates
    // created by the menu/lobby skins use the terrain-brown and gold palette.
    internal static void PopulateGoldButton(VertexHelper mesh, Rect bounds, Color tint, bool selected = false)
        => Populate(mesh, bounds, Surface.Button, selected, false, false, tint, false);

    private static void Populate(VertexHelper mesh, Rect bounds, Surface surface,
        bool highlighted, bool disabled, bool transparentFill, Color tint, bool blackButtons = true)
    {
        mesh.Clear();
        if (bounds.width < .1f || bounds.height < .1f) return;
        if (surface == Surface.ReadyGlow)
        {
            float halo = Mathf.Min(8f, Mathf.Min(bounds.width, bounds.height) * .25f);
            GlowRing(mesh, bounds, halo, halo + 7f, new Color32(249, 219, 131, 0), new Color32(249, 219, 131, 128), tint);
            return;
        }
        if (surface == Surface.Button || surface == Surface.PickButton)
        {
            float cut = Mathf.Min(surface == Surface.PickButton ? 4f : 5f, Mathf.Min(bounds.width, bounds.height) * .20f);
            Color fill = disabled ? new Color32(174, 157, 116, 255) :
                highlighted ? new Color32(218, 196, 140, 255) : new Color32(202, 178, 112, 255);
            Color edge = disabled ? new Color32(118, 104, 73, 255) : new Color32(113, 91, 43, 255);
            if (blackButtons)
            {
                fill = ButtonFill;
                edge = highlighted ? new Color32(251, 230, 166, 255) : ButtonBorder;
            }
            float rim = blackButtons ? ButtonBorderWidth : 1f;
            // Native disabled/pressed face tint must not dim the gold outline.
            Color rimTint = blackButtons ? new Color(1, 1, 1, tint.a) : tint;
            Ring(mesh, bounds, 0, rim, cut, edge, edge, rimTint);
            if (!transparentFill)
                Fan(mesh, Inset(bounds, rim), Mathf.Max(0, cut - rim), fill, fill, tint);
            return;
        }
        if (surface == Surface.DropdownOption || surface == Surface.ArrowButton)
        {
            // Faction artwork stays intact on the same flat terrain tone as
            // action buttons. Hover changes the gold rim, never the fill.
            float cut = Mathf.Min(3, Mathf.Min(bounds.width, bounds.height) * .2f);
            Color edge = ButtonBorder;
            Color fill = ButtonFill;
            if (highlighted) edge = new Color32(251, 230, 166, 255);
            Ring(mesh, bounds, 0, ButtonBorderWidth, cut, edge, edge, new Color(1, 1, 1, tint.a));
            Fan(mesh, Inset(bounds, ButtonBorderWidth), Mathf.Max(0, cut - ButtonBorderWidth), fill, fill, tint);
            return;
        }
        float depth = surface == Surface.Frame ? 8f : surface == Surface.Panel ? 3.5f : surface == Surface.Header ? 2.8f : 1.9f;
        depth = Mathf.Min(depth, Mathf.Min(bounds.width, bounds.height) * .20f);
        float chamfer = surface == Surface.Frame ? 14f : 3f;
        chamfer = Mathf.Min(chamfer, Mathf.Min(bounds.width, bounds.height) * .25f);
        Color pale = new Color32(255, 249, 225, 255);
        Color steel = new Color32(215, 187, 112, 255);
        Color dark = new Color32(35, 32, 22, 255);
        if (highlighted) { pale = Color.white; steel = new Color32(247, 226, 157, 255); }
        if (disabled) { pale = new Color32(153, 146, 123, 255); steel = new Color32(111, 100, 64, 255); }

        Ring(mesh, bounds, 0, depth * .13f, chamfer, dark, Color.black, tint);
        Ring(mesh, bounds, depth * .13f, depth * .38f, chamfer, pale, steel, tint);
        Ring(mesh, bounds, depth * .38f, depth * .63f, chamfer, steel, dark, tint);
        Ring(mesh, bounds, depth * .63f, depth * .83f, chamfer, new Color32(68, 59, 31, 255), pale, tint);
        Ring(mesh, bounds, depth * .83f, depth, chamfer, new Color32(244, 226, 168, 255), new Color32(145, 122, 57, 255), tint);

        if (!transparentFill)
        {
            Color top = surface == Surface.Row ? new Color32(52, 43, 31, 255) : new Color32(46, 37, 26, 255);
            Color bottom = surface == Surface.Row ? new Color32(31, 25, 19, 255) : new Color32(22, 18, 13, 255);
            if (surface == Surface.Frame) { top = new Color32(58, 47, 33, 252); bottom = new Color32(30, 25, 19, 252); }
            if (surface == Surface.Header) { top = new Color32(76, 67, 40, 255); bottom = new Color32(40, 36, 25, 255); }
            if (highlighted) { top = Color.Lerp(top, Color.white, .25f); bottom = Color.Lerp(bottom, new Color32(247, 226, 157, 255), .30f); }
            if (disabled) { top *= .70f; bottom *= .70f; top.a = bottom.a = 1; }
            Fan(mesh, Inset(bounds, depth), Mathf.Max(0, chamfer - depth), top, bottom, tint);
        }
    }

    private static Rect Inset(Rect rect, float amount) => Rect.MinMaxRect(rect.xMin + amount, rect.yMin + amount, rect.xMax - amount, rect.yMax - amount);

    private static void GlowRing(VertexHelper mesh, Rect bounds, float width, float cut, Color outerColor, Color innerColor, Color tint)
    {
        Rect inner = Inset(bounds, width);
        if (inner.width <= 0 || inner.height <= 0) return;
        int start = mesh.currentVertCount;
        for (int i = 0; i < 8; i++) mesh.AddVert(Point(bounds, cut, i), outerColor * tint, Vector2.zero);
        for (int i = 0; i < 8; i++) mesh.AddVert(Point(inner, Mathf.Max(0, cut - width), i), innerColor * tint, Vector2.zero);
        for (int i = 0; i < 8; i++)
        {
            int next = (i + 1) % 8;
            mesh.AddTriangle(start + i, start + next, start + 8 + next);
            mesh.AddTriangle(start + i, start + 8 + next, start + 8 + i);
        }
    }

    private static Vector2 Point(Rect r, float cut, int index)
    {
        cut = Mathf.Clamp(cut, 0, Mathf.Min(r.width, r.height) * .5f);
        switch (index)
        {
            case 0: return new Vector2(r.xMin + cut, r.yMin);
            case 1: return new Vector2(r.xMax - cut, r.yMin);
            case 2: return new Vector2(r.xMax, r.yMin + cut);
            case 3: return new Vector2(r.xMax, r.yMax - cut);
            case 4: return new Vector2(r.xMax - cut, r.yMax);
            case 5: return new Vector2(r.xMin + cut, r.yMax);
            case 6: return new Vector2(r.xMin, r.yMax - cut);
            default: return new Vector2(r.xMin, r.yMin + cut);
        }
    }

    private static Color Shade(Rect rect, Vector2 point, Color top, Color bottom, Color tint)
        => Color.Lerp(bottom, top, Mathf.InverseLerp(rect.yMin, rect.yMax, point.y)) * tint;

    private static void Ring(VertexHelper mesh, Rect bounds, float outerInset, float innerInset, float cut, Color top, Color bottom, Color tint)
    {
        Rect outer = Inset(bounds, outerInset);
        Rect inner = Inset(bounds, innerInset);
        if (inner.width <= 0 || inner.height <= 0) return;
        int start = mesh.currentVertCount;
        for (int i = 0; i < 8; i++)
        {
            Vector2 point = Point(outer, Mathf.Max(0, cut - outerInset), i);
            mesh.AddVert(point, Shade(bounds, point, top, bottom, tint), Vector2.zero);
        }
        for (int i = 0; i < 8; i++)
        {
            Vector2 point = Point(inner, Mathf.Max(0, cut - innerInset), i);
            mesh.AddVert(point, Shade(bounds, point, top, bottom, tint), Vector2.zero);
        }
        for (int i = 0; i < 8; i++)
        {
            int next = (i + 1) % 8;
            mesh.AddTriangle(start + i, start + next, start + 8 + next);
            mesh.AddTriangle(start + i, start + 8 + next, start + 8 + i);
        }
    }

    private static void Fan(VertexHelper mesh, Rect rect, float cut, Color top, Color bottom, Color tint)
    {
        if (rect.width <= 0 || rect.height <= 0) return;
        int start = mesh.currentVertCount;
        for (int i = 0; i < 8; i++)
        {
            Vector2 point = Point(rect, cut, i);
            mesh.AddVert(point, Shade(rect, point, top, bottom, tint), Vector2.zero);
        }
        for (int i = 1; i < 7; i++) mesh.AddTriangle(start, start + i, start + i + 1);
    }
}
