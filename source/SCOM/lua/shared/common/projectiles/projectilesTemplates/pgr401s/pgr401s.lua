---@type ProjectileTemplate
ProjectileTemplate = {
    audio = { onImpact = { looping = false, name = "agoi1130" } },
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = { name = "Cybran_Scathis_Artillery_Proton", tpId = "pgr401s" },
    nonUniformScale = { x = 0.45, y = 0.45, z = 0.45 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi8321_plasma_stream_large_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt8321_plasma_stream_large_trail.sanvfx" } } },
        },
    },
}

-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
-- Source ID: CIFArtilleryProton01
-- Source blueprint: projectiles/CIFArtilleryProton01/CIFArtilleryProton01_proj.bp
-- Source blueprint SHA-256: e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e
-- Source script: projectiles/CIFArtilleryProton01/CIFArtilleryProton01_script.lua
-- Source script SHA-256: 98a19bd78f1a61dc4c2f3f9e2c63a6cb27aadb6cbb352dbe6cf430d3483ee0ef
-- Limitation: FA Force/Fire emitter graphs, camera shake/follow, decal and
-- explicit DestroyOnWater are not native Sanctuary projectile-template inputs.
-- Supreme Commander Overhaul FA Cybran Scathis 1.0.0