using System;
using System.IO;
using System.IO.Compression;
using UnityEngine;

namespace ScomShatter;

// Render-only displacement at every authored mesh vertex. Coordinates remain
// in source space; the caller owns the transported ellipse and horizontal warp.
internal static class CampaignWaterHeights
{
    internal const int Columns = 641, Rows = 321;
    private const int Frames = CampaignMotion.Frames, Slice = Columns * Rows;
    private const float MetresPerSample = .01f;
    private static readonly ushort[] peaks = new ushort[Slice];
    private static readonly ushort[] samples = Load();

    private static ushort[] Load()
    {
        using var stream = typeof(CampaignWaterHeights).Assembly.GetManifestResourceStream("CampaignWaterHeights.bin.gz")
            ?? throw new InvalidDataException("Missing campaign water heights.");
        using var gzip = new GZipStream(stream, CompressionMode.Decompress);
        using var reader = new BinaryReader(gzip);
        if (reader.ReadUInt32() != 0x31485743 || reader.ReadUInt16() != Columns || reader.ReadUInt16() != Rows
            || reader.ReadUInt16() != Frames)
            throw new InvalidDataException("Invalid campaign water height dimensions.");
        var data = new ushort[Slice * Frames];
        var encoded = new byte[64 * 1024];
        int offset = 0, pixel = 0;
        while (offset < data.Length)
        {
            int count = Math.Min(encoded.Length, (data.Length - offset) * sizeof(ushort));
            int received = 0;
            while (received < count)
            {
                int read = gzip.Read(encoded, received, count - received);
                if (read == 0) throw new InvalidDataException("Truncated campaign water heights.");
                received += read;
            }
            if (!BitConverter.IsLittleEndian)
                for (int i = 0; i < count; i += 2)
                    (encoded[i], encoded[i + 1]) = (encoded[i + 1], encoded[i]);
            Buffer.BlockCopy(encoded, 0, data, offset * sizeof(ushort), count);
            int end = offset + count / sizeof(ushort);
            for (; offset < end; offset++)
            {
                if (data[offset] > peaks[pixel]) peaks[pixel] = data[offset];
                if (++pixel == Slice) pixel = 0;
            }
        }
        if (gzip.ReadByte() != -1) throw new InvalidDataException("Trailing campaign water heights.");
        return data;
    }

    internal static void Address(Vector2 source, out int pixel, out float fx, out float fz)
    {
        float x = Mathf.Clamp01(source.x / CampaignSurfaceAssets.NativeWidth + .5f) * (Columns - 1);
        float z = Mathf.Clamp01(source.y / CampaignSurfaceAssets.NativeLength + .5f) * (Rows - 1);
        int ix = Math.Min((int)x, Columns - 2), iz = Math.Min((int)z, Rows - 2);
        pixel = iz * Columns + ix;
        fx = x - ix; fz = z - iz;
    }

    private static float Sample(ushort[] field, int pixel, float x, float z)
    {
        float a = field[pixel], b = field[pixel + 1], c = field[pixel + Columns], d = field[pixel + Columns + 1];
        // The authored plane splits each quad along (1,0)-(0,1).
        float value = x + z <= 1f ? a + x * (b - a) + z * (c - a)
            : d + (1f - x) * (c - d) + (1f - z) * (b - d);
        return value * MetresPerSample;
    }

    internal static float Final(int pixel, float fx, float fz)
        => Sample(samples, (Frames - 1) * Slice + pixel, fx, fz);

    internal static float VertexFinal(int i) => samples[(Frames-1)*Slice+i] * MetresPerSample;
    internal static float VertexPeak(int i) => (peaks[i] + .5f) * MetresPerSample;
    internal static float VertexDrop(int frame, float blend, int i)
    {
        int p = frame*Slice+i;
        return Mathf.LerpUnclamped(samples[p],samples[p+Slice],blend)*MetresPerSample;
    }

    // Nonnegative triangle weights preserve this temporal upper bound, even
    // when the three vertices peak at different phases. Include rounding error.
    internal static float Peak(int pixel, float fx, float fz)
        => Sample(peaks, pixel, fx, fz) + MetresPerSample * .5f;

    internal static float Drop(int frame, float blend, int pixel, float fx, float fz)
    {
        int offset = frame * Slice + pixel;
        return Mathf.LerpUnclamped(Sample(samples, offset, fx, fz), Sample(samples, offset + Slice, fx, fz), blend);
    }
}
