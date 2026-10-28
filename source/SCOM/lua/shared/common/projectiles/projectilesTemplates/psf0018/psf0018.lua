ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "686a715a34f53ae0562fb128887f4b1b26337b5d44e2b41e140639b5a1bf1b7d",
["categories"] = { "CYBRAN", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 0,
["DestroyOnWater"] = true,
["InitialSpeed"] = 35,
["MaxSpeed"] = 45,
["MaxZigZag"] = 5,
["TrackTarget"] = true,
["TurnRate"] = 0,
["VelocityAlign"] = true,
["ZigZagFrequency"] = 1,
},
["sourceId"] = "cdfrocketiridium01",
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
["name"] = "cdfrocketiridium01",
["tpId"] = "psf0018",
},
["movement"] = {
["acceleration"] = 0,
["rotationSpeed"] = 0,
["speedMax"] = 45,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0018/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0018/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0018/LOD0/psf0018.sanmaterial",
["model"] = "Projectiles/psf0018/LOD0/psf0018.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0018.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0018")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/psf0018/ribbon_0.sanvfx",
}, {
["boneName"] = "SCO_SourceParticles",
["particleName"] = "VFX/SCOM/Source/psf0018/ribbon_particles.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceParticles"] = "VFX/SCOM/Source/psf0018/ribbon_particles.sanvfx",
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/psf0018/ribbon_0.sanvfx",
}
end
