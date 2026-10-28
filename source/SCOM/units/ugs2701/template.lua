-- ugs2701: Magno XR
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["mapping"] = "URB3201 -> ugs2701",
            ["radarStateRotatorGateSupported"] = true,
            ["sanctuaryOmniRadiusSupported"] = false,
            ["sanctuaryRandomDishMotionSupported"] = false,
            ["sanctuaryReactivateTimeSupported"] = false,
            ["sanctuaryShowIntelOnSelectSupported"] = false,
            ["sanctuaryUpgradesTo"] = "ugs3701",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudioBanksImported"] = false,
            ["sourceBlueprint"] = "units/URB3201/URB3201_unit.bp",
            ["sourceBlueprintSha256"] = "3863c2abaae011903c08ba6921bec62e995c043fee8591d81591a807d5ba4b32",
            ["sourceCommanderBuildCategoriesSupported"] = false,
            ["sourceEmitterGraphSupported"] = false,
            ["sourceRandomDishMotion"] = true,
            ["sourceRotatorAccelerationSupported"] = false,
            ["sourceScript"] = "units/URB3201/URB3201_script.lua",
            ["sourceScriptSha256"] = "42f30013928cd63e8de2c72540b9e20f40ae842ba40fb5d3b46e1fe8427fab17",
            ["sourceShowIntelOnSelect"] = true,
            ["sourceUpgradeAnimationMapped"] = true,
            ["sourceUpgradesTo"] = "urb3104",
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "upgrade",
            ["durationSeconds"] = 6.65000009536743,
            ["restAnimationKey"] = "walk",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.81,
                ["z"] = 0.13,
            },
            ["size"] = {
                ["x"] = 1.99,
                ["y"] = 1.81,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.84,
            ["y"] = 1.66,
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1.81,
            ["z"] = 0.13,
        },
        ["collisionSize"] = {
            ["x"] = 1.76,
            ["y"] = 4.66,
            ["z"] = 1.58,
        },
    },
    ["construction"] = {
        ["buildPower"] = 15,
        ["canBuild"] = "(Tags.ugs3701) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "ugs3701",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 50,
            ["regen"] = 0,
            ["value"] = 50,
        },
    },
    ["economy"] = {
        ["buildTime"] = 600,
        ["cost"] = {
            ["alloys"] = 180,
            ["energy"] = 3600,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 250,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardImportedAnimatedStructure",
        },
        ["displayName"] = "Magno XR",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "intel",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_intel.png",
        ["iconUIBuildSortPriority"] = 290,
        ["iconUIType"] = "land",
        ["name"] = "Magno XR",
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
            ["Intel"] = true,
            ["Pause"] = false,
        },
        ["tpId"] = "ugs2701",
        ["unitTypeName"] = "GuardT2Radar",
    },
    ["intel"] = {
        ["radarRadius"] = 200,
        ["visionRadius"] = 25,
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 200,
        },
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
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_ENGINEER",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "CONSTRUCTION",
        [4] = "GUARD",
        [5] = "INTEL",
        [6] = "RADAR",
        [7] = "STRUCTURE",
        [8] = "TECH2",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER2COMMANDER",
        [11] = "SCFA_BUILTBYTIER2ENGINEER",
        [12] = "SCFA_BUILTBYTIER3COMMANDER",
        [13] = "SCFA_BUILTBYTIER3ENGINEER",
        [14] = "SCFA_CYBRAN",
        [15] = "SCFA_DRAGBUILD",
        [16] = "SCFA_INTELLIGENCE",
        [17] = "SCFA_OVERLAYRADAR",
        [18] = "SCFA_PRODUCTSC1",
        [19] = "SCFA_RADAR",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SHOWQUEUE",
        [23] = "SCFA_SIZE4",
        [24] = "SCFA_SORTINTEL",
        [25] = "SCFA_STRUCTURE",
        [26] = "SCFA_TECH2",
        [27] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs2701/LOD0/ugs2701.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs2701/LOD0/ugs2701.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.31679999999999997,
                    ["y"] = 2.975,
                    ["z"] = -0.18600000000000005,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.3872,
                    ["y"] = 2.6488,
                    ["z"] = 0.4144,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.35200000000000004,
                    ["y"] = 3.1148000000000002,
                    ["z"] = 0.38280000000000003,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.31679999999999997,
                    ["y"] = 3.7672,
                    ["z"] = -0.18600000000000005,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.3872,
                    ["y"] = 3.6740000000000004,
                    ["z"] = 0.4144,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 82,
            ["lod1distance"] = 215,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.81,
                ["z"] = 0.13,
            },
            ["size"] = {
                ["x"] = 1.99,
                ["y"] = 1.81,
            },
        },
    },
}
