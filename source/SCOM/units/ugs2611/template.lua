-- ugs2611: Power Generator
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["sourceBlueprint"] = "units/URB1201/URB1201_unit.bp",
            ["sourceBlueprintSha256"] = "19cef2bfff64f1dd4f859db54272fbfd5753912baadefc8db898f6b31fc4c0cb",
            ["sourceId"] = "URB1201",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1336,
                ["entry"] = "units/URB1201/URB1201_script.lua",
                ["sha256"] = "9f4f33cbcd1987c3acf5e79305d5c0454902c6ea4cd44b55693f84b92c2258a9",
            },
            ["targetId"] = "ugs2611",
        },
        ["scoSourceSecondaryVisuals"] = {
            ["ambientSource"] = {
                ["baseClass"] = {
                    ["archive"] = "lua.scd",
                    ["path"] = "lua/cybranunits.lua",
                    ["sha256"] = "f126ce26875ef8b51f240296af8bd0d86ff07e3fc4b2a5ebf0a5ba4478687411",
                },
                ["callback"] = "CEnergyCreationUnit.OnStopBeingBuilt",
                ["effectTemplate"] = {
                    ["archive"] = "lua.scd",
                    ["path"] = "lua/EffectTemplates.lua",
                    ["sha256"] = "a38581311b5b575aecde3eecb0805742ca06e1747253dab95346ebb20d9a7702",
                },
                ["sourceBone"] = 0,
                ["template"] = "CT2PowerAmbient",
            },
            ["effectProvenance"] = {
                [1] = {
                    ["emitters"] = {
                        [1] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/e4b1f8249910305219b3.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_t2power_ambient_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_01.dds",
                                ["sha256"] = "784b58918ff448897d8b4abf5cfbe025b84123d8e530836d9985d56e78d39015",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "f763aa5a6be0d4081ee8c4c03d70365a352d42ea840b874fd4e68a0ad063324d",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_t2power_ambient_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0,
                                            ["y"] = 2.5,
                                            ["z"] = 0,
                                        },
                                        [3] = {
                                            ["x"] = 1.847,
                                            ["y"] = 0.833,
                                            ["z"] = 0,
                                        },
                                        [4] = {
                                            ["x"] = 5.805,
                                            ["y"] = 1.75,
                                            ["z"] = 0,
                                        },
                                        [5] = {
                                            ["x"] = 10.29,
                                            ["y"] = 0.917,
                                            ["z"] = 0,
                                        },
                                        [6] = {
                                            ["x"] = 15.765,
                                            ["y"] = 2,
                                            ["z"] = 0,
                                        },
                                        [7] = {
                                            ["x"] = 18.272,
                                            ["y"] = 1.167,
                                            ["z"] = 0,
                                        },
                                        [8] = {
                                            ["x"] = 20,
                                            ["y"] = 2.5,
                                            ["z"] = 0,
                                        },
                                        [9] = {
                                            ["x"] = 20,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.7,
                                            ["z"] = 0.1,
                                        },
                                        [2] = {
                                            ["x"] = 20,
                                            ["y"] = 0.3,
                                            ["z"] = 0.05,
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
                                ["LODCutoff"] = 100,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 2,
                                            ["z"] = 0,
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
                                ["RampTexture"] = "/textures/particles/ramp_blue_01.dds",
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
                                            ["x"] = 19.789,
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
                                            ["x"] = 0,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 20,
                                            ["y"] = 0.2,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Texture"] = "/textures/particles/electricity_bolts_add_01.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 2,
                                            ["z"] = 4,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["TextureStripcount"] = 4,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
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
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = -1,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 20,
                                            ["y"] = -0.7,
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
                                            ["x"] = 0,
                                            ["y"] = 0.2,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 20,
                                            ["y"] = 0.8,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/electricity_bolts_add_01.dds",
                                ["sha256"] = "16bdfe61fe79cd632d32649a3521356d3a6601065a33fcc837b1bc6fcc61ffe9",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/a6aea616cd99aa646e4f.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_t2power_ambient_01b_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_01.dds",
                                ["sha256"] = "784b58918ff448897d8b4abf5cfbe025b84123d8e530836d9985d56e78d39015",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "50c4ae87cf445501ff7ea6392335a38c997e875ac619e35670a339d611ab9ec8",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_t2power_ambient_01b",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.09,
                                            ["y"] = 10,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.7,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.3,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["Flat"] = true,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 100,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 4,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
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
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_01.dds",
                                ["Repeattime"] = 0.5,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.198,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = 0,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.2,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["Texture"] = "/textures/particles/glow.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = -1,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = -0.55,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.2,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
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
                        [3] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/e66943023416d0d0efe1.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_t2power_ambient_02_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_01.dds",
                                ["sha256"] = "784b58918ff448897d8b4abf5cfbe025b84123d8e530836d9985d56e78d39015",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "84075062d6660d4bd72c9b80f7b443a28ceb2e1180602bc0e8a84cbee629d5ea",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_t2power_ambient_02",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 15,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 15,
                                            ["y"] = 1.5,
                                            ["z"] = 0,
                                        },
                                        [3] = {
                                            ["x"] = 20.449,
                                            ["y"] = 0.417,
                                            ["z"] = 0,
                                        },
                                        [4] = {
                                            ["x"] = 24.868,
                                            ["y"] = 1.167,
                                            ["z"] = 0,
                                        },
                                        [5] = {
                                            ["x"] = 27.704,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                        [6] = {
                                            ["x"] = 35,
                                            ["y"] = 1.5,
                                            ["z"] = 0,
                                        },
                                        [7] = {
                                            ["x"] = 35,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 15,
                                            ["y"] = 0.7,
                                            ["z"] = 0.1,
                                        },
                                        [2] = {
                                            ["x"] = 35,
                                            ["y"] = 0.3,
                                            ["z"] = 0.05,
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
                                ["LODCutoff"] = 100,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 2,
                                            ["z"] = 0,
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
                                ["RampTexture"] = "/textures/particles/ramp_blue_01.dds",
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
                                            ["x"] = 19.789,
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
                                            ["x"] = 15,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 35,
                                            ["y"] = 0.2,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Texture"] = "/textures/particles/electricity_bolts_add_01.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 2,
                                            ["z"] = 4,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["TextureStripcount"] = 4,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
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
                                            ["x"] = 15,
                                            ["y"] = -0.768,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 35,
                                            ["y"] = -0.538,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 15,
                                            ["y"] = 0.64,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 35,
                                            ["y"] = 0.448,
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
                                            ["x"] = 15,
                                            ["y"] = 0.2,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 35,
                                            ["y"] = 0.8,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/electricity_bolts_add_01.dds",
                                ["sha256"] = "16bdfe61fe79cd632d32649a3521356d3a6601065a33fcc837b1bc6fcc61ffe9",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/1f3f4fcadda8cbbca84d.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_t2power_ambient_02b_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_01.dds",
                                ["sha256"] = "784b58918ff448897d8b4abf5cfbe025b84123d8e530836d9985d56e78d39015",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "fcd1e612736ba30f8e403dcc9c06522f3232f629202f48ef0f641cda8ca642d2",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_t2power_ambient_02b",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.09,
                                            ["y"] = 10,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.7,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.3,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["Flat"] = true,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 100,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 4,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
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
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_01.dds",
                                ["Repeattime"] = 0.5,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.198,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = 0,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.2,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["Texture"] = "/textures/particles/glow.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = -0.922,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = -0.549,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.768,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.498,
                                            ["y"] = 0.458,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.2,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
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
                        [5] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/6124150c36198e7b767c.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_t2power_ambient_03_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_01.dds",
                                ["sha256"] = "784b58918ff448897d8b4abf5cfbe025b84123d8e530836d9985d56e78d39015",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "46f7c804eab0a278bcbc164bc21e0118a849db0888931a0ebf3bd7e95dd9690a",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_t2power_ambient_03",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 30,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 30,
                                            ["y"] = 1.5,
                                            ["z"] = 0,
                                        },
                                        [3] = {
                                            ["x"] = 33.311,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                        [4] = {
                                            ["x"] = 37.269,
                                            ["y"] = 1.167,
                                            ["z"] = 0,
                                        },
                                        [5] = {
                                            ["x"] = 40.501,
                                            ["y"] = 0.583,
                                            ["z"] = 0,
                                        },
                                        [6] = {
                                            ["x"] = 46.834,
                                            ["y"] = 1.417,
                                            ["z"] = 0,
                                        },
                                        [7] = {
                                            ["x"] = 48.681,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                        [8] = {
                                            ["x"] = 50,
                                            ["y"] = 1.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 30,
                                            ["y"] = 0.7,
                                            ["z"] = 0.1,
                                        },
                                        [2] = {
                                            ["x"] = 50,
                                            ["y"] = 0.3,
                                            ["z"] = 0.05,
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
                                ["LODCutoff"] = 100,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 2,
                                            ["z"] = 0,
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
                                ["RampTexture"] = "/textures/particles/ramp_blue_01.dds",
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
                                            ["x"] = 19.789,
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
                                            ["x"] = 30,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 50,
                                            ["y"] = 0.2,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Texture"] = "/textures/particles/electricity_bolts_add_01.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 2,
                                            ["z"] = 4,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["TextureStripcount"] = 4,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
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
                                            ["x"] = 30,
                                            ["y"] = 0.768,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 50,
                                            ["y"] = 0.538,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 30.013,
                                            ["y"] = 0.64,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 50,
                                            ["y"] = 0.448,
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
                                            ["x"] = 30,
                                            ["y"] = 0.2,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 50,
                                            ["y"] = 0.8,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/electricity_bolts_add_01.dds",
                                ["sha256"] = "16bdfe61fe79cd632d32649a3521356d3a6601065a33fcc837b1bc6fcc61ffe9",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/57a89ff41db27c530603.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_t2power_ambient_03b_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_01.dds",
                                ["sha256"] = "784b58918ff448897d8b4abf5cfbe025b84123d8e530836d9985d56e78d39015",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "32fb7c38964f215b1f28d71f0ec5da690d4dc4b43ac9950a7f94050b802dbd08",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_t2power_ambient_03b",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.09,
                                            ["y"] = 10,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.7,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.3,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["Flat"] = true,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 100,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 4,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
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
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_blue_01.dds",
                                ["Repeattime"] = 0.5,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.198,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = 0,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.2,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["Texture"] = "/textures/particles/glow.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.922,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.549,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.768,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.498,
                                            ["y"] = 0.458,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.25,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.2,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
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
                    ["path"] = "VFX/SCOM/Source/ugs2611/ambient_power.sanvfx",
                    ["sha256"] = "86fef48cc9b0c3615053b2d7d9ad3162aafd5290de01c92d3b17199071afefb9",
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
                    ["path"] = "VFX/SCOM/Source/ugs2611/ambient_power.sanvfx",
                    ["sourceBone"] = "0",
                    ["when"] = "complete",
                },
            },
            ["legacyStaticVisual"] = true,
            ["legacyTemplateClass"] = "GuardEnergyGenerator",
            ["legacyTemplateModule"] = "unitsDefaultGuard",
            ["meshes"] = {},
            ["sourceBlueprint"] = "units/URB1201/URB1201_unit.bp",
            ["sourceBlueprintSha256"] = "19cef2bfff64f1dd4f859db54272fbfd5753912baadefc8db898f6b31fc4c0cb",
            ["sourceId"] = "URB1201",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 268522,
                ["entry"] = "units/URB1201/URB1201_lod0.scm",
                ["sha256"] = "1b3fc45624cd9edcf8e7d2d790290762367fb1dcbd91d92652beb0748607f6d1",
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1336,
                ["entry"] = "units/URB1201/URB1201_script.lua",
                ["sha256"] = "9f4f33cbcd1987c3acf5e79305d5c0454902c6ea4cd44b55693f84b92c2258a9",
            },
            ["targetId"] = "ugs2611",
            ["unsupportedEffects"] = {},
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.47,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3.4,
                ["y"] = 3.1,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 3.4,
            ["y"] = 3.1,
        },
    },
    ["adjacency"] = "T2EnergyGeneratorAdjacencyBuff",
    ["audio"] = {
        ["active"] = {
            ["looping"] = true,
            ["name"] = "aglu2320",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1.47,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 3.2,
            ["y"] = 3.2,
            ["z"] = 2.9,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1600,
            ["regen"] = 2,
            ["value"] = 1600,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1000,
        ["cost"] = {
            ["alloys"] = 1000,
            ["energy"] = 10000,
        },
        ["production"] = {
            ["energy"] = 300,
        },
    },
    ["footprint"] = {
        ["x"] = 4,
        ["y"] = 4,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardEnergyGenerator",
        },
        ["displayName"] = "Power Generator",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "plasma",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_plasma.png",
        ["iconUIBuildSortPriority"] = 360,
        ["iconUIType"] = "amphibious",
        ["name"] = "Power Generator",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "ugs2611",
        ["unitTypeName"] = "GuardT2EnergyGenerator",
    },
    ["intel"] = {
        ["visionRadius"] = 15,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 15,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 15,
        },
    },
    ["skirtSize"] = {
        ["x"] = 6,
        ["y"] = 6,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_ENGINEER",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "ECONOMIC",
        [4] = "ENERGY_PRODUCTION",
        [5] = "GUARD",
        [6] = "STRUCTURE",
        [7] = "TECH2",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_BUILTBYTIER2COMMANDER",
        [10] = "SCFA_BUILTBYTIER2ENGINEER",
        [11] = "SCFA_BUILTBYTIER3COMMANDER",
        [12] = "SCFA_BUILTBYTIER3ENGINEER",
        [13] = "SCFA_CYBRAN",
        [14] = "SCFA_DRAGBUILD",
        [15] = "SCFA_ECONOMIC",
        [16] = "SCFA_ENERGYPRODUCTION",
        [17] = "SCFA_PRODUCTSC1",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_SIZE12",
        [21] = "SCFA_SORTECONOMY",
        [22] = "SCFA_STRUCTURE",
        [23] = "SCFA_TECH2",
        [24] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.5,
                ["y"] = 0.5,
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
        ["effectsInstant"] = {
            ["onDeath"] = {
                [1] = {
                    ["audioName"] = "unit_death_land_eda_large",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vgd2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.576,
                    ["y"] = 2.27,
                    ["z"] = -0.58,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.7040000000000001,
                    ["y"] = 2.046,
                    ["z"] = 0.522,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.6400000000000001,
                    ["y"] = 2.366,
                    ["z"] = 0.46399999999999997,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.576,
                    ["y"] = 2.814,
                    ["z"] = -0.58,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.7040000000000001,
                    ["y"] = 2.75,
                    ["z"] = 0.522,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 109,
            ["lod1distance"] = 283,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.47,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3.4,
                ["y"] = 3.1,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 1000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 5,
            ["damageType"] = "Normal",
        },
    },
}

-- These fields intentionally share runtime animation/audio state.
UnitTemplate["additions"]["scoSourceSecondaryVisuals"]["sourceScript"] = UnitTemplate["additions"]["faSourceContract"]["sourceScript"]
