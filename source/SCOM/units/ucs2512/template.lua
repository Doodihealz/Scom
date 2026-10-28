-- ucs2512: Air Factory
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Turret_Muzzle_01",
            [2] = "Turret_Muzzle_02",
        },
        ["buildBeamEffectName"] = "beam1",
        ["buildStagingBoneName"] = "Attachpoint",
        ["buildStagingModelSha256"] = "496b01a3340ca3fe5bb7c1557194dd9e80ea8f640e6303b2126d67784fd67c06",
        ["buildStagingOffset"] = {
            ["x"] = 0,
            ["y"] = 0.7099999785423279,
            ["z"] = 8.733400965301244e-15,
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
            ["sourceBlueprint"] = "units/UAB0202/UAB0202_unit.bp",
            ["sourceBlueprintSha256"] = "24f7d32122abf9346431a991316c66c99e3e93feccc6309411a425d5c645785e",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "AIR",
                [3] = "BUILTBYTIER1FACTORY",
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
                [16] = "TECH2",
                [17] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB0202",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "UAB0102",
            ["sourceUpgradeTo"] = "UAB0302",
            ["targetId"] = "ucs2512",
            ["weapons"] = {},
        },
        ["multiConstructionBeam"] = {
            ["materialPath"] = "VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial",
            ["prefabName"] = "SCOM.AeonFactoryBeam",
            ["shrink"] = 0.05,
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "source_animupgrade",
            ["durationSeconds"] = 4,
            ["restAnimationKey"] = "walk",
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
                    ["x"] = 2.77799,
                    ["y"] = 2.904009,
                    ["z"] = 2.458285,
                },
                ["min"] = {
                    ["x"] = -2.34132,
                    ["y"] = -1.09081,
                    ["z"] = -2.357563,
                },
            },
            ["buildBone"] = "Attachpoint",
            ["buildOffset"] = {
                ["x"] = 0,
                ["y"] = 0.71,
                ["z"] = 0,
            },
            ["domain"] = "air",
            ["engineerRoute"] = {
                ["buildBottomClearance"] = 0.71,
                ["direction"] = {
                    ["x"] = 1,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["distanceRule"] = "max(sourceOutDistance, minimumOutDistance + child projected rear extent + required clearance margin)",
                ["extendByChildExtent"] = true,
                ["landingMode"] = "terrain-and-product-preferred-altitude-after-horizontal-clearance",
                ["matchingEngineer"] = "ucl2501",
                ["measuredMinimumOriginY"] = 1.01013,
                ["minimumOutDistance"] = 2.77799,
                ["reservationHalfWidth"] = 0.550923,
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
                        ["z"] = 0,
                    },
                    ["extendByChildExtent"] = true,
                    ["headingDegrees"] = -90,
                    ["heightMode"] = "attachment-origin-until-clear-then-native-air-or-water-altitude",
                    ["minimumClearanceDistance"] = 6,
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
                            ["y"] = 0.71,
                            ["z"] = 0,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = -6,
                            ["y"] = 0.71,
                            ["z"] = 0,
                        },
                    },
                },
                [2] = {
                    ["direction"] = {
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["extendByChildExtent"] = true,
                    ["headingDegrees"] = 90,
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
                            ["x"] = 3,
                            ["y"] = 0.71,
                            ["z"] = 0,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = 6,
                            ["y"] = 0.71,
                            ["z"] = 0,
                        },
                    },
                },
            },
            ["productOverrides"] = {
                ["uca1001"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 2.465441,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 1,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
                ["uca2502"] = {
                    ["buildOffset"] = {
                        ["x"] = 0,
                        ["y"] = 3.416816,
                        ["z"] = 0,
                    },
                    ["measurement"] = {
                        ["authoredFactoryPoses"] = 1,
                        ["reason"] = "source Rest/build-pose clearance before creation",
                    },
                },
            },
            ["sourceId"] = "UAB0202",
            ["targetId"] = "ucs2512",
            ["version"] = 1,
        },
        ["scoFactoryEngineerEgress"] = {
            ["canBuild"] = "Tags.CHOSEN * Tags.BUILDABLE_BY_T2_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)",
            ["className"] = {
                [1] = "unitsDefaultChosen",
                [2] = "AeonPortAirFactory",
            },
            ["engineers"] = {
                [1] = "ucl1501",
                [2] = "ucl2501",
            },
            ["faction"] = "CHOSEN",
            ["originalCanBuild"] = "Tags.CHOSEN * Tags.BUILDABLE_BY_T2_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)",
            ["platformBoneName"] = "Attachpoint",
            ["platformEvidence"] = {
                ["bone"] = "Attachpoint",
                ["path"] = "Units/ucs2512/LOD0/ucs2512.sanskeleton",
                ["sha256"] = "ce7b04b2b71895c6e5e89c4a400ff2b48a5bbbfa1d7bb5286c4539eb55577948",
            },
            ["sourceBlueprint"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 9238,
                ["entry"] = "units/UAB0202/UAB0202_unit.bp",
                ["sha256"] = "24f7d32122abf9346431a991316c66c99e3e93feccc6309411a425d5c645785e",
            },
            ["sourceBuildableCategories"] = {
                [1] = "BUILTBYTIER2FACTORY AEON MOBILE CONSTRUCTION",
                [2] = "BUILTBYTIER2FACTORY AEON STRUCTURE AIR",
                [3] = "BUILTBYTIER2FACTORY AEON MOBILE AIR",
                [4] = "TRANSPORTBUILTBYTIER2FACTORY AEON MOBILE AIR",
            },
            ["sourceId"] = "UAB0202",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 526,
                ["entry"] = "units/UAB0202/UAB0202_script.lua",
                ["sha256"] = "a55d07ab748787150f884645f54386424644c610fc77fba6368b7ef4f6261a40",
            },
            ["standardEngineers"] = {
                [1] = "ucl1501",
                [2] = "ucl2501",
            },
            ["targetId"] = "ucs2512",
            ["tier"] = 2,
            ["upgradesTo"] = "ucs3512",
            ["version"] = 1,
        },
        ["scoFieldFixAeonFactoryRouting"] = {
            ["aiVisible"] = true,
            ["role"] = "AIR_FACTORY",
            ["upgrade"] = "ucs3512",
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
        ["buildPower"] = 40,
        ["canBuild"] = "(Tags.CHOSEN * Tags.BUILDABLE_BY_T2_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)) * Tags.SCFA_ALLUNITS",
        ["platformBoneName"] = "Attachpoint",
        ["upgradesTo"] = "ucs3512",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 8200,
            ["regen"] = 0,
            ["value"] = 8200,
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
        ["tpId"] = "ucs2512",
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
        [3] = "BUILDABLE_BY_T1_FACTORY",
        [4] = "BUILDABLE_BY_T2_FACTORY",
        [5] = "BUILDABLE_BY_T3_FACTORY",
        [6] = "CHOSEN",
        [7] = "CONSTRUCTION",
        [8] = "FACTORY",
        [9] = "STRUCTURE",
        [10] = "TECH2",
        [11] = "SCFA_AEON",
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
        [28] = "SCFA_VISIBLETORECON",
        [29] = "BUILDABLE_BY_T3_ENGINEER",
    },
    ["transport"] = {
        ["storage"] = 10,
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animupgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2512/LOD0/ucs2512.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2512/LOD0/ucs2512.sananimation",
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
