-- ucs3512: Air Factory
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Turret_Muzzle_01",
            [2] = "Turret_Muzzle_02",
            [3] = "Turret_Muzzle_03",
        },
        ["buildBeamEffectName"] = "beam1",
        ["buildStagingBoneName"] = "Attachpoint",
        ["buildStagingModelSha256"] = "92765eb9e27a5e10f190fd79d4c26207bf6626fb42860f7d3b683604c9c8f9de",
        ["buildStagingOffset"] = {
            ["x"] = 0.0002561488072387874,
            ["y"] = 0.6849361062049866,
            ["z"] = 5.91340649407357e-05,
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 20,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 5,
                    ["z"] = 5,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirt"] = {
                    ["offsetX"] = -1.5,
                    ["offsetZ"] = -1.5,
                    ["sizeX"] = 8,
                    ["sizeZ"] = 8,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB0302/UAB0302_unit.bp",
            ["sourceBlueprintSha256"] = "d475f08ab1fc0434b548f6f2959c808750615bfb2dc9f7dc1dd25bf8f336abfd",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "AIR",
                [3] = "BUILTBYTIER2FACTORY",
                [4] = "CONSTRUCTION",
                [5] = "CONSTRUCTIONSORTDOWN",
                [6] = "DRAGBUILD",
                [7] = "FACTORY",
                [8] = "PRODUCTSC1",
                [9] = "RALLYPOINT",
                [10] = "RECLAIMABLE",
                [11] = "SELECTABLE",
                [12] = "SHOWQUEUE",
                [13] = "SIZE16",
                [14] = "SORTCONSTRUCTION",
                [15] = "STRUCTURE",
                [16] = "TECH3",
                [17] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB0302",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "UAB0202",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs3512",
            ["weapons"] = {},
        },
        ["multiConstructionBeam"] = {
            ["materialPath"] = "VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial",
            ["prefabName"] = "SCOM.AeonFactoryBeam",
            ["shrink"] = 0.05,
        },
        ["rollOffRamps"] = {
            [1] = {
                ["clearanceOffset"] = {
                    ["x"] = -6,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["headingDegrees"] = -90,
                ["rampOffset"] = {
                    ["x"] = -3,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
            [2] = {
                ["clearanceOffset"] = {
                    ["x"] = 6,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["headingDegrees"] = 90,
                ["rampOffset"] = {
                    ["x"] = 3,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        ["rollOffSurfacePolicy"] = "factory",
        ["scoFactoryEgress"] = {
            ["bounds"] = {
                ["max"] = {
                    ["x"] = 2.557373,
                    ["y"] = 4.017887,
                    ["z"] = 2.458285,
                },
                ["min"] = {
                    ["x"] = -2.557371,
                    ["y"] = 0.007895,
                    ["z"] = -2.357563,
                },
            },
            ["buildBone"] = "Attachpoint",
            ["buildOffset"] = {
                ["x"] = 0.000256,
                ["y"] = 0.684936,
                ["z"] = 5.9e-05,
            },
            ["domain"] = "air",
            ["engineerRoute"] = {
                ["buildBottomClearance"] = 0.687436,
                ["direction"] = {
                    ["x"] = 1,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["distanceRule"] = "max(sourceOutDistance, minimumOutDistance + child projected rear extent + required clearance margin)",
                ["extendByChildExtent"] = true,
                ["landingMode"] = "terrain-and-product-preferred-altitude-after-horizontal-clearance",
                ["matchingEngineer"] = "ucl3501",
                ["measuredMinimumOriginY"] = 0.986626,
                ["minimumOutDistance"] = 2.557117,
                ["reservationHalfWidth"] = 0.580512,
                ["sourceDownDistance"] = 2.75,
                ["sourceOutDistance"] = 3,
                ["sourceSpeed"] = 1.5,
                ["staticSweepEvidence"] = "Conservative axis-aligned engineer envelope: UEF platform-end forward; Cybran/Aeon side; Seraphim forward. Full child extent must clear factory envelope before lowering.",
                ["supportMeasurement"] = "Source side corridor triangle/AABB sweep; horizontal radius encloses every engineer yaw. Deck/rim clearance measured at .0025 native-unit steps.",
            },
            ["exitRoutes"] = {
                [1] = {
                    ["direction"] = {
                        ["x"] = -1,
                        ["y"] = 0,
                        ["z"] = -2e-05,
                    },
                    ["extendByChildExtent"] = true,
                    ["headingDegrees"] = -90.001129,
                    ["heightMode"] = "attachment-origin-until-clear-then-native-air-or-water-altitude",
                    ["minimumClearanceDistance"] = 6.000512,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = 90,
                        ["X"] = 3,
                        ["Y"] = 0,
                        ["Z"] = 0,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = -3,
                            ["y"] = 0.684936,
                            ["z"] = 0,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = -6.000256,
                            ["y"] = 0.684936,
                            ["z"] = -5.9e-05,
                        },
                    },
                },
                [2] = {
                    ["direction"] = {
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = -2e-05,
                    },
                    ["extendByChildExtent"] = true,
                    ["headingDegrees"] = 90.001129,
                    ["heightMode"] = "attachment-origin-until-clear-then-native-air-or-water-altitude",
                    ["minimumClearanceDistance"] = 5.999488,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = -90,
                        ["X"] = -3,
                        ["Y"] = 0,
                        ["Z"] = 0,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = 3,
                            ["y"] = 0.684936,
                            ["z"] = 0,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = 5.999744,
                            ["y"] = 0.684936,
                            ["z"] = -5.9e-05,
                        },
                    },
                },
            },
            ["productOverrides"] = {
                ["uca1001"] = {
                    ["buildOffset"] = {
                        ["x"] = 0.000256,
                        ["y"] = 2.391122,
                        ["z"] = 5.9e-05,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 1,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uca1502"] = {
                    ["buildOffset"] = {
                        ["x"] = 0.000256,
                        ["y"] = 1.478273,
                        ["z"] = 5.9e-05,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 1,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uca1701"] = {
                    ["buildOffset"] = {
                        ["x"] = 0.000256,
                        ["y"] = 0.721282,
                        ["z"] = 5.9e-05,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 1,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uca2502"] = {
                    ["buildOffset"] = {
                        ["x"] = 0.000256,
                        ["y"] = 4.530694,
                        ["z"] = 5.9e-05,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 1,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uca2701"] = {
                    ["buildOffset"] = {
                        ["x"] = 0.000256,
                        ["y"] = 2.40404,
                        ["z"] = 5.9e-05,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 1,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uca3001"] = {
                    ["buildOffset"] = {
                        ["x"] = 0.000256,
                        ["y"] = 2.403313,
                        ["z"] = 5.9e-05,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 1,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uca3011"] = {
                    ["buildOffset"] = {
                        ["x"] = 0.000256,
                        ["y"] = 3.504105,
                        ["z"] = 5.9e-05,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 1,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uca3201"] = {
                    ["buildOffset"] = {
                        ["x"] = 0.000256,
                        ["y"] = 1.470481,
                        ["z"] = 5.9e-05,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 1,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
            },
            ["sourceId"] = "UAB0302",
            ["targetId"] = "ucs3512",
            ["version"] = 1,
        },
        ["scoFactoryEngineerEgress"] = {
            ["canBuild"] = "Tags.CHOSEN * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)",
            ["className"] = {
                [1] = "unitsDefaultChosen",
                [2] = "AeonPortAirFactory",
            },
            ["engineers"] = {
                [1] = "ucl1501",
                [2] = "ucl2501",
                [3] = "ucl3501",
            },
            ["faction"] = "CHOSEN",
            ["originalCanBuild"] = "Tags.CHOSEN * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)",
            ["platformBoneName"] = "Attachpoint",
            ["platformEvidence"] = {
                ["bone"] = "Attachpoint",
                ["path"] = "Units/ucs3512/LOD0/ucs3512.sanskeleton",
                ["sha256"] = "1b6e43c44f6b0fe71118b68a59de81dedf72a23751c4051e28d16b6c00f65af6",
            },
            ["sourceBlueprint"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 9264,
                ["entry"] = "units/UAB0302/UAB0302_unit.bp",
                ["sha256"] = "d475f08ab1fc0434b548f6f2959c808750615bfb2dc9f7dc1dd25bf8f336abfd",
            },
            ["sourceBuildableCategories"] = {
                [1] = "BUILTBYTIER3FACTORY AEON MOBILE CONSTRUCTION",
                [2] = "BUILTBYTIER3FACTORY AEON STRUCTURE AIR",
                [3] = "BUILTBYTIER3FACTORY AEON MOBILE AIR",
                [4] = "TRANSPORTBUILTBYTIER3FACTORY AEON MOBILE AIR",
            },
            ["sourceId"] = "UAB0302",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 528,
                ["entry"] = "units/UAB0302/UAB0302_script.lua",
                ["sha256"] = "6767a8beb915bc0c3742fbaac7fa41974bdd1382daa61d5e66531528fc841d54",
            },
            ["standardEngineers"] = {
                [1] = "ucl1501",
                [2] = "ucl2501",
                [3] = "ucl3501",
            },
            ["targetId"] = "ucs3512",
            ["tier"] = 3,
            ["version"] = 1,
        },
        ["scoFieldFixAeonFactoryRouting"] = {
            ["aiVisible"] = true,
            ["role"] = "AIR_FACTORY",
            ["version"] = "1.0.0",
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.35,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.85,
                ["y"] = 2.75,
            },
        },
    },
    ["audio"] = {
        ["active"] = {
            ["looping"] = true,
            ["name"] = "aclu2520",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.35,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 4,
            ["y"] = 0.7,
            ["z"] = 4,
        },
    },
    ["construction"] = {
        ["buildPower"] = 60,
        ["canBuild"] = "(Tags.CHOSEN * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)) * Tags.SCFA_ALLUNITS",
        ["platformBoneName"] = "Attachpoint",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 20000,
            ["regen"] = 0,
            ["value"] = 20000,
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
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortAirFactory",
        },
        ["displayName"] = "Air Factory",
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
        ["tpId"] = "ucs3512",
        ["unitTypeName"] = "Air Factory",
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
        [1] = "AIR",
        [2] = "AIR_FACTORY",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "CHOSEN",
        [6] = "CONSTRUCTION",
        [7] = "FACTORY",
        [8] = "STRUCTURE",
        [9] = "TECH3",
        [10] = "SCFA_AEON",
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
        [27] = "SCFA_VISIBLETORECON",
        [28] = "BUILDABLE_BY_T3_ENGINEER",
    },
    ["transport"] = {
        ["storage"] = 10,
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs3512/LOD0/ucs3512.sananimation",
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
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd2301_death_building_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.72,
                    ["y"] = 0.5249999999999999,
                    ["z"] = -0.8,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.88,
                    ["y"] = 0.476,
                    ["z"] = 0.72,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8,
                    ["y"] = 0.546,
                    ["z"] = 0.64,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.72,
                    ["y"] = 0.6439999999999999,
                    ["z"] = -0.8,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.88,
                    ["y"] = 0.6299999999999999,
                    ["z"] = 0.72,
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
                ["y"] = 0.35,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.85,
                ["y"] = 2.75,
            },
        },
    },
}
