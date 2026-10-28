---@type ProjectileTemplate
ProjectileTemplate = {
    audio = {
        onImpact = {
            looping = false,
            name = "acoi2110",
        },
    },
    collisionInfo = {
        centerOffset = {
            x = 0,
            y = 0.1,
            z = 0,
        },
        collisionSize = {
            x = 1,
            y = 1,
            z = 1,
        },
    },
    color = {
        x = 0.5372549,
        y = 0.972549,
        z = 0.892659247,
    },
    damage = 10,
    general = {
        name = "Plasma_Large",
        tpId = "pad002",
    },
    nonUniformScale = {
        x = 4,
        y = 4,
        z = 4,
    },
    speed = 20,
    timeToLive = 2,
    visuals = {
        mesh = {
            lod0distance = 60,
        },
        onImpactEffects = {
            {
                effects = {
                    {
                        audioName = "Sounds/videvo.net_royalFree_soundEffects/Impacts/MetallicWarbleImpa PE359507.ogg",
                        particleName = "VFX/AeonProjectiles/Impact/vci1101_cannon_plasma_small_impact.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/AeonProjectiles/Trails/vct1201_cannon_plasma_medium_trail.sanvfx",
                    },
                },
            },
        },
    },
}

-- Supreme Commander Overhaul Aeon mint projectile visuals 1.0.0
