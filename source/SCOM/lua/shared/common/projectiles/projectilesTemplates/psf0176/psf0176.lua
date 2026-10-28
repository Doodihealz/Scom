ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "21ac4b56a6d157c1850a377bf37c80148fab1a131c5ceee811500fef27ab0eac",
["categories"] = { "AEON", "PROJECTILE", "ANTITORPEDO", "DEFENSE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 30,
["DestroyOnWater"] = false,
["MaxSpeed"] = 10,
["StayUnderwater"] = true,
["TrackTarget"] = true,
["TurnRate"] = 720,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "aimantitorpedo01",
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
["name"] = "aimantitorpedo01",
["tpId"] = "psf0176",
},
["movement"] = {
["acceleration"] = 30,
["rotationSpeed"] = 720,
["speedMax"] = 10,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0176/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0176/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0176/LOD0/psf0176.sanmaterial",
["model"] = "Projectiles/psf0176/LOD0/psf0176.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
