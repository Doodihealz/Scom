-- ues3701: SA3 - Omni
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["mapping"] = "UEB3104 -> ues3701",
            ["radarStateRotatorGateSupported"] = true,
            ["sanctuaryOmniRadiusSupported"] = false,
            ["sanctuaryRandomDishMotionSupported"] = false,
            ["sanctuaryReactivateTimeSupported"] = false,
            ["sanctuaryShowIntelOnSelectSupported"] = false,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudioBanksImported"] = false,
            ["sourceBlueprint"] = "units/UEB3104/UEB3104_unit.bp",
            ["sourceBlueprintSha256"] = "0850c6139f625e2bbe6ff575a0950f786c1526cfb2a59e2aaf5661c3b0e8e495",
            ["sourceCommanderBuildCategoriesSupported"] = false,
            ["sourceEmitterGraphSupported"] = false,
            ["sourceOmniRadius"] = 200,
            ["sourceRandomDishMotion"] = false,
            ["sourceReactivateTime"] = 10,
            ["sourceRotatorAccelerationSupported"] = false,
            ["sourceScript"] = "units/UEB3104/UEB3104_script.lua",
            ["sourceScriptSha256"] = "1b503994719bacb8ddebf014fdfb743228dbcf6a02ac3ff89478689898c4d653",
            ["sourceShowIntelOnSelect"] = true,
            ["sourceUpgradeAnimationMapped"] = false,
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Upper_Array",
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 10,
                },
            },
            [2] = {
                ["boneName"] = "Lower_Array_Detail",
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = -10,
                },
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.94,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.39,
                ["y"] = 2.39,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 2.24,
            ["y"] = 2.24,
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1.94,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2.16,
            ["y"] = 4.12,
            ["z"] = 2.16,
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
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "SA3 - Omni",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "intel",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_intel.png",
        ["iconUIBuildSortPriority"] = 290,
        ["iconUIType"] = "land",
        ["name"] = "SA3 - Omni",
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
        ["tpId"] = "ues3701",
        ["unitTypeName"] = "EDAT3Radar",
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
        [2] = "EDA",
        [3] = "INTEL",
        [4] = "RADAR",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER3COMMANDER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_DRAGBUILD",
        [11] = "SCFA_INTELLIGENCE",
        [12] = "SCFA_OMNI",
        [13] = "SCFA_OVERLAYOMNI",
        [14] = "SCFA_OVERLAYRADAR",
        [15] = "SCFA_PRODUCTSC1",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_SIZE4",
        [19] = "SCFA_SORTINTEL",
        [20] = "SCFA_STRUCTURE",
        [21] = "SCFA_TECH3",
        [22] = "SCFA_UEF",
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
                    ["particleName"] = "VFX/Death/ved2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.38880000000000003,
                    ["y"] = 2.9699999999999998,
                    ["z"] = -0.43200000000000005,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.4752,
                    ["y"] = 2.6816,
                    ["z"] = 0.38880000000000003,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.43200000000000005,
                    ["y"] = 3.0936000000000003,
                    ["z"] = 0.3456,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.38880000000000003,
                    ["y"] = 3.6704,
                    ["z"] = -0.43200000000000005,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.4752,
                    ["y"] = 3.588,
                    ["z"] = 0.38880000000000003,
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
                ["y"] = 1.94,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.39,
                ["y"] = 2.39,
            },
        },
    },
}
