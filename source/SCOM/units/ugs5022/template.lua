-- ugs5022: Cybran Agricultural Center
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
            ["sourceBlueprint"] = "units/URC1401/URC1401_unit.bp",
            ["sourceBlueprintSha256"] = "95212bf39f0fbf8dde16294f875a73d19812c92dd06540e649ce5498ebc5b92b",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "URC1401",
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
                ["bytes"] = 1145,
                ["entry"] = "units/URC1401/URC1401_Script.lua",
                ["sha256"] = "33c7c9a5e7561cc548ee61be1f49c28527f7b57cebbfc06c22f04cb6138ec8c4",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ugs5022",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoSourceSecondaryVisuals"] = {
            ["effects"] = {},
            ["meshes"] = {
                [1] = {
                    ["bone"] = "Root",
                    ["entityName"] = "SCO_Secondary_urc1401_window",
                    ["geometry"] = {
                        ["boundsMax"] = {
                            [1] = 20.029438018798828,
                            [2] = 24.576446533203125,
                            [3] = 19.896793365478516,
                        },
                        ["boundsMin"] = {
                            [1] = -20.029441833496094,
                            [2] = 0.5079523324966431,
                            [3] = -16.204166412353516,
                        },
                        ["coordinateBasis"] = "parent source bone; no extra yaw, scale, or 0.01 lift",
                        ["sourcePositionsExact"] = true,
                        ["sourceVertices"] = 177,
                        ["triangles"] = 130,
                        ["vertices"] = 390,
                    },
                    ["material"] = "VFX/SCOM/Secondary/urc1401_window.sanmaterial",
                    ["model"] = "VFX/SCOM/Secondary/urc1401_window.sanmodel",
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["outputs"] = {
                        ["VFX/SCOM/Secondary/urc1401_window.sanmaterial"] = "62cc550a1c65d79de548c9054a65e44410c3344d07b3972f53752931e75894ab",
                        ["VFX/SCOM/Secondary/urc1401_window.sanmodel"] = "ba38aee02e2f39bfdaf086e954320dd4e60e4d5d98f174cbec7fb60873186295",
                        ["VFX/SCOM/Secondary/urc1401_window_albedo.dds"] = "7c181d51ad65884f6d4f0d8221e30c434e3777526184b9f59fd12c467907658f",
                        ["VFX/SCOM/Secondary/urc1401_window_normal.dds"] = "c0a77869012623c55614d7f42f02846f2c87c0f3b1622c331de766c23e00a458",
                        ["VFX/SCOM/Secondary/urc1401_window_specular.dds"] = "4222755b24b55b5cecfb2fe82f4bd27ddb43c96e18e7703d139b41470394ffa8",
                    },
                    ["scale"] = 0.1,
                    ["sourceBone"] = "URC1401",
                    ["sourceMeshBlueprint"] = "/effects/Entities/URC1401_WINDOW/URC1401_WINDOW_mesh.bp",
                    ["sourceShader"] = "GlassAlpha",
                    ["when"] = "created",
                },
            },
            ["sourceBlueprintSha256"] = "95212bf39f0fbf8dde16294f875a73d19812c92dd06540e649ce5498ebc5b92b",
            ["sourceId"] = "URC1401",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1145,
                ["entry"] = "units/URC1401/URC1401_Script.lua",
                ["sha256"] = "33c7c9a5e7561cc548ee61be1f49c28527f7b57cebbfc06c22f04cb6138ec8c4",
            },
            ["targetId"] = "ugs5022",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 3.75,
            ["y"] = 2.75,
            ["z"] = 3.75,
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
            ["alloys"] = 5,
            ["energy"] = 50,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardStructure",
        },
        ["displayName"] = "Cybran Agricultural Center",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "land",
        ["name"] = "Cybran Agricultural Center",
        ["orders"] = {},
        ["tpId"] = "ugs5022",
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
        [2] = "GUARD",
        [3] = "LAND",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_CIVILIAN",
        [6] = "SCFA_CYBRAN",
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
                ["sanAnimationPath"] = "Units/ugs5022/LOD0/ugs5022.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5022/LOD0/ugs5022.sananimation",
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
                    ["x"] = 0.6749999999999999,
                    ["y"] = 0.6875,
                    ["z"] = -0.75,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.825,
                    ["y"] = 0.495,
                    ["z"] = 0.6749999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.75,
                    ["y"] = 0.77,
                    ["z"] = 0.6,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.6749999999999999,
                    ["y"] = 1.155,
                    ["z"] = -0.75,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.825,
                    ["y"] = 1.1,
                    ["z"] = 0.6749999999999999,
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
                ["x"] = 2.65,
                ["y"] = 2.35,
            },
        },
    },
    ["weapons"] = {},
}
