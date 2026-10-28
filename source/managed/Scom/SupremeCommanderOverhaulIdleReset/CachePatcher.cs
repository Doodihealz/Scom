using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace SupremeCommanderOverhaulIdleReset;

internal static class CachePatcher
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

	private const string ScomApplyFullName = "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()";

	private const string OwnApplyFullName = "System.Void SupremeCommanderOverhaulIdleReset.CachePatcherRuntime::Apply()";

	private const string RebuildDirectoryIndexFullName = "System.Void EM.Lua.FilesCache::RebuildDirectoryIndex()";

	private const string WatcherDataGetterFullName = "EM.GameUtils.DebugManager/UnmanagedDebugProperties& EM.GameUtils.DebugManager::get_data()";

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
		Instruction[] array3 = instructions.Where((Instruction instruction3) => IsCallTo(instruction3, "System.Void SupremeCommanderOverhaulIdleReset.CachePatcherRuntime::Apply()")).ToArray();
		if (array3.Length > 1)
		{
			throw new InvalidOperationException($"Expected zero or one idle-reset callbacks, found {array3.Length}.");
		}
		Instruction[] array4 = instructions.Where((Instruction instruction3) => IsCallTo(instruction3, "System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()")).ToArray();
		if (array4.Length != 1)
		{
			if (array3.Length != 0)
			{
				throw new InvalidOperationException("An idle-reset callback exists without one exact main SCOM callback.");
			}
			LogSkip($"expected one main SCOM cache callback, found {array4.Length}");
			return;
		}
		Instruction[] array5 = instructions.Where((Instruction instruction3) => instruction3.OpCode == OpCodes.Ret).ToArray();
		if (array5.Length != 1)
		{
			if (array3.Length != 0)
			{
				throw new InvalidOperationException($"An idle-reset callback exists with {array5.Length} returns.");
			}
			LogSkip($"expected one CreateFileCache return, found {array5.Length}");
			return;
		}
		Instruction[] array6 = instructions.Where((Instruction instruction3) => IsCallTo(instruction3, "System.Void EM.Lua.FilesCache::RebuildDirectoryIndex()")).ToArray();
		Instruction[] array7 = instructions.Where((Instruction instruction3) => IsCallTo(instruction3, "EM.GameUtils.DebugManager/UnmanagedDebugProperties& EM.GameUtils.DebugManager::get_data()")).ToArray();
		if (array6.Length != 1 || array7.Length != 1)
		{
			if (array3.Length != 0)
			{
				throw new InvalidOperationException("An idle-reset callback exists without one exact post-cache watcher anchor.");
			}
			LogSkip($"expected one cache rebuild and watcher anchor, found {array6.Length} and {array7.Length}");
			return;
		}
		Instruction instruction = array7[0];
		if (!HasSupportedExceptionHandlerLayout(methodDefinition.Body, instructions, instruction))
		{
			if (array3.Length != 0)
			{
				throw new InvalidOperationException("An idle-reset callback exists in an unsupported exception-handler layout.");
			}
			LogSkip("CreateFileCache exception regions now reach its watcher anchor");
			return;
		}
		if (array3.Length == 1)
		{
			ValidateInstalledCall(instructions, array4[0], array6[0], array3[0], instruction, array5[0]);
			return;
		}
		MethodInfo method = typeof(CachePatcherRuntime).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(CachePatcherRuntime).FullName, "Apply");
		MethodReference methodReference = assembly.MainModule.ImportReference(method);
		if (!string.Equals(methodReference.FullName, "System.Void SupremeCommanderOverhaulIdleReset.CachePatcherRuntime::Apply()", StringComparison.Ordinal))
		{
			throw new InvalidOperationException("Imported idle-reset callback identity drifted: " + methodReference.FullName);
		}
		Instruction instruction2 = Instruction.Create(OpCodes.Call, methodReference);
		methodDefinition.Body.GetILProcessor().InsertBefore(instruction, instruction2);
		ValidateInstalledCall(instructions, array4[0], array6[0], instruction2, instruction, array5[0]);
	}

	private static void ValidateInstalledCall(IList<Instruction> instructions, Instruction scomCall, Instruction rebuildCall, Instruction ownCall, Instruction watcherAnchor, Instruction returnInstruction)
	{
		int ownIndex = instructions.IndexOf(ownCall);
		if (instructions.IndexOf(scomCall) >= ownIndex)
		{
			throw new InvalidOperationException("The idle-reset callback must run after the main SCOM cache callback.");
		}
		if (instructions.IndexOf(rebuildCall) >= ownIndex)
		{
			throw new InvalidOperationException("The idle-reset callback must run after the cache directory is rebuilt.");
		}
		int num = instructions.IndexOf(watcherAnchor);
		if (ownIndex >= num)
		{
			throw new InvalidOperationException("The idle-reset callback does not precede the watcher branch.");
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
			throw new InvalidOperationException("Unexpected code exists between the idle-reset callback and watcher branch.");
		}
		BranchEdge[] source = EnumerateBranchEdges(instructions).ToArray();
		if (source.Any((BranchEdge edge) => instructions.IndexOf(edge.Source) < ownIndex && instructions.IndexOf(edge.Target) > ownIndex))
		{
			throw new InvalidOperationException("A CreateFileCache control-flow edge bypasses the idle-reset callback.");
		}
		if (!source.Any((BranchEdge edge) => edge.Target == returnInstruction && instructions.IndexOf(edge.Source) > ownIndex))
		{
			throw new InvalidOperationException("The expected post-idle watcher early-return edge is unavailable.");
		}
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
		IEnumerator<ExceptionHandler> enumerator = body.ExceptionHandlers.GetEnumerator();
		try
		{
			while (enumerator.MoveNext())
			{
				ExceptionHandler current = enumerator.Current;
				int num2 = instructions.IndexOf(current.TryStart);
				int num3 = instructions.IndexOf(current.TryEnd);
				int num4 = instructions.IndexOf(current.HandlerStart);
				int num5 = instructions.IndexOf(current.HandlerEnd);
				int num6 = ((current.FilterStart != null) ? instructions.IndexOf(current.FilterStart) : 0);
				if (num2 < 0 || num3 < 0 || num4 < 0 || num5 < 0 || num6 < 0 || num2 >= num3 || num4 >= num5 || num2 >= num || num3 >= num || num4 >= num || num5 >= num || num6 >= num)
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

	private static bool IsSupportedMvid(Guid mvid)
	{
		return string.Equals(mvid.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase);
	}

	private static void LogSkip(string reason)
	{
		try
		{
			Console.WriteLine("[SCOM Idle Reset] Preloader skipped: " + reason + ".");
		}
		catch
		{
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
