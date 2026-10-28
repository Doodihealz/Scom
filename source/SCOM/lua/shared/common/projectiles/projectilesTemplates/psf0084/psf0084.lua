ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "62fa521286123ca9dc8f8da1a9b7bf60cdcb15ee421b5ca05880c2c48d9045a8",
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
["StayUnderwater"] = true,
["TrackTarget"] = true,
["TurnRate"] = 230,
["VelocityAlign"] = true,
},
["sourceId"] = "cantorpedomeson02",
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
["name"] = "cantorpedomeson02",
["tpId"] = "psf0084",
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
["particleName"] = "VFX/SCOM/Source/psf0084/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0084/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0084/LOD0/psf0084.sanmaterial",
["model"] = "Projectiles/psf0084/LOD0/psf0084.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0084.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="cantorpedomeson02",["blueprintSha256"]="62fa521286123ca9dc8f8da1a9b7bf60cdcb15ee421b5ca05880c2c48d9045a8",["categories"]={"CYBRAN","PROJECTILE","ANTINAVY","TORPEDO","NOSPLASHDAMAGE"},["defense"]={["Health"]=1},["collisionRadius"]=1}
