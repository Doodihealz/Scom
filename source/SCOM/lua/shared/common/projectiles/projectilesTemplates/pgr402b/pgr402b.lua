---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "URL0402 Heavy Electron Bolter",
        tpId = "pgr402b",
    },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi1281_cannon_plasma_medium_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt1281_cannon_plasma_medium_trail.sanvfx" } } },
        },
    },
}

-- Guard Cybran Monkeylord Cache Patcher 1.4.0
-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
-- Source ID: CDFBolter02
-- Source blueprint: projectiles/CDFBolter02/CDFBolter02_proj.bp
-- Source blueprint SHA-256: f29bbeda9a1d139e330d3cf4d30d7a9cffb80b321e77a2bb86eda7b9471b8091
-- Source script: projectiles/CDFBolter02/CDFBolter02_script.lua
-- Source script SHA-256: cf4b9bd0b40cdf37e10bcb77fdf12844676a503be8cdaff5f29be4226129b288
-- Native Guard VFX archive SHA-256: 86c43f27b3ff9189a82f8201eec020d18c0770568a862b034737cd17424a357c
-- Sanctuary limitation: DestroyOnWater has no supported Sanctuary projectile-transition field.
-- The FA emitter/audio graph is not a supported sanvfx input; these are
-- verified native Guard-family effects and never route through Aeon assets.