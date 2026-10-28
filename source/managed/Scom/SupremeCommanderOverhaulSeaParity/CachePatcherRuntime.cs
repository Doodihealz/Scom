using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using ScomDeterministicLua;
using ScomRepair20260913;
using SupremeCommanderOverhaulCanonical;

namespace SupremeCommanderOverhaulSeaParity;

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

		public object? Stock { get; }

		public string? OldSource { get; }

		public string NewSource { get; }

		public Type NativeArrayType { get; }

		public bool Added { get; }

		public object? Replacement { get; set; }

		public bool AssignmentAttempted { get; set; }

		public byte[]? NewBytes { get; }

		public MutationPlan(string path, object stock, string oldSource, string newSource)
		{
			Path = path;
			Stock = stock;
			OldSource = oldSource;
			NewSource = newSource;
			NativeArrayType = stock.GetType();
		}

		public MutationPlan(string path, Type nativeArrayType, string newSource)
		{
			Path = path;
			NativeArrayType = nativeArrayType ?? throw new ArgumentNullException("nativeArrayType");
			NewSource = newSource;
			Added = true;
		}

		public MutationPlan(string path, Type nativeArrayType, byte[] newBytes)
		{
			Path = path;
			NativeArrayType = nativeArrayType ?? throw new ArgumentNullException("nativeArrayType");
			NewSource = string.Empty;
			NewBytes = newBytes ?? throw new ArgumentNullException("newBytes");
			Added = true;
		}
	}

	private sealed class RollbackException : AggregateException
	{
		public RollbackException(Exception commitError, IEnumerable<Exception> rollbackErrors)
			: base("Sea-parity cache commit and rollback both failed.", new Exception[1] { commitError }.Concat<Exception>(rollbackErrors))
		{
		}
	}

	public const string ExpectedScomSha256 = "3EED7306200D5910786221547FF0FB959FA8CF92C85C99D62B98A12175C28B76";

	public const string ExpectedScomMvid = "48dd1991-b31b-4297-bd60-0597d33328b5";

	public const long ExpectedScomBytes = 3819520L;

	public const string SpawnLoaderPath = "LJ/lua/common/loading/constructionSpawnPositionLoader.lua";

	private static readonly IReadOnlyDictionary<string, double> ProgressBoundFactoryUpgradeDurations = new Dictionary<string, double>(StringComparer.Ordinal)
	{
		["ues1512"] = 6.666666507720947,
		["ues1513"] = 10.0,
		["ues2513"] = 10.0,
		["ugs1512"] = 4.666666507720947,
		["ugs1513"] = 26.66666603088379,
		["ugs2513"] = 26.66666603088379
	};

	private const string ScomRuntimeType = "SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime";

	private static bool _isApplied;

	private const string HostWeaponTargetGateAppendix = "\n\n-- Supreme Commander Overhaul sea parity 1.0.0\n-- Sanctuary validates targetWaterLimits but does not consume it. Generated\n-- surface-only guns opt into this narrow physical target-height gate.\nlocal SCOSeaParityPreviousHostWeaponCanShootAt = HostWeapon.CanShootAt\nfunction HostWeapon:CanShootAt(targetUnit)\n    if not SCOSeaParityPreviousHostWeaponCanShootAt(self, targetUnit) then\n        return false\n    end\n    if self.tp == nil\n        or self.tp.scoSeaParityTargetGate ~= \"TargetAbove\"\n    then\n        return true\n    end\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return true end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then\n        return false\n    end\n    local targetPosition = targetUnit and targetUnit:GetPosition()\n    return targetPosition ~= nil\n        and targetPosition.y >= waterLevel - 0.05\nend";

	private const string HostWaterAppendix = "\n\n-- Supreme Commander Overhaul sea parity 1.0.0\n-- Final, narrow host authority for genuinely submerged naval factories. The\n-- SCOM wrapper calls stock first and can never accept Water; this branch instead\n-- preserves source depth and native water flags; occupancy is resolved separately.\nlocal SCOSeaParityPreviousHostBuildOrderIsOrderValid = HostBuildOrder.IsOrderValid\nlocal SCOSeaParityPreviousHostBuildOrderOrderStart = HostBuildOrder.OrderStart\nlocal SCOSeaParityWaterMargin = 1.5\nlocal SCOSeaParityWaterPlacementIds = {\n    [\"ucl3701\"] = true,\n    [\"ucl4003\"] = true,\n    [\"uen3005\"] = true,\n    [\"uen4001\"] = true,\n    [\"ugn3005\"] = true,\n    [\"ucs1513\"] = true,\n    [\"ucs2513\"] = true,\n    [\"ucs3513\"] = true,\n    [\"uss1513\"] = true,\n    [\"uss2513\"] = true,\n    [\"uss3513\"] = true,\n    [\"ues1513\"] = true,\n    [\"ues2513\"] = true,\n    [\"ues3513\"] = true,\n    [\"ugs1513\"] = true,\n    [\"ugs2513\"] = true,\n    [\"ugs3513\"] = true,\n}\nlocal SCOSeaParityWaterFactoryIds = {\n    [\"ucs1513\"] = true,\n    [\"ucs2513\"] = true,\n    [\"ucs3513\"] = true,\n    [\"uss1513\"] = true,\n    [\"uss2513\"] = true,\n    [\"uss3513\"] = true,\n    [\"ues1513\"] = true,\n    [\"ues2513\"] = true,\n    [\"ues3513\"] = true,\n    [\"ugs1513\"] = true,\n    [\"ugs2513\"] = true,\n    [\"ugs3513\"] = true,\n}\nlocal SCOSeaParityWaterMinimumDepth = {\n    [\"ucl3701\"] = 1.5,\n    [\"ucl4003\"] = 0,\n    [\"uen3005\"] = 1.5,\n    [\"uen4001\"] = 0,\n    [\"ugn3005\"] = 1.5,\n    [\"ucs1513\"] = 1.5,\n    [\"ucs2513\"] = 1.5,\n    [\"ucs3513\"] = 1.5,\n    [\"uss1513\"] = 1.5,\n    [\"uss2513\"] = 1.5,\n    [\"uss3513\"] = 1.5,\n    [\"ues1513\"] = 1.5,\n    [\"ues2513\"] = 1.5,\n    [\"ues3513\"] = 1.5,\n    [\"ugs1513\"] = 1.5,\n    [\"ugs2513\"] = 1.5,\n    [\"ugs3513\"] = 1.5,\n}\nlocal SCOSeaParityDualLandWaterIds = {\n    [\"ucl3701\"] = true,\n    [\"uen3005\"] = true,\n}\n\nlocal function SCOSeaParityRequiresWater(tp)\n    local id = tp and tp.general and tp.general.tpId\n    return id ~= nil\n        and SCOSeaParityWaterPlacementIds[id] == true\n        and tp.general.requiresWaterPlacement == true\nend\n\nlocal function SCOSeaParityIsWaterFactory(tp)\n    local id = tp and tp.general and tp.general.tpId\n    return id ~= nil and SCOSeaParityWaterFactoryIds[id] == true\nend\n\nlocal function SCOSeaParityGetWaterLevel()\n    local waterError, hasWater = Engine.HasWater()\n    if waterError ~= EngineErrorCode.Success or not hasWater then return nil end\n    local levelError, waterLevel = Engine.GetWaterLevel()\n    if levelError ~= EngineErrorCode.Success then return nil end\n    return waterLevel\nend\n\nlocal function SCOSeaParityWaterPlacementState(tp, position)\n    if not SCOSeaParityRequiresWater(tp) then return false end\n    local id = tp.general.tpId\n    if not SCOSeaParityDualLandWaterIds[id] then return true end\n    if position == nil then return nil end\n    local waterError, hasWater = Engine.HasWater()\n    if waterError ~= EngineErrorCode.Success then return nil end\n    if not hasWater then return false end\n    local levelError, waterLevel = Engine.GetWaterLevel()\n    local terrainError, terrainHeight = Engine.SampleTerrainHeight(position)\n    local minimumDepth = SCOSeaParityWaterMinimumDepth[id]\n    if levelError ~= EngineErrorCode.Success or waterLevel == nil\n        or terrainError ~= EngineErrorCode.Success or terrainHeight == nil\n        or minimumDepth == nil\n    then\n        return nil\n    end\n    return terrainHeight <= waterLevel - minimumDepth\nend\n\nlocal function SCOSeaParityIsSubmergedPoint(position, waterLevel, minimumDepth)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend\n\nlocal function SCOSeaParityAllRolloffRoutesAreSubmerged(position, tp, waterLevel)\n    local id = tp and tp.general and tp.general.tpId\n    local minimumDepth = id and SCOSeaParityWaterMinimumDepth[id]\n    if minimumDepth == nil then return false end\n    local routes = tp.construction and tp.construction.rollOffPoints\n    local ramps = tp.additions and tp.additions.rollOffRamps\n    if routes and #routes ~= 2 then return false end\n    if ramps and #ramps ~= 2 then return false end\n    if not routes and not ramps then return false end\n    for index = 1, 2 do\n        local route = routes and routes[index]\n        local ramp = ramps and ramps[index]\n        local routeOffset = route and route.offset or ramp and ramp.rampOffset\n        local exitOffset = ramp and ramp.clearanceOffset\n            or routeOffset and {\n                x = (routeOffset.x or 0) * ((route and route.exitScale) or 2),\n                z = (routeOffset.z or 0) * ((route and route.exitScale) or 2),\n            }\n        if not routeOffset or not exitOffset then return false end\n        local routePoint = EngineClasses.float3(\n            position.x + (routeOffset.x or 0),\n            waterLevel,\n            position.z + (routeOffset.z or 0))\n        local exitPoint = EngineClasses.float3(\n            position.x + (exitOffset.x or 0),\n            waterLevel,\n            position.z + (exitOffset.z or 0))\n        if not SCOSeaParityIsSubmergedPoint(routePoint, waterLevel, minimumDepth)\n            or not SCOSeaParityIsSubmergedPoint(exitPoint, waterLevel, minimumDepth)\n        then\n            return false\n        end\n    end\n    return true\nend\n\nlocal function SCOSeaParityWaterGridIsClear(position, tp, waterLevel)\n    local placementSize = tp.skirtSize or tp.footprint\n    local id = tp and tp.general and tp.general.tpId\n    local minimumDepth = id and SCOSeaParityWaterMinimumDepth[id]\n    if placementSize == nil or minimumDepth == nil then return false end\n    local minX, minY, maxX, maxY = PlacementUtils.GetPlacementBounds(\n        position, placementSize)\n    local min = EngineClasses.int2(minX, minY)\n    local max = EngineClasses.int2(maxX, maxY)\n    local errorCode, results = Engine.GetGlobalGridCellFlags(\n        _G.globalBuildingPlacementGridID, min, max)\n    local expectedCells = (maxX - minX + 1) * (maxY - minY + 1)\n    if errorCode ~= EngineErrorCode.Success or #results ~= expectedCells then\n        return false\n    end\n    for _, gridQueryResult in ipairs(results) do\n        local flags = gridQueryResult.flags\n        local allowed = bit.bor(PlacementLayer.Water, PlacementLayer.InvalidTerrain, PlacementLayer.Default)\n        if bit.band(flags, PlacementLayer.Water) == 0\n            or bit.band(flags, bit.bnot(allowed)) ~= 0\n        then\n            return false\n        end\n    end\n    for x = minX, maxX do\n        for z = minY, maxY do\n            local terrainError, terrainHeight = Engine.SampleTerrainHeightFromCell(\n                EngineClasses.int2(x, z))\n            if terrainError ~= EngineErrorCode.Success\n                or terrainHeight > waterLevel - minimumDepth\n            then\n                return false\n            end\n        end\n    end\n    return true, min, max\nend\n\nfunction HostBuildOrder:IsOrderValid()\n    if not SCOSeaParityRequiresWater(self.tp) then\n        return SCOSeaParityPreviousHostBuildOrderIsOrderValid(self)\n    end\n    local placementState = SCOSeaParityWaterPlacementState(\n        self.tp, self.positionFloat3)\n    if placementState == nil then return false end\n    if not placementState then\n        return SCO_StockHostBuildOrderIsOrderValid(self)\n    end\n    local waterLevel = SCOSeaParityGetWaterLevel()\n    if waterLevel == nil then return false end\n    if not OverhaulFactoryPlacementReservationsAreClear(\n        self.positionFloat3, self.tp, self.armyId, self.unitGettingBuilt)\n    then\n        return false\n    end\n    local clear, min, max = SCOSeaParityWaterGridIsClear(\n        self.positionFloat3, self.tp, waterLevel)\n    if not clear\n        or (SCOSeaParityIsWaterFactory(self.tp)\n            and not SCOSeaParityAllRolloffRoutesAreSubmerged(\n                self.positionFloat3, self.tp, waterLevel))\n    then\n        return false\n    end\n\n    local overlapError, overlappingIDs = Engine.GetGlobalGridModifiers(\n        _G.globalBuildingPlacementGridID, min, max, PlacementLayer.Default)\n    if overlapError ~= EngineErrorCode.Success then return false end\n    for _, overlappingID in ipairs(overlappingIDs) do\n        local occupyingID = OverhaulFactoryReservationOwner(overlappingID)\n            or overlappingID\n        local overlappingUnit = GetUnitById(occupyingID)\n        local isOwnGhost = self.unitGettingBuilt\n            and occupyingID.index == self.unitGettingBuilt.id.index\n            and occupyingID.version == self.unitGettingBuilt.id.version\n        if not isOwnGhost and overlappingUnit\n            and overlappingUnit:IsIntelVisionVisible(Armies[self.armyId])\n        then\n            return false\n        end\n    end\n    return true\nend\n\nfunction HostBuildOrder:OrderStart()\n    if not SCOSeaParityRequiresWater(self.tp) then\n        return SCOSeaParityPreviousHostBuildOrderOrderStart(self)\n    end\n    local placementState = SCOSeaParityWaterPlacementState(\n        self.tp, self.positionFloat3)\n    if placementState == nil then\n        error(\"Sea-parity water placement state became unavailable before OrderStart.\")\n    end\n    if placementState then\n        local waterLevel = SCOSeaParityGetWaterLevel()\n        if waterLevel == nil then\n            error(\"Sea-parity water level became unavailable before OrderStart.\")\n        end\n        self.positionFloat3 = EngineClasses.float3(\n            self.positionFloat3.x, waterLevel, self.positionFloat3.z)\n    end\n    return SCO_StockHostBuildOrderOrderStart(self)\nend";

	private const string ClientWaterAppendix = "\n\n-- Supreme Commander Overhaul sea parity 1.0.0\n-- Preview equivalent of the final host validator. Deep water carries both Water\n-- and InvalidTerrain; resources, reservations and occupied cells remain blocked.\nlocal SCOSeaParityPreviousCanPlaceAtArea = CanPlaceAtArea\nlocal SCOSeaParityPreviewMargin = 1.5\n\nlocal function SCOSeaParityPreviewRequiresWater(tp)\n    return SCOSeaParityIsWaterPlacement(tp)\nend\n\nlocal function SCOSeaParityPreviewWaterLevel()\n    local waterError, hasWater = Engine.HasWater()\n    if waterError ~= EngineErrorCode.Success or not hasWater then return nil end\n    local levelError, waterLevel = Engine.GetWaterLevel()\n    if levelError ~= EngineErrorCode.Success then return nil end\n    return waterLevel\nend\n\nlocal function SCOSeaParityPreviewPointIsSubmerged(position, waterLevel)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - SCOSeaParityPreviewMargin\nend\n\nlocal function SCOSeaParityAllPreviewRolloffsAreSubmerged(tp, position, waterLevel)\n    local routes = tp.construction and tp.construction.rollOffPoints\n    local ramps = tp.additions and tp.additions.rollOffRamps\n    if routes and #routes ~= 2 then return false end\n    if ramps and #ramps ~= 2 then return false end\n    if not routes and not ramps then return false end\n    for index = 1, 2 do\n        local route = routes and routes[index]\n        local ramp = ramps and ramps[index]\n        local routeOffset = route and route.offset or ramp and ramp.rampOffset\n        local exitOffset = ramp and ramp.clearanceOffset\n            or routeOffset and {\n                x = (routeOffset.x or 0) * ((route and route.exitScale) or 2),\n                z = (routeOffset.z or 0) * ((route and route.exitScale) or 2),\n            }\n        if not routeOffset or not exitOffset then return false end\n        local routePoint = EngineClasses.float3(\n            position.x + (routeOffset.x or 0),\n            waterLevel,\n            position.z + (routeOffset.z or 0))\n        local exitPoint = EngineClasses.float3(\n            position.x + (exitOffset.x or 0),\n            waterLevel,\n            position.z + (exitOffset.z or 0))\n        if not SCOSeaParityPreviewPointIsSubmerged(routePoint, waterLevel)\n            or not SCOSeaParityPreviewPointIsSubmerged(exitPoint, waterLevel)\n        then\n            return false\n        end\n    end\n    return true\nend\n\nfunction CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor, tp, position)\n    if not SCOSeaParityPreviewRequiresWater(tp) then\n        return SCOSeaParityPreviousCanPlaceAtArea(\n            minX, minY, maxX, maxY, domain, isAlloyExtractor, tp, position)\n    end\n    local placementState = SCOSeaParityWaterPlacementState(tp, position)\n    if placementState == nil then return false end\n    if not placementState then\n        return SCO_StockCanPlaceAtArea(\n            minX, minY, maxX, maxY, domain, isAlloyExtractor)\n    end\n    if isAlloyExtractor or position == nil then return false end\n    local waterLevel = SCOSeaParityPreviewWaterLevel()\n    if waterLevel == nil\n        or (SCOSeaParityIsWaterFactory(tp)\n            and not SCOSeaParityAllPreviewRolloffsAreSubmerged(\n                tp, position, waterLevel))\n    then\n        return false\n    end\n\n    local min = EngineClasses.int2(minX, minY)\n    local max = EngineClasses.int2(maxX, maxY)\n    local results = {}\n    local errorCode = Engine.GetLocalGridCellFlags(\n        _G.localBuildingPlacementGridID, min, max, results)\n    local expectedCells = (maxX - minX + 1) * (maxY - minY + 1)\n    if errorCode ~= EngineErrorCode.Success or #results ~= expectedCells then\n        return false\n    end\n    for _, gridQueryResult in ipairs(results) do\n        if not SCOSeaParityWaterCellIsClear(gridQueryResult.flags) then return false end\n    end\n    for x = minX, maxX do\n        for z = minY, maxY do\n            if not SCOSeaParityCellIsDeepEnough(\n                tp, EngineClasses.int2(x, z), waterLevel) then\n                return false\n            end\n        end\n    end\n    return true\nend";

	private const string BrokenPreviewCellBranch = "                    isValid = isValid and (not isWaterPlacement\n                        or (waterRollOffIsValid and waterLevel ~= nil\n                            and SCO_IsSeraphimSubmergedCell(cellCoord, waterLevel)))\n                    cellIsValid[x][y] = isValid\n";

	private const string BrokenPreviewReservationBranch = "        if not CanPlaceAtArea(minX, minY, maxX, maxY, PlacementUtils.GetPlacementDomain(tp), false) then\n            return false\n        end";

	private const string FixedPreviewReservationBranch = "        local waterPlacementState = SCOSeaParityWaterPlacementState(tp, position)\n        if waterPlacementState == nil then return false end\n        local isWaterPlacement = waterPlacementState == true\n        if isWaterPlacement then\n            local waterError, hasWater = Engine.HasWater()\n            local levelError, waterLevel = Engine.GetWaterLevel()\n            local results = {}\n            local flagsError = Engine.GetLocalGridCellFlags(\n                _G.localBuildingPlacementGridID,\n                EngineClasses.int2(minX, minY),\n                EngineClasses.int2(maxX, maxY),\n                results)\n            local expectedCells = (maxX - minX + 1) * (maxY - minY + 1)\n            if waterError ~= EngineErrorCode.Success or not hasWater\n                or levelError ~= EngineErrorCode.Success\n                or flagsError ~= EngineErrorCode.Success\n                or #results ~= expectedCells\n            then\n                return false\n            end\n            for _, result in ipairs(results) do\n                if not SCOSeaParityWaterCellIsClear(result.flags) then return false end\n            end\n            for x = minX, maxX do\n                for z = minY, maxY do\n                    if not SCOSeaParityCellIsDeepEnough(\n                        tp, EngineClasses.int2(x, z), waterLevel) then\n                        return false\n                    end\n                end\n            end\n        elseif not CanPlaceAtArea(minX, minY, maxX, maxY, PlacementUtils.GetPlacementDomain(tp), false) then\n            return false\n        end";

	private const string FixedPreviewCellBranch = "                    if isWaterPlacement then\n                        local flags = results[1].flags\n                        isValid = waterRollOffIsValid\n                            and waterLevel ~= nil\n                            and SCOSeaParityWaterCellIsClear(flags)\n                            and SCOSeaParityCellIsDeepEnough(\n                                unitTemplate, cellCoord, waterLevel)\n                    end\n                    cellIsValid[x][y] = isValid\n";

	public const string Marker = "-- Supreme Commander Overhaul sea parity 1.0.0";

	public const string FinalWaterDepthPolicyMarker = "-- Supreme Commander Overhaul final naval placement depth 1.0.0";

	public const string HostNavalUsableRolloffMarker = "-- Supreme Commander Overhaul usable naval factory rolloff 1.0.0";

	private const string FinalWaterDepthResolver = "-- Supreme Commander Overhaul final naval placement depth 1.0.0\nlocal function SCOSeaParityMinimumDepth(tp)\n    local additions = tp and tp.additions\n    local faContract = additions and additions.faSourceContract\n    local authored = faContract and faContract.minimumWaterDepth\n    if type(authored) == \"number\" and authored >= 0 then\n        return authored\n    end\n    local id = tp and tp.general and tp.general.tpId\n    return id and SCOSeaParityWaterMinimumDepth[id]\nend\n";

	public const string HostBuildOrderPath = "LJ/lua/host/managers/orders/orderClasses/hostBuildOrder.lua";

	public const string ConstructionPreviewPath = "LJ/lua/client/input/constructionPreviewSystem.lua";

	public const string PlacementGhostLoaderPath = "LJ/lua/common/loading/placementGhostTemplateLoader.lua";

	public const string ImportPath = "LJ/lua/common/systems/import.lua";

	public const string AvailableUnitsPath = "LJ/lua/common/units/availableUnits.lua";

	public const string QuickLaunchUnitsPath = "LJ/lua/common/units/quickLaunchUnits.lua";

	public const string HostDefaultPath = "LJ/lua/host/units/unitsClasses/unitsDefault.lua";

	public const string ClientDefaultPath = "LJ/lua/client/units/unitsClasses/unitsDefault.lua";

	public const string HostEdaPath = "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua";

	public const string ClientEdaPath = "LJ/lua/client/units/unitsClasses/unitsDefaultEDA.lua";

	public const string HostGuardPath = "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua";

	public const string ClientGuardPath = "LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua";

	public const string HostWeaponsPath = "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua";

	public const string UnitBlueprintValidatorPath = "LJ/lua/AI/UnitBlueprintValidator.lua";

	private const string SeraphimMarker = "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0";

	private const string SeraphimHostWaterMarker = "-- SCO_HostWaterPlacement";

	private const string SeraphimClientWaterMarker = "-- SCO_ClientWaterPlacement";

	private const string FaAirMarker = "-- Supreme Commander Overhaul FA Air Factories 1.0.0";

	private const string FaCybranT3Marker = "-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0";

	private const string SalemValidatorMarker = "-- Supreme Commander Overhaul Salem amphibious NAVAL preservation 1.0.0";

	public static IReadOnlyDictionary<string, string> GeneratedSources => GeneratedNavalTemplateSources.All;

	public static IReadOnlyDictionary<string, string> GeneratedProjectileSources => GeneratedNavalTemplateSources.Projectiles;

	public static void Apply()
	{
		if (_isApplied)
		{
			return;
		}
		try
		{
			ValidatePinnedScope();
			ValidateGeneratedSources(GeneratedNavalTemplateSources.All);
			ValidateGeneratedProjectileSources(GeneratedNavalTemplateSources.Projectiles);
			object luaFileCache = GetLuaFileCache();
			IReadOnlyList<MutationPlan> readOnlyList = BuildMutationPlans(luaFileCache);
			if (readOnlyList.Count != 0)
			{
				Commit(luaFileCache, readOnlyList);
			}
			_isApplied = true;
			Log((readOnlyList.Count == 0) ? "All pinned sea-parity cache contracts are already active." : "Applied pinned naval templates, dedicated projectiles, factory visibility, water placement, factory routing, registration, and firing-origin repairs transactionally.");
		}
		catch (RollbackException)
		{
			throw;
		}
		catch (InvalidOperationException ex2) when (ex2.Message.StartsWith("Incompatible cache source:", StringComparison.Ordinal))
		{
			Log("Skipped sea-parity cache stage because its source contract is unavailable; Lua startup remains available: " + ex2.Message);
		}
		catch (Exception)
		{
			throw;
		}
	}

	private static IReadOnlyList<MutationPlan> BuildMutationPlans(object cache)
	{
		List<MutationPlan> list = new List<MutationPlan>();
		HashSet<string> plannedPaths = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
		ValidateRuntimeDependencies(cache);
		QueueTransform(cache, list, plannedPaths, "LJ/lua/AI/UnitBlueprintValidator.lua", PatchUnitBlueprintValidatorSource);
		QueueTransform(cache, list, plannedPaths, "LJ/lua/host/units/weaponsClasses/weaponsBaseClass.lua", PatchHostWeaponTargetGateSource);
		QueueTransform(cache, list, plannedPaths, "LJ/lua/host/managers/orders/orderClasses/hostBuildOrder.lua", PatchHostBuildOrderSource);
		QueueTransform(cache, list, plannedPaths, "LJ/lua/client/input/constructionPreviewSystem.lua", PatchConstructionPreviewSource);
		QueueTransform(cache, list, plannedPaths, "LJ/lua/common/loading/placementGhostTemplateLoader.lua", PatchPlacementGhostLoaderSource);
		QueueTransform(cache, list, plannedPaths, "LJ/lua/common/systems/import.lua", PatchImportScannerSource);
		QueueTransform(cache, list, plannedPaths, "LJ/lua/common/units/availableUnits.lua", (string source) => PatchRegistrationTableSource(source, "AvailableUnits"));
		QueueTransform(cache, list, plannedPaths, "LJ/lua/common/units/quickLaunchUnits.lua", (string source) => PatchRegistrationTableSource(source, "QuickLaunchUnits"));
		QueueTransform(cache, list, plannedPaths, "LJ/lua/host/units/unitsClasses/unitsDefaultEDA.lua", (string source) => PatchHostFactionClassSource(source, eda: true));
		QueueTransform(cache, list, plannedPaths, "LJ/lua/client/units/unitsClasses/unitsDefaultEDA.lua", (string source) => PatchClientFactionClassSource(source, eda: true));
		QueueTransform(cache, list, plannedPaths, "LJ/lua/host/units/unitsClasses/unitsDefaultGuard.lua", (string source) => PatchHostFactionClassSource(source, eda: false));
		QueueTransform(cache, list, plannedPaths, "LJ/lua/client/units/unitsClasses/unitsDefaultGuard.lua", (string source) => PatchClientFactionClassSource(source, eda: false));
		foreach (SeaTemplateSpec generatedTemplate in SeaParityManifest.GeneratedTemplates)
		{
			QueueGeneratedTemplate(cache, list, plannedPaths, generatedTemplate);
		}
		foreach (string generatedProjectileId in SeaParityManifest.GeneratedProjectileIds)
		{
			QueueGeneratedProjectile(cache, list, plannedPaths, generatedProjectileId);
		}
		foreach (string targetId in SeaParityManifest.WaterFactoryIds.Where((string id) => id.StartsWith("ucs", StringComparison.Ordinal) || id.StartsWith("uss", StringComparison.Ordinal)))
		{
			QueueTransform(cache, list, plannedPaths, TemplatePath(targetId), (string source) => PatchWaterFactoryTemplateSource(source, targetId));
		}
		foreach (string targetId2 in SeaParityManifest.ExistingAirFactoryVisibilityIds)
		{
			QueueTransform(cache, list, plannedPaths, TemplatePath(targetId2), (string source) => PatchExistingAirFactoryVisibilitySource(source, targetId2));
		}
		foreach (KeyValuePair<string, int> existingWeaponCount in SeaParityManifest.ExistingWeaponCounts)
		{
			string targetId3 = existingWeaponCount.Key;
			int expectedCount = existingWeaponCount.Value;
			QueueTransform(cache, list, plannedPaths, TemplatePath(targetId3), (string source) => PatchWeaponOriginSource(source, targetId3, expectedCount));
		}
		return list;
	}

	private static void ValidateRuntimeDependencies(object cache)
	{
		string source = ReadText(GetCachedResource(cache, "LJ/lua/host/units/unitsClasses/unitsDefault.lua").Value);
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, "FA-air host lifecycle marker");
		RequireTokens(source, "_G.SCOFaAirFactoryLifecycle = SCOFaAirFactoryLifecycle", "SCOFaAirFactoryLifecycle.BindPlatform", "SCOFaAirFactoryLifecycle.StartBuild", "SCOFaAirFactoryLifecycle.StopBuild", "SCOFaAirFactoryLifecycle.CancelBuild");
		string source2 = ReadText(GetCachedResource(cache, "LJ/lua/client/units/unitsClasses/unitsDefault.lua").Value);
		RequireExactly(source2, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, "FA-air client lifecycle marker");
		RequireTokens(source2, "_G.SCOFaAirFactoryClientLifecycle = SCOFaAirFactoryClientLifecycle", "SCOFaAirFactoryClientLifecycle.Prepare", "SCOFaAirFactoryClientLifecycle.Render", "SCOFaAirFactoryClientLifecycle.Dispose");
		string source3 = ReadText(GetCachedResource(cache, "LJ/lua/common/loading/constructionSpawnPositionLoader.lua").Value);
		RequireExactly(source3, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, "FA-air platform-loader marker");
		RequireTokens(source3, "local explicitBoneName = tp.construction and tp.construction.platformBoneName", "error(\"Explicit factory platform bone is absent: \" .. explicitBoneName)");
	}

	private static void QueueGeneratedTemplate(object cache, ICollection<MutationPlan> plans, ISet<string> plannedPaths, SeaTemplateSpec spec)
	{
		if (!GeneratedNavalTemplateSources.All.TryGetValue(spec.TargetId, out string value))
		{
			throw Incompatible("Generated source is absent for " + spec.TargetId + ".");
		}
		string relativePath = TemplatePath(spec.TargetId);
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath);
		if (cacheResource == null)
		{
			string text = ResolveCachePath(relativePath);
			if (!plannedPaths.Add(text))
			{
				throw Incompatible("Multiple mutations target " + text + ".");
			}
			plans.Add(new MutationPlan(text, GetNativeArrayType(cache), PatchCachedGeneratedTemplateSource(value, value, spec)));
		}
		else
		{
			string text2 = ReadText(cacheResource.Value);
			string text3 = Normalize(text2);
			string newSource = PatchCachedGeneratedTemplateSource(text3, value, spec);
			QueueIfChanged(plans, plannedPaths, cacheResource, text2, text3, newSource);
		}
	}

	private static void QueueGeneratedProjectile(object cache, ICollection<MutationPlan> plans, ISet<string> plannedPaths, string projectileId)
	{
		if (!GeneratedNavalTemplateSources.Projectiles.TryGetValue(projectileId, out string value))
		{
			throw Incompatible("Generated projectile source is absent for " + projectileId + ".");
		}
		string text = Normalize(value);
		string relativePath = ProjectileTemplatePath(projectileId);
		CacheResource cacheResource = TryGetCachedResource(cache, relativePath);
		if (cacheResource == null)
		{
			string text2 = ResolveCachePath(relativePath);
			if (!plannedPaths.Add(text2))
			{
				throw Incompatible("Multiple mutations target " + text2 + ".");
			}
			plans.Add(new MutationPlan(text2, GetNativeArrayType(cache), text));
		}
		else if (!string.Equals(Normalize(ReadText(cacheResource.Value)), text, StringComparison.Ordinal))
		{
			throw Incompatible("Cached projectile source for " + projectileId + " is not its exact generated sea-parity source.");
		}
	}

	public static string PatchCachedGeneratedTemplateSource(string cachedSource, string generatedSource, SeaTemplateSpec spec)
	{
		if (cachedSource == null)
		{
			throw new ArgumentNullException("cachedSource");
		}
		if (generatedSource == null)
		{
			throw new ArgumentNullException("generatedSource");
		}
		if (spec == null)
		{
			throw new ArgumentNullException("spec");
		}
		string text = Normalize(cachedSource);
		string text2 = Normalize(generatedSource);
		string text3 = PatchGeneratedTemplateSource(text2, spec);
		if (!(text == text3))
		{
			if (!(text == text2))
			{
				CacheCompatibilityRepair.RequireSeaInput(text, text2, spec);
			}
			return text3;
		}
		return text;
	}

	private static string Sha256Utf8(string source)
	{
		return Sha256Bytes(Encoding.UTF8.GetBytes(source));
	}

	private static string Sha256Bytes(byte[] bytes)
	{
		using SHA256 sHA = SHA256.Create();
		return BitConverter.ToString(sHA.ComputeHash(bytes)).Replace("-", "");
	}

	private static void QueueTransform(object cache, ICollection<MutationPlan> plans, ISet<string> plannedPaths, string relativePath, Func<string, string> transform)
	{
		CacheResource cachedResource = GetCachedResource(cache, relativePath);
		string text = ReadText(cachedResource.Value);
		string text2 = Normalize(text);
		string newSource = transform(text2);
		QueueIfChanged(plans, plannedPaths, cachedResource, text, text2, newSource);
	}

	private static void QueueIfChanged(ICollection<MutationPlan> plans, ISet<string> plannedPaths, CacheResource resource, string rawOldSource, string normalizedOldSource, string newSource)
	{
		if (!string.Equals(normalizedOldSource, newSource, StringComparison.Ordinal))
		{
			if (!plannedPaths.Add(resource.Path))
			{
				throw Incompatible("Multiple mutations target " + resource.Path + ".");
			}
			plans.Add(new MutationPlan(resource.Path, resource.Value, rawOldSource, newSource));
		}
	}

	private static string TemplatePath(string targetId)
	{
		return "LJ/lua/common/units/unitsTemplates/" + targetId + "/" + targetId + ".santp";
	}

	private static string ProjectileTemplatePath(string projectileId)
	{
		return "LJ/lua/common/projectiles/projectilesTemplates/" + projectileId + "/" + projectileId + ".santp";
	}

	private static void Commit(object cache, IReadOnlyList<MutationPlan> plans)
	{
		try
		{
			foreach (MutationPlan plan in plans)
			{
				plan.Replacement = ((plan.NewBytes == null) ? CreateNativeArrayFromText(plan.NativeArrayType, plan.NewSource) : CreateNativeArrayFromBytes(plan.NativeArrayType, plan.NewBytes));
				if (!((plan.NewBytes == null) ? string.Equals(ReadText(plan.Replacement), plan.NewSource, StringComparison.Ordinal) : BytesEqual(ReadBytes(plan.Replacement), plan.NewBytes)))
				{
					throw new InvalidOperationException("Prepared cache value verification failed for " + plan.Path + ".");
				}
			}
		}
		catch
		{
			foreach (MutationPlan item in plans.Where((MutationPlan item) => item.Replacement != null))
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
				object exactCachedResource = GetExactCachedResource(cache, plan2.Path);
				if (!((plan2.NewBytes == null) ? string.Equals(ReadText(exactCachedResource), plan2.NewSource, StringComparison.Ordinal) : BytesEqual(ReadBytes(exactCachedResource), plan2.NewBytes)))
				{
					throw new InvalidOperationException("Cache write verification failed for " + plan2.Path + ".");
				}
			}
		}
		catch (Exception ex)
		{
			List<Exception> list = RollBack(cache, plans);
			foreach (MutationPlan item2 in plans.Where((MutationPlan item) => !item.AssignmentAttempted && item.Replacement != null))
			{
				TryDispose(item2.Replacement, "rolled-back " + item2.Path);
			}
			if (list.Count != 0)
			{
				throw new RollbackException(ex, list);
			}
			throw new InvalidOperationException("Sea-parity cache transaction failed and was rolled back.", ex);
		}
		foreach (MutationPlan plan3 in plans)
		{
			if (!plan3.Added)
			{
				TryDispose(plan3.Stock, "replaced " + plan3.Path);
			}
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
					if (mutationPlan.Added)
					{
						RemoveCachedResource(cache, mutationPlan.Path);
						if (ContainsExactCachedResource(cache, mutationPlan.Path))
						{
							throw new InvalidOperationException("Added cache resource survived rollback for " + mutationPlan.Path + ".");
						}
					}
					else
					{
						SetCachedResource(cache, mutationPlan.Path, mutationPlan.Stock);
						if (!string.Equals(ReadText(GetExactCachedResource(cache, mutationPlan.Path)), mutationPlan.OldSource, StringComparison.Ordinal))
						{
							throw new InvalidOperationException("Cache rollback verification failed for " + mutationPlan.Path + ".");
						}
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

	private static void ValidatePinnedScope()
	{
		CachePatcher.ValidateMvid(FindLoadedType("EM.Lua.FilesCache").Module.ModuleVersionId);
		CanonicalAssemblyContract.RequireCanonicalTypes("SupremeCommanderOverhaulCachePatcher.CachePatcherRuntime", "SupremeCommanderOverhaulSeaParity.CachePatcherRuntime");
	}

	public static void InstallEmbeddedSalemAnimationAsset()
	{
		byte[] array = ReadEmbeddedSalemAnimation();
		Type type = FindLoadedType("EM.Gamedata.Data");
		CachePatcher.ValidateMvid(type.Module.ModuleVersionId);
		Type type2 = FindLoadedType("EM.Gamedata.IGamedataEntry");
		Type type3 = type.GetNestedType("GamedataByteEntry", BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingMemberException(type.FullName, "GamedataByteEntry");
		if (!type2.IsAssignableFrom(type3))
		{
			throw Incompatible("Trebuchet GamedataByteEntry no longer implements IGamedataEntry.");
		}
		ConstructorInfo constructorInfo = type3.GetConstructor(new Type[3]
		{
			typeof(string),
			typeof(string),
			typeof(byte[])
		}) ?? throw new MissingMethodException(type3.FullName, ".ctor(string,string,byte[])");
		MethodInfo methodInfo = type2.GetMethod("ID", Type.EmptyTypes) ?? throw new MissingMethodException(type2.FullName, "ID");
		MethodInfo pathMethod = type2.GetMethod("Path", Type.EmptyTypes) ?? throw new MissingMethodException(type2.FullName, "Path");
		MethodInfo readBytesMethod = type2.GetMethod("ReadBytes", Type.EmptyTypes) ?? throw new MissingMethodException(type2.FullName, "ReadBytes");
		MethodInfo methodInfo2 = type.GetMethod("GetFileEntry", BindingFlags.Static | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(type.FullName, "GetFileEntry(string)");
		MethodInfo methodInfo3 = type.GetMethod("GetFileEntry", BindingFlags.Static | BindingFlags.Public, null, new Type[1] { typeof(uint) }, null) ?? throw new MissingMethodException(type.FullName, "GetFileEntry(uint)");
		MethodInfo methodInfo4 = type.GetMethod("AddGamedataEntry", BindingFlags.Static | BindingFlags.NonPublic, null, new Type[1] { type2 }, null) ?? throw new MissingMethodException(type.FullName, "AddGamedataEntry");
		object obj = (type.GetField("SanPackLoadedFiles", BindingFlags.Static | BindingFlags.NonPublic) ?? throw new MissingFieldException(type.FullName, "SanPackLoadedFiles")).GetValue(null) ?? throw new InvalidOperationException("SanPackLoadedFiles is null.");
		MethodInfo methodInfo5 = obj.GetType().GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(uint) }, null) ?? throw new MissingMethodException(obj.GetType().FullName, "ContainsKey(uint)");
		MethodInfo methodInfo6 = obj.GetType().GetMethod("TryRemove", BindingFlags.Instance | BindingFlags.Public, null, new Type[2]
		{
			typeof(uint),
			type2.MakeByRefType()
		}, null) ?? throw new MissingMethodException(obj.GetType().FullName, "TryRemove(uint,out IGamedataEntry)");
		Type type4 = FindLoadedType("EM.Gamedata.Load");
		object obj2 = (type4.GetField("SanAnimationsDictionary", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic) ?? throw new MissingFieldException(type4.FullName, "SanAnimationsDictionary")).GetValue(null) ?? throw new InvalidOperationException("SanAnimationsDictionary is null.");
		MethodInfo methodInfo7 = obj2.GetType().GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(uint) }, null) ?? throw new MissingMethodException(obj2.GetType().FullName, "ContainsKey(uint)");
		string text = "Units/ugn2001/LOD0/ugn2001_amphibious.sananimation";
		object obj3 = methodInfo2.Invoke(null, new object[1] { text });
		string text2 = typeof(CachePatcherRuntime).Assembly.Location;
		if (string.IsNullOrEmpty(text2))
		{
			text2 = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, typeof(CachePatcherRuntime).Assembly.GetName().Name + ".dll");
		}
		object obj4 = constructorInfo.Invoke(new object[3] { text2, text, array });
		uint num = (uint)(methodInfo.Invoke(obj4, null) ?? throw new InvalidOperationException("GamedataByteEntry.ID returned null."));
		if (obj3 != null)
		{
			ValidateSalemGamedataEntry(obj3, pathMethod, readBytesMethod, array, "existing");
			Log("Embedded Salem animation gamedata entry is already active.");
			return;
		}
		if ((bool)(methodInfo7.Invoke(obj2, new object[1] { num }) ?? throw new InvalidOperationException("SanAnimationsDictionary.ContainsKey returned null.")))
		{
			throw Incompatible("Salem animation was loaded before embedded gamedata ownership: " + text + ".");
		}
		bool flag = false;
		try
		{
			flag = true;
			methodInfo4.Invoke(null, new object[1] { obj4 });
			object obj5 = methodInfo2.Invoke(null, new object[1] { text }) ?? throw new InvalidOperationException("Embedded Salem gamedata assignment vanished: " + text + ".");
			if (obj5 != obj4)
			{
				throw Incompatible("Embedded Salem gamedata ownership was superseded during installation.");
			}
			ValidateSalemGamedataEntry(obj5, pathMethod, readBytesMethod, array, "installed");
		}
		catch (Exception ex)
		{
			if (flag)
			{
				try
				{
					object obj6 = methodInfo3.Invoke(null, new object[1] { num });
					if (obj6 == obj4)
					{
						object[] array2 = new object[2] { num, null };
						bool flag2 = (bool)(methodInfo6.Invoke(obj, array2) ?? throw new InvalidOperationException("SanPackLoadedFiles.TryRemove returned null."));
						bool flag3 = (bool)(methodInfo5.Invoke(obj, new object[1] { num }) ?? throw new InvalidOperationException("SanPackLoadedFiles.ContainsKey returned null."));
						if (!flag2 || array2[1] != obj4 || flag3)
						{
							throw new InvalidOperationException("Embedded Salem gamedata rollback verification failed.");
						}
					}
					else if (obj6 != null)
					{
						throw new InvalidOperationException("Embedded Salem gamedata rollback lost entry ownership.");
					}
				}
				catch (Exception ex2)
				{
					throw new AggregateException("Embedded Salem gamedata installation and rollback both failed.", ex, ex2);
				}
			}
			throw;
		}
		Log("Installed the embedded Salem animation in gamedata after sanpack enumeration.");
	}

	private static void ValidateSalemGamedataEntry(object entry, MethodInfo pathMethod, MethodInfo readBytesMethod, byte[] desiredBytes, string description)
	{
		string text = (string)(pathMethod.Invoke(entry, null) ?? throw new InvalidOperationException("IGamedataEntry.Path returned null."));
		if (!string.Equals(NormalizeGamedataPath(text), "Units/ugn2001/LOD0/ugn2001_amphibious.sananimation", StringComparison.OrdinalIgnoreCase))
		{
			throw Incompatible("Salem gamedata ID collision at Units/ugn2001/LOD0/ugn2001_amphibious.sananimation: " + text + ".");
		}
		byte[] array = (byte[])(readBytesMethod.Invoke(entry, null) ?? throw new InvalidOperationException("IGamedataEntry.ReadBytes returned null."));
		if (array.LongLength != 34235641 || !string.Equals(Sha256Bytes(array), "8026850836A1778313425BE6FFB20E3B0722319FC28B43EA4599866D37248BFF", StringComparison.OrdinalIgnoreCase) || !BytesEqual(array, desiredBytes))
		{
			throw Incompatible("The " + description + " Salem gamedata entry differs from the embedded asset.");
		}
	}

	private static string NormalizeGamedataPath(string path)
	{
		return path.Replace('\\', '/').TrimStart(new char[1] { '/' });
	}

	public static byte[] GetEmbeddedSalemAnimationForVerification()
	{
		return ReadEmbeddedSalemAnimation();
	}

	private static byte[] ReadEmbeddedSalemAnimation()
	{
		using Stream stream = typeof(CachePatcherRuntime).Assembly.GetManifestResourceStream("SupremeCommanderOverhaulSeaParity.Assets.SalemAmphibiousAnimationAssets.sanpack") ?? throw Incompatible("Embedded Salem animation pack is absent.");
		using MemoryStream memoryStream = new MemoryStream();
		stream.CopyTo(memoryStream);
		byte[] array = memoryStream.ToArray();
		if (array.LongLength != 4056791 || !string.Equals(Sha256Bytes(array), "2CD8C37D44957AAB36154A0C3E58F68F6547A05329B7CFD927E903C579F62AF1", StringComparison.OrdinalIgnoreCase))
		{
			throw Incompatible("Embedded Salem animation pack hash or length drifted.");
		}
		using MemoryStream stream2 = new MemoryStream(array, writable: false);
		using ZipArchive zipArchive = new ZipArchive(stream2, ZipArchiveMode.Read);
		ZipArchiveEntry[] array2 = zipArchive.Entries.Where((ZipArchiveEntry entry) => string.Equals(entry.FullName, "Units/ugn2001/LOD0/ugn2001_amphibious.sananimation", StringComparison.Ordinal)).ToArray();
		if (zipArchive.Entries.Count != 1 || array2.Length != 1 || array2[0].Length != 34235641)
		{
			throw Incompatible("Embedded Salem animation pack topology drifted.");
		}
		using Stream stream3 = array2[0].Open();
		using MemoryStream memoryStream2 = new MemoryStream(34235641);
		stream3.CopyTo(memoryStream2);
		byte[] array3 = memoryStream2.ToArray();
		if (array3.LongLength != 34235641 || !string.Equals(Sha256Bytes(array3), "8026850836A1778313425BE6FFB20E3B0722319FC28B43EA4599866D37248BFF", StringComparison.OrdinalIgnoreCase))
		{
			throw Incompatible("Embedded Salem animation entry hash or length drifted.");
		}
		return array3;
	}

	public static void ValidateAssemblyIdentity(Assembly assembly, string expectedMvid, long expectedBytes, string expectedSha256, string description)
	{
		if (assembly == null)
		{
			throw new ArgumentNullException("assembly");
		}
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
		return TryGetCachedResource(cache, relativePath) ?? throw new FileNotFoundException("Required cached Lua source is unavailable: " + relativePath + ".", relativePath);
	}

	private static CacheResource? TryGetCachedResource(object cache, string relativePath)
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
		return cacheResource;
	}

	private static string ResolveCachePath(string relativePath)
	{
		return Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), relativePath));
	}

	private static Type GetNativeArrayType(object cache)
	{
		foreach (Type item in new Type[1] { cache.GetType() }.Concat(cache.GetType().GetInterfaces()))
		{
			if (item.IsGenericType)
			{
				Type[] genericArguments = item.GetGenericArguments();
				if (genericArguments.Length == 2 && genericArguments[0] == typeof(string))
				{
					return genericArguments[1];
				}
			}
		}
		foreach (object item2 in (IEnumerable)cache)
		{
			object obj = item2.GetType().GetProperty("Value")?.GetValue(item2, null);
			if (obj != null)
			{
				EnsureCreated(obj, "Lua cache type probe");
				return obj.GetType();
			}
		}
		throw new InvalidOperationException("The Lua file cache exposes no NativeArray value type.");
	}

	private static string ReadText(object resource)
	{
		return Encoding.UTF8.GetString(ReadBytes(resource));
	}

	private static byte[] ReadBytes(object resource)
	{
		EnsureCreated(resource, "cache resource");
		return ((resource.GetType().GetMethod("ToArray", BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null) ?? throw new MissingMethodException(resource.GetType().FullName, "ToArray")).Invoke(resource, null) as byte[]) ?? throw new InvalidOperationException("NativeArray.ToArray returned null.");
	}

	private static object CreateNativeArrayFromText(Type nativeArrayType, string source)
	{
		return CreateNativeArrayFromBytes(nativeArrayType, Encoding.UTF8.GetBytes(source));
	}

	private static object CreateNativeArrayFromBytes(Type nativeArrayType, byte[] bytes)
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
			bytes,
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

	private static void RemoveCachedResource(object cache, string path)
	{
		(cache.GetType().GetMethod("Remove", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null) ?? throw new MissingMethodException(cache.GetType().FullName, "Remove")).Invoke(cache, new object[1] { path });
	}

	private static bool ContainsExactCachedResource(object cache, string path)
	{
		object obj = cache.GetType().GetMethod("ContainsKey", BindingFlags.Instance | BindingFlags.Public, null, new Type[1] { typeof(string) }, null)?.Invoke(cache, new object[1] { path });
		if (obj is bool)
		{
			return (bool)obj;
		}
		foreach (object item in (IEnumerable)cache)
		{
			if (string.Equals(item.GetType().GetProperty("Key")?.GetValue(item, null) as string, path, StringComparison.Ordinal))
			{
				return true;
			}
		}
		return false;
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

	private static void Log(string message)
	{
		string text = "[SCOM Sea Parity] " + message;
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

	private static string BuildHostNavalClassAppendix(bool eda)
	{
		string text = (eda ? "HostEDANavalFactory" : "HostGuardNavalFactory");
		string text2 = (eda ? "EDAFaUefNavalFactory" : "GuardFaCybranNavalFactory");
		string text3 = "Host" + text2;
		return "\n\n-- Supreme Commander Overhaul sea parity 1.0.0\nlocal SCOSeaParityNavalFactoryHostBase = " + text + "\nlocal SCOSeaParityFactoryLifecycle = _G.SCOFaAirFactoryLifecycle\nlocal SCOSeaParityHostOrderManager = Import(\"host/managers/orders/hostOrderManager.lua\")\nlocal SCOSeaParityOrderTasks = Import(\"common/commonOrders.lua\").OrderTasks\nif not SCOSeaParityNavalFactoryHostBase or not SCOSeaParityFactoryLifecycle then\n    error(\"Sea-parity naval-factory host dependencies are unavailable.\")\nend\n\n" + text3 + " = Class(\"" + text2 + "\", SCOSeaParityNavalFactoryHostBase)\nlocal SCOSeaParityNavalFactoryHostClass = " + text3 + "\n\nlocal function SCOSeaParityRotateFactoryOffset(factory, offset, scale, waterLevel)\n    local rotated = Engine.QuaternionRotateVector(\n        factory:GetOrientation(),\n        EngineClasses.float3(\n            (offset.x or 0) * scale,\n            (offset.y or 0) * scale,\n            (offset.z or 0) * scale))\n    local origin = factory:GetPosition()\n    return EngineClasses.float3(\n        origin.x + rotated.x,\n        waterLevel or origin.y + rotated.y,\n        origin.z + rotated.z)\nend\n\nlocal function SCOSeaParitySelectRolloffRoute(factory, rallyPoint)\n    local routes = factory.tp.construction and factory.tp.construction.rollOffPoints\n    if not routes or #routes ~= 2 then\n        error(\"Sea-parity naval factory lost its two-route contract.\")\n    end\n    if rallyPoint == nil then return routes[1] end\n    local selected = nil\n    local selectedDistance = nil\n    for _, route in ipairs(routes) do\n        if not route.offset then error(\"Sea-parity rolloff route has no offset.\") end\n        local point = SCOSeaParityRotateFactoryOffset(factory, route.offset, 1, rallyPoint.y)\n        local dx = point.x - rallyPoint.x\n        local dz = point.z - rallyPoint.z\n        local distance = dx * dx + dz * dz\n        if selectedDistance == nil or distance < selectedDistance then\n            selected = route\n            selectedDistance = distance\n        end\n    end\n    return selected\nend\n\nfunction SCOSeaParityNavalFactoryHostClass:__init(id, army, template, progress, builder)\n    SCOSeaParityNavalFactoryHostBase.__init(self, id, army, template, progress, builder)\n    SCOSeaParityFactoryLifecycle.BindPlatform(self)\nend\n\nfunction SCOSeaParityNavalFactoryHostClass:UpdateAnimations()\n    -- Static factory animation is owned by the SCOM sentinel sampler.\nend\n\nfunction SCOSeaParityNavalFactoryHostClass:OnStartBuildRoutine(targetUnit)\n    if targetUnit and targetUnit:HasTags(Tags.MOBILE)\n        and not targetUnit:IsCompleted()\n    then\n        targetUnit.scoSeaParityFactoryPinOwner = self\n        targetUnit:SetOrientation(self:GetOrientation())\n        targetUnit:SetPosition(self:GetConstructionSpawnPoint())\n        Engine.SetVolumeColliderEnabled(targetUnit.id, false)\n    end\n    SCOSeaParityNavalFactoryHostBase.OnStartBuildRoutine(self, targetUnit)\n    SCOSeaParityFactoryLifecycle.StartBuild(self, targetUnit)\nend\n\nfunction SCOSeaParityNavalFactoryHostClass:OnStopBuildRoutine(targetUnit)\n    SCOSeaParityNavalFactoryHostBase.OnStopBuildRoutine(self, targetUnit)\n    SCOSeaParityFactoryLifecycle.StopBuild(self, targetUnit)\nend\n\nfunction SCOSeaParityNavalFactoryHostClass:RollOffUnit(targetUnit)\n    local source = self.unitBeingBuiltSource or self\n    local rallyPoint = source.rallyPoint\n    local route = SCOSeaParitySelectRolloffRoute(self, rallyPoint)\n    local waterLevel = nil\n    local waterError, hasWater = Engine.HasWater()\n    if waterError == EngineErrorCode.Success and hasWater then\n        local levelError, level = Engine.GetWaterLevel()\n        if levelError == EngineErrorCode.Success then waterLevel = level end\n    end\n    if waterLevel == nil then error(\"Sea-parity naval rolloff has no water level.\") end\n\n    local exitScale = route.exitScale or 2\n    local routePoint = SCOSeaParityRotateFactoryOffset(\n        self, route.offset, 1, waterLevel)\n    local exitPoint = SCOSeaParityRotateFactoryOffset(\n        self, route.offset, exitScale, waterLevel)\n    local localOrientation = Engine.EulerToQuaternion(\n        EngineClasses.float3(0, math.rad(route.unitSpin or 0), 0),\n        RotationOrder.Default)\n    targetUnit:SetOrientation(Engine.QuaternionMultiply(\n        self:GetOrientation(), localOrientation))\n    targetUnit:SetPosition(routePoint)\n    if targetUnit.scoSeaParityFactoryPinOwner == self then\n        targetUnit.scoSeaParityFactoryPinOwner = nil\n    end\n    Engine.SetVolumeColliderEnabled(targetUnit.id, true)\n    SCOSeaParityHostOrderManager.HostIssueOrder(\n        SCOSeaParityOrderTasks.MOVE, {targetUnit}, false, exitPoint, nil)\n    if rallyPoint then\n        rallyPoint = EngineClasses.float3(rallyPoint.x, waterLevel, rallyPoint.z)\n        SCOSeaParityHostOrderManager.HostIssueOrder(\n            SCOSeaParityOrderTasks.MOVE, {targetUnit}, true, rallyPoint, nil)\n    end\nend\n\nfunction SCOSeaParityNavalFactoryHostClass:OnDestroy(isDelete)\n    SCOSeaParityFactoryLifecycle.CancelBuild(self)\n    local target = self.productionBehaviorTargetUnit\n    if target and target.scoSeaParityFactoryPinOwner == self\n        and not target.dead and not target.deleted\n    then\n        target.scoSeaParityFactoryPinOwner = nil\n        Engine.SetVolumeColliderEnabled(target.id, true)\n    end\n    SCOSeaParityNavalFactoryHostBase.OnDestroy(self, isDelete)\nend";
	}

	private static string BuildClientNavalClassAppendix(bool eda)
	{
		string text = (eda ? "ClientEDANavalFactory" : "ClientGuardNavalFactory");
		string text2 = (eda ? "EDAFaUefNavalFactory" : "GuardFaCybranNavalFactory");
		string text3 = "Client" + text2;
		return "\n\n-- Supreme Commander Overhaul sea parity 1.0.0\nlocal SCOSeaParityNavalFactoryClientBase = " + text + "\nlocal SCOSeaParityFactoryClientLifecycle = _G.SCOFaAirFactoryClientLifecycle\nif not SCOSeaParityNavalFactoryClientBase or not SCOSeaParityFactoryClientLifecycle then\n    error(\"Sea-parity naval-factory client dependencies are unavailable.\")\nend\n\n" + text3 + " = Class(\"" + text2 + "\", SCOSeaParityNavalFactoryClientBase)\nlocal SCOSeaParityNavalFactoryClientClass = " + text3 + "\n\nfunction SCOSeaParityNavalFactoryClientClass:OnStartBuildRoutine(buildableId)\n    SCOSeaParityFactoryClientLifecycle.Prepare(self)\n    SCOSeaParityNavalFactoryClientBase.OnStartBuildRoutine(self, buildableId)\nend\n\nfunction SCOSeaParityNavalFactoryClientClass:ClientOnStopBuilding()\n    SCOSeaParityNavalFactoryClientBase.ClientOnStopBuilding(self)\n    SCOSeaParityFactoryClientLifecycle.Dispose(self)\nend\n\nfunction SCOSeaParityNavalFactoryClientClass:OnEndUpgrading(upgrade)\n    SCOSeaParityNavalFactoryClientBase.OnEndUpgrading(self, upgrade)\n    SCOSeaParityFactoryClientLifecycle.Dispose(self)\nend\n\nfunction SCOSeaParityNavalFactoryClientClass:RenderUpdateBeams()\n    SCOSeaParityNavalFactoryClientBase.RenderUpdateBeams(self)\n    SCOSeaParityFactoryClientLifecycle.Render(self)\nend\n\nfunction SCOSeaParityNavalFactoryClientClass:OnDestroy(isDelete)\n    SCOSeaParityFactoryClientLifecycle.Dispose(self)\n    SCOSeaParityNavalFactoryClientBase.OnDestroy(self, isDelete)\nend";
	}

	public static string PatchHostWeaponTargetGateSource(string source)
	{
		string text = Normalize(source);
		if (Count(text, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
		{
			ValidateHostWeaponTargetGate(text);
			return text;
		}
		RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, "sea-parity marker");
		RequireExactly(text, "-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0", 1, "FA Cybran T3 marker");
		RequireTokens(text, "local SCO_FaCybranT3StockCanShootAt = HostWeapon.CanShootAt", "if not SCO_FaCybranT3StockCanShootAt(self, targetUnit) then return false end", "if gate == \"TargetAbove\" then return targetAbove end", "if gate == \"OwnerAndTargetAbove\" then return ownerAbove and targetAbove end", "if gate == \"OwnerAndTargetBelow\" then return not ownerAbove and not targetAbove end");
		string text2 = text.TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul sea parity 1.0.0\n-- Sanctuary validates targetWaterLimits but does not consume it. Generated\n-- surface-only guns opt into this narrow physical target-height gate.\nlocal SCOSeaParityPreviousHostWeaponCanShootAt = HostWeapon.CanShootAt\nfunction HostWeapon:CanShootAt(targetUnit)\n    if not SCOSeaParityPreviousHostWeaponCanShootAt(self, targetUnit) then\n        return false\n    end\n    if self.tp == nil\n        or self.tp.scoSeaParityTargetGate ~= \"TargetAbove\"\n    then\n        return true\n    end\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return false end\n    if not hasWater then return true end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then\n        return false\n    end\n    local targetPosition = targetUnit and targetUnit:GetPosition()\n    return targetPosition ~= nil\n        and targetPosition.y >= waterLevel - 0.05\nend\n";
		ValidateHostWeaponTargetGate(text2);
		return text2;
	}

	public static string PatchHostBuildOrderSource(string source)
	{
		string source2 = Normalize(source);
		if (Count(source2, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
		{
			source2 = ApplyHostFinalWaterDepthPolicy(source2);
			ValidateHostWaterPatch(source2);
			return source2;
		}
		RequireExactly(source2, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, "sea-parity marker");
		RequireExactly(source2, "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", 1, "SCOM Seraphim marker");
		RequireExactly(source2, "-- SCO_HostWaterPlacement", 1, "SCOM host-water marker");
		if (Count(source2, "local bit = require(\"bit\")") == 0)
		{
			source2 = ReplaceExactly(source2, "local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\n", "local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer\nlocal bit = require(\"bit\")\n", 1, "host sea-placement bit-library import");
		}
		RequireTokens(source2, "local PlacementUtils = Import(\"common/systems/placementUtils.lua\")", "local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer", "local bit = require(\"bit\")", "local function OverhaulFactoryPlacementReservationsAreClear(", "local function OverhaulFactoryReservationOwner(", "function HostBuildOrder:IsOrderValid()", "function HostBuildOrder:OrderStart()", "SCO_StockHostBuildOrderIsOrderValid(self)");
		string text = ApplyHostFinalWaterDepthPolicy(ReplaceExactly(source2, "PlacementUtils.GetPlacementBounds(self.positionFloat3, self.tp.skirtSize)", "PlacementUtils.GetPlacementBounds(\n        self.positionFloat3, self.tp.skirtSize or self.tp.footprint)", 1, "host build-order placement-size reference").TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul sea parity 1.0.0\n-- Final, narrow host authority for genuinely submerged naval factories. The\n-- SCOM wrapper calls stock first and can never accept Water; this branch instead\n-- preserves source depth and native water flags; occupancy is resolved separately.\nlocal SCOSeaParityPreviousHostBuildOrderIsOrderValid = HostBuildOrder.IsOrderValid\nlocal SCOSeaParityPreviousHostBuildOrderOrderStart = HostBuildOrder.OrderStart\nlocal SCOSeaParityWaterMargin = 1.5\nlocal SCOSeaParityWaterPlacementIds = {\n    [\"ucl3701\"] = true,\n    [\"ucl4003\"] = true,\n    [\"uen3005\"] = true,\n    [\"uen4001\"] = true,\n    [\"ugn3005\"] = true,\n    [\"ucs1513\"] = true,\n    [\"ucs2513\"] = true,\n    [\"ucs3513\"] = true,\n    [\"uss1513\"] = true,\n    [\"uss2513\"] = true,\n    [\"uss3513\"] = true,\n    [\"ues1513\"] = true,\n    [\"ues2513\"] = true,\n    [\"ues3513\"] = true,\n    [\"ugs1513\"] = true,\n    [\"ugs2513\"] = true,\n    [\"ugs3513\"] = true,\n}\nlocal SCOSeaParityWaterFactoryIds = {\n    [\"ucs1513\"] = true,\n    [\"ucs2513\"] = true,\n    [\"ucs3513\"] = true,\n    [\"uss1513\"] = true,\n    [\"uss2513\"] = true,\n    [\"uss3513\"] = true,\n    [\"ues1513\"] = true,\n    [\"ues2513\"] = true,\n    [\"ues3513\"] = true,\n    [\"ugs1513\"] = true,\n    [\"ugs2513\"] = true,\n    [\"ugs3513\"] = true,\n}\nlocal SCOSeaParityWaterMinimumDepth = {\n    [\"ucl3701\"] = 1.5,\n    [\"ucl4003\"] = 0,\n    [\"uen3005\"] = 1.5,\n    [\"uen4001\"] = 0,\n    [\"ugn3005\"] = 1.5,\n    [\"ucs1513\"] = 1.5,\n    [\"ucs2513\"] = 1.5,\n    [\"ucs3513\"] = 1.5,\n    [\"uss1513\"] = 1.5,\n    [\"uss2513\"] = 1.5,\n    [\"uss3513\"] = 1.5,\n    [\"ues1513\"] = 1.5,\n    [\"ues2513\"] = 1.5,\n    [\"ues3513\"] = 1.5,\n    [\"ugs1513\"] = 1.5,\n    [\"ugs2513\"] = 1.5,\n    [\"ugs3513\"] = 1.5,\n}\nlocal SCOSeaParityDualLandWaterIds = {\n    [\"ucl3701\"] = true,\n    [\"uen3005\"] = true,\n}\n\nlocal function SCOSeaParityRequiresWater(tp)\n    local id = tp and tp.general and tp.general.tpId\n    return id ~= nil\n        and SCOSeaParityWaterPlacementIds[id] == true\n        and tp.general.requiresWaterPlacement == true\nend\n\nlocal function SCOSeaParityIsWaterFactory(tp)\n    local id = tp and tp.general and tp.general.tpId\n    return id ~= nil and SCOSeaParityWaterFactoryIds[id] == true\nend\n\nlocal function SCOSeaParityGetWaterLevel()\n    local waterError, hasWater = Engine.HasWater()\n    if waterError ~= EngineErrorCode.Success or not hasWater then return nil end\n    local levelError, waterLevel = Engine.GetWaterLevel()\n    if levelError ~= EngineErrorCode.Success then return nil end\n    return waterLevel\nend\n\nlocal function SCOSeaParityWaterPlacementState(tp, position)\n    if not SCOSeaParityRequiresWater(tp) then return false end\n    local id = tp.general.tpId\n    if not SCOSeaParityDualLandWaterIds[id] then return true end\n    if position == nil then return nil end\n    local waterError, hasWater = Engine.HasWater()\n    if waterError ~= EngineErrorCode.Success then return nil end\n    if not hasWater then return false end\n    local levelError, waterLevel = Engine.GetWaterLevel()\n    local terrainError, terrainHeight = Engine.SampleTerrainHeight(position)\n    local minimumDepth = SCOSeaParityWaterMinimumDepth[id]\n    if levelError ~= EngineErrorCode.Success or waterLevel == nil\n        or terrainError ~= EngineErrorCode.Success or terrainHeight == nil\n        or minimumDepth == nil\n    then\n        return nil\n    end\n    return terrainHeight <= waterLevel - minimumDepth\nend\n\nlocal function SCOSeaParityIsSubmergedPoint(position, waterLevel, minimumDepth)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend\n\nlocal function SCOSeaParityAllRolloffRoutesAreSubmerged(position, tp, waterLevel)\n    local id = tp and tp.general and tp.general.tpId\n    local minimumDepth = id and SCOSeaParityWaterMinimumDepth[id]\n    if minimumDepth == nil then return false end\n    local routes = tp.construction and tp.construction.rollOffPoints\n    local ramps = tp.additions and tp.additions.rollOffRamps\n    if routes and #routes ~= 2 then return false end\n    if ramps and #ramps ~= 2 then return false end\n    if not routes and not ramps then return false end\n    for index = 1, 2 do\n        local route = routes and routes[index]\n        local ramp = ramps and ramps[index]\n        local routeOffset = route and route.offset or ramp and ramp.rampOffset\n        local exitOffset = ramp and ramp.clearanceOffset\n            or routeOffset and {\n                x = (routeOffset.x or 0) * ((route and route.exitScale) or 2),\n                z = (routeOffset.z or 0) * ((route and route.exitScale) or 2),\n            }\n        if not routeOffset or not exitOffset then return false end\n        local routePoint = EngineClasses.float3(\n            position.x + (routeOffset.x or 0),\n            waterLevel,\n            position.z + (routeOffset.z or 0))\n        local exitPoint = EngineClasses.float3(\n            position.x + (exitOffset.x or 0),\n            waterLevel,\n            position.z + (exitOffset.z or 0))\n        if not SCOSeaParityIsSubmergedPoint(routePoint, waterLevel, minimumDepth)\n            or not SCOSeaParityIsSubmergedPoint(exitPoint, waterLevel, minimumDepth)\n        then\n            return false\n        end\n    end\n    return true\nend\n\nlocal function SCOSeaParityWaterGridIsClear(position, tp, waterLevel)\n    local placementSize = tp.skirtSize or tp.footprint\n    local id = tp and tp.general and tp.general.tpId\n    local minimumDepth = id and SCOSeaParityWaterMinimumDepth[id]\n    if placementSize == nil or minimumDepth == nil then return false end\n    local minX, minY, maxX, maxY = PlacementUtils.GetPlacementBounds(\n        position, placementSize)\n    local min = EngineClasses.int2(minX, minY)\n    local max = EngineClasses.int2(maxX, maxY)\n    local errorCode, results = Engine.GetGlobalGridCellFlags(\n        _G.globalBuildingPlacementGridID, min, max)\n    local expectedCells = (maxX - minX + 1) * (maxY - minY + 1)\n    if errorCode ~= EngineErrorCode.Success or #results ~= expectedCells then\n        return false\n    end\n    for _, gridQueryResult in ipairs(results) do\n        local flags = gridQueryResult.flags\n        local allowed = bit.bor(PlacementLayer.Water, PlacementLayer.InvalidTerrain, PlacementLayer.Default)\n        if bit.band(flags, PlacementLayer.Water) == 0\n            or bit.band(flags, bit.bnot(allowed)) ~= 0\n        then\n            return false\n        end\n    end\n    for x = minX, maxX do\n        for z = minY, maxY do\n            local terrainError, terrainHeight = Engine.SampleTerrainHeightFromCell(\n                EngineClasses.int2(x, z))\n            if terrainError ~= EngineErrorCode.Success\n                or terrainHeight > waterLevel - minimumDepth\n            then\n                return false\n            end\n        end\n    end\n    return true, min, max\nend\n\nfunction HostBuildOrder:IsOrderValid()\n    if not SCOSeaParityRequiresWater(self.tp) then\n        return SCOSeaParityPreviousHostBuildOrderIsOrderValid(self)\n    end\n    local placementState = SCOSeaParityWaterPlacementState(\n        self.tp, self.positionFloat3)\n    if placementState == nil then return false end\n    if not placementState then\n        return SCO_StockHostBuildOrderIsOrderValid(self)\n    end\n    local waterLevel = SCOSeaParityGetWaterLevel()\n    if waterLevel == nil then return false end\n    if not OverhaulFactoryPlacementReservationsAreClear(\n        self.positionFloat3, self.tp, self.armyId, self.unitGettingBuilt)\n    then\n        return false\n    end\n    local clear, min, max = SCOSeaParityWaterGridIsClear(\n        self.positionFloat3, self.tp, waterLevel)\n    if not clear\n        or (SCOSeaParityIsWaterFactory(self.tp)\n            and not SCOSeaParityAllRolloffRoutesAreSubmerged(\n                self.positionFloat3, self.tp, waterLevel))\n    then\n        return false\n    end\n\n    local overlapError, overlappingIDs = Engine.GetGlobalGridModifiers(\n        _G.globalBuildingPlacementGridID, min, max, PlacementLayer.Default)\n    if overlapError ~= EngineErrorCode.Success then return false end\n    for _, overlappingID in ipairs(overlappingIDs) do\n        local occupyingID = OverhaulFactoryReservationOwner(overlappingID)\n            or overlappingID\n        local overlappingUnit = GetUnitById(occupyingID)\n        local isOwnGhost = self.unitGettingBuilt\n            and occupyingID.index == self.unitGettingBuilt.id.index\n            and occupyingID.version == self.unitGettingBuilt.id.version\n        if not isOwnGhost and overlappingUnit\n            and overlappingUnit:IsIntelVisionVisible(Armies[self.armyId])\n        then\n            return false\n        end\n    end\n    return true\nend\n\nfunction HostBuildOrder:OrderStart()\n    if not SCOSeaParityRequiresWater(self.tp) then\n        return SCOSeaParityPreviousHostBuildOrderOrderStart(self)\n    end\n    local placementState = SCOSeaParityWaterPlacementState(\n        self.tp, self.positionFloat3)\n    if placementState == nil then\n        error(\"Sea-parity water placement state became unavailable before OrderStart.\")\n    end\n    if placementState then\n        local waterLevel = SCOSeaParityGetWaterLevel()\n        if waterLevel == nil then\n            error(\"Sea-parity water level became unavailable before OrderStart.\")\n        end\n        self.positionFloat3 = EngineClasses.float3(\n            self.positionFloat3.x, waterLevel, self.positionFloat3.z)\n    end\n    return SCO_StockHostBuildOrderOrderStart(self)\nend\n");
		ValidateHostWaterPatch(text);
		return text;
	}

	public static string GetSalemHostRuntimeForVerification()
	{
		return BuildHostSalemClassAppendix();
	}

	private static string BuildHostSalemClassAppendix()
	{
		return "\n\n-- Supreme Commander Overhaul Salem amphibious parity 1.0.0\nlocal SCOSeaParitySalemBase = HostGuardNavalUnit\nlocal SCOSeaParitySalemSentinelBase = -10000\nlocal SCOSeaParitySalemLifecycle = {}\nif not SCOSeaParitySalemBase then\n    error(\"Salem amphibious host base is unavailable\")\nend\nlocal SCOSeaParitySalemBaseOnStopBeingBuilt =\n    SCOSeaParitySalemBase.OnStopBeingBuilt\nlocal SCOSeaParitySalemBaseUpdateAnimations =\n    SCOSeaParitySalemBase.UpdateAnimations\nlocal SCOSeaParitySalemBaseOnDestroy =\n    SCOSeaParitySalemBase.OnDestroy\nlocal SCOSeaParitySalemBaseDeathThread =\n    SCOSeaParitySalemBase.DeathThread\nif not SCOSeaParitySalemBaseOnStopBeingBuilt\n    or not SCOSeaParitySalemBaseUpdateAnimations\n    or not SCOSeaParitySalemBaseOnDestroy\n    or not SCOSeaParitySalemBaseDeathThread\nthen\n    error(\"Salem amphibious host lifecycle hooks are unavailable\")\nend\n\nlocal function SCOSeaParitySalemAlive(unit)\n    return unit ~= nil and not unit.dead and not unit.deleted\nend\n\nlocal function SCOSeaParitySalemConfig(unit)\n    local additions = unit.tp and unit.tp.additions\n    return additions and additions.faSalemAmphibious\nend\n\nlocal function SCOSeaParitySalemAnimations(unit)\n    local visuals = unit.tp and unit.tp.visuals\n    return visuals and visuals.animations\nend\n\nfunction SCOSeaParitySalemLifecycle.IsSupported(unit)\n    local config = SCOSeaParitySalemConfig(unit)\n    return config ~= nil\n        and unit.tp ~= nil\n        and unit.tp.movement ~= nil\n        and config.transformSourceClip == \"AnimTransform02\"\n        and config.transformDurationSeconds == 7\n        and config.transformSourceRate == 2\n        and config.transformReverseSourceRate == -2\n        and config.landRestAnimationKey == \"salemLandRest\"\n        and config.landRestCrossFadeSeconds == 1\n        and config.waterSpeed == 5\n        and config.landSpeed == 2.5\n        and config.waterColliderOffsetY == 0.36\n        and config.landColliderOffsetY == 1.01\n        and config.waterTerrainAlignmentFactor == 0\n        and config.landTerrainAlignmentFactor == 1\n        and config.landDeathPlaybackSeconds == 3\n        and config.waterDeathSourceDurationSeconds == 21.7\n        and config.waterDeathRateMin == 0.5\n        and config.waterDeathRateMax == 1.5\n        and config.waterDeathRateSteps == 101\n        and config.waterPostWreckSeconds == 5\n        and config.mediumDebounceTicks == 3\n        and config.waterEnterDepth == 0.05\n        and config.waterExitDepth == 0.01\nend\n\nfunction SCOSeaParitySalemLifecycle.Probe(unit, previousWater, position)\n    local config = SCOSeaParitySalemConfig(unit)\n    if not config then return nil end\n    local waterResult, hasWater = Engine.HasWater()\n    if waterResult ~= EngineErrorCode.Success then return nil end\n    if not hasWater then return false end\n    local levelResult, waterLevel = Engine.GetWaterLevel()\n    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then return nil end\n    local positionResult = Engine.GetGlobalEntityWorldPosition(unit.id, position)\n    if positionResult ~= EngineErrorCode.Success then return nil end\n    local terrainResult, terrainHeight = Engine.SampleTerrainHeight(position)\n    if terrainResult ~= EngineErrorCode.Success or terrainHeight == nil then return nil end\n    local requiredDepth = previousWater\n        and config.waterExitDepth or config.waterEnterDepth\n    -- Bathymetry alone misclassifies a Salem standing above submerged terrain.\n    if position.y > waterLevel + requiredDepth then return false end\n    return terrainHeight < waterLevel - requiredDepth\nend\n\nfunction SCOSeaParitySalemLifecycle.AcceptProbe(unit, probed, config)\n    if probed == nil or probed == unit.scoSeaParitySalemMediumWater then\n        unit.scoSeaParitySalemCandidateWater = nil\n        unit.scoSeaParitySalemCandidateTicks = 0\n        return\n    end\n    if unit.scoSeaParitySalemCandidateWater == probed then\n        unit.scoSeaParitySalemCandidateTicks =\n            unit.scoSeaParitySalemCandidateTicks + 1\n    else\n        unit.scoSeaParitySalemCandidateWater = probed\n        unit.scoSeaParitySalemCandidateTicks = 1\n    end\n    if unit.scoSeaParitySalemCandidateTicks >= config.mediumDebounceTicks then\n        unit.scoSeaParitySalemMediumWater = probed\n        unit.scoSeaParitySalemCandidateWater = nil\n        unit.scoSeaParitySalemCandidateTicks = 0\n    end\nend\n\nfunction SCOSeaParitySalemLifecycle.SampleTransform(unit, elapsed, animation)\n    unit.scoSeaParitySalemTransformElapsed = elapsed\n    unit.scoSeaParitySalemAnimationOwner = \"transform\"\n    Engine.PlayAnimation(\n        unit.id, animation.id, SCOSeaParitySalemSentinelBase + elapsed)\nend\n\nfunction SCOSeaParitySalemLifecycle.ApplyTerrainAlignment(unit, water, config)\n    local factor = water\n        and config.waterTerrainAlignmentFactor\n        or config.landTerrainAlignmentFactor\n    if unit.scoSeaParitySalemTerrainAlignmentFactor == factor then return end\n    local result = Engine.SetMovementTerrainAlignmentFactor(unit.id, factor)\n    if result ~= EngineErrorCode.Success then\n        error(\"Salem terrain-alignment transition failed\")\n    end\n    unit.scoSeaParitySalemTerrainAlignmentFactor = factor\nend\n\nfunction SCOSeaParitySalemLifecycle.BeginTransform(\n    unit, elapsed, animation, targetWater, config)\n    SCOSeaParitySalemLifecycle.ApplyTerrainAlignment(\n        unit, targetWater, config)\n    if not unit.scoSeaParitySalemTransforming then\n        Engine.SetMovementEnabled(unit.id, false)\n        unit.scoSeaParitySalemTransforming = true\n        unit.isWalking = true\n        SCOSeaParitySalemLifecycle.SampleTransform(unit, elapsed, animation)\n    end\nend\n\nfunction SCOSeaParitySalemLifecycle.PlayWaterRest(unit, animations)\n    unit.scoSeaParitySalemAnimationOwner = \"water-rest\"\n    unit.isWalking = true\n    Engine.PlayAnimation(unit.id, animations.walk.id, 0.1)\nend\n\nfunction SCOSeaParitySalemLifecycle.PlayLandRest(unit, config, animations)\n    unit.scoSeaParitySalemTransformElapsed = config.transformDurationSeconds\n    unit.scoSeaParitySalemAnimationOwner = \"land-rest\"\n    unit.isWalking = true\n    Engine.PlayAnimation(\n        unit.id,\n        animations.salemLandRest.id,\n        config.landRestCrossFadeSeconds)\nend\n\nfunction SCOSeaParitySalemLifecycle.PlayLandWalk(unit, animations)\n    unit.scoSeaParitySalemAnimationOwner = \"land-walk\"\n    unit.isWalking = false\n    Engine.PlayAnimation(unit.id, animations.run.id, 0.1)\nend\n\nfunction SCOSeaParitySalemLifecycle.EnterStablePose(unit, water, config, animations)\n    unit.scoSeaParitySalemTransforming = nil\n    SCOSeaParitySalemLifecycle.ApplyTerrainAlignment(unit, water, config)\n    Engine.SetMovementMaxSpeed(unit.id, water and config.waterSpeed or config.landSpeed)\n    local colliderResult = Engine.SetVolumeColliderOffset(\n        unit.id,\n        EngineClasses.float3(\n            0,\n            water and config.waterColliderOffsetY or config.landColliderOffsetY,\n            0))\n    if colliderResult ~= EngineErrorCode.Success then\n        error(\"Salem collider-offset transition failed\")\n    end\n    if water then\n        SCOSeaParitySalemLifecycle.PlayWaterRest(unit, animations)\n    else\n        SCOSeaParitySalemLifecycle.PlayLandRest(unit, config, animations)\n    end\n    Engine.SetMovementEnabled(unit.id, true)\nend\n\nfunction SCOSeaParitySalemLifecycle.MediumThread(unit)\n    local config = SCOSeaParitySalemConfig(unit)\n    local animations = SCOSeaParitySalemAnimations(unit)\n    local transform = animations and animations.salemTransform\n    if not SCOSeaParitySalemLifecycle.IsSupported(unit)\n        or not animations.walk or not animations.walk.id\n        or not animations.run or not animations.run.id\n        or not animations.salemLandRest or not animations.salemLandRest.id\n        or not transform or not transform.id\n    then\n        error(\"Salem amphibious runtime contract is incomplete\")\n    end\n\n    local position = EngineClasses.float3()\n    local initialWater = SCOSeaParitySalemLifecycle.Probe(unit, true, position)\n    if initialWater == nil then initialWater = true end\n    local elapsed = 0\n    unit.scoSeaParitySalemMediumWater = initialWater\n    unit.scoSeaParitySalemCandidateWater = nil\n    unit.scoSeaParitySalemCandidateTicks = 0\n    unit.scoSeaParitySalemTransformElapsed = elapsed\n    if initialWater then\n        SCOSeaParitySalemLifecycle.EnterStablePose(\n            unit, true, config, animations)\n    else\n        SCOSeaParitySalemLifecycle.BeginTransform(\n            unit, elapsed, transform, false, config)\n    end\n\n    while SCOSeaParitySalemAlive(unit)\n        and unit.scoSeaParitySalemMovementActive == true\n    do\n        WaitTicks(1)\n        if not SCOSeaParitySalemAlive(unit) then break end\n        local probed = SCOSeaParitySalemLifecycle.Probe(\n            unit, unit.scoSeaParitySalemMediumWater, position)\n        SCOSeaParitySalemLifecycle.AcceptProbe(unit, probed, config)\n\n        local target = unit.scoSeaParitySalemMediumWater\n            and 0 or config.transformDurationSeconds\n        if elapsed ~= target then\n            SCOSeaParitySalemLifecycle.BeginTransform(\n                unit, elapsed, transform,\n                unit.scoSeaParitySalemMediumWater, config)\n            local sourceRate = target > elapsed\n                and config.transformSourceRate\n                or config.transformReverseSourceRate\n            elapsed = math.max(0, math.min(\n                config.transformDurationSeconds,\n                elapsed + sourceRate * Constants.TickTimeStep))\n            SCOSeaParitySalemLifecycle.SampleTransform(unit, elapsed, transform)\n            if elapsed == target then\n                SCOSeaParitySalemLifecycle.EnterStablePose(\n                    unit, unit.scoSeaParitySalemMediumWater, config, animations)\n            end\n        end\n    end\n    unit.scoSeaParitySalemMediumThread = nil\nend\n\nfunction SCOSeaParitySalemLifecycle.Start(unit)\n    if not SCOSeaParitySalemConfig(unit) then return false end\n    if unit.scoSeaParitySalemMovementUnavailable then return false end\n    if not SCOSeaParitySalemLifecycle.IsSupported(unit) then\n        error(\"Salem amphibious runtime contract is incomplete\")\n    end\n    SCOSeaParitySalemLifecycle.Stop(unit)\n    unit.scoSeaParitySalemMovementActive = true\n    unit.scoSeaParitySalemMediumThread =\n        unit:NewThread(SCOSeaParitySalemLifecycle.MediumThread)\n    return true\nend\n\nfunction SCOSeaParitySalemLifecycle.Stop(unit, movementUnavailable)\n    if unit.scoSeaParitySalemMediumThread then\n        KillThread(unit.scoSeaParitySalemMediumThread)\n    end\n    unit.scoSeaParitySalemMediumThread = nil\n    unit.scoSeaParitySalemMovementActive = nil\n    if movementUnavailable then\n        unit.scoSeaParitySalemMovementUnavailable = true\n    end\n    unit.scoSeaParitySalemCandidateWater = nil\n    unit.scoSeaParitySalemCandidateTicks = nil\n    unit.scoSeaParitySalemTransforming = nil\n    unit.scoSeaParitySalemAnimationOwner = nil\n    unit.scoSeaParitySalemTerrainAlignmentFactor = nil\nend\n\nfunction SCOSeaParitySalemLifecycle.SelectWaterDeath(unit, config)\n    local keys = config.waterDeathAnimationKeys\n    if not keys or #keys ~= 2 or config.waterDeathRateSteps < 2 then\n        error(\"Salem water-death selection contract is incomplete\")\n    end\n    local identity = unit.id and unit.id.index or 0\n    local key = keys[(identity % 2) + 1]\n    local step = math.floor(identity / 2) % config.waterDeathRateSteps\n    local rate = config.waterDeathRateMin\n        + (config.waterDeathRateMax - config.waterDeathRateMin)\n            * step / (config.waterDeathRateSteps - 1)\n    return key, rate\nend\n\nfunction SCOSeaParitySalemLifecycle.SampleWaterDeath(unit, animation, elapsed)\n    unit.scoSeaParitySalemDeathElapsed = elapsed\n    unit.scoSeaParitySalemAnimationOwner = \"water-death\"\n    Engine.PlayAnimation(\n        unit.id, animation.id, SCOSeaParitySalemSentinelBase + elapsed)\nend\n\nfunction SCOSeaParitySalemLifecycle.PlayWaterDeath(unit, animation, config, rate)\n    local elapsed = 0\n    SCOSeaParitySalemLifecycle.SampleWaterDeath(unit, animation, elapsed)\n    while elapsed < config.waterDeathSourceDurationSeconds do\n        WaitTicks(1)\n        if unit.deleted then return false end\n        elapsed = math.min(\n            config.waterDeathSourceDurationSeconds,\n            elapsed + rate * Constants.TickTimeStep)\n        SCOSeaParitySalemLifecycle.SampleWaterDeath(unit, animation, elapsed)\n    end\n    return true\nend\n\nfunction SCOSeaParitySalemBase:OnStopBeingBuilt(...)\n    SCOSeaParitySalemBaseOnStopBeingBuilt(self, ...)\n    if SCOSeaParitySalemConfig(self) then\n        self.scoSeaParitySalemMovementUnavailable = nil\n        SCOSeaParitySalemLifecycle.Start(self)\n    end\nend\n\nfunction SCOSeaParitySalemBase:UpdateAnimations()\n    if not SCOSeaParitySalemConfig(self) then\n        return SCOSeaParitySalemBaseUpdateAnimations(self)\n    end\n    if not SCOSeaParitySalemLifecycle.IsSupported(self) then\n        error(\"Salem amphibious runtime contract is incomplete\")\n    end\n    if self.dead or self.deleted or not self:IsCompleted() then return end\n    if not self.scoSeaParitySalemMediumThread then\n        SCOSeaParitySalemLifecycle.Start(self)\n        return\n    end\n    if self.scoSeaParitySalemMovementActive ~= true then return end\n    if self.scoSeaParitySalemTransforming then return end\n    if self.scoSeaParitySalemMediumWater then\n        if self.scoSeaParitySalemAnimationOwner ~= \"water-rest\" then\n            local animations = SCOSeaParitySalemAnimations(self)\n            if animations and animations.walk and animations.walk.id then\n                SCOSeaParitySalemLifecycle.PlayWaterRest(self, animations)\n            end\n        end\n        return\n    end\n    local config = SCOSeaParitySalemConfig(self)\n    local animations = SCOSeaParitySalemAnimations(self)\n    if not config or not animations or not animations.run or not animations.run.id\n        or not animations.salemLandRest or not animations.salemLandRest.id\n    then\n        error(\"Salem land-animation contract is incomplete\")\n    end\n    local movementResult, movementSpeed = Engine.GetMovementCurrentSpeed(self.id)\n    if movementResult ~= EngineErrorCode.Success\n        or type(movementSpeed) ~= \"number\"\n    then\n        -- The engine removes Movement before every remaining Lua callback is\n        -- necessarily drained. Make the first failed sample terminal so the\n        -- global animation dispatcher cannot query the missing component again.\n        SCOSeaParitySalemLifecycle.Stop(self, true)\n        return\n    end\n    if movementSpeed >= (animations.run.startSpeed or 0) then\n        if self.scoSeaParitySalemAnimationOwner ~= \"land-walk\" then\n            SCOSeaParitySalemLifecycle.PlayLandWalk(self, animations)\n        end\n    elseif self.scoSeaParitySalemAnimationOwner ~= \"land-rest\" then\n        SCOSeaParitySalemLifecycle.PlayLandRest(self, config, animations)\n    end\nend\n\nfunction SCOSeaParitySalemBase:OnDestroy(...)\n    if not SCOSeaParitySalemConfig(self) then\n        return SCOSeaParitySalemBaseOnDestroy(self, ...)\n    end\n    local position = EngineClasses.float3()\n    local deathWater = self.scoSeaParitySalemMediumWater == true\n    local probed = SCOSeaParitySalemLifecycle.Probe(self, deathWater, position)\n    if probed ~= nil then deathWater = probed end\n    self.scoSeaParitySalemDeathWater = deathWater\n    SCOSeaParitySalemLifecycle.Stop(self)\n    return SCOSeaParitySalemBaseOnDestroy(self, ...)\nend\n\nfunction SCOSeaParitySalemBase:DeathThread(overkillRatio)\n    local config = SCOSeaParitySalemConfig(self)\n    if not config then\n        return SCOSeaParitySalemBaseDeathThread(self, overkillRatio)\n    end\n    if not SCOSeaParitySalemLifecycle.IsSupported(self) then\n        error(\"Salem amphibious runtime contract is incomplete\")\n    end\n    local animations = SCOSeaParitySalemAnimations(self)\n    if not animations then\n        error(\"Salem death animation contract is incomplete\")\n    end\n    Engine.SetMovementEnabled(self.id, false)\n    if self.scoSeaParitySalemDeathWater then\n        local key, rate = SCOSeaParitySalemLifecycle.SelectWaterDeath(self, config)\n        local animation = animations[key]\n        if not animation or not animation.id then\n            error(\"Salem water-death animation contract is incomplete\")\n        end\n        self.scoSeaParitySalemWaterDeathKey = key\n        self.scoSeaParitySalemWaterDeathRate = rate\n        if not SCOSeaParitySalemLifecycle.PlayWaterDeath(\n            self, animation, config, rate)\n        then\n            return\n        end\n        if self:GetFractionComplete() >= 0.5 and self.spawnsWreck then\n            self:CreateWreckage(overkillRatio or 0)\n        end\n        WaitSeconds(config.waterPostWreckSeconds)\n    else\n        local animation = animations[config.landDeathAnimationKey]\n        if not animation or not animation.id then\n            error(\"Salem land-death animation contract is incomplete\")\n        end\n        self.scoSeaParitySalemAnimationOwner = \"land-death\"\n        Engine.PlayAnimation(self.id, animation.id, 0.1)\n        WaitSeconds(config.landDeathPlaybackSeconds)\n        if self:GetFractionComplete() >= 0.5 and self.spawnsWreck then\n            self:CreateWreckage(0.1)\n        end\n    end\n    self:Delete()\nend\n\n-- The named class remains the canonical template binding, while the\n-- faSalemAmphibious contract on HostGuardNavalUnit owns every lifecycle\n-- hook.  This also repairs a completed Salem instantiated through the\n-- default GuardNavalUnit class without double-starting its monitor.\nHostGuardFaCybranSalem = Class(\"GuardFaCybranSalem\", SCOSeaParitySalemBase)\n\n_G.SCOSeaParitySalemLifecycle = SCOSeaParitySalemLifecycle";
	}

	private static string BuildClientSalemClassAppendix()
	{
		return "\n\n-- Supreme Commander Overhaul Salem amphibious parity 1.0.0\nif not ClientGuardNavalUnit then\n    error(\"Salem amphibious client base is unavailable\")\nend\nClientGuardFaCybranSalem = Class(\n    \"GuardFaCybranSalem\", ClientGuardNavalUnit)";
	}

	public static string PatchUnitBlueprintValidatorSource(string source)
	{
		string text = Normalize(source);
		if (Count(text, "-- Supreme Commander Overhaul Salem amphibious NAVAL preservation 1.0.0") == 1)
		{
			ValidateUnitBlueprintValidator(text);
			return text;
		}
		RequireExactly(text, "-- Supreme Commander Overhaul Salem amphibious NAVAL preservation 1.0.0", 0, "Salem validator marker");
		RequireTokens(text, "TracksAmphibious = {\"LAND\", \"AMPHIBIOUS\"}", "local templateIdentifier = blueprint.general.tpId");
		string text2 = ReplaceExactly(text, "        for _, tagName in ipairs(movementSynchronizedTagNames) do\n            if not requiredMovementTagLookup[tagName] and movementBlueprintHasTag(blueprint, tagName) then\n                movementCheckLog(blueprint, \"Unit has movement type (\"..argument.type..\") but also has \"..tagName..\" tag (removed \"..tagName..\")\")\n                removeMovementTag(blueprint, tagName)\n            end\n        end", "        for _, tagName in ipairs(movementSynchronizedTagNames) do\n            -- Supreme Commander Overhaul Salem amphibious NAVAL preservation 1.0.0\n            local preserveSalemNavalTag = templateIdentifier == \"ugn2001\"\n                and argument.type == \"TracksAmphibious\"\n                and tagName == \"NAVAL\"\n            if not requiredMovementTagLookup[tagName]\n                and not preserveSalemNavalTag\n                and movementBlueprintHasTag(blueprint, tagName)\n            then\n                movementCheckLog(blueprint, \"Unit has movement type (\"..argument.type..\") but also has \"..tagName..\" tag (removed \"..tagName..\")\")\n                removeMovementTag(blueprint, tagName)\n            end\n        end", 1, "movement synchronized-tag removal branch");
		ValidateUnitBlueprintValidator(text2);
		return text2;
	}

	public static string PatchConstructionPreviewSource(string source)
	{
		string text = Normalize(source);
		if (Count(text, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
		{
			text = ApplyClientFinalWaterDepthPolicy(text);
			ValidateClientWaterPatch(text);
			return text;
		}
		RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, "sea-parity marker");
		RequireExactly(text, "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", 1, "SCOM Seraphim marker");
		RequireExactly(text, "-- SCO_ClientWaterPlacement", 1, "SCOM client-water marker");
		RequireTokens(text, "function CanPlaceAtArea(", "SCO_StockCanPlaceAtArea", "SCO_GetSeraphimWaterPlacementHeight", "local function OverhaulFactoryPlacementReservationsAreClear(position, tp)", "local PlacementLayer = Import(\"common/layers.lua\").PlacementLayer");
		int num = text.LastIndexOf("\n--Only for annotataions\nreturn {", StringComparison.Ordinal);
		if (num < 0)
		{
			throw Incompatible("Construction preview terminal return drifted.");
		}
		string text2 = ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(text, "local constructionGhostIDs = { }\n", "local constructionGhostIDs = { }\n" + BuildClientPlacementSizingPrelude(), 1, "construction-preview placement-size prelude anchor"), "unitTemplate.skirtSize", "SCOSeaParityPlacementSize(unitTemplate)", 13, "construction-preview unit placement-size references"), "PlacementUtils.GetPlacementBounds(position, tp.skirtSize)", "PlacementUtils.GetPlacementBounds(position, SCOSeaParityPlacementSize(tp))", 1, "SCOM water placement-size reference"), "                if SCO_RequiresSeraphimWaterPlacement(unitTemplate) then\n                    targetHeight = SCO_GetSeraphimWaterPlacementHeight(point, targetHeight)\n                end", "                if SCOSeaParityWaterPlacementState(unitTemplate, point) == true then\n                    targetHeight = SCO_GetSeraphimWaterPlacementHeight(point, targetHeight)\n                end", 1, "SCOM water placement-height branch"), "            local isWaterPlacement = SCO_RequiresSeraphimWaterPlacement(unitTemplate)\n            local waterLevel = isWaterPlacement and SCO_GetSeraphimWaterLevel() or nil\n            local waterRollOffIsValid = not isWaterPlacement\n                or (waterLevel ~= nil and SCO_CanPlaceSeraphimWaterFactory(unitTemplate, position))", "            local waterPlacementState = SCOSeaParityWaterPlacementState(unitTemplate, position)\n            local isWaterPlacement = waterPlacementState == true\n            local waterLevel = isWaterPlacement and SCO_GetSeraphimWaterLevel() or nil\n            local waterRollOffIsValid = waterPlacementState ~= nil\n                and (not isWaterPlacement\n                or not SCOSeaParityIsWaterFactory(unitTemplate)\n                or (waterLevel ~= nil and SCOSeaParityHasUsablePreviewRolloff(unitTemplate, position, waterLevel)))", 1, "SCOM water rolloff preview branch"), "        if not CanPlaceAtArea(minX, minY, maxX, maxY, PlacementUtils.GetPlacementDomain(tp), false) then\n            return false\n        end", "        local waterPlacementState = SCOSeaParityWaterPlacementState(tp, position)\n        if waterPlacementState == nil then return false end\n        local isWaterPlacement = waterPlacementState == true\n        if isWaterPlacement then\n            local waterError, hasWater = Engine.HasWater()\n            local levelError, waterLevel = Engine.GetWaterLevel()\n            local results = {}\n            local flagsError = Engine.GetLocalGridCellFlags(\n                _G.localBuildingPlacementGridID,\n                EngineClasses.int2(minX, minY),\n                EngineClasses.int2(maxX, maxY),\n                results)\n            local expectedCells = (maxX - minX + 1) * (maxY - minY + 1)\n            if waterError ~= EngineErrorCode.Success or not hasWater\n                or levelError ~= EngineErrorCode.Success\n                or flagsError ~= EngineErrorCode.Success\n                or #results ~= expectedCells\n            then\n                return false\n            end\n            for _, result in ipairs(results) do\n                if not SCOSeaParityWaterCellIsClear(result.flags) then return false end\n            end\n            for x = minX, maxX do\n                for z = minY, maxY do\n                    if not SCOSeaParityCellIsDeepEnough(\n                        tp, EngineClasses.int2(x, z), waterLevel) then\n                        return false\n                    end\n                end\n            end\n        elseif not CanPlaceAtArea(minX, minY, maxX, maxY, PlacementUtils.GetPlacementDomain(tp), false) then\n            return false\n        end", 1, "SCOM factory-reservation water branch"), "                    isValid = isValid and (not isWaterPlacement\n                        or (waterRollOffIsValid and waterLevel ~= nil\n                            and SCO_IsSeraphimSubmergedCell(cellCoord, waterLevel)))\n                    isValid = isValid and dualSiteIsValid\n                    cellIsValid[x][y] = isValid\n", "                    if isWaterPlacement then\n                        local flags = results[1].flags\n                        isValid = waterRollOffIsValid\n                            and waterLevel ~= nil\n                            and SCOSeaParityWaterCellIsClear(flags)\n                            and SCOSeaParityCellIsDeepEnough(\n                                unitTemplate, cellCoord, waterLevel)\n                    end\n                    isValid = isValid and dualSiteIsValid\n                    cellIsValid[x][y] = isValid\n", 1, "SCOM water-preview cell branch");
		num = text2.LastIndexOf("\n--Only for annotataions\nreturn {", StringComparison.Ordinal);
		string text3 = ApplyClientFinalWaterDepthPolicy(Normalize(text2.Insert(num, "\n\n-- Supreme Commander Overhaul sea parity 1.0.0\n-- Preview equivalent of the final host validator. Deep water carries both Water\n-- and InvalidTerrain; resources, reservations and occupied cells remain blocked.\nlocal SCOSeaParityPreviousCanPlaceAtArea = CanPlaceAtArea\nlocal SCOSeaParityPreviewMargin = 1.5\n\nlocal function SCOSeaParityPreviewRequiresWater(tp)\n    return SCOSeaParityIsWaterPlacement(tp)\nend\n\nlocal function SCOSeaParityPreviewWaterLevel()\n    local waterError, hasWater = Engine.HasWater()\n    if waterError ~= EngineErrorCode.Success or not hasWater then return nil end\n    local levelError, waterLevel = Engine.GetWaterLevel()\n    if levelError ~= EngineErrorCode.Success then return nil end\n    return waterLevel\nend\n\nlocal function SCOSeaParityPreviewPointIsSubmerged(position, waterLevel)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - SCOSeaParityPreviewMargin\nend\n\nlocal function SCOSeaParityAllPreviewRolloffsAreSubmerged(tp, position, waterLevel)\n    local routes = tp.construction and tp.construction.rollOffPoints\n    local ramps = tp.additions and tp.additions.rollOffRamps\n    if routes and #routes ~= 2 then return false end\n    if ramps and #ramps ~= 2 then return false end\n    if not routes and not ramps then return false end\n    for index = 1, 2 do\n        local route = routes and routes[index]\n        local ramp = ramps and ramps[index]\n        local routeOffset = route and route.offset or ramp and ramp.rampOffset\n        local exitOffset = ramp and ramp.clearanceOffset\n            or routeOffset and {\n                x = (routeOffset.x or 0) * ((route and route.exitScale) or 2),\n                z = (routeOffset.z or 0) * ((route and route.exitScale) or 2),\n            }\n        if not routeOffset or not exitOffset then return false end\n        local routePoint = EngineClasses.float3(\n            position.x + (routeOffset.x or 0),\n            waterLevel,\n            position.z + (routeOffset.z or 0))\n        local exitPoint = EngineClasses.float3(\n            position.x + (exitOffset.x or 0),\n            waterLevel,\n            position.z + (exitOffset.z or 0))\n        if not SCOSeaParityPreviewPointIsSubmerged(routePoint, waterLevel)\n            or not SCOSeaParityPreviewPointIsSubmerged(exitPoint, waterLevel)\n        then\n            return false\n        end\n    end\n    return true\nend\n\nfunction CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor, tp, position)\n    if not SCOSeaParityPreviewRequiresWater(tp) then\n        return SCOSeaParityPreviousCanPlaceAtArea(\n            minX, minY, maxX, maxY, domain, isAlloyExtractor, tp, position)\n    end\n    local placementState = SCOSeaParityWaterPlacementState(tp, position)\n    if placementState == nil then return false end\n    if not placementState then\n        return SCO_StockCanPlaceAtArea(\n            minX, minY, maxX, maxY, domain, isAlloyExtractor)\n    end\n    if isAlloyExtractor or position == nil then return false end\n    local waterLevel = SCOSeaParityPreviewWaterLevel()\n    if waterLevel == nil\n        or (SCOSeaParityIsWaterFactory(tp)\n            and not SCOSeaParityAllPreviewRolloffsAreSubmerged(\n                tp, position, waterLevel))\n    then\n        return false\n    end\n\n    local min = EngineClasses.int2(minX, minY)\n    local max = EngineClasses.int2(maxX, maxY)\n    local results = {}\n    local errorCode = Engine.GetLocalGridCellFlags(\n        _G.localBuildingPlacementGridID, min, max, results)\n    local expectedCells = (maxX - minX + 1) * (maxY - minY + 1)\n    if errorCode ~= EngineErrorCode.Success or #results ~= expectedCells then\n        return false\n    end\n    for _, gridQueryResult in ipairs(results) do\n        if not SCOSeaParityWaterCellIsClear(gridQueryResult.flags) then return false end\n    end\n    for x = minX, maxX do\n        for z = minY, maxY do\n            if not SCOSeaParityCellIsDeepEnough(\n                tp, EngineClasses.int2(x, z), waterLevel) then\n                return false\n            end\n        end\n    end\n    return true\nend")));
		ValidateClientWaterPatch(text3);
		return text3;
	}

	private static string ApplyHostFinalWaterDepthPolicy(string source)
	{
		int num = Count(source, "-- Supreme Commander Overhaul final naval placement depth 1.0.0");
		return num switch
		{
			1 => source, 
			0 => ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(source, "local SCOSeaParityWaterMargin = 1.5\n", string.Empty, 1, "obsolete host water-margin constant"), "\nlocal function SCOSeaParityRequiresWater(tp)", "\n-- Supreme Commander Overhaul final naval placement depth 1.0.0\nlocal function SCOSeaParityMinimumDepth(tp)\n    local additions = tp and tp.additions\n    local faContract = additions and additions.faSourceContract\n    local authored = faContract and faContract.minimumWaterDepth\n    if type(authored) == \"number\" and authored >= 0 then\n        return authored\n    end\n    local id = tp and tp.general and tp.general.tpId\n    return id and SCOSeaParityWaterMinimumDepth[id]\nend\nlocal function SCOSeaParityRequiresWater(tp)", 1, "host final-depth resolver anchor"), "local minimumDepth = SCOSeaParityWaterMinimumDepth[id]", "local minimumDepth = SCOSeaParityMinimumDepth(tp)", 1, "host direct minimum-depth lookup"), "local minimumDepth = id and SCOSeaParityWaterMinimumDepth[id]", "local minimumDepth = SCOSeaParityMinimumDepth(tp)", 2, "host optional minimum-depth lookups"), Normalize("local function SCOSeaParityAllRolloffRoutesAreSubmerged(position, tp, waterLevel)\n    local id = tp and tp.general and tp.general.tpId\n    local minimumDepth = SCOSeaParityMinimumDepth(tp)\n    if minimumDepth == nil then return false end\n    local routes = tp.construction and tp.construction.rollOffPoints\n    local ramps = tp.additions and tp.additions.rollOffRamps\n    if routes and #routes ~= 2 then return false end\n    if ramps and #ramps ~= 2 then return false end\n    if not routes and not ramps then return false end\n    for index = 1, 2 do\n        local route = routes and routes[index]\n        local ramp = ramps and ramps[index]\n        local routeOffset = route and route.offset or ramp and ramp.rampOffset\n        local exitOffset = ramp and ramp.clearanceOffset\n            or routeOffset and {\n                x = (routeOffset.x or 0) * ((route and route.exitScale) or 2),\n                z = (routeOffset.z or 0) * ((route and route.exitScale) or 2),\n            }\n        if not routeOffset or not exitOffset then return false end\n        local routePoint = EngineClasses.float3(\n            position.x + (routeOffset.x or 0),\n            waterLevel,\n            position.z + (routeOffset.z or 0))\n        local exitPoint = EngineClasses.float3(\n            position.x + (exitOffset.x or 0),\n            waterLevel,\n            position.z + (exitOffset.z or 0))\n        if not SCOSeaParityIsSubmergedPoint(routePoint, waterLevel, minimumDepth)\n            or not SCOSeaParityIsSubmergedPoint(exitPoint, waterLevel, minimumDepth)\n        then\n            return false\n        end\n    end\n    return true\nend"), Normalize("local function SCOSeaParityHasUsableRolloffRoute(position, tp, waterLevel)\n    local minimumDepth = SCOSeaParityMinimumDepth(tp)\n    if minimumDepth == nil then return false end\n    local routes = tp.construction and tp.construction.rollOffPoints\n    local ramps = tp.additions and tp.additions.rollOffRamps\n    if routes and #routes ~= 2 then return false end\n    if ramps and #ramps ~= 2 then return false end\n    if not routes and not ramps then return false end\n    for index = 1, 2 do\n        local route = routes and routes[index]\n        local ramp = ramps and ramps[index]\n        local routeOffset = route and route.offset or ramp and ramp.rampOffset\n        local exitOffset = ramp and ramp.clearanceOffset\n            or routeOffset and {\n                x = (routeOffset.x or 0) * ((route and route.exitScale) or 2),\n                z = (routeOffset.z or 0) * ((route and route.exitScale) or 2),\n            }\n        if routeOffset and exitOffset then\n            local routePoint = EngineClasses.float3(\n                position.x + (routeOffset.x or 0),\n                waterLevel,\n                position.z + (routeOffset.z or 0))\n            local exitPoint = EngineClasses.float3(\n                position.x + (exitOffset.x or 0),\n                waterLevel,\n                position.z + (exitOffset.z or 0))\n            if SCOSeaParityIsSubmergedPoint(\n                    routePoint, waterLevel, minimumDepth)\n                and SCOSeaParityIsSubmergedPoint(\n                    exitPoint, waterLevel, minimumDepth)\n            then\n                return true\n            end\n        end\n    end\n    return false\nend"), 1, "host usable naval rolloff predicate"), "SCOSeaParityAllRolloffRoutesAreSubmerged(\n", "SCOSeaParityHasUsableRolloffRoute(\n", 1, "host usable naval rolloff call"), 
			_ => throw Incompatible($"Expected zero or one final naval-depth markers, found {num}."), 
		};
	}

	private static string ApplyClientFinalWaterDepthPolicy(string source)
	{
		int num = Count(source, "-- Supreme Commander Overhaul final naval placement depth 1.0.0");
		return num switch
		{
			1 => source, 
			0 => ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(ReplaceExactly(source, "\nlocal function SCOSeaParityIsWaterPlacement(tp)", "\n-- Supreme Commander Overhaul final naval placement depth 1.0.0\nlocal function SCOSeaParityMinimumDepth(tp)\n    local additions = tp and tp.additions\n    local faContract = additions and additions.faSourceContract\n    local authored = faContract and faContract.minimumWaterDepth\n    if type(authored) == \"number\" and authored >= 0 then\n        return authored\n    end\n    local id = tp and tp.general and tp.general.tpId\n    return id and SCOSeaParityWaterMinimumDepth[id]\nend\nlocal function SCOSeaParityIsWaterPlacement(tp)", 1, "client final-depth resolver anchor"), "local minimumDepth = SCOSeaParityWaterMinimumDepth[id]", "local minimumDepth = SCOSeaParityMinimumDepth(tp)", 1, "client direct minimum-depth lookup"), "local minimumDepth = id and SCOSeaParityWaterMinimumDepth[id]", "local minimumDepth = SCOSeaParityMinimumDepth(tp)", 1, "client optional minimum-depth lookup"), "local SCOSeaParityPreviewMargin = 1.5\n\n", string.Empty, 1, "obsolete client preview-margin constant"), "local function SCOSeaParityPreviewPointIsSubmerged(position, waterLevel)\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - SCOSeaParityPreviewMargin\nend", "local function SCOSeaParityPreviewPointIsSubmerged(tp, position, waterLevel)\n    local minimumDepth = SCOSeaParityMinimumDepth(tp)\n    if minimumDepth == nil then return false end\n    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)\n    return errorCode == EngineErrorCode.Success\n        and terrainHeight <= waterLevel - minimumDepth\nend", 1, "client rolloff depth helper"), "SCOSeaParityPreviewPointIsSubmerged(routePoint, waterLevel)", "SCOSeaParityPreviewPointIsSubmerged(tp, routePoint, waterLevel)", 1, "client rolloff route depth call"), "SCOSeaParityPreviewPointIsSubmerged(exitPoint, waterLevel)", "SCOSeaParityPreviewPointIsSubmerged(tp, exitPoint, waterLevel)", 1, "client rolloff exit depth call"), Normalize("local function SCOSeaParityAllPreviewRolloffsAreSubmerged(tp, position, waterLevel)\n    local routes = tp.construction and tp.construction.rollOffPoints\n    local ramps = tp.additions and tp.additions.rollOffRamps\n    if routes and #routes ~= 2 then return false end\n    if ramps and #ramps ~= 2 then return false end\n    if not routes and not ramps then return false end\n    for index = 1, 2 do\n        local route = routes and routes[index]\n        local ramp = ramps and ramps[index]\n        local routeOffset = route and route.offset or ramp and ramp.rampOffset\n        local exitOffset = ramp and ramp.clearanceOffset\n            or routeOffset and {\n                x = (routeOffset.x or 0) * ((route and route.exitScale) or 2),\n                z = (routeOffset.z or 0) * ((route and route.exitScale) or 2),\n            }\n        if not routeOffset or not exitOffset then return false end\n        local routePoint = EngineClasses.float3(\n            position.x + (routeOffset.x or 0),\n            waterLevel,\n            position.z + (routeOffset.z or 0))\n        local exitPoint = EngineClasses.float3(\n            position.x + (exitOffset.x or 0),\n            waterLevel,\n            position.z + (exitOffset.z or 0))\n        if not SCOSeaParityPreviewPointIsSubmerged(tp, routePoint, waterLevel)\n            or not SCOSeaParityPreviewPointIsSubmerged(tp, exitPoint, waterLevel)\n        then\n            return false\n        end\n    end\n    return true\nend"), Normalize("SCOSeaParityHasUsablePreviewRolloff = function(tp, position, waterLevel)\n    local routes = tp.construction and tp.construction.rollOffPoints\n    local ramps = tp.additions and tp.additions.rollOffRamps\n    if routes and #routes ~= 2 then return false end\n    if ramps and #ramps ~= 2 then return false end\n    if not routes and not ramps then return false end\n    for index = 1, 2 do\n        local route = routes and routes[index]\n        local ramp = ramps and ramps[index]\n        local routeOffset = route and route.offset or ramp and ramp.rampOffset\n        local exitOffset = ramp and ramp.clearanceOffset\n            or routeOffset and {\n                x = (routeOffset.x or 0) * ((route and route.exitScale) or 2),\n                z = (routeOffset.z or 0) * ((route and route.exitScale) or 2),\n            }\n        if routeOffset and exitOffset then\n            local routePoint = EngineClasses.float3(\n                position.x + (routeOffset.x or 0),\n                waterLevel,\n                position.z + (routeOffset.z or 0))\n            local exitPoint = EngineClasses.float3(\n                position.x + (exitOffset.x or 0),\n                waterLevel,\n                position.z + (exitOffset.z or 0))\n            if SCOSeaParityPreviewPointIsSubmerged(\n                    tp, routePoint, waterLevel)\n                and SCOSeaParityPreviewPointIsSubmerged(\n                    tp, exitPoint, waterLevel)\n            then\n                return true\n            end\n        end\n    end\n    return false\nend"), 1, "client usable naval rolloff predicate"), "SCOSeaParityAllPreviewRolloffsAreSubmerged(\n", "SCOSeaParityHasUsablePreviewRolloff(\n", 1, "client usable naval rolloff call"), 
			_ => throw Incompatible($"Expected zero or one final naval-depth markers, found {num}."), 
		};
	}

	private static string ApplyHostNavalUsableRolloffPolicy(string source)
	{
		int num = Count(source, "-- Supreme Commander Overhaul usable naval factory rolloff 1.0.0");
		return num switch
		{
			1 => source, 
			0 => ReplaceExactly(ReplaceExactly(source, "local function SCOSeaParitySelectRolloffRoute(factory, rallyPoint)\n    local routes = factory.tp.construction and factory.tp.construction.rollOffPoints\n    if not routes or #routes ~= 2 then\n        error(\"Sea-parity naval factory lost its two-route contract.\")\n    end\n    if rallyPoint == nil then return routes[1] end\n    local selected = nil\n    local selectedDistance = nil\n    for _, route in ipairs(routes) do\n        if not route.offset then error(\"Sea-parity rolloff route has no offset.\") end\n        local point = SCOSeaParityRotateFactoryOffset(factory, route.offset, 1, rallyPoint.y)\n        local dx = point.x - rallyPoint.x\n        local dz = point.z - rallyPoint.z\n        local distance = dx * dx + dz * dz\n        if selectedDistance == nil or distance < selectedDistance then\n            selected = route\n            selectedDistance = distance\n        end\n    end\n    return selected\nend", "-- Supreme Commander Overhaul usable naval factory rolloff 1.0.0\nlocal function SCOSeaParityRolloffMinimumDepth(factory)\n    local additions = factory.tp and factory.tp.additions\n    local faContract = additions and additions.faSourceContract\n    local authored = faContract and faContract.minimumWaterDepth\n    if type(authored) == \"number\" and authored >= 0 then\n        return authored\n    end\n    return 1.5\nend\n\nlocal function SCOSeaParityRolloffRouteIsSubmerged(\n    factory, route, waterLevel, minimumDepth)\n    if not route or not route.offset then return false end\n    local routePoint = SCOSeaParityRotateFactoryOffset(\n        factory, route.offset, 1, waterLevel)\n    local exitPoint = SCOSeaParityRotateFactoryOffset(\n        factory, route.offset, route.exitScale or 2, waterLevel)\n    local routeError, routeTerrain = Engine.SampleTerrainHeight(routePoint)\n    local exitError, exitTerrain = Engine.SampleTerrainHeight(exitPoint)\n    return routeError == EngineErrorCode.Success\n        and exitError == EngineErrorCode.Success\n        and routeTerrain <= waterLevel - minimumDepth\n        and exitTerrain <= waterLevel - minimumDepth\nend\n\nlocal function SCOSeaParitySelectRolloffRoute(factory, rallyPoint, waterLevel)\n    local routes = factory.tp.construction and factory.tp.construction.rollOffPoints\n    if not routes or #routes ~= 2 then\n        error(\"Sea-parity naval factory lost its two-route contract.\")\n    end\n    local minimumDepth = SCOSeaParityRolloffMinimumDepth(factory)\n    local selected = nil\n    local selectedDistance = nil\n    for _, route in ipairs(routes) do\n        if SCOSeaParityRolloffRouteIsSubmerged(\n            factory, route, waterLevel, minimumDepth)\n        then\n            if rallyPoint == nil then return route end\n            local point = SCOSeaParityRotateFactoryOffset(\n                factory, route.offset, 1, waterLevel)\n            local dx = point.x - rallyPoint.x\n            local dz = point.z - rallyPoint.z\n            local distance = dx * dx + dz * dz\n            if selectedDistance == nil or distance < selectedDistance then\n                selected = route\n                selectedDistance = distance\n            end\n        end\n    end\n    if selected == nil then\n        error(\"Sea-parity naval factory has no submerged rolloff route.\")\n    end\n    return selected\nend", 1, "host naval-factory rolloff selector"), "function SCOSeaParityNavalFactoryHostClass:RollOffUnit(targetUnit)\n    local source = self.unitBeingBuiltSource or self\n    local rallyPoint = source.rallyPoint\n    local route = SCOSeaParitySelectRolloffRoute(self, rallyPoint)\n    local waterLevel = nil\n    local waterError, hasWater = Engine.HasWater()\n    if waterError == EngineErrorCode.Success and hasWater then\n        local levelError, level = Engine.GetWaterLevel()\n        if levelError == EngineErrorCode.Success then waterLevel = level end\n    end\n    if waterLevel == nil then error(\"Sea-parity naval rolloff has no water level.\") end", "function SCOSeaParityNavalFactoryHostClass:RollOffUnit(targetUnit)\n    local source = self.unitBeingBuiltSource or self\n    local rallyPoint = source.rallyPoint\n    local waterLevel = nil\n    local waterError, hasWater = Engine.HasWater()\n    if waterError == EngineErrorCode.Success and hasWater then\n        local levelError, level = Engine.GetWaterLevel()\n        if levelError == EngineErrorCode.Success then waterLevel = level end\n    end\n    if waterLevel == nil then error(\"Sea-parity naval rolloff has no water level.\") end\n    local route = SCOSeaParitySelectRolloffRoute(self, rallyPoint, waterLevel)", 1, "host naval-factory water-aware rolloff call"), 
			_ => throw Incompatible($"Expected zero or one usable naval-rolloff markers, found {num}."), 
		};
	}

	public static string PatchPlacementGhostLoaderSource(string source)
	{
		string text = Normalize(source);
		if (Count(text, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
		{
			ValidatePlacementGhostLoader(text);
			return text;
		}
		RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, "placement-ghost sea-parity marker");
		RequireTokens(text, "function CreatePlacementGhostPrefab(tp)", "selectionSize = tp.skirtSize or tp.footprint", "if tp.skirtSize then", "localGridModifierTemplates", "globalGridModifierTemplates", "function CreatePlacementGridTilePrefab(state)");
		RequireExactly(text, "\n    if tp.skirtSize then\n", 1, "placement-ghost grid block");
		int num = text.IndexOf("\n    if tp.skirtSize then\n", StringComparison.Ordinal);
		string text2 = text.Substring(0, num);
		string text3 = text.Substring(num);
		RequireExactly(text3, "tp.skirtSize", 5, "placement-ghost grid-size references");
		text3 = text3.Replace("tp.skirtSize", "SCOSeaParityGhostPlacementSize");
		string newValue = "\n\n    -- Supreme Commander Overhaul sea parity 1.0.0\n    -- Water-built mobiles need a placement-only grid; never persist a skirt on the unit template.\n    local SCOSeaParityGhostPlacementSize = tp.skirtSize\n    local SCOSeaParityGhostRequiresWater = tp.general\n        and tp.general.requiresWaterPlacement == true\n    if SCOSeaParityGhostPlacementSize == nil\n        and SCOSeaParityGhostRequiresWater\n    then\n        SCOSeaParityGhostPlacementSize = tp.footprint\n    end\n    if SCOSeaParityGhostRequiresWater\n        and SCOSeaParityGhostPlacementSize == nil\n    then\n        error(\"Water placement ghost has neither skirt nor footprint.\")\n    end\n    if SCOSeaParityGhostPlacementSize then\n";
		RequireExactly(text3, "\n    if SCOSeaParityGhostPlacementSize then\n", 1, "sized placement-ghost grid block");
		text3 = text3.Replace("\n    if SCOSeaParityGhostPlacementSize then\n", newValue);
		string text4 = text2 + text3;
		ValidatePlacementGhostLoader(text4);
		return text4;
	}

	public static string PatchImportScannerSource(string source)
	{
		string text = Normalize(source);
		if (Count(text, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
		{
			ValidateImportScanner(text);
			return text;
		}
		RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, "sea-parity marker");
		RequireTokens(text, "function ScanDir(directory)", "Engine.GetFoldersInsideDirectory", "local SCO_ScanDir = ScanDir", "common/units/unitsTemplates/");
		StringBuilder stringBuilder = new StringBuilder(text.TrimEnd(Array.Empty<char>()));
		stringBuilder.AppendLine().AppendLine().AppendLine("-- Supreme Commander Overhaul sea parity 1.0.0")
			.AppendLine("-- Register cache-only UEF/Cybran unit and projectile folders after SCOM's scanner.")
			.AppendLine("local SCOSeaParityPreviousScanDir = ScanDir")
			.AppendLine("function ScanDir(directory)")
			.AppendLine("    local folders = SCOSeaParityPreviousScanDir(directory)")
			.AppendLine("    local generated")
			.AppendLine("    if directory == \"common/units/unitsTemplates/\" then")
			.AppendLine("        generated = {");
		foreach (string item in SeaParityManifest.GeneratedTemplates.Select((SeaTemplateSpec spec) => spec.TargetId))
		{
			stringBuilder.Append("            \"").Append(item).AppendLine("\",");
		}
		stringBuilder.AppendLine("        }").AppendLine("    elseif directory == \"common/projectiles/projectilesTemplates/\" then").AppendLine("        generated = {");
		foreach (string generatedProjectileId in SeaParityManifest.GeneratedProjectileIds)
		{
			stringBuilder.Append("            \"").Append(generatedProjectileId).AppendLine("\",");
		}
		stringBuilder.AppendLine("        }").AppendLine("    else").AppendLine("        return folders")
			.AppendLine("    end")
			.AppendLine("    local known = {}")
			.AppendLine("    for _, folder in ipairs(folders) do known[folder] = true end")
			.AppendLine("    for _, templateId in ipairs(generated) do")
			.AppendLine("        local folder = directory .. templateId")
			.AppendLine("        if not known[folder] then")
			.AppendLine("            table.insert(folders, folder)")
			.AppendLine("            known[folder] = true")
			.AppendLine("        end")
			.AppendLine("    end")
			.AppendLine("    return folders")
			.AppendLine("end");
		string text2 = Normalize(stringBuilder.ToString());
		ValidateImportScanner(text2);
		return text2;
	}

	public static string PatchRegistrationTableSource(string source, string tableName)
	{
		if (tableName != "AvailableUnits" && tableName != "QuickLaunchUnits")
		{
			throw new ArgumentOutOfRangeException("tableName");
		}
		string text = Normalize(source);
		if (Count(text, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
		{
			ValidateRegistrationTable(text, tableName);
			return text;
		}
		RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, "sea-parity marker");
		RequireTokens(text, tableName + " =", "ucl0000", "ugl0000");
		StringBuilder stringBuilder = new StringBuilder(text.TrimEnd(Array.Empty<char>()));
		stringBuilder.AppendLine().AppendLine().AppendLine("-- Supreme Commander Overhaul sea parity 1.0.0")
			.AppendLine("-- Keep generated naval content loadable for AI and reduced quick launch.");
		foreach (string registrationId in SeaParityManifest.RegistrationIds)
		{
			string text2 = tableName + "[\"" + registrationId + "\"] = true";
			int num = Count(text, text2);
			if (num > 1)
			{
				throw Incompatible(tableName + " contains duplicate upstream registration for " + registrationId + ".");
			}
			if (num == 0)
			{
				stringBuilder.AppendLine(text2);
			}
		}
		if (tableName == "QuickLaunchUnits")
		{
			foreach (string quickLaunchOnlyRegistrationId in SeaParityManifest.QuickLaunchOnlyRegistrationIds)
			{
				string text3 = tableName + "[\"" + quickLaunchOnlyRegistrationId + "\"] = true";
				RequireExactly(text, text3, 0, tableName + " missing " + quickLaunchOnlyRegistrationId);
				RequireExactly(text, quickLaunchOnlyRegistrationId + " = true", 0, tableName + " upstream bare registration for " + quickLaunchOnlyRegistrationId);
				stringBuilder.AppendLine(text3);
			}
		}
		string text4 = Normalize(stringBuilder.ToString());
		ValidateRegistrationTable(text4, tableName);
		return text4;
	}

	public static string PatchExistingAirFactoryVisibilitySource(string source, string targetId)
	{
		if (!SeaParityManifest.ExistingAirFactoryVisibilityIds.Contains<string>(targetId))
		{
			throw new ArgumentOutOfRangeException("targetId");
		}
		string text = Normalize(source);
		if (Count(text, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
		{
			ValidateExistingAirFactoryVisibility(text, targetId);
			return text;
		}
		RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, targetId + " sea-parity marker");
		RequireExactly(text, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, targetId + " FA air-factory marker");
		RequireTokens(text, "tpId = \"" + targetId + "\"", "faAirFactoryLifecycle", "UnitTemplate.construction.buildPower");
		int num = Count(text, "        \"DEMO_UI_ONLY\",\n");
		if (num > 1)
		{
			throw Incompatible("Expected at most 1 " + targetId + " demo-only tag line occurrence, found " + num + ".");
		}
		string text2 = text;
		if (num == 1)
		{
			text2 = ReplaceExactly(text2, "        \"DEMO_UI_ONLY\",\n", string.Empty, 1, targetId + " demo-only tag line");
		}
		text2 = Normalize(text2.TrimEnd(Array.Empty<char>()) + "\n\n-- Supreme Commander Overhaul sea parity 1.0.0\n-- Expose the imported FA air-factory upgrade without changing its lifecycle.\n");
		ValidateExistingAirFactoryVisibility(text2, targetId);
		return text2;
	}

	public static string PatchWaterFactoryTemplateSource(string source, string targetId)
	{
		if (!SeaParityManifest.WaterFactoryIds.Contains<string>(targetId))
		{
			throw new ArgumentOutOfRangeException("targetId");
		}
		string text = Normalize(source);
		if (Count(text, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
		{
			ValidateWaterFactoryTemplate(text, targetId);
			return text;
		}
		RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, targetId + " sea-parity marker");
		RequireTokens(text, "UnitTemplate", "tpId = \"" + targetId + "\"", "NAVAL", "FACTORY");
		bool num = text.Contains("rollOffPoints") && text.Contains("unitSpin");
		bool flag = text.Contains("rollOffRamps") && text.Contains("rampOffset") && text.Contains("clearanceOffset");
		if (!num && !flag)
		{
			throw Incompatible(targetId + " has neither an authored rollOffPoints nor rollOffRamps contract.");
		}
		string text2 = "\n\n-- Supreme Commander Overhaul sea parity 1.0.0\n-- Water placement is authoritative on both preview and host validators.\nUnitTemplate.general.requiresWaterPlacement = true\nUnitTemplate.additions = UnitTemplate.additions or {}\nUnitTemplate.additions.seaParityWaterFactory = true\nlocal SCOSeaParityRolloffs = UnitTemplate.construction\n    and UnitTemplate.construction.rollOffPoints\nlocal SCOSeaParityRamps = UnitTemplate.additions.rollOffRamps\nif (not SCOSeaParityRolloffs or #SCOSeaParityRolloffs ~= 2)\n    and (not SCOSeaParityRamps or #SCOSeaParityRamps ~= 2)\nthen\n    error(\"Sea-parity water factory requires exactly two rolloff routes: " + targetId + "\")\nend";
		string text3 = text.TrimEnd(Array.Empty<char>()) + text2 + "\n";
		ValidateWaterFactoryTemplate(text3, targetId);
		return text3;
	}

	public static string PatchGeneratedTemplateSource(string source, SeaTemplateSpec spec)
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
		if (Count(text, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
		{
			ValidateGeneratedTemplate(text, spec, requirePatched: true);
			return text;
		}
		RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, spec.TargetId + " sea-parity marker");
		ValidateGeneratedTemplate(text, spec, requirePatched: false);
		if (SeaParityManifest.WaterMobileIds.Contains<string>(spec.TargetId))
		{
			ValidateWaterMobileSourceDimensions(text, spec.TargetId);
		}
		StringBuilder stringBuilder = new StringBuilder(text.TrimEnd(Array.Empty<char>()));
		stringBuilder.AppendLine().AppendLine().AppendLine("-- Supreme Commander Overhaul sea parity 1.0.0")
			.Append("-- Pinned FA source route ")
			.Append(spec.TargetId)
			.Append(" <- ")
			.AppendLine(spec.SourceId)
			.AppendLine("UnitTemplate.general = UnitTemplate.general or {}")
			.Append("UnitTemplate.general.tpId = \"")
			.Append(spec.TargetId)
			.AppendLine("\"")
			.AppendLine("UnitTemplate.general.class = {")
			.Append("    \"")
			.Append(spec.ClassModule)
			.AppendLine("\",")
			.Append("    \"")
			.Append(spec.RuntimeClass)
			.AppendLine("\",")
			.AppendLine("}")
			.AppendLine("UnitTemplate.additions = UnitTemplate.additions or {}")
			.AppendLine("UnitTemplate.additions.seaParitySourceContract = {")
			.Append("    sourceId = \"")
			.Append(spec.SourceId)
			.AppendLine("\",")
			.Append("    targetId = \"")
			.Append(spec.TargetId)
			.AppendLine("\",")
			.Append("    sourceArchiveSha256 = \"")
			.Append("C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26")
			.AppendLine("\",")
			.AppendLine("}");
		if (spec.TargetId == "ues1512")
		{
			stringBuilder.AppendLine("UnitTemplate.general.name = \"Air Factory\"").AppendLine("UnitTemplate.general.displayName = \"Tier 1: Air Factory\"");
		}
		if (spec.Kind == SeaTemplateKind.NavalUnit)
		{
			AppendWeaponOriginRepair(stringBuilder, null);
			if (spec.TargetId == "ugn2001")
			{
				AppendSalemAmphibiousContract(stringBuilder);
			}
			AppendGeneratedFeatureGates(stringBuilder, spec.TargetId);
			AppendWaterMobileContract(stringBuilder, spec.TargetId);
		}
		else
		{
			AppendFactoryContract(stringBuilder, spec);
		}
		string text2 = Normalize(stringBuilder.ToString());
		ValidateGeneratedTemplate(text2, spec, requirePatched: true);
		return text2;
	}

	public static string PatchWeaponOriginSource(string source, string targetId, int expectedCombatWeapons)
	{
		if (!SeaParityManifest.ExistingWeaponCounts.TryGetValue(targetId, out var value) || value != expectedCombatWeapons)
		{
			throw new ArgumentOutOfRangeException("targetId");
		}
		string text = Normalize(source);
		if (Count(text, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
		{
			ValidateWeaponOriginPatch(text, targetId, expectedCombatWeapons);
			return text;
		}
		RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, targetId + " sea-parity marker");
		RequireTokens(text, "UnitTemplate", "tpId = \"" + targetId + "\"");
		if (targetId.StartsWith("usn", StringComparison.Ordinal))
		{
			RequireExactly(text, "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0", 1, targetId + " SCOM marker");
		}
		else
		{
			RequireTokens(text, "sourceId =", "targetId = \"" + targetId + "\"");
		}
		if (SeaParityManifest.WaterMobileIds.Contains<string>(targetId))
		{
			ValidateWaterMobileSourceDimensions(text, targetId);
		}
		ValidateSeraphimUnsupportedSourceAnchors(text, targetId);
		ValidateExistingWeaponSemanticSourceAnchors(text, targetId);
		StringBuilder stringBuilder = new StringBuilder(text.TrimEnd(Array.Empty<char>()));
		stringBuilder.AppendLine().AppendLine().AppendLine("-- Supreme Commander Overhaul sea parity 1.0.0")
			.Append("-- Correct shooter-layer limits without changing target or bone contracts for ")
			.AppendLine(targetId);
		AppendWeaponOriginRepair(stringBuilder, expectedCombatWeapons);
		AppendExistingWeaponSemanticCorrections(stringBuilder, targetId);
		if (targetId == "usn1002")
		{
			AppendUsn1002InterceptorGate(stringBuilder);
		}
		else if (targetId == "usn3001")
		{
			AppendUsn3001UnsupportedWeaponGates(stringBuilder);
		}
		AppendSeraphimUnsupportedWeaponGates(stringBuilder, targetId);
		if (targetId == "ucs2803" || targetId == "usn3003")
		{
			AppendCarrierDeckGate(stringBuilder);
		}
		if (targetId == "ucl4003")
		{
			AppendTempestFactoryGate(stringBuilder);
		}
		AppendAeonUnsupportedWeaponGates(stringBuilder, targetId);
		AppendWaterMobileContract(stringBuilder, targetId);
		string text2 = Normalize(stringBuilder.ToString());
		ValidateWeaponOriginPatch(text2, targetId, expectedCombatWeapons);
		return text2;
	}

	public static string PatchTempestGateSource(string source)
	{
		return PatchWeaponOriginSource(source, "ucl4003", 3);
	}

	public static string PatchAeonUnsupportedWeaponSource(string source, string targetId)
	{
		if (targetId != "uca2806")
		{
			throw new ArgumentOutOfRangeException("targetId");
		}
		string text = Normalize(source);
		if (Count(text, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
		{
			ValidateAeonUnsupportedWeaponGate(text, targetId);
			return text;
		}
		RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, targetId + " sea-parity marker");
		RequireTokens(text, "UnitTemplate", "tpId = \"" + targetId + "\"", "sourceId =", "targetId = \"" + targetId + "\"");
		StringBuilder stringBuilder = new StringBuilder(text.TrimEnd(Array.Empty<char>()));
		stringBuilder.AppendLine().AppendLine().AppendLine("-- Supreme Commander Overhaul sea parity 1.0.0")
			.AppendLine("-- Remove source projectile-defense weapons that Sanctuary cannot target safely.");
		AppendAeonUnsupportedWeaponGates(stringBuilder, targetId);
		string text2 = Normalize(stringBuilder.ToString());
		ValidateAeonUnsupportedWeaponGate(text2, targetId);
		return text2;
	}

	public static string PatchHostFactionClassSource(string source, bool eda)
	{
		string text = Normalize(source);
		if (Count(text, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
		{
			text = ApplyHostNavalUsableRolloffPolicy(text);
			ValidateHostFactionClasses(text, eda);
			return text;
		}
		RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, "sea-parity marker");
		RequireExactly(text, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, "FA-air upstream marker");
		string text2 = (eda ? "HostEDANavalFactory" : "HostGuardNavalFactory");
		RequireTokens(text, text2, eda ? "HostEDAFaUefAirFactory" : "HostGuardFaCybranAirFactory");
		string text3 = BuildHostNavalClassAppendix(eda) + (eda ? string.Empty : BuildHostSalemClassAppendix());
		string text4 = ApplyHostNavalUsableRolloffPolicy(text.TrimEnd(Array.Empty<char>()) + text3 + "\n");
		ValidateHostFactionClasses(text4, eda);
		return text4;
	}

	public static string PatchClientFactionClassSource(string source, bool eda)
	{
		string text = Normalize(source);
		if (Count(text, "-- Supreme Commander Overhaul sea parity 1.0.0") == 1)
		{
			ValidateClientFactionClasses(text, eda);
			return text;
		}
		RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, "sea-parity marker");
		RequireExactly(text, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, "FA-air upstream marker");
		string text2 = (eda ? "ClientEDANavalFactory" : "ClientGuardNavalFactory");
		RequireTokens(text, text2, eda ? "ClientEDAFaUefAirFactory" : "ClientGuardFaCybranAirFactory");
		string text3 = BuildClientNavalClassAppendix(eda) + (eda ? string.Empty : BuildClientSalemClassAppendix());
		string text4 = text.TrimEnd(Array.Empty<char>()) + text3 + "\n";
		ValidateClientFactionClasses(text4, eda);
		return text4;
	}

	public static void ValidateGeneratedSources(IReadOnlyDictionary<string, string> sources)
	{
		if (sources == null)
		{
			throw new ArgumentNullException("sources");
		}
		string[] array = SeaParityManifest.GeneratedTemplates.Select((SeaTemplateSpec spec) => spec.TargetId).OrderBy<string, string>((string id) => id, StringComparer.Ordinal).ToArray();
		string[] array2 = sources.Keys.OrderBy<string, string>((string id) => id, StringComparer.Ordinal).ToArray();
		if (!array.SequenceEqual(array2, StringComparer.Ordinal))
		{
			IEnumerable<string> values = array.Except(array2, StringComparer.Ordinal);
			IEnumerable<string> values2 = array2.Except(array, StringComparer.Ordinal);
			throw Incompatible("Generated template manifest mismatch; missing [" + string.Join(", ", values) + "], extra [" + string.Join(", ", values2) + "].");
		}
		foreach (SeaTemplateSpec generatedTemplate in SeaParityManifest.GeneratedTemplates)
		{
			ValidateGeneratedTemplate(sources[generatedTemplate.TargetId], generatedTemplate, requirePatched: false);
		}
	}

	public static void ValidateGeneratedProjectileSources(IReadOnlyDictionary<string, string> sources)
	{
		if (sources == null)
		{
			throw new ArgumentNullException("sources");
		}
		string[] array = SeaParityManifest.GeneratedProjectileIds.OrderBy<string, string>((string id) => id, StringComparer.Ordinal).ToArray();
		string[] array2 = sources.Keys.OrderBy<string, string>((string id) => id, StringComparer.Ordinal).ToArray();
		if (!array.SequenceEqual(array2, StringComparer.Ordinal))
		{
			IEnumerable<string> values = array.Except(array2, StringComparer.Ordinal);
			IEnumerable<string> values2 = array2.Except(array, StringComparer.Ordinal);
			throw Incompatible("Generated projectile manifest mismatch; missing [" + string.Join(", ", values) + "], extra [" + string.Join(", ", values2) + "].");
		}
		foreach (string generatedProjectileId in SeaParityManifest.GeneratedProjectileIds)
		{
			string source = Normalize(sources[generatedProjectileId]);
			RequireExactly(source, "ProjectileTemplate = {", 1, generatedProjectileId + " projectile template root");
			RequireExactly(source, "tpId = \"" + generatedProjectileId + "\"", 1, generatedProjectileId + " projectile ID");
			RequireExactly(source, "movement = {", 0, generatedProjectileId + " non-homing movement contract");
		}
		RequireTokens(Normalize(sources["psu302g"]), "VFX/Impact/vei1301_cannon_large_impact.sanvfx", "VFX/Trails/vet1301_cannon_large_trail.sanvfx");
		RequireTokens(Normalize(sources["psu302a"]), "sanctuary-visibility-fallback=vet1121_autocannon_small_trail; FA TAARailgun02 has no flight trail.", "persistantEffects = {", "VFX/Impact/vei7601_railgun_flak_medium_impact.sanvfx", "VFX/Trails/vet1121_autocannon_small_trail.sanvfx");
	}

	private static string BuildClientPlacementSizingPrelude()
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.AppendLine("local SCOSeaParityHasUsablePreviewRolloff").AppendLine("local function SCOSeaParityWaterCellIsClear(flags)").AppendLine("    local allowed = bit.bor(PlacementLayer.Water, PlacementLayer.InvalidTerrain)")
			.AppendLine("    return bit.band(flags, PlacementLayer.Water) ~= 0")
			.AppendLine("        and bit.band(flags, bit.bnot(allowed)) == 0")
			.AppendLine("end")
			.AppendLine();
		stringBuilder.AppendLine("local SCOSeaParityWaterPlacementIds = {");
		foreach (string waterPlacementId in SeaParityManifest.WaterPlacementIds)
		{
			stringBuilder.Append("    [\"").Append(waterPlacementId).AppendLine("\"] = true,");
		}
		stringBuilder.AppendLine("}").AppendLine("local SCOSeaParityWaterFactoryIds = {");
		foreach (string waterFactoryId in SeaParityManifest.WaterFactoryIds)
		{
			stringBuilder.Append("    [\"").Append(waterFactoryId).AppendLine("\"] = true,");
		}
		stringBuilder.AppendLine("}").AppendLine("local SCOSeaParityWaterMinimumDepth = {");
		foreach (string waterPlacementId2 in SeaParityManifest.WaterPlacementIds)
		{
			string value = ((waterPlacementId2 == "ucl4003" || waterPlacementId2 == "uen4001") ? "0" : "1.5");
			stringBuilder.Append("    [\"").Append(waterPlacementId2).Append("\"] = ")
				.Append(value)
				.AppendLine(",");
		}
		stringBuilder.AppendLine("}").AppendLine("local SCOSeaParityDualLandWaterIds = {").AppendLine("    [\"ucl3701\"] = true,")
			.AppendLine("    [\"uen3005\"] = true,")
			.AppendLine("}")
			.AppendLine()
			.AppendLine("local function SCOSeaParityIsWaterPlacement(tp)")
			.AppendLine("    local id = tp and tp.general and tp.general.tpId")
			.AppendLine("    return id ~= nil")
			.AppendLine("        and SCOSeaParityWaterPlacementIds[id] == true")
			.AppendLine("        and tp.general.requiresWaterPlacement == true")
			.AppendLine("end")
			.AppendLine()
			.AppendLine("local function SCOSeaParityIsWaterFactory(tp)")
			.AppendLine("    local id = tp and tp.general and tp.general.tpId")
			.AppendLine("    return id ~= nil and SCOSeaParityWaterFactoryIds[id] == true")
			.AppendLine("end")
			.AppendLine()
			.AppendLine("local function SCOSeaParityPlacementSize(tp)")
			.AppendLine("    if not tp then return nil end")
			.AppendLine("    if SCOSeaParityIsWaterPlacement(tp) then")
			.AppendLine("        return tp.skirtSize or tp.footprint")
			.AppendLine("    end")
			.AppendLine("    return tp.skirtSize")
			.AppendLine("end")
			.AppendLine()
			.AppendLine("local function SCOSeaParityWaterPlacementState(tp, position)")
			.AppendLine("    if not SCOSeaParityIsWaterPlacement(tp) then return false end")
			.AppendLine("    local id = tp.general.tpId")
			.AppendLine("    if not SCOSeaParityDualLandWaterIds[id] then return true end")
			.AppendLine("    if position == nil then return nil end")
			.AppendLine("    local waterError, hasWater = Engine.HasWater()")
			.AppendLine("    if waterError ~= EngineErrorCode.Success then return nil end")
			.AppendLine("    if not hasWater then return false end")
			.AppendLine("    local levelError, waterLevel = Engine.GetWaterLevel()")
			.AppendLine("    local terrainError, terrainHeight = Engine.SampleTerrainHeight(position)")
			.AppendLine("    local minimumDepth = SCOSeaParityWaterMinimumDepth[id]")
			.AppendLine("    if levelError ~= EngineErrorCode.Success or waterLevel == nil")
			.AppendLine("        or terrainError ~= EngineErrorCode.Success or terrainHeight == nil")
			.AppendLine("        or minimumDepth == nil")
			.AppendLine("    then")
			.AppendLine("        return nil")
			.AppendLine("    end")
			.AppendLine("    return terrainHeight <= waterLevel - minimumDepth")
			.AppendLine("end")
			.AppendLine()
			.AppendLine("local function SCOSeaParityCellIsDeepEnough(tp, cell, waterLevel)")
			.AppendLine("    local id = tp and tp.general and tp.general.tpId")
			.AppendLine("    local minimumDepth = id and SCOSeaParityWaterMinimumDepth[id]")
			.AppendLine("    if minimumDepth == nil then return false end")
			.AppendLine("    local errorCode, terrainHeight = Engine.SampleTerrainHeightFromCell(cell)")
			.AppendLine("    return errorCode == EngineErrorCode.Success")
			.AppendLine("        and terrainHeight <= waterLevel - minimumDepth")
			.AppendLine("end")
			.AppendLine();
		return stringBuilder.ToString();
	}

	private static void AppendFactoryContract(StringBuilder builder, SeaTemplateSpec spec)
	{
		string value = "BUILDABLE_BY_T" + spec.Tier + "_FACTORY";
		string text = ((spec.Kind == SeaTemplateKind.AirFactory) ? "AIR" : "NAVAL");
		string value2 = text + "_FACTORY";
		builder.AppendLine("UnitTemplate.construction = UnitTemplate.construction or {}").Append("UnitTemplate.construction.canBuild = \"Tags.").Append(spec.FactionTag)
			.Append(" * Tags.")
			.Append(value)
			.Append(" * ((Tags.")
			.Append(text)
			.Append(" * Tags.MOBILE) + Tags.")
			.Append(value2)
			.AppendLine(")\"")
			.Append("UnitTemplate.construction.platformBoneName = \"")
			.Append(spec.PlatformBone)
			.AppendLine("\"")
			.AppendLine("UnitTemplate.additions.buildBeamBones = {");
		foreach (string buildBone in spec.BuildBones)
		{
			builder.Append("    \"").Append(buildBone).AppendLine("\",");
		}
		builder.AppendLine("}").AppendLine("UnitTemplate.additions.faAirFactoryLifecycle = UnitTemplate.additions.faAirFactoryLifecycle or {}").Append("UnitTemplate.additions.faAirFactoryLifecycle.platformBoneName = \"")
			.Append(spec.PlatformBone)
			.AppendLine("\"")
			.AppendLine("local SCOSeaParityBuildAnimation = UnitTemplate.visuals")
			.AppendLine("    and UnitTemplate.visuals.animations")
			.AppendLine("    and UnitTemplate.visuals.animations.build");
		if (ProgressBoundFactoryUpgradeDurations.TryGetValue(spec.TargetId, out var value3))
		{
			builder.AppendLine("UnitTemplate.additions.progressBoundUpgradeAnimation = {").AppendLine("    animationKey = \"upgrade\",").Append("    durationSeconds = ")
				.Append(StableLuaNumber.Format(ref value3, "R", CultureInfo.InvariantCulture))
				.AppendLine(",")
				.AppendLine("    restAnimationKey = \"walk\",")
				.AppendLine("}");
		}
		builder.AppendLine("if not SCOSeaParityBuildAnimation").AppendLine("    or not SCOSeaParityBuildAnimation.clipName").AppendLine("    or not SCOSeaParityBuildAnimation.sanAnimationPath")
			.AppendLine("    or type(UnitTemplate.additions.faAirFactoryLifecycle.buildDurationSeconds) ~= \"number\"")
			.AppendLine("    or UnitTemplate.additions.faAirFactoryLifecycle.buildDurationSeconds <= 0")
			.AppendLine("then")
			.Append("    error(\"Generated FA factory lacks a playable build animation: ")
			.Append(spec.TargetId)
			.AppendLine("\")")
			.AppendLine("end");
		if (spec.UpgradeTo == null)
		{
			builder.AppendLine("UnitTemplate.construction.upgradesTo = nil");
		}
		else
		{
			builder.Append("UnitTemplate.construction.upgradesTo = \"").Append(spec.UpgradeTo).AppendLine("\"");
		}
		if (spec.Kind == SeaTemplateKind.NavalFactory)
		{
			builder.AppendLine("UnitTemplate.general.requiresWaterPlacement = true").AppendLine("if not UnitTemplate.construction.rollOffPoints").AppendLine("    or #UnitTemplate.construction.rollOffPoints ~= 2")
				.AppendLine("then")
				.Append("    error(\"Generated naval factory requires exactly two FA rolloff routes: ")
				.Append(spec.TargetId)
				.AppendLine("\")")
				.AppendLine("end");
		}
		else
		{
			builder.AppendLine("UnitTemplate.general.requiresWaterPlacement = nil");
		}
	}

	private static void AppendWeaponOriginRepair(StringBuilder builder, int? expectedCombatWeapons)
	{
		builder.AppendLine("do").AppendLine("    local weapons = UnitTemplate.weapons or {}").AppendLine("    local combatCount = 0")
			.AppendLine("    local originLayers = { \"WaterSurface\" }")
			.AppendLine("    if UnitTemplate.movement and UnitTemplate.movement.type == \"UnderWater\" then")
			.AppendLine("        originLayers = { \"Water\", \"WaterSurface\" }")
			.AppendLine("    end")
			.AppendLine("    for _, weapon in ipairs(weapons) do")
			.AppendLine("        if weapon.category ~= \"DeathExplosion\" then")
			.AppendLine("            combatCount = combatCount + 1")
			.AppendLine("        end")
			.AppendLine("    end");
		if (expectedCombatWeapons.HasValue)
		{
			builder.Append("    if combatCount ~= ").Append(expectedCombatWeapons.Value).AppendLine(" then")
				.AppendLine("        error(\"Sea-parity weapon-table anchor drifted.\")")
				.AppendLine("    end");
		}
		builder.AppendLine("    for _, weapon in ipairs(weapons) do").AppendLine("        if weapon.category ~= \"DeathExplosion\" then").AppendLine("            local controllers = weapon.aimControllers")
			.AppendLine("            if not controllers or #controllers == 0 then")
			.AppendLine("                error(\"Sea-parity combat weapon has no aim controller.\")")
			.AppendLine("            end")
			.AppendLine("            local controllerByAimBone = {}")
			.AppendLine("            local yawControllerCount = 0")
			.AppendLine("            for _, controller in ipairs(controllers) do")
			.AppendLine("                if controller.yawBone ~= nil then")
			.AppendLine("                    if type(controller.yawBone) ~= \"string\"")
			.AppendLine("                        or type(controller.yawMin) ~= \"number\"")
			.AppendLine("                        or type(controller.yawMax) ~= \"number\"")
			.AppendLine("                        or controller.yawMin < -180")
			.AppendLine("                        or controller.yawMin > controller.yawMax")
			.AppendLine("                        or controller.yawMax > 180")
			.AppendLine("                    then")
			.AppendLine("                        error(\"Sea-parity aim-controller yaw bounds are invalid.\")")
			.AppendLine("                    end")
			.AppendLine("                    yawControllerCount = yawControllerCount + 1")
			.AppendLine("                elseif controller.yawMin ~= nil or controller.yawMax ~= nil then")
			.AppendLine("                    error(\"Sea-parity pitch-only controller owns yaw bounds.\")")
			.AppendLine("                end")
			.AppendLine("                if type(controller.aimBone) ~= \"string\"")
			.AppendLine("                    or controllerByAimBone[controller.aimBone]")
			.AppendLine("                then")
			.AppendLine("                    error(\"Sea-parity aim-controller key is absent or duplicated.\")")
			.AppendLine("                end")
			.AppendLine("                controllerByAimBone[controller.aimBone] = true")
			.AppendLine("            end")
			.AppendLine("            if yawControllerCount == 0 then")
			.AppendLine("                error(\"Sea-parity combat weapon has no yaw controller.\")")
			.AppendLine("            end")
			.AppendLine("            if type(weapon.muzzles) ~= \"table\" then")
			.AppendLine("                error(\"Sea-parity combat weapon has no muzzle map.\")")
			.AppendLine("            end")
			.AppendLine("            for _, muzzle in pairs(weapon.muzzles) do")
			.AppendLine("                if type(muzzle) ~= \"table\"")
			.AppendLine("                    or not controllerByAimBone[muzzle.aimController]")
			.AppendLine("                then")
			.AppendLine("                    error(\"Sea-parity muzzle references an unresolved aim controller.\")")
			.AppendLine("                end")
			.AppendLine("            end")
			.AppendLine("            local limits = weapon.layerWeaponLimits")
			.AppendLine("            local mismatch = not limits or #limits ~= #originLayers")
			.AppendLine("            if not mismatch then")
			.AppendLine("                for index, layer in ipairs(originLayers) do")
			.AppendLine("                    if limits[index] ~= layer then mismatch = true break end")
			.AppendLine("                end")
			.AppendLine("            end")
			.AppendLine("            if mismatch then weapon.layerWeaponLimits = originLayers end");
		if (expectedCombatWeapons.HasValue)
		{
			builder.AppendLine("            local targetsLand = false").AppendLine("            for _, targetLayer in ipairs(weapon.layerTargetLimits or {}) do").AppendLine("                if targetLayer == \"Land\" then targetsLand = true break end")
				.AppendLine("            end")
				.AppendLine("            local ring = weapon.rangeRingType")
				.AppendLine("            if weapon.targetWaterLimits == \"Above\"")
				.AppendLine("                and targetsLand")
				.AppendLine("                and (ring == \"DirectFire\" or ring == \"IndirectFire\")")
				.AppendLine("            then")
				.AppendLine("                weapon.scoSeaParityTargetGate = \"TargetAbove\"")
				.AppendLine("            else")
				.AppendLine("                weapon.scoSeaParityTargetGate = nil")
				.AppendLine("            end");
		}
		builder.AppendLine("        end").AppendLine("    end").AppendLine("end");
	}

	private static void AppendGeneratedFeatureGates(StringBuilder builder, string targetId)
	{
		if (!(targetId != "uen3004") || !(targetId != "ugn3003") || !(targetId != "ugn3004"))
		{
			builder.AppendLine("UnitTemplate.additions.seaParityUnsupported = UnitTemplate.additions.seaParityUnsupported or {}");
			if (targetId == "uen3004" || targetId == "ugn3004")
			{
				builder.AppendLine("UnitTemplate.additions.seaParityUnsupported.nukeSilo = true");
				return;
			}
			builder.AppendLine("UnitTemplate.construction = UnitTemplate.construction or {}");
			builder.AppendLine("UnitTemplate.construction.canBuild = nil");
			builder.AppendLine("UnitTemplate.additions.seaParityUnsupported.carrierDeck = true");
		}
	}

	private static void AppendWaterMobileContract(StringBuilder builder, string targetId)
	{
		if (SeaParityManifest.WaterMobileIds.Contains<string>(targetId))
		{
			int value = ((targetId == "uen4001") ? 6 : ((targetId == "ucl4003") ? 16 : 2));
			int value2 = ((targetId == "uen4001") ? 22 : ((targetId == "ucl4003") ? 16 : 2));
			string value3 = ((targetId == "uen4001" || targetId == "ucl4003") ? "0" : "1.5");
			bool flag = targetId == "uen3005" || targetId == "ucl3701";
			builder.AppendLine("UnitTemplate.general = UnitTemplate.general or {}").AppendLine("UnitTemplate.general.requiresWaterPlacement = true").AppendLine("if not UnitTemplate.footprint")
				.Append("    or UnitTemplate.footprint.x ~= ")
				.Append(value)
				.AppendLine()
				.Append("    or UnitTemplate.footprint.y ~= ")
				.Append(value2)
				.AppendLine()
				.AppendLine("then")
				.Append("    error(\"Water-built mobile footprint drifted: ")
				.Append(targetId)
				.AppendLine("\")")
				.AppendLine("end")
				.AppendLine("UnitTemplate.additions = UnitTemplate.additions or {}")
				.Append("UnitTemplate.additions.scoSeaParityMinimumWaterDepth = ")
				.AppendLine(value3)
				.Append("UnitTemplate.additions.scoSeaParityPlacementMode = \"")
				.Append(flag ? "LandOrWater" : "WaterOnly")
				.AppendLine("\"")
				.AppendLine("-- Keep completed mobiles out of structure navigation/grid modifiers.")
				.AppendLine("UnitTemplate.skirtSize = nil");
		}
	}

	private static void ValidateWaterMobileSourceDimensions(string source, string targetId)
	{
		if (!SeaParityManifest.WaterMobileIds.Contains<string>(targetId))
		{
			throw new ArgumentOutOfRangeException("targetId");
		}
		int num = ((targetId == "uen4001") ? 6 : ((targetId == "ucl4003") ? 16 : 2));
		int num2 = ((targetId == "uen4001") ? 22 : ((targetId == "ucl4003") ? 16 : 2));
		string token = "UnitTemplate.footprint = {\n    x = " + num + ",\n    y = " + num2 + ",\n}";
		string token2 = "footprint = { x = " + num + ", y = " + num2 + " }";
		int num3 = Count(source, token);
		int num4 = Count(source, token2);
		if (num3 + num4 != 1)
		{
			throw Incompatible(targetId + " placement footprint source anchor drifted.");
		}
		if (targetId == "ucl4003")
		{
			RequireExactly(source, "UnitTemplate.skirtSize = {\n    x = 16,\n    y = 16,\n}", 1, "ucl4003 source skirt");
			RequireTokens(source, "footprintSource = \"Physics.SkirtSizeFallback\"", "sourceSkirtPresent = true");
		}
	}

	private static void AppendAeonUnsupportedWeaponGates(StringBuilder builder, string targetId)
	{
		if (!SeaParityManifest.UnsupportedAeonWeaponLabels.TryGetValue(targetId, out IReadOnlyList<string> value))
		{
			return;
		}
		builder.AppendLine("do").AppendLine("    local unsupported = {");
		foreach (string item in value)
		{
			builder.Append("        [\"").Append(item).AppendLine("\"] = true,");
		}
		builder.AppendLine("    }").AppendLine("    local removed = {}").AppendLine("    local removedCount = 0")
			.AppendLine("    local retained = {}")
			.AppendLine("    for _, weapon in ipairs(UnitTemplate.weapons or {}) do")
			.AppendLine("        local label = weapon.scoSourceLabel")
			.AppendLine("        if label and unsupported[label] then")
			.AppendLine("            if removed[label] then")
			.AppendLine("                error(\"Duplicate unsupported Aeon weapon label: \" .. label)")
			.AppendLine("            end")
			.AppendLine("            removed[label] = true")
			.AppendLine("            removedCount = removedCount + 1")
			.AppendLine("        else")
			.AppendLine("            table.insert(retained, weapon)")
			.AppendLine("        end")
			.AppendLine("    end")
			.Append("    if removedCount ~= ")
			.Append(value.Count)
			.AppendLine(" then")
			.Append("        error(\"Unsupported Aeon weapon count drifted: ")
			.Append(targetId)
			.AppendLine("\")")
			.AppendLine("    end");
		foreach (string item2 in value)
		{
			builder.Append("    if not removed[\"").Append(item2).AppendLine("\"] then")
				.Append("        error(\"Unsupported Aeon weapon label drifted: ")
				.Append(targetId)
				.Append('/')
				.Append(item2)
				.AppendLine("\")")
				.AppendLine("    end");
		}
		builder.AppendLine("    UnitTemplate.weapons = retained").AppendLine("    UnitTemplate.additions = UnitTemplate.additions or {}").AppendLine("    UnitTemplate.additions.seaParityUnsupported = UnitTemplate.additions.seaParityUnsupported or {}");
		if (targetId == "ucl4001")
		{
			builder.AppendLine("    UnitTemplate.additions.seaParityUnsupported.nukeSilo = true");
		}
		else
		{
			builder.AppendLine("    UnitTemplate.additions.seaParityUnsupported.projectileInterception = true");
		}
		builder.AppendLine("end");
	}

	private static void AppendCarrierDeckGate(StringBuilder builder)
	{
		builder.AppendLine("UnitTemplate.construction = UnitTemplate.construction or {}").AppendLine("UnitTemplate.construction.canBuild = nil").AppendLine("UnitTemplate.additions = UnitTemplate.additions or {}")
			.AppendLine("UnitTemplate.additions.seaParityUnsupported = UnitTemplate.additions.seaParityUnsupported or {}")
			.AppendLine("UnitTemplate.additions.seaParityUnsupported.carrierDeck = true");
	}

	private static void AppendTempestFactoryGate(StringBuilder builder)
	{
		builder.AppendLine("-- Tempest remains a static compatibility finding: Sanctuary has no safe moving-factory product lifecycle.").AppendLine("UnitTemplate.construction = UnitTemplate.construction or {}").AppendLine("UnitTemplate.construction.canBuild = nil")
			.AppendLine("UnitTemplate.additions = UnitTemplate.additions or {}")
			.AppendLine("UnitTemplate.additions.seaParityUnsupported = UnitTemplate.additions.seaParityUnsupported or {}")
			.AppendLine("UnitTemplate.additions.seaParityUnsupported.movingNavalFactory = true");
	}

	private static void ValidateExistingWeaponSemanticSourceAnchors(string source, string targetId)
	{
		ExistingWeaponSemanticSpec[] array = ExistingWeaponSemantics.Corrections.Where((ExistingWeaponSemanticSpec spec) => spec.TargetId == targetId).ToArray();
		if (array.Length == 0)
		{
			return;
		}
		string[] array2 = array.Select((ExistingWeaponSemanticSpec spec) => spec.SourceId).Distinct<string>(StringComparer.Ordinal).ToArray();
		if (array2.Length != 1)
		{
			throw Incompatible(targetId + " correction source IDs disagree.");
		}
		RequireTokens(source, "tpId = \"" + targetId + "\"");
		if (targetId.StartsWith("usn", StringComparison.Ordinal))
		{
			RequireTokens(source, array2[0], "-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0");
		}
		else
		{
			RequireTokens(source, "sourceId = \"" + array2[0] + "\"");
		}
		int[] array3 = array.Select((ExistingWeaponSemanticSpec spec) => spec.UpstreamCombatIndex).ToArray();
		if (array3.Distinct().Count() != array3.Length)
		{
			throw Incompatible(targetId + " correction combat indices are duplicated.");
		}
		ExistingWeaponSemanticSpec[] array4 = array;
		foreach (ExistingWeaponSemanticSpec existingWeaponSemanticSpec in array4)
		{
			RequireTokens(source, "\"" + existingWeaponSemanticSpec.AimBone + "\"", "\"" + existingWeaponSemanticSpec.YawBone + "\"", "\"" + existingWeaponSemanticSpec.PitchBone + "\"");
			foreach (IReadOnlyList<string> muzzleGroup in existingWeaponSemanticSpec.MuzzleGroups)
			{
				foreach (string item in muzzleGroup)
				{
					RequireTokens(source, "\"" + item + "\"");
				}
			}
		}
	}

	private static void AppendExistingWeaponSemanticCorrections(StringBuilder builder, string targetId)
	{
		ExistingWeaponSemanticSpec[] array = (from spec in ExistingWeaponSemantics.Corrections
			where spec.TargetId == targetId
			orderby spec.UpstreamCombatIndex
			select spec).ToArray();
		if (array.Length == 0)
		{
			return;
		}
		builder.AppendLine("do").AppendLine("    local corrections = {");
		ExistingWeaponSemanticSpec[] array2 = array;
		foreach (ExistingWeaponSemanticSpec existingWeaponSemanticSpec in array2)
		{
			StringBuilder stringBuilder = builder.Append("        { sourceLabel = \"").Append(existingWeaponSemanticSpec.SourceWeaponLabel).Append("\", combatIndex = ")
				.Append(existingWeaponSemanticSpec.UpstreamCombatIndex)
				.Append(", aim = \"")
				.Append(existingWeaponSemanticSpec.AimBone)
				.Append("\", yaw = \"")
				.Append(existingWeaponSemanticSpec.YawBone)
				.Append("\", pitch = \"")
				.Append(existingWeaponSemanticSpec.PitchBone)
				.Append("\", muzzleSalvoSize = ")
				.Append(existingWeaponSemanticSpec.MuzzleSalvoSize)
				.Append(", muzzleSalvoDelay = ");
			double value = existingWeaponSemanticSpec.MuzzleSalvoDelay;
			stringBuilder.Append(StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture)).Append(", groups = {\n");
			foreach (IReadOnlyList<string> muzzleGroup in existingWeaponSemanticSpec.MuzzleGroups)
			{
				builder.Append("            {");
				foreach (string item in muzzleGroup)
				{
					builder.Append(" \"").Append(item).Append("\",");
				}
				builder.AppendLine(" },");
			}
			builder.AppendLine("        } },");
		}
		builder.AppendLine("    }").AppendLine("    local combatWeapons = {}").AppendLine("    for _, weapon in ipairs(UnitTemplate.weapons or {}) do")
			.AppendLine("        if weapon.category ~= \"DeathExplosion\" then")
			.AppendLine("            table.insert(combatWeapons, weapon)")
			.AppendLine("        end")
			.AppendLine("    end")
			.AppendLine("    local correctedLabels = {}")
			.AppendLine("    for _, correction in ipairs(corrections) do")
			.AppendLine("        local weapon = combatWeapons[correction.combatIndex]")
			.AppendLine("        local controllers = weapon and weapon.aimControllers")
			.AppendLine("        local controller = controllers and controllers[1]")
			.AppendLine("        if not weapon or not controllers or #controllers ~= 1")
			.AppendLine("            or not controller")
			.AppendLine("            or controller.aimBone ~= correction.aim")
			.AppendLine("            or controller.yawBone ~= correction.yaw")
			.AppendLine("            or controller.pitchBone ~= correction.pitch")
			.AppendLine("            or correctedLabels[correction.sourceLabel]")
			.AppendLine("            or (weapon.scoSourceLabel ~= nil")
			.AppendLine("                and weapon.scoSourceLabel ~= correction.sourceLabel)")
			.AppendLine("        then")
			.AppendLine("            error(\"Supported source weapon anchor drifted: \" .. correction.sourceLabel)")
			.AppendLine("        end")
			.AppendLine("        local expectedMuzzles = {}")
			.AppendLine("        local expectedMuzzleCount = 0")
			.AppendLine("        for _, group in ipairs(correction.groups) do")
			.AppendLine("            for _, muzzleBone in ipairs(group) do")
			.AppendLine("                if not expectedMuzzles[muzzleBone] then")
			.AppendLine("                    expectedMuzzles[muzzleBone] = true")
			.AppendLine("                    expectedMuzzleCount = expectedMuzzleCount + 1")
			.AppendLine("                end")
			.AppendLine("            end")
			.AppendLine("        end")
			.AppendLine("        local actualMuzzleCount = 0")
			.AppendLine("        for muzzleBone, muzzle in pairs(weapon.muzzles or {}) do")
			.AppendLine("            if not expectedMuzzles[muzzleBone]")
			.AppendLine("                or type(muzzle) ~= \"table\"")
			.AppendLine("                or muzzle.aimController ~= correction.aim")
			.AppendLine("            then")
			.AppendLine("                error(\"Supported source weapon muzzle map drifted: \" .. correction.sourceLabel)")
			.AppendLine("            end")
			.AppendLine("            actualMuzzleCount = actualMuzzleCount + 1")
			.AppendLine("        end")
			.AppendLine("        if actualMuzzleCount ~= expectedMuzzleCount then")
			.AppendLine("            error(\"Supported source weapon muzzle count drifted: \" .. correction.sourceLabel)")
			.AppendLine("        end")
			.AppendLine("        weapon.muzzleGroups = {}")
			.AppendLine("        for _, group in ipairs(correction.groups) do")
			.AppendLine("            table.insert(weapon.muzzleGroups, { muzzles = group })")
			.AppendLine("        end")
			.AppendLine("        weapon.muzzleSalvoSize = correction.muzzleSalvoSize")
			.AppendLine("        weapon.muzzleSalvoDelay = correction.muzzleSalvoDelay")
			.AppendLine("        weapon.scoSourceLabel = correction.sourceLabel")
			.AppendLine("        correctedLabels[correction.sourceLabel] = true")
			.AppendLine("    end")
			.Append("    if #corrections ~= ")
			.Append(array.Length)
			.AppendLine(" then")
			.Append("        error(\"Supported source-weapon correction count drifted: ")
			.Append(targetId)
			.AppendLine("\")")
			.AppendLine("    end")
			.AppendLine("    UnitTemplate.additions = UnitTemplate.additions or {}")
			.AppendLine("    UnitTemplate.additions.seaParityWeaponSemantics = correctedLabels")
			.AppendLine("end");
	}

	private static void AppendUsn1002InterceptorGate(StringBuilder builder)
	{
		builder.AppendLine("do").AppendLine("    local gated = 0").AppendLine("    for index = #UnitTemplate.weapons, 1, -1 do")
			.AppendLine("        local weapon = UnitTemplate.weapons[index]")
			.AppendLine("        local aim = weapon.aimControllers and weapon.aimControllers[1]")
			.AppendLine("        if aim and aim.aimBone == \"AntiTorpedo\"")
			.AppendLine("            and weapon.projectileTemplate == \"pca111\"")
			.AppendLine("            and weapon.rangeMax == 32")
			.AppendLine("        then")
			.AppendLine("            table.remove(UnitTemplate.weapons, index)")
			.AppendLine("            gated = gated + 1")
			.AppendLine("        end")
			.AppendLine("    end")
			.AppendLine("    if gated ~= 1 then error(\"usn1002 anti-torpedo gate anchor drifted.\") end")
			.AppendLine("    UnitTemplate.additions = UnitTemplate.additions or {}")
			.AppendLine("    UnitTemplate.additions.seaParityUnsupported = UnitTemplate.additions.seaParityUnsupported or {}")
			.AppendLine("    UnitTemplate.additions.seaParityUnsupported.projectileInterception = true")
			.AppendLine("end");
	}

	private static void AppendUsn3001UnsupportedWeaponGates(StringBuilder builder)
	{
		builder.AppendLine("do").AppendLine("    local gatedNuke = 0").AppendLine("    local gatedDefense = 0")
			.AppendLine("    for index = #UnitTemplate.weapons, 1, -1 do")
			.AppendLine("        local weapon = UnitTemplate.weapons[index]")
			.AppendLine("        local aim = weapon.aimControllers and weapon.aimControllers[1]")
			.AppendLine("        if aim and aim.aimBone == \"Projectile01\"")
			.AppendLine("            and weapon.projectileTemplate == \"pci211\"")
			.AppendLine("            and weapon.rangeMin == 128 and weapon.rangeMax == 1024")
			.AppendLine("        then")
			.AppendLine("            table.remove(UnitTemplate.weapons, index)")
			.AppendLine("            gatedNuke = gatedNuke + 1")
			.AppendLine("        elseif aim and weapon.projectileTemplate == \"pca111\"")
			.AppendLine("            and ((aim.yawBone == \"Left_Turret01\" and aim.aimBone == \"Left_Turret_Muzzle01\")")
			.AppendLine("                or (aim.yawBone == \"Right_Turret02\" and aim.aimBone == \"Right_Turret_Muzzle03\"))")
			.AppendLine("        then")
			.AppendLine("            table.remove(UnitTemplate.weapons, index)")
			.AppendLine("            gatedDefense = gatedDefense + 1")
			.AppendLine("        end")
			.AppendLine("    end")
			.AppendLine("    if gatedNuke ~= 1 or gatedDefense ~= 2 then")
			.AppendLine("        error(\"usn3001 unsupported-weapon gate anchors drifted.\")")
			.AppendLine("    end")
			.AppendLine("    UnitTemplate.additions = UnitTemplate.additions or {}")
			.AppendLine("    UnitTemplate.additions.seaParityUnsupported = UnitTemplate.additions.seaParityUnsupported or {}")
			.AppendLine("    UnitTemplate.additions.seaParityUnsupported.nukeSilo = true")
			.AppendLine("    UnitTemplate.additions.seaParityUnsupported.projectileInterception = true")
			.AppendLine("end");
	}

	private static void ValidateSeraphimUnsupportedSourceAnchors(string source, string targetId)
	{
		if (SeaParityManifest.UnsupportedSeraphimWeaponLabels.ContainsKey(targetId))
		{
			if (targetId == "usn2001")
			{
				RequireExactly(source, "{ aim = \"Projectile02\", yaw = \"Projectile02\", pitch = \"Projectile02\", muzzles = { \"Projectile02\" }, projectile = \"pca111\", rangeRingType = \"AntiAir\"", 1, "usn2001/AntiTorpedo source rig");
				return;
			}
			if (targetId == "usn2002")
			{
				RequireExactly(source, "{ aim = \"Front_Turret01_Muzzle\", yaw = \"Front_Turret01\", pitch = \"Front_Turret01_Barrel\", muzzles = { \"Front_Turret01_Muzzle\" }, projectile = \"pca111\", rangeRingType = \"AntiAir\"", 1, "usn2002/AntiMissile source rig");
				return;
			}
			RequireExactly(source, "{ aim = \"Left_Turret_Muzzle\", yaw = \"Left_Turret_Barrel\", pitch = \"Left_Turret_Barrel\", muzzles = { \"Left_Turret_Muzzle\" }, projectile = \"pca111\", rangeRingType = \"AntiAir\"", 1, "usn3004/AntiTorpedoLeft source rig");
			RequireExactly(source, "{ aim = \"Right_Turret_Muzzle\", yaw = \"Right_Turret_Barrel\", pitch = \"Right_Turret_Barrel\", muzzles = { \"Right_Turret_Muzzle\" }, projectile = \"pca111\", rangeRingType = \"AntiAir\"", 1, "usn3004/AntiTorpedoRight source rig");
		}
	}

	private static void AppendSeraphimUnsupportedWeaponGates(StringBuilder builder, string targetId)
	{
		if (!SeaParityManifest.UnsupportedSeraphimWeaponLabels.TryGetValue(targetId, out IReadOnlyList<string> value))
		{
			return;
		}
		builder.AppendLine("do").AppendLine("    local gates = {");
		if (targetId == "usn2001")
		{
			builder.AppendLine("        { index = 4, label = \"AntiTorpedo\", aim = \"Projectile02\", projectile = \"pca111\", rangeMax = 45, damage = 2, reloadTime = 3.84615384615385 },");
		}
		else if (targetId == "usn2002")
		{
			builder.AppendLine("        { index = 4, label = \"AntiMissile\", aim = \"Front_Turret01_Muzzle\", projectile = \"pca111\", rangeMax = 50, damage = 1, reloadTime = 2 },");
		}
		else
		{
			builder.AppendLine("        { index = 3, label = \"AntiTorpedoRight\", aim = \"Right_Turret_Muzzle\", projectile = \"pca111\", rangeMax = 32, damage = 2, reloadTime = 6.66666666666667 },").AppendLine("        { index = 2, label = \"AntiTorpedoLeft\", aim = \"Left_Turret_Muzzle\", projectile = \"pca111\", rangeMax = 32, damage = 2, reloadTime = 6.66666666666667 },");
		}
		builder.AppendLine("    }").AppendLine("    local removed = {}").AppendLine("    local removedCount = 0")
			.AppendLine("    for _, gate in ipairs(gates) do")
			.AppendLine("        local weapon = UnitTemplate.weapons[gate.index]")
			.AppendLine("        local aim = weapon and weapon.aimControllers")
			.AppendLine("            and weapon.aimControllers[1]")
			.AppendLine("        local muzzle = weapon and weapon.muzzles")
			.AppendLine("            and weapon.muzzles[gate.aim]")
			.AppendLine("        if not weapon or not aim or not muzzle")
			.AppendLine("            or aim.aimBone ~= gate.aim")
			.AppendLine("            or muzzle.aimController ~= gate.aim")
			.AppendLine("            or weapon.projectileTemplate ~= gate.projectile")
			.AppendLine("            or weapon.rangeRingType ~= \"AntiAir\"")
			.AppendLine("            or weapon.rangeMax ~= gate.rangeMax")
			.AppendLine("            or weapon.damage ~= gate.damage")
			.AppendLine("            or weapon.reloadTime ~= gate.reloadTime")
			.AppendLine("            or not weapon.layerTargetLimits")
			.AppendLine("            or #weapon.layerTargetLimits ~= 1")
			.AppendLine("            or weapon.layerTargetLimits[1] ~= \"Air\"")
			.AppendLine("            or removed[gate.label]")
			.AppendLine("        then")
			.AppendLine("            error(\"Unsupported Seraphim source weapon drifted: \" .. gate.label)")
			.AppendLine("        end")
			.AppendLine("        table.remove(UnitTemplate.weapons, gate.index)")
			.AppendLine("        removed[gate.label] = true")
			.AppendLine("        removedCount = removedCount + 1")
			.AppendLine("    end")
			.Append("    if removedCount ~= ")
			.Append(value.Count)
			.AppendLine(" then")
			.Append("        error(\"Unsupported Seraphim source-weapon count drifted: ")
			.Append(targetId)
			.AppendLine("\")")
			.AppendLine("    end");
		foreach (string item in value)
		{
			builder.Append("    if not removed[\"").Append(item).AppendLine("\"] then")
				.Append("        error(\"Unsupported Seraphim source label drifted: ")
				.Append(targetId)
				.Append('/')
				.Append(item)
				.AppendLine("\")")
				.AppendLine("    end");
		}
		builder.AppendLine("    UnitTemplate.additions = UnitTemplate.additions or {}").AppendLine("    UnitTemplate.additions.seaParityUnsupported = UnitTemplate.additions.seaParityUnsupported or {}").AppendLine("    UnitTemplate.additions.seaParityUnsupported.projectileInterception = true")
			.AppendLine("    UnitTemplate.additions.seaParityUnsupported.sourceWeaponLabels = removed")
			.AppendLine("end");
	}

	private static void ValidateGeneratedTemplate(string source, SeaTemplateSpec spec, bool requirePatched)
	{
		string text = Normalize(source);
		RequireExactly(text, "UnitTemplate =", 1, spec.TargetId + " UnitTemplate root");
		RequireExactly(text, "tpId = \"" + spec.TargetId + "\"", (!requirePatched) ? 1 : 2, spec.TargetId + " target ID");
		RequireExactly(text, "sourceId = \"" + spec.SourceId + "\"", (!requirePatched) ? 1 : 2, spec.TargetId + " source mapping");
		RequireExactly(text, "DEMO_UI_ONLY", 0, spec.TargetId + " demo gate");
		RequireTokens(text, "\"" + spec.FactionTag + "\"", "TECH" + spec.Tier);
		if (spec.Kind == SeaTemplateKind.NavalUnit)
		{
			RequireTokens(text, "NAVAL", "MOBILE", "BUILDABLE_BY_T");
		}
		else
		{
			RequireTokens(text, "FACTORY", (spec.Kind == SeaTemplateKind.NavalFactory) ? "NAVAL" : "AIR", "platformBoneName = \"" + spec.PlatformBone + "\"", "faAirFactoryLifecycle", "animations", "build", "targetFacing = \"South\"", "basisYawDegrees = 180");
			foreach (string buildBone in spec.BuildBones)
			{
				RequireTokens(text, "\"" + buildBone + "\"");
			}
			RequireExactly(text, "unitSpin =", 2, spec.TargetId + " rolloff route spins");
		}
		if (requirePatched)
		{
			RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, spec.TargetId + " marker");
			RequireTokens(text, "UnitTemplate.general.class = {", "\"" + spec.ClassModule + "\"", "\"" + spec.RuntimeClass + "\"", "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26");
			if (spec.Kind == SeaTemplateKind.NavalFactory)
			{
				RequireTokens(text, "UnitTemplate.general.requiresWaterPlacement = true", "#UnitTemplate.construction.rollOffPoints ~= 2");
			}
			else if (spec.Kind == SeaTemplateKind.AirFactory)
			{
				RequireTokens(text, "UnitTemplate.general.requiresWaterPlacement = nil");
			}
			if (SeaParityManifest.WaterMobileIds.Contains<string>(spec.TargetId))
			{
				RequireTokens(text, "UnitTemplate.general.requiresWaterPlacement = true", "UnitTemplate.skirtSize = nil", "Water-built mobile footprint drifted: " + spec.TargetId, "scoSeaParityMinimumWaterDepth", "scoSeaParityPlacementMode");
			}
			if (spec.Kind == SeaTemplateKind.NavalUnit)
			{
				string source2 = text.Substring(text.LastIndexOf("-- Supreme Commander Overhaul sea parity 1.0.0", StringComparison.Ordinal));
				RequireTokens(source2, "weapon.layerWeaponLimits = originLayers");
				RequireExactly(source2, "weapon.scoSeaParityTargetGate", 0, spec.TargetId + " generated target-gate mutation");
				if (spec.TargetId == "ugn2001")
				{
					ValidateSalemGeneratedContract(source2);
				}
			}
		}
		else
		{
			RequireExactly(text, "-- Supreme Commander Overhaul sea parity 1.0.0", 0, spec.TargetId + " marker");
		}
		if (ProgressBoundFactoryUpgradeDurations.TryGetValue(spec.TargetId, out var value))
		{
			int expected = (requirePatched ? 1 : 0);
			RequireExactly(text, "progressBoundUpgradeAnimation = {", expected, spec.TargetId + " progress-owned upgrade binding");
			RequireExactly(text, "animationKey = \"upgrade\"", expected, spec.TargetId + " progress-owned upgrade key");
			RequireExactly(text, "durationSeconds = " + StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture), expected, spec.TargetId + " progress-owned upgrade duration");
			RequireExactly(text, "restAnimationKey = \"walk\"", expected, spec.TargetId + " progress-owned upgrade rest key");
			RequireTokens(text, "clipName = \"AnimUpgrade\"");
		}
		ValidateGeneratedUnsupportedContracts(text, spec.TargetId);
	}

	private static void ValidateSalemGeneratedContract(string source)
	{
		RequireTokens(source, "movement.type = \"TracksAmphibious\"", "movement.collisionMaskDefault = { \"Sea\", \"LandSmall\" }", "movement.collisionMaskSpawn = { \"Sea\", \"LandSmall\" }", "movement.speed = 5", "movement.terrainAlignmentFactor = 0", "movement.walkAnimation = { authoredSpeed = 0.8928571428571429 }", "addTag(\"LAND\")", "addTag(\"AMPHIBIOUS\")", "addTag(\"NAVAL\")", "transformSourceClip = \"AnimTransform02\"", "transformDurationSeconds = 7", "transformSourceRate = 2", "transformReverseSourceRate = -2", "transformPlaybackSeconds = 3.5", "landRestAnimationKey = \"salemLandRest\"", "landRestCrossFadeSeconds = 1", "walkSourceRate = 2.8", "walkAuthoredSpeed = 0.8928571428571429", "waterSpeed = 5", "landSpeed = 2.5", "waterColliderOffsetY = 0.36", "landColliderOffsetY = 1.01", "waterTerrainAlignmentFactor = 0", "landTerrainAlignmentFactor = 1", "landDeathPlaybackSeconds = 3", "waterDeathSourceDurationSeconds = 21.7", "waterDeathRateMin = 0.5", "waterDeathRateMax = 1.5", "waterDeathRateSteps = 101", "waterPostWreckSeconds = 5", "mediumDebounceTicks = 3", "antiTorpedoTargetFiltering = true", "sourceAudioEffects = true", "waterVision = true", "Units/ugn2001/LOD0/ugn2001_amphibious.sananimation", "8026850836A1778313425BE6FFB20E3B0722319FC28B43EA4599866D37248BFF", "2CD8C37D44957AAB36154A0C3E58F68F6547A05329B7CFD927E903C579F62AF1");
		RequireExactly(source, "clipName = \"AnimTransform02\"", 1, "Salem Transform02 binding");
		RequireExactly(source, "clipName = \"LandRest\"", 1, "Salem deployed land-rest binding");
		RequireExactly(source, "clipName = \"AnimWalk\"", 1, "Salem walk binding");
		RequireExactly(source, "clipName = \"AnimAdeath\"", 1, "Salem land-death binding");
		RequireExactly(source, "clipName = \"AnimAsink02\"", 1, "Salem water-death02 binding");
		RequireExactly(source, "clipName = \"AnimAsink03\"", 1, "Salem water-death03 binding");
		RequireExactly(source, "cannon.damage = 115", 1, "Salem cannon damage");
		RequireExactly(source, "cannon.reloadTime = 1", 1, "Salem cannon cadence");
		RequireExactly(source, "cannon.rangeMax = 80", 1, "Salem cannon range");
		RequireExactly(source, "cannon.muzzleSalvoSize = 1", 1, "Salem simultaneous cannon group salvo");
		RequireExactly(source, "{ muzzles = { \"CannonBarrel_R\", \"CannonBarrel_L\" } }", 1, "Salem simultaneous cannon group");
		RequireExactly(source, "antiAir.damage = 2", 1, "Salem AA damage");
		RequireExactly(source, "antiAir.reloadTime = 0.6666666666666666", 1, "Salem AA cadence");
		RequireExactly(source, "{ muzzles = { \"AA_Barrel_R01\" } }", 1, "Salem AA R01 cycle group");
		RequireExactly(source, "{ muzzles = { \"AA_Barrel_R02\" } }", 1, "Salem AA R02 cycle group");
		RequireExactly(source, "{ muzzles = { \"AA_Barrel_L01\" } }", 1, "Salem AA L01 cycle group");
		RequireExactly(source, "{ muzzles = { \"AA_Barrel_L02\" } }", 1, "Salem AA L02 cycle group");
		RequireExactly(source, "torpedoes.damage = 40", 1, "Salem torpedo damage");
		RequireExactly(source, "torpedoes.reloadTime = 4", 1, "Salem torpedo cadence");
		RequireExactly(source, "torpedoes.rangeMax = 45", 1, "Salem torpedo range");
		RequireExactly(source, "torpedoes.muzzleSalvoSize = 2", 1, "Salem torpedo salvo size");
		RequireExactly(source, "torpedoes.muzzleSalvoDelay = 0.8", 1, "Salem torpedo salvo delay");
		RequireExactly(source, "torpedoes.layerWeaponLimits = { \"WaterSurface\" }", 1, "Salem water-only torpedo origin");
		RequireExactly(source, "layerWeaponLimits = { \"Land\", \"WaterSurface\" }", 2, "Salem land/water surface weapons");
	}

	private static void AppendSalemAmphibiousContract(StringBuilder builder)
	{
		builder.AppendLine("do\n    local movement = UnitTemplate.movement\n    local weapons = UnitTemplate.weapons\n    if not movement or not weapons or #weapons ~= 3\n        or weapons[1].name ~= \"ParticleGun\"\n        or weapons[2].name ~= \"AAGun\"\n        or weapons[3].name ~= \"TorpedoL\"\n    then\n        error(\"Salem amphibious source anchors drifted\")\n    end\n\n    UnitTemplate.general.iconUIType = \"amphibious\"\n    UnitTemplate.general.requiresWaterPlacement = nil\n    movement.type = \"TracksAmphibious\"\n    movement.speed = 5\n    movement.referenceAltitude = \"GroundOrWater\"\n    -- A surface hull must remain level over submerged terrain.  The host\n    -- lifecycle switches this to ground alignment only after land commits.\n    movement.terrainAlignmentFactor = 0\n    movement.collisionMaskDefault = { \"Sea\", \"LandSmall\" }\n    movement.collisionMaskSpawn = { \"Sea\", \"LandSmall\" }\n    movement.walkAnimation = { authoredSpeed = 0.8928571428571429 }\n\n    local function addTag(tag)\n        for _, existing in ipairs(UnitTemplate.tags) do\n            if existing == tag then return end\n        end\n        table.insert(UnitTemplate.tags, tag)\n    end\n    addTag(\"LAND\")\n    addTag(\"AMPHIBIOUS\")\n    addTag(\"NAVAL\")\n\n    local animationPath = \"@ANIMATION_PATH@\"\n    UnitTemplate.visuals.animations = {\n        walk = {\n            clipName = \"Rest\",\n            sanAnimationPath = animationPath,\n            playbackMode = 0,\n        },\n        run = {\n            authoredSpeed = 0.8928571428571429,\n            clipName = \"AnimWalk\",\n            sanAnimationPath = animationPath,\n            startSpeed = 0.01,\n        },\n        salemTransform = {\n            clipName = \"AnimTransform02\",\n            sanAnimationPath = animationPath,\n            playbackMode = 0,\n        },\n        salemLandRest = {\n            clipName = \"LandRest\",\n            sanAnimationPath = animationPath,\n            playbackMode = 0,\n        },\n        salemLandDeath = {\n            clipName = \"AnimAdeath\",\n            sanAnimationPath = animationPath,\n            playbackMode = 0,\n        },\n        salemWaterDeath02 = {\n            clipName = \"AnimAsink02\",\n            sanAnimationPath = animationPath,\n            playbackMode = 0,\n        },\n        salemWaterDeath03 = {\n            clipName = \"AnimAsink03\",\n            sanAnimationPath = animationPath,\n            playbackMode = 0,\n        },\n    }\n\n    UnitTemplate.additions.faSalemAmphibious = {\n        sourceBlueprintSha256 = \"3BC6DD799B3CDB76CB92B501C1B8AED17CC63F5E4CE95E41D87F329106813CAC\",\n        embeddedAnimationSha256 = \"@ANIMATION_SHA256@\",\n        embeddedPackSha256 = \"@PACK_SHA256@\",\n        animationOwner = \"GuardFaCybranSalem host medium/transition/death lifecycle\",\n        transformAnimationKey = \"salemTransform\",\n        transformSourceClip = \"AnimTransform02\",\n        transformDurationSeconds = 7,\n        transformSourceRate = 2,\n        transformReverseSourceRate = -2,\n        transformPlaybackSeconds = 3.5,\n        landRestAnimationKey = \"salemLandRest\",\n        landRestCrossFadeSeconds = 1,\n        walkSourceRate = 2.8,\n        walkAuthoredSpeed = 0.8928571428571429,\n        waterSpeed = 5,\n        landSpeed = 2.5,\n        waterColliderOffsetY = 0.36,\n        landColliderOffsetY = 1.01,\n        waterTerrainAlignmentFactor = 0,\n        landTerrainAlignmentFactor = 1,\n        landDeathPlaybackSeconds = 3,\n        waterDeathSourceDurationSeconds = 21.7,\n        waterDeathRateMin = 0.5,\n        waterDeathRateMax = 1.5,\n        waterDeathRateSteps = 101,\n        waterPostWreckSeconds = 5,\n        mediumDebounceTicks = 3,\n        waterEnterDepth = 0.05,\n        waterExitDepth = 0.01,\n        landDeathAnimationKey = \"salemLandDeath\",\n        waterDeathAnimationKeys = { \"salemWaterDeath02\", \"salemWaterDeath03\" },\n    }\n\n    UnitTemplate.additions.seaParityUnsupported =\n        UnitTemplate.additions.seaParityUnsupported or {}\n    UnitTemplate.additions.seaParityUnsupported.antiTorpedoTargetFiltering = true\n    UnitTemplate.additions.seaParityUnsupported.sourceAudioEffects = true\n    UnitTemplate.additions.seaParityUnsupported.waterVision = true\n\n    local cannon = weapons[1]\n    cannon.damage = 115\n    cannon.reloadTime = 1\n    cannon.rangeMax = 80\n    cannon.muzzleGroups = {\n        { muzzles = { \"CannonBarrel_R\", \"CannonBarrel_L\" } },\n    }\n    -- Sanctuary fires every muzzle in the selected group together. One salvo\n    -- over the pinned two-muzzle group is the FA two-shot simultaneous volley.\n    cannon.muzzleSalvoSize = 1\n    cannon.muzzleSalvoDelay = 0\n    cannon.layerWeaponLimits = { \"Land\", \"WaterSurface\" }\n\n    local antiAir = weapons[2]\n    antiAir.damage = 2\n    antiAir.reloadTime = 0.6666666666666666\n    antiAir.muzzleSalvoSize = 1\n    antiAir.muzzleSalvoDelay = 0\n    antiAir.layerWeaponLimits = { \"Land\", \"WaterSurface\" }\n    antiAir.muzzleGroups = {\n        { muzzles = { \"AA_Barrel_R01\" } },\n        { muzzles = { \"AA_Barrel_R02\" } },\n        { muzzles = { \"AA_Barrel_L01\" } },\n        { muzzles = { \"AA_Barrel_L02\" } },\n    }\n\n    local torpedoes = weapons[3]\n    torpedoes.damage = 40\n    torpedoes.reloadTime = 4\n    torpedoes.rangeMax = 45\n    torpedoes.muzzleSalvoSize = 2\n    torpedoes.muzzleSalvoDelay = 0.8\n    torpedoes.layerWeaponLimits = { \"WaterSurface\" }\nend".Replace("@ANIMATION_PATH@", "Units/ugn2001/LOD0/ugn2001_amphibious.sananimation").Replace("@ANIMATION_SHA256@", "8026850836A1778313425BE6FFB20E3B0722319FC28B43EA4599866D37248BFF").Replace("@PACK_SHA256@", "2CD8C37D44957AAB36154A0C3E58F68F6547A05329B7CFD927E903C579F62AF1"));
	}

	private static void ValidateGeneratedUnsupportedContracts(string source, string targetId)
	{
		if (!SeaParityManifest.UnsupportedGeneratedWeaponLabels.TryGetValue(targetId, out IReadOnlyList<string> value))
		{
			return;
		}
		if (targetId != "uen3001" || value.Count != 2 || value[0] != "RightPhalanxGun01" || value[1] != "LeftPhalanxGun01")
		{
			throw Incompatible("Generated unsupported-weapon manifest drifted.");
		}
		RequireExactly(source, "sourceIndex = 8,", 1, "Summit right Phalanx source index");
		RequireExactly(source, "sourceIndex = 9,", 1, "Summit left Phalanx source index");
		RequireExactly(source, "runtimeStatus = \"skipped-unsupported\",", 2, "Summit unsupported runtime status");
		RequireExactly(source, "targetType = \"RULEWTT_Projectile\",", 2, "Summit projectile-target contract");
		RequireExactly(source, "sourceSonarRadius = 20,", 1, "Summit source sonar");
		RequireExactly(source, "sanctuarySonarAdvertised = false,", 1, "Summit unsupported sonar ledger");
		RequireExactly(source, "sourceWaterVisionRadius = 50,", 1, "Summit source water vision");
		RequireExactly(source, "sanctuaryWaterVisionAdvertised = false,", 1, "Summit unsupported water-vision ledger");
		RequireExactly(source, "sourceVeterancyThresholds = { 32, 64, 96, 128, 160 },", 1, "Summit source veterancy thresholds");
		RequireExactly(source, "sanctuaryVeterancyMapped = false,", 1, "Summit unsupported veterancy ledger");
		RequireExactly(source, "sourceDeathAnimationLifecycleSupported = false,", 1, "Summit unsupported death-animation ledger");
		RequireExactly(source, "sonarRadius =", 0, "Summit runtime sonar advertisement");
		int num = source.IndexOf("    weapons = {", StringComparison.Ordinal);
		if (num < 0)
		{
			throw Incompatible("Summit generated weapons table is absent.");
		}
		string source2 = source.Substring(num);
		RequireExactly(source2, "projectileTemplate =", 7, "Summit supported weapon count");
		foreach (string item in value)
		{
			RequireExactly(source, "label = \"" + item + "\",", 1, "Summit unsupported source label " + item);
			RequireExactly(source2, "name = \"" + item + "\"", 0, "Summit unsupported runtime weapon " + item);
		}
	}

	private static void ValidateHostWaterPatch(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, "host sea-parity marker");
		RequireExactly(source, "-- Supreme Commander Overhaul final naval placement depth 1.0.0", 1, "host final naval-depth marker");
		RequireTokens(source, "SCOSeaParityWaterFactoryIds", "SCOSeaParityWaterPlacementIds", "SCOSeaParityWaterMinimumDepth", "SCOSeaParityDualLandWaterIds", "local function SCOSeaParityMinimumDepth(tp)", "local faContract = additions and additions.faSourceContract", "local authored = faContract and faContract.minimumWaterDepth", "if type(authored) == \"number\" and authored >= 0 then", "local allowed = bit.bor(PlacementLayer.Water, PlacementLayer.InvalidTerrain, PlacementLayer.Default)", "bit.band(flags, PlacementLayer.Water) == 0", "bit.band(flags, bit.bnot(allowed)) ~= 0", "OverhaulFactoryPlacementReservationsAreClear(", "OverhaulFactoryReservationOwner(overlappingID)", "Engine.GetGlobalGridModifiers", "overlappingUnit:IsIntelVisionVisible(Armies[self.armyId])", "SCOSeaParityHasUsableRolloffRoute", "local placementSize = tp.skirtSize or tp.footprint", "SCOSeaParityWaterPlacementState(", "self.positionFloat3, self.tp.skirtSize or self.tp.footprint", "return SCO_StockHostBuildOrderIsOrderValid(self)", "return SCO_StockHostBuildOrderOrderStart(self)", "tp.additions and tp.additions.rollOffRamps", "ramp and ramp.clearanceOffset", "self.positionFloat3 = EngineClasses.float3(", "waterLevel");
		RequireExactly(source, "SCOSeaParityAllRolloffRoutesAreSubmerged", 0, "obsolete all-routes host predicate");
		RequireExactly(source, "local minimumDepth = SCOSeaParityWaterMinimumDepth[id]", 0, "obsolete host direct minimum-depth lookup");
		RequireExactly(source, "local minimumDepth = id and SCOSeaParityWaterMinimumDepth[id]", 0, "obsolete host optional minimum-depth lookup");
		RequireExactly(source, "local minimumDepth = SCOSeaParityMinimumDepth(tp)", 3, "host final minimum-depth resolutions");
		foreach (string waterFactoryId in SeaParityManifest.WaterFactoryIds)
		{
			RequireExactly(source, "[\"" + waterFactoryId + "\"] = true", 2, waterFactoryId + " water ID");
		}
		foreach (string waterMobileId in SeaParityManifest.WaterMobileIds)
		{
			int expected = ((!(waterMobileId == "ucl3701") && !(waterMobileId == "uen3005")) ? 1 : 2);
			RequireExactly(source, "[\"" + waterMobileId + "\"] = true", expected, waterMobileId + " water ID");
		}
	}

	private static void ValidateClientWaterPatch(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, "client sea-parity marker");
		RequireExactly(source, "-- Supreme Commander Overhaul final naval placement depth 1.0.0", 1, "client final naval-depth marker");
		RequireTokens(source, "SCOSeaParityPreviousCanPlaceAtArea", "SCOSeaParityPlacementSize(unitTemplate)", "SCOSeaParityWaterPlacementState(", "SCOSeaParityWaterMinimumDepth", "SCOSeaParityDualLandWaterIds", "local function SCOSeaParityMinimumDepth(tp)", "local faContract = additions and additions.faSourceContract", "local authored = faContract and faContract.minimumWaterDepth", "if type(authored) == \"number\" and authored >= 0 then", "not SCOSeaParityWaterCellIsClear(gridQueryResult.flags)", "SCOSeaParityCellIsDeepEnough", "SCOSeaParityHasUsablePreviewRolloff", "local function SCOSeaParityPreviewPointIsSubmerged(tp, position, waterLevel)", "tp, routePoint, waterLevel)", "tp, exitPoint, waterLevel)", "tp.additions and tp.additions.rollOffRamps", "ramp and ramp.clearanceOffset", "local flags = results[1].flags", "and SCOSeaParityWaterCellIsClear(flags)", "return SCOSeaParityPreviousCanPlaceAtArea(");
		RequireExactly(source, "SCOSeaParityAllPreviewRolloffsAreSubmerged", 0, "obsolete all-routes client predicate");
		RequireExactly(source, "local minimumDepth = SCOSeaParityWaterMinimumDepth[id]", 0, "obsolete client direct minimum-depth lookup");
		RequireExactly(source, "local minimumDepth = id and SCOSeaParityWaterMinimumDepth[id]", 0, "obsolete client optional minimum-depth lookup");
		RequireExactly(source, "local minimumDepth = SCOSeaParityMinimumDepth(tp)", 3, "client final minimum-depth resolutions");
		RequireExactly(source, "SCOSeaParityPreviewMargin", 0, "obsolete client preview-depth margin");
		RequireExactly(source, "unitTemplate.skirtSize", 0, "unpatched construction-preview skirt references");
		RequireExactly(source, "                    if isWaterPlacement then\n                        local flags = results[1].flags\n                        isValid = waterRollOffIsValid\n                            and waterLevel ~= nil\n                            and SCOSeaParityWaterCellIsClear(flags)\n                            and SCOSeaParityCellIsDeepEnough(\n                                unitTemplate, cellCoord, waterLevel)\n                    end\n                    isValid = isValid and dualSiteIsValid\n                    cellIsValid[x][y] = isValid\n", 1, "Sea Parity and dual-water preview checks");
		RequireExactly(source, "                    isValid = isValid and (not isWaterPlacement\n                        or (waterRollOffIsValid and waterLevel ~= nil\n                            and SCO_IsSeraphimSubmergedCell(cellCoord, waterLevel)))\n", 0, "obsolete preview water check");
		foreach (string waterFactoryId in SeaParityManifest.WaterFactoryIds)
		{
			RequireExactly(source, "[\"" + waterFactoryId + "\"] = true", 2, waterFactoryId + " preview water ID");
		}
		foreach (string waterMobileId in SeaParityManifest.WaterMobileIds)
		{
			int expected = ((!(waterMobileId == "ucl3701") && !(waterMobileId == "uen3005")) ? 1 : 2);
			RequireExactly(source, "[\"" + waterMobileId + "\"] = true", expected, waterMobileId + " preview water ID");
		}
		int num = source.IndexOf("-- Supreme Commander Overhaul sea parity 1.0.0", StringComparison.Ordinal);
		int num2 = source.LastIndexOf("\n--Only for annotataions\nreturn {", StringComparison.Ordinal);
		if (num < 0 || num2 <= num)
		{
			throw Incompatible("Client sea-parity appendix is not before the module return.");
		}
	}

	private static void ValidatePlacementGhostLoader(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, "placement-ghost sea-parity marker");
		RequireTokens(source, "selectionSize = tp.skirtSize or tp.footprint", "local SCOSeaParityGhostPlacementSize = tp.skirtSize", "and SCOSeaParityGhostRequiresWater", "SCOSeaParityGhostPlacementSize = tp.footprint", "Water placement ghost has neither skirt nor footprint.", "EngineClasses.int2(SCOSeaParityGhostPlacementSize.x, SCOSeaParityGhostPlacementSize.y)", "table.insert(localGridModifierTemplates, EngineClasses.GridModifierTemplate(TemplateHeadEntityName,", "table.insert(globalGridModifierTemplates, EngineClasses.GridModifierTemplate(TemplateHeadEntityName,");
		RequireExactly(source, "if tp.skirtSize then", 0, "unpatched placement-ghost skirt branch");
	}

	private static void ValidateHostWeaponTargetGate(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, "host-weapon sea-parity marker");
		RequireExactly(source, "local SCOSeaParityPreviousHostWeaponCanShootAt = HostWeapon.CanShootAt", 1, "host-weapon previous-wrapper binding");
		RequireTokens(source, "if not SCOSeaParityPreviousHostWeaponCanShootAt(self, targetUnit) then", "self.tp.scoSeaParityTargetGate ~= \"TargetAbove\"", "local waterResult, hasWater = Engine.HasWater()", "if waterResult ~= EngineErrorCode.Success then return false end", "if not hasWater then return true end", "local levelResult, waterLevel = Engine.GetWaterLevel()", "local targetPosition = targetUnit and targetUnit:GetPosition()", "targetPosition.y >= waterLevel - 0.05");
		int num = source.LastIndexOf("if not SCOSeaParityPreviousHostWeaponCanShootAt(self, targetUnit) then", StringComparison.Ordinal);
		int num2 = source.LastIndexOf("self.tp.scoSeaParityTargetGate ~= \"TargetAbove\"", StringComparison.Ordinal);
		if (num < 0 || num2 <= num)
		{
			throw Incompatible("Host-weapon target gate does not compose previous-first.");
		}
	}

	private static void ValidateUnitBlueprintValidator(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul Salem amphibious NAVAL preservation 1.0.0", 1, "Salem validator marker");
		RequireExactly(source, "local preserveSalemNavalTag = templateIdentifier == \"ugn2001\"", 1, "Salem template-ID exception");
		RequireExactly(source, "and argument.type == \"TracksAmphibious\"", 1, "Salem movement-type exception");
		RequireExactly(source, "and tagName == \"NAVAL\"", 1, "Salem NAVAL-tag exception");
		RequireTokens(source, "if not requiredMovementTagLookup[tagName]", "and not preserveSalemNavalTag", "and movementBlueprintHasTag(blueprint, tagName)", "removeMovementTag(blueprint, tagName)");
	}

	private static void ValidateImportScanner(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, "import scanner marker");
		RequireTokens(source, "SCOSeaParityPreviousScanDir", "known[folder] = true", "directory == \"common/units/unitsTemplates/\"", "directory == \"common/projectiles/projectilesTemplates/\"");
		foreach (SeaTemplateSpec generatedTemplate in SeaParityManifest.GeneratedTemplates)
		{
			RequireExactly(source, "\"" + generatedTemplate.TargetId + "\",", 1, generatedTemplate.TargetId + " scanner ID");
		}
		foreach (string generatedProjectileId in SeaParityManifest.GeneratedProjectileIds)
		{
			RequireExactly(source, "\"" + generatedProjectileId + "\",", 1, generatedProjectileId + " scanner ID");
		}
	}

	private static void ValidateRegistrationTable(string source, string tableName)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, tableName + " marker");
		foreach (string registrationId in SeaParityManifest.RegistrationIds)
		{
			RequireExactly(source, tableName + "[\"" + registrationId + "\"] = true", 1, tableName + " " + registrationId);
		}
		foreach (string quickLaunchOnlyRegistrationId in SeaParityManifest.QuickLaunchOnlyRegistrationIds)
		{
			RequireExactly(source, tableName + "[\"" + quickLaunchOnlyRegistrationId + "\"] = true", (tableName == "QuickLaunchUnits") ? 1 : 0, tableName + " quick-launch-only " + quickLaunchOnlyRegistrationId);
		}
	}

	private static void ValidateExistingAirFactoryVisibility(string source, string targetId)
	{
		string text = (targetId.StartsWith("ues", StringComparison.Ordinal) ? "EDA" : "GUARD");
		int num = (targetId.EndsWith("2512", StringComparison.Ordinal) ? 2 : 3);
		string text2 = "BUILDABLE_BY_T" + num + "_FACTORY";
		string text3 = "BUILDABLE_BY_T" + (num - 1) + "_FACTORY";
		string token = "canBuild = \"Tags." + text + " * Tags." + text2 + " * ((Tags.AIR * Tags.MOBILE) + (Tags.LAND * Tags.MOBILE * Tags.ENGINEER) + Tags.AIR_FACTORY)\"";
		RequireExactly(source, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, targetId + " marker");
		RequireExactly(source, "-- Supreme Commander Overhaul FA Air Factories 1.0.0", 1, targetId + " FA air-factory marker");
		RequireExactly(source, "DEMO_UI_ONLY", 0, targetId + " demo-only gate");
		RequireExactly(source, token, 1, targetId + " build domain");
		RequireExactly(source, "\"" + text + "\"", 1, targetId + " faction tag");
		RequireExactly(source, "\"TECH" + num + "\"", 1, targetId + " tech tag");
		RequireExactly(source, "\"AIR_FACTORY\"", 1, targetId + " air-factory tag");
		RequireExactly(source, "\"" + text3 + "\"", 1, targetId + " factory-buildable tag");
		RequireExactly(source, "\"BUILDABLE_BY_T" + num + "_ENGINEER\"", 1, targetId + " engineer-buildable tag");
		RequireTokens(source, "tpId = \"" + targetId + "\"", "faAirFactoryLifecycle", "UnitTemplate.construction.buildPower");
		if (num == 2)
		{
			RequireExactly(source, "upgradesTo = \"" + targetId.Substring(0, 3) + "3512\"", 2, targetId + " upgrade edge");
		}
		else
		{
			RequireExactly(source, "upgradesTo", 0, targetId + " terminal upgrade edge");
		}
	}

	private static void ValidateWaterFactoryTemplate(string source, string targetId)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, targetId + " marker");
		RequireTokens(source, "tpId = \"" + targetId + "\"", "UnitTemplate.general.requiresWaterPlacement = true", "#SCOSeaParityRolloffs ~= 2", "#SCOSeaParityRamps ~= 2");
	}

	private static void ValidateWeaponOriginPatch(string source, string targetId, int expectedCombatWeapons)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, targetId + " marker");
		RequireTokens(source, "combatCount ~= " + expectedCombatWeapons, "local originLayers = { \"WaterSurface\" }", "originLayers = { \"Water\", \"WaterSurface\" }", "weapon.layerWeaponLimits = originLayers", "local targetsLand = false", "for _, targetLayer in ipairs(weapon.layerTargetLimits or {}) do", "if targetLayer == \"Land\" then targetsLand = true break end", "local ring = weapon.rangeRingType", "weapon.targetWaterLimits == \"Above\"", "and targetsLand", "and (ring == \"DirectFire\" or ring == \"IndirectFire\")", "weapon.scoSeaParityTargetGate = \"TargetAbove\"", "weapon.scoSeaParityTargetGate = nil", "weapon.category ~= \"DeathExplosion\"");
		int num = source.LastIndexOf("-- Supreme Commander Overhaul sea parity 1.0.0", StringComparison.Ordinal);
		string source2 = ((num >= 0) ? source.Substring(num) : "");
		RequireExactly(source2, "weapon.layerTargetLimits =", 0, targetId + " target-limit rewrite");
		RequireExactly(source2, "weapon.scoSeaParityTargetGate = \"TargetAbove\"", 1, targetId + " surface-target gate assignment");
		RequireExactly(source2, "weapon.scoSeaParityTargetGate = nil", 1, targetId + " non-surface target-gate clear");
		if (targetId == "usn1002")
		{
			RequireTokens(source, "gated ~= 1", "projectileInterception = true");
		}
		if (targetId == "usn3001")
		{
			RequireTokens(source, "gatedNuke ~= 1", "gatedDefense ~= 2", "nukeSilo = true");
		}
		if (targetId == "ucs2803" || targetId == "usn3003")
		{
			RequireTokens(source, "UnitTemplate.construction.canBuild = nil", "seaParityUnsupported.carrierDeck = true");
		}
		if (SeaParityManifest.UnsupportedAeonWeaponLabels.ContainsKey(targetId))
		{
			ValidateAeonUnsupportedWeaponGate(source, targetId);
		}
		ValidateSeraphimUnsupportedWeaponGate(source, targetId);
		ValidateExistingWeaponSemanticPatch(source, targetId);
		if (SeaParityManifest.WaterMobileIds.Contains<string>(targetId))
		{
			RequireTokens(source, "UnitTemplate.general.requiresWaterPlacement = true", "UnitTemplate.skirtSize = nil");
		}
		if (targetId == "ucl4003")
		{
			RequireTokens(source, "UnitTemplate.construction.canBuild = nil", "seaParityUnsupported.movingNavalFactory = true");
		}
	}

	private static void ValidateSeraphimUnsupportedWeaponGate(string source, string targetId)
	{
		if (!SeaParityManifest.UnsupportedSeraphimWeaponLabels.TryGetValue(targetId, out IReadOnlyList<string> value))
		{
			return;
		}
		string source2 = source.Substring(source.LastIndexOf("-- Supreme Commander Overhaul sea parity 1.0.0", StringComparison.Ordinal));
		RequireTokens(source2, "local gates = {", "local weapon = UnitTemplate.weapons[gate.index]", "muzzle.aimController ~= gate.aim", "UnitTemplate.additions.seaParityUnsupported.sourceWeaponLabels = removed", "if removedCount ~= " + value.Count + " then");
		foreach (string item in value)
		{
			RequireExactly(source2, "label = \"" + item + "\"", 1, targetId + "/" + item + " source label");
			RequireExactly(source2, "removed[\"" + item + "\"]", 1, targetId + "/" + item + " removal assertion");
		}
	}

	private static void ValidateExistingWeaponSemanticPatch(string source, string targetId)
	{
		ExistingWeaponSemanticSpec[] array = ExistingWeaponSemantics.Corrections.Where((ExistingWeaponSemanticSpec spec) => spec.TargetId == targetId).ToArray();
		if (array.Length == 0)
		{
			return;
		}
		string text = source.Substring(source.LastIndexOf("-- Supreme Commander Overhaul sea parity 1.0.0", StringComparison.Ordinal));
		RequireTokens(text, "local corrections = {", "local combatWeapons = {}", "controller.aimBone ~= correction.aim", "controller.yawBone ~= correction.yaw", "controller.pitchBone ~= correction.pitch", "actualMuzzleCount ~= expectedMuzzleCount", "table.insert(weapon.muzzleGroups, { muzzles = group })", "weapon.muzzleSalvoSize = correction.muzzleSalvoSize", "weapon.muzzleSalvoDelay = correction.muzzleSalvoDelay", "if #corrections ~= " + array.Length + " then");
		ExistingWeaponSemanticSpec[] array2 = array;
		foreach (ExistingWeaponSemanticSpec existingWeaponSemanticSpec in array2)
		{
			if (existingWeaponSemanticSpec.MuzzleSalvoDelay == 0.0)
			{
				if (existingWeaponSemanticSpec.MuzzleSalvoSize != 1)
				{
					throw Incompatible(targetId + "/" + existingWeaponSemanticSpec.SourceWeaponLabel + " zero-delay schedule is not one simultaneous group.");
				}
			}
			else if (existingWeaponSemanticSpec.MuzzleSalvoSize % existingWeaponSemanticSpec.MuzzleGroups.Count != 0)
			{
				throw Incompatible(targetId + "/" + existingWeaponSemanticSpec.SourceWeaponLabel + " delayed schedule cannot reset its group phase.");
			}
			RequireExactly(text, "sourceLabel = \"" + existingWeaponSemanticSpec.SourceWeaponLabel + "\"", 1, targetId + "/" + existingWeaponSemanticSpec.SourceWeaponLabel + " correction");
			int num2 = text.IndexOf("        { sourceLabel = \"" + existingWeaponSemanticSpec.SourceWeaponLabel + "\"", StringComparison.Ordinal);
			int num3 = ((num2 < 0) ? (-1) : text.IndexOf("        } },", num2, StringComparison.Ordinal));
			if (num2 < 0 || num3 < 0)
			{
				throw Incompatible(targetId + "/" + existingWeaponSemanticSpec.SourceWeaponLabel + " correction row is incomplete.");
			}
			string a = text.Substring(num2, num3 - num2 + "        } },".Length);
			StringBuilder stringBuilder = new StringBuilder().Append("        { sourceLabel = \"").Append(existingWeaponSemanticSpec.SourceWeaponLabel).Append("\", combatIndex = ")
				.Append(existingWeaponSemanticSpec.UpstreamCombatIndex)
				.Append(", aim = \"")
				.Append(existingWeaponSemanticSpec.AimBone)
				.Append("\", yaw = \"")
				.Append(existingWeaponSemanticSpec.YawBone)
				.Append("\", pitch = \"")
				.Append(existingWeaponSemanticSpec.PitchBone)
				.Append("\", muzzleSalvoSize = ")
				.Append(existingWeaponSemanticSpec.MuzzleSalvoSize)
				.Append(", muzzleSalvoDelay = ");
			double value = existingWeaponSemanticSpec.MuzzleSalvoDelay;
			StringBuilder stringBuilder2 = stringBuilder.Append(StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture)).Append(", groups = {\n");
			foreach (IReadOnlyList<string> muzzleGroup in existingWeaponSemanticSpec.MuzzleGroups)
			{
				stringBuilder2.Append("            {");
				foreach (string item in muzzleGroup)
				{
					stringBuilder2.Append(" \"").Append(item).Append("\",");
				}
				stringBuilder2.Append(" },\n");
			}
			stringBuilder2.Append("        } },");
			if (!string.Equals(a, stringBuilder2.ToString(), StringComparison.Ordinal))
			{
				throw Incompatible(targetId + "/" + existingWeaponSemanticSpec.SourceWeaponLabel + " ordered correction row drifted.");
			}
		}
	}

	private static void ValidateTempestGate(string source)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, "ucl4003 marker");
		RequireTokens(source, "tpId = \"ucl4003\"", "sourceId = \"UAS0401\"", "\"AeonPortNavalUnit\"", "UnitTemplate.construction.canBuild = nil", "seaParityUnsupported.movingNavalFactory = true");
		ValidateAeonUnsupportedWeaponGate(source, "ucl4003");
		RequireTokens(source, "UnitTemplate.general.requiresWaterPlacement = true", "UnitTemplate.skirtSize = nil");
	}

	private static void ValidateAeonUnsupportedWeaponGate(string source, string targetId)
	{
		if (!SeaParityManifest.UnsupportedAeonWeaponLabels.TryGetValue(targetId, out IReadOnlyList<string> value))
		{
			throw new ArgumentOutOfRangeException("targetId");
		}
		RequireTokens(source, "local label = weapon.scoSourceLabel", "if removedCount ~= " + value.Count + " then", "UnitTemplate.weapons = retained");
		foreach (string item in value)
		{
			RequireExactly(source, "[\"" + item + "\"] = true", 1, targetId + "/" + item + " gate label");
			RequireExactly(source, "scoSourceLabel = \"" + item + "\"", 1, targetId + "/" + item + " upstream label");
		}
		RequireTokens(source, (targetId == "ucl4001") ? "seaParityUnsupported.nukeSilo = true" : "seaParityUnsupported.projectileInterception = true");
	}

	private static void ValidateHostFactionClasses(string source, bool eda)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, "host class marker");
		RequireExactly(source, "-- Supreme Commander Overhaul usable naval factory rolloff 1.0.0", 1, "usable naval-rolloff marker");
		RequireTokens(source, eda ? "HostEDAFaUefNavalFactory" : "HostGuardFaCybranNavalFactory", "SCOFaAirFactoryLifecycle.BindPlatform(self)", "function SCOSeaParityNavalFactoryHostClass:RollOffUnit(targetUnit)", "local function SCOSeaParityRolloffMinimumDepth(factory)", "faContract.minimumWaterDepth", "local function SCOSeaParityRolloffRouteIsSubmerged(", "Engine.SampleTerrainHeight(routePoint)", "Engine.SampleTerrainHeight(exitPoint)", "Sea-parity naval factory has no submerged rolloff route.", "Engine.QuaternionRotateVector", "route.unitSpin", "source.rallyPoint", "targetUnit:SetPosition(routePoint)", "Engine.SetVolumeColliderEnabled(targetUnit.id, false)", "Engine.SetVolumeColliderEnabled(targetUnit.id, true)", "SCOSeaParityOrderTasks.MOVE, {targetUnit}, false, exitPoint, nil", "SCOSeaParityOrderTasks.MOVE, {targetUnit}, true, rallyPoint, nil");
		string text = source.Substring(source.LastIndexOf("-- Supreme Commander Overhaul sea parity 1.0.0", StringComparison.Ordinal));
		int num = text.IndexOf("function SCOSeaParityNavalFactoryHostClass:RollOffUnit(targetUnit)", StringComparison.Ordinal);
		int num2 = ((num < 0) ? (-1) : text.IndexOf("function SCOSeaParityNavalFactoryHostClass:OnDestroy(isDelete)", num, StringComparison.Ordinal));
		if (num < 0 || num2 <= num)
		{
			throw Incompatible("Host naval-factory rolloff method is incomplete.");
		}
		string source2 = text.Substring(num, num2 - num);
		RequireExactly(source2, "SCOSeaParitySelectRolloffRoute(self, rallyPoint, waterLevel)", 1, "water-aware physical-factory route selection");
		RequireExactly(source2, "SCOSeaParitySelectRolloffRoute(self, rallyPoint)", 0, "obsolete physical-factory route selection");
		RequireExactly(source2, "SCOSeaParityRotateFactoryOffset(\n        self, route.offset", 2, "physical-factory rolloff transform");
		RequireExactly(source2, "self:GetOrientation()", 1, "physical-factory rolloff orientation");
		RequireExactly(source2, "source.rallyPoint", 1, "logical-source rally read");
		RequireExactly(source2, "source.", 1, "logical-source rolloff access");
		RequireOrderedTokens(text, "host naval-factory lifecycle", "function SCOSeaParityNavalFactoryHostClass:OnStartBuildRoutine(targetUnit)", "SCOSeaParityNavalFactoryHostBase.OnStartBuildRoutine(self, targetUnit)", "SCOSeaParityFactoryLifecycle.StartBuild(self, targetUnit)", "function SCOSeaParityNavalFactoryHostClass:OnStopBuildRoutine(targetUnit)", "SCOSeaParityNavalFactoryHostBase.OnStopBuildRoutine(self, targetUnit)", "SCOSeaParityFactoryLifecycle.StopBuild(self, targetUnit)", "function SCOSeaParityNavalFactoryHostClass:RollOffUnit(targetUnit)", "function SCOSeaParityNavalFactoryHostClass:OnDestroy(isDelete)", "SCOSeaParityFactoryLifecycle.CancelBuild(self)", "SCOSeaParityNavalFactoryHostBase.OnDestroy(self, isDelete)");
		if (eda)
		{
			RequireExactly(source, "-- Supreme Commander Overhaul Salem amphibious parity 1.0.0", 0, "EDA Salem host class");
			return;
		}
		RequireExactly(source, "-- Supreme Commander Overhaul Salem amphibious parity 1.0.0", 1, "Guard Salem host class");
		RequireTokens(source, "HostGuardFaCybranSalem = Class(\"GuardFaCybranSalem\", SCOSeaParitySalemBase)", "SCOSeaParitySalemSentinelBase = -10000", "config.transformSourceClip == \"AnimTransform02\"", "config.transformSourceRate == 2", "config.transformReverseSourceRate == -2", "config.landRestAnimationKey == \"salemLandRest\"", "config.landRestCrossFadeSeconds == 1", "config.mediumDebounceTicks == 3", "config.waterEnterDepth == 0.05", "config.waterExitDepth == 0.01", "unit.tp.movement ~= nil", "position.y > waterLevel + requiredDepth", "return terrainHeight < waterLevel - requiredDepth", "unit.scoSeaParitySalemCandidateTicks >= config.mediumDebounceTicks", "Engine.SetMovementEnabled(unit.id, false)", "Engine.SetMovementTerrainAlignmentFactor(unit.id, factor)", "Engine.SetMovementMaxSpeed(unit.id, water and config.waterSpeed or config.landSpeed)", "Engine.SetVolumeColliderOffset(", "water and config.waterColliderOffsetY or config.landColliderOffsetY", "elapsed + sourceRate * Constants.TickTimeStep", "local movementResult, movementSpeed = Engine.GetMovementCurrentSpeed(self.id)", "movementResult ~= EngineErrorCode.Success", "SCOSeaParitySalemLifecycle.Stop(self, true)", "unit.scoSeaParitySalemMovementActive == true", "unit.scoSeaParitySalemMovementUnavailable = true", "animations.run.startSpeed or 0", "SCOSeaParitySalemLifecycle.PlayLandWalk(self, animations)", "animations.salemLandRest.id", "SCOSeaParitySalemLifecycle.PlayLandRest(self, config, animations)", "function SCOSeaParitySalemBase:OnStopBeingBuilt(...)", "function SCOSeaParitySalemBase:UpdateAnimations()", "not self.scoSeaParitySalemMediumThread", "function SCOSeaParitySalemBase:OnDestroy(...)", "function SCOSeaParitySalemBase:DeathThread(overkillRatio)", "local key = keys[(identity % 2) + 1]", "local step = math.floor(identity / 2) % config.waterDeathRateSteps", "while elapsed < config.waterDeathSourceDurationSeconds do", "WaitSeconds(config.waterPostWreckSeconds)", "WaitSeconds(config.landDeathPlaybackSeconds)", "SCOSeaParitySalemLifecycle.Stop(self)", "_G.SCOSeaParitySalemLifecycle = SCOSeaParitySalemLifecycle");
		string source3 = source.Substring(source.LastIndexOf("-- Supreme Commander Overhaul Salem amphibious parity 1.0.0", StringComparison.Ordinal));
		RequireExactly(source3, "SCOSeaParitySalemBase.UpdateAnimations(self)", 0, "Salem stock animation dispatcher call");
		RequireExactly(source3, "SCOSeaParitySalemSentinelBase + config.transformDurationSeconds", 0, "obsolete no-blend Salem land-rest sampling");
		RequireExactly(source3, "HoldLandRest", 0, "obsolete sampled Salem land-rest helper");
		RequireExactly(source3, "position.y > waterLevel + requiredDepth", 1, "Salem height-aware medium probe");
		RequireExactly(source3, "function HostGuardFaCybranSalem:OnStopBeingBuilt", 0, "duplicate named-class Salem construction hook");
		RequireExactly(source3, "function HostGuardFaCybranSalem:UpdateAnimations", 0, "duplicate named-class Salem animation hook");
		RequireExactly(source3, "function HostGuardFaCybranSalem:OnDestroy", 0, "duplicate named-class Salem destruction hook");
		RequireExactly(source3, "function HostGuardFaCybranSalem:DeathThread", 0, "duplicate named-class Salem death hook");
		RequireExactly(source3, "SetWeapon", 0, "Salem weapon-disabling runtime call");
	}

	private static void ValidateClientFactionClasses(string source, bool eda)
	{
		RequireExactly(source, "-- Supreme Commander Overhaul sea parity 1.0.0", 1, "client class marker");
		RequireTokens(source, eda ? "ClientEDAFaUefNavalFactory" : "ClientGuardFaCybranNavalFactory", "SCOFaAirFactoryClientLifecycle.Prepare(self)", "SCOFaAirFactoryClientLifecycle.Render(self)", "SCOFaAirFactoryClientLifecycle.Dispose(self)");
		RequireOrderedTokens(source.Substring(source.LastIndexOf("-- Supreme Commander Overhaul sea parity 1.0.0", StringComparison.Ordinal)), "client naval-factory lifecycle", "function SCOSeaParityNavalFactoryClientClass:OnStartBuildRoutine(buildableId)", "SCOSeaParityFactoryClientLifecycle.Prepare(self)", "SCOSeaParityNavalFactoryClientBase.OnStartBuildRoutine(self, buildableId)", "function SCOSeaParityNavalFactoryClientClass:ClientOnStopBuilding()", "SCOSeaParityNavalFactoryClientBase.ClientOnStopBuilding(self)", "SCOSeaParityFactoryClientLifecycle.Dispose(self)", "function SCOSeaParityNavalFactoryClientClass:OnEndUpgrading(upgrade)", "SCOSeaParityNavalFactoryClientBase.OnEndUpgrading(self, upgrade)", "SCOSeaParityFactoryClientLifecycle.Dispose(self)", "function SCOSeaParityNavalFactoryClientClass:RenderUpdateBeams()", "SCOSeaParityNavalFactoryClientBase.RenderUpdateBeams(self)", "SCOSeaParityFactoryClientLifecycle.Render(self)", "function SCOSeaParityNavalFactoryClientClass:OnDestroy(isDelete)", "SCOSeaParityFactoryClientLifecycle.Dispose(self)", "SCOSeaParityNavalFactoryClientBase.OnDestroy(self, isDelete)");
		RequireExactly(source, "-- Supreme Commander Overhaul Salem amphibious parity 1.0.0", (!eda) ? 1 : 0, "client Salem class");
		if (!eda)
		{
			RequireExactly(source, "ClientGuardFaCybranSalem = Class(\n    \"GuardFaCybranSalem\", ClientGuardNavalUnit)", 1, "client Salem class binding");
		}
	}

	private static void RequireTokens(string source, params string[] tokens)
	{
		foreach (string text in tokens)
		{
			if (source.IndexOf(text, StringComparison.Ordinal) < 0)
			{
				throw Incompatible("Required token is absent: " + text);
			}
		}
	}

	private static void RequireOrderedTokens(string source, string description, params string[] tokens)
	{
		int startIndex = 0;
		foreach (string text in tokens)
		{
			int num = source.IndexOf(text, startIndex, StringComparison.Ordinal);
			if (num < 0)
			{
				throw Incompatible(description + " is absent or out of order at: " + text);
			}
			startIndex = num + text.Length;
		}
	}

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int num = Count(source, token);
		if (num != expected)
		{
			throw Incompatible($"Expected {expected} {description} occurrence(s), found {num}.");
		}
	}

	private static string ReplaceExactly(string source, string oldValue, string newValue, int expected, string description)
	{
		RequireExactly(source, oldValue, expected, description);
		return source.Replace(oldValue, newValue);
	}

	private static string Normalize(string source)
	{
		return (source ?? throw new ArgumentNullException("source")).Replace("\r\n", "\n").Replace("\r", "\n");
	}

	private static int Count(string source, string token)
	{
		if (token.Length == 0)
		{
			throw new ArgumentException("Token cannot be empty.", "token");
		}
		int num = 0;
		int startIndex = 0;
		while ((startIndex = source.IndexOf(token, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += token.Length;
		}
		return num;
	}

	private static bool BytesEqual(byte[] left, byte[] right)
	{
		if (left == right)
		{
			return true;
		}
		if (left == null || right == null || left.Length != right.Length)
		{
			return false;
		}
		for (int i = 0; i < left.Length; i++)
		{
			if (left[i] != right[i])
			{
				return false;
			}
		}
		return true;
	}

	private static InvalidOperationException Incompatible(string message)
	{
		return new InvalidOperationException("Incompatible cache source: " + message);
	}
}
