-- Sanctuary Construction Plans 2.1.0
-- Bounded client placement. Every structure remains an ordinary
-- Sanctuary BUILD order independently validated by the host.
local bit = require("bit")
local MAX_ENTRIES = 20
local MAX_OFFSET = 8192
local PREVIEW_REFRESH_SECONDS = 0.1
local TempBuildMode = Import("client/input/buildmodeTemp.lua")
local MouseCursor = Import("client/input/mouseCursor.lua")
local SelectionSystem = Import("client/input/selectionSystem.lua")
local ClientOrderManager = Import("client/managers/orders/clientOrderManager.lua")
local OrderTasks = Import("common/commonOrders.lua").OrderTasks
local PredictedUnit = Import("client/entities/predictedUnit.lua").PredictedUnit
local Layers = Import("common/layers.lua")
local PlacementLayer = Layers.PlacementLayer
local PlacementDomain = Layers.PlacementDomain
local PlacementUtils = Import("common/systems/placementUtils.lua")

local activePlan = nil
local planGhosts = {}
local previewAnchorX = nil
local previewAnchorZ = nil
local nextPreviewRefreshTime = nil
local previewReuseUnavailable = false

local function Notify(text)
    Engine.UI_AddLogText("Construction Plans: " .. text, 5)
end

local function IsFiniteNumber(value, maximumMagnitude)
    return type(value) == "number"
        and value == value
        and math.abs(value) <= maximumMagnitude
end

local function IsFiniteInteger(value, maximumMagnitude)
    return IsFiniteNumber(value, maximumMagnitude)
        and value == math.floor(value)
end

local function IsFiniteCoordinate(value, maximumMagnitude)
    return IsFiniteNumber(value, maximumMagnitude)
end

local function IsDenseArray(value, maximumLength)
    if type(value) ~= "table"
        or #value > maximumLength then
        return false
    end

    local count = 0
    for key in pairs(value) do
        if type(key) ~= "number"
            or key ~= math.floor(key)
            or key < 1
            or key > #value then
            return false
        end
        count = count + 1
    end
    return count == #value
end

local function IsPlanBuilder(unit)
    if not unit or not unit.tp or not unit.tp.general then
        return false
    end
    local tpId = unit.tp.general.tpId
    return unit.armyId == GetFocusArmy()
        and unit.IsCompleted
        and unit:IsCompleted()
        and (Tags.ENGINEER[tpId]
            or Tags.COMMAND[tpId]
            or Tags.ENGINEERING_STATION[tpId])
end

local function IsPlanEntry(entry)
    local tpId = entry and entry.tpId
    local template = tpId and __Templates.Units[tpId]
    local skirt = template and template.skirtSize
    return type(tpId) == "string"
        and #tpId > 0
        and #tpId <= 64
        and string.match(tpId, "^[%w_%-]+$") ~= nil
        and template
        and template.general
        and template.general.placementGhostPrefabID
        and skirt
        and IsFiniteInteger(skirt.x, 128)
        and IsFiniteInteger(skirt.y, 128)
        and skirt.x > 0
        and skirt.y > 0
        and Tags.STRUCTURE[tpId]
        and not Tags.ALLOYS_EXTRACTION[tpId]
        and IsFiniteCoordinate(entry.dx, MAX_OFFSET)
        and IsFiniteCoordinate(entry.dz, MAX_OFFSET)
end

local function AddArea(areas, position, size)
    if type(size) ~= "table"
        or not IsFiniteInteger(size.x, 128)
        or not IsFiniteInteger(size.y, 128)
        or size.x <= 0
        or size.y <= 0 then
        return false
    end

    local minX, minZ, maxX, maxZ =
        PlacementUtils.GetPlacementBounds(position, size)
    table.insert(areas, {
        minX = minX,
        minZ = minZ,
        maxX = maxX,
        maxZ = maxZ,
    })
    return true
end

local function GetTemplateAreas(position, template)
    if not template or not template.skirtSize then
        return nil
    end

    local areas = {}
    if not AddArea(areas, position, template.skirtSize) then
        return nil
    end

    local additions = template.additions
    local reservations = additions and additions.placementReservations or {}
    if not IsDenseArray(reservations, 16) then
        return nil
    end
    for _, reservation in ipairs(reservations) do
        if type(reservation) ~= "table" then
            return nil
        end
        local offset = reservation.offset or {}
        if type(offset) ~= "table"
            or not IsFiniteInteger(offset.x or 0, 128)
            or not IsFiniteInteger(offset.z or 0, 128)
            or not AddArea(
                areas,
                EngineClasses.float3(
                    position.x + (offset.x or 0),
                    position.y or 0,
                    position.z + (offset.z or 0)),
                reservation.size) then
            return nil
        end
    end
    return areas
end

local function AreasOverlap(first, second)
    return first.minX <= second.maxX
        and second.minX <= first.maxX
        and first.minZ <= second.maxZ
        and second.minZ <= first.maxZ
end

local function EntriesOverlap(first, second)
    local firstTemplate = __Templates.Units[first.tpId]
    local secondTemplate = __Templates.Units[second.tpId]
    local firstAreas = GetTemplateAreas(
        EngineClasses.float3(first.dx, 0, first.dz),
        firstTemplate)
    local secondAreas = GetTemplateAreas(
        EngineClasses.float3(second.dx, 0, second.dz),
        secondTemplate)
    if not firstAreas or not secondAreas then
        return true
    end
    for _, firstArea in ipairs(firstAreas) do
        for _, secondArea in ipairs(secondAreas) do
            if AreasOverlap(firstArea, secondArea) then
                return true
            end
        end
    end
    return false
end

local function CopyPlan(plan)
    if type(plan) ~= "table"
        or not IsDenseArray(plan.entries, MAX_ENTRIES)
        or #plan.entries == 0 then
        return nil
    end

    local copied = {}
    for _, entry in ipairs(plan.entries) do
        if not IsPlanEntry(entry) then
            return nil
        end
        table.insert(copied, {
            tpId = entry.tpId,
            dx = entry.dx,
            dz = entry.dz,
        })
    end
    for firstIndex = 1, #copied do
        for secondIndex = firstIndex + 1, #copied do
            if EntriesOverlap(copied[firstIndex], copied[secondIndex]) then
                return nil
            end
        end
    end
    return copied
end

local function GetCompatibleBuilders(entries, units)
    local compatible = {}
    for _, unit in pairs(units or {}) do
        if IsPlanBuilder(unit) then
            local canBuildAll = true
            for _, entry in ipairs(entries) do
                local callSucceeded, canBuild =
                    pcall(buildQueueUtils.CanBuild, unit, entry.tpId, nil, true)
                if not callSucceeded or not canBuild then
                    canBuildAll = false
                    break
                end
            end
            if canBuildAll then
                table.insert(compatible, unit)
            end
        end
    end
    return compatible
end

function CanBuildEntries(entries, units)
    local copied = CopyPlan({ entries = entries })
    return copied ~= nil and #GetCompatibleBuilders(copied, units) > 0
end

local function RemovePreview()
    for _, ghost in pairs(planGhosts) do
        Engine.SetRangeRingsEnabled(ghost.id, false)
        Engine.DeletePrefabInstance(ghost.id)
    end
    table.clear(planGhosts)
    previewAnchorX = nil
    previewAnchorZ = nil
    nextPreviewRefreshTime = nil
end

-- Sanctuary Construction Plans naval water placement 1.0.0
local function RequiresWaterPlacement(template)
    return template
        and template.general
        and template.general.requiresWaterPlacement == true
end

local function GetMinimumWaterDepth(template)
    local additions = template and template.additions
    local faContract = additions and additions.faSourceContract
    local authored = faContract and faContract.minimumWaterDepth
    if type(authored) == "number" and authored >= 0 then
        return authored
    end
    return 1.5
end

local function IsClearArea(area, template)
    local min = EngineClasses.int2(area.minX, area.minZ)
    local max = EngineClasses.int2(area.maxX, area.maxZ)
    local results = {}
    local errorCode = Engine.GetLocalGridCellFlags(
        _G.localBuildingPlacementGridID,
        min,
        max,
        results)
    local expectedCells =
        (area.maxX - area.minX + 1) * (area.maxZ - area.minZ + 1)
    if errorCode ~= EngineErrorCode.Success or #results ~= expectedCells then
        return false
    end
    local domain = RequiresWaterPlacement(template)
        and PlacementDomain.Water or PlacementUtils.GetPlacementDomain(template)
    for _, result in ipairs(results) do
        if not PlacementUtils.IsCellValidForPlacement(result.flags, domain, false)
            or bit.band(result.flags, PlacementLayer.Default) ~= 0 then
            return false
        end
    end
    return true
end

local function GetWaterLevel()
    local hasWaterErrorCode, hasWater = Engine.HasWater()
    if hasWaterErrorCode ~= EngineErrorCode.Success or not hasWater then
        return nil
    end
    local waterLevelErrorCode, waterLevel = Engine.GetWaterLevel()
    if waterLevelErrorCode ~= EngineErrorCode.Success then
        return nil
    end
    return waterLevel
end

local function IsSubmergedCell(cell, waterLevel, minimumDepth)
    local errorCode, terrainHeight = Engine.SampleTerrainHeightFromCell(cell)
    return errorCode == EngineErrorCode.Success
        and terrainHeight <= waterLevel - minimumDepth
end

local function IsSubmergedPoint(position, waterLevel, minimumDepth)
    local errorCode, terrainHeight = Engine.SampleTerrainHeight(position)
    return errorCode == EngineErrorCode.Success
        and terrainHeight <= waterLevel - minimumDepth
end

local function CanPlaceWaterFactory(template, position)
    if not RequiresWaterPlacement(template) then
        return true
    end

    local waterLevel = GetWaterLevel()
    local minimumDepth = GetMinimumWaterDepth(template)
    if not waterLevel or minimumDepth == nil then
        return false
    end
    local minX, minZ, maxX, maxZ =
        PlacementUtils.GetPlacementBounds(position, template.skirtSize)
    for x = minX, maxX do
        for z = minZ, maxZ do
            if not IsSubmergedCell(
                EngineClasses.int2(x, z),
                waterLevel,
                minimumDepth) then
                return false
            end
        end
    end

    local construction = template.construction
    local additions = template.additions
    local routes = construction and construction.rollOffPoints
    local ramps = additions and additions.rollOffRamps
    if routes and (not IsDenseArray(routes, 2) or #routes ~= 2) then
        return false
    end
    if ramps and (not IsDenseArray(ramps, 2) or #ramps ~= 2) then
        return false
    end
    if not routes and not ramps then
        return false
    end
    for index = 1, 2 do
        local route = routes and routes[index]
        local ramp = ramps and ramps[index]
        local routeOffset = route and route.offset or ramp and ramp.rampOffset
        local exitOffset = ramp and ramp.clearanceOffset
            or routeOffset and {
                x = (routeOffset.x or 0) * ((route and route.exitScale) or 2),
                z = (routeOffset.z or 0) * ((route and route.exitScale) or 2),
            }
        if type(routeOffset) == "table"
            and type(exitOffset) == "table"
            and IsFiniteNumber(routeOffset.x or 0, 128)
            and IsFiniteNumber(routeOffset.z or 0, 128)
            and IsFiniteNumber(exitOffset.x or 0, 256)
            and IsFiniteNumber(exitOffset.z or 0, 256) then
            local routePoint = EngineClasses.float3(
                position.x + (routeOffset.x or 0),
                waterLevel,
                position.z + (routeOffset.z or 0))
            local exitPoint = EngineClasses.float3(
                position.x + (exitOffset.x or 0),
                waterLevel,
                position.z + (exitOffset.z or 0))
            if IsSubmergedPoint(routePoint, waterLevel, minimumDepth)
                and IsSubmergedPoint(exitPoint, waterLevel, minimumDepth) then
                return true
            end
        end
    end
    return false
end

local function GetPlacementHeight(template, point)
    if RequiresWaterPlacement(template)
        or PlacementUtils.GetPlacementDomain(template) == PlacementDomain.Water then
        local waterLevel = GetWaterLevel()
        return waterLevel or 0, waterLevel ~= nil
    end
    local terrainErrorCode, terrainHeight =
        Engine.SampleTerrainHeight(EngineClasses.float3(point.x, 0, point.z))
    if terrainErrorCode ~= EngineErrorCode.Success then
        return 0, false
    end
    return terrainHeight, true
end

local function GetPlacementEntries(anchor)
    if not activePlan then
        return {}, false
    end

    anchor = anchor or MouseCursor.GetMousePosition()
    anchor.x = math.truncateToInt(anchor.x)
    anchor.z = math.truncateToInt(anchor.z)
    local entries = {}
    local allValid = true
    local mapSizeX = GameInfo.MapInfo.size[1]
    local mapSizeZ = GameInfo.MapInfo.size[2]

    -- Read every stock/reservation cell before creating plan ghosts.
    for _, entry in ipairs(activePlan.entries) do
        local template = __Templates.Units[entry.tpId]
        local point = {
            x = anchor.x + entry.dx,
            z = anchor.z + entry.dz,
        }
        point = PlacementUtils.SnapToBuildGrid(template, point)
        local placementHeight, heightValid = GetPlacementHeight(template, point)
        local position = EngineClasses.float3(
            point.x,
            placementHeight,
            point.z)
        local areas = GetTemplateAreas(position, template)
        local valid = heightValid
            and areas ~= nil
            and CanPlaceWaterFactory(template, position)
        for _, area in ipairs(areas or {}) do
            local withinBounds = area.minX >= 0
                and area.minZ >= 0
                and area.maxX <= mapSizeX
                and area.maxZ <= mapSizeZ
            if not withinBounds or not IsClearArea(area, template) then
                valid = false
            end
        end
        table.insert(entries, {
            tpId = entry.tpId,
            position = position,
            areas = areas or {},
            valid = valid,
        })
        if not valid then
            allValid = false
        end
    end

    -- A single grid read cannot see the other not-yet-issued plan
    -- entries, so reject core or factory-reservation overlap here.
    for firstIndex = 1, #entries do
        for secondIndex = firstIndex + 1, #entries do
            for _, firstArea in ipairs(entries[firstIndex].areas) do
                for _, secondArea in ipairs(entries[secondIndex].areas) do
                    if AreasOverlap(firstArea, secondArea) then
                        entries[firstIndex].valid = false
                        entries[secondIndex].valid = false
                        allValid = false
                    end
                end
            end
        end
    end
    return entries, allValid
end

local function SetGhostGrid(ghostID, template, valid)
    for x = 1, template.skirtSize.x do
        for z = 1, template.skirtSize.y do
            local boneID = {}
            Engine.GetLocalBone(ghostID, "Grid" .. x .. " " .. z .. "On", boneID)
            Engine.SetRendererEnabled(boneID, valid)
            Engine.GetLocalBone(ghostID, "Grid" .. x .. " " .. z .. "Off", boneID)
            Engine.SetRendererEnabled(boneID, not valid)
            Engine.GetLocalBone(ghostID, "Grid" .. x .. " " .. z .. "Neutral", boneID)
            Engine.SetRendererEnabled(boneID, false)
        end
    end
end

local function CreatePrediction(entry, builders, builderArmyId, shouldAppend)
    local template = __Templates.Units[entry.tpId]
    local payload = { tpId = entry.tpId, armyId = builderArmyId }
    local iconColor = Armies[builderArmyId]:GetColor()
    iconColor.w = PlacementGhostIconAlpha
    local _, predictedUnitLocalID = Engine.InstantiatePrefab(
        template.general.placementGhostPrefabID,
        entry.position,
        EngineClasses.float3(1, 1, 1),
        GetIdentityQuaternion())
    Engine.SetIconColor(predictedUnitLocalID, 0, iconColor)
    _G.PredictedUnits[predictedUnitLocalID.index] =
        PredictedUnit(predictedUnitLocalID, GetFocusArmy(), template)
    payload.predictedUnitLocalID = predictedUnitLocalID
    ClientOrderManager.ClientIssueOrder(
        OrderTasks.BUILD,
        builders,
        shouldAppend,
        entry.position,
        payload,
        function(accepted, newUnitGlobalID)
            local predictedUnit =
                _G.PredictedUnits[predictedUnitLocalID.index]
            if accepted and predictedUnit and newUnitGlobalID then
                local targetUnit = _G.GetUnitById(newUnitGlobalID)
                if targetUnit then
                    local transferSucceeded = pcall(function()
                        targetUnit.predictedBuildQueue =
                            predictedUnit.predictedBuildQueue
                        targetUnit.predictedBuildQueueIdCounter =
                            predictedUnit.predictedBuildQueueIdCounter
                        local units = {
                            [newUnitGlobalID.index] = targetUnit,
                        }
                        for queueIndex, queueItem in ipairs(
                            predictedUnit.predictedBuildQueue) do
                            Import("common/commands/definitions/buildQueue.lua")
                                .RequestQueueAmountForUnits(
                                    units,
                                    queueItem.tpId,
                                    queueItem.count,
                                    queueIndex)
                        end
                    end)
                    if not transferSucceeded then
                        Notify("a predicted build queue could not be transferred.")
                    end
                end
            end
            if predictedUnit then
                predictedUnit:Delete()
            end
        end)
end

function Begin(plan, selectedUnits, sourceSlot, sourceRevision)
    local copied = CopyPlan(plan)
    if not copied or #GetCompatibleBuilders(copied, selectedUnits) == 0 then
        return false
    end
    Cancel()
    TempBuildMode.SetBuildMode(false)
    activePlan = {
        entries = copied,
        sourceSlot = sourceSlot,
        sourceRevision = sourceRevision,
    }
    Notify("plan ready: left-click a clear area to place it; right-click cancels.")
    return true
end

function IsActive()
    return activePlan ~= nil
end

function Cancel()
    activePlan = nil
    RemovePreview()
    previewReuseUnavailable = false
end

function CancelIfSourceSlot(slot, revision)
    if not activePlan
        or activePlan.sourceSlot ~= slot
        or activePlan.sourceRevision ~= revision then
        return false
    end
    Cancel()
    return true
end

function OnMouseLeftDown()
    return false
end

function OnMouseLeftUp(isAppendingToQueue)
    if not MouseCursor.IsCursorInGameView() or Engine.IsMouseOverUI() then
        return false
    end

    RemovePreview()
    local plan = activePlan
    if not plan then
        return false
    end
    local entries, allValid = GetPlacementEntries()
    local compatibleBuilders =
        GetCompatibleBuilders(plan.entries, SelectionSystem.GetSelectedUnits())
    local placeable = {}
    for _, entry in ipairs(entries) do
        if entry.valid then
            table.insert(placeable, entry)
        end
    end
    if #entries == 0
        or #placeable == 0
        or #compatibleBuilders == 0 then
        Notify("placement is blocked or the selected builders are no longer compatible.")
        return false
    end

    local builderArmyId = compatibleBuilders[1].armyId
    local shouldAppend = isAppendingToQueue == true
    for _, entry in ipairs(placeable) do
        CreatePrediction(
            entry,
            compatibleBuilders,
            builderArmyId,
            shouldAppend)
        shouldAppend = true
    end
    if not allValid then
        Notify("submitted " .. #placeable .. "/" .. #entries
            .. " build orders; " .. (#entries - #placeable) .. " blocked.")
    end
    if not isAppendingToQueue then
        Cancel()
    end
    return false
end

function OnMouseRightDown()
    return false
end

function OnMouseRightUp()
    Cancel()
    if MouseCursor.IsCursorInGameView() and not Engine.IsMouseOverUI() then
        Notify("plan placement cancelled.")
    end
    return false
end

local function CreatePreviewGhost(entry, visualOnly)
    local template = __Templates.Units[entry.tpId]
    local errorCode, ghostID = Engine.InstantiatePrefab(
        template.general.placementGhostPrefabID,
        entry.position,
        EngineClasses.float3(1, 1, 1),
        GetIdentityQuaternion())
    if errorCode ~= EngineErrorCode.Success or not ghostID then
        return nil
    end
    if visualOnly then
        local disableCode = Engine.SetLocalGridModifierEnabled(ghostID, false)
        local readCode, enabled = Engine.GetLocalGridModifierEnabled(ghostID)
        if disableCode ~= EngineErrorCode.Success
            or readCode ~= EngineErrorCode.Success or enabled then
            Engine.DeletePrefabInstance(ghostID)
            return nil
        end
    end
    Engine.SetIconsEnabled(ghostID, false)
    Engine.SetRangeRingsEnabled(ghostID, true)
    SetGhostGrid(ghostID, template, entry.valid)
    return {
        id = ghostID,
        valid = entry.valid,
        x = entry.position.x,
        y = entry.position.y,
        z = entry.position.z,
    }
end

local function DrawLegacyPreview(entries)
    for _, entry in ipairs(entries) do
        local ghost = CreatePreviewGhost(entry, false)
        if ghost then
            table.insert(planGhosts, ghost)
        end
    end
end

function UpdatePreview()
    if not activePlan then
        return
    end

    local anchor = MouseCursor.GetMousePosition()
    anchor.x = math.truncateToInt(anchor.x)
    anchor.z = math.truncateToInt(anchor.z)
    if previewReuseUnavailable then
        RemovePreview()
        DrawLegacyPreview(GetPlacementEntries(anchor))
        return
    end

    local now = Engine.GetCurrentRealtimeInSeconds()
    local anchorChanged = anchor.x ~= previewAnchorX
        or anchor.z ~= previewAnchorZ
    if not anchorChanged and nextPreviewRefreshTime
        and type(now) == "number"
        and now == now
        and now < nextPreviewRefreshTime then
        return
    end

    -- Preview ghosts are visual only: their own grid modifiers must not
    -- contaminate later occupancy checks while the prefabs are retained.
    local entries = GetPlacementEntries(anchor)
    for index, entry in ipairs(entries) do
        local ghost = planGhosts[index]
        if not ghost then
            ghost = CreatePreviewGhost(entry, true)
            if not ghost then
                previewReuseUnavailable = true
                RemovePreview()
                DrawLegacyPreview(entries)
                return
            end
            planGhosts[index] = ghost
        else
            if ghost.x ~= entry.position.x
                or ghost.y ~= entry.position.y
                or ghost.z ~= entry.position.z then
                if Engine.SetLocalEntityLocalPosition(ghost.id, entry.position)
                    ~= EngineErrorCode.Success then
                    previewReuseUnavailable = true
                    RemovePreview()
                    DrawLegacyPreview(entries)
                    return
                end
                ghost.x = entry.position.x
                ghost.y = entry.position.y
                ghost.z = entry.position.z
            end
            if ghost.valid ~= entry.valid then
                SetGhostGrid(ghost.id, __Templates.Units[entry.tpId], entry.valid)
                ghost.valid = entry.valid
            end
        end
    end
    previewAnchorX = anchor.x
    previewAnchorZ = anchor.z
    nextPreviewRefreshTime = type(now) == "number" and now == now
        and now + PREVIEW_REFRESH_SECONDS or nil
end

return {
    Begin = Begin,
    Cancel = Cancel,
    CancelIfSourceSlot = CancelIfSourceSlot,
    CanBuildEntries = CanBuildEntries,
    IsActive = IsActive,
    OnMouseLeftDown = OnMouseLeftDown,
    OnMouseLeftUp = OnMouseLeftUp,
    OnMouseRightDown = OnMouseRightDown,
    OnMouseRightUp = OnMouseRightUp,
    UpdatePreview = UpdatePreview,
}
