---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = {
            x = 0,
            y = 0.25,
            z = 0,
        },
        collisionSize = {
            x = 0.5,
            y = 0.5,
            z = 0.5,
        },
    },
    extraStages = {
        {
            delay = 1,
            acceleration = 5,
            rotationSpeed = 50,
            speedMax = 5,
        },
        {
            delay = 0.5,
            acceleration = 20,
            rotationSpeed = 250,
            speedMax = 200,
        },
    },
    general = {
        name = "EDA_Missile_Small",
        tpId = "pei241",
    },
    movement = {
        acceleration = 60,
        alignToVelocity = false,
        gravityMultiplier = 0,
        rotationSpeed = 50,
        speedMax = 15,
        type = "StaticPosistion",
    },
    visuals = {
        mesh = {
            lod0distance = 60,
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/Trails/vet5511_T5_rocket_trail.sanvfx",
                    },
                },
            },
        },
    },
}
-- SCOM native missile registration scale 1.0.0
ProjectileTemplate.nonUniformScale = ProjectileTemplate.nonUniformScale or { x = 1, y = 1, z = 1 }
