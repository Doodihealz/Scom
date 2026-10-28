-- ues1513: Tier 1: FA UEF Naval Factory
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Right_Exhaust",
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
            ["sourceBlueprintSha256"] = "535033CD33ED70440625920E37E3112E4CA33AC1476F5F32CA42E441230808CA",
            ["sourceId"] = "UEB0103",
            ["sourceUniformScale"] = 0.083,
            ["targetFacing"] = "South",
            ["targetId"] = "ues1513",
            ["textureResolution"] = 2048,
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "upgrade",
            ["durationSeconds"] = 10,
            ["restAnimationKey"] = "walk",
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
                ["x"] = -1.777643,
                ["y"] = 0.01,
                ["z"] = -0.743929,
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
                    ["minimumClearanceDistance"] = 17.487858,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = 180,
                        ["X"] = -2,
                        ["Y"] = 0,
                        ["Z"] = -8,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = -1.777643,
                            ["y"] = 0.01,
                            ["z"] = 8,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = -1.777643,
                            ["y"] = 0.01,
                            ["z"] = 16.743929,
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
                    ["minimumClearanceDistance"] = 14.512142,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = 0,
                        ["X"] = -2,
                        ["Y"] = 0,
                        ["Z"] = 8,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = -1.777643,
                            ["y"] = 0.01,
                            ["z"] = -8,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = -1.777643,
                            ["y"] = 0.01,
                            ["z"] = -15.256071,
                        },
                    },
                },
            },
            ["productOverrides"] = {
                ["uen1001"] = {
                    ["buildOffset"] = {
                        ["x"] = -1.98425,
                        ["y"] = 0.01,
                        ["z"] = -0.743929,
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
                            ["minimumClearanceDistance"] = 17.487858,
                            ["sourcePoint"] = {
                                ["UnitSpin"] = 180,
                                ["X"] = -2,
                                ["Y"] = 0,
                                ["Z"] = -8,
                            },
                            ["waypoints"] = {
                                [1] = {
                                    ["phase"] = "deck",
                                    ["x"] = -1.98425,
                                    ["y"] = 0.01,
                                    ["z"] = 8,
                                },
                                [2] = {
                                    ["phase"] = "clearance",
                                    ["x"] = -1.98425,
                                    ["y"] = 0.01,
                                    ["z"] = 16.743929,
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
                            ["minimumClearanceDistance"] = 14.512142,
                            ["sourcePoint"] = {
                                ["UnitSpin"] = 0,
                                ["X"] = -2,
                                ["Y"] = 0,
                                ["Z"] = 8,
                            },
                            ["waypoints"] = {
                                [1] = {
                                    ["phase"] = "deck",
                                    ["x"] = -1.98425,
                                    ["y"] = 0.01,
                                    ["z"] = -8,
                                },
                                [2] = {
                                    ["phase"] = "clearance",
                                    ["x"] = -1.98425,
                                    ["y"] = 0.01,
                                    ["z"] = -15.256071,
                                },
                            },
                        },
                    },
                    ["measurement"] = {
                        ["outwardClearanceMargin"] = 0.025,
                        ["reason"] = "Both source naval exit directions clear the visible product/factory meshes",
                    },
                },
                ["uen1304"] = {
                    ["buildOffset"] = {
                        ["x"] = -2.2409,
                        ["y"] = 0.01,
                        ["z"] = -0.743929,
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
                            ["minimumClearanceDistance"] = 17.487858,
                            ["sourcePoint"] = {
                                ["UnitSpin"] = 180,
                                ["X"] = -2,
                                ["Y"] = 0,
                                ["Z"] = -8,
                            },
                            ["waypoints"] = {
                                [1] = {
                                    ["phase"] = "deck",
                                    ["x"] = -2.2409,
                                    ["y"] = 0.01,
                                    ["z"] = 8,
                                },
                                [2] = {
                                    ["phase"] = "clearance",
                                    ["x"] = -2.2409,
                                    ["y"] = 0.01,
                                    ["z"] = 16.743929,
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
                            ["minimumClearanceDistance"] = 14.512142,
                            ["sourcePoint"] = {
                                ["UnitSpin"] = 0,
                                ["X"] = -2,
                                ["Y"] = 0,
                                ["Z"] = 8,
                            },
                            ["waypoints"] = {
                                [1] = {
                                    ["phase"] = "deck",
                                    ["x"] = -2.2409,
                                    ["y"] = 0.01,
                                    ["z"] = -8,
                                },
                                [2] = {
                                    ["phase"] = "clearance",
                                    ["x"] = -2.2409,
                                    ["y"] = 0.01,
                                    ["z"] = -15.256071,
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
            ["sourceId"] = "UEB0103",
            ["targetId"] = "ues1513",
            ["version"] = 1,
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "UEB0103",
            ["targetId"] = "ues1513",
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
        ["buildPower"] = 20,
        ["canBuild"] = "(Tags.EDA * Tags.BUILDABLE_BY_T1_FACTORY * ((Tags.NAVAL * Tags.MOBILE) + Tags.NAVAL_FACTORY)) * Tags.SCFA_ALLUNITS",
        ["platformBoneName"] = "Attachpoint01",
        ["rollOffPoints"] = {
            [1] = {
                ["exitScale"] = 2,
                ["offset"] = {
                    ["x"] = -2,
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
                    ["x"] = -2,
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
        ["upgradesTo"] = "ues2513",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 4800,
            ["regen"] = 0,
            ["value"] = 4800,
        },
    },
    ["economy"] = {
        ["buildTime"] = 300,
        ["cost"] = {
            ["alloys"] = 300,
            ["energy"] = 1500,
        },
        ["storage"] = {
            ["alloys"] = 80,
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
        ["displayName"] = "Tier 1: FA UEF Naval Factory",
        ["icon"] = {
            ["shape"] = "structure2",
            ["symbol"] = "naval",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure2_naval.png",
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
        ["tpId"] = "ues1513",
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
        [1] = "BUILDABLE_BY_T1_ENGINEER",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "EDA",
        [5] = "STRUCTURE",
        [6] = "CONSTRUCTION",
        [7] = "FACTORY",
        [8] = "NAVAL_FACTORY",
        [9] = "NAVAL",
        [10] = "TECH1",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYCOMMANDER",
        [13] = "SCFA_BUILTBYTIER1ENGINEER",
        [14] = "SCFA_BUILTBYTIER2ENGINEER",
        [15] = "SCFA_BUILTBYTIER3ENGINEER",
        [16] = "SCFA_CONSTRUCTION",
        [17] = "SCFA_DRAGBUILD",
        [18] = "SCFA_FACTORY",
        [19] = "SCFA_NAVAL",
        [20] = "SCFA_PRODUCTSC1",
        [21] = "SCFA_RALLYPOINT",
        [22] = "SCFA_RECLAIMABLE",
        [23] = "SCFA_SELECTABLE",
        [24] = "SCFA_SHOWQUEUE",
        [25] = "SCFA_SIZE16",
        [26] = "SCFA_SORTCONSTRUCTION",
        [27] = "SCFA_STRUCTURE",
        [28] = "SCFA_TECH1",
        [29] = "SCFA_UEF",
        [30] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimBuild",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ues1513/LOD0/ues1513.sananimation",
            },
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues1513/LOD0/ues1513.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues1513/LOD0/ues1513.sananimation",
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
