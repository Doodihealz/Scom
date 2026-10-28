ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "21bb399873c7fc9f5b5eb47767b95139753d54420020c748d02a0d7df06ab753",
["categories"] = { "CYBRAN", "PROJECTILE", "ANTINAVY", "TORPEDO" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 5,
["DestroyOnWater"] = false,
["InitialSpeed"] = 5,
["MaxSpeed"] = 18,
["RotationalVelocity"] = 800,
["StayUnderwater"] = true,
["TrackTarget"] = true,
["TurnRate"] = 230,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "cankriltorpedo01",
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
["name"] = "cankriltorpedo01",
["tpId"] = "psf0011",
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
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0011/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0011/LOD0/psf0011.sanmaterial",
["model"] = "Projectiles/psf0011/LOD0/psf0011.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0011.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="cankriltorpedo01",["blueprintSha256"]="21bb399873c7fc9f5b5eb47767b95139753d54420020c748d02a0d7df06ab753",["categories"]={"CYBRAN","PROJECTILE","ANTINAVY","TORPEDO"},["defense"]={},["collisionRadius"]=1}
