ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "eb2e236a2589515c5fb9af3a772f0c85ed83316677388e97f80df81164b309ce",
["categories"] = { "SERAPHIM", "PROJECTILE", "ANTIAIR" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["DetonateAboveHeight"] = 10,
["InitialSpeed"] = 20,
["LeadTarget"] = false,
["Lifetime"] = 3,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "saaolarisaaartillery02",
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
["name"] = "saaolarisaaartillery02",
["tpId"] = "psf0104",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0104/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0104/trail.sanvfx",
} },
} },
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0104",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="eb2e236a2589515c5fb9af3a772f0c85ed83316677388e97f80df81164b309ce",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vci3121_cannon_antiair_small_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vct3121_cannon_antiair_small_trail.sanvfx",
} },
} },
}
end
