---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        name = "UEF_Flayer_Missile_T3_AntiAir",
        tpId = "psu321",
    },
    movement = {
        acceleration = 6,
        alignToVelocity = true,
        gravityMultiplier = 0,
        rotationSpeed = 180,
        speedMax = 50,
        type = "TargetEntity",
    },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            {
                effects = {
                    { particleName = "VFX/Impact/vei3301_missile_antiair_large_impact.sanvfx" },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    { particleName = "VFX/Trails/vet3301_missile_antiair_large_trail.sanvfx" },
                },
            },
        },
    },
}

-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0
-- FA source projectile: TAAMissileFlayer01; units.scd SHA-256 C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26, projectiles.scd SHA-256 60D2732597CDE9EF046A663C8D439E60844F967147E14737C7AD5A08C641BE12.
-- Source projectile blueprint SHA-256 8b0ec153e08f756d7623a671a2dcc2852bd3b54ca1e2a23af4cf83e81f5d6fc9; script SHA-256 ba368ff670768bbd3897c154140e85f35922d47aeba96feab22d017cc6342726.
-- Unsupported source fields: DestroyOnWater; OnLostTargetLifetime 0.7; FA emitter graph.
-- Compatibility VFX are explicit Sanctuary stand-ins; the weapon tables own source damage, cadence, range, and lifetime.
