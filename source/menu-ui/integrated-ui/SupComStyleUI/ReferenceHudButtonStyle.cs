using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace SupComStyleUI;

/// <summary>
/// Decodes Sanctuary's UI/ButtonIconGlow red-mask sprites for ordinary UI
/// rendering. This is deliberately opt-in for order/filter glyphs; it must not
/// be applied to unit portraits or other ordinary color sprites.
/// </summary>
internal static class ReferenceHudButtonStyle
{
    private sealed class DecodedGlyph
    {
        public Texture2D texture;
        public Sprite sprite;
    }

    private static readonly Dictionary<int, DecodedGlyph> decodedBySource = new Dictionary<int, DecodedGlyph>();
    private static readonly HashSet<int> decodedSpriteIds = new HashSet<int>();
    private static readonly HashSet<int> packedImageIds = new HashSet<int>();
    private static readonly Dictionary<int, Material> nativePackedMaterials = new Dictionary<int, Material>();
    private static readonly HashSet<int> failedSpriteIds = new HashSet<int>();

    public static string LastError { get; private set; } = string.Empty;

    /// <summary>
    /// Call only after capturing the Graphic's native state. Native SetIcon can
    /// replace its sprite later; call again from that postfix to decode it.
    /// Color, alpha, selectable state and every native callback are untouched.
    /// </summary>
    public static bool DecodeOrderGlyph(Image glyph)
    {
        if (glyph == null || glyph.sprite == null) return false;
        int spriteId = glyph.sprite.GetInstanceID();
        if (decodedSpriteIds.Contains(spriteId))
        {
            glyph.material = null;
            return true;
        }
        int imageId = glyph.GetInstanceID();
        if (!packedImageIds.Contains(imageId))
        {
            Material material = glyph.material;
            if (material == null || material.shader == null ||
                !string.Equals(material.shader.name, "UI/ButtonIconGlow", StringComparison.Ordinal))
            {
                return false;
            }
            packedImageIds.Add(imageId);
            nativePackedMaterials[imageId] = material;
        }
        if (failedSpriteIds.Contains(spriteId))
        {
            RestorePackedMaterial(glyph, imageId);
            return false;
        }
        try
        {
            if (!decodedBySource.TryGetValue(spriteId, out DecodedGlyph decoded))
            {
                decoded = Decode(glyph.sprite);
                decodedBySource.Add(spriteId, decoded);
                decodedSpriteIds.Add(decoded.sprite.GetInstanceID());
            }
            Color nativeColor = glyph.color;
            glyph.sprite = decoded.sprite;
            glyph.material = null;
            glyph.color = nativeColor;
            glyph.SetMaterialDirty();
            glyph.SetVerticesDirty();
            LastError = string.Empty;
            return true;
        }
        catch (Exception ex)
        {
            RestorePackedMaterial(glyph, imageId);
            failedSpriteIds.Add(spriteId);
            LastError = "The native order glyph could not be decoded: " + ex.Message;
            if (LastError.Length > 320) LastError = LastError.Substring(0, 320);
            return false;
        }
    }

    private static void RestorePackedMaterial(Image glyph, int imageId)
    {
        if (nativePackedMaterials.TryGetValue(imageId, out Material nativeMaterial) && nativeMaterial != null)
            glyph.material = nativeMaterial;
    }

    private static DecodedGlyph Decode(Sprite sourceSprite)
    {
        if (sourceSprite.packed && sourceSprite.packingRotation != SpritePackingRotation.None)
            throw new InvalidOperationException("Rotated sprite atlases are not supported.");
        Rect sourceRect = sourceSprite.textureRect;
        Texture2D sourceTexture = sourceSprite.texture;
        if (sourceTexture == null || sourceRect.width < 1f || sourceRect.height < 1f)
            throw new InvalidOperationException("The native glyph has no texture rectangle.");
        int width = Mathf.RoundToInt(sourceRect.width);
        int height = Mathf.RoundToInt(sourceRect.height);
        if (width > 1024 || height > 1024)
            throw new InvalidOperationException("The native glyph exceeds the supported texture size.");

        Texture2D readback = null;
        Texture2D decodedTexture = null;
        RenderTexture temporary = null;
        RenderTexture previous = RenderTexture.active;
        try
        {
            // Runtime gamedata DDS textures are usually unreadable. A one-time
            // GPU copy lets us decode exactly the red channel of this sprite,
            // without assuming its backing texture is CPU-readable or unatlased.
            temporary = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
            Vector2 scale = new Vector2(sourceRect.width / sourceTexture.width, sourceRect.height / sourceTexture.height);
            Vector2 offset = new Vector2(sourceRect.x / sourceTexture.width, sourceRect.y / sourceTexture.height);
            Graphics.Blit(sourceTexture, temporary, scale, offset);
            RenderTexture.active = temporary;
            readback = new Texture2D(width, height, TextureFormat.RGBA32, false, true);
            readback.ReadPixels(new Rect(0f, 0f, width, height), 0, 0, false);
            readback.Apply(false, false);
            Color32[] packed = readback.GetPixels32();
            int left = width;
            int right = -1;
            int bottom = height;
            int top = -1;
            for (int y = 0; y < height; y++)
            {
                for (int x = 0; x < width; x++)
                {
                    if (packed[y * width + x].r == 0) continue;
                    left = Math.Min(left, x);
                    right = Math.Max(right, x);
                    bottom = Math.Min(bottom, y);
                    top = Math.Max(top, y);
                }
            }
            if (right < left || top < bottom)
                throw new InvalidOperationException("The native glyph has an empty red-channel mask.");
            left = Math.Max(0, left - 2);
            right = Math.Min(width - 1, right + 2);
            bottom = Math.Max(0, bottom - 2);
            top = Math.Min(height - 1, top + 2);
            int croppedWidth = right - left + 1;
            int croppedHeight = top - bottom + 1;
            // The native glyph Image is a square. Keep the decoded canvas
            // square too so a narrow wrench/arrow is not stretched by its rect.
            int side = Math.Max(croppedWidth, croppedHeight);
            int padX = (side - croppedWidth) / 2;
            int padY = (side - croppedHeight) / 2;
            Color32[] whiteMask = new Color32[side * side];
            for (int i = 0; i < whiteMask.Length; i++) whiteMask[i] = new Color32(255, 255, 255, 0);
            for (int y = 0; y < croppedHeight; y++)
            {
                for (int x = 0; x < croppedWidth; x++)
                {
                    byte mask = packed[(bottom + y) * width + left + x].r;
                    whiteMask[(y + padY) * side + x + padX] = new Color32(255, 255, 255, mask);
                }
            }
            decodedTexture = new Texture2D(side, side, TextureFormat.RGBA32, false);
            decodedTexture.name = "SCOM Order Glyph " + sourceSprite.name;
            decodedTexture.wrapMode = TextureWrapMode.Clamp;
            decodedTexture.filterMode = FilterMode.Bilinear;
            decodedTexture.SetPixels32(whiteMask);
            decodedTexture.Apply(false, true);
            Sprite decodedSprite = Sprite.Create(decodedTexture, new Rect(0f, 0f, side, side),
                new Vector2(0.5f, 0.5f), sourceSprite.pixelsPerUnit, 0, SpriteMeshType.FullRect);
            decodedSprite.name = decodedTexture.name;
            DecodedGlyph result = new DecodedGlyph { texture = decodedTexture, sprite = decodedSprite };
            decodedTexture = null;
            return result;
        }
        finally
        {
            RenderTexture.active = previous;
            if (temporary != null) RenderTexture.ReleaseTemporary(temporary);
            if (readback != null) UnityEngine.Object.Destroy(readback);
            if (decodedTexture != null) UnityEngine.Object.Destroy(decodedTexture);
        }
    }

    /// <summary>Call after native GraphicState restoration releases these sprites.</summary>
    public static void Cleanup()
    {
        foreach (DecodedGlyph decoded in decodedBySource.Values)
        {
            if (decoded.sprite != null) UnityEngine.Object.Destroy(decoded.sprite);
            if (decoded.texture != null) UnityEngine.Object.Destroy(decoded.texture);
        }
        decodedBySource.Clear();
        decodedSpriteIds.Clear();
        packedImageIds.Clear();
        nativePackedMaterials.Clear();
        failedSpriteIds.Clear();
        LastError = string.Empty;
    }
}
