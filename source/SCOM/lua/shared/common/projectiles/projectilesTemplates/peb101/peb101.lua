---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoFaBomberImpact = {
            version = "1.0.0",
            runtimeProjectileId = "peb101",
            damageFriendly = false,
        },
            scoFaBomberGroundFire = {
            version = "1.0.0",
            sourceId = "TIFNapalmCarpetBomb01",
            runtimeProjectileId = "peb101",
            pulseCount = 15,
            pulseDamage = 4,
            pulseIntervalTicks = 1,
            durationSeconds = 1.5,
            damageRadius = 2.5,
            damageFriendly = false,
            impactVfx = "VFX/SupremeCommanderOverhaul/Bombers/scorcher_napalm_ground_fire.sanvfx",
        },},    
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "UEF_Scorcher_Napalm_Carpet_Bomb",
        tpId = "peb101",
    },
    -- FA provenance: sourceMaxSpeed=20; realistic ordnance; TurnRate=360; DestroyOnWater=true.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/TIFNapalmCarpetBomb01/TIFNapalmCarpetBomb01_proj.bp
    -- Source blueprint SHA-256: 58a4511cb4d575f5f8b96dd51be654b4b4662ec67fdfa05ad139c70322680954
    -- Source script: projectiles/TIFNapalmCarpetBomb01/TIFNapalmCarpetBomb01_script.lua
    -- Source script SHA-256: fb52ef413bec3ed05de3e92641259cd89b1e595932f327ba65aa67b922961b25
    isBomb = true,
    speed = 20,
    timeToLive = 8,    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/SupremeCommanderOverhaul/Bombers/scorcher_napalm_ground_fire.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/TrailGeneric_01.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0