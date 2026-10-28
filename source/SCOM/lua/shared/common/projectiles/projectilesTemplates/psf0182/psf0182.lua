ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "199e1c2553b4436e6d90f72a4c3eefbd1fc1c1742017243eb23b7d87eadb81df",
["categories"] = { "SERAPHIM", "PROJECTILE", "INDIRECTFIRE", "STRATEGIC", "MISSILE", "NOSPLASHDAMAGE" },
["defense"] = {
["Health"] = 25,
["MaxHealth"] = 25,
},
["physics"] = {
["Acceleration"] = 3,
["CollideEntity"] = false,
["CollideSurface"] = false,
["DestroyOnWater"] = false,
["InitialSpeed"] = 0,
["Lifetime"] = 600,
["MaxSpeed"] = 40,
["RotationalVelocity"] = 0,
["RotationalVelocityRange"] = 0,
["TrackTarget"] = true,
["TrackTargetGround"] = true,
["TurnRate"] = 0,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "sifinainostrategicmissile02",
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
["name"] = "sifinainostrategicmissile02",
["tpId"] = "psf0182",
},
["movement"] = {
["acceleration"] = 3,
["rotationSpeed"] = 0,
["speedMax"] = 40,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0182/LOD0/psf0182.sanmaterial",
["model"] = "Projectiles/psf0182/LOD0/psf0182.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0182.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoTacticalProjectile={["version"]="1.0.0",["sourceId"]="sifinainostrategicmissile02",["targetClass"]=nil,["interceptor"]=false,["sourceNuke"]=true,["health"]=25,["lifetime"]=600,["acceleration"]=3,["maxSpeed"]=40,["turnRate"]=0,["track"]=true,["sourcePhysics"]=true,["destroyOnWater"]=false,["collisionRadius"]=0.1,["nukeProfile"]={["waterAt"]=7.5,["seraphimMobile"]=true}}
ProjectileTemplate.visuals.scoNukePhases={{["phase"]=1,["boneName"]="SCO_SourceNuke_birth",["particleName"]="VFX/SCOM/Source/psf0182/nuke_birth.sanvfx",["startTime"]=0},{["phase"]=2,["boneName"]="SCO_SourceNuke_launch",["particleName"]="VFX/SCOM/Source/psf0182/nuke_launch.sanvfx",["startTime"]=2.5},{["phase"]=3,["boneName"]="SCO_SourceNuke_thrust",["particleName"]="VFX/SCOM/Source/psf0182/nuke_thrust.sanvfx",["startTime"]=5}}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="sifinainostrategicmissile02",["blueprintSha256"]="199e1c2553b4436e6d90f72a4c3eefbd1fc1c1742017243eb23b7d87eadb81df",["categories"]={"SERAPHIM","PROJECTILE","INDIRECTFIRE","STRATEGIC","MISSILE","NOSPLASHDAMAGE"},["defense"]={["Health"]=25,["MaxHealth"]=25},["collisionRadius"]=2}
