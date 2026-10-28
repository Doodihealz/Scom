-- Dedicated Overcharge identity; reuses the installed faction cannon VFX.
-- Runtime owns payment, targeting, damage, muzzle handoff and cooldown.
ProjectileTemplate = {
    ["additions"] = {
        ["scoOvercharge"] = {
            ["sourceId"] = "UAL0001",
            ["version"] = "1.0.0",
            ["visualSourceTemplate"] = "psf0165",
        },
        ["scoSourceProjectile"] = {
            ["blueprintSha256"] = "bd77321e26ea78e8abce2a699849133833457cf498750a54d5c33b8c23b37427",
            ["categories"] = {
                [1] = "AEON",
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
            ["sourceId"] = "adfovercharge01",
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
        ["name"] = "ADFOverCharge01",
        ["tpId"] = "pocaeon",
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
            ["lod0distance"] = 60,
        },
        ["onImpactEffects"] = {
            [1] = {
                ["effects"] = {
                    [1] = {
                        ["particleName"] = "VFX/SCOM/Commanders/ChosenStyle/Aeon/impact.sanvfx",
                    },
                },
            },
        },
        ["persistantEffects"] = {
            [1] = {
                ["effects"] = {
                    [1] = {
                        ["particleName"] = "VFX/SCOM/Commanders/ChosenStyle/Aeon/projectile.sanvfx",
                    },
                },
            },
        },
    },
}
