---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Cybran_Wagner_Heavy_Electron_Bolter",
        tpId = "pgr203b",
    },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi1101_cannon_small_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt1101_cannon_small_trail.sanvfx" } } },
        },
    },
}

-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
-- Source ID: CDFBolter02
-- Source blueprint: projectiles/CDFBolter02/CDFBolter02_proj.bp
-- Source blueprint SHA-256: f29bbeda9a1d139e330d3cf4d30d7a9cffb80b321e77a2bb86eda7b9471b8091
-- Source script: projectiles/CDFBolter02/CDFBolter02_script.lua
-- Source script SHA-256: cf4b9bd0b40cdf37e10bcb77fdf12844676a503be8cdaff5f29be4226129b288
-- Sanctuary limitation: FA emitter graphs and rocket packed-mesh swap are not native sanvfx inputs.
-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0