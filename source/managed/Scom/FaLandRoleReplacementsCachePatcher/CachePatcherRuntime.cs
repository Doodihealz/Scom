using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using SupremeCommanderOverhaul.Shared;

namespace FaLandRoleReplacementsCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class ProjectileSpec
	{
		public string Id { get; }

		public string Name { get; }

		public string SourceId { get; }

		public string SourceBlueprintPath { get; }

		public string SourceBlueprintSha256 { get; }

		public string SourceScriptPath { get; }

		public string SourceScriptSha256 { get; }

		public string PhysicsProfile { get; }

		public string ImpactVfx { get; }

		public string TrailVfx { get; }

		public ProjectileSpec(string id, string name, string sourceId, string sourceBlueprintPath, string sourceBlueprintSha256, string sourceScriptPath, string sourceScriptSha256, string physicsProfile, string impactVfx, string trailVfx)
		{
			Id = id;
			Name = name;
			SourceId = sourceId;
			SourceBlueprintPath = sourceBlueprintPath;
			SourceBlueprintSha256 = sourceBlueprintSha256;
			SourceScriptPath = sourceScriptPath;
			SourceScriptSha256 = sourceScriptSha256;
			PhysicsProfile = physicsProfile;
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

	internal const string OverrideMarker = "-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0";

	internal const string SourceArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	internal const string ProjectileArchiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12";

	private const string TitanUnitPath = "LJ/lua/common/units/unitsTemplates/uel3001/uel3001.santp";

	private const string WagnerUnitPath = "LJ/lua/common/units/unitsTemplates/ugl2002/ugl2002.santp";

	private const string EdaHostClassPath = "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua";

	private const string GuardHostClassPath = "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua";

	private const string HostWeaponPath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private const string HostShieldPath = "LJ/lua/host/shield.lua";

	private const string UnitTemplateLoaderPath = "LJ/lua/common/loading/unitTemplateLoader.lua";

	private const string ImportPath = "LJ/lua/common/systems/import.lua";

	private const string ProjectileRoot = "LJ/lua/common/projectiles/projectilesTemplates";

	private const string TitanProjectileId = "per303";

	private const string WagnerRocketProjectileId = "pgr203r";

	private const string WagnerBolterProjectileId = "pgr203b";

	private const string WagnerTorpedoProjectileId = "pgr203t";

	private static readonly ProjectileSpec[] Projectiles = new ProjectileSpec[4]
	{
		new ProjectileSpec("per303", "UEF_Titan_Commander_Plasma_Small", "TDFPlasmaHeavy04", "projectiles/TDFPlasmaHeavy04/TDFPlasmaHeavy04_proj.bp", "52c3df44df89d8dcea319e60a35ec7c5068a9fe2cfa51d78b81d1972ea694b4d", "projectiles/TDFPlasmaHeavy04/TDFPlasmaHeavy04_script.lua", "3c05c2f3388f867ad54f2e6708d324fbe09aac2d1e6735e44a18bb83bee5c00d", "Gravity", "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx", "VFX/Trails/vct2101_rocket_antitank_small_trail.sanvfx"),
		new ProjectileSpec("pgr203r", "Cybran_Wagner_Meson_Rocket", "CDFRocketMeson01", "projectiles/CDFRocketMeson01/CDFRocketMeson01_proj.bp", "a952ed37521cdf7935413c8e994a44fc91a397389078e4ab1796866fe403ce1b", "projectiles/CDFRocketMeson01/CDFRocketMeson01_Script.lua", "905d2197b1c6202b13217d6817bdd13c534810f26b53f6cd5aa5deb67e0c8296", "NoGravity", "VFX/Impact/vgi1141_cannon_artillery_small_impact.sanvfx", "VFX/Trails/vgt1141_cannon_artillery_small_trail.sanvfx"),
		new ProjectileSpec("pgr203b", "Cybran_Wagner_Heavy_Electron_Bolter", "CDFBolter02", "projectiles/CDFBolter02/CDFBolter02_proj.bp", "f29bbeda9a1d139e330d3cf4d30d7a9cffb80b321e77a2bb86eda7b9471b8091", "projectiles/CDFBolter02/CDFBolter02_script.lua", "cf4b9bd0b40cdf37e10bcb77fdf12844676a503be8cdaff5f29be4226129b288", "Gravity", "VFX/Impact/vgi1101_cannon_small_impact.sanvfx", "VFX/Trails/vgt1101_cannon_small_trail.sanvfx"),
		new ProjectileSpec("pgr203t", "Cybran_Wagner_Meson_Torpedo", "CANTorpedoMeson02", "projectiles/CANTorpedoMeson02/CANTorpedoMeson02_proj.bp", "62fa521286123ca9dc8f8da1a9b7bf60cdcb15ee421b5ca05880c2c48d9045a8", "projectiles/CANTorpedoMeson02/CANTorpedoMeson02_script.lua", "f11469fe5cfd2b64398aa8f5e664b8d1895eb504e215bb4f33e6366538d6269b", "HomingTorpedo", "VFX/Impact/vgi1241_cannon_artillery_medium_impact.sanvfx", "VFX/Trails/vgt1241_cannon_artillery_medium_trail.sanvfx")
	};

	private const string TitanUnitAppendix = "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n-- Explicit same-faction role substitution: FA UEL0303 -> uel3001.\n-- The Sanctuary EDA class identity stays\n-- intact; every gameplay table below belongs to the Titan donor.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"UEL0303 -> uel3001\",\n    substitution = true,\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/UEL0303/UEL0303_unit.bp\",\n    sourceBlueprintSha256 = \"327d13c35da244c4beccda90e697cbd3f5220d9ad7fbafd04c342fa79a372d5a\",\n    sourceScript = \"units/UEL0303/UEL0303_Script.lua\",\n    sourceScriptSha256 = \"102f17046627fcb9806c11dad0c0e286718f86362bc126cb101d527decd4d761\",\n    class = { owner = \"unitsDefaultEDA\", name = \"EDALandUnit\" },\n    collision = { size = { x = 0.9, y = 1.2, z = 0.9 }, offset = { x = 0, y = 0, z = 0 } },\n    selection = { x = 0.55, z = 0.5, centerX = 0, centerZ = -0.25, thickness = 0.7 },\n    defence = { health = 1200, regen = 0 },\n    economy = { buildCostEnergy = 5400, buildCostMass = 480, buildTime = 2400, shieldMaintenanceEnergy = 25 },\n    intel = { visionRadius = 22 },\n    movement = {\n        sourceMotionType = \"RULEUMT_Land\",\n        acceleration = 4, brake = 4, speed = 4, reverseSpeed = 0,\n        steerForce = 10, turnRadius = 5, turnRate = 150,\n        sourceAnimationWalkRate = 5,\n        sanctuaryAuthoredSpeed = 0.8,\n    },\n    shield = {\n        personal = true, max = 2200, regen = 9, regenStart = 3,\n        sourceEnergyDrainRechargeTime = 5,\n        sourceDamageRechargeTime = 60,\n        sourceSize = 2.5, sourceVerticalOffset = 0,\n        startsOff = true,\n        sanctuaryPersonalCollider = \"Box\",\n        sanctuaryPersonalVisual = \"EDA sphere fallback\",\n    },\n    limitations = {\n        sourceDeathRateRandomization = \"0.75-1.25 unavailable; nominal rate used\",\n        transportFoldRuntime = false,\n        disabledFiringBonesRuntime = false,\n        ownerMeshPhaseShieldShader = false,\n        sourceProjectileEmitterGraph = false,\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 3: Assault Bot\"\nUnitTemplate.general.name = \"Titan\"\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"direct\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 80\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = { Shield = false }\n\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.6, z = 0 },\n    collisionSize = { x = 0.9, y = 1.2, z = 0.9 },\n}\nUnitTemplate.footprint = { x = 0.9, y = 0.9 }\nUnitTemplate.defence = {\n    health = { max = 1200, regen = 0, value = 1200 },\n    shields = {\n        {\n            boneName = \"Root\",\n            name = \"Personal Shield\",\n            type = \"Personal\",\n            max = 2200,\n            value = 2200,\n            regen = 9,\n            regenDelay = 3,\n            rechargeTime = 60,\n            rechargeHPRatio = 0.5,\n            radii = { x = 2.5, y = 2.5, z = 2.5 },\n            collisionSize = { x = 0.9, y = 1.2, z = 0.9 },\n            collisionOffset = { x = 0, y = 0.6, z = 0 },\n            offset = { x = 0, y = 0, z = 0 },\n            scoFaTitanPersonalShield = true,\n            scoManualRechargeTime = 5,\n        },\n    },\n}\nUnitTemplate.economy = {\n    buildTime = 2400,\n    cost = { alloys = 480, energy = 5400 },\n    maintenanceConsumption = { energy = 25 },\n}\nUnitTemplate.intel = { visionRadius = 22 }\nUnitTemplate.movement = {\n    acceleration = 4,\n    deceleration = 4,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"LandSmall\" },\n    collisionMaskSpawn = { \"LandSmall\" },\n    maxReverseDistance = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotationSpeed = 150,\n    sortOrder = 1,\n    speed = 4,\n    terrainAlignmentFactor = 1,\n    type = \"LegsLand\",\n}\nUnitTemplate.tags = {\n    \"ANTI_SURFACE\", \"BUILDABLE_BY_T3_FACTORY\", \"DIRECT_FIRE\",\n    \"EDA\", \"LAND\", \"MOBILE\", \"SHIELD\", \"TECH3\", \"WALKER\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.55, y = 0.5 },\n    offset = { x = 0, y = 0, z = -0.25 },\n}\nUnitTemplate.visuals.animations = {\n    walk = {\n        authoredSpeed = 0.8,\n        clipName = \"AnimWalk\",\n        sanAnimationPath = \"Units/uel3001/LOD0/uel3001.sananimation\",\n    },\n    death01 = {\n        clipName = \"AnimDeath01\",\n        sanAnimationPath = \"Units/uel3001/LOD0/uel3001.sananimation\",\n    },\n    death02 = {\n        clipName = \"AnimDeath02\",\n        sanAnimationPath = \"Units/uel3001/LOD0/uel3001.sananimation\",\n    },\n    fold = {\n        clipName = \"AnimFold\",\n        sanAnimationPath = \"Units/uel3001/LOD0/uel3001.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Muzzle_R\", yawBone = \"Torso\", pitchBone = \"ArmR_B04\",\n                aimTolerance = 2, defaultPitchAdjustment = 10, defaultYawAdjustment = 0,\n                leadTarget = true, pitchMin = -80, pitchMax = 100, pitchSpeed = 30,\n                poseResetTime = 3, projectileSpeed = 30, solverType = \"LowArc\",\n                yawMin = -180, yawMax = 180, yawSpeed = 150,\n            },\n            {\n                aimBone = \"Muzzle_L\", yawBone = \"Torso\", pitchBone = \"ArmL_B04\",\n                aimTolerance = 2, defaultPitchAdjustment = 10, defaultYawAdjustment = 0,\n                leadTarget = true, pitchMin = -80, pitchMax = 100, pitchSpeed = 30,\n                poseResetTime = 3, projectileSpeed = 30, solverType = \"LowArc\",\n                yawMin = -180, yawMax = 180, yawSpeed = 150,\n            },\n        },\n        muzzles = {\n            Muzzle_R = { aimController = \"Muzzle_R\" },\n            Muzzle_L = { aimController = \"Muzzle_L\" },\n        },\n        damage = 50,\n        damageRadius = 0,\n        damageType = \"Normal\",\n        firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = -1,\n        muzzleGroups = {\n            { muzzles = { \"Muzzle_R\" } },\n            { muzzles = { \"Muzzle_L\" } },\n        },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 0.7666666666666667,\n        projectileTemplate = \"per303\",\n        rangeMax = 20,\n        rangeMin = 0,\n        rangeRingType = \"DirectFire\",\n        rangeTracking = 1.1,\n        reloadTime = 0.3333333333333333,\n        targetWaterLimits = \"Above\",\n        scoFaWaterGate = \"Above\",\n    },\n}";

	private const string WagnerUnitAppendix = "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n-- Explicit same-faction role substitution: FA URL0203 -> ugl2002.\n-- The GuardLandUnit class is retained.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URL0203 -> ugl2002\",\n    substitution = true,\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/URL0203/URL0203_unit.bp\",\n    sourceBlueprintSha256 = \"c07db55c26720367272bc1b32b444a572632cbd9a21b772c1e43c06dcb4345ae\",\n    sourceScript = \"units/URL0203/URL0203_script.lua\",\n    sourceScriptSha256 = \"135df7d571db9b4812e497404a21c7d22002bc0620efdbe65420766c10c1b1cd\",\n    class = { owner = \"unitsDefaultGuard\", name = \"GuardLandUnit\" },\n    collision = { size = { x = 0.9, y = 0.45, z = 1.1 }, offset = { x = 0, y = 0, z = 0 } },\n    selection = { x = 0.55, z = 0.6, centerX = 0, centerZ = 0, thickness = 0.7 },\n    defence = { health = 1450, regen = 0 },\n    economy = { buildCostEnergy = 1980, buildCostMass = 297, buildTime = 1320 },\n    intel = { visionRadius = 15, sourceWaterVisionRadius = 20, sanctuaryWaterVisionRadiusSupported = false },\n    movement = {\n        sourceMotionType = \"RULEUMT_Amphibious\",\n        acceleration = 3.7, brake = 3.7, speed = 3.7, reverseSpeed = 0,\n        steerForce = 10, turnRadius = 0, turnRate = 90, rotateOnSpot = true,\n        sourceLayerChangeOffsetHeight = -0.2,\n    },\n    sourceLayerWeapons = { Land = { \"MesonRocket\", \"HeavyBolter\" }, Seabed = { \"Torpedo\" } },\n    limitations = {\n        sourceWaterEntryAudio = false,\n        sourceTreadAndGroundKickupEffects = false,\n        sourceRocketPackedMeshSwapAtSeconds = 0.15,\n        sanctuaryProjectileMeshSwapSupported = false,\n        sourceTorpedoStayUnderwaterConstraintSupported = false,\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 2: Amphibious Tank\"\nUnitTemplate.general.name = \"Wagner\"\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"direct\", tech = \"t2\" }\nUnitTemplate.general.iconUI = \"tech2_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 90\nUnitTemplate.general.iconUIType = \"amphibious\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = nil\n\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.225, z = 0 },\n    collisionSize = { x = 0.9, y = 0.45, z = 1.1 },\n}\nUnitTemplate.footprint = { x = 0.9, y = 1.1 }\nUnitTemplate.defence = { health = { max = 1450, regen = 0, value = 1450 } }\nUnitTemplate.economy = {\n    buildTime = 1320,\n    cost = { alloys = 297, energy = 1980 },\n}\nUnitTemplate.intel = { visionRadius = 15 }\nUnitTemplate.movement = {\n    acceleration = 3.7,\n    deceleration = 3.7,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"LandSmall\", \"SeabedSmall\" },\n    collisionMaskSpawn = { \"LandSmall\", \"SeabedSmall\" },\n    maxReverseDistance = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotationSpeed = 90,\n    sortOrder = 1,\n    speed = 3.7,\n    terrainAlignmentFactor = 1,\n    type = \"TracksSeabed\",\n}\nUnitTemplate.tags = {\n    \"AMPHIBIOUS\", \"ANTI_NAVY\", \"ANTI_SURFACE\",\n    \"BUILDABLE_BY_T2_FACTORY\", \"BUILDABLE_BY_T3_FACTORY\",\n    \"DIRECT_FIRE\", \"GUARD\", \"LAND\", \"MOBILE\", \"TANK\", \"TECH2\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.55, y = 0.6 },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nlocal function SCO_WagnerAim(aimBone, yawBone, pitchBone, pitchMin, pitchMax, pitchSpeed, defaultPitch, projectileSpeed, solverType)\n    return {\n        aimBone = aimBone, yawBone = yawBone, pitchBone = pitchBone,\n        aimTolerance = 2, defaultPitchAdjustment = defaultPitch,\n        defaultYawAdjustment = 0, leadTarget = true,\n        pitchMin = pitchMin, pitchMax = pitchMax, pitchSpeed = pitchSpeed,\n        poseResetTime = 3, projectileSpeed = projectileSpeed,\n        solverType = solverType,\n        yawMin = -180, yawMax = 180, yawSpeed = 90,\n    }\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = { SCO_WagnerAim(\"Turret03_Muzzle\", \"Turret02\", \"Turret02\", -10, 10, 70, 0, 15, \"NoArc\") },\n        damage = 200, damageRadius = 0, damageType = \"Normal\", firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0, muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Turret03_Muzzle\" } } },\n        muzzleSalvoDelay = 0, muzzleSalvoSize = 1,\n        projectileLifetime = 1.6866666666666668,\n        projectileTemplate = \"pgr203r\",\n        rangeMax = 22, rangeMin = 0, rangeRingType = \"DirectFire\",\n        rangeTracking = 1.1, reloadTime = 4,\n        targetWaterLimits = \"Above\", scoFaWaterGate = \"Above\",\n    },\n    {\n        aimControllers = { SCO_WagnerAim(\"Turret01_Muzzle\", \"Turret01\", \"Turret01_Barrel\", -35, 45, 30, 5, 30, \"LowArc\") },\n        damage = 50, damageRadius = 0, damageType = \"Normal\", firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0, muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Turret01_Muzzle\", \"Turret02_Muzzle\" } } },\n        muzzleSalvoDelay = 0, muzzleSalvoSize = 1,\n        projectileLifetime = 0.8433333333333334,\n        projectileTemplate = \"pgr203b\",\n        rangeMax = 22, rangeMin = 0, rangeRingType = \"DirectFire\",\n        rangeTracking = 1.1, reloadTime = 2,\n        targetWaterLimits = \"Above\", scoFaWaterGate = \"Above\",\n    },\n    {\n        aimControllers = { SCO_WagnerAim(\"Turret03_Muzzle\", \"Turret02\", \"Turret02\", -10, 50, 70, 20, 5, \"NoArc\") },\n        damage = 6, damageRadius = 0, damageType = \"Normal\", firingRandomness = 0,\n        layerTargetLimits = { \"Seabed\", \"Water\" },\n        layerWeaponLimits = { \"Seabed\" },\n        muzzleGroupChargeDelay = 0, muzzleGroupTimeOut = -1,\n        -- ProjectilesPerOnFire=2 is represented by two registrations of\n        -- the same non-beam source muzzle; two salvos are 0.8s apart.\n        muzzleGroups = { { muzzles = { \"Turret03_Muzzle\", \"Turret03_Muzzle\" } } },\n        muzzleSalvoDelay = 0.8, muzzleSalvoSize = 2,\n        projectileLifetime = 6,\n        projectileTemplate = \"pgr203t\",\n        rangeMax = 32, rangeMin = 0, rangeRingType = \"DirectFire\",\n        rangeTracking = 1.1, reloadTime = 4,\n        targetWaterLimits = \"Below\", scoFaWaterGate = \"Below\",\n    },\n}";

	private const string EdaHostAppendix = "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n-- Keep uel3001 on its stock EDALandUnit class. Delay only Titan's\n-- stock wreck/delete path for one deterministic source death clip.\nlocal SCO_FaRoleStockEdaDeathThread = HostEDALandUnit.DeathThread\nfunction HostEDALandUnit:DeathThread(overkillRatio)\n    if self.tpId ~= \"uel3001\" then\n        return SCO_FaRoleStockEdaDeathThread(self, overkillRatio)\n    end\n\n    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations\n    local useFirst = ((self.id and self.id.index) or 0) % 2 == 0\n    local death = animations and (useFirst and animations.death01 or animations.death02)\n    if not death or not death.id then\n        error(\"UEL3001 Titan requires both hash-pinned source death clips\")\n    end\n    Engine.PlayAnimation(self.id, death.id, 0.1)\n    WaitSeconds(useFirst and 3.4 or 1.9)\n    return SCO_FaRoleStockEdaDeathThread(self, overkillRatio)\nend";

	private const string GuardHostAppendix = "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n-- Keep ugl2002 on GuardLandUnit. Its source layer callback switches\n-- land guns and torpedoes; reproduce that state through the native\n-- targeting layer, which the weapon masks consume directly.\nlocal SCO_FaRoleLayers = Import(\"common/layers.lua\")\nlocal SCO_FaRoleStockGuardUpdateAnimations = HostGuardLandUnit.UpdateAnimations\nfunction HostGuardLandUnit:UpdateAnimations()\n    if self.tpId == \"ugl2002\" and not self.dead then\n        local targetLayer = SCO_FaRoleLayers.TargetingLayer.Land\n        local waterResult, hasWater = Engine.HasWater()\n        if waterResult == EngineErrorCode.Success and hasWater then\n            local levelResult, waterLevel = Engine.GetWaterLevel()\n            local position = self:GetPosition()\n            if levelResult == EngineErrorCode.Success and waterLevel ~= nil and position ~= nil then\n                local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)\n                if terrainResult == EngineErrorCode.Success\n                    and terrainHeight < waterLevel - 0.05\n                    and position.y < waterLevel - 0.05\n                then\n                    targetLayer = SCO_FaRoleLayers.TargetingLayer.Seabed\n                end\n            end\n        end\n        if self.targetingLayer ~= targetLayer then\n            self:SetTargetingLayer(targetLayer)\n        end\n    end\n    return SCO_FaRoleStockGuardUpdateAnimations(self)\nend";

	private const string HostWeaponAppendix = "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n-- targetWaterLimits is descriptive-only in this engine build. Enforce\n-- the two imported Wagner/Titan gates physically after every earlier\n-- CanShootAt implementation has accepted the target.\nlocal SCO_FaRoleStockCanShootAt = HostWeapon.CanShootAt\nfunction HostWeapon:CanShootAt(targetUnit)\n    if not SCO_FaRoleStockCanShootAt(self, targetUnit) then\n        return false\n    end\n    local gate = self.tp and self.tp.scoFaWaterGate\n    if gate == nil then return true end\n\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return gate == \"Above\" end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return false end\n\n    local ownerPosition = self.unit and self.unit:GetPosition()\n    local targetPosition = targetUnit and targetUnit:GetPosition()\n    if ownerPosition == nil or targetPosition == nil then return false end\n    local margin = 0.05\n    if gate == \"Above\" then\n        return ownerPosition.y >= waterLevel - margin\n            and targetPosition.y >= waterLevel - margin\n    elseif gate == \"Below\" then\n        return ownerPosition.y < waterLevel - margin\n            and targetPosition.y < waterLevel - margin\n    end\n    return false\nend";

	private const string HostShieldAppendix = "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n-- Titan's personal shield preserves health when manually/power disabled\n-- and uses the source five-second reactivation delay. Damage depletion\n-- continues through stock RechargeThread at the source 60 seconds.\nlocal SCO_FaRoleStockShieldSetEnableable = HostShield.SetEnableable\nfunction HostShield:SCO_FaTitanManualRechargeThread()\n    WaitSeconds(self.tp.scoManualRechargeTime)\n    self:SetEnabled(true)\n    self:SetRegenEnabled(true)\n    self.rechargeThread = nil\nend\n\nfunction HostShield:SetEnableable(value, skipRecharge)\n    local isTitan = self.owner\n        and self.owner.tpId == \"uel3001\"\n        and self.tp\n        and self.tp.scoFaTitanPersonalShield == true\n    if not isTitan then\n        return SCO_FaRoleStockShieldSetEnableable(self, value, skipRecharge)\n    end\n    if value == self.isEnableable then return end\n    self.isEnableable = value\n\n    if value then\n        if skipRecharge then\n            self:SetEnabled(true)\n            self:SetRegenEnabled(true)\n            self:SetHealth(self:GetMaxHealth())\n        elseif self:GetHealth() <= 0 then\n            -- A damage-depleted shield stays on the donor's distinct\n            -- 60-second damage recharge even if power/toggle state\n            -- interrupted the original stock recharge thread.\n            self.rechargeThread = self:NewThread(self.RechargeThread)\n        else\n            self.rechargeThread = self:NewThread(self.SCO_FaTitanManualRechargeThread)\n        end\n        return\n    end\n\n    if self.rechargeThread then\n        KillThread(self.rechargeThread)\n        self.rechargeThread = nil\n    end\n    if self.regenAfterDelayThread then\n        KillThread(self.regenAfterDelayThread)\n        self.regenAfterDelayThread = nil\n    end\n    self:SetEnabled(false)\n    self:SetRegenEnabled(false)\nend";

	private const string ImportScannerAppendix = "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n-- These four isolated projectile templates live only in FilesCache.\nlocal SCO_FaRoleScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_FaRoleScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n    local roleFolders = {\n        directory .. \"per303\",\n        directory .. \"pgr203r\",\n        directory .. \"pgr203b\",\n        directory .. \"pgr203t\",\n    }\n    for _, roleFolder in ipairs(roleFolders) do\n        local found = false\n        for _, folder in ipairs(folders) do\n            if folder == roleFolder then found = true break end\n        end\n        if not found then table.insert(folders, roleFolder) end\n    end\n    return folders\nend";

	public static void Apply()
	{
		ValidatePinnedScope();
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		try
		{
			obj = GetLuaFileCache();
			ValidateTransactionState(obj);
			QueueAppend(obj, list, "LJ/lua/common/units/unitsTemplates/uel3001/uel3001.santp", "UEL3001 Titan role template", "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n-- Explicit same-faction role substitution: FA UEL0303 -> uel3001.\n-- The Sanctuary EDA class identity stays\n-- intact; every gameplay table below belongs to the Titan donor.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"UEL0303 -> uel3001\",\n    substitution = true,\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/UEL0303/UEL0303_unit.bp\",\n    sourceBlueprintSha256 = \"327d13c35da244c4beccda90e697cbd3f5220d9ad7fbafd04c342fa79a372d5a\",\n    sourceScript = \"units/UEL0303/UEL0303_Script.lua\",\n    sourceScriptSha256 = \"102f17046627fcb9806c11dad0c0e286718f86362bc126cb101d527decd4d761\",\n    class = { owner = \"unitsDefaultEDA\", name = \"EDALandUnit\" },\n    collision = { size = { x = 0.9, y = 1.2, z = 0.9 }, offset = { x = 0, y = 0, z = 0 } },\n    selection = { x = 0.55, z = 0.5, centerX = 0, centerZ = -0.25, thickness = 0.7 },\n    defence = { health = 1200, regen = 0 },\n    economy = { buildCostEnergy = 5400, buildCostMass = 480, buildTime = 2400, shieldMaintenanceEnergy = 25 },\n    intel = { visionRadius = 22 },\n    movement = {\n        sourceMotionType = \"RULEUMT_Land\",\n        acceleration = 4, brake = 4, speed = 4, reverseSpeed = 0,\n        steerForce = 10, turnRadius = 5, turnRate = 150,\n        sourceAnimationWalkRate = 5,\n        sanctuaryAuthoredSpeed = 0.8,\n    },\n    shield = {\n        personal = true, max = 2200, regen = 9, regenStart = 3,\n        sourceEnergyDrainRechargeTime = 5,\n        sourceDamageRechargeTime = 60,\n        sourceSize = 2.5, sourceVerticalOffset = 0,\n        startsOff = true,\n        sanctuaryPersonalCollider = \"Box\",\n        sanctuaryPersonalVisual = \"EDA sphere fallback\",\n    },\n    limitations = {\n        sourceDeathRateRandomization = \"0.75-1.25 unavailable; nominal rate used\",\n        transportFoldRuntime = false,\n        disabledFiringBonesRuntime = false,\n        ownerMeshPhaseShieldShader = false,\n        sourceProjectileEmitterGraph = false,\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 3: Assault Bot\"\nUnitTemplate.general.name = \"Titan\"\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"direct\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 80\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = { Shield = false }\n\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.6, z = 0 },\n    collisionSize = { x = 0.9, y = 1.2, z = 0.9 },\n}\nUnitTemplate.footprint = { x = 0.9, y = 0.9 }\nUnitTemplate.defence = {\n    health = { max = 1200, regen = 0, value = 1200 },\n    shields = {\n        {\n            boneName = \"Root\",\n            name = \"Personal Shield\",\n            type = \"Personal\",\n            max = 2200,\n            value = 2200,\n            regen = 9,\n            regenDelay = 3,\n            rechargeTime = 60,\n            rechargeHPRatio = 0.5,\n            radii = { x = 2.5, y = 2.5, z = 2.5 },\n            collisionSize = { x = 0.9, y = 1.2, z = 0.9 },\n            collisionOffset = { x = 0, y = 0.6, z = 0 },\n            offset = { x = 0, y = 0, z = 0 },\n            scoFaTitanPersonalShield = true,\n            scoManualRechargeTime = 5,\n        },\n    },\n}\nUnitTemplate.economy = {\n    buildTime = 2400,\n    cost = { alloys = 480, energy = 5400 },\n    maintenanceConsumption = { energy = 25 },\n}\nUnitTemplate.intel = { visionRadius = 22 }\nUnitTemplate.movement = {\n    acceleration = 4,\n    deceleration = 4,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"LandSmall\" },\n    collisionMaskSpawn = { \"LandSmall\" },\n    maxReverseDistance = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotationSpeed = 150,\n    sortOrder = 1,\n    speed = 4,\n    terrainAlignmentFactor = 1,\n    type = \"LegsLand\",\n}\nUnitTemplate.tags = {\n    \"ANTI_SURFACE\", \"BUILDABLE_BY_T3_FACTORY\", \"DIRECT_FIRE\",\n    \"EDA\", \"LAND\", \"MOBILE\", \"SHIELD\", \"TECH3\", \"WALKER\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.55, y = 0.5 },\n    offset = { x = 0, y = 0, z = -0.25 },\n}\nUnitTemplate.visuals.animations = {\n    walk = {\n        authoredSpeed = 0.8,\n        clipName = \"AnimWalk\",\n        sanAnimationPath = \"Units/uel3001/LOD0/uel3001.sananimation\",\n    },\n    death01 = {\n        clipName = \"AnimDeath01\",\n        sanAnimationPath = \"Units/uel3001/LOD0/uel3001.sananimation\",\n    },\n    death02 = {\n        clipName = \"AnimDeath02\",\n        sanAnimationPath = \"Units/uel3001/LOD0/uel3001.sananimation\",\n    },\n    fold = {\n        clipName = \"AnimFold\",\n        sanAnimationPath = \"Units/uel3001/LOD0/uel3001.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Muzzle_R\", yawBone = \"Torso\", pitchBone = \"ArmR_B04\",\n                aimTolerance = 2, defaultPitchAdjustment = 10, defaultYawAdjustment = 0,\n                leadTarget = true, pitchMin = -80, pitchMax = 100, pitchSpeed = 30,\n                poseResetTime = 3, projectileSpeed = 30, solverType = \"LowArc\",\n                yawMin = -180, yawMax = 180, yawSpeed = 150,\n            },\n            {\n                aimBone = \"Muzzle_L\", yawBone = \"Torso\", pitchBone = \"ArmL_B04\",\n                aimTolerance = 2, defaultPitchAdjustment = 10, defaultYawAdjustment = 0,\n                leadTarget = true, pitchMin = -80, pitchMax = 100, pitchSpeed = 30,\n                poseResetTime = 3, projectileSpeed = 30, solverType = \"LowArc\",\n                yawMin = -180, yawMax = 180, yawSpeed = 150,\n            },\n        },\n        muzzles = {\n            Muzzle_R = { aimController = \"Muzzle_R\" },\n            Muzzle_L = { aimController = \"Muzzle_L\" },\n        },\n        damage = 50,\n        damageRadius = 0,\n        damageType = \"Normal\",\n        firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = -1,\n        muzzleGroups = {\n            { muzzles = { \"Muzzle_R\" } },\n            { muzzles = { \"Muzzle_L\" } },\n        },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 0.7666666666666667,\n        projectileTemplate = \"per303\",\n        rangeMax = 20,\n        rangeMin = 0,\n        rangeRingType = \"DirectFire\",\n        rangeTracking = 1.1,\n        reloadTime = 0.3333333333333333,\n        targetWaterLimits = \"Above\",\n        scoFaWaterGate = \"Above\",\n    },\n}", ValidateTitan);
			QueueAppend(obj, list, "LJ/lua/common/units/unitsTemplates/ugl2002/ugl2002.santp", "UGL2002 Wagner role template", "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n-- Explicit same-faction role substitution: FA URL0203 -> ugl2002.\n-- The GuardLandUnit class is retained.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URL0203 -> ugl2002\",\n    substitution = true,\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/URL0203/URL0203_unit.bp\",\n    sourceBlueprintSha256 = \"c07db55c26720367272bc1b32b444a572632cbd9a21b772c1e43c06dcb4345ae\",\n    sourceScript = \"units/URL0203/URL0203_script.lua\",\n    sourceScriptSha256 = \"135df7d571db9b4812e497404a21c7d22002bc0620efdbe65420766c10c1b1cd\",\n    class = { owner = \"unitsDefaultGuard\", name = \"GuardLandUnit\" },\n    collision = { size = { x = 0.9, y = 0.45, z = 1.1 }, offset = { x = 0, y = 0, z = 0 } },\n    selection = { x = 0.55, z = 0.6, centerX = 0, centerZ = 0, thickness = 0.7 },\n    defence = { health = 1450, regen = 0 },\n    economy = { buildCostEnergy = 1980, buildCostMass = 297, buildTime = 1320 },\n    intel = { visionRadius = 15, sourceWaterVisionRadius = 20, sanctuaryWaterVisionRadiusSupported = false },\n    movement = {\n        sourceMotionType = \"RULEUMT_Amphibious\",\n        acceleration = 3.7, brake = 3.7, speed = 3.7, reverseSpeed = 0,\n        steerForce = 10, turnRadius = 0, turnRate = 90, rotateOnSpot = true,\n        sourceLayerChangeOffsetHeight = -0.2,\n    },\n    sourceLayerWeapons = { Land = { \"MesonRocket\", \"HeavyBolter\" }, Seabed = { \"Torpedo\" } },\n    limitations = {\n        sourceWaterEntryAudio = false,\n        sourceTreadAndGroundKickupEffects = false,\n        sourceRocketPackedMeshSwapAtSeconds = 0.15,\n        sanctuaryProjectileMeshSwapSupported = false,\n        sourceTorpedoStayUnderwaterConstraintSupported = false,\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 2: Amphibious Tank\"\nUnitTemplate.general.name = \"Wagner\"\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"direct\", tech = \"t2\" }\nUnitTemplate.general.iconUI = \"tech2_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 90\nUnitTemplate.general.iconUIType = \"amphibious\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = nil\n\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.225, z = 0 },\n    collisionSize = { x = 0.9, y = 0.45, z = 1.1 },\n}\nUnitTemplate.footprint = { x = 0.9, y = 1.1 }\nUnitTemplate.defence = { health = { max = 1450, regen = 0, value = 1450 } }\nUnitTemplate.economy = {\n    buildTime = 1320,\n    cost = { alloys = 297, energy = 1980 },\n}\nUnitTemplate.intel = { visionRadius = 15 }\nUnitTemplate.movement = {\n    acceleration = 3.7,\n    deceleration = 3.7,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"LandSmall\", \"SeabedSmall\" },\n    collisionMaskSpawn = { \"LandSmall\", \"SeabedSmall\" },\n    maxReverseDistance = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotationSpeed = 90,\n    sortOrder = 1,\n    speed = 3.7,\n    terrainAlignmentFactor = 1,\n    type = \"TracksSeabed\",\n}\nUnitTemplate.tags = {\n    \"AMPHIBIOUS\", \"ANTI_NAVY\", \"ANTI_SURFACE\",\n    \"BUILDABLE_BY_T2_FACTORY\", \"BUILDABLE_BY_T3_FACTORY\",\n    \"DIRECT_FIRE\", \"GUARD\", \"LAND\", \"MOBILE\", \"TANK\", \"TECH2\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.55, y = 0.6 },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nlocal function SCO_WagnerAim(aimBone, yawBone, pitchBone, pitchMin, pitchMax, pitchSpeed, defaultPitch, projectileSpeed, solverType)\n    return {\n        aimBone = aimBone, yawBone = yawBone, pitchBone = pitchBone,\n        aimTolerance = 2, defaultPitchAdjustment = defaultPitch,\n        defaultYawAdjustment = 0, leadTarget = true,\n        pitchMin = pitchMin, pitchMax = pitchMax, pitchSpeed = pitchSpeed,\n        poseResetTime = 3, projectileSpeed = projectileSpeed,\n        solverType = solverType,\n        yawMin = -180, yawMax = 180, yawSpeed = 90,\n    }\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = { SCO_WagnerAim(\"Turret03_Muzzle\", \"Turret02\", \"Turret02\", -10, 10, 70, 0, 15, \"NoArc\") },\n        damage = 200, damageRadius = 0, damageType = \"Normal\", firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0, muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Turret03_Muzzle\" } } },\n        muzzleSalvoDelay = 0, muzzleSalvoSize = 1,\n        projectileLifetime = 1.6866666666666668,\n        projectileTemplate = \"pgr203r\",\n        rangeMax = 22, rangeMin = 0, rangeRingType = \"DirectFire\",\n        rangeTracking = 1.1, reloadTime = 4,\n        targetWaterLimits = \"Above\", scoFaWaterGate = \"Above\",\n    },\n    {\n        aimControllers = { SCO_WagnerAim(\"Turret01_Muzzle\", \"Turret01\", \"Turret01_Barrel\", -35, 45, 30, 5, 30, \"LowArc\") },\n        damage = 50, damageRadius = 0, damageType = \"Normal\", firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0, muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Turret01_Muzzle\", \"Turret02_Muzzle\" } } },\n        muzzleSalvoDelay = 0, muzzleSalvoSize = 1,\n        projectileLifetime = 0.8433333333333334,\n        projectileTemplate = \"pgr203b\",\n        rangeMax = 22, rangeMin = 0, rangeRingType = \"DirectFire\",\n        rangeTracking = 1.1, reloadTime = 2,\n        targetWaterLimits = \"Above\", scoFaWaterGate = \"Above\",\n    },\n    {\n        aimControllers = { SCO_WagnerAim(\"Turret03_Muzzle\", \"Turret02\", \"Turret02\", -10, 50, 70, 20, 5, \"NoArc\") },\n        damage = 6, damageRadius = 0, damageType = \"Normal\", firingRandomness = 0,\n        layerTargetLimits = { \"Seabed\", \"Water\" },\n        layerWeaponLimits = { \"Seabed\" },\n        muzzleGroupChargeDelay = 0, muzzleGroupTimeOut = -1,\n        -- ProjectilesPerOnFire=2 is represented by two registrations of\n        -- the same non-beam source muzzle; two salvos are 0.8s apart.\n        muzzleGroups = { { muzzles = { \"Turret03_Muzzle\", \"Turret03_Muzzle\" } } },\n        muzzleSalvoDelay = 0.8, muzzleSalvoSize = 2,\n        projectileLifetime = 6,\n        projectileTemplate = \"pgr203t\",\n        rangeMax = 32, rangeMin = 0, rangeRingType = \"DirectFire\",\n        rangeTracking = 1.1, reloadTime = 4,\n        targetWaterLimits = \"Below\", scoFaWaterGate = \"Below\",\n    },\n}", ValidateWagner);
			QueueAppend(obj, list, "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", "Titan EDA death lifecycle", "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n-- Keep uel3001 on its stock EDALandUnit class. Delay only Titan's\n-- stock wreck/delete path for one deterministic source death clip.\nlocal SCO_FaRoleStockEdaDeathThread = HostEDALandUnit.DeathThread\nfunction HostEDALandUnit:DeathThread(overkillRatio)\n    if self.tpId ~= \"uel3001\" then\n        return SCO_FaRoleStockEdaDeathThread(self, overkillRatio)\n    end\n\n    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations\n    local useFirst = ((self.id and self.id.index) or 0) % 2 == 0\n    local death = animations and (useFirst and animations.death01 or animations.death02)\n    if not death or not death.id then\n        error(\"UEL3001 Titan requires both hash-pinned source death clips\")\n    end\n    Engine.PlayAnimation(self.id, death.id, 0.1)\n    WaitSeconds(useFirst and 3.4 or 1.9)\n    return SCO_FaRoleStockEdaDeathThread(self, overkillRatio)\nend", ValidateEdaHost);
			QueueAppend(obj, list, "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Wagner Guard layer lifecycle", "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n-- Keep ugl2002 on GuardLandUnit. Its source layer callback switches\n-- land guns and torpedoes; reproduce that state through the native\n-- targeting layer, which the weapon masks consume directly.\nlocal SCO_FaRoleLayers = Import(\"common/layers.lua\")\nlocal SCO_FaRoleStockGuardUpdateAnimations = HostGuardLandUnit.UpdateAnimations\nfunction HostGuardLandUnit:UpdateAnimations()\n    if self.tpId == \"ugl2002\" and not self.dead then\n        local targetLayer = SCO_FaRoleLayers.TargetingLayer.Land\n        local waterResult, hasWater = Engine.HasWater()\n        if waterResult == EngineErrorCode.Success and hasWater then\n            local levelResult, waterLevel = Engine.GetWaterLevel()\n            local position = self:GetPosition()\n            if levelResult == EngineErrorCode.Success and waterLevel ~= nil and position ~= nil then\n                local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)\n                if terrainResult == EngineErrorCode.Success\n                    and terrainHeight < waterLevel - 0.05\n                    and position.y < waterLevel - 0.05\n                then\n                    targetLayer = SCO_FaRoleLayers.TargetingLayer.Seabed\n                end\n            end\n        end\n        if self.targetingLayer ~= targetLayer then\n            self:SetTargetingLayer(targetLayer)\n        end\n    end\n    return SCO_FaRoleStockGuardUpdateAnimations(self)\nend", ValidateGuardHost);
			QueueAppend(obj, list, "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "role water-target gate", "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n-- targetWaterLimits is descriptive-only in this engine build. Enforce\n-- the two imported Wagner/Titan gates physically after every earlier\n-- CanShootAt implementation has accepted the target.\nlocal SCO_FaRoleStockCanShootAt = HostWeapon.CanShootAt\nfunction HostWeapon:CanShootAt(targetUnit)\n    if not SCO_FaRoleStockCanShootAt(self, targetUnit) then\n        return false\n    end\n    local gate = self.tp and self.tp.scoFaWaterGate\n    if gate == nil then return true end\n\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return gate == \"Above\" end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return false end\n\n    local ownerPosition = self.unit and self.unit:GetPosition()\n    local targetPosition = targetUnit and targetUnit:GetPosition()\n    if ownerPosition == nil or targetPosition == nil then return false end\n    local margin = 0.05\n    if gate == \"Above\" then\n        return ownerPosition.y >= waterLevel - margin\n            and targetPosition.y >= waterLevel - margin\n    elseif gate == \"Below\" then\n        return ownerPosition.y < waterLevel - margin\n            and targetPosition.y < waterLevel - margin\n    end\n    return false\nend", ValidateHostWeapon);
			QueueAppend(obj, list, "LJ/lua/host/shield.lua", "Titan personal-shield lifecycle", "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n-- Titan's personal shield preserves health when manually/power disabled\n-- and uses the source five-second reactivation delay. Damage depletion\n-- continues through stock RechargeThread at the source 60 seconds.\nlocal SCO_FaRoleStockShieldSetEnableable = HostShield.SetEnableable\nfunction HostShield:SCO_FaTitanManualRechargeThread()\n    WaitSeconds(self.tp.scoManualRechargeTime)\n    self:SetEnabled(true)\n    self:SetRegenEnabled(true)\n    self.rechargeThread = nil\nend\n\nfunction HostShield:SetEnableable(value, skipRecharge)\n    local isTitan = self.owner\n        and self.owner.tpId == \"uel3001\"\n        and self.tp\n        and self.tp.scoFaTitanPersonalShield == true\n    if not isTitan then\n        return SCO_FaRoleStockShieldSetEnableable(self, value, skipRecharge)\n    end\n    if value == self.isEnableable then return end\n    self.isEnableable = value\n\n    if value then\n        if skipRecharge then\n            self:SetEnabled(true)\n            self:SetRegenEnabled(true)\n            self:SetHealth(self:GetMaxHealth())\n        elseif self:GetHealth() <= 0 then\n            -- A damage-depleted shield stays on the donor's distinct\n            -- 60-second damage recharge even if power/toggle state\n            -- interrupted the original stock recharge thread.\n            self.rechargeThread = self:NewThread(self.RechargeThread)\n        else\n            self.rechargeThread = self:NewThread(self.SCO_FaTitanManualRechargeThread)\n        end\n        return\n    end\n\n    if self.rechargeThread then\n        KillThread(self.rechargeThread)\n        self.rechargeThread = nil\n    end\n    if self.regenAfterDelayThread then\n        KillThread(self.regenAfterDelayThread)\n        self.regenAfterDelayThread = nil\n    end\n    self:SetEnabled(false)\n    self:SetRegenEnabled(false)\nend", ValidateHostShield);
			QueueTransform(obj, list, "LJ/lua/common/loading/unitTemplateLoader.lua", "personal-shield collider loader", TransformUnitTemplateLoader, ValidateUnitTemplateLoader);
			QueueAppend(obj, list, "LJ/lua/common/systems/import.lua", "role virtual-projectile scanner", "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n-- These four isolated projectile templates live only in FilesCache.\nlocal SCO_FaRoleScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_FaRoleScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n    local roleFolders = {\n        directory .. \"per303\",\n        directory .. \"pgr203r\",\n        directory .. \"pgr203b\",\n        directory .. \"pgr203t\",\n    }\n    for _, roleFolder in ipairs(roleFolders) do\n        local found = false\n        for _, folder in ipairs(folders) do\n            if folder == roleFolder then found = true break end\n        end\n        if not found then table.insert(folders, roleFolder) end\n    end\n    return folders\nend", ValidateImportScanner);
			ProjectileSpec[] projectiles = Projectiles;
			foreach (ProjectileSpec projectile in projectiles)
			{
				QueueVirtualProjectile(obj, list, projectile);
			}
			if (list.Count == 0)
			{
				Log("Titan/Wagner gameplay and isolated projectile resources are already current.");
				return;
			}
			Commit(obj, list);
			Log("Applied the atomic UEL0303->uel3001 and URL0203->ugl2002 role-replacement transaction.");
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
			Log($"Failed to apply the FA land-role transaction: {arg}");
			throw;
		}
	}

	private static void ValidatePinnedScope()
	{
		string[] array = Projectiles.Select((ProjectileSpec projectile) => projectile.Id).ToArray();
		if (Projectiles.Length != 4 || array.Distinct(StringComparer.Ordinal).Count() != 4 || array[0] != "per303" || array[1] != "pgr203r" || array[2] != "pgr203b" || array[3] != "pgr203t")
		{
			throw new InvalidOperationException("The reviewed Titan/Wagner projectile scope changed.");
		}
		ProjectileSpec[] projectiles = Projectiles;
		foreach (ProjectileSpec projectileSpec in projectiles)
		{
			if (projectileSpec.SourceBlueprintSha256.Length != 64 || projectileSpec.SourceScriptSha256.Length != 64)
			{
				throw new InvalidOperationException(projectileSpec.SourceId + " has an invalid source hash lock.");
			}
		}
	}

	private static void ValidateTransactionState(object cache)
	{
		int num = 0;
		(string, string)[] array = new(string, string)[8]
		{
			("LJ/lua/common/units/unitsTemplates/uel3001/uel3001.santp", "UEL3001 Titan role template"),
			("LJ/lua/common/units/unitsTemplates/ugl2002/ugl2002.santp", "UGL2002 Wagner role template"),
			("LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", "Titan EDA death lifecycle"),
			("LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Wagner Guard layer lifecycle"),
			("LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "role water-target gate"),
			("LJ/lua/host/shield.lua", "Titan personal-shield lifecycle"),
			("LJ/lua/common/loading/unitTemplateLoader.lua", "personal-shield collider loader"),
			("LJ/lua/common/systems/import.lua", "role virtual-projectile scanner")
		};
		for (int i = 0; i < array.Length; i++)
		{
			(string, string) tuple = array[i];
			if (GetResourceText(GetCachedResource(cache, tuple.Item1, tuple.Item2).Stock).IndexOf("-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", StringComparison.Ordinal) >= 0)
			{
				num++;
			}
		}
		ProjectileSpec[] projectiles = Projectiles;
		foreach (ProjectileSpec projectileSpec in projectiles)
		{
			CacheResource cacheResource = TryGetCachedResource(cache, ProjectilePath(projectileSpec.Id), projectileSpec.SourceId + " isolated projectile");
			if (cacheResource != null && GetResourceText(cacheResource.Stock).IndexOf("-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", StringComparison.Ordinal) >= 0)
			{
				num++;
			}
		}
		if (num != 0 && num != 12)
		{
			throw new InvalidOperationException($"A partial Titan/Wagner transaction was found ({num}/{12} owned resources). " + "Refusing to mix stock and patched role resources.");
		}
	}

	private static string TransformUnitTemplateLoader(string source)
	{
		string text = NormalizeNewlines(source);
		if (text.IndexOf("-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", StringComparison.Ordinal) >= 0)
		{
			ValidateUnitTemplateLoader(text);
			return text;
		}
		RequireExactly(text, "                shield.radii,\n                EngineClasses.float3(0, 0, 0),\n                ColliderType.Sphere,", 2, "stock shield collider blocks");
		string text2 = text.Replace("                shield.radii,\n                EngineClasses.float3(0, 0, 0),\n                ColliderType.Sphere,", "                (shield.scoFaTitanPersonalShield == true and not shield.scoFaTitanSphereCollider and shield.collisionSize) or shield.radii,\n                (shield.scoFaTitanPersonalShield == true and not shield.scoFaTitanSphereCollider and shield.collisionOffset) or EngineClasses.float3(0, 0, 0),\n                (shield.scoFaTitanPersonalShield == true and not shield.scoFaTitanSphereCollider and ColliderType.Box) or ColliderType.Sphere,") + "\n\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0\n";
		ValidateUnitTemplateLoader(text2);
		return text2;
	}

	private static string BuildVirtualProjectile(ProjectileSpec projectile)
	{
		if (projectile.Id == "per303")
		{
			return TitanFaContract.BuildProjectile(projectile.Name, projectile.SourceId, projectile.SourceBlueprintPath, projectile.SourceBlueprintSha256, projectile.SourceScriptPath, projectile.SourceScriptSha256, projectile.ImpactVfx, projectile.TrailVfx);
		}
		string text = projectile.PhysicsProfile switch
		{
			"Gravity" => string.Empty, 
			"NoGravity" => "    movement = { gravityMultiplier = 0 },\n", 
			"HomingTorpedo" => "    movement = { acceleration = 5, gravityMultiplier = 0, rotationSpeed = 230, speedMax = 18, type = \"TargetEntity\" },\n", 
			_ => throw new InvalidOperationException("Unknown projectile physics profile " + projectile.PhysicsProfile + "."), 
		};
		return "---@type ProjectileTemplate\nProjectileTemplate = {\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"" + projectile.Name + "\",\n        tpId = \"" + projectile.Id + "\",\n    },\n" + text + "    nonUniformScale = { x = 1, y = 1, z = 1 },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = {\n            { effects = { { particleName = \"" + projectile.ImpactVfx + "\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"" + projectile.TrailVfx + "\" } } },\n        },\n    },\n}\n\n-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\n-- Source ID: " + projectile.SourceId + "\n-- Source blueprint: " + projectile.SourceBlueprintPath + "\n-- Source blueprint SHA-256: " + projectile.SourceBlueprintSha256 + "\n-- Source script: " + projectile.SourceScriptPath + "\n-- Source script SHA-256: " + projectile.SourceScriptSha256 + "\n-- Sanctuary limitation: FA emitter graphs and rocket packed-mesh swap are not native sanvfx inputs.\n-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0";
	}

	private static void ValidateStock(string relativePath, string source)
	{
		if (relativePath == null)
		{
			return;
		}
		switch (relativePath.Length)
		{
		case 56:
			switch (relativePath[36])
			{
			case 'e':
				if (relativePath == "LJ/lua/common/units/unitsTemplates/uel3001/uel3001.santp")
				{
					ValidateStockUnit(source, "uel3001", "unitsDefaultEDA", "EDALandUnit");
				}
				break;
			case 'g':
				if (relativePath == "LJ/lua/common/units/unitsTemplates/ugl2002/ugl2002.santp")
				{
					ValidateStockUnit(source, "ugl2002", "unitsDefaultGuard", "GuardLandUnit");
				}
				break;
			}
			break;
		case 50:
			if (relativePath == "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua")
			{
				RequireTokens(source, "HostEDALandUnit = Class(\"EDALandUnit\", LandUnit)", "HostEDACommander");
			}
			break;
		case 52:
			if (relativePath == "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua")
			{
				RequireTokens(source, "HostGuardLandUnit = Class(\"GuardLandUnit\", LandUnit)", "HostGuardCommander");
			}
			break;
		case 53:
			if (relativePath == "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua")
			{
				RequireTokens(source, "function HostWeapon:CanShootAt(targetUnit)", "self.layerWeaponLimitsMask", "self.layerTargetLimitsMask");
			}
			break;
		case 22:
			if (relativePath == "LJ/lua/host/shield.lua")
			{
				RequireTokens(source, "function HostShield:SetEnableable(value, skipRecharge)", "function HostShield:RechargeThread()", "self:SetHealth(0)");
			}
			break;
		case 32:
			if (relativePath == "LJ/lua/common/systems/import.lua")
			{
				RequireTokens(source, "function ScanDir", "Engine.GetFoldersInsideDirectory");
			}
			break;
		}
	}

	private static void ValidateStockUnit(string source, string targetId, string ownerClass, string unitClass)
	{
		RequireTokens(source, "UnitTemplate =", "tpId = \"" + targetId + "\"", "\"" + ownerClass + "\"", "\"" + unitClass + "\"");
		RequireExactly(source, "tpId = \"" + targetId + "\"", 1, targetId + " stock tpId");
		string pattern = "class\\s*=\\s*\\{\\s*\"" + Regex.Escape(ownerClass) + "\"\\s*,\\s*\"" + Regex.Escape(unitClass) + "\"\\s*,?\\s*\\}";
		if (!Regex.IsMatch(source, pattern, RegexOptions.CultureInvariant))
		{
			throw new InvalidOperationException(targetId + " no longer exposes its reviewed Sanctuary class table.");
		}
	}

	private static void ValidateTitan(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", 1, "Titan role marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "mapping = \"UEL0303 -> uel3001\"", "sourceBlueprintSha256 = \"327d13c35da244c4beccda90e697cbd3f5220d9ad7fbafd04c342fa79a372d5a\"", "sourceScriptSha256 = \"102f17046627fcb9806c11dad0c0e286718f86362bc126cb101d527decd4d761\"", "UnitTemplate.general.name = \"Titan\"", "collisionSize = { x = 0.9, y = 1.2, z = 0.9 }", "max = 1200, regen = 0, value = 1200", "cost = { alloys = 480, energy = 5400 }", "maintenanceConsumption = { energy = 25 }", "UnitTemplate.intel = { visionRadius = 22 }", "type = \"LegsLand\"", "rotationSpeed = 150", "speed = 4", "authoredSpeed = 0.8", "sourceAmbientMoveCue = \"UEL0303_Move_Loop\"", "sanctuaryWalkerDonorTemplateSha256 = \"189c307051af4423f0ace168694b2a7f0087cb4e07e90943055af3031143a178\"", "UnitTemplate.audio.engine = { looping = true, name = \"aelu1335\" }", "clipName = \"AnimDeath01\"", "clipName = \"AnimDeath02\"", "clipName = \"AnimFold\"", "clipName = \"AnimWalk\"", "type = \"Personal\"", "sourceStartsOffField = true", "sourceStartsOffFieldRuntimeInert = true", "sourceInitialEnableRule = \"Shield.StartOn ~= false\"", "sourceEffectiveInitialEnabled = true", "collisionOffset = { x = 0, y = 0, z = 0 }", "scoManualRechargeTime = 5", "aimBone = \"Muzzle_R\"", "aimBone = \"Muzzle_L\"", "pitchMin = -80, pitchMax = 100", "projectileTemplate = \"per303\"", "projectileLifetime = 0.7666666666666667", "reloadTime = 0.3333333333333333", "scoFaWaterGate = \"Above\"");
		RequireExactly(source2, "{ muzzles = { \"Muzzle_R\" } }", 1, "Titan right rack");
		RequireExactly(source2, "{ muzzles = { \"Muzzle_L\" } }", 1, "Titan left rack");
		RequireExactly(source2, "aimControllers = {", 1, "Titan aim-controller table");
		RequireExactly(source2, "aimBone = ", 3, "Titan aim-controller count");
		RequireExactly(source2, "aimBone = \"Torso\"", 1, "Titan shared yaw controller");
		RequireExactly(source2, "yawBone = \"Torso\"", 1, "Titan torso yaw ownership");
		RequireExactly(source2, "pitchBone = ", 2, "Titan pitch-controller count");
		RequireExactly(source2, "pitchBone = \"ArmR_B04\"", 1, "Titan right pitch ownership");
		RequireExactly(source2, "pitchBone = \"ArmL_B04\"", 1, "Titan left pitch ownership");
		RequireExactly(source2, "defaultYawAdjustment = 0", 1, "Titan yaw-only default");
		RequireExactly(source2, "defaultPitchAdjustment = 10", 2, "Titan pitch-only defaults");
		RequireTokens(source2, "sourceDisplayUniformScale = 0.7", "sourceBodyCollisionUsesBlueprintSize = true", "sourceClass = \"UnitShield\"", "sourceOwnerShieldMesh = \"/units/uel0303/UEL0303_PersonalShield_mesh\"", "sourceImpactEffects = \"UEFShieldHit01\"", "sourceCreationRuntime = \"lua/sim/Unit.lua\"", "sourceCreationRuntimeSha256 = \"ced522e17b204aedfe196706fd3f3421af5f041cf692248ef56d43c97b52cd67\"", "sourceSize = 2.5", "sourceSizeSemantics = \"diameter\"", "sanctuaryCompatibilityVisualRadius = 1.25", "radii = { x = 1.25, y = 1.25, z = 1.25 }", "sourceColliderFormula = \"SizeX/Y/Z * 0.75 at CollisionOffsetX/Y/Z\"", "sourceColliderBlueprintScale = 0.75", "sourceColliderSize = { x = 0.675, y = 0.9, z = 0.675 }", "sourceColliderOffset = { x = 0, y = 0, z = 0 }", "sourcePassOverkillDamage = true", "sourceDamageRechargeRestoresFullHealth = true", "rechargeHPRatio = 1", "collisionSize = { x = 0.675, y = 0.9, z = 0.675 }", "collisionOffset = { x = 0, y = 0, z = 0 }", "scoEnergyDrainRechargeTime = 5", "scoDamageRechargeTime = 60", "sourceLabel = \"HeavyPlasma01\"", "rateOfFire = 3", "rackCount = 2", "rackFireTogether = false", "projectilesPerOnFire = 1", "shotsPerSecond = 3", "totalDps = 150", "presentationSourceUnit = \"UEL0001\"", "presentationSourceUnitBlueprintSha256 = \"d23dfe5cd085a5d248dc0544bebbf9432316b16905ada26fe88a5280591dd406\"", "presentationSourceUnitScriptSha256 = \"b3118531641de2ddc4c30a1dd461913f83d6b13778cfb041d47a20c6b80f2169\"", "presentationSourceProjectile = \"LaserBotTerran01\"", "currentCanonicalCommanderProjectile = \"pcd121\"", "dedicatedSanctuaryProjectile = \"per303\"", "authoredPresentationScale = 0.65", "compatibilityPresentation = true", "exactFaVisualAssetPort = false");
		RequireTokens(source2, "sanctuaryInitialToggleOwner = \"stock HostUnit:OnStopBeingBuilt\"", "UnitTemplate.general.toggles = { Shield = true }");
		RequireExactly(source2, "damage = 50,", 2, "Titan source and runtime per-shot damage");
		RequireExactly(source2, "muzzleSalvoSize = 1,", 2, "Titan source and runtime salvo size");
		RequireExactly(source2, "reloadTime = 0.3333333333333333,", 1, "Titan three-shot-per-second cadence");
		RequireExactly(source2, "projectileTemplate = \"per303\"", 1, "Titan isolated projectile");
		RequireNotContains(source2, "Kodiak", "ped311", "AeonProjectiles", "pad002", "pcl001");
		ValidateStockUnit(source, "uel3001", "unitsDefaultEDA", "EDALandUnit");
	}

	private static void ValidateWagner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", 1, "Wagner role marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "mapping = \"URL0203 -> ugl2002\"", "sourceBlueprintSha256 = \"c07db55c26720367272bc1b32b444a572632cbd9a21b772c1e43c06dcb4345ae\"", "sourceScriptSha256 = \"135df7d571db9b4812e497404a21c7d22002bc0620efdbe65420766c10c1b1cd\"", "UnitTemplate.general.name = \"Wagner\"", "collisionSize = { x = 0.9, y = 0.45, z = 1.1 }", "max = 1450, regen = 0, value = 1450", "cost = { alloys = 297, energy = 1980 }", "UnitTemplate.intel = { visionRadius = 15 }", "type = \"TracksSeabed\"", "rotationSpeed = 90", "speed = 3.7", "UnitTemplate.visuals.animations = nil", "projectileTemplate = \"pgr203r\"", "projectileTemplate = \"pgr203b\"", "projectileTemplate = \"pgr203t\"", "muzzleGroups = { { muzzles = { \"Turret03_Muzzle\", \"Turret03_Muzzle\" } } }", "muzzleSalvoDelay = 0.8, muzzleSalvoSize = 2", "layerWeaponLimits = { \"Seabed\" }", "scoFaWaterGate = \"Below\"");
		RequireExactly(source2, "projectileTemplate = \"pgr203", 3, "Wagner isolated projectile routes");
		RequireExactly(source2, "scoFaWaterGate = \"Above\"", 2, "Wagner above-water gates");
		RequireExactly(source2, "scoFaWaterGate = \"Below\"", 1, "Wagner below-water gate");
		RequireNotContains(source2, "Torque", "pgd111", "AeonProjectiles", "pad002", "pcl001");
		ValidateStockUnit(source, "ugl2002", "unitsDefaultGuard", "GuardLandUnit");
	}

	private static void ValidateEdaHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", 1, "Titan host marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "local SCO_FaRoleStockEdaDeathThread = HostEDALandUnit.DeathThread", "function HostEDALandUnit:DeathThread(overkillRatio)", "if self.tpId ~= \"uel3001\" then", "Engine.PlayAnimation(self.id, death.id, 0.1)", "WaitSeconds(useFirst and 3.4 or 1.9)", "return SCO_FaRoleStockEdaDeathThread(self, overkillRatio)");
		RequireNotContains(source2, "function HostEDALandUnit:OnStopBeingBuilt()", "self.toggles.Shield = false", "self:CheckShieldState(false)", "SetUnitToggleCommand.HostSend(");
	}

	private static void ValidateGuardHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", 1, "Wagner host marker");
		RequireTokens(OwnedAppendix(source), "local SCO_FaRoleLayers = Import(\"common/layers.lua\")", "local SCO_FaRoleStockGuardUpdateAnimations = HostGuardLandUnit.UpdateAnimations", "function HostGuardLandUnit:UpdateAnimations()", "if self.tpId == \"ugl2002\" and not self.dead then", "Engine.SampleTerrainHeight(position)", "SCO_FaRoleLayers.TargetingLayer.Seabed", "self:SetTargetingLayer(targetLayer)", "return SCO_FaRoleStockGuardUpdateAnimations(self)");
	}

	private static void ValidateHostWeapon(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", 1, "role water-gate marker");
		RequireTokens(OwnedAppendix(source), "local SCO_FaRoleStockCanShootAt = HostWeapon.CanShootAt", "function HostWeapon:CanShootAt(targetUnit)", "if not SCO_FaRoleStockCanShootAt(self, targetUnit) then", "local gate = self.tp and self.tp.scoFaWaterGate", "Engine.HasWater()", "Engine.GetWaterLevel()", "return ownerPosition.y >= waterLevel - margin", "return ownerPosition.y < waterLevel - margin");
	}

	private static void ValidateHostShield(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", 1, "Titan shield marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "local SCO_FaRoleStockShieldSetEnableable = HostShield.SetEnableable", "local SCO_FaRoleStockShieldTakeDamage = HostShield.TakeDamage", "local SCO_FaRoleStockShieldRechargeThread = HostShield.RechargeThread", "local function SCO_FaTitanShieldContract(shield)", "shield.owner.tpId == \"uel3001\"", "shield.tp.scoFaTitanPersonalShield == true", "local function SCO_FaTitanEnergySatisfaction(shield)", "economy.resources", "energy.satisfaction or 0", "function HostShield:TakeDamage(damage)", "damage >= self:GetHealth()", "self.scoFaTitanRechargeKind = \"Damage\"", "function HostShield:RechargeThread()", "self.scoFaTitanRechargeKind or \"Energy\"", "self.tp.scoDamageRechargeTime", "self.tp.scoEnergyDrainRechargeTime", "rechargeSeconds * Constants.TickRate", "progress + SCO_FaTitanEnergySatisfaction(self)", "restoredHealth = rechargeKind == \"Damage\"", "and maximum", "self:SetHealth(restoredHealth)", "function HostShield:SetEnableable(value, skipRecharge)", "return SCO_FaRoleStockShieldSetEnableable(self, value, skipRecharge)", "self.scoFaTitanRechargeKind or \"Energy\"", "self.scoFaTitanOffHealth = math.min(", "self:SetEnabled(false)", "self:SetRegenEnabled(false)");
		RequireExactly(source2, "function HostShield:TakeDamage(damage)", 1, "Titan damage-pop classifier");
		RequireExactly(source2, "function HostShield:RechargeThread()", 1, "Titan supply-adjusted recharge owner");
		RequireExactly(source2, "function HostShield:SetEnableable(value, skipRecharge)", 1, "Titan enableable lifecycle owner");
		RequireNotContains(source2, "self:SetHealth(0)");
		RequireNotContains(source2, "self:GetHealth() <= 0", "WaitSeconds(self.tp.scoManualRechargeTime)");
	}

	private static void ValidateUnitTemplateLoader(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", 1, "personal-shield loader marker");
		RequireExactly(source, "(shield.scoFaTitanPersonalShield == true and not shield.scoFaTitanSphereCollider and shield.collisionSize) or shield.radii", 2, "Titan shield collider extents");
		RequireExactly(source, "(shield.scoFaTitanPersonalShield == true and not shield.scoFaTitanSphereCollider and shield.collisionOffset) or EngineClasses.float3(0, 0, 0)", 2, "Titan shield collider offsets");
		RequireExactly(source, "(shield.scoFaTitanPersonalShield == true and not shield.scoFaTitanSphereCollider and ColliderType.Box) or ColliderType.Sphere", 2, "Titan shield collider types");
		RequireTokens(source, "ShieldTemplateLoader.CreateShieldEntity", "CreateUnitPrefab(tp)");
	}

	private static void ValidateImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", 1, "role scanner marker");
		RequireTokens(OwnedAppendix(source), "local SCO_FaRoleScanDir = ScanDir", "local folders = SCO_FaRoleScanDir(directory)", "directory .. \"per303\"", "directory .. \"pgr203r\"", "directory .. \"pgr203b\"", "directory .. \"pgr203t\"", "table.insert(folders, roleFolder)");
	}

	private static void ValidateVirtualProjectile(string source, ProjectileSpec projectile)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", 1, projectile.Id + " projectile marker");
		RequireTokens(source, "ProjectileTemplate =", "tpId = \"" + projectile.Id + "\"", "name = \"" + projectile.Name + "\"", "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12", projectile.SourceId, projectile.SourceBlueprintPath, projectile.SourceBlueprintSha256, projectile.SourceScriptPath, projectile.SourceScriptSha256, projectile.ImpactVfx, projectile.TrailVfx);
		if (projectile.Id == "per303")
		{
			RequireTokens(source, "tpId = \"per303\"", "nonUniformScale = { x = 0.65, y = 0.65, z = 0.65 }", "boneName = \"SCO_Titan_Commander_Projectile_Visual\"", "Presentation source unit: UEL0001 (RightZephyr)", "d23dfe5cd085a5d248dc0544bebbf9432316b16905ada26fe88a5280591dd406", "b3118531641de2ddc4c30a1dd461913f83d6b13778cfb041d47a20c6b80f2169", "Presentation source projectile: LaserBotTerran01", "4a1d33796c7896993dbee6f3a309a4ff56fa0c97900b1e3f702aafcf363437fe", "e89c5430b392baf89703bf926ff71b862a1dd4d4b6126e06af4f031bd5f9bcac", "Current canonical UEF commander route: UEL0001 -> uel0000 -> pcd121", "252536ffba44544195bde3ebfba00063a134b429801098c537559b1f6380773a", "dedicated per303 child at uniform scale 0.65", "not a 1:1 Forged Alliance visual-asset port");
			RequireExactly(source, "boneName = \"SCO_Titan_Commander_Projectile_Visual\"", 1, "Titan presentation-child trail binding");
			RequireNotContains(source, "UEF_Titan_Heavy_Plasma", "vei1301_cannon_large_impact.sanvfx", "vet1301_cannon_large_trail.sanvfx");
		}
		if (projectile.PhysicsProfile == "Gravity")
		{
			RequireNotContains(source, "movement =");
		}
		else if (projectile.PhysicsProfile == "NoGravity")
		{
			RequireTokens(source, "movement = { gravityMultiplier = 0 }");
			RequireNotContains(source, "type = \"TargetEntity\"");
		}
		else
		{
			RequireTokens(source, "acceleration = 5", "rotationSpeed = 230", "speedMax = 18", "type = \"TargetEntity\"");
		}
		RequireNotContains(source, "AeonProjectiles", "pad002", "pcl001");
	}

	private static void QueueAppend(object cache, ICollection<CacheMutation> mutations, string relativePath, string description, string appendix, Action<string> validate)
	{
		appendix = TitanFaContract.ResolveAppendix(relativePath, appendix);
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		if (resourceText.IndexOf("-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", StringComparison.Ordinal) >= 0)
		{
			validate(resourceText);
			return;
		}
		ValidateStock(relativePath, resourceText);
		object obj = CreateNativeArray(cachedResource.Stock.GetType(), AppendOverride(resourceText, appendix));
		try
		{
			validate(GetResourceText(obj));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, description));
		}
		catch
		{
			TryDispose(obj, "uncommitted " + description);
			throw;
		}
	}

	private static void QueueTransform(object cache, ICollection<CacheMutation> mutations, string relativePath, string description, Func<string, string> transform, Action<string> validate)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		if (resourceText.IndexOf("-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", StringComparison.Ordinal) >= 0)
		{
			validate(resourceText);
			return;
		}
		string source = transform(resourceText);
		object obj = CreateNativeArray(cachedResource.Stock.GetType(), source);
		try
		{
			validate(GetResourceText(obj));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, added: false, description));
		}
		catch
		{
			TryDispose(obj, "uncommitted " + description);
			throw;
		}
	}

	private static void QueueVirtualProjectile(object cache, ICollection<CacheMutation> mutations, ProjectileSpec projectile)
	{
		string relativePath = ProjectilePath(projectile.Id);
		string text = projectile.SourceId + " isolated projectile";
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath, text);
		if (cacheResource != null)
		{
			string resourceText = GetResourceText(cacheResource.Stock);
			if (resourceText.IndexOf("-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Reserved role projectile ID " + projectile.Id + " already exists without this module's marker.");
			}
			ValidateVirtualProjectile(resourceText, projectile);
			return;
		}
		string source = BuildVirtualProjectile(projectile);
		ValidateVirtualProjectile(source, projectile);
		object obj = CreateNativeArray(GetNativeArrayType(cache), source);
		try
		{
			ValidateVirtualProjectile(GetResourceText(obj), projectile);
			mutations.Add(new CacheMutation(ResolvePath(relativePath), null, obj, added: true, text));
		}
		catch
		{
			TryDispose(obj, "uncommitted " + text);
			throw;
		}
	}

	private static void Commit(object cache, IEnumerable<CacheMutation> mutations)
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
				TryDispose(mutation2.Stock, "stock " + mutation2.Description);
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
				TryDispose(item.Replacement, "replacement " + item.Description);
			}
		}
	}

	private static void DisposeUncommitted(IEnumerable<CacheMutation> mutations)
	{
		foreach (CacheMutation mutation in mutations)
		{
			TryDispose(mutation.Replacement, "uncommitted " + mutation.Description);
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
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
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
			EnsureCreated(obj3, description);
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
				EnsureCreated(obj4, description);
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
				EnsureCreated(obj, "Lua cache resource");
				return obj.GetType();
			}
		}
		throw new InvalidOperationException("Sanctuary's Lua file cache contains no NativeArray resource type.");
	}

	private static string ResolvePath(string relativePath)
	{
		return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
	}

	private static object CreateNativeArray(Type type, string source)
	{
		return NativeArrayByteFactory.CreatePersistent(type, Encoding.UTF8.GetBytes(source));
	}

	private static string GetResourceText(object resource)
	{
		EnsureCreated(resource, "Lua cache resource");
		MethodInfo methodInfo = resource.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray");
		return Encoding.UTF8.GetString((byte[])methodInfo.Invoke(resource, null));
	}

	private static void EnsureCreated(object resource, string description)
	{
		object value = (resource.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource);
		if (!(value is bool) || !(bool)value)
		{
			throw new InvalidOperationException("Cached " + description + " is not an initialized NativeArray.");
		}
	}

	private static void SetCachedResource(object cache, string path, object resource)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, resource, new object[1] { path });
	}

	private static void RemoveCachedResource(object cache, string path)
	{
		(cache.GetType().GetMethod("Remove", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(cache.GetType().FullName, "Remove")).Invoke(cache, new object[1] { path });
	}

	private static void TryDispose(object resource, string description)
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
		return NormalizeNewlines(source).TrimEnd(new char[1] { '\n' }) + "\n" + NormalizeNewlines(appendix).TrimStart(new char[1] { '\n' }) + "\n";
	}

	private static string NormalizeNewlines(string source)
	{
		return source.Replace("\r\n", "\n").Replace('\r', '\n');
	}

	private static string ProjectilePath(string id)
	{
		return "LJ/lua/common/projectiles/projectilesTemplates/" + id + "/" + id + ".santp";
	}

	private static string OwnedAppendix(string source)
	{
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Land-role marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0".Length, StringComparison.Ordinal);
		if (num2 >= 0)
		{
			return source.Substring(num, num2 - num);
		}
		return source.Substring(num);
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
				throw new InvalidOperationException("Land-role-owned Lua must not contain '" + text + "'.");
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
		string text = "[FA Land Role Replacements Cache Patcher] " + message;
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
