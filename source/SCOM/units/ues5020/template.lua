-- ues5020: SP1 - 1000
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
                    ["bytes"] = 54562,
                    ["clipName"] = "FaUEB3102Aupgrade",
                    ["duration"] = 3,
                    ["entry"] = "units/UEB3102/UEB3102_Aupgrade.sca",
                    ["frames"] = 91,
                    ["outputDuration"] = 3,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "9a873c856128348d1aa2c2ffd9197bb1965e43af468313d068759ef546c80bcb",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 21,
                    ["usedBySource"] = true,
                },
            },
            ["sourceBlueprint"] = "units/UEB3102/UEB3102_unit.bp",
            ["sourceBlueprintSha256"] = "17bcd5ab1edd7a57b1dc7923cfd8b0740a335e9f52008ab62fb1e78df7308a66",
            ["sourceBuildableCategory"] = {
                [1] = "ueb3202",
            },
            ["sourceId"] = "UEB3102",
            ["sourceIntel"] = {
                ["ReactivateTime"] = 10,
                ["ShowIntelOnSelect"] = true,
                ["SonarRadius"] = 115,
                ["VisionRadius"] = 20,
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
                ["MeshExtentsOffsetY"] = -1.2,
                ["MeshExtentsX"] = 1.25,
                ["MeshExtentsY"] = 2,
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
                ["bytes"] = 805,
                ["entry"] = "units/UEB3102/UEB3102_script.lua",
                ["sha256"] = "9236eef14318eb97d1252d652c378d31afe1105b3572d463f5228a9604f7c94c",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ues5020",
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
            ["x"] = 0.6,
            ["y"] = 0.5,
            ["z"] = 0.6,
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
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.ues5021) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
        ["upgradesTo"] = "ues5021",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 600,
            ["regen"] = 0,
            ["value"] = 600,
        },
    },
    ["economy"] = {
        ["buildTime"] = 80,
        ["cost"] = {
            ["alloys"] = 64,
            ["energy"] = 544,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 10,
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
        ["displayName"] = "SP1 - 1000",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 20,
        ["iconUIType"] = "water",
        ["name"] = "SP1 - 1000",
        ["orders"] = {},
        ["tpId"] = "ues5020",
    },
    ["intel"] = {
        ["sonarRadius"] = 115,
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 5,
        },
        [3] = {
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
        ["x"] = 1,
        ["y"] = 1,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T1_ENGINEER",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "EDA",
        [5] = "SCFA_ALLUNITS",
        [6] = "SCFA_BUILTBYTIER1ENGINEER",
        [7] = "SCFA_BUILTBYTIER2COMMANDER",
        [8] = "SCFA_BUILTBYTIER2ENGINEER",
        [9] = "SCFA_BUILTBYTIER3COMMANDER",
        [10] = "SCFA_BUILTBYTIER3ENGINEER",
        [11] = "SCFA_DRAGBUILD",
        [12] = "SCFA_INTELLIGENCE",
        [13] = "SCFA_OVERLAYSONAR",
        [14] = "SCFA_PRODUCTSC1",
        [15] = "SCFA_RECLAIMABLE",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SHOWQUEUE",
        [18] = "SCFA_SIZE4",
        [19] = "SCFA_SONAR",
        [20] = "SCFA_SORTINTEL",
        [21] = "SCFA_STRUCTURE",
        [22] = "SCFA_TECH1",
        [23] = "SCFA_UEF",
        [24] = "SCFA_VISIBLETORECON",
        [25] = "STRUCTURE",
        [26] = "TECH1",
        [27] = "NAVAL",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5020/LOD0/ues5020.sananimation",
            },
            ["upgrade"] = {
                ["clipName"] = "FaUEB3102Aupgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5020/LOD0/ues5020.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5020/LOD0/ues5020.sananimation",
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
                    ["x"] = 0.108,
                    ["y"] = -0.125,
                    ["z"] = -0.12,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = -0.16,
                    ["z"] = 0.108,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = -0.10999999999999999,
                    ["z"] = 0.096,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = -0.04000000000000001,
                    ["z"] = -0.12,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = -0.04999999999999999,
                    ["z"] = 0.108,
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
                ["x"] = 0.4,
                ["y"] = 0.4,
            },
        },
    },
    ["weapons"] = {},
}
