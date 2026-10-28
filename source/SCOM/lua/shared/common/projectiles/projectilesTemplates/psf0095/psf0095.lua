ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "6e29a113ca2678aed23f2f0cc9d69418f259eccd69244efb4539d9dfc2f0b4e5",
["categories"] = { "CYBRAN", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 0,
["DestroyOnWater"] = true,
["InitialSpeed"] = 35,
["MaxSpeed"] = 45,
["MaxZigZag"] = 5,
["TrackTarget"] = false,
["TurnRate"] = 360,
["VelocityAlign"] = true,
["ZigZagFrequency"] = 1,
},
["sourceId"] = "cdfrocketiridium02",
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
["name"] = "cdfrocketiridium02",
["tpId"] = "psf0095",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0095/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0095/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0095/LOD0/psf0095.sanmaterial",
["model"] = "Projectiles/psf0095/LOD0/psf0095.sanmodel",
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
assert(tp.general.tpId=="psf0095",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="6e29a113ca2678aed23f2f0cc9d69418f259eccd69244efb4539d9dfc2f0b4e5",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vei2101_rocket_antitank_small_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vet2101_rocket_antitank_small_trail.sanvfx",
} },
} },
}
end
