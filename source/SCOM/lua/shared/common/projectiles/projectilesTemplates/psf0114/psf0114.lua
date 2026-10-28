ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "0d0ed1dc06f64074e1b8e963ef90006aae41b11c6089162046c47856e9a6ea5e",
["categories"] = { "SERAPHIM", "PROJECTILE", "ANTITORPEDO" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = false,
["InitialSpeed"] = 120,
["Lifetime"] = 0.5,
["MaxSpeed"] = 30,
["StayUnderwater"] = true,
["TrackTarget"] = true,
["TurnRate"] = 360,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "sanajelluantitorpedo01",
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
["name"] = "sanajelluantitorpedo01",
["tpId"] = "psf0114",
},
["movement"] = {
["acceleration"] = 0,
["rotationSpeed"] = 360,
["speedMax"] = 30,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0114/trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0114.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoTacticalProjectile={["version"]="1.0.0",["sourceId"]="sanajelluantitorpedo01",["targetClass"]="torpedo",["interceptor"]=true,["sourceNuke"]=false,["health"]=1,["lifetime"]=7,["acceleration"]=0,["maxSpeed"]=30,["turnRate"]=0,["track"]=false,["sourcePhysics"]=true,["destroyOnWater"]=false,["collisionRadius"]=1}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0114.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0114")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/psf0114/ribbon_0.sanvfx",
}, {
["boneName"] = "SCO_SourceRibbon_1",
["particleName"] = "VFX/SCOM/Source/psf0114/ribbon_1.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/psf0114/ribbon_0.sanvfx",
["SCO_SourceRibbon_1"] = "VFX/SCOM/Source/psf0114/ribbon_1.sanvfx",
}
end
