-- ues5022: Scattershield
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
            ["sourceBlueprint"] = "units/UEB4203/UEB4203_unit.bp",
            ["sourceBlueprintSha256"] = "23fb4baadc09b09b7e2cf40bab743fe905be69a6ddb8c735bd95319d876c911a",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "UEB4203",
            ["sourceIntel"] = {
                ["RadarStealthFieldRadius"] = 24,
                ["ReactivateTime"] = 5,
                ["SonarStealthFieldRadius"] = 24,
                ["VisionRadius"] = 20,
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
                ["MeshExtentsX"] = 3.2,
                ["MeshExtentsY"] = 5,
                ["MeshExtentsZ"] = 3.2,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_None",
                ["SkirtOffsetX"] = -1.5,
                ["SkirtOffsetZ"] = -1.5,
                ["SkirtSizeX"] = 6,
                ["SkirtSizeZ"] = 6,
                ["TurnRate"] = 0,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 681,
                ["entry"] = "units/UEB4203/UEB4203_script.lua",
                ["sha256"] = "515009e3a65f0a851bf7a962ff917732fcd370b56ea196b94d958722440041fd",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ues5022",
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
            ["x"] = 0.9,
            ["y"] = 4,
            ["z"] = 0.9,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 225,
            ["regen"] = 0,
            ["value"] = 225,
        },
    },
    ["economy"] = {
        ["buildTime"] = 450,
        ["cost"] = {
            ["alloys"] = 360,
            ["energy"] = 5400,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 125,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "Scattershield",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 190,
        ["iconUIType"] = "land",
        ["name"] = "Scattershield",
        ["orders"] = {},
        ["tpId"] = "ues5022",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
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
        ["x"] = 6,
        ["y"] = 6,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_ENGINEER",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "EDA",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_BUILTBYTIER2COMMANDER",
        [6] = "SCFA_BUILTBYTIER2ENGINEER",
        [7] = "SCFA_BUILTBYTIER3COMMANDER",
        [8] = "SCFA_BUILTBYTIER3ENGINEER",
        [9] = "SCFA_COUNTERINTELLIGENCE",
        [10] = "SCFA_DRAGBUILD",
        [11] = "SCFA_INTELLIGENCE",
        [12] = "SCFA_OVERLAYCOUNTERINTEL",
        [13] = "SCFA_PRODUCTSC1",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SIZE12",
        [17] = "SCFA_SORTINTEL",
        [18] = "SCFA_STRUCTURE",
        [19] = "SCFA_TECH2",
        [20] = "SCFA_UEF",
        [21] = "SCFA_VISIBLETORECON",
        [22] = "STRUCTURE",
        [23] = "TECH2",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5022/LOD0/ues5022.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5022/LOD0/ues5022.sananimation",
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
                    ["x"] = 0.162,
                    ["y"] = 0.75,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.47,
                    ["z"] = 0.162,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18000000000000002,
                    ["y"] = 0.8700000000000001,
                    ["z"] = 0.14400000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 1.43,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 1.35,
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
                ["y"] = -0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.55,
                ["y"] = 1.55,
            },
        },
    },
    ["weapons"] = {},
}
