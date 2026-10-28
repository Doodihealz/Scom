ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "f0b2f7b0ac0252a9ae597efaea72a9841bfe7943ac9936254837c5900a665e7d",
["categories"] = { "UEF", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 0,
["DestroyOnWater"] = true,
["InitialSpeed"] = 28,
["InitialSpeedRange"] = 0,
["LeadTarget"] = false,
["MaxSpeed"] = 0,
["RotationalVelocity"] = 0,
["RotationalVelocityRange"] = 0,
["TurnRate"] = 360,
["VelocityAlign"] = true,
},
["sourceId"] = "tdfgauss02",
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
["name"] = "tdfgauss02",
["tpId"] = "psf0152",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0152/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0152/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0152/LOD0/psf0152.sanmaterial",
["model"] = "Projectiles/psf0152/LOD0/psf0152.sanmodel",
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
assert(tp.general.tpId=="psf0152",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="f0b2f7b0ac0252a9ae597efaea72a9841bfe7943ac9936254837c5900a665e7d",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vei1101_cannon_small_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vet1101_cannon_small_trail.sanvfx",
} },
} },
}
end
