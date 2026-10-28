using System;
using System.Linq;
using AeonResourceMarkerCachePatcher;
using Mono.Cecil;
using Mono.Cecil.Cil;
using SupremeCommanderOverhaulAudioCompat;
using SupremeCommanderOverhaulFieldFixes;
using SupremeCommanderOverhaulGeneratorBuildability;
using SupremeCommanderOverhaulHydroDisable;
using SupremeCommanderOverhaulIdleReset;
using SupremeCommanderOverhaulMonkeylordFix;
using SupremeCommanderOverhaulSeraphimEcoBuildUi;
using SupremeCommanderOverhaulUpgradeAnimationFix;

namespace SupremeCommanderOverhaulCanonical;

internal static class CanonicalStageCoordinator
{
	private const string FactionSelectorCallback = "System.Void SeraphimFourthFactionCachePatcher.CachePatcherRuntime::ConfigureFactionDropdown(System.Object)";

	private const string FactionLogoCallback = "System.Void SupremeCommanderOverhaulFieldFixes.FactionLogoRuntime::ConfigureFactionLogos(System.Object)";

	private const string RetiredFactionLogoCallback = "System.Void SupremeCommanderOverhaulFactionLogos.CachePatcherRuntime::ConfigureFactionLogos(System.Object)";

	private static readonly string[] AllCanonicalCacheCallbacks = new string[16]
	{
		"System.Void SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulMonkeylordFix.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulSeaParity.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulAudioCompat.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulGeneratorBuildability.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulSeraphimEcoBuildUi.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime::Apply()", "System.Void AeonResourceMarkerCachePatcher.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulIdleReset.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulUpgradeAnimationFix.CachePatcherRuntime::Apply()",
		"System.Void SupremeCommanderOverhaulHydroDisable.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulGameplayCorrections.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::ApplyGalacticColossusHotfix()", "System.Void SupremeCommanderOverhaulAeonStructureMotion.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulFieldFixes.CachePatcherRuntime::Apply()", "System.Void SupremeCommanderOverhaulCanonical.LargeMapPlacementGridCompat::Apply()"
	};

	internal static void Patch(AssemblyDefinition assembly)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
		CanonicalAssemblyContract.RequireSinglePublicPatcherEntryPoint();
		LargeMapShoreWaveCompat.Install(assembly);
		if (IsFullyInstalled(assembly))
		{
			CommanderPodAssetStage.Install(assembly);
			LargeMapPlacementGridCompat.Install(assembly);
			RequireCallbacks(assembly);
			CanonicalAssemblyContract.RequireNoRetiredReferences(assembly);
			return;
		}
		AeonResourceMarkerCachePatcher.CachePatcher.Patch(assembly);
		SupremeCommanderOverhaulAudioCompat.CachePatcher.Patch(assembly);
		SupremeCommanderOverhaulGeneratorBuildability.CachePatcher.Patch(assembly);
		SupremeCommanderOverhaulSeraphimEcoBuildUi.CachePatcher.Patch(assembly);
		SupremeCommanderOverhaulIdleReset.CachePatcher.Patch(assembly);
		SupremeCommanderOverhaulUpgradeAnimationFix.CachePatcher.Patch(assembly);
		SupremeCommanderOverhaulHydroDisable.CachePatcher.Patch(assembly);
		SupremeCommanderOverhaulFieldFixes.CachePatcher.Patch(assembly);
		SupremeCommanderOverhaulMonkeylordFix.CachePatcher.Patch(assembly);
		CommanderPodAssetStage.Install(assembly);
		LargeMapPlacementGridCompat.Install(assembly);
		RequireCallbacks(assembly);
		CanonicalAssemblyContract.RequireNoRetiredReferences(assembly);
	}

	private static bool IsFullyInstalled(AssemblyDefinition assembly)
	{
		TypeDefinition typeDefinition = assembly.MainModule.Types.Single((TypeDefinition type) => type.FullName == "EM.Lua.FilesCache");
		MethodDefinition createFileCache = typeDefinition.Methods.Single((MethodDefinition method) => method.Name == "CreateFileCache" && method.IsStatic && method.Parameters.Count == 0 && method.HasBody);
		if (AllCanonicalCacheCallbacks.Any((string callback) => createFileCache.Body.Instructions.Count((Instruction instruction) => IsCallTo(instruction, callback)) != 1))
		{
			return false;
		}
		if (HasFactionUiHooks(assembly))
		{
			return CommanderPodAssetStage.IsInstalled(assembly);
		}
		return false;
	}

	private static void RequireCallbacks(AssemblyDefinition assembly)
	{
		TypeDefinition typeDefinition = assembly.MainModule.Types.Single((TypeDefinition type) => type.FullName == "EM.Lua.FilesCache");
		MethodDefinition createFileCache = typeDefinition.Methods.Single((MethodDefinition method) => method.Name == "CreateFileCache" && method.IsStatic && method.Parameters.Count == 0 && method.HasBody);
		Instruction[][] array = AllCanonicalCacheCallbacks.Select((string callback) => createFileCache.Body.Instructions.Where((Instruction instruction) => IsCallTo(instruction, callback)).ToArray()).ToArray();
		for (int num = 0; num < array.Length; num++)
		{
			if (array[num].Length != 1)
			{
				throw new InvalidOperationException($"Expected exactly one canonical callback {AllCanonicalCacheCallbacks[num]}, found {array[num].Length}.");
			}
		}
		int[] array2 = array.Select((Instruction[] call) => createFileCache.Body.Instructions.IndexOf(call[0])).ToArray();
		if (!array2.SequenceEqual(array2.OrderBy((int index) => index)))
		{
			throw new InvalidOperationException("Canonical SCOM callbacks are not in their exact dependency order.");
		}
		if (!HasFactionUiHooks(assembly))
		{
			throw new InvalidOperationException("Canonical SCOM faction selector/logo hooks are missing, duplicated, or out of order.");
		}
		if (!CommanderPodAssetStage.IsInstalled(assembly))
		{
			throw new InvalidOperationException("Canonical SCOM commander pod asset callback is missing or duplicated.");
		}
	}

	private static bool HasFactionUiHooks(AssemblyDefinition assembly)
	{
		MethodDefinition methodDefinition = assembly.MainModule.Types.Single((TypeDefinition type) => type.FullName == "EM.UI.PlayerListItem").Methods.Single((MethodDefinition method) => method.Name == "Awake" && method.Parameters.Count == 0 && method.HasBody);
		Instruction[] array = methodDefinition.Body.Instructions.Where((Instruction instruction) => instruction.OpCode == OpCodes.Ret).ToArray();
		Instruction[] array2 = methodDefinition.Body.Instructions.Where((Instruction instruction) => IsCallTo(instruction, "System.Void SeraphimFourthFactionCachePatcher.CachePatcherRuntime::ConfigureFactionDropdown(System.Object)")).ToArray();
		Instruction[] array3 = methodDefinition.Body.Instructions.Where((Instruction instruction) => IsCallTo(instruction, "System.Void SupremeCommanderOverhaulFieldFixes.FactionLogoRuntime::ConfigureFactionLogos(System.Object)")).ToArray();
		if (array.Length == 0 || array2.Length != array.Length || array3.Length != array.Length || methodDefinition.Body.Instructions.Any((Instruction instruction) => IsCallTo(instruction, "System.Void SupremeCommanderOverhaulFactionLogos.CachePatcherRuntime::ConfigureFactionLogos(System.Object)")))
		{
			return false;
		}
		for (int num = 0; num < array.Length; num++)
		{
			int num2 = methodDefinition.Body.Instructions.IndexOf(array2[num]);
			int num3 = methodDefinition.Body.Instructions.IndexOf(array3[num]);
			int num4 = methodDefinition.Body.Instructions.IndexOf(array[num]);
			if (num2 >= num3 || num3 >= num4)
			{
				return false;
			}
		}
		return true;
	}

	private static bool IsCallTo(Instruction instruction, string fullName)
	{
		if (!IsCall(instruction))
		{
			return false;
		}
		object operand = instruction.Operand;
		MethodReference methodReference = (MethodReference)((operand is MethodReference) ? operand : null);
		if (methodReference != null)
		{
			return string.Equals(methodReference.FullName, fullName, StringComparison.Ordinal);
		}
		return false;
	}

	private static bool IsCall(Instruction instruction)
	{
		if (instruction != null)
		{
			if (!(instruction.OpCode == OpCodes.Call))
			{
				return instruction.OpCode == OpCodes.Callvirt;
			}
			return true;
		}
		return false;
	}
}
