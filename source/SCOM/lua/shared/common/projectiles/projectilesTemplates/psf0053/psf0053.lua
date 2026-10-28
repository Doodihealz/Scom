ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "16ff14ee2eb91421198b500169247792ebd48a503ce40357baf915d35bc9934b",
["categories"] = { "AEON", "PROJECTILE", "ANTINAVY", "TORPEDO", "NOSPLASHDAMAGE" },
["defense"] = {
["Health"] = 1,
},
["physics"] = {
["Acceleration"] = 5,
["DestroyOnWater"] = false,
["InitialSpeed"] = 5,
["Lifetime"] = 7,
["MaxSpeed"] = 18,
["StayUnderwater"] = true,
["TrackTarget"] = true,
["TurnRate"] = 230,
["VelocityAlign"] = true,
},
["sourceId"] = "aantorpedo01",
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
["name"] = "aantorpedo01",
["tpId"] = "psf0053",
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
["particleName"] = "VFX/SCOM/Source/psf0053/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0053/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0053/LOD0/psf0053.sanmaterial",
["model"] = "Projectiles/psf0053/LOD0/psf0053.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0053.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="aantorpedo01",["blueprintSha256"]="16ff14ee2eb91421198b500169247792ebd48a503ce40357baf915d35bc9934b",["categories"]={"AEON","PROJECTILE","ANTINAVY","TORPEDO","NOSPLASHDAMAGE"},["defense"]={["Health"]=1},["collisionRadius"]=1}
