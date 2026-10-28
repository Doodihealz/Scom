-- ugs2601: Mass Extractor
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["mapping"] = "URB1202 -> ugs2601",
            ["resolvedSourceVisionRadius"] = 20,
            ["sanctuaryAdjacency"] = "AlloyExtractorAdjacencyBuff",
            ["sanctuaryUpgradesTo"] = "ugs3601",
            ["sourceActiveLoopSupported"] = false,
            ["sourceAdjacency"] = "T2MassExtractorAdjacencyBuffs",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudioBanksImported"] = false,
            ["sourceBlueprint"] = "units/URB1202/URB1202_unit.bp",
            ["sourceBlueprintSha256"] = "b89469f2fa005d292b134e78aa46bf36d3ba3693085bf4b2a991d84635924a9c",
            ["sourceCommanderBuildCategoriesSupported"] = false,
            ["sourceEnergyStallAnimationSupported"] = true,
            ["sourcePauseResumeAnimationSupported"] = true,
            ["sourceProductionToggle"] = true,
            ["sourcePumpAnimationMapped"] = true,
            ["sourceScript"] = "units/URB1202/URB1202_script.lua",
            ["sourceScriptSha256"] = "415f197ffaf57d3983f9528984f6bce30b90c88137e605d6d5d7187c608a885b",
            ["sourceUpgradeAnimationMapped"] = true,
            ["sourceUpgradesTo"] = "urb1302",
            ["sourceVisionRadiusDeclared"] = true,
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "upgrade",
            ["durationSeconds"] = 3.33333325386047,
            ["restAnimationKey"] = "walk",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.11,
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
            ["name"] = "agod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1.11,
            ["z"] = -0.1,
        },
        ["collisionSize"] = {
            ["x"] = 1.21,
            ["y"] = 2.67,
            ["z"] = 1.08,
        },
    },
    ["construction"] = {
        ["buildPower"] = 15,
        ["buildableOnResources"] = {
            [1] = "alloys",
        },
        ["canBuild"] = "(Tags.ugs3601) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "ugs3601",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 3000,
            ["regen"] = 0,
            ["value"] = 3000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 900,
        ["cost"] = {
            ["alloys"] = 900,
            ["energy"] = 5400,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 9,
        },
        ["production"] = {
            ["alloys"] = 6,
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
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_alloy.png",
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
        ["tpId"] = "ugs2601",
        ["unitTypeName"] = "GuardT2AlloyExtractor",
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
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "CONSTRUCTION",
        [5] = "ECONOMIC",
        [6] = "GUARD",
        [7] = "STRUCTURE",
        [8] = "TECH2",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER2COMMANDER",
        [11] = "SCFA_BUILTBYTIER2ENGINEER",
        [12] = "SCFA_BUILTBYTIER3COMMANDER",
        [13] = "SCFA_BUILTBYTIER3ENGINEER",
        [14] = "SCFA_CYBRAN",
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
        [25] = "SCFA_TECH2",
        [26] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs2601/LOD0/ugs2601.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "AnimPump",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ugs2601/LOD0/ugs2601.sananimation",
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
                    ["y"] = 1.7775,
                    ["z"] = -0.31600000000000006,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.2662,
                    ["y"] = 1.5906,
                    ["z"] = 0.09440000000000001,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.242,
                    ["y"] = 1.8576000000000001,
                    ["z"] = 0.0728,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2178,
                    ["y"] = 2.2314,
                    ["z"] = -0.31600000000000006,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.2662,
                    ["y"] = 2.178,
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
                ["y"] = 1.11,
                ["z"] = -0.1,
            },
            ["size"] = {
                ["x"] = 1.44,
                ["y"] = 1.31,
            },
        },
    },
}
