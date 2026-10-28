ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "070115a33ac8c75ea6bb6e3e649e02b9bc784de222051c2e7f63ade00006a2e4",
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
["sourceId"] = "tdfgauss03",
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
["name"] = "tdfgauss03",
["tpId"] = "psf0153",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0153/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0153/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0153/LOD0/psf0153.sanmaterial",
["model"] = "Projectiles/psf0153/LOD0/psf0153.sanmodel",
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
assert(tp.general.tpId=="psf0153",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="070115a33ac8c75ea6bb6e3e649e02b9bc784de222051c2e7f63ade00006a2e4",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["audioName"] = "eda_projectile_impact_cannon_small",
["particleName"] = "VFX/Impact/vei1301_cannon_large_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vet1301_cannon_large_trail.sanvfx",
} },
} },
}
end
