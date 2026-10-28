ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "4080e78910d6a89e47e649e7c75fa4d4b6f42cf72009fbb71d60b41621cac76f",
["categories"] = { "AEON", "PROJECTILE", "ANTIAIR", "MISSILE" },
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
["TurnRate"] = 150,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "aaalightdisplacementautocannonmissile01",
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
["name"] = "aaalightdisplacementautocannonmissile01",
["tpId"] = "psf0046",
},
["movement"] = {
["acceleration"] = 6,
["rotationSpeed"] = 150,
["speedMax"] = 50,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0046/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0046/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0046/LOD0/psf0046.sanmaterial",
["model"] = "Projectiles/psf0046/LOD0/psf0046.sanmodel",
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
assert(tp.general.tpId=="psf0046",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="4080e78910d6a89e47e649e7c75fa4d4b6f42cf72009fbb71d60b41621cac76f",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Impact/vci3221_cannon_antiair_medium_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Trails/vct3221_cannon_antiair_medium_trail.sanvfx",
} },
} },
}
end
