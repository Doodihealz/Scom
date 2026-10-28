-- ugs5004: Mass Fabricator
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
            ["sourceBlueprint"] = "units/URB1104/URB1104_unit.bp",
            ["sourceBlueprintSha256"] = "8adf72c514ddbeade7f7b08a150f3dd9a894ad1459a0ff30f5efbb1651431f50",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "URB1104",
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
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_None",
                ["SkirtOffsetX"] = -0.5,
                ["SkirtOffsetZ"] = -0.5,
                ["SkirtSizeX"] = 2,
                ["SkirtSizeZ"] = 2,
                ["TurnRate"] = 0,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1201,
                ["entry"] = "units/URB1104/URB1104_script.lua",
                ["sha256"] = "476489d1ae936c41c16d843bdefa98699b2d87d40685165713a5cf867ba47741",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {
                [1] = {
                    ["Damage"] = 370,
                    ["DamageFriendly"] = true,
                    ["DamageRadius"] = 5,
                    ["DamageType"] = "Normal",
                    ["DisplayName"] = "Death Weapon",
                    ["DummyWeapon"] = true,
                    ["Label"] = "DeathWeapon",
                    ["WeaponCategory"] = "Death",
                },
            },
            ["targetId"] = "ugs5004",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoFaAdjacency"] = {
            ["nativeAdjacency"] = "T1AlloyFabricatorAdjacencyBuff",
            ["parityLimitation"] = "Native T1 alloy-fabricator adjacency uses one factory/station discount instead of FA footprint scaling.",
            ["sourceAdjacency"] = "T1MassFabricatorAdjacencyBuffs",
            ["sourceBlueprintSha256"] = "8adf72c514ddbeade7f7b08a150f3dd9a894ad1459a0ff30f5efbb1651431f50",
            ["sourceId"] = "URB1104",
        },
        ["scoSourceSecondaryVisuals"] = {
            ["effects"] = {},
            ["meshes"] = {},
            ["rotators"] = {
                [1] = {
                    ["acceleration"] = 40,
                    ["axis"] = "z",
                    ["bone"] = "Blade",
                    ["condition"] = "production",
                    ["delay"] = 0,
                    ["disabledAcceleration"] = 40,
                    ["initialSpeed"] = 0,
                    ["speed"] = 150,
                },
            },
            ["sourceBlueprintSha256"] = "8adf72c514ddbeade7f7b08a150f3dd9a894ad1459a0ff30f5efbb1651431f50",
            ["sourceId"] = "URB1104",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1201,
                ["entry"] = "units/URB1104/URB1104_script.lua",
                ["sha256"] = "476489d1ae936c41c16d843bdefa98699b2d87d40685165713a5cf867ba47741",
            },
            ["targetId"] = "ugs5004",
        },
    },
    ["adjacency"] = "T1AlloyFabricatorAdjacencyBuff",
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.7,
            ["y"] = 0.55,
            ["z"] = 0.7,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 360,
            ["regen"] = 0,
            ["value"] = 360,
        },
    },
    ["economy"] = {
        ["buildTime"] = 500,
        ["cost"] = {
            ["alloys"] = 100,
            ["energy"] = 4000,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 150,
        },
        ["production"] = {
            ["alloys"] = 1,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardStructure",
        },
        ["displayName"] = "Mass Fabricator",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 50,
        ["iconUIType"] = "land",
        ["name"] = "Mass Fabricator",
        ["orders"] = {},
        ["toggles"] = {
            ["Production"] = true,
        },
        ["tpId"] = "ugs5004",
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
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_ENGINEER",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "GUARD",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_BUILTBYTIER2COMMANDER",
        [6] = "SCFA_BUILTBYTIER2ENGINEER",
        [7] = "SCFA_BUILTBYTIER3COMMANDER",
        [8] = "SCFA_BUILTBYTIER3ENGINEER",
        [9] = "SCFA_CYBRAN",
        [10] = "SCFA_DRAGBUILD",
        [11] = "SCFA_ECONOMIC",
        [12] = "SCFA_MASSFABRICATION",
        [13] = "SCFA_MASSPRODUCTION",
        [14] = "SCFA_PRODUCTSC1",
        [15] = "SCFA_RECLAIMABLE",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SIZE4",
        [18] = "SCFA_SORTECONOMY",
        [19] = "SCFA_STRUCTURE",
        [20] = "SCFA_TECH2",
        [21] = "SCFA_VISIBLETORECON",
        [22] = "STRUCTURE",
        [23] = "TECH2",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5004/LOD0/ugs5004.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5004/LOD0/ugs5004.sananimation",
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
                    ["x"] = 0.126,
                    ["y"] = 0.1375,
                    ["z"] = -0.13999999999999999,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.099,
                    ["z"] = 0.126,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.13999999999999999,
                    ["y"] = 0.15400000000000003,
                    ["z"] = 0.11199999999999999,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.231,
                    ["z"] = -0.13999999999999999,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.22000000000000003,
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
                ["y"] = 0.65,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 370,
            ["damageFriendly"] = true,
            ["damageRadius"] = 5,
            ["damageType"] = "Normal",
            ["scoFaSourceWeaponIndex"] = 1,
        },
    },
}
