using System;
using System.IO;
using UnityEngine;

namespace ScomShatter
{
    internal static class CampaignSurfaceAssets
    {
        internal const float NativeScale = 17.66796684f;
        internal const float NativeWidth = 20f * NativeScale;
        internal const float NativeLength = 10f * NativeScale;
        internal const float MaximumLocalDrop = 4f;

        private const string ResourceName = "CampaignSurface.bundle";
        private const string AssetPrefix = "assets/campaign/land-collapse.";
        private static readonly int TimelineId = Shader.PropertyToID("_Animation_Timeline");
        internal static readonly string[] RequiredTextures =
        {
            "_Acceleration_Profile", "_Cracks", "_Diffuse", "_Height",
            "_Land_Displacement", "_Normals", "_Surface_Detail_Diffuse", "_Surface_Detail_Normals"
        };

        private static AssetBundle bundle;
        private static Stream bundleStream;
        private static Mesh mesh;
        private static readonly Mesh[] variants = new Mesh[CampaignWarp.ProfileCount];
        private static Material template;

        internal static Mesh Mesh
        {
            get { EnsureLoaded(); return mesh; }
        }

        internal static Mesh WholeVariant(int profile)
        {
            if (variants[profile] != null) return variants[profile];
            var source = Mesh;
            var bounds = source.bounds;
            var map = Rect.MinMaxRect(bounds.min.x, bounds.min.z, bounds.max.x, bounds.max.z);
            return variants[profile] = FrameSection.WarpLand(source, map, profile);
        }

        // The caller owns this clone; the bundle retains the shared source assets.
        internal static Material CreateMaterial()
        {
            EnsureLoaded();
            return new Material(template) { name = "Campaign Land Collapse" };
        }

        internal static T Load<T>(string canonicalKey) where T : UnityEngine.Object
        {
            EnsureLoaded();
            var asset = bundle.LoadAsset<T>(canonicalKey);
            if (asset == null) throw new InvalidDataException("Missing original campaign asset: " + canonicalKey);
            return asset;
        }

        internal static Material CreateRayMaterial()
        {
            return new Material(Load<Material>("assets/campaign/hole-edge-light.mat"));
        }

        internal static Material CreateSmokeMaterial()
        {
            return new Material(Load<Material>("assets/campaign/smoke-cover.mat"));
        }

        internal static Mesh RayMesh
        {
            get { return Load<Mesh>("assets/campaign/hole-edge-light.mesh"); }
        }

        private static void EnsureLoaded()
        {
            if (bundle != null) return;
            AssetBundle loaded = null;
            Stream stream = null;
            try
            {
                stream = typeof(CampaignSurfaceAssets).Assembly.GetManifestResourceStream(ResourceName);
                if (stream == null) throw new InvalidDataException("Missing original campaign surface bundle.");
                loaded = AssetBundle.LoadFromStream(stream);
                if (loaded == null) throw new InvalidDataException("Unity could not load the original campaign surface bundle.");
                var sourceMesh = loaded.LoadAsset<Mesh>(AssetPrefix + "mesh");
                var sourceMaterial = loaded.LoadAsset<Material>(AssetPrefix + "mat");
                var sourceShader = loaded.LoadAsset<Shader>(AssetPrefix + "shader");
                if (sourceMesh == null || sourceMesh.vertexCount != 205761 || sourceMesh.subMeshCount != 1)
                    throw new InvalidDataException("The original campaign collapse mesh is incomplete.");
                if (sourceShader == null || sourceShader.name != "Shader Graphs/Land Collapse" || !sourceShader.isSupported)
                    throw new NotSupportedException("The original Land Collapse shader is unsupported by this renderer.");
                if (sourceMaterial == null || sourceMaterial.shader != sourceShader
                    || sourceMaterial.FindPass("GBuffer") < 0 || sourceMaterial.FindPass("DepthOnly") < 0)
                    throw new InvalidDataException("The original Land Collapse material or shader passes are incomplete.");
                foreach (string property in RequiredTextures)
                    if (!sourceMaterial.HasProperty(property) || sourceMaterial.GetTexture(property) == null)
                        throw new InvalidDataException("Missing original campaign surface texture: " + property);
                if (!sourceMaterial.HasProperty(TimelineId))
                    throw new InvalidDataException("The original campaign animation property is unavailable.");

                // Preserve the imported graph's native keywords, pass state and queue.
                // HDRP's generic Lit validator does not own this custom Shader Graph.
                mesh = sourceMesh;
                template = sourceMaterial;
                bundleStream = stream;
                bundle = loaded;
            }
            catch
            {
                if (loaded != null) loaded.Unload(true);
                if (stream != null) stream.Dispose();
                throw;
            }
        }

        // Call after every impact object and its material/mesh clones are destroyed.
        internal static void Release()
        {
            for (int i = 0; i < variants.Length; i++)
            {
                if (variants[i] != null) UnityEngine.Object.Destroy(variants[i]);
                variants[i] = null;
            }
            if (bundle != null) bundle.Unload(true);
            if (bundleStream != null) bundleStream.Dispose();
            bundle = null;
            bundleStream = null;
            mesh = null;
            template = null;
        }
    }
}
