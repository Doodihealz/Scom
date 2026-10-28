ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "2143068adec9f3f97c804255fb5b2534e53d693eb44a9a2b99d0110b88c4ecb1",
["categories"] = { "SERAPHIM", "PROJECTILE", "ANTIAIR" },
["defense"] = {

},
["physics"] = {
["CollideEntity"] = true,
["CollideSurface"] = true,
["DestroyOnWater"] = true,
["DetonateAboveHeight"] = 10,
["InitialSpeed"] = 20,
["LeadTarget"] = false,
["RotationalVelocity"] = 0,
["StayUpright"] = true,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "saaolarisaaartillery03",
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
["name"] = "saaolarisaaartillery03",
["tpId"] = "psf0105",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0105/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0105/trail.sanvfx",
} },
} },
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0105",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="2143068adec9f3f97c804255fb5b2534e53d693eb44a9a2b99d0110b88c4ecb1",'Historical projectile source drift')
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
