-- uss1614: Uya-atoh
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faHydrocarbonPlacement"] = {
            ["fallback"] = "blocked_normal_construction",
            ["nativeResourceSupported"] = false,
            ["sourceRequirement"] = "hydrocarbon_deposit",
            ["supported"] = false,
        },
        ["scoFaAdjacency"] = {
            ["nativeAdjacency"] = "T2EnergyGeneratorAdjacencyBuff",
            ["parityLimitation"] = "Native T2 energy adjacency omits FA weapon-energy/rate-of-fire effects and footprint scaling.",
            ["sourceAdjacency"] = "HydrocarbonAdjacencyBuffs",
            ["sourceBlueprintSha256"] = "3c83b8f1ac1224e0d65768164ff3e9b791e22ca81fa4a3d17a214a2130692473",
            ["sourceId"] = "XSB1102",
        },
        ["scoHydroPlacement"] = {
            ["creativeDirectSpawnPreserved"] = true,
            ["fallback"] = "blocked_normal_construction",
            ["nativeResourceSupported"] = false,
            ["nativeResourceTypes"] = {
                [1] = "alloys",
            },
            ["normalConstructionSupported"] = false,
            ["reason"] = "Requires a hydrocarbon deposit; this native runtime has no supported hydrocarbon resource type.",
            ["sourceBlueprint"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 5800,
                ["entry"] = "units/XSB1102/XSB1102_unit.bp",
                ["sha256"] = "3c83b8f1ac1224e0d65768164ff3e9b791e22ca81fa4a3d17a214a2130692473",
            },
            ["sourceId"] = "XSB1102",
            ["sourceRequirement"] = "RULEUBR_OnHydrocarbonDeposit",
            ["targetId"] = "uss1614",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.75,
                ["y"] = 1.5,
            },
        },
    },
    ["adjacency"] = "T2EnergyGeneratorAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2.5,
            ["y"] = 0.5,
            ["z"] = 1.75,
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
        ["buildTime"] = 400,
        ["cost"] = {
            ["alloys"] = 160,
            ["energy"] = 800,
        },
        ["production"] = {
            ["energy"] = 100,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimEnergyGenerator",
        },
        ["displayName"] = "Uya-atoh",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "plasma",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_plasma.png",
        ["iconUIBuildSortPriority"] = 360,
        ["iconUIType"] = "amphibious",
        ["name"] = "Uya-atoh",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "uss1614",
        ["unitTypeName"] = "UnknownT1EnergyGenerator",
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
        ["x"] = 6,
        ["y"] = 6,
    },
    ["tags"] = {
        [1] = "SERAPHIM",
        [2] = "ECONOMIC",
        [3] = "ENERGY_PRODUCTION",
        [4] = "STRUCTURE",
        [5] = "TECH1",
        [6] = "SCFA_ALLUNITS",
        [7] = "SCFA_ECONOMIC",
        [8] = "SCFA_ENERGYPRODUCTION",
        [9] = "SCFA_HYDROCARBON",
        [10] = "SCFA_PRODUCTFA",
        [11] = "SCFA_RECLAIMABLE",
        [12] = "SCFA_SELECTABLE",
        [13] = "SCFA_SERAPHIM",
        [14] = "SCFA_SIZE12",
        [15] = "SCFA_SORTECONOMY",
        [16] = "SCFA_STRUCTURE",
        [17] = "SCFA_TECH1",
        [18] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss1614/LOD0/uss1614.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "AnimLoop",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/uss1614/LOD0/uss1614.sananimation",
            },
        },
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
                    ["particleName"] = "VFX/Death/vcd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.44999999999999996,
                    ["y"] = 0.375,
                    ["z"] = -0.35000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.55,
                    ["y"] = 0.33999999999999997,
                    ["z"] = 0.315,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.5,
                    ["y"] = 0.39,
                    ["z"] = 0.28,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.44999999999999996,
                    ["y"] = 0.45999999999999996,
                    ["z"] = -0.35000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.55,
                    ["y"] = 0.45,
                    ["z"] = 0.315,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 71,
            ["lod1distance"] = 184,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.75,
                ["y"] = 1.5,
            },
        },
    },
}
