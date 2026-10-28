---@type ProjectileTemplate
ProjectileTemplate = {
    audio = {
        onImpact = {
            looping = false,
            name = "aeoi1112",
        },
    },
    collisionInfo = {
        centerOffset = { x = 0, y = 0.25, z = 0 },
        collisionSize = { x = 0.5, y = 0.5, z = 0.5 },
    },
    general = {
        icon = "projectile",
        name = "Cybran_Hoplite_Iridium_Rocket",
        tpId = "pgh204",
    },
    -- FA CDFRocketIridium02 uses InitialSpeed=35, MaxSpeed=45, TurnRate=0,
    -- TrackTarget=true, MaxZigZag=5, and ZigZagFrequency=1. Sanctuary's public
    -- projectile template API has no initial-speed or zig-zag fields.  The
    -- source muzzle solution remains 15; this supported homing prefab ramps
    -- immediately toward the source maximum while its zero turn rate keeps it
    -- on the authored direct-fire line.  The source projectile mesh/VFX is
    -- likewise unsupported by the loader, so compatible native rocket VFX
    -- are intentionally explicit rather than pretending the grenade matches.
    movement = {
        acceleration = 120,
        alignToVelocity = true,
        gravityMultiplier = 0,
        rotationSpeed = 0,
        speedMax = 45,
        type = "TargetEntity",
    },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/Impact/vei2101_rocket_antitank_small_impact.sanvfx",
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

-- Supreme Commander Overhaul Cybran Hoplite Cache Patcher 1.0.0