---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        name = "UEF_Railgun_T1_AntiAir",
        tpId = "psu121",
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
-- FA source projectile: TAARailgun01; units.scd SHA-256 C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26, projectiles.scd SHA-256 60D2732597CDE9EF046A663C8D439E60844F967147E14737C7AD5A08C641BE12.
-- Source projectile blueprint SHA-256 27f4839a8b5b048073055a42fc728537303e8fae0a28266fe6674fbdb18bbc8f; script SHA-256 36c2417368fb105b30325e2ee1fa1f63f51c79ddf18e0fece8842108333cd92e.
-- Unsupported source fields: DestroyOnWater; FA velocity-aligned mesh; FA emitter graph.
-- Compatibility VFX are explicit Sanctuary stand-ins; the weapon tables own source damage, cadence, range, and lifetime.
