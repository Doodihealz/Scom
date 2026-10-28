---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoFaBomberImpact = {
            version = "1.0.0",
            runtimeProjectileId = "psb202",
            damageFriendly = true,
        },
        scoFaDestroyOnWater = {
        version = "1.0.0",
        sourceId = "SBOOtheTacticalBomb02",
        runtimeProjectileId = "psb202",
        sourceDestroyOnWater = true,
        runtimeMode = "HostPreCollisionWaterlineCull",
    },},    
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Seraphim_Notha_Othe_Tactical_Bomb",
        tpId = "psb202",
    },
    -- FA provenance: source MaxSpeed=20; realistic ordnance; MuzzleVelocity=0; PredictAheadForBombDrop=3; DestroyOnWater=true.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/SBOOtheTacticalBomb02/SBOOtheTacticalBomb02_proj.bp
    -- Source blueprint SHA-256: 1f96bc42cae307c9e116b960e7dc8f0955baf831f17ac1409b91796e1fc4c5cb
    -- Source script: projectiles/SBOOtheTacticalBomb02/SBOOtheTacticalBomb02_script.lua
    -- Source script SHA-256: 601d17860a124be6a0acbe6be5cb331ca5d54a6a04c57f09399b7d9c308a5dbe
    isBomb = true,
    speed = 20,
    timeToLive = 8,    nonUniformScale = { x = 1, y = 1, z = 1 },
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