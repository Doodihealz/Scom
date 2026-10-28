ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "66ab89d85182d90bd64e9c47796a38e6fd73d2d798ce9137723137c37a99c207",
["categories"] = { "SERAPHIM", "PROJECTILE", "ANTINAVY", "TORPEDO" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 5,
["DestroyOnWater"] = false,
["InitialSpeed"] = 3,
["Lifetime"] = 7,
["MaxSpeed"] = 18,
["StayUnderwater"] = true,
["TrackTarget"] = true,
["TurnRate"] = 230,
["VelocityAlign"] = true,
},
["sourceId"] = "sanuallcavitationtorpedo03",
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
["name"] = "sanuallcavitationtorpedo03",
["tpId"] = "psf0120",
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
["particleName"] = "VFX/SCOM/Source/psf0120/trail.sanvfx",
} },
} },
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0120",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="66ab89d85182d90bd64e9c47796a38e6fd73d2d798ce9137723137c37a99c207",'Historical projectile source drift')
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
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0120.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="sanuallcavitationtorpedo03",["blueprintSha256"]="66ab89d85182d90bd64e9c47796a38e6fd73d2d798ce9137723137c37a99c207",["categories"]={"SERAPHIM","PROJECTILE","ANTINAVY","TORPEDO"},["defense"]={},["collisionRadius"]=1}
