ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "989a1075053ba0d0c4bcea3db313b05e58a1a95f9c7dc6249a5eacbf89c209ed",
["categories"] = { "AEON", "PROJECTILE", "INDIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["DetonateBelowHeight"] = 2,
["LeadTarget"] = false,
["StayUpright"] = false,
["VelocityAlign"] = false,
},
["sourceId"] = "aifmiasmashell01",
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
["name"] = "aifmiasmashell01",
["tpId"] = "psf0072",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0072/impact_none.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0072/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0072/LOD0/psf0072.sanmaterial",
["model"] = "Projectiles/psf0072/LOD0/psf0072.sanmodel",
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
assert(tp.general.tpId=="psf0072",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="989a1075053ba0d0c4bcea3db313b05e58a1a95f9c7dc6249a5eacbf89c209ed",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Impact/vci1241_cannon_artillery_medium_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Trails/vct1241_cannon_artillery_medium_trail.sanvfx",
} },
} },
}
end
