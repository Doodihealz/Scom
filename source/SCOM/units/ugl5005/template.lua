-- ugl5005: Deceiver
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
            ["sourceBlueprint"] = "units/URL0306/URL0306_unit.bp",
            ["sourceBlueprintSha256"] = "f2da062ae6b14af5b2ed53ddfdd06830f885c0abfa675d870bcba4fd491feecb",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "URL0306",
            ["sourceIntel"] = {
                ["RadarStealth"] = true,
                ["RadarStealthField"] = true,
                ["RadarStealthFieldRadius"] = 18,
                ["SonarStealthFieldRadius"] = 18,
                ["VisionRadius"] = 16,
            },
            ["sourceMovement"] = {
                ["BankingSlope"] = 0,
                ["BuildOnLayerCaps"] = {
                    ["LAYER_Air"] = false,
                    ["LAYER_Land"] = true,
                    ["LAYER_Orbit"] = false,
                    ["LAYER_Seabed"] = false,
                    ["LAYER_Sub"] = false,
                    ["LAYER_Water"] = false,
                },
                ["DragCoefficient"] = 0.2,
                ["MaxAcceleration"] = 4,
                ["MaxBrake"] = 4,
                ["MaxSpeed"] = 4,
                ["MaxSpeedReverse"] = 0,
                ["MaxSteerForce"] = 10,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_Land",
                ["RotateOnSpot"] = true,
                ["RotateOnSpotThreshold"] = 0.1,
                ["TurnRadius"] = 0,
                ["TurnRate"] = 120,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1356,
                ["entry"] = "units/URL0306/URL0306_Script.lua",
                ["sha256"] = "b76d128b70d579d111717553044ce70d9616bb71be855c07518d89353e086eec",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ugl5005",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0.5005761053114688,
                [3] = -0.17085440232998994,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "URL0306",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 78920,
                ["entry"] = "units/URL0306/URL0306_lod0.scm",
                ["sha256"] = "6d81a16ebe93fa656728a26edeabb12f8a2cb7be2ecb4e6909749100fc870c3f",
            },
        },
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/ugl5005/LOD0/ugl5005_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.11702682077884674,
                        ["y"] = -5.7127147604432715e-08,
                        ["z"] = -0.044745534658423014,
                    },
                    ["width"] = 0.206518,
                },
                [2] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.11702682077884674,
                        ["y"] = -5.7127147604432715e-08,
                        ["z"] = -0.044745534658423014,
                    },
                    ["width"] = 0.206518,
                },
            },
            ["unit"] = "ugl5005",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.6,
            ["y"] = 0.2,
            ["z"] = 0.7,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 350,
            ["regen"] = 0,
            ["value"] = 350,
        },
    },
    ["economy"] = {
        ["buildTime"] = 400,
        ["cost"] = {
            ["alloys"] = 80,
            ["energy"] = 800,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 25,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardLandUnit",
        },
        ["displayName"] = "Deceiver",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_land1_direct.png",
        ["iconUIBuildSortPriority"] = 60,
        ["iconUIType"] = "land",
        ["name"] = "Deceiver",
        ["orders"] = {
            ["Assist"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ugl5005",
    },
    ["intel"] = {
        ["visionRadius"] = 16,
    },
    ["movement"] = {
        ["acceleration"] = 4,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 4,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 120,
        ["sortOrder"] = 1,
        ["speed"] = 4,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "TracksLand",
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 16,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 16,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_FACTORY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "GUARD",
        [4] = "LAND",
        [5] = "MOBILE",
        [6] = "SCFA_ALLUNITS",
        [7] = "SCFA_BUILTBYTIER2FACTORY",
        [8] = "SCFA_BUILTBYTIER3FACTORY",
        [9] = "SCFA_COUNTERINTELLIGENCE",
        [10] = "SCFA_CYBRAN",
        [11] = "SCFA_INTELLIGENCE",
        [12] = "SCFA_LAND",
        [13] = "SCFA_MOBILE",
        [14] = "SCFA_OVERLAYCOUNTERINTEL",
        [15] = "SCFA_PRODUCTSC1",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_TECH2",
        [19] = "SCFA_VISIBLETORECON",
        [20] = "TECH2",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ugl5005/LOD0/ugl5005.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ugl5005/LOD0/ugl5005.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.05,
                    ["z"] = -0.13999999999999999,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.036,
                    ["z"] = 0.126,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = 0.05600000000000001,
                    ["z"] = 0.11199999999999999,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.084,
                    ["z"] = -0.13999999999999999,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.08000000000000002,
                    ["z"] = 0.126,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 65,
            ["lod1distance"] = 171,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.35,
                ["y"] = 0.45,
            },
        },
    },
    ["weapons"] = {},
}
