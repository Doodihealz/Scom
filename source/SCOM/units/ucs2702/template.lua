-- ucs2702: Sonar System
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["kind"] = "upgrade_only",
            ["mapping"] = "UAB3202 -> ucs2702",
            ["rotatorCount"] = 0,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB3202/UAB3202_unit.bp",
            ["sourceBlueprintSha256"] = "d2ec861ba7994346569793b39236cfc8c4447adf80f3cdfc2cb8770511c2baa5",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 2.5,
                    ["frames"] = 76,
                    ["key"] = "source_animopen",
                    ["name"] = "AnimOpen",
                    ["rate"] = 1,
                    ["role"] = "upgrade",
                    ["sha256"] = "fae36b9e142d17e43ccbdb226f784217dd88639495650e6722fb5b145d3cee70",
                    ["source"] = "units/UAB3202/UAB3202_Aopen.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "e0dee3f0eaa163721e96fae62d8fae44318333c20e8be7c4741b2e963a593955",
            ["sourceScript"] = "units/UAB3202/UAB3202_script.lua",
            ["sourceScriptSha256"] = "721e8c0b54a7e60d0aac00cb6f96f4ce841a484875a16336920c925f1edeef06",
            ["stateOwner"] = "No invented idle motion; AnimOpen is owned only by upgrade progress.",
            ["targetAnimation"] = {
                ["bytes"] = 253606,
                ["path"] = "Units/ucs2702/LOD0/ucs2702.sananimation",
                ["sha256"] = "25599a63bbe1ec4c4d751bfe6fc90fe97f32b16bf69703e8c755298aaefe4d78",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 304913,
                ["path"] = "Units/ucs2702/LOD0/ucs2702_lod0.sanmodel",
                ["sha256"] = "740cee74f51c28f113fbea2160d4aabd9d14255cce1e050269ccb02ebb650688",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 17847,
                ["path"] = "Units/ucs2702/LOD0/ucs2702.sanskeleton",
                ["sha256"] = "fe557c78b29d7a5d138ef622efd67a0bb07131e0b8bd8654b5a3c7a2cc3575ab",
            },
            ["version"] = "1.0.2",
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {
                    ["showIntelOnSelect"] = true,
                    ["sonarRadius"] = 230,
                },
                ["runtimeSupported"] = {
                    ["visionRadius"] = 25,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 1,
                    ["z"] = 1,
                },
                ["footprintSource"] = "Physics.SkirtSizeFallback",
                ["sourceSkirt"] = {
                    ["offsetX"] = 0,
                    ["offsetZ"] = 0,
                    ["sizeX"] = 1,
                    ["sizeZ"] = 1,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB3202/UAB3202_unit.bp",
            ["sourceBlueprintSha256"] = "d2ec861ba7994346569793b39236cfc8c4447adf80f3cdfc2cb8770511c2baa5",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER2COMMANDER",
                [3] = "BUILTBYTIER2ENGINEER",
                [4] = "BUILTBYTIER3COMMANDER",
                [5] = "BUILTBYTIER3ENGINEER",
                [6] = "DRAGBUILD",
                [7] = "INTELLIGENCE",
                [8] = "OVERLAYSONAR",
                [9] = "PRODUCTSC1",
                [10] = "RECLAIMABLE",
                [11] = "SELECTABLE",
                [12] = "SHOWQUEUE",
                [13] = "SIZE4",
                [14] = "SONAR",
                [15] = "SORTINTEL",
                [16] = "STRUCTURE",
                [17] = "TECH2",
                [18] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB3202",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "UAB3102",
            ["sourceUpgradeTo"] = "UAS0305",
            ["targetId"] = "ucs2702",
            ["weapons"] = {},
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "source_animopen",
            ["durationSeconds"] = 2.5,
            ["restAnimationKey"] = "walk",
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixAeonUpgradeRouting"] = {
            ["target"] = "ucl3701",
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.55,
                ["y"] = 0.55,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.5,
            ["y"] = 0.5,
            ["z"] = 0.5,
        },
    },
    ["construction"] = {
        ["buildPower"] = 15,
        ["canBuild"] = "(Tags.ucl3701) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "ucl3701",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1000,
            ["regen"] = 0,
            ["value"] = 1000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 600,
        ["cost"] = {
            ["alloys"] = 120,
            ["energy"] = 3600,
        },
        ["maintenanceConsumption"] = {
            ["alloys"] = 0,
            ["energy"] = 100,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortStructure",
        },
        ["displayName"] = "Sonar System",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "water",
        ["name"] = "Sonar System",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["tpId"] = "ucs2702",
        ["unitTypeName"] = "Sonar System",
    },
    ["intel"] = {
        ["visionRadius"] = 25,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 25,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 25,
        },
    },
    ["skirtSize"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_ENGINEER",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "CHOSEN",
        [4] = "STRUCTURE",
        [5] = "TECH2",
        [6] = "SCFA_AEON",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER2COMMANDER",
        [9] = "SCFA_BUILTBYTIER2ENGINEER",
        [10] = "SCFA_BUILTBYTIER3COMMANDER",
        [11] = "SCFA_BUILTBYTIER3ENGINEER",
        [12] = "SCFA_DRAGBUILD",
        [13] = "SCFA_INTELLIGENCE",
        [14] = "SCFA_OVERLAYSONAR",
        [15] = "SCFA_PRODUCTSC1",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_SHOWQUEUE",
        [19] = "SCFA_SIZE4",
        [20] = "SCFA_SONAR",
        [21] = "SCFA_SORTINTEL",
        [22] = "SCFA_STRUCTURE",
        [23] = "SCFA_TECH2",
        [24] = "SCFA_VISIBLETORECON",
        [25] = "NAVAL",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animopen"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2702/LOD0/ucs2702.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2702/LOD0/ucs2702.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
            },
            ["mainBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 20,
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.125,
                    ["z"] = -0.1,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.09,
                    ["z"] = 0.09,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.1,
                    ["y"] = 0.14,
                    ["z"] = 0.08,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.21,
                    ["z"] = -0.1,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.2,
                    ["z"] = 0.09,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 67,
            ["lod1distance"] = 175,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.55,
                ["y"] = 0.55,
            },
        },
    },
}
