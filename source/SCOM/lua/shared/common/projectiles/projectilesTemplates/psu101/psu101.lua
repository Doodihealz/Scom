---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        name = "UEF_Plasma_T1_PointDefense",
        tpId = "psu101",
    },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            {
                effects = {
                    { particleName = "VFX/Impact/vei1101_cannon_small_impact.sanvfx" },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    { particleName = "VFX/Trails/vet1101_cannon_small_trail.sanvfx" },
                },
            },
        },
    },
}

-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0
-- FA source projectile: TDFPlasma01; units.scd SHA-256 C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26, projectiles.scd SHA-256 60D2732597CDE9EF046A663C8D439E60844F967147E14737C7AD5A08C641BE12.
-- Source projectile blueprint SHA-256 cd2fa28e058af6a39e8ca4ef7e440b5c655fad3f899cf06cea0eb20d70586103; script SHA-256 c8ee9063b2a1273a8ed4fc389df315c1c6bff3a3365763bbaa332e73dcd591c0.
-- Unsupported source fields: DestroyOnWater; FA emitter graph.
-- Compatibility VFX are explicit Sanctuary stand-ins; the weapon tables own source damage, cadence, range, and lifetime.
