ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "199bd908af987d0ce1173e112053d699e50c5ff7d43f0fd912166145e8e786d4",
["categories"] = { "CYBRAN", "PROJECTILE", "ANTIAIR" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 0.5,
["DestroyOnWater"] = true,
["InitialSpeed"] = 20,
["LeadTarget"] = true,
["Lifetime"] = 4,
["MaxSpeed"] = 20,
["MaxZigZag"] = 2,
["RotationalVelocityRange"] = 200,
["TrackTarget"] = false,
["TurnRate"] = 0,
["UseGravity"] = false,
["VelocityAlign"] = true,
["ZigZagFrequency"] = 0.2,
},
["sourceId"] = "caananodart02",
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
["name"] = "caananodart02",
["tpId"] = "psf0082",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0082/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0082/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0082/LOD0/psf0082.sanmaterial",
["model"] = "Projectiles/psf0082/LOD0/psf0082.sanmodel",
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
assert(tp.general.tpId=="psf0082",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="199bd908af987d0ce1173e112053d699e50c5ff7d43f0fd912166145e8e786d4",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vgi1281_cannon_plasma_medium_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vgt1281_cannon_plasma_medium_trail.sanvfx",
} },
} },
}
end
