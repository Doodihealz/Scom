using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using SupremeCommanderOverhaul.Shared;

namespace FaCybranLandScoutCachePatcher;

public static class CachePatcherRuntime
{
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

	internal const string OverrideMarker = "-- Supreme Commander Overhaul FA Cybran Land Scout 1.0.0";

	internal const string TargetId = "ugl1701";

	internal const string SourceId = "URL0101";

	internal const string SourceArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	internal const string SourceBlueprintSha256 = "720d62e6df71611d74225bbb397dac76de617770c7fdd9bcfb60cac32ae0c49a";

	internal const string SourceScriptSha256 = "70380ca0da6a1551186fc5ba2e54e7d57f9044845e8688614f91a3ca314373b1";

	private const string UnitRelativePath = "LJ/lua/common/units/unitsTemplates/ugl1701/ugl1701.santp";

	private const string HostClassRelativePath = "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua";

	private const string UnitAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran Land Scout 1.0.0\n-- Exact direct mapping: FA URL0101 Mole -> Sanctuary Guard ugl1701.\n-- The source has no weapon table. Aagro is shipped but its source\n-- blueprint/script never binds or plays it, so it remains loadable\n-- provenance rather than an invented runtime state.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.rotators = {\n    {\n        boneName = \"Spinner\",\n        speed = { x = 0, y = 90, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n}\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.3, y = 0.3 },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URL0101 -> ugl1701\",\n    sourceId = \"URL0101\",\n    targetId = \"ugl1701\",\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/URL0101/URL0101_unit.bp\",\n    sourceBlueprintSha256 = \"720d62e6df71611d74225bbb397dac76de617770c7fdd9bcfb60cac32ae0c49a\",\n    sourceScript = \"units/URL0101/URL0101_Script.lua\",\n    sourceScriptSha256 = \"70380ca0da6a1551186fc5ba2e54e7d57f9044845e8688614f91a3ca314373b1\",\n    sourceCategories = {\n        \"PRODUCTSC1\", \"SELECTABLE\", \"BUILTBYTIER1FACTORY\",\n        \"BUILTBYTIER2FACTORY\", \"BUILTBYTIER3FACTORY\",\n        \"CYBRAN\", \"MOBILE\", \"LAND\", \"TECH1\", \"SCOUT\",\n        \"INTELLIGENCE\", \"RADAR\", \"VISIBLETORECON\",\n        \"RECLAIMABLE\", \"OVERLAYRADAR\",\n    },\n    class = { owner = \"unitsDefaultGuard\", name = \"GuardLandUnit\" },\n    collision = {\n        centerOffset = { x = 0, y = 0.05, z = 0 },\n        size = { x = 0.5, y = 0.3, z = 0.5 },\n    },\n    selection = { x = 0.3, z = 0.3, thickness = 1.2 },\n    footprint = { x = 0.5, z = 0.5 },\n    defence = { health = 15, regen = 0 },\n    economy = {\n        buildCostEnergy = 80,\n        buildCostMass = 8,\n        buildTime = 80,\n        sourceCloakMaintenanceEnergy = 5,\n    },\n    intel = {\n        radarRadius = 45,\n        visionRadius = 24,\n        sourceCloak = true,\n        sourceCloakStartsDisabled = true,\n        sanctuaryCloakRuntimeSupported = false,\n        radarIsFree = true,\n    },\n    movement = {\n        sourceMotionType = \"RULEUMT_Land\",\n        sourceMaxAcceleration = 4.8,\n        sourceMaxBrake = 4.8,\n        sourceMaxSpeed = 4.8,\n        sourceMaxSpeedReverse = 0,\n        sourceMaxSteerForce = 10,\n        sourceTurnRadius = 0,\n        sourceTurnRate = 180,\n        sourceBackUpDistance = 0,\n        sourceAnimationWalkRate = 10,\n        sanctuaryAuthoredSpeed = 0.48,\n    },\n    spinner = {\n        bone = \"Spinner\",\n        axis = \"y\",\n        speed = 90,\n        sourceAcceleration = 5,\n        sanctuaryAccelerationSupported = false,\n        velocityScaled = false,\n    },\n    animations = {\n        agro = {\n            source = \"units/URL0101/URL0101_Aagro.sca\",\n            sha256 = \"ce0f9edb38884a8e29b9ade06e6bcfe6e4daf961e52f21c44c16a7809fd493a3\",\n            frames = 121, duration = 4, sourceBound = false,\n        },\n        death = {\n            source = \"units/URL0101/URL0101_Adeath.sca\",\n            sha256 = \"6b7cb41b12d11637ae32ab5649f5562c2d40dcd058ddf44e470b2dd165d2e054\",\n            frames = 16, duration = 0.5, sourceRate = 1,\n        },\n        walk = {\n            source = \"units/URL0101/URL0101_Awalk.sca\",\n            sha256 = \"78a5c9fe293d1d0af377b3e789efd0232ca680cd21f85545a00fe1fc525b0636\",\n            frames = 61, duration = 2, sourceRate = 10,\n        },\n    },\n    sourceHasWeapon = false,\n    unsupportedSourceAudio = true,\n    unsupportedGroundKickupEffect = true,\n}\n\nUnitTemplate.general.displayName = \"Mole\"\nUnitTemplate.general.name = \"Mole\"\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"intel\", tech = \"t1\" }\nUnitTemplate.general.iconUI = \"tech1_land1_intel.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 20\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true,\n    Move = true,\n    Patrol = true,\n    Stop = true,\n}\n\nUnitTemplate.audio = nil\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.05, z = 0 },\n    collisionSize = { x = 0.5, y = 0.3, z = 0.5 },\n}\nUnitTemplate.footprint = { x = 0.5, y = 0.5 }\nUnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = { max = 15, regen = 0, value = 15 }\nUnitTemplate.economy = {\n    buildTime = 80,\n    cost = { alloys = 8, energy = 80 },\n}\n-- Do not map the five-energy cloak maintenance to Sanctuary's generic\n-- maintenance resource. HostUnit uses that resource for radar too;\n-- doing so would incorrectly make URL0101's source-free radar cost energy.\nUnitTemplate.intel = { radarRadius = 45, visionRadius = 24 }\n\nUnitTemplate.movement = UnitTemplate.movement or {}\nUnitTemplate.movement.type = \"LegsLand\"\nUnitTemplate.movement.acceleration = 4.8\nUnitTemplate.movement.deceleration = 4.8\nUnitTemplate.movement.rotationSpeed = 180\nUnitTemplate.movement.speed = 4.8\nUnitTemplate.movement.maxReverseDistance = 0\nUnitTemplate.movement.walkAnimation = { authoredSpeed = 0.48 }\nUnitTemplate.movement.air = nil\nUnitTemplate.movement.airHover = nil\nUnitTemplate.movement.minSpeed = nil\nUnitTemplate.movement.water = nil\n\nUnitTemplate.tags = {\n    \"BUILDABLE_BY_T1_FACTORY\",\n    \"BUILDABLE_BY_T2_FACTORY\",\n    \"BUILDABLE_BY_T3_FACTORY\",\n    \"GUARD\",\n    \"INTEL\",\n    \"LAND\",\n    \"MOBILE\",\n    \"RADAR\",\n    \"SCOUT\",\n    \"TECH1\",\n}\nUnitTemplate.weapons = nil\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 0.3, y = 0.3 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0, z = 0 }\nUnitTemplate.visuals.animations = {\n    agro = {\n        clipName = \"AnimAgro\",\n        sanAnimationPath = \"Units/ugl1701/LOD0/ugl1701.sananimation\",\n    },\n    death = {\n        clipName = \"AnimDeath\",\n        sanAnimationPath = \"Units/ugl1701/LOD0/ugl1701.sananimation\",\n    },\n    walk = {\n        authoredSpeed = 0.48,\n        clipName = \"AnimWalk\",\n        sanAnimationPath = \"Units/ugl1701/LOD0/ugl1701.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do\n            effect.boneName = \"Root\"\n        end\n    end\nend";

	private const string HostClassAppendix = "\n\n-- Supreme Commander Overhaul FA Cybran Land Scout 1.0.0\n-- Keep the template's stock GuardLandUnit class. This ID-gated wrapper\n-- delays only the Mole's stock wreck/delete path for one exact source\n-- Adeath play. The loader currently exposes clips as Loop; deletion at\n-- the 0.5-second source endpoint prevents an observable second cycle.\nlocal SCO_FaMoleCommands = Import(\"common/commands/definitions/units.lua\")\nlocal SCO_FaMoleStockCheckRadarState = HostGuardLandUnit.CheckRadarState\nfunction HostGuardLandUnit:CheckRadarState()\n    if self.tpId ~= \"ugl1701\" then\n        return SCO_FaMoleStockCheckRadarState(self)\n    end\n    if not self.radarDetector or self.progress == nil then\n        return\n    end\n\n    -- URL0101 creates and enables a separate, free RadarEnt. It has no\n    -- radar toggle and does not shut down on an army energy stall.\n    local isRadarActive = self:IsCompleted()\n    if self.radarDetector:GetEnabled() ~= isRadarActive then\n        self.radarDetector:SetEnabled(isRadarActive)\n        SCO_FaMoleCommands.SetRadarActive.Send(self.id, isRadarActive)\n    end\nend\n\nlocal SCO_FaMoleStockDeathThread = HostGuardLandUnit.DeathThread\nfunction HostGuardLandUnit:DeathThread(overkillRatio)\n    if self.tpId ~= \"ugl1701\" then\n        return SCO_FaMoleStockDeathThread(self, overkillRatio)\n    end\n\n    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations\n    local death = animations and animations.death\n    if not death or not death.id then\n        error(\"UGL1701 Mole requires its hash-pinned AnimDeath clip\")\n    end\n    Engine.PlayAnimation(self.id, death.id, 0.1)\n    WaitSeconds(0.5)\n    return SCO_FaMoleStockDeathThread(self, overkillRatio)\nend";

	public static void Apply()
	{
		ValidatePinnedScope();
		object obj = null;
		List<CacheMutation> mutations = new List<CacheMutation>(2);
		try
		{
			obj = GetLuaFileCache();
			CachedResource cachedResource = GetCachedResource(obj, "LJ/lua/common/units/unitsTemplates/ugl1701/ugl1701.santp", "UGL1701 unit template");
			CachedResource cachedResource2 = GetCachedResource(obj, "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Guard host class file");
			string text = GetText(cachedResource.Stock);
			string text2 = GetText(cachedResource2.Stock);
			switch ((ContainsMarker(text) ? 1 : 0) + (ContainsMarker(text2) ? 1 : 0))
			{
			case 2:
				ValidatePatchedUnit(text);
				ValidatePatchedHost(text2);
				Log("The exact URL0101 -> ugl1701 gameplay and death lifecycle are already current.");
				break;
			default:
				throw new InvalidOperationException("A partial Mole transaction was found. Refusing to mix stock and patched lifecycle resources.");
			case 0:
				ValidateStockUnit(text);
				ValidateStockHost(text2);
				QueueAppend(mutations, cachedResource, "\n\n-- Supreme Commander Overhaul FA Cybran Land Scout 1.0.0\n-- Exact direct mapping: FA URL0101 Mole -> Sanctuary Guard ugl1701.\n-- The source has no weapon table. Aagro is shipped but its source\n-- blueprint/script never binds or plays it, so it remains loadable\n-- provenance rather than an invented runtime state.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.buildBeamBones = nil\nUnitTemplate.additions.rotators = {\n    {\n        boneName = \"Spinner\",\n        speed = { x = 0, y = 90, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n}\nUnitTemplate.additions.selectionHit = {\n    size = { x = 0.3, y = 0.3 },\n    offset = { x = 0, y = 0, z = 0 },\n}\nUnitTemplate.additions.faSourceContract = {\n    mapping = \"URL0101 -> ugl1701\",\n    sourceId = \"URL0101\",\n    targetId = \"ugl1701\",\n    sourceArchiveSha256 = \"c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26\",\n    sourceBlueprint = \"units/URL0101/URL0101_unit.bp\",\n    sourceBlueprintSha256 = \"720d62e6df71611d74225bbb397dac76de617770c7fdd9bcfb60cac32ae0c49a\",\n    sourceScript = \"units/URL0101/URL0101_Script.lua\",\n    sourceScriptSha256 = \"70380ca0da6a1551186fc5ba2e54e7d57f9044845e8688614f91a3ca314373b1\",\n    sourceCategories = {\n        \"PRODUCTSC1\", \"SELECTABLE\", \"BUILTBYTIER1FACTORY\",\n        \"BUILTBYTIER2FACTORY\", \"BUILTBYTIER3FACTORY\",\n        \"CYBRAN\", \"MOBILE\", \"LAND\", \"TECH1\", \"SCOUT\",\n        \"INTELLIGENCE\", \"RADAR\", \"VISIBLETORECON\",\n        \"RECLAIMABLE\", \"OVERLAYRADAR\",\n    },\n    class = { owner = \"unitsDefaultGuard\", name = \"GuardLandUnit\" },\n    collision = {\n        centerOffset = { x = 0, y = 0.05, z = 0 },\n        size = { x = 0.5, y = 0.3, z = 0.5 },\n    },\n    selection = { x = 0.3, z = 0.3, thickness = 1.2 },\n    footprint = { x = 0.5, z = 0.5 },\n    defence = { health = 15, regen = 0 },\n    economy = {\n        buildCostEnergy = 80,\n        buildCostMass = 8,\n        buildTime = 80,\n        sourceCloakMaintenanceEnergy = 5,\n    },\n    intel = {\n        radarRadius = 45,\n        visionRadius = 24,\n        sourceCloak = true,\n        sourceCloakStartsDisabled = true,\n        sanctuaryCloakRuntimeSupported = false,\n        radarIsFree = true,\n    },\n    movement = {\n        sourceMotionType = \"RULEUMT_Land\",\n        sourceMaxAcceleration = 4.8,\n        sourceMaxBrake = 4.8,\n        sourceMaxSpeed = 4.8,\n        sourceMaxSpeedReverse = 0,\n        sourceMaxSteerForce = 10,\n        sourceTurnRadius = 0,\n        sourceTurnRate = 180,\n        sourceBackUpDistance = 0,\n        sourceAnimationWalkRate = 10,\n        sanctuaryAuthoredSpeed = 0.48,\n    },\n    spinner = {\n        bone = \"Spinner\",\n        axis = \"y\",\n        speed = 90,\n        sourceAcceleration = 5,\n        sanctuaryAccelerationSupported = false,\n        velocityScaled = false,\n    },\n    animations = {\n        agro = {\n            source = \"units/URL0101/URL0101_Aagro.sca\",\n            sha256 = \"ce0f9edb38884a8e29b9ade06e6bcfe6e4daf961e52f21c44c16a7809fd493a3\",\n            frames = 121, duration = 4, sourceBound = false,\n        },\n        death = {\n            source = \"units/URL0101/URL0101_Adeath.sca\",\n            sha256 = \"6b7cb41b12d11637ae32ab5649f5562c2d40dcd058ddf44e470b2dd165d2e054\",\n            frames = 16, duration = 0.5, sourceRate = 1,\n        },\n        walk = {\n            source = \"units/URL0101/URL0101_Awalk.sca\",\n            sha256 = \"78a5c9fe293d1d0af377b3e789efd0232ca680cd21f85545a00fe1fc525b0636\",\n            frames = 61, duration = 2, sourceRate = 10,\n        },\n    },\n    sourceHasWeapon = false,\n    unsupportedSourceAudio = true,\n    unsupportedGroundKickupEffect = true,\n}\n\nUnitTemplate.general.displayName = \"Mole\"\nUnitTemplate.general.name = \"Mole\"\nUnitTemplate.general.icon = { shape = \"land1\", symbol = \"intel\", tech = \"t1\" }\nUnitTemplate.general.iconUI = \"tech1_land1_intel.png\"\nUnitTemplate.general.iconUIBuildSortPriority = 20\nUnitTemplate.general.iconUIType = \"land\"\nUnitTemplate.general.orders = {\n    Assist = true,\n    Move = true,\n    Patrol = true,\n    Stop = true,\n}\n\nUnitTemplate.audio = nil\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.05, z = 0 },\n    collisionSize = { x = 0.5, y = 0.3, z = 0.5 },\n}\nUnitTemplate.footprint = { x = 0.5, y = 0.5 }\nUnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = { max = 15, regen = 0, value = 15 }\nUnitTemplate.economy = {\n    buildTime = 80,\n    cost = { alloys = 8, energy = 80 },\n}\n-- Do not map the five-energy cloak maintenance to Sanctuary's generic\n-- maintenance resource. HostUnit uses that resource for radar too;\n-- doing so would incorrectly make URL0101's source-free radar cost energy.\nUnitTemplate.intel = { radarRadius = 45, visionRadius = 24 }\n\nUnitTemplate.movement = UnitTemplate.movement or {}\nUnitTemplate.movement.type = \"LegsLand\"\nUnitTemplate.movement.acceleration = 4.8\nUnitTemplate.movement.deceleration = 4.8\nUnitTemplate.movement.rotationSpeed = 180\nUnitTemplate.movement.speed = 4.8\nUnitTemplate.movement.maxReverseDistance = 0\nUnitTemplate.movement.walkAnimation = { authoredSpeed = 0.48 }\nUnitTemplate.movement.air = nil\nUnitTemplate.movement.airHover = nil\nUnitTemplate.movement.minSpeed = nil\nUnitTemplate.movement.water = nil\n\nUnitTemplate.tags = {\n    \"BUILDABLE_BY_T1_FACTORY\",\n    \"BUILDABLE_BY_T2_FACTORY\",\n    \"BUILDABLE_BY_T3_FACTORY\",\n    \"GUARD\",\n    \"INTEL\",\n    \"LAND\",\n    \"MOBILE\",\n    \"RADAR\",\n    \"SCOUT\",\n    \"TECH1\",\n}\nUnitTemplate.weapons = nil\n\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 0.3, y = 0.3 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0, z = 0 }\nUnitTemplate.visuals.animations = {\n    agro = {\n        clipName = \"AnimAgro\",\n        sanAnimationPath = \"Units/ugl1701/LOD0/ugl1701.sananimation\",\n    },\n    death = {\n        clipName = \"AnimDeath\",\n        sanAnimationPath = \"Units/ugl1701/LOD0/ugl1701.sananimation\",\n    },\n    walk = {\n        authoredSpeed = 0.48,\n        clipName = \"AnimWalk\",\n        sanAnimationPath = \"Units/ugl1701/LOD0/ugl1701.sananimation\",\n    },\n}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do\n            effect.boneName = \"Root\"\n        end\n    end\nend", ValidatePatchedUnit);
				QueueAppend(mutations, cachedResource2, "\n\n-- Supreme Commander Overhaul FA Cybran Land Scout 1.0.0\n-- Keep the template's stock GuardLandUnit class. This ID-gated wrapper\n-- delays only the Mole's stock wreck/delete path for one exact source\n-- Adeath play. The loader currently exposes clips as Loop; deletion at\n-- the 0.5-second source endpoint prevents an observable second cycle.\nlocal SCO_FaMoleCommands = Import(\"common/commands/definitions/units.lua\")\nlocal SCO_FaMoleStockCheckRadarState = HostGuardLandUnit.CheckRadarState\nfunction HostGuardLandUnit:CheckRadarState()\n    if self.tpId ~= \"ugl1701\" then\n        return SCO_FaMoleStockCheckRadarState(self)\n    end\n    if not self.radarDetector or self.progress == nil then\n        return\n    end\n\n    -- URL0101 creates and enables a separate, free RadarEnt. It has no\n    -- radar toggle and does not shut down on an army energy stall.\n    local isRadarActive = self:IsCompleted()\n    if self.radarDetector:GetEnabled() ~= isRadarActive then\n        self.radarDetector:SetEnabled(isRadarActive)\n        SCO_FaMoleCommands.SetRadarActive.Send(self.id, isRadarActive)\n    end\nend\n\nlocal SCO_FaMoleStockDeathThread = HostGuardLandUnit.DeathThread\nfunction HostGuardLandUnit:DeathThread(overkillRatio)\n    if self.tpId ~= \"ugl1701\" then\n        return SCO_FaMoleStockDeathThread(self, overkillRatio)\n    end\n\n    local animations = self.tp and self.tp.visuals and self.tp.visuals.animations\n    local death = animations and animations.death\n    if not death or not death.id then\n        error(\"UGL1701 Mole requires its hash-pinned AnimDeath clip\")\n    end\n    Engine.PlayAnimation(self.id, death.id, 0.1)\n    WaitSeconds(0.5)\n    return SCO_FaMoleStockDeathThread(self, overkillRatio)\nend", ValidatePatchedHost);
				Commit(obj, mutations);
				Log("Applied exact URL0101 Mole gameplay, Spinner, walk cadence, and source-bound death timing to class-preserved ugl1701.");
				break;
			}
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
			Log($"Failed to apply the FA Cybran land-scout transaction: {arg}");
			throw;
		}
	}

	private static void ValidatePinnedScope()
	{
		if ("c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26".Length != 64 || "720d62e6df71611d74225bbb397dac76de617770c7fdd9bcfb60cac32ae0c49a".Length != 64 || "70380ca0da6a1551186fc5ba2e54e7d57f9044845e8688614f91a3ca314373b1".Length != 64)
		{
			throw new InvalidOperationException("The reviewed URL0101 -> ugl1701 direct mapping or hash lock changed.");
		}
	}

	private static void ValidateStockUnit(string source)
	{
		RequireTokens(source, "tpId = \"ugl1701\"", "\"unitsDefaultGuard\"", "\"GuardLandUnit\"");
		if (!Regex.IsMatch(source, "class\\s*=\\s*\\{\\s*\"unitsDefaultGuard\"\\s*,\\s*\"GuardLandUnit\"\\s*,?\\s*\\}", RegexOptions.CultureInvariant))
		{
			throw new InvalidOperationException("UGL1701 no longer exposes its reviewed GuardLandUnit class.");
		}
	}

	private static void ValidateStockHost(string source)
	{
		RequireTokens(source, "HostGuardLandUnit = Class(\"GuardLandUnit\", LandUnit)", "local unitsDefault = Import(\"host/units/unitsClasses/unitsDefault.lua\")");
	}

	private static void ValidatePatchedUnit(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Land Scout 1.0.0", 1, "Mole unit marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "mapping = \"URL0101 -> ugl1701\"", "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", "720d62e6df71611d74225bbb397dac76de617770c7fdd9bcfb60cac32ae0c49a", "70380ca0da6a1551186fc5ba2e54e7d57f9044845e8688614f91a3ca314373b1", "UnitTemplate.general.name = \"Mole\"", "collisionSize = { x = 0.5, y = 0.3, z = 0.5 }", "UnitTemplate.footprint = { x = 0.5, y = 0.5 }", "max = 15, regen = 0, value = 15", "buildTime = 80", "cost = { alloys = 8, energy = 80 }", "UnitTemplate.intel = { radarRadius = 45, visionRadius = 24 }", "UnitTemplate.movement.type = \"LegsLand\"", "UnitTemplate.movement.acceleration = 4.8", "UnitTemplate.movement.deceleration = 4.8", "UnitTemplate.movement.rotationSpeed = 180", "UnitTemplate.movement.speed = 4.8", "authoredSpeed = 0.48", "boneName = \"Spinner\"", "speed = { x = 0, y = 90, z = 0 }", "clipName = \"AnimAgro\"", "clipName = \"AnimDeath\"", "clipName = \"AnimWalk\"", "UnitTemplate.weapons = nil", "sanctuaryCloakRuntimeSupported = false", "radarIsFree = true");
		RequireExactly(source2, "clipName = \"AnimAgro\"", 1, "unbound Aagro payload");
		RequireExactly(source2, "clipName = \"AnimDeath\"", 1, "death clip binding");
		RequireExactly(source2, "clipName = \"AnimWalk\"", 1, "walk clip binding");
		RequireNotContains(source2, "projectileTemplate", "aimControllers", "muzzleGroups", "AeonProjectiles");
	}

	private static void ValidatePatchedHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Cybran Land Scout 1.0.0", 1, "Mole host marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "local SCO_FaMoleCommands = Import(\"common/commands/definitions/units.lua\")", "local SCO_FaMoleStockCheckRadarState = HostGuardLandUnit.CheckRadarState", "function HostGuardLandUnit:CheckRadarState()", "local isRadarActive = self:IsCompleted()", "SCO_FaMoleCommands.SetRadarActive.Send(self.id, isRadarActive)", "local SCO_FaMoleStockDeathThread = HostGuardLandUnit.DeathThread", "function HostGuardLandUnit:DeathThread(overkillRatio)", "if self.tpId ~= \"ugl1701\" then", "Engine.PlayAnimation(self.id, death.id, 0.1)", "WaitSeconds(0.5)", "return SCO_FaMoleStockDeathThread(self, overkillRatio)");
		RequireExactly(source2, "Engine.PlayAnimation(self.id, death.id, 0.1)", 1, "Mole death playback");
		RequireExactly(source2, "WaitSeconds(0.5)", 1, "Mole death delay");
		RequireExactly(source2, "function HostGuardLandUnit:CheckRadarState()", 1, "Mole free-radar wrapper");
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
		return source.IndexOf("-- Supreme Commander Overhaul FA Cybran Land Scout 1.0.0", StringComparison.Ordinal) >= 0;
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
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Cybran Land Scout 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Mole marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul FA Cybran Land Scout 1.0.0".Length, StringComparison.Ordinal);
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
				throw new InvalidOperationException("Mole-owned Lua must not contain '" + text + "'.");
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
		string text = "[FA Cybran Land Scout Cache Patcher] " + message;
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
