ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "b7cbaaa0b052484adc2af98157f67438930f2ece91cb5414c0611e7414e56e1b",
["categories"] = { "UEF", "PROJECTILE", "ANTIMISSILE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 100,
["VelocityAlign"] = true,
},
["sourceId"] = "tdphalanx01",
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
["name"] = "tdphalanx01",
["tpId"] = "psf0037",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0037/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0037/trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0037.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoTacticalProjectile={["version"]="1.0.0",["sourceId"]="tdphalanx01",["targetClass"]="tactical",["interceptor"]=true,["sourceNuke"]=false,["health"]=1,["lifetime"]=10,["acceleration"]=0,["maxSpeed"]=100,["turnRate"]=0,["track"]=false,["sourcePhysics"]=true,["destroyOnWater"]=true,["collisionRadius"]=0.1}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0037.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0037")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/psf0037/ribbon_0.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/psf0037/ribbon_0.sanvfx",
}
end
