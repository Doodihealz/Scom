---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoFaBomberImpact = {
            version = "1.0.0",
            runtimeProjectileId = "psb101",
            damageFriendly = true,
        },
        scoFaDestroyOnWater = {
        version = "1.0.0",
        sourceId = "SBOOtheTacticalBomb01",
        runtimeProjectileId = "psb101",
        sourceDestroyOnWater = true,
        runtimeMode = "HostPreCollisionWaterlineCull",
    },},    
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Seraphim_Sinnve_Othe_Tactical_Bomb",
        tpId = "psb101",
    },
    -- FA provenance: source MaxSpeed=40; realistic ordnance; MuzzleVelocity=0; PredictAheadForBombDrop=3; DestroyOnWater=true.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/SBOOtheTacticalBomb01/SBOOtheTacticalBomb01_proj.bp
    -- Source blueprint SHA-256: 157076800c4a9cbb2c970ecd89065ba2d42304d0f5f6b23fd5765917fbf6a30b
    -- Source script: projectiles/SBOOtheTacticalBomb01/SBOOtheTacticalBomb01_script.lua
    -- Source script SHA-256: 4a3d936e2ca311d20071945ce500c56154a1d3e097ffbf35aa38081f1c02cdc1
    isBomb = true,
    speed = 40,
    timeToLive = 3,    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/TrailGeneric_01.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0