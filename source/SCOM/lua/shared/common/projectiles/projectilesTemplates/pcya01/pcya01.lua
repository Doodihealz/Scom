---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = {
            x = 0,
            y = 0.5,
            z = 0,
        },
        collisionSize = {
            x = 1,
            y = 1,
            z = 1,
        },
    },
    general = {
        name = "Chosen_Autocannon_Plasma_Small",
        tpId = "pcya01",
    },
    nonUniformScale = {
        x = 1,
        y = 1,
        z = 1,
    },
    visuals = {
        mesh = {
            lod0distance = 60,
        },
        onImpactEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/CybranAcuProjectiles/Impact/vci1301_cannon_plasma_large_impact.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/CybranAcuProjectiles/Trails/vct2101_rocket_antitank_small_trail.sanvfx",
                    },
                },
            },
        },
    },
}

-- Supreme Commander Overhaul Cybran red ACU projectile visuals 1.1.0
