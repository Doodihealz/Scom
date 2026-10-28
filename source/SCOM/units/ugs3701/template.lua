-- ugs3701: Olympus
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["mapping"] = "URB3104 -> ugs3701",
            ["radarStateRotatorGateSupported"] = true,
            ["sanctuaryOmniRadiusSupported"] = false,
            ["sanctuaryRandomDishMotionSupported"] = false,
            ["sanctuaryReactivateTimeSupported"] = false,
            ["sanctuaryShowIntelOnSelectSupported"] = false,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudioBanksImported"] = false,
            ["sourceBlueprint"] = "units/URB3104/URB3104_unit.bp",
            ["sourceBlueprintSha256"] = "d72ec56d15d1a0ff351a580ce5afabd127f16817d6e4a0134316d5193c3735fa",
            ["sourceCommanderBuildCategoriesSupported"] = false,
            ["sourceEmitterGraphSupported"] = false,
            ["sourceOmniRadius"] = 200,
            ["sourceRandomDishMotion"] = true,
            ["sourceRotatorAccelerationSupported"] = false,
            ["sourceScript"] = "units/URB3104/URB3104_script.lua",
            ["sourceScriptSha256"] = "97d45c808e24410434d2f7ad417f45d2af9c0e9410cf232e1b63b8e174825702",
            ["sourceShowIntelOnSelect"] = true,
            ["sourceUpgradeAnimationMapped"] = false,
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Spinner",
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 3,
                },
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 2.32,
                ["z"] = 0.18,
            },
            ["size"] = {
                ["x"] = 2.37,
                ["y"] = 2.16,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 2.22,
            ["y"] = 2.01,
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 2.32,
            ["z"] = 0.18,
        },
        ["collisionSize"] = {
            ["x"] = 2.14,
            ["y"] = 4.79,
            ["z"] = 1.93,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 100,
            ["regen"] = 0,
            ["value"] = 100,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1800,
        ["cost"] = {
            ["alloys"] = 2400,
            ["energy"] = 30000,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 2000,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardStructure",
        },
        ["displayName"] = "Olympus",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "intel",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_intel.png",
        ["iconUIBuildSortPriority"] = 290,
        ["iconUIType"] = "land",
        ["name"] = "Olympus",
        ["orders"] = {
            ["Pause"] = false,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Intel"] = true,
        },
        ["tpId"] = "ugs3701",
        ["unitTypeName"] = "GuardT3Radar",
    },
    ["intel"] = {
        ["radarRadius"] = 600,
        ["visionRadius"] = 30,
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 600,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 30,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 30,
        },
    },
    ["skirtSize"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "GUARD",
        [3] = "INTEL",
        [4] = "RADAR",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER3COMMANDER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_CYBRAN",
        [11] = "SCFA_DRAGBUILD",
        [12] = "SCFA_INTELLIGENCE",
        [13] = "SCFA_OMNI",
        [14] = "SCFA_OVERLAYOMNI",
        [15] = "SCFA_OVERLAYRADAR",
        [16] = "SCFA_PRODUCTSC1",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_SIZE4",
        [20] = "SCFA_SORTINTEL",
        [21] = "SCFA_STRUCTURE",
        [22] = "SCFA_TECH3",
        [23] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
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
                    ["particleName"] = "VFX/Death/vgd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.3852,
                    ["y"] = 3.5175,
                    ["z"] = -0.20600000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.47080000000000005,
                    ["y"] = 3.1822,
                    ["z"] = 0.5274,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.42800000000000005,
                    ["y"] = 3.6612,
                    ["z"] = 0.4888,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.3852,
                    ["y"] = 4.331799999999999,
                    ["z"] = -0.20600000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.47080000000000005,
                    ["y"] = 4.236,
                    ["z"] = 0.5274,
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
                ["y"] = 2.32,
                ["z"] = 0.18,
            },
            ["size"] = {
                ["x"] = 2.37,
                ["y"] = 2.16,
            },
        },
    },
}
