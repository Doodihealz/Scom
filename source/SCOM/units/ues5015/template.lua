-- ues5015: HCPP - X1000
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
            ["sourceBlueprint"] = "units/UEB1102/UEB1102_unit.bp",
            ["sourceBlueprintSha256"] = "c881c49165ff33b9644eb62910fad3ed2075fdf732f1fc5dceb028b673f710fc",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "UEB1102",
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
                ["MeshExtentsX"] = 3.25,
                ["MeshExtentsY"] = 1.5,
                ["MeshExtentsZ"] = 3.25,
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
                ["bytes"] = 3880,
                ["entry"] = "units/UEB1102/UEB1102_script.lua",
                ["sha256"] = "94db51b59a92dac9a715894f81e13e83ae6aa6834db14990c58734115759d8bc",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ues5015",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoFaAdjacency"] = {
            ["nativeAdjacency"] = "T2EnergyGeneratorAdjacencyBuff",
            ["parityLimitation"] = "Native T2 energy adjacency omits FA weapon-energy/rate-of-fire effects and footprint scaling.",
            ["sourceAdjacency"] = "HydrocarbonAdjacencyBuffs",
            ["sourceBlueprintSha256"] = "c881c49165ff33b9644eb62910fad3ed2075fdf732f1fc5dceb028b673f710fc",
            ["sourceId"] = "UEB1102",
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
                ["bytes"] = 5342,
                ["entry"] = "units/UEB1102/UEB1102_unit.bp",
                ["sha256"] = "c881c49165ff33b9644eb62910fad3ed2075fdf732f1fc5dceb028b673f710fc",
            },
            ["sourceId"] = "UEB1102",
            ["sourceRequirement"] = "RULEUBR_OnHydrocarbonDeposit",
            ["targetId"] = "ues5015",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/355b7ac21f005c712bac.sanmaterial",
                            ["path"] = "effects/Emitters/hydrocarbon_smoke_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_smoke_03.dds",
                                ["sha256"] = "51563a069d8495585334507b1b2cbd4b3594beb12b958d38d26825cfaec75b40",
                            },
                            ["scale"] = 1,
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
                    ["path"] = "VFX/SCOM/Source/ues5015/ambient_hydro_land.sanvfx",
                    ["sha256"] = "e197bf27d04d24c2384683600e024e25610579f38e24c7a1b0b4e267e0d7079b",
                },
                [2] = {
                    ["emitters"] = {
                        [1] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/5d3bd7e9d91600b4233b.sanmaterial",
                            ["path"] = "effects/Emitters/underwater_idle_bubbles_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_water_04.dds",
                                ["sha256"] = "9d0dfa5801ebb441d054ee57263a2334ad4b63bdc453622a4e5423422d3ef012",
                            },
                            ["scale"] = 3,
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
                    ["path"] = "VFX/SCOM/Source/ues5015/ambient_hydro_seabed.sanvfx",
                    ["sha256"] = "4846cf301aaf2c814e69cdc86a7ae64e4f2b231a5df5f5a1769c173c845a833f",
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
                    ["path"] = "VFX/SCOM/Source/ues5015/ambient_hydro_land.sanvfx",
                    ["sourceBone"] = "Exhaust01",
                    ["when"] = "complete",
                },
                [2] = {
                    ["bone"] = "Exhaust01",
                    ["condition"] = "seabed",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = -0.1,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5015/ambient_hydro_seabed.sanvfx",
                    ["sourceBone"] = "Exhaust01",
                    ["when"] = "complete",
                },
            },
            ["meshes"] = {},
            ["sourceBlueprintSha256"] = "c881c49165ff33b9644eb62910fad3ed2075fdf732f1fc5dceb028b673f710fc",
            ["sourceId"] = "UEB1102",
            ["sourceLimitations"] = {
                [1] = "Retail AnimationOpen units/ueb1102/ueb1102_aopen.sca absent across installed archives; available source smoke begins at completion without an invented opening delay.",
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 3880,
                ["entry"] = "units/UEB1102/UEB1102_script.lua",
                ["sha256"] = "94db51b59a92dac9a715894f81e13e83ae6aa6834db14990c58734115759d8bc",
            },
            ["targetId"] = "ues5015",
        },
    },
    ["adjacency"] = "T2EnergyGeneratorAdjacencyBuff",
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2.5,
            ["y"] = 1.3,
            ["z"] = 2.5,
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
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "HCPP - X1000",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "HCPP - X1000",
        ["orders"] = {},
        ["tpId"] = "ues5015",
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
        [1] = "EDA",
        [2] = "SCFA_ALLUNITS",
        [3] = "SCFA_ECONOMIC",
        [4] = "SCFA_ENERGYPRODUCTION",
        [5] = "SCFA_HYDROCARBON",
        [6] = "SCFA_PRODUCTSC1",
        [7] = "SCFA_RECLAIMABLE",
        [8] = "SCFA_SELECTABLE",
        [9] = "SCFA_SIZE12",
        [10] = "SCFA_SORTECONOMY",
        [11] = "SCFA_STRUCTURE",
        [12] = "SCFA_TECH1",
        [13] = "SCFA_UEF",
        [14] = "SCFA_VISIBLETORECON",
        [15] = "STRUCTURE",
        [16] = "TECH1",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5015/LOD0/ues5015.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5015/LOD0/ues5015.sananimation",
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
                    ["y"] = 0.325,
                    ["z"] = -0.5,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.55,
                    ["y"] = 0.23399999999999999,
                    ["z"] = 0.44999999999999996,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.5,
                    ["y"] = 0.36400000000000005,
                    ["z"] = 0.4,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.44999999999999996,
                    ["y"] = 0.546,
                    ["z"] = -0.5,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.55,
                    ["y"] = 0.52,
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
                ["x"] = 1.9,
                ["y"] = 1.9,
            },
        },
    },
    ["weapons"] = {},
}
