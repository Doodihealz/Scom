-- ucs1513: Naval Factory
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Turret_Muzzle_01",
        },
        ["buildStagingBoneName"] = "Attachpoint01",
        ["buildStagingModelSha256"] = "c3b344852b759d82da977ad607d6f6d22b2c0d41e756c1b547ea7e4b9df34310",
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
            ["sourceBlueprint"] = "units/UAB0103/UAB0103_unit.bp",
            ["sourceBlueprintSha256"] = "c4a4ecbc0b8e053b8bb4d46a90fa47e19c137038f297572ea53db6b3e9deedb6",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYCOMMANDER",
                [3] = "BUILTBYTIER1ENGINEER",
                [4] = "BUILTBYTIER2ENGINEER",
                [5] = "BUILTBYTIER3ENGINEER",
                [6] = "CONSTRUCTION",
                [7] = "DRAGBUILD",
                [8] = "FACTORY",
                [9] = "NAVAL",
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
            ["sourceId"] = "UAB0103",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "UAB0203",
            ["targetId"] = "ucs1513",
            ["weapons"] = {},
        },
        ["multiConstructionBeam"] = {
            ["materialPath"] = "VFX/SupremeCommanderOverhaul/Aeon/Materials/aeon_construction_beam.sanmaterial",
            ["prefabName"] = "SCOM.AeonFactoryBeam",
            ["shrink"] = 0.05,
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "source_animopen",
            ["durationSeconds"] = 3.3333332538604736,
            ["restAnimationKey"] = "walk",
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
                    ["y"] = 3.89868,
                    ["z"] = 3.490644,
                },
                ["min"] = {
                    ["x"] = -2.501638,
                    ["y"] = -0.963797,
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
            ["sourceId"] = "UAB0103",
            ["targetId"] = "ucs1513",
            ["version"] = 1,
        },
        ["scoFieldFixAeonFactoryRouting"] = {
            ["aiVisible"] = true,
            ["role"] = "NAVAL_FACTORY",
            ["upgrade"] = "ucs2513",
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
                ["y"] = 6.5,
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
        ["buildPower"] = 20,
        ["canBuild"] = "(Tags.CHOSEN * Tags.BUILDABLE_BY_T1_FACTORY * ((Tags.NAVAL * Tags.MOBILE) + Tags.NAVAL_FACTORY)) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "ucs2513",
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
            ["alloys"] = 300,
            ["energy"] = 1500,
        },
        ["storage"] = {
            ["alloys"] = 80,
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
        ["tpId"] = "ucs1513",
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
        [1] = "BUILDABLE_BY_T1_ENGINEER",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "CHOSEN",
        [5] = "CONSTRUCTION",
        [6] = "FACTORY",
        [7] = "NAVAL",
        [8] = "NAVAL_FACTORY",
        [9] = "STRUCTURE",
        [10] = "TECH1",
        [11] = "SCFA_AEON",
        [12] = "SCFA_ALLUNITS",
        [13] = "SCFA_BUILTBYCOMMANDER",
        [14] = "SCFA_BUILTBYTIER1ENGINEER",
        [15] = "SCFA_BUILTBYTIER2ENGINEER",
        [16] = "SCFA_BUILTBYTIER3ENGINEER",
        [17] = "SCFA_CONSTRUCTION",
        [18] = "SCFA_DRAGBUILD",
        [19] = "SCFA_FACTORY",
        [20] = "SCFA_NAVAL",
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
            ["source_animopen"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1513/LOD0/ucs1513.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1513/LOD0/ucs1513.sananimation",
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
                ["y"] = 6.5,
            },
        },
    },
}
