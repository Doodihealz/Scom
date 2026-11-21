using System;
using System.IO;
using System.IO.Compression;
using UnityEngine;

namespace ScomShatter;

// The immutable native mesh heights are generated from the bundled vertex graph.
// Baking reads managed arrays and never inverts the horizontal campaign warp.
internal sealed class BakedWallProjection
{
    private const int Columns = 640, Rows = 320, Width = Columns + 1;
    private const int JacobianColumns = 96, JacobianRows = 48;
    private static readonly Lazy<float[]> settled = new Lazy<float[]>(LoadSettled);
    private readonly Vector4[] inverseJacobians;

    internal readonly struct SurfaceSample
    {
        internal readonly float Drop, Dx, Dz;
        internal readonly Vector2 Source;
        internal readonly bool Reprojected;
        internal SurfaceSample(float drop, float dx, float dz, Vector2 source = default(Vector2), bool reprojected = false)
        { Drop = drop; Dx = dx; Dz = dz; Source = source; Reprojected = reprojected; }
    }

    private BakedWallProjection(Vector4[] inverseJacobians) { this.inverseJacobians = inverseJacobians; }

    // The bundled graph is immutable; retain only its 0.8 MB managed height
    // field across sites/sessions, with no references to unloaded Unity assets.
    internal static BakedWallProjection Capture(FractureLayout layout)
    {
        var inverse = new Vector4[(JacobianColumns + 1) * (JacobianRows + 1)];
        const float step = .1f;
        for (int z = 0; z <= JacobianRows; ++z)
            for (int x = 0; x <= JacobianColumns; ++x)
            {
                var p = new Vector2(((float)x / JacobianColumns - .5f) * CampaignSurfaceAssets.NativeWidth,
                    ((float)z / JacobianRows - .5f) * CampaignSurfaceAssets.NativeLength);
                Vector2 dx = (layout.ToSite(layout.SourceToNative(p + new Vector2(step, 0f))) -
                    layout.ToSite(layout.SourceToNative(p - new Vector2(step, 0f)))) / (2f * step);
                Vector2 dz = (layout.ToSite(layout.SourceToNative(p + new Vector2(0f, step))) -
                    layout.ToSite(layout.SourceToNative(p - new Vector2(0f, step)))) / (2f * step);
                float determinant = dx.x * dz.y - dz.x * dx.y;
                if (Mathf.Abs(determinant) < .0001f)
                    throw new InvalidOperationException("Degenerate campaign wall projection.");
                inverse[z * (JacobianColumns + 1) + x] = new Vector4(dz.y, -dx.y, -dz.x, dx.x) / determinant;
            }
        return new BakedWallProjection(inverse);
    }

    internal SurfaceSample Sample(Vector2 source)
    {
        SurfaceSample direct = At(source);
        // Fallen native diffuse/normal UVs expand about their centre by 1.08.
        // A single atlas cannot serve conflicting cap and wall phases: retain
        // the cap wherever either address belongs to a supported flat surface.
        if (!IsWall(direct)) return direct;
        Vector2 correctedSource = source / 1.08f;
        SurfaceSample corrected = At(correctedSource);
        return IsWall(corrected) ? new SurfaceSample(corrected.Drop, corrected.Dx, corrected.Dz, correctedSource, true) : direct;
    }

    private static bool IsWall(SurfaceSample sample)
        => sample.Drop > .25f && sample.Dx * sample.Dx + sample.Dz * sample.Dz > 1.367f;

    private SurfaceSample At(Vector2 source)
    {
        float u = Mathf.Clamp01(source.x / CampaignSurfaceAssets.NativeWidth + .5f);
        float v = Mathf.Clamp01(source.y / CampaignSurfaceAssets.NativeLength + .5f);
        float x = u * Columns, z = v * Rows;
        int ix = Math.Min((int)x, Columns - 1), iz = Math.Min((int)z, Rows - 1);
        float fx = x - ix, fz = z - iz;
        int p = iz * Width + ix;
        float[] values = settled.Value;
        float h00 = values[p], h10 = values[p + 1], h01 = values[p + Width], h11 = values[p + Width + 1];
        // Native grid quads split along (1,0)-(0,1). Interpolate their actual
        // displaced triangles instead of smoothing narrow scar faces away.
        float drop, dx, dz;
        if (fx + fz <= 1f)
        {
            dx = h10 - h00; dz = h01 - h00;
            drop = h00 + fx * dx + fz * dz;
        }
        else
        {
            dx = h11 - h01; dz = h11 - h10;
            drop = h11 - (1f - fx) * dx - (1f - fz) * dz;
        }
        if (drop <= .25f) return new SurfaceSample(drop, 0f, 0f);
        dx *= Columns / CampaignSurfaceAssets.NativeWidth;
        dz *= Rows / CampaignSurfaceAssets.NativeLength;
        x = u * JacobianColumns; z = v * JacobianRows;
        ix = Math.Min((int)x, JacobianColumns - 1); iz = Math.Min((int)z, JacobianRows - 1);
        p = iz * (JacobianColumns + 1) + ix;
        Vector4 inverse = Vector4.LerpUnclamped(Vector4.LerpUnclamped(inverseJacobians[p], inverseJacobians[p + 1], x - ix),
            Vector4.LerpUnclamped(inverseJacobians[p + JacobianColumns + 1], inverseJacobians[p + JacobianColumns + 2], x - ix), z - iz);
        return new SurfaceSample(drop, inverse.x * dx + inverse.y * dz, inverse.z * dx + inverse.w * dz);
    }

    private static float[] LoadSettled()
    {
        using var stream = typeof(BakedWallProjection).Assembly.GetManifestResourceStream("CampaignSettledHeights.bin.gz")
            ?? throw new InvalidDataException("Missing settled campaign wall heights.");
        using var gzip = new GZipStream(stream, CompressionMode.Decompress);
        using var reader = new BinaryReader(gzip);
        if (reader.ReadUInt32() != 0x31485753 || reader.ReadUInt16() != Width || reader.ReadUInt16() != Rows + 1)
            throw new InvalidDataException("Invalid settled campaign wall height dimensions.");
        var values = new float[Width * (Rows + 1)];
        for (int i = 0; i < values.Length; ++i) values[i] = reader.ReadUInt16() * .001f;
        if (gzip.ReadByte() != -1) throw new InvalidDataException("Invalid settled campaign wall height length.");
        return values;
    }
}
