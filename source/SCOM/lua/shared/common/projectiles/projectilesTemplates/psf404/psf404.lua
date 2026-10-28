---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = {
            x = 0,
            y = 0.25,
            z = 0,
        },
        collisionSize = {
            x = 0.5,
            y = 0.5,
            z = 0.5,
        },
    },
    general = {
        name = "Fatboy_Angler_Torpedo",
        tpId = "psf404",
    },
    movement = {
        acceleration = 5,
        alignToVelocity = true,
        gravityMultiplier = 0,
        rotationSpeed = 230,
        speedMax = 18,
        type = "TargetEntity",
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
                        particleName = "VFX/Environment/vxi5201_water_splash_medium_impact.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/Trails/vet2101_rocket_antitank_small_trail.sanvfx",
                    },
                },
            },
        },
    },
}

-- Supreme Commander Overhaul UEF Fatboy Cache Patcher 1.0.0
-- Compatibility VFX are explicit Sanctuary stand-ins until native FA projectile
-- meshes/materials can be converted; damage, trajectory, lifetime, and cadence
-- are owned by the UEL4511 weapon tables above.