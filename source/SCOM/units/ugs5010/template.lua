-- ugs5010: Flood
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
                    ["bytes"] = 36504,
                    ["clipName"] = "FaURB3202Aupgrade",
                    ["duration"] = 1.6666666269302368,
                    ["entry"] = "units/URB3202/URB3202_Aupgrade.sca",
                    ["frames"] = 51,
                    ["outputDuration"] = 1.6666666269302368,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "1fbff825386f39d8fd26494518bde3b63e01932045b5a86911d77dba981cd462",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 25,
                    ["usedBySource"] = true,
                },
            },
            ["sourceBlueprint"] = "units/URB3202/URB3202_unit.bp",
            ["sourceBlueprintSha256"] = "e87775a04b66d376282913696ff67b8310b53fe17ff4233413b7ed51fe7f0c1a",
            ["sourceBuildableCategory"] = {
                [1] = "urs0305",
            },
            ["sourceId"] = "URB3202",
            ["sourceIntel"] = {
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
                ["bytes"] = 770,
                ["entry"] = "units/URB3202/URB3202_script.lua",
                ["sha256"] = "c3bc1104bea6bec740999f530665fd54cfdd756358cdbcea11ba7ace60012e66",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ugs5010",
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
        ["canBuild"] = "(Tags.ugn3005) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
        ["upgradesTo"] = "ugn3005",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 625,
            ["regen"] = 0,
            ["value"] = 625,
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
            [1] = "unitsDefaultGuard",
            [2] = "GuardStructure",
        },
        ["displayName"] = "Flood",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 190,
        ["iconUIType"] = "water",
        ["name"] = "Flood",
        ["orders"] = {},
        ["tpId"] = "ugs5010",
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
        [3] = "GUARD",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_BUILTBYTIER2COMMANDER",
        [6] = "SCFA_BUILTBYTIER2ENGINEER",
        [7] = "SCFA_BUILTBYTIER3COMMANDER",
        [8] = "SCFA_BUILTBYTIER3ENGINEER",
        [9] = "SCFA_CYBRAN",
        [10] = "SCFA_DRAGBUILD",
        [11] = "SCFA_INTELLIGENCE",
        [12] = "SCFA_OVERLAYSONAR",
        [13] = "SCFA_PRODUCTSC1",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SHOWQUEUE",
        [17] = "SCFA_SIZE4",
        [18] = "SCFA_SONAR",
        [19] = "SCFA_SORTINTEL",
        [20] = "SCFA_STRUCTURE",
        [21] = "SCFA_TECH2",
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
                ["sanAnimationPath"] = "Units/ugs5010/LOD0/ugs5010.sananimation",
            },
            ["upgrade"] = {
                ["clipName"] = "FaURB3202Aupgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5010/LOD0/ugs5010.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5010/LOD0/ugs5010.sananimation",
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
                ["x"] = 0.45,
                ["y"] = 0.45,
            },
        },
    },
    ["weapons"] = {},
}
