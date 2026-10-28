-- ugs5026: The Hive
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Attachpoint01",
            [2] = "Attachpoint02",
        },
        ["faSourceContract"] = {
            ["fuelIntentionallyOmitted"] = false,
            ["runtimeBehaviorApproval"] = false,
            ["sourceAir"] = {},
            ["sourceAnimations"] = {
                [1] = {
                    ["archive"] = "units.scd",
                    ["bindPoseTracks"] = {},
                    ["blueprintUses"] = {
                        [1] = ".Display.AnimationOpen",
                    },
                    ["bytes"] = 8278,
                    ["clipName"] = "FaXRB0204aopen",
                    ["duration"] = 1,
                    ["entry"] = "units/XRB0204/XRB0204_aopen.sca",
                    ["frames"] = 31,
                    ["outputDuration"] = 1,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "da1274272894bdb328a1d1242f23edfff7bc91ff9a5acbab5c15b2d742d93021",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 9,
                    ["usedBySource"] = true,
                },
            },
            ["sourceBlueprint"] = "units/XRB0204/XRB0204_unit.bp",
            ["sourceBlueprintSha256"] = "2d4bd826f7b7ffb0e843680acfe630b2955251333e5eb50faec16269b6139e6b",
            ["sourceBuildableCategory"] = {
                [1] = "xrb0304",
            },
            ["sourceId"] = "XRB0204",
            ["sourceIntel"] = {
                ["VisionRadius"] = 15,
            },
            ["sourceMovement"] = {
                ["BankingSlope"] = 0,
                ["BuildOnLayerCaps"] = {
                    ["LAYER_Air"] = false,
                    ["LAYER_Land"] = true,
                    ["LAYER_Orbit"] = false,
                    ["LAYER_Seabed"] = false,
                    ["LAYER_Sub"] = false,
                    ["LAYER_Water"] = false,
                },
                ["DragCoefficient"] = 0.2,
                ["FlattenSkirt"] = true,
                ["MaxSteerForce"] = 0,
                ["MeshExtentsX"] = 2,
                ["MeshExtentsY"] = 4,
                ["MeshExtentsZ"] = 2,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_None",
                ["SkirtOffsetX"] = -0.5,
                ["SkirtOffsetZ"] = -0.5,
                ["SkirtSizeX"] = 2,
                ["SkirtSizeZ"] = 2,
                ["TurnRate"] = 0,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1723,
                ["entry"] = "units/XRB0204/XRB0204_script.lua",
                ["sha256"] = "2ddd4e2154af4a88dcb2bf3bb0e988a7365aa82085383e49b246859a7a3227b5",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ugs5026",
            ["unsupportedWeaponBindings"] = {},
        },
        ["multiConstructionBeam"] = {
            ["materialPath"] = "VFX/SCOM/CybranBuildDrones/build_beam.sanmaterial",
            ["prefabName"] = "SCOM_CybranHiveMuzzleBeam",
            ["shrink"] = 0.05,
        },
        ["scoSourceSecondaryVisuals"] = {
            ["animationState"] = {
                ["clipName"] = "FaXRB0204aopen",
                ["condition"] = "constructionWork",
                ["duration"] = 1,
                ["forwardRate"] = 1,
                ["key"] = "scoSecondaryOpen",
                ["reverseRate"] = -1,
                ["sanAnimationPath"] = "Units/ugs5026/LOD0/ugs5026.sananimation",
                ["source"] = {
                    ["archive"] = "units.scd",
                    ["bindPoseTracks"] = {},
                    ["blueprintUses"] = {
                        [1] = ".Display.AnimationOpen",
                    },
                    ["bytes"] = 8278,
                    ["clipName"] = "FaXRB0204aopen",
                    ["duration"] = 1,
                    ["entry"] = "units/XRB0204/XRB0204_aopen.sca",
                    ["frames"] = 31,
                    ["outputDuration"] = 1,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "da1274272894bdb328a1d1242f23edfff7bc91ff9a5acbab5c15b2d742d93021",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 9,
                    ["usedBySource"] = true,
                },
            },
            ["effects"] = {},
            ["meshes"] = {},
            ["sourceBlueprintSha256"] = "2d4bd826f7b7ffb0e843680acfe630b2955251333e5eb50faec16269b6139e6b",
            ["sourceId"] = "XRB0204",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1723,
                ["entry"] = "units/XRB0204/XRB0204_script.lua",
                ["sha256"] = "2ddd4e2154af4a88dcb2bf3bb0e988a7365aa82085383e49b246859a7a3227b5",
            },
            ["targetId"] = "ugs5026",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.2,
            ["y"] = 2,
            ["z"] = 1.3,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Attachpoint01",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 25,
        ["canBuild"] = "(Tags.ugs3501) * Tags.SCFA_ALLUNITS",
        ["range"] = 20,
        ["upgradesTo"] = "ugs3501",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1250,
            ["regen"] = 0,
            ["value"] = 1250,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1200,
        ["cost"] = {
            ["alloys"] = 240,
            ["energy"] = 1600,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardEngineeringStation",
        },
        ["displayName"] = "The Hive",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "engineer",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_engineer.png",
        ["iconUIBuildSortPriority"] = 200,
        ["iconUIType"] = "land",
        ["name"] = "The Hive",
        ["orders"] = {
            ["Assist"] = true,
            ["Capture"] = true,
            ["Harvest"] = true,
            ["Repair"] = true,
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "ugs5026",
    },
    ["intel"] = {
        ["visionRadius"] = 15,
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
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
        [1] = "ENGINEER",
        [2] = "GUARD",
        [3] = "SCFA_ALLUNITS",
        [4] = "SCFA_CAPTURE",
        [5] = "SCFA_CONSTRUCTION",
        [6] = "SCFA_CYBRAN",
        [7] = "SCFA_DRAGBUILD",
        [8] = "SCFA_ENGINEER",
        [9] = "SCFA_ENGINEERSTATION",
        [10] = "SCFA_OVERLAYMISC",
        [11] = "SCFA_PATROLHELPER",
        [12] = "SCFA_PRODUCTFA",
        [13] = "SCFA_RECLAIM",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_REPAIR",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SHOWQUEUE",
        [18] = "SCFA_SORTCONSTRUCTION",
        [19] = "SCFA_STATIONASSISTPOD",
        [20] = "SCFA_STRUCTURE",
        [21] = "SCFA_TECH2",
        [22] = "SCFA_VISIBLETORECON",
        [23] = "STRUCTURE",
        [24] = "TECH2",
        [25] = "ENGINEERING_STATION",
    },
    ["visuals"] = {
        ["animations"] = {
            ["open"] = {
                ["clipName"] = "FaXRB0204aopen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5026/LOD0/ugs5026.sananimation",
            },
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5026/LOD0/ugs5026.sananimation",
            },
            ["scoSecondaryOpen"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "FaXRB0204aopen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5026/LOD0/ugs5026.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5026/LOD0/ugs5026.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.216,
                    ["y"] = 0.25,
                    ["z"] = -0.26,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.264,
                    ["y"] = 0.10999999999999999,
                    ["z"] = 0.23399999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.24,
                    ["y"] = 0.31000000000000005,
                    ["z"] = 0.20800000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.216,
                    ["y"] = 0.59,
                    ["z"] = -0.26,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.264,
                    ["y"] = 0.55,
                    ["z"] = 0.23399999999999999,
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
                ["x"] = 1,
                ["y"] = 1,
            },
        },
    },
    ["weapons"] = {},
}
