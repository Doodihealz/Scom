using System.IO;
using System.IO.Compression;
using UnityEngine;

namespace ScomShatter
{
    internal static class CampaignInterior
    {
        private const string Prefix = "ScomShatter.Interior.";
        internal const float FloorDepth = 136.800003f, RootZ = 7.2800293f, FloorScale = 2649.45947f;
        internal static readonly Vector3 FrameOffset = new Vector3(111.199951f,-41f,-313.719971f);
        private static Mesh reduced;

        internal static Mesh ReducedFrame { get { ReadFrame(); return reduced; } }

        private static void ReadFrame()
        {
            if (reduced != null) return;
            using (var stream = Resource("frame.gz"))
            using (var gzip = new GZipStream(stream, CompressionMode.Decompress))
            using (var reader = new BinaryReader(gzip))
            {
                if (reader.ReadUInt32() != 0x32495353) throw new InvalidDataException("Invalid campaign interior mesh.");
                int count = reader.ReadInt32(), groups = reader.ReadInt32();
                if (count < 3 || count > 60000 || groups != 4) throw new InvalidDataException("Invalid campaign interior mesh bounds.");
                var vertices = new FrameSection.Full[count];
                for (int i = 0; i < count; ++i)
                {
                    var position = new Vector3(reader.ReadSingle(), reader.ReadSingle(), reader.ReadSingle());
                    var normal = new Vector3(reader.ReadSingle(), reader.ReadSingle(), reader.ReadSingle());
                    var uv = new Vector2(reader.ReadSingle(), reader.ReadSingle());
                    var tangent = new Vector4(reader.ReadSingle(), reader.ReadSingle(), reader.ReadSingle(), reader.ReadSingle());
                    vertices[i] = new FrameSection.Full { Point=position / .54335621f - FrameOffset,
                        Normal=normal, Tangent=tangent, UV=uv };
                }
                var triangles = new int[groups][];
                for (int g = 0; g < groups; ++g)
                {
                    int length = reader.ReadInt32();
                    if (length < 0 || length > 180000 || length % 3 != 0) throw new InvalidDataException("Invalid campaign interior triangles.");
                    var group = new int[length];
                    for (int i = 0; i < length; ++i)
                    {
                        group[i] = reader.ReadUInt16();
                        if (group[i] >= count) throw new InvalidDataException("Invalid campaign interior vertex index.");
                    }
                    triangles[g] = group;
                }
                var mesh=new Mesh { name="Campaign frame distance LOD" };
                try
                {
                    // Keep the CPU stream deterministic so border clipping needs no native attribute conversion.
                    mesh.SetVertexBufferParams(count,FrameSection.FullLayout);
                    mesh.SetVertexBufferData(vertices,0,0,count);
                    mesh.subMeshCount=groups;
                    for(int g=0;g<groups;g++) mesh.SetTriangles(triangles[g],g,false);
                    mesh.RecalculateBounds();
                    reduced=mesh;
                }
                catch { Object.Destroy(mesh);throw; }
            }
        }

        private static Stream Resource(string name)
        {
            var stream = typeof(CampaignInterior).Assembly.GetManifestResourceStream(Prefix + name);
            if (stream == null) throw new InvalidDataException("Missing campaign interior resource: " + name);
            return stream;
        }

        internal static void Release()
        {
            if (reduced != null) Object.Destroy(reduced);
            reduced = null;
        }
    }
}
