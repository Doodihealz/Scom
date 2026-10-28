ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "90e8c7adebb2460ed3e2cef3d3ce16a47356e0d21007e7384085cca303d6cd15",
["categories"] = { "CYBRAN", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 0,
["DestroyOnWater"] = true,
["InitialSpeed"] = 19,
["InitialSpeedRange"] = 0,
["MaxSpeed"] = 0,
["RotationalVelocity"] = 0,
["RotationalVelocityRange"] = 0,
["VelocityAlign"] = true,
},
["sourceId"] = "cdfprotoncannon02",
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
["name"] = "cdfprotoncannon02",
["tpId"] = "psf0092",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0092/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0092/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0092/LOD0/psf0092.sanmaterial",
["model"] = "Projectiles/psf0092/LOD0/psf0092.sanmodel",
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
assert(tp.general.tpId=="psf0092",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="90e8c7adebb2460ed3e2cef3d3ce16a47356e0d21007e7384085cca303d6cd15",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vgi1281_cannon_plasma_medium_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vgt1281_cannon_plasma_medium_trail.sanvfx",
} },
} },
}
end
