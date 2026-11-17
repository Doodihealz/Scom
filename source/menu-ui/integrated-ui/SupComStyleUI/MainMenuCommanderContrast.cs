using UnityEngine;
using UnityEngine.UI;

namespace SupComStyleUI;

// A soft, cool shadow in the background beside the commander. The source
// artwork stays unchanged, and a conservative silhouette keeps the armor bright.
// This lives below the lobby image so it participates in the same crossfade.
internal sealed class MainMenuCommanderContrast : MaskableGraphic
{
    private ScomMenuBackdrop picture;
    private const float ArtworkWidth = 1938f;
    private const float ArtworkHeight = 811f;
    private static readonly Vector2[] Silhouette =
    {
        new Vector2(741, 72), new Vector2(759, 14), new Vector2(791, 57),
        new Vector2(811, -12), new Vector2(864, 30), new Vector2(931, 29),
        new Vector2(1016, -12), new Vector2(1050, 80), new Vector2(1051, 137),
        new Vector2(1044, 189), new Vector2(1074, 208), new Vector2(1082, 248),
        new Vector2(1124, 338), new Vector2(1082, 350), new Vector2(1008, 309),
        new Vector2(986, 372), new Vector2(986, 555), new Vector2(807, 562),
        new Vector2(795, 478), new Vector2(804, 371), new Vector2(783, 332),
        new Vector2(766, 289), new Vector2(762, 238), new Vector2(735, 228),
        new Vector2(735, 161), new Vector2(742, 111)
    };

    public static void Create(RectTransform parent, ScomMenuBackdrop artwork)
    {
        var rect = LobbyControls.Rect("SCOM Commander Background Contrast", parent, 0, 0, 0, 0);
        rect.gameObject.layer = parent.gameObject.layer;
        LobbyControls.Stretch(rect);
        rect.SetAsFirstSibling();
        rect.gameObject.AddComponent<LayoutElement>().ignoreLayout = true;
        var graphic = rect.gameObject.AddComponent<MainMenuCommanderContrast>();
        graphic.picture = artwork;
        graphic.raycastTarget = false;
        graphic.SetVerticesDirty();
    }

    protected override void Awake()
    {
        base.Awake();
        raycastTarget = false;
    }

    protected override void OnPopulateMesh(VertexHelper mesh)
    {
        mesh.Clear();
        if (picture == null || picture.texture == null) return;
        Rect rect = GetPixelAdjustedRect();
        Rect uv = picture.uvRect;
        if (rect.width <= 0 || rect.height <= 0 || uv.width <= 0 || uv.height <= 0) return;

        // Coordinates follow the source image rather than screen proportions,
        // including FitCover cropping on narrow and ultrawide displays.
        const int columns = 96, rows = 64;
        const float left = 535, right = 1310, top = 0, bottom = 540;
        for (int y = 0; y <= rows; y++)
        {
            float sourceY = Mathf.Lerp(top, bottom, (float)y / rows);
            for (int x = 0; x <= columns; x++)
            {
                float sourceX = Mathf.Lerp(left, right, (float)x / columns);
                float distance = OutsideDistance(new Vector2(sourceX, sourceY));
                // Leave the silhouette and a small antialiasing guard untouched.
                float near = Mathf.SmoothStep(0, 1, Mathf.Clamp01((distance - 2f) / 20f));
                float far = 1f - Mathf.SmoothStep(0, 1, Mathf.Clamp01(distance / 165f));
                float vertical = 1f - Mathf.SmoothStep(0, 1, Mathf.InverseLerp(280, bottom, sourceY));
                byte alpha = (byte)Mathf.RoundToInt(near * far * vertical * 48f);
                float px = rect.xMin + (sourceX / ArtworkWidth - uv.xMin) / uv.width * rect.width;
                float py = rect.yMin + (1f - sourceY / ArtworkHeight - uv.yMin) / uv.height * rect.height;
                mesh.AddVert(new Vector2(px, py), new Color32(17, 27, 41, alpha), Vector2.zero);
            }
        }
        for (int y = 0; y < rows; y++)
            for (int x = 0; x < columns; x++)
            {
                int a = y * (columns + 1) + x;
                mesh.AddTriangle(a, a + columns + 1, a + 1);
                mesh.AddTriangle(a + 1, a + columns + 1, a + columns + 2);
            }
    }

    private static float OutsideDistance(Vector2 point)
    {
        bool inside = false;
        float squared = float.MaxValue;
        for (int i = 0, previous = Silhouette.Length - 1; i < Silhouette.Length; previous = i++)
        {
            Vector2 a = Silhouette[previous], b = Silhouette[i];
            if ((a.y > point.y) != (b.y > point.y) &&
                point.x < (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x)
                inside = !inside;
            Vector2 edge = b - a;
            float fraction = edge.sqrMagnitude > 0 ? Mathf.Clamp01(Vector2.Dot(point - a, edge) / edge.sqrMagnitude) : 0;
            squared = Mathf.Min(squared, (point - a - edge * fraction).sqrMagnitude);
        }
        return inside ? 0 : Mathf.Sqrt(squared);
    }
}
