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
        name = "Guard_Strategic_Nuclear_Missile",
        tpId = "psn002",
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
                        particleName = "VFX/Impact/vgi8321_plasma_stream_large_impact.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/Trails/vgt8321_plasma_stream_large_trail.sanvfx",
                    },
                },
            },
        },
    },
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psn002.lua
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="CIFEMPFluxWarhead01",["categories"]={"CYBRAN","PROJECTILE","INDIRECTFIRE","STRATEGIC","MISSILE","NOSPLASHDAMAGE"},["defense"]={["Health"]=25,["MaxHealth"]=25},["blueprintSha256"]="d81a018429e6ab63427f4022e9631055e9fc179ee5d693b977fd6b39f225ffa4",["collisionRadius"]=2}
