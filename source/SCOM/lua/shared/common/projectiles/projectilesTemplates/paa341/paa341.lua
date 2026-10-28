---@type ProjectileTemplate
ProjectileTemplate = {
    audio = {
        onImpact = {
            looping = false,
            name = "acoi2130",
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
    extraStages = {
        {
            delay = 0.1,
            acceleration = 40,
            speedMax = 50,
            rotationSpeed = 180,
            gravityMultiplier = 0,
        },
    },
    general = {
        name = "Chosen_Missile_AntiAir_Large",
        tpId = "paa341",
    },
    nonUniformScale = {
        x = 1,
        y = 1,
        z = 1,
    },
    movement = {
        acceleration = 40,
        alignToVelocity = true,
        gravityMultiplier = 0,
        rotationSpeed = 10,
        speedMax = 50,
        type = "TargetEntity",
    },
    visuals = {
        mesh = {
            lod0distance = 60,
        },
        onImpactEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/AeonProjectiles/Impact/vci3301_missile_antiair_large_impact.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/AeonProjectiles/Trails/vct3301_missile_antiair_large_trail.sanvfx",
                    },
                },
            },
        },
    },
}

-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0
