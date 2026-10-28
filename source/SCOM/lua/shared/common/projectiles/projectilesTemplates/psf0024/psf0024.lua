ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "8b0ec153e08f756d7623a671a2dcc2852bd3b54ca1e2a23af4cf83e81f5d6fc9",
["categories"] = { "UEF", "PROJECTILE", "ANTIAIR", "MISSILE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 6,
["DestroyOnWater"] = true,
["InitialSpeed"] = 30,
["LeadTarget"] = false,
["Lifetime"] = 4,
["MaxSpeed"] = 50,
["OnLostTargetLifetime"] = 0.7,
["TrackTarget"] = true,
["TurnRate"] = 180,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "taamissileflayer01",
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
["name"] = "taamissileflayer01",
["tpId"] = "psf0024",
},
["movement"] = {
["acceleration"] = 6,
["rotationSpeed"] = 180,
["speedMax"] = 50,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0024/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0024/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0024/LOD0/psf0024.sanmaterial",
["model"] = "Projectiles/psf0024/LOD0/psf0024.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
