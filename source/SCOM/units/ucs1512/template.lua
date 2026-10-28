-- ucs1512: Air Factory
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Turret_Muzzle_02",
        },
        ["buildBeamEffectName"] = "beam1",
        ["buildStagingBoneName"] = "Attachpoint",
        ["buildStagingModelSha256"] = "913030238e2fdf9be899c772345a4e63da39cc00054c7ed3263c910f3d1054ea",
        ["buildStagingOffset"] = {
            ["x"] = 0,
            ["y"] = 0.7099999785423279,
            ["z"] = -4.1480610613042757e-10,
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
            ["sourceBlueprint"] = "units/UAB0102/UAB0102_unit.bp",
            ["sourceBlueprintSha256"] = "9b5583fba065681bed436f0777ab1e6187c10dda2da0e99e20b934aaa7bd84d8",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "AIR",
                [3] = "BUILTBYCOMMANDER",
                [4] = "BUILTBYTIER1ENGINEER",
                [5] = "BUILTBYTIER2ENGINEER",
                [6] = "BUILTBYTIER3ENGINEER",
                [7] = "CONSTRUCTION",
                [8] = "DRAGBUILD",
                [9] = "FACTORY",
                [10] = "PRODUCTSC1",
                [11] = "RALLYPOINT",
                [12] = "RECLAIMABLE",
                [13] = "SELECTABLE",
                [14] = "SHOWQUEUE",
                [15] = "SIZE16",
                [16] = "SORTCONSTRUCTION",
                [17] = "STRUCTURE",
                [18] = "TECH1",
                [19] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB0102",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "UAB0202",
            ["targetId"] = "ucs1512",
            ["weapons"] = {},
        },
        ["multiConstructionBeam"] = {
            ["materialPath"] = "VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial",
            ["prefabName"] = "SCOM.AeonFactoryBeam",
            ["shrink"] = 0.05,
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "source_animupgrade",
            ["durationSeconds"] = 4.666666507720947,
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
                    ["x"] = 1.874239,
                    ["y"] = 2.204285,
                    ["z"] = 2.458285,
                },
                ["min"] = {
                    ["x"] = -1.874239,
                    ["y"] = -1.09086,
                    ["z"] = -1.874239,
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
                ["matchingEngineer"] = "ucl1501",
                ["measuredMinimumOriginY"] = 0.982296,
                ["minimumOutDistance"] = 1.874239,
                ["reservationHalfWidth"] = 0.271269,
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
            ["sourceId"] = "UAB0102",
            ["targetId"] = "ucs1512",
            ["version"] = 1,
        },
        ["scoFactoryEngineerEgress"] = {
            ["canBuild"] = "Tags.CHOSEN * Tags.BUILDABLE_BY_T1_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)",
            ["className"] = {
                [1] = "unitsDefaultChosen",
                [2] = "AeonPortAirFactory",
            },
            ["engineers"] = {
                [1] = "ucl1501",
            },
            ["faction"] = "CHOSEN",
            ["originalCanBuild"] = "Tags.CHOSEN * Tags.BUILDABLE_BY_T1_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)",
            ["platformBoneName"] = "Attachpoint",
            ["platformEvidence"] = {
                ["bone"] = "Attachpoint",
                ["path"] = "Units/ucs1512/LOD0/ucs1512.sanskeleton",
                ["sha256"] = "b066c64a4dd3b2433eef0bd44f424dbcc47a927d746ed10dc95d6db7081a82fb",
            },
            ["sourceBlueprint"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 9869,
                ["entry"] = "units/UAB0102/UAB0102_unit.bp",
                ["sha256"] = "9b5583fba065681bed436f0777ab1e6187c10dda2da0e99e20b934aaa7bd84d8",
            },
            ["sourceBuildableCategories"] = {
                [1] = "BUILTBYTIER1FACTORY AEON MOBILE CONSTRUCTION",
                [2] = "BUILTBYTIER1FACTORY AEON STRUCTURE AIR",
                [3] = "BUILTBYTIER1FACTORY AEON MOBILE AIR",
                [4] = "TRANSPORTBUILTBYTIER1FACTORY AEON MOBILE AIR",
            },
            ["sourceId"] = "UAB0102",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 526,
                ["entry"] = "units/UAB0102/UAB0102_script.lua",
                ["sha256"] = "2663ae2ff8675ef8653e7cad199338b1c019bc7d8ca06da2958d92e2b77a7461",
            },
            ["standardEngineers"] = {
                [1] = "ucl1501",
            },
            ["targetId"] = "ucs1512",
            ["tier"] = 1,
            ["upgradesTo"] = "ucs2512",
            ["version"] = 1,
        },
        ["scoFieldFixAeonFactoryRouting"] = {
            ["aiVisible"] = true,
            ["role"] = "AIR_FACTORY",
            ["upgrade"] = "ucs2512",
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
            ["x"] = 3,
            ["y"] = 0.7,
            ["z"] = 3,
        },
    },
    ["construction"] = {
        ["buildPower"] = 20,
        ["canBuild"] = "(Tags.CHOSEN * Tags.BUILDABLE_BY_T1_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY + Tags.ENGINEER)) * Tags.SCFA_ALLUNITS",
        ["platformBoneName"] = "Attachpoint",
        ["upgradesTo"] = "ucs2512",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 4400,
            ["regen"] = 0,
            ["value"] = 4400,
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
        ["tpId"] = "ucs1512",
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
        [3] = "BUILDABLE_BY_T1_ENGINEER",
        [4] = "BUILDABLE_BY_T2_ENGINEER",
        [5] = "BUILDABLE_BY_T3_ENGINEER",
        [6] = "CHOSEN",
        [7] = "CONSTRUCTION",
        [8] = "FACTORY",
        [9] = "STRUCTURE",
        [10] = "TECH1",
        [11] = "SCFA_AEON",
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
        [30] = "SCFA_VISIBLETORECON",
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
                ["sanAnimationPath"] = "Units/ucs1512/LOD0/ucs1512.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1512/LOD0/ucs1512.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.54,
                    ["y"] = 0.5249999999999999,
                    ["z"] = -0.6000000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.66,
                    ["y"] = 0.476,
                    ["z"] = 0.54,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.6000000000000001,
                    ["y"] = 0.546,
                    ["z"] = 0.48,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.54,
                    ["y"] = 0.6439999999999999,
                    ["z"] = -0.6000000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.66,
                    ["y"] = 0.6299999999999999,
                    ["z"] = 0.54,
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
