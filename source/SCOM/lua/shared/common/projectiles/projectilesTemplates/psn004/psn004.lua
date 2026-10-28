---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoStrategicNuke = {
            version = "1.0.0",
            damageFriendly = true,
            innerDamage = {
                amount = 70000,
                radius = 30,
                ticks = 24,
                totalTime = 0,
            },
            outerDamage = {
                amount = 500,
                radius = 40,
                ticks = 20,
                totalTime = 0,
            },
        },
    },
    collisionInfo = {
        centerOffset = {
            x = 0,
            y = 0.5,
            z = 0,
        },
        collisionSize = {
            x = 1,
            y = 1,
            z = 1,
        },
    },
    general = {
        name = "Seraphim_Inaino_Strategic_Missile",
        tpId = "psn004",
    },
    movement = {
        acceleration = 3,
        alignToVelocity = true,
        gravityMultiplier = 0,
        rotationSpeed = 30,
        speedMax = 40,
        type = "LeadStaticPosition",
    },
    nonUniformScale = {
        x = 1,
        y = 1,
        z = 1,
    },
    visuals = {
        mesh = {
            lod0distance = 60,
        },
        onImpactEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/Impact/vci1341_cannon_artillery_large_impact.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/Trails/vct1341_cannon_artillery_large_trail.sanvfx",
                    },
                },
            },
        },
    },
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psn004.lua
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="SIFInainoStrategicMissile01",["categories"]={"SERAPHIM","PROJECTILE","INDIRECTFIRE","STRATEGIC","MISSILE","NOSPLASHDAMAGE"},["defense"]={["Health"]=25,["MaxHealth"]=25},["blueprintSha256"]="fa6c9b656f4d5422a3c938156086b992f8f1c48ae8654ed837269e8ea7028fc6",["collisionRadius"]=2}
