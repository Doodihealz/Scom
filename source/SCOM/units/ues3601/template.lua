-- ues3601: Mass Pump 3
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["mapping"] = "UEB1302 -> ues3601",
            ["resolvedSourceVisionRadius"] = 20,
            ["sanctuaryAdjacency"] = "AlloyExtractorAdjacencyBuff",
            ["sourceActiveLoopSupported"] = false,
            ["sourceAdjacency"] = "T3MassExtractorAdjacencyBuffs",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudioBanksImported"] = false,
            ["sourceBlueprint"] = "units/UEB1302/UEB1302_unit.bp",
            ["sourceBlueprintSha256"] = "4f488f277b85b44ea8d422228e936d2933e8e667b690e633e89a13e6560558ef",
            ["sourceCommanderBuildCategoriesSupported"] = false,
            ["sourceEnergyStallAnimationSupported"] = true,
            ["sourcePauseResumeAnimationSupported"] = true,
            ["sourceProductionToggle"] = true,
            ["sourcePumpAnimationMapped"] = true,
            ["sourceScript"] = "units/UEB1302/UEB1302_script.lua",
            ["sourceScriptSha256"] = "42ca7242bb5362e5f396dd628e144df3b14789491c8d20bcc84669ae8eed3849",
            ["sourceUpgradeAnimationMapped"] = false,
            ["sourceVisionRadiusDeclared"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.84,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.66,
                ["y"] = 1.31,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.51,
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
            ["y"] = 0.84,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.43,
            ["y"] = 1.82,
            ["z"] = 1.08,
        },
    },
    ["construction"] = {
        ["buildableOnResources"] = {
            [1] = "alloys",
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 8400,
            ["regen"] = 0,
            ["value"] = 8400,
        },
    },
    ["economy"] = {
        ["buildTime"] = 2875,
        ["cost"] = {
            ["alloys"] = 4600,
            ["energy"] = 31625,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 54,
        },
        ["production"] = {
            ["alloys"] = 18,
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
        ["displayName"] = "Mass Pump 3",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "alloy",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_alloy.png",
        ["iconUIBuildSortPriority"] = 370,
        ["iconUIType"] = "amphibious",
        ["name"] = "Mass Pump 3",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["Production"] = true,
        },
        ["tpId"] = "ues3601",
        ["unitTypeName"] = "EDAT3AlloyExtractor",
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
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "ALLOYS_EXTRACTION",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "ECONOMIC",
        [4] = "EDA",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER3COMMANDER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_ECONOMIC",
        [11] = "SCFA_MASSEXTRACTION",
        [12] = "SCFA_MASSPRODUCTION",
        [13] = "SCFA_PRODUCTSC1",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SIZE4",
        [17] = "SCFA_SORTECONOMY",
        [18] = "SCFA_STRUCTURE",
        [19] = "SCFA_TECH3",
        [20] = "SCFA_UEF",
        [21] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "AnimPump",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ues3601/LOD0/ues3601.sananimation",
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
                    ["x"] = 0.25739999999999996,
                    ["y"] = 1.295,
                    ["z"] = -0.21600000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.3146,
                    ["y"] = 1.1676,
                    ["z"] = 0.19440000000000002,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.286,
                    ["y"] = 1.3496000000000001,
                    ["z"] = 0.1728,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.25739999999999996,
                    ["y"] = 1.6044,
                    ["z"] = -0.21600000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.3146,
                    ["y"] = 1.568,
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
                ["y"] = 0.84,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.66,
                ["y"] = 1.31,
            },
        },
    },
}
