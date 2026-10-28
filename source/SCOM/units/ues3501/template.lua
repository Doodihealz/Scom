-- ues3501: The Kennel
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "AttachSpecial01",
            [2] = "AttachSpecial02",
        },
        ["buildBeamEffectName"] = "beam1",
        ["faSourceContract"] = {
            ["audio"] = {
                ["donorDestroyedOneShotRetained"] = true,
                ["donorRootPersistentLoopRetained"] = false,
                ["sourceActivationCuesSupported"] = false,
                ["sourceBanksImported"] = false,
            },
            ["completionOpen"] = {
                ["clip"] = "AnimOpen",
                ["durationSeconds"] = 5,
                ["sourceRate"] = 0.4,
            },
            ["mapping"] = "XEB0204 -> ues3501",
            ["sanctuaryDirectBuildCompatibility"] = true,
            ["sanctuaryPodRuntimeSupported"] = false,
            ["sanctuarySkirtOffsetSupported"] = false,
            ["sanctuarySouthFacingSelectionOffsetZ"] = -0.1,
            ["sourceBlueprintSha256"] = "c7bca76130a5892b252464a8dc65f08e15da385bc3f0e7dcbbe873d60ca40ba8",
            ["sourcePods"] = {
                [1] = {
                    ["attach"] = "AttachSpecial01",
                    ["id"] = "XEA3204",
                },
                [2] = {
                    ["attach"] = "AttachSpecial02",
                    ["id"] = "XEA3204",
                },
            },
            ["sourceScriptSha256"] = "e944e2bbe6bdd0dce936a2cacdabf1fd29add88c81fbb6d1ecfc599ca17749fa",
            ["sourceSelectionCenterOffsetZ"] = 0.1,
            ["sourceSkirtOffset"] = {
                ["x"] = -0.5,
                ["z"] = -0.5,
            },
        },
        ["scoSourcePods"] = {
            ["animation"] = {
                ["initialRate"] = 0.4,
                ["segments"] = {
                    [1] = {
                        ["bakedRate"] = 0.4,
                        ["clip"] = "AnimOpen",
                        ["finish"] = 2,
                        ["key"] = "open",
                        ["start"] = 0,
                    },
                },
                ["sourceDuration"] = 2,
                ["sourceHoldSeconds"] = 0.5,
                ["sourceOpen"] = "/units/XEB0204/XEB0204_aopen.sca",
                ["sourceStartRate"] = 2,
                ["sourceStopRate"] = 1.5,
            },
            ["autoAssistRange"] = 25,
            ["buildPower"] = 20,
            ["kind"] = "tower",
            ["slots"] = {
                [1] = {
                    ["bone"] = "AttachSpecial01",
                    ["cost"] = {
                        ["alloys"] = 250,
                        ["energy"] = 2500,
                        ["time"] = 750,
                    },
                    ["initial"] = true,
                    ["name"] = "PodOne",
                    ["template"] = "uea5011",
                },
                [2] = {
                    ["bone"] = "AttachSpecial02",
                    ["cost"] = {
                        ["alloys"] = 250,
                        ["energy"] = 2500,
                        ["time"] = 750,
                    },
                    ["initial"] = true,
                    ["name"] = "PodTwo",
                    ["template"] = "uea5011",
                },
            },
            ["sourceId"] = "XEB0204",
            ["targetId"] = "ues3501",
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 1.8,
            ["z"] = 1,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["offset"] = {
                ["x"] = -0.4,
                ["y"] = 1.15,
                ["z"] = -0.83,
            },
            ["shrink"] = 0.9,
        },
        ["buildPower"] = 20,
        ["canBuild"] = "(Tags.SCFA_IMPOSSIBLE) * Tags.SCFA_ALLUNITS",
        ["range"] = 25,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 3000,
            ["regen"] = 0,
            ["value"] = 3000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 2000,
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
            [1] = "unitsDefaultEDA",
            [2] = "EDASupComKennelT3",
        },
        ["displayName"] = "The Kennel",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "engineer",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_engineer.png",
        ["iconUIBuildSortPriority"] = 200,
        ["iconUIType"] = "land",
        ["name"] = "The Kennel",
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
        ["tpId"] = "ues3501",
        ["unitTypeName"] = "EDAT3EngineeringStation",
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
        [1] = "CONSTRUCTION",
        [2] = "EDA",
        [3] = "ENGINEERING_STATION",
        [4] = "LAND",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_CONSTRUCTION",
        [9] = "SCFA_ENGINEERSTATION",
        [10] = "SCFA_OVERLAYMISC",
        [11] = "SCFA_PODSTAGINGPLATFORM",
        [12] = "SCFA_PRODUCTFA",
        [13] = "SCFA_RECLAIMABLE",
        [14] = "SCFA_SELECTABLE",
        [15] = "SCFA_SHOWQUEUE",
        [16] = "SCFA_SORTCONSTRUCTION",
        [17] = "SCFA_STRUCTURE",
        [18] = "SCFA_TECH3",
        [19] = "SCFA_UEF",
        [20] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["open"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues3501/LOD0/ues3501.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues3501/LOD0/ues3501.sananimation",
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
                    ["particleName"] = "VFX/Death/ved2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.2,
                    ["z"] = -0.2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.07400000000000001,
                    ["z"] = 0.18,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.2540000000000001,
                    ["z"] = 0.16,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.506,
                    ["z"] = -0.2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.4700000000000001,
                    ["z"] = 0.18,
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
                ["z"] = -0.1,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.6,
            },
        },
    },
}
