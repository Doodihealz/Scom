using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace AeonChosenAcuCachePatcher;

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

	internal const string OverrideMarker = "-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0";

	private const string TargetTemplateRelativePath = "LJ/lua/common/units/unitsTemplates/ucl0000/ucl0000.santp";

	private const string ImportRelativePath = "LJ/lua/common/systems/import.lua";

	private const string ProjectileRootRelativePath = "LJ/lua/common/projectiles/projectilesTemplates";

	private const string QuantumDisruptorProjectileId = "pcl001";

	private const string TemplateOverride = "\n\n-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0\n-- FA UAL0001 replaces only Chosen UCL0000 after the fourth-faction module has\n-- already cloned its independent Seraphim source.  The companion local asset\n-- delta owns UAL0001's 24-bone walker, original walk animation, material, and\n-- native construction/fire endpoints.  Chosen's internal faction/class route,\n-- shared commander economy, and shared death damage behavior intentionally remain.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.buildBeamBones = {\n    \"Left_Turret_Muzzle\",\n}\nUnitTemplate.additions.rotators = nil\nUnitTemplate.construction.beam = {\n    boneName = \"Left_Turret_Muzzle\",\n    offset = { x = 0, y = 0, z = 0 },\n    shrink = 1,\n}\n\nUnitTemplate.movement.type = \"LegsLand\"\nUnitTemplate.movement.speed = 1.7\nUnitTemplate.movement.acceleration = 1.7\nUnitTemplate.movement.rotationSpeed = 90\n-- Sanctuary advances the walk clip by current velocity / authoredSpeed.\n-- UAL0001 has MaxSpeed=1.7 and AnimationWalkRate=2.5, so 1.7 / 2.5 = 0.68\n-- preserves its 2.5x source gait at full speed instead of making its feet\n-- slide behind the simulation movement.\nUnitTemplate.movement.walkAnimation = { authoredSpeed = 0.68 }\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.animations = {\n    walk = {\n        authoredSpeed = 0.68,\n        clipName = \"AnimWalk01\",\n        sanAnimationPath = \"Units/ucl0000/LOD0/ucl0000.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\n\n-- Keep the stock commander death audio, root attachment, and damage weapon,\n-- but use the cache-owned mint graph only for this post-Seraphim Aeon ACU.\nif not UnitTemplate.visuals.effectsInstant\n    or not UnitTemplate.visuals.effectsInstant.onDeath\n    or not UnitTemplate.visuals.effectsInstant.onDeath[1] then\n    error(\"UCL0000 Aeon ACU override requires the stock commander death effect\")\nend\nlocal aeonAcuDeathEffect = UnitTemplate.visuals.effectsInstant.onDeath[1]\nif aeonAcuDeathEffect.particleName ~= \"VFX/Death/vcd0301_death_rdu.sanvfx\"\n    and aeonAcuDeathEffect.particleName ~= \"VFX/AeonProjectiles/Death/vcd0301_death_rdu.sanvfx\" then\n    error(\"UCL0000 Aeon ACU override found an unexpected stock commander death graph\")\nend\naeonAcuDeathEffect.particleName = \"VFX/AeonProjectiles/Death/vcd0301_death_rdu.sanvfx\"\n\n-- Measured from the converted native model AABB: min=(-0.547557, 0.009945,\n-- -0.418581), max=(0.539772, 1.905204, 0.857670).  Collision fits the real\n-- Aeon body with a small planar movement margin; selection uses the same\n-- model-centered space rather than the removed Chosen walker footprint.\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = -0.004, y = 0.958, z = 0.22 },\n    collisionSize = { x = 1.1, y = 1.92, z = 1.3 },\n}\nUnitTemplate.footprint = { x = 1.2, y = 1.4 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.3, y = 1.5 }\nUnitTemplate.visuals.selection.offset = { x = -0.004, y = 0.958, z = 0.22 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.3, y = 1.5 },\n    offset = { x = -0.004, y = 0.958, z = 0.22 },\n}\n\n-- The stock Chosen controller references Turret01 bones absent from UAL0001.\n-- Restore FA's exact normal-gun hierarchy: right muzzle -> right turret ->\n-- torso.  It is one direct shot per second, not the stock paired salvo.\nif not UnitTemplate.weapons or not UnitTemplate.weapons[1] then\n    error(\"UCL0000 Aeon ACU override requires the stock primary weapon\")\nend\nlocal primaryWeapon = UnitTemplate.weapons[1]\nprimaryWeapon.aimControllers = {\n    {\n        aimBone = \"Right_Turret_Muzzle\",\n        aimTolerance = 2,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = true,\n        pitchBone = \"Right_Turret\",\n        pitchMax = 90,\n        pitchMin = -90,\n        pitchSpeed = 90,\n        poseResetTime = 3,\n        projectileSpeed = 35,\n        solverType = \"LowArc\",\n        yawBone = \"Torso\",\n        yawMax = 180,\n        yawMin = -180,\n        yawSpeed = 90,\n    },\n}\nprimaryWeapon.audio = {\n    onFire = {\n        looping = false,\n        -- Sanctuary-compatible medium plasma audio; FA's source Wwise bank\n        -- cannot be imported through the public runtime loader.\n        name = \"acom1120\",\n    },\n}\nprimaryWeapon.collideFriendly = false\nprimaryWeapon.damage = 100\nprimaryWeapon.damageFriendly = false\nprimaryWeapon.damageRadius = 0\nprimaryWeapon.damageType = \"Normal\"\nprimaryWeapon.effects = {\n    -- Compatibility visual only.  The source projectile's native effect\n    -- script is unavailable to Sanctuary's public projectile-template API.\n    -- This ACU-only derivative removes the two stacking oversized cloud\n    -- emitters while retaining the normal muzzle flash and projectile trail.\n    onFire = \"VFX/AeonProjectiles/Muzzle/vcm1203_aeon_acu_clean_muzzle.sanvfx\",\n}\nprimaryWeapon.firingRandomness = 0\nprimaryWeapon.layerTargetLimits = {\n    \"Land\",\n    \"WaterSurface\",\n}\nprimaryWeapon.layerWeaponLimits = {\n    \"Land\",\n    \"WaterSurface\",\n}\nprimaryWeapon.muzzleGroupChargeDelay = 0\nprimaryWeapon.muzzleGroupTimeOut = -1\nprimaryWeapon.muzzleGroups = {\n    { muzzles = { \"Right_Turret_Muzzle\" } },\n}\nprimaryWeapon.muzzles = {\n    [\"Right_Turret_Muzzle\"] = { aimController = \"Right_Turret_Muzzle\" },\n}\nprimaryWeapon.muzzleSalvoDelay = 0\nprimaryWeapon.muzzleSalvoSize = 1\nprimaryWeapon.projectileLifetime = 1\nprimaryWeapon.projectileTemplate = \"pcl001\"\nprimaryWeapon.rangeMax = 22\nprimaryWeapon.rangeMin = 1\nprimaryWeapon.rangeRingType = \"DirectFire\"\nprimaryWeapon.rangeTracking = 1.1\nprimaryWeapon.reloadTime = 1\nprimaryWeapon.targetWaterLimits = \"Above\"";

	private const string ImportScannerAppendix = "\n\n-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0\n-- Chain the existing source-projectile scanner and expose the one cache-owned\n-- UAL0001 projectile folder exactly once to Sanctuary's projectile loader.\nlocal SCO_AeonAcuScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_AeonAcuScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n\n    local aeonAcuFolder = directory .. \"pcl001\"\n    for _, folder in ipairs(folders) do\n        if folder == aeonAcuFolder then\n            return folders\n        end\n    end\n    table.insert(folders, aeonAcuFolder)\n    return folders\nend";

	private const string VirtualProjectileSource = "---@type ProjectileTemplate\nProjectileTemplate = {\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.25, z = 0 },\n        collisionSize = { x = 0.5, y = 0.5, z = 0.5 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Aeon_ACU_Quantum_Disruptor\",\n        tpId = \"pcl001\",\n    },\n    -- FA ADFQuantumDisruptor01 is direct fire with InitialSpeed=28 and\n    -- VelocityAlign=true.  Sanctuary's public template schema has no separate\n    -- initial-speed field.  Deliberately omit ``movement`` so the source\n    -- weapon's 35-speed LowArc aim solution stays direct rather than becoming\n    -- a homing missile.  Source projectile mesh/effect scripts are likewise\n    -- unsupported, so these known native plasma effects are explicit fallbacks.\n    nonUniformScale = { x = 1, y = 1, z = 1 },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = {\n            {\n                effects = {\n                    {\n                        particleName = \"VFX/AeonProjectiles/Impact/vci1201_cannon_plasma_medium_impact.sanvfx\",\n                    },\n                },\n            },\n        },\n        persistantEffects = {\n            {\n                effects = {\n                    {\n                        particleName = \"VFX/AeonProjectiles/Trails/vct1201_cannon_plasma_medium_trail.sanvfx\",\n                    },\n                },\n            },\n        },\n    },\n}\n\n-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0";

	public static void Apply()
	{
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			QueueAppend(obj, list, "LJ/lua/common/units/unitsTemplates/ucl0000/ucl0000.santp", "Chosen UCL0000 Aeon ACU target template", ValidateStockTemplate, "\n\n-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0\n-- FA UAL0001 replaces only Chosen UCL0000 after the fourth-faction module has\n-- already cloned its independent Seraphim source.  The companion local asset\n-- delta owns UAL0001's 24-bone walker, original walk animation, material, and\n-- native construction/fire endpoints.  Chosen's internal faction/class route,\n-- shared commander economy, and shared death damage behavior intentionally remain.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.buildBeamBones = {\n    \"Left_Turret_Muzzle\",\n}\nUnitTemplate.additions.rotators = nil\nUnitTemplate.construction.beam = {\n    boneName = \"Left_Turret_Muzzle\",\n    offset = { x = 0, y = 0, z = 0 },\n    shrink = 1,\n}\n\nUnitTemplate.movement.type = \"LegsLand\"\nUnitTemplate.movement.speed = 1.7\nUnitTemplate.movement.acceleration = 1.7\nUnitTemplate.movement.rotationSpeed = 90\n-- Sanctuary advances the walk clip by current velocity / authoredSpeed.\n-- UAL0001 has MaxSpeed=1.7 and AnimationWalkRate=2.5, so 1.7 / 2.5 = 0.68\n-- preserves its 2.5x source gait at full speed instead of making its feet\n-- slide behind the simulation movement.\nUnitTemplate.movement.walkAnimation = { authoredSpeed = 0.68 }\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.animations = {\n    walk = {\n        authoredSpeed = 0.68,\n        clipName = \"AnimWalk01\",\n        sanAnimationPath = \"Units/ucl0000/LOD0/ucl0000.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\n\n-- Keep the stock commander death audio, root attachment, and damage weapon,\n-- but use the cache-owned mint graph only for this post-Seraphim Aeon ACU.\nif not UnitTemplate.visuals.effectsInstant\n    or not UnitTemplate.visuals.effectsInstant.onDeath\n    or not UnitTemplate.visuals.effectsInstant.onDeath[1] then\n    error(\"UCL0000 Aeon ACU override requires the stock commander death effect\")\nend\nlocal aeonAcuDeathEffect = UnitTemplate.visuals.effectsInstant.onDeath[1]\nif aeonAcuDeathEffect.particleName ~= \"VFX/Death/vcd0301_death_rdu.sanvfx\"\n    and aeonAcuDeathEffect.particleName ~= \"VFX/AeonProjectiles/Death/vcd0301_death_rdu.sanvfx\" then\n    error(\"UCL0000 Aeon ACU override found an unexpected stock commander death graph\")\nend\naeonAcuDeathEffect.particleName = \"VFX/AeonProjectiles/Death/vcd0301_death_rdu.sanvfx\"\n\n-- Measured from the converted native model AABB: min=(-0.547557, 0.009945,\n-- -0.418581), max=(0.539772, 1.905204, 0.857670).  Collision fits the real\n-- Aeon body with a small planar movement margin; selection uses the same\n-- model-centered space rather than the removed Chosen walker footprint.\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = -0.004, y = 0.958, z = 0.22 },\n    collisionSize = { x = 1.1, y = 1.92, z = 1.3 },\n}\nUnitTemplate.footprint = { x = 1.2, y = 1.4 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.3, y = 1.5 }\nUnitTemplate.visuals.selection.offset = { x = -0.004, y = 0.958, z = 0.22 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.3, y = 1.5 },\n    offset = { x = -0.004, y = 0.958, z = 0.22 },\n}\n\n-- The stock Chosen controller references Turret01 bones absent from UAL0001.\n-- Restore FA's exact normal-gun hierarchy: right muzzle -> right turret ->\n-- torso.  It is one direct shot per second, not the stock paired salvo.\nif not UnitTemplate.weapons or not UnitTemplate.weapons[1] then\n    error(\"UCL0000 Aeon ACU override requires the stock primary weapon\")\nend\nlocal primaryWeapon = UnitTemplate.weapons[1]\nprimaryWeapon.aimControllers = {\n    {\n        aimBone = \"Right_Turret_Muzzle\",\n        aimTolerance = 2,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = true,\n        pitchBone = \"Right_Turret\",\n        pitchMax = 90,\n        pitchMin = -90,\n        pitchSpeed = 90,\n        poseResetTime = 3,\n        projectileSpeed = 35,\n        solverType = \"LowArc\",\n        yawBone = \"Torso\",\n        yawMax = 180,\n        yawMin = -180,\n        yawSpeed = 90,\n    },\n}\nprimaryWeapon.audio = {\n    onFire = {\n        looping = false,\n        -- Sanctuary-compatible medium plasma audio; FA's source Wwise bank\n        -- cannot be imported through the public runtime loader.\n        name = \"acom1120\",\n    },\n}\nprimaryWeapon.collideFriendly = false\nprimaryWeapon.damage = 100\nprimaryWeapon.damageFriendly = false\nprimaryWeapon.damageRadius = 0\nprimaryWeapon.damageType = \"Normal\"\nprimaryWeapon.effects = {\n    -- Compatibility visual only.  The source projectile's native effect\n    -- script is unavailable to Sanctuary's public projectile-template API.\n    -- This ACU-only derivative removes the two stacking oversized cloud\n    -- emitters while retaining the normal muzzle flash and projectile trail.\n    onFire = \"VFX/AeonProjectiles/Muzzle/vcm1203_aeon_acu_clean_muzzle.sanvfx\",\n}\nprimaryWeapon.firingRandomness = 0\nprimaryWeapon.layerTargetLimits = {\n    \"Land\",\n    \"WaterSurface\",\n}\nprimaryWeapon.layerWeaponLimits = {\n    \"Land\",\n    \"WaterSurface\",\n}\nprimaryWeapon.muzzleGroupChargeDelay = 0\nprimaryWeapon.muzzleGroupTimeOut = -1\nprimaryWeapon.muzzleGroups = {\n    { muzzles = { \"Right_Turret_Muzzle\" } },\n}\nprimaryWeapon.muzzles = {\n    [\"Right_Turret_Muzzle\"] = { aimController = \"Right_Turret_Muzzle\" },\n}\nprimaryWeapon.muzzleSalvoDelay = 0\nprimaryWeapon.muzzleSalvoSize = 1\nprimaryWeapon.projectileLifetime = 1\nprimaryWeapon.projectileTemplate = \"pcl001\"\nprimaryWeapon.rangeMax = 22\nprimaryWeapon.rangeMin = 1\nprimaryWeapon.rangeRingType = \"DirectFire\"\nprimaryWeapon.rangeTracking = 1.1\nprimaryWeapon.reloadTime = 1\nprimaryWeapon.targetWaterLimits = \"Above\"", ValidateAeonTemplate);
			QueueAppend(obj, list, "LJ/lua/common/systems/import.lua", "Aeon ACU virtual-projectile directory scanner", ValidateStockImportScanner, "\n\n-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0\n-- Chain the existing source-projectile scanner and expose the one cache-owned\n-- UAL0001 projectile folder exactly once to Sanctuary's projectile loader.\nlocal SCO_AeonAcuScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_AeonAcuScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n\n    local aeonAcuFolder = directory .. \"pcl001\"\n    for _, folder in ipairs(folders) do\n        if folder == aeonAcuFolder then\n            return folders\n        end\n    end\n    table.insert(folders, aeonAcuFolder)\n    return folders\nend", ValidateImportScanner, UpgradeImportScanner);
			QueueVirtualProjectile(obj, list);
			if (list.Count == 0)
			{
				Log("The cached UAL0001 Aeon ACU replacement is already active.");
				return;
			}
			Commit(obj, list);
			Log("Replaced Chosen UCL0000 with the UAL0001 Aeon ACU rig, synchronized walk gait, mint death graph, clean muzzle, direct Quantum Disruptor, and dedicated virtual projectile.");
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
			Log($"Failed to apply the UAL0001 Aeon ACU replacement: {arg}");
			throw;
		}
	}

	private static void ValidateStockTemplate(string source)
	{
		if (source.Contains("UnitTemplate =") && source.Contains("tpId = \"ucl0000\"") && source.Contains("\"ChosenCommander\"") && source.Contains("\"CHOSEN\"") && source.Contains("Build_emitter01") && source.Contains("Turret01_Muzzle01") && source.Contains("VFX/Death/vcd0301_death_rdu.sanvfx") && source.Contains("projectileTemplate = \"pcd121\""))
		{
			RequireTokens(source, "UnitTemplate =", "tpId = \"ucl0000\"", "\"ChosenCommander\"", "\"CHOSEN\"", "Build_emitter01", "Turret01_Muzzle01", "VFX/Death/vcd0301_death_rdu.sanvfx", "projectileTemplate = \"pcd121\"");
			return;
		}
		RequireTokens(source, "UnitTemplate =", "tpId = \"ucl0000\"", "\"ChosenCommander\"", "\"CHOSEN\"", "Left_Turret_Muzzle", "Right_Turret_Muzzle", "Units/ucl0000/LOD0/ucl0000.sananimation");
		if (!source.Contains("VFX/Death/vcd0301_death_rdu.sanvfx"))
		{
			RequireTokens(source, "VFX/AeonProjectiles/Death/vcd0301_death_rdu.sanvfx");
		}
	}

	private static void ValidateAeonTemplate(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0", 1, "Aeon ACU override marker");
		int num = source.IndexOf("-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("The Aeon ACU template lost its authoritative marker.");
		}
		string source2 = source.Substring(num);
		RequireTokens(source2, "\"Left_Turret_Muzzle\"", "boneName = \"Left_Turret_Muzzle\"", "movement.speed = 1.7", "movement.acceleration = 1.7", "movement.rotationSpeed = 90", "authoredSpeed = 0.68", "sanAnimationPath = \"Units/ucl0000/LOD0/ucl0000.sananimation\"", "VFX/AeonProjectiles/Death/vcd0301_death_rdu.sanvfx", "centerOffset = { x = -0.004, y = 0.958, z = 0.22 }", "collisionSize = { x = 1.1, y = 1.92, z = 1.3 }", "UnitTemplate.footprint = { x = 1.2, y = 1.4 }", "aimBone = \"Right_Turret_Muzzle\"", "pitchBone = \"Right_Turret\"", "yawBone = \"Torso\"", "projectileSpeed = 35", "solverType = \"LowArc\"", "damage = 100", "damageRadius = 0", "muzzleSalvoSize = 1", "VFX/AeonProjectiles/Muzzle/vcm1203_aeon_acu_clean_muzzle.sanvfx", "projectileTemplate = \"pcl001\"", "projectileLifetime = 1", "rangeMax = 22", "rangeMin = 1", "rangeRingType = \"DirectFire\"", "reloadTime = 1", "targetWaterLimits = \"Above\"");
		RequireExactly(source2, "authoredSpeed = 0.68", 2, "Aeon ACU synchronized walk-speed entries");
		RequireExactly(source2, "{ muzzles = { \"Right_Turret_Muzzle\" } }", 1, "Aeon ACU one-muzzle group");
		RequireNotContains(source2, "authoredSpeed = 1.7", "authoredSpeed = 2.5", "Turret01_", "pcd121", "OverChargeWeapon", "Overcharge");
	}

	private static void ValidateStockImportScanner(string source)
	{
		RequireTokens(source, "function ScanDir", "Engine.GetFoldersInsideDirectory");
	}

	private static void ValidateImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0", 1, "Aeon ACU scanner marker");
		string ownedImportScannerAppendix = GetOwnedImportScannerAppendix(source);
		RequireTokens(ownedImportScannerAppendix, "local SCO_AeonAcuScanDir = ScanDir", "function ScanDir(directory)", "local folders = SCO_AeonAcuScanDir(directory)", "common/projectiles/projectilesTemplates/", "directory .. \"pcl001\"");
		RequireExactly(ownedImportScannerAppendix, "function ScanDir(directory)", 1, "Aeon ACU scanner wrapper function");
		RequireExactly(ownedImportScannerAppendix, "local folders = SCO_AeonAcuScanDir(directory)", 1, "Aeon ACU prior-scanner call-through");
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
		string relativePath = ProjectileRelativePath("pcl001");
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath, "UAL0001 Aeon ACU virtual Quantum Disruptor projectile");
		if (cacheResource != null)
		{
			string resourceText = GetResourceText(cacheResource.Stock);
			if (!ContainsOverride(resourceText))
			{
				throw new InvalidOperationException("The reserved Aeon ACU projectile ID pcl001 already exists without the Aeon ACU marker.");
			}
			ValidateVirtualProjectile(resourceText);
			return;
		}
		ValidateVirtualProjectile("---@type ProjectileTemplate\nProjectileTemplate = {\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.25, z = 0 },\n        collisionSize = { x = 0.5, y = 0.5, z = 0.5 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Aeon_ACU_Quantum_Disruptor\",\n        tpId = \"pcl001\",\n    },\n    -- FA ADFQuantumDisruptor01 is direct fire with InitialSpeed=28 and\n    -- VelocityAlign=true.  Sanctuary's public template schema has no separate\n    -- initial-speed field.  Deliberately omit ``movement`` so the source\n    -- weapon's 35-speed LowArc aim solution stays direct rather than becoming\n    -- a homing missile.  Source projectile mesh/effect scripts are likewise\n    -- unsupported, so these known native plasma effects are explicit fallbacks.\n    nonUniformScale = { x = 1, y = 1, z = 1 },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = {\n            {\n                effects = {\n                    {\n                        particleName = \"VFX/AeonProjectiles/Impact/vci1201_cannon_plasma_medium_impact.sanvfx\",\n                    },\n                },\n            },\n        },\n        persistantEffects = {\n            {\n                effects = {\n                    {\n                        particleName = \"VFX/AeonProjectiles/Trails/vct1201_cannon_plasma_medium_trail.sanvfx\",\n                    },\n                },\n            },\n        },\n    },\n}\n\n-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0");
		object obj = CreateNativeArrayFromText(GetNativeArrayType(cache), "---@type ProjectileTemplate\nProjectileTemplate = {\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.25, z = 0 },\n        collisionSize = { x = 0.5, y = 0.5, z = 0.5 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Aeon_ACU_Quantum_Disruptor\",\n        tpId = \"pcl001\",\n    },\n    -- FA ADFQuantumDisruptor01 is direct fire with InitialSpeed=28 and\n    -- VelocityAlign=true.  Sanctuary's public template schema has no separate\n    -- initial-speed field.  Deliberately omit ``movement`` so the source\n    -- weapon's 35-speed LowArc aim solution stays direct rather than becoming\n    -- a homing missile.  Source projectile mesh/effect scripts are likewise\n    -- unsupported, so these known native plasma effects are explicit fallbacks.\n    nonUniformScale = { x = 1, y = 1, z = 1 },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = {\n            {\n                effects = {\n                    {\n                        particleName = \"VFX/AeonProjectiles/Impact/vci1201_cannon_plasma_medium_impact.sanvfx\",\n                    },\n                },\n            },\n        },\n        persistantEffects = {\n            {\n                effects = {\n                    {\n                        particleName = \"VFX/AeonProjectiles/Trails/vct1201_cannon_plasma_medium_trail.sanvfx\",\n                    },\n                },\n            },\n        },\n    },\n}\n\n-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0");
		try
		{
			ValidateVirtualProjectile(GetResourceText(obj));
			mutations.Add(new CacheMutation(ResolvePath(relativePath), null, obj, added: true, "UAL0001 Aeon ACU virtual Quantum Disruptor projectile"));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted UAL0001 Aeon ACU virtual Quantum Disruptor projectile");
			throw;
		}
	}

	private static void ValidateVirtualProjectile(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0", 1, "Aeon ACU virtual-projectile marker");
		RequireTokens(source, "ProjectileTemplate =", "tpId = \"pcl001\"", "name = \"Aeon_ACU_Quantum_Disruptor\"", "InitialSpeed=28", "VelocityAlign=true", "VFX/AeonProjectiles/Impact/vci1201_cannon_plasma_medium_impact.sanvfx", "VFX/AeonProjectiles/Trails/vct1201_cannon_plasma_medium_trail.sanvfx");
		RequireNotContains(source, "movement =", "TargetEntity");
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
		RequireExactly(source, "-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0", 1, "Aeon ACU scanner marker");
		int num = source.LastIndexOf("-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0", StringComparison.Ordinal);
		string ownedImportScannerAppendix = GetOwnedImportScannerAppendix(source);
		string text = UpgradeScanDirWrapper(ownedImportScannerAppendix, "SCO_AeonAcuScanDir");
		if (!string.Equals(ownedImportScannerAppendix, text, StringComparison.Ordinal))
		{
			return source.Substring(0, num) + text + source.Substring(num + ownedImportScannerAppendix.Length);
		}
		return source;
	}

	private static string GetOwnedImportScannerAppendix(string source)
	{
		int num = source.LastIndexOf("-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Aeon ACU scanner marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0".Length, StringComparison.Ordinal);
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
		RequireExactly(appendix, text, 1, "legacy Aeon ACU scanner wrapper function");
		RequireExactly(appendix, text2, 1, "legacy Aeon ACU prior-scanner call-through");
		return appendix.Replace(text, "function ScanDir(directory)").Replace(text2, newValue);
	}

	private static string ProjectileRelativePath(string projectileId)
	{
		return "LJ/lua/common/projectiles/projectilesTemplates/" + projectileId + "/" + projectileId + ".santp";
	}

	private static bool ContainsOverride(string source)
	{
		return source.IndexOf("-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0", StringComparison.Ordinal) >= 0;
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
				throw new InvalidOperationException("The Aeon ACU override must not retain '" + text + "'.");
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
		string text = "[Aeon ACU Cache Patcher] " + message;
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
