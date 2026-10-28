-- ucs5004: Aeon Agricultural Center
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
            ["sourceBlueprint"] = "units/UAC1401/UAC1401_unit.bp",
            ["sourceBlueprintSha256"] = "428143a96dc41ffafa79d1a5d27ea9ecd32ed3a9a23b8b1d59548a7d4454dab5",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "UAC1401",
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
                ["bytes"] = 1134,
                ["entry"] = "units/UAC1401/UAC1401_Script.lua",
                ["sha256"] = "0b05aa2418febe5181bc8d54dc154bd0088ea0f5375dc5774c7eea62767ea829",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ucs5004",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoSourceSecondaryVisuals"] = {
            ["effects"] = {},
            ["meshes"] = {
                [1] = {
                    ["bone"] = "Root",
                    ["entityName"] = "SCO_Secondary_uac1401_dome",
                    ["geometry"] = {
                        ["boundsMax"] = {
                            [1] = 14.700432777404785,
                            [2] = 13.42010498046875,
                            [3] = 14.700438499450684,
                        },
                        ["boundsMin"] = {
                            [1] = -14.700432777404785,
                            [2] = 1.5432758331298828,
                            [3] = -14.700428009033203,
                        },
                        ["coordinateBasis"] = "parent source bone; no extra yaw, scale, or 0.01 lift",
                        ["sourcePositionsExact"] = true,
                        ["sourceVertices"] = 37,
                        ["triangles"] = 60,
                        ["vertices"] = 180,
                    },
                    ["material"] = "VFX/SCOM/Secondary/uac1401_dome.sanmaterial",
                    ["model"] = "VFX/SCOM/Secondary/uac1401_dome.sanmodel",
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["outputs"] = {
                        ["VFX/SCOM/Secondary/uac1401_dome.sanmaterial"] = "6db757a3b0173d45de592a5d1dfa8ca194d5f59c17c824b096fe915db1aeaf21",
                        ["VFX/SCOM/Secondary/uac1401_dome.sanmodel"] = "3f4fdc86d1a61ad75938c00365ef008a9acac7077fe2b8544f0c206725849d18",
                        ["VFX/SCOM/Secondary/uac1401_dome_albedo.dds"] = "7d3c5ab803fa218d6359954f93929c0ae94a8439d313c84c27a9f6e5bf79535c",
                        ["VFX/SCOM/Secondary/uac1401_dome_normal.dds"] = "3c1e8e4643dd6a677ee9f1e9da190e483b7471b805e08690a06422a8052ef6ce",
                        ["VFX/SCOM/Secondary/uac1401_dome_specular.dds"] = "57a35842b8462d79419cf28106dc0b1e240efbd408ea36df88819bda38aaed1a",
                    },
                    ["scale"] = 0.1,
                    ["sourceBone"] = "UAC1401",
                    ["sourceMeshBlueprint"] = "/effects/Entities/UAC1401-DOME_M001/UAC1401-DOME_mesh.bp",
                    ["sourceShader"] = "GlassAlpha",
                    ["when"] = "created",
                },
            },
            ["sourceBlueprintSha256"] = "428143a96dc41ffafa79d1a5d27ea9ecd32ed3a9a23b8b1d59548a7d4454dab5",
            ["sourceId"] = "UAC1401",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1134,
                ["entry"] = "units/UAC1401/UAC1401_Script.lua",
                ["sha256"] = "0b05aa2418febe5181bc8d54dc154bd0088ea0f5375dc5774c7eea62767ea829",
            },
            ["targetId"] = "ucs5004",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 3.5,
            ["y"] = 1,
            ["z"] = 3.5,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1000,
            ["regen"] = 0,
            ["value"] = 1000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 50,
        ["cost"] = {
            ["alloys"] = 150,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "ChosenStructure",
        },
        ["displayName"] = "Aeon Agricultural Center",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "land",
        ["name"] = "Aeon Agricultural Center",
        ["orders"] = {},
        ["tpId"] = "ucs5004",
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
        [1] = "CHOSEN",
        [2] = "CIVILIAN",
        [3] = "LAND",
        [4] = "SCFA_AEON",
        [5] = "SCFA_ALLUNITS",
        [6] = "SCFA_CIVILIAN",
        [7] = "SCFA_LAND",
        [8] = "SCFA_RECLAIMABLE",
        [9] = "SCFA_SELECTABLE",
        [10] = "SCFA_STRUCTURE",
        [11] = "SCFA_VISIBLETORECON",
        [12] = "STRUCTURE",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs5004/LOD0/ucs5004.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs5004/LOD0/ucs5004.sananimation",
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
                    ["x"] = 0.63,
                    ["y"] = 0.25,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.77,
                    ["y"] = 0.18,
                    ["z"] = 0.63,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.7000000000000001,
                    ["y"] = 0.28,
                    ["z"] = 0.56,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.63,
                    ["y"] = 0.42,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.77,
                    ["y"] = 0.4,
                    ["z"] = 0.63,
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
                ["x"] = 2.8,
                ["y"] = 2.8,
            },
        },
    },
    ["weapons"] = {},
}
