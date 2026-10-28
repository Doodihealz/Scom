ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "95827fbff5673ff590b19e04d652f2246b3b46b6c1b8c26d7cb334509fdabcd8",
["categories"] = { "CYBRAN", "PROJECTILE", "INDIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 14.6,
["InitialSpeedRange"] = 3,
["InitialSpeedReduceDistance"] = 30,
["LeadTarget"] = false,
["TurnRate"] = 360,
["VelocityAlign"] = true,
},
["sourceId"] = "cifgrenade01",
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
["name"] = "cifgrenade01",
["tpId"] = "psf0097",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0097/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0097/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0097/LOD0/psf0097.sanmaterial",
["model"] = "Projectiles/psf0097/LOD0/psf0097.sanmodel",
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
assert(tp.general.tpId=="psf0097",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="95827fbff5673ff590b19e04d652f2246b3b46b6c1b8c26d7cb334509fdabcd8",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 150,
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
