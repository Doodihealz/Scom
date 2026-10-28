ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "7f2cd42737a1e2acb1f257aacfe2a84dde7ae31d728ddbb179d789dd024ad10d",
["categories"] = { "SERAPHIM", "PROJECTILE", "ANTIMISSILE" },
["defense"] = {
["Health"] = 1,
["MaxHealth"] = 1,
},
["physics"] = {
["Acceleration"] = 90,
["DestroyOnWater"] = false,
["LeadTarget"] = false,
["MaxSpeed"] = 90,
["TrackTarget"] = true,
["TurnRate"] = 720,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "simantimissile02",
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
["x"] = 0.5,
["y"] = 0.5,
["z"] = 0.5,
},
},
["general"] = {
["name"] = "simantimissile02",
["tpId"] = "psf0179",
},
["movement"] = {
["acceleration"] = 90,
["rotationSpeed"] = 720,
["speedMax"] = 90,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0179/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0179/trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0179.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoTacticalProjectile={["version"]="1.0.0",["sourceId"]="simantimissile02",["targetClass"]="tactical",["interceptor"]=true,["sourceNuke"]=false,["health"]=1,["lifetime"]=10,["acceleration"]=90,["maxSpeed"]=90,["turnRate"]=720,["track"]=true,["sourcePhysics"]=true,["destroyOnWater"]=false,["collisionRadius"]=0.1}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0179.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0179")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/psf0179/ribbon_0.sanvfx",
}, {
["boneName"] = "SCO_SourceRibbon_1",
["particleName"] = "VFX/SCOM/Source/psf0179/ribbon_1.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/psf0179/ribbon_0.sanvfx",
["SCO_SourceRibbon_1"] = "VFX/SCOM/Source/psf0179/ribbon_1.sanvfx",
}
end
