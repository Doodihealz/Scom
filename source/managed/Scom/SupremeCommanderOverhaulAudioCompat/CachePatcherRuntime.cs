using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using ScomDeterministicLua;
using SupremeCommanderOverhaulCanonical;

namespace SupremeCommanderOverhaulAudioCompat;

public static class CachePatcherRuntime
{
	private sealed class CachedResource
	{
		public string Path { get; }

		public object Value { get; }

		public CachedResource(string path, object value)
		{
			Path = path;
			Value = value;
		}
	}

	private sealed class PendingSource
	{
		public CachedResource Resource { get; }

		public string OriginalSource { get; }

		public string PatchedSource { get; }

		public string Description { get; }

		public object Replacement { get; set; }

		public bool Changed => !string.Equals(OriginalSource, PatchedSource, StringComparison.Ordinal);

		public PendingSource(CachedResource resource, string originalSource, string patchedSource, string description)
		{
			Resource = resource;
			OriginalSource = originalSource;
			PatchedSource = patchedSource;
			Description = description;
		}
	}

	private sealed class AudioSourceCompatibilityException : InvalidOperationException
	{
		public AudioSourceCompatibilityException(string message)
			: base(message)
		{
		}
	}

	private sealed class CacheRollbackException : AggregateException
	{
		public CacheRollbackException(Exception transactionFailure, IEnumerable<Exception> rollbackFailures)
			: base("SCOM audio compatibility cache transaction failed and rollback was incomplete.", new Exception[1] { transactionFailure }.Concat<Exception>(rollbackFailures))
		{
		}
	}

	public const string Marker = "-- Supreme Commander Overhaul 0.0.1.10 Audio Compatibility 1.0.0";

	public const string ExpectedScomSha256 = "3EED7306200D5910786221547FF0FB959FA8CF92C85C99D62B98A12175C28B76";

	public const long ExpectedScomBytes = 3819520L;

	private const string RelativePath = "LJ/lua/client/units/unitsClasses/unitsBaseClass.lua";

	private const string UefTemplateRelativePath = "LJ/lua/common/units/unitsTemplates/uel0000/uel0000.santp";

	private const string HostUnitBaseRelativePath = "LJ/lua/host/units/unitsClasses/unitsBaseClass.lua";

	private const string SeraphimHostClassRelativePath = "LJ/lua/host/units/unitsClasses/unitsDefaultSeraphim.lua";

	private const string SeraphimGameplayMarkerPrefix = "-- Supreme Commander Overhaul Seraphim source gameplay 2.1 ";

	public const string SeraphimFactoryMarker = "-- Supreme Commander Overhaul Seraphim Land Factory Compatibility 1.0.0";

	public const string SeraphimDeathMarker = "-- Supreme Commander Overhaul Seraphim Death Animation Compatibility 1.0.0";

	public const string UefGroundingMarker = "-- Supreme Commander Overhaul UEF ACU Grounding Compatibility 1.0.0";

	private const string CombatStructureMarker = "-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0";

	private const string UnsafeRadarRotatorGate = "if SCO_FaCombatRadarIds[self.tpId] and self.radarDetector then";

	private const string SafeRadarRotatorGate = "if SCO_FaCombatRadarIds[self.tpId] and self.radarDetector and self.rotatorIds then";

	private const string UefTemplateMarker = "-- UEF ACU EDA Cache Patcher 2.4.2";

	private const string OldGuardMarker = "-- Supreme Commander Overhaul Guard ACU Engine Audio 1.0.0";

	private const string OldUefMarker = "-- Supreme Commander Overhaul UEF ACU Engine Audio 1.0.0";

	private const string OldStructureMarker = "-- Supreme Commander Overhaul Structure Persistent Audio 1.0.0";

	private static readonly string[] StructureIds = new string[34]
	{
		"ugs1611", "ugs2611", "ugs3611", "ugs2511", "ugs3511", "ugs2401", "ugs1701", "ugs2701", "ugs3701", "ues1511",
		"ues2511", "ues1611", "ues2611", "ues3611", "ues2401", "ues3401", "ues1701", "ues2701", "ues3701", "uss1511",
		"uss1512", "uss1611", "uss1701", "uss2401", "uss2511", "uss2512", "uss2611", "uss2701", "uss2711", "uss3401",
		"uss3511", "uss3512", "uss3611", "uss3701"
	};

	public static void Apply()
	{
		try
		{
			ValidateScomIdentity();
			object cache = GetLuaFileCache();
			List<PendingSource> list = new PendingSource[3]
			{
				CreatePendingSource(cache, "LJ/lua/host/units/unitsClasses/unitsBaseClass.lua", "Host unit-base source", PatchRadarLifecycleSource),
				CreatePendingSource(cache, "LJ/lua/common/units/unitsTemplates/uel0000/uel0000.santp", "UEF ACU template", PatchUefGroundingSource),
				CreatePendingSource(cache, "LJ/lua/host/units/unitsClasses/unitsDefaultSeraphim.lua", "Seraphim host class", PatchSeraphimHostSource)
			}.Concat<PendingSource>(SeraphimContracts.DeathAnimations.Select((DeathContract contract) => contract.Id).Concat<string>(SeraphimContracts.LandFactories.Select((LandFactoryContract contract) => contract.Id)).Distinct(StringComparer.Ordinal)
				.Select(delegate(string id)
				{
					string relativePath = SeraphimTemplateRelativePath(id);
					LandFactoryContract landFactoryContract = SeraphimContracts.LandFactories.SingleOrDefault((LandFactoryContract contract) => contract.Id == id);
					DeathContract deathContract = SeraphimContracts.DeathAnimations.SingleOrDefault((DeathContract contract) => contract.Id == id);
					return CreatePendingSource(cache, relativePath, id + " Seraphim template", (string source) => PatchSeraphimTemplateSource(source, id, landFactoryContract, deathContract));
				})).ToList();
			try
			{
				list.Add(CreatePendingSource(cache, "LJ/lua/client/units/unitsClasses/unitsBaseClass.lua", "Client unit-base source", PatchSource));
			}
			catch (AudioSourceCompatibilityException ex)
			{
				Log("WARNING: Skipped optional client audio compatibility; source unchanged. LJ/lua/client/units/unitsClasses/unitsBaseClass.lua: " + ex.Message);
			}
			if (!PublishCachedSources(cache, list.ToArray()))
			{
				Log("Required gameplay compatibility is already present; skipped audio edits, if any, are reported above.");
			}
			else
			{
				Log("Fixed all six SCOM radar lifecycles; restored Seraphim land-factory platforms/beams/pods; applied UEF grounding and Seraphim death-animation fixes; skipped audio edits, if any, are reported above.");
			}
		}
		catch (CacheRollbackException)
		{
			throw;
		}
		catch (Exception ex3)
		{
			Log("Required compatibility stage failed: " + ex3.GetBaseException().Message);
			throw;
		}
	}

	public static string PatchSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = source.Replace("\r\n", "\n").Replace("\r", "\n");
		int num = Count(text, "-- Supreme Commander Overhaul 0.0.1.10 Audio Compatibility 1.0.0");
		switch (num)
		{
		case 1:
			ValidatePatchedSource(text);
			return text;
		default:
			throw new AudioSourceCompatibilityException($"Expected zero or one audio compatibility markers, found {num}.");
		case 0:
		{
			RequireAudioExactly(text, "function ClientUnit:SetUpAudioSources()", 1);
			RequireAudioExactly(text, "self.motorAudio = AddAudioSource(self.tp.audio.engine, \"EngineAudioEntity\", false)", 1);
			RequireAudioExactly(text, "function ClientUnit:UpdateAudio(health, maxHealth)", 1);
			RequireAudioExactly(text, "self:SetAudioSourceEmitting(self.motorAudio, isAirUnit or currentSpeed > 0)", 1);
			RequireAudioExactly(text, "-- Supreme Commander Overhaul Guard ACU Engine Audio 1.0.0", 0);
			RequireAudioExactly(text, "-- Supreme Commander Overhaul UEF ACU Engine Audio 1.0.0", 0);
			RequireAudioExactly(text, "-- Supreme Commander Overhaul Structure Persistent Audio 1.0.0", 0);
			string text2 = text.TrimEnd(Array.Empty<char>()) + BuildAppendix() + "\n";
			ValidatePatchedSource(text2);
			return text2;
		}
		}
	}

	public static string PatchUefGroundingSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = source.Replace("\r\n", "\n").Replace("\r", "\n");
		int num = Count(text, "-- Supreme Commander Overhaul UEF ACU Grounding Compatibility 1.0.0");
		switch (num)
		{
		case 1:
			ValidateUefGroundingSource(text);
			return text;
		default:
			throw new InvalidOperationException($"Expected zero or one UEF grounding markers, found {num}.");
		case 0:
		{
			RequireExactly(text, "-- UEF ACU EDA Cache Patcher 2.4.2", 1);
			RequireExactly(text, "UnitTemplate.movement.type = \"LegsLand\"", 1);
			string text2 = text.TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul UEF ACU Grounding Compatibility 1.0.0\nUnitTemplate.movement.preferredAltitude = 0\nUnitTemplate.movement.referenceAltitude = \"Ground\"\n";
			ValidateUefGroundingSource(text2);
			return text2;
		}
		}
	}

	public static string PatchRadarLifecycleSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = source.Replace("\r\n", "\n").Replace("\r", "\n");
		RequireExactly(text, "-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0", 1);
		int num = Count(text, "if SCO_FaCombatRadarIds[self.tpId] and self.radarDetector then");
		int num2 = Count(text, "if SCO_FaCombatRadarIds[self.tpId] and self.radarDetector and self.rotatorIds then");
		if (num == 0 && num2 == 1)
		{
			return text;
		}
		if (num != 1 || num2 != 0)
		{
			throw new InvalidOperationException($"Expected one unsafe or one safe SCOM radar rotator gate; found unsafe={num}, safe={num2}.");
		}
		string text2 = text.Replace("if SCO_FaCombatRadarIds[self.tpId] and self.radarDetector then", "if SCO_FaCombatRadarIds[self.tpId] and self.radarDetector and self.rotatorIds then");
		ValidateRadarLifecycleSource(text2);
		return text2;
	}

	public static string PatchSeraphimTemplateSource(string source, string id)
	{
		LandFactoryContract landFactoryContract = SeraphimContracts.LandFactories.SingleOrDefault((LandFactoryContract contract) => contract.Id == id);
		DeathContract deathContract = SeraphimContracts.DeathAnimations.SingleOrDefault((DeathContract contract) => contract.Id == id);
		if (landFactoryContract == null && deathContract == null)
		{
			throw new InvalidOperationException("No Seraphim compatibility contract exists for " + id + ".");
		}
		return PatchSeraphimTemplateSource(source, id, landFactoryContract, deathContract);
	}

	internal static string PatchSeraphimTemplateSource(string source, string id, LandFactoryContract? factory, DeathContract? death)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = source.Replace("\r\n", "\n").Replace("\r", "\n");
		RequireExactly(text, "-- Supreme Commander Overhaul Seraphim source gameplay 2.1 " + id, 1);
		string text2 = "-- Supreme Commander Overhaul Seraphim Compatibility 1.0.0 " + id;
		int num = Count(text, text2);
		switch (num)
		{
		case 1:
			ValidateSeraphimTemplate(text, id, factory, death, text2);
			return text;
		default:
			throw new InvalidOperationException($"Expected zero or one Seraphim compatibility markers for {id}, found {num}.");
		case 0:
		{
			StringBuilder stringBuilder = new StringBuilder();
			stringBuilder.Append("\n\n").Append(text2).Append('\n');
			if (factory != null)
			{
				stringBuilder.Append(BuildLandFactoryTemplateAppendix(factory));
			}
			if (death != null)
			{
				stringBuilder.Append(BuildDeathTemplateAppendix(death));
			}
			string text3 = text.TrimEnd(Array.Empty<char>()) + stringBuilder?.ToString() + "\n";
			ValidateSeraphimTemplate(text3, id, factory, death, text2);
			return text3;
		}
		}
	}

	public static string PatchSeraphimHostSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = source.Replace("\r\n", "\n").Replace("\r", "\n");
		switch (Count(text, "-- Supreme Commander Overhaul Seraphim Land Factory Compatibility 1.0.0"))
		{
		case 1:
			ValidateSeraphimHostSource(text);
			return text;
		case 0:
			if (Count(text, "-- Supreme Commander Overhaul Seraphim Death Animation Compatibility 1.0.0") == 0)
			{
				RequireExactly(text, "local SeraphimLandFactory = HostSeraphimLandFactory", 1);
				RequireExactly(text, "function SeraphimLandFactory:OnStartBuildRoutine(targetUnit)", 1);
				RequireExactly(text, "function SeraphimLandFactory:OnStopBuildRoutine(targetUnit)", 1);
				RequireExactly(text, "local SeraphimHostOrderManager = Import(\"host/managers/orders/hostOrderManager.lua\")", 1);
				string text2 = text.TrimEnd(Array.Empty<char>()) + BuildSeraphimHostAppendix() + "\n";
				ValidateSeraphimHostSource(text2);
				return text2;
			}
			break;
		}
		throw new InvalidOperationException("Seraphim host compatibility marker count drifted.");
	}

	private static string BuildLandFactoryTemplateAppendix(LandFactoryContract factory)
	{
		string text = string.Join("\n", factory.Rotators.Select(((string Bone, double Speed) rotator) => "    { boneName = \"" + rotator.Bone + "\", speed = { x = 0, y = " + Lua(rotator.Speed) + ", z = 0 }, isVelocityScalingEnabled = false },"));
		return "-- Supreme Commander Overhaul Seraphim Land Factory Compatibility 1.0.0\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.platformBoneName = \"Attachpoint\"\nUnitTemplate.construction.beam = UnitTemplate.construction.beam or {}\nUnitTemplate.construction.beam.boneName = \"Muzzle01\"\nUnitTemplate.construction.beam.offset = { x = 0, y = 0, z = 0 }\nUnitTemplate.construction.beam.shrink = 0.6\nUnitTemplate.construction.rollOffPoints = {\n    { offset = { x = 2.75, y = 0, z = " + Lua(factory.RollOffZ) + " }, platformOffset = { x = 0, y = 0, z = 0 }, rollOffTime = 2, unitSpin = 90 },\n    { offset = { x = -2.75, y = 0, z = " + Lua(factory.RollOffZ) + " }, platformOffset = { x = 0, y = 0, z = 0 }, rollOffTime = 2, unitSpin = -90 },\n}\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.buildBeamBones = { \"Muzzle01\" }\nUnitTemplate.additions.rotators = {\n" + text + "\n}\nUnitTemplate.additions.seraphimLandFactoryRamps = {\n    { rampOffset = { x = 2.75, y = 0, z = " + Lua(factory.RollOffZ) + " }, clearanceOffset = { x = 5, y = 0, z = " + Lua(factory.RollOffZ) + " }, headingDegrees = 90 },\n    { rampOffset = { x = -2.75, y = 0, z = " + Lua(factory.RollOffZ) + " }, clearanceOffset = { x = -5, y = 0, z = " + Lua(factory.RollOffZ) + " }, headingDegrees = -90 },\n}\n";
	}

	private static string BuildDeathTemplateAppendix(DeathContract death)
	{
		string text = string.Join("\n", death.Clips.Select((DeathClip clip) => "    { key = \"" + clip.Key + "\", weight = " + clip.Weight + ", durationSeconds = " + Lua(clip.Duration) + ", rateMinTenths = " + Math.Round((clip.RateMin ?? 1.0) * 10.0).ToString(CultureInfo.InvariantCulture) + ", rateMaxTenths = " + Math.Round((clip.RateMax ?? 1.0) * 10.0).ToString(CultureInfo.InvariantCulture) + " },"));
		string text2 = string.Join("\n", death.Clips.Select((DeathClip clip) => "UnitTemplate.visuals.animations." + clip.Key + ".playbackMode = 0"));
		return "-- Supreme Commander Overhaul Seraphim Death Animation Compatibility 1.0.0\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.animations = UnitTemplate.visuals.animations or {}\n" + text2 + "\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.seraphimDeathAnimations = {\n" + text + "\n}\n";
	}

	private static string BuildSeraphimHostAppendix()
	{
		string[] source = SeraphimContracts.DeathAnimations.Select((DeathContract contract) => contract.ClassName).Distinct<string>(StringComparer.Ordinal).OrderBy<string, string>((string name) => name, StringComparer.Ordinal)
			.ToArray();
		string text = string.Join("\n", source.Select((string name) => "SCO_SeraphimInstallDeathThread(" + name + ", \"" + name + "\")"));
		return "\n\n-- Supreme Commander Overhaul Seraphim Land Factory Compatibility 1.0.0\nlocal function SCO_SeraphimFactoryAlive(unit)\n    return unit ~= nil and not unit.dead and not unit.deleted\nend\n\nlocal function SCO_SeraphimFactoryTargetKey(target)\n    return target and target.id\n        and (tostring(target.id.index) .. \":\" .. tostring(target.id.version))\nend\n\nlocal function SCO_SeraphimFactoryRamps(factory)\n    local additions = factory.tp and factory.tp.additions\n    return additions and additions.seraphimLandFactoryRamps or {}\nend\n\nlocal function SCO_SeraphimFactoryPosition(factory, offset)\n    local position = factory:GetPosition()\n    return EngineClasses.float3(\n        position.x + (offset.x or 0),\n        position.y + (offset.y or 0),\n        position.z + (offset.z or 0))\nend\n\nlocal function SCO_SeraphimSelectRamp(factory, target)\n    local ramps = SCO_SeraphimFactoryRamps(factory)\n    if #ramps == 0 then return nil end\n    local key = SCO_SeraphimFactoryTargetKey(target)\n    factory.scoSeraphimRampByTarget = factory.scoSeraphimRampByTarget or {}\n    local index = key and factory.scoSeraphimRampByTarget[key]\n    if not index then\n        local source = factory.unitBeingBuiltSource or factory\n        if source.rallyPoint then\n            local bestDistance = nil\n            for candidateIndex, ramp in ipairs(ramps) do\n                local point = SCO_SeraphimFactoryPosition(factory, ramp.clearanceOffset)\n                local dx = point.x - source.rallyPoint.x\n                local dz = point.z - source.rallyPoint.z\n                local distance = dx * dx + dz * dz\n                if not bestDistance or distance < bestDistance then\n                    bestDistance = distance\n                    index = candidateIndex\n                end\n            end\n        else index = 1 end\n        if key then factory.scoSeraphimRampByTarget[key] = index end\n    end\n    return ramps[index]\nend\n\nlocal function SCO_SeraphimFaceRamp(target, ramp)\n    if not SCO_SeraphimFactoryAlive(target) or not ramp then return end\n    Engine.SetGlobalEntityLocalRotation(target.id, Engine.EulerToQuaternion(\n        EngineClasses.float3(0, math.rad(ramp.headingDegrees), 0),\n        RotationOrder.Default))\nend\n\nfunction SeraphimLandFactory:RotatorsEnabledOnConstruction()\n    return true\nend\n\nfunction SeraphimLandFactory:OnStartBuildRoutine(target)\n    if SCO_SeraphimFactoryAlive(target)\n        and target:HasTags(Tags.MOBILE)\n        and not target:IsCompleted()\n    then\n        self.scoSeraphimPinnedTarget = target\n        target.scoFactoryColliderPinOwner = self\n        Engine.SetVolumeColliderEnabled(target.id, false)\n    end\n    ChosenLandFactory.OnStartBuildRoutine(self, target)\n    SCO_SeraphimFaceRamp(target, SCO_SeraphimSelectRamp(self, target))\n    if SCO_SeraphimFactoryAlive(target) and target:HasTags(Tags.MOBILE) then\n        Engine.SetVolumeColliderEnabled(target.id, false)\n    end\nend\n\nfunction SeraphimLandFactory:OnStopBuildRoutine(target)\n    local completed = SCO_SeraphimFactoryAlive(target)\n        and target:HasTags(Tags.MOBILE)\n        and target:IsCompleted()\n    local ramp = completed and SCO_SeraphimSelectRamp(self, target)\n    if completed and ramp then\n        SCO_SeraphimFaceRamp(target, ramp)\n        local point = SCO_SeraphimFactoryPosition(self, ramp.clearanceOffset)\n        local _, terrainHeight = Engine.SampleTerrainHeight(point)\n        point.y = terrainHeight\n        target:SetPosition(point)\n        target.scoFactoryColliderPinOwner = nil\n        self.scoSeraphimPinnedTarget = nil\n        Engine.SetVolumeColliderEnabled(target.id, true)\n    end\n    ChosenLandFactory.OnStopBuildRoutine(self, target)\nend\n\nfunction SeraphimLandFactory:RollOffUnit(target)\n    local ramp = SCO_SeraphimSelectRamp(self, target)\n    if not ramp then\n        return ChosenLandFactory.RollOffUnit(self, target)\n    end\n    if SCO_SeraphimFactoryAlive(target) and target.scoFactoryColliderPinOwner == self then\n        local point = SCO_SeraphimFactoryPosition(self, ramp.clearanceOffset)\n        local _, terrainHeight = Engine.SampleTerrainHeight(point)\n        point.y = terrainHeight\n        SCO_SeraphimFaceRamp(target, ramp)\n        target:SetPosition(point)\n        target.scoFactoryColliderPinOwner = nil\n        self.scoSeraphimPinnedTarget = nil\n        Engine.SetVolumeColliderEnabled(target.id, true)\n    end\n    local source = self.unitBeingBuiltSource or self\n    if source.rallyPoint then\n        SeraphimHostOrderManager.HostIssueOrder(\n            SeraphimOrderTasks.MOVE, { target }, false, source.rallyPoint, nil)\n    end\n    local key = SCO_SeraphimFactoryTargetKey(target)\n    if key and self.scoSeraphimRampByTarget then\n        self.scoSeraphimRampByTarget[key] = nil\n    end\nend\n\nfunction SeraphimLandFactory:ProductionBehaviorStop()\n    local target = self.scoSeraphimPinnedTarget\n    if SCO_SeraphimFactoryAlive(target) and target.scoFactoryColliderPinOwner == self then\n        target.scoFactoryColliderPinOwner = nil\n    end\n    self.scoSeraphimPinnedTarget = nil\n    ChosenLandFactory.ProductionBehaviorStop(self)\n    if not self.dead and not self.deleted then self:SetRotatorsEnabled(true) end\nend\n\n-- Supreme Commander Overhaul Seraphim Death Animation Compatibility 1.0.0\nlocal SCO_SeraphimDeathSentinel = -10000\n\nlocal function SCO_SeraphimSelectDeath(configs)\n    local total = 0\n    for _, config in ipairs(configs) do total = total + config.weight end\n    local selected = math.random(0, total)\n    local accumulated = 1\n    for _, config in ipairs(configs) do\n        accumulated = accumulated + config.weight\n        if selected < accumulated then return config end\n    end\n    return nil\nend\n\nlocal function SCO_SeraphimDeathThread(unit, inherited, overkillRatio)\n    local configs = unit.tp.additions and unit.tp.additions.seraphimDeathAnimations\n    if not configs or #configs == 0 or not unit:IsCompleted() then\n        return inherited(unit, overkillRatio)\n    end\n    local config = SCO_SeraphimSelectDeath(configs)\n    local animations = unit.tp.visuals and unit.tp.visuals.animations\n    local animation = config and animations and animations[config.key]\n    if not animation or not animation.id then\n        return inherited(unit, overkillRatio)\n    end\n    local rateMin = config.rateMinTenths or 10\n    local rateMax = config.rateMaxTenths or 10\n    local rate = math.random(rateMin, rateMax) / 10\n    local elapsed = 0\n    while not unit.deleted and elapsed < config.durationSeconds do\n        Engine.PlayAnimation(unit.id, animation.id, SCO_SeraphimDeathSentinel + elapsed)\n        local wallStep = math.min(0.1, (config.durationSeconds - elapsed) / rate)\n        if wallStep <= 0 then break end\n        WaitSeconds(wallStep)\n        elapsed = math.min(config.durationSeconds, elapsed + wallStep * rate)\n    end\n    if not unit.deleted then\n        Engine.PlayAnimation(unit.id, animation.id,\n            SCO_SeraphimDeathSentinel + config.durationSeconds)\n        return inherited(unit, overkillRatio)\n    end\nend\n\nlocal function SCO_SeraphimInstallDeathThread(class, name)\n    local inherited = class.DeathThread\n    if type(inherited) ~= \"function\" then\n        error(\"Seraphim death compatibility has no inherited DeathThread for \" .. name)\n    end\n    function class:DeathThread(overkillRatio)\n        return SCO_SeraphimDeathThread(self, inherited, overkillRatio)\n    end\nend\n\n" + text;
	}

	private static string BuildAppendix()
	{
		string text = string.Join("\n", StructureIds.Select((string id) => "    " + id + " = true,"));
		return "\n\n-- Supreme Commander Overhaul 0.0.1.10 Audio Compatibility 1.0.0\n-- SetUpEngineAudio became SetUpAudioSources and engineAudioLocalId became\n-- motorAudio. UpdateAudio now natively gates motor audio by movement, so the\n-- old UEF commander wrapper is intentionally obsolete.\nlocal SCO_AudioCompatStructureIds = {\n" + text + "\n}\n\nlocal SCO_AudioCompatStockSetUpAudioSources = ClientUnit.SetUpAudioSources\n\nlocal function SCO_AudioCompatDisable(source)\n    if source and source.localId then\n        Engine.SetAudioSourceCanEmitPersistentSound(source.localId, false)\n        source.emitting = false\n    end\nend\n\nfunction ClientUnit:SetUpAudioSources()\n    SCO_AudioCompatStockSetUpAudioSources(self)\n\n    -- URL0001 has no authored engine source. Disable the inherited donor\n    -- source and remove only the motor role so UpdateAudio cannot re-enable it.\n    if self.tpId == \"ugl0000\" then\n        SCO_AudioCompatDisable(self.motorAudio)\n        self.motorAudio = nil\n    end\n\n    if not SCO_AudioCompatStructureIds[self.tpId]\n        or not self:HasTags(Tags.STRUCTURE) then\n        return\n    end\n\n    local audio = self.tp and self.tp.audio\n    if audio and audio.active and audio.active.looping then\n        SCO_AudioCompatDisable(self.activeAudio)\n        self.activeAudio = nil\n    end\n    if audio and audio.engine and audio.engine.looping then\n        SCO_AudioCompatDisable(self.motorAudio)\n        self.motorAudio = nil\n    end\n\n    for _, shield in ipairs(self.shields or {}) do\n        if shield.audio and shield.audio.looping then\n            Engine.SetAudioSourceCanEmitPersistentSound(shield.localId, false)\n            shield.audio = nil\n        end\n    end\nend";
	}

	private static void ValidatePatchedSource(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul 0.0.1.10 Audio Compatibility 1.0.0", 1);
		RequireExactly(source, "local SCO_AudioCompatStockSetUpAudioSources = ClientUnit.SetUpAudioSources", 1);
		RequireExactly(source, "SCO_AudioCompatStockSetUpAudioSources(self)", 1);
		RequireExactly(source, "if self.tpId == \"ugl0000\" then", 1);
		RequireExactly(source, "self.motorAudio = nil", 2);
		RequireExactly(source, "self.activeAudio = nil", 1);
		RequireExactly(source, "shield.audio = nil", 1);
		string text = source.Substring(source.IndexOf("-- Supreme Commander Overhaul 0.0.1.10 Audio Compatibility 1.0.0", StringComparison.Ordinal));
		if (Count(text, " = true,") != StructureIds.Length)
		{
			throw new InvalidOperationException("Structure audio target count drifted.");
		}
		if (text.IndexOf("uel0000", StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("Native UEF movement audio was overridden.");
		}
	}

	private static void ValidateUefGroundingSource(string source)
	{
		RequireExactly(source, "-- UEF ACU EDA Cache Patcher 2.4.2", 1);
		RequireExactly(source, "-- Supreme Commander Overhaul UEF ACU Grounding Compatibility 1.0.0", 1);
		RequireExactly(source, "UnitTemplate.movement.type = \"LegsLand\"", 1);
		RequireExactly(source, "UnitTemplate.movement.preferredAltitude = 0", 1);
		RequireExactly(source, "UnitTemplate.movement.referenceAltitude = \"Ground\"", 1);
		int num = source.IndexOf("-- UEF ACU EDA Cache Patcher 2.4.2", StringComparison.Ordinal);
		if (source.IndexOf("-- Supreme Commander Overhaul UEF ACU Grounding Compatibility 1.0.0", StringComparison.Ordinal) <= num)
		{
			throw new InvalidOperationException("UEF grounding does not follow the SCOM UEF override.");
		}
		if (!source.TrimEnd(Array.Empty<char>()).EndsWith("-- Supreme Commander Overhaul UEF ACU Grounding Compatibility 1.0.0\nUnitTemplate.movement.preferredAltitude = 0\nUnitTemplate.movement.referenceAltitude = \"Ground\"", StringComparison.Ordinal))
		{
			throw new InvalidOperationException("UEF grounding is not the final movement writer.");
		}
	}

	private static void ValidateRadarLifecycleSource(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0", 1);
		RequireExactly(source, "if SCO_FaCombatRadarIds[self.tpId] and self.radarDetector then", 0);
		RequireExactly(source, "if SCO_FaCombatRadarIds[self.tpId] and self.radarDetector and self.rotatorIds then", 1);
		string[] array = new string[6] { "ugs1701", "ugs2701", "ugs3701", "ues1701", "ues2701", "ues3701" };
		foreach (string text in array)
		{
			RequireExactly(source, "[\"" + text + "\"] = true", 1);
		}
		RequireExactly(source, "self:SetRotatorsEnabled(self.radarDetector:GetEnabled())", 1);
	}

	private static void ValidateSeraphimTemplate(string source, string id, LandFactoryContract? factory, DeathContract? death, string marker)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Seraphim source gameplay 2.1 " + id, 1);
		RequireExactly(source, marker, 1);
		int num = source.IndexOf("-- Supreme Commander Overhaul Seraphim source gameplay 2.1 " + id, StringComparison.Ordinal);
		if (source.IndexOf(marker, StringComparison.Ordinal) <= num)
		{
			throw new InvalidOperationException(id + " Seraphim compatibility is not the final writer.");
		}
		string text = source;
		source = text.Substring(text.IndexOf(marker, StringComparison.Ordinal));
		if (factory != null)
		{
			RequireExactly(source, "-- Supreme Commander Overhaul Seraphim Land Factory Compatibility 1.0.0", 1);
			RequireExactly(source, "UnitTemplate.construction.platformBoneName = \"Attachpoint\"", 1);
			RequireExactly(source, "UnitTemplate.construction.beam.boneName = \"Muzzle01\"", 1);
			RequireExactly(source, "UnitTemplate.construction.beam.shrink = 0.6", 1);
			RequireExactly(source, "UnitTemplate.additions.buildBeamBones = { \"Muzzle01\" }", 1);
			(string, double)[] rotators = factory.Rotators;
			for (int i = 0; i < rotators.Length; i++)
			{
				(string, double) tuple = rotators[i];
				RequireExactly(source, "boneName = \"" + tuple.Item1 + "\"", 1);
			}
		}
		if (death != null)
		{
			RequireExactly(source, "-- Supreme Commander Overhaul Seraphim Death Animation Compatibility 1.0.0", 1);
			RequireExactly(source, "UnitTemplate.additions.seraphimDeathAnimations = {", 1);
			DeathClip[] clips = death.Clips;
			foreach (DeathClip deathClip in clips)
			{
				RequireExactly(source, "UnitTemplate.visuals.animations." + deathClip.Key + ".playbackMode = 0", 1);
				RequireExactly(source, "key = \"" + deathClip.Key + "\"", 1);
			}
		}
	}

	private static void ValidateSeraphimHostSource(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Seraphim Land Factory Compatibility 1.0.0", 1);
		RequireExactly(source, "-- Supreme Commander Overhaul Seraphim Death Animation Compatibility 1.0.0", 1);
		RequireExactly(source, "function SeraphimLandFactory:RotatorsEnabledOnConstruction()", 1);
		RequireExactly(source, "function SeraphimLandFactory:OnStartBuildRoutine(target)", 1);
		RequireExactly(source, "function SeraphimLandFactory:OnStopBuildRoutine(target)", 1);
		RequireExactly(source, "function SeraphimLandFactory:RollOffUnit(target)", 1);
		RequireExactly(source, "target.scoFactoryColliderPinOwner = self", 1);
		RequireExactly(source, "Engine.EulerToQuaternion(", 1);
		RequireExactly(source, "RotationOrder.Default", 1);
		RequireExactly(source, "Engine.SetGlobalEntityLocalRotation(target.id,", 1);
		RequireExactly(source, "target:SetOrientation(", 0);
		RequireExactly(source, "local SCO_SeraphimDeathSentinel = -10000", 1);
		RequireExactly(source, "while not unit.deleted and elapsed < config.durationSeconds do", 1);
		RequireExactly(source, "local rate = math.random(rateMin, rateMax) / 10", 1);
		RequireExactly(source, "SCO_SeraphimInstallDeathThread(", 10);
	}

	private static string SeraphimTemplateRelativePath(string id)
	{
		return "LJ/lua/common/units/unitsTemplates/" + id + "/" + id + ".santp";
	}

	private static string Lua(double value)
	{
		return StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture);
	}

	private static void ValidateScomIdentity()
	{
		CanonicalAssemblyContract.RequireCanonicalTypes("SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime", "SupremeCommanderOverhaulAudioCompat.CachePatcherRuntime");
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("EM.Lua.FilesCache is unavailable.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua cache.");
	}

	private static CachedResource GetCachedResource(object cache, string relativePath, string description)
	{
		string value = "/" + relativePath.Replace('\\', '/');
		CachedResource cachedResource = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type = item.GetType();
			if (type.GetProperty("Key")?.GetValue(item, null) is string text && text.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (cachedResource != null)
				{
					throw new InvalidOperationException("Multiple " + description + " entries were cached.");
				}
				object value2 = type.GetProperty("Value")?.GetValue(item, null) ?? throw new InvalidOperationException("Cached " + description + " has no value.");
				cachedResource = new CachedResource(text, value2);
			}
		}
		return cachedResource ?? throw new FileNotFoundException(description + " is not cached.");
	}

	private static PendingSource CreatePendingSource(object cache, string relativePath, string description, Func<string, string> transform)
	{
		CachedResource cachedResource = GetCachedResource(cache, relativePath, description);
		string text = ReadText(cachedResource.Value);
		return new PendingSource(cachedResource, text, transform(text), description);
	}

	private static bool PublishCachedSources(object cache, PendingSource[] pendingSources)
	{
		PendingSource[] array = pendingSources.Where((PendingSource pendingSource7) => pendingSource7.Changed).ToArray();
		if (array.Length == 0)
		{
			return false;
		}
		PropertyInfo propertyInfo = cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item");
		PendingSource[] array2;
		try
		{
			array2 = array;
			foreach (PendingSource pendingSource in array2)
			{
				pendingSource.Replacement = CreatePersistent(pendingSource.Resource.Value.GetType(), pendingSource.PatchedSource);
			}
		}
		catch
		{
			array2 = array;
			foreach (PendingSource pendingSource2 in array2)
			{
				TryDispose(pendingSource2.Replacement, "prepared replacement for " + pendingSource2.Description);
			}
			throw;
		}
		List<PendingSource> list = new List<PendingSource>();
		try
		{
			array2 = array;
			foreach (PendingSource pendingSource3 in array2)
			{
				list.Add(pendingSource3);
				propertyInfo.SetValue(cache, pendingSource3.Replacement, new object[1] { pendingSource3.Resource.Path });
				VerifyCachedSource(cache, propertyInfo, pendingSource3.Resource.Path, pendingSource3.PatchedSource, "Published " + pendingSource3.Description);
			}
		}
		catch (Exception transactionFailure)
		{
			List<Exception> list2 = new List<Exception>();
			HashSet<PendingSource> hashSet = new HashSet<PendingSource>();
			for (int num2 = list.Count - 1; num2 >= 0; num2--)
			{
				PendingSource pendingSource4 = list[num2];
				try
				{
					propertyInfo.SetValue(cache, pendingSource4.Resource.Value, new object[1] { pendingSource4.Resource.Path });
					VerifyCachedSource(cache, propertyInfo, pendingSource4.Resource.Path, pendingSource4.OriginalSource, "Rolled-back " + pendingSource4.Description);
					hashSet.Add(pendingSource4);
				}
				catch (Exception innerException)
				{
					list2.Add(new InvalidOperationException("Failed to roll back " + pendingSource4.Description + ".", innerException));
				}
			}
			array2 = array;
			foreach (PendingSource pendingSource5 in array2)
			{
				if (!list.Contains(pendingSource5) || hashSet.Contains(pendingSource5))
				{
					TryDispose(pendingSource5.Replacement, "rolled-back replacement for " + pendingSource5.Description);
				}
			}
			if (list2.Count != 0)
			{
				throw new CacheRollbackException(transactionFailure, list2);
			}
			throw;
		}
		array2 = array;
		foreach (PendingSource pendingSource6 in array2)
		{
			TryDispose(pendingSource6.Resource.Value, "superseded original for " + pendingSource6.Description);
		}
		return true;
	}

	private static void VerifyCachedSource(object cache, PropertyInfo indexer, string path, string expectedSource, string description)
	{
		if (!string.Equals(ReadText(indexer.GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException(description + " was unavailable.")), expectedSource, StringComparison.Ordinal))
		{
			throw new InvalidOperationException(description + " failed readback.");
		}
	}

	private static string ReadText(object nativeArray)
	{
		byte[] bytes = ((nativeArray.GetType().GetMethod("ToArray", Type.EmptyTypes) ?? throw new MissingMethodException(nativeArray.GetType().FullName, "ToArray")).Invoke(nativeArray, null) as byte[]) ?? throw new InvalidOperationException("NativeArray.ToArray returned no bytes.");
		return Encoding.UTF8.GetString(bytes);
	}

	private static object CreatePersistent(Type nativeArrayType, string source)
	{
		Type type = nativeArrayType.Assembly.GetType("Unity.Collections.Allocator", throwOnError: false) ?? throw new TypeLoadException("Unity.Collections.Allocator is unavailable.");
		return (nativeArrayType.GetConstructor(new Type[2]
		{
			typeof(byte[]),
			type
		}) ?? throw new MissingMethodException(nativeArrayType.FullName, ".ctor(byte[], Allocator)")).Invoke(new object[2]
		{
			Encoding.UTF8.GetBytes(source),
			Enum.Parse(type, "Persistent")
		});
	}

	private static void Dispose(object nativeArray)
	{
		object value = (nativeArray.GetType().GetProperty("IsCreated") ?? throw new MissingMemberException(nativeArray.GetType().FullName, "IsCreated")).GetValue(nativeArray, null);
		bool flag = false;
		int num;
		if (value is bool)
		{
			flag = (bool)value;
			num = 1;
		}
		else
		{
			num = 0;
		}
		if (((uint)num & (flag ? 1u : 0u)) != 0)
		{
			(nativeArray.GetType().GetMethod("Dispose", Type.EmptyTypes) ?? throw new MissingMethodException(nativeArray.GetType().FullName, "Dispose")).Invoke(nativeArray, null);
		}
	}

	private static void TryDispose(object nativeArray, string description)
	{
		if (nativeArray == null)
		{
			return;
		}
		try
		{
			Dispose(nativeArray);
		}
		catch (Exception ex)
		{
			Log("NativeArray cleanup warning for " + description + ": " + ex.GetBaseException().Message);
		}
	}

	private static void RequireAudioExactly(string source, string token, int expected)
	{
		int num = Count(source, token);
		if (num != expected)
		{
			throw new AudioSourceCompatibilityException($"Expected {expected} occurrence(s) of '{token}', found {num}.");
		}
	}

	private static void RequireExactly(string source, string token, int expected)
	{
		int num = Count(source, token);
		if (num != expected)
		{
			throw new InvalidOperationException($"Expected {expected} occurrence(s) of '{token}', found {num}.");
		}
	}

	private static int Count(string source, string token)
	{
		int num = 0;
		int startIndex = 0;
		while ((startIndex = source.IndexOf(token, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += token.Length;
		}
		return num;
	}

	private static void Log(string message)
	{
		Console.WriteLine("[SCOM Audio Compatibility] " + message);
	}
}
