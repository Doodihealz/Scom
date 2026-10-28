local bit = require("bit")
local Layers = Import("common/layers.lua")
local Water = Import("common/water.lua")
local PlacementLayer = Layers.PlacementLayer
local PlacementDomain = Layers.PlacementDomain

--- How far below the water level every corner of a cell must sit for it to carry
--- PlacementLayer.Water, i.e. to be deep enough to float a naval structure.
NavalPlacementDepth = 0.1

function GetPlacementBounds(position, skirtSize)
    local minX = math.floor(position.x) - math.floor(skirtSize.x / 2)
    local minY = math.floor(position.z) - math.floor(skirtSize.y / 2)
    local maxX = minX + skirtSize.x - 1
    local maxY = minY + skirtSize.y - 1
    return minX, minY, maxX, maxY
end

-- Center a structure on the native integer cells without changing their bounds.
-- Odd skirts have a half-cell center; even skirts have an integer center.
function SnapToBuildGrid(tp, position)
    local size = tp and tp.skirtSize
    if not size or not size.x or not size.y or size.x <= 0 or size.y <= 0 then
        return position
    end
    return EngineClasses.float3(
        math.floor(position.x) + (size.x % 2) * 0.5,
        position.y or 0,
        math.floor(position.z) + (size.y % 2) * 0.5)
end

---Tests one placement grid cell against a template's placement domain.
---@param flags integer Combined PlacementLayer mask for the cell.
---@param domain integer The PlacementDomain of the template being placed.
---@param isAlloy boolean True if the template is an alloy extractor.
---@return boolean
function IsCellValidForPlacement(flags, domain, isAlloy)
    if domain == PlacementDomain.Water then
        if bit.band(flags, PlacementLayer.Water) == 0 then
            return false
        end
    elseif domain == PlacementDomain.Any then
        if bit.band(flags, PlacementLayer.InvalidTerrain) ~= 0
            and bit.band(flags, PlacementLayer.Water) == 0 then
            return false
        end
    else
        if bit.band(flags, PlacementLayer.InvalidTerrain) ~= 0 then
            return false
        end
    end

    if isAlloy then
        return bit.band(flags, PlacementLayer.ResourceSpot) ~= 0
    end

    return bit.band(flags, PlacementLayer.ResourceSpot) == 0
end

---Gets a template's placement domain.
---@param tp Template
---@return integer A PlacementDomain.
function GetPlacementDomain(tp)
    if tp == nil or tp.general == nil then
        return PlacementDomain.Land
    end

    local domain = tp.general.placementDomain
    if domain == nil then
        domain = Layers.GetPlacementDomainFromTemplate(tp)
        tp.general.placementDomain = domain
    end

    return domain
end

---Gets the world height a template should be placed at. Water structures sit on the water surface;
---everything else sits on the terrain.
---@param tp Template
---@param x number
---@param z number
---@return number
--- Classify an FA land-water structure's entire build skirt. A shallow or
--- shoreline-straddling footprint has no valid height and must be rejected.
function GetDualPlacementSurface(tp, x, z)
    if not (tp and tp.general and tp.general.faDualWaterPlacement == true) then
        return nil
    end

    local waterError, hasWater = Engine.HasWater()
    if waterError ~= EngineErrorCode.Success then return nil end
    if not hasWater then return PlacementDomain.Land end
    local levelError, waterLevel = Engine.GetWaterLevel()
    if levelError ~= EngineErrorCode.Success or waterLevel == nil then return nil end

    local minX, minZ, maxX, maxZ = GetPlacementBounds(
        { x = x, z = z }, tp.skirtSize)
    local allLand, allWater = true, true
    for cellX = minX, maxX + 1 do
        for cellZ = minZ, maxZ + 1 do
            local errorCode, terrainHeight = Engine.SampleTerrainHeightFromCell(
                EngineClasses.int2(cellX, cellZ))
            if errorCode ~= EngineErrorCode.Success or terrainHeight == nil then
                return nil
            end
            if terrainHeight < waterLevel then allLand = false end
            if terrainHeight > waterLevel - 1 then allWater = false end
        end
    end
    if allWater then return PlacementDomain.Water end
    if allLand then return PlacementDomain.Land end
    return nil
end

function GetPlacementHeight(tp, x, z)
    if GetPlacementDomain(tp) == PlacementDomain.Water
        or GetDualPlacementSurface(tp, x, z) == PlacementDomain.Water then
        local waterLevel = Water.GetLevel()
        if waterLevel ~= nil then
            return waterLevel
        end

        Warn(string.format(
            "GetPlacementHeight: water template '%s' placed on a map with hasWater = false; "
            .. "falling back to terrain height. Naval placement cannot work on this map.",
            tostring(tp.general and tp.general.tpId)))
    end

    local _, terrainHeight = Engine.SampleTerrainHeight(EngineClasses.float3(x, 0, z))
    return terrainHeight
end

-- Only for annotations
return {
    NavalPlacementDepth = NavalPlacementDepth,
    GetPlacementBounds = GetPlacementBounds,
    SnapToBuildGrid = SnapToBuildGrid,
    IsCellValidForPlacement = IsCellValidForPlacement,
    GetPlacementDomain = GetPlacementDomain,
    GetDualPlacementSurface = GetDualPlacementSurface,
    GetPlacementHeight = GetPlacementHeight
}

-- Supreme Commander Overhaul dual land-water structures 1.0.0

-- Supreme Commander Overhaul FA build-box parity 1.0.0
