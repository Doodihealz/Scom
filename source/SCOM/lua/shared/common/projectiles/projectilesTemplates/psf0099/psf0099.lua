ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "6a89cda3b080d10dc66547022518fe30a87d337a0ff6ca876fa2ff6f555493a4",
["categories"] = { "CYBRAN", "PROJECTILE", "INDIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["LeadTarget"] = false,
["TurnRate"] = 360,
["VelocityAlign"] = true,
},
["sourceId"] = "cifmolecularresonanceshell01",
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
["name"] = "cifmolecularresonanceshell01",
["tpId"] = "psf0099",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0099/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0099/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0099/LOD0/psf0099.sanmaterial",
["model"] = "Projectiles/psf0099/LOD0/psf0099.sanmodel",
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
assert(tp.general.tpId=="psf0099",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="6a89cda3b080d10dc66547022518fe30a87d337a0ff6ca876fa2ff6f555493a4",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vgi1241_cannon_artillery_medium_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vgt1241_cannon_artillery_medium_trail.sanvfx",
} },
} },
}
end
