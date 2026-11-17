using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text.Json;
using Mono.Cecil;
using Mono.Cecil.Cil;

internal static class InstallGroundMarks
{
    const string ResourceName = "SCOM.GroundMarks.Runtime.dll";
    const string TypeName = "ScomTerrainDeformation.EmbeddedModule";
    const string Suffix = "/common/systems/scoNuclearPresentation.lua";
    const string ContactSuffix = "/client/units/unitsClasses/unitsBaseClass.lua";
    static string Hash(byte[] bytes) => Convert.ToHexString(SHA256.HashData(bytes));
    static string Fingerprint(MethodDefinition method)
    {
        if (!method.HasBody) return method.FullName;
        var il=method.Body.Instructions;
        string Operand(object value) => value is Instruction target ? "@"+il.IndexOf(target) : value is Instruction[] targets ? string.Join(",",targets.Select(t=>"@"+il.IndexOf(t))) : value?.ToString() ?? "";
        return JsonSerializer.Serialize(new {
            method.FullName,method.Attributes,method.ImplAttributes,method.Body.InitLocals,
            Variables=method.Body.Variables.Select(v=>v.VariableType.FullName).ToArray(),
            IL=il.Select(i=>i.OpCode.Name+" "+Operand(i.Operand)).ToArray(),
            Handlers=method.Body.ExceptionHandlers.Select(h=>new {h.HandlerType,Catch=h.CatchType?.FullName,Try=il.IndexOf(h.TryStart),TryEnd=il.IndexOf(h.TryEnd),Handler=il.IndexOf(h.HandlerStart),HandlerEnd=il.IndexOf(h.HandlerEnd),Filter=il.IndexOf(h.FilterStart)}).ToArray()
        });
    }
    public static void Main(string[] args)
    {
        if(args.Length!=3) throw new ArgumentException("input-patcher.dll runtime.dll output-patcher.dll");
        if(Path.GetFullPath(args[0])==Path.GetFullPath(args[2]))throw new ArgumentException("Output must differ from input");
        using var assembly=AssemblyDefinition.ReadAssembly(args[0]);
        if(assembly.MainModule.Resources.Any(r=>r.Name==ResourceName))throw new InvalidDataException("Ground marks resource already present");
        var type=assembly.MainModule.GetType(TypeName) ?? throw new InvalidDataException("Terrain bridge missing");
        var method=type.Methods.Single(m=>m.Name=="Transform"&&m.Parameters.Count==2&&m.ReturnType.FullName=="System.Byte[]");
        var old=method.Body.Instructions.ToArray();
        if(old.Length<8 || old[0].OpCode!=OpCodes.Ldarg_1 || old[4].OpCode!=OpCodes.Stloc_0 || old[5].OpCode!=OpCodes.Ldloc_0)
            throw new InvalidDataException("Expected path normalization prefix changed");
        if(method.Body.Variables[0].VariableType.FullName!="System.String")throw new InvalidDataException("Normalized path local changed");
        var load=type.Methods.Single(m=>m.Name=="Load"&&m.Parameters.Count==1);
        MethodReference Ref(string declaring,string name,int count) => old.Select(i=>i.Operand).OfType<MethodReference>().First(m=>m.DeclaringType.FullName==declaring&&m.Name==name&&m.Parameters.Count==count);
        var endsWith=Ref("System.String","EndsWith",2);
        var getType=Ref("System.Reflection.Assembly","GetType",2);
        var getMethod=Ref("System.Type","GetMethod",1);
        var invoke=Ref("System.Reflection.MethodBase","Invoke",2);
        var objectType=(TypeReference)old.Single(i=>i.OpCode==OpCodes.Newarr).Operand;
        var bytesType=(TypeReference)old.Single(i=>i.OpCode==OpCodes.Castclass).Operand;
        var cachedMethod=new FieldDefinition("groundMarksTransform",FieldAttributes.Private|FieldAttributes.Static,getMethod.ReturnType);
        if(type.Fields.Any(f=>f.Name==cachedMethod.Name))throw new InvalidDataException("Ground marks bridge field already present");
        type.Fields.Add(cachedMethod);
        var invokeStart=Instruction.Create(OpCodes.Ldsfld,cachedMethod);
        var originalGate=old[5];
        var bridgeStart=Instruction.Create(OpCodes.Ldsfld,cachedMethod);
        var prefix=new[] {
            Instruction.Create(OpCodes.Ldloc_0),Instruction.Create(OpCodes.Ldstr,Suffix),
            Instruction.Create(OpCodes.Ldc_I4_4),Instruction.Create(OpCodes.Callvirt,endsWith),
            Instruction.Create(OpCodes.Brtrue,bridgeStart),
            Instruction.Create(OpCodes.Ldloc_0),Instruction.Create(OpCodes.Ldstr,ContactSuffix),
            Instruction.Create(OpCodes.Ldc_I4_4),Instruction.Create(OpCodes.Callvirt,endsWith),
            Instruction.Create(OpCodes.Brfalse,originalGate),
            bridgeStart,Instruction.Create(OpCodes.Brtrue,invokeStart),
            Instruction.Create(OpCodes.Ldstr,ResourceName),Instruction.Create(OpCodes.Call,load),
            Instruction.Create(OpCodes.Ldstr,"ScomGroundMarks.SourceTransform"),Instruction.Create(OpCodes.Ldc_I4_1),Instruction.Create(OpCodes.Callvirt,getType),
            Instruction.Create(OpCodes.Ldstr,"Transform"),Instruction.Create(OpCodes.Callvirt,getMethod),
            Instruction.Create(OpCodes.Stsfld,cachedMethod),invokeStart,
            Instruction.Create(OpCodes.Ldnull),Instruction.Create(OpCodes.Ldc_I4_2),Instruction.Create(OpCodes.Newarr,objectType),
            Instruction.Create(OpCodes.Dup),Instruction.Create(OpCodes.Ldc_I4_0),Instruction.Create(OpCodes.Ldarg_0),Instruction.Create(OpCodes.Stelem_Ref),
            Instruction.Create(OpCodes.Dup),Instruction.Create(OpCodes.Ldc_I4_1),Instruction.Create(OpCodes.Ldloc_0),Instruction.Create(OpCodes.Stelem_Ref),
            Instruction.Create(OpCodes.Callvirt,invoke),Instruction.Create(OpCodes.Castclass,bytesType),Instruction.Create(OpCodes.Ret)
        };
        var processor=method.Body.GetILProcessor();foreach(var instruction in prefix)processor.InsertBefore(originalGate,instruction);
        assembly.MainModule.Resources.Add(new EmbeddedResource(ResourceName,ManifestResourceAttributes.Private,File.ReadAllBytes(args[1])));
        assembly.Write(args[2]);
        using var before=AssemblyDefinition.ReadAssembly(args[0]);using var after=AssemblyDefinition.ReadAssembly(args[2]);
        var left=before.MainModule.GetTypes().SelectMany(t=>t.Methods).ToDictionary(m=>m.FullName,Fingerprint);
        var right=after.MainModule.GetTypes().SelectMany(t=>t.Methods).ToDictionary(m=>m.FullName,Fingerprint);
        var changed=left.Keys.Union(right.Keys).Where(k=>!left.ContainsKey(k)||!right.ContainsKey(k)||left[k]!=right[k]).ToArray();
        if(changed.Length!=1||changed[0]!=method.FullName)throw new InvalidDataException("Unexpected method change: "+string.Join(";",changed));
        if(after.MainModule.Resources.Count!=before.MainModule.Resources.Count+1)throw new InvalidDataException("Wrong resource count");
        for(int i=0;i<before.MainModule.Resources.Count;i++) {
            var a=before.MainModule.Resources[i];var b=after.MainModule.Resources[i];
            if(a.Name!=b.Name||a.Attributes!=b.Attributes||a.ResourceType!=b.ResourceType)throw new InvalidDataException("Resource metadata changed: "+a.Name);
            if(a is EmbeddedResource ea && (b is not EmbeddedResource eb||Hash(ea.GetResourceData())!=Hash(eb.GetResourceData())))throw new InvalidDataException("Resource payload changed: "+a.Name);
        }
        var resource=(EmbeddedResource)after.MainModule.Resources.Last();if(resource.Name!=ResourceName||Hash(resource.GetResourceData())!=Hash(File.ReadAllBytes(args[1])))throw new InvalidDataException("New payload mismatch");
        Console.WriteLine("PASS: added one cached MethodInfo field and changed only "+method.FullName+"; preserved "+(left.Count-1)+" other methods and all "+before.MainModule.Resources.Count+" existing resources.");
        Console.WriteLine("Output SHA256 "+Hash(File.ReadAllBytes(args[2])).ToLowerInvariant());
    }
}
