-- ues2611: EG - 200 Fusion Reactor
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["adjacencyMagnitudeSourceOwned"] = false,
            ["adjacentStructureEnergyMod"] = -4,
            ["sourceBlueprintSha256"] = "49ea20d181b052fabd2563a799c87dadb89a71025233210ef59a944e34c95e17",
            ["sourceId"] = "UEB1201",
            ["sourceScriptSha256"] = "86265a9e2a02675b31d78d0ae366544a1b058728b40411b46d9a05e1c56ee167",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.45,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3.6,
                ["y"] = 3.6,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 3.6,
            ["y"] = 3.6,
        },
    },
    ["adjacency"] = "T2EnergyGeneratorAdjacencyBuff",
    ["audio"] = {
        ["active"] = {
            ["looping"] = true,
            ["name"] = "aelu2320",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2121",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.45,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2.2,
            ["y"] = 0.9,
            ["z"] = 2.2,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 2160,
            ["regen"] = 0,
            ["value"] = 2160,
        },
    },
    ["economy"] = {
        ["buildTime"] = 2000,
        ["cost"] = {
            ["alloys"] = 1200,
            ["energy"] = 12000,
        },
        ["production"] = {
            ["energy"] = 500,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAEnergyGenerator",
        },
        ["displayName"] = "EG - 200 Fusion Reactor",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "plasma",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_plasma.png",
        ["iconUIBuildSortPriority"] = 360,
        ["iconUIType"] = "amphibious",
        ["name"] = "EG - 200 Fusion Reactor",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "ues2611",
        ["unitTypeName"] = "EDAT2EnergyGenerator",
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
        ["x"] = 6,
        ["y"] = 6,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_ENGINEER",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "ECONOMIC",
        [4] = "EDA",
        [5] = "ENERGY_PRODUCTION",
        [6] = "STRUCTURE",
        [7] = "TECH2",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_BUILTBYTIER2COMMANDER",
        [10] = "SCFA_BUILTBYTIER2ENGINEER",
        [11] = "SCFA_BUILTBYTIER3ENGINEER",
        [12] = "SCFA_DRAGBUILD",
        [13] = "SCFA_ECONOMIC",
        [14] = "SCFA_ENERGYPRODUCTION",
        [15] = "SCFA_PRODUCTSC1",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_SIZE12",
        [19] = "SCFA_SORTECONOMY",
        [20] = "SCFA_STRUCTURE",
        [21] = "SCFA_TECH2",
        [22] = "SCFA_UEF",
        [23] = "SCFA_VISIBLETORECON",
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
                    ["particleName"] = "VFX/Death/ved2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.396,
                    ["y"] = 0.675,
                    ["z"] = -0.44000000000000006,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.48400000000000004,
                    ["y"] = 0.612,
                    ["z"] = 0.396,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.44000000000000006,
                    ["y"] = 0.7020000000000001,
                    ["z"] = 0.35200000000000004,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.396,
                    ["y"] = 0.8280000000000001,
                    ["z"] = -0.44000000000000006,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.48400000000000004,
                    ["y"] = 0.81,
                    ["z"] = 0.396,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 109,
            ["lod1distance"] = 283,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.45,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3.6,
                ["y"] = 3.6,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 1500,
            ["damageFriendly"] = true,
            ["damageRadius"] = 5,
            ["damageType"] = "Normal",
        },
    },
}
