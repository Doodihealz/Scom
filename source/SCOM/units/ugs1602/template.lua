-- ugs1602: Mass Storage
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
            ["mapping"] = "URB1106 -> ugs1602",
            ["resolvedSourceVisionRadius"] = 0,
            ["sanctuaryAdjacency"] = "T1AlloyStorageAdjacencyBuff",
            ["sanctuaryStorageFillManipulationSupported"] = false,
            ["sourceAdjacency"] = "T1MassStorageAdjacencyBuffs",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/URB1106/URB1106_unit.bp",
            ["sourceBlueprintSha256"] = "323ac892e188940daad815df6ee42ffe2f75585376591ede1965706ca51055f7",
            ["sourceCommanderBuildCategoriesSupported"] = false,
            ["sourceScript"] = "units/URB1106/URB1106_script.lua",
            ["sourceScriptSha256"] = "511a2b6ca2f189f4124d57430375f65004e1b075159c8a113dcaaec725fdf642",
            ["sourceStorageManipulation"] = {
                ["bone"] = "B01",
                ["offset"] = {
                    ["z"] = 0.61,
                },
                ["resource"] = "MASS",
            },
            ["sourceVisionRadiusDeclared"] = false,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.12,
                ["z"] = -0.02,
            },
            ["size"] = {
                ["x"] = 1.4,
                ["y"] = 1.2,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.1,
            ["y"] = 0.9,
        },
    },
    ["adjacency"] = "T1AlloyStorageAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.12,
            ["z"] = -0.02,
        },
        ["collisionSize"] = {
            ["x"] = 1.4,
            ["y"] = 1.8,
            ["z"] = 1.2,
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
        ["y"] = 1.2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardStorage",
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
        ["tpId"] = "ugs1602",
        ["unitTypeName"] = "GuardT1AlloyStorage",
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
        [5] = "GUARD",
        [6] = "STRUCTURE",
        [7] = "TECH1",
        [8] = "ALLOYS_STORAGE",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER1ENGINEER",
        [11] = "SCFA_BUILTBYTIER2COMMANDER",
        [12] = "SCFA_BUILTBYTIER2ENGINEER",
        [13] = "SCFA_BUILTBYTIER3COMMANDER",
        [14] = "SCFA_BUILTBYTIER3ENGINEER",
        [15] = "SCFA_CYBRAN",
        [16] = "SCFA_DRAGBUILD",
        [17] = "SCFA_ECONOMIC",
        [18] = "SCFA_MASSSTORAGE",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SIZE4",
        [23] = "SCFA_SORTECONOMY",
        [24] = "SCFA_STRUCTURE",
        [25] = "SCFA_TECH1",
        [26] = "SCFA_VISIBLETORECON",
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
                    ["particleName"] = "VFX/Death/vgd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.252,
                    ["y"] = 0.5700000000000001,
                    ["z"] = -0.26,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.308,
                    ["y"] = 0.444,
                    ["z"] = 0.196,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.27999999999999997,
                    ["y"] = 0.6240000000000001,
                    ["z"] = 0.17200000000000001,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.252,
                    ["y"] = 0.876,
                    ["z"] = -0.26,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.308,
                    ["y"] = 0.8400000000000001,
                    ["z"] = 0.196,
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
                ["y"] = 0.12,
                ["z"] = -0.02,
            },
            ["size"] = {
                ["x"] = 1.4,
                ["y"] = 1.2,
            },
        },
    },
}
