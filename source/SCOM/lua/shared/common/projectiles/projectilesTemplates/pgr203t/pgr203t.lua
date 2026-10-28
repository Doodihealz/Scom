---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Cybran_Wagner_Meson_Torpedo",
        tpId = "pgr203t",
    },
    movement = { acceleration = 5, gravityMultiplier = 0, rotationSpeed = 230, speedMax = 18, type = "TargetEntity" },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi1241_cannon_artillery_medium_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt1241_cannon_artillery_medium_trail.sanvfx" } } },
        },
    },
}

-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
-- Source ID: CANTorpedoMeson02
-- Source blueprint: projectiles/CANTorpedoMeson02/CANTorpedoMeson02_proj.bp
-- Source blueprint SHA-256: 62fa521286123ca9dc8f8da1a9b7bf60cdcb15ee421b5ca05880c2c48d9045a8
-- Source script: projectiles/CANTorpedoMeson02/CANTorpedoMeson02_script.lua
-- Source script SHA-256: f11469fe5cfd2b64398aa8f5e664b8d1895eb504e215bb4f33e6366538d6269b
-- Sanctuary limitation: FA emitter graphs and rocket packed-mesh swap are not native sanvfx inputs.
-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0