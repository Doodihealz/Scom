ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "8b7851d08f385f9ecd28d546d7cb601ced695eb66eeabfb08b01ac4427a7277d",
["categories"] = { "UEF", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 22,
["InitialSpeedRange"] = 0,
["VelocityAlign"] = true,
},
["sourceId"] = "tdfmachinegun01",
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
["name"] = "tdfmachinegun01",
["tpId"] = "psf0156",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0156/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0156/trail.sanvfx",
} },
} },
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0156",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="8b7851d08f385f9ecd28d546d7cb601ced695eb66eeabfb08b01ac4427a7277d",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 90,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vei1121_autocannon_small_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vet1121_autocannon_small_trail.sanvfx",
} },
} },
}
end
