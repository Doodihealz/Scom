---@type ProjectileTemplate
ProjectileTemplate = {
    ["additions"] = {
    ["scoTacticalProjectile"] = {
    ["acceleration"] = 3,
    ["collisionRadius"] = 2,
    ["destroyOnWater"] = true,
    ["health"] = 2,
    ["interceptor"] = false,
    ["lifetime"] = 30,
    ["maxSpeed"] = 12,
    ["sourceId"] = "AIFMissileTactical01",
    ["split"] = false,
    ["steppedTurn"] = true,
    ["tactical"] = true,
    ["track"] = true,
    ["turnRate"] = 8,
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
    ["name"] = "AIFMissileTactical01",
    ["tpId"] = "pst002",
},
    ["movement"] = {
    ["acceleration"] = 3,
    ["alignToVelocity"] = true,
    ["gravityMultiplier"] = 0,
    ["rotationSpeed"] = 8,
    ["speedMax"] = 12,
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
    ["persistantEffects"] = { {
    ["effects"] = { {
    ["particleName"] = "VFX/SCOM/Source/pst002/trail.sanvfx",
} },
} },
    ["scoProjectileMesh"] = {
    ["material"] = "Projectiles/pst002/LOD0/pst002.sanmaterial",
    ["model"] = "Projectiles/pst002/LOD0/pst002.sanmodel",
    ["scale"] = {
    ["x"] = 1,
    ["y"] = 1,
    ["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.pst002.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="pst002")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/pst002/ribbon_0.sanvfx",
}, {
["boneName"] = "SCO_SourceParticles",
["particleName"] = "VFX/SCOM/Source/pst002/ribbon_particles.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceParticles"] = "VFX/SCOM/Source/pst002/ribbon_particles.sanvfx",
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/pst002/ribbon_0.sanvfx",
}
end
