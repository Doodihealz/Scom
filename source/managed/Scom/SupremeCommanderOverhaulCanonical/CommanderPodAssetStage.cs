using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using CommanderEnhancementsCachePatcher;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;

namespace SupremeCommanderOverhaulCanonical;

internal static class CommanderPodAssetStage
{
	internal const string Callback = "System.Void CommanderEnhancementsCachePatcher.Uea0001AssetRuntime::InstallEmbeddedAssets()";

	private const string FieldFixAssets = "System.Void SupremeCommanderOverhaulFieldFixes.EmbeddedAssetRuntime::InstallEmbeddedAssets()";

	private const string SetInitialized = "System.Void EM.Gamedata.Data::set_IsGamedataInitialized(System.Boolean)";

	internal static void Install(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		MethodDefinition methodDefinition = assembly.MainModule.Types.Single((TypeDefinition type) => type.FullName == "EM.Gamedata.Data").Methods.Single((MethodDefinition methodDefinition2) => methodDefinition2.Name == "InitAssets" && methodDefinition2.IsStatic && methodDefinition2.Parameters.Count == 0 && methodDefinition2.HasBody);
		Collection<Instruction> instructions = methodDefinition.Body.Instructions;
		Instruction instruction = RequireSingleCall(instructions, "System.Void SupremeCommanderOverhaulFieldFixes.EmbeddedAssetRuntime::InstallEmbeddedAssets()");
		Instruction instruction2 = RequireSingleCall(instructions, "System.Void EM.Gamedata.Data::set_IsGamedataInitialized(System.Boolean)");
		Instruction previous = instruction2.Previous;
		if (previous == null || previous.OpCode != OpCodes.Ldc_I4_1 || instruction2.Next == null || instruction2.Next.OpCode != OpCodes.Ret)
		{
			throw new InvalidOperationException("Commander pod assets lost the exact InitAssets completion anchor.");
		}
		Instruction[] array = CallsTo(instructions, "System.Void CommanderEnhancementsCachePatcher.Uea0001AssetRuntime::InstallEmbeddedAssets()");
		if (array.Length > 1)
		{
			throw new InvalidOperationException($"Expected at most one commander pod asset callback, found {array.Length}.");
		}
		if (array.Length == 0)
		{
			if (instruction.Next != previous)
			{
				throw new InvalidOperationException("Field Fixes is not the final asset callback before the InitAssets commit.");
			}
			MethodInfo method = typeof(Uea0001AssetRuntime).GetMethod("InstallEmbeddedAssets", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(Uea0001AssetRuntime).FullName, "InstallEmbeddedAssets");
			MethodReference methodReference = assembly.MainModule.ImportReference(method);
			if (!string.Equals(methodReference.FullName, "System.Void CommanderEnhancementsCachePatcher.Uea0001AssetRuntime::InstallEmbeddedAssets()", StringComparison.Ordinal))
			{
				throw new InvalidOperationException("Imported commander pod asset callback identity drifted: " + methodReference.FullName);
			}
			Instruction instruction3 = Instruction.Create(OpCodes.Call, methodReference);
			methodDefinition.Body.GetILProcessor().InsertBefore(previous, instruction3);
			array = new Instruction[1] { instruction3 };
		}
		Validate(methodDefinition, instruction, array[0], previous, instruction2);
	}

	internal static bool IsInstalled(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			return false;
		}
		MethodDefinition methodDefinition = assembly.MainModule.Types.SingleOrDefault((TypeDefinition type) => type.FullName == "EM.Gamedata.Data")?.Methods.SingleOrDefault((MethodDefinition method) => method.Name == "InitAssets" && method.IsStatic && method.Parameters.Count == 0 && method.HasBody);
		if (methodDefinition != null)
		{
			return CallsTo(methodDefinition.Body.Instructions, "System.Void CommanderEnhancementsCachePatcher.Uea0001AssetRuntime::InstallEmbeddedAssets()").Length == 1;
		}
		return false;
	}

	private static void Validate(MethodDefinition initAssets, Instruction fieldFix, Instruction callback, Instruction initializedTrue, Instruction initialized)
	{
		if (fieldFix.Next != callback || callback.Next != initializedTrue || initializedTrue.Next != initialized || initialized.Next == null || initialized.Next.OpCode != OpCodes.Ret)
		{
			throw new InvalidOperationException("Commander pod assets must run immediately after Field Fixes and immediately before InitAssets commits.");
		}
		Collection<Instruction> instructions = initAssets.Body.Instructions;
		int callbackIndex = instructions.IndexOf(callback);
		foreach (var item in EnumerateBranchEdges(instructions))
		{
			if (instructions.IndexOf(item.Source) < callbackIndex && instructions.IndexOf(item.Target) > callbackIndex)
			{
				throw new InvalidOperationException("An InitAssets control-flow edge bypasses commander pod asset installation.");
			}
		}
		foreach (ExceptionHandler exceptionHandler in initAssets.Body.ExceptionHandlers)
		{
			if (new Instruction[5] { exceptionHandler.TryStart, exceptionHandler.TryEnd, exceptionHandler.HandlerStart, exceptionHandler.HandlerEnd, exceptionHandler.FilterStart }.Where((Instruction boundary) => boundary != null).Any((Instruction boundary) => instructions.IndexOf(boundary) >= callbackIndex))
			{
				throw new InvalidOperationException("Commander pod asset installation entered an unsupported InitAssets exception region.");
			}
		}
	}

	private static Instruction RequireSingleCall(IEnumerable<Instruction> instructions, string fullName)
	{
		Instruction[] array = CallsTo(instructions, fullName);
		if (array.Length != 1)
		{
			throw new InvalidOperationException($"Expected exactly one InitAssets call {fullName}, found {array.Length}.");
		}
		return array[0];
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
					return string.Equals(methodReference.FullName, fullName, StringComparison.Ordinal);
				}
			}
			return false;
		}).ToArray();
	}

	private static IEnumerable<(Instruction Source, Instruction Target)> EnumerateBranchEdges(IEnumerable<Instruction> instructions)
	{
		foreach (Instruction instruction in instructions)
		{
			object operand = instruction.Operand;
			Instruction instruction2 = (Instruction)((operand is Instruction) ? operand : null);
			if (instruction2 != null)
			{
				yield return (Source: instruction, Target: instruction2);
			}
			else if (instruction.Operand is Instruction[] array)
			{
				Instruction[] array2 = array;
				Instruction[] array3 = array2;
				foreach (Instruction item in array3)
				{
					yield return (Source: instruction, Target: item);
				}
			}
		}
	}
}
