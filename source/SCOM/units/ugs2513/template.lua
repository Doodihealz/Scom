-- ugs2513: Tier 2: FA Cybran Naval Factory
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Right_Exhaust03",
            [2] = "Right_Exhaust02",
        },
        ["faAirFactoryLifecycle"] = {
            ["animationOwner"] = "host Engine.PlayAnimation sentinel sampler",
            ["buildDurationSeconds"] = 6.66666651,
            ["buildSampleSeconds"] = 0.1,
            ["platformBoneName"] = "Attachpoint",
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
            ["minimumWaterDepth"] = 1.5,
            ["skirt"] = {
                ["sourceOffsetX"] = -6,
                ["sourceOffsetZ"] = -2,
                ["x"] = 12,
                ["y"] = 14,
            },
            ["sourceBlueprintSha256"] = "C4B8ADDD484FF90A4F5FF241621D4B12FCD05960DF3FB5CC1B1B22B3F5F996E2",
            ["sourceId"] = "URB0203",
            ["sourceUniformScale"] = 0.1,
            ["targetFacing"] = "South",
            ["targetId"] = "ugs2513",
            ["textureResolution"] = 2048,
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "upgrade",
            ["durationSeconds"] = 26.66666603088379,
            ["restAnimationKey"] = "walk",
        },
        ["scoFactoryEgress"] = {
            ["bounds"] = {
                ["max"] = {
                    ["x"] = 1.446813,
                    ["y"] = 1.802109,
                    ["z"] = 7.190228,
                },
                ["min"] = {
                    ["x"] = -2.526527,
                    ["y"] = -14.990005,
                    ["z"] = -5.779225,
                },
            },
            ["buildBone"] = "Attachpoint",
            ["buildOffset"] = {
                ["x"] = 3,
                ["y"] = 0.01,
                ["z"] = 0.7168,
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
                    ["minimumClearanceDistance"] = 14.5664,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = 180,
                        ["X"] = -2,
                        ["Y"] = 0,
                        ["Z"] = -8,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = 3,
                            ["y"] = 0.01,
                            ["z"] = 8,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = 3,
                            ["y"] = 0.01,
                            ["z"] = 15.2832,
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
                    ["minimumClearanceDistance"] = 17.4336,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = 0,
                        ["X"] = -2,
                        ["Y"] = 0,
                        ["Z"] = 8,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = 3,
                            ["y"] = 0.01,
                            ["z"] = -8,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = 3,
                            ["y"] = 0.01,
                            ["z"] = -16.7168,
                        },
                    },
                },
            },
            ["sourceId"] = "URB0203",
            ["targetId"] = "ugs2513",
            ["version"] = 1,
        },
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "URB0203",
            ["targetId"] = "ugs2513",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.6,
                ["y"] = 8.1,
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
        ["buildPower"] = 40,
        ["canBuild"] = "(Tags.GUARD * Tags.BUILDABLE_BY_T2_FACTORY * ((Tags.NAVAL * Tags.MOBILE) + Tags.NAVAL_FACTORY)) * Tags.SCFA_ALLUNITS",
        ["platformBoneName"] = "Attachpoint",
        ["rollOffPoints"] = {
            [1] = {
                ["exitScale"] = 2,
                ["offset"] = {
                    ["x"] = 2,
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
                    ["x"] = 2,
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
        ["upgradesTo"] = "ugs3513",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 15000,
            ["regen"] = 0,
            ["value"] = 15000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1800,
        ["cost"] = {
            ["alloys"] = 1170,
            ["energy"] = 5400,
        },
        ["storage"] = {
            ["alloys"] = 160,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 4,
        ["y"] = 10,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardFaCybranNavalFactory",
        },
        ["displayName"] = "Tier 2: FA Cybran Naval Factory",
        ["icon"] = {
            ["shape"] = "structure2",
            ["symbol"] = "naval",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure2_naval.png",
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
        ["tpId"] = "ugs2513",
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
        [1] = "BUILDABLE_BY_T1_FACTORY",
        [2] = "GUARD",
        [3] = "STRUCTURE",
        [4] = "CONSTRUCTION",
        [5] = "FACTORY",
        [6] = "NAVAL_FACTORY",
        [7] = "NAVAL",
        [8] = "TECH2",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER1FACTORY",
        [11] = "SCFA_CONSTRUCTION",
        [12] = "SCFA_CONSTRUCTIONSORTDOWN",
        [13] = "SCFA_CYBRAN",
        [14] = "SCFA_DRAGBUILD",
        [15] = "SCFA_FACTORY",
        [16] = "SCFA_NAVAL",
        [17] = "SCFA_PRODUCTSC1",
        [18] = "SCFA_RALLYPOINT",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_SHOWQUEUE",
        [22] = "SCFA_SIZE16",
        [23] = "SCFA_SORTCONSTRUCTION",
        [24] = "SCFA_STRUCTURE",
        [25] = "SCFA_TECH2",
        [26] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimBuild",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ugs2513/LOD0/ugs2513.sananimation",
            },
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs2513/LOD0/ugs2513.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs2513/LOD0/ugs2513.sananimation",
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
                    ["particleName"] = "VFX/Death/vgd2301_death_building_large.sanvfx",
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
                ["x"] = 2.6,
                ["y"] = 8.1,
            },
            ["thickness"] = 0.21,
        },
    },
}
