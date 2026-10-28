-- ugs5012: ED2
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
                    ["clipName"] = "FaURB4204Aopen",
                    ["duration"] = 1.3333333730697632,
                    ["entry"] = "units/URB4204/URB4204_Aopen.sca",
                    ["frames"] = 41,
                    ["outputDuration"] = 1.3333333730697632,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "5e789e7d20f52dd7832197399afd2876d787847a4e3c682caa0e414c74f0e914",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 12,
                    ["usedBySource"] = true,
                },
            },
            ["sourceBlueprint"] = "units/URB4204/URB4204_unit.bp",
            ["sourceBlueprintSha256"] = "ffb34c53c36bf2ae438d1c041ba1ba9e1c089a327b93d173e9312def4006dfb9",
            ["sourceBuildableCategory"] = {
                [1] = "urb4205",
            },
            ["sourceId"] = "URB4204",
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
                ["entry"] = "units/URB4204/URB4204_script.lua",
                ["sha256"] = "6df94f4c54e5b135763a1bbd610014958ac95390de79b281a11b21c7d8239420",
            },
            ["sourceShield"] = {
                ["ImpactEffects"] = "CybranShieldHit01",
                ["ImpactMesh"] = "/effects/entities/ShieldSection01/ShieldSection01b_mesh",
                ["Mesh"] = "/effects/entities/CybranShield01/CybranShield01_mesh",
                ["MeshZ"] = "/effects/entities/Shield01/Shield01z_mesh",
                ["RegenAssistMult"] = 60,
                ["ShieldEnergyDrainRechargeTime"] = 5,
                ["ShieldMaxHealth"] = 7000,
                ["ShieldRechargeTime"] = 16,
                ["ShieldRegenRate"] = 88,
                ["ShieldRegenStartTime"] = 1,
                ["ShieldSize"] = 22,
                ["ShieldVerticalOffset"] = -3,
            },
            ["sourceWeapons"] = {},
            ["targetId"] = "ugs5012",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/935041efe2c96b58c041.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_shield_02_generator_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_reacton_02.dds",
                                ["sha256"] = "3ee302ab64e8a6d58db2ed4d63294d7f55b1d1c22bc1af0c35aaa79e6fbe0161",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "f58e2ef490f9f4c5b2b8bb4d9f4874a6e763d1267d0294cebadbc20db3f44dc9",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_shield_02_generator_01",
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
                                            ["y"] = 1.937,
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/d0ac55bc9b11911d0cac.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_shield_02_generator_02_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_16.dds",
                                ["sha256"] = "3dd966f628c49acbd2df92ec0801ca9999f5e216f95e1a420d53716d48d37f7d",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "92c62a9128e595e26562b45156a0e8a11afc380f483d16d7857bc760aa22ae1e",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_shield_02_generator_02",
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
                                            ["y"] = 1,
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
                                            ["y"] = 1,
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/cd2f9d591213a06b271a.sanmaterial",
                            ["path"] = "effects/Emitters/cybran_shield_02_generator_03_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_white_26.dds",
                                ["sha256"] = "690c3f7cf3bdb822b193fee8b6a55dbae2195e8ed923125af6e849fbdd01e9fb",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "bb7ab308b2e6677da1b1c1fa80618c6b8ddbc85fbff5ff20261f0a51593639c6",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "cybran_shield_02_generator_03",
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
                                            ["y"] = -1.537,
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
                    ["path"] = "VFX/SCOM/Source/ugs5012/ambient_shield.sanvfx",
                    ["sha256"] = "45284c4b970414706244c390dd0b0590ddf0931f3a5470b79d4819f9da80f064",
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
                    ["path"] = "VFX/SCOM/Source/ugs5012/ambient_shield.sanvfx",
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
            ["sourceBlueprintSha256"] = "ffb34c53c36bf2ae438d1c041ba1ba9e1c089a327b93d173e9312def4006dfb9",
            ["sourceId"] = "URB4204",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 2021,
                ["entry"] = "units/URB4204/URB4204_script.lua",
                ["sha256"] = "6df94f4c54e5b135763a1bbd610014958ac95390de79b281a11b21c7d8239420",
            },
            ["targetId"] = "ugs5012",
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
        ["canBuild"] = "(Tags.ugs5013) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
        ["upgradesTo"] = "ugs5013",
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
                ["max"] = 7000,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = -3,
                    ["z"] = 0,
                },
                ["radii"] = {
                    ["x"] = 11,
                    ["y"] = 11,
                    ["z"] = 11,
                },
                ["rechargeHPRatio"] = 0.5,
                ["rechargeTime"] = 16,
                ["regen"] = 88,
                ["regenDelay"] = 1,
                ["type"] = 0,
                ["value"] = 7000,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 300,
        ["cost"] = {
            ["alloys"] = 300,
            ["energy"] = 3000,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 200,
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
        ["displayName"] = "ED2",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 160,
        ["iconUIType"] = "land",
        ["name"] = "ED2",
        ["orders"] = {},
        ["toggles"] = {
            ["Shield"] = true,
        },
        ["tpId"] = "ugs5012",
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
                ["sanAnimationPath"] = "Units/ugs5012/LOD0/ugs5012.sananimation",
            },
            ["upgrade"] = {
                ["clipName"] = "FaURB4204Aopen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5012/LOD0/ugs5012.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5012/LOD0/ugs5012.sananimation",
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
