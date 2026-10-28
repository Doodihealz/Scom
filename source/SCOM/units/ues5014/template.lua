-- ues5014: Quantum Gateway
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoFactoryEgress"] = {
            targetId = "ues5014",
            sourceId = "UEB0304",
            domain = "land",
            buildOffset = { x = 0, y = 0.335198230743408, z = 0 },
            bounds = {
                min = { x = -3.81046104431152, y = -0.40032234787941, z = -3.36173343658447 },
                max = { x = 3.81042623519897, y = 3.40920829772949, z = 3.36173343658447 },
            },
            exitRoutes = {
                {
                    headingDegrees = 0,
                    waypoints = {
                        { x = 0, y = 0.33611, z = 0 },
                        { x = 0, y = 0.33611, z = 0.125 },
                        { x = 0, y = 0.33611, z = 0.25 },
                        { x = 0, y = 0.33611, z = 0.375 },
                        { x = 0, y = 0.33611, z = 0.5 },
                        { x = 0, y = 0.33611, z = 0.625 },
                        { x = 0, y = 0.33611, z = 0.75 },
                        { x = 0, y = 0.33611, z = 0.875 },
                        { x = 0, y = 0.33611, z = 1 },
                        { x = 0, y = 0.33611, z = 1.125 },
                        { x = 0, y = 0.33611, z = 1.25 },
                        { x = 0, y = 0.33611, z = 1.375 },
                        { x = 0, y = 0.33611, z = 1.5 },
                        { x = 0, y = 0.3224, z = 1.625 },
                        { x = 0, y = 0.299182, z = 1.75 },
                        { x = 0, y = 0.275964, z = 1.875 },
                        { x = 0, y = 0.252745, z = 2 },
                        { x = 0, y = 0.229527, z = 2.125 },
                        { x = 0, y = 0.206309, z = 2.25 },
                        { x = 0, y = 0.183091, z = 2.375 },
                        { x = 0, y = 0.159873, z = 2.5 },
                        { x = 0, y = 0.136654, z = 2.625 },
                        { x = 0, y = 0.113436, z = 2.75 },
                        { x = 0, y = 0.090218, z = 2.875 },
                        { x = 0, y = 0.067, z = 3 },
                    },
                },
                {
                    headingDegrees = 180,
                    waypoints = {
                        { x = 0, y = 0.33611, z = 0 },
                        { x = 0, y = 0.33611, z = -0.125 },
                        { x = 0, y = 0.33611, z = -0.25 },
                        { x = 0, y = 0.33611, z = -0.375 },
                        { x = 0, y = 0.33611, z = -0.5 },
                        { x = 0, y = 0.33611, z = -0.625 },
                        { x = 0, y = 0.33611, z = -0.75 },
                        { x = 0, y = 0.33611, z = -0.875 },
                        { x = 0, y = 0.33611, z = -1 },
                        { x = 0, y = 0.33611, z = -1.125 },
                        { x = 0, y = 0.33611, z = -1.25 },
                        { x = 0, y = 0.33611, z = -1.375 },
                        { x = 0, y = 0.33611, z = -1.5 },
                        { x = 0, y = 0.3224, z = -1.625 },
                        { x = 0, y = 0.299182, z = -1.75 },
                        { x = 0, y = 0.275964, z = -1.875 },
                        { x = 0, y = 0.252745, z = -2 },
                        { x = 0, y = 0.229527, z = -2.125 },
                        { x = 0, y = 0.206309, z = -2.25 },
                        { x = 0, y = 0.183091, z = -2.375 },
                        { x = 0, y = 0.159873, z = -2.5 },
                        { x = 0, y = 0.136654, z = -2.625 },
                        { x = 0, y = 0.113436, z = -2.75 },
                        { x = 0, y = 0.090218, z = -2.875 },
                        { x = 0, y = 0.067, z = -3 },
                    },
                },
            },
        },
        ["faSourceContract"] = {
            ["fuelIntentionallyOmitted"] = false,
            ["runtimeBehaviorApproval"] = false,
            ["sourceAir"] = {},
            ["sourceAnimations"] = {},
            ["sourceBlueprint"] = "units/UEB0304/UEB0304_unit.bp",
            ["sourceBlueprintSha256"] = "d312a74e9a6bb153922726e4995e28aa8cd43a031569661ce740e7847d1f25df",
            ["sourceBuildableCategory"] = {
                [1] = "BUILTBYQUANTUMGATE UEF",
            },
            ["sourceId"] = "UEB0304",
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
                ["OccupyRects"] = {
                    [1] = -2.5,
                    [2] = 0,
                    [3] = 1,
                    [4] = 3,
                    [5] = 2.5,
                    [6] = 0,
                    [7] = 1,
                    [8] = 3,
                },
                ["RaisedPlatforms"] = {
                    [1] = -1.5,
                    [2] = -1.5,
                    [3] = 0.3,
                    [4] = 1.5,
                    [5] = -1.5,
                    [6] = 0.3,
                    [7] = -1.5,
                    [8] = 1.5,
                    [9] = 0.3,
                    [10] = 1.5,
                    [11] = 1.5,
                    [12] = 0.3,
                    [13] = -1.5,
                    [14] = -3.4,
                    [15] = 0,
                    [16] = 1.5,
                    [17] = -3.4,
                    [18] = 0,
                    [19] = -1.5,
                    [20] = -1.5,
                    [21] = 0.3,
                    [22] = 1.5,
                    [23] = -1.5,
                    [24] = 0.3,
                    [25] = -1.5,
                    [26] = 1.5,
                    [27] = 0.3,
                    [28] = 1.5,
                    [29] = 1.5,
                    [30] = 0.3,
                    [31] = -1.5,
                    [32] = 3.4,
                    [33] = 0,
                    [34] = 1.5,
                    [35] = 3.4,
                    [36] = 0,
                },
                ["RollOffPoints"] = {
                    [1] = {
                        ["UnitSpin"] = 0,
                        ["X"] = 0,
                        ["Y"] = 0,
                        ["Z"] = 3,
                    },
                    [2] = {
                        ["UnitSpin"] = 180,
                        ["X"] = 0,
                        ["Y"] = 0,
                        ["Z"] = -3,
                    },
                },
                ["SkirtOffsetX"] = -1.5,
                ["SkirtOffsetZ"] = -1.5,
                ["SkirtSizeX"] = 10,
                ["SkirtSizeZ"] = 10,
                ["TurnRate"] = 0,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1586,
                ["entry"] = "units/UEB0304/UEB0304_script.lua",
                ["sha256"] = "485e0db6359420dc330abdff78799c5189cc9cc9cf5a5cb384f4f0d2f811192a",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ues5014",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoSourceSecondaryVisuals"] = {
            ["effects"] = {
                [1] = {
                    ["bone"] = "Left_Gate_FX",
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5014/secondary_gate.sanvfx",
                    ["when"] = "complete",
                },
                [2] = {
                    ["bone"] = "Right_Gate_FX",
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/ues5014/secondary_gate.sanvfx",
                    ["when"] = "complete",
                },
            },
            ["gateEmitterProvenance"] = {
                ["emitters"] = {
                    [1] = {
                        ["archive"] = "effects.scd",
                        ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                        ["limitations"] = {
                            [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                        },
                        ["nativeMaterial"] = "VFX/SCOM/Source/Materials/1c49ae76fb69730e29ab.sanmaterial",
                        ["path"] = "effects/Emitters/terran_gate_01_emit.bp",
                        ["ramp"] = {
                            ["archive"] = "textures.scd",
                            ["path"] = "textures/particles/ramp_quantum_gate.dds",
                            ["sha256"] = "b52af8909e7e5cebcd335608cded86c24e28401262aa25e8898f2a1baaa0006e",
                        },
                        ["scale"] = 1,
                        ["sha256"] = "108df24d6671a004390ea1dbb1c104f545d6ba7f53e81c91233d739cbde67db4",
                        ["sourceBlueprint"] = {
                            ["AlignRotation"] = false,
                            ["AlignToBone"] = false,
                            ["Blendmode"] = 3,
                            ["BlueprintId"] = "terran_gate_01",
                            ["CatchupEmit"] = true,
                            ["CreateIfVisible"] = false,
                            ["EmitIfVisible"] = true,
                            ["EmitRateCurve"] = {
                                ["Keys"] = {
                                    [1] = {
                                        ["x"] = 25.132,
                                        ["y"] = 15.476,
                                        ["z"] = 0,
                                    },
                                },
                                ["XRange"] = 50,
                            },
                            ["EndSizeCurve"] = {
                                ["Keys"] = {
                                    [1] = {
                                        ["x"] = 25,
                                        ["y"] = 0.025,
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
                                        ["y"] = 0,
                                        ["z"] = 0,
                                    },
                                },
                                ["XRange"] = 50,
                            },
                            ["InterpolateEmission"] = true,
                            ["LODCutoff"] = 500,
                            ["Lifetime"] = -1,
                            ["LifetimeCurve"] = {
                                ["Keys"] = {
                                    [1] = {
                                        ["x"] = 25.396,
                                        ["y"] = 10,
                                        ["z"] = 0,
                                    },
                                },
                                ["XRange"] = 50,
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
                                        ["x"] = 25,
                                        ["y"] = 0.5,
                                        ["z"] = 1,
                                    },
                                },
                                ["XRange"] = 50,
                            },
                            ["RampTexture"] = "/textures/particles/ramp_quantum_gate.dds",
                            ["Repeattime"] = 50,
                            ["ResistanceCurve"] = {
                                ["Keys"] = {
                                    [1] = {
                                        ["x"] = 5,
                                        ["y"] = 0,
                                        ["z"] = 0,
                                    },
                                },
                                ["XRange"] = 10,
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
                                        ["y"] = 0.025,
                                        ["z"] = 0,
                                    },
                                },
                                ["XRange"] = 50,
                            },
                            ["Texture"] = "/textures/particles/blurry_rectangle_add_01.dds",
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
                                        ["y"] = 0.1,
                                        ["z"] = 0.18,
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
                                        ["z"] = 0.2,
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
                                        ["x"] = 9.96,
                                        ["y"] = 0,
                                        ["z"] = 0,
                                    },
                                },
                                ["XRange"] = 50,
                            },
                            ["YPosCurve"] = {
                                ["Keys"] = {
                                    [1] = {
                                        ["x"] = 25.462,
                                        ["y"] = -0.25,
                                        ["z"] = 2.25,
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
                                        ["x"] = 19.459,
                                        ["y"] = 1,
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
                            ["path"] = "textures/particles/blurry_rectangle_add_01.dds",
                            ["sha256"] = "37cc4391cfcff217ab9f959f4db397b3b93c78507615abf991f8a1d30afb1a17",
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
                ["path"] = "VFX/SCOM/Source/ues5014/secondary_gate.sanvfx",
                ["rangeConvention"] = "Source Range z is full range (mean +/- z/2), documented by FAF emitter editor: https://wiki.faforever.com/en/Development/Modding/Modding_Emitters",
                ["sha256"] = "2cb5f93ae96770eea21345d2b176a92747e8ac99b9710ff9eefd450eb67690b3",
                ["sourcePositionAndSpeed"] = {
                    ["archive"] = "effects.scd",
                    ["path"] = "effects/Emitters/terran_gate_01_emit.bp",
                    ["sha256"] = "108df24d6671a004390ea1dbb1c104f545d6ba7f53e81c91233d739cbde67db4",
                },
            },
            ["meshes"] = {
                [1] = {
                    ["bone"] = "Root",
                    ["entityName"] = "SCO_Secondary_forcefield01",
                    ["geometry"] = {
                        ["boundsMax"] = {
                            [1] = 2.0607955455780029,
                            [2] = 0.18644788861274719,
                            [3] = 3.2244594097137451,
                        },
                        ["boundsMin"] = {
                            [1] = -2.0607962608337402,
                            [2] = -0.18644788861274719,
                            [3] = 0.13136129081249237,
                        },
                        ["coordinateBasis"] = "native Root local basis; closed aperture rectangle with 0.02 sill overlap",
                        ["sourcePositionsExact"] = false,
                        ["sourceVertices"] = 52,
                        ["triangles"] = 12,
                        ["vertices"] = 24,
                    },
                    ["material"] = "VFX/SCOM/Secondary/uef_gateway_field.sanmaterial",
                    ["model"] = "VFX/SCOM/Secondary/uef_gateway_field.sanmodel",
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["outputs"] = {
                        ["VFX/SCOM/Secondary/uef_gateway_field.sanmodel"] = "19f0178c86a139389d7b96510c1d3ad202f2a1ee7519119bcea6f311a1b817b2",
                        ["VFX/SCOM/Secondary/forcefield01.sanmaterial"] = "db7f44e06c7602b68fe86ba97c007ffc355b76fe1410f5e82c8db95d99240ef7",
                        ["VFX/SCOM/Secondary/forcefield01.sanmodel"] = "f4e57cabec75e88e586a98ecd037f9d5bb158f8d801750b8430f571aee5c1ece",
                        ["VFX/SCOM/Secondary/forcefield01_albedo.dds"] = "7a1b631f75d62dd13934df170b8756f07328b344828f6430c182ecf1aad44252",
                        ["VFX/SCOM/Secondary/forcefield01_normal.dds"] = "87daca0c96b72abdc110173f7a22bbde1ce87ca33efa708eeab4e97758d7ded2",
                    },
                    ["scale"] = 1,
                    ["sourceBone"] = "UEB0304",
                    ["sourceMeshBlueprint"] = "/effects/entities/ForceField01/ForceField01_mesh.bp",
                    ["sourceShader"] = "UEFQuantumGate",
                    ["when"] = "complete",
                },
            },
            ["sourceBlueprintSha256"] = "d312a74e9a6bb153922726e4995e28aa8cd43a031569661ce740e7847d1f25df",
            ["sourceId"] = "UEB0304",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1586,
                ["entry"] = "units/UEB0304/UEB0304_script.lua",
                ["sha256"] = "485e0db6359420dc330abdff78799c5189cc9cc9cf5a5cb384f4f0d2f811192a",
            },
            ["targetId"] = "ues5014",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 7.25,
            ["y"] = 3.5,
            ["z"] = 1.5,
        },
    },
    ["construction"] = {
        ["platformBoneName"] = "Attachpoint01",
        ["buildPower"] = 120,
        ["canBuild"] = "((Tags.SCFA_BUILTBYQUANTUMGATE * Tags.SCFA_UEF)) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
        ["rollOffPoints"] = {
            [1] = {
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 3,
                },
                ["platformOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = 0,
            },
            [2] = {
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = -3,
                },
                ["platformOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 2,
                ["unitSpin"] = 180,
            },
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 10000,
            ["regen"] = 0,
            ["value"] = 10000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 3000,
        ["cost"] = {
            ["alloys"] = 3000,
            ["energy"] = 30000,
        },
    },
    ["footprint"] = {
        ["x"] = 7,
        ["y"] = 7,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDALandFactory",
        },
        ["displayName"] = "Quantum Gateway",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 220,
        ["iconUIType"] = "land",
        ["name"] = "Quantum Gateway",
        ["orders"] = {
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["RepeatBuild"] = true,
        },
        ["tpId"] = "ues5014",
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
        ["x"] = 10,
        ["y"] = 10,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "EDA",
        [3] = "FACTORY",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_BUILTBYTIER3COMMANDER",
        [6] = "SCFA_BUILTBYTIER3ENGINEER",
        [7] = "SCFA_DRAGBUILD",
        [8] = "SCFA_FACTORY",
        [9] = "SCFA_GATE",
        [10] = "SCFA_PRODUCTSC1",
        [11] = "SCFA_RALLYPOINT",
        [12] = "SCFA_RECLAIMABLE",
        [13] = "SCFA_SELECTABLE",
        [14] = "SCFA_SHOWQUEUE",
        [15] = "SCFA_SIZE20",
        [16] = "SCFA_SORTSTRATEGIC",
        [17] = "SCFA_STRUCTURE",
        [18] = "SCFA_TECH3",
        [19] = "SCFA_UEF",
        [20] = "SCFA_VISIBLETORECON",
        [21] = "STRUCTURE",
        [22] = "TECH3",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5014/LOD0/ues5014.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5014/LOD0/ues5014.sananimation",
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
                    ["x"] = 1.305,
                    ["y"] = 0.625,
                    ["z"] = -0.30000000000000004,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.595,
                    ["y"] = 0.38,
                    ["z"] = 0.27,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.4500000000000002,
                    ["y"] = 0.7300000000000001,
                    ["z"] = 0.24,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.305,
                    ["y"] = 1.22,
                    ["z"] = -0.30000000000000004,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.595,
                    ["y"] = 1.1500000000000001,
                    ["z"] = 0.27,
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
                ["x"] = 4,
                ["y"] = 3.75,
            },
        },
    },
    ["weapons"] = {},
}
