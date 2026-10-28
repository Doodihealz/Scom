---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Cybran_Wagner_Meson_Rocket",
        tpId = "pgr203r",
    },
    movement = { gravityMultiplier = 0 },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi1141_cannon_artillery_small_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt1141_cannon_artillery_small_trail.sanvfx" } } },
        },
    },
}

-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
-- Source ID: CDFRocketMeson01
-- Source blueprint: projectiles/CDFRocketMeson01/CDFRocketMeson01_proj.bp
-- Source blueprint SHA-256: a952ed37521cdf7935413c8e994a44fc91a397389078e4ab1796866fe403ce1b
-- Source script: projectiles/CDFRocketMeson01/CDFRocketMeson01_Script.lua
-- Source script SHA-256: 905d2197b1c6202b13217d6817bdd13c534810f26b53f6cd5aa5deb67e0c8296
-- Sanctuary limitation: FA emitter graphs and rocket packed-mesh swap are not native sanvfx inputs.
-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0