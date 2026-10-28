using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;

namespace SeraphimFourthFactionCachePatcher;

internal static class SeraphimPortOverrides
{
	private sealed class AnimationEntry
	{
		public string Key { get; }

		public string ClipName { get; }

		public bool IsRun { get; }

		public int? PlaybackMode { get; }

		public double? AuthoredSpeed { get; }

		public AnimationEntry(string key, string clipName, bool isRun, int? playbackMode = null, double? authoredSpeed = null)
		{
			Key = key;
			ClipName = clipName;
			IsRun = isRun;
			PlaybackMode = playbackMode;
			AuthoredSpeed = authoredSpeed;
		}
	}

	private const string MarkerPrefix = "-- Supreme Commander Overhaul Seraphim source gameplay 2.1 ";

	private const string ChosenCommanderProjectileMarker = "-- Supreme Commander Overhaul Seraphim ACU direct-fire projectile pcd121";

	private const string ChosenCommanderManualWeaponSafetyMarker = "-- Supreme Commander Overhaul Seraphim ACU manual special weapons excluded";

	private const string ZthueeSplitAimMarker = "-- Supreme Commander Overhaul Zthuee split yaw/pitch 1.0.0";

	private const string YthothaAimArcMarker = "-- Supreme Commander Overhaul Ythotha source aim arcs 1.0.0";

	private const string IlshavohIndependentArmOverride = "-- Supreme Commander Overhaul Ilshavoh independent arms 1.0.0\n-- FA XSL0202 owns one shared Torso yaw manipulator and independent Right_Arm/Left_Arm\n-- pitch manipulators. RackFireTogether=false is preserved as two ordered muzzle groups.\nlocal ilshavohWeapon = UnitTemplate.weapons and UnitTemplate.weapons[1]\nif not ilshavohWeapon then\n    error(\"Ilshavoh source weapon is missing.\")\nend\nlocal function SCO_IlshavohAimController(aimBone, yawBone, pitchBone)\n    return {\n        aimBone = aimBone,\n        aimTolerance = 1,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = true,\n        pitchBone = pitchBone,\n        pitchMax = 60,\n        pitchMin = -60,\n        pitchSpeed = 60,\n        poseResetTime = 3,\n        projectileSpeed = 30,\n        reduceMuzzleVelocityToTarget = false,\n        solverType = \"LowArc\",\n        yawBone = yawBone,\n        yawMax = 180,\n        yawMin = -180,\n        yawSpeed = 180,\n    }\nend\nilshavohWeapon.aimControllers = {\n    SCO_IlshavohAimController(\"Torso\", \"Torso\", nil),\n    SCO_IlshavohAimController(\"Right_Muzzle\", nil, \"Right_Arm\"),\n    SCO_IlshavohAimController(\"Left_Muzzle\", nil, \"Left_Arm\"),\n}\nilshavohWeapon.muzzleGroups = {\n    { muzzles = { \"Right_Muzzle\" } },\n    { muzzles = { \"Left_Muzzle\" } },\n}\nilshavohWeapon.muzzles = {\n    [\"Right_Muzzle\"] = { aimController = \"Right_Muzzle\" },\n    [\"Left_Muzzle\"] = { aimController = \"Left_Muzzle\" },\n}\nilshavohWeapon.muzzleSalvoDelay = 0\nilshavohWeapon.muzzleSalvoSize = 1";

	private const string YthothaAimArcOverride = "-- Supreme Commander Overhaul Ythotha source aim arcs 1.0.0\n-- XSL0401's body-slaved guns use a narrow forward arc; its two AA mounts use half-turn arcs.\nlocal ythothaAimArcs = {\n    { aim = \"Head\", yaw = \"Head\", pitch = \"Head\", range = 35, speed = 40 },\n    { aim = \"LeftHand_Muzzle\", yaw = \"Left_Arm_B10\", pitch = \"Left_Arm_B07\", range = 35, speed = 50 },\n    { aim = \"RightHand_Muzzle\", yaw = \"Right_Arm_B07\", pitch = \"Right_Arm_B03\", range = 35, speed = 50 },\n    { aim = \"Left_AA_Muzzle\", yaw = \"Left_AA_Turret03\", pitch = \"Left_AA_Turret03\", range = 90, speed = 180 },\n    { aim = \"Right_AA_Muzzle\", yaw = \"Right_AA_Turret02\", pitch = \"Right_AA_Turret02\", range = 90, speed = 180 },\n}\nfor index, sourceArc in ipairs(ythothaAimArcs) do\n    local weapon = UnitTemplate.weapons and UnitTemplate.weapons[index]\n    local controllers = weapon and weapon.aimControllers\n    local controller = controllers and controllers[1]\n    if not controller or #controllers ~= 1\n        or controller.aimBone ~= sourceArc.aim\n        or controller.yawBone ~= sourceArc.yaw\n        or controller.pitchBone ~= sourceArc.pitch\n    then\n        error(\"Ythotha source aim controller \" .. index .. \" drifted.\")\n    end\n    controller.defaultYawAdjustment = 0\n    controller.yawMin = -sourceArc.range\n    controller.yawMax = sourceArc.range\n    controller.yawSpeed = sourceArc.speed\nend\nUnitTemplate.additions.scoYthothaAimArc = {\n    version = \"1.0.0\",\n    sourceId = \"XSL0401\",\n    sourceBlueprintSha256 = \"14f9f8c5566774931c0ebdd308088a3731857b3c2fd373f9cc4a4f01c00c83d4\",\n    controllerCount = 5,\n    rearAimExcluded = true,\n}";

	private const string ChosenCommanderProjectileTemplate = "pcd121";

	private const string ResourceTagContractMarker = "-- Supreme Commander Overhaul Seraphim canonical resource tags 1.0 ";

	private static readonly ISet<string> SupportedMovementTypes = new HashSet<string>(StringComparer.Ordinal) { "LegsLand", "LegsSeabed", "TracksLand", "TracksSeabed", "Hover", "WaterSurface", "Plane", "Gunship" };

	private static readonly IReadOnlyDictionary<string, double> ProgressBoundFactoryUpgradeDurations = new Dictionary<string, double>(StringComparer.Ordinal)
	{
		["uss1511"] = 10.0,
		["uss2511"] = 10.0,
		["uss1512"] = 13.333333015441895,
		["uss2512"] = 13.333333015441895,
		["uss1513"] = 16.66666603088379,
		["uss2513"] = 16.66666603088379
	};

	private static readonly IReadOnlyDictionary<string, string[]> ResourceTagContracts = new Dictionary<string, string[]>(StringComparer.Ordinal)
	{
		["uss1601"] = new string[9] { "ALLOYS_EXTRACTION", "BUILDABLE_BY_T1_ENGINEER", "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "CONSTRUCTION", "ECONOMIC", "STRUCTURE", "TECH1" },
		["uss1602"] = new string[8] { "ALLOYS_STORAGE", "BUILDABLE_BY_T1_ENGINEER", "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "STRUCTURE", "TECH1" },
		["uss1611"] = new string[8] { "BUILDABLE_BY_T1_ENGINEER", "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "ENERGY_PRODUCTION", "STRUCTURE", "TECH1" },
		["uss1612"] = new string[8] { "BUILDABLE_BY_T1_ENGINEER", "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "ENERGY_STORAGE", "STRUCTURE", "TECH1" },
		["uss1614"] = new string[8] { "BUILDABLE_BY_T1_ENGINEER", "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "ENERGY_PRODUCTION", "STRUCTURE", "TECH1" },
		["uss2601"] = new string[8] { "ALLOYS_EXTRACTION", "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "CONSTRUCTION", "ECONOMIC", "STRUCTURE", "TECH2" },
		["uss2611"] = new string[7] { "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "ENERGY_PRODUCTION", "STRUCTURE", "TECH2" },
		["uss2806"] = new string[8] { "BUILDABLE_BY_T2_ENGINEER", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "LAND", "STRUCTURE", "TECH2", "ALLOYS_PRODUCTION", "ECONOMIC" },
		["uss3601"] = new string[6] { "ALLOYS_EXTRACTION", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "STRUCTURE", "TECH3" },
		["uss3603"] = new string[6] { "ALLOYS_PRODUCTION", "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "STRUCTURE", "TECH3" },
		["uss3611"] = new string[6] { "BUILDABLE_BY_T3_ENGINEER", "SERAPHIM", "ECONOMIC", "ENERGY_PRODUCTION", "STRUCTURE", "TECH3" }
	};

	internal static bool IsApplied(string source, string templateId)
	{
		if (source.IndexOf("-- Supreme Commander Overhaul Seraphim source gameplay 2.1 " + templateId, StringComparison.Ordinal) < 0)
		{
			return false;
		}
		GeneratedPortSpec generatedPortSpec = GeneratedPortSpecs.All.SingleOrDefault((GeneratedPortSpec candidate) => string.Equals(candidate.TargetId, templateId, StringComparison.Ordinal));
		if (generatedPortSpec == null)
		{
			return true;
		}
		if (!HasResourceTagContract(source, generatedPortSpec))
		{
			return false;
		}
		if (!HasRadarRotatorBinding(source, generatedPortSpec))
		{
			return false;
		}
		if (string.Equals(generatedPortSpec.TargetId, "usl0000", StringComparison.Ordinal) && (source.IndexOf("-- Supreme Commander Overhaul Seraphim ACU direct-fire projectile pcd121", StringComparison.Ordinal) < 0 || source.IndexOf("-- Supreme Commander Overhaul Seraphim ACU manual special weapons excluded", StringComparison.Ordinal) < 0))
		{
			return false;
		}
		if (string.Equals(generatedPortSpec.TargetId, "usl1101", StringComparison.Ordinal) && source.IndexOf("-- Supreme Commander Overhaul Zthuee split yaw/pitch 1.0.0", StringComparison.Ordinal) < 0)
		{
			return false;
		}
		if (TryGetProgressBoundFactoryUpgradeDuration(generatedPortSpec, out var durationSeconds) && !HasProgressBoundFactoryUpgradeBinding(source, durationSeconds))
		{
			return false;
		}
		if (!HasSourcePlacementBinding(source, generatedPortSpec))
		{
			return false;
		}
		if (HasSourceMovementContract(generatedPortSpec) && !HasSourceMovementBinding(source, generatedPortSpec))
		{
			return false;
		}
		if (!HasConstructionBinding(source, generatedPortSpec))
		{
			return false;
		}
		if (!HasWeaponOriginBinding(source, generatedPortSpec))
		{
			return false;
		}
		if (string.Equals(generatedPortSpec.ClassName, "SeraphimNavalFactory", StringComparison.Ordinal))
		{
			return source.IndexOf("UnitTemplate.general.requiresWaterPlacement = true", StringComparison.Ordinal) >= 0;
		}
		return true;
	}

	internal static string BuildTemplateAppendix(string templateId)
	{
		GeneratedPortSpec generatedPortSpec = GeneratedPortSpecs.All.SingleOrDefault((GeneratedPortSpec candidate) => string.Equals(candidate.TargetId, templateId, StringComparison.Ordinal));
		if (generatedPortSpec == null)
		{
			throw new InvalidOperationException("No generated Seraphim source-rig mapping exists for " + templateId + ".");
		}
		ValidatePort(generatedPortSpec);
		string text = (string.Equals(templateId, "usl0000", StringComparison.Ordinal) ? "-- Supreme Commander Overhaul Seraphim ACU direct-fire projectile pcd121\n-- Supreme Commander Overhaul Seraphim ACU manual special weapons excluded\n" : string.Empty);
		if (generatedPortSpec.Role == "naval")
		{
			text += "UnitTemplate.visuals.display.subBarDisplayScale = UnitTemplate.visuals.display.subBarDisplayScale or { x = 1, y = 1 }\nUnitTemplate.visuals.display.subBarOffSet = UnitTemplate.visuals.display.subBarOffSet or { x = 0, y = 0 }\n";
		}
		if (string.Equals(templateId, "usl1101", StringComparison.Ordinal))
		{
			text += "-- Supreme Commander Overhaul Zthuee split yaw/pitch 1.0.0\n";
		}
		return "\n\n" + BuildTemplateOverride(generatedPortSpec) + "\n-- Supreme Commander Overhaul Seraphim source gameplay 2.1 " + templateId + "\n" + text;
	}

	internal static string EnableClampPlayback(string source)
	{
		int num = source.IndexOf("                animationInfo.playbackMode or AnimationPlaybackMode.Loop,", StringComparison.Ordinal);
		if (num >= 0)
		{
			if (source.IndexOf("                animationInfo.playbackMode or AnimationPlaybackMode.Loop,", num + "                animationInfo.playbackMode or AnimationPlaybackMode.Loop,".Length, StringComparison.Ordinal) >= 0)
			{
				throw new InvalidOperationException("Sanctuary's unit-template loader contains more than one generic animation playback-mode statement; refusing an ambiguous patch.");
			}
			if (source.IndexOf("                AnimationPlaybackMode.Loop,", StringComparison.Ordinal) >= 0)
			{
				throw new InvalidOperationException("Sanctuary's unit-template loader contains both stock and generic animation playback-mode statements; refusing an ambiguous patch.");
			}
			return source;
		}
		int num2 = source.IndexOf("                AnimationPlaybackMode.Loop,", StringComparison.Ordinal);
		if (num2 < 0)
		{
			throw new InvalidOperationException("Sanctuary's unit-template loader no longer contains the expected animation playback-mode statement.");
		}
		if (source.IndexOf("                AnimationPlaybackMode.Loop,", num2 + "                AnimationPlaybackMode.Loop,".Length, StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("Sanctuary's unit-template loader contains more than one animation playback-mode statement; refusing an ambiguous patch.");
		}
		return source.Remove(num2, "                AnimationPlaybackMode.Loop,".Length).Insert(num2, "                animationInfo.playbackMode or AnimationPlaybackMode.Loop,");
	}

	internal static string BuildClassModule(string runtimeSide)
	{
		if (!string.Equals(runtimeSide, "host", StringComparison.Ordinal) && !string.Equals(runtimeSide, "client", StringComparison.Ordinal))
		{
			throw new ArgumentOutOfRangeException("runtimeSide");
		}
		StringBuilder stringBuilder = new StringBuilder();
		string value = (string.Equals(runtimeSide, "host", StringComparison.Ordinal) ? "Host" : "Client");
		stringBuilder.AppendLine("-- Virtual unitsDefaultSeraphim module for the true fourth faction.");
		stringBuilder.AppendLine("-- It subclasses the stock Chosen behavior classes without modifying them.");
		stringBuilder.Append("local chosenDefaults = Import(\"").Append(runtimeSide).AppendLine("/units/unitsClasses/unitsDefaultChosen.lua\")");
		foreach (ClassRoute seraphimClassRoute in CachePatcherRuntime.GetSeraphimClassRoutes())
		{
			stringBuilder.Append("local ").Append(seraphimClassRoute.ChosenClassName).Append(" = chosenDefaults.")
				.Append(value)
				.Append(seraphimClassRoute.ChosenClassName)
				.AppendLine();
		}
		stringBuilder.AppendLine();
		foreach (ClassRoute seraphimClassRoute2 in CachePatcherRuntime.GetSeraphimClassRoutes())
		{
			stringBuilder.Append(value).Append(seraphimClassRoute2.SeraphimClassName).Append(" = Class(\"")
				.Append(seraphimClassRoute2.SeraphimClassName)
				.Append("\", ")
				.Append(seraphimClassRoute2.ChosenClassName)
				.AppendLine(")");
			stringBuilder.Append("local ").Append(seraphimClassRoute2.SeraphimClassName).Append(" = ")
				.Append(value)
				.Append(seraphimClassRoute2.SeraphimClassName)
				.AppendLine();
		}
		if (string.Equals(runtimeSide, "host", StringComparison.Ordinal))
		{
			stringBuilder.AppendLine();
			stringBuilder.AppendLine("local SeraphimOrderTasks = Import(\"common/commonOrders.lua\").OrderTasks");
			stringBuilder.AppendLine("local SeraphimHostOrderManager = Import(\"host/managers/orders/hostOrderManager.lua\")");
			stringBuilder.AppendLine();
			stringBuilder.AppendLine("local function PlaySeraphimAnimation(unit, animationKey, blendTime)");
			stringBuilder.AppendLine("    local animations = unit.tp.visuals and unit.tp.visuals.animations");
			stringBuilder.AppendLine("    local animation = animations and animations[animationKey]");
			stringBuilder.AppendLine("    if animation and animation.id then");
			stringBuilder.AppendLine("        Engine.PlayAnimation(unit.id, animation.id, blendTime or 0.1)");
			stringBuilder.AppendLine("    end");
			stringBuilder.AppendLine("end");
			stringBuilder.AppendLine();
			stringBuilder.AppendLine("function SeraphimNavalUnit:OnStopBeingBuilt()");
			stringBuilder.AppendLine("    ChosenNavalUnit.OnStopBeingBuilt(self)");
			stringBuilder.AppendLine("    PlaySeraphimAnimation(self, \"open\", 0)");
			stringBuilder.AppendLine("end");
			AppendFactoryLifecycleHooks(stringBuilder, "SeraphimLandFactory", "ChosenLandFactory");
			AppendFactoryLifecycleHooks(stringBuilder, "SeraphimAirFactory", "ChosenAirFactory");
			AppendFactoryLifecycleHooks(stringBuilder, "SeraphimNavalFactory", "ChosenNavalFactory");
			AppendNavalFactoryWaterHooks(stringBuilder);
		}
		return stringBuilder.ToString();
	}

	private static void AppendFactoryLifecycleHooks(StringBuilder builder, string seraphimClass, string baseClass)
	{
		builder.AppendLine();
		builder.Append("function ").Append(seraphimClass).AppendLine(":OnStartBuildRoutine(targetUnit)");
		builder.Append("    ").Append(baseClass).AppendLine(".OnStartBuildRoutine(self, targetUnit)");
		builder.AppendLine("end");
		builder.AppendLine();
		builder.Append("function ").Append(seraphimClass).AppendLine(":OnStopBuildRoutine(targetUnit)");
		builder.Append("    ").Append(baseClass).AppendLine(".OnStopBuildRoutine(self, targetUnit)");
		builder.AppendLine("end");
	}

	private static void AppendNavalFactoryWaterHooks(StringBuilder builder)
	{
		builder.AppendLine();
		builder.AppendLine("-- Keep naval factory rollout on submerged cells.  The stock Factory class");
		builder.AppendLine("-- always chooses rollOffPoints[1], which can point onto a shoreline.");
		builder.AppendLine("local SeraphimNavalWaterMargin = 0.05");
		builder.AppendLine();
		builder.AppendLine("local function IsSeraphimNavalWaterPoint(position, waterLevel)");
		builder.AppendLine("    local _, terrainHeight = Engine.SampleTerrainHeight(position)");
		builder.AppendLine("    return terrainHeight < waterLevel - SeraphimNavalWaterMargin");
		builder.AppendLine("end");
		builder.AppendLine();
		builder.AppendLine("local function GetSeraphimNavalRollOffPoints(factory)");
		builder.AppendLine("    local _, hasWater = Engine.HasWater()");
		builder.AppendLine("    if not hasWater then");
		builder.AppendLine("        return nil, nil");
		builder.AppendLine("    end");
		builder.AppendLine();
		builder.AppendLine("    local _, waterLevel = Engine.GetWaterLevel()");
		builder.AppendLine("    local factoryPosition = factory:GetPosition()");
		builder.AppendLine("    local construction = factory.tp and factory.tp.construction");
		builder.AppendLine("    for _, rollOff in ipairs((construction and construction.rollOffPoints) or {}) do");
		builder.AppendLine("        local offset = rollOff.offset");
		builder.AppendLine("        if offset then");
		builder.AppendLine("            local spawnPoint = EngineClasses.float3(");
		builder.AppendLine("                factoryPosition.x + offset.x,");
		builder.AppendLine("                waterLevel,");
		builder.AppendLine("                factoryPosition.z + offset.z");
		builder.AppendLine("            )");
		builder.AppendLine("            local rallyPoint = EngineClasses.float3(");
		builder.AppendLine("                factoryPosition.x + offset.x * 2,");
		builder.AppendLine("                waterLevel,");
		builder.AppendLine("                factoryPosition.z + offset.z * 2");
		builder.AppendLine("            )");
		builder.AppendLine("            if IsSeraphimNavalWaterPoint(spawnPoint, waterLevel)");
		builder.AppendLine("                and IsSeraphimNavalWaterPoint(rallyPoint, waterLevel) then");
		builder.AppendLine("                return spawnPoint, rallyPoint");
		builder.AppendLine("            end");
		builder.AppendLine("        end");
		builder.AppendLine("    end");
		builder.AppendLine();
		builder.AppendLine("    return nil, nil");
		builder.AppendLine("end");
		builder.AppendLine();
		builder.AppendLine("function SeraphimNavalFactory:GetRollOffPoint()");
		builder.AppendLine("    local rollOffPoint = GetSeraphimNavalRollOffPoints(self)");
		builder.AppendLine("    if rollOffPoint then");
		builder.AppendLine("        return rollOffPoint");
		builder.AppendLine("    end");
		builder.AppendLine("    return ChosenNavalFactory.GetRollOffPoint(self)");
		builder.AppendLine("end");
		builder.AppendLine();
		builder.AppendLine("function SeraphimNavalFactory:RollOffUnit(targetUnit)");
		builder.AppendLine("    local source = self.unitBeingBuiltSource or self");
		builder.AppendLine("    local _, fallbackRallyPoint = GetSeraphimNavalRollOffPoints(source)");
		builder.AppendLine("    local rallyPoint = source.rallyPoint");
		builder.AppendLine();
		builder.AppendLine("    if rallyPoint then");
		builder.AppendLine("        local _, hasWater = Engine.HasWater()");
		builder.AppendLine("        if hasWater then");
		builder.AppendLine("            local _, waterLevel = Engine.GetWaterLevel()");
		builder.AppendLine("            if IsSeraphimNavalWaterPoint(rallyPoint, waterLevel) then");
		builder.AppendLine("                rallyPoint = EngineClasses.float3(rallyPoint.x, waterLevel, rallyPoint.z)");
		builder.AppendLine("            else");
		builder.AppendLine("                rallyPoint = nil");
		builder.AppendLine("            end");
		builder.AppendLine("        else");
		builder.AppendLine("            rallyPoint = nil");
		builder.AppendLine("        end");
		builder.AppendLine("    end");
		builder.AppendLine();
		builder.AppendLine("    rallyPoint = rallyPoint or fallbackRallyPoint");
		builder.AppendLine("    if rallyPoint then");
		builder.AppendLine("        SeraphimHostOrderManager.HostIssueOrder(SeraphimOrderTasks.MOVE, { targetUnit }, false, rallyPoint, nil)");
		builder.AppendLine("    end");
		builder.AppendLine("end");
	}

	private static void ValidatePort(GeneratedPortSpec port)
	{
		if (string.IsNullOrWhiteSpace(port.TargetId) || string.IsNullOrWhiteSpace(port.SourceId) || string.IsNullOrWhiteSpace(port.Role) || !port.TargetId.StartsWith("us", StringComparison.Ordinal) || !port.SourceId.StartsWith("XS", StringComparison.Ordinal))
		{
			throw new InvalidOperationException("A generated Seraphim port has invalid source, target, or role identity.");
		}
		if (port.CollisionX <= 0.0 || port.CollisionY <= 0.0 || port.CollisionZ <= 0.0 || port.SelectionX <= 0.0 || port.SelectionZ <= 0.0)
		{
			throw new InvalidOperationException(port.TargetId + " has a non-positive collision or selection envelope.");
		}
		GeneratedPlacementSpec placement = port.Placement;
		if (placement == null || string.IsNullOrWhiteSpace(placement.FootprintSource) || placement.FootprintX <= 0.0 || placement.FootprintZ <= 0.0 || !IsFinite(placement.FootprintX) || !IsFinite(placement.FootprintZ) || !IsFinite(placement.SkirtX) || !IsFinite(placement.SkirtZ) || !IsFinite(placement.SkirtOffsetX) || !IsFinite(placement.SkirtOffsetZ) || (placement.HasSourceSkirt && (placement.SkirtX <= 0.0 || placement.SkirtZ <= 0.0)) || (!placement.HasSourceSkirt && (placement.SkirtX != 0.0 || placement.SkirtZ != 0.0)))
		{
			throw new InvalidOperationException(port.TargetId + " has an invalid source placement contract.");
		}
		if (port.MaxHealth <= 0.0 || port.RegenRate < 0.0)
		{
			throw new InvalidOperationException(port.TargetId + " has an invalid source health contract.");
		}
		if (port.Economy == null || port.Economy.BuildCostMass < 0.0 || port.Economy.BuildCostEnergy < 0.0 || port.Economy.BuildTime <= 0.0 || port.Economy.BuildRate < 0.0 || port.Economy.ProductionMass < 0.0 || port.Economy.ProductionEnergy < 0.0 || port.Economy.MaintenanceMass < 0.0 || port.Economy.MaintenanceEnergy < 0.0 || port.Economy.StorageMass < 0.0 || port.Economy.StorageEnergy < 0.0)
		{
			throw new InvalidOperationException(port.TargetId + " has an invalid source economy contract.");
		}
		if (port.Intel == null || port.Intel.VisionRadius < 0.0 || port.Intel.RadarRadius < 0.0 || port.Intel.SourceWaterVisionRadius < 0.0 || port.Intel.SourceSonarRadius < 0.0 || port.Intel.SourceOmniRadius < 0.0 || port.Intel.SourceRadarStealthRadius < 0.0 || port.Intel.SourceSonarStealthRadius < 0.0 || port.Intel.SourceJammerRadius < 0.0)
		{
			throw new InvalidOperationException(port.TargetId + " has an invalid source intel contract.");
		}
		if (port.Shield != null && (port.Shield.MaxHealth <= 0.0 || port.Shield.RegenRate < 0.0 || port.Shield.RegenStartTime < 0.0 || port.Shield.RechargeTime < 0.0 || port.Shield.Size <= 0.0 || port.Shield.EnergyDrainRechargeTime < 0.0))
		{
			throw new InvalidOperationException(port.TargetId + " has an invalid source shield contract.");
		}
		if (port.AnimationClips == null || !port.AnimationClips.Contains<string>("Rest", StringComparer.Ordinal) || !port.AnimationClips.Contains<string>(port.WalkClip, StringComparer.Ordinal) || (!string.IsNullOrEmpty(port.BuildClip) && !port.AnimationClips.Contains<string>(port.BuildClip, StringComparer.Ordinal)))
		{
			throw new InvalidOperationException(port.TargetId + " has an invalid generated animation mapping.");
		}
		if (port.IsMobile && (!HasSourceMovementContract(port) || port.MovementAcceleration < 0.0 || port.MovementDeceleration < 0.0 || port.MovementRotationSpeed < 0.0 || !SupportedMovementTypes.Contains(port.MovementType)))
		{
			throw new InvalidOperationException(port.TargetId + " has an incomplete or unsupported source movement contract.");
		}
		if (!port.IsMobile && (port.MovementSpeed != 0.0 || port.MovementAcceleration != 0.0 || port.MovementDeceleration != 0.0 || port.MovementRotationSpeed != 0.0 || !string.IsNullOrEmpty(port.MovementType)))
		{
			throw new InvalidOperationException(port.TargetId + " structure unexpectedly owns a movement contract.");
		}
		if (HasSourceWalkContract(port) && (port.AnimationWalkRate <= 0.0 || port.AnimationAuthoredSpeed <= 0.0 || Math.Abs(port.AnimationAuthoredSpeed - port.MovementSpeed / port.AnimationWalkRate) > 1E-12))
		{
			throw new InvalidOperationException(port.TargetId + " has an incomplete or inconsistent source locomotion contract.");
		}
		if (port.WeaponRigs == null)
		{
			throw new InvalidOperationException(port.TargetId + " has no generated weapon-rig collection.");
		}
		GeneratedWeaponRig[] weaponRigs = port.WeaponRigs;
		foreach (GeneratedWeaponRig generatedWeaponRig in weaponRigs)
		{
			if (string.IsNullOrWhiteSpace(generatedWeaponRig.AimBone) || string.IsNullOrWhiteSpace(generatedWeaponRig.YawBone) || string.IsNullOrWhiteSpace(generatedWeaponRig.PitchBone) || generatedWeaponRig.Muzzles == null || generatedWeaponRig.Muzzles.Length == 0 || generatedWeaponRig.Muzzles.Any(string.IsNullOrWhiteSpace) || string.IsNullOrWhiteSpace(generatedWeaponRig.ProjectileTemplate) || string.IsNullOrWhiteSpace(generatedWeaponRig.RangeRingType) || generatedWeaponRig.TargetLayers == null || generatedWeaponRig.TargetLayers.Length == 0 || generatedWeaponRig.TargetLayers.Any(string.IsNullOrWhiteSpace) || string.IsNullOrWhiteSpace(generatedWeaponRig.TargetWaterLimits) || string.IsNullOrWhiteSpace(generatedWeaponRig.SolverType) || generatedWeaponRig.Damage <= 0.0 || generatedWeaponRig.DamageRadius < 0.0 || generatedWeaponRig.RangeMin < 0.0 || generatedWeaponRig.RangeMax <= 0.0 || generatedWeaponRig.RangeMin > generatedWeaponRig.RangeMax || generatedWeaponRig.ReloadTime <= 0.0 || generatedWeaponRig.ProjectileSpeed <= 0.0)
			{
				throw new InvalidOperationException(port.TargetId + " has an incomplete weapon-rig mapping.");
			}
		}
	}

	private static string BuildTemplateOverride(GeneratedPortSpec port)
	{
		double value = (port.Structure ? (0.0 - port.CollisionOffsetX) : port.CollisionOffsetX);
		double value2 = (port.Structure ? (0.0 - port.CollisionOffsetZ) : port.CollisionOffsetZ);
		double value3 = port.CollisionY / 2.0 + port.CollisionOffsetY;
		string text = BuildAnimationOverride(port);
		string text2 = BuildPlacementOverride(port);
		string text3 = BuildDefenceOverride(port);
		string text4 = BuildIntelOverride(port);
		string text5 = BuildWeaponOverride(port) + BuildIlshavohIndependentArmOverride(port) + BuildYthothaAimArcOverride(port);
		string text6 = BuildConstructionOverride(port);
		string text7 = BuildTagOverride(port);
		string text8 = BuildResourceTagContractOverride(port);
		string text9 = BuildEconomyOverride(port);
		string text10 = BuildEnergyGeneratorOverride(port);
		string text11 = (string.Equals(port.ClassName, "SeraphimNavalFactory", StringComparison.Ordinal) ? "UnitTemplate.general.requiresWaterPlacement = true" : string.Empty);
		string text12 = BuildRadarRotatorOverride(port);
		return "-- Apply the audited " + port.SourceId + " gameplay contract to the independent\n-- " + port.TargetId + " template. Health, economy, supported intel, shields,\n-- collision, placement, animation, and weapon metadata come from the source blueprint.\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.meshes = nil\nUnitTemplate.additions.rotators = nil\nUnitTemplate.visuals = UnitTemplate.visuals or {}\nUnitTemplate.visuals.effectsPersistent = nil\nUnitTemplate.visuals.persistantEffects = nil\nUnitTemplate.visuals.effectsWhenActive = nil\nUnitTemplate.visuals.holes = nil\nUnitTemplate.general = UnitTemplate.general or {}\nUnitTemplate.general.class = {\n    \"unitsDefaultSeraphim\",\n    \"" + EscapeLua(port.ClassName) + "\",\n}\nUnitTemplate.general.displayName = \"" + EscapeLua(port.DisplayName) + "\"\nUnitTemplate.general.name = \"" + EscapeLua(port.DisplayName) + "\"\n" + text11 + "\n\nUnitTemplate.collisionInfo = {\n    centerOffset = {\n        x = " + Lua(value) + ",\n        y = " + Lua(value3) + ",\n        z = " + Lua(value2) + ",\n    },\n    collisionSize = {\n        x = " + Lua(port.CollisionX) + ",\n        y = " + Lua(port.CollisionY) + ",\n        z = " + Lua(port.CollisionZ) + ",\n    },\n}\nUnitTemplate.visuals.selection = UnitTemplate.visuals.selection or {}\nUnitTemplate.visuals.selection.size = {\n    x = " + Lua(port.SelectionX) + ",\n    y = " + Lua(port.SelectionZ) + ",\n}\nUnitTemplate.visuals.selection.offset = {\n    x = " + Lua(value) + ",\n    y = " + Lua(value3) + ",\n    z = " + Lua(value2) + ",\n}\nUnitTemplate.additions.selectionHit = {\n    size = {\n        x = " + Lua(port.SelectionX) + ",\n        y = " + Lua(port.SelectionZ) + ",\n    },\n    offset = {\n        x = " + Lua(value) + ",\n        y = " + Lua(value3) + ",\n        z = " + Lua(value2) + ",\n    },\n}\n\n" + text2 + "\n" + text3 + "\n" + text4 + "\n" + text + "\n" + text6 + "\n" + text5 + "\n" + text7 + "\n" + text8 + "\n" + text9 + "\n" + text10 + "\n" + text12 + "\n\nif UnitTemplate.visuals.effectsInstant then\n    for _, effects in pairs(UnitTemplate.visuals.effectsInstant) do\n        for _, effect in ipairs(effects) do\n            effect.boneName = \"Root\"\n        end\n    end\nend";
	}

	private static string BuildPlacementOverride(GeneratedPortSpec port)
	{
		GeneratedPlacementSpec placement = port.Placement;
		string text = (placement.HasSourceSkirt ? ("UnitTemplate.skirtSize = {\n    x = " + Lua(placement.SkirtX) + ",\n    y = " + Lua(placement.SkirtZ) + ",\n}") : "UnitTemplate.skirtSize = nil");
		return "UnitTemplate.footprint = {\n    x = " + Lua(placement.FootprintX) + ",\n    y = " + Lua(placement.FootprintZ) + ",\n}\n" + text;
	}

	private static string BuildDefenceOverride(GeneratedPortSpec port)
	{
		string text = "UnitTemplate.defence = UnitTemplate.defence or {}\nUnitTemplate.defence.health = {\n    max = " + Lua(port.MaxHealth) + ",\n    value = " + Lua(port.MaxHealth) + ",\n    regen = " + Lua(port.RegenRate) + ",\n}";
		GeneratedShieldSpec shield = port.Shield;
		if (shield == null)
		{
			return text + "\nUnitTemplate.defence.shields = nil\nif UnitTemplate.general.toggles then\n    UnitTemplate.general.toggles.Shield = nil\nend";
		}
		double value = shield.Size / 2.0;
		return text + "\nUnitTemplate.general.toggles = UnitTemplate.general.toggles or {}\nUnitTemplate.general.toggles.Shield = true\nlocal seraphimShield = UnitTemplate.defence.shields and UnitTemplate.defence.shields[1] or {}\nUnitTemplate.defence.shields = { seraphimShield }\nseraphimShield.boneName = seraphimShield.boneName or \"Root\"\nseraphimShield.max = " + Lua(shield.MaxHealth) + "\nseraphimShield.value = " + Lua(shield.MaxHealth) + "\nseraphimShield.name = seraphimShield.name or \"Bubble Shield\"\nseraphimShield.offset = { x = 0, y = " + Lua(shield.VerticalOffset) + ", z = 0 }\nseraphimShield.radii = { x = " + Lua(value) + ", y = " + Lua(value) + ", z = " + Lua(value) + " }\nseraphimShield.rechargeHPRatio = 0.5\nseraphimShield.rechargeTime = " + Lua(shield.RechargeTime) + "\nseraphimShield.regen = " + Lua(shield.RegenRate) + "\nseraphimShield.regenDelay = " + Lua(shield.RegenStartTime) + "\nseraphimShield.type = seraphimShield.type or 0";
	}

	private static string BuildRadarRotatorOverride(GeneratedPortSpec port)
	{
		switch (port.TargetId)
		{
		case "uss1701":
			if (!string.Equals(port.SourceId, "XSB3101", StringComparison.Ordinal))
			{
				throw new InvalidOperationException("USS1701 radar rotators require the XSB3101 source contract.");
			}
			return "-- Supreme Commander Overhaul Seraphim radar rotators 1.0 uss1701\n-- FA XSB3101 target speed is preserved; Sanctuary exposes no rotator acceleration field.\nUnitTemplate.additions.rotators = {\n    {\n        boneName = \"Array\",\n        speed = { x = 0, y = 30, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n}";
		case "uss2701":
			if (!string.Equals(port.SourceId, "XSB3201", StringComparison.Ordinal))
			{
				throw new InvalidOperationException("USS2701 radar rotators require the XSB3201 source contract.");
			}
			return "-- Supreme Commander Overhaul Seraphim radar rotators 1.0 uss2701\n-- FA XSB3201 target speeds are preserved; Sanctuary exposes no rotator acceleration field.\nUnitTemplate.additions.rotators = {\n    {\n        boneName = \"Array01\",\n        speed = { x = 0, y = 15, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n    {\n        boneName = \"Array02\",\n        speed = { x = 0, y = 30, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n}";
		case "uss3701":
			if (!string.Equals(port.SourceId, "XSB3104", StringComparison.Ordinal))
			{
				throw new InvalidOperationException("USS3701 radar rotators require the XSB3104 source contract.");
			}
			return "-- Supreme Commander Overhaul Seraphim radar rotators 1.0 uss3701\n-- FA XSB3104 target speeds are preserved; Sanctuary exposes no rotator acceleration field.\nUnitTemplate.additions.rotators = {\n    {\n        boneName = \"Array03\",\n        speed = { x = 0, y = 30, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n    {\n        boneName = \"Array02\",\n        speed = { x = 0, y = -20, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n    {\n        boneName = \"Array01\",\n        speed = { x = 0, y = 10, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n}";
		default:
			return string.Empty;
		}
	}

	private static bool HasRadarRotatorBinding(string source, GeneratedPortSpec port)
	{
		string text = BuildRadarRotatorOverride(port);
		if (text.Length != 0)
		{
			return source.IndexOf(text, StringComparison.Ordinal) >= 0;
		}
		return true;
	}

	private static string BuildIntelOverride(GeneratedPortSpec port)
	{
		StringBuilder stringBuilder = new StringBuilder("UnitTemplate.intel = {}\n");
		if (!(port.Intel.VisionRadius > 0.0) && !(port.TargetId == "uss1614") && !(port.TargetId == "uss1804"))
		{
			_ = port.TargetId == "uss3501";
		}
		stringBuilder.Append("UnitTemplate.intel.visionRadius = ").Append(Lua(port.Intel.VisionRadius)).AppendLine();
		if (port.Intel.RadarRadius > 0.0)
		{
			stringBuilder.Append("UnitTemplate.intel.radarRadius = ").Append(Lua(port.Intel.RadarRadius)).AppendLine();
		}
		return stringBuilder.ToString().TrimEnd(Array.Empty<char>());
	}

	private static string BuildAnimationOverride(GeneratedPortSpec port)
	{
		double durationSeconds;
		bool flag = TryGetProgressBoundFactoryUpgradeDuration(port, out durationSeconds);
		bool flag2 = HasSourceWalkContract(port);
		bool flag3 = HasSourceMovementContract(port);
		List<AnimationEntry> list = new List<AnimationEntry>
		{
			new AnimationEntry("walk", port.WalkClip, isRun: false)
		};
		HashSet<string> hashSet = new HashSet<string>(StringComparer.Ordinal) { port.WalkClip };
		if (flag2)
		{
			double? authoredSpeed = port.AnimationAuthoredSpeed;
			list.Add(new AnimationEntry("run", "AnimWalk", isRun: true, null, authoredSpeed));
			hashSet.Add("AnimWalk");
		}
		if (!string.IsNullOrEmpty(port.BuildClip) && !string.Equals(port.Role, "factory", StringComparison.Ordinal))
		{
			list.Add(new AnimationEntry("build", port.BuildClip, isRun: false));
			hashSet.Add(port.BuildClip);
		}
		if (string.Equals(port.Role, "naval", StringComparison.Ordinal) && port.AnimationClips.Contains<string>("AnimOpen", StringComparer.Ordinal))
		{
			list.Add(new AnimationEntry("open", "AnimOpen", isRun: false, 0));
			hashSet.Add("AnimOpen");
		}
		Dictionary<string, int> dictionary = new Dictionary<string, int>(StringComparer.Ordinal);
		string[] animationClips = port.AnimationClips;
		foreach (string text in animationClips)
		{
			if (hashSet.Add(text))
			{
				string text2 = "source_" + MakeLuaIdentifier(text);
				dictionary.TryGetValue(text2, out var value);
				dictionary[text2] = value + 1;
				string text3 = ((value == 0) ? text2 : (text2 + "_" + (value + 1).ToString(CultureInfo.InvariantCulture)));
				bool flag4 = flag && string.Equals(text, "AnimUpgrade", StringComparison.Ordinal) && string.Equals(text3, "source_animupgrade", StringComparison.Ordinal);
				list.Add(new AnimationEntry(text3, text, isRun: false, flag4 ? new int?(0) : ((int?)null)));
			}
		}
		StringBuilder stringBuilder = new StringBuilder();
		if (port.IsMobile)
		{
			stringBuilder.AppendLine("UnitTemplate.movement = UnitTemplate.movement or {}");
			stringBuilder.AppendLine("UnitTemplate.movement.animClips = nil");
			if (flag3)
			{
				stringBuilder.Append("UnitTemplate.movement.type = \"").Append(EscapeLua(port.MovementType)).AppendLine("\"");
				stringBuilder.Append("UnitTemplate.movement.speed = ").Append(Lua(port.MovementSpeed)).AppendLine();
				stringBuilder.Append("UnitTemplate.movement.acceleration = ").Append(Lua(port.MovementAcceleration)).AppendLine();
				if (port.MovementDeceleration > 0.0)
				{
					stringBuilder.Append("UnitTemplate.movement.deceleration = ").Append(Lua(port.MovementDeceleration)).AppendLine();
				}
				stringBuilder.Append("UnitTemplate.movement.rotationSpeed = ").Append(Lua(port.MovementRotationSpeed)).AppendLine();
				stringBuilder.AppendLine(BuildMovementEnvironmentOverride(port));
				if (flag2)
				{
					stringBuilder.AppendLine("UnitTemplate.movement.walkAnimation = UnitTemplate.movement.walkAnimation or {}");
					stringBuilder.Append("UnitTemplate.movement.walkAnimation.authoredSpeed = ").Append(Lua(port.AnimationAuthoredSpeed)).AppendLine();
				}
			}
		}
		stringBuilder.AppendLine("UnitTemplate.visuals.animations = {");
		foreach (AnimationEntry item in list)
		{
			stringBuilder.Append("    ").Append(item.Key).AppendLine(" = {");
			if (item.IsRun)
			{
				stringBuilder.AppendLine("        startSpeed = 0.05,");
			}
			if (item.AuthoredSpeed.HasValue)
			{
				stringBuilder.Append("        authoredSpeed = ").Append(Lua(item.AuthoredSpeed.Value)).AppendLine(",");
			}
			if (item.PlaybackMode.HasValue)
			{
				stringBuilder.Append("        playbackMode = ").Append(item.PlaybackMode.Value).AppendLine(",");
			}
			stringBuilder.Append("        clipName = \"").Append(EscapeLua(item.ClipName)).AppendLine("\",");
			stringBuilder.Append("        sanAnimationPath = \"Units/").Append(port.TargetId).Append("/LOD0/")
				.Append(port.TargetId)
				.AppendLine(".sananimation\",");
			stringBuilder.AppendLine("    },");
		}
		stringBuilder.Append('}');
		if (flag)
		{
			stringBuilder.AppendLine();
			stringBuilder.AppendLine("UnitTemplate.additions = UnitTemplate.additions or {}");
			stringBuilder.AppendLine("UnitTemplate.additions.progressBoundUpgradeAnimation = {");
			stringBuilder.AppendLine("    animationKey = \"source_animupgrade\",");
			stringBuilder.Append("    durationSeconds = ").Append(Lua(durationSeconds)).AppendLine(",");
			stringBuilder.AppendLine("    restAnimationKey = \"walk\",");
			stringBuilder.Append('}');
		}
		return stringBuilder.ToString();
	}

	private static string BuildMovementEnvironmentOverride(GeneratedPortSpec port)
	{
		string text = (port.MovementLarge ? "Large" : "Small");
		string text2 = "Land" + text;
		string text3 = "Seabed" + text;
		switch (port.MovementType)
		{
		case "TracksLand":
		case "LegsLand":
			return "UnitTemplate.movement.air = nil\nUnitTemplate.movement.airHover = nil\nUnitTemplate.movement.minSpeed = nil\nUnitTemplate.movement.landWhenIdleSeconds = nil\nUnitTemplate.movement.altitudeJitterFactor = 0\nUnitTemplate.movement.bankFactor = 0\nUnitTemplate.movement.orbitRange = 0\nUnitTemplate.movement.orbitSpeed = 0\nUnitTemplate.movement.collisionMaskDefault = { \"" + text2 + "\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"" + text2 + "\" }\nUnitTemplate.movement.referenceAltitude = \"Ground\"\nUnitTemplate.movement.preferredAltitude = 0\nUnitTemplate.movement.terrainAlignmentFactor = 1\nUnitTemplate.movement.elevation = nil\nUnitTemplate.movement.continuous = nil";
		case "Hover":
			return "UnitTemplate.movement.air = nil\nUnitTemplate.movement.airHover = nil\nUnitTemplate.movement.minSpeed = nil\nUnitTemplate.movement.landWhenIdleSeconds = nil\nUnitTemplate.movement.altitudeJitterFactor = 0\nUnitTemplate.movement.bankFactor = 0\nUnitTemplate.movement.orbitRange = 0\nUnitTemplate.movement.orbitSpeed = 0\nUnitTemplate.movement.collisionMaskDefault = { \"" + text2 + "\", \"Sea\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"" + text2 + "\", \"Sea\" }\nUnitTemplate.movement.referenceAltitude = \"GroundOrWater\"\nUnitTemplate.movement.preferredAltitude = " + Lua(port.MovementElevation) + "\nUnitTemplate.movement.terrainAlignmentFactor = 0\nUnitTemplate.movement.elevation = nil\nUnitTemplate.movement.continuous = nil";
		case "LegsSeabed":
		case "TracksSeabed":
			return "UnitTemplate.movement.air = nil\nUnitTemplate.movement.airHover = nil\nUnitTemplate.movement.minSpeed = nil\nUnitTemplate.movement.landWhenIdleSeconds = nil\nUnitTemplate.movement.altitudeJitterFactor = 0\nUnitTemplate.movement.bankFactor = 0\nUnitTemplate.movement.orbitRange = 0\nUnitTemplate.movement.orbitSpeed = 0\nUnitTemplate.movement.collisionMaskDefault = { \"" + text3 + "\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"" + text3 + "\" }\nUnitTemplate.movement.referenceAltitude = \"Ground\"\nUnitTemplate.movement.preferredAltitude = 0\nUnitTemplate.movement.terrainAlignmentFactor = 1\nUnitTemplate.movement.elevation = nil\nUnitTemplate.movement.continuous = nil";
		case "WaterSurface":
			return "UnitTemplate.movement.air = nil\nUnitTemplate.movement.airHover = nil\nUnitTemplate.movement.minSpeed = nil\nUnitTemplate.movement.landWhenIdleSeconds = nil\nUnitTemplate.movement.altitudeJitterFactor = 0\nUnitTemplate.movement.bankFactor = 0\nUnitTemplate.movement.orbitRange = 0\nUnitTemplate.movement.orbitSpeed = 0\nUnitTemplate.movement.collisionMaskDefault = { \"Sea\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"Sea\" }\nUnitTemplate.movement.referenceAltitude = \"GroundOrWater\"\nUnitTemplate.movement.preferredAltitude = 0\nUnitTemplate.movement.terrainAlignmentFactor = 0\nUnitTemplate.movement.elevation = nil\nUnitTemplate.movement.continuous = nil";
		case "UnderWater":
			return "UnitTemplate.movement.air = nil\nUnitTemplate.movement.airHover = nil\nUnitTemplate.movement.minSpeed = nil\nUnitTemplate.movement.landWhenIdleSeconds = nil\nUnitTemplate.movement.altitudeJitterFactor = 0\nUnitTemplate.movement.bankFactor = 0\nUnitTemplate.movement.orbitRange = 0\nUnitTemplate.movement.orbitSpeed = 0\nUnitTemplate.movement.collisionMaskDefault = { \"Submarine\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"Submarine\" }\nUnitTemplate.movement.referenceAltitude = \"Water\"\nUnitTemplate.movement.preferredAltitude = " + Lua(port.MovementElevation) + "\nUnitTemplate.movement.terrainAlignmentFactor = 0\nUnitTemplate.movement.elevation = nil\nUnitTemplate.movement.continuous = nil";
		case "Plane":
		case "Gunship":
		{
			double num = ((port.MovementAirHover || port.MovementMinSpeed <= 0.0) ? port.MovementSpeed : port.MovementMinSpeed);
			double num2 = port.MovementRotationSpeed * Math.PI / 180.0;
			double value = ((num2 > 0.0) ? (num / num2) : 0.0);
			return "UnitTemplate.movement.air = true\nUnitTemplate.movement.airHover = " + (port.MovementAirHover ? "true" : "false") + "\nUnitTemplate.movement.minSpeed = " + Lua(port.MovementMinSpeed) + "\nUnitTemplate.movement.landWhenIdleSeconds = 5\nUnitTemplate.movement.altitudeJitterFactor = 1\nUnitTemplate.movement.bankFactor = " + Lua((!port.MovementAirHover) ? 1 : 0) + "\nUnitTemplate.movement.orbitRange = " + Lua(value) + "\nUnitTemplate.movement.orbitSpeed = " + Lua(num) + "\nUnitTemplate.movement.collisionMaskDefault = { \"Air\" }\nUnitTemplate.movement.collisionMaskSpawn = { \"" + text2 + "\" }\nUnitTemplate.movement.referenceAltitude = \"GroundOrWater\"\nUnitTemplate.movement.preferredAltitude = " + Lua(port.MovementElevation) + "\nUnitTemplate.movement.terrainAlignmentFactor = 0\nUnitTemplate.movement.elevation = nil\nUnitTemplate.movement.continuous = nil";
		}
		default:
			throw new InvalidOperationException("Unsupported Seraphim movement type " + port.MovementType + " for " + port.SourceId + ".");
		}
	}

	private static bool HasSourceWalkContract(GeneratedPortSpec port)
	{
		if (port.IsMobile)
		{
			return port.AnimationClips.Contains<string>("AnimWalk", StringComparer.Ordinal);
		}
		return false;
	}

	private static bool HasSourceMovementContract(GeneratedPortSpec port)
	{
		if (port.IsMobile && port.MovementSpeed > 0.0)
		{
			return !string.IsNullOrEmpty(port.MovementType);
		}
		return false;
	}

	private static bool IsFinite(double value)
	{
		if (!double.IsNaN(value))
		{
			return !double.IsInfinity(value);
		}
		return false;
	}

	private static bool HasSourceMovementBinding(string source, GeneratedPortSpec port)
	{
		int num = source.LastIndexOf("-- Apply the audited ", StringComparison.Ordinal);
		if (num < 0)
		{
			return false;
		}
		string binding = source.Substring(num);
		string text = Lua(port.AnimationAuthoredSpeed);
		if ((from line in BuildMovementEnvironmentOverride(port).Split(new char[2] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries)
			select line.Trim() into line
			where line.Length > 0
			select line).All((string line) => binding.IndexOf(line, StringComparison.Ordinal) >= 0) && binding.IndexOf("UnitTemplate.movement.type = \"" + port.MovementType + "\"", StringComparison.Ordinal) >= 0 && binding.IndexOf("UnitTemplate.movement.speed = " + Lua(port.MovementSpeed), StringComparison.Ordinal) >= 0 && binding.IndexOf("UnitTemplate.movement.acceleration = " + Lua(port.MovementAcceleration), StringComparison.Ordinal) >= 0 && ((port.MovementDeceleration > 0.0) ? (binding.IndexOf("UnitTemplate.movement.deceleration = " + Lua(port.MovementDeceleration), StringComparison.Ordinal) >= 0) : (binding.IndexOf("UnitTemplate.movement.deceleration =", StringComparison.Ordinal) < 0)) && binding.IndexOf("UnitTemplate.movement.rotationSpeed = " + Lua(port.MovementRotationSpeed), StringComparison.Ordinal) >= 0)
		{
			if (HasSourceWalkContract(port))
			{
				if (binding.IndexOf("UnitTemplate.movement.walkAnimation.authoredSpeed = " + text, StringComparison.Ordinal) >= 0 && binding.IndexOf("run = {", StringComparison.Ordinal) >= 0)
				{
					return binding.IndexOf("authoredSpeed = " + text + ",", StringComparison.Ordinal) >= 0;
				}
				return false;
			}
			return true;
		}
		return false;
	}

	private static bool HasSourcePlacementBinding(string source, GeneratedPortSpec port)
	{
		int num = source.LastIndexOf("-- Apply the audited ", StringComparison.Ordinal);
		if (num < 0)
		{
			return false;
		}
		string binding = source.Substring(num);
		return (from line in BuildPlacementOverride(port).Split(new char[2] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries)
			select line.Trim() into line
			where line.Length > 0
			select line).All((string line) => binding.IndexOf(line, StringComparison.Ordinal) >= 0);
	}

	private static bool TryGetProgressBoundFactoryUpgradeDuration(GeneratedPortSpec port, out double durationSeconds)
	{
		durationSeconds = 0.0;
		if (string.Equals(port.Role, "factory", StringComparison.Ordinal) && port.AnimationClips.Contains<string>("AnimUpgrade", StringComparer.Ordinal))
		{
			return ProgressBoundFactoryUpgradeDurations.TryGetValue(port.TargetId, out durationSeconds);
		}
		return false;
	}

	private static bool HasProgressBoundFactoryUpgradeBinding(string source, double durationSeconds)
	{
		if (source.IndexOf("progressBoundUpgradeAnimation = {", StringComparison.Ordinal) >= 0 && source.IndexOf("animationKey = \"source_animupgrade\"", StringComparison.Ordinal) >= 0 && source.IndexOf("durationSeconds = " + Lua(durationSeconds), StringComparison.Ordinal) >= 0)
		{
			return source.IndexOf("restAnimationKey = \"walk\"", StringComparison.Ordinal) >= 0;
		}
		return false;
	}

	private static string BuildWeaponOverride(GeneratedPortSpec port)
	{
		GeneratedWeaponRig[] runtimeWeaponRigs = GetRuntimeWeaponRigs(port);
		StringBuilder stringBuilder = new StringBuilder();
		string value = string.Join(", ", from layer in OriginLayers(port)
			select "\"" + EscapeLua(layer) + "\"");
		GeneratedWeaponRig[] array = runtimeWeaponRigs;
		foreach (GeneratedWeaponRig generatedWeaponRig in array)
		{
			string value2 = (UsesChosenCommanderProjectile(port, generatedWeaponRig) ? "pcd121" : generatedWeaponRig.ProjectileTemplate);
			bool num2 = IsT1MobileArtillery(port, generatedWeaponRig);
			string value3 = (num2 ? "Turret_Barrel" : generatedWeaponRig.PitchBone);
			stringBuilder.Append("    { aim = \"").Append(EscapeLua(generatedWeaponRig.AimBone)).Append("\", yaw = \"")
				.Append(EscapeLua(generatedWeaponRig.YawBone))
				.Append("\", pitch = \"")
				.Append(EscapeLua(value3))
				.Append("\", muzzles = { ")
				.Append(string.Join(", ", generatedWeaponRig.Muzzles.Select((string muzzle) => "\"" + EscapeLua(muzzle) + "\"")))
				.Append(" }, projectile = \"")
				.Append(EscapeLua(value2))
				.Append("\", rangeRingType = \"")
				.Append(EscapeLua(generatedWeaponRig.RangeRingType))
				.Append("\", layers = { ")
				.Append(string.Join(", ", generatedWeaponRig.TargetLayers.Select((string layer) => "\"" + EscapeLua(layer) + "\"")))
				.Append(" }, weaponLayers = { ")
				.Append(value)
				.Append(" }, targetWaterLimits = \"")
				.Append(EscapeLua(generatedWeaponRig.TargetWaterLimits))
				.Append("\", solverType = \"")
				.Append(EscapeLua(generatedWeaponRig.SolverType))
				.Append("\", damage = ")
				.Append(Lua(generatedWeaponRig.Damage))
				.Append(" , damageRadius = ")
				.Append(Lua(generatedWeaponRig.DamageRadius))
				.Append(" , rangeMin = ")
				.Append(Lua(generatedWeaponRig.RangeMin))
				.Append(" , rangeMax = ")
				.Append(Lua(generatedWeaponRig.RangeMax))
				.Append(" , reloadTime = ")
				.Append(Lua(generatedWeaponRig.ReloadTime))
				.Append(" , projectileSpeed = ")
				.Append(Lua(generatedWeaponRig.ProjectileSpeed));
			if (num2)
			{
				stringBuilder.Append(", defaultPitchAdjustment = 45, t1ArtilleryArc = true");
			}
			stringBuilder.AppendLine(" },");
		}
		if (runtimeWeaponRigs.Length == 0)
		{
			return "if UnitTemplate.weapons then\n    local seraphimDeathWeapons = {}\n    for _, weapon in ipairs(UnitTemplate.weapons) do\n        if weapon.category == \"DeathExplosion\" then\n            table.insert(seraphimDeathWeapons, weapon)\n        end\n    end\n    UnitTemplate.weapons = #seraphimDeathWeapons > 0 and seraphimDeathWeapons or nil\nend";
		}
		return "local seraphimWeaponRigs = {\n" + stringBuilder.ToString().TrimEnd('\r', '\n') + "\n}\nlocal function ApplySeraphimWeaponRig(combatWeapon, rig)\n    local aimController = combatWeapon.aimControllers and combatWeapon.aimControllers[1] or {}\n    combatWeapon.aimControllers = { aimController }\n    aimController.aimBone = rig.aim\n    aimController.yawBone = rig.yaw\n    aimController.pitchBone = rig.pitch\n    aimController.aimTolerance = aimController.aimTolerance or 0.2\n    aimController.defaultPitchAdjustment = rig.defaultPitchAdjustment or aimController.defaultPitchAdjustment or 0\n    aimController.defaultYawAdjustment = aimController.defaultYawAdjustment or 0\n    aimController.leadTarget = aimController.leadTarget ~= false\n    aimController.pitchMax = aimController.pitchMax or 45\n    aimController.pitchMin = aimController.pitchMin or -25\n    aimController.pitchSpeed = aimController.pitchSpeed or 60\n    aimController.poseResetTime = aimController.poseResetTime or 3\n    aimController.projectileSpeed = rig.projectileSpeed\n    aimController.solverType = rig.solverType\n    if rig.t1ArtilleryArc then\n        aimController.aimGravity = { x = 0, y = -4.9, z = 0 }\n        aimController.leadTarget = false\n        aimController.reduceMuzzleVelocityToTarget = true\n    end\n    aimController.yawMax = aimController.yawMax or 180\n    aimController.yawMin = aimController.yawMin or -180\n    aimController.yawSpeed = aimController.yawSpeed or 60\n    combatWeapon.damage = rig.damage\n    combatWeapon.damageRadius = rig.damageRadius\n    combatWeapon.damageType = combatWeapon.damageType or \"Normal\"\n    combatWeapon.layerTargetLimits = rig.layers\n    combatWeapon.layerWeaponLimits = rig.weaponLayers\n    combatWeapon.muzzleGroups = {\n        { muzzles = rig.muzzles },\n    }\n    combatWeapon.projectileTemplate = rig.projectile\n    combatWeapon.rangeMax = rig.rangeMax\n    combatWeapon.rangeMin = rig.rangeMin\n    combatWeapon.rangeRingType = rig.rangeRingType\n    combatWeapon.reloadTime = rig.reloadTime\n    if rig.t1ArtilleryArc then\n        combatWeapon.projectileLifetime = 20\n    end\n    combatWeapon.targetWaterLimits = rig.targetWaterLimits\n    combatWeapon.muzzles = {}\n    for _, muzzleBone in ipairs(rig.muzzles) do\n        combatWeapon.muzzles[muzzleBone] = { aimController = rig.aim }\n    end\nend\n\nlocal function CreateSeraphimFallbackWeapon(rig)\n    local combatWeapon = {\n        aimControllers = {\n            {\n                aimBone = rig.aim,\n                aimTolerance = 0.2,\n                defaultPitchAdjustment = rig.defaultPitchAdjustment or 0,\n                defaultYawAdjustment = 0,\n                leadTarget = true,\n                pitchBone = rig.pitch,\n                pitchMax = 45,\n                pitchMin = -25,\n                pitchSpeed = 60,\n                poseResetTime = 3,\n                projectileSpeed = rig.projectileSpeed,\n                solverType = rig.solverType,\n                yawBone = rig.yaw,\n                yawMax = 180,\n                yawMin = -180,\n                yawSpeed = 60,\n            },\n        },\n        damage = rig.damage,\n        damageRadius = rig.damageRadius,\n        damageType = \"Normal\",\n        effects = {\n            onFire = \"VFX/Muzzle/vcm1101_cannon_plasma_small_muzzle.sanvfx\",\n        },\n        firingRandomness = 0,\n        layerTargetLimits = rig.layers,\n        layerWeaponLimits = rig.weaponLayers,\n        muzzleGroupChargeDelay = 0,\n        muzzleGroupTimeOut = -1,\n        muzzleGroups = {\n            { muzzles = rig.muzzles },\n        },\n        muzzleSalvoDelay = 0.1,\n        muzzleSalvoSize = #rig.muzzles,\n        projectileLifetime = 8,\n        projectileTemplate = rig.projectile,\n        rangeMax = rig.rangeMax,\n        rangeMin = rig.rangeMin,\n        rangeRingType = rig.rangeRingType,\n        rangeTracking = 1.1,\n        reloadTime = rig.reloadTime,\n        targetWaterLimits = rig.targetWaterLimits,\n        muzzles = {},\n    }\n    for _, muzzleBone in ipairs(rig.muzzles) do\n        combatWeapon.muzzles[muzzleBone] = { aimController = rig.aim }\n    end\n    return combatWeapon\nend\n\nlocal seraphimDonorCombatWeapons = {}\nlocal seraphimDeathWeapons = {}\nfor _, weapon in ipairs(UnitTemplate.weapons or {}) do\n    if weapon.category == \"DeathExplosion\" then\n        table.insert(seraphimDeathWeapons, weapon)\n    else\n        table.insert(seraphimDonorCombatWeapons, weapon)\n    end\nend\n\nlocal seraphimWeapons = {}\nfor rigIndex, rig in ipairs(seraphimWeaponRigs) do\n    local combatWeapon = seraphimDonorCombatWeapons[rigIndex]\n        or CreateSeraphimFallbackWeapon(rig)\n    ApplySeraphimWeaponRig(combatWeapon, rig)\n    table.insert(seraphimWeapons, combatWeapon)\nend\nfor _, deathWeapon in ipairs(seraphimDeathWeapons) do\n    table.insert(seraphimWeapons, deathWeapon)\nend\nUnitTemplate.weapons = #seraphimWeapons > 0 and seraphimWeapons or nil";
	}

	private static string BuildIlshavohIndependentArmOverride(GeneratedPortSpec port)
	{
		if (!string.Equals(port.TargetId, "usl2002", StringComparison.Ordinal))
		{
			return string.Empty;
		}
		GeneratedWeaponRig[] runtimeWeaponRigs = GetRuntimeWeaponRigs(port);
		if (!string.Equals(port.SourceId, "XSL0202", StringComparison.Ordinal) || runtimeWeaponRigs.Length != 1 || !string.Equals(runtimeWeaponRigs[0].AimBone, "Right_Muzzle", StringComparison.Ordinal) || !string.Equals(runtimeWeaponRigs[0].YawBone, "Torso", StringComparison.Ordinal) || !string.Equals(runtimeWeaponRigs[0].PitchBone, "Right_Arm", StringComparison.Ordinal) || !runtimeWeaponRigs[0].Muzzles.SequenceEqual<string>(new string[2] { "Right_Muzzle", "Left_Muzzle" }, StringComparer.Ordinal))
		{
			throw new InvalidOperationException("USL2002 no longer matches the reviewed XSL0202 dual-manipulator source rig.");
		}
		return "\n-- Supreme Commander Overhaul Ilshavoh independent arms 1.0.0\n-- FA XSL0202 owns one shared Torso yaw manipulator and independent Right_Arm/Left_Arm\n-- pitch manipulators. RackFireTogether=false is preserved as two ordered muzzle groups.\nlocal ilshavohWeapon = UnitTemplate.weapons and UnitTemplate.weapons[1]\nif not ilshavohWeapon then\n    error(\"Ilshavoh source weapon is missing.\")\nend\nlocal function SCO_IlshavohAimController(aimBone, yawBone, pitchBone)\n    return {\n        aimBone = aimBone,\n        aimTolerance = 1,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = true,\n        pitchBone = pitchBone,\n        pitchMax = 60,\n        pitchMin = -60,\n        pitchSpeed = 60,\n        poseResetTime = 3,\n        projectileSpeed = 30,\n        reduceMuzzleVelocityToTarget = false,\n        solverType = \"LowArc\",\n        yawBone = yawBone,\n        yawMax = 180,\n        yawMin = -180,\n        yawSpeed = 180,\n    }\nend\nilshavohWeapon.aimControllers = {\n    SCO_IlshavohAimController(\"Torso\", \"Torso\", nil),\n    SCO_IlshavohAimController(\"Right_Muzzle\", nil, \"Right_Arm\"),\n    SCO_IlshavohAimController(\"Left_Muzzle\", nil, \"Left_Arm\"),\n}\nilshavohWeapon.muzzleGroups = {\n    { muzzles = { \"Right_Muzzle\" } },\n    { muzzles = { \"Left_Muzzle\" } },\n}\nilshavohWeapon.muzzles = {\n    [\"Right_Muzzle\"] = { aimController = \"Right_Muzzle\" },\n    [\"Left_Muzzle\"] = { aimController = \"Left_Muzzle\" },\n}\nilshavohWeapon.muzzleSalvoDelay = 0\nilshavohWeapon.muzzleSalvoSize = 1";
	}

	private static string BuildYthothaAimArcOverride(GeneratedPortSpec port)
	{
		if (!string.Equals(port.TargetId, "usl4004", StringComparison.Ordinal))
		{
			return string.Empty;
		}
		GeneratedWeaponRig[] runtimeWeaponRigs = GetRuntimeWeaponRigs(port);
		if (!string.Equals(port.SourceId, "XSL0401", StringComparison.Ordinal) || runtimeWeaponRigs.Length != 5 || !MatchesSingleMuzzleRig(runtimeWeaponRigs[0], "Head", "Head", "Head", "Head") || !MatchesSingleMuzzleRig(runtimeWeaponRigs[1], "LeftHand_Muzzle", "Left_Arm_B10", "Left_Arm_B07", "LeftHand_Muzzle") || !MatchesSingleMuzzleRig(runtimeWeaponRigs[2], "RightHand_Muzzle", "Right_Arm_B07", "Right_Arm_B03", "RightHand_Muzzle") || !MatchesSingleMuzzleRig(runtimeWeaponRigs[3], "Left_AA_Muzzle", "Left_AA_Turret03", "Left_AA_Turret03", "Left_AA_Muzzle") || !MatchesSingleMuzzleRig(runtimeWeaponRigs[4], "Right_AA_Muzzle", "Right_AA_Turret02", "Right_AA_Turret02", "Right_AA_Muzzle"))
		{
			throw new InvalidOperationException("USL4004 no longer matches the reviewed XSL0401 aim-controller layout.");
		}
		return "\n-- Supreme Commander Overhaul Ythotha source aim arcs 1.0.0\n-- XSL0401's body-slaved guns use a narrow forward arc; its two AA mounts use half-turn arcs.\nlocal ythothaAimArcs = {\n    { aim = \"Head\", yaw = \"Head\", pitch = \"Head\", range = 35, speed = 40 },\n    { aim = \"LeftHand_Muzzle\", yaw = \"Left_Arm_B10\", pitch = \"Left_Arm_B07\", range = 35, speed = 50 },\n    { aim = \"RightHand_Muzzle\", yaw = \"Right_Arm_B07\", pitch = \"Right_Arm_B03\", range = 35, speed = 50 },\n    { aim = \"Left_AA_Muzzle\", yaw = \"Left_AA_Turret03\", pitch = \"Left_AA_Turret03\", range = 90, speed = 180 },\n    { aim = \"Right_AA_Muzzle\", yaw = \"Right_AA_Turret02\", pitch = \"Right_AA_Turret02\", range = 90, speed = 180 },\n}\nfor index, sourceArc in ipairs(ythothaAimArcs) do\n    local weapon = UnitTemplate.weapons and UnitTemplate.weapons[index]\n    local controllers = weapon and weapon.aimControllers\n    local controller = controllers and controllers[1]\n    if not controller or #controllers ~= 1\n        or controller.aimBone ~= sourceArc.aim\n        or controller.yawBone ~= sourceArc.yaw\n        or controller.pitchBone ~= sourceArc.pitch\n    then\n        error(\"Ythotha source aim controller \" .. index .. \" drifted.\")\n    end\n    controller.defaultYawAdjustment = 0\n    controller.yawMin = -sourceArc.range\n    controller.yawMax = sourceArc.range\n    controller.yawSpeed = sourceArc.speed\nend\nUnitTemplate.additions.scoYthothaAimArc = {\n    version = \"1.0.0\",\n    sourceId = \"XSL0401\",\n    sourceBlueprintSha256 = \"14f9f8c5566774931c0ebdd308088a3731857b3c2fd373f9cc4a4f01c00c83d4\",\n    controllerCount = 5,\n    rearAimExcluded = true,\n}";
	}

	private static bool MatchesSingleMuzzleRig(GeneratedWeaponRig rig, string aimBone, string yawBone, string pitchBone, string muzzleBone)
	{
		if (string.Equals(rig.AimBone, aimBone, StringComparison.Ordinal) && string.Equals(rig.YawBone, yawBone, StringComparison.Ordinal) && string.Equals(rig.PitchBone, pitchBone, StringComparison.Ordinal))
		{
			return rig.Muzzles.SequenceEqual<string>(new string[1] { muzzleBone }, StringComparer.Ordinal);
		}
		return false;
	}

	private static bool HasWeaponOriginBinding(string source, GeneratedPortSpec port)
	{
		if (GetRuntimeWeaponRigs(port).Length == 0)
		{
			return true;
		}
		string value = "weaponLayers = { " + string.Join(", ", from layer in OriginLayers(port)
			select "\"" + EscapeLua(layer) + "\"") + " }";
		if (source.IndexOf(value, StringComparison.Ordinal) < 0 || source.IndexOf("combatWeapon.layerWeaponLimits = rig.weaponLayers", StringComparison.Ordinal) < 0 || source.IndexOf("layerWeaponLimits = rig.weaponLayers,", StringComparison.Ordinal) < 0)
		{
			return false;
		}
		if (string.Equals(port.TargetId, "usl2002", StringComparison.Ordinal))
		{
			return source.IndexOf("-- Supreme Commander Overhaul Ilshavoh independent arms 1.0.0\n-- FA XSL0202 owns one shared Torso yaw manipulator and independent Right_Arm/Left_Arm\n-- pitch manipulators. RackFireTogether=false is preserved as two ordered muzzle groups.\nlocal ilshavohWeapon = UnitTemplate.weapons and UnitTemplate.weapons[1]\nif not ilshavohWeapon then\n    error(\"Ilshavoh source weapon is missing.\")\nend\nlocal function SCO_IlshavohAimController(aimBone, yawBone, pitchBone)\n    return {\n        aimBone = aimBone,\n        aimTolerance = 1,\n        defaultPitchAdjustment = 0,\n        defaultYawAdjustment = 0,\n        leadTarget = true,\n        pitchBone = pitchBone,\n        pitchMax = 60,\n        pitchMin = -60,\n        pitchSpeed = 60,\n        poseResetTime = 3,\n        projectileSpeed = 30,\n        reduceMuzzleVelocityToTarget = false,\n        solverType = \"LowArc\",\n        yawBone = yawBone,\n        yawMax = 180,\n        yawMin = -180,\n        yawSpeed = 180,\n    }\nend\nilshavohWeapon.aimControllers = {\n    SCO_IlshavohAimController(\"Torso\", \"Torso\", nil),\n    SCO_IlshavohAimController(\"Right_Muzzle\", nil, \"Right_Arm\"),\n    SCO_IlshavohAimController(\"Left_Muzzle\", nil, \"Left_Arm\"),\n}\nilshavohWeapon.muzzleGroups = {\n    { muzzles = { \"Right_Muzzle\" } },\n    { muzzles = { \"Left_Muzzle\" } },\n}\nilshavohWeapon.muzzles = {\n    [\"Right_Muzzle\"] = { aimController = \"Right_Muzzle\" },\n    [\"Left_Muzzle\"] = { aimController = \"Left_Muzzle\" },\n}\nilshavohWeapon.muzzleSalvoDelay = 0\nilshavohWeapon.muzzleSalvoSize = 1", StringComparison.Ordinal) >= 0;
		}
		if (string.Equals(port.TargetId, "usl4004", StringComparison.Ordinal))
		{
			if (source.IndexOf("-- Supreme Commander Overhaul Ythotha source aim arcs 1.0.0", StringComparison.Ordinal) >= 0 && source.IndexOf("UnitTemplate.additions.scoYthothaAimArc = {", StringComparison.Ordinal) >= 0)
			{
				return source.IndexOf("rearAimExcluded = true", StringComparison.Ordinal) >= 0;
			}
			return false;
		}
		if (!string.Equals(port.TargetId, "usl1101", StringComparison.Ordinal))
		{
			return true;
		}
		if (source.IndexOf("t1ArtilleryArc = true", StringComparison.Ordinal) >= 0 && source.IndexOf("defaultPitchAdjustment = 45", StringComparison.Ordinal) >= 0 && source.IndexOf("aim = \"Turret_Muzzle\", yaw = \"Turret\", pitch = \"Turret_Barrel\"", StringComparison.Ordinal) >= 0 && source.IndexOf("-- Supreme Commander Overhaul Zthuee split yaw/pitch 1.0.0", StringComparison.Ordinal) >= 0 && source.IndexOf("aimController.aimGravity = { x = 0, y = -4.9, z = 0 }", StringComparison.Ordinal) >= 0 && source.IndexOf("aimController.leadTarget = false", StringComparison.Ordinal) >= 0 && source.IndexOf("aimController.reduceMuzzleVelocityToTarget = true", StringComparison.Ordinal) >= 0)
		{
			return source.IndexOf("combatWeapon.projectileLifetime = 20", StringComparison.Ordinal) >= 0;
		}
		return false;
	}

	private static bool IsT1MobileArtillery(GeneratedPortSpec port, GeneratedWeaponRig rig)
	{
		if (string.Equals(port.TargetId, "usl1101", StringComparison.Ordinal) && string.Equals(port.SourceId, "XSL0103", StringComparison.Ordinal) && string.Equals(rig.ProjectileTemplate, "pci211", StringComparison.Ordinal))
		{
			return string.Equals(rig.SolverType, "HighArc", StringComparison.Ordinal);
		}
		return false;
	}

	private static string[] OriginLayers(GeneratedPortSpec port)
	{
		if (!string.Equals(port.MovementType, "Plane", StringComparison.Ordinal) && !string.Equals(port.MovementType, "Gunship", StringComparison.Ordinal))
		{
			if (!string.Equals(port.MovementType, "WaterSurface", StringComparison.Ordinal))
			{
				if (string.Equals(port.MovementType, "Hover", StringComparison.Ordinal))
				{
					return new string[2] { "Land", "WaterSurface" };
				}
				return new string[1] { "Land" };
			}
			return new string[1] { "WaterSurface" };
		}
		return new string[1] { "Air" };
	}

	private static bool UsesChosenCommanderProjectile(GeneratedPortSpec port, GeneratedWeaponRig rig)
	{
		if (string.Equals(port.TargetId, "usl0000", StringComparison.Ordinal))
		{
			return string.Equals(rig.RangeRingType, "DirectFire", StringComparison.Ordinal);
		}
		return false;
	}

	private static GeneratedWeaponRig[] GetRuntimeWeaponRigs(GeneratedPortSpec port)
	{
		if (!string.Equals(port.TargetId, "usl0000", StringComparison.Ordinal))
		{
			return port.WeaponRigs;
		}
		return port.WeaponRigs.Take(1).ToArray();
	}

	private static string BuildConstructionOverride(GeneratedPortSpec port)
	{
		string text = ((port.Economy.BuildRate > 0.0) ? ("UnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.buildPower = " + Lua(port.Economy.BuildRate)) : "if UnitTemplate.construction then\n    UnitTemplate.construction.buildPower = nil\nend");
		if (TryGetSeraphimLandFactoryBuildBeamBones(port, out string[] beamBones))
		{
			string text2 = string.Join("\n", beamBones.Select((string bone) => "    \"" + EscapeLua(bone) + "\","));
			return text + "\nUnitTemplate.additions.buildBeamBones = {\n" + text2 + "\n}\nUnitTemplate.additions.multiConstructionBeam = {\n    prefabName = \"SCOM.SeraphimFactoryBeam\",\n    materialPath = \"VFX/SCOM/ConstructionBeams/seraphim.sanmaterial\",\n    shrink = 0.05,\n}\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.beam = nil";
		}
		if (string.IsNullOrWhiteSpace(port.ConstructionBone))
		{
			return text + "\nUnitTemplate.additions.buildBeamBones = nil\nif UnitTemplate.construction and UnitTemplate.construction.beam then\n    UnitTemplate.construction.beam.boneName = nil\nend";
		}
		string text3 = EscapeLua(port.ConstructionBone);
		return text + "\nUnitTemplate.additions.buildBeamBones = { \"" + text3 + "\" }\nUnitTemplate.construction = UnitTemplate.construction or {}\nUnitTemplate.construction.beam = UnitTemplate.construction.beam or {}\nUnitTemplate.construction.beam.boneName = \"" + text3 + "\"\nUnitTemplate.construction.beam.offset = { x = 0, y = 0, z = 0 }";
	}

	private static bool HasConstructionBinding(string source, GeneratedPortSpec port)
	{
		return (from line in BuildConstructionOverride(port).Split(new char[2] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries)
			select line.Trim() into line
			where line.Length > 0
			select line).All((string line) => source.IndexOf(line, StringComparison.Ordinal) >= 0);
	}

	private static bool TryGetSeraphimLandFactoryBuildBeamBones(GeneratedPortSpec port, out string[] beamBones)
	{
		switch (port.TargetId)
		{
		case "uss1511":
			beamBones = new string[2] { "Muzzle01", "Muzzle02" };
			return string.Equals(port.SourceId, "XSB0101", StringComparison.Ordinal);
		case "uss2511":
			beamBones = new string[3] { "Muzzle01", "Muzzle02", "Muzzle03" };
			return string.Equals(port.SourceId, "XSB0201", StringComparison.Ordinal);
		case "uss3511":
			beamBones = new string[3] { "Muzzle01", "Muzzle02", "Muzzle03" };
			return string.Equals(port.SourceId, "XSB0301", StringComparison.Ordinal);
		default:
			beamBones = Array.Empty<string>();
			return false;
		}
	}

	private static string BuildTagOverride(GeneratedPortSpec port)
	{
		HashSet<string> hashSet = new HashSet<string>(port.RemoveTags, StringComparer.Ordinal);
		HashSet<string> hashSet2 = new HashSet<string>(port.AddTags, StringComparer.Ordinal);
		if (port.IsMobile)
		{
			string[] array = new string[6] { "AIR", "GUNSHIP", "LAND", "HOVER", "SEABED", "NAVAL" };
			foreach (string item in array)
			{
				hashSet.Add(item);
				hashSet2.Remove(item);
			}
			switch (port.MovementType)
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
				throw new InvalidOperationException("Unsupported Seraphim movement/tag type " + port.MovementType + " for " + port.SourceId + ".");
			}
		}
		string text = string.Join(", ", from tag in hashSet.OrderBy<string, string>((string tag) => tag, StringComparer.Ordinal)
			select "\"" + EscapeLua(tag) + "\"");
		string text2 = string.Join(", ", from tag in hashSet2.OrderBy<string, string>((string tag) => tag, StringComparer.Ordinal)
			select "\"" + EscapeLua(tag) + "\"");
		return "local seraphimRemoveTags = { " + text + " }\nlocal seraphimAddTags = { " + text2 + " }\nUnitTemplate.tags = UnitTemplate.tags or {}\nfor _, tag in ipairs(seraphimRemoveTags) do\n    for index = #UnitTemplate.tags, 1, -1 do\n        if UnitTemplate.tags[index] == tag then\n            table.remove(UnitTemplate.tags, index)\n        end\n    end\nend\nfor _, tag in ipairs(seraphimAddTags) do\n    local alreadyPresent = false\n    for _, existingTag in ipairs(UnitTemplate.tags) do\n        if existingTag == tag then\n            alreadyPresent = true\n            break\n        end\n    end\n    if not alreadyPresent then\n        table.insert(UnitTemplate.tags, tag)\n    end\nend";
	}

	private static bool HasResourceTagContract(string source, GeneratedPortSpec port)
	{
		string value = BuildResourceTagContractOverride(port);
		if (!string.IsNullOrEmpty(value))
		{
			return source.IndexOf(value, StringComparison.Ordinal) >= 0;
		}
		return true;
	}

	private static string BuildResourceTagContractOverride(GeneratedPortSpec port)
	{
		if (!ResourceTagContracts.TryGetValue(port.TargetId, out string[] value))
		{
			return string.Empty;
		}
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.Append("-- Supreme Commander Overhaul Seraphim canonical resource tags 1.0 ").AppendLine(port.TargetId);
		stringBuilder.AppendLine("UnitTemplate.tags = {");
		string[] array = value;
		foreach (string value2 in array)
		{
			stringBuilder.Append("    \"").Append(EscapeLua(value2)).AppendLine("\",");
		}
		stringBuilder.Append('}');
		return stringBuilder.ToString();
	}

	private static string BuildEconomyOverride(GeneratedPortSpec port)
	{
		GeneratedEconomySpec economy = port.Economy;
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("UnitTemplate.economy = {");
		stringBuilder.Append("    buildTime = ").Append(Lua(economy.BuildTime)).AppendLine(",");
		stringBuilder.AppendLine("    cost = {");
		stringBuilder.Append("        alloys = ").Append(Lua(economy.BuildCostMass)).AppendLine(",");
		stringBuilder.Append("        energy = ").Append(Lua(economy.BuildCostEnergy)).AppendLine(",");
		stringBuilder.AppendLine("    },");
		AppendResourceTable(stringBuilder, "production", economy.ProductionMass, economy.ProductionEnergy);
		AppendResourceTable(stringBuilder, "maintenanceConsumption", economy.MaintenanceMass, economy.MaintenanceEnergy);
		AppendResourceTable(stringBuilder, "storage", economy.StorageMass, economy.StorageEnergy);
		stringBuilder.AppendLine("}");
		if (string.Equals(port.EconomyProfile, "t2_fabricator", StringComparison.Ordinal))
		{
			stringBuilder.AppendLine("UnitTemplate.general.toggles = UnitTemplate.general.toggles or {}");
			stringBuilder.AppendLine("UnitTemplate.general.toggles.Production = true");
			stringBuilder.AppendLine("UnitTemplate.general.icon = UnitTemplate.general.icon or {}");
			stringBuilder.AppendLine("UnitTemplate.general.icon.shape = \"structure1\"");
			stringBuilder.AppendLine("UnitTemplate.general.icon.symbol = \"alloy\"");
			stringBuilder.AppendLine("UnitTemplate.general.icon.tech = \"t2\"");
		}
		return stringBuilder.ToString().TrimEnd(Array.Empty<char>());
	}

	private static string BuildEnergyGeneratorOverride(GeneratedPortSpec port)
	{
		if (!string.Equals(port.EconomyProfile, "energy_generator", StringComparison.Ordinal))
		{
			return string.Empty;
		}
		string text;
		switch (port.SourceId)
		{
		case "XSB1101":
		case "XSB1102":
			text = "t1";
			break;
		case "XSB1201":
			text = "t2";
			break;
		case "XSB1301":
			text = "t3";
			break;
		default:
			throw new InvalidOperationException("Unsupported Seraphim energy-generator source " + port.SourceId + ".");
		}
		string text2 = text;
		text = port.SourceId;
		string text3 = ((text == "XSB1301") ? "UnitTemplate.additions.rotators = {\n    {\n        boneName = \"Orb\",\n        speed = { x = 0, y = 90, z = 0 },\n        isVelocityScalingEnabled = false,\n    },\n}" : ((!(text == "XSB1102")) ? string.Empty : "UnitTemplate.additions.faHydrocarbonPlacement = {\n    sourceRequirement = \"hydrocarbon_deposit\",\n    supported = false,\n    fallback = \"unrestricted\",\n}"));
		return ("UnitTemplate.general.icon = UnitTemplate.general.icon or {}\nUnitTemplate.general.icon.shape = \"structure1\"\nUnitTemplate.general.icon.symbol = \"plasma\"\nUnitTemplate.general.icon.tech = \"" + text2 + "\"\nUnitTemplate.general.iconUI = \"tech" + text2.Substring(1) + "_structure1_plasma.png\"\nUnitTemplate.general.iconUIType = \"amphibious\"\n" + text3).TrimEnd(Array.Empty<char>());
	}

	private static void AppendResourceTable(StringBuilder result, string field, double alloys, double energy)
	{
		if (!(alloys <= 0.0) || !(energy <= 0.0))
		{
			result.Append("    ").Append(field).AppendLine(" = {");
			if (alloys > 0.0)
			{
				result.Append("        alloys = ").Append(Lua(alloys)).AppendLine(",");
			}
			if (energy > 0.0)
			{
				result.Append("        energy = ").Append(Lua(energy)).AppendLine(",");
			}
			result.AppendLine("    },");
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
		return value.ToString("0.###############", CultureInfo.InvariantCulture);
	}
}
