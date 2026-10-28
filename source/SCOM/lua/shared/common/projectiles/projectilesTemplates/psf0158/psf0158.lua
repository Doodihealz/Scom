ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "52c3df44df89d8dcea319e60a35ec7c5068a9fe2cfa51d78b81d1972ea694b4d",
["categories"] = { "UEF", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 12,
["LeadTarget"] = false,
["Lifetime"] = 4,
["UseGravity"] = true,
},
["sourceId"] = "tdfplasmaheavy04",
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
["name"] = "tdfplasmaheavy04",
["tpId"] = "psf0158",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0158/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0158/trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0158.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0158")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_1",
["particleName"] = "VFX/SCOM/Source/psf0158/ribbon_1.sanvfx",
}, {
["boneName"] = "SCO_SourceRibbon_2",
["particleName"] = "VFX/SCOM/Source/psf0158/ribbon_2.sanvfx",
}, {
["boneName"] = "SCO_SourceRibbon_3",
["particleName"] = "VFX/SCOM/Source/psf0158/ribbon_3.sanvfx",
}, {
["boneName"] = "SCO_SourceParticles",
["particleName"] = "VFX/SCOM/Source/psf0158/ribbon_particles.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceParticles"] = "VFX/SCOM/Source/psf0158/ribbon_particles.sanvfx",
["SCO_SourceRibbon_1"] = "VFX/SCOM/Source/psf0158/ribbon_1.sanvfx",
["SCO_SourceRibbon_2"] = "VFX/SCOM/Source/psf0158/ribbon_2.sanvfx",
["SCO_SourceRibbon_3"] = "VFX/SCOM/Source/psf0158/ribbon_3.sanvfx",
}
end

-- Titan: isolated blue Chosen commander presentation; simulation is unchanged.
do
    local tp = ProjectileTemplate
    assert(tp.general.tpId == "psf0158", "Titan projectile identity drift")
    tp.visuals.persistantEffects = { { effects = { {
        particleName = "VFX/SCOM/Titan/projectile.sanvfx",
    } } } }
    tp.visuals.onImpactEffects = { { effects = { {
        particleName = "VFX/SCOM/Titan/impact.sanvfx",
    } } } }
    tp.visuals.scoTrailOwners = nil
end
