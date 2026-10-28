ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "67f49f2d714889a4a98af6bb6bac6a239ab9886f83801568f8bba4ff18702ed9",
["categories"] = { "CYBRAN", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 15,
["ProjectileLifetime"] = 1.5,
["UseGravity"] = true,
},
["sourceId"] = "cdflaserdisintegrator04",
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
["name"] = "cdflaserdisintegrator04",
["tpId"] = "psf0016",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0016/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0016/trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0016.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0016")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_1",
["particleName"] = "VFX/SCOM/Source/psf0016/ribbon_1.sanvfx",
}, {
["boneName"] = "SCO_SourceRibbon_2",
["particleName"] = "VFX/SCOM/Source/psf0016/ribbon_2.sanvfx",
}, {
["boneName"] = "SCO_SourceRibbon_3",
["particleName"] = "VFX/SCOM/Source/psf0016/ribbon_3.sanvfx",
}, {
["boneName"] = "SCO_SourceParticles",
["particleName"] = "VFX/SCOM/Source/psf0016/ribbon_particles.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceParticles"] = "VFX/SCOM/Source/psf0016/ribbon_particles.sanvfx",
["SCO_SourceRibbon_1"] = "VFX/SCOM/Source/psf0016/ribbon_1.sanvfx",
["SCO_SourceRibbon_2"] = "VFX/SCOM/Source/psf0016/ribbon_2.sanvfx",
["SCO_SourceRibbon_3"] = "VFX/SCOM/Source/psf0016/ribbon_3.sanvfx",
}
end
