-- ugs1601: Mass Extractor
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["mapping"] = "URB1103 -> ugs1601",
            ["resolvedSourceVisionRadius"] = 0,
            ["sanctuaryAdjacency"] = "AlloyExtractorAdjacencyBuff",
            ["sanctuaryUpgradesTo"] = "ugs2601",
            ["sourceActiveLoopSupported"] = false,
            ["sourceAdjacency"] = "T1MassExtractorAdjacencyBuffs",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudioBanksImported"] = false,
            ["sourceBlueprint"] = "units/URB1103/URB1103_unit.bp",
            ["sourceBlueprintSha256"] = "e723b2d7f3b916bd24f46587a9ef7c3691b60265830553bb234505cd162db1ef",
            ["sourceCommanderBuildCategoriesSupported"] = false,
            ["sourceEnergyStallAnimationSupported"] = true,
            ["sourcePauseResumeAnimationSupported"] = true,
            ["sourceProductionToggle"] = true,
            ["sourcePumpAnimationMapped"] = true,
            ["sourceScript"] = "units/URB1103/URB1103_script.lua",
            ["sourceScriptSha256"] = "4cb15562c13b6c34b7ac751aadd39f36e67f62ae4ea2bd1e2a3dac3b01055078",
            ["sourceUpgradeAnimationMapped"] = true,
            ["sourceUpgradesTo"] = "urb1202",
            ["sourceVisionRadiusDeclared"] = false,
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "upgrade",
            ["durationSeconds"] = 4.33333349227905,
            ["restAnimationKey"] = "walk",
        },
        ["scoGameplayT1ExtractorVision"] = "1.1.0",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.76,
                ["z"] = -0.1,
            },
            ["size"] = {
                ["x"] = 1.44,
                ["y"] = 1.31,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.29,
            ["y"] = 1.16,
        },
    },
    ["adjacency"] = "AlloyExtractorAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.76,
            ["z"] = -0.1,
        },
        ["collisionSize"] = {
            ["x"] = 1.21,
            ["y"] = 2.67,
            ["z"] = 1.08,
        },
    },
    ["construction"] = {
        ["buildPower"] = 10,
        ["buildableOnResources"] = {
            [1] = "alloys",
        },
        ["canBuild"] = "(Tags.ugs2601) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "ugs2601",
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
            [1] = "unitsDefaultGuard",
            [2] = "GuardImportedAnimatedAlloyExtractor",
        },
        ["displayName"] = "Mass Extractor",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "alloy",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_alloy.png",
        ["iconUIBuildSortPriority"] = 370,
        ["iconUIType"] = "amphibious",
        ["name"] = "Mass Extractor",
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
        ["tpId"] = "ugs1601",
        ["unitTypeName"] = "GuardT1AlloyExtractor",
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
        [7] = "GUARD",
        [8] = "STRUCTURE",
        [9] = "TECH1",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_BUILTBYCOMMANDER",
        [12] = "SCFA_BUILTBYTIER1ENGINEER",
        [13] = "SCFA_BUILTBYTIER2ENGINEER",
        [14] = "SCFA_BUILTBYTIER3ENGINEER",
        [15] = "SCFA_CYBRAN",
        [16] = "SCFA_ECONOMIC",
        [17] = "SCFA_MASSEXTRACTION",
        [18] = "SCFA_MASSPRODUCTION",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SHOWQUEUE",
        [23] = "SCFA_SIZE4",
        [24] = "SCFA_SORTECONOMY",
        [25] = "SCFA_STRUCTURE",
        [26] = "SCFA_TECH1",
        [27] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs1601/LOD0/ugs1601.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "AnimPump",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ugs1601/LOD0/ugs1601.sananimation",
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
                    ["x"] = 0.2178,
                    ["y"] = 1.4275,
                    ["z"] = -0.31600000000000006,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.2662,
                    ["y"] = 1.2406,
                    ["z"] = 0.09440000000000001,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.242,
                    ["y"] = 1.5076,
                    ["z"] = 0.0728,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2178,
                    ["y"] = 1.8814,
                    ["z"] = -0.31600000000000006,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.2662,
                    ["y"] = 1.828,
                    ["z"] = 0.09440000000000001,
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
                ["y"] = 0.76,
                ["z"] = -0.1,
            },
            ["size"] = {
                ["x"] = 1.44,
                ["y"] = 1.31,
            },
        },
    },
}
