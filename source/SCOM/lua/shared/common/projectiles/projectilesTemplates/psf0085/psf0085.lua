ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "057ed883894736a59210e14e3832b38265a99407c7a91a82a0f023ecdac917bd",
["categories"] = { "CYBRAN", "PROJECTILE", "ANTINAVY", "TORPEDO", "NOSPLASHDAMAGE" },
["defense"] = {
["Health"] = 1,
},
["physics"] = {
["Acceleration"] = 5,
["DestroyOnWater"] = false,
["InitialSpeed"] = 3,
["Lifetime"] = 7,
["MaxSpeed"] = 18,
["MaxZigZag"] = 0.5,
["StayUnderwater"] = true,
["TrackTarget"] = true,
["TurnRate"] = 230,
["VelocityAlign"] = true,
["ZigZagFrequency"] = 1,
},
["sourceId"] = "cantorpedonanite02",
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
["name"] = "cantorpedonanite02",
["tpId"] = "psf0085",
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
["particleName"] = "VFX/SCOM/Source/psf0085/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0085/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0085/LOD0/psf0085.sanmaterial",
["model"] = "Projectiles/psf0085/LOD0/psf0085.sanmodel",
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
assert(tp.general.tpId=="psf0085",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="057ed883894736a59210e14e3832b38265a99407c7a91a82a0f023ecdac917bd",'Historical projectile source drift')
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
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0085.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="cantorpedonanite02",["blueprintSha256"]="057ed883894736a59210e14e3832b38265a99407c7a91a82a0f023ecdac917bd",["categories"]={"CYBRAN","PROJECTILE","ANTINAVY","TORPEDO","NOSPLASHDAMAGE"},["defense"]={["Health"]=1},["collisionRadius"]=1}
