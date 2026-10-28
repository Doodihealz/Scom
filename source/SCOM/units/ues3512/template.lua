-- ues3512: Tier 3: FA UEF Air Factory
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
        ["faAirFactoryLifecycle"] = {
            ["animationOwner"] = "host Engine.PlayAnimation sentinel sampler",
            ["buildDurationSeconds"] = 1,
            ["buildSampleSeconds"] = 0.1,
            ["platformBoneName"] = "Attachpoint",
            ["returnSeconds"] = 0.125,
        },
        ["faSourceContract"] = {
            ["build"] = {
                ["clip"] = "AnimBuild",
                ["durationSeconds"] = 1,
                ["frames"] = 31,
                ["loops"] = true,
                ["pauses"] = true,
                ["source"] = "procedural UEB0302 sliders",
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
                ["durationSeconds"] = 2.3333332538604736,
                ["frames"] = 71,
                ["reachableForAirProduction"] = false,
                ["reason"] = "FA gates this clip to LAND while this factory builds AIR",
                ["sourceEvent"] = "AnimationFinishBuildLand",
            },
            ["proceduralArms"] = {
                ["Arm01"] = {
                    ["goalY"] = -5,
                    ["speed"] = 20,
                },
                ["Arm02"] = {
                    ["alternatesDirection"] = true,
                    ["goalY"] = 2,
                    ["speed"] = 10,
                },
                ["Arm03"] = {
                    ["goalY"] = 5,
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
            ["sourceBlueprint"] = "units/UEB0302/UEB0302_unit.bp",
            ["sourceBlueprintSha256"] = "213ba2a3d9aac7127d7f4aeb8345eef367dfd298e3d078954a20a71fa666d2d7",
            ["sourceClassBase"] = "unitsDefaultEDA/EDAAirFactory",
            ["sourceId"] = "UEB0302",
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceScript"] = "units/UEB0302/UEB0302_script.lua",
            ["sourceScriptSha256"] = "4413a4f0f2498b9ed1e93fd35838173a3fd5e8a16b15cca2321acb72e697a6cc",
            ["sourceVfx"] = {
                ["blinkingLightsImported"] = false,
                ["constructionBeamMaterial"] = "EDA compatibility",
            },
            ["targetId"] = "ues3512",
        },
        ["scoFactoryEgress"] = {
            ["bounds"] = {
                ["max"] = {
                    ["x"] = 2.59543,
                    ["y"] = 5.385567,
                    ["z"] = 2.937128,
                },
                ["min"] = {
                    ["x"] = -2.506685,
                    ["y"] = -1.02993,
                    ["z"] = -2.499907,
                },
            },
            ["buildBone"] = "Attachpoint",
            ["buildOffset"] = {
                ["x"] = 0,
                ["y"] = 0.960026,
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
                ["matchingEngineer"] = "uel3501",
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
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.03333333507180214,
                        },
                        [3] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.06666667014360428,
                        },
                        [4] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.10000000149011612,
                        },
                        [5] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.13333334028720856,
                        },
                        [6] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.1666666716337204,
                        },
                        [7] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.20000000298023224,
                        },
                        [8] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.23333333432674408,
                        },
                        [9] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.2666666805744171,
                        },
                        [10] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.30000001192092896,
                        },
                        [11] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.3333333432674408,
                        },
                        [12] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.36666667461395264,
                        },
                        [13] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.4000000059604645,
                        },
                        [14] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.4333333373069763,
                        },
                        [15] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.46666666865348816,
                        },
                        [16] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.5,
                        },
                        [17] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.5333333611488342,
                        },
                        [18] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.5666666626930237,
                        },
                        [19] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.6000000238418579,
                        },
                        [20] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.6333333253860474,
                        },
                        [21] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.6666666865348816,
                        },
                        [22] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.699999988079071,
                        },
                        [23] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.7333333492279053,
                        },
                        [24] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.7666666507720947,
                        },
                        [25] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.800000011920929,
                        },
                        [26] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.8333333134651184,
                        },
                        [27] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.8666666746139526,
                        },
                        [28] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.8999999761581421,
                        },
                        [29] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.9333333373069763,
                        },
                        [30] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 0.9666666388511658,
                        },
                        [31] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1,
                        },
                        [32] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.0333333015441895,
                        },
                        [33] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.0666667222976685,
                        },
                        [34] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.100000023841858,
                        },
                        [35] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.1333333253860474,
                        },
                        [36] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.1666666269302368,
                        },
                        [37] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.2000000476837158,
                        },
                        [38] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.2333333492279053,
                        },
                        [39] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.2666666507720947,
                        },
                        [40] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.2999999523162842,
                        },
                        [41] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.3333333730697632,
                        },
                        [42] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.3666666746139526,
                        },
                        [43] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.399999976158142,
                        },
                        [44] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.4333332777023315,
                        },
                        [45] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.4666666984558105,
                        },
                        [46] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.5,
                        },
                        [47] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.5333333015441895,
                        },
                        [48] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.5666667222976685,
                        },
                        [49] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.600000023841858,
                        },
                        [50] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.6333333253860474,
                        },
                        [51] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.6666666269302368,
                        },
                        [52] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.7000000476837158,
                        },
                        [53] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.7333333492279053,
                        },
                        [54] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.7666666507720947,
                        },
                        [55] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.7999999523162842,
                        },
                        [56] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.96,
                                ["z"] = 0,
                            },
                            ["time"] = 1.8333333730697632,
                        },
                        [57] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.909119,
                                ["z"] = 0,
                            },
                            ["time"] = 1.8666666746139526,
                        },
                        [58] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.858238,
                                ["z"] = 0,
                            },
                            ["time"] = 1.899999976158142,
                        },
                        [59] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.807357,
                                ["z"] = 0,
                            },
                            ["time"] = 1.9333332777023315,
                        },
                        [60] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.756475,
                                ["z"] = 0,
                            },
                            ["time"] = 1.9666666984558105,
                        },
                        [61] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.705594,
                                ["z"] = 0,
                            },
                            ["time"] = 2,
                        },
                        [62] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.654713,
                                ["z"] = 0,
                            },
                            ["time"] = 2.0333333015441895,
                        },
                        [63] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.603832,
                                ["z"] = 0,
                            },
                            ["time"] = 2.066666603088379,
                        },
                        [64] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.55295,
                                ["z"] = 0,
                            },
                            ["time"] = 2.0999999046325684,
                        },
                        [65] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.502069,
                                ["z"] = 0,
                            },
                            ["time"] = 2.133333444595337,
                        },
                        [66] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.451188,
                                ["z"] = 0,
                            },
                            ["time"] = 2.1666667461395264,
                        },
                        [67] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.400307,
                                ["z"] = 0,
                            },
                            ["time"] = 2.200000047683716,
                        },
                        [68] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.349426,
                                ["z"] = 0,
                            },
                            ["time"] = 2.2333333492279053,
                        },
                        [69] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.298544,
                                ["z"] = 0,
                            },
                            ["time"] = 2.2666666507720947,
                        },
                        [70] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.247663,
                                ["z"] = 0,
                            },
                            ["time"] = 2.299999952316284,
                        },
                        [71] = {
                            ["position"] = {
                                ["x"] = 0,
                                ["y"] = 0.196782,
                                ["z"] = 0,
                            },
                            ["time"] = 2.3333332538604736,
                        },
                    },
                    ["clipName"] = "AnimPlatform",
                    ["duration"] = 2.3333332538604736,
                    ["holdFromConstructionStart"] = true,
                    ["time"] = 0,
                },
                ["reason"] = "Build on raised Attachpoint, then sample the compiled platform and product together before outward release.",
                ["reservationHalfWidth"] = 0.700344,
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
                            ["y"] = 0.960026,
                            ["z"] = -3,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = 0,
                            ["y"] = 0.960026,
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
                            ["y"] = 0.960026,
                            ["z"] = 0,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = -6,
                            ["y"] = 0.960026,
                            ["z"] = 0,
                        },
                    },
                },
            },
            ["productOverrides"] = {
                ["uea2011"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 2.402243,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 32,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uea3001"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 2.716869,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 32,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uea3011"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 3.501084,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 32,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uea3701"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 2.718681,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 32,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uea5003"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 5.988556,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 32,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uea5004"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 5.411807,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 32,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uea5005"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 2.330973,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 32,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uea5008"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 2.401073,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 32,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uea5010"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 5.407104,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 32,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
            },
            ["sourceId"] = "UEB0302",
            ["targetId"] = "ues3512",
            ["version"] = 1,
        },
        ["scoFactoryEngineerEgress"] = {
            ["canBuild"] = "Tags.EDA * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)",
            ["className"] = {
                [1] = "unitsDefaultEDA",
                [2] = "EDAFaUefAirFactory",
            },
            ["engineers"] = {
                [1] = "uel1501",
                [2] = "uel2501",
                [3] = "uel3501",
                [4] = "uel5010",
            },
            ["faction"] = "EDA",
            ["originalCanBuild"] = "Tags.EDA * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)",
            ["platformBoneName"] = "Attachpoint",
            ["platformEvidence"] = {
                ["bone"] = "Attachpoint",
                ["path"] = "Units/ues3512/LOD0/ues3512.sanskeleton",
                ["sha256"] = "e57b0a2ec9401715663501f0c2f76e3cb65a6ba3cd7748aa0171dea017693e93",
            },
            ["sourceBlueprint"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 8935,
                ["entry"] = "units/UEB0302/UEB0302_unit.bp",
                ["sha256"] = "213ba2a3d9aac7127d7f4aeb8345eef367dfd298e3d078954a20a71fa666d2d7",
            },
            ["sourceBuildableCategories"] = {
                [1] = "BUILTBYTIER3FACTORY UEF MOBILE CONSTRUCTION",
                [2] = "BUILTBYTIER3FACTORY UEF STRUCTURE AIR",
                [3] = "BUILTBYTIER3FACTORY UEF MOBILE AIR",
                [4] = "TRANSPORTBUILTBYTIER3FACTORY UEF MOBILE AIR",
            },
            ["sourceId"] = "UEB0302",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 2385,
                ["entry"] = "units/UEB0302/UEB0302_script.lua",
                ["sha256"] = "4413a4f0f2498b9ed1e93fd35838173a3fd5e8a16b15cca2321acb72e697a6cc",
            },
            ["standardEngineers"] = {
                [1] = "uel1501",
                [2] = "uel2501",
                [3] = "uel3501",
            },
            ["targetId"] = "ues3512",
            ["tier"] = 3,
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
        ["buildPower"] = 60,
        ["canBuild"] = "(Tags.EDA * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)) * Tags.SCFA_ALLUNITS",
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
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 22000,
            ["regen"] = 0,
            ["value"] = 22000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 8400,
        ["cost"] = {
            ["alloys"] = 3150,
            ["energy"] = 105000,
        },
        ["storage"] = {
            ["alloys"] = 320,
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
        ["displayName"] = "Tier 3: FA UEF Air Factory",
        ["icon"] = {
            ["shape"] = "structure2",
            ["symbol"] = "air",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure2_air.png",
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
        ["tpId"] = "ues3512",
        ["unitTypeName"] = "EDAT3LandFactory",
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
        [2] = "BUILDABLE_BY_T2_FACTORY",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "CONSTRUCTION",
        [5] = "EDA",
        [6] = "ENERGY_STORAGE",
        [7] = "FACTORY",
        [8] = "LAND",
        [9] = "STRUCTURE",
        [10] = "TECH3",
        [11] = "SCFA_AIR",
        [12] = "SCFA_ALLUNITS",
        [13] = "SCFA_BUILTBYTIER2FACTORY",
        [14] = "SCFA_CONSTRUCTION",
        [15] = "SCFA_CONSTRUCTIONSORTDOWN",
        [16] = "SCFA_DRAGBUILD",
        [17] = "SCFA_FACTORY",
        [18] = "SCFA_PRODUCTSC1",
        [19] = "SCFA_RALLYPOINT",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SHOWQUEUE",
        [23] = "SCFA_SIZE16",
        [24] = "SCFA_SORTCONSTRUCTION",
        [25] = "SCFA_STRUCTURE",
        [26] = "SCFA_TECH3",
        [27] = "SCFA_UEF",
        [28] = "SCFA_VISIBLETORECON",
    },
    ["transport"] = {
        ["storage"] = 40,
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimBuild",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ues3512/LOD0/ues3512.sananimation",
            },
            ["platform"] = {
                ["clipName"] = "AnimPlatform",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues3512/LOD0/ues3512.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues3512/LOD0/ues3512.sananimation",
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
