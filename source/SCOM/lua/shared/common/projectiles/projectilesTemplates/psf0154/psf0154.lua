ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "698494d16d9335f66c9d4af60ba47d4893b6ac2b5ba2a3ec1a072dcf1cd0a55d",
["categories"] = { "UEF", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 0,
["DestroyOnWater"] = false,
["InitialSpeed"] = 12,
["InitialSpeedRange"] = 0,
["InitialSpeedReduceDistance"] = 0,
["MaxSpeed"] = 0,
["RotationalVelocity"] = 0,
["RotationalVelocityRange"] = 0,
["TurnRate"] = 360,
["VelocityAlign"] = true,
},
["sourceId"] = "tdfgauss04",
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
["name"] = "tdfgauss04",
["tpId"] = "psf0154",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0154/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0154/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0154/LOD0/psf0154.sanmaterial",
["model"] = "Projectiles/psf0154/LOD0/psf0154.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
},
}

-- SCOM preserved pre-completion projectile visuals 1.0.0
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0154",'Historical projectile identity drift')
assert(tp.additions.scoSourceProjectile.blueprintSha256=="698494d16d9335f66c9d4af60ba47d4893b6ac2b5ba2a3ec1a072dcf1cd0a55d",'Historical projectile source drift')
tp.visuals={
["mesh"] = {
["lod0distance"] = 60,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Impact/vei1301_cannon_large_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/Trails/vet1301_cannon_large_trail.sanvfx",
} },
} },
}
end

-- The historical visuals replacement above drops the source mesh binding.
-- Restore the packed pellet and reuse the installed UEF bomber white trail.
assert(ProjectileTemplate.general.tpId=="psf0154",'Fatboy trail scope changed')
ProjectileTemplate.visuals.persistantEffects={
    {effects={{particleName="VFX/Trails/TrailGeneric_01.sanvfx"}}},
}
ProjectileTemplate.visuals.scoProjectileMesh={
    model="Projectiles/psf0154/LOD0/psf0154.sanmodel",
    -- The shared source Gauss material supports Sanctuary's instance buffer.
    material="Projectiles/psf0151/LOD0/psf0151.sanmaterial",
    scale={x=1,y=1,z=1},
}
