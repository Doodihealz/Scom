-- ues5029: UEF Agricultural Center
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
            ["sourceBlueprint"] = "units/UEC1401/UEC1401_unit.bp",
            ["sourceBlueprintSha256"] = "f595572f0b57ee523ef8cf76477fae2fec8e63e9bf8bab630f7e23ee41805568",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "UEC1401",
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
                ["MeshExtentsX"] = 4.75,
                ["MeshExtentsY"] = 2.75,
                ["MeshExtentsZ"] = 4.75,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_None",
                ["SkirtOffsetX"] = -1.5,
                ["SkirtOffsetZ"] = -1.5,
                ["SkirtSizeX"] = 8,
                ["SkirtSizeZ"] = 8,
                ["TurnRate"] = 0,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1132,
                ["entry"] = "units/UEC1401/UEC1401_Script.lua",
                ["sha256"] = "8f63bf3c6a85a0ed88fc68f73fa28410275f0f949c54e23ff06914a4a0ccd318",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ues5029",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoSourceSecondaryVisuals"] = {
            ["effects"] = {},
            ["meshes"] = {
                [1] = {
                    ["bone"] = "Root",
                    ["entityName"] = "SCO_Secondary_uec1401_window",
                    ["geometry"] = {
                        ["boundsMax"] = {
                            [1] = 10.839350700378418,
                            [2] = 15.137060165405273,
                            [3] = 18.302997589111328,
                        },
                        ["boundsMin"] = {
                            [1] = -10.831913948059082,
                            [2] = 13.255300521850586,
                            [3] = -11.630023002624512,
                        },
                        ["coordinateBasis"] = "parent source bone; no extra yaw, scale, or 0.01 lift",
                        ["sourcePositionsExact"] = true,
                        ["sourceVertices"] = 78,
                        ["triangles"] = 84,
                        ["vertices"] = 252,
                    },
                    ["material"] = "VFX/SCOM/Secondary/uec1401_window.sanmaterial",
                    ["model"] = "VFX/SCOM/Secondary/uec1401_window.sanmodel",
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["outputs"] = {
                        ["VFX/SCOM/Secondary/uec1401_window.sanmaterial"] = "931a404bd528ec196b20ca822baf4b531aa5cb4ce110a49e94b7967b9ab6e8c9",
                        ["VFX/SCOM/Secondary/uec1401_window.sanmodel"] = "a8bf64e3ad991ae772d024b94e2d4cd6c79353d2f96b72b15371fae0abb7a66b",
                        ["VFX/SCOM/Secondary/uec1401_window_albedo.dds"] = "1382728bdb268c6748534ef362d5e9c1e5247920a27679043e766112a1a0a46a",
                        ["VFX/SCOM/Secondary/uec1401_window_normal.dds"] = "c653e1556d24f20a461dd987cdab5d1ae270743ddd82e5fe8ab662ca80e2838c",
                        ["VFX/SCOM/Secondary/uec1401_window_specular.dds"] = "e54c5420944bc2a5092df725b93d0b188c2340485f91519ac2b996bb68e0008a",
                    },
                    ["scale"] = 0.1,
                    ["sourceBone"] = "UEC1401",
                    ["sourceMeshBlueprint"] = "/effects/Entities/UEC1401_WINDOW/UEC1401_WINDOW_mesh.bp",
                    ["sourceShader"] = "GlassAlpha",
                    ["when"] = "created",
                },
            },
            ["sourceBlueprintSha256"] = "f595572f0b57ee523ef8cf76477fae2fec8e63e9bf8bab630f7e23ee41805568",
            ["sourceId"] = "UEC1401",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1132,
                ["entry"] = "units/UEC1401/UEC1401_Script.lua",
                ["sha256"] = "8f63bf3c6a85a0ed88fc68f73fa28410275f0f949c54e23ff06914a4a0ccd318",
            },
            ["targetId"] = "ues5029",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 4,
            ["y"] = 1.5,
            ["z"] = 4,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 2000,
            ["regen"] = 0,
            ["value"] = 2000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 50,
        ["cost"] = {
            ["alloys"] = 100,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "UEF Agricultural Center",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "land",
        ["name"] = "UEF Agricultural Center",
        ["orders"] = {},
        ["tpId"] = "ues5029",
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
        ["x"] = 8,
        ["y"] = 8,
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
                ["sanAnimationPath"] = "Units/ues5029/LOD0/ues5029.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5029/LOD0/ues5029.sananimation",
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
                    ["x"] = 0.72,
                    ["y"] = 0.375,
                    ["z"] = -0.8,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.88,
                    ["y"] = 0.27,
                    ["z"] = 0.72,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8,
                    ["y"] = 0.42000000000000004,
                    ["z"] = 0.64,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.72,
                    ["y"] = 0.63,
                    ["z"] = -0.8,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.88,
                    ["y"] = 0.6000000000000001,
                    ["z"] = 0.72,
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
                ["x"] = 3.1,
                ["y"] = 3.1,
            },
        },
    },
    ["weapons"] = {},
}
