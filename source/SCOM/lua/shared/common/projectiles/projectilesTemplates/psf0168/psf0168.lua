ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "4a1d33796c7896993dbee6f3a309a4ff56fa0c97900b1e3f702aafcf363437fe",
["categories"] = {  },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 17,
["Lifetime"] = 2.5,
["UseGravity"] = true,
},
["sourceId"] = "laserbotterran01",
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
["name"] = "laserbotterran01",
["tpId"] = "psf0168",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0168/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/FieldFixes/UEFAcu/uef_acu_blue_projectile.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0168.lua
-- SCOM commander projectile-tail binding 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general and tp.general.tpId=="psf0168",'Commander projectile identity drift')
local groups=assert(tp.visuals and tp.visuals.persistantEffects,'Commander projectile persistent effects missing')
assert(#groups==1,'Commander projectile persistent group count drift')
local effects=assert(groups[1].effects,'Commander projectile persistent effect list missing')
assert(#effects==1,'Commander projectile persistent effect count drift')
local effect=effects[1]
assert(effect.boneName==nil,'Commander projectile trail bone ownership drift')
assert(effect.particleName=="VFX/SCOM/FieldFixes/UEFAcu/uef_acu_blue_projectile.sanvfx",'Commander projectile trail path drift')
effect.particleName="VFX/SCOM/FieldFixes/UEFAcu/uef_acu_blue_projectile.sanvfx"
end
-- SCOM Chosen commander presentation 1.0; visual effects only.
do
    local tp = ProjectileTemplate
    assert(tp.general.tpId == "psf0168", "Commander projectile identity drift")
    tp.visuals.persistantEffects = { { effects = { {
        particleName = "VFX/SCOM/Commanders/ChosenStyle/UEF/projectile.sanvfx",
    } } } }
    tp.visuals.onImpactEffects = { { effects = { {
        particleName = "VFX/SCOM/Commanders/ChosenStyle/UEF/impact.sanvfx",
    } } } }
    tp.visuals.scoTrailOwners = nil
end
