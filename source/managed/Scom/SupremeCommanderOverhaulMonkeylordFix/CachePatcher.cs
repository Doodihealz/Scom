using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace SupremeCommanderOverhaulMonkeylordFix;

internal static class CachePatcher
{
	private const string SupportedGameMvid = "2cc1c6fa-e909-410e-8fd9-2f307b231dfb";

	private const string ScomApply = "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()";

	private const string OptionalWyvernApply = "System.Void WyvernBattlePackScomFirst.CachePatcherRuntime::Apply()";

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
			throw new InvalidOperationException("Unsupported Trebuchet.dll build.");
		}
		MethodDefinition methodDefinition = assembly.MainModule.Types.Single((TypeDefinition type) => type.FullName == "EM.Lua.FilesCache").Methods.Single((MethodDefinition methodDefinition2) => methodDefinition2.Name == "CreateFileCache" && methodDefinition2.Parameters.Count == 0);
		Collection<Instruction> instructions = methodDefinition.Body.Instructions;
		Instruction[] array = instructions.Where((Instruction i) => IsCallTo(i, "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()")).ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException($"Expected one SCOM Apply call, found {array.Length}.");
		}
		Instruction[] array2 = instructions.Where((Instruction i) => IsCallTo(i, "System.Void WyvernBattlePackScomFirst.CachePatcherRuntime::Apply()")).ToArray();
		if (array2.Length > 1)
		{
			throw new InvalidOperationException($"Expected at most one Wyvern Apply call, found {array2.Length}.");
		}
		MethodInfo method = typeof(CachePatcherRuntime).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException("Apply");
		MethodReference applyReference = assembly.MainModule.ImportReference(method);
		Instruction[] array3 = instructions.Where(delegate(Instruction i)
		{
			object operand = i.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			return methodReference != null && methodReference.FullName == applyReference.FullName;
		}).ToArray();
		Instruction instruction = ((array2.Length == 1) ? array2[0] : array[0]);
		if (array3.Length != 1 || array3[0].Previous != instruction)
		{
			if (array3.Length != 0)
			{
				throw new InvalidOperationException("Monkeylord fix Apply call exists at an unexpected IL location.");
			}
			methodDefinition.Body.GetILProcessor().InsertAfter(instruction, Instruction.Create(OpCodes.Call, applyReference));
		}
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
