local bit = require("bit")

---@enum CollisionLayer A layer mask that a collider can use withihn a collision world to exclude collisions.
CollisionLayer = {
    None = 0,
    Units = 1,
    Shields = 2,
    Projectiles = 4,
    PlacementGhost = 8,
    Props = 16,
    -- SCOM Field Fix: Supreme Commander artillery water layer 1.0.0
    Water = 32,

    -- Bitmask where all bits are enabled.
    All = bit.lshift(1, 32)   -- 0xFFFFFFFF (4294967295)
}

---@enum PlacementLayer The layers available for placement, used as a mask
PlacementLayer = {
    None = 0,
    Default = 1,
    InvalidTerrain = 2,
    ResourceSpot = 4,
    Water = 8
}

---@enum PlacementDomain Where a template may be placed.
PlacementDomain = {
    Land  = 1,
    Water = 2,
    Any   = 3,
}

---Gets the placement domain for a template, from its physical layer tag.
---@param tp Template
---@return integer A PlacementDomain.
function GetPlacementDomainFromTemplate(tp)
    if tp.general.faDualWaterPlacement == true then
        return PlacementDomain.Any
    end
    if Tags.NAVAL[tp.general.tpId] and not Tags.NAVAL_TECH_CENTRE[tp.general.tpId] then
        return PlacementDomain.Water
    end

    return PlacementDomain.Land
end

---@enum TargetingLayer Targeting layers an entity can occupy, used as a bitmask
TargetingLayer = {
    None          = 0,
    Seabed        = 1,
    Water         = 2,
    WaterSurface  = 4,
    Land          = 8,
    Air           = 16,
    LandedAir     = 32,
}

local TargetingLayerByName = {
    None         = TargetingLayer.None,
    Seabed       = TargetingLayer.Seabed,
    Water        = TargetingLayer.Water,
    WaterSurface = TargetingLayer.WaterSurface,
    Land         = TargetingLayer.Land,
    Air          = TargetingLayer.Air,
    LandedAir    = TargetingLayer.LandedAir,
}

---Converts a list of layer name strings from a template into a TargetingLayer bitmask.
---@param list string[]
---@return integer
function TargetingLayerMaskFromList(list)
    local mask = TargetingLayer.None
    for _, name in ipairs(list) do
        mask = bit.bor(mask, TargetingLayerByName[name] or TargetingLayer.None)
    end
    return mask
end

---@enum NavigationLayer 
NavigationLayer = {
    Invalid = 255, -- Used when a template has no movement or an unrecognized movement type.
}

--- All created navigation layers.
NavigationLayers = {}

--- Maps a unit template's movement.type to the NAME of the navigation layer it should occupy.
local NavigationLayerByName = {
    Plane            = "Air",
    Gunship          = "Air",
    LegsLand         = "Land",
    TracksLand       = "Land",
    Hover            = "Hover",
    LegsSeabed       = "Amphibious",
    TracksSeabed     = "Amphibious",
    UnderWater       = "Submarine",
    TracksWater      = "Sea",
    WaterSurface     = "Sea",
    TracksAmphibious = "Amphibious",
    LegsAmphibious   = "Amphibious",
}

---Gets a navigation layer index by name. Falls back to Land (with a warning) if the
---named layer isn't created.
---@param name string A navigation layer name, e.g. "Land", "Air", "Submarine".
---@return integer
function GetNavigationLayerByName(name)
    local index = NavigationLayers[name]
    if index ~= nil then
        return index
    end

    Warn("Navigation layer '" .. tostring(name) .. "' is not created for this map; falling back to Land.")
    return NavigationLayers.Land or NavigationLayer.Invalid
end

---Gets the navigation layer index for a unit based on its movement type in the template. Buildings are
---always placed on the Land layer.
---@param tp Template
---@return integer
function GetDefaultNavigationLayerFromTemplate(tp)
    if tp.tags ~= nil and table.find(tp.tags, "STRUCTURE") then
        return GetNavigationLayerByName("Land")
    end

    if tp.movement == nil then
        return NavigationLayer.Invalid
    end

    local name = NavigationLayerByName[tp.movement.type]
    if name == nil then
        Warn(string.format("GetDefaultNavigationLayerFromTemplate: template '%s' has unrecognized movement type '%s'; falling back to Land.",
            tp.general.tpId, tostring(tp.movement.type)))
        name = "Land"
    end

    return GetNavigationLayerByName(name)
end

---Gets the names of every navigation layer created for this map, optionally excluding some.
---@param excluded table<string, boolean>|nil Layer names to leave out.
---@return string[]
local function GetNavigationLayerNames(excluded)
    local names = {}
    for name, _ in pairs(NavigationLayers) do
        if excluded == nil or not excluded[name] then
            table.insert(names, name)
        end
    end
    table.sort(names, function(a, b) return NavigationLayers[a] < NavigationLayers[b] end)
    return names
end

---Gets the names of all navigation layers created for this map.
---@return string[]
function GetAllNavigationLayerNames()
    return GetNavigationLayerNames(nil)
end

---Gets the names of all navigation layers a structure should block. Structures do not block Air.
---@return string[]
function GetStructureNavigationLayerNames()
    return GetNavigationLayerNames({ Air = true })
end

---@enum MovementCollisionLayer Collision-avoidance layer bits, used as a mask.
MovementCollisionLayer = {
    None        = 0,
    LandSmall   = bit.lshift(1, 0),
    LandLarge   = bit.lshift(1, 1),
    SeabedSmall = bit.lshift(1, 2),
    SeabedLarge = bit.lshift(1, 3),
    Sea         = bit.lshift(1, 4),
    Submarine   = bit.lshift(1, 5),
    Air         = bit.lshift(1, 6),
    AirLarge    = bit.lshift(1, 7),
}

---Converts a list of MovementCollisionLayer name strings from a template (e.g.
---`{ "LandSmall", "Sea" }`) into a collision-avoidance bitmask.
---@param list string[]
---@return integer
function MovementCollisionLayerMaskFromList(list)
    local mask = MovementCollisionLayer.None
    for _, name in ipairs(list) do
        local layerBit = MovementCollisionLayer[name]
        if layerBit == nil then
            Warn("MovementCollisionLayerMaskFromList: unknown movement collision layer '" .. tostring(name) .. "'.")
        else
            mask = bit.bor(mask, layerBit)
        end
    end
    return mask
end

GroundedMovementConfig = {
    referenceAltitude      = ReferenceAltitude.Ground,
    preferredAltitude      = 0,
    terrainAlignmentFactor = 1,
    maxBankDegrees         = 0,
}


-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0

-- Only for annotations
return {
    CollisionLayer = CollisionLayer,
    PlacementLayer = PlacementLayer,
    PlacementDomain = PlacementDomain,
    GetPlacementDomainFromTemplate = GetPlacementDomainFromTemplate,
    TargetingLayer = TargetingLayer,
    TargetingLayerMaskFromList = TargetingLayerMaskFromList,
    NavigationLayer = NavigationLayer,
    NavigationLayers = NavigationLayers,
    GetNavigationLayerByName = GetNavigationLayerByName,
    GetDefaultNavigationLayerFromTemplate = GetDefaultNavigationLayerFromTemplate,
    GetAllNavigationLayerNames = GetAllNavigationLayerNames,
    GetStructureNavigationLayerNames = GetStructureNavigationLayerNames,
    MovementCollisionLayer = MovementCollisionLayer,
    MovementCollisionLayerMaskFromList = MovementCollisionLayerMaskFromList,
    GroundedMovementConfig = GroundedMovementConfig
}

-- Supreme Commander Overhaul dual land-water structures 1.0.0
