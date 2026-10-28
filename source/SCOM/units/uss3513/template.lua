-- uss3513: Uosiya
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Muzzle01",
            [2] = "Muzzle02",
            [3] = "Muzzle03",
        },
        ["multiConstructionBeam"] = {
            ["materialPath"] = "VFX/SCOM/ConstructionBeams/seraphim.sanmaterial",
            ["prefabName"] = "SCOM_SeraphimNavalMuzzleBeam",
            ["shrink"] = 0.05,
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Pod03",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = -3,
                    ["z"] = 0,
                },
            },
            [2] = {
                ["boneName"] = "Pod01",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 5,
                    ["z"] = 0,
                },
            },
            [3] = {
                ["boneName"] = "Pod02",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 8,
                    ["z"] = 0,
                },
            },
        },
        ["scoFactoryEgress"] = {
            ["bounds"] = {
                ["max"] = {
                    ["x"] = 2.039715,
                    ["y"] = 9.588172,
                    ["z"] = 6.194459,
                },
                ["min"] = {
                    ["x"] = -6.178577,
                    ["y"] = -10.955798,
                    ["z"] = -6.919002,
                },
            },
            ["buildBone"] = "Attachpoint",
            ["buildOffset"] = {
                ["x"] = -5.281595,
                ["y"] = 0.013792,
                ["z"] = -0.212603,
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
                    ["minimumClearanceDistance"] = 20.425206,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = 180,
                        ["X"] = -4,
                        ["Y"] = 0,
                        ["Z"] = -10,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = -5.281595,
                            ["y"] = 0.013792,
                            ["z"] = 10,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = -5.281595,
                            ["y"] = 0.013792,
                            ["z"] = 20.212603,
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
                    ["minimumClearanceDistance"] = 19.574794,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = 0,
                        ["X"] = -4,
                        ["Y"] = 0,
                        ["Z"] = 10,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = -5.281595,
                            ["y"] = 0.013792,
                            ["z"] = -10,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = -5.281595,
                            ["y"] = 0.013792,
                            ["z"] = -19.787397,
                        },
                    },
                },
            },
            ["productOverrides"] = {
                ["usn3001"] = {
                    ["buildOffset"] = {
                        ["x"] = -5.61287,
                        ["y"] = 0.013792,
                        ["z"] = -0.212603,
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
                            ["minimumClearanceDistance"] = 20.425206,
                            ["sourcePoint"] = {
                                ["UnitSpin"] = 180,
                                ["X"] = -4,
                                ["Y"] = 0,
                                ["Z"] = -10,
                            },
                            ["waypoints"] = {
                                [1] = {
                                    ["phase"] = "deck",
                                    ["x"] = -5.61287,
                                    ["y"] = 0.013792,
                                    ["z"] = 10,
                                },
                                [2] = {
                                    ["phase"] = "clearance",
                                    ["x"] = -5.61287,
                                    ["y"] = 0.013792,
                                    ["z"] = 20.212603,
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
                            ["minimumClearanceDistance"] = 19.574794,
                            ["sourcePoint"] = {
                                ["UnitSpin"] = 0,
                                ["X"] = -4,
                                ["Y"] = 0,
                                ["Z"] = 10,
                            },
                            ["waypoints"] = {
                                [1] = {
                                    ["phase"] = "deck",
                                    ["x"] = -5.61287,
                                    ["y"] = 0.013792,
                                    ["z"] = -10,
                                },
                                [2] = {
                                    ["phase"] = "clearance",
                                    ["x"] = -5.61287,
                                    ["y"] = 0.013792,
                                    ["z"] = -19.787397,
                                },
                            },
                        },
                    },
                    ["measurement"] = {
                        ["outwardClearanceMargin"] = 0.025,
                        ["reason"] = "Both source naval exit directions clear the visible product/factory meshes",
                    },
                },
                ["usn3003"] = {
                    ["buildOffset"] = {
                        ["x"] = -6.46431,
                        ["y"] = 0.013792,
                        ["z"] = -0.212603,
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
                            ["minimumClearanceDistance"] = 20.425206,
                            ["sourcePoint"] = {
                                ["UnitSpin"] = 180,
                                ["X"] = -4,
                                ["Y"] = 0,
                                ["Z"] = -10,
                            },
                            ["waypoints"] = {
                                [1] = {
                                    ["phase"] = "deck",
                                    ["x"] = -6.46431,
                                    ["y"] = 0.013792,
                                    ["z"] = 10,
                                },
                                [2] = {
                                    ["phase"] = "clearance",
                                    ["x"] = -6.46431,
                                    ["y"] = 0.013792,
                                    ["z"] = 20.212603,
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
                            ["minimumClearanceDistance"] = 19.574794,
                            ["sourcePoint"] = {
                                ["UnitSpin"] = 0,
                                ["X"] = -4,
                                ["Y"] = 0,
                                ["Z"] = 10,
                            },
                            ["waypoints"] = {
                                [1] = {
                                    ["phase"] = "deck",
                                    ["x"] = -6.46431,
                                    ["y"] = 0.013792,
                                    ["z"] = -10,
                                },
                                [2] = {
                                    ["phase"] = "clearance",
                                    ["x"] = -6.46431,
                                    ["y"] = 0.013792,
                                    ["z"] = -19.787397,
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
            ["sourceId"] = "XSB0303",
            ["targetId"] = "uss3513",
            ["version"] = 1,
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixSeraphimNavalFactory"] = {
            ["attachpointCorrection"] = {
                ["assetOwned"] = true,
                ["boneName"] = "Attachpoint",
                ["correctedBindPoseX"] = -4.531594848632813,
                ["correctedLocalX"] = 4.531594848632813,
                ["localOffsetX"] = -0.75,
                ["runtimeSliderConsumerRequired"] = false,
                ["sourceSliderSpeed"] = -1,
                ["sourceSliderX"] = -15,
                ["sourceUniformScale"] = 0.05,
            },
            ["rotatorMetadataInstalled"] = true,
            ["version"] = "1.0.0",
        },
        ["seaParityWaterFactory"] = true,
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3,
                ["y"] = 8,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 6.666666507720947,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 100,
            },
        },
        ["seraphimNavalBuildPods"] = {
            ["clearance"] = 0.35,
            ["count"] = 3,
            ["lowestPodY"] = 2.83,
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2120",
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
        ["beam"] = {
            ["boneName"] = "Attachpoint",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
        },
        ["buildPower"] = 60,
        ["canBuild"] = "(Tags.SERAPHIM * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.NAVAL * Tags.MOBILE) + Tags.NAVAL_FACTORY)) * Tags.SCFA_ALLUNITS",
        ["platformBoneName"] = "Attachpoint",
        ["rollOffPoints"] = {
            [1] = {
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 10,
                },
                ["unitSpin"] = 0,
            },
            [2] = {
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = -10,
                },
                ["unitSpin"] = 180,
            },
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 38000,
            ["regen"] = 0,
            ["value"] = 38000,
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
        },
    },
    ["footprint"] = {
        ["x"] = 12,
        ["y"] = 14,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimNavalFactory",
        },
        ["displayName"] = "Uosiya",
        ["icon"] = {
            ["shape"] = "structure2",
            ["symbol"] = "air",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure2_air.png",
        ["iconUIBuildSortPriority"] = 390,
        ["iconUIType"] = "water",
        ["name"] = "Uosiya",
        ["orders"] = {
            ["Assist"] = true,
            ["Pause"] = false,
            ["Stop"] = true,
        },
        ["requiresWaterPlacement"] = true,
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["RepeatBuild"] = true,
        },
        ["tpId"] = "uss3513",
        ["unitTypeName"] = "UnknownT3NavalFactory",
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
        [1] = "ALLOYS_STORAGE",
        [2] = "BUILDABLE_BY_T2_FACTORY",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "CONSTRUCTION",
        [5] = "FACTORY",
        [6] = "NAVAL",
        [7] = "NAVAL_FACTORY",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_BUILTBYTIER2FACTORY",
        [10] = "SCFA_CONSTRUCTION",
        [11] = "SCFA_CONSTRUCTIONSORTDOWN",
        [12] = "SCFA_DRAGBUILD",
        [13] = "SCFA_FACTORY",
        [14] = "SCFA_NAVAL",
        [15] = "SCFA_PRODUCTFA",
        [16] = "SCFA_RALLYPOINT",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_SERAPHIM",
        [20] = "SCFA_SHOWQUEUE",
        [21] = "SCFA_SIZE16",
        [22] = "SCFA_SORTCONSTRUCTION",
        [23] = "SCFA_STRUCTURE",
        [24] = "SCFA_TECH3",
        [25] = "SCFA_VISIBLETORECON",
        [26] = "SERAPHIM",
        [27] = "STRUCTURE",
        [28] = "TECH3",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3513/LOD0/uss3513.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3513/LOD0/uss3513.sananimation",
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
                    ["audioName"] = "unit_death_land_eda_large",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd2301_death_building_large.sanvfx",
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
            ["lod0distance"] = 151,
            ["lod1distance"] = 395,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3,
                ["y"] = 8,
            },
        },
    },
}
