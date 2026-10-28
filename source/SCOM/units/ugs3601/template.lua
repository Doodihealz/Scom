-- ugs3601: Mass Extractor
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["mapping"] = "URB1302 -> ugs3601",
            ["resolvedSourceVisionRadius"] = 20,
            ["sanctuaryAdjacency"] = "AlloyExtractorAdjacencyBuff",
            ["sourceActiveLoopSupported"] = false,
            ["sourceAdjacency"] = "T3MassExtractorAdjacencyBuffs",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudioBanksImported"] = false,
            ["sourceBlueprint"] = "units/URB1302/URB1302_unit.bp",
            ["sourceBlueprintSha256"] = "8e6c44d30877de9829061ac604f160ed81797698d6bed13c3580dc98ea5baf8c",
            ["sourceCommanderBuildCategoriesSupported"] = false,
            ["sourceEnergyStallAnimationSupported"] = true,
            ["sourcePauseResumeAnimationSupported"] = true,
            ["sourceProductionToggle"] = true,
            ["sourcePumpAnimationMapped"] = true,
            ["sourceScript"] = "units/URB1302/URB1302_script.lua",
            ["sourceScriptSha256"] = "9028c6b987da4164e97fdd9dbecc39abb1a8a40efbebbfc61d2a9264f45e9ebc",
            ["sourceUpgradeAnimationMapped"] = false,
            ["sourceVisionRadiusDeclared"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.13,
                ["z"] = -0.2,
            },
            ["size"] = {
                ["x"] = 1.81,
                ["y"] = 1.62,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.66,
            ["y"] = 1.47,
        },
    },
    ["adjacency"] = "AlloyExtractorAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1.13,
            ["z"] = -0.2,
        },
        ["collisionSize"] = {
            ["x"] = 1.58,
            ["y"] = 2.4,
            ["z"] = 1.39,
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
            [1] = "unitsDefaultGuard",
            [2] = "GuardImportedAnimatedAlloyExtractor",
        },
        ["displayName"] = "Mass Extractor",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "alloy",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_alloy.png",
        ["iconUIBuildSortPriority"] = 370,
        ["iconUIType"] = "amphibious",
        ["name"] = "Mass Extractor",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["Production"] = true,
        },
        ["tpId"] = "ugs3601",
        ["unitTypeName"] = "GuardT3AlloyExtractor",
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
        [4] = "GUARD",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER3COMMANDER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_CYBRAN",
        [11] = "SCFA_ECONOMIC",
        [12] = "SCFA_MASSEXTRACTION",
        [13] = "SCFA_MASSPRODUCTION",
        [14] = "SCFA_PRODUCTSC1",
        [15] = "SCFA_RECLAIMABLE",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SIZE4",
        [18] = "SCFA_SORTECONOMY",
        [19] = "SCFA_STRUCTURE",
        [20] = "SCFA_TECH3",
        [21] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "AnimPump",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ugs3601/LOD0/ugs3601.sananimation",
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
                    ["particleName"] = "VFX/Death/vgd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2844,
                    ["y"] = 1.73,
                    ["z"] = -0.478,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.3476,
                    ["y"] = 1.5619999999999998,
                    ["z"] = 0.05019999999999997,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.31600000000000006,
                    ["y"] = 1.802,
                    ["z"] = 0.022399999999999975,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2844,
                    ["y"] = 2.138,
                    ["z"] = -0.478,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.3476,
                    ["y"] = 2.09,
                    ["z"] = 0.05019999999999997,
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
                ["y"] = 1.13,
                ["z"] = -0.2,
            },
            ["size"] = {
                ["x"] = 1.81,
                ["y"] = 1.62,
            },
        },
    },
}
