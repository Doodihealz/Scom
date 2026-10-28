ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "2bf0ec1910fb2ca15841927ced82fefd0b01d8b25ab7f0e34921f64c475bef21",
["categories"] = { "AEON", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 28,
["VelocityAlign"] = true,
},
["sourceId"] = "adfquantumdisruptor01",
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
["name"] = "adfquantumdisruptor01",
["tpId"] = "psf0165",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0165/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0165/trail.sanvfx",
} },
} },
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0165",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="2bf0ec1910fb2ca15841927ced82fefd0b01d8b25ab7f0e34921f64c475bef21",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Impact/vci1201_cannon_plasma_medium_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Trails/vct1201_cannon_plasma_medium_trail.sanvfx",
} },
} },
}
end
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0165.lua
-- SCOM commander projectile-tail binding 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general and tp.general.tpId=="psf0165",'Commander projectile identity drift')
local groups=assert(tp.visuals and tp.visuals.persistantEffects,'Commander projectile persistent effects missing')
assert(#groups==1,'Commander projectile persistent group count drift')
local effects=assert(groups[1].effects,'Commander projectile persistent effect list missing')
assert(#effects==1,'Commander projectile persistent effect count drift')
local effect=effects[1]
assert(effect.boneName==nil,'Commander projectile trail bone ownership drift')
assert(effect.particleName=="VFX/AeonProjectiles/Trails/vct1201_cannon_plasma_medium_trail.sanvfx" or effect.particleName=="VFX/SCOM/Commanders/Aeon/projectile.sanvfx",'Commander projectile trail path drift')
effect.particleName="VFX/SCOM/Commanders/Aeon/projectile.sanvfx"
end
-- SCOM Chosen commander presentation 1.0; visual effects only.
do
    local tp = ProjectileTemplate
    assert(tp.general.tpId == "psf0165", "Commander projectile identity drift")
    tp.visuals.persistantEffects = { { effects = { {
        particleName = "VFX/SCOM/Commanders/ChosenStyle/Aeon/projectile.sanvfx",
    } } } }
    tp.visuals.onImpactEffects = { { effects = { {
        particleName = "VFX/SCOM/Commanders/ChosenStyle/Aeon/impact.sanvfx",
    } } } }
    tp.visuals.scoTrailOwners = nil
end
