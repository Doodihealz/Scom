---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoFaBomberImpact = {
            version = "1.0.0",
            runtimeProjectileId = "psb301",
            damageFriendly = true,
        },
        scoFaDestroyOnWater = {
        version = "1.0.0",
        sourceId = "SBOZhanaseeBomb01",
        runtimeProjectileId = "psb301",
        sourceDestroyOnWater = true,
        runtimeMode = "HostPreCollisionWaterlineCull",
    },},    
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Seraphim_Sinntha_Zhanasee_Strategic_Bomb",
        tpId = "psb301",
    },
    -- FA provenance: source realistic ordnance; MuzzleVelocity=0; PredictAheadForBombDrop=3; DestroyOnWater=true; impact children unavailable.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/SBOZhanaseeBomb01/SBOZhanaseeBomb01_proj.bp
    -- Source blueprint SHA-256: ca131429be3e508d043617e3fc522e6381eb579f6dc3c53dd70ccbd13a5e2428
    -- Source script: projectiles/SBOZhanaseeBomb01/SBOZhanaseeBomb01_script.lua
    -- Source script SHA-256: a13dd7da0abeba1921d111adb8430cd065babe4e7ba1023fb10bd776a17b3382
    isBomb = true,
    speed = 20,
    timeToLive = 8,    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Death/vcd1301_death_land_large.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/TrailGeneric_01.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0