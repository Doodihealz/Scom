-- ues5093: Seraphim Quantum Rift Archway
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
                        [1] = ".Display.AnimationDeath[0].Animation",
                    },
                    ["bytes"] = 38610,
                    ["clipName"] = "FaXSC1901adeath",
                    ["duration"] = 2.3333332538604736,
                    ["entry"] = "units/XSC1901/XSC1901_adeath.sca",
                    ["frames"] = 71,
                    ["outputDuration"] = 2.3333332538604736,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "df0dd322272a6e4d2f43555c7575d23363bc5c50a8d572e335ff5e5312517b3b",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 19,
                    ["usedBySource"] = true,
                },
            },
            ["sourceBlueprint"] = "units/XSC1901/XSC1901_unit.bp",
            ["sourceBlueprintSha256"] = "f4f117baa29b2049f2bcbd0e6bc902a7f7c2a12b717002db6100b84b1a0a37b7",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "XSC1901",
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
                ["MeshExtentsY"] = 2.2,
                ["MeshExtentsZ"] = 3.2,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_None",
                ["SkirtOffsetX"] = -1.5,
                ["SkirtOffsetZ"] = -1.5,
                ["SkirtSizeX"] = 9,
                ["SkirtSizeZ"] = 9,
                ["TurnRate"] = 0,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 3120,
                ["entry"] = "units/XSC1901/XSC1901_Script.lua",
                ["sha256"] = "e2b3168c9ac40cd4412d51da9f70677e991fb90caeebb95888156ad6c23cafdc",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ues5093",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoIdleResetLocomotion"] = true,
        ["scoSourceDeath"] = {
            ["hasMovement"] = false,
            ["sourceId"] = "XSC1901",
            ["variants"] = {
                [1] = {
                    ["durationSeconds"] = 2.3333332538604736,
                    ["key"] = "scoSourceDeath01",
                    ["rateMax"] = 1,
                    ["rateMin"] = 1,
                    ["weight"] = 100,
                },
            },
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/755015da95fd1ddee237.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_base_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_24.dds",
                                ["sha256"] = "0116ef4765512a950eb27a6015684584246e6283e6f6e3a590046307c5113d92",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "9214668790b280a1aa25e121927a80f5c1f21eac8e718980a34d00fa300da3e0",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_base_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 0.1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 15,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = true,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.058,
                                            ["y"] = 50,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 1,
                                            ["z"] = 0.173,
                                        },
                                        [2] = {
                                            ["x"] = 1,
                                            ["y"] = 0,
                                            ["z"] = 0.153,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_24.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 15,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/glow_02.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.49,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.301,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 1,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/glow_02.dds",
                                ["sha256"] = "834ff186bc85e7aca02b710f13967aff7d542dcb6420061c266f684ca2ad83f1",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/5e63fa839b63d6b6727d.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_base_02_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_24.dds",
                                ["sha256"] = "0116ef4765512a950eb27a6015684584246e6283e6f6e3a590046307c5113d92",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "5297cfc2f187a93879f5d14625e820dee6baf43f21a1955bb1fa79329a2f64b7",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_base_02",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 10,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 1,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.996,
                                            ["y"] = 30,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 1,
                                            ["z"] = 0.173,
                                        },
                                        [2] = {
                                            ["x"] = 1,
                                            ["y"] = 0,
                                            ["z"] = 0.153,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_24.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 4.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 3,
                                            ["z"] = 3,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/ser_plasma07.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.49,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.447,
                                            ["y"] = 0,
                                            ["z"] = 3,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.273,
                                            ["y"] = 7.5,
                                            ["z"] = 11,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ser_plasma07.dds",
                                ["sha256"] = "1dd8ba8d5d086955d8ca0395bb7786276e9f7f292b8ba1e9857695951fbd70be",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/400165def1e76de4d417.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_base_03_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_white_premod_01.dds",
                                ["sha256"] = "508d1a64a60ef7111ba2cdcd20a64309c8dad9faf82f77230d72a84796085bbd",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "1da74f42f67b757c6d213a89506f78d14ed8d3255393ca5b931f09578ea5fa80",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 1,
                                ["BlueprintId"] = "seraphim_rift_arch_base_03",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0.75,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.996,
                                            ["y"] = 30,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 1,
                                            ["z"] = 0.173,
                                        },
                                        [2] = {
                                            ["x"] = 1,
                                            ["y"] = 0,
                                            ["z"] = 0.153,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_white_premod_01.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 2,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 3,
                                            ["z"] = 1.5,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/ser_plasma07.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.49,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.447,
                                            ["y"] = 0,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 6,
                                            ["z"] = 8,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ser_plasma07.dds",
                                ["sha256"] = "1dd8ba8d5d086955d8ca0395bb7786276e9f7f292b8ba1e9857695951fbd70be",
                            },
                            ["timeUnits"] = {
                                ["accelerationMultiplier"] = 100,
                                ["rateMultiplier"] = 10,
                                ["reference"] = "https://wiki.faforever.com/en/Development/Modding/Modding_Emitters",
                                ["secondsPerTick"] = 0.1,
                                ["source"] = "ticks",
                            },
                        },
                        [4] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/ea605a09d0a1fb730898.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_base_04_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_white_29.dds",
                                ["sha256"] = "db9164548dea20405127cbf30e3b6d4800c7d9d997fd59d010cc9ed5c78e8c14",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "7f1861cb28779c5b797eca2141cb059a0914f67187bf0b68066c7a2a2f1ffcb6",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_base_04",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 0.4,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.292,
                                            ["y"] = 15,
                                            ["z"] = 4,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = true,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.058,
                                            ["y"] = 50,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.248,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_white_29.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 3,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 6,
                                            ["z"] = 3,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/ring_14.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.49,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.301,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 1,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ring_14.dds",
                                ["sha256"] = "d332ee3f8c907f74bce618d73aca84dbc996505631e4221ed74227019a3c6519",
                            },
                            ["timeUnits"] = {
                                ["accelerationMultiplier"] = 100,
                                ["rateMultiplier"] = 10,
                                ["reference"] = "https://wiki.faforever.com/en/Development/Modding/Modding_Emitters",
                                ["secondsPerTick"] = 0.1,
                                ["source"] = "ticks",
                            },
                        },
                        [5] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/9d8f1f1f94b301617a03.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_base_05_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_24.dds",
                                ["sha256"] = "0116ef4765512a950eb27a6015684584246e6283e6f6e3a590046307c5113d92",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "3c98f8902c87ae6acd806e9c3829cd8e8021ba04167db9ee2f2cb16b627225ac",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_base_05",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 10,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 1,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.996,
                                            ["y"] = 30,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 1,
                                            ["z"] = 0.173,
                                        },
                                        [2] = {
                                            ["x"] = 1,
                                            ["y"] = 0,
                                            ["z"] = 0.153,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_24.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 4.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 3,
                                            ["z"] = 3,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/ser_plasma07.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.49,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.25,
                                            ["z"] = 0.2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.5,
                                            ["z"] = 1,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.447,
                                            ["y"] = 2.25,
                                            ["z"] = 3,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 6,
                                            ["z"] = 8,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ser_plasma07.dds",
                                ["sha256"] = "1dd8ba8d5d086955d8ca0395bb7786276e9f7f292b8ba1e9857695951fbd70be",
                            },
                            ["timeUnits"] = {
                                ["accelerationMultiplier"] = 100,
                                ["rateMultiplier"] = 10,
                                ["reference"] = "https://wiki.faforever.com/en/Development/Modding/Modding_Emitters",
                                ["secondsPerTick"] = 0.1,
                                ["source"] = "ticks",
                            },
                        },
                        [6] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/3d2a6facbd3852048bd2.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_base_06_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_white_premod_01.dds",
                                ["sha256"] = "508d1a64a60ef7111ba2cdcd20a64309c8dad9faf82f77230d72a84796085bbd",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "0938f087834be3a692ec496ee9b95078eb552e9600e922ca8545ed01de9ee839",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 1,
                                ["BlueprintId"] = "seraphim_rift_arch_base_06",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0.75,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.996,
                                            ["y"] = 30,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 1,
                                            ["z"] = 0.173,
                                        },
                                        [2] = {
                                            ["x"] = 1,
                                            ["y"] = 0,
                                            ["z"] = 0.153,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_white_premod_01.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 2,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 3,
                                            ["z"] = 1.5,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/ser_plasma07.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.49,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.25,
                                            ["z"] = 0.2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.5,
                                            ["z"] = 1,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.447,
                                            ["y"] = 2.25,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 6,
                                            ["z"] = 8,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ser_plasma07.dds",
                                ["sha256"] = "1dd8ba8d5d086955d8ca0395bb7786276e9f7f292b8ba1e9857695951fbd70be",
                            },
                            ["timeUnits"] = {
                                ["accelerationMultiplier"] = 100,
                                ["rateMultiplier"] = 10,
                                ["reference"] = "https://wiki.faforever.com/en/Development/Modding/Modding_Emitters",
                                ["secondsPerTick"] = 0.1,
                                ["source"] = "ticks",
                            },
                        },
                        [7] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/1d78d192747fec0a90c6.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_base_07_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_white_29.dds",
                                ["sha256"] = "db9164548dea20405127cbf30e3b6d4800c7d9d997fd59d010cc9ed5c78e8c14",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "1de52516da42e360591561da675fa09b232892105a6aba0bba676d2018f79825",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_base_07",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = true,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 0,
                                            ["z"] = 30,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.996,
                                            ["y"] = 60,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.22,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_white_29.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 2,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 10,
                                            ["z"] = 6,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/line_white_add_13.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.326,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.3,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.75,
                                            ["z"] = 0.75,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.256,
                                            ["y"] = 10,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 1,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/line_white_add_13.dds",
                                ["sha256"] = "8ef4aa4139b82e648e5e8a9dc76d79c6479cc917972b808e96721985ab1292d4",
                            },
                            ["timeUnits"] = {
                                ["accelerationMultiplier"] = 100,
                                ["rateMultiplier"] = 10,
                                ["reference"] = "https://wiki.faforever.com/en/Development/Modding/Modding_Emitters",
                                ["secondsPerTick"] = 0.1,
                                ["source"] = "ticks",
                            },
                        },
                        [8] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/4fe001e7b7575cd5faec.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_base_08_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_white_29.dds",
                                ["sha256"] = "db9164548dea20405127cbf30e3b6d4800c7d9d997fd59d010cc9ed5c78e8c14",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "b59f73a32bec7b834e11d9408a08ce94a0b161a821e8c6244ae007b04a5a2b65",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_base_08",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = true,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 0,
                                            ["z"] = 30,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.996,
                                            ["y"] = 60,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.22,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_white_29.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 2,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 10,
                                            ["z"] = 6,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/line_white_add_14.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.326,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.3,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = -0.75,
                                            ["z"] = 0.75,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.256,
                                            ["y"] = 10,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 1,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/line_white_add_14.dds",
                                ["sha256"] = "6d913cd8f4090533c6b1a631e6aba3b6543918e345244cfa9a703502038440b5",
                            },
                            ["timeUnits"] = {
                                ["accelerationMultiplier"] = 100,
                                ["rateMultiplier"] = 10,
                                ["reference"] = "https://wiki.faforever.com/en/Development/Modding/Modding_Emitters",
                                ["secondsPerTick"] = 0.1,
                                ["source"] = "ticks",
                            },
                        },
                        [9] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/990a7d841e49e25c5e3a.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_base_09_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_phalanx_premod.dds",
                                ["sha256"] = "1e9627d73937b68103509b3bbec9dbeb501e7f7e547efc86c7e7863ce5e11d1d",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "5be4a6a0710aa33e0abf0ea290aa20028ee4e0c841ae6e7c288769f2cb261330",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_base_09",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.293,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 0,
                                            ["z"] = 30,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.169,
                                            ["y"] = 20,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.22,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_phalanx_premod.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 2,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0.5,
                                            ["z"] = 0.2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/glow.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.326,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.21,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.256,
                                            ["y"] = 10,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.156,
                                            ["y"] = 1,
                                            ["z"] = 1,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 10,
                                            ["z"] = 6,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/glow.dds",
                                ["sha256"] = "cf72608df45b1a4562547439f55273bba6e6a3519e0259819f0cb009fef2e4eb",
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
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift0.sanvfx",
                    ["sha256"] = "96722a1faba832fe7c0812ad55cab76c1c0eb799373dd12a528426aefaeb1583",
                },
                [2] = {
                    ["emitters"] = {
                        [1] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/c21916c708b0d8907ac6.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_top_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_24.dds",
                                ["sha256"] = "0116ef4765512a950eb27a6015684584246e6283e6f6e3a590046307c5113d92",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "449164466487b3b292d8c26a5956900f3f513938fd5ce838f1e740bdc9c94532",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_top_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 0.1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 3.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.058,
                                            ["y"] = 50,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 1,
                                            ["z"] = 0.173,
                                        },
                                        [2] = {
                                            ["x"] = 1,
                                            ["y"] = 0,
                                            ["z"] = 0.153,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_24.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 3.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/glow_02.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.49,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.301,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0.3,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/glow_02.dds",
                                ["sha256"] = "834ff186bc85e7aca02b710f13967aff7d542dcb6420061c266f684ca2ad83f1",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/8125754d1bd711c97518.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_top_02_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_24.dds",
                                ["sha256"] = "0116ef4765512a950eb27a6015684584246e6283e6f6e3a590046307c5113d92",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "283035ec9d250e62a6c6090e44875cc0a2b50754b98a8c49b15d21afb26deed5",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_top_02",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 1.5,
                                            ["z"] = 1,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.996,
                                            ["y"] = 45,
                                            ["z"] = 15,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 1,
                                            ["z"] = 0.173,
                                        },
                                        [2] = {
                                            ["x"] = 1,
                                            ["y"] = 0,
                                            ["z"] = 0.153,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_24.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.245,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0.5,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/ser_plasma07.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.49,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.03,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = -1,
                                            ["z"] = 1,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.447,
                                            ["y"] = 0,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ser_plasma07.dds",
                                ["sha256"] = "1dd8ba8d5d086955d8ca0395bb7786276e9f7f292b8ba1e9857695951fbd70be",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/df1defe089a80213fceb.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_top_03_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_white_premod_01.dds",
                                ["sha256"] = "508d1a64a60ef7111ba2cdcd20a64309c8dad9faf82f77230d72a84796085bbd",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "18420b22e64fbf78b001c1827c8035703120fd068a08d82a8f5d47c12bb82f5e",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 1,
                                ["BlueprintId"] = "seraphim_rift_arch_top_03",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 1.5,
                                            ["z"] = 1,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.996,
                                            ["y"] = 45,
                                            ["z"] = 15,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 1,
                                            ["z"] = 0.173,
                                        },
                                        [2] = {
                                            ["x"] = 1,
                                            ["y"] = 0,
                                            ["z"] = 0.153,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_white_premod_01.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.245,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0.5,
                                            ["z"] = 0.5,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/ser_plasma07.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.49,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.03,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = -1,
                                            ["z"] = 1,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.447,
                                            ["y"] = 0,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 0,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ser_plasma07.dds",
                                ["sha256"] = "1dd8ba8d5d086955d8ca0395bb7786276e9f7f292b8ba1e9857695951fbd70be",
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
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift1.sanvfx",
                    ["sha256"] = "c379d02987dc3defe432f9b9be15d8f58dccaabe872de4727bfb54d3d6d72e5d",
                },
                [3] = {
                    ["emitters"] = {
                        [1] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/a3048ad677757f38f387.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_edge_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_25.dds",
                                ["sha256"] = "8f12c1cac8c7be780960ae959cf67d3a4354cf24ff9b5a627a48b22a745c5a4d",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "52b336b287b64e3312814c39f1e54e73bbc9c144a10bf8f29ea4ba6d03e47b1a",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = true,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_edge_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 10,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0.5,
                                            ["z"] = 0.25,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.996,
                                            ["y"] = 30,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.252,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_25.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 2.25,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/line_white_add_11.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.297,
                                            ["y"] = 2,
                                            ["z"] = 4,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 4,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.1,
                                            ["z"] = 0.2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0.35,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.259,
                                            ["y"] = 1,
                                            ["z"] = 3.65,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0.35,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.253,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 10,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/line_white_add_11.dds",
                                ["sha256"] = "423ad42211645af85e23918ac2c1c25fe0eba6a06b14f6e9fde1c4a0a52a675f",
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
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift2.sanvfx",
                    ["sha256"] = "c92b6cdc9ab2806932c6b00d3c0c075c64f29a1c17a24ad4155c60a24c90f139",
                },
                [4] = {
                    ["emitters"] = {
                        [1] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/a3048ad677757f38f387.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_edge_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_25.dds",
                                ["sha256"] = "8f12c1cac8c7be780960ae959cf67d3a4354cf24ff9b5a627a48b22a745c5a4d",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "52b336b287b64e3312814c39f1e54e73bbc9c144a10bf8f29ea4ba6d03e47b1a",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = true,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_edge_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 10,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0.5,
                                            ["z"] = 0.25,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.996,
                                            ["y"] = 30,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.252,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_25.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 2.25,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/line_white_add_11.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.297,
                                            ["y"] = 2,
                                            ["z"] = 4,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 4,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.1,
                                            ["z"] = 0.2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0.35,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.259,
                                            ["y"] = 1,
                                            ["z"] = 3.65,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0.35,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.253,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 10,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/line_white_add_11.dds",
                                ["sha256"] = "423ad42211645af85e23918ac2c1c25fe0eba6a06b14f6e9fde1c4a0a52a675f",
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
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift3.sanvfx",
                    ["sha256"] = "aff867e69a136a91ff45110c3a85c0e6c2e161c9abaab0f63048db9418709565",
                },
                [5] = {
                    ["emitters"] = {
                        [1] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/a3048ad677757f38f387.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_edge_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_25.dds",
                                ["sha256"] = "8f12c1cac8c7be780960ae959cf67d3a4354cf24ff9b5a627a48b22a745c5a4d",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "52b336b287b64e3312814c39f1e54e73bbc9c144a10bf8f29ea4ba6d03e47b1a",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = true,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_edge_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 10,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0.5,
                                            ["z"] = 0.25,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.996,
                                            ["y"] = 30,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.252,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_25.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 2.25,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/line_white_add_11.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.297,
                                            ["y"] = 2,
                                            ["z"] = 4,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 4,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.1,
                                            ["z"] = 0.2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0.35,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.259,
                                            ["y"] = 1,
                                            ["z"] = 3.65,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0.35,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.253,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 10,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/line_white_add_11.dds",
                                ["sha256"] = "423ad42211645af85e23918ac2c1c25fe0eba6a06b14f6e9fde1c4a0a52a675f",
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
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift4.sanvfx",
                    ["sha256"] = "0d77b03d7ee1dc1afae418c26e80929e7502155900b9b242216e33d2ab6af186",
                },
                [6] = {
                    ["emitters"] = {
                        [1] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/a3048ad677757f38f387.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_edge_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_25.dds",
                                ["sha256"] = "8f12c1cac8c7be780960ae959cf67d3a4354cf24ff9b5a627a48b22a745c5a4d",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "52b336b287b64e3312814c39f1e54e73bbc9c144a10bf8f29ea4ba6d03e47b1a",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = true,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_edge_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 10,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0.5,
                                            ["z"] = 0.25,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.996,
                                            ["y"] = 30,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.252,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_25.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 2.25,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/line_white_add_11.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.297,
                                            ["y"] = 2,
                                            ["z"] = 4,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 4,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.1,
                                            ["z"] = 0.2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0.35,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.259,
                                            ["y"] = 1,
                                            ["z"] = 3.65,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0.35,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.253,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 10,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/line_white_add_11.dds",
                                ["sha256"] = "423ad42211645af85e23918ac2c1c25fe0eba6a06b14f6e9fde1c4a0a52a675f",
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
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift5.sanvfx",
                    ["sha256"] = "6b3aa95d69f1370457f5770eae53f241361049a89060af5fbfcce9e3abe7d3af",
                },
                [7] = {
                    ["emitters"] = {
                        [1] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/a3048ad677757f38f387.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_edge_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_25.dds",
                                ["sha256"] = "8f12c1cac8c7be780960ae959cf67d3a4354cf24ff9b5a627a48b22a745c5a4d",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "52b336b287b64e3312814c39f1e54e73bbc9c144a10bf8f29ea4ba6d03e47b1a",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = true,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_edge_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 10,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0.5,
                                            ["z"] = 0.25,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.996,
                                            ["y"] = 30,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.252,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_25.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 2.25,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/line_white_add_11.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.297,
                                            ["y"] = 2,
                                            ["z"] = 4,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 4,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.1,
                                            ["z"] = 0.2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0.35,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.259,
                                            ["y"] = 1,
                                            ["z"] = 3.65,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0.35,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.253,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 10,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/line_white_add_11.dds",
                                ["sha256"] = "423ad42211645af85e23918ac2c1c25fe0eba6a06b14f6e9fde1c4a0a52a675f",
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
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift6.sanvfx",
                    ["sha256"] = "dfaee45b12625059ace794394ba219de6e91f2609853230b9bacb93bc5f9e40e",
                },
                [8] = {
                    ["emitters"] = {
                        [1] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/a3048ad677757f38f387.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_rift_arch_edge_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_25.dds",
                                ["sha256"] = "8f12c1cac8c7be780960ae959cf67d3a4354cf24ff9b5a627a48b22a745c5a4d",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "52b336b287b64e3312814c39f1e54e73bbc9c144a10bf8f29ea4ba6d03e47b1a",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = true,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_rift_arch_edge_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.103,
                                            ["y"] = 10,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0.5,
                                            ["z"] = 0.25,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.277,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 500,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.996,
                                            ["y"] = 30,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["LocalAcceleration"] = true,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.252,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_25.dds",
                                ["Repeattime"] = 1,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.435,
                                            ["y"] = 0,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.284,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -5,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 2.25,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["Texture"] = "/textures/particles/line_white_add_11.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.297,
                                            ["y"] = 2,
                                            ["z"] = 4,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["TextureStripcount"] = 4,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.1,
                                            ["z"] = 0.2,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0.35,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.259,
                                            ["y"] = 1,
                                            ["z"] = 3.65,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0.35,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.253,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.55,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.51,
                                            ["y"] = 10,
                                            ["z"] = 20,
                                        },
                                    },
                                    ["XRange"] = 1,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/line_white_add_11.dds",
                                ["sha256"] = "423ad42211645af85e23918ac2c1c25fe0eba6a06b14f6e9fde1c4a0a52a675f",
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
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift7.sanvfx",
                    ["sha256"] = "4637609791bc6c428befb71590c8868d02f9dc590f7dfd6bf62fbd991109443b",
                },
            },
            ["effects"] = {
                [1] = {
                    ["bone"] = "Root",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift0.sanvfx",
                    ["sourceBone"] = "XSC1901",
                    ["when"] = "created",
                },
                [2] = {
                    ["bone"] = "FX_07",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift1.sanvfx",
                    ["sourceBone"] = "FX_07",
                    ["when"] = "created",
                },
                [3] = {
                    ["bone"] = "FX_01",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift2.sanvfx",
                    ["sourceBone"] = "FX_01",
                    ["when"] = "created",
                },
                [4] = {
                    ["bone"] = "FX_02",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift3.sanvfx",
                    ["sourceBone"] = "FX_02",
                    ["when"] = "created",
                },
                [5] = {
                    ["bone"] = "FX_03",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift4.sanvfx",
                    ["sourceBone"] = "FX_03",
                    ["when"] = "created",
                },
                [6] = {
                    ["bone"] = "FX_04",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift5.sanvfx",
                    ["sourceBone"] = "FX_04",
                    ["when"] = "created",
                },
                [7] = {
                    ["bone"] = "FX_05",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift6.sanvfx",
                    ["sourceBone"] = "FX_05",
                    ["when"] = "created",
                },
                [8] = {
                    ["bone"] = "FX_06",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5093/ambient_rift7.sanvfx",
                    ["sourceBone"] = "FX_06",
                    ["when"] = "created",
                },
            },
            ["meshes"] = {},
            ["sourceBlueprintSha256"] = "f4f117baa29b2049f2bcbd0e6bc902a7f7c2a12b717002db6100b84b1a0a37b7",
            ["sourceId"] = "XSC1901",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 3120,
                ["entry"] = "units/XSC1901/XSC1901_Script.lua",
                ["sha256"] = "e2b3168c9ac40cd4412d51da9f70677e991fb90caeebb95888156ad6c23cafdc",
            },
            ["targetId"] = "ues5093",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2.5,
            ["y"] = 2.5,
            ["z"] = 2.5,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 500000,
            ["regen"] = 20,
            ["value"] = 500000,
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
        ["x"] = 6,
        ["y"] = 6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "Seraphim Quantum Rift Archway",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "land",
        ["name"] = "Seraphim Quantum Rift Archway",
        ["orders"] = {},
        ["tpId"] = "ues5093",
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
        ["x"] = 9,
        ["y"] = 9,
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
                ["sanAnimationPath"] = "Units/ues5093/LOD0/ues5093.sananimation",
            },
            ["scoSourceDeath01"] = {
                ["clipName"] = "FaXSC1901adeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5093/LOD0/ues5093.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5093/LOD0/ues5093.sananimation",
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
                    ["x"] = 0.44999999999999996,
                    ["y"] = 0.625,
                    ["z"] = -0.5,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.55,
                    ["y"] = 0.44999999999999996,
                    ["z"] = 0.44999999999999996,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.5,
                    ["y"] = 0.7000000000000001,
                    ["z"] = 0.4,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.44999999999999996,
                    ["y"] = 1.05,
                    ["z"] = -0.5,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.55,
                    ["y"] = 1,
                    ["z"] = 0.44999999999999996,
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
                ["x"] = 2.2,
                ["y"] = 2.2,
            },
        },
    },
    ["weapons"] = {},
}
