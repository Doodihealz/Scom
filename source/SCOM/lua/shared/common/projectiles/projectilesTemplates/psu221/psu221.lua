---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        name = "UEF_FragmentationShell_T2_AntiAir",
        tpId = "psu221",
    },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            {
                effects = {
                    { particleName = "VFX/Impact/vei1121_autocannon_small_impact.sanvfx" },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    { particleName = "VFX/Trails/vet1121_autocannon_small_trail.sanvfx" },
                },
            },
        },
    },
}

-- Supreme Commander Overhaul Combat Structures Defensive Parity 1.2.0
-- FA source projectile: TAALightFragmentationShell01; units.scd SHA-256 C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26, projectiles.scd SHA-256 60D2732597CDE9EF046A663C8D439E60844F967147E14737C7AD5A08C641BE12.
-- Source projectile blueprint SHA-256 40248b18e2d77e9ee0659444c440511b4232b515eff6372774d1c42b539dc588; script SHA-256 a22c5d63a904bd719fadf2c7826248ec83c92602e7334cb6ccbce7f9fa5a89e7.
-- Unsupported source fields: DestroyOnWater; DetonateAboveHeight 10; FA velocity-aligned mesh; FA emitter graph.
-- Compatibility VFX are explicit Sanctuary stand-ins; the weapon tables own source damage, cadence, range, and lifetime.
