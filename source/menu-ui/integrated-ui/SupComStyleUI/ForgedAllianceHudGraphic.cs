using UnityEngine;
using UnityEngine.UI;

namespace SupComStyleUI;

// Untextured steel HUD chrome. This is deliberately independent of the gold
// front-end/lobby material so changing the in-game HUD leaves those menus alone.
[AddComponentMenu("UI/SupCom/Forged Alliance HUD Graphic")]
public sealed class ForgedAllianceHudGraphic : MaskableGraphic
{
    private Color fillColor = new Color32(12, 19, 20, 222);
    private Color borderColor = new Color32(166, 200, 201, 255);
    private float corner = 10f;
    private bool button;
    private bool selected;

    public Color FillColor { get => fillColor; set { if (fillColor != value) { fillColor = value; SetVerticesDirty(); } } }
    public Color BorderColor { get => borderColor; set { if (borderColor != value) { borderColor = value; SetVerticesDirty(); } } }
    public float Corner { get => corner; set { value = Mathf.Max(0, value); if (corner != value) { corner = value; SetVerticesDirty(); } } }
    public bool IsButton { get => button; set { if (button != value) { button = value; SetVerticesDirty(); } } }
    public bool IsSelected { get => selected; set { if (selected != value) { selected = value; SetVerticesDirty(); } } }

    public void Configure(Color fill, Color border, float corner = 10f, bool button = false, bool selected = false)
    {
        float cut = Mathf.Max(0, corner);
        if (fillColor == fill && borderColor == border && this.corner == cut && this.button == button && this.selected == selected) return;
        fillColor = fill;
        borderColor = border;
        this.corner = cut;
        this.button = button;
        this.selected = selected;
        SetVerticesDirty();
    }

    protected override void Awake()
    {
        base.Awake();
        raycastTarget = false;
    }

    protected override void OnPopulateMesh(VertexHelper mesh)
        => Populate(mesh, GetPixelAdjustedRect(), fillColor, borderColor, corner, button, selected, color);

    // Shared by HUD plates and existing selectable skins. Native controls retain
    // their hit targets; disabled tint dims the rim while faces stay readable.
    public static void Populate(VertexHelper mesh, Rect bounds, Color fill, Color border, float corner, bool button, bool selected, Color? tint = null)
    {
        mesh.Clear();
        if (bounds.width <= .01f || bounds.height <= .01f ||
            float.IsNaN(bounds.width) || float.IsNaN(bounds.height)) return;

        float shortest = Mathf.Min(bounds.width, bounds.height);
        Color stateTint = tint ?? Color.white;
        if (stateTint.a <= 0) return;
        if (button)
        {
            Button(mesh, bounds, fill, border, corner, selected, stateTint);
            return;
        }
        float depth = Mathf.Min(6f, shortest * .20f);
        float cut = Mathf.Min(Mathf.Max(0, corner), shortest * .22f);
        fill.a = Mathf.Min(fill.a, .98f);
        fill *= stateTint;
        float alpha = Mathf.Clamp01(border.a * stateTint.a * .88f);
        Color rgbTint = new Color(stateTint.r, stateTint.g, stateTint.b, 1f);
        Color black = WithAlpha(new Color32(4, 8, 9, 255), alpha) * rgbTint;
        Color darkSteel = WithAlpha(new Color32(39, 51, 54, 255), alpha) * rgbTint;
        Color midSteel = WithAlpha(new Color32(100, 120, 123, 255), alpha) * rgbTint;
        Color lightSteel = WithAlpha(new Color32(192, 207, 207, 255), alpha) * rgbTint;
        Color whiteSteel = WithAlpha(new Color32(231, 242, 239, 255), alpha) * rgbTint;
        Color accent = Color.Lerp(new Color32(168, 213, 213, 255), border, .30f);
        accent.a = alpha * .65f;
        if (selected) accent = WithAlpha(new Color32(153, 240, 247, 255), alpha * .90f);
        accent *= rgbTint;

        // One silver shoulder and a quiet inner accent give a mechanical edge
        // without a stack of alternating bright outlines around every plate.
        Ring(mesh, bounds, 0, depth * .16f, cut, darkSteel, black, black, black);
        Ring(mesh, bounds, depth * .16f, depth * .65f, cut, whiteSteel, midSteel, lightSteel, darkSteel);
        Ring(mesh, bounds, depth * .65f, depth * .80f, cut, accent, accent, accent, accent);
        Ring(mesh, bounds, depth * .80f, depth, cut, darkSteel, black, black, black);

        Rect inside = Inset(bounds, depth);
        if (inside.width > 0 && inside.height > 0)
        {
            Color top = Color.Lerp(fill, new Color(.18f, .22f, .23f, fill.a), .08f);
            Color bottom = Color.Lerp(fill, new Color(.025f, .045f, .05f, fill.a), .20f);
            if (selected)
            {
                top = Color.Lerp(top, new Color(.23f, .40f, .43f, fill.a), .32f);
                bottom = Color.Lerp(bottom, new Color(.07f, .18f, .20f, fill.a), .22f);
            }
            Fan(mesh, inside, Mathf.Max(0, cut - depth), top, bottom);
        }

        // Restrained fasteners belong on larger chassis plates, never on tiny
        // command icons. Their positions stay in the rim and outside content.
        if (bounds.width >= 115f && bounds.height >= 54f && depth >= 4f)
        {
            float screwRadius = Mathf.Min(1.65f, depth * .23f);
            float edge = depth * .43f;
            float xInset = Mathf.Max(cut + 3f, depth + 3f);
            Screw(mesh, new Vector2(bounds.xMin + xInset, bounds.yMax - edge), screwRadius, alpha);
            Screw(mesh, new Vector2(bounds.xMax - xInset, bounds.yMax - edge), screwRadius, alpha);
            Screw(mesh, new Vector2(bounds.xMin + xInset, bounds.yMin + edge), screwRadius, alpha);
            Screw(mesh, new Vector2(bounds.xMax - xInset, bounds.yMin + edge), screwRadius, alpha);
        }
    }

    private static void Button(VertexHelper mesh, Rect bounds, Color fill, Color border, float corner, bool selected, Color tint)
    {
        float shortest = Mathf.Min(bounds.width, bounds.height);
        float depth = Mathf.Min(1.9f, shortest * .11f);
        // Command tiles are squared controls, not miniature chassis plates.
        // Keep their corners and bevel small enough that the glyph owns the face.
        float cut = Mathf.Min(Mathf.Clamp(corner, 0, 4f), shortest * .12f);
        float alpha = Mathf.Clamp01(border.a * tint.a);
        Color rgbTint = new Color(tint.r, tint.g, tint.b, 1);
        Color edge = WithAlpha(new Color32(4, 8, 10, 255), alpha) * rgbTint;
        Color shoulderTop = WithAlpha(new Color32(188, 205, 208, 255), alpha * .88f) * rgbTint;
        Color shoulderBottom = WithAlpha(new Color32(72, 91, 97, 255), alpha * .90f) * rgbTint;
        Color accent = selected ? new Color32(155, 227, 235, 255) : new Color32(116, 167, 178, 255);
        accent = Color.Lerp(accent, border, selected ? .08f : .16f);
        accent.a = alpha * (selected ? .95f : .68f);
        accent *= rgbTint;

        Ring(mesh, bounds, 0, depth * .32f, cut, edge, edge, edge, edge);
        Ring(mesh, bounds, depth * .32f, depth * .72f, cut, shoulderTop, shoulderBottom, shoulderTop, shoulderBottom);
        Ring(mesh, bounds, depth * .72f, depth, cut, accent, accent, accent, accent);

        Rect inside = Inset(bounds, depth);
        if (inside.width <= 0 || inside.height <= 0) return;
        // Deliberately keep a near-black face rather than deriving a pale teal
        // button body from its border or native control tint.
        // Disabled Selectable alpha is state feedback, not a request to reveal
        // terrain through the control. Whole-HUD fades belong to CanvasGroup;
        // an explicit zero graphic tint is handled by Populate's early return.
        float bodyAlpha = Mathf.Clamp(fill.a, .96f, .98f);
        Color top = WithAlpha(selected ? new Color32(20, 37, 42, 255) : new Color32(13, 20, 23, 255), bodyAlpha) * rgbTint;
        Color bottom = WithAlpha(selected ? new Color32(10, 24, 29, 255) : new Color32(6, 11, 14, 255), bodyAlpha) * rgbTint;
        Fan(mesh, inside, Mathf.Max(0, cut - depth), top, bottom);
    }

    private static Color WithAlpha(Color value, float alpha) { value.a = alpha; return value; }
    private static Rect Inset(Rect rect, float inset)
        => Rect.MinMaxRect(rect.xMin + inset, rect.yMin + inset, rect.xMax - inset, rect.yMax - inset);

    private static Vector2 Point(Rect rect, float cut, int index)
    {
        cut = Mathf.Clamp(cut, 0, Mathf.Min(rect.width, rect.height) * .5f);
        switch (index)
        {
            case 0: return new Vector2(rect.xMin + cut, rect.yMin);
            case 1: return new Vector2(rect.xMax - cut, rect.yMin);
            case 2: return new Vector2(rect.xMax, rect.yMin + cut);
            case 3: return new Vector2(rect.xMax, rect.yMax - cut);
            case 4: return new Vector2(rect.xMax - cut, rect.yMax);
            case 5: return new Vector2(rect.xMin + cut, rect.yMax);
            case 6: return new Vector2(rect.xMin, rect.yMax - cut);
            default: return new Vector2(rect.xMin, rect.yMin + cut);
        }
    }

    private static Color Shade(Rect bounds, Vector2 point, Color top, Color bottom)
        => Color.Lerp(bottom, top, Mathf.InverseLerp(bounds.yMin, bounds.yMax, point.y));

    private static void Ring(VertexHelper mesh, Rect bounds, float outerInset, float innerInset, float cut,
        Color outerTop, Color outerBottom, Color innerTop, Color innerBottom)
    {
        Rect outer = Inset(bounds, outerInset), inner = Inset(bounds, innerInset);
        if (inner.width <= 0 || inner.height <= 0) return;
        int start = mesh.currentVertCount;
        for (int i = 0; i < 8; i++)
        {
            Vector2 point = Point(outer, Mathf.Max(0, cut - outerInset), i);
            mesh.AddVert(point, Shade(bounds, point, outerTop, outerBottom), Vector2.zero);
        }
        for (int i = 0; i < 8; i++)
        {
            Vector2 point = Point(inner, Mathf.Max(0, cut - innerInset), i);
            mesh.AddVert(point, Shade(bounds, point, innerTop, innerBottom), Vector2.zero);
        }
        for (int i = 0; i < 8; i++)
        {
            int next = (i + 1) % 8;
            mesh.AddTriangle(start + i, start + next, start + 8 + next);
            mesh.AddTriangle(start + i, start + 8 + next, start + 8 + i);
        }
    }

    private static void Fan(VertexHelper mesh, Rect rect, float cut, Color top, Color bottom)
    {
        int start = mesh.currentVertCount;
        for (int i = 0; i < 8; i++)
        {
            Vector2 point = Point(rect, cut, i);
            mesh.AddVert(point, Shade(rect, point, top, bottom), Vector2.zero);
        }
        for (int i = 1; i < 7; i++) mesh.AddTriangle(start, start + i, start + i + 1);
    }

    private static void Screw(VertexHelper mesh, Vector2 center, float radius, float alpha)
    {
        Disc(mesh, center, radius, WithAlpha(new Color32(14, 23, 25, 255), alpha));
        Disc(mesh, center + new Vector2(-.25f, .3f), radius * .53f, WithAlpha(new Color32(125, 145, 145, 255), alpha));
        float half = radius * .48f, thin = Mathf.Max(.32f, radius * .16f);
        Quad(mesh, new Rect(center.x - half, center.y - thin, half * 2, thin * 2), WithAlpha(new Color32(20, 30, 32, 255), alpha));
    }

    private static void Disc(VertexHelper mesh, Vector2 center, float radius, Color color)
    {
        int start = mesh.currentVertCount;
        mesh.AddVert(center, color, Vector2.zero);
        for (int i = 0; i < 8; i++)
        {
            float angle = i * Mathf.PI * .25f;
            mesh.AddVert(center + new Vector2(Mathf.Cos(angle), Mathf.Sin(angle)) * radius, color, Vector2.zero);
        }
        for (int i = 0; i < 8; i++) mesh.AddTriangle(start, start + 1 + i, start + 1 + (i + 1) % 8);
    }

    private static void Quad(VertexHelper mesh, Rect rect, Color color)
    {
        int start = mesh.currentVertCount;
        mesh.AddVert(new Vector2(rect.xMin, rect.yMin), color, Vector2.zero);
        mesh.AddVert(new Vector2(rect.xMax, rect.yMin), color, Vector2.zero);
        mesh.AddVert(new Vector2(rect.xMax, rect.yMax), color, Vector2.zero);
        mesh.AddVert(new Vector2(rect.xMin, rect.yMax), color, Vector2.zero);
        mesh.AddTriangle(start, start + 1, start + 2);
        mesh.AddTriangle(start, start + 2, start + 3);
    }
}
