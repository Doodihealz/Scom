ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "27f4839a8b5b048073055a42fc728537303e8fae0a28266fe6674fbdb18bbc8f",
["categories"] = { "UEF", "PROJECTILE", "ANTIAIR" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 120,
["Lifetime"] = 2.5,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "taarailgun03",
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
["name"] = "taarailgun03",
["tpId"] = "psf0026",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0026/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0026/trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0026.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0026")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/psf0026/ribbon_0.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/psf0026/ribbon_0.sanvfx",
}
end
