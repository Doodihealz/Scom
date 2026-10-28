ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "c5e63eb0c5ad7ca4b64671457477b19af709d0c2208f8996e507d9035d4d6c1c",
["categories"] = { "CYBRAN", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 0,
["DestroyOnWater"] = true,
["InitialSpeed"] = 25,
["InitialSpeedRange"] = 0,
["MaxSpeed"] = 0,
["RotationalVelocity"] = 0,
["RotationalVelocityRange"] = 0,
["TurnRate"] = 360,
["VelocityAlign"] = true,
},
["sourceId"] = "cdfprotoncannon04",
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
["x"] = 0.01,
["y"] = 0.01,
["z"] = 0.25,
},
},
["general"] = {
["name"] = "cdfprotoncannon04",
["tpId"] = "psf0094",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0094/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0094/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0094/LOD0/psf0094.sanmaterial",
["model"] = "Projectiles/psf0094/LOD0/psf0094.sanmodel",
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
assert(tp.general.tpId=="psf0094",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="c5e63eb0c5ad7ca4b64671457477b19af709d0c2208f8996e507d9035d4d6c1c",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vgi1101_cannon_small_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vgt1101_cannon_small_trail.sanvfx",
} },
} },
}
end
