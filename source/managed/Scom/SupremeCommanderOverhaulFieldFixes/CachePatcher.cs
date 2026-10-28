using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Collections.Generic;
using ScomCurrentEngine;
using SupremeCommanderOverhaulAeonStructureMotion;
using SupremeCommanderOverhaulBuildBoxParity;
using SupremeCommanderOverhaulCanonical;
using SupremeCommanderOverhaulGameplayCorrections;
using SupremeCommanderOverhaulSeaParity;

namespace SupremeCommanderOverhaulFieldFixes;

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

	private const int HoverFacingMarkerMask = 1073741824;

	private const float HoverFacingTurnRateMultiplier = 1.3333334f;

	internal const string GameplayApply = "System.Void SupremeCommanderOverhaulGameplayCorrections.CachePatcherRuntime::Apply()";

	internal const string SeaApply = "System.Void SupremeCommanderOverhaulSeaParity.CachePatcherRuntime::Apply()";

	internal const string BuildBoxApply = "System.Void SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime::Apply()";

	internal const string OwnColossusApply = "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::ApplyGalacticColossusHotfix()";

	internal const string MotionApply = "System.Void SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime::Apply()";

	internal const string MotionAssetInstall = "System.Void SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime::InstallEmbeddedStorageAssets()";

	internal const string OwnApply = "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::Apply()";

	internal const string OwnAssetInstall = "System.Void SupremeCommanderOverhaulFieldFixes.EmbeddedAssetRuntime::InstallEmbeddedAssets()";

	internal const string RebuildDirectoryIndex = "System.Void EM.Lua.FilesCache::RebuildDirectoryIndex()";

	internal const string WatcherGetter = "EM.GameUtils.DebugManager/UnmanagedDebugProperties& EM.GameUtils.DebugManager::get_data()";

	internal const string SetGamedataInitialized = "System.Void EM.Gamedata.Data::set_IsGamedataInitialized(System.Boolean)";

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
			LogSkip("unsupported Trebuchet.dll MVID " + assembly.MainModule.Mvid.ToString("D"));
			return;
		}
		ValidateConsolidatedDiscoverySurface();
		SupremeCommanderOverhaulSeaParity.CachePatcher.PatchStage(assembly);
		SupremeCommanderOverhaulBuildBoxParity.CachePatcher.PatchStage(assembly);
		SupremeCommanderOverhaulGameplayCorrections.CachePatcher.PatchStage(assembly);
		SupremeCommanderOverhaulAeonStructureMotion.CachePatcher.PatchStage(assembly);
		PatchStage(assembly);
		PatchHoverStrafeNativeMovement(assembly);
		ValidateConsolidatedChain(assembly);
		LogInfo("native Aurora/Blaze hover-strafe movement verified");
	}

	private static void ValidateConsolidatedDiscoverySurface()
	{
		CanonicalAssemblyContract.RequireSinglePublicPatcherEntryPoint();
	}

	private static void ValidateConsolidatedChain(AssemblyDefinition assembly)
	{
		MethodDefinition methodDefinition = assembly.MainModule.Types.Single((TypeDefinition type) => type.FullName == "EM.Lua.FilesCache").Methods.Single((MethodDefinition method) => method.Name == "CreateFileCache" && method.IsStatic && method.Parameters.Count == 0 && method.HasBody);
		Collection<Instruction> instructions = methodDefinition.Body.Instructions;
		Instruction[] array = new string[6] { "System.Void SupremeCommanderOverhaulSeaParity.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulGameplayCorrections.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::ApplyGalacticColossusHotfix()", "System.Void SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::Apply()" }.Select((string signature) => RequireSingleCall(instructions, signature)).ToArray();
		for (int num = 1; num < array.Length; num++)
		{
			if (instructions.IndexOf(array[num - 1]) >= instructions.IndexOf(array[num]))
			{
				throw new InvalidOperationException("The consolidated SCOM cache stages are not in their required order.");
			}
		}
		MethodDefinition methodDefinition2 = assembly.MainModule.Types.Single((TypeDefinition type) => type.FullName == "EM.Gamedata.Data").Methods.Single((MethodDefinition method) => method.Name == "InitAssets" && method.IsStatic && method.Parameters.Count == 0 && method.HasBody);
		Instruction[] array2 = new Instruction[2]
		{
			RequireSingleCall(methodDefinition2.Body.Instructions, "System.Void SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime::InstallEmbeddedStorageAssets()"),
			RequireSingleCall(methodDefinition2.Body.Instructions, "System.Void SupremeCommanderOverhaulFieldFixes.EmbeddedAssetRuntime::InstallEmbeddedAssets()")
		};
		if (methodDefinition2.Body.Instructions.IndexOf(array2[0]) >= methodDefinition2.Body.Instructions.IndexOf(array2[1]))
		{
			throw new InvalidOperationException("The consolidated SCOM asset stages are not in their required order.");
		}
		string name = typeof(CachePatcher).Assembly.GetName().Name;
		foreach (Instruction item in array.Concat(array2))
		{
			object operand = item.Operand;
			MethodReference methodReference = (MethodReference)(((operand is MethodReference) ? operand : null) ?? throw new InvalidOperationException("A consolidated SCOM callback lost its method reference."));
			if (!string.Equals(methodReference.DeclaringType.Scope?.Name, name, StringComparison.Ordinal))
			{
				throw new InvalidOperationException(methodReference.FullName + " is not owned by the consolidated SCOM assembly.");
			}
		}
		HashSet<string> retiredNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase) { "ZZZZZZZZZZZ-SupremeCommanderOverhaul-SeaParity-CachePatcher", "ZZZZZZZZZZZZ-SupremeCommanderOverhaul-BuildBoxParity-CachePatcher", "ZZZZZZZZZZZZZZZZ-SupremeCommanderOverhaul-GameplayCorrections-CachePatcher", "ZZZZZZZZZZZZZZZZZ-SupremeCommanderOverhaul-AeonStructureMotion-CachePatcher" };
		string[] array3 = (from reference in assembly.MainModule.AssemblyReferences
			where retiredNames.Contains(reference.Name)
			select reference.Name).ToArray();
		if (array3.Length != 0)
		{
			throw new InvalidOperationException("The patched game still references retired SCOM patchers: " + string.Join(", ", array3));
		}
	}

	private static Instruction RequireSingleCall(IEnumerable<Instruction> instructions, string methodFullName)
	{
		Instruction[] array = CallsTo(instructions, methodFullName);
		if (array.Length != 1)
		{
			throw new InvalidOperationException("Expected exactly one consolidated callback " + methodFullName + ", found " + array.Length + ".");
		}
		return array[0];
	}

	private static void PatchHoverStrafeNativeMovement(AssemblyDefinition assembly)
	{
		HoverCircleNative.Install(assembly);
	}

	private static void PatchOrbitTargetDirection(MethodDefinition orbit, FieldDefinition targetDirection)
	{
		Instruction instruction = orbit.Body.Instructions.Single(delegate(Instruction instruction5)
		{
			if (IsCall(instruction5))
			{
				object operand = instruction5.Operand;
				MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
				if (methodReference != null && methodReference.Name == "op_Division" && methodReference.DeclaringType.FullName == "Unity.Mathematics.float2" && methodReference.ReturnType.FullName == "Unity.Mathematics.float2" && methodReference.Parameters.Count == 2 && methodReference.Parameters[0].ParameterType.FullName == "Unity.Mathematics.float2")
				{
					return methodReference.Parameters[1].ParameterType.FullName == "System.Single";
				}
			}
			return false;
		}).Next ?? throw new InvalidOperationException("Orbit radial normalization lost its local-store anchor.");
		VariableDefinition variableDefinition = GetStoredVariable(orbit, instruction) ?? throw new InvalidOperationException("Orbit radial normalization no longer stores a local.");
		if (variableDefinition.VariableType.FullName != "Unity.Mathematics.float2")
		{
			throw new InvalidOperationException("Orbit radial direction local changed type.");
		}
		Instruction[] array = FieldInstructions(orbit, OpCodes.Stfld, targetDirection).ToArray();
		if (array.Length == 0)
		{
			ILProcessor iLProcessor = orbit.Body.GetILProcessor();
			Instruction instruction2 = Instruction.Create(OpCodes.Ldarg_2);
			Instruction instruction3 = Instruction.Create(OpCodes.Ldloc, variableDefinition);
			Instruction instruction4 = Instruction.Create(OpCodes.Stfld, targetDirection);
			iLProcessor.InsertAfter(instruction, instruction2);
			iLProcessor.InsertAfter(instruction2, instruction3);
			iLProcessor.InsertAfter(instruction3, instruction4);
			orbit.Body.MaxStackSize = Math.Max(orbit.Body.MaxStackSize, 2);
		}
		else if (array.Length != 1)
		{
			throw new InvalidOperationException("Orbit target-facing direction has an ambiguous installation count.");
		}
	}

	private static void PatchHoverStrafeRotationSync(MethodDefinition sync, FieldDefinition mode, FieldDefinition collisionMask, FieldDefinition orbitTarget, MethodReference globalIdIsValid)
	{
		Instruction[] array = sync.Body.Instructions.Where((Instruction instruction4) => LoadsInt32(instruction4, 1073741824)).ToArray();
		if (array.Length == 1)
		{
			return;
		}
		if (array.Length != 0)
		{
			throw new InvalidOperationException("Hover-strafe rotation sync marker is ambiguous.");
		}
		Instruction instruction = sync.Body.Instructions.Single(delegate(Instruction instruction4)
		{
			if (IsCall(instruction4))
			{
				object operand2 = instruction4.Operand;
				MethodReference methodReference = (MethodReference)((operand2 is MethodReference) ? operand2 : null);
				if (methodReference != null)
				{
					return methodReference.FullName == "System.Boolean EM.Components.MovementFlagsUtils::IsEnabled(EM.Components.MovementFlags)";
				}
			}
			return false;
		}).Next ?? throw new InvalidOperationException("Movement rotation sync lost its enabled branch.");
		if (instruction.OpCode != OpCodes.Brtrue_S && instruction.OpCode != OpCodes.Brtrue)
		{
			throw new InvalidOperationException("Movement rotation sync enabled branch changed shape.");
		}
		Instruction next = instruction.Next;
		object operand = instruction.Operand;
		Instruction instruction2 = (Instruction)((operand is Instruction) ? operand : null);
		if (next == null || next.OpCode != OpCodes.Ret || instruction2 == null || next.Next != instruction2)
		{
			throw new InvalidOperationException("Movement rotation sync entry control flow changed shape.");
		}
		Instruction[] array2 = new Instruction[14]
		{
			Instruction.Create(OpCodes.Ldarg_1),
			Instruction.Create(OpCodes.Ldfld, mode),
			Instruction.Create(OpCodes.Ldc_I4_1),
			Instruction.Create(OpCodes.Bne_Un, instruction2),
			Instruction.Create(OpCodes.Ldarg_1),
			Instruction.Create(OpCodes.Ldfld, collisionMask),
			Instruction.Create(OpCodes.Ldc_I4, 1073741824),
			Instruction.Create(OpCodes.And),
			Instruction.Create(OpCodes.Brfalse, instruction2),
			Instruction.Create(OpCodes.Ldarg_1),
			Instruction.Create(OpCodes.Ldflda, orbitTarget),
			Instruction.Create(OpCodes.Call, globalIdIsValid),
			Instruction.Create(OpCodes.Brfalse, instruction2),
			Instruction.Create(OpCodes.Br, next)
		};
		ILProcessor iLProcessor = sync.Body.GetILProcessor();
		Instruction[] array3 = array2;
		foreach (Instruction instruction3 in array3)
		{
			iLProcessor.InsertBefore(instruction2, instruction3);
		}
		instruction.Operand = array2[0];
		sync.Body.MaxStackSize = Math.Max(sync.Body.MaxStackSize, 2);
	}

	private static void PatchHoverStrafeChassisRotation(MethodDefinition rotation, FieldDefinition mode, FieldDefinition collisionMask, FieldDefinition orbitTarget, FieldDefinition targetDirection, FieldDefinition heading, FieldDefinition chassisYaw, MethodReference globalIdIsValid)
	{
		Instruction[] array = FieldInstructions(rotation, OpCodes.Stfld, chassisYaw).ToArray();
		if (array.Length != 2)
		{
			if (array.Length != 1)
			{
				throw new InvalidOperationException("Movement chassis-yaw assignment has an unsupported shape.");
			}
			Instruction stockStore = array[0];
			Instruction headingLoad = stockStore.Previous;
			Instruction valueOwner = headingLoad?.Previous;
			Instruction destinationOwner = valueOwner?.Previous;
			if (headingLoad == null || !IsFieldInstruction(headingLoad, OpCodes.Ldfld, heading) || valueOwner == null || valueOwner.OpCode != OpCodes.Ldarg_1 || destinationOwner == null || destinationOwner.OpCode != OpCodes.Ldarg_1)
			{
				throw new InvalidOperationException("Stock movement chassis-yaw assignment changed shape.");
			}
			if (rotation.Body.Instructions.Any(delegate(Instruction instruction5)
			{
				object operand = instruction5.Operand;
				Instruction instruction6 = (Instruction)((operand is Instruction) ? operand : null);
				return (instruction6 != null && (instruction6 == destinationOwner || instruction6 == valueOwner || instruction6 == headingLoad || instruction6 == stockStore)) || (instruction5.Operand is Instruction[] source && source.Any((Instruction instruction7) => instruction7 == destinationOwner || instruction7 == valueOwner || instruction7 == headingLoad || instruction7 == stockStore));
			}))
			{
				throw new InvalidOperationException("Stock movement chassis-yaw assignment gained an internal branch target.");
			}
			Instruction instruction = rotation.Body.Instructions.Single((Instruction instruction5) => IsCallTo(instruction5, "EM.GameUtils.MathUtils", "LerpAngle"));
			VariableDefinition variableDefinition = ((instruction.Previous == null) ? null : GetLoadedVariable(rotation, instruction.Previous));
			if (variableDefinition == null || variableDefinition.VariableType.FullName != "System.Single")
			{
				throw new InvalidOperationException("Movement heading turn-step local changed shape.");
			}
			Instruction instruction2 = rotation.Body.Instructions.Single((Instruction instruction5) => IsCallTo(instruction5, "Unity.Mathematics.math", "forward"));
			VariableDefinition variableDefinition2 = ((instruction2.Next == null) ? null : GetStoredVariable(rotation, instruction2.Next));
			if (variableDefinition2 == null || variableDefinition2.VariableType.FullName != "Unity.Mathematics.float3")
			{
				throw new InvalidOperationException("Movement forward-vector local changed shape.");
			}
			MethodReference method = (MethodReference)instruction2.Operand;
			MethodReference method2 = RequireSingleCallReference(rotation, (MethodReference reference) => reference.Name == "get_xz" && reference.DeclaringType.FullName == "Unity.Mathematics.float3", "float3.xz in movement rotation");
			MethodReference method3 = RequireSingleCallReference(rotation, (MethodReference reference) => reference.Name == "SignedAngle2D" && reference.DeclaringType.FullName == "EM.GameUtils.MathUtils", "SignedAngle2D in movement rotation");
			MethodReference method4 = RequireSingleCallReference(rotation, (MethodReference reference) => reference.Name == "ToDegrees" && reference.DeclaringType.FullName == "EM.GameUtils.MathUtils", "ToDegrees in movement rotation");
			MethodReference method5 = (MethodReference)instruction.Operand;
			VariableDefinition variableDefinition3 = new VariableDefinition(chassisYaw.FieldType);
			rotation.Body.Variables.Add(variableDefinition3);
			rotation.Body.InitLocals = true;
			ILProcessor iLProcessor = rotation.Body.GetILProcessor();
			Instruction[] array2 = new Instruction[3]
			{
				Instruction.Create(OpCodes.Ldarg_1),
				Instruction.Create(OpCodes.Ldfld, chassisYaw),
				Instruction.Create(OpCodes.Stloc, variableDefinition3)
			};
			foreach (Instruction instruction3 in array2)
			{
				iLProcessor.InsertBefore(destinationOwner, instruction3);
			}
			Instruction target = stockStore.Next ?? throw new InvalidOperationException("Stock movement chassis-yaw assignment lost its continuation.");
			array2 = new Instruction[28]
			{
				Instruction.Create(OpCodes.Ldarg_1),
				Instruction.Create(OpCodes.Ldfld, mode),
				Instruction.Create(OpCodes.Ldc_I4_1),
				Instruction.Create(OpCodes.Bne_Un, target),
				Instruction.Create(OpCodes.Ldarg_1),
				Instruction.Create(OpCodes.Ldfld, collisionMask),
				Instruction.Create(OpCodes.Ldc_I4, 1073741824),
				Instruction.Create(OpCodes.And),
				Instruction.Create(OpCodes.Brfalse, target),
				Instruction.Create(OpCodes.Ldarg_1),
				Instruction.Create(OpCodes.Ldflda, orbitTarget),
				Instruction.Create(OpCodes.Call, globalIdIsValid),
				Instruction.Create(OpCodes.Brfalse, target),
				Instruction.Create(OpCodes.Ldarg_1),
				Instruction.Create(OpCodes.Ldloc, variableDefinition3),
				Instruction.Create(OpCodes.Call, method),
				Instruction.Create(OpCodes.Stloc, variableDefinition2),
				Instruction.Create(OpCodes.Ldloca, variableDefinition2),
				Instruction.Create(OpCodes.Call, method2),
				Instruction.Create(OpCodes.Ldarg_1),
				Instruction.Create(OpCodes.Ldfld, targetDirection),
				Instruction.Create(OpCodes.Call, method3),
				Instruction.Create(OpCodes.Call, method4),
				Instruction.Create(OpCodes.Ldloc, variableDefinition),
				Instruction.Create(OpCodes.Ldc_R4, 1.3333334f),
				Instruction.Create(OpCodes.Mul),
				Instruction.Create(OpCodes.Call, method5),
				Instruction.Create(OpCodes.Stfld, chassisYaw)
			};
			foreach (Instruction instruction4 in array2)
			{
				iLProcessor.InsertBefore(target, instruction4);
			}
			rotation.Body.MaxStackSize = Math.Max(rotation.Body.MaxStackSize, 4);
		}
	}

	private static void ValidateHoverStrafeNativeMovement(MethodDefinition orbit, MethodDefinition sync, MethodDefinition rotation, FieldDefinition mode, FieldDefinition collisionMask, FieldDefinition orbitTarget, FieldDefinition targetDirection, FieldDefinition heading, FieldDefinition chassisYaw, MethodReference globalIdIsValid)
	{
		Instruction next = orbit.Body.Instructions.Single(delegate(Instruction instruction)
		{
			if (IsCall(instruction))
			{
				object operand = instruction.Operand;
				MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
				if (methodReference != null && methodReference.Name == "op_Division" && methodReference.DeclaringType.FullName == "Unity.Mathematics.float2")
				{
					return methodReference.ReturnType.FullName == "Unity.Mathematics.float2";
				}
			}
			return false;
		}).Next;
		VariableDefinition variableDefinition = ((next == null) ? null : GetStoredVariable(orbit, next));
		Instruction[] array = FieldInstructions(orbit, OpCodes.Stfld, targetDirection).ToArray();
		if (next != null && variableDefinition != null && array.Length == 1)
		{
			object obj = next.Next?.Next?.Next;
			if (obj == array[0])
			{
				OpCode? opCode = next.Next?.OpCode;
				OpCode ldarg_ = OpCodes.Ldarg_2;
				if (opCode.HasValue && !(opCode.GetValueOrDefault() != ldarg_) && GetLoadedVariable(orbit, next.Next.Next) == variableDefinition)
				{
					ValidateHoverStrafeSync(sync, mode, collisionMask, orbitTarget, globalIdIsValid);
					ValidateHoverStrafeRotation(rotation, mode, collisionMask, orbitTarget, targetDirection, heading, chassisYaw, globalIdIsValid);
					return;
				}
			}
		}
		throw new InvalidOperationException("Native hover-strafe radial target-direction contract failed validation.");
	}

	private static void ValidateHoverStrafeSync(MethodDefinition sync, FieldDefinition mode, FieldDefinition collisionMask, FieldDefinition orbitTarget, MethodReference globalIdIsValid)
	{
		Instruction[] array = FieldInstructions(sync, OpCodes.Ldfld, mode).ToArray();
		Instruction[] array2 = FieldInstructions(sync, OpCodes.Ldfld, collisionMask).ToArray();
		Instruction[] array3 = FieldInstructions(sync, OpCodes.Ldflda, orbitTarget).ToArray();
		Instruction[] array4 = sync.Body.Instructions.Where((Instruction instruction3) => LoadsInt32(instruction3, 1073741824)).ToArray();
		Instruction[] array5 = sync.Body.Instructions.Where(delegate(Instruction instruction3)
		{
			if (IsCall(instruction3))
			{
				object operand = instruction3.Operand;
				MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
				if (methodReference != null)
				{
					return methodReference.FullName == globalIdIsValid.FullName;
				}
			}
			return false;
		}).ToArray();
		if (array.Length == 1 && array2.Length == 1 && array3.Length == 1 && array4.Length == 1 && array5.Length == 1)
		{
			OpCode? opCode = array[0].Previous?.OpCode;
			OpCode ldarg_ = OpCodes.Ldarg_1;
			if (opCode.HasValue && !(opCode.GetValueOrDefault() != ldarg_) && !(array2[0].Previous?.OpCode != OpCodes.Ldarg_1))
			{
				opCode = array3[0].Previous?.OpCode;
				ldarg_ = OpCodes.Ldarg_1;
				if (opCode.HasValue && !(opCode.GetValueOrDefault() != ldarg_) && array2[0].Next == array4[0] && !(array4[0].Next?.OpCode != OpCodes.And))
				{
					object obj = array4[0].Next?.Next?.Operand;
					Instruction instruction = (Instruction)((obj is Instruction) ? obj : null);
					Instruction instruction2 = array[0].Next?.Next;
					Instruction next = array5[0].Next;
					if (instruction != null && array[0].Next != null && LoadsInt32(array[0].Next, 1) && instruction2 != null && instruction2.Operand == instruction && next != null && next.Operand == instruction)
					{
						opCode = next.Next?.OpCode;
						ldarg_ = OpCodes.Br;
						if (opCode.HasValue && !(opCode.GetValueOrDefault() != ldarg_) && next.Next.Next != null && next.Next.Next == instruction)
						{
							return;
						}
					}
					throw new InvalidOperationException("Native hover-strafe rotation-sync control flow failed validation.");
				}
			}
		}
		throw new InvalidOperationException("Native hover-strafe rotation-sync guard failed validation.");
	}

	private static void ValidateHoverStrafeRotation(MethodDefinition rotation, FieldDefinition mode, FieldDefinition collisionMask, FieldDefinition orbitTarget, FieldDefinition targetDirection, FieldDefinition heading, FieldDefinition chassisYaw, MethodReference globalIdIsValid)
	{
		Instruction[] array = FieldInstructions(rotation, OpCodes.Stfld, chassisYaw).ToArray();
		Instruction[] array2 = array.Where((Instruction store) => store.Previous != null && IsFieldInstruction(store.Previous, OpCodes.Ldfld, heading) && store.Previous.Previous?.OpCode == OpCodes.Ldarg_1 && store.Previous.Previous.Previous?.OpCode == OpCodes.Ldarg_1).ToArray();
		Instruction[] array3 = array.Where((Instruction store) => store.Previous != null && IsCallTo(store.Previous, "EM.GameUtils.MathUtils", "LerpAngle")).ToArray();
		Instruction[] array4 = FieldInstructions(rotation, OpCodes.Ldfld, mode).ToArray();
		Instruction[] array5 = FieldInstructions(rotation, OpCodes.Ldfld, collisionMask).ToArray();
		Instruction[] array6 = FieldInstructions(rotation, OpCodes.Ldflda, orbitTarget).ToArray();
		Instruction[] array7 = FieldInstructions(rotation, OpCodes.Ldfld, targetDirection).ToArray();
		Instruction[] array8 = rotation.Body.Instructions.Where((Instruction instruction) => LoadsInt32(instruction, 1073741824)).ToArray();
		Instruction[] array9 = rotation.Body.Instructions.Where((Instruction instruction) => instruction.OpCode == OpCodes.Ldc_R4 && instruction.Operand is float num && num == 1.3333334f).ToArray();
		Instruction[] array10 = rotation.Body.Instructions.Where(delegate(Instruction instruction)
		{
			if (IsCall(instruction))
			{
				object operand = instruction.Operand;
				MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
				if (methodReference != null)
				{
					return methodReference.FullName == globalIdIsValid.FullName;
				}
			}
			return false;
		}).ToArray();
		if (array.Length != 2 || array2.Length != 1 || array3.Length != 1 || array4.Length != 1 || array5.Length != 1 || array6.Length != 1 || array7.Length != 1 || array8.Length != 1 || array9.Length != 1 || array10.Length != 1 || CountCalls(rotation, "EM.GameUtils.MathUtils", "SignedAngle2D") != 2 || CountCalls(rotation, "EM.GameUtils.MathUtils", "ToDegrees") != 2 || CountCalls(rotation, "EM.GameUtils.MathUtils", "LerpAngle") != 2 || CountCalls(rotation, "Unity.Mathematics.math", "forward") != 2 || CountCalls(rotation, "Unity.Mathematics.float3", "get_xz") != 2)
		{
			throw new InvalidOperationException("Native hover-strafe chassis rotation failed structural validation.");
		}
		Instruction[] array11 = rotation.Body.Instructions.Where((Instruction instruction) => GetStoredVariable(rotation, instruction) != null && instruction.Previous != null && IsFieldInstruction(instruction.Previous, OpCodes.Ldfld, chassisYaw) && instruction.Previous.Previous?.OpCode == OpCodes.Ldarg_1).ToArray();
		if (array11.Length != 1)
		{
			throw new InvalidOperationException("Native hover-strafe previous chassis yaw was not captured exactly once.");
		}
		VariableDefinition previousYaw = GetStoredVariable(rotation, array11[0]);
		if (previousYaw != null && rotation.Body.Instructions.Count((Instruction instruction) => GetLoadedVariable(rotation, instruction) == previousYaw) == 1)
		{
			Instruction next = array11[0].Next;
			object obj = array2[0].Previous?.Previous?.Previous;
			if (next == obj)
			{
				Instruction continuation = array3[0].Next;
				if (continuation != null && rotation.Body.Instructions.Count((Instruction instruction) => instruction.Operand == continuation && instruction.OpCode.FlowControl == FlowControl.Cond_Branch) == 3 && rotation.Body.Instructions.IndexOf(array3[0]) > rotation.Body.Instructions.IndexOf(array2[0]))
				{
					OpCode? opCode = array9[0].Next?.OpCode;
					OpCode mul = OpCodes.Mul;
					if (opCode.HasValue && !(opCode.GetValueOrDefault() != mul) && array5[0].Next == array8[0] && !(array8[0].Next?.OpCode != OpCodes.And))
					{
						return;
					}
				}
				throw new InvalidOperationException("Native hover-strafe chassis control flow failed validation.");
			}
		}
		throw new InvalidOperationException("Native hover-strafe previous chassis-yaw flow failed validation.");
	}

	private static TypeDefinition RequireType(ModuleDefinition module, string fullName)
	{
		TypeDefinition[] array = (from type in EnumerateTypes(module.Types)
			where type.FullName == fullName
			select type).ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException("Expected one " + fullName + " type, found " + array.Length + ".");
		}
		return array[0];
	}

	private static IEnumerable<TypeDefinition> EnumerateTypes(IEnumerable<TypeDefinition> roots)
	{
		foreach (TypeDefinition type in roots)
		{
			yield return type;
			foreach (TypeDefinition item in EnumerateTypes(type.NestedTypes))
			{
				yield return item;
			}
		}
	}

	private static FieldDefinition RequireField(TypeDefinition type, string name)
	{
		FieldDefinition[] array = type.Fields.Where((FieldDefinition field) => field.Name == name).ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException("Expected one " + type.FullName + "." + name + " field, found " + array.Length + ".");
		}
		return array[0];
	}

	private static MethodDefinition RequireMethod(TypeDefinition type, string name, int parameterCount)
	{
		MethodDefinition[] array = type.Methods.Where((MethodDefinition method) => method.Name == name && method.Parameters.Count == parameterCount && method.HasBody).ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException("Expected one " + type.FullName + "." + name + " method with " + parameterCount + " parameters, found " + array.Length + ".");
		}
		return array[0];
	}

	private static MethodReference RequireSingleCallReference(MethodDefinition method, Func<MethodReference, bool> predicate, string description)
	{
		MethodReference[] array = (from reference in method.Body.Instructions.Where(IsCall).Select(delegate(Instruction instruction)
			{
				object operand = instruction.Operand;
				return (MethodReference)((operand is MethodReference) ? operand : null);
			})
			where reference != null && predicate(reference)
			select reference).Cast<MethodReference>().ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException("Expected one " + description + ", found " + array.Length + ".");
		}
		return array[0];
	}

	private static IEnumerable<Instruction> FieldInstructions(MethodDefinition method, OpCode opcode, FieldReference field)
	{
		return method.Body.Instructions.Where((Instruction instruction) => IsFieldInstruction(instruction, opcode, field));
	}

	private static bool IsFieldInstruction(Instruction instruction, OpCode opcode, FieldReference field)
	{
		if (instruction.OpCode == opcode)
		{
			object operand = instruction.Operand;
			FieldReference fieldReference = (FieldReference)((operand is FieldReference) ? operand : null);
			if (fieldReference != null)
			{
				return fieldReference.FullName == field.FullName;
			}
		}
		return false;
	}

	private static bool IsCall(Instruction instruction)
	{
		if (!(instruction.OpCode == OpCodes.Call))
		{
			return instruction.OpCode == OpCodes.Callvirt;
		}
		return true;
	}

	private static bool IsCallTo(Instruction instruction, string declaringType, string methodName)
	{
		if (IsCall(instruction))
		{
			object operand = instruction.Operand;
			MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
			if (methodReference != null && methodReference.DeclaringType.FullName == declaringType)
			{
				return methodReference.Name == methodName;
			}
		}
		return false;
	}

	private static int CountCalls(MethodDefinition method, string declaringType, string methodName)
	{
		return method.Body.Instructions.Count((Instruction instruction) => IsCallTo(instruction, declaringType, methodName));
	}

	private static VariableDefinition? GetStoredVariable(MethodDefinition method, Instruction instruction)
	{
		switch (instruction.OpCode.Code)
		{
		case Code.Stloc_S:
		case Code.Stloc:
		{
			object operand = instruction.Operand;
			return (VariableDefinition)((operand is VariableDefinition) ? operand : null);
		}
		default:
			return null;
		case Code.Stloc_0:
			return method.Body.Variables[0];
		case Code.Stloc_1:
			return method.Body.Variables[1];
		case Code.Stloc_2:
			return method.Body.Variables[2];
		case Code.Stloc_3:
			return method.Body.Variables[3];
		}
	}

	private static VariableDefinition? GetLoadedVariable(MethodDefinition method, Instruction instruction)
	{
		switch (instruction.OpCode.Code)
		{
		case Code.Ldloc_S:
		case Code.Ldloc:
		{
			object operand = instruction.Operand;
			return (VariableDefinition)((operand is VariableDefinition) ? operand : null);
		}
		default:
			return null;
		case Code.Ldloc_0:
			return method.Body.Variables[0];
		case Code.Ldloc_1:
			return method.Body.Variables[1];
		case Code.Ldloc_2:
			return method.Body.Variables[2];
		case Code.Ldloc_3:
			return method.Body.Variables[3];
		}
	}

	private static bool LoadsInt32(Instruction instruction, int value)
	{
		switch ((int)instruction.OpCode.Code)
		{
		case 21:
			return value == -1;
		case 22:
			return value == 0;
		case 23:
			return value == 1;
		case 24:
			return value == 2;
		case 25:
			return value == 3;
		case 26:
			return value == 4;
		case 27:
			return value == 5;
		case 28:
			return value == 6;
		case 29:
			return value == 7;
		case 30:
			return value == 8;
		case 31:
			if (instruction.Operand is sbyte b)
			{
				return b == value;
			}
			return false;
		case 32:
			if (instruction.Operand is int num)
			{
				return num == value;
			}
			return false;
		default:
			return false;
		}
	}

	private static void PatchStage(AssemblyDefinition assembly)
	{
		PatchFactionLogoHook(assembly);
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
		Instruction[] array3 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulGameplayCorrections.CachePatcherRuntime::Apply()");
		Instruction[] array4 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::ApplyGalacticColossusHotfix()");
		Instruction[] array5 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime::Apply()");
		Instruction[] array6 = CallsTo(instructions, "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::Apply()");
		Instruction[] array7 = CallsTo(instructions, "System.Void EM.Lua.FilesCache::RebuildDirectoryIndex()");
		Instruction[] array8 = CallsTo(instructions, "EM.GameUtils.DebugManager/UnmanagedDebugProperties& EM.GameUtils.DebugManager::get_data()");
		if (array6.Length > 1)
		{
			throw new InvalidOperationException($"Expected zero or one Field Fixes callbacks, found {array6.Length}.");
		}
		if (array4.Length > 1)
		{
			throw new InvalidOperationException($"Expected zero or one Galactic Colossus callbacks, found {array4.Length}.");
		}
		TypeDefinition[] array9 = assembly.MainModule.Types.Where((TypeDefinition type) => type.FullName == "EM.Gamedata.Data").ToArray();
		if (array9.Length != 1)
		{
			if (array6.Length != 0)
			{
				throw new InvalidOperationException("An installed Field Fixes callback lost EM.Gamedata.Data.");
			}
			LogSkip($"expected one EM.Gamedata.Data type, found {array9.Length}");
			return;
		}
		MethodDefinition[] array10 = array9[0].Methods.Where((MethodDefinition candidate) => candidate.Name == "InitAssets" && candidate.IsStatic && candidate.Parameters.Count == 0).ToArray();
		if (array10.Length != 1 || !array10[0].HasBody)
		{
			if (array6.Length != 0)
			{
				throw new InvalidOperationException("An installed Field Fixes callback lost Data.InitAssets().");
			}
			LogSkip("Data.InitAssets() is missing, ambiguous, or bodyless");
			return;
		}
		MethodDefinition methodDefinition2 = array10[0];
		Collection<Instruction> instructions2 = methodDefinition2.Body.Instructions;
		Instruction[] array11 = CallsTo(instructions2, "System.Void SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime::InstallEmbeddedStorageAssets()");
		Instruction[] array12 = CallsTo(instructions2, "System.Void SupremeCommanderOverhaulFieldFixes.EmbeddedAssetRuntime::InstallEmbeddedAssets()");
		if (array12.Length > 1)
		{
			throw new InvalidOperationException($"Expected zero or one Field Fixes asset callbacks, found {array12.Length}.");
		}
		if (array6.Length == 0 != (array12.Length == 0))
		{
			throw new InvalidOperationException("A partial Field Fixes dual-hook installation was found.");
		}
		if (array11.Length != 1)
		{
			if (array12.Length != 0)
			{
				throw new InvalidOperationException("The installed Field Fixes asset callback lost its Aeon Motion predecessor.");
			}
			LogSkip($"expected one Aeon Motion asset callback, found {array11.Length}");
			return;
		}
		Instruction[] array13 = CallsTo(instructions2, "System.Void EM.Gamedata.Data::set_IsGamedataInitialized(System.Boolean)");
		if (array13.Length != 1 || array13[0].Previous == null || array13[0].Previous.OpCode != OpCodes.Ldc_I4_1 || array13[0].Next == null || array13[0].Next.OpCode != OpCodes.Ret)
		{
			if (array12.Length != 0)
			{
				throw new InvalidOperationException("The installed Field Fixes asset callback lost its InitAssets completion anchor.");
			}
			LogSkip("Data.InitAssets() completion anchor is absent or ambiguous");
			return;
		}
		Instruction initializedTrue = array13[0].Previous;
		if (EnumerateBranchEdges(instructions2).Any((BranchEdge edge) => edge.Target == initializedTrue) || !HasSupportedExceptionLayout(methodDefinition2.Body, instructions2, initializedTrue))
		{
			if (array12.Length != 0)
			{
				throw new InvalidOperationException("The installed Field Fixes asset callback entered an unsupported InitAssets control-flow region.");
			}
			LogSkip("Data.InitAssets completion can be bypassed or is inside an exception region");
			return;
		}
		if (array12.Length == 0 && array11[0].Next != initializedTrue)
		{
			LogSkip("Aeon Motion is not the final pre-commit InitAssets callback");
			return;
		}
		if (array3.Length != 1 || array5.Length != 1 || array7.Length != 1 || array8.Length != 1)
		{
			if (array6.Length != 0)
			{
				throw new InvalidOperationException("Field Fixes exists without its exact predecessor and cache anchors.");
			}
			LogSkip($"required callbacks/anchors are unavailable: gameplay={array3.Length}, motion={array5.Length}, rebuild={array7.Length}, watcher={array8.Length}");
			return;
		}
		if (array4.Length == 0)
		{
			MethodReference method = ImportRuntimeMethod(assembly.MainModule, typeof(CachePatcherRuntime), "ApplyGalacticColossusHotfix", "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::ApplyGalacticColossusHotfix()");
			Instruction instruction = Instruction.Create(OpCodes.Call, method);
			methodDefinition.Body.GetILProcessor().InsertAfter(array3[0], instruction);
			array4 = new Instruction[1] { instruction };
		}
		if (array6.Length == 0)
		{
			MethodReference method2 = ImportRuntimeMethod(assembly.MainModule, typeof(CachePatcherRuntime), "Apply", "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::Apply()");
			Instruction instruction2 = Instruction.Create(OpCodes.Call, method2);
			methodDefinition.Body.GetILProcessor().InsertBefore(array8[0], instruction2);
			array6 = new Instruction[1] { instruction2 };
			MethodReference method3 = ImportRuntimeMethod(assembly.MainModule, typeof(EmbeddedAssetRuntime), "InstallEmbeddedAssets", "System.Void SupremeCommanderOverhaulFieldFixes.EmbeddedAssetRuntime::InstallEmbeddedAssets()");
			Instruction instruction3 = Instruction.Create(OpCodes.Call, method3);
			methodDefinition2.Body.GetILProcessor().InsertBefore(initializedTrue, instruction3);
			array12 = new Instruction[1] { instruction3 };
		}
		ValidateOrder(instructions, array3[0], array4[0], array5[0], array7[0], array6[0], array8[0]);
		ValidateAssetOrder(instructions2, array11[0], array12[0], initializedTrue, array13[0]);
	}

	private static MethodReference ImportRuntimeMethod(ModuleDefinition module, Type runtimeType, string methodName, string expectedFullName)
	{
		MethodInfo method = runtimeType.GetMethod(methodName, BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(runtimeType.FullName, methodName);
		MethodReference methodReference = module.ImportReference(method);
		if (!string.Equals(methodReference.FullName, expectedFullName, StringComparison.Ordinal))
		{
			throw new InvalidOperationException("Imported Field Fixes callback identity drifted: " + methodReference.FullName);
		}
		return methodReference;
	}

	private static void PatchFactionLogoHook(AssemblyDefinition assembly)
	{
		TypeDefinition[] array = assembly.MainModule.Types.Where((TypeDefinition type) => type.FullName == "EM.UI.PlayerListItem").ToArray();
		if (array.Length != 1)
		{
			LogSkip($"expected one EM.UI.PlayerListItem type, found {array.Length}");
			return;
		}
		MethodDefinition[] array2 = array[0].Methods.Where((MethodDefinition methodDefinition2) => methodDefinition2.Name == "Awake" && methodDefinition2.Parameters.Count == 0 && methodDefinition2.ReturnType.FullName == "System.Void" && methodDefinition2.HasBody).ToArray();
		if (array2.Length != 1)
		{
			LogSkip($"expected one EM.UI.PlayerListItem.Awake(), found {array2.Length}");
			return;
		}
		MethodDefinition methodDefinition = array2[0];
		Instruction[] array3 = methodDefinition.Body.Instructions.Where((Instruction instruction2) => instruction2.OpCode == OpCodes.Ret).ToArray();
		Instruction[] array4 = CallsTo(methodDefinition.Body.Instructions, "System.Void SupremeCommanderOverhaulFieldFixes.FactionLogoRuntime::ConfigureFactionLogos(System.Object)");
		if (CallsTo(methodDefinition.Body.Instructions, "System.Void SupremeCommanderOverhaulFactionLogos.CachePatcherRuntime::ConfigureFactionLogos(System.Object)").Length != 0)
		{
			throw new InvalidOperationException("The retired standalone faction-logo hook is still installed.");
		}
		if (array3.Length == 0)
		{
			LogSkip("PlayerListItem.Awake() has no return anchor");
		}
		else if (array4.Length != array3.Length)
		{
			if (array4.Length != 0)
			{
				throw new InvalidOperationException("Field Fixes faction-logo hook count is incomplete.");
			}
			MethodInfo method = typeof(FactionLogoRuntime).GetMethod("ConfigureFactionLogos", BindingFlags.Static | BindingFlags.Public) ?? throw new MissingMethodException(typeof(FactionLogoRuntime).FullName, "ConfigureFactionLogos");
			MethodReference methodReference = assembly.MainModule.ImportReference(method);
			if (!string.Equals(methodReference.FullName, "System.Void SupremeCommanderOverhaulFieldFixes.FactionLogoRuntime::ConfigureFactionLogos(System.Object)", StringComparison.Ordinal))
			{
				throw new InvalidOperationException("Imported faction-logo callback identity drifted: " + methodReference.FullName);
			}
			ILProcessor iLProcessor = methodDefinition.Body.GetILProcessor();
			Instruction[] array5 = array3;
			foreach (Instruction target in array5)
			{
				Instruction instruction = Instruction.Create(OpCodes.Ldarg_0);
				iLProcessor.InsertBefore(target, instruction);
				iLProcessor.InsertAfter(instruction, Instruction.Create(OpCodes.Call, methodReference));
			}
		}
	}

	private static void ValidateOrder(IList<Instruction> instructions, Instruction gameplay, Instruction colossus, Instruction motion, Instruction rebuild, Instruction own, Instruction watcher)
	{
		int num = instructions.IndexOf(gameplay);
		int num2 = instructions.IndexOf(colossus);
		int num3 = instructions.IndexOf(motion);
		int num4 = instructions.IndexOf(rebuild);
		int num5 = instructions.IndexOf(own);
		int num6 = instructions.IndexOf(watcher);
		if (num4 >= num || num >= num2 || num2 >= num3 || num3 >= num5 || num5 >= num6)
		{
			throw new InvalidOperationException("The isolated Galactic Colossus fix must run after Gameplay Corrections and before Aeon Structure Motion; the full Field Fixes transaction must remain after Motion and before the watcher.");
		}
		if (gameplay.Next != colossus || colossus.Next != motion)
		{
			throw new InvalidOperationException("The isolated Galactic Colossus callback must be the immediate, non-bypassable stage between Gameplay Corrections and Aeon Structure Motion.");
		}
		int num7 = num5 + 1;
		while (num7 < num6)
		{
			Instruction instruction = instructions[num7];
			if (!(instruction.OpCode != OpCodes.Call) || !(instruction.OpCode != OpCodes.Callvirt))
			{
				object operand = instruction.Operand;
				MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
				if (methodReference != null && methodReference.FullName.EndsWith("CachePatcherRuntime::Apply()", StringComparison.Ordinal))
				{
					num7++;
					continue;
				}
			}
			throw new InvalidOperationException("Unexpected code exists between Field Fixes and the watcher.");
		}
	}

	private static void ValidateAssetOrder(IList<Instruction> instructions, Instruction motion, Instruction own, Instruction initializedTrue, Instruction initializedSetter)
	{
		if (motion.Next != own || own.Next != initializedTrue || initializedTrue.Next != initializedSetter || initializedSetter.Next == null || initializedSetter.Next.OpCode != OpCodes.Ret)
		{
			throw new InvalidOperationException("Field Fixes asset ownership must run immediately after Aeon Motion and immediately before initialization commits.");
		}
		int num = instructions.IndexOf(own);
		foreach (BranchEdge item in EnumerateBranchEdges(instructions))
		{
			if (instructions.IndexOf(item.Source) < num && instructions.IndexOf(item.Target) > num)
			{
				throw new InvalidOperationException("A Data.InitAssets control-flow edge bypasses Field Fixes asset ownership.");
			}
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

	private static void LogSkip(string reason)
	{
		try
		{
			Console.WriteLine("[SCOM Field Fixes] Preloader skipped: " + reason + ".");
		}
		catch
		{
		}
	}

	private static void LogInfo(string message)
	{
		try
		{
			Console.WriteLine("[SCOM Field Fixes] Preloader: " + message + ".");
		}
		catch
		{
		}
	}
}
