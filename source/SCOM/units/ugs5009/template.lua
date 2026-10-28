-- ugs5009: Scout-Deployed Land Sensor
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
                        [1] = ".Display.AnimationOpen",
                    },
                    ["bytes"] = 55598,
                    ["clipName"] = "FaURL0101Aagro",
                    ["duration"] = 4,
                    ["entry"] = "units/URL0101/URL0101_Aagro.sca",
                    ["frames"] = 121,
                    ["outputDuration"] = 4,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "ce0f9edb38884a8e29b9ade06e6bcfe6e4daf961e52f21c44c16a7809fd493a3",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 16,
                    ["usedBySource"] = true,
                },
            },
            ["sourceBlueprint"] = "units/URB3103/URB3103_unit.bp",
            ["sourceBlueprintSha256"] = "2a708b559c898668156f4286878f87faac9d7ffe56be9e986e4e4c5d05ac0e02",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "URB3103",
            ["sourceIntel"] = {
                ["RadarStealth"] = true,
                ["ShowIntelOnSelect"] = true,
                ["VisionRadius"] = 60,
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
                ["bytes"] = 1465,
                ["entry"] = "units/URB3103/URB3103_script.lua",
                ["sha256"] = "f1a0af1f79e6663c54490c1b0b276d98596b8fdb1e2aec4f9db281338f7ae6eb",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ugs5009",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoSourceSecondaryVisuals"] = {
            ["animationState"] = {
                ["clipName"] = "FaURL0101Aagro",
                ["condition"] = "complete",
                ["duration"] = 4,
                ["forwardRate"] = 1,
                ["key"] = "scoSecondaryOpen",
                ["reverseRate"] = -1,
                ["sanAnimationPath"] = "Units/ugs5009/LOD0/ugs5009.sananimation",
                ["source"] = {
                    ["archive"] = "units.scd",
                    ["bindPoseTracks"] = {},
                    ["blueprintUses"] = {
                        [1] = ".Display.AnimationOpen",
                    },
                    ["bytes"] = 55598,
                    ["clipName"] = "FaURL0101Aagro",
                    ["duration"] = 4,
                    ["entry"] = "units/URL0101/URL0101_Aagro.sca",
                    ["frames"] = 121,
                    ["outputDuration"] = 4,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "ce0f9edb38884a8e29b9ade06e6bcfe6e4daf961e52f21c44c16a7809fd493a3",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 16,
                    ["usedBySource"] = true,
                },
            },
            ["effects"] = {},
            ["meshes"] = {},
            ["rotators"] = {
                [1] = {
                    ["acceleration"] = 5,
                    ["axis"] = "y",
                    ["bone"] = "Spinner",
                    ["delay"] = 5,
                    ["disabledAcceleration"] = 5,
                    ["initialSpeed"] = 90,
                    ["speed"] = 90,
                },
            },
            ["sourceBlueprintSha256"] = "2a708b559c898668156f4286878f87faac9d7ffe56be9e986e4e4c5d05ac0e02",
            ["sourceId"] = "URB3103",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1465,
                ["entry"] = "units/URB3103/URB3103_script.lua",
                ["sha256"] = "f1a0af1f79e6663c54490c1b0b276d98596b8fdb1e2aec4f9db281338f7ae6eb",
            },
            ["targetId"] = "ugs5009",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.1,
            ["y"] = 0.7,
            ["z"] = 0.15,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1,
            ["regen"] = 0,
            ["value"] = 1,
        },
    },
    ["economy"] = {
        ["buildTime"] = 40,
        ["cost"] = {
            ["alloys"] = 32,
            ["energy"] = 320,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 20,
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
        ["displayName"] = "Scout-Deployed Land Sensor",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "land",
        ["name"] = "Scout-Deployed Land Sensor",
        ["orders"] = {},
        ["tpId"] = "ugs5009",
    },
    ["intel"] = {
        ["visionRadius"] = 60,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 60,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 60,
        },
    },
    ["skirtSize"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["tags"] = {
        [1] = "GUARD",
        [2] = "SCFA_ALLUNITS",
        [3] = "SCFA_CYBRAN",
        [4] = "SCFA_INTELLIGENCE",
        [5] = "SCFA_PRODUCTSC1",
        [6] = "SCFA_RADAR",
        [7] = "SCFA_RECLAIMABLE",
        [8] = "SCFA_SELECTABLE",
        [9] = "SCFA_SIZE4",
        [10] = "SCFA_STRUCTURE",
        [11] = "SCFA_TECH1",
        [12] = "SCFA_VISIBLETORECON",
        [13] = "STRUCTURE",
        [14] = "TECH1",
    },
    ["visuals"] = {
        ["animations"] = {
            ["open"] = {
                ["clipName"] = "FaURL0101Aagro",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5009/LOD0/ugs5009.sananimation",
            },
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5009/LOD0/ugs5009.sananimation",
            },
            ["scoSecondaryOpen"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "FaURL0101Aagro",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5009/LOD0/ugs5009.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5009/LOD0/ugs5009.sananimation",
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
                    ["x"] = 0.018,
                    ["y"] = -0.07500000000000001,
                    ["z"] = -0.03,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.022000000000000002,
                    ["y"] = -0.124,
                    ["z"] = 0.027,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.020000000000000004,
                    ["y"] = -0.05399999999999999,
                    ["z"] = 0.024,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.018,
                    ["y"] = 0.043999999999999984,
                    ["z"] = -0.03,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.022000000000000002,
                    ["y"] = 0.02999999999999997,
                    ["z"] = 0.027,
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
                ["x"] = 0.3,
                ["y"] = 0.3,
            },
        },
    },
    ["weapons"] = {},
}
