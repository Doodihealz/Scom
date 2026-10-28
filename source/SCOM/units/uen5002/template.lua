-- uen5002: Bulwark
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
                    ["bindPoseTracks"] = {
                        [1] = "Exhaust01",
                        [2] = "Exhaust02",
                    },
                    ["blueprintUses"] = {
                        [1] = ".Display.AnimationDeath[0].Animation",
                    },
                    ["bytes"] = 12748,
                    ["clipName"] = "FaXES0205ADeath01",
                    ["duration"] = 11.666666984558105,
                    ["entry"] = "units/XES0205/XES0205_ADeath01.sca",
                    ["frames"] = 351,
                    ["outputDuration"] = 11.666666984558105,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "f45a03809062f6d6ad26059e51232b507c8b61bd38aba29d1d96f1adbba1c13e",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 1,
                    ["usedBySource"] = true,
                },
                [2] = {
                    ["archive"] = "units.scd",
                    ["bindPoseTracks"] = {
                        [1] = "Exhaust01",
                        [2] = "Exhaust02",
                    },
                    ["blueprintUses"] = {
                        [1] = ".Display.AnimationDeath[1].Animation",
                    },
                    ["bytes"] = 12748,
                    ["clipName"] = "FaXES0205ADeath02",
                    ["duration"] = 11.666666984558105,
                    ["entry"] = "units/XES0205/XES0205_ADeath02.sca",
                    ["frames"] = 351,
                    ["outputDuration"] = 11.666666984558105,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "06c16637ecde822af5c0ee56430544cd8304db7c4c5caa83a2222b2c7f77b505",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 1,
                    ["usedBySource"] = true,
                },
                [3] = {
                    ["archive"] = "units.scd",
                    ["bindPoseTracks"] = {
                        [1] = "Exhaust01",
                        [2] = "Exhaust02",
                    },
                    ["blueprintUses"] = {
                        [1] = ".Display.AnimationDeath[2].Animation",
                    },
                    ["bytes"] = 12748,
                    ["clipName"] = "FaXES0205ADeath03",
                    ["duration"] = 11.666666984558105,
                    ["entry"] = "units/XES0205/XES0205_ADeath03.sca",
                    ["frames"] = 351,
                    ["outputDuration"] = 11.666666984558105,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "9d6d0a8dee318c2f1b4f5fb625c985a622112d12c37b8b073f2b9384d918e878",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 1,
                    ["usedBySource"] = true,
                },
            },
            ["sourceBlueprint"] = "units/XES0205/XES0205_unit.bp",
            ["sourceBlueprintSha256"] = "5c51ae09a9e8378513005e38934d91b77c3d6aa5918f5541af424e84a0cdd32b",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "XES0205",
            ["sourceIntel"] = {
                ["VisionRadius"] = 32,
            },
            ["sourceMovement"] = {
                ["BackUpDistance"] = 5,
                ["BankingSlope"] = 0,
                ["BuildOnLayerCaps"] = {
                    ["LAYER_Air"] = false,
                    ["LAYER_Land"] = false,
                    ["LAYER_Orbit"] = false,
                    ["LAYER_Seabed"] = false,
                    ["LAYER_Sub"] = false,
                    ["LAYER_Water"] = true,
                },
                ["CatchUpAcc"] = 10,
                ["DragCoefficient"] = 0.2,
                ["MaxAcceleration"] = 7,
                ["MaxBrake"] = 7,
                ["MaxSpeed"] = 7,
                ["MaxSpeedReverse"] = 7,
                ["MaxSteerForce"] = 5,
                ["MeshExtentsX"] = 2.25,
                ["MeshExtentsY"] = 2,
                ["MeshExtentsZ"] = 12,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_Water",
                ["TurnRadius"] = 10,
                ["TurnRate"] = 60,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1575,
                ["entry"] = "units/XES0205/XES0205_script.lua",
                ["sha256"] = "e19dde6b9097d76cef209dcfb1999b19e71dc942e1b806cc4b2b955e85927c61",
            },
            ["sourceShield"] = {
                ["ImpactEffects"] = "UEFShieldHit01",
                ["ImpactMesh"] = "/effects/entities/ShieldSection01/ShieldSection01_mesh",
                ["Mesh"] = "/effects/entities/Shield01/Shield01_mesh",
                ["MeshZ"] = "/effects/entities/Shield01/Shield01z_mesh",
                ["RegenAssistMult"] = 60,
                ["ShieldEnergyDrainRechargeTime"] = 5,
                ["ShieldMaxHealth"] = 8000,
                ["ShieldRechargeTime"] = 32,
                ["ShieldRegenRate"] = 80,
                ["ShieldRegenStartTime"] = 1,
                ["ShieldSize"] = 120,
                ["ShieldVerticalOffset"] = -50,
            },
            ["sourceWeapons"] = {},
            ["targetId"] = "uen5002",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoIdleResetLocomotion"] = true,
        ["scoSourceDeath"] = {
            ["hasMovement"] = true,
            ["sourceId"] = "XES0205",
            ["variants"] = {
                [1] = {
                    ["durationSeconds"] = 11.666666984558105,
                    ["key"] = "scoSourceDeath01",
                    ["rateMax"] = 1.2,
                    ["rateMin"] = 0.8,
                    ["weight"] = 100,
                },
                [2] = {
                    ["durationSeconds"] = 11.666666984558105,
                    ["key"] = "scoSourceDeath02",
                    ["rateMax"] = 1.2,
                    ["rateMin"] = 0.8,
                    ["weight"] = 100,
                },
                [3] = {
                    ["durationSeconds"] = 11.666666984558105,
                    ["key"] = "scoSourceDeath03",
                    ["rateMax"] = 1.2,
                    ["rateMin"] = 0.8,
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/f7a9f358c62c0014469c.sanmaterial",
                            ["path"] = "effects/Emitters/terran_shield_generator_shipmobile_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_06.dds",
                                ["sha256"] = "258dcb4d66de1d6336d812e2beab12ea5f501e35a4441e0265648e2f68767e2b",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "b6a5f1bdd2dfedaadcab990c48d3c77686220bfe94058de385802e90ecfe93fd",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "terran_shield_generator_shipmobile_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 9.169,
                                            ["y"] = 4,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0.3,
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
                                ["LODCutoff"] = 100,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 7,
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
                                ["RampTexture"] = "/textures/particles/ramp_blue_06.dds",
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
                                            ["y"] = 0.1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Texture"] = "/textures/particles/smoke.dds",
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
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = -0.3,
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
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0.75,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/smoke.dds",
                                ["sha256"] = "d23d001cf5d3b381c08ddb841d0f4bb16f17c64d3127b82f60d5a2b8489e3ead",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/2d91f9abea108e728416.sanmaterial",
                            ["path"] = "effects/Emitters/terran_shield_generator_shipmobile_02_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_white_05.dds",
                                ["sha256"] = "c276082fbcd646aa2a6a309fd88f72724bc27fcaa3753781e568ee2408349aac",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "92bdf3df3b295083a69b91f101bea5cca45283744c9d3cf91019b5c97f57e3b1",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = true,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "terran_shield_generator_shipmobile_02",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 9.169,
                                            ["y"] = 4,
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
                                            ["z"] = 0.5,
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
                                ["LODCutoff"] = 100,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 10,
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
                                ["RampTexture"] = "/textures/particles/ramp_white_05.dds",
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
                                            ["y"] = 0.1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Texture"] = "/textures/particles/line_white_add_04.dds",
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
                                            ["y"] = 0.02,
                                            ["z"] = 0.04,
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
                                            ["y"] = 0,
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = -0.3,
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
                                            ["z"] = 2,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 0.75,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/line_white_add_04.dds",
                                ["sha256"] = "b81fa7edce3cb6be05365a9411ee3a2955028d41994ebee758a6f2b4df427899",
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
                    ["path"] = "VFX/SCOM/Source/uen5002/ambient_shield.sanvfx",
                    ["sha256"] = "8f613b1ab2f48358177745b985329d9deae1b95fdc6769b8c04267e53feab35a",
                },
            },
            ["effects"] = {
                [1] = {
                    ["bone"] = "Root",
                    ["condition"] = "shield",
                    ["delay"] = 0,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/uen5002/ambient_shield.sanvfx",
                    ["sourceBone"] = "XES0205",
                    ["when"] = "complete",
                },
            },
            ["meshes"] = {},
            ["sourceBlueprintSha256"] = "5c51ae09a9e8378513005e38934d91b77c3d6aa5918f5541af424e84a0cdd32b",
            ["sourceId"] = "XES0205",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1575,
                ["entry"] = "units/XES0205/XES0205_script.lua",
                ["sha256"] = "e19dde6b9097d76cef209dcfb1999b19e71dc942e1b806cc4b2b955e85927c61",
            },
            ["targetId"] = "uen5002",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.85,
            ["y"] = 1,
            ["z"] = 2.75,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 750,
            ["regen"] = 0,
            ["value"] = 750,
        },
        ["shields"] = {
            [1] = {
                ["boneName"] = "Root",
                ["max"] = 8000,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = -5.63,
                    ["z"] = 0,
                },
                ["radii"] = {
                    ["x"] = 6.75,
                    ["y"] = 6.75,
                    ["z"] = 6.75,
                },
                ["rechargeHPRatio"] = 0.5,
                ["rechargeTime"] = 32,
                ["regen"] = 80,
                ["regenDelay"] = 1,
                ["type"] = 0,
                ["value"] = 8000,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 5200,
        ["cost"] = {
            ["alloys"] = 1300,
            ["energy"] = 13000,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 150,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDANavalUnit",
        },
        ["displayName"] = "Bulwark",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 60,
        ["iconUIType"] = "water",
        ["name"] = "Bulwark",
        ["orders"] = {
            ["Assist"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Shield"] = true,
        },
        ["tpId"] = "uen5002",
    },
    ["intel"] = {
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 7,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 7,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 60,
        ["sortOrder"] = 1,
        ["speed"] = 7,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_FACTORY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "EDA",
        [4] = "MOBILE",
        [5] = "NAVAL",
        [6] = "SCFA_ALLUNITS",
        [7] = "SCFA_BUILTBYTIER2FACTORY",
        [8] = "SCFA_BUILTBYTIER3FACTORY",
        [9] = "SCFA_DEFENSE",
        [10] = "SCFA_DEFENSIVEBOAT",
        [11] = "SCFA_MOBILE",
        [12] = "SCFA_NAVAL",
        [13] = "SCFA_OVERLAYDEFENSE",
        [14] = "SCFA_PRODUCTFA",
        [15] = "SCFA_RECLAIMABLE",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SHIELD",
        [18] = "SCFA_TECH2",
        [19] = "SCFA_UEF",
        [20] = "SCFA_VISIBLETORECON",
        [21] = "TECH2",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uen5002/LOD0/uen5002.sananimation",
            },
            ["scoSourceDeath01"] = {
                ["clipName"] = "FaXES0205ADeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen5002/LOD0/uen5002.sananimation",
            },
            ["scoSourceDeath02"] = {
                ["clipName"] = "FaXES0205ADeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen5002/LOD0/uen5002.sananimation",
            },
            ["scoSourceDeath03"] = {
                ["clipName"] = "FaXES0205ADeath03",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen5002/LOD0/uen5002.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uen5002/LOD0/uen5002.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.153,
                    ["y"] = 0,
                    ["z"] = -0.55,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.187,
                    ["y"] = -0.07,
                    ["z"] = 0.495,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.17,
                    ["y"] = 0.030000000000000027,
                    ["z"] = 0.44,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.153,
                    ["y"] = 0.16999999999999998,
                    ["z"] = -0.55,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.187,
                    ["y"] = 0.15000000000000002,
                    ["z"] = 0.495,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 150,
            ["lod1distance"] = 390,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = -0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 1.8,
            },
        },
    },
    ["weapons"] = {},
}
