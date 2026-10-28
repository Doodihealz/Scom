local Units = __Entities.Units

---@type MovementEventData[]
local movementEvents = {}

function MovementUpdate()
    Engine.GetMovementEvents(movementEvents)

    for i, data in ipairs(movementEvents) do
        local unit = GetUnitById(data.globalID)
        if unit then
            if data.type == MovementEventType.Aligned then
                unit:OnMovementAligned()
            elseif data.type == MovementEventType.AltitudeReached then
                unit:AltitudeReached() -- -> OnAltitudeReached (this is an event that is optionally handled/extended for different units)
            else
                unit:MoveIntoRangeBehaviorEnteredRange(data.type)
            end
        end
    end
end

function AnimationUpdate()
    for _, unit in pairs(Units) do
        unit:UpdateAnimations()
    end
end

----------------------------
-- Builders enter/exit range
----------------------------

-- Return a prop of the wreckage for rebuilding.
-- Must have the same x and z coordinate and tpId.
function GetWreckForRebuildingAtPosition(position, tpId)
    for _, prop in pairs(__Entities.Props) do
        if prop.isWreckage and prop.unitTpId == tpId then
            local pos = prop:GetPosition()
            if pos.x == position.x and pos.z == position.z then
                return prop
            end
        end
    end

    return nil
end

function WeaponsUpdate()
    for _, unit in pairs(Units) do
        if unit.weapons then
            for _, weapon in ipairs(unit.weapons) do
                weapon:Update()
            end
        end
    end
end
-- SCO_ApplySeraphimWaterHeights
-- Native preferred-altitude movement owns all aircraft and hover units.
-- Correct only authored surface-ship waterlines and explicit submarine depth
-- at the same bounded 10 Hz cadence used by the reviewed ocean reference.
local SCO_StockMovementUpdate = MovementUpdate
local SCO_SeraphimMovementUpdateInterval = 2
local SCO_SeraphimSubmergeDepth = 1.5

local function SCO_GetCachedSeraphimTerrainHeight(entry, position)
    if entry.terrainX ~= position.x
        or entry.terrainZ ~= position.z
        or entry.terrainHeight == nil
    then
        local _, terrainHeight = Engine.SampleTerrainHeight(position)
        entry.terrainX = position.x
        entry.terrainZ = position.z
        entry.terrainHeight = terrainHeight
    end
    return entry.terrainHeight
end

local function SCO_ApplySeraphimWaterHeights(registry)
    if registry == nil or next(registry) == nil then
        return
    end

    local waterResult, hasWater = Engine.HasWater()
    if waterResult ~= EngineErrorCode.Success or not hasWater then
        return
    end
    local levelResult, waterLevel = Engine.GetWaterLevel()
    if levelResult ~= EngineErrorCode.Success or waterLevel == nil then
        return
    end

    for index, entry in pairs(registry) do
        local unit = entry.unit
        if unit == nil
            or unit.dead
            or __Entities.Units[index] ~= unit
        then
            registry[index] = nil
        else
            local position = entry.position
            local positionResult =
                Engine.GetGlobalEntityWorldPosition(unit.id, position)
            local targetHeight = nil
            if positionResult == EngineErrorCode.Success
                and entry.movementType == "WaterSurface"
            then
                targetHeight = waterLevel + entry.waterlineOffset
            elseif positionResult == EngineErrorCode.Success
                and entry.movementType == "UnderWater"
            then
                local terrainHeight = SCO_GetCachedSeraphimTerrainHeight(entry, position)
                local submergeDepth = entry.submergeDepth or SCO_SeraphimSubmergeDepth
                targetHeight = math.max(terrainHeight + 0.1, waterLevel - submergeDepth)
            end

            if targetHeight ~= nil and math.abs(position.y - targetHeight) > 0.001 then
                position.y = targetHeight
                unit:SetPosition(position)
            end
        end
    end
end

function MovementUpdate()
    SCO_StockMovementUpdate()
    if Tick % SCO_SeraphimMovementUpdateInterval == 0 then
        SCO_ApplySeraphimWaterHeights(_G.SCO_SeraphimMovementUnits)
    end
end

-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0
