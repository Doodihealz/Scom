ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "679f05f2a746ce83663b88769616bed90271872824e845a83baf2f3a85362eed",
["categories"] = { "AEON", "PROJECTILE", "ANTINAVY", "NOSPLASHDAMAGE" },
["defense"] = {
["Health"] = 1,
},
["physics"] = {
["Acceleration"] = 0,
["DestroyOnWater"] = false,
["Lifetime"] = 25,
["MaxSpeed"] = 18,
["MaxZigZag"] = 5,
["StayUnderwater"] = true,
["StayUpright"] = true,
["TrackTarget"] = false,
["TurnRate"] = 360,
["VelocityAlign"] = true,
["ZigZagFrequency"] = 0.2,
},
["sourceId"] = "aantorpedoclustersplit01",
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
["name"] = "aantorpedoclustersplit01",
["tpId"] = "psf0183",
},
["movement"] = {
["acceleration"] = 0,
["rotationSpeed"] = 360,
["speedMax"] = 18,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0183/impact_unit.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0183/LOD0/psf0183.sanmaterial",
["model"] = "Projectiles/psf0183/LOD0/psf0183.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
