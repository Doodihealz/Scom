ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "ffac4a5a216f3dfaf7750bb4003a612905fb58379de03b8c34b1aa1f68317e66",
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
["sourceId"] = "cdfprotoncannon03",
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
["name"] = "cdfprotoncannon03",
["tpId"] = "psf0093",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0093/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0093/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0093/LOD0/psf0093.sanmaterial",
["model"] = "Projectiles/psf0093/LOD0/psf0093.sanmodel",
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
assert(tp.general.tpId=="psf0093",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="ffac4a5a216f3dfaf7750bb4003a612905fb58379de03b8c34b1aa1f68317e66",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vgi1301_cannon_large_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vgt1301_cannon_large_trail.sanvfx",
} },
} },
}
end
