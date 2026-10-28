ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "a309f59a614da7d823a027590852dda8d7b69699bc078af7a4077dd02be582b9",
["categories"] = { "PROJECTILE", "ANTIMISSILE", "NOSPLASHDAMAGE", "SERAPHIM" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 30,
["DestroyOnWater"] = false,
["HitAssignedTarget"] = true,
["LeadTarget"] = true,
["MaxSpeed"] = 90,
["TrackTarget"] = true,
["TurnRate"] = 180,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "sifhuantinuke01",
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
["name"] = "sifhuantinuke01",
["tpId"] = "psf0137",
},
["movement"] = {
["acceleration"] = 30,
["rotationSpeed"] = 180,
["speedMax"] = 90,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0137/trail.sanvfx",
} },
} },
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0137",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="a309f59a614da7d823a027590852dda8d7b69699bc078af7a4077dd02be582b9",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vci3121_cannon_antiair_small_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vct3121_cannon_antiair_small_trail.sanvfx",
} },
} },
}
end
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0137.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoTacticalProjectile={["version"]="1.0.0",["sourceId"]="sifhuantinuke01",["targetClass"]="strategic",["interceptor"]=true,["sourceNuke"]=false,["health"]=1,["lifetime"]=10,["acceleration"]=30,["maxSpeed"]=90,["turnRate"]=180,["track"]=true,["sourcePhysics"]=true,["destroyOnWater"]=false,["collisionRadius"]=0.1}
