-- ugs2512: Tier 2: FA Cybran Air Factory
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Arm01_Muzzle",
            [2] = "Arm02_Muzzle",
            [3] = "Arm03_Muzzle",
            [4] = "Arm04_Muzzle",
        },
        ["faAirFactoryLifecycle"] = {
            ["animationOwner"] = "host Engine.PlayAnimation sentinel sampler",
            ["buildDurationSeconds"] = 7.333333492279053,
            ["buildSampleSeconds"] = 0.1,
            ["platformBoneName"] = "Build_Point",
            ["returnSeconds"] = 0.1,
        },
        ["faSourceContract"] = {
            ["build"] = {
                ["clip"] = "AnimBuild",
                ["durationSeconds"] = 7.333333492279053,
                ["frames"] = 221,
                ["loops"] = true,
                ["pauses"] = true,
                ["source"] = "units/URB0202/URB0202_Abuild.sca",
            },
            ["collision"] = {
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["size"] = {
                    ["x"] = 3.5,
                    ["y"] = 0.75,
                    ["z"] = 3.5,
                },
            },
            ["footprint"] = {
                ["x"] = 5,
                ["y"] = 5,
            },
            ["platform"] = {
                ["clip"] = "AnimPlatform",
                ["durationSeconds"] = 4.333333492279053,
                ["frames"] = 131,
                ["reachableForAirProduction"] = false,
                ["reason"] = "FA gates this clip to LAND while this factory builds AIR",
                ["sourceEvent"] = "AnimationFinishBuildLand",
            },
            ["runtimeClass"] = "unitsDefaultGuard/GuardFaCybranAirFactory",
            ["selection"] = {
                ["size"] = {
                    ["x"] = 3,
                    ["y"] = 3,
                },
                ["thickness"] = 0.33,
            },
            ["skirt"] = {
                ["sourceOffsetX"] = -1.5,
                ["sourceOffsetZ"] = -1.5,
                ["x"] = 8,
                ["y"] = 8,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/URB0202/URB0202_unit.bp",
            ["sourceBlueprintSha256"] = "9f67bda320e5993f0987b1fb11b6c24e2871fc1c925177fb66971b6e6a17afef",
            ["sourceClassBase"] = "unitsDefaultGuard/GuardAirFactory",
            ["sourceId"] = "URB0202",
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceScript"] = "units/URB0202/URB0202_script.lua",
            ["sourceScriptSha256"] = "4dc35d2263f87df996d4f4f797ae2f533184d0cb640b2c8d0c37763e6cafeaff",
            ["sourceVfx"] = {
                ["blinkingLightsImported"] = false,
                ["constructionBeamMaterial"] = "Guard compatibility",
            },
            ["targetId"] = "ugs2512",
            ["upgrade"] = {
                ["clip"] = "AnimUpgrade",
                ["durationSeconds"] = 4.666666507720947,
                ["frames"] = 141,
                ["progressBound"] = true,
            },
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
                    ["y"] = -3.319995,
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
                ["matchingEngineer"] = "ugl2501",
                ["minimumOutDistance"] = 3.019457,
                ["reservationHalfWidth"] = 0.382454,
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
                    ["headingDegrees"] = -97.253138,
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
                    ["headingDegrees"] = 97.253138,
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
                        ["y"] = 1.620578,
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
                        ["y"] = 1.570032,
                        ["z"] = -3e-06,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 222,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uga2502"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 1.570032,
                        ["z"] = -3e-06,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 222,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uga5001"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 1.863398,
                        ["z"] = -3e-06,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 222,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uga5002"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 1.595688,
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
                        ["y"] = 1.58801,
                        ["z"] = -3e-06,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 222,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
            },
            ["sourceId"] = "URB0202",
            ["targetId"] = "ugs2512",
            ["version"] = 1,
        },
        ["scoFactoryEngineerEgress"] = {
            ["canBuild"] = "(Tags.GUARD * Tags.BUILDABLE_BY_T2_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)) + (Tags.ugl1501 + Tags.ugl2501)",
            ["className"] = {
                [1] = "unitsDefaultGuard",
                [2] = "GuardFaCybranAirFactory",
            },
            ["engineers"] = {
                [1] = "ugl1501",
                [2] = "ugl2501",
            },
            ["faction"] = "GUARD",
            ["originalCanBuild"] = "Tags.GUARD * Tags.BUILDABLE_BY_T2_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)",
            ["platformBoneName"] = "Build_Point",
            ["platformEvidence"] = {
                ["bone"] = "Build_Point",
                ["path"] = "Units/ugs2512/LOD0/ugs2512.sanskeleton",
                ["sha256"] = "e857a21b439b1645f89bc80cc7adab352db899243d06d29a09a78d1b36ddd4fb",
            },
            ["sourceBlueprint"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 9498,
                ["entry"] = "units/URB0202/URB0202_unit.bp",
                ["sha256"] = "9f67bda320e5993f0987b1fb11b6c24e2871fc1c925177fb66971b6e6a17afef",
            },
            ["sourceBuildableCategories"] = {
                [1] = "BUILTBYTIER2FACTORY CYBRAN MOBILE CONSTRUCTION",
                [2] = "BUILTBYTIER2FACTORY CYBRAN STRUCTURE AIR",
                [3] = "BUILTBYTIER2FACTORY CYBRAN MOBILE AIR",
                [4] = "TRANSPORTBUILTBYTIER2FACTORY CYBRAN MOBILE AIR",
            },
            ["sourceId"] = "URB0202",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 697,
                ["entry"] = "units/URB0202/URB0202_script.lua",
                ["sha256"] = "4dc35d2263f87df996d4f4f797ae2f533184d0cb640b2c8d0c37763e6cafeaff",
            },
            ["standardEngineers"] = {
                [1] = "ugl1501",
                [2] = "ugl2501",
            },
            ["targetId"] = "ugs2512",
            ["tier"] = 2,
            ["upgradesTo"] = "ugs3512",
            ["version"] = 1,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3,
                ["y"] = 3,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 12.8,
            ["y"] = 12.8,
        },
    },
    ["audio"] = {
        ["active"] = {
            ["looping"] = true,
            ["name"] = "aglu2520",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 3.5,
            ["y"] = 0.75,
            ["z"] = 3.5,
        },
    },
    ["construction"] = {
        ["buildPower"] = 40,
        ["canBuild"] = "((Tags.GUARD * Tags.BUILDABLE_BY_T2_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)) + (Tags.ugl1501 + Tags.ugl2501)) * Tags.SCFA_ALLUNITS",
        ["platformBoneName"] = "Build_Point",
        ["rollOffPoints"] = {
            [1] = {
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 5,
                    ["z"] = 4,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = 0,
            },
            [2] = {
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 5,
                    ["z"] = -4,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = 180,
            },
        },
        ["upgradesTo"] = "ugs3512",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 7800,
            ["regen"] = 0,
            ["value"] = 7800,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1800,
        ["cost"] = {
            ["alloys"] = 630,
            ["energy"] = 11700,
        },
        ["storage"] = {
            ["alloys"] = 160,
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
        ["displayName"] = "Tier 2: FA Cybran Air Factory",
        ["icon"] = {
            ["shape"] = "structure2",
            ["symbol"] = "air",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure2_air.png",
        ["iconUIBuildSortPriority"] = 390,
        ["iconUIType"] = "air",
        ["name"] = "Air Factory",
        ["orders"] = {
            ["Assist"] = true,
            ["Pause"] = false,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["RepeatBuild"] = true,
        },
        ["tpId"] = "ugs2512",
        ["unitTypeName"] = "GuardT2LandFactory",
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
        [1] = "AIR_FACTORY",
        [2] = "BUILDABLE_BY_T1_FACTORY",
        [3] = "BUILDABLE_BY_T2_ENGINEER",
        [4] = "BUILDABLE_BY_T3_ENGINEER",
        [5] = "CONSTRUCTION",
        [6] = "FACTORY",
        [7] = "GUARD",
        [8] = "LAND",
        [9] = "STRUCTURE",
        [10] = "TECH2",
        [11] = "SCFA_AIR",
        [12] = "SCFA_ALLUNITS",
        [13] = "SCFA_BUILTBYTIER1FACTORY",
        [14] = "SCFA_CONSTRUCTION",
        [15] = "SCFA_CONSTRUCTIONSORTDOWN",
        [16] = "SCFA_CYBRAN",
        [17] = "SCFA_DRAGBUILD",
        [18] = "SCFA_FACTORY",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RALLYPOINT",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_SELECTABLE",
        [23] = "SCFA_SHOWQUEUE",
        [24] = "SCFA_SIZE16",
        [25] = "SCFA_SORTCONSTRUCTION",
        [26] = "SCFA_STRUCTURE",
        [27] = "SCFA_TECH2",
        [28] = "SCFA_VISIBLETORECON",
    },
    ["transport"] = {
        ["storage"] = 25,
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimBuild",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ugs2512/LOD0/ugs2512.sananimation",
            },
            ["platform"] = {
                ["clipName"] = "AnimPlatform",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs2512/LOD0/ugs2512.sananimation",
            },
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs2512/LOD0/ugs2512.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs2512/LOD0/ugs2512.sananimation",
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
                    ["y"] = 0.1875,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.77,
                    ["y"] = 0.135,
                    ["z"] = 0.63,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.7000000000000001,
                    ["y"] = 0.21000000000000002,
                    ["z"] = 0.56,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.63,
                    ["y"] = 0.315,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.77,
                    ["y"] = 0.30000000000000004,
                    ["z"] = 0.63,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 272,
            ["lod1distance"] = 709,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3,
                ["y"] = 3,
            },
        },
    },
}
