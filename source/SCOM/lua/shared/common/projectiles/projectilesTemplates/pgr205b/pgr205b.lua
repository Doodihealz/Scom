---@type ProjectileTemplate
ProjectileTemplate = {
    audio = { onImpact = { looping = false, name = "agoi1221" } },
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Cybran_Banger_CAABurstCloud01",
        tpId = "pgr205b",
    },
    nonUniformScale = { x = 0.1, y = 0.1, z = 0.1 },
    source = {
        archiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
        sourceId = "CAABurstCloud01",
        blueprint = "projectiles/CAABurstCloud01/CAABurstCloud01_proj.bp",
        blueprintSha256 = "a67bd4f98381453ecd65897dc7d40feb7f8c1005f669b67e3f20e2162362bff4",
        script = "projectiles/CAABurstCloud01/CAABurstCloud01_script.lua",
        scriptSha256 = "c40d3c20d99e4bf9380bb68009558bf0da7f3a516e327305cbd41e6f3fa314bc",
        initialSpeed = 20,
        lifetime = 5,
        useGravity = false,
        velocityAlign = true,
        destroyOnWater = true,
        detonateAboveHeight = 10,
        limitations = {
            electronBurstCloudEmitterGraph = false,
            detonateAboveTargetHeight = false,
            destroyOnWaterRuntime = false,
            visual = "Guard medium-AA compatibility trail/impact",
        },
    },
    visuals = {
        mesh = { lod0distance = 90 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi3221_cannon_antiair_medium_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt3221_cannon_antiair_medium_trail.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0