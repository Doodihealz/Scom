ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "7b4cf765e643ae78c849338be82943eaba000aa10d03565dcd717182aed63460",
["categories"] = { "UEF", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 0,
["DestroyOnWater"] = false,
["InitialSpeed"] = 12,
["InitialSpeedRange"] = 0,
["InitialSpeedReduceDistance"] = 0,
["MaxSpeed"] = 0,
["RotationalVelocity"] = 0,
["RotationalVelocityRange"] = 0,
["TurnRate"] = 360,
["VelocityAlign"] = true,
},
["sourceId"] = "tdfgauss01",
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
["name"] = "tdfgauss01",
["tpId"] = "psf0151",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0151/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["boneName"] = "SCO_Gauss_01",
["particleName"] = "VFX/SCOM/Source/psf0151/trail.sanvfx",
}, {
["boneName"] = "SCO_Gauss_02",
["particleName"] = "VFX/SCOM/Source/psf0151/trail_core.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0151/LOD0/psf0151.sanmaterial",
["model"] = "Projectiles/psf0151/LOD0/psf0151.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
