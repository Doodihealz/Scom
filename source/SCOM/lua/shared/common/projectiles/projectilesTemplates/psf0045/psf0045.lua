ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "248e24c30379edeec047740234224a4cb53faf5b4150007156988b9b4bf5e5c4",
["categories"] = { "AEON", "PROJECTILE", "ANTIAIR" },
["defense"] = {

},
["physics"] = {
["CollideEntity"] = true,
["CollideSurface"] = true,
["DestroyOnWater"] = true,
["DetonateAboveHeight"] = 8,
["InitialSpeed"] = 20,
["LeadTarget"] = false,
["RotationalVelocity"] = 0,
["StayUpright"] = true,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "aaafizz01",
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
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
["general"] = {
["name"] = "aaafizz01",
["tpId"] = "psf0045",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0045/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0045/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0045/LOD0/psf0045.sanmaterial",
["model"] = "Projectiles/psf0045/LOD0/psf0045.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0045.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0045")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/psf0045/ribbon_0.sanvfx",
}, {
["boneName"] = "SCO_SourceParticles",
["particleName"] = "VFX/SCOM/Source/psf0045/ribbon_particles.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceParticles"] = "VFX/SCOM/Source/psf0045/ribbon_particles.sanvfx",
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/psf0045/ribbon_0.sanvfx",
}
end
