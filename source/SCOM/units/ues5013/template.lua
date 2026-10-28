-- ues5013: UEF Black Sun
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
            ["sourceBlueprint"] = "units/OPE6006/ope6006_unit.bp",
            ["sourceBlueprintSha256"] = "8bc6e7e3395c89e96dac81455d46f1dc2f9e39118711f693320ec665eb00bd48",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "OPE6006",
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
                ["MeshExtentsX"] = 7.5,
                ["MeshExtentsY"] = 3,
                ["MeshExtentsZ"] = 7.5,
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
                ["bytes"] = 551,
                ["entry"] = "units/OPE6006/ope6006_script.lua",
                ["sha256"] = "39c9cb1d71096533ed3b9e6c5c943ebf20a30f744a4bc7e63a502a71573077e9",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ues5013",
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
            ["x"] = 15.3,
            ["y"] = 9,
            ["z"] = 15.3,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 50000,
            ["regen"] = 0,
            ["value"] = 50000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 50,
        ["cost"] = {
            ["alloys"] = 5,
            ["energy"] = 50,
        },
    },
    ["footprint"] = {
        ["x"] = 20,
        ["y"] = 20,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "UEF Black Sun",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "land",
        ["name"] = "UEF Black Sun",
        ["orders"] = {},
        ["tpId"] = "ues5013",
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
        ["x"] = 1,
        ["y"] = 1,
    },
    ["tags"] = {
        [1] = "CIVILIAN",
        [2] = "EDA",
        [3] = "LAND",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_CIVILIAN",
        [6] = "SCFA_LAND",
        [7] = "SCFA_RECLAIMABLE",
        [8] = "SCFA_SELECTABLE",
        [9] = "SCFA_STRUCTURE",
        [10] = "SCFA_UEF",
        [11] = "SCFA_VISIBLETORECON",
        [12] = "STRUCTURE",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5013/LOD0/ues5013.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5013/LOD0/ues5013.sananimation",
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
                    ["x"] = 2.754,
                    ["y"] = 2.25,
                    ["z"] = -3.0600000000000005,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -3.366,
                    ["y"] = 1.6199999999999999,
                    ["z"] = 2.754,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 3.0600000000000005,
                    ["y"] = 2.5200000000000005,
                    ["z"] = 2.448,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 2.754,
                    ["y"] = 3.78,
                    ["z"] = -3.0600000000000005,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -3.366,
                    ["y"] = 3.6,
                    ["z"] = 2.754,
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
                ["x"] = 15.1,
                ["y"] = 15.15,
            },
        },
    },
    ["weapons"] = {},
}
