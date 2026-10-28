---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoFaBomberImpact = {
            version = "1.0.0",
            runtimeProjectileId = "pgb101",
            damageFriendly = true,
        },
    },    
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Cybran_Zeus_Neutron_Cluster_Bomb",
        tpId = "pgb101",
    },
    -- FA provenance: source MaxSpeed=25; realistic ordnance; TurnRate=30; child visual burst unavailable.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/CIFNeutronClusterBomb01/CIFNeutronClusterBomb01_proj.bp
    -- Source blueprint SHA-256: d8d893a306a94ef13e6b660c72a2f8023598f7fba27752ecc21c88da9e8ed399
    -- Source script: projectiles/CIFNeutronClusterBomb01/CIFNeutronClusterBomb01_script.lua
    -- Source script SHA-256: 39740ef89c603eb5b01989afdefd2f0c9745f8b227b056c24a5d7502af326875
    isBomb = true,
    speed = 25,
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