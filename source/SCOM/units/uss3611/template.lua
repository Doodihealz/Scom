-- uss3611: Uya-iya
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["sourceBlueprint"] = "units/XSB1301/XSB1301_unit.bp",
            ["sourceBlueprintSha256"] = "d3e64b6276d7da2404226e898e335bf91221602f27d46d7e2c78afdf8c6e6090",
            ["sourceId"] = "XSB1301",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 817,
                ["entry"] = "units/XSB1301/XSB1301_script.lua",
                ["sha256"] = "00f890450a4a7f11c294d379f10239d3e7946da4fc0b0f59db2a010e9ea84586",
            },
            ["targetId"] = "uss3611",
        },
        ["rotators"] = {},
        ["scoSourceSecondaryVisuals"] = {
            ["ambientSource"] = {
                ["baseClass"] = {
                    ["archive"] = "lua.scd",
                    ["path"] = "lua/seraphimunits.lua",
                    ["sha256"] = "81c89428bc1b7c423e26ee2a75341bb87a1df6905fc9b510a4e62c8ba1bb95cf",
                },
                ["callback"] = "SEnergyCreationUnit.OnStopBeingBuilt",
                ["effectTemplate"] = {
                    ["archive"] = "lua.scd",
                    ["path"] = "lua/EffectTemplates.lua",
                    ["sha256"] = "a38581311b5b575aecde3eecb0805742ca06e1747253dab95346ebb20d9a7702",
                },
                ["sourceBone"] = 0,
                ["template"] = "ST3PowerAmbient",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/3af5a7dd89a47309e425.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_t3power_ambient_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_yellow_06.dds",
                                ["sha256"] = "812c4ba449a29160f17c6706fcfa80eb06c61b0a9adb6e0668cb4eb4c35311d1",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "062e4511d0529c9b46924710ad1d3eca316ef74028177cba99f11d4f608088ab",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_t3power_ambient_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25.594,
                                            ["y"] = 1,
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
                                ["LODCutoff"] = 250,
                                ["Lifetime"] = -1,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 11.5,
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
                                ["RampTexture"] = "/textures/particles/ramp_yellow_06.dds",
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
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 11.214,
                                            ["y"] = 0.5,
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
                                            ["y"] = 9,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 50,
                                },
                                ["Texture"] = "/textures/particles/ring_11.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 25,
                                            ["y"] = 2.5,
                                            ["z"] = 5,
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
                                            ["y"] = 0.1,
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
                                ["path"] = "textures/particles/ring_11.dds",
                                ["sha256"] = "6c382b9ea91e2eebe8f94027eb34253cf3b2b387b5203f19d0897a89cf680317",
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
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/0eae43d0d442e3ffed3f.sanmaterial",
                            ["path"] = "effects/Emitters/seraphim_t3power_ambient_02_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_ser_13.dds",
                                ["sha256"] = "170673142aba12567b53cca93be6a5de5c8cca4a2fe9ce7765e258904e962d94",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "0bfcd86510bb369e781f262e72d9dae7957cfc07964b9a946f45b02b0b5ffcbc",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = true,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "seraphim_t3power_ambient_02",
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
                                            ["y"] = 1.129,
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
                                ["LODCutoff"] = 250,
                                ["Lifetime"] = -0.2,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0.1,
                                            ["y"] = 21,
                                            ["z"] = 10,
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
                                ["RampTexture"] = "/textures/particles/ramp_ser_13.dds",
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
                                            ["y"] = 0.02,
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
                    ["path"] = "VFX/SCOM/Source/uss3611/ambient_power.sanvfx",
                    ["sha256"] = "04bd9b40e16ab09af56b9449a85a746edaa5987705f91c83627e6e25f7668900",
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
                    ["path"] = "VFX/SCOM/Source/uss3611/ambient_power.sanvfx",
                    ["sourceBone"] = "0",
                    ["when"] = "complete",
                },
            },
            ["forceSimulatedRotators"] = true,
            ["legacyStaticVisual"] = false,
            ["legacyTemplateClass"] = "SeraphimEnergyGenerator",
            ["legacyTemplateModule"] = "unitsDefaultSeraphim",
            ["meshes"] = {},
            ["rotators"] = {
                [1] = {
                    ["acceleration"] = 15,
                    ["axis"] = "y",
                    ["bone"] = "Orb",
                    ["delay"] = 0,
                    ["disabledAcceleration"] = 15,
                    ["initialSpeed"] = 0,
                    ["randomAddRange"] = 20,
                    ["speed"] = 80,
                },
            },
            ["sourceBlueprint"] = "units/XSB1301/XSB1301_unit.bp",
            ["sourceBlueprintSha256"] = "d3e64b6276d7da2404226e898e335bf91221602f27d46d7e2c78afdf8c6e6090",
            ["sourceId"] = "XSB1301",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 78888,
                ["entry"] = "units/XSB1301/XSB1301_lod0.scm",
                ["sha256"] = "e84cfff2f40af2908ff9ab8f52da9c566f075bf92648b6de6eb56c2dea8ec4f1",
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 817,
                ["entry"] = "units/XSB1301/XSB1301_script.lua",
                ["sha256"] = "00f890450a4a7f11c294d379f10239d3e7946da4fc0b0f59db2a010e9ea84586",
            },
            ["targetId"] = "uss3611",
            ["unsupportedEffects"] = {
                [1] = {
                    ["archive"] = "effects.scd",
                    ["path"] = "effects/Emitters/seraphim_t3power_ambient_04_emit.bp",
                    ["reason"] = "Source blend5 is refractive distortion; the native unlit compiler has no equivalent. The source distortion emitter remains unbound instead of changing it to an alpha ring.",
                    ["sha256"] = "a0a25017c265f38cc3bc7f4dbc6863b15d04ea6bd8fa40678c7cfedff00fddb5",
                },
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.375,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.75,
                ["y"] = 2.75,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 5,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 100,
            },
        },
    },
    ["adjacency"] = "T3EnergyGeneratorAdjacencyBuff",
    ["audio"] = {
        ["active"] = {
            ["looping"] = true,
            ["name"] = "aclu2330",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2120",
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
            ["energy"] = 2500,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimEnergyGenerator",
        },
        ["displayName"] = "Uya-iya",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "plasma",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_plasma.png",
        ["iconUIBuildSortPriority"] = 360,
        ["iconUIType"] = "amphibious",
        ["name"] = "Uya-iya",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "uss3611",
        ["unitTypeName"] = "UnknownT3EnergyGenerator",
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
        [2] = "SERAPHIM",
        [3] = "ECONOMIC",
        [4] = "ENERGY_PRODUCTION",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER3COMMANDER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_DRAGBUILD",
        [11] = "SCFA_ECONOMIC",
        [12] = "SCFA_ENERGYPRODUCTION",
        [13] = "SCFA_PRODUCTFA",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SERAPHIM",
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
                ["sanAnimationPath"] = "Units/uss3611/LOD0/uss3611.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3611/LOD0/uss3611.sananimation",
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
                    ["audioName"] = "unit_death_land_eda_large",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd2301_death_building_large.sanvfx",
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
            ["lod0distance"] = 122,
            ["lod1distance"] = 319,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.375,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.75,
                ["y"] = 2.75,
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
