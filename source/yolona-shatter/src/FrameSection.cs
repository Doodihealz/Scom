using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Rendering;

namespace ScomShatter
{
    internal static class FrameSection
    {
        internal interface IVertex<T> { Vector3 Position { get; } T Between(T other,float t); }

        // Unity stores the native plane and beams in one 32-byte vertex stream.
        // Preserve untouched vertices byte for byte, including split seams.
        [StructLayout(LayoutKind.Sequential)]
        private struct Packed : IVertex<Packed>
        {
            public Vector3 Point;
            public ushort Nx,Ny,Nz,Nw,Tx,Ty,Tz,Tw,U,V;
            public Vector3 Position => Point;

            private Full Decode() => new Full { Point=Point,
                Normal=new Vector3(Mathf.HalfToFloat(Nx),Mathf.HalfToFloat(Ny),Mathf.HalfToFloat(Nz)),
                Tangent=new Vector4(Mathf.HalfToFloat(Tx),Mathf.HalfToFloat(Ty),Mathf.HalfToFloat(Tz),Mathf.HalfToFloat(Tw)),
                UV=new Vector2(Mathf.HalfToFloat(U),Mathf.HalfToFloat(V)) };

            public Packed Between(Packed other,float t)
            {
                var v=Decode().Between(other.Decode(),t);
                return new Packed { Point=v.Point, Nx=Mathf.FloatToHalf(v.Normal.x), Ny=Mathf.FloatToHalf(v.Normal.y),
                    Nz=Mathf.FloatToHalf(v.Normal.z), Nw=Nw, Tx=Mathf.FloatToHalf(v.Tangent.x), Ty=Mathf.FloatToHalf(v.Tangent.y),
                    Tz=Mathf.FloatToHalf(v.Tangent.z), Tw=Mathf.FloatToHalf(v.Tangent.w), U=Mathf.FloatToHalf(v.UV.x), V=Mathf.FloatToHalf(v.UV.y) };
            }

            internal Packed BetweenEncoded(Packed other,float t)
            {
                ushort Blend(ushort a,ushort b) => Mathf.FloatToHalf(Mathf.LerpUnclamped(Mathf.HalfToFloat(a),Mathf.HalfToFloat(b),t));
                // Land's native shader owns these channels. Intersections retain
                // their interpolated values rather than treating them as a new basis.
                return new Packed { Point=Vector3.LerpUnclamped(Point,other.Point,t),
                    Nx=Blend(Nx,other.Nx),Ny=Blend(Ny,other.Ny),Nz=Blend(Nz,other.Nz),Nw=Blend(Nw,other.Nw),
                    Tx=Blend(Tx,other.Tx),Ty=Blend(Ty,other.Ty),Tz=Blend(Tz,other.Tz),Tw=Blend(Tw,other.Tw),
                    U=Blend(U,other.U),V=Blend(V,other.V) };
            }
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct WarpedLandVertex : IVertex<WarpedLandVertex>
        {
            internal Packed Value;
            public Vector3 Position => Value.Point;
            public WarpedLandVertex Between(WarpedLandVertex other,float t) =>
                new WarpedLandVertex { Value=Value.BetweenEncoded(other.Value,t) };
        }

        [StructLayout(LayoutKind.Sequential)]
        internal struct Full : IVertex<Full>
        {
            public Vector3 Point,Normal;
            public Vector4 Tangent;
            public Vector2 UV;
            public Vector3 Position => Point;
            public Full Between(Full other,float t)
            {
                Vector3 n=Vector3.LerpUnclamped(Normal,other.Normal,t).normalized;
                Vector3 d=Vector3.LerpUnclamped(Tangent,other.Tangent,t);
                d=(d-n*Vector3.Dot(n,d)).normalized;
                return new Full { Point=Vector3.LerpUnclamped(Point,other.Point,t),Normal=n,
                    Tangent=new Vector4(d.x,d.y,d.z,t<.5f?Tangent.w:other.Tangent.w),UV=Vector2.LerpUnclamped(UV,other.UV,t) };
            }
        }

        private static readonly VertexAttributeDescriptor[] PackedLayout={
            new VertexAttributeDescriptor(VertexAttribute.Position,VertexAttributeFormat.Float32,3),
            new VertexAttributeDescriptor(VertexAttribute.Normal,VertexAttributeFormat.Float16,4),
            new VertexAttributeDescriptor(VertexAttribute.Tangent,VertexAttributeFormat.Float16,4),
            new VertexAttributeDescriptor(VertexAttribute.TexCoord0,VertexAttributeFormat.Float16,2)
        };

        internal static readonly VertexAttributeDescriptor[] FullLayout={
            new VertexAttributeDescriptor(VertexAttribute.Position,VertexAttributeFormat.Float32,3),
            new VertexAttributeDescriptor(VertexAttribute.Normal,VertexAttributeFormat.Float32,3),
            new VertexAttributeDescriptor(VertexAttribute.Tangent,VertexAttributeFormat.Float32,4),
            new VertexAttributeDescriptor(VertexAttribute.TexCoord0,VertexAttributeFormat.Float32,2)
        };

        internal static bool Contains(Rect bounds,Bounds mesh) =>
            mesh.min.x>=bounds.xMin && mesh.max.x<=bounds.xMax && mesh.min.z>=bounds.yMin && mesh.max.z<=bounds.yMax;

        internal static Mesh Clip(Mesh source,Rect bounds) => Clip(source,bounds,null);

        // Returns a caller-owned mesh. Only POSITION.xz changes before clipping;
        // the campaign shader still samples every authored map through native UV0.
        internal static Mesh WarpLand(Mesh source,Rect mapInObjectUnits,int profile,Func<Vector3,float> keep=null)
        {
            if(source==null) throw new ArgumentNullException(nameof(source));
            if(!source.isReadable) throw Invalid(source,"CPU geometry is not readable");
            if(profile>=CampaignWarp.ProfileCount) throw new ArgumentOutOfRangeException(nameof(profile));
            using(var sourceData=Mesh.AcquireReadOnlyMeshData(source))
            {
                var data=sourceData[0];
                if(data.vertexBufferCount!=1 || source.vertexAttributeCount!=4 || !MatchesLayout(data,PackedLayout,32))
                    throw Invalid(source,"land warp requires the canonical packed 32-byte vertex stream");
                var indices=new IndexBuffer(data,source);
                var subMeshes=ValidateSubMeshes(data,indices,source);
                var input=data.GetVertexData<Packed>(0);
                if(input.Length!=data.vertexCount || (input.Length!=0 && !input.IsCreated))
                    throw Invalid(source,"CPU vertex buffer is missing or its length does not match vertex count");
                var warped=new NativeArray<WarpedLandVertex>(input.Length,Allocator.TempJob,NativeArrayOptions.UninitializedMemory);
                try
                {
                    const float scale=CampaignSurfaceAssets.NativeScale;
                    for(int i=0;i<input.Length;i++)
                    {
                        var value=input[i];
                        if(profile>=0)
                        {
                            Vector2 p=CampaignWarp.Forward(new Vector2(value.Point.x*scale,value.Point.z*scale),profile)/scale;
                            value.Point=new Vector3(p.x,value.Point.y,p.y);
                        }
                        // +Y normals and the native tangent stay in physical X/Z:
                        // the material's terrain slope/detail samples use that basis.
                        warped[i]=new WarpedLandVertex { Value=value };
                    }
                    // Bounds and overlap fields are evaluated on actual warped
                    // positions, including field interpolation at map intersections.
                    var result=Clip(source,mapInObjectUnits,warped,warped.Length,indices,subMeshes,PackedLayout,keep);
                    result.name=source.name+" warped campaign land";
                    return result;
                }
                finally { warped.Dispose(); }
            }
        }

        // The signed field is sampled once at each source vertex and linearly
        // interpolated within its triangles: zero/positive keeps the surface.
        internal static Mesh Clip(Mesh source,Rect bounds,Func<Vector3,float> signedKeep)
        {
            if(source==null) throw new ArgumentNullException(nameof(source));
            if(!source.isReadable) throw Invalid(source,"CPU geometry is not readable");
            using(var sourceData=Mesh.AcquireReadOnlyMeshData(source))
            {
                var data=sourceData[0];
                if(data.vertexBufferCount!=1 || source.vertexAttributeCount!=4)
                    throw Invalid(source,"expected one vertex stream with position, normal, tangent and UV");
                var indices=new IndexBuffer(data,source);
                var subMeshes=ValidateSubMeshes(data,indices,source);
                if(MatchesLayout(data,PackedLayout,32))
                    return Clip(source,bounds,data.GetVertexData<Packed>(0),data.vertexCount,indices,subMeshes,PackedLayout,signedKeep);
                if(MatchesLayout(data,FullLayout,48))
                    return Clip(source,bounds,data.GetVertexData<Full>(0),data.vertexCount,indices,subMeshes,FullLayout,signedKeep);
                // Imported packed data must never enter Unity's attribute conversion APIs.
                throw Invalid(source,"unsupported vertex layout (stream stride "+data.GetVertexBufferStride(0)+")");
            }
        }

        private static InvalidDataException Invalid(Mesh source,string reason) =>
            new InvalidDataException("Cannot clip campaign mesh '"+source.name+"': "+reason+".");

        private static bool MatchesLayout(Mesh.MeshData data,VertexAttributeDescriptor[] layout,int stride)
        {
            if(data.GetVertexBufferStride(0)!=stride) return false;
            int offset=0;
            foreach(var attribute in layout)
            {
                if(!data.HasVertexAttribute(attribute.attribute) || data.GetVertexAttributeStream(attribute.attribute)!=0 ||
                   data.GetVertexAttributeFormat(attribute.attribute)!=attribute.format ||
                   data.GetVertexAttributeDimension(attribute.attribute)!=attribute.dimension ||
                   data.GetVertexAttributeOffset(attribute.attribute)!=offset) return false;
                offset+=attribute.dimension*(attribute.format==VertexAttributeFormat.Float32?4:2);
            }
            return offset==stride;
        }

        private struct IndexBuffer
        {
            private NativeArray<ushort> shortIndices;
            private NativeArray<uint> longIndices;
            private bool wide;
            internal int Length => wide?longIndices.Length:shortIndices.Length;
            internal uint this[int index] => wide?longIndices[index]:shortIndices[index];

            internal IndexBuffer(Mesh.MeshData data,Mesh source)
            {
                shortIndices=default;longIndices=default;
                wide=data.indexFormat==IndexFormat.UInt32;
                if(wide) longIndices=data.GetIndexData<uint>();
                else if(data.indexFormat==IndexFormat.UInt16) shortIndices=data.GetIndexData<ushort>();
                else throw Invalid(source,"unsupported index format");
                if(Length!=0 && !(wide?longIndices.IsCreated:shortIndices.IsCreated))
                    throw Invalid(source,"CPU index buffer is missing");
            }

            // Validation proves this sum is a valid vertex index before clipping starts.
            internal int Vertex(int index,int baseVertex) => (int)((long)this[index]+baseVertex);
        }

        private static SubMeshDescriptor[] ValidateSubMeshes(Mesh.MeshData data,IndexBuffer indices,Mesh source)
        {
            var subMeshes=new SubMeshDescriptor[data.subMeshCount];
            for(int g=0;g<subMeshes.Length;g++)
            {
                var sub=data.GetSubMesh(g);
                if(sub.topology!=MeshTopology.Triangles || sub.indexStart<0 || sub.indexCount<0 || sub.indexCount%3!=0 ||
                   (long)sub.indexStart+sub.indexCount>indices.Length || sub.firstVertex<0 || sub.vertexCount<0 ||
                   (long)sub.firstVertex+sub.vertexCount>data.vertexCount)
                    throw Invalid(source,"invalid triangle or vertex range in submesh "+g);
                long end=(long)sub.firstVertex+sub.vertexCount;
                for(int i=sub.indexStart;i<sub.indexStart+sub.indexCount;i++)
                {
                    long vertex=(long)indices[i]+sub.baseVertex;
                    if(vertex<sub.firstVertex || vertex>=end)
                        throw Invalid(source,"index "+i+" is outside the vertex range in submesh "+g);
                }
                subMeshes[g]=sub;
            }
            return subMeshes;
        }

        private static Mesh Clip<T>(Mesh source,Rect bounds,NativeArray<T> input,int vertexCount,IndexBuffer sourceIndices,
            SubMeshDescriptor[] subMeshes,VertexAttributeDescriptor[] layout,Func<Vector3,float> signedKeep)
            where T:struct,IVertex<T>
        {
            if(input.Length!=vertexCount || (vertexCount!=0 && !input.IsCreated))
                throw Invalid(source,"CPU vertex buffer is missing or its length does not match vertex count");
            if(signedKeep!=null) return ClipField(source,bounds,input,sourceIndices,subMeshes,layout,signedKeep);
            var meshBounds=source.bounds;
            float xOverlap=Mathf.Max(0,Mathf.Min(bounds.xMax,meshBounds.max.x)-Mathf.Max(bounds.xMin,meshBounds.min.x));
            float zOverlap=Mathf.Max(0,Mathf.Min(bounds.yMax,meshBounds.max.z)-Mathf.Max(bounds.yMin,meshBounds.min.z));
            float fraction=Mathf.Clamp01(xOverlap*zOverlap/Mathf.Max(.001f,meshBounds.size.x*meshBounds.size.z));
            var vertices=new List<T>(Mathf.CeilToInt(input.Length*fraction));
            var mapping=new int[input.Length];
            var sideCodes=new byte[input.Length];
            for(int i=0;i<input.Length;i++)
            {
                var p=input[i].Position;
                sideCodes[i]=(byte)((p.x<bounds.xMin?1:0)|(p.x>bounds.xMax?2:0)|(p.z<bounds.yMin?4:0)|(p.z>bounds.yMax?8:0));
            }
            int Index(int i)
            {
                if(mapping[i]==0){ vertices.Add(input[i]);mapping[i]=vertices.Count; }
                return mapping[i]-1;
            }
            var groups=new List<int>[subMeshes.Length];
            var polygon=new List<T>(8);var scratch=new List<T>(8);
            for(int g=0;g<groups.Length;g++)
            {
                var sub=subMeshes[g];
                var indices=groups[g]=new List<int>(Mathf.CeilToInt(sub.indexCount*fraction));
                for(int i=sub.indexStart;i<sub.indexStart+sub.indexCount;i+=3)
                {
                    int a=sourceIndices.Vertex(i,sub.baseVertex),b=sourceIndices.Vertex(i+1,sub.baseVertex),c=sourceIndices.Vertex(i+2,sub.baseVertex);
                    int ca=sideCodes[a], cb=sideCodes[b], cc=sideCodes[c];
                    if((ca&cb&cc)!=0) continue;
                    if((ca|cb|cc)==0){ indices.Add(Index(a));indices.Add(Index(b));indices.Add(Index(c));continue; }
                    polygon.Clear();polygon.Add(input[a]);polygon.Add(input[b]);polygon.Add(input[c]);
                    for(int side=0;side<4 && polygon.Count>0;side++)
                    {
                        float limit=side==0?bounds.xMin:side==1?bounds.xMax:side==2?bounds.yMin:bounds.yMax;
                        float Distance(T v) => ((side<2?v.Position.x:v.Position.z)-limit)*((side&1)==0?1:-1);
                        scratch.Clear();
                        var previous=polygon[polygon.Count-1];
                        float d0=Distance(previous);
                        foreach(var next in polygon)
                        {
                            float d1=Distance(next);
                            if(d0*d1<0) scratch.Add(previous.Between(next,d0/(d0-d1)));
                            if(d1>=0) scratch.Add(next);
                            previous=next;d0=d1;
                        }
                        var swap=polygon;polygon=scratch;scratch=swap;
                    }
                    if(polygon.Count<3) continue;
                    int first=vertices.Count;
                    vertices.AddRange(polygon);
                    for(int j=2;j<polygon.Count;j++){indices.Add(first);indices.Add(first+j-1);indices.Add(first+j);}
                }
            }
            var mesh=new Mesh { name=source.name+" at map boundary",indexFormat=vertices.Count>65535?IndexFormat.UInt32:IndexFormat.UInt16 };
            try
            {
                mesh.SetVertexBufferParams(vertices.Count,layout);
                if(vertices.Count!=0) mesh.SetVertexBufferData(vertices,0,0,vertices.Count);
                mesh.subMeshCount=groups.Length;
                for(int i=0;i<groups.Length;i++) mesh.SetTriangles(groups[i],i,false);
                mesh.RecalculateBounds();
                mesh.UploadMeshData(true);
                return mesh;
            }
            catch { UnityEngine.Object.Destroy(mesh);throw; }
        }

        private struct FieldVertex<T> where T:struct,IVertex<T>
        {
            internal T Value;
            internal float Signed;
            internal int Source;

            internal FieldVertex<T> Between(FieldVertex<T> other,float t) => new FieldVertex<T> {
                Value=Value.Between(other.Value,t), Signed=(float)((1d-t)*Signed+t*(double)other.Signed), Source=-1
            };
        }

        private static void ClipFieldSide<T>(List<FieldVertex<T>> polygon,List<FieldVertex<T>> clipped,Rect bounds,int side)
            where T:struct,IVertex<T>
        {
            clipped.Clear();
            if(polygon.Count==0) return;
            float Distance(FieldVertex<T> v)
            {
                if(side==4) return v.Signed;
                float limit=side==0?bounds.xMin:side==1?bounds.xMax:side==2?bounds.yMin:bounds.yMax;
                return ((side<2?v.Value.Position.x:v.Value.Position.z)-limit)*((side&1)==0?1f:-1f);
            }
            var previous=polygon[polygon.Count-1];
            float d0=Distance(previous);
            foreach(var next in polygon)
            {
                float d1=Distance(next);
                if((d0<0f && d1>0f) || (d0>0f && d1<0f))
                {
                    // Double arithmetic avoids overflow for finite large field values.
                    float t=(float)((double)d0/((double)d0-d1));
                    clipped.Add(previous.Between(next,t));
                }
                if(d1>=0f) clipped.Add(next);
                previous=next;d0=d1;
            }
        }

        private static Mesh ClipField<T>(Mesh source,Rect bounds,NativeArray<T> input,IndexBuffer sourceIndices,
            SubMeshDescriptor[] subMeshes,VertexAttributeDescriptor[] layout,Func<Vector3,float> signedKeep)
            where T:struct,IVertex<T>
        {
            var field=new float[input.Length];
            var sideCodes=new byte[input.Length];
            var mapping=new int[input.Length];
            for(int i=0;i<input.Length;i++)
            {
                Vector3 p=input[i].Position;
                float value=signedKeep(p);
                if(float.IsNaN(value) || float.IsInfinity(value)) throw Invalid(source,"non-finite signed clipping field");
                field[i]=value;
                sideCodes[i]=(byte)((p.x<bounds.xMin?1:0)|(p.x>bounds.xMax?2:0)|
                    (p.z<bounds.yMin?4:0)|(p.z>bounds.yMax?8:0)|(value<0f?16:0));
            }
            var vertices=new List<T>(input.Length);
            int Index(int i)
            {
                if(mapping[i]==0) { vertices.Add(input[i]);mapping[i]=vertices.Count; }
                return mapping[i]-1;
            }
            FieldVertex<T> Vertex(int i) => new FieldVertex<T> { Value=input[i],Signed=field[i],Source=i };
            var polygon=new List<FieldVertex<T>>(8);var scratch=new List<FieldVertex<T>>(8);
            var groups=new List<int>[subMeshes.Length];
            for(int g=0;g<subMeshes.Length;g++)
            {
                var sub=subMeshes[g];
                var indices=groups[g]=new List<int>(sub.indexCount);
                for(int i=sub.indexStart;i<sub.indexStart+sub.indexCount;i+=3)
                {
                    int a=sourceIndices.Vertex(i,sub.baseVertex), b=sourceIndices.Vertex(i+1,sub.baseVertex), c=sourceIndices.Vertex(i+2,sub.baseVertex);
                    int ca=sideCodes[a], cb=sideCodes[b], cc=sideCodes[c];
                    if((ca&cb&cc)!=0) continue;
                    if((ca|cb|cc)==0) { indices.Add(Index(a));indices.Add(Index(b));indices.Add(Index(c));continue; }
                    polygon.Clear();polygon.Add(Vertex(a));polygon.Add(Vertex(b));polygon.Add(Vertex(c));
                    for(int side=0;side<5 && polygon.Count>0;side++)
                    {
                        ClipFieldSide(polygon,scratch,bounds,side);
                        var swap=polygon;polygon=scratch;scratch=swap;
                    }
                    if(polygon.Count<3) continue;
                    int first=-1,previous=-1;
                    for(int j=0;j<polygon.Count;j++)
                    {
                        var v=polygon[j];
                        int index;
                        if(v.Source>=0) index=Index(v.Source);
                        else { index=vertices.Count;vertices.Add(v.Value); }
                        if(j==0) first=index;
                        else if(j>=2) { indices.Add(first);indices.Add(previous);indices.Add(index); }
                        previous=index;
                    }
                }
            }
            var mesh=new Mesh { name=source.name+" clipped to visible surface",indexFormat=vertices.Count>65535?IndexFormat.UInt32:IndexFormat.UInt16 };
            try
            {
                mesh.SetVertexBufferParams(vertices.Count,layout);
                if(vertices.Count!=0) mesh.SetVertexBufferData(vertices,0,0,vertices.Count);
                mesh.subMeshCount=groups.Length;
                for(int i=0;i<groups.Length;i++) mesh.SetTriangles(groups[i],i,false);
                mesh.RecalculateBounds();mesh.UploadMeshData(true);
                return mesh;
            }
            catch { UnityEngine.Object.Destroy(mesh);throw; }
        }
    }
}
