using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using Mono.Cecil;

internal static class SetModVersion
{
    private const string Identity = "SupremeCommanderOverhaul-CachePatcher";
    private const string FileAttribute = "System.Reflection.AssemblyFileVersionAttribute";
    private const string InfoAttribute = "System.Reflection.AssemblyInformationalVersionAttribute";
    private static string Hash(byte[] bytes) => Convert.ToHexString(SHA256.HashData(bytes)).ToLowerInvariant();
    private static string Shape(AssemblyDefinition assembly) => (string)typeof(ResourceUpdate).GetMethod("Shape", BindingFlags.NonPublic | BindingFlags.Static).Invoke(null, new object[] { assembly });

    public static int Main(string[] args)
    {
        try
        {
            if (args.Length != 3 || Path.GetFullPath(args[0]) == Path.GetFullPath(args[1]))
                throw new ArgumentException("Usage: SetModVersion input.dll output.dll expected-input-sha256");
            if (Hash(File.ReadAllBytes(args[0])) != args[2]) throw new InvalidDataException("Input hash changed.");
            using (var assembly = AssemblyDefinition.ReadAssembly(args[0]))
            {
                if (assembly.Name.Name != Identity || (assembly.Name.Version != new Version(1, 2, 1, 0) && assembly.Name.Version != new Version(1, 5, 0, 0)))
                    throw new InvalidDataException("Unexpected original mod identity/version: " + assembly.Name.FullName + "; File " + (string)assembly.CustomAttributes.Single(a => a.AttributeType.FullName == FileAttribute).ConstructorArguments[0].Value + "; Informational " + (string)assembly.CustomAttributes.Single(a => a.AttributeType.FullName == InfoAttribute).ConstructorArguments[0].Value);
                ReportReferences(assembly);
                assembly.Name.Version = new Version(1, 5, 1, 0);
                SetAttribute(assembly, FileAttribute, "1.5.1.0");
                SetAttribute(assembly, InfoAttribute, "1.5.1");
                assembly.Write(args[1]);
            }
            UpdateWin32Version(args[1]);
            Verify(args[0], args[1]);
            var native = FileVersionInfo.GetVersionInfo(args[1]);
            if (native.FileVersion != "1.5.1.0" || native.ProductVersion != "1.5.1" ||
                native.FileMajorPart != 1 || native.FileMinorPart != 5 || native.FileBuildPart != 1 || native.FilePrivatePart != 0 ||
                native.ProductMajorPart != 1 || native.ProductMinorPart != 5 || native.ProductBuildPart != 1 || native.ProductPrivatePart != 0)
                throw new InvalidDataException("Native Windows version properties were not updated.");
            Console.WriteLine("PASS: assembly 1.5.1.0, file 1.5.1.0, informational/product 1.5.1, including Windows properties.");
            Console.WriteLine("Output SHA256 " + Hash(File.ReadAllBytes(args[1])));
            return 0;
        }
        catch (Exception error) { Console.Error.WriteLine(error); return 1; }
    }

    private static void SetAttribute(AssemblyDefinition assembly, string name, string value)
    {
        var attribute = assembly.CustomAttributes.Single(a => a.AttributeType.FullName == name);
        attribute.ConstructorArguments[0] = new CustomAttributeArgument(assembly.MainModule.TypeSystem.String, value);
    }

    private static void StripVersions(AssemblyDefinition assembly)
    {
        assembly.Name.Version = new Version(0, 0, 0, 0);
        foreach (var attribute in assembly.CustomAttributes.Where(a => a.AttributeType.FullName == FileAttribute || a.AttributeType.FullName == InfoAttribute).ToArray())
            assembly.CustomAttributes.Remove(attribute);
    }

    private static void Verify(string original, string candidate)
    {
        using var before = AssemblyDefinition.ReadAssembly(original);
        using var after = AssemblyDefinition.ReadAssembly(candidate);
        if (after.Name.Version != new Version(1, 5, 1, 0)) throw new InvalidDataException("Wrong final assembly version.");
        if ((string)after.CustomAttributes.Single(a => a.AttributeType.FullName == FileAttribute).ConstructorArguments[0].Value != "1.5.1.0" ||
            (string)after.CustomAttributes.Single(a => a.AttributeType.FullName == InfoAttribute).ConstructorArguments[0].Value != "1.5.1")
            throw new InvalidDataException("Wrong final version attributes.");
        StripVersions(before); StripVersions(after);
        if (Shape(before) != Shape(after)) throw new InvalidDataException("Unrelated metadata or method behavior changed.");
        if (before.MainModule.Resources.Count != after.MainModule.Resources.Count) throw new InvalidDataException("Resource count changed.");
        for (int i = 0; i < before.MainModule.Resources.Count; i++)
        {
            var left = (EmbeddedResource)before.MainModule.Resources[i];
            var right = (EmbeddedResource)after.MainModule.Resources[i];
            if (left.Name != right.Name || left.Attributes != right.Attributes || Hash(left.GetResourceData()) != Hash(right.GetResourceData()))
                throw new InvalidDataException("Managed resource changed: " + left.Name);
        }
        Console.WriteLine("PASS: version metadata only; all existing method bodies, unrelated metadata and all " + before.MainModule.Resources.Count + " managed resources preserved.");
    }

    private static void ReportReferences(AssemblyDefinition assembly)
    {
        if (assembly.MainModule.AssemblyReferences.Any(a => a.Name == Identity))
            throw new InvalidDataException("Unexpected explicit self assembly reference; manual audit required.");
        int checkedCount = 0;
        foreach (var resource in assembly.MainModule.Resources.OfType<EmbeddedResource>())
        {
            if (!resource.Name.EndsWith(".dll", StringComparison.OrdinalIgnoreCase)) continue;
            byte[] bytes = resource.GetResourceData();
            if (bytes.Length < 2 || bytes[0] != 'M' || bytes[1] != 'Z') continue;
            using var inner = AssemblyDefinition.ReadAssembly(new MemoryStream(bytes));
            if (inner.MainModule.AssemblyReferences.Any(a => a.Name == Identity))
                throw new InvalidDataException("Embedded runtime explicitly references old mod assembly: " + resource.Name);
            checkedCount++;
        }
        Console.WriteLine("PASS: no explicit assembly self-reference in main assembly or " + checkedCount + " embedded managed runtimes.");
    }

    private static ushort U16(byte[] data, int p) => BitConverter.ToUInt16(data, p);
    private static uint U32(byte[] data, int p) => BitConverter.ToUInt32(data, p);
    private static int Align(int p) => (p + 3) & ~3;

    private static void UpdateWin32Version(string path)
    {
        byte[] data = File.ReadAllBytes(path);
        byte[] original = (byte[])data.Clone();
        var allowed = new HashSet<int>();
        void Write(int position, byte[] value)
        {
            Array.Copy(value, 0, data, position, value.Length);
            for (int i = position; i < position + value.Length; i++) allowed.Add(i);
        }
        int pe = checked((int)U32(data, 0x3c));
        if (U32(data, pe) != 0x4550) throw new InvalidDataException("Invalid PE image.");
        int optional = pe + 24;
        int directories = optional + (U16(data, optional) == 0x20b ? 112 : 96);
        uint resourceRva = U32(data, directories + 16);
        int sections = optional + U16(data, pe + 20);
        int Rva(uint address)
        {
            for (int i = 0; i < U16(data, pe + 6); i++)
            {
                int section = sections + 40 * i;
                uint start = U32(data, section + 12);
                uint size = Math.Max(U32(data, section + 8), U32(data, section + 16));
                if (address >= start && address < start + size)
                    return checked((int)(U32(data, section + 20) + address - start));
            }
            throw new InvalidDataException("Resource RVA is outside image sections.");
        }
        int baseOffset = Rva(resourceRva);
        var leaves = new List<(int Offset, int Length)>();
        void Walk(int relative, int depth)
        {
            int table = baseOffset + relative;
            int count = U16(data, table + 12) + U16(data, table + 14);
            for (int i = 0; i < count; i++)
            {
                int entry = table + 16 + i * 8;
                uint name = U32(data, entry), value = U32(data, entry + 4);
                if (depth == 0 && name != 16) continue;
                if ((value & 0x80000000) != 0) Walk(checked((int)(value & 0x7fffffff)), depth + 1);
                else
                {
                    int leaf = baseOffset + checked((int)value);
                    leaves.Add((Rva(U32(data, leaf)), checked((int)U32(data, leaf + 4))));
                }
            }
        }
        Walk(0, 0);
        if (leaves.Count != 1) throw new InvalidDataException("Expected one native VERSIONINFO resource.");
        var resource = leaves[0];
        var strings = new HashSet<string>();
        bool fixedUpdated = false;
        void Block(int position, int limit)
        {
            int length = U16(data, position), valueLength = U16(data, position + 2), type = U16(data, position + 4);
            if (length < 6 || position + length > limit) throw new InvalidDataException("Invalid native version block.");
            int endKey = position + 6;
            while (U16(data, endKey) != 0) endKey += 2;
            string key = Encoding.Unicode.GetString(data, position + 6, endKey - position - 6);
            int value = Align(endKey + 2);
            int bytes = type == 1 ? valueLength * 2 : valueLength;
            if (value + bytes > position + length) throw new InvalidDataException("Native version value exceeds block.");
            if (key == "VS_VERSION_INFO")
            {
                if (valueLength != 52 || U32(data, value) != 0xfeef04bd) throw new InvalidDataException("Unexpected fixed version info.");
                foreach (int at in new[] { value + 8, value + 16 })
                {
                    Write(at, BitConverter.GetBytes((uint)((1 << 16) | 5)));
                    Write(at + 4, BitConverter.GetBytes((uint)(1 << 16)));
                }
                fixedUpdated = true;
            }
            if (key == "FileVersion" || key == "ProductVersion")
            {
                string next = key == "FileVersion" ? "1.5.1.0" : "1.5.1";
                byte[] encoded = Encoding.Unicode.GetBytes(next + "\0");
                if (encoded.Length > bytes) throw new InvalidDataException("New native version string does not fit existing allocation.");
                Write(position + 2, BitConverter.GetBytes((ushort)(next.Length + 1)));
                var padded = new byte[bytes]; Array.Copy(encoded, padded, encoded.Length); Write(value, padded);
                strings.Add(key);
            }
            for (int child = Align(value + bytes); child + 6 <= position + length;)
            {
                int childLength = U16(data, child);
                if (childLength == 0) break;
                Block(child, position + length);
                child = Align(child + childLength);
            }
        }
        Block(resource.Offset, resource.Offset + resource.Length);
        if (!fixedUpdated || strings.Count != 2) throw new InvalidDataException("Incomplete native version update.");
        for (int i = 0; i < data.Length; i++)
            if (data[i] != original[i] && !allowed.Contains(i)) throw new InvalidDataException("Unrelated native bytes changed.");
        File.WriteAllBytes(path, data);
    }
}
