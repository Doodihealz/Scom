ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "fe1336c29503afc4042d9be09bbe3f5c74a36076a13dc550049110dd6f8a28e9",
["categories"] = { "UEF", "PROJECTILE", "INDIRECTFIRE", "STRATEGIC", "NOSPLASHDAMAGE", "MISSILE" },
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
["sourceId"] = "tifmissilenuke02",
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
["name"] = "tifmissilenuke02",
["tpId"] = "psf0180",
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
["particleName"] = "VFX/SCOM/Source/psf0180/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0180/LOD0/psf0180.sanmaterial",
["model"] = "Projectiles/psf0180/LOD0/psf0180.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0180.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoTacticalProjectile={["version"]="1.0.0",["sourceId"]="tifmissilenuke02",["targetClass"]=nil,["interceptor"]=false,["sourceNuke"]=true,["health"]=25,["lifetime"]=600,["acceleration"]=3,["maxSpeed"]=40,["turnRate"]=0,["track"]=true,["sourcePhysics"]=true,["destroyOnWater"]=false,["collisionRadius"]=0.1,["nukeProfile"]={["waterAt"]=false,["seraphimMobile"]=false}}
ProjectileTemplate.visuals.scoNukePhases={{["phase"]=1,["boneName"]="SCO_SourceNuke_birth",["particleName"]="VFX/SCOM/Source/psf0180/nuke_birth.sanvfx",["startTime"]=0},{["phase"]=2,["boneName"]="SCO_SourceNuke_launch",["particleName"]="VFX/SCOM/Source/psf0180/nuke_launch.sanvfx",["startTime"]=2.5},{["phase"]=3,["boneName"]="SCO_SourceNuke_thrust",["particleName"]="VFX/SCOM/Source/psf0180/nuke_thrust.sanvfx",["startTime"]=5}}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="tifmissilenuke02",["blueprintSha256"]="fe1336c29503afc4042d9be09bbe3f5c74a36076a13dc550049110dd6f8a28e9",["categories"]={"UEF","PROJECTILE","INDIRECTFIRE","STRATEGIC","NOSPLASHDAMAGE","MISSILE"},["defense"]={["Health"]=25,["MaxHealth"]=25},["collisionRadius"]=2}
