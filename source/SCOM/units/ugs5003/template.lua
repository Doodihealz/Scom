-- ugs5003: Hydrocarbon Power Plant
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faHydrocarbonPlacement"] = {
            ["fallback"] = "blocked_normal_construction",
            ["nativeResourceSupported"] = false,
            ["sourceRequirement"] = "hydrocarbon_deposit",
            ["supported"] = false,
        },
        ["faSourceContract"] = {
            ["fuelIntentionallyOmitted"] = false,
            ["runtimeBehaviorApproval"] = false,
            ["sourceAir"] = {},
            ["sourceAnimations"] = {},
            ["sourceBlueprint"] = "units/URB1102/URB1102_unit.bp",
            ["sourceBlueprintSha256"] = "5d744a449a2f1c66a8523324b5f37581b2bea656169fc6c260b7d096316bcd99",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "URB1102",
            ["sourceIntel"] = {},
            ["sourceMovement"] = {
                ["BankingSlope"] = 0,
                ["BuildOnLayerCaps"] = {
                    ["LAYER_Air"] = false,
                    ["LAYER_Land"] = true,
                    ["LAYER_Orbit"] = false,
                    ["LAYER_Seabed"] = true,
                    ["LAYER_Sub"] = false,
                    ["LAYER_Water"] = false,
                },
                ["BuildRestriction"] = "RULEUBR_OnHydrocarbonDeposit",
                ["DragCoefficient"] = 0.2,
                ["FlattenSkirt"] = true,
                ["MaxSteerForce"] = 0,
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
                ["bytes"] = 2606,
                ["entry"] = "units/URB1102/URB1102_script.lua",
                ["sha256"] = "8b070f745302826f6394364fe912df10263d26546b88331bcbbed32fb683f51c",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ugs5003",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoFaAdjacency"] = {
            ["nativeAdjacency"] = "T2EnergyGeneratorAdjacencyBuff",
            ["parityLimitation"] = "Native T2 energy adjacency omits FA weapon-energy/rate-of-fire effects and footprint scaling.",
            ["sourceAdjacency"] = "HydrocarbonAdjacencyBuffs",
            ["sourceBlueprintSha256"] = "5d744a449a2f1c66a8523324b5f37581b2bea656169fc6c260b7d096316bcd99",
            ["sourceId"] = "URB1102",
        },
        ["scoHydroPlacement"] = {
            ["creativeDirectSpawnPreserved"] = true,
            ["fallback"] = "blocked_normal_construction",
            ["nativeResourceSupported"] = false,
            ["nativeResourceTypes"] = {
                [1] = "alloys",
            },
            ["normalConstructionSupported"] = false,
            ["reason"] = "Requires a hydrocarbon deposit; this native runtime has no supported hydrocarbon resource type.",
            ["sourceBlueprint"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 5202,
                ["entry"] = "units/URB1102/URB1102_unit.bp",
                ["sha256"] = "5d744a449a2f1c66a8523324b5f37581b2bea656169fc6c260b7d096316bcd99",
            },
            ["sourceId"] = "URB1102",
            ["sourceRequirement"] = "RULEUBR_OnHydrocarbonDeposit",
            ["targetId"] = "ugs5003",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/ff9a0b13f221f8d9bc78.sanmaterial",
                            ["path"] = "effects/Emitters/hydrocarbon_smoke_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_smoke_03.dds",
                                ["sha256"] = "51563a069d8495585334507b1b2cbd4b3594beb12b958d38d26825cfaec75b40",
                            },
                            ["scale"] = 0.5,
                            ["sha256"] = "277c24e455eca7ef0f4259050a6fc8b1bb47365f0e84865f56d42df068e5ec00",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 0,
                                ["BlueprintId"] = "hydrocarbon_smoke_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.263,
                                            ["y"] = 2.453,
                                            ["z"] = 1,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 2.592,
                                            ["y"] = 0.825,
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
                                            ["y"] = 68.571,
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
                                            ["x"] = 7.361,
                                            ["y"] = 0.338,
                                            ["z"] = 0.1,
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
                                            ["z"] = 0.08,
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
                                            ["z"] = 0.002,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.658,
                                            ["y"] = 0.333,
                                            ["z"] = 0.1,
                                        },
                                    },
                                    ["XRange"] = 15,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 7.4,
                                            ["y"] = 0.2,
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
                                            ["z"] = 0.05,
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
                    ["path"] = "VFX/SCOM/Source/ugs5003/ambient_hydro_land.sanvfx",
                    ["sha256"] = "bc090ab409387565564f05a15b9170f313ae8f06cf38a2c0a1633546c034447c",
                },
                [2] = {
                    ["emitters"] = {
                        [1] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/5c61c7695eb8274beb26.sanmaterial",
                            ["path"] = "effects/Emitters/underwater_idle_bubbles_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_water_04.dds",
                                ["sha256"] = "9d0dfa5801ebb441d054ee57263a2334ad4b63bdc453622a4e5423422d3ef012",
                            },
                            ["scale"] = 2,
                            ["sha256"] = "5b238b558b18802e1b430d4e1c5036f6c6fbc406e25f96b5a1f3ea038ffef9c5",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 0,
                                ["BlueprintId"] = "underwater_idle_bubbles_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 45,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 45,
                                            ["y"] = 2.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 29.2,
                                            ["y"] = 0.08,
                                            ["z"] = 0.03,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 30,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["Gravity"] = false,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 30.28,
                                            ["y"] = 180,
                                            ["z"] = 350,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 100,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 29.96,
                                            ["y"] = 30,
                                            ["z"] = 3,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["LocalAcceleration"] = false,
                                ["LocalVelocity"] = false,
                                ["OnlyEmitOnWater"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 30,
                                            ["y"] = 0.3,
                                            ["z"] = 0.58,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_water_04.dds",
                                ["Repeattime"] = 60,
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 29.68,
                                            ["y"] = 0,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 15.04,
                                            ["y"] = 0.08,
                                            ["z"] = 0.05,
                                        },
                                        [2] = {
                                            ["x"] = 45.92,
                                            ["y"] = 0.08,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = -102,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 27.44,
                                            ["y"] = 0.02,
                                            ["z"] = 0.01,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["Texture"] = "/textures/particles/water_bubbles.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 30,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 30,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 5.56,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 30,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [3] = {
                                            ["x"] = 49.88,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 30.16,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 30.16,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                        [3] = {
                                            ["x"] = 30.16,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 30.72,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 24.72,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 30.24,
                                            ["y"] = 0.08,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 30,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 30,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 36.17,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 30,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 60,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/water_bubbles.dds",
                                ["sha256"] = "b98c4cda95cbdc83d65704209e25c57cfbaafe0134747650cb179f3d8c9c0114",
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
                    ["path"] = "VFX/SCOM/Source/ugs5003/ambient_hydro_seabed.sanvfx",
                    ["sha256"] = "00d43fa4e06f242b75b816985bfa8441a706808d397f489ab2f1f8acb0eb9949",
                },
            },
            ["effects"] = {
                [1] = {
                    ["bone"] = "Exhaust01",
                    ["condition"] = "land",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = -0.1,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ugs5003/ambient_hydro_land.sanvfx",
                    ["sourceBone"] = "Exhaust01",
                    ["when"] = "complete",
                },
                [2] = {
                    ["bone"] = "Exhaust02",
                    ["condition"] = "land",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = -0.1,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ugs5003/ambient_hydro_land.sanvfx",
                    ["sourceBone"] = "Exhaust02",
                    ["when"] = "complete",
                },
                [3] = {
                    ["bone"] = "Exhaust03",
                    ["condition"] = "land",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = -0.1,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ugs5003/ambient_hydro_land.sanvfx",
                    ["sourceBone"] = "Exhaust03",
                    ["when"] = "complete",
                },
                [4] = {
                    ["bone"] = "Exhaust04",
                    ["condition"] = "land",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = -0.1,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ugs5003/ambient_hydro_land.sanvfx",
                    ["sourceBone"] = "Exhaust04",
                    ["when"] = "complete",
                },
                [5] = {
                    ["bone"] = "Exhaust01",
                    ["condition"] = "seabed",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = -0.1,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ugs5003/ambient_hydro_seabed.sanvfx",
                    ["sourceBone"] = "Exhaust01",
                    ["when"] = "complete",
                },
                [6] = {
                    ["bone"] = "Exhaust02",
                    ["condition"] = "seabed",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = -0.1,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ugs5003/ambient_hydro_seabed.sanvfx",
                    ["sourceBone"] = "Exhaust02",
                    ["when"] = "complete",
                },
                [7] = {
                    ["bone"] = "Exhaust03",
                    ["condition"] = "seabed",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = -0.1,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ugs5003/ambient_hydro_seabed.sanvfx",
                    ["sourceBone"] = "Exhaust03",
                    ["when"] = "complete",
                },
                [8] = {
                    ["bone"] = "Exhaust04",
                    ["condition"] = "seabed",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = -0.1,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ugs5003/ambient_hydro_seabed.sanvfx",
                    ["sourceBone"] = "Exhaust04",
                    ["when"] = "complete",
                },
            },
            ["meshes"] = {},
            ["sourceBlueprintSha256"] = "5d744a449a2f1c66a8523324b5f37581b2bea656169fc6c260b7d096316bcd99",
            ["sourceId"] = "URB1102",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 2606,
                ["entry"] = "units/URB1102/URB1102_script.lua",
                ["sha256"] = "8b070f745302826f6394364fe912df10263d26546b88331bcbbed32fb683f51c",
            },
            ["targetId"] = "ugs5003",
        },
    },
    ["adjacency"] = "T2EnergyGeneratorAdjacencyBuff",
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2,
            ["y"] = 1.5,
            ["z"] = 2,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1600,
            ["regen"] = 0,
            ["value"] = 1600,
        },
    },
    ["economy"] = {
        ["buildTime"] = 400,
        ["cost"] = {
            ["alloys"] = 160,
            ["energy"] = 800,
        },
        ["production"] = {
            ["energy"] = 100,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardStructure",
        },
        ["displayName"] = "Hydrocarbon Power Plant",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "Hydrocarbon Power Plant",
        ["orders"] = {},
        ["tpId"] = "ugs5003",
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
        [1] = "GUARD",
        [2] = "SCFA_ALLUNITS",
        [3] = "SCFA_CYBRAN",
        [4] = "SCFA_ECONOMIC",
        [5] = "SCFA_ENERGYPRODUCTION",
        [6] = "SCFA_HYDROCARBON",
        [7] = "SCFA_PRODUCTSC1",
        [8] = "SCFA_RECLAIMABLE",
        [9] = "SCFA_SELECTABLE",
        [10] = "SCFA_SIZE12",
        [11] = "SCFA_SORTECONOMY",
        [12] = "SCFA_STRUCTURE",
        [13] = "SCFA_TECH1",
        [14] = "SCFA_VISIBLETORECON",
        [15] = "STRUCTURE",
        [16] = "TECH1",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5003/LOD0/ugs5003.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5003/LOD0/ugs5003.sananimation",
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
                    ["x"] = 0.36,
                    ["y"] = 0.125,
                    ["z"] = -0.4,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 0.020000000000000018,
                    ["z"] = 0.36,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.4,
                    ["y"] = 0.17000000000000004,
                    ["z"] = 0.32,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.36,
                    ["y"] = 0.38,
                    ["z"] = -0.4,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 0.3500000000000001,
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
                ["x"] = 1.8,
                ["y"] = 1.6,
            },
        },
    },
    ["weapons"] = {},
}
