using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace FaCybranEggProductsCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class CacheResource
	{
		public string Path { get; }

		public object Value { get; }

		public CacheResource(string path, object value)
		{
			Path = path;
			Value = value;
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

	private sealed class ExistingSpec
	{
		public string RelativePath { get; }

		public string Description { get; }

		public string Appendix { get; }

		public Action<string> Validate { get; }

		public ExistingSpec(string relativePath, string description, string appendix, Action<string> validate)
		{
			RelativePath = relativePath;
			Description = description;
			Appendix = appendix;
			Validate = validate;
		}
	}

	private sealed class VirtualSpec
	{
		public string RelativePath { get; }

		public string Description { get; }

		public string Source { get; }

		public Action<string> Validate { get; }

		public VirtualSpec(string relativePath, string description, string source, Action<string> validate)
		{
			RelativePath = relativePath;
			Description = description;
			Source = source;
			Validate = validate;
		}
	}

	internal const string OverrideMarker = "-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0";

	private const string BangerPath = "LJ/lua/common/units/unitsTemplates/ugl2201/ugl2201.santp";

	private const string TrebuchetPath = "LJ/lua/common/units/unitsTemplates/ugl3101/ugl3101.santp";

	private const string GuardHostPath = "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua";

	private const string GuardClientPath = "LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua";

	private const string HostWeaponPath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private const string ImportPath = "LJ/lua/common/systems/import.lua";

	private const string AvailableUnitsPath = "LJ/lua/common/units/availableUnits.lua";

	private const string BangerProjectilePath = "LJ/lua/common/projectiles/projectilesTemplates/pgr205b/pgr205b.santp";

	private const string TrebuchetProjectilePath = "LJ/lua/common/projectiles/projectilesTemplates/pgr304t/pgr304t.santp";

	internal const string BangerUnitAppendix = "\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\n-- Deliberate same-faction role substitution: URL0205 Banger replaces only\n-- the existing ugl2201 Megalith egg product slot.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.5, y = 0.65 },\n    offset = { x = 0, y = 0, z = -0.05 },\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URL0205 -> ugl2201\",\n    substitution = \"Cybran mobile anti-air -> Guard/Cybran mobile anti-air\",\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/URL0205/URL0205_unit.bp\",\n    sourceBlueprintSha256 = \"53fb5ae5cadc1f36af4b1190c29dda6eaf30318806b13e3688ec427ae6bf7436\",\n    sourceScript = \"units/URL0205/URL0205_script.lua\",\n    sourceScriptSha256 = \"e3118736b13e505928e8a9572b73be896f747b5d4d4b429adfa4bc60c7fc0496\",\n    sourceModel = \"units/URL0205/URL0205_lod0.scm\",\n    sourceModelSha256 = \"9051cd745f341f77f62da2bd9e5d1c8a4d87e77344a738a894350f37bfe47c0b\",\n    sourceProjectile = \"CAABurstCloud01\",\n    sourceProjectileBlueprintSha256 = \"a67bd4f98381453ecd65897dc7d40feb7f8c1005f669b67e3f20e2162362bff4\",\n    sourceProjectileScriptSha256 = \"c40d3c20d99e4bf9380bb68009558bf0da7f3a516e327305cbd41e6f3fa314bc\",\n    sourceRig = { boneCount = 10, vertices = 1034, indices = 1770 },\n    sourceAnimationWalk = false,\n    movementAnimation = \"source has no active SCA; engine locomotion keeps the packed Rest pose\",\n    sourceUniformScale = 0.2,\n    sourceSelectionThickness = 0.6,\n    sourceMaxSpeedReverse = 0,\n    sourceRotateOnSpot = true,\n    sourceTurnRadius = 0,\n    limitations = {\n        sourceAudioBanks = false,\n        sourceGroundKickupAndScrollingTreads = false,\n        sourceRackRecoilDistance = -0.5,\n        sourceRackRecoilRuntime = false,\n        flakDetonateAboveTargetHeight = false,\n        electronBurstCloudEmitterGraph = false,\n        projectileDestroyOnWaterRuntime = false,\n        sanctuaryProjectileVisual = \"Guard medium-AA compatibility trail/impact\",\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 2: Mobile AA Flak Artillery\"\nUnitTemplate.general.name = \"Banger\"\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardLandUnit\" }\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"aa\", tech = \"t2\" }\nUnitTemplate.general.iconUI = \"tech2_land1_antiAir.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 50\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = nil\n\nUnitTemplate.audio = nil\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.3, z = 0 },\n    collisionSize = { x = 0.65, y = 0.6, z = 0.9 },\n}\nUnitTemplate.defence = { health = { max = 1000, regen = 0, value = 1000 } }\nUnitTemplate.economy = {\n    buildTime = 800,\n    cost = { alloys = 160, energy = 800 },\n}\nUnitTemplate.footprint = { x = 0.65, y = 0.9 }\nUnitTemplate.intel = { visionRadius = 20 }\nUnitTemplate.movement = {\n    acceleration = 2.9,\n    deceleration = 2.9,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"LandSmall\" },\n    collisionMaskSpawn = { \"LandSmall\" },\n    maxReverseDistance = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotateOnSpot = true,\n    rotationSpeed = 90,\n    sortOrder = 5,\n    speed = 2.9,\n    terrainAlignmentFactor = 1,\n    turnRadius = 0,\n    type = \"TracksLand\",\n}\nUnitTemplate.tags = {\n    \"ANTI_AIR\", \"BUILDABLE_BY_T2_FACTORY\", \"BUILDABLE_BY_T3_FACTORY\",\n    \"GUARD\", \"LAND\", \"MOBILE\", \"TECH2\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.effectsWhenActive = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.mesh = { lod0distance = 130, lod1distance = 350 }\nUnitTemplate.visuals.selection = {\n    size = { x = 0.5, y = 0.65 },\n    offset = { x = 0, y = 0, z = -0.05 },\n}\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Right_Muzzle01\",\n                aimTolerance = 2,\n                aimGravity = { x = 0, y = 0, z = 0 },\n                defaultPitchAdjustment = 35,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = \"Barrel\",\n                pitchMax = 75,\n                pitchMin = -5,\n                pitchSpeed = 180,\n                poseResetTime = 0,\n                projectileSpeed = 20,\n                solverType = \"NoArc\",\n                yawBone = \"Turret\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 180,\n            },\n        },\n        audio = { onFire = { looping = false, name = \"agom1221\" } },\n        collideFriendly = false,\n        damage = 90,\n        damageFriendly = false,\n        damageRadius = 4,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vgm3221_cannon_antiair_medium_muzzle.sanvfx\" },\n        firingRandomness = 2.5,\n        layerTargetLimits = { \"Air\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = 0,\n        muzzleGroups = {\n            { muzzles = { \"Right_Muzzle01\" } },\n            { muzzles = { \"Left_Muzzle01\" } },\n            { muzzles = { \"Right_Muzzle02\" } },\n            { muzzles = { \"Left_Muzzle02\" } },\n        },\n        muzzles = {\n            Right_Muzzle01 = { aimController = \"Right_Muzzle01\" },\n            Left_Muzzle01 = { aimController = \"Right_Muzzle01\" },\n            Right_Muzzle02 = { aimController = \"Right_Muzzle01\" },\n            Left_Muzzle02 = { aimController = \"Right_Muzzle01\" },\n        },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 6.25,\n        projectileTemplate = \"pgr205b\",\n        rangeMax = 40,\n        rangeMin = 0,\n        rangeRingType = \"AntiAir\",\n        rangeTracking = 1.4,\n        reloadTime = 0.625,\n        targetCheckInterval = 0.3,\n        targetWaterLimits = \"Above\",\n    },\n}";

	internal const string TrebuchetUnitAppendix = "\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\n-- Deliberate same-faction role substitution: URL0304 Trebuchet replaces only\n-- the existing ugl3101 Megalith egg product slot.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.8, y = 0.8 },\n    offset = { x = 0, y = 0, z = -0.15 },\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URL0304 -> ugl3101\",\n    substitution = \"Cybran mobile artillery -> Guard/Cybran mobile artillery\",\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/URL0304/URL0304_unit.bp\",\n    sourceBlueprintSha256 = \"10aa240dba2bf0bffd00589cfeebf1facd49eebaf9f799b5123a435e7aff161b\",\n    sourceScript = \"units/URL0304/URL0304_Script.lua\",\n    sourceScriptSha256 = \"57adaddea1cfc1cdae48cd7f1f003446b4552ce8890d45a62b3eea886ed0bbf9\",\n    sourceModel = \"units/URL0304/URL0304_lod0.scm\",\n    sourceModelSha256 = \"4fe449b72ead76d0e6c3d286d05eb841ff58c2a08a8e531e799a67dc836e618b\",\n    sourceProjectile = \"CIFArtilleryProton01\",\n    sourceProjectileBlueprintSha256 = \"e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e\",\n    sourceProjectileScriptSha256 = \"98a19bd78f1a61dc4c2f3f9e2c63a6cb27aadb6cbb352dbe6cf430d3483ee0ef\",\n    sourceRig = { boneCount = 11, vertices = 896, indices = 2040 },\n    sourceAnimation = \"units/URL0304/URL0304_Aactivate.sca\",\n    sourceAnimationSha256 = \"008bd0f7a56bf9b513fca03e42d079654f571e6572beaee9c5432a8c4cb58657\",\n    sourceAnimationFrames = 17,\n    sourceAnimationFps = 10,\n    sourceAnimationSeconds = 1.600000023841858,\n    sourceClose = \"exact time reversal of the active Aactivate source clip\",\n    sourceUniformScale = 0.35,\n    sourceSelectionThickness = 0.55,\n    sourceMaxSpeedReverse = 0,\n    sourceRotateOnSpot = true,\n    sourceTurnRadius = 0,\n    sourceWeaponUnpacks = true,\n    sourceWeaponUnpackLocksMotion = true,\n    sourceWeaponRepackTimeout = 0,\n    limitations = {\n        sourceAudioBanks = false,\n        sourceGroundKickupAndScrollingTreads = false,\n        sourceRackRecoilDistance = -1,\n        sourceRackRecoilRuntime = false,\n        muzzleVelocityReduceDistance = 85,\n        sanctuaryVelocityReduction = \"boolean adapter has no distance threshold\",\n        forceAndFireDamageRings = false,\n        impactLightDecalCameraShakeAndFollow = false,\n        projectileDestroyOnWaterRuntime = false,\n        sanctuaryProjectileVisual = \"Guard proton-artillery compatibility trail/impact\",\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 3: Mobile Heavy Artillery\"\nUnitTemplate.general.name = \"Trebuchet\"\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardTrebuchet\" }\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"indirect\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_land1_indirect.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 70\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = nil\n\nUnitTemplate.audio = nil\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.2, z = 0 },\n    collisionSize = { x = 1.2, y = 0.4, z = 0.8 },\n    targetBones = { \"Root\", \"Turret\" },\n}\nUnitTemplate.defence = { health = { max = 850, regen = 0, value = 850 } }\nUnitTemplate.economy = {\n    buildTime = 4800,\n    cost = { alloys = 800, energy = 8000 },\n}\nUnitTemplate.footprint = { x = 1.2, y = 0.8 }\nUnitTemplate.intel = { visionRadius = 26 }\nUnitTemplate.movement = {\n    acceleration = 2.5,\n    deceleration = 2.5,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"LandSmall\" },\n    collisionMaskSpawn = { \"LandSmall\" },\n    maxReverseDistance = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotateOnSpot = true,\n    rotationSpeed = 75,\n    sortOrder = 3,\n    speed = 2.5,\n    terrainAlignmentFactor = 1,\n    turnRadius = 0,\n    type = \"TracksLand\",\n}\nUnitTemplate.tags = {\n    \"ARTILLERY\", \"BUILDABLE_BY_T3_FACTORY\", \"GUARD\", \"INDIRECT_FIRE\",\n    \"LAND\", \"MOBILE\", \"TECH3\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.animations = {\n    walk = {\n        clipName = \"Rest\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl3101/LOD0/ugl3101.sananimation\",\n    },\n    deploy = {\n        clipName = \"AnimActivate\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl3101/LOD0/ugl3101.sananimation\",\n    },\n    close = {\n        clipName = \"AnimClose\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl3101/LOD0/ugl3101.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.effectsWhenActive = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.mesh = { lod0distance = 130, lod1distance = 350 }\nUnitTemplate.visuals.selection = {\n    size = { x = 0.8, y = 0.8 },\n    offset = { x = 0, y = 0, z = -0.15 },\n}\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Turret_Muzzle\",\n                aimTolerance = 2,\n                defaultPitchAdjustment = 30,\n                defaultYawAdjustment = 0,\n                leadTarget = false,\n                pitchBone = \"Turret_Barrel\",\n                pitchMax = 45,\n                pitchMin = -45,\n                pitchSpeed = 20,\n                poseResetTime = 0,\n                projectileSpeed = 22,\n                reduceMuzzleVelocityToTarget = true,\n                solverType = \"HighArc\",\n                yawBone = \"Turret\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 30,\n            },\n        },\n        audio = { onFire = { looping = false, name = \"agom3230\" } },\n        collideFriendly = false,\n        damage = 450,\n        damageFriendly = true,\n        damageRadius = 7,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vgm8321_plasma_stream_large_muzzle.sanvfx\" },\n        firingRandomness = 2,\n        layerTargetLimits = { \"Land\", \"WaterSurface\", \"Seabed\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = 0,\n        muzzleGroups = { { muzzles = { \"Turret_Muzzle\" } } },\n        muzzles = { Turret_Muzzle = { aimController = \"Turret_Muzzle\" } },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 20,\n        projectileTemplate = \"pgr304t\",\n        rangeMax = 90,\n        rangeMin = 0,\n        rangeRingType = \"IndirectFire\",\n        rangeTracking = 1.15,\n        reloadProgressBar = true,\n        reloadTime = 6.666666666666667,\n        targetCheckInterval = 1,\n        targetWaterLimits = \"Above\",\n        scoFaEggAboveWaterTargetsOnly = true,\n        scoFaEggArtilleryShieldBlocks = true,\n        scoFaEggTrebuchet = true,\n        scoFaEggTrebuchetDeploySeconds = 1.600000023841858,\n        scoFaEggTrebuchetRepackSeconds = 1.600000023841858,\n    },\n}";

	internal const string GuardHostAppendix = "\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\nlocal SCO_EggGuardLandUnit = HostGuardLandUnit or GuardLandUnit\nif not SCO_EggGuardLandUnit then error(\"Trebuchet requires GuardLandUnit\") end\nHostGuardTrebuchet = Class(\"GuardTrebuchet\", SCO_EggGuardLandUnit)\nlocal GuardTrebuchet = HostGuardTrebuchet\n\nfunction GuardTrebuchet:UpdateAnimations()\n    -- URL0304 has no locomotion SCA. Its sole active clip is weapon-owned.\nend\n\nfunction GuardTrebuchet:OnStopBeingBuilt()\n    SCO_EggGuardLandUnit.OnStopBeingBuilt(self)\n    local rest = self.tp.visuals and self.tp.visuals.animations\n        and self.tp.visuals.animations.walk\n    if not rest or not rest.id then\n        error(\"Trebuchet requires its hash-pinned Rest clip\")\n    end\n    Engine.PlayAnimation(self.id, rest.id, 0.1)\nend";

	internal const string GuardClientAppendix = "\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\nlocal SCO_EggClientGuardLandUnit = ClientGuardLandUnit or GuardLandUnit\nif not SCO_EggClientGuardLandUnit then\n    error(\"Trebuchet requires client GuardLandUnit\")\nend\nClientGuardTrebuchet = Class(\"GuardTrebuchet\", SCO_EggClientGuardLandUnit)";

	internal const string HostWeaponAppendix = "\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\n-- URL0304 deterministic host lifecycle:\n-- packed -> opening -> ready -> closing -> packed.\nlocal SCO_EggStockWeaponInit = HostWeapon.__init\nlocal SCO_EggStockWeaponDelete = HostWeapon.Delete\nlocal SCO_EggStockSetAimTarget = HostWeapon.SetAimTarget\nlocal SCO_EggStockCanShootAt = HostWeapon.CanShootAt\nlocal SCO_EggStockWeaponUpdate = HostWeapon.Update\n\nlocal function SCO_IsEggTrebuchetWeapon(self)\n    return self.unit and self.unit.tpId == \"ugl3101\"\n        and self.tp and self.tp.scoFaEggTrebuchet == true\nend\n\nlocal function SCO_PlayEggTrebuchetAnimation(self, key)\n    local animation = self.unit.tp.visuals and self.unit.tp.visuals.animations\n        and self.unit.tp.visuals.animations[key]\n    if not animation or not animation.id then\n        error(\"Trebuchet requires source animation \" .. tostring(key))\n    end\n    Engine.PlayAnimation(self.unit.id, animation.id, 0.1)\nend\n\nlocal function SCO_SetEggTrebuchetMovementLocked(self, locked)\n    if self.scoEggTrebuchetMovementLocked == locked then return end\n    self.scoEggTrebuchetMovementLocked = locked\n    Engine.SetMovementEnabled(self.unit.id, not locked)\nend\n\nlocal function SCO_BeginEggTrebuchetOpen(self, now)\n    SCO_SetEggTrebuchetMovementLocked(self, true)\n    SCO_PlayEggTrebuchetAnimation(self, \"deploy\")\n    self.scoEggTrebuchetState = \"opening\"\n    self.scoEggTrebuchetDeadline = now + self.tp.scoFaEggTrebuchetDeploySeconds\nend\n\nlocal function SCO_BeginEggTrebuchetClose(self, now)\n    SCO_PlayEggTrebuchetAnimation(self, \"close\")\n    self.scoEggTrebuchetState = \"closing\"\n    self.scoEggTrebuchetDeadline = now + self.tp.scoFaEggTrebuchetRepackSeconds\nend\n\nfunction HostWeapon:__init(aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)\n    SCO_EggStockWeaponInit(self, aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)\n    if not SCO_IsEggTrebuchetWeapon(self) then return end\n    if tp.scoFaEggTrebuchetDeploySeconds ~= 1.600000023841858\n        or tp.scoFaEggTrebuchetRepackSeconds ~= 1.600000023841858\n    then error(\"Trebuchet source deployment timing drifted\") end\n    self.scoEggTrebuchetState = \"packed\"\n    self.scoEggTrebuchetMovementLocked = false\nend\n\nfunction HostWeapon:Delete()\n    if SCO_IsEggTrebuchetWeapon(self) then\n        self.scoEggTrebuchetDisposed = true\n        SCO_SetEggTrebuchetMovementLocked(self, false)\n    end\n    return SCO_EggStockWeaponDelete(self)\nend\n\nfunction HostWeapon:CanShootAt(targetUnit)\n    if not SCO_EggStockCanShootAt(self, targetUnit) then return false end\n    if not SCO_IsEggTrebuchetWeapon(self)\n        or self.tp.scoFaEggAboveWaterTargetsOnly ~= true\n    then return true end\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return true end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    local targetPosition = targetUnit and targetUnit:GetPosition()\n    return levelResult == EngineErrorCode.Success and waterLevel ~= nil\n        and targetPosition ~= nil and targetPosition.y >= waterLevel - 0.05\nend\n\nfunction HostWeapon:SetAimTarget(targetUnit)\n    local result = SCO_EggStockSetAimTarget(self, targetUnit)\n    if not SCO_IsEggTrebuchetWeapon(self) then return result end\n    self.scoEggTrebuchetHasTarget = targetUnit ~= nil\n    return result\nend\n\nfunction HostWeapon:SCO_UpdateEggTrebuchetLifecycle(now)\n    local state = self.scoEggTrebuchetState\n    local hasTarget = self:HasTarget()\n    self.scoEggTrebuchetHasTarget = hasTarget\n\n    if state == \"packed\" and hasTarget then\n        SCO_BeginEggTrebuchetOpen(self, now)\n        return\n    end\n    if state == \"opening\" and now >= self.scoEggTrebuchetDeadline then\n        self.scoEggTrebuchetDeadline = nil\n        self.scoEggTrebuchetState = \"ready\"\n        state = \"ready\"\n    end\n    if state == \"ready\" and not hasTarget then\n        SCO_BeginEggTrebuchetClose(self, now)\n        return\n    end\n    if state == \"closing\" and now >= self.scoEggTrebuchetDeadline then\n        self.scoEggTrebuchetDeadline = nil\n        self.scoEggTrebuchetState = \"packed\"\n        SCO_PlayEggTrebuchetAnimation(self, \"walk\")\n        SCO_SetEggTrebuchetMovementLocked(self, false)\n        if hasTarget then SCO_BeginEggTrebuchetOpen(self, now) end\n    end\nend\n\nfunction HostWeapon:Update()\n    if not SCO_IsEggTrebuchetWeapon(self) then\n        return SCO_EggStockWeaponUpdate(self)\n    end\n    self:SCO_UpdateEggTrebuchetLifecycle(GetGameTimeSeconds())\n    if self.scoEggTrebuchetState == \"ready\" then\n        return SCO_EggStockWeaponUpdate(self)\n    end\n\n    -- Preserve reload time while withholding projectiles until the source\n    -- deploy clip reaches its authored endpoint.\n    if self.currentState == WeaponState.WaitingForReload then\n        self.reloadTimer = self.reloadTimer - Constants.TickTimeStep\n        if self.reloadTimer <= 0 then\n            self.currentState = WeaponState.WaitingForTarget\n        end\n    end\n    self:UpdateTargeting()\nend";

	internal const string ImportScannerAppendix = "\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\n-- The dedicated egg-product projectiles exist only in FilesCache.\nlocal SCO_EggProductsScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_EggProductsScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n    local routes = {\n        directory .. \"pgr205b\",\n        directory .. \"pgr304t\",\n    }\n    local known = {}\n    for _, folder in ipairs(folders) do known[folder] = true end\n    for _, folder in ipairs(routes) do\n        if not known[folder] then\n            table.insert(folders, folder)\n            known[folder] = true\n        end\n    end\n    return folders\nend";

	internal const string AvailableUnitsAppendix = "\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\n-- The source-pinned Trebuchet now has its complete model, template, projectile,\n-- and deterministic deploy lifecycle. Enable the existing Guard T3 factory\n-- route; template tags remain the builder-eligibility contract.\nAvailableUnits[\"ugl3101\"] = true";

	internal const string BangerProjectileSource = "---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = { onImpact = { looping = false, name = \"agoi1221\" } },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Cybran_Banger_CAABurstCloud01\",\n        tpId = \"pgr205b\",\n    },\n    nonUniformScale = { x = 0.1, y = 0.1, z = 0.1 },\n    source = {\n        archiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n        sourceId = \"CAABurstCloud01\",\n        blueprint = \"projectiles/CAABurstCloud01/CAABurstCloud01_proj.bp\",\n        blueprintSha256 = \"a67bd4f98381453ecd65897dc7d40feb7f8c1005f669b67e3f20e2162362bff4\",\n        script = \"projectiles/CAABurstCloud01/CAABurstCloud01_script.lua\",\n        scriptSha256 = \"c40d3c20d99e4bf9380bb68009558bf0da7f3a516e327305cbd41e6f3fa314bc\",\n        initialSpeed = 20,\n        lifetime = 5,\n        useGravity = false,\n        velocityAlign = true,\n        destroyOnWater = true,\n        detonateAboveHeight = 10,\n        limitations = {\n            electronBurstCloudEmitterGraph = false,\n            detonateAboveTargetHeight = false,\n            destroyOnWaterRuntime = false,\n            visual = \"Guard medium-AA compatibility trail/impact\",\n        },\n    },\n    visuals = {\n        mesh = { lod0distance = 90 },\n        onImpactEffects = {\n            { effects = { { particleName = \"VFX/Impact/vgi3221_cannon_antiair_medium_impact.sanvfx\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"VFX/Trails/vgt3221_cannon_antiair_medium_trail.sanvfx\" } } },\n        },\n    },\n}\n\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0";

	internal const string TrebuchetProjectileSource = "---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = { onImpact = { looping = false, name = \"agoi3230\" } },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Cybran_Trebuchet_CIFArtilleryProton01\",\n        tpId = \"pgr304t\",\n    },\n    nonUniformScale = { x = 0.45, y = 0.45, z = 0.45 },\n    source = {\n        archiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n        sourceId = \"CIFArtilleryProton01\",\n        blueprint = \"projectiles/CIFArtilleryProton01/CIFArtilleryProton01_proj.bp\",\n        blueprintSha256 = \"e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e\",\n        script = \"projectiles/CIFArtilleryProton01/CIFArtilleryProton01_script.lua\",\n        scriptSha256 = \"98a19bd78f1a61dc4c2f3f9e2c63a6cb27aadb6cbb352dbe6cf430d3483ee0ef\",\n        velocityAlign = true,\n        turnRate = 360,\n        destroyOnWater = true,\n        limitations = {\n            forceAndFireDamageRings = false,\n            impactLightsAndScorchDecal = false,\n            cameraShakeAndFollow = false,\n            destroyOnWaterRuntime = false,\n            sourceMeshAndEmitterGraph = false,\n            visual = \"Guard proton-artillery compatibility trail/impact\",\n        },\n    },\n    visuals = {\n        mesh = { lod0distance = 150 },\n        onImpactEffects = {\n            { effects = { { particleName = \"VFX/Impact/vgi8321_plasma_stream_large_impact.sanvfx\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"VFX/Trails/vgt8321_plasma_stream_large_trail.sanvfx\" } } },\n        },\n    },\n}\n\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0";

	private static ExistingSpec[] ExistingSpecs => new ExistingSpec[8]
	{
		new ExistingSpec("LJ/lua/common/units/unitsTemplates/ugl2201/ugl2201.santp", "UGL2201 Banger template", "\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\n-- Deliberate same-faction role substitution: URL0205 Banger replaces only\n-- the existing ugl2201 Megalith egg product slot.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.5, y = 0.65 },\n    offset = { x = 0, y = 0, z = -0.05 },\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URL0205 -> ugl2201\",\n    substitution = \"Cybran mobile anti-air -> Guard/Cybran mobile anti-air\",\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/URL0205/URL0205_unit.bp\",\n    sourceBlueprintSha256 = \"53fb5ae5cadc1f36af4b1190c29dda6eaf30318806b13e3688ec427ae6bf7436\",\n    sourceScript = \"units/URL0205/URL0205_script.lua\",\n    sourceScriptSha256 = \"e3118736b13e505928e8a9572b73be896f747b5d4d4b429adfa4bc60c7fc0496\",\n    sourceModel = \"units/URL0205/URL0205_lod0.scm\",\n    sourceModelSha256 = \"9051cd745f341f77f62da2bd9e5d1c8a4d87e77344a738a894350f37bfe47c0b\",\n    sourceProjectile = \"CAABurstCloud01\",\n    sourceProjectileBlueprintSha256 = \"a67bd4f98381453ecd65897dc7d40feb7f8c1005f669b67e3f20e2162362bff4\",\n    sourceProjectileScriptSha256 = \"c40d3c20d99e4bf9380bb68009558bf0da7f3a516e327305cbd41e6f3fa314bc\",\n    sourceRig = { boneCount = 10, vertices = 1034, indices = 1770 },\n    sourceAnimationWalk = false,\n    movementAnimation = \"source has no active SCA; engine locomotion keeps the packed Rest pose\",\n    sourceUniformScale = 0.2,\n    sourceSelectionThickness = 0.6,\n    sourceMaxSpeedReverse = 0,\n    sourceRotateOnSpot = true,\n    sourceTurnRadius = 0,\n    limitations = {\n        sourceAudioBanks = false,\n        sourceGroundKickupAndScrollingTreads = false,\n        sourceRackRecoilDistance = -0.5,\n        sourceRackRecoilRuntime = false,\n        flakDetonateAboveTargetHeight = false,\n        electronBurstCloudEmitterGraph = false,\n        projectileDestroyOnWaterRuntime = false,\n        sanctuaryProjectileVisual = \"Guard medium-AA compatibility trail/impact\",\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 2: Mobile AA Flak Artillery\"\nUnitTemplate.general.name = \"Banger\"\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardLandUnit\" }\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"aa\", tech = \"t2\" }\nUnitTemplate.general.iconUI = \"tech2_land1_antiAir.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 50\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = nil\n\nUnitTemplate.audio = nil\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.3, z = 0 },\n    collisionSize = { x = 0.65, y = 0.6, z = 0.9 },\n}\nUnitTemplate.defence = { health = { max = 1000, regen = 0, value = 1000 } }\nUnitTemplate.economy = {\n    buildTime = 800,\n    cost = { alloys = 160, energy = 800 },\n}\nUnitTemplate.footprint = { x = 0.65, y = 0.9 }\nUnitTemplate.intel = { visionRadius = 20 }\nUnitTemplate.movement = {\n    acceleration = 2.9,\n    deceleration = 2.9,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"LandSmall\" },\n    collisionMaskSpawn = { \"LandSmall\" },\n    maxReverseDistance = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotateOnSpot = true,\n    rotationSpeed = 90,\n    sortOrder = 5,\n    speed = 2.9,\n    terrainAlignmentFactor = 1,\n    turnRadius = 0,\n    type = \"TracksLand\",\n}\nUnitTemplate.tags = {\n    \"ANTI_AIR\", \"BUILDABLE_BY_T2_FACTORY\", \"BUILDABLE_BY_T3_FACTORY\",\n    \"GUARD\", \"LAND\", \"MOBILE\", \"TECH2\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.animations = nil\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.effectsWhenActive = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.mesh = { lod0distance = 130, lod1distance = 350 }\nUnitTemplate.visuals.selection = {\n    size = { x = 0.5, y = 0.65 },\n    offset = { x = 0, y = 0, z = -0.05 },\n}\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Right_Muzzle01\",\n                aimTolerance = 2,\n                aimGravity = { x = 0, y = 0, z = 0 },\n                defaultPitchAdjustment = 35,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = \"Barrel\",\n                pitchMax = 75,\n                pitchMin = -5,\n                pitchSpeed = 180,\n                poseResetTime = 0,\n                projectileSpeed = 20,\n                solverType = \"NoArc\",\n                yawBone = \"Turret\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 180,\n            },\n        },\n        audio = { onFire = { looping = false, name = \"agom1221\" } },\n        collideFriendly = false,\n        damage = 90,\n        damageFriendly = false,\n        damageRadius = 4,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vgm3221_cannon_antiair_medium_muzzle.sanvfx\" },\n        firingRandomness = 2.5,\n        layerTargetLimits = { \"Air\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = 0,\n        muzzleGroups = {\n            { muzzles = { \"Right_Muzzle01\" } },\n            { muzzles = { \"Left_Muzzle01\" } },\n            { muzzles = { \"Right_Muzzle02\" } },\n            { muzzles = { \"Left_Muzzle02\" } },\n        },\n        muzzles = {\n            Right_Muzzle01 = { aimController = \"Right_Muzzle01\" },\n            Left_Muzzle01 = { aimController = \"Right_Muzzle01\" },\n            Right_Muzzle02 = { aimController = \"Right_Muzzle01\" },\n            Left_Muzzle02 = { aimController = \"Right_Muzzle01\" },\n        },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 6.25,\n        projectileTemplate = \"pgr205b\",\n        rangeMax = 40,\n        rangeMin = 0,\n        rangeRingType = \"AntiAir\",\n        rangeTracking = 1.4,\n        reloadTime = 0.625,\n        targetCheckInterval = 0.3,\n        targetWaterLimits = \"Above\",\n    },\n}", ValidateBangerTemplate),
		new ExistingSpec("LJ/lua/common/units/unitsTemplates/ugl3101/ugl3101.santp", "UGL3101 Trebuchet template", "\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\n-- Deliberate same-faction role substitution: URL0304 Trebuchet replaces only\n-- the existing ugl3101 Megalith egg product slot.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.8, y = 0.8 },\n    offset = { x = 0, y = 0, z = -0.15 },\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URL0304 -> ugl3101\",\n    substitution = \"Cybran mobile artillery -> Guard/Cybran mobile artillery\",\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/URL0304/URL0304_unit.bp\",\n    sourceBlueprintSha256 = \"10aa240dba2bf0bffd00589cfeebf1facd49eebaf9f799b5123a435e7aff161b\",\n    sourceScript = \"units/URL0304/URL0304_Script.lua\",\n    sourceScriptSha256 = \"57adaddea1cfc1cdae48cd7f1f003446b4552ce8890d45a62b3eea886ed0bbf9\",\n    sourceModel = \"units/URL0304/URL0304_lod0.scm\",\n    sourceModelSha256 = \"4fe449b72ead76d0e6c3d286d05eb841ff58c2a08a8e531e799a67dc836e618b\",\n    sourceProjectile = \"CIFArtilleryProton01\",\n    sourceProjectileBlueprintSha256 = \"e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e\",\n    sourceProjectileScriptSha256 = \"98a19bd78f1a61dc4c2f3f9e2c63a6cb27aadb6cbb352dbe6cf430d3483ee0ef\",\n    sourceRig = { boneCount = 11, vertices = 896, indices = 2040 },\n    sourceAnimation = \"units/URL0304/URL0304_Aactivate.sca\",\n    sourceAnimationSha256 = \"008bd0f7a56bf9b513fca03e42d079654f571e6572beaee9c5432a8c4cb58657\",\n    sourceAnimationFrames = 17,\n    sourceAnimationFps = 10,\n    sourceAnimationSeconds = 1.600000023841858,\n    sourceClose = \"exact time reversal of the active Aactivate source clip\",\n    sourceUniformScale = 0.35,\n    sourceSelectionThickness = 0.55,\n    sourceMaxSpeedReverse = 0,\n    sourceRotateOnSpot = true,\n    sourceTurnRadius = 0,\n    sourceWeaponUnpacks = true,\n    sourceWeaponUnpackLocksMotion = true,\n    sourceWeaponRepackTimeout = 0,\n    limitations = {\n        sourceAudioBanks = false,\n        sourceGroundKickupAndScrollingTreads = false,\n        sourceRackRecoilDistance = -1,\n        sourceRackRecoilRuntime = false,\n        muzzleVelocityReduceDistance = 85,\n        sanctuaryVelocityReduction = \"boolean adapter has no distance threshold\",\n        forceAndFireDamageRings = false,\n        impactLightDecalCameraShakeAndFollow = false,\n        projectileDestroyOnWaterRuntime = false,\n        sanctuaryProjectileVisual = \"Guard proton-artillery compatibility trail/impact\",\n    },\n}\n\nUnitTemplate.general.displayName = \"Tier 3: Mobile Heavy Artillery\"\nUnitTemplate.general.name = \"Trebuchet\"\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardTrebuchet\" }\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"indirect\", tech = \"t3\" }\nUnitTemplate.general.iconUI = \"tech3_land1_indirect.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 70\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true,\n    Move = true, Patrol = true, Stop = true,\n}\nUnitTemplate.general.toggles = nil\n\nUnitTemplate.audio = nil\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.2, z = 0 },\n    collisionSize = { x = 1.2, y = 0.4, z = 0.8 },\n    targetBones = { \"Root\", \"Turret\" },\n}\nUnitTemplate.defence = { health = { max = 850, regen = 0, value = 850 } }\nUnitTemplate.economy = {\n    buildTime = 4800,\n    cost = { alloys = 800, energy = 8000 },\n}\nUnitTemplate.footprint = { x = 1.2, y = 0.8 }\nUnitTemplate.intel = { visionRadius = 26 }\nUnitTemplate.movement = {\n    acceleration = 2.5,\n    deceleration = 2.5,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    collisionMaskDefault = { \"LandSmall\" },\n    collisionMaskSpawn = { \"LandSmall\" },\n    maxReverseDistance = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotateOnSpot = true,\n    rotationSpeed = 75,\n    sortOrder = 3,\n    speed = 2.5,\n    terrainAlignmentFactor = 1,\n    turnRadius = 0,\n    type = \"TracksLand\",\n}\nUnitTemplate.tags = {\n    \"ARTILLERY\", \"BUILDABLE_BY_T3_FACTORY\", \"GUARD\", \"INDIRECT_FIRE\",\n    \"LAND\", \"MOBILE\", \"TECH3\",\n}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.animations = {\n    walk = {\n        clipName = \"Rest\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl3101/LOD0/ugl3101.sananimation\",\n    },\n    deploy = {\n        clipName = \"AnimActivate\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl3101/LOD0/ugl3101.sananimation\",\n    },\n    close = {\n        clipName = \"AnimClose\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl3101/LOD0/ugl3101.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.effectsWhenActive = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.visuals.mesh = { lod0distance = 130, lod1distance = 350 }\nUnitTemplate.visuals.selection = {\n    size = { x = 0.8, y = 0.8 },\n    offset = { x = 0, y = 0, z = -0.15 },\n}\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do effect.boneName = \"Root\" end\n    end\nend\n\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Turret_Muzzle\",\n                aimTolerance = 2,\n                defaultPitchAdjustment = 30,\n                defaultYawAdjustment = 0,\n                leadTarget = false,\n                pitchBone = \"Turret_Barrel\",\n                pitchMax = 45,\n                pitchMin = -45,\n                pitchSpeed = 20,\n                poseResetTime = 0,\n                projectileSpeed = 22,\n                reduceMuzzleVelocityToTarget = true,\n                solverType = \"HighArc\",\n                yawBone = \"Turret\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 30,\n            },\n        },\n        audio = { onFire = { looping = false, name = \"agom3230\" } },\n        collideFriendly = false,\n        damage = 450,\n        damageFriendly = true,\n        damageRadius = 7,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vgm8321_plasma_stream_large_muzzle.sanvfx\" },\n        firingRandomness = 2,\n        layerTargetLimits = { \"Land\", \"WaterSurface\", \"Seabed\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = 0,\n        muzzleGroups = { { muzzles = { \"Turret_Muzzle\" } } },\n        muzzles = { Turret_Muzzle = { aimController = \"Turret_Muzzle\" } },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 20,\n        projectileTemplate = \"pgr304t\",\n        rangeMax = 90,\n        rangeMin = 0,\n        rangeRingType = \"IndirectFire\",\n        rangeTracking = 1.15,\n        reloadProgressBar = true,\n        reloadTime = 6.666666666666667,\n        targetCheckInterval = 1,\n        targetWaterLimits = \"Above\",\n        scoFaEggAboveWaterTargetsOnly = true,\n        scoFaEggArtilleryShieldBlocks = true,\n        scoFaEggTrebuchet = true,\n        scoFaEggTrebuchetDeploySeconds = 1.600000023841858,\n        scoFaEggTrebuchetRepackSeconds = 1.600000023841858,\n    },\n}", ValidateTrebuchetTemplate),
		new ExistingSpec("LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Trebuchet Guard host class", "\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\nlocal SCO_EggGuardLandUnit = HostGuardLandUnit or GuardLandUnit\nif not SCO_EggGuardLandUnit then error(\"Trebuchet requires GuardLandUnit\") end\nHostGuardTrebuchet = Class(\"GuardTrebuchet\", SCO_EggGuardLandUnit)\nlocal GuardTrebuchet = HostGuardTrebuchet\n\nfunction GuardTrebuchet:UpdateAnimations()\n    -- URL0304 has no locomotion SCA. Its sole active clip is weapon-owned.\nend\n\nfunction GuardTrebuchet:OnStopBeingBuilt()\n    SCO_EggGuardLandUnit.OnStopBeingBuilt(self)\n    local rest = self.tp.visuals and self.tp.visuals.animations\n        and self.tp.visuals.animations.walk\n    if not rest or not rest.id then\n        error(\"Trebuchet requires its hash-pinned Rest clip\")\n    end\n    Engine.PlayAnimation(self.id, rest.id, 0.1)\nend", ValidateGuardHost),
		new ExistingSpec("LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua", "Trebuchet Guard client class", "\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\nlocal SCO_EggClientGuardLandUnit = ClientGuardLandUnit or GuardLandUnit\nif not SCO_EggClientGuardLandUnit then\n    error(\"Trebuchet requires client GuardLandUnit\")\nend\nClientGuardTrebuchet = Class(\"GuardTrebuchet\", SCO_EggClientGuardLandUnit)", ValidateGuardClient),
		new ExistingSpec("LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "Trebuchet host weapon lifecycle", "\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\n-- URL0304 deterministic host lifecycle:\n-- packed -> opening -> ready -> closing -> packed.\nlocal SCO_EggStockWeaponInit = HostWeapon.__init\nlocal SCO_EggStockWeaponDelete = HostWeapon.Delete\nlocal SCO_EggStockSetAimTarget = HostWeapon.SetAimTarget\nlocal SCO_EggStockCanShootAt = HostWeapon.CanShootAt\nlocal SCO_EggStockWeaponUpdate = HostWeapon.Update\nlocal SCO_EggOrderTasks = Import(\"common/commonOrders.lua\").OrderTasks\n\nlocal function SCO_IsEggTrebuchetWeapon(self)\n    return self.unit and self.unit.tpId == \"ugl3101\"\n        and self.tp and self.tp.scoFaEggTrebuchet == true\nend\n\nlocal function SCO_PlayEggTrebuchetAnimation(self, key)\n    local animation = self.unit.tp.visuals and self.unit.tp.visuals.animations\n        and self.unit.tp.visuals.animations[key]\n    if not animation or not animation.id then\n        error(\"Trebuchet requires source animation \" .. tostring(key))\n    end\n    Engine.PlayAnimation(self.unit.id, animation.id, 0.1)\nend\n\nlocal function SCO_SetEggTrebuchetMovementLocked(self, locked)\n    if self.scoEggTrebuchetMovementLocked == locked then return end\n    local unit = self.unit\n    if unit.dead or unit.deleted then\n        self.scoEggTrebuchetMovementLocked = locked\n        self.scoEggTrebuchetPreviousMaxSpeed = nil\n        return\n    end\n    local speed\n    if locked then\n        local status\n        status, speed = Engine.GetMovementMaxSpeed(unit.id)\n        if status ~= EngineErrorCode.Success or type(speed) ~= \"number\" then\n            error(\"Trebuchet deploy could not read movement speed\")\n        end\n        -- Keep movement active so native separation retains the collision entry.\n        local stop = Engine.MovementStop(unit.id, EngineClasses.float2(0, 0))\n        if stop ~= EngineErrorCode.Success then\n            error(\"Trebuchet deploy could not stop movement\")\n        end\n    else\n        speed = self.scoEggTrebuchetPreviousMaxSpeed\n        if type(speed) ~= \"number\" then\n            error(\"Trebuchet deploy has no movement speed to restore\")\n        end\n    end\n    local result = Engine.SetMovementMaxSpeed(unit.id, locked and 0 or speed)\n    if result ~= EngineErrorCode.Success then\n        error(\"Trebuchet deploy could not update movement speed\")\n    end\n    self.scoEggTrebuchetPreviousMaxSpeed = locked and speed or nil\n    self.scoEggTrebuchetMovementLocked = locked\nend\n\nlocal function SCO_BeginEggTrebuchetOpen(self, now)\n    SCO_SetEggTrebuchetMovementLocked(self, true)\n    SCO_PlayEggTrebuchetAnimation(self, \"deploy\")\n    self.scoEggTrebuchetState = \"opening\"\n    self.scoEggTrebuchetDeadline = now + self.tp.scoFaEggTrebuchetDeploySeconds\nend\n\nlocal function SCO_BeginEggTrebuchetClose(self, now)\n    SCO_PlayEggTrebuchetAnimation(self, \"close\")\n    self.scoEggTrebuchetState = \"closing\"\n    self.scoEggTrebuchetDeadline = now + self.tp.scoFaEggTrebuchetRepackSeconds\nend\n\nfunction HostWeapon:SCO_ReleaseEggTrebuchetForMove()\n    if not SCO_IsEggTrebuchetWeapon(self) then return end\n    if self:HasTarget() then self:SetAimTarget(nil) end\n    if self.scoEggTrebuchetState ~= \"packed\" then\n        SCO_PlayEggTrebuchetAnimation(self, \"walk\")\n    end\n    self.scoEggTrebuchetState = \"packed\"\n    self.scoEggTrebuchetDeadline = nil\n    SCO_SetEggTrebuchetMovementLocked(self, false)\nend\n\nfunction HostWeapon:__init(aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)\n    SCO_EggStockWeaponInit(self, aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)\n    if not SCO_IsEggTrebuchetWeapon(self) then return end\n    if tp.scoFaEggTrebuchetDeploySeconds ~= 1.600000023841858\n        or tp.scoFaEggTrebuchetRepackSeconds ~= 1.600000023841858\n    then error(\"Trebuchet source deployment timing drifted\") end\n    self.scoEggTrebuchetState = \"packed\"\n    self.scoEggTrebuchetMovementLocked = false\nend\n\nfunction HostWeapon:Delete()\n    if SCO_IsEggTrebuchetWeapon(self) then\n        self.scoEggTrebuchetDisposed = true\n        SCO_SetEggTrebuchetMovementLocked(self, false)\n    end\n    return SCO_EggStockWeaponDelete(self)\nend\n\nfunction HostWeapon:CanShootAt(targetUnit)\n    if not SCO_EggStockCanShootAt(self, targetUnit) then return false end\n    if not SCO_IsEggTrebuchetWeapon(self)\n        or self.tp.scoFaEggAboveWaterTargetsOnly ~= true\n    then return true end\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return true end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    local targetPosition = targetUnit and targetUnit:GetPosition()\n    return levelResult == EngineErrorCode.Success and waterLevel ~= nil\n        and targetPosition ~= nil and targetPosition.y >= waterLevel - 0.05\nend\n\nfunction HostWeapon:SetAimTarget(targetUnit)\n    local result = SCO_EggStockSetAimTarget(self, targetUnit)\n    if not SCO_IsEggTrebuchetWeapon(self) then return result end\n    self.scoEggTrebuchetHasTarget = targetUnit ~= nil\n    return result\nend\n\nfunction HostWeapon:SCO_UpdateEggTrebuchetLifecycle(now)\n    local state = self.scoEggTrebuchetState\n    local hasTarget = self:HasTarget()\n    self.scoEggTrebuchetHasTarget = hasTarget\n\n    if state == \"packed\" and hasTarget then\n        SCO_BeginEggTrebuchetOpen(self, now)\n        return\n    end\n    if state == \"opening\" and now >= self.scoEggTrebuchetDeadline then\n        self.scoEggTrebuchetDeadline = nil\n        self.scoEggTrebuchetState = \"ready\"\n        state = \"ready\"\n    end\n    if state == \"ready\" and not hasTarget then\n        SCO_BeginEggTrebuchetClose(self, now)\n        return\n    end\n    if state == \"closing\" and now >= self.scoEggTrebuchetDeadline then\n        self.scoEggTrebuchetDeadline = nil\n        self.scoEggTrebuchetState = \"packed\"\n        SCO_PlayEggTrebuchetAnimation(self, \"walk\")\n        SCO_SetEggTrebuchetMovementLocked(self, false)\n        if hasTarget then SCO_BeginEggTrebuchetOpen(self, now) end\n    end\nend\n\nfunction HostWeapon:Update()\n    if not SCO_IsEggTrebuchetWeapon(self) then\n        return SCO_EggStockWeaponUpdate(self)\n    end\n    local activeOrder = self.unit.orders and self.unit.orders.activeOrder\n    local explicitMove = activeOrder and activeOrder.orderTask == SCO_EggOrderTasks.MOVE\n    if explicitMove then\n        self:SCO_ReleaseEggTrebuchetForMove()\n    else\n        self:SCO_UpdateEggTrebuchetLifecycle(GetGameTimeSeconds())\n    end\n    if not explicitMove and self.scoEggTrebuchetState == \"ready\" then\n        return SCO_EggStockWeaponUpdate(self)\n    end\n\n    -- Preserve reload time while withholding projectiles until the source\n    -- deploy clip reaches its authored endpoint.\n    if self.currentState == WeaponState.WaitingForReload then\n        self.reloadTimer = self.reloadTimer - Constants.TickTimeStep\n        if self.reloadTimer <= 0 then\n            self.currentState = WeaponState.WaitingForTarget\n        end\n    end\n    if not explicitMove then\n        if self.UpdateTargeting then\n            self:UpdateTargeting()\n        else\n            self:RecalculateTargets()\n        end\n    end\nend", ValidateHostWeapon),
		new ExistingSpec("LJ/lua/host/managers/orders/orderClasses/hostMoveOrder.lua", "Trebuchet explicit MOVE unlock", "\n\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\n-- Clear the artillery deploy lock before native MOVE starts its path.\nlocal SCO_EggStockMoveUnitStart = HostMoveOrder.UnitStart\nfunction HostMoveOrder:UnitStart(unit)\n    if unit.tpId == \"ugl3101\" and unit.weapons then\n        for _, weapon in ipairs(unit.weapons) do\n            if weapon.tp and weapon.tp.scoFaEggTrebuchet == true then\n                weapon:SCO_ReleaseEggTrebuchetForMove()\n            end\n        end\n    end\n    return SCO_EggStockMoveUnitStart(self, unit)\nend", ValidateHostMoveOrder),
		new ExistingSpec("LJ/lua/common/systems/import.lua", "egg-product virtual-projectile scanner", "\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\n-- The dedicated egg-product projectiles exist only in FilesCache.\nlocal SCO_EggProductsScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_EggProductsScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then\n        return folders\n    end\n    local routes = {\n        directory .. \"pgr205b\",\n        directory .. \"pgr304t\",\n    }\n    local known = {}\n    for _, folder in ipairs(folders) do known[folder] = true end\n    for _, folder in ipairs(routes) do\n        if not known[folder] then\n            table.insert(folders, folder)\n            known[folder] = true\n        end\n    end\n    return folders\nend", ValidateImportScanner),
		new ExistingSpec("LJ/lua/common/units/availableUnits.lua", "Trebuchet available-unit gate", "\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0\n-- The source-pinned Trebuchet now has its complete model, template, projectile,\n-- and deterministic deploy lifecycle. Enable the existing Guard T3 factory\n-- route; template tags remain the builder-eligibility contract.\nAvailableUnits[\"ugl3101\"] = true", ValidateAvailableUnits)
	};

	private static VirtualSpec[] VirtualSpecs => new VirtualSpec[2]
	{
		new VirtualSpec("LJ/lua/common/projectiles/projectilesTemplates/pgr205b/pgr205b.santp", "Banger dedicated projectile", "---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = { onImpact = { looping = false, name = \"agoi1221\" } },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Cybran_Banger_CAABurstCloud01\",\n        tpId = \"pgr205b\",\n    },\n    nonUniformScale = { x = 0.1, y = 0.1, z = 0.1 },\n    source = {\n        archiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n        sourceId = \"CAABurstCloud01\",\n        blueprint = \"projectiles/CAABurstCloud01/CAABurstCloud01_proj.bp\",\n        blueprintSha256 = \"a67bd4f98381453ecd65897dc7d40feb7f8c1005f669b67e3f20e2162362bff4\",\n        script = \"projectiles/CAABurstCloud01/CAABurstCloud01_script.lua\",\n        scriptSha256 = \"c40d3c20d99e4bf9380bb68009558bf0da7f3a516e327305cbd41e6f3fa314bc\",\n        initialSpeed = 20,\n        lifetime = 5,\n        useGravity = false,\n        velocityAlign = true,\n        destroyOnWater = true,\n        detonateAboveHeight = 10,\n        limitations = {\n            electronBurstCloudEmitterGraph = false,\n            detonateAboveTargetHeight = false,\n            destroyOnWaterRuntime = false,\n            visual = \"Guard medium-AA compatibility trail/impact\",\n        },\n    },\n    visuals = {\n        mesh = { lod0distance = 90 },\n        onImpactEffects = {\n            { effects = { { particleName = \"VFX/Impact/vgi3221_cannon_antiair_medium_impact.sanvfx\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"VFX/Trails/vgt3221_cannon_antiair_medium_trail.sanvfx\" } } },\n        },\n    },\n}\n\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", ValidateBangerProjectile),
		new VirtualSpec("LJ/lua/common/projectiles/projectilesTemplates/pgr304t/pgr304t.santp", "Trebuchet dedicated projectile", "---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = { onImpact = { looping = false, name = \"agoi3230\" } },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = {\n        icon = \"projectile\",\n        name = \"Cybran_Trebuchet_CIFArtilleryProton01\",\n        tpId = \"pgr304t\",\n    },\n    nonUniformScale = { x = 0.45, y = 0.45, z = 0.45 },\n    source = {\n        archiveSha256 = \"60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\",\n        sourceId = \"CIFArtilleryProton01\",\n        blueprint = \"projectiles/CIFArtilleryProton01/CIFArtilleryProton01_proj.bp\",\n        blueprintSha256 = \"e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e\",\n        script = \"projectiles/CIFArtilleryProton01/CIFArtilleryProton01_script.lua\",\n        scriptSha256 = \"98a19bd78f1a61dc4c2f3f9e2c63a6cb27aadb6cbb352dbe6cf430d3483ee0ef\",\n        velocityAlign = true,\n        turnRate = 360,\n        destroyOnWater = true,\n        limitations = {\n            forceAndFireDamageRings = false,\n            impactLightsAndScorchDecal = false,\n            cameraShakeAndFollow = false,\n            destroyOnWaterRuntime = false,\n            sourceMeshAndEmitterGraph = false,\n            visual = \"Guard proton-artillery compatibility trail/impact\",\n        },\n    },\n    visuals = {\n        mesh = { lod0distance = 150 },\n        onImpactEffects = {\n            { effects = { { particleName = \"VFX/Impact/vgi8321_plasma_stream_large_impact.sanvfx\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"VFX/Trails/vgt8321_plasma_stream_large_trail.sanvfx\" } } },\n        },\n    },\n}\n\n-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", ValidateTrebuchetProjectile)
	};

	public static void Apply()
	{
		object luaFileCache = GetLuaFileCache();
		ExistingSpec[] existingSpecs = ExistingSpecs;
		VirtualSpec[] virtualSpecs = VirtualSpecs;
		int num = CountOwnedResources(luaFileCache, existingSpecs, virtualSpecs);
		int num2 = existingSpecs.Length + virtualSpecs.Length;
		if (num == num2)
		{
			ValidateOwnedResources(luaFileCache, existingSpecs, virtualSpecs);
			Log("Banger/Trebuchet templates, lifecycle, and projectiles are already active.");
			return;
		}
		bool flag = num == 4 && IsStaticOverlaySeed(luaFileCache);
		if (num != 0 && !flag)
		{
			throw new InvalidOperationException($"The Cybran egg-product cache is partially owned ({num}/{num2}). " + "Refusing to compose over an incomplete or drifted transaction.");
		}
		if (flag)
		{
			ValidateStaticOverlaySeed(luaFileCache);
		}
		ExistingSpec[] array = (flag ? existingSpecs.Where((ExistingSpec existingSpec) => existingSpec.RelativePath != "LJ/lua/common/units/unitsTemplates/ugl2201/ugl2201.santp" && existingSpec.RelativePath != "LJ/lua/common/units/unitsTemplates/ugl3101/ugl3101.santp").ToArray() : existingSpecs);
		VirtualSpec[] array2 = (flag ? Array.Empty<VirtualSpec>() : virtualSpecs);
		int num3 = array.Length + array2.Length;
		List<CacheMutation> list = new List<CacheMutation>(num3);
		bool flag2 = false;
		try
		{
			ExistingSpec[] array3 = array;
			foreach (ExistingSpec spec in array3)
			{
				QueueAppend(luaFileCache, list, spec);
			}
			Type type = list[0].Replacement.GetType();
			VirtualSpec[] array4 = array2;
			foreach (VirtualSpec spec2 in array4)
			{
				QueueVirtual(luaFileCache, list, type, spec2);
			}
			if (list.Count != num3)
			{
				throw new InvalidOperationException($"Expected {num3} egg-product mutations, prepared {list.Count}.");
			}
			Commit(luaFileCache, list);
			flag2 = true;
			Log(flag ? "Validated the four-resource static asset overlay and atomically installed the Trebuchet host lifecycle, scanner, and buildability gate." : "Atomically synthesized the Banger/Trebuchet templates and projectiles and installed lifecycle, scanner, and buildability resources.");
		}
		catch
		{
			RollBack(luaFileCache, list);
			throw;
		}
		finally
		{
			if (!flag2)
			{
				DisposeUncommitted(list);
			}
		}
	}

	private static bool IsStaticOverlaySeed(object cache)
	{
		if (HasOwnedMarker(cache, "LJ/lua/common/units/unitsTemplates/ugl2201/ugl2201.santp", "Banger overlay template") && HasOwnedMarker(cache, "LJ/lua/common/units/unitsTemplates/ugl3101/ugl3101.santp", "Trebuchet overlay template") && HasOwnedMarker(cache, "LJ/lua/common/projectiles/projectilesTemplates/pgr205b/pgr205b.santp", "Banger overlay projectile"))
		{
			return HasOwnedMarker(cache, "LJ/lua/common/projectiles/projectilesTemplates/pgr304t/pgr304t.santp", "Trebuchet overlay projectile");
		}
		return false;
	}

	private static bool HasOwnedMarker(object cache, string relativePath, string description)
	{
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath, description);
		if (cacheResource != null)
		{
			return GetResourceText(cacheResource.Value).IndexOf("-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", StringComparison.Ordinal) >= 0;
		}
		return false;
	}

	private static void ValidateStaticOverlaySeed(object cache)
	{
		ValidateBangerTemplate(GetResourceText(GetCachedResource(cache, "LJ/lua/common/units/unitsTemplates/ugl2201/ugl2201.santp", "Banger overlay template").Value));
		ValidateTrebuchetTemplate(GetResourceText(GetCachedResource(cache, "LJ/lua/common/units/unitsTemplates/ugl3101/ugl3101.santp", "Trebuchet overlay template").Value));
		ValidateBangerProjectile(GetResourceText(GetCachedResource(cache, "LJ/lua/common/projectiles/projectilesTemplates/pgr205b/pgr205b.santp", "Banger overlay projectile").Value));
		ValidateTrebuchetProjectile(GetResourceText(GetCachedResource(cache, "LJ/lua/common/projectiles/projectilesTemplates/pgr304t/pgr304t.santp", "Trebuchet overlay projectile").Value));
	}

	private static int CountOwnedResources(object cache, IEnumerable<ExistingSpec> existingSpecs, IEnumerable<VirtualSpec> virtualSpecs)
	{
		int num = 0;
		foreach (ExistingSpec existingSpec in existingSpecs)
		{
			if (GetResourceText(GetCachedResource(cache, existingSpec.RelativePath, existingSpec.Description).Value).IndexOf("-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", StringComparison.Ordinal) >= 0)
			{
				num++;
			}
		}
		foreach (VirtualSpec virtualSpec in virtualSpecs)
		{
			CacheResource cacheResource = TryGetCachedResource(cache, virtualSpec.RelativePath, virtualSpec.Description);
			if (cacheResource != null)
			{
				if (GetResourceText(cacheResource.Value).IndexOf("-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", StringComparison.Ordinal) < 0)
				{
					throw new InvalidOperationException("Reserved resource " + virtualSpec.RelativePath + " exists without the egg-product marker.");
				}
				num++;
			}
		}
		return num;
	}

	private static void ValidateOwnedResources(object cache, IEnumerable<ExistingSpec> existingSpecs, IEnumerable<VirtualSpec> virtualSpecs)
	{
		foreach (ExistingSpec existingSpec in existingSpecs)
		{
			existingSpec.Validate(GetResourceText(GetCachedResource(cache, existingSpec.RelativePath, existingSpec.Description).Value));
		}
		foreach (VirtualSpec virtualSpec in virtualSpecs)
		{
			CacheResource cacheResource = TryGetCachedResource(cache, virtualSpec.RelativePath, virtualSpec.Description) ?? throw new FileNotFoundException("Missing owned virtual resource.", virtualSpec.RelativePath);
			virtualSpec.Validate(GetResourceText(cacheResource.Value));
		}
	}

	private static void QueueAppend(object cache, ICollection<CacheMutation> mutations, ExistingSpec spec)
	{
		CacheResource cachedResource = GetCachedResource(cache, spec.RelativePath, spec.Description);
		string resourceText = GetResourceText(cachedResource.Value);
		ValidateStock(spec.RelativePath, resourceText);
		object obj = CreateNativeArray(cachedResource.Value.GetType(), AppendOverride(resourceText, spec.Appendix));
		try
		{
			spec.Validate(GetResourceText(obj));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Value, obj, added: false, spec.Description));
		}
		catch
		{
			TryDispose(obj, "uncommitted " + spec.Description);
			throw;
		}
	}

	private static void QueueVirtual(object cache, ICollection<CacheMutation> mutations, Type nativeArrayType, VirtualSpec spec)
	{
		if (TryGetCachedResource(cache, spec.RelativePath, spec.Description) != null)
		{
			throw new InvalidOperationException("Reserved virtual resource already exists: " + spec.RelativePath);
		}
		spec.Validate(spec.Source);
		object obj = CreateNativeArray(nativeArrayType, spec.Source);
		try
		{
			spec.Validate(GetResourceText(obj));
			mutations.Add(new CacheMutation(ResolvePath(spec.RelativePath), null, obj, added: true, spec.Description));
		}
		catch
		{
			TryDispose(obj, "uncommitted " + spec.Description);
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
			if (!mutation.Assigned)
			{
				TryDispose(mutation.Replacement, "uncommitted " + mutation.Description);
			}
		}
	}

	private static void ValidateStock(string relativePath, string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", 0, "stock egg-product marker");
		switch (relativePath)
		{
		case "LJ/lua/common/units/unitsTemplates/ugl2201/ugl2201.santp":
			RequireTokens(source, "UnitTemplate =", "tpId = \"ugl2201\"");
			break;
		case "LJ/lua/common/units/unitsTemplates/ugl3101/ugl3101.santp":
			RequireTokens(source, "UnitTemplate =", "tpId = \"ugl3101\"");
			break;
		case "LJ/lua/common/units/availableUnits.lua":
			RequireTokens(source, "AvailableUnits =", "ugl2201 = true", "ugl3101 = false");
			break;
		case "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua":
			RequireTokens(source, "local unitsDefault = Import(\"host/units/unitsClasses/unitsDefault.lua\")", "LandUnit = unitsDefault.HostLandUnit", "HostGuardLandUnit = Class(\"GuardLandUnit\", LandUnit)");
			break;
		case "LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua":
			RequireTokens(source, "local unitsDefault = Import(\"client/units/unitsClasses/unitsDefault.lua\")", "LandUnit = unitsDefault.ClientLandUnit", "ClientGuardLandUnit = Class(\"GuardLandUnit\", LandUnit)");
			break;
		case "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua":
			RequireTokens(source, "HostWeapon = Class(\"Weapon\")", "function HostWeapon:__init(aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)", "function HostWeapon:Delete()", "function HostWeapon:HasTarget()", "function HostWeapon:SetAimTarget(targetUnit)", "function HostWeapon:CanShootAt(targetUnit)", "function HostWeapon:Update()");
			if (!source.Contains("function HostWeapon:UpdateTargeting()"))
			{
				RequireTokens(source, "function HostWeapon:RecalculateTargets()", "function HostWeapon:FindBestTarget()");
			}
			break;
		case "LJ/lua/common/systems/import.lua":
			RequireTokens(source, "function ScanDir(directory)", "Engine.GetFoldersInsideDirectory(directory, folders)", "folders[i] = directory..fileName", "return folders");
			break;
		default:
			if (string.IsNullOrWhiteSpace(source))
			{
				throw new InvalidOperationException("Required stock Lua resource is empty: " + relativePath);
			}
			break;
		}
	}

	private static void ValidateBangerTemplate(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", 1, "Banger marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "URL0205 -> ugl2201", "UnitTemplate.general.name = \"Banger\"", "health = { max = 1000", "speed = 2.9", "rotationSpeed = 90", "projectileTemplate = \"pgr205b\"", "reloadTime = 0.625", "Right_Muzzle01", "Left_Muzzle01", "Right_Muzzle02", "Left_Muzzle02", "sourceAnimationWalk = false", "electronBurstCloudEmitterGraph = false");
		RequireNotContains(source2, "Perforator", "DEMO_UI_ONLY", "walkAnimation");
	}

	private static void ValidateTrebuchetTemplate(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", 1, "Trebuchet marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "URL0304 -> ugl3101", "UnitTemplate.general.name = \"Trebuchet\"", "GuardTrebuchet", "health = { max = 850", "speed = 2.5", "clipName = \"AnimActivate\"", "clipName = \"AnimClose\"", "projectileTemplate = \"pgr304t\"", "reloadTime = 6.666666666666667", "scoFaEggTrebuchet = true", "sourceAnimationFrames = 17", "sourceAnimationFps = 10", "sourceWeaponUnpackLocksMotion = true");
		RequireNotContains(source2, "Malware", "DEMO_UI_ONLY", "DRONE_LAUNCHER", "movement.walkAnimation", "authoredSpeed");
	}

	private static void ValidateGuardHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", 1, "Trebuchet Guard-host marker");
		RequireTokens(OwnedAppendix(source), "HostGuardTrebuchet", "function GuardTrebuchet:UpdateAnimations()", "function GuardTrebuchet:OnStopBeingBuilt()", "Engine.PlayAnimation");
	}

	private static void ValidateGuardClient(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", 1, "Trebuchet Guard-client marker");
		RequireTokens(OwnedAppendix(source), "ClientGuardTrebuchet", "Class(\"GuardTrebuchet\"");
	}

	private static void ValidateHostWeapon(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", 1, "Trebuchet host-lifecycle marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "packed -> opening -> ready -> closing -> packed", "SCO_EggStockWeaponUpdate", "SCO_EggStockSetAimTarget", "Engine.SetMovementMaxSpeed(unit.id, locked and 0 or speed)", "SCO_BeginEggTrebuchetOpen", "SCO_BeginEggTrebuchetClose", "scoEggTrebuchetState == \"ready\"", "now + self.tp.scoFaEggTrebuchetDeploySeconds", "now + self.tp.scoFaEggTrebuchetRepackSeconds", "SCO_PlayEggTrebuchetAnimation(self, \"walk\")", "SCO_SetEggTrebuchetMovementLocked(self, false)");
		RequireNotContains(source2, "WaitSeconds(", "math.random", "SetGlobalEntityPosition");
	}

	private static void ValidateImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", 1, "egg projectile-scanner marker");
		RequireTokens(OwnedAppendix(source), "SCO_EggProductsScanDir", "pgr205b", "pgr304t");
	}

	private static void ValidateAvailableUnits(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", 1, "Trebuchet availability marker");
		RequireExactly(source, "AvailableUnits[\"ugl3101\"] = true", 1, "Trebuchet roster enablement");
		RequireTokens(OwnedAppendix(source), "existing Guard T3 factory", "template tags remain", "AvailableUnits[\"ugl3101\"] = true");
	}

	private static void ValidateBangerProjectile(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", 1, "Banger projectile marker");
		RequireTokens(source, "tpId = \"pgr205b\"", "sourceId = \"CAABurstCloud01\"", "a67bd4f98381453ecd65897dc7d40feb7f8c1005f669b67e3f20e2162362bff4", "c40d3c20d99e4bf9380bb68009558bf0da7f3a516e327305cbd41e6f3fa314bc", "detonateAboveTargetHeight = false", "electronBurstCloudEmitterGraph = false", "vgt3221_cannon_antiair_medium_trail.sanvfx");
	}

	private static void ValidateTrebuchetProjectile(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", 1, "Trebuchet projectile marker");
		RequireTokens(source, "tpId = \"pgr304t\"", "sourceId = \"CIFArtilleryProton01\"", "e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e", "98a19bd78f1a61dc4c2f3f9e2c63a6cb27aadb6cbb352dbe6cf430d3483ee0ef", "forceAndFireDamageRings = false", "cameraShakeAndFollow = false", "vgt8321_plasma_stream_large_trail.sanvfx");
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? (from assembly in AppDomain.CurrentDomain.GetAssemblies()
			select assembly.GetType("EM.Lua.FilesCache", throwOnError: false)).FirstOrDefault((Type type2) => type2 != null);
		if (type == null)
		{
			throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		}
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
		if (obj2 is bool && (bool)obj2)
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

	private static string ResolvePath(string relativePath)
	{
		return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
	}

	private static object CreateNativeArray(Type nativeArrayType, string source)
	{
		return NativeArrayByteFactory.CreatePersistent(nativeArrayType, Encoding.UTF8.GetBytes(source));
	}

	private static string GetResourceText(object resource)
	{
		EnsureCreated(resource, "Lua cache resource");
		if (!((resource.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray")).Invoke(resource, null) is byte[] bytes))
		{
			throw new InvalidOperationException("Cached Lua resource did not expose a byte array.");
		}
		return Encoding.UTF8.GetString(bytes);
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

	private static string OwnedAppendix(string source)
	{
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Egg-product marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0".Length, StringComparison.Ordinal);
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
				throw new InvalidOperationException("Egg-product-owned Lua must not contain '" + text + "'.");
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
		string text = "[FA Cybran Egg Products Cache Patcher] " + message;
		Console.WriteLine(text);
		try
		{
			(from assembly in AppDomain.CurrentDomain.GetAssemblies()
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type type) => type != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}

	private static void ValidateHostMoveOrder(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0", 1, "Trebuchet move-order marker");
		RequireTokens(source, "HostMoveOrder = Class(\"HostMoveOrder\", HostBaseOrder)", "unit:MoveIntoRangeBehaviorStart(spot, self.range, self.alignDirection, brakeOnApproach)");
		RequireTokens(OwnedAppendix(source), "SCO_EggStockMoveUnitStart", "unit.tpId == \"ugl3101\"", "SCO_ReleaseEggTrebuchetForMove()", "return SCO_EggStockMoveUnitStart(self, unit)");
	}
}
