-- ues1601: Mass Pump 1
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["mapping"] = "UEB1103 -> ues1601",
            ["resolvedSourceVisionRadius"] = 0,
            ["sanctuaryAdjacency"] = "AlloyExtractorAdjacencyBuff",
            ["sanctuaryUpgradesTo"] = "ues2601",
            ["sourceActiveLoopSupported"] = false,
            ["sourceAdjacency"] = "T1MassExtractorAdjacencyBuffs",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudioBanksImported"] = false,
            ["sourceBlueprint"] = "units/UEB1103/UEB1103_unit.bp",
            ["sourceBlueprintSha256"] = "86c7f83bd2c803cd1640e9a88785bf847aff377287ceabedbe7d7735083e55bf",
            ["sourceCommanderBuildCategoriesSupported"] = false,
            ["sourceEnergyStallAnimationSupported"] = true,
            ["sourcePauseResumeAnimationSupported"] = true,
            ["sourceProductionToggle"] = true,
            ["sourcePumpAnimationMapped"] = true,
            ["sourceScript"] = "units/UEB1103/UEB1103_script.lua",
            ["sourceScriptSha256"] = "0bc78e289e8912ab401f3fcede51cc89530e4ff10a913b2b0c52ff1625affa72",
            ["sourceUpgradeAnimationMapped"] = true,
            ["sourceUpgradesTo"] = "ueb1202",
            ["sourceVisionRadiusDeclared"] = false,
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "upgrade",
            ["durationSeconds"] = 4,
            ["restAnimationKey"] = "walk",
        },
        ["scoGameplayT1ExtractorVision"] = "1.1.0",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.42,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.31,
                ["y"] = 1.31,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.16,
            ["y"] = 1.16,
        },
    },
    ["adjacency"] = "AlloyExtractorAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.42,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.08,
            ["y"] = 2.22,
            ["z"] = 1.08,
        },
    },
    ["construction"] = {
        ["buildPower"] = 10,
        ["buildableOnResources"] = {
            [1] = "alloys",
        },
        ["canBuild"] = "(Tags.ues2601) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "ues2601",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 600,
            ["regen"] = 0,
            ["value"] = 600,
        },
    },
    ["economy"] = {
        ["buildTime"] = 60,
        ["cost"] = {
            ["alloys"] = 36,
            ["energy"] = 360,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 2,
        },
        ["production"] = {
            ["alloys"] = 2,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAImportedAnimatedAlloyExtractor",
        },
        ["displayName"] = "Mass Pump 1",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "alloy",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_alloy.png",
        ["iconUIBuildSortPriority"] = 370,
        ["iconUIType"] = "amphibious",
        ["name"] = "Mass Pump 1",
        ["orders"] = {
            ["Pause"] = false,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["Production"] = true,
        },
        ["tpId"] = "ues1601",
        ["unitTypeName"] = "EDAT1AlloyExtractor",
    },
    ["intel"] = {
        ["visionRadius"] = 15,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 15,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 15,
        },
    },
    ["skirtSize"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "ALLOYS_EXTRACTION",
        [2] = "BUILDABLE_BY_T1_ENGINEER",
        [3] = "BUILDABLE_BY_T2_ENGINEER",
        [4] = "BUILDABLE_BY_T3_ENGINEER",
        [5] = "CONSTRUCTION",
        [6] = "ECONOMIC",
        [7] = "EDA",
        [8] = "STRUCTURE",
        [9] = "TECH1",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_BUILTBYCOMMANDER",
        [12] = "SCFA_BUILTBYTIER1ENGINEER",
        [13] = "SCFA_BUILTBYTIER2ENGINEER",
        [14] = "SCFA_BUILTBYTIER3ENGINEER",
        [15] = "SCFA_ECONOMIC",
        [16] = "SCFA_MASSEXTRACTION",
        [17] = "SCFA_MASSPRODUCTION",
        [18] = "SCFA_PRODUCTSC1",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_SHOWQUEUE",
        [22] = "SCFA_SIZE4",
        [23] = "SCFA_SORTECONOMY",
        [24] = "SCFA_STRUCTURE",
        [25] = "SCFA_TECH1",
        [26] = "SCFA_UEF",
        [27] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues1601/LOD0/ues1601.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "AnimPump",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ues1601/LOD0/ues1601.sananimation",
            },
        },
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.19440000000000002,
                    ["y"] = 0.9750000000000001,
                    ["z"] = -0.21600000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.2376,
                    ["y"] = 0.8196,
                    ["z"] = 0.19440000000000002,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.21600000000000003,
                    ["y"] = 1.0416,
                    ["z"] = 0.1728,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.19440000000000002,
                    ["y"] = 1.3524,
                    ["z"] = -0.21600000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.2376,
                    ["y"] = 1.308,
                    ["z"] = 0.19440000000000002,
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
                ["y"] = 0.42,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.31,
                ["y"] = 1.31,
            },
        },
    },
}
