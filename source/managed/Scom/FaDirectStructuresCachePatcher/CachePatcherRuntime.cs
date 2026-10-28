using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace FaDirectStructuresCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class PatchSpec
	{
		public string RelativePath { get; }

		public string Description { get; }

		public string Appendix { get; }

		private string[] StockTokens { get; }

		private string[] PatchedTokens { get; }

		public PatchSpec(string relativePath, string description, string appendix, string[] stockTokens, string[] patchedTokens)
		{
			RelativePath = relativePath;
			Description = description;
			Appendix = appendix;
			StockTokens = stockTokens;
			PatchedTokens = patchedTokens;
		}

		public void ValidateStock(string source)
		{
			if (ContainsOverride(source))
			{
				throw new InvalidOperationException(Description + " already contains this module's marker.");
			}
			RequireTokens(source, StockTokens);
		}

		public void ValidatePatched(string source)
		{
			RequireExactly(source, "-- Supreme Commander Overhaul FA Direct Structures 1.0.0", 1, Description + " marker");
			int startIndex = source.IndexOf("-- Supreme Commander Overhaul FA Direct Structures 1.0.0", StringComparison.Ordinal);
			RequireTokens(source.Substring(startIndex), PatchedTokens);
		}
	}

	private sealed class CacheResource
	{
		public string Path { get; }

		public object Stock { get; }

		public CacheResource(string path, object stock)
		{
			Path = path;
			Stock = stock;
		}
	}

	private sealed class CacheMutation
	{
		public string Path { get; }

		public object Stock { get; }

		public object Replacement { get; }

		public string Description { get; }

		public bool Assigned { get; set; }

		public CacheMutation(string path, object stock, object replacement, string description)
		{
			Path = path;
			Stock = stock;
			Replacement = replacement;
			Description = description;
		}
	}

	internal const string OverrideMarker = "-- Supreme Commander Overhaul FA Direct Structures 1.0.0";

	private const string StructuresMarker = "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1";

	private const string LoaderRelativePath = "LJ/lua/common/loading/unitTemplateLoader.lua";

	private const string HostBaseRelativePath = "LJ/lua/host/units/unitsClasses/unitsDefault.lua";

	private const string DirectTemplateAudioOverride = "\n-- FA sound banks are not part of the deterministic visual archive. Preserve\n-- only Sanctuary's faction-compatible destruction one-shot; never inherit an\n-- unrelated donor root loop or claim unavailable FA activation cues.\nUnitTemplate.additions.faSourceContract.audio = {\n    sourceBanksImported = false,\n    sourceActivationCuesSupported = false,\n    donorDestroyedOneShotRetained = UnitTemplate.audio ~= nil\n        and UnitTemplate.audio.onDestroyed ~= nil,\n    donorRootPersistentLoopRetained = false,\n}\nlocal SCO_DirectDestroyedAudio = UnitTemplate.audio and UnitTemplate.audio.onDestroyed\nUnitTemplate.audio = SCO_DirectDestroyedAudio\n    and { onDestroyed = SCO_DirectDestroyedAudio }\n    or nil";

	private const string UefMassFabricatorOverride = "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- Exact direct mapping: UEB1303 -> ues3603.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.rotators = {\n    {\n        boneName = \"Spinner\",\n        speed = { x = 0, y = 0, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"UEB1303 -> ues3603\",\n    sourceBlueprint = \"units/UEB1303/UEB1303_unit.bp\",\n    sourceBlueprintSha256 = \"fbb11aa62f87e520fea91e63f7f7f9bedb83fb1f2f59f7e78bd031522496ba4b\",\n    sourceScript = \"units/UEB1303/UEB1303_script.lua\",\n    sourceScriptSha256 = \"4377bad9f2c57249e54cca725bc6b201b6d287e6239dd1cb139f593ff1435bf7\",\n    sourceAdjacency = \"T3MassFabricatorAdjacencyBuffs\",\n    sanctuaryAdjacency = \"T3AlloyFabricatorAdjacencyBuff\",\n    sourceSkirtOffset = { x = -1.5, z = -1.5 },\n    sanctuarySkirtOffsetSupported = false,\n    spinner = { bone = \"Spinner\", axis = \"z\", targetSpeed = 40, acceleration = 10 },\n    sourceAmbientEmitter = \"/effects/emitters/uef_t3_massfab_ambient_01_emit.bp\",\n    sourceEmitterGraphSupported = false,\n}\nUnitTemplate.adjacency = \"T3AlloyFabricatorAdjacencyBuff\"\nUnitTemplate.general.class = { \"unitsDefaultEDA\", \"EDASupComMassFabricator\" }\nUnitTemplate.general.displayName = \"Mass Fabricator\"\nUnitTemplate.general.name = \"Mass Fabricator\"\nUnitTemplate.general.icon = { shape = \"structure1\", symbol = \"alloy\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_structure1_alloy.png\"\nUnitTemplate.general.toggles = { Production = true }\nUnitTemplate.tags = {\n    \"ALLOYS_PRODUCTION\", \"BUILDABLE_BY_T3_ENGINEER\", \"ECONOMIC\",\n    \"EDA\", \"STRUCTURE\", \"TECH3\",\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = -0.25, z = 0 },\n    collisionSize = { x = 1.75, y = 2.1, z = 1.875 },\n}\nUnitTemplate.footprint = { x = 3, y = 3 }\nUnitTemplate.skirtSize = { x = 6, y = 6 }\nUnitTemplate.defence.health = { max = 6000, regen = 0, value = 6000 }\nUnitTemplate.economy = {\n    buildTime = 3750,\n    cost = { alloys = 3000, energy = 65000 },\n    maintenanceConsumption = { energy = 3500 },\n    production = { alloys = 12 },\n}\nUnitTemplate.intel = { visionRadius = 20 }\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.selection = {\n    size = { x = 1.55, y = 1.55 },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.weapons = {\n    {\n        category = \"DeathExplosion\",\n        damage = 5000,\n        damageFriendly = true,\n        damageRadius = 14,\n        damageType = \"Normal\",\n    },\n}";

	private const string CybranMassFabricatorOverride = "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- Exact direct mapping: URB1303 -> ugs3603.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.rotators = {\n    {\n        boneName = \"Spinner\",\n        speed = { x = 0, y = 0, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URB1303 -> ugs3603\",\n    sourceBlueprint = \"units/URB1303/URB1303_unit.bp\",\n    sourceBlueprintSha256 = \"bf7930986d1b416fc4db68e070f4b1249d2edce04c82415c03791f62ab79ae75\",\n    sourceScript = \"units/URB1303/URB1303_script.lua\",\n    sourceScriptSha256 = \"5a29e3fb5be7a66c892cfaa23021777d4773be82a7fa00abf20dd302eac35400\",\n    sourceAdjacency = \"T3MassFabricatorAdjacencyBuffs\",\n    sanctuaryAdjacency = \"T3AlloyFabricatorAdjacencyBuff\",\n    sourceSkirtOffset = { x = -1.5, z = -1.5 },\n    sanctuarySkirtOffsetSupported = false,\n    spinner = { bone = \"Spinner\", axis = \"z\", targetSpeed = 60, acceleration = 10 },\n}\nUnitTemplate.adjacency = \"T3AlloyFabricatorAdjacencyBuff\"\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardSupComMassFabricator\" }\nUnitTemplate.general.displayName = \"Mass Fabricator\"\nUnitTemplate.general.name = \"Mass Fabricator\"\nUnitTemplate.general.icon = { shape = \"structure1\", symbol = \"alloy\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_structure1_alloy.png\"\nUnitTemplate.general.toggles = { Production = true }\nUnitTemplate.tags = {\n    \"ALLOYS_PRODUCTION\", \"BUILDABLE_BY_T3_ENGINEER\", \"ECONOMIC\",\n    \"GUARD\", \"STRUCTURE\", \"TECH3\",\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = -0.25, z = 0 },\n    collisionSize = { x = 1.3, y = 3.2, z = 1.3 },\n}\nUnitTemplate.footprint = { x = 3, y = 3 }\nUnitTemplate.skirtSize = { x = 6, y = 6 }\nUnitTemplate.defence.health = { max = 6000, regen = 0, value = 6000 }\nUnitTemplate.economy = {\n    buildTime = 3750,\n    cost = { alloys = 3000, energy = 65000 },\n    maintenanceConsumption = { energy = 3500 },\n    production = { alloys = 12 },\n}\nUnitTemplate.intel = { visionRadius = 20 }\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.selection = {\n    size = { x = 1.55, y = 1.55 },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.weapons = {\n    {\n        category = \"DeathExplosion\",\n        damage = 5000,\n        damageFriendly = true,\n        damageRadius = 14,\n        damageType = \"Normal\",\n    },\n}";

	private const string UefKennelT2Override = "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- Direct source: XEB0104 The Kennel -> ues2501.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = { \"AttachSpecial01\", \"AttachSpecial02\" }\nUnitTemplate.additions.progressBoundUpgradeAnimation = {\n    animationKey = \"upgrade\",\n    durationSeconds = 0.8333333134651184,\n    restAnimationKey = \"walk\",\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"XEB0104 -> ues2501\",\n    sourceBlueprintSha256 = \"2052c14d35cc2772d23e5bf429a4457204c37745b3fa5e6ab22b0adeaf73bc37\",\n    sourceScriptSha256 = \"00d4ff0aa2f10cfb5addce51f3783a08a7b229ffe388bf84a270403301f2f3f2\",\n    sourceSkirtOffset = { x = -0.5, z = -0.5 },\n    sanctuarySkirtOffsetSupported = false,\n    sourcePod = { id = \"XEA3204\", attach = \"AttachSpecial01\", createWithUnit = true },\n    sanctuaryPodRuntimeSupported = false,\n    sanctuaryDirectBuildCompatibility = true,\n    podOpen = { sourceRate = 2, holdSeconds = 0.5, clip = \"AnimPodOpen\" },\n    podResume = { sourceRate = 1.5, clip = \"AnimPodResume\" },\n}\nUnitTemplate.general.class = { \"unitsDefaultEDA\", \"EDASupComKennelT2\" }\nUnitTemplate.general.displayName = \"The Kennel\"\nUnitTemplate.general.name = \"The Kennel\"\nUnitTemplate.general.icon = { shape = \"structure1\", symbol = \"engineer\", tech = \"t2\" }\nUnitTemplate.general.iconUI = \"tech2_structure1_engineer.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 200\nUnitTemplate.tags = {\n    \"BUILDABLE_BY_T2_ENGINEER\", \"BUILDABLE_BY_T3_ENGINEER\", \"CONSTRUCTION\",\n    \"EDA\", \"ENGINEERING_STATION\", \"LAND\", \"STRUCTURE\", \"TECH2\",\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0, z = 0 },\n    collisionSize = { x = 0.7, y = 0.8, z = 0.7 },\n}\nUnitTemplate.footprint = { x = 1, y = 1 }\nUnitTemplate.skirtSize = { x = 2, y = 2 }\nUnitTemplate.defence.health = { max = 1000, regen = 0, value = 1000 }\nUnitTemplate.economy = {\n    buildTime = 1100,\n    cost = { alloys = 550, energy = 2750 },\n}\nUnitTemplate.intel = { visionRadius = 15 }\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.buildPower = 20\nUnitTemplate.construction.range = 15\nUnitTemplate.construction.canBuild = \"Tags.EDA * Tags.BUILDABLE_BY_T2_ENGINEER\"\nUnitTemplate.construction.upgradesTo = \"ues3501\"\nUnitTemplate.visuals.animations = {\n    walk = { clipName = \"Rest\", sanAnimationPath = \"Units/ues2501/LOD0/ues2501.sananimation\" },\n    podOpen = { clipName = \"AnimPodOpen\", sanAnimationPath = \"Units/ues2501/LOD0/ues2501.sananimation\", playbackMode = 0 },\n    podResume = { clipName = \"AnimPodResume\", sanAnimationPath = \"Units/ues2501/LOD0/ues2501.sananimation\", playbackMode = 0 },\n    upgrade = { clipName = \"AnimUpgrade\", sanAnimationPath = \"Units/ues2501/LOD0/ues2501.sananimation\", playbackMode = 0 },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.selection = {\n    size = { x = 0.65, y = 0.6 },\n    offset = { x = 0, y = 0, z = 0 },\n}";

	private const string UefKennelT3Override = "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- Direct source: XEB0204 The Kennel -> ues3501.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = { \"AttachSpecial01\", \"AttachSpecial02\" }\nUnitTemplate.additions.progressBoundUpgradeAnimation = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"XEB0204 -> ues3501\",\n    sourceBlueprintSha256 = \"c7bca76130a5892b252464a8dc65f08e15da385bc3f0e7dcbbe873d60ca40ba8\",\n    sourceScriptSha256 = \"e944e2bbe6bdd0dce936a2cacdabf1fd29add88c81fbb6d1ecfc599ca17749fa\",\n    sourceSelectionCenterOffsetZ = 0.1,\n    sanctuarySouthFacingSelectionOffsetZ = -0.1,\n    sourceSkirtOffset = { x = -0.5, z = -0.5 },\n    sanctuarySkirtOffsetSupported = false,\n    sourcePods = {\n        { id = \"XEA3204\", attach = \"AttachSpecial01\" },\n        { id = \"XEA3204\", attach = \"AttachSpecial02\" },\n    },\n    sanctuaryPodRuntimeSupported = false,\n    sanctuaryDirectBuildCompatibility = true,\n    completionOpen = { sourceRate = 0.4, durationSeconds = 5, clip = \"AnimOpen\" },\n}\nUnitTemplate.general.class = { \"unitsDefaultEDA\", \"EDASupComKennelT3\" }\nUnitTemplate.general.displayName = \"The Kennel\"\nUnitTemplate.general.name = \"The Kennel\"\nUnitTemplate.general.icon = { shape = \"structure1\", symbol = \"engineer\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_structure1_engineer.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 200\n-- XEB0204 is upgrade-only; retain the Sanctuary TECH3 identity but do not\n-- expose the terminal target as a separately buildable structure.\nUnitTemplate.tags = {\n    \"CONSTRUCTION\", \"EDA\", \"ENGINEERING_STATION\", \"LAND\", \"STRUCTURE\", \"TECH3\",\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = -0.25, z = 0 },\n    collisionSize = { x = 1, y = 1.8, z = 1 },\n}\nUnitTemplate.footprint = { x = 1, y = 1 }\nUnitTemplate.skirtSize = { x = 2, y = 2 }\nUnitTemplate.defence.health = { max = 3000, regen = 0, value = 3000 }\nUnitTemplate.economy = {\n    buildTime = 2000,\n    cost = { alloys = 500, energy = 2500 },\n}\nUnitTemplate.intel = { visionRadius = 15 }\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.buildPower = 20\nUnitTemplate.construction.range = 20\nUnitTemplate.construction.canBuild = \"Tags.EDA * Tags.BUILDABLE_BY_T3_ENGINEER\"\nUnitTemplate.construction.upgradesTo = nil\nUnitTemplate.visuals.animations = {\n    walk = { clipName = \"Rest\", sanAnimationPath = \"Units/ues3501/LOD0/ues3501.sananimation\" },\n    open = { clipName = \"AnimOpen\", sanAnimationPath = \"Units/ues3501/LOD0/ues3501.sananimation\", playbackMode = 0 },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.selection = {\n    size = { x = 0.65, y = 0.6 },\n    offset = { x = 0, y = 0, z = -0.1 },\n}";

	private const string CybranHiveT2Override = "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- Direct source: XRB0104 The Hive -> ugs2501.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = { \"Attachpoint01\" }\nUnitTemplate.additions.progressBoundUpgradeAnimation = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"XRB0104 -> ugs2501\",\n    sourceBlueprintSha256 = \"33df9d71506323628c40288aaf5df5ce6bea3f90ee7b176232ca1ed253580a05\",\n    sourceScriptSha256 = \"f4a5ce558e59e30e8866c35977f7badc154d1a5951c7a6c07905d4fc36a8432c\",\n    sourceUpgradesTo = \"XRB0204\",\n    substitutedTerminalTarget = \"ugs3501/XRB0304\",\n    sourceSkirtOffset = { x = -0.5, z = -0.5 },\n    sanctuarySkirtOffsetSupported = false,\n    closeClipIsBakedReverse = true,\n    midClipReverseContinuitySupported = false,\n}\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardSupComHiveT2\" }\nUnitTemplate.general.displayName = \"The Hive\"\nUnitTemplate.general.name = \"The Hive\"\nUnitTemplate.general.icon = { shape = \"structure1\", symbol = \"engineer\", tech = \"t2\" }\nUnitTemplate.general.iconUI = \"tech2_structure1_engineer.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 200\nUnitTemplate.tags = {\n    \"BUILDABLE_BY_T2_ENGINEER\", \"BUILDABLE_BY_T3_ENGINEER\", \"CONSTRUCTION\",\n    \"ENGINEERING_STATION\", \"GUARD\", \"LAND\", \"STRUCTURE\", \"TECH2\",\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = -0.25, z = 0 },\n    collisionSize = { x = 1.2, y = 1.6, z = 1.2 },\n}\nUnitTemplate.footprint = { x = 1, y = 1 }\nUnitTemplate.skirtSize = { x = 2, y = 2 }\nUnitTemplate.defence.health = { max = 500, regen = 0, value = 500 }\nUnitTemplate.economy = {\n    buildTime = 900,\n    cost = { alloys = 500, energy = 2500 },\n}\nUnitTemplate.intel = { visionRadius = 15 }\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.buildPower = 15\nUnitTemplate.construction.range = 15\nUnitTemplate.construction.canBuild = \"Tags.GUARD * Tags.BUILDABLE_BY_T2_ENGINEER\"\nUnitTemplate.construction.upgradesTo = \"ugs3501\"\nUnitTemplate.visuals.animations = {\n    walk = { clipName = \"Rest\", sanAnimationPath = \"Units/ugs2501/LOD0/ugs2501.sananimation\" },\n    open = { clipName = \"AnimOpen\", sanAnimationPath = \"Units/ugs2501/LOD0/ugs2501.sananimation\", playbackMode = 0 },\n    close = { clipName = \"AnimClose\", sanAnimationPath = \"Units/ugs2501/LOD0/ugs2501.sananimation\", playbackMode = 0 },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.selection = {\n    size = { x = 1, y = 1 },\n    offset = { x = 0, y = 0, z = 0 },\n}";

	private const string CybranHiveFinalOverride = "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- Terminal progression source: XRB0304 The Hive -> ugs3501.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = { \"Attachpoint01\", \"Attachpoint02\", \"Attachpoint03\" }\nUnitTemplate.additions.progressBoundUpgradeAnimation = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"XRB0304 -> ugs3501\",\n    sourceBlueprintSha256 = \"d2fc5fa9de2105259bf66ee88b20b271e11c4ddae34420df2383d67baa90b701\",\n    sourceScriptSha256 = \"3cc97747f900596d50c06565fd4682ca70bd8d870d49a9e0d664a93ea8e7d5be\",\n    terminalProgressionSubstitution = true,\n    sourceTechCategory = \"TECH2\",\n    sanctuaryPublicTechCategory = \"TECH3\",\n    sourceUpgradesFrom = \"XRB0204\",\n    sanctuaryUpgradesFrom = \"ugs2501/XRB0104\",\n    sourceSkirtOffset = { x = -0.5, z = -0.5 },\n    sanctuarySkirtOffsetSupported = false,\n    staticallyVisibleMeshBones = { \"TurretT3\", \"B03\", \"Door3_B03\" },\n    closeClipIsBakedReverse = true,\n    midClipReverseContinuitySupported = false,\n}\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardSupComHiveFinal\" }\nUnitTemplate.general.displayName = \"The Hive\"\nUnitTemplate.general.name = \"The Hive\"\nUnitTemplate.general.icon = { shape = \"structure1\", symbol = \"engineer\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_structure1_engineer.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 200\nUnitTemplate.tags = {\n    \"CONSTRUCTION\", \"ENGINEERING_STATION\", \"GUARD\", \"LAND\", \"STRUCTURE\", \"TECH3\",\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = -0.25, z = 0 },\n    collisionSize = { x = 1.2, y = 2.6, z = 1.3 },\n}\nUnitTemplate.footprint = { x = 1, y = 1 }\nUnitTemplate.skirtSize = { x = 2, y = 2 }\nUnitTemplate.defence.health = { max = 2750, regen = 0, value = 2750 }\nUnitTemplate.economy = {\n    buildTime = 2400,\n    cost = { alloys = 240, energy = 1600 },\n}\nUnitTemplate.intel = { visionRadius = 15 }\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.buildPower = 35\nUnitTemplate.construction.range = 25\nUnitTemplate.construction.canBuild = \"Tags.GUARD * Tags.BUILDABLE_BY_T3_ENGINEER\"\nUnitTemplate.construction.upgradesTo = nil\nUnitTemplate.visuals.animations = {\n    walk = { clipName = \"Rest\", sanAnimationPath = \"Units/ugs3501/LOD0/ugs3501.sananimation\" },\n    open = { clipName = \"AnimOpen\", sanAnimationPath = \"Units/ugs3501/LOD0/ugs3501.sananimation\", playbackMode = 0 },\n    close = { clipName = \"AnimClose\", sanAnimationPath = \"Units/ugs3501/LOD0/ugs3501.sananimation\", playbackMode = 0 },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.selection = {\n    size = { x = 1, y = 1 },\n    offset = { x = 0, y = 0, z = 0 },\n}";

	private const string CybranShieldFinalOverride = "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- Terminal ED5 progression source: URB4207 -> ugs3401.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.rotators = {\n    {\n        boneName = \"Shaft\",\n        speed = { x = 0, y = 0, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n}\nUnitTemplate.additions.progressBoundUpgradeAnimation = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URB4207 -> ugs3401\",\n    sourceBlueprintSha256 = \"7442a10729ab814418f0201aed463b1acda55a8dc135ead974b399d709e210e3\",\n    sourceScriptSha256 = \"357879b75e0d17dfd9330fa72efa5c2dc69d085aaa1573dcd9b543f95e86ea49\",\n    terminalProgressionSubstitution = true,\n    sourceTechCategory = \"TECH2\",\n    sanctuaryPublicTechCategory = \"TECH3\",\n    sourceUpgradesFrom = \"URB4206\",\n    sanctuaryUpgradesFrom = \"ugs2401\",\n    sourceShieldSizeDiameter = 40,\n    sanctuaryShieldRadius = 20,\n    sourceShieldEnergyDrainRechargeTime = 5,\n    sanctuaryEnergyDrainRechargeTimeSupported = false,\n    sourceRegenAssistMultiplier = 60,\n    sanctuaryRegenAssistMultiplierSupported = false,\n    sourceSkirtOffset = { x = -2.5, z = -2.5 },\n    sanctuarySkirtOffsetSupported = false,\n    spinner = { bone = \"Shaft\", axis = \"z\", initialSpeed = 30, enabledSpeed = 10, acceleration = 5, maximumSpeed = 30 },\n    terminalAopen = { clip = \"AnimUpgrade\", frames = 161, durationSeconds = 5.333333492279053, sourceBound = false },\n    sourceEmitterGraphSupported = false,\n}\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardSupComShieldFinal\" }\nUnitTemplate.general.displayName = \"ED5\"\nUnitTemplate.general.name = \"ED5\"\nUnitTemplate.general.icon = { shape = \"structure1\", symbol = \"shield\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_structure1_shield.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 160\nUnitTemplate.general.toggles = { Shield = true }\nUnitTemplate.tags = { \"DEFENCE\", \"GUARD\", \"SHIELD\", \"STRUCTURE\", \"TECH3\" }\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = -0.25, z = 0 },\n    collisionSize = { x = 2, y = 5, z = 2 },\n}\nUnitTemplate.footprint = { x = 1, y = 1 }\nUnitTemplate.skirtSize = { x = 6, y = 6 }\nUnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = { max = 500, regen = 0, value = 500 }\nlocal SCO_ED5Shield = UnitTemplate.defence.shields and UnitTemplate.defence.shields[1] or {}\nUnitTemplate.defence.shields = { SCO_ED5Shield }\nSCO_ED5Shield.boneName = \"Root\"\nSCO_ED5Shield.max = 14000\nSCO_ED5Shield.value = 14000\nSCO_ED5Shield.name = \"Bubble Shield\"\nSCO_ED5Shield.offset = { x = 0, y = -6, z = 0 }\nSCO_ED5Shield.radii = { x = 20, y = 20, z = 20 }\nSCO_ED5Shield.rechargeHPRatio = 0.5\nSCO_ED5Shield.rechargeTime = 22\nSCO_ED5Shield.regen = 140\nSCO_ED5Shield.regenDelay = 1\nSCO_ED5Shield.type = 0\nSCO_ED5Shield.effectsPersistent = nil\n-- URB4207 has ShieldOn/ShieldOff one-shots, not the donor's continuous shield\n-- hum. Its FA bank is unavailable, so remove that false persistent owner.\nSCO_ED5Shield.audio = nil\nUnitTemplate.economy = {\n    buildTime = 1600,\n    cost = { alloys = 2400, energy = 40000 },\n    maintenanceConsumption = { energy = 500 },\n}\nUnitTemplate.intel = { visionRadius = 20 }\nUnitTemplate.visuals.animations = {\n    walk = { clipName = \"Rest\", sanAnimationPath = \"Units/ugs3401/LOD0/ugs3401.sananimation\" },\n    terminalOpen = { clipName = \"AnimUpgrade\", sanAnimationPath = \"Units/ugs3401/LOD0/ugs3401.sananimation\", playbackMode = 0 },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.selection = {\n    size = { x = 2.2, y = 2.2 },\n    offset = { x = 0, y = 0, z = 0 },\n}";

	private const string EdaHostClassesOverride = "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\nlocal SCO_EDAAlloyExtractor = HostEDAAlloyExtractor or EDAAlloyExtractor\nlocal SCO_EDAEngineeringStation = HostEDAEngineeringStation or EDAEngineeringStation\nif not SCO_EDAAlloyExtractor or not SCO_EDAEngineeringStation then\n    error(\"SCO direct structures could not resolve host EDA bases.\")\nend\n\nlocal function SCO_FabricatorIsActive(self)\n    return self:IsCompleted()\n        and self:GetProductionToggle()\n        and not self.army.economy.isEnergyDown\nend\n\nHostEDASupComMassFabricator = Class(\"EDASupComMassFabricator\", SCO_EDAAlloyExtractor)\nlocal EDASupComMassFabricator = HostEDASupComMassFabricator\n\nfunction EDASupComMassFabricator:RotatorsEnabledOnConstruction()\n    return false\nend\n\nfunction EDASupComMassFabricator:SCOSetFabricatorRotorTarget(targetSpeed)\n    if self.scoFabricatorRotorTarget == targetSpeed and self.scoFabricatorRotorThread then\n        return\n    end\n    if self.scoFabricatorRotorThread then\n        KillThread(self.scoFabricatorRotorThread)\n    end\n    self.scoFabricatorRotorTarget = targetSpeed\n    self.scoFabricatorRotorThread = self:NewThread(self.SCOFabricatorRotorRampThread, targetSpeed)\nend\n\nfunction EDASupComMassFabricator:SCOFabricatorRotorRampThread(targetSpeed)\n    local rotor = self.rotatorIds and self.rotatorIds[1]\n    if not rotor then\n        error(\"UEB1303 Spinner rotator is missing.\")\n    end\n    local speed = self.scoFabricatorRotorSpeed or 0\n    self:SetRotatorsEnabled(true)\n    while not self.dead and math.abs(targetSpeed - speed) > 0.000001 do\n        local delta = math.min(math.abs(targetSpeed - speed), 1)\n        speed = speed + (targetSpeed > speed and delta or -delta)\n        self.scoFabricatorRotorSpeed = speed\n        Engine.SetRotatorSpeed(rotor, EngineClasses.float3(0, 0, speed))\n        WaitSeconds(0.1)\n    end\n    if targetSpeed == 0 then\n        self:SetRotatorsEnabled(false)\n    end\n    self.scoFabricatorRotorThread = nil\nend\n\nfunction EDASupComMassFabricator:CheckProductionState()\n    local active = SCO_FabricatorIsActive(self)\n    if self.resourceEntities.production then\n        self.resourceEntities.production:SetEnabled(active)\n    end\n    if self.rotatorIds and self.rotatorIds[1] then\n        self:SCOSetFabricatorRotorTarget(active and 40 or 0)\n    end\nend\n\nfunction EDASupComMassFabricator:OnStopBeingBuilt()\n    SCO_EDAAlloyExtractor.OnStopBeingBuilt(self)\n    self:CheckProductionState()\nend\n\nfunction EDASupComMassFabricator:OnEnergyDown()\n    SCO_EDAAlloyExtractor.OnEnergyDown(self)\n    self:CheckProductionState()\nend\n\nfunction EDASupComMassFabricator:OnEnergyUp()\n    SCO_EDAAlloyExtractor.OnEnergyUp(self)\n    self:CheckProductionState()\nend\n\nHostEDASupComKennelT2 = Class(\"EDASupComKennelT2\", SCO_EDAEngineeringStation)\nlocal EDASupComKennelT2 = HostEDASupComKennelT2\n\nfunction EDASupComKennelT2:UpdateAnimations()\nend\n\nfunction EDASupComKennelT2:OnStartBuildRoutine(targetUnit)\n    SCO_EDAEngineeringStation.OnStartBuildRoutine(self, targetUnit)\n    if self:IsUpgrading() or self.scoKennelPodOpen then\n        return\n    end\n    local animation = self.tp.visuals.animations.podOpen\n    self.scoKennelPodOpen = true\n    Engine.PlayAnimation(self.id, animation.id, 0.1)\nend\n\nfunction EDASupComKennelT2:OnStopBuildRoutine(targetUnit)\n    SCO_EDAEngineeringStation.OnStopBuildRoutine(self, targetUnit)\n    if self:IsUpgrading() or not self.scoKennelPodOpen then\n        return\n    end\n    local animation = self.tp.visuals.animations.podResume\n    self.scoKennelPodOpen = false\n    Engine.PlayAnimation(self.id, animation.id, 0.1)\nend\n\nHostEDASupComKennelT3 = Class(\"EDASupComKennelT3\", SCO_EDAEngineeringStation)\nlocal EDASupComKennelT3 = HostEDASupComKennelT3\n\nfunction EDASupComKennelT3:UpdateAnimations()\nend\n\nfunction EDASupComKennelT3:OnStopBeingBuilt()\n    SCO_EDAEngineeringStation.OnStopBeingBuilt(self)\n    local animation = self.tp.visuals.animations.open\n    Engine.PlayAnimation(self.id, animation.id, 0.1)\nend";

	private const string EdaClientClassesOverride = "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\nlocal SCO_EDAAlloyExtractor = ClientEDAAlloyExtractor or EDAAlloyExtractor\nlocal SCO_EDAEngineeringStation = ClientEDAEngineeringStation or EDAEngineeringStation\nif not SCO_EDAAlloyExtractor or not SCO_EDAEngineeringStation then\n    error(\"SCO direct structures could not resolve client EDA bases.\")\nend\nClientEDASupComMassFabricator = Class(\"EDASupComMassFabricator\", SCO_EDAAlloyExtractor)\nClientEDASupComKennelT2 = Class(\"EDASupComKennelT2\", SCO_EDAEngineeringStation)\nClientEDASupComKennelT3 = Class(\"EDASupComKennelT3\", SCO_EDAEngineeringStation)";

	private const string GuardHostClassesOverride = "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\nlocal SCO_GuardStructure = HostGuardStructure or GuardStructure\nlocal SCO_GuardAlloyExtractor = HostGuardAlloyExtractor or GuardAlloyExtractor\nlocal SCO_GuardEngineeringStation = HostGuardEngineeringStation or GuardEngineeringStation\nif not SCO_GuardStructure or not SCO_GuardAlloyExtractor or not SCO_GuardEngineeringStation then\n    error(\"SCO direct structures could not resolve host Guard bases.\")\nend\n\nlocal function SCO_GuardFabricatorIsActive(self)\n    return self:IsCompleted()\n        and self:GetProductionToggle()\n        and not self.army.economy.isEnergyDown\nend\n\nHostGuardSupComMassFabricator = Class(\"GuardSupComMassFabricator\", SCO_GuardAlloyExtractor)\nlocal GuardSupComMassFabricator = HostGuardSupComMassFabricator\n\nfunction GuardSupComMassFabricator:RotatorsEnabledOnConstruction()\n    return false\nend\n\nfunction GuardSupComMassFabricator:SCOSetFabricatorRotorTarget(targetSpeed)\n    if self.scoFabricatorRotorTarget == targetSpeed and self.scoFabricatorRotorThread then\n        return\n    end\n    if self.scoFabricatorRotorThread then\n        KillThread(self.scoFabricatorRotorThread)\n    end\n    self.scoFabricatorRotorTarget = targetSpeed\n    self.scoFabricatorRotorThread = self:NewThread(self.SCOFabricatorRotorRampThread, targetSpeed)\nend\n\nfunction GuardSupComMassFabricator:SCOFabricatorRotorRampThread(targetSpeed)\n    local rotor = self.rotatorIds and self.rotatorIds[1]\n    if not rotor then\n        error(\"URB1303 Spinner rotator is missing.\")\n    end\n    local speed = self.scoFabricatorRotorSpeed or 0\n    self:SetRotatorsEnabled(true)\n    while not self.dead and math.abs(targetSpeed - speed) > 0.000001 do\n        local delta = math.min(math.abs(targetSpeed - speed), 1)\n        speed = speed + (targetSpeed > speed and delta or -delta)\n        self.scoFabricatorRotorSpeed = speed\n        Engine.SetRotatorSpeed(rotor, EngineClasses.float3(0, 0, speed))\n        WaitSeconds(0.1)\n    end\n    if targetSpeed == 0 then\n        self:SetRotatorsEnabled(false)\n    end\n    self.scoFabricatorRotorThread = nil\nend\n\nfunction GuardSupComMassFabricator:CheckProductionState()\n    local active = SCO_GuardFabricatorIsActive(self)\n    if self.resourceEntities.production then\n        self.resourceEntities.production:SetEnabled(active)\n    end\n    if self.rotatorIds and self.rotatorIds[1] then\n        self:SCOSetFabricatorRotorTarget(active and 60 or 0)\n    end\nend\n\nfunction GuardSupComMassFabricator:OnStopBeingBuilt()\n    SCO_GuardAlloyExtractor.OnStopBeingBuilt(self)\n    self:CheckProductionState()\nend\n\nfunction GuardSupComMassFabricator:OnEnergyDown()\n    SCO_GuardAlloyExtractor.OnEnergyDown(self)\n    self:CheckProductionState()\nend\n\nfunction GuardSupComMassFabricator:OnEnergyUp()\n    SCO_GuardAlloyExtractor.OnEnergyUp(self)\n    self:CheckProductionState()\nend\n\nlocal function SCO_PlayGuardStationAnimation(self, key)\n    local animation = self.tp.visuals.animations[key]\n    Engine.PlayAnimation(self.id, animation.id, 0.1)\nend\n\nHostGuardSupComHiveT2 = Class(\"GuardSupComHiveT2\", SCO_GuardEngineeringStation)\nlocal GuardSupComHiveT2 = HostGuardSupComHiveT2\n\nfunction GuardSupComHiveT2:UpdateAnimations()\nend\n\nfunction GuardSupComHiveT2:OnStartBuildRoutine(targetUnit)\n    SCO_GuardEngineeringStation.OnStartBuildRoutine(self, targetUnit)\n    SCO_PlayGuardStationAnimation(self, \"open\")\nend\n\nfunction GuardSupComHiveT2:OnStopBuildRoutine(targetUnit)\n    SCO_GuardEngineeringStation.OnStopBuildRoutine(self, targetUnit)\n    SCO_PlayGuardStationAnimation(self, \"close\")\nend\n\nHostGuardSupComHiveFinal = Class(\"GuardSupComHiveFinal\", SCO_GuardEngineeringStation)\nlocal GuardSupComHiveFinal = HostGuardSupComHiveFinal\n\nfunction GuardSupComHiveFinal:UpdateAnimations()\nend\n\nfunction GuardSupComHiveFinal:OnStartBuildRoutine(targetUnit)\n    SCO_GuardEngineeringStation.OnStartBuildRoutine(self, targetUnit)\n    SCO_PlayGuardStationAnimation(self, \"open\")\nend\n\nfunction GuardSupComHiveFinal:OnStopBuildRoutine(targetUnit)\n    SCO_GuardEngineeringStation.OnStopBuildRoutine(self, targetUnit)\n    SCO_PlayGuardStationAnimation(self, \"close\")\nend\n\nHostGuardSupComShieldFinal = Class(\"GuardSupComShieldFinal\", SCO_GuardStructure)\nlocal GuardSupComShieldFinal = HostGuardSupComShieldFinal\n\nfunction GuardSupComShieldFinal:UpdateAnimations()\nend\n\nfunction GuardSupComShieldFinal:SCOSetShieldRotorTarget(targetSpeed)\n    if self.scoShieldRotorTarget == targetSpeed and self.scoShieldRotorThread then\n        return\n    end\n    if self.scoShieldRotorThread then\n        KillThread(self.scoShieldRotorThread)\n    end\n    self.scoShieldRotorTarget = targetSpeed\n    self.scoShieldRotorThread = self:NewThread(self.SCOShieldRotorRampThread, targetSpeed)\nend\n\nfunction GuardSupComShieldFinal:SCOShieldRotorRampThread(targetSpeed)\n    local rotor = self.rotatorIds and self.rotatorIds[1]\n    if not rotor then\n        error(\"URB4207 Shaft rotator is missing.\")\n    end\n    local speed = self.scoShieldRotorSpeed or 0\n    self:SetRotatorsEnabled(true)\n    while not self.dead and math.abs(targetSpeed - speed) > 0.000001 do\n        local delta = math.min(math.abs(targetSpeed - speed), 0.5)\n        speed = speed + (targetSpeed > speed and delta or -delta)\n        self.scoShieldRotorSpeed = speed\n        Engine.SetRotatorSpeed(rotor, EngineClasses.float3(0, 0, speed))\n        WaitSeconds(0.1)\n    end\n    if targetSpeed == 0 then\n        self:SetRotatorsEnabled(false)\n    end\n    self.scoShieldRotorThread = nil\nend\n\nfunction GuardSupComShieldFinal:SCOOnDirectShieldEnabledChanged(enabled)\n    if not self.scoShieldRotorReady then\n        return\n    end\n    self:SCOSetShieldRotorTarget(enabled and 10 or 0)\nend\n\nfunction GuardSupComShieldFinal:OnStopBeingBuilt()\n    SCO_GuardStructure.OnStopBeingBuilt(self)\n    local rotor = self.rotatorIds and self.rotatorIds[1]\n    if not rotor then\n        error(\"URB4207 Shaft rotator is missing after construction.\")\n    end\n    self.scoShieldRotorReady = true\n    local active = self:GetShieldToggle() and not self.army.economy.isEnergyDown\n    local initialSpeed = active and 30 or 0\n    self.scoShieldRotorSpeed = initialSpeed\n    self.scoShieldRotorTarget = initialSpeed\n    Engine.SetRotatorSpeed(rotor, EngineClasses.float3(0, 0, initialSpeed))\n    self:SetRotatorsEnabled(active)\nend";

	private const string HostShieldOverride = "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- URB4207 drives its Shaft from actual shield transitions, matching the\n-- source OnShieldDisabled/OnShieldEnabled lifecycle across damage recharge,\n-- manual toggle, and power loss. Delegate every non-target shield unchanged.\nlocal SCO_DirectStructureStockShieldSetEnabled = HostShield.SetEnabled\nfunction HostShield:SetEnabled(value)\n    local wasEnabled = self.enabled\n    SCO_DirectStructureStockShieldSetEnabled(self, value)\n    if self.enabled == wasEnabled then\n        return\n    end\n    local owner = self.owner\n    if owner\n        and owner.tpId == \"ugs3401\"\n        and owner.SCOOnDirectShieldEnabledChanged then\n        owner:SCOOnDirectShieldEnabledChanged(self.enabled)\n    end\nend";

	private const string GuardClientClassesOverride = "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\nlocal SCO_GuardStructure = ClientGuardStructure or GuardStructure\nlocal SCO_GuardAlloyExtractor = ClientGuardAlloyExtractor or GuardAlloyExtractor\nlocal SCO_GuardEngineeringStation = ClientGuardEngineeringStation or GuardEngineeringStation\nif not SCO_GuardStructure or not SCO_GuardAlloyExtractor or not SCO_GuardEngineeringStation then\n    error(\"SCO direct structures could not resolve client Guard bases.\")\nend\nClientGuardSupComMassFabricator = Class(\"GuardSupComMassFabricator\", SCO_GuardAlloyExtractor)\nClientGuardSupComHiveT2 = Class(\"GuardSupComHiveT2\", SCO_GuardEngineeringStation)\nClientGuardSupComHiveFinal = Class(\"GuardSupComHiveFinal\", SCO_GuardEngineeringStation)\nClientGuardSupComShieldFinal = Class(\"GuardSupComShieldFinal\", SCO_GuardStructure)";

	private static readonly PatchSpec[] Specs = new PatchSpec[12]
	{
		Template("ues3603", "UEB1303 mass fabricator", "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- Exact direct mapping: UEB1303 -> ues3603.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.rotators = {\n    {\n        boneName = \"Spinner\",\n        speed = { x = 0, y = 0, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"UEB1303 -> ues3603\",\n    sourceBlueprint = \"units/UEB1303/UEB1303_unit.bp\",\n    sourceBlueprintSha256 = \"fbb11aa62f87e520fea91e63f7f7f9bedb83fb1f2f59f7e78bd031522496ba4b\",\n    sourceScript = \"units/UEB1303/UEB1303_script.lua\",\n    sourceScriptSha256 = \"4377bad9f2c57249e54cca725bc6b201b6d287e6239dd1cb139f593ff1435bf7\",\n    sourceAdjacency = \"T3MassFabricatorAdjacencyBuffs\",\n    sanctuaryAdjacency = \"T3AlloyFabricatorAdjacencyBuff\",\n    sourceSkirtOffset = { x = -1.5, z = -1.5 },\n    sanctuarySkirtOffsetSupported = false,\n    spinner = { bone = \"Spinner\", axis = \"z\", targetSpeed = 40, acceleration = 10 },\n    sourceAmbientEmitter = \"/effects/emitters/uef_t3_massfab_ambient_01_emit.bp\",\n    sourceEmitterGraphSupported = false,\n}\nUnitTemplate.adjacency = \"T3AlloyFabricatorAdjacencyBuff\"\nUnitTemplate.general.class = { \"unitsDefaultEDA\", \"EDASupComMassFabricator\" }\nUnitTemplate.general.displayName = \"Mass Fabricator\"\nUnitTemplate.general.name = \"Mass Fabricator\"\nUnitTemplate.general.icon = { shape = \"structure1\", symbol = \"alloy\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_structure1_alloy.png\"\nUnitTemplate.general.toggles = { Production = true }\nUnitTemplate.tags = {\n    \"ALLOYS_PRODUCTION\", \"BUILDABLE_BY_T3_ENGINEER\", \"ECONOMIC\",\n    \"EDA\", \"STRUCTURE\", \"TECH3\",\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = -0.25, z = 0 },\n    collisionSize = { x = 1.75, y = 2.1, z = 1.875 },\n}\nUnitTemplate.footprint = { x = 3, y = 3 }\nUnitTemplate.skirtSize = { x = 6, y = 6 }\nUnitTemplate.defence.health = { max = 6000, regen = 0, value = 6000 }\nUnitTemplate.economy = {\n    buildTime = 3750,\n    cost = { alloys = 3000, energy = 65000 },\n    maintenanceConsumption = { energy = 3500 },\n    production = { alloys = 12 },\n}\nUnitTemplate.intel = { visionRadius = 20 }\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.selection = {\n    size = { x = 1.55, y = 1.55 },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.weapons = {\n    {\n        category = \"DeathExplosion\",\n        damage = 5000,\n        damageFriendly = true,\n        damageRadius = 14,\n        damageType = \"Normal\",\n    },\n}", "EDASupComMassFabricator", "buildTime = 3750", "damageRadius = 14"),
		Template("ugs3603", "URB1303 mass fabricator", "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- Exact direct mapping: URB1303 -> ugs3603.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.rotators = {\n    {\n        boneName = \"Spinner\",\n        speed = { x = 0, y = 0, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URB1303 -> ugs3603\",\n    sourceBlueprint = \"units/URB1303/URB1303_unit.bp\",\n    sourceBlueprintSha256 = \"bf7930986d1b416fc4db68e070f4b1249d2edce04c82415c03791f62ab79ae75\",\n    sourceScript = \"units/URB1303/URB1303_script.lua\",\n    sourceScriptSha256 = \"5a29e3fb5be7a66c892cfaa23021777d4773be82a7fa00abf20dd302eac35400\",\n    sourceAdjacency = \"T3MassFabricatorAdjacencyBuffs\",\n    sanctuaryAdjacency = \"T3AlloyFabricatorAdjacencyBuff\",\n    sourceSkirtOffset = { x = -1.5, z = -1.5 },\n    sanctuarySkirtOffsetSupported = false,\n    spinner = { bone = \"Spinner\", axis = \"z\", targetSpeed = 60, acceleration = 10 },\n}\nUnitTemplate.adjacency = \"T3AlloyFabricatorAdjacencyBuff\"\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardSupComMassFabricator\" }\nUnitTemplate.general.displayName = \"Mass Fabricator\"\nUnitTemplate.general.name = \"Mass Fabricator\"\nUnitTemplate.general.icon = { shape = \"structure1\", symbol = \"alloy\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_structure1_alloy.png\"\nUnitTemplate.general.toggles = { Production = true }\nUnitTemplate.tags = {\n    \"ALLOYS_PRODUCTION\", \"BUILDABLE_BY_T3_ENGINEER\", \"ECONOMIC\",\n    \"GUARD\", \"STRUCTURE\", \"TECH3\",\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = -0.25, z = 0 },\n    collisionSize = { x = 1.3, y = 3.2, z = 1.3 },\n}\nUnitTemplate.footprint = { x = 3, y = 3 }\nUnitTemplate.skirtSize = { x = 6, y = 6 }\nUnitTemplate.defence.health = { max = 6000, regen = 0, value = 6000 }\nUnitTemplate.economy = {\n    buildTime = 3750,\n    cost = { alloys = 3000, energy = 65000 },\n    maintenanceConsumption = { energy = 3500 },\n    production = { alloys = 12 },\n}\nUnitTemplate.intel = { visionRadius = 20 }\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.selection = {\n    size = { x = 1.55, y = 1.55 },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.weapons = {\n    {\n        category = \"DeathExplosion\",\n        damage = 5000,\n        damageFriendly = true,\n        damageRadius = 14,\n        damageType = \"Normal\",\n    },\n}", "GuardSupComMassFabricator", "buildTime = 3750", "targetSpeed = 60"),
		Template("ues2501", "XEB0104 Kennel", "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- Direct source: XEB0104 The Kennel -> ues2501.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = { \"AttachSpecial01\", \"AttachSpecial02\" }\nUnitTemplate.additions.progressBoundUpgradeAnimation = {\n    animationKey = \"upgrade\",\n    durationSeconds = 0.8333333134651184,\n    restAnimationKey = \"walk\",\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"XEB0104 -> ues2501\",\n    sourceBlueprintSha256 = \"2052c14d35cc2772d23e5bf429a4457204c37745b3fa5e6ab22b0adeaf73bc37\",\n    sourceScriptSha256 = \"00d4ff0aa2f10cfb5addce51f3783a08a7b229ffe388bf84a270403301f2f3f2\",\n    sourceSkirtOffset = { x = -0.5, z = -0.5 },\n    sanctuarySkirtOffsetSupported = false,\n    sourcePod = { id = \"XEA3204\", attach = \"AttachSpecial01\", createWithUnit = true },\n    sanctuaryPodRuntimeSupported = false,\n    sanctuaryDirectBuildCompatibility = true,\n    podOpen = { sourceRate = 2, holdSeconds = 0.5, clip = \"AnimPodOpen\" },\n    podResume = { sourceRate = 1.5, clip = \"AnimPodResume\" },\n}\nUnitTemplate.general.class = { \"unitsDefaultEDA\", \"EDASupComKennelT2\" }\nUnitTemplate.general.displayName = \"The Kennel\"\nUnitTemplate.general.name = \"The Kennel\"\nUnitTemplate.general.icon = { shape = \"structure1\", symbol = \"engineer\", tech = \"t2\" }\nUnitTemplate.general.iconUI = \"tech2_structure1_engineer.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 200\nUnitTemplate.tags = {\n    \"BUILDABLE_BY_T2_ENGINEER\", \"BUILDABLE_BY_T3_ENGINEER\", \"CONSTRUCTION\",\n    \"EDA\", \"ENGINEERING_STATION\", \"LAND\", \"STRUCTURE\", \"TECH2\",\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0, z = 0 },\n    collisionSize = { x = 0.7, y = 0.8, z = 0.7 },\n}\nUnitTemplate.footprint = { x = 1, y = 1 }\nUnitTemplate.skirtSize = { x = 2, y = 2 }\nUnitTemplate.defence.health = { max = 1000, regen = 0, value = 1000 }\nUnitTemplate.economy = {\n    buildTime = 1100,\n    cost = { alloys = 550, energy = 2750 },\n}\nUnitTemplate.intel = { visionRadius = 15 }\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.buildPower = 20\nUnitTemplate.construction.range = 15\nUnitTemplate.construction.canBuild = \"Tags.EDA * Tags.BUILDABLE_BY_T2_ENGINEER\"\nUnitTemplate.construction.upgradesTo = \"ues3501\"\nUnitTemplate.visuals.animations = {\n    walk = { clipName = \"Rest\", sanAnimationPath = \"Units/ues2501/LOD0/ues2501.sananimation\" },\n    podOpen = { clipName = \"AnimPodOpen\", sanAnimationPath = \"Units/ues2501/LOD0/ues2501.sananimation\", playbackMode = 0 },\n    podResume = { clipName = \"AnimPodResume\", sanAnimationPath = \"Units/ues2501/LOD0/ues2501.sananimation\", playbackMode = 0 },\n    upgrade = { clipName = \"AnimUpgrade\", sanAnimationPath = \"Units/ues2501/LOD0/ues2501.sananimation\", playbackMode = 0 },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.selection = {\n    size = { x = 0.65, y = 0.6 },\n    offset = { x = 0, y = 0, z = 0 },\n}", "EDASupComKennelT2", "AnimPodOpen", "durationSeconds = 0.8333333134651184"),
		Template("ues3501", "XEB0204 Kennel", "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- Direct source: XEB0204 The Kennel -> ues3501.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = { \"AttachSpecial01\", \"AttachSpecial02\" }\nUnitTemplate.additions.progressBoundUpgradeAnimation = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"XEB0204 -> ues3501\",\n    sourceBlueprintSha256 = \"c7bca76130a5892b252464a8dc65f08e15da385bc3f0e7dcbbe873d60ca40ba8\",\n    sourceScriptSha256 = \"e944e2bbe6bdd0dce936a2cacdabf1fd29add88c81fbb6d1ecfc599ca17749fa\",\n    sourceSelectionCenterOffsetZ = 0.1,\n    sanctuarySouthFacingSelectionOffsetZ = -0.1,\n    sourceSkirtOffset = { x = -0.5, z = -0.5 },\n    sanctuarySkirtOffsetSupported = false,\n    sourcePods = {\n        { id = \"XEA3204\", attach = \"AttachSpecial01\" },\n        { id = \"XEA3204\", attach = \"AttachSpecial02\" },\n    },\n    sanctuaryPodRuntimeSupported = false,\n    sanctuaryDirectBuildCompatibility = true,\n    completionOpen = { sourceRate = 0.4, durationSeconds = 5, clip = \"AnimOpen\" },\n}\nUnitTemplate.general.class = { \"unitsDefaultEDA\", \"EDASupComKennelT3\" }\nUnitTemplate.general.displayName = \"The Kennel\"\nUnitTemplate.general.name = \"The Kennel\"\nUnitTemplate.general.icon = { shape = \"structure1\", symbol = \"engineer\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_structure1_engineer.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 200\n-- XEB0204 is upgrade-only; retain the Sanctuary TECH3 identity but do not\n-- expose the terminal target as a separately buildable structure.\nUnitTemplate.tags = {\n    \"CONSTRUCTION\", \"EDA\", \"ENGINEERING_STATION\", \"LAND\", \"STRUCTURE\", \"TECH3\",\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = -0.25, z = 0 },\n    collisionSize = { x = 1, y = 1.8, z = 1 },\n}\nUnitTemplate.footprint = { x = 1, y = 1 }\nUnitTemplate.skirtSize = { x = 2, y = 2 }\nUnitTemplate.defence.health = { max = 3000, regen = 0, value = 3000 }\nUnitTemplate.economy = {\n    buildTime = 2000,\n    cost = { alloys = 500, energy = 2500 },\n}\nUnitTemplate.intel = { visionRadius = 15 }\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.buildPower = 20\nUnitTemplate.construction.range = 20\nUnitTemplate.construction.canBuild = \"Tags.EDA * Tags.BUILDABLE_BY_T3_ENGINEER\"\nUnitTemplate.construction.upgradesTo = nil\nUnitTemplate.visuals.animations = {\n    walk = { clipName = \"Rest\", sanAnimationPath = \"Units/ues3501/LOD0/ues3501.sananimation\" },\n    open = { clipName = \"AnimOpen\", sanAnimationPath = \"Units/ues3501/LOD0/ues3501.sananimation\", playbackMode = 0 },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.selection = {\n    size = { x = 0.65, y = 0.6 },\n    offset = { x = 0, y = 0, z = -0.1 },\n}", "EDASupComKennelT3", "durationSeconds = 5", "z = -0.1"),
		Template("ugs2501", "XRB0104 Hive", "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- Direct source: XRB0104 The Hive -> ugs2501.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = { \"Attachpoint01\" }\nUnitTemplate.additions.progressBoundUpgradeAnimation = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"XRB0104 -> ugs2501\",\n    sourceBlueprintSha256 = \"33df9d71506323628c40288aaf5df5ce6bea3f90ee7b176232ca1ed253580a05\",\n    sourceScriptSha256 = \"f4a5ce558e59e30e8866c35977f7badc154d1a5951c7a6c07905d4fc36a8432c\",\n    sourceUpgradesTo = \"XRB0204\",\n    substitutedTerminalTarget = \"ugs3501/XRB0304\",\n    sourceSkirtOffset = { x = -0.5, z = -0.5 },\n    sanctuarySkirtOffsetSupported = false,\n    closeClipIsBakedReverse = true,\n    midClipReverseContinuitySupported = false,\n}\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardSupComHiveT2\" }\nUnitTemplate.general.displayName = \"The Hive\"\nUnitTemplate.general.name = \"The Hive\"\nUnitTemplate.general.icon = { shape = \"structure1\", symbol = \"engineer\", tech = \"t2\" }\nUnitTemplate.general.iconUI = \"tech2_structure1_engineer.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 200\nUnitTemplate.tags = {\n    \"BUILDABLE_BY_T2_ENGINEER\", \"BUILDABLE_BY_T3_ENGINEER\", \"CONSTRUCTION\",\n    \"ENGINEERING_STATION\", \"GUARD\", \"LAND\", \"STRUCTURE\", \"TECH2\",\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = -0.25, z = 0 },\n    collisionSize = { x = 1.2, y = 1.6, z = 1.2 },\n}\nUnitTemplate.footprint = { x = 1, y = 1 }\nUnitTemplate.skirtSize = { x = 2, y = 2 }\nUnitTemplate.defence.health = { max = 500, regen = 0, value = 500 }\nUnitTemplate.economy = {\n    buildTime = 900,\n    cost = { alloys = 500, energy = 2500 },\n}\nUnitTemplate.intel = { visionRadius = 15 }\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.buildPower = 15\nUnitTemplate.construction.range = 15\nUnitTemplate.construction.canBuild = \"Tags.GUARD * Tags.BUILDABLE_BY_T2_ENGINEER\"\nUnitTemplate.construction.upgradesTo = \"ugs3501\"\nUnitTemplate.visuals.animations = {\n    walk = { clipName = \"Rest\", sanAnimationPath = \"Units/ugs2501/LOD0/ugs2501.sananimation\" },\n    open = { clipName = \"AnimOpen\", sanAnimationPath = \"Units/ugs2501/LOD0/ugs2501.sananimation\", playbackMode = 0 },\n    close = { clipName = \"AnimClose\", sanAnimationPath = \"Units/ugs2501/LOD0/ugs2501.sananimation\", playbackMode = 0 },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.selection = {\n    size = { x = 1, y = 1 },\n    offset = { x = 0, y = 0, z = 0 },\n}", "GuardSupComHiveT2", "AnimClose", "upgradesTo = \"ugs3501\""),
		Template("ugs3501", "XRB0304 terminal Hive", "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- Terminal progression source: XRB0304 The Hive -> ugs3501.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = { \"Attachpoint01\", \"Attachpoint02\", \"Attachpoint03\" }\nUnitTemplate.additions.progressBoundUpgradeAnimation = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"XRB0304 -> ugs3501\",\n    sourceBlueprintSha256 = \"d2fc5fa9de2105259bf66ee88b20b271e11c4ddae34420df2383d67baa90b701\",\n    sourceScriptSha256 = \"3cc97747f900596d50c06565fd4682ca70bd8d870d49a9e0d664a93ea8e7d5be\",\n    terminalProgressionSubstitution = true,\n    sourceTechCategory = \"TECH2\",\n    sanctuaryPublicTechCategory = \"TECH3\",\n    sourceUpgradesFrom = \"XRB0204\",\n    sanctuaryUpgradesFrom = \"ugs2501/XRB0104\",\n    sourceSkirtOffset = { x = -0.5, z = -0.5 },\n    sanctuarySkirtOffsetSupported = false,\n    staticallyVisibleMeshBones = { \"TurretT3\", \"B03\", \"Door3_B03\" },\n    closeClipIsBakedReverse = true,\n    midClipReverseContinuitySupported = false,\n}\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardSupComHiveFinal\" }\nUnitTemplate.general.displayName = \"The Hive\"\nUnitTemplate.general.name = \"The Hive\"\nUnitTemplate.general.icon = { shape = \"structure1\", symbol = \"engineer\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_structure1_engineer.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 200\nUnitTemplate.tags = {\n    \"CONSTRUCTION\", \"ENGINEERING_STATION\", \"GUARD\", \"LAND\", \"STRUCTURE\", \"TECH3\",\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = -0.25, z = 0 },\n    collisionSize = { x = 1.2, y = 2.6, z = 1.3 },\n}\nUnitTemplate.footprint = { x = 1, y = 1 }\nUnitTemplate.skirtSize = { x = 2, y = 2 }\nUnitTemplate.defence.health = { max = 2750, regen = 0, value = 2750 }\nUnitTemplate.economy = {\n    buildTime = 2400,\n    cost = { alloys = 240, energy = 1600 },\n}\nUnitTemplate.intel = { visionRadius = 15 }\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.buildPower = 35\nUnitTemplate.construction.range = 25\nUnitTemplate.construction.canBuild = \"Tags.GUARD * Tags.BUILDABLE_BY_T3_ENGINEER\"\nUnitTemplate.construction.upgradesTo = nil\nUnitTemplate.visuals.animations = {\n    walk = { clipName = \"Rest\", sanAnimationPath = \"Units/ugs3501/LOD0/ugs3501.sananimation\" },\n    open = { clipName = \"AnimOpen\", sanAnimationPath = \"Units/ugs3501/LOD0/ugs3501.sananimation\", playbackMode = 0 },\n    close = { clipName = \"AnimClose\", sanAnimationPath = \"Units/ugs3501/LOD0/ugs3501.sananimation\", playbackMode = 0 },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.selection = {\n    size = { x = 1, y = 1 },\n    offset = { x = 0, y = 0, z = 0 },\n}", "GuardSupComHiveFinal", "staticallyVisibleMeshBones", "buildPower = 35"),
		Template("ugs3401", "URB4207 terminal ED5 shield", "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- Terminal ED5 progression source: URB4207 -> ugs3401.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.rotators = {\n    {\n        boneName = \"Shaft\",\n        speed = { x = 0, y = 0, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n}\nUnitTemplate.additions.progressBoundUpgradeAnimation = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URB4207 -> ugs3401\",\n    sourceBlueprintSha256 = \"7442a10729ab814418f0201aed463b1acda55a8dc135ead974b399d709e210e3\",\n    sourceScriptSha256 = \"357879b75e0d17dfd9330fa72efa5c2dc69d085aaa1573dcd9b543f95e86ea49\",\n    terminalProgressionSubstitution = true,\n    sourceTechCategory = \"TECH2\",\n    sanctuaryPublicTechCategory = \"TECH3\",\n    sourceUpgradesFrom = \"URB4206\",\n    sanctuaryUpgradesFrom = \"ugs2401\",\n    sourceShieldSizeDiameter = 40,\n    sanctuaryShieldRadius = 20,\n    sourceShieldEnergyDrainRechargeTime = 5,\n    sanctuaryEnergyDrainRechargeTimeSupported = false,\n    sourceRegenAssistMultiplier = 60,\n    sanctuaryRegenAssistMultiplierSupported = false,\n    sourceSkirtOffset = { x = -2.5, z = -2.5 },\n    sanctuarySkirtOffsetSupported = false,\n    spinner = { bone = \"Shaft\", axis = \"z\", initialSpeed = 30, enabledSpeed = 10, acceleration = 5, maximumSpeed = 30 },\n    terminalAopen = { clip = \"AnimUpgrade\", frames = 161, durationSeconds = 5.333333492279053, sourceBound = false },\n    sourceEmitterGraphSupported = false,\n}\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardSupComShieldFinal\" }\nUnitTemplate.general.displayName = \"ED5\"\nUnitTemplate.general.name = \"ED5\"\nUnitTemplate.general.icon = { shape = \"structure1\", symbol = \"shield\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_structure1_shield.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 160\nUnitTemplate.general.toggles = { Shield = true }\nUnitTemplate.tags = { \"DEFENCE\", \"GUARD\", \"SHIELD\", \"STRUCTURE\", \"TECH3\" }\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = -0.25, z = 0 },\n    collisionSize = { x = 2, y = 5, z = 2 },\n}\nUnitTemplate.footprint = { x = 1, y = 1 }\nUnitTemplate.skirtSize = { x = 6, y = 6 }\nUnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = { max = 500, regen = 0, value = 500 }\nlocal SCO_ED5Shield = UnitTemplate.defence.shields and UnitTemplate.defence.shields[1] or {}\nUnitTemplate.defence.shields = { SCO_ED5Shield }\nSCO_ED5Shield.boneName = \"Root\"\nSCO_ED5Shield.max = 14000\nSCO_ED5Shield.value = 14000\nSCO_ED5Shield.name = \"Bubble Shield\"\nSCO_ED5Shield.offset = { x = 0, y = -6, z = 0 }\nSCO_ED5Shield.radii = { x = 20, y = 20, z = 20 }\nSCO_ED5Shield.rechargeHPRatio = 0.5\nSCO_ED5Shield.rechargeTime = 22\nSCO_ED5Shield.regen = 140\nSCO_ED5Shield.regenDelay = 1\nSCO_ED5Shield.type = 0\nSCO_ED5Shield.effectsPersistent = nil\n-- URB4207 has ShieldOn/ShieldOff one-shots, not the donor's continuous shield\n-- hum. Its FA bank is unavailable, so remove that false persistent owner.\nSCO_ED5Shield.audio = nil\nUnitTemplate.economy = {\n    buildTime = 1600,\n    cost = { alloys = 2400, energy = 40000 },\n    maintenanceConsumption = { energy = 500 },\n}\nUnitTemplate.intel = { visionRadius = 20 }\nUnitTemplate.visuals.animations = {\n    walk = { clipName = \"Rest\", sanAnimationPath = \"Units/ugs3401/LOD0/ugs3401.sananimation\" },\n    terminalOpen = { clipName = \"AnimUpgrade\", sanAnimationPath = \"Units/ugs3401/LOD0/ugs3401.sananimation\", playbackMode = 0 },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.selection = {\n    size = { x = 2.2, y = 2.2 },\n    offset = { x = 0, y = 0, z = 0 },\n}", "GuardSupComShieldFinal", "max = 14000", "sourceBound = false"),
		ClassFile("host/units/unitsClasses/unitsDefaultEDA.lua", "host EDA direct classes", "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\nlocal SCO_EDAAlloyExtractor = HostEDAAlloyExtractor or EDAAlloyExtractor\nlocal SCO_EDAEngineeringStation = HostEDAEngineeringStation or EDAEngineeringStation\nif not SCO_EDAAlloyExtractor or not SCO_EDAEngineeringStation then\n    error(\"SCO direct structures could not resolve host EDA bases.\")\nend\n\nlocal function SCO_FabricatorIsActive(self)\n    return self:IsCompleted()\n        and self:GetProductionToggle()\n        and not self.army.economy.isEnergyDown\nend\n\nHostEDASupComMassFabricator = Class(\"EDASupComMassFabricator\", SCO_EDAAlloyExtractor)\nlocal EDASupComMassFabricator = HostEDASupComMassFabricator\n\nfunction EDASupComMassFabricator:RotatorsEnabledOnConstruction()\n    return false\nend\n\nfunction EDASupComMassFabricator:SCOSetFabricatorRotorTarget(targetSpeed)\n    if self.scoFabricatorRotorTarget == targetSpeed and self.scoFabricatorRotorThread then\n        return\n    end\n    if self.scoFabricatorRotorThread then\n        KillThread(self.scoFabricatorRotorThread)\n    end\n    self.scoFabricatorRotorTarget = targetSpeed\n    self.scoFabricatorRotorThread = self:NewThread(self.SCOFabricatorRotorRampThread, targetSpeed)\nend\n\nfunction EDASupComMassFabricator:SCOFabricatorRotorRampThread(targetSpeed)\n    local rotor = self.rotatorIds and self.rotatorIds[1]\n    if not rotor then\n        error(\"UEB1303 Spinner rotator is missing.\")\n    end\n    local speed = self.scoFabricatorRotorSpeed or 0\n    self:SetRotatorsEnabled(true)\n    while not self.dead and math.abs(targetSpeed - speed) > 0.000001 do\n        local delta = math.min(math.abs(targetSpeed - speed), 1)\n        speed = speed + (targetSpeed > speed and delta or -delta)\n        self.scoFabricatorRotorSpeed = speed\n        Engine.SetRotatorSpeed(rotor, EngineClasses.float3(0, 0, speed))\n        WaitSeconds(0.1)\n    end\n    if targetSpeed == 0 then\n        self:SetRotatorsEnabled(false)\n    end\n    self.scoFabricatorRotorThread = nil\nend\n\nfunction EDASupComMassFabricator:CheckProductionState()\n    local active = SCO_FabricatorIsActive(self)\n    if self.resourceEntities.production then\n        self.resourceEntities.production:SetEnabled(active)\n    end\n    if self.rotatorIds and self.rotatorIds[1] then\n        self:SCOSetFabricatorRotorTarget(active and 40 or 0)\n    end\nend\n\nfunction EDASupComMassFabricator:OnStopBeingBuilt()\n    SCO_EDAAlloyExtractor.OnStopBeingBuilt(self)\n    self:CheckProductionState()\nend\n\nfunction EDASupComMassFabricator:OnEnergyDown()\n    SCO_EDAAlloyExtractor.OnEnergyDown(self)\n    self:CheckProductionState()\nend\n\nfunction EDASupComMassFabricator:OnEnergyUp()\n    SCO_EDAAlloyExtractor.OnEnergyUp(self)\n    self:CheckProductionState()\nend\n\nHostEDASupComKennelT2 = Class(\"EDASupComKennelT2\", SCO_EDAEngineeringStation)\nlocal EDASupComKennelT2 = HostEDASupComKennelT2\n\nfunction EDASupComKennelT2:UpdateAnimations()\nend\n\nfunction EDASupComKennelT2:OnStartBuildRoutine(targetUnit)\n    SCO_EDAEngineeringStation.OnStartBuildRoutine(self, targetUnit)\n    if self:IsUpgrading() or self.scoKennelPodOpen then\n        return\n    end\n    local animation = self.tp.visuals.animations.podOpen\n    self.scoKennelPodOpen = true\n    Engine.PlayAnimation(self.id, animation.id, 0.1)\nend\n\nfunction EDASupComKennelT2:OnStopBuildRoutine(targetUnit)\n    SCO_EDAEngineeringStation.OnStopBuildRoutine(self, targetUnit)\n    if self:IsUpgrading() or not self.scoKennelPodOpen then\n        return\n    end\n    local animation = self.tp.visuals.animations.podResume\n    self.scoKennelPodOpen = false\n    Engine.PlayAnimation(self.id, animation.id, 0.1)\nend\n\nHostEDASupComKennelT3 = Class(\"EDASupComKennelT3\", SCO_EDAEngineeringStation)\nlocal EDASupComKennelT3 = HostEDASupComKennelT3\n\nfunction EDASupComKennelT3:UpdateAnimations()\nend\n\nfunction EDASupComKennelT3:OnStopBeingBuilt()\n    SCO_EDAEngineeringStation.OnStopBeingBuilt(self)\n    local animation = self.tp.visuals.animations.open\n    Engine.PlayAnimation(self.id, animation.id, 0.1)\nend", "HostEDASupComMassFabricator", "HostEDASupComKennelT3"),
		ClassFile("client/units/unitsClasses/unitsDefaultEDA.lua", "client EDA direct classes", "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\nlocal SCO_EDAAlloyExtractor = ClientEDAAlloyExtractor or EDAAlloyExtractor\nlocal SCO_EDAEngineeringStation = ClientEDAEngineeringStation or EDAEngineeringStation\nif not SCO_EDAAlloyExtractor or not SCO_EDAEngineeringStation then\n    error(\"SCO direct structures could not resolve client EDA bases.\")\nend\nClientEDASupComMassFabricator = Class(\"EDASupComMassFabricator\", SCO_EDAAlloyExtractor)\nClientEDASupComKennelT2 = Class(\"EDASupComKennelT2\", SCO_EDAEngineeringStation)\nClientEDASupComKennelT3 = Class(\"EDASupComKennelT3\", SCO_EDAEngineeringStation)", "ClientEDASupComMassFabricator", "ClientEDASupComKennelT3"),
		ClassFile("host/units/unitsClasses/unitsDefaultGuard.lua", "host Guard direct classes", "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\nlocal SCO_GuardStructure = HostGuardStructure or GuardStructure\nlocal SCO_GuardAlloyExtractor = HostGuardAlloyExtractor or GuardAlloyExtractor\nlocal SCO_GuardEngineeringStation = HostGuardEngineeringStation or GuardEngineeringStation\nif not SCO_GuardStructure or not SCO_GuardAlloyExtractor or not SCO_GuardEngineeringStation then\n    error(\"SCO direct structures could not resolve host Guard bases.\")\nend\n\nlocal function SCO_GuardFabricatorIsActive(self)\n    return self:IsCompleted()\n        and self:GetProductionToggle()\n        and not self.army.economy.isEnergyDown\nend\n\nHostGuardSupComMassFabricator = Class(\"GuardSupComMassFabricator\", SCO_GuardAlloyExtractor)\nlocal GuardSupComMassFabricator = HostGuardSupComMassFabricator\n\nfunction GuardSupComMassFabricator:RotatorsEnabledOnConstruction()\n    return false\nend\n\nfunction GuardSupComMassFabricator:SCOSetFabricatorRotorTarget(targetSpeed)\n    if self.scoFabricatorRotorTarget == targetSpeed and self.scoFabricatorRotorThread then\n        return\n    end\n    if self.scoFabricatorRotorThread then\n        KillThread(self.scoFabricatorRotorThread)\n    end\n    self.scoFabricatorRotorTarget = targetSpeed\n    self.scoFabricatorRotorThread = self:NewThread(self.SCOFabricatorRotorRampThread, targetSpeed)\nend\n\nfunction GuardSupComMassFabricator:SCOFabricatorRotorRampThread(targetSpeed)\n    local rotor = self.rotatorIds and self.rotatorIds[1]\n    if not rotor then\n        error(\"URB1303 Spinner rotator is missing.\")\n    end\n    local speed = self.scoFabricatorRotorSpeed or 0\n    self:SetRotatorsEnabled(true)\n    while not self.dead and math.abs(targetSpeed - speed) > 0.000001 do\n        local delta = math.min(math.abs(targetSpeed - speed), 1)\n        speed = speed + (targetSpeed > speed and delta or -delta)\n        self.scoFabricatorRotorSpeed = speed\n        Engine.SetRotatorSpeed(rotor, EngineClasses.float3(0, 0, speed))\n        WaitSeconds(0.1)\n    end\n    if targetSpeed == 0 then\n        self:SetRotatorsEnabled(false)\n    end\n    self.scoFabricatorRotorThread = nil\nend\n\nfunction GuardSupComMassFabricator:CheckProductionState()\n    local active = SCO_GuardFabricatorIsActive(self)\n    if self.resourceEntities.production then\n        self.resourceEntities.production:SetEnabled(active)\n    end\n    if self.rotatorIds and self.rotatorIds[1] then\n        self:SCOSetFabricatorRotorTarget(active and 60 or 0)\n    end\nend\n\nfunction GuardSupComMassFabricator:OnStopBeingBuilt()\n    SCO_GuardAlloyExtractor.OnStopBeingBuilt(self)\n    self:CheckProductionState()\nend\n\nfunction GuardSupComMassFabricator:OnEnergyDown()\n    SCO_GuardAlloyExtractor.OnEnergyDown(self)\n    self:CheckProductionState()\nend\n\nfunction GuardSupComMassFabricator:OnEnergyUp()\n    SCO_GuardAlloyExtractor.OnEnergyUp(self)\n    self:CheckProductionState()\nend\n\nlocal function SCO_PlayGuardStationAnimation(self, key)\n    local animation = self.tp.visuals.animations[key]\n    Engine.PlayAnimation(self.id, animation.id, 0.1)\nend\n\nHostGuardSupComHiveT2 = Class(\"GuardSupComHiveT2\", SCO_GuardEngineeringStation)\nlocal GuardSupComHiveT2 = HostGuardSupComHiveT2\n\nfunction GuardSupComHiveT2:UpdateAnimations()\nend\n\nfunction GuardSupComHiveT2:OnStartBuildRoutine(targetUnit)\n    SCO_GuardEngineeringStation.OnStartBuildRoutine(self, targetUnit)\n    SCO_PlayGuardStationAnimation(self, \"open\")\nend\n\nfunction GuardSupComHiveT2:OnStopBuildRoutine(targetUnit)\n    SCO_GuardEngineeringStation.OnStopBuildRoutine(self, targetUnit)\n    SCO_PlayGuardStationAnimation(self, \"close\")\nend\n\nHostGuardSupComHiveFinal = Class(\"GuardSupComHiveFinal\", SCO_GuardEngineeringStation)\nlocal GuardSupComHiveFinal = HostGuardSupComHiveFinal\n\nfunction GuardSupComHiveFinal:UpdateAnimations()\nend\n\nfunction GuardSupComHiveFinal:OnStartBuildRoutine(targetUnit)\n    SCO_GuardEngineeringStation.OnStartBuildRoutine(self, targetUnit)\n    SCO_PlayGuardStationAnimation(self, \"open\")\nend\n\nfunction GuardSupComHiveFinal:OnStopBuildRoutine(targetUnit)\n    SCO_GuardEngineeringStation.OnStopBuildRoutine(self, targetUnit)\n    SCO_PlayGuardStationAnimation(self, \"close\")\nend\n\nHostGuardSupComShieldFinal = Class(\"GuardSupComShieldFinal\", SCO_GuardStructure)\nlocal GuardSupComShieldFinal = HostGuardSupComShieldFinal\n\nfunction GuardSupComShieldFinal:UpdateAnimations()\nend\n\nfunction GuardSupComShieldFinal:SCOSetShieldRotorTarget(targetSpeed)\n    if self.scoShieldRotorTarget == targetSpeed and self.scoShieldRotorThread then\n        return\n    end\n    if self.scoShieldRotorThread then\n        KillThread(self.scoShieldRotorThread)\n    end\n    self.scoShieldRotorTarget = targetSpeed\n    self.scoShieldRotorThread = self:NewThread(self.SCOShieldRotorRampThread, targetSpeed)\nend\n\nfunction GuardSupComShieldFinal:SCOShieldRotorRampThread(targetSpeed)\n    local rotor = self.rotatorIds and self.rotatorIds[1]\n    if not rotor then\n        error(\"URB4207 Shaft rotator is missing.\")\n    end\n    local speed = self.scoShieldRotorSpeed or 0\n    self:SetRotatorsEnabled(true)\n    while not self.dead and math.abs(targetSpeed - speed) > 0.000001 do\n        local delta = math.min(math.abs(targetSpeed - speed), 0.5)\n        speed = speed + (targetSpeed > speed and delta or -delta)\n        self.scoShieldRotorSpeed = speed\n        Engine.SetRotatorSpeed(rotor, EngineClasses.float3(0, 0, speed))\n        WaitSeconds(0.1)\n    end\n    if targetSpeed == 0 then\n        self:SetRotatorsEnabled(false)\n    end\n    self.scoShieldRotorThread = nil\nend\n\nfunction GuardSupComShieldFinal:SCOOnDirectShieldEnabledChanged(enabled)\n    if not self.scoShieldRotorReady then\n        return\n    end\n    self:SCOSetShieldRotorTarget(enabled and 10 or 0)\nend\n\nfunction GuardSupComShieldFinal:OnStopBeingBuilt()\n    SCO_GuardStructure.OnStopBeingBuilt(self)\n    local rotor = self.rotatorIds and self.rotatorIds[1]\n    if not rotor then\n        error(\"URB4207 Shaft rotator is missing after construction.\")\n    end\n    self.scoShieldRotorReady = true\n    local active = self:GetShieldToggle() and not self.army.economy.isEnergyDown\n    local initialSpeed = active and 30 or 0\n    self.scoShieldRotorSpeed = initialSpeed\n    self.scoShieldRotorTarget = initialSpeed\n    Engine.SetRotatorSpeed(rotor, EngineClasses.float3(0, 0, initialSpeed))\n    self:SetRotatorsEnabled(active)\nend", "HostGuardSupComMassFabricator", "HostGuardSupComShieldFinal"),
		ClassFile("client/units/unitsClasses/unitsDefaultGuard.lua", "client Guard direct classes", "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\nlocal SCO_GuardStructure = ClientGuardStructure or GuardStructure\nlocal SCO_GuardAlloyExtractor = ClientGuardAlloyExtractor or GuardAlloyExtractor\nlocal SCO_GuardEngineeringStation = ClientGuardEngineeringStation or GuardEngineeringStation\nif not SCO_GuardStructure or not SCO_GuardAlloyExtractor or not SCO_GuardEngineeringStation then\n    error(\"SCO direct structures could not resolve client Guard bases.\")\nend\nClientGuardSupComMassFabricator = Class(\"GuardSupComMassFabricator\", SCO_GuardAlloyExtractor)\nClientGuardSupComHiveT2 = Class(\"GuardSupComHiveT2\", SCO_GuardEngineeringStation)\nClientGuardSupComHiveFinal = Class(\"GuardSupComHiveFinal\", SCO_GuardEngineeringStation)\nClientGuardSupComShieldFinal = Class(\"GuardSupComShieldFinal\", SCO_GuardStructure)", "ClientGuardSupComMassFabricator", "ClientGuardSupComShieldFinal"),
		RuntimeFile("host/shield.lua", "URB4207 shield-transition bridge", "\n\n-- Supreme Commander Overhaul FA Direct Structures 1.0.0\n-- URB4207 drives its Shaft from actual shield transitions, matching the\n-- source OnShieldDisabled/OnShieldEnabled lifecycle across damage recharge,\n-- manual toggle, and power loss. Delegate every non-target shield unchanged.\nlocal SCO_DirectStructureStockShieldSetEnabled = HostShield.SetEnabled\nfunction HostShield:SetEnabled(value)\n    local wasEnabled = self.enabled\n    SCO_DirectStructureStockShieldSetEnabled(self, value)\n    if self.enabled == wasEnabled then\n        return\n    end\n    local owner = self.owner\n    if owner\n        and owner.tpId == \"ugs3401\"\n        and owner.SCOOnDirectShieldEnabledChanged then\n        owner:SCOOnDirectShieldEnabledChanged(self.enabled)\n    end\nend", "SCO_DirectStructureStockShieldSetEnabled", "owner.tpId == \"ugs3401\"", "SCOOnDirectShieldEnabledChanged(self.enabled)")
	};

	public static void Apply()
	{
		object obj = null;
		List<CacheMutation> mutations = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			ValidateDependencies(obj);
			if (Preflight(obj))
			{
				Log("The seven direct FA structures are already active.");
				return;
			}
			PatchSpec[] specs = Specs;
			foreach (PatchSpec spec in specs)
			{
				QueueAppend(obj, mutations, spec);
			}
			Commit(obj, mutations);
			Log("Applied seven exact direct-structure contracts in one transaction.");
		}
		catch (Exception arg)
		{
			if (obj != null)
			{
				RollBack(obj, mutations);
			}
			else
			{
				DisposeUncommitted(mutations);
			}
			Log($"Failed to apply the direct FA structures: {arg}");
			throw;
		}
	}

	private static PatchSpec Template(string targetId, string description, string appendix, params string[] tokens)
	{
		return new PatchSpec("LJ/lua/common/units/unitsTemplates/" + targetId + "/" + targetId + ".santp", description, appendix + "\n-- FA sound banks are not part of the deterministic visual archive. Preserve\n-- only Sanctuary's faction-compatible destruction one-shot; never inherit an\n-- unrelated donor root loop or claim unavailable FA activation cues.\nUnitTemplate.additions.faSourceContract.audio = {\n    sourceBanksImported = false,\n    sourceActivationCuesSupported = false,\n    donorDestroyedOneShotRetained = UnitTemplate.audio ~= nil\n        and UnitTemplate.audio.onDestroyed ~= nil,\n    donorRootPersistentLoopRetained = false,\n}\nlocal SCO_DirectDestroyedAudio = UnitTemplate.audio and UnitTemplate.audio.onDestroyed\nUnitTemplate.audio = SCO_DirectDestroyedAudio\n    and { onDestroyed = SCO_DirectDestroyedAudio }\n    or nil", new string[2]
		{
			"UnitTemplate =",
			"tpId = \"" + targetId + "\""
		}, tokens);
	}

	private static PatchSpec ClassFile(string path, string description, string appendix, params string[] tokens)
	{
		return new PatchSpec("LJ/lua/" + path, description, appendix, new string[1] { "Class(" }, tokens);
	}

	private static PatchSpec RuntimeFile(string path, string description, string appendix, params string[] tokens)
	{
		return new PatchSpec("LJ/lua/" + path, description, appendix, new string[2] { "HostShield = Class", "function HostShield:SetEnabled(value)" }, tokens);
	}

	private static void ValidateDependencies(object cache)
	{
		RequireTokens(GetResourceText(GetCachedResource(cache, "LJ/lua/common/loading/unitTemplateLoader.lua", "animation template loader").Stock), "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1", "animationInfo.playbackMode or AnimationPlaybackMode.Loop");
		RequireTokens(GetResourceText(GetCachedResource(cache, "LJ/lua/host/units/unitsClasses/unitsDefault.lua", "progress-bound animation host bridge").Stock), "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1", "function SCOProgressAnimationUnit:StartProgressBoundUpgradeAnimation(targetUnit)");
	}

	private static bool Preflight(object cache)
	{
		(PatchSpec, string)[] array = Specs.Select((PatchSpec spec) => (Spec: spec, Source: GetResourceText(GetCachedResource(cache, spec.RelativePath, spec.Description).Stock))).ToArray();
		bool[] source = array.Select(((PatchSpec Spec, string Source) item) => ContainsOverride(item.Source)).ToArray();
		if (source.Any((bool value) => value) && !source.All((bool value) => value))
		{
			throw new InvalidOperationException("The direct-structure cache is partially marked; refusing a mixed generation.");
		}
		(PatchSpec, string)[] array2;
		if (!source.Any((bool value) => value))
		{
			array2 = array;
			for (int num = 0; num < array2.Length; num++)
			{
				(PatchSpec, string) tuple = array2[num];
				tuple.Item1.ValidateStock(tuple.Item2);
			}
			return false;
		}
		array2 = array;
		for (int num2 = 0; num2 < array2.Length; num2++)
		{
			(PatchSpec, string) tuple2 = array2[num2];
			tuple2.Item1.ValidatePatched(tuple2.Item2);
		}
		return true;
	}

	private static void QueueAppend(object cache, ICollection<CacheMutation> mutations, PatchSpec spec)
	{
		CacheResource cachedResource = GetCachedResource(cache, spec.RelativePath, spec.Description);
		string resourceText = GetResourceText(cachedResource.Stock);
		spec.ValidateStock(resourceText);
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), AppendOverride(resourceText, spec.Appendix));
		try
		{
			spec.ValidatePatched(GetResourceText(obj));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, spec.Description));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + spec.Description);
			throw;
		}
	}

	private static void Commit(object cache, IReadOnlyCollection<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			mutation.Assigned = true;
			SetCachedResource(cache, mutation.Path, mutation.Replacement);
		}
		foreach (CacheMutation mutation2 in mutations)
		{
			TryDisposeNativeArray(mutation2.Stock.GetType(), mutation2.Stock, "stock " + mutation2.Description);
		}
	}

	private static void RollBack(object cache, IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation item in mutations.Reverse())
		{
			if (item.Assigned)
			{
				try
				{
					SetCachedResource(cache, item.Path, item.Stock);
					item.Assigned = false;
				}
				catch (Exception arg)
				{
					Log($"Rollback failed for {item.Description}: {arg}");
				}
			}
			if (!item.Assigned)
			{
				TryDisposeNativeArray(item.Replacement.GetType(), item.Replacement, "replacement " + item.Description);
			}
		}
	}

	private static void DisposeUncommitted(IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			TryDisposeNativeArray(mutation.Replacement.GetType(), mutation.Replacement, "uncommitted " + mutation.Description);
		}
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static CacheResource GetCachedResource(object cache, string relativePath, string description)
	{
		Type type = cache.GetType();
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		string text = ResolvePath(relativePath);
		object obj2 = obj.Invoke(cache, new object[1] { text });
		bool flag = false;
		int num;
		if (obj2 is bool)
		{
			flag = (bool)obj2;
			num = 1;
		}
		else
		{
			num = 0;
		}
		if (((uint)num & (flag ? 1u : 0u)) != 0)
		{
			object obj3 = propertyInfo.GetValue(cache, new object[1] { text }) ?? throw new InvalidOperationException("The cached " + description + " has no value.");
			EnsureNativeArray(obj3, description);
			return new CacheResource(text, obj3);
		}
		string value = "/" + relativePath.Replace('\\', '/');
		CacheResource cacheResource = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			if (type2.GetProperty("Key")?.GetValue(item) is string text2 && text2.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (cacheResource != null)
				{
					throw new InvalidOperationException("More than one cached resource matches " + relativePath + ".");
				}
				object obj4 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("The cached " + description + " has no value.");
				EnsureNativeArray(obj4, description);
				cacheResource = new CacheResource(text2, obj4);
			}
		}
		return cacheResource ?? throw new FileNotFoundException("The required " + description + " was not present in Sanctuary's Lua file cache.", relativePath);
	}

	private static string ResolvePath(string relativePath)
	{
		return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
	}

	private static object CreateNativeArrayFromText(Type nativeArrayType, string source)
	{
		return NativeArrayByteFactory.CreatePersistent(nativeArrayType, Encoding.UTF8.GetBytes(source));
	}

	private static string GetResourceText(object resource)
	{
		EnsureNativeArray(resource, "Lua cache resource");
		Type type = resource.GetType();
		byte[] bytes = (byte[])((type.GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(type.FullName, "ToArray")).Invoke(resource, null) ?? throw new InvalidOperationException(type.FullName + ".ToArray returned null."));
		return Encoding.UTF8.GetString(bytes);
	}

	private static void EnsureNativeArray(object value, string description)
	{
		object value2 = (value.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(value.GetType().FullName, "IsCreated")).GetValue(value);
		if (!(value2 is bool) || !(bool)value2)
		{
			throw new InvalidOperationException("The cached " + description + " is not an initialized NativeArray.");
		}
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void TryDisposeNativeArray(Type nativeArrayType, object nativeArray, string description)
	{
		try
		{
			object value = (nativeArrayType.GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(nativeArrayType.FullName, "IsCreated")).GetValue(nativeArray);
			if (value is bool && (bool)value)
			{
				(nativeArrayType.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "Dispose")).Invoke(nativeArray, null);
			}
		}
		catch (Exception arg)
		{
			Log($"Could not dispose {description}: {arg}");
		}
	}

	private static string AppendOverride(string source, string appendix)
	{
		if (!source.EndsWith("\n", StringComparison.Ordinal))
		{
			return source + "\n" + appendix;
		}
		return source + appendix;
	}

	private static bool ContainsOverride(string source)
	{
		return source.IndexOf("-- Supreme Commander Overhaul FA Direct Structures 1.0.0", StringComparison.Ordinal) >= 0;
	}

	private static void RequireTokens(string source, params string[] tokens)
	{
		foreach (string text in tokens)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Expected cached Lua source to contain '" + text + "'.");
			}
		}
	}

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int num = 0;
		int startIndex = 0;
		while (true)
		{
			int num2 = source.IndexOf(token, startIndex, StringComparison.Ordinal);
			if (num2 < 0)
			{
				break;
			}
			num++;
			startIndex = num2 + token.Length;
		}
		if (num != expected)
		{
			throw new InvalidOperationException($"Expected {expected} {description}, found {num}.");
		}
	}

	private static void Log(string message)
	{
		string text = "[FA Direct Structures Cache Patcher] " + message;
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
