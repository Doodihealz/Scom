ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "a8b70128eafed73ed55f29667a1c1550858d20b8e13577526221bfee24057332",
["categories"] = { "CYBRAN", "PROJECTILE", "INDIRECTFIRE", "TACTICAL", "MISSILE", "NOSPLASHDAMAGE" },
["defense"] = {
["Health"] = 1,
["MaxHealth"] = 1,
},
["physics"] = {
["Acceleration"] = 15,
["DestroyOnWater"] = false,
["InitialSpeed"] = 2,
["MaxSpeed"] = 25,
["RotationalVelocity"] = 0,
["RotationalVelocityRange"] = 0,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "cifmissiletacticalsplit01",
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
["name"] = "cifmissiletacticalsplit01",
["tpId"] = "psf0190",
},
["movement"] = {
["acceleration"] = 15,
["rotationSpeed"] = 0,
["speedMax"] = 25,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0190/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0190/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0190/LOD0/psf0190.sanmaterial",
["model"] = "Projectiles/psf0190/LOD0/psf0190.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0190.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="cifmissiletacticalsplit01",["blueprintSha256"]="a8b70128eafed73ed55f29667a1c1550858d20b8e13577526221bfee24057332",["categories"]={"CYBRAN","PROJECTILE","INDIRECTFIRE","TACTICAL","MISSILE","NOSPLASHDAMAGE"},["defense"]={["Health"]=1,["MaxHealth"]=1},["collisionRadius"]=1}
