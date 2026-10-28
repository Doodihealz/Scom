using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace GuardCybranMonkeylordCachePatcher;

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

		public string? Movement { get; }

		public string TrailVfx { get; }

		public string? ImpactVfx { get; }

		public string Limitation { get; }

		public ProjectileSpec(string id, string name, string sourceId, string sourceBlueprintPath, string sourceBlueprintSha256, string sourceScriptPath, string sourceScriptSha256, string? movement, string trailVfx, string? impactVfx, string limitation)
		{
			Id = id;
			Name = name;
			SourceId = sourceId;
			SourceBlueprintPath = sourceBlueprintPath;
			SourceBlueprintSha256 = sourceBlueprintSha256;
			SourceScriptPath = sourceScriptPath;
			SourceScriptSha256 = sourceScriptSha256;
			Movement = movement;
			TrailVfx = trailVfx;
			ImpactVfx = impactVfx;
			Limitation = limitation;
		}
	}

	private sealed class PatchSpec
	{
		public string RelativePath { get; }

		public string Description { get; }

		public string Marker { get; }

		public string Appendix { get; }

		public Func<string, string>? Transform { get; }

		public string[] RequiredTokens { get; }

		public string? VirtualSource { get; }

		public PatchSpec(string relativePath, string description, string marker, string appendix, Func<string, string>? transform, string[] requiredTokens, string? virtualSource = null)
		{
			RelativePath = relativePath;
			Description = description;
			Marker = marker;
			Appendix = appendix;
			Transform = transform;
			RequiredTokens = requiredTokens;
			VirtualSource = virtualSource;
		}
	}

	private sealed class PatchResource
	{
		public PatchSpec Spec { get; }

		public string Path { get; }

		public object? Stock { get; }

		public bool Added { get; }

		public object? Replacement { get; set; }

		public bool AssignmentWasAttempted { get; set; }

		public PatchResource(PatchSpec spec, string path, object? stock, bool added = false)
		{
			Spec = spec;
			Path = path;
			Stock = stock;
			Added = added;
		}
	}

	private const string TargetTemplateRelativePath = "LJ/lua/common/units/unitsTemplates/ugl4001/ugl4001.santp";

	private const string HostGuardClassesRelativePath = "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua";

	private const string ClientGuardClassesRelativePath = "LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua";

	private const string HostBeamRelativePath = "LJ/lua/host/units/weaponsClasses/beam.lua";

	private const string ClientBeamRelativePath = "LJ/lua/client/entities/beam.lua";

	private const string HostWeaponRelativePath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private const string ImportRelativePath = "LJ/lua/common/systems/import.lua";

	private const string BolterProjectileId = "pgr402b";

	private const string NaniteProjectileId = "pgr402a";

	private const string TorpedoProjectileId = "pgr402t";

	private const string OverrideMarker = "-- Guard Cybran Monkeylord Cache Patcher 1.4.0";

	private const string LegacyOverrideMarker = "-- Guard Cybran Monkeylord Cache Patcher 1.3.0";

	private const string FaProjectilesArchiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12";

	private const string SanctuaryVfxArchiveSha256 = "86c43f27b3ff9189a82f8201eec020d18c0770568a862b034737cd17424a357c";

	private static readonly ProjectileSpec[] Projectiles = new ProjectileSpec[3]
	{
		new ProjectileSpec("pgr402b", "URL0402 Heavy Electron Bolter", "CDFBolter02", "projectiles/CDFBolter02/CDFBolter02_proj.bp", "f29bbeda9a1d139e330d3cf4d30d7a9cffb80b321e77a2bb86eda7b9471b8091", "projectiles/CDFBolter02/CDFBolter02_script.lua", "cf4b9bd0b40cdf37e10bcb77fdf12844676a503be8cdaff5f29be4226129b288", null, "VFX/Trails/vgt1281_cannon_plasma_medium_trail.sanvfx", "VFX/Impact/vgi1281_cannon_plasma_medium_impact.sanvfx", "DestroyOnWater has no supported Sanctuary projectile-transition field."),
		new ProjectileSpec("pgr402a", "URL0402 Nanite AA Missile", "CAAMissileNanite02", "projectiles/CAAMissileNanite02/CAAMissileNanite02_proj.bp", "927a795462a0c10f7baa08aef672414b47b04a96236672be24d6a4a03ba0a935", "projectiles/CAAMissileNanite02/CAAMissileNanite02_script.lua", "7001c493cc2ac2a5cd4c9d43898be59a304ff2f16317cc5a53dcfca110756747", "movement = { acceleration = 5, gravityMultiplier = 0, rotationSpeed = 180, speedMax = 50, type = \"TargetEntity\" },", "VFX/Trails/vgt3301_missile_antiair_large_trail.sanvfx", null, "The source 1.5-second random acceleration and zig-zag thread are unsupported."),
		new ProjectileSpec("pgr402t", "URL0402 Meson Torpedo", "CANTorpedoMeson02", "projectiles/CANTorpedoMeson02/CANTorpedoMeson02_proj.bp", "62fa521286123ca9dc8f8da1a9b7bf60cdcb15ee421b5ca05880c2c48d9045a8", "projectiles/CANTorpedoMeson02/CANTorpedoMeson02_script.lua", "f11469fe5cfd2b64398aa8f5e664b8d1895eb504e215bb4f33e6366538d6269b", "movement = { acceleration = 5, gravityMultiplier = 0, rotationSpeed = 230, speedMax = 18, type = \"TargetEntity\" },", "VFX/Trails/vgt8321_plasma_stream_large_trail.sanvfx", "VFX/Impact/vgi8321_plasma_stream_large_impact.sanvfx", "StayUnderwater and the FA torpedo emitter graph are unsupported.")
	};

	private const string TemplateOverride = "\r\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\r\n-- The personal pack supplies URL0402 at its authored 0.0725 scale with\r\n-- its complete native rig and A001 walk. The gameplay contract routes\r\n-- the complete source weapon suite through the real URL0402 endpoints.\r\nUnitTemplate.general.displayName = \"Monkeylord\"\r\nUnitTemplate.general.name = \"Monkeylord\"\r\nUnitTemplate.general.class = {\r\n    \"unitsDefaultGuard\",\r\n    \"GuardMonkeylord\",\r\n}\r\n\r\n-- URL0402_unit.bp SHA-256 ce61e4bf...2f1a is the gameplay source.\r\n-- Replace donor balance fields together so a visual port cannot retain\r\n-- the unrelated Guard experimental's health or economy contract.\r\nUnitTemplate.defence.health.max = 45000\r\nUnitTemplate.defence.health.regen = 10\r\nUnitTemplate.defence.health.value = 45000\r\nUnitTemplate.economy.buildTime = 15750\r\nUnitTemplate.economy.cost.alloys = 21000\r\nUnitTemplate.economy.cost.energy = 260000\r\nUnitTemplate.economy.maintenanceConsumption = { energy = 250 }\r\nUnitTemplate.intel = UnitTemplate.intel or {}\r\nUnitTemplate.intel.visionRadius = 32\r\n-- Authored provenance; this Sanctuary build currently ignores the\r\n-- separate water-vision field during HostUnit intel setup.\r\nUnitTemplate.intel.waterVisionRadius = 32\r\n\r\n-- A001's raw timeline was played at 3.5x for FA's 2.5 movement speed.\r\n-- Keep that exact animation-to-motion ratio as the source speed is\r\n-- restored below.\r\nlocal monkeylordAuthoredSpeed = 0.7142857142857143\r\nUnitTemplate.movement.acceleration = 2.5\r\nUnitTemplate.movement.rotationSpeed = 25\r\nUnitTemplate.movement.speed = 2.5\r\n-- URL0402 is fully amphibious in FA.  Sanctuary documents\r\n-- LegsAmphibious, but its active navigation and AI layer maps do not\r\n-- currently route that type.  Retain the existing supported\r\n-- LegsSeabed mode until that engine-level route can be tested rather\r\n-- than silently creating an unknown movement class.\r\nUnitTemplate.movement.walkAnimation = UnitTemplate.movement.walkAnimation or {}\r\nUnitTemplate.movement.walkAnimation.authoredSpeed = monkeylordAuthoredSpeed\r\nUnitTemplate.visuals.animations = UnitTemplate.visuals.animations or {}\r\nUnitTemplate.visuals.animations.walk = {\r\n    sanAnimationPath = \"Units/ugl4001/LOD0/ugl4001.sananimation\",\r\n    clipName = \"AnimWalk01\",\r\n    authoredSpeed = monkeylordAuthoredSpeed,\r\n}\r\n\r\n-- Aactivate is held at frame zero during construction, then played once.\r\n-- These source clips use time, never movement velocity, to advance.\r\nUnitTemplate.visuals.animations.construction = {\r\n    sanAnimationPath = \"Units/ugl4001/LOD0/ugl4001.sananimation\",\r\n    clipName = \"ConstructionRest\",\r\n    playbackMode = AnimationPlaybackMode.Clamp,\r\n}\r\nUnitTemplate.visuals.animations.activate = {\r\n    sanAnimationPath = \"Units/ugl4001/LOD0/ugl4001.sananimation\",\r\n    clipName = \"AnimActivate\",\r\n    playbackMode = AnimationPlaybackMode.Clamp,\r\n}\r\nUnitTemplate.visuals.animations.death = {\r\n    sanAnimationPath = \"Units/ugl4001/LOD0/ugl4001.sananimation\",\r\n    clipName = \"AnimDeath\",\r\n    playbackMode = AnimationPlaybackMode.Clamp,\r\n}\r\n\r\n-- Authentic-scale mesh bounds are about 5.88 x 4.33 x 6.69 and are\r\n-- forward-offset.  Align its physical, selection, and pathing bounds\r\n-- to the replacement model while retaining the stock 8x8 build skirt.\r\nUnitTemplate.collisionInfo = {\r\n    centerOffset = {\r\n        x = 0,\r\n        y = 2.15,\r\n        z = 0.66,\r\n    },\r\n    collisionSize = {\r\n        x = 6.0,\r\n        y = 4.4,\r\n        z = 6.8,\r\n    },\r\n    targetBones = {\r\n        \"Center_Turret\",\r\n        \"Left_Turret\",\r\n        \"Right_Turret\",\r\n        \"Left_Leg03_B01\",\r\n        \"Left_Leg01_B01\",\r\n        \"Right_Leg01_B01\",\r\n        \"Right_Leg03_B01\",\r\n    },\r\n}\r\n-- The stock 6.4 x 6.4 occupancy is the reviewed placement contract.\r\n-- The visible replacement's forward extent is handled by its measured\r\n-- collider and selection volume, not an undocumented extra build tile.\r\nUnitTemplate.footprint = { x = 6.4, y = 6.4 }\r\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\r\nUnitTemplate.visuals.selection.size = { x = 6.3, y = 7.1 }\r\nUnitTemplate.visuals.selection.offset = { x = 0, y = 2.15, z = 0.66 }\r\nUnitTemplate.additions = UnitTemplate.additions or {}\r\nUnitTemplate.additions.rotators = {\r\n    {\r\n        boneName = \"Center_Turret_Barrel\",\r\n        -- Fail closed if the host lifecycle appendix is unavailable:\r\n        -- construction may enable this component, but zero speed\r\n        -- keeps the barrel still until the beam state drives it.\r\n        speed = { x = 0, y = 0, z = 0 },\r\n    },\r\n}\r\n-- unitTemplateLoader consumes this opt-in box instead of inflating the\r\n-- visible bracket by 30 percent for click/selection collision.\r\nUnitTemplate.additions.selectionHit = {\r\n    size = { x = 6.3, y = 7.1 },\r\n    offset = { x = 0, y = 2.15, z = 0.66 },\r\n}\r\n\r\n-- The former Guard exhaust bone does not exist on URL0402.  The stock\r\n-- death effect is already attached to Root and remains unchanged.\r\nUnitTemplate.visuals.effectsPersistent = nil\r\n\r\nif not UnitTemplate.weapons or not UnitTemplate.weapons[1] then\r\n    error(\"UGL4001 Monkeylord override requires the stock primary beam weapon.\")\r\nend\r\n\r\n-- URL0402's Heavy Microwave Laser is one continuous beam: 800 damage\r\n-- every other 0.1 s simulation tick, range 4..30, ROF 3, and one\r\n-- central muzzle.  The scoped HostBeam cadence below preserves the\r\n-- authored 800-per-hit / 4,000-DPS contract.\r\nUnitTemplate.weapons[1].beamLifetime = -1\r\nUnitTemplate.weapons[1].damage = 800\r\nUnitTemplate.weapons[1].damageFriendly = false\r\nUnitTemplate.weapons[1].damageRadius = 0.5\r\nUnitTemplate.weapons[1].damageType = \"Normal\"\r\n-- The Guard donor's plasma muzzle, audio, and PGD471 endpoint are not\r\n-- URL0402 effects.  Remove the first two and route ClientBeam through\r\n-- a stock projectile with no onImpactEffects instead of displaying a\r\n-- confidently wrong plasma impact while the FA emitter graph remains\r\n-- unsupported by Sanctuary's current beam client.\r\nUnitTemplate.weapons[1].audio = nil\r\nUnitTemplate.weapons[1].effects = nil\r\nUnitTemplate.weapons[1].projectileTemplate = \"pxd003\"\r\nUnitTemplate.weapons[1].rangeMax = 30\r\nUnitTemplate.weapons[1].rangeMin = 4\r\nUnitTemplate.weapons[1].reloadTime = 0.3333333333333333\r\nUnitTemplate.weapons[1].layerTargetLimits = {\r\n    \"Land\", \"WaterSurface\", \"Seabed\",\r\n}\r\nUnitTemplate.weapons[1].layerWeaponLimits = { \"Land\", \"Seabed\" }\r\nUnitTemplate.weapons[1].targetWaterLimits = \"Above\"\r\nUnitTemplate.weapons[1].scoAboveWaterFireOnly = true\r\nUnitTemplate.weapons[1].scoAboveWaterTargetsOnly = true\r\nUnitTemplate.weapons[1].scoMonkeylordWaterGate = \"Above\"\r\nUnitTemplate.weapons[1].scoMonkeylordMicrowave = {\r\n    collisionTicks = 2,\r\n    damageRadius = 0.5,\r\n    sliderBone = \"Center_Turret_Barrel\",\r\n    sliderFireSpeed = 1,\r\n    sliderGoal = -1,\r\n    sliderReturnSpeed = 2,\r\n    spinBone = \"Center_Turret_Barrel\",\r\n    spinSpeed = 180,\r\n}\r\nUnitTemplate.weapons[1].beam = {\r\n    subMesh = {\r\n        {\r\n            model = \"VFX/SupremeCommanderOverhaul/Models/Monkeylord/monkeylord_microwave_beam.sanmodel\",\r\n            material = \"VFX/SupremeCommanderOverhaul/Materials/Monkeylord/monkeylord_microwave_beam.sanmaterial\",\r\n        },\r\n    },\r\n    fadeInTime = 0,\r\n    fadeOutTime = 0,\r\n    cullDistance = 400,\r\n}\r\nUnitTemplate.weapons[1].aimControllers = {\r\n    {\r\n        aimBone = \"Center_Turret_Muzzle\",\r\n        aimTolerance = 2,\r\n        defaultPitchAdjustment = -20,\r\n        defaultYawAdjustment = 0,\r\n        leadTarget = false,\r\n        pitchBone = \"Center_Turret\",\r\n        pitchMax = 70,\r\n        pitchMin = -110,\r\n        pitchSpeed = 20,\r\n        poseResetTime = 3,\r\n        projectileSpeed = 30,\r\n        solverType = \"NoArc\",\r\n        yawBone = \"Center_Turret\",\r\n        yawMax = 180,\r\n        yawMin = -180,\r\n        yawSpeed = 40,\r\n    },\r\n}\r\nUnitTemplate.weapons[1].muzzleGroups = {\r\n    {\r\n        muzzles = {\r\n            \"Center_Turret_Muzzle\",\r\n        },\r\n    },\r\n}\r\nUnitTemplate.weapons[1].muzzles = {\r\n    [\"Center_Turret_Muzzle\"] = {\r\n        aimController = \"Center_Turret_Muzzle\",\r\n    },\r\n}\r\nlocal monkeylordMicrowave = UnitTemplate.weapons[1]\r\nlocal monkeylordDeathWeapon = UnitTemplate.weapons[2]\r\nif not monkeylordDeathWeapon\r\n    or monkeylordDeathWeapon.category ~= \"DeathExplosion\"\r\nthen\r\n    error(\"UGL4001 Monkeylord override requires the stock death weapon.\")\r\nend\r\nmonkeylordDeathWeapon.category = \"DeathExplosion\"\r\nmonkeylordDeathWeapon.damage = 4000\r\nmonkeylordDeathWeapon.damageFriendly = true\r\nmonkeylordDeathWeapon.damageRadius = 7\r\nmonkeylordDeathWeapon.damageType = \"Normal\"\r\n\r\nlocal function SCO_MonkeylordAim(\r\n    aimBone, yawBone, pitchBone,\r\n    defaultPitch, pitchRange, pitchSpeed,\r\n    defaultYaw, yawRange, yawSpeed,\r\n    projectileSpeed, leadTarget)\r\n    return {\r\n        aimBone = aimBone,\r\n        aimTolerance = 2,\r\n        defaultPitchAdjustment = defaultPitch,\r\n        defaultYawAdjustment = defaultYaw,\r\n        leadTarget = leadTarget,\r\n        pitchBone = pitchBone,\r\n        pitchMax = defaultPitch + pitchRange,\r\n        pitchMin = defaultPitch - pitchRange,\r\n        pitchSpeed = pitchSpeed,\r\n        poseResetTime = 3,\r\n        projectileSpeed = projectileSpeed,\r\n        solverType = \"NoArc\",\r\n        yawBone = yawBone,\r\n        yawMax = defaultYaw + yawRange,\r\n        yawMin = defaultYaw - yawRange,\r\n        yawSpeed = yawSpeed,\r\n    }\r\nend\r\n\r\nlocal function SCO_MonkeylordMuzzleMap(controller, names)\r\n    local result = {}\r\n    for _, name in ipairs(names) do\r\n        result[name] = { aimController = controller }\r\n    end\r\n    return result\r\nend\r\n\r\nlocal function SCO_MonkeylordBolter(\r\n    muzzle, yawBone, pitchBone,\r\n    defaultPitch, pitchRange, defaultYaw, headingArc)\r\n    local weapon = {\r\n        aimControllers = {\r\n            SCO_MonkeylordAim(\r\n                muzzle, yawBone, pitchBone,\r\n                defaultPitch, pitchRange, 90,\r\n                defaultYaw, 90, 90,\r\n                35, true),\r\n        },\r\n        collideFriendly = false,\r\n        damage = 150,\r\n        damageFriendly = false,\r\n        damageRadius = 0,\r\n        damageType = \"Normal\",\r\n        effects = {\r\n            onFire = \"VFX/Muzzle/vgm1281_cannon_plasma_medium_muzzle.sanvfx\",\r\n        },\r\n        firingRandomness = 0,\r\n        layerTargetLimits = { \"Land\", \"WaterSurface\", \"Seabed\" },\r\n        layerWeaponLimits = { \"Land\", \"Seabed\" },\r\n        muzzleGroupChargeDelay = 0,\r\n        muzzleGroupTimeOut = -1,\r\n        muzzleGroups = { { muzzles = { muzzle } } },\r\n        muzzles = SCO_MonkeylordMuzzleMap(muzzle, { muzzle }),\r\n        muzzleSalvoDelay = 0,\r\n        muzzleSalvoSize = 1,\r\n        projectileLifetime = 2.1028571428571428,\r\n        projectileTemplate = \"pgr402b\",\r\n        rangeMax = 64,\r\n        rangeMin = 0,\r\n        rangeRingType = \"DirectFire\",\r\n        rangeTracking = 1.15,\r\n        reloadTime = 0.6666666666666666,\r\n    }\r\n    if headingArc then\r\n        weapon.scoMonkeylordHeadingArc = {\r\n            center = headingArc.center,\r\n            range = headingArc.range,\r\n        }\r\n    end\r\n    return weapon\r\nend\r\n\r\nlocal function SCO_MonkeylordNanite(side)\r\n    local first = side .. \"_Projectile01\"\r\n    local second = side .. \"_Projectile02\"\r\n    return {\r\n        aimControllers = {\r\n            SCO_MonkeylordAim(\r\n                first, first, first,\r\n                0, 0, 0,\r\n                0, 0, 0,\r\n                30, false),\r\n        },\r\n        collideFriendly = false,\r\n        damage = 40,\r\n        damageFriendly = false,\r\n        damageRadius = 0,\r\n        damageType = \"Normal\",\r\n        firingRandomness = 0,\r\n        layerTargetLimits = { \"Air\" },\r\n        layerWeaponLimits = { \"Land\" },\r\n        muzzleGroupChargeDelay = 0,\r\n        muzzleGroupTimeOut = -1,\r\n        -- ProjectilesPerOnFire=2: both native rack endpoints fire in\r\n        -- one Sanctuary muzzle group, once per two-second reload.\r\n        muzzleGroups = { { muzzles = { first, second } } },\r\n        muzzles = SCO_MonkeylordMuzzleMap(first, { first, second }),\r\n        muzzleSalvoDelay = 0,\r\n        muzzleSalvoSize = 1,\r\n        projectileLifetime = 7,\r\n        projectileTemplate = \"pgr402a\",\r\n        rangeMax = 64,\r\n        rangeMin = 0,\r\n        rangeRingType = \"AntiAir\",\r\n        rangeTracking = 1.15,\r\n        reloadTime = 2,\r\n        targetWaterLimits = \"Above\",\r\n    }\r\nend\r\n\r\nlocal torpedoMuzzles = {\r\n    \"Right_Projectile01\",\r\n    \"Right_Projectile02\",\r\n    \"Left_Projectile01\",\r\n    \"Left_Projectile02\",\r\n}\r\nlocal monkeylordTorpedo = {\r\n    aimControllers = {\r\n        SCO_MonkeylordAim(\r\n            \"Right_Projectile01\",\r\n            \"Right_Projectile01\",\r\n            \"Right_Projectile01\",\r\n            0, 0, 0,\r\n            0, 0, 0,\r\n            5, false),\r\n    },\r\n    collideFriendly = false,\r\n    damage = 50,\r\n    damageFriendly = false,\r\n    damageRadius = 0,\r\n    damageType = \"Normal\",\r\n    firingRandomness = 0,\r\n    layerTargetLimits = { \"Seabed\", \"Water\" },\r\n    layerWeaponLimits = { \"Seabed\" },\r\n    muzzleGroupChargeDelay = 0,\r\n    muzzleGroupTimeOut = -1,\r\n    -- FA ProjectilesPerOnFire=1 cycles the four authored rack bones;\r\n    -- separate Sanctuary groups avoid firing four torpedoes at once.\r\n    muzzleGroups = {\r\n        { muzzles = { \"Right_Projectile01\" } },\r\n        { muzzles = { \"Right_Projectile02\" } },\r\n        { muzzles = { \"Left_Projectile01\" } },\r\n        { muzzles = { \"Left_Projectile02\" } },\r\n    },\r\n    muzzles = SCO_MonkeylordMuzzleMap(\r\n        \"Right_Projectile01\", torpedoMuzzles),\r\n    muzzleSalvoDelay = 0,\r\n    muzzleSalvoSize = 1,\r\n    projectileLifetime = 9,\r\n    projectileTemplate = \"pgr402t\",\r\n    rangeMax = 45,\r\n    rangeMin = 0,\r\n    rangeRingType = \"AntiNavy\",\r\n    rangeTracking = 1.15,\r\n    reloadTime = 4,\r\n    targetWaterLimits = \"Below\",\r\n    scoMonkeylordWaterGate = \"Below\",\r\n}\r\n\r\nUnitTemplate.weapons = {\r\n    monkeylordMicrowave,\r\n    SCO_MonkeylordBolter(\r\n        \"Right_Turret_Muzzle\",\r\n        \"Right_Turret\",\r\n        \"Right_Turret_Barrel\",\r\n        -10, 45, -45, nil),\r\n    SCO_MonkeylordBolter(\r\n        \"Left_Turret_Muzzle\",\r\n        \"Left_Turret\",\r\n        \"Left_Turret_Barrel\",\r\n        -10, 90, 45, { center = 45, range = 90 }),\r\n    SCO_MonkeylordNanite(\"Right\"),\r\n    SCO_MonkeylordNanite(\"Left\"),\r\n    monkeylordTorpedo,\r\n    monkeylordDeathWeapon,\r\n}\r\n\r\n-- Current Sanctuary limitations retained explicitly: no FA source\r\n-- emitter/audio graph importer, no EffectiveRadius/TargetCheckInterval,\r\n-- no PrefersPrimaryWeaponTarget or HOVER category reject, and no native\r\n-- sonar/sonar-stealth entity lifecycle. Nanite's late random acceleration\r\n-- and zig-zag, torpedo StayUnderwater, and DestroyOnWater transition\r\n-- semantics are likewise unavailable in the current projectile schema.";

	private const string HostClassAppendix = "\r\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\r\nlocal SCO_MonkeylordLayers = Import(\"common/layers.lua\")\r\nlocal SCO_MonkeylordStockGuardUpdateAnimations =\r\n    HostGuardLandUnit.UpdateAnimations\r\nHostGuardMonkeylord = Class(\"GuardMonkeylord\", HostGuardLandUnit)\r\n\r\nfunction HostGuardMonkeylord:RotatorsEnabledOnConstruction()\r\n    -- The microwave barrel starts only when its persistent beam does.\r\n    return false\r\nend\r\n\r\nlocal SCO_MonkeylordActivationDuration = 4.333333492279053\r\nlocal SCO_MonkeylordDeathDuration = 5.666666507720947\r\n\r\nfunction HostGuardMonkeylord:SetupAnimations()\r\n    HostGuardLandUnit.SetupAnimations(self)\r\n    if not self:IsCompleted() then\r\n        self.scoMonkeylordAnimationPhase = \"construction\"\r\n        self:SetAnimatorEnabled(true)\r\n        Engine.PlayAnimation(self.id, self.tp.visuals.animations.construction.id, 0)\r\n    end\r\nend\r\n\r\nfunction HostGuardMonkeylord:RestoreLocomotionAnimation()\r\n    self.scoMonkeylordAnimationPhase = \"ready\"\r\n    self.isWalking = true\r\n    Engine.PlayAnimation(self.id, self.tp.visuals.animations.walk.id, 0.1)\r\n    self:UpdateAnimations()\r\nend\r\n\r\nfunction HostGuardMonkeylord:CancelActivationThread()\r\n    self.scoMonkeylordAnimationGeneration =\r\n        (self.scoMonkeylordAnimationGeneration or 0) + 1\r\n    if self.scoMonkeylordActivationThread then\r\n        KillThread(self.scoMonkeylordActivationThread)\r\n        self.scoMonkeylordActivationThread = nil\r\n    end\r\nend\r\n\r\nfunction HostGuardMonkeylord:ActivationThread(generation)\r\n    WaitSeconds(SCO_MonkeylordActivationDuration)\r\n    if self.dead or self.deleted\r\n        or self.scoMonkeylordAnimationGeneration ~= generation\r\n        or self.scoMonkeylordAnimationPhase ~= \"activating\"\r\n    then\r\n        return\r\n    end\r\n    self.scoMonkeylordActivationThread = nil\r\n    self:RestoreLocomotionAnimation()\r\nend\r\n\r\nfunction HostGuardMonkeylord:OnStopBeingBuilt()\r\n    if self.dead or self.deleted or self.scoMonkeylordCompletionHandled then return end\r\n    self.scoMonkeylordCompletionHandled = true\r\n    local bypassed = self.bypassedBuildProcess\r\n    HostGuardLandUnit.OnStopBeingBuilt(self)\r\n    local resourceEntities = self.resourceEntities\r\n    local consumption = resourceEntities and resourceEntities.consumption\r\n    if consumption == nil then\r\n        error(\"Monkeylord maintenance resource was not created\")\r\n    end\r\n    consumption:SetEnabled(true)\r\n    if bypassed then\r\n        self:RestoreLocomotionAnimation()\r\n        return\r\n    end\r\n    self.scoMonkeylordAnimationPhase = \"activating\"\r\n    self.scoMonkeylordAnimationGeneration =\r\n        (self.scoMonkeylordAnimationGeneration or 0) + 1\r\n    self:UpdateAnimations()\r\n    if self.scoMonkeylordAnimationPhase ~= \"activating\" then return end\r\n    Engine.PlayAnimation(self.id, self.tp.visuals.animations.activate.id, 0.1)\r\n    self.scoMonkeylordActivationThread = self:NewThread(\r\n        self.ActivationThread, self.scoMonkeylordAnimationGeneration)\r\nend\r\n\r\nfunction HostGuardMonkeylord:UpdateAnimations()\r\n    -- URL0402's source layer callback enables its torpedo only on the\r\n    -- seabed. Sanctuary weapon masks consume targetingLayer directly,\r\n    -- so derive that layer from the current water/terrain contract.\r\n    if not self.dead then\r\n        local targetLayer = SCO_MonkeylordLayers.TargetingLayer.Land\r\n        local waterResult, hasWater = Engine.HasWater()\r\n        if waterResult == EngineErrorCode.Success and hasWater then\r\n            local levelResult, waterLevel = Engine.GetWaterLevel()\r\n            local position = self:GetPosition()\r\n            if levelResult == EngineErrorCode.Success\r\n                and waterLevel ~= nil\r\n                and position ~= nil\r\n            then\r\n                local terrainResult, terrainHeight =\r\n                    Engine.SampleTerrainHeight(position)\r\n                if terrainResult == EngineErrorCode.Success\r\n                    and terrainHeight < waterLevel - 0.05\r\n                    and position.y < waterLevel - 0.05\r\n                then\r\n                    targetLayer =\r\n                        SCO_MonkeylordLayers.TargetingLayer.Seabed\r\n                end\r\n            end\r\n        end\r\n        if self.targetingLayer ~= targetLayer then\r\n            self:SetTargetingLayer(targetLayer)\r\n        end\r\n    end\r\n    if self.dead or self.scoMonkeylordAnimationPhase == \"construction\" then return end\r\n    if self.scoMonkeylordAnimationPhase == \"activating\" then\r\n        -- Completion already enabled native movement and weapons. Yield the\r\n        -- deploy pose when either takes ownership, instead of sliding the rig.\r\n        local speedResult, speed = Engine.GetMovementSpeed(self.id)\r\n        local active = speedResult == EngineErrorCode.Success and speed > 0\r\n        if not active then\r\n            for _, weapon in ipairs(self.weapons or {}) do\r\n                local target = weapon:GetAimTarget()\r\n                if weapon:IsEnabled() and target and not target.dead and not target.deleted then\r\n                    active = true\r\n                    break\r\n                end\r\n            end\r\n        end\r\n        if not active then return end\r\n        self:CancelActivationThread()\r\n        return self:RestoreLocomotionAnimation()\r\n    end\r\n    return SCO_MonkeylordStockGuardUpdateAnimations(self)\r\nend\r\n\r\nfunction HostGuardMonkeylord:OnDestroy(destroyType)\r\n    self.scoMonkeylordDeathAnimationPending = self:IsCompleted()\r\n        and not self:IsPlacementGhost()\r\n        and (destroyType == DestroyType.Kinetic or destroyType == DestroyType.Unspecified)\r\n    self.scoMonkeylordAnimationPhase = \"dead\"\r\n    self:CancelActivationThread()\r\n    self:SetRotatorsEnabled(false)\r\n    -- The native unit updater retains dead units until Delete. Quiesce before\r\n    -- native deletion so neither it nor aim controllers touch deleted weapons.\r\n    for _, weapon in ipairs(self.weapons or {}) do\r\n        weapon:SetEnabled(false)\r\n        weapon:SetAimTarget(nil)\r\n    end\r\n    local result = HostGuardLandUnit.OnDestroy(self, destroyType)\r\n    self.weapons = {}\r\n    return result\r\nend\r\n\r\nfunction HostGuardMonkeylord:DeathThread(overkillRatio)\r\n    if not self.scoMonkeylordDeathAnimationPending then\r\n        return HostGuardLandUnit.DeathThread(self, overkillRatio)\r\n    end\r\n    self.scoMonkeylordDeathAnimationPending = nil\r\n    self.scoMonkeylordAnimationPhase = \"dying\"\r\n    -- Native OnDestroy has already ended combat, economy and targeting.\r\n    Engine.SetMovementEnabled(self.id, false)\r\n    Engine.SetMovementCollisionMask(self.id, 0)\r\n    self:SetAnimatorEnabled(true)\r\n    Engine.PlayAnimation(self.id, self.tp.visuals.animations.death.id, 0.1)\r\n    WaitSeconds(SCO_MonkeylordDeathDuration)\r\n    if not self.deleted then\r\n        -- Keep native fraction/overkill/wreck rules; only defer their execution.\r\n        return HostGuardLandUnit.DeathThread(self, overkillRatio)\r\n    end\r\nend";

	private const string ClientClassAppendix = "\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\nClientGuardMonkeylord = Class(\"GuardMonkeylord\", ClientGuardLandUnit)";

	private const string HostWeaponAppendix = "\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\nlocal SCO_MonkeylordStockCanShootAt = HostWeapon.CanShootAt\n\nlocal function SCO_MonkeylordPassesWaterGate(weapon, target)\n    local gate = weapon.tp and weapon.tp.scoMonkeylordWaterGate\n    if gate == nil then return true end\n\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return gate == \"Above\" end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then\n        return false\n    end\n    local ownerPosition = weapon.unit and weapon.unit:GetPosition()\n    local targetPosition = target and target:GetPosition()\n    if ownerPosition == nil or targetPosition == nil then return false end\n    local margin = 0.05\n    if gate == \"Above\" then\n        return ownerPosition.y >= waterLevel - margin\n            and targetPosition.y >= waterLevel - margin\n    elseif gate == \"Below\" then\n        return ownerPosition.y < waterLevel - margin\n            and targetPosition.y < waterLevel - margin\n    end\n    return false\nend\n\nlocal function SCO_MonkeylordNormalizeHeading(value)\n    return (value + 180) % 360 - 180\nend\n\nlocal function SCO_MonkeylordPassesHeadingArc(weapon, target)\n    local arc = weapon.tp and weapon.tp.scoMonkeylordHeadingArc\n    if arc == nil then return true end\n    local ownerPosition = weapon.unit and weapon.unit:GetPosition()\n    local targetPosition = target and target:GetPosition()\n    if ownerPosition == nil or targetPosition == nil then return false end\n    local deltaX = targetPosition.x - ownerPosition.x\n    local deltaZ = targetPosition.z - ownerPosition.z\n    if deltaX == 0 and deltaZ == 0 then return true end\n    local yawResult, ownerYaw = Engine.GetMovementYaw(weapon.unit.id)\n    if yawResult ~= EngineErrorCode.Success or ownerYaw == nil then\n        return false\n    end\n    local targetHeading = math.deg(math.atan2(deltaX, deltaZ))\n    local relativeHeading = SCO_MonkeylordNormalizeHeading(\n        targetHeading - ownerYaw - arc.center)\n    return math.abs(relativeHeading) <= arc.range\nend\n\nfunction HostWeapon:CanShootAt(target)\n    return SCO_MonkeylordStockCanShootAt(self, target)\n        and SCO_MonkeylordPassesWaterGate(self, target)\n        and SCO_MonkeylordPassesHeadingArc(self, target)\nend";

	private const string ImportScannerAppendix = "\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\nlocal SCO_MonkeylordScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_MonkeylordScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n    local monkeylordFolders = {\n        directory .. \"pgr402b\",\n        directory .. \"pgr402a\",\n        directory .. \"pgr402t\",\n    }\n    for _, monkeylordFolder in ipairs(monkeylordFolders) do\n        local found = false\n        for _, folder in ipairs(folders) do\n            if folder == monkeylordFolder then\n                found = true\n                break\n            end\n        end\n        if not found then table.insert(folders, monkeylordFolder) end\n    end\n    return folders\nend";

	private const string HostBeamAppendix = "\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\nlocal scoMonkeylordStockBeamInit = HostBeam.__init\nlocal scoMonkeylordStockSetBeamEnabled = HostBeam.SetBeamEnabled\nlocal scoMonkeylordStockBeamUpdate = HostBeam.Update\nlocal scoMonkeylordCollisionUpdate =\n    Import(\"host/collisionUpdate.lua\")\nlocal scoMonkeylordUnits = __Entities.Units\nlocal scoMonkeylordShields = __Entities.Shields\n\nfunction HostBeam:__init(id, boneName, unit, weaponTemplate)\n    scoMonkeylordStockBeamInit(self, id, boneName, unit, weaponTemplate)\n    self.scoMonkeylordMicrowave =\n        weaponTemplate.scoMonkeylordMicrowave\n    if self.scoMonkeylordMicrowave\n        and ((self.scoMonkeylordMicrowave.damageRadius or 0) <= 0\n            or (self.scoMonkeylordMicrowave.collisionTicks or 0) < 1)\n    then\n        error(\"Monkeylord microwave radius/cadence must be positive\")\n    end\n    self.scoMonkeylordCollisionTicksRemaining = 0\nend\n\nfunction HostBeam:SetBeamEnabled(enabled, sendCommand)\n    scoMonkeylordStockSetBeamEnabled(self, enabled, sendCommand)\n    local config = self.scoMonkeylordMicrowave\n    if config == nil\n        or self.scoMonkeylordSpinActive == enabled\n    then\n        return\n    end\n    self.scoMonkeylordCollisionTicksRemaining = 0\n    if self.scoMonkeylordSpinBone == nil then\n        self.scoMonkeylordSpinBone =\n            self.unit:GetBoneId(config.spinBone)\n        if self.scoMonkeylordSpinBone == nil then\n            error(\"Monkeylord microwave spin bone is missing\")\n        end\n    end\n    self.scoMonkeylordSpinActive = enabled\n    Engine.SetRotatorSpeed(\n        self.scoMonkeylordSpinBone,\n        EngineClasses.float3(0, 0, config.spinSpeed))\n    Engine.SetRotatorEnabled(\n        self.scoMonkeylordSpinBone,\n        enabled)\nend\n\nfunction HostBeam:Update()\n    local config = self.scoMonkeylordMicrowave\n    if config == nil then\n        return scoMonkeylordStockBeamUpdate(self)\n    end\n    if not self.enabled then\n        return\n    end\n    if self.scoMonkeylordCollisionTicksRemaining > 0 then\n        self.scoMonkeylordCollisionTicksRemaining =\n            self.scoMonkeylordCollisionTicksRemaining - 1\n        return\n    end\n    self.scoMonkeylordCollisionTicksRemaining =\n        config.collisionTicks - 1\n\n    local _, origin = Engine.GetGlobalEntityWorldPosition(self.id)\n    local _, forward = Engine.GetGlobalEntityForwardDirection(self.id)\n    local collisions = Engine.RayCast(\n        CollisionWorld.Collision,\n        origin,\n        forward,\n        self.rangeMax,\n        CollisionLayer.Shields + CollisionLayer.Units)\n    local army = self.unit.army\n    local radius = config.damageRadius or 0\n\n    for _, collision in ipairs(collisions) do\n        if collision.otherGlobalID.index == 0 then\n            if radius > 0 then\n                scoMonkeylordCollisionUpdate.ProcessAreaDamage(\n                    collision.hitPosition,\n                    radius,\n                    self.damage,\n                    army,\n                    false,\n                    self.unit)\n            end\n            return\n        end\n\n        if Engine.IsValidGlobalID(collision.otherGlobalID) then\n            local unit =\n                scoMonkeylordUnits[collision.otherGlobalID.index]\n            local shield =\n                scoMonkeylordShields[collision.otherGlobalID.index]\n            if unit and army:IsEnemy(unit.army) then\n                scoMonkeylordCollisionUpdate.ProcessAreaDamage(\n                    collision.hitPosition,\n                    radius,\n                    self.damage,\n                    army,\n                    false,\n                    self.unit)\n                return\n            end\n            if shield\n                and shield.enabled\n                and army:IsEnemy(shield.army)\n            then\n                scoMonkeylordCollisionUpdate.ProcessAreaDamage(\n                    collision.hitPosition,\n                    radius,\n                    self.damage,\n                    army,\n                    false,\n                    self.unit)\n                return\n            end\n        end\n    end\nend";

	private const string ClientBeamAppendix = "\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\nlocal scoMonkeylordStockClientBeamInit = ClientBeam.__init\nlocal scoMonkeylordStockClientBeamSetEnabled = ClientBeam.SetBeamEnabled\nlocal scoMonkeylordStockClientBeamRenderUpdate = ClientBeam.RenderUpdate\n\nfunction ClientBeam:__init(submeshes, muzzle)\n    scoMonkeylordStockClientBeamInit(self, submeshes, muzzle)\n    local config = self.muzzle.weapon.tp.scoMonkeylordMicrowave\n    self.scoMonkeylordSliderConfig = config\n    if config == nil then\n        return\n    end\n\n    local sliderId = self.muzzle.weapon.unit:GetBoneId(config.sliderBone)\n    if sliderId == nil or not Engine.IsValidLocalID(sliderId) then\n        error(\"Monkeylord microwave slider bone is missing\")\n    end\n    local base = EngineClasses.float3()\n    local result = Engine.GetLocalEntityLocalPosition(sliderId, base)\n    if result ~= EngineErrorCode.Success then\n        error(\"Monkeylord microwave slider bind position is unavailable\")\n    end\n    self.scoMonkeylordSliderId = sliderId\n    self.scoMonkeylordSliderBase = EngineClasses.float3(base.x, base.y, base.z)\n    self.scoMonkeylordSliderOffset = 0\n    self.scoMonkeylordSliderTarget = 0\n    self.scoMonkeylordSliderLastTime = _G.Time\nend\n\nfunction ClientBeam:SetBeamEnabled(enabled)\n    scoMonkeylordStockClientBeamSetEnabled(self, enabled)\n    local config = self.scoMonkeylordSliderConfig\n    if config == nil then\n        return\n    end\n    self.scoMonkeylordSliderTarget = enabled and config.sliderGoal or 0\n    self.scoMonkeylordSliderLastTime = _G.Time\nend\n\nlocal function scoMonkeylordMoveToward(current, target, distance)\n    local delta = target - current\n    if math.abs(delta) <= distance then\n        return target\n    end\n    return current + (delta < 0 and -distance or distance)\nend\n\nfunction ClientBeam:RenderUpdate()\n    scoMonkeylordStockClientBeamRenderUpdate(self)\n    local config = self.scoMonkeylordSliderConfig\n    if config == nil then\n        return\n    end\n\n    local now = _G.Time\n    local elapsed = math.max(now - self.scoMonkeylordSliderLastTime, 0)\n    self.scoMonkeylordSliderLastTime = now\n    local speed = self.enabled\n        and config.sliderFireSpeed\n        or config.sliderReturnSpeed\n    self.scoMonkeylordSliderOffset = scoMonkeylordMoveToward(\n        self.scoMonkeylordSliderOffset,\n        self.scoMonkeylordSliderTarget,\n        speed * elapsed)\n    local base = self.scoMonkeylordSliderBase\n    local result = Engine.SetLocalEntityLocalPosition(\n        self.scoMonkeylordSliderId,\n        EngineClasses.float3(\n            base.x,\n            base.y,\n            base.z + self.scoMonkeylordSliderOffset))\n    if result ~= EngineErrorCode.Success then\n        error(\"Monkeylord microwave slider update failed\")\n    end\nend";

	private static string ProjectileRelativePath(string id)
	{
		return "LJ/lua/common/projectiles/projectilesTemplates/" + id + "/" + id + ".santp";
	}

	private static string BuildVirtualProjectile(ProjectileSpec projectile)
	{
		string text = ((projectile.Movement == null) ? string.Empty : ("    " + projectile.Movement + "\n"));
		string text2 = ((projectile.ImpactVfx == null) ? string.Empty : ("        onImpactEffects = {\n            { effects = { { particleName = \"" + projectile.ImpactVfx + "\" } } },\n        },"));
		return "---@type ProjectileTemplate\nProjectileTemplate = {\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"" + projectile.Name + "\",\n        tpId = \"" + projectile.Id + "\",\n    },\n" + text + "    nonUniformScale = { x = 1, y = 1, z = 1 },\n    visuals = {\n        mesh = { lod0distance = 60 },\n" + text2 + "\n        persistantEffects = {\n            { effects = { { particleName = \"" + projectile.TrailVfx + "\" } } },\n        },\n    },\n}\n\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\n-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\n-- Source ID: " + projectile.SourceId + "\n-- Source blueprint: " + projectile.SourceBlueprintPath + "\n-- Source blueprint SHA-256: " + projectile.SourceBlueprintSha256 + "\n-- Source script: " + projectile.SourceScriptPath + "\n-- Source script SHA-256: " + projectile.SourceScriptSha256 + "\n-- Native Guard VFX archive SHA-256: 86c43f27b3ff9189a82f8201eec020d18c0770568a862b034737cd17424a357c\n-- Sanctuary limitation: " + projectile.Limitation + "\n-- The FA emitter/audio graph is not a supported sanvfx input; these are\n-- verified native Guard-family effects and never route through Aeon assets.";
	}

	public static void Apply()
	{
		ValidatePinnedScope();
		object obj = null;
		List<PatchResource> list = new List<PatchResource>();
		bool flag = false;
		try
		{
			obj = GetLuaFileCache();
			PatchSpec[] array = CreatePatchSpecs();
			ValidateTransactionState(obj, (IReadOnlyCollection<PatchSpec>)(object)array);
			PatchSpec[] array2 = array;
			foreach (PatchSpec patchSpec in array2)
			{
				string text2;
				PatchResource patchResource;
				if (TryGetResource(obj, patchSpec, out PatchResource resource))
				{
					object obj2 = resource.Stock ?? throw new InvalidOperationException("Cached " + patchSpec.Description + " unexpectedly has no stock bytes.");
					string text = Encoding.UTF8.GetString(GetNativeArrayBytes(obj2.GetType(), obj2));
					if (text.IndexOf(patchSpec.Marker, StringComparison.Ordinal) >= 0)
					{
						ValidatePatchedResource(patchSpec, text);
						continue;
					}
					if (text.IndexOf("-- Guard Cybran Monkeylord Cache Patcher 1.3.0", StringComparison.Ordinal) >= 0 || text.IndexOf("-- Guard Cybran Monkeylord Cache Patcher 1.2.0", StringComparison.Ordinal) >= 0)
					{
						throw new InvalidOperationException("A legacy in-memory Monkeylord override is active; restart before applying 1.4.0.");
					}
					if (patchSpec.VirtualSource != null)
					{
						throw new InvalidOperationException("Reserved Monkeylord projectile path is owned by another source: " + patchSpec.RelativePath);
					}
					ValidateStockResource(patchSpec, text);
					text2 = ((patchSpec.Transform == null) ? (text + patchSpec.Appendix) : patchSpec.Transform(text));
					patchResource = resource;
				}
				else
				{
					if (patchSpec.VirtualSource == null)
					{
						throw new FileNotFoundException("Required " + patchSpec.Description + " was not present in Sanctuary's Lua file cache.", patchSpec.RelativePath);
					}
					text2 = patchSpec.VirtualSource;
					patchResource = new PatchResource(patchSpec, ResolvePath(patchSpec.RelativePath), null, added: true);
				}
				ValidatePatchedResource(patchSpec, text2);
				patchResource.Replacement = NativeArrayByteFactory.CreatePersistent(patchResource.Stock?.GetType() ?? GetNativeArrayType(obj), Encoding.UTF8.GetBytes(text2));
				list.Add(patchResource);
			}
			if (list.Count == 0)
			{
				Log("The complete cached Monkeylord weapon-suite transaction is already active.");
				return;
			}
			foreach (PatchResource item2 in list)
			{
				item2.AssignmentWasAttempted = true;
				SetCachedResource(obj, item2.Path, item2.Replacement);
				object cachedResource = GetCachedResource(obj, item2.Path);
				string source = Encoding.UTF8.GetString(GetNativeArrayBytes(cachedResource.GetType(), cachedResource));
				ValidatePatchedResource(item2.Spec, source);
			}
			flag = true;
			foreach (PatchResource item3 in list)
			{
				if (item3.Stock != null)
				{
					TryDisposeNativeArray(item3.Stock.GetType(), item3.Stock, "stock " + item3.Spec.Description);
				}
			}
			Log("Committed the cached Monkeylord template, dedicated host/client class, maintenance/layer lifecycle, scoped beam behavior, and three isolated projectiles. The source suite now includes one microwave laser, two Heavy Electron Bolters, two independent Nanite AA racks, one Meson Torpedo, and the death weapon.");
		}
		catch (Exception ex)
		{
			List<Exception> list2 = new List<Exception>();
			if (!flag && obj != null)
			{
				foreach (PatchResource item4 in list.AsEnumerable().Reverse())
				{
					bool flag2 = !item4.AssignmentWasAttempted;
					if (item4.AssignmentWasAttempted)
					{
						try
						{
							if (item4.Added)
							{
								RemoveCachedResource(obj, item4.Path);
								if (ContainsCachedResource(obj, item4.Path))
								{
									throw new InvalidOperationException("Rollback did not remove " + item4.Spec.Description + ".");
								}
							}
							else
							{
								object obj3 = item4.Stock ?? throw new InvalidOperationException(item4.Spec.Description + " has no rollback stock.");
								SetCachedResource(obj, item4.Path, obj3);
								object cachedResource2 = GetCachedResource(obj, item4.Path);
								if (!GetNativeArrayBytes(cachedResource2.GetType(), cachedResource2).SequenceEqual(GetNativeArrayBytes(obj3.GetType(), obj3)))
								{
									throw new InvalidOperationException("Rollback did not restore " + item4.Spec.Description + ".");
								}
							}
							flag2 = true;
						}
						catch (Exception item)
						{
							list2.Add(item);
						}
					}
					if (flag2 && item4.Replacement != null && IsNativeArrayCreated(item4.Replacement))
					{
						TryDisposeNativeArray(item4.Replacement.GetType(), item4.Replacement, "uncommitted " + item4.Spec.Description + " replacement");
					}
				}
			}
			Exception ex2 = ((list2.Count == 0) ? ex : new AggregateException(new Exception[1] { ex }.Concat(list2)));
			Log("Failed to commit the cached Monkeylord contract" + ((list2.Count == 0) ? " after a complete rollback: " : " with an incomplete rollback: ") + ex2);
			throw new InvalidOperationException("The Monkeylord cache transaction did not commit.", ex2);
		}
	}

	private static void ValidatePinnedScope()
	{
		string[] array = new string[3] { "pgr402b", "pgr402a", "pgr402t" };
		if (Projectiles.Length != array.Length || !Projectiles.Select((ProjectileSpec projectile) => projectile.Id).SequenceEqual<string>(array) || Projectiles.Select((ProjectileSpec projectile) => projectile.Id).Distinct<string>(StringComparer.Ordinal).Count() != array.Length)
		{
			throw new InvalidOperationException("The reviewed URL0402 projectile scope/order changed.");
		}
		ProjectileSpec[] projectiles = Projectiles;
		foreach (ProjectileSpec projectileSpec in projectiles)
		{
			if (projectileSpec.SourceBlueprintSha256.Length != 64 || projectileSpec.SourceScriptSha256.Length != 64 || projectileSpec.TrailVfx.IndexOf("VFX/", StringComparison.Ordinal) != 0 || (projectileSpec.ImpactVfx != null && projectileSpec.ImpactVfx.IndexOf("VFX/", StringComparison.Ordinal) != 0))
			{
				throw new InvalidOperationException(projectileSpec.SourceId + " has an invalid source/VFX contract.");
			}
		}
	}

	private static void ValidateTransactionState(object cache, IReadOnlyCollection<PatchSpec> specs)
	{
		int num = 0;
		foreach (PatchSpec spec in specs)
		{
			if (!TryGetResource(cache, spec, out PatchResource resource))
			{
				if (spec.VirtualSource == null)
				{
					throw new FileNotFoundException("Required " + spec.Description + " was not present in Sanctuary's Lua file cache.", spec.RelativePath);
				}
				continue;
			}
			object obj = resource.Stock ?? throw new InvalidOperationException("Cached " + spec.Description + " unexpectedly has no stock bytes.");
			string text = Encoding.UTF8.GetString(GetNativeArrayBytes(obj.GetType(), obj));
			if (text.IndexOf("-- Guard Cybran Monkeylord Cache Patcher 1.3.0", StringComparison.Ordinal) >= 0 || text.IndexOf("-- Guard Cybran Monkeylord Cache Patcher 1.2.0", StringComparison.Ordinal) >= 0)
			{
				throw new InvalidOperationException("A legacy in-memory Monkeylord override is active; restart before applying 1.4.0.");
			}
			if (text.IndexOf("-- Guard Cybran Monkeylord Cache Patcher 1.4.0", StringComparison.Ordinal) >= 0)
			{
				num++;
			}
		}
		if (num != 0 && num != specs.Count)
		{
			throw new InvalidOperationException($"A partial Monkeylord transaction was found ({num}/{specs.Count} owned resources). " + "Refusing to mix stock and patched weapon-suite resources.");
		}
	}

	private static PatchSpec[] CreatePatchSpecs()
	{
		List<PatchSpec> list = new List<PatchSpec>();
		list.Add(new PatchSpec("LJ/lua/common/units/unitsTemplates/ugl4001/ugl4001.santp", "UGL4001 template", "-- Guard Cybran Monkeylord Cache Patcher 1.4.0", "\r\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\r\n-- The personal pack supplies URL0402 at its authored 0.0725 scale with\r\n-- its complete native rig and A001 walk. The gameplay contract routes\r\n-- the complete source weapon suite through the real URL0402 endpoints.\r\nUnitTemplate.general.displayName = \"Monkeylord\"\r\nUnitTemplate.general.name = \"Monkeylord\"\r\nUnitTemplate.general.class = {\r\n    \"unitsDefaultGuard\",\r\n    \"GuardMonkeylord\",\r\n}\r\n\r\n-- URL0402_unit.bp SHA-256 ce61e4bf...2f1a is the gameplay source.\r\n-- Replace donor balance fields together so a visual port cannot retain\r\n-- the unrelated Guard experimental's health or economy contract.\r\nUnitTemplate.defence.health.max = 45000\r\nUnitTemplate.defence.health.regen = 10\r\nUnitTemplate.defence.health.value = 45000\r\nUnitTemplate.economy.buildTime = 15750\r\nUnitTemplate.economy.cost.alloys = 21000\r\nUnitTemplate.economy.cost.energy = 260000\r\nUnitTemplate.economy.maintenanceConsumption = { energy = 250 }\r\nUnitTemplate.intel = UnitTemplate.intel or {}\r\nUnitTemplate.intel.visionRadius = 32\r\n-- Authored provenance; this Sanctuary build currently ignores the\r\n-- separate water-vision field during HostUnit intel setup.\r\nUnitTemplate.intel.waterVisionRadius = 32\r\n\r\n-- A001's raw timeline was played at 3.5x for FA's 2.5 movement speed.\r\n-- Keep that exact animation-to-motion ratio as the source speed is\r\n-- restored below.\r\nlocal monkeylordAuthoredSpeed = 0.7142857142857143\r\nUnitTemplate.movement.acceleration = 2.5\r\nUnitTemplate.movement.rotationSpeed = 25\r\nUnitTemplate.movement.speed = 2.5\r\n-- URL0402 is fully amphibious in FA.  Sanctuary documents\r\n-- LegsAmphibious, but its active navigation and AI layer maps do not\r\n-- currently route that type.  Retain the existing supported\r\n-- LegsSeabed mode until that engine-level route can be tested rather\r\n-- than silently creating an unknown movement class.\r\nUnitTemplate.movement.walkAnimation = UnitTemplate.movement.walkAnimation or {}\r\nUnitTemplate.movement.walkAnimation.authoredSpeed = monkeylordAuthoredSpeed\r\nUnitTemplate.visuals.animations = UnitTemplate.visuals.animations or {}\r\nUnitTemplate.visuals.animations.walk = {\r\n    sanAnimationPath = \"Units/ugl4001/LOD0/ugl4001.sananimation\",\r\n    clipName = \"AnimWalk01\",\r\n    authoredSpeed = monkeylordAuthoredSpeed,\r\n}\r\n\r\n-- Aactivate is held at frame zero during construction, then played once.\r\n-- These source clips use time, never movement velocity, to advance.\r\nUnitTemplate.visuals.animations.construction = {\r\n    sanAnimationPath = \"Units/ugl4001/LOD0/ugl4001.sananimation\",\r\n    clipName = \"ConstructionRest\",\r\n    playbackMode = AnimationPlaybackMode.Clamp,\r\n}\r\nUnitTemplate.visuals.animations.activate = {\r\n    sanAnimationPath = \"Units/ugl4001/LOD0/ugl4001.sananimation\",\r\n    clipName = \"AnimActivate\",\r\n    playbackMode = AnimationPlaybackMode.Clamp,\r\n}\r\nUnitTemplate.visuals.animations.death = {\r\n    sanAnimationPath = \"Units/ugl4001/LOD0/ugl4001.sananimation\",\r\n    clipName = \"AnimDeath\",\r\n    playbackMode = AnimationPlaybackMode.Clamp,\r\n}\r\n\r\n-- Authentic-scale mesh bounds are about 5.88 x 4.33 x 6.69 and are\r\n-- forward-offset.  Align its physical, selection, and pathing bounds\r\n-- to the replacement model while retaining the stock 8x8 build skirt.\r\nUnitTemplate.collisionInfo = {\r\n    centerOffset = {\r\n        x = 0,\r\n        y = 2.15,\r\n        z = 0.66,\r\n    },\r\n    collisionSize = {\r\n        x = 6.0,\r\n        y = 4.4,\r\n        z = 6.8,\r\n    },\r\n    targetBones = {\r\n        \"Center_Turret\",\r\n        \"Left_Turret\",\r\n        \"Right_Turret\",\r\n        \"Left_Leg03_B01\",\r\n        \"Left_Leg01_B01\",\r\n        \"Right_Leg01_B01\",\r\n        \"Right_Leg03_B01\",\r\n    },\r\n}\r\n-- The stock 6.4 x 6.4 occupancy is the reviewed placement contract.\r\n-- The visible replacement's forward extent is handled by its measured\r\n-- collider and selection volume, not an undocumented extra build tile.\r\nUnitTemplate.footprint = { x = 6.4, y = 6.4 }\r\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\r\nUnitTemplate.visuals.selection.size = { x = 6.3, y = 7.1 }\r\nUnitTemplate.visuals.selection.offset = { x = 0, y = 2.15, z = 0.66 }\r\nUnitTemplate.additions = UnitTemplate.additions or {}\r\nUnitTemplate.additions.rotators = {\r\n    {\r\n        boneName = \"Center_Turret_Barrel\",\r\n        -- Fail closed if the host lifecycle appendix is unavailable:\r\n        -- construction may enable this component, but zero speed\r\n        -- keeps the barrel still until the beam state drives it.\r\n        speed = { x = 0, y = 0, z = 0 },\r\n    },\r\n}\r\n-- unitTemplateLoader consumes this opt-in box instead of inflating the\r\n-- visible bracket by 30 percent for click/selection collision.\r\nUnitTemplate.additions.selectionHit = {\r\n    size = { x = 6.3, y = 7.1 },\r\n    offset = { x = 0, y = 2.15, z = 0.66 },\r\n}\r\n\r\n-- The former Guard exhaust bone does not exist on URL0402.  The stock\r\n-- death effect is already attached to Root and remains unchanged.\r\nUnitTemplate.visuals.effectsPersistent = nil\r\n\r\nif not UnitTemplate.weapons or not UnitTemplate.weapons[1] then\r\n    error(\"UGL4001 Monkeylord override requires the stock primary beam weapon.\")\r\nend\r\n\r\n-- URL0402's Heavy Microwave Laser is one continuous beam: 800 damage\r\n-- every other 0.1 s simulation tick, range 4..30, ROF 3, and one\r\n-- central muzzle.  The scoped HostBeam cadence below preserves the\r\n-- authored 800-per-hit / 4,000-DPS contract.\r\nUnitTemplate.weapons[1].beamLifetime = -1\r\nUnitTemplate.weapons[1].damage = 800\r\nUnitTemplate.weapons[1].damageFriendly = false\r\nUnitTemplate.weapons[1].damageRadius = 0.5\r\nUnitTemplate.weapons[1].damageType = \"Normal\"\r\n-- The Guard donor's plasma muzzle, audio, and PGD471 endpoint are not\r\n-- URL0402 effects.  Remove the first two and route ClientBeam through\r\n-- a stock projectile with no onImpactEffects instead of displaying a\r\n-- confidently wrong plasma impact while the FA emitter graph remains\r\n-- unsupported by Sanctuary's current beam client.\r\nUnitTemplate.weapons[1].audio = nil\r\nUnitTemplate.weapons[1].effects = nil\r\nUnitTemplate.weapons[1].projectileTemplate = \"pxd003\"\r\nUnitTemplate.weapons[1].rangeMax = 30\r\nUnitTemplate.weapons[1].rangeMin = 4\r\nUnitTemplate.weapons[1].reloadTime = 0.3333333333333333\r\nUnitTemplate.weapons[1].layerTargetLimits = {\r\n    \"Land\", \"WaterSurface\", \"Seabed\",\r\n}\r\nUnitTemplate.weapons[1].layerWeaponLimits = { \"Land\", \"Seabed\" }\r\nUnitTemplate.weapons[1].targetWaterLimits = \"Above\"\r\nUnitTemplate.weapons[1].scoAboveWaterFireOnly = true\r\nUnitTemplate.weapons[1].scoAboveWaterTargetsOnly = true\r\nUnitTemplate.weapons[1].scoMonkeylordWaterGate = \"Above\"\r\nUnitTemplate.weapons[1].scoMonkeylordMicrowave = {\r\n    collisionTicks = 2,\r\n    damageRadius = 0.5,\r\n    sliderBone = \"Center_Turret_Barrel\",\r\n    sliderFireSpeed = 1,\r\n    sliderGoal = -1,\r\n    sliderReturnSpeed = 2,\r\n    spinBone = \"Center_Turret_Barrel\",\r\n    spinSpeed = 180,\r\n}\r\nUnitTemplate.weapons[1].beam = {\r\n    subMesh = {\r\n        {\r\n            model = \"VFX/SupremeCommanderOverhaul/Models/Monkeylord/monkeylord_microwave_beam.sanmodel\",\r\n            material = \"VFX/SupremeCommanderOverhaul/Materials/Monkeylord/monkeylord_microwave_beam.sanmaterial\",\r\n        },\r\n    },\r\n    fadeInTime = 0,\r\n    fadeOutTime = 0,\r\n    cullDistance = 400,\r\n}\r\nUnitTemplate.weapons[1].aimControllers = {\r\n    {\r\n        aimBone = \"Center_Turret_Muzzle\",\r\n        aimTolerance = 2,\r\n        defaultPitchAdjustment = -20,\r\n        defaultYawAdjustment = 0,\r\n        leadTarget = false,\r\n        pitchBone = \"Center_Turret\",\r\n        pitchMax = 70,\r\n        pitchMin = -110,\r\n        pitchSpeed = 20,\r\n        poseResetTime = 3,\r\n        projectileSpeed = 30,\r\n        solverType = \"NoArc\",\r\n        yawBone = \"Center_Turret\",\r\n        yawMax = 180,\r\n        yawMin = -180,\r\n        yawSpeed = 40,\r\n    },\r\n}\r\nUnitTemplate.weapons[1].muzzleGroups = {\r\n    {\r\n        muzzles = {\r\n            \"Center_Turret_Muzzle\",\r\n        },\r\n    },\r\n}\r\nUnitTemplate.weapons[1].muzzles = {\r\n    [\"Center_Turret_Muzzle\"] = {\r\n        aimController = \"Center_Turret_Muzzle\",\r\n    },\r\n}\r\nlocal monkeylordMicrowave = UnitTemplate.weapons[1]\r\n-- A previously ported Monkeylord has seven weapons. The death weapon's\n-- category is stable; its numeric slot is not. Do not synthesize a missing one.\nlocal monkeylordDeathWeapon\nfor _, candidate in ipairs(UnitTemplate.weapons) do\n    if type(candidate) == \"table\" and candidate.category == \"DeathExplosion\" then\n        if monkeylordDeathWeapon then\n            error(\"UGL4001 Monkeylord has ambiguous DeathExplosion weapons.\")\n        end\n        monkeylordDeathWeapon = candidate\n    end\nend\nif not monkeylordDeathWeapon then\n    error(\"UGL4001 Monkeylord override requires the stock death weapon.\")\nend\nmonkeylordDeathWeapon.category = \"DeathExplosion\"\r\nmonkeylordDeathWeapon.damage = 4000\r\nmonkeylordDeathWeapon.damageFriendly = true\r\nmonkeylordDeathWeapon.damageRadius = 7\r\nmonkeylordDeathWeapon.damageType = \"Normal\"\r\n\r\nlocal function SCO_MonkeylordAim(\r\n    aimBone, yawBone, pitchBone,\r\n    defaultPitch, pitchRange, pitchSpeed,\r\n    defaultYaw, yawRange, yawSpeed,\r\n    projectileSpeed, leadTarget)\r\n    return {\r\n        aimBone = aimBone,\r\n        aimTolerance = 2,\r\n        defaultPitchAdjustment = defaultPitch,\r\n        defaultYawAdjustment = defaultYaw,\r\n        leadTarget = leadTarget,\r\n        pitchBone = pitchBone,\r\n        pitchMax = defaultPitch + pitchRange,\r\n        pitchMin = defaultPitch - pitchRange,\r\n        pitchSpeed = pitchSpeed,\r\n        poseResetTime = 3,\r\n        projectileSpeed = projectileSpeed,\r\n        solverType = \"NoArc\",\r\n        yawBone = yawBone,\r\n        yawMax = defaultYaw + yawRange,\r\n        yawMin = defaultYaw - yawRange,\r\n        yawSpeed = yawSpeed,\r\n    }\r\nend\r\n\r\nlocal function SCO_MonkeylordMuzzleMap(controller, names)\r\n    local result = {}\r\n    for _, name in ipairs(names) do\r\n        result[name] = { aimController = controller }\r\n    end\r\n    return result\r\nend\r\n\r\nlocal function SCO_MonkeylordBolter(\r\n    muzzle, yawBone, pitchBone,\r\n    defaultPitch, pitchRange, defaultYaw, headingArc)\r\n    local weapon = {\r\n        aimControllers = {\r\n            SCO_MonkeylordAim(\r\n                muzzle, yawBone, pitchBone,\r\n                defaultPitch, pitchRange, 90,\r\n                defaultYaw, 90, 90,\r\n                35, true),\r\n        },\r\n        collideFriendly = false,\r\n        damage = 150,\r\n        damageFriendly = false,\r\n        damageRadius = 0,\r\n        damageType = \"Normal\",\r\n        effects = {\r\n            onFire = \"VFX/Muzzle/vgm1281_cannon_plasma_medium_muzzle.sanvfx\",\r\n        },\r\n        firingRandomness = 0,\r\n        layerTargetLimits = { \"Land\", \"WaterSurface\", \"Seabed\" },\r\n        layerWeaponLimits = { \"Land\", \"Seabed\" },\r\n        muzzleGroupChargeDelay = 0,\r\n        muzzleGroupTimeOut = -1,\r\n        muzzleGroups = { { muzzles = { muzzle } } },\r\n        muzzles = SCO_MonkeylordMuzzleMap(muzzle, { muzzle }),\r\n        muzzleSalvoDelay = 0,\r\n        muzzleSalvoSize = 1,\r\n        projectileLifetime = 2.1028571428571428,\r\n        projectileTemplate = \"pgr402b\",\r\n        rangeMax = 64,\r\n        rangeMin = 0,\r\n        rangeRingType = \"DirectFire\",\r\n        rangeTracking = 1.15,\r\n        reloadTime = 0.6666666666666666,\r\n    }\r\n    if headingArc then\r\n        weapon.scoMonkeylordHeadingArc = {\r\n            center = headingArc.center,\r\n            range = headingArc.range,\r\n        }\r\n    end\r\n    return weapon\r\nend\r\n\r\nlocal function SCO_MonkeylordNanite(side)\r\n    local first = side .. \"_Projectile01\"\r\n    local second = side .. \"_Projectile02\"\r\n    return {\r\n        aimControllers = {\r\n            SCO_MonkeylordAim(\r\n                first, first, first,\r\n                0, 0, 0,\r\n                0, 0, 0,\r\n                30, false),\r\n        },\r\n        collideFriendly = false,\r\n        damage = 40,\r\n        damageFriendly = false,\r\n        damageRadius = 0,\r\n        damageType = \"Normal\",\r\n        firingRandomness = 0,\r\n        layerTargetLimits = { \"Air\" },\r\n        layerWeaponLimits = { \"Land\" },\r\n        muzzleGroupChargeDelay = 0,\r\n        muzzleGroupTimeOut = -1,\r\n        -- ProjectilesPerOnFire=2: both native rack endpoints fire in\r\n        -- one Sanctuary muzzle group, once per two-second reload.\r\n        muzzleGroups = { { muzzles = { first, second } } },\r\n        muzzles = SCO_MonkeylordMuzzleMap(first, { first, second }),\r\n        muzzleSalvoDelay = 0,\r\n        muzzleSalvoSize = 1,\r\n        projectileLifetime = 7,\r\n        projectileTemplate = \"pgr402a\",\r\n        rangeMax = 64,\r\n        rangeMin = 0,\r\n        rangeRingType = \"AntiAir\",\r\n        rangeTracking = 1.15,\r\n        reloadTime = 2,\r\n        targetWaterLimits = \"Above\",\r\n    }\r\nend\r\n\r\nlocal torpedoMuzzles = {\r\n    \"Right_Projectile01\",\r\n    \"Right_Projectile02\",\r\n    \"Left_Projectile01\",\r\n    \"Left_Projectile02\",\r\n}\r\nlocal monkeylordTorpedo = {\r\n    aimControllers = {\r\n        SCO_MonkeylordAim(\r\n            \"Right_Projectile01\",\r\n            \"Right_Projectile01\",\r\n            \"Right_Projectile01\",\r\n            0, 0, 0,\r\n            0, 0, 0,\r\n            5, false),\r\n    },\r\n    collideFriendly = false,\r\n    damage = 50,\r\n    damageFriendly = false,\r\n    damageRadius = 0,\r\n    damageType = \"Normal\",\r\n    firingRandomness = 0,\r\n    layerTargetLimits = { \"Seabed\", \"Water\" },\r\n    layerWeaponLimits = { \"Seabed\" },\r\n    muzzleGroupChargeDelay = 0,\r\n    muzzleGroupTimeOut = -1,\r\n    -- FA ProjectilesPerOnFire=1 cycles the four authored rack bones;\r\n    -- separate Sanctuary groups avoid firing four torpedoes at once.\r\n    muzzleGroups = {\r\n        { muzzles = { \"Right_Projectile01\" } },\r\n        { muzzles = { \"Right_Projectile02\" } },\r\n        { muzzles = { \"Left_Projectile01\" } },\r\n        { muzzles = { \"Left_Projectile02\" } },\r\n    },\r\n    muzzles = SCO_MonkeylordMuzzleMap(\r\n        \"Right_Projectile01\", torpedoMuzzles),\r\n    muzzleSalvoDelay = 0,\r\n    muzzleSalvoSize = 1,\r\n    projectileLifetime = 9,\r\n    projectileTemplate = \"pgr402t\",\r\n    rangeMax = 45,\r\n    rangeMin = 0,\r\n    rangeRingType = \"AntiNavy\",\r\n    rangeTracking = 1.15,\r\n    reloadTime = 4,\r\n    targetWaterLimits = \"Below\",\r\n    scoMonkeylordWaterGate = \"Below\",\r\n}\r\n\r\nUnitTemplate.weapons = {\r\n    monkeylordMicrowave,\r\n    SCO_MonkeylordBolter(\r\n        \"Right_Turret_Muzzle\",\r\n        \"Right_Turret\",\r\n        \"Right_Turret_Barrel\",\r\n        -10, 45, -45, nil),\r\n    SCO_MonkeylordBolter(\r\n        \"Left_Turret_Muzzle\",\r\n        \"Left_Turret\",\r\n        \"Left_Turret_Barrel\",\r\n        -10, 90, 45, { center = 45, range = 90 }),\r\n    SCO_MonkeylordNanite(\"Right\"),\r\n    SCO_MonkeylordNanite(\"Left\"),\r\n    monkeylordTorpedo,\r\n    monkeylordDeathWeapon,\r\n}\r\n\r\n-- Current Sanctuary limitations retained explicitly: no FA source\r\n-- emitter/audio graph importer, no EffectiveRadius/TargetCheckInterval,\r\n-- no PrefersPrimaryWeaponTarget or HOVER category reject, and no native\r\n-- sonar/sonar-stealth entity lifecycle. Nanite's late random acceleration\r\n-- and zig-zag, torpedo StayUnderwater, and DestroyOnWater transition\r\n-- semantics are likewise unavailable in the current projectile schema.", null, new string[19]
		{
			"GuardMonkeylord", "maintenanceConsumption = { energy = 250 }", "scoMonkeylordMicrowave = {", "collisionTicks = 2,", "damageRadius = 0.5,", "sliderBone = \"Center_Turret_Barrel\"", "sliderGoal = -1,", "UnitTemplate.weapons[1].audio = nil", "UnitTemplate.weapons[1].effects = nil", "UnitTemplate.weapons[1].projectileTemplate = \"pxd003\"",
			"monkeylord_microwave_beam.sanmaterial", "SCO_MonkeylordBolter(", "projectileTemplate = \"pgr402b\"", "SCO_MonkeylordNanite(\"Right\")", "SCO_MonkeylordNanite(\"Left\")", "projectileTemplate = \"pgr402a\"", "projectileTemplate = \"pgr402t\"", "scoMonkeylordWaterGate = \"Below\"", "UnitTemplate.weapons = {"
		}));
		list.Add(new PatchSpec("LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Guard Monkeylord host class", "-- Guard Cybran Monkeylord Cache Patcher 1.4.0", "\r\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\r\nlocal SCO_MonkeylordLayers = Import(\"common/layers.lua\")\r\nlocal SCO_MonkeylordStockGuardUpdateAnimations =\r\n    HostGuardLandUnit.UpdateAnimations\r\nHostGuardMonkeylord = Class(\"GuardMonkeylord\", HostGuardLandUnit)\r\n\r\nfunction HostGuardMonkeylord:RotatorsEnabledOnConstruction()\r\n    -- The microwave barrel starts only when its persistent beam does.\r\n    return false\r\nend\r\n\r\nlocal SCO_MonkeylordActivationDuration = 4.333333492279053\r\nlocal SCO_MonkeylordDeathDuration = 5.666666507720947\r\n\r\nfunction HostGuardMonkeylord:SetupAnimations()\r\n    HostGuardLandUnit.SetupAnimations(self)\r\n    if not self:IsCompleted() then\r\n        self.scoMonkeylordAnimationPhase = \"construction\"\r\n        self:SetAnimatorEnabled(true)\r\n        Engine.PlayAnimation(self.id, self.tp.visuals.animations.construction.id, 0)\r\n    end\r\nend\r\n\r\nfunction HostGuardMonkeylord:RestoreLocomotionAnimation()\r\n    self.scoMonkeylordAnimationPhase = \"ready\"\r\n    self.isWalking = true\r\n    Engine.PlayAnimation(self.id, self.tp.visuals.animations.walk.id, 0.1)\r\n    self:UpdateAnimations()\r\nend\r\n\r\nfunction HostGuardMonkeylord:CancelActivationThread()\r\n    self.scoMonkeylordAnimationGeneration =\r\n        (self.scoMonkeylordAnimationGeneration or 0) + 1\r\n    if self.scoMonkeylordActivationThread then\r\n        KillThread(self.scoMonkeylordActivationThread)\r\n        self.scoMonkeylordActivationThread = nil\r\n    end\r\nend\r\n\r\nfunction HostGuardMonkeylord:ActivationThread(generation)\r\n    WaitSeconds(SCO_MonkeylordActivationDuration)\r\n    if self.dead or self.deleted\r\n        or self.scoMonkeylordAnimationGeneration ~= generation\r\n        or self.scoMonkeylordAnimationPhase ~= \"activating\"\r\n    then\r\n        return\r\n    end\r\n    self.scoMonkeylordActivationThread = nil\r\n    self:RestoreLocomotionAnimation()\r\nend\r\n\r\nfunction HostGuardMonkeylord:OnStopBeingBuilt()\r\n    if self.dead or self.deleted or self.scoMonkeylordCompletionHandled then return end\r\n    self.scoMonkeylordCompletionHandled = true\r\n    local bypassed = self.bypassedBuildProcess\r\n    HostGuardLandUnit.OnStopBeingBuilt(self)\r\n    local resourceEntities = self.resourceEntities\r\n    local consumption = resourceEntities and resourceEntities.consumption\r\n    if consumption == nil then\r\n        error(\"Monkeylord maintenance resource was not created\")\r\n    end\r\n    consumption:SetEnabled(true)\r\n    if bypassed then\r\n        self:RestoreLocomotionAnimation()\r\n        return\r\n    end\r\n    self.scoMonkeylordAnimationPhase = \"activating\"\r\n    self.scoMonkeylordAnimationGeneration =\r\n        (self.scoMonkeylordAnimationGeneration or 0) + 1\r\n    self:UpdateAnimations()\r\n    if self.scoMonkeylordAnimationPhase ~= \"activating\" then return end\r\n    Engine.PlayAnimation(self.id, self.tp.visuals.animations.activate.id, 0.1)\r\n    self.scoMonkeylordActivationThread = self:NewThread(\r\n        self.ActivationThread, self.scoMonkeylordAnimationGeneration)\r\nend\r\n\r\nfunction HostGuardMonkeylord:UpdateAnimations()\r\n    -- URL0402's source layer callback enables its torpedo only on the\r\n    -- seabed. Sanctuary weapon masks consume targetingLayer directly,\r\n    -- so derive that layer from the current water/terrain contract.\r\n    if not self.dead then\r\n        local targetLayer = SCO_MonkeylordLayers.TargetingLayer.Land\r\n        local waterResult, hasWater = Engine.HasWater()\r\n        if waterResult == EngineErrorCode.Success and hasWater then\r\n            local levelResult, waterLevel = Engine.GetWaterLevel()\r\n            local position = self:GetPosition()\r\n            if levelResult == EngineErrorCode.Success\r\n                and waterLevel ~= nil\r\n                and position ~= nil\r\n            then\r\n                local terrainResult, terrainHeight =\r\n                    Engine.SampleTerrainHeight(position)\r\n                if terrainResult == EngineErrorCode.Success\r\n                    and terrainHeight < waterLevel - 0.05\r\n                    and position.y < waterLevel - 0.05\r\n                then\r\n                    targetLayer =\r\n                        SCO_MonkeylordLayers.TargetingLayer.Seabed\r\n                end\r\n            end\r\n        end\r\n        if self.targetingLayer ~= targetLayer then\r\n            self:SetTargetingLayer(targetLayer)\r\n        end\r\n    end\r\n    if self.dead or self.scoMonkeylordAnimationPhase == \"construction\" then return end\r\n    if self.scoMonkeylordAnimationPhase == \"activating\" then\r\n        -- Completion already enabled native movement and weapons. Yield the\r\n        -- deploy pose when either takes ownership, instead of sliding the rig.\r\n        local speedResult, speed = Engine.GetMovementCurrentSpeed(self.id)\r\n        local active = speedResult == EngineErrorCode.Success and speed > 0\r\n        if not active then\r\n            for _, weapon in ipairs(self.weapons or {}) do\r\n                local target = weapon:GetAimTarget()\r\n                if weapon:IsEnabled() and target and not target.dead and not target.deleted then\r\n                    active = true\r\n                    break\r\n                end\r\n            end\r\n        end\r\n        if not active then return end\r\n        self:CancelActivationThread()\r\n        return self:RestoreLocomotionAnimation()\r\n    end\r\n    return SCO_MonkeylordStockGuardUpdateAnimations(self)\r\nend\r\n\r\nfunction HostGuardMonkeylord:OnDestroy(destroyType)\r\n    self.scoMonkeylordDeathAnimationPending = self:IsCompleted()\r\n        and not self:IsPlacementGhost()\r\n        and (destroyType == DestroyType.Kinetic or destroyType == DestroyType.Unspecified)\r\n    self.scoMonkeylordAnimationPhase = \"dead\"\r\n    self:CancelActivationThread()\r\n    self:SetRotatorsEnabled(false)\r\n    -- The native unit updater retains dead units until Delete. Quiesce before\r\n    -- native deletion so neither it nor aim controllers touch deleted weapons.\r\n    for _, weapon in ipairs(self.weapons or {}) do\r\n        weapon:SetEnabled(false)\r\n        weapon:SetAimTarget(nil)\r\n    end\r\n    local result = HostGuardLandUnit.OnDestroy(self, destroyType)\r\n    self.weapons = {}\r\n    return result\r\nend\r\n\r\nfunction HostGuardMonkeylord:DeathThread(overkillRatio)\r\n    if not self.scoMonkeylordDeathAnimationPending then\r\n        return HostGuardLandUnit.DeathThread(self, overkillRatio)\r\n    end\r\n    self.scoMonkeylordDeathAnimationPending = nil\r\n    self.scoMonkeylordAnimationPhase = \"dying\"\r\n    -- Native OnDestroy has already ended combat, economy and targeting.\r\n    Engine.SetMovementEnabled(self.id, false)\r\n    Engine.SetMovementCollisionMask(self.id, 0)\r\n    self:SetAnimatorEnabled(true)\r\n    Engine.PlayAnimation(self.id, self.tp.visuals.animations.death.id, 0.1)\r\n    WaitSeconds(SCO_MonkeylordDeathDuration)\r\n    if not self.deleted then\r\n        -- Keep native fraction/overkill/wreck rules; only defer their execution.\r\n        return HostGuardLandUnit.DeathThread(self, overkillRatio)\r\n    end\r\nend", null, new string[7] { "HostGuardMonkeylord = Class(\"GuardMonkeylord\", HostGuardLandUnit)", "function HostGuardMonkeylord:OnStopBeingBuilt()", "consumption:SetEnabled(true)", "function HostGuardMonkeylord:RotatorsEnabledOnConstruction()", "function HostGuardMonkeylord:UpdateAnimations()", "Engine.SampleTerrainHeight(position)", "SCO_MonkeylordLayers.TargetingLayer.Seabed" }));
		list.Add(new PatchSpec("LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua", "Guard Monkeylord client class", "-- Guard Cybran Monkeylord Cache Patcher 1.4.0", "\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\nClientGuardMonkeylord = Class(\"GuardMonkeylord\", ClientGuardLandUnit)", null, new string[1] { "ClientGuardMonkeylord = Class(\"GuardMonkeylord\", ClientGuardLandUnit)" }));
		list.Add(new PatchSpec("LJ/lua/host/units/weaponsClasses/beam.lua", "Monkeylord scoped host beam behavior", "-- Guard Cybran Monkeylord Cache Patcher 1.4.0", string.Empty, TransformHostBeam, new string[5] { "local scoMonkeylordStockBeamRaycast = HostBeam.Raycast", "function HostBeam:SetBeamEnabled(enabled, sendCommand)", "scoMonkeylordCollisionUpdate.ProcessAreaDamage(", "collision.hitPosition,", "Engine.SetRotatorEnabled(" }));
		list.Add(new PatchSpec("LJ/lua/client/entities/beam.lua", "Monkeylord scoped client barrel slider", "-- Guard Cybran Monkeylord Cache Patcher 1.4.0", string.Empty, TransformClientBeam, new string[5] { "local scoMonkeylordStockClientBeamRenderUpdate = ClientBeam.RenderUpdate", "function ClientBeam:SetBeamEnabled(enabled)", "function ClientBeam:RenderUpdate()", "Engine.GetLocalEntityLocalPosition(sliderId, base)", "Engine.SetLocalEntityLocalPosition(" }));
		list.Add(new PatchSpec("LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "Monkeylord source water/heading gates", "-- Guard Cybran Monkeylord Cache Patcher 1.4.0", "\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\nlocal SCO_MonkeylordStockCanShootAt = HostWeapon.CanShootAt\n\nlocal function SCO_MonkeylordPassesWaterGate(weapon, target)\n    local gate = weapon.tp and weapon.tp.scoMonkeylordWaterGate\n    if gate == nil then return true end\n\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return gate == \"Above\" end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then\n        return false\n    end\n    local ownerPosition = weapon.unit and weapon.unit:GetPosition()\n    local targetPosition = target and target:GetPosition()\n    if ownerPosition == nil or targetPosition == nil then return false end\n    local margin = 0.05\n    if gate == \"Above\" then\n        return ownerPosition.y >= waterLevel - margin\n            and targetPosition.y >= waterLevel - margin\n    elseif gate == \"Below\" then\n        return ownerPosition.y < waterLevel - margin\n            and targetPosition.y < waterLevel - margin\n    end\n    return false\nend\n\nlocal function SCO_MonkeylordNormalizeHeading(value)\n    return (value + 180) % 360 - 180\nend\n\nlocal function SCO_MonkeylordPassesHeadingArc(weapon, target)\n    local arc = weapon.tp and weapon.tp.scoMonkeylordHeadingArc\n    if arc == nil then return true end\n    local ownerPosition = weapon.unit and weapon.unit:GetPosition()\n    local targetPosition = target and target:GetPosition()\n    if ownerPosition == nil or targetPosition == nil then return false end\n    local deltaX = targetPosition.x - ownerPosition.x\n    local deltaZ = targetPosition.z - ownerPosition.z\n    if deltaX == 0 and deltaZ == 0 then return true end\n    local yawResult, ownerYaw = Engine.GetMovementChassisYawDegrees(weapon.unit.id)\n    if yawResult ~= EngineErrorCode.Success or ownerYaw == nil then\n        return false\n    end\n    local targetHeading = math.deg(math.atan2(deltaX, deltaZ))\n    local relativeHeading = SCO_MonkeylordNormalizeHeading(\n        targetHeading - ownerYaw - arc.center)\n    return math.abs(relativeHeading) <= arc.range\nend\n\nfunction HostWeapon:CanShootAt(target)\n    return SCO_MonkeylordStockCanShootAt(self, target)\n        and SCO_MonkeylordPassesWaterGate(self, target)\n        and SCO_MonkeylordPassesHeadingArc(self, target)\nend", null, new string[5] { "local SCO_MonkeylordStockCanShootAt = HostWeapon.CanShootAt", "function HostWeapon:CanShootAt(target)", "scoMonkeylordWaterGate", "scoMonkeylordHeadingArc", "Engine.GetMovementChassisYawDegrees(weapon.unit.id)" }));
		list.Add(new PatchSpec("LJ/lua/common/systems/import.lua", "Monkeylord virtual-projectile scanner", "-- Guard Cybran Monkeylord Cache Patcher 1.4.0", "\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\nlocal SCO_MonkeylordScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_MonkeylordScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n    local monkeylordFolders = {\n        directory .. \"pgr402b\",\n        directory .. \"pgr402a\",\n        directory .. \"pgr402t\",\n    }\n    for _, monkeylordFolder in ipairs(monkeylordFolders) do\n        local found = false\n        for _, folder in ipairs(folders) do\n            if folder == monkeylordFolder then\n                found = true\n                break\n            end\n        end\n        if not found then table.insert(folders, monkeylordFolder) end\n    end\n    return folders\nend", null, new string[4] { "local SCO_MonkeylordScanDir = ScanDir", "directory .. \"pgr402b\"", "directory .. \"pgr402a\"", "directory .. \"pgr402t\"" }));
		List<PatchSpec> list2 = list;
		ProjectileSpec[] projectiles = Projectiles;
		foreach (ProjectileSpec projectileSpec in projectiles)
		{
			List<string> list3 = new List<string>
			{
				"ProjectileTemplate = {",
				"tpId = \"" + projectileSpec.Id + "\"",
				projectileSpec.SourceId,
				projectileSpec.SourceBlueprintSha256,
				projectileSpec.SourceScriptSha256,
				projectileSpec.TrailVfx,
				"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
				"86c43f27b3ff9189a82f8201eec020d18c0770568a862b034737cd17424a357c"
			};
			if (projectileSpec.ImpactVfx != null)
			{
				list3.Add(projectileSpec.ImpactVfx);
			}
			list2.Add(new PatchSpec(ProjectileRelativePath(projectileSpec.Id), projectileSpec.SourceId + " isolated Monkeylord projectile", "-- Guard Cybran Monkeylord Cache Patcher 1.4.0", string.Empty, null, list3.ToArray(), BuildVirtualProjectile(projectileSpec)));
		}
		return list2.ToArray();
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static bool TryGetResource(object cache, PatchSpec spec, out PatchResource resource)
	{
		Type type = cache.GetType();
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		string fullPath = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), spec.RelativePath));
		if ((bool)obj.Invoke(cache, new object[1] { fullPath }))
		{
			object obj2 = propertyInfo.GetValue(cache, new object[1] { fullPath }) ?? throw new InvalidOperationException("The cached " + spec.Description + " has no value.");
			if (!IsNativeArrayCreated(obj2))
			{
				throw new InvalidOperationException("The cached " + spec.Description + " is not an initialized NativeArray.");
			}
			resource = new PatchResource(spec, fullPath, obj2);
			return true;
		}
		string value = "/" + spec.RelativePath.Replace('\\', '/');
		string text = null;
		object obj3 = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			string text2 = (string)type2.GetProperty("Key")?.GetValue(item);
			if (text2 != null && text2.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (text != null)
				{
					throw new InvalidOperationException("More than one cached resource matches " + spec.RelativePath + ".");
				}
				object obj4 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("The cached " + spec.Description + " has no value.");
				if (!IsNativeArrayCreated(obj4))
				{
					throw new InvalidOperationException("The cached " + spec.Description + " is not an initialized NativeArray.");
				}
				text = text2;
				obj3 = obj4;
			}
		}
		if (text == null || obj3 == null)
		{
			resource = null;
			return false;
		}
		resource = new PatchResource(spec, text, obj3);
		return true;
	}

	private static Type GetNativeArrayType(object cache)
	{
		foreach (object item in (IEnumerable)cache)
		{
			object obj = item.GetType().GetProperty("Value")?.GetValue(item);
			if (obj != null)
			{
				if (!IsNativeArrayCreated(obj))
				{
					throw new InvalidOperationException("Sanctuary's Lua cache contains an uninitialized NativeArray.");
				}
				return obj.GetType();
			}
		}
		throw new InvalidOperationException("Sanctuary's Lua cache contains no NativeArray resource type.");
	}

	private static string ResolvePath(string relativePath)
	{
		return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
	}

	private static string TransformHostBeam(string source)
	{
		string text = ((source.IndexOf("return {\r\n    CreateHostBeam = CreateHostBeam\r\n}", StringComparison.Ordinal) >= 0) ? "return {\r\n    CreateHostBeam = CreateHostBeam\r\n}" : "return {\n    CreateHostBeam = CreateHostBeam\n}");
		int num = source.IndexOf(text, StringComparison.Ordinal);
		if (num < 0 || source.IndexOf(text, num + text.Length, StringComparison.Ordinal) >= 0 || source.IndexOf("function HostBeam:Update()", StringComparison.Ordinal) < 0 || source.IndexOf("unit:TakeDamage(self.damage", StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("The stock HostBeam source no longer has its audited insertion contract.");
		}
		return source.Insert(num, "\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\nlocal scoMonkeylordStockBeamInit = HostBeam.__init\nlocal scoMonkeylordStockSetBeamEnabled = HostBeam.SetBeamEnabled\nlocal scoMonkeylordStockBeamRaycast = HostBeam.Raycast\nlocal scoMonkeylordCollisionUpdate =\n    Import(\"host/collisionUpdate.lua\")\nlocal scoMonkeylordUnits = __Entities.Units\nlocal scoMonkeylordShields = __Entities.Shields\n\nfunction HostBeam:__init(id, muzzle)\n    scoMonkeylordStockBeamInit(self, id, muzzle)\n    local weaponTemplate = muzzle.weapon.tp\n    self.scoMonkeylordMicrowave =\n        weaponTemplate.scoMonkeylordMicrowave\n    if self.scoMonkeylordMicrowave\n        and ((self.scoMonkeylordMicrowave.damageRadius or 0) <= 0\n            or (self.scoMonkeylordMicrowave.collisionTicks or 0) < 1)\n    then\n        error(\"Monkeylord microwave radius/cadence must be positive\")\n    end\n    self.scoMonkeylordCollisionTicksRemaining = 0\nend\n\nfunction HostBeam:SetBeamEnabled(enabled, sendCommand)\n    scoMonkeylordStockSetBeamEnabled(self, enabled, sendCommand)\n    local config = self.scoMonkeylordMicrowave\n    if config == nil\n        or self.scoMonkeylordSpinActive == enabled\n    then\n        return\n    end\n    self.scoMonkeylordCollisionTicksRemaining = enabled\n        and config.collisionTicks - 1 or 0\n    if self.scoMonkeylordSpinBone == nil then\n        self.scoMonkeylordSpinBone =\n            self.unit:GetBoneId(config.spinBone)\n        if self.scoMonkeylordSpinBone == nil then\n            error(\"Monkeylord microwave spin bone is missing\")\n        end\n    end\n    self.scoMonkeylordSpinActive = enabled\n    Engine.SetRotatorSpeed(\n        self.scoMonkeylordSpinBone,\n        EngineClasses.float3(0, 0, config.spinSpeed))\n    Engine.SetRotatorEnabled(\n        self.scoMonkeylordSpinBone,\n        enabled)\nend\n\nfunction HostBeam:Raycast()\n    local config = self.scoMonkeylordMicrowave\n    if config == nil then return scoMonkeylordStockBeamRaycast(self) end\n    if not self.enabled then return self.rangeMax end\n    local applyDamage = self.scoMonkeylordCollisionTicksRemaining <= 0\n    if applyDamage then\n        self.scoMonkeylordCollisionTicksRemaining = config.collisionTicks - 1\n    else\n        self.scoMonkeylordCollisionTicksRemaining = self.scoMonkeylordCollisionTicksRemaining - 1\n    end\n    local _, origin = Engine.GetGlobalEntityWorldPosition(self.id)\n    local _, forward = Engine.GetGlobalEntityForwardDirection(self.id)\n    local collisions = Engine.RayCast(CollisionWorld.Collision, origin, forward,\n        self.rangeMax, CollisionLayer.Shields + CollisionLayer.Units)\n    local army = self.unit.army\n    for _, collision in ipairs(collisions) do\n        local id = collision.otherGlobalID\n        local terrain = id.index == 0\n        local valid = not terrain and Engine.IsValidGlobalID(id)\n        local unit = valid and scoMonkeylordUnits[id.index]\n        local shield = valid and scoMonkeylordShields[id.index]\n        if terrain or (unit and army:IsEnemy(unit.army))\n            or (shield and shield.enabled and army:IsEnemy(shield.army)) then\n            if applyDamage then\n                scoMonkeylordCollisionUpdate.ProcessAreaDamage(collision.hitPosition, config.damageRadius,\n                    self.damage, army, false, self.unit)\n            end\n            return collision.hitDistance\n        end\n    end\n    return self.rangeMax\nend" + Environment.NewLine);
	}

	private static void ValidateStockResource(PatchSpec spec, string source)
	{
		string[] array;
		if (spec.RelativePath.Equals("LJ/lua/common/units/unitsTemplates/ugl4001/ugl4001.santp", StringComparison.Ordinal))
		{
			array = new string[3] { "UnitTemplate =", "tpId = \"ugl4001\"", "category = \"DeathExplosion\"" };
		}
		else if (spec.RelativePath.Equals("LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", StringComparison.Ordinal))
		{
			array = new string[2] { "HostGuardLandUnit = Class(\"GuardLandUnit\", LandUnit)", "HostGuardCommander" };
		}
		else if (spec.RelativePath.Equals("LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua", StringComparison.Ordinal))
		{
			array = new string[2] { "ClientGuardLandUnit = Class(\"GuardLandUnit\", LandUnit)", "ClientGuardCommander" };
		}
		else if (spec.RelativePath.Equals("LJ/lua/host/units/weaponsClasses/beam.lua", StringComparison.Ordinal))
		{
			array = new string[3] { "function HostBeam:Update()", "unit:TakeDamage(self.damage", "CreateHostBeam = CreateHostBeam" };
		}
		else if (spec.RelativePath.Equals("LJ/lua/client/entities/beam.lua", StringComparison.Ordinal))
		{
			array = new string[3] { "function ClientBeam:__init(", "function ClientBeam:SetBeamEnabled(", "return { ClientBeam = ClientBeam }" };
		}
		else if (spec.RelativePath.Equals("LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", StringComparison.Ordinal))
		{
			array = new string[3] { "function HostWeapon:CanShootAt(targetUnit)", "self.layerWeaponLimitsMask", "self.layerTargetLimitsMask" };
		}
		else
		{
			if (!spec.RelativePath.Equals("LJ/lua/common/systems/import.lua", StringComparison.Ordinal))
			{
				throw new InvalidOperationException("No stock validation contract exists for " + spec.RelativePath + ".");
			}
			array = new string[1] { "function ScanDir(directory)" };
		}
		string[] array2 = array;
		foreach (string text in array2)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Stock " + spec.Description + " is missing its audited anchor: " + text);
			}
		}
	}

	private static string TransformClientBeam(string source)
	{
		int num = source.IndexOf("return { ClientBeam = ClientBeam }", StringComparison.Ordinal);
		if (num < 0 || source.IndexOf("return { ClientBeam = ClientBeam }", num + "return { ClientBeam = ClientBeam }".Length, StringComparison.Ordinal) >= 0 || source.IndexOf("function ClientBeam:__init(", StringComparison.Ordinal) < 0 || source.IndexOf("function ClientBeam:SetBeamEnabled(", StringComparison.Ordinal) < 0 || source.IndexOf("function ClientBeam:RenderUpdate(", StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("The stock ClientBeam source no longer has its audited insertion contract.");
		}
		return source.Insert(num, "\n-- Guard Cybran Monkeylord Cache Patcher 1.4.0\nlocal scoMonkeylordStockClientBeamInit = ClientBeam.__init\nlocal scoMonkeylordStockClientBeamSetEnabled = ClientBeam.SetBeamEnabled\nlocal scoMonkeylordStockClientBeamSimUpdate = ClientBeam.SimUpdate\nlocal scoMonkeylordStockClientBeamRenderUpdate = ClientBeam.RenderUpdate\n\nfunction ClientBeam:__init(submeshes, muzzle)\n    scoMonkeylordStockClientBeamInit(self, submeshes, muzzle)\n    local config = self.muzzle.weapon.tp.scoMonkeylordMicrowave\n    self.scoMonkeylordSliderConfig = config\n    if config == nil then\n        return\n    end\n\n    local sliderId = self.muzzle.weapon.unit:GetBoneId(config.sliderBone)\n    if sliderId == nil or not Engine.IsValidLocalID(sliderId) then\n        error(\"Monkeylord microwave slider bone is missing\")\n    end\n    local base = EngineClasses.float3()\n    local result = Engine.GetLocalEntityLocalPosition(sliderId, base)\n    if result ~= EngineErrorCode.Success then\n        error(\"Monkeylord microwave slider bind position is unavailable\")\n    end\n    self.scoMonkeylordSliderId = sliderId\n    self.scoMonkeylordSliderBase = EngineClasses.float3(base.x, base.y, base.z)\n    self.scoMonkeylordSliderOffset = 0\n    self.scoMonkeylordSliderTarget = 0\n    self.scoMonkeylordSliderLastTime = _G.Time\nend\n\nfunction ClientBeam:SetBeamEnabled(enabled)\n    scoMonkeylordStockClientBeamSetEnabled(self, enabled)\n    local config = self.scoMonkeylordSliderConfig\n    if config == nil then\n        return\n    end\n    self.scoMonkeylordSliderTarget = enabled and config.sliderGoal or 0\n    self.scoMonkeylordSliderLastTime = _G.Time\nend\n\nfunction ClientBeam:SimUpdate()\n    if self.scoMonkeylordSliderConfig ~= nil\n        and self.enabled and self.pendingEnable\n    then\n        -- The existing muzzle is ready; let its first sim tick raycast and render.\n        self.pendingEnable = false\n    end\n    return scoMonkeylordStockClientBeamSimUpdate(self)\nend\n\nlocal function scoMonkeylordMoveToward(current, target, distance)\n    local delta = target - current\n    if math.abs(delta) <= distance then\n        return target\n    end\n    return current + (delta < 0 and -distance or distance)\nend\n\nfunction ClientBeam:RenderUpdate()\n    scoMonkeylordStockClientBeamRenderUpdate(self)\n    local config = self.scoMonkeylordSliderConfig\n    if config == nil then\n        return\n    end\n\n    local now = _G.Time\n    local elapsed = math.max(now - self.scoMonkeylordSliderLastTime, 0)\n    self.scoMonkeylordSliderLastTime = now\n    local speed = self.enabled\n        and config.sliderFireSpeed\n        or config.sliderReturnSpeed\n    self.scoMonkeylordSliderOffset = scoMonkeylordMoveToward(\n        self.scoMonkeylordSliderOffset,\n        self.scoMonkeylordSliderTarget,\n        speed * elapsed)\n    local base = self.scoMonkeylordSliderBase\n    local result = Engine.SetLocalEntityLocalPosition(\n        self.scoMonkeylordSliderId,\n        EngineClasses.float3(\n            base.x,\n            base.y,\n            base.z + self.scoMonkeylordSliderOffset))\n    if result ~= EngineErrorCode.Success then\n        error(\"Monkeylord microwave slider update failed\")\n    end\nend" + Environment.NewLine);
	}

	private static void ValidatePatchedResource(PatchSpec spec, string source)
	{
		int num = source.IndexOf(spec.Marker, StringComparison.Ordinal);
		int num2 = ((num < 0) ? (-1) : source.IndexOf(spec.Marker, num + spec.Marker.Length, StringComparison.Ordinal));
		if (num < 0 || num2 >= 0)
		{
			throw new InvalidOperationException("Patched " + spec.Description + " does not contain exactly one current marker.");
		}
		string[] requiredTokens = spec.RequiredTokens;
		foreach (string text in requiredTokens)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Patched " + spec.Description + " is missing: " + text);
			}
		}
		if (spec.RelativePath == "LJ/lua/common/units/unitsTemplates/ugl4001/ugl4001.santp")
		{
			requiredTokens = new string[3] { "ConstructionRest", "AnimActivate", "AnimDeath" };
			foreach (string text2 in requiredTokens)
			{
				if (source.IndexOf("clipName = \"" + text2 + "\"", StringComparison.Ordinal) < 0)
				{
					throw new InvalidOperationException("Monkeylord animation clip is missing: " + text2);
				}
			}
		}
		else if (spec.RelativePath == "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua")
		{
			requiredTokens = new string[3] { "SetupAnimations", "ActivationThread", "DeathThread" };
			foreach (string text3 in requiredTokens)
			{
				if (source.IndexOf("function HostGuardMonkeylord:" + text3 + "(", StringComparison.Ordinal) < 0)
				{
					throw new InvalidOperationException("Monkeylord animation lifecycle hook is missing: " + text3);
				}
			}
		}
		if ((spec.RelativePath.Equals("LJ/lua/host/units/weaponsClasses/beam.lua", StringComparison.Ordinal) || spec.RelativePath.Equals("LJ/lua/client/entities/beam.lua", StringComparison.Ordinal)) && num > source.LastIndexOf("return {", StringComparison.Ordinal))
		{
			throw new InvalidOperationException("Monkeylord HostBeam behavior was appended after the module return.");
		}
	}

	private static object GetCachedResource(object cache, string path)
	{
		return (cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException("The cached resource has no value: " + path);
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static bool ContainsCachedResource(object cache, string path)
	{
		object obj = (cache.GetType().GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(cache.GetType().FullName, "ContainsKey")).Invoke(cache, new object[1] { path });
		bool flag = false;
		int num;
		if (obj is bool)
		{
			flag = (bool)obj;
			num = 1;
		}
		else
		{
			num = 0;
		}
		return (byte)(num & (flag ? 1 : 0)) != 0;
	}

	private static void RemoveCachedResource(object cache, string path)
	{
		(cache.GetType().GetMethod("Remove", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(cache.GetType().FullName, "Remove")).Invoke(cache, new object[1] { path });
	}

	private static byte[] GetNativeArrayBytes(Type nativeArrayType, object nativeArray)
	{
		return (byte[])(nativeArrayType.GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "ToArray")).Invoke(nativeArray, null);
	}

	private static bool IsNativeArrayCreated(object nativeArray)
	{
		return (bool)(nativeArray.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(nativeArray.GetType().FullName, "IsCreated")).GetValue(nativeArray);
	}

	private static void TryDisposeNativeArray(Type nativeArrayType, object nativeArray, string description)
	{
		try
		{
			if (IsNativeArrayCreated(nativeArray))
			{
				(nativeArrayType.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "Dispose")).Invoke(nativeArray, null);
			}
		}
		catch (Exception arg)
		{
			Log($"Unable to dispose {description}: {arg}");
		}
	}

	private static void Log(string message)
	{
		string text = "[Guard Cybran Monkeylord Cache Patcher] " + message;
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
