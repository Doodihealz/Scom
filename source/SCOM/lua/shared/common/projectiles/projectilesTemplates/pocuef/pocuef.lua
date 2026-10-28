-- Dedicated Overcharge identity; reuses the installed faction cannon VFX.
-- Runtime owns payment, targeting, damage, muzzle handoff and cooldown.
ProjectileTemplate = {
    ["additions"] = {
        ["scoOvercharge"] = {
            ["sourceId"] = "UEL0001",
            ["version"] = "1.0.0",
            ["visualSourceTemplate"] = "psf0168",
        },
        ["scoSourceProjectile"] = {
            ["blueprintSha256"] = "b7f5676157e97b93f7ab430d4c0f9a919f14660cfc1b68af53f6201c914a49d5",
            ["categories"] = {
                [1] = "UEF",
                [2] = "PROJECTILE",
                [3] = "DIRECTFIRE",
            },
            ["physics"] = {
                ["DestroyOnWater"] = true,
                ["InitialSpeed"] = 14.6,
                ["InitialSpeedRange"] = 3,
                ["InitialSpeedReduceDistance"] = 30,
                ["LeadTarget"] = false,
                ["TrackTarget"] = true,
                ["TurnRate"] = 60,
                ["VelocityAlign"] = true,
            },
            ["sourceId"] = "tdfovercharge01",
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
        ["name"] = "TDFOverCharge01",
        ["tpId"] = "pocuef",
    },
    ["movement"] = {
        ["acceleration"] = 0,
        ["rotationSpeed"] = 60,
        ["speedMax"] = 25,
        ["type"] = "TargetEntity",
    },
    ["nonUniformScale"] = {
        ["x"] = 1,
        ["y"] = 1,
        ["z"] = 1,
    },
    ["visuals"] = {
        ["mesh"] = {
            ["lod0distance"] = 150,
        },
        ["onImpactEffects"] = {
            [1] = {
                ["effects"] = {
                    [1] = {
                        ["particleName"] = "VFX/SCOM/Commanders/ChosenStyle/UEF/impact.sanvfx",
                    },
                },
            },
        },
        ["persistantEffects"] = {
            [1] = {
                ["effects"] = {
                    [1] = {
                        ["particleName"] = "VFX/SCOM/Commanders/ChosenStyle/UEF/projectile.sanvfx",
                    },
                },
            },
        },
    },
}
