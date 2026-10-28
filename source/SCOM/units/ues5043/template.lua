-- ues5043: Novax Center
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
                    ["blueprintUses"] = {},
                    ["bytes"] = 23638,
                    ["clipName"] = "FaXEB2402aopen",
                    ["duration"] = 3.3333332538604736,
                    ["entry"] = "units/XEB2402/XEB2402_aopen.sca",
                    ["frames"] = 101,
                    ["outputDuration"] = 3.3333332538604736,
                    ["scriptLiteralUse"] = true,
                    ["sha256"] = "d73296dbade53410b7cd0201d5bf99fe227bf432bfb7cf60ce7f707675ef196b",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 8,
                    ["usedBySource"] = true,
                },
                [2] = {
                    ["archive"] = "units.scd",
                    ["bindPoseTracks"] = {},
                    ["blueprintUses"] = {},
                    ["bytes"] = 12038,
                    ["clipName"] = "FaXEB2402aopen01",
                    ["duration"] = 1.6666666269302368,
                    ["entry"] = "units/XEB2402/XEB2402_aopen01.sca",
                    ["frames"] = 51,
                    ["outputDuration"] = 1.6666666269302368,
                    ["scriptLiteralUse"] = true,
                    ["sha256"] = "73dbab5cc10530b4a27a7b8303a5cddd5520c26c08114f21e76b18d4c77ea7cd",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 8,
                    ["usedBySource"] = true,
                },
            },
            ["sourceBlueprint"] = "units/XEB2402/XEB2402_unit.bp",
            ["sourceBlueprintSha256"] = "767bfe0a4e2c2f0900988b4859211fabf66fa8443dc95e87e888f5f8fff386c7",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "XEB2402",
            ["sourceIntel"] = {},
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
                ["MeshExtentsX"] = 5.4,
                ["MeshExtentsY"] = 5.2,
                ["MeshExtentsZ"] = 5.7,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_None",
                ["SkirtOffsetX"] = -1.5,
                ["SkirtOffsetZ"] = -1.5,
                ["SkirtSizeX"] = 9,
                ["SkirtSizeZ"] = 9,
                ["TurnRate"] = 0,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 7199,
                ["entry"] = "units/XEB2402/XEB2402_Script.lua",
                ["sha256"] = "f3bd0922dc1fd7f80c420a783f7c1528ea16bdabeafb8ea40ae08c3f67a812a5",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ues5043",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoSpecial"] = {
            ["animations"] = {
                ["aopen"] = {
                    ["clipName"] = "FaXEB2402aopen",
                    ["duration"] = 3.3333332538604736,
                    ["sanAnimationPath"] = "Units/ues5043/LOD0/ues5043.sananimation",
                },
                ["aopen01"] = {
                    ["clipName"] = "FaXEB2402aopen01",
                    ["duration"] = 3.3333332538604736,
                    ["sanAnimationPath"] = "Units/ues5043/LOD0/ues5043.sananimation",
                },
            },
            ["attachBone"] = "Attachpoint01",
            ["child"] = "uea5009",
            ["effects"] = {
                ["launch1"] = {
                    ["bone"] = "Root",
                    ["loop"] = false,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 1,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5043/launch1.sanvfx",
                },
                ["launch2"] = {
                    ["bone"] = "Root",
                    ["loop"] = false,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 2,
                        [3] = 1,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5043/launch2.sanvfx",
                },
                ["light1"] = {
                    ["bone"] = "Tower_B04",
                    ["loop"] = true,
                    ["offset"] = {
                        [1] = 0.06,
                        [2] = -0.1,
                        [3] = 1.9,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5043/light1.sanvfx",
                },
                ["light2"] = {
                    ["bone"] = "Tower_B04",
                    ["loop"] = true,
                    ["offset"] = {
                        [1] = -0.06,
                        [2] = -0.1,
                        [3] = 1.9,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5043/light2.sanvfx",
                },
                ["light3"] = {
                    ["bone"] = "Tower_B04",
                    ["loop"] = true,
                    ["offset"] = {
                        [1] = 0.08,
                        [2] = -0.5,
                        [3] = 1.6,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5043/light3.sanvfx",
                },
                ["light4"] = {
                    ["bone"] = "Tower_B04",
                    ["loop"] = true,
                    ["offset"] = {
                        [1] = -0.04,
                        [2] = -0.5,
                        [3] = 1.6,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5043/light4.sanvfx",
                },
                ["rotator1"] = {
                    ["bone"] = "ConstuctBeam01",
                    ["loop"] = true,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5043/rotator1.sanvfx",
                },
                ["rotator2"] = {
                    ["bone"] = "ConstuctBeam02",
                    ["loop"] = true,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5043/rotator2.sanvfx",
                },
                ["steam1"] = {
                    ["bone"] = "Attachpoint01",
                    ["loop"] = true,
                    ["offset"] = {
                        [1] = 0.7,
                        [2] = -0.85,
                        [3] = 0.35,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5043/steam1.sanvfx",
                },
                ["steam2"] = {
                    ["bone"] = "Attachpoint01",
                    ["loop"] = true,
                    ["offset"] = {
                        [1] = -0.7,
                        [2] = -0.85,
                        [3] = 0.35,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5043/steam2.sanvfx",
                },
            },
            ["kind"] = "novaxLauncher",
            ["sourceId"] = "XEB2402",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 6,
            ["y"] = 1.7,
            ["z"] = 6,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 9000,
            ["regen"] = 0,
            ["value"] = 9000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 27900,
        ["cost"] = {
            ["alloys"] = 37200,
            ["energy"] = 604500,
        },
    },
    ["footprint"] = {
        ["x"] = 6,
        ["y"] = 6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "Novax Center",
        ["icon"] = {
            ["shape"] = "experimental1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech4_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "land",
        ["name"] = "Novax Center",
        ["orders"] = {},
        ["tpId"] = "ues5043",
    },
    ["intel"] = {
        ["visionRadius"] = 0,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
    },
    ["skirtSize"] = {
        ["x"] = 9,
        ["y"] = 9,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "EDA",
        [3] = "EXPERIMENTAL",
        [4] = "LAND",
        [5] = "SCFA_ALLUNITS",
        [6] = "SCFA_BUILTBYTIER3COMMANDER",
        [7] = "SCFA_BUILTBYTIER3ENGINEER",
        [8] = "SCFA_DRAGBUILD",
        [9] = "SCFA_EXPERIMENTAL",
        [10] = "SCFA_LAND",
        [11] = "SCFA_ORBITALSYSTEM",
        [12] = "SCFA_PRODUCTFA",
        [13] = "SCFA_RECLAIMABLE",
        [14] = "SCFA_SELECTABLE",
        [15] = "SCFA_STRUCTURE",
        [16] = "SCFA_UEF",
        [17] = "SCFA_VISIBLETORECON",
        [18] = "STRUCTURE",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5043/LOD0/ues5043.sananimation",
            },
            ["scoSpecial_aopen"] = {
                ["clipName"] = "FaXEB2402aopen",
                ["duration"] = 3.3333332538604736,
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5043/LOD0/ues5043.sananimation",
            },
            ["scoSpecial_aopen01"] = {
                ["clipName"] = "FaXEB2402aopen01",
                ["duration"] = 3.3333332538604736,
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5043/LOD0/ues5043.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5043/LOD0/ues5043.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.08,
                    ["y"] = 0.425,
                    ["z"] = -1.2000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.32,
                    ["y"] = 0.306,
                    ["z"] = 1.08,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.2000000000000002,
                    ["y"] = 0.47600000000000003,
                    ["z"] = 0.96,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.08,
                    ["y"] = 0.714,
                    ["z"] = -1.2000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.32,
                    ["y"] = 0.68,
                    ["z"] = 1.08,
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
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3.4,
                ["y"] = 3.4,
            },
        },
    },
    ["weapons"] = {},
}
