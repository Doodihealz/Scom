---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoFaBomberImpact = {
            version = "1.0.0",
            runtimeProjectileId = "peb301",
            damageFriendly = true,
        },
    },    
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "UEF_Ambassador_Small_Yield_Nuclear_Bomb",
        tpId = "peb301",
    },
    -- FA provenance: source realistic ordnance; no explicit speed/lifetime; TurnRate=360.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/TIFSmallYieldNuclearBomb01/TIFSmallYieldNuclearBomb01_proj.bp
    -- Source blueprint SHA-256: 808c092a0d3f6fe101050af17f22705fa7a72cdf96842a7962200efc8fc5d36a
    -- Source script: projectiles/TIFSmallYieldNuclearBomb01/TIFSmallYieldNuclearBomb01_script.lua
    -- Source script SHA-256: d9c88f50f05988fc6e7565135c8b76515220f83250481a2fa2a4dbd958613a77
    isBomb = true,
    speed = 20,
    timeToLive = 8,    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vei8301_bomb_large_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/TrailGeneric_01.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0