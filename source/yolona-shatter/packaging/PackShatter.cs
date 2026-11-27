using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using Mono.Cecil;
using Mono.Cecil.Cil;

internal static class PackShatter
{
    private const string Bridge = "ScomShatterHost.EmbeddedShatter";
    private const string Startup = "ScomIntegratedUI.EmbeddedModule";
    private const string Resource = "SCOM.YolonaShatter.Runtime.dll";

    // Arguments are the installed patcher, compiled bridge, shatter runtime and output.
    public static void Main(string[] args)
    {
        if (args.Length != 4 || args.Take(3).Any(p => Path.GetFullPath(p) == Path.GetFullPath(args[3])))
            throw new ArgumentException("Expected host.dll bridge.dll runtime.dll separate-output.dll");
        using var runtime = AssemblyDefinition.ReadAssembly(args[2]);
        var plugin = runtime.MainModule.GetType("ScomShatter.ShatterPlugin");
        var metadata = plugin?.CustomAttributes.Single(a => a.AttributeType.FullName == "BepInEx.BepInPlugin");
        if (runtime.Name.Name != "ScomYolonaShatter" || (string)metadata?.ConstructorArguments[0].Value != "local.scom.yolona-shatter")
            throw new InvalidDataException("Unexpected shatter runtime.");

        using var host = AssemblyDefinition.ReadAssembly(args[0]);
        using var helper = AssemblyDefinition.ReadAssembly(args[1]);
        var module = host.MainModule;
        var startup = module.GetType(Startup).Methods.Single(m => m.Name == "Boot" && m.IsPublic && m.IsStatic && !m.HasParameters);
        var oldBridge = module.GetType(Bridge);
        var oldPayload = module.Resources.SingleOrDefault(r => r.Name == Resource);
        bool update = oldBridge != null;
        if (update != (oldPayload != null)) throw new InvalidDataException("Incomplete shatter integration.");
        if (update)
        {
            var previous = startup.Body.Instructions[0];
            if (!CallsBridge(previous)) throw new InvalidDataException("Unknown shatter startup hook.");
            startup.Body.GetILProcessor().Remove(previous);
            module.Types.Remove(oldBridge);
            module.Resources.Remove(oldPayload);
        }
        var bridge = CloneType(helper.MainModule.GetType(Bridge), module);
        var boot = bridge.Methods.Single(m => m.Name == "Boot" && m.IsPublic && m.IsStatic && !m.HasParameters);
        startup.Body.GetILProcessor().InsertBefore(startup.Body.Instructions[0], Instruction.Create(OpCodes.Call, boot));
        byte[] bytes = File.ReadAllBytes(args[2]);
        module.Resources.Add(new EmbeddedResource(Resource, Mono.Cecil.ManifestResourceAttributes.Private, bytes));
        byte[] identity = module.Mvid.ToByteArray().Concat(helper.MainModule.Mvid.ToByteArray())
            .Concat(runtime.MainModule.Mvid.ToByteArray()).ToArray();
        module.Mvid = new Guid(SHA256.HashData(identity).Take(16).ToArray());
        host.Write(args[3]);
        VerifyPreservation(args[0], args[3], bytes);
    }

    private static bool CallsBridge(Instruction i) => i.OpCode == OpCodes.Call && i.Operand is MethodReference m
        && m.Name == "Boot" && m.DeclaringType.FullName == Bridge;
    private static string Hash(byte[] value) => Convert.ToHexString(SHA256.HashData(value));

    private static IEnumerable<TypeDefinition> Types(IEnumerable<TypeDefinition> roots)
    {
        foreach (var type in roots) { yield return type; foreach (var child in Types(type.NestedTypes)) yield return child; }
    }
    private static string Attributes(IEnumerable<CustomAttribute> attributes)
        => string.Join("|", attributes.Select(a => a.AttributeType.FullName + ":" + Convert.ToHexString(a.GetBlob())));
    private static string Operand(object value, Mono.Collections.Generic.Collection<Instruction> instructions)
    {
        if (value is Instruction one) return "branch:" + instructions.IndexOf(one);
        if (value is Instruction[] many) return string.Join(",", many.Select(i => instructions.IndexOf(i)));
        return value == null ? "" : value.ToString();
    }
    private static string Body(MethodDefinition method)
    {
        if (!method.HasBody) return "";
        var instructions = method.Body.Instructions;
        return string.Join("\n", instructions.Select(i => (i.OpCode.OperandType == OperandType.ShortInlineBrTarget ? i.OpCode.Name.Substring(0, i.OpCode.Name.Length - 2) : i.OpCode.Name) + " " + Operand(i.Operand, instructions))) +
            "\nHANDLERS:" + string.Join("|", method.Body.ExceptionHandlers.Select(e => e.HandlerType + ":" + e.CatchType?.FullName + ":" + instructions.IndexOf(e.TryStart) + ":" + instructions.IndexOf(e.TryEnd) + ":" + instructions.IndexOf(e.HandlerStart) + ":" + instructions.IndexOf(e.HandlerEnd) + ":" + instructions.IndexOf(e.FilterStart)));
    }
    private static string FieldShape(FieldDefinition field)
        => field.FullName + ":" + field.Attributes + ":" + field.HasConstant + ":" + field.Constant + ":" + Attributes(field.CustomAttributes);
    private static string MethodShape(MethodDefinition method)
        => method.FullName + ":" + method.Attributes + ":" + method.ImplAttributes + ":" + Attributes(method.CustomAttributes) + ":" + Attributes(method.MethodReturnType.CustomAttributes) + ":" + string.Join("|", method.Parameters.Select(p => p.Name + ":" + p.Attributes + ":" + p.Constant + ":" + Attributes(p.CustomAttributes))) + ":" + string.Join("|", method.Overrides.Select(o => o.FullName));

    private static void VerifyPreservation(string original, string candidate, byte[] runtime)
    {
        using var before = AssemblyDefinition.ReadAssembly(original);
        using var after = AssemblyDefinition.ReadAssembly(candidate);
        if (before.Name.FullName != after.Name.FullName || Attributes(before.CustomAttributes) != Attributes(after.CustomAttributes)) throw new InvalidDataException("Assembly identity or attributes changed.");
        if (Attributes(before.MainModule.CustomAttributes) != Attributes(after.MainModule.CustomAttributes)) throw new InvalidDataException("Module attributes changed.");
        if (!before.MainModule.AssemblyReferences.Select(r => r.FullName).SequenceEqual(after.MainModule.AssemblyReferences.Select(r => r.FullName))) throw new InvalidDataException("Assembly dependencies changed.");
        var types = Types(after.MainModule.Types).ToDictionary(t => t.FullName);
        int count = 0;
        bool update = before.MainModule.GetType(Bridge) != null;
        foreach (var type in Types(before.MainModule.Types).Where(t => t.FullName != Bridge))
        {
            if (!types.TryGetValue(type.FullName, out var updatedType)) throw new InvalidDataException("Original type lost: " + type.FullName);
            if (type.Attributes != updatedType.Attributes || type.BaseType?.FullName != updatedType.BaseType?.FullName || Attributes(type.CustomAttributes) != Attributes(updatedType.CustomAttributes)) throw new InvalidDataException("Original type metadata changed: " + type.FullName);
            if (!type.Fields.Select(FieldShape).SequenceEqual(updatedType.Fields.Select(FieldShape))) throw new InvalidDataException("Original fields changed: " + type.FullName);
            if (!type.Properties.Select(p => p.FullName + ":" + p.Attributes + ":" + Attributes(p.CustomAttributes)).SequenceEqual(updatedType.Properties.Select(p => p.FullName + ":" + p.Attributes + ":" + Attributes(p.CustomAttributes)))) throw new InvalidDataException("Original properties changed: " + type.FullName);
            if (!type.Events.Select(e => e.FullName + ":" + e.Attributes + ":" + Attributes(e.CustomAttributes)).SequenceEqual(updatedType.Events.Select(e => e.FullName + ":" + e.Attributes + ":" + Attributes(e.CustomAttributes)))) throw new InvalidDataException("Original events changed: " + type.FullName);
            var methods = updatedType.Methods.ToDictionary(m => m.FullName);
            foreach (var method in type.Methods)
            {
                if (!methods.TryGetValue(method.FullName, out var updated) || MethodShape(method) != MethodShape(updated)) throw new InvalidDataException("Original method metadata changed: " + method.FullName);
                if (type.FullName == Startup && method.Name == "Boot")
                {
                    var il = updated.Body.Instructions;
                    if (!CallsBridge(il[0]) || il.Count(CallsBridge) != 1)
                        throw new InvalidDataException("Expected exactly one shatter startup call.");
                    il.RemoveAt(0);
                    if (update) method.Body.Instructions.RemoveAt(0);
                }
                if (Body(method) != Body(updated)) throw new InvalidDataException("Unrelated original behavior changed: " + method.FullName);
                count++;
            }
            if (type.Methods.Count != updatedType.Methods.Count) throw new InvalidDataException("Original type method count changed.");
        }
        foreach (var resource in before.MainModule.Resources.Cast<EmbeddedResource>().Where(r => r.Name != Resource))
        {
            var updated = after.MainModule.Resources.OfType<EmbeddedResource>().Single(r => r.Name == resource.Name);
            if (Hash(resource.GetResourceData()) != Hash(updated.GetResourceData())) throw new InvalidDataException("Original resource changed: " + resource.Name);
        }
        if (after.MainModule.Resources.Count != before.MainModule.Resources.Count + (update ? 0 : 1) ||
            Hash(after.MainModule.Resources.OfType<EmbeddedResource>().Single(r => r.Name == Resource).GetResourceData()) != Hash(runtime))
            throw new InvalidDataException("Embedded shatter payload or resource count changed.");
        if (types.Count != Types(before.MainModule.Types).Count() + (update ? 0 : 1)) throw new InvalidDataException("Unexpected added type count.");
        int discovery = types.Values.Count(t => t.IsPublic && t.Methods.Any(m => m.IsPublic && m.IsStatic && m.Name == "Patch") && t.Properties.Any(p => p.Name == "TargetDLLs"));
        if (discovery != 1) throw new InvalidDataException("Preloader discovery surface changed.");
        Console.WriteLine("PASS: preserved " + count + " original methods, metadata, all " + before.MainModule.Resources.Count + " resources and assembly dependencies; one public patcher remains and shatter is embedded byte-for-byte.");
    }

    internal static TypeDefinition CloneType(TypeDefinition source, ModuleDefinition target)
    {
        if (source.HasNestedTypes || source.HasGenericParameters) throw new InvalidDataException("Bridge must remain one nongeneric type.");
        var type = new TypeDefinition(source.Namespace, source.Name, source.Attributes, target.ImportReference(source.BaseType));
        target.Types.Add(type);
        var fields = new Dictionary<FieldDefinition, FieldDefinition>();
        var methods = new Dictionary<MethodDefinition, MethodDefinition>();
        foreach (var field in source.Fields)
        {
            var clone = new FieldDefinition(field.Name, field.Attributes, target.ImportReference(field.FieldType));
            if (field.HasConstant) clone.Constant = field.Constant;
            fields.Add(field, clone); type.Fields.Add(clone);
        }
        foreach (var method in source.Methods)
        {
            var clone = new MethodDefinition(method.Name, method.Attributes, target.ImportReference(method.ReturnType)) { ImplAttributes = method.ImplAttributes };
            foreach (var parameter in method.Parameters) clone.Parameters.Add(new ParameterDefinition(parameter.Name, parameter.Attributes, target.ImportReference(parameter.ParameterType)));
            methods.Add(method, clone); type.Methods.Add(clone);
        }
        foreach (var pair in methods)
        {
            var sourceMethod = pair.Key; var clone = pair.Value;
            if (!sourceMethod.HasBody) continue;
            clone.Body = new Mono.Cecil.Cil.MethodBody(clone) { InitLocals = sourceMethod.Body.InitLocals, MaxStackSize = sourceMethod.Body.MaxStackSize };
            foreach (var variable in sourceMethod.Body.Variables) clone.Body.Variables.Add(new VariableDefinition(target.ImportReference(variable.VariableType)));
            var instructions = sourceMethod.Body.Instructions.ToDictionary(i => i, i => Instruction.Create(OpCodes.Nop));
            foreach (var old in sourceMethod.Body.Instructions)
            {
                var fresh = instructions[old]; fresh.OpCode = old.OpCode;
                object value = old.Operand;
                if (value is Instruction branch) value = instructions[branch];
                else if (value is Instruction[] branches) value = branches.Select(i => instructions[i]).ToArray();
                else if (value is VariableDefinition variable) value = clone.Body.Variables[variable.Index];
                else if (value is ParameterDefinition parameter) value = clone.Parameters[parameter.Index];
                else if (value is MethodReference method) value = method.DeclaringType.FullName == source.FullName ? methods[method.Resolve()] : target.ImportReference(method);
                else if (value is FieldReference field) value = field.DeclaringType.FullName == source.FullName ? fields[field.Resolve()] : target.ImportReference(field);
                else if (value is TypeReference reference) value = reference.FullName == source.FullName ? type : target.ImportReference(reference);
                fresh.Operand = value; clone.Body.Instructions.Add(fresh);
            }
            foreach (var old in sourceMethod.Body.ExceptionHandlers)
                clone.Body.ExceptionHandlers.Add(new ExceptionHandler(old.HandlerType)
                {
                    CatchType = old.CatchType == null ? null : target.ImportReference(old.CatchType),
                    TryStart = instructions[old.TryStart], TryEnd = old.TryEnd == null ? null : instructions[old.TryEnd],
                    HandlerStart = instructions[old.HandlerStart], HandlerEnd = old.HandlerEnd == null ? null : instructions[old.HandlerEnd],
                    FilterStart = old.FilterStart == null ? null : instructions[old.FilterStart]
                });
        }
        foreach (var property in source.Properties)
            type.Properties.Add(new PropertyDefinition(property.Name, property.Attributes, target.ImportReference(property.PropertyType))
            { GetMethod = property.GetMethod == null ? null : methods[property.GetMethod], SetMethod = property.SetMethod == null ? null : methods[property.SetMethod] });
        return type;
    }
}
