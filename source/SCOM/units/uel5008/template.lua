-- uel5008: Parashield
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
                        [1] = "AttachPoint",
                        [2] = "AttachPoint",
                    },
                    ["blueprintUses"] = {
                        [1] = ".Display.AnimationOpen",
                    },
                    ["bytes"] = 14343,
                    ["clipName"] = "FaUEL0307Aactivate",
                    ["duration"] = 2,
                    ["entry"] = "units/uel0307/UEL0307_Aactivate.sca",
                    ["frames"] = 61,
                    ["outputDuration"] = 2,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "3ea2074d71c69f4e3b75dba3c7686ae93967ad6c3421feab2b51df4dee3e0a88",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 8,
                    ["usedBySource"] = true,
                },
            },
            ["sourceBlueprint"] = "units/uel0307/UEL0307_unit.bp",
            ["sourceBlueprintSha256"] = "ec1db0859a778ab5af14b4919d99e1aea97e7dab0a2e8e694237d974e6f0a820",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "UEL0307",
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
                ["MaxAcceleration"] = 4,
                ["MaxBrake"] = 4,
                ["MaxSpeed"] = 4,
                ["MaxSpeedReverse"] = 0,
                ["MaxSteerForce"] = 10,
                ["MeshExtentsX"] = 0.75,
                ["MeshExtentsY"] = 0.6,
                ["MeshExtentsZ"] = 0.85,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_Land",
                ["RotateOnSpot"] = true,
                ["RotateOnSpotThreshold"] = 0.1,
                ["TurnRadius"] = 0,
                ["TurnRate"] = 120,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 3329,
                ["entry"] = "units/uel0307/UEL0307_script.lua",
                ["sha256"] = "4599f95fa109d14aa76034eed2e0a74bd8fca621dea936de82bc76d084556c38",
            },
            ["sourceShield"] = {
                ["ImpactEffects"] = "UEFShieldHit01",
                ["ImpactMesh"] = "/effects/entities/ShieldSection01/ShieldSection01_mesh",
                ["Mesh"] = "/effects/entities/Shield01/Shield01_mesh",
                ["MeshZ"] = "/effects/entities/Shield01/Shield01z_mesh",
                ["RegenAssistMult"] = 60,
                ["ShieldEnergyDrainRechargeTime"] = 5,
                ["ShieldMaxHealth"] = 4000,
                ["ShieldRechargeTime"] = 24,
                ["ShieldRegenRate"] = 55,
                ["ShieldRegenStartTime"] = 1,
                ["ShieldSize"] = 16,
                ["ShieldVerticalOffset"] = -3,
            },
            ["sourceWeapons"] = {},
            ["targetId"] = "uel5008",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 1.7424607585448816e-15,
                [2] = 0.42376085957801884,
                [3] = -0.040123389941899956,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UEL0307",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 85702,
                ["entry"] = "units/uel0307/UEL0307_lod0.scm",
                ["sha256"] = "b89894a1211e110131e1326e319544d2df3f3c746acddc6db7692efcd5b25560",
            },
        },
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/uel5008/LOD0/uel5008_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.22750000655651093,
                        ["y"] = -0.140595078445017,
                        ["z"] = 0.259999984363497,
                    },
                    ["width"] = 0.135,
                },
                [2] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.22749998420476913,
                        ["y"] = -0.1405950885733582,
                        ["z"] = -0.010000019846083126,
                    },
                    ["width"] = 0.135,
                },
                [3] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.22749997675418854,
                        ["y"] = -0.14059508055809192,
                        ["z"] = -0.20000000907999824,
                    },
                    ["width"] = 0.135,
                },
                [4] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.22749997675418854,
                        ["y"] = -0.1405950870773474,
                        ["z"] = -0.19999999417883593,
                    },
                    ["width"] = 0.135,
                },
                [5] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.22749998420476913,
                        ["y"] = -0.14059508857335523,
                        ["z"] = -0.010000002150954208,
                    },
                    ["width"] = 0.135,
                },
                [6] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.22750000655651093,
                        ["y"] = -0.14059506633781851,
                        ["z"] = 0.26000001416581736,
                    },
                    ["width"] = 0.135,
                },
            },
            ["unit"] = "uel5008",
        },
        ["scoSourceSecondaryVisuals"] = {
            ["animationState"] = {
                ["clipName"] = "FaUEL0307Aactivate",
                ["condition"] = "shield",
                ["duration"] = 2,
                ["forwardRate"] = 1,
                ["key"] = "scoSecondaryOpen",
                ["reverseRate"] = -1,
                ["sanAnimationPath"] = "Units/uel5008/LOD0/uel5008.sananimation",
                ["source"] = {
                    ["archive"] = "units.scd",
                    ["bindPoseTracks"] = {
                        [1] = "AttachPoint",
                        [2] = "AttachPoint",
                    },
                    ["blueprintUses"] = {
                        [1] = ".Display.AnimationOpen",
                    },
                    ["bytes"] = 14343,
                    ["clipName"] = "FaUEL0307Aactivate",
                    ["duration"] = 2,
                    ["entry"] = "units/uel0307/UEL0307_Aactivate.sca",
                    ["frames"] = 61,
                    ["outputDuration"] = 2,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "3ea2074d71c69f4e3b75dba3c7686ae93967ad6c3421feab2b51df4dee3e0a88",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 8,
                    ["usedBySource"] = true,
                },
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/ed1e3976be4301c21e68.sanmaterial",
                            ["path"] = "effects/Emitters/terran_shield_generator_mobile_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_06.dds",
                                ["sha256"] = "258dcb4d66de1d6336d812e2beab12ea5f501e35a4441e0265648e2f68767e2b",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "4189399390042d1193c86ed0bda4b7d14760cfcd2f30357e55121482f014dbb7",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "terran_shield_generator_mobile_01",
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
                                            ["y"] = 0.45,
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
                                            ["y"] = 0,
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/e6e6ad328d091c343760.sanmaterial",
                            ["path"] = "effects/Emitters/terran_shield_generator_mobile_02_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_white_05.dds",
                                ["sha256"] = "c276082fbcd646aa2a6a309fd88f72724bc27fcaa3753781e568ee2408349aac",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "164186b860cd17c2d774f0c25feb196a22a4bcf6c78ecba05f22d290e8a28eae",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = true,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "terran_shield_generator_mobile_02",
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
                                            ["y"] = 0.45,
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
                                            ["y"] = 0,
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
                    ["path"] = "VFX/SCOM/Source/uel5008/ambient_shield.sanvfx",
                    ["sha256"] = "c9d00132918f8766d025c2a3a06c6701b48f72c34da83186c9a1235a2b719c5c",
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
                    ["path"] = "VFX/SCOM/Source/uel5008/ambient_shield.sanvfx",
                    ["sourceBone"] = "0",
                    ["when"] = "complete",
                },
            },
            ["meshes"] = {},
            ["rotators"] = {
                [1] = {
                    ["acceleration"] = 5,
                    ["axis"] = "y",
                    ["bone"] = "Spinner",
                    ["condition"] = "shield",
                    ["delay"] = 0,
                    ["disabledAcceleration"] = 10,
                    ["initialSpeed"] = 0,
                    ["speed"] = 30,
                },
            },
            ["sourceBlueprintSha256"] = "ec1db0859a778ab5af14b4919d99e1aea97e7dab0a2e8e694237d974e6f0a820",
            ["sourceId"] = "UEL0307",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 3329,
                ["entry"] = "units/uel0307/UEL0307_script.lua",
                ["sha256"] = "4599f95fa109d14aa76034eed2e0a74bd8fca621dea936de82bc76d084556c38",
            },
            ["targetId"] = "uel5008",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0.05,
        },
        ["collisionSize"] = {
            ["x"] = 0.6,
            ["y"] = 0.35,
            ["z"] = 0.7,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 150,
            ["regen"] = 0,
            ["value"] = 150,
        },
        ["shields"] = {
            [1] = {
                ["boneName"] = "Root",
                ["max"] = 4000,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = -3,
                    ["z"] = 0,
                },
                ["radii"] = {
                    ["x"] = 8,
                    ["y"] = 8,
                    ["z"] = 8,
                },
                ["rechargeHPRatio"] = 0.5,
                ["rechargeTime"] = 24,
                ["regen"] = 55,
                ["regenDelay"] = 1,
                ["type"] = 0,
                ["value"] = 4000,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 600,
        ["cost"] = {
            ["alloys"] = 120,
            ["energy"] = 900,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 100,
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
        ["displayName"] = "Parashield",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_land1_direct.png",
        ["iconUIBuildSortPriority"] = 110,
        ["iconUIType"] = "land",
        ["name"] = "Parashield",
        ["orders"] = {
            ["Assist"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Shield"] = true,
        },
        ["tpId"] = "uel5008",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["movement"] = {
        ["acceleration"] = 4,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 4,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 120,
        ["sortOrder"] = 1,
        ["speed"] = 4,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "TracksLand",
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
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_FACTORY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "EDA",
        [4] = "LAND",
        [5] = "MOBILE",
        [6] = "SCFA_ALLUNITS",
        [7] = "SCFA_BUILTBYTIER2FACTORY",
        [8] = "SCFA_BUILTBYTIER3FACTORY",
        [9] = "SCFA_DEFENSE",
        [10] = "SCFA_LAND",
        [11] = "SCFA_MOBILE",
        [12] = "SCFA_OVERLAYDEFENSE",
        [13] = "SCFA_PRODUCTSC1",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SHIELD",
        [17] = "SCFA_TECH2",
        [18] = "SCFA_UEF",
        [19] = "SCFA_VISIBLETORECON",
        [20] = "TECH2",
    },
    ["visuals"] = {
        ["animations"] = {
            ["open"] = {
                ["clipName"] = "FaUEL0307Aactivate",
                ["sanAnimationPath"] = "Units/uel5008/LOD0/uel5008.sananimation",
            },
            ["rest"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uel5008/LOD0/uel5008.sananimation",
            },
            ["scoSecondaryOpen"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "FaUEL0307Aactivate",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel5008/LOD0/uel5008.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uel5008/LOD0/uel5008.sananimation",
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
                    ["x"] = 0.108,
                    ["y"] = 0.0875,
                    ["z"] = -0.08999999999999998,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.063,
                    ["z"] = 0.176,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = 0.098,
                    ["z"] = 0.16199999999999998,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.147,
                    ["z"] = -0.08999999999999998,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.13999999999999999,
                    ["z"] = 0.176,
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
                ["z"] = 0.05,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.5,
            },
        },
    },
    ["weapons"] = {},
}
