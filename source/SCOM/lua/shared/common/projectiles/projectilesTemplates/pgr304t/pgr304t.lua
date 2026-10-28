---@type ProjectileTemplate
ProjectileTemplate = {
    audio = { onImpact = { looping = false, name = "agoi3230" } },
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Cybran_Trebuchet_CIFArtilleryProton01",
        tpId = "pgr304t",
    },
    nonUniformScale = { x = 0.45, y = 0.45, z = 0.45 },
    source = {
        archiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
        sourceId = "CIFArtilleryProton01",
        blueprint = "projectiles/CIFArtilleryProton01/CIFArtilleryProton01_proj.bp",
        blueprintSha256 = "e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e",
        script = "projectiles/CIFArtilleryProton01/CIFArtilleryProton01_script.lua",
        scriptSha256 = "98a19bd78f1a61dc4c2f3f9e2c63a6cb27aadb6cbb352dbe6cf430d3483ee0ef",
        velocityAlign = true,
        turnRate = 360,
        destroyOnWater = true,
        limitations = {
            forceAndFireDamageRings = false,
            impactLightsAndScorchDecal = false,
            cameraShakeAndFollow = false,
            destroyOnWaterRuntime = false,
            sourceMeshAndEmitterGraph = false,
            visual = "Guard proton-artillery compatibility trail/impact",
        },
    },
    visuals = {
        mesh = { lod0distance = 150 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi8321_plasma_stream_large_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt8321_plasma_stream_large_trail.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Cybran Egg Products 1.0.0