ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "f402241e24e5f2e0ba2a1c9f1930308c0c988c5b9500f7404511a199d0f1d2a5",
["categories"] = { "SERAPHIM", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 14.6,
["InitialSpeedRange"] = 3,
["InitialSpeedReduceDistance"] = 30,
["LeadTarget"] = false,
["RotationalVelocity"] = 900,
["TurnRate"] = 360,
["VelocityAlign"] = true,
},
["sourceId"] = "sdfchronatroncannon01",
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
["name"] = "sdfchronatroncannon01",
["tpId"] = "psf0169",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0169/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0169/trail.sanvfx",
} },
} },
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0169",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="f402241e24e5f2e0ba2a1c9f1930308c0c988c5b9500f7404511a199d0f1d2a5",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vct2101_rocket_antitank_small_trail.sanvfx",
} },
} },
}
end
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0169.lua
-- SCOM commander projectile-tail binding 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general and tp.general.tpId=="psf0169",'Commander projectile identity drift')
local groups=assert(tp.visuals and tp.visuals.persistantEffects,'Commander projectile persistent effects missing')
assert(#groups==1,'Commander projectile persistent group count drift')
local effects=assert(groups[1].effects,'Commander projectile persistent effect list missing')
assert(#effects==1,'Commander projectile persistent effect count drift')
local effect=effects[1]
assert(effect.boneName==nil,'Commander projectile trail bone ownership drift')
assert(effect.particleName=="VFX/Trails/vct2101_rocket_antitank_small_trail.sanvfx" or effect.particleName=="VFX/SCOM/Commanders/Seraphim/projectile.sanvfx",'Commander projectile trail path drift')
effect.particleName="VFX/SCOM/Commanders/Seraphim/projectile.sanvfx"
end
-- SCOM Chosen commander presentation 1.0; visual effects only.
do
    local tp = ProjectileTemplate
    assert(tp.general.tpId == "psf0169", "Commander projectile identity drift")
    tp.visuals.persistantEffects = { { effects = { {
        particleName = "VFX/SCOM/Commanders/ChosenStyle/Seraphim/projectile.sanvfx",
    } } } }
    tp.visuals.onImpactEffects = { { effects = { {
        particleName = "VFX/SCOM/Commanders/ChosenStyle/Seraphim/ACUImpact/impact.sanvfx",
    } } } }
    tp.visuals.scoTrailOwners = nil
end
