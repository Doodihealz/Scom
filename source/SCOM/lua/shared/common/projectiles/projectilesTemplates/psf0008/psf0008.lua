ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "273548f5789b3096765d0ab2ba0c21158a7df2a9e8334a3d78bd30d5ced4bf62",
["categories"] = { "CYBRAN", "PROJECTILE", "ANTIAIR" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 2,
["DestroyOnWater"] = true,
["InitialSpeed"] = 15,
["LeadTarget"] = false,
["Lifetime"] = 4,
["MaxSpeed"] = 25,
["MaxZigZag"] = 2,
["OnLostTargetLifetime"] = 0.7,
["RotationalVelocityRange"] = 200,
["TrackTarget"] = true,
["TurnRate"] = 80,
["UseGravity"] = false,
["VelocityAlign"] = true,
["ZigZagFrequency"] = 0.2,
},
["sourceId"] = "caananodart01",
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
["name"] = "caananodart01",
["tpId"] = "psf0008",
},
["movement"] = {
["acceleration"] = 2,
["rotationSpeed"] = 80,
["speedMax"] = 25,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0008/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0008/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0008/LOD0/psf0008.sanmaterial",
["model"] = "Projectiles/psf0008/LOD0/psf0008.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0008.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0008")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/psf0008/ribbon_0.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/psf0008/ribbon_0.sanvfx",
}
end
