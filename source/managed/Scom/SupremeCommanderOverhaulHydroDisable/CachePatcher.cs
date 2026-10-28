using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace SupremeCommanderOverhaulHydroDisable;

internal static class CachePatcher
{
	public const string SupportedGameMvid = "2cc1c6fa-e909-410e-8fd9-2f307b231dfb";

	private const string UpgradeApplyFullName = "System.Void SupremeCommanderOverhaulUpgradeAnimationFix.CachePatcherRuntime::Apply()";

	private const string ScomApplyFullName = "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()";

	private const string RebuildFullName = "System.Void EM.Lua.FilesCache::RebuildDirectoryIndex()";

	private const string OwnApplyFullName = "System.Void SupremeCommanderOverhaulHydroDisable.CachePatcherRuntime::Apply()";

	private const string WatcherGetterFullName = "EM.GameUtils.DebugManager/UnmanagedDebugProperties& EM.GameUtils.DebugManager::get_data()";

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
		if (!string.Equals(assembly.MainModule.Mvid.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			LogSkip("unsupported Trebuchet.dll MVID " + assembly.MainModule.Mvid.ToString("D"));
			return;
		}
		MethodDefinition[] array = (from methodDefinition2 in assembly.MainModule.Types.Where((TypeDefinition type) => type.FullName == "EM.Lua.FilesCache").SelectMany((TypeDefinition type) => type.Methods)
			where methodDefinition2.Name == "CreateFileCache" && methodDefinition2.IsStatic && methodDefinition2.Parameters.Count == 0 && methodDefinition2.HasBody
			select methodDefinition2).ToArray();
		if (array.Length != 1)
		{
			LogSkip($"expected one EM.Lua.FilesCache.CreateFileCache(), found {array.Length}");
			return;
		}
		MethodDefinition methodDefinition = array[0];
		Collection<Instruction> instructions = methodDefinition.Body.Instructions;
		Instruction[] array2 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulHydroDisable.CachePatcherRuntime::Apply()");
		if (array2.Length > 1)
		{
			throw new InvalidOperationException($"Expected zero or one hydro-disable callback, found {array2.Length}.");
		}
		Instruction[] array3 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulUpgradeAnimationFix.CachePatcherRuntime::Apply()");
		Instruction[] array4 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()");
		Instruction[] array5 = CallsTo(instructions, "System.Void EM.Lua.FilesCache::RebuildDirectoryIndex()");
		Instruction[] array6 = CallsTo(instructions, "EM.GameUtils.DebugManager/UnmanagedDebugProperties& EM.GameUtils.DebugManager::get_data()");
		if (array3.Length > 1 || array4.Length != 1 || array5.Length != 1 || array6.Length != 1)
		{
			if (array2.Length != 0)
			{
				throw new InvalidOperationException("An installed hydro-disable callback lost its exact cache/watcher anchors.");
			}
			LogSkip("the main cache callback, rebuild, optional upgrade, or watcher layout drifted");
			return;
		}
		if (!HasSupportedExceptionHandlerLayout(methodDefinition, array6[0]))
		{
			if (array2.Length != 0)
			{
				throw new InvalidOperationException("An installed hydro-disable callback entered an unsupported exception region.");
			}
			LogSkip("CreateFileCache exception regions reach the watcher anchor");
			return;
		}
		if (array2.Length == 1)
		{
			ValidateInstalledCall(methodDefinition, array4[0], array5[0], (IReadOnlyCollection<Instruction>)(object)array3, array2[0], array6[0]);
			return;
		}
		MethodInfo method = typeof(CachePatcherRuntime).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(CachePatcherRuntime).FullName, "Apply");
		MethodReference methodReference = assembly.MainModule.ImportReference(method);
		if (!string.Equals(methodReference.FullName, "System.Void SupremeCommanderOverhaulHydroDisable.CachePatcherRuntime::Apply()", StringComparison.Ordinal))
		{
			throw new InvalidOperationException("Imported hydro-disable callback identity drifted: " + methodReference.FullName);
		}
		Instruction instruction = Instruction.Create(OpCodes.Call, methodReference);
		methodDefinition.Body.GetILProcessor().InsertBefore(array6[0], instruction);
		ValidateInstalledCall(methodDefinition, array4[0], array5[0], (IReadOnlyCollection<Instruction>)(object)array3, instruction, array6[0]);
	}

	private static void ValidateInstalledCall(MethodDefinition method, Instruction scom, Instruction rebuild, IReadOnlyCollection<Instruction> upgrades, Instruction own, Instruction watcher)
	{
		Collection<Instruction> instructions = method.Body.Instructions;
		int ownIndex = instructions.IndexOf(own);
		if (own.Next != watcher || instructions.IndexOf(scom) >= ownIndex || instructions.IndexOf(rebuild) >= ownIndex || upgrades.Any((Instruction upgrade) => instructions.IndexOf(upgrade) >= ownIndex))
		{
			throw new InvalidOperationException("Hydro disable must run after cache producers and immediately before the watcher.");
		}
		IEnumerator<Instruction> enumerator = instructions.GetEnumerator();
		try
		{
			while (enumerator.MoveNext())
			{
				Instruction current = enumerator.Current;
				foreach (Instruction item in BranchTargets(current))
				{
					if (instructions.IndexOf(current) < ownIndex && instructions.IndexOf(item) > ownIndex)
					{
						throw new InvalidOperationException("A CreateFileCache control-flow edge bypasses hydro disable.");
					}
				}
			}
		}
		finally
		{
			enumerator.Dispose();
		}
	}

	private static bool HasSupportedExceptionHandlerLayout(MethodDefinition method, Instruction watcher)
	{
		Collection<Instruction> instructions = method.Body.Instructions;
		int watcherIndex = instructions.IndexOf(watcher);
		IEnumerator<ExceptionHandler> enumerator = method.Body.ExceptionHandlers.GetEnumerator();
		try
		{
			while (enumerator.MoveNext())
			{
				ExceptionHandler current = enumerator.Current;
				if (new Instruction[5] { current.TryStart, current.TryEnd, current.HandlerStart, current.HandlerEnd, current.FilterStart }.Where((Instruction item) => item != null).Cast<Instruction>().Any((Instruction item) => instructions.IndexOf(item) >= watcherIndex))
				{
					return false;
				}
			}
		}
		finally
		{
			enumerator.Dispose();
		}
		return true;
	}

	private static Instruction[] CallsTo(IEnumerable<Instruction> instructions, string fullName)
	{
		return instructions.Where((Instruction instruction) => IsCallTo(instruction, fullName)).ToArray();
	}

	private static IEnumerable<Instruction> BranchTargets(Instruction instruction)
	{
		object operand = instruction.Operand;
		Instruction instruction2 = (Instruction)((operand is Instruction) ? operand : null);
		if (instruction2 != null)
		{
			yield return instruction2;
		}
		else if (instruction.Operand is Instruction[] array)
		{
			Instruction[] array2 = array;
			for (int i = 0; i < array2.Length; i++)
			{
				yield return array2[i];
			}
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

	private static void LogSkip(string reason)
	{
		try
		{
			Console.WriteLine("[SCOM Hydro Disable] Preloader skipped: " + reason + ".");
		}
		catch
		{
		}
	}
}
