-- ugs3611: Ion Reactor
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["sourceBlueprint"] = "units/URB1301/URB1301_unit.bp",
            ["sourceBlueprintSha256"] = "e1d59ee7ded7cae10c69bfde8fe4a76927de45449b35dd951de2ae3be9947439",
            ["sourceId"] = "URB1301",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1159,
                ["entry"] = "units/URB1301/URB1301_script.lua",
                ["sha256"] = "5705277a509b316841e490379d49c12bc3cd2f90028e467444aaaa1fb399f07b",
            },
            ["targetId"] = "ugs3611",
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
                ["template"] = "CT3PowerAmbient",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/4b21cf7059e4268fdd37.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_t3power_ambient_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_08.dds",
                                ["sha256"] = "8cd70f50714883bacef40d862a656f44a0aa41c81475ac5772812b5516216e6c",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "cfba670b8e4ed16ef8ccb5f576c505eee55aea9e05d760343f7508f6f79bd405",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_t3power_ambient_01",
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
                                            ["y"] = 0.5,
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
                                ["RampTexture"] = "/textures/particles/ramp_blue_08.dds",
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
                                            ["y"] = 0.4,
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
                                            ["x"] = 15,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 15,
                                            ["y"] = 2.2,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 35,
                                            ["y"] = 2.85,
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
                                            ["y"] = -2,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 35,
                                            ["y"] = -1.5,
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/d15a7ed1dd107c1ca8dd.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_t3power_ambient_01b_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_08.dds",
                                ["sha256"] = "8cd70f50714883bacef40d862a656f44a0aa41c81475ac5772812b5516216e6c",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "ddb6e7324b1442304613f53b93740f2df73f95a1e3b01a924e766954a7032fa0",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_t3power_ambient_01b",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.09,
                                            ["y"] = 15,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.8,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.6,
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
                                ["RampTexture"] = "/textures/particles/ramp_blue_08.dds",
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
                                            ["y"] = 0.6,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.5,
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
                                            ["x"] = 0.359,
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
                                            ["y"] = 2.2,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.498,
                                            ["y"] = 3,
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
                                            ["y"] = -2,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = -1.5,
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/d0b046593ad7b27b2ce4.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_t3power_ambient_02_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_08.dds",
                                ["sha256"] = "8cd70f50714883bacef40d862a656f44a0aa41c81475ac5772812b5516216e6c",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "c0673ce4de0683414e5d16bddcf9d64e2d659e823f9b77f2838d3eafd0a10df3",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_t3power_ambient_02",
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
                                ["RampTexture"] = "/textures/particles/ramp_blue_08.dds",
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
                                            ["y"] = -1.738,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 50,
                                            ["y"] = -1.313,
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
                                            ["x"] = 30,
                                            ["y"] = 2.2,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 50,
                                            ["y"] = 2.85,
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
                                            ["y"] = 0.989,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 50,
                                            ["y"] = 0.725,
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/ae4f61dfcafcb130d125.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_t3power_ambient_02b_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_08.dds",
                                ["sha256"] = "8cd70f50714883bacef40d862a656f44a0aa41c81475ac5772812b5516216e6c",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "a193d93cc233217f7498a252f2da3c249560603c50bebcbaa1c44dee06be5923",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_t3power_ambient_02b",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.09,
                                            ["y"] = 15,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.8,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.6,
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
                                ["RampTexture"] = "/textures/particles/ramp_blue_08.dds",
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
                                            ["y"] = 0.6,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.5,
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
                                            ["y"] = -1.738,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = -1.313,
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
                                            ["y"] = 2.2,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.498,
                                            ["y"] = 3,
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
                                            ["y"] = 0.989,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.725,
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/528b857112c917420f2e.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_t3power_ambient_03_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_08.dds",
                                ["sha256"] = "8cd70f50714883bacef40d862a656f44a0aa41c81475ac5772812b5516216e6c",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "712b02ec7d58cfed18307b6030dff0a5e515c868c3317db6d826953a4ef46f3f",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_t3power_ambient_03",
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
                                            ["y"] = 0.5,
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
                                ["RampTexture"] = "/textures/particles/ramp_blue_08.dds",
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
                                            ["y"] = 0.4,
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
                                            ["x"] = 0,
                                            ["y"] = 1.738,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 20,
                                            ["y"] = 1.313,
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
                                            ["y"] = 2.2,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 20,
                                            ["y"] = 2.85,
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
                                            ["y"] = 0.989,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 20,
                                            ["y"] = 0.725,
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/567cd77c8ecc6f2ff80a.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_t3power_ambient_03b_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_08.dds",
                                ["sha256"] = "8cd70f50714883bacef40d862a656f44a0aa41c81475ac5772812b5516216e6c",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "aa396110c67d8982eb9ffad25b9e17d3bfd0f4e8ae5b4be0a7e674de9096f317",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_t3power_ambient_03b",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.09,
                                            ["y"] = 15,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.5,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.8,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.6,
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
                                ["RampTexture"] = "/textures/particles/ramp_blue_08.dds",
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
                                            ["y"] = 0.6,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.5,
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
                                            ["y"] = 1.738,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 1.313,
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
                                            ["y"] = 2.2,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.498,
                                            ["y"] = 3,
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
                                            ["y"] = 0.989,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 0.5,
                                            ["y"] = 0.725,
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
                    ["path"] = "VFX/SCOM/Source/ugs3611/ambient_power.sanvfx",
                    ["sha256"] = "db5c7d9271bfde651b26b878ed110ac4383a745397a465a5273d4fdf18664f54",
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
                    ["path"] = "VFX/SCOM/Source/ugs3611/ambient_power.sanvfx",
                    ["sourceBone"] = "0",
                    ["when"] = "complete",
                },
            },
            ["legacyStaticVisual"] = true,
            ["legacyTemplateClass"] = "GuardEnergyGenerator",
            ["legacyTemplateModule"] = "unitsDefaultGuard",
            ["meshes"] = {},
            ["sourceBlueprint"] = "units/URB1301/URB1301_unit.bp",
            ["sourceBlueprintSha256"] = "e1d59ee7ded7cae10c69bfde8fe4a76927de45449b35dd951de2ae3be9947439",
            ["sourceId"] = "URB1301",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 428233,
                ["entry"] = "units/URB1301/URB1301_lod0.scm",
                ["sha256"] = "b2765f1535c77b41e4b1b3c92d7453c72c6a5a61566d932f55bb9ad7e0f14239",
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1159,
                ["entry"] = "units/URB1301/URB1301_script.lua",
                ["sha256"] = "5705277a509b316841e490379d49c12bc3cd2f90028e467444aaaa1fb399f07b",
            },
            ["targetId"] = "ugs3611",
            ["unsupportedEffects"] = {},
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.85,
                ["z"] = 0.03,
            },
            ["size"] = {
                ["x"] = 6.7,
                ["y"] = 6.6,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 6.7,
            ["y"] = 6.6,
        },
    },
    ["adjacency"] = "T3EnergyGeneratorAdjacencyBuff",
    ["audio"] = {
        ["active"] = {
            ["looping"] = true,
            ["name"] = "aglu2330",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1.85,
            ["z"] = 0.03,
        },
        ["collisionSize"] = {
            ["x"] = 6.5,
            ["y"] = 4.1,
            ["z"] = 6.4,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 8000,
            ["regen"] = 3,
            ["value"] = 8000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 5000,
        ["cost"] = {
            ["alloys"] = 5000,
            ["energy"] = 50000,
        },
        ["production"] = {
            ["energy"] = 2750,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardEnergyGenerator",
        },
        ["displayName"] = "Ion Reactor",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "plasma",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_plasma.png",
        ["iconUIBuildSortPriority"] = 360,
        ["iconUIType"] = "amphibious",
        ["name"] = "Ion Reactor",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "ugs3611",
        ["unitTypeName"] = "GuardT3EnergyGenerator",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
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
        ["x"] = 8,
        ["y"] = 8,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "ECONOMIC",
        [3] = "ENERGY_PRODUCTION",
        [4] = "GUARD",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER3COMMANDER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_CYBRAN",
        [11] = "SCFA_DRAGBUILD",
        [12] = "SCFA_ECONOMIC",
        [13] = "SCFA_ENERGYPRODUCTION",
        [14] = "SCFA_PRODUCTSC1",
        [15] = "SCFA_RECLAIMABLE",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SIZE16",
        [18] = "SCFA_SORTECONOMY",
        [19] = "SCFA_STRUCTURE",
        [20] = "SCFA_TECH3",
        [21] = "SCFA_VISIBLETORECON",
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
                    ["particleName"] = "VFX/Death/vgd2301_death_building_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.17,
                    ["y"] = 2.875,
                    ["z"] = -1.2500000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.43,
                    ["y"] = 2.588,
                    ["z"] = 1.182,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.3,
                    ["y"] = 2.998,
                    ["z"] = 1.054,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.17,
                    ["y"] = 3.572,
                    ["z"] = -1.2500000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.43,
                    ["y"] = 3.49,
                    ["z"] = 1.182,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 176,
            ["lod1distance"] = 459,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.85,
                ["z"] = 0.03,
            },
            ["size"] = {
                ["x"] = 6.7,
                ["y"] = 6.6,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 5000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 10,
            ["damageType"] = "Normal",
        },
    },
}

-- These fields intentionally share runtime animation/audio state.
UnitTemplate["additions"]["scoSourceSecondaryVisuals"]["sourceScript"] = UnitTemplate["additions"]["faSourceContract"]["sourceScript"]
