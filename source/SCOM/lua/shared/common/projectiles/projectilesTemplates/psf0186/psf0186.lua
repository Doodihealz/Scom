ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "d9c3b045ac3c0836b93187799d97ee44afa8bbda40030885325c376dac007664",
["categories"] = { "AEON", "PROJECTILE", "MISSILE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 5,
["DestroyOnWater"] = true,
["InitialSpeed"] = 15,
["LeadTarget"] = false,
["Lifetime"] = 10,
["MaxSpeed"] = 35,
["MaxZigZag"] = 10,
["TrackTarget"] = false,
["TurnRate"] = 180,
["UseGravity"] = false,
["VelocityAlign"] = true,
["ZigZagFrequency"] = 0.2,
},
["sourceId"] = "aifguidedmissile02",
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
["name"] = "aifguidedmissile02",
["tpId"] = "psf0186",
},
["movement"] = {
["acceleration"] = 5,
["rotationSpeed"] = 180,
["speedMax"] = 35,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0186/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0186/trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0186.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0186")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_1",
["particleName"] = "VFX/SCOM/Source/psf0186/ribbon_1.sanvfx",
}, {
["boneName"] = "SCO_SourceParticles",
["particleName"] = "VFX/SCOM/Source/psf0186/ribbon_particles.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceParticles"] = "VFX/SCOM/Source/psf0186/ribbon_particles.sanvfx",
["SCO_SourceRibbon_1"] = "VFX/SCOM/Source/psf0186/ribbon_1.sanvfx",
}
end
