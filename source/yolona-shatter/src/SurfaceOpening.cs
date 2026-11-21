using System;
using System.Runtime.InteropServices;
using EM.Controls.Cameras;
using EM.DOTS.Engine.Loader;
using EM.Map;
using UnityEngine;
using UnityEngine.Rendering;

namespace ScomShatter;

// Client render-only holes. Native RangesPass combines these draws with unit holes
// into _HoleBuffer while the campaign surface animates. ChasmTerrain commits the settled collider.
internal sealed class SurfaceOpening : IDisposable
{
    [StructLayout(LayoutKind.Sequential)]
    private struct HoleInstance
    {
        public Vector2 Position;
        public Vector2 Size;
        public float Rotation;
        public float Circle;
    }

    private static readonly int InstanceBuffer = Shader.PropertyToID("HoleInstanceBuffer");
    private static readonly int BufferOffset = Shader.PropertyToID("BufferOffset");
    // The ordinary terrain-hole list includes all rendering layers. The ocean
    // can omit just these slab footprints while retaining every native draw.
    // The shipped project defines sixteen rendering layers. Native unit holes
    // use the default layer; the final decal layer identifies our range draws.
    internal const uint FractureRenderingLayer = 1u << 15;

    private readonly HoleInstance[] holes;
    private readonly FractureLayout layout;
    private readonly Bounds bounds;
    private ComputeBuffer buffer;
    private GraphicsBuffer drawArguments;
    private RenderParams renderParams;
    private Mesh mesh;
    private Material material;
    private Camera camera;
    private Terrain terrain;
    private string mapPath;
    private bool boundToMap;
    private bool disposed;

    // Source HoleDistanceField under Land Collapse Pack. The editor mesh and the
    // playtest's native instance both parameterize a unit circle by its full size.
    internal const float Width = 344.626343f, Length = 168.943680f;
    internal const float OffsetZ = -8f + 7.2800293f;

    internal SurfaceOpening(Vector3 impact,FractureLayout layout)
    {
        this.layout=layout;
        var position = new Vector2(impact.x, impact.z)+layout.ToSite(layout.OpeningCenter);
        Vector2 openingSize=layout.OpeningSize;
        var size=layout.Swapped ? new Vector2(openingSize.y*layout.ScaleZ,openingSize.x*layout.ScaleX)
            : new Vector2(openingSize.x*layout.ScaleX,openingSize.y*layout.ScaleZ);
        holes = new[] { new HoleInstance {
            Position = position, Size = size, Rotation = 0, Circle = 1
        } };
        bounds = new Bounds(new Vector3(position.x,impact.y,position.y), new Vector3(size.x+2,2000,size.y+2));
    }

    internal static bool CanDraw()
    {
        var loader=EngineLoader.Instance;
        return RangesRenderer.holesActive && MainCamera.Cam!=null && LayerMask.NameToLayer("Ranges")>=0 &&
            loader!=null && loader.holesMesh!=null && loader.holesMaterial!=null &&
            loader.holesMaterial.shader!=null && loader.holesMaterial.shader.isSupported &&
            loader.holesMaterial.shader.name=="RTS/Range/HoleDistanceField HLSL" && loader.holesMaterial.renderQueue==2000;
    }

    // Call once per active frame before rendering, just like the native hole renderer.
    // False means assets/camera/native holes rendering are not ready or the map ended.
    internal bool Draw()
    {
        if (disposed) return false;
        Terrain currentTerrain = MapManager.Terrain;
        if (!MapManager.IsMapLoadedForClient || currentTerrain == null || !currentTerrain.isActiveAndEnabled)
        {
            if (boundToMap) Dispose();
            return false;
        }
        string currentPath = MapManager.mapFile.filePath;
        if (boundToMap && (terrain != currentTerrain || !String.Equals(mapPath, currentPath, StringComparison.Ordinal)))
        {
            // Coordinates belong to the original session. Never reopen a later map.
            Dispose();
            return false;
        }
        if (!boundToMap)
        {
            terrain = currentTerrain;
            mapPath = currentPath;
            boundToMap = true;
        }

        EngineLoader loader = EngineLoader.Instance;
        Camera currentCamera = MainCamera.Cam;
        int layer = LayerMask.NameToLayer("Ranges");
        if (!CanDraw())
        {
            ReleaseRenderer();
            return false;
        }

        Mesh footprint = OpeningFootprint.Get(layout);
        if (drawArguments == null || mesh != footprint || material != loader.holesMaterial || camera != currentCamera)
        {
            ReleaseRenderer();
            try
            {
                mesh = footprint;
                material = loader.holesMaterial;
                camera = currentCamera;
                buffer = new ComputeBuffer(holes.Length, 24, ComputeBufferType.Default);
                buffer.SetData(holes);
                var properties = new MaterialPropertyBlock();
                properties.SetBuffer(InstanceBuffer, buffer);
                properties.SetFloat(BufferOffset, 0f);
                renderParams = new RenderParams(material) {
                    worldBounds = bounds, camera = camera, layer = layer, matProps = properties,
                    renderingLayerMask = FractureRenderingLayer
                };
                drawArguments = new GraphicsBuffer(GraphicsBuffer.Target.IndirectArguments, 1, GraphicsBuffer.IndirectDrawIndexedArgs.size);
                drawArguments.SetData(new[] { new GraphicsBuffer.IndirectDrawIndexedArgs {
                    indexCountPerInstance = mesh.GetIndexCount(0), instanceCount = (uint)holes.Length,
                    startIndex = mesh.GetIndexStart(0), baseVertexIndex = mesh.GetBaseVertex(0)
                } });
            }
            catch
            {
                ReleaseRenderer();
                throw;
            }
        }
        Graphics.RenderMeshIndirect(in renderParams, mesh, drawArguments);
        return true;
    }

    private void ReleaseRenderer()
    {
        drawArguments?.Dispose();
        drawArguments = null;
        renderParams = default;
        if (buffer != null)
        {
            buffer.Dispose();
            buffer = null;
        }
        mesh = null;
        material = null;
        camera = null;
    }

    public void Dispose()
    {
        if (disposed) return;
        disposed = true;
        ReleaseRenderer();
        terrain = null;
        mapPath = null;
    }

}
