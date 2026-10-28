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
using SupremeCommanderOverhaulCachePatcher;

namespace FaEngineerWaterAnimationsCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class EngineerSpec
	{
		public string TargetId { get; }

		public string SourceId { get; }

		public string BlueprintSha256 { get; }

		public string ScriptSha256 { get; }

		public string WheelsSha256 { get; }

		public string AnimationSha256 { get; }

		public int WaterFrames { get; }

		public double WaterDuration { get; }

		public bool IsUef { get; }

		public string? TransformSha256 { get; }

		public string TemplatePath => "LJ/lua/common/units/unitsTemplates/" + TargetId + "/" + TargetId + ".santp";

		public double BuildCloseSeconds
		{
			get
			{
				if (IsUef)
				{
					if (!(TargetId == "uel1501"))
					{
						return 0.4000000059604645;
					}
					return 0.3333333134651184;
				}
				return 0.0;
			}
		}

		public string WaterDurationLiteral
		{
			get
			{
				if (!IsUef)
				{
					return "0.8999999761581421";
				}
				return "1.6666666269302368";
			}
		}

		public string BuildCloseSecondsLiteral
		{
			get
			{
				if (IsUef)
				{
					if (!(TargetId == "uel1501"))
					{
						return "0.4000000059604645";
					}
					return "0.3333333134651184";
				}
				return "0";
			}
		}

		public EngineerSpec(string targetId, string sourceId, string blueprintSha256, string scriptSha256, string wheelsSha256, string animationSha256, int waterFrames, double waterDuration, bool isUef, string? transformSha256)
		{
			TargetId = targetId;
			SourceId = sourceId;
			BlueprintSha256 = blueprintSha256;
			ScriptSha256 = scriptSha256;
			WheelsSha256 = wheelsSha256;
			AnimationSha256 = animationSha256;
			WaterFrames = waterFrames;
			WaterDuration = waterDuration;
			IsUef = isUef;
			TransformSha256 = transformSha256;
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

	internal const string OverrideMarker = "-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0";

	internal const string PackageSha256 = "feb5dbaa525a32f6987734620efe3f4643cb17e5a234e4518f8180b06704d11f";

	internal const string UnitsArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	internal const string LuaArchiveSha256 = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb";

	internal const string CybranUnitsLuaSha256 = "f126ce26875ef8b51f240296af8bd0d86ff07e3fc4b2a5ebf0a5ba4478687411";

	internal const string TerranUnitsLuaSha256 = "4cf1990c6320b3999bd86edb2e0bba0a543942ae58e808cb41cf05c469d35b5e";

	private const string EngineerMarker = "-- Guard/EDA Engineer Cache Patcher 1.2.1";

	private const string StructuresMarker = "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1";

	private const string AirFactoriesMarker = "-- Supreme Commander Overhaul FA Air Factories 1.0.0";

	private const string UnitLoaderPath = "LJ/lua/common/loading/unitTemplateLoader.lua";

	private const string HostDefaultPath = "LJ/lua/host/units/unitsClasses/unitsDefault.lua";

	private const string HostGuardPath = "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua";

	private const string HostEdaPath = "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua";

	private static readonly EngineerSpec[] Engineers = new EngineerSpec[6]
	{
		new EngineerSpec("ugl1501", "URL0105", "3eb677289b63514a1152a1328f899d7a8a88bdc549a3556bb77cd3562508ac8e", "39de5d1c7b1f97f8c4294c45d9edb7a958f0cff8f2d4653d5ee286c5378687f9", "4ab6dea31186e457030d13094d40e4c1e8e1e1969ed63f17373f86c4dd29c1bb", "66419a8e261d0b6f2630983eae5907a8c2a5d8606097419dd50b2ea2807d4d5a", 28, 0.8999999761581421, isUef: false, "2b1dbba7ca3901562622ee516135f9f716ea5bceba6f5972885fa3ea9059ea52"),
		new EngineerSpec("ugl2501", "URL0208", "eddd9987117e3cc3062b849c1de7be153cefada2581ab12404ff01a41025f807", "957785569c55c5cc0b992d22e55dd06f9585f3702c81e8726a4cbf9afef705a6", "b22f5638a2996d9d579558708c36532068d8009836bfad8fce2f35c3f83a1b97", "389f8aadbc4bcf477b2052e3ec01468bef5f202864471f45f3bd9e660d84450c", 28, 0.8999999761581421, isUef: false, "4631c0ebd36d4dbdf0d7fcc992ffb410ff3fdabf4fbded79a6c09171d5a9655a"),
		new EngineerSpec("ugl3501", "URL0309", "70ad5c542a3781bb25e0dda8c2d29bf8b699bed8f6ce5e6d6284826e6e4a0232", "80206def06b03e4ec47e92d7304b6813a46e37b717aad42bc853d9aed55310f5", "acc8961e61dc1091022de639317e71aa4adbdacf038906c6aa99f81259b444f8", "616769ea98f6ce14e7a612df4b8a8b4ae2048a07e50b40df351f2a722b9f7a80", 28, 0.8999999761581421, isUef: false, "30187773af22fee6b3fe0e1e132b9e8f72a83c1fcd2d44e2ffec3fff8743e9c6"),
		new EngineerSpec("uel1501", "UEL0105", "94daaf4535afafd99543deeb799b13c84f4a17312b6c9dab89ba954486deae2b", "c45d1e9b621eb5679e9ea6bf07c18bed5b655dbf8ea360efd97c773beb67b35c", "0970abfd894ab503582c65451f170472b512845324f0e670331518883d72a02b", "7e943b71a35220443810ee99ab27ec67c3523dd03e9694e452c8e4c9d4cc817e", 51, 1.6666666269302368, isUef: true, null),
		new EngineerSpec("uel2501", "UEL0208", "5e444a49c6a849aecab6d84b604f1957d58e148d0e5f89be56c4aed813198987", "4c357b4d1158e39d7a8f16a5a5f65958bea5e1fa30d062d1903675d331f70357", "bf419e97d5a6e41e1a9b760105e7788fd974c19fbc35bacab9b1f0cc327becc1", "af308597e2b0be3c3425d1959fc9822000d42260d79f3163aa48a45dd1d8004d", 51, 1.6666666269302368, isUef: true, null),
		new EngineerSpec("uel3501", "UEL0309", "7710ec8ac0c9c3157c516d24b7a91acc26914090870217aa8e80da46ad862ccb", "a84606264cf517151137026c6e12a8c47d2c19a36e02876b1f4a1ed77909ba49", "d651793a5b43601a38695f17551e2c925fe12657e7f38717afc13f253f71a687", "56b61afc4ecf1dc2edc7b4fbf8ec34a4deaa7df7643f4ac67caf6ef4a7a322f4", 51, 1.6666666269302368, isUef: true, null)
	};

	private const string HostLifecycleAppendix = "\n\n-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0\n-- FA CConstructionUnit/TConstructionUnit use one reversible Awheels animator.\n-- The coordinator sentinel stores exact clip seconds in currentClipTime and\n-- freezes automatic advancement, so interrupted shoreline reversal retains\n-- the same authored pose at deterministic simulation ticks.\nlocal SCOFaEngineerWaterSentinelBase = -10000\nlocal SCOFaEngineerWaterEnterDepth = 0.05\nlocal SCOFaEngineerWaterExitDepth = 0.01\nlocal SCOFaEngineerWaterLifecycle = {}\n\nlocal function SCOFaEngineerWaterAlive(unit)\n    return unit ~= nil and not unit.dead and not unit.deleted\nend\n\nlocal function SCOFaEngineerWaterConfig(unit)\n    local additions = unit.tp and unit.tp.additions\n    return additions and additions.faEngineerWaterAnimation\nend\n\nfunction SCOFaEngineerWaterLifecycle.IsSupported(unit)\n    local config = SCOFaEngineerWaterConfig(unit)\n    return config ~= nil and config.sourceRate == 1\nend\n\nfunction SCOFaEngineerWaterLifecycle.Probe(unit, previous, position)\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return nil end\n    if not hasWater then return false end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return nil end\n    local positionResult = Engine.GetGlobalEntityWorldPosition(unit.id, position)\n    if positionResult ~= EngineErrorCode.Success then return nil end\n    local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)\n    if terrainResult ~= EngineErrorCode.Success or terrainHeight == nil then return nil end\n    local requiredDepth = previous and SCOFaEngineerWaterExitDepth or SCOFaEngineerWaterEnterDepth\n    return terrainHeight < waterLevel - requiredDepth\nend\n\nfunction SCOFaEngineerWaterLifecycle.SampleThread(unit)\n    local config = SCOFaEngineerWaterConfig(unit)\n    local animations = unit.tp and unit.tp.visuals and unit.tp.visuals.animations\n    local water = animations and animations.waterTransform\n    if not config or not water or not water.id\n        or type(config.durationSeconds) ~= \"number\"\n        or config.durationSeconds <= 0\n        or config.durationSeconds >= 1000\n    then\n        error(\"FA engineer water-animation contract is incomplete\")\n    end\n\n    local elapsed = unit.scoFaEngineerWaterElapsed or 0\n    local inWater = unit.scoFaEngineerWaterState or false\n    local position = EngineClasses.float3()\n    local initialProbe = SCOFaEngineerWaterLifecycle.Probe(unit, inWater, position)\n    if initialProbe ~= nil then inWater = initialProbe end\n    unit.scoFaEngineerWaterElapsed = elapsed\n    unit.scoFaEngineerWaterState = inWater\n    Engine.PlayAnimation(unit.id, water.id, SCOFaEngineerWaterSentinelBase + elapsed)\n\n    while SCOFaEngineerWaterAlive(unit) do\n        WaitTicks(1)\n        if not SCOFaEngineerWaterAlive(unit) then break end\n        local probed = SCOFaEngineerWaterLifecycle.Probe(unit, inWater, position)\n        if probed ~= nil then\n            inWater = probed\n            unit.scoFaEngineerWaterState = inWater\n        end\n\n        local previousElapsed = elapsed\n        if inWater then\n            elapsed = math.min(config.durationSeconds, elapsed + Constants.TickTimeStep)\n        else\n            elapsed = math.max(0, elapsed - Constants.TickTimeStep)\n        end\n        unit.scoFaEngineerWaterElapsed = elapsed\n        if not unit.scoFaEngineerWaterSuspended\n            and (elapsed ~= previousElapsed or unit.scoFaEngineerWaterForceSample)\n        then\n            unit.scoFaEngineerWaterForceSample = nil\n            Engine.PlayAnimation(unit.id, water.id, SCOFaEngineerWaterSentinelBase + elapsed)\n        end\n    end\n    unit.scoFaEngineerWaterThread = nil\nend\n\nfunction SCOFaEngineerWaterLifecycle.Stop(unit)\n    if unit.scoFaEngineerWaterThread then KillThread(unit.scoFaEngineerWaterThread) end\n    if unit.scoFaEngineerWaterRestoreThread then KillThread(unit.scoFaEngineerWaterRestoreThread) end\n    unit.scoFaEngineerWaterThread = nil\n    unit.scoFaEngineerWaterRestoreThread = nil\n    unit.scoFaEngineerWaterElapsed = nil\n    unit.scoFaEngineerWaterState = nil\n    unit.scoFaEngineerWaterSuspended = nil\n    unit.scoFaEngineerWaterForceSample = nil\nend\n\nfunction SCOFaEngineerWaterLifecycle.Start(unit)\n    if not SCOFaEngineerWaterLifecycle.IsSupported(unit) then return end\n    SCOFaEngineerWaterLifecycle.Stop(unit)\n    unit.scoFaEngineerWaterElapsed = 0\n    unit.scoFaEngineerWaterState = false\n    unit.scoFaEngineerWaterThread = unit:NewThread(SCOFaEngineerWaterLifecycle.SampleThread)\nend\n\nfunction SCOFaEngineerWaterLifecycle.Suspend(unit)\n    if not SCOFaEngineerWaterLifecycle.IsSupported(unit) then return end\n    if unit.scoFaEngineerWaterRestoreThread then KillThread(unit.scoFaEngineerWaterRestoreThread) end\n    unit.scoFaEngineerWaterRestoreThread = nil\n    unit.scoFaEngineerWaterSuspended = true\nend\n\nfunction SCOFaEngineerWaterLifecycle.RestoreThread(unit, delay)\n    WaitSeconds(delay)\n    unit.scoFaEngineerWaterRestoreThread = nil\n    if not SCOFaEngineerWaterAlive(unit) then return end\n    unit.scoFaEngineerWaterSuspended = nil\n    unit.scoFaEngineerWaterForceSample = true\nend\n\nfunction SCOFaEngineerWaterLifecycle.ResumeAfter(unit, delay)\n    if not SCOFaEngineerWaterLifecycle.IsSupported(unit) then return end\n    if unit.scoFaEngineerWaterRestoreThread then KillThread(unit.scoFaEngineerWaterRestoreThread) end\n    unit.scoFaEngineerWaterRestoreThread = unit:NewThread(\n        SCOFaEngineerWaterLifecycle.RestoreThread,\n        delay\n    )\nend\n\n_G.SCOFaEngineerWaterLifecycle = SCOFaEngineerWaterLifecycle";

	private const string GuardHostAppendix = "\n\n-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0\nlocal SCOFaEngineerWaterLifecycle = _G.SCOFaEngineerWaterLifecycle\nlocal SCOFaEngineerWaterGuard = HostGuardEngineer or GuardEngineer\nif not SCOFaEngineerWaterLifecycle or not SCOFaEngineerWaterGuard then\n    error(\"FA engineer water lifecycle could not resolve Guard dependencies\")\nend\nlocal SCOFaEngineerWaterGuardStopBuilt = SCOFaEngineerWaterGuard.OnStopBeingBuilt\nlocal SCOFaEngineerWaterGuardDestroy = SCOFaEngineerWaterGuard.OnDestroy\n\nfunction SCOFaEngineerWaterGuard:OnStopBeingBuilt(...)\n    SCOFaEngineerWaterGuardStopBuilt(self, ...)\n    SCOFaEngineerWaterLifecycle.Start(self)\nend\n\nfunction SCOFaEngineerWaterGuard:OnDestroy(...)\n    if SCOFaEngineerWaterLifecycle.IsSupported(self) then\n        SCOFaEngineerWaterLifecycle.Stop(self)\n    end\n    return SCOFaEngineerWaterGuardDestroy(self, ...)\nend";

	private const string EdaHostAppendix = "\n\n-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0\nlocal SCOFaEngineerWaterLifecycle = _G.SCOFaEngineerWaterLifecycle\nlocal SCOFaEngineerWaterEda = HostEDAUefEngineer or EDAUefEngineer\nif not SCOFaEngineerWaterLifecycle or not SCOFaEngineerWaterEda then\n    error(\"FA engineer water lifecycle could not resolve EDA dependencies\")\nend\nlocal SCOFaEngineerWaterEdaStopBuilt = SCOFaEngineerWaterEda.OnStopBeingBuilt\nlocal SCOFaEngineerWaterEdaStartBuild = SCOFaEngineerWaterEda.OnStartBuildRoutine\nlocal SCOFaEngineerWaterEdaStopBuild = SCOFaEngineerWaterEda.OnStopBuildRoutine\nlocal SCOFaEngineerWaterEdaDestroy = SCOFaEngineerWaterEda.OnDestroy\n\nfunction SCOFaEngineerWaterEda:OnStopBeingBuilt(...)\n    SCOFaEngineerWaterEdaStopBuilt(self, ...)\n    SCOFaEngineerWaterLifecycle.Start(self)\nend\n\nfunction SCOFaEngineerWaterEda:OnStartBuildRoutine(targetUnit)\n    SCOFaEngineerWaterLifecycle.Suspend(self)\n    return SCOFaEngineerWaterEdaStartBuild(self, targetUnit)\nend\n\nfunction SCOFaEngineerWaterEda:OnStopBuildRoutine(targetUnit)\n    local result = SCOFaEngineerWaterEdaStopBuild(self, targetUnit)\n    if SCOFaEngineerWaterLifecycle.IsSupported(self) then\n        local config = self.tp.additions.faEngineerWaterAnimation\n        SCOFaEngineerWaterLifecycle.ResumeAfter(self, config.buildCloseSeconds)\n    end\n    return result\nend\n\nfunction SCOFaEngineerWaterEda:OnDestroy(...)\n    if SCOFaEngineerWaterLifecycle.IsSupported(self) then\n        SCOFaEngineerWaterLifecycle.Stop(self)\n    end\n    return SCOFaEngineerWaterEdaDestroy(self, ...)\nend";

	public static void Apply()
	{
		ValidatePinnedScope();
		ProgressBoundAnimationBridgeAttestation.RequireVerified();
		object obj = null;
		List<CacheMutation> list = new List<CacheMutation>(9);
		try
		{
			obj = GetLuaFileCache();
			ValidateDependencyResources(obj);
			ValidateTransactionState(obj);
			EngineerSpec[] engineers = Engineers;
			foreach (EngineerSpec spec in engineers)
			{
				QueueAppend(obj, list, spec.TemplatePath, spec.SourceId + "->" + spec.TargetId + " engineer template", BuildTemplateAppendix(spec), delegate(string source)
				{
					ValidateTemplate(source, spec);
				});
			}
			QueueAppend(obj, list, "LJ/lua/host/units/unitsClasses/unitsDefault.lua", "generic host engineer-water lifecycle", "\n\n-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0\n-- FA CConstructionUnit/TConstructionUnit use one reversible Awheels animator.\n-- The coordinator sentinel stores exact clip seconds in currentClipTime and\n-- freezes automatic advancement, so interrupted shoreline reversal retains\n-- the same authored pose at deterministic simulation ticks.\nlocal SCOFaEngineerWaterSentinelBase = -10000\nlocal SCOFaEngineerWaterEnterDepth = 0.05\nlocal SCOFaEngineerWaterExitDepth = 0.01\nlocal SCOFaEngineerWaterLifecycle = {}\n\nlocal function SCOFaEngineerWaterAlive(unit)\n    return unit ~= nil and not unit.dead and not unit.deleted\nend\n\nlocal function SCOFaEngineerWaterConfig(unit)\n    local additions = unit.tp and unit.tp.additions\n    return additions and additions.faEngineerWaterAnimation\nend\n\nfunction SCOFaEngineerWaterLifecycle.IsSupported(unit)\n    local config = SCOFaEngineerWaterConfig(unit)\n    return config ~= nil and config.sourceRate == 1\nend\n\nfunction SCOFaEngineerWaterLifecycle.Probe(unit, previous, position)\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return nil end\n    if not hasWater then return false end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return nil end\n    local positionResult = Engine.GetGlobalEntityWorldPosition(unit.id, position)\n    if positionResult ~= EngineErrorCode.Success then return nil end\n    local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)\n    if terrainResult ~= EngineErrorCode.Success or terrainHeight == nil then return nil end\n    local requiredDepth = previous and SCOFaEngineerWaterExitDepth or SCOFaEngineerWaterEnterDepth\n    return terrainHeight < waterLevel - requiredDepth\nend\n\nfunction SCOFaEngineerWaterLifecycle.SampleThread(unit)\n    local config = SCOFaEngineerWaterConfig(unit)\n    local animations = unit.tp and unit.tp.visuals and unit.tp.visuals.animations\n    local water = animations and animations.waterTransform\n    if not config or not water or not water.id\n        or type(config.durationSeconds) ~= \"number\"\n        or config.durationSeconds <= 0\n        or config.durationSeconds >= 1000\n    then\n        error(\"FA engineer water-animation contract is incomplete\")\n    end\n\n    local elapsed = unit.scoFaEngineerWaterElapsed or 0\n    local inWater = unit.scoFaEngineerWaterState or false\n    local position = EngineClasses.float3()\n    local initialProbe = SCOFaEngineerWaterLifecycle.Probe(unit, inWater, position)\n    if initialProbe ~= nil then inWater = initialProbe end\n    unit.scoFaEngineerWaterElapsed = elapsed\n    unit.scoFaEngineerWaterState = inWater\n    Engine.PlayAnimation(unit.id, water.id, SCOFaEngineerWaterSentinelBase + elapsed)\n\n    while SCOFaEngineerWaterAlive(unit) do\n        WaitTicks(1)\n        if not SCOFaEngineerWaterAlive(unit) then break end\n        local probed = SCOFaEngineerWaterLifecycle.Probe(unit, inWater, position)\n        if probed ~= nil then\n            inWater = probed\n            unit.scoFaEngineerWaterState = inWater\n        end\n\n        local previousElapsed = elapsed\n        if inWater then\n            elapsed = math.min(config.durationSeconds, elapsed + Constants.TickTimeStep)\n        else\n            elapsed = math.max(0, elapsed - Constants.TickTimeStep)\n        end\n        unit.scoFaEngineerWaterElapsed = elapsed\n        if not unit.scoFaEngineerWaterSuspended\n            and (elapsed ~= previousElapsed or unit.scoFaEngineerWaterForceSample)\n        then\n            unit.scoFaEngineerWaterForceSample = nil\n            Engine.PlayAnimation(unit.id, water.id, SCOFaEngineerWaterSentinelBase + elapsed)\n        end\n    end\n    unit.scoFaEngineerWaterThread = nil\nend\n\nfunction SCOFaEngineerWaterLifecycle.Stop(unit)\n    if unit.scoFaEngineerWaterThread then KillThread(unit.scoFaEngineerWaterThread) end\n    if unit.scoFaEngineerWaterRestoreThread then KillThread(unit.scoFaEngineerWaterRestoreThread) end\n    unit.scoFaEngineerWaterThread = nil\n    unit.scoFaEngineerWaterRestoreThread = nil\n    unit.scoFaEngineerWaterElapsed = nil\n    unit.scoFaEngineerWaterState = nil\n    unit.scoFaEngineerWaterSuspended = nil\n    unit.scoFaEngineerWaterForceSample = nil\nend\n\nfunction SCOFaEngineerWaterLifecycle.Start(unit)\n    if not SCOFaEngineerWaterLifecycle.IsSupported(unit) then return end\n    SCOFaEngineerWaterLifecycle.Stop(unit)\n    unit.scoFaEngineerWaterElapsed = 0\n    unit.scoFaEngineerWaterState = false\n    unit.scoFaEngineerWaterThread = unit:NewThread(SCOFaEngineerWaterLifecycle.SampleThread)\nend\n\nfunction SCOFaEngineerWaterLifecycle.Suspend(unit)\n    if not SCOFaEngineerWaterLifecycle.IsSupported(unit) then return end\n    if unit.scoFaEngineerWaterRestoreThread then KillThread(unit.scoFaEngineerWaterRestoreThread) end\n    unit.scoFaEngineerWaterRestoreThread = nil\n    unit.scoFaEngineerWaterSuspended = true\nend\n\nfunction SCOFaEngineerWaterLifecycle.RestoreThread(unit, delay)\n    WaitSeconds(delay)\n    unit.scoFaEngineerWaterRestoreThread = nil\n    if not SCOFaEngineerWaterAlive(unit) then return end\n    unit.scoFaEngineerWaterSuspended = nil\n    unit.scoFaEngineerWaterForceSample = true\nend\n\nfunction SCOFaEngineerWaterLifecycle.ResumeAfter(unit, delay)\n    if not SCOFaEngineerWaterLifecycle.IsSupported(unit) then return end\n    if unit.scoFaEngineerWaterRestoreThread then KillThread(unit.scoFaEngineerWaterRestoreThread) end\n    unit.scoFaEngineerWaterRestoreThread = unit:NewThread(\n        SCOFaEngineerWaterLifecycle.RestoreThread,\n        delay\n    )\nend\n\n_G.SCOFaEngineerWaterLifecycle = SCOFaEngineerWaterLifecycle", ValidateHostLifecycle);
			QueueAppend(obj, list, "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "Guard engineer-water lifecycle binding", "\n\n-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0\nlocal SCOFaEngineerWaterLifecycle = _G.SCOFaEngineerWaterLifecycle\nlocal SCOFaEngineerWaterGuard = HostGuardEngineer or GuardEngineer\nif not SCOFaEngineerWaterLifecycle or not SCOFaEngineerWaterGuard then\n    error(\"FA engineer water lifecycle could not resolve Guard dependencies\")\nend\nlocal SCOFaEngineerWaterGuardStopBuilt = SCOFaEngineerWaterGuard.OnStopBeingBuilt\nlocal SCOFaEngineerWaterGuardDestroy = SCOFaEngineerWaterGuard.OnDestroy\n\nfunction SCOFaEngineerWaterGuard:OnStopBeingBuilt(...)\n    SCOFaEngineerWaterGuardStopBuilt(self, ...)\n    SCOFaEngineerWaterLifecycle.Start(self)\nend\n\nfunction SCOFaEngineerWaterGuard:OnDestroy(...)\n    if SCOFaEngineerWaterLifecycle.IsSupported(self) then\n        SCOFaEngineerWaterLifecycle.Stop(self)\n    end\n    return SCOFaEngineerWaterGuardDestroy(self, ...)\nend", ValidateGuardHost);
			QueueAppend(obj, list, "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", "EDA engineer-water lifecycle binding", "\n\n-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0\nlocal SCOFaEngineerWaterLifecycle = _G.SCOFaEngineerWaterLifecycle\nlocal SCOFaEngineerWaterEda = HostEDAUefEngineer or EDAUefEngineer\nif not SCOFaEngineerWaterLifecycle or not SCOFaEngineerWaterEda then\n    error(\"FA engineer water lifecycle could not resolve EDA dependencies\")\nend\nlocal SCOFaEngineerWaterEdaStopBuilt = SCOFaEngineerWaterEda.OnStopBeingBuilt\nlocal SCOFaEngineerWaterEdaStartBuild = SCOFaEngineerWaterEda.OnStartBuildRoutine\nlocal SCOFaEngineerWaterEdaStopBuild = SCOFaEngineerWaterEda.OnStopBuildRoutine\nlocal SCOFaEngineerWaterEdaDestroy = SCOFaEngineerWaterEda.OnDestroy\n\nfunction SCOFaEngineerWaterEda:OnStopBeingBuilt(...)\n    SCOFaEngineerWaterEdaStopBuilt(self, ...)\n    SCOFaEngineerWaterLifecycle.Start(self)\nend\n\nfunction SCOFaEngineerWaterEda:OnStartBuildRoutine(targetUnit)\n    SCOFaEngineerWaterLifecycle.Suspend(self)\n    return SCOFaEngineerWaterEdaStartBuild(self, targetUnit)\nend\n\nfunction SCOFaEngineerWaterEda:OnStopBuildRoutine(targetUnit)\n    local result = SCOFaEngineerWaterEdaStopBuild(self, targetUnit)\n    if SCOFaEngineerWaterLifecycle.IsSupported(self) then\n        local config = self.tp.additions.faEngineerWaterAnimation\n        SCOFaEngineerWaterLifecycle.ResumeAfter(self, config.buildCloseSeconds)\n    end\n    return result\nend\n\nfunction SCOFaEngineerWaterEda:OnDestroy(...)\n    if SCOFaEngineerWaterLifecycle.IsSupported(self) then\n        SCOFaEngineerWaterLifecycle.Stop(self)\n    end\n    return SCOFaEngineerWaterEdaDestroy(self, ...)\nend", ValidateEdaHost);
			if (list.Count == 0)
			{
				Log("All six exact FA engineer water-animation bindings are already current.");
				return;
			}
			Commit(obj, list);
			Log("Applied six exact reversible FA engineer Awheels bindings atomically.");
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
			Log($"Failed to apply FA engineer water animations: {arg}");
			throw;
		}
	}

	private static string BuildTemplateAppendix(EngineerSpec spec)
	{
		string text = ((spec.TransformSha256 == null) ? "sourceDormantTransform = nil," : ("sourceDormantTransform = {\n    source = \"units/" + spec.SourceId + "/" + spec.SourceId + "_Atransform01.sca\",\n    sha256 = \"" + spec.TransformSha256 + "\",\n    runtimeBound = false,\n},"));
		string sourceId = spec.SourceId;
		string text2 = ((sourceId == "UEL0208") ? "{ \"Turret_Muzzle\" }" : ((!(sourceId == "UEL0309")) ? "{}" : "{ \"Turret_Barrel_Muzzle\", \"Turret_Barrel_Muzzle01\" }"));
		string text3 = ((spec.SourceId == "URL0105") ? "rejectedLegacy = {\n    Aconstruct01 = \"204f9658bc3b64942528ee351a7aebf11fc55992064ff61a80a1f6b785db99ea\",\n    Aconstruct02 = \"015d9c3623496a0438066a840eb743bb5f5641d2a174ed82ef0805105bfa731e\",\n    Aidle01 = \"c1ddae02300f55c9b78d66b929747e5834ec9651574718a55c5c80e1190a32df\",\n    Aidle02 = \"f23550c0a661e33de0e16d1d053697a094b25d57b0f2f6b1f940cae7cd83ee93\",\n    Aswim01 = \"47e3d0a992471be4e47ad7bdadfbd18300adeb1c3d17992c1240a54986a679c4\",\n    Atransform02 = \"82a3e3ec00a586d977fbbfcc34c0281edb5539b0193ebda008d747c8a00ed0f9\",\n    Awalk01 = \"327baed48899d3b42a2dc2c387447c10365c9a4b3e48e6b067db3df51ad5d379\",\n    reason = \"moving source hierarchy is absent from native LOD0 skeleton; no alias is valid\",\n}," : "rejectedLegacy = nil,");
		string text4 = (spec.IsUef ? "Sanctuary has one animation component; build-open temporarily suspends water sampling and exact phase is restored after close" : "none");
		return string.Format("\n\n{0}\nUnitTemplate.additions = UnitTemplate.additions or {{}}\nUnitTemplate.additions.faEngineerWaterAnimation = {{\n    mapping = \"{1} -> {2}\",\n    packageSha256 = \"{3}\",\n    animationSha256 = \"{4}\",\n    sourceArchiveSha256 = \"{5}\",\n    sourceLuaArchiveSha256 = \"{6}\",\n    sourceBlueprint = \"units/{7}/{8}_unit.bp\",\n    sourceBlueprintSha256 = \"{9}\",\n    sourceScript = \"units/{10}/{11}_script.lua\",\n    sourceScriptSha256 = \"{12}\",\n    sourceFactionLifecycle = \"{13}\",\n    sourceFactionLifecycleSha256 = \"{14}\",\n    sourceAnimationWater = \"units/{15}/{16}_Awheels.sca\",\n    sourceAnimationWaterSha256 = \"{17}\",\n    sourceFrames = {18},\n    durationSeconds = {19},\n    sourceRate = 1,\n    sourceReverseRate = -1,\n    buildCloseSeconds = {20},\n    exactTimeOwner = \"coordinator -10000 progress-frame sentinel\",\n    mediumProbe = \"guarded water level + root world position + terrain height with hysteresis\",\n    omittedSourceHelpers = {21},\n    {22}\n    {23}\n    limitation = \"{24}\",\n}}\n\nUnitTemplate.visuals = UnitTemplate.visuals or {{}}\nUnitTemplate.visuals.animations = UnitTemplate.visuals.animations or {{}}\n-- Imported rigs have no source-authored land walk. Remove the donor run and\n-- make exact source-rest the loader's initial pose.\nUnitTemplate.visuals.animations.run = nil\nUnitTemplate.visuals.animations.walk = {{\n    clipName = \"Rest\",\n    sanAnimationPath = \"Units/{25}/LOD0/{26}.sananimation\",\n    playbackMode = 0,\n}}\nUnitTemplate.visuals.animations.waterTransform = {{\n    clipName = \"AnimWater\",\n    sanAnimationPath = \"Units/{27}/LOD0/{28}.sananimation\",\n    playbackMode = 0,\n}}", "-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0", spec.SourceId, spec.TargetId, "feb5dbaa525a32f6987734620efe3f4643cb17e5a234e4518f8180b06704d11f", spec.AnimationSha256, "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb", spec.SourceId, spec.SourceId, spec.BlueprintSha256, spec.SourceId, spec.SourceId, spec.ScriptSha256, spec.IsUef ? "lua/terranunits.lua" : "lua/cybranunits.lua", spec.IsUef ? "4cf1990c6320b3999bd86edb2e0bba0a543942ae58e808cb41cf05c469d35b5e" : "f126ce26875ef8b51f240296af8bd0d86ff07e3fc4b2a5ebf0a5ba4478687411", spec.SourceId, spec.SourceId, spec.WheelsSha256, spec.WaterFrames, spec.WaterDurationLiteral, spec.BuildCloseSecondsLiteral, text2, text, text3, text4, spec.TargetId, spec.TargetId, spec.TargetId, spec.TargetId);
	}

	private static void ValidatePinnedScope()
	{
		(string, string)[] expected = new(string, string)[6]
		{
			("ugl1501", "URL0105"),
			("ugl2501", "URL0208"),
			("ugl3501", "URL0309"),
			("uel1501", "UEL0105"),
			("uel2501", "UEL0208"),
			("uel3501", "UEL0309")
		};
		if (Engineers.Length != expected.Length || Engineers.Select((EngineerSpec spec) => (TargetId: spec.TargetId, SourceId: spec.SourceId)).Where(delegate((string TargetId, string SourceId) pair, int index)
		{
			(string, string) tuple = pair;
			(string, string) tuple2 = expected[index];
			return tuple.Item1 != tuple2.Item1 || tuple.Item2 != tuple2.Item2;
		}).Any() || Engineers.Select((EngineerSpec spec) => spec.TargetId).Distinct<string>(StringComparer.Ordinal).Count() != expected.Length || Engineers.Any((EngineerSpec spec) => new string[4] { spec.BlueprintSha256, spec.ScriptSha256, spec.WheelsSha256, spec.AnimationSha256 }.Any((string hash) => hash.Length != 64)))
		{
			throw new InvalidOperationException("The reviewed six-engineer water-animation scope changed.");
		}
	}

	private static void ValidateDependencyResources(object cache)
	{
		string resourceText = GetResourceText(GetCachedResource(cache, "LJ/lua/common/loading/unitTemplateLoader.lua", "Clamp-capable unit loader").Stock);
		RequireTokens(resourceText, "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1", "animationInfo.playbackMode or AnimationPlaybackMode.Loop");
		RequireExactly(resourceText, "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1", 1, "structures loader marker");
		string resourceText2 = GetResourceText(GetCachedResource(cache, "LJ/lua/host/units/unitsClasses/unitsDefault.lua", "air-factory sentinel consumer").Stock);
		RequireTokens(resourceText2, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", "SCOFaAirFactoryElapsedSentinelBase = -20000", "Constants.TickTimeStep", "Engine.PlayAnimation");
		RequireExactly(resourceText2, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, "FA air-factory host marker");
	}

	private static void ValidateTransactionState(object cache)
	{
		string[] array = Engineers.Select((EngineerSpec spec) => spec.TemplatePath).Concat<string>(new string[3] { "LJ/lua/host/units/unitsClasses/unitsDefault.lua", "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua" }).ToArray();
		int num = array.Count((string path) => GetResourceText(GetCachedResource(cache, path, path).Stock).IndexOf("-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0", StringComparison.Ordinal) >= 0);
		if (num != 0 && num != array.Length)
		{
			throw new InvalidOperationException($"A partial FA engineer water-animation transaction was found ({num}/{array.Length}).");
		}
	}

	private static void ValidateStock(string path, string source)
	{
		if (path == "LJ/lua/host/units/unitsClasses/unitsDefault.lua")
		{
			RequireTokens(source, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", "HostFactory = Class", "SCOFaAirFactoryElapsedSentinelBase = -20000");
			return;
		}
		if (path == "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua")
		{
			RequireTokens(source, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", "HostGuardEngineer");
			return;
		}
		if (path == "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua")
		{
			RequireTokens(source, "-- Guard/EDA Engineer Cache Patcher 1.2.1", "-- Supreme Commander Overhaul FA Air Factories 1.0.0", "HostEDAUefEngineer = Class(\"EDAUefEngineer\"", "OnStartBuildRoutine", "OnStopBuildRoutine");
			return;
		}
		EngineerSpec engineerSpec = Engineers.Single((EngineerSpec candidate) => candidate.TemplatePath == path);
		RequireTokens(source, "-- Guard/EDA Engineer Cache Patcher 1.2.1", "tpId = \"" + engineerSpec.TargetId + "\"", "mapping = \"" + engineerSpec.SourceId + " -> " + engineerSpec.TargetId + "\"");
		if (engineerSpec.IsUef)
		{
			RequireTokens(source, "\"unitsDefaultEDA\"", "\"EDAUefEngineer\"", "clipName = \"AnimBuild\"", "clipName = \"AnimClose\"", "clipName = \"Rest\"");
		}
		else
		{
			RequireTokens(source, "\"unitsDefaultGuard\"", "\"GuardEngineer\"");
		}
	}

	private static void ValidateTemplate(string source, EngineerSpec spec)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0", 1, spec.TargetId + " water-animation marker");
		RequireTokens(source, "mapping = \"" + spec.SourceId + " -> " + spec.TargetId + "\"", "feb5dbaa525a32f6987734620efe3f4643cb17e5a234e4518f8180b06704d11f", spec.AnimationSha256, spec.BlueprintSha256, spec.ScriptSha256, spec.WheelsSha256, "durationSeconds = " + spec.WaterDurationLiteral, "sourceRate = 1", "sourceReverseRate = -1", "UnitTemplate.visuals.animations.run = nil", "clipName = \"Rest\"", "clipName = \"AnimWater\"", "playbackMode = 0");
		string source2 = OwnedAppendix(source);
		RequireNotContains(source2, "UnitTemplate.general.class", "UnitTemplate.movement =", "Aconstruct01.sca", "Awalk01.sca", "Aswim01.sca");
		if (spec.SourceId == "URL0105")
		{
			RequireTokens(source2, "204f9658bc3b64942528ee351a7aebf11fc55992064ff61a80a1f6b785db99ea", "327baed48899d3b42a2dc2c387447c10365c9a4b3e48e6b067db3df51ad5d379", "moving source hierarchy is absent from native LOD0 skeleton");
		}
		if (spec.IsUef)
		{
			RequireTokens(source, "clipName = \"AnimBuild\"", "clipName = \"AnimClose\"");
		}
		ValidateStock(spec.TemplatePath, source);
	}

	private static void ValidateHostLifecycle(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0", 1, "generic engineer-water marker");
		string source2 = OwnedAppendix(source);
		RequireTokens(source2, "SCOFaEngineerWaterSentinelBase = -10000", "SCOFaEngineerWaterEnterDepth = 0.05", "SCOFaEngineerWaterExitDepth = 0.01", "Engine.HasWater()", "Engine.GetWaterLevel()", "Engine.GetGlobalEntityWorldPosition(unit.id, position)", "Engine.SampleTerrainHeight(position)", "EngineErrorCode.Success", "elapsed + Constants.TickTimeStep", "elapsed - Constants.TickTimeStep", "math.min(config.durationSeconds", "math.max(0", "Engine.PlayAnimation(unit.id, water.id, SCOFaEngineerWaterSentinelBase + elapsed)", "WaitTicks(1)", "KillThread", "SCOFaEngineerWaterLifecycle.Suspend", "SCOFaEngineerWaterLifecycle.ResumeAfter");
		RequireTokens(source2, "function SCOFaEngineerWaterLifecycle.PlayPose", "local walk = animations and animations.walk", "not config or not walk or not walk.id", "if not inWater and elapsed == 0 then", "Engine.PlayAnimation(unit.id, walk.id, 0)", "SCOFaEngineerWaterLifecycle.PlayPose(unit, walk, water, elapsed, inWater)");
		RequireTokens(source2, "if not unit.scoFaEngineerWaterSuspended then", "or not SCOFaEngineerWaterAlive(unit) then return end");
		RequireExactly(source2, "SCOFaEngineerWaterLifecycle.PlayPose(unit, walk, water, elapsed, inWater)", 3, "land/water pose dispatch points");
		RequireExactly(source2, "Engine.PlayAnimation(unit.id, water.id, SCOFaEngineerWaterSentinelBase + elapsed)", 1, "water sentinel owner");
		RequireExactly(source2, "Engine.PlayAnimation(unit.id, walk.id, 0)", 1, "dry-land Rest owner");
		RequireExactly(source2, "Constants.TickTimeStep", 2, "exact ±1 water sample rate");
		RequireNotContains(source2, "0.5 * Constants.TickTimeStep", "GetMovementNavigationLayer");
		ValidateStock("LJ/lua/host/units/unitsClasses/unitsDefault.lua", source);
	}

	private static void ValidateGuardHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0", 1, "Guard engineer-water marker");
		RequireTokens(OwnedAppendix(source), "HostGuardEngineer or GuardEngineer", "SCOFaEngineerWaterGuardStopBuilt(self, ...)", "SCOFaEngineerWaterLifecycle.Start(self)", "SCOFaEngineerWaterGuardDestroy(self, ...)");
		ValidateStock("LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", source);
	}

	private static void ValidateEdaHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0", 1, "EDA engineer-water marker");
		RequireTokens(OwnedAppendix(source), "HostEDAUefEngineer or EDAUefEngineer", "SCOFaEngineerWaterEdaStopBuilt(self, ...)", "SCOFaEngineerWaterLifecycle.Suspend(self)", "SCOFaEngineerWaterEdaStartBuild(self, targetUnit)", "SCOFaEngineerWaterEdaStopBuild(self, targetUnit)", "SCOFaEngineerWaterEdaStartRepair(self, targetUnit)", "SCOFaEngineerWaterEdaStopRepair(self, targetUnit)", "SCOFaEngineerWaterEdaStartReclaim(self, targetUnit)", "SCOFaEngineerWaterEdaStopReclaim(self, targetUnit)", "not self:IsBuildRoutineEnabled()", "not self:IsRepairRoutineEnabled()", "not self:IsReclaimRoutineEnabled()", "SCOFaEngineerWaterLifecycle.ResumeAfter(self, config.buildCloseSeconds + Constants.TickTimeStep)", "local result = SCOFaEngineerWaterEdaDestroy(self, ...)", "SCOFaEngineerWaterLifecycle.Stop(self)");
		ValidateStock("LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", source);
	}

	private static string BuildHostLifecycleAppendix()
	{
		return ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly("\n\n-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0\n-- FA CConstructionUnit/TConstructionUnit use one reversible Awheels animator.\n-- The coordinator sentinel stores exact clip seconds in currentClipTime and\n-- freezes automatic advancement, so interrupted shoreline reversal retains\n-- the same authored pose at deterministic simulation ticks.\nlocal SCOFaEngineerWaterSentinelBase = -10000\nlocal SCOFaEngineerWaterEnterDepth = 0.05\nlocal SCOFaEngineerWaterExitDepth = 0.01\nlocal SCOFaEngineerWaterLifecycle = {}\n\nlocal function SCOFaEngineerWaterAlive(unit)\n    return unit ~= nil and not unit.dead and not unit.deleted\nend\n\nlocal function SCOFaEngineerWaterConfig(unit)\n    local additions = unit.tp and unit.tp.additions\n    return additions and additions.faEngineerWaterAnimation\nend\n\nfunction SCOFaEngineerWaterLifecycle.IsSupported(unit)\n    local config = SCOFaEngineerWaterConfig(unit)\n    return config ~= nil and config.sourceRate == 1\nend\n\nfunction SCOFaEngineerWaterLifecycle.SetTerrainAlignment(unit, inWater)\n    local id = unit.tp and unit.tp.general and unit.tp.general.tpId\n    if id ~= \"uel1501\" and id ~= \"uel2501\" and id ~= \"uel3501\" then return end\n    local factor = inWater and 0 or unit.tp.movement.terrainAlignmentFactor\n    local result = Engine.SetMovementTerrainAlignmentFactor(unit.id, factor)\n    if result ~= EngineErrorCode.Success and not unit.scoFaEngineerWaterAlignmentWarned then\n        unit.scoFaEngineerWaterAlignmentWarned = true\n        Warn(\"UEF engineer water terrain alignment failed: \" .. tostring(result))\n    end\nend\n\nfunction SCOFaEngineerWaterLifecycle.Probe(unit, previous, position)\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return nil end\n    if not hasWater then return false end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return nil end\n    local positionResult = Engine.GetGlobalEntityWorldPosition(unit.id, position)\n    if positionResult ~= EngineErrorCode.Success then return nil end\n    local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)\n    if terrainResult ~= EngineErrorCode.Success or terrainHeight == nil then return nil end\n    local requiredDepth = previous and SCOFaEngineerWaterExitDepth or SCOFaEngineerWaterEnterDepth\n    return terrainHeight < waterLevel - requiredDepth\nend\n\nfunction SCOFaEngineerWaterLifecycle.SampleThread(unit)\n    local config = SCOFaEngineerWaterConfig(unit)\n    local animations = unit.tp and unit.tp.visuals and unit.tp.visuals.animations\n    local water = animations and animations.waterTransform\n    if not config or not water or not water.id\n        or type(config.durationSeconds) ~= \"number\"\n        or config.durationSeconds <= 0\n        or config.durationSeconds >= 1000\n    then\n        error(\"FA engineer water-animation contract is incomplete\")\n    end\n\n    local elapsed = unit.scoFaEngineerWaterElapsed or 0\n    local inWater = unit.scoFaEngineerWaterState or false\n    local position = EngineClasses.float3()\n    local initialProbe = SCOFaEngineerWaterLifecycle.Probe(unit, inWater, position)\n    if initialProbe ~= nil then inWater = initialProbe end\n    unit.scoFaEngineerWaterElapsed = elapsed\n    unit.scoFaEngineerWaterState = inWater\n    Engine.PlayAnimation(unit.id, water.id, SCOFaEngineerWaterSentinelBase + elapsed)\n\n    while SCOFaEngineerWaterAlive(unit) do\n        WaitTicks(1)\n        if not SCOFaEngineerWaterAlive(unit) then break end\n        local probed = SCOFaEngineerWaterLifecycle.Probe(unit, inWater, position)\n        if probed ~= nil then\n            if probed ~= inWater then\n                SCOFaEngineerWaterLifecycle.SetTerrainAlignment(unit, probed)\n            end\n            inWater = probed\n            unit.scoFaEngineerWaterState = inWater\n        end\n\n        local previousElapsed = elapsed\n        if inWater then\n            elapsed = math.min(config.durationSeconds, elapsed + Constants.TickTimeStep)\n        else\n            elapsed = math.max(0, elapsed - Constants.TickTimeStep)\n        end\n        unit.scoFaEngineerWaterElapsed = elapsed\n        if not unit.scoFaEngineerWaterSuspended\n            and (elapsed ~= previousElapsed or unit.scoFaEngineerWaterForceSample)\n        then\n            unit.scoFaEngineerWaterForceSample = nil\n            Engine.PlayAnimation(unit.id, water.id, SCOFaEngineerWaterSentinelBase + elapsed)\n        end\n    end\n    unit.scoFaEngineerWaterThread = nil\nend\n\nfunction SCOFaEngineerWaterLifecycle.Stop(unit)\n    if unit.scoFaEngineerWaterThread then KillThread(unit.scoFaEngineerWaterThread) end\n    if unit.scoFaEngineerWaterRestoreThread then KillThread(unit.scoFaEngineerWaterRestoreThread) end\n    if SCOFaEngineerWaterAlive(unit) then\n        SCOFaEngineerWaterLifecycle.SetTerrainAlignment(unit, false)\n    end\n    unit.scoFaEngineerWaterThread = nil\n    unit.scoFaEngineerWaterRestoreThread = nil\n    unit.scoFaEngineerWaterElapsed = nil\n    unit.scoFaEngineerWaterState = nil\n    unit.scoFaEngineerWaterSuspended = nil\n    unit.scoFaEngineerWaterForceSample = nil\nend\n\nfunction SCOFaEngineerWaterLifecycle.Start(unit)\n    if not SCOFaEngineerWaterLifecycle.IsSupported(unit) then return end\n    SCOFaEngineerWaterLifecycle.Stop(unit)\n    unit.scoFaEngineerWaterElapsed = 0\n    unit.scoFaEngineerWaterState = false\n    unit.scoFaEngineerWaterThread = unit:NewThread(SCOFaEngineerWaterLifecycle.SampleThread)\nend\n\nfunction SCOFaEngineerWaterLifecycle.Suspend(unit)\n    if not SCOFaEngineerWaterLifecycle.IsSupported(unit) then return end\n    if unit.scoFaEngineerWaterRestoreThread then KillThread(unit.scoFaEngineerWaterRestoreThread) end\n    unit.scoFaEngineerWaterRestoreThread = nil\n    unit.scoFaEngineerWaterSuspended = true\nend\n\nfunction SCOFaEngineerWaterLifecycle.RestoreThread(unit, delay)\n    WaitSeconds(delay)\n    unit.scoFaEngineerWaterRestoreThread = nil\n    if not SCOFaEngineerWaterAlive(unit) then return end\n    unit.scoFaEngineerWaterSuspended = nil\n    unit.scoFaEngineerWaterForceSample = true\nend\n\nfunction SCOFaEngineerWaterLifecycle.ResumeAfter(unit, delay)\n    if not SCOFaEngineerWaterLifecycle.IsSupported(unit) then return end\n    if unit.scoFaEngineerWaterRestoreThread then KillThread(unit.scoFaEngineerWaterRestoreThread) end\n    unit.scoFaEngineerWaterRestoreThread = unit:NewThread(\n        SCOFaEngineerWaterLifecycle.RestoreThread,\n        delay\n    )\nend\n\n_G.SCOFaEngineerWaterLifecycle = SCOFaEngineerWaterLifecycle", "    Engine.PlayAnimation(unit.id, water.id, SCOFaEngineerWaterSentinelBase + elapsed)\n", "    SCOFaEngineerWaterLifecycle.PlayPose(unit, walk, water, elapsed, inWater)\n", 2, "water-only pose samples"), "    local water = animations and animations.waterTransform\n    if not config or not water or not water.id\n", "    local walk = animations and animations.walk\n    local water = animations and animations.waterTransform\n    if not config or not walk or not walk.id or not water or not water.id\n", 1, "land and water animation contract"), "function SCOFaEngineerWaterLifecycle.SampleThread(unit)\n", "function SCOFaEngineerWaterLifecycle.PlayPose(unit, walk, water, elapsed, inWater)\n    if not inWater and elapsed == 0 then\n        Engine.PlayAnimation(unit.id, walk.id, 0)\n        return\n    end\n    Engine.PlayAnimation(unit.id, water.id, SCOFaEngineerWaterSentinelBase + elapsed)\nend\n\nfunction SCOFaEngineerWaterLifecycle.SampleThread(unit)\n", 1, "land-pose dispatcher insertion point"), "    unit.scoFaEngineerWaterState = inWater\n    SCOFaEngineerWaterLifecycle.PlayPose(unit, walk, water, elapsed, inWater)\n\n    while SCOFaEngineerWaterAlive(unit) do\n", "    unit.scoFaEngineerWaterState = inWater\n    SCOFaEngineerWaterLifecycle.SetTerrainAlignment(unit, inWater)\n    if not unit.scoFaEngineerWaterSuspended then\n        SCOFaEngineerWaterLifecycle.PlayPose(unit, walk, water, elapsed, inWater)\n    end\n\n    while SCOFaEngineerWaterAlive(unit) do\n", 1, "suspension-aware initial pose"), "function SCOFaEngineerWaterLifecycle.ResumeAfter(unit, delay)\n    if not SCOFaEngineerWaterLifecycle.IsSupported(unit) then return end\n", "function SCOFaEngineerWaterLifecycle.ResumeAfter(unit, delay)\n    if not SCOFaEngineerWaterLifecycle.IsSupported(unit)\n        or not SCOFaEngineerWaterAlive(unit) then return end\n", 1, "dead-unit restore guard");
	}

	private static string BuildEdaHostAppendix()
	{
		return ReplaceExactly(ReplaceExactly(ReplaceExactly("\n\n-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0\nlocal SCOFaEngineerWaterLifecycle = _G.SCOFaEngineerWaterLifecycle\nlocal SCOFaEngineerWaterEda = HostEDAUefEngineer or EDAUefEngineer\nif not SCOFaEngineerWaterLifecycle or not SCOFaEngineerWaterEda then\n    error(\"FA engineer water lifecycle could not resolve EDA dependencies\")\nend\nlocal SCOFaEngineerWaterEdaStopBuilt = SCOFaEngineerWaterEda.OnStopBeingBuilt\nlocal SCOFaEngineerWaterEdaStartBuild = SCOFaEngineerWaterEda.OnStartBuildRoutine\nlocal SCOFaEngineerWaterEdaStopBuild = SCOFaEngineerWaterEda.OnStopBuildRoutine\nlocal SCOFaEngineerWaterEdaDestroy = SCOFaEngineerWaterEda.OnDestroy\n\nfunction SCOFaEngineerWaterEda:OnStopBeingBuilt(...)\n    SCOFaEngineerWaterEdaStopBuilt(self, ...)\n    SCOFaEngineerWaterLifecycle.Start(self)\nend\n\nfunction SCOFaEngineerWaterEda:OnStartBuildRoutine(targetUnit)\n    SCOFaEngineerWaterLifecycle.Suspend(self)\n    return SCOFaEngineerWaterEdaStartBuild(self, targetUnit)\nend\n\nfunction SCOFaEngineerWaterEda:OnStopBuildRoutine(targetUnit)\n    local result = SCOFaEngineerWaterEdaStopBuild(self, targetUnit)\n    if SCOFaEngineerWaterLifecycle.IsSupported(self) then\n        local config = self.tp.additions.faEngineerWaterAnimation\n        SCOFaEngineerWaterLifecycle.ResumeAfter(self, config.buildCloseSeconds)\n    end\n    return result\nend\n\nfunction SCOFaEngineerWaterEda:OnDestroy(...)\n    if SCOFaEngineerWaterLifecycle.IsSupported(self) then\n        SCOFaEngineerWaterLifecycle.Stop(self)\n    end\n    return SCOFaEngineerWaterEdaDestroy(self, ...)\nend", "SCOFaEngineerWaterLifecycle.ResumeAfter(self, config.buildCloseSeconds)", "SCOFaEngineerWaterLifecycle.ResumeAfter(self, config.buildCloseSeconds + Constants.TickTimeStep)", 1, "UEF close restore safety margin"), "    if SCOFaEngineerWaterLifecycle.IsSupported(self) then\n        local config = self.tp.additions.faEngineerWaterAnimation\n        SCOFaEngineerWaterLifecycle.ResumeAfter(self, config.buildCloseSeconds + Constants.TickTimeStep)\n    end\n", "    if not self:IsRepairRoutineEnabled()\n        and not self:IsReclaimRoutineEnabled()\n        and SCOFaEngineerWaterLifecycle.IsSupported(self)\n    then\n        local config = self.tp.additions.faEngineerWaterAnimation\n        SCOFaEngineerWaterLifecycle.ResumeAfter(self, config.buildCloseSeconds + Constants.TickTimeStep)\n    end\n", 1, "UEF build stop ownership guard"), "function SCOFaEngineerWaterEda:OnDestroy(...)\n    if SCOFaEngineerWaterLifecycle.IsSupported(self) then\n        SCOFaEngineerWaterLifecycle.Stop(self)\n    end\n    return SCOFaEngineerWaterEdaDestroy(self, ...)\nend", "function SCOFaEngineerWaterEda:OnDestroy(...)\n    local result = SCOFaEngineerWaterEdaDestroy(self, ...)\n    if SCOFaEngineerWaterLifecycle.IsSupported(self) then\n        SCOFaEngineerWaterLifecycle.Stop(self)\n    end\n    return result\nend", 1, "UEF destroy cleanup ordering") + "\r\n-- Repair shares the same one-component pose ownership as construction.\r\nlocal SCOFaEngineerWaterEdaStartRepair = SCOFaEngineerWaterEda.OnStartRepairRoutine\r\nlocal SCOFaEngineerWaterEdaStopRepair = SCOFaEngineerWaterEda.OnStopRepairRoutine\r\n\r\nfunction SCOFaEngineerWaterEda:OnStartRepairRoutine(targetUnit)\r\n    SCOFaEngineerWaterLifecycle.Suspend(self)\r\n    return SCOFaEngineerWaterEdaStartRepair(self, targetUnit)\r\nend\r\n\r\nfunction SCOFaEngineerWaterEda:OnStopRepairRoutine(targetUnit)\n    local result = SCOFaEngineerWaterEdaStopRepair(self, targetUnit)\n    if not self:IsBuildRoutineEnabled()\n        and not self:IsReclaimRoutineEnabled()\n        and SCOFaEngineerWaterLifecycle.IsSupported(self)\n    then\n        local config = self.tp.additions.faEngineerWaterAnimation\n        SCOFaEngineerWaterLifecycle.ResumeAfter(self, config.buildCloseSeconds + Constants.TickTimeStep)\n    end\n    return result\nend\n\n-- Reclaim is a native work routine with the same UEF arm and water-pose owner.\nlocal SCOFaEngineerWaterEdaStartReclaim = SCOFaEngineerWaterEda.OnStartReclaimRoutine\nlocal SCOFaEngineerWaterEdaStopReclaim = SCOFaEngineerWaterEda.OnStopReclaimRoutine\n\nfunction SCOFaEngineerWaterEda:OnStartReclaimRoutine(targetUnit)\n    SCOFaEngineerWaterLifecycle.Suspend(self)\n    return SCOFaEngineerWaterEdaStartReclaim(self, targetUnit)\nend\n\nfunction SCOFaEngineerWaterEda:OnStopReclaimRoutine(targetUnit)\n    local result = SCOFaEngineerWaterEdaStopReclaim(self, targetUnit)\n    if not self:IsBuildRoutineEnabled()\n        and not self:IsRepairRoutineEnabled()\n        and SCOFaEngineerWaterLifecycle.IsSupported(self)\n    then\n        local config = self.tp.additions.faEngineerWaterAnimation\n        SCOFaEngineerWaterLifecycle.ResumeAfter(self, config.buildCloseSeconds + Constants.TickTimeStep)\n    end\n    return result\nend";
	}

	private static string ReplaceExactly(string source, string oldValue, string newValue, int expectedCount, string description)
	{
		int num = 0;
		int startIndex = 0;
		while ((startIndex = source.IndexOf(oldValue, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += oldValue.Length;
		}
		if (num != expectedCount)
		{
			throw new InvalidOperationException($"Expected {expectedCount} {description}, found {num}.");
		}
		return source.Replace(oldValue, newValue);
	}

	private static void QueueAppend(object cache, ICollection<CacheMutation> mutations, string relativePath, string description, string appendix, Action<string> validate)
	{
		if (relativePath == "LJ/lua/host/units/unitsClasses/unitsDefault.lua")
		{
			appendix = BuildHostLifecycleAppendix();
		}
		else if (relativePath == "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua")
		{
			appendix = BuildEdaHostAppendix();
		}
		CacheResource cachedResource = GetCachedResource(cache, relativePath, description);
		string resourceText = GetResourceText(cachedResource.Stock);
		if (resourceText.IndexOf("-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0", StringComparison.Ordinal) >= 0)
		{
			validate(resourceText);
			return;
		}
		ValidateStock(relativePath, resourceText);
		object obj = CreateNativeArray(cachedResource.Stock.GetType(), AppendOverride(resourceText, appendix));
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
		return cacheResource ?? throw new FileNotFoundException("Required " + description + " was not present in Sanctuary's Lua cache.", relativePath);
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
		int num = source.IndexOf("-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0", StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException("Engineer water-animation marker is absent.");
		}
		int num2 = source.IndexOf("\n-- Supreme Commander Overhaul", num + "-- Supreme Commander Overhaul FA Engineer Water Animations 1.0.0".Length, StringComparison.Ordinal);
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
				throw new InvalidOperationException("Engineer water-owned Lua must not contain '" + text + "'.");
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

	private static string Lua(double value)
	{
		return StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture);
	}

	private static void Log(string message)
	{
		string text = "[FA Engineer Water Animations Cache Patcher] " + message;
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
