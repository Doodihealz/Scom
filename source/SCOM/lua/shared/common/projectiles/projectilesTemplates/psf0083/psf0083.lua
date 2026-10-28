ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "a7b08165aca0e481b27001b61bd2e0790f605ab0ce24c87a4734c9d379ae82db",
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
["OnLostTargetLifetime"] = 0.7,
["RotationalVelocityRange"] = 200,
["TrackTarget"] = true,
["TurnRate"] = 180,
["UseGravity"] = false,
["VelocityAlign"] = true,
["ZigZagFrequency"] = 0.2,
},
["sourceId"] = "caananodart03",
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
["name"] = "caananodart03",
["tpId"] = "psf0083",
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
["particleName"] = "VFX/SCOM/Source/psf0083/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0083/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0083/LOD0/psf0083.sanmaterial",
["model"] = "Projectiles/psf0083/LOD0/psf0083.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0083",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="a7b08165aca0e481b27001b61bd2e0790f605ab0ce24c87a4734c9d379ae82db",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vgi3221_cannon_antiair_medium_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vgt3221_cannon_antiair_medium_trail.sanvfx",
} },
} },
}
end
