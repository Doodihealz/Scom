---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        name = "Cybran_Beam_Heavy",
        tpId = "pcg201",
    },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        beamEffectName = "VFX/Beams/vgb7301_beam_plasma_large_beam.sanvfx",
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            {
                effects = {
                    { particleName = "VFX/Impact/vgi1281_cannon_plasma_medium_impact.sanvfx" },
                },
            },
        },
    },
}

-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0
-- FA source projectile: beam (no FA ProjectileId); units.scd SHA-256 C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26, projectiles.scd SHA-256 60D2732597CDE9EF046A663C8D439E60844F967147E14737C7AD5A08C641BE12.
-- Compatibility VFX are explicit Sanctuary stand-ins; the weapon tables own source damage, cadence, range, and lifetime.
