---@type ProjectileTemplate
ProjectileTemplate = {
    
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "UEF_Stork_Angler_Torpedo",
        tpId = "peb231",
    },
    -- FA provenance: source Initial/MaxSpeed=14 and TurnRate=230; water-entry runtime MaxSpeed=18 and TurnRate=240.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/TANAnglerTorpedo06/TANAnglerTorpedo06_proj.bp
    -- Source blueprint SHA-256: 55e293247e1e0c3675563582954ccbc5b0eee894475abb09eeba0fb4bc90971b
    -- Source script: projectiles/TANAnglerTorpedo06/TANAnglerTorpedo06_script.lua
    -- Source script SHA-256: d35c124b1be07811a2acf7436ebb1ba9b95017b19bd3d22bf0ca8125fbef8dac
    movement = {
        acceleration = 4,
        alignToVelocity = true,
        gravityMultiplier = 0,
        rotationSpeed = 240,
        speedMax = 18,
        type = "TargetEntity",
    },
    timeToLive = 20,    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vei3301_missile_antiair_large_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vet3301_missile_antiair_large_trail.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0