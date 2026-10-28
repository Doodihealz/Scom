using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace FaArtilleryPairCachePatcher;

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

	internal const string OverrideMarker = "-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0";

	private const string MobileTemplateRelativePath = "LJ/lua/common/units/unitsTemplates/ugl1101/ugl1101.santp";

	private const string StructureTemplateRelativePath = "LJ/lua/common/units/unitsTemplates/ugs2101/ugs2101.santp";

	private const string ImportRelativePath = "LJ/lua/common/systems/import.lua";

	private const string ProjectileRootRelativePath = "LJ/lua/common/projectiles/projectilesTemplates";

	private const string GrenadeProjectileId = "pcg103";

	private const string MolecularShellProjectileId = "pcg203";

	private const string MobileOverride = "\n\n-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0\n-- URL0103 Medusa -> ugl1101. Source blueprint:\n-- units/URL0103/URL0103_unit.bp\n-- SHA-256: 66553b6bb649dcd4ec87ebe8a6b39eece18f5562d5ef4700d5a48285a74c7423\n-- Sanctuary has no projectile-template status-buff surface.  The source's\n-- three-second TECH1/TECH2 EMP stun is therefore recorded below but cannot be\n-- claimed as simulated; damage, radius, cadence, arc, range, and rig are exact.\nUnitTemplate.general = UnitTemplate.general or {}\nUnitTemplate.general.displayName = \"Medusa\"\nUnitTemplate.general.name = \"Medusa\"\nUnitTemplate.general.icon = {\n    shape = \"land1\",\n    symbol = \"indirect\",\n    tech = \"t1\",\n}\nUnitTemplate.general.iconUI = \"tech1_land1_indirect.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 70\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true,\n    Attack = true,\n    AttackMove = true,\n    Move = true,\n    Patrol = true,\n    Stop = true,\n}\n\nUnitTemplate.tags = {\n    \"ARTILLERY\",\n    \"BUILDABLE_BY_T1_FACTORY\",\n    \"BUILDABLE_BY_T2_FACTORY\",\n    \"BUILDABLE_BY_T3_FACTORY\",\n    \"GUARD\",\n    \"INDIRECT_FIRE\",\n    \"LAND\",\n    \"MOBILE\",\n    \"TECH1\",\n}\n\nUnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = { max = 140, regen = 0, value = 140 }\nUnitTemplate.economy = UnitTemplate.economy or {}\nUnitTemplate.economy.buildTime = 240\nUnitTemplate.economy.cost = { alloys = 48, energy = 240 }\nUnitTemplate.intel = { visionRadius = 18 }\n\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0, z = 0 },\n    collisionSize = { x = 0.55, y = 0.45, z = 0.65 },\n}\nUnitTemplate.footprint = { x = 0.55, y = 0.65 }\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.35, y = 0.45 },\n    offset = { x = 0, y = 0, z = -0.05 },\n}\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.35, y = 0.45 },\n    offset = { x = 0, y = 0, z = -0.05 },\n}\nUnitTemplate.additions.faSourceContract = {\n    sourceId = \"URL0103\",\n    targetId = \"ugl1101\",\n    sourceCollisionOffset = { x = 0, y = 0, z = 0 },\n    sourceEmpDuration = 3,\n    sourceEmpRadius = 2,\n    sourceEmpTargetAllow = \"TECH1,TECH2\",\n    nativeEmpBuffSupported = false,\n}\n\nUnitTemplate.movement = UnitTemplate.movement or {}\nUnitTemplate.movement.animClips = nil\nUnitTemplate.movement.walkAnimation = nil\nUnitTemplate.movement.type = \"TracksLand\"\nUnitTemplate.movement.acceleration = 2.9\nUnitTemplate.movement.deceleration = 2.9\nUnitTemplate.movement.rotationSpeed = 90\nUnitTemplate.movement.speed = 2.9\nUnitTemplate.movement.minSpeed = 0\nUnitTemplate.movement.referenceAltitude = \"Ground\"\nUnitTemplate.movement.terrainAlignmentFactor = 1\nUnitTemplate.movement.collisionMaskDefault = { \"LandSmall\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"LandSmall\" }\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Turret_Muzzle\",\n                aimTolerance = 1,\n                defaultPitchAdjustment = 45,\n                defaultYawAdjustment = 0,\n                leadTarget = false,\n                pitchBone = \"Turret_Barrel\",\n                pitchMax = 90,\n                pitchMin = -90,\n                pitchSpeed = 70,\n                poseResetTime = 10,\n                projectileSpeed = 14,\n                reduceMuzzleVelocityToTarget = true,\n                solverType = \"HighArc\",\n                yawBone = \"Turret\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 70,\n            },\n        },\n        audio = { onFire = { looping = false, name = \"agom1210\" } },\n        collideFriendly = false,\n        damage = 195,\n        damageFriendly = false,\n        damageRadius = 2,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vgm1141_cannon_artillery_small_muzzle.sanvfx\" },\n        firingRandomness = 1.5,\n        layerTargetLimits = { \"Land\", \"WaterSurface\", \"Seabed\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = 10,\n        muzzleGroups = { { muzzles = { \"Turret_Muzzle\" } } },\n        muzzles = { [\"Turret_Muzzle\"] = { aimController = \"Turret_Muzzle\" } },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 20,\n        projectileTemplate = \"pcg103\",\n        rangeMax = 30,\n        rangeMin = 5,\n        rangeRingType = \"IndirectFire\",\n        rangeTracking = 1.15,\n        reloadTime = 5,\n        targetCheckInterval = 1,\n        targetWaterLimits = \"Above\",\n    },\n}";

	private const string StructureOverride = "\n\n-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0\n-- URB2303 Gunther -> ugs2101. Source blueprint:\n-- units/URB2303/URB2303_unit.bp\n-- SHA-256: f0f11960837abf5a856d885fcf5500a2e4cd47546752a8865f7bf22e4998cf0a\n-- The current weapon template API has no economy-event charge gate.  Source\n-- EnergyRequired=1150 and EnergyDrainPerSecond=115 remain audited metadata;\n-- the supported 20-second fire cadence is exact without inventing economy IO.\nUnitTemplate.general = UnitTemplate.general or {}\nUnitTemplate.general.displayName = \"Gunther\"\nUnitTemplate.general.name = \"Gunther\"\nUnitTemplate.general.icon = {\n    shape = \"structure1\",\n    symbol = \"indirect\",\n    tech = \"t2\",\n}\nUnitTemplate.general.iconUI = \"tech2_structure1_indirect.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 70\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true,\n    Attack = true,\n    Move = true,\n    Patrol = true,\n    Stop = true,\n}\n\nUnitTemplate.tags = {\n    \"ARTILLERY\",\n    \"BUILDABLE_BY_T2_ENGINEER\",\n    \"BUILDABLE_BY_T3_ENGINEER\",\n    \"GUARD\",\n    \"INDIRECT_FIRE\",\n    \"STRATEGIC\",\n    \"STRUCTURE\",\n    \"TECH2\",\n}\n\nUnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = { max = 3150, regen = 0, value = 3150 }\nUnitTemplate.economy = UnitTemplate.economy or {}\nUnitTemplate.economy.buildTime = 1600\nUnitTemplate.economy.cost = { alloys = 2240, energy = 16000 }\nUnitTemplate.intel = { visionRadius = 28 }\n\n-- The converted structure is rotated 180 degrees into Sanctuary's canonical\n-- south-facing basis, so source CollisionOffsetZ=-0.1 becomes +0.1.\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = -0.25, z = 0.1 },\n    collisionSize = { x = 0.5, y = 1.4, z = 0.8 },\n}\nUnitTemplate.footprint = { x = 1, y = 1 }\nUnitTemplate.skirtSize = { x = 2, y = 2 }\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.75, y = 0.75 },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.75, y = 0.75 },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.additions.faSourceContract = {\n    sourceId = \"URB2303\",\n    targetId = \"ugs2101\",\n    sourceCollisionOffset = { x = 0, y = -0.25, z = -0.1 },\n    sourceSkirtOffset = { x = -0.5, y = -0.5 },\n    sourceEnergyRequired = 1150,\n    sourceEnergyDrainPerSecond = 115,\n    nativeWeaponEconomyChargeSupported = false,\n}\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Turret_Muzzle\",\n                aimTolerance = 1,\n                defaultPitchAdjustment = 30,\n                defaultYawAdjustment = 0,\n                leadTarget = false,\n                pitchBone = \"Turret_Barrel\",\n                pitchMax = 60,\n                pitchMin = -60,\n                pitchSpeed = 6,\n                poseResetTime = 14,\n                projectileSpeed = 26.13,\n                reduceMuzzleVelocityToTarget = false,\n                solverType = \"LowArc\",\n                yawBone = \"Turret\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 6,\n            },\n        },\n        audio = { onFire = { looping = false, name = \"agom1224\" } },\n        collideFriendly = false,\n        damage = 1750,\n        damageFriendly = true,\n        damageRadius = 4,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vgm1241_cannon_artillery_medium_muzzle.sanvfx\" },\n        firingRandomness = 2.5,\n        layerTargetLimits = { \"Land\", \"WaterSurface\", \"Seabed\" },\n        layerWeaponLimits = { \"Land\", \"WaterSurface\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = 14,\n        muzzleGroups = { { muzzles = { \"Turret_Muzzle\" } } },\n        muzzles = { [\"Turret_Muzzle\"] = { aimController = \"Turret_Muzzle\" } },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 60,\n        projectileTemplate = \"pcg203\",\n        rangeMax = 128,\n        rangeMin = 5,\n        rangeRingType = \"IndirectFire\",\n        rangeTracking = 1.1,\n        reloadTime = 20,\n        targetCheckInterval = 4,\n        targetWaterLimits = \"Above\",\n    },\n}";

	private const string ImportScannerAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0\n-- Register only this module's two source-identified virtual projectile roots.\nlocal SCO_ArtilleryPairScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_ArtilleryPairScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n\n    local artilleryFolders = {\n        directory .. \"pcg103\",\n        directory .. \"pcg203\",\n    }\n    for _, artilleryFolder in ipairs(artilleryFolders) do\n        local found = false\n        for _, folder in ipairs(folders) do\n            if folder == artilleryFolder then\n                found = true\n                break\n            end\n        end\n        if not found then\n            table.insert(folders, artilleryFolder)\n        end\n    end\n    return folders\nend";

	private const string GrenadeProjectileSource = "---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = { onImpact = { looping = false, name = \"agoi1110\" } },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Cybran_URL0103_EMP_Grenade\",\n        tpId = \"pcg103\",\n    },\n    -- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0\n    -- CIFGrenade01: UniformScale=.05, InitialSpeed=14.6, range=3,\n    -- reduce-distance=30, LeadTarget=false, TurnRate=360,\n    -- VelocityAlign=true, DestroyOnWater=true. Sanctuary's weapon solver owns\n    -- the ballistic launch; compatible Guard effects stand in for the FA-only\n    -- projectile mesh and emitters without sharing an Aeon projectile route.\n    nonUniformScale = { x = 0.05, y = 0.05, z = 0.05 },\n    visuals = {\n        mesh = { lod0distance = 150 },\n        onImpactEffects = {\n            { effects = { { particleName = \"VFX/Impact/vgi1141_cannon_artillery_small_impact.sanvfx\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"VFX/Trails/vgt1141_cannon_artillery_small_trail.sanvfx\" } } },\n        },\n    },\n}";

	private const string MolecularShellProjectileSource = "---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = { onImpact = { looping = false, name = \"agoi1130\" } },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Cybran_URB2303_Molecular_Resonance_Shell\",\n        tpId = \"pcg203\",\n    },\n    -- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0\n    -- CIFMolecularResonanceShell01: UniformScale=.25, LeadTarget=false,\n    -- TurnRate=360, VelocityAlign=true, DestroyOnWater=true.  The FA mesh and\n    -- emitter graph are not loadable as a Sanctuary projectile template, so\n    -- explicit Guard artillery effects are the non-Aeon compatibility path.\n    nonUniformScale = { x = 0.25, y = 0.25, z = 0.25 },\n    visuals = {\n        mesh = { lod0distance = 150 },\n        onImpactEffects = {\n            { effects = { { particleName = \"VFX/Impact/vgi1241_cannon_artillery_medium_impact.sanvfx\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"VFX/Trails/vgt1241_cannon_artillery_medium_trail.sanvfx\" } } },\n        },\n    },\n}";

	public static void Apply()
	{
		object obj = null;
		List<CacheMutation> mutations = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			if (Preflight(obj))
			{
				Log("The cached URL0103/URB2303 artillery pair is already active.");
				return;
			}
			QueueAppend(obj, mutations, "LJ/lua/common/units/unitsTemplates/ugl1101/ugl1101.santp", "Guard UGL1101 Medusa target template", ValidateStockMobile, "\n\n-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0\n-- URL0103 Medusa -> ugl1101. Source blueprint:\n-- units/URL0103/URL0103_unit.bp\n-- SHA-256: 66553b6bb649dcd4ec87ebe8a6b39eece18f5562d5ef4700d5a48285a74c7423\n-- Sanctuary has no projectile-template status-buff surface.  The source's\n-- three-second TECH1/TECH2 EMP stun is therefore recorded below but cannot be\n-- claimed as simulated; damage, radius, cadence, arc, range, and rig are exact.\nUnitTemplate.general = UnitTemplate.general or {}\nUnitTemplate.general.displayName = \"Medusa\"\nUnitTemplate.general.name = \"Medusa\"\nUnitTemplate.general.icon = {\n    shape = \"land1\",\n    symbol = \"indirect\",\n    tech = \"t1\",\n}\nUnitTemplate.general.iconUI = \"tech1_land1_indirect.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 70\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true,\n    Attack = true,\n    AttackMove = true,\n    Move = true,\n    Patrol = true,\n    Stop = true,\n}\n\nUnitTemplate.tags = {\n    \"ARTILLERY\",\n    \"BUILDABLE_BY_T1_FACTORY\",\n    \"BUILDABLE_BY_T2_FACTORY\",\n    \"BUILDABLE_BY_T3_FACTORY\",\n    \"GUARD\",\n    \"INDIRECT_FIRE\",\n    \"LAND\",\n    \"MOBILE\",\n    \"TECH1\",\n}\n\nUnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = { max = 140, regen = 0, value = 140 }\nUnitTemplate.economy = UnitTemplate.economy or {}\nUnitTemplate.economy.buildTime = 240\nUnitTemplate.economy.cost = { alloys = 48, energy = 240 }\nUnitTemplate.intel = { visionRadius = 18 }\n\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0, z = 0 },\n    collisionSize = { x = 0.55, y = 0.45, z = 0.65 },\n}\nUnitTemplate.footprint = { x = 0.55, y = 0.65 }\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.35, y = 0.45 },\n    offset = { x = 0, y = 0, z = -0.05 },\n}\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.35, y = 0.45 },\n    offset = { x = 0, y = 0, z = -0.05 },\n}\nUnitTemplate.additions.faSourceContract = {\n    sourceId = \"URL0103\",\n    targetId = \"ugl1101\",\n    sourceCollisionOffset = { x = 0, y = 0, z = 0 },\n    sourceEmpDuration = 3,\n    sourceEmpRadius = 2,\n    sourceEmpTargetAllow = \"TECH1,TECH2\",\n    nativeEmpBuffSupported = false,\n}\n\nUnitTemplate.movement = UnitTemplate.movement or {}\nUnitTemplate.movement.animClips = nil\nUnitTemplate.movement.walkAnimation = nil\nUnitTemplate.movement.type = \"TracksLand\"\nUnitTemplate.movement.acceleration = 2.9\nUnitTemplate.movement.deceleration = 2.9\nUnitTemplate.movement.rotationSpeed = 90\nUnitTemplate.movement.speed = 2.9\nUnitTemplate.movement.minSpeed = 0\nUnitTemplate.movement.referenceAltitude = \"Ground\"\nUnitTemplate.movement.terrainAlignmentFactor = 1\nUnitTemplate.movement.collisionMaskDefault = { \"LandSmall\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"LandSmall\" }\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Turret_Muzzle\",\n                aimTolerance = 1,\n                defaultPitchAdjustment = 45,\n                defaultYawAdjustment = 0,\n                leadTarget = false,\n                pitchBone = \"Turret_Barrel\",\n                pitchMax = 90,\n                pitchMin = -90,\n                pitchSpeed = 70,\n                poseResetTime = 10,\n                projectileSpeed = 14,\n                reduceMuzzleVelocityToTarget = true,\n                solverType = \"HighArc\",\n                yawBone = \"Turret\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 70,\n            },\n        },\n        audio = { onFire = { looping = false, name = \"agom1210\" } },\n        collideFriendly = false,\n        damage = 195,\n        damageFriendly = false,\n        damageRadius = 2,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vgm1141_cannon_artillery_small_muzzle.sanvfx\" },\n        firingRandomness = 1.5,\n        layerTargetLimits = { \"Land\", \"WaterSurface\", \"Seabed\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = 10,\n        muzzleGroups = { { muzzles = { \"Turret_Muzzle\" } } },\n        muzzles = { [\"Turret_Muzzle\"] = { aimController = \"Turret_Muzzle\" } },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 20,\n        projectileTemplate = \"pcg103\",\n        rangeMax = 30,\n        rangeMin = 5,\n        rangeRingType = \"IndirectFire\",\n        rangeTracking = 1.15,\n        reloadTime = 5,\n        targetCheckInterval = 1,\n        targetWaterLimits = \"Above\",\n    },\n}", ValidateMobile);
			QueueAppend(obj, mutations, "LJ/lua/common/units/unitsTemplates/ugs2101/ugs2101.santp", "Guard UGS2101 Gunther target template", ValidateStockStructure, "\n\n-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0\n-- URB2303 Gunther -> ugs2101. Source blueprint:\n-- units/URB2303/URB2303_unit.bp\n-- SHA-256: f0f11960837abf5a856d885fcf5500a2e4cd47546752a8865f7bf22e4998cf0a\n-- The current weapon template API has no economy-event charge gate.  Source\n-- EnergyRequired=1150 and EnergyDrainPerSecond=115 remain audited metadata;\n-- the supported 20-second fire cadence is exact without inventing economy IO.\nUnitTemplate.general = UnitTemplate.general or {}\nUnitTemplate.general.displayName = \"Gunther\"\nUnitTemplate.general.name = \"Gunther\"\nUnitTemplate.general.icon = {\n    shape = \"structure1\",\n    symbol = \"indirect\",\n    tech = \"t2\",\n}\nUnitTemplate.general.iconUI = \"tech2_structure1_indirect.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 70\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true,\n    Attack = true,\n    Move = true,\n    Patrol = true,\n    Stop = true,\n}\n\nUnitTemplate.tags = {\n    \"ARTILLERY\",\n    \"BUILDABLE_BY_T2_ENGINEER\",\n    \"BUILDABLE_BY_T3_ENGINEER\",\n    \"GUARD\",\n    \"INDIRECT_FIRE\",\n    \"STRATEGIC\",\n    \"STRUCTURE\",\n    \"TECH2\",\n}\n\nUnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = { max = 3150, regen = 0, value = 3150 }\nUnitTemplate.economy = UnitTemplate.economy or {}\nUnitTemplate.economy.buildTime = 1600\nUnitTemplate.economy.cost = { alloys = 2240, energy = 16000 }\nUnitTemplate.intel = { visionRadius = 28 }\n\n-- The converted structure is rotated 180 degrees into Sanctuary's canonical\n-- south-facing basis, so source CollisionOffsetZ=-0.1 becomes +0.1.\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = -0.25, z = 0.1 },\n    collisionSize = { x = 0.5, y = 1.4, z = 0.8 },\n}\nUnitTemplate.footprint = { x = 1, y = 1 }\nUnitTemplate.skirtSize = { x = 2, y = 2 }\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.75, y = 0.75 },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.75, y = 0.75 },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.additions.faSourceContract = {\n    sourceId = \"URB2303\",\n    targetId = \"ugs2101\",\n    sourceCollisionOffset = { x = 0, y = -0.25, z = -0.1 },\n    sourceSkirtOffset = { x = -0.5, y = -0.5 },\n    sourceEnergyRequired = 1150,\n    sourceEnergyDrainPerSecond = 115,\n    nativeWeaponEconomyChargeSupported = false,\n}\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Turret_Muzzle\",\n                aimTolerance = 1,\n                defaultPitchAdjustment = 30,\n                defaultYawAdjustment = 0,\n                leadTarget = false,\n                pitchBone = \"Turret_Barrel\",\n                pitchMax = 60,\n                pitchMin = -60,\n                pitchSpeed = 6,\n                poseResetTime = 14,\n                projectileSpeed = 26.13,\n                reduceMuzzleVelocityToTarget = false,\n                solverType = \"LowArc\",\n                yawBone = \"Turret\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 6,\n            },\n        },\n        audio = { onFire = { looping = false, name = \"agom1224\" } },\n        collideFriendly = false,\n        damage = 1750,\n        damageFriendly = true,\n        damageRadius = 4,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vgm1241_cannon_artillery_medium_muzzle.sanvfx\" },\n        firingRandomness = 2.5,\n        layerTargetLimits = { \"Land\", \"WaterSurface\", \"Seabed\" },\n        layerWeaponLimits = { \"Land\", \"WaterSurface\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = 14,\n        muzzleGroups = { { muzzles = { \"Turret_Muzzle\" } } },\n        muzzles = { [\"Turret_Muzzle\"] = { aimController = \"Turret_Muzzle\" } },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 60,\n        projectileTemplate = \"pcg203\",\n        rangeMax = 128,\n        rangeMin = 5,\n        rangeRingType = \"IndirectFire\",\n        rangeTracking = 1.1,\n        reloadTime = 20,\n        targetCheckInterval = 4,\n        targetWaterLimits = \"Above\",\n    },\n}", ValidateStructure);
			QueueAppend(obj, mutations, "LJ/lua/common/systems/import.lua", "artillery virtual-projectile directory scanner", ValidateStockImport, "\n\n-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0\n-- Register only this module's two source-identified virtual projectile roots.\nlocal SCO_ArtilleryPairScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_ArtilleryPairScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n\n    local artilleryFolders = {\n        directory .. \"pcg103\",\n        directory .. \"pcg203\",\n    }\n    for _, artilleryFolder in ipairs(artilleryFolders) do\n        local found = false\n        for _, folder in ipairs(folders) do\n            if folder == artilleryFolder then\n                found = true\n                break\n            end\n        end\n        if not found then\n            table.insert(folders, artilleryFolder)\n        end\n    end\n    return folders\nend", ValidateImportScanner);
			QueueVirtualProjectile(obj, mutations, "pcg103", "URL0103 CIFGrenade01 virtual projectile", "---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = { onImpact = { looping = false, name = \"agoi1110\" } },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Cybran_URL0103_EMP_Grenade\",\n        tpId = \"pcg103\",\n    },\n    -- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0\n    -- CIFGrenade01: UniformScale=.05, InitialSpeed=14.6, range=3,\n    -- reduce-distance=30, LeadTarget=false, TurnRate=360,\n    -- VelocityAlign=true, DestroyOnWater=true. Sanctuary's weapon solver owns\n    -- the ballistic launch; compatible Guard effects stand in for the FA-only\n    -- projectile mesh and emitters without sharing an Aeon projectile route.\n    nonUniformScale = { x = 0.05, y = 0.05, z = 0.05 },\n    visuals = {\n        mesh = { lod0distance = 150 },\n        onImpactEffects = {\n            { effects = { { particleName = \"VFX/Impact/vgi1141_cannon_artillery_small_impact.sanvfx\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"VFX/Trails/vgt1141_cannon_artillery_small_trail.sanvfx\" } } },\n        },\n    },\n}", ValidateGrenadeProjectile);
			QueueVirtualProjectile(obj, mutations, "pcg203", "URB2303 CIFMolecularResonanceShell01 virtual projectile", "---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = { onImpact = { looping = false, name = \"agoi1130\" } },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Cybran_URB2303_Molecular_Resonance_Shell\",\n        tpId = \"pcg203\",\n    },\n    -- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0\n    -- CIFMolecularResonanceShell01: UniformScale=.25, LeadTarget=false,\n    -- TurnRate=360, VelocityAlign=true, DestroyOnWater=true.  The FA mesh and\n    -- emitter graph are not loadable as a Sanctuary projectile template, so\n    -- explicit Guard artillery effects are the non-Aeon compatibility path.\n    nonUniformScale = { x = 0.25, y = 0.25, z = 0.25 },\n    visuals = {\n        mesh = { lod0distance = 150 },\n        onImpactEffects = {\n            { effects = { { particleName = \"VFX/Impact/vgi1241_cannon_artillery_medium_impact.sanvfx\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"VFX/Trails/vgt1241_cannon_artillery_medium_trail.sanvfx\" } } },\n        },\n    },\n}", ValidateMolecularProjectile);
			Commit(obj, mutations);
			Log("Replaced UGL1101/UGS2101 with Medusa/Gunther source gameplay and dedicated Cybran projectile routes.");
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
			Log($"Failed to apply the FA artillery pair: {arg}");
			throw;
		}
	}

	private static bool Preflight(object cache)
	{
		CacheResource cachedResource = GetCachedResource(cache, "LJ/lua/common/units/unitsTemplates/ugl1101/ugl1101.santp", "UGL1101 template");
		CacheResource cachedResource2 = GetCachedResource(cache, "LJ/lua/common/units/unitsTemplates/ugs2101/ugs2101.santp", "UGS2101 template");
		CacheResource cachedResource3 = GetCachedResource(cache, "LJ/lua/common/systems/import.lua", "import scanner");
		CacheResource cacheResource = TryGetCachedResource(cache, ProjectileRelativePath("pcg103"), "pcg103 projectile");
		CacheResource cacheResource2 = TryGetCachedResource(cache, ProjectileRelativePath("pcg203"), "pcg203 projectile");
		string[] array = new string[5]
		{
			GetResourceText(cachedResource.Stock),
			GetResourceText(cachedResource2.Stock),
			GetResourceText(cachedResource3.Stock),
			(cacheResource == null) ? null : GetResourceText(cacheResource.Stock),
			(cacheResource2 == null) ? null : GetResourceText(cacheResource2.Stock)
		};
		bool[] source = array.Select((string text) => text != null && ContainsOverride(text)).ToArray();
		if (source.Any((bool value) => value) && !source.All((bool value) => value))
		{
			throw new InvalidOperationException("The FA artillery pair cache is partially marked; refusing a mixed generation.");
		}
		if (!source.Any((bool value) => value))
		{
			if (cacheResource != null || cacheResource2 != null)
			{
				throw new InvalidOperationException("A reserved artillery projectile ID exists without this module's marker.");
			}
			return false;
		}
		ValidateMobile(array[0]);
		ValidateStructure(array[1]);
		ValidateImportScanner(array[2]);
		ValidateGrenadeProjectile(array[3]);
		ValidateMolecularProjectile(array[4]);
		return true;
	}

	private static void ValidateStockMobile(string source)
	{
		RequireTokens(source, "UnitTemplate =", "tpId = \"ugl1101\"", "\"unitsDefaultGuard\"", "\"GuardLandUnit\"");
	}

	private static void ValidateStockStructure(string source)
	{
		RequireTokens(source, "UnitTemplate =", "tpId = \"ugs2101\"", "\"unitsDefaultGuard\"", "\"GuardStructure\"");
	}

	private static void ValidateMobile(string source)
	{
		ValidateOwnedAppendix(source, "Medusa", new string[37]
		{
			"displayName = \"Medusa\"", "name = \"Medusa\"", "max = 140", "regen = 0", "buildTime = 240", "alloys = 48", "energy = 240", "visionRadius = 18", "collisionSize = { x = 0.55, y = 0.45, z = 0.65 }", "UnitTemplate.footprint = { x = 0.55, y = 0.65 }",
			"size = { x = 0.35, y = 0.45 }", "z = -0.05", "movement.type = \"TracksLand\"", "movement.speed = 2.9", "movement.acceleration = 2.9", "movement.deceleration = 2.9", "movement.rotationSpeed = 90", "aimBone = \"Turret_Muzzle\"", "pitchBone = \"Turret_Barrel\"", "yawBone = \"Turret\"",
			"defaultPitchAdjustment = 45", "pitchMax = 90", "pitchMin = -90", "pitchSpeed = 70", "yawSpeed = 70", "projectileSpeed = 14", "solverType = \"HighArc\"", "damage = 195", "damageRadius = 2", "firingRandomness = 1.5",
			"projectileTemplate = \"pcg103\"", "rangeMax = 30", "rangeMin = 5", "rangeTracking = 1.15", "reloadTime = 5", "sourceEmpDuration = 3", "nativeEmpBuffSupported = false"
		}, new string[4] { "Wheel01_", "Turret01_", "pgi111", "damage = 400" });
	}

	private static void ValidateStructure(string source)
	{
		ValidateOwnedAppendix(source, "Gunther", new string[35]
		{
			"displayName = \"Gunther\"", "name = \"Gunther\"", "max = 3150", "regen = 0", "buildTime = 1600", "alloys = 2240", "energy = 16000", "visionRadius = 28", "centerOffset = { x = 0, y = -0.25, z = 0.1 }", "collisionSize = { x = 0.5, y = 1.4, z = 0.8 }",
			"UnitTemplate.footprint = { x = 1, y = 1 }", "UnitTemplate.skirtSize = { x = 2, y = 2 }", "size = { x = 0.75, y = 0.75 }", "UnitTemplate.visuals.holes = nil", "aimBone = \"Turret_Muzzle\"", "pitchBone = \"Turret_Barrel\"", "yawBone = \"Turret\"", "defaultPitchAdjustment = 30", "pitchMax = 60", "pitchMin = -60",
			"pitchSpeed = 6", "yawSpeed = 6", "projectileSpeed = 26.13", "solverType = \"LowArc\"", "damage = 1750", "damageRadius = 4", "damageFriendly = true", "firingRandomness = 2.5", "projectileTemplate = \"pcg203\"", "rangeMax = 128",
			"rangeMin = 5", "reloadTime = 20", "sourceEnergyRequired = 1150", "sourceEnergyDrainPerSecond = 115", "nativeWeaponEconomyChargeSupported = false"
		}, new string[3] { "Turret01_", "pgi211", "damage = 2000" });
	}

	private static void ValidateOwnedAppendix(string source, string label, IEnumerable<string> required, IEnumerable<string> forbidden)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0", 1, label + " marker");
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException(label + " marker is absent.");
		}
		string source2 = source.Substring(num);
		RequireTokens(source2, required.ToArray());
		RequireNotContains(source2, forbidden.ToArray());
		RequireNotContains(source2, "UnitTemplate.general.class");
	}

	private static void ValidateStockImport(string source)
	{
		RequireTokens(source, "function ScanDir", "Engine.GetFoldersInsideDirectory");
	}

	private static void ValidateImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0", 1, "artillery scanner marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "local SCO_ArtilleryPairScanDir = ScanDir", "function ScanDir(directory)", "local folders = SCO_ArtilleryPairScanDir(directory)", "directory .. \"pcg103\"", "directory .. \"pcg203\"");
		RequireExactly(source2, "function ScanDir(directory)", 1, "artillery scanner wrapper");
		RequireExactly(source2, "directory .. \"pcg103\"", 1, "pcg103 scanner route");
		RequireExactly(source2, "directory .. \"pcg203\"", 1, "pcg203 scanner route");
		RequireNotContains(source2, "scanRoot");
	}

	private static void ValidateGrenadeProjectile(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0", 1, "grenade projectile marker");
		RequireTokens(source, "ProjectileTemplate =", "tpId = \"pcg103\"", "name = \"Cybran_URL0103_EMP_Grenade\"", "InitialSpeed=14.6", "DestroyOnWater=true", "nonUniformScale = { x = 0.05", "VFX/Impact/vgi1141_cannon_artillery_small_impact.sanvfx", "VFX/Trails/vgt1141_cannon_artillery_small_trail.sanvfx");
		RequireNotContains(source, "vci1141", "vct1141", "paa111");
	}

	private static void ValidateMolecularProjectile(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0", 1, "molecular projectile marker");
		RequireTokens(source, "ProjectileTemplate =", "tpId = \"pcg203\"", "name = \"Cybran_URB2303_Molecular_Resonance_Shell\"", "CIFMolecularResonanceShell01", "DestroyOnWater=true", "nonUniformScale = { x = 0.25", "VFX/Impact/vgi1241_cannon_artillery_medium_impact.sanvfx", "VFX/Trails/vgt1241_cannon_artillery_medium_trail.sanvfx");
		RequireNotContains(source, "vci1241", "vct1241", "paa211");
	}

	private static void QueueAppend(object cache, List<CacheMutation> mutations, string relativePath, string description, Action<string> validateStock, string appendix, Action<string> validatePatched)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		validateStock(resourceText);
		object obj = CreateNativeArrayFromText(cachedResource.Stock.GetType(), AppendOverride(resourceText, appendix));
		try
		{
			validatePatched(GetResourceText(obj));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, description));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + description);
			throw;
		}
	}

	private static void QueueVirtualProjectile(object cache, List<CacheMutation> mutations, string projectileId, string description, string source, Action<string> validate)
	{
		if (TryGetCachedResource(cache, ProjectileRelativePath(projectileId), description) != null)
		{
			throw new InvalidOperationException("Reserved artillery projectile " + projectileId + " appeared after preflight.");
		}
		validate(source);
		object obj = CreateNativeArrayFromText(GetNativeArrayType(cache), source);
		try
		{
			validate(GetResourceText(obj));
			mutations.Add(new CacheMutation(ResolvePath(ProjectileRelativePath(projectileId)), null, obj, added: true, description));
		}
		catch
		{
			TryDisposeNativeArray(obj.GetType(), obj, "uncommitted " + description);
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
		foreach (CacheMutation item in mutations.Where((CacheMutation mutation) => mutation.Stock != null))
		{
			TryDisposeNativeArray(item.Stock.GetType(), item.Stock, "stock " + item.Description);
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

	private static string OwnedAppendix(string source)
	{
		int num = source.LastIndexOf("-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Artillery scanner marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0".Length, StringComparison.Ordinal);
		if (num2 >= 0)
		{
			return source.Substring(num, num2 - num);
		}
		return source.Substring(num);
	}

	private static string ProjectileRelativePath(string projectileId)
	{
		return "LJ/lua/common/projectiles/projectilesTemplates/" + projectileId + "/" + projectileId + ".santp";
	}

	private static bool ContainsOverride(string source)
	{
		return source.IndexOf("-- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0", StringComparison.Ordinal) >= 0;
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
				throw new InvalidOperationException("The artillery-owned source must not contain '" + text + "'.");
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
		string text = "[FA Artillery Pair Cache Patcher] " + message;
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
