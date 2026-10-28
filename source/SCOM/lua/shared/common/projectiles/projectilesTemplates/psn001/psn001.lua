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
        name = "EDA_Strategic_Nuclear_Missile",
        tpId = "psn001",
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
                        particleName = "VFX/Impact/vei2341_rocket_artillery_medium_impact.sanvfx",
                    },
                },
            },
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
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psn001.lua
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="TIFMissileNuke01",["categories"]={"UEF","PROJECTILE","INDIRECTFIRE","STRATEGIC","MISSILE","NOSPLASHDAMAGE"},["defense"]={["Health"]=25,["MaxHealth"]=25},["blueprintSha256"]="364af3f0788095b8fba64d307bd75bcc0ad4c903e09b2ad1e08558102246b0cc",["collisionRadius"]=2}
