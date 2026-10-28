using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using SupremeCommanderOverhaulCanonical;

namespace SupremeCommanderOverhaulBuildBoxParity;

public static class CachePatcherRuntime
{
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
			: base("Build-box parity cache commit and rollback both failed.", new Exception[1] { commitError }.Concat<Exception>(rollbackErrors))
		{
		}
	}

	public const string Marker = "-- Supreme Commander Overhaul FA build-box parity 1.0.0";

	public const string UpstreamPlacementMarker = "-- Supreme Commander Overhaul Structure Placement Contract 1.0.1";

	public const string UpstreamAeonMarker = "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0";

	public const string PlacementUtilsPath = "LJ/lua/common/systems/placementUtils.lua";

	public const string ConstructionPreviewPath = "LJ/lua/client/input/constructionPreviewSystem.lua";

	public const string HostFactoryBasePath = "LJ/lua/host/units/unitsClasses/unitsDefault.lua";

	public const string GuardFactoryHostPath = "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua";

	public const string EdaFactoryHostPath = "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua";

	public const string ChosenFactoryHostPath = "LJ/lua/host/units/unitsClasses/unitsDefaultChosen.lua";

	public const string SeraphimFactoryHostPath = "LJ/lua/host/units/unitsClasses/unitsDefaultSeraphim.lua";

	public const string ExpectedScomSha256 = "3EED7306200D5910786221547FF0FB959FA8CF92C85C99D62B98A12175C28B76";

	public const string ExpectedScomMvid = "48dd1991-b31b-4297-bd60-0597d33328b5";

	public const long ExpectedScomBytes = 3819520L;

	public const string ExpectedGeneratorSha256 = "4981EFE18ECF6BE6F47DF8996564808B0AC8C7CF22FADAF6F1490B44B34D355C";

	public const string ExpectedGeneratorMvid = "29e22108-0a14-4ec3-be24-b65214f2ecf5";

	public const long ExpectedGeneratorBytes = 56832L;

	public const string ExpectedSeraphimEcoSha256 = "2EB868C66855BE18CC051CD5A961DD7B95AC2FE4338985F2DE56E6F132DBFEF7";

	public const string ExpectedSeraphimEcoMvid = "7674a016-d61a-401d-8cdc-71f17bcaf2bc";

	public const long ExpectedSeraphimEcoBytes = 36864L;

	public const string ExpectedAudioCompatSha256 = "3D44C760EB3088BADC89A841A4951B12910F04BDBBF5734F3FF92FA3C50574AA";

	public const string ExpectedAudioCompatMvid = "04ece079-4982-4ceb-b33d-91e62f2511f5";

	public const long ExpectedAudioCompatBytes = 65024L;

	private const string ScomRuntimeType = "SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime";

	private const string GeneratorRuntimeType = "SupremeCommanderOverhaulGeneratorBuildability.CachePatcherRuntime";

	private const string SeaParityRuntimeType = "SupremeCommanderOverhaulSeaParity.CachePatcherRuntime";

	private const string SeraphimEcoRuntimeType = "SupremeCommanderOverhaulSeraphimEcoBuildUi.CachePatcherRuntime";

	private const string AudioCompatRuntimeType = "SupremeCommanderOverhaulAudioCompat.CachePatcherRuntime";

	private const string UpstreamStructuresMarker = "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1";

	private const string UpstreamSeraphimMarker = "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0";

	private const string UpstreamSeraphimModuleMarker = "-- Virtual unitsDefaultSeraphim module for the true fourth faction.";

	private const string UpstreamSeraphimFactoryCompatMarker = "-- Supreme Commander Overhaul Seraphim Land Factory Compatibility 1.0.0";

	private const string UpstreamSeraphimDeathCompatMarker = "-- Supreme Commander Overhaul Seraphim Death Animation Compatibility 1.0.0";

	public const string FactoryStagingMarker = "-- Supreme Commander Overhaul factory staging hook 1.0.2";

	private const string FactoryProductionEntry = "function HostFactory:ProductionBehaviorBuildOne(item)";

	private const string FactorySpawnCall = "    local spawnPoint = self:GetConstructionSpawnPoint()";

	private const string FactorySpawnHook = "function HostFactory:GetConstructionSpawnPoint()";

	private const string GuardFactoryClassBinding = "local GuardCybranLandFactory = HostGuardCybranLandFactory\n";

	private const string GuardLegacySpawnHook = "function GuardCybranLandFactory:GetRollOffPoint()";

	private const string GuardCurrentSpawnHook = "function GuardCybranLandFactory:GetConstructionSpawnPoint()";

	private const string GuardLegacyBaseSpawn = "return GuardLandFactory.GetRollOffPoint(self)";

	private const string GuardCurrentBaseSpawn = "return GuardLandFactory.GetConstructionSpawnPoint(self)";

	private const string EdaFactoryClassBinding = "local EDAUefLandFactory = HostEDAUefLandFactory";

	private const string EdaLegacySpawnHook = "function EDAUefLandFactory:GetRollOffPoint()";

	private const string EdaCurrentSpawnHook = "function EDAUefLandFactory:GetConstructionSpawnPoint()";

	private const string EdaLegacyBaseSpawn = "return EDALandFactory.GetRollOffPoint(self)";

	private const string EdaCurrentBaseSpawn = "return EDALandFactory.GetConstructionSpawnPoint(self)";

	private const string FatboyLegacySpawnHook = "function EDAFatboyMobileFactory:GetRollOffPoint()";

	private const string FatboyCurrentSpawnHook = "function EDAFatboyMobileFactory:GetConstructionSpawnPoint()";

	private const string AeonFactoryAdapterBinding = "local function scoAdaptAeonFactoryClass(factoryClass, baseClass)";

	private const string AeonLegacyAdapterHook = "factoryClass.GetRollOffPoint = function(self)";

	private const string AeonCurrentAdapterHook = "factoryClass.GetConstructionSpawnPoint = function(self)";

	private const string AeonLegacyBaseSpawn = "return baseClass.GetRollOffPoint(self)";

	private const string AeonCurrentBaseSpawn = "return baseClass.GetConstructionSpawnPoint(self)";

	private const string CzarLegacySpawnHook = "function AeonPortCzar:GetRollOffPoint()";

	private const string CzarCurrentSpawnHook = "function AeonPortCzar:GetConstructionSpawnPoint()";

	private const string SeraphimLegacySpawnHook = "function SeraphimNavalFactory:GetRollOffPoint()";

	private const string SeraphimCurrentSpawnHook = "function SeraphimNavalFactory:GetConstructionSpawnPoint()";

	private const string SeraphimLegacyBaseSpawn = "return ChosenNavalFactory.GetRollOffPoint(self)";

	private const string SeraphimCurrentBaseSpawn = "return ChosenNavalFactory.GetConstructionSpawnPoint(self)";

	private const string OldFactoryStagingBody = "    local point = self:GetPosition()\n    point.x = point.x + offset.x\n    point.y = point.y + offset.y\n    point.z = point.z + offset.z\n    return point";

	private const string NewFactoryStagingBody = "    local rotated = Engine.QuaternionRotateVector(\n        self:GetOrientation(),\n        EngineClasses.float3(\n            offset.x or 0,\n            offset.y or 0,\n            offset.z or 0))\n    local origin = self:GetPosition()\n    return EngineClasses.float3(\n        origin.x + rotated.x,\n        origin.y + rotated.y,\n        origin.z + rotated.z)";

	private const string OldFactoryRampPositionBody = "    local factoryPosition = factory:GetPosition()\n    return EngineClasses.float3(\n        factoryPosition.x + (offset.x or 0),\n        factoryPosition.y + (offset.y or 0),\n        factoryPosition.z + (offset.z or 0)\n    )";

	private const string NewFactoryRampPositionBody = "    local rotated = Engine.QuaternionRotateVector(\n        factory:GetOrientation(),\n        EngineClasses.float3(\n            offset.x or 0,\n            offset.y or 0,\n            offset.z or 0))\n    local origin = factory:GetPosition()\n    return EngineClasses.float3(\n        origin.x + rotated.x,\n        origin.y + rotated.y,\n        origin.z + rotated.z)";

	private const string OldFactoryHeadingBody = "    if ramp.headingDegrees then\n        local orientation = Engine.EulerToQuaternion(\n            EngineClasses.float3(0, math.rad(ramp.headingDegrees), 0),\n            RotationOrder.Default\n        )\n        Engine.SetGlobalEntityLocalRotation(targetUnit.id, orientation)\n        return\n    end";

	private const string NewFactoryHeadingBody = "    if ramp.headingDegrees then\n        local localOrientation = Engine.EulerToQuaternion(\n            EngineClasses.float3(0, math.rad(ramp.headingDegrees), 0),\n            RotationOrder.Default)\n        local orientation = Engine.QuaternionMultiply(\n            factory:GetOrientation(),\n            localOrientation)\n        targetUnit:SetOrientation(orientation)\n        return\n    end";

	private const string OldBoundsX = "    local minX = math.floor(position.x - skirtSize.x / 2)";

	private const string OldBoundsZ = "    local minY = math.floor(position.z - skirtSize.y / 2)";

	private const string NewBoundsX = "    local minX = math.floor(position.x) - math.floor(skirtSize.x / 2)";

	private const string NewBoundsZ = "    local minY = math.floor(position.z) - math.floor(skirtSize.y / 2)";

	private const string OldPreviewBounds = "            local minX = math.floor(position.x - unitTemplate.skirtSize.x / 2)\n            local minZ = math.floor(position.z - unitTemplate.skirtSize.y / 2)";

	private const string NewPreviewBounds = "            local minX, minZ = PlacementUtils.GetPlacementBounds(\n                position, unitTemplate.skirtSize)";

	private const string SeaParityMarker = "-- Supreme Commander Overhaul sea parity 1.0.0";

	private const string SeaParityFactorySpawnCall = "targetUnit:SetPosition(self:GetConstructionSpawnPoint())";

	private const string SeaParityOldPreviewBounds = "            local minX = math.floor(position.x - SCOSeaParityPlacementSize(unitTemplate).x / 2)\n            local minZ = math.floor(position.z - SCOSeaParityPlacementSize(unitTemplate).y / 2)";

	private const string SeaParityNewPreviewBounds = "            local minX, minZ = PlacementUtils.GetPlacementBounds(\n                position, SCOSeaParityPlacementSize(unitTemplate))";

	private static bool _isApplied;

	public static IReadOnlyList<string> ManagedPaths => BuildBoxManifest.ManagedPaths.Concat<string>(new string[7] { "LJ/lua/common/systems/placementUtils.lua", "LJ/lua/client/input/constructionPreviewSystem.lua", "LJ/lua/host/units/unitsClasses/unitsDefault.lua", "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", "LJ/lua/host/units/unitsClasses/unitsDefaultChosen.lua", "LJ/lua/host/units/unitsClasses/unitsDefaultSeraphim.lua" }).ToArray();

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
				Log("All 137 SCOM structure build boxes, shared grid bounds, and 20 imported factory spawn hooks are already exact.");
			}
			else
			{
				Commit(luaFileCache, list);
				_isApplied = true;
				Log("Applied exact FA Physics.SkirtSize to all 137 SCOM structures and aligned Lua/preview bounds with Trebuchet's grid reservation; all stale imported factory construction-spawn hooks now use Sanctuary's live API.");
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

	public static string PatchTemplateSource(string source, BuildBoxSpec spec)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		if (spec == null)
		{
			throw new ArgumentNullException("spec");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul FA build-box parity 1.0.0");
		switch (num)
		{
		case 1:
			ValidatePatchedTemplate(text, spec);
			return text;
		default:
			throw Incompatible($"Template '{spec.TargetId}' has {num} build-box parity markers.");
		case 0:
		{
			if (spec.IsAeon)
			{
				RequireExactly(text, "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0", 1, spec.TargetId + " upstream Aeon marker");
				RequireExactly(text, "    sourceId = \"" + spec.SourceId + "\",", 1, spec.TargetId + " Aeon source mapping");
			}
			else
			{
				RequireExactly(text, "-- Supreme Commander Overhaul Structure Placement Contract 1.0.1", 1, spec.TargetId + " upstream placement marker");
				RequireExactly(text, "-- " + spec.TargetId + " <- " + spec.SourceId + ";", 1, spec.TargetId + " source mapping");
			}
			RequireAtLeast(text, "UnitTemplate.skirtSize = {", 1, spec.TargetId + " upstream skirt assignment");
			string text2 = "\n\n-- Supreme Commander Overhaul FA build-box parity 1.0.0\n-- " + spec.TargetId + " <- " + spec.SourceId + "; " + $"FA Physics.SkirtSize={spec.SizeX}x{spec.SizeZ}; " + "units.scd SHA-256=c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26.\nUnitTemplate.skirtSize = {\n" + $"    x = {spec.SizeX},\n" + $"    y = {spec.SizeZ},\n" + "}\n";
			string text3 = Normalize(text.TrimEnd(Array.Empty<char>()) + text2);
			ValidatePatchedTemplate(text3, spec);
			return text3;
		}
		}
	}

	public static string PatchPlacementUtilsSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul FA build-box parity 1.0.0");
		switch (num)
		{
		case 1:
			ValidatePatchedPlacementUtils(text);
			return text;
		default:
			throw Incompatible($"Placement utilities contain {num} build-box parity markers.");
		case 0:
		{
			RequireExactly(text, "    local minX = math.floor(position.x - skirtSize.x / 2)", 1, "stock X placement bound");
			RequireExactly(text, "    local minY = math.floor(position.z - skirtSize.y / 2)", 1, "stock Z placement bound");
			RequireExactly(text, "    local minX = math.floor(position.x) - math.floor(skirtSize.x / 2)", 0, "Trebuchet-exact X placement bound");
			RequireExactly(text, "    local minY = math.floor(position.z) - math.floor(skirtSize.y / 2)", 0, "Trebuchet-exact Z placement bound");
			string text2 = Normalize(ReplaceExactly(ReplaceExactly(text, "    local minX = math.floor(position.x - skirtSize.x / 2)", "    local minX = math.floor(position.x) - math.floor(skirtSize.x / 2)", "X placement bound"), "    local minY = math.floor(position.z - skirtSize.y / 2)", "    local minY = math.floor(position.z) - math.floor(skirtSize.y / 2)", "Z placement bound").TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul FA build-box parity 1.0.0\n");
			ValidatePatchedPlacementUtils(text2);
			return text2;
		}
		}
	}

	public static string PatchConstructionPreviewSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul FA build-box parity 1.0.0");
		switch (num)
		{
		case 1:
			ValidatePatchedConstructionPreview(text);
			return text;
		default:
			throw Incompatible($"Construction preview contains {num} build-box parity markers.");
		case 0:
		{
			RequireExactly(text, "            local minX, minZ = PlacementUtils.GetPlacementBounds(\n                position, unitTemplate.skirtSize)", 0, "Trebuchet-exact preview cell bounds");
			RequireExactly(text, "            local minX, minZ = PlacementUtils.GetPlacementBounds(\n                position, SCOSeaParityPlacementSize(unitTemplate))", 0, "Sea-Parity-aware Trebuchet-exact preview cell bounds");
			string text2;
			if (Count(text, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
			{
				RequireExactly(text, "            local minX = math.floor(position.x - SCOSeaParityPlacementSize(unitTemplate).x / 2)\n            local minZ = math.floor(position.z - SCOSeaParityPlacementSize(unitTemplate).y / 2)", 1, "Sea-Parity-aware stock preview cell bounds");
				RequireExactly(text, "            local minX = math.floor(position.x - unitTemplate.skirtSize.x / 2)\n            local minZ = math.floor(position.z - unitTemplate.skirtSize.y / 2)", 0, "stock preview cell bounds");
				text2 = ReplaceExactly(text, "            local minX = math.floor(position.x - SCOSeaParityPlacementSize(unitTemplate).x / 2)\n            local minZ = math.floor(position.z - SCOSeaParityPlacementSize(unitTemplate).y / 2)", "            local minX, minZ = PlacementUtils.GetPlacementBounds(\n                position, SCOSeaParityPlacementSize(unitTemplate))", "Sea-Parity-aware preview cell bounds");
			}
			else
			{
				RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, "Sea Parity marker");
				RequireExactly(text, "            local minX = math.floor(position.x - SCOSeaParityPlacementSize(unitTemplate).x / 2)\n            local minZ = math.floor(position.z - SCOSeaParityPlacementSize(unitTemplate).y / 2)", 0, "Sea-Parity-aware stock preview cell bounds");
				RequireExactly(text, "            local minX = math.floor(position.x - unitTemplate.skirtSize.x / 2)\n            local minZ = math.floor(position.z - unitTemplate.skirtSize.y / 2)", 1, "stock preview cell bounds");
				text2 = ReplaceExactly(text, "            local minX = math.floor(position.x - unitTemplate.skirtSize.x / 2)\n            local minZ = math.floor(position.z - unitTemplate.skirtSize.y / 2)", "            local minX, minZ = PlacementUtils.GetPlacementBounds(\n                position, unitTemplate.skirtSize)", "preview cell bounds");
			}
			text2 = Normalize(text2.TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul FA build-box parity 1.0.0\n");
			ValidatePatchedConstructionPreview(text2);
			return text2;
		}
		}
	}

	public static void ValidateHostFactoryBaseSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string source2 = Normalize(source);
		RequireExactly(source2, "function HostFactory:ProductionBehaviorBuildOne(item)", 1, "factory production entry point");
		RequireExactly(source2, "    local spawnPoint = self:GetConstructionSpawnPoint()", 1, "live construction-spawn call");
		RequireExactly(source2, "function HostFactory:GetConstructionSpawnPoint()", 1, "live construction-spawn hook");
	}

	public static string PatchGuardFactoryHostSource(string source)
	{
		return PatchLandFactoryHostSource(source, "Guard/Cybran", "local GuardCybranLandFactory = HostGuardCybranLandFactory\n", "function GuardCybranLandFactory:GetRollOffPoint()", "function GuardCybranLandFactory:GetConstructionSpawnPoint()", "return GuardLandFactory.GetRollOffPoint(self)", "return GuardLandFactory.GetConstructionSpawnPoint(self)", 3, 1, "targetUnit:SetPosition(self:GetConstructionSpawnPoint())", null, null);
	}

	public static string PatchEdaFactoryHostSource(string source)
	{
		return PatchLandFactoryHostSource(source, "EDA/UEF", "local EDAUefLandFactory = HostEDAUefLandFactory", "function EDAUefLandFactory:GetRollOffPoint()", "function EDAUefLandFactory:GetConstructionSpawnPoint()", "return EDALandFactory.GetRollOffPoint(self)", "return EDALandFactory.GetConstructionSpawnPoint(self)", 3, 1, "targetUnit:SetPosition(self:GetConstructionSpawnPoint())", "function EDAFatboyMobileFactory:GetRollOffPoint()", "function EDAFatboyMobileFactory:GetConstructionSpawnPoint()");
	}

	public static string PatchChosenFactoryHostSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul factory staging hook 1.0.2");
		switch (num)
		{
		case 1:
			ValidatePatchedChosenFactoryHost(text);
			return text;
		default:
			throw Incompatible($"Chosen host classes contain {num} factory staging markers.");
		case 0:
		{
			RequireExactly(text, "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0", 1, "Aeon upstream marker");
			RequireExactly(text, "local function scoAdaptAeonFactoryClass(factoryClass, baseClass)", 1, "Aeon factory adapter");
			RequireExactly(text, "factoryClass.GetRollOffPoint = function(self)", 1, "Aeon legacy spawn hook");
			RequireExactly(text, "return baseClass.GetRollOffPoint(self)", 1, "Aeon legacy base fallback");
			RequireExactly(text, "function AeonPortCzar:GetRollOffPoint()", 1, "Czar legacy spawn hook");
			RequireExactly(text, "GetRollOffPoint", 5, "Chosen legacy spawn tokens");
			RequireExactly(text, "GetConstructionSpawnPoint", 0, "Chosen live spawn tokens");
			string text2 = AppendFactoryStagingMarker(ReplaceExactly(text, "GetRollOffPoint", "GetConstructionSpawnPoint", 5, "Chosen construction-spawn tokens"));
			ValidatePatchedChosenFactoryHost(text2);
			return text2;
		}
		}
	}

	public static string PatchSeraphimFactoryHostSource(string source)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul factory staging hook 1.0.2");
		switch (num)
		{
		case 1:
			ValidatePatchedSeraphimFactoryHost(text);
			return text;
		default:
			throw Incompatible($"Seraphim host classes contain {num} factory staging markers.");
		case 0:
		{
			RequireExactly(text, "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", 1, "Seraphim upstream marker");
			RequireExactly(text, "-- Virtual unitsDefaultSeraphim module for the true fourth faction.", 1, "Seraphim virtual module marker");
			RequireExactly(text, "-- Supreme Commander Overhaul Seraphim Land Factory Compatibility 1.0.0", 1, "Seraphim factory compatibility marker");
			RequireExactly(text, "-- Supreme Commander Overhaul Seraphim Death Animation Compatibility 1.0.0", 1, "Seraphim death compatibility marker");
			RequireExactly(text, "function SeraphimNavalFactory:GetRollOffPoint()", 1, "Seraphim naval legacy spawn hook");
			RequireExactly(text, "return ChosenNavalFactory.GetRollOffPoint(self)", 1, "Seraphim naval legacy base fallback");
			RequireExactly(text, "GetRollOffPoint", 2, "Seraphim legacy spawn tokens");
			RequireExactly(text, "GetConstructionSpawnPoint", 0, "Seraphim live spawn tokens");
			string text2 = AppendFactoryStagingMarker(ReplaceExactly(text, "GetRollOffPoint", "GetConstructionSpawnPoint", 2, "Seraphim naval construction-spawn tokens"));
			ValidatePatchedSeraphimFactoryHost(text2);
			return text2;
		}
		}
	}

	private static string PatchLandFactoryHostSource(string source, string family, string classBinding, string legacyHook, string currentHook, string legacyBaseSpawn, string currentBaseSpawn, int expectedLegacyTokenCount, int expectedExistingCurrentTokenCount, string? existingCurrentTokenProof, string? additionalLegacyHook, string? additionalCurrentHook)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		string text = Normalize(source);
		int num = Count(text, "-- Supreme Commander Overhaul factory staging hook 1.0.2");
		switch (num)
		{
		case 1:
			ValidatePatchedFactoryHost(text, family, classBinding, legacyHook, currentHook, currentBaseSpawn, expectedLegacyTokenCount + expectedExistingCurrentTokenCount, existingCurrentTokenProof, additionalCurrentHook);
			return text;
		default:
			throw Incompatible($"{family} host classes contain {num} factory staging markers.");
		case 0:
		{
			RequireExactly(text, "-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1", 1, family + " upstream structures marker");
			RequireExactly(text, classBinding, 1, family + " factory class binding");
			RequireExactly(text, legacyHook, 1, family + " legacy staging hook");
			RequireExactly(text, legacyBaseSpawn, 1, family + " legacy base fallback");
			RequireExactly(text, currentHook, 0, family + " live staging hook");
			RequireExactly(text, "GetRollOffPoint", expectedLegacyTokenCount, family + " legacy spawn tokens");
			RequireExactly(text, "GetConstructionSpawnPoint", expectedExistingCurrentTokenCount, family + " live spawn tokens");
			if (existingCurrentTokenProof != null)
			{
				RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, family + " Sea Parity marker");
				RequireExactly(text, existingCurrentTokenProof, 1, family + " Sea Parity live spawn call");
			}
			if (additionalLegacyHook != null)
			{
				RequireExactly(text, additionalLegacyHook, 1, family + " additional legacy staging hook");
				RequireExactly(text, additionalCurrentHook, 0, family + " additional live staging hook");
			}
			RequireExactly(text, "    local point = self:GetPosition()\n    point.x = point.x + offset.x\n    point.y = point.y + offset.y\n    point.z = point.z + offset.z\n    return point", 1, family + " world-axis staging body");
			RequireExactly(text, "    local factoryPosition = factory:GetPosition()\n    return EngineClasses.float3(\n        factoryPosition.x + (offset.x or 0),\n        factoryPosition.y + (offset.y or 0),\n        factoryPosition.z + (offset.z or 0)\n    )", 1, family + " world-axis ramp body");
			RequireExactly(text, "    if ramp.headingDegrees then\n        local orientation = Engine.EulerToQuaternion(\n            EngineClasses.float3(0, math.rad(ramp.headingDegrees), 0),\n            RotationOrder.Default\n        )\n        Engine.SetGlobalEntityLocalRotation(targetUnit.id, orientation)\n        return\n    end", 1, family + " uncomposed heading body");
			string text2 = AppendFactoryStagingMarker(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(text, "GetRollOffPoint", "GetConstructionSpawnPoint", expectedLegacyTokenCount, family + " construction-spawn tokens"), "    local point = self:GetPosition()\n    point.x = point.x + offset.x\n    point.y = point.y + offset.y\n    point.z = point.z + offset.z\n    return point", "    local rotated = Engine.QuaternionRotateVector(\n        self:GetOrientation(),\n        EngineClasses.float3(\n            offset.x or 0,\n            offset.y or 0,\n            offset.z or 0))\n    local origin = self:GetPosition()\n    return EngineClasses.float3(\n        origin.x + rotated.x,\n        origin.y + rotated.y,\n        origin.z + rotated.z)", family + " orientation-relative staging"), "    local factoryPosition = factory:GetPosition()\n    return EngineClasses.float3(\n        factoryPosition.x + (offset.x or 0),\n        factoryPosition.y + (offset.y or 0),\n        factoryPosition.z + (offset.z or 0)\n    )", "    local rotated = Engine.QuaternionRotateVector(\n        factory:GetOrientation(),\n        EngineClasses.float3(\n            offset.x or 0,\n            offset.y or 0,\n            offset.z or 0))\n    local origin = factory:GetPosition()\n    return EngineClasses.float3(\n        origin.x + rotated.x,\n        origin.y + rotated.y,\n        origin.z + rotated.z)", family + " orientation-relative ramp position"), "    if ramp.headingDegrees then\n        local orientation = Engine.EulerToQuaternion(\n            EngineClasses.float3(0, math.rad(ramp.headingDegrees), 0),\n            RotationOrder.Default\n        )\n        Engine.SetGlobalEntityLocalRotation(targetUnit.id, orientation)\n        return\n    end", "    if ramp.headingDegrees then\n        local localOrientation = Engine.EulerToQuaternion(\n            EngineClasses.float3(0, math.rad(ramp.headingDegrees), 0),\n            RotationOrder.Default)\n        local orientation = Engine.QuaternionMultiply(\n            factory:GetOrientation(),\n            localOrientation)\n        targetUnit:SetOrientation(orientation)\n        return\n    end", family + " composed ramp heading"));
			ValidatePatchedFactoryHost(text2, family, classBinding, legacyHook, currentHook, currentBaseSpawn, expectedLegacyTokenCount + expectedExistingCurrentTokenCount, existingCurrentTokenProof, additionalCurrentHook);
			return text2;
		}
		}
	}

	private static void ValidatePatchedTemplate(string source, BuildBoxSpec spec)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA build-box parity 1.0.0", 1, spec.TargetId + " build-box parity marker");
		int startIndex = source.IndexOf("-- Supreme Commander Overhaul FA build-box parity 1.0.0", StringComparison.Ordinal);
		string source2 = source.Substring(startIndex);
		RequireExactly(source2, "-- " + spec.TargetId + " <- " + spec.SourceId + "; " + $"FA Physics.SkirtSize={spec.SizeX}x{spec.SizeZ}; " + "units.scd SHA-256=c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26.", 1, spec.TargetId + " FA source proof");
		RequireExactly(source2, $"    x = {spec.SizeX},", 1, spec.TargetId + " exact skirt X");
		RequireExactly(source2, $"    y = {spec.SizeZ},", 1, spec.TargetId + " exact skirt Z");
	}

	private static void ValidatePatchedPlacementUtils(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA build-box parity 1.0.0", 1, "placement-utils build-box parity marker");
		RequireExactly(source, "    local minX = math.floor(position.x - skirtSize.x / 2)", 0, "obsolete X placement bound");
		RequireExactly(source, "    local minY = math.floor(position.z - skirtSize.y / 2)", 0, "obsolete Z placement bound");
		RequireExactly(source, "    local minX = math.floor(position.x) - math.floor(skirtSize.x / 2)", 1, "Trebuchet-exact X placement bound");
		RequireExactly(source, "    local minY = math.floor(position.z) - math.floor(skirtSize.y / 2)", 1, "Trebuchet-exact Z placement bound");
	}

	private static void ValidatePatchedConstructionPreview(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul FA build-box parity 1.0.0", 1, "preview build-box parity marker");
		RequireExactly(source, "            local minX = math.floor(position.x - unitTemplate.skirtSize.x / 2)\n            local minZ = math.floor(position.z - unitTemplate.skirtSize.y / 2)", 0, "obsolete preview cell bounds");
		RequireExactly(source, "            local minX = math.floor(position.x - SCOSeaParityPlacementSize(unitTemplate).x / 2)\n            local minZ = math.floor(position.z - SCOSeaParityPlacementSize(unitTemplate).y / 2)", 0, "obsolete Sea-Parity-aware preview cell bounds");
		Count(source, "            local minX, minZ = PlacementUtils.GetPlacementBounds(\n                position, unitTemplate.skirtSize)");
		Count(source, "            local minX, minZ = PlacementUtils.GetPlacementBounds(\n                position, SCOSeaParityPlacementSize(unitTemplate))");
		if (Count(source, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
		{
			RequireExactly(source, "            local minX, minZ = PlacementUtils.GetPlacementBounds(\n                position, unitTemplate.skirtSize)", 0, "stock preview cell bounds");
			RequireExactly(source, "            local minX, minZ = PlacementUtils.GetPlacementBounds(\n                position, SCOSeaParityPlacementSize(unitTemplate))", 1, "Sea-Parity-aware Trebuchet-exact preview cell bounds");
		}
		else
		{
			RequireExactly(source, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, "Sea Parity marker");
			RequireExactly(source, "            local minX, minZ = PlacementUtils.GetPlacementBounds(\n                position, unitTemplate.skirtSize)", 1, "Trebuchet-exact preview cell bounds");
			RequireExactly(source, "            local minX, minZ = PlacementUtils.GetPlacementBounds(\n                position, SCOSeaParityPlacementSize(unitTemplate))", 0, "Sea-Parity-aware preview cell bounds");
		}
		RequireAtLeast(source, "local PlacementUtils = Import(\"common/systems/placementUtils.lua\")", 1, "preview placement-utils import");
	}

	private static void ValidatePatchedFactoryHost(string source, string family, string classBinding, string legacyHook, string currentHook, string currentBaseSpawn, int expectedCurrentTokenCount, string? existingCurrentTokenProof, string? additionalCurrentHook)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul factory staging hook 1.0.2", 1, family + " factory staging marker");
		RequireExactly(source, classBinding, 1, family + " factory class binding");
		RequireExactly(source, legacyHook, 0, family + " legacy staging hook");
		RequireExactly(source, currentHook, 1, family + " live staging hook");
		RequireExactly(source, currentBaseSpawn, 1, family + " live base fallback");
		RequireExactly(source, "GetRollOffPoint", 0, family + " legacy spawn tokens");
		RequireExactly(source, "GetConstructionSpawnPoint", expectedCurrentTokenCount, family + " live spawn tokens");
		if (existingCurrentTokenProof != null)
		{
			RequireExactly(source, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, family + " Sea Parity marker");
			RequireExactly(source, existingCurrentTokenProof, 1, family + " Sea Parity live spawn call");
		}
		if (additionalCurrentHook != null)
		{
			RequireExactly(source, additionalCurrentHook, 1, family + " additional live staging hook");
		}
		RequireExactly(source, "    local point = self:GetPosition()\n    point.x = point.x + offset.x\n    point.y = point.y + offset.y\n    point.z = point.z + offset.z\n    return point", 0, family + " world-axis staging body");
		RequireExactly(source, "    local rotated = Engine.QuaternionRotateVector(\n        self:GetOrientation(),\n        EngineClasses.float3(\n            offset.x or 0,\n            offset.y or 0,\n            offset.z or 0))\n    local origin = self:GetPosition()\n    return EngineClasses.float3(\n        origin.x + rotated.x,\n        origin.y + rotated.y,\n        origin.z + rotated.z)", 1, family + " orientation-relative staging body");
		RequireExactly(source, "    local factoryPosition = factory:GetPosition()\n    return EngineClasses.float3(\n        factoryPosition.x + (offset.x or 0),\n        factoryPosition.y + (offset.y or 0),\n        factoryPosition.z + (offset.z or 0)\n    )", 0, family + " world-axis ramp body");
		RequireExactly(source, "    local rotated = Engine.QuaternionRotateVector(\n        factory:GetOrientation(),\n        EngineClasses.float3(\n            offset.x or 0,\n            offset.y or 0,\n            offset.z or 0))\n    local origin = factory:GetPosition()\n    return EngineClasses.float3(\n        origin.x + rotated.x,\n        origin.y + rotated.y,\n        origin.z + rotated.z)", 1, family + " orientation-relative ramp body");
		RequireExactly(source, "    if ramp.headingDegrees then\n        local orientation = Engine.EulerToQuaternion(\n            EngineClasses.float3(0, math.rad(ramp.headingDegrees), 0),\n            RotationOrder.Default\n        )\n        Engine.SetGlobalEntityLocalRotation(targetUnit.id, orientation)\n        return\n    end", 0, family + " uncomposed heading body");
		RequireExactly(source, "    if ramp.headingDegrees then\n        local localOrientation = Engine.EulerToQuaternion(\n            EngineClasses.float3(0, math.rad(ramp.headingDegrees), 0),\n            RotationOrder.Default)\n        local orientation = Engine.QuaternionMultiply(\n            factory:GetOrientation(),\n            localOrientation)\n        targetUnit:SetOrientation(orientation)\n        return\n    end", 1, family + " composed ramp heading body");
	}

	private static void ValidatePatchedChosenFactoryHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul factory staging hook 1.0.2", 1, "Chosen factory staging marker");
		RequireExactly(source, "-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0", 1, "Aeon upstream marker");
		RequireExactly(source, "local function scoAdaptAeonFactoryClass(factoryClass, baseClass)", 1, "Aeon factory adapter");
		RequireExactly(source, "factoryClass.GetRollOffPoint = function(self)", 0, "Aeon legacy spawn hook");
		RequireExactly(source, "factoryClass.GetConstructionSpawnPoint = function(self)", 1, "Aeon live spawn hook");
		RequireExactly(source, "return baseClass.GetRollOffPoint(self)", 0, "Aeon legacy base fallback");
		RequireExactly(source, "return baseClass.GetConstructionSpawnPoint(self)", 1, "Aeon live base fallback");
		RequireExactly(source, "function AeonPortCzar:GetRollOffPoint()", 0, "Czar legacy spawn hook");
		RequireExactly(source, "function AeonPortCzar:GetConstructionSpawnPoint()", 1, "Czar live spawn hook");
		RequireExactly(source, "GetRollOffPoint", 0, "Chosen legacy spawn tokens");
		RequireExactly(source, "GetConstructionSpawnPoint", 5, "Chosen live spawn tokens");
		RequireExactly(source, "targetUnit:SetPosition(self:GetConstructionSpawnPoint())", 2, "Aeon internal live spawn calls");
	}

	private static void ValidatePatchedSeraphimFactoryHost(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul factory staging hook 1.0.2", 1, "Seraphim factory staging marker");
		RequireExactly(source, "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", 1, "Seraphim upstream marker");
		RequireExactly(source, "-- Virtual unitsDefaultSeraphim module for the true fourth faction.", 1, "Seraphim virtual module marker");
		RequireExactly(source, "-- Supreme Commander Overhaul Seraphim Land Factory Compatibility 1.0.0", 1, "Seraphim factory compatibility marker");
		RequireExactly(source, "-- Supreme Commander Overhaul Seraphim Death Animation Compatibility 1.0.0", 1, "Seraphim death compatibility marker");
		RequireExactly(source, "function SeraphimNavalFactory:GetRollOffPoint()", 0, "Seraphim naval legacy spawn hook");
		RequireExactly(source, "function SeraphimNavalFactory:GetConstructionSpawnPoint()", 1, "Seraphim naval live spawn hook");
		RequireExactly(source, "return ChosenNavalFactory.GetRollOffPoint(self)", 0, "Seraphim naval legacy base fallback");
		RequireExactly(source, "return ChosenNavalFactory.GetConstructionSpawnPoint(self)", 1, "Seraphim naval live base fallback");
		RequireExactly(source, "GetRollOffPoint", 0, "Seraphim legacy spawn tokens");
		RequireExactly(source, "GetConstructionSpawnPoint", 2, "Seraphim live spawn tokens");
	}

	private static string AppendFactoryStagingMarker(string source)
	{
		return Normalize(source.TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul factory staging hook 1.0.2\n");
	}

	private static List<MutationPlan> BuildMutationPlans(object cache)
	{
		List<MutationPlan> list = new List<MutationPlan>();
		ValidateHostFactoryBaseSource(ReadText(GetCachedResource(cache, "LJ/lua/host/units/unitsClasses/unitsDefault.lua").Value));
		BuildBoxSpec[] specs = BuildBoxManifest.Specs;
		foreach (BuildBoxSpec buildBoxSpec in specs)
		{
			CacheResource cachedResource = GetCachedResource(cache, buildBoxSpec.RelativePath);
			string text = ReadText(cachedResource.Value);
			QueueIfChanged(list, cachedResource, text, PatchTemplateSource(text, buildBoxSpec));
		}
		CacheResource cachedResource2 = GetCachedResource(cache, "LJ/lua/common/systems/placementUtils.lua");
		string text2 = ReadText(cachedResource2.Value);
		QueueIfChanged(list, cachedResource2, text2, PatchPlacementUtilsSource(text2));
		CacheResource cachedResource3 = GetCachedResource(cache, "LJ/lua/client/input/constructionPreviewSystem.lua");
		string text3 = ReadText(cachedResource3.Value);
		QueueIfChanged(list, cachedResource3, text3, PatchConstructionPreviewSource(text3));
		CacheResource cachedResource4 = GetCachedResource(cache, "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua");
		string text4 = ReadText(cachedResource4.Value);
		QueueIfChanged(list, cachedResource4, text4, PatchGuardFactoryHostSource(text4));
		CacheResource cachedResource5 = GetCachedResource(cache, "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua");
		string text5 = ReadText(cachedResource5.Value);
		QueueIfChanged(list, cachedResource5, text5, PatchEdaFactoryHostSource(text5));
		CacheResource cachedResource6 = GetCachedResource(cache, "LJ/lua/host/units/unitsClasses/unitsDefaultChosen.lua");
		string text6 = ReadText(cachedResource6.Value);
		QueueIfChanged(list, cachedResource6, text6, PatchChosenFactoryHostSource(text6));
		CacheResource cachedResource7 = GetCachedResource(cache, "LJ/lua/host/units/unitsClasses/unitsDefaultSeraphim.lua");
		string text7 = ReadText(cachedResource7.Value);
		QueueIfChanged(list, cachedResource7, text7, PatchSeraphimFactoryHostSource(text7));
		return list;
	}

	private static void QueueIfChanged(ICollection<MutationPlan> plans, CacheResource resource, string oldSource, string newSource)
	{
		if (!string.Equals(oldSource, newSource, StringComparison.Ordinal))
		{
			plans.Add(new MutationPlan(resource.Path, resource.Value, oldSource, newSource));
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
			foreach (MutationPlan plan3 in plans)
			{
				if (!plan3.AssignmentAttempted && plan3.Replacement != null)
				{
					TryDispose(plan3.Replacement, "rolled-back " + plan3.Path);
				}
			}
			if (list.Count != 0)
			{
				throw new RollbackException(ex, list);
			}
			throw new InvalidOperationException("Build-box parity cache transaction failed and was rolled back.", ex);
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
					Exception ex = null;
					try
					{
						SetCachedResource(cache, mutationPlan.Path, mutationPlan.Stock);
					}
					catch (Exception ex2)
					{
						ex = ex2;
					}
					string a = ReadText(GetExactCachedResource(cache, mutationPlan.Path));
					if (!string.Equals(a, mutationPlan.OldSource, StringComparison.Ordinal))
					{
						if (ex != null)
						{
							list.Add(ex);
						}
						if (string.Equals(a, mutationPlan.NewSource, StringComparison.Ordinal))
						{
							throw new InvalidOperationException("Cache rollback retained the replacement for " + mutationPlan.Path + ".");
						}
						throw new InvalidOperationException("Cache rollback produced unknown contents for " + mutationPlan.Path + ".");
					}
					mutationPlan.AssignmentAttempted = false;
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
		CanonicalAssemblyContract.RequireCanonicalTypes("SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime", "SupremeCommanderOverhaulGeneratorBuildability.CachePatcherRuntime", "SupremeCommanderOverhaulSeaParity.CachePatcherRuntime", "SupremeCommanderOverhaulSeraphimEcoBuildUi.CachePatcherRuntime", "SupremeCommanderOverhaulAudioCompat.CachePatcherRuntime", "SupremeCommanderOverhaulBuildBoxParity.CachePatcherRuntime");
	}

	private static void ValidateSameAssembly(Type runtimeType, Assembly expectedAssembly, string description)
	{
		if ((object)runtimeType.Assembly != expectedAssembly)
		{
			throw Incompatible(description + " is not linked into the consolidated patcher.");
		}
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
		return TryFindLoadedType(fullName) ?? throw Incompatible("Expected one loaded " + fullName + " type, found 0.");
	}

	private static Type? TryFindLoadedType(string fullName)
	{
		Type[] array = (from assembly in AppDomain.CurrentDomain.GetAssemblies()
			select assembly.GetType(fullName, throwOnError: false) into type
			where type != null
			select type).Cast<Type>().ToArray();
		if (array.Length > 1)
		{
			throw Incompatible($"Expected one loaded {fullName} type, found {array.Length}.");
		}
		return array.SingleOrDefault();
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
		return ReplaceExactly(source, oldValue, newValue, 1, description);
	}

	private static string ReplaceExactly(string source, string oldValue, string newValue, int expectedCount, string description)
	{
		RequireExactly(source, oldValue, expectedCount, description);
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

	private static void RequireAtLeast(string source, string token, int minimum, string description)
	{
		int num = Count(source, token);
		if (num < minimum)
		{
			throw Incompatible($"Expected at least {minimum} {description}, found {num}.");
		}
	}

	private static CompatibilityException Incompatible(string message)
	{
		return new CompatibilityException(message);
	}

	private static void Log(string message)
	{
		string text = "[SCOM FA Build-Box Parity] " + message;
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
