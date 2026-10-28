ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "87e1a314b45cb224421b60d0aef68670ecfdaaa12311b1e269112f0956c25963",
["categories"] = { "CYBRAN", "PROJECTILE", "INDIRECTFIRE", "TACTICAL", "MISSILE", "NOSPLASHDAMAGE" },
["defense"] = {
["Health"] = 1,
["MaxHealth"] = 1,
},
["physics"] = {
["Acceleration"] = 3,
["DestroyOnWater"] = true,
["InitialSpeed"] = 3,
["MaxSpeed"] = 12,
["RotationalVelocity"] = 0,
["RotationalVelocityRange"] = 0,
["TrackTarget"] = true,
["TrackTargetGround"] = true,
["TurnRate"] = 0,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "cifmissiletactical01",
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
["name"] = "cifmissiletactical01",
["tpId"] = "psf0021",
},
["movement"] = {
["acceleration"] = 3,
["rotationSpeed"] = 0,
["speedMax"] = 12,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0021/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0021/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0021/LOD0/psf0021.sanmaterial",
["model"] = "Projectiles/psf0021/LOD0/psf0021.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0021.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="cifmissiletactical01",["blueprintSha256"]="87e1a314b45cb224421b60d0aef68670ecfdaaa12311b1e269112f0956c25963",["categories"]={"CYBRAN","PROJECTILE","INDIRECTFIRE","TACTICAL","MISSILE","NOSPLASHDAMAGE"},["defense"]={["Health"]=1,["MaxHealth"]=1},["collisionRadius"]=1}
