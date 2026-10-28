-- ugs1612: Energy Storage
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
            ["mapping"] = "URB1105 -> ugs1612",
            ["resolvedSourceVisionRadius"] = 0,
            ["sanctuaryAdjacency"] = "T1EnergyStorageAdjacencyBuff",
            ["sanctuaryStorageFillManipulationSupported"] = false,
            ["sourceAdjacency"] = "T1EnergyStorageAdjacencyBuffs",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/URB1105/URB1105_unit.bp",
            ["sourceBlueprintSha256"] = "5f7f46eea3ee0e1ddd37db354fb54ff30fe197aa5b2c45e04ab21706f0427e59",
            ["sourceCommanderBuildCategoriesSupported"] = false,
            ["sourceScript"] = "units/URB1105/URB1105_script.lua",
            ["sourceScriptSha256"] = "1909147d9e28cc86fca23ce2a8029a9449c1c94b6105ef8501a9ff7463dadfec",
            ["sourceStorageManipulation"] = {
                ["bone"] = "Lift",
                ["offset"] = {
                    ["y"] = 0.8,
                },
                ["resource"] = "ENERGY",
            },
            ["sourceVisionRadiusDeclared"] = false,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.2,
                ["z"] = -0.07,
            },
            ["size"] = {
                ["x"] = 1.5,
                ["y"] = 1.4,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.2,
            ["y"] = 1.1,
        },
    },
    ["adjacency"] = "T1EnergyStorageAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.2,
            ["z"] = -0.07,
        },
        ["collisionSize"] = {
            ["x"] = 1.5,
            ["y"] = 2.3,
            ["z"] = 1.4,
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
        ["x"] = 1.5,
        ["y"] = 1.4,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardStorage",
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
        ["tpId"] = "ugs1612",
        ["unitTypeName"] = "GuardT1EnergyStorage",
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
        [8] = "ENERGY_STORAGE",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER1ENGINEER",
        [11] = "SCFA_BUILTBYTIER2COMMANDER",
        [12] = "SCFA_BUILTBYTIER2ENGINEER",
        [13] = "SCFA_BUILTBYTIER3COMMANDER",
        [14] = "SCFA_BUILTBYTIER3ENGINEER",
        [15] = "SCFA_CYBRAN",
        [16] = "SCFA_DRAGBUILD",
        [17] = "SCFA_ECONOMIC",
        [18] = "SCFA_ENERGYSTORAGE",
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
                    ["x"] = 0.27,
                    ["y"] = 0.7749999999999999,
                    ["z"] = -0.35,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.33,
                    ["y"] = 0.614,
                    ["z"] = 0.182,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.30000000000000004,
                    ["y"] = 0.8440000000000001,
                    ["z"] = 0.15399999999999997,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.27,
                    ["y"] = 1.166,
                    ["z"] = -0.35,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.33,
                    ["y"] = 1.1199999999999999,
                    ["z"] = 0.182,
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
                ["y"] = 0.2,
                ["z"] = -0.07,
            },
            ["size"] = {
                ["x"] = 1.5,
                ["y"] = 1.4,
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
