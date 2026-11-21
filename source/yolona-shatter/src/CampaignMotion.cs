using System;
using System.IO;
using UnityEngine;

namespace ScomShatter;

// The simulation can read the baked campaign displacement without a camera,
// Unity textures, or an active terrain renderer.
internal static class CampaignMotion
{
    internal const int Columns = 97, Rows = 49, Frames = 65;
    internal const float LipDrop = 5f;
    private const int Slice = Columns * Rows;
    private const float DropScale = CampaignSurfaceAssets.MaximumLocalDrop * CampaignSurfaceAssets.NativeScale / 255f;
    private static readonly byte[] samples = Load();

    private static byte[] Load()
    {
        using var stream = typeof(CampaignMotion).Assembly.GetManifestResourceStream("CampaignWaterMotion.bin")
            ?? throw new InvalidDataException("Missing campaign displacement.");
        using var reader = new BinaryReader(stream);
        if (reader.ReadUInt32() != 0x31465753 || reader.ReadUInt16() != Columns || reader.ReadUInt16() != Rows
            || reader.ReadUInt16() != Frames || stream.Length != 10 + Slice * Frames)
            throw new InvalidDataException("Invalid campaign displacement.");
        var data = reader.ReadBytes(Slice * Frames);
        if (data.Length != Slice * Frames) throw new EndOfStreamException();
        return data;
    }

    internal static void Address(Vector2 native, out int pixel, out float fx, out float fz)
    {
        float x = Mathf.Clamp01(native.x / CampaignSurfaceAssets.NativeWidth + .5f) * (Columns - 1);
        float z = Mathf.Clamp01(native.y / CampaignSurfaceAssets.NativeLength + .5f) * (Rows - 1);
        int ix = Math.Min((int)x, Columns - 2), iz = Math.Min((int)z, Rows - 2);
        pixel = iz * Columns + ix;
        fx = x - ix;
        fz = z - iz;
    }

    internal static void Frame(float progress, out int frame, out float blend)
    {
        float time = Mathf.Clamp01(progress) * (Frames - 1);
        frame = Math.Min((int)time, Frames - 2);
        blend = time - frame;
    }

    private static float Sample(int p, float x, float z)
        => Sample(samples, p, x, z);

    private static float Sample(byte[] source, int p, float x, float z)
    {
        float a = Mathf.LerpUnclamped(source[p], source[p + 1], x);
        float b = Mathf.LerpUnclamped(source[p + Columns], source[p + Columns + 1], x);
        return Mathf.LerpUnclamped(a, b, z) * DropScale;
    }

    // Bilinear interpolation uses nonnegative weights. The four corner maxima
    // therefore bound every sample in this stage, even if their peaks differ.
    private static class StagePeaks
    {
        internal static readonly byte[] Values = Build();
        private static byte[] Build()
        {
            var peaks = new byte[NavigationFootprint.Stages * Slice];
            for (int frame = 1; frame < Frames; frame++)
            {
                int stage = (frame - 1) * NavigationFootprint.Stages / (Frames - 1);
                int destination = stage * Slice, source = frame * Slice;
                for (int i = 0; i < Slice; i++)
                    if (samples[source + i] > peaks[destination + i]) peaks[destination + i] = samples[source + i];
            }
            return peaks;
        }
    }

    internal static bool OpensDuring(int stage, int pixel, float x, float z)
    {
        if (Sample(StagePeaks.Values, (stage - 1) * Slice + pixel, x, z) < LipDrop - .00001f) return false;
        int last = stage * (Frames - 1) / NavigationFootprint.Stages;
        int first = (stage - 1) * (Frames - 1) / NavigationFootprint.Stages + 1;
        for (int frame = last; frame >= first; frame--)
            if (Sample(frame * Slice + pixel, x, z) >= LipDrop) return true;
        return false;
    }

    internal static float Final(int pixel, float fx, float fz) => Sample((Frames - 1) * Slice + pixel, fx, fz);

    internal static float Drop(int frame, float blend, int pixel, float fx, float fz)
    {
        int p = frame * Slice + pixel;
        return Mathf.LerpUnclamped(Sample(p, fx, fz), Sample(p + Slice, fx, fz), blend);
    }
}
