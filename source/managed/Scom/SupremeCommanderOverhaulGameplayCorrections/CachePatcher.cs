using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace SupremeCommanderOverhaulGameplayCorrections;

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

	private const string MainApplyFullName = "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()";

	private const string BuildBoxApplyFullName = "System.Void SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime::Apply()";

	private const string OwnApplyFullName = "System.Void SupremeCommanderOverhaulGameplayCorrections.CachePatcherRuntime::Apply()";

	private const string RebuildDirectoryIndexFullName = "System.Void EM.Lua.FilesCache::RebuildDirectoryIndex()";

	private const string WatcherDataGetterFullName = "EM.GameUtils.DebugManager/UnmanagedDebugProperties& EM.GameUtils.DebugManager::get_data()";

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
		if (!IsSupportedMvid(assembly.MainModule.Mvid))
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
			LogSkip("EM.Lua.FilesCache.CreateFileCache() is missing, ambiguous, or bodyless");
			return;
		}
		MethodDefinition methodDefinition = array2[0];
		Collection<Instruction> instructions = methodDefinition.Body.Instructions;
		Instruction[] array3 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulGameplayCorrections.CachePatcherRuntime::Apply()");
		if (array3.Length > 1)
		{
			throw new InvalidOperationException($"Expected zero or one gameplay-corrections callbacks, found {array3.Length}.");
		}
		Instruction[] array4 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()");
		Instruction[] array5 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime::Apply()");
		if (array4.Length != 1 || array5.Length != 1)
		{
			if (array3.Length != 0)
			{
				throw new InvalidOperationException("A gameplay-corrections callback exists without exact main and BuildBox callbacks.");
			}
			LogSkip($"expected one main and BuildBox callback, found {array4.Length} and {array5.Length}");
			return;
		}
		Instruction[] array6 = CallsTo(instructions, "System.Void EM.Lua.FilesCache::RebuildDirectoryIndex()");
		Instruction[] array7 = CallsTo(instructions, "EM.GameUtils.DebugManager/UnmanagedDebugProperties& EM.GameUtils.DebugManager::get_data()");
		Instruction[] array8 = instructions.Where((Instruction instruction3) => instruction3.OpCode == OpCodes.Ret).ToArray();
		if (array6.Length != 1 || array7.Length != 1 || array8.Length != 1)
		{
			if (array3.Length != 0)
			{
				throw new InvalidOperationException("A gameplay-corrections callback exists without exact cache/watcher anchors.");
			}
			LogSkip($"expected one rebuild, watcher, and return; found {array6.Length}, {array7.Length}, and {array8.Length}");
			return;
		}
		Instruction instruction = array7[0];
		if (!HasSupportedExceptionHandlerLayout(methodDefinition.Body, instructions, instruction))
		{
			if (array3.Length != 0)
			{
				throw new InvalidOperationException("A gameplay-corrections callback exists in an unsupported exception layout.");
			}
			LogSkip("CreateFileCache exception regions now reach its watcher anchor");
			return;
		}
		if (array3.Length == 1)
		{
			ValidateInstalledCall(instructions, array4[0], array5[0], array6[0], array3[0], instruction, array8[0]);
			return;
		}
		MethodInfo method = typeof(CachePatcherRuntime).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(CachePatcherRuntime).FullName, "Apply");
		MethodReference methodReference = assembly.MainModule.ImportReference(method);
		if (!string.Equals(methodReference.FullName, "System.Void SupremeCommanderOverhaulGameplayCorrections.CachePatcherRuntime::Apply()", StringComparison.Ordinal))
		{
			throw new InvalidOperationException("Imported gameplay-corrections callback identity drifted: " + methodReference.FullName);
		}
		Instruction instruction2 = Instruction.Create(OpCodes.Call, methodReference);
		methodDefinition.Body.GetILProcessor().InsertBefore(instruction, instruction2);
		ValidateInstalledCall(instructions, array4[0], array5[0], array6[0], instruction2, instruction, array8[0]);
	}

	private static void ValidateInstalledCall(IList<Instruction> instructions, Instruction mainCall, Instruction buildBoxCall, Instruction rebuildCall, Instruction ownCall, Instruction watcher, Instruction returnInstruction)
	{
		int ownIndex = instructions.IndexOf(ownCall);
		if (instructions.IndexOf(mainCall) >= ownIndex || instructions.IndexOf(buildBoxCall) >= ownIndex || instructions.IndexOf(rebuildCall) >= ownIndex)
		{
			throw new InvalidOperationException("The gameplay-corrections callback must run after main SCOM, BuildBox, and cache rebuild.");
		}
		int num = instructions.IndexOf(watcher);
		if (ownIndex >= num)
		{
			throw new InvalidOperationException("The gameplay-corrections callback does not precede the watcher branch.");
		}
		int num2 = ownIndex + 1;
		while (num2 < num)
		{
			Instruction instruction = instructions[num2];
			if (!(instruction.OpCode != OpCodes.Call) || !(instruction.OpCode != OpCodes.Callvirt))
			{
				object operand = instruction.Operand;
				MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
				if (methodReference != null && methodReference.FullName.EndsWith("CachePatcherRuntime::Apply()", StringComparison.Ordinal))
				{
					num2++;
					continue;
				}
			}
			throw new InvalidOperationException("Unexpected code exists between gameplay corrections and the watcher branch.");
		}
		BranchEdge[] source = EnumerateBranchEdges(instructions).ToArray();
		if (source.Any((BranchEdge edge) => instructions.IndexOf(edge.Source) < ownIndex && instructions.IndexOf(edge.Target) > ownIndex))
		{
			throw new InvalidOperationException("A CreateFileCache control-flow edge bypasses gameplay corrections.");
		}
		if (!source.Any((BranchEdge edge) => edge.Target == returnInstruction && instructions.IndexOf(edge.Source) > ownIndex))
		{
			throw new InvalidOperationException("The expected post-correction watcher early-return edge is unavailable.");
		}
	}

	private static Instruction[] CallsTo(IList<Instruction> instructions, string fullName)
	{
		return instructions.Where((Instruction instruction) => IsCallTo(instruction, fullName)).ToArray();
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

	private static bool HasSupportedExceptionHandlerLayout(Mono.Cecil.Cil.MethodBody body, IList<Instruction> instructions, Instruction insertionAnchor)
	{
		int num = instructions.IndexOf(insertionAnchor);
		foreach (ExceptionHandler exceptionHandler in body.ExceptionHandlers)
		{
			int num2 = instructions.IndexOf(exceptionHandler.TryStart);
			int num3 = instructions.IndexOf(exceptionHandler.TryEnd);
			int num4 = instructions.IndexOf(exceptionHandler.HandlerStart);
			int num5 = instructions.IndexOf(exceptionHandler.HandlerEnd);
			int num6 = ((exceptionHandler.FilterStart != null) ? instructions.IndexOf(exceptionHandler.FilterStart) : 0);
			if (num2 < 0 || num3 < 0 || num4 < 0 || num5 < 0 || num6 < 0 || num2 >= num3 || num4 >= num5 || num2 >= num || num3 >= num || num4 >= num || num5 >= num || num6 >= num)
			{
				return false;
			}
		}
		return true;
	}

	private static bool IsSupportedMvid(Guid mvid)
	{
		return string.Equals(mvid.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase);
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
			Console.WriteLine("[SCOM Gameplay Corrections] Preloader skipped: " + reason + ".");
		}
		catch
		{
		}
	}
}
