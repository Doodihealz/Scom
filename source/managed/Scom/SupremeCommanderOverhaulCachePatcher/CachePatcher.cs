using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;
using SanctuaryConstructionPlansCachePatcher;
using ScomCybranConstruction;
using ScomEditableSources;
using ScomFatboyTracks;
using ScomNavalSurfaceFoam;
using SeraphimFourthFactionCachePatcher;
using SupremeCommanderOverhaulCanonical;
using SupremeCommanderOverhaulFieldFixes;
using SupremeCommanderVeterancyCachePatcher;

namespace SupremeCommanderOverhaulCachePatcher;

public static class CachePatcher
{
	private const string SupportedGameMvid = "2cc1c6fa-e909-410e-8fd9-2f307b231dfb";

	private const float ProgressAnimationSentinelThreshold = -9000f;

	private const float ProgressAnimationSentinelBase = -10000f;

	public static IEnumerable<string> TargetDLLs
	{
		get
		{
			yield return "Trebuchet.dll";
		}
	}

	public static void Patch(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		if (!string.Equals(assembly.MainModule.Mvid.ToString("D"), "824eddf3-58d1-4a0a-824a-0153dcd374ee", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Canonical SCOM does not support Trebuchet.dll MVID " + assembly.MainModule.Mvid.ToString("D") + ".");
		}
		SeraphimFourthFactionCachePatcher.CachePatcher.Install(assembly);
		SupremeCommanderVeterancyCachePatcher.CachePatcher.Install(assembly);
		InstallProgressBoundAnimationBridge(assembly);
		ElapsedAnimationSampleBridge.Install(assembly);
		InstallConstructionPlansPersistenceBridge(assembly);
		TypeDefinition filesCache = assembly.MainModule.Types.FirstOrDefault((TypeDefinition type) => type.FullName == "EM.Lua.FilesCache") ?? throw new TypeLoadException("EM.Lua.FilesCache was not found.");
		MethodDefinition methodDefinition = filesCache.Methods.FirstOrDefault((MethodDefinition methodDefinition2) => methodDefinition2.Name == "CreateFileCache" && methodDefinition2.Parameters.Count == 0) ?? throw new MissingMethodException(filesCache.FullName, "CreateFileCache");
		Instruction target = methodDefinition.Body.Instructions.FirstOrDefault(delegate(Instruction instruction)
		{
			if (instruction.OpCode == OpCodes.Call || instruction.OpCode == OpCodes.Callvirt)
			{
				object operand = instruction.Operand;
				MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
				if (methodReference != null && methodReference.DeclaringType.FullName == filesCache.FullName)
				{
					return methodReference.Name == "LoadFiles";
				}
			}
			return false;
		}) ?? throw new MissingMethodException(filesCache.FullName, "LoadFiles");
		MethodInfo method = typeof(CachePatcherRuntime).GetMethod("Apply", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(CachePatcherRuntime).FullName, "Apply");
		MethodReference applyReference = assembly.MainModule.ImportReference(method);
		if (!methodDefinition.Body.Instructions.Any(delegate(Instruction instruction)
		{
			object operand = instruction.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			return methodReference != null && methodReference.FullName == applyReference.FullName;
		}))
		{
			methodDefinition.Body.GetILProcessor().InsertAfter(target, methodDefinition.Body.GetILProcessor().Create(OpCodes.Call, applyReference));
		}
		CanonicalStageCoordinator.Patch(assembly);
		FollowupCacheRuntime.Install(assembly);
		SoulRipperCacheRuntime.Install(assembly);
		NavalSurfaceFoam.Install(assembly);
		TrackHooks.Install(assembly);
		SourceInstaller.Install(assembly);
		ConstructionHooks.Install(assembly);
		LobbyFactionLabels.Install(assembly);
	}

	private static void InstallConstructionPlansPersistenceBridge(AssemblyDefinition assembly)
	{
		TypeDefinition typeDefinition = RequireType(assembly, "EM.Lua.Client.ClientLuaInterface");
		MethodDefinition methodDefinition = RequireMethod(typeDefinition, (MethodDefinition methodDefinition2) => methodDefinition2.Name == "Startup" && methodDefinition2.IsStatic && methodDefinition2.Parameters.Count == 0 && methodDefinition2.HasBody, "EM.Lua.Client.ClientLuaInterface.Startup()");
		MethodInfo method = typeof(ConstructionPlansPersistenceBridge).GetMethod("Register", BindingFlags.Static | BindingFlags.Public, null, new Type[1] { typeof(UIntPtr) }, null) ?? throw new MissingMethodException(typeof(ConstructionPlansPersistenceBridge).FullName, "Register");
		MethodReference registerReference = assembly.MainModule.ImportReference(method);
		int num = methodDefinition.Body.Instructions.Count(delegate(Instruction instruction2)
		{
			object operand = instruction2.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			return methodReference != null && methodReference.FullName == registerReference.FullName;
		});
		switch (num)
		{
		default:
			throw new InvalidOperationException($"Expected at most one Construction Plans persistence registration; found {num}.");
		case 0:
		{
			MethodDefinition method2 = RequireMethod(typeDefinition, (MethodDefinition methodDefinition2) => methodDefinition2.Name == "get_Data" && methodDefinition2.IsStatic && methodDefinition2.Parameters.Count == 0, "EM.Lua.Client.ClientLuaInterface.get_Data()");
			TypeDefinition typeDefinition2 = typeDefinition.NestedTypes.SingleOrDefault((TypeDefinition type) => type.Name == "Unmanaged") ?? throw new TypeLoadException("EM.Lua.Client.ClientLuaInterface.Unmanaged was not found.");
			FieldDefinition luaStateField = typeDefinition2.Fields.SingleOrDefault((FieldDefinition fieldDefinition) => fieldDefinition.Name == "luaState") ?? throw new MissingFieldException(typeDefinition2.FullName, "luaState");
			TypeDefinition typeDefinition3 = RequireType(assembly, "lua_State");
			FieldDefinition field = typeDefinition3.Fields.SingleOrDefault((FieldDefinition fieldDefinition) => fieldDefinition.Name == "Handle" && fieldDefinition.FieldType.MetadataType == MetadataType.UIntPtr) ?? throw new MissingFieldException(typeDefinition3.FullName, "Handle");
			Instruction item = RequireSingleInstruction(methodDefinition.Body.Instructions, delegate(Instruction instruction2, int _)
			{
				if (instruction2.OpCode == OpCodes.Call || instruction2.OpCode == OpCodes.Callvirt)
				{
					object operand = instruction2.Operand;
					MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
					if (methodReference != null && methodReference.DeclaringType.FullName == "EM.Lua.LuaInterface")
					{
						return methodReference.Name == "InitLuaState";
					}
				}
				return false;
			}, "the client LuaInterface.InitLuaState call");
			int initIndex = methodDefinition.Body.Instructions.IndexOf(item);
			Instruction instruction = RequireSingleInstruction(methodDefinition.Body.Instructions, delegate(Instruction instruction2, int index)
			{
				if (index > initIndex && index <= initIndex + 2 && instruction2.OpCode == OpCodes.Stfld)
				{
					object operand = instruction2.Operand;
					FieldReference fieldReference = (FieldReference)((operand is FieldReference) ? operand : null);
					if (fieldReference != null)
					{
						return fieldReference.FullName == luaStateField.FullName;
					}
				}
				return false;
			}, "the client luaState store after InitLuaState");
			ILProcessor iLProcessor = methodDefinition.Body.GetILProcessor();
			Instruction cursor = instruction;
			cursor = InsertAfter(iLProcessor, cursor, iLProcessor.Create(OpCodes.Call, method2));
			cursor = InsertAfter(iLProcessor, cursor, iLProcessor.Create(OpCodes.Ldfld, luaStateField));
			cursor = InsertAfter(iLProcessor, cursor, iLProcessor.Create(OpCodes.Ldfld, field));
			InsertAfter(iLProcessor, cursor, iLProcessor.Create(OpCodes.Call, registerReference));
			if (methodDefinition.Body.Instructions.Count(delegate(Instruction instruction2)
			{
				object operand = instruction2.Operand;
				MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
				return methodReference != null && methodReference.FullName == registerReference.FullName;
			}) != 1)
			{
				throw new InvalidOperationException("The Construction Plans persistence bridge did not install exactly once.");
			}
			break;
		}
		case 1:
			break;
		}
	}

	private static Instruction InsertAfter(ILProcessor processor, Instruction cursor, Instruction instruction)
	{
		processor.InsertAfter(cursor, instruction);
		return instruction;
	}

	private static void InstallProgressBoundAnimationBridge(AssemblyDefinition assembly)
	{
		ProgressBoundAnimationBridgeAttestation.BeginVerification();
		MethodDefinition methodDefinition = RequireMethod(RequireType(assembly, "EM.Lua.Host.HostLuaInterface"), (MethodDefinition method) => method.Name == "PlayAnimation" && method.IsStatic && method.Parameters.Count == 3 && method.Parameters[1].ParameterType.MetadataType == MetadataType.Int32 && method.Parameters[2].ParameterType.MetadataType == MetadataType.Single && method.HasBody, "EM.Lua.Host.HostLuaInterface.PlayAnimation(in GlobalID, int, float)");
		MethodDefinition methodDefinition2 = RequireMethod(RequireType(assembly, "EM.Engine.Simulation.TxBothSystem_AnimateSimulationBones/AnimateSimulationBonesJob"), (MethodDefinition method) => method.Name == "Execute" && method.HasBody && method.ReturnType.FullName == "System.Void" && method.Parameters.Select((ParameterDefinition parameter) => parameter.ParameterType.FullName).SequenceEqual(new string[2] { "System.Int32", "EM.Entities.World&" }), "EM.Engine.Simulation.TxBothSystem_AnimateSimulationBones/AnimateSimulationBonesJob.Execute(int, World&)");
		int num = CountFloatLiteral(methodDefinition, -9000f);
		int num2 = CountFloatLiteral(methodDefinition2, -9000f);
		if (num == 2 && num2 == 1)
		{
			ProgressBoundAnimationBridgeAttestation.RecordVerified();
			return;
		}
		if (num != 0 || num2 != 0)
		{
			throw new InvalidOperationException("A partial progress-bound animation bridge was found; refusing to mix native IL revisions.");
		}
		PatchPlayAnimationForProgressFrames(methodDefinition);
		PatchSimulationAnimationAdvanceForProgressFrames(methodDefinition2);
		if (CountFloatLiteral(methodDefinition, -9000f) != 2 || CountFloatLiteral(methodDefinition2, -9000f) != 1)
		{
			throw new InvalidOperationException("The progress-bound animation bridge did not produce its complete sentinel contract.");
		}
		ProgressBoundAnimationBridgeAttestation.RecordVerified();
	}

	private static void PatchPlayAnimationForProgressFrames(MethodDefinition playAnimation)
	{
		Collection<Instruction> instructions = playAnimation.Body.Instructions;
		Instruction instruction = RequireSingleInstruction(instructions, (Instruction instruction3, int index) => instruction3.OpCode == OpCodes.Stfld && IsSimulationAnimationField(instruction3, "blendDuration") && index > 0 && IsFloatLiteral(instructions[index - 1], 0f), "the no-blend SimulationAnimationComponent.blendDuration store");
		Instruction instruction2 = RequireSingleInstruction(instructions, (Instruction instruction3, int index) => instruction3.OpCode == OpCodes.Stfld && IsSimulationAnimationField(instruction3, "currentClipTime") && index > 0 && IsFloatLiteral(instructions[index - 1], 0f) && instructions.Skip(index + 1).Take(8).Any(IsSetAnimationComponentCall), "the terminal SimulationAnimationComponent.currentClipTime store");
		InsertProgressFrameValue(playAnimation.Body.GetILProcessor(), instructions[instructions.IndexOf(instruction) - 1], instruction, encodeClipTime: false);
		InsertProgressFrameValue(playAnimation.Body.GetILProcessor(), instructions[instructions.IndexOf(instruction2) - 1], instruction2, encodeClipTime: true);
	}

	private static void InsertProgressFrameValue(ILProcessor processor, Instruction stockZero, Instruction fieldStore, bool encodeClipTime)
	{
		processor.InsertBefore(stockZero, processor.Create(OpCodes.Ldarg_2));
		processor.InsertBefore(stockZero, processor.Create(OpCodes.Ldc_R4, -9000f));
		processor.InsertBefore(stockZero, processor.Create(OpCodes.Bgt_Un, stockZero));
		if (encodeClipTime)
		{
			processor.InsertBefore(stockZero, processor.Create(OpCodes.Ldarg_2));
			processor.InsertBefore(stockZero, processor.Create(OpCodes.Ldc_R4, 10000f));
			processor.InsertBefore(stockZero, processor.Create(OpCodes.Add));
		}
		else
		{
			processor.InsertBefore(stockZero, processor.Create(OpCodes.Ldc_R4, -10000f));
		}
		processor.InsertBefore(stockZero, processor.Create(OpCodes.Br, fieldStore));
	}

	private static void PatchSimulationAnimationAdvanceForProgressFrames(MethodDefinition updateSimulationBones)
	{
		Collection<Instruction> instructions = updateSimulationBones.Body.Instructions;
		Instruction item = RequireSingleInstruction(instructions, (Instruction instruction3, int index) => IsApplyPlaybackModeCall(instruction3) && instructions.Skip(Math.Max(0, index - 8)).Take(8).Any((Instruction candidate) => candidate.OpCode == OpCodes.Ldfld && IsSimulationAnimationField(candidate, "currentClipTime")), "the current-clip AnimationUtils.ApplyPlaybackMode call");
		int beforeIndex = instructions.IndexOf(item);
		Instruction item2 = FindPreviousInstruction(instructions, beforeIndex, (Instruction instruction3) => instruction3.OpCode == OpCodes.Ldfld && IsSimulationAnimationField(instruction3, "currentClipTime"), "the currentClipTime load before AnimationUtils.ApplyPlaybackMode");
		int num = instructions.IndexOf(item2);
		if (num == 0)
		{
			throw new InvalidOperationException("The currentClipTime load has no owning SimulationAnimationComponent local.");
		}
		VariableDefinition local = GetLocal(updateSimulationBones, instructions[num - 1], "the SimulationAnimationComponent local used for playback");
		Instruction clampStart = instructions[num - 1];
		Instruction item3 = RequireSingleInstruction(instructions, (Instruction instruction3, int _) => IsUnconditionalBranch(instruction3) && instruction3.Operand == clampStart, "the automatic-animation-time join branch");
		int num2 = instructions.IndexOf(item3);
		Instruction item4 = FindPreviousInstruction(instructions, num2, delegate(Instruction instruction3)
		{
			if (instruction3.OpCode == OpCodes.Ldfld)
			{
				object operand2 = instruction3.Operand;
				FieldReference fieldReference = (FieldReference)((operand2 is FieldReference) ? operand2 : null);
				if (fieldReference != null && fieldReference.DeclaringType.FullName == "EM.Components.AnimationClipInformation")
				{
					return fieldReference.Name == "adjustPlaybackSpeedBasedOnSimulationSpeed";
				}
			}
			return false;
		}, "the AnimationClipInformation.adjustPlaybackSpeedBasedOnSimulationSpeed load");
		int num3 = instructions.IndexOf(item4);
		Instruction instruction = NextNonNop(instructions, num3 + 1, "the adjustPlaybackSpeedBasedOnSimulationSpeed branch");
		if (instruction.OpCode.Code != Code.Brfalse && instruction.OpCode.Code != Code.Brfalse_S)
		{
			throw new InvalidOperationException("The animation-speed flag no longer selects the stock time-advance path.");
		}
		object operand = instruction.Operand;
		Instruction instruction2 = (Instruction)((operand is Instruction) ? operand : null);
		if (instruction2 == null || instructions.IndexOf(instruction2) <= num2 || instructions.IndexOf(instruction2) >= num)
		{
			throw new InvalidOperationException("The animation-speed fallback path no longer joins the expected playback block.");
		}
		Instruction target = PreviousNonNop(instructions, num3 - 1, "the stock automatic animation-time advance");
		FieldReference field = (FieldReference)FindPreviousInstruction(instructions, num3, (Instruction instruction3) => instruction3.OpCode == OpCodes.Ldfld && IsSimulationAnimationField(instruction3, "blendDuration"), "the SimulationAnimationComponent.blendDuration load before current-clip time advance").Operand;
		ILProcessor iLProcessor = updateSimulationBones.Body.GetILProcessor();
		iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Ldloc, local));
		iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Ldfld, field));
		iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Ldc_R4, -9000f));
		iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Bgt_Un, target));
		iLProcessor.InsertBefore(target, iLProcessor.Create(OpCodes.Br, clampStart));
	}

	private static TypeDefinition RequireType(AssemblyDefinition assembly, string fullName)
	{
		TypeDefinition[] array = (from type in EnumerateTypes(assembly.MainModule.Types)
			where type.FullName == fullName
			select type).ToArray();
		if (array.Length != 1)
		{
			throw new TypeLoadException($"Expected exactly one {fullName}; found {array.Length}.");
		}
		return array[0];
	}

	private static IEnumerable<TypeDefinition> EnumerateTypes(IEnumerable<TypeDefinition> types)
	{
		foreach (TypeDefinition type in types)
		{
			yield return type;
			foreach (TypeDefinition item in EnumerateTypes(type.NestedTypes))
			{
				yield return item;
			}
		}
	}

	private static MethodDefinition RequireMethod(TypeDefinition type, Func<MethodDefinition, bool> predicate, string description)
	{
		MethodDefinition[] array = type.Methods.Where<MethodDefinition>(predicate).ToArray();
		if (array.Length != 1)
		{
			throw new MissingMethodException($"Expected exactly one {description}; found {array.Length}.");
		}
		return array[0];
	}

	private static Instruction RequireSingleInstruction(ICollection<Instruction> instructions, Func<Instruction, int, bool> predicate, string description)
	{
		Instruction[] array = (from candidate in instructions.Select((Instruction instruction, int index) => new { instruction, index })
			where predicate(candidate.instruction, candidate.index)
			select candidate.instruction).ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException($"Expected exactly one {description}; found {array.Length}.");
		}
		return array[0];
	}

	private static Instruction FindPreviousInstruction(ICollection<Instruction> instructions, int beforeIndex, Func<Instruction, bool> predicate, string description)
	{
		for (int num = beforeIndex - 1; num >= 0; num--)
		{
			if (predicate(instructions.ElementAt(num)))
			{
				return instructions.ElementAt(num);
			}
		}
		throw new InvalidOperationException("Could not find " + description + ".");
	}

	private static Instruction NextNonNop(ICollection<Instruction> instructions, int startIndex, string description)
	{
		for (int i = startIndex; i < instructions.Count; i++)
		{
			Instruction instruction = instructions.ElementAt(i);
			if (instruction.OpCode.Code != Code.Nop)
			{
				return instruction;
			}
		}
		throw new InvalidOperationException("Could not find " + description + ".");
	}

	private static Instruction PreviousNonNop(ICollection<Instruction> instructions, int startIndex, string description)
	{
		for (int num = startIndex; num >= 0; num--)
		{
			Instruction instruction = instructions.ElementAt(num);
			if (instruction.OpCode.Code != Code.Nop)
			{
				return instruction;
			}
		}
		throw new InvalidOperationException("Could not find " + description + ".");
	}

	private static VariableDefinition GetLocal(MethodDefinition method, Instruction instruction, string description)
	{
		object operand = instruction.Operand;
		VariableDefinition variableDefinition = (VariableDefinition)((operand is VariableDefinition) ? operand : null);
		if (variableDefinition != null)
		{
			return variableDefinition;
		}
		int num = (int)instruction.OpCode.Code switch
		{
			6 => 0, 
			7 => 1, 
			8 => 2, 
			9 => 3, 
			_ => -1, 
		};
		if (num < 0 || num >= method.Body.Variables.Count)
		{
			throw new InvalidOperationException("Expected " + description + " to be loaded from a local variable.");
		}
		return method.Body.Variables[num];
	}

	private static int CountFloatLiteral(MethodDefinition method, float value)
	{
		return method.Body.Instructions.Count((Instruction instruction) => IsFloatLiteral(instruction, value));
	}

	private static bool IsFloatLiteral(Instruction instruction, float value)
	{
		if (instruction.OpCode == OpCodes.Ldc_R4 && instruction.Operand is float num)
		{
			return num == value;
		}
		return false;
	}

	private static bool IsSimulationAnimationField(Instruction instruction, string fieldName)
	{
		object operand = instruction.Operand;
		FieldReference fieldReference = (FieldReference)((operand is FieldReference) ? operand : null);
		if (fieldReference != null && fieldReference.DeclaringType.FullName == "EM.Components.SimulationAnimationComponent")
		{
			return fieldReference.Name == fieldName;
		}
		return false;
	}

	private static bool IsSetAnimationComponentCall(Instruction instruction)
	{
		if (instruction.OpCode == OpCodes.Call || instruction.OpCode == OpCodes.Callvirt)
		{
			object operand = instruction.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			if (methodReference != null && methodReference.DeclaringType.FullName == "EM.Engine.HostEngine")
			{
				return methodReference.Name == "SetAnimationComponent";
			}
		}
		return false;
	}

	private static bool IsApplyPlaybackModeCall(Instruction instruction)
	{
		if (instruction.OpCode == OpCodes.Call || instruction.OpCode == OpCodes.Callvirt)
		{
			object operand = instruction.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			if (methodReference != null)
			{
				return methodReference.Name == "ApplyPlaybackMode";
			}
		}
		return false;
	}

	private static bool IsUnconditionalBranch(Instruction instruction)
	{
		if (instruction.OpCode.Code != Code.Br)
		{
			return instruction.OpCode.Code == Code.Br_S;
		}
		return true;
	}
}
