-- ucs3513: Naval Factory
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
        ["buildStagingBoneName"] = "Attachpoint01",
        ["buildStagingModelSha256"] = "1748fd75441c6be92b1af8f4b16ec8b8c34fd2def780c9ba3b11117b464531c2",
        ["buildStagingOffset"] = {
            ["x"] = 4.050000190734863,
            ["y"] = 0.009999657049775124,
            ["z"] = 4.779702067025937e-06,
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
                    ["x"] = 12,
                    ["z"] = 14,
                },
                ["footprintSource"] = "Physics.SkirtSizeFallback",
                ["sourceSkirt"] = {
                    ["offsetX"] = -6,
                    ["offsetZ"] = -2,
                    ["sizeX"] = 12,
                    ["sizeZ"] = 14,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB0303/UAB0303_unit.bp",
            ["sourceBlueprintSha256"] = "7ab2f1b00839e1f449406dfd87ec8b1884a393ba857d1a2f59c258d02694c2c0",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER2FACTORY",
                [3] = "CONSTRUCTION",
                [4] = "CONSTRUCTIONSORTDOWN",
                [5] = "DRAGBUILD",
                [6] = "FACTORY",
                [7] = "NAVAL",
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
            ["sourceId"] = "UAB0303",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "UAB0203",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs3513",
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
                    ["x"] = 4,
                    ["y"] = 0,
                    ["z"] = 14,
                },
                ["headingDegrees"] = 0,
                ["rampOffset"] = {
                    ["x"] = 4,
                    ["y"] = 0,
                    ["z"] = 10,
                },
            },
            [2] = {
                ["clearanceOffset"] = {
                    ["x"] = 4,
                    ["y"] = 0,
                    ["z"] = -14,
                },
                ["headingDegrees"] = 180,
                ["rampOffset"] = {
                    ["x"] = 4,
                    ["y"] = 0,
                    ["z"] = -10,
                },
            },
        },
        ["rollOffSurfacePolicy"] = "factory",
        ["scoFactoryEgress"] = {
            ["bounds"] = {
                ["max"] = {
                    ["x"] = 2.501636,
                    ["y"] = 6.223019,
                    ["z"] = 7.477192,
                },
                ["min"] = {
                    ["x"] = -2.501638,
                    ["y"] = 0.007087,
                    ["z"] = -6.930246,
                },
            },
            ["buildBone"] = "Attachpoint01",
            ["buildOffset"] = {
                ["x"] = 4.05,
                ["y"] = 0.01,
                ["z"] = 5e-06,
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
                    ["minimumClearanceDistance"] = 19.99999,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = 180,
                        ["X"] = -4,
                        ["Y"] = 0,
                        ["Z"] = -10,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = 4.05,
                            ["y"] = 0.01,
                            ["z"] = 10,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = 4.05,
                            ["y"] = 0.01,
                            ["z"] = 19.999995,
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
                    ["minimumClearanceDistance"] = 20.00001,
                    ["sourcePoint"] = {
                        ["UnitSpin"] = 0,
                        ["X"] = -4,
                        ["Y"] = 0,
                        ["Z"] = 10,
                    },
                    ["waypoints"] = {
                        [1] = {
                            ["phase"] = "deck",
                            ["x"] = 4.05,
                            ["y"] = 0.01,
                            ["z"] = -10,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = 4.05,
                            ["y"] = 0.01,
                            ["z"] = -20.000005,
                        },
                    },
                },
            },
            ["productOverrides"] = {
                ["ucn3001"] = {
                    ["buildOffset"] = {
                        ["x"] = 4.31615,
                        ["y"] = 0.01,
                        ["z"] = 5e-06,
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
                            ["minimumClearanceDistance"] = 19.99999,
                            ["sourcePoint"] = {
                                ["UnitSpin"] = 180,
                                ["X"] = -4,
                                ["Y"] = 0,
                                ["Z"] = -10,
                            },
                            ["waypoints"] = {
                                [1] = {
                                    ["phase"] = "deck",
                                    ["x"] = 4.31615,
                                    ["y"] = 0.01,
                                    ["z"] = 10,
                                },
                                [2] = {
                                    ["phase"] = "clearance",
                                    ["x"] = 4.31615,
                                    ["y"] = 0.01,
                                    ["z"] = 19.999995,
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
                            ["minimumClearanceDistance"] = 20.00001,
                            ["sourcePoint"] = {
                                ["UnitSpin"] = 0,
                                ["X"] = -4,
                                ["Y"] = 0,
                                ["Z"] = 10,
                            },
                            ["waypoints"] = {
                                [1] = {
                                    ["phase"] = "deck",
                                    ["x"] = 4.31615,
                                    ["y"] = 0.01,
                                    ["z"] = -10,
                                },
                                [2] = {
                                    ["phase"] = "clearance",
                                    ["x"] = 4.31615,
                                    ["y"] = 0.01,
                                    ["z"] = -20.000005,
                                },
                            },
                        },
                    },
                    ["measurement"] = {
                        ["outwardClearanceMargin"] = 0.025,
                        ["reason"] = "Both source naval exit directions clear the visible product/factory meshes",
                    },
                },
                ["ucs2803"] = {
                    ["buildOffset"] = {
                        ["x"] = 5.22314,
                        ["y"] = 0.01,
                        ["z"] = 5e-06,
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
                            ["minimumClearanceDistance"] = 19.99999,
                            ["sourcePoint"] = {
                                ["UnitSpin"] = 180,
                                ["X"] = -4,
                                ["Y"] = 0,
                                ["Z"] = -10,
                            },
                            ["waypoints"] = {
                                [1] = {
                                    ["phase"] = "deck",
                                    ["x"] = 5.22314,
                                    ["y"] = 0.01,
                                    ["z"] = 10,
                                },
                                [2] = {
                                    ["phase"] = "clearance",
                                    ["x"] = 5.22314,
                                    ["y"] = 0.01,
                                    ["z"] = 19.999995,
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
                            ["minimumClearanceDistance"] = 20.00001,
                            ["sourcePoint"] = {
                                ["UnitSpin"] = 0,
                                ["X"] = -4,
                                ["Y"] = 0,
                                ["Z"] = 10,
                            },
                            ["waypoints"] = {
                                [1] = {
                                    ["phase"] = "deck",
                                    ["x"] = 5.22314,
                                    ["y"] = 0.01,
                                    ["z"] = -10,
                                },
                                [2] = {
                                    ["phase"] = "clearance",
                                    ["x"] = 5.22314,
                                    ["y"] = 0.01,
                                    ["z"] = -20.000005,
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
            ["sourceId"] = "UAB0303",
            ["targetId"] = "ucs3513",
            ["version"] = 1,
        },
        ["scoFieldFixAeonFactoryRouting"] = {
            ["aiVisible"] = true,
            ["role"] = "NAVAL_FACTORY",
            ["version"] = "1.0.0",
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["seaParityWaterFactory"] = true,
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.5,
                ["y"] = 8.8,
            },
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
        ["buildPower"] = 60,
        ["canBuild"] = "(Tags.CHOSEN * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.NAVAL * Tags.MOBILE) + Tags.NAVAL_FACTORY)) * Tags.SCFA_ALLUNITS",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 37500,
            ["regen"] = 0,
            ["value"] = 37500,
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
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 12,
        ["y"] = 14,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortNavalFactory",
        },
        ["displayName"] = "Naval Factory",
        ["icon"] = {
            ["shape"] = "structure2",
            ["symbol"] = "naval",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure2_naval.png",
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
        ["tpId"] = "ucs3513",
        ["unitTypeName"] = "Naval Factory",
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
        [1] = "BUILDABLE_BY_T2_FACTORY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "CHOSEN",
        [4] = "CONSTRUCTION",
        [5] = "FACTORY",
        [6] = "NAVAL",
        [7] = "NAVAL_FACTORY",
        [8] = "STRUCTURE",
        [9] = "TECH3",
        [10] = "SCFA_AEON",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYTIER2FACTORY",
        [13] = "SCFA_CONSTRUCTION",
        [14] = "SCFA_CONSTRUCTIONSORTDOWN",
        [15] = "SCFA_DRAGBUILD",
        [16] = "SCFA_FACTORY",
        [17] = "SCFA_NAVAL",
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
                ["sanAnimationPath"] = "Units/ucs3513/LOD0/ucs3513.sananimation",
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
            ["lod0distance"] = 135,
            ["lod1distance"] = 353,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.5,
                ["y"] = 8.8,
            },
        },
    },
}
