using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using AeonChosenAcuCachePatcher;
using AeonChosenRosterCachePatcher;
using AeonProjectileVisualsCachePatcher;
using CommanderEnhancementsCachePatcher;
using CybranAcuProjectileVisualsCachePatcher;
using CybranHopliteCachePatcher;
using CybranMantisCachePatcher;
using EdaUefFatboyCachePatcher;
using EdaUefLandPowerCachePatcher;
using EdaUefPercivalCachePatcher;
using FaAirBomberCachePatcher;
using FaAirFactoryCachePatcher;
using FaAirFighterCachePatcher;
using FaAirScoutCachePatcher;
using FaAnimationClosureCachePatcher;
using FaArtilleryPairCachePatcher;
using FaCombatStructuresCachePatcher;
using FaCybranEggProductsCachePatcher;
using FaCybranHunterCachePatcher;
using FaCybranLandScoutCachePatcher;
using FaCybranMegalithCachePatcher;
using FaCybranScathisCachePatcher;
using FaCybranT3RolesCachePatcher;
using FaDirectStructuresCachePatcher;
using FaEngineerWaterAnimationsCachePatcher;
using FaLandRoleReplacementsCachePatcher;
using FaSupportStructuresCachePatcher;
using GuardCybranAcuAudioCachePatcher;
using GuardCybranAcuCachePatcher;
using GuardCybranMonkeylordCachePatcher;
using GuardCybranStructuresCachePatcher;
using GuardCybranT3ArtilleryCachePatcher;
using GuardEdaEngineerCachePatcher;
using SanctuaryConstructionPlansCachePatcher;
using SeraphimAiCompatibilityCachePatcher;
using SeraphimFourthFactionCachePatcher;
using StructurePersistentAudioCachePatcher;
using StructurePlacementContractCachePatcher;
using SupremeCommanderUnitPresentationCachePatcher;
using SupremeCommanderVeterancyCachePatcher;
using UefAcuAudioCachePatcher;
using UefAcuEdaCachePatcher;

namespace SupremeCommanderOverhaulCachePatcher;

public static class CachePatcherRuntime
{
	private static readonly HashSet<string> CriticalModuleIds = new HashSet<string>(StringComparer.Ordinal) { "seraphim-fourth-faction", "aeon-chosen-roster", "structure-placement-contract", "seraphim-ai", "fa-air-scouts", "fa-air-fighters" };

	private static readonly ModuleSpec[] Modules = new ModuleSpec[42]
	{
		new ModuleSpec("uef-acu", "UEF ACU", ApplyUefAcu),
		new ModuleSpec("engineers", "Guard/EDA engineers", ApplyEngineers),
		new ModuleSpec("artillery", "Guard T3 artillery", ApplyArtillery),
		new ModuleSpec("structures", "Guard/EDA structures", ApplyStructures, "engineers"),
		new ModuleSpec("eda-land-power", "EDA UEF land/power", ApplyEdaUefLandPower, "structures"),
		new ModuleSpec("fatboy", "UEF Fatboy", ApplyFatboy, "structures"),
		new ModuleSpec("monkeylord", "Guard Monkeylord", ApplyMonkeylord),
		new ModuleSpec("guard-acu", "Guard ACU", ApplyGuardAcu),
		new ModuleSpec("fa-air-scouts", "FA UEF/Cybran air scouts", ApplyFaAirScouts),
		new ModuleSpec("fa-air-fighters", "FA UEF/Cybran T1 air fighters", ApplyFaAirFighters),
		new ModuleSpec("fa-cybran-land-scout", "FA Cybran T1 land scout", ApplyFaCybranLandScout),
		new ModuleSpec("fa-air-factories", "FA UEF/Cybran T2/T3 air factories", ApplyFaAirFactories, "structures"),
		new ModuleSpec("fa-engineer-water-animations", "FA UEF/Cybran engineer water animations", ApplyFaEngineerWaterAnimations, "fa-air-factories", "engineers"),
		new ModuleSpec("fa-direct-structures", "FA direct mass-fabricator, engineering-station, and terminal-shield structures", ApplyFaDirectStructures, "structures"),
		new ModuleSpec("guard-acu-engine-audio", "Guard ACU engine audio", ApplyGuardAcuEngineAudio, "guard-acu"),
		new ModuleSpec("uef-acu-engine-audio", "UEF ACU engine audio", ApplyUefAcuEngineAudio, "uef-acu"),
		new ModuleSpec("cybran-mantis", "Cybran Mantis", ApplyCybranMantis, "guard-acu"),
		new ModuleSpec("support-structures", "FA support structures", ApplySupportStructures),
		new ModuleSpec("combat-structures", "FA combat structures", ApplyCombatStructures, "artillery"),
		new ModuleSpec("cybran-hoplite", "Cybran Hoplite", ApplyCybranHoplite, "combat-structures"),
		new ModuleSpec("fa-artillery-pair", "FA Cybran Medusa/Gunther artillery pair", ApplyFaArtilleryPair, "cybran-hoplite"),
		new ModuleSpec("fa-land-role-replacements", "FA Titan/Wagner land role replacements", ApplyFaLandRoleReplacements, "fa-artillery-pair"),
		new ModuleSpec("fa-uef-percival", "FA UEF Percival", ApplyEdaUefPercival, "fa-land-role-replacements"),
		new ModuleSpec("fa-cybran-hunter", "FA Cybran Hunter role replacement", ApplyFaCybranHunter, "fa-land-role-replacements"),
		new ModuleSpec("fa-cybran-t3-roles", "FA Cybran Brick/Loyalist T3 role replacements", ApplyFaCybranT3Roles, "fa-cybran-hunter"),
		new ModuleSpec("fa-cybran-egg-products", "FA Cybran Banger/Trebuchet egg products", ApplyFaCybranEggProducts, "fa-cybran-t3-roles"),
		new ModuleSpec("fa-cybran-megalith", "FA Cybran Megalith and construction eggs", ApplyFaCybranMegalith, "engineers", "fa-cybran-egg-products"),
		new ModuleSpec("fa-cybran-scathis", "FA Cybran Scathis role replacement", ApplyFaCybranScathis, "fa-cybran-t3-roles", "structures"),
		new ModuleSpec("seraphim-fourth-faction", "Seraphim fourth faction", ApplySeraphimFourthFaction),
		new ModuleSpec("aeon-chosen-roster", "Aeon Chosen one-for-one roster", ApplyAeonChosenRoster, "seraphim-fourth-faction"),
		new ModuleSpec("fa-animation-closure", "FA weapon deploy and submarine hatch animation closure", ApplyFaAnimationClosure, "aeon-chosen-roster", "structures"),
		new ModuleSpec("structure-persistent-audio", "Imported structure persistent audio", ApplyStructurePersistentAudio),
		new ModuleSpec("aeon-acu", "Aeon ACU", ApplyAeonAcu, "aeon-chosen-roster"),
		new ModuleSpec("aeon-projectile-visuals", "Aeon mint projectile visuals", ApplyAeonProjectileVisuals, "seraphim-fourth-faction", "aeon-acu"),
		new ModuleSpec("fa-air-bombers", "FA surface and anti-navy air bombers", ApplyFaAirBombers, "fa-air-fighters", "fa-air-factories", "seraphim-fourth-faction", "aeon-chosen-roster", "aeon-projectile-visuals"),
		new ModuleSpec("cybran-acu-projectiles", "Cybran red ACU projectile visuals", ApplyCybranAcuProjectileVisuals, "guard-acu", "aeon-projectile-visuals"),
		new ModuleSpec("structure-placement-contract", "FA structure placement contract", ApplyStructurePlacementContract, "structures", "eda-land-power", "support-structures", "combat-structures", "seraphim-fourth-faction"),
		new ModuleSpec("construction-plans", "Sanctuary Construction Plans", ApplyConstructionPlans),
		new ModuleSpec("seraphim-ai", "Seraphim AI compatibility", ApplySeraphimAiCompatibility, "seraphim-fourth-faction"),
		new ModuleSpec("forged-alliance-veterancy", "Forged Alliance veterancy", ApplyVeterancy, "seraphim-ai"),
		new ModuleSpec("unit-presentation", "Forged Alliance unit portraits and names", ApplyUnitPresentation, "forged-alliance-veterancy", "cybran-hoplite", "aeon-acu", "aeon-projectile-visuals", "cybran-acu-projectiles"),
		new ModuleSpec("commander-enhancements", "Forged Alliance commander enhancements", ApplyCommanderEnhancements, "unit-presentation", "seraphim-fourth-faction", "aeon-acu", "guard-acu", "uef-acu", "cybran-acu-projectiles", "monkeylord", "fa-land-role-replacements", "fa-cybran-t3-roles")
	};

	public static void Apply()
	{
		IReadOnlyList<ModuleResult> readOnlyList = ModulePlan.Run(Modules);
		LogModuleSummary(readOnlyList);
		ModuleResult[] array = readOnlyList.Where((ModuleResult result) => CriticalModuleIds.Contains(result.Module.Id) && result.Status != ModuleStatus.Applied).ToArray();
		if (array.Length != 0)
		{
			throw new InvalidOperationException("Required SCOM cache modules failed: " + string.Join("; ", array.Select((ModuleResult result) => result.Module.Name + " (" + result.Detail + ")")));
		}
		if (readOnlyList.Where((ModuleResult result) => result.Status != ModuleStatus.Applied).ToArray().Length != 0)
		{
			Log("Continuing with applied modules; unavailable optional modules were isolated and Lua startup remains available.");
		}
	}

	private static void ApplyUefAcu()
	{
		UefAcuEdaCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyUefAcuEngineAudio()
	{
		UefAcuAudioCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyStructurePersistentAudio()
	{
		StructurePersistentAudioCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyEngineers()
	{
		GuardEdaEngineerCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyArtillery()
	{
		GuardCybranT3ArtilleryCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyStructures()
	{
		GuardCybranStructuresCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyEdaUefLandPower()
	{
		EdaUefLandPowerCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFatboy()
	{
		EdaUefFatboyCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyMonkeylord()
	{
		GuardCybranMonkeylordCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyGuardAcu()
	{
		GuardCybranAcuCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaAirScouts()
	{
		FaAirScoutCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaAirFighters()
	{
		FaAirFighterCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaCybranLandScout()
	{
		FaCybranLandScoutCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaAirFactories()
	{
		FaAirFactoryCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaAirBombers()
	{
		FaAirBomberCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaEngineerWaterAnimations()
	{
		FaEngineerWaterAnimationsCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaDirectStructures()
	{
		FaDirectStructuresCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyGuardAcuEngineAudio()
	{
		GuardCybranAcuAudioCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyCybranMantis()
	{
		CybranMantisCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyCybranHoplite()
	{
		CybranHopliteCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaArtilleryPair()
	{
		FaArtilleryPairCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaLandRoleReplacements()
	{
		FaLandRoleReplacementsCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyEdaUefPercival()
	{
		EdaUefPercivalCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaCybranHunter()
	{
		FaCybranHunterCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaCybranT3Roles()
	{
		FaCybranT3RolesCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaCybranEggProducts()
	{
		FaCybranEggProductsCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaCybranMegalith()
	{
		FaCybranMegalithCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaCybranScathis()
	{
		FaCybranScathisCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplySupportStructures()
	{
		FaSupportStructuresCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyCombatStructures()
	{
		FaCombatStructuresCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplySeraphimFourthFaction()
	{
		SeraphimFourthFactionCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyAeonChosenRoster()
	{
		AeonChosenRosterCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyFaAnimationClosure()
	{
		FaAnimationClosureCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyAeonAcu()
	{
		AeonChosenAcuCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyAeonProjectileVisuals()
	{
		AeonProjectileVisualsCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyCybranAcuProjectileVisuals()
	{
		CybranAcuProjectileVisualsCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyStructurePlacementContract()
	{
		StructurePlacementContractCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyConstructionPlans()
	{
		SanctuaryConstructionPlansCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplySeraphimAiCompatibility()
	{
		SeraphimAiCompatibilityCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyVeterancy()
	{
		SupremeCommanderVeterancyCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyUnitPresentation()
	{
		SupremeCommanderUnitPresentationCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void ApplyCommanderEnhancements()
	{
		CommanderEnhancementsCachePatcher.CachePatcherRuntime.Apply();
	}

	private static void LogModuleSummary(IEnumerable<ModuleResult> results)
	{
		ModuleResult[] results2 = results.ToArray();
		string text = FormatResults(results2, ModuleStatus.Applied);
		string text2 = FormatResults(results2, ModuleStatus.Failed);
		string text3 = FormatResults(results2, ModuleStatus.Skipped);
		Log("Module summary: applied=[" + text + "]; failed=[" + text2 + "]; skipped=[" + text3 + "].");
	}

	private static string FormatResults(IEnumerable<ModuleResult> results, ModuleStatus status)
	{
		string[] array = (from result in results
			where result.Status == status
			select (status != ModuleStatus.Applied) ? (result.Module.Name + " (" + result.Detail + ")") : result.Module.Name).ToArray();
		if (array.Length != 0)
		{
			return string.Join(", ", array);
		}
		return "none";
	}

	private static void Log(string message)
	{
		string text = "[Supreme Commander Overhaul Cache Patcher] " + message;
		Console.WriteLine(text);
		try
		{
			(from assembly in AppDomain.CurrentDomain.GetAssemblies()
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type type) => (object)type != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}
}
