using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace SupremeCommanderOverhaulAudioCompat;

internal static class CachePatcher
{
	public const string SupportedGameMvid = "2cc1c6fa-e909-410e-8fd9-2f307b231dfb";

	public const string ScomApply = "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()";

	internal static IEnumerable<string> TargetDLLs
	{
		get
		{
			yield return "Trebuchet.dll";
		}
	}

	internal static void Patch(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		if (!string.Equals(assembly.MainModule.Mvid.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException(string.Format("Unsupported Trebuchet.dll MVID {0:D}; expected {1}.", assembly.MainModule.Mvid, "824eddf3-58d1-4a0a-824a-0153dcd374ee"));
		}
		MethodDefinition methodDefinition = assembly.MainModule.Types.Single((TypeDefinition type) => type.FullName == "EM.Lua.FilesCache").Methods.Single((MethodDefinition methodDefinition2) => methodDefinition2.Name == "CreateFileCache" && methodDefinition2.IsStatic && methodDefinition2.Parameters.Count == 0);
		if (!methodDefinition.HasBody)
		{
			throw new InvalidOperationException("EM.Lua.FilesCache.CreateFileCache() has no body.");
		}
		Collection<Instruction> instructions = methodDefinition.Body.Instructions;
		Instruction[] array = instructions.Where((Instruction i) => IsCallTo(i, "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()")).ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException($"Expected one SCOM Apply call, found {array.Length}.");
		}
		MethodInfo method = typeof(CachePatcherRuntime).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException("Apply");
		MethodReference callbackReference = assembly.MainModule.ImportReference(method);
		Instruction[] array2 = instructions.Where((Instruction i) => IsCallTo(i, callbackReference.FullName)).ToArray();
		if (array2.Length == 1)
		{
			if (instructions.IndexOf(array2[0]) <= instructions.IndexOf(array[0]))
			{
				throw new InvalidOperationException("Audio compatibility callback is not after SCOM.");
			}
			return;
		}
		if (array2.Length != 0)
		{
			throw new InvalidOperationException($"Expected zero or one audio compatibility calls, found {array2.Length}.");
		}
		methodDefinition.Body.GetILProcessor().InsertAfter(array[0], Instruction.Create(OpCodes.Call, callbackReference));
	}

	private static bool IsCallTo(Instruction instruction, string fullName)
	{
		if (instruction.OpCode == OpCodes.Call || instruction.OpCode == OpCodes.Callvirt)
		{
			object operand = instruction.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			if (methodReference != null)
			{
				return methodReference.FullName == fullName;
			}
		}
		return false;
	}
}
