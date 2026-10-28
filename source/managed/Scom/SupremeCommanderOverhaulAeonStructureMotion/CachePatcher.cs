using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace SupremeCommanderOverhaulAeonStructureMotion;

public static class CachePatcher
{
	private sealed class BranchEdge
	{
		public Instruction Source { get; }

		public Instruction Target { get; }

		public BranchEdge(Instruction source, Instruction target)
		{
			Source = source;
			Target = target;
		}
	}

	public const string SupportedGameMvid = "2cc1c6fa-e909-410e-8fd9-2f307b231dfb";

	public const string MainApply = "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()";

	public const string BuildBoxApply = "System.Void SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime::Apply()";

	public const string IdleApply = "System.Void SupremeCommanderOverhaulIdleReset.CachePatcherRuntime::Apply()";

	public const string UpgradeApply = "System.Void SupremeCommanderOverhaulUpgradeAnimationFix.CachePatcherRuntime::Apply()";

	public const string HydroApply = "System.Void SupremeCommanderOverhaulHydroDisable.CachePatcherRuntime::Apply()";

	public const string GameplayApply = "System.Void SupremeCommanderOverhaulGameplayCorrections.CachePatcherRuntime::Apply()";

	public const string RebuildApply = "System.Void EM.Lua.FilesCache::RebuildDirectoryIndex()";

	public const string WatcherGetter = "EM.GameUtils.DebugManager/UnmanagedDebugProperties& EM.GameUtils.DebugManager::get_data()";

	public const string OwnApply = "System.Void SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime::Apply()";

	public const string OwnStorageInstall = "System.Void SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime::InstallEmbeddedStorageAssets()";

	public const string SetGamedataInitialized = "System.Void EM.Gamedata.Data::set_IsGamedataInitialized(System.Boolean)";

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
		MethodDefinition[] array2 = array[0].Methods.Where((MethodDefinition methodDefinition3) => methodDefinition3.Name == "CreateFileCache" && methodDefinition3.IsStatic && methodDefinition3.Parameters.Count == 0).ToArray();
		if (array2.Length != 1 || !array2[0].HasBody)
		{
			LogSkip("CreateFileCache() is missing, ambiguous, or bodyless");
			return;
		}
		MethodDefinition methodDefinition = array2[0];
		Collection<Instruction> instructions = methodDefinition.Body.Instructions;
		Instruction[] array3 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime::Apply()");
		if (array3.Length > 1)
		{
			throw new InvalidOperationException($"Expected zero or one Aeon structure-motion callbacks, found {array3.Length}.");
		}
		TypeDefinition[] array4 = assembly.MainModule.Types.Where((TypeDefinition type) => type.FullName == "EM.Gamedata.Data").ToArray();
		if (array4.Length != 1)
		{
			if (array3.Length != 0)
			{
				throw new InvalidOperationException("An installed Aeon structure-motion callback lost EM.Gamedata.Data.");
			}
			LogSkip($"expected one EM.Gamedata.Data type, found {array4.Length}");
			return;
		}
		MethodDefinition[] array5 = array4[0].Methods.Where((MethodDefinition methodDefinition3) => methodDefinition3.Name == "InitAssets" && methodDefinition3.IsStatic && methodDefinition3.Parameters.Count == 0).ToArray();
		if (array5.Length != 1 || !array5[0].HasBody)
		{
			if (array3.Length != 0)
			{
				throw new InvalidOperationException("An installed Aeon structure-motion callback lost Data.InitAssets().");
			}
			LogSkip("Data.InitAssets() is missing, ambiguous, or bodyless");
			return;
		}
		MethodDefinition methodDefinition2 = array5[0];
		Collection<Instruction> instructions2 = methodDefinition2.Body.Instructions;
		Instruction[] array6 = CallsTo(instructions2, "System.Void SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime::InstallEmbeddedStorageAssets()");
		if (array6.Length > 1)
		{
			throw new InvalidOperationException($"Expected zero or one embedded-storage callbacks, found {array6.Length}.");
		}
		if (array3.Length == 0 != (array6.Length == 0))
		{
			throw new InvalidOperationException("A partial Aeon structure-motion Cecil installation was found.");
		}
		Dictionary<string, Instruction[]> dictionary = new string[7] { "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulIdleReset.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulUpgradeAnimationFix.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulHydroDisable.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulGameplayCorrections.CachePatcherRuntime::Apply()", "System.Void EM.Lua.FilesCache::RebuildDirectoryIndex()" }.ToDictionary<string, string, Instruction[]>((string name) => name, (string name) => CallsTo(instructions, name), StringComparer.Ordinal);
		if (dictionary.Any<KeyValuePair<string, Instruction[]>>((KeyValuePair<string, Instruction[]> pair) => pair.Value.Length != 1))
		{
			if (array3.Length != 0 || array6.Length != 0)
			{
				throw new InvalidOperationException("An installed Aeon structure-motion callback lost a required predecessor.");
			}
			LogSkip("one or more exact late-cache predecessors are absent or ambiguous");
			return;
		}
		Instruction[] array7 = CallsTo(instructions, "EM.GameUtils.DebugManager/UnmanagedDebugProperties& EM.GameUtils.DebugManager::get_data()");
		Instruction[] array8 = instructions.Where((Instruction instruction3) => instruction3.OpCode == OpCodes.Ret).ToArray();
		if (array7.Length != 1 || array8.Length != 1)
		{
			if (array3.Length != 0)
			{
				throw new InvalidOperationException("An installed Aeon structure-motion callback lost its watcher/return anchors.");
			}
			LogSkip("the watcher or return anchor is absent or ambiguous");
			return;
		}
		if (!HasSupportedExceptionLayout(methodDefinition.Body, instructions, array7[0]))
		{
			if (array3.Length != 0)
			{
				throw new InvalidOperationException("An installed Aeon structure-motion callback entered an unsupported exception region.");
			}
			LogSkip("CreateFileCache exception regions reach the late watcher anchor");
			return;
		}
		Instruction[] array9 = CallsTo(instructions2, "System.Void EM.Gamedata.Data::set_IsGamedataInitialized(System.Boolean)");
		if (array9.Length != 1 || array9[0].Previous == null || array9[0].Previous.OpCode != OpCodes.Ldc_I4_1 || array9[0].Next == null || array9[0].Next.OpCode != OpCodes.Ret)
		{
			if (array6.Length != 0)
			{
				throw new InvalidOperationException("The installed embedded-storage callback lost its InitAssets completion anchor.");
			}
			LogSkip("Data.InitAssets() completion anchor is absent or ambiguous");
			return;
		}
		Instruction initializedTrue = array9[0].Previous;
		if (EnumerateBranchEdges(instructions2).Any((BranchEdge edge) => edge.Target == initializedTrue) || !HasSupportedExceptionLayout(methodDefinition2.Body, instructions2, initializedTrue))
		{
			if (array6.Length != 0)
			{
				throw new InvalidOperationException("The installed embedded-storage callback entered an unsupported InitAssets control-flow region.");
			}
			LogSkip("Data.InitAssets completion can be bypassed or is inside an exception region");
			return;
		}
		MethodReference method = null;
		MethodReference method2 = null;
		if (array3.Length == 0)
		{
			method = ImportRuntimeMethod(assembly.MainModule, "Apply", "System.Void SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime::Apply()");
			method2 = ImportRuntimeMethod(assembly.MainModule, "InstallEmbeddedStorageAssets", "System.Void SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime::InstallEmbeddedStorageAssets()");
		}
		if (array3.Length == 0)
		{
			Instruction instruction = Instruction.Create(OpCodes.Call, method);
			methodDefinition.Body.GetILProcessor().InsertBefore(array7[0], instruction);
			array3 = new Instruction[1] { instruction };
			Instruction instruction2 = Instruction.Create(OpCodes.Call, method2);
			methodDefinition2.Body.GetILProcessor().InsertBefore(initializedTrue, instruction2);
			array6 = new Instruction[1] { instruction2 };
		}
		ValidateInstalledCall(instructions, dictionary, array3[0], array7[0], array8[0]);
		ValidateInstalledStorageCall(instructions2, array6[0], initializedTrue, array9[0]);
	}

	private static MethodReference ImportRuntimeMethod(ModuleDefinition module, string methodName, string expectedFullName)
	{
		MethodInfo method = typeof(CachePatcherRuntime).GetMethod(methodName, BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(CachePatcherRuntime).FullName, methodName);
		MethodReference methodReference = module.ImportReference(method);
		if (!string.Equals(methodReference.FullName, expectedFullName, StringComparison.Ordinal))
		{
			throw new InvalidOperationException("Imported Aeon structure-motion callback identity drifted: " + methodReference.FullName);
		}
		return methodReference;
	}

	private static void ValidateInstalledCall(IList<Instruction> instructions, IReadOnlyDictionary<string, Instruction[]> predecessors, Instruction own, Instruction watcher, Instruction returnInstruction)
	{
		int ownIndex = instructions.IndexOf(own);
		foreach (KeyValuePair<string, Instruction[]> predecessor in predecessors)
		{
			if (instructions.IndexOf(predecessor.Value[0]) >= ownIndex)
			{
				throw new InvalidOperationException("Aeon structure motion precedes required callback: " + predecessor.Key);
			}
		}
		Instruction instruction = predecessors["System.Void SupremeCommanderOverhaulGameplayCorrections.CachePatcherRuntime::Apply()"][0];
		if (own.Previous != instruction || own.Next != watcher)
		{
			throw new InvalidOperationException("Aeon structure motion must be the sole final callback between GameplayCorrections and the watcher.");
		}
		foreach (BranchEdge item in EnumerateBranchEdges(instructions))
		{
			if (instructions.IndexOf(item.Source) < ownIndex && instructions.IndexOf(item.Target) > ownIndex)
			{
				throw new InvalidOperationException("A CreateFileCache control-flow edge bypasses Aeon structure motion.");
			}
		}
		if (!EnumerateBranchEdges(instructions).Any((BranchEdge edge) => edge.Target == returnInstruction && instructions.IndexOf(edge.Source) > ownIndex))
		{
			throw new InvalidOperationException("The expected post-motion watcher early-return edge is unavailable.");
		}
	}

	private static void ValidateInstalledStorageCall(IList<Instruction> instructions, Instruction own, Instruction initializedTrue, Instruction initializedSetter)
	{
		if (own.Next != initializedTrue || initializedTrue.Next != initializedSetter || initializedSetter.Next == null || initializedSetter.Next.OpCode != OpCodes.Ret)
		{
			throw new InvalidOperationException("Embedded storage installation must be the sole final InitAssets callback before initialization commits.");
		}
		int num = instructions.IndexOf(own);
		foreach (BranchEdge item in EnumerateBranchEdges(instructions))
		{
			if (instructions.IndexOf(item.Source) < num && instructions.IndexOf(item.Target) > num)
			{
				throw new InvalidOperationException("A Data.InitAssets control-flow edge bypasses embedded storage installation.");
			}
		}
	}

	private static Instruction[] CallsTo(IEnumerable<Instruction> instructions, string fullName)
	{
		return instructions.Where(delegate(Instruction instruction)
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
		}).ToArray();
	}

	private static IEnumerable<BranchEdge> EnumerateBranchEdges(IEnumerable<Instruction> instructions)
	{
		foreach (Instruction instruction in instructions)
		{
			object operand = instruction.Operand;
			Instruction instruction2 = (Instruction)((operand is Instruction) ? operand : null);
			if (instruction2 != null)
			{
				yield return new BranchEdge(instruction, instruction2);
			}
			else if (instruction.Operand is Instruction[] array)
			{
				Instruction[] array2 = array;
				Instruction[] array3 = array2;
				foreach (Instruction target in array3)
				{
					yield return new BranchEdge(instruction, target);
				}
			}
		}
	}

	private static bool HasSupportedExceptionLayout(Mono.Cecil.Cil.MethodBody body, IList<Instruction> instructions, Instruction anchor)
	{
		int anchorIndex = instructions.IndexOf(anchor);
		foreach (ExceptionHandler exceptionHandler in body.ExceptionHandlers)
		{
			if (new Instruction[4] { exceptionHandler.TryStart, exceptionHandler.TryEnd, exceptionHandler.HandlerStart, exceptionHandler.HandlerEnd }.Any((Instruction point) => point == null || instructions.IndexOf(point) >= anchorIndex))
			{
				return false;
			}
			if (exceptionHandler.FilterStart != null && instructions.IndexOf(exceptionHandler.FilterStart) >= anchorIndex)
			{
				return false;
			}
		}
		return true;
	}

	private static void LogSkip(string reason)
	{
		try
		{
			Console.WriteLine("[SCOM Aeon Structure Motion] Preloader skipped: " + reason + ".");
		}
		catch
		{
		}
	}
}
