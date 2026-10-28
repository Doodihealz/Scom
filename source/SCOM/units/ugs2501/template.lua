-- ugs2501: The Hive
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Attachpoint01",
        },
        ["buildBeamEffectName"] = "beam1",
        ["faSourceContract"] = {
            ["sourceId"] = "XRB0104",
            ["audio"] = {
                ["donorDestroyedOneShotRetained"] = true,
                ["donorRootPersistentLoopRetained"] = false,
                ["sourceActivationCuesSupported"] = false,
                ["sourceBanksImported"] = false,
            },
            ["closeClipIsBakedReverse"] = true,
            ["mapping"] = "XRB0104 -> ugs2501",
            ["midClipReverseContinuitySupported"] = true,
            ["sanctuarySkirtOffsetSupported"] = false,
            ["sourceBlueprintSha256"] = "33df9d71506323628c40288aaf5df5ce6bea3f90ee7b176232ca1ed253580a05",
            ["sourceScriptSha256"] = "f4a5ce558e59e30e8866c35977f7badc154d1a5951c7a6c07905d4fc36a8432c",
            ["sourceSkirtOffset"] = {
                ["x"] = -0.5,
                ["z"] = -0.5,
            },
            ["sourceUpgradesTo"] = "XRB0204",
            ["substitutedTerminalTarget"] = "ugs3501/XRB0304",
        },
        ["multiConstructionBeam"] = {
            ["materialPath"] = "VFX/SCOM/CybranBuildDrones/build_beam.sanmaterial",
            ["prefabName"] = "SCOM_CybranHiveMuzzleBeam",
            ["shrink"] = 0.05,
        },
        ["scoSourceSecondaryVisuals"] = {
            ["sourceId"] = "XRB0104",
            ["sourceBlueprintSha256"] = "33df9d71506323628c40288aaf5df5ce6bea3f90ee7b176232ca1ed253580a05",
            ["targetId"] = "ugs2501",
            ["animationState"] = {
                ["key"] = "open",
                ["clipName"] = "AnimOpen",
                ["sanAnimationPath"] = "Units/ugs2501/LOD0/ugs2501.sananimation",
                ["condition"] = "constructionWork",
                ["duration"] = 1,
                ["forwardRate"] = 1,
                ["reverseRate"] = -1,
            },
        },
        ["scoFieldFixCybran"] = "1.0.4",
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod2110",
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
            ["y"] = 1.6,
            ["z"] = 1.2,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.86,
                ["z"] = 0.24,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 15,
        ["canBuild"] = "(Tags.ugs5026) * Tags.SCFA_ALLUNITS",
        ["range"] = 15,
        ["upgradesTo"] = "ugs5026",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 500,
            ["regen"] = 0,
            ["value"] = 500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 900,
        ["cost"] = {
            ["alloys"] = 500,
            ["energy"] = 2500,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardSupComHiveT2",
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
            ["Harvest"] = true,
            ["Pause"] = false,
            ["Repair"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "ugs2501",
        ["unitTypeName"] = "GuardT2EngineeringStation",
    },
    ["intel"] = {
        ["visionRadius"] = 15,
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 15,
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
        [1] = "BUILDABLE_BY_T2_ENGINEER",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "CONSTRUCTION",
        [4] = "ENGINEERING_STATION",
        [5] = "GUARD",
        [6] = "LAND",
        [7] = "STRUCTURE",
        [8] = "TECH2",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYCOMMANDER",
        [11] = "SCFA_BUILTBYTIER2COMMANDER",
        [12] = "SCFA_BUILTBYTIER2ENGINEER",
        [13] = "SCFA_BUILTBYTIER3COMMANDER",
        [14] = "SCFA_BUILTBYTIER3ENGINEER",
        [15] = "SCFA_CAPTURE",
        [16] = "SCFA_CONSTRUCTION",
        [17] = "SCFA_CYBRAN",
        [18] = "SCFA_DRAGBUILD",
        [19] = "SCFA_ENGINEER",
        [20] = "SCFA_ENGINEERSTATION",
        [21] = "SCFA_OVERLAYMISC",
        [22] = "SCFA_PATROLHELPER",
        [23] = "SCFA_PRODUCTFA",
        [24] = "SCFA_RECLAIM",
        [25] = "SCFA_RECLAIMABLE",
        [26] = "SCFA_REPAIR",
        [27] = "SCFA_SELECTABLE",
        [28] = "SCFA_SHOWQUEUE",
        [29] = "SCFA_SORTCONSTRUCTION",
        [30] = "SCFA_STATIONASSISTPOD",
        [31] = "SCFA_STRUCTURE",
        [32] = "SCFA_TECH2",
        [33] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["close"] = {
                ["clipName"] = "AnimClose",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs2501/LOD0/ugs2501.sananimation",
            },
            ["open"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs2501/LOD0/ugs2501.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs2501/LOD0/ugs2501.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 1,
                ["y"] = 1,
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
                    ["x"] = 0.216,
                    ["y"] = 0.15000000000000002,
                    ["z"] = -0.24,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.264,
                    ["y"] = 0.03799999999999998,
                    ["z"] = 0.216,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.24,
                    ["y"] = 0.19800000000000006,
                    ["z"] = 0.192,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.216,
                    ["y"] = 0.42200000000000004,
                    ["z"] = -0.24,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.264,
                    ["y"] = 0.3900000000000001,
                    ["z"] = 0.216,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 89,
            ["lod1distance"] = 233,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1,
                ["y"] = 1,
            },
        },
    },
}
