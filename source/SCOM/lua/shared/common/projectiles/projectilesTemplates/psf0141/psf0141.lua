ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "fc6d640a7385c24fc60bc4b9614572461fa0eee4afb2de0b0120f4b92e6456c3",
["categories"] = { "SERAPHIM", "PROJECTILE", "INDIRECTFIRE", "TACTICAL", "MISSILE", "NOSPLASHDAMAGE" },
["defense"] = {
["Health"] = 3,
["MaxHealth"] = 3,
},
["physics"] = {
["Acceleration"] = 3,
["DestroyOnWater"] = false,
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
["sourceId"] = "siflaansetacticalmissilescu",
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
["name"] = "siflaansetacticalmissilescu",
["tpId"] = "psf0141",
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
["particleName"] = "VFX/SCOM/Source/psf0141/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0141/trail.sanvfx",
} },
} },
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0141",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="fc6d640a7385c24fc60bc4b9614572461fa0eee4afb2de0b0120f4b92e6456c3",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vci1241_cannon_artillery_medium_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vct1241_cannon_artillery_medium_trail.sanvfx",
} },
} },
}
end
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0141.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="siflaansetacticalmissilescu",["blueprintSha256"]="fc6d640a7385c24fc60bc4b9614572461fa0eee4afb2de0b0120f4b92e6456c3",["categories"]={"SERAPHIM","PROJECTILE","INDIRECTFIRE","TACTICAL","MISSILE","NOSPLASHDAMAGE"},["defense"]={["Health"]=3,["MaxHealth"]=3},["collisionRadius"]=1}
