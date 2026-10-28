-- ucn5001: Aeon Boat
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["fuelIntentionallyOmitted"] = false,
            ["runtimeBehaviorApproval"] = false,
            ["sourceAir"] = {},
            ["sourceAnimations"] = {},
            ["sourceBlueprint"] = "units/XAC0101/XAC0101_unit.bp",
            ["sourceBlueprintSha256"] = "2656f661a16ec2ce40119384bab3b839f767c87b513fbda00db2ef3465eff235",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "XAC0101",
            ["sourceIntel"] = {},
            ["sourceMovement"] = {
                ["BackUpDistance"] = 5,
                ["BankingSlope"] = 0,
                ["BuildOnLayerCaps"] = {
                    ["LAYER_Air"] = false,
                    ["LAYER_Land"] = false,
                    ["LAYER_Orbit"] = false,
                    ["LAYER_Seabed"] = false,
                    ["LAYER_Sub"] = false,
                    ["LAYER_Water"] = true,
                },
                ["CatchUpAcc"] = 10,
                ["DragCoefficient"] = 0.2,
                ["MaxAcceleration"] = 5,
                ["MaxBrake"] = 5,
                ["MaxSpeed"] = 5,
                ["MaxSpeedReverse"] = 5,
                ["MaxSteerForce"] = 5,
                ["MeshExtentsX"] = 3.2,
                ["MeshExtentsY"] = 2.2,
                ["MeshExtentsZ"] = 3.2,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_Water",
                ["TurnRadius"] = 15,
                ["TurnRate"] = 50,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 423,
                ["entry"] = "units/XAC0101/XAC0101_script.lua",
                ["sha256"] = "0170ae1f161513b0906e62c5fe5fa3be8c54fb155d06bd92d016a3fae3951991",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ucn5001",
            ["unsupportedWeaponBindings"] = {},
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2.5,
            ["y"] = 2.5,
            ["z"] = 2.5,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 5500,
            ["regen"] = 0,
            ["value"] = 5500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 50,
        ["cost"] = {
            ["alloys"] = 5,
            ["energy"] = 50,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 4,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "ChosenNavalUnit",
        },
        ["displayName"] = "Aeon Boat",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "water",
        ["name"] = "Aeon Boat",
        ["orders"] = {
            ["Assist"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ucn5001",
    },
    ["intel"] = {
        ["visionRadius"] = 0,
    },
    ["movement"] = {
        ["acceleration"] = 5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 5,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 50,
        ["sortOrder"] = 1,
        ["speed"] = 5,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
    },
    ["tags"] = {
        [1] = "CHOSEN",
        [2] = "CIVILIAN",
        [3] = "MOBILE",
        [4] = "NAVAL",
        [5] = "SCFA_AEON",
        [6] = "SCFA_ALLUNITS",
        [7] = "SCFA_CIVILIAN",
        [8] = "SCFA_MOBILE",
        [9] = "SCFA_NAVAL",
        [10] = "SCFA_RECLAIMABLE",
        [11] = "SCFA_SELECTABLE",
        [12] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucn5001/LOD0/ucn5001.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucn5001/LOD0/ucn5001.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
            },
            ["mainBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 20,
            },
            ["progressBars"] = {
                [1] = {
                    ["colorBackground"] = {
                        ["a"] = 1,
                        ["x"] = 0,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["colorEmpty"] = {
                        ["a"] = 1,
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["colorFull"] = {
                        ["a"] = 1,
                        ["x"] = 0,
                        ["y"] = 1,
                        ["z"] = 0,
                    },
                    ["mainBar"] = true,
                    ["name"] = "Health",
                    ["property"] = "Health_Current",
                    ["xOffset"] = 0,
                    ["xScale"] = 1,
                },
            },
            ["subBarDisplayScale"] = {
                ["x"] = 1,
                ["y"] = 1,
            },
            ["subBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 0,
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.44999999999999996,
                    ["y"] = 0.625,
                    ["z"] = -0.5,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.55,
                    ["y"] = 0.44999999999999996,
                    ["z"] = 0.44999999999999996,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.5,
                    ["y"] = 0.7000000000000001,
                    ["z"] = 0.4,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.44999999999999996,
                    ["y"] = 1.05,
                    ["z"] = -0.5,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.55,
                    ["y"] = 1,
                    ["z"] = 0.44999999999999996,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 150,
            ["lod1distance"] = 390,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.75,
                ["y"] = 2.5,
            },
        },
    },
    ["weapons"] = {},
}
