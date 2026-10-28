-- uss2512: Ia-iya
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Attachpoint",
        },
        ["buildBeamEffectName"] = "beam1",
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "source_animupgrade",
            ["durationSeconds"] = 13.3333330154419,
            ["restAnimationKey"] = "walk",
        },
        ["scoFactoryEgress"] = {
            ["bounds"] = {
                ["max"] = {
                    ["x"] = 2.237524,
                    ["y"] = 9.96379,
                    ["z"] = 3.066239,
                },
                ["min"] = {
                    ["x"] = -2.306333,
                    ["y"] = 0.82655,
                    ["z"] = -1.761593,
                },
            },
            ["buildBone"] = "Attachpoint",
            ["buildOffset"] = {
                ["x"] = 0,
                ["y"] = 3.909203,
                ["z"] = 0,
            },
            ["domain"] = "air",
            ["engineerRoute"] = {
                ["buildBottomClearance"] = 0,
                ["direction"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = -1,
                },
                ["distanceRule"] = "max(sourceOutDistance, minimumOutDistance + child projected rear extent + required clearance margin)",
                ["extendByChildExtent"] = true,
                ["landingMode"] = "terrain-and-product-preferred-altitude-after-horizontal-clearance",
                ["matchingEngineer"] = "usl2501",
                ["minimumOutDistance"] = 1.761593,
                ["reservationHalfWidth"] = 0.580856,
                ["sourceDownDistance"] = 2.75,
                ["sourceOutDistance"] = 3,
                ["sourceSpeed"] = 1.5,
                ["staticSweepEvidence"] = "Conservative axis-aligned engineer envelope: UEF platform-end forward; Cybran/Aeon side; Seraphim forward. Full child extent must clear factory envelope before lowering.",
            },
            ["exitRoutes"] = {
                [1] = {
                    ["direction"] = {
                        ["x"] = -1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["extendByChildExtent"] = true,
                    ["headingDegrees"] = -89.999995,
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
                            ["y"] = 3.909203,
                            ["z"] = 0,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = -6,
                            ["y"] = 3.909203,
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
                    ["headingDegrees"] = 89.999995,
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
                            ["y"] = 3.909203,
                            ["z"] = 0,
                        },
                        [2] = {
                            ["phase"] = "clearance",
                            ["x"] = 6,
                            ["y"] = 3.909203,
                            ["z"] = 0,
                        },
                    },
                },
            },
            ["sourceId"] = "XSB0202",
            ["targetId"] = "uss2512",
            ["version"] = 1,
        },
        ["scoFactoryEngineerEgress"] = {
            ["canBuild"] = "(Tags.SERAPHIM * Tags.BUILDABLE_BY_T2_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)) + (Tags.usl1501 + Tags.usl2501)",
            ["className"] = {
                [1] = "unitsDefaultSeraphim",
                [2] = "SeraphimAirFactory",
            },
            ["engineers"] = {
                [1] = "usl1501",
                [2] = "usl2501",
            },
            ["faction"] = "SERAPHIM",
            ["originalCanBuild"] = "Tags.SERAPHIM * Tags.BUILDABLE_BY_T2_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)",
            ["platformBoneName"] = "Attachpoint",
            ["platformEvidence"] = {
                ["bone"] = "Attachpoint",
                ["path"] = "Units/uss2512/LOD0/uss2512.sanskeleton",
                ["sha256"] = "1c1a91d20d050e6c0a4d0ba0ba6e52d22e784a5d8853fba59328f24d29e1e962",
            },
            ["sourceBlueprint"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 7767,
                ["entry"] = "units/XSB0202/XSB0202_unit.bp",
                ["sha256"] = "ad9a1749d2df5935f3a84198af00059186006364dfdc7b9a2c4fc25b28057fd3",
            },
            ["sourceBuildableCategories"] = {
                [1] = "BUILTBYTIER2FACTORY SERAPHIM MOBILE CONSTRUCTION",
                [2] = "BUILTBYTIER2FACTORY SERAPHIM STRUCTURE AIR",
                [3] = "BUILTBYTIER2FACTORY SERAPHIM MOBILE AIR",
                [4] = "TRANSPORTBUILTBYTIER2FACTORY SERAPHIM MOBILE AIR",
            },
            ["sourceId"] = "XSB0202",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1092,
                ["entry"] = "units/XSB0202/XSB0202_script.lua",
                ["sha256"] = "0f0d6b43cd870ed8891d4ec07d4afad3f9ca81066e430ab1b49ddf080fa2c0d0",
            },
            ["standardEngineers"] = {
                [1] = "usl1501",
                [2] = "usl2501",
            },
            ["targetId"] = "uss2512",
            ["tier"] = 2,
            ["upgradesTo"] = "uss3512",
            ["version"] = 1,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.35,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.75,
                ["y"] = 2.75,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 5,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 100,
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
            ["y"] = 1.35,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 3.5,
            ["y"] = 2.7,
            ["z"] = 3.5,
        },
        ["targetBones"] = {
            [1] = "Target_Bottom",
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Attachpoint",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
        },
        ["buildPower"] = 40,
        ["canBuild"] = "((Tags.SERAPHIM * Tags.BUILDABLE_BY_T2_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)) + (Tags.usl1501 + Tags.usl2501)) * Tags.SCFA_ALLUNITS",
        ["platformBoneName"] = "Attachpoint",
        ["rollOffPoints"] = {
            [1] = {
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = 0,
            },
            [2] = {
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = 180,
            },
        },
        ["upgradesTo"] = "uss3512",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 8600,
            ["regen"] = 0,
            ["value"] = 8600,
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
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimAirFactory",
        },
        ["displayName"] = "Ia-iya",
        ["icon"] = {
            ["shape"] = "structure2",
            ["symbol"] = "air",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure2_air.png",
        ["iconUIBuildSortPriority"] = 390,
        ["iconUIType"] = "air",
        ["name"] = "Ia-iya",
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
        ["tpId"] = "uss2512",
        ["unitTypeName"] = "UnknownT2LandFactory",
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
        [2] = "ALLOYS_STORAGE",
        [3] = "BUILDABLE_BY_T1_FACTORY",
        [4] = "BUILDABLE_BY_T2_ENGINEER",
        [5] = "BUILDABLE_BY_T3_ENGINEER",
        [6] = "CONSTRUCTION",
        [7] = "FACTORY",
        [8] = "LAND",
        [9] = "SCFA_AIR",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_BUILTBYTIER1FACTORY",
        [12] = "SCFA_CONSTRUCTION",
        [13] = "SCFA_CONSTRUCTIONSORTDOWN",
        [14] = "SCFA_DRAGBUILD",
        [15] = "SCFA_FACTORY",
        [16] = "SCFA_PRODUCTFA",
        [17] = "SCFA_RALLYPOINT",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_SERAPHIM",
        [21] = "SCFA_SHOWQUEUE",
        [22] = "SCFA_SIZE16",
        [23] = "SCFA_SORTCONSTRUCTION",
        [24] = "SCFA_STRUCTURE",
        [25] = "SCFA_TECH2",
        [26] = "SCFA_VISIBLETORECON",
        [27] = "SERAPHIM",
        [28] = "STRUCTURE",
        [29] = "TECH2",
    },
    ["transport"] = {
        ["storage"] = 25,
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2512/LOD0/uss2512.sananimation",
            },
            ["source_animupgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2512/LOD0/uss2512.sananimation",
            },
            ["source_animupgrade01"] = {
                ["clipName"] = "AnimUpgrade01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2512/LOD0/uss2512.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2512/LOD0/uss2512.sananimation",
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
                    ["particleName"] = "VFX/Death/vcd2301_death_building_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.63,
                    ["y"] = 2.0250000000000004,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.77,
                    ["y"] = 1.836,
                    ["z"] = 0.63,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.7000000000000001,
                    ["y"] = 2.1060000000000003,
                    ["z"] = 0.56,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.63,
                    ["y"] = 2.484,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.77,
                    ["y"] = 2.43,
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
                ["y"] = 1.35,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.75,
                ["y"] = 2.75,
            },
        },
    },
}
