using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text.Json;
using Mono.Cecil;
using Mono.Cecil.Cil;

internal static class ResourceUpdate
{
    private const string ResourceName = "SCOM.IntegratedUI.Runtime.dll";
    private static string Hash(byte[] bytes) => Convert.ToHexString(SHA256.HashData(bytes)).ToLowerInvariant();
    private static EmbeddedResource Runtime(AssemblyDefinition assembly)
        => assembly.MainModule.Resources.OfType<EmbeddedResource>().Single(r => r.Name == ResourceName);

    public static int Main(string[] args)
    {
        try
        {
            if (args.Length == 3 && args[0] == "dumpmeta")
            {
                using var assembly = AssemblyDefinition.ReadAssembly(args[1]);
                File.WriteAllText(args[2], Shape(assembly));
                return 0;
            }
            if (args.Length == 2 && args[0] == "info")
            {
                using var assembly = AssemblyDefinition.ReadAssembly(args[1]);
                Console.WriteLine("Assembly " + assembly.Name.FullName);
                foreach (var attribute in assembly.CustomAttributes.Where(a => a.AttributeType.Name.Contains("Version") || a.AttributeType.Name.Contains("Title") || a.AttributeType.Name.Contains("Product")))
                    Console.WriteLine(attribute.AttributeType.FullName + " " + string.Join("; ", attribute.ConstructorArguments.Select(a => a.Value)));
                foreach (var type in Types(assembly))
                {
                    foreach (var attribute in type.CustomAttributes.Where(a => a.AttributeType.Name == "BepInPlugin"))
                        Console.WriteLine(type.FullName + " " + string.Join("; ", attribute.ConstructorArguments.Select(a => a.Value)));
                    foreach (var field in type.Fields.Where(f => f.HasConstant && f.Name.Contains("Version", StringComparison.OrdinalIgnoreCase)))
                        Console.WriteLine(field.FullName + " = " + field.Constant);
                }
                return 0;
            }
            if (args.Length == 3 && args[0] == "extract")
            {
                using var assembly = AssemblyDefinition.ReadAssembly(args[1]);
                byte[] bytes = Runtime(assembly).GetResourceData();
                File.WriteAllBytes(args[2], bytes);
                Console.WriteLine("Extracted " + ResourceName + " SHA256 " + Hash(bytes));
                return 0;
            }
            if (args.Length == 4 && args[0] == "replace")
            {
                if (Path.GetFullPath(args[1]) == Path.GetFullPath(args[3]))
                    throw new ArgumentException("Output must differ from input.");
                byte[] payload = File.ReadAllBytes(args[2]);
                using (var ui = AssemblyDefinition.ReadAssembly(new MemoryStream(payload)))
                {
                    if (ui.Name.Name != "Scom.UI.Runtime") throw new InvalidDataException("Wrong UI assembly identity.");
                    var plugin = ui.MainModule.GetType("SupComStyleUI.SupComStyleUIPlugin")
                        ?? throw new InvalidDataException("UI plugin missing.");
                    var attribute = plugin.CustomAttributes.Single(a => a.AttributeType.FullName == "BepInEx.BepInPlugin");
                    if ((string)attribute.ConstructorArguments[0].Value != "ziggy.sanctuary.supcom-style-ui")
                        throw new InvalidDataException("UI plugin GUID changed.");
                }
                using (var assembly = AssemblyDefinition.ReadAssembly(args[1]))
                {
                    var old = Runtime(assembly);
                    int index = assembly.MainModule.Resources.IndexOf(old);
                    assembly.MainModule.Resources[index] = new EmbeddedResource(old.Name, old.Attributes, payload);
                    assembly.Write(args[3]);
                }
                Verify(args[1], args[3], payload);
                Console.WriteLine("Output SHA256 " + Hash(File.ReadAllBytes(args[3])));
                return 0;
            }
            if (args.Length == 3 && args[0] == "compare")
            {
                using var before = AssemblyDefinition.ReadAssembly(args[1]);
                using var after = AssemblyDefinition.ReadAssembly(args[2]);
                var left = Methods(before).ToDictionary(m => m.FullName, m => Method(m));
                var right = Methods(after).ToDictionary(m => m.FullName, m => Method(m));
                foreach (string key in left.Keys.Union(right.Keys).OrderBy(k => k))
                    if (!left.TryGetValue(key, out string a) || !right.TryGetValue(key, out string b) || a != b)
                        Console.WriteLine("Changed method: " + key);
                return 0;
            }
            throw new ArgumentException("Usage: extract input.dll output-ui.dll | replace input.dll ui.dll output.dll | compare before-ui.dll after-ui.dll");
        }
        catch (Exception error) { Console.Error.WriteLine(error); return 1; }
    }

    private static void Verify(string input, string output, byte[] payload)
    {
        using var before = AssemblyDefinition.ReadAssembly(input);
        using var after = AssemblyDefinition.ReadAssembly(output);
        if (Shape(before) != Shape(after)) throw new InvalidDataException("Assembly metadata or method behavior changed.");
        if (before.MainModule.Resources.Count != after.MainModule.Resources.Count)
            throw new InvalidDataException("Resource count changed.");
        for (int i = 0; i < before.MainModule.Resources.Count; i++)
        {
            Resource left = before.MainModule.Resources[i], right = after.MainModule.Resources[i];
            if (left.Name != right.Name || left.Attributes != right.Attributes || left.ResourceType != right.ResourceType)
                throw new InvalidDataException("Resource metadata/order changed: " + left.Name);
            if (left is EmbeddedResource embedded)
            {
                byte[] expected = left.Name == ResourceName ? payload : embedded.GetResourceData();
                if (right is not EmbeddedResource updated || Hash(expected) != Hash(updated.GetResourceData()))
                    throw new InvalidDataException("Resource mismatch: " + left.Name);
            }
            else if (left.ToString() != right.ToString())
                throw new InvalidDataException("External resource changed: " + left.Name);
        }
        Console.WriteLine("PASS: replaced only " + ResourceName + "; preserved " + Methods(before).Count() +
            " method bodies/signatures, assembly/module/type/member metadata, resource order and all " +
            (before.MainModule.Resources.Count - 1) + " other resources.");
    }

    private static IEnumerable<TypeDefinition> Types(AssemblyDefinition a) => a.Modules.SelectMany(m => m.GetTypes());
    private static IEnumerable<MethodDefinition> Methods(AssemblyDefinition a) => Types(a).SelectMany(t => t.Methods);
    private static string Attr(ICustomAttributeProvider p) => string.Join("|", p.CustomAttributes.Select(a => a.AttributeType.FullName + ":" + Convert.ToHexString(a.GetBlob())));
    private static string Security(ISecurityDeclarationProvider p) => string.Join("|", p.SecurityDeclarations.Select(d => d.Action + ":" + Convert.ToHexString(d.GetBlob())));
    private static string Constant(bool has, object value) => has + ":" + value?.GetType().FullName + ":" + JsonSerializer.Serialize(value);
    private static string Marshal(IMarshalInfoProvider p) => !p.HasMarshalInfo ? "" : JsonSerializer.Serialize(new { Type = p.MarshalInfo.GetType().FullName, Value = p.MarshalInfo.ToString() });
    private static object Parameter(ParameterDefinition p) => new { p.Name, p.Attributes, Type = p.ParameterType.FullName, Value = Constant(p.HasConstant, p.Constant), CustomAttributes = Attr(p), Marshal = Marshal(p) };
    private static object Generic(GenericParameter g) => new { g.Name, g.Attributes, CustomAttributes = Attr(g), Constraints = g.Constraints.Select(c => c.FullName).ToArray() };
    private static object Return(MethodReturnType r) => new { Type = r.ReturnType.FullName, r.Name, r.Attributes, Value = Constant(r.HasConstant, r.Constant), CustomAttributes = Attr(r), Marshal = Marshal(r) };
    private static string Operand(object value, Mono.Collections.Generic.Collection<Instruction> list)
    {
        if (value is Instruction i) return "branch:" + list.IndexOf(i);
        if (value is Instruction[] many) return string.Join(",", many.Select(i => list.IndexOf(i)));
        if (value is string text) return JsonSerializer.Serialize(text);
        if (value is VariableDefinition local) return "local:" + local.Index;
        if (value is ParameterDefinition parameter) return "parameter:" + parameter.Index;
        return value == null ? "" : value.ToString();
    }
    private static string Method(MethodDefinition m)
    {
        var body = m.HasBody ? m.Body : null;
        var il = body?.Instructions;
        return JsonSerializer.Serialize(new {
            m.FullName, m.Name, m.Attributes, m.ImplAttributes, m.CallingConvention, m.HasThis, m.ExplicitThis,
            CustomAttributes = Attr(m), Security = Security(m), Return = Return(m.MethodReturnType),
            Parameters = m.Parameters.Select(Parameter).ToArray(), Generics = m.GenericParameters.Select(Generic).ToArray(),
            Overrides = m.Overrides.Select(o => o.FullName).ToArray(),
            PInvoke = m.HasPInvokeInfo ? new { m.PInvokeInfo.Attributes, m.PInvokeInfo.EntryPoint, Module = m.PInvokeInfo.Module.Name } : null,
            Body = body == null ? null : new {
                body.InitLocals, body.MaxStackSize, Variables = body.Variables.Select(v => v.VariableType.FullName).ToArray(),
                Instructions = il.Select(i => i.OpCode.Name + " " + Operand(i.Operand, il)).ToArray(),
                Handlers = body.ExceptionHandlers.Select(h => new { h.HandlerType, Catch = h.CatchType?.FullName, Try = il.IndexOf(h.TryStart), TryEnd = il.IndexOf(h.TryEnd), Handler = il.IndexOf(h.HandlerStart), HandlerEnd = il.IndexOf(h.HandlerEnd), Filter = il.IndexOf(h.FilterStart) }).ToArray()
            }
        });
    }
    private static string Shape(AssemblyDefinition a) => JsonSerializer.Serialize(new {
        Name = a.Name.FullName, a.Name.Attributes, PublicKey = Convert.ToHexString(a.Name.PublicKey), a.Name.HashAlgorithm,
        CustomAttributes = Attr(a), Security = Security(a),
        Modules = a.Modules.Select(m => new {
            m.Name, m.Kind, m.Runtime, m.RuntimeVersion, m.Architecture, m.Attributes, m.Characteristics, m.Mvid,
            CustomAttributes = Attr(m), Entry = m.EntryPoint?.FullName,
            References = m.AssemblyReferences.Select(r => r.FullName + ":" + r.Attributes + ":" + r.HashAlgorithm + ":" + Convert.ToHexString(r.Hash)).ToArray(),
            ModuleReferences = m.ModuleReferences.Select(r => r.Name).ToArray(),
            Exported = m.ExportedTypes.Select(t => t.FullName + ":" + t.Attributes + ":" + t.Scope).ToArray(),
            Types = m.GetTypes().Select(t => new {
                t.FullName, t.Attributes, Base = t.BaseType?.FullName, t.PackingSize, t.ClassSize, CustomAttributes = Attr(t), Security = Security(t),
                Interfaces = t.Interfaces.Select(i => new { Type = i.InterfaceType.FullName, CustomAttributes = Attr(i) }).ToArray(),
                Generics = t.GenericParameters.Select(Generic).ToArray(),
                // RVAs are physical PE addresses. A larger embedded resource can
                // relocate initialized field data without changing its bytes or
                // semantics. Preserve whether storage exists and compare every
                // initial byte, along with the field's full metadata and offset.
                Fields = t.Fields.Select(f => new { f.FullName, f.Attributes, f.Offset, HasRva = f.RVA != 0, InitialValue = Convert.ToHexString(f.InitialValue), Value = Constant(f.HasConstant, f.Constant), CustomAttributes = Attr(f), Marshal = Marshal(f) }).ToArray(),
                Methods = t.Methods.Select(Method).ToArray(),
                Properties = t.Properties.Select(p => new { p.FullName, p.Attributes, p.HasThis, Value = Constant(p.HasConstant, p.Constant), CustomAttributes = Attr(p), Get = p.GetMethod?.FullName, Set = p.SetMethod?.FullName, Other = p.OtherMethods.Select(m => m.FullName).ToArray(), Parameters = p.Parameters.Select(Parameter).ToArray() }).ToArray(),
                Events = t.Events.Select(e => new { e.FullName, e.Attributes, CustomAttributes = Attr(e), Add = e.AddMethod?.FullName, Remove = e.RemoveMethod?.FullName, Invoke = e.InvokeMethod?.FullName, Other = e.OtherMethods.Select(m => m.FullName).ToArray() }).ToArray()
            }).ToArray()
        }).ToArray()
    });
}
