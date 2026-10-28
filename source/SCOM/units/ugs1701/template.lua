-- ugs1701: Magno
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["mapping"] = "URB3101 -> ugs1701",
            ["radarStateRotatorGateSupported"] = true,
            ["sanctuaryOmniRadiusSupported"] = false,
            ["sanctuaryRandomDishMotionSupported"] = false,
            ["sanctuaryReactivateTimeSupported"] = false,
            ["sanctuaryShowIntelOnSelectSupported"] = false,
            ["sanctuaryUpgradesTo"] = "ugs2701",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudioBanksImported"] = false,
            ["sourceBlueprint"] = "units/URB3101/URB3101_unit.bp",
            ["sourceBlueprintSha256"] = "9ad39baea926509e420f233c500da4d9180404fd93ee5035aa435d6cbc4627ce",
            ["sourceCommanderBuildCategoriesSupported"] = false,
            ["sourceEmitterGraphSupported"] = false,
            ["sourceRandomDishMotion"] = true,
            ["sourceRotatorAccelerationSupported"] = false,
            ["sourceScript"] = "units/URB3101/URB3101_script.lua",
            ["sourceScriptSha256"] = "64e0786f75876a4ad96b6a709f0b86d429dbf9b5f53c4cc3ff11984843ed434b",
            ["sourceShowIntelOnSelect"] = true,
            ["sourceUpgradeAnimationMapped"] = true,
            ["sourceUpgradesTo"] = "urb3201",
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "upgrade",
            ["durationSeconds"] = 6.66666650772095,
            ["restAnimationKey"] = "walk",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.67,
                ["z"] = 0.11,
            },
            ["size"] = {
                ["x"] = 1.92,
                ["y"] = 1.77,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.77,
            ["y"] = 1.62,
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
            ["y"] = 0.67,
            ["z"] = 0.11,
        },
        ["collisionSize"] = {
            ["x"] = 1.69,
            ["y"] = 4.21,
            ["z"] = 1.54,
        },
    },
    ["construction"] = {
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.ugs2701) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "ugs2701",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 10,
            ["regen"] = 0,
            ["value"] = 10,
        },
    },
    ["economy"] = {
        ["buildTime"] = 80,
        ["cost"] = {
            ["alloys"] = 80,
            ["energy"] = 720,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 20,
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
        ["displayName"] = "Magno",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "intel",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_intel.png",
        ["iconUIBuildSortPriority"] = 290,
        ["iconUIType"] = "land",
        ["name"] = "Magno",
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
        ["tpId"] = "ugs1701",
        ["unitTypeName"] = "GuardT1Radar",
    },
    ["intel"] = {
        ["radarRadius"] = 115,
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 115,
        },
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
        [1] = "BUILDABLE_BY_T1_ENGINEER",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "CONSTRUCTION",
        [5] = "GUARD",
        [6] = "INTEL",
        [7] = "RADAR",
        [8] = "STRUCTURE",
        [9] = "TECH1",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_BUILTBYTIER1ENGINEER",
        [12] = "SCFA_BUILTBYTIER2COMMANDER",
        [13] = "SCFA_BUILTBYTIER2ENGINEER",
        [14] = "SCFA_BUILTBYTIER3ENGINEER",
        [15] = "SCFA_CYBRAN",
        [16] = "SCFA_DRAGBUILD",
        [17] = "SCFA_INTELLIGENCE",
        [18] = "SCFA_OVERLAYRADAR",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RADAR",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_SELECTABLE",
        [23] = "SCFA_SHOWQUEUE",
        [24] = "SCFA_SIZE4",
        [25] = "SCFA_SORTINTEL",
        [26] = "SCFA_STRUCTURE",
        [27] = "SCFA_TECH1",
        [28] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs1701/LOD0/ugs1701.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs1701/LOD0/ugs1701.sananimation",
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
                    ["x"] = 0.30419999999999997,
                    ["y"] = 1.7225000000000001,
                    ["z"] = -0.19800000000000006,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.37179999999999996,
                    ["y"] = 1.4278,
                    ["z"] = 0.3872,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.338,
                    ["y"] = 1.8488000000000002,
                    ["z"] = 0.3564,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.30419999999999997,
                    ["y"] = 2.4382,
                    ["z"] = -0.19800000000000006,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.37179999999999996,
                    ["y"] = 2.354,
                    ["z"] = 0.3872,
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
                ["y"] = 0.67,
                ["z"] = 0.11,
            },
            ["size"] = {
                ["x"] = 1.92,
                ["y"] = 1.77,
            },
        },
    },
}
