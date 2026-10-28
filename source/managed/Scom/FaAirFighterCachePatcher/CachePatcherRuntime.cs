using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using ScomDeterministicLua;
using SupremeCommanderOverhaul.Shared;

namespace FaAirFighterCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class FighterSpec
	{
		public string TargetId { get; }

		public string SourceId { get; }

		public string SourceBlueprintPath { get; }

		public string SourceBlueprintSha256 { get; }

		public string SourceFactionCategory { get; }

		public string FactionTag { get; }

		public string ExpectedClassOwner { get; }

		public string ExpectedUnitClass { get; }

		public string Name { get; }

		public int Health { get; }

		public double SelectionX { get; }

		public double SelectionZ { get; }

		public double SelectionThickness { get; }

		public string RelativePath => "LJ/lua/common/units/unitsTemplates/" + TargetId + "/" + TargetId + ".santp";

		public string Description => TargetId + " <- " + SourceId + " fighter template";

		public FighterSpec(string targetId, string sourceId, string sourceBlueprintPath, string sourceBlueprintSha256, string sourceFactionCategory, string factionTag, string expectedClassOwner, string expectedUnitClass, string name, int health, double selectionX, double selectionZ, double selectionThickness)
		{
			TargetId = targetId;
			SourceId = sourceId;
			SourceBlueprintPath = sourceBlueprintPath;
			SourceBlueprintSha256 = sourceBlueprintSha256;
			SourceFactionCategory = sourceFactionCategory;
			FactionTag = factionTag;
			ExpectedClassOwner = expectedClassOwner;
			ExpectedUnitClass = expectedUnitClass;
			Name = name;
			Health = health;
			SelectionX = selectionX;
			SelectionZ = selectionZ;
			SelectionThickness = selectionThickness;
		}
	}

	private sealed class ProjectileSpec
	{
		public string Id { get; }

		public string Name { get; }

		public string SourceId { get; }

		public string SourceBlueprintPath { get; }

		public string SourceBlueprintSha256 { get; }

		public string SourceScriptPath { get; }

		public string SourceScriptSha256 { get; }

		public string ImpactVfx { get; }

		public string TrailVfx { get; }

		public ProjectileSpec(string id, string name, string sourceId, string sourceBlueprintPath, string sourceBlueprintSha256, string sourceScriptPath, string sourceScriptSha256, string impactVfx, string trailVfx)
		{
			Id = id;
			Name = name;
			SourceId = sourceId;
			SourceBlueprintPath = sourceBlueprintPath;
			SourceBlueprintSha256 = sourceBlueprintSha256;
			SourceScriptPath = sourceScriptPath;
			SourceScriptSha256 = sourceScriptSha256;
			ImpactVfx = impactVfx;
			TrailVfx = trailVfx;
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

		public object? Stock { get; }

		public object Replacement { get; }

		public bool Added { get; }

		public string Description { get; }

		public bool Assigned { get; set; }

		public CacheMutation(string path, object? stock, object replacement, bool added, string description)
		{
			Path = path;
			Stock = stock;
			Replacement = replacement;
			Added = added;
			Description = description;
		}
	}

	internal const string OverrideMarker = "-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0";

	internal const string SourceArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	internal const string SourceProjectileArchiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12";

	private const string ImportRelativePath = "LJ/lua/common/systems/import.lua";

	private const string ProjectileRootRelativePath = "LJ/lua/common/projectiles/projectilesTemplates";

	private const string UefProjectileId = "pef102";

	private const string GuardProjectileId = "pgf102";

	private const string NativeOrbitRange = "6.366197723675814";

	private const string ProjectileLifetime = "0.2604166666666667";

	private static readonly FighterSpec[] FighterSpecs = new FighterSpec[2]
	{
		new FighterSpec("uea1201", "UEA0102", "units/UEA0102/UEA0102_unit.bp", "47d0b30c6c5e4a834614dd11134a11d49a90f727bac7995e54c24f0ddbfb1c26", "UEF", "EDA", "unitsDefaultEDA", "EDAAirUnit", "Cyclone", 295, 0.6, 0.65, 0.65),
		new FighterSpec("uga1201", "URA0102", "units/URA0102/URA0102_unit.bp", "9b9c06de17cd21c644ab0a9d0a8b2b3f261dd0cb23feccbdc3fc2f9bbc39261b", "CYBRAN", "GUARD", "unitsDefaultGuard", "GuardAirUnit", "Prowler", 280, 0.7, 0.6, 0.6)
	};

	private static readonly ProjectileSpec[] ProjectileSpecs = new ProjectileSpec[2]
	{
		new ProjectileSpec("pef102", "UEF_Cyclone_Linked_Railgun", "TAARailgun01", "projectiles/TAARailgun01/TAARailgun01_proj.bp", "27f4839a8b5b048073055a42fc728537303e8fae0a28266fe6674fbdb18bbc8f", "projectiles/TAARailgun01/TAARailgun01_script.lua", "36c2417368fb105b30325e2ee1fa1f63f51c79ddf18e0fece8842108333cd92e", "VFX/Impact/vei1121_autocannon_small_impact.sanvfx", "VFX/Trails/vet1121_autocannon_small_trail.sanvfx"),
		new ProjectileSpec("pgf102", "Cybran_Prowler_Electron_Autocannon", "CAAAutocannon02", "projectiles/CAAAutocannon02/CAAAutocannon02_proj.bp", "196d6739b1349438378aab28cdef2df8a1c5a346cebf1bbe290071786abb4957", "projectiles/CAAAutocannon02/CAAAutocannon02_script.lua", "57f5695e460493503a05a77dcd7e7a0524c545c19e9ec9d63b3f48f0ff843dca", "VFX/Impact/vgi1121_autocannon_plasma_small_impact.sanvfx", "VFX/Trails/vgt1121_autocannon_plasma_small_trail.sanvfx")
	};

	private const string ImportScannerAppendix = "\n\n-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0\n-- These two virtual projectile templates exist only in FilesCache.\n-- Chain every earlier scanner and publish their logical folders once.\nlocal SCO_FaAirFighterScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_FaAirFighterScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n\n    local fighterFolders = {\n        directory .. \"pef102\",\n        directory .. \"pgf102\",\n    }\n    for _, fighterFolder in ipairs(fighterFolders) do\n        local found = false\n        for _, folder in ipairs(folders) do\n            if folder == fighterFolder then\n                found = true\n                break\n            end\n        end\n        if not found then\n            table.insert(folders, fighterFolder)\n        end\n    end\n    return folders\nend";

	private const string ProwlerExhaustClientAppendix = "\n\n-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0\n-- Prowler landed-exhaust lifecycle 1.0.0. The native client has no motion\n-- callback, so its existing per-update audio pass supplies the supported speed sample.\nlocal SCO_FaAirFighterClientUnit = ClientUnit\nlocal SCO_ProwlerExhaustSpeedEpsilon = 0.01\nlocal function SCO_IsProwlerExhaustOwner(unit)\n    return unit.tpId == \"uga1201\"\n        and unit.tp and unit.tp.additions\n        and unit.tp.additions.prowlerExhaustLifecycle == true\nend\n\nlocal SCO_ProwlerStockRecalculatePersistentEffectsState = SCO_FaAirFighterClientUnit.RecalculatePersistentEffectsState\nfunction SCO_FaAirFighterClientUnit:RecalculatePersistentEffectsState()\n    if not SCO_IsProwlerExhaustOwner(self) then\n        return SCO_ProwlerStockRecalculatePersistentEffectsState(self)\n    end\n    local enabled = self.persistentEffectsEnabled == true\n        and self:IsIntelVisionVisible() == true\n        and self.scoProwlerExhaustMoving == true\n    self:SetPersistentEffectsState(self.persistentEffects, enabled)\nend\n\nlocal SCO_ProwlerStockUpdateAudio = SCO_FaAirFighterClientUnit.UpdateAudio\nfunction SCO_FaAirFighterClientUnit:UpdateAudio(...)\n    local result = SCO_ProwlerStockUpdateAudio(self, ...)\n    if not SCO_IsProwlerExhaustOwner(self) then\n        return result\n    end\n    local moving = false\n    if not self.dead then\n        local _, currentSpeed = Engine.GetMovementCurrentSpeed(self.id)\n        moving = type(currentSpeed) == \"number\"\n            and currentSpeed > SCO_ProwlerExhaustSpeedEpsilon\n    end\n    if self.scoProwlerExhaustMoving ~= moving then\n        self.scoProwlerExhaustMoving = moving\n        self:RecalculatePersistentEffectsState()\n    end\n    return result\nend";

	public static void Apply()
	{
		ValidatePinnedScope();
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			FighterSpec[] fighterSpecs = FighterSpecs;
			foreach (FighterSpec fighter in fighterSpecs)
			{
				Func<string, string> upgradePatched = ((fighter.TargetId == "uga1201") ? new Func<string, string>(UpgradeProwlerExhaust) : null);
				QueueAppend(obj, list, fighter.RelativePath, fighter.Description, delegate(string source)
				{
					ValidateStockUnit(source, fighter);
				}, BuildUnitOverride(fighter), delegate(string source)
				{
					ValidatePatchedUnit(source, fighter);
				}, upgradePatched);
			}
			QueueAppend(obj, list, "LJ/lua/client/units/unitsClasses/unitsBaseClass.lua", "Prowler landed-exhaust client lifecycle", ValidateStockProwlerExhaustLifecycle, "\n\n-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0\n-- Prowler landed-exhaust lifecycle 1.0.0. The native client has no motion\n-- callback, so its existing per-update audio pass supplies the supported speed sample.\nlocal SCO_FaAirFighterClientUnit = ClientUnit\nlocal SCO_ProwlerExhaustSpeedEpsilon = 0.01\nlocal function SCO_IsProwlerExhaustOwner(unit)\n    return unit.tpId == \"uga1201\"\n        and unit.tp and unit.tp.additions\n        and unit.tp.additions.prowlerExhaustLifecycle == true\nend\n\nlocal SCO_ProwlerStockRecalculatePersistentEffectsState = SCO_FaAirFighterClientUnit.RecalculatePersistentEffectsState\nfunction SCO_FaAirFighterClientUnit:RecalculatePersistentEffectsState()\n    if not SCO_IsProwlerExhaustOwner(self) then\n        return SCO_ProwlerStockRecalculatePersistentEffectsState(self)\n    end\n    local enabled = self.persistentEffectsEnabled == true\n        and self:IsIntelVisionVisible() == true\n        and self.scoProwlerExhaustMoving == true\n    self:SetPersistentEffectsState(self.persistentEffects, enabled)\nend\n\nlocal SCO_ProwlerStockUpdateAudio = SCO_FaAirFighterClientUnit.UpdateAudio\nfunction SCO_FaAirFighterClientUnit:UpdateAudio(...)\n    local result = SCO_ProwlerStockUpdateAudio(self, ...)\n    if not SCO_IsProwlerExhaustOwner(self) then\n        return result\n    end\n    local moving = false\n    if not self.dead then\n        local _, currentSpeed = Engine.GetMovementCurrentSpeed(self.id)\n        moving = type(currentSpeed) == \"number\"\n            and currentSpeed > SCO_ProwlerExhaustSpeedEpsilon\n    end\n    if self.scoProwlerExhaustMoving ~= moving then\n        self.scoProwlerExhaustMoving = moving\n        self:RecalculatePersistentEffectsState()\n    end\n    return result\nend", ValidateProwlerExhaustLifecycle, null);
			QueueAppend(obj, list, "LJ/lua/common/systems/import.lua", "FA air-fighter virtual-projectile scanner", ValidateStockImportScanner, "\n\n-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0\n-- These two virtual projectile templates exist only in FilesCache.\n-- Chain every earlier scanner and publish their logical folders once.\nlocal SCO_FaAirFighterScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_FaAirFighterScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n\n    local fighterFolders = {\n        directory .. \"pef102\",\n        directory .. \"pgf102\",\n    }\n    for _, fighterFolder in ipairs(fighterFolders) do\n        local found = false\n        for _, folder in ipairs(folders) do\n            if folder == fighterFolder then\n                found = true\n                break\n            end\n        end\n        if not found then\n            table.insert(folders, fighterFolder)\n        end\n    end\n    return folders\nend", ValidateImportScanner, null);
			ProjectileSpec[] projectileSpecs = ProjectileSpecs;
			foreach (ProjectileSpec projectile in projectileSpecs)
			{
				QueueVirtualProjectile(obj, list, projectile);
			}
			if (list.Count == 0)
			{
				Log("Both FA T1 fighters and their dedicated projectiles are already current.");
				return;
			}
			Commit(obj, list);
			Log("Applied exact UEA0102/URA0102 fighter stats and racks to uea1201/uga1201 with preserved classes, isolated projectiles, and Prowler landed-exhaust lifecycle.");
		}
		catch (Exception arg)
		{
			if (obj != null)
			{
				RollBack(obj, list);
			}
			else
			{
				DisposeUncommitted(list);
			}
			Log($"Failed to apply the FA air-fighter transaction: {arg}");
			throw;
		}
	}

	private static void ValidatePinnedScope()
	{
		if (FighterSpecs.Length != 2 || FighterSpecs[0].TargetId != "uea1201" || FighterSpecs[0].SourceId != "UEA0102" || FighterSpecs[1].TargetId != "uga1201" || FighterSpecs[1].SourceId != "URA0102" || ProjectileSpecs.Length != 2 || ProjectileSpecs[0].Id != "pef102" || ProjectileSpecs[1].Id != "pgf102" || FighterSpecs.Select((FighterSpec spec) => spec.TargetId).Distinct<string>(StringComparer.Ordinal).Count() != 2 || ProjectileSpecs.Select((ProjectileSpec spec) => spec.Id).Distinct<string>(StringComparer.Ordinal).Count() != 2)
		{
			throw new InvalidOperationException("The FA air-fighter patch scope changed from its reviewed pair.");
		}
		ProjectileSpec[] projectileSpecs = ProjectileSpecs;
		foreach (ProjectileSpec projectileSpec in projectileSpecs)
		{
			if (projectileSpec.SourceBlueprintSha256.Length != 64 || projectileSpec.SourceScriptSha256.Length != 64)
			{
				throw new InvalidOperationException(projectileSpec.SourceId + " has an invalid source hash lock.");
			}
		}
	}

	private static string BuildUnitOverride(FighterSpec fighter)
	{
		string[] source = new string[14]
		{
			"PRODUCTSC1", "SELECTABLE", "BUILTBYTIER1FACTORY", "BUILTBYTIER2FACTORY", "BUILTBYTIER3FACTORY", fighter.SourceFactionCategory, "MOBILE", "AIR", "HIGHALTAIR", "TECH1",
			"ANTIAIR", "VISIBLETORECON", "RECLAIMABLE", "OVERLAYANTIAIR"
		};
		string text = string.Join("\n", source.Select((string category) => "        \"" + category + "\","));
		string text2 = ((fighter.TargetId == "uea1201") ? "UnitTemplate.additions.prowlerExhaustLifecycle = nil\nUnitTemplate.visuals.effectsPersistent = {\n    { boneName = \"Exhaust_Right\", particleName = \"VFX/Unit/veu4101_exhaust_aircraft_small.sanvfx\" },\n    { boneName = \"Exhaust_Right01\", particleName = \"VFX/Unit/veu4101_exhaust_aircraft_small.sanvfx\" },\n}" : "UnitTemplate.additions.prowlerExhaustLifecycle = true\nUnitTemplate.visuals.effectsPersistent = {\n    { boneName = \"Exhaust\", particleName = \"VFX/SCOM/FieldFixes/Prowler/exhaust_attached.sanvfx\" },\n}");
		string text3 = ((fighter.TargetId == "uea1201") ? BuildUefWeapons() : BuildGuardWeapons());
		string text4 = ((fighter.TargetId == "uea1201") ? BuildUefWeaponContract() : BuildGuardWeaponContract());
		string text5 = ((fighter.TargetId == "uea1201") ? "true" : "false");
		return string.Format("\n\n{0}\n-- Installed FA units.scd is the authority. Sanctuary has no public\n-- KLift/KLiftDamping/LiftFactor/KMove/KTurn controller fields, so\n-- those values remain explicit provenance while Plane speed,\n-- minimum speed, preferred altitude, and derived orbit values use\n-- the supported native controller.\nUnitTemplate.additions = UnitTemplate.additions or {{}}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {{\n    size = {{ x = {1}, y = {2} }},\n    offset = {{ x = 0, y = 0, z = 0 }},\n}}\nUnitTemplate.additions.faSourceContract = {{\n    sourceId = \"{3}\",\n    targetId = \"{4}\",\n    sourceArchiveSha256 = \"{5}\",\n    sourceBlueprint = \"{6}\",\n    sourceBlueprintSha256 = \"{7}\",\n    sourceCategories = {{\n{8}\n    }},\n    collision = {{\n        centerOffset = {{ x = 0, y = 0, z = 0 }},\n        size = {{ x = 1, y = 0.2, z = 1 }},\n    }},\n    selection = {{\n        size = {{ x = {9}, y = {10} }},\n        thickness = {11},\n    }},\n    footprint = {{ x = 1, y = 1, sourceMaxSlope = 0.25 }},\n    sourceSizeSphere = 1.6,\n    movement = {{\n        sourceMotionType = \"RULEUMT_Air\",\n        sourceElevation = 18,\n        sourcePhysicsMaxSpeed = 0.5,\n        sourceMaxAirspeed = 15,\n        sourceMinAirspeed = 10,\n        sourceAutoLandTime = 1,\n        sourceBankFactor = 2,\n        sourceBankForward = false,\n        sourceBreakOffDistance = 5,\n        sourceBreakOffTrigger = 15,\n        sourceCanFly = true,\n        sourceCombatTurnSpeed = 1.5,\n        sourceEngageDistance = 50,\n        sourceKLift = 3,\n        sourceKLiftDamping = 2.5,\n        sourceLiftFactor = 7,\n        sourceKMove = 1,\n        sourceKMoveDamping = 1,\n        sourceKRoll = 2,\n        sourceKRollDamping = 1,\n        sourceKTurn = 1,\n        sourceKTurnDamping = 1.5,\n        sourceStartTurnDistance = 5,\n        sourceTightTurnMultiplier = 1.02,\n        sourceTurnSpeed = 1.5,\n        sourceWinged = true,\n        sourceFuelRechargeRate = 5,\n        sourceFuelUseTime = 300,\n        nativeAccelerationFallback = 15,\n        nativeRotationSpeedFallback = 90,\n        nativeOrbitRange = {12},\n        nativeOrbitSpeed = 10,\n    }},\n    deathImpact = {{\n        label = \"DeathImpact\",\n        weaponCategory = \"Death\",\n        aboveWaterTargetsOnly = {13},\n        damage = 25,\n        damageRadius = 1,\n        damageFriendly = true,\n        damageType = \"Normal\",\n        firingTolerance = 2,\n    }},\n    weapons = {{\n{14}\n    }},\n}}\n\nUnitTemplate.general.displayName = \"{15}\"\nUnitTemplate.general.name = \"{16}\"\nUnitTemplate.general.icon = {{ shape = \"air1\", symbol = \"aa\", tech = \"t1\" }}\nUnitTemplate.general.iconUI = \"tech1_air1_antiAir.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 30\nUnitTemplate.general.iconUIType = \"air\"\n\nUnitTemplate.collisionInfo = {{\n    centerOffset = {{ x = 0, y = 0, z = 0 }},\n    collisionSize = {{ x = 1, y = 0.2, z = 1 }},\n}}\nUnitTemplate.footprint = {{ x = 1, y = 1 }}\nUnitTemplate.visuals = UnitTemplate.visuals or {{}}\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {{}}\nUnitTemplate.visuals.selection.size = {{ x = {17}, y = {18} }}\nUnitTemplate.visuals.selection.offset = {{ x = 0, y = 0, z = 0 }}\n\nUnitTemplate.defence = UnitTemplate.defence or {{}}\nUnitTemplate.defence.health = {{ max = {19}, regen = 0, value = {20} }}\nUnitTemplate.economy = {{\n    buildTime = 500,\n    cost = {{ alloys = 50, energy = 2250 }},\n}}\nUnitTemplate.intel = {{ visionRadius = 28 }}\n\nUnitTemplate.movement = UnitTemplate.movement or {{}}\nUnitTemplate.movement.type = \"Plane\"\nUnitTemplate.movement.speed = 15\nUnitTemplate.movement.minSpeed = 10\nUnitTemplate.movement.acceleration = 15\nUnitTemplate.movement.deceleration = nil\nUnitTemplate.movement.rotationSpeed = 90\nUnitTemplate.movement.air = true\nUnitTemplate.movement.airHover = false\nUnitTemplate.movement.landWhenIdleSeconds = 1\nUnitTemplate.movement.altitudeJitterFactor = 1\nUnitTemplate.movement.bankFactor = 1\nUnitTemplate.movement.orbitRange = {21}\nUnitTemplate.movement.orbitSpeed = 10\nUnitTemplate.movement.collisionMaskDefault = {{ \"Air\" }}\nUnitTemplate.movement.collisionMaskSpawn = {{ \"LandSmall\" }}\nUnitTemplate.movement.referenceAltitude = \"GroundOrWater\"\nUnitTemplate.movement.preferredAltitude = 18\nUnitTemplate.movement.terrainAlignmentFactor = 0\nUnitTemplate.movement.sortOrder = 1\nUnitTemplate.movement.elevation = nil\nUnitTemplate.movement.continuous = nil\nUnitTemplate.movement.targetCirclingRadius = nil\nUnitTemplate.movement.targetCirclingSpeed = nil\nUnitTemplate.movement.targetCirclingTime = nil\nUnitTemplate.movement.walkAnimation = nil\n\nUnitTemplate.tags = {{\n    \"AIR\",\n    \"ANTI_AIR\",\n    \"BUILDABLE_BY_T1_FACTORY\",\n    \"BUILDABLE_BY_T2_FACTORY\",\n    \"BUILDABLE_BY_T3_FACTORY\",\n    \"{22}\",\n    \"FIGHTER\",\n    \"MOBILE\",\n    \"TECH1\",\n}}\n\n{23}\n\n-- Both source fighters are no-SCA units. Remove donor animation and\n-- bind only explicit native fallback exhausts to verified source bones.\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.persistantEffects = nil\n{24}\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do\n            effect.boneName = \"Root\"\n        end\n    end\nend", "-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0", Lua(fighter.SelectionX), Lua(fighter.SelectionZ), fighter.SourceId, fighter.TargetId, "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", fighter.SourceBlueprintPath, fighter.SourceBlueprintSha256, text, Lua(fighter.SelectionX), Lua(fighter.SelectionZ), Lua(fighter.SelectionThickness), "6.366197723675814", text5, text4, fighter.Name, fighter.Name, Lua(fighter.SelectionX), Lua(fighter.SelectionZ), fighter.Health, fighter.Health, "6.366197723675814", fighter.FactionTag, text3, text2).Replace("\r\n", "\n");
	}

	private static string BuildUefWeaponContract()
	{
		return "            {\n                label = \"LinkedRailGun\",\n                sourceProjectileArchiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n                sourceProjectile = \"projectiles/TAARailgun01/TAARailgun01_proj.bp\",\n                sourceProjectileSha256 = \"27f4839a8b5b048073055a42fc728537303e8fae0a28266fe6674fbdb18bbc8f\",\n                sourceProjectileScript = \"projectiles/TAARailgun01/TAARailgun01_script.lua\",\n                sourceProjectileScriptSha256 = \"36c2417368fb105b30325e2ee1fa1f63f51c79ddf18e0fece8842108333cd92e\",\n                rackBone = \"Muzzle\",\n                muzzleBones = { \"Muzzle\" },\n                damage = 50,\n                maxRadius = 25,\n                muzzleVelocity = 120,\n                muzzleSalvoDelay = 0,\n                muzzleSalvoSize = 1,\n                projectilesPerOnFire = 1,\n                rateOfFire = 1,\n                projectileLifetimeUsesMultiplier = 1.25,\n                firingTolerance = 0,\n                targetOnly = \"AIR\",\n                targetDisallow = \"UNTARGETABLE,LAND,STRUCTURE,NAVAL\",\n                weaponLayers = { \"Air\", \"Land\" },\n                targetLayers = { \"Air\" },\n            },";
	}

	private static string BuildGuardWeaponContract()
	{
		return "            {\n                label = \"AutoCannon\",\n                sourceProjectileArchiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n                sourceProjectile = \"projectiles/CAAAutocannon02/CAAAutocannon02_proj.bp\",\n                sourceProjectileSha256 = \"196d6739b1349438378aab28cdef2df8a1c5a346cebf1bbe290071786abb4957\",\n                sourceProjectileScript = \"projectiles/CAAAutocannon02/CAAAutocannon02_script.lua\",\n                sourceProjectileScriptSha256 = \"57f5695e460493503a05a77dcd7e7a0524c545c19e9ec9d63b3f48f0ff843dca\",\n                rackBone = \"Left_Muzzle01\",\n                muzzleBones = { \"Left_Muzzle01\" },\n                damage = 8,\n                maxRadius = 25,\n                muzzleVelocity = 120,\n                muzzleSalvoDelay = 0.1,\n                muzzleSalvoSize = 3,\n                projectilesPerOnFire = 3,\n                rateOfFire = 1,\n                projectileLifetimeUsesMultiplier = 1.25,\n                firingTolerance = 0.1,\n                targetOnly = \"AIR\",\n                targetDisallow = \"UNTARGETABLE,LAND,STRUCTURE,NAVAL\",\n                weaponLayers = { \"Air\", \"Land\" },\n                targetLayers = { \"Air\" },\n            },\n            {\n                label = \"AutoCannon2\",\n                sourceProjectileArchiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n                sourceProjectile = \"projectiles/CAAAutocannon02/CAAAutocannon02_proj.bp\",\n                sourceProjectileSha256 = \"196d6739b1349438378aab28cdef2df8a1c5a346cebf1bbe290071786abb4957\",\n                sourceProjectileScript = \"projectiles/CAAAutocannon02/CAAAutocannon02_script.lua\",\n                sourceProjectileScriptSha256 = \"57f5695e460493503a05a77dcd7e7a0524c545c19e9ec9d63b3f48f0ff843dca\",\n                rackBone = \"Right_Muzzle01\",\n                muzzleBones = { \"Right_Muzzle01\" },\n                damage = 8,\n                maxRadius = 25,\n                muzzleVelocity = 120,\n                muzzleSalvoDelay = 0.1,\n                muzzleSalvoSize = 3,\n                projectilesPerOnFire = 3,\n                rateOfFire = 1,\n                projectileLifetimeUsesMultiplier = 1.25,\n                firingTolerance = 0.1,\n                alwaysRecheckTarget = true,\n                prefersPrimaryWeaponTarget = true,\n                targetOnly = \"AIR\",\n                targetDisallow = \"UNTARGETABLE,LAND,STRUCTURE,NAVAL\",\n                weaponLayers = { \"Air\", \"Land\" },\n                targetLayers = { \"Air\" },\n            },";
	}

	private static string BuildUefWeapons()
	{
		return "UnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Muzzle\",\n                aimTolerance = 0,\n                defaultPitchAdjustment = 0,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = \"Muzzle\",\n                pitchMax = 55,\n                pitchMin = -55,\n                pitchSpeed = 360,\n                poseResetTime = 0,\n                projectileSpeed = 120,\n                solverType = \"NoArc\",\n                yawBone = \"Muzzle\",\n                yawMax = 55,\n                yawMin = -55,\n                yawSpeed = 360,\n            },\n        },\n        audio = { onFire = { looping = false, name = \"aeom1112\" } },\n        collideFriendly = false,\n        damage = 50,\n        damageFriendly = false,\n        damageRadius = 0,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vem1121_autocannon_antiair_small_muzzle.sanvfx\" },\n        firingRandomness = 0,\n        layerTargetLimits = { \"Air\" },\n        layerWeaponLimits = { \"Air\", \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Muzzle\" } } },\n        muzzles = { [\"Muzzle\"] = { aimController = \"Muzzle\" } },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 0.2604166666666667,\n        projectileTemplate = \"pef102\",\n        rangeMax = 25,\n        rangeMin = 0,\n        rangeRingType = \"AntiAir\",\n        rangeTracking = 1.25,\n        reloadTime = 1,\n        targetWaterLimits = \"Above\",\n    },\n    {\n        category = \"DeathExplosion\",\n        damage = 25,\n        damageRadius = 1,\n        damageFriendly = true,\n        damageType = \"Normal\",\n    },\n}";
	}

	private static string BuildGuardWeapons()
	{
		return "-- FA emits ProjectilesPerOnFire=3 from one physical muzzle on each of\n-- three rack salvos. Sanctuary has no ProjectilesPerOnFire field, so\n-- three entries for the same verified endpoint reproduce each parallel\n-- triple while muzzleSalvoSize preserves the three sequential salvos.\nlocal function SCO_ProwlerAutocannon(muzzle)\n    return {\n        aimControllers = {\n            {\n                aimBone = muzzle,\n                aimTolerance = 0.1,\n                defaultPitchAdjustment = 0,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = muzzle,\n                pitchMax = 55,\n                pitchMin = -55,\n                pitchSpeed = 360,\n                poseResetTime = 0,\n                projectileSpeed = 120,\n                solverType = \"NoArc\",\n                yawBone = muzzle,\n                yawMax = 55,\n                yawMin = -55,\n                yawSpeed = 360,\n            },\n        },\n        audio = { onFire = { looping = false, name = \"agom1115\" } },\n        collideFriendly = false,\n        damage = 8,\n        damageFriendly = false,\n        damageRadius = 0,\n        damageType = \"Normal\",\n        firingRandomness = 0,\n        layerTargetLimits = { \"Air\" },\n        layerWeaponLimits = { \"Air\", \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = -1,\n        muzzleGroups = {\n            { muzzles = { muzzle, muzzle, muzzle } },\n        },\n        muzzles = { [muzzle] = { aimController = muzzle } },\n        muzzleSalvoDelay = 0.1,\n        muzzleSalvoSize = 3,\n        projectileLifetime = 0.2604166666666667,\n        projectileTemplate = \"pgf102\",\n        rangeMax = 25,\n        rangeMin = 0,\n        rangeRingType = \"AntiAir\",\n        rangeTracking = 1.25,\n        reloadTime = 1,\n        targetWaterLimits = \"Above\",\n    }\nend\nUnitTemplate.weapons = {\n    SCO_ProwlerAutocannon(\"Left_Muzzle01\"),\n    SCO_ProwlerAutocannon(\"Right_Muzzle01\"),\n    {\n        category = \"DeathExplosion\",\n        damage = 25,\n        damageRadius = 1,\n        damageFriendly = true,\n        damageType = \"Normal\",\n    },\n}";
	}

	private static string BuildVirtualProjectile(ProjectileSpec projectile)
	{
		return "---@type ProjectileTemplate\nProjectileTemplate = {\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"" + projectile.Name + "\",\n        tpId = \"" + projectile.Id + "\",\n    },\n    -- FA " + projectile.SourceId + " is a gravity-free, velocity-aligned\n    -- direct projectile at InitialSpeed=120. Omitting movement makes\n    -- Sanctuary use the weapon's exact 120-speed NoArc solution. The\n    -- FA emitter graph is not a supported sanvfx input, so this private\n    -- template uses an explicit same-faction native small-AA fallback;\n    -- it never routes through Aeon projectile assets.\n    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\n    -- Source blueprint: " + projectile.SourceBlueprintPath + "\n    -- Source blueprint SHA-256: " + projectile.SourceBlueprintSha256 + "\n    -- Source script: " + projectile.SourceScriptPath + "\n    -- Source script SHA-256: " + projectile.SourceScriptSha256 + "\n    nonUniformScale = { x = 1, y = 1, z = 1 },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = {\n            { effects = { { particleName = \"" + projectile.ImpactVfx + "\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"" + projectile.TrailVfx + "\" } } },\n        },\n    },\n}\n\n-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0";
	}

	private static void ValidateStockUnit(string source, FighterSpec fighter)
	{
		RequireTokens(source, "UnitTemplate =", "tpId = \"" + fighter.TargetId + "\"", "\"" + fighter.ExpectedClassOwner + "\"", "\"" + fighter.ExpectedUnitClass + "\"");
		RequireExactly(source, "tpId = \"" + fighter.TargetId + "\"", 1, fighter.TargetId + " stock tpId");
		string pattern = "class\\s*=\\s*\\{\\s*\"" + Regex.Escape(fighter.ExpectedClassOwner) + "\"\\s*,\\s*\"" + Regex.Escape(fighter.ExpectedUnitClass) + "\"\\s*,?\\s*\\}";
		if (!Regex.IsMatch(source, pattern, RegexOptions.CultureInvariant))
		{
			throw new InvalidOperationException(fighter.Description + " no longer exposes its reviewed Sanctuary class table.");
		}
	}

	private static void ValidatePatchedUnit(string source, FighterSpec fighter)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0", 1, fighter.TargetId + " fighter marker");
		string source2 = source.Substring(source.IndexOf("-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0", StringComparison.Ordinal));
		RequireTokens(source2, "sourceId = \"" + fighter.SourceId + "\"", "sourceBlueprintSha256 = \"" + fighter.SourceBlueprintSha256 + "\"", "UnitTemplate.general.name = \"" + fighter.Name + "\"", $"max = {fighter.Health}", "collisionSize = { x = 1, y = 0.2, z = 1 }", "UnitTemplate.visuals.selection.size = { x = " + Lua(fighter.SelectionX) + ", y = " + Lua(fighter.SelectionZ) + " }", "buildTime = 500", "cost = { alloys = 50, energy = 2250 }", "visionRadius = 28", "UnitTemplate.movement.type = \"Plane\"", "UnitTemplate.movement.speed = 15", "UnitTemplate.movement.minSpeed = 10", "UnitTemplate.movement.acceleration = 15", "UnitTemplate.movement.rotationSpeed = 90", "UnitTemplate.movement.preferredAltitude = 18", "UnitTemplate.movement.orbitRange = 6.366197723675814", "UnitTemplate.movement.orbitSpeed = 10", "sourceKLift = 3", "sourceKLiftDamping = 2.5", "sourceLiftFactor = 7", "UnitTemplate.visuals.animations = nil", "category = \"DeathExplosion\"", "damageRadius = 1", "damageFriendly = true");
		RequireExactly(source2, "damage = 25", 2, fighter.TargetId + " death-impact provenance/runtime values");
		RequireNotContains(source2, "AeonProjectiles", "pad002", "pcl001", "Turret01_", "Turret02_");
		if (fighter.TargetId == "uea1201")
		{
			RequireTokens(source2, "aimBone = \"Muzzle\"", "projectileTemplate = \"pef102\"", "damage = 50", "muzzleSalvoSize = 1", "{ muzzles = { \"Muzzle\" } }", "UnitTemplate.additions.prowlerExhaustLifecycle = nil", "boneName = \"Exhaust_Right\"", "boneName = \"Exhaust_Right01\"");
			RequireExactly(source2, "projectileTemplate = \"pef102\"", 1, "UEF linked railgun");
		}
		else
		{
			RequireTokens(source2, "SCO_ProwlerAutocannon(\"Left_Muzzle01\")", "SCO_ProwlerAutocannon(\"Right_Muzzle01\")", "projectileTemplate = \"pgf102\"", "damage = 8", "muzzleSalvoDelay = 0.1", "muzzleSalvoSize = 3", "{ muzzles = { muzzle, muzzle, muzzle } }", "UnitTemplate.additions.prowlerExhaustLifecycle = true", "{ boneName = \"Exhaust\", particleName = \"VFX/SCOM/FieldFixes/Prowler/exhaust_attached.sanvfx\" }");
			RequireExactly(source2, "SCO_ProwlerAutocannon(\"", 2, "Guard distinct autocannon racks");
			RequireExactly(source2, "boneName = \"Exhaust\"", 1, "Guard native exhaust attachment");
			RequireExactly(source2, "boneName = \"EngineVFX01\"", 0, "Guard invalid engine VFX attachment");
		}
	}

	private static void ValidateStockProwlerExhaustLifecycle(string source)
	{
		RequireTokens(source, "function ClientUnit:UpdateAudio(health, maxHealth)", "function ClientUnit:RecalculatePersistentEffectsState()", "Engine.GetMovementCurrentSpeed(self.id)");
	}

	private static void ValidateProwlerExhaustLifecycle(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0", 1, "Prowler exhaust lifecycle marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "-- Prowler landed-exhaust lifecycle 1.0.0", "local SCO_FaAirFighterClientUnit = ClientUnit", "local SCO_ProwlerExhaustSpeedEpsilon = 0.01", "unit.tpId == \"uga1201\"", "unit.tp.additions.prowlerExhaustLifecycle == true", "local SCO_ProwlerStockRecalculatePersistentEffectsState", "function SCO_FaAirFighterClientUnit:RecalculatePersistentEffectsState()", "self.scoProwlerExhaustMoving == true", "local SCO_ProwlerStockUpdateAudio", "function SCO_FaAirFighterClientUnit:UpdateAudio(...)", "local _, currentSpeed = Engine.GetMovementCurrentSpeed(self.id)", "currentSpeed > SCO_ProwlerExhaustSpeedEpsilon", "self.scoProwlerExhaustMoving = moving");
		RequireExactly(source2, "function SCO_FaAirFighterClientUnit:RecalculatePersistentEffectsState()", 1, "Prowler persistent-effect gate");
		RequireExactly(source2, "function SCO_FaAirFighterClientUnit:UpdateAudio(...)", 1, "Prowler speed sampler");
	}

	private static void ValidateStockImportScanner(string source)
	{
		RequireTokens(source, "function ScanDir", "Engine.GetFoldersInsideDirectory");
	}

	private static void ValidateImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0", 1, "fighter scanner marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "local SCO_FaAirFighterScanDir = ScanDir", "function ScanDir(directory)", "local folders = SCO_FaAirFighterScanDir(directory)", "directory .. \"pef102\"", "directory .. \"pgf102\"");
		RequireExactly(source2, "function ScanDir(directory)", 1, "fighter scanner function");
		RequireExactly(source2, "table.insert(folders, fighterFolder)", 1, "fighter scanner insertion");
		RequireNotContains(source2, "scanRoot");
	}

	private static void ValidateVirtualProjectile(string source, ProjectileSpec projectile)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0", 1, projectile.Id + " marker");
		RequireTokens(source, "ProjectileTemplate =", "tpId = \"" + projectile.Id + "\"", "name = \"" + projectile.Name + "\"", projectile.SourceId, "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12", projectile.SourceBlueprintPath, projectile.SourceBlueprintSha256, projectile.SourceScriptPath, projectile.SourceScriptSha256, "InitialSpeed=120", "gravity-free", projectile.ImpactVfx, projectile.TrailVfx);
		RequireNotContains(source, "movement =", "AeonProjectiles", "pad002", "pcl001");
	}

	private static void QueueAppend(object cache, List<CacheMutation> mutations, string relativePath, string description, Action<string> validateStock, string appendix, Action<string> validatePatched)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		if (resourceText.IndexOf("-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0", StringComparison.Ordinal) >= 0)
		{
			validatePatched(resourceText);
			return;
		}
		validateStock(resourceText);
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), AppendOverride(resourceText, appendix));
		try
		{
			validatePatched(GetResourceText(obj));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, description));
		}
		catch
		{
			TryDisposeNativeArray(obj, "uncommitted " + description);
			throw;
		}
	}

	private static void QueueVirtualProjectile(object cache, List<CacheMutation> mutations, ProjectileSpec projectile)
	{
		string relativePath = ProjectileRelativePath(projectile.Id);
		string text = projectile.SourceId + " virtual projectile";
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath, text);
		if (cacheResource != null)
		{
			string resourceText = GetResourceText(cacheResource.Stock);
			if (resourceText.IndexOf("-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0", StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Reserved fighter projectile ID " + projectile.Id + " already exists without the fighter marker.");
			}
			ValidateVirtualProjectile(resourceText, projectile);
			return;
		}
		string source = BuildVirtualProjectile(projectile);
		ValidateVirtualProjectile(source, projectile);
		object obj = CreateNativeArrayFromText(GetNativeArrayType(cache), source);
		try
		{
			ValidateVirtualProjectile(GetResourceText(obj), projectile);
			mutations.Add(new CacheMutation(ResolvePath(relativePath), null, obj, added: true, text));
		}
		catch
		{
			TryDisposeNativeArray(obj, "uncommitted " + text);
			throw;
		}
	}

	private static void Commit(object cache, IReadOnlyList<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			mutation.Assigned = true;
			SetCachedResource(cache, mutation.Path, mutation.Replacement);
		}
		foreach (CacheMutation mutation2 in mutations)
		{
			if (mutation2.Stock != null)
			{
				TryDisposeNativeArray(mutation2.Stock, "stock " + mutation2.Description);
			}
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
					if (item.Added)
					{
						RemoveCachedResource(cache, item.Path);
					}
					else
					{
						SetCachedResource(cache, item.Path, item.Stock ?? throw new InvalidOperationException(item.Description + " has no stock resource."));
					}
					item.Assigned = false;
				}
				catch (Exception arg)
				{
					Log($"Rollback failed for {item.Description}: {arg}");
				}
			}
			if (!item.Assigned)
			{
				TryDisposeNativeArray(item.Replacement, "replacement " + item.Description);
			}
		}
	}

	private static void DisposeUncommitted(IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			TryDisposeNativeArray(mutation.Replacement, "uncommitted " + mutation.Description);
		}
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static CacheResource GetCachedResource(object cache, string relativePath, string description)
	{
		return TryGetCachedResource(cache, relativePath, description) ?? throw new FileNotFoundException("Required " + description + " was not present in Sanctuary's Lua cache.", relativePath);
	}

	private static CacheResource? TryGetCachedResource(object cache, string relativePath, string description)
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
			object obj3 = propertyInfo.GetValue(cache, new object[1] { text }) ?? throw new InvalidOperationException("Cached " + description + " has no value.");
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
				object obj4 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("Cached " + description + " has no value.");
				EnsureNativeArray(obj4, description);
				cacheResource = new CacheResource(text2, obj4);
			}
		}
		return cacheResource;
	}

	private static Type GetNativeArrayType(object cache)
	{
		foreach (object item in (IEnumerable)cache)
		{
			object obj = item.GetType().GetProperty("Value")?.GetValue(item);
			if (obj != null)
			{
				EnsureNativeArray(obj, "Lua cache resource");
				return obj.GetType();
			}
		}
		throw new InvalidOperationException("Sanctuary's Lua file cache contains no NativeArray resource type.");
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
		MethodInfo methodInfo = resource.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray");
		return Encoding.UTF8.GetString((byte[])methodInfo.Invoke(resource, null));
	}

	private static void EnsureNativeArray(object resource, string description)
	{
		object value = (resource.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource);
		if (!(value is bool) || !(bool)value)
		{
			throw new InvalidOperationException("Cached " + description + " is not an initialized NativeArray.");
		}
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void RemoveCachedResource(object cache, string path)
	{
		(cache.GetType().GetMethod("Remove", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(cache.GetType().FullName, "Remove")).Invoke(cache, new object[1] { path });
	}

	private static void TryDisposeNativeArray(object resource, string description)
	{
		try
		{
			object value = (resource.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource);
			if (value is bool && (bool)value)
			{
				(resource.GetType().GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "Dispose")).Invoke(resource, null);
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

	private static string ProjectileRelativePath(string projectileId)
	{
		return "LJ/lua/common/projectiles/projectilesTemplates/" + projectileId + "/" + projectileId + ".santp";
	}

	private static string OwnedAppendix(string source)
	{
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Fighter marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0".Length, StringComparison.Ordinal);
		if (num2 >= 0)
		{
			return source.Substring(num, num2 - num);
		}
		return source.Substring(num);
	}

	private static string Lua(double value)
	{
		return StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture);
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

	private static void RequireNotContains(string source, params string[] tokens)
	{
		foreach (string text in tokens)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) >= 0)
			{
				throw new InvalidOperationException("FA fighter-owned source must not contain '" + text + "'.");
			}
		}
	}

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int num = 0;
		int startIndex = 0;
		while ((startIndex = source.IndexOf(token, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += token.Length;
		}
		if (num != expected)
		{
			throw new InvalidOperationException($"Expected {expected} {description}, found {num}.");
		}
	}

	private static void Log(string message)
	{
		string text = "[FA Air Fighter Cache Patcher] " + message;
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

	private static string UpgradeProwlerExhaust(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0", 1, "Guard fighter appendix marker");
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0", StringComparison.Ordinal);
		string text = source.Substring(num);
		text = text.Replace("{ boneName = \"Exhaust\", particleName = \"VFX/Unit/vgu4301_exhaust_aircraft_large.sanvfx\" }", "{ boneName = \"EngineVFX01\", particleName = \"VFX/Unit/vgu4301_exhaust_aircraft_large.sanvfx\" }");
		RequireExactly(text, "UnitTemplate.visuals.effectsPersistent = {\n", 1, "Prowler effects table count");
		if (text.IndexOf("{ boneName = \"Exhaust\", particleName = \"VFX/SCOM/FieldFixes/Prowler/exhaust_attached.sanvfx\" }", StringComparison.Ordinal) >= 0)
		{
			RequireExactly(text, "{ boneName = \"Exhaust\", particleName = \"VFX/SCOM/FieldFixes/Prowler/exhaust_attached.sanvfx\" }", 1, "Guard native exhaust attachment");
			RequireExactly(text, "UnitTemplate.visuals.effectsPersistent = {\n    { boneName = \"Exhaust\", particleName = \"VFX/SCOM/FieldFixes/Prowler/exhaust_attached.sanvfx\" },\n}", 1, "Prowler exhaust binding provenance drifted");
			RequireExactly(text, "{ boneName = \"EngineVFX01\", particleName = \"VFX/Unit/vgu4301_exhaust_aircraft_large.sanvfx\" }", 0, "Guard invalid engine VFX attachment");
			return source;
		}
		RequireExactly(text, "{ boneName = \"EngineVFX01\", particleName = \"VFX/Unit/vgu4301_exhaust_aircraft_large.sanvfx\" }", 1, "legacy invalid Guard attachment");
		RequireExactly(text, "UnitTemplate.visuals.effectsPersistent = {\n    { boneName = \"EngineVFX01\", particleName = \"VFX/Unit/vgu4301_exhaust_aircraft_large.sanvfx\" },\n}", 1, "Prowler exhaust binding provenance drifted");
		RequireExactly(text, "{ boneName = \"Exhaust\", particleName = \"VFX/SCOM/FieldFixes/Prowler/exhaust_attached.sanvfx\" }", 0, "premature Guard native attachment");
		return source.Substring(0, num) + text.Replace("{ boneName = \"EngineVFX01\", particleName = \"VFX/Unit/vgu4301_exhaust_aircraft_large.sanvfx\" }", "{ boneName = \"Exhaust\", particleName = \"VFX/SCOM/FieldFixes/Prowler/exhaust_attached.sanvfx\" }");
	}

	private static void QueueAppend(object cache, List<CacheMutation> mutations, string relativePath, string description, Action<string> validateStock, string appendix, Action<string> validatePatched, [Optional] Func<string, string> upgradePatched)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		string text;
		if (resourceText.IndexOf("-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0", StringComparison.Ordinal) >= 0)
		{
			text = ((upgradePatched != null) ? upgradePatched(resourceText) : resourceText);
			if (text == resourceText)
			{
				validatePatched(resourceText);
				return;
			}
		}
		else
		{
			validateStock(resourceText);
			text = AppendOverride(resourceText, appendix);
		}
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), text);
		try
		{
			validatePatched(GetResourceText(obj));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, description));
		}
		catch
		{
			TryDisposeNativeArray(obj, "uncommitted " + description);
			throw;
		}
	}
}
