using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using ScomRepair20260913;
using SupremeCommanderOverhaul.Shared;

namespace FaCybranScathisCachePatcher;

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

	internal const string OverrideMarker = "-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0";

	internal const string SourceArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	internal const string ProjectileArchiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12";

	private const string UnitPath = "LJ/lua/common/units/unitsTemplates/ugl4011/ugl4011.santp";

	private const string HostGuardPath = "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua";

	private const string ClientGuardPath = "LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua";

	private const string HostWeaponPath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private const string ClientMuzzlePath = "LJ/lua/client/units/weaponsClasses/clientMuzzleClass.lua";

	private const string ImportPath = "LJ/lua/common/systems/import.lua";

	private const string ProjectilePath = "LJ/lua/common/projectiles/projectilesTemplates/pgr401s/pgr401s.santp";

	private const string UnitAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0\n-- Exact direct mapping: FA URL0401 Scathis replaces only ugl4011.\nUnitTemplate.additions = {\n    displayWreckOnDeath = true,\n    selectionHit = { size = { x = 4, y = 5 } },\n    rotators = {\n        {\n            boneName = \"Turret_Fake\",\n            speed = { x = 0, y = 120, z = 0 },\n        },\n    },\n    faSourceContract = {\n        mapping = \"URL0401 -> ugl4011\",\n        sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n        sourceBlueprint = \"units/URL0401/URL0401_unit.bp\",\n        sourceBlueprintSha256 = \"c0366fbe9bf45b4c5cb32c9b4618dd97d3756d46e6ff5e3d449d013e89669f74\",\n        sourceScript = \"units/URL0401/URL0401_Script.lua\",\n        sourceScriptSha256 = \"406c68acd2806fae507c68f23b57209a4d8982d512a9bcab3fc95887ba97794e\",\n        sourceOpenAnimation = \"units/URL0401/URL0401_Aopen.sca\",\n        sourceOpenAnimationSha256 = \"9fd6d8f08446ab7adbeed2923057f43878949cbdc27fc1d05c522e469fbbae6c\",\n        openFrames = 501,\n        openFps = 30,\n        openSeconds = 16.66666603088379,\n        repackTimeoutSeconds = 4,\n        sourceRackRecoilDistance = -20,\n        convertedRackRecoilDistance = -2,\n        sourceRackRecoilReturnSpeed = 13.25,\n        convertedRackRecoilReturnSpeed = 1.325,\n        fakeBarrelOrder = { \"F\", \"E\", \"D\", \"C\", \"B\", \"A\" },\n        sourceSelectionThickness = 0.36,\n        sourceSkirtOffset = { x = -1.5, z = -1 },\n        sourceMaxSpeedReverse = 0,\n        sourceRotateOnSpot = true,\n        sourceTurnRadius = 2,\n        sourceCollideFriendly = false,\n        sourceProjectileDestroyOnWater = true,\n        sanctuarySelectionThicknessUsesCollisionHeight = true,\n        sanctuarySkirtOffsetRuntime = false,\n        sanctuaryReverseSpeedRuntime = false,\n        sanctuaryProjectileCollisionFilterRuntime = false,\n    },\n}\nUnitTemplate.audio = UnitTemplate.audio or {}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 1, z = 0 },\n    collisionSize = { x = 6, y = 2, z = 7 },\n    targetBones = { \"Root\", \"Turret_Aim\" },\n}\nUnitTemplate.defence = { health = { max = 17500, regen = 0, value = 17500 } }\nUnitTemplate.economy = {\n    buildTime = 99900,\n    cost = { alloys = 299700, energy = 5994000 },\n}\nUnitTemplate.footprint = { x = 5, y = 5 }\nUnitTemplate.skirtSize = { x = 8, y = 8 }\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardScathis\" }\nUnitTemplate.general.displayName = \"Experimental Mobile Rapid-Fire Artillery\"\nUnitTemplate.general.icon = { shape = \"experimental1\", symbol = \"indirect\", tech = \"t1\" }\nUnitTemplate.general.iconUI = \"tech3_land1_indirect.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 10\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.name = \"Scathis\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true, Move = true,\n    Patrol = true, Stop = true,\n}\nUnitTemplate.general.tpId = \"ugl4011\"\nUnitTemplate.intel = { visionRadius = 26 }\nUnitTemplate.movement = {\n    acceleration = 1,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    deceleration = 1,\n    collisionMaskDefault = { \"LandLarge\" },\n    collisionMaskSpawn = { \"LandLarge\" },\n    maxReverseDistance = 0,\n    minSpeed = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotateOnSpot = true,\n    rotationSpeed = 40,\n    sortOrder = 3,\n    speed = 1,\n    terrainAlignmentFactor = 1,\n    turnRadius = 2,\n    type = \"TracksLand\",\n}\nUnitTemplate.tags = {\n    \"ARTILLERY\", \"BUILDABLE_BY_T3_ENGINEER\", \"GUARD\", \"INDIRECT_FIRE\",\n    \"LAND\", \"MOBILE\", \"TANK\", \"TECH4\",\n}\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.animations = {\n    walk = {\n        clipName = \"Rest\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl4011/LOD0/ugl4011.sananimation\",\n    },\n    open = {\n        clipName = \"AnimOpen\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl4011/LOD0/ugl4011.sananimation\",\n    },\n    close = {\n        clipName = \"AnimClose\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl4011/LOD0/ugl4011.sananimation\",\n    },\n}\nUnitTemplate.visuals.mesh = { lod0distance = 175, lod1distance = 550 }\nUnitTemplate.visuals.selection = { size = { x = 4, y = 5 } }\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Turret_Aim_Barrel_Muzzle\",\n                aimTolerance = 0,\n                defaultPitchAdjustment = 0,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = \"Turret_Aim_Barrel\",\n                pitchMax = 45,\n                pitchMin = -45,\n                pitchSpeed = 30,\n                poseResetTime = 4,\n                projectileSpeed = 160,\n                reduceMuzzleVelocityToTarget = true,\n                solverType = \"HighArc\",\n                yawBone = \"Turret_Aim\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 90,\n            },\n        },\n        damage = 3000,\n        damageFriendly = true,\n        damageRadius = 7,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vgm8321_plasma_stream_large_muzzle.sanvfx\" },\n        firingRandomness = 0.3,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = 4,\n        muzzleGroups = {\n            { muzzles = { \"Turret_Aim_Barrel_Muzzle\" } },\n            { muzzles = { \"Turret_Barrel_F_B03\" } },\n            { muzzles = { \"Turret_Barrel_E_B03\" } },\n            { muzzles = { \"Turret_Barrel_D_B03\" } },\n            { muzzles = { \"Turret_Barrel_C_B03\" } },\n            { muzzles = { \"Turret_Barrel_B_B03\" } },\n            { muzzles = { \"Turret_Barrel_A_B03\" } },\n        },\n        muzzles = {\n            Turret_Aim_Barrel_Muzzle = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_F_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_E_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_D_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_C_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_B_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_A_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n        },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 100,\n        projectileTemplate = \"pgr401s\",\n        rangeMax = 4000,\n        rangeMin = 100,\n        rangeRingType = \"IndirectFire\",\n        reloadProgressBar = true,\n        reloadTime = 1.8867924528301887,\n        scoFaAboveWaterTargetsOnly = true,\n        scoFaArtilleryShieldBlocks = true,\n        scoFaEnergyChargeForFirstShot = false,\n        scoFaEnergyDrainPerSecond = 2000,\n        scoFaEnergyRequired = 2000,\n        scoFaScathis = true,\n        scoFaWeaponUnpackLocksMotion = true,\n        scoFaWeaponUnpackSeconds = 16.66666603088379,\n        scoFaWeaponRepackSeconds = 16.66666603088379,\n        scoFaWeaponRepackTimeout = 4,\n        targetWaterLimits = \"Above\",\n    },\n}";

	private const string HostGuardAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0\nlocal SCO_ScathisGuardLandUnit = HostGuardLandUnit or GuardLandUnit\nif not SCO_ScathisGuardLandUnit then error(\"Scathis requires GuardLandUnit\") end\nHostGuardScathis = Class(\"GuardScathis\", SCO_ScathisGuardLandUnit)\nlocal GuardScathis = HostGuardScathis\n\nfunction GuardScathis:RotatorsEnabledOnConstruction()\n    return false\nend\n\nfunction GuardScathis:UpdateAnimations()\n    -- URL0401 is tracked. Its only source clip is weapon-driven unpacking.\nend\n\nfunction GuardScathis:OnStopBeingBuilt()\n    SCO_ScathisGuardLandUnit.OnStopBeingBuilt(self)\n    local rest = self.tp.visuals and self.tp.visuals.animations\n        and self.tp.visuals.animations.walk\n    if not rest or not rest.id then error(\"Scathis requires its hash-pinned Rest clip\") end\n    Engine.PlayAnimation(self.id, rest.id, 0.1)\n    self:SetRotatorsEnabled(false)\nend";

	private const string ClientGuardAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0\nlocal SCO_ScathisClientGuardLandUnit = ClientGuardLandUnit or GuardLandUnit\nif not SCO_ScathisClientGuardLandUnit then error(\"Scathis requires client GuardLandUnit\") end\nClientGuardScathis = Class(\"GuardScathis\", SCO_ScathisClientGuardLandUnit)";

	private const string HostWeaponAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0\nlocal SCO_ScathisCommands = Import(\"common/commands/definitions/projectiles.lua\")\nlocal SCO_ScathisStockInit = HostWeapon.__init\nlocal SCO_ScathisStockDelete = HostWeapon.Delete\nlocal SCO_ScathisStockSetAimTarget = HostWeapon.SetAimTarget\nlocal SCO_ScathisStockCanShootAt = HostWeapon.CanShootAt\nlocal SCO_ScathisStockUpdate = HostWeapon.Update\nlocal SCO_ScathisStockUpdateProjectile = HostWeapon.UpdateProjectile\n\nlocal function SCO_IsScathisWeapon(self)\n    return self.unit and self.unit.tpId == \"ugl4011\"\n        and self.tp and self.tp.scoFaScathis == true\nend\n\nlocal function SCO_PlayScathisAnimation(self, key)\n    local animation = self.unit.tp.visuals and self.unit.tp.visuals.animations\n        and self.unit.tp.visuals.animations[key]\n    if not animation or not animation.id then\n        error(\"Scathis requires source animation \" .. tostring(key))\n    end\n    Engine.PlayAnimation(self.unit.id, animation.id, 0.1)\nend\n\nlocal function SCO_SetScathisMovementLocked(self, locked)\n    if self.scoScathisMovementLocked == locked then return end\n    self.scoScathisMovementLocked = locked\n    Engine.SetMovementEnabled(self.unit.id, not locked)\nend\n\nlocal function SCO_ResetScathisFakeTurret(self)\n    if not self.scoScathisFakeTurretId then return end\n    Engine.SetRotatorEnabled(self.scoScathisFakeTurretId, false)\n    if self.scoScathisFakeTurretBaseRotation then\n        Engine.SetGlobalEntityLocalRotation(\n            self.scoScathisFakeTurretId,\n            self.scoScathisFakeTurretBaseRotation)\n    end\n    self.scoScathisFakeRotationDegrees = 0\nend\n\nlocal function SCO_ScathisAngleBetween(a, b)\n    local lengthA = math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z)\n    local lengthB = math.sqrt(b.x * b.x + b.y * b.y + b.z * b.z)\n    if lengthA <= 0 or lengthB <= 0 then\n        error(\"Scathis cannot align a zero-length barrel direction\")\n    end\n    local cosine = (a.x * b.x + a.y * b.y + a.z * b.z)\n        / (lengthA * lengthB)\n    cosine = math.max(-1, math.min(1, cosine))\n    return math.acos(cosine) * 180 / math.pi\nend\n\nlocal function SCO_SetScathisPitch(self, degrees)\n    local delta = Engine.QuaternionAxisAngle(\n        EngineClasses.float3(1, 0, 0),\n        math.rad(degrees))\n    for index, boneId in ipairs(self.scoScathisPitchBoneIds) do\n        Engine.SetGlobalEntityLocalRotation(\n            boneId,\n            Engine.QuaternionMultiply(self.scoScathisPitchBases[index], delta))\n    end\n    self.scoScathisPitchCurrent = degrees\nend\n\nlocal function SCO_ResetScathisPitch(self)\n    if self.scoScathisPitchBases then\n        for index, boneId in ipairs(self.scoScathisPitchBoneIds) do\n            Engine.SetGlobalEntityLocalRotation(\n                boneId,\n                self.scoScathisPitchBases[index])\n        end\n    end\n    self.scoScathisPitchBases = nil\n    self.scoScathisPitchRestAngle = nil\n    self.scoScathisPitchCurrent = 0\n    self.scoScathisPitchGoal = 0\n    self.scoScathisPitchLastTime = nil\n    self.scoScathisPitchDelayDeadline = nil\nend\n\nlocal function SCO_BeginScathisPitchAlignment(self, now)\n    if not self.scoScathisPitchBases then\n        self.scoScathisPitchBases = {}\n        for index, boneId in ipairs(self.scoScathisPitchBoneIds) do\n            local rotation = EngineClasses.quaternion()\n            local rotationResult = Engine.GetGlobalEntityLocalRotation(boneId, rotation)\n            if rotationResult ~= EngineErrorCode.Success then\n                error(\"Scathis cannot read fake barrel \" .. tostring(index) .. \" rotation\")\n            end\n            self.scoScathisPitchBases[index] = rotation\n        end\n        local barrelResult, barrelDirection = Engine.GetGlobalEntityForwardDirection(\n            self.scoScathisPitchBoneIds[self.scoScathisBarrelIndex])\n        local baseResult, baseDirection = Engine.GetGlobalEntityForwardDirection(\n            self.scoScathisAimBoneId)\n        if barrelResult ~= EngineErrorCode.Success\n            or baseResult ~= EngineErrorCode.Success\n        then error(\"Scathis cannot read unpacked fake-barrel direction\") end\n        self.scoScathisPitchRestAngle =\n            SCO_ScathisAngleBetween(barrelDirection, baseDirection)\n    end\n\n    local aimResult, aimDirection = Engine.GetGlobalEntityForwardDirection(\n        self.scoScathisAimBarrelBoneId)\n    local baseResult, baseDirection = Engine.GetGlobalEntityForwardDirection(\n        self.scoScathisAimBoneId)\n    if aimResult ~= EngineErrorCode.Success or baseResult ~= EngineErrorCode.Success then\n        error(\"Scathis cannot read central aim-barrel direction\")\n    end\n    self.scoScathisPitchGoal = self.scoScathisPitchRestAngle\n        - SCO_ScathisAngleBetween(aimDirection, baseDirection)\n    self.scoScathisPitchLastTime = now\n    self.scoScathisPitchDelayDeadline = nil\n    self.scoScathisDeployState = \"aligning\"\nend\n\nlocal function SCO_UpdateScathisPitchAlignment(self, now)\n    if self.scoScathisPitchDelayDeadline then\n        if now >= self.scoScathisPitchDelayDeadline then\n            self.scoScathisDeployState = \"deployed\"\n            return true\n        end\n        return false\n    end\n\n    local current = self.scoScathisPitchCurrent or 0\n    local goal = self.scoScathisPitchGoal or 0\n    local difference = goal - current\n    local elapsed = math.max(0, now - (self.scoScathisPitchLastTime or now))\n    local step = 30 * elapsed\n    if math.abs(difference) <= step then\n        local arrivalTime = now\n        if step > 0 then\n            arrivalTime = (self.scoScathisPitchLastTime or now)\n                + math.abs(difference) / 30\n        end\n        SCO_SetScathisPitch(self, goal)\n        self.scoScathisPitchDelayDeadline = arrivalTime + 0.2\n    elseif step > 0 then\n        SCO_SetScathisPitch(\n            self,\n            current + (difference > 0 and step or -step))\n    end\n    self.scoScathisPitchLastTime = now\n    if self.scoScathisPitchDelayDeadline\n        and now >= self.scoScathisPitchDelayDeadline\n    then\n        self.scoScathisDeployState = \"deployed\"\n        return true\n    end\n    return false\nend\n\nlocal function SCO_ScathisRotationThread(unit, weapon, generation)\n    WaitSeconds(0.5)\n    if unit.dead or weapon.scoScathisDisposed\n        or weapon.scoScathisRotationGeneration ~= generation\n    then return end\n    Engine.SetRotatorSpeed(\n        weapon.scoScathisFakeTurretId,\n        EngineClasses.float3(0, 120, 0))\n    Engine.SetRotatorEnabled(weapon.scoScathisFakeTurretId, true)\n    WaitSeconds(0.5)\n    if unit.dead or weapon.scoScathisDisposed\n        or weapon.scoScathisRotationGeneration ~= generation\n    then return end\n    Engine.SetRotatorEnabled(weapon.scoScathisFakeTurretId, false)\n    weapon.scoScathisFakeRotationDegrees =\n        ((weapon.scoScathisFakeRotationDegrees or 0) + 60) % 360\nend\n\nfunction HostWeapon:__init(aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)\n    SCO_ScathisStockInit(self, aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)\n    if not SCO_IsScathisWeapon(self) then return end\n    if #muzzleGroups ~= 7 or #muzzleGroups[1] ~= 1 then\n        error(\"Scathis requires one central and six indexed fake muzzle groups\")\n    end\n    self.scoScathisFakeMuzzles = {}\n    for index = 2, 7 do\n        if #muzzleGroups[index] ~= 1 then\n            error(\"Scathis fake muzzle group \" .. tostring(index - 1) .. \" is invalid\")\n        end\n        table.insert(self.scoScathisFakeMuzzles, muzzleGroups[index][1])\n    end\n    -- All seven host/client muzzle IDs remain registered. Only the central\n    -- source muzzle may instantiate the real projectile.\n    self.muzzleGroups = { muzzleGroups[1] }\n    self.scoScathisBarrelIndex = 1\n    self.scoScathisDeployState = \"packed\"\n    self.scoScathisEnergyDebt = 0\n    self.scoScathisRotationGeneration = 0\n    self.scoScathisPitchBoneIds = {}\n    local pitchBoneNames = {\n        \"Turret_Barrel_F_B01\", \"Turret_Barrel_E_B01\",\n        \"Turret_Barrel_D_B01\", \"Turret_Barrel_C_B01\",\n        \"Turret_Barrel_B_B01\", \"Turret_Barrel_A_B01\",\n    }\n    for index, boneName in ipairs(pitchBoneNames) do\n        local pitchResult, pitchBoneId = Engine.GetGlobalBone(unit.id, boneName)\n        if pitchResult ~= EngineErrorCode.Success then\n            error(\"Scathis fake pitch bone \" .. tostring(index) .. \" is absent\")\n        end\n        self.scoScathisPitchBoneIds[index] = pitchBoneId\n    end\n    local aimResult, aimBoneId = Engine.GetGlobalBone(unit.id, \"Turret_Aim\")\n    local aimBarrelResult, aimBarrelBoneId =\n        Engine.GetGlobalBone(unit.id, \"Turret_Aim_Barrel\")\n    if aimResult ~= EngineErrorCode.Success\n        or aimBarrelResult ~= EngineErrorCode.Success\n    then error(\"Scathis central aim bones are absent\") end\n    self.scoScathisAimBoneId = aimBoneId\n    self.scoScathisAimBarrelBoneId = aimBarrelBoneId\n    self.scoScathisPitchCurrent = 0\n    self.scoScathisPitchGoal = 0\n    local result, fakeTurretId = Engine.GetGlobalBone(unit.id, \"Turret_Fake\")\n    if result ~= EngineErrorCode.Success then error(\"Scathis Turret_Fake bone is absent\") end\n    self.scoScathisFakeTurretId = fakeTurretId\n    self.scoScathisFakeTurretBaseRotation = EngineClasses.quaternion()\n    Engine.GetGlobalEntityLocalRotation(fakeTurretId, self.scoScathisFakeTurretBaseRotation)\n    SCO_ResetScathisFakeTurret(self)\nend\n\nfunction HostWeapon:Delete()\n    if SCO_IsScathisWeapon(self) then\n        self.scoScathisDisposed = true\n        self.scoScathisRotationGeneration =\n            (self.scoScathisRotationGeneration or 0) + 1\n        SCO_ResetScathisFakeTurret(self)\n        SCO_ResetScathisPitch(self)\n    end\n    return SCO_ScathisStockDelete(self)\nend\n\nfunction HostWeapon:CanShootAt(targetUnit)\n    if not SCO_IsScathisWeapon(self) then\n        return SCO_ScathisStockCanShootAt(self, targetUnit)\n    end\n    if not SCO_ScathisStockCanShootAt(self, targetUnit) then return false end\n    if not self.tp.scoFaAboveWaterTargetsOnly then return true end\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return true end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    local position = targetUnit and targetUnit:GetPosition()\n    return levelResult == EngineErrorCode.Success and waterLevel ~= nil\n        and position ~= nil and position.y >= waterLevel - 0.05\nend\n\nfunction HostWeapon:SetAimTarget(targetUnit)\n    local previous = self.targetUnit\n    local result = SCO_ScathisStockSetAimTarget(self, targetUnit)\n    if not SCO_IsScathisWeapon(self) then return result end\n    local now = GetGameTimeSeconds()\n    if targetUnit then\n        self.scoScathisTargetLostTime = nil\n        if previous == nil and self.scoScathisDeployState == \"deployed\" then\n            SCO_BeginScathisPitchAlignment(self, now)\n        end\n    elseif previous ~= nil then\n        self.scoScathisTargetLostTime = now\n    end\n    return result\nend\n\nfunction HostWeapon:SCO_UpdateScathisDeployment(now)\n    local state = self.scoScathisDeployState\n    local hasTarget = self:HasTarget()\n    if state == \"packed\" and hasTarget then\n        SCO_ResetScathisFakeTurret(self)\n        SCO_SetScathisMovementLocked(self, true)\n        SCO_PlayScathisAnimation(self, \"open\")\n        self.scoScathisDeployState = \"opening\"\n        self.scoScathisDeployDeadline = now + 16.66666603088379\n        return\n    end\n    if state == \"opening\" and now >= self.scoScathisDeployDeadline then\n        if hasTarget then\n            SCO_BeginScathisPitchAlignment(self, now)\n            state = \"aligning\"\n        else\n            self.scoScathisDeployState = \"deployed\"\n            state = \"deployed\"\n        end\n    end\n    if state == \"aligning\" then\n        if not SCO_UpdateScathisPitchAlignment(self, now) then return end\n        state = \"deployed\"\n    end\n    if state == \"deployed\" and not hasTarget then\n        self.scoScathisTargetLostTime = self.scoScathisTargetLostTime or now\n        if now >= self.scoScathisTargetLostTime + 4 then\n            self.scoScathisRotationGeneration =\n                (self.scoScathisRotationGeneration or 0) + 1\n            SCO_ResetScathisFakeTurret(self)\n            SCO_ResetScathisPitch(self)\n            SCO_PlayScathisAnimation(self, \"close\")\n            self.scoScathisDeployState = \"closing\"\n            self.scoScathisDeployDeadline = now + 16.66666603088379\n        end\n        return\n    end\n    if state == \"closing\" and now >= self.scoScathisDeployDeadline then\n        self.scoScathisDeployState = \"packed\"\n        self.scoScathisDeployDeadline = nil\n        SCO_PlayScathisAnimation(self, \"walk\")\n        SCO_SetScathisMovementLocked(self, false)\n        if hasTarget then self:SCO_UpdateScathisDeployment(now) end\n    end\nend\n\nfunction HostWeapon:SCO_DrainScathisEnergy()\n    local debt = self.scoScathisEnergyDebt or 0\n    if debt <= 0 then return false end\n    local economy = self.unit:GetEconomy()\n    local request = math.min(\n        debt,\n        self.tp.scoFaEnergyDrainPerSecond * Constants.TickTimeStep)\n    local taken = economy and economy:TakeResources(\"energy\", request) or 0\n    self.scoScathisEnergyDebt = math.max(0, debt - taken)\n    return self.scoScathisEnergyDebt > 0\nend\n\nfunction HostWeapon:Update()\n    if not SCO_IsScathisWeapon(self) then return SCO_ScathisStockUpdate(self) end\n    self:SCO_UpdateScathisDeployment(GetGameTimeSeconds())\n    local draining = self:SCO_DrainScathisEnergy()\n    if self.scoScathisDeployState ~= \"deployed\" or draining then\n        if self.currentState == WeaponState.WaitingForReload then\n            self.reloadTimer = self.reloadTimer - Constants.TickTimeStep\n            if self.reloadTimer <= 0 then\n                self.currentState = WeaponState.WaitingForTarget\n            end\n        end\n        self:UpdateTargeting()\n        return\n    end\n    return SCO_ScathisStockUpdate(self)\nend\n\nfunction HostWeapon:UpdateProjectile(isOnTarget)\n    if not SCO_IsScathisWeapon(self) then\n        return SCO_ScathisStockUpdateProjectile(self, isOnTarget)\n    end\n    local fired = false\n    if self.currentState == WeaponState.ShootSalvo then\n        local central = self.muzzleGroups[1] and self.muzzleGroups[1][1]\n        fired = central ~= nil\n            and self.projectileTemplate.general.prefabID ~= nil\n            and self:GetDesiredProjectileValues(central.aimControllerId) ~= nil\n    end\n    local result = SCO_ScathisStockUpdateProjectile(self, isOnTarget)\n    if fired then\n        local fake = self.scoScathisFakeMuzzles[self.scoScathisBarrelIndex]\n        SCO_ScathisCommands.FireMuzzle.Send(fake.id)\n        self.scoScathisBarrelIndex = self.scoScathisBarrelIndex % 6 + 1\n        self.scoScathisEnergyDebt = self.tp.scoFaEnergyRequired\n        self.scoScathisRotationGeneration =\n            (self.scoScathisRotationGeneration or 0) + 1\n        self.unit:NewThread(\n            SCO_ScathisRotationThread,\n            self,\n            self.scoScathisRotationGeneration)\n    end\n    return result\nend";

	private const string ClientMuzzleAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0\nlocal SCO_ScathisStockFireMuzzle = ClientMuzzle.FireMuzzle\nlocal SCO_ScathisStockCleanupMuzzle = ClientMuzzle.Cleanup\n\nlocal function SCO_IsScathisClientMuzzle(self)\n    return self.weapon and self.weapon.unit\n        and self.weapon.unit.tpId == \"ugl4011\"\n        and self.weapon.tp and self.weapon.tp.scoFaScathis == true\nend\n\nlocal function SCO_ScathisRecoilReturn(self, generation, boneId, basePosition)\n    WaitTicks(1)\n    local duration = 2 / 1.325\n    local elapsed = 0\n    while elapsed < duration do\n        if self.deleted or self.scoScathisRecoilGeneration ~= generation then return end\n        elapsed = math.min(duration, elapsed + Constants.TickTimeStep)\n        local ratio = elapsed / duration\n        Engine.SetLocalEntityLocalPosition(\n            boneId,\n            EngineClasses.float3(\n                basePosition.x,\n                basePosition.y,\n                basePosition.z - 2 * (1 - ratio)))\n        if elapsed < duration then WaitTicks(1) end\n    end\nend\n\nlocal function SCO_StartScathisRecoil(self, boneName)\n    local boneId = self.weapon.unit:GetBoneId(boneName)\n    if not boneId then error(\"Scathis recoil bone is absent: \" .. tostring(boneName)) end\n    local result, current = Engine.GetLocalEntityLocalPosition(boneId)\n    if result ~= EngineErrorCode.Success or current == nil then\n        error(\"Scathis could not read recoil bone \" .. tostring(boneName))\n    end\n    local base = EngineClasses.float3(current.x, current.y, current.z)\n    self.scoScathisRecoilGeneration = (self.scoScathisRecoilGeneration or 0) + 1\n    self.scoScathisRecoilBoneId = boneId\n    self.scoScathisRecoilBase = base\n    Engine.SetLocalEntityLocalPosition(\n        boneId,\n        EngineClasses.float3(base.x, base.y, base.z - 2))\n    self:NewThread(\n        SCO_ScathisRecoilReturn,\n        self.scoScathisRecoilGeneration,\n        boneId,\n        base)\nend\n\nfunction ClientMuzzle:FireMuzzle()\n    if not SCO_IsScathisClientMuzzle(self) then\n        return SCO_ScathisStockFireMuzzle(self)\n    end\n    if self.boneName == \"Turret_Aim_Barrel_Muzzle\" then\n        local result = SCO_ScathisStockFireMuzzle(self)\n        SCO_StartScathisRecoil(self, \"Turret_Aim_Barrel\")\n        return result\n    end\n    local recoilBone = string.gsub(self.boneName, \"_B03$\", \"_B02\")\n    if recoilBone == self.boneName then\n        error(\"Unexpected Scathis visual muzzle \" .. tostring(self.boneName))\n    end\n    -- The host emits exactly one selected fake muzzle event per real shot.\n    -- Suppress duplicate stock muzzle/audio while preserving source recoil.\n    SCO_StartScathisRecoil(self, recoilBone)\nend\n\nfunction ClientMuzzle:Cleanup()\n    if SCO_IsScathisClientMuzzle(self) then\n        self.scoScathisRecoilGeneration =\n            (self.scoScathisRecoilGeneration or 0) + 1\n        if self.scoScathisRecoilBoneId and self.scoScathisRecoilBase then\n            Engine.SetLocalEntityLocalPosition(\n                self.scoScathisRecoilBoneId,\n                self.scoScathisRecoilBase)\n        end\n    end\n    return SCO_ScathisStockCleanupMuzzle(self)\nend";

	private const string ImportAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0\nlocal SCO_ScathisScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_ScathisScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then return folders end\n    local candidate = directory .. \"pgr401s\"\n    for _, folder in ipairs(folders) do\n        if folder == candidate then return folders end\n    end\n    table.insert(folders, candidate)\n    return folders\nend";

	private const string ProjectileSource = "---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = { onImpact = { looping = false, name = \"agoi1130\" } },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = { name = \"Cybran_Scathis_Artillery_Proton\", tpId = \"pgr401s\" },\n    nonUniformScale = { x = 0.45, y = 0.45, z = 0.45 },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = {\n            { effects = { { particleName = \"VFX/Impact/vgi8321_plasma_stream_large_impact.sanvfx\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"VFX/Trails/vgt8321_plasma_stream_large_trail.sanvfx\" } } },\n        },\n    },\n}\n\n-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\n-- Source ID: CIFArtilleryProton01\n-- Source blueprint: projectiles/CIFArtilleryProton01/CIFArtilleryProton01_proj.bp\n-- Source blueprint SHA-256: e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e\n-- Source script: projectiles/CIFArtilleryProton01/CIFArtilleryProton01_script.lua\n-- Source script SHA-256: 98a19bd78f1a61dc4c2f3f9e2c63a6cb27aadb6cbb352dbe6cf430d3483ee0ef\n-- Limitation: FA Force/Fire emitter graphs, camera shake/follow, decal and\n-- explicit DestroyOnWater are not native Sanctuary projectile-template inputs.\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0";

	private static readonly (string Path, string Description)[] ExistingResources = new(string, string)[6]
	{
		("LJ/lua/common/units/unitsTemplates/ugl4011/ugl4011.santp", "UGL4011 Scathis template"),
		("LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Scathis host class"),
		("LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua", "Scathis client class"),
		("LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "Scathis host weapon runtime"),
		("LJ/lua/client/units/weaponsClasses/clientMuzzleClass.lua", "Scathis client recoil runtime"),
		("LJ/lua/common/systems/import.lua", "Scathis projectile scanner")
	};

	public static void Apply()
	{
		ValidatePinnedScope();
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>(7);
		try
		{
			obj = GetLuaFileCache();
			ValidateTransactionState(obj);
			QueueAppend(obj, list, "LJ/lua/common/units/unitsTemplates/ugl4011/ugl4011.santp", "UGL4011 Scathis template", "\n\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0\n-- Exact direct mapping: FA URL0401 Scathis replaces only ugl4011.\nUnitTemplate.additions = {\n    displayWreckOnDeath = true,\n    selectionHit = { size = { x = 4, y = 5 } },\n    rotators = {\n        {\n            boneName = \"Turret_Fake\",\n            speed = { x = 0, y = 120, z = 0 },\n        },\n    },\n    faSourceContract = {\n        mapping = \"URL0401 -> ugl4011\",\n        sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n        sourceBlueprint = \"units/URL0401/URL0401_unit.bp\",\n        sourceBlueprintSha256 = \"c0366fbe9bf45b4c5cb32c9b4618dd97d3756d46e6ff5e3d449d013e89669f74\",\n        sourceScript = \"units/URL0401/URL0401_Script.lua\",\n        sourceScriptSha256 = \"406c68acd2806fae507c68f23b57209a4d8982d512a9bcab3fc95887ba97794e\",\n        sourceOpenAnimation = \"units/URL0401/URL0401_Aopen.sca\",\n        sourceOpenAnimationSha256 = \"9fd6d8f08446ab7adbeed2923057f43878949cbdc27fc1d05c522e469fbbae6c\",\n        openFrames = 501,\n        openFps = 30,\n        openSeconds = 16.66666603088379,\n        repackTimeoutSeconds = 4,\n        sourceRackRecoilDistance = -20,\n        convertedRackRecoilDistance = -2,\n        sourceRackRecoilReturnSpeed = 13.25,\n        convertedRackRecoilReturnSpeed = 1.325,\n        fakeBarrelOrder = { \"F\", \"E\", \"D\", \"C\", \"B\", \"A\" },\n        sourceSelectionThickness = 0.36,\n        sourceSkirtOffset = { x = -1.5, z = -1 },\n        sourceMaxSpeedReverse = 0,\n        sourceRotateOnSpot = true,\n        sourceTurnRadius = 2,\n        sourceCollideFriendly = false,\n        sourceProjectileDestroyOnWater = true,\n        sanctuarySelectionThicknessUsesCollisionHeight = true,\n        sanctuarySkirtOffsetRuntime = false,\n        sanctuaryReverseSpeedRuntime = false,\n        sanctuaryProjectileCollisionFilterRuntime = false,\n    },\n}\nUnitTemplate.audio = UnitTemplate.audio or {}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 1, z = 0 },\n    collisionSize = { x = 6, y = 2, z = 7 },\n    targetBones = { \"Root\", \"Turret_Aim\" },\n}\nUnitTemplate.defence = { health = { max = 17500, regen = 0, value = 17500 } }\nUnitTemplate.economy = {\n    buildTime = 99900,\n    cost = { alloys = 299700, energy = 5994000 },\n}\nUnitTemplate.footprint = { x = 5, y = 5 }\nUnitTemplate.skirtSize = { x = 8, y = 8 }\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardScathis\" }\nUnitTemplate.general.displayName = \"Experimental Mobile Rapid-Fire Artillery\"\nUnitTemplate.general.icon = { shape = \"experimental1\", symbol = \"indirect\", tech = \"t1\" }\nUnitTemplate.general.iconUI = \"tech3_land1_indirect.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 10\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.name = \"Scathis\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true, Move = true,\n    Patrol = true, Stop = true,\n}\nUnitTemplate.general.tpId = \"ugl4011\"\nUnitTemplate.intel = { visionRadius = 26 }\nUnitTemplate.movement = {\n    acceleration = 1,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    deceleration = 1,\n    collisionMaskDefault = { \"LandLarge\" },\n    collisionMaskSpawn = { \"LandLarge\" },\n    maxReverseDistance = 0,\n    minSpeed = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotateOnSpot = true,\n    rotationSpeed = 40,\n    sortOrder = 3,\n    speed = 1,\n    terrainAlignmentFactor = 1,\n    turnRadius = 2,\n    type = \"TracksLand\",\n}\nUnitTemplate.tags = {\n    \"ARTILLERY\", \"BUILDABLE_BY_T3_ENGINEER\", \"GUARD\", \"INDIRECT_FIRE\",\n    \"LAND\", \"MOBILE\", \"TANK\", \"TECH4\",\n}\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.animations = {\n    walk = {\n        clipName = \"Rest\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl4011/LOD0/ugl4011.sananimation\",\n    },\n    open = {\n        clipName = \"AnimOpen\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl4011/LOD0/ugl4011.sananimation\",\n    },\n    close = {\n        clipName = \"AnimClose\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl4011/LOD0/ugl4011.sananimation\",\n    },\n}\nUnitTemplate.visuals.mesh = { lod0distance = 175, lod1distance = 550 }\nUnitTemplate.visuals.selection = { size = { x = 4, y = 5 } }\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Turret_Aim_Barrel_Muzzle\",\n                aimTolerance = 0,\n                defaultPitchAdjustment = 0,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = \"Turret_Aim_Barrel\",\n                pitchMax = 45,\n                pitchMin = -45,\n                pitchSpeed = 30,\n                poseResetTime = 4,\n                projectileSpeed = 160,\n                reduceMuzzleVelocityToTarget = true,\n                solverType = \"HighArc\",\n                yawBone = \"Turret_Aim\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 90,\n            },\n        },\n        damage = 3000,\n        damageFriendly = true,\n        damageRadius = 7,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vgm8321_plasma_stream_large_muzzle.sanvfx\" },\n        firingRandomness = 0.3,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = 4,\n        muzzleGroups = {\n            { muzzles = { \"Turret_Aim_Barrel_Muzzle\" } },\n            { muzzles = { \"Turret_Barrel_F_B03\" } },\n            { muzzles = { \"Turret_Barrel_E_B03\" } },\n            { muzzles = { \"Turret_Barrel_D_B03\" } },\n            { muzzles = { \"Turret_Barrel_C_B03\" } },\n            { muzzles = { \"Turret_Barrel_B_B03\" } },\n            { muzzles = { \"Turret_Barrel_A_B03\" } },\n        },\n        muzzles = {\n            Turret_Aim_Barrel_Muzzle = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_F_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_E_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_D_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_C_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_B_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_A_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n        },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 100,\n        projectileTemplate = \"pgr401s\",\n        rangeMax = 4000,\n        rangeMin = 100,\n        rangeRingType = \"IndirectFire\",\n        reloadProgressBar = true,\n        reloadTime = 1.8867924528301887,\n        scoFaAboveWaterTargetsOnly = true,\n        scoFaArtilleryShieldBlocks = true,\n        scoFaEnergyChargeForFirstShot = false,\n        scoFaEnergyDrainPerSecond = 2000,\n        scoFaEnergyRequired = 2000,\n        scoFaScathis = true,\n        scoFaWeaponUnpackLocksMotion = true,\n        scoFaWeaponUnpackSeconds = 16.66666603088379,\n        scoFaWeaponRepackSeconds = 16.66666603088379,\n        scoFaWeaponRepackTimeout = 4,\n        targetWaterLimits = \"Above\",\n    },\n}", ValidateUnit);
			QueueAppend(obj, list, "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Scathis host class", "\n\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0\nlocal SCO_ScathisGuardLandUnit = HostGuardLandUnit or GuardLandUnit\nif not SCO_ScathisGuardLandUnit then error(\"Scathis requires GuardLandUnit\") end\nHostGuardScathis = Class(\"GuardScathis\", SCO_ScathisGuardLandUnit)\nlocal GuardScathis = HostGuardScathis\n\nfunction GuardScathis:RotatorsEnabledOnConstruction()\n    return false\nend\n\nfunction GuardScathis:UpdateAnimations()\n    -- URL0401 is tracked. Its only source clip is weapon-driven unpacking.\nend\n\nfunction GuardScathis:OnStopBeingBuilt()\n    SCO_ScathisGuardLandUnit.OnStopBeingBuilt(self)\n    local rest = self.tp.visuals and self.tp.visuals.animations\n        and self.tp.visuals.animations.walk\n    if not rest or not rest.id then error(\"Scathis requires its hash-pinned Rest clip\") end\n    Engine.PlayAnimation(self.id, rest.id, 0.1)\n    self:SetRotatorsEnabled(false)\nend", ValidateHostGuard);
			QueueAppend(obj, list, "LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua", "Scathis client class", "\n\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0\nlocal SCO_ScathisClientGuardLandUnit = ClientGuardLandUnit or GuardLandUnit\nif not SCO_ScathisClientGuardLandUnit then error(\"Scathis requires client GuardLandUnit\") end\nClientGuardScathis = Class(\"GuardScathis\", SCO_ScathisClientGuardLandUnit)", ValidateClientGuard);
			QueueAppend(obj, list, "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "Scathis host weapon runtime", "\n\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0\nlocal SCO_ScathisCommands = Import(\"common/commands/definitions/projectiles.lua\")\nlocal SCO_ScathisStockInit = HostWeapon.__init\nlocal SCO_ScathisStockDelete = HostWeapon.Delete\nlocal SCO_ScathisStockSetAimTarget = HostWeapon.SetAimTarget\nlocal SCO_ScathisStockCanShootAt = HostWeapon.CanShootAt\nlocal SCO_ScathisStockUpdate = HostWeapon.Update\nlocal SCO_ScathisStockUpdateProjectile = HostWeapon.UpdateProjectile\n\nlocal function SCO_IsScathisWeapon(self)\n    return self.unit and self.unit.tpId == \"ugl4011\"\n        and self.tp and self.tp.scoFaScathis == true\nend\n\nlocal function SCO_PlayScathisAnimation(self, key)\n    local animation = self.unit.tp.visuals and self.unit.tp.visuals.animations\n        and self.unit.tp.visuals.animations[key]\n    if not animation or not animation.id then\n        error(\"Scathis requires source animation \" .. tostring(key))\n    end\n    Engine.PlayAnimation(self.unit.id, animation.id, 0.1)\nend\n\nlocal SCO_ScathisOpenSeconds = 16.66666603088379\nlocal SCO_ScathisPitchGoalTolerance = 0.05\nlocal SCO_ScathisSampleSentinel = -10000\n\nlocal function SCO_SampleScathisDeployment(self, progress)\n    local animation = self.unit.tp.visuals and self.unit.tp.visuals.animations\n        and self.unit.tp.visuals.animations.open\n    if not animation or not animation.id then\n        error(\"Scathis requires source animation open\")\n    end\n    -- The coordinator's exact-time bridge samples the original open clip\n    -- in either direction without restarting a fully open close clip.\n    Engine.PlayAnimation(\n        self.unit.id, animation.id, SCO_ScathisSampleSentinel + progress)\nend\n\nlocal function SCO_AdvanceScathisDeployment(self, now, direction)\n    local lastTime = self.scoScathisDeployLastTime or now\n    self.scoScathisDeployLastTime = now\n    local progress = (self.scoScathisDeployProgress or 0)\n        + direction * math.max(0, now - lastTime)\n    progress = math.max(0, math.min(SCO_ScathisOpenSeconds, progress))\n    self.scoScathisDeployProgress = progress\n    SCO_SampleScathisDeployment(self, progress)\n    return progress\nend\n\nlocal function SCO_SetScathisMovementLocked(self, locked)\n    if self.scoScathisMovementLocked == locked then return end\n    self.scoScathisMovementLocked = locked\n    Engine.SetMovementEnabled(self.unit.id, not locked)\nend\n\nlocal function SCO_ResetScathisFakeTurret(self)\n    if not self.scoScathisFakeTurretId then return end\n    Engine.SetRotatorEnabled(self.scoScathisFakeTurretId, false)\n    if self.scoScathisFakeTurretBaseRotation then\n        Engine.SetGlobalEntityLocalRotation(\n            self.scoScathisFakeTurretId,\n            self.scoScathisFakeTurretBaseRotation)\n    end\n    self.scoScathisFakeRotationDegrees = 0\nend\n\nlocal function SCO_ScathisAngleBetween(a, b)\n    local lengthA = math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z)\n    local lengthB = math.sqrt(b.x * b.x + b.y * b.y + b.z * b.z)\n    if lengthA <= 0 or lengthB <= 0 then\n        error(\"Scathis cannot align a zero-length barrel direction\")\n    end\n    local cosine = (a.x * b.x + a.y * b.y + a.z * b.z)\n        / (lengthA * lengthB)\n    cosine = math.max(-1, math.min(1, cosine))\n    return math.acos(cosine) * 180 / math.pi\nend\n\nlocal function SCO_SetScathisPitch(self, degrees)\n    local delta = Engine.QuaternionAxisAngle(\n        EngineClasses.float3(1, 0, 0),\n        math.rad(degrees))\n    for index, boneId in ipairs(self.scoScathisPitchBoneIds) do\n        Engine.SetGlobalEntityLocalRotation(\n            boneId,\n            Engine.QuaternionMultiply(self.scoScathisPitchBases[index], delta))\n    end\n    self.scoScathisPitchCurrent = degrees\nend\n\nlocal function SCO_ResetScathisPitch(self)\n    if self.scoScathisPitchBases then\n        for index, boneId in ipairs(self.scoScathisPitchBoneIds) do\n            Engine.SetGlobalEntityLocalRotation(\n                boneId,\n                self.scoScathisPitchBases[index])\n        end\n    end\n    self.scoScathisPitchBases = nil\n    self.scoScathisPitchRestAngle = nil\n    self.scoScathisPitchCurrent = 0\n    self.scoScathisPitchGoal = 0\n    self.scoScathisPitchLastTime = nil\n    self.scoScathisPitchDelayDeadline = nil\nend\n\nlocal function SCO_ReadScathisPitchGoal(self)\n    local aimResult, aimDirection = Engine.GetGlobalEntityForwardDirection(\n        self.scoScathisAimBarrelBoneId)\n    local baseResult, baseDirection = Engine.GetGlobalEntityForwardDirection(\n        self.scoScathisAimBoneId)\n    if aimResult ~= EngineErrorCode.Success or baseResult ~= EngineErrorCode.Success then\n        error(\"Scathis cannot read central aim-barrel direction\")\n    end\n    return self.scoScathisPitchRestAngle\n        - SCO_ScathisAngleBetween(aimDirection, baseDirection)\nend\n\nlocal function SCO_BeginScathisPitchAlignment(self, now)\n    if not self.scoScathisPitchBases then\n        self.scoScathisPitchBases = {}\n        for index, boneId in ipairs(self.scoScathisPitchBoneIds) do\n            local rotation = EngineClasses.quaternion()\n            local rotationResult = Engine.GetGlobalEntityLocalRotation(boneId, rotation)\n            if rotationResult ~= EngineErrorCode.Success then\n                error(\"Scathis cannot read fake barrel \" .. tostring(index) .. \" rotation\")\n            end\n            self.scoScathisPitchBases[index] = rotation\n        end\n        local barrelResult, barrelDirection = Engine.GetGlobalEntityForwardDirection(\n            self.scoScathisPitchBoneIds[self.scoScathisBarrelIndex])\n        local baseResult, baseDirection = Engine.GetGlobalEntityForwardDirection(\n            self.scoScathisAimBoneId)\n        if barrelResult ~= EngineErrorCode.Success\n            or baseResult ~= EngineErrorCode.Success\n        then error(\"Scathis cannot read unpacked fake-barrel direction\") end\n        self.scoScathisPitchRestAngle =\n            SCO_ScathisAngleBetween(barrelDirection, baseDirection)\n    end\n\n    self.scoScathisPitchGoal = SCO_ReadScathisPitchGoal(self)\n    self.scoScathisPitchLastTime = now\n    self.scoScathisPitchDelayDeadline = nil\n    self.scoScathisDeployState = \"aligning\"\nend\n\nlocal function SCO_UpdateScathisPitchAlignment(self, now)\n    local sampledGoal = SCO_ReadScathisPitchGoal(self)\n    if math.abs(sampledGoal - (self.scoScathisPitchGoal or sampledGoal))\n        > SCO_ScathisPitchGoalTolerance\n    then\n        self.scoScathisPitchGoal = sampledGoal\n        self.scoScathisPitchDelayDeadline = nil\n    end\n    if self.scoScathisPitchDelayDeadline then\n        if now >= self.scoScathisPitchDelayDeadline\n            and self:IsWeaponOnTarget()\n        then\n            self.scoScathisDeployState = \"deployed\"\n            return true\n        end\n        return false\n    end\n\n    local current = self.scoScathisPitchCurrent or 0\n    local goal = self.scoScathisPitchGoal or 0\n    local difference = goal - current\n    local elapsed = math.max(0, now - (self.scoScathisPitchLastTime or now))\n    local step = 30 * elapsed\n    if math.abs(difference) <= step then\n        local arrivalTime = now\n        if step > 0 then\n            arrivalTime = (self.scoScathisPitchLastTime or now)\n                + math.abs(difference) / 30\n        end\n        SCO_SetScathisPitch(self, goal)\n        self.scoScathisPitchDelayDeadline = arrivalTime + 0.2\n    elseif step > 0 then\n        SCO_SetScathisPitch(\n            self,\n            current + (difference > 0 and step or -step))\n    end\n    self.scoScathisPitchLastTime = now\n    if self.scoScathisPitchDelayDeadline\n        and now >= self.scoScathisPitchDelayDeadline\n        and self:IsWeaponOnTarget()\n    then\n        self.scoScathisDeployState = \"deployed\"\n        return true\n    end\n    return false\nend\n\nlocal function SCO_ScathisRotationThread(unit, weapon, generation)\n    WaitSeconds(0.5)\n    if unit.dead or weapon.scoScathisDisposed\n        or weapon.scoScathisRotationGeneration ~= generation\n    then return end\n    Engine.SetRotatorSpeed(\n        weapon.scoScathisFakeTurretId,\n        EngineClasses.float3(0, 120, 0))\n    Engine.SetRotatorEnabled(weapon.scoScathisFakeTurretId, true)\n    WaitSeconds(0.5)\n    if unit.dead or weapon.scoScathisDisposed\n        or weapon.scoScathisRotationGeneration ~= generation\n    then return end\n    Engine.SetRotatorEnabled(weapon.scoScathisFakeTurretId, false)\n    weapon.scoScathisFakeRotationDegrees =\n        ((weapon.scoScathisFakeRotationDegrees or 0) + 60) % 360\nend\n\nfunction HostWeapon:__init(aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)\n    SCO_ScathisStockInit(self, aimControllerIds, muzzleGroups, unit, tp, projectileTemplate)\n    if not SCO_IsScathisWeapon(self) then return end\n    if #muzzleGroups ~= 7 or #muzzleGroups[1] ~= 1 then\n        error(\"Scathis requires one central and six indexed fake muzzle groups\")\n    end\n    if #aimControllerIds ~= 1 then\n        error(\"Scathis requires exactly one aim controller\")\n    end\n    -- Native velocity reduction uses the aim controller max range as its\n    -- distance denominator. FA uses 2350; weapon targeting still reaches 4000.\n    local rangeResult = Engine.SetAimControllerMaxRange(aimControllerIds[1], 2350)\n    if rangeResult ~= EngineErrorCode.Success then\n        error(\"Scathis cannot set FA muzzle velocity reduction distance\")\n    end\n    self.scoScathisFakeMuzzles = {}\n    for index = 2, 7 do\n        if #muzzleGroups[index] ~= 1 then\n            error(\"Scathis fake muzzle group \" .. tostring(index - 1) .. \" is invalid\")\n        end\n        table.insert(self.scoScathisFakeMuzzles, muzzleGroups[index][1])\n    end\n    -- All seven host/client muzzle IDs remain registered. Only the central\n    -- source muzzle may instantiate the real projectile.\n    self.muzzleGroups = { muzzleGroups[1] }\n    self.scoScathisBarrelIndex = 1\n    self.scoScathisDeployState = \"packed\"\n    self.scoScathisEnergyDebt = 0\n    self.scoScathisRotationGeneration = 0\n    self.scoScathisPitchBoneIds = {}\n    local pitchBoneNames = {\n        \"Turret_Barrel_F_B01\", \"Turret_Barrel_E_B01\",\n        \"Turret_Barrel_D_B01\", \"Turret_Barrel_C_B01\",\n        \"Turret_Barrel_B_B01\", \"Turret_Barrel_A_B01\",\n    }\n    for index, boneName in ipairs(pitchBoneNames) do\n        local pitchResult, pitchBoneId = Engine.GetGlobalBone(unit.id, boneName)\n        if pitchResult ~= EngineErrorCode.Success then\n            error(\"Scathis fake pitch bone \" .. tostring(index) .. \" is absent\")\n        end\n        self.scoScathisPitchBoneIds[index] = pitchBoneId\n    end\n    local aimResult, aimBoneId = Engine.GetGlobalBone(unit.id, \"Turret_Aim\")\n    local aimBarrelResult, aimBarrelBoneId =\n        Engine.GetGlobalBone(unit.id, \"Turret_Aim_Barrel\")\n    if aimResult ~= EngineErrorCode.Success\n        or aimBarrelResult ~= EngineErrorCode.Success\n    then error(\"Scathis central aim bones are absent\") end\n    self.scoScathisAimBoneId = aimBoneId\n    self.scoScathisAimBarrelBoneId = aimBarrelBoneId\n    self.scoScathisPitchCurrent = 0\n    self.scoScathisPitchGoal = 0\n    local result, fakeTurretId = Engine.GetGlobalBone(unit.id, \"Turret_Fake\")\n    if result ~= EngineErrorCode.Success then error(\"Scathis Turret_Fake bone is absent\") end\n    self.scoScathisFakeTurretId = fakeTurretId\n    self.scoScathisFakeTurretBaseRotation = EngineClasses.quaternion()\n    Engine.GetGlobalEntityLocalRotation(fakeTurretId, self.scoScathisFakeTurretBaseRotation)\n    SCO_ResetScathisFakeTurret(self)\nend\n\nfunction HostWeapon:Delete()\n    if SCO_IsScathisWeapon(self) then\n        self.scoScathisDisposed = true\n        self.scoScathisRotationGeneration =\n            (self.scoScathisRotationGeneration or 0) + 1\n        SCO_ResetScathisFakeTurret(self)\n        SCO_ResetScathisPitch(self)\n    end\n    return SCO_ScathisStockDelete(self)\nend\n\nfunction HostWeapon:CanShootAt(targetUnit)\n    if not SCO_IsScathisWeapon(self) then\n        return SCO_ScathisStockCanShootAt(self, targetUnit)\n    end\n    if not SCO_ScathisStockCanShootAt(self, targetUnit) then return false end\n    if not self.tp.scoFaAboveWaterTargetsOnly then return true end\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return true end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    local position = targetUnit and targetUnit:GetPosition()\n    return levelResult == EngineErrorCode.Success and waterLevel ~= nil\n        and position ~= nil and position.y >= waterLevel - 0.05\nend\n\nfunction HostWeapon:SetAimTarget(targetUnit)\n    local previous = self.targetUnit\n    local result = SCO_ScathisStockSetAimTarget(self, targetUnit)\n    if not SCO_IsScathisWeapon(self) then return result end\n    local now = GetGameTimeSeconds()\n    if targetUnit then\n        self.scoScathisTargetLostTime = nil\n        if previous ~= targetUnit and self.scoScathisDeployState == \"deployed\" then\n            SCO_BeginScathisPitchAlignment(self, now)\n        end\n    elseif previous ~= nil then\n        self.scoScathisTargetLostTime = now\n    end\n    return result\nend\n\nfunction HostWeapon:SCO_UpdateScathisDeployment(now)\n    local state = self.scoScathisDeployState\n    local hasTarget = self:HasTarget()\n    if state == \"packed\" then\n        if not hasTarget then return end\n        SCO_ResetScathisFakeTurret(self)\n        SCO_SetScathisMovementLocked(self, true)\n        self.scoScathisDeployProgress = 0\n        self.scoScathisDeployLastTime = now\n        self.scoScathisDeployState = \"opening\"\n        SCO_SampleScathisDeployment(self, 0)\n        return\n    end\n\n    if state == \"closing\" and hasTarget then\n        -- Reacquisition reverses from the current pose while motion stays locked.\n        self.scoScathisDeployState = \"opening\"\n        self.scoScathisDeployLastTime = now\n        state = \"opening\"\n    end\n\n    if state == \"opening\" or state == \"repack_wait\" then\n        local progress = SCO_AdvanceScathisDeployment(self, now, 1)\n        if state == \"opening\" then\n            if not hasTarget then\n                self.scoScathisTargetLostTime =\n                    self.scoScathisTargetLostTime or now\n                self.scoScathisDeployState = \"repack_wait\"\n                state = \"repack_wait\"\n            elseif progress >= SCO_ScathisOpenSeconds then\n                SCO_BeginScathisPitchAlignment(self, now)\n                state = \"aligning\"\n            else\n                return\n            end\n        end\n    end\n\n    if state == \"deployed\" and hasTarget\n        and math.abs(SCO_ReadScathisPitchGoal(self)\n            - (self.scoScathisPitchCurrent or 0))\n            > SCO_ScathisPitchGoalTolerance\n    then\n        SCO_BeginScathisPitchAlignment(self, now)\n        state = \"aligning\"\n    end\n\n    if state == \"aligning\" then\n        if not hasTarget then\n            self.scoScathisTargetLostTime =\n                self.scoScathisTargetLostTime or now\n            self.scoScathisDeployState = \"repack_wait\"\n            state = \"repack_wait\"\n        else\n            if not SCO_UpdateScathisPitchAlignment(self, now) then return end\n            state = \"deployed\"\n        end\n    end\n\n    if state == \"deployed\" and not hasTarget then\n        self.scoScathisTargetLostTime =\n            self.scoScathisTargetLostTime or now\n        self.scoScathisDeployState = \"repack_wait\"\n        state = \"repack_wait\"\n    end\n\n    if state == \"repack_wait\" then\n        if hasTarget then\n            self.scoScathisTargetLostTime = nil\n            if self.scoScathisDeployProgress >= SCO_ScathisOpenSeconds then\n                SCO_BeginScathisPitchAlignment(self, now)\n            else\n                self.scoScathisDeployState = \"opening\"\n            end\n        elseif now >= self.scoScathisTargetLostTime + 4 then\n            self.scoScathisRotationGeneration =\n                (self.scoScathisRotationGeneration or 0) + 1\n            SCO_ResetScathisFakeTurret(self)\n            SCO_ResetScathisPitch(self)\n            self.scoScathisDeployState = \"closing\"\n            self.scoScathisDeployLastTime = now\n        end\n        return\n    end\n\n    if state == \"closing\" then\n        if SCO_AdvanceScathisDeployment(self, now, -1) <= 0 then\n            self.scoScathisDeployState = \"packed\"\n            self.scoScathisDeployLastTime = nil\n            self.scoScathisTargetLostTime = nil\n            SCO_PlayScathisAnimation(self, \"walk\")\n            SCO_SetScathisMovementLocked(self, false)\n        end\n    end\nend\n\nfunction HostWeapon:SCO_DrainScathisEnergy()\n    local debt = self.scoScathisEnergyDebt or 0\n    if debt <= 0 then return false end\n    local economy = self.unit:GetEconomy()\n    local request = math.min(\n        debt,\n        self.tp.scoFaEnergyDrainPerSecond * Constants.TickTimeStep)\n    local taken = economy and economy:TakeResources(\"energy\", request) or 0\n    self.scoScathisEnergyDebt = math.max(0, debt - taken)\n    return self.scoScathisEnergyDebt > 0\nend\n\nfunction HostWeapon:Update()\n    if not SCO_IsScathisWeapon(self) then return SCO_ScathisStockUpdate(self) end\n    self:SCO_UpdateScathisDeployment(GetGameTimeSeconds())\n    local draining = self:SCO_DrainScathisEnergy()\n    if self.scoScathisDeployState ~= \"deployed\" or draining then\n        if self.currentState == WeaponState.WaitingForReload then\n            self.reloadTimer = self.reloadTimer - Constants.TickTimeStep\n            if self.reloadTimer <= 0 then\n                self.currentState = WeaponState.WaitingForTarget\n            end\n        end\n        if self.UpdateTargeting then\n            self:UpdateTargeting()\n        else\n            self:RecalculateTargets()\n        end\n        return\n    end\n    return SCO_ScathisStockUpdate(self)\nend\n\nfunction HostWeapon:UpdateProjectile(isOnTarget)\n    if not SCO_IsScathisWeapon(self) then\n        return SCO_ScathisStockUpdateProjectile(self, isOnTarget)\n    end\n    local fired = false\n    if self.currentState == WeaponState.ShootSalvo then\n        local central = self.muzzleGroups[1] and self.muzzleGroups[1][1]\n        fired = central ~= nil\n            and self.projectileTemplate.general.prefabID ~= nil\n            and self:GetDesiredProjectileValues(central.aimControllerId) ~= nil\n    end\n    local result = SCO_ScathisStockUpdateProjectile(self, isOnTarget)\n    if fired then\n        local fake = self.scoScathisFakeMuzzles[self.scoScathisBarrelIndex]\n        SCO_ScathisCommands.FireMuzzle.Send(fake.id)\n        self.scoScathisBarrelIndex = self.scoScathisBarrelIndex % 6 + 1\n        self.scoScathisEnergyDebt = self.tp.scoFaEnergyRequired\n        self.scoScathisRotationGeneration =\n            (self.scoScathisRotationGeneration or 0) + 1\n        self.unit:NewThread(\n            SCO_ScathisRotationThread,\n            self,\n            self.scoScathisRotationGeneration)\n    end\n    return result\nend", ValidateHostWeapon);
			QueueTransform(obj, list, "LJ/lua/client/units/weaponsClasses/clientMuzzleClass.lua", "Scathis client recoil runtime", "\n\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0\nlocal SCO_ScathisStockFireMuzzle = ClientMuzzle.FireMuzzle\nlocal SCO_ScathisStockCleanupMuzzle = ClientMuzzle.Cleanup\n\nlocal function SCO_IsScathisClientMuzzle(self)\n    return self.weapon and self.weapon.unit\n        and self.weapon.unit.tpId == \"ugl4011\"\n        and self.weapon.tp and self.weapon.tp.scoFaScathis == true\nend\n\nlocal function SCO_ScathisRecoilReturn(self, generation, boneId, basePosition)\n    WaitTicks(1)\n    local duration = 2 / 1.325\n    local elapsed = 0\n    while elapsed < duration do\n        if self.deleted or self.scoScathisRecoilGeneration ~= generation then return end\n        elapsed = math.min(duration, elapsed + Constants.TickTimeStep)\n        local ratio = elapsed / duration\n        Engine.SetLocalEntityLocalPosition(\n            boneId,\n            EngineClasses.float3(\n                basePosition.x,\n                basePosition.y,\n                basePosition.z - 2 * (1 - ratio)))\n        if elapsed < duration then WaitTicks(1) end\n    end\nend\n\nlocal function SCO_StartScathisRecoil(self, boneName)\n    local boneId = self.weapon.unit:GetBoneId(boneName)\n    if not boneId then error(\"Scathis recoil bone is absent: \" .. tostring(boneName)) end\n    local result, current = Engine.GetLocalEntityLocalPosition(boneId)\n    if result ~= EngineErrorCode.Success or current == nil then\n        error(\"Scathis could not read recoil bone \" .. tostring(boneName))\n    end\n    local base = EngineClasses.float3(current.x, current.y, current.z)\n    self.scoScathisRecoilGeneration = (self.scoScathisRecoilGeneration or 0) + 1\n    self.scoScathisRecoilBoneId = boneId\n    self.scoScathisRecoilBase = base\n    Engine.SetLocalEntityLocalPosition(\n        boneId,\n        EngineClasses.float3(base.x, base.y, base.z - 2))\n    self:NewThread(\n        SCO_ScathisRecoilReturn,\n        self.scoScathisRecoilGeneration,\n        boneId,\n        base)\nend\n\nfunction ClientMuzzle:FireMuzzle()\n    if not SCO_IsScathisClientMuzzle(self) then\n        return SCO_ScathisStockFireMuzzle(self)\n    end\n    if self.boneName == \"Turret_Aim_Barrel_Muzzle\" then\n        local result = SCO_ScathisStockFireMuzzle(self)\n        SCO_StartScathisRecoil(self, \"Turret_Aim_Barrel\")\n        return result\n    end\n    local recoilBone = string.gsub(self.boneName, \"_B03$\", \"_B02\")\n    if recoilBone == self.boneName then\n        error(\"Unexpected Scathis visual muzzle \" .. tostring(self.boneName))\n    end\n    -- The host emits exactly one selected fake muzzle event per real shot.\n    -- Suppress duplicate stock muzzle/audio while preserving source recoil.\n    SCO_StartScathisRecoil(self, recoilBone)\nend\n\nfunction ClientMuzzle:Cleanup()\n    if SCO_IsScathisClientMuzzle(self) then\n        self.scoScathisRecoilGeneration =\n            (self.scoScathisRecoilGeneration or 0) + 1\n        if self.scoScathisRecoilBoneId and self.scoScathisRecoilBase then\n            Engine.SetLocalEntityLocalPosition(\n                self.scoScathisRecoilBoneId,\n                self.scoScathisRecoilBase)\n        end\n    end\n    return SCO_ScathisStockCleanupMuzzle(self)\nend", ValidateClientMuzzle);
			QueueAppend(obj, list, "LJ/lua/common/systems/import.lua", "Scathis projectile scanner", "\n\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0\nlocal SCO_ScathisScanDir = ScanDir\nfunction ScanDir(directory)\n    local folders = SCO_ScathisScanDir(directory)\n    if directory ~= \"common/projectiles/projectilesTemplates/\" then return folders end\n    local candidate = directory .. \"pgr401s\"\n    for _, folder in ipairs(folders) do\n        if folder == candidate then return folders end\n    end\n    table.insert(folders, candidate)\n    return folders\nend", ValidateImport);
			QueueProjectile(obj, list);
			if (list.Count == 0)
			{
				Log("URL0401->ugl4011 is already current.");
				return;
			}
			Commit(obj, list);
			Log("Applied atomic URL0401->ugl4011 Scathis transaction.");
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
			Log($"Failed to apply the Scathis transaction: {arg}");
			throw;
		}
	}

	private static void ValidatePinnedScope()
	{
		if ("c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26".Length != 64 || "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12".Length != 64 || "\n\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0\n-- Exact direct mapping: FA URL0401 Scathis replaces only ugl4011.\nUnitTemplate.additions = {\n    displayWreckOnDeath = true,\n    selectionHit = { size = { x = 4, y = 5 } },\n    rotators = {\n        {\n            boneName = \"Turret_Fake\",\n            speed = { x = 0, y = 120, z = 0 },\n        },\n    },\n    faSourceContract = {\n        mapping = \"URL0401 -> ugl4011\",\n        sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n        sourceBlueprint = \"units/URL0401/URL0401_unit.bp\",\n        sourceBlueprintSha256 = \"c0366fbe9bf45b4c5cb32c9b4618dd97d3756d46e6ff5e3d449d013e89669f74\",\n        sourceScript = \"units/URL0401/URL0401_Script.lua\",\n        sourceScriptSha256 = \"406c68acd2806fae507c68f23b57209a4d8982d512a9bcab3fc95887ba97794e\",\n        sourceOpenAnimation = \"units/URL0401/URL0401_Aopen.sca\",\n        sourceOpenAnimationSha256 = \"9fd6d8f08446ab7adbeed2923057f43878949cbdc27fc1d05c522e469fbbae6c\",\n        openFrames = 501,\n        openFps = 30,\n        openSeconds = 16.66666603088379,\n        repackTimeoutSeconds = 4,\n        sourceRackRecoilDistance = -20,\n        convertedRackRecoilDistance = -2,\n        sourceRackRecoilReturnSpeed = 13.25,\n        convertedRackRecoilReturnSpeed = 1.325,\n        fakeBarrelOrder = { \"F\", \"E\", \"D\", \"C\", \"B\", \"A\" },\n        sourceSelectionThickness = 0.36,\n        sourceSkirtOffset = { x = -1.5, z = -1 },\n        sourceMaxSpeedReverse = 0,\n        sourceRotateOnSpot = true,\n        sourceTurnRadius = 2,\n        sourceCollideFriendly = false,\n        sourceProjectileDestroyOnWater = true,\n        sanctuarySelectionThicknessUsesCollisionHeight = true,\n        sanctuarySkirtOffsetRuntime = false,\n        sanctuaryReverseSpeedRuntime = false,\n        sanctuaryProjectileCollisionFilterRuntime = false,\n    },\n}\nUnitTemplate.audio = UnitTemplate.audio or {}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 1, z = 0 },\n    collisionSize = { x = 6, y = 2, z = 7 },\n    targetBones = { \"Root\", \"Turret_Aim\" },\n}\nUnitTemplate.defence = { health = { max = 17500, regen = 0, value = 17500 } }\nUnitTemplate.economy = {\n    buildTime = 99900,\n    cost = { alloys = 299700, energy = 5994000 },\n}\nUnitTemplate.footprint = { x = 5, y = 5 }\nUnitTemplate.skirtSize = { x = 8, y = 8 }\nUnitTemplate.general.class = { \"unitsDefaultGuard\", \"GuardScathis\" }\nUnitTemplate.general.displayName = \"Experimental Mobile Rapid-Fire Artillery\"\nUnitTemplate.general.icon = { shape = \"experimental1\", symbol = \"indirect\", tech = \"t1\" }\nUnitTemplate.general.iconUI = \"tech3_land1_indirect.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 10\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.name = \"Scathis\"\nUnitTemplate.general.orders = {\n    Assist = true, Attack = true, AttackMove = true, Move = true,\n    Patrol = true, Stop = true,\n}\nUnitTemplate.general.tpId = \"ugl4011\"\nUnitTemplate.intel = { visionRadius = 26 }\nUnitTemplate.movement = {\n    acceleration = 1,\n    altitudeJitterFactor = 0,\n    bankFactor = 0,\n    deceleration = 1,\n    collisionMaskDefault = { \"LandLarge\" },\n    collisionMaskSpawn = { \"LandLarge\" },\n    maxReverseDistance = 0,\n    minSpeed = 0,\n    orbitRange = 0,\n    orbitSpeed = 0,\n    preferredAltitude = 0,\n    referenceAltitude = \"Ground\",\n    rotateOnSpot = true,\n    rotationSpeed = 40,\n    sortOrder = 3,\n    speed = 1,\n    terrainAlignmentFactor = 1,\n    turnRadius = 2,\n    type = \"TracksLand\",\n}\nUnitTemplate.tags = {\n    \"ARTILLERY\", \"BUILDABLE_BY_T3_ENGINEER\", \"GUARD\", \"INDIRECT_FIRE\",\n    \"LAND\", \"MOBILE\", \"TANK\", \"TECH4\",\n}\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.animations = {\n    walk = {\n        clipName = \"Rest\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl4011/LOD0/ugl4011.sananimation\",\n    },\n    open = {\n        clipName = \"AnimOpen\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl4011/LOD0/ugl4011.sananimation\",\n    },\n    close = {\n        clipName = \"AnimClose\",\n        playbackMode = 0,\n        sanAnimationPath = \"Units/ugl4011/LOD0/ugl4011.sananimation\",\n    },\n}\nUnitTemplate.visuals.mesh = { lod0distance = 175, lod1distance = 550 }\nUnitTemplate.visuals.selection = { size = { x = 4, y = 5 } }\nUnitTemplate.weapons = {\n    {\n        aimControllers = {\n            {\n                aimBone = \"Turret_Aim_Barrel_Muzzle\",\n                aimTolerance = 0,\n                defaultPitchAdjustment = 0,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = \"Turret_Aim_Barrel\",\n                pitchMax = 45,\n                pitchMin = -45,\n                pitchSpeed = 30,\n                poseResetTime = 4,\n                projectileSpeed = 160,\n                reduceMuzzleVelocityToTarget = true,\n                solverType = \"HighArc\",\n                yawBone = \"Turret_Aim\",\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 90,\n            },\n        },\n        damage = 3000,\n        damageFriendly = true,\n        damageRadius = 7,\n        damageType = \"Normal\",\n        effects = { onFire = \"VFX/Muzzle/vgm8321_plasma_stream_large_muzzle.sanvfx\" },\n        firingRandomness = 0.3,\n        layerTargetLimits = { \"Land\", \"WaterSurface\" },\n        layerWeaponLimits = { \"Land\" },\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = 4,\n        muzzleGroups = {\n            { muzzles = { \"Turret_Aim_Barrel_Muzzle\" } },\n            { muzzles = { \"Turret_Barrel_F_B03\" } },\n            { muzzles = { \"Turret_Barrel_E_B03\" } },\n            { muzzles = { \"Turret_Barrel_D_B03\" } },\n            { muzzles = { \"Turret_Barrel_C_B03\" } },\n            { muzzles = { \"Turret_Barrel_B_B03\" } },\n            { muzzles = { \"Turret_Barrel_A_B03\" } },\n        },\n        muzzles = {\n            Turret_Aim_Barrel_Muzzle = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_F_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_E_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_D_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_C_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_B_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n            Turret_Barrel_A_B03 = { aimController = \"Turret_Aim_Barrel_Muzzle\" },\n        },\n        muzzleSalvoDelay = 0,\n        muzzleSalvoSize = 1,\n        projectileLifetime = 100,\n        projectileTemplate = \"pgr401s\",\n        rangeMax = 4000,\n        rangeMin = 100,\n        rangeRingType = \"IndirectFire\",\n        reloadProgressBar = true,\n        reloadTime = 1.8867924528301887,\n        scoFaAboveWaterTargetsOnly = true,\n        scoFaArtilleryShieldBlocks = true,\n        scoFaEnergyChargeForFirstShot = false,\n        scoFaEnergyDrainPerSecond = 2000,\n        scoFaEnergyRequired = 2000,\n        scoFaScathis = true,\n        scoFaWeaponUnpackLocksMotion = true,\n        scoFaWeaponUnpackSeconds = 16.66666603088379,\n        scoFaWeaponRepackSeconds = 16.66666603088379,\n        scoFaWeaponRepackTimeout = 4,\n        targetWaterLimits = \"Above\",\n    },\n}".IndexOf("URL0401 -> ugl4011", StringComparison.Ordinal) < 0 || "---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = { onImpact = { looping = false, name = \"agoi1130\" } },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = { name = \"Cybran_Scathis_Artillery_Proton\", tpId = \"pgr401s\" },\n    nonUniformScale = { x = 0.45, y = 0.45, z = 0.45 },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = {\n            { effects = { { particleName = \"VFX/Impact/vgi8321_plasma_stream_large_impact.sanvfx\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"VFX/Trails/vgt8321_plasma_stream_large_trail.sanvfx\" } } },\n        },\n    },\n}\n\n-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\n-- Source ID: CIFArtilleryProton01\n-- Source blueprint: projectiles/CIFArtilleryProton01/CIFArtilleryProton01_proj.bp\n-- Source blueprint SHA-256: e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e\n-- Source script: projectiles/CIFArtilleryProton01/CIFArtilleryProton01_script.lua\n-- Source script SHA-256: 98a19bd78f1a61dc4c2f3f9e2c63a6cb27aadb6cbb352dbe6cf430d3483ee0ef\n-- Limitation: FA Force/Fire emitter graphs, camera shake/follow, decal and\n-- explicit DestroyOnWater are not native Sanctuary projectile-template inputs.\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0".IndexOf("tpId = \"pgr401s\"", StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("The reviewed Scathis mapping scope changed.");
		}
	}

	private static void ValidateTransactionState(object cache)
	{
		int num = 0;
		(string, string)[] existingResources = ExistingResources;
		for (int i = 0; i < existingResources.Length; i++)
		{
			(string, string) tuple = existingResources[i];
			if (GetResourceText(GetCachedResource(cache, tuple.Item1, tuple.Item2).Stock).IndexOf("-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", StringComparison.Ordinal) >= 0)
			{
				num++;
			}
		}
		CacheResource cacheResource = TryGetCachedResource(cache, "LJ/lua/common/projectiles/projectilesTemplates/pgr401s/pgr401s.santp", "Scathis isolated projectile");
		if (cacheResource != null)
		{
			if (GetResourceText(cacheResource.Stock).IndexOf("-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Reserved projectile pgr401s already exists without the Scathis marker.");
			}
			num++;
		}
		if (num != 0 && num != 7)
		{
			throw new InvalidOperationException($"A partial Scathis transaction was found ({num}/7 owned resources).");
		}
	}

	private static void ValidateStock(string path, string source)
	{
		if (path == "LJ/lua/common/units/unitsTemplates/ugl4011/ugl4011.santp")
		{
			CacheCompatibilityRepair.RequireUnit(source, "ugl4011", "|unitsDefaultGuard:GuardLandUnit|unitsDefaultGuard:GuardScathis|", "GUARD");
			return;
		}
		switch (path)
		{
		case "LJ/lua/common/units/unitsTemplates/ugl4011/ugl4011.santp":
			RequireTokens(source, "UnitTemplate =", "tpId = \"ugl4011\"", "\"unitsDefaultGuard\"", "\"GuardLandUnit\"");
			RequireExactly(source, "tpId = \"ugl4011\"", 1, "stock ugl4011 tpId");
			break;
		case "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua":
			RequireTokens(source, "HostGuardLandUnit = Class(\"GuardLandUnit\", LandUnit)");
			break;
		case "LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua":
			RequireTokens(source, "ClientGuardLandUnit = Class(\"GuardLandUnit\", LandUnit)");
			break;
		case "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua":
			RequireTokens(source, "function HostWeapon:__init", "function HostWeapon:UpdateProjectile", "function HostWeapon:SetAimTarget");
			break;
		case "LJ/lua/client/units/weaponsClasses/clientMuzzleClass.lua":
			RequireTokens(source, "function ClientMuzzle:FireMuzzle()", "function ClientMuzzle:Cleanup()", "return {");
			break;
		case "LJ/lua/common/systems/import.lua":
			RequireTokens(source, "function ScanDir", "Engine.GetFoldersInsideDirectory");
			break;
		}
	}

	private static void ValidateUnit(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", 1, "Scathis template marker");
		string source2 = Owned(source);
		RequireTokens(source2, "mapping = \"URL0401 -> ugl4011\"", "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", "c0366fbe9bf45b4c5cb32c9b4618dd97d3756d46e6ff5e3d449d013e89669f74", "406c68acd2806fae507c68f23b57209a4d8982d512a9bcab3fc95887ba97794e", "openFrames = 501", "openSeconds = 16.66666603088379", "max = 17500, regen = 0, value = 17500", "alloys = 299700, energy = 5994000", "buildTime = 99900", "collisionSize = { x = 6, y = 2, z = 7 }", "selectionHit = { size = { x = 4, y = 5 } }", "type = \"TracksLand\"", "speed = 1", "acceleration = 1", "deceleration = 1", "rotationSpeed = 40", "damage = 3000", "damageRadius = 7", "damageFriendly = true", "projectileSpeed = 160", "rangeMax = 4000", "rangeMin = 100", "reloadTime = 1.8867924528301887", "projectileTemplate = \"pgr401s\"", "scoFaEnergyRequired = 2000", "scoFaEnergyDrainPerSecond = 2000");
		RequireExactly(source2, "{ muzzles = { \"Turret_Barrel_", 6, "indexed fake muzzle groups");
		RequireExactly(source2, "category = \"DeathExplosion\"", 0, "invented Scathis death weapon");
		RequireNotContains(source2, "AMPHIBIOUS", "SEABED", "pad002", "AeonProjectiles");
	}

	private static void ValidateHostGuard(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", 1, "Scathis host class marker");
		RequireTokens(Owned(source), "HostGuardScathis = Class(\"GuardScathis\"", "return false", "function GuardScathis:UpdateAnimations()", "Engine.PlayAnimation(self.id, rest.id, 0.1)");
	}

	private static void ValidateClientGuard(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", 1, "Scathis client class marker");
		RequireTokens(Owned(source), "ClientGuardScathis = Class(\"GuardScathis\"");
	}

	private static void ValidateHostWeapon(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", 1, "Scathis host weapon marker");
		RequireTokens(Owned(source), "local SCO_ScathisStockUpdate = HostWeapon.Update", "if not SCO_IsScathisWeapon(self) then return SCO_ScathisStockUpdate(self) end", "self.muzzleGroups = { muzzleGroups[1] }", "for index = 2, 7 do", "self.scoScathisBarrelIndex = self.scoScathisBarrelIndex % 6 + 1", "SCO_ScathisCommands.FireMuzzle.Send(fake.id)", "local SCO_ScathisCommands = Import(\"common/commands/definitions/projectiles.lua\")", "WaitSeconds(0.5)", "Engine.SetRotatorEnabled(weapon.scoScathisFakeTurretId, true)", "local function SCO_BeginScathisPitchAlignment(self, now)", "self.scoScathisPitchRestAngle", "Engine.GetGlobalEntityForwardDirection(", "local step = 30 * elapsed", "self.scoScathisPitchDelayDeadline = arrivalTime + 0.2", "Engine.QuaternionMultiply(self.scoScathisPitchBases[index], delta)", "SCO_ScathisOpenSeconds", "self.scoScathisTargetLostTime + 4", "Engine.SetMovementEnabled(self.unit.id, not locked)", "economy:TakeResources(\"energy\", request)", "position.y >= waterLevel - 0.05");
	}

	private static void ValidateClientMuzzle(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", 1, "Scathis client muzzle marker");
		RequireTokens(Owned(source), "local SCO_ScathisStockFireMuzzle = ClientMuzzle.FireMuzzle", "if not SCO_IsScathisClientMuzzle(self) then", "return SCO_ScathisStockFireMuzzle(self)", "string.gsub(self.boneName, \"_B03$\", \"_B02\")", "basePosition.z - 2 * (1 - ratio)", "local duration = 2 / 1.325", "Engine.SetLocalEntityLocalPosition", "function ClientMuzzle:Cleanup()");
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", StringComparison.Ordinal);
		if (source.LastIndexOf("\nreturn {", StringComparison.Ordinal) < num)
		{
			throw new InvalidOperationException("Scathis client muzzle appendix was not inserted before the module return.");
		}
	}

	private static void ValidateImport(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", 1, "Scathis scanner marker");
		RequireTokens(Owned(source), "local SCO_ScathisScanDir = ScanDir", "directory .. \"pgr401s\"", "table.insert(folders, candidate)");
	}

	private static void ValidateProjectile(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", 1, "Scathis projectile marker");
		RequireTokens(source, "tpId = \"pgr401s\"", "CIFArtilleryProton01", "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12", "e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e", "98a19bd78f1a61dc4c2f3f9e2c63a6cb27aadb6cbb352dbe6cf430d3483ee0ef", "x = 0.45, y = 0.45, z = 0.45", "vgt8321_plasma_stream_large_trail.sanvfx");
		RequireNotContains(source, "pad002", "AeonProjectiles", "pcl001");
	}

	private static void QueueAppend(object cache, ICollection<CacheMutation> mutations, string path, string description, string appendix, Action<string> validate)
	{
		QueueExisting(cache, mutations, path, description, (string source) => Append(source, appendix), validate);
	}

	private static void QueueTransform(object cache, ICollection<CacheMutation> mutations, string path, string description, string appendix, Action<string> validate)
	{
		QueueExisting(cache, mutations, path, description, (string source) => InsertBeforeReturn(source, appendix), validate);
	}

	private static void QueueExisting(object cache, ICollection<CacheMutation> mutations, string path, string description, Func<string, string> transform, Action<string> validate)
	{
		CacheResource cachedResource = GetCachedResource(cache, path, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		if (resourceText.IndexOf("-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", StringComparison.Ordinal) >= 0)
		{
			validate(resourceText);
			return;
		}
		ValidateStock(path, resourceText);
		object obj = CreateNativeArray(cachedResource.Stock.GetType(), transform(resourceText));
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

	private static void QueueProjectile(object cache, ICollection<CacheMutation> mutations)
	{
		CacheResource cacheResource = TryGetCachedResource(cache, "LJ/lua/common/projectiles/projectilesTemplates/pgr401s/pgr401s.santp", "Scathis isolated projectile");
		if (cacheResource != null)
		{
			string resourceText = GetResourceText(cacheResource.Stock);
			if (resourceText.IndexOf("-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("Reserved projectile pgr401s already exists without the Scathis marker.");
			}
			ValidateProjectile(resourceText);
			return;
		}
		ValidateProjectile("---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = { onImpact = { looping = false, name = \"agoi1130\" } },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = { name = \"Cybran_Scathis_Artillery_Proton\", tpId = \"pgr401s\" },\n    nonUniformScale = { x = 0.45, y = 0.45, z = 0.45 },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = {\n            { effects = { { particleName = \"VFX/Impact/vgi8321_plasma_stream_large_impact.sanvfx\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"VFX/Trails/vgt8321_plasma_stream_large_trail.sanvfx\" } } },\n        },\n    },\n}\n\n-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\n-- Source ID: CIFArtilleryProton01\n-- Source blueprint: projectiles/CIFArtilleryProton01/CIFArtilleryProton01_proj.bp\n-- Source blueprint SHA-256: e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e\n-- Source script: projectiles/CIFArtilleryProton01/CIFArtilleryProton01_script.lua\n-- Source script SHA-256: 98a19bd78f1a61dc4c2f3f9e2c63a6cb27aadb6cbb352dbe6cf430d3483ee0ef\n-- Limitation: FA Force/Fire emitter graphs, camera shake/follow, decal and\n-- explicit DestroyOnWater are not native Sanctuary projectile-template inputs.\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0");
		object obj = CreateNativeArray(GetNativeArrayType(cache), "---@type ProjectileTemplate\nProjectileTemplate = {\n    audio = { onImpact = { looping = false, name = \"agoi1130\" } },\n    collisionInfo = {\n        centerOffset = { x = 0, y = 0.5, z = 0 },\n        collisionSize = { x = 1, y = 1, z = 1 },\n    },\n    general = { name = \"Cybran_Scathis_Artillery_Proton\", tpId = \"pgr401s\" },\n    nonUniformScale = { x = 0.45, y = 0.45, z = 0.45 },\n    visuals = {\n        mesh = { lod0distance = 60 },\n        onImpactEffects = {\n            { effects = { { particleName = \"VFX/Impact/vgi8321_plasma_stream_large_impact.sanvfx\" } } },\n        },\n        persistantEffects = {\n            { effects = { { particleName = \"VFX/Trails/vgt8321_plasma_stream_large_trail.sanvfx\" } } },\n        },\n    },\n}\n\n-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12\n-- Source ID: CIFArtilleryProton01\n-- Source blueprint: projectiles/CIFArtilleryProton01/CIFArtilleryProton01_proj.bp\n-- Source blueprint SHA-256: e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e\n-- Source script: projectiles/CIFArtilleryProton01/CIFArtilleryProton01_script.lua\n-- Source script SHA-256: 98a19bd78f1a61dc4c2f3f9e2c63a6cb27aadb6cbb352dbe6cf430d3483ee0ef\n-- Limitation: FA Force/Fire emitter graphs, camera shake/follow, decal and\n-- explicit DestroyOnWater are not native Sanctuary projectile-template inputs.\n-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0");
		try
		{
			ValidateProjectile(GetResourceText(obj));
			mutations.Add(new CacheMutation(ResolvePath("LJ/lua/common/projectiles/projectilesTemplates/pgr401s/pgr401s.santp"), null, obj, added: true, "Scathis isolated projectile"));
		}
		catch
		{
			TryDispose(obj, "uncommitted Scathis projectile");
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

	private static CacheResource GetCachedResource(object cache, string path, string description)
	{
		return TryGetCachedResource(cache, path, description) ?? throw new FileNotFoundException("Required " + description + " was not present in Sanctuary's Lua cache.", path);
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

	private static string Append(string source, string appendix)
	{
		return Normalize(source).TrimEnd(new char[1] { '\n' }) + "\n" + Normalize(appendix).TrimStart(new char[1] { '\n' }) + "\n";
	}

	private static string InsertBeforeReturn(string source, string appendix)
	{
		source = Normalize(source);
		int num = source.LastIndexOf("\nreturn {", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Client muzzle module return anchor changed.");
		}
		return source.Insert(num, "\n" + Normalize(appendix).Trim(new char[1] { '\n' }) + "\n");
	}

	private static string Normalize(string source)
	{
		return source.Replace("\r\n", "\n").Replace('\r', '\n');
	}

	private static string Owned(string source)
	{
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Scathis marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0".Length, StringComparison.Ordinal);
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
				throw new InvalidOperationException("Scathis-owned Lua must not contain '" + text + "'.");
			}
		}
	}

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int count = Regex.Matches(source, Regex.Escape(token), RegexOptions.CultureInvariant).Count;
		if (count != expected)
		{
			throw new InvalidOperationException($"Expected {expected} {description}, found {count}.");
		}
	}

	private static void Log(string message)
	{
		string text = "[FA Cybran Scathis Cache Patcher] " + message;
		Console.WriteLine(text);
		try
		{
			(from assembly in AppDomain.CurrentDomain.GetAssemblies()
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type candidate) => (object)candidate != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}
}
