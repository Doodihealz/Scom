ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "d81a018429e6ab63427f4022e9631055e9fc179ee5d693b977fd6b39f225ffa4",
["categories"] = { "CYBRAN", "PROJECTILE", "INDIRECTFIRE", "STRATEGIC", "MISSILE", "NOSPLASHDAMAGE" },
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
["sourceId"] = "cifempfluxwarhead01",
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
["name"] = "cifempfluxwarhead01",
["tpId"] = "psf0020",
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
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0020/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0020/LOD0/psf0020.sanmaterial",
["model"] = "Projectiles/psf0020/LOD0/psf0020.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0020.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoTacticalProjectile={["version"]="1.0.0",["sourceId"]="cifempfluxwarhead01",["targetClass"]=nil,["interceptor"]=false,["sourceNuke"]=true,["health"]=25,["lifetime"]=600,["acceleration"]=3,["maxSpeed"]=40,["turnRate"]=0,["track"]=true,["sourcePhysics"]=true,["destroyOnWater"]=false,["collisionRadius"]=0.1,["nukeProfile"]={["waterAt"]=7.5,["seraphimMobile"]=false}}
ProjectileTemplate.visuals.scoNukePhases={{["phase"]=1,["boneName"]="SCO_SourceNuke_birth",["particleName"]="VFX/SCOM/Source/psf0020/nuke_birth.sanvfx",["startTime"]=0},{["phase"]=2,["boneName"]="SCO_SourceNuke_launch",["particleName"]="VFX/SCOM/Source/psf0020/nuke_launch.sanvfx",["startTime"]=2.5},{["phase"]=3,["boneName"]="SCO_SourceNuke_thrust",["particleName"]="VFX/SCOM/Source/psf0020/nuke_thrust.sanvfx",["startTime"]=5}}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="cifempfluxwarhead01",["blueprintSha256"]="d81a018429e6ab63427f4022e9631055e9fc179ee5d693b977fd6b39f225ffa4",["categories"]={"CYBRAN","PROJECTILE","INDIRECTFIRE","STRATEGIC","MISSILE","NOSPLASHDAMAGE"},["defense"]={["Health"]=25,["MaxHealth"]=25},["collisionRadius"]=2}
