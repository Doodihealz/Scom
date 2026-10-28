ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "e2759f1dbf0b1c023bd35eb4aa443c7cf953673ba0f5a5284fc5545a8a423437",
["categories"] = { "AEON", "PROJECTILE", "INDIRECTFIRE", "TACTICAL", "MISSILE", "NOSPLASHDAMAGE" },
["defense"] = {
["Health"] = 2,
["MaxHealth"] = 2,
},
["physics"] = {
["Acceleration"] = 3,
["DestroyOnWater"] = false,
["InitialSpeed"] = 3,
["LifeTime"] = 30,
["MaxSpeed"] = 12,
["MaxZigZag"] = 5,
["RotationalVelocity"] = 0,
["RotationalVelocityRange"] = 0,
["TrackTarget"] = true,
["TrackTargetGround"] = true,
["TurnRate"] = 0,
["UseGravity"] = false,
["VelocityAlign"] = true,
["ZigZagFrequency"] = 0.5,
},
["sourceId"] = "aifmissileserpentine02",
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
["name"] = "aifmissileserpentine02",
["tpId"] = "psf0074",
},
["movement"] = {
["acceleration"] = 3,
["rotationSpeed"] = 0,
["speedMax"] = 12,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0074/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0074/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0074/LOD0/psf0074.sanmaterial",
["model"] = "Projectiles/psf0074/LOD0/psf0074.sanmodel",
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
assert(tp.general.tpId=="psf0074",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="e2759f1dbf0b1c023bd35eb4aa443c7cf953673ba0f5a5284fc5545a8a423437",'Historical projectile source drift')
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
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0074.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="aifmissileserpentine02",["blueprintSha256"]="e2759f1dbf0b1c023bd35eb4aa443c7cf953673ba0f5a5284fc5545a8a423437",["categories"]={"AEON","PROJECTILE","INDIRECTFIRE","TACTICAL","MISSILE","NOSPLASHDAMAGE"},["defense"]={["Health"]=2,["MaxHealth"]=2},["collisionRadius"]=1}
