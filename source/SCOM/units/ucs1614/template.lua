-- ucs1614: Hydrocarbon Power Plant
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["kind"] = "permanent_open",
            ["mapping"] = "UAB1102 -> ucs1614",
            ["primaryClip"] = {
                ["durationSeconds"] = 2.4000000953674316,
                ["key"] = "source_animopen",
                ["name"] = "AnimOpen",
                ["rate"] = 1,
            },
            ["rotatorCount"] = 0,
            ["sourceBlueprint"] = "units/UAB1102/UAB1102_unit.bp",
            ["sourceBlueprintSha256"] = "226e38c51f687f906d0d30ba449d032223b40eed65aaff7bb8c0607b021f25b6",
            ["sourceScript"] = "units/UAB1102/UAB1102_script.lua",
            ["sourceScriptSha256"] = "2f154a0ac97bbbce7193a468cb2eae0fb676480cffcde2071690912f0f91247a",
            ["version"] = "1.0.2",
        },
        ["faHydrocarbonPlacement"] = {
            ["fallback"] = "blocked_normal_construction",
            ["nativeResourceSupported"] = false,
            ["sourceRequirement"] = "hydrocarbon_deposit",
            ["supported"] = false,
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {},
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 3,
                    ["z"] = 3,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirt"] = {
                    ["offsetX"] = -1.5,
                    ["offsetZ"] = -1.5,
                    ["sizeX"] = 6,
                    ["sizeZ"] = 6,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB1102/UAB1102_unit.bp",
            ["sourceBlueprintSha256"] = "226e38c51f687f906d0d30ba449d032223b40eed65aaff7bb8c0607b021f25b6",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER1ENGINEER",
                [3] = "BUILTBYTIER2COMMANDER",
                [4] = "BUILTBYTIER2ENGINEER",
                [5] = "BUILTBYTIER3ENGINEER",
                [6] = "ECONOMIC",
                [7] = "ENERGYPRODUCTION",
                [8] = "HYDROCARBON",
                [9] = "PRODUCTSC1",
                [10] = "RECLAIMABLE",
                [11] = "SELECTABLE",
                [12] = "SIZE12",
                [13] = "SORTECONOMY",
                [14] = "STRUCTURE",
                [15] = "TECH1",
                [16] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB1102",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs1614",
            ["weapons"] = {},
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
                ["bytes"] = 5485,
                ["entry"] = "units/UAB1102/UAB1102_unit.bp",
                ["sha256"] = "226e38c51f687f906d0d30ba449d032223b40eed65aaff7bb8c0607b021f25b6",
            },
            ["sourceId"] = "UAB1102",
            ["sourceRequirement"] = "RULEUBR_OnHydrocarbonDeposit",
            ["targetId"] = "ucs1614",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.9,
                ["y"] = 1.9,
            },
        },
    },
    ["adjacency"] = "T1EnergyGeneratorAdjacencyBuff",
    ["audio"] = {
        ["active"] = {
            ["looping"] = true,
            ["name"] = "aclu2310",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.75,
            ["y"] = 2.5,
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
            ["alloys"] = 0,
            ["energy"] = 100,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortEnergyGenerator",
        },
        ["displayName"] = "Hydrocarbon Power Plant",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "plasma",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_plasma.png",
        ["iconUIBuildSortPriority"] = 360,
        ["iconUIType"] = "amphibious",
        ["name"] = "Hydrocarbon Power Plant",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["tpId"] = "ucs1614",
        ["unitTypeName"] = "Hydrocarbon Power Plant",
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
        [1] = "CHOSEN",
        [2] = "ECONOMIC",
        [3] = "ENERGY_PRODUCTION",
        [4] = "STRUCTURE",
        [5] = "TECH1",
        [6] = "SCFA_AEON",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_ECONOMIC",
        [9] = "SCFA_ENERGYPRODUCTION",
        [10] = "SCFA_HYDROCARBON",
        [11] = "SCFA_PRODUCTSC1",
        [12] = "SCFA_RECLAIMABLE",
        [13] = "SCFA_SELECTABLE",
        [14] = "SCFA_SIZE12",
        [15] = "SCFA_SORTECONOMY",
        [16] = "SCFA_STRUCTURE",
        [17] = "SCFA_TECH1",
        [18] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animopen"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1614/LOD0/ucs1614.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1614/LOD0/ucs1614.sananimation",
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
                    ["audioName"] = "unit_death_land_eda_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.315,
                    ["y"] = 1.625,
                    ["z"] = -0.35000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.385,
                    ["y"] = 1.45,
                    ["z"] = 0.315,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.35000000000000003,
                    ["y"] = 1.7000000000000002,
                    ["z"] = 0.28,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.315,
                    ["y"] = 2.05,
                    ["z"] = -0.35000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.385,
                    ["y"] = 2,
                    ["z"] = 0.315,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 70,
            ["lod1distance"] = 182,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.9,
                ["y"] = 1.9,
            },
        },
    },
}
