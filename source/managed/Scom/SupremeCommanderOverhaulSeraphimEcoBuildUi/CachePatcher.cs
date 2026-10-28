using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace SupremeCommanderOverhaulSeraphimEcoBuildUi;

internal static class CachePatcher
{
	public const string SupportedGameMvid = "2cc1c6fa-e909-410e-8fd9-2f307b231dfb";

	public const string ScomApplyFullName = "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()";

	public const string GeneratorApplyFullName = "System.Void SupremeCommanderOverhaulGeneratorBuildability.CachePatcherRuntime::Apply()";

	internal static IEnumerable<string> TargetDLLs
	{
		get
		{
			yield return "Trebuchet.dll";
		}
	}

	public static void ValidateMvid(Guid mvid)
	{
		string text = mvid.ToString("D");
		if (!string.Equals(text, "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Unsupported Trebuchet.dll MVID " + text + "; expected 2cc1c6fa-e909-410e-8fd9-2f307b231dfb.");
		}
	}

	internal static void Patch(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		ValidateMvid(assembly.MainModule.Mvid);
		MethodDefinition methodDefinition = assembly.MainModule.Types.Single((TypeDefinition type) => type.FullName == "EM.Lua.FilesCache").Methods.Single((MethodDefinition methodDefinition2) => methodDefinition2.Name == "CreateFileCache" && methodDefinition2.IsStatic && methodDefinition2.Parameters.Count == 0);
		if (!methodDefinition.HasBody)
		{
			throw new InvalidOperationException("EM.Lua.FilesCache.CreateFileCache() has no body.");
		}
		Collection<Instruction> instructions = methodDefinition.Body.Instructions;
		Instruction item = SingleCall(instructions, "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()", "SCOM");
		Instruction instruction = SingleCall(instructions, "System.Void SupremeCommanderOverhaulGeneratorBuildability.CachePatcherRuntime::Apply()", "generator-buildability");
		if (instructions.IndexOf(item) >= instructions.IndexOf(instruction))
		{
			throw new InvalidOperationException("SCOM cache callback must run before generator-buildability.");
		}
		MethodInfo method = typeof(CachePatcherRuntime).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(CachePatcherRuntime).FullName, "Apply");
		MethodReference applyReference = assembly.MainModule.ImportReference(method);
		Instruction[] array = instructions.Where((Instruction instruction2) => IsCallTo(instruction2, applyReference.FullName)).ToArray();
		if (array.Length == 1)
		{
			if (array[0].Previous != instruction)
			{
				throw new InvalidOperationException("Seraphim eco UI callback is not immediately after generator-buildability.");
			}
			return;
		}
		if (array.Length != 0)
		{
			throw new InvalidOperationException($"Expected zero or one Seraphim eco UI callbacks, found {array.Length}.");
		}
		methodDefinition.Body.GetILProcessor().InsertAfter(instruction, Instruction.Create(OpCodes.Call, applyReference));
	}

	private static Instruction SingleCall(IEnumerable<Instruction> instructions, string fullName, string description)
	{
		Instruction[] array = instructions.Where((Instruction instruction) => IsCallTo(instruction, fullName)).ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException($"Expected exactly one {description} cache callback, found {array.Length}.");
		}
		return array[0];
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
