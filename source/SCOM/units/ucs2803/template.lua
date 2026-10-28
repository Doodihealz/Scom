-- ucs2803: Keefer Class
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {
                    ["sonarRadius"] = 40,
                    ["waterVisionRadius"] = 36,
                },
                ["runtimeSupported"] = {
                    ["radarRadius"] = 200,
                    ["visionRadius"] = 85,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 5,
                    ["z"] = 17,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAS0303/UAS0303_unit.bp",
            ["sourceBlueprintSha256"] = "e81be2657406fe199d88ea9b1ae654de3d78d72057d0490a78c2261e479fc259",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "AIRSTAGINGPLATFORM",
                [3] = "ANTIAIR",
                [4] = "BUILTBYTIER3FACTORY",
                [5] = "CARRIER",
                [6] = "FACTORY",
                [7] = "MOBILE",
                [8] = "NAVAL",
                [9] = "NAVALCARRIER",
                [10] = "OVERLAYANTIAIR",
                [11] = "OVERLAYMISC",
                [12] = "OVERLAYRADAR",
                [13] = "OVERLAYSONAR",
                [14] = "PRODUCTSC1",
                [15] = "RECLAIMABLE",
                [16] = "REPAIR",
                [17] = "SELECTABLE",
                [18] = "SHOWQUEUE",
                [19] = "TECH3",
                [20] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAS0303",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 2.5,
            ["sourceMotionType"] = "RULEUMT_Water",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs2803",
            ["weapons"] = {
                [1] = {
                    ["label"] = "AntiAirMissiles01",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Muzzle_Right",
                            },
                            ["rackBone"] = "Turret_Right_Barrel",
                        },
                    },
                    ["rateOfFire"] = 1,
                    ["reloadTime"] = 1,
                    ["sourceCategory"] = "Anti Air",
                    ["sourceProjectile"] = "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp",
                },
                [2] = {
                    ["label"] = "AntiAirMissiles01",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Muzzle_Left",
                            },
                            ["rackBone"] = "Turret_Left_Barrel",
                        },
                    },
                    ["rateOfFire"] = 1,
                    ["reloadTime"] = 1,
                    ["sourceCategory"] = "Anti Air",
                    ["sourceProjectile"] = "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp",
                },
            },
        },
        ["scoCargo"] = {
            ["airStorage"] = true,
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0,
                [3] = 0,
            },
            ["canFire"] = false,
            ["cargoClass"] = 10,
            ["portable"] = false,
            ["slots"] = {
                [1] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 1,
                    },
                },
                [2] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 2,
                    },
                },
                [3] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 3,
                    },
                },
                [4] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 4,
                    },
                },
                [5] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 5,
                    },
                },
                [6] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 6,
                    },
                },
                [7] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 7,
                    },
                },
                [8] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 8,
                    },
                },
                [9] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 9,
                    },
                },
                [10] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 10,
                    },
                },
                [11] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 11,
                    },
                },
                [12] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 12,
                    },
                },
                [13] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 13,
                    },
                },
                [14] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 14,
                    },
                },
                [15] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 15,
                    },
                },
                [16] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 16,
                    },
                },
                [17] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 17,
                    },
                },
                [18] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 18,
                    },
                },
                [19] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 19,
                    },
                },
                [20] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 20,
                    },
                },
                [21] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 21,
                    },
                },
                [22] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 22,
                    },
                },
                [23] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 23,
                    },
                },
                [24] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 24,
                    },
                },
                [25] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 25,
                    },
                },
                [26] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 26,
                    },
                },
                [27] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 27,
                    },
                },
                [28] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 28,
                    },
                },
                [29] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 29,
                    },
                },
                [30] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 30,
                    },
                },
                [31] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 31,
                    },
                },
                [32] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 32,
                    },
                },
                [33] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 33,
                    },
                },
                [34] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 34,
                    },
                },
                [35] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 35,
                    },
                },
                [36] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 36,
                    },
                },
                [37] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 37,
                    },
                },
                [38] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 38,
                    },
                },
                [39] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 39,
                    },
                },
                [40] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 40,
                    },
                },
                [41] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 41,
                    },
                },
                [42] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 42,
                    },
                },
                [43] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 43,
                    },
                },
                [44] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 44,
                    },
                },
                [45] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 45,
                    },
                },
                [46] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 46,
                    },
                },
                [47] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 47,
                    },
                },
                [48] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 48,
                    },
                },
                [49] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 49,
                    },
                },
                [50] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 50,
                    },
                },
                [51] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 51,
                    },
                },
                [52] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 52,
                    },
                },
                [53] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 53,
                    },
                },
                [54] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 54,
                    },
                },
                [55] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 55,
                    },
                },
                [56] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 56,
                    },
                },
                [57] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 57,
                    },
                },
                [58] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 58,
                    },
                },
                [59] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 59,
                    },
                },
                [60] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 60,
                    },
                },
            },
        },
        ["scoIdleResetLocomotion"] = true,
        ["scoSourceDeath"] = {
            ["hasMovement"] = true,
            ["sourceId"] = "UAS0303",
            ["variants"] = {
                [1] = {
                    ["durationSeconds"] = 33.33333206176758,
                    ["key"] = "scoSourceDeath01",
                    ["rateMax"] = 1,
                    ["rateMin"] = 1,
                    ["weight"] = 100,
                },
                [2] = {
                    ["durationSeconds"] = 33.33333206176758,
                    ["key"] = "scoSourceDeath02",
                    ["rateMax"] = 1,
                    ["rateMin"] = 1,
                    ["weight"] = 100,
                },
                [3] = {
                    ["durationSeconds"] = 33.33333206176758,
                    ["key"] = "scoSourceDeath03",
                    ["rateMax"] = 1,
                    ["rateMin"] = 1,
                    ["weight"] = 100,
                },
            },
        },
        ["scoSourceSurfaceCarrier"] = 1,
        ["seaParityUnsupported"] = {},
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.85,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3,
                ["y"] = 10.6,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod3110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.85,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 6.5,
            ["y"] = 2.9,
            ["z"] = 15.7,
        },
    },
    ["construction"] = {
        ["buildPower"] = 150,
        ["canBuild"] = "(Tags.SCFA_BUILTBYTIER3FACTORY * Tags.SCFA_AEON * Tags.SCFA_MOBILE * Tags.SCFA_AIR * (Tags.SCFA_ANTINAVY + Tags.SCFA_INTELLIGENCE + Tags.SCFA_ANTIAIR)) * Tags.SCFA_ALLUNITS",
        ["range"] = 30,
        ["rollOffPoints"] = {
            [1] = {
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["platformOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 0,
                ["unitSpin"] = 0,
            },
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 22000,
            ["regen"] = 0,
            ["value"] = 22000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 12000,
        ["cost"] = {
            ["alloys"] = 4000,
            ["energy"] = 40000,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 17,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortNavalUnit",
        },
        ["displayName"] = "Keefer Class",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Keefer Class",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
            ["Transport"] = true,
        },
        ["toggles"] = {
            ["RepeatBuild"] = false,
        },
        ["tpId"] = "ucs2803",
        ["unitTypeName"] = "Keefer Class",
    },
    ["intel"] = {
        ["radarRadius"] = 200,
        ["visionRadius"] = 85,
    },
    ["movement"] = {
        ["acceleration"] = 3,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 2.5,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 30,
        ["sortOrder"] = 1,
        ["speed"] = 3,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 200,
        },
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 75,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 85,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 85,
        },
    },
    ["tags"] = {
        [1] = "ANTI_AIR",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "CHOSEN",
        [4] = "FACTORY",
        [5] = "INTEL",
        [6] = "MOBILE",
        [7] = "NAVAL",
        [8] = "RADAR",
        [9] = "TECH3",
        [10] = "SCFA_AEON",
        [11] = "SCFA_AIRSTAGINGPLATFORM",
        [12] = "SCFA_ALLUNITS",
        [13] = "SCFA_ANTIAIR",
        [14] = "SCFA_BUILTBYTIER3FACTORY",
        [15] = "SCFA_CARRIER",
        [16] = "SCFA_FACTORY",
        [17] = "SCFA_MOBILE",
        [18] = "SCFA_NAVAL",
        [19] = "SCFA_NAVALCARRIER",
        [20] = "SCFA_OVERLAYANTIAIR",
        [21] = "SCFA_OVERLAYMISC",
        [22] = "SCFA_OVERLAYRADAR",
        [23] = "SCFA_OVERLAYSONAR",
        [24] = "SCFA_PRODUCTSC1",
        [25] = "SCFA_RECLAIMABLE",
        [26] = "SCFA_REPAIR",
        [27] = "SCFA_SELECTABLE",
        [28] = "SCFA_SHOWQUEUE",
        [29] = "SCFA_TECH3",
        [30] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["scoSourceDeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2803/LOD0/ucs2803.sananimation",
            },
            ["scoSourceDeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2803/LOD0/ucs2803.sananimation",
            },
            ["scoSourceDeath03"] = {
                ["clipName"] = "AnimAdeath03",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2803/LOD0/ucs2803.sananimation",
            },
            ["source_animadeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["sanAnimationPath"] = "Units/ucs2803/LOD0/ucs2803.sananimation",
            },
            ["source_animadeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["sanAnimationPath"] = "Units/ucs2803/LOD0/ucs2803.sananimation",
            },
            ["source_animadeath03"] = {
                ["clipName"] = "AnimAdeath03",
                ["sanAnimationPath"] = "Units/ucs2803/LOD0/ucs2803.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucs2803/LOD0/ucs2803.sananimation",
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
        ["effectsInstant"] = {
            ["onDeath"] = {
                [1] = {
                    ["audioName"] = "chosen_unit_death_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.17,
                    ["y"] = 1.575,
                    ["z"] = -3.14,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.43,
                    ["y"] = 1.3719999999999999,
                    ["z"] = 2.8259999999999996,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.3,
                    ["y"] = 1.662,
                    ["z"] = 2.512,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.17,
                    ["y"] = 2.068,
                    ["z"] = -3.14,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.43,
                    ["y"] = 2.01,
                    ["z"] = 2.8259999999999996,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 73,
            ["lod1distance"] = 190,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.85,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3,
                ["y"] = 10.6,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Muzzle_Right",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 50,
                    ["defaultPitchAdjustment"] = 30,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Right_Barrel",
                    ["pitchMax"] = 70,
                    ["pitchMin"] = -10,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret_Right",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 120,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucs2803/muzzle_antiairmissiles01.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Muzzle_Right",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Muzzle_Right"] = {
                    ["aimController"] = "Muzzle_Right",
                },
            },
            ["projectileLifetime"] = 6,
            ["projectileTemplate"] = "psf0049",
            ["rangeMax"] = 75,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "0ad044add942af4aa3d8b092aa2ba5a592074db5df0a27564d831411ea86ed1d",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AntiAirMissiles01",
                ["sourceProjectile"] = "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Air",
            ["scoSourceLabel"] = "AntiAirMissiles01",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AntiAirMissiles01",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Muzzle_Left",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 50,
                    ["defaultPitchAdjustment"] = 30,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Left_Barrel",
                    ["pitchMax"] = 70,
                    ["pitchMin"] = -10,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret_Left",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 120,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucs2803/muzzle_antiairmissiles01.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Muzzle_Left",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Muzzle_Left"] = {
                    ["aimController"] = "Muzzle_Left",
                },
            },
            ["projectileLifetime"] = 6,
            ["projectileTemplate"] = "psf0049",
            ["rangeMax"] = 75,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "0ad044add942af4aa3d8b092aa2ba5a592074db5df0a27564d831411ea86ed1d",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AntiAirMissiles01",
                ["sourceProjectile"] = "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Air",
            ["scoSourceLabel"] = "AntiAirMissiles01",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AntiAirMissiles01",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
