ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "04afccb1d468735670d21c86ce383178907398c9bd65a88324cafc4fffb9d293",
["categories"] = { "CYBRAN", "PROJECTILE", "ANTIAIR", "MISSILE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 5,
["DestroyOnWater"] = true,
["InitialSpeed"] = 30,
["LeadTarget"] = false,
["Lifetime"] = 3,
["MaxSpeed"] = 35,
["MaxZigZag"] = 5,
["OnLostTargetLifetime"] = 0.7,
["TrackTarget"] = true,
["TurnRate"] = 400,
["UseGravity"] = false,
["VelocityAlign"] = true,
["ZigZagFrequency"] = 0.5,
},
["sourceId"] = "caamissilenanite03",
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
["name"] = "caamissilenanite03",
["tpId"] = "psf0007",
},
["movement"] = {
["acceleration"] = 5,
["rotationSpeed"] = 400,
["speedMax"] = 35,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0007/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0007/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0007/LOD0/psf0007.sanmaterial",
["model"] = "Projectiles/psf0007/LOD0/psf0007.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0007.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0007")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/psf0007/ribbon_0.sanvfx",
}, {
["boneName"] = "SCO_SourceParticles",
["particleName"] = "VFX/SCOM/Source/psf0007/ribbon_particles.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceParticles"] = "VFX/SCOM/Source/psf0007/ribbon_particles.sanvfx",
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/psf0007/ribbon_0.sanvfx",
}
end
