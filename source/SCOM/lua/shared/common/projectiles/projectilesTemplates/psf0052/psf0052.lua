ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "900b6cbe51295692f2864998328b78784a784e2fed05168ee93115a147e50b39",
["categories"] = { "AEON", "PROJECTILE", "ANTINAVY" },
["defense"] = {
["Health"] = 1,
},
["physics"] = {
["Acceleration"] = 0,
["DestroyOnWater"] = false,
["Lifetime"] = 20,
["MaxSpeed"] = 14,
["StayUnderwater"] = true,
["StayUpright"] = true,
["TrackTarget"] = false,
["TurnRate"] = 230,
["VelocityAlign"] = true,
},
["sourceId"] = "aandepthcharge03",
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
["name"] = "aandepthcharge03",
["tpId"] = "psf0052",
},
["movement"] = {
["acceleration"] = 0,
["rotationSpeed"] = 230,
["speedMax"] = 14,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0052/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0052/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0052/LOD0/psf0052.sanmaterial",
["model"] = "Projectiles/psf0052/LOD0/psf0052.sanmodel",
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
assert(tp.general.tpId=="psf0052",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="900b6cbe51295692f2864998328b78784a784e2fed05168ee93115a147e50b39",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Impacts/MetallicWarbleImpa PE359507.ogg",
["particleName"] = "VFX/AeonProjectiles/Impact/vci1101_cannon_plasma_small_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Trails/vct1201_cannon_plasma_medium_trail.sanvfx",
} },
} },
}
end
