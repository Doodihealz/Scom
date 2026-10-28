-- ugs3501: The Hive
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Attachpoint01",
            [2] = "Attachpoint02",
            [3] = "Attachpoint03",
        },
        ["buildBeamEffectName"] = "beam1",
        ["faSourceContract"] = {
            ["sourceId"] = "XRB0304",
            ["audio"] = {
                ["donorDestroyedOneShotRetained"] = true,
                ["donorRootPersistentLoopRetained"] = false,
                ["sourceActivationCuesSupported"] = false,
                ["sourceBanksImported"] = false,
            },
            ["closeClipIsBakedReverse"] = true,
            ["mapping"] = "XRB0304 -> ugs3501",
            ["midClipReverseContinuitySupported"] = true,
            ["sanctuaryPublicTechCategory"] = "TECH3",
            ["sanctuarySkirtOffsetSupported"] = false,
            ["sanctuaryUpgradesFrom"] = "ugs2501/XRB0104",
            ["sourceBlueprintSha256"] = "d2fc5fa9de2105259bf66ee88b20b271e11c4ddae34420df2383d67baa90b701",
            ["sourceScriptSha256"] = "3cc97747f900596d50c06565fd4682ca70bd8d870d49a9e0d664a93ea8e7d5be",
            ["sourceSkirtOffset"] = {
                ["x"] = -0.5,
                ["z"] = -0.5,
            },
            ["sourceTechCategory"] = "TECH2",
            ["sourceUpgradesFrom"] = "XRB0204",
            ["staticallyVisibleMeshBones"] = {
                [1] = "TurretT3",
                [2] = "B03",
                [3] = "Door3_B03",
            },
            ["terminalProgressionSubstitution"] = true,
        },
        ["multiConstructionBeam"] = {
            ["materialPath"] = "VFX/SCOM/CybranBuildDrones/build_beam.sanmaterial",
            ["prefabName"] = "SCOM_CybranHiveMuzzleBeam",
            ["shrink"] = 0.05,
        },
        ["scoSourceSecondaryVisuals"] = {
            ["sourceId"] = "XRB0304",
            ["sourceBlueprintSha256"] = "d2fc5fa9de2105259bf66ee88b20b271e11c4ddae34420df2383d67baa90b701",
            ["targetId"] = "ugs3501",
            ["animationState"] = {
                ["key"] = "open",
                ["clipName"] = "AnimOpen",
                ["sanAnimationPath"] = "Units/ugs3501/LOD0/ugs3501.sananimation",
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
            ["name"] = "agod2120",
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
            ["y"] = 2.6,
            ["z"] = 1.3,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.86,
                ["z"] = 0.83,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 35,
        ["canBuild"] = "(Tags.GUARD * Tags.BUILDABLE_BY_T3_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 25,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 2750,
            ["regen"] = 0,
            ["value"] = 2750,
        },
    },
    ["economy"] = {
        ["buildTime"] = 2400,
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
            [2] = "GuardSupComHiveFinal",
        },
        ["displayName"] = "The Hive",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "engineer",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_engineer.png",
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
        ["tpId"] = "ugs3501",
        ["unitTypeName"] = "GuardT3EngineeringStation",
    },
    ["intel"] = {
        ["visionRadius"] = 15,
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 25,
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
        [1] = "CONSTRUCTION",
        [2] = "ENGINEERING_STATION",
        [3] = "GUARD",
        [4] = "LAND",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_CAPTURE",
        [9] = "SCFA_CONSTRUCTION",
        [10] = "SCFA_CYBRAN",
        [11] = "SCFA_DRAGBUILD",
        [12] = "SCFA_ENGINEER",
        [13] = "SCFA_ENGINEERSTATION",
        [14] = "SCFA_OVERLAYMISC",
        [15] = "SCFA_PATROLHELPER",
        [16] = "SCFA_PRODUCTFA",
        [17] = "SCFA_RECLAIM",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_REPAIR",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_SHOWQUEUE",
        [22] = "SCFA_SORTCONSTRUCTION",
        [23] = "SCFA_STATIONASSISTPOD",
        [24] = "SCFA_STRUCTURE",
        [25] = "SCFA_TECH2",
        [26] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["close"] = {
                ["clipName"] = "AnimClose",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs3501/LOD0/ugs3501.sananimation",
            },
            ["open"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs3501/LOD0/ugs3501.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs3501/LOD0/ugs3501.sananimation",
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
                    ["y"] = 0.4,
                    ["z"] = -0.26,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.264,
                    ["y"] = 0.21799999999999997,
                    ["z"] = 0.23399999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.24,
                    ["y"] = 0.4780000000000001,
                    ["z"] = 0.20800000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.216,
                    ["y"] = 0.8420000000000001,
                    ["z"] = -0.26,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.264,
                    ["y"] = 0.79,
                    ["z"] = 0.23399999999999999,
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
