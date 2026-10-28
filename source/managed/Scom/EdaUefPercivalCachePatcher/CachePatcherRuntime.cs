using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using SupremeCommanderOverhaul.Shared;

namespace EdaUefPercivalCachePatcher;

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

		public string ImpactVfx { get; }

		public string TrailVfx { get; }

		public string Scale { get; }

		public ProjectileSpec(string id, string name, string sourceId, string blueprintPath, string blueprintSha256, string scriptPath, string scriptSha256, string physicsProfile, string impactVfx, string trailVfx, string scale)
		{
			Id = id;
			Name = name;
			SourceId = sourceId;
			BlueprintPath = blueprintPath;
			BlueprintSha256 = blueprintSha256;
			ScriptPath = scriptPath;
			ScriptSha256 = scriptSha256;
			PhysicsProfile = physicsProfile;
			ImpactVfx = impactVfx;
			TrailVfx = trailVfx;
			Scale = scale;
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

	internal const string OverrideMarker = "-- Supreme Commander Overhaul UEF Percival 1.0.0";

	internal const string SourceUnitsArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	internal const string SourceProjectileArchiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12";

	private const string TemplatePath = "LJ/lua/common/units/unitsTemplates/uel3401/uel3401.santp";

	private const string EdaHostPath = "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua";

	private const string HostWeaponPath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private const string ImportPath = "LJ/lua/common/systems/import.lua";

	private const string AvailableUnitsPath = "LJ/lua/common/units/availableUnits.lua";

	private static readonly ProjectileSpec PercivalProjectile = new ProjectileSpec("pep305", "UEF_Percival_Ionized_Plasma", "TDFIonizedPlasmaGatlingCannon01", "projectiles/TDFIonizedPlasmaGatlingCannon01/TDFIonizedPlasmaGatlingCannon01_proj.bp", "4abb26c07e031a20c0e0584298a7ae22bdb21e4b824abdd9d635d24874555e28", "projectiles/TDFIonizedPlasmaGatlingCannon01/TDFIonizedPlasmaGatlingCannon01_script.lua", "c2fcafc8d9f64ccb03572654dc510d91e0d2f637e0ba981e41ac50632f47c247", "NoGravity", "VFX/Impact/vei1301_cannon_large_impact.sanvfx", "VFX/Trails/vet1301_cannon_large_trail.sanvfx", "0.8");

	private const string TemplateAppendix = "-- Supreme Commander Overhaul UEF Percival 1.0.0\n-- Exact FA XEL0305 gameplay/rig port into the dormant EDA uel3401 NO_MODEL\n-- slot. Sanctuary class identity remains unitsDefaultEDA/EDALandUnit.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.55, y = 0.5 },\n    offset = { x = 0, y = 0.8, z = 0 },\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"XEL0305 -> uel3401\",\n    substitution = false,\n    targetOccupancy = {\n        stockTemplateSha256 = \"0a9380943f549b0746e1478bc0ec33e0dc98d30216f6be124de20fc4aed20716\",\n        stockAvailableUnits = false,\n        stockNoModel = true,\n        canonicalModuleReferencesBeforePort = 0,\n    },\n    sourceUnitsArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceTexturesArchiveSha256 = \"5f48e3e283759cb71b65e6501063d0d4bd586fe67fc1cfa27672250d1a4f8ffd\",\n    sourceProjectileArchiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n    sourceEffectsArchiveSha256 = \"f0dcbf76b2c3381e7d9ebbd7e09613e046875f6ba3a788406e5635768e28a300\",\n    sourceBlueprint = \"units/XEL0305/XEL0305_unit.bp\",\n    sourceBlueprintSha256 = \"fe188417a1bba7346013a71cb2ff3ef6b27eac67e85b326cee21eba143568bce\",\n    sourceScript = \"units/XEL0305/XEL0305_Script.lua\",\n    sourceScriptSha256 = \"9f45fb493193021a8b5e7160d794f93310e58f22d257fe8f5a0926d164dbe0af\",\n    sourceClass = { unit = \"TWalkingLandUnit\", weapon = \"TDFIonizedPlasmaCannon\" },\n    sanctuaryClass = { owner = \"unitsDefaultEDA\", name = \"EDALandUnit\" },\n    model = {\n        source = \"units/XEL0305/XEL0305_lod0.scm\",\n        sha256 = \"ac24c4dc8105ed71d798dcec6bd05ba643bc3f7c705b2c0849561dd711b3be87\",\n        vertices = 2201, indices = 4962, bones = 14, uniformScale = 0.063,\n        coordinateConversion = \"mobile identity\",\n        rigAlias = {\n            model = \"AttachPoint\", animation = \"Attachpoint_01\",\n            foldException = \"AnimFold source track is model-native AttachPoint\",\n        },\n    },\n    materials = {\n        policy = \"UEF industrial 2K derived DDS; normal is authored normal, mask packs specular-derived PBR channels\",\n        albedoSha256 = \"d9c38873dc8d8a23dcdb01a489fbb5848e28d0648fcb591aa7ef44777f379f84\",\n        normalSha256 = \"981bee4501d7cfe4bd73a8f9f7e8fc6239aef765da1418e885f5a5cb7f2841e0\",\n        specularSha256 = \"437789d46032cbb7781ab894254cfab4367c13195fe5702a7331d88b55da525f\",\n        iconSha256 = \"09552e30ea6afd39973ff8f950bb5cf0b738833fe43727ea1db9e5fcd26cfaa1\",\n    },\n    collision = { size = { x = 0.8, y = 1.6, z = 0.8 }, offset = { x = 0, y = 0, z = 0 } },\n    selection = { x = 0.55, z = 0.5, centerX = 0, centerZ = 0, thickness = 0.7 },\n    defence = { health = 9300, regen = 0 },\n    economy = { buildCostEnergy = 14000, buildCostMass = 1280, buildTime = 4800 },\n    intel = { visionRadius = 26, waterVisionRadius = 26 },\n    movement = {\n        sourceMotionType = \"RULEUMT_Amphibious\",\n        acceleration = 2, brake = 2, speed = 2, reverseSpeed = 2,\n        steerForce = 10, turnRadius = 5, turnRate = 60,\n        rotateOnSpot = false, standUpright = true,\n        sourceAnimationWalkRate = 2, sanctuaryAuthoredSpeed = 1,\n    },\n    animations = {\n        walk = { source = \"units/XEL0305/XEL0305_awalk.sca\", sha256 = \"c2018d2938d5fa8c94cac5d80728e3b058bbd351b271105c3cadd5e741cadb5f\", frames = 61, duration = 2 },\n        death01 = { source = \"units/XEL0305/XEL0305_adeath.sca\", sha256 = \"ddd0ed0ec49c1b1dd84246da5c34a1cc00b0fe4586c5e6ae47506d88ca9d78c8\", frames = 61, duration = 2, weight = 1 },\n        death02 = { source = \"units/XEL0305/XEL0305_adeath02.sca\", sha256 = \"5d2de83fa07810ea231522b97de20723c2e503ebf0dd4caf494cff4a197d0a92\", frames = 71, duration = 2.3333332538604736, weight = 1 },\n        death03 = { source = \"units/XEL0305/XEL0305_adeath03.sca\", sha256 = \"13eb370f9215f92a0493da55cbade30003dde47960e0b43c020922810ab65c91\", frames = 61, duration = 2, weight = 1 },\n        fold = { source = \"units/XEL0305/XEL0305_Afold01.sca\", sha256 = \"49553406c6946174f6e502082092d41bee4f61330606153f5a512a16a3ca8cf0\", frames = 61, duration = 2 },\n        deathSelection = \"deterministic equal-weight unit-index thirds\",\n    },\n    weapon = {\n        label = \"Ionized Plasma Cannon\",\n        damage = 1600, damageRadius = 0, rateOfFire = 0.25,\n        range = 35, muzzleVelocity = 35, projectileLifetimeMultiplier = 1.15,\n        rackBone = \"Turret_Barrel\", muzzleBone = \"Muzzle\",\n        rackCount = 1, muzzlesPerRack = 1, projectilesPerOnFire = 1,\n        rackFireTogether = false, muzzleSalvoSize = 1,\n        turretYawBone = \"Turret\", turretYawRange = 180, turretYawSpeed = 60,\n        turretPitchBone = \"Turret_Barrel\", defaultPitch = 10,\n        turretPitchMin = -80, turretPitchMax = 100, turretPitchSpeed = 30,\n        aimTolerance = 2, ballisticArc = \"LowArc\",\n        aboveWaterFireOnly = true, aboveWaterTargetsOnly = true,\n        collideFriendly = false, damageFriendly = false,\n    },\n    projectile = {\n        sourceId = \"TDFIonizedPlasmaGatlingCannon01\",\n        sourceBlueprintSha256 = \"4abb26c07e031a20c0e0584298a7ae22bdb21e4b824abdd9d635d24874555e28\",\n        sourceScriptSha256 = \"c2fcafc8d9f64ccb03572654dc510d91e0d2f637e0ba981e41ac50632f47c247\",\n        sanctuaryId = \"pep305\", sourceInitialSpeed = 14.6,\n        sourceInitialSpeedReduceDistance = 30, sourceTurnRate = 360,\n        sourceVelocityAlign = true, sourceDestroyOnWater = true,\n    },\n    limitations = {\n        sourceDeathRateRandomization = \"0.75-1.25 unavailable; nominal rate used\",\n        sourceDeathWeightedRandom = \"deterministic unit-index thirds preserve equal weights\",\n        sourceMaxReverseSpeedRuntime = \"Sanctuary movement exposes one speed; forward speed 2 preserved\",\n        sourceTurnRadiusRuntime = false,\n        sourceSteerForceRuntime = false,\n        sourceFoldTransportRuntime = \"clip preserved as unbound payload; no Sanctuary transport-fold callback\",\n        sourceGroundKickupEffects = false,\n        sourceAudioBanks = false,\n        sourceProjectileEmitterGraphs = \"compatibility UEF sanvfx used; FA emitter graph retained by hash\",\n        sourceProjectileDestroyOnWaterRuntime = false,\n        sourceProjectileInitialSpeedReduceDistanceRuntime = \"weapon reduceMuzzleVelocityToTarget used as closest native equivalent\",\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 3: Armored Assault Bot\"\nUnitTemplate.general.name = \"Percival\"\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"direct\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 20\nUnitTemplate.general.iconUIType = \"amphibious\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = nil\nUnitTemplate.audio = nil\n\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.8, z = 0 },\n    collisionSize = { x = 0.8, y = 1.6, z = 0.8 },\n}\nUnitTemplate.footprint = { x = 0.8, y = 0.8 }\nUnitTemplate.defence = { health = { max = 9300, regen = 0, value = 9300 } }\nUnitTemplate.economy = {\n    buildTime = 4800,\n    cost = { alloys = 1280, energy = 14000 },\n}\nUnitTemplate.intel = { visionRadius = 26, waterVisionRadius = 26 }\nUnitTemplate.movement = {\n    acceleration = 2,\n    deceleration = 2,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"SeabedSmall\" },\n    collisionMaskSpawn = { \"SeabedSmall\" },\n    maxReverseDistance = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotationSpeed = 60,\n    sortOrder = 1,\n    speed = 2,\n    terrainAlignmentFactor = 1,\n    type = \"LegsSeabed\",\n    walkAnimation = { authoredSpeed = 1 },\n}\nUnitTemplate.tags = {\n    \"AMPHIBIOUS\", \"ANTI_SURFACE\", \"BOT\", \"BUILDABLE_BY_T3_FACTORY\",\n    \"DIRECT_FIRE\", \"EDA\", \"LAND\", \"MOBILE\", \"SEABED\", \"TECH3\", \"WALKER\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.55, y = 0.5 },\n    offset = { x = 0, y = 0.8, z = 0 },\n}\nUnitTemplate.visuals.animations = {\n    death01 = { clipName = \"AnimDeath01\", sanAnimationPath = \"Units/uel3401/LOD0/uel3401.sananimation\" },\n    death02 = { clipName = \"AnimDeath02\", sanAnimationPath = \"Units/uel3401/LOD0/uel3401.sananimation\" },\n    death03 = { clipName = \"AnimDeath03\", sanAnimationPath = \"Units/uel3401/LOD0/uel3401.sananimation\" },\n    fold = { clipName = \"AnimFold\", sanAnimationPath = \"Units/uel3401/LOD0/uel3401.sananimation\" },\n    rest = { clipName = \"Rest\", sanAnimationPath = \"Units/uel3401/LOD0/uel3401.sananimation\" },\n    walk = { authoredSpeed = 1, clipName = \"AnimWalk01\", sanAnimationPath = \"Units/uel3401/LOD0/uel3401.sananimation\" },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Muzzle\",\n                aimTolerance = 2,\n                defaultPitchAdjustment = 10,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = \"Turret_Barrel\",\n                pitchMax = 100,\n                pitchMin = -80,\n                pitchSpeed = 30,\n                poseResetTime = 3,\n                projectileSpeed = 35,\n                reduceMuzzleVelocityToTarget = true,\n                solverType = \"LowArc\",\n                yawBone = \"Turret\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 60,\n            },\n        },\n        collideFriendly = false,\n        damage = 1600,\n        damageFriendly = false,\n        damageRadius = 0,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vem1301_cannon_large_muzzle.sanvfx\" },\n        firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\", \"Seabed\" },\n        layerWeaponLimits = { \"Land\", \"Seabed\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Muzzle\" } } },\n        muzzles = { Muzzle = { aimController = \"Muzzle\" } },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 1.15,\n        projectileTemplate = \"pep305\",\n        rangeMax = 35,\n        rangeMin = 0,\n        rangeRingType = \"DirectFire\",\n        rangeTracking = 1.15,\n        reloadTime = 4,\n        targetWaterLimits = \"Above\",\n        scoFaPercivalWaterGate = \"OwnerAndTargetAbove\",\n    },\n}";

	private const string EdaHostAppendix = "-- Supreme Commander Overhaul UEF Percival 1.0.0\n-- HostUnit:Destroy marks the unit dead before starting DeathThread. Preserve\n-- the three equal-weight FA terminal clips while collision is disabled.\nlocal SCO_PercivalStockDeathThread = HostEDALandUnit.DeathThread\nfunction HostEDALandUnit:DeathThread(overkillRatio)\n    if self.tpId ~= \"uel3401\" then\n        return SCO_PercivalStockDeathThread(self, overkillRatio)\n    end\n    if not self.dead then\n        error(\"UEL3401 Percival death animation must run after HostUnit:OnDestroy\")\n    end\n    Engine.SetMovementCollisionMask(self.id, 0)\n    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations\n    local bucket = ((self.id and self.id.index) or 0) % 3\n    local death = animations and (bucket == 0 and animations.death01\n        or bucket == 1 and animations.death02 or animations.death03)\n    if not death or not death.id then\n        error(\"UEL3401 Percival requires all three source-pinned death clips\")\n    end\n    Engine.PlayAnimation(self.id, death.id, 0.1)\n    WaitSeconds(bucket == 1 and 2.3333332538604736 or 2)\n    return SCO_PercivalStockDeathThread(self, overkillRatio)\nend";

	private const string HostWeaponAppendix = "-- Supreme Commander Overhaul UEF Percival 1.0.0\n-- FA AboveWaterFireOnly and AboveWaterTargetsOnly are physical constraints,\n-- not merely target-layer labels. Chain the current host gate.\nlocal SCO_PercivalStockCanShootAt = HostWeapon.CanShootAt\nfunction HostWeapon:CanShootAt(targetUnit)\n    if not SCO_PercivalStockCanShootAt(self, targetUnit) then return false end\n    if not self.unit or self.unit.tpId ~= \"uel3401\" then return true end\n    if not self.tp or self.tp.scoFaPercivalWaterGate ~= \"OwnerAndTargetAbove\" then\n        return true\n    end\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return true end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return false end\n    local ownerPosition = self.unit:GetPosition()\n    local targetPosition = targetUnit and targetUnit:GetPosition()\n    if ownerPosition == nil or targetPosition == nil then return false end\n    local margin = 0.05\n    return ownerPosition.y >= waterLevel - margin\n        and targetPosition.y >= waterLevel - margin\nend";

	private const string ImportAppendix = "-- Supreme Commander Overhaul UEF Percival 1.0.0\n-- pep305 exists only in FilesCache; chain all earlier virtual scanners.\nlocal SCO_PercivalScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_PercivalScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then return folders end\n    local candidate = directory .. \"pep305\"\n    for _, folder in ipairs(folders) do\n        if folder == candidate then return folders end\n    end\n    table.insert(folders, candidate)\n    return folders\nend";

	private const string AvailableUnitsAppendix = "-- Supreme Commander Overhaul UEF Percival 1.0.0\n-- uel3401 is a stock NO_MODEL demonstration placeholder. The source-pinned\n-- overlay and gameplay transaction make it a real factory-buildable unit.\nAvailableUnits[\"uel3401\"] = true";

	public static void Apply()
	{
		ValidatePinnedScope();
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>(6);
		try
		{
			obj = GetLuaFileCache();
			ValidateTransactionState(obj);
			QueueAppend(obj, list, "LJ/lua/common/units/unitsTemplates/uel3401/uel3401.santp", "UEL3401 Percival template", "-- Supreme Commander Overhaul UEF Percival 1.0.0\n-- Exact FA XEL0305 gameplay/rig port into the dormant EDA uel3401 NO_MODEL\n-- slot. Sanctuary class identity remains unitsDefaultEDA/EDALandUnit.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.55, y = 0.5 },\n    offset = { x = 0, y = 0.8, z = 0 },\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"XEL0305 -> uel3401\",\n    substitution = false,\n    targetOccupancy = {\n        stockTemplateSha256 = \"0a9380943f549b0746e1478bc0ec33e0dc98d30216f6be124de20fc4aed20716\",\n        stockAvailableUnits = false,\n        stockNoModel = true,\n        canonicalModuleReferencesBeforePort = 0,\n    },\n    sourceUnitsArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceTexturesArchiveSha256 = \"5f48e3e283759cb71b65e6501063d0d4bd586fe67fc1cfa27672250d1a4f8ffd\",\n    sourceProjectileArchiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n    sourceEffectsArchiveSha256 = \"f0dcbf76b2c3381e7d9ebbd7e09613e046875f6ba3a788406e5635768e28a300\",\n    sourceBlueprint = \"units/XEL0305/XEL0305_unit.bp\",\n    sourceBlueprintSha256 = \"fe188417a1bba7346013a71cb2ff3ef6b27eac67e85b326cee21eba143568bce\",\n    sourceScript = \"units/XEL0305/XEL0305_Script.lua\",\n    sourceScriptSha256 = \"9f45fb493193021a8b5e7160d794f93310e58f22d257fe8f5a0926d164dbe0af\",\n    sourceClass = { unit = \"TWalkingLandUnit\", weapon = \"TDFIonizedPlasmaCannon\" },\n    sanctuaryClass = { owner = \"unitsDefaultEDA\", name = \"EDALandUnit\" },\n    model = {\n        source = \"units/XEL0305/XEL0305_lod0.scm\",\n        sha256 = \"ac24c4dc8105ed71d798dcec6bd05ba643bc3f7c705b2c0849561dd711b3be87\",\n        vertices = 2201, indices = 4962, bones = 14, uniformScale = 0.063,\n        coordinateConversion = \"mobile identity\",\n        rigAlias = {\n            model = \"AttachPoint\", animation = \"Attachpoint_01\",\n            foldException = \"AnimFold source track is model-native AttachPoint\",\n        },\n    },\n    materials = {\n        policy = \"UEF industrial 2K derived DDS; normal is authored normal, mask packs specular-derived PBR channels\",\n        albedoSha256 = \"d9c38873dc8d8a23dcdb01a489fbb5848e28d0648fcb591aa7ef44777f379f84\",\n        normalSha256 = \"981bee4501d7cfe4bd73a8f9f7e8fc6239aef765da1418e885f5a5cb7f2841e0\",\n        specularSha256 = \"437789d46032cbb7781ab894254cfab4367c13195fe5702a7331d88b55da525f\",\n        iconSha256 = \"09552e30ea6afd39973ff8f950bb5cf0b738833fe43727ea1db9e5fcd26cfaa1\",\n    },\n    collision = { size = { x = 0.8, y = 1.6, z = 0.8 }, offset = { x = 0, y = 0, z = 0 } },\n    selection = { x = 0.55, z = 0.5, centerX = 0, centerZ = 0, thickness = 0.7 },\n    defence = { health = 9300, regen = 0 },\n    economy = { buildCostEnergy = 14000, buildCostMass = 1280, buildTime = 4800 },\n    intel = { visionRadius = 26, waterVisionRadius = 26 },\n    movement = {\n        sourceMotionType = \"RULEUMT_Amphibious\",\n        acceleration = 2, brake = 2, speed = 2, reverseSpeed = 2,\n        steerForce = 10, turnRadius = 5, turnRate = 60,\n        rotateOnSpot = false, standUpright = true,\n        sourceAnimationWalkRate = 2, sanctuaryAuthoredSpeed = 1,\n    },\n    animations = {\n        walk = { source = \"units/XEL0305/XEL0305_awalk.sca\", sha256 = \"c2018d2938d5fa8c94cac5d80728e3b058bbd351b271105c3cadd5e741cadb5f\", frames = 61, duration = 2 },\n        death01 = { source = \"units/XEL0305/XEL0305_adeath.sca\", sha256 = \"ddd0ed0ec49c1b1dd84246da5c34a1cc00b0fe4586c5e6ae47506d88ca9d78c8\", frames = 61, duration = 2, weight = 1 },\n        death02 = { source = \"units/XEL0305/XEL0305_adeath02.sca\", sha256 = \"5d2de83fa07810ea231522b97de20723c2e503ebf0dd4caf494cff4a197d0a92\", frames = 71, duration = 2.3333332538604736, weight = 1 },\n        death03 = { source = \"units/XEL0305/XEL0305_adeath03.sca\", sha256 = \"13eb370f9215f92a0493da55cbade30003dde47960e0b43c020922810ab65c91\", frames = 61, duration = 2, weight = 1 },\n        fold = { source = \"units/XEL0305/XEL0305_Afold01.sca\", sha256 = \"49553406c6946174f6e502082092d41bee4f61330606153f5a512a16a3ca8cf0\", frames = 61, duration = 2 },\n        deathSelection = \"deterministic equal-weight unit-index thirds\",\n    },\n    weapon = {\n        label = \"Ionized Plasma Cannon\",\n        damage = 1600, damageRadius = 0, rateOfFire = 0.25,\n        range = 35, muzzleVelocity = 35, projectileLifetimeMultiplier = 1.15,\n        rackBone = \"Turret_Barrel\", muzzleBone = \"Muzzle\",\n        rackCount = 1, muzzlesPerRack = 1, projectilesPerOnFire = 1,\n        rackFireTogether = false, muzzleSalvoSize = 1,\n        turretYawBone = \"Turret\", turretYawRange = 180, turretYawSpeed = 60,\n        turretPitchBone = \"Turret_Barrel\", defaultPitch = 10,\n        turretPitchMin = -80, turretPitchMax = 100, turretPitchSpeed = 30,\n        aimTolerance = 2, ballisticArc = \"LowArc\",\n        aboveWaterFireOnly = true, aboveWaterTargetsOnly = true,\n        collideFriendly = false, damageFriendly = false,\n    },\n    projectile = {\n        sourceId = \"TDFIonizedPlasmaGatlingCannon01\",\n        sourceBlueprintSha256 = \"4abb26c07e031a20c0e0584298a7ae22bdb21e4b824abdd9d635d24874555e28\",\n        sourceScriptSha256 = \"c2fcafc8d9f64ccb03572654dc510d91e0d2f637e0ba981e41ac50632f47c247\",\n        sanctuaryId = \"pep305\", sourceInitialSpeed = 14.6,\n        sourceInitialSpeedReduceDistance = 30, sourceTurnRate = 360,\n        sourceVelocityAlign = true, sourceDestroyOnWater = true,\n    },\n    limitations = {\n        sourceDeathRateRandomization = \"0.75-1.25 unavailable; nominal rate used\",\n        sourceDeathWeightedRandom = \"deterministic unit-index thirds preserve equal weights\",\n        sourceMaxReverseSpeedRuntime = \"Sanctuary movement exposes one speed; forward speed 2 preserved\",\n        sourceTurnRadiusRuntime = false,\n        sourceSteerForceRuntime = false,\n        sourceFoldTransportRuntime = \"clip preserved as unbound payload; no Sanctuary transport-fold callback\",\n        sourceGroundKickupEffects = false,\n        sourceAudioBanks = false,\n        sourceProjectileEmitterGraphs = \"compatibility UEF sanvfx used; FA emitter graph retained by hash\",\n        sourceProjectileDestroyOnWaterRuntime = false,\n        sourceProjectileInitialSpeedReduceDistanceRuntime = \"weapon reduceMuzzleVelocityToTarget used as closest native equivalent\",\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 3: Armored Assault Bot\"\nUnitTemplate.general.name = \"Percival\"\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"direct\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_land1_direct.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 20\nUnitTemplate.general.iconUIType = \"amphibious\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = nil\nUnitTemplate.audio = nil\n\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.8, z = 0 },\n    collisionSize = { x = 0.8, y = 1.6, z = 0.8 },\n}\nUnitTemplate.footprint = { x = 0.8, y = 0.8 }\nUnitTemplate.defence = { health = { max = 9300, regen = 0, value = 9300 } }\nUnitTemplate.economy = {\n    buildTime = 4800,\n    cost = { alloys = 1280, energy = 14000 },\n}\nUnitTemplate.intel = { visionRadius = 26, waterVisionRadius = 26 }\nUnitTemplate.movement = {\n    acceleration = 2,\n    deceleration = 2,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"SeabedSmall\" },\n    collisionMaskSpawn = { \"SeabedSmall\" },\n    maxReverseDistance = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotationSpeed = 60,\n    sortOrder = 1,\n    speed = 2,\n    terrainAlignmentFactor = 1,\n    type = \"LegsSeabed\",\n    walkAnimation = { authoredSpeed = 1 },\n}\nUnitTemplate.tags = {\n    \"AMPHIBIOUS\", \"ANTI_SURFACE\", \"BOT\", \"BUILDABLE_BY_T3_FACTORY\",\n    \"DIRECT_FIRE\", \"EDA\", \"LAND\", \"MOBILE\", \"SEABED\", \"TECH3\", \"WALKER\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = {\n    size = { x = 0.55, y = 0.5 },\n    offset = { x = 0, y = 0.8, z = 0 },\n}\nUnitTemplate.visuals.animations = {\n    death01 = { clipName = \"AnimDeath01\", sanAnimationPath = \"Units/uel3401/LOD0/uel3401.sananimation\" },\n    death02 = { clipName = \"AnimDeath02\", sanAnimationPath = \"Units/uel3401/LOD0/uel3401.sananimation\" },\n    death03 = { clipName = \"AnimDeath03\", sanAnimationPath = \"Units/uel3401/LOD0/uel3401.sananimation\" },\n    fold = { clipName = \"AnimFold\", sanAnimationPath = \"Units/uel3401/LOD0/uel3401.sananimation\" },\n    rest = { clipName = \"Rest\", sanAnimationPath = \"Units/uel3401/LOD0/uel3401.sananimation\" },\n    walk = { authoredSpeed = 1, clipName = \"AnimWalk01\", sanAnimationPath = \"Units/uel3401/LOD0/uel3401.sananimation\" },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Muzzle\",\n                aimTolerance = 2,\n                defaultPitchAdjustment = 10,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = \"Turret_Barrel\",\n                pitchMax = 100,\n                pitchMin = -80,\n                pitchSpeed = 30,\n                poseResetTime = 3,\n                projectileSpeed = 35,\n                reduceMuzzleVelocityToTarget = true,\n                solverType = \"LowArc\",\n                yawBone = \"Turret\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 60,\n            },\n        },\n        collideFriendly = false,\n        damage = 1600,\n        damageFriendly = false,\n        damageRadius = 0,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vem1301_cannon_large_muzzle.sanvfx\" },\n        firingRandomness = 0,\n        layerTargetLimits = { \"Land\", \"WaterSurface\", \"Seabed\" },\n        layerWeaponLimits = { \"Land\", \"Seabed\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = -1,\n        muzzleGroups = { { muzzles = { \"Muzzle\" } } },\n        muzzles = { Muzzle = { aimController = \"Muzzle\" } },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 1.15,\n        projectileTemplate = \"pep305\",\n        rangeMax = 35,\n        rangeMin = 0,\n        rangeRingType = \"DirectFire\",\n        rangeTracking = 1.15,\n        reloadTime = 4,\n        targetWaterLimits = \"Above\",\n        scoFaPercivalWaterGate = \"OwnerAndTargetAbove\",\n    },\n}", ValidateTemplate);
			QueueAppend(obj, list, "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", "Percival death lifecycle", "-- Supreme Commander Overhaul UEF Percival 1.0.0\n-- HostUnit:Destroy marks the unit dead before starting DeathThread. Preserve\n-- the three equal-weight FA terminal clips while collision is disabled.\nlocal SCO_PercivalStockDeathThread = HostEDALandUnit.DeathThread\nfunction HostEDALandUnit:DeathThread(overkillRatio)\n    if self.tpId ~= \"uel3401\" then\n        return SCO_PercivalStockDeathThread(self, overkillRatio)\n    end\n    if not self.dead then\n        error(\"UEL3401 Percival death animation must run after HostUnit:OnDestroy\")\n    end\n    Engine.SetMovementCollisionMask(self.id, 0)\n    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations\n    local bucket = ((self.id and self.id.index) or 0) % 3\n    local death = animations and (bucket == 0 and animations.death01\n        or bucket == 1 and animations.death02 or animations.death03)\n    if not death or not death.id then\n        error(\"UEL3401 Percival requires all three source-pinned death clips\")\n    end\n    Engine.PlayAnimation(self.id, death.id, 0.1)\n    WaitSeconds(bucket == 1 and 2.3333332538604736 or 2)\n    return SCO_PercivalStockDeathThread(self, overkillRatio)\nend", ValidateEdaHost);
			QueueAppend(obj, list, "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "Percival water gate", "-- Supreme Commander Overhaul UEF Percival 1.0.0\n-- FA AboveWaterFireOnly and AboveWaterTargetsOnly are physical constraints,\n-- not merely target-layer labels. Chain the current host gate.\nlocal SCO_PercivalStockCanShootAt = HostWeapon.CanShootAt\nfunction HostWeapon:CanShootAt(targetUnit)\n    if not SCO_PercivalStockCanShootAt(self, targetUnit) then return false end\n    if not self.unit or self.unit.tpId ~= \"uel3401\" then return true end\n    if not self.tp or self.tp.scoFaPercivalWaterGate ~= \"OwnerAndTargetAbove\" then\n        return true\n    end\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return true end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return false end\n    local ownerPosition = self.unit:GetPosition()\n    local targetPosition = targetUnit and targetUnit:GetPosition()\n    if ownerPosition == nil or targetPosition == nil then return false end\n    local margin = 0.05\n    return ownerPosition.y >= waterLevel - margin\n        and targetPosition.y >= waterLevel - margin\nend", ValidateHostWeapon);
			QueueAppend(obj, list, "LJ/lua/common/systems/import.lua", "Percival projectile scanner", "-- Supreme Commander Overhaul UEF Percival 1.0.0\n-- pep305 exists only in FilesCache; chain all earlier virtual scanners.\nlocal SCO_PercivalScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_PercivalScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then return folders end\n    local candidate = directory .. \"pep305\"\n    for _, folder in ipairs(folders) do\n        if folder == candidate then return folders end\n    end\n    table.insert(folders, candidate)\n    return folders\nend", ValidateImport);
			QueueAppend(obj, list, "LJ/lua/common/units/availableUnits.lua", "Percival available-unit registration", "-- Supreme Commander Overhaul UEF Percival 1.0.0\n-- uel3401 is a stock NO_MODEL demonstration placeholder. The source-pinned\n-- overlay and gameplay transaction make it a real factory-buildable unit.\nAvailableUnits[\"uel3401\"] = true", ValidateAvailableUnits);
			QueueVirtualProjectile(obj, list, PercivalProjectile);
			if (list.Count == 0)
			{
				Log("XEL0305 -> uel3401 gameplay transaction is already current.");
				return;
			}
			Commit(obj, list);
			Log("Applied atomic XEL0305 -> uel3401 Percival template, lifecycle, water gate, scanner, availability, and projectile.");
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
			Log($"Failed to apply the UEF Percival transaction: {arg}");
			throw;
		}
	}

	private static void ValidatePinnedScope()
	{
		string[] source = new string[6] { "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12", "fe188417a1bba7346013a71cb2ff3ef6b27eac67e85b326cee21eba143568bce", "9f45fb493193021a8b5e7160d794f93310e58f22d257fe8f5a0926d164dbe0af", PercivalProjectile.BlueprintSha256, PercivalProjectile.ScriptSha256 };
		if (PercivalProjectile.Id != "pep305" || source.Any((string hash) => hash.Length != 64))
		{
			throw new InvalidOperationException("The reviewed Percival source/projectile scope changed.");
		}
	}

	private static void ValidateTransactionState(object cache)
	{
		int num = 0;
		(string, string)[] array = new(string, string)[5]
		{
			("LJ/lua/common/units/unitsTemplates/uel3401/uel3401.santp", "UEL3401 Percival template"),
			("LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", "Percival death lifecycle"),
			("LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "Percival water gate"),
			("LJ/lua/common/systems/import.lua", "Percival projectile scanner"),
			("LJ/lua/common/units/availableUnits.lua", "Percival available-unit registration")
		};
		for (int i = 0; i < array.Length; i++)
		{
			var (relativePath, description) = array[i];
			if (GetResourceText(GetCachedResource(cache, relativePath, description).Stock).IndexOf("-- Supreme Commander Overhaul UEF Percival 1.0.0", StringComparison.Ordinal) >= 0)
			{
				num++;
			}
		}
		CacheResource cacheResource = TryGetCachedResource(cache, ProjectilePath(PercivalProjectile.Id), "Percival projectile");
		if (cacheResource != null)
		{
			if (GetResourceText(cacheResource.Stock).IndexOf("-- Supreme Commander Overhaul UEF Percival 1.0.0", StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Reserved projectile ID pep305 is occupied by another owner.");
			}
			num++;
		}
		if (num != 0 && num != 6)
		{
			throw new InvalidOperationException($"A partial Percival transaction was found ({num}/6 resources).");
		}
	}

	private static string BuildVirtualProjectile(ProjectileSpec projectile)
	{
		return "---@type ProjectileTemplate\nProjectileTemplate = {\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"" + projectile.Name + "\",\n        tpId = \"" + projectile.Id + "\",\n    },\n    movement = { gravityMultiplier = 0 },\n    nonUniformScale = { x = " + projectile.Scale + ", y = " + projectile.Scale + ", z = " + projectile.Scale + " },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = {\n            { effects = { { particleName = \"" + projectile.ImpactVfx + "\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"" + projectile.TrailVfx + "\" } } },\n        },\n    },\n}\n\n-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\n-- Source ID: " + projectile.SourceId + "\n-- Source blueprint: " + projectile.BlueprintPath + "\n-- Source blueprint SHA-256: " + projectile.BlueprintSha256 + "\n-- Source script: " + projectile.ScriptPath + "\n-- Source script SHA-256: " + projectile.ScriptSha256 + "\n-- Source physics: initial speed 14.6, speed-reduce distance 30, turn rate 360,\n-- velocity alignment true, no target lead, DestroyOnWater true.\n-- Limitations: FA emitter graphs and DestroyOnWater are unavailable; pinned\n-- compatibility UEF sanvfx and the unit's above-water physical gate are used.\n-- Supreme Commander Overhaul UEF Percival 1.0.0";
	}

	private static void ValidateStock(string relativePath, string source)
	{
		switch (relativePath)
		{
		case "LJ/lua/common/units/unitsTemplates/uel3401/uel3401.santp":
			RequireTokens(source, "UnitTemplate =", "tpId = \"uel3401\"", "\"unitsDefaultEDA\"", "\"EDALandUnit\"");
			RequireExactly(source, "tpId = \"uel3401\"", 1, "stock uel3401 tpId");
			if (!Regex.IsMatch(source, "class\\s*=\\s*\\{\\s*\\\"unitsDefaultEDA\\\"\\s*,\\s*\\\"EDALandUnit\\\"\\s*,?\\s*\\}", RegexOptions.CultureInvariant))
			{
				throw new InvalidOperationException("uel3401 no longer exposes its reviewed EDALandUnit class.");
			}
			break;
		case "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua":
			RequireTokens(source, "HostEDALandUnit = Class(\"EDALandUnit\", LandUnit)", "HostEDACommander");
			break;
		case "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua":
			RequireTokens(source, "function HostWeapon:CanShootAt(targetUnit)", "self.layerWeaponLimitsMask", "self.layerTargetLimitsMask");
			break;
		case "LJ/lua/common/systems/import.lua":
			RequireTokens(source, "function ScanDir", "Engine.GetFoldersInsideDirectory");
			break;
		case "LJ/lua/common/units/availableUnits.lua":
			RequireTokens(source, "AvailableUnits =", "uel3401 = false");
			break;
		default:
			throw new InvalidOperationException("Unexpected Percival cache path: " + relativePath);
		}
	}

	private static void ValidateTemplate(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul UEF Percival 1.0.0", 1, "Percival template marker");
		string text = OwnedAppendix(source);
		RequireTokens(text, "mapping = \"XEL0305 -> uel3401\"", "targetOccupancy = {", "stockAvailableUnits = false", "sourceBlueprintSha256 = \"fe188417a1bba7346013a71cb2ff3ef6b27eac67e85b326cee21eba143568bce\"", "sourceScriptSha256 = \"9f45fb493193021a8b5e7160d794f93310e58f22d257fe8f5a0926d164dbe0af\"", "UnitTemplate.general.name = \"Percival\"", "collisionSize = { x = 0.8, y = 1.6, z = 0.8 }", "max = 9300, regen = 0, value = 9300", "cost = { alloys = 1280, energy = 14000 }", "visionRadius = 26, waterVisionRadius = 26", "type = \"LegsSeabed\"", "rotationSpeed = 60", "speed = 2", "authoredSpeed = 1", "clipName = \"Rest\"", "clipName = \"AnimWalk01\"", "clipName = \"AnimDeath01\"", "clipName = \"AnimDeath02\"", "clipName = \"AnimDeath03\"", "clipName = \"AnimFold\"", "aimBone = \"Muzzle\"", "yawBone = \"Turret\"", "pitchBone = \"Turret_Barrel\"", "damage = 1600", "projectileTemplate = \"pep305\"", "reloadTime = 4", "scoFaPercivalWaterGate = \"OwnerAndTargetAbove\"", "sourceFoldTransportRuntime =", "sourceProjectileEmitterGraphs =", "sourceProjectileDestroyOnWaterRuntime = false");
		ValidateRigAlias(text);
		RequireExactly(text, "projectileTemplate = \"pep305\"", 1, "Percival isolated projectile route");
		RequireExactly(text, "clipName = \"AnimDeath", 3, "Percival death clip bindings");
		RequireExactly(text, "{ muzzles = { \"Muzzle\" } }", 1, "Percival single source rack");
		RequireNotContains(text, "pad002", "pcl001", "AeonProjectiles");
		ValidateStock("LJ/lua/common/units/unitsTemplates/uel3401/uel3401.santp", source);
	}

	private static void ValidateRigAlias(string owned)
	{
		MatchCollection matchCollection = Regex.Matches(owned, "\\brigAlias\\s*=\\s*\\{(?<body>[^{}]*)\\}", RegexOptions.Singleline | RegexOptions.CultureInvariant);
		if (matchCollection.Count != 1)
		{
			throw new InvalidOperationException("Expected exactly one flat Percival rigAlias table, found " + matchCollection.Count + ".");
		}
		string value = matchCollection[0].Groups["body"].Value;
		RequireRigAliasField(value, "model", "AttachPoint");
		RequireRigAliasField(value, "animation", "Attachpoint_01");
		RequireRigAliasField(value, "foldException", "AnimFold source track is model-native AttachPoint");
		int count = Regex.Matches(value, "\\b[A-Za-z_][A-Za-z0-9_]*\\s*=", RegexOptions.CultureInvariant).Count;
		if (count != 3)
		{
			throw new InvalidOperationException("Expected Percival rigAlias to contain exactly three fields, found " + count + ".");
		}
	}

	private static void RequireRigAliasField(string body, string fieldName, string expectedValue)
	{
		string pattern = "\\b" + Regex.Escape(fieldName) + "\\s*=\\s*\"" + Regex.Escape(expectedValue) + "\"";
		int count = Regex.Matches(body, pattern, RegexOptions.CultureInvariant).Count;
		if (count != 1)
		{
			throw new InvalidOperationException("Expected Percival rigAlias field '" + fieldName + "' to equal '" + expectedValue + "' exactly once, found " + count + ".");
		}
	}

	private static void ValidateEdaHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul UEF Percival 1.0.0", 1, "Percival host marker");
		RequireTokens(OwnedAppendix(source), "local SCO_PercivalStockDeathThread = HostEDALandUnit.DeathThread", "function HostEDALandUnit:DeathThread(overkillRatio)", "if self.tpId ~= \"uel3401\" then", "Engine.SetMovementCollisionMask(self.id, 0)", "local bucket = ((self.id and self.id.index) or 0) % 3", "WaitSeconds(bucket == 1 and 2.3333332538604736 or 2)", "return SCO_PercivalStockDeathThread(self, overkillRatio)");
	}

	private static void ValidateHostWeapon(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul UEF Percival 1.0.0", 1, "Percival water-gate marker");
		RequireTokens(OwnedAppendix(source), "local SCO_PercivalStockCanShootAt = HostWeapon.CanShootAt", "if not SCO_PercivalStockCanShootAt(self, targetUnit) then return false end", "self.unit.tpId ~= \"uel3401\"", "Engine.HasWater()", "Engine.GetWaterLevel()", "return ownerPosition.y >= waterLevel - margin", "and targetPosition.y >= waterLevel - margin");
	}

	private static void ValidateImport(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul UEF Percival 1.0.0", 1, "Percival scanner marker");
		RequireTokens(OwnedAppendix(source), "local SCO_PercivalScanDir = ScanDir", "local candidate = directory .. \"pep305\"", "table.insert(folders, candidate)");
	}

	private static void ValidateAvailableUnits(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul UEF Percival 1.0.0", 1, "Percival available-unit marker");
		RequireTokens(OwnedAppendix(source), "AvailableUnits[\"uel3401\"] = true");
		ValidateStock("LJ/lua/common/units/availableUnits.lua", source);
	}

	private static void ValidateVirtualProjectile(string source, ProjectileSpec projectile)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul UEF Percival 1.0.0", 1, "pep305 projectile marker");
		RequireTokens(source, "ProjectileTemplate =", "tpId = \"pep305\"", projectile.Name, "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12", projectile.SourceId, projectile.BlueprintPath, projectile.BlueprintSha256, projectile.ScriptPath, projectile.ScriptSha256, projectile.ImpactVfx, projectile.TrailVfx, "movement = { gravityMultiplier = 0 }", "DestroyOnWater true", "FA emitter graphs");
		RequireNotContains(source, "pad002", "pcl001", "AeonProjectiles");
	}

	private static void QueueAppend(object cache, ICollection<CacheMutation> mutations, string relativePath, string description, string appendix, Action<string> validate)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		if (resourceText.IndexOf("-- Supreme Commander Overhaul UEF Percival 1.0.0", StringComparison.Ordinal) >= 0)
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
			if (resourceText.IndexOf("-- Supreme Commander Overhaul UEF Percival 1.0.0", StringComparison.Ordinal) < 0)
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
		int num = source.IndexOf("-- Supreme Commander Overhaul UEF Percival 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("UEF Percival marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul UEF Percival 1.0.0".Length, StringComparison.Ordinal);
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
				throw new InvalidOperationException("Percival-owned Lua must not contain '" + text + "'.");
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
		string text = "[UEF Percival Cache Patcher] " + message;
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
