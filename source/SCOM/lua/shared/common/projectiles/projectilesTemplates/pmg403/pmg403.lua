---@type ProjectileTemplate
-- Supreme Commander Overhaul FA Cybran Megalith Physical Port 1.0.1
-- Dedicated compatibility projectile; gameplay damage remains unit-weapon owned.
ProjectileTemplate = {
    additions = {
        faSourceContract = {
            sourceId = "CAABurstCloud01",
            targetId = "pmg403",
            sourceArchiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
            sourceBlueprint = "projectiles/CAABurstCloud01/CAABurstCloud01_proj.bp",
            sourceBlueprintSha256 = "a67bd4f98381453ecd65897dc7d40feb7f8c1005f669b67e3f20e2162362bff4",
            sourceScript = "projectiles/CAABurstCloud01/CAABurstCloud01_script.lua",
            sourceScriptSha256 = "c40d3c20d99e4bf9380bb68009558bf0da7f3a516e327305cbd41e6f3fa314bc",
            destinationVisualRevision = "red-fast-fallback-1.0.0",
            sourceDamage = 18,
            sourceDamageRadius = 2,
            sourceInitialSpeed = 20,
            sourceLifetime = 5,
            sourceUseGravity = false,
            sourceVelocityAlign = true,
            sourceDestroyOnWater = true,
            sourceDetonateAboveHeight = 10,
            sourceTrailEmitter = "effects/emitters/default_polytrail_02_emit.bp",
            sourceTrailEmitterSha256 = "0e11df4be71c11b350f927b0ae8b49f68aff03d1c96c4e74d32f327cffe37b63",
            sourceTrailLength = 1,
            sourceTrailSize = 0.025,
            destinationTrail = "VFX/Trails/vgt1121_autocannon_plasma_small_trail.sanvfx",
            destinationImpact = "VFX/Impact/vgi1121_autocannon_plasma_small_impact.sanvfx",
            destinationExactEmitterGraphSupported = false,
            limitation = "DetonateAboveHeight and the exact FA burst-cloud emitter graph have no public Sanctuary equivalents; the destination uses a compact native red Guard plasma fallback.",
        },
    },
    collisionInfo = {
        centerOffset = { x = 0, y = 0.25, z = 0 },
        collisionSize = { x = 0.5, y = 0.5, z = 0.5 },
    },
    general = { icon = "projectile", name = "Megalith_Electron_Flak", tpId = "pmg403" },
    movement = {
        gravityMultiplier = 0,
    },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi1121_autocannon_plasma_small_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt1121_autocannon_plasma_small_trail.sanvfx" } } },
        },
    },
}
