ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "55e293247e1e0c3675563582954ccbc5b0eee894475abb09eeba0fb4bc90971b",
["categories"] = { "UEF", "PROJECTILE", "ANTINAVY", "TORPEDO", "NOSPLASHDAMAGE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 0,
["DestroyOnWater"] = false,
["InitialSpeed"] = 14,
["Lifetime"] = 20,
["MaxSpeed"] = 14,
["StayUnderwater"] = true,
["TrackTarget"] = true,
["TurnRate"] = 230,
["VelocityAlign"] = true,
},
["sourceId"] = "tananglertorpedo06",
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
["name"] = "tananglertorpedo06",
["tpId"] = "psf0150",
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
["particleName"] = "VFX/SCOM/Source/psf0150/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0150/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0150/LOD0/psf0150.sanmaterial",
["model"] = "Projectiles/psf0150/LOD0/psf0150.sanmodel",
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
assert(tp.general.tpId=="psf0150",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="55e293247e1e0c3675563582954ccbc5b0eee894475abb09eeba0fb4bc90971b",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vei3301_missile_antiair_large_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vet3301_missile_antiair_large_trail.sanvfx",
} },
} },
}
end
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0150.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="tananglertorpedo06",["blueprintSha256"]="55e293247e1e0c3675563582954ccbc5b0eee894475abb09eeba0fb4bc90971b",["categories"]={"UEF","PROJECTILE","ANTINAVY","TORPEDO","NOSPLASHDAMAGE"},["defense"]={},["collisionRadius"]=1}
