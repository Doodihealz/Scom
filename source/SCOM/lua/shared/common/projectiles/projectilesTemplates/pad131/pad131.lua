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
        tpId = "pad131",
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
                        particleName = "VFX/AeonProjectiles/Impact/vci1101_cannon_plasma_small_impact.sanvfx", --vci1121_autocannon_plasma_small_impact
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/AeonProjectiles/Trails/vct1101_cannon_plasma_small_trail.sanvfx", --vct1121_autocannon_plasma_small_trail
                    },
                },
            },
        },
    },
}

-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0
