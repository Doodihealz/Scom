-- ugs3512: Tier 3: FA Cybran Air Factory
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
            [5] = "Arm05_Muzzle",
            [6] = "Arm06_Muzzle",
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
                ["source"] = "units/URB0302/URB0302_Abuild.sca",
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
            ["sourceBlueprint"] = "units/URB0302/URB0302_unit.bp",
            ["sourceBlueprintSha256"] = "e9aa49c6eed7fafde2fb543cb853e2ed8b53c10924481539d224d925c4bacae3",
            ["sourceClassBase"] = "unitsDefaultGuard/GuardAirFactory",
            ["sourceId"] = "URB0302",
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceScript"] = "units/URB0302/URB0302_script.lua",
            ["sourceScriptSha256"] = "6983ea728f70d1195d67e4688bb84a8100fcce0e90daff60304aeac69e2843e2",
            ["sourceVfx"] = {
                ["blinkingLightsImported"] = false,
                ["constructionBeamMaterial"] = "Guard compatibility",
            },
            ["targetId"] = "ugs3512",
        },
        ["scoFactoryEgress"] = {
            ["bounds"] = {
                ["max"] = {
                    ["x"] = 3.019457,
                    ["y"] = 3.943222,
                    ["z"] = 3.213343,
                },
                ["min"] = {
                    ["x"] = -3.019453,
                    ["y"] = -2.427224,
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
                ["matchingEngineer"] = "ugl3501",
                ["minimumOutDistance"] = 3.019457,
                ["reservationHalfWidth"] = 0.491264,
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
                        ["y"] = 1.620547,
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
                        ["y"] = 1.570001,
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
                        ["y"] = 1.570001,
                        ["z"] = -3e-06,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 222,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uga3001"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 1.564211,
                        ["z"] = -3e-06,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 222,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uga3201"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 1.571775,
                        ["z"] = -3e-06,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 222,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uga3701"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 1.576301,
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
                        ["y"] = 1.863366,
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
                        ["y"] = 1.595656,
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
                        ["y"] = 1.587978,
                        ["z"] = -3e-06,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 222,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uga5005"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 1.576321,
                        ["z"] = -3e-06,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 222,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
            },
            ["sourceId"] = "URB0302",
            ["targetId"] = "ugs3512",
            ["version"] = 1,
        },
        ["scoFactoryEngineerEgress"] = {
            ["canBuild"] = "(Tags.GUARD * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)) + (Tags.ugl1501 + Tags.ugl2501 + Tags.ugl3501)",
            ["className"] = {
                [1] = "unitsDefaultGuard",
                [2] = "GuardFaCybranAirFactory",
            },
            ["engineers"] = {
                [1] = "ugl1501",
                [2] = "ugl2501",
                [3] = "ugl3501",
            },
            ["faction"] = "GUARD",
            ["originalCanBuild"] = "Tags.GUARD * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)",
            ["platformBoneName"] = "Build_Point",
            ["platformEvidence"] = {
                ["bone"] = "Build_Point",
                ["path"] = "Units/ugs3512/LOD0/ugs3512.sanskeleton",
                ["sha256"] = "d4105700d75afa5fcbe7e5c31d32f699b6e319efc128f61aa531c4fa3723a8ec",
            },
            ["sourceBlueprint"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 9399,
                ["entry"] = "units/URB0302/URB0302_unit.bp",
                ["sha256"] = "e9aa49c6eed7fafde2fb543cb853e2ed8b53c10924481539d224d925c4bacae3",
            },
            ["sourceBuildableCategories"] = {
                [1] = "BUILTBYTIER3FACTORY CYBRAN MOBILE CONSTRUCTION",
                [2] = "BUILTBYTIER3FACTORY CYBRAN STRUCTURE AIR",
                [3] = "BUILTBYTIER3FACTORY CYBRAN MOBILE AIR",
                [4] = "TRANSPORTBUILTBYTIER3FACTORY CYBRAN MOBILE AIR",
            },
            ["sourceId"] = "URB0302",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 551,
                ["entry"] = "units/URB0302/URB0302_script.lua",
                ["sha256"] = "6983ea728f70d1195d67e4688bb84a8100fcce0e90daff60304aeac69e2843e2",
            },
            ["standardEngineers"] = {
                [1] = "ugl1501",
                [2] = "ugl2501",
                [3] = "ugl3501",
            },
            ["targetId"] = "ugs3512",
            ["tier"] = 3,
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
        ["buildPower"] = 60,
        ["canBuild"] = "((Tags.GUARD * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)) + (Tags.ugl1501 + Tags.ugl2501 + Tags.ugl3501)) * Tags.SCFA_ALLUNITS",
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
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 19000,
            ["regen"] = 0,
            ["value"] = 19000,
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
            [1] = "unitsDefaultGuard",
            [2] = "GuardFaCybranAirFactory",
        },
        ["displayName"] = "Tier 3: FA Cybran Air Factory",
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
        ["tpId"] = "ugs3512",
        ["unitTypeName"] = "GuardT3LandFactory",
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
        [5] = "FACTORY",
        [6] = "GUARD",
        [7] = "LAND",
        [8] = "STRUCTURE",
        [9] = "TECH3",
        [10] = "SCFA_AIR",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYTIER2FACTORY",
        [13] = "SCFA_CONSTRUCTION",
        [14] = "SCFA_CONSTRUCTIONSORTDOWN",
        [15] = "SCFA_CYBRAN",
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
        [27] = "SCFA_VISIBLETORECON",
    },
    ["transport"] = {
        ["storage"] = 40,
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimBuild",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ugs3512/LOD0/ugs3512.sananimation",
            },
            ["platform"] = {
                ["clipName"] = "AnimPlatform",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs3512/LOD0/ugs3512.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs3512/LOD0/ugs3512.sananimation",
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
