---@type ProjectileTemplate
ProjectileTemplate = {
    ["additions"] = {
    ["scoTacticalProjectile"] = {
    ["acceleration"] = 0,
    ["collisionRadius"] = 0,
    ["destroyOnWater"] = true,
    ["health"] = 1,
    ["interceptor"] = true,
    ["lifetime"] = 3,
    ["maxSpeed"] = 100,
    ["sourceId"] = "TDPhalanx01",
    ["split"] = false,
    ["steppedTurn"] = false,
    ["tactical"] = false,
    ["track"] = false,
    ["turnRate"] = 0,
    ["version"] = "1.0.0",
},
},
    ["collisionInfo"] = {
    ["centerOffset"] = {
    ["x"] = 0,
    ["y"] = 0,
    ["z"] = 0,
},
    ["collisionSize"] = {
    ["x"] = 0.1,
    ["y"] = 0.1,
    ["z"] = 0.1,
},
},
    ["general"] = {
    ["name"] = "TDPhalanx01",
    ["tpId"] = "pst006",
},
    ["movement"] = {
    ["acceleration"] = 0,
    ["alignToVelocity"] = true,
    ["gravityMultiplier"] = 0,
    ["rotationSpeed"] = 0,
    ["speedMax"] = 100,
    ["type"] = "LeadStaticPosition",
},
    ["nonUniformScale"] = {
    ["x"] = 1,
    ["y"] = 1,
    ["z"] = 1,
},
    ["visuals"] = {
    ["mesh"] = {
    ["lod0distance"] = 150,
},
    ["onImpactEffects"] = { {
    ["effects"] = { {
    ["particleName"] = "VFX/SCOM/Source/pst006/impact_land.sanvfx",
} },
} },
    ["persistantEffects"] = { {
    ["effects"] = { {
    ["particleName"] = "VFX/SCOM/Source/pst006/trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.pst006.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="pst006")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/pst006/ribbon_0.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/pst006/ribbon_0.sanvfx",
}
end
