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
        name = "Fatboy_Gauss_Cannon",
        tpId = "psf401",
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
                        particleName = "VFX/Impact/vei1301_cannon_large_impact.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/Trails/vet1301_cannon_large_trail.sanvfx",
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