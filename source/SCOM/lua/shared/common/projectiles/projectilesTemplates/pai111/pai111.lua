---@type ProjectileTemplate
ProjectileTemplate = {
    audio = {
        onImpact = {
            looping = false,
            name = "acoi2110",
        },
    },
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
        name = "Chosen_Cannon_Artillery_Small",
        tpId = "pai111",
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
                        particleName = "VFX/AeonProjectiles/Impact/vci1141_cannon_artillery_small_impact.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/AeonProjectiles/Trails/vct1141_cannon_artillery_small_trail.sanvfx",
                    },
                },
            },
        },
    },
}

-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0
