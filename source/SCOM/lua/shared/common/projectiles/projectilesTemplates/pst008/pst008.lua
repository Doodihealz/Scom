---@type ProjectileTemplate
ProjectileTemplate = {
    ["additions"] = {
    ["scoTacticalProjectile"] = {
    ["acceleration"] = 90,
    ["collisionRadius"] = 0,
    ["destroyOnWater"] = false,
    ["health"] = 1,
    ["interceptor"] = true,
    ["lifetime"] = 3,
    ["maxSpeed"] = 90,
    ["sourceId"] = "SIMAntiMissile01",
    ["split"] = false,
    ["steppedTurn"] = false,
    ["tactical"] = false,
    ["track"] = true,
    ["turnRate"] = 720,
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
    ["name"] = "SIMAntiMissile01",
    ["tpId"] = "pst008",
},
    ["movement"] = {
    ["acceleration"] = 90,
    ["alignToVelocity"] = true,
    ["gravityMultiplier"] = 0,
    ["rotationSpeed"] = 720,
    ["speedMax"] = 90,
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
    ["particleName"] = "VFX/SCOM/Source/pst008/impact_land.sanvfx",
} },
} },
    ["persistantEffects"] = { {
    ["effects"] = { {
    ["particleName"] = "VFX/SCOM/Source/pst008/trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.pst008.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="pst008")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/pst008/ribbon_0.sanvfx",
}, {
["boneName"] = "SCO_SourceRibbon_1",
["particleName"] = "VFX/SCOM/Source/pst008/ribbon_1.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/pst008/ribbon_0.sanvfx",
["SCO_SourceRibbon_1"] = "VFX/SCOM/Source/pst008/ribbon_1.sanvfx",
}
end
