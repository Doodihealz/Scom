using System;
using EM.Map;
using UnityEngine;

namespace ScomShatter
{
    // Map-specific inputs to the campaign vertex shader. The collapse maps and
    // animation stay in authored UV space; terrain samples follow the physical mesh.
    internal sealed class CampaignGround : IDisposable
    {
        private const int Columns = 640, Rows = 320;
        private const int Width = Columns + 1, Height = Rows + 1;
        private static readonly VertexFilter horizontal = new VertexFilter(Columns);
        private static readonly VertexFilter vertical = new VertexFilter(Rows);
        private readonly Vector3 center;
        private readonly Rect localBounds, worldBounds;
        private readonly FractureLayout layout;
        private float[,] sampled;
        private Vector3[,] sampledNormals;
        private Vector2 sampleOrigin, sampleScale;
        private readonly float[] heights = new float[Width * Height];
        private readonly float[] pixels = new float[Width * Height];
        private readonly ushort[] encoded = new ushort[Width * Height];
        private readonly Color32[] normals = new Color32[Columns * Rows];
        private Texture2D heightMap, normalMap, restCoordinates;
        private Texture2D surfaceNormals;
        internal float InteriorOffset { get; private set; }
        internal Bounds SurfaceBounds { get; private set; }

        // The source has 641x321 vertices, but UV0 was rounded to Half. Address
        // texel centres with _Height_ST, then invert that small bilinear shift.
        // The strictly diagonally dominant tridiagonal systems are separable;
        // each authored vertex recovers its own height, without another blur.
        private sealed class VertexFilter
        {
            internal readonly float[] UV;
            private readonly float[] lower, upper, inverse;

            internal VertexFilter(int intervals)
            {
                int count = intervals + 1;
                UV = new float[count];
                lower = new float[count]; upper = new float[count]; inverse = new float[count];
                for (int i = 0; i < count; i++)
                {
                    UV[i] = Mathf.HalfToFloat(Mathf.FloatToHalf((float)i / intervals));
                    float offset = UV[i] * intervals - i;
                    lower[i] = Mathf.Max(-offset, 0f);
                    float diagonal = 1f - Mathf.Abs(offset);
                    inverse[i] = 1f / (diagonal - (i > 0 ? lower[i] * upper[i - 1] : 0f));
                    upper[i] = Mathf.Max(offset, 0f) * inverse[i];
                }
            }

            internal void Solve(float[] values, int start, int stride)
            {
                values[start] *= inverse[0];
                for (int i = 1, p = start + stride; i < UV.Length; i++, p += stride)
                    values[p] = (values[p] - lower[i] * values[p - stride]) * inverse[i];
                for (int i = UV.Length - 2, p = start + i * stride; i >= 0; i--, p -= stride)
                    values[p] -= upper[i] * values[p + stride];
            }

            internal float Source(float uv)
            {
                int intervals = UV.Length - 1;
                int i = Math.Min((int)(uv * intervals), intervals - 1);
                if (i > 0 && uv < UV[i]) i--;
                if (i < intervals - 1 && uv > UV[i + 1]) i++;
                return (i + (uv - UV[i]) / (UV[i + 1] - UV[i])) / intervals;
            }
        }

        internal CampaignGround(Vector3 center, Rect localBounds, FractureLayout layout)
        {
            this.center = center;
            this.localBounds = localBounds;
            this.layout = layout;
            worldBounds = layout.SiteBounds(localBounds);
        }

        internal void Update(Material material)
        {
            Capture(out float low, out float high);
            const float scale = CampaignSurfaceAssets.NativeScale;
            float depth = Mathf.Max(.92f, (Mathf.Max(Mathf.Abs(low), Mathf.Abs(high)) + 4f) / scale);
            float edge = material.GetFloat("_Edge_Size"), lip = material.GetFloat("_Edge_Bump");
            for (int z = 0; z < Height; z++) for (int x = 0; x < Width; x++)
            {
                float lx = (.5f - (float)x / Columns) * ShatterEffect.Width;
                float lz = ((float)z / Rows - .5f) * ShatterEffect.Length;
                float ex = 2f * lx / SurfaceOpening.Width;
                float ez = 2f * (lz - SurfaceOpening.OffsetZ) / SurfaceOpening.Length;
                float radius = Mathf.Sqrt(ex * ex + ez * ez);
                // Only intact-terrain overlap is buried. The supported interior
                // keeps the native terrain height, including directly at the rim.
                float margin = Mathf.SmoothStep(0f, 1f, Mathf.InverseLerp(1f, 1.035f, radius));
                float burial = radius > 1f ? .005f + 2f * margin : 0f;
                burial = Mathf.Max(burial, OpeningFootprint.CollarBurial((float)x / Columns, (float)z / Rows));
                Vector2 point = layout.SourceToNative(new Vector2(lx, lz));
                heights[z * Width + x] = Sample(point.x, point.y) - burial;
            }

            // R16 needs headroom for inverse-filter overshoot as well as relief.
            // Increase the range before quantizing rather than silently clipping a peak.
            bool fits = false;
            for (int attempt = 0; attempt < 4; attempt++, depth *= 2f)
            {
                for (int z = 0; z < Height; z++) for (int x = 0; x < Width; x++)
                {
                    float u = 2f * horizontal.UV[x] - 1f, v = 2f * vertical.UV[z] - 1f;
                    float q = Mathf.Clamp01(Mathf.Sqrt(u * u + v * v) * (1f - edge) + edge);
                    float bump = 2f * Mathf.Min(q, 1f - q) * lip;
                    pixels[z * Width + x] = .5f + heights[z * Width + x] / (2f * depth * scale) - bump;
                }
                for (int z = 0; z < Height; z++) horizontal.Solve(pixels, z * Width, 1);
                for (int x = 0; x < Width; x++) vertical.Solve(pixels, x, Width);
                fits = true;
                for (int i = 0; i < pixels.Length; i++)
                    if (pixels[i] < 0f || pixels[i] > 1f || float.IsNaN(pixels[i])) { fits = false; break; }
                if (fits) break;
            }
            if (!fits) throw new InvalidOperationException("Campaign terrain height exceeds the shader's R16 range.");
            for (int i = 0; i < pixels.Length; i++) encoded[i] = (ushort)Mathf.RoundToInt(65535f * pixels[i]);

            for (int z = 0; z < Rows; z++) for (int x = 0; x < Columns; x++)
            {
                float lx = (.5f - horizontal.Source((x + .5f) / Columns)) * ShatterEffect.Width;
                float lz = (vertical.Source((z + .5f) / Rows) - .5f) * ShatterEffect.Length;
                Vector2 point = layout.SourceToNative(new Vector2(lx, lz));
                Vector3 normal = Normal(point.x, point.y);
                // The physical tangent/bitangent stay -X/-Z even on a warped mesh.
                // Rotation changes this basis; its nonuniform scale does not.
                float nx = normal.x, nz = normal.z;
                switch (layout.QuarterTurns)
                {
                    case 1: nx = -normal.z; nz = normal.x; break;
                    case 2: nx = -normal.x; nz = -normal.z; break;
                    case 3: nx = normal.z; nz = -normal.x; break;
                }
                byte r = (byte)Mathf.Clamp(Mathf.RoundToInt((.5f - .5f * nx) * 255f), 0, 255);
                byte g = (byte)Mathf.Clamp(Mathf.RoundToInt((.5f - .5f * nz) * 255f), 0, 255);
                normals[z * Columns + x] = new Color32(255, g, 255, r);
            }
            if (heightMap == null)
                heightMap = new Texture2D(Width, Height, TextureFormat.R16, false, true)
                    { name = "Campaign terrain height", wrapMode = TextureWrapMode.Clamp, filterMode = FilterMode.Bilinear };
            if (normalMap == null)
                normalMap = new Texture2D(Columns, Rows, TextureFormat.RGBA32, true, true)
                    { name = "Campaign terrain normals", wrapMode = TextureWrapMode.Clamp, filterMode = FilterMode.Trilinear };
            heightMap.SetPixelData(encoded, 0); heightMap.Apply(false, false);
            normalMap.SetPixelData(normals, 0); normalMap.Apply(true, false);
            material.SetTexture("_Height", heightMap);
            material.SetTextureScale("_Height", new Vector2((float)Columns / Width, (float)Rows / Height));
            material.SetTextureOffset("_Height", new Vector2(.5f / Width, .5f / Height));
            material.SetFloat("_Height_Depth", depth); material.SetFloat("_Height_Offset", 0f);
            material.SetTexture("_Normals", surfaceNormals != null ? surfaceNormals : normalMap);
            material.SetTextureScale("_Normals", Vector2.one);
            material.SetTextureOffset("_Normals", Vector2.zero);
            if (restCoordinates != null) RefreshRestCoordinates();
            InteriorOffset = Mathf.Min(0f, low + 30f);
            var a = new Vector3(localBounds.xMin / scale, low / scale - CampaignSurfaceAssets.MaximumLocalDrop - 1f, localBounds.yMin / scale);
            var b = new Vector3(localBounds.xMax / scale, high / scale + 1f, localBounds.yMax / scale);
            SurfaceBounds = new Bounds((a + b) * .5f, b - a);
        }

        // The fallback atlas includes this terrain's macro normal and the actual
        // map strata bumps. Its renderer owns the atlas and replaces it atomically.
        internal void SetSurfaceNormals(Material material,Texture2D texture)
        {
            surfaceNormals=texture;
            material.SetTexture("_Normals",texture != null ? texture : normalMap);
            material.SetTextureScale("_Normals",Vector2.one);
            material.SetTextureOffset("_Normals",Vector2.zero);
        }

        // The native terrain material samples this field through the same ST as
        // _Height. XYZ are the uncollapsed world position, before collar burial;
        // W is the quarter-turn orientation used by the native terrain normal basis.
        internal Texture2D EnsureRestCoordinates()
        {
            if (restCoordinates != null) return restCoordinates;
            if (sampled == null) throw new InvalidOperationException("Campaign terrain must be captured before binding its coordinates.");
            restCoordinates = new Texture2D(Width, Height, TextureFormat.RGBAFloat, false, true)
                { name = "Campaign terrain rest coordinates", wrapMode = TextureWrapMode.Clamp, filterMode = FilterMode.Bilinear };
            try { RefreshRestCoordinates(); }
            catch
            {
                UnityEngine.Object.Destroy(restCoordinates);
                restCoordinates = null;
                throw;
            }
            return restCoordinates;
        }

        private void RefreshRestCoordinates()
        {
            // Write into Unity's existing CPU copy. Retaining a separate color
            // array would cost another 3.1 MiB for every persistent chasm.
            var coordinates = restCoordinates.GetRawTextureData<Color>();
            for (int z = 0; z < Height; z++) for (int x = 0; x < Width; x++)
            {
                var source = new Vector2((.5f - (float)x / Columns) * ShatterEffect.Width,
                    ((float)z / Rows - .5f) * ShatterEffect.Length);
                Vector2 native = layout.SourceToNative(source), site = layout.ToSite(native);
                coordinates[z * Width + x] = new Color(center.x + site.x,
                    center.y + Sample(native.x, native.y), center.z + site.y, layout.QuarterTurns);
            }
            for (int channel = 0; channel < 3; channel++)
            {
                for (int i = 0; i < pixels.Length; i++) pixels[i] = coordinates[i][channel];
                for (int z = 0; z < Height; z++) horizontal.Solve(pixels, z * Width, 1);
                for (int x = 0; x < Width; x++) vertical.Solve(pixels, x, Width);
                for (int i = 0; i < pixels.Length; i++)
                {
                    Color coordinate = coordinates[i];
                    coordinate[channel] = pixels[i];
                    coordinates[i] = coordinate;
                }
            }
            restCoordinates.Apply(false, false);
        }

        private void Capture(out float low, out float high)
        {
            var terrain = MapManager.Terrain;
            var data = terrain.terrainData;
            Vector3 origin = terrain.GetPosition(), size = data.size;
            int resolution = data.heightmapResolution - 1;
            Vector2 step = new Vector2(size.x / resolution, size.z / resolution);
            // Keep the native grid and a Sobel/filter halo. An arbitrary resampling
            // lattice smooths the terrain twice and flattens clipped patch edges.
            int x0 = Mathf.Clamp(Mathf.FloorToInt((center.x + worldBounds.xMin - origin.x) / step.x) - 2, 0, resolution - 1);
            int z0 = Mathf.Clamp(Mathf.FloorToInt((center.z + worldBounds.yMin - origin.z) / step.y) - 2, 0, resolution - 1);
            int x1 = Mathf.Clamp(Mathf.CeilToInt((center.x + worldBounds.xMax - origin.x) / step.x) + 2, x0 + 1, resolution);
            int z1 = Mathf.Clamp(Mathf.CeilToInt((center.z + worldBounds.yMax - origin.z) / step.y) + 2, z0 + 1, resolution);
            sampled = data.GetHeights(x0, z0, x1 - x0 + 1, z1 - z0 + 1);
            int nx = sampled.GetLength(1), nz = sampled.GetLength(0);
            if (sampledNormals == null || sampledNormals.GetLength(1) != nx || sampledNormals.GetLength(0) != nz)
                sampledNormals = new Vector3[nz, nx];
            sampleOrigin = new Vector2(origin.x + x0 * step.x - center.x, origin.z + z0 * step.y - center.z);
            sampleScale = new Vector2(1f / step.x, 1f / step.y);
            low = float.PositiveInfinity; high = float.NegativeInfinity;
            for (int z = 0; z < nz; z++) for (int x = 0; x < nx; x++)
            {
                float y = sampled[z, x] * size.y + origin.y - center.y;
                sampled[z, x] = y; low = Mathf.Min(low, y); high = Mathf.Max(high, y);
            }
            // Unity interpolates normalized Sobel normals from native grid points.
            for (int z = 0; z < nz; z++) for (int x = 0; x < nx; x++)
            {
                int l = Math.Max(x - 1, 0), r = Math.Min(x + 1, nx - 1);
                int b = Math.Max(z - 1, 0), t = Math.Min(z + 1, nz - 1);
                float dx = (sampled[b, r] + 2f * sampled[z, r] + sampled[t, r]
                    - sampled[b, l] - 2f * sampled[z, l] - sampled[t, l]) / (8f * step.x);
                float dz = (sampled[t, l] + 2f * sampled[t, x] + sampled[t, r]
                    - sampled[b, l] - 2f * sampled[b, x] - sampled[b, r]) / (8f * step.y);
                sampledNormals[z, x] = new Vector3(-dx, 1f, -dz).normalized;
            }
        }

        private void Address(float x, float z, out int ix, out int iz, out float fx, out float fz)
        {
            Vector2 p = layout.ToSite(new Vector2(x, z));
            int nx = sampled.GetLength(1) - 1, nz = sampled.GetLength(0) - 1;
            float u = Mathf.Clamp((p.x - sampleOrigin.x) * sampleScale.x, 0f, nx);
            float v = Mathf.Clamp((p.y - sampleOrigin.y) * sampleScale.y, 0f, nz);
            ix = Math.Min((int)u, nx - 1); iz = Math.Min((int)v, nz - 1);
            fx = u - ix; fz = v - iz;
        }

        internal float Sample(float x, float z)
        {
            Address(x, z, out int ix, out int iz, out float fx, out float fz);
            return Mathf.Lerp(Mathf.Lerp(sampled[iz, ix], sampled[iz, ix + 1], fx),
                Mathf.Lerp(sampled[iz + 1, ix], sampled[iz + 1, ix + 1], fx), fz);
        }

        private Vector3 Normal(float x, float z)
        {
            Address(x, z, out int ix, out int iz, out float fx, out float fz);
            return Vector3.Lerp(Vector3.Lerp(sampledNormals[iz, ix], sampledNormals[iz, ix + 1], fx),
                Vector3.Lerp(sampledNormals[iz + 1, ix], sampledNormals[iz + 1, ix + 1], fx), fz).normalized;
        }

        public void Dispose()
        {
            if (heightMap != null) UnityEngine.Object.Destroy(heightMap);
            if (normalMap != null) UnityEngine.Object.Destroy(normalMap);
            if (restCoordinates != null) UnityEngine.Object.Destroy(restCoordinates);
            heightMap = null; normalMap = null; restCoordinates = null; surfaceNormals = null;
        }
    }
}
