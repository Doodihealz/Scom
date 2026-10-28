---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "URL0402 Meson Torpedo",
        tpId = "pgr402t",
    },
    movement = { acceleration = 5, gravityMultiplier = 0, rotationSpeed = 230, speedMax = 18, type = "TargetEntity" },
    nonUniformScale = { x = 1, y = 1, z = 1 },
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

-- Guard Cybran Monkeylord Cache Patcher 1.4.0
-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
-- Source ID: CANTorpedoMeson02
-- Source blueprint: projectiles/CANTorpedoMeson02/CANTorpedoMeson02_proj.bp
-- Source blueprint SHA-256: 62fa521286123ca9dc8f8da1a9b7bf60cdcb15ee421b5ca05880c2c48d9045a8
-- Source script: projectiles/CANTorpedoMeson02/CANTorpedoMeson02_script.lua
-- Source script SHA-256: f11469fe5cfd2b64398aa8f5e664b8d1895eb504e215bb4f33e6366538d6269b
-- Native Guard VFX archive SHA-256: 86c43f27b3ff9189a82f8201eec020d18c0770568a862b034737cd17424a357c
-- Sanctuary limitation: StayUnderwater and the FA torpedo emitter graph are unsupported.
-- The FA emitter/audio graph is not a supported sanvfx input; these are
-- verified native Guard-family effects and never route through Aeon assets.