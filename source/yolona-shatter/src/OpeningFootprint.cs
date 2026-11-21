using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Rendering;

namespace ScomShatter;

internal static class OpeningFootprint
{
    private static readonly Mesh[] meshes=new Mesh[4];
    private static readonly Mesh[,] warped=new Mesh[CampaignWarp.ProfileCount,4];
    private static readonly Vector3[][] warpedPositions=new Vector3[CampaignWarp.ProfileCount][];
    private static SourceMask sourceMask;
    private static byte[] collar;
    private const int MaskWidth = 512, MaskHeight = 256;

    // The rendered cut follows the individual displaced islands inside the
    // ellipse. Leave the first surrounding cell level with the real bank, then
    // tuck the overlapping mesh under intact ground, including gaps between islands.
    internal static float CollarBurial(float u, float v)
    {
        if (collar == null) collar = BuildCollar();
        float x = Mathf.Clamp(u * MaskWidth - .5f, 0, MaskWidth - 1);
        float z = Mathf.Clamp(v * MaskHeight - .5f, 0, MaskHeight - 1);
        int ix = (int)x, iz = (int)z;
        int nx = Mathf.Min(ix + 1, MaskWidth - 1), nz = Mathf.Min(iz + 1, MaskHeight - 1);
        float a = Mathf.LerpUnclamped(collar[iz * MaskWidth + ix], collar[iz * MaskWidth + nx], x - ix);
        float b = Mathf.LerpUnclamped(collar[nz * MaskWidth + ix], collar[nz * MaskWidth + nx], x - ix);
        return Mathf.LerpUnclamped(a, b, z - iz) * .01f;
    }

    private static byte[] BuildCollar()
    {
        var rectangles = ReadRectangles(out int w, out int h);
        var distance = new byte[w * h];
        for (int i = 0; i < distance.Length; i++) distance[i] = 4;
        for (int i = 0; i < rectangles.Length; i += 4)
            for (int z = rectangles[i + 1]; z < rectangles[i + 3]; z++)
                System.Array.Clear(distance, z * w + rectangles[i], rectangles[i + 2] - rectangles[i]);
        // Two chamfer passes give the exact capped Chebyshev cell distance.
        for (int z = 0; z < h; z++)
            for (int x = 0; x < w; x++) Relax(x, z, -1);
        for (int z = h - 1; z >= 0; z--)
            for (int x = w - 1; x >= 0; x--) Relax(x, z, 1);
        byte[] centimetres = { 0, 0, 15, 80, 200 };
        for (int i = 0; i < distance.Length; i++) distance[i] = centimetres[distance[i]];
        return distance;

        void Relax(int x, int z, int step)
        {
            int i = z * w + x, d = distance[i];
            if (d == 0) return;
            int side = x + step, other = z + step;
            if (side >= 0 && side < w) d = Mathf.Min(d, 1 + distance[z * w + side]);
            if (other >= 0 && other < h)
                for (int xx = Mathf.Max(0, x - 1); xx <= Mathf.Min(w - 1, x + 1); xx++)
                    d = Mathf.Min(d, 1 + distance[other * w + xx]);
            distance[i] = (byte)d;
        }
    }

    internal static Mesh Get(FractureLayout layout)
    {
        if (!layout.IsFault) return Get(layout.QuarterTurns);
        int profile=layout.FaultProfile, orientation=layout.QuarterTurns;
        if(warped[profile,orientation]!=null) return warped[profile,orientation];
        var result=BuildWarped(layout);
        warped[profile,orientation]=result;
        return result;
    }

    internal static Mesh Get(int orientation)
    {
        orientation &= 3;
        if (meshes[orientation] != null) return meshes[orientation];
        var rectangles=ReadRectangles(out int width,out int height);
        int count=rectangles.Length/4;

        var vertices = new Vector3[count * 4];
        var uv = new Vector2[vertices.Length];
        var triangles = new int[count * 6];
        for (int i = 0; i < count; ++i)
        {
            int x0=rectangles[i*4],y0=rectangles[i*4+1],x1=rectangles[i*4+2],y1=rectangles[i*4+3];
            int first = i * 4, index = i * 6;
            Corner(first, x0, y0); Corner(first + 1, x1, y0);
            Corner(first + 2, x1, y1); Corner(first + 3, x0, y1);
            triangles[index] = first; triangles[index + 1] = first + 1; triangles[index + 2] = first + 2;
            triangles[index + 3] = first; triangles[index + 4] = first + 2; triangles[index + 5] = first + 3;
        }
        var result = new Mesh { name = "Campaign displaced terrain footprint" };
        try
        {
            result.vertices = vertices;
            result.uv = uv;
            result.triangles = triangles;
            result.UploadMeshData(true);
            meshes[orientation] = result;
            return result;
        }
        catch
        {
            Object.Destroy(result);
            throw;
        }

        void Corner(int index, int x, int y)
        {
            float lx = (.5f - (float)x / width) * ShatterEffect.Width;
            float lz = ((float)y / height - .5f) * ShatterEffect.Length;
            vertices[index] = new Vector3(lx, 0, lz);
            // The native hole vertex program projects UV0 from instance space,
            // independent of POSITION. Its fragment pass retains the ellipse limit.
            var p = new Vector2(2f * lx / SurfaceOpening.Width,
                2f * (lz - SurfaceOpening.OffsetZ) / SurfaceOpening.Length);
            // UV0 drives native instance projection. Swap/sign both axes so its
            // clipped mask and ellipse agree with the rendered quarter turn.
            uv[index]=Rotate(p,orientation);
        }
    }

    private static int[] ReadRectangles(out int width,out int height)
    {
        using var stream=typeof(OpeningFootprint).Assembly.GetManifestResourceStream("CampaignOpening.bin")
            ?? throw new InvalidDataException("Missing campaign opening footprint.");
        using var reader=new BinaryReader(stream);
        if(reader.ReadUInt32()!=0x314d4f53) throw new InvalidDataException("Invalid campaign opening footprint.");
        width=reader.ReadUInt16();height=reader.ReadUInt16();int count=reader.ReadInt32();
        if(width!=512 || height!=256 || count<=0 || count>16383 || stream.Length!=12+8*count)
            throw new InvalidDataException("Invalid campaign opening dimensions.");
        var rectangles=new int[count*4];
        for(int i=0;i<rectangles.Length;i+=4)
        {
            int x0=reader.ReadUInt16(),y0=reader.ReadUInt16(),x1=reader.ReadUInt16(),y1=reader.ReadUInt16();
            if(x0>=x1 || x1>width || y0>=y1 || y1>height)
                throw new InvalidDataException("Invalid campaign opening rectangle.");
            rectangles[i]=x0;rectangles[i+1]=y0;rectangles[i+2]=x1;rectangles[i+3]=y1;
        }
        return rectangles;
    }

    private static Vector2 Rotate(Vector2 p,int orientation)
    {
        switch(orientation)
        {
            case 1:return new Vector2(p.y,-p.x);
            case 2:return -p;
            case 3:return new Vector2(-p.y,p.x);
            default:return p;
        }
    }

    private struct MaskVertex
    {
        internal Vector2 Source;
        internal int Key;
    }

    private sealed class SourceMask
    {
        internal Vector2[] Points;
        internal int[] Indices;
    }

    private static SourceMask BuildSourceMask()
    {
        var rectangles=ReadRectangles(out int width,out int height);
        var vertices=new List<Vector2>();var indices=new List<int>();
        var polygon=new List<MaskVertex>(8);var clipped=new List<MaskVertex>(8);
        int gridCount=(width+1)*(height+1);
        // Corner, horizontal crossing and vertical crossing keys are disjoint.
        // Every incident cell reuses the same vertex, including ellipse crossings.
        var mapping=new int[gridCount*3];
        MaskVertex Source(int x,int y) => new MaskVertex {
            Source=new Vector2((.5f-(float)x/width)*ShatterEffect.Width,((float)y/height-.5f)*ShatterEffect.Length),
            Key=y*(width+1)+x
        };
        float Ellipse(Vector2 p)
        {
            float x=2f*p.x/SurfaceOpening.Width,z=2f*(p.y-SurfaceOpening.OffsetZ)/SurfaceOpening.Length;
            return 1f-x*x-z*z;
        }
        int Index(MaskVertex vertex)
        {
            int cached=mapping[vertex.Key];
            if(cached!=0) return cached-1;
            vertices.Add(vertex.Source);
            mapping[vertex.Key]=vertices.Count;
            return vertices.Count-1;
        }
        void Cell(int x,int y)
        {
            polygon.Clear();
            polygon.Add(Source(x,y));polygon.Add(Source(x+1,y));
            polygon.Add(Source(x+1,y+1));polygon.Add(Source(x,y+1));
            // The original shader intersected the binary mask with its source
            // ellipse. Retain that intersection before applying the horizontal map.
            clipped.Clear();
            var previous=polygon[polygon.Count-1];float d0=Ellipse(previous.Source);
            foreach(var next in polygon)
            {
                float d1=Ellipse(next.Source);
                if((d0<0f && d1>0f)||(d0>0f && d1<0f))
                {
                    int edge=Mathf.Min(previous.Key,next.Key);
                    bool horizontal=Mathf.Abs(previous.Key-next.Key)==1;
                    clipped.Add(new MaskVertex {
                        Source=Vector2.LerpUnclamped(previous.Source,next.Source,d0/(d0-d1)),
                        Key=gridCount*(horizontal?1:2)+edge
                    });
                }
                if(d1>=0f) clipped.Add(next);
                previous=next;d0=d1;
            }
            if(clipped.Count<3) return;
            int first=Index(clipped[0]),last=Index(clipped[1]);
            for(int j=2;j<clipped.Count;j++)
            {
                int next=Index(clipped[j]);
                indices.Add(first);indices.Add(last);indices.Add(next);
                last=next;
            }
        }
        // Use the authored mask's 0.69 m grid. A common pixel lattice avoids
        // cracks where merged rectangles meet or a warp knot bends a shared edge.
        for(int i=0;i<rectangles.Length;i+=4)
            for(int y=rectangles[i+1];y<rectangles[i+3];y++)
                for(int x=rectangles[i];x<rectangles[i+2];x++) Cell(x,y);
        return new SourceMask { Points=vertices.ToArray(),Indices=indices.ToArray() };
    }

    private static Mesh BuildWarped(FractureLayout layout)
    {
        if(sourceMask==null) sourceMask=BuildSourceMask();
        var vertices=warpedPositions[layout.FaultProfile];
        if(vertices==null)
        {
            vertices=new Vector3[sourceMask.Points.Length];
            for(int i=0;i<vertices.Length;i++)
            {
                Vector2 p=CampaignWarp.Forward(sourceMask.Points[i],layout.FaultProfile);
                vertices[i]=new Vector3(p.x,0f,p.y);
            }
            warpedPositions[layout.FaultProfile]=vertices;
        }
        Vector2 center=layout.OpeningCenter,size=layout.OpeningSize;
        var uv=new Vector2[vertices.Length];
        for(int i=0;i<uv.Length;i++)
            uv[i]=Rotate(new Vector2(2f*(vertices[i].x-center.x)/size.x,2f*(vertices[i].z-center.y)/size.y),layout.QuarterTurns);
        var result=new Mesh { name="Warped campaign opening "+layout.FaultProfile,
            indexFormat=vertices.Length>65535?IndexFormat.UInt32:IndexFormat.UInt16 };
        try
        {
            result.vertices=vertices;result.uv=uv;result.SetTriangles(sourceMask.Indices,0,false);
            result.RecalculateBounds();result.UploadMeshData(true);
            return result;
        }
        catch { Object.Destroy(result);throw; }
    }

    internal static void Release()
    {
        collar = null;
        sourceMask=null;
        for(int i=0;i<warpedPositions.Length;i++) warpedPositions[i]=null;
        for(int profile=0;profile<warped.GetLength(0);profile++)
            for(int orientation=0;orientation<warped.GetLength(1);orientation++)
            {
                if(warped[profile,orientation]!=null) Object.Destroy(warped[profile,orientation]);
                warped[profile,orientation]=null;
            }
        for(int i=0;i<meshes.Length;i++)
        {
            if (meshes[i] != null) Object.Destroy(meshes[i]);
            meshes[i]=null;
        }
    }
}
