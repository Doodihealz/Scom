using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using Mono.Cecil;

internal static class BuildAiCompatibility
{
    private static byte[] Serialize(AssemblyDefinition assembly)
    {
        using var buffer = new MemoryStream();
        var options = new WriterParameters { Timestamp = 0 };
        assembly.Write(buffer, options);
        buffer.Position = 0;
        assembly.MainModule.Mvid = new Guid(SHA256.HashData(buffer).AsSpan(0, 16));
        buffer.SetLength(0);
        assembly.Write(buffer, options);
        return buffer.ToArray();
    }

    private static EmbeddedResource Resource(ModuleDefinition module, string name) =>
        module.Resources.OfType<EmbeddedResource>().Single(r => r.Name == name);

    private static void ReplaceResource(ModuleDefinition module, string name, byte[] bytes)
    {
        var before = Resource(module, name);
        module.Resources[module.Resources.IndexOf(before)] = new EmbeddedResource(name, before.Attributes, bytes);
    }

    private static void InstallEdits(ModuleDefinition target, ModuleDefinition source)
    {
        // Resolve the original method tokens while their declaring types still belong to the module.
        var originalCalls = target.GetTypes().Where(t => source.GetType(t.FullName) == null).SelectMany(t => t.Methods).Where(m => m.HasBody)
            .SelectMany(m => m.Body.Instructions).Where(i => i.Operand is MethodReference).ToArray();
        var replacements = new Dictionary<string, TypeDefinition>(StringComparer.Ordinal);
        foreach (var type in source.Types.Where(t => t.Name != "<Module>" && !t.Namespace.StartsWith("Microsoft.") && !t.Namespace.StartsWith("System.")))
        {
            var before = target.GetType(type.FullName);
            if (before != null) target.Types.Remove(before);
            else if (type.Name != "OptionalAiSource") throw new InvalidDataException("Unexpected new type " + type.FullName);
            replacements.Add(type.FullName, PackShatter.CloneType(type, target));
        }
        if (replacements.Count != 5) throw new InvalidDataException("Unexpected AI edit inventory");
        // Calls from the composer and the compiled edit classes must resolve inside the shipped runtime.
        var newCode = replacements.Values.SelectMany(t => t.Methods).Where(m => m.HasBody)
            .SelectMany(m => m.Body.Instructions);
        foreach (var instruction in originalCalls.Concat(newCode))
            if (instruction.Operand is MethodReference call && replacements.TryGetValue(call.DeclaringType.FullName, out var owner))
                instruction.Operand = owner.Methods.Single(m => m.FullName == call.FullName);
        var temporary = target.AssemblyReferences.SingleOrDefault(r => r.Name == source.Assembly.Name.Name);
        if (temporary != null) target.AssemblyReferences.Remove(temporary);
    }

    internal static void Main(string[] args)
    {
        string engine = args[0], input = args[1], edits = args[2], presentation = args[3], output = args[4];
        if (Path.GetFullPath(input) == Path.GetFullPath(output) || File.Exists(output))
            throw new IOException("Select a new output file.");
        using (var stream = File.OpenRead(input)) {
            var hash = Convert.ToHexString(SHA256.HashData(stream));
            if (hash != "D56FA4E3F7BE55BA41DB4E77F72B5E7919FEE69EA9D269EA6FB32D3CC92DBA07" &&
                hash != "573C85411D6A95393A9CA1DB7E99E1D306D3814542D2473FF6A0097A63CA0C16")
                throw new InvalidDataException("Expected the public 1.5.0 SCOM patcher or its first Rush hotfix.");
        }
        using var resolver = new DefaultAssemblyResolver();
        resolver.AddSearchDirectory(Path.Combine(engine, "Sanctuary_Data", "Managed"));
        resolver.AddSearchDirectory(Path.Combine(engine, "BepInEx", "core"));
        var options = new ReaderParameters { AssemblyResolver = resolver };
        using var owner = AssemblyDefinition.ReadAssembly(input, options);
        using var runtimeStream = Resource(owner.MainModule, "SCOM.Playtest.Runtime.dll").GetResourceStream();
        using var runtime = AssemblyDefinition.ReadAssembly(runtimeStream, options);
        using var helper = AssemblyDefinition.ReadAssembly(edits, options);
        InstallEdits(runtime.MainModule, helper.MainModule);
        ReplaceResource(runtime.MainModule, "SCOM.GameplayPresentation.dll", File.ReadAllBytes(presentation));
        ReplaceResource(owner.MainModule, "SCOM.Playtest.Runtime.dll", Serialize(runtime));
        File.WriteAllBytes(output, Serialize(owner));
    }
}
