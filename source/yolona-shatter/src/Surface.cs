using System;
using System.Threading;
using System.Threading.Tasks;
using EM.Map;
using UnityEngine;

namespace ScomShatter;

internal static class Surface
{
	private static Terrain terrain;

	private static TerrainData data;

	private static string mapPath;

	private static int sessionId;

	private static TerrainAppearance appearance;

	private static float appearanceDx = float.PositiveInfinity, appearanceDz = float.PositiveInfinity;

	private static readonly SemaphoreSlim bakeSlots = new SemaphoreSlim(2, 2);
	private static readonly SemaphoreSlim previewSlots = new SemaphoreSlim(1, 1);

	internal static bool IsReady => Refresh();

	internal static int SessionId
	{
		get
		{
			Refresh();
			return sessionId;
		}
	}

	internal static void Reset()
	{
		if (terrain != null || data != null || mapPath != null)
		{
			sessionId++;
		}
		terrain = null;
		data = null;
		mapPath = null;
		appearance = null;
		appearanceDx = appearanceDz = float.PositiveInfinity;
	}

	private static bool Refresh()
	{
		Terrain terrain = MapManager.Terrain;
		if (!MapManager.IsMapLoadedForClient || terrain == null || !terrain.isActiveAndEnabled || terrain.terrainData == null)
		{
			Reset();
			return false;
		}
		TerrainData terrainData = terrain.terrainData;
		string filePath = MapManager.mapFile.filePath;
		if (terrain != Surface.terrain || terrainData != data || !string.Equals(filePath, mapPath, StringComparison.Ordinal))
		{
			Reset();
			Surface.terrain = terrain;
			data = terrainData;
			mapPath = filePath;
			sessionId++;
		}
		Vector3 size = data.size;
		if (Finite(size.x) && Finite(size.y) && Finite(size.z) && size.x > 0f && size.y > 0f)
		{
			return size.z > 0f;
		}
		return false;
	}

	internal static bool TryGetBounds(out Rect bounds)
	{
		bounds = default(Rect);
		if (!Refresh())
		{
			return false;
		}
		Vector3 position = terrain.GetPosition();
		Vector3 size = data.size;
		bounds = new Rect(position.x, position.z, size.x, size.z);
		return true;
	}

    internal static bool TryGetHeight(float x,float z,out float height)
    {
        height=0f;
        if(!Finite(x) || !Finite(z) || !Refresh()) return false;
        Vector3 origin=terrain.GetPosition(), size=data.size;
        float u=(x-origin.x)/size.x, v=(z-origin.z)/size.z;
        if(u<0 || u>1 || v<0 || v>1) return false;
        height=origin.y+data.GetInterpolatedHeight(u,v);
        return Finite(height);
    }

    // Unity's GPU texture readbacks run here. Both bake tasks share the same immutable
    // regional splats and tint, including when the owner is cancelled on map unload.
    internal static TerrainAppearance CaptureAlbedo(Rect footprint,Rect map,int width,int height)
    {
        if(!Refresh()) throw new InvalidOperationException("Terrain is unavailable for surface capture.");
        float dx=footprint.width/width,dz=footprint.height/height;
        if(appearance==null || dx<appearanceDx || dz<appearanceDz)
        {
            appearanceDx=Math.Min(dx,appearanceDx);
            appearanceDz=Math.Min(dz,appearanceDz);
            appearance=TerrainAppearance.Capture(terrain.materialTemplate,MapManager.mapFile,appearanceDx,appearanceDz);
        }
        var normalized=Rect.MinMaxRect(Mathf.Clamp01((footprint.xMin-map.xMin)/map.width),
            Mathf.Clamp01((footprint.yMin-map.yMin)/map.height),Mathf.Clamp01((footprint.xMax-map.xMin)/map.width),
            Mathf.Clamp01((footprint.yMax-map.yMin)/map.height));
        return appearance.CapturePatch(normalized,width,height);
    }

    internal sealed class BakedSurface
    {
        internal readonly int Width, Height;
        internal readonly Color32[] Albedo, Normals;
        internal BakedSurface(int width,int height)
        {
            Width=width;Height=height;
            Albedo=new Color32[width*height];
            Normals=new Color32[width*height];
        }
    }

    internal static async Task<BakedSurface> BakeAlbedoAsync(TerrainAppearance captured,Rect map,Vector3 center,FractureLayout layout,
        int width,int height,CancellationToken cancellation,bool preview=false,BakedWallProjection walls=null)
    {
        cancellation.ThrowIfCancellationRequested();
        if(!captured.HasAlbedo) return null;
        float dx=ShatterEffect.Width/width, dz=ShatterEffect.Length/height;
        // Previews have one small independent slot; they never occupy either
        // full-resolution slot or allocate their arrays while queued.
        var slots=preview?previewSlots:bakeSlots;
        await slots.WaitAsync(cancellation).ConfigureAwait(false);
		try
		{
			return await Task.Run(() =>
			{
                var result = new BakedSurface(width,height);
				for (int y = 0; y < height; ++y)
				{
					cancellation.ThrowIfCancellationRequested();
					float nativeZ = -ShatterEffect.Length * .5f + (y + .5f) * dz;
					for (int x = 0; x < width; ++x)
					{
						Vector2 source = new Vector2(-ShatterEffect.Width * .5f + (x + .5f) * dx, nativeZ);
                        var wall=walls==null?default(BakedWallProjection.SurfaceSample):walls.Sample(source);
                        if(wall.Reprojected) source=wall.Source;
						Vector2 offset = layout.ToSite(layout.SourceToNative(source));
                        float wx = Mathf.Clamp(center.x + offset.x, map.xMin, map.xMax);
                        float z = Mathf.Clamp(center.z + offset.y, map.yMin, map.yMax);
                        captured.TrySample(wx, z, (wx - map.xMin) / map.width, (z - map.yMin) / map.height,
                            true,out var color,out var normal,wall);
                        // UV0 increases towards native -X before the layout is applied.
                        int destination=y*width+width-1-x;
                        result.Albedo[destination] = new Color32(TerrainAppearance.Encode(color.r),
                            TerrainAppearance.Encode(color.g),TerrainAppearance.Encode(color.b),255);
                        if(result.Normals!=null)
                        {
                            float nx=normal.x,nz=normal.z;
                            switch(layout.QuarterTurns)
                            {
                                case 1: nx=-normal.z;nz=normal.x;break;
                                case 2: nx=-normal.x;nz=-normal.z;break;
                                case 3: nx=normal.z;nz=-normal.x;break;
                            }
                            byte r=(byte)Mathf.Clamp(Mathf.RoundToInt((.5f-.5f*nx)*255f),0,255);
                            byte g=(byte)Mathf.Clamp(Mathf.RoundToInt((.5f-.5f*nz)*255f),0,255);
                            result.Normals[destination]=new Color32(255,g,255,r);
                        }
					}
				}
                return result;
			}, cancellation).ConfigureAwait(false);
		}
		finally { slots.Release(); }
	}

	private static bool Finite(float value)
	{
		if (!float.IsNaN(value))
		{
			return !float.IsInfinity(value);
		}
		return false;
	}
}
