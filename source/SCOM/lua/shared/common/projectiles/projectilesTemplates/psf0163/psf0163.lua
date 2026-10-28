ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "dbf3f025999121d5c001364f1247dc9613aa9802252f2a23a931c03fe7eb6ab6",
["categories"] = { "AEON", "PROJECTILE", "ANTINAVY" },
["defense"] = {
["Health"] = 1,
},
["physics"] = {
["Acceleration"] = 0,
["DestroyOnWater"] = false,
["MaxSpeed"] = 15,
["StayUnderwater"] = true,
["StayUpright"] = true,
["TrackTarget"] = true,
["TurnRate"] = 230,
["VelocityAlign"] = true,
},
["sourceId"] = "aandepthcharge02",
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
["name"] = "aandepthcharge02",
["tpId"] = "psf0163",
},
["movement"] = {
["acceleration"] = 0,
["rotationSpeed"] = 230,
["speedMax"] = 15,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0163/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0163/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0163/LOD0/psf0163.sanmaterial",
["model"] = "Projectiles/psf0163/LOD0/psf0163.sanmodel",
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
assert(tp.general.tpId=="psf0163",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="dbf3f025999121d5c001364f1247dc9613aa9802252f2a23a931c03fe7eb6ab6",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Impact/vci1241_cannon_artillery_medium_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Trails/vct1241_cannon_artillery_medium_trail.sanvfx",
} },
} },
}
end
