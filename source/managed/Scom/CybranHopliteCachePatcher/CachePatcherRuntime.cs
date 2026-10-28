using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace CybranHopliteCachePatcher;

public static class CachePatcherRuntime
{
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

	internal const string OverrideMarker = "-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0";

	private const string TargetTemplateRelativePath = "LJ/lua/common/units/unitsTemplates/ugl2101/ugl2101.santp";

	private const string ImportRelativePath = "LJ/lua/common/systems/import.lua";

	private const string ProjectileRootRelativePath = "LJ/lua/common/projectiles/projectilesTemplates";

	private const string HopliteProjectileId = "pgh204";

	private const string TemplateOverride = "\n\n-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0\n-- FA DRL0204 Hoplite replaces Guard UGL2101 completely.  The companion\n-- local-only asset delta supplies DRL0204's 23-bone walker, real three-rocket\n-- pack, and native walk loop; no stock Grenadier rig or high-arc weapon path\n-- remains active.\nUnitTemplate.general = UnitTemplate.general or {}\nUnitTemplate.general.displayName = \"Hoplite\"\nUnitTemplate.general.name = \"Hoplite\"\nUnitTemplate.general.icon = {\n    shape = \"land1\",\n    symbol = \"direct\",\n    tech = \"t2\",\n}\nUnitTemplate.general.iconUI = \"tech2_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 20\nUnitTemplate.general.iconUIType = \"land\"\n-- Sanctuary exposes the source Guard command as Assist.  The FA Hoplite has\n-- attack, move, patrol, stop, guard, transport-call, and retaliate commands;\n-- it has no construction, repair, capture, or reclaim capability.\nUnitTemplate.general.orders = {\n    Assist = true,\n    Attack = true,\n    AttackMove = true,\n    Move = true,\n    Patrol = true,\n    Stop = true,\n}\n\nUnitTemplate.tags = {\n    \"ANTI_SURFACE\",\n    \"BOT\",\n    \"BUILDABLE_BY_T2_FACTORY\",\n    \"BUILDABLE_BY_T3_FACTORY\",\n    \"DIRECT_FIRE\",\n    \"GUARD\",\n    \"LAND\",\n    \"MOBILE\",\n    \"TECH2\",\n}\n\nUnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = {\n    max = 450,\n    regen = 0,\n    value = 450,\n}\nUnitTemplate.economy = UnitTemplate.economy or {}\nUnitTemplate.economy.buildTime = 1000\nUnitTemplate.economy.cost = {\n    alloys = 200,\n    energy = 1000,\n}\nUnitTemplate.intel = UnitTemplate.intel or {}\nUnitTemplate.intel.visionRadius = 26\n\n-- DRL0204 has no authored CollisionOffsetY, so its source SizeY / 2 center\n-- is used.  Its intentionally compact source footprint remains distinct from\n-- the larger visual selection envelope.\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.4, z = 0 },\n    collisionSize = { x = 0.45, y = 0.8, z = 0.9 },\n}\nUnitTemplate.footprint = { x = 0.45, y = 0.9 }\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 0.75, y = 0.85 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.4, z = 0 }\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.75, y = 0.85 },\n    offset = { x = 0, y = 0.4, z = 0 },\n}\n\nUnitTemplate.movement = UnitTemplate.movement or {}\nUnitTemplate.movement.animClips = nil\nUnitTemplate.movement.type = \"LegsLand\"\nUnitTemplate.movement.acceleration = 3.5\nUnitTemplate.movement.deceleration = 3.6\nUnitTemplate.movement.rotationSpeed = 90\nUnitTemplate.movement.speed = 3.6\n-- Sanctuary advances movement-bound clips by velocity / authoredSpeed.\n-- DRL0204 has MaxSpeed=3.6 and AnimationWalkRate=3.7, so the exact source\n-- cadence is 3.6 / 3.7 = 0.972972972972973.\nUnitTemplate.movement.walkAnimation = { authoredSpeed = 0.972972972972973 }\nUnitTemplate.visuals.animations = {\n    walk = {\n        authoredSpeed = 0.972972972972973,\n        clipName = \"AnimWalk01\",\n        sanAnimationPath = \"Units/ugl2101/LOD0/ugl2101.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\n\n-- DRL0204 RocketBackpack: three sequential Iridium rockets, never the stock\n-- UGL2101 indirect-fire grenade.  One muzzle per group plus a three-salvo\n-- count reproduces FA's RackFireTogether=false semantics without firing nine\n-- rockets in Sanctuary's group-driven weapon state machine.\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Turret_Muzzle_01\",\n                aimTolerance = 0.1,\n                defaultPitchAdjustment = 0,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = \"Turret_Barrel\",\n                pitchMax = 45,\n                pitchMin = -45,\n                pitchSpeed = 100,\n                poseResetTime = 3,\n                projectileSpeed = 15,\n                solverType = \"LowArc\",\n                yawBone = \"Turret\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 50,\n            },\n        },\n        audio = {\n            onFire = {\n                looping = false,\n                name = \"agom3100\",\n            },\n        },\n        collideFriendly = false,\n        damage = 60,\n        damageFriendly = false,\n        damageRadius = 2,\n        damageType = \"Normal\",\n        effects = {\n            onFire = \"VFX/Muzzle/vem2101_rocket_antitank_small_muzzle.sanvfx\",\n        },\n        firingRandomness = 0,\n        layerTargetLimits = {\n            \"Land\",\n            \"WaterSurface\",\n        },\n        layerWeaponLimits = {\n            \"Land\",\n        },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = -1,\n        muzzleGroups = {\n            { muzzles = { \"Turret_Muzzle_01\" } },\n            { muzzles = { \"Turret_Muzzle_02\" } },\n            { muzzles = { \"Turret_Muzzle_03\" } },\n        },\n        muzzles = {\n            [\"Turret_Muzzle_01\"] = { aimController = \"Turret_Muzzle_01\" },\n            [\"Turret_Muzzle_02\"] = { aimController = \"Turret_Muzzle_01\" },\n            [\"Turret_Muzzle_03\"] = { aimController = \"Turret_Muzzle_01\" },\n        },\n        muzzleSalvoDelay = 0.2,\n        muzzleSalvoSize = 3,\n        projectileLifetime = 2.8366666666666664,\n        projectileTemplate = \"pgh204\",\n        rangeMax = 37,\n        rangeMin = 0,\n        rangeRingType = \"DirectFire\",\n        rangeTracking = 1.15,\n        reloadTime = 4,\n        targetWaterLimits = \"Above\",\n    },\n}";

	private const string ImportScannerAppendix = "\n\n-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0\n-- The virtual DRL0204 projectile lives in FilesCache rather than a physical\n-- source folder.  Chain the scanner installed by other SCO modules and expose\n-- its logical folder exactly once to Sanctuary's projectile loader.\nlocal SCO_HopliteScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_HopliteScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n\n    local hopliteFolder = directory .. \"pgh204\"\n    for _, folder in ipairs(folders) do\n        if folder == hopliteFolder then\n            return folders\n        end\n    end\n    table.insert(folders, hopliteFolder)\n    return folders\nend";

	private const string VirtualProjectileSource = "---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = {\n        onImpact = {\n            looping = false,\n            name = \"aeoi1112\",\n        },\n    },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.25, z = 0 },\n        collisionSize = { x = 0.5, y = 0.5, z = 0.5 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Cybran_Hoplite_Iridium_Rocket\",\n        tpId = \"pgh204\",\n    },\n    -- FA CDFRocketIridium02 uses InitialSpeed=35, MaxSpeed=45, TurnRate=0,\n    -- TrackTarget=true, MaxZigZag=5, and ZigZagFrequency=1. Sanctuary's public\n    -- projectile template API has no initial-speed or zig-zag fields.  The\n    -- source muzzle solution remains 15; this supported homing prefab ramps\n    -- immediately toward the source maximum while its zero turn rate keeps it\n    -- on the authored direct-fire line.  The source projectile mesh/VFX is\n    -- likewise unsupported by the loader, so compatible native rocket VFX\n    -- are intentionally explicit rather than pretending the grenade matches.\n    movement = {\n        acceleration = 120,\n        alignToVelocity = true,\n        gravityMultiplier = 0,\n        rotationSpeed = 0,\n        speedMax = 45,\n        type = \"TargetEntity\",\n    },\n    nonUniformScale = { x = 1, y = 1, z = 1 },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = {\n            {\n                effects = {\n                    {\n                        particleName = \"VFX/Impact/vei2101_rocket_antitank_small_impact.sanvfx\",\n                    },\n                },\n            },\n        },\n        persistantEffects = {\n            {\n                effects = {\n                    {\n                        particleName = \"VFX/Trails/vet2101_rocket_antitank_small_trail.sanvfx\",\n                    },\n                },\n            },\n        },\n    },\n}\n\n-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0";

	public static void Apply()
	{
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			QueueAppend(obj, list, "LJ/lua/common/units/unitsTemplates/ugl2101/ugl2101.santp", "Guard UGL2101 Hoplite target template", ValidateStockTemplate, "\n\n-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0\n-- FA DRL0204 Hoplite replaces Guard UGL2101 completely.  The companion\n-- local-only asset delta supplies DRL0204's 23-bone walker, real three-rocket\n-- pack, and native walk loop; no stock Grenadier rig or high-arc weapon path\n-- remains active.\nUnitTemplate.general = UnitTemplate.general or {}\nUnitTemplate.general.displayName = \"Hoplite\"\nUnitTemplate.general.name = \"Hoplite\"\nUnitTemplate.general.icon = {\n    shape = \"land1\",\n    symbol = \"direct\",\n    tech = \"t2\",\n}\nUnitTemplate.general.iconUI = \"tech2_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 20\nUnitTemplate.general.iconUIType = \"land\"\n-- Sanctuary exposes the source Guard command as Assist.  The FA Hoplite has\n-- attack, move, patrol, stop, guard, transport-call, and retaliate commands;\n-- it has no construction, repair, capture, or reclaim capability.\nUnitTemplate.general.orders = {\n    Assist = true,\n    Attack = true,\n    AttackMove = true,\n    Move = true,\n    Patrol = true,\n    Stop = true,\n}\n\nUnitTemplate.tags = {\n    \"ANTI_SURFACE\",\n    \"BOT\",\n    \"BUILDABLE_BY_T2_FACTORY\",\n    \"BUILDABLE_BY_T3_FACTORY\",\n    \"DIRECT_FIRE\",\n    \"GUARD\",\n    \"LAND\",\n    \"MOBILE\",\n    \"TECH2\",\n}\n\nUnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = {\n    max = 450,\n    regen = 0,\n    value = 450,\n}\nUnitTemplate.economy = UnitTemplate.economy or {}\nUnitTemplate.economy.buildTime = 1000\nUnitTemplate.economy.cost = {\n    alloys = 200,\n    energy = 1000,\n}\nUnitTemplate.intel = UnitTemplate.intel or {}\nUnitTemplate.intel.visionRadius = 26\n\n-- DRL0204 has no authored CollisionOffsetY, so its source SizeY / 2 center\n-- is used.  Its intentionally compact source footprint remains distinct from\n-- the larger visual selection envelope.\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.4, z = 0 },\n    collisionSize = { x = 0.45, y = 0.8, z = 0.9 },\n}\nUnitTemplate.footprint = { x = 0.45, y = 0.9 }\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 0.75, y = 0.85 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.4, z = 0 }\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.75, y = 0.85 },\n    offset = { x = 0, y = 0.4, z = 0 },\n}\n\nUnitTemplate.movement = UnitTemplate.movement or {}\nUnitTemplate.movement.animClips = nil\nUnitTemplate.movement.type = \"LegsLand\"\nUnitTemplate.movement.acceleration = 3.5\nUnitTemplate.movement.deceleration = 3.6\nUnitTemplate.movement.rotationSpeed = 90\nUnitTemplate.movement.speed = 3.6\n-- Sanctuary advances movement-bound clips by velocity / authoredSpeed.\n-- DRL0204 has MaxSpeed=3.6 and AnimationWalkRate=3.7, so the exact source\n-- cadence is 3.6 / 3.7 = 0.972972972972973.\nUnitTemplate.movement.walkAnimation = { authoredSpeed = 0.972972972972973 }\nUnitTemplate.visuals.animations = {\n    walk = {\n        authoredSpeed = 0.972972972972973,\n        clipName = \"AnimWalk01\",\n        sanAnimationPath = \"Units/ugl2101/LOD0/ugl2101.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\n\n-- DRL0204 RocketBackpack: three sequential Iridium rockets, never the stock\n-- UGL2101 indirect-fire grenade.  One muzzle per group plus a three-salvo\n-- count reproduces FA's RackFireTogether=false semantics without firing nine\n-- rockets in Sanctuary's group-driven weapon state machine.\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Turret_Muzzle_01\",\n                aimTolerance = 0.1,\n                defaultPitchAdjustment = 0,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = \"Turret_Barrel\",\n                pitchMax = 45,\n                pitchMin = -45,\n                pitchSpeed = 100,\n                poseResetTime = 3,\n                projectileSpeed = 15,\n                solverType = \"LowArc\",\n                yawBone = \"Turret\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 50,\n            },\n        },\n        audio = {\n            onFire = {\n                looping = false,\n                name = \"agom3100\",\n            },\n        },\n        collideFriendly = false,\n        damage = 60,\n        damageFriendly = false,\n        damageRadius = 2,\n        damageType = \"Normal\",\n        effects = {\n            onFire = \"VFX/Muzzle/vem2101_rocket_antitank_small_muzzle.sanvfx\",\n        },\n        firingRandomness = 0,\n        layerTargetLimits = {\n            \"Land\",\n            \"WaterSurface\",\n        },\n        layerWeaponLimits = {\n            \"Land\",\n        },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = -1,\n        muzzleGroups = {\n            { muzzles = { \"Turret_Muzzle_01\" } },\n            { muzzles = { \"Turret_Muzzle_02\" } },\n            { muzzles = { \"Turret_Muzzle_03\" } },\n        },\n        muzzles = {\n            [\"Turret_Muzzle_01\"] = { aimController = \"Turret_Muzzle_01\" },\n            [\"Turret_Muzzle_02\"] = { aimController = \"Turret_Muzzle_01\" },\n            [\"Turret_Muzzle_03\"] = { aimController = \"Turret_Muzzle_01\" },\n        },\n        muzzleSalvoDelay = 0.2,\n        muzzleSalvoSize = 3,\n        projectileLifetime = 2.8366666666666664,\n        projectileTemplate = \"pgh204\",\n        rangeMax = 37,\n        rangeMin = 0,\n        rangeRingType = \"DirectFire\",\n        rangeTracking = 1.15,\n        reloadTime = 4,\n        targetWaterLimits = \"Above\",\n    },\n}", ValidateHopliteTemplate);
			QueueAppend(obj, list, "LJ/lua/common/systems/import.lua", "Hoplite virtual-projectile directory scanner", ValidateStockImportScanner, "\n\n-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0\n-- The virtual DRL0204 projectile lives in FilesCache rather than a physical\n-- source folder.  Chain the scanner installed by other SCO modules and expose\n-- its logical folder exactly once to Sanctuary's projectile loader.\nlocal SCO_HopliteScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_HopliteScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n\n    local hopliteFolder = directory .. \"pgh204\"\n    for _, folder in ipairs(folders) do\n        if folder == hopliteFolder then\n            return folders\n        end\n    end\n    table.insert(folders, hopliteFolder)\n    return folders\nend", ValidateImportScanner, UpgradeImportScanner);
			QueueVirtualProjectile(obj, list);
			if (list.Count == 0)
			{
				Log("The cached DRL0204 Hoplite replacement is already active.");
				return;
			}
			Commit(obj, list);
			Log("Replaced Guard UGL2101 with DRL0204 Hoplite rig, source stats, three sequential rockets, and its dedicated virtual projectile.");
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
			Log($"Failed to apply the DRL0204 Hoplite replacement: {arg}");
			throw;
		}
	}

	private static void ValidateStockTemplate(string source)
	{
		if (source.Contains("UnitTemplate =") && source.Contains("tpId = \"ugl2101\"") && source.Contains("\"INDIRECT_FIRE\"") && source.Contains("Turret01_Muzzle01") && source.Contains("projectileTemplate = \"pgi212\""))
		{
			RequireTokens(source, "UnitTemplate =", "tpId = \"ugl2101\"", "\"INDIRECT_FIRE\"", "Turret01_Muzzle01", "projectileTemplate = \"pgi212\"");
		}
		else
		{
			RequireTokens(source, "UnitTemplate =", "tpId = \"ugl2101\"", "\"GUARD\"", "\"LAND\"", "\"TECH2\"", "\"DIRECT_FIRE\"", "Turret_Muzzle_01", "Turret_Muzzle_02", "Turret_Muzzle_03", "Units/ugl2101/LOD0/ugl2101.sananimation");
		}
	}

	private static void ValidateHopliteTemplate(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0", 1, "Hoplite override marker");
		int num = source.IndexOf("-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("The Hoplite template lost its authoritative marker.");
		}
		string source2 = source.Substring(num);
		RequireTokens(source2, "displayName = \"Hoplite\"", "name = \"Hoplite\"", "symbol = \"direct\"", "iconUI = \"tech2_land1_direct.png\"", "\"BOT\"", "\"DIRECT_FIRE\"", "max = 450", "regen = 0", "buildTime = 1000", "alloys = 200", "energy = 1000", "visionRadius = 26", "collisionSize = { x = 0.45, y = 0.8, z = 0.9 }", "UnitTemplate.footprint = { x = 0.45, y = 0.9 }", "movement.acceleration = 3.5", "movement.deceleration = 3.6", "movement.rotationSpeed = 90", "movement.speed = 3.6", "authoredSpeed = 0.972972972972973", "sanAnimationPath = \"Units/ugl2101/LOD0/ugl2101.sananimation\"", "aimBone = \"Turret_Muzzle_01\"", "yawBone = \"Turret\"", "pitchBone = \"Turret_Barrel\"", "projectileSpeed = 15", "solverType = \"LowArc\"", "pitchMin = -45", "pitchMax = 45", "yawSpeed = 50", "damage = 60", "damageRadius = 2", "muzzleSalvoDelay = 0.2", "muzzleSalvoSize = 3", "projectileTemplate = \"pgh204\"", "projectileLifetime = 2.8366666666666664", "rangeMax = 37", "rangeRingType = \"DirectFire\"", "reloadTime = 4");
		RequireExactly(source2, "{ muzzles = { \"Turret_Muzzle_", 3, "Hoplite one-muzzle rocket groups");
		RequireNotContains(source2, "Turret01_", "INDIRECT_FIRE", "HighArc", "pgi212", "Wrecker");
	}

	private static void ValidateStockImportScanner(string source)
	{
		RequireTokens(source, "function ScanDir", "Engine.GetFoldersInsideDirectory");
	}

	private static void ValidateImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0", 1, "Hoplite scanner marker");
		string ownedImportScannerAppendix = GetOwnedImportScannerAppendix(source);
		RequireTokens(ownedImportScannerAppendix, "local SCO_HopliteScanDir = ScanDir", "function ScanDir(directory)", "local folders = SCO_HopliteScanDir(directory)", "common/projectiles/projectilesTemplates/", "directory .. \"pgh204\"");
		RequireExactly(ownedImportScannerAppendix, "function ScanDir(directory)", 1, "Hoplite scanner wrapper function");
		RequireExactly(ownedImportScannerAppendix, "local folders = SCO_HopliteScanDir(directory)", 1, "Hoplite prior-scanner call-through");
		RequireNotContains(ownedImportScannerAppendix, "scanRoot");
	}

	private static void QueueAppend(object cache, List<CacheMutation> mutations, string relativePath, string description, Action<string> validateStock, string appendix, Action<string> validatePatched, Func<string, string>? upgradeMarked = null)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		if (ContainsOverride(resourceText))
		{
			string text = ((upgradeMarked == null) ? resourceText : upgradeMarked(resourceText));
			if (string.Equals(text, resourceText, StringComparison.Ordinal))
			{
				validatePatched(resourceText);
				return;
			}
			object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), text);
			try
			{
				validatePatched(GetResourceText(obj));
				mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, description));
				return;
			}
			catch
			{
				TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + description + " upgrade");
				throw;
			}
		}
		validateStock(resourceText);
		object obj3 = CreateNativeArrayFromText(cachedResource.Stock.GetType(), AppendOverride(resourceText, appendix));
		try
		{
			validatePatched(GetResourceText(obj3));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj3, added: false, description));
		}
		catch
		{
			TryDisposeNativeArray(obj3.GetType(), obj3, "uncommitted " + description + " replacement");
			throw;
		}
	}

	private static void QueueVirtualProjectile(object cache, List<CacheMutation> mutations)
	{
		string relativePath = ProjectileRelativePath("pgh204");
		string text = "DRL0204 Hoplite virtual projectile";
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath, text);
		if (cacheResource != null)
		{
			string resourceText = GetResourceText(cacheResource.Stock);
			if (!ContainsOverride(resourceText))
			{
				throw new InvalidOperationException("The reserved Hoplite projectile ID pgh204 already exists without the Hoplite marker.");
			}
			ValidateVirtualProjectile(resourceText);
			return;
		}
		ValidateVirtualProjectile("---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = {\n        onImpact = {\n            looping = false,\n            name = \"aeoi1112\",\n        },\n    },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.25, z = 0 },\n        collisionSize = { x = 0.5, y = 0.5, z = 0.5 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Cybran_Hoplite_Iridium_Rocket\",\n        tpId = \"pgh204\",\n    },\n    -- FA CDFRocketIridium02 uses InitialSpeed=35, MaxSpeed=45, TurnRate=0,\n    -- TrackTarget=true, MaxZigZag=5, and ZigZagFrequency=1. Sanctuary's public\n    -- projectile template API has no initial-speed or zig-zag fields.  The\n    -- source muzzle solution remains 15; this supported homing prefab ramps\n    -- immediately toward the source maximum while its zero turn rate keeps it\n    -- on the authored direct-fire line.  The source projectile mesh/VFX is\n    -- likewise unsupported by the loader, so compatible native rocket VFX\n    -- are intentionally explicit rather than pretending the grenade matches.\n    movement = {\n        acceleration = 120,\n        alignToVelocity = true,\n        gravityMultiplier = 0,\n        rotationSpeed = 0,\n        speedMax = 45,\n        type = \"TargetEntity\",\n    },\n    nonUniformScale = { x = 1, y = 1, z = 1 },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = {\n            {\n                effects = {\n                    {\n                        particleName = \"VFX/Impact/vei2101_rocket_antitank_small_impact.sanvfx\",\n                    },\n                },\n            },\n        },\n        persistantEffects = {\n            {\n                effects = {\n                    {\n                        particleName = \"VFX/Trails/vet2101_rocket_antitank_small_trail.sanvfx\",\n                    },\n                },\n            },\n        },\n    },\n}\n\n-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0");
		object obj = CreateNativeArrayFromText(GetNativeArrayType(cache), "---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = {\n        onImpact = {\n            looping = false,\n            name = \"aeoi1112\",\n        },\n    },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.25, z = 0 },\n        collisionSize = { x = 0.5, y = 0.5, z = 0.5 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Cybran_Hoplite_Iridium_Rocket\",\n        tpId = \"pgh204\",\n    },\n    -- FA CDFRocketIridium02 uses InitialSpeed=35, MaxSpeed=45, TurnRate=0,\n    -- TrackTarget=true, MaxZigZag=5, and ZigZagFrequency=1. Sanctuary's public\n    -- projectile template API has no initial-speed or zig-zag fields.  The\n    -- source muzzle solution remains 15; this supported homing prefab ramps\n    -- immediately toward the source maximum while its zero turn rate keeps it\n    -- on the authored direct-fire line.  The source projectile mesh/VFX is\n    -- likewise unsupported by the loader, so compatible native rocket VFX\n    -- are intentionally explicit rather than pretending the grenade matches.\n    movement = {\n        acceleration = 120,\n        alignToVelocity = true,\n        gravityMultiplier = 0,\n        rotationSpeed = 0,\n        speedMax = 45,\n        type = \"TargetEntity\",\n    },\n    nonUniformScale = { x = 1, y = 1, z = 1 },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = {\n            {\n                effects = {\n                    {\n                        particleName = \"VFX/Impact/vei2101_rocket_antitank_small_impact.sanvfx\",\n                    },\n                },\n            },\n        },\n        persistantEffects = {\n            {\n                effects = {\n                    {\n                        particleName = \"VFX/Trails/vet2101_rocket_antitank_small_trail.sanvfx\",\n                    },\n                },\n            },\n        },\n    },\n}\n\n-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0");
		try
		{
			ValidateVirtualProjectile(GetResourceText(obj));
			mutations.Add(new CacheMutation(ResolvePath(relativePath), null, obj, added: true, text));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + text);
			throw;
		}
	}

	private static void ValidateVirtualProjectile(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0", 1, "Hoplite virtual-projectile marker");
		RequireTokens(source, "ProjectileTemplate =", "tpId = \"pgh204\"", "name = \"Cybran_Hoplite_Iridium_Rocket\"", "acceleration = 120", "rotationSpeed = 0", "speedMax = 45", "type = \"TargetEntity\"", "VFX/Impact/vei2101_rocket_antitank_small_impact.sanvfx", "VFX/Trails/vet2101_rocket_antitank_small_trail.sanvfx", "InitialSpeed=35", "MaxZigZag");
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
				TryDisposeNativeArray(mutation2.Stock.GetType(), mutation2.Stock, "stock " + mutation2.Description);
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
						SetCachedResource(cache, item.Path, item.Stock ?? throw new InvalidOperationException(item.Description + " has no stock cache resource."));
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
		return TryGetCachedResource(cache, relativePath, description) ?? throw new FileNotFoundException("The required " + description + " was not present in Sanctuary's Lua file cache.", relativePath);
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

	private static void RemoveCachedResource(object cache, string path)
	{
		(cache.GetType().GetMethod("Remove", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(cache.GetType().FullName, "Remove")).Invoke(cache, new object[1] { path });
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

	private static string UpgradeImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0", 1, "Hoplite scanner marker");
		int num = source.LastIndexOf("-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0", StringComparison.Ordinal);
		string ownedImportScannerAppendix = GetOwnedImportScannerAppendix(source);
		string text = UpgradeScanDirWrapper(ownedImportScannerAppendix, "SCO_HopliteScanDir");
		if (!string.Equals(ownedImportScannerAppendix, text, StringComparison.Ordinal))
		{
			return source.Substring(0, num) + text + source.Substring(num + ownedImportScannerAppendix.Length);
		}
		return source;
	}

	private static string GetOwnedImportScannerAppendix(string source)
	{
		int num = source.LastIndexOf("-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Hoplite scanner marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0".Length, StringComparison.Ordinal);
		if (num2 >= 0)
		{
			return source.Substring(num, num2 - num);
		}
		return source.Substring(num);
	}

	private static string UpgradeScanDirWrapper(string appendix, string priorScanner)
	{
		if (appendix.IndexOf("scanRoot", StringComparison.Ordinal) < 0)
		{
			return appendix;
		}
		string newValue = "local folders = " + priorScanner + "(directory)";
		string text = ((appendix.IndexOf("function ScanDir(scanRoot, directory)", StringComparison.Ordinal) >= 0) ? "function ScanDir(scanRoot, directory)" : "function ScanDir(scanRoot,directory)");
		string text2 = ((appendix.IndexOf("local folders = " + priorScanner + "(scanRoot, directory)", StringComparison.Ordinal) >= 0) ? ("local folders = " + priorScanner + "(scanRoot, directory)") : ("local folders = " + priorScanner + "(scanRoot,directory)"));
		RequireExactly(appendix, text, 1, "legacy Hoplite scanner wrapper function");
		RequireExactly(appendix, text2, 1, "legacy Hoplite prior-scanner call-through");
		return appendix.Replace(text, "function ScanDir(directory)").Replace(text2, newValue);
	}

	private static string ProjectileRelativePath(string projectileId)
	{
		return "LJ/lua/common/projectiles/projectilesTemplates/" + projectileId + "/" + projectileId + ".santp";
	}

	private static bool ContainsOverride(string source)
	{
		return source.IndexOf("-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0", StringComparison.Ordinal) >= 0;
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
				throw new InvalidOperationException("The Hoplite override must not retain '" + text + "'.");
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
		string text = "[Cybran Hoplite Cache Patcher] " + message;
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
