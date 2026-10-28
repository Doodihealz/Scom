-- ugs5013: ED3
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
                    ["blueprintUses"] = {
                        [1] = ".Display.AnimationUpgrade",
                    },
                    ["bytes"] = 14348,
                    ["clipName"] = "FaURB4205Aopen",
                    ["duration"] = 1.3333333730697632,
                    ["entry"] = "units/URB4205/URB4205_Aopen.sca",
                    ["frames"] = 41,
                    ["outputDuration"] = 1.3333333730697632,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "d49df68ebd42366751bdc010b2ef053324953a06a674a4a73abed6f02f5a4d89",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 12,
                    ["usedBySource"] = true,
                },
            },
            ["sourceBlueprint"] = "units/URB4205/URB4205_unit.bp",
            ["sourceBlueprintSha256"] = "1fca98ab7de7a06c63cd92ddec0ebe89f3fc2f61f21ded458cb9a2f5449cc172",
            ["sourceBuildableCategory"] = {
                [1] = "urb4206",
            },
            ["sourceId"] = "URB4205",
            ["sourceIntel"] = {
                ["VisionRadius"] = 20,
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
                ["FlattenSkirt"] = true,
                ["MaxSteerForce"] = 0,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_None",
                ["SkirtOffsetX"] = -2.5,
                ["SkirtOffsetZ"] = -2.5,
                ["SkirtSizeX"] = 6,
                ["SkirtSizeZ"] = 6,
                ["TurnRate"] = 0,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 2021,
                ["entry"] = "units/URB4205/URB4205_script.lua",
                ["sha256"] = "4a86716c5b15e90850ebdeda332ed627b602b2f5a33cc51f250db85077ead93c",
            },
            ["sourceShield"] = {
                ["ImpactEffects"] = "CybranShieldHit01",
                ["ImpactMesh"] = "/effects/entities/ShieldSection01/ShieldSection01b_mesh",
                ["Mesh"] = "/effects/entities/CybranShield01/CybranShield01_mesh",
                ["MeshZ"] = "/effects/entities/Shield01/Shield01z_mesh",
                ["RegenAssistMult"] = 60,
                ["ShieldEnergyDrainRechargeTime"] = 5,
                ["ShieldMaxHealth"] = 10000,
                ["ShieldRechargeTime"] = 18,
                ["ShieldRegenRate"] = 112,
                ["ShieldRegenStartTime"] = 1,
                ["ShieldSize"] = 28,
                ["ShieldVerticalOffset"] = -4,
            },
            ["sourceWeapons"] = {},
            ["targetId"] = "ugs5013",
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
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/81c7859abc70a0282e86.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_shield_03_generator_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_reacton_02.dds",
                                ["sha256"] = "3ee302ab64e8a6d58db2ed4d63294d7f55b1d1c22bc1af0c35aaa79e6fbe0161",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "6de9dc0e7c6535652b61b8c63c51aec6b3b47b2ad62e94e51b2ef7af3e3c347a",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_shield_03_generator_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 9.169,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0.75,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 250,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 7,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["LocalAcceleration"] = false,
                                ["LocalVelocity"] = false,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_reacton_02.dds",
                                ["Repeattime"] = 50,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0.4,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = 0,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 2.5,
                                            ["z"] = 0.75,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Texture"] = "/textures/particles/outrush02.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0.05,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0.25,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0.015,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 11.412,
                                            ["y"] = 0,
                                            ["z"] = 1,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 2.337,
                                            ["z"] = 0.25,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/outrush02.dds",
                                ["sha256"] = "0de1f9d79e2491ee274cbfe7c0cc164ebf06243d1fc52d38003b01be5c199845",
                            },
                            ["timeUnits"] = {
                                ["accelerationMultiplier"] = 100,
                                ["rateMultiplier"] = 10,
                                ["reference"] = "https://wiki.faforever.com/en/Development/Modding/Modding_Emitters",
                                ["secondsPerTick"] = 0.1,
                                ["source"] = "ticks",
                            },
                        },
                        [2] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/57b65992910e26b32b81.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_shield_03_generator_02_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_16.dds",
                                ["sha256"] = "3dd966f628c49acbd2df92ec0801ca9999f5e216f95e1a420d53716d48d37f7d",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "7a0e682067ddaf028ee714649f32f6c6371f1de5f1684b18a6b181068a8647dd",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_shield_03_generator_02",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 2.177,
                                            ["y"] = 3.5,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 2.253,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [3] = {
                                            ["x"] = 7.124,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [4] = {
                                            ["x"] = 9.169,
                                            ["y"] = 3.5,
                                            ["z"] = 0,
                                        },
                                        [5] = {
                                            ["x"] = 19.459,
                                            ["y"] = 3.5,
                                            ["z"] = 0,
                                        },
                                        [6] = {
                                            ["x"] = 20.976,
                                            ["y"] = -0.5,
                                            ["z"] = 0,
                                        },
                                        [7] = {
                                            ["x"] = 27.243,
                                            ["y"] = -0.5,
                                            ["z"] = 0,
                                        },
                                        [8] = {
                                            ["x"] = 28.166,
                                            ["y"] = 3.5,
                                            ["z"] = 0,
                                        },
                                        [9] = {
                                            ["x"] = 36.346,
                                            ["y"] = 3.5,
                                            ["z"] = 0,
                                        },
                                        [10] = {
                                            ["x"] = 36.807,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [11] = {
                                            ["x"] = 40.844,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [12] = {
                                            ["x"] = 42.348,
                                            ["y"] = 3.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 14.446,
                                            ["y"] = 1.1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 250,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 1,
                                            ["z"] = 1,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["LocalAcceleration"] = false,
                                ["LocalVelocity"] = false,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_16.dds",
                                ["Repeattime"] = 50,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = 0,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 15.633,
                                            ["y"] = 1.1,
                                            ["z"] = 0.35,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Texture"] = "/textures/particles/electricity_06.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0.05,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0.015,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 10.554,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 6.794,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 3,
                                            ["z"] = 3,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/electricity_06.dds",
                                ["sha256"] = "eec79f2c82311b0cf6584ac245e72e47a9361a0ac174ab87c07f5e082728dbc7",
                            },
                            ["timeUnits"] = {
                                ["accelerationMultiplier"] = 100,
                                ["rateMultiplier"] = 10,
                                ["reference"] = "https://wiki.faforever.com/en/Development/Modding/Modding_Emitters",
                                ["secondsPerTick"] = 0.1,
                                ["source"] = "ticks",
                            },
                        },
                        [3] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/a2a71856f7b2728e7af7.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_shield_03_generator_03_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_white_26.dds",
                                ["sha256"] = "690c3f7cf3bdb822b193fee8b6a55dbae2195e8ed923125af6e849fbdd01e9fb",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "c771036033f41db39c6786f7328bfc9279049bf2c6675975a3621386261d479a",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_shield_03_generator_03",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 2.177,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 2.253,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [3] = {
                                            ["x"] = 7.124,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [4] = {
                                            ["x"] = 9.169,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                        [5] = {
                                            ["x"] = 19.459,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                        [6] = {
                                            ["x"] = 20.976,
                                            ["y"] = -0.5,
                                            ["z"] = 0,
                                        },
                                        [7] = {
                                            ["x"] = 27.243,
                                            ["y"] = -0.5,
                                            ["z"] = 0,
                                        },
                                        [8] = {
                                            ["x"] = 28.166,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                        [9] = {
                                            ["x"] = 36.346,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                        [10] = {
                                            ["x"] = 36.807,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [11] = {
                                            ["x"] = 40.844,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [12] = {
                                            ["x"] = 42.348,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 3.85,
                                            ["z"] = 0.317,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Flat"] = true,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 250,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 1.95,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["LocalAcceleration"] = false,
                                ["LocalVelocity"] = false,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_white_26.dds",
                                ["Repeattime"] = 50,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = 0,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 7.5,
                                            ["z"] = 8,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Texture"] = "/textures/particles/glow_03.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0.05,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0.115,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 11.016,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 6.794,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = -1.937,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/glow_03.dds",
                                ["sha256"] = "35f64331dbf3203cd8a120ce66dfeb79092dbff82451bff9ad95dd3236e13bb5",
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
                    ["path"] = "VFX/SCOM/Source/ugs5013/ambient_shield.sanvfx",
                    ["sha256"] = "0958c4c43c21e5a92f4fc4e91f0fd97e30c315a2e302ea7a32fa9b6adc0ad9f8",
                },
            },
            ["effects"] = {
                [1] = {
                    ["bone"] = "Shaft",
                    ["condition"] = "shield",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ugs5013/ambient_shield.sanvfx",
                    ["sourceBone"] = "Shaft",
                    ["when"] = "complete",
                },
            },
            ["meshes"] = {},
            ["rotators"] = {
                [1] = {
                    ["acceleration"] = 5,
                    ["axis"] = "z",
                    ["bone"] = "Shaft",
                    ["condition"] = "shield",
                    ["delay"] = 0,
                    ["disabledAcceleration"] = 5,
                    ["initialSpeed"] = 30,
                    ["initialTarget"] = 30,
                    ["speed"] = 10,
                },
            },
            ["sourceBlueprintSha256"] = "1fca98ab7de7a06c63cd92ddec0ebe89f3fc2f61f21ded458cb9a2f5449cc172",
            ["sourceId"] = "URB4205",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 2021,
                ["entry"] = "units/URB4205/URB4205_script.lua",
                ["sha256"] = "4a86716c5b15e90850ebdeda332ed627b602b2f5a33cc51f250db85077ead93c",
            },
            ["targetId"] = "ugs5013",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2,
            ["y"] = 5,
            ["z"] = 2,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Root",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.ugs5014) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
        ["upgradesTo"] = "ugs5014",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 500,
            ["regen"] = 0,
            ["value"] = 500,
        },
        ["shields"] = {
            [1] = {
                ["boneName"] = "Root",
                ["max"] = 10000,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = -4,
                    ["z"] = 0,
                },
                ["radii"] = {
                    ["x"] = 14,
                    ["y"] = 14,
                    ["z"] = 14,
                },
                ["rechargeHPRatio"] = 0.5,
                ["rechargeTime"] = 18,
                ["regen"] = 112,
                ["regenDelay"] = 1,
                ["type"] = 0,
                ["value"] = 10000,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 800,
        ["cost"] = {
            ["alloys"] = 800,
            ["energy"] = 12000,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 300,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardStructure",
        },
        ["displayName"] = "ED3",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 160,
        ["iconUIType"] = "land",
        ["name"] = "ED3",
        ["orders"] = {},
        ["toggles"] = {
            ["Shield"] = true,
        },
        ["tpId"] = "ugs5013",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 5,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
    },
    ["skirtSize"] = {
        ["x"] = 6,
        ["y"] = 6,
    },
    ["tags"] = {
        [1] = "GUARD",
        [2] = "SCFA_ALLUNITS",
        [3] = "SCFA_CYBRAN",
        [4] = "SCFA_DEFENSE",
        [5] = "SCFA_DRAGBUILD",
        [6] = "SCFA_OVERLAYDEFENSE",
        [7] = "SCFA_PRODUCTSC1",
        [8] = "SCFA_RECLAIMABLE",
        [9] = "SCFA_SELECTABLE",
        [10] = "SCFA_SHIELD",
        [11] = "SCFA_SHOWQUEUE",
        [12] = "SCFA_SIZE12",
        [13] = "SCFA_SORTDEFENSE",
        [14] = "SCFA_STRUCTURE",
        [15] = "SCFA_TECH2",
        [16] = "SCFA_VISIBLETORECON",
        [17] = "STRUCTURE",
        [18] = "TECH2",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5013/LOD0/ugs5013.sananimation",
            },
            ["upgrade"] = {
                ["clipName"] = "FaURB4205Aopen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5013/LOD0/ugs5013.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5013/LOD0/ugs5013.sananimation",
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
                    ["x"] = 0.36,
                    ["y"] = 1,
                    ["z"] = -0.4,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 0.6499999999999999,
                    ["z"] = 0.36,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.4,
                    ["y"] = 1.1500000000000001,
                    ["z"] = 0.32,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.36,
                    ["y"] = 1.85,
                    ["z"] = -0.4,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 1.75,
                    ["z"] = 0.36,
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
                ["y"] = -0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.2,
                ["y"] = 2.2,
            },
        },
    },
    ["weapons"] = {},
}
