ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "9e7aeaf8aa46b735e23aec6af37b4e2d2498c5cc55fd3c488e36791973dd7fc0",
["categories"] = { "UEF", "PROJECTILE", "NOSPLASHDAMAGE", "ANTIMISSILE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 30,
["DestroyOnWater"] = false,
["HitAssignedTarget"] = true,
["LeadTarget"] = true,
["MaxSpeed"] = 90,
["TrackTarget"] = true,
["TurnRate"] = 180,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "timmissileintercerptor01",
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
["name"] = "timmissileintercerptor01",
["tpId"] = "psf0043",
},
["movement"] = {
["acceleration"] = 30,
["rotationSpeed"] = 180,
["speedMax"] = 90,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0043/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0043/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0043/LOD0/psf0043.sanmaterial",
["model"] = "Projectiles/psf0043/LOD0/psf0043.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0043.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoTacticalProjectile={["version"]="1.0.0",["sourceId"]="timmissileintercerptor01",["targetClass"]="strategic",["interceptor"]=true,["sourceNuke"]=false,["health"]=1,["lifetime"]=10,["acceleration"]=30,["maxSpeed"]=90,["turnRate"]=180,["track"]=true,["sourcePhysics"]=true,["destroyOnWater"]=false,["collisionRadius"]=0.1}
