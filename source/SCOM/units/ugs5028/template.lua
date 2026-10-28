-- ugs5028: Soothsayer
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
                        [1] = "TargetBone01",
                        [2] = "TargetBone03",
                        [3] = "TargetBone02",
                    },
                    ["blueprintUses"] = {
                        [1] = ".Display.AnimationPermOpen",
                    },
                    ["bytes"] = 9434,
                    ["clipName"] = "Faxrb3301aopen",
                    ["duration"] = 3.3333332538604736,
                    ["entry"] = "units/XRB3301/xrb3301_aopen.sca",
                    ["frames"] = 101,
                    ["outputDuration"] = 3.3333332538604736,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "2f5e81889a3f334b83a71a1154b0addc4ce46160feb4ff045c38f264e0b2c324",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 3,
                    ["usedBySource"] = true,
                },
            },
            ["sourceBlueprint"] = "units/XRB3301/XRB3301_unit.bp",
            ["sourceBlueprintSha256"] = "84f4883c8f9584f26206dbeaf9d2b376294a453f07683b94e1fb26b51b6598a8",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "XRB3301",
            ["sourceIntel"] = {
                ["MaxVisionRadius"] = 200,
                ["MinVisionRadius"] = 10,
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
                ["SkirtOffsetX"] = -0.5,
                ["SkirtOffsetZ"] = -0.5,
                ["SkirtSizeX"] = 6,
                ["SkirtSizeZ"] = 6,
                ["TurnRate"] = 0,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 5481,
                ["entry"] = "units/XRB3301/XRB3301_script.lua",
                ["sha256"] = "171f26afef5ee27fca7d4e470dd0af6a420f85cca4e6719737d086c9e9649580",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {},
            ["targetId"] = "ugs5028",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoSoothsayer"] = {
            ["deathInterval"] = 0.1,
            ["deathSteps"] = 15,
            ["initialDelay"] = 0.1,
            ["interval"] = 0.2,
            ["maximum"] = 200,
            ["minimum"] = 10,
            ["sourceId"] = "XRB3301",
            ["sourceScriptSha256"] = "171f26afef5ee27fca7d4e470dd0af6a420f85cca4e6719737d086c9e9649580",
            ["step"] = 1,
            ["version"] = 1,
        },
        ["scoSourceSecondaryVisuals"] = {
            ["animationState"] = {
                ["clipName"] = "Faxrb3301aopen",
                ["condition"] = "complete",
                ["duration"] = 3.3333332538604736,
                ["forwardRate"] = 1,
                ["key"] = "scoSecondaryOpen",
                ["reverseRate"] = 0,
                ["sanAnimationPath"] = "Units/ugs5028/LOD0/ugs5028.sananimation",
                ["source"] = {
                    ["archive"] = "units.scd",
                    ["bindPoseTracks"] = {
                        [1] = "TargetBone01",
                        [2] = "TargetBone03",
                        [3] = "TargetBone02",
                    },
                    ["blueprintUses"] = {
                        [1] = ".Display.AnimationPermOpen",
                    },
                    ["bytes"] = 9434,
                    ["clipName"] = "Faxrb3301aopen",
                    ["duration"] = 3.3333332538604736,
                    ["entry"] = "units/XRB3301/xrb3301_aopen.sca",
                    ["frames"] = 101,
                    ["outputDuration"] = 3.3333332538604736,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "2f5e81889a3f334b83a71a1154b0addc4ce46160feb4ff045c38f264e0b2c324",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 3,
                    ["usedBySource"] = true,
                },
            },
            ["effects"] = {},
            ["meshes"] = {},
            ["sourceBlueprintSha256"] = "84f4883c8f9584f26206dbeaf9d2b376294a453f07683b94e1fb26b51b6598a8",
            ["sourceId"] = "XRB3301",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 5481,
                ["entry"] = "units/XRB3301/XRB3301_script.lua",
                ["sha256"] = "171f26afef5ee27fca7d4e470dd0af6a420f85cca4e6719737d086c9e9649580",
            },
            ["targetId"] = "ugs5028",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 3,
            ["y"] = 7,
            ["z"] = 4.1,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 500,
            ["regen"] = 0,
            ["value"] = 500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 800,
        ["cost"] = {
            ["alloys"] = 4800,
            ["energy"] = 60000,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 3000,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardStructure",
        },
        ["displayName"] = "Soothsayer",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 200,
        ["iconUIType"] = "land",
        ["name"] = "Soothsayer",
        ["orders"] = {},
        ["toggles"] = {
            ["Intel"] = true,
        },
        ["tpId"] = "ugs5028",
    },
    ["intel"] = {
        ["visionRadius"] = 10,
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
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "GUARD",
        [3] = "SCFA_ALLUNITS",
        [4] = "SCFA_BUILTBYTIER3COMMANDER",
        [5] = "SCFA_BUILTBYTIER3ENGINEER",
        [6] = "SCFA_CYBRAN",
        [7] = "SCFA_DRAGBUILD",
        [8] = "SCFA_INTELLIGENCE",
        [9] = "SCFA_OPTICS",
        [10] = "SCFA_OVERLAYMISC",
        [11] = "SCFA_PRODUCTFA",
        [12] = "SCFA_RECLAIMABLE",
        [13] = "SCFA_SELECTABLE",
        [14] = "SCFA_SIZE12",
        [15] = "SCFA_SORTINTEL",
        [16] = "SCFA_STRUCTURE",
        [17] = "SCFA_TECH3",
        [18] = "SCFA_VISIBLETORECON",
        [19] = "STRUCTURE",
        [20] = "TECH3",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5028/LOD0/ugs5028.sananimation",
            },
            ["scoSecondaryOpen"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "Faxrb3301aopen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5028/LOD0/ugs5028.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs5028/LOD0/ugs5028.sananimation",
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
                    ["x"] = 0.54,
                    ["y"] = 1.5,
                    ["z"] = -0.82,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.66,
                    ["y"] = 1.01,
                    ["z"] = 0.7379999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.6000000000000001,
                    ["y"] = 1.7100000000000002,
                    ["z"] = 0.6559999999999999,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.54,
                    ["y"] = 2.69,
                    ["z"] = -0.82,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.66,
                    ["y"] = 2.5500000000000003,
                    ["z"] = 0.7379999999999999,
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
                ["x"] = 3.1,
                ["y"] = 3,
            },
        },
    },
    ["weapons"] = {},
}
