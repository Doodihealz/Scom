using UnityEngine;

namespace ScomShatter;

// The horizontal warp maps the authored mesh into the local terrain patch.
// Quarter turns and scale then place that patch on the map.
internal readonly struct FractureLayout
{
    internal readonly float ScaleX, ScaleZ;
    internal readonly int QuarterTurns;
    internal bool IsFault => FaultProfile >= 0;
    internal readonly int FaultProfile;
    internal Vector2 OpeningCenter => IsFault ? Vector2.zero : new Vector2(0f, SurfaceOpening.OffsetZ);
    // The native hole pass always clips to its instance ellipse. Warped mask
    // geometry already contains the transported source ellipse. Enclose the
    // entire patch so the native pass cannot also cut off a bent tip.
    internal Vector2 OpeningSize => IsFault ? 1.42f * new Vector2(CampaignSurfaceAssets.NativeWidth, CampaignSurfaceAssets.NativeLength)
        : new Vector2(SurfaceOpening.Width, SurfaceOpening.Length);
    internal Vector3 Scale => new Vector3(ScaleX, 1f, ScaleZ);
    internal Quaternion Rotation => Quaternion.Euler(0f, QuarterTurns * 90f, 0f);
    internal bool Swapped => (QuarterTurns & 1) != 0;

    internal FractureLayout(float scaleX, float scaleZ, int quarterTurns, int faultProfile = -1)
    {
        ScaleX = scaleX; ScaleZ = scaleZ; QuarterTurns = quarterTurns & 3;
        FaultProfile = faultProfile;
    }

    internal static FractureLayout Create(Vector3 impact, uint sequence)
    {
        uint seed = 2166136261u;
        seed = unchecked((seed ^ (uint)Mathf.RoundToInt(impact.x * 8f)) * 16777619u);
        seed = unchecked((seed ^ (uint)Mathf.RoundToInt(impact.z * 8f)) * 16777619u);
        uint orientation = seed + sequence;
        seed = unchecked(seed ^ (sequence * 747796405u + 2891336453u));
        float Next()
        {
            seed ^= seed << 13; seed ^= seed >> 17; seed ^= seed << 5;
            return (seed & 0xffffffu) / 16777215f;
        }
        float size = Mathf.Lerp(.84f, 1.16f, Next());
        float aspect = Mathf.Lerp(.90f, 1.10f, Next());
        int turns = (int)(orientation & 3u);
        if (Next() >= .5f) return new FractureLayout(size * aspect, size / aspect, turns);
        int profile = Mathf.Min((int)(Next() * CampaignWarp.ProfileCount), CampaignWarp.ProfileCount - 1);
        float stretch = Mathf.Lerp(.88f, 1.23f, Next());
        return new FractureLayout(size * stretch, size / stretch, turns, profile);
    }

    internal Vector2 SourceToNative(Vector2 source) => CampaignWarp.Forward(source, FaultProfile);
    internal Vector2 NativeToSource(Vector2 native) => CampaignWarp.Inverse(native, FaultProfile);

    internal bool TryAddress(Vector2 native, out int pixel, out float fx, out float fz)
    {
        Vector2 source = NativeToSource(native);
        float x = 2f * source.x / SurfaceOpening.Width;
        float z = 2f * (source.y - SurfaceOpening.OffsetZ) / SurfaceOpening.Length;
        if (x * x + z * z > 1f) { pixel = 0; fx = fz = 0f; return false; }
        CampaignMotion.Address(source, out pixel, out fx, out fz);
        return true;
    }

    internal float FinalDrop(Vector2 native) => TryAddress(native, out int p, out float x, out float z)
        ? CampaignMotion.Final(p, x, z) : 0f;

    internal float Drop(Vector2 native, float progress)
    {
        if (progress <= 0f || !TryAddress(native, out int p, out float x, out float z)) return 0f;
        if (progress >= 1f) return CampaignMotion.Final(p, x, z);
        CampaignMotion.Frame(progress, out int frame, out float blend);
        return CampaignMotion.Drop(frame, blend, p, x, z);
    }

    // A slab that briefly dips and rebounds retains its final support.
    internal bool LostSupport(Vector2 native, float progress)
    {
        if (!TryAddress(native, out int p, out float x, out float z)
            || CampaignMotion.Final(p, x, z) < CampaignMotion.LipDrop) return false;
        if (progress >= 1f) return true;
        CampaignMotion.Frame(progress, out int frame, out float blend);
        return CampaignMotion.Drop(frame, blend, p, x, z) >= CampaignMotion.LipDrop;
    }

    internal Vector2 ToSite(Vector2 native)
    {
        float x = native.x * ScaleX, z = native.y * ScaleZ;
        switch (QuarterTurns)
        {
            case 1: return new Vector2(z, -x);
            case 2: return new Vector2(-x, -z);
            case 3: return new Vector2(-z, x);
            default: return new Vector2(x, z);
        }
    }

    internal Vector2 ToNative(Vector2 site)
    {
        switch (QuarterTurns)
        {
            case 1: return new Vector2(-site.y / ScaleX, site.x / ScaleZ);
            case 2: return new Vector2(-site.x / ScaleX, -site.y / ScaleZ);
            case 3: return new Vector2(site.y / ScaleX, -site.x / ScaleZ);
            default: return new Vector2(site.x / ScaleX, site.y / ScaleZ);
        }
    }

    internal Vector3 ToNative(Vector3 site)
    {
        Vector2 p = ToNative(new Vector2(site.x, site.z));
        return new Vector3(p.x, site.y, p.y);
    }

    internal Rect SiteBounds(Rect native) => Bounds(ToSite(new Vector2(native.xMin, native.yMin)),
        ToSite(new Vector2(native.xMax, native.yMax)));
    internal Rect NativeBounds(Rect site) => Bounds(ToNative(new Vector2(site.xMin, site.yMin)),
        ToNative(new Vector2(site.xMax, site.yMax)));
    private static Rect Bounds(Vector2 a, Vector2 b) => Rect.MinMaxRect(Mathf.Min(a.x,b.x),Mathf.Min(a.y,b.y),
        Mathf.Max(a.x,b.x),Mathf.Max(a.y,b.y));
}
