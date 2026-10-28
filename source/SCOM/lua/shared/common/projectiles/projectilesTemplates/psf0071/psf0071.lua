ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "844a73f3e21f9c2ec80463059e6cf418f3fc1c0db5650a7d99998fa1909b2dd7",
["categories"] = { "UEF", "PROJECTILE", "INDIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["DetonateBelowHeight"] = 45,
["InitialSpeed"] = 14.6,
["InitialSpeedRange"] = 3,
["InitialSpeedReduceDistance"] = 30,
["LeadTarget"] = false,
["TurnRate"] = 360,
["VelocityAlign"] = true,
},
["sourceId"] = "aiffragmentationsensorshell01",
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
["name"] = "aiffragmentationsensorshell01",
["tpId"] = "psf0071",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0071/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0071/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0071/LOD0/psf0071.sanmaterial",
["model"] = "Projectiles/psf0071/LOD0/psf0071.sanmodel",
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
assert(tp.general.tpId=="psf0071",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="844a73f3e21f9c2ec80463059e6cf418f3fc1c0db5650a7d99998fa1909b2dd7",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Impact/vci1341_cannon_artillery_large_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Trails/vct1341_cannon_artillery_large_trail.sanvfx",
} },
} },
}
end
