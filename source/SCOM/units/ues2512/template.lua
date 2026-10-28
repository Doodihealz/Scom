-- ues2512: Tier 2: FA UEF Air Factory
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Muzzle01",
            [2] = "Muzzle02",
        },
        ["faAirFactoryLifecycle"] = {
            ["animationOwner"] = "host Engine.PlayAnimation sentinel sampler",
            ["buildDurationSeconds"] = 0.6,
            ["buildSampleSeconds"] = 0.1,
            ["platformBoneName"] = "Attachpoint",
            ["returnSeconds"] = 0.15,
        },
        ["faSourceContract"] = {
            ["build"] = {
                ["clip"] = "AnimBuild",
                ["durationSeconds"] = 0.6,
                ["frames"] = 19,
                ["loops"] = true,
                ["pauses"] = true,
                ["source"] = "procedural UEB0202 sliders",
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
                ["durationSeconds"] = 0.5,
                ["frames"] = 16,
                ["reachableForAirProduction"] = false,
                ["reason"] = "FA gates this clip to LAND while this factory builds AIR",
                ["sourceEvent"] = "AnimationFinishBuildLand",
            },
            ["proceduralArms"] = {
                ["Arm01"] = {
                    ["goalY"] = -6,
                    ["speed"] = 20,
                },
                ["Arm02"] = {
                    ["goalY"] = 6,
                    ["speed"] = 20,
                },
                ["sourceScale"] = 0.1,
                ["stopSpeed"] = 40,
            },
            ["runtimeClass"] = "unitsDefaultEDA/EDAFaUefAirFactory",
            ["selection"] = {
                ["size"] = {
                    ["x"] = 3.2,
                    ["y"] = 3.1,
                },
                ["thickness"] = 0.3,
            },
            ["skirt"] = {
                ["sourceOffsetX"] = -1.5,
                ["sourceOffsetZ"] = -1.5,
                ["x"] = 8,
                ["y"] = 8,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEB0202/UEB0202_unit.bp",
            ["sourceBlueprintSha256"] = "a548f94be1a5e5ef2022eb13d002aa3ead9a08be7d5124c93032416382490121",
            ["sourceClassBase"] = "unitsDefaultEDA/EDAAirFactory",
            ["sourceId"] = "UEB0202",
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceScript"] = "units/UEB0202/UEB0202_script.lua",
            ["sourceScriptSha256"] = "ca090b1f981299ce5f3624f8565a4fced7488d57e2bdccba152147c9a963072c",
            ["sourceVfx"] = {
                ["blinkingLightsImported"] = false,
                ["constructionBeamMaterial"] = "EDA compatibility",
            },
            ["targetId"] = "ues2512",
            ["upgrade"] = {
                ["clip"] = "AnimUpgrade",
                ["durationSeconds"] = 6.666666507720947,
                ["frames"] = 201,
                ["progressBound"] = true,
            },
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
                    ["y"] = 4.859542,
                    ["z"] = 2.937128,
                },
                ["min"] = {
                    ["x"] = -2.506685,
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
                ["matchingEngineer"] = "uel2501",
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
                                ["y"] = 0.90912,
                                ["z"] = 0,
                            },
                            ["time"] = 0.03333333507180214,
                        },
                        [3] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.858241,
                                ["z"] = 0,
                            },
                            ["time"] = 0.06666667014360428,
                        },
                        [4] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.807362,
                                ["z"] = 0,
                            },
                            ["time"] = 0.10000000149011612,
                        },
                        [5] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.756482,
                                ["z"] = 0,
                            },
                            ["time"] = 0.13333334028720856,
                        },
                        [6] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.705602,
                                ["z"] = 0,
                            },
                            ["time"] = 0.1666666716337204,
                        },
                        [7] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.654723,
                                ["z"] = 0,
                            },
                            ["time"] = 0.20000000298023224,
                        },
                        [8] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.603843,
                                ["z"] = 0,
                            },
                            ["time"] = 0.23333333432674408,
                        },
                        [9] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.552964,
                                ["z"] = 0,
                            },
                            ["time"] = 0.2666666805744171,
                        },
                        [10] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.502084,
                                ["z"] = 0,
                            },
                            ["time"] = 0.30000001192092896,
                        },
                        [11] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.451205,
                                ["z"] = 0,
                            },
                            ["time"] = 0.3333333432674408,
                        },
                        [12] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.400325,
                                ["z"] = 0,
                            },
                            ["time"] = 0.36666667461395264,
                        },
                        [13] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.349446,
                                ["z"] = 0,
                            },
                            ["time"] = 0.4000000059604645,
                        },
                        [14] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.298566,
                                ["z"] = 0,
                            },
                            ["time"] = 0.4333333373069763,
                        },
                        [15] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.247687,
                                ["z"] = 0,
                            },
                            ["time"] = 0.46666666865348816,
                        },
                        [16] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.196807,
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
                ["reservationHalfWidth"] = 0.560275,
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
                    ["headingDegrees"] = -90.000001,
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
                ["uea2011"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 2.542691,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 20,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uea5003"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 5.462531,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 20,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uea5004"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 4.885783,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 20,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
            },
            ["sourceId"] = "UEB0202",
            ["targetId"] = "ues2512",
            ["version"] = 1,
        },
        ["scoFactoryEngineerEgress"] = {
            ["canBuild"] = "Tags.EDA * Tags.BUILDABLE_BY_T2_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)",
            ["className"] = {
                [1] = "unitsDefaultEDA",
                [2] = "EDAFaUefAirFactory",
            },
            ["engineers"] = {
                [1] = "uel1501",
                [2] = "uel2501",
                [3] = "uel5010",
            },
            ["faction"] = "EDA",
            ["originalCanBuild"] = "Tags.EDA * Tags.BUILDABLE_BY_T2_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)",
            ["platformBoneName"] = "Attachpoint",
            ["platformEvidence"] = {
                ["bone"] = "Attachpoint",
                ["path"] = "Units/ues2512/LOD0/ues2512.sanskeleton",
                ["sha256"] = "74d0e42920fd91a839210a1eb2e259cbb8e7b3c0ef41e7ce022e52ffb2ebdae1",
            },
            ["sourceBlueprint"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 9052,
                ["entry"] = "units/UEB0202/UEB0202_unit.bp",
                ["sha256"] = "a548f94be1a5e5ef2022eb13d002aa3ead9a08be7d5124c93032416382490121",
            },
            ["sourceBuildableCategories"] = {
                [1] = "BUILTBYTIER2FACTORY UEF MOBILE CONSTRUCTION",
                [2] = "BUILTBYTIER2FACTORY UEF STRUCTURE AIR",
                [3] = "BUILTBYTIER2FACTORY UEF MOBILE AIR",
                [4] = "TRANSPORTBUILTBYTIER2FACTORY UEF MOBILE AIR",
            },
            ["sourceId"] = "UEB0202",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1878,
                ["entry"] = "units/UEB0202/UEB0202_script.lua",
                ["sha256"] = "ca090b1f981299ce5f3624f8565a4fced7488d57e2bdccba152147c9a963072c",
            },
            ["standardEngineers"] = {
                [1] = "uel1501",
                [2] = "uel2501",
            },
            ["targetId"] = "ues2512",
            ["tier"] = 2,
            ["upgradesTo"] = "ues3512",
            ["version"] = 1,
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3.2,
                ["y"] = 3.1,
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
            ["name"] = "aelu2520",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2120",
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
        ["canBuild"] = "(Tags.EDA * Tags.BUILDABLE_BY_T2_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)) * Tags.SCFA_ALLUNITS",
        ["platformBoneName"] = "Attachpoint",
        ["rollOffPoints"] = {
            [1] = {
                ["offset"] = {
                    ["x"] = -5,
                    ["y"] = 5,
                    ["z"] = 0,
                },
                ["platformOffset"] = {
                    ["x"] = -2,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = -90,
            },
            [2] = {
                ["offset"] = {
                    ["x"] = 5,
                    ["y"] = 5,
                    ["z"] = 0,
                },
                ["platformOffset"] = {
                    ["x"] = 2,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = 90,
            },
        },
        ["upgradesTo"] = "ues3512",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 9000,
            ["regen"] = 0,
            ["value"] = 9000,
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
            [1] = "unitsDefaultEDA",
            [2] = "EDAFaUefAirFactory",
        },
        ["displayName"] = "Tier 2: FA UEF Air Factory",
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
        ["tpId"] = "ues2512",
        ["unitTypeName"] = "EDAT2LandFactory",
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
        [6] = "EDA",
        [7] = "ENERGY_STORAGE",
        [8] = "FACTORY",
        [9] = "LAND",
        [10] = "STRUCTURE",
        [11] = "TECH2",
        [12] = "SCFA_AIR",
        [13] = "SCFA_ALLUNITS",
        [14] = "SCFA_BUILTBYTIER1FACTORY",
        [15] = "SCFA_CONSTRUCTION",
        [16] = "SCFA_CONSTRUCTIONSORTDOWN",
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
        [28] = "SCFA_UEF",
        [29] = "SCFA_VISIBLETORECON",
    },
    ["transport"] = {
        ["storage"] = 25,
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimBuild",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ues2512/LOD0/ues2512.sananimation",
            },
            ["platform"] = {
                ["clipName"] = "AnimPlatform",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues2512/LOD0/ues2512.sananimation",
            },
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues2512/LOD0/ues2512.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues2512/LOD0/ues2512.sananimation",
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
                ["x"] = 3.2,
                ["y"] = 3.1,
            },
        },
    },
}
