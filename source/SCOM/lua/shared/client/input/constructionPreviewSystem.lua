local bit = require("bit")
local MouseCursor = Import("client/input/mouseCursor.lua")
local buildmodeTemp = Import("client/input/buildmodeTemp.lua")
local PlacementUtils = Import("common/systems/placementUtils.lua")
local PlacementLayer = Import("common/layers.lua").PlacementLayer
local ResourceSpotUtils = Import("common/resourceSpot.lua")
local constructionGhostIDs = { }
local SCOSeaParityHasUsablePreviewRolloff
local function SCOSeaParityWaterCellIsClear(flags)
    local allowed = bit.bor(PlacementLayer.Water, PlacementLayer.InvalidTerrain)
    return bit.band(flags, PlacementLayer.Water) ~= 0
        and bit.band(flags, bit.bnot(allowed)) == 0
end

local SCOSeaParityWaterPlacementIds = {
    ["ucl3701"] = true,
    ["ucl4003"] = true,
    ["ucs1513"] = true,
    ["ucs2513"] = true,
    ["ucs3513"] = true,
    ["uen3005"] = true,
    ["uen4001"] = true,
    ["ues1513"] = true,
    ["ues2513"] = true,
    ["ues3513"] = true,
    ["ugn3005"] = true,
    ["ugs1513"] = true,
    ["ugs2513"] = true,
    ["ugs3513"] = true,
    ["uss1513"] = true,
    ["uss2513"] = true,
    ["uss3513"] = true,
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
    ["ucs1513"] = 1.5,
    ["ucs2513"] = 1.5,
    ["ucs3513"] = 1.5,
    ["uen3005"] = 1.5,
    ["uen4001"] = 0,
    ["ues1513"] = 0.5,
    ["ues2513"] = 0.5,
    ["ues3513"] = 0.5,
    ["ugn3005"] = 1.5,
    ["ugs1513"] = 1.5,
    ["ugs2513"] = 1.5,
    ["ugs3513"] = 1.5,
    ["uss1513"] = 1.5,
    ["uss2513"] = 1.5,
    ["uss3513"] = 1.5,
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
local function SCOSeaParityIsWaterPlacement(tp)
    local id = tp and tp.general and tp.general.tpId
    return id ~= nil
        and SCOSeaParityWaterPlacementIds[id] == true
        and tp.general.requiresWaterPlacement == true
end

local function SCOSeaParityIsWaterFactory(tp)
    local id = tp and tp.general and tp.general.tpId
    return id ~= nil and SCOSeaParityWaterFactoryIds[id] == true
end

local function SCOSeaParityPlacementSize(tp)
    if not tp then return nil end
    if SCOSeaParityIsWaterPlacement(tp) then
        return tp.skirtSize or tp.footprint
    end
    return tp.skirtSize
end

local function SCOSeaParityWaterPlacementState(tp, position)
    if not SCOSeaParityIsWaterPlacement(tp) then return false end
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

local function SCOSeaParityCellIsDeepEnough(tp, cell, waterLevel)
    local id = tp and tp.general and tp.general.tpId
    local minimumDepth = SCOSeaParityMinimumDepth(tp)
    if minimumDepth == nil then return false end
    local errorCode, terrainHeight = Engine.SampleTerrainHeightFromCell(cell)
    return errorCode == EngineErrorCode.Success
        and terrainHeight <= waterLevel - minimumDepth
end

local constructionGridTileIDs = { }

local function WalkBetweenPoints(x0, z0, x1, z1, sizeX, sizeZ, positions)
    x0 = math.truncateToInt(x0)
    x1 = math.truncateToInt(x1)
    z0 = math.truncateToInt(z0)
    z1 = math.truncateToInt(z1)

    local dx = math.abs(x1 - x0)
    local sx = x0 < x1 and 1 or -1
    local dz = math.abs(z1 - z0)
    local sz = z0 < z1 and 1 or -1
    local err = dx - dz

    local lastAddX = x0
    local lastAddZ = z0

    table.insert(positions, { x = x0, z = z0 })

    while x0 ~= x1 or z0 ~= z1 do
        local e2 = 2 * err

        if e2 > -dz then
            err = err - dz
            x0 = x0 + sx
        end

        if e2 < dx then
            err = err + dx
            z0 = z0 + sz
        end

        if (math.abs(x0 - lastAddX) >= sizeX or math.abs(z0 - lastAddZ) >= sizeZ) then
            table.insert(positions, { x = x0, z = z0 })
            lastAddX = x0
            lastAddZ = z0
        end
    end
end

function CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor)
    local min = EngineClasses.int2(minX, minY)
    local max = EngineClasses.int2(maxX, maxY)
    local results = {}
    Engine.GetLocalGridCellFlags(_G.localBuildingPlacementGridID, min, max, results)

    for _, gridQueryResult in ipairs(results) do
        if not PlacementUtils.IsCellValidForPlacement(gridQueryResult.flags, domain, isAlloyExtractor)
            or bit.band(gridQueryResult.flags, PlacementLayer.Default) ~= 0 then
            return false
        end
    end

    return true
end

-- Supreme Commander Overhaul Structures Cache Patcher 1.6.1
-- Factory models reserve a narrow side exit lane in addition to their measured core.
local function OverhaulFactoryPlacementReservationsAreClear(position, tp)
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
        local waterPlacementState = SCOSeaParityWaterPlacementState(tp, position)
        if waterPlacementState == nil then return false end
        local isWaterPlacement = waterPlacementState == true
        if isWaterPlacement then
            local waterError, hasWater = Engine.HasWater()
            local levelError, waterLevel = Engine.GetWaterLevel()
            local results = {}
            local flagsError = Engine.GetLocalGridCellFlags(
                _G.localBuildingPlacementGridID,
                EngineClasses.int2(minX, minY),
                EngineClasses.int2(maxX, maxY),
                results)
            local expectedCells = (maxX - minX + 1) * (maxY - minY + 1)
            if waterError ~= EngineErrorCode.Success or not hasWater
                or levelError ~= EngineErrorCode.Success
                or flagsError ~= EngineErrorCode.Success
                or #results ~= expectedCells
            then
                return false
            end
            for _, result in ipairs(results) do
                if not SCOSeaParityWaterCellIsClear(result.flags) then return false end
            end
            for x = minX, maxX do
                for z = minY, maxY do
                    if not SCOSeaParityCellIsDeepEnough(
                        tp, EngineClasses.int2(x, z), waterLevel) then
                        return false
                    end
                end
            end
        elseif not CanPlaceAtArea(minX, minY, maxX, maxY, PlacementUtils.GetPlacementDomain(tp), false) then
            return false
        end
    end

    return true
end
-- SCO_ClientWaterPlacement
-- Mirrors the host's narrow water-factory rule for local ghosts.  HostBuildOrder
-- remains authoritative; this only prevents misleading green placement cells.
local SCO_ClientWaterPlacementMargin = 0.05

local function SCO_RequiresSeraphimWaterPlacement(tp)
    return tp and tp.general and tp.general.requiresWaterPlacement == true
end

local function SCO_GetSeraphimWaterLevel()
    local _, hasWater = Engine.HasWater()
    if not hasWater then
        return nil
    end
    local _, waterLevel = Engine.GetWaterLevel()
    return waterLevel
end

local function SCO_IsSeraphimSubmergedCell(cell, waterLevel)
    local _, terrainHeight = Engine.SampleTerrainHeightFromCell(cell)
    return terrainHeight < waterLevel - SCO_ClientWaterPlacementMargin
end

local function SCO_IsSeraphimSubmergedPoint(position, waterLevel)
    local _, terrainHeight = Engine.SampleTerrainHeight(position)
    return terrainHeight < waterLevel - SCO_ClientWaterPlacementMargin
end

local function SCO_HasSubmergedSeraphimBounds(minX, minZ, maxX, maxZ, waterLevel)
    for x = minX, maxX do
        for z = minZ, maxZ do
            if not SCO_IsSeraphimSubmergedCell(EngineClasses.int2(x, z), waterLevel) then
                return false
            end
        end
    end
    return true
end

local function SCO_HasUsableSeraphimNavalRollOff(tp, position, waterLevel)
    local minX, minZ, maxX, maxZ = PlacementUtils.GetPlacementBounds(position, SCOSeaParityPlacementSize(tp))
    if not SCO_HasSubmergedSeraphimBounds(minX, minZ, maxX, maxZ, waterLevel) then
        return false
    end

    for _, rollOff in ipairs((tp.construction and tp.construction.rollOffPoints) or {}) do
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
            if SCO_IsSeraphimSubmergedPoint(spawnPoint, waterLevel)
                and SCO_IsSeraphimSubmergedPoint(rallyPoint, waterLevel)
            then
                return true
            end
        end
    end
    return false
end

local function SCO_CanPlaceSeraphimWaterFactory(tp, position)
    local waterLevel = SCO_GetSeraphimWaterLevel()
    return waterLevel ~= nil and SCO_HasUsableSeraphimNavalRollOff(tp, position, waterLevel)
end

local function SCO_GetSeraphimWaterPlacementHeight(position, terrainHeight)
    return SCO_GetSeraphimWaterLevel() or terrainHeight
end

local SCO_StockCanPlaceAtArea = CanPlaceAtArea
function CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor, tp, position)
    if tp and tp.general.faDualWaterPlacement == true
        and (not position or not PlacementUtils.GetDualPlacementSurface(tp, position.x, position.z)) then
        return false
    end
    if SCO_RequiresSeraphimWaterPlacement(tp)
        and not SCO_CanPlaceSeraphimWaterFactory(tp, position)
    then
        return false
    end
    return SCO_StockCanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor)
end
function FindClosestResourceSpot(position)
    local buildTemplateID = buildmodeTemp.GetBuildTpId()
    local unitTemplate = __Templates.Units[buildTemplateID]
    local closestSpot = nil
    local closestDistance = 8 -- 8 Is the max snapping distance
    local domain = PlacementUtils.GetPlacementDomain(unitTemplate)

    for _, resourceSpot in pairs(ResourceSpotUtils.resourceSpots) do
        local spotPosition = resourceSpot:GetPosition()
        spotPosition.x = math.truncateToInt(spotPosition.x)
        spotPosition.z = math.truncateToInt(spotPosition.z)
        local distance = math.sqrt((position.x - spotPosition.x) ^ 2 + (position.z - spotPosition.z) ^ 2)
        local minX, minY, maxX, maxY = PlacementUtils.GetPlacementBounds(spotPosition, SCOSeaParityPlacementSize(unitTemplate))

        if distance < closestDistance and CanPlaceAtArea(minX, minY, maxX, maxY, domain, true, unitTemplate, spotPosition) then
            closestDistance = distance
            closestSpot = spotPosition
        end
    end

    return closestSpot
end

function RemoveExistingConstructionGhosts()
    for _, ghostID in pairs(constructionGhostIDs) do
        Engine.SetRangeRingsEnabled(ghostID, false)
        Engine.DeletePrefabInstance(ghostID)
    end
    table.clear(constructionGhostIDs)

    for _, tileID in pairs(constructionGridTileIDs) do
        Engine.DeletePrefabInstance(tileID)
    end
    table.clear(constructionGridTileIDs)
end

function GetBuildingPlacementPositions(includeInvalid)
    local startPosition = buildmodeTemp.GetStartPosition()

    if not startPosition then
        startPosition = MouseCursor.GetMousePosition()
        startPosition.x = math.truncateToInt(startPosition.x)
        startPosition.z = math.truncateToInt(startPosition.z)
    end

    local buildingPositions = { }
    local buildTemplateID = buildmodeTemp.GetBuildTpId()
    local isAlloyExtractor = Tags.ALLOYS_EXTRACTION[buildTemplateID]
    local unitTemplate = __Templates.Units[buildTemplateID]
    
    if isAlloyExtractor then
        local closestSpot = FindClosestResourceSpot(startPosition)
        local targetPosition

        if closestSpot then
            targetPosition = closestSpot
        else
            local currentPosition = MouseCursor.GetMousePosition()
            currentPosition.x = math.truncateToInt(currentPosition.x)
            currentPosition.z = math.truncateToInt(currentPosition.z)
            targetPosition = currentPosition
        end

        table.insert(buildingPositions, targetPosition)
    else
        local endingPosition = MouseCursor.GetMousePosition()
        WalkBetweenPoints(startPosition.x, startPosition.z, endingPosition.x, endingPosition.z, SCOSeaParityPlacementSize(unitTemplate).x, SCOSeaParityPlacementSize(unitTemplate).y, buildingPositions)
    end

    local filteredPositions = { }

    local mapSizeX = GameInfo.MapInfo.size[1]
    local mapSizeY = GameInfo.MapInfo.size[2]
    local domain = PlacementUtils.GetPlacementDomain(unitTemplate)

    for _, point in pairs(buildingPositions) do
        point = PlacementUtils.SnapToBuildGrid(unitTemplate, point)
        local minX, minY, maxX, maxY = PlacementUtils.GetPlacementBounds(point, SCOSeaParityPlacementSize(unitTemplate))
        local isWithinMapBounds = minX >= 0 and minY >= 0 and maxX <= mapSizeX and maxY <= mapSizeY

        if isWithinMapBounds then
            if includeInvalid or (CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor, unitTemplate, point) and OverhaulFactoryPlacementReservationsAreClear(point, unitTemplate)) then
                local targetHeight = PlacementUtils.GetPlacementHeight(unitTemplate, point.x, point.z)
                if SCOSeaParityWaterPlacementState(unitTemplate, point) == true then
                    targetHeight = SCO_GetSeraphimWaterPlacementHeight(point, targetHeight)
                end
                table.insert(filteredPositions, EngineClasses.float3(point.x, targetHeight, point.z))
            end
        end
    end

    return filteredPositions
end

function UpdateConstructionPreview()
    RemoveExistingConstructionGhosts()

    if buildmodeTemp.GetBuildMode() then
        local positions = GetBuildingPlacementPositions(true)
        local unitTemplate = __Templates.Units[buildmodeTemp.GetBuildTpId()]
        local buildTemplateID = unitTemplate.general.placementGhostPrefabID
        local isAlloyExtractor = Tags.ALLOYS_EXTRACTION[buildmodeTemp.GetBuildTpId()]
        local domain = PlacementUtils.GetPlacementDomain(unitTemplate)

        for _, position in pairs(positions) do
            local minX, minZ = PlacementUtils.GetPlacementBounds(
                position, SCOSeaParityPlacementSize(unitTemplate))

            -- Read before creating new ghosts as the ghosts will also modify the grid
            local dualSiteIsValid = unitTemplate.general.faDualWaterPlacement ~= true
                or PlacementUtils.GetDualPlacementSurface(unitTemplate, position.x, position.z) ~= nil
            local hasInvalidCells = false
            local waterPlacementState = SCOSeaParityWaterPlacementState(unitTemplate, position)
            local isWaterPlacement = waterPlacementState == true
            local waterLevel = isWaterPlacement and SCO_GetSeraphimWaterLevel() or nil
            local waterRollOffIsValid = waterPlacementState ~= nil
                and (not isWaterPlacement
                or not SCOSeaParityIsWaterFactory(unitTemplate)
                or (waterLevel ~= nil and SCOSeaParityHasUsablePreviewRolloff(unitTemplate, position, waterLevel)))
            local cellIsValid = {}
            for x = 1, SCOSeaParityPlacementSize(unitTemplate).x do
                cellIsValid[x] = {}
                for y = 1, SCOSeaParityPlacementSize(unitTemplate).y do
                    local cellCoord = EngineClasses.int2(minX + x - 1, minZ + y - 1)
                    local results = {}

                    Engine.GetLocalGridCellFlags(_G.localBuildingPlacementGridID, cellCoord, cellCoord, results)

                    local isValid = PlacementUtils.IsCellValidForPlacement(results[1].flags, domain, isAlloyExtractor)
                        and bit.band(results[1].flags, PlacementLayer.Default) == 0
                    if isWaterPlacement then
                        local flags = results[1].flags
                        isValid = waterRollOffIsValid
                            and waterLevel ~= nil
                            and SCOSeaParityWaterCellIsClear(flags)
                            and SCOSeaParityCellIsDeepEnough(
                                unitTemplate, cellCoord, waterLevel)
                    end
                    isValid = isValid and dualSiteIsValid
                    cellIsValid[x][y] = isValid
                    if not isValid then
                        hasInvalidCells = true
                    end
                end
            end

            if not OverhaulFactoryPlacementReservationsAreClear(position, unitTemplate) then
                hasInvalidCells = true
            end

            local _, ghostID = Engine.InstantiatePrefab(buildTemplateID, position, EngineClasses.float3(1.0, 1.0, 1.0), GetIdentityQuaternion())
            -- SCOM Field Fix: construction preview team color 1.0.0
            local previewArmy = Armies[GetFocusArmy()]
            if previewArmy then
                Engine.SetRendererInstanceData0(ghostID, previewArmy:GetColor())
            end
            table.insert(constructionGhostIDs, ghostID)

            Engine.SetIconsEnabled(ghostID, false)
            Engine.SetRangeRingsEnabled(ghostID, true)

            local tileScale = EngineClasses.float3(1.0, 1.0, 1.0)
            local tileRotation = GetIdentityQuaternion()

            for x = 1, SCOSeaParityPlacementSize(unitTemplate).x do
                for y = 1, SCOSeaParityPlacementSize(unitTemplate).y do
                    local isValid = cellIsValid[x][y]

                    local tilePrefabID = _G.PlacementGridTilePrefabIDOn
                    if not isValid then
                        tilePrefabID = _G.PlacementGridTilePrefabIDOff
                    elseif hasInvalidCells then
                        tilePrefabID = _G.PlacementGridTilePrefabIDNeutral
                    end

                    local tilePosition = EngineClasses.float3(minX + x - 0.5, position.y, minZ + y - 0.5)
                    local _, tileID = Engine.InstantiatePrefab(tilePrefabID, tilePosition, tileScale, tileRotation)
                    table.insert(constructionGridTileIDs, tileID)
                end
            end
        end
    end
end


-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0

-- Sanctuary Construction Plans 2.1.0
local SCO_StockUpdateConstructionPreview = UpdateConstructionPreview
local SCO_InvalidBuildTemplateWarningShown = false

function UpdateConstructionPreview()
    if buildmodeTemp.GetBuildMode() then
        local tpId = buildmodeTemp.GetBuildTpId()
        local unitTemplate = tpId and __Templates.Units[tpId] or nil
        if not unitTemplate or not SCOSeaParityPlacementSize(unitTemplate) then
            buildmodeTemp.SetBuildMode(false)
            if not SCO_InvalidBuildTemplateWarningShown then
                SCO_InvalidBuildTemplateWarningShown = true
                Engine.UI_AddLogText(
                    "Construction: cancelled an invalid build template instead of breaking the UI.",
                    5)
            end
            return
        end
    end

    return SCO_StockUpdateConstructionPreview()
end


-- Supreme Commander Overhaul sea parity 1.0.0
-- Preview equivalent of the final host validator. Deep water carries both Water
-- and InvalidTerrain; resources, reservations and occupied cells remain blocked.
local SCOSeaParityPreviousCanPlaceAtArea = CanPlaceAtArea
local function SCOSeaParityPreviewRequiresWater(tp)
    return SCOSeaParityIsWaterPlacement(tp)
end

local function SCOSeaParityPreviewWaterLevel()
    local waterError, hasWater = Engine.HasWater()
    if waterError ~= EngineErrorCode.Success or not hasWater then return nil end
    local levelError, waterLevel = Engine.GetWaterLevel()
    if levelError ~= EngineErrorCode.Success then return nil end
    return waterLevel
end

local function SCOSeaParityPreviewPointIsSubmerged(tp, position, waterLevel)
    local minimumDepth = SCOSeaParityMinimumDepth(tp)
    if minimumDepth == nil then return false end
    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)
    return errorCode == EngineErrorCode.Success
        and terrainHeight <= waterLevel - minimumDepth
end

SCOSeaParityHasUsablePreviewRolloff = function(tp, position, waterLevel)
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
            if SCOSeaParityPreviewPointIsSubmerged(
                    tp, routePoint, waterLevel)
                and SCOSeaParityPreviewPointIsSubmerged(
                    tp, exitPoint, waterLevel)
            then
                return true
            end
        end
    end
    return false
end

function CanPlaceAtArea(minX, minY, maxX, maxY, domain, isAlloyExtractor, tp, position)
    if not SCOSeaParityPreviewRequiresWater(tp) then
        return SCOSeaParityPreviousCanPlaceAtArea(
            minX, minY, maxX, maxY, domain, isAlloyExtractor, tp, position)
    end
    local placementState = SCOSeaParityWaterPlacementState(tp, position)
    if placementState == nil then return false end
    if not placementState then
        return SCO_StockCanPlaceAtArea(
            minX, minY, maxX, maxY, domain, isAlloyExtractor)
    end
    if isAlloyExtractor or position == nil then return false end
    local waterLevel = SCOSeaParityPreviewWaterLevel()
    if waterLevel == nil
        or (SCOSeaParityIsWaterFactory(tp)
            and not SCOSeaParityHasUsablePreviewRolloff(
                tp, position, waterLevel))
    then
        return false
    end

    local min = EngineClasses.int2(minX, minY)
    local max = EngineClasses.int2(maxX, maxY)
    local results = {}
    local errorCode = Engine.GetLocalGridCellFlags(
        _G.localBuildingPlacementGridID, min, max, results)
    local expectedCells = (maxX - minX + 1) * (maxY - minY + 1)
    if errorCode ~= EngineErrorCode.Success or #results ~= expectedCells then
        return false
    end
    for _, gridQueryResult in ipairs(results) do
        if not SCOSeaParityWaterCellIsClear(gridQueryResult.flags) then return false end
    end
    for x = minX, maxX do
        for z = minY, maxY do
            if not SCOSeaParityCellIsDeepEnough(
                tp, EngineClasses.int2(x, z), waterLevel) then
                return false
            end
        end
    end
    return true
end
--Only for annotataions
-- Normal construction uses no green/valid preview for an unsupported deposit.
-- DebugUI/Creative spawning bypasses this normal construction-preview module.
local SourceHydro=Import("common/systems/scoSourceHydroPlacement.lua")
local SourceHydroBuildMode=Import("client/input/buildmodeTemp.lua")
local PreviousHydroPositions=GetBuildingPlacementPositions
function GetBuildingPlacementPositions(includeInvalid)
    if not SourceHydro.CanBuildNormally(SourceHydroBuildMode.GetBuildTpId()) then return {} end
    return PreviousHydroPositions(includeInvalid)
end
local PreviousHydroCanPlace=CanPlaceAtArea
function CanPlaceAtArea(...)
    if not SourceHydro.CanBuildNormally(SourceHydroBuildMode.GetBuildTpId()) then return false end
    return PreviousHydroCanPlace(...)
end

return {
    UpdateConstructionPreview = UpdateConstructionPreview
}
-- Supreme Commander Overhaul dual land-water structures 1.0.0

-- Supreme Commander Overhaul FA build-box parity 1.0.0
-- SCOM Field Fix: UEF naval minimum depth 0.5 preview 1.0.0
