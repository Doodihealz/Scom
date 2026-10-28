using System;
using System.IO;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace ScomFatboyTracks;

public static class TrackHooks
{
	private static MethodInfo update;

	private static MethodInfo destroy;

	private static bool failed;

	private static MethodInfo metadataPredicate;

	public static void Install(AssemblyDefinition native)
	{
		if (native.MainModule.GetType().GetProperty("Mvid").GetValue(native.MainModule, null)
			.ToString() != "824eddf3-58d1-4a0a-824a-0153dcd374ee")
		{
			throw new InvalidOperationException("ground motion native MVID changed.");
		}
		using (AssemblyDefinition assemblyDefinition = AssemblyDefinition.ReadAssembly(Assembly.GetExecutingAssembly().Location))
		{
			TypeDefinition type = assemblyDefinition.MainModule.GetType("ScomFatboyTracks.TrackHooks");
			TypeDefinition type2 = native.MainModule.GetType("EM.Engine.Rendering.TxRenderSystem_SkinnedMeshRenderingSystem");
			MethodDefinition target = Method(type2, "ScheduleCounts");
			MethodDefinition target2 = Method(type2, "Dispose");
			Hook(native, target, Method(type, "Update"), postfix: false);
			Hook(native, target2, Method(type, "Destroy"), postfix: true);
		}
		using AssemblyDefinition assemblyDefinition2 = AssemblyDefinition.ReadAssembly(Assembly.GetExecutingAssembly().Location);
		InstallReadability(native, Method(assemblyDefinition2.MainModule.GetType("ScomFatboyTracks.TrackHooks"), "IsAnimatedMesh"));
	}

	private static void InstallReadability(AssemblyDefinition native, MethodDefinition predicate)
	{
		TypeDefinition typeDefinition = null;
		foreach (TypeDefinition nestedType in native.MainModule.GetType("EM.Gamedata.Data").NestedTypes)
		{
			if (nestedType.Name == "SanModel")
			{
				typeDefinition = nestedType;
			}
		}
		MethodDefinition methodDefinition = Method(typeDefinition, "GetMesh");
		FieldDefinition fieldDefinition = null;
		foreach (FieldDefinition field in typeDefinition.Fields)
		{
			if (field.Name == "name")
			{
				fieldDefinition = field;
			}
		}
		if (fieldDefinition == null)
		{
			throw new MissingFieldException("SanModel.name");
		}
		int num = 0;
		foreach (Instruction instruction in methodDefinition.Body.Instructions)
		{
			if (instruction.Operand is MethodReference methodReference && methodReference.FullName == predicate.FullName)
			{
				num++;
			}
		}
		switch (num)
		{
		case 1:
		{
			Collection<Instruction> instructions = methodDefinition.Body.Instructions;
			if (instructions.Count < 7 || instructions[0].OpCode != OpCodes.Ldarg_0 || instructions[1].OpCode != OpCodes.Ldfld || ((FieldReference)instructions[1].Operand).FullName != fieldDefinition.FullName || instructions[2].OpCode != OpCodes.Call || ((MethodReference)instructions[2].Operand).FullName != predicate.FullName || instructions[3].OpCode != OpCodes.Brfalse || instructions[3].Operand != instructions[6] || instructions[4].OpCode != OpCodes.Ldc_I4_0 || instructions[5].OpCode != OpCodes.Starg || instructions[5].Operand != methodDefinition.Parameters[0])
			{
				throw new InvalidOperationException("Existing ground-motion readability guard changed.");
			}
			break;
		}
		case 0:
			if (methodDefinition.Parameters.Count == 1 && !(methodDefinition.Parameters[0].ParameterType.FullName != "System.Boolean"))
			{
				ILProcessor iLProcessor = methodDefinition.Body.GetILProcessor();
				Instruction target = methodDefinition.Body.Instructions[0];
				iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Ldarg_0));
				iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Ldfld, fieldDefinition));
				iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Call, native.MainModule.ImportReference(predicate)));
				iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Brfalse, target));
				iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Ldc_I4_0));
				iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Starg, methodDefinition.Parameters[0]));
				methodDefinition.Body.MaxStackSize = Math.Max(methodDefinition.Body.MaxStackSize, 2);
				break;
			}
			goto default;
		default:
			throw new InvalidOperationException("Ground-motion readable mesh guard changed.");
		}
	}

	private static MethodDefinition Method(TypeDefinition owner, string name)
	{
		if (owner == null)
		{
			throw new MissingMemberException("Track hook owner missing.");
		}
		MethodDefinition methodDefinition = null;
		foreach (MethodDefinition method in owner.Methods)
		{
			if (method.Name == name)
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
			throw new MissingMethodException(owner.FullName, name);
		}
		return methodDefinition;
	}

	private static void Hook(AssemblyDefinition native, MethodDefinition target, MethodDefinition hook, bool postfix)
	{
		int num = 0;
		foreach (Instruction instruction2 in target.Body.Instructions)
		{
			if (instruction2.Operand is MethodReference methodReference && methodReference.FullName == hook.FullName)
			{
				num++;
			}
		}
		switch (num)
		{
		case 1:
			break;
		default:
			throw new InvalidOperationException("Duplicate ground motion hook.");
		case 0:
		{
			ILProcessor iLProcessor = target.Body.GetILProcessor();
			MethodReference method = native.MainModule.ImportReference(hook);
			if (postfix)
			{
				Instruction instruction = null;
				foreach (Instruction instruction3 in target.Body.Instructions)
				{
					if (instruction3.OpCode == OpCodes.Ret)
					{
						if (instruction != null)
						{
							throw new InvalidOperationException("Native destroy returns changed.");
						}
						instruction = instruction3;
					}
				}
				if (instruction == null)
				{
					throw new InvalidOperationException("Native destroy return missing.");
				}
				instruction.OpCode = OpCodes.Ldarg_0;
				iLProcessor.InsertAfter(instruction, iLProcessor.Create(OpCodes.Call, method));
				iLProcessor.InsertAfter(instruction.Next, iLProcessor.Create(OpCodes.Ret));
			}
			else
			{
				Instruction target2 = target.Body.Instructions[0];
				iLProcessor.InsertBefore(target2, iLProcessor.Create(OpCodes.Ldarg_0));
				iLProcessor.InsertBefore(target2, iLProcessor.Create(OpCodes.Call, method));
			}
			target.Body.MaxStackSize = Math.Max(target.Body.MaxStackSize, 1);
			break;
		}
		}
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
			update.Invoke(null, new object[1] { system });
		}
		catch (Exception ex)
		{
			failed = true;
			Console.Error.WriteLine("[SCOM ground motion] Runtime load/update failed: " + ex);
		}
	}

	public static void Destroy(object system)
	{
		try
		{
			if (destroy != null)
			{
				destroy.Invoke(null, new object[1] { system });
			}
		}
		catch (Exception ex)
		{
			Console.Error.WriteLine("[SCOM ground motion] Runtime cleanup failed: " + ex);
		}
	}

	public static bool IsAnimatedMesh(string name)
	{
		if (failed || name == null)
		{
			return false;
		}
		try
		{
			EnsureRuntime();
			return (bool)metadataPredicate.Invoke(null, new object[1] { name });
		}
		catch (Exception ex)
		{
			failed = true;
			Console.Error.WriteLine("[SCOM ground motion] Runtime metadata load failed: " + ex);
			return false;
		}
	}

	private static void EnsureRuntime()
	{
		lock (typeof(TrackHooks))
		{
			if (metadataPredicate != null)
			{
				return;
			}
			Assembly executingAssembly = Assembly.GetExecutingAssembly();
			byte[] array;
			using (Stream stream = executingAssembly.GetManifestResourceStream("ScomFatboyTracks.Runtime.dll"))
			{
				if (stream == null)
				{
					throw new FileNotFoundException("Embedded ground motion runtime missing.");
				}
				array = new byte[stream.Length];
				int num;
				for (int i = 0; i < array.Length; i += num)
				{
					num = stream.Read(array, i, array.Length - i);
					if (num == 0)
					{
						throw new EndOfStreamException();
					}
				}
			}
			Assembly assembly = Assembly.Load(array);
			Type type = assembly.GetType("ScomGroundMotion.GroundProfiles", throwOnError: true);
			type.GetMethod("Initialize").Invoke(null, new object[1] { Path.GetDirectoryName(executingAssembly.Location) });
			Type type2 = assembly.GetType("ScomFatboyTracks.TrackRuntime", throwOnError: true);
			update = type2.GetMethod("Update", BindingFlags.Static | BindingFlags.Public);
			destroy = type2.GetMethod("Destroy", BindingFlags.Static | BindingFlags.Public);
			metadataPredicate = type.GetMethod("IsAnimatedMesh", BindingFlags.Static | BindingFlags.Public);
			if (!(update == null) && !(destroy == null) && !(metadataPredicate == null))
			{
				return;
			}
			throw new MissingMethodException("Ground motion runtime ABI changed.");
		}
	}
}
