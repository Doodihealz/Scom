-- ugs5001: OpC1 Symbiont Vehicle
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["fuelIntentionallyOmitted"] = false,
            ["runtimeBehaviorApproval"] = false,
            ["sourceAir"] = {},
            ["sourceAnimations"] = {},
            ["sourceBlueprint"] = "units/OPC1002/OPC1002_unit.bp",
            ["sourceBlueprintSha256"] = "32ab6f345fb4bc0e97019e1982979758ab3b2816d29dfa6c5b975dcb6eaff075",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "OPC1002",
            ["sourceIntel"] = {
                ["VisionRadius"] = 18,
            },
            ["sourceMovement"] = {
                ["BackUpDistance"] = 4,
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
                ["MaxAcceleration"] = 0.459,
                ["MaxBrake"] = 2.8,
                ["MaxSpeed"] = 2.8,
                ["MaxSpeedReverse"] = 2.5,
                ["MaxSteerForce"] = 5,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_Land",
                ["TurnRadius"] = 0,
                ["TurnRate"] = 27,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 491,
                ["entry"] = "units/OPC1002/OPC1002_script.lua",
                ["sha256"] = "b293cb90e8f07feb06704c395d53a7c80572f6e6bf6a144ee1a2dbf55acc251d",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ugs5001",
            ["unsupportedWeaponBindings"] = {},
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.45,
            ["y"] = 0.4,
            ["z"] = 0.9,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 128,
            ["regen"] = 0,
            ["value"] = 128,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1,
        ["cost"] = {
            ["alloys"] = 158,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardStructure",
        },
        ["displayName"] = "OpC1 Symbiont Vehicle",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "land",
        ["name"] = "OpC1 Symbiont Vehicle",
        ["orders"] = {
            ["Assist"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ugs5001",
    },
    ["intel"] = {
        ["visionRadius"] = 18,
    },
    ["movement"] = {
        ["acceleration"] = 0.459,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 2.8,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 27,
        ["sortOrder"] = 1,
        ["speed"] = 2.8,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "TracksLand",
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 18,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 18,
        },
    },
    ["tags"] = {
        [1] = "CIVILIAN",
        [2] = "GUARD",
        [3] = "MOBILE",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_CIVILIAN",
        [6] = "SCFA_CYBRAN",
        [7] = "SCFA_MOBILE",
        [8] = "SCFA_OPERATION",
        [9] = "SCFA_RECLAIMABLE",
        [10] = "SCFA_SELECTABLE",
        [11] = "SCFA_SPECIALHIGHPRI",
        [12] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ugs5001/LOD0/ugs5001.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ugs5001/LOD0/ugs5001.sananimation",
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
                    ["x"] = 0.081,
                    ["y"] = 0.1,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.099,
                    ["y"] = 0.072,
                    ["z"] = 0.162,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09000000000000001,
                    ["y"] = 0.11200000000000002,
                    ["z"] = 0.14400000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.081,
                    ["y"] = 0.168,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.099,
                    ["y"] = 0.16000000000000003,
                    ["z"] = 0.162,
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
                ["x"] = 0.5005048751831055,
                ["y"] = 1.0893130493164063,
            },
        },
    },
    ["weapons"] = {},
}
