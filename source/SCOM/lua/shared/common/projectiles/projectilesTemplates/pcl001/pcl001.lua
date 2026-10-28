---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.25, z = 0 },
        collisionSize = { x = 0.5, y = 0.5, z = 0.5 },
    },
    general = {
        icon = "projectile",
        name = "Aeon_ACU_Quantum_Disruptor",
        tpId = "pcl001",
    },
    -- FA ADFQuantumDisruptor01 is direct fire with InitialSpeed=28 and
    -- VelocityAlign=true.  Sanctuary's public template schema has no separate
    -- initial-speed field.  Deliberately omit ``movement`` so the source
    -- weapon's 35-speed LowArc aim solution stays direct rather than becoming
    -- a homing missile.  Source projectile mesh/effect scripts are likewise
    -- unsupported, so these known native plasma effects are explicit fallbacks.
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/AeonProjectiles/Impact/vci1201_cannon_plasma_medium_impact.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/AeonProjectiles/Trails/vct1201_cannon_plasma_medium_trail.sanvfx",
                    },
                },
            },
        },
    },
}

-- Supreme Commander Overhaul Aeon ACU Cache Patcher 1.0.0