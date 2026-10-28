ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "889c17e6fb8a833d67ad146ffc55e8cd93724071f2a99e85dcaa379c7941525a",
["categories"] = { "PROJECTILE", "ANTIMISSILE", "NOSPLASHDAMAGE", "AEON" },
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
["sourceId"] = "aimsaintantinuke01",
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
["name"] = "aimsaintantinuke01",
["tpId"] = "psf0079",
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
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0079/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0079/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0079/LOD0/psf0079.sanmaterial",
["model"] = "Projectiles/psf0079/LOD0/psf0079.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0079",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="889c17e6fb8a833d67ad146ffc55e8cd93724071f2a99e85dcaa379c7941525a",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Impact/vci1341_cannon_artillery_large_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Trails/vct1341_cannon_artillery_large_trail.sanvfx",
} },
} },
}
end
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0079.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoTacticalProjectile={["version"]="1.0.0",["sourceId"]="aimsaintantinuke01",["targetClass"]="strategic",["interceptor"]=true,["sourceNuke"]=false,["health"]=1,["lifetime"]=10,["acceleration"]=30,["maxSpeed"]=90,["turnRate"]=180,["track"]=true,["sourcePhysics"]=true,["destroyOnWater"]=false,["collisionRadius"]=0.1}
