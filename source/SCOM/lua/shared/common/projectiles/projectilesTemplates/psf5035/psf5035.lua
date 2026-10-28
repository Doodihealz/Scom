ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "7885fbb13a4c69f8d79a1e579970815b12af17c3c4e7344a89720c00abba1ed9",
["categories"] = { "UEF", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 13,
["Lifetime"] = 1.3,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "tdfriot02",
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
["name"] = "tdfriot02",
["tpId"] = "psf5035",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0035/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0035/trail.sanvfx",
} },
} },
},
}

-- Fatboy-only compact tracer; physics, collision and impact remain source-owned.
ProjectileTemplate.visuals.persistantEffects = {
    {effects = {{particleName = "VFX/SCOM/Source/psf5035/trail.sanvfx"}}},
}
-- Reuse the converted UEF pellet with its validated indirect-renderer material.
ProjectileTemplate.visuals.scoProjectileMesh = {
    model = "Projectiles/psf0154/LOD0/psf0154.sanmodel",
    material = "Projectiles/psf0151/LOD0/psf0151.sanmaterial",
    scale = {x = 3, y = 3, z = 1.5},
}
