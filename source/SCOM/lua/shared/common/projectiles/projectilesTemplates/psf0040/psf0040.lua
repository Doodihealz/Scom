ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "364af3f0788095b8fba64d307bd75bcc0ad4c903e09b2ad1e08558102246b0cc",
["categories"] = { "UEF", "PROJECTILE", "INDIRECTFIRE", "STRATEGIC", "MISSILE", "NOSPLASHDAMAGE" },
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
["MaxSpeed"] = 30,
["RotationalVelocity"] = 0,
["RotationalVelocityRange"] = 0,
["TrackTarget"] = true,
["TrackTargetGround"] = true,
["TurnRate"] = 0,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "tifmissilenuke01",
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
["name"] = "tifmissilenuke01",
["tpId"] = "psf0040",
},
["movement"] = {
["acceleration"] = 3,
["rotationSpeed"] = 0,
["speedMax"] = 30,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0040/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0040/LOD0/psf0040.sanmaterial",
["model"] = "Projectiles/psf0040/LOD0/psf0040.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0040.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoTacticalProjectile={["version"]="1.0.0",["sourceId"]="tifmissilenuke01",["targetClass"]=nil,["interceptor"]=false,["sourceNuke"]=true,["health"]=25,["lifetime"]=600,["acceleration"]=3,["maxSpeed"]=30,["turnRate"]=0,["track"]=true,["sourcePhysics"]=true,["destroyOnWater"]=false,["collisionRadius"]=0.1,["nukeProfile"]={["waterAt"]=7.5,["seraphimMobile"]=false}}
ProjectileTemplate.visuals.scoNukePhases={{["phase"]=1,["boneName"]="SCO_SourceNuke_birth",["particleName"]="VFX/SCOM/Source/psf0040/nuke_birth.sanvfx",["startTime"]=0},{["phase"]=2,["boneName"]="SCO_SourceNuke_launch",["particleName"]="VFX/SCOM/Source/psf0040/nuke_launch.sanvfx",["startTime"]=2.5},{["phase"]=3,["boneName"]="SCO_SourceNuke_thrust",["particleName"]="VFX/SCOM/Source/psf0040/nuke_thrust.sanvfx",["startTime"]=5}}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="tifmissilenuke01",["blueprintSha256"]="364af3f0788095b8fba64d307bd75bcc0ad4c903e09b2ad1e08558102246b0cc",["categories"]={"UEF","PROJECTILE","INDIRECTFIRE","STRATEGIC","MISSILE","NOSPLASHDAMAGE"},["defense"]={["Health"]=25,["MaxHealth"]=25},["collisionRadius"]=2}
