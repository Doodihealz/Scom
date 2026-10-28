using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using SupremeCommanderOverhaul.Shared;

namespace AeonChosenRosterCachePatcher;

public static class CachePatcherRuntime
{
	private sealed class AeonFactoryRoutingSpec
	{
		internal string SourceId { get; }

		internal string TargetId { get; }

		internal string ClassName { get; }

		internal string Kind { get; }

		internal string BuildBone { get; }

		internal IReadOnlyList<string> BuildBeamBones { get; }

		internal double BuildStagingX { get; }

		internal double BuildStagingY { get; }

		internal double BuildStagingZ { get; }

		internal string ModelSha256 { get; }

		internal AeonFactoryRoutingSpec(string sourceId, string targetId, string className, string kind, string buildBone, string[] buildBeamBones, double buildStagingX, double buildStagingY, double buildStagingZ, string modelSha256)
		{
			SourceId = sourceId;
			TargetId = targetId;
			ClassName = className;
			Kind = kind;
			BuildBone = buildBone;
			BuildBeamBones = buildBeamBones;
			BuildStagingX = buildStagingX;
			BuildStagingY = buildStagingY;
			BuildStagingZ = buildStagingZ;
			ModelSha256 = modelSha256;
		}
	}

	private sealed class SourceTagMapping
	{
		internal string Source { get; }

		internal string Target { get; }

		internal SourceTagMapping(string source, string target)
		{
			Source = source;
			Target = target;
		}
	}

	private sealed class AnimationEntry
	{
		internal string Key { get; }

		internal string ClipName { get; }

		internal double AuthoredSpeed { get; }

		internal AnimationEntry(string key, string clipName, double authoredSpeed)
		{
			Key = key;
			ClipName = clipName;
			AuthoredSpeed = authoredSpeed;
		}
	}

	private sealed class PatchSpec
	{
		internal string RelativePath { get; }

		internal string Description { get; }

		internal string Appendix { get; }

		internal bool IsTemplateReplacement { get; }

		internal string TargetId { get; }

		internal Func<string, string>? Transform { get; }

		internal PatchSpec(string relativePath, string description, string appendix, bool isTemplateReplacement = false, string targetId = "", Func<string, string>? transform = null)
		{
			if (isTemplateReplacement != !string.IsNullOrWhiteSpace(targetId))
			{
				throw new ArgumentException("Template replacements require exactly one target identity.");
			}
			RelativePath = relativePath;
			Description = description;
			IsTemplateReplacement = isTemplateReplacement;
			TargetId = targetId;
			Transform = transform;
			Appendix = "\n\n-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0\n" + appendix.TrimStart('\r', '\n');
		}
	}

	private sealed class CachedResource
	{
		internal PatchSpec Spec { get; }

		internal string Path { get; }

		internal object Stock { get; }

		internal object? Replacement { get; set; }

		internal bool AssignmentWasAttempted { get; set; }

		internal CachedResource(PatchSpec spec, string path, object stock)
		{
			Spec = spec;
			Path = path;
			Stock = stock;
		}
	}

	private const string OverrideMarker = "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0";

	private const string TemplatePathPrefix = "LJ/lua/common/units/unitsTemplates/";

	private const string HostChosenClassesPath = "LJ/lua/host/units/unitsClasses/unitsDefaultChosen.lua";

	private const string HostDefaultClassesPath = "LJ/lua/host/units/unitsClasses/unitsDefault.lua";

	private const string ClientChosenClassesPath = "LJ/lua/client/units/unitsClasses/unitsDefaultChosen.lua";

	private const string AvailableUnitsPath = "LJ/lua/common/units/availableUnits.lua";

	private const string QuickLaunchUnitsPath = "LJ/lua/common/units/quickLaunchUnits.lua";

	private const string HostWeaponsBasePath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	private const string ClientContinuousBeamPath = "LJ/lua/client/entities/clientContinuousBeam.lua";

	private const string ClientContinuousBeamReturn = "return { ClientContinuousBeam = ClientContinuousBeam }";

	private const string ClientListenersPath = "LJ/lua/client/clientListeners.lua";

	private const string UnitTemplateLoaderPath = "LJ/lua/common/loading/unitTemplateLoader.lua";

	private const double CzarBeamCoreWidthScale = 1.0;

	private const double CzarBeamDistortionWidthScale = 1.0;

	private const string CzarBeamModel = "VFX/SupremeCommanderOverhaul/Czar/Models/czar_quantum_beam_cylinder.sanmodel";

	private const string CzarBeamDistortionMaterial = "VFX/SupremeCommanderOverhaul/Czar/Materials/czar_quantum_beam_distortion.sanmaterial";

	private const string GalacticColossusEyeCoreMaterial = "VFX/AeonProjectiles/Materials/GalacticColossus/galactic_colossus_eye_core.sanmaterial";

	private const string GalacticColossusEyeAuraMaterial = "VFX/AeonProjectiles/Materials/GalacticColossus/galactic_colossus_eye_aura.sanmaterial";

	private const string GalacticColossusTractorBeamMaterial = "VFX/AeonProjectiles/Materials/GalacticColossus/galactic_colossus_tractor_beam.sanmaterial";

	private const string GalacticColossusTractorBeamModel = "VFX/AeonProjectiles/Models/GalacticColossus/galactic_colossus_tractor_beam.sanmodel";

	private static readonly string[] InstalledChosenTargetIds = new string[94]
	{
		"uca1001", "uca1201", "uca1502", "uca1701", "uca2011", "uca2101", "uca2301", "uca2502", "uca2701", "uca2806",
		"uca3001", "uca3011", "uca3201", "uca3701", "uca4011", "ucl1001", "ucl1002", "ucl1101", "ucl1201", "ucl1501",
		"ucl1701", "ucl2002", "ucl2101", "ucl2201", "ucl2501", "ucl2806", "ucl3001", "ucl3101", "ucl3501", "ucl3701",
		"ucl3801", "ucl4001", "ucl4002", "ucl4003", "ucl4004", "ucl4005", "ucl4401", "ucn1001", "ucn3001", "ucs1001",
		"ucs1201", "ucs1301", "ucs1501", "ucs1511", "ucs1512", "ucs1513", "ucs1601", "ucs1602", "ucs1611", "ucs1612",
		"ucs1614", "ucs1701", "ucs1702", "ucs1801", "ucs1802", "ucs1803", "ucs1804", "ucs2001", "ucs2101", "ucs2102",
		"ucs2201", "ucs2301", "ucs2401", "ucs2402", "ucs2501", "ucs2510", "ucs2511", "ucs2512", "ucs2513", "ucs2601",
		"ucs2611", "ucs2701", "ucs2702", "ucs2711", "ucs2801", "ucs2802", "ucs2803", "ucs2806", "ucs3001", "ucs3101",
		"ucs3102", "ucs3201", "ucs3401", "ucs3402", "ucs3501", "ucs3511", "ucs3512", "ucs3513", "ucs3601", "ucs3603",
		"ucs3611", "ucs3701", "ucs3702", "ucs4102"
	};

	public static bool IsApplied { get; private set; }

	private static AeonFactoryRoutingSpec[] CreateAeonFactoryRoutingSpecs()
	{
		return new AeonFactoryRoutingSpec[9]
		{
			new AeonFactoryRoutingSpec("UAB0101", "ucs1511", "AeonPortLandFactory", "land", "Attachpoint", new string[1] { "Tier1_Arm_Refpoint" }, -0.0075623453594744205, 0.15511077642440796, -0.35434505343437195, "42045b5e5a187cff77b08a7f519f629a21bcc3a4c800989a70c616083c7ea8c6"),
			new AeonFactoryRoutingSpec("UAB0201", "ucs2511", "AeonPortLandFactory", "land", "Attachpoint", new string[2] { "Tier1_Arm_Refpoint", "Tier2_Arm_Refpoint" }, 0.003009234322234988, 0.12780076265335083, -0.3464999794960022, "aa6d6b22e80b197f949ea52d41d4b523ed56cd5fd82eb8b583b6d9a3f6501d8b"),
			new AeonFactoryRoutingSpec("UAB0301", "ucs3511", "AeonPortLandFactory", "land", "Attachpoint", new string[3] { "Tier1_Arm_Refpoint", "Tier2_Arm_Refpoint", "Tier3_Arm_Refpoint" }, 0.003009234322234988, 0.12780076265335083, -0.3464999794960022, "f469905a44ba3c67e145f9f9631bb3517241752748c91f93c229fc8081d000c5"),
			new AeonFactoryRoutingSpec("UAB0102", "ucs1512", "AeonPortAirFactory", "air", "Attachpoint", new string[1] { "Turret_Muzzle_02" }, 0.0, 0.7099999785423279, -4.1480610613042757E-10, "913030238e2fdf9be899c772345a4e63da39cc00054c7ed3263c910f3d1054ea"),
			new AeonFactoryRoutingSpec("UAB0202", "ucs2512", "AeonPortAirFactory", "air", "Attachpoint", new string[2] { "Turret_Muzzle_01", "Turret_Muzzle_02" }, 0.0, 0.7099999785423279, 8.733400965301244E-15, "496b01a3340ca3fe5bb7c1557194dd9e80ea8f640e6303b2126d67784fd67c06"),
			new AeonFactoryRoutingSpec("UAB0302", "ucs3512", "AeonPortAirFactory", "air", "Attachpoint", new string[3] { "Turret_Muzzle_01", "Turret_Muzzle_02", "Turret_Muzzle_03" }, 0.0002561488072387874, 0.6849361062049866, 5.91340649407357E-05, "92765eb9e27a5e10f190fd79d4c26207bf6626fb42860f7d3b683604c9c8f9de"),
			new AeonFactoryRoutingSpec("UAB0103", "ucs1513", "AeonPortNavalFactory", "naval", "Attachpoint01", new string[1] { "Turret_Muzzle_01" }, 4.050000190734863, 0.009999657049775124, 4.779702067025937E-06, "c3b344852b759d82da977ad607d6f6d22b2c0d41e756c1b547ea7e4b9df34310"),
			new AeonFactoryRoutingSpec("UAB0203", "ucs2513", "AeonPortNavalFactory", "naval", "Attachpoint01", new string[2] { "Turret_Muzzle_01", "Turret_Muzzle_02" }, 4.050000190734863, 0.009999657049775124, 4.779702067025937E-06, "1720076166348179062979578d48e853f8ee8575aede272dc51992054d532702"),
			new AeonFactoryRoutingSpec("UAB0303", "ucs3513", "AeonPortNavalFactory", "naval", "Attachpoint01", new string[3] { "Turret_Muzzle_01", "Turret_Muzzle_02", "Turret_Muzzle_03" }, 4.050000190734863, 0.009999657049775124, 4.779702067025937E-06, "1748fd75441c6be92b1af8f4b16ec8b8c34fd2def780c9ba3b11117b464531c2")
		};
	}

	public static void Apply()
	{
		IsApplied = false;
		List<CachedResource> list = new List<CachedResource>();
		object obj = null;
		bool flag = false;
		try
		{
			PatchSpec[] array = CreatePatchSpecs();
			list.Capacity = array.Length;
			obj = GetLuaFileCache();
			PatchSpec[] array2 = array;
			foreach (PatchSpec patchSpec in array2)
			{
				if (!TryGetCachedResource(obj, patchSpec, out CachedResource resource))
				{
					throw new FileNotFoundException("Required " + patchSpec.Description + " is absent from the Lua cache.", patchSpec.RelativePath);
				}
				if (HasOverrideMarker(resource.Stock))
				{
					ValidatePatchedResource(patchSpec, resource.Stock);
					continue;
				}
				if (patchSpec.IsTemplateReplacement)
				{
					ValidateInstalledTargetIdentity(patchSpec, GetNativeArrayBytes(resource.Stock.GetType(), resource.Stock));
				}
				if (patchSpec.IsTemplateReplacement)
				{
					byte[] array3 = LoadEmbeddedTemplate(patchSpec);
					ValidateEmbeddedScaffoldIdentity(patchSpec, array3);
					resource.Replacement = NativeArrayByteFactory.CreatePersistent(resource.Stock.GetType(), array3, Encoding.UTF8.GetBytes(patchSpec.Appendix));
				}
				else
				{
					resource.Replacement = ((patchSpec.Transform == null) ? AppendOverride(resource.Stock, patchSpec.Appendix) : TransformOverride(resource.Stock, patchSpec.Appendix, patchSpec.Transform));
				}
				list.Add(resource);
				ValidatePatchedResource(patchSpec, resource.Replacement);
			}
			if (list.Count == 0)
			{
				IsApplied = true;
				Log($"All {GeneratedAeonPortSpecs.All.Length} one-for-one Aeon " + "Chosen replacements are already active.");
				return;
			}
			foreach (CachedResource item in list)
			{
				item.AssignmentWasAttempted = true;
				SetCachedResource(obj, item.Path, item.Replacement);
				ValidateAssignedResource(obj, item);
			}
			flag = true;
			foreach (CachedResource item2 in list)
			{
				TryDisposeNativeArray(item2.Stock.GetType(), item2.Stock, "stock " + item2.Spec.Description);
			}
			IsApplied = true;
			Log($"Committed {GeneratedAeonPortSpecs.All.Length} one-for-one " + "Aeon-over-Chosen template replacements " + $"({GeneratedAeonPortSpecs.All.Count((GeneratedPortSpec port) => port.RosterVisible)} visible), " + "host/client classes, explicit player/AI roster ownership, authored mobile navigation and source braking where exposed, native hover/air preferred-altitude flight, Czar +25 preferred altitude, 5x mobile render distance, visible radial fixed-down center beam and collision-free ground-target approach, host-authoritative Galactic Colossus tractor pull/crush with scoped client VFX, air-only secondary AA, and mobile aircraft production, unchanged cache keys, and preserved commander spawn. Manifest=14e172d2796065a956dd18bd1c1ddab9462df8eff65c5990e4e8364c162861df.");
		}
		catch (Exception ex)
		{
			IsApplied = false;
			Exception ex2 = null;
			if (!flag && obj != null)
			{
				try
				{
					RollBackAndDispose(obj, list);
				}
				catch (Exception ex3)
				{
					ex2 = ex3;
				}
			}
			Exception ex4 = ((ex2 == null) ? ex : new AggregateException(ex, ex2));
			Log("One-for-one Aeon replacement failed closed" + ((ex2 == null) ? " after a complete rollback. " : " with an incomplete rollback. ") + ex4);
			throw new InvalidOperationException("The one-for-one Aeon cache transaction did not commit.", ex4);
		}
	}

	private static PatchSpec[] CreatePatchSpecs()
	{
		AeonFactoryRoutingSpec[] array = CreateAeonFactoryRoutingSpecs();
		Dictionary<string, AeonFactoryRoutingSpec> dictionary = array.ToDictionary<AeonFactoryRoutingSpec, string>((AeonFactoryRoutingSpec spec) => spec.SourceId, StringComparer.Ordinal);
		if (GeneratedAeonPortSpecs.All.Length != 94)
		{
			throw new InvalidOperationException("Generated Aeon manifest must contain exactly 94 replacement ports.");
		}
		ValidateAeonFactoryRoutingInventory(array, dictionary);
		HashSet<string> hashSet = new HashSet<string>(StringComparer.Ordinal);
		List<PatchSpec> list = new List<PatchSpec>(GeneratedAeonPortSpecs.All.Length + 11);
		GeneratedPortSpec[] all = GeneratedAeonPortSpecs.All;
		foreach (GeneratedPortSpec generatedPortSpec in all)
		{
			ValidatePort(generatedPortSpec);
			if (!hashSet.Add(generatedPortSpec.TargetId))
			{
				throw new InvalidOperationException("Generated Aeon target " + generatedPortSpec.TargetId + " is duplicated.");
			}
			list.Add(new PatchSpec("LJ/lua/common/units/unitsTemplates/" + generatedPortSpec.TargetId + "/" + generatedPortSpec.TargetId + ".santp", generatedPortSpec.TargetId + " <- " + generatedPortSpec.SourceId + " template", BuildTemplateAppendix(generatedPortSpec, dictionary), isTemplateReplacement: true, generatedPortSpec.TargetId));
		}
		ValidateInstalledTargetSet(hashSet);
		if (!new HashSet<string>(from port in GeneratedAeonPortSpecs.All
			where port.Shield.Enabled
			select port.SourceId, StringComparer.Ordinal).SetEquals(new string[5] { "UAB4202", "UAB4301", "UAL0202", "UAL0303", "UAL0307" }))
		{
			throw new InvalidOperationException("Generated Aeon shield-source inventory changed.");
		}
		if (!new HashSet<string>(from port in GeneratedAeonPortSpecs.All
			where port.Movement.SourceMotionType == "RULEUMT_Air"
			select port.SourceId, StringComparer.Ordinal).SetEquals(new string[14]
		{
			"UAA0101", "UAA0102", "UAA0103", "UAA0104", "UAA0107", "UAA0203", "UAA0204", "UAA0302", "UAA0303", "UAA0304",
			"UAA0310", "XAA0202", "XAA0305", "XAA0306"
		}))
		{
			throw new InvalidOperationException("Generated Aeon aircraft-source inventory changed.");
		}
		if (!new HashSet<string>(from port in GeneratedAeonPortSpecs.All
			where port.Movement.SanctuaryType == "Gunship"
			select port.SourceId, StringComparer.Ordinal).SetEquals(new string[5] { "UAA0104", "UAA0107", "UAA0203", "UAA0310", "XAA0305" }) || GeneratedAeonPortSpecs.All.Count((GeneratedPortSpec port) => port.Movement.SanctuaryType == "Plane") != 9)
		{
			throw new InvalidOperationException("Generated Aeon Winged aircraft classification changed.");
		}
		list.Add(new PatchSpec("LJ/lua/host/units/unitsClasses/unitsDefault.lua", "factory-child collider promotion guard", BuildHostColliderPromotionAppendix()));
		list.Add(new PatchSpec("LJ/lua/host/units/unitsClasses/unitsDefaultChosen.lua", "host one-for-one Aeon classes", BuildHostClassAppendix() + BuildHostCzarCrashAppendix() + BuildAeonEngineerHostAnimationAppendix()));
		list.Add(new PatchSpec("LJ/lua/client/units/unitsClasses/unitsDefaultChosen.lua", "client one-for-one Aeon classes", DeferCzarImpactPrefabLoad(BuildClientClassAppendix())));
		list.Add(new PatchSpec("LJ/lua/common/units/availableUnits.lua", "explicit Aeon available-unit roster", BuildRosterAppendix("AvailableUnits")));
		list.Add(new PatchSpec("LJ/lua/common/units/quickLaunchUnits.lua", "explicit Aeon quick-launch roster", BuildRosterAppendix("QuickLaunchUnits")));
		list.Add(new PatchSpec("LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", "Galactic Colossus tractor-claw host behavior", BuildHostWeaponAppendixForSanctuary()));
		list.Add(new PatchSpec("LJ/lua/client/entities/clientContinuousBeam.lua", "Galactic Colossus tractor-claw client beam lifecycle", BuildClientContinuousBeamAppendix(), isTemplateReplacement: false, "", StripClientContinuousBeamModuleReturn));
		list.Add(new PatchSpec("LJ/lua/client/clientListeners.lua", "Galactic Colossus tractor-claw crush listener", BuildClientListenerAppendix()));
		list.Add(new PatchSpec("LJ/lua/common/loading/unitTemplateLoader.lua", "Aeon construction-beam material and Czar render distance", "", isTemplateReplacement: false, "", TransformUnitTemplateLoader));
		list.Add(new PatchSpec("LJ/lua/host/hostMain.lua", "synchronized initial commander arrival", "-- SCO_CommanderArrivalHost_v1\n-- Appended inside hostMain; only the canonical initial-unit call opens this cohort.\nlocal scoArrivalIds = {uel0000=true, ugl0000=true, ucl0000=true, usl0000=true}\nlocal scoArrivalSession = Import(\"common/commands/definitions/session.lua\")\nlocal scoArrivalLobby = Import(\"common/lobby.lua\")\nlocal scoArrivalStockStart = Start\nlocal scoArrivalState\nlocal scoArrivalStarted = false\n\nlocal function scoArrivalSend(name, state, units)\n    scoArrivalSession.ExecuteClientFunction.Send(name, {\n        version = 2,\n        sequence = 1,\n        phase = state.phase,\n        startTick = state.startTick,\n        effectTick = state.effectTick,\n        revealTick = state.releaseTick,\n        releaseTick = state.releaseTick,\n        units = units or state.units,\n    })\nend\n\nlocal function scoArrivalAcceptReady(data, clientId)\n    local state = scoArrivalState\n    if not state or type(data) ~= \"table\" or data.version ~= 2\n        or data.sequence ~= 1 or data.phase ~= state.phase\n        or not state.clients[clientId] or not scoArrivalLobby.Players[clientId] then\n        return false\n    end\n    state.ready[clientId] = true\n    return true\nend\n\n-- The ordinary named-function bridge drops sender identity. Intercept only this\n-- acknowledgment while the registry still supplies its authenticated command.\nlocal scoArrivalReceiveHostFunction = scoArrivalSession.ExecuteHostFunction.Receive\nfunction scoArrivalSession.ExecuteHostFunction.Receive(data, command)\n    local call = json.decode(data.call)\n    if call.functionName == \"SCOCommanderArrivalReady\" then\n        return scoArrivalAcceptReady(call.functionData, command and command.clientID)\n    end\n    return scoArrivalReceiveHostFunction(data, command)\nend\n\nlocal function scoArrivalAllReady(state)\n    for clientId in pairs(state.clients) do\n        if scoArrivalLobby.Players[clientId] and not state.ready[clientId] then return false end\n    end\n    return true\nend\n\nlocal function scoArrivalRestore(state)\n    for _, saved in ipairs(state.savedUnits) do\n        local unit = saved.unit\n        if not unit.dead and __Entities.Units[unit.id.index] == unit then\n            unit.canTakeDamage = saved.canTakeDamage\n            unit.canBeKilled = saved.canBeKilled\n            unit.isTargetable = saved.isTargetable\n        end\n    end\nend\n\nfunction SCOSpawnInitialUnits(gameUtils)\n    if scoArrivalStarted then return end\n    if Engine.GetSimulationTick() ~= 0 then\n        return gameUtils.SpawnInitialUnits()\n    end\n    scoArrivalStarted = true\n    local factions = Import(\"common/systems/factions.lua\").FactionsData\n    local placement = Import(\"common/systems/placementUtils.lua\")\n    local _, terrainSize = Engine.GetTerrainHeightmapSize()\n    local plans = {}\n    local plannedArmies = {}\n    for armyId, army in pairs(Armies) do\n        local faction = factions[army.faction]\n        local tpId = faction and faction.initialUnit\n        if not army.lobbyOptions.isEmptySlot and scoArrivalIds[tpId]\n            and gameUtils.GetMarker(army.name, \"Spawn\", true) then\n            local position = gameUtils.MarkerToPosition(army.name, \"Spawn\")\n            local x = math.clamp(position.x, 0, terrainSize.x - 2)\n            local z = math.clamp(position.z, 0, terrainSize.y - 2)\n            local y = position.y\n            if y == 0 then\n                y = placement.GetPlacementHeight(__Templates.Units[tpId], x, z)\n            end\n            local plan = {armyId=armyId, tpId=tpId, position={x=x, y=y, z=z}}\n            plans[#plans + 1] = plan\n            plannedArmies[armyId] = plan\n        end\n    end\n    if #plans == 0 then\n        return gameUtils.SpawnInitialUnits()\n    end\n    table.sort(plans, function(first, second) return first.armyId < second.armyId end)\n    local startTick = Engine.GetSimulationTick()\n    local clients = {}\n    -- Observers have no arrival camera and must not hold gameplay startup.\n    for clientId, player in pairs(scoArrivalLobby.Players) do\n        if player.playerType == PlayerType.Player then clients[clientId] = true end\n    end\n    if next(clients) == nil then return gameUtils.SpawnInitialUnits() end\n    local state = {\n        startTick = startTick,\n        phase = \"pan\",\n        clients = clients,\n        ready = {},\n        units = plans,\n        savedUnits = {},\n        gameUtils = gameUtils,\n        plannedArmies = plannedArmies,\n    }\n    scoArrivalState = state\n    -- ExecuteClientFunction and CreateUnit share the ordered host-command channel.\n    local beginSucceeded, beginError = pcall(scoArrivalSend, \"SCOCommanderArrivalBegin\", state)\n    if not beginSucceeded then\n        scoArrivalState = nil\n        error(beginError)\n    end\n    Engine.Warn(\"[SCOM Arrival] Waiting for every client's rendered camera pan.\")\nend\n\nlocal function scoArrivalSpawnUnits(state)\n    state.spawned = true\n    state.phase = \"teleport\"\n    state.effectTick = Engine.GetSimulationTick()\n    state.ready = {}\n    local stockCreateUnit = _G.CreateUnit\n    _G.CreateUnit = function(armyId, tpId, position, orientation, ...)\n        local plan = state.plannedArmies[armyId]\n        if plan and plan.tpId == tpId and not plan.unitId then\n            -- Imported ACUs face +Z; the unchanged arrival camera ends on -Z.\n            orientation = Engine.QuaternionAxisAngle(EngineClasses.float3(0, 1, 0), math.pi)\n        end\n        local unit = stockCreateUnit(armyId, tpId, position, orientation, ...)\n        if plan and plan.tpId == tpId and not plan.unitId then\n            plan.unitId = {index=unit.id.index, version=unit.id.version}\n            local position = unit:GetPosition()\n            plan.position = {x=position.x, y=position.y, z=position.z}\n            state.savedUnits[#state.savedUnits + 1] = {\n                unit=unit,\n                canTakeDamage=unit.canTakeDamage,\n                canBeKilled=unit.canBeKilled,\n                isTargetable=unit.isTargetable,\n            }\n            unit.canTakeDamage = false\n            unit.canBeKilled = false\n            unit.isTargetable = false\n        end\n        return unit\n    end\n    local success, result = pcall(state.gameUtils.SpawnInitialUnits)\n    _G.CreateUnit = stockCreateUnit\n    if not success then\n        scoArrivalRestore(state)\n        scoArrivalState = nil\n        pcall(scoArrivalSend, \"SCOCommanderArrivalCancel\", state)\n        error(result)\n    end\n    local cohort = {}\n    for _, plan in ipairs(state.units) do\n        if plan.unitId then cohort[#cohort + 1] = plan end\n    end\n    state.units = cohort\n    if #cohort == 0 then\n        scoArrivalState = nil\n        scoArrivalSend(\"SCOCommanderArrivalCancel\", state)\n        if state.startPending then scoArrivalStockStart() end\n        if state.survivalPending then\n            Import(\"host/survival/survival.lua\").TryStartSurvival()\n        end\n    else\n        local bindSucceeded, bindError = pcall(scoArrivalSend, \"SCOCommanderArrivalBind\", state)\n        if not bindSucceeded then\n            scoArrivalRestore(state)\n            scoArrivalState = nil\n            pcall(scoArrivalSend, \"SCOCommanderArrivalCancel\", state)\n            error(bindError)\n        end\n        Engine.Warn(\"[SCOM Arrival] Commanders created after all camera pans; teleport started.\")\n    end\n    return result\nend\n\nfunction Start()\n    if scoArrivalState then\n        scoArrivalState.startPending = true\n        return\n    end\n    return scoArrivalStockStart()\nend\n\nfunction SCOStartSurvival()\n    if scoArrivalState then\n        scoArrivalState.survivalPending = true\n        return\n    end\n    return Import(\"host/survival/survival.lua\").TryStartSurvival()\nend\n\nfunction SCOHoldCommanderArrival()\n    local state = scoArrivalState\n    if not state then return false end\n    -- Rendering acknowledgments and disconnects must be consumed while gameplay\n    -- is held. Simulation catch-up alone can never finish either visible phase.\n    Import(\"host/commands.lua\").ProcessClientCommands()\n    if not scoArrivalAllReady(state) then\n        Import(\"host/managers/intel/intelManager.lua\").UpdateIntel()\n        return true\n    end\n    if not state.spawned then\n        scoArrivalSpawnUnits(state)\n        if scoArrivalState ~= state then return false end\n        Import(\"host/managers/intel/intelManager.lua\").UpdateIntel()\n        return true\n    end\n    -- Intel continues to own fog/cloak masks while gameplay updates are held.\n    Import(\"host/managers/intel/intelManager.lua\").UpdateIntel()\n    state.releaseTick = Engine.GetSimulationTick()\n    state.phase = \"released\"\n    scoArrivalRestore(state)\n    scoArrivalState = nil\n    local released, releaseError = pcall(function()\n        scoArrivalSend(\"SCOCommanderArrivalReveal\", state)\n        scoArrivalSend(\"SCOCommanderArrivalRelease\", state)\n    end)\n    if not released then\n        pcall(scoArrivalSend, \"SCOCommanderArrivalCancel\", state)\n    end\n    if state.startPending then scoArrivalStockStart() end\n    if state.survivalPending then\n        Import(\"host/survival/survival.lua\").TryStartSurvival()\n    end\n    if not released then error(releaseError) end\n    Engine.Warn(\"[SCOM Arrival] Teleport presentation complete for all clients; gameplay released.\")\n    return false\nend\n", isTemplateReplacement: false, "", TransformCommanderArrivalHostMain));
		list.Add(new PatchSpec("LJ/lua/client/input/cameraController.lua", "local commander arrival camera pan", "-- Insert in client/input/cameraController.lua before its final module return.\n-- This stays in the native rig's scope; renderer and intel state are untouched.\nlocal SCOArrivalCameraState = nil\nlocal SCOArrivalNativeUpdate = Update\nlocal SCOArrivalNativeDoInput = DoInput\nlocal SCOArrivalNativeSetCameraRotation = SetCameraRotation\n\nlocal function SCOArrivalCopyVector(value)\n    return EngineClasses.float3(value.x, value.y, value.z)\nend\n\nlocal function SCOArrivalFiniteNumber(value)\n    return type(value) == \"number\" and value == value and value > -math.huge and value < math.huge\nend\n\nlocal function SCOArrivalCameraStillOwnsView(state)\n    return GameInfo and GameInfo.MapInfo == state.mapInfo\n        and type(IsObserver) == \"function\" and not IsObserver()\n        and type(GetFocusArmy) == \"function\" and GetFocusArmy() == state.armyId\n        and not Engine.IsReplayPlayback()\nend\n\nlocal function SCOArrivalApplyCameraPan(state, eased)\n    pivotPosition = math3D.lerpClamped(state.startPivot, state.targetPivot, eased)\n    cameraLocalPosition = math3D.lerpClamped(state.startLocalPosition, state.targetLocalPosition, eased)\n    lastLocalCameraPosition = SCOArrivalCopyVector(cameraLocalPosition)\n    targetLocalCameraPosition = SCOArrivalCopyVector(cameraLocalPosition)\n    pivotBasePitch = state.startPitch + (state.targetPitch - state.startPitch) * eased\n    rotationAdd = math3D.scale(state.startRotation, 1 - eased)\n    rotationAddSmooth = SCOArrivalCopyVector(rotationAdd)\n    ClampPivotXZPlane()\n    lastZoomPosition = SCOArrivalCopyVector(pivotPosition)\nend\n\nlocal function SCOArrivalClearCameraInput()\n    input.zoomDelta = 0\n    input.rotationDelta.x = 0\n    input.rotationDelta.y = 0\n    input.panDirection.x = 0\n    input.panDirection.y = 0\n    input.isPanning = false\n    input.isRotating = false\n    for direction in pairs(panDirectionMap) do\n        panDirectionMap[direction] = 0\n    end\n    mouseScrollSteps = 0\n    zoomVelocity = EngineClasses.float3(0, 0, 0)\n    panSmooth = EngineClasses.float3(0, 0, 0)\n    panVelocity = EngineClasses.float3(0, 0, 0)\n    panOffsetX = EngineClasses.float3(0, 0, 0)\n    panOffsetZ = EngineClasses.float3(0, 0, 0)\n    previousMousePosition = mouseCursor.GetMouseScreenPosition2D()\n    SCOArrivalNativeSetCameraRotation(false)\nend\n\n---@param finishPan? boolean Pass true only for authoritative match-start release.\nfunction StopSCOMCommanderArrivalCamera(finishPan)\n    local state = SCOArrivalCameraState\n    if state == nil then\n        return false\n    end\n    if finishPan == true and SCOArrivalCameraStillOwnsView(state) then\n        SCOArrivalApplyCameraPan(state, 1)\n    end\n    SCOArrivalCameraState = nil\n    input.freeCamera = state.freeCamera\n    SCOArrivalClearCameraInput()\n    lastLocalCameraPosition = SCOArrivalCopyVector(cameraLocalPosition)\n    targetLocalCameraPosition = SCOArrivalCopyVector(cameraLocalPosition)\n    lastZoomPosition = SCOArrivalCopyVector(pivotPosition)\n    return true\nend\n\n---@param armyId ArmyId Owning army from the authoritative arrival event.\n---@param position float3 Authoritative position of that army's initial commander.\n---@param duration? number Host sequence duration, default 4; authoritative Stop releases control.\n---@return boolean started\nfunction StartSCOMCommanderArrivalCamera(armyId, position, duration)\n    if SCOArrivalCameraState ~= nil or not GameInfo or not GameInfo.MapInfo then\n        return false\n    end\n    if type(IsObserver) ~= \"function\" or IsObserver() or Engine.IsReplayPlayback() then\n        return false\n    end\n    local focusArmy = type(GetFocusArmy) == \"function\" and GetFocusArmy() or nil\n    if not SCOArrivalFiniteNumber(focusArmy) or focusArmy <= 0 or armyId ~= focusArmy then\n        return false\n    end\n    local validPosition, x, y, z = pcall(function()\n        return position.x, position.y, position.z\n    end)\n    if not validPosition or not SCOArrivalFiniteNumber(x) or not SCOArrivalFiniteNumber(y) or not SCOArrivalFiniteNumber(z) then\n        return false\n    end\n    duration = duration == nil and 4 or duration\n    if not SCOArrivalFiniteNumber(duration) or duration <= 0 or duration > 30 then\n        return false\n    end\n    local now = Engine.GetCurrentRealtimeInSeconds()\n    if not SCOArrivalFiniteNumber(now) then\n        return false\n    end\n    if not initialised then\n        RestartCamera()\n    end\n    local target = GetMapClampedXZPoint(EngineClasses.float3(x, y, z))\n    target.y = SampleHeight(target)\n    local height = math.clamp(fitBoundsMinHeight, minDistance, math.max(minDistance, maxDistance))\n    SCOArrivalCameraState = {\n        armyId = armyId,\n        mapInfo = GameInfo.MapInfo,\n        renderedElapsed = 0,\n        moveDuration = math.min(1.5, duration * 0.4),\n        startPivot = SCOArrivalCopyVector(pivotPosition),\n        targetPivot = target,\n        startLocalPosition = SCOArrivalCopyVector(cameraLocalPosition),\n        targetLocalPosition = EngineClasses.float3(0, height, 0),\n        startPitch = pivotBasePitch,\n        targetPitch = -SampleRotationPerHeight(height),\n        startRotation = SCOArrivalCopyVector(rotationAddSmooth),\n        freeCamera = input.freeCamera,\n    }\n    SCOArrivalClearCameraInput()\n    input.freeCamera = false\n    return true\nend\n\nDoInput = function(deltaTime)\n    local state = SCOArrivalCameraState\n    if state == nil then\n        return SCOArrivalNativeDoInput(deltaTime)\n    end\n    if SCOArrivalFiniteNumber(deltaTime) then\n        state.renderedElapsed = state.renderedElapsed + math.clamp(deltaTime, 0, 0.1)\n    end\n    local fraction = math.clamp(state.renderedElapsed / state.moveDuration, 0, 1)\n    local eased = fraction * fraction * (3 - 2 * fraction)\n    SCOArrivalApplyCameraPan(state, eased)\n    state.panComplete = fraction >= 1\nend\n\nfunction IsSCOMCommanderArrivalPanComplete()\n    local state = SCOArrivalCameraState\n    return state ~= nil and state.panComplete == true and SCOArrivalCameraStillOwnsView(state)\nend\n\nfunction Update()\n    local state = SCOArrivalCameraState\n    if state ~= nil and not SCOArrivalCameraStillOwnsView(state) then\n        StopSCOMCommanderArrivalCamera()\n    end\n    SCOArrivalNativeUpdate()\n    -- Native clientMain resolves this module Update on every rendered frame.\n    -- Run the handshake after the camera transform was applied to that frame.\n    local arrival = rawget(_G, \"SCO_CommanderArrivalVisuals\")\n    if arrival then arrival.RenderUpdate() end\nend\n\n-- Ignore input while the native rig is being animated, including rotation's cursor-lock side effect.\nlocal function SCOArrivalBlockCameraInput(nativeFunction)\n    return function(...)\n        if SCOArrivalCameraState == nil then\n            return nativeFunction(...)\n        end\n    end\nend\n\nSetZoomAmount = SCOArrivalBlockCameraInput(SetZoomAmount)\nSetPanLeft = SCOArrivalBlockCameraInput(SetPanLeft)\nSetPanRight = SCOArrivalBlockCameraInput(SetPanRight)\nSetPanUp = SCOArrivalBlockCameraInput(SetPanUp)\nSetPanDown = SCOArrivalBlockCameraInput(SetPanDown)\nSetCameraPan = SCOArrivalBlockCameraInput(SetCameraPan)\nSetCameraRotation = SCOArrivalBlockCameraInput(SetCameraRotation)\nAddRotationDeltaX = SCOArrivalBlockCameraInput(AddRotationDeltaX)\nAddRotationDeltaY = SCOArrivalBlockCameraInput(AddRotationDeltaY)\nToggleFreeCamera = SCOArrivalBlockCameraInput(ToggleFreeCamera)\nFitCameraToPositions = SCOArrivalBlockCameraInput(FitCameraToPositions)\nRestartCamera = SCOArrivalBlockCameraInput(RestartCamera)\n\nreturn {\n    StartSCOMCommanderArrivalCamera = StartSCOMCommanderArrivalCamera,\n    StopSCOMCommanderArrivalCamera = StopSCOMCommanderArrivalCamera,\n    IsSCOMCommanderArrivalPanComplete = IsSCOMCommanderArrivalPanComplete,\n    Update = Update,\n    RestartCamera = RestartCamera,\n    SetPlayableArea = SetPlayableArea,\n    SetZoomAmount = SetZoomAmount,\n    SetPanLeft = SetPanLeft,\n    SetPanRight = SetPanRight,\n    SetPanUp = SetPanUp,\n    SetPanDown = SetPanDown,\n    SetCameraPan = SetCameraPan,\n    SetCameraRotation = SetCameraRotation,\n    AddRotationDeltaX = AddRotationDeltaX,\n    AddRotationDeltaY = AddRotationDeltaY,\n    ToggleFreeCamera = ToggleFreeCamera,\n    FitCameraToPositions = FitCameraToPositions,\n}\n", isTemplateReplacement: false, "", StripCommanderArrivalCameraModuleReturn));
		IGrouping<string, PatchSpec> grouping = list.GroupBy<PatchSpec, string>((PatchSpec spec) => spec.RelativePath, StringComparer.OrdinalIgnoreCase).FirstOrDefault((IGrouping<string, PatchSpec> group) => group.Count() != 1);
		if (grouping != null)
		{
			throw new InvalidOperationException("Aeon replacement patch path " + grouping.Key + " is duplicated.");
		}
		if (list.Any((PatchSpec spec) => spec.RelativePath.IndexOf("ucl0000", StringComparison.OrdinalIgnoreCase) >= 0))
		{
			throw new InvalidOperationException("Protected Aeon ACU target entered the patch transaction.");
		}
		return list.ToArray();
	}

	private static void ValidateInstalledTargetSet(HashSet<string> generatedTargets)
	{
		HashSet<string> hashSet = new HashSet<string>(InstalledChosenTargetIds, StringComparer.Ordinal);
		if (InstalledChosenTargetIds.Length != 94 || hashSet.Count != InstalledChosenTargetIds.Length || hashSet.Contains("ucl0000") || hashSet.Any((string target) => !target.StartsWith("uc", StringComparison.Ordinal)))
		{
			throw new InvalidOperationException("The frozen installed Chosen target set is malformed.");
		}
		if (generatedTargets.SetEquals(hashSet))
		{
			return;
		}
		string[] value = hashSet.Except<string>(generatedTargets, StringComparer.Ordinal).OrderBy<string, string>((string target) => target, StringComparer.Ordinal).ToArray();
		string[] value2 = generatedTargets.Except<string>(hashSet, StringComparer.Ordinal).OrderBy<string, string>((string target) => target, StringComparer.Ordinal).ToArray();
		throw new InvalidOperationException("Generated Aeon targets do not exactly replace the installed non-commander Chosen set. Missing=[" + string.Join(",", value) + "]; unexpected=[" + string.Join(",", value2) + "].");
	}

	private static void ValidateAeonFactoryRoutingInventory(AeonFactoryRoutingSpec[] routingSpecs, IReadOnlyDictionary<string, AeonFactoryRoutingSpec> routingBySource)
	{
		GeneratedPortSpec[] array = GeneratedAeonPortSpecs.All.Where((GeneratedPortSpec port) => port.Role == "land_factory" || port.Role == "air_factory" || port.Role == "naval_factory").ToArray();
		HashSet<string> hashSet = new HashSet<string>(array.Select((GeneratedPortSpec port) => port.SourceId), StringComparer.Ordinal);
		Dictionary<string, string[]> dictionary = new Dictionary<string, string[]>(StringComparer.Ordinal);
		dictionary["UAB0101"] = new string[1] { "Tier1_Arm_Refpoint" };
		dictionary["UAB0201"] = new string[2] { "Tier1_Arm_Refpoint", "Tier2_Arm_Refpoint" };
		dictionary["UAB0301"] = new string[3] { "Tier1_Arm_Refpoint", "Tier2_Arm_Refpoint", "Tier3_Arm_Refpoint" };
		dictionary["UAB0102"] = new string[1] { "Turret_Muzzle_02" };
		dictionary["UAB0202"] = new string[2] { "Turret_Muzzle_01", "Turret_Muzzle_02" };
		dictionary["UAB0302"] = new string[3] { "Turret_Muzzle_01", "Turret_Muzzle_02", "Turret_Muzzle_03" };
		dictionary["UAB0103"] = new string[1] { "Turret_Muzzle_01" };
		dictionary["UAB0203"] = new string[2] { "Turret_Muzzle_01", "Turret_Muzzle_02" };
		dictionary["UAB0303"] = new string[3] { "Turret_Muzzle_01", "Turret_Muzzle_02", "Turret_Muzzle_03" };
		Dictionary<string, string[]> dictionary2 = dictionary;
		if (array.Length != 9 || routingSpecs.Length != 9 || routingBySource.Count != 9 || !hashSet.SetEquals(routingBySource.Keys))
		{
			throw new InvalidOperationException("Aeon factory routing must own exactly all nine land/air/naval factories.");
		}
		foreach (AeonFactoryRoutingSpec routing in routingSpecs)
		{
			GeneratedPortSpec generatedPortSpec = array.Single((GeneratedPortSpec candidate) => candidate.SourceId == routing.SourceId);
			if (generatedPortSpec.TargetId != routing.TargetId || generatedPortSpec.ClassName != routing.ClassName || generatedPortSpec.Role != routing.Kind + "_factory" || !generatedPortSpec.Structure || generatedPortSpec.ConstructionBone != routing.BuildBone || !dictionary2.TryGetValue(routing.SourceId, out var value) || !routing.BuildBeamBones.SequenceEqual<string>(value, StringComparer.Ordinal) || routing.BuildBeamBones.Any(string.IsNullOrWhiteSpace) || routing.BuildBeamBones.Distinct<string>(StringComparer.Ordinal).Count() != routing.BuildBeamBones.Count || IsInvalidNumber(routing.BuildStagingX) || IsInvalidNumber(routing.BuildStagingY) || IsInvalidNumber(routing.BuildStagingZ) || routing.ModelSha256.Length != 64 || routing.ModelSha256.Any((char character) => !Uri.IsHexDigit(character)))
			{
				throw new InvalidOperationException(routing.SourceId + "/" + routing.TargetId + " has an invalid factory staging contract.");
			}
		}
	}

	private static void ValidatePort(GeneratedPortSpec port)
	{
		if (string.IsNullOrWhiteSpace(port.SourceId) || string.IsNullOrWhiteSpace(port.TargetId) || string.IsNullOrWhiteSpace(port.Role) || string.IsNullOrWhiteSpace(port.ClassName) || !port.TargetId.StartsWith("uc", StringComparison.Ordinal) || port.SourceId.Equals("UAL0001", StringComparison.OrdinalIgnoreCase) || port.TargetId.Equals("ucl0000", StringComparison.OrdinalIgnoreCase))
		{
			throw new InvalidOperationException("Generated Aeon source/target identity is invalid or protected.");
		}
		if (port.Health <= 0.0 || port.Regeneration < 0.0 || port.CollisionX <= 0.0 || port.CollisionY <= 0.0 || port.CollisionZ <= 0.0 || port.SelectionX <= 0.0 || port.SelectionZ <= 0.0)
		{
			throw new InvalidOperationException(port.TargetId + " has invalid health or geometry.");
		}
		if (port.Placement == null || string.IsNullOrWhiteSpace(port.Placement.FootprintSource) || port.Placement.FootprintX <= 0.0 || port.Placement.FootprintZ <= 0.0 || double.IsNaN(port.Placement.FootprintX) || double.IsInfinity(port.Placement.FootprintX) || double.IsNaN(port.Placement.FootprintZ) || double.IsInfinity(port.Placement.FootprintZ) || IsInvalidNumber(port.Placement.SkirtX) || IsInvalidNumber(port.Placement.SkirtZ) || IsInvalidNumber(port.Placement.SkirtOffsetX) || IsInvalidNumber(port.Placement.SkirtOffsetZ) || (port.Placement.HasSourceSkirt && (port.Placement.SkirtX <= 0.0 || port.Placement.SkirtZ <= 0.0)) || (!port.Placement.HasSourceSkirt && (port.Placement.SkirtX != 0.0 || port.Placement.SkirtZ != 0.0)))
		{
			throw new InvalidOperationException(port.TargetId + " has an invalid source placement contract.");
		}
		if (port.Intel == null || IsInvalidOptional(port.Intel.VisionRadius) || IsInvalidOptional(port.Intel.RadarRadius) || IsInvalidOptional(port.Intel.SonarRadius) || IsInvalidOptional(port.Intel.OmniRadius) || IsInvalidOptional(port.Intel.RadarStealthFieldRadius) || IsInvalidOptional(port.Intel.SonarStealthFieldRadius) || IsInvalidOptional(port.Intel.RemoteViewingRadius) || IsInvalidOptional(port.Intel.ReactivateTime) || IsInvalidOptional(port.Intel.WaterVisionRadius))
		{
			throw new InvalidOperationException(port.TargetId + " has an invalid source intel contract.");
		}
		if (port.Shield == null || (port.Shield.Enabled && (port.Shield.MaxHealth <= 0.0 || port.Shield.RechargeTime < 0.0 || port.Shield.RegenRate < 0.0 || port.Shield.RegenStartTime < 0.0 || port.Shield.Size <= 0.0 || port.Shield.RuntimeRadius <= 0.0 || Math.Abs(port.Shield.RuntimeRadius - port.Shield.Size / 2.0) > 1E-12 || port.Shield.EnergyDrainRechargeTime < 0.0 || IsInvalidNumber(port.Shield.MaxHealth) || IsInvalidNumber(port.Shield.RechargeTime) || IsInvalidNumber(port.Shield.RegenRate) || IsInvalidNumber(port.Shield.RegenStartTime) || IsInvalidNumber(port.Shield.Size) || IsInvalidNumber(port.Shield.RuntimeRadius) || IsInvalidNumber(port.Shield.VerticalOffset) || IsInvalidNumber(port.Shield.EnergyDrainRechargeTime))) || (!port.Shield.Enabled && (port.Shield.Personal.HasValue || port.Shield.MaxHealth != 0.0 || port.Shield.RechargeTime != 0.0 || port.Shield.RegenRate != 0.0 || port.Shield.RegenStartTime != 0.0 || port.Shield.Size != 0.0 || port.Shield.RuntimeRadius != 0.0 || port.Shield.VerticalOffset != 0.0 || port.Shield.EnergyDrainRechargeTime != 0.0)))
		{
			throw new InvalidOperationException(port.TargetId + " has an invalid source shield contract.");
		}
		if (port.Economy.BuildTime < 0.0 || port.Economy.MassCost < 0.0 || port.Economy.EnergyCost < 0.0 || port.Economy.BuildRate < 0.0 || port.Economy.MassProduction < 0.0 || port.Economy.EnergyProduction < 0.0 || port.Economy.MassMaintenance < 0.0 || port.Economy.EnergyMaintenance < 0.0 || port.Economy.MassStorage < 0.0 || port.Economy.EnergyStorage < 0.0)
		{
			throw new InvalidOperationException(port.TargetId + " has a negative economy value.");
		}
		if (port.Movement.Enabled && (string.IsNullOrWhiteSpace(port.Movement.SourceMotionType) || string.IsNullOrWhiteSpace(port.Movement.SanctuaryType) || port.Movement.Speed <= 0.0 || port.Movement.MinSpeed < 0.0 || port.Movement.Acceleration < 0.0 || double.IsNaN(port.Movement.Elevation) || double.IsInfinity(port.Movement.Elevation) || double.IsNaN(port.Movement.LiftCoefficient) || double.IsInfinity(port.Movement.LiftCoefficient) || port.Movement.LiftCoefficient < 0.0 || double.IsNaN(port.Movement.LiftDamping) || double.IsInfinity(port.Movement.LiftDamping) || port.Movement.LiftDamping < 0.0 || double.IsNaN(port.Movement.LiftFactor) || double.IsInfinity(port.Movement.LiftFactor) || port.Movement.LiftFactor < 0.0 || double.IsNaN(port.Movement.ConstructionSurfaceClearance) || double.IsInfinity(port.Movement.ConstructionSurfaceClearance) || port.Movement.ConstructionSurfaceClearance < 0.0 || (port.Movement.SourceMotionType == "RULEUMT_Hover" && port.Movement.Elevation <= 0.0) || port.Movement.RotationSpeed < 0.0 || (port.Movement.RunClip.Length != 0 && (port.Movement.WalkRate <= 0.0 || port.Movement.AuthoredSpeed <= 0.0))))
		{
			throw new InvalidOperationException(port.TargetId + " has an incomplete movement contract.");
		}
		if (port.HasVisualAsset && (port.AnimationClips == null || !port.AnimationClips.Contains<string>("Rest", StringComparer.Ordinal)))
		{
			throw new InvalidOperationException(port.TargetId + " has no generated Rest clip.");
		}
		string text = AeonEngineerBuildClip(port);
		if (text != null && (port.ClassName != "AeonPortEngineer" || port.ConstructionBone != "Muzzle" || !port.AnimationClips.Contains<string>(text, StringComparer.Ordinal)))
		{
			throw new InvalidOperationException(port.TargetId + " has an incomplete Aeon engineer pole-tip build-animation contract.");
		}
		if (port.Weapons == null)
		{
			throw new InvalidOperationException(port.TargetId + " has no generated weapon collection.");
		}
		if (port.SourceCategories == null || port.SourceCategories.Length == 0 || !port.SourceCategories.Contains<string>("AEON", StringComparer.Ordinal))
		{
			throw new InvalidOperationException(port.TargetId + " has no frozen Aeon source-category contract.");
		}
		GeneratedWeaponSpec[] weapons = port.Weapons;
		foreach (GeneratedWeaponSpec weapon in weapons)
		{
			ValidateWeapon(port, weapon);
		}
		if (string.Equals(port.TargetId, "ucl1101", StringComparison.Ordinal) && (port.Weapons.Length != 1 || !IsAeonT1MobileArtillery(port, port.Weapons[0])))
		{
			throw new InvalidOperationException("Fervor source artillery contract changed; review its Sanctuary ballistic conversion.");
		}
		bool num = port.Movement.SourceMotionType == "RULEUMT_Air";
		if (num && (!port.Movement.Air || port.Movement.Elevation <= 0.0 || port.Movement.LiftCoefficient <= 0.0 || port.Movement.LiftDamping <= 0.0 || port.Movement.LiftFactor <= 0.0 || port.Movement.Acceleration <= 0.0 || port.Movement.RotationSpeed <= 0.0 || port.Movement.CompatibilityNote.Length == 0 || port.Movement.ConstructionSurfaceModelEntry.Length == 0 || port.Movement.ConstructionSurfaceModelSha256.Length != 64))
		{
			throw new InvalidOperationException(port.TargetId + " has an incomplete authored aircraft altitude contract.");
		}
		if (!num && (port.Movement.ConstructionSurfaceClearance != 0.0 || port.Movement.ConstructionSurfaceModelEntry.Length != 0 || port.Movement.ConstructionSurfaceModelSha256.Length != 0))
		{
			throw new InvalidOperationException(port.TargetId + " unexpectedly owns aircraft surface metadata.");
		}
		bool num2 = port.SourceId == "UAA0310";
		if (num2 != (port.TargetId == "uca4011"))
		{
			throw new InvalidOperationException("Czar target identity changed.");
		}
		if (num2 && (!port.CzarBeam.Enabled || port.ClassName != "AeonPortCzar" || port.Economy.BuildRate != 180.0 || !port.SourceCategories.Contains<string>("FACTORY", StringComparer.Ordinal) || !port.SourceCategories.Contains<string>("CARRIER", StringComparer.Ordinal) || !port.SourceCategories.Contains<string>("AIRSTAGINGPLATFORM", StringComparer.Ordinal) || port.Movement.SourceMotionType != "RULEUMT_Air" || port.Movement.SanctuaryType != "Gunship" || port.Movement.Elevation != 25.0 || port.Movement.LiftCoefficient != 2.0 || port.Movement.LiftDamping != 3.5 || port.Movement.LiftFactor != 7.0 || port.Movement.Speed != 8.0 || port.Movement.Acceleration != 1.0 || port.Movement.RotationSpeed != 20.0 || port.Movement.ConstructionSurfaceClearance != 2.8341667652130127 || port.Movement.ConstructionSurfaceModelEntry != "Units/uca4011/LOD0/uca4011_lod0.sanmodel" || port.Movement.ConstructionSurfaceModelSha256 != "e2cd1bd7867aee210e0afd3d6f310d6850de9672b3f58fb979759d6b815a6cfc" || !port.Movement.Air || !port.Movement.AirHover || port.CzarBeam.CenterBone != "Center_Muzzle" || port.CzarBeam.ImpactEffect != "VFX/SupremeCommanderOverhaul/Czar/Impact/czar_quantum_impact.sanvfx" || port.CzarBeam.BeamMaterial != "VFX/SupremeCommanderOverhaul/Czar/Materials/czar_quantum_beam_core.sanmaterial" || port.CzarBeam.DirectionX != 0.0 || port.CzarBeam.DirectionY != -1.0 || port.CzarBeam.DirectionZ != 0.0 || port.CzarBeam.Damage != 1000.0 || port.CzarBeam.DamageInterval != 0.2 || port.CzarBeam.DamageRadius != 4.0 || port.CzarBeam.RayLength != 50.0 || port.CzarBeam.AcquisitionRange != 30.0 || port.CzarBeam.ReloadTime != 5.0 || port.Weapons.Length == 0 || port.Weapons[0].Label != "QuantumBeamGeneratorWeapon" || !port.Weapons[0].IsBeam || port.Weapons[0].Damage != port.CzarBeam.Damage || port.Weapons[0].DamageRadius != port.CzarBeam.DamageRadius || port.Weapons[0].RangeMax != port.CzarBeam.AcquisitionRange || port.Weapons[0].ReloadTime != port.CzarBeam.ReloadTime || port.Weapons[0].RateOfFire != 0.2 || port.Weapons[0].BeamLifetime != 0.0 || port.Weapons[0].Racks.Length != 1 || port.Weapons[0].Racks[0].RackBone != "Center_Muzzle" || port.Weapons[0].Racks[0].Muzzles.Length != 1 || port.Weapons[0].Racks[0].Muzzles[0] != "Center_Muzzle"))
		{
			throw new InvalidOperationException("Enabled Czar center-down beam contract is incomplete or changed.");
		}
		if (num2)
		{
			GeneratedWeaponSpec generatedWeaponSpec = port.Weapons.SingleOrDefault((GeneratedWeaponSpec generatedWeaponSpec2) => generatedWeaponSpec2.IsDeath && generatedWeaponSpec2.Label == "DeathImpact");
			if (generatedWeaponSpec == null || generatedWeaponSpec.Damage != 15000.0 || generatedWeaponSpec.DamageRadius != 15.0 || generatedWeaponSpec.SourceCategory != "Death")
			{
				throw new InvalidOperationException("Czar FA crash-impact contract is incomplete or changed.");
			}
		}
		if (!num2 && port.CzarBeam.Enabled)
		{
			throw new InvalidOperationException(port.TargetId + " unexpectedly owns the Czar beam hook.");
		}
	}

	private static bool IsInvalidOptional(double? value)
	{
		if (value.HasValue)
		{
			if (!(value.Value < 0.0) && !double.IsNaN(value.Value))
			{
				return double.IsInfinity(value.Value);
			}
			return true;
		}
		return false;
	}

	private static bool IsInvalidNumber(double value)
	{
		if (!double.IsNaN(value))
		{
			return double.IsInfinity(value);
		}
		return true;
	}

	private static void ValidateWeapon(GeneratedPortSpec port, GeneratedWeaponSpec weapon)
	{
		if (string.IsNullOrWhiteSpace(weapon.Label) || weapon.Damage < 0.0 || weapon.DamageRadius < 0.0)
		{
			throw new InvalidOperationException(port.TargetId + " has invalid weapon identity or damage.");
		}
		if (weapon.IsDeath || (!string.IsNullOrWhiteSpace(weapon.AimBone) && !string.IsNullOrWhiteSpace(weapon.YawBone) && !string.IsNullOrWhiteSpace(weapon.PitchBone) && weapon.Racks != null && weapon.Racks.Length != 0 && !weapon.Racks.Any((GeneratedRackSpec rack) => string.IsNullOrWhiteSpace(rack.RackBone) || rack.Muzzles == null || rack.Muzzles.Length == 0 || rack.Muzzles.Any(string.IsNullOrWhiteSpace)) && weapon.RackSalvoSize > 0 && weapon.MuzzleSalvoSize >= 0 && !(weapon.MuzzleSalvoDelay < 0.0) && !(weapon.RackChargeDelay < 0.0) && !(weapon.RackTimeout < -1.0) && weapon.ProjectilesPerFire > 0 && !(weapon.RangeMin < 0.0) && !(weapon.RangeMax <= 0.0) && !(weapon.RangeMin > weapon.RangeMax) && !(weapon.RateOfFire <= 0.0) && !(weapon.ReloadTime <= 0.0) && !(Math.Abs(weapon.ReloadTime - 1.0 / weapon.RateOfFire) > 1E-12) && !(weapon.ProjectileSpeed < 0.0) && !(weapon.ProjectileLifetime <= 0.0) && !string.IsNullOrWhiteSpace(weapon.ProjectileTemplate) && !string.IsNullOrWhiteSpace(weapon.RangeRingType) && weapon.TargetLayers != null && weapon.TargetLayers.Length != 0 && !weapon.TargetLayers.Any(string.IsNullOrWhiteSpace) && (!(weapon.TargetWaterLimits != "Above") || !(weapon.TargetWaterLimits != "Below")) && !string.IsNullOrWhiteSpace(weapon.SolverType)))
		{
			return;
		}
		throw new InvalidOperationException(port.TargetId + "/" + weapon.Label + " has an incomplete parity contract.");
	}

	private static string BuildTemplateAppendix(GeneratedPortSpec port, IReadOnlyDictionary<string, AeonFactoryRoutingSpec> factoryRoutingBySource)
	{
		double value = (port.Structure ? (0.0 - port.CollisionOffsetX) : port.CollisionOffsetX);
		double value2 = (port.Structure ? (0.0 - port.CollisionOffsetZ) : port.CollisionOffsetZ);
		double value3 = port.CollisionY / 2.0 + port.CollisionOffsetY;
		return "assert(\n    UnitTemplate\n        and UnitTemplate.general\n        and UnitTemplate.general.tpId == \"" + EscapeLua(port.TargetId) + "\",\n    \"Aeon replacement template identity mismatch: " + EscapeLua(port.TargetId) + "\")\n\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.effectsWhenActive = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.general.class = {\n    \"unitsDefaultChosen\",\n    \"" + EscapeLua(port.ClassName) + "\",\n}\nUnitTemplate.general.displayName = \"" + EscapeLua(port.DisplayName) + "\"\nUnitTemplate.general.name = \"" + EscapeLua(port.DisplayName) + "\"\nUnitTemplate.general.unitTypeName = UnitTemplate.general.unitTypeName or UnitTemplate.general.displayName\nUnitTemplate.general.tpId = \"" + EscapeLua(port.TargetId) + "\"\n\nUnitTemplate.collisionInfo = {\n    centerOffset = {\n        x = " + Lua(value) + ",\n        y = " + Lua(value3) + ",\n        z = " + Lua(value2) + ",\n    },\n    collisionSize = {\n        x = " + Lua(port.CollisionX) + ",\n        y = " + Lua(port.CollisionY) + ",\n        z = " + Lua(port.CollisionZ) + ",\n    },\n}\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = {\n    x = " + Lua(port.SelectionX) + ",\n    y = " + Lua(port.SelectionZ) + ",\n}\nUnitTemplate.visuals.selection.offset = {\n    x = " + Lua(value) + ",\n    y = " + Lua(value3) + ",\n    z = " + Lua(value2) + ",\n}\nUnitTemplate.additions.selectionHit = {\n    size = {\n        x = " + Lua(port.SelectionX) + ",\n        y = " + Lua(port.SelectionZ) + ",\n    },\n    offset = {\n        x = " + Lua(value) + ",\n        y = " + Lua(value3) + ",\n        z = " + Lua(value2) + ",\n    },\n}\n\n" + BuildPlacementOverride(port) + "\n" + BuildHealthEconomyConstruction(port, factoryRoutingBySource) + "\n" + BuildFactoryRoutingOverride(port, factoryRoutingBySource) + "\n" + BuildIntelOverride(port) + "\n" + BuildMovementOverride(port) + "\n" + BuildAnimationOverride(port) + "\n" + BuildWeaponOverride(port) + "\n" + BuildSourceContract(port) + "\n" + BuildAeonLandFactoryHitboxOverride(port) + "\n" + BuildTagsOverride(port) + "\n" + BuildOrdersOverride(port) + "\n" + BuildShieldOverride(port) + "\n\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do\n            effect.boneName = \"Root\"\n        end\n    end\nend\nif UnitTemplate.general.tpId == \"ucl3001\" then\n-- Append to ucl3001.santp after the Aeon one-for-one source replacement.\ndo\n    local unit = UnitTemplate\n    assert(unit.general.tpId == \"ucl3001\")\n    assert(unit.additions.faSourceContract.sourceId == \"UAL0303\"\n        and unit.additions.faSourceContract.shield.runtimeRadius == 1.25\n        and unit.additions.faSourceContract.shield.energyDrainRechargeTime == 5)\n    assert(unit.general.toggles.Shield == true)\n    assert(unit.collisionInfo.centerOffset.y == 0.75\n        and unit.collisionInfo.collisionSize.x == 1\n        and unit.collisionInfo.collisionSize.y == 1.5\n        and unit.collisionInfo.collisionSize.z == 1.2)\n\n    local shields = assert(unit.defence.shields)\n    assert(#shields == 1)\n    local shield = shields[1]\n    assert(shield.boneName == \"Root\" and shield.type == 0\n        and shield.max == 1300 and shield.value == 1300\n        and shield.regen == 9 and shield.regenDelay == 3\n        and shield.rechargeTime == 60 and shield.rechargeHPRatio == 0.5\n        and shield.radii.x == 1.25 and shield.radii.y == 1.25\n        and shield.radii.z == 1.25\n        and (shield.offset.x or 0) == 0 and shield.offset.y == 0\n        and (shield.offset.z or 0) == 0)\n\n    -- The imported Root is already at world Y 0.903200016; its radius-1.25\n    -- sphere encloses the body collider centered at Y 0.75.\n    shield.scoFaHarbingerPersonalShield = true\n    shield.scoDamageRechargeTime = 60\n    shield.scoManualRechargeTime = 5\n    shield.scoEnergyDrainRechargeTime = 5\nend\nend\n";
	}

	private static string BuildAeonLandFactoryHitboxOverride(GeneratedPortSpec port)
	{
		double value;
		double value2;
		switch (port.TargetId)
		{
		case "ucs1511":
			value = -0.0107654333114624;
			value2 = 3.41015768051147;
			break;
		case "ucs2511":
			value = -0.0342665910720825;
			value2 = 3.39709544181824;
			break;
		case "ucs3511":
			value = 0.347618401050568;
			value2 = 3.238325715065;
			break;
		default:
			return string.Empty;
		}
		return "-- SCOM Aeon land-factory measured hitbox 1.0.0\n-- The FA gameplay collider is narrower than the converted circular hull.\n-- Preserve its 5x5 footprint and 8x8 build skirt while aligning physical\n-- collision and click selection to the packaged model envelope.\nUnitTemplate.additions.aeonLandFactoryHitbox = {\n    model = \"Units/" + EscapeLua(port.TargetId) + "/LOD0/" + EscapeLua(port.TargetId) + "_lod0.sanmodel\",\n    measuredRestBounds = {\n        center = { x = 0, y = " + Lua(value) + ", z = 0 },\n        size = { x = 4.8331995010376, y = " + Lua(value2) + ", z = 4.8331995010376 },\n    },\n    collision = { centerY = 0.1, x = 5, y = 3.8, z = 5 },\n    selection = { x = 5.2, z = 5.2 },\n}\nUnitTemplate.collisionInfo = {\n    centerOffset = { x = 0, y = 0.1, z = 0 },\n    collisionSize = { x = 5, y = 3.8, z = 5 },\n}\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = { x = 5.2, y = 5.2 }\nUnitTemplate.visuals.selection.offset = { x = 0, y = 0.1, z = 0 }\nUnitTemplate.additions.selectionHit = {\n    size = { x = 5.2, y = 5.2 },\n    offset = { x = 0, y = 0.1, z = 0 },\n}";
	}

	private static string BuildPlacementOverride(GeneratedPortSpec port)
	{
		GeneratedPlacementSpec placement = port.Placement;
		string text = (placement.HasSourceSkirt ? ("UnitTemplate.skirtSize = {\n    x = " + Lua(placement.SkirtX) + ",\n    y = " + Lua(placement.SkirtZ) + ",\n}") : "UnitTemplate.skirtSize = nil");
		return "UnitTemplate.footprint = {\n    x = " + Lua(placement.FootprintX) + ",\n    y = " + Lua(placement.FootprintZ) + ",\n}\n" + text;
	}

	private static string BuildFactoryRoutingOverride(GeneratedPortSpec port, IReadOnlyDictionary<string, AeonFactoryRoutingSpec> factoryRoutingBySource)
	{
		if (!factoryRoutingBySource.TryGetValue(port.SourceId, out AeonFactoryRoutingSpec value))
		{
			return string.Empty;
		}
		if (value.TargetId != port.TargetId || value.ClassName != port.ClassName || value.BuildBone != port.ConstructionBone)
		{
			throw new InvalidOperationException(port.SourceId + "/" + port.TargetId + " no longer matches its factory routing metadata.");
		}
		string text = value.Kind switch
		{
			"land" => "UnitTemplate.additions.rollOffRamps = {\n    {\n        rampOffset = { x = -2.75, y = 0, z = -0.35 },\n        clearanceOffset = { x = -5, y = 0, z = -0.35 },\n        headingDegrees = -90,\n    },\n    {\n        rampOffset = { x = 2.75, y = 0, z = -0.35 },\n        clearanceOffset = { x = 5, y = 0, z = -0.35 },\n        headingDegrees = 90,\n    },\n}", 
			"air" => "UnitTemplate.additions.rollOffRamps = {\n    {\n        rampOffset = { x = -3, y = 0, z = 0 },\n        clearanceOffset = { x = -6, y = 0, z = 0 },\n        headingDegrees = -90,\n    },\n    {\n        rampOffset = { x = 3, y = 0, z = 0 },\n        clearanceOffset = { x = 6, y = 0, z = 0 },\n        headingDegrees = 90,\n    },\n}", 
			"naval" => "UnitTemplate.additions.rollOffRamps = {\n    {\n        rampOffset = { x = 4, y = 0, z = 10 },\n        clearanceOffset = { x = 4, y = 0, z = 14 },\n        headingDegrees = 0,\n    },\n    {\n        rampOffset = { x = 4, y = 0, z = -10 },\n        clearanceOffset = { x = 4, y = 0, z = -14 },\n        headingDegrees = 180,\n    },\n}", 
			_ => throw new InvalidOperationException(value.SourceId + " has unsupported factory routing kind " + value.Kind + "."), 
		};
		return "-- Exact packaged " + EscapeLua(value.BuildBone) + " rest translation.\n-- Do not derive this from the model's lowest vertex: Aeon factory\n-- foundations intentionally extend below their visible floor.\nUnitTemplate.additions.buildStagingOffset = {\n    x = " + Lua(value.BuildStagingX) + ",\n    y = " + Lua(value.BuildStagingY) + ",\n    z = " + Lua(value.BuildStagingZ) + ",\n}\nUnitTemplate.additions.buildStagingBoneName =\n    \"" + EscapeLua(value.BuildBone) + "\"\nUnitTemplate.additions.buildStagingModelSha256 =\n    \"" + EscapeLua(value.ModelSha256) + "\"\nUnitTemplate.additions.rollOffSurfacePolicy =\n    \"" + ((value.Kind == "land") ? "terrain" : "factory") + "\"\n" + text + "\n-- The custom host class owns staging and completed-unit routing.\n-- Removing the donor point makes accidental donor inheritance\n-- detectable instead of silently burying the child again.\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.rollOffPoints = nil";
	}

	private static string BuildIntelOverride(GeneratedPortSpec port)
	{
		GeneratedIntelSpec intel = port.Intel;
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("UnitTemplate.intel = {");
		stringBuilder.Append("    visionRadius = ").Append(Lua(intel.VisionRadius.GetValueOrDefault())).AppendLine(",");
		if (intel.RadarRadius.HasValue)
		{
			stringBuilder.Append("    radarRadius = ").Append(Lua(intel.RadarRadius.Value)).AppendLine(",");
		}
		stringBuilder.Append('}');
		if (port.TargetId == "ucl4004")
		{
			stringBuilder.AppendLine();
			stringBuilder.AppendLine("-- The compatibility slot keeps the native experimental silhouette but corrects its stale T1/none metadata.");
			stringBuilder.AppendLine("UnitTemplate.general.icon = { shape = \"experimental1\", symbol = \"direct\", tech = \"t3\" }");
			stringBuilder.Append("UnitTemplate.general.iconUI = \"tech3_land1_direct.png\"");
		}
		return stringBuilder.ToString();
	}

	private static string BuildShieldOverride(GeneratedPortSpec port)
	{
		GeneratedShieldSpec shield = port.Shield;
		if (!shield.Enabled)
		{
			return "UnitTemplate.defence.shields = nil\nif UnitTemplate.general.toggles then\n    UnitTemplate.general.toggles.Shield = nil\nend";
		}
		return "local SCO_AeonShield =\n    UnitTemplate.defence.shields\n    and UnitTemplate.defence.shields[1]\n    or {}\nSCO_AeonShield.boneName = \"Root\"\nSCO_AeonShield.max = " + Lua(shield.MaxHealth) + "\nSCO_AeonShield.value = " + Lua(shield.MaxHealth) + "\nSCO_AeonShield.regen = " + Lua(shield.RegenRate) + "\nSCO_AeonShield.regenDelay = " + Lua(shield.RegenStartTime) + "\nSCO_AeonShield.rechargeTime = " + Lua(shield.RechargeTime) + "\nSCO_AeonShield.rechargeHPRatio = 0.5\nif UnitTemplate.general.tpId == \"ucs2401\"\n    or UnitTemplate.general.tpId == \"ucs3401\"\n    or UnitTemplate.general.tpId == \"ucl4401\" then\n    SCO_AeonShield.rechargeHPRatio = 1\nend\nSCO_AeonShield.name = \"Bubble Shield\"\nSCO_AeonShield.type = 0\nSCO_AeonShield.radii = {\n    x = " + Lua(shield.RuntimeRadius) + ",\n    y = " + Lua(shield.RuntimeRadius) + ",\n    z = " + Lua(shield.RuntimeRadius) + ",\n}\nSCO_AeonShield.offset = {\n    y = " + Lua(shield.VerticalOffset) + ",\n}\nUnitTemplate.defence.shields = { SCO_AeonShield }\nUnitTemplate.general.toggles = UnitTemplate.general.toggles or {}\nUnitTemplate.general.toggles.Shield = true";
	}

	private static string BuildHealthEconomyConstruction(GeneratedPortSpec port, IReadOnlyDictionary<string, AeonFactoryRoutingSpec> factoryRoutingBySource)
	{
		GeneratedEconomySpec economy = port.Economy;
		string text = ((economy.MassProduction > 0.0 || economy.EnergyProduction > 0.0) ? ("UnitTemplate.economy.production = {\n    alloys = " + Lua(economy.MassProduction) + ",\n    energy = " + Lua(economy.EnergyProduction) + ",\n}") : "UnitTemplate.economy.production = nil");
		string text2 = ((economy.MassMaintenance > 0.0 || economy.EnergyMaintenance > 0.0) ? ("UnitTemplate.economy.maintenanceConsumption = {\n    alloys = " + Lua(economy.MassMaintenance) + ",\n    energy = " + Lua(economy.EnergyMaintenance) + ",\n}") : "UnitTemplate.economy.maintenanceConsumption = nil");
		string text3 = ((economy.MassStorage > 0.0 || economy.EnergyStorage > 0.0) ? ("UnitTemplate.economy.storage = {\n    alloys = " + Lua(economy.MassStorage) + ",\n    energy = " + Lua(economy.EnergyStorage) + ",\n}") : "UnitTemplate.economy.storage = nil");
		string text4 = ((economy.BuildRate > 0.0) ? ("UnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.buildPower = " + Lua(economy.BuildRate)) : "if UnitTemplate.construction then\n    UnitTemplate.construction.buildPower = nil\nend");
		string text5 = ((port.SourceId == "UAA0310") ? "UnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.rollOffPoints = {\n    {\n        offset = { x = 0, y = 0, z = 0 },\n        rollOffTime = 2,\n        unitSpin = 0,\n    },\n}" : string.Empty);
		string value = ((port.SourceId == "UAA0310") ? "Root" : port.ConstructionBone);
		string text7;
		if (factoryRoutingBySource.TryGetValue(port.SourceId, out AeonFactoryRoutingSpec value2))
		{
			string text6 = string.Join("\n", value2.BuildBeamBones.Select((string bone) => "    \"" + EscapeLua(bone) + "\","));
			text7 = "UnitTemplate.additions.buildBeamBones = {\n" + text6 + "\n}\nUnitTemplate.additions.multiConstructionBeam = {\n    prefabName = \"SCOM.AeonFactoryBeam\",\n    materialPath = \"VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial\",\n    shrink = 0.05,\n}\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.beam = nil";
		}
		else
		{
			text7 = (string.IsNullOrWhiteSpace(value) ? "UnitTemplate.additions.buildBeamBones = nil\nif UnitTemplate.construction and UnitTemplate.construction.beam then\n    UnitTemplate.construction.beam.boneName = nil\nend" : ("UnitTemplate.additions.buildBeamBones = {\n    \"" + EscapeLua(value) + "\",\n}\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.beam = UnitTemplate.construction.beam or {}\nUnitTemplate.construction.beam.boneName = \"" + EscapeLua(value) + "\"\nUnitTemplate.construction.beam.offset = { x = 0, y = 0, z = 0 }"));
		}
		string text8 = BuildConstructionRouting(port);
		return "UnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = {\n    max = " + Lua(port.Health) + ",\n    value = " + Lua(port.Health) + ",\n    regen = " + Lua(port.Regeneration) + ",\n}\nUnitTemplate.economy = UnitTemplate.economy or {}\nUnitTemplate.economy.buildTime = " + Lua(economy.BuildTime) + "\nUnitTemplate.economy.cost = {\n    alloys = " + Lua(economy.MassCost) + ",\n    energy = " + Lua(economy.EnergyCost) + ",\n}\nUnitTemplate.economy.initial = nil\n" + text + "\n" + text2 + "\n" + text3 + "\n" + text4 + "\n" + text5 + "\n" + text7 + "\n" + text8;
	}

	private static string BuildConstructionRouting(GeneratedPortSpec port)
	{
		HashSet<string> source = new HashSet<string>(port.SourceCategories, StringComparer.Ordinal);
		string text = null;
		if (port.SourceId == "UAB0304")
		{
			if (!GeneratedAeonPortSpecs.All.Any((GeneratedPortSpec candidate) => candidate.SourceId == "UAL0301" && candidate.TargetId == "ucl4002"))
			{
				throw new InvalidOperationException("Aeon gateway SACU target mapping changed.");
			}
			text = "Tags.ucl4002";
		}
		else if (port.ClassName == "AeonPortEngineer")
		{
			text = "Tags.CHOSEN * Tags.BUILDABLE_BY_T" + SourceTechLevel(source) + "_ENGINEER";
		}
		else if (port.ClassName == "AeonPortLandFactory")
		{
			text = "Tags.CHOSEN * Tags.BUILDABLE_BY_T" + SourceTechLevel(source) + "_FACTORY * Tags.LAND";
		}
		else if (port.SourceId == "UAA0310")
		{
			text = "Tags.CHOSEN * Tags.BUILDABLE_BY_T3_FACTORY * Tags.AIR * Tags.MOBILE";
		}
		else if (port.ClassName == "AeonPortAirFactory")
		{
			text = "Tags.CHOSEN * Tags.BUILDABLE_BY_T" + SourceTechLevel(source) + "_FACTORY * Tags.AIR";
		}
		else if (port.ClassName == "AeonPortNavalFactory")
		{
			text = "Tags.CHOSEN * Tags.BUILDABLE_BY_T" + SourceTechLevel(source) + "_FACTORY * Tags.NAVAL";
		}
		GeneratedPortSpec generatedPortSpec = (string.IsNullOrEmpty(port.SourceUpgradeTo) ? null : GeneratedAeonPortSpecs.All.Single((GeneratedPortSpec candidate) => candidate.SourceId.Equals(port.SourceUpgradeTo, StringComparison.OrdinalIgnoreCase)));
		string obj = ((text == null) ? "if UnitTemplate.construction then\n    UnitTemplate.construction.canBuild = nil\nend" : ("UnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.canBuild = \"" + EscapeLua(text) + "\""));
		string text2 = ((generatedPortSpec == null) ? "if UnitTemplate.construction then\n    UnitTemplate.construction.upgradesTo = nil\nend" : ("UnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.upgradesTo =\n    \"" + EscapeLua(generatedPortSpec.TargetId) + "\""));
		return obj + "\n" + text2;
	}

	private static int SourceTechLevel(HashSet<string> source)
	{
		if (source.Contains("TECH1"))
		{
			return 1;
		}
		if (source.Contains("TECH2"))
		{
			return 2;
		}
		if (source.Contains("TECH3") || source.Contains("EXPERIMENTAL"))
		{
			return 3;
		}
		throw new InvalidOperationException("Builder/factory source has no supported technology tier.");
	}

	private static string BuildMovementOverride(GeneratedPortSpec port)
	{
		GeneratedMovementSpec movement = port.Movement;
		if (!movement.Enabled)
		{
			return "UnitTemplate.movement = nil";
		}
		string text = (movement.HasSourceMaxBrake ? ("UnitTemplate.movement.deceleration = " + Lua(movement.SourceMaxBrake)) : "-- Source blueprint has no MaxBrake; retain the compatible donor deceleration.");
		string text2 = ((movement.RunClip.Length != 0) ? ("UnitTemplate.movement.walkAnimation = {\n    authoredSpeed = " + Lua(movement.AuthoredSpeed) + ",\n}") : "UnitTemplate.movement.walkAnimation = nil");
		string text3 = BuildMovementEnvironmentOverride(port);
		return "UnitTemplate.movement = UnitTemplate.movement or {}\nUnitTemplate.movement.speed = " + Lua(movement.Speed) + "\nUnitTemplate.movement.acceleration = " + Lua(movement.Acceleration) + "\n" + text + "\nUnitTemplate.movement.rotationSpeed = " + Lua(movement.RotationSpeed) + "\nUnitTemplate.movement.type = \"" + EscapeLua(movement.SanctuaryType) + "\"\nUnitTemplate.movement.targetCirclingRadius = nil\nUnitTemplate.movement.targetCirclingSpeed = nil\nUnitTemplate.movement.targetCirclingTime = nil\n" + text3 + "\n" + text2;
	}

	private static string BuildMovementEnvironmentOverride(GeneratedPortSpec port)
	{
		GeneratedMovementSpec movement = port.Movement;
		string text = ((port.SourceCategories.Contains<string>("EXPERIMENTAL", StringComparer.Ordinal) || port.SourceId == "UAL0301" || port.SourceId == "UAL0307") ? "Large" : "Small");
		string text2 = "Land" + text;
		string text3 = "Seabed" + text;
		switch (movement.SanctuaryType)
		{
		case "TracksLand":
		case "LegsLand":
			return "UnitTemplate.movement.air = nil\nUnitTemplate.movement.airHover = nil\nUnitTemplate.movement.minSpeed = nil\nUnitTemplate.movement.landWhenIdleSeconds = nil\nUnitTemplate.movement.altitudeJitterFactor = 0\nUnitTemplate.movement.bankFactor = 0\nUnitTemplate.movement.orbitRange = 0\nUnitTemplate.movement.orbitSpeed = 0\nUnitTemplate.movement.collisionMaskDefault = { \"" + text2 + "\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"" + text2 + "\" }\nUnitTemplate.movement.referenceAltitude = \"Ground\"\nUnitTemplate.movement.preferredAltitude = 0\nUnitTemplate.movement.terrainAlignmentFactor = 1\nUnitTemplate.movement.elevation = nil\nUnitTemplate.movement.continuous = nil";
		case "Hover":
			return "UnitTemplate.movement.air = nil\nUnitTemplate.movement.airHover = nil\nUnitTemplate.movement.minSpeed = nil\nUnitTemplate.movement.landWhenIdleSeconds = nil\nUnitTemplate.movement.altitudeJitterFactor = 0\nUnitTemplate.movement.bankFactor = 0\nUnitTemplate.movement.orbitRange = 0\nUnitTemplate.movement.orbitSpeed = 0\nUnitTemplate.movement.collisionMaskDefault = { \"" + text2 + "\", \"Sea\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"" + text2 + "\", \"Sea\" }\nUnitTemplate.movement.referenceAltitude = \"GroundOrWater\"\nUnitTemplate.movement.preferredAltitude = " + Lua(movement.Elevation) + "\nUnitTemplate.movement.terrainAlignmentFactor = 0\nUnitTemplate.movement.elevation = nil\nUnitTemplate.movement.continuous = nil";
		case "LegsSeabed":
		case "TracksSeabed":
			return "UnitTemplate.movement.air = nil\nUnitTemplate.movement.airHover = nil\nUnitTemplate.movement.minSpeed = nil\nUnitTemplate.movement.landWhenIdleSeconds = nil\nUnitTemplate.movement.altitudeJitterFactor = 0\nUnitTemplate.movement.bankFactor = 0\nUnitTemplate.movement.orbitRange = 0\nUnitTemplate.movement.orbitSpeed = 0\nUnitTemplate.movement.collisionMaskDefault = { \"" + text3 + "\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"" + text3 + "\" }\nUnitTemplate.movement.referenceAltitude = \"Ground\"\nUnitTemplate.movement.preferredAltitude = 0\nUnitTemplate.movement.terrainAlignmentFactor = 1\nUnitTemplate.movement.elevation = nil\nUnitTemplate.movement.continuous = nil";
		case "WaterSurface":
			return "UnitTemplate.movement.air = nil\nUnitTemplate.movement.airHover = nil\nUnitTemplate.movement.minSpeed = nil\nUnitTemplate.movement.landWhenIdleSeconds = nil\nUnitTemplate.movement.altitudeJitterFactor = 0\nUnitTemplate.movement.bankFactor = 0\nUnitTemplate.movement.orbitRange = 0\nUnitTemplate.movement.orbitSpeed = 0\nUnitTemplate.movement.collisionMaskDefault = { \"Sea\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"Sea\" }\nUnitTemplate.movement.referenceAltitude = \"GroundOrWater\"\nUnitTemplate.movement.preferredAltitude = 0\nUnitTemplate.movement.terrainAlignmentFactor = 0\nUnitTemplate.movement.elevation = nil\nUnitTemplate.movement.continuous = nil";
		case "UnderWater":
			return "UnitTemplate.movement.air = nil\nUnitTemplate.movement.airHover = nil\nUnitTemplate.movement.minSpeed = nil\nUnitTemplate.movement.landWhenIdleSeconds = nil\nUnitTemplate.movement.altitudeJitterFactor = 0\nUnitTemplate.movement.bankFactor = 0\nUnitTemplate.movement.orbitRange = 0\nUnitTemplate.movement.orbitSpeed = 0\nUnitTemplate.movement.collisionMaskDefault = { \"Submarine\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"Submarine\" }\nUnitTemplate.movement.referenceAltitude = \"Water\"\nUnitTemplate.movement.preferredAltitude = " + Lua(movement.Elevation) + "\nUnitTemplate.movement.terrainAlignmentFactor = 0\nUnitTemplate.movement.elevation = nil\nUnitTemplate.movement.continuous = nil";
		case "Plane":
		case "Gunship":
		{
			double num = ((movement.AirHover || movement.MinSpeed <= 0.0) ? movement.Speed : movement.MinSpeed);
			double num2 = movement.RotationSpeed * Math.PI / 180.0;
			double value = ((num2 > 0.0) ? (num / num2) : 0.0);
			return "UnitTemplate.movement.air = true\nUnitTemplate.movement.airHover = " + Lua(movement.AirHover) + "\nUnitTemplate.movement.minSpeed = " + Lua(movement.MinSpeed) + "\nUnitTemplate.movement.landWhenIdleSeconds = 5\nUnitTemplate.movement.altitudeJitterFactor = 1\nUnitTemplate.movement.bankFactor = " + Lua((!movement.AirHover) ? 1 : 0) + "\nUnitTemplate.movement.orbitRange = " + Lua(value) + "\nUnitTemplate.movement.orbitSpeed = " + Lua(num) + "\nUnitTemplate.movement.collisionMaskDefault = { \"Air\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"" + text2 + "\" }\nUnitTemplate.movement.referenceAltitude = \"GroundOrWater\"\nUnitTemplate.movement.preferredAltitude = " + Lua(movement.Elevation) + "\nUnitTemplate.movement.terrainAlignmentFactor = 0\nUnitTemplate.movement.elevation = nil\nUnitTemplate.movement.continuous = nil";
		}
		default:
			throw new InvalidOperationException("Unsupported Sanctuary movement type " + movement.SanctuaryType + " for " + port.SourceId + ".");
		}
	}

	private static string? AeonEngineerBuildClip(GeneratedPortSpec port)
	{
		switch (port.SourceId)
		{
		case "UAL0105":
			return "AnimAopen01";
		case "UAL0208":
		case "UAL0309":
			return "AnimOpen";
		default:
			return null;
		}
	}

	private static string BuildAnimationOverride(GeneratedPortSpec port)
	{
		if (!port.HasVisualAsset)
		{
			return "UnitTemplate.visuals.animations = nil";
		}
		List<AnimationEntry> list = new List<AnimationEntry>
		{
			new AnimationEntry("walk", "Rest", 0.0)
		};
		HashSet<string> hashSet = new HashSet<string>(StringComparer.Ordinal) { "Rest" };
		string text = AeonEngineerBuildClip(port);
		if (text != null)
		{
			if (!port.AnimationClips.Contains<string>(text, StringComparer.Ordinal))
			{
				throw new InvalidOperationException(port.SourceId + " lost its source engineer build clip " + text + ".");
			}
			list.Add(new AnimationEntry("build", text, 0.0));
			hashSet.Add(text);
		}
		if (port.Movement.RunClip.Length != 0)
		{
			list.Add(new AnimationEntry("run", port.Movement.RunClip, port.Movement.AuthoredSpeed));
			hashSet.Add(port.Movement.RunClip);
		}
		Dictionary<string, int> dictionary = new Dictionary<string, int>(StringComparer.Ordinal);
		string[] animationClips = port.AnimationClips;
		foreach (string text2 in animationClips)
		{
			if (hashSet.Add(text2))
			{
				string text3 = "source_" + MakeLuaIdentifier(text2);
				dictionary.TryGetValue(text3, out var value);
				dictionary[text3] = value + 1;
				list.Add(new AnimationEntry((value == 0) ? text3 : (text3 + "_" + (value + 1).ToString(CultureInfo.InvariantCulture)), text2, 0.0));
			}
		}
		string text4 = null;
		double value2 = 0.0;
		switch (port.SourceId)
		{
		case "UAB0101":
			text4 = "AnimOpen";
			value2 = 7.400000095367432;
			break;
		case "UAB0201":
			text4 = "AnimOpen";
			value2 = 5.0;
			break;
		case "UAB0102":
			text4 = "AnimUpgrade";
			value2 = 4.666666507720947;
			break;
		case "UAB0202":
			text4 = "AnimUpgrade";
			value2 = 4.0;
			break;
		case "UAB0103":
		case "UAB0203":
			text4 = "AnimOpen";
			value2 = 3.3333332538604736;
			break;
		}
		if (text4 != null && !port.AnimationClips.Contains<string>(text4, StringComparer.Ordinal))
		{
			throw new InvalidOperationException(port.SourceId + " lost its source factory upgrade clip " + text4 + ".");
		}
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("UnitTemplate.visuals.animations = {");
		foreach (AnimationEntry item in list)
		{
			stringBuilder.Append("    ").Append(item.Key).AppendLine(" = {");
			if (item.AuthoredSpeed > 0.0)
			{
				stringBuilder.Append("        authoredSpeed = ").Append(Lua(item.AuthoredSpeed)).AppendLine(",");
				stringBuilder.AppendLine("        startSpeed = 0.05,");
			}
			stringBuilder.Append("        clipName = \"").Append(EscapeLua(item.ClipName)).AppendLine("\",");
			stringBuilder.Append("        sanAnimationPath = \"Units/").Append(port.TargetId).Append("/LOD0/")
				.Append(port.TargetId)
				.AppendLine(".sananimation\",");
			if (item.Key == "build")
			{
				stringBuilder.AppendLine("        playbackMode = 0,");
			}
			stringBuilder.AppendLine("    },");
		}
		stringBuilder.AppendLine("}");
		if (text4 == null)
		{
			stringBuilder.AppendLine("UnitTemplate.additions.progressBoundUpgradeAnimation = nil");
		}
		else
		{
			string value3 = "source_" + MakeLuaIdentifier(text4);
			stringBuilder.Append("UnitTemplate.visuals.animations.").Append(value3).AppendLine(".playbackMode = 0");
			stringBuilder.AppendLine("UnitTemplate.additions.progressBoundUpgradeAnimation = {");
			stringBuilder.Append("    animationKey = \"").Append(value3).AppendLine("\",");
			stringBuilder.Append("    durationSeconds = ").Append(Lua(value2)).AppendLine(",");
			stringBuilder.AppendLine("    restAnimationKey = \"walk\",");
			stringBuilder.AppendLine("}");
		}
		if (text == null)
		{
			stringBuilder.Append("UnitTemplate.additions.aeonEngineerBuildAnimation = nil");
		}
		else
		{
			stringBuilder.AppendLine("UnitTemplate.additions.aeonEngineerBuildAnimation = {");
			stringBuilder.AppendLine("    animationKey = \"build\",");
			stringBuilder.AppendLine("    durationSeconds = 1.6666666269302368,");
			stringBuilder.AppendLine("    authoredRate = 1,");
			stringBuilder.AppendLine("    restAnimationKey = \"walk\",");
			stringBuilder.Append('}');
		}
		return stringBuilder.ToString();
	}

	private static string BuildWeaponOverride(GeneratedPortSpec port)
	{
		if (port.Weapons.Length == 0)
		{
			return "UnitTemplate.turrets = nil\nUnitTemplate.weapons = nil";
		}
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("UnitTemplate.turrets = nil");
		stringBuilder.AppendLine("UnitTemplate.weapons = {");
		for (int i = 0; i < port.Weapons.Length; i++)
		{
			AppendWeapon(stringBuilder, port, port.Weapons[i], i);
		}
		stringBuilder.AppendLine("}");
		return stringBuilder.ToString();
	}

	private static void AppendWeapon(StringBuilder builder, GeneratedPortSpec port, GeneratedWeaponSpec weapon, int weaponIndex)
	{
		if (weapon.IsDeath)
		{
			builder.AppendLine("    {");
			builder.AppendLine("        category = \"DeathExplosion\",");
			builder.Append("        damage = ").Append(Lua(weapon.Damage)).AppendLine(",");
			builder.Append("        damageRadius = ").Append(Lua(weapon.DamageRadius)).AppendLine(",");
			builder.AppendLine("        damageFriendly = true,");
			builder.AppendLine("        damageType = \"Normal\",");
			builder.AppendLine("    },");
			return;
		}
		GeneratedCzarBeamHook generatedCzarBeamHook = ((weaponIndex == 0 && port.CzarBeam.Enabled) ? port.CzarBeam : null);
		bool flag = IsAeonT1MobileArtillery(port, weapon);
		string value = generatedCzarBeamHook?.CenterBone ?? weapon.AimBone;
		string value2 = generatedCzarBeamHook?.CenterBone ?? (flag ? "Turret" : weapon.YawBone);
		string value3 = generatedCzarBeamHook?.CenterBone ?? weapon.PitchBone;
		string[][] array = RuntimeMuzzleGroups(weapon, generatedCzarBeamHook?.CenterBone);
		string[] array2 = array.SelectMany((string[] group) => group).Distinct<string>(StringComparer.Ordinal).ToArray();
		string[] values = OriginLayers(port);
		builder.AppendLine("    {");
		builder.Append("        scoSourceLabel = \"").Append(EscapeLua(weapon.Label)).AppendLine("\",");
		builder.Append("        scoSourceCategory = \"").Append(EscapeLua(weapon.SourceCategory)).AppendLine("\",");
		if (port.SourceId == "UAL0401" && (weapon.Label == "EyeWeapon" || weapon.Label == "RightArmTractor" || weapon.Label == "LeftArmTractor"))
		{
			builder.AppendLine("        scoAboveWaterFireOnly = true,");
			builder.AppendLine("        scoAboveWaterTargetsOnly = true,");
		}
		if (!string.IsNullOrEmpty(weapon.SpecialMuzzleBone))
		{
			if (port.SourceId != "UAL0401" || (weapon.Label != "RightArmTractor" && weapon.Label != "LeftArmTractor"))
			{
				throw new InvalidOperationException("Unreviewed special-muzzle weapon " + port.SourceId + "/" + weapon.Label + ".");
			}
			builder.AppendLine("        scoTractor = {");
			builder.Append("            captureBone = \"").Append(EscapeLua(weapon.SpecialMuzzleBone)).AppendLine("\",");
			builder.AppendLine("            crushDuration = 1,");
			builder.AppendLine("            pullSpeed = 15,");
			builder.AppendLine("            sourceClass = \"ADFTractorClaw\",");
			if (weapon.HasHeadingArc)
			{
				builder.Append("            headingArcCenter = ").Append(Lua(weapon.HeadingArcCenter)).AppendLine(",");
				builder.Append("            headingArcRange = ").Append(Lua(weapon.HeadingArcRange)).AppendLine(",");
			}
			builder.AppendLine("        },");
		}
		builder.AppendLine("        aimControllers = {");
		if (generatedCzarBeamHook == null)
		{
			builder.AppendLine("            {");
			builder.Append("                aimBone = \"").Append(EscapeLua(value)).AppendLine("\",");
			builder.Append("                aimTolerance = ").Append(Lua(weapon.FiringTolerance)).AppendLine(",");
			builder.Append("                defaultPitchAdjustment = ").Append(Lua(weapon.DefaultPitch)).AppendLine(",");
			builder.Append("                defaultYawAdjustment = ").Append(Lua(weapon.DefaultYaw)).AppendLine(",");
			builder.AppendLine((weapon.IsBeam || flag) ? "                leadTarget = false," : "                leadTarget = true,");
			builder.Append("                pitchBone = \"").Append(EscapeLua(value3)).AppendLine("\",");
			builder.Append("                pitchMax = ").Append(Lua(weapon.DefaultPitch + weapon.PitchRange)).AppendLine(",");
			builder.Append("                pitchMin = ").Append(Lua(weapon.DefaultPitch - weapon.PitchRange)).AppendLine(",");
			builder.Append("                pitchSpeed = ").Append(Lua(weapon.PitchSpeed)).AppendLine(",");
			builder.AppendLine("                poseResetTime = 3,");
			double value4 = ((weapon.IsBeam && weapon.ProjectileSpeed <= 0.0) ? 30.0 : weapon.ProjectileSpeed);
			builder.Append("                projectileSpeed = ").Append(Lua(value4)).AppendLine(",");
			if (flag)
			{
				builder.AppendLine("                aimGravity = { x = 0, y = -4.9, z = 0 },");
				builder.AppendLine("                reduceMuzzleVelocityToTarget = true,");
			}
			builder.Append("                solverType = \"").Append(EscapeLua(weapon.SolverType)).AppendLine("\",");
			builder.Append("                yawBone = \"").Append(EscapeLua(value2)).AppendLine("\",");
			double value5 = weapon.DefaultYaw - weapon.YawRange;
			double value6 = weapon.DefaultYaw + weapon.YawRange;
			builder.Append("                yawMax = ").Append(Lua(value6)).AppendLine(",");
			builder.Append("                yawMin = ").Append(Lua(value5)).AppendLine(",");
			builder.Append("                yawSpeed = ").Append(Lua(weapon.YawSpeed)).AppendLine(",");
			builder.AppendLine("            },");
		}
		builder.AppendLine("        },");
		builder.Append("        damage = ").Append(Lua((generatedCzarBeamHook == null) ? weapon.Damage : 0.0)).AppendLine(",");
		builder.Append("        damageRadius = ").Append(Lua(weapon.DamageRadius)).AppendLine(",");
		builder.AppendLine("        damageType = \"Normal\",");
		builder.AppendLine("        firingRandomness = 0,");
		AppendStringArray(builder, "layerTargetLimits", weapon.TargetLayers, 8);
		AppendStringArray(builder, "layerWeaponLimits", values, 8);
		builder.Append("        muzzleGroupChargeDelay = ").Append(Lua(weapon.RackChargeDelay)).AppendLine(",");
		builder.Append("        muzzleGroupTimeOut = ").Append(Lua(weapon.RackTimeout)).AppendLine(",");
		builder.AppendLine("        muzzleGroups = {");
		string[][] array3 = array;
		foreach (string[] values2 in array3)
		{
			builder.AppendLine("            {");
			AppendStringArray(builder, "muzzles", values2, 16);
			builder.AppendLine("            },");
		}
		builder.AppendLine("        },");
		builder.Append("        muzzleSalvoDelay = ").Append(Lua(weapon.MuzzleSalvoDelay)).AppendLine(",");
		builder.Append("        muzzleSalvoSize = ").Append(Math.Max(1, weapon.MuzzleSalvoSize) * weapon.RackSalvoSize).AppendLine(",");
		if (generatedCzarBeamHook == null)
		{
			builder.AppendLine("        muzzles = {");
			string[] array4 = array2;
			foreach (string value7 in array4)
			{
				builder.Append("            [\"").Append(EscapeLua(value7)).AppendLine("\"] = {");
				builder.Append("                aimController = \"").Append(EscapeLua(value)).AppendLine("\",");
				builder.AppendLine("            },");
			}
			builder.AppendLine("        },");
		}
		builder.Append("        projectileLifetime = ").Append(Lua(flag ? 20.0 : weapon.ProjectileLifetime)).AppendLine(",");
		builder.Append("        projectileTemplate = \"").Append(EscapeLua(weapon.ProjectileTemplate)).AppendLine("\",");
		builder.Append("        rangeMax = ").Append(Lua(weapon.RangeMax)).AppendLine(",");
		builder.Append("        rangeMin = ").Append(Lua(weapon.RangeMin)).AppendLine(",");
		builder.Append("        rangeRingType = \"").Append(EscapeLua(weapon.RangeRingType)).AppendLine("\",");
		builder.AppendLine("        rangeTracking = 1.1,");
		builder.Append("        reloadTime = ").Append(Lua(weapon.ReloadTime)).AppendLine(",");
		builder.Append("        targetWaterLimits = \"").Append(EscapeLua(weapon.TargetWaterLimits)).AppendLine("\",");
		if (weapon.IsBeam)
		{
			AppendBeam(builder, port, weapon, generatedCzarBeamHook);
		}
		builder.AppendLine("    },");
	}

	private static bool IsAeonT1MobileArtillery(GeneratedPortSpec port, GeneratedWeaponSpec weapon)
	{
		if (string.Equals(port.TargetId, "ucl1101", StringComparison.Ordinal) && string.Equals(port.SourceId, "UAL0103", StringComparison.Ordinal) && string.Equals(weapon.Label, "MainGun", StringComparison.Ordinal) && string.Equals(weapon.SourceCategory, "Artillery", StringComparison.Ordinal) && string.Equals(weapon.AimBone, "Turret_Muzzle", StringComparison.Ordinal) && string.Equals(weapon.YawBone, "Turret_Barrel", StringComparison.Ordinal) && string.Equals(weapon.PitchBone, "Turret_Barrel", StringComparison.Ordinal) && string.Equals(weapon.ProjectileTemplate, "pai111", StringComparison.Ordinal) && string.Equals(weapon.SolverType, "HighArc", StringComparison.Ordinal) && weapon.Damage == 200.0 && weapon.DamageRadius == 0.5 && weapon.RangeMin == 5.0 && weapon.RangeMax == 30.0 && weapon.ReloadTime == 2.0 && weapon.ProjectileSpeed == 14.0)
		{
			return weapon.DefaultPitch == 45.0;
		}
		return false;
	}

	private static string[][] RuntimeMuzzleGroups(GeneratedWeaponSpec weapon, string? forcedMuzzle)
	{
		if (!string.IsNullOrEmpty(forcedMuzzle))
		{
			return new string[1][] { new string[1] { forcedMuzzle } };
		}
		if (weapon.RackFireTogether)
		{
			return new string[1][] { weapon.Racks.SelectMany((GeneratedRackSpec rack) => rack.Muzzles).Distinct<string>(StringComparer.Ordinal).ToArray() };
		}
		return weapon.Racks.Select((GeneratedRackSpec rack) => rack.Muzzles.ToArray()).ToArray();
	}

	private static string[] OriginLayers(GeneratedPortSpec port)
	{
		if (!port.Movement.Air)
		{
			if (!(port.Movement.SourceMotionType == "RULEUMT_Water") && !(port.Movement.SourceMotionType == "RULEUMT_SurfacingSub"))
			{
				if (!(port.Movement.SourceMotionType == "RULEUMT_Hover") && !(port.Movement.SourceMotionType == "RULEUMT_Amphibious"))
				{
					return new string[1] { "Land" };
				}
				return new string[2] { "Land", "WaterSurface" };
			}
			return new string[1] { "WaterSurface" };
		}
		return new string[1] { "Air" };
	}

	private static void AppendBeam(StringBuilder builder, GeneratedPortSpec port, GeneratedWeaponSpec weapon, GeneratedCzarBeamHook? hook)
	{
		double value = ((hook != null || weapon.BeamLifetime == 0.0) ? (-1.0) : weapon.BeamLifetime);
		builder.Append("        beamLifetime = ").Append(Lua(value)).AppendLine(",");
		bool flag = port.SourceId == "UAL0401" && (weapon.Label == "RightArmTractor" || weapon.Label == "LeftArmTractor");
		if (hook == null && !flag)
		{
			builder.AppendLine("        effects = {");
			builder.Append("            onFire = \"").Append("VFX/AeonProjectiles/Muzzle/vcm7101_beam_antitank_small_muzzle.sanvfx").AppendLine("\",");
			builder.AppendLine("        },");
		}
		builder.AppendLine("        beam = {");
		if (hook != null)
		{
			builder.AppendLine("            subMesh = {");
			builder.AppendLine("                {");
			builder.Append("                    model = \"").Append("VFX/SupremeCommanderOverhaul/Czar/Models/czar_quantum_beam_cylinder.sanmodel").AppendLine("\",");
			builder.Append("                    material = \"").Append(EscapeLua(hook.BeamMaterial)).AppendLine("\",");
			builder.AppendLine("                },");
			builder.AppendLine("                {");
			builder.Append("                    model = \"").Append("VFX/SupremeCommanderOverhaul/Czar/Models/czar_quantum_beam_cylinder.sanmodel").AppendLine("\",");
			builder.Append("                    material = \"").Append("VFX/SupremeCommanderOverhaul/Czar/Materials/czar_quantum_beam_distortion.sanmaterial").AppendLine("\",");
			builder.AppendLine("                },");
			builder.AppendLine("            },");
			builder.AppendLine("            fadeInTime = 0,");
			builder.AppendLine("            fadeOutTime = 0.7,");
			builder.AppendLine("            cullDistance = 500,");
			builder.AppendLine("        },");
			return;
		}
		bool flag2 = port.SourceId == "UAL0401" && weapon.Label == "EyeWeapon";
		if (flag)
		{
			builder.AppendLine("            subMesh = {");
			builder.AppendLine("                {");
			builder.Append("                    model = \"").Append("VFX/AeonProjectiles/Models/GalacticColossus/galactic_colossus_tractor_beam.sanmodel").AppendLine("\",");
			builder.Append("                    material = \"").Append("VFX/AeonProjectiles/Materials/GalacticColossus/galactic_colossus_tractor_beam.sanmaterial").AppendLine("\",");
			builder.AppendLine("                },");
			builder.AppendLine("            },");
			builder.AppendLine("            fadeInTime = 0.15,");
			builder.AppendLine("            fadeOutTime = 0.6,");
			builder.AppendLine("            renderLifetime = 0.5,");
			builder.AppendLine("            cullDistance = 500,");
			builder.AppendLine("        },");
		}
		else
		{
			builder.AppendLine("            subMesh = {");
			builder.AppendLine("                {");
			builder.Append("                    model = \"").Append("VFX/Models/Beams/BeamBasicLongSingle.sanmodel").AppendLine("\",");
			builder.Append("                    material = \"").Append(flag2 ? "VFX/AeonProjectiles/Materials/GalacticColossus/galactic_colossus_eye_core.sanmaterial" : "VFX/AeonProjectiles/Materials/Beam/Beam ucs1001_01.sanmaterial").AppendLine("\",");
			builder.AppendLine("                },");
			builder.AppendLine("                {");
			builder.Append("                    model = \"").Append("VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel").AppendLine("\",");
			builder.Append("                    material = \"").Append(flag2 ? "VFX/AeonProjectiles/Materials/GalacticColossus/galactic_colossus_eye_aura.sanmaterial" : "VFX/AeonProjectiles/Materials/Beam/Beam ucs1001_02.sanmaterial").AppendLine("\",");
			builder.AppendLine("                },");
			builder.AppendLine("            },");
			builder.AppendLine("            fadeInTime = 0.1,");
			builder.AppendLine("            fadeOutTime = 0.6,");
			builder.AppendLine("            renderLifetime = 0.5,");
			builder.AppendLine("            cullDistance = 500,");
			builder.AppendLine("        },");
		}
	}

	private static string BuildTagsOverride(GeneratedPortSpec port)
	{
		HashSet<string> hashSet = new HashSet<string>(port.SourceCategories, StringComparer.Ordinal);
		HashSet<string> hashSet2 = new HashSet<string>(StringComparer.Ordinal) { "CHOSEN" };
		SourceTagMapping[] array = new SourceTagMapping[31]
		{
			new SourceTagMapping("AIR", "AIR"),
			new SourceTagMapping("LAND", "LAND"),
			new SourceTagMapping("NAVAL", "NAVAL"),
			new SourceTagMapping("STRUCTURE", "STRUCTURE"),
			new SourceTagMapping("MOBILE", "MOBILE"),
			new SourceTagMapping("ENGINEER", "ENGINEER"),
			new SourceTagMapping("CONSTRUCTION", "CONSTRUCTION"),
			new SourceTagMapping("FACTORY", "FACTORY"),
			new SourceTagMapping("HOVER", "HOVER"),
			new SourceTagMapping("SUBMERSIBLE", "SEABED"),
			new SourceTagMapping("DIRECTFIRE", "DIRECT_FIRE"),
			new SourceTagMapping("INDIRECTFIRE", "INDIRECT_FIRE"),
			new SourceTagMapping("ARTILLERY", "ARTILLERY"),
			new SourceTagMapping("ANTIAIR", "ANTI_AIR"),
			new SourceTagMapping("ANTINAVY", "ANTI_NAVAL"),
			new SourceTagMapping("ANTIMISSILE", "ANTI_PROJECTILE"),
			new SourceTagMapping("GROUNDATTACK", "ANTI_SURFACE"),
			new SourceTagMapping("BOMBER", "BOMBER"),
			new SourceTagMapping("BOT", "BOT"),
			new SourceTagMapping("TANK", "TANK"),
			new SourceTagMapping("SCOUT", "SCOUT"),
			new SourceTagMapping("ECONOMIC", "ECONOMIC"),
			new SourceTagMapping("ENERGYPRODUCTION", "ENERGY_PRODUCTION"),
			new SourceTagMapping("ENERGYSTORAGE", "ENERGY_STORAGE"),
			new SourceTagMapping("MASSEXTRACTION", "ALLOYS_EXTRACTION"),
			new SourceTagMapping("MASSPRODUCTION", "ALLOYS_PRODUCTION"),
			new SourceTagMapping("MASSSTORAGE", "ALLOYS_STORAGE"),
			new SourceTagMapping("DEFENSE", "DEFENCE"),
			new SourceTagMapping("STRATEGIC", "STRATEGIC"),
			new SourceTagMapping("TRANSPORTATION", "TRANSPORT"),
			new SourceTagMapping("WALL", "WALL")
		};
		foreach (SourceTagMapping sourceTagMapping in array)
		{
			if (hashSet.Contains(sourceTagMapping.Source))
			{
				hashSet2.Add(sourceTagMapping.Target);
			}
		}
		if (port.Movement.Enabled)
		{
			string[] array2 = new string[6] { "AIR", "GUNSHIP", "LAND", "HOVER", "SEABED", "NAVAL" };
			foreach (string item in array2)
			{
				hashSet2.Remove(item);
			}
			switch (port.Movement.SanctuaryType)
			{
			case "Plane":
				hashSet2.Add("AIR");
				break;
			case "Gunship":
				hashSet2.Add("AIR");
				hashSet2.Add("GUNSHIP");
				break;
			case "Hover":
				hashSet2.Add("LAND");
				hashSet2.Add("HOVER");
				break;
			case "TracksLand":
			case "LegsLand":
				hashSet2.Add("LAND");
				break;
			case "LegsSeabed":
			case "TracksSeabed":
				hashSet2.Add("LAND");
				hashSet2.Add("SEABED");
				break;
			case "UnderWater":
			case "WaterSurface":
				hashSet2.Add("NAVAL");
				break;
			default:
				throw new InvalidOperationException("Unsupported movement/tag synchronization type " + port.Movement.SanctuaryType + " for " + port.SourceId + ".");
			}
		}
		if (port.SourceId == "UAA0310")
		{
			hashSet2.Add("CONSTRUCTION");
		}
		if (port.Intel.RadarRadius.HasValue)
		{
			hashSet2.Add("RADAR");
			hashSet2.Add("INTEL");
		}
		if (port.Shield.Enabled)
		{
			hashSet2.Add("SHIELD");
		}
		if (hashSet.Contains("EXPERIMENTAL"))
		{
			hashSet2.Add("TECH4");
		}
		else if (hashSet.Contains("TECH3"))
		{
			hashSet2.Add("TECH3");
		}
		else if (hashSet.Contains("TECH2"))
		{
			hashSet2.Add("TECH2");
		}
		else if (hashSet.Contains("TECH1"))
		{
			hashSet2.Add("TECH1");
		}
		if (port.RosterVisible)
		{
			AddBuildabilityTags(hashSet, hashSet2);
		}
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("UnitTemplate.tags = {");
		foreach (string item2 in hashSet2.OrderBy<string, string>((string value) => value, StringComparer.Ordinal))
		{
			stringBuilder.Append("    \"").Append(EscapeLua(item2)).AppendLine("\",");
		}
		stringBuilder.Append('}');
		return stringBuilder.ToString();
	}

	private static void AddBuildabilityTags(HashSet<string> source, HashSet<string> tags)
	{
		if (source.Contains("BUILTBYCOMMANDER") || source.Contains("BUILTBYTIER1ENGINEER"))
		{
			tags.Add("BUILDABLE_BY_T1_ENGINEER");
			tags.Add("BUILDABLE_BY_T2_ENGINEER");
			tags.Add("BUILDABLE_BY_T3_ENGINEER");
		}
		if (source.Contains("BUILTBYTIER2COMMANDER") || source.Contains("BUILTBYTIER2ENGINEER"))
		{
			tags.Add("BUILDABLE_BY_T2_ENGINEER");
			tags.Add("BUILDABLE_BY_T3_ENGINEER");
		}
		if (source.Contains("BUILTBYTIER3COMMANDER") || source.Contains("BUILTBYTIER3ENGINEER"))
		{
			tags.Add("BUILDABLE_BY_T3_ENGINEER");
		}
		if (source.Contains("BUILTBYTIER1FACTORY") || source.Contains("TRANSPORTBUILTBYTIER1FACTORY"))
		{
			tags.Add("BUILDABLE_BY_T1_FACTORY");
			tags.Add("BUILDABLE_BY_T2_FACTORY");
			tags.Add("BUILDABLE_BY_T3_FACTORY");
		}
		if (source.Contains("BUILTBYTIER2FACTORY") || source.Contains("TRANSPORTBUILTBYTIER2FACTORY"))
		{
			tags.Add("BUILDABLE_BY_T2_FACTORY");
			tags.Add("BUILDABLE_BY_T3_FACTORY");
		}
		if (source.Contains("BUILTBYTIER3FACTORY") || source.Contains("TRANSPORTBUILTBYTIER3FACTORY"))
		{
			tags.Add("BUILDABLE_BY_T3_FACTORY");
		}
	}

	private static string BuildOrdersOverride(GeneratedPortSpec port)
	{
		HashSet<string> hashSet = new HashSet<string>(port.SourceCategories, StringComparer.Ordinal);
		HashSet<string> hashSet2 = new HashSet<string>(StringComparer.Ordinal) { "Stop" };
		bool flag = hashSet.Contains("MOBILE");
		bool flag2 = hashSet.Contains("FACTORY");
		bool num = hashSet.Contains("ENGINEER") || hashSet.Contains("CONSTRUCTION");
		bool flag3 = port.ClassName == "AeonPortLandFactory" || port.ClassName == "AeonPortAirFactory" || port.ClassName == "AeonPortNavalFactory" || port.SourceId == "UAA0310";
		bool flag4 = port.ClassName == "AeonPortEngineer";
		bool num2 = port.Weapons.Any((GeneratedWeaponSpec weapon) => !weapon.IsDeath);
		if (flag)
		{
			hashSet2.Add("Assist");
			hashSet2.Add("Move");
			hashSet2.Add("Patrol");
		}
		if (flag2)
		{
			hashSet2.Add("Assist");
		}
		if (num2)
		{
			hashSet2.Add("Attack");
			if (flag)
			{
				hashSet2.Add("AttackMove");
			}
		}
		if (num)
		{
			hashSet2.Add("Assist");
			if (flag)
			{
				hashSet2.Add("AttackMove");
			}
			if (hashSet.Contains("CAPTURE"))
			{
				hashSet2.Add("Capture");
			}
			if (hashSet.Contains("RECLAIM"))
			{
				hashSet2.Add("Harvest");
			}
			if (hashSet.Contains("REPAIR"))
			{
				hashSet2.Add("Repair");
			}
		}
		if (hashSet.Contains("SILO") || hashSet.Contains("NUKE") || hashSet.Contains("TACTICALMISSILEPLATFORM"))
		{
			hashSet2.Add("StrategicManualLaunch");
		}
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("UnitTemplate.general.orders = {");
		foreach (string item in hashSet2.OrderBy<string, string>((string value) => value, StringComparer.Ordinal))
		{
			stringBuilder.Append("    ").Append(item).AppendLine(" = true,");
		}
		if (flag3 || flag4)
		{
			stringBuilder.AppendLine("    Pause = false,");
		}
		stringBuilder.AppendLine("}");
		if (flag3)
		{
			stringBuilder.AppendLine("UnitTemplate.general.toggles = {");
			stringBuilder.AppendLine("    Pause = false,");
			stringBuilder.AppendLine("    RepeatBuild = true,");
			stringBuilder.Append('}');
		}
		else if (flag4)
		{
			stringBuilder.AppendLine("UnitTemplate.general.toggles = {");
			stringBuilder.AppendLine("    Pause = false,");
			stringBuilder.Append('}');
		}
		return stringBuilder.ToString();
	}

	private static string BuildSourceContract(GeneratedPortSpec port)
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("UnitTemplate.additions.faSourceContract = {");
		stringBuilder.Append("    sourceId = \"").Append(EscapeLua(port.SourceId)).AppendLine("\",");
		stringBuilder.Append("    targetId = \"").Append(EscapeLua(port.TargetId)).AppendLine("\",");
		stringBuilder.Append("    sourceArchiveSha256 = \"").Append("c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26").AppendLine("\",");
		stringBuilder.Append("    sourceBlueprint = \"").Append(EscapeLua(port.SourceBlueprintEntry)).AppendLine("\",");
		stringBuilder.Append("    sourceBlueprintSha256 = \"").Append(port.SourceBlueprintHash).AppendLine("\",");
		stringBuilder.Append("    sourceMotionType = \"").Append(EscapeLua(port.Movement.SourceMotionType)).AppendLine("\",");
		stringBuilder.Append("    sourceElevation = ").Append(Lua(port.Movement.Elevation)).AppendLine(",");
		stringBuilder.Append("    sourceKLift = ").Append(Lua(port.Movement.LiftCoefficient)).AppendLine(",");
		stringBuilder.Append("    sourceKLiftDamping = ").Append(Lua(port.Movement.LiftDamping)).AppendLine(",");
		stringBuilder.Append("    sourceLiftFactor = ").Append(Lua(port.Movement.LiftFactor)).AppendLine(",");
		stringBuilder.Append("    sourceConstructionSurfaceClearance = ").Append(Lua(port.Movement.ConstructionSurfaceClearance)).AppendLine(",");
		stringBuilder.Append("    constructionSurfaceModelEntry = \"").Append(EscapeLua(port.Movement.ConstructionSurfaceModelEntry)).AppendLine("\",");
		stringBuilder.Append("    constructionSurfaceModelSha256 = \"").Append(EscapeLua(port.Movement.ConstructionSurfaceModelSha256)).AppendLine("\",");
		stringBuilder.Append("    movementCompatibility = \"").Append(EscapeLua(port.Movement.CompatibilityNote)).AppendLine("\",");
		AppendStringArray(stringBuilder, "sourceCategories", port.SourceCategories, 4);
		stringBuilder.Append("    sourceUpgradeFrom = \"").Append(EscapeLua(port.SourceUpgradeFrom)).AppendLine("\",");
		stringBuilder.Append("    sourceUpgradeTo = \"").Append(EscapeLua(port.SourceUpgradeTo)).AppendLine("\",");
		stringBuilder.AppendLine("    placement = {");
		stringBuilder.Append("        footprintSource = \"").Append(EscapeLua(port.Placement.FootprintSource)).AppendLine("\",");
		stringBuilder.AppendLine("        footprint = {");
		stringBuilder.Append("            x = ").Append(Lua(port.Placement.FootprintX)).AppendLine(",");
		stringBuilder.Append("            z = ").Append(Lua(port.Placement.FootprintZ)).AppendLine(",");
		stringBuilder.AppendLine("        },");
		stringBuilder.Append("        sourceSkirtPresent = ").Append(Lua(port.Placement.HasSourceSkirt)).AppendLine(",");
		if (port.Placement.HasSourceSkirt)
		{
			stringBuilder.AppendLine("        sourceSkirt = {");
			stringBuilder.Append("            sizeX = ").Append(Lua(port.Placement.SkirtX)).AppendLine(",");
			stringBuilder.Append("            sizeZ = ").Append(Lua(port.Placement.SkirtZ)).AppendLine(",");
			stringBuilder.Append("            offsetX = ").Append(Lua(port.Placement.SkirtOffsetX)).AppendLine(",");
			stringBuilder.Append("            offsetZ = ").Append(Lua(port.Placement.SkirtOffsetZ)).AppendLine(",");
			stringBuilder.AppendLine("        },");
		}
		stringBuilder.AppendLine("    },");
		stringBuilder.AppendLine("    intel = {");
		stringBuilder.AppendLine("        runtimeSupported = {");
		AppendOptionalNumber(stringBuilder, "visionRadius", port.Intel.VisionRadius, 12);
		AppendOptionalNumber(stringBuilder, "radarRadius", port.Intel.RadarRadius, 12);
		stringBuilder.AppendLine("        },");
		stringBuilder.AppendLine("        provenanceOnly = {");
		AppendOptionalNumber(stringBuilder, "sonarRadius", port.Intel.SonarRadius, 12);
		AppendOptionalNumber(stringBuilder, "omniRadius", port.Intel.OmniRadius, 12);
		AppendOptionalBoolean(stringBuilder, "radarStealth", port.Intel.RadarStealth, 12);
		AppendOptionalBoolean(stringBuilder, "sonarStealth", port.Intel.SonarStealth, 12);
		AppendOptionalNumber(stringBuilder, "radarStealthFieldRadius", port.Intel.RadarStealthFieldRadius, 12);
		AppendOptionalNumber(stringBuilder, "sonarStealthFieldRadius", port.Intel.SonarStealthFieldRadius, 12);
		AppendOptionalNumber(stringBuilder, "remoteViewingRadius", port.Intel.RemoteViewingRadius, 12);
		AppendOptionalNumber(stringBuilder, "reactivateTime", port.Intel.ReactivateTime, 12);
		AppendOptionalNumber(stringBuilder, "waterVisionRadius", port.Intel.WaterVisionRadius, 12);
		AppendOptionalBoolean(stringBuilder, "freeIntel", port.Intel.FreeIntel, 12);
		AppendOptionalBoolean(stringBuilder, "showIntelOnSelect", port.Intel.ShowIntelOnSelect, 12);
		stringBuilder.AppendLine("        },");
		stringBuilder.AppendLine("    },");
		stringBuilder.AppendLine("    shield = {");
		stringBuilder.Append("        enabled = ").Append(Lua(port.Shield.Enabled)).AppendLine(",");
		if (port.Shield.Enabled)
		{
			AppendOptionalBoolean(stringBuilder, "personal", port.Shield.Personal, 8);
			stringBuilder.Append("        maxHealth = ").Append(Lua(port.Shield.MaxHealth)).AppendLine(",");
			stringBuilder.Append("        rechargeTime = ").Append(Lua(port.Shield.RechargeTime)).AppendLine(",");
			stringBuilder.Append("        regenRate = ").Append(Lua(port.Shield.RegenRate)).AppendLine(",");
			stringBuilder.Append("        regenStartTime = ").Append(Lua(port.Shield.RegenStartTime)).AppendLine(",");
			stringBuilder.Append("        size = ").Append(Lua(port.Shield.Size)).AppendLine(",");
			stringBuilder.Append("        runtimeRadius = ").Append(Lua(port.Shield.RuntimeRadius)).AppendLine(",");
			stringBuilder.Append("        verticalOffset = ").Append(Lua(port.Shield.VerticalOffset)).AppendLine(",");
			stringBuilder.Append("        energyDrainRechargeTime = ").Append(Lua(port.Shield.EnergyDrainRechargeTime)).AppendLine(",");
		}
		stringBuilder.AppendLine("    },");
		if (port.Movement.HasSourceMaxBrake)
		{
			stringBuilder.Append("    sourceMaxBrake = ").Append(Lua(port.Movement.SourceMaxBrake)).AppendLine(",");
		}
		stringBuilder.AppendLine("    weapons = {");
		GeneratedWeaponSpec[] weapons = port.Weapons;
		foreach (GeneratedWeaponSpec generatedWeaponSpec in weapons)
		{
			stringBuilder.AppendLine("        {");
			stringBuilder.Append("            label = \"").Append(EscapeLua(generatedWeaponSpec.Label)).AppendLine("\",");
			stringBuilder.Append("            sourceCategory = \"").Append(EscapeLua(generatedWeaponSpec.SourceCategory)).AppendLine("\",");
			stringBuilder.Append("            rateOfFire = ").Append(Lua(generatedWeaponSpec.RateOfFire)).AppendLine(",");
			stringBuilder.Append("            reloadTime = ").Append(Lua(generatedWeaponSpec.ReloadTime)).AppendLine(",");
			stringBuilder.Append("            rackFireTogether = ").Append(Lua(generatedWeaponSpec.RackFireTogether)).AppendLine(",");
			stringBuilder.Append("            rackSalvoSize = ").Append(generatedWeaponSpec.RackSalvoSize).AppendLine(",");
			stringBuilder.Append("            muzzleSalvoSize = ").Append(generatedWeaponSpec.MuzzleSalvoSize).AppendLine(",");
			stringBuilder.Append("            projectilesPerOnFire = ").Append(generatedWeaponSpec.ProjectilesPerFire).AppendLine(",");
			stringBuilder.Append("            sourceProjectile = \"").Append(EscapeLua(generatedWeaponSpec.SourceProjectile)).AppendLine("\",");
			stringBuilder.AppendLine("            racks = {");
			GeneratedRackSpec[] racks = generatedWeaponSpec.Racks;
			foreach (GeneratedRackSpec generatedRackSpec in racks)
			{
				stringBuilder.AppendLine("                {");
				stringBuilder.Append("                    rackBone = \"").Append(EscapeLua(generatedRackSpec.RackBone)).AppendLine("\",");
				AppendStringArray(stringBuilder, "muzzles", generatedRackSpec.Muzzles, 20);
				stringBuilder.AppendLine("                },");
			}
			stringBuilder.AppendLine("            },");
			stringBuilder.AppendLine("        },");
		}
		stringBuilder.AppendLine("    },");
		stringBuilder.AppendLine("}");
		if (port.SourceId == "UAA0310")
		{
			GeneratedWeaponSpec generatedWeaponSpec2 = port.Weapons.Single((GeneratedWeaponSpec weapon) => weapon.IsDeath && weapon.Label == "DeathImpact");
			stringBuilder.AppendLine("UnitTemplate.additions.czarCenterDownBeam = {");
			stringBuilder.Append("    enabled = ").Append(Lua(port.CzarBeam.Enabled)).AppendLine(",");
			stringBuilder.Append("    centerBone = \"").Append(EscapeLua(port.CzarBeam.CenterBone)).AppendLine("\",");
			stringBuilder.Append("    impactEffect = \"").Append(EscapeLua(port.CzarBeam.ImpactEffect)).AppendLine("\",");
			stringBuilder.Append("    beamMaterial = \"").Append(EscapeLua(port.CzarBeam.BeamMaterial)).AppendLine("\",");
			stringBuilder.Append("    visualCoreWidthScale = ").Append(Lua(1.0)).AppendLine(",");
			stringBuilder.Append("    visualDistortionWidthScale = ").Append(Lua(1.0)).AppendLine(",");
			stringBuilder.Append("    damage = ").Append(Lua(port.CzarBeam.Damage)).AppendLine(",");
			stringBuilder.Append("    damageInterval = ").Append(Lua(port.CzarBeam.DamageInterval)).AppendLine(",");
			stringBuilder.Append("    damageRadius = ").Append(Lua(port.CzarBeam.DamageRadius)).AppendLine(",");
			stringBuilder.Append("    rayLength = ").Append(Lua(port.CzarBeam.RayLength)).AppendLine(",");
			stringBuilder.Append("    acquisitionRange = ").Append(Lua(port.CzarBeam.AcquisitionRange)).AppendLine(",");
			stringBuilder.Append("    reloadTime = ").Append(Lua(port.CzarBeam.ReloadTime)).AppendLine(",");
			stringBuilder.AppendLine("    direction = {");
			stringBuilder.Append("        x = ").Append(Lua(port.CzarBeam.DirectionX)).AppendLine(",");
			stringBuilder.Append("        y = ").Append(Lua(port.CzarBeam.DirectionY)).AppendLine(",");
			stringBuilder.Append("        z = ").Append(Lua(port.CzarBeam.DirectionZ)).AppendLine(",");
			stringBuilder.AppendLine("    },");
			stringBuilder.AppendLine("}");
			stringBuilder.AppendLine("UnitTemplate.additions.scoFaCzarCrash = {");
			stringBuilder.AppendLine("    version = \"1.0.0\",");
			stringBuilder.AppendLine("    sourceUnitId = \"UAA0310\",");
			stringBuilder.AppendLine("    sourceScriptSha256 = \"af2458bd797acffbe8c28ca9d683a020d17aa9a7e0ed6df3780e58274e82e3f2\",");
			stringBuilder.AppendLine("    sourceDefaultAirUnitSha256 = \"fce73da5a37ca4b68ef9e4c317316189e9196d172f9f4d172df3cc825d079447\",");
			stringBuilder.AppendLine("    sourceDestroyNoFallRandomChance = 1.1,");
			stringBuilder.Append("    impactDamage = ").Append(Lua(generatedWeaponSpec2.Damage)).AppendLine(",");
			stringBuilder.Append("    impactRadius = ").Append(Lua(generatedWeaponSpec2.DamageRadius)).AppendLine(",");
			stringBuilder.AppendLine("    impactDamageFriendly = true,");
			stringBuilder.AppendLine("    perimeterDamage = 1000,");
			stringBuilder.AppendLine("    perimeterRadius = 5,");
			stringBuilder.AppendLine("    perimeterDamageFriendly = true,");
			AppendStringArray(stringBuilder, "sourceWatchedBones", new string[8] { "Left_Turret01_Muzzle", "Right_Turret01_Muzzle", "Left_Turret02_WepFocus", "Right_Turret02_WepFocus", "Left_Turret03_Muzzle", "Right_Turret03_Muzzle", "Attachpoint01", "Attachpoint02" }, 4);
			stringBuilder.AppendLine("    sourceWaterImpactAppliesDamage = true,");
			stringBuilder.AppendLine("    runtimeMode = \"HostWreckEdgeFirstFall\",");
			stringBuilder.AppendLine("    runtimeSideSelection = \"EntityIndexParity\",");
			stringBuilder.AppendLine("    runtimePerimeterContactMode = \"SingleLeadingEdgePulse\",");
			stringBuilder.AppendLine("    runtimeImpactDebounce = \"ExactlyOnce\",");
			stringBuilder.AppendLine("    runtimeTiltDegrees = 32,");
			stringBuilder.AppendLine("    runtimeTiltRateDegrees = 16,");
			stringBuilder.AppendLine("    runtimeLeadingEdgeOffset = 13.45,");
			stringBuilder.Append("    runtimeLevelClearance = ").Append(Lua(port.Movement.ConstructionSurfaceClearance)).AppendLine(",");
			stringBuilder.AppendLine("    runtimeFallAcceleration = 10,");
			stringBuilder.AppendLine("    runtimeMaximumFallSeconds = 30,");
			stringBuilder.AppendLine("}");
		}
		return stringBuilder.ToString();
	}

	private static string BuildRosterAppendix(string tableName)
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("do");
		stringBuilder.AppendLine("    -- Own exactly the 94 replaced Chosen slots.");
		stringBuilder.AppendLine("    -- The independently patched ucl0000 entry is untouched.");
		foreach (GeneratedPortSpec item in GeneratedAeonPortSpecs.All.OrderBy<GeneratedPortSpec, string>((GeneratedPortSpec port) => port.TargetId, StringComparer.Ordinal))
		{
			stringBuilder.Append("    ").Append(tableName).Append("[\"")
				.Append(EscapeLua(item.TargetId))
				.Append("\"] = ")
				.AppendLine(Lua(item.RosterVisible));
		}
		stringBuilder.Append("end");
		return stringBuilder.ToString();
	}

	private static string TransformUnitTemplateLoader(string source)
	{
		if (string.IsNullOrWhiteSpace(source))
		{
			throw new InvalidOperationException("The unit-template loader is empty and cannot be patched.");
		}
		return TransformCzarRenderDistance(TransformAeonConstructionBeamMaterial(source.Replace("\r\n", "\n").Replace('\r', '\n')));
	}

	private static string TransformCzarRenderDistance(string source)
	{
		int num = CountOccurrences(source, "-- SCO_CzarRenderDistance");
		if (num != 0)
		{
			if (num != 1 || CountOccurrences(source, "UnitRenderDistance * 5") != 1 || source.IndexOf("SCO_CzarRenderSource.targetId == \"uca4011\"", StringComparison.Ordinal) < 0 || source.IndexOf("SCO_CzarRenderSource.sourceId == \"UAA0310\"", StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("The existing Czar render-distance patch is malformed.");
			}
			return source;
		}
		if (CountOccurrences(source, "    local renderDistance = StructureRenderDistance\n    if tp.movement ~= nil then\n        renderDistance = UnitRenderDistance\n    end") != 1)
		{
			throw new InvalidOperationException("Expected exactly one stock unit render-distance block.");
		}
		string text = source.Replace("    local renderDistance = StructureRenderDistance\n    if tp.movement ~= nil then\n        renderDistance = UnitRenderDistance\n    end", "    local renderDistance = StructureRenderDistance\n    if tp.movement ~= nil then\n        renderDistance = UnitRenderDistance\n    end\n\n    -- SCO_CzarRenderDistance\n    -- Mobile units normally render to UnitRenderDistance (100 in this build).\n    -- Give only the imported UAA0310 Czar five times that native cutoff.\n    local SCO_CzarRenderSource =\n        tp.additions and tp.additions.faSourceContract\n    if tp.general.tpId == \"uca4011\"\n        and SCO_CzarRenderSource\n        and SCO_CzarRenderSource.targetId == \"uca4011\"\n        and SCO_CzarRenderSource.sourceId == \"UAA0310\"\n    then\n        renderDistance = UnitRenderDistance * 5\n    end");
		if (CountOccurrences(text, "-- SCO_CzarRenderDistance") != 1 || CountOccurrences(text, "UnitRenderDistance * 5") != 1 || text.IndexOf("EngineClasses.LODLevelTemplate(meshPath,\n                materialPath,\n                renderDistance,", StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("The Czar render-distance transform did not apply.");
		}
		return text;
	}

	private static string TransformAeonConstructionBeamMaterial(string source)
	{
		if (source.IndexOf("-- SCO_AeonConstructionBeamMaterial", StringComparison.Ordinal) >= 0)
		{
			int num = source.IndexOf("-- SCO_AeonConstructionBeamMaterial", StringComparison.Ordinal);
			if (source.IndexOf("-- SCO_AeonConstructionBeamMaterial", num + "-- SCO_AeonConstructionBeamMaterial".Length, StringComparison.Ordinal) >= 0 || source.IndexOf("VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial", StringComparison.Ordinal) < 0 || source.IndexOf("if (tp.additions and tp.additions.faSourceContract)", num, StringComparison.Ordinal) < 0 || source.IndexOf("tp.general.tpId == \"ucl0000\"", num, StringComparison.Ordinal) < 0 || source.IndexOf("tp.construction.beam.boneName == \"Left_Turret_Muzzle\"", num, StringComparison.Ordinal) < 0)
			{
				throw new InvalidOperationException("The existing Aeon construction-beam patch is malformed.");
			}
			return source;
		}
		int num2 = source.IndexOf("        local constructionBeamMaterialPath\n        if table.find(tp.tags, \"EDA\") then", StringComparison.Ordinal);
		if (num2 < 0 || source.IndexOf("        local constructionBeamMaterialPath\n        if table.find(tp.tags, \"EDA\") then", num2 + "        local constructionBeamMaterialPath\n        if table.find(tp.tags, \"EDA\") then".Length, StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("Expected exactly one construction-beam material branch.");
		}
		return source.Remove(num2, "        local constructionBeamMaterialPath\n        if table.find(tp.tags, \"EDA\") then".Length).Insert(num2, "        local constructionBeamMaterialPath\n        -- SCO_AeonConstructionBeamMaterial\n        if (tp.additions and tp.additions.faSourceContract)\n            or (\n                tp.general.tpId == \"ucl0000\"\n                and tp.construction.beam.boneName == \"Left_Turret_Muzzle\"\n            )\n        then\n            constructionBeamMaterialPath = \"VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial\"\n        elseif table.find(tp.tags, \"EDA\") then");
	}

	private static string DeferCzarImpactPrefabLoad(string source)
	{
		string text = EscapeLua(GeneratedAeonPortSpecs.All.Single((GeneratedPortSpec port) => port.SourceId == "UAA0310").CzarBeam.ImpactEffect);
		string text2 = "local scoCzarImpactPrefab =\n    scoCzarVFXTemplateLoader.GetOrCreateVFXPrefab(\n        \"" + text + "\")";
		if (CountOccurrences(source, "local function scoCzarGetImpactPrefab()") == 1)
		{
			if (CountOccurrences(source, text2) != 0 || CountOccurrences(source, "Engine.InstantiatePrefab(\n        impactPrefab,") != 1)
			{
				throw new InvalidOperationException("The existing lazy Czar impact-prefab route is malformed.");
			}
			return source;
		}
		if (CountOccurrences(source, "local function scoCzarGetImpactPrefab()") != 0)
		{
			throw new InvalidOperationException("The Czar impact-prefab lazy marker is duplicated.");
		}
		string after = "local scoCzarImpactEffectPath =\n    \"" + text + "\"\nlocal scoCzarImpactPrefab = nil\n\nlocal function scoCzarGetImpactPrefab()\n    if scoCzarImpactPrefab == nil then\n        Engine.LoadEffect(scoCzarImpactEffectPath)\n        scoCzarImpactPrefab =\n            scoCzarVFXTemplateLoader.GetOrCreateVFXPrefab(\n                scoCzarImpactEffectPath)\n    end\n    return scoCzarImpactPrefab\nend";
		source = ReplaceUnique(source, text2, after, "eager Czar impact-prefab registration");
		source = ReplaceUnique(source, "function AeonPortCzar:ScoCzarStartImpactEffect()\n    local impact = scoCzarTerrainImpact(", "function AeonPortCzar:ScoCzarStartImpactEffect()\n    local impactPrefab = scoCzarGetImpactPrefab()\n    if impactPrefab == nil then\n        error(\"Czar center-down impact graph failed to load.\")\n    end\n    local impact = scoCzarTerrainImpact(", "Czar impact-effect startup boundary");
		source = ReplaceUnique(source, "    local _, impactEffect = Engine.InstantiatePrefab(\n        scoCzarImpactPrefab,", "    local _, impactEffect = Engine.InstantiatePrefab(\n        impactPrefab,", "Czar impact-prefab instantiation");
		if (CountOccurrences(source, "local function scoCzarGetImpactPrefab()") != 1 || CountOccurrences(source, text2) != 0 || CountOccurrences(source, "Engine.LoadEffect(scoCzarImpactEffectPath)") != 1 || CountOccurrences(source, "Engine.InstantiatePrefab(\n        impactPrefab,") != 1)
		{
			throw new InvalidOperationException("The Czar impact prefab was not deferred exactly once.");
		}
		return source;
	}

	private static string ReplaceUnique(string source, string before, string after, string label)
	{
		int num = CountOccurrences(source, before);
		if (num != 1)
		{
			throw new InvalidOperationException("Expected exactly one " + label + ", found " + num + ".");
		}
		return source.Replace(before, after);
	}

	private static string BuildHostWeaponAppendixSourceBaseline()
	{
		return "-- SCO_GalacticColossusTractor\n-- FA's ADFTractorClaw accepts ordinary mobile units, excludes\n-- structures/commanders/experimentals/naval/SACUs, lets only one\n-- claw claim a target, makes the victim untargetable, and pulls its\n-- root into MuzzleSpecial at 15 world units per second before the\n-- crush. Sanctuary has no attachment slider, so the host simulation\n-- performs the equivalent deterministic position integration.\nlocal scoTractorHostOrderManager =\n    Import(\"host/managers/orders/hostOrderManager.lua\")\nlocal scoTractorUnits = __Entities.Units\nlocal scoTractorClaims =\n    _G.SCO_GalacticColossusTractorClaims or {}\n_G.SCO_GalacticColossusTractorClaims = scoTractorClaims\n\nlocal scoTractorStockCanShootAt = HostWeapon.CanShootAt\nlocal scoTractorStockDelete = HostWeapon.Delete\nlocal scoTractorStockSetAimTarget = HostWeapon.SetAimTarget\nlocal scoTractorStockUpdate = HostWeapon.Update\n\nlocal function scoTractorIsCurrent(unit)\n    local id = unit and unit.id\n    return unit ~= nil\n        and not unit.dead\n        and not unit.deleted\n        and id ~= nil\n        and scoTractorUnits[id.index] == unit\nend\n\nlocal function scoWeaponPassesWaterGate(weapon, target)\n    local tp = weapon.tp\n    if tp == nil\n        or (\n            tp.scoAboveWaterFireOnly ~= true\n            and tp.scoAboveWaterTargetsOnly ~= true)\n    then\n        return true\n    end\n\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then\n        return false\n    end\n    if not hasWater then\n        return true\n    end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success\n        or waterLevel == nil\n    then\n        return false\n    end\n    if tp.scoAboveWaterFireOnly == true then\n        local ownerPosition = weapon.unit:GetPosition()\n        if ownerPosition == nil or ownerPosition.y < waterLevel then\n            return false\n        end\n    end\n    if tp.scoAboveWaterTargetsOnly == true then\n        local targetPosition = target and target:GetPosition()\n        if targetPosition == nil or targetPosition.y < waterLevel then\n            return false\n        end\n    end\n    return true\nend\n\nlocal function scoNormalizeHeadingDegrees(value)\n    return (value + 180) % 360 - 180\nend\n\nlocal function scoWeaponPassesHeadingArc(weapon, target)\n    local config = weapon.tp and weapon.tp.scoTractor\n    if config == nil\n        or config.headingArcCenter == nil\n        or config.headingArcRange == nil\n    then\n        return true\n    end\n\n    local ownerPosition = weapon.unit:GetPosition()\n    local targetPosition = target and target:GetPosition()\n    if ownerPosition == nil or targetPosition == nil then\n        return false\n    end\n    local deltaX = targetPosition.x - ownerPosition.x\n    local deltaZ = targetPosition.z - ownerPosition.z\n    if deltaX == 0 and deltaZ == 0 then\n        return true\n    end\n\n    local yawResult, ownerYaw =\n        Engine.GetMovementChassisYawDegrees(weapon.unit.id)\n    if yawResult ~= EngineErrorCode.Success\n        or ownerYaw == nil\n    then\n        return false\n    end\n    local targetHeading = math.deg(math.atan2(deltaX, deltaZ))\n    local relativeHeading = scoNormalizeHeadingDegrees(\n        targetHeading - ownerYaw - config.headingArcCenter)\n    return math.abs(relativeHeading) <= config.headingArcRange\nend\n\nlocal function scoTractorTargetKey(target)\n    local id = target and target.id\n    if id == nil then\n        return nil\n    end\n    return tostring(id.index) .. \":\" .. tostring(id.version)\nend\n\nlocal function scoTractorHasSourceCategory(target, category)\n    local additions = target.tp and target.tp.additions\n    local contract = additions and additions.faSourceContract\n    local categories = contract and contract.sourceCategories\n    for _, sourceCategory in ipairs(categories or {}) do\n        if sourceCategory == category then\n            return true\n        end\n    end\n    return false\nend\n\nlocal function scoTractorIsEligible(weapon, target)\n    if not scoTractorIsCurrent(target)\n        or target.isTargetable ~= true\n        or not weapon.unit.army:IsEnemy(target.army)\n    then\n        return false\n    end\n\n    local tags = target.tp and target.tp.hasTags\n    if tags == nil\n        or not tags.MOBILE\n        or tags.STRUCTURE\n        or tags.COMMAND\n        or tags.TECH4\n        or tags.NAVAL\n        or tags.SUBCOMMANDER\n    then\n        return false\n    end\n\n    for _, excluded in ipairs({\n        \"STRUCTURE\",\n        \"COMMAND\",\n        \"EXPERIMENTAL\",\n        \"NAVAL\",\n        \"SUBCOMMANDER\",\n    }) do\n        if scoTractorHasSourceCategory(target, excluded) then\n            return false\n        end\n    end\n    return true\nend\n\nlocal function scoTractorIsAlreadyUsed(weapon, target)\n    -- FA's ADFTractorClaw checks every other weapon on this\n    -- Colossus, not only the opposite claw.  This keeps an eye-beam\n    -- target out of both capture streams and prevents both claws\n    -- from starting a visible beam on the same victim.\n    for _, otherWeapon in ipairs(weapon.unit.weapons or {}) do\n        if otherWeapon ~= weapon\n            and otherWeapon.targetUnit == target\n        then\n            return true\n        end\n    end\n\n    local key = scoTractorTargetKey(target)\n    local claim = key and scoTractorClaims[key]\n    return claim ~= nil and claim.weapon ~= weapon\nend\n\nlocal function scoTractorRelease(weapon, restoreTarget)\n    local target = weapon.scoTractorTarget\n    local key = weapon.scoTractorTargetKey\n    local claim = key and scoTractorClaims[key]\n    if claim and claim.weapon == weapon then\n        scoTractorClaims[key] = nil\n    end\n\n    weapon.scoTractorTarget = nil\n    weapon.scoTractorTargetKey = nil\n    weapon.scoTractorCaptureBone = nil\n    weapon.scoTractorReleasing = true\n    scoTractorStockSetAimTarget(weapon, nil)\n    weapon.scoTractorReleasing = nil\n\n    if restoreTarget and scoTractorIsCurrent(target) then\n        Engine.SetMovementEnabled(target.id, true)\n        -- SetTargetable also disables/enables the unit collider.\n        -- FA's SetDoNotTarget changes acquisition only, so keep\n        -- the victim's beam/physics collider alive throughout.\n        target.isTargetable = true\n    end\nend\n\nlocal function scoTractorTryClaim(weapon)\n    local config = weapon.tp and weapon.tp.scoTractor\n    local target = weapon.targetUnit\n    if config == nil\n        or weapon.scoTractorTarget ~= nil\n        or weapon.currentState\n            ~= WeaponState.WaitingPersistentBeamLifetime\n        or weapon.beamPendingEnable\n        or not scoTractorIsEligible(weapon, target)\n        or scoTractorIsAlreadyUsed(weapon, target)\n    then\n        return\n    end\n\n    local key = scoTractorTargetKey(target)\n    local captureBone = weapon.unit:GetBoneId(config.captureBone)\n    if key == nil\n        or captureBone == nil\n        or scoTractorClaims[key] ~= nil\n    then\n        return\n    end\n\n    scoTractorClaims[key] = {\n        weapon = weapon,\n        target = target,\n    }\n    weapon.scoTractorTarget = target\n    weapon.scoTractorTargetKey = key\n    weapon.scoTractorCaptureBone = captureBone\n    scoTractorHostOrderManager.HostClearOrder({ target })\n    Engine.SetMovementEnabled(target.id, false)\n    target.isTargetable = false\nend\n\nlocal function scoTractorCrush(weapon, target, capturePosition)\n    if not scoTractorIsCurrent(target) then\n        return\n    end\n    if capturePosition ~= nil then\n        Commands.SendHostClientExecuteFunctionCommand(\n            \"SCOGalacticColossusTractorCrush\",\n            {\n                position = {\n                    x = capturePosition.x,\n                    y = capturePosition.y,\n                    z = capturePosition.z,\n                },\n            })\n    end\n    if target.SCOOnKilledUnit then\n        -- The optional SCOM veterancy layer adds a third\n        -- instigator argument while preserving DestroyType.\n        -- Preserve FA kill attribution when composed.\n        target:Destroy(1, DestroyType.Kinetic, weapon.unit)\n    else\n        target:Destroy(1, DestroyType.Kinetic)\n    end\nend\n\nlocal function scoTractorPull(weapon)\n    local target = weapon.scoTractorTarget\n    local config = weapon.tp and weapon.tp.scoTractor\n    if not scoTractorIsCurrent(weapon.unit)\n        or not scoTractorIsCurrent(target)\n        or config == nil\n        or weapon.scoTractorCaptureBone == nil\n    then\n        scoTractorRelease(weapon, true)\n        return\n    end\n\n    local result, capturePosition = Engine.GetGlobalEntityWorldPosition(\n        weapon.scoTractorCaptureBone)\n    if result ~= EngineErrorCode.Success\n        or capturePosition == nil\n    then\n        scoTractorRelease(weapon, true)\n        return\n    end\n    local targetPosition = target:GetPosition()\n    local deltaX = capturePosition.x - targetPosition.x\n    local deltaY = capturePosition.y - targetPosition.y\n    local deltaZ = capturePosition.z - targetPosition.z\n    local distance = math.sqrt(\n        deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)\n    local step = config.pullSpeed * Constants.TickTimeStep\n    if step <= 0 then\n        scoTractorRelease(weapon, true)\n        return\n    end\n\n    if distance <= step then\n        target:SetPosition(EngineClasses.float3(\n            capturePosition.x,\n            capturePosition.y,\n            capturePosition.z))\n        scoTractorRelease(weapon, false)\n        scoTractorCrush(weapon, target, capturePosition)\n        return\n    end\n\n    local ratio = step / distance\n    target:SetPosition(EngineClasses.float3(\n        targetPosition.x + deltaX * ratio,\n        targetPosition.y + deltaY * ratio,\n        targetPosition.z + deltaZ * ratio))\nend\n\nfunction HostWeapon:CanShootAt(target)\n    if not scoWeaponPassesWaterGate(self, target) then\n        return false\n    end\n    if self.tp and self.tp.scoTractor then\n        if self.scoTractorTarget == target\n            and scoTractorIsCurrent(target)\n        then\n            return true\n        end\n        return scoTractorStockCanShootAt(self, target)\n            and scoWeaponPassesHeadingArc(self, target)\n            and scoTractorIsEligible(self, target)\n            and not scoTractorIsAlreadyUsed(self, target)\n    end\n    return scoTractorStockCanShootAt(self, target)\nend\n\nfunction HostWeapon:SetAimTarget(target)\n    if self.scoTractorTarget ~= nil\n        and target ~= self.scoTractorTarget\n        and not self.scoTractorReleasing\n    then\n        return\n    end\n    return scoTractorStockSetAimTarget(self, target)\nend\n\nfunction HostWeapon:Update()\n    scoTractorStockUpdate(self)\n    if self.tp and self.tp.scoTractor then\n        if self.scoTractorTarget == nil then\n            scoTractorTryClaim(self)\n        end\n        if self.scoTractorTarget ~= nil then\n            scoTractorPull(self)\n        end\n    end\nend\n\nfunction HostWeapon:Delete()\n    local target = self.scoTractorTarget\n    if target ~= nil then\n        -- FA adds captured victims to the Colossus TrashBag. If\n        -- the weapon/unit dies mid-pull, the victim is destroyed\n        -- with its owner rather than restored as a free unit.\n        scoTractorRelease(self, false)\n        if scoTractorIsCurrent(target) then\n            -- FA's TrashBag destroys the victim without a kill\n            -- instigator when the Colossus itself is deleted.\n            target:Destroy(1, DestroyType.Kinetic)\n        end\n    end\n    return scoTractorStockDelete(self)\nend";
	}

	private static string BuildHostWeaponAppendixForSanctuary()
	{
		return ReplaceUnique(ReplaceUnique(ReplaceUnique(ReplaceUnique(ReplaceUnique(ReplaceUnique(ReplaceUnique(ReplaceUnique(ReplaceUnique(BuildHostWeaponAppendixSourceBaseline(), "root into MuzzleSpecial at 15 world units per second before the\n-- crush.", "root into MuzzleSpecial at 15 world units per second before the\n-- crush.", "Galactic Colossus tractor lifecycle description"), NormalizeNewlines("local function scoTractorIsEligible(weapon, target)\n    if not scoTractorIsCurrent(target)\n        or target.isTargetable ~= true\n        or not weapon.unit.army:IsEnemy(target.army)\n    then\n        return false\n    end\n\n    local tags = target.tp and target.tp.hasTags\n    if tags == nil\n        or not tags.MOBILE\n        or tags.STRUCTURE\n        or tags.COMMAND\n        or tags.TECH4\n        or tags.NAVAL\n        or tags.SUBCOMMANDER\n    then\n        return false\n    end\n\n    for _, excluded in ipairs({\n        \"STRUCTURE\",\n        \"COMMAND\",\n        \"EXPERIMENTAL\",\n        \"NAVAL\",\n        \"SUBCOMMANDER\",\n    }) do\n        if scoTractorHasSourceCategory(target, excluded) then\n            return false\n        end\n    end\n    return true\nend"), NormalizeNewlines("local function scoTractorIsEligible(weapon, target)\n    if not scoTractorIsCurrent(target)\n        or target.isTargetable ~= true\n        or target.canTakeDamage == false\n        or target.canBeKilled == false\n        or not weapon.unit.army:IsEnemy(target.army)\n    then\n        return false\n    end\n\n    local tags = target.tp and target.tp.hasTags\n    if tags ~= nil\n        and (tags.STRUCTURE\n            or tags.COMMAND\n            or tags.TECH4\n            or tags.EXPERIMENTAL\n            or tags.NAVAL\n            or tags.SUBCOMMANDER)\n    then\n        return false\n    end\n\n    for _, excluded in ipairs({\n        \"STRUCTURE\",\n        \"COMMAND\",\n        \"EXPERIMENTAL\",\n        \"NAVAL\",\n        \"SUBCOMMANDER\",\n    }) do\n        if scoTractorHasSourceCategory(target, excluded) then\n            return false\n        end\n    end\n    return true\nend"), "Galactic Colossus FA category eligibility"), NormalizeNewlines("local function scoTractorIsAlreadyUsed(weapon, target)\n    -- FA's ADFTractorClaw checks every other weapon on this\n    -- Colossus, not only the opposite claw.  This keeps an eye-beam\n    -- target out of both capture streams and prevents both claws\n    -- from starting a visible beam on the same victim.\n    for _, otherWeapon in ipairs(weapon.unit.weapons or {}) do\n        if otherWeapon ~= weapon\n            and otherWeapon.targetUnit == target\n        then\n            return true\n        end\n    end\n\n    local key = scoTractorTargetKey(target)\n    local claim = key and scoTractorClaims[key]\n    return claim ~= nil and claim.weapon ~= weapon\nend"), NormalizeNewlines("local function scoTractorIsAlreadyUsed(weapon, target)\n    -- Target selection may assign the same candidate to both claws in\n    -- one simulation tick. Only an established claim is exclusive;\n    -- treating the other claw's provisional aim target as ownership\n    -- makes both claws reject the victim and deadlock forever.\n    -- The eye's current target is already exposed to its lethal beam.\n    -- Provisional aim from the other claw is not a claim.\n    local weapons = weapon.unit.weapons\n    local eyeWeapon = weapons and weapons[1]\n    if eyeWeapon ~= weapon\n        and eyeWeapon\n        and eyeWeapon.tp\n        and eyeWeapon.tp.scoSourceLabel == \"EyeWeapon\"\n        and eyeWeapon.targetUnit == target\n    then\n        return true\n    end\n\n    local key = scoTractorTargetKey(target)\n    local claim = key and scoTractorClaims[key]\n    return claim ~= nil and claim.weapon ~= weapon\nend"), "Galactic Colossus atomic target arbitration"), "    weapon.scoTractorCaptureBone = nil\n    weapon.scoTractorReleasing = true", "    weapon.scoTractorCaptureBone = nil\n    weapon.scoTractorReleasing = true", "Galactic Colossus contact-state cleanup"), NormalizeNewlines("local function scoTractorCrush(weapon, target, capturePosition)\n    if not scoTractorIsCurrent(target) then\n        return\n    end\n    if capturePosition ~= nil then\n        Commands.SendHostClientExecuteFunctionCommand(\n            \"SCOGalacticColossusTractorCrush\",\n            {\n                position = {\n                    x = capturePosition.x,\n                    y = capturePosition.y,\n                    z = capturePosition.z,\n                },\n            })\n    end\n    if target.SCOOnKilledUnit then\n        -- The optional SCOM veterancy layer adds a third\n        -- instigator argument while preserving DestroyType.\n        -- Preserve FA kill attribution when composed.\n        target:Destroy(1, DestroyType.Kinetic, weapon.unit)\n    else\n        target:Destroy(1, DestroyType.Kinetic)\n    end\nend"), NormalizeNewlines("local function scoTractorCrush(weapon, target, capturePosition)\n    if not scoTractorIsCurrent(target) then\n        return\n    end\n    if capturePosition ~= nil then\n        Commands.SendHostClientExecuteFunctionCommand(\n            \"SCOGalacticColossusTractorCrush\",\n            {\n                position = {\n                    x = capturePosition.x,\n                    y = capturePosition.y,\n                    z = capturePosition.z,\n                },\n            })\n    end\n    if target.SCOOnKilledUnit then\n        -- The optional SCOM veterancy layer adds a third\n        -- instigator argument while preserving DestroyType.\n        -- Preserve FA kill attribution when composed.\n        target:Destroy(1, DestroyType.Kinetic, weapon.unit)\n    else\n        target:Destroy(1, DestroyType.Kinetic)\n    end\nend"), "Galactic Colossus sustained crush entry"), "    local result, capturePosition = Engine.GetGlobalEntityWorldPosition(\n        weapon.scoTractorCaptureBone)\n    if result ~= EngineErrorCode.Success\n        or capturePosition == nil\n    then", "    if type(Engine.IsValidGlobalID) == \"function\"\n        and not Engine.IsValidGlobalID(weapon.scoTractorCaptureBone)\n    then\n        scoTractorRelease(weapon, true)\n        return\n    end\n    local result, capturePosition = Engine.GetGlobalEntityWorldPosition(\n        weapon.scoTractorCaptureBone)\n    if result ~= EngineErrorCode.Success\n        or capturePosition == nil\n    then", "Galactic Colossus capture-bone validity guard"), "    local targetPosition = target:GetPosition()\n    local deltaX = capturePosition.x - targetPosition.x", "    local targetPosition = target:GetPosition()\n    if targetPosition == nil then\n        scoTractorRelease(weapon, true)\n        return\n    end\n    local deltaX = capturePosition.x - targetPosition.x", "Galactic Colossus target-position validity guard"), NormalizeNewlines("    if distance <= step then\n        target:SetPosition(EngineClasses.float3(\n            capturePosition.x,\n            capturePosition.y,\n            capturePosition.z))\n        scoTractorRelease(weapon, false)\n        scoTractorCrush(weapon, target, capturePosition)\n        return\n    end"), NormalizeNewlines("    if distance <= step then\n        target:SetPosition(EngineClasses.float3(\n            capturePosition.x,\n            capturePosition.y,\n            capturePosition.z))\n        scoTractorRelease(weapon, false)\n        scoTractorCrush(weapon, target, capturePosition)\n        return\n    end"), "Galactic Colossus sustained contact damage"), NormalizeNewlines("function HostWeapon:Delete()\n    local target = self.scoTractorTarget\n    if target ~= nil then\n        -- FA adds captured victims to the Colossus TrashBag. If\n        -- the weapon/unit dies mid-pull, the victim is destroyed\n        -- with its owner rather than restored as a free unit.\n        scoTractorRelease(self, false)\n        if scoTractorIsCurrent(target) then\n            -- FA's TrashBag destroys the victim without a kill\n            -- instigator when the Colossus itself is deleted.\n            target:Destroy(1, DestroyType.Kinetic)\n        end\n    end\n    return scoTractorStockDelete(self)\nend"), NormalizeNewlines("function HostWeapon:Delete()\n    if self.scoTractorTarget ~= nil then\n        -- A destroyed or removed Colossus no longer owns the victim.\n        -- Release a living unit instead of killing it out of band.\n        scoTractorRelease(self, true)\n    end\n    return scoTractorStockDelete(self)\nend"), "Galactic Colossus interrupted-capture release");
	}

	private static string BuildClientContinuousBeamAppendix()
	{
		return "-- SCO_GalacticColossusTractorClientBeam\r\n-- The stock continuous-beam lifecycle remains authoritative for\r\n-- shaft enable/fade/raycast. This extension is gated only by the\r\n-- ucl4004 scoTractor template contract and owns FA's persistent\r\n-- start/end glows plus its finite vacuum-grab emitter.\r\nlocal scoTractorHierarchyTemplateLoader =\r\n    Import(\"common/loading/hierarchyTemplateLoader.lua\")\r\nlocal scoTractorEffectPrefabs =\r\n    _G.SCO_GalacticColossusEffectPrefabs or {}\r\n_G.SCO_GalacticColossusEffectPrefabs = scoTractorEffectPrefabs\r\nlocal scoTractorUnitScale = EngineClasses.float3(1, 1, 1)\r\nlocal scoTractorStartEffect =\r\n    \"VFX/AeonProjectiles/GalacticColossus/galactic_colossus_tractor_start_glow.sanvfx\"\r\nlocal scoTractorEndEffect =\r\n    \"VFX/AeonProjectiles/GalacticColossus/galactic_colossus_tractor_end_glow.sanvfx\"\r\nlocal scoTractorVacuumEffect =\r\n    \"VFX/AeonProjectiles/GalacticColossus/galactic_colossus_tractor_vacuum_grab.sanvfx\"\r\nlocal scoTractorPrefabNames = {\r\n    [scoTractorStartEffect] = \"SCO.GC.TractorStart\",\r\n    [scoTractorEndEffect] = \"SCO.GC.TractorEnd\",\r\n    [scoTractorVacuumEffect] = \"SCO.GC.TractorVacuum\",\r\n}\r\n\r\nlocal scoTractorStockSetBeamEnabled = ClientBeam.SetBeamEnabled\r\nlocal scoTractorStockRenderUpdate = ClientBeam.RenderUpdate\r\nlocal scoTractorStockRenderImpactEffect = ClientBeam.RenderImpactEffect\r\nlocal scoTractorStockCleanupImpactEffect = ClientBeam.CleanupImpactEffect\r\nlocal scoTractorStockOnFirstImpactEffect =\r\n    ClientContinuousBeam.OnFirstImpactEffect\r\n\r\nlocal function scoTractorIsBeam(beam)\r\n    local weapon = beam.muzzle and beam.muzzle.weapon\r\n    return weapon ~= nil\r\n        and weapon.tp ~= nil\r\n        and weapon.tp.scoTractor ~= nil\r\nend\r\n\r\nlocal function scoTractorGetPrefab(path)\r\n    local prefab = scoTractorEffectPrefabs[path]\r\n    if prefab == false then\r\n        return nil\r\n    end\r\n    if prefab ~= nil then\r\n        return prefab\r\n    end\r\n\r\n    local prefabName = scoTractorPrefabNames[path]\r\n    if prefabName == nil then\r\n        scoTractorEffectPrefabs[path] = false\r\n        return nil\r\n    end\r\n    local particleTemplates = {\r\n        EngineClasses.ParticleTemplate(\r\n            TemplateHeadEntityName,\r\n            path,\r\n            true,\r\n            true)\r\n    }\r\n    local prefabTemplate = EngineClasses.PrefabTemplate(\r\n        prefabName,\r\n        EngineClasses.HierarchyTemplate(\r\n            scoTractorHierarchyTemplateLoader.GetHierarchyEntities(nil)),\r\n        EngineClasses.GlobalTemplate(),\r\n        EngineClasses.LocalTemplate(\r\n            nil, nil, nil, nil, nil,\r\n            nil, nil, nil, nil, nil,\r\n            particleTemplates))\r\n    local result, createdPrefab = Engine.CreatePrefab(prefabTemplate)\r\n    if result ~= EngineErrorCode.Success\r\n        or createdPrefab == nil\r\n        or createdPrefab.Value == nil\r\n        or createdPrefab.Value == 65535\r\n    then\r\n        scoTractorEffectPrefabs[path] = false\r\n        return nil\r\n    end\r\n    scoTractorEffectPrefabs[path] = createdPrefab\r\n    return createdPrefab\r\nend\r\n\r\nlocal function scoTractorStopEffect(localId)\r\n    if localId ~= nil and Engine.IsValidLocalID(localId) then\r\n        Engine.SetParticleCanEmit(localId, false)\r\n        Engine.SetDestroyUponCompletion(localId, true)\r\n    end\r\nend\r\n\r\nlocal function scoTractorSpawnEffect(\r\n    path,\r\n    position,\r\n    orientation,\r\n    persistent)\r\n    local prefab = scoTractorGetPrefab(path)\r\n    if prefab == nil then\r\n        return nil\r\n    end\r\n    local result, localId = Engine.InstantiatePrefab(\r\n        prefab,\r\n        position,\r\n        scoTractorUnitScale,\r\n        orientation)\r\n    if result ~= EngineErrorCode.Success\r\n        or localId == nil\r\n        or not Engine.IsValidLocalID(localId)\r\n    then\r\n        scoTractorStopEffect(localId)\r\n        return nil\r\n    end\r\n    Engine.SetParticleCanEmit(localId, true)\r\n    Engine.SetDestroyUponCompletion(localId, not persistent)\r\n    return localId\r\nend\r\n\r\nfunction ClientContinuousBeam:CleanupImpactEffect()\r\n    if scoTractorIsBeam(self) then\r\n        scoTractorStopEffect(self.scoTractorStartEffectId)\r\n        scoTractorStopEffect(self.scoTractorVacuumEffectId)\r\n        self.scoTractorStartEffectId = nil\r\n        self.scoTractorVacuumEffectId = nil\r\n    end\r\n    return scoTractorStockCleanupImpactEffect(self)\r\nend\r\n\r\nfunction ClientContinuousBeam:SetBeamEnabled(enabled)\r\n    if not scoTractorIsBeam(self) then\r\n        return scoTractorStockSetBeamEnabled(self, enabled)\r\n    end\r\n    if enabled then\r\n        -- A re-enable can arrive before the previous afterlife\r\n        -- finishes. Stop every owned emitter before replacing it.\r\n        self:CleanupImpactEffect()\r\n    end\r\n    scoTractorStockSetBeamEnabled(self, enabled)\r\n    if not enabled then\r\n        return\r\n    end\r\n    self.scoTractorStartEffectId = scoTractorSpawnEffect(\r\n        scoTractorStartEffect,\r\n        self.muzzle:GetPosition(),\r\n        self.muzzle:GetOrientation(),\r\n        true)\r\nend\r\n\r\nfunction ClientContinuousBeam:OnFirstImpactEffect(\r\n    impactPosition,\r\n    orientation)\r\n    if not scoTractorIsBeam(self) then\r\n        return scoTractorStockOnFirstImpactEffect(\r\n            self,\r\n            impactPosition,\r\n            orientation)\r\n    end\r\n    self.impactEffectId = scoTractorSpawnEffect(\r\n        scoTractorEndEffect,\r\n        impactPosition,\r\n        orientation,\r\n        true)\r\n    self.scoTractorVacuumEffectId = scoTractorSpawnEffect(\r\n        scoTractorVacuumEffect,\r\n        impactPosition,\r\n        orientation,\r\n        false)\r\nend\r\n\r\nfunction ClientContinuousBeam:RenderImpactEffect()\r\n    scoTractorStockRenderImpactEffect(self)\r\n    if scoTractorIsBeam(self)\r\n        and self.scoTractorVacuumEffectId ~= nil\r\n        and Engine.IsValidLocalID(self.scoTractorVacuumEffectId)\r\n    then\r\n        local orientation = self:GetImpactOrientation(self.lastForward)\r\n        Engine.SetLocalEntityLocalPosition(\r\n            self.scoTractorVacuumEffectId,\r\n            self.impactPosition)\r\n        Engine.SetLocalEntityLocalRotation(\r\n            self.scoTractorVacuumEffectId,\r\n            orientation)\r\n    end\r\nend\r\n\r\nfunction ClientContinuousBeam:RenderUpdate()\r\n    if scoTractorIsBeam(self)\r\n        and self.scoTractorStartEffectId ~= nil\r\n        and Engine.IsValidLocalID(self.scoTractorStartEffectId)\r\n    then\r\n        Engine.SetLocalEntityLocalPosition(\r\n            self.scoTractorStartEffectId,\r\n            self.muzzle:GetPosition())\r\n        Engine.SetLocalEntityLocalRotation(\r\n            self.scoTractorStartEffectId,\r\n            self.muzzle:GetOrientation())\r\n    end\r\n    return scoTractorStockRenderUpdate(self)\r\nend\r\n\r\nreturn { ClientContinuousBeam = ClientContinuousBeam }";
	}

	private static string StripClientContinuousBeamModuleReturn(string source)
	{
		source = NormalizeNewlines(source);
		if (source.IndexOf("-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0", StringComparison.Ordinal) >= 0)
		{
			return source;
		}
		string text = source.TrimEnd(new char[1] { '\n' });
		if (CountOccurrences(text, "return { ClientContinuousBeam = ClientContinuousBeam }") != 1 || !text.EndsWith("return { ClientContinuousBeam = ClientContinuousBeam }", StringComparison.Ordinal))
		{
			throw new InvalidOperationException("The client continuous-beam module return contract changed.");
		}
		return text.Substring(0, text.Length - "return { ClientContinuousBeam = ClientContinuousBeam }".Length).TrimEnd(new char[1] { '\n' }) + "\n";
	}

	private static string BuildClientListenerAppendix()
	{
		return "-- SCO_GalacticColossusTractorCrushClient\r\n-- Host simulation sends only the authoritative capture position;\r\n-- this listener creates no gameplay state and owns one finite VFX.\r\nlocal scoTractorCrushHierarchyTemplateLoader =\r\n    Import(\"common/loading/hierarchyTemplateLoader.lua\")\r\nlocal scoTractorCrushEffectPrefabs =\r\n    _G.SCO_GalacticColossusEffectPrefabs or {}\r\n_G.SCO_GalacticColossusEffectPrefabs = scoTractorCrushEffectPrefabs\r\nlocal scoTractorCrushEffect =\r\n    \"VFX/AeonProjectiles/GalacticColossus/galactic_colossus_tractor_crush.sanvfx\"\r\nlocal scoTractorCrushPrefabName = \"SCO.GC.TractorCrush\"\r\nlocal scoTractorCrushScale = EngineClasses.float3(1, 1, 1)\r\nlocal scoTractorCrushOrientation = EngineClasses.quaternion()\r\n\r\nlocal function scoTractorCrushGetPrefab()\r\n    local prefab = scoTractorCrushEffectPrefabs[scoTractorCrushEffect]\r\n    if prefab == false then\r\n        return nil\r\n    end\r\n    if prefab ~= nil then\r\n        return prefab\r\n    end\r\n\r\n    local particleTemplates = {\r\n        EngineClasses.ParticleTemplate(\r\n            TemplateHeadEntityName,\r\n            scoTractorCrushEffect,\r\n            true,\r\n            true)\r\n    }\r\n    local prefabTemplate = EngineClasses.PrefabTemplate(\r\n        scoTractorCrushPrefabName,\r\n        EngineClasses.HierarchyTemplate(\r\n            scoTractorCrushHierarchyTemplateLoader.GetHierarchyEntities(nil)),\r\n        EngineClasses.GlobalTemplate(),\r\n        EngineClasses.LocalTemplate(\r\n            nil, nil, nil, nil, nil,\r\n            nil, nil, nil, nil, nil,\r\n            particleTemplates))\r\n    local result, createdPrefab = Engine.CreatePrefab(prefabTemplate)\r\n    if result ~= EngineErrorCode.Success\r\n        or createdPrefab == nil\r\n        or createdPrefab.Value == nil\r\n        or createdPrefab.Value == 65535\r\n    then\r\n        scoTractorCrushEffectPrefabs[scoTractorCrushEffect] = false\r\n        return nil\r\n    end\r\n    scoTractorCrushEffectPrefabs[scoTractorCrushEffect] = createdPrefab\r\n    return createdPrefab\r\nend\r\n\r\nlocal function scoTractorFiniteCoordinate(value)\r\n    return type(value) == \"number\"\r\n        and value == value\r\n        and math.abs(value) < 1000000\r\nend\r\n\r\nfunction functions.SCOGalacticColossusTractorCrush(data)\r\n    local position = data and data.position\r\n    if position == nil\r\n        or not scoTractorFiniteCoordinate(position.x)\r\n        or not scoTractorFiniteCoordinate(position.y)\r\n        or not scoTractorFiniteCoordinate(position.z)\r\n    then\r\n        return\r\n    end\r\n    local prefab = scoTractorCrushGetPrefab()\r\n    if prefab == nil then\r\n        return\r\n    end\r\n    local result, localId = Engine.InstantiatePrefab(\r\n        prefab,\r\n        EngineClasses.float3(position.x, position.y, position.z),\r\n        scoTractorCrushScale,\r\n        scoTractorCrushOrientation)\r\n    if result ~= EngineErrorCode.Success\r\n        or localId == nil\r\n        or not Engine.IsValidLocalID(localId)\r\n    then\r\n        return\r\n    end\r\n    Engine.SetParticleCanEmit(localId, true)\r\n    Engine.SetDestroyUponCompletion(localId, true)\r\nend\n\n-- SCO_CzarCrashScorchContact_v1: retain native decal appearance and lifetime.\nfunction functions.SCOCzarCrashImpactScorch(data)\n    if type(data) ~= \"table\" then\n        return\n    end\n    local position = data and data.position\n    if type(position) ~= \"table\"\n        or not scoTractorFiniteCoordinate(position.x)\n        or not scoTractorFiniteCoordinate(position.y)\n        or not scoTractorFiniteCoordinate(position.z)\n    then\n        return\n    end\n    local template = __Templates\n        and __Templates.Units\n        and __Templates.Units.uca4011\n    if template == nil then\n        return\n    end\n\n    local unitClass =\n        Import(\"client/units/unitsClasses/unitsBaseClass.lua\").ClientUnit\n    local impactPosition =\n        EngineClasses.float3(position.x, position.y, position.z)\n    local scorchSource = {\n        tp = template,\n        CreateDecal = unitClass.CreateDecal,\n        GetSimPosition = function()\n            return impactPosition\n        end,\n    }\n    -- The aircraft was already deleted. An independent finite thread\n    -- waits for its falling wreck to interpolate to the contact pose.\n    NewThread(function()\n        WaitTickEnd()\n        unitClass.CreateRandomScorchmark(scorchSource)\n    end)\nend\n\n-- SCOM initial commander arrival visuals 2.0.0.\n-- Append to client/clientListeners.lua. Begin precedes native CreateUnit commands.\n-- The host owns the cohort and every reveal/release decision; this is presentation only.\n-- SCO_CommanderArrivalVisuals_v1\nlocal arrivalVersion = \"2.0.0\"\nlocal installedArrival = rawget(_G, \"SCO_CommanderArrivalVisuals\")\nif installedArrival ~= nil then\n    assert(type(installedArrival) == \"table\" and installedArrival.version == arrivalVersion,\n        \"Unsupported SCOM commander arrival visuals\")\nelse\n    local supported = { uel0000 = true, ugl0000 = true, ucl0000 = true, usl0000 = true }\n    local arrivalFactions = { uel0000 = \"uef\", ugl0000 = \"cybran\", ucl0000 = \"aeon\", usl0000 = \"seraphim\" }\n    local api = { version = arrivalVersion }\n    local session, previousSequence, unitClass = nil, 0, nil\n    local nativeVision, nativeRadar\n    local effectPrefabs, effectLoaded = {}, {}\n    local groundScorches = {}\n    local cleanupQueue, pendingRecords = {}, {}\n    local requestPump, startPump, pumpRunning, pumpRequested, presentationBoundary = nil, nil, false, false, false\n\n    local function finite(value)\n        return type(value) == \"number\" and value == value\n            and value ~= math.huge and value ~= -math.huge\n    end\n\n    local function integer(value, minimum, maximum)\n        return finite(value) and value == math.floor(value)\n            and value >= minimum and value <= maximum\n    end\n\n    local function position(value)\n        if type(value) ~= \"table\" then return nil end\n        for _, name in ipairs({ \"x\", \"y\", \"z\" }) do\n            if not finite(value[name]) or math.abs(value[name]) > 1048576 then return nil end\n        end\n        return { x = value.x, y = value.y, z = value.z }\n    end\n\n    local function identity(value)\n        if type(value) ~= \"table\" or not integer(value.index, 0, 4294967295)\n            or not integer(value.version, 0, 4294967295)\n            or (value.index == 0 and value.version == 0) then return nil end\n        return { index = value.index, version = value.version }\n    end\n\n    local function sameIdentity(left, right)\n        return left ~= nil and right ~= nil\n            and left.index == right.index and left.version == right.version\n    end\n\n    local function validLocal(value)\n        return value ~= nil and Engine.IsValidLocalID(value)\n    end\n\n    local function tick()\n        local value = Engine.GetSimulationTick()\n        return integer(value, 0, 2147483647) and value or nil\n    end\n\n    local function activeRecord(unit)\n        local record = unit.scoCommanderArrivalRecord\n        if record and record.unit == unit and not record.cancelled and not record.deleted\n            and (unit.id == nil or sameIdentity(record.unitId, unit.id)) then return record end\n    end\n\n    local function hidden(unit)\n        local record = activeRecord(unit)\n        return record ~= nil and not record.revealed and not record.released\n    end\n\n    local function blocked(unit)\n        local record = activeRecord(unit)\n        return record ~= nil and not record.released\n    end\n\n    local function hideDisplay(unit)\n        if unit.isInitialized == false or not validLocal(unit.localId) then return end\n        Engine.SetRendererEnabled(unit.localId, false)\n        Engine.SetRangeRingsEnabled(unit.localId, false)\n        Engine.SetIconsEnabled(unit.localId, false)\n        unit:SetSelectionEnabled(false)\n        unit:SetProgressBarsEnabled(false)\n        unit:RecalculateConstructionBeamState()\n        unit:RecalculateBuildEffectsState()\n        unit:RecalculatePersistentEffectsState()\n        unit:RecalculateAudioSourcesState()\n        unit:RecalculateShieldEffectsState()\n    end\n\n    local function liveUnit(record)\n        local unit = record.unit\n        if unit == nil and record.unitId and __Entities and __Entities.Units then\n            unit = __Entities.Units[record.unitId.index]\n            if not sameIdentity(unit and unit.id, record.unitId) then unit = nil end\n        end\n        if unit == nil or unit.dead or unit.deleted or not validLocal(unit.localId)\n            or not sameIdentity(unit.id, record.unitId) then return nil end\n        return unit\n    end\n\n    local function grounded(record)\n        local point = position(record.position)\n        local code, height = Engine.SampleTerrainHeight(point)\n        if code == EngineErrorCode.Success and finite(height) then point.y = height end\n        return point\n    end\n\n    local function renderable(unit)\n        return unit.isInitialized ~= false and nativeVision(unit) == true\n    end\n\n    local function getEffectPrefab(path, name)\n        if effectPrefabs[path] ~= nil then return effectPrefabs[path] or nil end\n        if effectLoaded[path] == nil then\n            effectLoaded[path] = Engine.LoadEffect(path) == true\n            if not effectLoaded[path] then\n                Engine.Error(\"[SCOM Arrival] Arrival effect loading failed: \" .. path)\n            end\n        end\n        if not effectLoaded[path] then return nil end\n        local hierarchy = Import(\"common/loading/hierarchyTemplateLoader.lua\")\n        -- Match the native VFX loader, with a private name and explicit ownership.\n        -- This persistent root must remain alive until the presentation pump deletes it.\n        local particles = { EngineClasses.ParticleTemplate(TemplateHeadEntityName,\n            path, false, true) }\n        local template = EngineClasses.PrefabTemplate(name,\n            EngineClasses.HierarchyTemplate(hierarchy.GetHierarchyEntities(nil)),\n            EngineClasses.GlobalTemplate(),\n            EngineClasses.LocalTemplate(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, particles))\n        local code, prefab = Engine.CreatePrefab(template)\n        effectPrefabs[path] = false\n        if code == EngineErrorCode.Success and type(prefab) == \"table\"\n            and integer(prefab.Value, 0, 65534) then effectPrefabs[path] = prefab end\n        return effectPrefabs[path] or nil\n    end\n\n    local function stopPortal(record)\n        local instance = record.teleportId\n        record.teleportId = nil\n        if validLocal(instance) then Engine.DeletePrefabInstance(instance) end\n    end\n\n    local function stopImpact(record)\n        local instance = record.impactId\n        record.impactId = nil\n        if validLocal(instance) then Engine.DeletePrefabInstance(instance) end\n    end\n\n    local function effectFaction(record, unit)\n        local tpId = unit.tp and unit.tp.general and unit.tp.general.tpId\n        return tpId == record.tpId and arrivalFactions[tpId] or nil\n    end\n\n    local function arrivalPortal(record, unit)\n        if record.portalAttempted then return end\n        record.portalAttempted = true\n        local faction = effectFaction(record, unit)\n        if faction == nil then\n            Engine.Error(\"[SCOM Arrival] Teleport faction unavailable; arrival remains held.\")\n            return\n        end\n        local suffix = faction == \"uef\" and \"\" or \"_\" .. faction\n        local prefab = getEffectPrefab(\n            \"VFX/SCOM/Commanders/Arrival/commander_arrival_portal\" .. suffix .. \".sanvfx\",\n            \"SCOM_CommanderArrivalTeleport_v2_\" .. faction)\n        if prefab == nil then\n            Engine.Error(\"[SCOM Arrival] Teleport prefab creation failed; arrival remains held.\")\n            return\n        end\n        local code, instance = Engine.InstantiatePrefab(prefab, grounded(record),\n            EngineClasses.float3(1, 1, 1), GetIdentityQuaternion())\n        if code == EngineErrorCode.Success and identity(instance) then\n            record.teleportId = instance\n            Engine.Log(\"[SCOM Arrival] Teleport effect instantiated for army \" .. tostring(record.armyId))\n        else\n            Engine.Error(\"[SCOM Arrival] Teleport instance creation failed; arrival remains held.\")\n        end\n    end\n\n    local function arrivalImpact(record, unit)\n        if record.impactAttempted then return end\n        record.impactAttempted = true\n        if not renderable(unit) then return end\n        local faction = effectFaction(record, unit)\n        if faction == nil then\n            Engine.Error(\"[SCOM Arrival] Reveal impact faction unavailable.\")\n            return\n        end\n        local suffix = faction == \"uef\" and \"\" or \"_\" .. faction\n        local prefab = getEffectPrefab(\n            \"VFX/SCOM/Commanders/Arrival/commander_arrival_impact\" .. suffix .. \".sanvfx\",\n            \"SCOM_CommanderArrivalImpact_v1_\" .. faction)\n        if prefab == nil then\n            Engine.Error(\"[SCOM Arrival] Reveal impact prefab creation failed.\")\n            return\n        end\n        local code, instance = Engine.InstantiatePrefab(prefab, grounded(record),\n            EngineClasses.float3(1, 1, 1), GetIdentityQuaternion())\n        if code == EngineErrorCode.Success and identity(instance) then\n            record.impactId = instance\n        else\n            Engine.Error(\"[SCOM Arrival] Reveal impact instance creation failed.\")\n        end\n    end\n\n    local function arrivalScorch(record, unit)\n        record.scorchDone = true\n        if not renderable(unit) then return end\n        local point = grounded(record)\n        local waterCode, hasWater = Engine.HasWater()\n        if waterCode == EngineErrorCode.Success and hasWater then\n            local code, water = Engine.GetWaterLevel()\n            if code == EngineErrorCode.Success and finite(water) and point.y < water then return end\n        end\n        local size = unit.tp.collisionInfo and unit.tp.collisionInfo.collisionSize\n        local width = 1\n        if size and finite(size.x) and finite(size.z) then\n            width = math.max(1, size.x, size.z)\n        end\n        -- Index 4 is the stock radial scorch also used by native unit deaths.\n        -- The native projector has unit extents, so this is a 6*width footprint.\n        local prefab = type(ScorchmarkDecalPrefabIDs) == \"table\" and ScorchmarkDecalPrefabIDs[4]\n        if not prefab then\n            Engine.Error(\"[SCOM Arrival] Native radial scorch prefab unavailable.\")\n            return\n        end\n        local yaw = (record.armyId * 73) % 360 - 180\n        local rotation = Engine.EulerToQuaternion(EngineClasses.float3(math.pi / 2,\n            math.rad(yaw), 0), RotationOrder.Default)\n        local diameter = width * 6\n        -- CreateDecal discards the native result; validate the same stock prefab\n        -- route before giving its instance to the native Decal entity.\n        local code, instance = Engine.InstantiatePrefab(prefab, point,\n            EngineClasses.float3(diameter, diameter, diameter), rotation)\n        if code ~= EngineErrorCode.Success or not identity(instance) or not validLocal(instance) then\n            Engine.Error(\"[SCOM Arrival] Native radial scorch instance creation failed.\")\n            return\n        end\n        local componentCode, enabled = Engine.GetDecalEnabled(instance)\n        if componentCode ~= EngineErrorCode.Success or not enabled then\n            Engine.DeletePrefabInstance(instance)\n            Engine.Error(\"[SCOM Arrival] Native radial scorch component unavailable; discarded owned instance.\")\n            return\n        end\n        local decals = Import(\"client/entities/decal.lua\")\n        local clientEntity = Import(\"client/entities/entity.lua\").ClientEntity\n        local decal = decals.Decal(instance)\n        local nativeDelete, nativeSetOpacity = decal.Delete, decal.SetOpacity\n        -- These guards belong only to this mark. Native entity garbage still\n        -- owns its lifetime coroutine, including after an external ID deletion.\n        function decal:Delete()\n            if self.deleted then return end\n            if validLocal(self.localId) then nativeDelete(self)\n            else clientEntity.Delete(self) end\n        end\n        function decal:SetOpacity(opacity)\n            if self.deleted then return end\n            if not validLocal(self.localId) then self:Delete(); return end\n            nativeSetOpacity(self, opacity)\n        end\n        function decal:LifeTimeThread(seconds)\n            -- Native FadeOverTime(600) truncates its capped step delays to\n            -- 588.8s. A 595s hold plus its exact 50-tick fade lasts 600s.\n            WaitTicks((seconds - 5) * Constants.TickRate)\n            if self.deleted then return end\n            if not validLocal(self.localId) then self:Delete(); return end\n            self:FadeOverTime(5)\n            self:Delete()\n        end\n        decal:SetLifeTime(600)\n        groundScorches[#groundScorches + 1] = decal\n    end\n\n    local function restoreDisplay(record, unit)\n        if unit.isInitialized ~= false then unit:RecalculateIntel(true) end\n    end\n\n    local function finishPresentation(record, unit)\n        if not record.revealed then return end\n        if unit.isInitialized == false then return end\n        arrivalImpact(record, unit)\n        if not record.scorchDone then arrivalScorch(record, unit) end\n        if validLocal(record.teleportId) or validLocal(record.impactId) then\n            if not record.portalFading then\n                -- Stop new particles, then reveal the commander inside the finite\n                -- particles already rendered. Simulation catchup cannot end this fade.\n                if validLocal(record.teleportId) then\n                    Engine.SetParticleCanEmit(record.teleportId, false)\n                end\n                record.portalFading, record.renderedPortalFade = true, 0\n            end\n            if not record.portalFadeReady then return end\n        end\n        stopPortal(record)\n        -- The impact's one-shot world-space particles continue their finite\n        -- lifetimes after its emission root is disposed, including the steam.\n        stopImpact(record)\n    end\n\n    local function queueRecord(record)\n        pendingRecords[record] = true\n        requestPump()\n    end\n\n    local function queueCleanup(record, restore)\n        if not record.cleanupQueued then\n            record.cleanupQueued = { record = record }\n            cleanupQueue[#cleanupQueue + 1] = record.cleanupQueued\n        end\n        record.cleanupQueued.restore = record.cleanupQueued.restore or restore\n        pendingRecords[record] = nil\n        requestPump()\n    end\n\n    local function cancelUnit(unit)\n        local record = activeRecord(unit)\n        if record == nil then return end\n        record.deleted = true\n        unit.scoCommanderArrivalRecord = nil\n        queueCleanup(record, false)\n    end\n\n    local function claim(unit, globalId, armyId, template)\n        if session == nil or session.cancelled then return nil end\n        local tpId = template and template.general and template.general.tpId\n        for _, record in ipairs(session.records) do\n            if not record.deleted and record.armyId == armyId and record.tpId == tpId\n                and (sameIdentity(record.unitId, globalId)\n                    or (record.unitId == nil and record.unit == nil)) then\n                record.unitId = identity(globalId)\n                record.unit = unit\n                local now = tick()\n                if now and session.revealRequested and now >= session.revealTick then record.revealed = true end\n                if now and session.releaseRequested and now >= session.releaseTick then record.released = true end\n                unit.scoCommanderArrivalRecord = record\n                return record\n            end\n        end\n    end\n\n    local function installHooks()\n        if unitClass then return end\n        local previousFlush = _G.ThreadDispatcherFlush\n        assert(type(previousFlush) == \"function\", \"SCOM commander arrival needs native tick-end dispatch\")\n        function _G.ThreadDispatcherFlush(...)\n            if pumpRequested and not pumpRunning then\n                pumpRequested = false\n                startPump()\n            end\n            return previousFlush(...)\n        end\n        -- Begin runs after InitClient, when clientListeners has finished importing.\n        unitClass = Import(\"client/units/unitsClasses/unitsBaseClass.lua\").ClientUnit\n        assert(type(unitClass) == \"table\", \"SCOM commander arrival needs ClientUnit\")\n        nativeVision, nativeRadar = unitClass.IsIntelVisionVisible, unitClass.IsIntelRadarVisible\n        local function wrapConstructor(class)\n            local previous = class.__init\n            function class:__init(globalId, localId, armyId, template, fractionComplete)\n                local record = claim(self, globalId, armyId, template)\n                local result = previous(self, globalId, localId, armyId, template, fractionComplete)\n                if record then queueRecord(record) end\n                return result\n            end\n        end\n        -- Native Class copies __init without propagating later changes. The already-defined\n        -- Commander constructor explicitly calls this captured mobile constructor.\n        local mobileClass = Import(\"client/units/unitsClasses/unitsDefault.lua\").ClientMobileUnit\n        assert(type(mobileClass) == \"table\", \"SCOM commander arrival needs ClientMobileUnit\")\n        wrapConstructor(unitClass)\n        wrapConstructor(mobileClass)\n        function unitClass:IsIntelVisionVisible()\n            return not hidden(self) and nativeVision(self)\n        end\n        function unitClass:IsIntelRadarVisible()\n            return not hidden(self) and nativeRadar(self)\n        end\n        for _, name in ipairs({ \"IsSelectable\", \"IsHighlightable\" }) do\n            local previous = unitClass[name]\n            unitClass[name] = function(self, ...)\n                if blocked(self) then return false end\n                return previous(self, ...)\n            end\n        end\n        local previousSelection = unitClass.SetSelectionEnabled\n        function unitClass:SetSelectionEnabled(enabled)\n            if blocked(self) then\n                if presentationBoundary and self.isInitialized ~= false then\n                    return previousSelection(self, false)\n                end\n                local record = activeRecord(self)\n                if self.isInitialized ~= false then queueRecord(record) end\n                return\n            end\n            return previousSelection(self, enabled)\n        end\n        local previousIcons = unitClass.RecalculateUnitIconState\n        function unitClass:RecalculateUnitIconState(...)\n            if hidden(self) then\n                if presentationBoundary and self.isInitialized ~= false and validLocal(self.localId) then\n                    Engine.SetIconsEnabled(self.localId, false)\n                elseif self.isInitialized ~= false then queueRecord(activeRecord(self)) end\n                return\n            end\n            return previousIcons(self, ...)\n        end\n        local previousHidden = unitClass.OnIntelHidden\n        for _, name in ipairs({ \"OnIntelVision\", \"OnIntelRadar\", \"OnIntelHidden\" }) do\n            local previous = unitClass[name]\n            unitClass[name] = function(self, ...)\n                if hidden(self) then\n                    if presentationBoundary and self.isInitialized ~= false then\n                        previousHidden(self)\n                    elseif self.isInitialized ~= false then queueRecord(activeRecord(self)) end\n                    return\n                end\n                return previous(self, ...)\n            end\n        end\n        local previousDestroy, previousDelete = unitClass.OnDestroy, unitClass.OnDelete\n        local previousSimCreate = unitClass.SimCreateThread\n        function unitClass:SimCreateThread(...)\n            local result = previousSimCreate(self, ...)\n            local record = activeRecord(self)\n            if record then queueRecord(record) end\n            return result\n        end\n        function unitClass:OnDestroy(...)\n            cancelUnit(self)\n            return previousDestroy(self, ...)\n        end\n        function unitClass:OnDelete(...)\n            cancelUnit(self)\n            return previousDelete(self, ...)\n        end\n    end\n\n    local function phasePayload(value)\n        return type(value) == \"table\" and value.version == 2 and session ~= nil\n            and value.sequence == session.sequence and not session.cancelled\n    end\n\n    function api.Begin(value)\n        if type(value) ~= \"table\" or value.version ~= 2 or value.phase ~= \"pan\"\n            or not integer(value.sequence, 1, 2147483647) or value.sequence <= previousSequence\n            or not integer(value.startTick, 0, 2147483647)\n            or not integer(Constants.TickRate, 1, 1000)\n            or type(value.units) ~= \"table\" or #value.units < 1 or #value.units > 64 then return false end\n        local records, plans, planIds = {}, {}, {}\n        for key in pairs(value.units) do\n            if not integer(key, 1, #value.units) then return false end\n        end\n        for _, entry in ipairs(value.units) do\n            if type(entry) ~= \"table\" or not integer(entry.armyId, 0, 255)\n                or not supported[entry.tpId] then return false end\n            local point, unitId = position(entry.position), identity(entry.unitId)\n            local key = entry.armyId .. \":\" .. entry.tpId\n            if point == nil or plans[key] or (entry.unitId ~= nil and unitId == nil) then return false end\n            if unitId then\n                local idKey = unitId.index .. \":\" .. unitId.version\n                if planIds[idKey] then return false end\n                planIds[idKey] = true\n            end\n            plans[key] = true\n            records[#records + 1] = { armyId = entry.armyId, tpId = entry.tpId,\n                position = point, unitId = unitId }\n        end\n        if #records ~= #value.units then return false end\n        if session ~= nil then return false end\n        installHooks()\n        previousSequence = value.sequence\n        session = { sequence = value.sequence, startTick = value.startTick,\n            phase = \"pan\", records = records,\n            gameInfo = GameInfo, mapInfo = GameInfo and GameInfo.MapInfo }\n        for _, record in ipairs(records) do\n            local unit = liveUnit(record)\n            if unit then claim(unit, unit.id, unit.armyId, unit.tp) end\n        end\n        api.Update()\n        return true\n    end\n\n    function api.Bind(value)\n        if not phasePayload(value) or value.phase ~= \"teleport\"\n            or not integer(value.effectTick, session.startTick, 2147483647)\n            or type(value.units) ~= \"table\"\n            or #value.units ~= #session.records then return false end\n        for key in pairs(value.units) do\n            if not integer(key, 1, #value.units) then return false end\n        end\n        local pending, seen, seenIds = {}, {}, {}\n        for _, entry in ipairs(value.units) do\n            local unitId = type(entry) == \"table\" and identity(entry.unitId)\n            if not unitId or not integer(entry.armyId, 0, 255)\n                or not supported[entry.tpId] then return false end\n            local point = entry.position ~= nil and position(entry.position) or nil\n            if entry.position ~= nil and point == nil then return false end\n            local idKey = unitId.index .. \":\" .. unitId.version\n            if seenIds[idKey] then return false end\n            seenIds[idKey] = true\n            local selected\n            for _, record in ipairs(session.records) do\n                if record.armyId == entry.armyId and record.tpId == entry.tpId then selected = record; break end\n            end\n            if not selected or seen[selected] or (selected.unitId and not sameIdentity(selected.unitId, unitId)) then return false end\n            seen[selected] = true\n            pending[#pending + 1] = { record = selected, unitId = unitId, position = point }\n        end\n        if #pending ~= #session.records then return false end\n        for _, item in ipairs(pending) do\n            item.record.unitId = item.unitId\n            if item.position then item.record.position = item.position end\n            local unit = liveUnit(item.record)\n            if unit then\n                claim(unit, unit.id, unit.armyId, unit.tp)\n            end\n        end\n        session.phase, session.effectTick = \"teleport\", value.effectTick\n        session.lastEffectRender, session.renderedEffectTime = nil, 0\n        api.Update()\n        return true\n    end\n\n    function api.Reveal(value)\n        if not phasePayload(value) or value.phase ~= \"released\"\n            or not integer(value.releaseTick, session.effectTick or session.startTick, 2147483647) then return false end\n        session.revealTick, session.releaseTick = value.releaseTick, value.releaseTick\n        session.revealRequested = true\n        api.Update()\n        return true\n    end\n\n    function api.Release(value)\n        if not phasePayload(value) or value.phase ~= \"released\"\n            or not integer(value.releaseTick, session.effectTick or session.startTick, 2147483647) then return false end\n        session.revealTick, session.releaseTick = value.releaseTick, value.releaseTick\n        session.phase = \"released\"\n        session.revealRequested, session.releaseRequested = true, true\n        api.Update()\n        return true\n    end\n\n    function api.Reset()\n        if session then\n            session.cancelled = true\n            for _, record in ipairs(session.records) do\n                record.cancelled = true\n                local unit = record.unit\n                if unit then\n                    unit.scoCommanderArrivalRecord = nil\n                end\n                queueCleanup(record, true)\n            end\n        end\n        for _, decal in ipairs(groundScorches) do cleanupQueue[#cleanupQueue + 1] = { decal = decal } end\n        if session and session.cameraStarted then\n            cleanupQueue[#cleanupQueue + 1] = { camera = true }\n        end\n        groundScorches, session, previousSequence = {}, nil, 0\n        if #cleanupQueue > 0 then requestPump() end\n    end\n\n    function api.Cancel(value)\n        if not phasePayload(value) then return false end\n        local sequence = previousSequence\n        api.Reset()\n        previousSequence = sequence\n        return true\n    end\n\n    local function presentSession()\n        if session == nil then return end\n        if GameInfo ~= session.gameInfo or (GameInfo and GameInfo.MapInfo) ~= session.mapInfo then api.Reset(); return end\n        local now = tick()\n        if now == nil then return end\n        if session.completed then return end\n        local complete = session.releaseRequested == true and now >= session.releaseTick\n        for _, record in ipairs(session.records) do\n            if not record.cancelled and not record.deleted then\n                local unit = liveUnit(record)\n                local restore = false\n                if session.revealRequested and now >= session.revealTick and not record.revealed then\n                    record.revealed, restore = true, true\n                end\n                if session.releaseRequested and now >= session.releaseTick and not record.released then\n                    record.released, restore = true, true\n                end\n                if unit then\n                    if not renderable(unit) then\n                        stopPortal(record)\n                        stopImpact(record)\n                    elseif not record.revealed and not record.released and session.phase == \"teleport\" then\n                        arrivalPortal(record, unit)\n                    end\n                    if restore then restoreDisplay(record, unit) end\n                    finishPresentation(record, unit)\n                    if hidden(unit) then hideDisplay(unit) end\n                elseif record.unit and __Entities and __Entities.Units\n                    and __Entities.Units[record.unitId.index] ~= record.unit then\n                    cancelUnit(record.unit)\n                end\n            end\n            if not record.released and not record.deleted and not record.cancelled then complete = false end\n            if validLocal(record.teleportId) then complete = false end\n            if validLocal(record.impactId) then complete = false end\n        end\n        if session.releaseRequested and now >= session.releaseTick and not session.cameraEnded then\n            session.cameraEnded = true\n            if session.cameraStarted then\n                Import(\"client/input/cameraController.lua\").StopSCOMCommanderArrivalCamera(true)\n            end\n        end\n        if complete then session.completed = true end\n    end\n\n    startPump = function()\n        -- SCO_CommanderArrivalPresentationPump_v1\n        if pumpRunning then return end\n        pumpRunning = true\n        -- Native prefab jobs and predicted unit poses finish at this boundary.\n        -- Render callbacks and command listeners only request this one owned pump.\n        NewThread(function()\n            while true do\n                WaitTickEnd()\n                presentationBoundary = true\n                local cleanups = cleanupQueue\n                cleanupQueue = {}\n                for _, item in ipairs(cleanups) do\n                    if item.record then\n                        local record = item.record\n                        record.cleanupQueued = nil\n                        stopPortal(record)\n                        stopImpact(record)\n                        local unit = record.unit\n                        if item.restore and unit and not unit.dead and not unit.deleted\n                            and validLocal(unit.localId) then restoreDisplay(record, unit) end\n                    elseif item.decal then\n                        item.decal:Delete()\n                    elseif item.camera then\n                        Import(\"client/input/cameraController.lua\").StopSCOMCommanderArrivalCamera()\n                    end\n                end\n                local records = pendingRecords\n                pendingRecords = {}\n                presentSession()\n                for record in pairs(records) do\n                    if not record.cancelled and not record.deleted then\n                        local unit = liveUnit(record)\n                        if unit then\n                            if hidden(unit) then hideDisplay(unit) end\n                            finishPresentation(record, unit)\n                        end\n                    end\n                end\n                presentationBoundary = false\n                if (session == nil or session.completed) and #cleanupQueue == 0\n                    and next(pendingRecords) == nil then break end\n                -- WaitTickEnd alone can resume repeatedly within one native flush.\n                WaitTicks(1)\n            end\n            pumpRunning = false\n        end)\n    end\n\n    requestPump = function()\n        -- A post-render request can follow disposal of the current thread bucket.\n        -- Start the worker at native tick-end dispatch, where that bucket is still live.\n        if not pumpRunning then pumpRequested = true end\n    end\n\n    function api.Update()\n        if session and (GameInfo ~= session.gameInfo\n            or (GameInfo and GameInfo.MapInfo) ~= session.mapInfo) then api.Reset() end\n        if (session and not session.completed) or #cleanupQueue > 0\n            or next(pendingRecords) ~= nil then requestPump() end\n    end\n\n    local function acknowledge(phase)\n        Import(\"common/commands/definitions/session.lua\").ExecuteHostFunction.Send(\n            \"SCOCommanderArrivalReady\", {version=2, sequence=session.sequence, phase=phase})\n        Engine.Warn(\"[SCOM Arrival] Rendered \" .. phase .. \" complete; acknowledgment sent.\")\n    end\n\n    function api.RenderUpdate()\n        if not session or session.cancelled or session.completed or Engine.IsReplayPlayback() then return end\n        if GameInfo ~= session.gameInfo or GameInfo.MapInfo ~= session.mapInfo then return end\n        local renderTime = Engine.GetCurrentRealtimeInSeconds()\n        if finite(renderTime) then\n            for _, record in ipairs(session.records) do\n                if record.portalFading and not record.portalFadeReady\n                    and not record.deleted and not record.cancelled then\n                    if record.lastPortalRender then\n                        record.renderedPortalFade = record.renderedPortalFade\n                            + math.clamp(renderTime - record.lastPortalRender, 0, 0.1)\n                    end\n                    record.lastPortalRender = renderTime\n                    if record.renderedPortalFade >= 0.6 then\n                        record.portalFadeReady = true\n                        requestPump()\n                    end\n                end\n            end\n        end\n        if session.phase == \"pan\" and not session.panAcknowledged then\n            local camera = Import(\"client/input/cameraController.lua\")\n            if IsObserver() then\n                session.panAcknowledged = true\n                acknowledge(\"pan\")\n                return\n            end\n            if not session.cameraStarted then\n                for _, record in ipairs(session.records) do\n                    if record.armyId == GetFocusArmy() then\n                        session.cameraStarted = camera.StartSCOMCommanderArrivalCamera(\n                            record.armyId, position(record.position), 4.5)\n                        if session.cameraStarted then\n                            Engine.Warn(\"[SCOM Arrival] First rendered frame; empty-spawn camera pan started.\")\n                        end\n                        break\n                    end\n                end\n            elseif camera.IsSCOMCommanderArrivalPanComplete() then\n                session.panAcknowledged = true\n                acknowledge(\"pan\")\n            end\n        elseif session.phase == \"teleport\" and not session.teleportAcknowledged then\n            local presented = IsObserver()\n            for _, record in ipairs(session.records) do\n                if record.armyId == GetFocusArmy() then\n                    local unit = liveUnit(record)\n                    -- Invisible terrain has no portal to wait for. Visible own\n                    -- commanders must have their native effect allocated first.\n                    presented = unit ~= nil and (not renderable(unit) or validLocal(record.teleportId))\n                    break\n                end\n            end\n            if not presented then return end\n            local now = renderTime\n            if not finite(now) then return end\n            if session.lastEffectRender then\n                session.renderedEffectTime = session.renderedEffectTime\n                    + math.clamp(now - session.lastEffectRender, 0, 0.1)\n            end\n            session.lastEffectRender = now\n            if session.renderedEffectTime >= 2.5 then\n                session.teleportAcknowledged = true\n                acknowledge(\"teleport\")\n            end\n        end\n    end\n\n    _G.SCO_CommanderArrivalVisuals = api\n    Engine.Log(\"[SCOM Arrival] Rendered arrival listeners installed: 2.1.0.\")\n    for _, name in ipairs({ \"Begin\", \"Bind\", \"Reveal\", \"Release\", \"Cancel\" }) do\n        local callback = \"SCOCommanderArrival\" .. name\n        assert(functions[callback] == nil, \"Occupied SCOM arrival listener: \" .. callback)\n        functions[callback] = api[name]\n    end\nend\n\n-- Surface wakes and occasional destruction splashes, owned entirely by the client.\nif not rawget(_G, \"SCO_NavalWaterEffects_v1\") then\n    local unitClass = Import(\"client/units/unitsClasses/unitsBaseClass.lua\").ClientUnit\n    local unitsUpdate = Import(\"client/units/unitsUpdate.lua\")\n    local records, pending, fading, splashes = {}, {}, {}, {}\n    local pumpRunning, pumpRequested = false, false\n    local prefabs = {}\n    local failedPrefabs = {}\n    local reportedBoat, reportedWake = false, false\n    local surfaceBias, fadeSeconds = 0.25, 2.6\n    local sampleInterval, minimumSpeed, maximumCameraHeight = 0.1, 0.5, 350\n    local one = EngineClasses.float3(1, 1, 1)\n    local up = EngineClasses.float3(0, 1, 0)\n    local smallPath = \"VFX/SCOM/Naval/boat_wake.sanvfx\"\n    local mediumPath = \"VFX/SCOM/Naval/boat_wake_medium.sanvfx\"\n    local largePath = \"VFX/SCOM/Naval/boat_wake_large.sanvfx\"\n    local splashPath = \"VFX/Environment/vxi5301_water_splash_large_impact.sanvfx\"\n    local startPump, requestPump\n\n    local function finite(value)\n        return type(value) == \"number\" and value == value and value ~= math.huge and value ~= -math.huge\n    end\n\n    local function valid(id)\n        return id ~= nil and Engine.IsValidLocalID(id)\n    end\n\n    local function isBoat(unit)\n        local movement = unit.tp and unit.tp.movement\n        if not movement or unit:HasTags(Tags.STRUCTURE) then return false end\n        return movement.type == \"WaterSurface\"\n            or (movement.type == \"TracksAmphibious\" and unit:HasTags(Tags.NAVAL))\n    end\n\n    local function waterPoint(unit, water)\n        local position = unit:GetPosition()\n        if not position or not finite(position.x) or not finite(position.z) then return nil end\n        local code, terrain = Engine.SampleTerrainHeight(position)\n        if code ~= EngineErrorCode.Success or not finite(terrain) or terrain >= water then return nil end\n        return EngineClasses.float3(position.x, water + surfaceBias, position.z)\n    end\n\n    local function waterLevel()\n        local code, exists = Engine.HasWater()\n        if code ~= EngineErrorCode.Success or not exists then return nil end\n        local levelCode, level = Engine.GetWaterLevel()\n        if levelCode == EngineErrorCode.Success and finite(level) then return level end\n    end\n\n    local function getPrefab(path)\n        if prefabs[path] then return prefabs[path] end\n        if failedPrefabs[path] then return nil end\n        -- CreatePrefab only references effects registered with the native renderer.\n        if not Engine.LoadEffect(path) then\n            failedPrefabs[path] = true\n            Engine.Error(\"[SCOM Naval] Could not load effect: \" .. path)\n            return nil\n        end\n        local hierarchy = Import(\"common/loading/hierarchyTemplateLoader.lua\")\n        local prefab = EngineClasses.PrefabTemplate(\"SCOM_Naval_\" .. path:match(\"([^/]+)%.sanvfx$\"),\n            EngineClasses.HierarchyTemplate(hierarchy.GetHierarchyEntities(nil)),\n            EngineClasses.GlobalTemplate(),\n            EngineClasses.LocalTemplate(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,\n                { EngineClasses.ParticleTemplate(TemplateHeadEntityName, path, path == splashPath, true) }))\n        local code, id = Engine.CreatePrefab(prefab)\n        if code ~= EngineErrorCode.Success or type(id) ~= \"table\" or not finite(id.Value)\n            or id.Value < 0 or id.Value >= 65535 then\n            failedPrefabs[path] = true\n            Engine.Error(\"[SCOM Naval] Could not create effect prefab: \" .. path)\n            return nil\n        end\n        prefabs[path] = id\n        return id\n    end\n\n    local function createTrail(path, position, rotation)\n        local prefab = getPrefab(path)\n        if not prefab then return nil end\n        local code, id = Engine.InstantiatePrefab(prefab, position, one, rotation)\n        if code == EngineErrorCode.Success and valid(id) then return id end\n        prefabs[path], failedPrefabs[path] = nil, true\n        Engine.Error(\"[SCOM Naval] Effect instantiation failed; path disabled: \" .. path)\n    end\n\n    local function deleteTrail(item)\n        if valid(item.id) then Engine.DeletePrefabInstance(item.id) end\n        fading[item] = nil\n    end\n\n    local function retire(record, now, purge)\n        if record.active then\n            local item = { id = record.active, expires = now + fadeSeconds }\n            record.active = nil\n            if purge then\n                deleteTrail(item)\n            else\n                if valid(item.id) then Engine.SetParticleCanEmit(item.id, false) end\n                -- Completion is measured from the original spawn time by the engine.\n                -- Keep auto-deletion disabled and own the short tail explicitly.\n                fading[item] = true\n                table.insert(record.retired, item)\n            end\n        end\n        for index = #record.retired, 1, -1 do\n            if not fading[record.retired[index]] then table.remove(record.retired, index) end\n        end\n        if purge then\n            for _, item in ipairs(record.retired) do deleteTrail(item) end\n            record.retired = {}\n        elseif #record.retired > 1 then\n            deleteTrail(table.remove(record.retired, 1))\n        end\n    end\n\n    startPump = function()\n        if pumpRunning then return end\n        pumpRunning = true\n        NewThread(function()\n            while true do\n                WaitTickEnd()\n                local now = Engine.GetCurrentRealtimeInSeconds()\n                if not finite(now) then now = 0 end\n                local work = pending\n                pending = {}\n                for record in pairs(work) do\n                    if record.purge or record.want == nil or record.breakTrail then\n                        retire(record, now, record.purge)\n                    end\n                    record.breakTrail = nil\n                    if record.want and not record.purge and not record.finished and not valid(record.active) then\n                        record.active = createTrail(record.path, record.want, record.rotation)\n                        if record.active and not reportedWake then\n                            reportedWake = true\n                            Engine.Log(\"[SCOM Naval] First surface wake instantiated for \" .. tostring(record.unit.tpId))\n                        end\n                    end\n                    record.purge = nil\n                end\n                for item in pairs(fading) do\n                    if now >= item.expires or not valid(item.id) then deleteTrail(item) end\n                end\n                local deaths = splashes\n                splashes = {}\n                for _, position in ipairs(deaths) do\n                    local prefab = getPrefab(splashPath)\n                    if prefab then Engine.InstantiatePrefab(prefab, position, one, GetIdentityQuaternion()) end\n                end\n                if next(pending) == nil and next(fading) == nil and #splashes == 0 then break end\n                WaitTicks(1)\n            end\n            pumpRunning = false\n        end)\n    end\n\n    local function request(record)\n        pending[record] = true\n        requestPump()\n    end\n\n    requestPump = function()\n        -- Render callbacks can run after their tick's native thread bucket closed.\n        -- Start the coroutine only inside the next tick-end flush.\n        if not pumpRunning then pumpRequested = true end\n    end\n\n    local function track(unit)\n        if not isBoat(unit) or unit.scoNavalWakeRecord then return end\n        local collision = unit.tp.collisionInfo and unit.tp.collisionInfo.collisionSize\n        local offset = unit.tp.collisionInfo and unit.tp.collisionInfo.centerOffset\n        local length = collision and collision.z or 4\n        local width = collision and collision.x or 1\n        if not finite(length) then length = 4 end\n        if not finite(width) then width = 1 end\n        local record = { unit = unit, length = math.max(1, math.min(length, 64)),\n            width = math.max(0.3, math.min(width, 32)), retired = {},\n            offsetX = offset and finite(offset.x) and offset.x or 0,\n            offsetZ = offset and finite(offset.z) and offset.z or 0 }\n        -- Native delayed particles discard instance scale; sizes are authored per bin.\n        record.path = record.width <= 1.8 and smallPath or (record.width <= 4.5 and mediumPath or largePath)\n        unit.scoNavalWakeRecord = record\n        records[unit] = record\n        if not reportedBoat then\n            reportedBoat = true\n            Engine.Log(\"[SCOM Naval] First surface boat tracked: \" .. tostring(unit.tpId))\n        end\n    end\n\n    local function stop(unit, purge, finished)\n        local record = unit.scoNavalWakeRecord\n        if not record then return end\n        record.want, record.lastPosition = nil, nil\n        record.purge = record.purge or purge\n        if finished then record.finished = true; records[unit] = nil end\n        request(record)\n    end\n\n    local function updateWakes()\n        local now = Engine.GetCurrentRealtimeInSeconds()\n        local water = waterLevel()\n        local cameraHeight = Engine.GetCameraWorldSpaceHeight()\n        local nearby = water ~= nil and finite(cameraHeight) and cameraHeight - water <= maximumCameraHeight\n        for unit, record in pairs(records) do\n            local unitValid = valid(unit.localId)\n            local purge = unit.dead or unit.deleted or not unitValid or not unit:IsIntelVisionVisible()\n                or water == nil\n            if purge then\n                record.want, record.lastPosition = nil, nil\n                record.purge = true\n                if unit.dead or unit.deleted or not unitValid then\n                    record.finished = true\n                    records[unit] = nil\n                end\n                if record.active or #record.retired > 0 then request(record) end\n            elseif finite(now) and (not record.nextSample or now >= record.nextSample or now < record.lastSample) then\n                -- Foam emits only four times a second. Ten pose samples per second are\n                -- sufficient to follow the hull without four native writes every frame.\n                record.lastSample, record.nextSample = now, now + sampleInterval\n                local point\n                if nearby and unit.isInitialized ~= false and not unit:IsPlacementGhost() then\n                    local speedCode, speed = Engine.GetMovementCurrentSpeed(unit.id)\n                    -- Native movement speed is distance per simulation tick.\n                    local step = Constants.TickTimeStep or (1 / Constants.TickRate)\n                    if speedCode == EngineErrorCode.Success and finite(speed) and speed >= minimumSpeed * step then\n                        point = waterPoint(unit, water)\n                    end\n                end\n                if point then\n                    local previous = record.lastPosition\n                    record.lastPosition = EngineClasses.float3(point.x, point.y, point.z)\n                    if previous then\n                        local dx, dz = point.x - previous.x, point.z - previous.z\n                        if dx * dx + dz * dz > math.max(4, record.length * 2) ^ 2 then\n                            record.breakTrail = true\n                        end\n                    end\n                    local code, forward = Engine.GetLocalEntityForwardDirection(unit.localId)\n                    local heading = code == EngineErrorCode.Success and forward\n                        and finite(forward.x) and finite(forward.z)\n                        and math.sqrt(forward.x * forward.x + forward.z * forward.z) or 0\n                    if heading > 0.0001 then\n                        local x, z = forward.x / heading, forward.z / heading\n                        record.rotation = Engine.QuaternionLookRotationSafe(EngineClasses.float3(x, 0, z), up)\n                        point.x, point.z = point.x + z * record.offsetX + x * record.offsetZ - x * record.length * 0.5,\n                            point.z - x * record.offsetX + z * record.offsetZ - z * record.length * 0.5\n                        local terrainCode, terrain = Engine.SampleTerrainHeight(point)\n                        if terrainCode ~= EngineErrorCode.Success or not finite(terrain) or terrain >= water then point = nil end\n                    else\n                        point = nil\n                    end\n                end\n                record.want = point\n                if point and valid(record.active) and not record.breakTrail then\n                    Engine.SetLocalEntityLocalPosition(record.active, point)\n                    Engine.SetLocalEntityLocalRotation(record.active, record.rotation)\n                elseif point or record.active then\n                    if record.active or #record.retired > 0 or not failedPrefabs[record.path] then request(record) end\n                end\n                if not point then record.lastPosition = nil end\n            end\n        end\n    end\n\n    local function splashRoll(id)\n        if type(id) ~= \"table\" or not finite(id.index) or not finite(id.version) then return false end\n        -- Identity hashing keeps this cosmetic roll consistent across clients/replays\n        -- and never advances the gameplay or ordinary death-effect random stream.\n        local seed = (id.index * 48271 + id.version * 69621 + 17) % 2147483647\n        seed = (seed * 48271 + 1) % 2147483647\n        seed = (seed * 48271 + 1) % 2147483647\n        return seed % 4 == 0\n    end\n\n    local previousCreate = unitClass.SimCreateThread\n    function unitClass:SimCreateThread(...)\n        local result = previousCreate(self, ...)\n        track(self)\n        return result\n    end\n\n    local previousDestroy = unitClass.OnDestroy\n    function unitClass:OnDestroy(destroyType, ...)\n        local death = destroyType == DestroyType.Kinetic or destroyType == DestroyType.Unspecified\n        if not self.scoNavalDeathHandled then\n            self.scoNavalDeathHandled = true\n            if death and isBoat(self) and not self.dead and not self.deleted\n                and valid(self.localId) and not self:IsPlacementGhost() and self:IsIntelVisionVisible()\n                and splashRoll(self.id) then\n                local water = waterLevel()\n                local position = water ~= nil and waterPoint(self, water)\n                if position then table.insert(splashes, position); requestPump() end\n            end\n        end\n        stop(self, not death, true)\n        return previousDestroy(self, destroyType, ...)\n    end\n\n    local previousDelete = unitClass.OnDelete\n    function unitClass:OnDelete(...)\n        stop(self, not self.dead, true)\n        return previousDelete(self, ...)\n    end\n\n    local previousHidden = unitClass.OnIntelHidden\n    function unitClass:OnIntelHidden(...)\n        stop(self, true, false)\n        return previousHidden(self, ...)\n    end\n\n    local previousRender = unitsUpdate.RenderUpdateUnits\n    unitsUpdate.RenderUpdateUnits = function(...)\n        local result = previousRender(...)\n        updateWakes()\n        return result\n    end\n    local previousFlush = _G.ThreadDispatcherFlush\n    assert(type(previousFlush) == \"function\", \"SCOM naval effects need native tick-end dispatch\")\n    function _G.ThreadDispatcherFlush(...)\n        if pumpRequested and not pumpRunning then\n            pumpRequested = false\n            startPump()\n        end\n        return previousFlush(...)\n    end\n    _G.SCO_NavalWaterEffects_v1 = { version = \"1.4.0\" }\n    Engine.Log(\"[SCOM Naval] Surface wakes and 25% destruction splashes installed: 1.4.0.\")\nend\n\n-- FA TDFRiot02 uses one of three tank ribbon variants per projectile.\n-- psf0035 is shared by Fatboy riotguns and uel5005; simulation is untouched.\ndo\n    local class = Import(\"client/projectiles/projectilesClasses/projectilesBaseClass.lua\").ClientProjectile\n    if not class.scoRiotRibbonSelection then\n        local setup = assert(class.SetUpPersistentEffects)\n        function class:SetUpPersistentEffects()\n            setup(self)\n            if self.tpId ~= \"psf0035\" then return end\n            assert(self.tp.visuals.scoRandomPolyTrails == 1, \"Riot ribbon selection contract missing\")\n            local bones = {}\n            for index = 0, 2 do\n                local bone = self:GetBoneId(\"SCO_SourceRibbon_\" .. index)\n                assert(Engine.IsValidLocalID(bone), \"Riot ribbon owner missing\")\n                bones[index + 1] = bone\n            end\n            assert(#self.persistentEffects == 3, \"Riot ribbon owner count changed\")\n            -- This cosmetic seed uses bounded integer arithmetic exact in LuaJIT.\n            -- It avoids consuming the game's shared random state.\n            local seed = (tonumber(self.id.index) + tonumber(self.id.version) * 104729) % 2147483647\n            seed = (seed * 48271) % 2147483647\n            local selected = seed % 3 + 1\n            for index, bone in ipairs(bones) do\n                Engine.SetParticleCanEmit(bone, index == selected)\n            end\n            self.persistentEffects = { bones[selected] }\n        end\n        class.scoRiotRibbonSelection = true\n    end\nend\n";
	}

	private static string BuildAeonEngineerHostAnimationAppendix()
	{
		return "\r\n-- SCO_AeonEngineerBuildAnimation 1.0.0\r\n-- FA drives the same source clip forward while building and backward\r\n-- when construction stops. Exact-time sampling preserves continuity\r\n-- when an engineer changes state before either transition completes.\r\nlocal SCO_AeonEngineerBuildSentinelBase = -10000\r\n\r\nlocal function SCO_AeonEngineerBuildAlive(unit)\r\n    return unit ~= nil and not unit.dead and not unit.deleted\r\nend\r\n\r\nlocal function SCO_AeonEngineerBuildConfig(unit)\r\n    local additions = unit.tp and unit.tp.additions\r\n    local config = additions and additions.aeonEngineerBuildAnimation\r\n    if not config then\r\n        return nil\r\n    end\r\n\r\n    local animations = unit.tp.visuals and unit.tp.visuals.animations\r\n    local animation = animations and animations[config.animationKey]\r\n    if type(config.durationSeconds) ~= \"number\"\r\n        or config.durationSeconds <= 0\r\n        or type(config.authoredRate) ~= \"number\"\r\n        or config.authoredRate <= 0\r\n        or not animation\r\n        or animation.id == nil\r\n    then\r\n        error(unit.tpId .. \" has an invalid Aeon engineer build-animation contract\")\r\n    end\r\n    return config, animation\r\nend\r\n\r\nlocal function SCO_AeonEngineerBuildSample(unit, animation, seconds)\r\n    Engine.PlayAnimation(\r\n        unit.id,\r\n        animation.id,\r\n        SCO_AeonEngineerBuildSentinelBase + seconds)\r\nend\r\n\r\nlocal function SCO_AeonEngineerBuildPlayRest(unit, config)\r\n    local animations = unit.tp.visuals and unit.tp.visuals.animations\r\n    local rest = animations and animations[config.restAnimationKey]\r\n    if not rest or rest.id == nil then\r\n        error(unit.tpId .. \" has no Aeon engineer rest animation\")\r\n    end\r\n    Engine.PlayAnimation(unit.id, rest.id, 0.1)\r\nend\r\n\r\nlocal function SCO_AeonEngineerBuildTransitionThread(\r\n    unit,\r\n    generation,\r\n    opening)\r\n    local config, animation = SCO_AeonEngineerBuildConfig(unit)\r\n    if not config then\r\n        return\r\n    end\r\n\r\n    local duration = config.durationSeconds\r\n    local sample = math.max(\r\n        0,\r\n        math.min(duration, unit.scoAeonEngineerBuildSample or 0))\r\n    while SCO_AeonEngineerBuildAlive(unit)\r\n        and unit.scoAeonEngineerBuildGeneration == generation\r\n        and ((opening and sample < duration)\r\n            or (not opening and sample > 0))\r\n    do\r\n        SCO_AeonEngineerBuildSample(unit, animation, sample)\r\n        unit.scoAeonEngineerBuildSample = sample\r\n        WaitTicks(1)\r\n        local delta = Constants.TickTimeStep * config.authoredRate\r\n        if opening then\r\n            sample = math.min(duration, sample + delta)\r\n        else\r\n            sample = math.max(0, sample - delta)\r\n        end\r\n    end\r\n\r\n    if not SCO_AeonEngineerBuildAlive(unit)\r\n        or unit.scoAeonEngineerBuildGeneration ~= generation\r\n    then\r\n        return\r\n    end\r\n\r\n    unit.scoAeonEngineerBuildSample = sample\r\n    if opening then\r\n        SCO_AeonEngineerBuildSample(unit, animation, sample)\r\n    else\r\n        SCO_AeonEngineerBuildPlayRest(unit, config)\r\n    end\r\nend\r\n\r\nfunction AeonPortEngineer:SCO_SetBuildAnimationState(opening)\r\n    local additions = self.tp and self.tp.additions\r\n    if not additions or not additions.aeonEngineerBuildAnimation then\r\n        return\r\n    end\r\n    self.scoAeonEngineerBuildGeneration =\r\n        (self.scoAeonEngineerBuildGeneration or 0) + 1\r\n    self:NewThread(\r\n        SCO_AeonEngineerBuildTransitionThread,\r\n        self.scoAeonEngineerBuildGeneration,\r\n        opening)\r\nend\r\n\r\nfunction AeonPortEngineer:OnStopBeingBuilt()\r\n    local result = ChosenEngineer.OnStopBeingBuilt(self)\r\n    local additions = self.tp and self.tp.additions\r\n    if additions and additions.aeonEngineerBuildAnimation then\r\n        self.scoAeonEngineerBuildGeneration =\r\n            (self.scoAeonEngineerBuildGeneration or 0) + 1\r\n        self.scoAeonEngineerBuildSample = 0\r\n    end\r\n    return result\r\nend\r\n\r\nfunction AeonPortEngineer:OnStartBuildRoutine(targetUnit)\r\n    local result = ChosenEngineer.OnStartBuildRoutine(self, targetUnit)\r\n    self:SCO_SetBuildAnimationState(true)\r\n    return result\r\nend\r\n\r\nfunction AeonPortEngineer:OnStopBuildRoutine(targetUnit)\r\n    local result = ChosenEngineer.OnStopBuildRoutine(self, targetUnit)\r\n    self:SCO_SetBuildAnimationState(false)\r\n    return result\r\nend\r\n\r\nfunction AeonPortEngineer:OnDestroy(isDelete)\r\n    self.scoAeonEngineerBuildGeneration =\r\n        (self.scoAeonEngineerBuildGeneration or 0) + 1\r\n    return ChosenEngineer.OnDestroy(self, isDelete)\r\nend";
	}

	private static string BuildHostClassAppendix()
	{
		GeneratedCzarBeamHook czarBeam = GeneratedAeonPortSpecs.All.Single((GeneratedPortSpec port) => port.SourceId == "UAA0310").CzarBeam;
		return "-- The stock Chosen module exports realm-prefixed classes. Keep the\n-- established short names local to this generated appendix so every\n-- Aeon port and its later lifecycle delegates resolve the Host class.\nlocal ChosenStructure = HostChosenStructure\nlocal ChosenEngineeringStation = HostChosenEngineeringStation\nlocal ChosenStorage = HostChosenStorage\nlocal ChosenAirFactory = HostChosenAirFactory\nlocal ChosenLandFactory = HostChosenLandFactory\nlocal ChosenNavalFactory = HostChosenNavalFactory\nlocal ChosenAlloyExtractor = HostChosenAlloyExtractor\nlocal ChosenEnergyGenerator = HostChosenEnergyGenerator\nlocal ChosenAirUnit = HostChosenAirUnit\nlocal ChosenLandUnit = HostChosenLandUnit\nlocal ChosenNavalUnit = HostChosenNavalUnit\nlocal ChosenEngineer = HostChosenEngineer\n\nHostAeonPortLandUnit = Class(\"AeonPortLandUnit\", ChosenLandUnit)\nHostAeonPortAirUnit = Class(\"AeonPortAirUnit\", ChosenAirUnit)\nHostAeonPortNavalUnit = Class(\"AeonPortNavalUnit\", ChosenNavalUnit)\nHostAeonPortEngineer = Class(\"AeonPortEngineer\", ChosenEngineer)\nHostAeonPortStructure = Class(\"AeonPortStructure\", ChosenStructure)\nHostAeonPortStorage = Class(\"AeonPortStorage\", ChosenStorage)\nHostAeonPortAlloyExtractor = Class(\"AeonPortAlloyExtractor\", ChosenAlloyExtractor)\nHostAeonPortEnergyGenerator = Class(\"AeonPortEnergyGenerator\", ChosenEnergyGenerator)\nHostAeonPortEngineeringStation = Class(\"AeonPortEngineeringStation\", ChosenEngineeringStation)\nHostAeonPortLandFactory = Class(\"AeonPortLandFactory\", ChosenLandFactory)\nHostAeonPortAirFactory = Class(\"AeonPortAirFactory\", ChosenAirFactory)\nHostAeonPortNavalFactory = Class(\"AeonPortNavalFactory\", ChosenNavalFactory)\n\nlocal AeonPortLandUnit = HostAeonPortLandUnit\nlocal AeonPortAirUnit = HostAeonPortAirUnit\nlocal AeonPortNavalUnit = HostAeonPortNavalUnit\nlocal AeonPortEngineer = HostAeonPortEngineer\nlocal AeonPortStructure = HostAeonPortStructure\nlocal AeonPortStorage = HostAeonPortStorage\nlocal AeonPortAlloyExtractor = HostAeonPortAlloyExtractor\nlocal AeonPortEnergyGenerator = HostAeonPortEnergyGenerator\nlocal AeonPortEngineeringStation = HostAeonPortEngineeringStation\nlocal AeonPortLandFactory = HostAeonPortLandFactory\nlocal AeonPortAirFactory = HostAeonPortAirFactory\nlocal AeonPortNavalFactory = HostAeonPortNavalFactory\n\nlocal scoAeonFactoryOrderTasks =\n    Import(\"common/commonOrders.lua\").OrderTasks\nlocal scoAeonFactoryHostOrderManager =\n    Import(\"host/managers/orders/hostOrderManager.lua\")\nlocal scoAeonFactoryUnits = __Entities.Units\n\nlocal function scoAeonFactoryIsAlive(unit)\n    return unit ~= nil and not unit.dead and not unit.deleted\nend\n\nlocal function scoAeonFactoryIsCurrent(unit)\n    local id = unit and unit.id\n    return scoAeonFactoryIsAlive(unit)\n        and id ~= nil\n        and scoAeonFactoryUnits[id.index] == unit\nend\n\nlocal function scoAeonFactoryWorldPoint(factory, offset)\n    local rotated = Engine.QuaternionRotateVector(\n        factory:GetOrientation(),\n        EngineClasses.float3(\n            offset.x or 0,\n            offset.y or 0,\n            offset.z or 0))\n    local origin = factory:GetPosition()\n    return EngineClasses.float3(\n        origin.x + rotated.x,\n        origin.y + rotated.y,\n        origin.z + rotated.z)\nend\n\nlocal function scoAeonFactoryGetTargetKey(targetUnit)\n    local id = targetUnit and targetUnit.id\n    if id == nil then\n        return nil\n    end\n    return tostring(id.index) .. \":\" .. tostring(id.version)\nend\n\nlocal function scoAeonFactoryIsFiniteNumber(value)\n    return type(value) == \"number\"\n        and value == value\n        and value > -math.huge\n        and value < math.huge\nend\n\nlocal function scoAeonFactoryIsFiniteVector(value)\n    return type(value) == \"table\"\n        and scoAeonFactoryIsFiniteNumber(value.x)\n        and scoAeonFactoryIsFiniteNumber(value.y)\n        and scoAeonFactoryIsFiniteNumber(value.z)\nend\n\nlocal function scoAeonFactoryHasRouting(factory)\n    local additions = factory.tp.additions\n    local staging = additions and additions.buildStagingOffset\n    if staging == nil then\n        local construction = factory.tp.construction\n        local donorPoints =\n            construction and construction.rollOffPoints\n        if donorPoints\n            and donorPoints[1]\n            and scoAeonFactoryIsFiniteVector(\n                donorPoints[1].offset)\n        then\n            -- UAB0304 is a separately scoped SACU gateway that\n            -- shares this class and intentionally retains stock\n            -- staging/roll-off metadata.\n            return false\n        end\n        error(\n            \"Factory has neither exact Aeon routing nor a valid donor roll-off point: \"\n                .. tostring(factory.tpId))\n    end\n\n    local ramps = additions.rollOffRamps\n    local surfacePolicy = additions.rollOffSurfacePolicy\n    local valid = scoAeonFactoryIsFiniteVector(staging)\n        and type(ramps) == \"table\"\n        and #ramps == 2\n        and (\n            surfacePolicy == \"terrain\"\n            or surfacePolicy == \"factory\")\n    if valid then\n        for _, ramp in ipairs(ramps) do\n            if not scoAeonFactoryIsFiniteVector(ramp.rampOffset)\n                or not scoAeonFactoryIsFiniteVector(\n                    ramp.clearanceOffset)\n                or not scoAeonFactoryIsFiniteNumber(\n                    ramp.headingDegrees)\n            then\n                valid = false\n                break\n            end\n        end\n    end\n    if not valid then\n        error(\n            \"Imported Aeon factory routing metadata is malformed: \"\n                .. tostring(factory.tpId))\n    end\n    return true\nend\n\nlocal function scoAeonFactoryGetRamps(factory)\n    if not scoAeonFactoryHasRouting(factory) then\n        error(\"Stock-routed factory has no authored Aeon ramps.\")\n    end\n    return factory.tp.additions.rollOffRamps\nend\n\nlocal function scoAeonFactoryRoutePoint(factory, offset)\n    local point = scoAeonFactoryWorldPoint(factory, offset)\n    local policy = factory.tp.additions.rollOffSurfacePolicy\n    if policy == \"terrain\" then\n        local _, terrainHeight = Engine.SampleTerrainHeight(\n            EngineClasses.float3(point.x, 0, point.z))\n        point.y = terrainHeight\n    elseif policy ~= \"factory\" then\n        error(\n            \"Imported Aeon factory has an invalid surface policy: \"\n                .. tostring(factory.tpId))\n    end\n    return point\nend\n\nlocal function scoAeonFactorySelectRamp(factory, targetUnit)\n    local ramps = scoAeonFactoryGetRamps(factory)\n    local key = scoAeonFactoryGetTargetKey(targetUnit)\n    local selectedIndexes = factory.scoAeonFactoryRollOffRampIndexes\n    local selectedIndex =\n        key and selectedIndexes and selectedIndexes[key]\n    if selectedIndex then\n        return ramps[selectedIndex]\n    end\n\n    local source = factory.unitBeingBuiltSource or factory\n    local rallyPoint = source.rallyPoint\n    if rallyPoint then\n        local closestDistanceSquared = nil\n        for index, ramp in ipairs(ramps) do\n            local clearancePoint = scoAeonFactoryRoutePoint(\n                factory,\n                ramp.clearanceOffset or ramp.rampOffset)\n            local deltaX = clearancePoint.x - rallyPoint.x\n            local deltaZ = clearancePoint.z - rallyPoint.z\n            local distanceSquared =\n                (deltaX * deltaX) + (deltaZ * deltaZ)\n            if closestDistanceSquared == nil\n                or distanceSquared < closestDistanceSquared\n            then\n                closestDistanceSquared = distanceSquared\n                selectedIndex = index\n            end\n        end\n    else\n        selectedIndex = factory.scoAeonFactoryNextRollOffRampIndex or 1\n        if selectedIndex < 1 or selectedIndex > #ramps then\n            selectedIndex = 1\n        end\n        factory.scoAeonFactoryNextRollOffRampIndex = selectedIndex + 1\n        if factory.scoAeonFactoryNextRollOffRampIndex > #ramps then\n            factory.scoAeonFactoryNextRollOffRampIndex = 1\n        end\n    end\n\n    if key then\n        factory.scoAeonFactoryRollOffRampIndexes =\n            selectedIndexes or {}\n        factory.scoAeonFactoryRollOffRampIndexes[key] = selectedIndex\n    end\n    return ramps[selectedIndex]\nend\n\nlocal function scoAeonFactoryForgetRamp(factory, targetUnit)\n    local key = scoAeonFactoryGetTargetKey(targetUnit)\n    local selectedIndexes = factory.scoAeonFactoryRollOffRampIndexes\n    if key and selectedIndexes then\n        selectedIndexes[key] = nil\n    end\nend\n\nlocal function scoAeonFactoryFaceRamp(factory, targetUnit, ramp)\n    if not scoAeonFactoryIsAlive(targetUnit) or ramp == nil then\n        return\n    end\n    local localOrientation = Engine.EulerToQuaternion(\n        EngineClasses.float3(\n            0,\n            math.rad(ramp.headingDegrees or 0),\n            0),\n        RotationOrder.Default)\n    local orientation = Engine.QuaternionMultiply(\n        factory:GetOrientation(),\n        localOrientation)\n    targetUnit:SetOrientation(orientation)\nend\n\nlocal function scoAeonFactoryFinishLandRollOff(\n    targetUnit,\n    factory,\n    clearancePoint)\n    if not scoAeonFactoryIsCurrent(targetUnit) then\n        return\n    end\n    -- Pin the final terrain height before collision returns. This\n    -- also provides a bounded safe fallback if movement is ever\n    -- interrupted before the clearance waypoint is reached.\n    targetUnit:SetPosition(clearancePoint)\n    if targetUnit.scoFactoryColliderPinOwner == factory then\n        targetUnit.scoFactoryColliderPinOwner = nil\n    end\n    Engine.SetVolumeColliderEnabled(targetUnit.id, true)\nend\n\nlocal function scoAeonFactoryLandRollOffReleaseThread(\n    targetUnit,\n    factory,\n    clearancePoint)\n    local remainingTicks = 300\n    while scoAeonFactoryIsCurrent(targetUnit)\n        and remainingTicks > 0\n    do\n        local position = targetUnit:GetPosition()\n        local deltaX = position.x - clearancePoint.x\n        local deltaZ = position.z - clearancePoint.z\n        if (deltaX * deltaX) + (deltaZ * deltaZ) <= 1 then\n            scoAeonFactoryFinishLandRollOff(\n                targetUnit,\n                factory,\n                clearancePoint)\n            targetUnit.scoAeonFactoryLandRollOffThread = nil\n            return\n        end\n        remainingTicks = remainingTicks - 1\n        WaitTicks(1)\n    end\n    scoAeonFactoryFinishLandRollOff(\n        targetUnit,\n        factory,\n        clearancePoint)\n    if scoAeonFactoryIsCurrent(targetUnit) then\n        targetUnit.scoAeonFactoryLandRollOffThread = nil\n    end\nend\n\nlocal function scoAdaptAeonFactoryClass(factoryClass, baseClass)\n    factoryClass.GetRollOffPoint = function(self)\n        if not scoAeonFactoryHasRouting(self) then\n            return baseClass.GetRollOffPoint(self)\n        end\n        return scoAeonFactoryWorldPoint(\n            self,\n            self.tp.additions.buildStagingOffset)\n    end\n\n    factoryClass.StopAeonFactoryBuildColliderPin = function(\n        self,\n        targetUnit)\n        if targetUnit ~= nil\n            and self.scoAeonFactoryPinnedBuildTarget ~= targetUnit\n        then\n            return\n        end\n        local pinnedTarget = self.scoAeonFactoryPinnedBuildTarget\n        self.scoAeonFactoryPinnedBuildTarget = nil\n        if pinnedTarget\n            and pinnedTarget.scoFactoryColliderPinOwner == self\n        then\n            pinnedTarget.scoFactoryColliderPinOwner = nil\n        end\n    end\n\n    factoryClass.PinAeonFactoryBuildCollider = function(\n        self,\n        targetUnit)\n        self:StopAeonFactoryBuildColliderPin()\n        if not scoAeonFactoryIsAlive(targetUnit)\n            or not targetUnit:HasTags(Tags.MOBILE)\n            or targetUnit:IsCompleted()\n        then\n            return\n        end\n\n        self.scoAeonFactoryPinnedBuildTarget = targetUnit\n        targetUnit.scoFactoryColliderPinOwner = self\n        targetUnit:SetOrientation(self:GetOrientation())\n        targetUnit:SetPosition(self:GetRollOffPoint())\n        Engine.SetVolumeColliderEnabled(targetUnit.id, false)\n    end\n\n    factoryClass.StopAeonFactoryBuildTargetWatchThread = function(\n        self)\n        local thread = self.scoAeonFactoryBuildTargetWatchThread\n        self.scoAeonFactoryBuildTargetWatchThread = nil\n        if thread ~= nil then\n            KillThread(thread)\n        end\n    end\n\n    factoryClass.ScoAeonFactoryBuildTargetWatchThread = function(\n        self,\n        targetUnit)\n        while not self.dead\n            and self.scoAeonFactoryPinnedBuildTarget == targetUnit\n            and scoAeonFactoryIsCurrent(targetUnit)\n            and not targetUnit:IsCompleted()\n        do\n            WaitTicks(1)\n        end\n        self.scoAeonFactoryBuildTargetWatchThread = nil\n        if not scoAeonFactoryIsCurrent(targetUnit) then\n            self:StopAeonFactoryBuildColliderPin(targetUnit)\n            scoAeonFactoryForgetRamp(self, targetUnit)\n        end\n    end\n\n    factoryClass.StartAeonFactoryBuildTargetWatchThread = function(\n        self,\n        targetUnit)\n        self:StopAeonFactoryBuildTargetWatchThread()\n        if scoAeonFactoryIsAlive(targetUnit)\n            and targetUnit:HasTags(Tags.MOBILE)\n            and not targetUnit:IsCompleted()\n        then\n            self.scoAeonFactoryBuildTargetWatchThread =\n                self:NewThread(\n                    self.ScoAeonFactoryBuildTargetWatchThread,\n                    targetUnit)\n        end\n    end\n\n    factoryClass.ReleaseAeonFactoryBuiltUnit = function(\n        self,\n        targetUnit,\n        ramp)\n        if not scoAeonFactoryIsAlive(targetUnit)\n            or not targetUnit:HasTags(Tags.MOBILE)\n            or not targetUnit:IsCompleted()\n            or ramp == nil\n        then\n            return false\n        end\n\n        local clearancePoint = scoAeonFactoryRoutePoint(\n            self,\n            ramp.clearanceOffset or ramp.rampOffset)\n        -- Move clear before the stock callback restores paired\n        -- collision. Restoring collision at the build bone lets\n        -- large units intersect or sink through the factory hull.\n        scoAeonFactoryFaceRamp(self, targetUnit, ramp)\n        targetUnit:SetPosition(clearancePoint)\n        self:StopAeonFactoryBuildColliderPin(targetUnit)\n        if scoAeonFactoryIsAlive(targetUnit) then\n            Engine.SetVolumeColliderEnabled(targetUnit.id, true)\n        end\n        return true\n    end\n\n    factoryClass.OnStartBuildRoutine = function(self, targetUnit)\n        if not scoAeonFactoryHasRouting(self) then\n            baseClass.OnStartBuildRoutine(self, targetUnit)\n            return\n        end\n        self:PinAeonFactoryBuildCollider(targetUnit)\n        self:StartAeonFactoryBuildTargetWatchThread(targetUnit)\n        baseClass.OnStartBuildRoutine(self, targetUnit)\n        -- Self-upgrade targets are structures. They share this\n        -- callback but must retain the factory's authored rotation\n        -- and must not consume a production-child ramp slot.\n        if scoAeonFactoryIsAlive(targetUnit)\n            and targetUnit:HasTags(Tags.MOBILE)\n            and not targetUnit:IsCompleted()\n        then\n            local ramp = scoAeonFactorySelectRamp(self, targetUnit)\n            scoAeonFactoryFaceRamp(self, targetUnit, ramp)\n            targetUnit:SetPosition(self:GetRollOffPoint())\n            Engine.SetVolumeColliderEnabled(targetUnit.id, false)\n        end\n    end\n\n    factoryClass.OnStopBuildRoutine = function(self, targetUnit)\n        if not scoAeonFactoryHasRouting(self) then\n            baseClass.OnStopBuildRoutine(self, targetUnit)\n            return\n        end\n        self:StopAeonFactoryBuildTargetWatchThread()\n        local completed = scoAeonFactoryIsAlive(targetUnit)\n            and targetUnit:HasTags(Tags.MOBILE)\n            and targetUnit:IsCompleted()\n        local landRollOff = completed\n            and self.tp.additions.rollOffSurfacePolicy == \"terrain\"\n        if completed and not landRollOff then\n            self:ReleaseAeonFactoryBuiltUnit(\n                targetUnit,\n                scoAeonFactorySelectRamp(self, targetUnit))\n        elseif landRollOff then\n            -- Keep collision pinned while RollOffUnit drives the\n            -- completed land child through the authored exit.\n            Engine.SetVolumeColliderEnabled(targetUnit.id, false)\n        elseif scoAeonFactoryIsAlive(targetUnit)\n            and targetUnit:HasTags(Tags.MOBILE)\n        then\n            Engine.SetVolumeColliderEnabled(targetUnit.id, false)\n        else\n            self:StopAeonFactoryBuildColliderPin(targetUnit)\n            scoAeonFactoryForgetRamp(self, targetUnit)\n        end\n        baseClass.OnStopBuildRoutine(self, targetUnit)\n        if (not completed or landRollOff)\n            and scoAeonFactoryIsAlive(targetUnit)\n            and targetUnit:HasTags(Tags.MOBILE)\n        then\n            Engine.SetVolumeColliderEnabled(targetUnit.id, false)\n            if not completed then\n                -- A pause can leave the partial child alive; keep\n                -- watching until resume or later abort/delete so\n                -- collider/ramp ownership cannot become stale.\n                self:StartAeonFactoryBuildTargetWatchThread(\n                    targetUnit)\n            end\n        end\n    end\n\n    factoryClass.RollOffUnit = function(self, targetUnit)\n        if not scoAeonFactoryHasRouting(self) then\n            baseClass.RollOffUnit(self, targetUnit)\n            return\n        end\n        if not scoAeonFactoryIsAlive(targetUnit)\n            or not targetUnit:HasTags(Tags.MOBILE)\n        then\n            scoAeonFactoryForgetRamp(self, targetUnit)\n            return\n        end\n\n        local ramp = scoAeonFactorySelectRamp(self, targetUnit)\n        local rampPoint = scoAeonFactoryRoutePoint(\n            self,\n            ramp.rampOffset)\n        local clearancePoint = scoAeonFactoryRoutePoint(\n            self,\n            ramp.clearanceOffset or ramp.rampOffset)\n        scoAeonFactoryFaceRamp(self, targetUnit, ramp)\n        local landRollOff =\n            self.tp.additions.rollOffSurfacePolicy == \"terrain\"\n        local queuedRoute = false\n        if landRollOff then\n            -- The completed land child crosses the real source\n            -- ramp with collision disabled, then the child-owned\n            -- watcher restores collision at terrain clearance.\n            Engine.SetVolumeColliderEnabled(targetUnit.id, false)\n            self:StopAeonFactoryBuildColliderPin(targetUnit)\n            if targetUnit.scoAeonFactoryLandRollOffThread == nil then\n                targetUnit.scoAeonFactoryLandRollOffThread =\n                    targetUnit:NewThread(\n                        scoAeonFactoryLandRollOffReleaseThread,\n                        self,\n                        clearancePoint)\n            end\n            scoAeonFactoryHostOrderManager.HostIssueOrder(\n                scoAeonFactoryOrderTasks.MOVE,\n                { targetUnit },\n                false,\n                rampPoint,\n                nil)\n            scoAeonFactoryHostOrderManager.HostIssueOrder(\n                scoAeonFactoryOrderTasks.MOVE,\n                { targetUnit },\n                true,\n                clearancePoint,\n                nil)\n            queuedRoute = true\n        else\n            local released = self:ReleaseAeonFactoryBuiltUnit(\n                targetUnit,\n                ramp)\n            if not released then\n                scoAeonFactoryHostOrderManager.HostIssueOrder(\n                    scoAeonFactoryOrderTasks.MOVE,\n                    { targetUnit },\n                    false,\n                    rampPoint,\n                    nil)\n                scoAeonFactoryHostOrderManager.HostIssueOrder(\n                    scoAeonFactoryOrderTasks.MOVE,\n                    { targetUnit },\n                    true,\n                    clearancePoint,\n                    nil)\n                queuedRoute = true\n            end\n        end\n\n        local source = self.unitBeingBuiltSource or self\n        if source.rallyPoint then\n            scoAeonFactoryHostOrderManager.HostIssueOrder(\n                scoAeonFactoryOrderTasks.MOVE,\n                { targetUnit },\n                queuedRoute,\n                source.rallyPoint,\n                nil)\n        end\n        scoAeonFactoryForgetRamp(self, targetUnit)\n    end\n\n    factoryClass.ProductionBehaviorStop = function(self)\n        local targetUnit = self.productionBehaviorTargetUnit\n        self:StopAeonFactoryBuildTargetWatchThread()\n        self:StopAeonFactoryBuildColliderPin(targetUnit)\n        scoAeonFactoryForgetRamp(self, targetUnit)\n        baseClass.ProductionBehaviorStop(self)\n    end\n\n    factoryClass.OnCancelConstruction = function(self)\n        self:StopAeonFactoryBuildTargetWatchThread()\n        self:StopAeonFactoryBuildColliderPin()\n        self.scoAeonFactoryRollOffRampIndexes = nil\n        self.scoAeonFactoryNextRollOffRampIndex = nil\n        baseClass.OnCancelConstruction(self)\n    end\n\n    factoryClass.OnDestroy = function(self, isDelete)\n        self:StopAeonFactoryBuildTargetWatchThread()\n        self:StopAeonFactoryBuildColliderPin()\n        self.scoAeonFactoryRollOffRampIndexes = nil\n        self.scoAeonFactoryNextRollOffRampIndex = nil\n        baseClass.OnDestroy(self, isDelete)\n    end\nend\n\nscoAdaptAeonFactoryClass(\n    AeonPortLandFactory,\n    ChosenLandFactory)\nscoAdaptAeonFactoryClass(\n    AeonPortAirFactory,\n    ChosenAirFactory)\nscoAdaptAeonFactoryClass(\n    AeonPortNavalFactory,\n    ChosenNavalFactory)\n\nlocal scoCzarProcessAreaDamage =\n    Import(\"host/collisionUpdate.lua\").ProcessAreaDamage\nlocal scoCzarOrderTasks =\n    Import(\"common/commonOrders.lua\").OrderTasks\nlocal scoCzarTargetingLayers =\n    Import(\"common/layers.lua\").TargetingLayer\nlocal scoCzarHostOrderManager =\n    Import(\"host/managers/orders/hostOrderManager.lua\")\nlocal scoCzarOverheadRange = 0.3\n\nlocal function scoCzarIsAlive(unit)\n    return unit ~= nil and not unit.dead and not unit.deleted\nend\n\nlocal function scoCzarWorldPoint(factory, x, y, z)\n    local rotated = Engine.QuaternionRotateVector(\n        factory:GetOrientation(),\n        EngineClasses.float3(x, y, z))\n    local origin = factory:GetPosition()\n    return EngineClasses.float3(\n        origin.x + rotated.x,\n        origin.y + rotated.y,\n        origin.z + rotated.z)\nend\n\nlocal function scoCzarTerrainImpact(centerBone)\n    local _, origin = Engine.GetGlobalEntityWorldPosition(centerBone)\n    local _, terrainHeight = Engine.SampleTerrainHeight(origin)\n    local impactY = math.max(\n        origin.y - " + Lua(czarBeam.RayLength) + ",\n        terrainHeight)\n    impactY = math.min(origin.y, impactY)\n    return EngineClasses.float3(origin.x, impactY, origin.z)\nend\n\nlocal function scoCzarIsDirectLandAttack(czar, targetUnit)\n    local orders = czar.orders\n    local activeOrder = orders and orders.activeOrder\n    return targetUnit ~= nil\n        and targetUnit.targetingLayer\n            == scoCzarTargetingLayers.Land\n        and activeOrder ~= nil\n        and activeOrder.orderTask\n            == scoCzarOrderTasks.ATTACKUNIT\nend\n\nlocal function scoCzarIsHorizontallyCentered(czar, targetUnit)\n    if targetUnit.targetingLayer\n        ~= scoCzarTargetingLayers.Land\n    then\n        return true\n    end\n    return math3D.distanceToFloat2(\n        czar:GetPosition(),\n        math3D.tofloat2(targetUnit:GetPosition()))\n        < scoCzarOverheadRange\nend\n\n-- Retain stock Factory ownership of queue/production state, then\n-- delegate only the mobile lifecycle exactly as the existing\n-- Sanctuary mobile-factory composition does.\nHostAeonPortCzar = Class(\"AeonPortCzar\", ChosenAirFactory)\nlocal AeonPortCzar = HostAeonPortCzar\n\nfunction AeonPortCzar:__init(id, army, template, fractionCompleted, builder)\n    ChosenAirFactory.__init(\n        self,\n        id,\n        army,\n        template,\n        fractionCompleted,\n        builder)\n\n    self.scoCzarCenterMuzzle = self:GetBoneId(\n        \"" + EscapeLua(czarBeam.CenterBone) + "\")\n    if not self.scoCzarCenterMuzzle\n        or not Engine.IsValidGlobalID(self.scoCzarCenterMuzzle)\n    then\n        error(\"Czar requires exact Center_Muzzle; no Root fallback is allowed.\")\n    end\n\n    local weapon = self:GetWeapon(1)\n    local muzzle = weapon and weapon.muzzles and weapon.muzzles[1]\n    local beam = muzzle and muzzle.beam\n    if not weapon\n        or not weapon.isBeamWeapon\n        or #weapon.aimControllerIds ~= 0\n        or not beam\n    then\n        error(\"Czar primary Center_Muzzle beam was not created.\")\n    end\n\n    -- FA's Czar beam is fixed and non-turreted. Sanctuary's stock\n    -- weapon state machine incorrectly rejects weapons with no aim\n    -- controllers, so only this instance supplies the source-faithful\n    -- target/range gate while retaining stock reload and beam updates.\n    local czar = self\n    function weapon:IsWeaponOnTarget()\n        local target = self.targetUnit\n        return target ~= nil\n            and self:CanShootAt(target)\n            and self:IsTargetInRange(target)\n            and scoCzarIsHorizontallyCentered(czar, target)\n    end\n\n    -- The stock HostBeam applies damage every simulation tick.\n    -- Keep it only as the synchronized enable gate; the source\n    -- 1000 damage is delivered exactly once per 0.2-second pulse.\n    beam.damage = 0\n    self.scoCzarWeapon = weapon\n    self.scoCzarBeam = beam\n    self.scoCzarGroundAttackFollow = false\n    self.scoCzarForcedBeam = false\n    self.scoCzarLoggedForcedBeam = false\n    self.scoCzarMovementLocked = false\n    self.scoCzarDamageThread =\n        self:NewThread(self.ScoCzarDamageThread)\nend\n\nfunction AeonPortCzar:CanBeSlaveFactory()\n    return false\nend\n\nfunction AeonPortCzar:CanBeMasterFactory()\n    return false\nend\n\nfunction AeonPortCzar:PromoteToUnit()\n    ChosenAirUnit.PromoteToUnit(self)\nend\n\nfunction AeonPortCzar:AttackBehaviorStart(targetUnit, range)\n    if not self:AttackBehaviorIsValidFor(targetUnit, range) then\n        return\n    end\n    if self.attackBehaviorIsActive then\n        self:AttackBehaviorStop()\n    end\n\n    local followGroundTarget =\n        scoCzarIsDirectLandAttack(self, targetUnit)\n    self:SetCzarGroundAttackFollow(followGroundTarget)\n    ChosenAirFactory.AttackBehaviorStart(\n        self,\n        targetUnit,\n        followGroundTarget and scoCzarOverheadRange or range)\n    self:RefreshCzarMovementEnabled()\nend\n\nfunction AeonPortCzar:AttackBehaviorStop()\n    ChosenAirFactory.AttackBehaviorStop(self)\n    self:SetCzarGroundAttackFollow(false)\nend\n\nfunction AeonPortCzar:FollowBehaviorThread()\n    if not self.scoCzarGroundAttackFollow then\n        ChosenAirFactory.FollowBehaviorThread(self)\n        return\n    end\n\n    while self.scoCzarGroundAttackFollow\n        and self:FollowBehaviorIsValidFor(\n            self.followBehaviorTargetUnit,\n            self.followBehaviorRange)\n        and self.attackBehaviorTargetUnit\n            == self.followBehaviorTargetUnit\n    do\n        local targetPosition =\n            self:FollowBehaviorGetTargetPosition()\n        local currentPosition = self:GetPosition()\n        local offsetX = targetPosition.x - currentPosition.x\n        local offsetZ = targetPosition.y - currentPosition.z\n        local distance = math.sqrt(\n            offsetX * offsetX + offsetZ * offsetZ)\n        if distance > 0 then\n            local maxStep =\n                self.tp.movement.speed\n                * Constants.TickTimeStep\n            local step = math.min(distance, maxStep)\n            currentPosition.x = currentPosition.x\n                + offsetX / distance * step\n            currentPosition.z = currentPosition.z\n                + offsetZ / distance * step\n            self:SetPosition(currentPosition)\n        end\n        WaitTicks(1)\n    end\n\n    self:FollowBehaviorStop()\nend\n\nfunction AeonPortCzar:OnStopBeingBuilt()\n    ChosenAirFactory.OnStopBeingBuilt(self)\n    Engine.SetNavmapModifierEnabled(self.id, false)\n    Engine.SetGlobalGridModifierEnabled(self.id, false)\n    self.scoCzarGroundAttackFollow = false\n    self.scoCzarMovementLocked = false\n    self:RefreshCzarMovementEnabled()\nend\n\nfunction AeonPortCzar:RefreshCzarMovementEnabled()\n    -- Sanctuary's native movement separation is two-dimensional:\n    -- altitude does not keep this radius-10 Czar capsule from\n    -- shoving a land target. Direct land attacks therefore use\n    -- the bounded host movement above while all hit/selection\n    -- colliders remain enabled.\n    Engine.SetMovementEnabled(\n        self.id,\n        not self.scoCzarMovementLocked\n            and not self.scoCzarGroundAttackFollow)\nend\n\nfunction AeonPortCzar:SetCzarGroundAttackFollow(enabled)\n    self.scoCzarGroundAttackFollow = enabled\n    self:RefreshCzarMovementEnabled()\nend\n\nfunction AeonPortCzar:SetCzarMovementLocked(locked)\n    self.scoCzarMovementLocked = locked\n    self:RefreshCzarMovementEnabled()\nend\n\nfunction AeonPortCzar:StopCzarBuildColliderPin(targetUnit)\n    if targetUnit ~= nil\n        and self.scoCzarPinnedBuildTarget ~= targetUnit\n    then\n        return\n    end\n    local pinnedTarget = self.scoCzarPinnedBuildTarget\n    self.scoCzarPinnedBuildTarget = nil\n    if self.scoCzarBuildColliderPinThread ~= nil then\n        KillThread(self.scoCzarBuildColliderPinThread)\n        self.scoCzarBuildColliderPinThread = nil\n    end\n    if pinnedTarget\n        and pinnedTarget.scoFactoryColliderPinOwner == self\n    then\n        pinnedTarget.scoFactoryColliderPinOwner = nil\n    end\nend\n\nfunction AeonPortCzar:PinCzarBuildCollider(targetUnit)\n    self:StopCzarBuildColliderPin()\n    if not scoCzarIsAlive(targetUnit)\n        or targetUnit:IsCompleted()\n    then\n        return\n    end\n    self.scoCzarPinnedBuildTarget = targetUnit\n    targetUnit.scoFactoryColliderPinOwner = self\n    local buildPosition = scoCzarWorldPoint(self, 0, 0, 0)\n    targetUnit:SetOrientation(self:GetOrientation())\n    targetUnit:SetPosition(buildPosition)\n    Engine.SetVolumeColliderEnabled(targetUnit.id, false)\n    self.scoCzarBuildColliderPinThread = self:NewThread(\n        self.CzarBuildColliderPinThread,\n        targetUnit)\nend\n\nfunction AeonPortCzar:CzarBuildColliderPinThread(targetUnit)\n    while self.scoCzarPinnedBuildTarget == targetUnit\n        and scoCzarIsAlive(self)\n        and scoCzarIsAlive(targetUnit)\n        and not targetUnit:IsCompleted()\n    do\n        targetUnit:SetOrientation(self:GetOrientation())\n        targetUnit:SetPosition(scoCzarWorldPoint(self, 0, 0, 0))\n        WaitTicks(1)\n    end\n    self.scoCzarBuildColliderPinThread = nil\nend\n\nfunction AeonPortCzar:ReleaseCzarBuiltUnit(targetUnit)\n    if not scoCzarIsAlive(targetUnit)\n        or not targetUnit:IsCompleted()\n    then\n        return false\n    end\n    local releasePosition = scoCzarWorldPoint(\n        self,\n        0,\n        0,\n        " + Lua(-20.0) + ")\n    targetUnit:SetOrientation(self:GetOrientation())\n    targetUnit:SetPosition(releasePosition)\n    self:StopCzarBuildColliderPin(targetUnit)\n    if scoCzarIsAlive(targetUnit) then\n        Engine.SetVolumeColliderEnabled(targetUnit.id, true)\n    end\n    return true\nend\n\nfunction AeonPortCzar:RotatorsEnabledOnConstruction()\n    return true\nend\n\nfunction AeonPortCzar:GetRollOffPoint()\n    return scoCzarWorldPoint(self, 0, 0, 0)\nend\n\nfunction AeonPortCzar:OnStartBuildRoutine(targetUnit)\n    self:StopCzarBuildTargetWatchThread()\n    if scoCzarIsAlive(targetUnit) then\n        self:PinCzarBuildCollider(targetUnit)\n    end\n    self:SetCzarMovementLocked(true)\n    ChosenAirFactory.OnStartBuildRoutine(self, targetUnit)\n    if scoCzarIsAlive(targetUnit)\n        and not targetUnit:IsCompleted()\n    then\n        Engine.SetVolumeColliderEnabled(targetUnit.id, false)\n    end\nend\n\nfunction AeonPortCzar:OnStopBuildRoutine(targetUnit)\n    local completed = scoCzarIsAlive(targetUnit)\n        and targetUnit:IsCompleted()\n    if completed then\n        -- Move clear before the base callback restores the paired\n        -- client collider.\n        self:ReleaseCzarBuiltUnit(targetUnit)\n    elseif scoCzarIsAlive(targetUnit) then\n        Engine.SetVolumeColliderEnabled(targetUnit.id, false)\n    end\n    ChosenAirFactory.OnStopBuildRoutine(self, targetUnit)\n    if not completed and scoCzarIsAlive(targetUnit) then\n        Engine.SetVolumeColliderEnabled(targetUnit.id, false)\n    end\nend\n\nfunction AeonPortCzar:StopCzarBuildTargetWatchThread()\n    local thread = self.scoCzarBuildTargetWatchThread\n    self.scoCzarBuildTargetWatchThread = nil\n    if thread ~= nil then\n        KillThread(thread)\n    end\nend\n\nfunction AeonPortCzar:ScoCzarBuildTargetWatchThread()\n    while not self.dead and self.productionBehaviorIsActive do\n        local targetUnit = self.productionBehaviorTargetUnit\n        if scoCzarIsAlive(targetUnit)\n            and not targetUnit:IsCompleted()\n        then\n            self:PinCzarBuildCollider(targetUnit)\n            self.scoCzarBuildTargetWatchThread = nil\n            return\n        end\n        WaitTicks(1)\n    end\n    self.scoCzarBuildTargetWatchThread = nil\nend\n\nfunction AeonPortCzar:ProductionBehaviorBuildOne(item)\n    self:SetCzarMovementLocked(true)\n    self:StopCzarBuildTargetWatchThread()\n    self.scoCzarBuildTargetWatchThread =\n        self:NewThread(self.ScoCzarBuildTargetWatchThread)\n    ChosenAirFactory.ProductionBehaviorBuildOne(self, item)\n    self:StopCzarBuildTargetWatchThread()\n    self:SetCzarMovementLocked(false)\nend\n\nfunction AeonPortCzar:RollOffUnit(targetUnit)\n    if not scoCzarIsAlive(targetUnit) then\n        self:SetCzarMovementLocked(false)\n        return\n    end\n    self:ReleaseCzarBuiltUnit(targetUnit)\n    local rollOffPoint = self.rallyPoint\n    if not rollOffPoint then\n        rollOffPoint = scoCzarWorldPoint(\n            self,\n            0,\n            0,\n            " + Lua(-40.0) + ")\n    end\n\n    scoCzarHostOrderManager.HostIssueOrder(\n        scoCzarOrderTasks.MOVE,\n        { targetUnit },\n        false,\n        rollOffPoint,\n        nil)\n    self:SetCzarMovementLocked(false)\nend\n\nfunction AeonPortCzar:ProductionBehaviorStop()\n    local targetUnit = self.productionBehaviorTargetUnit\n    self:StopCzarBuildTargetWatchThread()\n    self:StopCzarBuildColliderPin(targetUnit)\n    ChosenAirFactory.ProductionBehaviorStop(self)\n    self:SetCzarMovementLocked(false)\n    if not self.dead and self:IsCompleted() then\n        -- Stock factories disable all rotators when production\n        -- ends; the combat Czar must keep its weapon rotators live.\n        self:SetRotatorsEnabled(true)\n    end\nend\n\nfunction AeonPortCzar:OnCancelConstruction()\n    self:StopCzarBuildTargetWatchThread()\n    self:StopCzarBuildColliderPin()\n    ChosenAirFactory.OnCancelConstruction(self)\n    self:SetCzarMovementLocked(false)\nend\n\nfunction AeonPortCzar:OnDestroy(isDelete)\n    self:StopCzarBuildTargetWatchThread()\n    self:StopCzarBuildColliderPin()\n    self:SetCzarMovementLocked(false)\n    if self.scoCzarBeam then\n        self.scoCzarForcedBeam = false\n        self.scoCzarBeam:SetBeamEnabled(false, true)\n    end\n    ChosenAirFactory.OnDestroy(self, isDelete)\nend\n\nfunction AeonPortCzar:ScoCzarForceDirectLandBeam()\n    local target = self.attackBehaviorTargetUnit\n    local shouldForce = self.scoCzarGroundAttackFollow == true\n        and scoCzarIsAlive(target)\n        and target.targetingLayer\n            == scoCzarTargetingLayers.Land\n        and self.scoCzarWeapon:CanShootAt(target)\n        and scoCzarIsHorizontallyCentered(self, target)\n\n    if shouldForce then\n        -- SetPreferredTarget only assigns an aim target when the\n        -- targeter collider has already delivered an enter event.\n        -- The Czar's collision-free manual approach can cross that\n        -- boundary without one, so explicitly bind the ordered land\n        -- target once it is directly beneath Center_Muzzle.\n        if self.scoCzarWeapon.targetUnit ~= target then\n            self.scoCzarWeapon:SetAimTarget(target)\n        end\n        self.scoCzarForcedBeam = true\n        self.scoCzarBeam:SetBeamEnabled(true, true)\n        if not self.scoCzarLoggedForcedBeam then\n            self.scoCzarLoggedForcedBeam = true\n            Log(\"SCO_CZAR_BEAM host direct-land gate enabled\")\n        end\n        return\n    end\n\n    if self.scoCzarForcedBeam then\n        self.scoCzarForcedBeam = false\n        self.scoCzarBeam:SetBeamEnabled(false, true)\n    end\nend\n\nfunction AeonPortCzar:ScoCzarDamageThread()\n    while not self.dead do\n        self:ScoCzarForceDirectLandBeam()\n        if self.scoCzarBeam and self.scoCzarBeam.enabled then\n            local impact = scoCzarTerrainImpact(\n                self.scoCzarCenterMuzzle)\n            scoCzarProcessAreaDamage(\n                impact,\n                " + Lua(czarBeam.DamageRadius) + ",\n                " + Lua(czarBeam.Damage) + ",\n                self.army,\n                false,\n                self)\n            WaitSeconds(" + Lua(czarBeam.DamageInterval) + ")\n        else\n            WaitTicks(1)\n        end\n    end\nend\n-- Append to host/units/unitsClasses/unitsDefaultChosen.lua.\nlocal SCOFaT3Shield = Import(\"host/shield.lua\")\nlocal SCOFaT3ChosenSetUpShields = HostAeonPortLandUnit.SetUpShields\nlocal SCOFaT3ChosenCheckShieldState = HostAeonPortLandUnit.CheckShieldState\n\nfunction HostAeonPortLandUnit:SetUpShields()\n    SCOFaT3ChosenSetUpShields(self)\n    if self.tpId == \"ucl3001\" then SCOFaT3Shield.SCOFaT3InstallShield(self) end\nend\n\nfunction HostAeonPortLandUnit:CheckShieldState(skipRecharge)\n    if self.tpId == \"ucl3001\" then\n        return SCOFaT3Shield.SCOFaT3CheckShieldState(self, skipRecharge)\n    end\n    return SCOFaT3ChosenCheckShieldState(self, skipRecharge)\nend\n";
	}

	private static string BuildHostCzarCrashAppendix()
	{
		return "\r\n-- FA UAA0310 always remains in its airborne destruction path until\r\n-- perimeter/terrain contact. Sanctuary normally explodes DeathExplosion\r\n-- weapons in OnDestroy and then drops a wreck, so defer only this Czar's\r\n-- authored damage and own its host-authoritative edge-first fall.\r\nlocal function scoCzarCrashContract(czar)\r\n    local additions = czar.tp and czar.tp.additions\r\n    local contract = additions and additions.scoFaCzarCrash\r\n    if contract == nil\r\n        or contract.version ~= \"1.0.0\"\r\n        or contract.sourceUnitId ~= \"UAA0310\"\r\n        or contract.sourceScriptSha256\r\n            ~= \"af2458bd797acffbe8c28ca9d683a020d17aa9a7e0ed6df3780e58274e82e3f2\"\r\n        or contract.sourceDefaultAirUnitSha256\r\n            ~= \"fce73da5a37ca4b68ef9e4c317316189e9196d172f9f4d172df3cc825d079447\"\r\n        or contract.sourceDestroyNoFallRandomChance ~= 1.1\r\n        or contract.impactDamage ~= 15000\r\n        or contract.impactRadius ~= 15\r\n        or contract.impactDamageFriendly ~= true\r\n        or contract.perimeterDamage ~= 1000\r\n        or contract.perimeterRadius ~= 5\r\n        or contract.perimeterDamageFriendly ~= true\r\n        or type(contract.sourceWatchedBones) ~= \"table\"\r\n        or #contract.sourceWatchedBones ~= 8\r\n        or contract.sourceWaterImpactAppliesDamage ~= true\r\n        or contract.runtimeMode ~= \"HostWreckEdgeFirstFall\"\r\n        or contract.runtimeSideSelection ~= \"EntityIndexParity\"\r\n        or contract.runtimePerimeterContactMode ~= \"SingleLeadingEdgePulse\"\r\n        or contract.runtimeImpactDebounce ~= \"ExactlyOnce\"\r\n        or contract.runtimeTiltDegrees ~= 32\r\n        or contract.runtimeTiltRateDegrees ~= 16\r\n        or contract.runtimeLeadingEdgeOffset ~= 13.45\r\n        or contract.runtimeLevelClearance ~= 2.8341667652130127\r\n        or contract.runtimeFallAcceleration ~= 10\r\n        or contract.runtimeMaximumFallSeconds ~= 30\r\n    then\r\n        error(\"Malformed SCOM FA Czar crash contract\")\r\n    end\r\n\r\n    local expectedWatchedBones = {\r\n        \"Left_Turret01_Muzzle\",\r\n        \"Right_Turret01_Muzzle\",\r\n        \"Left_Turret02_WepFocus\",\r\n        \"Right_Turret02_WepFocus\",\r\n        \"Left_Turret03_Muzzle\",\r\n        \"Right_Turret03_Muzzle\",\r\n        \"Attachpoint01\",\r\n        \"Attachpoint02\",\r\n    }\r\n    for index, boneName in ipairs(expectedWatchedBones) do\r\n        if contract.sourceWatchedBones[index] ~= boneName then\r\n            error(\"Czar perimeter-contact bone contract drifted\")\r\n        end\r\n    end\r\n\r\n    local deathImpact = nil\r\n    for _, weapon in ipairs(czar.tp.weapons or {}) do\r\n        if weapon.category == \"DeathExplosion\" then\r\n            if deathImpact ~= nil then\r\n                error(\"Czar owns more than one DeathExplosion weapon\")\r\n            end\r\n            deathImpact = weapon\r\n        end\r\n    end\r\n    if deathImpact == nil\r\n        or deathImpact.damage ~= contract.impactDamage\r\n        or deathImpact.damageRadius ~= contract.impactRadius\r\n        or deathImpact.damageFriendly ~= true\r\n        or deathImpact.damageType ~= \"Normal\"\r\n    then\r\n        error(\"Czar DeathImpact weapon drifted from FA\")\r\n    end\r\n    return contract\r\nend\r\n\r\nlocal function scoCzarCrashRotation(yawRadians, rollRadians)\r\n    local up = EngineClasses.float3(0, 1, 0)\r\n    local forward = EngineClasses.float3(0, 0, 1)\r\n    return Engine.QuaternionMultiply(\r\n        Engine.QuaternionAxisAngle(up, yawRadians),\r\n        Engine.QuaternionAxisAngle(forward, rollRadians))\r\nend\r\n\r\nlocal function scoCzarCrashApplyDamage(\r\n    wreck,\r\n    contract,\r\n    army,\r\n    center,\r\n    yawRadians,\r\n    sideSign)\r\n    if wreck.scoFaCzarCrashImpactApplied == true then\r\n        return false\r\n    end\r\n    wreck.scoFaCzarCrashImpactApplied = true\r\n\r\n    -- Positive local-forward roll raises the right edge, so the\r\n    -- opposite parity-selected edge is the first perimeter contact.\r\n    local rightX = math.cos(yawRadians)\r\n    local rightZ = -math.sin(yawRadians)\r\n    local edge = EngineClasses.float3(\r\n        center.x - sideSign * rightX\r\n            * contract.runtimeLeadingEdgeOffset,\r\n        center.y,\r\n        center.z - sideSign * rightZ\r\n            * contract.runtimeLeadingEdgeOffset)\r\n    scoCzarProcessAreaDamage(\r\n        edge,\r\n        contract.perimeterRadius,\r\n        contract.perimeterDamage,\r\n        army,\r\n        contract.perimeterDamageFriendly)\r\n    scoCzarProcessAreaDamage(\r\n        center,\r\n        contract.impactRadius,\r\n        contract.impactDamage,\r\n        army,\r\n        contract.impactDamageFriendly)\r\n    return true\r\nend\r\n\r\nlocal function scoCzarCrashSurface(position, hasWater, waterLevel)\r\n    local _, terrainHeight = Engine.SampleTerrainHeight(position)\r\n    if type(terrainHeight) ~= \"number\" then\r\n        error(\"Czar crash terrain height is unavailable\")\r\n    end\r\n    if hasWater and terrainHeight < waterLevel then\r\n        return waterLevel, true\r\n    end\r\n    return terrainHeight, false\r\nend\r\n\r\nlocal function scoCzarCrashWreckThread(\r\n    wreck,\r\n    position,\r\n    velocity,\r\n    yawRadians,\r\n    sideSign,\r\n    deleteWreckAtRest,\r\n    contract,\r\n    army)\r\n    local dt = Constants.TickTimeStep\r\n    local targetRoll = math.rad(contract.runtimeTiltDegrees) * sideSign\r\n    local rollRadians = math.rad(6) * sideSign\r\n    local rollRate = math.rad(contract.runtimeTiltRateDegrees)\r\n    local elapsed = 0\r\n    local _, hasWater = Engine.HasWater()\r\n    local waterLevel = 0\r\n    if hasWater then\r\n        _, waterLevel = Engine.GetWaterLevel()\r\n        if type(waterLevel) ~= \"number\" then\r\n            error(\"Czar crash water level is unavailable\")\r\n        end\r\n    end\r\n\r\n    Engine.SetRayColliderEnabled(wreck.id, false)\r\n    Engine.SetGlobalEntityLocalRotation(\r\n        wreck.id,\r\n        scoCzarCrashRotation(yawRadians, rollRadians))\r\n\r\n    while true do\r\n        WaitTicks(1)\r\n        if wreck.deleted then\r\n            return\r\n        end\r\n\r\n        elapsed = elapsed + dt\r\n        velocity.y = velocity.y\r\n            - contract.runtimeFallAcceleration * dt\r\n\r\n        local nextRollMagnitude = math.min(\r\n            math.abs(targetRoll),\r\n            math.abs(rollRadians) + rollRate * dt)\r\n        rollRadians = nextRollMagnitude * sideSign\r\n\r\n        position.x = position.x + velocity.x * dt\r\n        position.y = position.y + velocity.y * dt\r\n        position.z = position.z + velocity.z * dt\r\n\r\n        local surfaceHeight, overWater =\r\n            scoCzarCrashSurface(position, hasWater, waterLevel)\r\n        -- The pinned Czar mesh spans local Y -2.8341667652130127 to\r\n        -- 3.0966575145721436. Its local hull midpoint follows the roll;\r\n        -- placing it on the surface buries about half the rendered hull.\r\n        local hullMidpoint = 0.13124537467956543 * math.cos(rollRadians)\r\n        local contactHeight = surfaceHeight - hullMidpoint\r\n        local contacted = position.y <= contactHeight\r\n\r\n        local rotation = scoCzarCrashRotation(\r\n            yawRadians,\r\n            rollRadians)\r\n        if contacted then\r\n            position.y = contactHeight\r\n            Engine.SetGlobalEntityPosition(wreck.id, position)\r\n            Engine.SetGlobalEntityLocalRotation(wreck.id, rotation)\r\n            local impactCenter = EngineClasses.float3(\r\n                position.x,\r\n                surfaceHeight,\r\n                position.z)\r\n            local impactApplied = scoCzarCrashApplyDamage(\r\n                wreck,\r\n                contract,\r\n                army,\r\n                impactCenter,\r\n                yawRadians,\r\n                sideSign)\r\n            -- SCO_CzarCrashScorchContact_v1: the falling wreck owns impact.\r\n            if impactApplied and not overWater then\r\n                SendToAllClients(\r\n                    {\r\n                        position = {\r\n                            x = impactCenter.x,\r\n                            y = impactCenter.y,\r\n                            z = impactCenter.z,\r\n                        },\r\n                    },\r\n                    \"SCOCzarCrashImpactScorch\")\r\n            end\r\n            if overWater or deleteWreckAtRest then\r\n                wreck:Delete()\r\n            end\r\n            return\r\n        end\r\n\r\n        Engine.SetGlobalEntityPosition(wreck.id, position)\r\n        Engine.SetGlobalEntityLocalRotation(wreck.id, rotation)\r\n    end\r\nend\r\n\r\nlocal scoCzarStockOnStopBeingBuilt = AeonPortCzar.OnStopBeingBuilt\r\nfunction AeonPortCzar:OnStopBeingBuilt()\r\n    scoCzarStockOnStopBeingBuilt(self)\r\n    self.isAirborne = true\r\n    ChosenAirUnit.ApplyAirborneLayers(self)\r\nend\r\n\r\nfunction AeonPortCzar:CreateDeathExplosions()\r\n    if not self:IsCompleted() then\r\n        return ChosenAirFactory.CreateDeathExplosions(self)\r\n    end\r\n    -- Validate now, but apply at terrain/water contact below.\r\n    scoCzarCrashContract(self)\r\nend\r\n\r\nlocal function scoCzarCrashThread(czar, overkillRatio)\r\n    if not czar:IsCompleted() then\r\n        return ChosenAirFactory.DeathThread(czar, overkillRatio)\r\n    end\r\n\r\n    local contract = scoCzarCrashContract(czar)\r\n    local dt = Constants.TickTimeStep\r\n    local _, speedPerTick = Engine.GetMovementCurrentSpeed(czar.id)\r\n    local _, headingDegrees = Engine.GetMovementHeadingDegrees(czar.id)\r\n    local headingRadians = math.rad(headingDegrees)\r\n    local speed = speedPerTick / dt\r\n    local velocity = EngineClasses.float3(\r\n        math.sin(headingRadians) * speed,\r\n        0,\r\n        math.cos(headingRadians) * speed)\r\n    if czar.scoAircraftCrashVelocity then\r\n        local sourceVelocity = czar.scoAircraftCrashVelocity\r\n        velocity = EngineClasses.float3(\r\n            sourceVelocity.x, sourceVelocity.y, sourceVelocity.z)\r\n    end\r\n    local _, position = Engine.GetGlobalEntityWorldPosition(czar.id)\r\n    local sideSign = (czar.id.index % 2 == 0) and 1 or -1\r\n    local deleteWreckAtRest = (overkillRatio or 0) >= 1\r\n        or not czar.spawnsWreck\r\n        or czar:GetFractionComplete() < 0.5\r\n    local army = czar.army\r\n    local wreckage = CreateWreckageFromUnit(czar)\r\n    if wreckage == nil then\r\n        -- Asset creation failures must not strand a dead unit. This\r\n        -- fallback retains exact damage, while the verifier requires\r\n        -- the normal falling wreck route to be constructible.\r\n        local surfaceHeight = scoCzarCrashSurface(position, false, 0)\r\n        local impact = EngineClasses.float3(\r\n            position.x,\r\n            surfaceHeight,\r\n            position.z)\r\n        scoCzarCrashApplyDamage(\r\n            {}, contract, army, impact, headingRadians, sideSign)\r\n        czar:Delete()\r\n        return\r\n    end\r\n\r\n    wreckage:NewThread(function()\r\n        scoCzarCrashWreckThread(\r\n            wreckage,\r\n            position,\r\n            velocity,\r\n            headingRadians,\r\n            sideSign,\r\n            deleteWreckAtRest,\r\n            contract,\r\n            army)\r\n    end)\r\n    czar:Delete()\r\nend\r\n\r\nfunction AeonPortCzar:CrashThread(overkillRatio)\r\n    return scoCzarCrashThread(self, overkillRatio)\r\nend\r\n\r\nfunction AeonPortCzar:DeathThread(overkillRatio)\r\n    return scoCzarCrashThread(self, overkillRatio)\r\nend\r\n";
	}

	private static string BuildHostColliderPromotionAppendix()
	{
		return "-- A factory-owned child built inside imported carrier geometry must\n-- remain non-colliding when placement promotion ordinarily enables\n-- its collider. The mobile factory releases it only after moving it\n-- clear. This shared guard is idempotent with the Fatboy patcher.\nif not _G.SupremeCommanderOverhaulFactoryColliderPromotionHookInstalled then\n    _G.SupremeCommanderOverhaulFactoryColliderPromotionHookInstalled = true\n    local scoAeonColliderUnit = HostUnit or Unit\n    if not scoAeonColliderUnit then\n        error(\"SCO Aeon collider hook could not resolve the host unit base class\")\n    end\n    local scoStockUnitPromoteToUnit = scoAeonColliderUnit.PromoteToUnit\n    function scoAeonColliderUnit:PromoteToUnit()\n        scoStockUnitPromoteToUnit(self)\n        if self.scoFactoryColliderPinOwner ~= nil then\n            Engine.SetVolumeColliderEnabled(self.id, false)\n        end\n    end\nend";
	}

	private static string BuildClientClassAppendix()
	{
		GeneratedCzarBeamHook czarBeam = GeneratedAeonPortSpecs.All.Single((GeneratedPortSpec port) => port.SourceId == "UAA0310").CzarBeam;
		return "-- The stock Chosen module exports realm-prefixed classes. Keep the\n-- established short names local to this generated appendix so every\n-- Aeon port and its later lifecycle delegates resolve the Client class.\nlocal ChosenStructure = ClientChosenStructure\nlocal ChosenEngineeringStation = ClientChosenEngineeringStation\nlocal ChosenStorage = ClientChosenStorage\nlocal ChosenAirFactory = ClientChosenAirFactory\nlocal ChosenLandFactory = ClientChosenLandFactory\nlocal ChosenNavalFactory = ClientChosenNavalFactory\nlocal ChosenAlloyExtractor = ClientChosenAlloyExtractor\nlocal ChosenEnergyGenerator = ClientChosenEnergyGenerator\nlocal ChosenAirUnit = ClientChosenAirUnit\nlocal ChosenLandUnit = ClientChosenLandUnit\nlocal ChosenNavalUnit = ClientChosenNavalUnit\nlocal ChosenEngineer = ClientChosenEngineer\n\nClientAeonPortLandUnit = Class(\"AeonPortLandUnit\", ChosenLandUnit)\nClientAeonPortAirUnit = Class(\"AeonPortAirUnit\", ChosenAirUnit)\nClientAeonPortNavalUnit = Class(\"AeonPortNavalUnit\", ChosenNavalUnit)\nClientAeonPortEngineer = Class(\"AeonPortEngineer\", ChosenEngineer)\nClientAeonPortStructure = Class(\"AeonPortStructure\", ChosenStructure)\nClientAeonPortStorage = Class(\"AeonPortStorage\", ChosenStorage)\nClientAeonPortAlloyExtractor = Class(\"AeonPortAlloyExtractor\", ChosenAlloyExtractor)\nClientAeonPortEnergyGenerator = Class(\"AeonPortEnergyGenerator\", ChosenEnergyGenerator)\nClientAeonPortEngineeringStation = Class(\"AeonPortEngineeringStation\", ChosenEngineeringStation)\nClientAeonPortLandFactory = Class(\"AeonPortLandFactory\", ChosenLandFactory)\nClientAeonPortAirFactory = Class(\"AeonPortAirFactory\", ChosenAirFactory)\nClientAeonPortNavalFactory = Class(\"AeonPortNavalFactory\", ChosenNavalFactory)\n\nlocal AeonPortLandUnit = ClientAeonPortLandUnit\nlocal AeonPortAirUnit = ClientAeonPortAirUnit\nlocal AeonPortNavalUnit = ClientAeonPortNavalUnit\nlocal AeonPortEngineer = ClientAeonPortEngineer\nlocal AeonPortStructure = ClientAeonPortStructure\nlocal AeonPortStorage = ClientAeonPortStorage\nlocal AeonPortAlloyExtractor = ClientAeonPortAlloyExtractor\nlocal AeonPortEnergyGenerator = ClientAeonPortEnergyGenerator\nlocal AeonPortEngineeringStation = ClientAeonPortEngineeringStation\nlocal AeonPortLandFactory = ClientAeonPortLandFactory\nlocal AeonPortAirFactory = ClientAeonPortAirFactory\nlocal AeonPortNavalFactory = ClientAeonPortNavalFactory\n\n-- The uc* target IDs select Chosen tarmac prefabs in the stock\n-- Structure implementation. No owned Aeon decal is packaged here,\n-- so suppress that incorrect faction art instead of stretching it.\nfunction AeonPortLandFactory:CreateTarmac()\nend\n\nfunction AeonPortAirFactory:CreateTarmac()\nend\n\nfunction AeonPortNavalFactory:CreateTarmac()\nend\n\n-- Sanctuary keeps both full factory models at the same position\n-- throughout an upgrade. Match the source behavior by keeping the\n-- animated source factory visible and hiding its replacement target\n-- until the upgrade completes.\nlocal function scoHideAeonFactoryUpgradeTarget(factoryClass)\n    local stockOnStartUpgrade = factoryClass.OnStartUpgrade\n    local stockOnEndUpgrade = factoryClass.OnEndUpgrade\n    local stockOnEndUpgrading = factoryClass.OnEndUpgrading\n    local stockOnIntelVision = factoryClass.OnIntelVision\n\n    factoryClass.OnStartUpgrade = function(self, upgrader)\n        stockOnStartUpgrade(self, upgrader)\n        self.scoUpgradeTargetHidden = true\n        Engine.SetRendererEnabled(self.localId, false)\n        if self.tarmac then\n            self.tarmac:SetEnabled(false)\n        end\n    end\n\n    factoryClass.OnEndUpgrade = function(self, upgrader)\n        local completed =\n            self:IsCompleted() and upgrader and not upgrader.dead\n        stockOnEndUpgrade(self, upgrader)\n        if not completed then\n            return\n        end\n\n        self.scoUpgradeTargetHidden = false\n        self:RecalculateIntel(true)\n    end\n\n    factoryClass.OnEndUpgrading = function(self, upgrade)\n        stockOnEndUpgrading(self, upgrade)\n        if upgrade and upgrade:IsCompleted() then\n            Engine.SetRendererEnabled(self.localId, false)\n            if self.tarmac then\n                self.tarmac:SetEnabled(false)\n            end\n        end\n    end\n\n    factoryClass.OnIntelVision = function(self)\n        stockOnIntelVision(self)\n        if self.scoUpgradeTargetHidden then\n            Engine.SetRendererEnabled(self.localId, false)\n            if self.tarmac then\n                self.tarmac:SetEnabled(false)\n            end\n        end\n    end\nend\n\nscoHideAeonFactoryUpgradeTarget(AeonPortLandFactory)\nscoHideAeonFactoryUpgradeTarget(AeonPortAirFactory)\nscoHideAeonFactoryUpgradeTarget(AeonPortNavalFactory)\n\nlocal scoCzarVFXTemplateLoader =\n    Import(\"common/loading/vfxTemplateLoader.lua\")\nlocal scoCzarImpactPrefab =\n    scoCzarVFXTemplateLoader.GetOrCreateVFXPrefab(\n        \"" + EscapeLua(czarBeam.ImpactEffect) + "\")\nlocal scoCzarScale = EngineClasses.float3(1, 1, 1)\nlocal scoCzarUp = EngineClasses.float3(0, 1, 0)\nlocal scoCzarOrientationUp = EngineClasses.float3(0, 0, 1)\nlocal scoCzarImpactRotation = EngineClasses.quaternion()\nEngine.QuaternionLookRotation(\n    scoCzarUp,\n    scoCzarOrientationUp,\n    scoCzarImpactRotation)\n\nlocal function scoCzarTerrainImpact(centerBone)\n    local _, origin = Engine.GetLocalEntityWorldPosition(centerBone)\n    local _, terrainHeight = Engine.SampleTerrainHeight(origin)\n    local impactY = math.max(\n        origin.y - " + Lua(czarBeam.RayLength) + ",\n        terrainHeight)\n    impactY = math.min(origin.y, impactY)\n    local impact = EngineClasses.float3(\n        origin.x,\n        impactY,\n        origin.z)\n    return impact, math.max(0, origin.y - impactY)\nend\n\nlocal function scoCzarPinBeamVisualToTerrain(czar)\n    local beam = czar.scoCzarBeam\n    if not beam or not beam.enabled then\n        return\n    end\n    local _, terrainLength = scoCzarTerrainImpact(\n        czar.scoCzarCenterMuzzle)\n    beam.length = terrainLength\nend\n\nlocal function scoCzarStopEffect(localId)\n    if localId and Engine.IsValidLocalID(localId) then\n        Engine.SetParticleCanEmit(localId, false)\n        Engine.SetDestroyUponCompletion(localId, true)\n    end\nend\n\nlocal function scoCzarSetLocalVolumeColliderEnabled(\n    globalId,\n    enabled)\n    local localId = EngineClasses.LocalID()\n    local errorCode = Engine.GetGlobalEntityPairedLocalID(\n        globalId,\n        localId)\n    if errorCode == EngineErrorCode.Success\n        and Engine.IsValidLocalID(localId)\n    then\n        Engine.SetVolumeColliderEnabled(localId, enabled)\n    end\nend\n\nClientAeonPortCzar = Class(\"AeonPortCzar\", ChosenAirFactory)\nlocal AeonPortCzar = ClientAeonPortCzar\n\nfunction AeonPortCzar:__init(\n    globalId,\n    localId,\n    armyId,\n    template,\n    fractionComplete)\n    ChosenAirFactory.__init(\n        self,\n        globalId,\n        localId,\n        armyId,\n        template,\n        fractionComplete)\n\n    self.scoCzarCenterMuzzle = self:GetBoneId(\n        \"" + EscapeLua(czarBeam.CenterBone) + "\")\n    if not Engine.IsValidLocalID(self.scoCzarCenterMuzzle) then\n        error(\"Czar requires exact Center_Muzzle; no Root fallback is allowed.\")\n    end\n\n    local weapon = self.weapons and self.weapons[1]\n    local muzzle = weapon and weapon.muzzles and weapon.muzzles[1]\n    local beam = muzzle and muzzle.beam\n    if not beam then\n        error(\"Czar primary Center_Muzzle client beam was not created.\")\n    end\n\n    local beamContract = template.additions\n        and template.additions.czarCenterDownBeam\n    local beamWidthScales = beamContract and {\n        beamContract.visualCoreWidthScale,\n        beamContract.visualDistortionWidthScale,\n    }\n    -- The source UAA0310 continuous beam replaces the legacy core/distortion\n    -- pair with one authored mesh during the later Field Fix template pass.\n    local sourceBeam = weapon.tp and weapon.tp.scoFaContinuousBeam\n    local expectedSubmeshes = sourceBeam\n        and sourceBeam.sourceId == \"UAA0310\" and 1 or 2\n    if not beamWidthScales or #beam.submeshes ~= expectedSubmeshes then\n        error(\"Czar inner-hole beam-width contract is invalid.\")\n    end\n    for index, submeshId in ipairs(beam.submeshes) do\n        local widthScale = beamWidthScales[index]\n        if type(widthScale) ~= \"number\" or widthScale <= 0 then\n            error(\"Czar beam submesh width is invalid.\")\n        end\n        local beamScale = EngineClasses.float3(\n            widthScale,\n            widthScale,\n            1)\n        if not Engine.IsValidLocalID(submeshId)\n            or Engine.SetMeshRendererScale(submeshId, beamScale)\n                ~= EngineErrorCode.Success\n        then\n            error(\"Czar beam submesh width scaling failed.\")\n        end\n    end\n\n    -- Native beam submeshes own the target-scaled laser shaft.\n    -- Keep only the isolated blue sky-laser contact effect here.\n    beam.projectileTemplate = {}\n    self.scoCzarBeam = beam\n    self.scoCzarImpactEffect = nil\nend\n\nfunction AeonPortCzar:CreateTarmac()\nend\n\nfunction AeonPortCzar:OnPromoteToUnit()\n    ChosenAirUnit.OnPromoteToUnit(self)\nend\n\nfunction AeonPortCzar:OnCompleted()\n    ChosenAirUnit.OnCompleted(self)\nend\n\nfunction AeonPortCzar:IsHighlightable()\n    return ChosenAirUnit.IsHighlightable(self)\nend\n\nfunction AeonPortCzar:IsSelectable()\n    return ChosenAirUnit.IsSelectable(self)\nend\n\nfunction AeonPortCzar:OnIntelHidden()\n    ChosenAirUnit.OnIntelHidden(self)\nend\n\nfunction AeonPortCzar:OnIntelVision()\n    ChosenAirUnit.OnIntelVision(self)\nend\n\nfunction AeonPortCzar:OnIntelRadar()\n    ChosenAirUnit.OnIntelRadar(self)\n    self:RecalculateConstructionBeamState()\nend\n\nfunction AeonPortCzar:ClientOnStopBuilding()\n    local targetUnit = self.buildTarget\n    ChosenAirFactory.ClientOnStopBuilding(self)\n    if targetUnit and not targetUnit:IsCompleted() then\n        targetUnit:SetSelectionEnabled(false)\n        scoCzarSetLocalVolumeColliderEnabled(\n            targetUnit.id,\n            false)\n    end\nend\n\nfunction AeonPortCzar:ScoCzarStartImpactEffect()\n    local impact = scoCzarTerrainImpact(\n        self.scoCzarCenterMuzzle)\n    local _, impactEffect = Engine.InstantiatePrefab(\n        scoCzarImpactPrefab,\n        impact,\n        scoCzarScale,\n        scoCzarImpactRotation)\n    if not Engine.IsValidLocalID(impactEffect) then\n        scoCzarStopEffect(impactEffect)\n        error(\"Czar center-down impact graph failed to instantiate.\")\n    end\n    Engine.SetDestroyUponCompletion(impactEffect, false)\n    Engine.SetParticleCanEmit(impactEffect, true)\n    self.scoCzarImpactEffect = impactEffect\nend\n\nfunction AeonPortCzar:ScoCzarUpdateImpactEffect()\n    local impact = scoCzarTerrainImpact(\n        self.scoCzarCenterMuzzle)\n    Engine.SetLocalEntityLocalPosition(\n        self.scoCzarImpactEffect,\n        impact)\n    Engine.SetLocalEntityLocalRotation(\n        self.scoCzarImpactEffect,\n        scoCzarImpactRotation)\nend\n\nfunction AeonPortCzar:ScoCzarStopImpactEffect()\n    scoCzarStopEffect(self.scoCzarImpactEffect)\n    self.scoCzarImpactEffect = nil\nend\n\nfunction AeonPortCzar:UpdateBeams()\n    ChosenAirUnit.UpdateBeams(self)\n    -- Stock ClientBeam raycasts stop at unit colliders. Replace only\n    -- this Czar's displayed length with the terrain endpoint.\n    scoCzarPinBeamVisualToTerrain(self)\n    local active = self.scoCzarBeam\n        and self.scoCzarBeam.enabled\n        and self:IsIntelVisionVisible()\n    if active then\n        if not self.scoCzarImpactEffect then\n            self:ScoCzarStartImpactEffect()\n        end\n        self:ScoCzarUpdateImpactEffect()\n    elseif self.scoCzarImpactEffect then\n        self:ScoCzarStopImpactEffect()\n    end\nend\n\nfunction AeonPortCzar:RenderUpdateBeams()\n    -- Pin immediately before RenderUpdate writes beam.length into\n    -- renderer instance data, including between simulation ticks.\n    scoCzarPinBeamVisualToTerrain(self)\n    ChosenAirUnit.RenderUpdateBeams(self)\n    if self.scoCzarImpactEffect then\n        self:ScoCzarUpdateImpactEffect()\n    end\nend\n\nfunction AeonPortCzar:OnDestroy(isDelete)\n    self:ScoCzarStopImpactEffect()\n    return ChosenAirFactory.OnDestroy(self, isDelete)\nend\n\nfunction AeonPortCzar:OnDelete()\n    self:ScoCzarStopImpactEffect()\n    return ChosenAirFactory.OnDelete(self)\nend\n\n-- SCO_CzarCrashScorchContact_v1: completed Czar wrecks mark ground at contact.\nfunction AeonPortCzar:CreateRandomScorchmark()\n    if not self:IsCompleted() then\n        return ChosenAirFactory.CreateRandomScorchmark(self)\n    end\nend\n";
	}

	private static void AppendStringArray(StringBuilder builder, string field, IEnumerable<string> values, int indentation)
	{
		string value = new string(' ', indentation);
		builder.Append(value).Append(field).AppendLine(" = {");
		foreach (string value2 in values)
		{
			builder.Append(value).Append("    \"").Append(EscapeLua(value2))
				.AppendLine("\",");
		}
		builder.Append(value).AppendLine("},");
	}

	private static void AppendOptionalNumber(StringBuilder builder, string field, double? value, int indentation)
	{
		if (value.HasValue)
		{
			builder.Append(' ', indentation).Append(field).Append(" = ")
				.Append(Lua(value.Value))
				.AppendLine(",");
		}
	}

	private static void AppendOptionalBoolean(StringBuilder builder, string field, bool? value, int indentation)
	{
		if (value.HasValue)
		{
			builder.Append(' ', indentation).Append(field).Append(" = ")
				.Append(Lua(value.Value))
				.AppendLine(",");
		}
	}

	private static string MakeLuaIdentifier(string value)
	{
		StringBuilder stringBuilder = new StringBuilder(value.Length);
		foreach (char c in value)
		{
			stringBuilder.Append(char.IsLetterOrDigit(c) ? char.ToLowerInvariant(c) : '_');
		}
		if (stringBuilder.Length != 0)
		{
			return stringBuilder.ToString();
		}
		return "clip";
	}

	private static string EscapeLua(string value)
	{
		return value.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "\\r")
			.Replace("\n", "\\n");
	}

	private static string Lua(double value)
	{
		return value.ToString("G17", CultureInfo.InvariantCulture);
	}

	private static string Lua(bool value)
	{
		if (!value)
		{
			return "false";
		}
		return "true";
	}

	private static object GetLuaFileCache()
	{
		Type type = Type.GetType("EM.Lua.FilesCache, Trebuchet", throwOnError: false) ?? throw new TypeLoadException("Loaded Trebuchet does not expose EM.Lua.FilesCache.");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static byte[] LoadEmbeddedTemplate(PatchSpec spec)
	{
		if (!spec.IsTemplateReplacement || string.IsNullOrWhiteSpace(spec.TargetId))
		{
			throw new InvalidOperationException(spec.Description + " is not an embedded template replacement.");
		}
		string suffix = "." + spec.TargetId + "." + spec.TargetId + ".santp";
		Assembly assembly = typeof(CachePatcherRuntime).Assembly;
		string[] array = (from name in assembly.GetManifestResourceNames()
			where name.EndsWith(suffix, StringComparison.OrdinalIgnoreCase)
			select name).ToArray();
		if (array.Length != 1)
		{
			throw new InvalidOperationException($"Expected one embedded {spec.TargetId} donor stub, found {array.Length}.");
		}
		using Stream stream = assembly.GetManifestResourceStream(array[0]) ?? throw new InvalidOperationException("Embedded donor stub " + array[0] + " could not be opened.");
		using MemoryStream memoryStream = new MemoryStream();
		stream.CopyTo(memoryStream);
		return memoryStream.ToArray();
	}

	private static void ValidateInstalledTargetIdentity(PatchSpec spec, byte[] bytes)
	{
		string text = Encoding.UTF8.GetString(bytes);
		int num = text.IndexOf("tpId = \"", StringComparison.Ordinal);
		int num2 = num + "tpId = \"".Length;
		int num3 = ((num < 0) ? (-1) : text.IndexOf('"', num2));
		int num4 = ((num < 0) ? (-1) : text.IndexOf("tpId = \"", num3 + 1, StringComparison.Ordinal));
		string text2 = ((num3 <= num2) ? string.Empty : text.Substring(num2, num3 - num2));
		if (text.IndexOf("UnitTemplate", StringComparison.Ordinal) < 0 || num4 >= 0 || !text2.Equals(spec.TargetId, StringComparison.Ordinal))
		{
			throw new InvalidOperationException("Installed template " + spec.TargetId + " does not have its exact target identity.");
		}
	}

	private static void ValidateEmbeddedScaffoldIdentity(PatchSpec spec, byte[] bytes)
	{
		ValidateInstalledTargetIdentity(spec, bytes);
		string text = Encoding.UTF8.GetString(bytes);
		if (text.IndexOf("ucl0000", StringComparison.OrdinalIgnoreCase) >= 0 || text.IndexOf("UAL0001", StringComparison.OrdinalIgnoreCase) >= 0 || text.IndexOf("-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0", StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("Embedded scaffold " + spec.TargetId + " failed its protected-ACU contract.");
		}
	}

	private static string ResolvePath(string relativePath)
	{
		return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
	}

	private static bool TryGetCachedResource(object cache, PatchSpec spec, out CachedResource resource)
	{
		Type type = cache.GetType();
		PropertyInfo propertyInfo = type.GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(type.FullName, "Item");
		MethodInfo obj = type.GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "ContainsKey");
		string text = ResolvePath(spec.RelativePath);
		if ((bool)obj.Invoke(cache, new object[1] { text }))
		{
			object obj2 = propertyInfo.GetValue(cache, new object[1] { text }) ?? throw new InvalidOperationException("Cached " + spec.Description + " has no value.");
			EnsureNativeArray(obj2, spec.Description);
			resource = new CachedResource(spec, text, obj2);
			return true;
		}
		string value = "/" + spec.RelativePath.Replace('\\', '/');
		string text2 = null;
		object obj3 = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type2 = item.GetType();
			string text3 = (string)type2.GetProperty("Key")?.GetValue(item);
			if (text3 != null && text3.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (text2 != null)
				{
					throw new InvalidOperationException("More than one cache resource matches " + spec.RelativePath + ".");
				}
				text2 = text3;
				obj3 = type2.GetProperty("Value")?.GetValue(item) ?? throw new InvalidOperationException("Cached " + spec.Description + " has no value.");
				EnsureNativeArray(obj3, spec.Description);
			}
		}
		if (text2 == null || obj3 == null)
		{
			resource = null;
			return false;
		}
		resource = new CachedResource(spec, text2, obj3);
		return true;
	}

	private static object AppendOverride(object stockResource, string appendix)
	{
		Type type = stockResource.GetType();
		byte[] nativeArrayBytes = GetNativeArrayBytes(type, stockResource);
		byte[] bytes = Encoding.UTF8.GetBytes(appendix);
		return NativeArrayByteFactory.CreatePersistent(type, nativeArrayBytes, bytes);
	}

	private static object TransformOverride(object stockResource, string appendix, Func<string, string> transform)
	{
		Type type = stockResource.GetType();
		string arg = Encoding.UTF8.GetString(GetNativeArrayBytes(type, stockResource));
		byte[] bytes = Encoding.UTF8.GetBytes(transform(arg));
		byte[] bytes2 = Encoding.UTF8.GetBytes(appendix);
		return NativeArrayByteFactory.CreatePersistent(type, bytes, bytes2);
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static void ValidateAssignedResource(object cache, CachedResource resource)
	{
		object resource2 = ValidateCachedByteIdentity(cache, resource.Path, resource.Replacement, resource.Spec.Description);
		ValidatePatchedResource(resource.Spec, resource2);
	}

	private static object ValidateCachedByteIdentity(object cache, string path, object expectedResource, string description)
	{
		object obj = (cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException("Cached " + description + " has no value after assignment.");
		EnsureNativeArray(obj, description);
		byte[] nativeArrayBytes = GetNativeArrayBytes(expectedResource.GetType(), expectedResource);
		if (!GetNativeArrayBytes(obj.GetType(), obj).SequenceEqual(nativeArrayBytes))
		{
			throw new InvalidOperationException("Cached " + description + " failed byte-identity validation.");
		}
		return obj;
	}

	private static void RollBackAndDispose(object cache, IEnumerable<CachedResource> resources)
	{
		List<Exception> list = new List<Exception>();
		foreach (CachedResource item in resources.Reverse())
		{
			if (item.AssignmentWasAttempted)
			{
				try
				{
					SetCachedResource(cache, item.Path, item.Stock);
					ValidateCachedByteIdentity(cache, item.Path, item.Stock, "restored " + item.Spec.Description);
					item.AssignmentWasAttempted = false;
				}
				catch (Exception innerException)
				{
					list.Add(new InvalidOperationException("Could not restore " + item.Spec.Description + "; the cache may still own its replacement.", innerException));
					continue;
				}
			}
			if (item.Replacement == null)
			{
				continue;
			}
			try
			{
				if (IsNativeArrayCreated(item.Replacement))
				{
					DisposeNativeArray(item.Replacement.GetType(), item.Replacement);
				}
				item.Replacement = null;
			}
			catch (Exception innerException2)
			{
				list.Add(new InvalidOperationException("Could not dispose replacement " + item.Spec.Description + ".", innerException2));
			}
		}
		if (list.Count != 0)
		{
			throw new AggregateException("The Aeon cache rollback was incomplete.", list);
		}
	}

	private static byte[] GetNativeArrayBytes(Type nativeArrayType, object nativeArray)
	{
		return (byte[])(nativeArrayType.GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "ToArray")).Invoke(nativeArray, null);
	}

	private static bool HasOverrideMarker(object resource)
	{
		if (IsNativeArrayCreated(resource))
		{
			return Encoding.UTF8.GetString(GetNativeArrayBytes(resource.GetType(), resource)).IndexOf("-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0", StringComparison.Ordinal) >= 0;
		}
		return false;
	}

	private static void ValidatePatchedResource(PatchSpec spec, object resource)
	{
		EnsureNativeArray(resource, spec.Description);
		string text = NormalizeNewlines(Encoding.UTF8.GetString(GetNativeArrayBytes(resource.GetType(), resource)));
		if (text.Split(new char[1] { '\n' }).Count((string line) => line == "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0") != 1 || CountOccurrences(text, "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0") != 1)
		{
			throw new InvalidOperationException("Patched " + spec.Description + " does not contain exactly one exact marker line.");
		}
		string value = NormalizeNewlines(spec.Appendix);
		if (text.IndexOf(value, StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException("Patched " + spec.Description + " does not match the current generated appendix.");
		}
		if (spec.RelativePath == "LJ/lua/client/entities/clientContinuousBeam.lua")
		{
			string text2 = text.TrimEnd(new char[1] { '\n' });
			int num = text.IndexOf("-- SCO_GalacticColossusTractorClientBeam", StringComparison.Ordinal);
			int num2 = text.LastIndexOf("return { ClientContinuousBeam = ClientContinuousBeam }", StringComparison.Ordinal);
			if (CountOccurrences(text, "return { ClientContinuousBeam = ClientContinuousBeam }") != 1 || num < 0 || num2 <= num || !text2.EndsWith("return { ClientContinuousBeam = ClientContinuousBeam }", StringComparison.Ordinal))
			{
				throw new InvalidOperationException("The tractor client-beam appendix is not inside the Lua module return boundary.");
			}
		}
		if (spec.IsTemplateReplacement)
		{
			byte[] bytes = LoadEmbeddedTemplate(spec);
			ValidateEmbeddedScaffoldIdentity(spec, bytes);
			string value2 = NormalizeNewlines(Encoding.UTF8.GetString(bytes) + spec.Appendix);
			if (!text.StartsWith(value2, StringComparison.Ordinal))
			{
				throw new InvalidOperationException("Patched template " + spec.TargetId + " does not begin with the exact current scaffold replacement.");
			}
		}
		else if (spec.Transform != null && !NormalizeNewlines(spec.Transform(text)).Equals(text, StringComparison.Ordinal))
		{
			throw new InvalidOperationException("Patched " + spec.Description + " fails its transform postcondition.");
		}
	}

	private static string NormalizeNewlines(string value)
	{
		return value.Replace("\r\n", "\n").Replace('\r', '\n');
	}

	private static int CountOccurrences(string source, string value)
	{
		int num = 0;
		int startIndex = 0;
		while ((startIndex = source.IndexOf(value, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += value.Length;
		}
		return num;
	}

	private static void EnsureNativeArray(object value, string description)
	{
		if (!IsNativeArrayCreated(value))
		{
			throw new InvalidOperationException("Cached " + description + " is not an initialized NativeArray.");
		}
	}

	private static bool IsNativeArrayCreated(object nativeArray)
	{
		return (bool)(nativeArray.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(nativeArray.GetType().FullName, "IsCreated")).GetValue(nativeArray);
	}

	private static void TryDisposeNativeArray(Type nativeArrayType, object nativeArray, string description)
	{
		try
		{
			DisposeNativeArray(nativeArrayType, nativeArray);
		}
		catch (Exception arg)
		{
			Log($"Could not dispose {description}: {arg}");
		}
	}

	private static void DisposeNativeArray(Type nativeArrayType, object nativeArray)
	{
		(nativeArrayType.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(nativeArrayType.FullName, "Dispose")).Invoke(nativeArray, null);
	}

	private static void Log(string message)
	{
		string text = "[Aeon Chosen One-for-One Cache Patcher] " + message;
		try
		{
			Console.WriteLine(text);
		}
		catch
		{
		}
		try
		{
			(from assembly in AppDomain.CurrentDomain.GetAssemblies()
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type type) => (object)type != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}

	private static string StripCommanderArrivalCameraModuleReturn(string source)
	{
		source = NormalizeNewlines(source);
		if (source.IndexOf("-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0", StringComparison.Ordinal) >= 0)
		{
			return source;
		}
		string text = source.TrimEnd(new char[1] { '\n' });
		if (CountOccurrences(text, "return {\n    Update = Update,\n    RestartCamera = RestartCamera,\n    SetPlayableArea = SetPlayableArea,\n    SetZoomAmount = SetZoomAmount,\n    SetPanLeft = SetPanLeft,\n    SetPanRight = SetPanRight,\n    SetPanUp = SetPanUp,\n    SetPanDown = SetPanDown,\n    SetCameraPan = SetCameraPan,\n    SetCameraRotation = SetCameraRotation,\n    AddRotationDeltaX = AddRotationDeltaX,\n    AddRotationDeltaY = AddRotationDeltaY,\n    ToggleFreeCamera = ToggleFreeCamera,\n    FitCameraToPositions = FitCameraToPositions,\n}") != 1 || !text.EndsWith("return {\n    Update = Update,\n    RestartCamera = RestartCamera,\n    SetPlayableArea = SetPlayableArea,\n    SetZoomAmount = SetZoomAmount,\n    SetPanLeft = SetPanLeft,\n    SetPanRight = SetPanRight,\n    SetPanUp = SetPanUp,\n    SetPanDown = SetPanDown,\n    SetCameraPan = SetCameraPan,\n    SetCameraRotation = SetCameraRotation,\n    AddRotationDeltaX = AddRotationDeltaX,\n    AddRotationDeltaY = AddRotationDeltaY,\n    ToggleFreeCamera = ToggleFreeCamera,\n    FitCameraToPositions = FitCameraToPositions,\n}", StringComparison.Ordinal))
		{
			throw new InvalidOperationException("The commander arrival camera module return contract changed.");
		}
		return text.Substring(0, text.Length - "return {\n    Update = Update,\n    RestartCamera = RestartCamera,\n    SetPlayableArea = SetPlayableArea,\n    SetZoomAmount = SetZoomAmount,\n    SetPanLeft = SetPanLeft,\n    SetPanRight = SetPanRight,\n    SetPanUp = SetPanUp,\n    SetPanDown = SetPanDown,\n    SetCameraPan = SetCameraPan,\n    SetCameraRotation = SetCameraRotation,\n    AddRotationDeltaX = AddRotationDeltaX,\n    AddRotationDeltaY = AddRotationDeltaY,\n    ToggleFreeCamera = ToggleFreeCamera,\n    FitCameraToPositions = FitCameraToPositions,\n}".Length).TrimEnd(new char[1] { '\n' }) + "\n";
	}

	private static string TransformCommanderArrivalHostMain(string source)
	{
		source = NormalizeNewlines(source);
		if (source.IndexOf("-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0", StringComparison.Ordinal) >= 0)
		{
			if (CountOccurrences(source, "    if SCOHoldCommanderArrival() then\n        SamplingProfiler.NotifyLeavingLua()\n        return\n    end\n\n") != 1)
			{
				throw new InvalidOperationException("Commander arrival host gate is missing or duplicated.");
			}
			return source;
		}
		return ReplaceUnique(ReplaceUnique(source, "    for _, economy in pairs(Economies) do", "    if SCOHoldCommanderArrival() then\n        SamplingProfiler.NotifyLeavingLua()\n        return\n    end\n\n    for _, economy in pairs(Economies) do", "commander arrival host gameplay gate"), "        Import(\"host/survival/survival.lua\").TryStartSurvival()", "        SCOStartSurvival()", "commander arrival survival start");
	}
}
