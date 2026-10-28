using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;
using SupremeCommanderOverhaulCachePatcher;

namespace GuardEdaEngineerCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class PatchSpec
	{
		public string RelativePath { get; }

		public string Description { get; }

		public string Appendix { get; }

		public PatchSpec(string relativePath, string description, string appendix)
		{
			RelativePath = relativePath;
			Description = description;
			Appendix = appendix;
		}
	}

	private sealed class EngineerGameplaySpec
	{
		public string TargetId { get; }

		public string SourceId { get; }

		public string BlueprintSha256 { get; }

		public string ScriptSha256 { get; }

		public string Faction { get; }

		public int Tier { get; }

		public int Health { get; }

		public int BuildTime { get; }

		public int Alloys { get; }

		public int Energy { get; }

		public int AlloyStorage { get; }

		public int Vision { get; }

		public int BuildPower { get; }

		public double ReverseSpeed { get; }

		public EngineerGameplaySpec(string targetId, string sourceId, string blueprintSha256, string scriptSha256, string faction, int tier, int health, int buildTime, int alloys, int energy, int alloyStorage, int vision, int buildPower, double reverseSpeed)
		{
			TargetId = targetId;
			SourceId = sourceId;
			BlueprintSha256 = blueprintSha256;
			ScriptSha256 = scriptSha256;
			Faction = faction;
			Tier = tier;
			Health = health;
			BuildTime = buildTime;
			Alloys = alloys;
			Energy = energy;
			AlloyStorage = alloyStorage;
			Vision = vision;
			BuildPower = buildPower;
			ReverseSpeed = reverseSpeed;
		}
	}

	private sealed class CachedResource
	{
		public PatchSpec Spec { get; }

		public string Path { get; }

		public object Stock { get; }

		public object? Replacement { get; set; }

		public bool ReplacementWasAssigned { get; set; }

		public CachedResource(PatchSpec spec, string path, object stock)
		{
			Spec = spec;
			Path = path;
			Stock = stock;
		}
	}

	private const string OverrideMarker = "-- Guard/EDA Engineer Cache Patcher 1.2.1";

	internal const string SourceArchiveSha256 = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26";

	private static readonly EngineerGameplaySpec GuardT1Source = new EngineerGameplaySpec("ugl1501", "URL0105", "3eb677289b63514a1152a1328f899d7a8a88bdc549a3556bb77cd3562508ac8e", "39de5d1c7b1f97f8c4294c45d9edb7a958f0cff8f2d4653d5ee286c5378687f9", "GUARD", 1, 145, 260, 52, 260, 10, 18, 5, 1.7);

	private static readonly EngineerGameplaySpec GuardT2Source = new EngineerGameplaySpec("ugl2501", "URL0208", "eddd9987117e3cc3062b849c1de7be153cefada2581ab12404ff01a41025f807", "957785569c55c5cc0b992d22e55dd06f9585f3702c81e8726a4cbf9afef705a6", "GUARD", 2, 710, 800, 160, 840, 20, 20, 10, 1.6);

	private static readonly EngineerGameplaySpec GuardT3Source = new EngineerGameplaySpec("ugl3501", "URL0309", "70ad5c542a3781bb25e0dda8c2d29bf8b699bed8f6ce5e6d6284826e6e4a0232", "80206def06b03e4ec47e92d7304b6813a46e37b717aad42bc853d9aed55310f5", "GUARD", 3, 1425, 2100, 490, 3150, 40, 26, 15, 1.6);

	private static readonly EngineerGameplaySpec EdaT1Source = new EngineerGameplaySpec("uel1501", "UEL0105", "94daaf4535afafd99543deeb799b13c84f4a17312b6c9dab89ba954486deae2b", "c45d1e9b621eb5679e9ea6bf07c18bed5b655dbf8ea360efd97c773beb67b35c", "EDA", 1, 150, 260, 52, 260, 10, 18, 5, 1.5);

	private static readonly EngineerGameplaySpec EdaT2Source = new EngineerGameplaySpec("uel2501", "UEL0208", "5e444a49c6a849aecab6d84b604f1957d58e148d0e5f89be56c4aed813198987", "4c357b4d1158e39d7a8f16a5a5f65958bea5e1fa30d062d1903675d331f70357", "EDA", 2, 730, 800, 160, 840, 20, 20, 10, 1.4);

	private static readonly EngineerGameplaySpec EdaT3Source = new EngineerGameplaySpec("uel3501", "UEL0309", "7710ec8ac0c9c3157c516d24b7a91acc26914090870217aa8e80da46ad862ccb", "a84606264cf517151137026c6e12a8c47d2c19a36e02876b1f4a1ed77909ba49", "EDA", 3, 1500, 2100, 490, 3150, 40, 26, 15, 1.4);

	private const string GuardT1Bounds = "UnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.24, z = 0 },\n    collisionSize = { x = 0.8, y = 0.7, z = 0.8 },\n}\nUnitTemplate.footprint = { x = 1.2, y = 1.2 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.0, y = 1.0 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.24, z = 0 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.0, y = 1.0 },\n    offset = { x = 0, y = 0.24, z = 0 },\n}";

	private const string GuardT2Bounds = "UnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.32, z = -0.01 },\n    collisionSize = { x = 0.9, y = 0.9, z = 1.0 },\n}\nUnitTemplate.footprint = { x = 1.3, y = 1.4 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.1, y = 1.2 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.32, z = -0.01 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.1, y = 1.2 },\n    offset = { x = 0, y = 0.32, z = -0.01 },\n}";

	private const string GuardT3Bounds = "UnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.41, z = -0.01 },\n    collisionSize = { x = 1.1, y = 1.0, z = 1.2 },\n}\nUnitTemplate.footprint = { x = 1.5, y = 1.6 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.3, y = 1.4 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.41, z = -0.01 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.3, y = 1.4 },\n    offset = { x = 0, y = 0.41, z = -0.01 },\n}";

	private const string EdaT1Bounds = "UnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.28, z = 0.03 },\n    collisionSize = { x = 0.8, y = 0.8, z = 1.0 },\n}\nUnitTemplate.footprint = { x = 1.2, y = 1.4 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.0, y = 1.2 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.28, z = 0.03 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.0, y = 1.2 },\n    offset = { x = 0, y = 0.28, z = 0.03 },\n}";

	private const string EdaT2Bounds = "UnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.36, z = 0.07 },\n    collisionSize = { x = 0.9, y = 1.0, z = 1.2 },\n}\nUnitTemplate.footprint = { x = 1.3, y = 1.6 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.1, y = 1.4 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.36, z = 0.07 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.1, y = 1.4 },\n    offset = { x = 0, y = 0.36, z = 0.07 },\n}";

	private const string EdaT3Bounds = "UnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.47, z = 0.04 },\n    collisionSize = { x = 1.1, y = 1.2, z = 1.6 },\n}\nUnitTemplate.footprint = { x = 1.5, y = 2.0 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.3, y = 1.8 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.47, z = 0.04 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.3, y = 1.8 },\n    offset = { x = 0, y = 0.47, z = 0.04 },\n}";

	private static readonly PatchSpec[] PatchSpecs = new PatchSpec[8]
	{
		new PatchSpec("LJ/lua/common/units/unitsTemplates/ugl1501/ugl1501.santp", "Guard T1 engineer template", GuardTemplateOverride(GuardT1Source, "Buildpoint_Center", "\"Buildpoint_Center\"", "UnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.24, z = 0 },\n    collisionSize = { x = 0.8, y = 0.7, z = 0.8 },\n}\nUnitTemplate.footprint = { x = 1.2, y = 1.2 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.0, y = 1.0 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.24, z = 0 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.0, y = 1.0 },\n    offset = { x = 0, y = 0.24, z = 0 },\n}")),
		new PatchSpec("LJ/lua/common/units/unitsTemplates/ugl2501/ugl2501.santp", "Guard T2 engineer template", GuardTemplateOverride(GuardT2Source, "Buildpoint_Left", "\"Buildpoint_Left\", \"Buildpoint_Right\"", "UnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.32, z = -0.01 },\n    collisionSize = { x = 0.9, y = 0.9, z = 1.0 },\n}\nUnitTemplate.footprint = { x = 1.3, y = 1.4 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.1, y = 1.2 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.32, z = -0.01 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.1, y = 1.2 },\n    offset = { x = 0, y = 0.32, z = -0.01 },\n}")),
		new PatchSpec("LJ/lua/common/units/unitsTemplates/ugl3501/ugl3501.santp", "Guard T3 engineer template", GuardTemplateOverride(GuardT3Source, "Buildpoint_Center", "\"Buildpoint_Left\", \"Buildpoint_Center\", \"Buildpoint_Right\"", "UnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.41, z = -0.01 },\n    collisionSize = { x = 1.1, y = 1.0, z = 1.2 },\n}\nUnitTemplate.footprint = { x = 1.5, y = 1.6 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.3, y = 1.4 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.41, z = -0.01 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.3, y = 1.4 },\n    offset = { x = 0, y = 0.41, z = -0.01 },\n}")),
		new PatchSpec("LJ/lua/common/units/unitsTemplates/uel1501/uel1501.santp", "EDA T1 engineer template", EdaTemplateOverride(EdaT1Source, "Turret_Muzzle", "\"Turret_Muzzle\"", "UnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.28, z = 0.03 },\n    collisionSize = { x = 0.8, y = 0.8, z = 1.0 },\n}\nUnitTemplate.footprint = { x = 1.2, y = 1.4 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.0, y = 1.2 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.28, z = 0.03 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.0, y = 1.2 },\n    offset = { x = 0, y = 0.28, z = 0.03 },\n}")),
		new PatchSpec("LJ/lua/common/units/unitsTemplates/uel2501/uel2501.santp", "EDA T2 engineer template", EdaTemplateOverride(EdaT2Source, "Turret_Muzzle_01", "\"Turret_Muzzle_01\", \"Turret_Muzzle_02\"", "UnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.36, z = 0.07 },\n    collisionSize = { x = 0.9, y = 1.0, z = 1.2 },\n}\nUnitTemplate.footprint = { x = 1.3, y = 1.6 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.1, y = 1.4 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.36, z = 0.07 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.1, y = 1.4 },\n    offset = { x = 0, y = 0.36, z = 0.07 },\n}")),
		new PatchSpec("LJ/lua/common/units/unitsTemplates/uel3501/uel3501.santp", "EDA T3 engineer template", EdaTemplateOverride(EdaT3Source, "Turret_Muzzle02", "\"Turret_Muzzle01\", \"Turret_Muzzle02\", \"Turret_Muzzle03\"", "UnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.47, z = 0.04 },\n    collisionSize = { x = 1.1, y = 1.2, z = 1.6 },\n}\nUnitTemplate.footprint = { x = 1.5, y = 2.0 }\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 1.3, y = 1.8 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.47, z = 0.04 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 1.3, y = 1.8 },\n    offset = { x = 0, y = 0.47, z = 0.04 },\n}")),
		new PatchSpec("LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", "EDA host engineer classes", "\n-- Guard/EDA Engineer Cache Patcher 1.2.1\n-- Only the imported UEF rigs expose compatible native build-open clips.\n-- Clamp plays the FA-rate open action once when building begins and its\n-- exact reverse close action once when building ends.\n-- Normal builds outlast the 0.4s open. Sanctuary exposes no public\n-- playback-offset API for a close begun during that brief opening window.\nlocal EDAEngineer = HostEDAEngineer or EDAEngineer\nif not EDAEngineer then\n    error(\"SCO could not resolve the host EDA engineer base class.\")\nend\nHostEDAUefEngineer = Class(\"EDAUefEngineer\", EDAEngineer)\nlocal EDAUefEngineer = HostEDAUefEngineer\n\nfunction EDAUefEngineer:OnStartBuildRoutine(targetUnit)\n    EDAEngineer.OnStartBuildRoutine(self, targetUnit)\n    local animations = self.tp.visuals and self.tp.visuals.animations\n    if animations and animations.build then\n        Engine.PlayAnimation(self.id, animations.build.id, 0.1)\n    end\nend\n\nfunction EDAUefEngineer:OnStopBuildRoutine(targetUnit)\n    EDAEngineer.OnStopBuildRoutine(self, targetUnit)\n    local animations = self.tp.visuals and self.tp.visuals.animations\n    if animations and animations.close then\n        Engine.PlayAnimation(self.id, animations.close.id, 0.1)\n    end\nend"),
		new PatchSpec("LJ/lua/client/units/unitsClasses/unitsDefaultEDA.lua", "EDA client engineer classes", "\n-- Guard/EDA Engineer Cache Patcher 1.2.1\n-- The client resolves the same subclass name declared by the patched\n-- EDA engineer templates; build animation playback is host-authoritative.\nlocal EDAEngineer = ClientEDAEngineer or EDAEngineer\nif not EDAEngineer then\n    error(\"SCO could not resolve the client EDA engineer base class.\")\nend\nClientEDAUefEngineer = Class(\"EDAUefEngineer\", EDAEngineer)\nlocal EDAUefEngineer = ClientEDAUefEngineer")
	};

	private const string HostClassOverride = "\n-- Guard/EDA Engineer Cache Patcher 1.2.1\n-- Only the imported UEF rigs expose compatible native build-open clips.\n-- Clamp plays the FA-rate open action once when building begins and its\n-- exact reverse close action once when building ends.\n-- Normal builds outlast the 0.4s open. Sanctuary exposes no public\n-- playback-offset API for a close begun during that brief opening window.\nlocal EDAEngineer = HostEDAEngineer or EDAEngineer\nif not EDAEngineer then\n    error(\"SCO could not resolve the host EDA engineer base class.\")\nend\nHostEDAUefEngineer = Class(\"EDAUefEngineer\", EDAEngineer)\nlocal EDAUefEngineer = HostEDAUefEngineer\n\nfunction EDAUefEngineer:OnStartBuildRoutine(targetUnit)\n    EDAEngineer.OnStartBuildRoutine(self, targetUnit)\n    local animations = self.tp.visuals and self.tp.visuals.animations\n    if animations and animations.build then\n        Engine.PlayAnimation(self.id, animations.build.id, 0.1)\n    end\nend\n\nfunction EDAUefEngineer:OnStopBuildRoutine(targetUnit)\n    EDAEngineer.OnStopBuildRoutine(self, targetUnit)\n    local animations = self.tp.visuals and self.tp.visuals.animations\n    if animations and animations.close then\n        Engine.PlayAnimation(self.id, animations.close.id, 0.1)\n    end\nend";

	private const string ClientClassOverride = "\n-- Guard/EDA Engineer Cache Patcher 1.2.1\n-- The client resolves the same subclass name declared by the patched\n-- EDA engineer templates; build animation playback is host-authoritative.\nlocal EDAEngineer = ClientEDAEngineer or EDAEngineer\nif not EDAEngineer then\n    error(\"SCO could not resolve the client EDA engineer base class.\")\nend\nClientEDAUefEngineer = Class(\"EDAUefEngineer\", EDAEngineer)\nlocal EDAUefEngineer = ClientEDAUefEngineer";

	public static void Apply()
	{
		ProgressBoundAnimationBridgeAttestation.RequireVerified();
		List<CachedResource> list = new List<CachedResource>(PatchSpecs.Length);
		object obj = null;
		bool flag = false;
		try
		{
			obj = GetLuaFileCache();
			PatchSpec[] patchSpecs = PatchSpecs;
			foreach (PatchSpec patchSpec in patchSpecs)
			{
				if (!TryGetCachedResource(obj, patchSpec, out CachedResource resource))
				{
					throw new FileNotFoundException("The required " + patchSpec.Description + " was not present in Sanctuary's Lua file cache.", patchSpec.RelativePath);
				}
				list.Add(resource);
			}
			int num = list.Count((CachedResource cachedResource) => ContainsOverride(cachedResource.Stock));
			if (num == list.Count)
			{
				Log("All six engineer templates and both EDA class files already contain the local visual override.");
				return;
			}
			if (num != 0)
			{
				throw new InvalidOperationException("A partial Guard/EDA engineer cache override was found. The patcher will not mix old and new cached Lua resources.");
			}
			foreach (CachedResource item in list)
			{
				item.Replacement = AppendOverride(item.Stock, EffectiveAppendix(item.Spec));
				if (!ContainsOverride(item.Replacement))
				{
					throw new InvalidOperationException("The replacement " + item.Spec.Description + " did not retain its override marker.");
				}
			}
			foreach (CachedResource item2 in list)
			{
				item2.ReplacementWasAssigned = true;
				SetCachedResource(obj, item2.Path, item2.Replacement);
			}
			flag = true;
			foreach (CachedResource item3 in list)
			{
				TryDisposeNativeArray(item3.Stock.GetType(), item3.Stock, "stock " + item3.Spec.Description);
			}
			Log("Replaced the Guard Cybran and EDA UEF engineer templates. Build beams use verified native source bones; UEF builders use FA-rate open/close clips.");
		}
		catch (Exception arg)
		{
			if (!flag && obj != null)
			{
				RollBackAndDispose(obj, list);
			}
			Log($"Failed to replace the engineer resources: {arg}");
			throw;
		}
	}

	private static string EffectiveAppendix(PatchSpec spec)
	{
		if (spec.RelativePath == "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua")
		{
			return BuildHostClassOverride();
		}
		string text = spec.RelativePath switch
		{
			"LJ/lua/common/units/unitsTemplates/uel1501/uel1501.santp" => "uel1501", 
			"LJ/lua/common/units/unitsTemplates/uel2501/uel2501.santp" => "uel2501", 
			"LJ/lua/common/units/unitsTemplates/uel3501/uel3501.santp" => "uel3501", 
			_ => null, 
		};
		if (text != null)
		{
			return spec.Appendix + BuildUefEngineerAnimationContract(text);
		}
		return spec.Appendix;
	}

	private static string BuildUefEngineerAnimationContract(string targetId)
	{
		string text;
		switch (targetId)
		{
		case "uel1501":
			text = "0.3333333134651184";
			break;
		case "uel2501":
		case "uel3501":
			text = "0.4000000059604645";
			break;
		default:
			throw new ArgumentOutOfRangeException("targetId", targetId, "Unsupported UEF engineer animation contract.");
		}
		string text2 = text;
		return "\r\n\r\n-- Rest is the retracted AnimBuild frame 0/AnimClose endpoint.\r\n-- AnimBuild extends the arms for construction and AnimClose returns them to\r\n-- Rest; the host samples exact seconds when a transition reverses.\r\nUnitTemplate.additions.uefEngineerBuildAnimation = {\r\n    openAnimationKey = \"build\",\r\n    closeAnimationKey = \"close\",\r\n    restAnimationKey = \"walk\",\r\n    durationSeconds = " + text2 + ",\r\n    authoredRate = 1,\r\n    sourceClipRate = 5,\r\n    exactTimeOwner = \"coordinator -10000 progress-frame sentinel\",\r\n}";
	}

	private static string BuildHostClassOverride()
	{
		return "\r\n-- Guard/EDA Engineer Cache Patcher 1.2.1\r\n-- The corrected Rest pose is AnimBuild[0] and AnimClose[end].\r\n-- Exact-time sampling preserves the current tool pose across pause, cancel,\r\n-- and restart instead of replaying either transition from its endpoint.\r\nlocal EDAEngineer = HostEDAEngineer or EDAEngineer\r\nif not EDAEngineer then\r\n    error(\"SCO could not resolve the host EDA engineer base class.\")\r\nend\r\nHostEDAUefEngineer = Class(\"EDAUefEngineer\", EDAEngineer)\r\nlocal EDAUefEngineer = HostEDAUefEngineer\r\nlocal SCO_UefEngineerBuildSentinelBase = -10000\r\n\r\nlocal function SCO_UefEngineerBuildAlive(unit)\r\n    return unit ~= nil and not unit.dead and not unit.deleted\r\nend\r\n\r\nlocal function SCO_UefEngineerBuildConfig(unit)\r\n    local additions = unit.tp and unit.tp.additions\r\n    local config = additions and additions.uefEngineerBuildAnimation\r\n    if not config then\r\n        return nil\r\n    end\r\n\r\n    local animations = unit.tp.visuals and unit.tp.visuals.animations\r\n    local opening = animations and animations[config.openAnimationKey]\r\n    local closing = animations and animations[config.closeAnimationKey]\r\n    local rest = animations and animations[config.restAnimationKey]\r\n    if type(config.durationSeconds) ~= \"number\"\r\n        or config.durationSeconds <= 0\r\n        or type(config.authoredRate) ~= \"number\"\r\n        or config.authoredRate <= 0\r\n        or not opening or opening.id == nil\r\n        or not closing or closing.id == nil\r\n        or not rest or rest.id == nil\r\n    then\r\n        error((unit.tpId or \"UEF engineer\")\r\n            .. \" has an invalid reversible build-animation contract\")\r\n    end\r\n    return config, opening, closing, rest\r\nend\r\n\r\nlocal function SCO_UefEngineerBuildSample(unit, animation, seconds)\r\n    Engine.PlayAnimation(\r\n        unit.id,\r\n        animation.id,\r\n        SCO_UefEngineerBuildSentinelBase + seconds)\r\nend\r\n\r\nfunction EDAUefEngineer:SetupAnimations()\r\n    local result = EDAEngineer.SetupAnimations(self)\r\n    local config, _, _, rest = SCO_UefEngineerBuildConfig(self)\r\n    if config then\r\n        -- Native prefabs keep the animator disabled until construction ends,\r\n        -- exposing this rig's extended bind pose on the factory floor.\r\n        self.scoUefEngineerBuildSample = 0\r\n        self.scoUefEngineerBuildAtRest = true\r\n        self:SetAnimatorEnabled(true)\r\n        SCO_UefEngineerBuildSample(self, rest, 0)\r\n    end\r\n    return result\r\nend\r\n\r\nlocal function SCO_UefEngineerBuildTransitionThread(\r\n    unit,\r\n    generation,\r\n    opening)\r\n    local config, openAnimation, closeAnimation, rest =\r\n        SCO_UefEngineerBuildConfig(unit)\r\n    if not config then\r\n        return\r\n    end\r\n\r\n    local duration = config.durationSeconds\r\n    local sample = math.max(\r\n        0,\r\n        math.min(duration, unit.scoUefEngineerBuildSample or 0))\r\n    while SCO_UefEngineerBuildAlive(unit)\r\n        and unit.scoUefEngineerBuildGeneration == generation\r\n        and ((opening and sample < duration)\r\n            or (not opening and sample > 0))\r\n    do\r\n        if opening then\r\n            -- Exact-time ownership begins at the Rest-facing frame. Keeping\r\n            -- frame zero sampled until the next scheduler slice makes a\r\n            -- first-tick pause/cancel reverse from the pose actually shown.\r\n            SCO_UefEngineerBuildSample(unit, openAnimation, sample)\r\n            unit.scoUefEngineerBuildAtRest = nil\r\n        else\r\n            SCO_UefEngineerBuildSample(\r\n                unit,\r\n                closeAnimation,\r\n                duration - sample)\r\n        end\r\n        unit.scoUefEngineerBuildSample = sample\r\n        WaitTicks(1)\r\n        local delta = Constants.TickTimeStep * config.authoredRate\r\n        if opening then\r\n            sample = math.min(duration, sample + delta)\r\n        else\r\n            sample = math.max(0, sample - delta)\r\n        end\r\n    end\r\n\r\n    if not SCO_UefEngineerBuildAlive(unit)\r\n        or unit.scoUefEngineerBuildGeneration ~= generation\r\n    then\r\n        return\r\n    end\r\n\r\n    unit.scoUefEngineerBuildSample = sample\r\n    if opening then\r\n        SCO_UefEngineerBuildSample(unit, openAnimation, sample)\r\n        unit.scoUefEngineerBuildAtRest = nil\r\n    else\r\n        Engine.PlayAnimation(unit.id, rest.id, 0.1)\r\n        unit.scoUefEngineerBuildAtRest = true\r\n    end\r\nend\r\n\r\nfunction EDAUefEngineer:SCO_SetBuildAnimationState(opening)\r\n    local additions = self.tp and self.tp.additions\r\n    if not additions or not additions.uefEngineerBuildAnimation then\r\n        return\r\n    end\r\n    self.scoUefEngineerBuildGeneration =\r\n        (self.scoUefEngineerBuildGeneration or 0) + 1\r\n    self:NewThread(\r\n        SCO_UefEngineerBuildTransitionThread,\r\n        self.scoUefEngineerBuildGeneration,\r\n        opening)\r\nend\r\n\r\nfunction EDAUefEngineer:OnStopBeingBuilt(...)\r\n    local result = EDAEngineer.OnStopBeingBuilt(self, ...)\r\n    local additions = self.tp and self.tp.additions\r\n    if additions and additions.uefEngineerBuildAnimation then\r\n        self.scoUefEngineerBuildGeneration =\r\n            (self.scoUefEngineerBuildGeneration or 0) + 1\r\n        self.scoUefEngineerBuildSample = 0\r\n        self.scoUefEngineerBuildAtRest = true\r\n    end\r\n    return result\r\nend\r\n\r\nfunction EDAUefEngineer:OnStartBuildRoutine(targetUnit)\r\n    local result = EDAEngineer.OnStartBuildRoutine(self, targetUnit)\r\n    self:SCO_SetBuildAnimationState(true)\r\n    return result\r\nend\r\n\r\nfunction EDAUefEngineer:OnStopBuildRoutine(targetUnit)\n    local result = EDAEngineer.OnStopBuildRoutine(self, targetUnit)\n    if not self:IsRepairRoutineEnabled()\n        and not self:IsReclaimRoutineEnabled()\n    then\n        self:SCO_SetBuildAnimationState(false)\n    end\n    return result\nend\n\n-- Native construction assistance uses build callbacks; completed-target repair\n-- and reclaim use their own routine callbacks and need the same reversible\n-- tool transition. A stop closes the arm only after every native work routine\n-- has released it.\nfunction EDAUefEngineer:OnStartRepairRoutine(targetUnit)\n    local result = EDAEngineer.OnStartRepairRoutine(self, targetUnit)\n    self:SCO_SetBuildAnimationState(true)\n    return result\r\nend\r\n\r\nfunction EDAUefEngineer:OnStopRepairRoutine(targetUnit)\n    local result = EDAEngineer.OnStopRepairRoutine(self, targetUnit)\n    if not self:IsBuildRoutineEnabled()\n        and not self:IsReclaimRoutineEnabled()\n    then\n        self:SCO_SetBuildAnimationState(false)\n    end\n    return result\nend\n\nfunction EDAUefEngineer:OnStartReclaimRoutine(targetUnit)\n    local result = EDAEngineer.OnStartReclaimRoutine(self, targetUnit)\n    self:SCO_SetBuildAnimationState(true)\n    return result\nend\n\nfunction EDAUefEngineer:OnStopReclaimRoutine(targetUnit)\n    local result = EDAEngineer.OnStopReclaimRoutine(self, targetUnit)\n    if not self:IsBuildRoutineEnabled()\n        and not self:IsRepairRoutineEnabled()\n    then\n        self:SCO_SetBuildAnimationState(false)\n    end\n    return result\nend\n\r\nfunction EDAUefEngineer:OnDestroy(...)\r\n    self.scoUefEngineerBuildGeneration =\r\n        (self.scoUefEngineerBuildGeneration or 0) + 1\r\n    return EDAEngineer.OnDestroy(self, ...)\r\nend";
	}

	private static string GuardTemplateOverride(EngineerGameplaySpec source, string constructionBone, string buildBeamBones, string boundsOverride)
	{
		string text = SourceGameplayOverride(source);
		return "\n-- Guard/EDA Engineer Cache Patcher 1.2.1\n-- This imported Cybran crawler uses its own native skeleton. Keep its\n-- AmphibiousFloating movement through Sanctuary's supported\n-- TracksAmphibious equivalent; remap construction data, remove invalid\n-- hover VFX, and use measured mesh bounds.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.buildBeamBones = { " + buildBeamBones + " }\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.beam = UnitTemplate.construction.beam or {}\nUnitTemplate.construction.beam.boneName = \"" + constructionBone + "\"\nUnitTemplate.construction.beam.offset = { x = 0, y = 0, z = 0 }\n" + text + "\nUnitTemplate.visuals.effectsPersistent = nil\n\n" + boundsOverride + "\n\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do\n            effect.boneName = \"Root\"\n        end\n    end\nend";
	}

	private static string EdaTemplateOverride(EngineerGameplaySpec source, string constructionBone, string buildBeamBones, string boundsOverride)
	{
		string text = SourceGameplayOverride(source);
		return "\n-- Guard/EDA Engineer Cache Patcher 1.2.1\n-- The personal pack supplies this engineer's native UEF mesh, skin IDs,\n-- skeleton/bind poses, and real build-open clip. No EDA crawl trails,\n-- substation add-on mesh, or generic Root beam is compatible with it.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.buildBeamBones = { " + buildBeamBones + " }\nUnitTemplate.additions.multiConstructionBeam = {\n    prefabName = \"SCOM.EDAUefEngineerBeam\",\n    materialPath = \"VFX/SCOM/ConstructionBeams/uef.sanmaterial\",\n    shrink = 0.05,\n}\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.beam = UnitTemplate.construction.beam or {}\nUnitTemplate.construction.beam.boneName = \"" + constructionBone + "\"\nUnitTemplate.construction.beam.offset = { x = 0, y = 0, z = 0 }\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.general.class = {\n    \"unitsDefaultEDA\",\n    \"EDAUefEngineer\",\n}\nUnitTemplate.visuals.animations = {\n    build = {\n        clipName = \"AnimBuild\",\n        sanAnimationPath = \"Units/" + source.TargetId + "/LOD0/" + source.TargetId + ".sananimation\",\n        playbackMode = 0, -- AnimationPlaybackMode.Clamp\n    },\n    close = {\n        clipName = \"AnimClose\",\n        sanAnimationPath = \"Units/" + source.TargetId + "/LOD0/" + source.TargetId + ".sananimation\",\n        playbackMode = 0, -- AnimationPlaybackMode.Clamp\n    },\n    walk = {\n        clipName = \"Rest\",\n        sanAnimationPath = \"Units/" + source.TargetId + "/LOD0/" + source.TargetId + ".sananimation\",\n    },\n}\n\n" + text + "\n\n-- Measured imported-mesh collision, selection, and movement space.\n" + boundsOverride + "\n\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do\n            effect.boneName = \"Root\"\n        end\n    end\nend";
	}

	private static string SourceGameplayOverride(EngineerGameplaySpec source)
	{
		string text = source.ReverseSpeed.ToString("0.###", CultureInfo.InvariantCulture);
		string text2 = (source.SourceId.StartsWith("URL", StringComparison.Ordinal) ? "URL" : "UEL");
		return string.Format("-- Exact FA engineer gameplay. Imported FA sound banks are not shipped;\n-- retain Sanctuary's faction-compatible speed-driven mobile engine loop.\nUnitTemplate.additions.faSourceContract = {{\n    mapping = \"{0} -> {1}\",\n    sourceArchiveSha256 = \"{2}\",\n    sourceBlueprint = \"units/{3}/{4}_unit.bp\",\n    sourceBlueprintSha256 = \"{5}\",\n    sourceScript = \"units/{6}/{7}_script.lua\",\n    sourceScriptSha256 = \"{8}\",\n    sourceMovement = {{\n        type = \"RULEUMT_AmphibiousFloating\",\n        sanctuaryType = \"TracksAmphibious\",\n        maxBrake = 1.9,\n        maxReverseSpeed = {9},\n        independentBrakeSupported = false,\n        independentReverseSupported = false,\n    }},\n    sourceTeleportEnergyMod = 0.15,\n    sanctuaryTeleportSupported = false,\n    sourceAudio = {{\n        bank = \"{10}\",\n        ambientMoveCue = \"{11}_Move_Loop\",\n        bankImported = false,\n        sanctuaryDonorMovementLoopRetained = true,\n    }},\n}}\nUnitTemplate.defence = UnitTemplate.defence or {{}}\nUnitTemplate.defence.health = {{ max = {12}, regen = 0, value = {13} }}\nUnitTemplate.economy = UnitTemplate.economy or {{}}\nUnitTemplate.economy.buildTime = {14}\nUnitTemplate.economy.cost = {{ alloys = {15}, energy = {16} }}\nUnitTemplate.economy.storage = {{ alloys = {17}, energy = 0 }}\nUnitTemplate.intel = UnitTemplate.intel or {{}}\nUnitTemplate.intel.visionRadius = {18}\nUnitTemplate.construction.buildPower = {19}\nUnitTemplate.construction.range = 5\nUnitTemplate.construction.canBuild = \"Tags.{20} * Tags.BUILDABLE_BY_T{21}_ENGINEER\"\nUnitTemplate.movement = UnitTemplate.movement or {{}}\nUnitTemplate.movement.type = \"TracksAmphibious\"\nUnitTemplate.movement.speed = 1.9\nUnitTemplate.movement.acceleration = 1.9\nUnitTemplate.movement.rotationSpeed = 120\n\nlocal SCO_EngineerSourceTags = {{}}\nfor _, tag in ipairs(UnitTemplate.tags or {{}}) do\n    if tag ~= \"ALLOYS_STORAGE\" and tag ~= \"ENERGY_STORAGE\" then\n        table.insert(SCO_EngineerSourceTags, tag)\n    end\nend\ntable.insert(SCO_EngineerSourceTags, \"ALLOYS_STORAGE\")\nUnitTemplate.tags = SCO_EngineerSourceTags", source.SourceId, source.TargetId, "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26", source.SourceId, source.SourceId, source.BlueprintSha256, source.SourceId, source.SourceId, source.ScriptSha256, text, text2, source.SourceId, source.Health, source.Health, source.BuildTime, source.Alloys, source.Energy, source.AlloyStorage, source.Vision, source.BuildPower, source.Faction, source.Tier);
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("The loaded Trebuchet assembly does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static bool TryGetCachedResource(object cache, PatchSpec spec, out CachedResource resource)
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
			resource = new CachedResource(spec, fullPath, obj2);
			return true;
		}
		string value = "/" + spec.RelativePath;
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
					throw new InvalidOperationException("More than one cached resource matches the exact " + spec.RelativePath + " suffix.");
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
		resource = new CachedResource(spec, text, obj3);
		return true;
	}

	private static object AppendOverride(object stockResource, string appendix)
	{
		Type type = stockResource.GetType();
		byte[] nativeArrayBytes = GetNativeArrayBytes(type, stockResource);
		byte[] bytes = Encoding.UTF8.GetBytes(appendix);
		return NativeArrayByteFactory.CreatePersistent(type, nativeArrayBytes, bytes);
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void RollBackAndDispose(object cache, IEnumerable<CachedResource> resources)
	{
		foreach (CachedResource item in resources.Reverse())
		{
			bool flag = !item.ReplacementWasAssigned;
			if (item.ReplacementWasAssigned)
			{
				try
				{
					SetCachedResource(cache, item.Path, item.Stock);
					flag = true;
				}
				catch (Exception arg)
				{
					Log($"Rollback failed for {item.Spec.Description}: {arg}");
				}
			}
			if (flag && item.Replacement != null && IsNativeArrayCreated(item.Replacement))
			{
				TryDisposeNativeArray(item.Replacement.GetType(), item.Replacement, "replacement " + item.Spec.Description);
			}
		}
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
			(nativeArrayType.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "Dispose")).Invoke(nativeArray, null);
		}
		catch (Exception arg)
		{
			Log($"Could not dispose {description}: {arg}");
		}
	}

	private static bool ContainsOverride(object resource)
	{
		if (IsNativeArrayCreated(resource))
		{
			return Encoding.UTF8.GetString(GetNativeArrayBytes(resource.GetType(), resource)).IndexOf("-- Guard/EDA Engineer Cache Patcher 1.2.1", StringComparison.Ordinal) >= 0;
		}
		return false;
	}

	private static void Log(string message)
	{
		string text = "[Guard/EDA Engineer Cache Patcher] " + message;
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
