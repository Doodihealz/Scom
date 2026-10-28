-- ues1512: Tier 1: Air Factory
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Muzzle01",
        },
        ["faAirFactoryLifecycle"] = {
            ["animationOwner"] = "host Engine.PlayAnimation sentinel sampler",
            ["buildDurationSeconds"] = 1.2,
            ["buildSampleSeconds"] = 0.1,
            ["platformBoneName"] = "Attachpoint",
            ["returnSeconds"] = 0.1,
        },
        ["faSourceContract"] = {
            ["basisYawDegrees"] = 180,
            ["collisionOffset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["footprint"] = {
                ["x"] = 5,
                ["y"] = 5,
            },
            ["minimumWaterDepth"] = 0,
            ["skirt"] = {
                ["sourceOffsetX"] = -1.5,
                ["sourceOffsetZ"] = -1.5,
                ["x"] = 8,
                ["y"] = 8,
            },
            ["sourceBlueprintSha256"] = "AF008440765EC6FE36C134C66892FFFA7D1B3A969D03EE48D7E16AD7AB5450B1",
            ["sourceId"] = "UEB0102",
            ["sourceUniformScale"] = 0.1,
            ["targetFacing"] = "South",
            ["targetId"] = "ues1512",
            ["textureResolution"] = 2048,
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "upgrade",
            ["durationSeconds"] = 6.666666507720947,
            ["restAnimationKey"] = "walk",
        },
        ["scoFactoryEgress"] = {
            ["bounds"] = {
                ["max"] = {
                    ["x"] = 2.503556,
                    ["y"] = 4.000642,
                    ["z"] = 2.937128,
                },
                ["min"] = {
                    ["x"] = -2.499882,
                    ["y"] = -1.223761,
                    ["z"] = -2.499907,
                },
            },
            ["buildBone"] = "Attachpoint",
            ["buildOffset"] = {
                ["x"] = 0,
                ["y"] = 0.960025,
                ["z"] = 0,
            },
            ["domain"] = "air",
            ["engineerRoute"] = {
                ["buildBottomClearance"] = 0.96,
                ["buildOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0.96,
                    ["z"] = 0,
                },
                ["direction"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = -1,
                },
                ["distanceRule"] = "max(sourceOutDistance, minimumOutDistance + child projected rear extent + required clearance margin)",
                ["extendByChildExtent"] = true,
                ["landingMode"] = "terrain-and-product-preferred-altitude-after-horizontal-clearance",
                ["matchingEngineer"] = "uel1501",
                ["minimumOutDistance"] = 2.499907,
                ["platformClip"] = {
                    ["animationKey"] = "platform",
                    ["attachmentPath"] = {
                        [1] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0,
                        },
                        [2] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.909119,
                                ["z"] = 0,
                            },
                            ["time"] = 0.03333333507180214,
                        },
                        [3] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.858238,
                                ["z"] = 0,
                            },
                            ["time"] = 0.06666667014360428,
                        },
                        [4] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.807356,
                                ["z"] = 0,
                            },
                            ["time"] = 0.10000000149011612,
                        },
                        [5] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.756475,
                                ["z"] = 0,
                            },
                            ["time"] = 0.13333334028720856,
                        },
                        [6] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.705594,
                                ["z"] = 0,
                            },
                            ["time"] = 0.1666666716337204,
                        },
                        [7] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.654713,
                                ["z"] = 0,
                            },
                            ["time"] = 0.20000000298023224,
                        },
                        [8] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.603832,
                                ["z"] = 0,
                            },
                            ["time"] = 0.23333333432674408,
                        },
                        [9] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.55295,
                                ["z"] = 0,
                            },
                            ["time"] = 0.2666666805744171,
                        },
                        [10] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.502069,
                                ["z"] = 0,
                            },
                            ["time"] = 0.30000001192092896,
                        },
                        [11] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.451188,
                                ["z"] = 0,
                            },
                            ["time"] = 0.3333333432674408,
                        },
                        [12] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.400307,
                                ["z"] = 0,
                            },
                            ["time"] = 0.36666667461395264,
                        },
                        [13] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.349426,
                                ["z"] = 0,
                            },
                            ["time"] = 0.4000000059604645,
                        },
                        [14] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.298544,
                                ["z"] = 0,
                            },
                            ["time"] = 0.4333333373069763,
                        },
                        [15] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.247663,
                                ["z"] = 0,
                            },
                            ["time"] = 0.46666666865348816,
                        },
                        [16] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.196782,
                                ["z"] = 0,
                            },
                            ["time"] = 0.5,
                        },
                    },
                    ["clipName"] = "AnimPlatform",
                    ["duration"] = 0.5,
                    ["holdFromConstructionStart"] = true,
                    ["time"] = 0,
                },
                ["reason"] = "Build on raised Attachpoint, then sample the compiled platform and product together before outward release.",
                ["reservationHalfWidth"] = 0.394584,
                ["sourceDownDistance"] = 2.75,
                ["sourceOutDistance"] = 3,
                ["sourceSpeed"] = 1.5,
                ["staticSweepEvidence"] = "Conservative axis-aligned engineer envelope: UEF platform-end forward; Cybran/Aeon side; Seraphim forward. Full child extent must clear factory envelope before lowering.",
            },
            ["exitRoutes"] = {
                [1] = {
                    ["direction"] = {
                        ["x"] = 0,
                        ["y"] = 0,
                        ["z"] = -1,
                    },
                    ["extendByChildExtent"] = true,
                    ["headingDegrees"] = 180,
                    ["heightMode"] = "attachment-origin-until-clear-then-native-air-or-water-altitude",
                    ["minimumClearanceDistance"] = 6,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = 0,
                        ["X"] = 0,
                        ["Y"] = 0,
                        ["Z"] = 3,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = 0,
                            ["y"] = 0.960025,
                            ["z"] = -3,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = 0,
                            ["y"] = 0.960025,
                            ["z"] = -6,
                        },
                    },
                },
                [2] = {
                    ["direction"] = {
                        ["x"] = -1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["extendByChildExtent"] = true,
                    ["headingDegrees"] = -90,
                    ["heightMode"] = "attachment-origin-until-clear-then-native-air-or-water-altitude",
                    ["minimumClearanceDistance"] = 6,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = -90,
                        ["X"] = -3,
                        ["Y"] = 0,
                        ["Z"] = 0,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = -3,
                            ["y"] = 0.960025,
                            ["z"] = 0,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = -6,
                            ["y"] = 0.960025,
                            ["z"] = 0,
                        },
                    },
                },
            },
            ["productOverrides"] = {
                ["uea5004"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 4.026883,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 5,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
            },
            ["sourceId"] = "UEB0102",
            ["targetId"] = "ues1512",
            ["version"] = 1,
        },
        ["scoFactoryEngineerEgress"] = {
            ["canBuild"] = "Tags.EDA * Tags.BUILDABLE_BY_T1_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)",
            ["className"] = {
                [1] = "unitsDefaultEDA",
                [2] = "EDAFaUefAirFactory",
            },
            ["engineers"] = {
                [1] = "uel1501",
            },
            ["faction"] = "EDA",
            ["originalCanBuild"] = "Tags.EDA * Tags.BUILDABLE_BY_T1_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)",
            ["platformBoneName"] = "Attachpoint",
            ["platformEvidence"] = {
                ["bone"] = "Attachpoint",
                ["path"] = "Units/ues1512/LOD0/ues1512.sanskeleton",
                ["sha256"] = "e9a49beb25759865b38af6c66acd235c5a3d7608dfa5a51b6b3cb06a30039849",
            },
            ["sourceBlueprint"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 9246,
                ["entry"] = "units/UEB0102/UEB0102_unit.bp",
                ["sha256"] = "af008440765ec6fe36c134c66892fffa7d1b3a969d03ee48d7e16ad7ab5450b1",
            },
            ["sourceBuildableCategories"] = {
                [1] = "BUILTBYTIER1FACTORY UEF MOBILE CONSTRUCTION",
                [2] = "BUILTBYTIER1FACTORY UEF STRUCTURE AIR",
                [3] = "BUILTBYTIER1FACTORY UEF MOBILE AIR",
                [4] = "TRANSPORTBUILTBYTIER1FACTORY UEF MOBILE AIR",
            },
            ["sourceId"] = "UEB0102",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1455,
                ["entry"] = "units/UEB0102/UEB0102_script.lua",
                ["sha256"] = "c0c9b1137432cabb26d45183e99b70d5760d3d79bac89610262532cd76b75854",
            },
            ["standardEngineers"] = {
                [1] = "uel1501",
            },
            ["targetId"] = "ues1512",
            ["tier"] = 1,
            ["upgradesTo"] = "ues2512",
            ["version"] = 1,
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "UEB0102",
            ["targetId"] = "ues1512",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.375,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3.2,
                ["y"] = 3.1,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.375,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 3.5,
            ["y"] = 0.75,
            ["z"] = 3.5,
        },
    },
    ["construction"] = {
        ["buildPower"] = 20,
        ["canBuild"] = "(Tags.EDA * Tags.BUILDABLE_BY_T1_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)) * Tags.SCFA_ALLUNITS",
        ["platformBoneName"] = "Attachpoint",
        ["rollOffPoints"] = {
            [1] = {
                ["exitScale"] = 2,
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = -3,
                },
                ["platformOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = 180,
            },
            [2] = {
                ["exitScale"] = 2,
                ["offset"] = {
                    ["x"] = -3,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["platformOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = -90,
            },
        },
        ["upgradesTo"] = "ues2512",
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
            ["alloys"] = 210,
            ["energy"] = 2400,
        },
        ["storage"] = {
            ["alloys"] = 80,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAFaUefAirFactory",
        },
        ["displayName"] = "Tier 1: Air Factory",
        ["icon"] = {
            ["shape"] = "structure2",
            ["symbol"] = "air",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure2_air.png",
        ["iconUIBuildSortPriority"] = 390,
        ["iconUIType"] = "air",
        ["name"] = "Air Factory",
        ["orders"] = {
            ["Assist"] = true,
            ["Pause"] = false,
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["RepeatBuild"] = true,
        },
        ["tpId"] = "ues1512",
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
        ["x"] = 8,
        ["y"] = 8,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T1_ENGINEER",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "EDA",
        [5] = "STRUCTURE",
        [6] = "CONSTRUCTION",
        [7] = "FACTORY",
        [8] = "AIR_FACTORY",
        [9] = "AIR",
        [10] = "TECH1",
        [11] = "LAND",
        [12] = "SCFA_AIR",
        [13] = "SCFA_ALLUNITS",
        [14] = "SCFA_BUILTBYCOMMANDER",
        [15] = "SCFA_BUILTBYTIER1ENGINEER",
        [16] = "SCFA_BUILTBYTIER2ENGINEER",
        [17] = "SCFA_BUILTBYTIER3ENGINEER",
        [18] = "SCFA_CONSTRUCTION",
        [19] = "SCFA_DRAGBUILD",
        [20] = "SCFA_FACTORY",
        [21] = "SCFA_PRODUCTSC1",
        [22] = "SCFA_RALLYPOINT",
        [23] = "SCFA_RECLAIMABLE",
        [24] = "SCFA_SELECTABLE",
        [25] = "SCFA_SHOWQUEUE",
        [26] = "SCFA_SIZE16",
        [27] = "SCFA_SORTCONSTRUCTION",
        [28] = "SCFA_STRUCTURE",
        [29] = "SCFA_TECH1",
        [30] = "SCFA_UEF",
        [31] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimBuild",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ues1512/LOD0/ues1512.sananimation",
            },
            ["platform"] = {
                ["clipName"] = "AnimPlatform",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues1512/LOD0/ues1512.sananimation",
            },
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues1512/LOD0/ues1512.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues1512/LOD0/ues1512.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.63,
                    ["y"] = 0.5625,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.77,
                    ["y"] = 0.51,
                    ["z"] = 0.63,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.7000000000000001,
                    ["y"] = 0.585,
                    ["z"] = 0.56,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.63,
                    ["y"] = 0.69,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.77,
                    ["y"] = 0.675,
                    ["z"] = 0.63,
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
                ["y"] = 0.375,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3.2,
                ["y"] = 3.1,
            },
            ["thickness"] = 0.3,
        },
    },
}
