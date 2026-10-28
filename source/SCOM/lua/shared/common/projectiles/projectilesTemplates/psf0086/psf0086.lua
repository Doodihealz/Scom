ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "07cabdfb78f90b37c86ed7bc45a8b795f221425ed36a13f2cd1d8092790e90f7",
["categories"] = { "CYBRAN", "PROJECTILE", "ANTINAVY", "TORPEDO", "NOSPLASHDAMAGE" },
["defense"] = {
["Health"] = 1,
},
["physics"] = {
["Acceleration"] = 0,
["DestroyOnWater"] = false,
["InitialSpeed"] = 14,
["Lifetime"] = 20,
["MaxSpeed"] = 14,
["MaxZigZag"] = 0.5,
["StayUnderwater"] = true,
["TrackTarget"] = true,
["TurnRate"] = 230,
["VelocityAlign"] = true,
["ZigZagFrequency"] = 1,
},
["sourceId"] = "cantorpedonanite03",
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
["name"] = "cantorpedonanite03",
["tpId"] = "psf0086",
},
["movement"] = {
["acceleration"] = 0,
["rotationSpeed"] = 230,
["speedMax"] = 14,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0086/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0086/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0086/LOD0/psf0086.sanmaterial",
["model"] = "Projectiles/psf0086/LOD0/psf0086.sanmodel",
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
assert(tp.general.tpId=="psf0086",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="07cabdfb78f90b37c86ed7bc45a8b795f221425ed36a13f2cd1d8092790e90f7",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vgi1741_grenade_medium_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vgt1741_grenade_medium_trail.sanvfx",
} },
} },
}
end
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0086.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="cantorpedonanite03",["blueprintSha256"]="07cabdfb78f90b37c86ed7bc45a8b795f221425ed36a13f2cd1d8092790e90f7",["categories"]={"CYBRAN","PROJECTILE","ANTINAVY","TORPEDO","NOSPLASHDAMAGE"},["defense"]={["Health"]=1},["collisionRadius"]=1}
