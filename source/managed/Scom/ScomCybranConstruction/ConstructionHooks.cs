using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;

namespace ScomCybranConstruction;

public static class ConstructionHooks
{
	private static Action<object> update;

	private static Action<object> destroy;

	private static bool failed;

	private static Func<object, object> poolShader;

	private static bool poolFailed;

	private static Func<object, object> seraphimShader;

	private static bool seraphimFailed;

	private const string SeraphimBodyPrefix = "VFX/SCOM/FAConstruction/Bodies/";

	private const string PoolPath = "VFX/SCOM/FAConstruction/Aeon/Pool00.sanmaterial";

	public static void Install(AssemblyDefinition native)
	{
		if (native.MainModule.Mvid.ToString() != "824eddf3-58d1-4a0a-824a-0153dcd374ee")
		{
			throw new InvalidOperationException("Construction renderer native MVID changed.");
		}
		using AssemblyDefinition assemblyDefinition = AssemblyDefinition.ReadAssembly(Assembly.GetExecutingAssembly().Location);
		TypeDefinition type = assemblyDefinition.MainModule.GetType("ScomCybranConstruction.ConstructionHooks");
		TypeDefinition type2 = native.MainModule.GetType("EM.Engine.Rendering.TxRenderSystem_SkinnedMeshRenderingSystem");
		MethodDefinition methodDefinition = Method(type2, "ScheduleCounts");
		MethodDefinition methodDefinition2 = Method(type2, "Dispose");
		MethodDefinition methodDefinition3 = Method(type, "Update");
		MethodDefinition methodDefinition4 = Method(type, "Destroy");
		Instruction instruction = UniqueCall(methodDefinition, "System.Void ScomFatboyTracks.TrackHooks::Update(System.Object)");
		if (CountCalls(methodDefinition, methodDefinition3.FullName) == 0)
		{
			ILProcessor iLProcessor = methodDefinition.Body.GetILProcessor();
			Instruction instruction2 = iLProcessor.Create(OpCodes.Ldarg_0);
			iLProcessor.InsertAfter(instruction, instruction2);
			iLProcessor.InsertAfter(instruction2, iLProcessor.Create(OpCodes.Call, native.MainModule.ImportReference(methodDefinition3)));
		}
		Instruction instruction3 = UniqueCall(methodDefinition, methodDefinition3.FullName);
		if (instruction3.Previous == null || instruction3.Previous.OpCode != OpCodes.Ldarg_0 || instruction3.Previous.Previous != instruction)
		{
			throw new InvalidOperationException("Construction routing must immediately follow track routing.");
		}
		if (CountCalls(methodDefinition2, methodDefinition4.FullName) == 0)
		{
			Instruction instruction4 = methodDefinition2.Body.Instructions[methodDefinition2.Body.Instructions.Count - 1];
			if (instruction4.OpCode != OpCodes.Ret)
			{
				throw new InvalidOperationException("Native renderer Dispose return changed.");
			}
			instruction4.OpCode = OpCodes.Ldarg_0;
			ILProcessor iLProcessor2 = methodDefinition2.Body.GetILProcessor();
			iLProcessor2.Append(iLProcessor2.Create(OpCodes.Call, native.MainModule.ImportReference(methodDefinition4)));
			iLProcessor2.Append(iLProcessor2.Create(OpCodes.Ret));
		}
		Instruction instruction5 = UniqueCall(methodDefinition2, methodDefinition4.FullName);
		if (instruction5.Previous == null || instruction5.Previous.OpCode != OpCodes.Ldarg_0 || instruction5.Next == null || instruction5.Next.OpCode != OpCodes.Ret)
		{
			throw new InvalidOperationException("Construction cleanup placement changed.");
		}
		methodDefinition.Body.MaxStackSize = Math.Max(methodDefinition.Body.MaxStackSize, 1);
		methodDefinition2.Body.MaxStackSize = Math.Max(methodDefinition2.Body.MaxStackSize, 1);
		InstallPoolMaterialHook(native, type);
		InstallCommanderBlendHook(native);
	}

	private static void InstallCommanderBlendHook(AssemblyDefinition native)
	{
		MethodDefinition methodDefinition = Method(native.MainModule.GetType("EM.Gamedata.Data/SanMaterial"), "GetMaterial");
		MethodDefinition method = Method(native.MainModule.GetType("EM.Gamedata.Data/SanFileFormat"), "get_LoadedPath");
		Instruction instruction = UniqueCall(methodDefinition, "System.Boolean UnityEngine.Rendering.HighDefinition.HDMaterial::ValidateMaterial(UnityEngine.Material)");
		Instruction instruction2 = UniqueCall(methodDefinition, "System.Void EM.Gamedata.Data/SanFileFormat::SetNonReadable()");
		Instruction next = instruction.Next;
		Instruction previous = instruction2.Previous;
		FieldReference fieldReference = ((instruction.Previous == null) ? null : (instruction.Previous.Operand as FieldReference));
		if (next == null || next.OpCode != OpCodes.Pop || previous == null || previous.OpCode != OpCodes.Ldarg_0 || fieldReference == null || fieldReference.FullName != "UnityEngine.Material EM.Gamedata.Data/SanMaterial::mat" || instruction.Previous.OpCode != OpCodes.Ldfld || instruction.Previous.Previous.OpCode != OpCodes.Ldarg_0)
		{
			throw new InvalidOperationException("Commander inverse blend material validation anchor changed.");
		}
		MethodReference methodReference = null;
		int num = 0;
		int num2 = 0;
		foreach (Instruction instruction5 in methodDefinition.Body.Instructions)
		{
			if (instruction5.OpCode == OpCodes.Ldstr && (string)instruction5.Operand == "VFX/SCOM/Source/CommanderBrightness/524beeadb2ce57ca080d.sanmaterial")
			{
				num++;
			}
			if (instruction5.OpCode == OpCodes.Ldstr && (string)instruction5.Operand == "VFX/SCOM/Source/CommanderBrightness/a462b865b43eda0be943.sanmaterial")
			{
				num2++;
			}
			if (instruction5.Operand is MethodReference { FullName: "System.Void UnityEngine.Material::SetFloat(System.String,System.Single)" } methodReference2)
			{
				methodReference = methodReference2;
			}
		}
		if (methodReference == null || num != num2 || num > 1)
		{
			throw new InvalidOperationException("Commander inverse blend hook provenance changed.");
		}
		ILProcessor iLProcessor = methodDefinition.Body.GetILProcessor();
		MethodReference method2 = native.MainModule.ImportReference(typeof(string).GetMethod("Equals", new Type[3]
		{
			typeof(string),
			typeof(string),
			typeof(StringComparison)
		}));
		List<Instruction> list = new List<Instruction>();
		Instruction instruction3 = iLProcessor.Create(OpCodes.Ldarg_0);
		list.Add(iLProcessor.Create(OpCodes.Ldarg_0));
		list.Add(iLProcessor.Create(OpCodes.Call, native.MainModule.ImportReference(method)));
		list.Add(iLProcessor.Create(OpCodes.Ldstr, "VFX/SCOM/Source/CommanderBrightness/524beeadb2ce57ca080d.sanmaterial"));
		list.Add(iLProcessor.Create(OpCodes.Ldc_I4_4));
		list.Add(iLProcessor.Create(OpCodes.Call, method2));
		list.Add(iLProcessor.Create(OpCodes.Brtrue, instruction3));
		list.Add(iLProcessor.Create(OpCodes.Ldarg_0));
		list.Add(iLProcessor.Create(OpCodes.Call, native.MainModule.ImportReference(method)));
		list.Add(iLProcessor.Create(OpCodes.Ldstr, "VFX/SCOM/Source/CommanderBrightness/a462b865b43eda0be943.sanmaterial"));
		list.Add(iLProcessor.Create(OpCodes.Ldc_I4_4));
		list.Add(iLProcessor.Create(OpCodes.Call, method2));
		list.Add(iLProcessor.Create(OpCodes.Brfalse, previous));
		string[] array = new string[5] { "_BlendMode", "_SrcBlend", "_DstBlend", "_AlphaSrcBlend", "_AlphaDstBlend" };
		for (int i = 0; i < array.Length; i++)
		{
			list.Add((i == 0) ? instruction3 : iLProcessor.Create(OpCodes.Ldarg_0));
			list.Add(iLProcessor.Create(OpCodes.Ldfld, native.MainModule.ImportReference(fieldReference)));
			list.Add(iLProcessor.Create(OpCodes.Ldstr, array[i]));
			OpCode ldc_R = OpCodes.Ldc_R4;
			float value;
			switch (i)
			{
			default:
				value = 0f;
				break;
			case 2:
			case 4:
				value = 6f;
				break;
			case 0:
				value = 1f;
				break;
			}
			list.Add(iLProcessor.Create(ldc_R, value));
			list.Add(iLProcessor.Create(OpCodes.Callvirt, native.MainModule.ImportReference(methodReference)));
		}
		if (num == 0)
		{
			if (next.Next != previous)
			{
				throw new InvalidOperationException("Commander inverse blend insertion point changed.");
			}
			Instruction target = next;
			foreach (Instruction item in list)
			{
				iLProcessor.InsertAfter(target, item);
				target = item;
			}
		}
		List<Instruction> list2 = new List<Instruction>();
		Instruction next2 = next.Next;
		for (int j = 0; j < list.Count; j++)
		{
			if (next2 == null || next2 == previous)
			{
				throw new InvalidOperationException("Commander inverse blend hook was truncated.");
			}
			list2.Add(next2);
			next2 = next2.Next;
		}
		if (next2 != previous)
		{
			throw new InvalidOperationException("Commander inverse blend hook scope changed.");
		}
		for (int k = 0; k < list.Count; k++)
		{
			object operand = list[k].Operand;
			Instruction instruction4 = operand as Instruction;
			MemberReference memberReference = operand as MemberReference;
			bool flag;
			if (instruction4 == null)
			{
				flag = ((memberReference == null) ? object.Equals(list2[k].Operand, operand) : (list2[k].Operand is MemberReference memberReference2 && memberReference2.FullName == memberReference.FullName));
			}
			else
			{
				int num3 = list.IndexOf(instruction4);
				flag = list2[k].Operand == ((num3 < 0) ? previous : list2[num3]);
			}
			if (list2[k].OpCode != list[k].OpCode || !flag)
			{
				throw new InvalidOperationException("Commander inverse blend hook instruction changed.");
			}
		}
		methodDefinition.Body.MaxStackSize = Math.Max(methodDefinition.Body.MaxStackSize, 3);
	}

	private static void InstallPoolMaterialHook(AssemblyDefinition native, TypeDefinition hooks)
	{
		MethodDefinition methodDefinition = Method(native.MainModule.GetType("EM.Gamedata.Data/SanMaterial"), "GetMaterial");
		MethodDefinition methodDefinition2 = Method(hooks, "ResolvePoolShader");
		MethodDefinition methodDefinition3 = Method(native.MainModule.GetType("EM.Gamedata.Data/SanFileFormat"), "get_LoadedPath");
		Instruction instruction = null;
		foreach (Instruction instruction7 in methodDefinition.Body.Instructions)
		{
			MethodReference methodReference = instruction7.Operand as MethodReference;
			FieldReference fieldReference = ((instruction7.Previous == null) ? null : (instruction7.Previous.Operand as FieldReference));
			if (methodReference != null && !(methodReference.FullName != "UnityEngine.Shader UnityEngine.Shader::Find(System.String)") && fieldReference != null && !(fieldReference.FullName != "System.String EM.Gamedata.Data/SanMaterial::shader"))
			{
				if (instruction != null)
				{
					throw new InvalidOperationException("Duplicate declared material shader lookup.");
				}
				instruction = instruction7;
			}
		}
		if (instruction == null)
		{
			throw new InvalidOperationException("Declared material shader lookup changed.");
		}
		if (CountCalls(methodDefinition, methodDefinition2.FullName) == 0)
		{
			if (instruction.Next.OpCode != OpCodes.Stloc_0)
			{
				throw new InvalidOperationException("Material shader storage changed.");
			}
			ILProcessor iLProcessor = methodDefinition.Body.GetILProcessor();
			Instruction instruction2 = iLProcessor.Create(OpCodes.Ldarg_0);
			Instruction instruction3 = iLProcessor.Create(OpCodes.Call, native.MainModule.ImportReference(methodDefinition3));
			Instruction instruction4 = iLProcessor.Create(OpCodes.Call, native.MainModule.ImportReference(methodDefinition2));
			Instruction instruction5 = iLProcessor.Create(OpCodes.Castclass, ((MethodReference)instruction.Operand).ReturnType);
			iLProcessor.InsertAfter(instruction, instruction2);
			iLProcessor.InsertAfter(instruction2, instruction3);
			iLProcessor.InsertAfter(instruction3, instruction4);
			iLProcessor.InsertAfter(instruction4, instruction5);
		}
		Instruction instruction6 = UniqueCall(methodDefinition, methodDefinition2.FullName);
		if (instruction.Next.OpCode != OpCodes.Ldarg_0 || !(instruction.Next.Next.Operand is MethodReference) || ((MethodReference)instruction.Next.Next.Operand).FullName != methodDefinition3.FullName || instruction.Next.Next.Next != instruction6 || instruction6.Next.OpCode != OpCodes.Castclass || instruction6.Next.Next.OpCode != OpCodes.Stloc_0)
		{
			throw new InvalidOperationException("Aeon pool shader hook placement changed.");
		}
		methodDefinition.Body.MaxStackSize = Math.Max(methodDefinition.Body.MaxStackSize, 2);
	}

	public static object ResolvePoolShader(object fallback, string path)
	{
		if (IsSeraphimBodyPath(path))
		{
			if (seraphimFailed)
			{
				return fallback;
			}
			try
			{
				EnsureRuntime();
				return seraphimShader(fallback);
			}
			catch (Exception ex)
			{
				seraphimFailed = true;
				Console.Error.WriteLine("[SCOM Seraphim construction] Using native construction body: " + ex);
				return fallback;
			}
		}
		if (!string.Equals(path, "VFX/SCOM/FAConstruction/Aeon/Pool00.sanmaterial", StringComparison.Ordinal) || poolFailed)
		{
			return fallback;
		}
		try
		{
			EnsureRuntime();
			return poolShader(fallback);
		}
		catch (Exception ex2)
		{
			poolFailed = true;
			Console.Error.WriteLine("[SCOM Aeon construction] Using native silver pool: " + ex2);
			return fallback;
		}
	}

	private static bool IsSeraphimBodyPath(string path)
	{
		if (path == null || path.Length != "VFX/SCOM/FAConstruction/Bodies/".Length + 7 + ".sanmaterial".Length || !path.StartsWith("VFX/SCOM/FAConstruction/Bodies/", StringComparison.Ordinal) || !path.EndsWith(".sanmaterial", StringComparison.Ordinal))
		{
			return false;
		}
		int length = "VFX/SCOM/FAConstruction/Bodies/".Length;
		if (path[length] != 'u' || path[length + 1] != 's' || "alns".IndexOf(path[length + 2]) < 0)
		{
			return false;
		}
		for (int i = length + 3; i < length + 7; i++)
		{
			if (path[i] < '0' || path[i] > '9')
			{
				return false;
			}
		}
		return true;
	}

	private static MethodDefinition Method(TypeDefinition type, string name)
	{
		if (type == null)
		{
			throw new MissingMemberException(name);
		}
		MethodDefinition methodDefinition = null;
		foreach (MethodDefinition method in type.Methods)
		{
			if (!(method.Name != name))
			{
				if (methodDefinition != null)
				{
					throw new AmbiguousMatchException(name);
				}
				methodDefinition = method;
			}
		}
		if (methodDefinition == null || !methodDefinition.HasBody)
		{
			throw new MissingMethodException(type.FullName, name);
		}
		return methodDefinition;
	}

	private static int CountCalls(MethodDefinition method, string fullName)
	{
		int num = 0;
		foreach (Instruction instruction in method.Body.Instructions)
		{
			if (instruction.Operand is MethodReference methodReference && methodReference.FullName == fullName)
			{
				num++;
			}
		}
		return num;
	}

	private static Instruction UniqueCall(MethodDefinition method, string fullName)
	{
		if (CountCalls(method, fullName) != 1)
		{
			throw new InvalidOperationException("Expected one native hook: " + fullName);
		}
		foreach (Instruction instruction in method.Body.Instructions)
		{
			if (instruction.Operand is MethodReference methodReference && methodReference.FullName == fullName)
			{
				return instruction;
			}
		}
		throw new InvalidOperationException(fullName);
	}

	public static void Update(object system)
	{
		if (failed)
		{
			return;
		}
		try
		{
			EnsureRuntime();
			update(system);
		}
		catch (Exception ex)
		{
			failed = true;
			Console.Error.WriteLine("[SCOM Cybran construction] Runtime load failed: " + ex);
		}
	}

	private static void EnsureRuntime()
	{
		if (update == null)
		{
			Assembly executingAssembly = Assembly.GetExecutingAssembly();
			Type type = Assembly.Load(ReadResource(executingAssembly, "ScomCybranConstruction.Runtime.dll")).GetType("ScomCybranConstruction.ConstructionRuntime", throwOnError: true);
			((Action<byte[]>)Delegate.CreateDelegate(typeof(Action<byte[]>), type.GetMethod("Initialize")))(ReadResource(executingAssembly, "ScomCybranConstruction.Shader.bundle"));
			poolShader = (Func<object, object>)Delegate.CreateDelegate(typeof(Func<object, object>), type.GetMethod("ResolvePoolShader"));
			seraphimShader = (Func<object, object>)Delegate.CreateDelegate(typeof(Func<object, object>), type.GetMethod("ResolveSeraphimShader"));
			destroy = (Action<object>)Delegate.CreateDelegate(typeof(Action<object>), type.GetMethod("Destroy"));
			update = (Action<object>)Delegate.CreateDelegate(typeof(Action<object>), type.GetMethod("Update"));
		}
	}

	private static byte[] ReadResource(Assembly owner, string name)
	{
		using Stream stream = owner.GetManifestResourceStream(name);
		if (stream == null)
		{
			throw new FileNotFoundException(name);
		}
		byte[] array = new byte[stream.Length];
		int num;
		for (int i = 0; i < array.Length; i += num)
		{
			num = stream.Read(array, i, array.Length - i);
			if (num == 0)
			{
				throw new EndOfStreamException(name);
			}
		}
		return array;
	}

	public static void Destroy(object system)
	{
		try
		{
			if (destroy != null)
			{
				destroy(system);
			}
		}
		catch (Exception ex)
		{
			Console.Error.WriteLine("[SCOM Cybran construction] Runtime cleanup failed: " + ex);
		}
	}
}
