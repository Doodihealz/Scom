-- ues3513: Tier 3: FA UEF Naval Factory
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Right_Exhaust",
            [2] = "Center_Exhaust",
            [3] = "Left_Exhaust",
        },
        ["faAirFactoryLifecycle"] = {
            ["animationOwner"] = "host Engine.PlayAnimation sentinel sampler",
            ["buildDurationSeconds"] = 2,
            ["buildSampleSeconds"] = 0.1,
            ["platformBoneName"] = "Attachpoint01",
            ["returnSeconds"] = 0.1,
        },
        ["faSourceContract"] = {
            ["basisYawDegrees"] = 180,
            ["collisionOffset"] = {
                ["x"] = 0,
                ["y"] = -1,
                ["z"] = 0,
            },
            ["footprint"] = {
                ["x"] = 4,
                ["y"] = 10,
            },
            ["minimumWaterDepth"] = 0.5,
            ["skirt"] = {
                ["sourceOffsetX"] = -7,
                ["sourceOffsetZ"] = -1,
                ["x"] = 12,
                ["y"] = 14,
            },
            ["sourceBlueprintSha256"] = "2DB53B3F328E08E5BD4308EB080E456C22E5242FEF6DCF551C1EC29FB5F318B3",
            ["sourceId"] = "UEB0303",
            ["sourceUniformScale"] = 0.083,
            ["targetFacing"] = "South",
            ["targetId"] = "ues3513",
            ["textureResolution"] = 2048,
        },
        ["scoFactoryEgress"] = {
            ["bounds"] = {
                ["max"] = {
                    ["x"] = 7.424804,
                    ["y"] = 2.509946,
                    ["z"] = 9.059945,
                },
                ["min"] = {
                    ["x"] = -7.160708,
                    ["y"] = -22.592197,
                    ["z"] = -10.621736,
                },
            },
            ["buildBone"] = "Attachpoint01",
            ["buildOffset"] = {
                ["x"] = -3.022643,
                ["y"] = 0.01,
                ["z"] = -0.743904,
            },
            ["domain"] = "naval",
            ["exitRoutes"] = {
                [1] = {
                    ["direction"] = {
                        ["x"] = 0,
                        ["y"] = 0,
                        ["z"] = 1,
                    },
                    ["extendByChildExtent"] = true,
                    ["headingDegrees"] = 0,
                    ["heightMode"] = "attachment-origin-until-clear-then-native-air-or-water-altitude",
                    ["minimumClearanceDistance"] = 17.487808,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = 180,
                        ["X"] = -3,
                        ["Y"] = 0,
                        ["Z"] = -8,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = -3.022643,
                            ["y"] = 0.01,
                            ["z"] = 8,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = -3.022643,
                            ["y"] = 0.01,
                            ["z"] = 16.743904,
                        },
                    },
                },
                [2] = {
                    ["direction"] = {
                        ["x"] = 0,
                        ["y"] = 0,
                        ["z"] = -1,
                    },
                    ["extendByChildExtent"] = true,
                    ["headingDegrees"] = 180,
                    ["heightMode"] = "attachment-origin-until-clear-then-native-air-or-water-altitude",
                    ["minimumClearanceDistance"] = 14.512192,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = 0,
                        ["X"] = -3,
                        ["Y"] = 0,
                        ["Z"] = 8,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = -3.022643,
                            ["y"] = 0.01,
                            ["z"] = -8,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = -3.022643,
                            ["y"] = 0.01,
                            ["z"] = -15.256096,
                        },
                    },
                },
            },
            ["productOverrides"] = {
                ["uen3001"] = {
                    ["buildOffset"] = {
                        ["x"] = -3.16981,
                        ["y"] = 0.01,
                        ["z"] = -0.743904,
                    },
                    ["exitRoutes"] = {
                        [1] = {
                            ["direction"] = {
                                ["x"] = 0,
                                ["y"] = 0,
                                ["z"] = 1,
                            },
                            ["extendByChildExtent"] = true,
                            ["headingDegrees"] = 0,
                            ["heightMode"] = "attachment-origin-until-clear-then-native-air-or-water-altitude",
                            ["minimumClearanceDistance"] = 17.487808,
                            ["sourcePoint"] = {
                                ["UnitSpin"] = 180,
                                ["X"] = -3,
                                ["Y"] = 0,
                                ["Z"] = -8,
                            },
                            ["waypoints"] = {
                                [1] = {
                                    ["phase"] = "deck",
                                    ["x"] = -3.16981,
                                    ["y"] = 0.01,
                                    ["z"] = 8,
                                },
                                [2] = {
                                    ["phase"] = "clearance",
                                    ["x"] = -3.16981,
                                    ["y"] = 0.01,
                                    ["z"] = 16.743904,
                                },
                            },
                        },
                        [2] = {
                            ["direction"] = {
                                ["x"] = 0,
                                ["y"] = 0,
                                ["z"] = -1,
                            },
                            ["extendByChildExtent"] = true,
                            ["headingDegrees"] = 180,
                            ["heightMode"] = "attachment-origin-until-clear-then-native-air-or-water-altitude",
                            ["minimumClearanceDistance"] = 14.512192,
                            ["sourcePoint"] = {
                                ["UnitSpin"] = 0,
                                ["X"] = -3,
                                ["Y"] = 0,
                                ["Z"] = 8,
                            },
                            ["waypoints"] = {
                                [1] = {
                                    ["phase"] = "deck",
                                    ["x"] = -3.16981,
                                    ["y"] = 0.01,
                                    ["z"] = -8,
                                },
                                [2] = {
                                    ["phase"] = "clearance",
                                    ["x"] = -3.16981,
                                    ["y"] = 0.01,
                                    ["z"] = -15.256096,
                                },
                            },
                        },
                    },
                    ["measurement"] = {
                        ["outwardClearanceMargin"] = 0.025,
                        ["reason"] = "Both source naval exit directions clear the visible product/factory meshes",
                    },
                },
            },
            ["sourceId"] = "UEB0303",
            ["targetId"] = "ues3513",
            ["version"] = 1,
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "UEB0303",
            ["targetId"] = "ues3513",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.2,
                ["y"] = 6.9,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 4,
            ["y"] = 2,
            ["z"] = 10,
        },
    },
    ["construction"] = {
        ["buildPower"] = 60,
        ["canBuild"] = "(Tags.EDA * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.NAVAL * Tags.MOBILE) + Tags.NAVAL_FACTORY)) * Tags.SCFA_ALLUNITS",
        ["platformBoneName"] = "Attachpoint01",
        ["rollOffPoints"] = {
            [1] = {
                ["exitScale"] = 2,
                ["offset"] = {
                    ["x"] = -3,
                    ["y"] = 0,
                    ["z"] = 8,
                },
                ["platformOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = 0,
            },
            [2] = {
                ["exitScale"] = 2,
                ["offset"] = {
                    ["x"] = -3,
                    ["y"] = 0,
                    ["z"] = -8,
                },
                ["platformOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = 180,
            },
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 40000,
            ["regen"] = 0,
            ["value"] = 40000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 7200,
        ["cost"] = {
            ["alloys"] = 3150,
            ["energy"] = 23400,
        },
        ["storage"] = {
            ["alloys"] = 320,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 4,
        ["y"] = 10,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAFaUefNavalFactory",
        },
        ["displayName"] = "Tier 3: FA UEF Naval Factory",
        ["icon"] = {
            ["shape"] = "structure2",
            ["symbol"] = "naval",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure2_naval.png",
        ["iconUIBuildSortPriority"] = 390,
        ["iconUIType"] = "water",
        ["name"] = "Naval Factory",
        ["orders"] = {
            ["Assist"] = true,
            ["Pause"] = false,
            ["Stop"] = true,
        },
        ["requiresWaterPlacement"] = true,
        ["toggles"] = {
            ["Pause"] = false,
            ["RepeatBuild"] = true,
        },
        ["tpId"] = "ues3513",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
    },
    ["skirtSize"] = {
        ["x"] = 12,
        ["y"] = 14,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_FACTORY",
        [2] = "EDA",
        [3] = "STRUCTURE",
        [4] = "CONSTRUCTION",
        [5] = "FACTORY",
        [6] = "NAVAL_FACTORY",
        [7] = "NAVAL",
        [8] = "TECH3",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER2FACTORY",
        [11] = "SCFA_CONSTRUCTION",
        [12] = "SCFA_CONSTRUCTIONSORTDOWN",
        [13] = "SCFA_DRAGBUILD",
        [14] = "SCFA_FACTORY",
        [15] = "SCFA_NAVAL",
        [16] = "SCFA_PRODUCTSC1",
        [17] = "SCFA_RALLYPOINT",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_SHOWQUEUE",
        [21] = "SCFA_SIZE16",
        [22] = "SCFA_SORTCONSTRUCTION",
        [23] = "SCFA_STRUCTURE",
        [24] = "SCFA_TECH3",
        [25] = "SCFA_UEF",
        [26] = "SCFA_VISIBLETORECON",
        [27] = "BUILDABLE_BY_T3_ENGINEER",
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimBuild",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ues3513/LOD0/ues3513.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues3513/LOD0/ues3513.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 1,
                ["y"] = 1,
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
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/ved2301_death_building_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.72,
                    ["y"] = 0.5,
                    ["z"] = -2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.88,
                    ["y"] = 0.36,
                    ["z"] = 1.7999999999999998,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8,
                    ["y"] = 0.56,
                    ["z"] = 1.6,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.72,
                    ["y"] = 0.84,
                    ["z"] = -2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.88,
                    ["y"] = 0.8,
                    ["z"] = 1.7999999999999998,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 190,
            ["lod1distance"] = 495,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.2,
                ["y"] = 6.9,
            },
            ["thickness"] = 0.26,
        },
    },
}
