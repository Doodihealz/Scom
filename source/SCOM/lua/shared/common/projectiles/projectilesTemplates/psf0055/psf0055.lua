ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "cc6baf4b45f59f320ad1c5d98ceaefc5d680385097756209d1213a03362acbb8",
["categories"] = { "AEON", "PROJECTILE", "ANTINAVY", "NOSPLASHDAMAGE" },
["defense"] = {
["Health"] = 1,
},
["physics"] = {
["Acceleration"] = 0,
["DestroyOnWater"] = false,
["Lifetime"] = 30,
["MaxSpeed"] = 20,
["RealisticOrdinance"] = false,
["StayUpright"] = true,
["TrackTarget"] = false,
["TurnRate"] = 360,
["VelocityAlign"] = true,
},
["sourceId"] = "aantorpedocluster01",
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
["name"] = "aantorpedocluster01",
["tpId"] = "psf0055",
},
["movement"] = {
["acceleration"] = 0,
["rotationSpeed"] = 360,
["speedMax"] = 20,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0055/impact_unit.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0055/LOD0/psf0055.sanmaterial",
["model"] = "Projectiles/psf0055/LOD0/psf0055.sanmodel",
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
assert(tp.general.tpId=="psf0055",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="cc6baf4b45f59f320ad1c5d98ceaefc5d680385097756209d1213a03362acbb8",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Impacts/MetallicWarbleImpa PE359507.ogg",
["particleName"] = "VFX/AeonProjectiles/Impact/vci1441_cannon_artillery_huge_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Trails/vct1201_cannon_plasma_medium_trail.sanvfx",
} },
} },
}
end
