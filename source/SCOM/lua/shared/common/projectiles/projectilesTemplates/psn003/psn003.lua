---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoStrategicNuke = {
            version = "1.1.0",
            damageFriendly = true,
            impactProfile = "ApocalypseAeon2x",
            innerDamage = {
                amount = 140000,
                radius = 60,
                ticks = 24,
                totalTime = 0,
            },
            outerDamage = {
                amount = 1000,
                radius = 80,
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
        name = "Chosen_Quantum_Strategic_Missile",
        tpId = "psn003",
    },
    movement = {
        acceleration = 0,
        alignToVelocity = true,
        gravityMultiplier = 0,
        rotationSpeed = 0,
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
                        particleName = "VFX/SCOM/Apocalypse/apoc_impact.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/SCOM/Apocalypse/apoc_missile.sanvfx",
                    },
                },
            },
        },
    },
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psn003.lua
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="AIFQuantumWarhead01",["categories"]={"AEON","PROJECTILE","INDIRECTFIRE","STRATEGIC","MISSILE","NOSPLASHDAMAGE"},["defense"]={["Health"]=25,["MaxHealth"]=25},["blueprintSha256"]="7098e71f9e65f3780accaaf72b4936836780aeabf82d1543b67b68b9d22cecf1",["collisionRadius"]=2}
