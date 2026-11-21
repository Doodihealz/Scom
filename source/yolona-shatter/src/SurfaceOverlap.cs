using UnityEngine;

namespace ScomShatter;

// In overlapping apertures, the deeper campaign slab owns each point.
internal readonly struct SurfaceOverlap
{
    private readonly Vector2 origin;
    private readonly Rect bounds;
    private readonly FractureLayout layout;
    private readonly float phase, tie;

    internal SurfaceOverlap(Vector2 origin, Rect bounds, FractureLayout layout, float phase, bool ownerFirst)
    {
        this.origin = origin;
        this.bounds = bounds;
        this.layout = layout;
        this.phase = phase;
        // Complementary signs give coincident sheets one stable owner.
        tie = ownerFirst ? .001f : -.001f;
    }

    internal bool Applies(Vector2 world) => bounds.Contains(world);

    internal float Keep(Vector2 world, float ownDrop)
    {
        Vector2 native = layout.ToNative(world - origin);
        float otherDrop = layout.Drop(native, phase);
        return Mathf.Max(CampaignMotion.LipDrop - otherDrop, ownDrop - otherDrop + tie);
    }
}
