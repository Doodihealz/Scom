-- ucs5006: Seraphim Ruins
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
            ["sourceBlueprint"] = "units/UAC1901/UAC1901_unit.bp",
            ["sourceBlueprintSha256"] = "2aa6d7082af4bf9d41a156952a789aae0b29231a99d686db8d65be9c7067d34a",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "UAC1901",
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
                ["MeshExtentsX"] = 5.1,
                ["MeshExtentsY"] = 5.1,
                ["MeshExtentsZ"] = 5.1,
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
                ["bytes"] = 1104,
                ["entry"] = "units/UAC1901/UAC1901_Script.lua",
                ["sha256"] = "09306fb25a9482c0368d76cb73e9b6566254fcfe19a9619e46ee5bf5a503f3fb",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ucs5006",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoSourceSecondaryVisuals"] = {
            ["effects"] = {},
            ["meshes"] = {
                [1] = {
                    ["bone"] = "Root",
                    ["entityName"] = "SCO_Secondary_uac1901_dome",
                    ["geometry"] = {
                        ["boundsMax"] = {
                            [1] = 19.515785217285156,
                            [2] = 19.515783309936523,
                            [3] = 18.4404296875,
                        },
                        ["boundsMin"] = {
                            [1] = -19.515783309936523,
                            [2] = -19.515790939331055,
                            [3] = 0.744389533996582,
                        },
                        ["coordinateBasis"] = "parent source bone; no extra yaw, scale, or 0.01 lift",
                        ["sourcePositionsExact"] = true,
                        ["sourceVertices"] = 49,
                        ["triangles"] = 84,
                        ["vertices"] = 252,
                    },
                    ["material"] = "VFX/SCOM/Secondary/uac1901_dome.sanmaterial",
                    ["model"] = "VFX/SCOM/Secondary/uac1901_dome.sanmodel",
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["outputs"] = {
                        ["VFX/SCOM/Secondary/uac1901_dome.sanmaterial"] = "91817b27131da09073dd7c7f94f7b5a95c91767254d20005e4a523626a50de10",
                        ["VFX/SCOM/Secondary/uac1901_dome.sanmodel"] = "f02e1e759c0f0a17240f6544f462b1223bc8787dc6e4e6ec87aa6e405c4a74c6",
                        ["VFX/SCOM/Secondary/uac1901_dome_albedo.dds"] = "ff744559befb8df6227140f6ac9ce81a3f311f9884892971723da0303d4fa9c7",
                        ["VFX/SCOM/Secondary/uac1901_dome_normal.dds"] = "206443fb44e35995e2a076df651d343753247f5d32d48e64266e4bf1cae0caf5",
                        ["VFX/SCOM/Secondary/uac1901_dome_specular.dds"] = "9d2912818d39ed8159c319aebf8ed26bdf631403c0e1a043502494ebba9f5c84",
                    },
                    ["scale"] = 0.1,
                    ["sourceBone"] = "UAC1901",
                    ["sourceMeshBlueprint"] = "/effects/Entities/UAC1901-DOME/UAC1901-DOME_mesh.bp",
                    ["sourceShader"] = "GlassAlpha",
                    ["when"] = "created",
                },
            },
            ["sourceBlueprintSha256"] = "2aa6d7082af4bf9d41a156952a789aae0b29231a99d686db8d65be9c7067d34a",
            ["sourceId"] = "UAC1901",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1104,
                ["entry"] = "units/UAC1901/UAC1901_Script.lua",
                ["sha256"] = "09306fb25a9482c0368d76cb73e9b6566254fcfe19a9619e46ee5bf5a503f3fb",
            },
            ["targetId"] = "ucs5006",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 4.5,
            ["y"] = 2.7,
            ["z"] = 4.5,
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
            [1] = "unitsDefaultChosen",
            [2] = "ChosenStructure",
        },
        ["displayName"] = "Seraphim Ruins",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "land",
        ["name"] = "Seraphim Ruins",
        ["orders"] = {},
        ["tpId"] = "ucs5006",
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
                ["sanAnimationPath"] = "Units/ucs5006/LOD0/ucs5006.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs5006/LOD0/ucs5006.sananimation",
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
                    ["x"] = 0.8099999999999999,
                    ["y"] = 0.675,
                    ["z"] = -0.9,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.99,
                    ["y"] = 0.486,
                    ["z"] = 0.8099999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.9,
                    ["y"] = 0.7560000000000001,
                    ["z"] = 0.72,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8099999999999999,
                    ["y"] = 1.1340000000000001,
                    ["z"] = -0.9,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.99,
                    ["y"] = 1.08,
                    ["z"] = 0.8099999999999999,
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
                ["x"] = 2.75,
                ["y"] = 2.75,
            },
        },
    },
    ["weapons"] = {},
}
