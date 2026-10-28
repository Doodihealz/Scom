---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "URL0402 Nanite AA Missile",
        tpId = "pgr402a",
    },
    movement = { acceleration = 5, gravityMultiplier = 0, rotationSpeed = 180, speedMax = 50, type = "TargetEntity" },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },

        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt3301_missile_antiair_large_trail.sanvfx" } } },
        },
    },
}

-- Guard Cybran Monkeylord Cache Patcher 1.4.0
-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
-- Source ID: CAAMissileNanite02
-- Source blueprint: projectiles/CAAMissileNanite02/CAAMissileNanite02_proj.bp
-- Source blueprint SHA-256: 927a795462a0c10f7baa08aef672414b47b04a96236672be24d6a4a03ba0a935
-- Source script: projectiles/CAAMissileNanite02/CAAMissileNanite02_script.lua
-- Source script SHA-256: 7001c493cc2ac2a5cd4c9d43898be59a304ff2f16317cc5a53dcfca110756747
-- Native Guard VFX archive SHA-256: 86c43f27b3ff9189a82f8201eec020d18c0770568a862b034737cd17424a357c
-- Sanctuary limitation: The source 1.5-second random acceleration and zig-zag thread are unsupported.
-- The FA emitter/audio graph is not a supported sanvfx input; these are
-- verified native Guard-family effects and never route through Aeon assets.