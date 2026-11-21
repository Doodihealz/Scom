using System;
using EM.Engine;
using UnityEngine;

namespace ScomShatter
{
    internal static class CampaignTimeline
    {
        internal const string AnimationProperty = "_Animation_Timeline";
        internal const float AnimationDelay = 1.4f;
        internal const float AnimationDuration = 9f;
        internal const float GodRaysDelay = 2.8f;
        internal const float GodRayParticleDelay = 0f;

        // GetSimulationTime returns tick time outside the engine's render callback.
        // RenderUpdate already interpolates this local value, respects sim speed,
        // and stops at the newest tick while paused or waiting for simulation.
        internal static double RenderTime => ClientEngine.Data.isRenderingStarted
            ? ClientEngine.Data.localEngineData.localTime.simTime
            : ClientEngine.GetSimulationTime();

        internal sealed class Clock
        {
            private readonly double startedAt;
            private double impactAge;
            internal Clock(int impactTick) { startedAt = (impactTick + 1.0) * .1; }
            internal float ImpactAge => (float)impactAge;

            internal void Advance()
            {
                // Render the current authoritative phase even when the camera or
                // terrain texture becomes ready several simulation ticks later.
                impactAge = Math.Max(impactAge, RenderTime - startedAt);
            }
        }

        // DemoSceneShatterFx's serialized remapping curve has two linear keys.
        internal static float Progress(double age)
        {
            return Mathf.Clamp01((float)((age - AnimationDelay) / AnimationDuration));
        }

        // The native vertex graph applies this quadratic in/out to the timeline.
        internal static float ShaderPhase(float progress)
        {
            float t = Mathf.Clamp01(progress);
            return t < .5f ? 2f * t * t : 1f - 2f * (1f - t) * (1f - t);
        }

        internal static float AgeAtShaderPhase(float phase)
        {
            float t = Mathf.Clamp01(phase);
            float progress = t < .5f ? Mathf.Sqrt(t * .5f) : 1f - Mathf.Sqrt((1f - t) * .5f);
            return AnimationDelay + AnimationDuration * progress;
        }

        internal static void Apply(Material plane, double age)
        {
            plane.SetFloat(AnimationProperty, Progress(age));
        }
    }
}
