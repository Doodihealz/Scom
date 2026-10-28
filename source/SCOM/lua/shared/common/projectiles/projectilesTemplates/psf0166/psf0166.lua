ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "fd24fa44f96c18b55b2da3f767a7dc85c6bb6556c7e508040d81cd831b754d1e",
["categories"] = { "CYBRAN", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 20,
["UseGravity"] = true,
},
["sourceId"] = "cdfcannonmolecular01",
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
["name"] = "cdfcannonmolecular01",
["tpId"] = "psf0166",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/CybranAcuProjectiles/Impact/vci1301_cannon_plasma_large_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/CybranAcuProjectiles/Trails/vct2101_rocket_antitank_small_trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0166.lua
-- SCOM commander projectile-tail binding 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general and tp.general.tpId=="psf0166",'Commander projectile identity drift')
local groups=assert(tp.visuals and tp.visuals.persistantEffects,'Commander projectile persistent effects missing')
assert(#groups==1,'Commander projectile persistent group count drift')
local effects=assert(groups[1].effects,'Commander projectile persistent effect list missing')
assert(#effects==1,'Commander projectile persistent effect count drift')
local effect=effects[1]
assert(effect.boneName==nil,'Commander projectile trail bone ownership drift')
assert(effect.particleName=="VFX/CybranAcuProjectiles/Trails/vct2101_rocket_antitank_small_trail.sanvfx" or effect.particleName=="VFX/SCOM/Commanders/Cybran/projectile.sanvfx",'Commander projectile trail path drift')
effect.particleName="VFX/SCOM/Commanders/Cybran/projectile.sanvfx"
end
-- SCOM Chosen commander presentation 1.0; visual effects only.
do
    local tp = ProjectileTemplate
    assert(tp.general.tpId == "psf0166", "Commander projectile identity drift")
    tp.visuals.persistantEffects = { { effects = { {
        particleName = "VFX/SCOM/Commanders/ChosenStyle/Cybran/projectile.sanvfx",
    } } } }
    tp.visuals.onImpactEffects = { { effects = { {
        particleName = "VFX/SCOM/Commanders/ChosenStyle/Cybran/impact.sanvfx",
    } } } }
    tp.visuals.scoTrailOwners = nil
end
