ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "0ad044add942af4aa3d8b092aa2ba5a592074db5df0a27564d831411ea86ed1d",
["categories"] = { "AEON", "PROJECTILE", "ANTIAIR", "MISSILE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 6,
["DestroyOnWater"] = true,
["InitialSpeed"] = 30,
["LeadTarget"] = false,
["Lifetime"] = 4,
["MaxSpeed"] = 50,
["OnLostTargetLifetime"] = 0.7,
["TrackTarget"] = true,
["TurnRate"] = 180,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "aaazealotmissile01",
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
["name"] = "aaazealotmissile01",
["tpId"] = "psf0049",
},
["movement"] = {
["acceleration"] = 6,
["rotationSpeed"] = 180,
["speedMax"] = 50,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0049/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0049/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0049/LOD0/psf0049.sanmaterial",
["model"] = "Projectiles/psf0049/LOD0/psf0049.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0049.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0049")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/psf0049/ribbon_0.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/psf0049/ribbon_0.sanvfx",
}
end
