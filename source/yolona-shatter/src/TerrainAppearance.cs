using System;
using EM.Map;
using EM.Controls.Cameras;
using UnityEngine;

namespace ScomShatter
{
    // Owns only managed readbacks. Native textures remain owned by the map;
    // Surface drops this cache when the terrain or map session changes.
    internal sealed class TerrainAppearance
    {
        private const int TextureLimit = 1024;
        private static readonly Color Fallback = new Color(.27f, .24f, .21f, 1f);
        private static readonly float[] Linear = MakeLinearTable();
        private static readonly byte[] Gamma = MakeGammaTable();
        private readonly Layer[] layers;
        private readonly Pixels splat0, splat1, tint, normalTint;
        private readonly Settings settings;
        private readonly Heights heights;
        private readonly Vector3 cameraPosition;
        internal bool HasAlbedo { get; private set; }

        private sealed class Layer
        {
            internal Pixels Albedo, Mask, Normal;
            internal Vector2 Tile, FarTile;
            internal Color Remap, FarRemap;
            internal Vector4 Flip, MaskMin, MaskMax, NormalScale;
        }

        private sealed class Settings
        {
            internal float HeightTransition, FadeStart, FadeDistance, TintHidden;
            internal Vector4 HiddenFirst, HiddenSecond, Water;
            internal float Freezing;
            internal Pixels WaterDepth;
        }

        private sealed class Heights
        {
            internal float[,] Values;
            internal Vector3[,] Normals;
            internal Vector2 Origin, Scale;
            internal float Base, Range;

            internal float Sample(float u, float v)
            {
                float x = Mathf.Clamp((u - Origin.x) * Scale.x, 0f, Values.GetLength(1) - 1);
                float y = Mathf.Clamp((v - Origin.y) * Scale.y, 0f, Values.GetLength(0) - 1);
                int x0 = Mathf.FloorToInt(x), y0 = Mathf.FloorToInt(y);
                int x1 = Math.Min(x0 + 1, Values.GetLength(1) - 1);
                int y1 = Math.Min(y0 + 1, Values.GetLength(0) - 1);
                return Base + Range * Mathf.Lerp(
                    Mathf.Lerp(Values[y0, x0], Values[y0, x1], x - x0),
                    Mathf.Lerp(Values[y1, x0], Values[y1, x1], x - x0), y - y0);
            }

            internal Vector3 Normal(float u, float v)
            {
                float x = Mathf.Clamp((u - Origin.x) * Scale.x, 0f, Values.GetLength(1) - 1);
                float y = Mathf.Clamp((v - Origin.y) * Scale.y, 0f, Values.GetLength(0) - 1);
                int x0 = (int)x, y0 = (int)y;
                int x1 = Math.Min(x0 + 1, Values.GetLength(1) - 1), y1 = Math.Min(y0 + 1, Values.GetLength(0) - 1);
                return Vector3.LerpUnclamped(Vector3.LerpUnclamped(Normals[y0,x0], Normals[y0,x1], x-x0),
                    Vector3.LerpUnclamped(Normals[y1,x0], Normals[y1,x1], x-x0), y-y0).normalized;
            }
        }

        private sealed class Pixels
        {
            internal int Width, Height;
            internal Color32[] Values;
            internal bool Srgb;
            internal Vector2 Origin, InverseScale = Vector2.one, SourceTexel;

            internal Color Sample(float u, float v, bool repeat)
            {
                int width = Width, height = Height;
                u = repeat ? Mathf.Repeat(u, 1f) : Mathf.Clamp01((u-Origin.x)*InverseScale.x);
                v = repeat ? Mathf.Repeat(v, 1f) : Mathf.Clamp01((v-Origin.y)*InverseScale.y);
                // GPU bilinear coordinates place centers at (i + .5) / size.
                // In repeat mode the last and first texels interpolate together.
                float px = u * width - .5f, py = v * height - .5f;
                int x0 = Mathf.FloorToInt(px), y0 = Mathf.FloorToInt(py);
                float tx = px - x0, ty = py - y0;
                int x1 = Index(x0 + 1, width, repeat), y1 = Index(y0 + 1, height, repeat);
                x0 = Index(x0, width, repeat); y0 = Index(y0, height, repeat);
                var pixels = Values;
                return Color.LerpUnclamped(
                    Color.LerpUnclamped(Decode(pixels[y0 * width + x0], Srgb), Decode(pixels[y0 * width + x1], Srgb), tx),
                    Color.LerpUnclamped(Decode(pixels[y1 * width + x0], Srgb), Decode(pixels[y1 * width + x1], Srgb), tx), ty);
            }

            private static int Index(int value, int size, bool repeat)
            {
                if (!repeat) return Mathf.Clamp(value, 0, size - 1);
                int index = value % size;
                return index < 0 ? index + size : index;
            }
        }

        private TerrainAppearance(Layer[] layers, Settings settings, Pixels first = null,
            Pixels second = null, Pixels tint = null, Heights heights = null, Vector3 cameraPosition = default(Vector3),
            Pixels normalTint = null)
        {
            this.layers = layers;
            this.settings = settings;
            splat0 = first; splat1 = second;
            this.tint = tint; this.normalTint = normalTint; this.heights = heights; this.cameraPosition = cameraPosition;
            HasAlbedo = layers.Length > 0 && layers[0] != null;
        }

        internal static TerrainAppearance Capture(Material material, SanMap map, float dx, float dz)
        {
            var strata = map.stratumLayers;
            if (material == null || strata == null)
                return new TerrainAppearance(new Layer[0], new Settings());

            var layers = new Layer[Math.Min(material.IsKeywordEnabled("_TERRAIN_8_LAYERS_RTS") ? 9 : 5, strata.Length)];
            for (int i = 0; i < layers.Length; ++i)
            {
                if (strata[i] == null) continue;
                string suffix = i.ToString();
                string textureName = "_LayerAlbedo" + suffix;
                if (!material.HasProperty(textureName)) continue;
                Vector2 tile = Tile(material, "_LayerTilling" + suffix, strata[i].tileSize);
                Vector2 farTile = Tile(material, "_LayerTillingFar" + suffix, strata[i].tileSizeFar);
                int width = Mathf.Clamp(Mathf.CeilToInt(2f * Mathf.Max(tile.x, farTile.x) / dx), 1, TextureLimit);
                int height = Mathf.Clamp(Mathf.CeilToInt(2f * Mathf.Max(tile.y, farTile.y) / dz), 1, TextureLimit);
                Pixels albedo = Readback(material.GetTexture(textureName), true, width, height);
                if (albedo == null) continue;
                layers[i] = new Layer
                {
                    Albedo = albedo,
                    Normal = Readback(material.GetTexture("_LayerNormal" + suffix), false, width, height),
                    Mask = Readback(material.GetTexture("_LayerMask" + suffix), false, width, height),
                    Tile = tile, FarTile = farTile,
                    Remap = (Color)Vector(material, "_LayerDiffuseRemapScale" + suffix, strata[i].diffuseRemap),
                    FarRemap = (Color)Vector(material, "_LayerDiffuseFarRemapScale" + suffix, strata[i].farColorRemap.linear),
                    Flip = Vector(material, "_LayerTextureFlip" + suffix, Vector4.zero),
                    NormalScale = Vector(material, "_LayerNormalScale" + suffix,
                        new Vector4(strata[i].normalScale, strata[i].normalScaleFar, strata[i].normalFarNearBlend, 1f)),
                    MaskMin = Vector(material, "_LayerMaskMapRemapOffset" + suffix, strata[i].maskRemapMin),
                    MaskMax = Vector(material, "_LayerMaskMapRemapScale" + suffix, strata[i].maskRemapMax)
                };
            }
            var settings = new Settings
            {
                HeightTransition = material.GetFloat("_HeightTransition"),
                FadeStart = material.GetFloat("_FadeStartDistance"),
                FadeDistance = Mathf.Max(.1f, material.GetFloat("_FadeDistance")),
                HiddenFirst = Vector(material, "_TerrainVisibilityLayer14", Vector4.zero),
                HiddenSecond = Vector(material, "_TerrainVisibilityLayer58", Vector4.zero),
                TintHidden = Vector(material, "_TerrainVisibilityTints", Vector4.zero).x,
                Water = Shader.GetGlobalVector("_WaterLevel"),
                Freezing = Shader.GetGlobalFloat("_WaterFreezing"),
                WaterDepth = Readback(material.GetTexture("_WaterDepthMask"), false, 1024, 32)
            };
            return new TerrainAppearance(layers, settings);
        }

        private static Vector4 Vector(Material material, string name, Vector4 fallback)
        {
            return material.HasProperty(name) ? material.GetVector(name) : fallback;
        }

        private static Vector2 Tile(Material material, string name, Vector2 fallback)
        {
            Vector4 value = Vector(material, name, Vector4.zero);
            return new Vector2(value.x > 0 ? 1f / value.x : Mathf.Max(.001f, fallback.x),
                value.y > 0 ? 1f / value.y : Mathf.Max(.001f, fallback.y));
        }

        internal TerrainAppearance CapturePatch(Rect region, int width, int height)
        {
            if (!HasAlbedo) return this;
            var first = ReadRegion(MapManager.splat0, region, width, height);
            var second = ReadRegion(MapManager.splat1, region, width, height);
            var terrain = MapManager.Terrain;
            var data = terrain.terrainData;
            int resolution = data.heightmapResolution - 1;
            int x0 = Mathf.Clamp(Mathf.FloorToInt(region.xMin * resolution)-2, 0, resolution);
            int y0 = Mathf.Clamp(Mathf.FloorToInt(region.yMin * resolution)-2, 0, resolution);
            int x1 = Mathf.Clamp(Mathf.CeilToInt(region.xMax * resolution)+2, x0, resolution);
            int y1 = Mathf.Clamp(Mathf.CeilToInt(region.yMax * resolution)+2, y0, resolution);
            var capturedHeights = new Heights
            {
                Values = data.GetHeights(x0, y0, x1 - x0 + 1, y1 - y0 + 1),
                Origin = new Vector2((float)x0 / resolution, (float)y0 / resolution),
                Scale = new Vector2(resolution, resolution),
                Base = terrain.GetPosition().y, Range = data.size.y
            };
            int nx = capturedHeights.Values.GetLength(1), nz = capturedHeights.Values.GetLength(0);
            capturedHeights.Normals = new Vector3[nz,nx];
            float stepX = data.size.x/resolution, stepZ = data.size.z/resolution;
            for (int z = 0; z < nz; z++) for (int x = 0; x < nx; x++)
            {
                int l = Math.Max(0,x-1), r = Math.Min(nx-1,x+1), b = Math.Max(0,z-1), t = Math.Min(nz-1,z+1);
                var h = capturedHeights.Values;
                float dx = (h[b,r]+2*h[z,r]+h[t,r]-h[b,l]-2*h[z,l]-h[t,l])*data.size.y/(8*stepX);
                float dz = (h[t,l]+2*h[t,x]+h[t,r]-h[b,l]-2*h[b,x]-h[b,r])*data.size.y/(8*stepZ);
                capturedHeights.Normals[z,x] = new Vector3(-dx,1,-dz).normalized;
            }
            Camera camera = MainCamera.Cam;
            return new TerrainAppearance(layers, settings, first, second,
                ReadRegion(MapManager.tintMap, region, width, height), capturedHeights,
                camera != null ? camera.transform.position : Vector3.zero,
                ReadRegion(MapManager.normalTintMap, region, width, height));
        }

        // Call these on the Unity thread. Re-bakes share immutable CPU texture/height
        // snapshots; camera movement never repeats the GPU readbacks.
        internal TerrainAppearance WithCurrentCamera()
        {
            Camera camera = MainCamera.Cam;
            return camera == null ? this : new TerrainAppearance(layers, settings,
                splat0, splat1, tint, heights, camera.transform.position, normalTint);
        }

        internal bool NeedsDistanceRefresh(Vector3 center, float radius)
        {
            Camera camera = MainCamera.Cam;
            if (!HasAlbedo || camera == null) return false;
            Vector3 current = camera.transform.position;
            if ((current - cameraPosition).sqrMagnitude < 1f) return false;
            float oldDistance = Vector3.Distance(cameraPosition, center);
            float newDistance = Vector3.Distance(current, center);
            float farDistance = settings.FadeStart + settings.FadeDistance;
            if (Mathf.Max(oldDistance, newDistance) + radius <= settings.FadeStart ||
                Mathf.Min(oldDistance, newDistance) - radius >= farDistance) return false;
            // The cap lies over an XZ footprint. Probe its center and eight rim
            // directions so an orbit through a blend region also refreshes it.
            if (FadeChanged(center, current)) return true;
            for (int z = -1; z <= 1; ++z)
                for (int x = -1; x <= 1; ++x)
                {
                    if (x == 0 && z == 0) continue;
                    float scale = x != 0 && z != 0 ? radius * .70710678f : radius;
                    if (FadeChanged(center + new Vector3(x * scale, 0f, z * scale), current)) return true;
                }
            return false;
        }

        private bool FadeChanged(Vector3 position, Vector3 currentCamera)
        {
            float oldFade = Mathf.Clamp01((Vector3.Distance(cameraPosition, position) - settings.FadeStart) / settings.FadeDistance);
            float newFade = Mathf.Clamp01((Vector3.Distance(currentCamera, position) - settings.FadeStart) / settings.FadeDistance);
            return Mathf.Abs(oldFade - newFade) >= .15f;
        }

        // Align the regional readback to source texel edges and retain the two neighbors
        // the terrain's bilinear sampler can use at a clipped impact boundary.
        private static Pixels ReadRegion(Texture source,Rect region,int maxWidth,int maxHeight)
        {
            if(source==null || source.width<1 || source.height<1) return null;
            int w=source.width,h=source.height;
            int x0=Mathf.Clamp(Mathf.FloorToInt(region.xMin*w)-1,0,w-1);
            int x1=Mathf.Clamp(Mathf.CeilToInt(region.xMax*w)+1,x0+1,w);
            int y0=Mathf.Clamp(Mathf.FloorToInt(region.yMin*h)-1,0,h-1);
            int y1=Mathf.Clamp(Mathf.CeilToInt(region.yMax*h)+1,y0+1,h);
            var uv=new Rect((float)x0/w,(float)y0/h,(float)(x1-x0)/w,(float)(y1-y0)/h);
            return Readback(source,false,Math.Min(maxWidth,x1-x0),Math.Min(maxHeight,y1-y0),uv);
        }

        internal bool TrySample(float x, float z, float u, float v, bool includeNormals, out Color color, out Vector3 normal,
            BakedWallProjection.SurfaceSample projection = default(BakedWallProjection.SurfaceSample))
        {
            normal = Vector3.up;
            if (!HasAlbedo) { color = Fallback; return false; }
            // Native alphamaps address the centers of the first/last texels at the map edges.
            float su = u, sv = v;
            if (splat0 != null)
            {
                su = u * (1f - splat0.SourceTexel.x) + .5f * splat0.SourceTexel.x;
                sv = v * (1f - splat0.SourceTexel.y) + .5f * splat0.SourceTexel.y;
            }
            Color first = splat0 == null ? Color.clear : splat0.Sample(su, sv, false);
            Color second = splat1 == null ? Color.clear : splat1.Sample(su, sv, false);
            float restY = heights == null ? 0f : heights.Sample(u, v);
            Vector3 macroNormal = includeNormals || projection.Drop > .25f
                ? (heights == null ? Vector3.up : heights.Normal(u, v)) : Vector3.up;
            Vector3 face = macroNormal;
            float exposed = 0f;
            if (projection.Drop > .25f)
            {
                float inverseUp = 1f / Mathf.Max(.001f, macroNormal.y);
                face = new Vector3(macroNormal.x * inverseUp + projection.Dx, 1f,
                    macroNormal.z * inverseUp + projection.Dz).normalized;
                exposed = (1f - SmoothRange(.35f, .65f, Mathf.Abs(face.y))) * SmoothRange(.25f, 1.5f, projection.Drop);
            }
            float y = restY - projection.Drop * exposed;
            float fade = Mathf.Clamp01((Vector3.Distance(cameraPosition, new Vector3(x, y, z)) - settings.FadeStart) / settings.FadeDistance);
            int firstLayer = 0;
            // An opaque overlay replaces albedo, mask height and detail normals
            // alike. Skip everything it would overwrite before texture sampling.
            for (int i = layers.Length - 1; i > 0; --i)
                if (layers[i] != null && Weight(i, first, second) *
                    (1f - (i <= 4 ? settings.HiddenFirst[i - 1] : settings.HiddenSecond[i - 5])) >= .99f)
                { firstLayer = i; break; }
            Vector3 tintDetail = Vector3.forward;
            if (includeNormals)
            {
                Color encodedTint = normalTint == null ? new Color(.5f,.5f,1f,1f) : normalTint.Sample(u,v,false);
                float tx = Mathf.LerpUnclamped(encodedTint.r,.5f,settings.TintHidden)*2f-1f;
                float tz = Mathf.LerpUnclamped(encodedTint.g,.5f,settings.TintHidden)*2f-1f;
                tintDetail = new Vector3(tx,tz,Mathf.Sqrt(1f-Mathf.Clamp01(tx*tx+tz*tz)));
            }
            LayerSample surface;
            float maskHeight;
            if (exposed <= 0f)
            {
                surface = EvaluateLayers(x,z,first,second,firstLayer,fade,includeNormals);
                color = surface.Color; maskHeight = surface.Height;
                if (includeNormals) normal = CapNormal(surface.Detail,tintDetail,macroNormal);
            }
            else
            {
                float wx = Mathf.Max(Mathf.Abs(face.x) - .1f, 0f), wz = Mathf.Max(Mathf.Abs(face.z) - .1f, 0f);
                wx *= wx; wx *= wx; wz *= wz; wz *= wz;
                float weightX = wx / Mathf.Max(wx + wz, .00000001f);
                bool projectX = weightX >= .5f;
                surface = EvaluateLayers(projectX ? z : x,restY-projection.Drop,first,second,firstLayer,fade,includeNormals);
                color = surface.Color; maskHeight = surface.Height;
                if (includeNormals) normal = WallNormal(surface.Detail,tintDetail,macroNormal,face,projectX);
                if (weightX > .0001f && weightX < .9999f)
                {
                    // Blend oblique projections before the cap transition, so
                    // its limit remains continuous as exposure reaches one.
                    LayerSample other = EvaluateLayers(projectX ? x : z,restY-projection.Drop,first,second,firstLayer,fade,includeNormals);
                    float weight = projectX ? 1f-weightX : weightX;
                    color = Color.LerpUnclamped(color,other.Color,weight);
                    maskHeight = Mathf.LerpUnclamped(maskHeight,other.Height,weight);
                    if (includeNormals) normal = Vector3.LerpUnclamped(normal,WallNormal(other.Detail,tintDetail,macroNormal,face,!projectX),weight).normalized;
                }
                if (exposed < 1f)
                {
                    // Blend evaluated material values, never absolute UV axes:
                    // interpolating world Z into Y sweeps kilometres of texture.
                    // Only oblique faces inside this narrow transition need a
                    // third evaluation; flats and cardinal walls retain one.
                    LayerSample cap = EvaluateLayers(x,z,first,second,firstLayer,fade,includeNormals);
                    color = Color.LerpUnclamped(cap.Color,color,exposed);
                    maskHeight = Mathf.LerpUnclamped(cap.Height,maskHeight,exposed);
                    if (includeNormals) normal = Vector3.LerpUnclamped(CapNormal(cap.Detail,tintDetail,macroNormal),normal,exposed).normalized;
                }
            }
            Color macro = tint == null ? Color.gray : tint.Sample(u, v, false);
            macro = Color.LerpUnclamped(macro, Color.gray, settings.TintHidden);
            float belowWater = settings.Water.x - y;
            float wet = Mathf.Clamp01(belowWater * 4f + .8f);
            float darken = 1f - .4f * Mathf.Clamp01(2f * wet * (1f - settings.Freezing) + Mathf.Clamp01(maskHeight - .5f) - 1f);
            color *= macro * (2f * darken);
            if (settings.WaterDepth != null && settings.Water.y != 0f)
            {
                Color depth = settings.WaterDepth.Sample(Mathf.Clamp01(belowWater / settings.Water.y), .5f, false);
                color = Color.LerpUnclamped(color, depth, depth.a * settings.Water.w);
            }
            float ice = Mathf.Clamp01(belowWater * 1.5f + .8f);
            ice = ice * ice * settings.Freezing * .5f;
            color = Color.LerpUnclamped(color, new Color(.38005632f, .42003337f, .44798842f, 1f), ice);
            color.a = 1f;
            return true;
        }

        private struct LayerSample
        {
            internal Color Color;
            internal Vector3 Detail;
            internal float Height;
        }

        private LayerSample EvaluateLayers(float x,float z,Color first,Color second,int firstLayer,float fade,bool includeNormals)
        {
            Color near = Color.clear, far = Color.clear;
            Vector3 nearNormal = Vector3.forward, farNormal = Vector3.forward;
            float nearHeight = 0f, farHeight = 0f;
            for (int i = firstLayer; i < layers.Length; ++i)
            {
                Layer layer = layers[i];
                if (layer == null) continue;
                float painted = i == 0 ? 1f : Weight(i, first, second) *
                    (1f - (i <= 4 ? settings.HiddenFirst[i - 1] : settings.HiddenSecond[i - 5]));
                if (painted <= 0f) continue;
                float h = MaskHeight(layer, x, z, layer.Tile);
                Color sample = layer.Albedo.Sample(x / layer.Tile.x, z / layer.Tile.y * (1f - 2f * layer.Flip.x), true);
                Color nearColor = sample * layer.Remap * 2f;
                float weight = i == 0 ? 1f : BlendWeight(painted, h, nearHeight, settings.HeightTransition);
                near = Color.LerpUnclamped(near, nearColor, weight);
                if (includeNormals)
                    nearNormal = Vector3.LerpUnclamped(nearNormal, SampleNormal(layer,x,z,layer.Tile,layer.NormalScale.x), weight);
                nearHeight = Mathf.LerpUnclamped(nearHeight, h, weight);
                if (fade <= 0f && (!includeNormals || layer.NormalScale.z <= 0f)) continue;
                float fh = Mathf.LerpUnclamped(MaskHeight(layer, x, z, layer.FarTile), h, layer.Flip.w);
                sample = layer.Albedo.Sample(x / layer.FarTile.x, z / layer.FarTile.y * (1f - 2f * layer.Flip.x), true);
                Color scale = Color.LerpUnclamped(Color.white, layer.Remap * 2f, layer.Remap.a);
                Color farColor = Color.LerpUnclamped(sample * scale, layer.FarRemap, layer.FarRemap.a);
                weight = i == 0 ? 1f : BlendWeight(painted, fh, farHeight, settings.HeightTransition);
                far = Color.LerpUnclamped(far, farColor, weight);
                if (includeNormals)
                {
                    var detail = SampleNormal(layer,x,z,layer.FarTile,layer.NormalScale.y);
                    detail = Vector3.LerpUnclamped(Vector3.forward,detail,fade+(1f-fade)*layer.NormalScale.z);
                    farNormal = Vector3.LerpUnclamped(farNormal,detail,weight);
                }
                farHeight = Mathf.LerpUnclamped(farHeight, fh, weight);
            }
            return new LayerSample
            {
                Color = fade > 0f ? Color.LerpUnclamped(near,far,fade) : near,
                Detail = includeNormals ? Whiteout(Vector3.LerpUnclamped(nearNormal,Vector3.forward,fade),farNormal) : Vector3.forward,
                Height = Mathf.LerpUnclamped(nearHeight,farHeight,fade)
            };
        }

        private static Vector3 CapNormal(Vector3 detail,Vector3 tintDetail,Vector3 macroNormal)
        {
            Vector3 micro = Whiteout(detail,tintDetail);
            Vector3 tangent = new Vector3(macroNormal.y,-macroNormal.x,0f).normalized;
            Vector3 bitangent = -Vector3.Cross(macroNormal,tangent);
            return (tangent*micro.x+bitangent*micro.y+macroNormal*micro.z).normalized;
        }

        private static Vector3 WallNormal(Vector3 detail,Vector3 tintDetail,Vector3 macroNormal,Vector3 face,bool projectX)
        {
            Vector3 micro = Whiteout(detail,tintDetail);
            Vector3 tangent = new Vector3(face.z,0f,-face.x).normalized;
            Vector3 vertical = Vector3.Cross(face,tangent).normalized;
            float sign = projectX ? (face.x < 0f ? 1f : -1f) : (face.z < 0f ? -1f : 1f);
            // The native graph adds its authored fracture slope after reading
            // this atlas. Supply terrain macro plus oriented material detail,
            // so that a neutral normal map never doubles the fracture normal.
            return (tangent*(micro.x*sign)+vertical*micro.y+macroNormal*micro.z).normalized;
        }

        private static float SmoothRange(float minimum, float maximum, float value)
        {
            float t = Mathf.Clamp01((value - minimum) / (maximum - minimum));
            return t * t * (3f - 2f * t);
        }

        private static Vector3 SampleNormal(Layer layer,float x,float z,Vector2 tile,float strength)
        {
            if (layer.Normal == null) return Vector3.forward;
            Color encoded = layer.Normal.Sample(x/tile.x,z/tile.y*(1f-2f*layer.Flip.y),true);
            float nx = encoded.r*2f-1f, ny = encoded.g*2f-1f;
            return new Vector3(nx*strength,ny*strength,Mathf.Sqrt(1f-Mathf.Clamp01(nx*nx+ny*ny)));
        }

        private static Vector3 Whiteout(Vector3 first,Vector3 second)
            => new Vector3(first.x+second.x,first.y+second.y,first.z*second.z).normalized;

        private static float MaskHeight(Layer layer, float x, float z, Vector2 tile)
        {
            float value = layer.Mask == null ? 1f : layer.Mask.Sample(x / tile.x,
                z / tile.y * (1f - 2f * layer.Flip.z), true).b;
            float range = layer.MaskMax.z - layer.MaskMin.z;
            return range == 0f ? (value > layer.MaskMin.z ? 1f : 0f) : Mathf.Clamp01((value - layer.MaskMin.z) / range);
        }

        // RTS/TerrainLit overlays the strata in order, with a mask-blue height bias.
        private static float BlendWeight(float painted, float height, float previousHeight, float transition)
        {
            if (painted >= .99f) return 1f;
            float biased = Mathf.Clamp01(Mathf.Clamp01(height - previousHeight) - 1f + 2f * painted);
            biased = Mathf.Clamp01((biased - .217637f) * Mathf.Max(.5f, transition) + .217637f);
            return Mathf.LerpUnclamped(painted, biased, Mathf.Clamp01(transition));
        }

        private static float Weight(int layer, Color first, Color second)
        {
            return layer <= 4 ? first[layer - 1] : second[layer - 5];
        }

        private static Pixels Readback(Texture source, bool srgb, int maxWidth, int maxHeight, Rect? crop=null)
        {
            if (source == null || source.width < 1 || source.height < 1) return null;
            int width = Math.Min(maxWidth, source.width);
            int height = Math.Min(maxHeight, source.height);
            RenderTexture previous = RenderTexture.active;
            bool previousSrgb = GL.sRGBWrite;
            RenderTexture target = null;
            Texture2D readable = null;
            try
            {
                target = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32,
                    srgb ? RenderTextureReadWrite.sRGB : RenderTextureReadWrite.Linear);
                GL.sRGBWrite = srgb && QualitySettings.activeColorSpace == ColorSpace.Linear;
                Rect region=crop ?? new Rect(0,0,1,1);
                Graphics.Blit(source,target,region.size,region.position);
                RenderTexture.active = target;
                readable = new Texture2D(width, height, TextureFormat.RGBA32, false, !srgb);
                readable.ReadPixels(new Rect(0, 0, width, height), 0, 0, false);
                var pixels = new Pixels { Width = width, Height = height, Srgb = srgb };
                pixels.SourceTexel = new Vector2(1f / source.width, 1f / source.height);
                pixels.Origin=region.position;
                pixels.InverseScale=new Vector2(1f/region.width,1f/region.height);
                pixels.Values = readable.GetPixels32();
                return pixels;
            }
            catch (UnityException)
            {
                // A missing layer can be skipped without suppressing the whole fracture.
                return null;
            }
            finally
            {
                RenderTexture.active = previous;
                GL.sRGBWrite = previousSrgb;
                if (target != null) RenderTexture.ReleaseTemporary(target);
                if (readable != null) UnityEngine.Object.Destroy(readable);
            }
        }

        private static Color Decode(Color32 color, bool srgb)
        {
            return srgb ? new Color(Linear[color.r], Linear[color.g], Linear[color.b], color.a / 255f) : (Color)color;
        }

        internal static byte Encode(float linear)
        {
            return Gamma[Mathf.Clamp(Mathf.RoundToInt(linear * (Gamma.Length - 1)), 0, Gamma.Length - 1)];
        }

        private static float[] MakeLinearTable()
        {
            var result = new float[256];
            for (int i = 0; i < result.Length; ++i)
            {
                float value = i / 255f;
                result[i] = value <= .04045f ? value / 12.92f : (float)Math.Pow((value + .055f) / 1.055f, 2.4);
            }
            return result;
        }

        private static byte[] MakeGammaTable()
        {
            var result = new byte[16384];
            for (int i = 0; i < result.Length; ++i)
            {
                float value = i / (float)(result.Length - 1);
                float encoded = value <= .0031308f ? value * 12.92f : 1.055f * (float)Math.Pow(value, 1.0 / 2.4) - .055f;
                result[i] = (byte)Mathf.Clamp(Mathf.RoundToInt(encoded * 255f), 0, 255);
            }
            return result;
        }
    }
}
