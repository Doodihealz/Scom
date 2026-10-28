ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "825a3b3f540ce39054c8e58192feacaace1300b727709307d5cf1b9b116b6339",
["categories"] = { "CYBRAN", "PROJECTILE", "ANTITORPEDO" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 1,
["DestroyOnWater"] = false,
["MaxSpeed"] = 3,
["StayUnderwater"] = false,
["TrackTarget"] = true,
["TurnRate"] = 270,
["UseGravity"] = true,
["VelocityAlign"] = true,
},
["sourceId"] = "cimantitorpedo01",
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
["name"] = "cimantitorpedo01",
["tpId"] = "psf0022",
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
["particleName"] = "VFX/SCOM/Source/psf0022/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0022/trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0022.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoTacticalProjectile={["version"]="1.0.0",["sourceId"]="cimantitorpedo01",["targetClass"]="torpedo",["interceptor"]=true,["sourceNuke"]=false,["health"]=1,["lifetime"]=6,["acceleration"]=1,["maxSpeed"]=3,["turnRate"]=0,["track"]=false,["sourcePhysics"]=true,["destroyOnWater"]=false,["collisionRadius"]=1}
