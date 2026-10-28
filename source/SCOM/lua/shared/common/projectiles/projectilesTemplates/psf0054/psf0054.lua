ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "4e0fa8b97f5b156fbf6b14556351d3e57a9eef984371cfe2653f314ea51d2702",
["categories"] = { "AEON", "PROJECTILE", "ANTINAVY", "TORPEDO", "NOSPLASHDAMAGE" },
["defense"] = {
["Health"] = 1,
},
["physics"] = {
["Acceleration"] = 5,
["DestroyOnWater"] = false,
["InitialSpeed"] = 5,
["MaxSpeed"] = 18,
["StayUnderwater"] = true,
["TrackTarget"] = true,
["TurnRate"] = 230,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "aantorpedochronopack01",
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
["name"] = "aantorpedochronopack01",
["tpId"] = "psf0054",
},
["movement"] = {
["acceleration"] = 5,
["rotationSpeed"] = 230,
["speedMax"] = 18,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0054/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0054/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0054/LOD0/psf0054.sanmaterial",
["model"] = "Projectiles/psf0054/LOD0/psf0054.sanmodel",
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
assert(tp.general.tpId=="psf0054",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="4e0fa8b97f5b156fbf6b14556351d3e57a9eef984371cfe2653f314ea51d2702",'Historical projectile source drift')
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
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0054.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="aantorpedochronopack01",["blueprintSha256"]="4e0fa8b97f5b156fbf6b14556351d3e57a9eef984371cfe2653f314ea51d2702",["categories"]={"AEON","PROJECTILE","ANTINAVY","TORPEDO","NOSPLASHDAMAGE"},["defense"]={["Health"]=1},["collisionRadius"]=1}
