ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "5ba9eecbde5e838b724cabd2c0cb774e554b853355722c20bba7fbb6a489de42",
["categories"] = { "SERAPHIM", "PROJECTILE", "ANTINAVY", "TORPEDO" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 5,
["DestroyOnWater"] = false,
["InitialSpeed"] = 5,
["MaxSpeed"] = 18,
["StayUnderwater"] = true,
["TrackTarget"] = true,
["TurnRate"] = 230,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "sanheavycavitationtorpedo02",
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
["name"] = "sanheavycavitationtorpedo02",
["tpId"] = "psf0117",
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
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0117/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0117/trail.sanvfx",
} },
} },
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0117",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="5ba9eecbde5e838b724cabd2c0cb774e554b853355722c20bba7fbb6a489de42",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vci1141_cannon_artillery_small_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vct1141_cannon_artillery_small_trail.sanvfx",
} },
} },
}
end
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0117.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="sanheavycavitationtorpedo02",["blueprintSha256"]="5ba9eecbde5e838b724cabd2c0cb774e554b853355722c20bba7fbb6a489de42",["categories"]={"SERAPHIM","PROJECTILE","ANTINAVY","TORPEDO"},["defense"]={},["collisionRadius"]=1}
