---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoFaBomberImpact = {
            version = "1.0.0",
            runtimeProjectileId = "pgb301",
            damageFriendly = true,
        },
    },    
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Cybran_Revenant_Proton_Bomb",
        tpId = "pgb301",
    },
    -- FA provenance: source realistic ordnance; no explicit speed/lifetime; TurnRate=0; ambient effect children unavailable.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/CIFProtonBomb01/CIFProtonBomb01_proj.bp
    -- Source blueprint SHA-256: 8cce9628c7c2af978337c8ff38a0f6aee6be00bc1db49cf83132472205d30a89
    -- Source script: projectiles/CIFProtonBomb01/CIFProtonBomb01_script.lua
    -- Source script SHA-256: f6ec5c492cb0dc5bead4b07c6b8dd679b930f98d9749b0e3bb7a760522b91a7c
    isBomb = true,
    speed = 20,
    timeToLive = 8,    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Death/vgd1301_death_land_large.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/TrailGeneric_01.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Air Bomber Gameplay 1.0.0