using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace CybranMantisCachePatcher;

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

		public object Stock { get; }

		public object Replacement { get; }

		public string Description { get; }

		public bool Assigned { get; set; }

		public CacheMutation(string path, object stock, object replacement, string description)
		{
			Path = path;
			Stock = stock;
			Replacement = replacement;
			Description = description;
		}
	}

	private const string TemplateRelativePath = "LJ/lua/common/units/unitsTemplates/ugl1002/ugl1002.santp";

	private const string GuardHostRelativePath = "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua";

	private const string OverrideMarker = "-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.1.0";

	private const string LegacyMarker = "-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.0.0";

	private const string TemplateOverride = "-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.1.0\n-- FA URL0107 Mantis -> Guard ugl1002. The canonical asset replaces only\n-- ugl1002.sananimation: Rest and AnimWalk01 remain byte-identical, while\n-- both retail one-second death clips are appended as terminal clamp states.\nUnitTemplate.general = UnitTemplate.general or {}\nUnitTemplate.general.displayName = \"Mantis\"\nUnitTemplate.general.name = \"Mantis\"\nUnitTemplate.general.orders = UnitTemplate.general.orders or {}\nUnitTemplate.general.orders.Repair = true\n-- URL0107 has BuildRate=1 and can repair/assist, but it cannot place\n-- new structures. Sanctuary uses a construction table plus range to\n-- authorize repair behavior, while the omitted canBuild expression\n-- intentionally keeps a Mantis out of the construction build menu.\nUnitTemplate.construction = {\n    beam = {\n        boneName = \"Turret_Muzzle_01\",\n        offset = { x = 0, y = 0, z = 0 },\n        shrink = 1,\n    },\n    buildPower = 1,\n    range = 5,\n}\n\nUnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = {\n    max = 270,\n    regen = 0,\n    value = 270,\n}\nUnitTemplate.economy = UnitTemplate.economy or {}\nUnitTemplate.economy.buildTime = 260\nUnitTemplate.economy.cost = {\n    alloys = 52,\n    energy = 273,\n}\nUnitTemplate.intel = UnitTemplate.intel or {}\nUnitTemplate.intel.visionRadius = 20\n\n-- URL0107's source collision is 0.7 x 0.5 x 0.9 at a 0.15 vertical\n-- center offset. The imported 0.1475-scale model measures about\n-- 0.825 x 0.635 x 0.899, so retain source horizontal occupancy while\n-- giving the selection shell the model's complete visible envelope.\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.15, z = 0 },\n    collisionSize = { x = 0.7, y = 0.5, z = 0.9 },\n}\nUnitTemplate.footprint = { x = 0.7, y = 0.9 }\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 0.85, y = 0.9 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.32, z = 0 }\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.buildBeamBones = {\n    \"Turret_Muzzle_01\",\n    \"Turret_Muzzle_02\",\n}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.85, y = 0.9 },\n    offset = { x = 0, y = 0.32, z = 0 },\n}\nUnitTemplate.additions.faDeathAnimation = {\n    mapping = \"URL0107 -> ugl1002\",\n    sourceUnitsArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceLuaArchiveSha256 = \"3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb\",\n    sourceBlueprint = \"units/URL0107/URL0107_unit.bp\",\n    sourceBlueprintSha256 = \"303c473d3df0a0f0697dcaa7c102295ce3e615c89c3e69083fb84d13086d4b09\",\n    sourceScript = \"units/URL0107/URL0107_script.lua\",\n    sourceScriptSha256 = \"aeb8eb831f99832ed2b35a060beac1f836700b2b8cd28428c66f3bea8155c640\",\n    sourceUnitLuaSha256 = \"ced522e17b204aedfe196706fd3f3421af5f041cf692248ef56d43c97b52cd67\",\n    sourceCybranUnitsLuaSha256 = \"f126ce26875ef8b51f240296af8bd0d86ff07e3fc4b2a5ebf0a5ba4478687411\",\n    class = { owner = \"unitsDefaultGuard\", name = \"GuardLandUnit\", source = \"CWalkingLandUnit\" },\n    sanAnimationSha256 = \"e0c883e2a7ecc249443a217c863fbbab5d4b3c3595d5a09fb9b6b045c1f03695\",\n    existingSanAnimationSha256 = \"09b4bf91da58156c74204723ce6cfe0c7fdccd820252a0a3b32e51a77f2c1825\",\n    clips = {\n        death01 = {\n            source = \"units/URL0107/URL0107_Adeath01.sca\",\n            sha256 = \"f99f5ce7448b4fd17434fe118a53ca857eb7d886dd0f6ccc63c1997d5eca2e13\",\n            frames = 31, duration = 1, weight = 1,\n        },\n        death02 = {\n            source = \"units/URL0107/URL0107_Adeath02.sca\",\n            sha256 = \"3470f69d514164aa7a24be626e9da3c9584ad1510673cadafb4bfe5a12e7a152\",\n            frames = 31, duration = 1, weight = 1,\n        },\n    },\n    sourceRate = { minimum = 0.75, maximum = 1.25 },\n    runtimeRate = 1,\n    selection = \"deterministic equal-weight unit-index parity\",\n    limitations = {\n        sourceDeathRateRandomization = \"0.75-1.25 unavailable; nominal rate used\",\n        hostPlayAnimationThirdArgument = \"cross-fade time, not playback speed\",\n    },\n}\n\nUnitTemplate.movement = UnitTemplate.movement or {}\nUnitTemplate.movement.type = \"LegsLand\"\nUnitTemplate.movement.acceleration = 3.6\nUnitTemplate.movement.deceleration = 3.6\nUnitTemplate.movement.rotationSpeed = 80\nUnitTemplate.movement.speed = 3.6\n-- Sanctuary advances movement-bound clips by velocity / authoredSpeed.\n-- URL0107 has MaxSpeed=3.6 and AnimationWalkRate=8, so 3.6 / 8 = 0.45\n-- reproduces the source 0.25-second gait at full speed.\nUnitTemplate.movement.walkAnimation = { authoredSpeed = 0.45 }\nUnitTemplate.visuals.animations = {\n    death01 = {\n        clipName = \"AnimDeath01\",\n        sanAnimationPath = \"Units/ugl1002/LOD0/ugl1002.sananimation\",\n        playbackMode = AnimationPlaybackMode.Clamp,\n    },\n    death02 = {\n        clipName = \"AnimDeath02\",\n        sanAnimationPath = \"Units/ugl1002/LOD0/ugl1002.sananimation\",\n        playbackMode = AnimationPlaybackMode.Clamp,\n    },\n    walk = {\n        authoredSpeed = 0.45,\n        clipName = \"AnimWalk01\",\n        sanAnimationPath = \"Units/ugl1002/LOD0/ugl1002.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\n\nif not UnitTemplate.weapons or not UnitTemplate.weapons[1] then\n    error(\"UGL1002 Mantis override requires the stock primary weapon\")\nend\nlocal primaryWeapon = UnitTemplate.weapons[1]\n\n-- URL0107's LaserArms weapon uses one controller: Torso yaw, then\n-- Turret_Barrel pitch, with the two arm tips alternating as racks.\nprimaryWeapon.aimControllers = {\n    {\n        aimBone = \"Turret_Muzzle_01\",\n        aimTolerance = 2,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = true,\n        pitchBone = \"Turret_Barrel\",\n        pitchMax = 45,\n        pitchMin = -45,\n        pitchSpeed = 100,\n        poseResetTime = 3,\n        projectileSpeed = 25,\n        solverType = \"LowArc\",\n        yawBone = \"Torso\",\n        yawMax = 180,\n        yawMin = -180,\n        yawSpeed = 80,\n    },\n}\nprimaryWeapon.muzzleGroups = {\n    { muzzles = { \"Turret_Muzzle_01\" } },\n    { muzzles = { \"Turret_Muzzle_02\" } },\n}\nprimaryWeapon.muzzles = {\n    [\"Turret_Muzzle_01\"] = { aimController = \"Turret_Muzzle_01\" },\n    [\"Turret_Muzzle_02\"] = { aimController = \"Turret_Muzzle_01\" },\n}\nprimaryWeapon.damage = 8\nprimaryWeapon.damageRadius = 0\nprimaryWeapon.damageType = \"Normal\"\nprimaryWeapon.effects = {\n    onFire = \"VFX/Muzzle/vgm1121_autocannon_plasma_small_muzzle.sanvfx\",\n}\nprimaryWeapon.firingRandomness = 0\nprimaryWeapon.layerTargetLimits = { \"Land\", \"WaterSurface\" }\nprimaryWeapon.layerWeaponLimits = { \"Land\" }\nprimaryWeapon.muzzleGroupChargeDelay = 0\nprimaryWeapon.muzzleGroupTimeOut = -1\nprimaryWeapon.muzzleSalvoSize = 1\nprimaryWeapon.projectileLifetime = 2.875\n-- CDFLaserHeavy01 is a low-arc direct projectile. pgd131 is the\n-- existing Guard direct-projectile compatibility visual; its use is\n-- explicit so it cannot be mistaken for a source-specific VFX port.\nprimaryWeapon.projectileTemplate = \"pgd131\"\nprimaryWeapon.rangeMax = 18\nprimaryWeapon.rangeMin = 0\nprimaryWeapon.rangeRingType = \"DirectFire\"\nprimaryWeapon.rangeTracking = 1.15\nprimaryWeapon.reloadTime = 0.3333333333333333\nprimaryWeapon.targetWaterLimits = \"Above\"";

	private const string GuardHostAppendix = "-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.1.0\n-- Retail URL0107 owns two equal-weight death states. Unit-index parity is\n-- deterministic and multiplayer-safe. Sanctuary's Host PlayAnimation API\n-- exposes cross-fade time but no playback-rate control, so FA's randomized\n-- 0.75-1.25 rate range is retained as evidence and played at nominal 1x.\nlocal SCO_MantisStockDeathThread = HostGuardLandUnit.DeathThread\nfunction HostGuardLandUnit:DeathThread(overkillRatio)\n    if self.tpId ~= \"ugl1002\" then\n        return SCO_MantisStockDeathThread(self, overkillRatio)\n    end\n    if not self.dead then\n        error(\"UGL1002 Mantis death animation must run after HostUnit:OnDestroy\")\n    end\n\n    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations\n    local useFirst = ((self.id and self.id.index) or 0) % 2 == 0\n    local death\n    if animations then\n        if useFirst then\n            death = animations.death01\n        else\n            death = animations.death02\n        end\n    end\n    if not death or not death.id then\n        error(\"UGL1002 Mantis requires both source-pinned death clips\")\n    end\n    Engine.PlayAnimation(self.id, death.id, 0.1)\n    WaitSeconds(1)\n    return SCO_MantisStockDeathThread(self, overkillRatio)\nend";

	public static void Apply()
	{
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>();
		try
		{
			ValidatePinnedScope();
			obj = GetLuaFileCache();
			ValidateTransactionState(obj);
			QueueAppend(obj, list, "LJ/lua/common/units/unitsTemplates/ugl1002/ugl1002.santp", "UGL1002 Mantis template", "-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.1.0\n-- FA URL0107 Mantis -> Guard ugl1002. The canonical asset replaces only\n-- ugl1002.sananimation: Rest and AnimWalk01 remain byte-identical, while\n-- both retail one-second death clips are appended as terminal clamp states.\nUnitTemplate.general = UnitTemplate.general or {}\nUnitTemplate.general.displayName = \"Mantis\"\nUnitTemplate.general.name = \"Mantis\"\nUnitTemplate.general.orders = UnitTemplate.general.orders or {}\nUnitTemplate.general.orders.Repair = true\n-- URL0107 has BuildRate=1 and can repair/assist, but it cannot place\n-- new structures. Sanctuary uses a construction table plus range to\n-- authorize repair behavior, while the omitted canBuild expression\n-- intentionally keeps a Mantis out of the construction build menu.\nUnitTemplate.construction = {\n    beam = {\n        boneName = \"Turret_Muzzle_01\",\n        offset = { x = 0, y = 0, z = 0 },\n        shrink = 1,\n    },\n    buildPower = 1,\n    range = 5,\n}\n\nUnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = {\n    max = 270,\n    regen = 0,\n    value = 270,\n}\nUnitTemplate.economy = UnitTemplate.economy or {}\nUnitTemplate.economy.buildTime = 260\nUnitTemplate.economy.cost = {\n    alloys = 52,\n    energy = 273,\n}\nUnitTemplate.intel = UnitTemplate.intel or {}\nUnitTemplate.intel.visionRadius = 20\n\n-- URL0107's source collision is 0.7 x 0.5 x 0.9 at a 0.15 vertical\n-- center offset. The imported 0.1475-scale model measures about\n-- 0.825 x 0.635 x 0.899, so retain source horizontal occupancy while\n-- giving the selection shell the model's complete visible envelope.\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.15, z = 0 },\n    collisionSize = { x = 0.7, y = 0.5, z = 0.9 },\n}\nUnitTemplate.footprint = { x = 0.7, y = 0.9 }\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 0.85, y = 0.9 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.32, z = 0 }\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.buildBeamBones = {\n    \"Turret_Muzzle_01\",\n    \"Turret_Muzzle_02\",\n}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.85, y = 0.9 },\n    offset = { x = 0, y = 0.32, z = 0 },\n}\nUnitTemplate.additions.faDeathAnimation = {\n    mapping = \"URL0107 -> ugl1002\",\n    sourceUnitsArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceLuaArchiveSha256 = \"3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb\",\n    sourceBlueprint = \"units/URL0107/URL0107_unit.bp\",\n    sourceBlueprintSha256 = \"303c473d3df0a0f0697dcaa7c102295ce3e615c89c3e69083fb84d13086d4b09\",\n    sourceScript = \"units/URL0107/URL0107_script.lua\",\n    sourceScriptSha256 = \"aeb8eb831f99832ed2b35a060beac1f836700b2b8cd28428c66f3bea8155c640\",\n    sourceUnitLuaSha256 = \"ced522e17b204aedfe196706fd3f3421af5f041cf692248ef56d43c97b52cd67\",\n    sourceCybranUnitsLuaSha256 = \"f126ce26875ef8b51f240296af8bd0d86ff07e3fc4b2a5ebf0a5ba4478687411\",\n    class = { owner = \"unitsDefaultGuard\", name = \"GuardLandUnit\", source = \"CWalkingLandUnit\" },\n    sanAnimationSha256 = \"e0c883e2a7ecc249443a217c863fbbab5d4b3c3595d5a09fb9b6b045c1f03695\",\n    existingSanAnimationSha256 = \"09b4bf91da58156c74204723ce6cfe0c7fdccd820252a0a3b32e51a77f2c1825\",\n    clips = {\n        death01 = {\n            source = \"units/URL0107/URL0107_Adeath01.sca\",\n            sha256 = \"f99f5ce7448b4fd17434fe118a53ca857eb7d886dd0f6ccc63c1997d5eca2e13\",\n            frames = 31, duration = 1, weight = 1,\n        },\n        death02 = {\n            source = \"units/URL0107/URL0107_Adeath02.sca\",\n            sha256 = \"3470f69d514164aa7a24be626e9da3c9584ad1510673cadafb4bfe5a12e7a152\",\n            frames = 31, duration = 1, weight = 1,\n        },\n    },\n    sourceRate = { minimum = 0.75, maximum = 1.25 },\n    runtimeRate = 1,\n    selection = \"deterministic equal-weight unit-index parity\",\n    limitations = {\n        sourceDeathRateRandomization = \"0.75-1.25 unavailable; nominal rate used\",\n        hostPlayAnimationThirdArgument = \"cross-fade time, not playback speed\",\n    },\n}\n\nUnitTemplate.movement = UnitTemplate.movement or {}\nUnitTemplate.movement.type = \"LegsLand\"\nUnitTemplate.movement.acceleration = 3.6\nUnitTemplate.movement.deceleration = 3.6\nUnitTemplate.movement.rotationSpeed = 80\nUnitTemplate.movement.speed = 3.6\n-- Sanctuary advances movement-bound clips by velocity / authoredSpeed.\n-- URL0107 has MaxSpeed=3.6 and AnimationWalkRate=8, so 3.6 / 8 = 0.45\n-- reproduces the source 0.25-second gait at full speed.\nUnitTemplate.movement.walkAnimation = { authoredSpeed = 0.45 }\nUnitTemplate.visuals.animations = {\n    death01 = {\n        clipName = \"AnimDeath01\",\n        sanAnimationPath = \"Units/ugl1002/LOD0/ugl1002.sananimation\",\n        playbackMode = AnimationPlaybackMode.Clamp,\n    },\n    death02 = {\n        clipName = \"AnimDeath02\",\n        sanAnimationPath = \"Units/ugl1002/LOD0/ugl1002.sananimation\",\n        playbackMode = AnimationPlaybackMode.Clamp,\n    },\n    walk = {\n        authoredSpeed = 0.45,\n        clipName = \"AnimWalk01\",\n        sanAnimationPath = \"Units/ugl1002/LOD0/ugl1002.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\n\nif not UnitTemplate.weapons or not UnitTemplate.weapons[1] then\n    error(\"UGL1002 Mantis override requires the stock primary weapon\")\nend\nlocal primaryWeapon = UnitTemplate.weapons[1]\n\n-- URL0107's LaserArms weapon uses one controller: Torso yaw, then\n-- Turret_Barrel pitch, with the two arm tips alternating as racks.\nprimaryWeapon.aimControllers = {\n    {\n        aimBone = \"Turret_Muzzle_01\",\n        aimTolerance = 2,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = true,\n        pitchBone = \"Turret_Barrel\",\n        pitchMax = 45,\n        pitchMin = -45,\n        pitchSpeed = 100,\n        poseResetTime = 3,\n        projectileSpeed = 25,\n        solverType = \"LowArc\",\n        yawBone = \"Torso\",\n        yawMax = 180,\n        yawMin = -180,\n        yawSpeed = 80,\n    },\n}\nprimaryWeapon.muzzleGroups = {\n    { muzzles = { \"Turret_Muzzle_01\" } },\n    { muzzles = { \"Turret_Muzzle_02\" } },\n}\nprimaryWeapon.muzzles = {\n    [\"Turret_Muzzle_01\"] = { aimController = \"Turret_Muzzle_01\" },\n    [\"Turret_Muzzle_02\"] = { aimController = \"Turret_Muzzle_01\" },\n}\nprimaryWeapon.damage = 8\nprimaryWeapon.damageRadius = 0\nprimaryWeapon.damageType = \"Normal\"\nprimaryWeapon.effects = {\n    onFire = \"VFX/Muzzle/vgm1121_autocannon_plasma_small_muzzle.sanvfx\",\n}\nprimaryWeapon.firingRandomness = 0\nprimaryWeapon.layerTargetLimits = { \"Land\", \"WaterSurface\" }\nprimaryWeapon.layerWeaponLimits = { \"Land\" }\nprimaryWeapon.muzzleGroupChargeDelay = 0\nprimaryWeapon.muzzleGroupTimeOut = -1\nprimaryWeapon.muzzleSalvoSize = 1\nprimaryWeapon.projectileLifetime = 2.875\n-- CDFLaserHeavy01 is a low-arc direct projectile. pgd131 is the\n-- existing Guard direct-projectile compatibility visual; its use is\n-- explicit so it cannot be mistaken for a source-specific VFX port.\nprimaryWeapon.projectileTemplate = \"pgd131\"\nprimaryWeapon.rangeMax = 18\nprimaryWeapon.rangeMin = 0\nprimaryWeapon.rangeRingType = \"DirectFire\"\nprimaryWeapon.rangeTracking = 1.15\nprimaryWeapon.reloadTime = 0.3333333333333333\nprimaryWeapon.targetWaterLimits = \"Above\"", ValidatePatchedTemplate);
			QueueAppend(obj, list, "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Mantis Guard death lifecycle", "-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.1.0\n-- Retail URL0107 owns two equal-weight death states. Unit-index parity is\n-- deterministic and multiplayer-safe. Sanctuary's Host PlayAnimation API\n-- exposes cross-fade time but no playback-rate control, so FA's randomized\n-- 0.75-1.25 rate range is retained as evidence and played at nominal 1x.\nlocal SCO_MantisStockDeathThread = HostGuardLandUnit.DeathThread\nfunction HostGuardLandUnit:DeathThread(overkillRatio)\n    if self.tpId ~= \"ugl1002\" then\n        return SCO_MantisStockDeathThread(self, overkillRatio)\n    end\n    if not self.dead then\n        error(\"UGL1002 Mantis death animation must run after HostUnit:OnDestroy\")\n    end\n\n    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations\n    local useFirst = ((self.id and self.id.index) or 0) % 2 == 0\n    local death\n    if animations then\n        if useFirst then\n            death = animations.death01\n        else\n            death = animations.death02\n        end\n    end\n    if not death or not death.id then\n        error(\"UGL1002 Mantis requires both source-pinned death clips\")\n    end\n    Engine.PlayAnimation(self.id, death.id, 0.1)\n    WaitSeconds(1)\n    return SCO_MantisStockDeathThread(self, overkillRatio)\nend", ValidatePatchedGuardHost);
			if (list.Count == 0)
			{
				Log("URL0107 Mantis template and death lifecycle are already current.");
				return;
			}
			Commit(obj, list);
			Log("Applied atomic URL0107 -> ugl1002 Mantis template and two-clip death lifecycle.");
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
			Log($"Failed to apply the Cybran Mantis transaction: {arg}");
			throw;
		}
	}

	private static void ValidatePinnedScope()
	{
		if (new string[11]
		{
			"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb", "303c473d3df0a0f0697dcaa7c102295ce3e615c89c3e69083fb84d13086d4b09", "aeb8eb831f99832ed2b35a060beac1f836700b2b8cd28428c66f3bea8155c640", "ced522e17b204aedfe196706fd3f3421af5f041cf692248ef56d43c97b52cd67", "f126ce26875ef8b51f240296af8bd0d86ff07e3fc4b2a5ebf0a5ba4478687411", "f99f5ce7448b4fd17434fe118a53ca857eb7d886dd0f6ccc63c1997d5eca2e13", "3470f69d514164aa7a24be626e9da3c9584ad1510673cadafb4bfe5a12e7a152", "09b4bf91da58156c74204723ce6cfe0c7fdccd820252a0a3b32e51a77f2c1825", "e0c883e2a7ecc249443a217c863fbbab5d4b3c3595d5a09fb9b6b045c1f03695",
			"c55e1e9a12cc7e2775edaff379d5850952fa180e873cdbb66420a62415f6e2ce"
		}.Any((string hash) => hash.Length != 64))
		{
			throw new InvalidOperationException("The reviewed URL0107 Mantis source or generated-asset hash scope changed.");
		}
	}

	private static void ValidateTransactionState(object cache)
	{
		string resourceText = GetResourceText(GetCachedResource(cache, "LJ/lua/common/units/unitsTemplates/ugl1002/ugl1002.santp", "UGL1002 Mantis template").Stock);
		string resourceText2 = GetResourceText(GetCachedResource(cache, "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Mantis Guard death lifecycle").Stock);
		if (resourceText.IndexOf("-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.0.0", StringComparison.Ordinal) >= 0 || resourceText2.IndexOf("-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.0.0", StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("A legacy Mantis 1.0.0 cache mutation is present; restart with a fresh Sanctuary Lua cache before applying 1.1.0.");
		}
		int num = 0;
		if (resourceText.IndexOf("-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.1.0", StringComparison.Ordinal) >= 0)
		{
			num++;
		}
		if (resourceText2.IndexOf("-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.1.0", StringComparison.Ordinal) >= 0)
		{
			num++;
		}
		if (num != 0 && num != 2)
		{
			throw new InvalidOperationException($"A partial Mantis transaction was found ({num}/2 owned resources).");
		}
		if (num == 2)
		{
			ValidatePatchedTemplate(resourceText);
			ValidatePatchedGuardHost(resourceText2);
		}
	}

	private static void ValidateStock(string relativePath, string source)
	{
		if (!(relativePath == "LJ/lua/common/units/unitsTemplates/ugl1002/ugl1002.santp"))
		{
			if (!(relativePath == "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua"))
			{
				throw new InvalidOperationException("Unexpected Mantis cache path: " + relativePath);
			}
			RequireTokens(source, "HostGuardLandUnit = Class(\"GuardLandUnit\", LandUnit)", "HostGuardCommander");
		}
		else
		{
			RequireTokens(source, "UnitTemplate =", "tpId = \"ugl1002\"", "\"unitsDefaultGuard\"", "\"GuardLandUnit\"", "weapons = {");
			RequireExactly(source, "tpId = \"ugl1002\"", 1, "stock ugl1002 tpId");
		}
	}

	private static void ValidatePatchedTemplate(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.1.0", 1, "Mantis template marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "mapping = \"URL0107 -> ugl1002\"", "sourceUnitsArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\"", "sourceLuaArchiveSha256 = \"3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb\"", "sourceBlueprintSha256 = \"303c473d3df0a0f0697dcaa7c102295ce3e615c89c3e69083fb84d13086d4b09\"", "sourceScriptSha256 = \"aeb8eb831f99832ed2b35a060beac1f836700b2b8cd28428c66f3bea8155c640\"", "sanAnimationSha256 = \"e0c883e2a7ecc249443a217c863fbbab5d4b3c3595d5a09fb9b6b045c1f03695\"", "sha256 = \"f99f5ce7448b4fd17434fe118a53ca857eb7d886dd0f6ccc63c1997d5eca2e13\"", "sha256 = \"3470f69d514164aa7a24be626e9da3c9584ad1510673cadafb4bfe5a12e7a152\"", "sourceRate = { minimum = 0.75, maximum = 1.25 }", "runtimeRate = 1", "selection = \"deterministic equal-weight unit-index parity\"", "sourceDeathRateRandomization = \"0.75-1.25 unavailable; nominal rate used\"", "clipName = \"AnimDeath01\"", "clipName = \"AnimDeath02\"", "playbackMode = AnimationPlaybackMode.Clamp", "authoredSpeed = 0.45", "clipName = \"AnimWalk01\"", "primaryWeapon.damage = 8", "primaryWeapon.reloadTime = 0.3333333333333333", "primaryWeapon.projectileTemplate = \"pgd131\"");
		RequireExactly(source2, "playbackMode = AnimationPlaybackMode.Clamp", 2, "Mantis clamp playback state");
		RequireExactly(source2, "weight = 1", 2, "Mantis equal death weight");
		RequireExactly(source2, "clipName = \"AnimWalk01\"", 1, "preserved Mantis walk binding");
		ValidateStock("LJ/lua/common/units/unitsTemplates/ugl1002/ugl1002.santp", source);
	}

	private static void ValidatePatchedGuardHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.1.0", 1, "Mantis Guard-host marker");
		RequireTokens(OwnedAppendix(source), "local SCO_MantisStockDeathThread = HostGuardLandUnit.DeathThread", "function HostGuardLandUnit:DeathThread(overkillRatio)", "if self.tpId ~= \"ugl1002\" then", "if not self.dead then", "local useFirst = ((self.id and self.id.index) or 0) % 2 == 0", "death = animations.death01", "death = animations.death02", "Engine.PlayAnimation(self.id, death.id, 0.1)", "WaitSeconds(1)", "return SCO_MantisStockDeathThread(self, overkillRatio)", "0.75-1.25 rate range", "no playback-rate control");
		ValidateStock("LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", source);
	}

	private static void QueueAppend(object cache, ICollection<CacheMutation> mutations, string relativePath, string description, string appendix, Action<string> validate)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		byte[] nativeArrayBytes = GetNativeArrayBytes(cachedResource.Stock);
		string text = Encoding.UTF8.GetString(nativeArrayBytes);
		if (text.IndexOf("-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.1.0", StringComparison.Ordinal) >= 0)
		{
			validate(text);
			return;
		}
		if (text.IndexOf("-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.0.0", StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("The cached " + description + " still contains the legacy Mantis marker.");
		}
		ValidateStock(relativePath, text);
		byte[] bytes = Encoding.UTF8.GetBytes("\n\n" + NormalizeNewlines(appendix).Trim(new char[1] { '\n' }) + "\n");
		object obj = NativeArrayByteFactory.CreatePersistent(cachedResource.Stock.GetType(), nativeArrayBytes, bytes);
		try
		{
			validate(GetResourceText(obj));
			mutations.Add(new CacheMutation(cachedResource.Path, cachedResource.Stock, obj, description));
		}
		catch
		{
			TryDispose(obj, "uncommitted " + description);
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
			TryDispose(mutation2.Stock, "stock " + mutation2.Description);
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
					SetCachedResource(cache, item.Path, item.Stock);
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

	private static CacheResource TryGetCachedResource(object cache, string relativePath, string description)
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

	private static byte[] GetNativeArrayBytes(object resource)
	{
		EnsureCreated(resource, "Lua cache resource");
		return (byte[])(resource.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray")).Invoke(resource, null);
	}

	private static string GetResourceText(object resource)
	{
		return Encoding.UTF8.GetString(GetNativeArrayBytes(resource));
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

	private static string NormalizeNewlines(string source)
	{
		return source.Replace("\r\n", "\n").Replace('\r', '\n');
	}

	private static string OwnedAppendix(string source)
	{
		int num = source.IndexOf("-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.1.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Mantis marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul Cybran Mantis Cache Patcher 1.1.0".Length, StringComparison.Ordinal);
		if (num2 < 0)
		{
			return source.Substring(num);
		}
		return source.Substring(num, num2 - num);
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
		string text = "[Cybran Mantis Cache Patcher] " + message;
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
