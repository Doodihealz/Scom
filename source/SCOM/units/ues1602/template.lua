-- ues1602: Mass Storage
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["audio"] = {
                ["donorRootPersistentLoopRetained"] = false,
                ["sourceActiveLoopSupported"] = false,
                ["sourceBanksImported"] = false,
                ["sourceCompletionCueSupported"] = false,
            },
            ["mapping"] = "UEB1106 -> ues1602",
            ["resolvedSourceVisionRadius"] = 0,
            ["sanctuaryAdjacency"] = "T1AlloyStorageAdjacencyBuff",
            ["sanctuaryStorageFillManipulationSupported"] = false,
            ["sourceAdjacency"] = "T1MassStorageAdjacencyBuffs",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEB1106/UEB1106_unit.bp",
            ["sourceBlueprintSha256"] = "3c728933dfe3567a969b4ee8a6663fac7e600dca163873e4eba6374fa0d549a7",
            ["sourceCommanderBuildCategoriesSupported"] = false,
            ["sourceScript"] = "units/UEB1106/UEB1106_script.lua",
            ["sourceScriptSha256"] = "23cd41a64f390ec4c9eb3cbb65f22c5d374a3fcbf8c59109925263dfabac4d8e",
            ["sourceStorageManipulation"] = {
                ["bone"] = "Block",
                ["offset"] = {
                    ["z"] = -0.3,
                },
                ["resource"] = "MASS",
            },
            ["sourceVisionRadiusDeclared"] = false,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.53,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.4,
                ["y"] = 1.4,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.1,
            ["y"] = 1.1,
        },
    },
    ["adjacency"] = "T1AlloyStorageAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.53,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.4,
            ["y"] = 1.5,
            ["z"] = 1.4,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1600,
            ["regen"] = 0,
            ["value"] = 1600,
        },
    },
    ["economy"] = {
        ["buildTime"] = 250,
        ["cost"] = {
            ["alloys"] = 200,
            ["energy"] = 1500,
        },
        ["storage"] = {
            ["alloys"] = 500,
        },
    },
    ["footprint"] = {
        ["x"] = 1.4,
        ["y"] = 1.4,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStorage",
        },
        ["displayName"] = "Mass Storage",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "alloy",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_alloy.png",
        ["iconUIBuildSortPriority"] = 340,
        ["iconUIType"] = "amphibious",
        ["name"] = "Mass Storage",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "ues1602",
        ["unitTypeName"] = "EDAT1AlloyStorage",
    },
    ["intel"] = {
        ["visionRadius"] = 0,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
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
        [4] = "ECONOMIC",
        [5] = "EDA",
        [6] = "STRUCTURE",
        [7] = "TECH1",
        [8] = "ALLOYS_STORAGE",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER1ENGINEER",
        [11] = "SCFA_BUILTBYTIER2COMMANDER",
        [12] = "SCFA_BUILTBYTIER2ENGINEER",
        [13] = "SCFA_BUILTBYTIER3ENGINEER",
        [14] = "SCFA_DRAGBUILD",
        [15] = "SCFA_ECONOMIC",
        [16] = "SCFA_MASSSTORAGE",
        [17] = "SCFA_PRODUCTSC1",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_SIZE4",
        [21] = "SCFA_SORTECONOMY",
        [22] = "SCFA_STRUCTURE",
        [23] = "SCFA_TECH1",
        [24] = "SCFA_UEF",
        [25] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.5,
                ["y"] = 0.5,
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
                    ["x"] = 0.252,
                    ["y"] = 0.905,
                    ["z"] = -0.27999999999999997,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.308,
                    ["y"] = 0.8,
                    ["z"] = 0.252,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.27999999999999997,
                    ["y"] = 0.9500000000000001,
                    ["z"] = 0.22399999999999998,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.252,
                    ["y"] = 1.1600000000000001,
                    ["z"] = -0.27999999999999997,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.308,
                    ["y"] = 1.1300000000000001,
                    ["z"] = 0.252,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 69,
            ["lod1distance"] = 179,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.53,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.4,
                ["y"] = 1.4,
            },
        },
    },
}
