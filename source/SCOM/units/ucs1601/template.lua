-- ucs1601: Mass Extractor
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["kind"] = "pump_loop_upgrade",
            ["mapping"] = "UAB1103 -> ucs1601",
            ["primaryClip"] = {
                ["durationSeconds"] = 12.666667,
                ["key"] = "source_animpump",
                ["rate"] = 1,
            },
            ["rotatorCount"] = 0,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB1103/UAB1103_unit.bp",
            ["sourceBlueprintSha256"] = "a689422b2297f98499348c07ad287c27814ca9c136c92043e055e16f82e3989f",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 12.666667,
                    ["frames"] = 381,
                    ["key"] = "source_animpump",
                    ["name"] = "AnimPump",
                    ["rate"] = 1,
                    ["role"] = "pump",
                    ["sha256"] = "75d3f6b37d616d7fbc20519425ec5173e1dfda10cd6ab71fd752530ecaf3cb6d",
                    ["source"] = "units/UAB1103/UAB1103_Apump.sca",
                },
                [2] = {
                    ["durationSeconds"] = 3.5,
                    ["frames"] = 106,
                    ["key"] = "source_animupgrade",
                    ["name"] = "AnimUpgrade",
                    ["rate"] = 1,
                    ["role"] = "upgrade",
                    ["sha256"] = "40192f14f26e517abf9d579880cbd8c14cf33507ea17b1e154bc9d245b68d2fc",
                    ["source"] = "units/UAB1103/UAB1103_Aupgrade.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "6183974a52f300f90d01bffa0771715cefee5f90157fe598438932b9ef48097e",
            ["sourceScript"] = "units/UAB1103/UAB1103_script.lua",
            ["sourceScriptSha256"] = "9a14e34fa9fe6bccacb3e1e1ad60ed7333344460e93570086f2a14d94559be65",
            ["stateOwner"] = "Original AnimPump preserves the authored 12.666667-second Shaft rotation and 0.75-unit vertical pump stroke; continuous pump clocks let native Loop playback cross the cycle seam, production pause freezes the exact source time, upgrade yields ownership, and AnimUpgrade remains progress-bound.",
            ["targetAnimation"] = {
                ["bytes"] = 1063968,
                ["path"] = "Units/ucs1601/LOD0/ucs1601.sananimation",
                ["sha256"] = "1e619db040eba68cc459a6bbd105fa5b5f94fae2d7c1fcb7291d2028bdcf4b45",
            },
            ["targetClipCount"] = 3,
            ["targetModel"] = {
                ["bytes"] = 281193,
                ["path"] = "Units/ucs1601/LOD0/ucs1601_lod0.sanmodel",
                ["sha256"] = "cd477dfeac0483498cc984a681c333ff2786998b666a94922ebd2b1aae5b5007",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 12387,
                ["path"] = "Units/ucs1601/LOD0/ucs1601.sanskeleton",
                ["sha256"] = "1bdefc098412170de5244cc264cec521f8befa1b8fdf505dfca9aa4e67da995f",
            },
            ["version"] = "1.0.2",
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
                    ["x"] = 2,
                    ["z"] = 2,
                },
                ["footprintSource"] = "Physics.SkirtSizeFallback",
                ["sourceSkirt"] = {
                    ["offsetX"] = -0.5,
                    ["offsetZ"] = -0.5,
                    ["sizeX"] = 2,
                    ["sizeZ"] = 2,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB1103/UAB1103_unit.bp",
            ["sourceBlueprintSha256"] = "a689422b2297f98499348c07ad287c27814ca9c136c92043e055e16f82e3989f",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYCOMMANDER",
                [3] = "BUILTBYTIER1ENGINEER",
                [4] = "BUILTBYTIER2ENGINEER",
                [5] = "BUILTBYTIER3ENGINEER",
                [6] = "ECONOMIC",
                [7] = "MASSEXTRACTION",
                [8] = "MASSPRODUCTION",
                [9] = "PRODUCTSC1",
                [10] = "RECLAIMABLE",
                [11] = "SELECTABLE",
                [12] = "SHOWQUEUE",
                [13] = "SIZE4",
                [14] = "SORTECONOMY",
                [15] = "STRUCTURE",
                [16] = "TECH1",
                [17] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB1103",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "UAB1202",
            ["targetId"] = "ucs1601",
            ["weapons"] = {},
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "source_animupgrade",
            ["durationSeconds"] = 3.5,
            ["restAnimationKey"] = "walk",
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixAeonUpgradeRouting"] = {
            ["target"] = "ucs2601",
            ["version"] = "1.0.0",
        },
        ["scoGameplayT1ExtractorVision"] = "1.1.0",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.7,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
        },
    },
    ["adjacency"] = "AlloyExtractorAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.7,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.75,
            ["y"] = 1.4,
            ["z"] = 0.75,
        },
    },
    ["construction"] = {
        ["buildPower"] = 10,
        ["buildableOnResources"] = {
            [1] = "alloys",
        },
        ["canBuild"] = "(Tags.ucs2601) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "ucs2601",
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
            ["alloys"] = 0,
            ["energy"] = 2,
        },
        ["production"] = {
            ["alloys"] = 2,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortAlloyExtractor",
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
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "ucs1601",
        ["unitTypeName"] = "Mass Extractor",
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
        [2] = "ALLOYS_PRODUCTION",
        [3] = "BUILDABLE_BY_T1_ENGINEER",
        [4] = "BUILDABLE_BY_T2_ENGINEER",
        [5] = "BUILDABLE_BY_T3_ENGINEER",
        [6] = "CHOSEN",
        [7] = "ECONOMIC",
        [8] = "STRUCTURE",
        [9] = "TECH1",
        [10] = "SCFA_AEON",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYCOMMANDER",
        [13] = "SCFA_BUILTBYTIER1ENGINEER",
        [14] = "SCFA_BUILTBYTIER2ENGINEER",
        [15] = "SCFA_BUILTBYTIER3ENGINEER",
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
            ["source_animpump"] = {
                ["clipName"] = "AnimPump",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/ucs1601/LOD0/ucs1601.sananimation",
            },
            ["source_animupgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1601/LOD0/ucs1601.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1601/LOD0/ucs1601.sananimation",
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
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.135,
                    ["y"] = 1.0499999999999998,
                    ["z"] = -0.15000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.165,
                    ["y"] = 0.952,
                    ["z"] = 0.135,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.15000000000000002,
                    ["y"] = 1.092,
                    ["z"] = 0.12,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.135,
                    ["y"] = 1.2879999999999998,
                    ["z"] = -0.15000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.165,
                    ["y"] = 1.2599999999999998,
                    ["z"] = 0.135,
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
                ["y"] = 0.7,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
        },
    },
}
