-- ues1701: SA1 - 1000
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["mapping"] = "UEB3101 -> ues1701",
            ["radarStateRotatorGateSupported"] = true,
            ["sanctuaryOmniRadiusSupported"] = false,
            ["sanctuaryRandomDishMotionSupported"] = false,
            ["sanctuaryReactivateTimeSupported"] = false,
            ["sanctuaryShowIntelOnSelectSupported"] = false,
            ["sanctuaryUpgradesTo"] = "ues2701",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudioBanksImported"] = false,
            ["sourceBlueprint"] = "units/UEB3101/UEB3101_unit.bp",
            ["sourceBlueprintSha256"] = "ee05e5e121a66c6e9f1fd13aa971044c6d9f5b553af6867683a02772ce96a5b3",
            ["sourceCommanderBuildCategoriesSupported"] = false,
            ["sourceEmitterGraphSupported"] = false,
            ["sourceRandomDishMotion"] = false,
            ["sourceReactivateTime"] = 10,
            ["sourceRotatorAccelerationSupported"] = false,
            ["sourceScript"] = "units/UEB3101/UEB3101_Script.lua",
            ["sourceScriptSha256"] = "5c94a1e0cc57c419a4b7243e763d3e09890ad08493d94b3d361fb2b8c225b757",
            ["sourceShowIntelOnSelect"] = true,
            ["sourceUpgradeAnimationMapped"] = true,
            ["sourceUpgradesTo"] = "ueb3201",
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "upgrade",
            ["durationSeconds"] = 5.83333349227905,
            ["restAnimationKey"] = "walk",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.04,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.41,
                ["y"] = 1.41,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.26,
            ["y"] = 1.26,
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1.04,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.18,
            ["y"] = 3.41,
            ["z"] = 1.18,
        },
    },
    ["construction"] = {
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.ues2701) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "ues2701",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 10,
            ["regen"] = 0,
            ["value"] = 10,
        },
    },
    ["economy"] = {
        ["buildTime"] = 80,
        ["cost"] = {
            ["alloys"] = 80,
            ["energy"] = 720,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 20,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAImportedAnimatedStructure",
        },
        ["displayName"] = "SA1 - 1000",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "intel",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_intel.png",
        ["iconUIBuildSortPriority"] = 290,
        ["iconUIType"] = "land",
        ["name"] = "SA1 - 1000",
        ["orders"] = {
            ["Pause"] = false,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Intel"] = true,
            ["Pause"] = false,
        },
        ["tpId"] = "ues1701",
        ["unitTypeName"] = "EDAT1Radar",
    },
    ["intel"] = {
        ["radarRadius"] = 115,
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 115,
        },
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
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T1_ENGINEER",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "CONSTRUCTION",
        [5] = "EDA",
        [6] = "INTEL",
        [7] = "RADAR",
        [8] = "STRUCTURE",
        [9] = "TECH1",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_BUILTBYTIER1ENGINEER",
        [12] = "SCFA_BUILTBYTIER2COMMANDER",
        [13] = "SCFA_BUILTBYTIER2ENGINEER",
        [14] = "SCFA_BUILTBYTIER3COMMANDER",
        [15] = "SCFA_BUILTBYTIER3ENGINEER",
        [16] = "SCFA_DRAGBUILD",
        [17] = "SCFA_INTELLIGENCE",
        [18] = "SCFA_OVERLAYRADAR",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RADAR",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_SELECTABLE",
        [23] = "SCFA_SHOWQUEUE",
        [24] = "SCFA_SIZE4",
        [25] = "SCFA_SORTINTEL",
        [26] = "SCFA_STRUCTURE",
        [27] = "SCFA_TECH1",
        [28] = "SCFA_UEF",
        [29] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues1701/LOD0/ues1701.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues1701/LOD0/ues1701.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.4,
                ["y"] = 0.4,
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
                    ["audioName"] = "unit_death_land_eda_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/ved2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.21239999999999998,
                    ["y"] = 1.8925,
                    ["z"] = -0.236,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.2596,
                    ["y"] = 1.6538,
                    ["z"] = 0.21239999999999998,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.236,
                    ["y"] = 1.9948000000000001,
                    ["z"] = 0.1888,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.21239999999999998,
                    ["y"] = 2.4722,
                    ["z"] = -0.236,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.2596,
                    ["y"] = 2.404,
                    ["z"] = 0.21239999999999998,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 82,
            ["lod1distance"] = 215,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.04,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.41,
                ["y"] = 1.41,
            },
        },
    },
}
