local HostBaseOrder = Import("host/managers/orders/orderClasses/hostBaseOrder.lua").HostBaseOrder
local OrderTasks = Import("common/commonOrders.lua").OrderTasks
local PlacementUtils = Import("common/systems/placementUtils.lua")
local PlacementLayer = Import("common/layers.lua").PlacementLayer
local bit = require("bit")

-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1
-- Factory lanes are separate Default-grid roots. Resolve them to their owner
-- so either faction treats its own lane as the target during placement validation.
_G.SupremeCommanderOverhaulFactoryReservationOwners = _G.SupremeCommanderOverhaulFactoryReservationOwners or {}

local function OverhaulFactoryReservationKey(id)
    return tostring(id.index) .. ":" .. tostring(id.version)
end

local function OverhaulFactoryReservationOwner(id)
    return _G.SupremeCommanderOverhaulFactoryReservationOwners[OverhaulFactoryReservationKey(id)]
end

local function OverhaulFactoryPlacementReservationsAreClear(position, tp, armyId, targetUnit)
    local reservations = tp.additions and tp.additions.placementReservations
    if not reservations then
        return true
    end

    for _, reservation in ipairs(reservations) do
        local size = reservation.size
        local offset = reservation.offset or {}
        if not size then
            return false
        end
        local center = EngineClasses.float3(
            position.x + (offset.x or 0),
            (position.y or 0) + (offset.y or 0),
            position.z + (offset.z or 0)
        )
        local minX, minY, maxX, maxY = PlacementUtils.GetPlacementBounds(center, size)
        local min = EngineClasses.int2(minX, minY)
        local max = EngineClasses.int2(maxX, maxY)
        local _, cells = Engine.GetGlobalGridCellFlags(_G.globalBuildingPlacementGridID, min, max)
        for _, cell in ipairs(cells or {}) do
            local flags = cell.flags
            if not PlacementUtils.IsCellValidForPlacement(flags, PlacementUtils.GetPlacementDomain(tp), false) then
                return false
            end
        end

        local _, ids = Engine.GetGlobalGridModifiers(_G.globalBuildingPlacementGridID, min, max, PlacementLayer.Default)
        for _, id in ipairs(ids or {}) do
            local occupyingID = OverhaulFactoryReservationOwner(id) or id
            local unit = GetUnitById(occupyingID)
            local targetID = targetUnit and targetUnit.id
            local isTarget = targetID and occupyingID.index == targetID.index and occupyingID.version == targetID.version
            if not isTarget and unit and unit:IsIntelVisionVisible(Armies[armyId]) then
                return false
            end
        end
    end

    return true
end
local PlacementDomain = Import("common/layers.lua").PlacementDomain

---@class HostBuildOrder: HostBaseOrder
---@field tpId TemplateId
---@field armyId ArmyId
---@field tp Template
HostBuildOrder = Class("HostBuildOrder", HostBaseOrder)

function HostBuildOrder:__init(orderId, position, payload)
    self.tpId = payload.tpId
    self.armyId = payload.armyId
    self.tp = GetTemplate(self.tpId, "Units")

    position = PlacementUtils.SnapToBuildGrid(self.tp, position)
    HostBaseOrder.__init(self, orderId, OrderTasks.BUILD, position)

    local placementHeight = PlacementUtils.GetPlacementHeight(self.tp, position.x, position.z)
    self.positionFloat3 = { x = position.x, y = placementHeight, z = position.z }
end

function HostBuildOrder:OrderStart()
    HostBaseOrder:OrderStart()
    self.unitGettingBuilt = CreateUnit(self.armyId, self.tp.general.tpId, self.positionFloat3, nil, 0)
end

function HostBuildOrder:GetAdditionalPayload()
    if self.unitGettingBuilt then
        return self.unitGettingBuilt.id
    end
    return nil
end

function HostBuildOrder:ValidateUnitAssignment(unit)
    if not HostBaseOrder:ValidateUnitAssignment(unit) then return false end

    return unit:BuildBehaviorIsValidFor(self.unitGettingBuilt)
end

function HostBuildOrder:UnitStart(unit)
    unit:BuildBehaviorStart(self.unitGettingBuilt)
end

function HostBuildOrder:UnitUpdate(unit)
    return not unit.buildBehaviorIsActive
end

function HostBuildOrder:UnitStop(unit)
    unit:BuildBehaviorStop()
end

function HostBuildOrder:IsOrderValid()
    if not OverhaulFactoryPlacementReservationsAreClear(self.positionFloat3, self.tp, self.armyId, self.unitGettingBuilt) then
        return false
    end

    local minX, minY, maxX, maxY = PlacementUtils.GetPlacementBounds(
        self.positionFloat3, self.tp.skirtSize or self.tp.footprint)
    local min = EngineClasses.int2(minX, minY)
    local max = EngineClasses.int2(maxX, maxY)
    local _, results = Engine.GetGlobalGridCellFlags(_G.globalBuildingPlacementGridID, min, max)
    local isAlloy = Tags.ALLOYS_EXTRACTION[self.tp.general.tpId]
    local domain = PlacementUtils.GetPlacementDomain(self.tp)
    if self.tp.general.faDualWaterPlacement == true
        and not PlacementUtils.GetDualPlacementSurface(
            self.tp, self.positionFloat3.x, self.positionFloat3.z) then
        return false
    end

    for _, gridQueryResult in ipairs(results) do
        if not PlacementUtils.IsCellValidForPlacement(gridQueryResult.flags, domain, isAlloy) then
            return false
        end
    end

    local _, overlappingIDs = Engine.GetGlobalGridModifiers(_G.globalBuildingPlacementGridID, min, max, PlacementLayer.Default)
    
    local army = Armies[self.armyId]

    for _, overlappingID in ipairs(overlappingIDs) do
        local occupyingID = OverhaulFactoryReservationOwner(overlappingID) or overlappingID
        local overlappingUnit = GetUnitById(occupyingID)
        local isGlobalIDSameAsTargetUnit = false
        if self.unitGettingBuilt then
            if occupyingID.index == self.unitGettingBuilt.id.index and occupyingID.version == self.unitGettingBuilt.id.version then
                isGlobalIDSameAsTargetUnit = true
            end
        end
        
        if not isGlobalIDSameAsTargetUnit and overlappingUnit and overlappingUnit:IsIntelVisionVisible(army) then
            return false
        end
    end

    return true
end

function HostBuildOrder:ValidateOrder()
    if not self.unitGettingBuilt and not Armies[self.armyId]:HasUnitCapSpace() then
        return false
    end
    if (self.unitGettingBuilt and self.unitGettingBuilt.dead) or not self:IsOrderValid() then
        return false
    end

    return true
end

function HostBuildOrder:Delete()
    HostBaseOrder:Delete()

    -- Remove the unit if it is a placement ghost and was not started.
    if self.unitGettingBuilt and (not self.unitGettingBuilt.dead) and (self.unitGettingBuilt:GetFractionComplete() == 0) then
        self.unitGettingBuilt:Delete()
        self.unitGettingBuilt = nil
    end
end

-- SCO_HostWaterPlacement
-- The stock placement grid is terrain-agnostic for naval factories.  Keep
-- the normal host checks first, then require a wholly submerged footprint and
-- a submerged factory exit/rally lane for Seraphim naval factories.
local SCO_StockHostBuildOrderIsOrderValid = HostBuildOrder.IsOrderValid
local SCO_StockHostBuildOrderOrderStart = HostBuildOrder.OrderStart
local SCO_SeraphimWaterPlacementMargin = 0.05

local function SCO_RequiresSeraphimWaterPlacement(tp)
    return tp and tp.general and tp.general.requiresWaterPlacement == true
end

local function SCO_IsSeraphimWaterPoint(position, waterLevel)
    local _, terrainHeight = Engine.SampleTerrainHeight(position)
    return terrainHeight < waterLevel - SCO_SeraphimWaterPlacementMargin
end

local function SCO_HasSubmergedSeraphimFootprint(position, tp, waterLevel)
    local minX, minZ, maxX, maxZ = PlacementUtils.GetPlacementBounds(position, tp.skirtSize)
    for x = minX, maxX do
        for z = minZ, maxZ do
            local _, terrainHeight = Engine.SampleTerrainHeightFromCell(EngineClasses.int2(x, z))
            if terrainHeight >= waterLevel - SCO_SeraphimWaterPlacementMargin then
                return false
            end
        end
    end
    return true
end

local function SCO_HasUsableSeraphimNavalRollOff(position, tp, waterLevel)
    local construction = tp.construction
    for _, rollOff in ipairs((construction and construction.rollOffPoints) or {}) do
        local offset = rollOff.offset
        if offset then
            local spawnPoint = EngineClasses.float3(
                position.x + offset.x,
                waterLevel,
                position.z + offset.z
            )
            local rallyPoint = EngineClasses.float3(
                position.x + offset.x * 2,
                waterLevel,
                position.z + offset.z * 2
            )
            if SCO_IsSeraphimWaterPoint(spawnPoint, waterLevel)
                and SCO_IsSeraphimWaterPoint(rallyPoint, waterLevel)
            then
                return true
            end
        end
    end
    return false
end

local function SCO_CanPlaceSeraphimWaterFactory(position, tp)
    local _, hasWater = Engine.HasWater()
    if not hasWater then
        return false
    end

    local _, waterLevel = Engine.GetWaterLevel()
    return SCO_HasSubmergedSeraphimFootprint(position, tp, waterLevel)
        and SCO_HasUsableSeraphimNavalRollOff(position, tp, waterLevel)
end

function HostBuildOrder:IsOrderValid()
    if not SCO_StockHostBuildOrderIsOrderValid(self) then
        return false
    end
    if SCO_RequiresSeraphimWaterPlacement(self.tp) then
        return SCO_CanPlaceSeraphimWaterFactory(self.positionFloat3, self.tp)
    end
    return true
end

function HostBuildOrder:OrderStart()
    if SCO_RequiresSeraphimWaterPlacement(self.tp) then
        local _, hasWater = Engine.HasWater()
        if hasWater then
            local _, waterLevel = Engine.GetWaterLevel()
            self.positionFloat3 = EngineClasses.float3(
                self.positionFloat3.x,
                waterLevel,
                self.positionFloat3.z
            )
        end
    end
    return SCO_StockHostBuildOrderOrderStart(self)
end

-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0

-- Supreme Commander Overhaul dual land-water structures 1.0.0

-- Supreme Commander Overhaul sea parity 1.0.0
-- Final, narrow host authority for genuinely submerged naval factories. The
-- SCOM wrapper calls stock first and can never accept Water; this branch instead
-- preserves source depth and native water flags; occupancy is resolved separately.
local SCOSeaParityPreviousHostBuildOrderIsOrderValid = HostBuildOrder.IsOrderValid
local SCOSeaParityPreviousHostBuildOrderOrderStart = HostBuildOrder.OrderStart
local SCOSeaParityWaterPlacementIds = {
    ["ucl3701"] = true,
    ["ucl4003"] = true,
    ["uen3005"] = true,
    ["uen4001"] = true,
    ["ugn3005"] = true,
    ["ucs1513"] = true,
    ["ucs2513"] = true,
    ["ucs3513"] = true,
    ["uss1513"] = true,
    ["uss2513"] = true,
    ["uss3513"] = true,
    ["ues1513"] = true,
    ["ues2513"] = true,
    ["ues3513"] = true,
    ["ugs1513"] = true,
    ["ugs2513"] = true,
    ["ugs3513"] = true,
}
local SCOSeaParityWaterFactoryIds = {
    ["ucs1513"] = true,
    ["ucs2513"] = true,
    ["ucs3513"] = true,
    ["uss1513"] = true,
    ["uss2513"] = true,
    ["uss3513"] = true,
    ["ues1513"] = true,
    ["ues2513"] = true,
    ["ues3513"] = true,
    ["ugs1513"] = true,
    ["ugs2513"] = true,
    ["ugs3513"] = true,
}
local SCOSeaParityWaterMinimumDepth = {
    ["ucl3701"] = 1.5,
    ["ucl4003"] = 0,
    ["uen3005"] = 1.5,
    ["uen4001"] = 0,
    ["ugn3005"] = 1.5,
    ["ucs1513"] = 1.5,
    ["ucs2513"] = 1.5,
    ["ucs3513"] = 1.5,
    ["uss1513"] = 1.5,
    ["uss2513"] = 1.5,
    ["uss3513"] = 1.5,
    ["ues1513"] = 0.5,
    ["ues2513"] = 0.5,
    ["ues3513"] = 0.5,
    ["ugs1513"] = 1.5,
    ["ugs2513"] = 1.5,
    ["ugs3513"] = 1.5,
}
local SCOSeaParityDualLandWaterIds = {
    ["ucl3701"] = true,
    ["uen3005"] = true,
}

-- Supreme Commander Overhaul final naval placement depth 1.0.0
local function SCOSeaParityMinimumDepth(tp)
    local additions = tp and tp.additions
    local faContract = additions and additions.faSourceContract
    local authored = faContract and faContract.minimumWaterDepth
    if type(authored) == "number" and authored >= 0 then
        return authored
    end
    local id = tp and tp.general and tp.general.tpId
    return id and SCOSeaParityWaterMinimumDepth[id]
end
local function SCOSeaParityRequiresWater(tp)
    local id = tp and tp.general and tp.general.tpId
    return id ~= nil
        and SCOSeaParityWaterPlacementIds[id] == true
        and tp.general.requiresWaterPlacement == true
end

local function SCOSeaParityIsWaterFactory(tp)
    local id = tp and tp.general and tp.general.tpId
    return id ~= nil and SCOSeaParityWaterFactoryIds[id] == true
end

local function SCOSeaParityGetWaterLevel()
    local waterError, hasWater = Engine.HasWater()
    if waterError ~= EngineErrorCode.Success or not hasWater then return nil end
    local levelError, waterLevel = Engine.GetWaterLevel()
    if levelError ~= EngineErrorCode.Success then return nil end
    return waterLevel
end

local function SCOSeaParityWaterPlacementState(tp, position)
    if not SCOSeaParityRequiresWater(tp) then return false end
    local id = tp.general.tpId
    if not SCOSeaParityDualLandWaterIds[id] then return true end
    if position == nil then return nil end
    local waterError, hasWater = Engine.HasWater()
    if waterError ~= EngineErrorCode.Success then return nil end
    if not hasWater then return false end
    local levelError, waterLevel = Engine.GetWaterLevel()
    local terrainError, terrainHeight = Engine.SampleTerrainHeight(position)
    local minimumDepth = SCOSeaParityMinimumDepth(tp)
    if levelError ~= EngineErrorCode.Success or waterLevel == nil
        or terrainError ~= EngineErrorCode.Success or terrainHeight == nil
        or minimumDepth == nil
    then
        return nil
    end
    return terrainHeight <= waterLevel - minimumDepth
end

local function SCOSeaParityIsSubmergedPoint(position, waterLevel, minimumDepth)
    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)
    return errorCode == EngineErrorCode.Success
        and terrainHeight <= waterLevel - minimumDepth
end

local function SCOSeaParityHasUsableRolloffRoute(position, tp, waterLevel)
    local minimumDepth = SCOSeaParityMinimumDepth(tp)
    if minimumDepth == nil then return false end
    local routes = tp.construction and tp.construction.rollOffPoints
    local ramps = tp.additions and tp.additions.rollOffRamps
    if routes and #routes ~= 2 then return false end
    if ramps and #ramps ~= 2 then return false end
    if not routes and not ramps then return false end
    for index = 1, 2 do
        local route = routes and routes[index]
        local ramp = ramps and ramps[index]
        local routeOffset = route and route.offset or ramp and ramp.rampOffset
        local exitOffset = ramp and ramp.clearanceOffset
            or routeOffset and {
                x = (routeOffset.x or 0) * ((route and route.exitScale) or 2),
                z = (routeOffset.z or 0) * ((route and route.exitScale) or 2),
            }
        if routeOffset and exitOffset then
            local routePoint = EngineClasses.float3(
                position.x + (routeOffset.x or 0),
                waterLevel,
                position.z + (routeOffset.z or 0))
            local exitPoint = EngineClasses.float3(
                position.x + (exitOffset.x or 0),
                waterLevel,
                position.z + (exitOffset.z or 0))
            if SCOSeaParityIsSubmergedPoint(
                    routePoint, waterLevel, minimumDepth)
                and SCOSeaParityIsSubmergedPoint(
                    exitPoint, waterLevel, minimumDepth)
            then
                return true
            end
        end
    end
    return false
end

local function SCOSeaParityWaterGridIsClear(position, tp, waterLevel)
    local placementSize = tp.skirtSize or tp.footprint
    local id = tp and tp.general and tp.general.tpId
    local minimumDepth = SCOSeaParityMinimumDepth(tp)
    if placementSize == nil or minimumDepth == nil then return false end
    local minX, minY, maxX, maxY = PlacementUtils.GetPlacementBounds(
        position, placementSize)
    local min = EngineClasses.int2(minX, minY)
    local max = EngineClasses.int2(maxX, maxY)
    local errorCode, results = Engine.GetGlobalGridCellFlags(
        _G.globalBuildingPlacementGridID, min, max)
    local expectedCells = (maxX - minX + 1) * (maxY - minY + 1)
    if errorCode ~= EngineErrorCode.Success or #results ~= expectedCells then
        return false
    end
    for _, gridQueryResult in ipairs(results) do
        local flags = gridQueryResult.flags
        local allowed = bit.bor(PlacementLayer.Water, PlacementLayer.InvalidTerrain, PlacementLayer.Default)
        if bit.band(flags, PlacementLayer.Water) == 0
            or bit.band(flags, bit.bnot(allowed)) ~= 0
        then
            return false
        end
    end
    for x = minX, maxX do
        for z = minY, maxY do
            local terrainError, terrainHeight = Engine.SampleTerrainHeightFromCell(
                EngineClasses.int2(x, z))
            if terrainError ~= EngineErrorCode.Success
                or terrainHeight > waterLevel - minimumDepth
            then
                return false
            end
        end
    end
    return true, min, max
end

function HostBuildOrder:IsOrderValid()
    if not SCOSeaParityRequiresWater(self.tp) then
        return SCOSeaParityPreviousHostBuildOrderIsOrderValid(self)
    end
    local placementState = SCOSeaParityWaterPlacementState(
        self.tp, self.positionFloat3)
    if placementState == nil then return false end
    if not placementState then
        return SCO_StockHostBuildOrderIsOrderValid(self)
    end
    local waterLevel = SCOSeaParityGetWaterLevel()
    if waterLevel == nil then return false end
    if not OverhaulFactoryPlacementReservationsAreClear(
        self.positionFloat3, self.tp, self.armyId, self.unitGettingBuilt)
    then
        return false
    end
    local clear, min, max = SCOSeaParityWaterGridIsClear(
        self.positionFloat3, self.tp, waterLevel)
    if not clear
        or (SCOSeaParityIsWaterFactory(self.tp)
            and not SCOSeaParityHasUsableRolloffRoute(
                self.positionFloat3, self.tp, waterLevel))
    then
        return false
    end

    local overlapError, overlappingIDs = Engine.GetGlobalGridModifiers(
        _G.globalBuildingPlacementGridID, min, max, PlacementLayer.Default)
    if overlapError ~= EngineErrorCode.Success then return false end
    for _, overlappingID in ipairs(overlappingIDs) do
        local occupyingID = OverhaulFactoryReservationOwner(overlappingID)
            or overlappingID
        local overlappingUnit = GetUnitById(occupyingID)
        local isOwnGhost = self.unitGettingBuilt
            and occupyingID.index == self.unitGettingBuilt.id.index
            and occupyingID.version == self.unitGettingBuilt.id.version
        if not isOwnGhost and overlappingUnit
            and overlappingUnit:IsIntelVisionVisible(Armies[self.armyId])
        then
            return false
        end
    end
    return true
end

function HostBuildOrder:OrderStart()
    if not SCOSeaParityRequiresWater(self.tp) then
        return SCOSeaParityPreviousHostBuildOrderOrderStart(self)
    end
    local placementState = SCOSeaParityWaterPlacementState(
        self.tp, self.positionFloat3)
    if placementState == nil then
        error("Sea-parity water placement state became unavailable before OrderStart.")
    end
    if placementState then
        local waterLevel = SCOSeaParityGetWaterLevel()
        if waterLevel == nil then
            error("Sea-parity water level became unavailable before OrderStart.")
        end
        self.positionFloat3 = EngineClasses.float3(
            self.positionFloat3.x, waterLevel, self.positionFloat3.z)
    end
    return SCO_StockHostBuildOrderOrderStart(self)
end

-- SCOM mock Hydro placement 2.1.88.6
-- Do not add a deposit-only rejection or force a native ValidateOrder result.
do
    assert(type(HostBuildOrder) == "table" and type(HostBuildOrder.ValidateOrder) == "function",
        "SCOM mock Hydro: native host build-order validator is missing")
end
-- End SCOM mock Hydro placement 2.1.88.6
-- SCOM Field Fix: UEF naval minimum depth 0.5 host 1.0.0

-- A normal build order cannot bypass the installed source deposit requirement.
-- Creative/editor direct CreateUnit is a separate existing native path.
local SourceHydro=Import("common/systems/scoSourceHydroPlacement.lua")
local PreviousHydroValidateOrder=HostBuildOrder.ValidateOrder
function HostBuildOrder:ValidateOrder()
    if not SourceHydro.CanBuildNormally(self.tp) or not SourceHydro.CanBuildNormally(self.tpId) then return false end
    return PreviousHydroValidateOrder(self)
end
