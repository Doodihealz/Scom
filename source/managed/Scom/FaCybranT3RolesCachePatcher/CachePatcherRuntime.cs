using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using SupremeCommanderOverhaul.Shared;

namespace FaCybranT3RolesCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class ProjectileSpec
	{
		public string Id { get; }

		public string Name { get; }

		public string SourceId { get; }

		public string BlueprintPath { get; }

		public string BlueprintSha256 { get; }

		public string ScriptPath { get; }

		public string ScriptSha256 { get; }

		public string PhysicsProfile { get; }

		public string Scale { get; }

		public string ImpactVfx { get; }

		public string TrailVfx { get; }

		public ProjectileSpec(string id, string name, string sourceId, string blueprintPath, string blueprintSha256, string scriptPath, string scriptSha256, string physicsProfile, string scale, string impactVfx, string trailVfx)
		{
			Id = id;
			Name = name;
			SourceId = sourceId;
			BlueprintPath = blueprintPath;
			BlueprintSha256 = blueprintSha256;
			ScriptPath = scriptPath;
			ScriptSha256 = scriptSha256;
			PhysicsProfile = physicsProfile;
			Scale = scale;
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

	internal const string OverrideMarker = "-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0";

	internal const string SourceArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	internal const string ProjectileArchiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12";

	private const string BrickUnitPath = "LJ/lua/common/units/unitsTemplates/ugl3001/ugl3001.santp";

	private const string LoyalistUnitPath = "LJ/lua/common/units/unitsTemplates/ugl3002/ugl3002.santp";

	private const string GuardHostPath = "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua";

	private const string HostWeaponPath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private const string ImportPath = "LJ/lua/common/systems/import.lua";

	private const string ProjectileRoot = "LJ/lua/common/projectiles/projectilesTemplates";

	private static readonly ProjectileSpec[] Projectiles = new ProjectileSpec[4]
	{
		new ProjectileSpec("pgr305h", "Cybran_Brick_Heavy_Disintegrator", "CDFHeavyDisintegratorPulseLaser01", "projectiles/CDFHeavyDisintegratorPulseLaser01/CDFHeavyDisintegratorPulseLaser01_proj.bp", "0e09b2070b5db8c5c788955fd03160bd412edfa5859698bb9217537da0fa6be5", "projectiles/CDFHeavyDisintegratorPulseLaser01/CDFHeavyDisintegratorPulseLaser01_script.lua", "7f9e35d410923aa832bec62bee46e37b7abafc70cdedad52dad8646b3c31dccd", "NoGravity", "1", "VFX/Impact/vgi1141_cannon_artillery_small_impact.sanvfx", "VFX/Trails/vgt1141_cannon_artillery_small_trail.sanvfx"),
		new ProjectileSpec("pgr305t", "Cybran_Brick_Nanite_Torpedo", "CANTorpedoNanite01", "projectiles/CANTorpedoNanite01/CANTorpedoNanite01_proj.bp", "90ed85157713b241bcc0a73062dcbd998f8dc7765ecc4d830397ba8985cfba0f", "projectiles/CANTorpedoNanite01/CANTorpedoNanite01_script.lua", "c7c65750ec3af15cae005c29dddde03f43095700a98ab3285fc3bad9e26e7e9d", "HomingTorpedo", "0.65", "VFX/Impact/vgi1241_cannon_artillery_medium_impact.sanvfx", "VFX/Trails/vgt1241_cannon_artillery_medium_trail.sanvfx"),
		new ProjectileSpec("pgr303d", "Cybran_Loyalist_Disintegrator", "CDFLaserDisintegrator02", "projectiles/CDFLaserDisintegrator02/CDFLaserDisintegrator02_proj.bp", "67f49f2d714889a4a98af6bb6bac6a239ab9886f83801568f8bba4ff18702ed9", "projectiles/CDFLaserDisintegrator02/CDFLaserDisintegrator02_script.lua", "6dfe124794f944872bb8588d4fd3a0690d2ac2fbf8d76d34fbf40a72ae138bc4", "Gravity", "0.7", "VFX/Impact/vgi1101_cannon_small_impact.sanvfx", "VFX/Trails/vgt1101_cannon_small_trail.sanvfx"),
		new ProjectileSpec("pgr303b", "Cybran_Loyalist_Heavy_Bolter", "CDFBolter02", "projectiles/CDFBolter02/CDFBolter02_proj.bp", "f29bbeda9a1d139e330d3cf4d30d7a9cffb80b321e77a2bb86eda7b9471b8091", "projectiles/CDFBolter02/CDFBolter02_script.lua", "cf4b9bd0b40cdf37e10bcb77fdf12844676a503be8cdaff5f29be4226129b288", "Gravity", "0.6", "VFX/Impact/vgi1101_cannon_small_impact.sanvfx", "VFX/Trails/vgt1101_cannon_small_trail.sanvfx")
	};

	private const string BrickUnitAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0\n-- Explicit same-faction role substitution: FA XRL0305 The Brick\n-- replaces Sanctuary's ugl3001 Auger and retains GuardLandUnit.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"XRL0305 -> ugl3001\",\n    substitution = true,\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/XRL0305/XRL0305_unit.bp\",\n    sourceBlueprintSha256 = \"bfcaa9f4cd50e24bfffc87325283075206bb8ad3a1e7507e1d02ab8bd7ca406d\",\n    sourceScript = \"units/XRL0305/XRL0305_Script.lua\",\n    sourceScriptSha256 = \"c14840f975d04290da855b13d409f0c60d9a8c5082463707056bb38ed32f516e\",\n    class = { owner = \"unitsDefaultGuard\", name = \"GuardLandUnit\" },\n    collision = { size = { x = 0.9, y = 1.6, z = 0.9 }, offset = { x = 0, y = 0, z = 0 } },\n    selection = { x = 0.9, z = 0.9, centerX = 0, centerZ = 0, thickness = 0.47 },\n    defence = { health = 9000, regen = 0 },\n    economy = { buildCostEnergy = 14000, buildCostMass = 1280, buildTime = 4800 },\n    intel = { visionRadius = 26, sourceWaterVisionRadius = 26 },\n    movement = {\n        sourceMotionType = \"RULEUMT_Amphibious\",\n        acceleration = 2, brake = 2, speed = 2,\n        sourceMaxReverseSpeed = 2.5, sourceBackupDistance = 5,\n        steerForce = 10, turnRadius = 2, turnRate = 60,\n        sourceAnimationWalkRate = 8, sanctuaryAuthoredSpeed = 0.25,\n        sourceLayerChangeOffsetHeight = -0.9,\n    },\n    sanctuaryMovementValidator = {\n        source = \"LJ/lua/AI/UnitBlueprintValidator.lua\",\n        sourceSha256 = \"8e93684c5d04b26498a26142bcb4bfbd9eae000222bb53d257f67dae1a5fa2ba\",\n        requiredTags = { \"LAND\", \"SEABED\" },\n        stockTargetSha256 = \"6fe426d3d46f76dc7f58e11256324b6ccf3d4efb72bdddf281a348a1e71faa57\",\n        stockCollisionMaskDefault = { \"SeabedSmall\" },\n        stockCollisionMaskSpawn = { \"SeabedSmall\" },\n    },\n    animations = {\n        death01 = { sha256 = \"6121291deebeb93bc2c46fe5c23ff9609444c9bff2c24f6f0de69fcb8410af30\", frames = 71, duration = 2.3333332538604736, weight = 1 },\n        death02 = { sha256 = \"41264f7f44c425c68762e3fbe5556d86aaea36d1a1e0e230108061a0d172e814\", frames = 71, duration = 2.3333332538604736, weight = 1 },\n        death03 = { sha256 = \"ec70b1ada6481dc5e34e6f54487ce41b9adb89f9e2a4bf1df5ffe71dfb3f4a0d\", frames = 71, duration = 2.3333332538604736, weight = 1 },\n        walk = { sha256 = \"36d9dfaac3f6dac195e3255ff9ffdf574191de7c3c6d203082fd43b461a149fd\", frames = 161, duration = 5.333333492279053 },\n        omittedStaticNonRigTracks = { \"Turret_Barrel\", \"Turret_Muzzle\" },\n    },\n    heavyDisintegrator = {\n        sourceProjectile = \"CDFHeavyDisintegratorPulseLaser01\",\n        sourceProjectileSha256 = \"0e09b2070b5db8c5c788955fd03160bd412edfa5859698bb9217537da0fa6be5\",\n        sanctuaryProjectile = \"pgr305h\", damage = 150, range = 35,\n        rateOfFire = 2.5, muzzleVelocity = 35, ballisticArc = \"LowArc\",\n        aboveWaterFireOnly = true, aboveWaterTargetsOnly = true,\n    },\n    naniteTorpedo = {\n        sourceProjectile = \"CANTorpedoNanite01\",\n        sourceProjectileSha256 = \"90ed85157713b241bcc0a73062dcbd998f8dc7765ecc4d830397ba8985cfba0f\",\n        sanctuaryProjectile = \"pgr305t\", sourceDamage = 4,\n        sourceDoTPulses = 5, sourceDoTTime = 0.5,\n        sanctuaryCollapsedDamagePerProjectile = 20,\n        sourceProjectilesPerOnFire = 2, sourceMuzzleSalvoSize = 2,\n        sanctuaryProjectilesPerCycle = 4, range = 32,\n        rateOfFire = 0.25, muzzleVelocity = 5,\n    },\n    omittedAntiTorpedo = {\n        reason = \"Sanctuary HostWeapon has no projectile-target weapon API\",\n        targetType = \"RULEWTT_Projectile\", targetOnly = \"TORPEDO\",\n        sourceProjectile = \"CIMAntiTorpedo03\",\n        sourceProjectileSha256 = \"096f9ad1f981b1bc517e8dce0864ebc26a4afb8edccacd84c883bbab6709989d\",\n        sourceProjectileScriptSha256 = \"0bd5fc75bc282fe3d49011a0fa2c0f46170ebfa163eb51cdbe77f1682caf18e1\",\n    },\n    limitations = {\n        sourceDeathRateRandomization = \"0.75-1.25 unavailable; nominal rate used\",\n        sourceDeathWeightedRandom = \"deterministic unit-index thirds preserve equal weights\",\n        sourceMaxReverseSpeedRuntime = false,\n        sourceLayerChangeOffsetHeightRuntime = false,\n        sourceWaterVisionDistinctRuntime = false,\n        sourceGroundKickupEffects = false,\n        sourceAudioBanks = false,\n        sourceProjectileEmitterGraphs = false,\n        sourceHeavyDestroyOnWaterRuntime = false,\n        sourceTorpedoSubLayerMergedIntoWater = true,\n        sourceNaniteDoTTemporalPulsesCollapsed = true,\n        sourceAntiTorpedoProjectileTargeting = false,\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 3: Amphibious Assault Bot\"\nUnitTemplate.general.name = \"The Brick\"\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"direct\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 20\nUnitTemplate.general.iconUIType = \"amphibious\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = nil\nUnitTemplate.audio = nil\n\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.8, z = 0 },\n    collisionSize = { x = 0.9, y = 1.6, z = 0.9 },\n}\nUnitTemplate.footprint = { x = 0.9, y = 0.9 }\nUnitTemplate.defence = { health = { max = 9000, regen = 0, value = 9000 } }\nUnitTemplate.economy = {\n    buildTime = 4800,\n    cost = { alloys = 1280, energy = 14000 },\n}\nUnitTemplate.intel = { visionRadius = 26 }\nUnitTemplate.movement = {\n    acceleration = 2,\n    deceleration = 2,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"SeabedSmall\" },\n    collisionMaskSpawn = { \"SeabedSmall\" },\n    maxReverseDistance = 5,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotationSpeed = 60,\n    sortOrder = 1,\n    speed = 2,\n    terrainAlignmentFactor = 1,\n    type = \"LegsSeabed\",\n    walkAnimation = { authoredSpeed = 0.25 },\n}\nUnitTemplate.tags = {\n    \"ANTI_NAVY\", \"ANTI_SURFACE\", \"BOT\",\n    \"BUILDABLE_BY_T3_FACTORY\", \"DIRECT_FIRE\", \"GUARD\",\n    \"LAND\", \"MOBILE\", \"SEABED\", \"TECH3\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.9, y = 0.9 },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.visuals.animations = {\n    death01 = { clipName = \"AnimDeath01\", sanAnimationPath = \"Units/ugl3001/LOD0/ugl3001.sananimation\" },\n    death02 = { clipName = \"AnimDeath02\", sanAnimationPath = \"Units/ugl3001/LOD0/ugl3001.sananimation\" },\n    death03 = { clipName = \"AnimDeath03\", sanAnimationPath = \"Units/ugl3001/LOD0/ugl3001.sananimation\" },\n    walk = { authoredSpeed = 0.25, clipName = \"AnimWalk\", sanAnimationPath = \"Units/ugl3001/LOD0/ugl3001.sananimation\" },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nlocal function SCO_BrickAim(aimBone, yawBone, pitchBone, yawRange, yawSpeed, pitchRange, pitchSpeed, projectileSpeed, solverType, tolerance, lead)\n    return {\n        aimBone = aimBone, yawBone = yawBone, pitchBone = pitchBone,\n        aimTolerance = tolerance, defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0, leadTarget = lead,\n        pitchMin = -pitchRange, pitchMax = pitchRange, pitchSpeed = pitchSpeed,\n        poseResetTime = 3, projectileSpeed = projectileSpeed,\n        solverType = solverType,\n        yawMin = -yawRange, yawMax = yawRange, yawSpeed = yawSpeed,\n    }\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = { SCO_BrickAim(\"Projectile03\", \"Turret\", \"Projectile03\", 180, 60, 75, 60, 35, \"LowArc\", 1, true) },\n        collideFriendly = false, damage = 150, damageFriendly = false,\n        damageRadius = 0, damageType = \"Normal\", firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0, muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Projectile03\" } } },\n        muzzles = { Projectile03 = { aimController = \"Projectile03\" } },\n        muzzleSalvoDelay = 0, muzzleSalvoSize = 1,\n        projectileLifetime = 1.15, projectileTemplate = \"pgr305h\",\n        rangeMax = 35, rangeMin = 0, rangeRingType = \"DirectFire\",\n        rangeTracking = 1.1, reloadTime = 0.4,\n        targetWaterLimits = \"Above\",\n        scoFaCybranT3WaterGate = \"OwnerAndTargetAbove\",\n    },\n    {\n        -- Source is non-turreted. Projectile01 is an unskinned helper;\n        -- this adapter satisfies HostWeapon without moving mesh geometry.\n        aimControllers = { SCO_BrickAim(\"Projectile01\", \"Projectile01\", \"Projectile01\", 180, 360, 90, 360, 5, \"NoArc\", 2, false) },\n        collideFriendly = false, damage = 20, damageFriendly = false,\n        damageRadius = 0, damageType = \"Normal\", firingRandomness = 0,\n        layerTargetLimits = { \"Seabed\", \"Water\" },\n        layerWeaponLimits = { \"Seabed\" },\n        muzzleGroupChargeDelay = 0, muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Projectile01\", \"Projectile01\" } } },\n        muzzles = { Projectile01 = { aimController = \"Projectile01\" } },\n        muzzleSalvoDelay = 0.8, muzzleSalvoSize = 2,\n        projectileLifetime = 7, projectileTemplate = \"pgr305t\",\n        rangeMax = 32, rangeMin = 0, rangeRingType = \"DirectFire\",\n        rangeTracking = 1.1, reloadTime = 4,\n        targetWaterLimits = \"Below\",\n        scoFaCybranT3WaterGate = \"OwnerAndTargetBelow\",\n        scoFaSourceDoTPulsesCollapsed = true,\n    },\n}";

	private const string LoyalistUnitAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0\n-- Explicit same-faction role substitution: FA URL0303 Loyalist\n-- replaces Sanctuary's ugl3002 Nitro and retains GuardLandUnit.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URL0303 -> ugl3002\",\n    substitution = true,\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/URL0303/URL0303_unit.bp\",\n    sourceBlueprintSha256 = \"74d0b6c0f89c8d79f6041ed92034108c50b6851caf29892e4d58dbf0c1df3d91\",\n    sourceScript = \"units/URL0303/URL0303_Script.lua\",\n    sourceScriptSha256 = \"e057041a1def1f65f9cb88fc095f7899ba5f4453b451764908ea6b83a14c5dbd\",\n    class = { owner = \"unitsDefaultGuard\", name = \"GuardLandUnit\" },\n    collision = { size = { x = 0.9, y = 1.2, z = 0.9 }, offset = { x = 0, y = 0, z = 0 } },\n    selection = { x = 0.55, z = 0.5, centerX = 0, centerZ = -0.15, thickness = 0.7 },\n    defence = { health = 3100, regen = 0 },\n    economy = { buildCostEnergy = 5400, buildCostMass = 480, buildTime = 2400 },\n    intel = { visionRadius = 22 },\n    movement = {\n        sourceMotionType = \"RULEUMT_Land\", acceleration = 4,\n        brake = 4, speed = 4, reverseSpeed = 0,\n        steerForce = 10, turnRadius = 5, turnRate = 120,\n        sourceAnimationWalkRate = 4.5,\n        sanctuaryAuthoredSpeed = 0.8888888888888888,\n    },\n    animations = {\n        death01 = { sha256 = \"2b803b46eb61b896bdba38c8c317b84d9354849ca1f9a0277132ff781177497c\", frames = 31, duration = 1, weight = 1 },\n        death02 = { sha256 = \"f1e2f7e292b6ecd36d9bbce6426ea10eeda0db1c292456228f86ab3b170363c8\", frames = 31, duration = 1, weight = 1 },\n        fold = { sha256 = \"e0959f00e08e0fc220bb28a137399a22853fb63dcaf0613a2484c9b67f68c9ac\", frames = 61, duration = 2 },\n        walk = { sha256 = \"86b0565d75db5875b86a62c3f7733b3116e1b8e6b858c8a775e623fca7bbf85c\", frames = 33, duration = 3.200000047683716 },\n        omittedStaticNonRigTracks = { \"Turret_Center\", \"Barrel_Center01\", \"Barrel_Center02\" },\n    },\n    disintegrator = {\n        sourceProjectile = \"CDFLaserDisintegrator02\",\n        sourceProjectileSha256 = \"67f49f2d714889a4a98af6bb6bac6a239ab9886f83801568f8bba4ff18702ed9\",\n        sanctuaryProjectile = \"pgr303d\", damage = 175, range = 25,\n        rateOfFire = 0.3, muzzleVelocity = 30,\n        sourceMuzzleChargeDelay = 0.1, sourceMuzzleSalvoDelay = 0.3,\n        sourceMuzzleSalvoSize = 3, sourceProjectilesPerOnFire = 3,\n        sanctuaryProjectilesPerCycle = 9,\n    },\n    heavyBolter = {\n        sourceProjectile = \"CDFBolter02\",\n        sourceProjectileSha256 = \"f29bbeda9a1d139e330d3cf4d30d7a9cffb80b321e77a2bb86eda7b9471b8091\",\n        sanctuaryProjectile = \"pgr303b\", damage = 12, range = 25,\n        rateOfFire = 2.5, muzzleVelocity = 40,\n    },\n    deathEmp = {\n        sourceProjectile = \"CIFEMP01\",\n        sourceProjectileSha256 = \"6e49dd222e1fc3e2d86054276b392315313c738b3b3838f182013445f8ec014f\",\n        sourceProjectileScriptSha256 = \"9cffdd3f0309a0d06b48b187dad0fcf3caf43ddd080ae73270b15786cdfb75e3\",\n        sourceDamage = 1, radius = 10, damageFriendly = false,\n        sourceDamageType = \"EMP\", sourceStunDuration = 2,\n        sanctuaryDamageType = \"Normal\",\n    },\n    omittedMissileRedirect = {\n        reason = \"Sanctuary unit/shield APIs expose no tactical missile redirector\",\n        attachBone = \"Turret_Muzzle\", radius = 5, redirectRateOfFire = 1,\n    },\n    limitations = {\n        sourceDeathRateRandomization = \"0.75-1.25 unavailable; nominal rate used\",\n        sourceDeathWeightedRandom = \"deterministic unit-index halves preserve equal weights\",\n        transportFoldRuntime = false,\n        sourceGroundKickupEffects = false,\n        sourceAudioBanks = false,\n        sourceProjectileEmitterGraphs = false,\n        sourceProjectileDestroyOnWaterRuntime = false,\n        sourceTacticalMissileRedirect = false,\n        sourceEmpDamageTypeRuntime = false,\n        sourceStunStatusRuntime = false,\n        sourceDeathUnitCompleteGateRuntime = false,\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 3: Siege Assault Bot\"\nUnitTemplate.general.name = \"Loyalist\"\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"direct\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 20\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = nil\nUnitTemplate.audio = nil\n\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.6, z = 0 },\n    collisionSize = { x = 0.9, y = 1.2, z = 0.9 },\n}\nUnitTemplate.footprint = { x = 0.9, y = 0.9 }\nUnitTemplate.defence = { health = { max = 3100, regen = 0, value = 3100 } }\nUnitTemplate.economy = {\n    buildTime = 2400,\n    cost = { alloys = 480, energy = 5400 },\n}\nUnitTemplate.intel = { visionRadius = 22 }\nUnitTemplate.movement = {\n    acceleration = 4,\n    deceleration = 4,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"LandSmall\" },\n    collisionMaskSpawn = { \"LandSmall\" },\n    maxReverseDistance = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotationSpeed = 120,\n    sortOrder = 1,\n    speed = 4,\n    terrainAlignmentFactor = 1,\n    type = \"LegsLand\",\n    walkAnimation = { authoredSpeed = 0.8888888888888888 },\n}\nUnitTemplate.tags = {\n    \"ANTI_SURFACE\", \"BOT\", \"BUILDABLE_BY_T3_FACTORY\",\n    \"DIRECT_FIRE\", \"GUARD\", \"LAND\", \"MOBILE\", \"TECH3\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.55, y = 0.5 },\n    offset = { x = 0, y = 0, z = -0.15 },\n}\nUnitTemplate.visuals.animations = {\n    death01 = { clipName = \"AnimDeath01\", sanAnimationPath = \"Units/ugl3002/LOD0/ugl3002.sananimation\" },\n    death02 = { clipName = \"AnimDeath02\", sanAnimationPath = \"Units/ugl3002/LOD0/ugl3002.sananimation\" },\n    fold = { clipName = \"AnimFold\", sanAnimationPath = \"Units/ugl3002/LOD0/ugl3002.sananimation\" },\n    walk = { authoredSpeed = 0.8888888888888888, clipName = \"AnimWalk\", sanAnimationPath = \"Units/ugl3002/LOD0/ugl3002.sananimation\" },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nlocal function SCO_LoyalistAim(aimBone, yawBone, pitchBone, yawRange, yawSpeed, pitchRange, pitchSpeed, projectileSpeed)\n    return {\n        aimBone = aimBone, yawBone = yawBone, pitchBone = pitchBone,\n        aimTolerance = 2, defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0, leadTarget = true,\n        pitchMin = -pitchRange, pitchMax = pitchRange, pitchSpeed = pitchSpeed,\n        poseResetTime = 3, projectileSpeed = projectileSpeed,\n        solverType = \"LowArc\",\n        yawMin = -yawRange, yawMax = yawRange, yawSpeed = yawSpeed,\n    }\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = { SCO_LoyalistAim(\"Muzzle_Left\", \"Torso\", \"Barrel_L\", 180, 180, 45, 60, 30) },\n        collideFriendly = false, damage = 175, damageFriendly = false,\n        damageRadius = 0, damageType = \"Normal\", firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" }, layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0.1, muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Muzzle_Left\", \"Muzzle_Left\", \"Muzzle_Left\" } } },\n        muzzles = { Muzzle_Left = { aimController = \"Muzzle_Left\" } },\n        muzzleSalvoDelay = 0.3, muzzleSalvoSize = 3,\n        projectileLifetime = 0.9583333333333334, projectileTemplate = \"pgr303d\",\n        rangeMax = 25, rangeMin = 0, rangeRingType = \"DirectFire\",\n        rangeTracking = 1.15, reloadTime = 3.3333333333333335,\n        targetWaterLimits = \"Above\", scoFaCybranT3WaterGate = \"TargetAbove\",\n    },\n    {\n        aimControllers = { SCO_LoyalistAim(\"Muzzle_Right\", \"Barrel_R\", \"Barrel_R\", 35, 90, 45, 90, 40) },\n        collideFriendly = false, damage = 12, damageFriendly = false,\n        damageRadius = 0, damageType = \"Normal\", firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" }, layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0, muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Muzzle_Right\" } } },\n        muzzles = { Muzzle_Right = { aimController = \"Muzzle_Right\" } },\n        muzzleSalvoDelay = 0, muzzleSalvoSize = 1,\n        projectileLifetime = 0.71875, projectileTemplate = \"pgr303b\",\n        rangeMax = 25, rangeMin = 0, rangeRingType = \"DirectFire\",\n        rangeTracking = 1.15, reloadTime = 0.4,\n        targetWaterLimits = \"Above\", scoFaCybranT3WaterGate = \"TargetAbove\",\n    },\n    {\n        category = \"DeathExplosion\",\n        damage = 1,\n        damageRadius = 10,\n        damageFriendly = false,\n        damageType = \"Normal\",\n        scoFaSourceDamageType = \"EMP\",\n        scoFaSourceStunDuration = 2,\n    },\n}";

	private const string GuardHostAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0\nlocal SCO_FaCybranT3Layers = Import(\"common/layers.lua\")\nlocal SCO_FaCybranT3StockUpdateAnimations = HostGuardLandUnit.UpdateAnimations\nfunction HostGuardLandUnit:UpdateAnimations()\n    if self.tpId == \"ugl3001\" and not self.dead then\n        local targetLayer = SCO_FaCybranT3Layers.TargetingLayer.Land\n        local waterResult, hasWater = Engine.HasWater()\n        if waterResult == EngineErrorCode.Success and hasWater then\n            local levelResult, waterLevel = Engine.GetWaterLevel()\n            local position = self:GetPosition()\n            if levelResult == EngineErrorCode.Success and waterLevel ~= nil and position ~= nil then\n                local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)\n                if terrainResult == EngineErrorCode.Success\n                    and terrainHeight < waterLevel - 0.05\n                    and position.y < waterLevel - 0.05\n                then\n                    targetLayer = SCO_FaCybranT3Layers.TargetingLayer.Seabed\n                end\n            end\n        end\n        if self.targetingLayer ~= targetLayer then self:SetTargetingLayer(targetLayer) end\n    end\n    return SCO_FaCybranT3StockUpdateAnimations(self)\nend\n\n-- HostUnit:Destroy calls OnDestroy before it starts DeathThread.\n-- Hash-pinned unitsBaseClass.lua SHA-256\n-- 45ec82463ae6a39460eb661700fe20105fc068b8bab07592326ae712d003b5be\n-- sets self.dead, deletes\n-- every weapon and targetCollider there. Clear the remaining movement\n-- collision mask before preserving the visible source death delay.\nlocal SCO_FaCybranT3StockDeathThread = HostGuardLandUnit.DeathThread\nfunction HostGuardLandUnit:DeathThread(overkillRatio)\n    if self.tpId ~= \"ugl3001\" and self.tpId ~= \"ugl3002\" then\n        return SCO_FaCybranT3StockDeathThread(self, overkillRatio)\n    end\n    if not self.dead then\n        error(\"Cybran T3 source death animation must run after HostUnit:OnDestroy\")\n    end\n    Engine.SetMovementCollisionMask(self.id, 0)\n    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations\n    local index = (self.id and self.id.index) or 0\n    local death = nil\n    local duration = 0\n    if self.tpId == \"ugl3001\" then\n        local bucket = index % 3\n        death = animations and (bucket == 0 and animations.death01\n            or bucket == 1 and animations.death02 or animations.death03)\n        duration = 2.3333332538604736\n    else\n        death = animations and (index % 2 == 0 and animations.death01 or animations.death02)\n        duration = 1\n    end\n    if not death or not death.id then error(\"Cybran T3 role unit requires every hash-pinned source death clip\") end\n    Engine.PlayAnimation(self.id, death.id, 0.1)\n    WaitSeconds(duration)\n    return SCO_FaCybranT3StockDeathThread(self, overkillRatio)\nend";

	private const string HostWeaponAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0\n-- Physically enforce donor water gates after every earlier wrapper.\nlocal SCO_FaCybranT3StockCanShootAt = HostWeapon.CanShootAt\nfunction HostWeapon:CanShootAt(targetUnit)\n    if not SCO_FaCybranT3StockCanShootAt(self, targetUnit) then return false end\n    local unitId = self.unit and self.unit.tpId\n    if unitId ~= \"ugl3001\" and unitId ~= \"ugl3002\" then return true end\n    local gate = self.tp and self.tp.scoFaCybranT3WaterGate\n    if gate == nil then return true end\n\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return gate ~= \"OwnerAndTargetBelow\" end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return false end\n    local targetPosition = targetUnit and targetUnit:GetPosition()\n    if targetPosition == nil then return false end\n    local targetAbove = targetPosition.y >= waterLevel - 0.05\n    if gate == \"TargetAbove\" then return targetAbove end\n    local ownerPosition = self.unit:GetPosition()\n    if ownerPosition == nil then return false end\n    local ownerAbove = ownerPosition.y >= waterLevel - 0.05\n    if gate == \"OwnerAndTargetAbove\" then return ownerAbove and targetAbove end\n    if gate == \"OwnerAndTargetBelow\" then return not ownerAbove and not targetAbove end\n    return false\nend";

	private const string ImportScannerAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0\n-- These four isolated projectile templates exist only in FilesCache.\nlocal SCO_FaCybranT3ScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_FaCybranT3ScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then return folders end\n    local owned = {\n        directory .. \"pgr305h\", directory .. \"pgr305t\",\n        directory .. \"pgr303d\", directory .. \"pgr303b\",\n    }\n    for _, candidate in ipairs(owned) do\n        local found = false\n        for _, folder in ipairs(folders) do\n            if folder == candidate then found = true break end\n        end\n        if not found then table.insert(folders, candidate) end\n    end\n    return folders\nend";

	public static void Apply()
	{
		ValidatePinnedScope();
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>(9);
		try
		{
			obj = GetLuaFileCache();
			ValidateTransactionState(obj);
			QueueAppend(obj, list, "LJ/lua/common/units/unitsTemplates/ugl3001/ugl3001.santp", "UGL3001 Brick template", "\n\n-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0\n-- Explicit same-faction role substitution: FA XRL0305 The Brick\n-- replaces Sanctuary's ugl3001 Auger and retains GuardLandUnit.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"XRL0305 -> ugl3001\",\n    substitution = true,\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/XRL0305/XRL0305_unit.bp\",\n    sourceBlueprintSha256 = \"bfcaa9f4cd50e24bfffc87325283075206bb8ad3a1e7507e1d02ab8bd7ca406d\",\n    sourceScript = \"units/XRL0305/XRL0305_Script.lua\",\n    sourceScriptSha256 = \"c14840f975d04290da855b13d409f0c60d9a8c5082463707056bb38ed32f516e\",\n    class = { owner = \"unitsDefaultGuard\", name = \"GuardLandUnit\" },\n    collision = { size = { x = 0.9, y = 1.6, z = 0.9 }, offset = { x = 0, y = 0, z = 0 } },\n    selection = { x = 0.9, z = 0.9, centerX = 0, centerZ = 0, thickness = 0.47 },\n    defence = { health = 9000, regen = 0 },\n    economy = { buildCostEnergy = 14000, buildCostMass = 1280, buildTime = 4800 },\n    intel = { visionRadius = 26, sourceWaterVisionRadius = 26 },\n    movement = {\n        sourceMotionType = \"RULEUMT_Amphibious\",\n        acceleration = 2, brake = 2, speed = 2,\n        sourceMaxReverseSpeed = 2.5, sourceBackupDistance = 5,\n        steerForce = 10, turnRadius = 2, turnRate = 60,\n        sourceAnimationWalkRate = 8, sanctuaryAuthoredSpeed = 0.25,\n        sourceLayerChangeOffsetHeight = -0.9,\n    },\n    sanctuaryMovementValidator = {\n        source = \"LJ/lua/AI/UnitBlueprintValidator.lua\",\n        sourceSha256 = \"8e93684c5d04b26498a26142bcb4bfbd9eae000222bb53d257f67dae1a5fa2ba\",\n        requiredTags = { \"LAND\", \"SEABED\" },\n        stockTargetSha256 = \"6fe426d3d46f76dc7f58e11256324b6ccf3d4efb72bdddf281a348a1e71faa57\",\n        stockCollisionMaskDefault = { \"SeabedSmall\" },\n        stockCollisionMaskSpawn = { \"SeabedSmall\" },\n    },\n    animations = {\n        death01 = { sha256 = \"6121291deebeb93bc2c46fe5c23ff9609444c9bff2c24f6f0de69fcb8410af30\", frames = 71, duration = 2.3333332538604736, weight = 1 },\n        death02 = { sha256 = \"41264f7f44c425c68762e3fbe5556d86aaea36d1a1e0e230108061a0d172e814\", frames = 71, duration = 2.3333332538604736, weight = 1 },\n        death03 = { sha256 = \"ec70b1ada6481dc5e34e6f54487ce41b9adb89f9e2a4bf1df5ffe71dfb3f4a0d\", frames = 71, duration = 2.3333332538604736, weight = 1 },\n        walk = { sha256 = \"36d9dfaac3f6dac195e3255ff9ffdf574191de7c3c6d203082fd43b461a149fd\", frames = 161, duration = 5.333333492279053 },\n        omittedStaticNonRigTracks = { \"Turret_Barrel\", \"Turret_Muzzle\" },\n    },\n    heavyDisintegrator = {\n        sourceProjectile = \"CDFHeavyDisintegratorPulseLaser01\",\n        sourceProjectileSha256 = \"0e09b2070b5db8c5c788955fd03160bd412edfa5859698bb9217537da0fa6be5\",\n        sanctuaryProjectile = \"pgr305h\", damage = 150, range = 35,\n        rateOfFire = 2.5, muzzleVelocity = 35, ballisticArc = \"LowArc\",\n        aboveWaterFireOnly = true, aboveWaterTargetsOnly = true,\n    },\n    naniteTorpedo = {\n        sourceProjectile = \"CANTorpedoNanite01\",\n        sourceProjectileSha256 = \"90ed85157713b241bcc0a73062dcbd998f8dc7765ecc4d830397ba8985cfba0f\",\n        sanctuaryProjectile = \"pgr305t\", sourceDamage = 4,\n        sourceDoTPulses = 5, sourceDoTTime = 0.5,\n        sanctuaryCollapsedDamagePerProjectile = 20,\n        sourceProjectilesPerOnFire = 2, sourceMuzzleSalvoSize = 2,\n        sanctuaryProjectilesPerCycle = 4, range = 32,\n        rateOfFire = 0.25, muzzleVelocity = 5,\n    },\n    omittedAntiTorpedo = {\n        reason = \"Sanctuary HostWeapon has no projectile-target weapon API\",\n        targetType = \"RULEWTT_Projectile\", targetOnly = \"TORPEDO\",\n        sourceProjectile = \"CIMAntiTorpedo03\",\n        sourceProjectileSha256 = \"096f9ad1f981b1bc517e8dce0864ebc26a4afb8edccacd84c883bbab6709989d\",\n        sourceProjectileScriptSha256 = \"0bd5fc75bc282fe3d49011a0fa2c0f46170ebfa163eb51cdbe77f1682caf18e1\",\n    },\n    limitations = {\n        sourceDeathRateRandomization = \"0.75-1.25 unavailable; nominal rate used\",\n        sourceDeathWeightedRandom = \"deterministic unit-index thirds preserve equal weights\",\n        sourceMaxReverseSpeedRuntime = false,\n        sourceLayerChangeOffsetHeightRuntime = false,\n        sourceWaterVisionDistinctRuntime = false,\n        sourceGroundKickupEffects = false,\n        sourceAudioBanks = false,\n        sourceProjectileEmitterGraphs = false,\n        sourceHeavyDestroyOnWaterRuntime = false,\n        sourceTorpedoSubLayerMergedIntoWater = true,\n        sourceNaniteDoTTemporalPulsesCollapsed = true,\n        sourceAntiTorpedoProjectileTargeting = false,\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 3: Amphibious Assault Bot\"\nUnitTemplate.general.name = \"The Brick\"\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"direct\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 20\nUnitTemplate.general.iconUIType = \"amphibious\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = nil\nUnitTemplate.audio = nil\n\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.8, z = 0 },\n    collisionSize = { x = 0.9, y = 1.6, z = 0.9 },\n}\nUnitTemplate.footprint = { x = 0.9, y = 0.9 }\nUnitTemplate.defence = { health = { max = 9000, regen = 0, value = 9000 } }\nUnitTemplate.economy = {\n    buildTime = 4800,\n    cost = { alloys = 1280, energy = 14000 },\n}\nUnitTemplate.intel = { visionRadius = 26 }\nUnitTemplate.movement = {\n    acceleration = 2,\n    deceleration = 2,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"SeabedSmall\" },\n    collisionMaskSpawn = { \"SeabedSmall\" },\n    maxReverseDistance = 5,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotationSpeed = 60,\n    sortOrder = 1,\n    speed = 2,\n    terrainAlignmentFactor = 1,\n    type = \"LegsSeabed\",\n    walkAnimation = { authoredSpeed = 0.25 },\n}\nUnitTemplate.tags = {\n    \"ANTI_NAVY\", \"ANTI_SURFACE\", \"BOT\",\n    \"BUILDABLE_BY_T3_FACTORY\", \"DIRECT_FIRE\", \"GUARD\",\n    \"LAND\", \"MOBILE\", \"SEABED\", \"TECH3\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.9, y = 0.9 },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.visuals.animations = {\n    death01 = { clipName = \"AnimDeath01\", sanAnimationPath = \"Units/ugl3001/LOD0/ugl3001.sananimation\" },\n    death02 = { clipName = \"AnimDeath02\", sanAnimationPath = \"Units/ugl3001/LOD0/ugl3001.sananimation\" },\n    death03 = { clipName = \"AnimDeath03\", sanAnimationPath = \"Units/ugl3001/LOD0/ugl3001.sananimation\" },\n    walk = { authoredSpeed = 0.25, clipName = \"AnimWalk\", sanAnimationPath = \"Units/ugl3001/LOD0/ugl3001.sananimation\" },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nlocal function SCO_BrickAim(aimBone, yawBone, pitchBone, yawRange, yawSpeed, pitchRange, pitchSpeed, projectileSpeed, solverType, tolerance, lead)\n    return {\n        aimBone = aimBone, yawBone = yawBone, pitchBone = pitchBone,\n        aimTolerance = tolerance, defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0, leadTarget = lead,\n        pitchMin = -pitchRange, pitchMax = pitchRange, pitchSpeed = pitchSpeed,\n        poseResetTime = 3, projectileSpeed = projectileSpeed,\n        solverType = solverType,\n        yawMin = -yawRange, yawMax = yawRange, yawSpeed = yawSpeed,\n    }\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = { SCO_BrickAim(\"Projectile03\", \"Turret\", \"Projectile03\", 180, 60, 75, 60, 35, \"LowArc\", 1, true) },\n        collideFriendly = false, damage = 150, damageFriendly = false,\n        damageRadius = 0, damageType = \"Normal\", firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0, muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Projectile03\" } } },\n        muzzles = { Projectile03 = { aimController = \"Projectile03\" } },\n        muzzleSalvoDelay = 0, muzzleSalvoSize = 1,\n        projectileLifetime = 1.15, projectileTemplate = \"pgr305h\",\n        rangeMax = 35, rangeMin = 0, rangeRingType = \"DirectFire\",\n        rangeTracking = 1.1, reloadTime = 0.4,\n        targetWaterLimits = \"Above\",\n        scoFaCybranT3WaterGate = \"OwnerAndTargetAbove\",\n    },\n    {\n        -- Source is non-turreted. Projectile01 is an unskinned helper;\n        -- this adapter satisfies HostWeapon without moving mesh geometry.\n        aimControllers = { SCO_BrickAim(\"Projectile01\", \"Projectile01\", \"Projectile01\", 180, 360, 90, 360, 5, \"NoArc\", 2, false) },\n        collideFriendly = false, damage = 20, damageFriendly = false,\n        damageRadius = 0, damageType = \"Normal\", firingRandomness = 0,\n        layerTargetLimits = { \"Seabed\", \"Water\" },\n        layerWeaponLimits = { \"Seabed\" },\n        muzzleGroupChargeDelay = 0, muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Projectile01\", \"Projectile01\" } } },\n        muzzles = { Projectile01 = { aimController = \"Projectile01\" } },\n        muzzleSalvoDelay = 0.8, muzzleSalvoSize = 2,\n        projectileLifetime = 7, projectileTemplate = \"pgr305t\",\n        rangeMax = 32, rangeMin = 0, rangeRingType = \"DirectFire\",\n        rangeTracking = 1.1, reloadTime = 4,\n        targetWaterLimits = \"Below\",\n        scoFaCybranT3WaterGate = \"OwnerAndTargetBelow\",\n        scoFaSourceDoTPulsesCollapsed = true,\n    },\n}", ValidateBrick);
			QueueAppend(obj, list, "LJ/lua/common/units/unitsTemplates/ugl3002/ugl3002.santp", "UGL3002 Loyalist template", "\n\n-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0\n-- Explicit same-faction role substitution: FA URL0303 Loyalist\n-- replaces Sanctuary's ugl3002 Nitro and retains GuardLandUnit.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URL0303 -> ugl3002\",\n    substitution = true,\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/URL0303/URL0303_unit.bp\",\n    sourceBlueprintSha256 = \"74d0b6c0f89c8d79f6041ed92034108c50b6851caf29892e4d58dbf0c1df3d91\",\n    sourceScript = \"units/URL0303/URL0303_Script.lua\",\n    sourceScriptSha256 = \"e057041a1def1f65f9cb88fc095f7899ba5f4453b451764908ea6b83a14c5dbd\",\n    class = { owner = \"unitsDefaultGuard\", name = \"GuardLandUnit\" },\n    collision = { size = { x = 0.9, y = 1.2, z = 0.9 }, offset = { x = 0, y = 0, z = 0 } },\n    selection = { x = 0.55, z = 0.5, centerX = 0, centerZ = -0.15, thickness = 0.7 },\n    defence = { health = 3100, regen = 0 },\n    economy = { buildCostEnergy = 5400, buildCostMass = 480, buildTime = 2400 },\n    intel = { visionRadius = 22 },\n    movement = {\n        sourceMotionType = \"RULEUMT_Land\", acceleration = 4,\n        brake = 4, speed = 4, reverseSpeed = 0,\n        steerForce = 10, turnRadius = 5, turnRate = 120,\n        sourceAnimationWalkRate = 4.5,\n        sanctuaryAuthoredSpeed = 0.8888888888888888,\n    },\n    animations = {\n        death01 = { sha256 = \"2b803b46eb61b896bdba38c8c317b84d9354849ca1f9a0277132ff781177497c\", frames = 31, duration = 1, weight = 1 },\n        death02 = { sha256 = \"f1e2f7e292b6ecd36d9bbce6426ea10eeda0db1c292456228f86ab3b170363c8\", frames = 31, duration = 1, weight = 1 },\n        fold = { sha256 = \"e0959f00e08e0fc220bb28a137399a22853fb63dcaf0613a2484c9b67f68c9ac\", frames = 61, duration = 2 },\n        walk = { sha256 = \"86b0565d75db5875b86a62c3f7733b3116e1b8e6b858c8a775e623fca7bbf85c\", frames = 33, duration = 3.200000047683716 },\n        omittedStaticNonRigTracks = { \"Turret_Center\", \"Barrel_Center01\", \"Barrel_Center02\" },\n    },\n    disintegrator = {\n        sourceProjectile = \"CDFLaserDisintegrator02\",\n        sourceProjectileSha256 = \"67f49f2d714889a4a98af6bb6bac6a239ab9886f83801568f8bba4ff18702ed9\",\n        sanctuaryProjectile = \"pgr303d\", damage = 175, range = 25,\n        rateOfFire = 0.3, muzzleVelocity = 30,\n        sourceMuzzleChargeDelay = 0.1, sourceMuzzleSalvoDelay = 0.3,\n        sourceMuzzleSalvoSize = 3, sourceProjectilesPerOnFire = 3,\n        sanctuaryProjectilesPerCycle = 9,\n    },\n    heavyBolter = {\n        sourceProjectile = \"CDFBolter02\",\n        sourceProjectileSha256 = \"f29bbeda9a1d139e330d3cf4d30d7a9cffb80b321e77a2bb86eda7b9471b8091\",\n        sanctuaryProjectile = \"pgr303b\", damage = 12, range = 25,\n        rateOfFire = 2.5, muzzleVelocity = 40,\n    },\n    deathEmp = {\n        sourceProjectile = \"CIFEMP01\",\n        sourceProjectileSha256 = \"6e49dd222e1fc3e2d86054276b392315313c738b3b3838f182013445f8ec014f\",\n        sourceProjectileScriptSha256 = \"9cffdd3f0309a0d06b48b187dad0fcf3caf43ddd080ae73270b15786cdfb75e3\",\n        sourceDamage = 1, radius = 10, damageFriendly = false,\n        sourceDamageType = \"EMP\", sourceStunDuration = 2,\n        sanctuaryDamageType = \"Normal\",\n    },\n    omittedMissileRedirect = {\n        reason = \"Sanctuary unit/shield APIs expose no tactical missile redirector\",\n        attachBone = \"Turret_Muzzle\", radius = 5, redirectRateOfFire = 1,\n    },\n    limitations = {\n        sourceDeathRateRandomization = \"0.75-1.25 unavailable; nominal rate used\",\n        sourceDeathWeightedRandom = \"deterministic unit-index halves preserve equal weights\",\n        transportFoldRuntime = false,\n        sourceGroundKickupEffects = false,\n        sourceAudioBanks = false,\n        sourceProjectileEmitterGraphs = false,\n        sourceProjectileDestroyOnWaterRuntime = false,\n        sourceTacticalMissileRedirect = false,\n        sourceEmpDamageTypeRuntime = false,\n        sourceStunStatusRuntime = false,\n        sourceDeathUnitCompleteGateRuntime = false,\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 3: Siege Assault Bot\"\nUnitTemplate.general.name = \"Loyalist\"\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"direct\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 20\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = nil\nUnitTemplate.audio = nil\n\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.6, z = 0 },\n    collisionSize = { x = 0.9, y = 1.2, z = 0.9 },\n}\nUnitTemplate.footprint = { x = 0.9, y = 0.9 }\nUnitTemplate.defence = { health = { max = 3100, regen = 0, value = 3100 } }\nUnitTemplate.economy = {\n    buildTime = 2400,\n    cost = { alloys = 480, energy = 5400 },\n}\nUnitTemplate.intel = { visionRadius = 22 }\nUnitTemplate.movement = {\n    acceleration = 4,\n    deceleration = 4,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"LandSmall\" },\n    collisionMaskSpawn = { \"LandSmall\" },\n    maxReverseDistance = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotationSpeed = 120,\n    sortOrder = 1,\n    speed = 4,\n    terrainAlignmentFactor = 1,\n    type = \"LegsLand\",\n    walkAnimation = { authoredSpeed = 0.8888888888888888 },\n}\nUnitTemplate.tags = {\n    \"ANTI_SURFACE\", \"BOT\", \"BUILDABLE_BY_T3_FACTORY\",\n    \"DIRECT_FIRE\", \"GUARD\", \"LAND\", \"MOBILE\", \"TECH3\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.55, y = 0.5 },\n    offset = { x = 0, y = 0, z = -0.15 },\n}\nUnitTemplate.visuals.animations = {\n    death01 = { clipName = \"AnimDeath01\", sanAnimationPath = \"Units/ugl3002/LOD0/ugl3002.sananimation\" },\n    death02 = { clipName = \"AnimDeath02\", sanAnimationPath = \"Units/ugl3002/LOD0/ugl3002.sananimation\" },\n    fold = { clipName = \"AnimFold\", sanAnimationPath = \"Units/ugl3002/LOD0/ugl3002.sananimation\" },\n    walk = { authoredSpeed = 0.8888888888888888, clipName = \"AnimWalk\", sanAnimationPath = \"Units/ugl3002/LOD0/ugl3002.sananimation\" },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nlocal function SCO_LoyalistAim(aimBone, yawBone, pitchBone, yawRange, yawSpeed, pitchRange, pitchSpeed, projectileSpeed)\n    return {\n        aimBone = aimBone, yawBone = yawBone, pitchBone = pitchBone,\n        aimTolerance = 2, defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0, leadTarget = true,\n        pitchMin = -pitchRange, pitchMax = pitchRange, pitchSpeed = pitchSpeed,\n        poseResetTime = 3, projectileSpeed = projectileSpeed,\n        solverType = \"LowArc\",\n        yawMin = -yawRange, yawMax = yawRange, yawSpeed = yawSpeed,\n    }\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = { SCO_LoyalistAim(\"Muzzle_Left\", \"Torso\", \"Barrel_L\", 180, 180, 45, 60, 30) },\n        collideFriendly = false, damage = 175, damageFriendly = false,\n        damageRadius = 0, damageType = \"Normal\", firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" }, layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0.1, muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Muzzle_Left\", \"Muzzle_Left\", \"Muzzle_Left\" } } },\n        muzzles = { Muzzle_Left = { aimController = \"Muzzle_Left\" } },\n        muzzleSalvoDelay = 0.3, muzzleSalvoSize = 3,\n        projectileLifetime = 0.9583333333333334, projectileTemplate = \"pgr303d\",\n        rangeMax = 25, rangeMin = 0, rangeRingType = \"DirectFire\",\n        rangeTracking = 1.15, reloadTime = 3.3333333333333335,\n        targetWaterLimits = \"Above\", scoFaCybranT3WaterGate = \"TargetAbove\",\n    },\n    {\n        aimControllers = { SCO_LoyalistAim(\"Muzzle_Right\", \"Barrel_R\", \"Barrel_R\", 35, 90, 45, 90, 40) },\n        collideFriendly = false, damage = 12, damageFriendly = false,\n        damageRadius = 0, damageType = \"Normal\", firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" }, layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0, muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Muzzle_Right\" } } },\n        muzzles = { Muzzle_Right = { aimController = \"Muzzle_Right\" } },\n        muzzleSalvoDelay = 0, muzzleSalvoSize = 1,\n        projectileLifetime = 0.71875, projectileTemplate = \"pgr303b\",\n        rangeMax = 25, rangeMin = 0, rangeRingType = \"DirectFire\",\n        rangeTracking = 1.15, reloadTime = 0.4,\n        targetWaterLimits = \"Above\", scoFaCybranT3WaterGate = \"TargetAbove\",\n    },\n    {\n        category = \"DeathExplosion\",\n        damage = 1,\n        damageRadius = 10,\n        damageFriendly = false,\n        damageType = \"Normal\",\n        scoFaSourceDamageType = \"EMP\",\n        scoFaSourceStunDuration = 2,\n    },\n}", ValidateLoyalist);
			QueueAppend(obj, list, "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Cybran T3 Guard lifecycle", "\n\n-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0\nlocal SCO_FaCybranT3Layers = Import(\"common/layers.lua\")\nlocal SCO_FaCybranT3StockUpdateAnimations = HostGuardLandUnit.UpdateAnimations\nfunction HostGuardLandUnit:UpdateAnimations()\n    if self.tpId == \"ugl3001\" and not self.dead then\n        local targetLayer = SCO_FaCybranT3Layers.TargetingLayer.Land\n        local waterResult, hasWater = Engine.HasWater()\n        if waterResult == EngineErrorCode.Success and hasWater then\n            local levelResult, waterLevel = Engine.GetWaterLevel()\n            local position = self:GetPosition()\n            if levelResult == EngineErrorCode.Success and waterLevel ~= nil and position ~= nil then\n                local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)\n                if terrainResult == EngineErrorCode.Success\n                    and terrainHeight < waterLevel - 0.05\n                    and position.y < waterLevel - 0.05\n                then\n                    targetLayer = SCO_FaCybranT3Layers.TargetingLayer.Seabed\n                end\n            end\n        end\n        if self.targetingLayer ~= targetLayer then self:SetTargetingLayer(targetLayer) end\n    end\n    return SCO_FaCybranT3StockUpdateAnimations(self)\nend\n\n-- HostUnit:Destroy calls OnDestroy before it starts DeathThread.\n-- Hash-pinned unitsBaseClass.lua SHA-256\n-- 45ec82463ae6a39460eb661700fe20105fc068b8bab07592326ae712d003b5be\n-- sets self.dead, deletes\n-- every weapon and targetCollider there. Clear the remaining movement\n-- collision mask before preserving the visible source death delay.\nlocal SCO_FaCybranT3StockDeathThread = HostGuardLandUnit.DeathThread\nfunction HostGuardLandUnit:DeathThread(overkillRatio)\n    if self.tpId ~= \"ugl3001\" and self.tpId ~= \"ugl3002\" then\n        return SCO_FaCybranT3StockDeathThread(self, overkillRatio)\n    end\n    if not self.dead then\n        error(\"Cybran T3 source death animation must run after HostUnit:OnDestroy\")\n    end\n    Engine.SetMovementCollisionMask(self.id, 0)\n    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations\n    local index = (self.id and self.id.index) or 0\n    local death = nil\n    local duration = 0\n    if self.tpId == \"ugl3001\" then\n        local bucket = index % 3\n        death = animations and (bucket == 0 and animations.death01\n            or bucket == 1 and animations.death02 or animations.death03)\n        duration = 2.3333332538604736\n    else\n        death = animations and (index % 2 == 0 and animations.death01 or animations.death02)\n        duration = 1\n    end\n    if not death or not death.id then error(\"Cybran T3 role unit requires every hash-pinned source death clip\") end\n    Engine.PlayAnimation(self.id, death.id, 0.1)\n    WaitSeconds(duration)\n    return SCO_FaCybranT3StockDeathThread(self, overkillRatio)\nend", ValidateGuardHost);
			QueueAppend(obj, list, "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "Cybran T3 water gates", "\n\n-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0\n-- Physically enforce donor water gates after every earlier wrapper.\nlocal SCO_FaCybranT3StockCanShootAt = HostWeapon.CanShootAt\nfunction HostWeapon:CanShootAt(targetUnit)\n    if not SCO_FaCybranT3StockCanShootAt(self, targetUnit) then return false end\n    local unitId = self.unit and self.unit.tpId\n    if unitId ~= \"ugl3001\" and unitId ~= \"ugl3002\" then return true end\n    local gate = self.tp and self.tp.scoFaCybranT3WaterGate\n    if gate == nil then return true end\n\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return gate ~= \"OwnerAndTargetBelow\" end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return false end\n    local targetPosition = targetUnit and targetUnit:GetPosition()\n    if targetPosition == nil then return false end\n    local targetAbove = targetPosition.y >= waterLevel - 0.05\n    if gate == \"TargetAbove\" then return targetAbove end\n    local ownerPosition = self.unit:GetPosition()\n    if ownerPosition == nil then return false end\n    local ownerAbove = ownerPosition.y >= waterLevel - 0.05\n    if gate == \"OwnerAndTargetAbove\" then return ownerAbove and targetAbove end\n    if gate == \"OwnerAndTargetBelow\" then return not ownerAbove and not targetAbove end\n    return false\nend", ValidateHostWeapon);
			QueueAppend(obj, list, "LJ/lua/common/systems/import.lua", "Cybran T3 projectile scanner", "\n\n-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0\n-- These four isolated projectile templates exist only in FilesCache.\nlocal SCO_FaCybranT3ScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_FaCybranT3ScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then return folders end\n    local owned = {\n        directory .. \"pgr305h\", directory .. \"pgr305t\",\n        directory .. \"pgr303d\", directory .. \"pgr303b\",\n    }\n    for _, candidate in ipairs(owned) do\n        local found = false\n        for _, folder in ipairs(folders) do\n            if folder == candidate then found = true break end\n        end\n        if not found then table.insert(folders, candidate) end\n    end\n    return folders\nend", ValidateImport);
			ProjectileSpec[] projectiles = Projectiles;
			foreach (ProjectileSpec projectile in projectiles)
			{
				QueueVirtualProjectile(obj, list, projectile);
			}
			if (list.Count == 0)
			{
				Log("Brick/Loyalist gameplay and isolated projectiles are already current.");
				return;
			}
			Commit(obj, list);
			Log("Applied atomic XRL0305->ugl3001 and URL0303->ugl3002 T3 role transaction.");
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
			Log($"Failed to apply the FA Cybran T3 role transaction: {arg}");
			throw;
		}
	}

	private static void ValidatePinnedScope()
	{
		string[] second = new string[4] { "pgr305h", "pgr305t", "pgr303d", "pgr303b" };
		if (Projectiles.Length != 4 || !Projectiles.Select((ProjectileSpec projectile) => projectile.Id).SequenceEqual<string>(second) || Projectiles.Select((ProjectileSpec projectile) => projectile.Id).Distinct<string>(StringComparer.Ordinal).Count() != 4 || Projectiles.Any((ProjectileSpec projectile) => projectile.BlueprintSha256.Length != 64 || projectile.ScriptSha256.Length != 64) || "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26".Length != 64 || "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12".Length != 64)
		{
			throw new InvalidOperationException("The reviewed Cybran T3 mapping/projectile scope changed.");
		}
	}

	private static void ValidateTransactionState(object cache)
	{
		int num = 0;
		(string, string)[] array = new(string, string)[5]
		{
			("LJ/lua/common/units/unitsTemplates/ugl3001/ugl3001.santp", "UGL3001 Brick template"),
			("LJ/lua/common/units/unitsTemplates/ugl3002/ugl3002.santp", "UGL3002 Loyalist template"),
			("LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Cybran T3 Guard lifecycle"),
			("LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "Cybran T3 water gates"),
			("LJ/lua/common/systems/import.lua", "Cybran T3 projectile scanner")
		};
		for (int i = 0; i < array.Length; i++)
		{
			(string, string) tuple = array[i];
			if (GetResourceText(GetCachedResource(cache, tuple.Item1, tuple.Item2).Stock).IndexOf("-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0", StringComparison.Ordinal) >= 0)
			{
				num++;
			}
		}
		ProjectileSpec[] projectiles = Projectiles;
		foreach (ProjectileSpec projectileSpec in projectiles)
		{
			CacheResource cacheResource = TryGetCachedResource(cache, ProjectilePath(projectileSpec.Id), projectileSpec.SourceId + " isolated projectile");
			if (cacheResource != null)
			{
				if (GetResourceText(cacheResource.Stock).IndexOf("-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0", StringComparison.Ordinal) < 0)
				{
					throw new InvalidOperationException("Reserved projectile ID " + projectileSpec.Id + " already exists without this module's marker.");
				}
				num++;
			}
		}
		if (num != 0 && num != 9)
		{
			throw new InvalidOperationException($"A partial Cybran T3 role transaction was found ({num}/9 owned resources).");
		}
	}

	private static string BuildVirtualProjectile(ProjectileSpec projectile)
	{
		string text = projectile.PhysicsProfile switch
		{
			"Gravity" => string.Empty, 
			"NoGravity" => "    movement = { gravityMultiplier = 0 },\n", 
			"HomingTorpedo" => "    movement = { acceleration = 5, gravityMultiplier = 0, rotationSpeed = 230, speedMax = 18, type = \"TargetEntity\" },\n", 
			_ => throw new InvalidOperationException("Unknown projectile physics profile " + projectile.PhysicsProfile + "."), 
		};
		return "---@type ProjectileTemplate\nProjectileTemplate = {\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = { icon = \"projectile\", name = \"" + projectile.Name + "\", tpId = \"" + projectile.Id + "\" },\n" + text + "    nonUniformScale = { x = " + projectile.Scale + ", y = " + projectile.Scale + ", z = " + projectile.Scale + " },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = { { effects = { { particleName = \"" + projectile.ImpactVfx + "\" } } } },\n        persistantEffects = { { effects = { { particleName = \"" + projectile.TrailVfx + "\" } } } },\n    },\n}\n\n-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\n-- Source ID: " + projectile.SourceId + "\n-- Source blueprint: " + projectile.BlueprintPath + "\n-- Source blueprint SHA-256: " + projectile.BlueprintSha256 + "\n-- Source script: " + projectile.ScriptPath + "\n-- Source script SHA-256: " + projectile.ScriptSha256 + "\n-- Source physics profile: " + projectile.PhysicsProfile + "\n-- Limitation: FA emitter graphs and DestroyOnWater/StayUnderwater flags are not native sanvfx/template inputs.\n-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0";
	}

	private static void ValidateStock(string relativePath, string source)
	{
		switch (relativePath)
		{
		case "LJ/lua/common/units/unitsTemplates/ugl3001/ugl3001.santp":
			ValidateStockUnit(source, "ugl3001");
			break;
		case "LJ/lua/common/units/unitsTemplates/ugl3002/ugl3002.santp":
			ValidateStockUnit(source, "ugl3002");
			break;
		case "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua":
			RequireTokens(source, "HostGuardLandUnit = Class(\"GuardLandUnit\", LandUnit)", "HostGuardCommander");
			break;
		case "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua":
			RequireTokens(source, "function HostWeapon:CanShootAt(targetUnit)", "self.layerWeaponLimitsMask", "self.layerTargetLimitsMask");
			break;
		case "LJ/lua/common/systems/import.lua":
			RequireTokens(source, "function ScanDir", "Engine.GetFoldersInsideDirectory");
			break;
		}
	}

	private static void ValidateStockUnit(string source, string targetId)
	{
		RequireTokens(source, "UnitTemplate =", "tpId = \"" + targetId + "\"", "\"unitsDefaultGuard\"", "\"GuardLandUnit\"");
		RequireExactly(source, "tpId = \"" + targetId + "\"", 1, "stock " + targetId + " tpId");
		if (!Regex.IsMatch(source, "class\\s*=\\s*\\{\\s*\"unitsDefaultGuard\"\\s*,\\s*\"GuardLandUnit\"\\s*,?\\s*\\}", RegexOptions.CultureInvariant))
		{
			throw new InvalidOperationException(targetId + " no longer exposes its reviewed GuardLandUnit class.");
		}
	}

	private static void ValidateBrick(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0", 1, "Brick marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "mapping = \"XRL0305 -> ugl3001\"", "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", "bfcaa9f4cd50e24bfffc87325283075206bb8ad3a1e7507e1d02ab8bd7ca406d", "c14840f975d04290da855b13d409f0c60d9a8c5082463707056bb38ed32f516e", "UnitTemplate.general.name = \"The Brick\"", "collisionSize = { x = 0.9, y = 1.6, z = 0.9 }", "max = 9000, regen = 0, value = 9000", "cost = { alloys = 1280, energy = 14000 }", "UnitTemplate.intel = { visionRadius = 26 }", "type = \"LegsSeabed\"", "collisionMaskDefault = { \"SeabedSmall\" }", "collisionMaskSpawn = { \"SeabedSmall\" }", "maxReverseDistance = 5", "authoredSpeed = 0.25", "\"SEABED\"", "8e93684c5d04b26498a26142bcb4bfbd9eae000222bb53d257f67dae1a5fa2ba", "clipName = \"AnimDeath01\"", "clipName = \"AnimDeath02\"", "clipName = \"AnimDeath03\"", "clipName = \"AnimWalk\"", "SCO_BrickAim(\"Projectile03\", \"Turret\", \"Projectile03\"", "yawMin = -yawRange", "damage = 150", "projectileTemplate = \"pgr305h\"", "reloadTime = 0.4", "damage = 20", "\"Projectile01\", \"Projectile01\"", "muzzleSalvoDelay = 0.8", "muzzleSalvoSize = 2", "projectileTemplate = \"pgr305t\"", "reloadTime = 4", "scoFaSourceDoTPulsesCollapsed = true", "sourceAntiTorpedoProjectileTargeting = false");
		RequireExactly(source2, "projectileTemplate = \"pgr305", 2, "Brick projectile routes");
		RequireExactly(source2, "clipName = \"AnimDeath", 3, "Brick death clips");
		RequireNotContains(source2, "\"AMPHIBIOUS\"", "LandSmall", "CIMAntiTorpedo03/CIMAntiTorpedo03.santp", "category = \"DeathExplosion\"", "pad002", "AeonProjectiles");
		ValidateStock("LJ/lua/common/units/unitsTemplates/ugl3001/ugl3001.santp", source);
	}

	private static void ValidateLoyalist(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0", 1, "Loyalist marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "mapping = \"URL0303 -> ugl3002\"", "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", "74d0b6c0f89c8d79f6041ed92034108c50b6851caf29892e4d58dbf0c1df3d91", "e057041a1def1f65f9cb88fc095f7899ba5f4453b451764908ea6b83a14c5dbd", "UnitTemplate.general.name = \"Loyalist\"", "collisionSize = { x = 0.9, y = 1.2, z = 0.9 }", "max = 3100, regen = 0, value = 3100", "cost = { alloys = 480, energy = 5400 }", "UnitTemplate.intel = { visionRadius = 22 }", "type = \"LegsLand\"", "rotationSpeed = 120", "authoredSpeed = 0.8888888888888888", "clipName = \"AnimDeath01\"", "clipName = \"AnimDeath02\"", "clipName = \"AnimFold\"", "clipName = \"AnimWalk\"", "\"Muzzle_Left\", \"Muzzle_Left\", \"Muzzle_Left\"", "muzzleGroupChargeDelay = 0.1", "muzzleSalvoDelay = 0.3", "muzzleSalvoSize = 3", "projectileTemplate = \"pgr303d\"", "reloadTime = 3.3333333333333335", "projectileTemplate = \"pgr303b\"", "projectileLifetime = 0.71875", "category = \"DeathExplosion\"", "damageRadius = 10", "damageFriendly = false", "scoFaSourceDamageType = \"EMP\"", "scoFaSourceStunDuration = 2", "sourceTacticalMissileRedirect = false", "sourceStunStatusRuntime = false");
		RequireExactly(source2, "projectileTemplate = \"pgr303", 2, "Loyalist projectile routes");
		RequireExactly(source2, "clipName = \"AnimFold\"", 1, "Loyalist unbound fold payload");
		RequireExactly(source2, "category = \"DeathExplosion\"", 1, "Loyalist death weapon");
		RequireNotContains(source2, "CIFEMP01/CIFEMP01.santp", "category = \"MissileRedirect\"", "pad002", "AeonProjectiles");
		ValidateStock("LJ/lua/common/units/unitsTemplates/ugl3002/ugl3002.santp", source);
	}

	private static void ValidateGuardHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0", 1, "Cybran T3 Guard marker");
		RequireTokens(OwnedAppendix(source), "local SCO_FaCybranT3StockUpdateAnimations = HostGuardLandUnit.UpdateAnimations", "function HostGuardLandUnit:UpdateAnimations()", "self.tpId == \"ugl3001\"", "TargetingLayer.Seabed", "Engine.SampleTerrainHeight(position)", "return SCO_FaCybranT3StockUpdateAnimations(self)", "local SCO_FaCybranT3StockDeathThread = HostGuardLandUnit.DeathThread", "function HostGuardLandUnit:DeathThread(overkillRatio)", "self.tpId ~= \"ugl3001\" and self.tpId ~= \"ugl3002\"", "if not self.dead then", "Engine.SetMovementCollisionMask(self.id, 0)", "local bucket = index % 3", "index % 2 == 0", "duration = 2.3333332538604736", "Engine.PlayAnimation(self.id, death.id, 0.1)", "return SCO_FaCybranT3StockDeathThread(self, overkillRatio)");
	}

	private static void ValidateHostWeapon(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0", 1, "Cybran T3 water-gate marker");
		RequireTokens(OwnedAppendix(source), "local SCO_FaCybranT3StockCanShootAt = HostWeapon.CanShootAt", "if not SCO_FaCybranT3StockCanShootAt(self, targetUnit) then return false end", "unitId ~= \"ugl3001\" and unitId ~= \"ugl3002\"", "Engine.HasWater()", "Engine.GetWaterLevel()", "gate == \"TargetAbove\"", "gate == \"OwnerAndTargetAbove\"", "gate == \"OwnerAndTargetBelow\"", "return not ownerAbove and not targetAbove");
	}

	private static void ValidateImport(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0", 1, "Cybran T3 scanner marker");
		RequireTokens(OwnedAppendix(source), "local SCO_FaCybranT3ScanDir = ScanDir", "directory .. \"pgr305h\"", "directory .. \"pgr305t\"", "directory .. \"pgr303d\"", "directory .. \"pgr303b\"", "table.insert(folders, candidate)");
	}

	private static void ValidateVirtualProjectile(string source, ProjectileSpec projectile)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0", 1, projectile.Id + " projectile marker");
		RequireTokens(source, "ProjectileTemplate =", "tpId = \"" + projectile.Id + "\"", "name = \"" + projectile.Name + "\"", "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12", projectile.SourceId, projectile.BlueprintPath, projectile.BlueprintSha256, projectile.ScriptPath, projectile.ScriptSha256, projectile.ImpactVfx, projectile.TrailVfx);
		if (projectile.PhysicsProfile == "Gravity")
		{
			RequireNotContains(source, "movement =");
		}
		else if (projectile.PhysicsProfile == "NoGravity")
		{
			RequireTokens(source, "movement = { gravityMultiplier = 0 }");
		}
		else
		{
			RequireTokens(source, "acceleration = 5", "rotationSpeed = 230", "speedMax = 18", "type = \"TargetEntity\"");
		}
		RequireNotContains(source, "pad002", "AeonProjectiles", "pcl001");
	}

	private static void QueueAppend(object cache, ICollection<CacheMutation> mutations, string relativePath, string description, string appendix, Action<string> validate)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		if (resourceText.IndexOf("-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0", StringComparison.Ordinal) >= 0)
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

	private static void QueueVirtualProjectile(object cache, ICollection<CacheMutation> mutations, ProjectileSpec projectile)
	{
		string relativePath = ProjectilePath(projectile.Id);
		string text = projectile.SourceId + " isolated projectile";
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath, text);
		if (cacheResource != null)
		{
			string resourceText = GetResourceText(cacheResource.Stock);
			if (resourceText.IndexOf("-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0", StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Reserved projectile ID " + projectile.Id + " already exists without this module's marker.");
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
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Cybran T3 role marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0".Length, StringComparison.Ordinal);
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
				throw new InvalidOperationException("Cybran T3-owned Lua must not contain '" + text + "'.");
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
		string text = "[FA Cybran T3 Roles Cache Patcher] " + message;
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
