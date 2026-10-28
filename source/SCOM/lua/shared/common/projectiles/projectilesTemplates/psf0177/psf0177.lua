ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "a1d52136a62a120571f906856312d15889702ec946323a10edce319c1b935215",
["categories"] = { "AEON", "PROJECTILE", "ANTITORPEDO" },
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
["sourceId"] = "aimantitorpedo02",
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
["name"] = "aimantitorpedo02",
["tpId"] = "psf0177",
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
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0177/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0177/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0177/LOD0/psf0177.sanmaterial",
["model"] = "Projectiles/psf0177/LOD0/psf0177.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0177.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0177")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/psf0177/ribbon_0.sanvfx",
}, {
["boneName"] = "SCO_SourceRibbon_1",
["particleName"] = "VFX/SCOM/Source/psf0177/ribbon_1.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/psf0177/ribbon_0.sanvfx",
["SCO_SourceRibbon_1"] = "VFX/SCOM/Source/psf0177/ribbon_1.sanvfx",
}
end
