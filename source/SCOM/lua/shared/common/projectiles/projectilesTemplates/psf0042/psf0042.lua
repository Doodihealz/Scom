ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "2cfabdf953653df30a5b5fe4359c0d05d376046632560e749256624dd0f21082",
["categories"] = { "UEF", "PROJECTILE", "ANTITORPEDO" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 1,
["DestroyOnWater"] = false,
["MaxSpeed"] = 3,
["StayUnderwater"] = false,
["TrackTarget"] = false,
["TurnRate"] = 270,
["UseGravity"] = true,
["VelocityAlign"] = true,
},
["sourceId"] = "timantitorpedo01",
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
["name"] = "timantitorpedo01",
["tpId"] = "psf0042",
},
["movement"] = {
["acceleration"] = 1,
["rotationSpeed"] = 270,
["speedMax"] = 3,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0042/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0042/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0042/LOD0/psf0042.sanmaterial",
["model"] = "Projectiles/psf0042/LOD0/psf0042.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0042.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoTacticalProjectile={["version"]="1.0.0",["sourceId"]="timantitorpedo01",["targetClass"]="torpedo",["interceptor"]=true,["sourceNuke"]=false,["health"]=1,["lifetime"]=6,["acceleration"]=1,["maxSpeed"]=3,["turnRate"]=0,["track"]=false,["sourcePhysics"]=true,["destroyOnWater"]=false,["collisionRadius"]=1}
