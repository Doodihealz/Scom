using TMPro;
using UnityEngine;
using Object = UnityEngine.Object;

namespace SupComStyleUI;

// Native text preserves the live background and centered branding.
// The embedded opaque GIF is the unchanged visual/timing reference, not a UI plane.
internal sealed class MainMenuTextShine : MonoBehaviour
{
    private const float Cycle = 3f;
    private const float LeadPause = .36f;
    private const float FrameTime = .03f;
    private const int SweepFrames = 53;
    private TMP_Text source;
    private TextMeshProUGUI overlay;
    private Material ownedMaterial;
    private float elapsed;
    private int sample = -1;
    private bool meshReady;

    public void Bind(TMP_Text caption)
    {
        if (source == caption && overlay != null) return;
        Release();
        source = caption;
        if (source == null || source.font == null || source.fontSharedMaterial == null) return;

        var created = new GameObject("SCOM Subtitle Shine", typeof(RectTransform));
        created.SetActive(false);
        created.layer = source.gameObject.layer;
        var rect = (RectTransform)created.transform;
        rect.SetParent(source.transform.parent, false);
        var original = source.rectTransform;
        rect.anchorMin = original.anchorMin;
        rect.anchorMax = original.anchorMax;
        rect.pivot = original.pivot;
        rect.anchoredPosition = original.anchoredPosition;
        rect.sizeDelta = original.sizeDelta;
        rect.localScale = original.localScale;
        rect.localRotation = original.localRotation;
        rect.SetAsLastSibling();

        ownedMaterial = new Material(source.fontSharedMaterial)
        {
            name = "SCOM Subtitle Shine Material",
            hideFlags = HideFlags.HideAndDontSave
        };
        SetColor("_FaceColor", Color.white);
        SetColor("_OutlineColor", new Color(1f, .94f, .74f, .85f));
        SetFloat("_OutlineWidth", .12f);
        SetFloat("_OutlineSoftness", .12f);
        // Some native font shaders omit glow. A bright soft outline still gives
        // white letters a visible traveling highlight with those shaders.
        if (ownedMaterial.HasProperty("_GlowColor"))
        {
            ownedMaterial.EnableKeyword("GLOW_ON");
            SetColor("_GlowColor", new Color(1f, .92f, .64f, .85f));
            SetFloat("_GlowOffset", .02f);
            SetFloat("_GlowInner", .03f);
            SetFloat("_GlowOuter", .25f);
            SetFloat("_GlowPower", .45f);
        }

        overlay = created.AddComponent<TextMeshProUGUI>();
        overlay.font = source.font;
        overlay.fontSharedMaterial = ownedMaterial;
        overlay.text = source.text;
        overlay.richText = source.richText;
        overlay.overrideColorTags = true;
        overlay.fontStyle = source.fontStyle & ~FontStyles.Underline;
        overlay.fontWeight = source.fontWeight;
        overlay.fontSize = source.fontSize;
        overlay.fontSizeMin = source.fontSizeMin;
        overlay.fontSizeMax = source.fontSizeMax;
        overlay.enableAutoSizing = source.enableAutoSizing;
        overlay.alignment = source.alignment;
        overlay.textWrappingMode = source.textWrappingMode;
        overlay.overflowMode = source.overflowMode;
        overlay.margin = source.margin;
        overlay.characterSpacing = source.characterSpacing;
        overlay.wordSpacing = source.wordSpacing;
        overlay.lineSpacing = source.lineSpacing;
        overlay.paragraphSpacing = source.paragraphSpacing;
        overlay.color = Color.white;
        overlay.enableVertexGradient = false;
        overlay.extraPadding = true;
        overlay.raycastTarget = false;
        overlay.maskable = false;
        overlay.OnPreRenderText += OnMeshReady;
        elapsed = 0;
        sample = -1;
        meshReady = false;
    }

    private void SetFloat(string property, float value)
    {
        if (ownedMaterial.HasProperty(property)) ownedMaterial.SetFloat(property, value);
    }

    private void SetColor(string property, Color value)
    {
        if (ownedMaterial.HasProperty(property)) ownedMaterial.SetColor(property, value);
    }

    private void Update()
    {
        if (source == null || overlay == null) return;
        bool visible = source.isActiveAndEnabled && source.canvas != null && source.canvas.enabled &&
            source.canvasRenderer.GetInheritedAlpha() > .001f;
        if (!visible)
        {
            HideOverlay();
            return;
        }

        elapsed = (elapsed + Time.unscaledDeltaTime) % Cycle;
        float sweepTime = elapsed - LeadPause;
        if (sweepTime < 0 || sweepTime >= SweepFrames * FrameTime)
        {
            HideOverlay();
            return;
        }

        int next = Mathf.Clamp(Mathf.FloorToInt(sweepTime / FrameTime), 0, SweepFrames - 1);
        if (!overlay.gameObject.activeSelf)
        {
            sample = next;
            meshReady = false;
            overlay.gameObject.SetActive(true);
            overlay.ForceMeshUpdate();
        }
        if (sample == next && meshReady) return;
        sample = next;
        if (!meshReady || overlay.havePropertiesChanged) overlay.ForceMeshUpdate();
        ApplyBand(overlay.textInfo);
        overlay.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);
    }

    private void OnMeshReady(TMP_TextInfo info)
    {
        meshReady = true;
        ApplyBand(info);
    }

    private void ApplyBand(TMP_TextInfo info)
    {
        if (sample < 0 || info == null || info.characterCount == 0) return;
        float left = float.PositiveInfinity, right = float.NegativeInfinity;
        float bottom = float.PositiveInfinity, top = float.NegativeInfinity;
        for (int index = 0; index < info.characterCount; index++)
        {
            var glyph = info.characterInfo[index];
            if (!glyph.isVisible) continue;
            left = Mathf.Min(left, glyph.bottomLeft.x);
            right = Mathf.Max(right, glyph.topRight.x);
            bottom = Mathf.Min(bottom, glyph.bottomLeft.y);
            top = Mathf.Max(top, glyph.topRight.y);
        }
        float width = right - left;
        if (!(width > 0)) return;
        // The reference has a roughly 66px band across 441px of lettering.
        float halfBand = width * .075f;
        float center = Mathf.Lerp(left - width * .105f, right + width * .09f, (float)sample / (SweepFrames - 1));
        float middle = (bottom + top) * .5f;
        for (int materialIndex = 0; materialIndex < info.meshInfo.Length; materialIndex++)
        {
            var mesh = info.meshInfo[materialIndex];
            for (int vertex = 0; vertex < mesh.vertexCount; vertex++)
            {
                Vector3 point = mesh.vertices[vertex];
                float distance = Mathf.Abs(point.x + (point.y - middle) * .22f - center);
                float weight = Mathf.Clamp01(1f - distance / halfBand);
                weight = weight * weight * (3f - 2f * weight);
                mesh.colors32[vertex] = new Color32(255, 253, 234, (byte)Mathf.RoundToInt(weight * 235));
            }
        }
    }

    private void HideOverlay()
    {
        if (overlay != null && overlay.gameObject.activeSelf) overlay.gameObject.SetActive(false);
        sample = -1;
        meshReady = false;
    }

    private void OnDisable()
    {
        elapsed = 0;
        HideOverlay();
    }

    private void OnDestroy() => Release();

    private void Release()
    {
        if (overlay != null)
        {
            overlay.OnPreRenderText -= OnMeshReady;
            overlay.gameObject.SetActive(false);
            Object.Destroy(overlay.gameObject);
            overlay = null;
        }
        if (ownedMaterial != null) { Object.Destroy(ownedMaterial); ownedMaterial = null; }
        source = null;
        meshReady = false;
    }
}
