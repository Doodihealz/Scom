ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "e3afd2627d64bf5fc3ba6ec4b5831e3829acf123315911c9a9b123c7214bfd64",
["categories"] = { "CYBRAN", "PROJECTILE", "ANTIAIR" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 6,
["DestroyOnWater"] = true,
["InitialSpeed"] = 20,
["LeadTarget"] = false,
["Lifetime"] = 4,
["MaxSpeed"] = 50,
["MaxZigZag"] = 2,
["RotationalVelocityRange"] = 200,
["TrackTarget"] = true,
["TurnRate"] = 0,
["UseGravity"] = false,
["VelocityAlign"] = true,
["ZigZagFrequency"] = 0.2,
},
["sourceId"] = "caananodart04",
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
["name"] = "caananodart04",
["tpId"] = "psf0009",
},
["movement"] = {
["acceleration"] = 6,
["rotationSpeed"] = 0,
["speedMax"] = 50,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0009/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0009/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0009/LOD0/psf0009.sanmaterial",
["model"] = "Projectiles/psf0009/LOD0/psf0009.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0009.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0009")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/psf0009/ribbon_0.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/psf0009/ribbon_0.sanvfx",
}
end
