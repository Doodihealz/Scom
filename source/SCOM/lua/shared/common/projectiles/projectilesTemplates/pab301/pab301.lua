---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoFaBomberImpact = {
            version = "1.0.0",
            runtimeProjectileId = "pab301",
            damageFriendly = true,
        },
        scoFaDestroyOnWater = {
        version = "1.0.0",
        sourceId = "AIFBombQuark01",
        runtimeProjectileId = "pab301",
        sourceDestroyOnWater = true,
        runtimeMode = "HostPreCollisionWaterlineCull",
    },},    
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Aeon_Shocker_Quark_Bomb",
        tpId = "pab301",
    },
    -- FA provenance: source realistic ordnance; MuzzleVelocity=0; PredictAheadForBombDrop=3; TurnRate=0; DestroyOnWater=true.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/AIFBombQuark01/AIFBombQuark01_proj.bp
    -- Source blueprint SHA-256: 418285aaae897c7e47d2ac191105a27082950de3dddb663de2a49004776f8ba3
    -- Source script: projectiles/AIFBombQuark01/AIFBombQuark01_script.lua
    -- Source script SHA-256: 7ee67db187f1009c76785e983479240a0bc90eeffff44dd57cb0762fce15de50
    isBomb = true,
    speed = 20,
    timeToLive = 8,    nonUniformScale = { x = 4, y = 4, z = 4 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vci1441_cannon_artillery_huge_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vct1201_cannon_plasma_medium_trail.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0