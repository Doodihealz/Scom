-- usa1502: Vish
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoCargo"] = {
            ["airPortable"] = true,
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0,
                [3] = 0,
            },
            ["attachmentReference"] = "entity origin fallback: source model has no AttachPoint",
            ["canCarryCommander"] = true,
            ["canFire"] = true,
            ["cargoClass"] = 10,
            ["commander"] = false,
            ["genericUpTo"] = 0,
            ["portable"] = false,
            ["slots"] = {
                [1] = {
                    ["bone"] = "Left_Attachpoint02",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 1,
                    },
                    ["position"] = {
                        [1] = 1.5258105750558686,
                        [2] = 0.02989086414171936,
                        [3] = 1.219907019202877,
                    },
                },
                [2] = {
                    ["bone"] = "Left_Attachpoint03",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 2,
                    },
                    ["position"] = {
                        [1] = 1.5306054809621648,
                        [2] = 0.03946086476735214,
                        [3] = 1.834890863311873,
                    },
                },
                [3] = {
                    ["bone"] = "Left_Attachpoint04",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 3,
                    },
                    ["position"] = {
                        [1] = 1.4605370414785117,
                        [2] = 0.06218250756339351,
                        [3] = 2.4591238198655905,
                    },
                },
                [4] = {
                    ["bone"] = "Left_Attachpoint05",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 4,
                    },
                    ["position"] = {
                        [1] = 1.3079221228788578,
                        [2] = 0.07823167774837889,
                        [3] = 3.06708823301375,
                    },
                },
                [5] = {
                    ["bone"] = "Left_Attachpoint06",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 5,
                    },
                    ["position"] = {
                        [1] = 1.1213614889582713,
                        [2] = 0.09948790722685444,
                        [3] = 3.653290820569911,
                    },
                },
                [6] = {
                    ["bone"] = "Left_Attachpoint07",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 6,
                    },
                    ["position"] = {
                        [1] = 0.9844791060239546,
                        [2] = 0.14666645505933876,
                        [3] = 4.1963530318080915,
                    },
                },
                [7] = {
                    ["bone"] = "Left_Attachpoint08",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 7,
                    },
                    ["position"] = {
                        [1] = 0.780869958144225,
                        [2] = 0.16590670723955345,
                        [3] = 4.763433569536882,
                    },
                },
                [8] = {
                    ["bone"] = "Left_Attachpoint01",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 8,
                    },
                    ["position"] = {
                        [1] = 1.5153571895352136,
                        [2] = 0.04449431519052555,
                        [3] = 0.6155530967024809,
                    },
                },
                [9] = {
                    ["bone"] = "Attachpoint_Med01",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 8,
                        [2] = 1,
                    },
                    ["position"] = {
                        [1] = 1.4186610826498767,
                        [2] = 0.025225219445012916,
                        [3] = 0.900338338333193,
                    },
                },
                [10] = {
                    ["bone"] = "Attachpoint_Med02",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 2,
                        [2] = 3,
                    },
                    ["position"] = {
                        [1] = 1.3818371677477432,
                        [2] = 0.059980080747024225,
                        [3] = 2.1295351953819863,
                    },
                },
                [11] = {
                    ["bone"] = "Attachpoint_Med03",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 4,
                        [2] = 5,
                    },
                    ["position"] = {
                        [1] = 1.176744293348789,
                        [2] = 0.11275030642688406,
                        [3] = 3.2986590173271573,
                    },
                },
                [12] = {
                    ["bone"] = "Attachpoint_Lrg01",
                    ["cargoClass"] = 3,
                    ["occupies"] = {
                        [1] = 8,
                        [2] = 1,
                        [3] = 2,
                        [4] = 3,
                    },
                    ["position"] = {
                        [1] = 9.72948644149521e-07,
                        [2] = 0.39920004054001756,
                        [3] = -0.2985213515763376,
                    },
                },
                [13] = {
                    ["bone"] = "Attachpoint_Med04",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 6,
                        [2] = 7,
                    },
                    ["position"] = {
                        [1] = 0.8228383174436852,
                        [2] = 0.15395509995372006,
                        [3] = 4.402579163832171,
                    },
                },
            },
            ["sourceId"] = "XSA0107",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 105479,
                ["entry"] = "units/XSA0107/XSA0107_lod0.scm",
                ["sha256"] = "0d9bd9cb064f2e3aeb80bbdfc895c8914b906afbab2693ddcef1f93f146c37ee",
            },
            ["sourceTransport"] = {
                ["AirClass"] = true,
                ["Class2AttachSize"] = 2,
                ["Class3AttachSize"] = 4,
                ["TransportClass"] = 10,
            },
        },
        ["scoMissingCrashImpact"] = {
            ["damage"] = 100,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["sourceBlueprintSha256"] = "07b0bf12c674fa7ada32a104f1141e63471db38392fd1777b2b4a9f9e23d16e5",
            ["sourceId"] = "XSA0107",
            ["sourceIndex"] = 1,
            ["targetId"] = "usa1502",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = -0.5,
                ["z"] = 1.5,
            },
            ["size"] = {
                ["x"] = 2.1,
                ["y"] = 4.5,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1523",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod5110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.5,
            ["z"] = 1.5,
        },
        ["collisionSize"] = {
            ["x"] = 4.5,
            ["y"] = 3,
            ["z"] = 7,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 750,
            ["regen"] = 0,
            ["value"] = 750,
        },
    },
    ["economy"] = {
        ["buildTime"] = 400,
        ["cost"] = {
            ["alloys"] = 80,
            ["energy"] = 1600,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 4,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimAirUnit",
        },
        ["displayName"] = "Vish",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "none",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_air1_none.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "air",
        ["name"] = "Vish",
        ["orders"] = {
            ["Assist"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
            ["Transport"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "usa1502",
        ["unitTypeName"] = "UnknownT1Transport",
    },
    ["intel"] = {
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 10,
        ["air"] = true,
        ["airHover"] = true,
        ["altitudeJitterFactor"] = 1,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Air",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["landWhenIdleSeconds"] = 5,
        ["maxBankDegrees"] = 0,
        ["minSpeed"] = 0,
        ["orbitRange"] = 6.36619772367581,
        ["orbitSpeed"] = 10,
        ["patternBySituation"] = {
            ["hold"] = "idle",
            ["move"] = "cruise",
        },
        ["patterns"] = {
            ["cruise"] = {
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["offset"] = {
                        ["x"] = -1.275,
                        ["y"] = 1.275,
                    },
                },
            },
            ["idle"] = {
                ["mode"] = "Orbit",
                ["orbit"] = {
                    ["acceleration"] = 2.833,
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["facing"] = "hold",
                    ["maxSpeed"] = 1.7,
                    ["radius"] = {
                        ["x"] = 0,
                        ["y"] = 0.15,
                    },
                },
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["offset"] = {
                        ["x"] = -1.275,
                        ["y"] = 1.275,
                    },
                    ["syncToLateralPhase"] = true,
                },
            },
        },
        ["preferredAltitude"] = 8,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 5,
        ["speed"] = 10,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Gunship",
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T1_FACTORY",
        [2] = "BUILDABLE_BY_T2_FACTORY",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "MOBILE",
        [5] = "SCFA_AIR",
        [6] = "SCFA_ALLUNITS",
        [7] = "SCFA_CANNOTUSEAIRSTAGING",
        [8] = "SCFA_CANTRANSPORTCOMMANDER",
        [9] = "SCFA_MOBILE",
        [10] = "SCFA_PRODUCTFA",
        [11] = "SCFA_RECLAIMABLE",
        [12] = "SCFA_SELECTABLE",
        [13] = "SCFA_SERAPHIM",
        [14] = "SCFA_TECH1",
        [15] = "SCFA_TRANSPORTATION",
        [16] = "SCFA_TRANSPORTBUILTBYTIER1FACTORY",
        [17] = "SCFA_TRANSPORTBUILTBYTIER2FACTORY",
        [18] = "SCFA_TRANSPORTBUILTBYTIER3FACTORY",
        [19] = "SCFA_TRANSPORTFOCUS",
        [20] = "SCFA_VISIBLETORECON",
        [21] = "SERAPHIM",
        [22] = "TECH1",
        [23] = "TRANSPORT",
        [24] = "AIR",
        [25] = "GUNSHIP",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usa1502/LOD0/usa1502.sananimation",
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
        ["effectsInstant"] = {
            ["onDeath"] = {
                [1] = {
                    ["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Explosions/mi explosion 03 hpx.ogg",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/SCOM/Death/vcd3101_death_air_small.sanvfx",
                },
            },
            ["onImpact"] = {
                [1] = {
                    ["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Explosions/mi explosion 03 hpx.ogg",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/SCOM/Death/vcd3101_death_air_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8099999999999999,
                    ["y"] = 0.25,
                    ["z"] = 0.09999999999999987,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.99,
                    ["y"] = 0.040000000000000036,
                    ["z"] = 2.76,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.9,
                    ["y"] = 0.3400000000000001,
                    ["z"] = 2.62,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8099999999999999,
                    ["y"] = 0.76,
                    ["z"] = 0.09999999999999987,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.99,
                    ["y"] = 0.7000000000000002,
                    ["z"] = 2.76,
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
                ["y"] = -0.5,
                ["z"] = 1.5,
            },
            ["size"] = {
                ["x"] = 2.1,
                ["y"] = 4.5,
            },
        },
    },
    ["weapons"] = {},
}
