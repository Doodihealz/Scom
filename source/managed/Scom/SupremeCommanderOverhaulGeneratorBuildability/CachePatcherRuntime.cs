using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using SupremeCommanderOverhaulCanonical;

namespace SupremeCommanderOverhaulGeneratorBuildability;

public static class CachePatcherRuntime
{
	private sealed class FactoryTagRoute
	{
		public string TargetId { get; }

		public string SourceId { get; }

		public string DomainTag { get; }

		public string FactoryTag { get; }

		public string CanBuild { get; }

		public string Path => "LJ/lua/common/units/unitsTemplates/" + TargetId + "/" + TargetId + ".santp";

		public FactoryTagRoute(string targetId, string sourceId, string domainTag, string factoryTag, string canBuild)
		{
			TargetId = targetId;
			SourceId = sourceId;
			DomainTag = domainTag;
			FactoryTag = factoryTag;
			CanBuild = canBuild;
		}
	}

	private sealed class TagBlock
	{
		public int Start { get; }

		public int End { get; }

		public IReadOnlyList<string> Tags { get; }

		public TagBlock(int start, int end, IReadOnlyList<string> tags)
		{
			Start = start;
			End = end;
			Tags = tags;
		}
	}

	private sealed class Route
	{
		public string Chosen { get; }

		public string Seraphim { get; }

		public Route(string chosen, string seraphim)
		{
			Chosen = chosen;
			Seraphim = seraphim;
		}
	}

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

	private sealed class MutationPlan
	{
		public string Path { get; }

		public object Stock { get; }

		public string OldSource { get; }

		public string NewSource { get; }

		public object? Replacement { get; set; }

		public bool AssignmentAttempted { get; set; }

		public MutationPlan(string path, object stock, string oldSource, string newSource)
		{
			Path = path;
			Stock = stock;
			OldSource = oldSource;
			NewSource = newSource;
		}
	}

	private sealed class CompatibilityException : InvalidOperationException
	{
		public CompatibilityException(string message)
			: base(message)
		{
		}
	}

	private sealed class RollbackException : AggregateException
	{
		public RollbackException(Exception commitError, IEnumerable<Exception> rollbackErrors)
			: base("Generator-buildability cache commit and rollback both failed.", new Exception[1] { commitError }.Concat<Exception>(rollbackErrors))
		{
		}
	}

	public const string Marker = "-- Supreme Commander Overhaul generator buildability 1.1.0";

	public const string ScomAiMarker = "-- Supreme Commander Overhaul Seraphim AI compatibility 1.0.0";

	public const string ScomAeonMarker = "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0";

	public const string PrometheansMarker = "-- Prometheans standalone faction 0.6.3";

	public const string AIFunctionsPath = "LJ/lua/AI/AIFunctions.lua";

	public const string ExpectedScomSha256 = "3EED7306200D5910786221547FF0FB959FA8CF92C85C99D62B98A12175C28B76";

	public const string ExpectedScomMvid = "48dd1991-b31b-4297-bd60-0597d33328b5";

	public const long ExpectedScomBytes = 3819520L;

	public const string ExpectedPrometheansSha256 = "49CD6B4D0649E8C8F9020AC9C5856F5C6EAEB5556BA7855F74D1B85F30CD16B6";

	public const string ExpectedPrometheansMvid = "026508db-0dd6-41f3-b26b-02d881776fd0";

	public const long ExpectedPrometheansBytes = 380928L;

	private const string ScomRuntimeType = "SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime";

	private const string PrometheansRuntimeType = "Prometheans.FactionCachePatcher.CachePatcherRuntime";

	private const string BadRandomSelection = "FactiontpIds[FactiontpIdsIndex] = InittpIds[math.random(1,#tpIdTable)]";

	private const string FixedRandomSelection = "FactiontpIds[FactiontpIdsIndex] = InittpIds[math.random(1, #InittpIds)]";

	private const string PlatoonFunctionSignature = "function subPlanStartMoveToBuildDestination(unit, placeToBuild, reserveEcoTpId, issueBuild)";

	private const string UnsafeBuildPayload = "{tpId = unit.platoon.ai.nextBuildingtpIds[unit.factionTag], armyId = unit.army.id }";

	private const string SafeBuildPayload = "{tpId = reserveEcoTpId, armyId = unit.army.id }";

	private const string UnsafeBuildArgument = "subPlanStartMoveToBuildDestination(builder, platoon.ai.placeToBuild, platoon.ai.nextBuildingtpIds[builder.factionTag],";

	private const string SafeBuildArgument = "subPlanStartMoveToBuildDestination(builder, platoon.ai.placeToBuild, platoon.ai.nextBuildingtpIds and platoon.ai.nextBuildingtpIds[builder.factionTag],";

	private const string UnsafeDebugText = "builder.ai.orderText = \"No path, need transport! [\"..builder.platoon.ai.nextBuildingtpIds[builder.factionTag]..\"]\"";

	private const string SafeDebugText = "builder.ai.orderText = \"No path, need transport! [\"..repr(builder.platoon.ai.nextBuildingtpIds and builder.platoon.ai.nextBuildingtpIds[builder.factionTag])..\"]\"";

	private const string UpgradeMaintenanceGuardMarker = "-- Supreme Commander Overhaul AI upgrade maintenance guard 1.0.0";

	private const string LegacyStructureSelectorArguments = "armyIndex, baseName, formerTable";

	private const string CurrentStructureSelectorArguments = "armyIndex, baseName, formerTable, assignedBuilderOverride, maximumBuilderCountOverride";

	private const string UncheckedNormalStructureCandidate = "Tags[factionName][tpId] and AvailableUnits[tpId] then";

	private const string CheckedNormalStructureCandidate = "Tags[factionName][tpId] and AvailableUnits[tpId]\n                        and not (UnitTemplates[tpId].additions\n                            and UnitTemplates[tpId].additions.scoHydroPlacement\n                            and UnitTemplates[tpId].additions.scoHydroPlacement.normalConstructionSupported == false) then";

	private const string UnsafeUpgradeMaintenanceLoop = "            for unitTemplateIdentifier, _ in pairs(upgradeableUnitsLine[1]) do\n                local upgradeUnitTemplateIdentifier = UnitTemplates[unitTemplateIdentifier].construction.upgradesTo\n                local energyConsumption = UnitTemplates[upgradeUnitTemplateIdentifier].economy.maintenanceConsumption.energy\n                local unitName = UnitTemplates[upgradeUnitTemplateIdentifier].general.name\n                AILog(\"* Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): [A:\"..armyIndex..\"] upgrade [\"..upgradeUnitTemplateIdentifier..\"] (\"..unitName..\") maintenanceEnergy=\"..energyConsumption..\" availableEnergyTrend=\"..energyTrend..\" result=\"..tostring(energyTrend > energyConsumption), GetFormerDebugFlag(formerTable))\n                if maximumEnergyConsumption < energyConsumption then\n                    maximumEnergyConsumption = energyConsumption\n                end\n            end";

	private const string SafeUpgradeMaintenanceLoop = "            for unitTemplateIdentifier, _ in pairs(upgradeableUnitsLine[1]) do\n                local sourceTemplate = UnitTemplates[unitTemplateIdentifier]\n                if sourceTemplate == nil then\n                    AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): missing source template [\"..repr(unitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                    return false\n                end\n                local sourceConstruction = sourceTemplate.construction\n                local upgradeUnitTemplateIdentifier = sourceConstruction and sourceConstruction.upgradesTo\n                if upgradeUnitTemplateIdentifier ~= nil then\n                    local upgradeTemplate = UnitTemplates[upgradeUnitTemplateIdentifier]\n                    if upgradeTemplate == nil then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): missing upgrade target [\"..repr(unitTemplateIdentifier)..\"] -> [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local upgradeEconomy = upgradeTemplate.economy\n                    if type(upgradeEconomy) ~= \"table\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): upgrade target has no economy table [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local maintenanceConsumption = upgradeEconomy.maintenanceConsumption\n                    if maintenanceConsumption ~= nil and type(maintenanceConsumption) ~= \"table\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): invalid maintenance table [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local energyConsumption = maintenanceConsumption and maintenanceConsumption.energy or 0\n                    if type(energyConsumption) ~= \"number\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): invalid maintenance energy [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local unitName = upgradeTemplate.general and upgradeTemplate.general.name or upgradeUnitTemplateIdentifier\n                    AILog(\"* Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): [A:\"..armyIndex..\"] upgrade [\"..upgradeUnitTemplateIdentifier..\"] (\"..unitName..\") maintenanceEnergy=\"..energyConsumption..\" availableEnergyTrend=\"..energyTrend..\" result=\"..tostring(energyTrend > energyConsumption), GetFormerDebugFlag(formerTable))\n                    if maximumEnergyConsumption < energyConsumption then\n                        maximumEnergyConsumption = energyConsumption\n                    end\n                end\n            end";

	private static readonly string CurrentUnsafeUpgradeMaintenanceLoop = BuildCurrentUpgradeMaintenanceLoop("            for unitTemplateIdentifier, _ in pairs(upgradeableUnitsLine[1]) do\n                local upgradeUnitTemplateIdentifier = UnitTemplates[unitTemplateIdentifier].construction.upgradesTo\n                local energyConsumption = UnitTemplates[upgradeUnitTemplateIdentifier].economy.maintenanceConsumption.energy\n                local unitName = UnitTemplates[upgradeUnitTemplateIdentifier].general.name\n                AILog(\"* Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): [A:\"..armyIndex..\"] upgrade [\"..upgradeUnitTemplateIdentifier..\"] (\"..unitName..\") maintenanceEnergy=\"..energyConsumption..\" availableEnergyTrend=\"..energyTrend..\" result=\"..tostring(energyTrend > energyConsumption), GetFormerDebugFlag(formerTable))\n                if maximumEnergyConsumption < energyConsumption then\n                    maximumEnergyConsumption = energyConsumption\n                end\n            end", "                ");

	private static readonly string CurrentSafeUpgradeMaintenanceLoop = BuildCurrentUpgradeMaintenanceLoop("            for unitTemplateIdentifier, _ in pairs(upgradeableUnitsLine[1]) do\n                local sourceTemplate = UnitTemplates[unitTemplateIdentifier]\n                if sourceTemplate == nil then\n                    AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): missing source template [\"..repr(unitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                    return false\n                end\n                local sourceConstruction = sourceTemplate.construction\n                local upgradeUnitTemplateIdentifier = sourceConstruction and sourceConstruction.upgradesTo\n                if upgradeUnitTemplateIdentifier ~= nil then\n                    local upgradeTemplate = UnitTemplates[upgradeUnitTemplateIdentifier]\n                    if upgradeTemplate == nil then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): missing upgrade target [\"..repr(unitTemplateIdentifier)..\"] -> [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local upgradeEconomy = upgradeTemplate.economy\n                    if type(upgradeEconomy) ~= \"table\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): upgrade target has no economy table [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local maintenanceConsumption = upgradeEconomy.maintenanceConsumption\n                    if maintenanceConsumption ~= nil and type(maintenanceConsumption) ~= \"table\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): invalid maintenance table [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local energyConsumption = maintenanceConsumption and maintenanceConsumption.energy or 0\n                    if type(energyConsumption) ~= \"number\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): invalid maintenance energy [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local unitName = upgradeTemplate.general and upgradeTemplate.general.name or upgradeUnitTemplateIdentifier\n                    AILog(\"* Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): [A:\"..armyIndex..\"] upgrade [\"..upgradeUnitTemplateIdentifier..\"] (\"..unitName..\") maintenanceEnergy=\"..energyConsumption..\" availableEnergyTrend=\"..energyTrend..\" result=\"..tostring(energyTrend > energyConsumption), GetFormerDebugFlag(formerTable))\n                    if maximumEnergyConsumption < energyConsumption then\n                        maximumEnergyConsumption = energyConsumption\n                    end\n                end\n            end", "                    ");

	private const string UnitTemplatePathPrefix = "LJ/lua/common/units/unitsTemplates/";

	private const string TagBlockStart = "UnitTemplate.tags = {\n";

	private static readonly string[] PlatoonPaths = new string[2] { "LJ/lua/AI/mods/AI-Sanctuary-Rush/AIPlatoonFunctions.lua", "LJ/lua/AI/mods/AI-T2Rush/AIPlatoonFunctions.lua" };

	private static readonly FactoryTagRoute[] AeonFactoryTagRoutes = new FactoryTagRoute[10]
	{
		new FactoryTagRoute("uca4011", "UAA0310", "AIR", "AIR_FACTORY", "Tags.CHOSEN * Tags.BUILDABLE_BY_T3_FACTORY * Tags.AIR * Tags.MOBILE"),
		new FactoryTagRoute("ucs1511", "UAB0101", "LAND", "LAND_FACTORY", "Tags.CHOSEN * Tags.BUILDABLE_BY_T1_FACTORY * Tags.LAND"),
		new FactoryTagRoute("ucs1512", "UAB0102", "AIR", "AIR_FACTORY", "Tags.CHOSEN * Tags.BUILDABLE_BY_T1_FACTORY * Tags.AIR"),
		new FactoryTagRoute("ucs1513", "UAB0103", "NAVAL", "NAVAL_FACTORY", "Tags.CHOSEN * Tags.BUILDABLE_BY_T1_FACTORY * Tags.NAVAL"),
		new FactoryTagRoute("ucs2511", "UAB0201", "LAND", "LAND_FACTORY", "Tags.CHOSEN * Tags.BUILDABLE_BY_T2_FACTORY * Tags.LAND"),
		new FactoryTagRoute("ucs2512", "UAB0202", "AIR", "AIR_FACTORY", "Tags.CHOSEN * Tags.BUILDABLE_BY_T2_FACTORY * Tags.AIR"),
		new FactoryTagRoute("ucs2513", "UAB0203", "NAVAL", "NAVAL_FACTORY", "Tags.CHOSEN * Tags.BUILDABLE_BY_T2_FACTORY * Tags.NAVAL"),
		new FactoryTagRoute("ucs3511", "UAB0301", "LAND", "LAND_FACTORY", "Tags.CHOSEN * Tags.BUILDABLE_BY_T3_FACTORY * Tags.LAND"),
		new FactoryTagRoute("ucs3512", "UAB0302", "AIR", "AIR_FACTORY", "Tags.CHOSEN * Tags.BUILDABLE_BY_T3_FACTORY * Tags.AIR"),
		new FactoryTagRoute("ucs3513", "UAB0303", "NAVAL", "NAVAL_FACTORY", "Tags.CHOSEN * Tags.BUILDABLE_BY_T3_FACTORY * Tags.NAVAL")
	};

	private static readonly string[] FactoryDomainTags = new string[3] { "AIR_FACTORY", "LAND_FACTORY", "NAVAL_FACTORY" };

	private static readonly Route[] SeraphimRoutes = new Route[82]
	{
		new Route("uca1001", "usa1001"),
		new Route("uca1201", "usa1201"),
		new Route("uca1502", "usa1502"),
		new Route("uca1701", "usa1701"),
		new Route("uca2011", "usa2011"),
		new Route("uca2101", "usa2101"),
		new Route("uca2301", "usa2301"),
		new Route("uca2502", "usa2502"),
		new Route("uca3001", "usa3001"),
		new Route("uca3201", "usa3201"),
		new Route("uca3701", "usa3701"),
		new Route("uca4011", "usa4011"),
		new Route("ucl0000", "usl0000"),
		new Route("ucl1001", "usl1001"),
		new Route("ucl1101", "usl1101"),
		new Route("ucl1201", "usl1201"),
		new Route("ucl1501", "usl1501"),
		new Route("ucl1701", "usl1701"),
		new Route("ucl2002", "usl2002"),
		new Route("ucl2101", "usl2101"),
		new Route("ucl2201", "usl2201"),
		new Route("ucl2501", "usl2501"),
		new Route("ucl2806", "usl2806"),
		new Route("ucl3001", "usl3001"),
		new Route("ucl3101", "usl3101"),
		new Route("ucl3501", "usl3501"),
		new Route("ucl3801", "usl3801"),
		new Route("ucl4002", "usl4002"),
		new Route("ucl4004", "usl4004"),
		new Route("ucl4401", "usl4401"),
		new Route("ucn1001", "usn1001"),
		new Route("ucn1002", "usn1002"),
		new Route("ucn2001", "usn2001"),
		new Route("ucn2002", "usn2002"),
		new Route("ucn3001", "usn3001"),
		new Route("ucn3003", "usn3003"),
		new Route("ucn3004", "usn3004"),
		new Route("ucs1001", "uss1001"),
		new Route("ucs1201", "uss1201"),
		new Route("ucs1301", "uss1301"),
		new Route("ucs1511", "uss1511"),
		new Route("ucs1512", "uss1512"),
		new Route("ucs1513", "uss1513"),
		new Route("ucs1601", "uss1601"),
		new Route("ucs1602", "uss1602"),
		new Route("ucs1611", "uss1611"),
		new Route("ucs1612", "uss1612"),
		new Route("ucs1614", "uss1614"),
		new Route("ucs1701", "uss1701"),
		new Route("ucs1702", "uss1702"),
		new Route("ucs1804", "uss1804"),
		new Route("ucs2001", "uss2001"),
		new Route("ucs2101", "uss2101"),
		new Route("ucs2102", "uss2102"),
		new Route("ucs2201", "uss2201"),
		new Route("ucs2301", "uss2301"),
		new Route("ucs2401", "uss2401"),
		new Route("ucs2402", "uss2402"),
		new Route("ucs2510", "uss2510"),
		new Route("ucs2511", "uss2511"),
		new Route("ucs2512", "uss2512"),
		new Route("ucs2513", "uss2513"),
		new Route("ucs2601", "uss2601"),
		new Route("ucs2611", "uss2611"),
		new Route("ucs2701", "uss2701"),
		new Route("ucs2702", "uss2702"),
		new Route("ucs2711", "uss2711"),
		new Route("ucs2806", "uss2806"),
		new Route("ucs3101", "uss3101"),
		new Route("ucs3102", "uss3102"),
		new Route("ucs3201", "uss3201"),
		new Route("ucs3401", "uss3401"),
		new Route("ucs3402", "uss3402"),
		new Route("ucs3501", "uss3501"),
		new Route("ucs3511", "uss3511"),
		new Route("ucs3512", "uss3512"),
		new Route("ucs3513", "uss3513"),
		new Route("ucs3601", "uss3601"),
		new Route("ucs3603", "uss3603"),
		new Route("ucs3611", "uss3611"),
		new Route("ucs3701", "uss3701"),
		new Route("ucs4102", "uss4102")
	};

	private static bool _isApplied;

	public static IReadOnlyList<string> ManagedPaths
	{
		get
		{
			ValidateFactoryTagRoutes();
			return new string[1] { "LJ/lua/AI/AIFunctions.lua" }.Concat<string>(PlatoonPaths).Concat<string>(AeonFactoryTagRoutes.Select((FactoryTagRoute route) => route.Path)).ToArray();
		}
	}

	public static void Apply()
	{
		if (_isApplied)
		{
			return;
		}
		try
		{
			ValidateUpstreamIdentity();
			object luaFileCache = GetLuaFileCache();
			List<MutationPlan> list = BuildMutationPlans(luaFileCache);
			if (list.Count == 0)
			{
				_isApplied = true;
				Log("No generator-buildability cache changes required; skipped AI edits, if any, are reported above.");
			}
			else
			{
				Commit(luaFileCache, list);
				_isApplied = true;
				Log("Applied compatible generator-buildability cache changes; skipped AI edits, if any, are reported above.");
			}
		}
		catch (RollbackException)
		{
			throw;
		}
		catch (Exception)
		{
			throw;
		}
	}

	public static string PatchAIFunctionsSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = ApplyNormalConstructionGuard(Normalize(source));
		int num = Count(text, "-- Supreme Commander Overhaul generator buildability 1.1.0");
		switch (num)
		{
		case 1:
		{
			string text3 = ApplyUpgradeMaintenanceGuard(text);
			ValidateAIFunctionsSource(text3);
			return text3;
		}
		default:
			throw Incompatible($"Expected zero or one generator-buildability markers, found {num}.");
		case 0:
		{
			ValidateUpstreamAiSource(text, "AIFunctions");
			int num2 = Count(text, "FactiontpIds[FactiontpIdsIndex] = InittpIds[math.random(1,#tpIdTable)]");
			int num3 = Count(text, "FactiontpIds[FactiontpIdsIndex] = InittpIds[math.random(1, #InittpIds)]");
			int num4 = Count(text, "FactiontpIds[FactiontpIdsIndex] = InittpIds[math.random(1,#InittpIds)]");
			if (num2 + num3 + num4 != 1)
			{
				throw Incompatible($"Expected exactly one unsafe or already-fixed candidate-list bound; found unsafe={num2}, fixed={num3}, upstreamFixed={num4}.");
			}
			RequireExactly(text, "local SCO_GeneratorPreviousGetWantStructures", 0, "pre-existing structure wrapper");
			RequireExactly(text, "local SCO_GeneratorPreviousGetWantUnits", 0, "pre-existing unit wrapper");
			int num5 = Count(text, "function GetWantStructures(armyIndex, baseName, formerTable)");
			int num6 = Count(text, "function GetWantStructures(armyIndex, baseName, formerTable, assignedBuilderOverride, maximumBuilderCountOverride)");
			if (num5 + num6 != 1)
			{
				throw Incompatible($"Expected one supported structure selector; found legacy={num5}, current={num6}.");
			}
			string text2 = ApplyUpgradeMaintenanceGuard(Normalize(((num2 == 1) ? ReplaceExactly(text, "FactiontpIds[FactiontpIdsIndex] = InittpIds[math.random(1,#tpIdTable)]", "FactiontpIds[FactiontpIdsIndex] = InittpIds[math.random(1, #InittpIds)]", "candidate-list bound") : ((num4 == 1) ? ReplaceExactly(text, "FactiontpIds[FactiontpIdsIndex] = InittpIds[math.random(1,#InittpIds)]", "FactiontpIds[FactiontpIdsIndex] = InittpIds[math.random(1, #InittpIds)]", "upstream-fixed candidate-list bound") : text)).TrimEnd(Array.Empty<char>()) + BuildAiAppendix(num6 == 1) + "\n"));
			ValidateAIFunctionsSource(text2);
			return text2;
		}
		}
	}

	private static string ApplyNormalConstructionGuard(string source)
	{
		int num = Count(source, "Tags[factionName][tpId] and AvailableUnits[tpId] then");
		int num2 = Count(source, "Tags[factionName][tpId] and AvailableUnits[tpId]\n                        and not (UnitTemplates[tpId].additions\n                            and UnitTemplates[tpId].additions.scoHydroPlacement\n                            and UnitTemplates[tpId].additions.scoHydroPlacement.normalConstructionSupported == false) then");
		if (num == 0 && num2 == 1)
		{
			return source;
		}
		if (num != 1 || num2 != 0)
		{
			throw Incompatible($"Expected one normal structure-candidate gate; found unchecked={num}, checked={num2}.");
		}
		return ReplaceExactly(source, "Tags[factionName][tpId] and AvailableUnits[tpId] then", "Tags[factionName][tpId] and AvailableUnits[tpId]\n                        and not (UnitTemplates[tpId].additions\n                            and UnitTemplates[tpId].additions.scoHydroPlacement\n                            and UnitTemplates[tpId].additions.scoHydroPlacement.normalConstructionSupported == false) then", "normal construction policy gate");
	}

	private static string ApplyUpgradeMaintenanceGuard(string source)
	{
		int num = Count(source, "-- Supreme Commander Overhaul AI upgrade maintenance guard 1.0.0");
		switch (num)
		{
		case 1:
			return source;
		case 0:
		{
			int num2 = Count(source, "            for unitTemplateIdentifier, _ in pairs(upgradeableUnitsLine[1]) do\n                local upgradeUnitTemplateIdentifier = UnitTemplates[unitTemplateIdentifier].construction.upgradesTo\n                local energyConsumption = UnitTemplates[upgradeUnitTemplateIdentifier].economy.maintenanceConsumption.energy\n                local unitName = UnitTemplates[upgradeUnitTemplateIdentifier].general.name\n                AILog(\"* Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): [A:\"..armyIndex..\"] upgrade [\"..upgradeUnitTemplateIdentifier..\"] (\"..unitName..\") maintenanceEnergy=\"..energyConsumption..\" availableEnergyTrend=\"..energyTrend..\" result=\"..tostring(energyTrend > energyConsumption), GetFormerDebugFlag(formerTable))\n                if maximumEnergyConsumption < energyConsumption then\n                    maximumEnergyConsumption = energyConsumption\n                end\n            end");
			int num3 = Count(source, CurrentUnsafeUpgradeMaintenanceLoop);
			if (num2 + num3 != 1)
			{
				throw Incompatible($"Expected one supported unsafe upgrade-maintenance loop; found legacy={num2}, current={num3}.");
			}
			RequireExactly(source, "            for unitTemplateIdentifier, _ in pairs(upgradeableUnitsLine[1]) do\n                local sourceTemplate = UnitTemplates[unitTemplateIdentifier]\n                if sourceTemplate == nil then\n                    AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): missing source template [\"..repr(unitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                    return false\n                end\n                local sourceConstruction = sourceTemplate.construction\n                local upgradeUnitTemplateIdentifier = sourceConstruction and sourceConstruction.upgradesTo\n                if upgradeUnitTemplateIdentifier ~= nil then\n                    local upgradeTemplate = UnitTemplates[upgradeUnitTemplateIdentifier]\n                    if upgradeTemplate == nil then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): missing upgrade target [\"..repr(unitTemplateIdentifier)..\"] -> [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local upgradeEconomy = upgradeTemplate.economy\n                    if type(upgradeEconomy) ~= \"table\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): upgrade target has no economy table [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local maintenanceConsumption = upgradeEconomy.maintenanceConsumption\n                    if maintenanceConsumption ~= nil and type(maintenanceConsumption) ~= \"table\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): invalid maintenance table [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local energyConsumption = maintenanceConsumption and maintenanceConsumption.energy or 0\n                    if type(energyConsumption) ~= \"number\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): invalid maintenance energy [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local unitName = upgradeTemplate.general and upgradeTemplate.general.name or upgradeUnitTemplateIdentifier\n                    AILog(\"* Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): [A:\"..armyIndex..\"] upgrade [\"..upgradeUnitTemplateIdentifier..\"] (\"..unitName..\") maintenanceEnergy=\"..energyConsumption..\" availableEnergyTrend=\"..energyTrend..\" result=\"..tostring(energyTrend > energyConsumption), GetFormerDebugFlag(formerTable))\n                    if maximumEnergyConsumption < energyConsumption then\n                        maximumEnergyConsumption = energyConsumption\n                    end\n                end\n            end", 0, "guarded upgrade-maintenance loop");
			RequireExactly(source, CurrentSafeUpgradeMaintenanceLoop, 0, "current guarded upgrade-maintenance loop");
			string oldValue = ((num3 == 1) ? CurrentUnsafeUpgradeMaintenanceLoop : "            for unitTemplateIdentifier, _ in pairs(upgradeableUnitsLine[1]) do\n                local upgradeUnitTemplateIdentifier = UnitTemplates[unitTemplateIdentifier].construction.upgradesTo\n                local energyConsumption = UnitTemplates[upgradeUnitTemplateIdentifier].economy.maintenanceConsumption.energy\n                local unitName = UnitTemplates[upgradeUnitTemplateIdentifier].general.name\n                AILog(\"* Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): [A:\"..armyIndex..\"] upgrade [\"..upgradeUnitTemplateIdentifier..\"] (\"..unitName..\") maintenanceEnergy=\"..energyConsumption..\" availableEnergyTrend=\"..energyTrend..\" result=\"..tostring(energyTrend > energyConsumption), GetFormerDebugFlag(formerTable))\n                if maximumEnergyConsumption < energyConsumption then\n                    maximumEnergyConsumption = energyConsumption\n                end\n            end");
			string newValue = ((num3 == 1) ? CurrentSafeUpgradeMaintenanceLoop : "            for unitTemplateIdentifier, _ in pairs(upgradeableUnitsLine[1]) do\n                local sourceTemplate = UnitTemplates[unitTemplateIdentifier]\n                if sourceTemplate == nil then\n                    AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): missing source template [\"..repr(unitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                    return false\n                end\n                local sourceConstruction = sourceTemplate.construction\n                local upgradeUnitTemplateIdentifier = sourceConstruction and sourceConstruction.upgradesTo\n                if upgradeUnitTemplateIdentifier ~= nil then\n                    local upgradeTemplate = UnitTemplates[upgradeUnitTemplateIdentifier]\n                    if upgradeTemplate == nil then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): missing upgrade target [\"..repr(unitTemplateIdentifier)..\"] -> [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local upgradeEconomy = upgradeTemplate.economy\n                    if type(upgradeEconomy) ~= \"table\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): upgrade target has no economy table [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local maintenanceConsumption = upgradeEconomy.maintenanceConsumption\n                    if maintenanceConsumption ~= nil and type(maintenanceConsumption) ~= \"table\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): invalid maintenance table [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local energyConsumption = maintenanceConsumption and maintenanceConsumption.energy or 0\n                    if type(energyConsumption) ~= \"number\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): invalid maintenance energy [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local unitName = upgradeTemplate.general and upgradeTemplate.general.name or upgradeUnitTemplateIdentifier\n                    AILog(\"* Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): [A:\"..armyIndex..\"] upgrade [\"..upgradeUnitTemplateIdentifier..\"] (\"..unitName..\") maintenanceEnergy=\"..energyConsumption..\" availableEnergyTrend=\"..energyTrend..\" result=\"..tostring(energyTrend > energyConsumption), GetFormerDebugFlag(formerTable))\n                    if maximumEnergyConsumption < energyConsumption then\n                        maximumEnergyConsumption = energyConsumption\n                    end\n                end\n            end");
			return Normalize(ReplaceExactly(source, oldValue, newValue, "upgrade-maintenance loop").TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul AI upgrade maintenance guard 1.0.0\n");
		}
		default:
			throw Incompatible($"Expected zero or one upgrade-maintenance guard markers, found {num}.");
		}
	}

	private static string BuildCurrentUpgradeMaintenanceLoop(string loop, string indent)
	{
		string text = "AILog(\"* Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): [A:\"..armyIndex..\"] upgrade [\"..upgradeUnitTemplateIdentifier..\"] (\"..unitName..\") maintenanceEnergy=\"..energyConsumption..\" availableEnergyTrend=\"..energyTrend..\" result=\"..tostring(energyTrend > energyConsumption), GetFormerDebugFlag(formerTable))".Replace(", GetFormerDebugFlag(formerTable))", ")");
		return ReplaceExactly(loop.Replace(".general.name", ".general.unitTypeName"), indent + "AILog(\"* Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): [A:\"..armyIndex..\"] upgrade [\"..upgradeUnitTemplateIdentifier..\"] (\"..unitName..\") maintenanceEnergy=\"..energyConsumption..\" availableEnergyTrend=\"..energyTrend..\" result=\"..tostring(energyTrend > energyConsumption), GetFormerDebugFlag(formerTable))", indent + "if GetFormerDebugFlag(formerTable) then\n" + indent + "    " + text + "\n" + indent + "end", "current upgrade-maintenance debug log");
	}

	public static string PatchPlatoonSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul generator buildability 1.1.0");
		switch (num)
		{
		case 1:
			ValidatePlatoonSource(text);
			return text;
		default:
			throw Incompatible($"Expected zero or one generator-buildability markers, found {num}.");
		case 0:
		{
			ValidateUpstreamAiSource(text, "AI platoon functions");
			RequireExactly(text, "function subPlanStartMoveToBuildDestination(unit, placeToBuild, reserveEcoTpId, issueBuild)", 1, "build-move function");
			RequireExactly(text, "{tpId = unit.platoon.ai.nextBuildingtpIds[unit.factionTag], armyId = unit.army.id }", 1, "unguarded queued BUILD payload");
			RequireExactly(text, "{tpId = reserveEcoTpId, armyId = unit.army.id }", 0, "guarded queued BUILD payload");
			RequireExactly(text, "subPlanStartMoveToBuildDestination(builder, platoon.ai.placeToBuild, platoon.ai.nextBuildingtpIds[builder.factionTag],", 1, "unsafe build-move argument");
			RequireExactly(text, "subPlanStartMoveToBuildDestination(builder, platoon.ai.placeToBuild, platoon.ai.nextBuildingtpIds and platoon.ai.nextBuildingtpIds[builder.factionTag],", 0, "safe build-move argument");
			RequireExactly(text, "builder.ai.orderText = \"No path, need transport! [\"..builder.platoon.ai.nextBuildingtpIds[builder.factionTag]..\"]\"", 1, "unsafe no-path debug text");
			RequireExactly(text, "builder.ai.orderText = \"No path, need transport! [\"..repr(builder.platoon.ai.nextBuildingtpIds and builder.platoon.ai.nextBuildingtpIds[builder.factionTag])..\"]\"", 0, "safe no-path debug text");
			string newValue = "function subPlanStartMoveToBuildDestination(unit, placeToBuild, reserveEcoTpId, issueBuild)" + BuildPlatoonGuard();
			string text2 = Normalize(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(text, "function subPlanStartMoveToBuildDestination(unit, placeToBuild, reserveEcoTpId, issueBuild)", newValue, "build-move guard insertion"), "{tpId = unit.platoon.ai.nextBuildingtpIds[unit.factionTag], armyId = unit.army.id }", "{tpId = reserveEcoTpId, armyId = unit.army.id }", "queued BUILD payload"), "subPlanStartMoveToBuildDestination(builder, platoon.ai.placeToBuild, platoon.ai.nextBuildingtpIds[builder.factionTag],", "subPlanStartMoveToBuildDestination(builder, platoon.ai.placeToBuild, platoon.ai.nextBuildingtpIds and platoon.ai.nextBuildingtpIds[builder.factionTag],", "build-move argument"), "builder.ai.orderText = \"No path, need transport! [\"..builder.platoon.ai.nextBuildingtpIds[builder.factionTag]..\"]\"", "builder.ai.orderText = \"No path, need transport! [\"..repr(builder.platoon.ai.nextBuildingtpIds and builder.platoon.ai.nextBuildingtpIds[builder.factionTag])..\"]\"", "no-path debug text").TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul generator buildability 1.1.0\n");
			ValidatePlatoonSource(text2);
			return text2;
		}
		}
	}

	public static string PatchFactoryTemplateSource(string source, string targetId)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		if (targetId == null)
		{
			throw new ArgumentNullException("targetId");
		}
		ValidateFactoryTagRoutes();
		FactoryTagRoute factoryTagRoute = AeonFactoryTagRoutes.SingleOrDefault((FactoryTagRoute candidate) => string.Equals(candidate.TargetId, targetId, StringComparison.Ordinal));
		if (factoryTagRoute == null)
		{
			throw new ArgumentOutOfRangeException("targetId", targetId, "The target is not an enabled Aeon production factory.");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul generator buildability 1.1.0");
		switch (num)
		{
		case 1:
			ValidateFactoryTemplateSource(text, factoryTagRoute, expectFactoryTag: true);
			return text;
		default:
			throw Incompatible($"Expected zero or one generator-buildability markers, found {num}.");
		case 0:
		{
			TagBlock tagBlock = ValidateFactoryTemplateSource(text, factoryTagRoute, expectFactoryTag: false);
			string text2 = RenderTagBlock(tagBlock.Tags.Concat<string>(new string[1] { factoryTagRoute.FactoryTag }).OrderBy<string, string>((string tag) => tag, StringComparer.Ordinal).ToArray());
			string text3 = Normalize((text.Substring(0, tagBlock.Start) + text2 + text.Substring(tagBlock.End)).TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul generator buildability 1.1.0\n");
			ValidateFactoryTemplateSource(text3, factoryTagRoute, expectFactoryTag: true);
			return text3;
		}
		}
	}

	private static void ValidateAIFunctionsSource(string source)
	{
		RequireExactly(source, "Tags[factionName][tpId] and AvailableUnits[tpId] then", 0, "unchecked normal structure candidate");
		RequireExactly(source, "Tags[factionName][tpId] and AvailableUnits[tpId]\n                        and not (UnitTemplates[tpId].additions\n                            and UnitTemplates[tpId].additions.scoHydroPlacement\n                            and UnitTemplates[tpId].additions.scoHydroPlacement.normalConstructionSupported == false) then", 1, "normal construction policy gate");
		ValidateUpstreamAiSource(source, "AIFunctions");
		RequireExactly(source, "-- Supreme Commander Overhaul generator buildability 1.1.0", 1, "generator-buildability marker");
		RequireExactly(source, "FactiontpIds[FactiontpIdsIndex] = InittpIds[math.random(1,#tpIdTable)]", 0, "unsafe candidate-list bound");
		RequireExactly(source, "FactiontpIds[FactiontpIdsIndex] = InittpIds[math.random(1, #InittpIds)]", 1, "fixed candidate-list bound");
		RequireExactly(source, "local SCO_GeneratorPreviousGetWantStructures = GetWantStructures", 1, "structure wrapper capture");
		RequireExactly(source, "local SCO_GeneratorPreviousGetWantUnits = GetWantUnits", 1, "unit wrapper capture");
		int num = Count(source, "function GetWantStructures(armyIndex, baseName, formerTable, assignedBuilderOverride, maximumBuilderCountOverride)");
		string text = ((num == 0) ? "armyIndex, baseName, formerTable" : "armyIndex, baseName, formerTable, assignedBuilderOverride, maximumBuilderCountOverride");
		string text2 = ((num == 0) ? "armyIndex, baseName, formerTable, assignedBuilderOverride, maximumBuilderCountOverride" : "armyIndex, baseName, formerTable");
		RequireExactly(source, "function GetWantStructures(" + text + ")", 2, "stock and wrapped structure selectors");
		RequireExactly(source, "function GetWantStructures(" + text2 + ")", 0, "mismatched structure selector signature");
		RequireExactly(source, "SCO_GeneratorPreviousGetWantStructures(" + text + "),", 1, "forwarded structure selector arguments");
		RequireExactly(source, "function GetWantUnits(armyIndex, baseName, formerTable)", 2, "stock and wrapped unit selectors");
		RequireExactly(source, "local SCO_GeneratorSeraphimByChosen = {", 1, "explicit Seraphim route table");
		RequireExactly(source, "copy.SERAPHIM = seraphimId", 1, "Seraphim alias assignment");
		RequireExactly(source, "-- Supreme Commander Overhaul AI upgrade maintenance guard 1.0.0", 1, "upgrade-maintenance guard marker");
		RequireExactly(source, "            for unitTemplateIdentifier, _ in pairs(upgradeableUnitsLine[1]) do\n                local upgradeUnitTemplateIdentifier = UnitTemplates[unitTemplateIdentifier].construction.upgradesTo\n                local energyConsumption = UnitTemplates[upgradeUnitTemplateIdentifier].economy.maintenanceConsumption.energy\n                local unitName = UnitTemplates[upgradeUnitTemplateIdentifier].general.name\n                AILog(\"* Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): [A:\"..armyIndex..\"] upgrade [\"..upgradeUnitTemplateIdentifier..\"] (\"..unitName..\") maintenanceEnergy=\"..energyConsumption..\" availableEnergyTrend=\"..energyTrend..\" result=\"..tostring(energyTrend > energyConsumption), GetFormerDebugFlag(formerTable))\n                if maximumEnergyConsumption < energyConsumption then\n                    maximumEnergyConsumption = energyConsumption\n                end\n            end", 0, "unsafe upgrade-maintenance loop");
		RequireExactly(source, CurrentUnsafeUpgradeMaintenanceLoop, 0, "current unsafe upgrade-maintenance loop");
		int num2 = Count(source, "            for unitTemplateIdentifier, _ in pairs(upgradeableUnitsLine[1]) do\n                local sourceTemplate = UnitTemplates[unitTemplateIdentifier]\n                if sourceTemplate == nil then\n                    AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): missing source template [\"..repr(unitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                    return false\n                end\n                local sourceConstruction = sourceTemplate.construction\n                local upgradeUnitTemplateIdentifier = sourceConstruction and sourceConstruction.upgradesTo\n                if upgradeUnitTemplateIdentifier ~= nil then\n                    local upgradeTemplate = UnitTemplates[upgradeUnitTemplateIdentifier]\n                    if upgradeTemplate == nil then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): missing upgrade target [\"..repr(unitTemplateIdentifier)..\"] -> [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local upgradeEconomy = upgradeTemplate.economy\n                    if type(upgradeEconomy) ~= \"table\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): upgrade target has no economy table [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local maintenanceConsumption = upgradeEconomy.maintenanceConsumption\n                    if maintenanceConsumption ~= nil and type(maintenanceConsumption) ~= \"table\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): invalid maintenance table [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local energyConsumption = maintenanceConsumption and maintenanceConsumption.energy or 0\n                    if type(energyConsumption) ~= \"number\" then\n                        AILog(\"- WARNING: Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): invalid maintenance energy [\"..repr(upgradeUnitTemplateIdentifier)..\"]\", GetFormerDebugFlag(formerTable))\n                        return false\n                    end\n                    local unitName = upgradeTemplate.general and upgradeTemplate.general.name or upgradeUnitTemplateIdentifier\n                    AILog(\"* Fn CheckEnergyTrendCanCoverMaintenanceConsumption(): [A:\"..armyIndex..\"] upgrade [\"..upgradeUnitTemplateIdentifier..\"] (\"..unitName..\") maintenanceEnergy=\"..energyConsumption..\" availableEnergyTrend=\"..energyTrend..\" result=\"..tostring(energyTrend > energyConsumption), GetFormerDebugFlag(formerTable))\n                    if maximumEnergyConsumption < energyConsumption then\n                        maximumEnergyConsumption = energyConsumption\n                    end\n                end\n            end") + Count(source, CurrentSafeUpgradeMaintenanceLoop);
		if (num2 != 1)
		{
			throw Incompatible($"Expected one supported guarded upgrade-maintenance loop, found {num2}.");
		}
		RequireExactly(source, "if upgradeUnitTemplateIdentifier ~= nil then", 1, "terminal upgrade-candidate skip");
		RequireExactly(source, "local energyConsumption = maintenanceConsumption and maintenanceConsumption.energy or 0", 1, "zero-upkeep fallback");
		RequireExactly(source, "missing upgrade target", 1, "missing upgrade-target diagnostic");
		RequireExactly(source, "[\"ucs1611\"] = \"uss1611\"", 1, "T1 power alias");
		RequireExactly(source, "[\"ucs2611\"] = \"uss2611\"", 1, "T2 power alias");
		RequireExactly(source, "[\"ucs3611\"] = \"uss3611\"", 1, "T3 power alias");
		RequireExactly(source, "[\"ucs1601\"] = \"uss1601\"", 1, "T1 extractor alias");
		RequireExactly(source, "[\"ucs2601\"] = \"uss2601\"", 1, "T2 extractor alias");
		RequireExactly(source, "[\"ucs3601\"] = \"uss3601\"", 1, "T3 extractor alias");
		RequireExactly(source, "[\"ucs3603\"] = \"uss3603\"", 1, "T3 fabricator alias");
		RequireExactly(source, "[\"ucl1501\"] = \"usl1501\"", 1, "T1 engineer alias");
		RequireExactly(source, "[\"ucl2501\"] = \"usl2501\"", 1, "T2 engineer alias");
		RequireExactly(source, "[\"ucl3501\"] = \"usl3501\"", 1, "T3 engineer alias");
		RequireExactly(source, "[\"ucs1511\"] = \"uss1511\"", 1, "land-factory alias");
		RequireExactly(source, "[\"ucs1512\"] = \"uss1512\"", 1, "air-factory alias");
		RequireExactly(source, "[\"ucs1513\"] = \"uss1513\"", 1, "naval-factory alias");
		Route[] seraphimRoutes = SeraphimRoutes;
		foreach (Route route in seraphimRoutes)
		{
			RequireExactly(source, "[\"" + route.Chosen + "\"] = \"" + route.Seraphim + "\"", 1, route.Chosen + " explicit Seraphim route");
		}
	}

	private static void ValidatePlatoonSource(string source)
	{
		ValidateUpstreamAiSource(source, "AI platoon functions");
		RequireExactly(source, "-- Supreme Commander Overhaul generator buildability 1.1.0", 1, "generator-buildability marker");
		RequireExactly(source, "function subPlanStartMoveToBuildDestination(unit, placeToBuild, reserveEcoTpId, issueBuild)", 1, "build-move function");
		RequireExactly(source, "{tpId = unit.platoon.ai.nextBuildingtpIds[unit.factionTag], armyId = unit.army.id }", 0, "unguarded queued BUILD payload");
		RequireExactly(source, "{tpId = reserveEcoTpId, armyId = unit.army.id }", 1, "guarded queued BUILD payload");
		RequireExactly(source, "subPlanStartMoveToBuildDestination(builder, platoon.ai.placeToBuild, platoon.ai.nextBuildingtpIds[builder.factionTag],", 0, "unsafe build-move argument");
		RequireExactly(source, "subPlanStartMoveToBuildDestination(builder, platoon.ai.placeToBuild, platoon.ai.nextBuildingtpIds and platoon.ai.nextBuildingtpIds[builder.factionTag],", 1, "safe build-move argument");
		RequireExactly(source, "builder.ai.orderText = \"No path, need transport! [\"..builder.platoon.ai.nextBuildingtpIds[builder.factionTag]..\"]\"", 0, "unsafe no-path debug text");
		RequireExactly(source, "builder.ai.orderText = \"No path, need transport! [\"..repr(builder.platoon.ai.nextBuildingtpIds and builder.platoon.ai.nextBuildingtpIds[builder.factionTag])..\"]\"", 1, "safe no-path debug text");
		RequireExactly(source, "missing valid faction-owned build template; refusing BUILD order", 1, "fail-closed BUILD diagnostic");
		RequireExactly(source, "not Tags[unit.factionTag][reserveEcoTpId]", 1, "faction-ownership check");
	}

	private static void ValidateUpstreamAiSource(string source, string description)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Seraphim AI compatibility 1.0.0", 1, description + " SCOM marker");
	}

	private static TagBlock ValidateFactoryTemplateSource(string source, FactoryTagRoute route, bool expectFactoryTag)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0", 1, route.TargetId + " SCOM Aeon marker");
		RequireExactly(source, "and UnitTemplate.general.tpId == \"" + route.TargetId + "\"", 1, route.TargetId + " generated identity assertion");
		RequireExactly(source, "sourceId = \"" + route.SourceId + "\",", 1, route.TargetId + " FA source identity");
		RequireExactly(source, "targetId = \"" + route.TargetId + "\",", 1, route.TargetId + " source-contract target identity");
		RequireExactly(source, "UnitTemplate.construction.canBuild = \"" + route.CanBuild + "\"", 1, route.TargetId + " production domain");
		RequireExactly(source, "-- Supreme Commander Overhaul generator buildability 1.1.0", expectFactoryTag ? 1 : 0, route.TargetId + " generator-buildability marker");
		TagBlock tagBlock = ReadTagBlock(source, route.TargetId);
		RequireTag(tagBlock.Tags, "CHOSEN", route.TargetId);
		RequireTag(tagBlock.Tags, "FACTORY", route.TargetId);
		RequireTag(tagBlock.Tags, route.DomainTag, route.TargetId);
		string[] array = tagBlock.Tags.Where((string tag) => FactoryDomainTags.Contains<string>(tag, StringComparer.Ordinal)).ToArray();
		if (expectFactoryTag)
		{
			if (array.Length != 1 || !string.Equals(array[0], route.FactoryTag, StringComparison.Ordinal))
			{
				throw Incompatible(route.TargetId + " must contain only " + route.FactoryTag + ".");
			}
		}
		else if (array.Length != 0)
		{
			throw Incompatible(route.TargetId + " unexpectedly already contains a domain-factory tag.");
		}
		return tagBlock;
	}

	private static TagBlock ReadTagBlock(string source, string targetId)
	{
		RequireExactly(source, "UnitTemplate.tags = {\n", 1, targetId + " generated tag block");
		int num = source.IndexOf("UnitTemplate.tags = {\n", StringComparison.Ordinal);
		int num2 = num + "UnitTemplate.tags = {\n".Length;
		int num3 = source.IndexOf("\n}", num2, StringComparison.Ordinal);
		if (num3 < num2)
		{
			throw Incompatible(targetId + " generated tag block has no closing brace.");
		}
		string[] array = source.Substring(num2, num3 - num2).Split(new char[1] { '\n' }, StringSplitOptions.RemoveEmptyEntries);
		List<string> list = new List<string>(array.Length);
		string[] array2 = array;
		foreach (string text in array2)
		{
			if (!text.StartsWith("    \"", StringComparison.Ordinal) || !text.EndsWith("\",", StringComparison.Ordinal) || text.Length <= 7)
			{
				throw Incompatible(targetId + " generated tag block contains a non-canonical line.");
			}
			string text2 = text.Substring(5, text.Length - 7);
			if (text2.Length == 0 || text2.Any(delegate(char character)
			{
				switch (character)
				{
				default:
					if (character >= '0')
					{
						return character > '9';
					}
					return true;
				case 'A':
				case 'B':
				case 'C':
				case 'D':
				case 'E':
				case 'F':
				case 'G':
				case 'H':
				case 'I':
				case 'J':
				case 'K':
				case 'L':
				case 'M':
				case 'N':
				case 'O':
				case 'P':
				case 'Q':
				case 'R':
				case 'S':
				case 'T':
				case 'U':
				case 'V':
				case 'W':
				case 'X':
				case 'Y':
				case 'Z':
				case '_':
					return false;
				}
			}))
			{
				throw Incompatible(targetId + " contains an invalid generated tag.");
			}
			list.Add(text2);
		}
		if (list.Count == 0 || list.Distinct(StringComparer.Ordinal).Count() != list.Count || !list.SequenceEqual(list.OrderBy<string, string>((string tag) => tag, StringComparer.Ordinal)))
		{
			throw Incompatible(targetId + " generated tags must be nonempty, unique, and ordinal-sorted.");
		}
		return new TagBlock(num, num3 + 2, list.ToArray());
	}

	private static string RenderTagBlock(IEnumerable<string> tags)
	{
		StringBuilder stringBuilder = new StringBuilder("UnitTemplate.tags = {\n");
		foreach (string tag in tags)
		{
			stringBuilder.Append("    \"").Append(tag).AppendLine("\",");
		}
		stringBuilder.Append('}');
		return stringBuilder.ToString();
	}

	private static void RequireTag(IReadOnlyCollection<string> tags, string requiredTag, string targetId)
	{
		if (!tags.Contains<string>(requiredTag, StringComparer.Ordinal))
		{
			throw Incompatible(targetId + " is missing required tag " + requiredTag + ".");
		}
	}

	private static void ValidateFactoryTagRoutes()
	{
		if (AeonFactoryTagRoutes.Length != 10 || AeonFactoryTagRoutes.Select((FactoryTagRoute route) => route.TargetId).Distinct<string>(StringComparer.Ordinal).Count() != AeonFactoryTagRoutes.Length || AeonFactoryTagRoutes.Select((FactoryTagRoute route) => route.SourceId).Distinct<string>(StringComparer.Ordinal).Count() != AeonFactoryTagRoutes.Length || AeonFactoryTagRoutes.Count((FactoryTagRoute route) => route.FactoryTag == "LAND_FACTORY") != 3 || AeonFactoryTagRoutes.Count((FactoryTagRoute route) => route.FactoryTag == "AIR_FACTORY") != 4 || AeonFactoryTagRoutes.Count((FactoryTagRoute route) => route.FactoryTag == "NAVAL_FACTORY") != 3 || AeonFactoryTagRoutes.Any((FactoryTagRoute route) => !FactoryDomainTags.Contains<string>(route.FactoryTag, StringComparer.Ordinal) || !route.FactoryTag.StartsWith(route.DomainTag + "_", StringComparison.Ordinal) || string.IsNullOrWhiteSpace(route.CanBuild)))
		{
			throw new InvalidOperationException("The generated Aeon production-factory tag manifest is invalid.");
		}
	}

	private static string BuildAiAppendix(bool useBuilderOverrides)
	{
		if (SeraphimRoutes.Length != 82 || SeraphimRoutes.Select((Route route2) => route2.Chosen).Distinct<string>(StringComparer.Ordinal).Count() != SeraphimRoutes.Length || SeraphimRoutes.Select((Route route2) => route2.Seraphim).Distinct<string>(StringComparer.Ordinal).Count() != SeraphimRoutes.Length || SeraphimRoutes.Any((Route route2) => !route2.Chosen.StartsWith("uc", StringComparison.Ordinal) || !string.Equals(route2.Seraphim, "us" + route2.Chosen.Substring(2), StringComparison.Ordinal)))
		{
			throw new InvalidOperationException("The explicit Seraphim route manifest is invalid.");
		}
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.Append("\n\n").Append("-- Supreme Commander Overhaul generator buildability 1.1.0").Append('\n');
		stringBuilder.AppendLine("-- Add only registered fourth-faction counterparts. Unmapped Chosen choices");
		stringBuilder.AppendLine("-- remain unavailable, and no EDA/Guard cross-faction fallback is issued.");
		stringBuilder.AppendLine("local SCO_GeneratorSeraphimByChosen = {");
		Route[] seraphimRoutes = SeraphimRoutes;
		foreach (Route route in seraphimRoutes)
		{
			stringBuilder.Append("    [\"").Append(route.Chosen).Append("\"] = \"")
				.Append(route.Seraphim)
				.AppendLine("\",");
		}
		stringBuilder.AppendLine("}");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_GeneratorValidSeraphimId(tpId)");
		stringBuilder.AppendLine("    return type(tpId) == \"string\"");
		stringBuilder.AppendLine("        and UnitTemplates[tpId] ~= nil");
		stringBuilder.AppendLine("        and AvailableUnits[tpId] == true");
		stringBuilder.AppendLine("        and Tags.SERAPHIM ~= nil");
		stringBuilder.AppendLine("        and Tags.SERAPHIM[tpId] == true");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_GeneratorIsSeraphimArmy(armyIndex)");
		stringBuilder.AppendLine("    return Armies[armyIndex] ~= nil");
		stringBuilder.AppendLine("        and Armies[armyIndex].faction == 4");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local function SCO_GeneratorAliasBuildEntries(buildList, armyIndex)");
		stringBuilder.AppendLine("    if type(buildList) ~= \"table\" then");
		stringBuilder.AppendLine("        return buildList");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("    local requireSeraphim = SCO_GeneratorIsSeraphimArmy(armyIndex)");
		stringBuilder.AppendLine("    local aliased = {}");
		stringBuilder.AppendLine("    for _, buildEntry in ipairs(buildList) do");
		stringBuilder.AppendLine("        if type(buildEntry) == \"table\" then");
		stringBuilder.AppendLine("            local copy = {}");
		stringBuilder.AppendLine("            for factionName, tpId in pairs(buildEntry) do");
		stringBuilder.AppendLine("                copy[factionName] = tpId");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("            if not SCO_GeneratorValidSeraphimId(copy.SERAPHIM) then");
		stringBuilder.AppendLine("                copy.SERAPHIM = nil");
		stringBuilder.AppendLine("                local seraphimId = SCO_GeneratorSeraphimByChosen[copy.CHOSEN]");
		stringBuilder.AppendLine("                if SCO_GeneratorValidSeraphimId(seraphimId) then");
		stringBuilder.AppendLine("                    copy.SERAPHIM = seraphimId");
		stringBuilder.AppendLine("                end");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("            if not requireSeraphim or copy.SERAPHIM ~= nil then");
		stringBuilder.AppendLine("                aliased[#aliased + 1] = copy");
		stringBuilder.AppendLine("            end");
		stringBuilder.AppendLine("        elseif not requireSeraphim then");
		stringBuilder.AppendLine("            aliased[#aliased + 1] = buildEntry");
		stringBuilder.AppendLine("        end");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("    if #aliased == 0 then");
		stringBuilder.AppendLine("        return false");
		stringBuilder.AppendLine("    end");
		stringBuilder.AppendLine("    return aliased");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local SCO_GeneratorPreviousGetWantUnits = GetWantUnits");
		stringBuilder.AppendLine("function GetWantUnits(armyIndex, baseName, formerTable)");
		stringBuilder.AppendLine("    return SCO_GeneratorAliasBuildEntries(");
		stringBuilder.AppendLine("        SCO_GeneratorPreviousGetWantUnits(armyIndex, baseName, formerTable),");
		stringBuilder.AppendLine("        armyIndex)");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine();
		stringBuilder.AppendLine("local SCO_GeneratorPreviousGetWantStructures = GetWantStructures");
		string text = (useBuilderOverrides ? "armyIndex, baseName, formerTable, assignedBuilderOverride, maximumBuilderCountOverride" : "armyIndex, baseName, formerTable");
		stringBuilder.AppendLine("function GetWantStructures(" + text + ")");
		stringBuilder.AppendLine("    return SCO_GeneratorAliasBuildEntries(");
		stringBuilder.AppendLine("        SCO_GeneratorPreviousGetWantStructures(" + text + "),");
		stringBuilder.AppendLine("        armyIndex)");
		stringBuilder.AppendLine("end");
		return stringBuilder.ToString();
	}

	private static string BuildPlatoonGuard()
	{
		return "\n    if issueBuild\n        and (\n            type(reserveEcoTpId) ~= \"string\"\n            or UnitTemplates[reserveEcoTpId] == nil\n            or unit.factionTag == nil\n            or Tags[unit.factionTag] == nil\n            or not Tags[unit.factionTag][reserveEcoTpId]\n        )\n    then\n        AILog(\n            \"- WARNING: Fn subPlanStartMoveToBuildDestination(): missing valid faction-owned build template; refusing BUILD order for \"\n                .. repr(unit.factionTag)\n                .. \" / \" .. repr(reserveEcoTpId),\n            unit.platoon.ai.formerTable.DebugPlatoon)\n        return \"Disband\"\n    end";
	}

	private static List<MutationPlan> BuildMutationPlans(object cache)
	{
		ValidateFactoryTagRoutes();
		List<MutationPlan> list = new List<MutationPlan>();
		List<MutationPlan> list2 = new List<MutationPlan>();
		string text = "LJ/lua/AI/AIFunctions.lua";
		try
		{
			CacheResource cachedResource = GetCachedResource(cache, text);
			QueueIfChanged(list2, cachedResource, PatchAIFunctionsSource(ReadText(cachedResource.Value)));
			string[] platoonPaths = PlatoonPaths;
			for (int i = 0; i < platoonPaths.Length; i++)
			{
				text = platoonPaths[i];
				try
				{
					cachedResource = GetCachedResource(cache, text);
				}
				catch (FileNotFoundException ex) when (string.Equals(ex.FileName, text, StringComparison.Ordinal))
				{
					throw Incompatible("Optional AI profile source is not cached: " + text);
				}
				QueueIfChanged(list2, cachedResource, PatchPlatoonSource(ReadText(cachedResource.Value)));
			}
			list.AddRange(list2);
		}
		catch (CompatibilityException ex2)
		{
			Log("WARNING: Skipped optional generator AI compatibility edits; cached AI sources are unchanged. " + text + ": " + ex2.Message + " Unit registration will continue.");
		}
		FactoryTagRoute[] aeonFactoryTagRoutes = AeonFactoryTagRoutes;
		foreach (FactoryTagRoute factoryTagRoute in aeonFactoryTagRoutes)
		{
			CacheResource cachedResource2 = GetCachedResource(cache, factoryTagRoute.Path);
			QueueIfChanged(list, cachedResource2, PatchFactoryTemplateSource(ReadText(cachedResource2.Value), factoryTagRoute.TargetId));
		}
		return list;
	}

	private static void QueueIfChanged(ICollection<MutationPlan> plans, CacheResource resource, string newSource)
	{
		string text = ReadText(resource.Value);
		if (!string.Equals(text, newSource, StringComparison.Ordinal))
		{
			plans.Add(new MutationPlan(resource.Path, resource.Value, text, newSource));
		}
	}

	private static void Commit(object cache, IReadOnlyList<MutationPlan> plans)
	{
		try
		{
			foreach (MutationPlan plan in plans)
			{
				plan.Replacement = CreateNativeArrayFromText(plan.Stock.GetType(), plan.NewSource);
			}
		}
		catch
		{
			foreach (MutationPlan item in plans.Where((MutationPlan plan) => plan.Replacement != null))
			{
				TryDispose(item.Replacement, "uncommitted " + item.Path);
			}
			throw;
		}
		try
		{
			foreach (MutationPlan plan2 in plans)
			{
				plan2.AssignmentAttempted = true;
				SetCachedResource(cache, plan2.Path, plan2.Replacement);
				if (!string.Equals(ReadText(GetExactCachedResource(cache, plan2.Path)), plan2.NewSource, StringComparison.Ordinal))
				{
					throw new InvalidOperationException("Cache write verification failed for " + plan2.Path + ".");
				}
			}
		}
		catch (Exception ex)
		{
			List<Exception> list = RollBack(cache, plans);
			if (list.Count != 0)
			{
				throw new RollbackException(ex, list);
			}
			foreach (MutationPlan plan3 in plans)
			{
				TryDispose(plan3.Replacement, "rolled-back " + plan3.Path);
			}
			throw new InvalidOperationException("Generator-buildability cache transaction failed and was rolled back.", ex);
		}
		foreach (MutationPlan plan4 in plans)
		{
			TryDispose(plan4.Stock, "replaced " + plan4.Path);
		}
	}

	private static List<Exception> RollBack(object cache, IReadOnlyList<MutationPlan> plans)
	{
		List<Exception> list = new List<Exception>();
		for (int num = plans.Count - 1; num >= 0; num--)
		{
			MutationPlan mutationPlan = plans[num];
			if (mutationPlan.AssignmentAttempted)
			{
				try
				{
					SetCachedResource(cache, mutationPlan.Path, mutationPlan.Stock);
					if (!string.Equals(ReadText(GetExactCachedResource(cache, mutationPlan.Path)), mutationPlan.OldSource, StringComparison.Ordinal))
					{
						throw new InvalidOperationException("Cache rollback verification failed for " + mutationPlan.Path + ".");
					}
				}
				catch (Exception item)
				{
					list.Add(item);
				}
			}
		}
		return list;
	}

	private static void ValidateUpstreamIdentity()
	{
		CachePatcher.ValidateMvid(FindLoadedType("EM.Lua.FilesCache").Module.ModuleVersionId);
		CanonicalAssemblyContract.RequireCanonicalTypes("SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime", "SupremeCommanderOverhaulGeneratorBuildability.CachePatcherRuntime");
	}

	private static void ValidateAssemblyIdentity(Assembly assembly, string expectedMvid, long expectedBytes, string expectedSha256, string description)
	{
		string text = assembly.ManifestModule.ModuleVersionId.ToString("D");
		if (!string.Equals(text, expectedMvid, StringComparison.OrdinalIgnoreCase))
		{
			throw Incompatible(description + " MVID drifted: expected " + expectedMvid + ", found " + text + ".");
		}
		string location = assembly.Location;
		if (string.IsNullOrWhiteSpace(location) || !File.Exists(location))
		{
			throw Incompatible(description + " has no verifiable file location.");
		}
		FileInfo fileInfo = new FileInfo(location);
		if (fileInfo.Length != expectedBytes)
		{
			throw Incompatible($"{description} size drifted: expected {expectedBytes}, found {fileInfo.Length}.");
		}
		using FileStream inputStream = File.OpenRead(location);
		using SHA256 sHA = SHA256.Create();
		string text2 = BitConverter.ToString(sHA.ComputeHash(inputStream)).Replace("-", "");
		if (!string.Equals(text2, expectedSha256, StringComparison.OrdinalIgnoreCase))
		{
			throw Incompatible(description + " SHA-256 drifted: expected " + expectedSha256 + ", found " + text2 + ".");
		}
	}

	private static Type FindLoadedType(string fullName)
	{
		Type[] array = (from assembly in AppDomain.CurrentDomain.GetAssemblies()
			select assembly.GetType(fullName, throwOnError: false) into type
			where type != null
			select type).Cast<Type>().ToArray();
		if (array.Length != 1)
		{
			throw Incompatible($"Expected one loaded {fullName} type, found {array.Length}.");
		}
		return array[0];
	}

	private static object GetLuaFileCache()
	{
		Type type = FindLoadedType("EM.Lua.FilesCache");
		return (type.GetField("pathToFileContents", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "pathToFileContents")).GetValue(null) ?? throw new InvalidOperationException("Sanctuary created no Lua file cache.");
	}

	private static CacheResource GetCachedResource(object cache, string relativePath)
	{
		string value = "/" + relativePath.Replace('\\', '/');
		CacheResource cacheResource = null;
		foreach (object item in (IEnumerable)cache)
		{
			Type type = item.GetType();
			if (type.GetProperty("Key")?.GetValue(item, null) is string text && text.Replace('\\', '/').EndsWith(value, StringComparison.OrdinalIgnoreCase))
			{
				if (cacheResource != null)
				{
					throw Incompatible("Multiple cache resources match " + relativePath + ".");
				}
				object obj = type.GetProperty("Value")?.GetValue(item, null) ?? throw new InvalidOperationException("Cached " + relativePath + " has no value.");
				EnsureCreated(obj, relativePath);
				cacheResource = new CacheResource(text, obj);
			}
		}
		return cacheResource ?? throw new FileNotFoundException("Required cached Lua source is unavailable.", relativePath);
	}

	private static string ReadText(object resource)
	{
		EnsureCreated(resource, "Lua resource");
		byte[] bytes = ((resource.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray")).Invoke(resource, null) as byte[]) ?? throw new InvalidOperationException("NativeArray.ToArray returned null.");
		return Encoding.UTF8.GetString(bytes);
	}

	private static object CreateNativeArrayFromText(Type nativeArrayType, string source)
	{
		if (!nativeArrayType.IsGenericType || nativeArrayType.GetGenericArguments().Length != 1 || nativeArrayType.GetGenericArguments()[0] != typeof(byte))
		{
			throw new ArgumentException("Expected Unity NativeArray<byte>.", "nativeArrayType");
		}
		Type type = nativeArrayType.Assembly.GetType("Unity.Collections.Allocator", throwOnError: false) ?? (from assembly in AppDomain.CurrentDomain.GetAssemblies()
			select assembly.GetType("Unity.Collections.Allocator", throwOnError: false)).FirstOrDefault((Type type2) => type2 != null) ?? throw new TypeLoadException("Unity.Collections.Allocator is unavailable.");
		return (nativeArrayType.GetConstructor(BindingFlags.Instance | BindingFlags.Public, null, new Type[2]
		{
			typeof(byte[]),
			type
		}, null) ?? throw new MissingMethodException(nativeArrayType.FullName, ".ctor(Byte[], Allocator)")).Invoke(new object[2]
		{
			Encoding.UTF8.GetBytes(source),
			Enum.Parse(type, "Persistent")
		});
	}

	private static void EnsureCreated(object resource, string description)
	{
		object value = (resource.GetType().GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(resource.GetType().FullName, "IsCreated")).GetValue(resource, null);
		if (!(value is bool) || !(bool)value)
		{
			throw new InvalidOperationException("Cached " + description + " is not initialized.");
		}
	}

	private static void SetCachedResource(object cache, string path, object value)
	{
		(cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).SetValue(cache, value, new object[1] { path });
	}

	private static object GetExactCachedResource(object cache, string path)
	{
		return (cache.GetType().GetProperty("Item", BindingFlags.Instance | BindingFlags.Public) ?? throw new MissingMemberException(cache.GetType().FullName, "Item")).GetValue(cache, new object[1] { path }) ?? throw new InvalidOperationException("Cache returned null for " + path + ".");
	}

	private static void TryDispose(object resource, string description)
	{
		try
		{
			Type type = resource.GetType();
			object obj = type.GetProperty("IsCreated", BindingFlags.Instance | BindingFlags.Public)?.GetValue(resource, null);
			if (obj is bool && (bool)obj)
			{
				(type.GetMethod("Dispose", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(type.FullName, "Dispose")).Invoke(resource, null);
			}
		}
		catch (Exception ex)
		{
			Log("NativeArray cleanup warning for " + description + ": " + ex.GetBaseException().Message);
		}
	}

	private static string ReplaceExactly(string source, string oldValue, string newValue, string description)
	{
		RequireExactly(source, oldValue, 1, description);
		return source.Replace(oldValue, newValue);
	}

	private static string Normalize(string source)
	{
		return source.Replace("\r\n", "\n").Replace("\r", "\n");
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

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int num = Count(source, token);
		if (num != expected)
		{
			throw Incompatible($"Expected {expected} {description}, found {num}.");
		}
	}

	private static CompatibilityException Incompatible(string message)
	{
		return new CompatibilityException(message);
	}

	private static void Log(string message)
	{
		string text = "[SCOM Generator Buildability] " + message;
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
				select assembly.GetType("UnityEngine.Debug", throwOnError: false)).FirstOrDefault((Type type) => type != null)?.GetMethod("Log", new Type[1] { typeof(object) })?.Invoke(null, new object[1] { text });
		}
		catch
		{
		}
	}
}
