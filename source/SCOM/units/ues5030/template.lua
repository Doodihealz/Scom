-- ues5030: UEF Manufacturing Facility
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
            ["sourceBlueprint"] = "units/UEC1501/UEC1501_unit.bp",
            ["sourceBlueprintSha256"] = "5197e7b778d555692663540ebd545f91b7ebe861a62de7cf6760b84e6658579a",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "UEC1501",
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
                ["MeshExtentsX"] = 3.2,
                ["MeshExtentsY"] = 3.2,
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
                ["bytes"] = 1262,
                ["entry"] = "units/UEC1501/UEC1501_Script.lua",
                ["sha256"] = "9b47e5ada3690312ffcc400836ea632364939e564ad2634304160cb956882d38",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ues5030",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoSourceSecondaryVisuals"] = {
            ["effectProvenance"] = {
                [1] = {
                    ["emitters"] = {
                        [1] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                                [2] = "ParticleResistance requires source-engine emitter behavior not represented by native particle schema",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/8b3f0e7e5e2ca28cac31.sanmaterial",
                            ["path"] = "effects/Emitters/uec1501_smoke_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_smoke_03.dds",
                                ["sha256"] = "51563a069d8495585334507b1b2cbd4b3594beb12b958d38d26825cfaec75b40",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "81cff135b130ff5a2280741c0a4fcd4e33406866065e25a72e3e9fcfc6e2adf1",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 0,
                                ["BlueprintId"] = "uec1501_smoke_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.401,
                                            ["y"] = 3,
                                            ["z"] = 1,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 2.672,
                                            ["y"] = 0.635,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.5,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.5,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 100,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.836,
                                            ["y"] = 48.571,
                                            ["z"] = 80,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["LocalAcceleration"] = false,
                                ["LocalVelocity"] = false,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = true,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 6.194,
                                            ["y"] = 0.5,
                                            ["z"] = 1,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_smoke_03.dds",
                                ["Repeattime"] = 15,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 6.887,
                                            ["y"] = 0.043,
                                            ["z"] = 0.02,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.5,
                                            ["y"] = 0,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = 0,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.52,
                                            ["y"] = 0.062,
                                            ["z"] = 0.01,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["Texture"] = "/textures/particles/cloud_smoke_alpha_10.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.639,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.718,
                                            ["y"] = -0.002,
                                            ["z"] = 0.001,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.52,
                                            ["y"] = 0,
                                            ["z"] = 0.01,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.53,
                                            ["y"] = 0.001,
                                            ["z"] = 0.001,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.658,
                                            ["y"] = 0.2,
                                            ["z"] = 0.1,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.4,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 4.24,
                                            ["y"] = 0,
                                            ["z"] = 0.001,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 3.03,
                                            ["y"] = 0,
                                            ["z"] = 0.01,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/cloud_smoke_alpha_10.dds",
                                ["sha256"] = "291ce99308f3a59abf7498f3cb8889811bbc7f561493bbc44e84cf18571c831a",
                            },
                            ["timeUnits"] = {
                                ["accelerationMultiplier"] = 100,
                                ["rateMultiplier"] = 10,
                                ["reference"] = "https://wiki.faforever.com/en/Development/Modding/Modding_Emitters",
                                ["secondsPerTick"] = 0.1,
                                ["source"] = "ticks",
                            },
                        },
                    },
                    ["path"] = "VFX/SCOM/Source/ues5030/ambient_smoke1.sanvfx",
                    ["sha256"] = "9bd92305332f4415689f2f5c17aa7f26b088ce872ab10ae1664f321613456b8a",
                },
                [2] = {
                    ["emitters"] = {
                        [1] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                                [2] = "ParticleResistance requires source-engine emitter behavior not represented by native particle schema",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/ca8a989a9875616b9b38.sanmaterial",
                            ["path"] = "effects/Emitters/uec1501_smoke_02_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_smoke_03.dds",
                                ["sha256"] = "51563a069d8495585334507b1b2cbd4b3594beb12b958d38d26825cfaec75b40",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "2c5966293236f11e88af4abae388dac7f0175eae0e82919dc535b9a29ac436f6",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 0,
                                ["BlueprintId"] = "uec1501_smoke_02",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.401,
                                            ["y"] = 2,
                                            ["z"] = 1,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 2.672,
                                            ["y"] = 0.635,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.5,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.5,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 100,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.836,
                                            ["y"] = 48.571,
                                            ["z"] = 80,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["LocalAcceleration"] = false,
                                ["LocalVelocity"] = false,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = true,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 6.194,
                                            ["y"] = 0.5,
                                            ["z"] = 1,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_smoke_03.dds",
                                ["Repeattime"] = 15,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 6.887,
                                            ["y"] = 0.043,
                                            ["z"] = 0.02,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.5,
                                            ["y"] = 0,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = 0,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.52,
                                            ["y"] = 0.062,
                                            ["z"] = 0.01,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["Texture"] = "/textures/particles/cloud_smoke_alpha_10.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.639,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.718,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.52,
                                            ["y"] = 0,
                                            ["z"] = 0.01,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.53,
                                            ["y"] = 0.001,
                                            ["z"] = 0.001,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.658,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.4,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 4.24,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 3.03,
                                            ["y"] = 0,
                                            ["z"] = 0.01,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/cloud_smoke_alpha_10.dds",
                                ["sha256"] = "291ce99308f3a59abf7498f3cb8889811bbc7f561493bbc44e84cf18571c831a",
                            },
                            ["timeUnits"] = {
                                ["accelerationMultiplier"] = 100,
                                ["rateMultiplier"] = 10,
                                ["reference"] = "https://wiki.faforever.com/en/Development/Modding/Modding_Emitters",
                                ["secondsPerTick"] = 0.1,
                                ["source"] = "ticks",
                            },
                        },
                    },
                    ["path"] = "VFX/SCOM/Source/ues5030/ambient_smoke2.sanvfx",
                    ["sha256"] = "389467f86ea7b9ff833869ca191fb1c01b5f220cb5e7559b2e2e5ec23102a128",
                },
            },
            ["effects"] = {
                [1] = {
                    ["bone"] = "Smoke_Left01",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5030/ambient_smoke1.sanvfx",
                    ["sourceBone"] = "Smoke_Left01",
                    ["when"] = "created",
                },
                [2] = {
                    ["bone"] = "Smoke_Left02",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5030/ambient_smoke1.sanvfx",
                    ["sourceBone"] = "Smoke_Left02",
                    ["when"] = "created",
                },
                [3] = {
                    ["bone"] = "Smoke_Left03",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5030/ambient_smoke1.sanvfx",
                    ["sourceBone"] = "Smoke_Left03",
                    ["when"] = "created",
                },
                [4] = {
                    ["bone"] = "Smoke_Left04",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5030/ambient_smoke1.sanvfx",
                    ["sourceBone"] = "Smoke_Left04",
                    ["when"] = "created",
                },
                [5] = {
                    ["bone"] = "Smoke_Left_05",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5030/ambient_smoke1.sanvfx",
                    ["sourceBone"] = "Smoke_Left_05",
                    ["when"] = "created",
                },
                [6] = {
                    ["bone"] = "Smoke_Right01",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5030/ambient_smoke1.sanvfx",
                    ["sourceBone"] = "Smoke_Right01",
                    ["when"] = "created",
                },
                [7] = {
                    ["bone"] = "Smoke_Right02",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5030/ambient_smoke1.sanvfx",
                    ["sourceBone"] = "Smoke_Right02",
                    ["when"] = "created",
                },
                [8] = {
                    ["bone"] = "Smoke_Right03",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5030/ambient_smoke1.sanvfx",
                    ["sourceBone"] = "Smoke_Right03",
                    ["when"] = "created",
                },
                [9] = {
                    ["bone"] = "Smoke_Right04",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5030/ambient_smoke1.sanvfx",
                    ["sourceBone"] = "Smoke_Right04",
                    ["when"] = "created",
                },
                [10] = {
                    ["bone"] = "Smoke_Right05",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5030/ambient_smoke2.sanvfx",
                    ["sourceBone"] = "Smoke_Right05",
                    ["when"] = "created",
                },
                [11] = {
                    ["bone"] = "Smoke_Right06",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5030/ambient_smoke2.sanvfx",
                    ["sourceBone"] = "Smoke_Right06",
                    ["when"] = "created",
                },
            },
            ["meshes"] = {},
            ["sourceBlueprintSha256"] = "5197e7b778d555692663540ebd545f91b7ebe861a62de7cf6760b84e6658579a",
            ["sourceId"] = "UEC1501",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1262,
                ["entry"] = "units/UEC1501/UEC1501_Script.lua",
                ["sha256"] = "9b47e5ada3690312ffcc400836ea632364939e564ad2634304160cb956882d38",
            },
            ["targetId"] = "ues5030",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2.25,
            ["y"] = 1.5,
            ["z"] = 2.25,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1650,
            ["regen"] = 0,
            ["value"] = 1650,
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
        ["x"] = 3,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "UEF Manufacturing Facility",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "land",
        ["name"] = "UEF Manufacturing Facility",
        ["orders"] = {},
        ["tpId"] = "ues5030",
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
        ["x"] = 6,
        ["y"] = 6,
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
                ["sanAnimationPath"] = "Units/ues5030/LOD0/ues5030.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5030/LOD0/ues5030.sananimation",
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
                    ["x"] = 0.40499999999999997,
                    ["y"] = 0.375,
                    ["z"] = -0.45,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.495,
                    ["y"] = 0.27,
                    ["z"] = 0.40499999999999997,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.45,
                    ["y"] = 0.42000000000000004,
                    ["z"] = 0.36,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.40499999999999997,
                    ["y"] = 0.63,
                    ["z"] = -0.45,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.495,
                    ["y"] = 0.6000000000000001,
                    ["z"] = 0.40499999999999997,
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
                ["x"] = 1.9,
                ["y"] = 1.8,
            },
        },
    },
    ["weapons"] = {},
}
