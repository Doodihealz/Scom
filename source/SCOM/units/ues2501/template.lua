-- ues2501: The Kennel
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
            ["mapping"] = "XEB0104 -> ues2501",
            ["podOpen"] = {
                ["clip"] = "AnimPodOpen",
                ["holdSeconds"] = 0.5,
                ["sourceRate"] = 2,
            },
            ["podResume"] = {
                ["clip"] = "AnimPodResume",
                ["sourceRate"] = 1.5,
            },
            ["sanctuaryDirectBuildCompatibility"] = true,
            ["sanctuaryPodRuntimeSupported"] = false,
            ["sanctuarySkirtOffsetSupported"] = false,
            ["sourceBlueprintSha256"] = "2052c14d35cc2772d23e5bf429a4457204c37745b3fa5e6ab22b0adeaf73bc37",
            ["sourcePod"] = {
                ["attach"] = "AttachSpecial01",
                ["createWithUnit"] = true,
                ["id"] = "XEA3204",
            },
            ["sourceScriptSha256"] = "00d4ff0aa2f10cfb5addce51f3783a08a7b229ffe388bf84a270403301f2f3f2",
            ["sourceSkirtOffset"] = {
                ["x"] = -0.5,
                ["z"] = -0.5,
            },
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "upgrade",
            ["durationSeconds"] = 0.8333333134651184,
            ["restAnimationKey"] = "walk",
        },
        ["scoSourcePods"] = {
            ["animation"] = {
                ["initialRate"] = 0,
                ["segments"] = {
                    [1] = {
                        ["bakedRate"] = 2,
                        ["clip"] = "AnimPodOpen",
                        ["finish"] = 1,
                        ["key"] = "podOpen",
                        ["start"] = 0,
                    },
                    [2] = {
                        ["bakedRate"] = 1.5,
                        ["clip"] = "AnimPodResume",
                        ["finish"] = 2,
                        ["key"] = "podResume",
                        ["start"] = 1,
                    },
                },
                ["sourceDuration"] = 2,
                ["sourceHoldSeconds"] = 0.5,
                ["sourceOpen"] = "/units/XEB0104/XEB0104_aopen.sca",
                ["sourceStartRate"] = 2,
                ["sourceStopRate"] = 1.5,
            },
            ["autoAssistRange"] = 15,
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
            },
            ["sourceId"] = "XEB0104",
            ["targetId"] = "ues2501",
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
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.7,
            ["y"] = 0.8,
            ["z"] = 0.7,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["offset"] = {
                ["x"] = -0.2,
                ["y"] = 1.15,
                ["z"] = -0.83,
            },
            ["shrink"] = 0.55,
        },
        ["buildPower"] = 20,
        ["canBuild"] = "(Tags.ues3501) * Tags.SCFA_ALLUNITS",
        ["range"] = 15,
        ["upgradesTo"] = "ues3501",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1000,
            ["regen"] = 0,
            ["value"] = 1000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1100,
        ["cost"] = {
            ["alloys"] = 550,
            ["energy"] = 2750,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDASupComKennelT2",
        },
        ["displayName"] = "The Kennel",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "engineer",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_engineer.png",
        ["iconUIBuildSortPriority"] = 200,
        ["iconUIType"] = "land",
        ["name"] = "The Kennel",
        ["orders"] = {
            ["Assist"] = true,
            ["Harvest"] = true,
            ["Pause"] = true,
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
        ["tpId"] = "ues2501",
        ["unitTypeName"] = "EDAT2EngineeringStation",
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
        [4] = "EDA",
        [5] = "ENGINEERING_STATION",
        [6] = "LAND",
        [7] = "STRUCTURE",
        [8] = "TECH2",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER2COMMANDER",
        [11] = "SCFA_BUILTBYTIER2ENGINEER",
        [12] = "SCFA_BUILTBYTIER3COMMANDER",
        [13] = "SCFA_BUILTBYTIER3ENGINEER",
        [14] = "SCFA_CONSTRUCTION",
        [15] = "SCFA_DRAGBUILD",
        [16] = "SCFA_ENGINEERSTATION",
        [17] = "SCFA_OVERLAYMISC",
        [18] = "SCFA_PODSTAGINGPLATFORM",
        [19] = "SCFA_PRODUCTFA",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SHOWQUEUE",
        [23] = "SCFA_SORTCONSTRUCTION",
        [24] = "SCFA_STRUCTURE",
        [25] = "SCFA_TECH2",
        [26] = "SCFA_UEF",
        [27] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["podOpen"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimPodOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues2501/LOD0/ues2501.sananimation",
            },
            ["podResume"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimPodResume",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues2501/LOD0/ues2501.sananimation",
            },
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues2501/LOD0/ues2501.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues2501/LOD0/ues2501.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.2,
                    ["z"] = -0.13999999999999999,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.144,
                    ["z"] = 0.126,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.13999999999999999,
                    ["y"] = 0.22400000000000003,
                    ["z"] = 0.11199999999999999,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.336,
                    ["z"] = -0.13999999999999999,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.32000000000000006,
                    ["z"] = 0.126,
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
                ["x"] = 0.65,
                ["y"] = 0.6,
            },
        },
    },
}
