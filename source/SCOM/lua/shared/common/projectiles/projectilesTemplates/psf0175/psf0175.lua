ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "77466f2ffbaf3d1c2966d3213372697cef982aef7e0ab767a859b0076b4c9017",
["categories"] = { "AEON", "PROJECTILE", "ANTIMISSILE" },
["defense"] = {
["Health"] = 1,
["MaxHealth"] = 1,
},
["physics"] = {
["Acceleration"] = 1,
["DestroyOnWater"] = true,
["LifeTime"] = 4,
["MaxSpeed"] = 5,
["TrackTarget"] = true,
["TurnRate"] = 0,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "aimantimissile01",
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
["x"] = 0.5,
["y"] = 0.5,
["z"] = 0.5,
},
},
["general"] = {
["name"] = "aimantimissile01",
["tpId"] = "psf0175",
},
["movement"] = {
["acceleration"] = 1,
["rotationSpeed"] = 0,
["speedMax"] = 5,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0175/impact_none.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0175/trail.sanvfx",
} },
} },
},
}
