using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using Object = UnityEngine.Object;

namespace ScomShatter
{
    internal sealed class ShatterAccents : MonoBehaviour
    {
        private const int DustCount = 48;
        private const float DustLifetime = 3.4f, RayEmission = 4f, RayLifetime = 4f;
        private static Material rays, smoke;
        private static int borrowers;
        private bool borrowed;
        private ParticleSystem gapLight, smokeCover;
        private float raySimulatedUntil, smokeSimulatedUntil;
        private Vector2 dustRadius, localOrigin;
        private FractureLayout layout;
        private ParticleSystem.Particle[] rayParticles;
        private HashSet<uint> movedRays;
        private bool raysStarted, smokeStarted;

        internal static ShatterAccents Create(Transform parent, Vector3 impact, FractureLayout layout)
        {
            if (parent == null) throw new ArgumentNullException(nameof(parent));
            float width=ShatterEffect.Width*layout.ScaleX;
            float length=ShatterEffect.Length*layout.ScaleZ;
            var owner = new GameObject("Campaign shatter accents");
            owner.SetActive(false);
            owner.transform.SetParent(parent, false);
            Vector2 origin=layout.SourceToNative(new Vector2(0,CampaignInterior.RootZ));
            Vector2 offset=layout.ToSite(origin);
            owner.transform.position = impact+new Vector3(offset.x,0,offset.y);
            owner.transform.localRotation=layout.Rotation;
            var effect = owner.AddComponent<ShatterAccents>();
            try
            {
                effect.layout=layout;
                effect.localOrigin=origin;
                effect.Initialize(width, length);
                if (layout.IsFault)
                {
                    effect.rayParticles = new ParticleSystem.Particle[effect.gapLight.main.maxParticles];
                    effect.movedRays = new HashSet<uint>();
                }
                owner.SetActive(true);
                return effect;
            }
            catch
            {
                effect.ReleaseResources();
                Object.Destroy(owner);
                throw;
            }
        }

        private void Initialize(float width, float length)
        {
            float scaleX = width / CampaignSurfaceAssets.NativeWidth;
            float scaleZ = length / CampaignSurfaceAssets.NativeLength;
            float scale = Mathf.Min(scaleX, scaleZ);
            borrowed = true;
            if (++borrowers == 1)
            {
                rays = CampaignSurfaceAssets.CreateRayMaterial();
                smoke = CampaignSurfaceAssets.CreateSmokeMaterial();
            }
            CreateRays(scaleX, scaleZ, scale);
            dustRadius = new Vector2(width * .17f, length * .19f);
            CreateSmoke(scale);
        }

        private ParticleSystem CreateSystem(string name, Material material, bool meshMode)
        {
            var owner = new GameObject(name);
            owner.transform.SetParent(transform, false);
            var particles = owner.AddComponent<ParticleSystem>();
            particles.Stop(false, ParticleSystemStopBehavior.StopEmittingAndClear);
            var main = particles.main;
            main.playOnAwake = false;
            main.simulationSpace = ParticleSystemSimulationSpace.Local;
            main.scalingMode = ParticleSystemScalingMode.Local;
            main.cullingMode = ParticleSystemCullingMode.AlwaysSimulate;
            main.useUnscaledTime = false;
            var renderer = owner.GetComponent<ParticleSystemRenderer>();
            renderer.sharedMaterial = material;
            renderer.renderMode = meshMode ? ParticleSystemRenderMode.Mesh : ParticleSystemRenderMode.Billboard;
            renderer.alignment = meshMode ? ParticleSystemRenderSpace.Local : ParticleSystemRenderSpace.View;
            renderer.shadowCastingMode = ShadowCastingMode.Off;
            renderer.receiveShadows = false;
            renderer.lightProbeUsage = LightProbeUsage.Off;
            renderer.reflectionProbeUsage = ReflectionProbeUsage.Off;
            renderer.maxParticleSize = 5f;
            renderer.enableGPUInstancing = true;
            renderer.SetActiveVertexStreams(new List<ParticleSystemVertexStream>
            {
                ParticleSystemVertexStream.Position, ParticleSystemVertexStream.Normal,
                ParticleSystemVertexStream.Color, ParticleSystemVertexStream.UV,
                ParticleSystemVertexStream.Custom1XY
            });
            return particles;
        }

        private void CreateRays(float scaleX, float scaleZ, float scale)
        {
            gapLight = CreateSystem("Hole Gap Light", rays, true);
            var main = gapLight.main;
            main.loop = false;
            main.duration = RayEmission;
            main.startDelay = CampaignTimeline.GodRayParticleDelay;
            main.startLifetime = new ParticleSystem.MinMaxCurve(2.5f, RayLifetime);
            main.startSpeed = .01f * scale;
            main.startColor = new Color(.7169812f, .4069353f, 1f, 1f);
            main.startSize = 75f * scale;
            main.startRotation3D = true;
            main.startRotationX = new ParticleSystem.MinMaxCurve(0f, 0f);
            main.startRotationY = new ParticleSystem.MinMaxCurve(0f, Mathf.PI * 2f);
            main.startRotationZ = new ParticleSystem.MinMaxCurve(0f, 0f);
            main.maxParticles = 16;
            var emission = gapLight.emission;
            emission.enabled = true;
            emission.rateOverTime = 3f;
            var shape = gapLight.shape;
            shape.enabled = true;
            shape.shapeType = ParticleSystemShapeType.Circle;
            shape.radius = 17.2f;
            shape.radiusThickness = 1f;
            shape.rotation = new Vector3(90f, 0f, 0f);
            shape.scale = new Vector3(6f * scaleX, 3f * scaleZ, 1f);
            shape.position = new Vector3(0f, -50f * scale, 0f);
            var size = gapLight.sizeOverLifetime;
            size.enabled = true;
            size.separateAxes = true;
            size.x = new ParticleSystem.MinMaxCurve(1f);
            size.y = new ParticleSystem.MinMaxCurve(4f);
            size.z = new ParticleSystem.MinMaxCurve(1f);
            SetFade(gapLight, 32768f / 65535f, 1f);
            SetCustomData(gapLight, AnimationCurve.Linear(0f, 0f, 1f, 1f), 1f);
            var velocity = gapLight.velocityOverLifetime;
            velocity.enabled = true;
            velocity.space = ParticleSystemSimulationSpace.Local;
            velocity.x = new ParticleSystem.MinMaxCurve(0f);
            velocity.y = new ParticleSystem.MinMaxCurve(-.001f * scale);
            velocity.z = new ParticleSystem.MinMaxCurve(0f);
            var renderer = gapLight.GetComponent<ParticleSystemRenderer>();
            renderer.mesh = CampaignSurfaceAssets.RayMesh;
            renderer.sortMode = ParticleSystemSortMode.Depth;
            renderer.sortingOrder = 2;
            renderer.sortingFudge = -20f;
        }

        private void CreateSmoke(float scale)
        {
            smokeCover = CreateSystem("Smoke Cover", smoke, false);
            var main = smokeCover.main;
            main.loop = false;
            main.duration = DustLifetime;
            main.startLifetime = new ParticleSystem.MinMaxCurve(1.7f, DustLifetime);
            main.startSpeed = 0f;
            main.startColor = new ParticleSystem.MinMaxGradient(
                new Color(.54f, .63f, .74f, .50f),
                new Color(.79f, .86f, .94f, .69f));
            main.startSize = new ParticleSystem.MinMaxCurve(25f * scale, 57f * scale);
            main.startRotation = new ParticleSystem.MinMaxCurve(-.7853981f, .7853981f);
            main.maxParticles = DustCount;
            var emission = smokeCover.emission;
            emission.enabled = false;
            var shape = smokeCover.shape;
            shape.enabled = false;
            var size = smokeCover.sizeOverLifetime;
            size.enabled = true;
            size.size = new ParticleSystem.MinMaxCurve(1f, new AnimationCurve(
                new Keyframe(0f, .3968201f, 17.11158f, 17.11158f),
                new Keyframe(.06606747f, .8134602f, .5143715f, .5143715f),
                new Keyframe(1f, 1f, -.01126468f, -.01126468f)));
            SetFade(smokeCover, .21f, .48f);
            SetCustomData(smokeCover, new AnimationCurve(
                new Keyframe(0f, .08259583f, 1.124877f, 1.124877f),
                new Keyframe(1f, 1f, .5006318f, .5006318f)), 0f);
            var renderer = smokeCover.GetComponent<ParticleSystemRenderer>();
            renderer.sortMode = ParticleSystemSortMode.OldestInFront;
            renderer.pivot = new Vector3(0f, .1f, .1f);
        }

        private static void SetFade(ParticleSystem particles, float peakTime, float peakAlpha)
        {
            var gradient = new Gradient();
            gradient.SetKeys(new[] { new GradientColorKey(Color.white, 0f), new GradientColorKey(Color.white, 1f) },
                new[] { new GradientAlphaKey(0f, 0f), new GradientAlphaKey(peakAlpha, peakTime), new GradientAlphaKey(0f, 1f) });
            var color = particles.colorOverLifetime;
            color.enabled = true;
            color.color = new ParticleSystem.MinMaxGradient(gradient);
        }

        private static void SetCustomData(ParticleSystem particles, AnimationCurve frames, float second)
        {
            var custom = particles.customData;
            custom.enabled = true;
            custom.SetMode(ParticleSystemCustomData.Custom1, ParticleSystemCustomDataMode.Vector);
            custom.SetVectorComponentCount(ParticleSystemCustomData.Custom1, 2);
            custom.SetVector(ParticleSystemCustomData.Custom1, 0, new ParticleSystem.MinMaxCurve(1f, frames));
            custom.SetVector(ParticleSystemCustomData.Custom1, 1, new ParticleSystem.MinMaxCurve(second));
        }

        private Vector3 PlaceParticle(Vector3 p)
        {
            if (!layout.IsFault) return p;
            Vector2 source = new Vector2(p.x / layout.ScaleX, p.z / layout.ScaleZ + CampaignInterior.RootZ);
            Vector2 offset = layout.SourceToNative(source) - localOrigin;
            return new Vector3(offset.x * layout.ScaleX, p.y, offset.y * layout.ScaleZ);
        }

        private void PlaceNewRays()
        {
            int count = gapLight.GetParticles(rayParticles);
            bool changed = false;
            for (int i = 0; i < count; i++)
            {
                if (!movedRays.Add(rayParticles[i].randomSeed)) continue;
                rayParticles[i].position = PlaceParticle(rayParticles[i].position);
                changed = true;
            }
            if (changed) gapLight.SetParticles(rayParticles, count);
        }

        private void EmitDust()
        {
            var position = transform.position;
            var random = new System.Random(unchecked(Mathf.RoundToInt(position.x) * 397 ^ Mathf.RoundToInt(position.z)));
            for (int i = 0; i < DustCount; ++i)
            {
                float angle = (i + (float)random.NextDouble()) * (2f * Mathf.PI / DustCount);
                var direction = new Vector3(Mathf.Cos(angle), 0f, Mathf.Sin(angle));
                float radius = .55f + (float)random.NextDouble() * .75f;
                Vector3 point=transform.TransformPoint(PlaceParticle(new Vector3(direction.x*dustRadius.x*radius,0,
                    direction.z*dustRadius.y*radius)));
                if (!Surface.TryGetHeight(point.x,point.z,out float y)) continue;
                var dust = new ParticleSystem.EmitParams {
                    position = transform.InverseTransformPoint(new Vector3(point.x,y+2f,point.z)),
                    velocity = direction * (20f + 17f * (float)random.NextDouble())
                        + Vector3.up * (4f + 7f * (float)random.NextDouble())
                };
                smokeCover.Emit(dust, 1);
            }
        }

        internal bool SetAge(float blastAge, float groundAge)
        {
            if (blastAge > 0f && !smokeStarted)
            {
                StartPaused(smokeCover);
                EmitDust();
                smokeStarted = true;
            }
            Advance(smokeCover, Mathf.Min(blastAge, DustLifetime), ref smokeSimulatedUntil);
            float rayAge = groundAge - CampaignTimeline.GodRaysDelay;
            if (rayAge > 0f && !raysStarted)
            {
                StartPaused(gapLight);
                raysStarted = true;
            }
            float rayEnd = CampaignTimeline.GodRayParticleDelay + RayEmission + RayLifetime;
            float rayTarget = Mathf.Min(rayAge, rayEnd);
            if (rayTarget > raySimulatedUntil)
            {
                Advance(gapLight, rayTarget, ref raySimulatedUntil);
                if (rayParticles != null) PlaceNewRays();
            }
            return blastAge >= DustLifetime && rayAge >= rayEnd;
        }

        private static void StartPaused(ParticleSystem particles)
        {
            particles.Play(false);
            particles.Pause(false);
        }

        private static void Advance(ParticleSystem particles, float target, ref float simulatedUntil)
        {
            if (target <= simulatedUntil) return;
            particles.Simulate(target - simulatedUntil, false, false, false);
            simulatedUntil = target;
        }

        private void OnDisable() { ReleaseResources(); }
        private void OnDestroy() { ReleaseResources(); }

        private void ReleaseResources()
        {
            if (!borrowed) return;
            borrowed = false;
            if (--borrowers != 0) return;
            if (rays != null) Object.Destroy(rays);
            if (smoke != null) Object.Destroy(smoke);
            rays = smoke = null;
        }
    }
}
