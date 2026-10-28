ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "dd71f937eb2aeab35ae544fe8e104064ef9ef3b1c103cb05cd72a4c09e0d0f1e",
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
["sourceId"] = "taamissileflayer02",
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
["name"] = "taamissileflayer02",
["tpId"] = "psf0146",
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
["particleName"] = "VFX/SCOM/Source/psf0146/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0146/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0146/LOD0/psf0146.sanmaterial",
["model"] = "Projectiles/psf0146/LOD0/psf0146.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
