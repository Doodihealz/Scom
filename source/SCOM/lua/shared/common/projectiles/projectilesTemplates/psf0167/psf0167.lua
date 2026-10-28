ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "a952ed37521cdf7935413c8e994a44fc91a397389078e4ab1796866fe403ce1b",
["categories"] = { "CYBRAN", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 0,
["AccelerationRange"] = 0,
["DestroyOnWater"] = true,
["InitialSpeed"] = 8,
["InitialSpeedRange"] = 8,
["Lifetime"] = 3,
["MaxSpeed"] = 25,
["ProjectileLifetime"] = 2.1,
["RotationalVelocity"] = 500,
["RotationalVelocityRange"] = 0,
["TurnRate"] = 0,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "cdfrocketmeson01",
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
["name"] = "cdfrocketmeson01",
["tpId"] = "psf0167",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0167/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0167/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0167/LOD0/psf0167.sanmaterial",
["model"] = "Projectiles/psf0167/LOD0/psf0167.sanmodel",
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
assert(tp.general.tpId=="psf0167",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="a952ed37521cdf7935413c8e994a44fc91a397389078e4ab1796866fe403ce1b",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vgi1141_cannon_artillery_small_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vgt1141_cannon_artillery_small_trail.sanvfx",
} },
} },
}
end
