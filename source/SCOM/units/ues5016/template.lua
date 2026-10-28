-- ues5016: Mass Fabricator
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
                    ["blueprintUses"] = {},
                    ["bytes"] = 3856,
                    ["clipName"] = "FaUEB1104Aactivate",
                    ["duration"] = 1,
                    ["entry"] = "units/UEB1104/UEB1104_Aactivate.sca",
                    ["frames"] = 31,
                    ["outputDuration"] = 1,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "7d597f984c2a46904780f66b55afd501b196c2ac405fcff80eb7afd01356c6c3",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 4,
                    ["usedBySource"] = false,
                },
            },
            ["sourceBlueprint"] = "units/UEB1104/UEB1104_unit.bp",
            ["sourceBlueprintSha256"] = "c4ae102f6ed87c4e5c04b2ae019b16b5cf53244dc95ab865e3fc0d12286bdd52",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "UEB1104",
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
                ["MeshExtentsX"] = 1.25,
                ["MeshExtentsY"] = 1,
                ["MeshExtentsZ"] = 1.25,
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
                ["bytes"] = 3265,
                ["entry"] = "units/UEB1104/UEB1104_Script.lua",
                ["sha256"] = "60d41a6adfda3273c930eaf9881aff9bf242d076390e5e6147342341b90c3fe5",
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
            ["targetId"] = "ues5016",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoFaAdjacency"] = {
            ["nativeAdjacency"] = "T1AlloyFabricatorAdjacencyBuff",
            ["parityLimitation"] = "Native T1 alloy-fabricator adjacency uses one factory/station discount instead of FA footprint scaling.",
            ["sourceAdjacency"] = "T1MassFabricatorAdjacencyBuffs",
            ["sourceBlueprintSha256"] = "c4ae102f6ed87c4e5c04b2ae019b16b5cf53244dc95ab865e3fc0d12286bdd52",
            ["sourceId"] = "UEB1104",
        },
        ["scoSourceSecondaryVisuals"] = {
            ["effects"] = {},
            ["meshes"] = {},
            ["sliders"] = {
                [1] = {
                    ["basePosition"] = {
                        [1] = 0.4275,
                        [2] = 0.4244622588157654,
                        [3] = 1.010405469514808e-07,
                    },
                    ["bone"] = "B03",
                    ["closedOffset"] = {
                        [1] = 0,
                        [2] = -0.095,
                        [3] = 0,
                    },
                    ["condition"] = "production",
                    ["sourceBone"] = "B03",
                    ["sourceOffset"] = {
                        [1] = 0,
                        [2] = -1,
                        [3] = 0,
                    },
                    ["sourceSpeed"] = 3,
                    ["speed"] = 0.28500000000000003,
                },
            },
            ["sourceBlueprintSha256"] = "c4ae102f6ed87c4e5c04b2ae019b16b5cf53244dc95ab865e3fc0d12286bdd52",
            ["sourceId"] = "UEB1104",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 3265,
                ["entry"] = "units/UEB1104/UEB1104_Script.lua",
                ["sha256"] = "60d41a6adfda3273c930eaf9881aff9bf242d076390e5e6147342341b90c3fe5",
            },
            ["targetId"] = "ues5016",
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
            ["x"] = 0.8,
            ["y"] = 0.8,
            ["z"] = 0.8,
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
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
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
        ["tpId"] = "ues5016",
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
        [3] = "EDA",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_BUILTBYTIER2COMMANDER",
        [6] = "SCFA_BUILTBYTIER2ENGINEER",
        [7] = "SCFA_BUILTBYTIER3COMMANDER",
        [8] = "SCFA_BUILTBYTIER3ENGINEER",
        [9] = "SCFA_DRAGBUILD",
        [10] = "SCFA_ECONOMIC",
        [11] = "SCFA_MASSFABRICATION",
        [12] = "SCFA_MASSPRODUCTION",
        [13] = "SCFA_PRODUCTSC1",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SIZE4",
        [17] = "SCFA_SORTECONOMY",
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
                ["sanAnimationPath"] = "Units/ues5016/LOD0/ues5016.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5016/LOD0/ues5016.sananimation",
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
                    ["x"] = 0.144,
                    ["y"] = 0.2,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.144,
                    ["z"] = 0.144,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.16000000000000003,
                    ["y"] = 0.22400000000000003,
                    ["z"] = 0.128,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.336,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.32000000000000006,
                    ["z"] = 0.144,
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
