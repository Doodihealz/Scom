ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "8b9f2200f7ee4eb51d412c316216d4d340b0e41e0392b91af53ca523e9e12736",
["categories"] = { "AEON", "PROJECTILE", "ANTINAVY" },
["defense"] = {
["Health"] = 1,
},
["physics"] = {
["Acceleration"] = 1,
["DestroyOnWater"] = false,
["Lifetime"] = 15,
["MaxSpeed"] = 10,
["StayUnderwater"] = true,
["StayUpright"] = true,
["TrackTarget"] = false,
["TurnRate"] = 230,
["VelocityAlign"] = true,
},
["sourceId"] = "aandepthcharge01",
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
["name"] = "aandepthcharge01",
["tpId"] = "psf0051",
},
["movement"] = {
["acceleration"] = 1,
["rotationSpeed"] = 230,
["speedMax"] = 10,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0051/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0051/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0051/LOD0/psf0051.sanmaterial",
["model"] = "Projectiles/psf0051/LOD0/psf0051.sanmodel",
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
assert(tp.general.tpId=="psf0051",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="8b9f2200f7ee4eb51d412c316216d4d340b0e41e0392b91af53ca523e9e12736",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Impact/vci1341_cannon_artillery_large_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Trails/vct1341_cannon_artillery_large_trail.sanvfx",
} },
} },
}
end
