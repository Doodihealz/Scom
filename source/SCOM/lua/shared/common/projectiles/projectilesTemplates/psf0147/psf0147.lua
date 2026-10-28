ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "2d5d6c90b778d3d52454d893bfd0d85f2cbfda876474f85c0901373928d40558",
["categories"] = { "UEF", "PROJECTILE", "ANTIAIR" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 32,
["Lifetime"] = 2,
["RotationalVelocity"] = 0,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "taarailgun02",
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
["name"] = "taarailgun02",
["tpId"] = "psf0147",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0147/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0147/trail.sanvfx",
} },
} },
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0147",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="2d5d6c90b778d3d52454d893bfd0d85f2cbfda876474f85c0901373928d40558",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vei7601_railgun_flak_medium_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vet1121_autocannon_small_trail.sanvfx",
} },
} },
}
end
