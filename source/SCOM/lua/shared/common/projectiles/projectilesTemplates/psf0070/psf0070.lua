ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "b2045b5e5c6c004428e46ef08de8a7269e53b9e20b4a71c366c3ed6fcf00866e",
["categories"] = { "AEON", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 14,
["UseGravity"] = true,
},
["sourceId"] = "adfsonicpulsar01",
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
["name"] = "adfsonicpulsar01",
["tpId"] = "psf0070",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0070/trail.sanvfx",
} },
} },
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0070",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="b2045b5e5c6c004428e46ef08de8a7269e53b9e20b4a71c366c3ed6fcf00866e",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["audioName"] = "EDA_Impacts_Random",
["particleName"] = "VFX/AeonProjectiles/Impact/vci1101_cannon_plasma_small_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Trails/vct1101_cannon_plasma_small_trail.sanvfx",
} },
} },
}
end
