-- uss3512: Ia-iya
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Attachpoint",
        },
        ["buildBeamEffectName"] = "beam1",
        ["scoFactoryEgress"] = {
            ["bounds"] = {
                ["max"] = {
                    ["x"] = 2.237524,
                    ["y"] = 11.169369,
                    ["z"] = 3.066239,
                },
                ["min"] = {
                    ["x"] = -2.327187,
                    ["y"] = 0.82655,
                    ["z"] = -2.588614,
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
                ["matchingEngineer"] = "usl3501",
                ["minimumOutDistance"] = 2.588614,
                ["reservationHalfWidth"] = 0.661835,
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
            ["sourceId"] = "XSB0302",
            ["targetId"] = "uss3512",
            ["version"] = 1,
        },
        ["scoFactoryEngineerEgress"] = {
            ["canBuild"] = "(Tags.SERAPHIM * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)) + (Tags.usl1501 + Tags.usl2501 + Tags.usl3501)",
            ["className"] = {
                [1] = "unitsDefaultSeraphim",
                [2] = "SeraphimAirFactory",
            },
            ["engineers"] = {
                [1] = "usl1501",
                [2] = "usl2501",
                [3] = "usl3501",
            },
            ["faction"] = "SERAPHIM",
            ["originalCanBuild"] = "Tags.SERAPHIM * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)",
            ["platformBoneName"] = "Attachpoint",
            ["platformEvidence"] = {
                ["bone"] = "Attachpoint",
                ["path"] = "Units/uss3512/LOD0/uss3512.sanskeleton",
                ["sha256"] = "f7688355a5e77aca682b8da66602699b01aa8f8c8ffe42cd5c269e602c529053",
            },
            ["sourceBlueprint"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 7795,
                ["entry"] = "units/XSB0302/XSB0302_unit.bp",
                ["sha256"] = "9028bb8f84820286493c258402f1d7b67ff87c3f352e69276c74f3dfc4541fdc",
            },
            ["sourceBuildableCategories"] = {
                [1] = "BUILTBYTIER3FACTORY SERAPHIM MOBILE CONSTRUCTION",
                [2] = "BUILTBYTIER3FACTORY SERAPHIM STRUCTURE AIR",
                [3] = "BUILTBYTIER3FACTORY SERAPHIM MOBILE AIR",
                [4] = "TRANSPORTBUILTBYTIER3FACTORY SERAPHIM MOBILE AIR",
            },
            ["sourceId"] = "XSB0302",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1250,
                ["entry"] = "units/XSB0302/XSB0302_script.lua",
                ["sha256"] = "728b1b8c82bafb3861445264418e8f589a465601f2ae2945b66edc338ad78155",
            },
            ["standardEngineers"] = {
                [1] = "usl1501",
                [2] = "usl2501",
                [3] = "usl3501",
            },
            ["targetId"] = "uss3512",
            ["tier"] = 3,
            ["version"] = 1,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.4,
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
            ["y"] = 1.4,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 4,
            ["y"] = 2.8,
            ["z"] = 4,
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
        ["buildPower"] = 60,
        ["canBuild"] = "((Tags.SERAPHIM * Tags.BUILDABLE_BY_T3_FACTORY * ((Tags.AIR * Tags.MOBILE) + Tags.AIR_FACTORY)) + (Tags.usl1501 + Tags.usl2501 + Tags.usl3501)) * Tags.SCFA_ALLUNITS",
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
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 21000,
            ["regen"] = 0,
            ["value"] = 21000,
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
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure2_air.png",
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
        ["tpId"] = "uss3512",
        ["unitTypeName"] = "UnknownT3LandFactory",
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
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_ENGINEER",
        [5] = "CONSTRUCTION",
        [6] = "FACTORY",
        [7] = "LAND",
        [8] = "SCFA_AIR",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER2FACTORY",
        [11] = "SCFA_CONSTRUCTION",
        [12] = "SCFA_CONSTRUCTIONSORTDOWN",
        [13] = "SCFA_DRAGBUILD",
        [14] = "SCFA_FACTORY",
        [15] = "SCFA_PRODUCTFA",
        [16] = "SCFA_RALLYPOINT",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_SERAPHIM",
        [20] = "SCFA_SHOWQUEUE",
        [21] = "SCFA_SIZE16",
        [22] = "SCFA_SORTCONSTRUCTION",
        [23] = "SCFA_STRUCTURE",
        [24] = "SCFA_TECH3",
        [25] = "SCFA_VISIBLETORECON",
        [26] = "SERAPHIM",
        [27] = "STRUCTURE",
        [28] = "TECH3",
    },
    ["transport"] = {
        ["storage"] = 40,
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3512/LOD0/uss3512.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3512/LOD0/uss3512.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.72,
                    ["y"] = 2.0999999999999996,
                    ["z"] = -0.8,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.88,
                    ["y"] = 1.904,
                    ["z"] = 0.72,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8,
                    ["y"] = 2.184,
                    ["z"] = 0.64,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.72,
                    ["y"] = 2.5759999999999996,
                    ["z"] = -0.8,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.88,
                    ["y"] = 2.5199999999999996,
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
                ["y"] = 1.4,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.75,
                ["y"] = 2.75,
            },
        },
    },
}
