-- uea5011: C-D2 "Rover-2"
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["fuelIntentionallyOmitted"] = true,
            ["runtimeBehaviorApproval"] = false,
            ["sourceAir"] = {
                ["BankFactor"] = 0.1,
                ["BankForward"] = false,
                ["CanFly"] = true,
                ["CirclingDirChangeFrequencySec"] = 1,
                ["CirclingElevationChangeRatio"] = 0.25,
                ["CirclingRadiusChangeMaxRatio"] = 0.9,
                ["CirclingRadiusChangeMinRatio"] = 0.6,
                ["CirclingTurnMult"] = 2,
                ["KLift"] = 1,
                ["KLiftDamping"] = 1,
                ["KMove"] = 1,
                ["KMoveDamping"] = 1.2,
                ["KTurn"] = 3,
                ["KTurnDamping"] = 3,
                ["LiftFactor"] = 5,
                ["MaxAirspeed"] = 4,
                ["MinAirspeed"] = 3,
                ["StartTurnDistance"] = 5,
            },
            ["sourceAnimations"] = {},
            ["sourceBlueprint"] = "units/XEA3204/XEA3204_unit.bp",
            ["sourceBlueprintSha256"] = "71f41f577a5ce5eccd9c20b992790f54a4fda4e8e6be873edee4fcc090a8bbe5",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "XEA3204",
            ["sourceIntel"] = {
                ["VisionRadius"] = 12,
            },
            ["sourceMovement"] = {
                ["BankingSlope"] = 0.5,
                ["BuildOnLayerCaps"] = {
                    ["LAYER_Air"] = true,
                    ["LAYER_Land"] = false,
                    ["LAYER_Orbit"] = false,
                    ["LAYER_Seabed"] = false,
                    ["LAYER_Sub"] = false,
                    ["LAYER_Water"] = false,
                },
                ["Elevation"] = 0.4,
                ["GroundCollisionOffset"] = 0.2,
                ["MaxAcceleration"] = 10,
                ["MaxSpeed"] = 10,
                ["MaxSteerForce"] = 100,
                ["MinSpeedPercent"] = 0.85,
                ["MotionType"] = "RULEUMT_Air",
                ["TurnRadius"] = 100,
                ["TurnRate"] = 100,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 2607,
                ["entry"] = "units/XEA3204/XEA3204_script.lua",
                ["sha256"] = "61cc0236b7ee5ddc0eeb925c43a3d70f2b16db0773edab10708fbb327d8b7f13",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {
                [1] = {
                    ["AboveWaterTargetsOnly"] = true,
                    ["Damage"] = 10,
                    ["DamageFriendly"] = true,
                    ["DamageRadius"] = 1,
                    ["DamageType"] = "Normal",
                    ["DisplayName"] = "Air Crash",
                    ["DummyWeapon"] = true,
                    ["FiringTolerance"] = 2,
                    ["Label"] = "DeathImpact",
                    ["WeaponCategory"] = "Death",
                },
            },
            ["targetId"] = "uea5011",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoCargo"] = {
            ["airPortable"] = true,
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0,
                [3] = 0,
            },
            ["canFire"] = false,
            ["cargoClass"] = 1,
            ["portable"] = false,
            ["slots"] = {},
            ["unfoldDuration"] = 0,
        },
        ["scoSourcePods"] = {
            ["kind"] = "pod",
            ["sourceId"] = "XEA3204",
            ["targetId"] = "uea5011",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = -0.07,
        },
        ["collisionSize"] = {
            ["x"] = 0.5,
            ["y"] = 0.2,
            ["z"] = 0.5,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Arm_Muzzle",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 15,
        ["canBuild"] = "(Tags.SCFA_IMPOSSIBLE) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 6,
            ["regen"] = 0,
            ["value"] = 6,
        },
    },
    ["economy"] = {
        ["buildTime"] = 750,
        ["cost"] = {
            ["alloys"] = 250,
            ["energy"] = 2500,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAEngineer",
        },
        ["displayName"] = "C-D2 \"Rover-2\"",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "engineer",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_air1_engineer.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "air",
        ["name"] = "C-D2 \"Rover-2\"",
        ["orders"] = {
            ["Assist"] = true,
            ["Capture"] = true,
            ["Harvest"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Repair"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "uea5011",
    },
    ["intel"] = {
        ["visionRadius"] = 12,
    },
    ["movement"] = {
        ["acceleration"] = 10,
        ["air"] = true,
        ["airHover"] = false,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0.1,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Air",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Air",
        },
        ["landWhenIdleSeconds"] = 5,
        ["maxBankDegrees"] = 3,
        ["minSpeed"] = 3,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["patternBySituation"] = {
            ["assist"] = "circle",
            ["attack"] = "strafe",
            ["hold"] = "circle",
            ["move"] = "cruise",
        },
        ["patterns"] = {
            ["circle"] = {
                ["circle"] = {
                    ["radius"] = 0,
                    ["speed"] = 0,
                },
                ["mode"] = "Circle",
            },
            ["cruise"] = {},
            ["strafe"] = {
                ["mode"] = "Strafe",
                ["strafe"] = {
                    ["matchTargetSpeed"] = true,
                    ["runOutLength"] = 14.324,
                },
            },
        },
        ["preferredAltitude"] = 0.4,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 100,
        ["sortOrder"] = 1,
        ["speed"] = 4,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Plane",
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 5,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 12,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 12,
        },
    },
    ["tags"] = {
        [1] = "AIR",
        [2] = "EDA",
        [3] = "ENGINEER",
        [4] = "MOBILE",
        [5] = "SCFA_AIR",
        [6] = "SCFA_ALLUNITS",
        [7] = "SCFA_CAPTURE",
        [8] = "SCFA_ENGINEER",
        [9] = "SCFA_MOBILE",
        [10] = "SCFA_POD",
        [11] = "SCFA_RECLAIM",
        [12] = "SCFA_RECLAIMABLE",
        [13] = "SCFA_REPAIR",
        [14] = "SCFA_SELECTABLE",
        [15] = "SCFA_SHOWQUEUE",
        [16] = "SCFA_STATIONASSISTPOD",
        [17] = "SCFA_TECH1",
        [18] = "SCFA_UEF",
        [19] = "SCFA_VISIBLETORECON",
        [20] = "TECH1",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uea5011/LOD0/uea5011.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uea5011/LOD0/uea5011.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.4,
                ["y"] = 0.4,
            },
            ["mainBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 15,
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.05,
                    ["z"] = -0.17,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.036,
                    ["z"] = 0.01999999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.1,
                    ["y"] = 0.05600000000000001,
                    ["z"] = 0.009999999999999995,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.084,
                    ["z"] = -0.17,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.08000000000000002,
                    ["z"] = 0.01999999999999999,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 107,
            ["lod1distance"] = 279,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = -0.07,
            },
            ["size"] = {
                ["x"] = 0.3,
                ["y"] = 0.3,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 10,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["scoFaSourceWeaponIndex"] = 1,
        },
    },
}
