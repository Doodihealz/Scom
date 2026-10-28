---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoFaBomberImpact = {
            version = "1.0.0",
            runtimeProjectileId = "pab101",
            damageFriendly = true,
        },
        scoFaDestroyOnWater = {
        version = "1.0.0",
        sourceId = "AIFBombGraviton01",
        runtimeProjectileId = "pab101",
        sourceDestroyOnWater = true,
        runtimeMode = "HostPreCollisionWaterlineCull",
    },},    
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Aeon_Shimmer_Graviton_Bomb",
        tpId = "pab101",
    },
    -- FA provenance: source MaxSpeed=40; realistic ordnance; MuzzleVelocity=0; PredictAheadForBombDrop=3; DestroyOnWater=true.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/AIFBombGraviton01/AIFBombGraviton01_proj.bp
    -- Source blueprint SHA-256: cdc00f032be9fea0ac4c6b9f5738b9f705052a05badfec72a45771f84f0f4c44
    -- Source script: projectiles/AIFBombGraviton01/AIFBombGraviton01_script.lua
    -- Source script SHA-256: ec40f79950401890363a06bcc1ade8e59ffb415cbe3b9831641db7e72d3f356b
    isBomb = true,
    speed = 40,
    timeToLive = 3,    nonUniformScale = { x = 4, y = 4, z = 4 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vci1101_cannon_plasma_small_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vct1201_cannon_plasma_medium_trail.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0