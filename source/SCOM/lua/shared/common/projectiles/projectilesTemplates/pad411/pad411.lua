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
        name = "Chosen_Cannon_Air_Huge",
        tpId = "pad411",
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
                        particleName = "VFX/AeonProjectiles/Impact/vci4401_cannon_air_huge_impact.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/AeonProjectiles/Trails/vct4401_cannon_air_huge_trail.sanvfx",
                    },
                },
            },
        },
    },
}

-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0
