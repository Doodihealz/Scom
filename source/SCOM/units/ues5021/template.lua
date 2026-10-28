-- ues5021: SP2 - 2000
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["fuelIntentionallyOmitted"] = false,
            ["runtimeBehaviorApproval"] = false,
            ["sourceAir"] = {},
            ["sourceAnimations"] = {
                [1] = {
                    ["archive"] = "units.scd",
                    ["bindPoseTracks"] = {},
                    ["blueprintUses"] = {
                        [1] = ".Display.AnimationUpgrade",
                    },
                    ["bytes"] = 30722,
                    ["clipName"] = "FaUEB3202Aupgrade",
                    ["duration"] = 1.6666666269302368,
                    ["entry"] = "units/UEB3202/UEB3202_Aupgrade.sca",
                    ["frames"] = 51,
                    ["outputDuration"] = 1.6666666269302368,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "9632bdbe306d45cd80da9d2ca33889b629442901050a6fdc5742a76940854917",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 21,
                    ["usedBySource"] = true,
                },
            },
            ["sourceBlueprint"] = "units/UEB3202/UEB3202_unit.bp",
            ["sourceBlueprintSha256"] = "96d9618c3d88fe6582e3bfb814dd0a582bf19533a9861cac74b93ce37bfa2020",
            ["sourceBuildableCategory"] = {
                [1] = "ues0305",
            },
            ["sourceId"] = "UEB3202",
            ["sourceIntel"] = {
                ["ReactivateTime"] = 10,
                ["ShowIntelOnSelect"] = true,
                ["SonarRadius"] = 230,
                ["VisionRadius"] = 25,
            },
            ["sourceMovement"] = {
                ["BankingSlope"] = 0,
                ["BuildOnLayerCaps"] = {
                    ["LAYER_Air"] = false,
                    ["LAYER_Land"] = false,
                    ["LAYER_Orbit"] = false,
                    ["LAYER_Seabed"] = false,
                    ["LAYER_Sub"] = false,
                    ["LAYER_Water"] = true,
                },
                ["DragCoefficient"] = 0.2,
                ["MaxSteerForce"] = 0,
                ["MeshExtentsOffsetY"] = -1.5,
                ["MeshExtentsX"] = 1.25,
                ["MeshExtentsY"] = 2.5,
                ["MeshExtentsZ"] = 1.25,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_None",
                ["SkirtOffsetX"] = 0,
                ["SkirtOffsetZ"] = 0,
                ["SkirtSizeX"] = 1,
                ["SkirtSizeZ"] = 1,
                ["TurnRate"] = 0,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 801,
                ["entry"] = "units/UEB3202/UEB3202_script.lua",
                ["sha256"] = "ffbb12e15c9454c7a16b95d8f2f8ade6c7516f1f4ff5e05fb276a4abcee0e15d",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ues5021",
            ["unsupportedWeaponBindings"] = {},
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.5,
            ["y"] = 0.5,
            ["z"] = 0.5,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Root",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 15,
        ["canBuild"] = "(Tags.uen3005) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
        ["upgradesTo"] = "uen3005",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1400,
            ["regen"] = 0,
            ["value"] = 1400,
        },
    },
    ["economy"] = {
        ["buildTime"] = 600,
        ["cost"] = {
            ["alloys"] = 120,
            ["energy"] = 3600,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 100,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "SP2 - 2000",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 190,
        ["iconUIType"] = "water",
        ["name"] = "SP2 - 2000",
        ["orders"] = {},
        ["tpId"] = "ues5021",
    },
    ["intel"] = {
        ["sonarRadius"] = 230,
        ["visionRadius"] = 25,
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 5,
        },
        [3] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 230,
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
        ["x"] = 1,
        ["y"] = 1,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_ENGINEER",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "EDA",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_BUILTBYTIER2COMMANDER",
        [6] = "SCFA_BUILTBYTIER2ENGINEER",
        [7] = "SCFA_BUILTBYTIER3COMMANDER",
        [8] = "SCFA_BUILTBYTIER3ENGINEER",
        [9] = "SCFA_DRAGBUILD",
        [10] = "SCFA_INTELLIGENCE",
        [11] = "SCFA_OVERLAYSONAR",
        [12] = "SCFA_PRODUCTSC1",
        [13] = "SCFA_RECLAIMABLE",
        [14] = "SCFA_SELECTABLE",
        [15] = "SCFA_SHOWQUEUE",
        [16] = "SCFA_SIZE4",
        [17] = "SCFA_SONAR",
        [18] = "SCFA_SORTINTEL",
        [19] = "SCFA_STRUCTURE",
        [20] = "SCFA_TECH2",
        [21] = "SCFA_UEF",
        [22] = "SCFA_VISIBLETORECON",
        [23] = "STRUCTURE",
        [24] = "TECH2",
        [25] = "NAVAL",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5021/LOD0/ues5021.sananimation",
            },
            ["upgrade"] = {
                ["clipName"] = "FaUEB3202Aupgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5021/LOD0/ues5021.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5021/LOD0/ues5021.sananimation",
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
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = -0.125,
                    ["z"] = -0.1,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = -0.16,
                    ["z"] = 0.09,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.1,
                    ["y"] = -0.10999999999999999,
                    ["z"] = 0.08,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = -0.04000000000000001,
                    ["z"] = -0.1,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = -0.04999999999999999,
                    ["z"] = 0.09,
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
                ["y"] = -0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.55,
                ["y"] = 0.55,
            },
        },
    },
    ["weapons"] = {},
}
