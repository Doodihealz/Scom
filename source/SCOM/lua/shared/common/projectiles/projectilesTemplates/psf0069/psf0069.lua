ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "000b0998a3aced342412a08b60560e0b9ec3fec92bdb158cc13501713a71b4dd",
["categories"] = { "AEON", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 14,
["InitialSpeedRange"] = 5,
["Lifetime"] = 1.5,
["UseGravity"] = true,
["VelocityAlign"] = true,
},
["sourceId"] = "adfreactoncannon01",
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
["name"] = "adfreactoncannon01",
["tpId"] = "psf0069",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0069/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0069/trail.sanvfx",
} },
} },
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0069",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="000b0998a3aced342412a08b60560e0b9ec3fec92bdb158cc13501713a71b4dd",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Impact/vci1301_cannon_plasma_large_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/AeonProjectiles/Trails/vct1301_cannon_plasma_large_trail.sanvfx",
} },
} },
}
end
-- SCOM Chosen commander presentation 1.0; visual effects only.
do
    local tp = ProjectileTemplate
    assert(tp.general.tpId == "psf0069", "Commander projectile identity drift")
    tp.visuals.persistantEffects = { { effects = { {
        particleName = "VFX/SCOM/Commanders/ChosenStyle/Aeon/projectile.sanvfx",
    } } } }
    tp.visuals.onImpactEffects = { { effects = { {
        particleName = "VFX/SCOM/Commanders/ChosenStyle/Aeon/impact.sanvfx",
    } } } }
    tp.visuals.scoTrailOwners = nil
end
