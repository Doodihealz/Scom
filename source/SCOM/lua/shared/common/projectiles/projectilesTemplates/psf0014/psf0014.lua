ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "b5c66bca4309d82db0d0cad6765a639f1753435083fb627afc06ee2f04f391b3",
["categories"] = { "CYBRAN", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 15,
["ProjectileLifetime"] = 1.5,
["UseGravity"] = false,
},
["sourceId"] = "cdflaserdisintegrator01",
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
["name"] = "cdflaserdisintegrator01",
["tpId"] = "psf0014",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0014/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0014/trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0014.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0014")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/psf0014/ribbon_0.sanvfx",
}, {
["boneName"] = "SCO_SourceRibbon_1",
["particleName"] = "VFX/SCOM/Source/psf0014/ribbon_1.sanvfx",
}, {
["boneName"] = "SCO_SourceRibbon_2",
["particleName"] = "VFX/SCOM/Source/psf0014/ribbon_2.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/psf0014/ribbon_0.sanvfx",
["SCO_SourceRibbon_1"] = "VFX/SCOM/Source/psf0014/ribbon_1.sanvfx",
["SCO_SourceRibbon_2"] = "VFX/SCOM/Source/psf0014/ribbon_2.sanvfx",
}
end
