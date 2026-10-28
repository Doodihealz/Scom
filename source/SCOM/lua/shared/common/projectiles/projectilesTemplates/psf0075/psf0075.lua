ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "3266b58dead5ca5f64a6927cecb6d091748cbf724bb4d982df8b925ff2c83e6a",
["categories"] = { "AEON", "PROJECTILE", "INDIRECTFIRE", "TACTICAL", "MISSILE", "NOSPLASHDAMAGE" },
["defense"] = {
["Health"] = 2,
["MaxHealth"] = 2,
},
["physics"] = {
["Acceleration"] = 1.5,
["DestroyOnWater"] = true,
["InitialSpeed"] = 15,
["Lifetime"] = 60,
["MaxSpeed"] = 30,
["MaxZigZag"] = 5,
["RotationalVelocity"] = 0,
["RotationalVelocityRange"] = 0,
["TrackTarget"] = true,
["TrackTargetGround"] = true,
["TurnRate"] = 15,
["UseGravity"] = false,
["VelocityAlign"] = true,
["ZigZagFrequency"] = 0.2,
},
["sourceId"] = "aifmissileserpentine03",
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
["name"] = "aifmissileserpentine03",
["tpId"] = "psf0075",
},
["movement"] = {
["acceleration"] = 1.5,
["rotationSpeed"] = 15,
["speedMax"] = 30,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0075/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0075/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0075/LOD0/psf0075.sanmaterial",
["model"] = "Projectiles/psf0075/LOD0/psf0075.sanmodel",
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
assert(tp.general.tpId=="psf0075",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="3266b58dead5ca5f64a6927cecb6d091748cbf724bb4d982df8b925ff2c83e6a",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Impact/vci3301_missile_antiair_large_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Trails/vct3301_missile_antiair_large_trail.sanvfx",
} },
} },
}
end
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0075.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="aifmissileserpentine03",["blueprintSha256"]="3266b58dead5ca5f64a6927cecb6d091748cbf724bb4d982df8b925ff2c83e6a",["categories"]={"AEON","PROJECTILE","INDIRECTFIRE","TACTICAL","MISSILE","NOSPLASHDAMAGE"},["defense"]={["Health"]=2,["MaxHealth"]=2},["collisionRadius"]=1}
