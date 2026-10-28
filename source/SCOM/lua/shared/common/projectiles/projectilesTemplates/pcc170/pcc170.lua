ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "f25503b46c9fb155abaf27e668adf12e1d940e49683ee5f395b018b463272312",
["categories"] = { "SERAPHIM", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 14.6,
["InitialSpeedRange"] = 3,
["InitialSpeedReduceDistance"] = 30,
["LeadTarget"] = false,
["RotationalVelocity"] = 9000,
["TurnRate"] = 360,
["VelocityAlign"] = true,
},
["sourceId"] = "sdflightchronatroncannon01",
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
["name"] = "sdflightchronatroncannon01",
["tpId"] = "psf0170",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0170/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0170/trail.sanvfx",
} },
} },
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0170",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="f25503b46c9fb155abaf27e668adf12e1d940e49683ee5f395b018b463272312",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["audioName"] = "EDA_Impacts_Random",
["particleName"] = "VFX/Impact/vci1101_cannon_plasma_small_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vct1101_cannon_plasma_small_trail.sanvfx",
} },
} },
}
end
-- SCOM Chosen commander presentation 1.0; visual effects only.
do
    local tp = ProjectileTemplate
    assert(tp.general.tpId == "psf0170", "Commander projectile identity drift")
    tp.general.tpId = "pcc170"
    tp.visuals.persistantEffects = { { effects = { {
        particleName = "VFX/SCOM/Commanders/ChosenStyle/Seraphim/projectile.sanvfx",
    } } } }
    tp.visuals.onImpactEffects = { { effects = { {
        particleName = "VFX/SCOM/Commanders/ChosenStyle/Seraphim/impact.sanvfx",
    } } } }
    tp.visuals.scoTrailOwners = nil
end
