ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "7b202d569eef4aad90622088e11ea80a7be72f7737f9701236fa7a4dd2e759b8",
["categories"] = { "SERAPHIM", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 14.6,
["InitialSpeedRange"] = 3,
["InitialSpeedReduceDistance"] = 30,
["LeadTarget"] = false,
["TurnRate"] = 360,
["VelocityAlign"] = true,
},
["sourceId"] = "sdfsnipershot02",
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
["name"] = "sdfsnipershot02",
["tpId"] = "psf0173",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0173/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0173/trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0173.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0173")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_1",
["particleName"] = "VFX/SCOM/Source/psf0173/ribbon_1.sanvfx",
}, {
["boneName"] = "SCO_SourceRibbon_2",
["particleName"] = "VFX/SCOM/Source/psf0173/ribbon_2.sanvfx",
}, {
["boneName"] = "SCO_SourceParticles",
["particleName"] = "VFX/SCOM/Source/psf0173/ribbon_particles.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceParticles"] = "VFX/SCOM/Source/psf0173/ribbon_particles.sanvfx",
["SCO_SourceRibbon_1"] = "VFX/SCOM/Source/psf0173/ribbon_1.sanvfx",
["SCO_SourceRibbon_2"] = "VFX/SCOM/Source/psf0173/ribbon_2.sanvfx",
}
end
