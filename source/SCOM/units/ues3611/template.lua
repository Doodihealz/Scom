-- ues3611: EG 900 Fusion Reactor
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["adjacencyMagnitudeSourceOwned"] = false,
            ["adjacentStructureEnergyMod"] = -5,
            ["sourceBlueprintSha256"] = "71e92d602bed2a04916c020662df4f1ac74030cd7de70eff0f962aa760cd57af",
            ["sourceId"] = "UEB1301",
            ["sourceScriptSha256"] = "7d25361b4cd8e7fd70a0cfa3867e70d25bd0af33d7ca05c6671c0bb80c4bef1b",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 6.2,
                ["y"] = 6.2,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 6.2,
            ["y"] = 6.2,
        },
    },
    ["adjacency"] = "T3EnergyGeneratorAdjacencyBuff",
    ["audio"] = {
        ["active"] = {
            ["looping"] = true,
            ["name"] = "aelu2330",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2121",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 3,
            ["y"] = 2.5,
            ["z"] = 3,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 9720,
            ["regen"] = 0,
            ["value"] = 9720,
        },
    },
    ["economy"] = {
        ["buildTime"] = 5400,
        ["cost"] = {
            ["alloys"] = 3240,
            ["energy"] = 57600,
        },
        ["production"] = {
            ["energy"] = 2500,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAEnergyGenerator",
        },
        ["displayName"] = "EG 900 Fusion Reactor",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "plasma",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_plasma.png",
        ["iconUIBuildSortPriority"] = 360,
        ["iconUIType"] = "amphibious",
        ["name"] = "EG 900 Fusion Reactor",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "ues3611",
        ["unitTypeName"] = "EDAT3EnergyGenerator",
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
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "ECONOMIC",
        [3] = "EDA",
        [4] = "ENERGY_PRODUCTION",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER3COMMANDER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_DRAGBUILD",
        [11] = "SCFA_ECONOMIC",
        [12] = "SCFA_ENERGYPRODUCTION",
        [13] = "SCFA_PRODUCTSC1",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SIZE16",
        [17] = "SCFA_SORTECONOMY",
        [18] = "SCFA_STRUCTURE",
        [19] = "SCFA_TECH3",
        [20] = "SCFA_UEF",
        [21] = "SCFA_VISIBLETORECON",
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
                    ["audioName"] = "unit_death_land_eda_large",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/ved2301_death_building_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.54,
                    ["y"] = 1.875,
                    ["z"] = -0.6000000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.66,
                    ["y"] = 1.7,
                    ["z"] = 0.54,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.6000000000000001,
                    ["y"] = 1.9500000000000002,
                    ["z"] = 0.48,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.54,
                    ["y"] = 2.3,
                    ["z"] = -0.6000000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.66,
                    ["y"] = 2.25,
                    ["z"] = 0.54,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 202,
            ["lod1distance"] = 526,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 6.2,
                ["y"] = 6.2,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 8000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 10,
            ["damageType"] = "Normal",
        },
    },
}
