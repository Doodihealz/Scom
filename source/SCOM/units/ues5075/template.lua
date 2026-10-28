-- ues5075: UEF Wall Segment
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
            ["sourceBlueprint"] = "units/XEC9007/XEC9007_unit.bp",
            ["sourceBlueprintSha256"] = "1a2810479ef70d57708bbc0f606ea5132a932bfcc0c0fe17e8ba54b97324c07e",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "XEC9007",
            ["sourceIntel"] = {
                ["VisionRadius"] = 0,
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
                ["MaxGroundVariation"] = 50,
                ["MaxSteerForce"] = 0,
                ["MeshExtentsX"] = 1.5,
                ["MeshExtentsY"] = 1,
                ["MeshExtentsZ"] = 1.5,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_None",
                ["SkirtOffsetX"] = 0,
                ["SkirtOffsetZ"] = 0,
                ["SkirtSizeX"] = 3,
                ["SkirtSizeZ"] = 3,
                ["TurnRate"] = 0,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 515,
                ["entry"] = "units/XEC9007/XEC9007_script.lua",
                ["sha256"] = "4d55082816a2c341796da01b29fb50b2081cfe8ca5dac81dee19ab2dbb973ff5",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ues5075",
            ["unsupportedWeaponBindings"] = {},
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 1.2,
        },
        ["collisionSize"] = {
            ["x"] = 3,
            ["y"] = 2,
            ["z"] = 2.5,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 4000,
            ["regen"] = 0,
            ["value"] = 4000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 10,
        ["cost"] = {
            ["alloys"] = 2,
            ["energy"] = 10,
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
        ["displayName"] = "UEF Wall Segment",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "land",
        ["name"] = "UEF Wall Segment",
        ["orders"] = {},
        ["tpId"] = "ues5075",
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
        ["x"] = 3,
        ["y"] = 3,
    },
    ["tags"] = {
        [1] = "EDA",
        [2] = "SCFA_ALLUNITS",
        [3] = "SCFA_BENIGN",
        [4] = "SCFA_DEFENSE",
        [5] = "SCFA_RECLAIMABLE",
        [6] = "SCFA_SELECTABLE",
        [7] = "SCFA_STRUCTURE",
        [8] = "SCFA_TECH1",
        [9] = "SCFA_VISIBLETORECON",
        [10] = "SCFA_WALL",
        [11] = "STRUCTURE",
        [12] = "TECH1",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5075/LOD0/ues5075.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5075/LOD0/ues5075.sananimation",
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
                    ["x"] = 0.54,
                    ["y"] = 0.5,
                    ["z"] = 0.7,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.66,
                    ["y"] = 0.36,
                    ["z"] = 1.65,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.6000000000000001,
                    ["y"] = 0.56,
                    ["z"] = 1.6,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.54,
                    ["y"] = 0.84,
                    ["z"] = 0.7,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.66,
                    ["y"] = 0.8,
                    ["z"] = 1.65,
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
                ["z"] = 1.2,
            },
            ["size"] = {
                ["x"] = 4.2,
                ["y"] = 3.8,
            },
        },
    },
    ["weapons"] = {},
}
