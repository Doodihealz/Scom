-- Dedicated Overcharge identity; reuses the installed faction cannon VFX.
-- Runtime owns payment, targeting, damage, muzzle handoff and cooldown.
ProjectileTemplate = {
    ["additions"] = {
        ["scoOvercharge"] = {
            ["sourceId"] = "XSL0001",
            ["version"] = "1.0.0",
            ["visualSourceTemplate"] = "psf0169",
        },
        ["scoSourceProjectile"] = {
            ["blueprintSha256"] = "3accbfb57fac5cf31e182ceba27a45b6f3a2ad019492c3c62e17565b5625689e",
            ["categories"] = {
                [1] = "SERAPHIM",
                [2] = "PROJECTILE",
                [3] = "DIRECTFIRE",
            },
            ["physics"] = {
                ["DestroyOnWater"] = true,
                ["InitialSpeed"] = 14.6,
                ["InitialSpeedRange"] = 3,
                ["InitialSpeedReduceDistance"] = 30,
                ["LeadTarget"] = false,
                ["RotationalVelocity"] = 9000,
                ["TurnRate"] = 360,
                ["VelocityAlign"] = true,
            },
            ["sourceId"] = "sdfchronatroncannon02",
            ["version"] = "1.0.0",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 1,
            ["z"] = 1,
        },
    },
    ["general"] = {
        ["name"] = "SDFChronatronCannon02",
        ["tpId"] = "pocsera",
    },
    ["nonUniformScale"] = {
        ["x"] = 1,
        ["y"] = 1,
        ["z"] = 1,
    },
    ["visuals"] = {
        ["mesh"] = {
            ["lod0distance"] = 60,
        },
        ["onImpactEffects"] = {
            [1] = {
                ["effects"] = {
                    [1] = {
                        ["particleName"] = "VFX/SCOM/Commanders/ChosenStyle/Seraphim/ACUImpact/impact.sanvfx",
                    },
                },
            },
        },
        ["persistantEffects"] = {
            [1] = {
                ["effects"] = {
                    [1] = {
                        ["particleName"] = "VFX/SCOM/Commanders/ChosenStyle/Seraphim/projectile.sanvfx",
                    },
                },
            },
        },
    },
}
