-- uel5003: Black Sun Component
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
            ["sourceBlueprint"] = "units/OPE6003/OPE6003_unit.bp",
            ["sourceBlueprintSha256"] = "6eb9ab3d7abf01cd7685596597328c5632c0c3551397fe84ef2e48f26a02f7a2",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "OPE6003",
            ["sourceIntel"] = {
                ["VisionRadius"] = 18,
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
                ["MaxAcceleration"] = 1.2,
                ["MaxSpeed"] = 2.5,
                ["MaxSpeedReverse"] = 0,
                ["MaxSteerForce"] = 5,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_Land",
                ["TurnRadius"] = 0,
                ["TurnRate"] = 180,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 452,
                ["entry"] = "units/OPE6003/OPE6003_Script.lua",
                ["sha256"] = "5fb2d78ae4f4226de3d011a4a2d9aac3e7241f7380498088ed0943a868d87917",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "uel5003",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0,
                [3] = 0,
            },
            ["attachmentReference"] = "entity origin fallback: source model has no AttachPoint",
            ["canFire"] = true,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "OPE6003",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 70795,
                ["entry"] = "units/UEC0001/UEC0001_lod0.scm",
                ["sha256"] = "81e873f9ab965b7c7789b91cfc202ea79d5ba526a8dd0fb733f673e6e6e3bfc3",
            },
        },
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/uel5003/LOD0/uel5003_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.08397004008293152,
                        ["y"] = 0.00029794417030432085,
                        ["z"] = 0.09588407720072922,
                    },
                    ["width"] = 0.071748,
                },
                [2] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.08397003635764122,
                        ["y"] = 0.0002979237288207547,
                        ["z"] = -0.17452280228392467,
                    },
                    ["width"] = 0.071748,
                },
                [3] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.08397003635764122,
                        ["y"] = 0.0002979471022998848,
                        ["z"] = 0.18509115273698104,
                    },
                    ["width"] = 0.071748,
                },
                [4] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.08397004008293152,
                        ["y"] = 0.0002979358360142247,
                        ["z"] = -0.1745228022839267,
                    },
                    ["width"] = 0.071748,
                },
                [5] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.08397004008293152,
                        ["y"] = 0.000297956277500303,
                        ["z"] = 0.09588409210188838,
                    },
                    ["width"] = 0.071748,
                },
                [6] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.08397004008293152,
                        ["y"] = 0.0002979601408159294,
                        ["z"] = 0.18509115273697885,
                    },
                    ["width"] = 0.071748,
                },
            },
            ["unit"] = "uel5003",
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
            ["max"] = 264,
            ["regen"] = 0,
            ["value"] = 264,
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
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDALandUnit",
        },
        ["displayName"] = "Black Sun Component",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_direct.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "land",
        ["name"] = "Black Sun Component",
        ["orders"] = {
            ["Assist"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "uel5003",
    },
    ["intel"] = {
        ["visionRadius"] = 18,
    },
    ["movement"] = {
        ["acceleration"] = 1.2,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 180,
        ["sortOrder"] = 1,
        ["speed"] = 2.5,
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
        [1] = "EDA",
        [2] = "LAND",
        [3] = "MOBILE",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_LAND",
        [6] = "SCFA_MOBILE",
        [7] = "SCFA_OPERATION",
        [8] = "SCFA_RECLAIMABLE",
        [9] = "SCFA_SELECTABLE",
        [10] = "SCFA_UNTARGETABLE",
        [11] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uel5003/LOD0/uel5003.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uel5003/LOD0/uel5003.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
            },
            ["mainBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 20,
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
            ["lod0distance"] = 65,
            ["lod1distance"] = 171,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.6,
            },
        },
    },
    ["weapons"] = {},
}
