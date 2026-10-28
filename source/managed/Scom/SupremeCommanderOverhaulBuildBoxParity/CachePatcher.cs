using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace SupremeCommanderOverhaulBuildBoxParity;

public static class CachePatcher
{
	public const string SupportedGameMvid = "2cc1c6fa-e909-410e-8fd9-2f307b231dfb";

	public const string ScomApplyFullName = "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()";

	public const string GeneratorApplyFullName = "System.Void SupremeCommanderOverhaulGeneratorBuildability.CachePatcherRuntime::Apply()";

	public const string SeaParityApplyFullName = "System.Void SupremeCommanderOverhaulSeaParity.CachePatcherRuntime::Apply()";

	public const string SeraphimEcoApplyFullName = "System.Void SupremeCommanderOverhaulSeraphimEcoBuildUi.CachePatcherRuntime::Apply()";

	private const string OwnApplyFullName = "System.Void SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime::Apply()";

	public static void ValidateMvid(Guid mvid)
	{
		string text = mvid.ToString("D");
		if (!string.Equals(text, "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Unsupported Trebuchet.dll MVID " + text + "; expected 2cc1c6fa-e909-410e-8fd9-2f307b231dfb.");
		}
	}

	internal static void PatchStage(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		if (!string.Equals(assembly.MainModule.Mvid.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			LogSkip("unsupported Trebuchet.dll MVID " + assembly.MainModule.Mvid.ToString("D"));
			return;
		}
		TypeDefinition[] array = assembly.MainModule.Types.Where((TypeDefinition type) => type.FullName == "EM.Lua.FilesCache").ToArray();
		if (array.Length != 1)
		{
			LogSkip($"expected one EM.Lua.FilesCache type, found {array.Length}");
			return;
		}
		MethodDefinition[] array2 = array[0].Methods.Where((MethodDefinition methodDefinition2) => methodDefinition2.Name == "CreateFileCache" && methodDefinition2.IsStatic && methodDefinition2.Parameters.Count == 0).ToArray();
		if (array2.Length != 1 || !array2[0].HasBody)
		{
			LogSkip("CreateFileCache() is missing, ambiguous, or bodyless");
			return;
		}
		MethodDefinition methodDefinition = array2[0];
		Collection<Instruction> instructions = methodDefinition.Body.Instructions;
		Instruction[] array3 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime::Apply()");
		if (array3.Length > 1)
		{
			throw new InvalidOperationException($"Expected zero or one build-box parity callbacks, found {array3.Length}.");
		}
		Instruction[] array4 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()");
		Instruction[] array5 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulGeneratorBuildability.CachePatcherRuntime::Apply()");
		Instruction[] array6 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulSeaParity.CachePatcherRuntime::Apply()");
		Instruction[] array7 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulSeraphimEcoBuildUi.CachePatcherRuntime::Apply()");
		if (array4.Length != 1 || array5.Length != 1 || array6.Length != 1 || array7.Length != 1)
		{
			if (array3.Length != 0)
			{
				throw new InvalidOperationException("An installed build-box callback lost one of its required upstream callbacks.");
			}
			LogSkip($"expected one SCOM, generator, Sea Parity, and Seraphim eco callback; found {array4.Length}, {array5.Length}, {array6.Length}, and {array7.Length}");
			return;
		}
		Instruction item = array4[0];
		Instruction item2 = array5[0];
		Instruction item3 = array6[0];
		Instruction instruction = array7[0];
		if (instructions.IndexOf(item) >= instructions.IndexOf(item2) || instructions.IndexOf(item2) >= instructions.IndexOf(instruction) || instructions.IndexOf(item) >= instructions.IndexOf(item3) || instructions.IndexOf(item3) >= instructions.IndexOf(instruction))
		{
			if (array3.Length != 0)
			{
				throw new InvalidOperationException("The installed build-box callback's upstream order drifted.");
			}
			LogSkip("required upstream callbacks are out of order");
			return;
		}
		MethodInfo method = typeof(CachePatcherRuntime).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(CachePatcherRuntime).FullName, "Apply");
		MethodReference methodReference = assembly.MainModule.ImportReference(method);
		if (!string.Equals(methodReference.FullName, "System.Void SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime::Apply()", StringComparison.Ordinal))
		{
			throw new InvalidOperationException("Imported build-box callback identity drifted: " + methodReference.FullName);
		}
		if (array3.Length == 1)
		{
			if (array3[0].Previous != instruction)
			{
				throw new InvalidOperationException("Build-box parity callback is not immediately after Seraphim eco UI.");
			}
		}
		else
		{
			methodDefinition.Body.GetILProcessor().InsertAfter(instruction, Instruction.Create(OpCodes.Call, methodReference));
		}
	}

	private static Instruction[] CallsTo(IEnumerable<Instruction> instructions, string fullName)
	{
		return instructions.Where((Instruction instruction) => IsCallTo(instruction, fullName)).ToArray();
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

	private static void LogSkip(string reason)
	{
		try
		{
			Console.WriteLine("[SCOM FA Build-Box Parity] Preloader skipped: " + reason + ".");
		}
		catch
		{
		}
	}
}
