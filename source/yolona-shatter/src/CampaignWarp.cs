using System;
using UnityEngine;

namespace ScomShatter;

// Only horizontal coordinates change. Original campaign vertices retain their
// UVs, relief and animated heights; simulation applies the exact inverse map.
internal static class CampaignWarp
{
    internal const int ProfileCount = 6;
    private const float HalfWidth = CampaignSurfaceAssets.NativeWidth * .5f;
    private const float HalfLength = CampaignSurfaceAssets.NativeLength * .5f;
    private const float HorizontalPivot = .5f, LongitudinalPivot = .45f;
    private const int Intervals = 10;
    private const float Strength = .75f, Transition = .07f;

    private sealed class Axis
    {
        internal readonly float[] Center, Scale;
        internal Axis(float[] center, float[] scale) { Center = center; Scale = scale; }

        internal void At(float coordinate, out float center, out float scale)
        {
            float position = (coordinate + 1f) * (Intervals * .5f);
            int index = Math.Min(Math.Max((int)position, 0), Intervals - 1);
            float blend = position - index;
            // Zero endpoint derivatives keep the cross-axis shear C1 at every
            // station, including the identity frame and registered impact.
            blend *= blend * (3f - 2f * blend);
            center = (Center[index] + (Center[index + 1] - Center[index]) * blend) * Strength;
            scale = 1f + (Scale[index] + (Scale[index + 1] - Scale[index]) * blend - 1f) * Strength;
        }
    }

    private sealed class Profile
    {
        internal readonly Axis Horizontal, Longitudinal;
        internal Profile(float[] lateral, float[] width, float[] foreAft, float[] length)
        { Horizontal = new Axis(lateral, width); Longitudinal = new Axis(foreAft, length); }
    }

    // Knots lie at -1, -.8, ... 1 across the perpendicular native axis. Unequal
    // banks come from independent lateral and longitudinal shear, not lobes.
    // End knots are identity so the entire rectangular boundary stays fixed.
    private static readonly Profile[] profiles = {
        // A broad broken dogleg with a compressed northern shoulder.
        new Profile(
            new[] {0f, -.06f, -.19f, -.12f, .16f, 0f, .04f, -.16f, -.10f, .04f, 0f},
            new[] {1f, .88f, .72f, 1.12f, 1.24f, .88f, .70f, 1.19f, .91f, 1.05f, 1f},
            new[] {0f, .04f, .16f, .11f, -.13f, 0f, -.05f, .13f, .08f, -.03f, 0f},
            new[] {1f, 1.08f, .77f, .83f, 1.22f, 1.15f, .73f, .95f, 1.20f, .91f, 1f}),
        // A western cut followed by a long eastward slab displacement.
        new Profile(
            new[] {0f, .08f, .17f, -.11f, -.24f, 0f, .08f, .23f, .18f, .03f, 0f},
            new[] {1f, 1.12f, .82f, .68f, 1.07f, 1.28f, .86f, .72f, 1.10f, .94f, 1f},
            new[] {0f, -.07f, -.17f, -.10f, .12f, 0f, .02f, -.16f, -.05f, .06f, 0f},
            new[] {1f, .86f, 1.16f, 1.24f, .91f, .70f, 1.12f, 1.21f, .79f, .95f, 1f}),
        // A wide central rupture with opposite short shear steps at either end.
        new Profile(
            new[] {0f, -.10f, -.22f, -.03f, .20f, 0f, -.09f, -.21f, .05f, .11f, 0f},
            new[] {1f, .83f, 1.06f, .72f, .88f, 1.30f, 1.22f, .77f, .69f, 1.12f, 1f},
            new[] {0f, .07f, .19f, .02f, -.18f, 0f, .14f, .20f, .06f, -.09f, 0f},
            new[] {1f, 1.12f, .82f, .68f, 1.16f, 1.24f, .95f, .73f, 1.11f, .88f, 1f}),
        // A narrow displaced waist opening into unequal end basins.
        new Profile(
            new[] {0f, .11f, .21f, .13f, -.08f, 0f, -.17f, .06f, .19f, -.04f, 0f},
            new[] {1f, .91f, .73f, 1.21f, 1.12f, .64f, .83f, 1.26f, .92f, .77f, 1f},
            new[] {0f, -.03f, -.14f, .05f, .19f, 0f, -.17f, -.12f, .11f, .04f, 0f},
            new[] {1f, .77f, 1.13f, 1.23f, .82f, .69f, 1.21f, .97f, .76f, 1.09f, 1f}),
        // Two broad offsets separated by an abrupt oblique central slip.
        new Profile(
            new[] {0f, -.04f, -.16f, -.21f, -.11f, 0f, .24f, .12f, -.15f, -.08f, 0f},
            new[] {1f, 1.10f, .79f, .68f, 1.25f, 1.03f, .72f, 1.14f, 1.19f, .86f, 1f},
            new[] {0f, .06f, .12f, -.11f, -.20f, 0f, .16f, .09f, -.13f, -.05f, 0f},
            new[] {1f, .91f, 1.19f, .76f, 1.10f, 1.25f, .71f, .87f, 1.15f, .80f, 1f}),
        // Keep the double bend, but leave room between the second bend and
        // the narrow shoulder so the exposed wall is not pinched into a fin.
        new Profile(
            new[] {0f, .05f, .23f, .03f, -.18f, 0f, .17f, .18f, -.07f, -.13f, 0f},
            new[] {1f, .76f, .87f, 1.28f, 1.14f, .71f, .91f, 1.16f, .76f, 1.09f, 1f},
            new[] {0f, -.09f, -.06f, .16f, .20f, 0f, -.19f, .02f, .14f, -.02f, 0f},
            new[] {1f, 1.13f, .74f, .89f, 1.18f, .72f, 1.22f, 1.08f, .79f, .97f, 1f})
    };

    // Positive slopes connect the inner slab to the fixed frame. A narrow
    // quadratic bridge blends each slope jump, keeping the axis map C1. Its
    // derivative interpolates between positive slopes, so it cannot fold.
    private static float Map(float coordinate, float center, float scale, float pivot)
    {
        float left = (1f + center - pivot * scale) / (1f - pivot);
        if (coordinate < -pivot - Transition) return -1f + (coordinate + 1f) * left;
        if (coordinate < -pivot + Transition)
            return Bridge(coordinate + pivot + Transition,
                center - pivot * scale - left * Transition, left, scale);
        if (coordinate <= pivot - Transition) return center + coordinate * scale;
        float right = (1f - center - pivot * scale) / (1f - pivot);
        if (coordinate < pivot + Transition)
            return Bridge(coordinate - pivot + Transition,
                center + (pivot - Transition) * scale, scale, right);
        return 1f - (1f - coordinate) * right;
    }

    private static float Bridge(float distance, float start, float incoming, float outgoing)
        => start + distance * (incoming + (outgoing - incoming) * distance / (4f * Transition));

    private static float Unmap(float coordinate, float center, float scale, float pivot)
    {
        float left = (1f + center - pivot * scale) / (1f - pivot);
        float lowerStart = center - pivot * scale - left * Transition;
        if (coordinate < lowerStart) return -1f + (coordinate + 1f) / left;
        if (coordinate < center + (-pivot + Transition) * scale)
            return -pivot - Transition + Unbridge(coordinate - lowerStart, left, scale);
        float upperStart = center + (pivot - Transition) * scale;
        if (coordinate <= upperStart) return (coordinate - center) / scale;
        float right = (1f - center - pivot * scale) / (1f - pivot);
        if (coordinate < center + pivot * scale + right * Transition)
            return pivot - Transition + Unbridge(coordinate - upperStart, scale, right);
        return 1f - (1f - coordinate) / right;
    }

    private static float Unbridge(float distance, float incoming, float outgoing)
    {
        // Rationalizing the positive quadratic root avoids cancellation when
        // the two slopes are equal or very close. No iterative inverse is used.
        float discriminant = incoming * incoming + (outgoing - incoming) * distance / Transition;
        return 2f * distance / (incoming + (float)Math.Sqrt(Math.Max(0f, discriminant)));
    }

    internal static Vector2 Forward(Vector2 source, int profile)
    {
        if (profile == -1 || Outside(source)) return source;
        Profile field = profiles[profile];
        float x = source.x / HalfWidth, z = source.y / HalfLength;
        field.Horizontal.At(z, out float center, out float scale);
        x = Map(x, center, scale, HorizontalPivot);
        field.Longitudinal.At(x, out center, out scale);
        z = Map(z, center, scale, LongitudinalPivot);
        return new Vector2(x * HalfWidth, z * HalfLength);
    }

    internal static Vector2 Inverse(Vector2 native, int profile)
    {
        if (profile == -1 || Outside(native)) return native;
        Profile field = profiles[profile];
        float x = native.x / HalfWidth, z = native.y / HalfLength;
        // Reverse the composition: the second shear is keyed by transformed x.
        field.Longitudinal.At(x, out float center, out float scale);
        z = Unmap(z, center, scale, LongitudinalPivot);
        field.Horizontal.At(z, out center, out scale);
        x = Unmap(x, center, scale, HorizontalPivot);
        return new Vector2(x * HalfWidth, z * HalfLength);
    }

    private static bool Outside(Vector2 point)
        => point.x <= -HalfWidth || point.x >= HalfWidth
            || point.y <= -HalfLength || point.y >= HalfLength;
}
