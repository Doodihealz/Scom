---@type ProjectileTemplate
ProjectileTemplate = {
    
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Cybran_Cormorant_Nanite_Torpedo",
        tpId = "pgb231",
    },
    -- FA provenance: source Initial/MaxSpeed=14 and TurnRate=230; water-entry TurnRate=240; zigzag unavailable.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/CANTorpedoNanite03/CANTorpedoNanite03_proj.bp
    -- Source blueprint SHA-256: 07cabdfb78f90b37c86ed7bc45a8b795f221425ed36a13f2cd1d8092790e90f7
    -- Source script: projectiles/CANTorpedoNanite03/CANTorpedoNanite03_script.lua
    -- Source script SHA-256: de8af2f4a66f566dc2463030c02661977f9f033bb73c7593373f922f8a114ab6
    movement = {
        acceleration = 0,
        alignToVelocity = true,
        gravityMultiplier = 0,
        rotationSpeed = 240,
        speedMax = 14,
        type = "TargetEntity",
    },
    timeToLive = 20,    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi1741_grenade_medium_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt1741_grenade_medium_trail.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0