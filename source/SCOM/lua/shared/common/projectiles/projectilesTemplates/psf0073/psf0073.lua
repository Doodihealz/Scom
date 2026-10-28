ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "1376c174654070b29fdc47935b7f7b921acf5a2045e05ec78aaee49d0976e86f",
["categories"] = { "AEON", "PROJECTILE", "INDIRECTFIRE", "TACTICAL", "MISSILE", "NOSPLASHDAMAGE" },
["defense"] = {
["Health"] = 1,
["MaxHealth"] = 1,
},
["physics"] = {
["Acceleration"] = 3,
["DestroyOnWater"] = true,
["InitialSpeed"] = 3,
["MaxSpeed"] = 12,
["MaxZigZag"] = 5,
["TrackTarget"] = true,
["TrackTargetGround"] = true,
["TurnRate"] = 0,
["VelocityAlign"] = true,
["ZigZagFrequency"] = 0.5,
},
["sourceId"] = "aifmissileserpentine01",
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
["name"] = "aifmissileserpentine01",
["tpId"] = "psf0073",
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
["particleName"] = "VFX/SCOM/Source/psf0073/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0073/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0073/LOD0/psf0073.sanmaterial",
["model"] = "Projectiles/psf0073/LOD0/psf0073.sanmodel",
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
assert(tp.general.tpId=="psf0073",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="1376c174654070b29fdc47935b7f7b921acf5a2045e05ec78aaee49d0976e86f",'Historical projectile source drift')
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
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0073.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="aifmissileserpentine01",["blueprintSha256"]="1376c174654070b29fdc47935b7f7b921acf5a2045e05ec78aaee49d0976e86f",["categories"]={"AEON","PROJECTILE","INDIRECTFIRE","TACTICAL","MISSILE","NOSPLASHDAMAGE"},["defense"]={["Health"]=1,["MaxHealth"]=1},["collisionRadius"]=1}

-- Use the already converted source missile body with its native indirect material.
ProjectileTemplate.visuals.scoProjectileMesh = {
    model = "Projectiles/psf0073/LOD0/psf0073.sanmodel",
    material = "Projectiles/psf0073/LOD0/psf0073.sanmaterial",
    scale = { x = 1, y = 1, z = 1 },
}
