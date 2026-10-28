---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoStrategicNuke = {
            version = "1.0.0",
            damageFriendly = true,
            innerDamage = {
                amount = 75000,
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
        name = "Chosen_Submarine_Quantum_Warhead",
        tpId = "psn005",
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
                        particleName = "VFX/Trails/vct3301_missile_antiair_large_trail.sanvfx",
                    },
                },
            },
        },
    },
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psn005.lua
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="AIFQuantumWarhead03",["categories"]={"AEON","PROJECTILE","INDIRECTFIRE","STRATEGIC","MISSILE","NOSPLASHDAMAGE"},["defense"]={["Health"]=25,["MaxHealth"]=25},["blueprintSha256"]="6384a0b750f9fc6c7d717528ab0bd8c6bbd177daa4d6e8e29151e2f76b805f03",["collisionRadius"]=2}
