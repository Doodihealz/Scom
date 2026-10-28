using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using ScomDeterministicLua;
using SupremeCommanderOverhaul.Shared;

namespace FaAnimationClosureCachePatcher;

public static class CachePatcherRuntime
{
	private enum Faction
	{
		Aeon,
		Seraphim
	}

	private sealed class DeploySpec
	{
		public string TargetId { get; }

		public string SourceId { get; }

		public Faction Faction { get; }

		public string ClipName { get; }

		public string AnimationEntry { get; }

		public string AnimationSha256 { get; }

		public string BlueprintSha256 { get; }

		public string ScriptSha256 { get; }

		public string ModelSha256 { get; }

		public double AuthoredDuration { get; }

		public double AuthoredRate { get; }

		public double TransitionSeconds => AuthoredDuration / AuthoredRate;

		public double RepackTimeout { get; }

		public bool LocksMotion { get; }

		public string ConstructionClipName { get; }

		public string ConstructionEntry { get; }

		public string ConstructionSha256 { get; }

		public double ConstructionDuration { get; }

		public bool HasValidHashes
		{
			get
			{
				if (new string[4] { AnimationSha256, BlueprintSha256, ScriptSha256, ModelSha256 }.All((string hash) => hash.Length == 64 && hash.All(Uri.IsHexDigit)))
				{
					if (ConstructionClipName.Length != 0)
					{
						if (ConstructionSha256.Length == 64 && ConstructionSha256.All(Uri.IsHexDigit) && ConstructionDuration > 0.0)
						{
							return ConstructionEntry.Length != 0;
						}
						return false;
					}
					return true;
				}
				return false;
			}
		}

		public DeploySpec(string targetId, string sourceId, Faction faction, string clipName, string animationEntry, string animationSha256, string blueprintSha256, string scriptSha256, string modelSha256, double authoredDuration, double authoredRate, double repackTimeout, bool locksMotion, string constructionClipName = "", string constructionEntry = "", string constructionSha256 = "", double constructionDuration = 0.0)
		{
			TargetId = targetId;
			SourceId = sourceId;
			Faction = faction;
			ClipName = clipName;
			AnimationEntry = animationEntry;
			AnimationSha256 = animationSha256;
			BlueprintSha256 = blueprintSha256;
			ScriptSha256 = scriptSha256;
			ModelSha256 = modelSha256;
			AuthoredDuration = authoredDuration;
			AuthoredRate = authoredRate;
			RepackTimeout = repackTimeout;
			LocksMotion = locksMotion;
			ConstructionClipName = constructionClipName;
			ConstructionEntry = constructionEntry;
			ConstructionSha256 = constructionSha256;
			ConstructionDuration = constructionDuration;
		}
	}

	private sealed class SubmarineSpec
	{
		public string TargetId { get; }

		public string SourceId { get; }

		public int WeaponIndex { get; }

		public string WeaponLabel { get; }

		public double Duration { get; }

		public string BlueprintSha256 { get; }

		public string ScriptSha256 { get; }

		public string ModelSha256 { get; }

		public string AnimationSha256 { get; }

		public bool HasValidHashes => new string[4] { BlueprintSha256, ScriptSha256, ModelSha256, AnimationSha256 }.All((string hash) => hash.Length == 64 && hash.All(Uri.IsHexDigit));

		public SubmarineSpec(string targetId, string sourceId, int weaponIndex, string weaponLabel, double duration, string blueprintSha256, string scriptSha256, string modelSha256, string animationSha256)
		{
			TargetId = targetId;
			SourceId = sourceId;
			WeaponIndex = weaponIndex;
			WeaponLabel = weaponLabel;
			Duration = duration;
			BlueprintSha256 = blueprintSha256;
			ScriptSha256 = scriptSha256;
			ModelSha256 = modelSha256;
			AnimationSha256 = animationSha256;
		}
	}

	private sealed class PatchSpec
	{
		public string RelativePath { get; }

		public string Description { get; }

		public string Appendix { get; }

		public Action<string> ValidateStock { get; }

		public Action<string> ValidatePatched { get; }

		public PatchSpec(string relativePath, string description, string appendix, Action<string> validateStock, Action<string> validatePatched)
		{
			RelativePath = relativePath;
			Description = description;
			Appendix = appendix;
			ValidateStock = validateStock;
			ValidatePatched = validatePatched;
		}
	}

	private sealed class CachedResource
	{
		public string Path { get; }

		public object Stock { get; }

		public string Description { get; }

		public CachedResource(string path, object stock, string description)
		{
			Path = path;
			Stock = stock;
			Description = description;
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

	internal const string OverrideMarker = "-- Supreme Commander Overhaul FA animation closure 1.0.1";

	internal const string SourceArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	private const int ClampPlaybackMode = 0;

	private const string AeonUpstreamMarker = "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0";

	private const string SeraphimUpstreamMarker = "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0";

	private const string AeonHostClassesPath = "LJ/lua/host/units/unitsClasses/unitsDefaultChosen.lua";

	private const string SeraphimHostClassesPath = "LJ/lua/host/units/unitsClasses/unitsDefaultSeraphim.lua";

	private const string HostWeaponPath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private static readonly DeploySpec[] DeploySpecs = new DeploySpec[7]
	{
		new DeploySpec("ucl3801", "XAL0305", Faction.Aeon, "AnimAsetup", "units/XAL0305/XAL0305_asetup.sca", "15f53413216527c24d86e1586cd9941e8840379c9f4733cae6b598e5a9a52483", "b5ba4a2ba84fabd475a6ac44a9bfec9b5e00bb471e870a4610ca291be8bd0deb", "fab3bee322ff591be54677bbe27c6a3c978d0febe940e4e7bdfe5a3c62ae9dac", "ea4d6e409d5fd40254b943ef5422c98a368cacf9b9a92a939f05cb4a0a9abd4e", 1.0, 1.0, 0.0, locksMotion: true),
		new DeploySpec("ucs2102", "UAB2108", Faction.Aeon, "AnimOpen", "units/UAB2108/UAB2108_Aopen.sca", "c399cded91fc8805c01127e5a57dd1a12a4079281460011606d5fa7726492607", "f957f075831aa8e18a1d2a67f93335d0593d94463b7b0b55d3c2c894ef4edeec", "7589f79b495b8134606217abed6a96b59ab7bdb3e9dc912ece833698ce5f2af9", "af23d4ec5833b9d6c4a3b516c654f7a9f8e981a456612e2a10b514a394f905fa", 3.0, 1.0, 3.0, locksMotion: false),
		new DeploySpec("ucs2402", "UAB4201", Faction.Aeon, "AnimOpen", "units/UAB4201/UAB4201_Aopen.sca", "93379bccb9b67a40ca862bb4d7171fa178fea3c25ae2722164650259d7582828", "96d6ae783a48f8c18d929e707a710e0d0a54fa9df16fed6d27c3f986d764533a", "f6b6092a57a2baff5a0634233ab9651286c91c3c7cc9c02edbae6c473e054459", "27846a1b56f710d9b7c7d9a89004f4b6a1efa62771c2bb82286cbbd497e6ba35", 3.0, 10.0, 1.0, locksMotion: false),
		new DeploySpec("ucs3102", "UAB2305", Faction.Aeon, "AnimAlaunchsequence", "units/UAB2305/UAB2305_Alaunchsequence.sca", "55595941f480c2feb6282af0849e22e53a3179f9c1aa72190d755edd4537494e", "038993929f7375646f6173a401adc214417afc7766d97ce62dc4c50870bb59f2", "abf6dbc15e64ef1e4ca5148f398d016b835ab03b0642452bba5f85949437c2d8", "1e0fc6b052acf714ada6a0a6b67a5624c994d271ecd0178f51d3f85e0aad7761", 10.0, 1.0, 2.8, locksMotion: false, "AnimOpen", "units/UAB2305/UAB2305_Aopen.sca", "55275d58fd1335dd1643bc823cc58fa6c4034265964611087c8c7522227c3c4b", 16.6666660308838),
		new DeploySpec("usl3101", "XSL0304", Faction.Seraphim, "AnimAttack01", "units/XSL0304/XSL0304_attack01.sca", "65c295a71f8e2028f3b2520b153e1a12687490dc0b0090d6d2dc15984cfd227c", "2f8dd478914dfbe90e98952a2a2cccbbc936f597833becab205c5f5a01aebca5", "65d8633cb939e447d7c674c35384ce0da908d04d92a21c1b47301e48944e9c90", "24bd6effa460d7df197745d27089b7f5338ec3df52425302a1c915d2d898c4e2", 1.0, 1.0, 0.0, locksMotion: true),
		new DeploySpec("uss2102", "XSB2108", Faction.Seraphim, "AnimOpen", "units/XSB2108/XSB2108_aopen.sca", "d3f0ff8d7b413542a97125a308729875eb5c63f6747295aefbde44404fbe2ce8", "72d14324ce4c295fee7315e60272379a2d1c198cf6f88162eb222da660489f62", "849a9d556e399551500498cadb1e4339a89dc926f7b8f9a838ebeff932e987b8", "c383bc2dcfb96dc6c6840fb7ac253ea2d500a3f22d6ad07a8a86aaa6f59abd9b", 1.0, 1.0, 3.0, locksMotion: false),
		new DeploySpec("uss3102", "XSB2305", Faction.Seraphim, "AnimOpen", "units/XSB2305/XSB2305_aopen.sca", "fcbcd5c80aed64402cbc4e211cc4356a566442e696236676b392b97f3de6f751", "e3ded95d2d2b1b56235c70f3b2d6bae9e3cfb220bd02156a780f3f90c79b6017", "2edf65be60a5d261261f4535f13a5d51a1d79c6b28472a85d5a045414f60e6cb", "4b375c79f1521673d012021db96fd172101559fe3328e44dc423259119bae469", 3.33333325386047, 0.4, 5.0, locksMotion: false)
	};

	private static readonly SubmarineSpec[] SubmarineSpecs = new SubmarineSpec[2]
	{
		new SubmarineSpec("usn1002", "XSS0203", 3, "Cannon", 1.66666662693024, "d49efdc25ef4a20f20c7fe0fdf4767eb3304b9a0e916880f1374dc440d3050c8", "b39230d52ce7ef4e25141dbc303bfb5db534232ea692de5a4d76f41ce6354107", "a7dd004607520d8f5a6ca5355522408c23f76f88f1d2cbb8c24be9cb8c4c88b4", "494758b0e737b20dc6d7f99e9a157298e44bf0f8485a1f49bc174c01f25b3a3d"),
		new SubmarineSpec("usn3004", "XSS0304", 4, "AutoCannon", 0.5, "6cf4ff2c7041790188d315bc114c2eda0a1856100cc9f32d4332d954629fa44d", "a2163052394f57062bdf18ce0b1cce248d88d75dfc9814f37fd1ff1cf1905b85", "edb898de4f040e7491fd36dbac5e356ea69bf6fcbcf38cd1b4c6fb45855174b0", "e64243e17c2b0b067da041acc6aa188cc45b8dbab415daf5994f474e5bec41d6")
	};

	private const string AeonHostClassesAppendix = "\n\n-- Supreme Commander Overhaul FA animation closure 1.0.1\nlocal SCO_AnimationClosureSentinelBase = -10000\n\nlocal function SCO_AnimationClosureAlive(unit)\n    return unit ~= nil and not unit.dead and not unit.deleted\nend\n\nlocal function SCO_AnimationClosureSample(unit, key, seconds)\n    local animations = unit.tp.visuals and unit.tp.visuals.animations\n    local animation = animations and animations[key]\n    if not animation or not animation.id then\n        error(unit.tpId .. \" requires source animation \" .. tostring(key))\n    end\n    Engine.PlayAnimation(\n        unit.id,\n        animation.id,\n        SCO_AnimationClosureSentinelBase + seconds)\nend\n\nlocal function SCO_AnimationClosureConstructionOpenThread(unit, generation)\n    local deploy = unit.tp.additions.faAnimationClosureWeaponDeploy\n    local config = deploy and deploy.constructionOpen\n    if not config then return end\n    local elapsed = 0\n    while SCO_AnimationClosureAlive(unit)\n        and unit.scoFaConstructionOpenGeneration == generation\n        and elapsed < config.authoredDurationSeconds\n    do\n        SCO_AnimationClosureSample(unit, config.animationKey, elapsed)\n        WaitTicks(1)\n        elapsed = math.min(\n            config.authoredDurationSeconds,\n            elapsed + Constants.TickTimeStep * config.authoredRate)\n    end\n    if SCO_AnimationClosureAlive(unit)\n        and unit.scoFaConstructionOpenGeneration == generation\n    then\n        SCO_AnimationClosureSample(\n            unit,\n            config.animationKey,\n            config.authoredDurationSeconds)\n        unit.scoFaAnimationConstructionReady = true\n    end\nend\n\nfunction AeonPortStructure:OnStopBeingBuilt()\n    ChosenStructure.OnStopBeingBuilt(self)\n    local deploy = self.tp.additions\n        and self.tp.additions.faAnimationClosureWeaponDeploy\n    if not deploy or not deploy.constructionOpen then return end\n    self.scoFaAnimationConstructionReady = false\n    self.scoFaConstructionOpenGeneration =\n        (self.scoFaConstructionOpenGeneration or 0) + 1\n    self:NewThread(\n        SCO_AnimationClosureConstructionOpenThread,\n        self.scoFaConstructionOpenGeneration)\nend";

	private const string SeraphimHostClassesAppendix = "\n\n-- Supreme Commander Overhaul FA animation closure 1.0.1\nlocal SCO_AnimationClosureLayers = Import(\"common/layers.lua\")\nlocal SCO_AnimationClosureTargetingLayer =\n    SCO_AnimationClosureLayers.TargetingLayer\nlocal SCO_AnimationClosureSentinelBase = -10000\n\nlocal function SCO_AnimationClosureAlive(unit)\n    return unit ~= nil and not unit.dead and not unit.deleted\nend\n\nlocal function SCO_AnimationClosureSample(unit, key, seconds)\n    local animations = unit.tp.visuals and unit.tp.visuals.animations\n    local animation = animations and animations[key]\n    if not animation or not animation.id then\n        error(unit.tpId .. \" requires source animation \" .. tostring(key))\n    end\n    Engine.PlayAnimation(\n        unit.id,\n        animation.id,\n        SCO_AnimationClosureSentinelBase + seconds)\nend\n\nlocal function SCO_AnimationClosurePlayPacked(unit, config)\n    local animations = unit.tp.visuals and unit.tp.visuals.animations\n    local animation = animations and animations[config.packedAnimationKey]\n    if not animation or not animation.id then\n        error(unit.tpId .. \" requires its source packed pose\")\n    end\n    Engine.PlayAnimation(unit.id, animation.id, 0.1)\nend\n\nlocal function SCO_AnimationClosureSubmarineThread(unit, generation, opening)\n    local config = unit.tp.additions and unit.tp.additions.faSubmarineHatch\n    if not config then return end\n    local elapsed = unit.scoFaSubmarineHatchSample\n        or (opening and 0 or config.authoredDurationSeconds)\n    if not opening then\n        unit.scoFaSubmarineCannonReady = false\n    end\n    while SCO_AnimationClosureAlive(unit)\n        and unit.scoFaSubmarineHatchGeneration == generation\n        and ((opening and elapsed < config.authoredDurationSeconds)\n            or (not opening and elapsed > 0))\n    do\n        SCO_AnimationClosureSample(unit, config.animationKey, elapsed)\n        unit.scoFaSubmarineHatchSample = elapsed\n        WaitTicks(1)\n        local delta = Constants.TickTimeStep * config.authoredRate\n        if opening then\n            elapsed = math.min(config.authoredDurationSeconds, elapsed + delta)\n        else\n            elapsed = math.max(0, elapsed - delta)\n        end\n    end\n    if not SCO_AnimationClosureAlive(unit)\n        or unit.scoFaSubmarineHatchGeneration ~= generation\n    then return end\n    unit.scoFaSubmarineHatchSample = elapsed\n    if opening then\n        SCO_AnimationClosureSample(unit, config.animationKey, elapsed)\n        unit.scoFaSubmarineCannonReady = true\n    else\n        SCO_AnimationClosurePlayPacked(unit, config)\n    end\nend\n\nfunction SeraphimNavalUnit:SCO_SetSubmarineSurfaceState(surface)\n    local config = self.tp.additions and self.tp.additions.faSubmarineHatch\n    if not config or self.scoFaSubmarineSurface == surface then return end\n    self.scoFaSubmarineSurface = surface\n    self.scoFaSubmarineHatchGeneration =\n        (self.scoFaSubmarineHatchGeneration or 0) + 1\n    self:NewThread(\n        SCO_AnimationClosureSubmarineThread,\n        self.scoFaSubmarineHatchGeneration,\n        surface)\nend\n\nfunction SeraphimNavalUnit:OnStopBeingBuilt()\n    -- Bypass the earlier true-fourth unconditional-open shim. The FA\n    -- source branches on Water versus Sub; this is the sole writer.\n    ChosenNavalUnit.OnStopBeingBuilt(self)\n    local config = self.tp.additions and self.tp.additions.faSubmarineHatch\n    if not config then return end\n    self.scoFaSubmarineHatchSample = 0\n    self.scoFaSubmarineCannonReady = false\n    self:SCO_SetSubmarineSurfaceState(\n        self.targetingLayer\n            == SCO_AnimationClosureTargetingLayer.WaterSurface)\nend\n\nfunction SeraphimNavalUnit:SetTargetingLayer(layer)\n    local previous = self.targetingLayer\n    ChosenNavalUnit.SetTargetingLayer(self, layer)\n    local config = self.tp.additions and self.tp.additions.faSubmarineHatch\n    if not config or previous == layer then return end\n    if layer == SCO_AnimationClosureTargetingLayer.WaterSurface then\n        self:SCO_SetSubmarineSurfaceState(true)\n    elseif layer == SCO_AnimationClosureTargetingLayer.Water then\n        self:SCO_SetSubmarineSurfaceState(false)\n    end\nend";

	private const string HostWeaponAppendix = "\n\n-- Supreme Commander Overhaul FA animation closure 1.0.1\nlocal SCO_AnimationClosureWeaponStockDelete = HostWeapon.Delete\nlocal SCO_AnimationClosureWeaponStockSetAimTarget = HostWeapon.SetAimTarget\nlocal SCO_AnimationClosureWeaponStockUpdate = HostWeapon.Update\nlocal SCO_AnimationClosureWeaponSentinelBase = -10000\n\nlocal function SCO_AnimationClosureWeaponConfig(weapon)\n    if not weapon.tp or not weapon.tp.scoFaAnimationClosureDeploy then\n        return nil\n    end\n    local additions = weapon.unit and weapon.unit.tp\n        and weapon.unit.tp.additions\n    return additions and additions.faAnimationClosureWeaponDeploy\nend\n\nlocal function SCO_AnimationClosureWeaponSample(weapon, key, seconds)\n    local animations = weapon.unit.tp.visuals\n        and weapon.unit.tp.visuals.animations\n    local animation = animations and animations[key]\n    if not animation or not animation.id then\n        error(weapon.unit.tpId .. \" requires source animation \" .. tostring(key))\n    end\n    Engine.PlayAnimation(\n        weapon.unit.id,\n        animation.id,\n        SCO_AnimationClosureWeaponSentinelBase + seconds)\nend\n\nlocal function SCO_AnimationClosureWeaponSetMovement(weapon, locked)\n    if weapon.scoFaAnimationMovementLocked == locked then return end\n    weapon.scoFaAnimationMovementLocked = locked\n    Engine.SetMovementEnabled(weapon.unit.id, not locked)\nend\n\nlocal function SCO_AnimationClosureWeaponPlayPacked(weapon, config)\n    local construction = config.constructionOpen\n    if construction then\n        SCO_AnimationClosureWeaponSample(\n            weapon,\n            construction.animationKey,\n            construction.authoredDurationSeconds)\n        return\n    end\n    local animations = weapon.unit.tp.visuals\n        and weapon.unit.tp.visuals.animations\n    local packed = animations and animations[config.packedAnimationKey]\n    if not packed or not packed.id then\n        error(weapon.unit.tpId .. \" requires its source packed pose\")\n    end\n    Engine.PlayAnimation(weapon.unit.id, packed.id, 0.1)\nend\n\nlocal function SCO_AnimationClosureWeaponBegin(weapon, state, config)\n    weapon.scoFaAnimationDeployState = state\n    if state == \"opening\" and config.sourceWeaponUnpackLocksMotion then\n        SCO_AnimationClosureWeaponSetMovement(weapon, true)\n    end\nend\n\nlocal function SCO_AnimationClosureWeaponAdvance(weapon, config, now)\n    local state = weapon.scoFaAnimationDeployState or \"packed\"\n    local sample = weapon.scoFaAnimationDeploySample or 0\n    local hasTarget = weapon:HasTarget()\n\n    if config.constructionOpen\n        and weapon.unit.scoFaAnimationConstructionReady ~= true\n    then\n        return false\n    end\n\n    if hasTarget then\n        weapon.scoFaAnimationTargetLostTime = nil\n        if state == \"packed\" or state == \"closing\" then\n            SCO_AnimationClosureWeaponBegin(weapon, \"opening\", config)\n            state = \"opening\"\n        end\n    elseif weapon.scoFaAnimationTargetLostTime == nil then\n        weapon.scoFaAnimationTargetLostTime = now\n    end\n\n    if state == \"opening\" then\n        SCO_AnimationClosureWeaponSample(\n            weapon, config.deployAnimationKey, sample)\n        sample = math.min(\n            config.authoredDurationSeconds,\n            sample + Constants.TickTimeStep * config.authoredRate)\n        weapon.scoFaAnimationDeploySample = sample\n        if sample >= config.authoredDurationSeconds then\n            SCO_AnimationClosureWeaponSample(\n                weapon, config.deployAnimationKey, sample)\n            weapon.scoFaAnimationDeployState = \"deployed\"\n            state = \"deployed\"\n        else\n            return false\n        end\n    end\n\n    if state == \"deployed\" and not hasTarget\n        and now >= weapon.scoFaAnimationTargetLostTime\n            + config.repackTimeoutSeconds\n    then\n        SCO_AnimationClosureWeaponBegin(weapon, \"closing\", config)\n        state = \"closing\"\n    end\n\n    if state == \"closing\" then\n        if hasTarget then\n            SCO_AnimationClosureWeaponBegin(weapon, \"opening\", config)\n            return false\n        end\n        SCO_AnimationClosureWeaponSample(\n            weapon, config.deployAnimationKey, sample)\n        sample = math.max(\n            0,\n            sample - Constants.TickTimeStep * config.authoredRate)\n        weapon.scoFaAnimationDeploySample = sample\n        if sample <= 0 then\n            weapon.scoFaAnimationDeployState = \"packed\"\n            weapon.scoFaAnimationTargetLostTime = nil\n            SCO_AnimationClosureWeaponPlayPacked(weapon, config)\n            if config.sourceWeaponUnpackLocksMotion then\n                SCO_AnimationClosureWeaponSetMovement(weapon, false)\n            end\n        end\n        return false\n    end\n\n    return weapon.scoFaAnimationDeployState == \"deployed\"\nend\n\nfunction HostWeapon:Delete()\n    local config = SCO_AnimationClosureWeaponConfig(self)\n    if config and self.scoFaAnimationMovementLocked then\n        SCO_AnimationClosureWeaponSetMovement(self, false)\n    end\n    return SCO_AnimationClosureWeaponStockDelete(self)\nend\n\nfunction HostWeapon:SetAimTarget(targetUnit)\n    local previous = self.targetUnit\n    local result = SCO_AnimationClosureWeaponStockSetAimTarget(\n        self, targetUnit)\n    local config = SCO_AnimationClosureWeaponConfig(self)\n    if config then\n        local now = GetGameTimeSeconds()\n        if targetUnit ~= nil then\n            self.scoFaAnimationTargetLostTime = nil\n            if self.scoFaAnimationDeployState == \"closing\" then\n                SCO_AnimationClosureWeaponBegin(self, \"opening\", config)\n            end\n        elseif previous ~= nil then\n            self.scoFaAnimationTargetLostTime = now\n        end\n    end\n    return result\nend\n\nfunction HostWeapon:Update()\n    if self.tp and self.tp.scoFaAnimationClosureSurfaceWeapon\n        and not self.unit.scoFaSubmarineCannonReady\n    then\n        return\n    end\n    local config = SCO_AnimationClosureWeaponConfig(self)\n    if config and not SCO_AnimationClosureWeaponAdvance(\n        self, config, GetGameTimeSeconds())\n    then\n        return\n    end\n    return SCO_AnimationClosureWeaponStockUpdate(self)\nend";

	public static void Apply()
	{
		ValidatePinnedScope();
		PatchSpec[] array = BuildPatchSpecs();
		object cache = null;
		List<CacheMutation> mutations = new List<CacheMutation>(array.Length);
		try
		{
			cache = GetLuaFileCache();
			(PatchSpec, CachedResource)[] array2 = array.Select((PatchSpec spec) => (Spec: spec, Resource: GetCachedResource(cache, spec.RelativePath, spec.Description))).ToArray();
			int num = array2.Count(((PatchSpec Spec, CachedResource Resource) pair) => ContainsMarker(GetText(pair.Resource.Stock)));
			(PatchSpec, CachedResource)[] array3;
			if (num == array.Length)
			{
				array3 = array2;
				for (int num2 = 0; num2 < array3.Length; num2++)
				{
					(PatchSpec, CachedResource) tuple = array3[num2];
					tuple.Item1.ValidatePatched(GetText(tuple.Item2.Stock));
				}
				Log("The source-proven FA deploy and submarine animation closure is already current.");
				return;
			}
			if (num != 0)
			{
				throw new InvalidOperationException($"A partial animation-closure transaction was found ({num}/{array.Length}); refusing mixed lifecycle ownership.");
			}
			array3 = array2;
			for (int num3 = 0; num3 < array3.Length; num3++)
			{
				(PatchSpec, CachedResource) tuple2 = array3[num3];
				tuple2.Item1.ValidateStock(GetText(tuple2.Item2.Stock));
				QueueAppend(mutations, tuple2.Item2, tuple2.Item1.Appendix, tuple2.Item1.ValidatePatched);
			}
			Commit(cache, mutations);
			Log("Applied seven exact weapon deploy/repack lifecycles and two Seraphim surface-hatch cannon gates.");
		}
		catch (Exception arg)
		{
			if (cache != null)
			{
				RollBack(cache, mutations);
			}
			else
			{
				DisposeUncommitted(mutations);
			}
			Log($"Failed to apply the FA animation-closure transaction: {arg}");
			throw;
		}
	}

	private static PatchSpec[] BuildPatchSpecs()
	{
		List<PatchSpec> list = new List<PatchSpec>(DeploySpecs.Length + SubmarineSpecs.Length + 3);
		list.AddRange(DeploySpecs.Select((DeploySpec spec) => new PatchSpec(TemplatePath(spec.TargetId), spec.TargetId + " <- " + spec.SourceId + " deploy lifecycle", BuildDeployAppendix(spec), delegate(string source)
		{
			ValidateStockTemplate(source, spec.TargetId, spec.Faction);
		}, delegate(string source)
		{
			ValidatePatchedDeployTemplate(source, spec);
		})));
		list.AddRange(SubmarineSpecs.Select((SubmarineSpec spec) => new PatchSpec(TemplatePath(spec.TargetId), spec.TargetId + " <- " + spec.SourceId + " submarine hatch lifecycle", BuildSubmarineAppendix(spec), delegate(string source)
		{
			ValidateStockTemplate(source, spec.TargetId, Faction.Seraphim);
		}, delegate(string source)
		{
			ValidatePatchedSubmarineTemplate(source, spec);
		})));
		list.Add(new PatchSpec("LJ/lua/host/units/unitsClasses/unitsDefaultChosen.lua", "Aeon animation-closure host classes", "\n\n-- Supreme Commander Overhaul FA animation closure 1.0.1\nlocal SCO_AnimationClosureSentinelBase = -10000\n\nlocal function SCO_AnimationClosureAlive(unit)\n    return unit ~= nil and not unit.dead and not unit.deleted\nend\n\nlocal function SCO_AnimationClosureSample(unit, key, seconds)\n    local animations = unit.tp.visuals and unit.tp.visuals.animations\n    local animation = animations and animations[key]\n    if not animation or not animation.id then\n        error(unit.tpId .. \" requires source animation \" .. tostring(key))\n    end\n    Engine.PlayAnimation(\n        unit.id,\n        animation.id,\n        SCO_AnimationClosureSentinelBase + seconds)\nend\n\nlocal function SCO_AnimationClosureConstructionOpenThread(unit, generation)\n    local deploy = unit.tp.additions.faAnimationClosureWeaponDeploy\n    local config = deploy and deploy.constructionOpen\n    if not config then return end\n    local elapsed = 0\n    while SCO_AnimationClosureAlive(unit)\n        and unit.scoFaConstructionOpenGeneration == generation\n        and elapsed < config.authoredDurationSeconds\n    do\n        SCO_AnimationClosureSample(unit, config.animationKey, elapsed)\n        WaitTicks(1)\n        elapsed = math.min(\n            config.authoredDurationSeconds,\n            elapsed + Constants.TickTimeStep * config.authoredRate)\n    end\n    if SCO_AnimationClosureAlive(unit)\n        and unit.scoFaConstructionOpenGeneration == generation\n    then\n        SCO_AnimationClosureSample(\n            unit,\n            config.animationKey,\n            config.authoredDurationSeconds)\n        unit.scoFaAnimationConstructionReady = true\n    end\nend\n\nfunction AeonPortStructure:OnStopBeingBuilt()\n    ChosenStructure.OnStopBeingBuilt(self)\n    local deploy = self.tp.additions\n        and self.tp.additions.faAnimationClosureWeaponDeploy\n    if not deploy or not deploy.constructionOpen then return end\n    self.scoFaAnimationConstructionReady = false\n    self.scoFaConstructionOpenGeneration =\n        (self.scoFaConstructionOpenGeneration or 0) + 1\n    self:NewThread(\n        SCO_AnimationClosureConstructionOpenThread,\n        self.scoFaConstructionOpenGeneration)\nend", ValidateStockAeonHostClasses, ValidatePatchedAeonHostClasses));
		list.Add(new PatchSpec("LJ/lua/host/units/unitsClasses/unitsDefaultSeraphim.lua", "true-fourth Seraphim animation-closure host classes", "\n\n-- Supreme Commander Overhaul FA animation closure 1.0.1\nlocal SCO_AnimationClosureLayers = Import(\"common/layers.lua\")\nlocal SCO_AnimationClosureTargetingLayer =\n    SCO_AnimationClosureLayers.TargetingLayer\nlocal SCO_AnimationClosureSentinelBase = -10000\n\nlocal function SCO_AnimationClosureAlive(unit)\n    return unit ~= nil and not unit.dead and not unit.deleted\nend\n\nlocal function SCO_AnimationClosureSample(unit, key, seconds)\n    local animations = unit.tp.visuals and unit.tp.visuals.animations\n    local animation = animations and animations[key]\n    if not animation or not animation.id then\n        error(unit.tpId .. \" requires source animation \" .. tostring(key))\n    end\n    Engine.PlayAnimation(\n        unit.id,\n        animation.id,\n        SCO_AnimationClosureSentinelBase + seconds)\nend\n\nlocal function SCO_AnimationClosurePlayPacked(unit, config)\n    local animations = unit.tp.visuals and unit.tp.visuals.animations\n    local animation = animations and animations[config.packedAnimationKey]\n    if not animation or not animation.id then\n        error(unit.tpId .. \" requires its source packed pose\")\n    end\n    Engine.PlayAnimation(unit.id, animation.id, 0.1)\nend\n\nlocal function SCO_AnimationClosureSubmarineThread(unit, generation, opening)\n    local config = unit.tp.additions and unit.tp.additions.faSubmarineHatch\n    if not config then return end\n    local elapsed = unit.scoFaSubmarineHatchSample\n        or (opening and 0 or config.authoredDurationSeconds)\n    if not opening then\n        unit.scoFaSubmarineCannonReady = false\n    end\n    while SCO_AnimationClosureAlive(unit)\n        and unit.scoFaSubmarineHatchGeneration == generation\n        and ((opening and elapsed < config.authoredDurationSeconds)\n            or (not opening and elapsed > 0))\n    do\n        SCO_AnimationClosureSample(unit, config.animationKey, elapsed)\n        unit.scoFaSubmarineHatchSample = elapsed\n        WaitTicks(1)\n        local delta = Constants.TickTimeStep * config.authoredRate\n        if opening then\n            elapsed = math.min(config.authoredDurationSeconds, elapsed + delta)\n        else\n            elapsed = math.max(0, elapsed - delta)\n        end\n    end\n    if not SCO_AnimationClosureAlive(unit)\n        or unit.scoFaSubmarineHatchGeneration ~= generation\n    then return end\n    unit.scoFaSubmarineHatchSample = elapsed\n    if opening then\n        SCO_AnimationClosureSample(unit, config.animationKey, elapsed)\n        unit.scoFaSubmarineCannonReady = true\n    else\n        SCO_AnimationClosurePlayPacked(unit, config)\n    end\nend\n\nfunction SeraphimNavalUnit:SCO_SetSubmarineSurfaceState(surface)\n    local config = self.tp.additions and self.tp.additions.faSubmarineHatch\n    if not config or self.scoFaSubmarineSurface == surface then return end\n    self.scoFaSubmarineSurface = surface\n    self.scoFaSubmarineHatchGeneration =\n        (self.scoFaSubmarineHatchGeneration or 0) + 1\n    self:NewThread(\n        SCO_AnimationClosureSubmarineThread,\n        self.scoFaSubmarineHatchGeneration,\n        surface)\nend\n\nfunction SeraphimNavalUnit:OnStopBeingBuilt()\n    -- Bypass the earlier true-fourth unconditional-open shim. The FA\n    -- source branches on Water versus Sub; this is the sole writer.\n    ChosenNavalUnit.OnStopBeingBuilt(self)\n    local config = self.tp.additions and self.tp.additions.faSubmarineHatch\n    if not config then return end\n    self.scoFaSubmarineHatchSample = 0\n    self.scoFaSubmarineCannonReady = false\n    self:SCO_SetSubmarineSurfaceState(\n        self.targetingLayer\n            == SCO_AnimationClosureTargetingLayer.WaterSurface)\nend\n\nfunction SeraphimNavalUnit:SetTargetingLayer(layer)\n    local previous = self.targetingLayer\n    ChosenNavalUnit.SetTargetingLayer(self, layer)\n    local config = self.tp.additions and self.tp.additions.faSubmarineHatch\n    if not config or previous == layer then return end\n    if layer == SCO_AnimationClosureTargetingLayer.WaterSurface then\n        self:SCO_SetSubmarineSurfaceState(true)\n    elseif layer == SCO_AnimationClosureTargetingLayer.Water then\n        self:SCO_SetSubmarineSurfaceState(false)\n    end\nend", ValidateStockSeraphimHostClasses, ValidatePatchedSeraphimHostClasses));
		list.Add(new PatchSpec("LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "FA animation-closure HostWeapon lifecycle", "\n\n-- Supreme Commander Overhaul FA animation closure 1.0.1\nlocal SCO_AnimationClosureWeaponStockDelete = HostWeapon.Delete\nlocal SCO_AnimationClosureWeaponStockSetAimTarget = HostWeapon.SetAimTarget\nlocal SCO_AnimationClosureWeaponStockUpdate = HostWeapon.Update\nlocal SCO_AnimationClosureWeaponSentinelBase = -10000\n\nlocal function SCO_AnimationClosureWeaponConfig(weapon)\n    if not weapon.tp or not weapon.tp.scoFaAnimationClosureDeploy then\n        return nil\n    end\n    local additions = weapon.unit and weapon.unit.tp\n        and weapon.unit.tp.additions\n    return additions and additions.faAnimationClosureWeaponDeploy\nend\n\nlocal function SCO_AnimationClosureWeaponSample(weapon, key, seconds)\n    local animations = weapon.unit.tp.visuals\n        and weapon.unit.tp.visuals.animations\n    local animation = animations and animations[key]\n    if not animation or not animation.id then\n        error(weapon.unit.tpId .. \" requires source animation \" .. tostring(key))\n    end\n    Engine.PlayAnimation(\n        weapon.unit.id,\n        animation.id,\n        SCO_AnimationClosureWeaponSentinelBase + seconds)\nend\n\nlocal function SCO_AnimationClosureWeaponSetMovement(weapon, locked)\n    if weapon.scoFaAnimationMovementLocked == locked then return end\n    local unit = weapon.unit\n    local unitId = unit and unit.tpId\n    if unitId ~= \"usl3101\" and unitId ~= \"ucl3801\" then\n        error(\"Unexpected FA animation-closure movement lock owner\")\n    end\n    if unit.dead or unit.deleted then\n        weapon.scoFaAnimationMovementLocked = locked\n        weapon.scoFaAnimationPreviousMaxSpeed = nil\n        return\n    end\n    local speed\n    if locked then\n        local status\n        status, speed = Engine.GetMovementMaxSpeed(unit.id)\n        if status ~= EngineErrorCode.Success or type(speed) ~= \"number\" then\n            error(unitId .. \" deploy could not read movement speed\")\n        end\n        -- Keep movement active so native separation retains the collision entry.\n        local stop = Engine.MovementStop(unit.id, EngineClasses.float2(0, 0))\n        if stop ~= EngineErrorCode.Success then\n            error(unitId .. \" deploy could not stop movement\")\n        end\n    else\n        speed = weapon.scoFaAnimationPreviousMaxSpeed\n        if type(speed) ~= \"number\" then\n            error(unitId .. \" deploy has no movement speed to restore\")\n        end\n    end\n    local result = Engine.SetMovementMaxSpeed(unit.id, locked and 0 or speed)\n    if result ~= EngineErrorCode.Success then\n        error(unitId .. \" deploy could not update movement speed\")\n    end\n    weapon.scoFaAnimationPreviousMaxSpeed = locked and speed or nil\n    weapon.scoFaAnimationMovementLocked = locked\nend\n\nlocal function SCO_AnimationClosureWeaponPlayPacked(weapon, config)\n    local construction = config.constructionOpen\n    if construction then\n        SCO_AnimationClosureWeaponSample(\n            weapon,\n            construction.animationKey,\n            construction.authoredDurationSeconds)\n        return\n    end\n    local animations = weapon.unit.tp.visuals\n        and weapon.unit.tp.visuals.animations\n    local packed = animations and animations[config.packedAnimationKey]\n    if not packed or not packed.id then\n        error(weapon.unit.tpId .. \" requires its source packed pose\")\n    end\n    Engine.PlayAnimation(weapon.unit.id, packed.id, 0.1)\nend\n\nlocal function SCO_AnimationClosureWeaponBegin(weapon, state, config)\n    weapon.scoFaAnimationDeployState = state\n    if state == \"opening\" and config.sourceWeaponUnpackLocksMotion then\n        SCO_AnimationClosureWeaponSetMovement(weapon, true)\n    end\nend\n\nlocal function SCO_AnimationClosureWeaponAdvance(weapon, config, now)\n    local state = weapon.scoFaAnimationDeployState or \"packed\"\n    local sample = weapon.scoFaAnimationDeploySample or 0\n    local hasTarget = weapon:HasTarget()\n\n    if config.constructionOpen\n        and weapon.unit.scoFaAnimationConstructionReady ~= true\n    then\n        return false\n    end\n\n    if hasTarget then\n        weapon.scoFaAnimationTargetLostTime = nil\n        if state == \"packed\" or state == \"closing\" then\n            SCO_AnimationClosureWeaponBegin(weapon, \"opening\", config)\n            state = \"opening\"\n        end\n    elseif weapon.scoFaAnimationTargetLostTime == nil then\n        weapon.scoFaAnimationTargetLostTime = now\n    end\n\n    if state == \"opening\" then\n        SCO_AnimationClosureWeaponSample(\n            weapon, config.deployAnimationKey, sample)\n        sample = math.min(\n            config.authoredDurationSeconds,\n            sample + Constants.TickTimeStep * config.authoredRate)\n        weapon.scoFaAnimationDeploySample = sample\n        if sample >= config.authoredDurationSeconds then\n            SCO_AnimationClosureWeaponSample(\n                weapon, config.deployAnimationKey, sample)\n            weapon.scoFaAnimationDeployState = \"deployed\"\n            state = \"deployed\"\n        else\n            return false\n        end\n    end\n\n    if state == \"deployed\" and not hasTarget\n        and now >= weapon.scoFaAnimationTargetLostTime\n            + config.repackTimeoutSeconds\n    then\n        SCO_AnimationClosureWeaponBegin(weapon, \"closing\", config)\n        state = \"closing\"\n    end\n\n    if state == \"closing\" then\n        if hasTarget then\n            SCO_AnimationClosureWeaponBegin(weapon, \"opening\", config)\n            return false\n        end\n        SCO_AnimationClosureWeaponSample(\n            weapon, config.deployAnimationKey, sample)\n        sample = math.max(\n            0,\n            sample - Constants.TickTimeStep * config.authoredRate)\n        weapon.scoFaAnimationDeploySample = sample\n        if sample <= 0 then\n            weapon.scoFaAnimationDeployState = \"packed\"\n            weapon.scoFaAnimationTargetLostTime = nil\n            SCO_AnimationClosureWeaponPlayPacked(weapon, config)\n            if config.sourceWeaponUnpackLocksMotion then\n                SCO_AnimationClosureWeaponSetMovement(weapon, false)\n            end\n        end\n        return false\n    end\n\n    return weapon.scoFaAnimationDeployState == \"deployed\"\nend\n\nfunction HostWeapon:Delete()\n    local config = SCO_AnimationClosureWeaponConfig(self)\n    if config and self.scoFaAnimationMovementLocked then\n        SCO_AnimationClosureWeaponSetMovement(self, false)\n    end\n    return SCO_AnimationClosureWeaponStockDelete(self)\nend\n\nfunction HostWeapon:SetAimTarget(targetUnit)\n    local previous = self.targetUnit\n    local result = SCO_AnimationClosureWeaponStockSetAimTarget(\n        self, targetUnit)\n    local config = SCO_AnimationClosureWeaponConfig(self)\n    if config then\n        local now = GetGameTimeSeconds()\n        if targetUnit ~= nil then\n            self.scoFaAnimationTargetLostTime = nil\n            if self.scoFaAnimationDeployState == \"closing\" then\n                SCO_AnimationClosureWeaponBegin(self, \"opening\", config)\n            end\n        elseif previous ~= nil then\n            self.scoFaAnimationTargetLostTime = now\n        end\n    end\n    return result\nend\n\nfunction HostWeapon:Update()\n    if self.tp and self.tp.scoFaAnimationClosureSurfaceWeapon\n        and not self.unit.scoFaSubmarineCannonReady\n    then\n        return\n    end\n    local config = SCO_AnimationClosureWeaponConfig(self)\n    if config and not SCO_AnimationClosureWeaponAdvance(\n        self, config, GetGameTimeSeconds())\n    then\n        return\n    end\n    return SCO_AnimationClosureWeaponStockUpdate(self)\nend", ValidateStockHostWeapon, ValidatePatchedHostWeapon));
		IGrouping<string, PatchSpec> grouping = list.GroupBy<PatchSpec, string>((PatchSpec spec) => spec.RelativePath, StringComparer.OrdinalIgnoreCase).FirstOrDefault((IGrouping<string, PatchSpec> group) => group.Count() != 1);
		if (grouping != null)
		{
			throw new InvalidOperationException("Animation-closure resource path is duplicated: " + grouping.Key);
		}
		return list.ToArray();
	}

	private static string TemplatePath(string targetId)
	{
		return "LJ/lua/common/units/unitsTemplates/" + targetId + "/" + targetId + ".santp";
	}

	private static string BuildDeployAppendix(DeploySpec spec)
	{
		string text = "Units/" + spec.TargetId + "/LOD0/" + spec.TargetId + ".sananimation";
		string text2 = ((spec.ConstructionClipName.Length == 0) ? string.Empty : $"UnitTemplate.visuals.animations.fa_construction_open = {{\n    clipName = \"{spec.ConstructionClipName}\",\n    playbackMode = {0},\n    sanAnimationPath = \"{text}\",\n}}");
		string text3 = ((spec.ConstructionClipName.Length == 0) ? string.Empty : ("    constructionOpen = {\n        animationKey = \"fa_construction_open\",\n        source = \"" + spec.ConstructionEntry + "\",\n        sha256 = \"" + spec.ConstructionSha256 + "\",\n        authoredDurationSeconds = " + Lua(spec.ConstructionDuration) + ",\n        authoredRate = 1,\n    },"));
		return string.Format("\n\n{0}\n-- Exact source weapon state: target acquisition unpacks, firing waits\n-- for the authored endpoint, target loss waits WeaponRepackTimeout,\n-- and the same clip then runs backward to its packed pose.\nUnitTemplate.visuals = UnitTemplate.visuals or {{}}\nUnitTemplate.visuals.animations = UnitTemplate.visuals.animations or {{}}\nUnitTemplate.visuals.animations.fa_deploy = {{\n    clipName = \"{1}\",\n    playbackMode = {2},\n    sanAnimationPath = \"{3}\",\n}}\nUnitTemplate.visuals.animations.fa_packed = {{\n    clipName = \"Rest\",\n    playbackMode = {4},\n    sanAnimationPath = \"{5}\",\n}}\n{6}\nUnitTemplate.additions = UnitTemplate.additions or {{}}\nUnitTemplate.additions.faAnimationClosureWeaponDeploy = {{\n    mapping = \"{7} -> {8}\",\n    sourceArchiveSha256 = \"{9}\",\n    sourceBlueprintSha256 = \"{10}\",\n    sourceScriptSha256 = \"{11}\",\n    sourceModelSha256 = \"{12}\",\n    sourceAnimation = \"{13}\",\n    sourceAnimationSha256 = \"{14}\",\n    deployAnimationKey = \"fa_deploy\",\n    packedAnimationKey = \"fa_packed\",\n    authoredDurationSeconds = {15},\n    authoredRate = {16},\n    transitionSeconds = {17},\n    repackTimeoutSeconds = {18},\n    sourceWeaponUnpacks = true,\n    sourceWeaponUnpackLocksMotion = {19},\n{20}}}\nUnitTemplate.weapons[1].scoFaAnimationClosureDeploy = true", "-- Supreme Commander Overhaul FA animation closure 1.0.1", spec.ClipName, 0, text, 0, text, text2, spec.SourceId, spec.TargetId, "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", spec.BlueprintSha256, spec.ScriptSha256, spec.ModelSha256, spec.AnimationEntry, spec.AnimationSha256, Lua(spec.AuthoredDuration), Lua(spec.AuthoredRate), Lua(spec.TransitionSeconds), Lua(spec.RepackTimeout), Lua(spec.LocksMotion), text3);
	}

	private static string BuildSubmarineAppendix(SubmarineSpec spec)
	{
		string text = "Units/" + spec.TargetId + "/LOD0/" + spec.TargetId + ".sananimation";
		return string.Format("\n\n{0}\n-- XSS SurfacingSub source contract: Water opens the housing before\n-- enabling only {1}; Sub disables it immediately and\n-- reverses the same clip. Engine.PlayAnimation remains the sole\n-- replicated animation writer.\nUnitTemplate.visuals = UnitTemplate.visuals or {{}}\nUnitTemplate.visuals.animations = UnitTemplate.visuals.animations or {{}}\nUnitTemplate.visuals.animations.fa_submarine_hatch = {{\n    clipName = \"AnimOpen\",\n    playbackMode = {2},\n    sanAnimationPath = \"{3}\",\n}}\nUnitTemplate.visuals.animations.fa_submarine_packed = {{\n    clipName = \"Rest\",\n    playbackMode = {4},\n    sanAnimationPath = \"{5}\",\n}}\nUnitTemplate.additions = UnitTemplate.additions or {{}}\nUnitTemplate.additions.faSubmarineHatch = {{\n    mapping = \"{6} -> {7}\",\n    sourceArchiveSha256 = \"{8}\",\n    sourceBlueprintSha256 = \"{9}\",\n    sourceScriptSha256 = \"{10}\",\n    sourceModelSha256 = \"{11}\",\n    sourceAnimation = \"units/{12}/{13}_aopen.sca\",\n    sourceAnimationSha256 = \"{14}\",\n    animationKey = \"fa_submarine_hatch\",\n    packedAnimationKey = \"fa_submarine_packed\",\n    authoredDurationSeconds = {15},\n    authoredRate = 1,\n    surfaceLayer = \"Water\",\n    submergedLayer = \"Sub\",\n    surfaceTargetingLayer = \"WaterSurface\",\n    submergedTargetingLayer = \"Water\",\n    gatedWeaponIndex = {16},\n    gatedWeaponLabel = \"{17}\",\n}}\nUnitTemplate.weapons[{18}].scoFaAnimationClosureSurfaceWeapon = true", "-- Supreme Commander Overhaul FA animation closure 1.0.1", spec.WeaponLabel, 0, text, 0, text, spec.SourceId, spec.TargetId, "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", spec.BlueprintSha256, spec.ScriptSha256, spec.ModelSha256, spec.SourceId, spec.SourceId, spec.AnimationSha256, Lua(spec.Duration), spec.WeaponIndex, spec.WeaponLabel, spec.WeaponIndex);
	}

	private static void ValidatePinnedScope()
	{
		string[] second = new string[9] { "ucl3801", "ucs2102", "ucs2402", "ucs3102", "usl3101", "uss2102", "uss3102", "usn1002", "usn3004" };
		string[] array = DeploySpecs.Select((DeploySpec spec) => spec.TargetId).Concat<string>(SubmarineSpecs.Select((SubmarineSpec spec) => spec.TargetId)).ToArray();
		if (DeploySpecs.Length != 7 || SubmarineSpecs.Length != 2 || !array.SequenceEqual(second, StringComparer.Ordinal) || array.Distinct(StringComparer.Ordinal).Count() != array.Length || "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26".Length != 64)
		{
			throw new InvalidOperationException("The reviewed nine-unit FA animation-closure scope changed.");
		}
		DeploySpec[] deploySpecs = DeploySpecs;
		foreach (DeploySpec deploySpec in deploySpecs)
		{
			if (!deploySpec.HasValidHashes || deploySpec.AuthoredDuration <= 0.0 || deploySpec.AuthoredRate <= 0.0 || Math.Abs(deploySpec.TransitionSeconds - deploySpec.AuthoredDuration / deploySpec.AuthoredRate) > 1E-07 || deploySpec.RepackTimeout < 0.0)
			{
				throw new InvalidOperationException(deploySpec.SourceId + "/" + deploySpec.TargetId + " has an invalid pinned deploy contract.");
			}
		}
		SubmarineSpec[] submarineSpecs = SubmarineSpecs;
		foreach (SubmarineSpec submarineSpec in submarineSpecs)
		{
			if (!submarineSpec.HasValidHashes || submarineSpec.Duration <= 0.0 || submarineSpec.WeaponIndex < 1 || string.IsNullOrWhiteSpace(submarineSpec.WeaponLabel))
			{
				throw new InvalidOperationException(submarineSpec.SourceId + "/" + submarineSpec.TargetId + " has an invalid pinned hatch contract.");
			}
		}
	}

	private static void ValidateStockTemplate(string source, string targetId, Faction faction)
	{
		RequireTokens(source, "tpId = \"" + targetId + "\"", (faction == Faction.Aeon) ? "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0" : "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", "UnitTemplate.visuals.animations");
	}

	private static void ValidatePatchedDeployTemplate(string source, DeploySpec spec)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA animation closure 1.0.1", 1, spec.TargetId + " marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "mapping = \"" + spec.SourceId + " -> " + spec.TargetId + "\"", "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", spec.BlueprintSha256, spec.ScriptSha256, spec.ModelSha256, spec.AnimationSha256, "clipName = \"" + spec.ClipName + "\"", "deployAnimationKey = \"fa_deploy\"", "packedAnimationKey = \"fa_packed\"", "authoredDurationSeconds = " + Lua(spec.AuthoredDuration), "authoredRate = " + Lua(spec.AuthoredRate), "transitionSeconds = " + Lua(spec.TransitionSeconds), "repackTimeoutSeconds = " + Lua(spec.RepackTimeout), "sourceWeaponUnpackLocksMotion = " + Lua(spec.LocksMotion), "UnitTemplate.weapons[1].scoFaAnimationClosureDeploy = true");
		if (spec.ConstructionClipName.Length != 0)
		{
			RequireTokens(source2, "clipName = \"" + spec.ConstructionClipName + "\"", spec.ConstructionSha256, "authoredDurationSeconds = " + Lua(spec.ConstructionDuration));
		}
		RequireExactly(source2, "scoFaAnimationClosureDeploy = true", 1, spec.TargetId + " weapon ownership flag");
		RequireNumericClampPlaybackModes(source2, (spec.ConstructionClipName.Length == 0) ? 2 : 3, spec.TargetId);
	}

	private static void ValidatePatchedSubmarineTemplate(string source, SubmarineSpec spec)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA animation closure 1.0.1", 1, spec.TargetId + " marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "mapping = \"" + spec.SourceId + " -> " + spec.TargetId + "\"", "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", spec.BlueprintSha256, spec.ScriptSha256, spec.ModelSha256, spec.AnimationSha256, "clipName = \"AnimOpen\"", "authoredDurationSeconds = " + Lua(spec.Duration), $"gatedWeaponIndex = {spec.WeaponIndex}", "gatedWeaponLabel = \"" + spec.WeaponLabel + "\"", $"UnitTemplate.weapons[{spec.WeaponIndex}].scoFaAnimationClosureSurfaceWeapon = true");
		RequireExactly(source2, "scoFaAnimationClosureSurfaceWeapon = true", 1, spec.TargetId + " surface weapon gate");
		RequireNumericClampPlaybackModes(source2, 2, spec.TargetId);
	}

	private static void RequireNumericClampPlaybackModes(string source, int expectedCount, string description)
	{
		RequireExactly(source, $"playbackMode = {0},", expectedCount, description + " numeric clamp playback mode");
		if (source.IndexOf("playbackMode = \"", StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException(description + " contains a quoted playback mode that the engine FFI cannot marshal.");
		}
	}

	private static void ValidateStockAeonHostClasses(string source)
	{
		RequireTokens(source, "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0", "AeonPortStructure = Class(\"AeonPortStructure\", ChosenStructure)");
	}

	private static void ValidatePatchedAeonHostClasses(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA animation closure 1.0.1", 1, "animation-closure Aeon host marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "SCO_AnimationClosureSentinelBase = -10000", "function AeonPortStructure:OnStopBeingBuilt()", "ChosenStructure.OnStopBeingBuilt(self)", "SCO_AnimationClosureConstructionOpenThread");
		RequireExactly(source2, "Engine.PlayAnimation(", 1, "Aeon host animation transport call");
	}

	private static void ValidateStockSeraphimHostClasses(string source)
	{
		RequireTokens(source, "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", "local ChosenNavalUnit = chosenDefaults.HostChosenNavalUnit", "HostSeraphimNavalUnit = Class(\"SeraphimNavalUnit\", ChosenNavalUnit)", "local SeraphimNavalUnit = HostSeraphimNavalUnit", "function SeraphimNavalUnit:OnStopBeingBuilt()");
	}

	private static void ValidatePatchedSeraphimHostClasses(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA animation closure 1.0.1", 1, "animation-closure true-fourth Seraphim host marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "SCO_AnimationClosureSentinelBase = -10000", "function SeraphimNavalUnit:SCO_SetSubmarineSurfaceState(surface)", "function SeraphimNavalUnit:OnStopBeingBuilt()", "ChosenNavalUnit.OnStopBeingBuilt(self)", "function SeraphimNavalUnit:SetTargetingLayer(layer)", "SCO_AnimationClosureTargetingLayer.WaterSurface", "SCO_AnimationClosureTargetingLayer.Water", "unit.scoFaSubmarineCannonReady = false", "unit.scoFaSubmarineCannonReady = true", "unit.scoFaSubmarineHatchSample = elapsed");
		RequireExactly(source2, "function SeraphimNavalUnit:OnStopBeingBuilt()", 1, "true-fourth source-layer OnStopBeingBuilt owner");
		RequireExactly(source2, "Engine.PlayAnimation(", 2, "Seraphim host animation transport calls");
	}

	private static void ValidateStockHostWeapon(string source)
	{
		RequireTokens(source, "function HostWeapon:Delete()", "function HostWeapon:SetAimTarget(targetUnit)", "function HostWeapon:Update()");
	}

	private static void ValidatePatchedHostWeapon(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA animation closure 1.0.1", 1, "animation-closure HostWeapon marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "SCO_AnimationClosureWeaponSentinelBase = -10000", "local function SCO_AnimationClosureWeaponAdvance(weapon, config, now)", "weapon.scoFaAnimationDeployState or \"packed\"", "state == \"opening\"", "state == \"deployed\"", "state == \"closing\"", "sample + Constants.TickTimeStep * config.authoredRate", "sample - Constants.TickTimeStep * config.authoredRate", "config.repackTimeoutSeconds", "Engine.SetMovementMaxSpeed(unit.id, locked and 0 or speed)", "function HostWeapon:Delete()", "function HostWeapon:SetAimTarget(targetUnit)", "function HostWeapon:Update()", "self.tp.scoFaAnimationClosureSurfaceWeapon", "not self.unit.scoFaSubmarineCannonReady", "return SCO_AnimationClosureWeaponStockUpdate(self)");
		RequireExactly(source2, "function HostWeapon:Update()", 1, "animation-closure HostWeapon Update wrapper");
		RequireExactly(source2, "Engine.PlayAnimation(", 2, "HostWeapon animation transport calls");
	}

	private static string Lua(double value)
	{
		return StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture);
	}

	private static string Lua(bool value)
	{
		if (!value)
		{
			return "false";
		}
		return "true";
	}

	private static void QueueAppend(ICollection<CacheMutation> mutations, CachedResource resource, string appendix, Action<string> validate)
	{
		object obj = CreateNativeArray(resource.Stock.GetType(), Append(GetText(resource.Stock), appendix));
		try
		{
			validate(GetText(obj));
			mutations.Add(new CacheMutation(resource.Path, resource.Stock, obj, resource.Description));
		}
		catch
		{
			TryDispose(obj, "uncommitted " + resource.Description);
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

	private static CachedResource GetCachedResource(object cache, string relativePath, string description)
	{
		Type type = cache.GetType();
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		string text = ResolvePath(relativePath);
		if ((bool)obj.Invoke(cache, new object[1] { text }))
		{
			object obj2 = propertyInfo.GetValue(cache, new object[1] { text }) ?? throw new InvalidOperationException("Cached " + description + " has no value.");
			EnsureCreated(obj2, description);
			return new CachedResource(text, obj2, description);
		}
		string value = "/" + relativePath.Replace('\\', '/');
		CachedResource cachedResource = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			if (type2.GetProperty("Key")?.GetValue(item) is string text2 && text2.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (cachedResource != null)
				{
					throw new InvalidOperationException("More than one cached resource matches " + relativePath + ".");
				}
				object obj3 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("Cached " + description + " has no value.");
				EnsureCreated(obj3, description);
				cachedResource = new CachedResource(text2, obj3, description);
			}
		}
		return cachedResource ?? throw new FileNotFoundException("Required " + description + " was not present in Sanctuary's Lua cache.", relativePath);
	}

	private static string ResolvePath(string relativePath)
	{
		return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
	}

	private static object CreateNativeArray(Type type, string source)
	{
		return NativeArrayByteFactory.CreatePersistent(type, Encoding.UTF8.GetBytes(source));
	}

	private static string GetText(object resource)
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

	private static bool ContainsMarker(string source)
	{
		return source.IndexOf("-- Supreme Commander Overhaul FA animation closure 1.0.1", StringComparison.Ordinal) >= 0;
	}

	private static string Append(string source, string appendix)
	{
		if (!source.EndsWith("\n", StringComparison.Ordinal))
		{
			return source + "\n" + appendix.Replace("\r\n", "\n");
		}
		return source + appendix.Replace("\r\n", "\n");
	}

	private static string OwnedAppendix(string source)
	{
		int num = source.IndexOf("-- Supreme Commander Overhaul FA animation closure 1.0.1", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("FA animation-closure marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul FA animation closure 1.0.1".Length, StringComparison.Ordinal);
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
		string text = "[FA Animation Closure Cache Patcher] " + message;
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
