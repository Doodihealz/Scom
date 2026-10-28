ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "2cee3ad455f4b195b06dc6a701d24a42d27524d9bbb901f87ce9e44313355ab5",
["categories"] = { "PROJECTILE", "ANTIMISSILE", "NOSPLASHDAMAGE", "CYBRAN", "DEFENSE" },
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
["sourceId"] = "caadissidentantinuke01",
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
["name"] = "caadissidentantinuke01",
["tpId"] = "psf0005",
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
["particleName"] = "VFX/SCOM/Source/psf0005/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0005/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0005/LOD0/psf0005.sanmaterial",
["model"] = "Projectiles/psf0005/LOD0/psf0005.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0005.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoTacticalProjectile={["version"]="1.0.0",["sourceId"]="caadissidentantinuke01",["targetClass"]="strategic",["interceptor"]=true,["sourceNuke"]=false,["health"]=1,["lifetime"]=10,["acceleration"]=30,["maxSpeed"]=90,["turnRate"]=180,["track"]=true,["sourcePhysics"]=true,["destroyOnWater"]=false,["collisionRadius"]=0.1}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0005.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0005")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_1",
["particleName"] = "VFX/SCOM/Source/psf0005/ribbon_1.sanvfx",
}, {
["boneName"] = "SCO_SourceParticles",
["particleName"] = "VFX/SCOM/Source/psf0005/ribbon_particles.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceParticles"] = "VFX/SCOM/Source/psf0005/ribbon_particles.sanvfx",
["SCO_SourceRibbon_1"] = "VFX/SCOM/Source/psf0005/ribbon_1.sanvfx",
}
end
