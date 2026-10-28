using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using SupremeCommanderOverhaul.Shared;

namespace FaCybranHunterCachePatcher;

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

	internal const string OverrideMarker = "-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0";

	internal const string TargetId = "ugl1001";

	internal const string SourceId = "URL0106";

	internal const string ProjectileId = "pgr106";

	internal const string SourceArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	internal const string ProjectileArchiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12";

	internal const string SourceBlueprintSha256 = "46a3e6cdcbb714067e129a7bae90377a1b5a12b5c680130360aed973ad27bc57";

	internal const string SourceScriptSha256 = "d891364517e19d2d652237ae0b0a2a077a9d5eb32ff6fbd52c49d26ed043d81c";

	internal const string ProjectileBlueprintSha256 = "8cf98d148dd150fe40afc5fb53c20e071a69aeaf5bd67ba22664f3136202ab14";

	internal const string ProjectileScriptSha256 = "ba5e37cd799d302d7efdcff955212f139f21e7adcf5c77181af4c9002beb1d43";

	private const string UnitPath = "LJ/lua/common/units/unitsTemplates/ugl1001/ugl1001.santp";

	private const string GuardHostPath = "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua";

	private const string HostWeaponPath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private const string ImportPath = "LJ/lua/common/systems/import.lua";

	private const string ProjectileRoot = "LJ/lua/common/projectiles/projectilesTemplates";

	private const string UnitAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0\n-- Explicit same-faction role substitution: FA URL0106 Hunter replaces\n-- Sanctuary's ugl1001 Gimlet while retaining GuardLandUnit class identity.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.3, y = 0.3 },\n    offset = { x = 0, y = 0, z = -0.1 },\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URL0106 -> ugl1001\",\n    substitution = true,\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/URL0106/URL0106_unit.bp\",\n    sourceBlueprintSha256 = \"46a3e6cdcbb714067e129a7bae90377a1b5a12b5c680130360aed973ad27bc57\",\n    sourceScript = \"units/URL0106/URL0106_script.lua\",\n    sourceScriptSha256 = \"d891364517e19d2d652237ae0b0a2a077a9d5eb32ff6fbd52c49d26ed043d81c\",\n    sourceProjectile = \"projectiles/CDFLaserLight01/CDFLaserLight01_proj.bp\",\n    sourceProjectileSha256 = \"8cf98d148dd150fe40afc5fb53c20e071a69aeaf5bd67ba22664f3136202ab14\",\n    sourceProjectileScript = \"projectiles/CDFLaserLight01/CDFLaserLight01_script.lua\",\n    sourceProjectileScriptSha256 = \"ba5e37cd799d302d7efdcff955212f139f21e7adcf5c77181af4c9002beb1d43\",\n    class = { owner = \"unitsDefaultGuard\", name = \"GuardLandUnit\" },\n    collision = {\n        sourceSize = { x = 0.6, y = 0.6, z = 0.6 },\n        sourceOffset = { x = 0, y = 0, z = 0 },\n        sanctuaryCenterOffset = { x = 0, y = 0.3, z = 0 },\n    },\n    selection = { x = 0.3, z = 0.3, centerX = 0, centerZ = -0.1, thickness = 1.2 },\n    footprint = { x = 0.6, z = 0.6 },\n    defence = { health = 65, regen = 0 },\n    economy = { buildCostEnergy = 140, buildCostMass = 35, buildTime = 140 },\n    intel = { visionRadius = 18 },\n    movement = {\n        sourceMotionType = \"RULEUMT_Land\",\n        acceleration = 4, brake = 4, speed = 4, reverseSpeed = 0,\n        steerForce = 7, turnRadius = 1, turnRate = 45,\n        sourceAnimationWalkRate = 10,\n        sanctuaryAuthoredSpeed = 0.4,\n    },\n    weapon = {\n        name = \"Light Pulse Laser\",\n        projectile = \"CDFLaserLight01\",\n        sanctuaryProjectile = \"pgr106\",\n        sourceProjectileUseGravity = true,\n        sourceProjectileDestroyOnWater = true,\n        damage = 7, range = 14, rateOfFire = 1,\n        muzzleVelocity = 25, trackingRadius = 1.15,\n        muzzleSalvoSize = 3, muzzleSalvoDelay = 0.1,\n        projectilesPerOnFire = 3, sanctuaryProjectilesPerCycle = 9,\n        firingTolerance = 2,\n        turretYaw = 0, turretYawRange = 360, turretYawSpeed = 180,\n        turretPitch = 0, turretPitchRange = 90, turretPitchSpeed = 30,\n        useFiringSolutionInsteadOfAimBone = true,\n        aboveWaterTargetsOnly = true,\n    },\n    animations = {\n        death01 = { source = \"units/URL0106/URL0106_Adeath01.sca\", sha256 = \"ed80267859fe81c173e4dff7bc0278b9e65445a5da06144fa96465e0d2b74e3d\", frames = 15, duration = 0.46666666865348816, weight = 10 },\n        death02 = { source = \"units/URL0106/URL0106_Adeath02.sca\", sha256 = \"4c662ab9afa0307cc4bc86a4757494cba0728cb6c1e779908c114259d8ccc82e\", frames = 15, duration = 0.46666666865348816, weight = 90 },\n        fold = { source = \"units/URL0106/URL0106_Afold01.sca\", sha256 = \"f91d0e2060d41c8ec1be34589e95caba9f856202ba8b19b7bc1e476961fd3a64\", frames = 12, duration = 1.100000023841858, sourceBound = false },\n        walk = { source = \"units/URL0106/URL0106_Awalk01.sca\", sha256 = \"78a5bb9ab7aa4bdc4b0bb5fe44e8e124350ad4a8e0991af3f7de3e535b4bb3f9\", frames = 31, duration = 3, sourceRate = 10 },\n        omittedLod0Track = { name = \"AttachPoint\", clips = { \"death01\", \"death02\" }, numericallyStatic = true },\n    },\n    limitations = {\n        sourceDeathRateRandomization = \"0.75-1.25 unavailable; nominal rate used\",\n        sourceDeathWeightedRandom = \"deterministic unit-index buckets preserve 10/90 distribution\",\n        transportFoldRuntime = false,\n        sourceProjectileEmitterGraph = false,\n        sourceProjectileDestroyOnWaterRuntime = false,\n        sourceAudioBanks = false,\n        sourceGroundKickupEffect = false,\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 1: Light Assault Bot\"\nUnitTemplate.general.name = \"Hunter\"\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"direct\", tech = \"t1\" }\nUnitTemplate.general.iconUI = \"tech1_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 30\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = nil\n\nUnitTemplate.audio = nil\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.3, z = 0 },\n    collisionSize = { x = 0.6, y = 0.6, z = 0.6 },\n}\nUnitTemplate.footprint = { x = 0.6, y = 0.6 }\nUnitTemplate.defence = { health = { max = 65, regen = 0, value = 65 } }\nUnitTemplate.economy = {\n    buildTime = 140,\n    cost = { alloys = 35, energy = 140 },\n}\nUnitTemplate.intel = { visionRadius = 18 }\nUnitTemplate.movement = {\n    acceleration = 4,\n    deceleration = 4,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"LandSmall\" },\n    collisionMaskSpawn = { \"LandSmall\" },\n    maxReverseDistance = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotationSpeed = 45,\n    sortOrder = 1,\n    speed = 4,\n    terrainAlignmentFactor = 1,\n    type = \"LegsLand\",\n    walkAnimation = { authoredSpeed = 0.4 },\n}\nUnitTemplate.tags = {\n    \"ANTI_SURFACE\", \"BOT\", \"BUILDABLE_BY_T1_FACTORY\",\n    \"BUILDABLE_BY_T2_FACTORY\", \"BUILDABLE_BY_T3_FACTORY\",\n    \"DIRECT_FIRE\", \"GUARD\", \"LAND\", \"MOBILE\", \"TECH1\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.3, y = 0.3 },\n    offset = { x = 0, y = 0, z = -0.1 },\n}\nUnitTemplate.visuals.animations = {\n    death01 = {\n        clipName = \"AnimDeath01\",\n        sanAnimationPath = \"Units/ugl1001/LOD0/ugl1001.sananimation\",\n    },\n    death02 = {\n        clipName = \"AnimDeath02\",\n        sanAnimationPath = \"Units/ugl1001/LOD0/ugl1001.sananimation\",\n    },\n    fold = {\n        clipName = \"AnimFold\",\n        sanAnimationPath = \"Units/ugl1001/LOD0/ugl1001.sananimation\",\n    },\n    walk = {\n        authoredSpeed = 0.4,\n        clipName = \"AnimWalk\",\n        sanAnimationPath = \"Units/ugl1001/LOD0/ugl1001.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Turret_Muzzle\",\n                aimTolerance = 2,\n                defaultPitchAdjustment = 0,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = \"Turret_Barrel\",\n                pitchMax = 90,\n                pitchMin = -90,\n                pitchSpeed = 30,\n                poseResetTime = 3,\n                projectileSpeed = 25,\n                solverType = \"LowArc\",\n                yawBone = \"Turret\",\n                yawMax = 360,\n                yawMin = -360,\n                yawSpeed = 180,\n            },\n        },\n        audio = { onFire = { looping = false, name = \"agom1110\" } },\n        collideFriendly = false,\n        damage = 7,\n        damageFriendly = false,\n        damageRadius = 0,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vgm1101_cannon_small_muzzle.sanvfx\" },\n        firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = -1,\n        -- FA fires three parallel projectiles for each of three salvos.\n        muzzleGroups = {\n            { muzzles = { \"Turret_Muzzle\", \"Turret_Muzzle\", \"Turret_Muzzle\" } },\n        },\n        muzzles = { Turret_Muzzle = { aimController = \"Turret_Muzzle\" } },\n        muzzleSalvoDelay = 0.1,\n        muzzleSalvoSize = 3,\n        projectileLifetime = 0.644,\n        projectileTemplate = \"pgr106\",\n        rangeMax = 14,\n        rangeMin = 0,\n        rangeRingType = \"DirectFire\",\n        rangeTracking = 1.15,\n        reloadTime = 1,\n        targetWaterLimits = \"Above\",\n        scoFaHunterAboveWater = true,\n    },\n}";

	private const string GuardHostAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0\n-- Preserve the exact two source death clips and their 10/90 weighting.\n-- Unit-index buckets are deterministic and multiplayer-safe.\nlocal SCO_FaHunterStockDeathThread = HostGuardLandUnit.DeathThread\nfunction HostGuardLandUnit:DeathThread(overkillRatio)\n    if self.tpId ~= \"ugl1001\" then\n        return SCO_FaHunterStockDeathThread(self, overkillRatio)\n    end\n\n    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations\n    local bucket = ((self.id and self.id.index) or 0) % 10\n    local death = animations and (bucket == 0 and animations.death01 or animations.death02)\n    if not death or not death.id then\n        error(\"UGL1001 Hunter requires both hash-pinned source death clips\")\n    end\n    Engine.PlayAnimation(self.id, death.id, 0.1)\n    WaitSeconds(0.46666666865348816)\n    return SCO_FaHunterStockDeathThread(self, overkillRatio)\nend";

	private const string HostWeaponAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0\n-- targetWaterLimits is descriptive in this engine build. Enforce only\n-- URL0106's AboveWaterTargetsOnly target constraint after prior wrappers.\nlocal SCO_FaHunterStockCanShootAt = HostWeapon.CanShootAt\nfunction HostWeapon:CanShootAt(targetUnit)\n    if not SCO_FaHunterStockCanShootAt(self, targetUnit) then\n        return false\n    end\n    if not self.unit or self.unit.tpId ~= \"ugl1001\"\n        or not self.tp or self.tp.scoFaHunterAboveWater ~= true\n    then\n        return true\n    end\n\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return true end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return false end\n    local targetPosition = targetUnit and targetUnit:GetPosition()\n    return targetPosition ~= nil and targetPosition.y >= waterLevel - 0.05\nend";

	private const string ImportScannerAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0\n-- The isolated pgr106 projectile exists only in FilesCache.\nlocal SCO_FaHunterScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_FaHunterScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n    local hunterFolder = directory .. \"pgr106\"\n    for _, folder in ipairs(folders) do\n        if folder == hunterFolder then return folders end\n    end\n    table.insert(folders, hunterFolder)\n    return folders\nend";

	public static void Apply()
	{
		ValidatePinnedScope();
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>(5);
		try
		{
			obj = GetLuaFileCache();
			ValidateTransactionState(obj);
			QueueAppend(obj, list, "LJ/lua/common/units/unitsTemplates/ugl1001/ugl1001.santp", "UGL1001 Hunter template", "\n\n-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0\n-- Explicit same-faction role substitution: FA URL0106 Hunter replaces\n-- Sanctuary's ugl1001 Gimlet while retaining GuardLandUnit class identity.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.3, y = 0.3 },\n    offset = { x = 0, y = 0, z = -0.1 },\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URL0106 -> ugl1001\",\n    substitution = true,\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/URL0106/URL0106_unit.bp\",\n    sourceBlueprintSha256 = \"46a3e6cdcbb714067e129a7bae90377a1b5a12b5c680130360aed973ad27bc57\",\n    sourceScript = \"units/URL0106/URL0106_script.lua\",\n    sourceScriptSha256 = \"d891364517e19d2d652237ae0b0a2a077a9d5eb32ff6fbd52c49d26ed043d81c\",\n    sourceProjectile = \"projectiles/CDFLaserLight01/CDFLaserLight01_proj.bp\",\n    sourceProjectileSha256 = \"8cf98d148dd150fe40afc5fb53c20e071a69aeaf5bd67ba22664f3136202ab14\",\n    sourceProjectileScript = \"projectiles/CDFLaserLight01/CDFLaserLight01_script.lua\",\n    sourceProjectileScriptSha256 = \"ba5e37cd799d302d7efdcff955212f139f21e7adcf5c77181af4c9002beb1d43\",\n    class = { owner = \"unitsDefaultGuard\", name = \"GuardLandUnit\" },\n    collision = {\n        sourceSize = { x = 0.6, y = 0.6, z = 0.6 },\n        sourceOffset = { x = 0, y = 0, z = 0 },\n        sanctuaryCenterOffset = { x = 0, y = 0.3, z = 0 },\n    },\n    selection = { x = 0.3, z = 0.3, centerX = 0, centerZ = -0.1, thickness = 1.2 },\n    footprint = { x = 0.6, z = 0.6 },\n    defence = { health = 65, regen = 0 },\n    economy = { buildCostEnergy = 140, buildCostMass = 35, buildTime = 140 },\n    intel = { visionRadius = 18 },\n    movement = {\n        sourceMotionType = \"RULEUMT_Land\",\n        acceleration = 4, brake = 4, speed = 4, reverseSpeed = 0,\n        steerForce = 7, turnRadius = 1, turnRate = 45,\n        sourceAnimationWalkRate = 10,\n        sanctuaryAuthoredSpeed = 0.4,\n    },\n    weapon = {\n        name = \"Light Pulse Laser\",\n        projectile = \"CDFLaserLight01\",\n        sanctuaryProjectile = \"pgr106\",\n        sourceProjectileUseGravity = true,\n        sourceProjectileDestroyOnWater = true,\n        damage = 7, range = 14, rateOfFire = 1,\n        muzzleVelocity = 25, trackingRadius = 1.15,\n        muzzleSalvoSize = 3, muzzleSalvoDelay = 0.1,\n        projectilesPerOnFire = 3, sanctuaryProjectilesPerCycle = 9,\n        firingTolerance = 2,\n        turretYaw = 0, turretYawRange = 360, turretYawSpeed = 180,\n        turretPitch = 0, turretPitchRange = 90, turretPitchSpeed = 30,\n        useFiringSolutionInsteadOfAimBone = true,\n        aboveWaterTargetsOnly = true,\n    },\n    animations = {\n        death01 = { source = \"units/URL0106/URL0106_Adeath01.sca\", sha256 = \"ed80267859fe81c173e4dff7bc0278b9e65445a5da06144fa96465e0d2b74e3d\", frames = 15, duration = 0.46666666865348816, weight = 10 },\n        death02 = { source = \"units/URL0106/URL0106_Adeath02.sca\", sha256 = \"4c662ab9afa0307cc4bc86a4757494cba0728cb6c1e779908c114259d8ccc82e\", frames = 15, duration = 0.46666666865348816, weight = 90 },\n        fold = { source = \"units/URL0106/URL0106_Afold01.sca\", sha256 = \"f91d0e2060d41c8ec1be34589e95caba9f856202ba8b19b7bc1e476961fd3a64\", frames = 12, duration = 1.100000023841858, sourceBound = false },\n        walk = { source = \"units/URL0106/URL0106_Awalk01.sca\", sha256 = \"78a5bb9ab7aa4bdc4b0bb5fe44e8e124350ad4a8e0991af3f7de3e535b4bb3f9\", frames = 31, duration = 3, sourceRate = 10 },\n        omittedLod0Track = { name = \"AttachPoint\", clips = { \"death01\", \"death02\" }, numericallyStatic = true },\n    },\n    limitations = {\n        sourceDeathRateRandomization = \"0.75-1.25 unavailable; nominal rate used\",\n        sourceDeathWeightedRandom = \"deterministic unit-index buckets preserve 10/90 distribution\",\n        transportFoldRuntime = false,\n        sourceProjectileEmitterGraph = false,\n        sourceProjectileDestroyOnWaterRuntime = false,\n        sourceAudioBanks = false,\n        sourceGroundKickupEffect = false,\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 1: Light Assault Bot\"\nUnitTemplate.general.name = \"Hunter\"\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"direct\", tech = \"t1\" }\nUnitTemplate.general.iconUI = \"tech1_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 30\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = nil\n\nUnitTemplate.audio = nil\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.3, z = 0 },\n    collisionSize = { x = 0.6, y = 0.6, z = 0.6 },\n}\nUnitTemplate.footprint = { x = 0.6, y = 0.6 }\nUnitTemplate.defence = { health = { max = 65, regen = 0, value = 65 } }\nUnitTemplate.economy = {\n    buildTime = 140,\n    cost = { alloys = 35, energy = 140 },\n}\nUnitTemplate.intel = { visionRadius = 18 }\nUnitTemplate.movement = {\n    acceleration = 4,\n    deceleration = 4,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"LandSmall\" },\n    collisionMaskSpawn = { \"LandSmall\" },\n    maxReverseDistance = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotationSpeed = 45,\n    sortOrder = 1,\n    speed = 4,\n    terrainAlignmentFactor = 1,\n    type = \"LegsLand\",\n    walkAnimation = { authoredSpeed = 0.4 },\n}\nUnitTemplate.tags = {\n    \"ANTI_SURFACE\", \"BOT\", \"BUILDABLE_BY_T1_FACTORY\",\n    \"BUILDABLE_BY_T2_FACTORY\", \"BUILDABLE_BY_T3_FACTORY\",\n    \"DIRECT_FIRE\", \"GUARD\", \"LAND\", \"MOBILE\", \"TECH1\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.3, y = 0.3 },\n    offset = { x = 0, y = 0, z = -0.1 },\n}\nUnitTemplate.visuals.animations = {\n    death01 = {\n        clipName = \"AnimDeath01\",\n        sanAnimationPath = \"Units/ugl1001/LOD0/ugl1001.sananimation\",\n    },\n    death02 = {\n        clipName = \"AnimDeath02\",\n        sanAnimationPath = \"Units/ugl1001/LOD0/ugl1001.sananimation\",\n    },\n    fold = {\n        clipName = \"AnimFold\",\n        sanAnimationPath = \"Units/ugl1001/LOD0/ugl1001.sananimation\",\n    },\n    walk = {\n        authoredSpeed = 0.4,\n        clipName = \"AnimWalk\",\n        sanAnimationPath = \"Units/ugl1001/LOD0/ugl1001.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Turret_Muzzle\",\n                aimTolerance = 2,\n                defaultPitchAdjustment = 0,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = \"Turret_Barrel\",\n                pitchMax = 90,\n                pitchMin = -90,\n                pitchSpeed = 30,\n                poseResetTime = 3,\n                projectileSpeed = 25,\n                solverType = \"LowArc\",\n                yawBone = \"Turret\",\n                yawMax = 360,\n                yawMin = -360,\n                yawSpeed = 180,\n            },\n        },\n        audio = { onFire = { looping = false, name = \"agom1110\" } },\n        collideFriendly = false,\n        damage = 7,\n        damageFriendly = false,\n        damageRadius = 0,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vgm1101_cannon_small_muzzle.sanvfx\" },\n        firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = -1,\n        -- FA fires three parallel projectiles for each of three salvos.\n        muzzleGroups = {\n            { muzzles = { \"Turret_Muzzle\", \"Turret_Muzzle\", \"Turret_Muzzle\" } },\n        },\n        muzzles = { Turret_Muzzle = { aimController = \"Turret_Muzzle\" } },\n        muzzleSalvoDelay = 0.1,\n        muzzleSalvoSize = 3,\n        projectileLifetime = 0.644,\n        projectileTemplate = \"pgr106\",\n        rangeMax = 14,\n        rangeMin = 0,\n        rangeRingType = \"DirectFire\",\n        rangeTracking = 1.15,\n        reloadTime = 1,\n        targetWaterLimits = \"Above\",\n        scoFaHunterAboveWater = true,\n    },\n}", ValidatePatchedUnit);
			QueueAppend(obj, list, "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Hunter Guard death lifecycle", "\n\n-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0\n-- Preserve the exact two source death clips and their 10/90 weighting.\n-- Unit-index buckets are deterministic and multiplayer-safe.\nlocal SCO_FaHunterStockDeathThread = HostGuardLandUnit.DeathThread\nfunction HostGuardLandUnit:DeathThread(overkillRatio)\n    if self.tpId ~= \"ugl1001\" then\n        return SCO_FaHunterStockDeathThread(self, overkillRatio)\n    end\n\n    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations\n    local bucket = ((self.id and self.id.index) or 0) % 10\n    local death = animations and (bucket == 0 and animations.death01 or animations.death02)\n    if not death or not death.id then\n        error(\"UGL1001 Hunter requires both hash-pinned source death clips\")\n    end\n    Engine.PlayAnimation(self.id, death.id, 0.1)\n    WaitSeconds(0.46666666865348816)\n    return SCO_FaHunterStockDeathThread(self, overkillRatio)\nend", ValidatePatchedGuardHost);
			QueueAppend(obj, list, "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "Hunter water-target gate", "\n\n-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0\n-- targetWaterLimits is descriptive in this engine build. Enforce only\n-- URL0106's AboveWaterTargetsOnly target constraint after prior wrappers.\nlocal SCO_FaHunterStockCanShootAt = HostWeapon.CanShootAt\nfunction HostWeapon:CanShootAt(targetUnit)\n    if not SCO_FaHunterStockCanShootAt(self, targetUnit) then\n        return false\n    end\n    if not self.unit or self.unit.tpId ~= \"ugl1001\"\n        or not self.tp or self.tp.scoFaHunterAboveWater ~= true\n    then\n        return true\n    end\n\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return true end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return false end\n    local targetPosition = targetUnit and targetUnit:GetPosition()\n    return targetPosition ~= nil and targetPosition.y >= waterLevel - 0.05\nend", ValidatePatchedHostWeapon);
			QueueAppend(obj, list, "LJ/lua/common/systems/import.lua", "Hunter virtual-projectile scanner", "\n\n-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0\n-- The isolated pgr106 projectile exists only in FilesCache.\nlocal SCO_FaHunterScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_FaHunterScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n    local hunterFolder = directory .. \"pgr106\"\n    for _, folder in ipairs(folders) do\n        if folder == hunterFolder then return folders end\n    end\n    table.insert(folders, hunterFolder)\n    return folders\nend", ValidatePatchedImport);
			QueueVirtualProjectile(obj, list);
			if (list.Count == 0)
			{
				Log("URL0106 Hunter gameplay and isolated projectile resources are already current.");
				return;
			}
			Commit(obj, list);
			Log("Applied atomic URL0106 -> ugl1001 Hunter role replacement and pgr106 projectile.");
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
			Log($"Failed to apply the FA Cybran Hunter transaction: {arg}");
			throw;
		}
	}

	private static void ValidatePinnedScope()
	{
		if (new string[6] { "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12", "46a3e6cdcbb714067e129a7bae90377a1b5a12b5c680130360aed973ad27bc57", "d891364517e19d2d652237ae0b0a2a077a9d5eb32ff6fbd52c49d26ed043d81c", "8cf98d148dd150fe40afc5fb53c20e071a69aeaf5bd67ba22664f3136202ab14", "ba5e37cd799d302d7efdcff955212f139f21e7adcf5c77181af4c9002beb1d43" }.Any((string hash) => hash.Length != 64))
		{
			throw new InvalidOperationException("The reviewed Hunter mapping or hash scope changed.");
		}
	}

	private static void ValidateTransactionState(object cache)
	{
		int num = 0;
		(string, string)[] array = new(string, string)[4]
		{
			("LJ/lua/common/units/unitsTemplates/ugl1001/ugl1001.santp", "UGL1001 Hunter template"),
			("LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Hunter Guard death lifecycle"),
			("LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "Hunter water-target gate"),
			("LJ/lua/common/systems/import.lua", "Hunter virtual-projectile scanner")
		};
		for (int i = 0; i < array.Length; i++)
		{
			(string, string) tuple = array[i];
			if (GetResourceText(GetCachedResource(cache, tuple.Item1, tuple.Item2).Stock).IndexOf("-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0", StringComparison.Ordinal) >= 0)
			{
				num++;
			}
		}
		CacheResource cacheResource = TryGetCachedResource(cache, ProjectilePath(), "Hunter isolated projectile");
		if (cacheResource != null)
		{
			if (GetResourceText(cacheResource.Stock).IndexOf("-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0", StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Reserved projectile ID pgr106 already exists without the Hunter marker.");
			}
			num++;
		}
		if (num != 0 && num != 5)
		{
			throw new InvalidOperationException($"A partial Hunter transaction was found ({num}/5 owned resources).");
		}
	}

	private static string BuildVirtualProjectile()
	{
		return "---@type ProjectileTemplate\nProjectileTemplate = {\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Cybran_Hunter_Light_Pulse_Laser\",\n        tpId = \"pgr106\",\n    },\n    nonUniformScale = { x = 0.65, y = 0.65, z = 0.65 },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = {\n            { effects = { { particleName = \"VFX/Impact/vgi1101_cannon_small_impact.sanvfx\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"VFX/Trails/vgt1101_cannon_small_trail.sanvfx\" } } },\n        },\n    },\n}\n\n-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\n-- Source ID: CDFLaserLight01\n-- Source blueprint: projectiles/CDFLaserLight01/CDFLaserLight01_proj.bp\n-- Source blueprint SHA-256: 8cf98d148dd150fe40afc5fb53c20e071a69aeaf5bd67ba22664f3136202ab14\n-- Source script: projectiles/CDFLaserLight01/CDFLaserLight01_script.lua\n-- Source script SHA-256: ba5e37cd799d302d7efdcff955212f139f21e7adcf5c77181af4c9002beb1d43\n-- Source physics: UseGravity=true, DestroyOnWater=true, InitialSpeed=22, Lifetime=2.5.\n-- Weapon overrides speed to 25 and lifetime to range/speed*1.15 = 0.644.\n-- Limitation: FA CLaserLaserProjectile emitters/DestroyOnWater have no native sanvfx/template input;\n-- the isolated projectile uses explicit Guard small-cannon VFX and the weapon's physical water gate.\n-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0";
	}

	private static void ValidateStock(string relativePath, string source)
	{
		switch (relativePath)
		{
		case "LJ/lua/common/units/unitsTemplates/ugl1001/ugl1001.santp":
			RequireTokens(source, "UnitTemplate =", "tpId = \"ugl1001\"", "\"unitsDefaultGuard\"", "\"GuardLandUnit\"");
			RequireExactly(source, "tpId = \"ugl1001\"", 1, "stock ugl1001 tpId");
			if (!Regex.IsMatch(source, "class\\s*=\\s*\\{\\s*\"unitsDefaultGuard\"\\s*,\\s*\"GuardLandUnit\"\\s*,?\\s*\\}", RegexOptions.CultureInvariant))
			{
				throw new InvalidOperationException("UGL1001 no longer exposes its reviewed GuardLandUnit class.");
			}
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

	private static void ValidatePatchedUnit(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0", 1, "Hunter unit marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "mapping = \"URL0106 -> ugl1001\"", "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", "46a3e6cdcbb714067e129a7bae90377a1b5a12b5c680130360aed973ad27bc57", "d891364517e19d2d652237ae0b0a2a077a9d5eb32ff6fbd52c49d26ed043d81c", "8cf98d148dd150fe40afc5fb53c20e071a69aeaf5bd67ba22664f3136202ab14", "ba5e37cd799d302d7efdcff955212f139f21e7adcf5c77181af4c9002beb1d43", "UnitTemplate.general.name = \"Hunter\"", "collisionSize = { x = 0.6, y = 0.6, z = 0.6 }", "centerOffset = { x = 0, y = 0.3, z = 0 }", "UnitTemplate.footprint = { x = 0.6, y = 0.6 }", "max = 65, regen = 0, value = 65", "cost = { alloys = 35, energy = 140 }", "UnitTemplate.intel = { visionRadius = 18 }", "type = \"LegsLand\"", "rotationSpeed = 45", "speed = 4", "authoredSpeed = 0.4", "clipName = \"AnimDeath01\"", "clipName = \"AnimDeath02\"", "clipName = \"AnimFold\"", "clipName = \"AnimWalk\"", "aimBone = \"Turret_Muzzle\"", "pitchMin = -90", "yawMin = -360", "leadTarget = true", "muzzles = { \"Turret_Muzzle\", \"Turret_Muzzle\", \"Turret_Muzzle\" }", "muzzleSalvoDelay = 0.1", "muzzleSalvoSize = 3", "projectileLifetime = 0.644", "projectileTemplate = \"pgr106\"", "reloadTime = 1", "scoFaHunterAboveWater = true", "sourceProjectileDestroyOnWaterRuntime = false");
		RequireExactly(source2, "projectileTemplate = \"pgr106\"", 1, "Hunter projectile route");
		RequireExactly(source2, "\"Turret_Muzzle\", \"Turret_Muzzle\", \"Turret_Muzzle\"", 1, "Hunter parallel triple");
		RequireExactly(source2, "clipName = \"AnimFold\"", 1, "unbound Hunter fold payload");
		RequireNotContains(source2, "pgd111", "AeonProjectiles", "pad002", "pcl001");
		ValidateStock("LJ/lua/common/units/unitsTemplates/ugl1001/ugl1001.santp", source);
	}

	private static void ValidatePatchedGuardHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0", 1, "Hunter Guard-host marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "local SCO_FaHunterStockDeathThread = HostGuardLandUnit.DeathThread", "function HostGuardLandUnit:DeathThread(overkillRatio)", "if self.tpId ~= \"ugl1001\" then", "local bucket = ((self.id and self.id.index) or 0) % 10", "bucket == 0 and animations.death01 or animations.death02", "Engine.PlayAnimation(self.id, death.id, 0.1)", "WaitSeconds(0.46666666865348816)", "return SCO_FaHunterStockDeathThread(self, overkillRatio)");
		RequireNotContains(source2, "AnimFold");
	}

	private static void ValidatePatchedHostWeapon(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0", 1, "Hunter water-gate marker");
		RequireTokens(OwnedAppendix(source), "local SCO_FaHunterStockCanShootAt = HostWeapon.CanShootAt", "if not SCO_FaHunterStockCanShootAt(self, targetUnit) then", "self.unit.tpId ~= \"ugl1001\"", "self.tp.scoFaHunterAboveWater ~= true", "Engine.HasWater()", "Engine.GetWaterLevel()", "targetPosition.y >= waterLevel - 0.05");
	}

	private static void ValidatePatchedImport(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0", 1, "Hunter scanner marker");
		RequireTokens(OwnedAppendix(source), "local SCO_FaHunterScanDir = ScanDir", "local folders = SCO_FaHunterScanDir(directory)", "directory .. \"pgr106\"", "table.insert(folders, hunterFolder)");
	}

	private static void ValidateVirtualProjectile(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0", 1, "Hunter projectile marker");
		RequireTokens(source, "ProjectileTemplate =", "tpId = \"pgr106\"", "name = \"Cybran_Hunter_Light_Pulse_Laser\"", "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12", "8cf98d148dd150fe40afc5fb53c20e071a69aeaf5bd67ba22664f3136202ab14", "ba5e37cd799d302d7efdcff955212f139f21e7adcf5c77181af4c9002beb1d43", "UseGravity=true", "DestroyOnWater=true", "VFX/Impact/vgi1101_cannon_small_impact.sanvfx", "VFX/Trails/vgt1101_cannon_small_trail.sanvfx");
		RequireNotContains(source, "movement =", "AeonProjectiles", "pad002", "pcl001");
	}

	private static void QueueAppend(object cache, ICollection<CacheMutation> mutations, string relativePath, string description, string appendix, Action<string> validate)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		if (resourceText.IndexOf("-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0", StringComparison.Ordinal) >= 0)
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

	private static void QueueVirtualProjectile(object cache, ICollection<CacheMutation> mutations)
	{
		string relativePath = ProjectilePath();
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath, "Hunter isolated projectile");
		if (cacheResource != null)
		{
			string resourceText = GetResourceText(cacheResource.Stock);
			if (resourceText.IndexOf("-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0", StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Reserved projectile ID pgr106 already exists without the Hunter marker.");
			}
			ValidateVirtualProjectile(resourceText);
			return;
		}
		string source = BuildVirtualProjectile();
		ValidateVirtualProjectile(source);
		object obj = CreateNativeArray(GetNativeArrayType(cache), source);
		try
		{
			ValidateVirtualProjectile(GetResourceText(obj));
			mutations.Add(new CacheMutation(ResolvePath(relativePath), null, obj, added: true, "Hunter isolated projectile"));
		}
		catch
		{
			TryDispose(obj, "uncommitted Hunter isolated projectile");
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

	private static string ProjectilePath()
	{
		return "LJ/lua/common/projectiles/projectilesTemplates/pgr106/pgr106.santp";
	}

	private static string OwnedAppendix(string source)
	{
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Hunter marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0".Length, StringComparison.Ordinal);
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
				throw new InvalidOperationException("Hunter-owned Lua must not contain '" + text + "'.");
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
		string text = "[FA Cybran Hunter Cache Patcher] " + message;
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
