ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "f5adce36cb2944fa5ba10028e1ae35884bd2104fb0460b973b8267442bc2f28f",
["categories"] = { "UEF", "PROJECTILE", "INDIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 50,
["InitialSpeedRange"] = 12,
["InitialSpeedReduceDistance"] = 115,
["LeadTarget"] = false,
["Lifetime"] = 8,
["TurnRate"] = 360,
["VelocityAlign"] = true,
},
["sourceId"] = "tifantimattershells02",
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
["name"] = "tifantimattershells02",
["tpId"] = "psf0159",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0159/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0159/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0159/LOD0/psf0159.sanmaterial",
["model"] = "Projectiles/psf0159/LOD0/psf0159.sanmodel",
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
assert(tp.general.tpId=="psf0159",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="f5adce36cb2944fa5ba10028e1ae35884bd2104fb0460b973b8267442bc2f28f",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vei2241_rocket_artillery_medium_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vet2241_rocket_artillery_medium_trail.sanvfx",
} },
} },
}
end
