-- ugs1512: Tier 1: FA Cybran Air Factory
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Arm02_Muzzle",
            [2] = "Arm01_Muzzle",
        },
        ["faAirFactoryLifecycle"] = {
            ["animationOwner"] = "host Engine.PlayAnimation sentinel sampler",
            ["buildDurationSeconds"] = 7.33333349,
            ["buildSampleSeconds"] = 0.1,
            ["platformBoneName"] = "Build_Point",
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
            ["sourceBlueprintSha256"] = "A88242605A599B30590B8AAA6E190ADF85683F9AE1CA6CCDD72796D9D36B68B8",
            ["sourceId"] = "URB0102",
            ["sourceUniformScale"] = 0.09,
            ["targetFacing"] = "South",
            ["targetId"] = "ugs1512",
            ["textureResolution"] = 2048,
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "upgrade",
            ["durationSeconds"] = 4.666666507720947,
            ["restAnimationKey"] = "walk",
        },
        ["scoFactoryEgress"] = {
            ["bounds"] = {
                ["max"] = {
                    ["x"] = 3.019457,
                    ["y"] = 3.133224,
                    ["z"] = 3.213343,
                },
                ["min"] = {
                    ["x"] = -3.019453,
                    ["y"] = -2.526377,
                    ["z"] = -2.340003,
                },
            },
            ["buildBone"] = "Build_Point",
            ["buildOffset"] = {
                ["x"] = 0,
                ["y"] = 0.865,
                ["z"] = -3e-06,
            },
            ["domain"] = "air",
            ["engineerRoute"] = {
                ["buildBottomClearance"] = 0.865,
                ["direction"] = {
                    ["x"] = 1,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["distanceRule"] = "max(sourceOutDistance, minimumOutDistance + child projected rear extent + required clearance margin)",
                ["extendByChildExtent"] = true,
                ["landingMode"] = "terrain-and-product-preferred-altitude-after-horizontal-clearance",
                ["matchingEngineer"] = "ugl1501",
                ["minimumOutDistance"] = 3.019457,
                ["reservationHalfWidth"] = 0.270814,
                ["sourceDownDistance"] = 2.75,
                ["sourceOutDistance"] = 3,
                ["sourceSpeed"] = 1.5,
                ["staticSweepEvidence"] = "Conservative axis-aligned engineer envelope: UEF platform-end forward; Cybran/Aeon side; Seraphim forward. Full child extent must clear factory envelope before lowering.",
            },
            ["exitRoutes"] = {
                [1] = {
                    ["direction"] = {
                        ["x"] = -0.991998,
                        ["y"] = 0,
                        ["z"] = -0.126253,
                    },
                    ["extendByChildExtent"] = true,
                    ["headingDegrees"] = -97.253134,
                    ["heightMode"] = "attachment-origin-until-clear-then-native-air-or-water-altitude",
                    ["minimumClearanceDistance"] = 5.544366,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = 90,
                        ["X"] = 2.75,
                        ["Y"] = 0,
                        ["Z"] = 0.35,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = -2.75,
                            ["y"] = 0.865,
                            ["z"] = -0.35,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = -5.5,
                            ["y"] = 0.865,
                            ["z"] = -0.699997,
                        },
                    },
                },
                [2] = {
                    ["direction"] = {
                        ["x"] = 0.991998,
                        ["y"] = 0,
                        ["z"] = -0.126253,
                    },
                    ["extendByChildExtent"] = true,
                    ["headingDegrees"] = 97.253134,
                    ["heightMode"] = "attachment-origin-until-clear-then-native-air-or-water-altitude",
                    ["minimumClearanceDistance"] = 5.544366,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = -90,
                        ["X"] = -2.75,
                        ["Y"] = 0,
                        ["Z"] = 0.35,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = 2.75,
                            ["y"] = 0.865,
                            ["z"] = -0.35,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = 5.5,
                            ["y"] = 0.865,
                            ["z"] = -0.699997,
                        },
                    },
                },
            },
            ["productOverrides"] = {
                ["uga1001"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 1.611321,
                        ["z"] = -3e-06,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 222,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uga1502"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 1.560775,
                        ["z"] = -3e-06,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 222,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uga5003"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 1.578753,
                        ["z"] = -3e-06,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 222,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
            },
            ["sourceId"] = "URB0102",
            ["targetId"] = "ugs1512",
            ["version"] = 1,
        },
        ["scoFactoryEngineerEgress"] = {
            ["canBuild"] = "(Tags.GUARD * Tags.BUILDABLE_BY_T1_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)) + (Tags.ugl1501)",
            ["className"] = {
                [1] = "unitsDefaultGuard",
                [2] = "GuardFaCybranAirFactory",
            },
            ["engineers"] = {
                [1] = "ugl1501",
            },
            ["faction"] = "GUARD",
            ["originalCanBuild"] = "Tags.GUARD * Tags.BUILDABLE_BY_T1_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)",
            ["platformBoneName"] = "Build_Point",
            ["platformEvidence"] = {
                ["bone"] = "Build_Point",
                ["path"] = "Units/ugs1512/LOD0/ugs1512.sanskeleton",
                ["sha256"] = "e0c5f9c3b15839d3105e214a23b6646aad5191df052b9e6ac68d23260412c590",
            },
            ["sourceBlueprint"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 9548,
                ["entry"] = "units/URB0102/URB0102_unit.bp",
                ["sha256"] = "a88242605a599b30590b8aaa6e190adf85683f9ae1ca6ccdd72796d9d36b68b8",
            },
            ["sourceBuildableCategories"] = {
                [1] = "BUILTBYTIER1FACTORY CYBRAN MOBILE CONSTRUCTION",
                [2] = "BUILTBYTIER1FACTORY CYBRAN STRUCTURE AIR",
                [3] = "BUILTBYTIER1FACTORY CYBRAN MOBILE AIR",
                [4] = "TRANSPORTBUILTBYTIER1FACTORY CYBRAN MOBILE AIR",
            },
            ["sourceId"] = "URB0102",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 724,
                ["entry"] = "units/URB0102/URB0102_script.lua",
                ["sha256"] = "2126fa2aa80c0b735fc24eeaafd9283bf04d74716facd6016d72f83b91a37aeb",
            },
            ["standardEngineers"] = {
                [1] = "ugl1501",
            },
            ["targetId"] = "ugs1512",
            ["tier"] = 1,
            ["upgradesTo"] = "ugs2512",
            ["version"] = 1,
        },
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "URB0102",
            ["targetId"] = "ugs1512",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.375,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3,
                ["y"] = 3,
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
        ["canBuild"] = "((Tags.GUARD * Tags.BUILDABLE_BY_T1_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)) + (Tags.ugl1501)) * Tags.SCFA_ALLUNITS",
        ["platformBoneName"] = "Build_Point",
        ["rollOffPoints"] = {
            [1] = {
                ["exitScale"] = 2,
                ["offset"] = {
                    ["x"] = -2.75,
                    ["y"] = 0,
                    ["z"] = -0.35,
                },
                ["platformOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = -90,
            },
            [2] = {
                ["exitScale"] = 2,
                ["offset"] = {
                    ["x"] = 2.75,
                    ["y"] = 0,
                    ["z"] = -0.35,
                },
                ["platformOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = 90,
            },
        },
        ["upgradesTo"] = "ugs2512",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 4200,
            ["regen"] = 0,
            ["value"] = 4200,
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
            [1] = "unitsDefaultGuard",
            [2] = "GuardFaCybranAirFactory",
        },
        ["displayName"] = "Tier 1: FA Cybran Air Factory",
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
        ["tpId"] = "ugs1512",
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
        [4] = "GUARD",
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
        [19] = "SCFA_CYBRAN",
        [20] = "SCFA_DRAGBUILD",
        [21] = "SCFA_FACTORY",
        [22] = "SCFA_PRODUCTSC1",
        [23] = "SCFA_RALLYPOINT",
        [24] = "SCFA_RECLAIMABLE",
        [25] = "SCFA_SELECTABLE",
        [26] = "SCFA_SHOWQUEUE",
        [27] = "SCFA_SIZE16",
        [28] = "SCFA_SORTCONSTRUCTION",
        [29] = "SCFA_STRUCTURE",
        [30] = "SCFA_TECH1",
        [31] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimBuild",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ugs1512/LOD0/ugs1512.sananimation",
            },
            ["platform"] = {
                ["clipName"] = "AnimPlatform",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs1512/LOD0/ugs1512.sananimation",
            },
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs1512/LOD0/ugs1512.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs1512/LOD0/ugs1512.sananimation",
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
                ["x"] = 3,
                ["y"] = 3,
            },
            ["thickness"] = 0.33,
        },
    },
}
