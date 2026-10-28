-- ucs3611: Quantum Reactor
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["deathClip"] = {
                ["durationSeconds"] = 1,
                ["key"] = "source_animadeath",
                ["rate"] = 1,
            },
            ["kind"] = "rotating_power_death",
            ["mapping"] = "UAB1301 -> ucs3611",
            ["rotatorCount"] = 1,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB1301/UAB1301_unit.bp",
            ["sourceBlueprintSha256"] = "96e85f646efd233848af22f3cd6c6bfc74afde1f5dd27e5d2975f1b0fd11dfcf",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 1,
                    ["frames"] = 31,
                    ["key"] = "source_animadeath",
                    ["name"] = "AnimAdeath",
                    ["rate"] = 1,
                    ["role"] = "death",
                    ["sha256"] = "790a01b07fbb6fc1f1f254a19e2a96ef4dcdfabe6cc66dbce37335d2c2a5b672",
                    ["source"] = "units/UAB1301/UAB1301_Adeath.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "282dbdc030fd20b5cceb158431ac769d57435a31024dabb04738c459d602ac96",
            ["sourceScript"] = "units/UAB1301/UAB1301_script.lua",
            ["sourceScriptSha256"] = "9454c4e6406fb61e7fa8134cbb26f5c77e256fd1e57ecfbc2f932f143cea1c6a",
            ["stateOwner"] = "Sphere x/y/z accelerates at 15 to deterministic source-range 80..100 continuously, independent of production Pause; death owns the one-second authored clip before stock wreck/delete.",
            ["targetAnimation"] = {
                ["bytes"] = 15152,
                ["path"] = "Units/ucs3611/LOD0/ucs3611.sananimation",
                ["sha256"] = "c71850bb609479462b523af38f1095da26e153627d2d614080c7843b1418dc9d",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 626937,
                ["path"] = "Units/ucs3611/LOD0/ucs3611_lod0.sanmodel",
                ["sha256"] = "da68c98a8c7f52f570c4a2921ebe36c22b896d29c9448c33124d04e09757148f",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 1976,
                ["path"] = "Units/ucs3611/LOD0/ucs3611.sanskeleton",
                ["sha256"] = "51352f9a61fde2be842b5a745e97d1ab89fa874499cb5b1dadbfac231c4d8f10",
            },
            ["version"] = "1.0.2",
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 20,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 5,
                    ["z"] = 5,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirt"] = {
                    ["offsetX"] = -1.5,
                    ["offsetZ"] = -1.5,
                    ["sizeX"] = 8,
                    ["sizeZ"] = 8,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB1301/UAB1301_unit.bp",
            ["sourceBlueprintSha256"] = "96e85f646efd233848af22f3cd6c6bfc74afde1f5dd27e5d2975f1b0fd11dfcf",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER3COMMANDER",
                [3] = "BUILTBYTIER3ENGINEER",
                [4] = "DRAGBUILD",
                [5] = "ECONOMIC",
                [6] = "ENERGYPRODUCTION",
                [7] = "PRODUCTSC1",
                [8] = "RECLAIMABLE",
                [9] = "SELECTABLE",
                [10] = "SIZE16",
                [11] = "SORTECONOMY",
                [12] = "STRUCTURE",
                [13] = "TECH3",
                [14] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB1301",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs3611",
            ["weapons"] = {
                [1] = {
                    ["label"] = "DeathWeapon",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {},
                    ["rateOfFire"] = 0,
                    ["reloadTime"] = 0,
                    ["sourceCategory"] = "Death",
                    ["sourceProjectile"] = "",
                },
            },
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Sphere",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        ["scoSourceSecondaryVisuals"] = {
            ["ambientSource"] = {
                ["baseClass"] = {
                    ["archive"] = "lua.scd",
                    ["path"] = "lua/aeonunits.lua",
                    ["sha256"] = "b9ae185a54cf61a1f70e5d31be499bc309382c0d10dcfeb83d229a7f1961bc9f",
                },
                ["callback"] = "AEnergyCreationUnit.OnStopBeingBuilt",
                ["effectTemplate"] = {
                    ["archive"] = "lua.scd",
                    ["path"] = "lua/EffectTemplates.lua",
                    ["sha256"] = "a38581311b5b575aecde3eecb0805742ca06e1747253dab95346ebb20d9a7702",
                },
                ["sourceBone"] = 0,
                ["template"] = "AT3PowerAmbient",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/aa71434562d1fba412ea.sanmaterial",
                            ["path"] = "effects/Emitters/aeon_T3power_ambient_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_blue_01.dds",
                                ["sha256"] = "784b58918ff448897d8b4abf5cfbe025b84123d8e530836d9985d56e78d39015",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "6dc3461405882a26357b82ca32e2ffbff78bdbb4dd090111b774780ce3c6e09e",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "aeon_T3power_ambient_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 2,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25.594,
                                            ["y"] = 2.698,
                                            ["z"] = 0,
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
                                            ["y"] = 3,
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
                                            ["x"] = 24.934,
                                            ["y"] = 90,
                                            ["z"] = 20,
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
                                            ["x"] = 25.132,
                                            ["y"] = 1.446,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Texture"] = "/textures/particles/electricity_ring.dds",
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
                                            ["y"] = 1,
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
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 26.913,
                                            ["y"] = 0.238,
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
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/electricity_ring.dds",
                                ["sha256"] = "39d062628fe6b2457a3765bddc0bb77c9ed161d5d87366b783b82b6dbebd2705",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/0e606b0690fe041b7a52.sanmaterial",
                            ["path"] = "effects/Emitters/aeon_T3power_ambient_02_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_white_02.dds",
                                ["sha256"] = "1f99980d014fae877ec70f47b15674b4a58b848e45b2429e4fa6a4f141dcd537",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "9760863cf8970e483dbff0947e185302eac10e5197af3ba2c379b4dc3dc7dab8",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = true,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "aeon_T3power_ambient_02",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 2,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.101,
                                            ["y"] = 1.429,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.1,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["Gravity"] = false,
                                ["HighFidelity"] = true,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.1,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 200,
                                ["Lifetime"] = -0.2,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.1,
                                            ["y"] = 25,
                                            ["z"] = 3,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["LocalAcceleration"] = false,
                                ["LocalVelocity"] = true,
                                ["LowFidelity"] = true,
                                ["MedFidelity"] = true,
                                ["OnlyEmitOnWater"] = false,
                                ["ParticleResistance"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.1,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_white_02.dds",
                                ["Repeattime"] = 0.2,
                                ["ResistanceCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.1,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.1,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.094,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = 0,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.099,
                                            ["y"] = 0.338,
                                            ["z"] = 0.1,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["Texture"] = "/textures/particles/line_white_add_05.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.1,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.1,
                                            ["y"] = 6,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.1,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.1,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.101,
                                            ["y"] = 0,
                                            ["z"] = 1.5,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.1,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.014,
                                            ["y"] = 0.01,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.094,
                                            ["y"] = 2,
                                            ["z"] = 0.75,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.1,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.1,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0,
                                            ["z"] = 1.5,
                                        },
                                    },
                                    ["XRange"] = 0.2,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/line_white_add_05.dds",
                                ["sha256"] = "8a248ec8f64f3fc659254ca9135ad0df21ee31f14337755b73c895eaf32edfb2",
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
                    ["path"] = "VFX/SCOM/Source/ucs3611/ambient_power.sanvfx",
                    ["sha256"] = "70d9030e4089f8aa3052851e1d7d128fcd71f08809cfafa2f30297b1563b0663",
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
                    ["path"] = "VFX/SCOM/Source/ucs3611/ambient_power.sanvfx",
                    ["sourceBone"] = "0",
                    ["when"] = "complete",
                },
            },
            ["legacyStaticVisual"] = false,
            ["legacyTemplateClass"] = "AeonPortEnergyGenerator",
            ["legacyTemplateModule"] = "unitsDefaultChosen",
            ["meshes"] = {},
            ["sourceBlueprint"] = "units/UAB1301/UAB1301_unit.bp",
            ["sourceBlueprintSha256"] = "96e85f646efd233848af22f3cd6c6bfc74afde1f5dd27e5d2975f1b0fd11dfcf",
            ["sourceId"] = "UAB1301",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 352933,
                ["entry"] = "units/UAB1301/UAB1301_lod0.scm",
                ["sha256"] = "282dbdc030fd20b5cceb158431ac769d57435a31024dabb04738c459d602ac96",
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1010,
                ["entry"] = "units/UAB1301/UAB1301_script.lua",
                ["sha256"] = "9454c4e6406fb61e7fa8134cbb26f5c77e256fd1e57ecfbc2f932f143cea1c6a",
            },
            ["targetId"] = "ucs3611",
            ["unsupportedEffects"] = {},
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.375,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.9,
                ["y"] = 2.9,
            },
        },
    },
    ["adjacency"] = "T1EnergyGeneratorAdjacencyBuff",
    ["audio"] = {
        ["active"] = {
            ["looping"] = true,
            ["name"] = "aclu2310",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1.375,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 4,
            ["y"] = 2.75,
            ["z"] = 4,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 9720,
            ["regen"] = 0,
            ["value"] = 9720,
        },
    },
    ["economy"] = {
        ["buildTime"] = 5400,
        ["cost"] = {
            ["alloys"] = 3240,
            ["energy"] = 57600,
        },
        ["production"] = {
            ["alloys"] = 0,
            ["energy"] = 2500,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortEnergyGenerator",
        },
        ["displayName"] = "Quantum Reactor",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "plasma",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_plasma.png",
        ["iconUIBuildSortPriority"] = 360,
        ["iconUIType"] = "amphibious",
        ["name"] = "Quantum Reactor",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["tpId"] = "ucs3611",
        ["unitTypeName"] = "Quantum Reactor",
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
        [2] = "CHOSEN",
        [3] = "ECONOMIC",
        [4] = "ENERGY_PRODUCTION",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_AEON",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_BUILTBYTIER3COMMANDER",
        [10] = "SCFA_BUILTBYTIER3ENGINEER",
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
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs3611/LOD0/ucs3611.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs3611/LOD0/ucs3611.sananimation",
            },
        },
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
                    ["audioName"] = "unit_death_land_eda_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.72,
                    ["y"] = 2.0625,
                    ["z"] = -0.8,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.88,
                    ["y"] = 1.87,
                    ["z"] = 0.72,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8,
                    ["y"] = 2.145,
                    ["z"] = 0.64,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.72,
                    ["y"] = 2.5300000000000002,
                    ["z"] = -0.8,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.88,
                    ["y"] = 2.475,
                    ["z"] = 0.72,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 70,
            ["lod1distance"] = 182,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.375,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.9,
                ["y"] = 2.9,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 8000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 10,
            ["damageType"] = "Normal",
        },
    },
}
