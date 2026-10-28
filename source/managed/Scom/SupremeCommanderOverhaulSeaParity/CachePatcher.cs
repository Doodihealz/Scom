using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace SupremeCommanderOverhaulSeaParity;

public static class CachePatcher
{
	public const string SupportedTrebuchetMvid = "2cc1c6fa-e909-410e-8fd9-2f307b231dfb";

	public const string SupportedTrebuchetSha256 = "F876DAEBADAE43DE53DB1C92EE960A9313A59271208DDE05AC2236CB9FCCC3D3";

	public const long SupportedTrebuchetBytes = 3130368L;

	public const string ScomApplyFullName = "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()";

	public const string SalemGamedataInstallFullName = "System.Void SupremeCommanderOverhaulSeaParity.CachePatcherRuntime::InstallEmbeddedSalemAnimationAsset()";

	private const string SetGamedataInitializedFullName = "System.Void EM.Gamedata.Data::set_IsGamedataInitialized(System.Boolean)";

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
		ValidateMvid(assembly.MainModule.Mvid);
		MethodDefinition methodDefinition = assembly.MainModule.Types.Single((TypeDefinition type) => type.FullName == "EM.Lua.FilesCache").Methods.Single((MethodDefinition methodDefinition3) => methodDefinition3.Name == "CreateFileCache" && methodDefinition3.IsStatic && methodDefinition3.Parameters.Count == 0);
		if (!methodDefinition.HasBody)
		{
			throw new InvalidOperationException("EM.Lua.FilesCache.CreateFileCache() has no body.");
		}
		Collection<Instruction> instructions = methodDefinition.Body.Instructions;
		Instruction[] array = instructions.Where((Instruction instruction2) => IsCallTo(instruction2, "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()")).ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException($"Expected exactly one SCOM cache callback, found {array.Length}.");
		}
		MethodInfo method = typeof(CachePatcherRuntime).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(CachePatcherRuntime).FullName, "Apply");
		MethodReference applyReference = assembly.MainModule.ImportReference(method);
		Instruction[] array2 = instructions.Where((Instruction instruction2) => IsCallTo(instruction2, applyReference.FullName)).ToArray();
		if (array2.Length == 1)
		{
			if (array2[0].Previous != array[0])
			{
				throw new InvalidOperationException("Sea-parity callback is not immediately after SCOM.");
			}
		}
		else if (array2.Length != 0)
		{
			throw new InvalidOperationException($"Expected zero or one sea-parity callbacks, found {array2.Length}.");
		}
		MethodDefinition methodDefinition2 = assembly.MainModule.Types.Single((TypeDefinition type) => type.FullName == "EM.Gamedata.Data").Methods.Single((MethodDefinition methodDefinition3) => methodDefinition3.Name == "InitAssets" && methodDefinition3.IsStatic && methodDefinition3.Parameters.Count == 0);
		if (!methodDefinition2.HasBody)
		{
			throw new InvalidOperationException("EM.Gamedata.Data.InitAssets() has no body.");
		}
		Collection<Instruction> instructions2 = methodDefinition2.Body.Instructions;
		Instruction[] array3 = instructions2.Where((Instruction instruction2) => IsCallTo(instruction2, "System.Void SupremeCommanderOverhaulSeaParity.CachePatcherRuntime::InstallEmbeddedSalemAnimationAsset()")).ToArray();
		if (array3.Length > 1)
		{
			throw new InvalidOperationException($"Expected zero or one Salem gamedata callbacks, found {array3.Length}.");
		}
		Instruction[] array4 = instructions2.Where((Instruction instruction2) => IsCallTo(instruction2, "System.Void EM.Gamedata.Data::set_IsGamedataInitialized(System.Boolean)")).ToArray();
		if (array4.Length != 1 || array4[0].Previous == null || array4[0].Previous.OpCode != OpCodes.Ldc_I4_1 || array4[0].Next == null || array4[0].Next.OpCode != OpCodes.Ret)
		{
			throw new InvalidOperationException("EM.Gamedata.Data.InitAssets() completion anchor drifted.");
		}
		Instruction initializedTrue = array4[0].Previous;
		if (EnumerateBranchTargets(instructions2).Any((Instruction target) => target == initializedTrue) || !HasSupportedExceptionLayout(methodDefinition2.Body, instructions2, initializedTrue))
		{
			throw new InvalidOperationException("EM.Gamedata.Data.InitAssets() completion control flow drifted.");
		}
		if (array2.Length == 0)
		{
			methodDefinition.Body.GetILProcessor().InsertAfter(array[0], Instruction.Create(OpCodes.Call, applyReference));
		}
		if (array3.Length == 0)
		{
			MethodInfo method2 = typeof(CachePatcherRuntime).GetMethod("InstallEmbeddedSalemAnimationAsset", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(CachePatcherRuntime).FullName, "InstallEmbeddedSalemAnimationAsset");
			MethodReference methodReference = assembly.MainModule.ImportReference(method2);
			if (!string.Equals(methodReference.FullName, "System.Void SupremeCommanderOverhaulSeaParity.CachePatcherRuntime::InstallEmbeddedSalemAnimationAsset()", StringComparison.Ordinal))
			{
				throw new InvalidOperationException("Imported Salem gamedata callback identity drifted: " + methodReference.FullName);
			}
			Instruction instruction = Instruction.Create(OpCodes.Call, methodReference);
			methodDefinition2.Body.GetILProcessor().InsertBefore(initializedTrue, instruction);
			array3 = new Instruction[1] { instruction };
		}
		ValidateInstalledGamedataCall(instructions2, array3[0], initializedTrue, array4[0]);
	}

	private static void ValidateInstalledGamedataCall(IList<Instruction> instructions, Instruction installCall, Instruction initializedTrue, Instruction initializedSetter)
	{
		int num = instructions.IndexOf(installCall);
		int num2 = instructions.IndexOf(initializedTrue);
		if (num < 0 || num2 <= num || initializedTrue.Next != initializedSetter || initializedSetter.Next == null || initializedSetter.Next.OpCode != OpCodes.Ret)
		{
			throw new InvalidOperationException("Salem gamedata installation must run before gamedata initialization commits.");
		}
		foreach (Instruction instruction in instructions)
		{
			int num3 = instructions.IndexOf(instruction);
			foreach (Instruction item in EnumerateBranchTargets(new Instruction[1] { instruction }))
			{
				if (num3 < num && instructions.IndexOf(item) > num)
				{
					throw new InvalidOperationException("An EM.Gamedata.Data.InitAssets() control-flow edge bypasses Salem gamedata installation.");
				}
			}
		}
	}

	private static IEnumerable<Instruction> EnumerateBranchTargets(IEnumerable<Instruction> instructions)
	{
		foreach (Instruction instruction2 in instructions)
		{
			object operand = instruction2.Operand;
			Instruction instruction = (Instruction)((operand is Instruction) ? operand : null);
			if (instruction != null)
			{
				yield return instruction;
			}
			else if (instruction2.Operand is Instruction[] array)
			{
				Instruction[] array2 = array;
				for (int i = 0; i < array2.Length; i++)
				{
					yield return array2[i];
				}
			}
		}
	}

	private static bool HasSupportedExceptionLayout(Mono.Cecil.Cil.MethodBody body, IList<Instruction> instructions, Instruction anchor)
	{
		int anchorIndex = instructions.IndexOf(anchor);
		foreach (ExceptionHandler exceptionHandler in body.ExceptionHandlers)
		{
			if (new Instruction[4] { exceptionHandler.TryStart, exceptionHandler.TryEnd, exceptionHandler.HandlerStart, exceptionHandler.HandlerEnd }.Any((Instruction point) => point == null || instructions.IndexOf(point) >= anchorIndex) || (exceptionHandler.FilterStart != null && instructions.IndexOf(exceptionHandler.FilterStart) >= anchorIndex))
			{
				return false;
			}
		}
		return true;
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
