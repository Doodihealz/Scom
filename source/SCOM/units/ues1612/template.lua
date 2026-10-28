-- ues1612: Energy Storage
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
            ["mapping"] = "UEB1105 -> ues1612",
            ["resolvedSourceVisionRadius"] = 0,
            ["sanctuaryAdjacency"] = "T1EnergyStorageAdjacencyBuff",
            ["sanctuaryStorageFillManipulationSupported"] = false,
            ["sourceAdjacency"] = "T1EnergyStorageAdjacencyBuffs",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEB1105/UEB1105_unit.bp",
            ["sourceBlueprintSha256"] = "c034747eef467a9ce0895dcc670384b6ef404b2427e3fffa7ad0c3a6d4200384",
            ["sourceCommanderBuildCategoriesSupported"] = false,
            ["sourceScript"] = "units/UEB1105/UEB1105_Script.lua",
            ["sourceScriptSha256"] = "ef742df5a6fd50f475894cc6ad50069ede2e4ca658adee02df8cd64d217a98a0",
            ["sourceStorageManipulation"] = {
                ["bone"] = "B01",
                ["offset"] = {
                    ["z"] = -0.6,
                },
                ["resource"] = "ENERGY",
            },
            ["sourceVisionRadiusDeclared"] = false,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.57,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.6,
                ["y"] = 1.6,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.3,
            ["y"] = 1.3,
        },
    },
    ["adjacency"] = "T1EnergyStorageAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.57,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.6,
            ["y"] = 2.6,
            ["z"] = 1.6,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 500,
            ["regen"] = 0,
            ["value"] = 500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 200,
        ["cost"] = {
            ["alloys"] = 250,
            ["energy"] = 1200,
        },
        ["storage"] = {
            ["energy"] = 5000,
        },
    },
    ["footprint"] = {
        ["x"] = 1.6,
        ["y"] = 1.6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStorage",
        },
        ["displayName"] = "Energy Storage",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "plasma",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_plasma.png",
        ["iconUIBuildSortPriority"] = 330,
        ["iconUIType"] = "amphibious",
        ["name"] = "Energy Storage",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "ues1612",
        ["unitTypeName"] = "EDAT1EnergyStorage",
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
        [8] = "ENERGY_STORAGE",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER1ENGINEER",
        [11] = "SCFA_BUILTBYTIER2COMMANDER",
        [12] = "SCFA_BUILTBYTIER2ENGINEER",
        [13] = "SCFA_BUILTBYTIER3ENGINEER",
        [14] = "SCFA_DRAGBUILD",
        [15] = "SCFA_ECONOMIC",
        [16] = "SCFA_ENERGYSTORAGE",
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
                    ["x"] = 0.288,
                    ["y"] = 1.22,
                    ["z"] = -0.32000000000000006,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.35200000000000004,
                    ["y"] = 1.0379999999999998,
                    ["z"] = 0.288,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.32000000000000006,
                    ["y"] = 1.298,
                    ["z"] = 0.256,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.288,
                    ["y"] = 1.662,
                    ["z"] = -0.32000000000000006,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.35200000000000004,
                    ["y"] = 1.6099999999999999,
                    ["z"] = 0.288,
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
                ["y"] = 0.57,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.6,
                ["y"] = 1.6,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 1000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 2,
            ["damageType"] = "Normal",
        },
    },
}
