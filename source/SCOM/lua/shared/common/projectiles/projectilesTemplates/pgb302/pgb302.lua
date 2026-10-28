---@type ProjectileTemplate
ProjectileTemplate = {
    
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Cybran_Revenant_Electron_Autocannon",
        tpId = "pgb302",
    },
    -- FA provenance: source InitialSpeed=35; Lifetime=1.5; weapon MuzzleVelocity=45; gravity-free direct fire.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/CAAAutocannon01/CAAAutocannon01_proj.bp
    -- Source blueprint SHA-256: 0460b42285f54f1b3cd041b431805ab8a0d54c1d6246c0ba26d6980156f19152
    -- Source script: projectiles/CAAAutocannon01/CAAAutocannon01_script.lua
    -- Source script SHA-256: 7aaff4e111849bbf457f95985bd862fd91fc2f8be82f4719cb757c3091cb0975
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi1121_autocannon_plasma_small_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt1121_autocannon_plasma_small_trail.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0