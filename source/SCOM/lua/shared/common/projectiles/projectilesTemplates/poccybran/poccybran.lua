-- Dedicated Overcharge identity; reuses the installed faction cannon VFX.
-- Runtime owns payment, targeting, damage, muzzle handoff and cooldown.
ProjectileTemplate = {
    ["additions"] = {
        ["scoOvercharge"] = {
            ["sourceId"] = "URL0001",
            ["version"] = "1.0.0",
            ["visualSourceTemplate"] = "psf0166",
        },
        ["scoSourceProjectile"] = {
            ["blueprintSha256"] = "15c8f6e9021e91de9966d0f8a212c68ea419d6911934d8e93a3f772444ba6a9a",
            ["categories"] = {
                [1] = "CYBRAN",
                [2] = "PROJECTILE",
                [3] = "DIRECTFIRE",
            },
            ["physics"] = {
                ["DestroyOnWater"] = true,
                ["InitialSpeed"] = 20,
                ["TrackTarget"] = true,
                ["TurnRate"] = 60,
                ["UseGravity"] = false,
            },
            ["sourceId"] = "cdfcannonmolecularovercharge01",
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
        ["name"] = "CDFCannonMolecularOvercharge01",
        ["tpId"] = "poccybran",
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
                        ["particleName"] = "VFX/SCOM/Commanders/ChosenStyle/Cybran/impact.sanvfx",
                    },
                },
            },
        },
        ["persistantEffects"] = {
            [1] = {
                ["effects"] = {
                    [1] = {
                        ["particleName"] = "VFX/SCOM/Commanders/ChosenStyle/Cybran/projectile.sanvfx",
                    },
                },
            },
        },
    },
}
