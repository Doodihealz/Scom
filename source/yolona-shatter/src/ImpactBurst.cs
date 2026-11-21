using System;
using System.Collections.Generic;
using EM.DOTS.Engine.Loader;
using EM.Gamedata;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using Object = UnityEngine.Object;

namespace ScomShatter
{
    // A one-shot world-space crest. The site supplies simulation age, so pause and
    // speed changes cannot restart the flash or leave an autonomous emitter alive.
    internal sealed class ImpactBurst : IDisposable
    {
        // Particle lifetimes, flipbooks and the light envelope use the authored clock.
        internal const float PlaybackRate = 1f / 3f, ClipDuration = 2.4f;
        private const string MaterialRoot = "VFX/Materials/";
        // Normalized RGB of the installed Seraphim construction beam's contact glow.
        private static readonly Color EnergyBlue = new Color(.0613208f, .4424278f, 1f);
        private static readonly Color CoreBlue = Color.Lerp(EnergyBlue, Color.white, .68f);
        private static Material flareSource, fireSource, waveSource;
        private static bool prepared;
        private static int preparedSession;
        private static readonly HashSet<string> warnings = new HashSet<string>();
        private readonly List<Material> materials = new List<Material>(3);
        private readonly List<ParticleSystem> particles = new List<ParticleSystem>(3);
        private GameObject root;
        private Light pulse;
        private float peakCandela;
        private float simulatedUntil;
        private bool disposed;

        // Native game materials retain their HDRP graph keywords, passes, textures
        // and exposure settings. The native loader owns these shared source assets.
        internal static void Prepare()
        {
            int session = Surface.SessionId;
            if (prepared && preparedSession == session) return;
            Reset();
            prepared = true;
            preparedSession = session;
            flareSource = LoadOptional("Flash/Procedural Flare_Guard Nuke Impact.sanmaterial");
            fireSource = LoadOptional("Explosions/Guard Nuke Impact Explosion.sanmaterial");
            waveSource = LoadOptional("Nuke/Nuke 2_5D Ring Shockwave.sanmaterial");
        }

        private static Material LoadOptional(string path)
        {
            try
            {
                var source = Load.LoadGamedataMaterial(Data.GetFileEntry(MaterialRoot + path))?.GetMaterial();
                if (source == null || source.shader == null || !source.shader.isSupported)
                    throw new NotSupportedException("Unsupported native impact material: " + path);
                return source;
            }
            catch (Exception ex)
            {
                WarnOptional(path, ex);
                return null;
            }
        }

        internal static void Reset()
        {
            // The game loader owns these materials and may unload them with a map.
            prepared = false;
            flareSource = fireSource = waveSource = null;
            warnings.Clear();
        }

        private static void WarnOptional(string layer, Exception error)
        {
            if (warnings.Add(layer))
                Debug.LogWarning("[SCOM Yolona shatter] Optional impact layer unavailable: " + layer + ": " + error.Message);
        }

        internal ImpactBurst(Transform parent, float width, float length, float heightAboveGround)
        {
            if (parent == null) throw new ArgumentNullException(nameof(parent));
            if (!(width > 0f) || !(length > 0f) || float.IsInfinity(width) || float.IsInfinity(length))
                throw new ArgumentOutOfRangeException(nameof(width));
            try
            {
                Prepare();
                root = new GameObject("Yolona impact crest");
                root.transform.SetParent(parent, false);
                root.transform.localPosition = Vector3.up * heightAboveGround;
                // A geometric mean keeps the blast substantial on the campaign's
                // wide footprint without turning the crest into a screen overlay.
                float diameter = Mathf.Sqrt(width * length);
                if (flareSource != null) TryCreate("focus", diameter, CreateFlare);
                if (fireSource != null) TryCreate("fireball", diameter, CreateFireball);
                if (waveSource != null) TryCreate("shock front", diameter, CreateWave);
                TryCreate("point-light pulse", diameter, CreatePulse);
            }
            catch (Exception ex)
            {
                Dispose();
                WarnOptional("crest construction", ex);
            }
        }

        private void TryCreate(string layer, float diameter, Action<float> create)
        {
            int childCount = root.transform.childCount;
            int particleCount = particles.Count;
            int materialCount = materials.Count;
            Light previousPulse = pulse;
            try { create(diameter); }
            catch (Exception ex)
            {
                if (pulse != previousPulse)
                {
                    if (pulse != null) pulse.enabled = false;
                    pulse = previousPulse;
                }
                for (int i = root.transform.childCount - 1; i >= childCount; i--)
                {
                    var child = root.transform.GetChild(i).gameObject;
                    child.SetActive(false);
                    Object.Destroy(child);
                }
                particles.RemoveRange(particleCount, particles.Count - particleCount);
                for (int i = materials.Count - 1; i >= materialCount; i--)
                {
                    Object.Destroy(materials[i]);
                    materials.RemoveAt(i);
                }
                WarnOptional(layer, ex);
            }
        }

        private void CreatePulse(float diameter)
        {
            var owner = new GameObject("Impact terrain and unit light");
            owner.transform.SetParent(root.transform, false);
            owner.transform.localPosition = Vector3.up * (diameter * .16f);
            pulse = owner.AddComponent<Light>();
            pulse.enabled = false;
            pulse.type = LightType.Point;
            pulse.lightUnit = LightUnit.Candela;
            pulse.range = diameter * 1.35f;
            pulse.shadows = LightShadows.None;
            pulse.cullingMask = -1;
            pulse.renderingLayerMask = -1;
            pulse.useColorTemperature = false;
            pulse.intensity = 0f;
            var hd = owner.AddComponent<HDAdditionalLightData>();
            hd.affectDiffuse = true;
            hd.affectSpecular = true;
            hd.affectsVolumetric = false;
            hd.volumetricDimmer = 0f;
            hd.lightDimmer = 1f;
            hd.fadeDistance = 10000f;
            // Point-light intensity is native candela in this installed HDRP.
            // I = E*r^2 gives 30 klux at 0.3 diameters: a strong local crest
            // against HDRP's 100 klux daylight reference, with bounded range.
            float referenceDistance = diameter * .3f;
            peakCandela = 30000f * referenceDistance * referenceDistance;
        }

        private void UpdatePulse(float age)
        {
            if (pulse == null) return;
            if (age >= 1.1f)
            {
                pulse.enabled = false;
                return;
            }
            float strength = age < .055f ? Mathf.SmoothStep(0f, 1f, age / .055f)
                : Mathf.Pow(Mathf.Clamp01((1.1f - age) / 1.045f), 2.7f);
            pulse.color = Color.Lerp(CoreBlue, EnergyBlue, Mathf.Clamp01(age / .85f));
            pulse.intensity = peakCandela * strength;
            pulse.enabled = strength > 0f;
        }

        private Material Clone(Material source, string name)
        {
            var material = new Material(source) { name = name };
            materials.Add(material);
            return material;
        }

        private ParticleSystem CreateSystem(string name, Material material, float lifetime, int count,
            ParticleSystemRenderMode mode)
        {
            var owner = new GameObject(name);
            owner.transform.SetParent(root.transform, false);
            var system = owner.AddComponent<ParticleSystem>();
            particles.Add(system);
            system.Stop(false, ParticleSystemStopBehavior.StopEmittingAndClear);
            system.useAutoRandomSeed = false;
            system.randomSeed = 1771u + (uint)particles.Count;
            var main = system.main;
            main.playOnAwake = false;
            main.loop = false;
            main.duration = lifetime;
            main.startLifetime = lifetime;
            main.startSpeed = 0f;
            main.maxParticles = count;
            main.simulationSpace = ParticleSystemSimulationSpace.Local;
            main.scalingMode = ParticleSystemScalingMode.Local;
            main.cullingMode = ParticleSystemCullingMode.AlwaysSimulate;
            var emission = system.emission;
            emission.enabled = false;
            var shape = system.shape;
            shape.enabled = false;
            var renderer = owner.GetComponent<ParticleSystemRenderer>();
            renderer.sharedMaterial = material;
            renderer.renderMode = mode;
            renderer.alignment = ParticleSystemRenderSpace.View;
            renderer.sortMode = ParticleSystemSortMode.Depth;
            renderer.shadowCastingMode = ShadowCastingMode.Off;
            renderer.receiveShadows = false;
            renderer.lightProbeUsage = LightProbeUsage.Off;
            renderer.reflectionProbeUsage = ReflectionProbeUsage.Off;
            renderer.motionVectorGenerationMode = MotionVectorGenerationMode.ForceNoMotion;
            renderer.maxParticleSize = 5f;
            renderer.SetActiveVertexStreams(new List<ParticleSystemVertexStream>
            {
                ParticleSystemVertexStream.Position, ParticleSystemVertexStream.Normal,
                ParticleSystemVertexStream.Color, ParticleSystemVertexStream.UV,
                ParticleSystemVertexStream.Custom1XY
            });
            system.Play(false);
            system.Pause(false);
            return system;
        }

        private void CreateFlare(float diameter)
        {
            var material = Clone(flareSource, "Yolona blue-white impact focus");
            if (material.HasProperty("_Flare_Color")) material.SetColor("_Flare_Color", CoreBlue);
            var system = CreateSystem("Impact blue-white focus", material, .72f, 1, ParticleSystemRenderMode.Billboard);
            SetSize(system, .45f, .12f, 1f, .5f, .83f, 1f, .55f);
            SetFade(system, .04f, 1f, .27f, .72f, .74f, .13f);
            Emit(system, new Vector3(0f, diameter * .17f, 0f), diameter * 1.36f, Color.white, 0f);
        }

        private void CreateFireball(float diameter)
        {
            var material = Clone(fireSource, "Yolona impact fireball");
            TintComposite(material);
            var system = CreateSystem("Impact expanding fireball", material, 1.88f, 5, ParticleSystemRenderMode.Billboard);
            SetSize(system, .38f, .17f, .95f, .52f, 1.2f, 1f, 1.3f);
            SetFade(system, .045f, 1f, .45f, .94f, .8f, .22f);
            SetFrames(system, .015f, .98f, .6f);
            // Five overlapping lobes read as one turbulent volume from an RTS
            // camera. Each is seeded once; there are no delayed re-flashes.
            Emit(system, new Vector3(0f, diameter * .22f, 0f), diameter * .9f, Color.white, .2f);
            for (int i = 0; i < 4; i++)
            {
                float angle = i * Mathf.PI * .5f + .4f;
                var position = new Vector3(Mathf.Cos(angle) * diameter * .2f,
                    diameter * (.17f + i * .025f), Mathf.Sin(angle) * diameter * .14f);
                Emit(system, position, diameter * (.53f + i * .035f), CoreBlue, angle);
            }
        }

        private void CreateWave(float diameter)
        {
            var material = Clone(waveSource, "Yolona outward shock front");
            TintComposite(material);
            var system = CreateSystem("Impact expanding shock front", material, ClipDuration, 1,
                ParticleSystemRenderMode.HorizontalBillboard);
            SetSize(system, .24f, .1f, .47f, .53f, .8f, 1f, 1f);
            SetFade(system, .04f, .9f, .4f, .7f, .76f, .2f);
            SetFrames(system, .01f, .99f, 0f);
            Emit(system, new Vector3(0f, diameter * .045f, 0f), diameter * 3.2f,
                CoreBlue, 0f);
        }

        private static void TintComposite(Material material)
        {
            if (material.HasProperty("_FlameColor")) material.SetColor("_FlameColor", EnergyBlue);
            TintLighting("_DiffuseColor", Color.Lerp(EnergyBlue, Color.white, .28f));
            TintLighting("_AmbientColor", Color.Lerp(EnergyBlue, Color.white, .48f));

            // The smoke and the ring have separate authored brightness values.
            void TintLighting(string property, Color tint)
            {
                if (!material.HasProperty(property)) return;
                Color original = material.GetColor(property);
                Color shaded = tint * original.maxColorComponent;
                shaded.a = original.a;
                material.SetColor(property, shaded);
            }
        }

        private static void Emit(ParticleSystem system, Vector3 position, float size, Color color, float rotation)
        {
            system.Emit(new ParticleSystem.EmitParams
            {
                position = position,
                velocity = Vector3.zero,
                startSize = size,
                startColor = color,
                rotation = rotation * Mathf.Rad2Deg,
                applyShapeToPosition = false
            }, 1);
        }

        private static void SetSize(ParticleSystem system, float start, float t1, float s1,
            float t2, float s2, float t3, float s3)
        {
            var size = system.sizeOverLifetime;
            size.enabled = true;
            size.size = new ParticleSystem.MinMaxCurve(1f, new AnimationCurve(
                new Keyframe(0f, start), new Keyframe(t1, s1), new Keyframe(t2, s2), new Keyframe(t3, s3)));
        }

        private static void SetFade(ParticleSystem system, float peakTime, float peak,
            float shoulderTime, float shoulder, float tailTime, float tail)
        {
            var gradient = new Gradient();
            gradient.SetKeys(new[] { new GradientColorKey(Color.white, 0f), new GradientColorKey(Color.white, 1f) },
                new[] { new GradientAlphaKey(0f, 0f), new GradientAlphaKey(peak, peakTime),
                    new GradientAlphaKey(shoulder, shoulderTime), new GradientAlphaKey(tail, tailTime),
                    new GradientAlphaKey(0f, 1f) });
            var color = system.colorOverLifetime;
            color.enabled = true;
            color.color = new ParticleSystem.MinMaxGradient(gradient);
        }

        private static void SetFrames(ParticleSystem system, float first, float last, float flame)
        {
            // Installed composite explosion VFX serialize streams [0,1,3,4,32]:
            // Position, Normal, Color, UV, Custom1XY. The native SanVfx loader
            // passes these straight to Unity; X is flipbook age, Y flame decay.
            var custom = system.customData;
            custom.enabled = true;
            custom.SetMode(ParticleSystemCustomData.Custom1, ParticleSystemCustomDataMode.Vector);
            custom.SetVectorComponentCount(ParticleSystemCustomData.Custom1, 2);
            custom.SetVector(ParticleSystemCustomData.Custom1, 0,
                new ParticleSystem.MinMaxCurve(1f, AnimationCurve.Linear(0f, first, 1f, last)));
            custom.SetVector(ParticleSystemCustomData.Custom1, 1, new ParticleSystem.MinMaxCurve(flame,
                new AnimationCurve(new Keyframe(0f, 1f, -2.014936f, -2.014936f),
                    new Keyframe(.5213779f, .2419056f, -.9489685f, -.9489685f),
                    new Keyframe(1f, 0f, -.0644587f, -.0644587f))));
        }

        internal void SetAge(float age)
        {
            if (disposed || age <= simulatedUntil) return;
            if (age >= ClipDuration || float.IsNaN(age))
            {
                Dispose();
                return;
            }
            float delta = age - simulatedUntil;
            for (int i = particles.Count - 1; i >= 0; i--)
            {
                var system = particles[i];
                if (system == null) { particles.RemoveAt(i); continue; }
                try { system.Simulate(delta, false, false, false); }
                catch (Exception ex)
                {
                    if (system != null)
                    {
                        system.gameObject.SetActive(false);
                        Object.Destroy(system.gameObject);
                    }
                    particles.RemoveAt(i);
                    WarnOptional("particle simulation", ex);
                }
            }
            try { UpdatePulse(age); }
            catch (Exception ex)
            {
                if (pulse != null) pulse.enabled = false;
                pulse = null;
                WarnOptional("light simulation", ex);
            }
            simulatedUntil = age;
        }

        public void Dispose()
        {
            if (disposed) return;
            disposed = true;
            if (pulse != null) pulse.enabled = false;
            pulse = null;
            if (root != null)
            {
                root.SetActive(false);
                Object.Destroy(root);
                root = null;
            }
            foreach (var material in materials) if (material != null) Object.Destroy(material);
            materials.Clear();
            particles.Clear();
        }
    }
}
