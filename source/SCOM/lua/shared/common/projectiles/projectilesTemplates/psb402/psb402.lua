---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoFaBomberImpact = {
            version = "1.0.0",
            runtimeProjectileId = "psb402",
            damageFriendly = true,
        },
        scoFaDestroyOnWater = {
        version = "1.0.0",
        sourceId = "SBOOhwalliStrategicBomb01",
        runtimeProjectileId = "psb402",
        sourceDestroyOnWater = true,
        runtimeMode = "HostPreCollisionWaterlineCull",
    },},    
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Seraphim_Ahwassa_Ohwalli_Strategic_Bomb",
        tpId = "psb402",
    },
    -- FA provenance: source realistic ordnance; MuzzleVelocity=0; PredictAheadForBombDrop=2; DestroyOnWater=true; dedicated local mesh renderer at authored scale six.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/SBOOhwalliStrategicBomb01/SBOOhwalliStrategicBomb01_proj.bp
    -- Source blueprint SHA-256: 20609138dea5be8fef07140aacb1dbf240c85f679c1433329b5f46f7604f1c47
    -- Source script: projectiles/SBOOhwalliStrategicBomb01/SBOOhwalliStrategicBomb01_script.lua
    -- Source script SHA-256: b83acef1689a917ee98cac7c83991b83001fcc33f9d8d9d176872bf84787ca67
    isBomb = true,
    speed = 20,
    timeToLive = 8,    -- Dedicated commander-blue bomb VFX owns a local scale-six mesh core; hierarchy and root collision remain 1.
    nonUniformScale = { x = 6, y = 6, z = 6 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { boneName = "SCO_Ahwassa_Commander_Projectile_Visual", particleName = "VFX/SCOM/FieldFixes/Ahwassa/ahwassa_strategic_bomb_6x.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0