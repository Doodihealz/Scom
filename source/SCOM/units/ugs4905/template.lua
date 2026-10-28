-- ugs4905: Experimental Construction Egg
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["directProductSubstitution"] = {
                ["source"] = "url0304",
                ["target"] = "ugl3101",
            },
            ["mapping"] = "XRL0005 -> ugs4905",
            ["productDependencyMustExistAtRuntime"] = true,
            ["sourceAnimationDurationSeconds"] = 0.6666666865348816,
            ["sourceAnimationFrames"] = 21,
            ["sourceAnimationRate"] = 0.1,
            ["sourceAnimationSha256"] = "b31e76daa6d30ed9b832bcbe97a7277a3a46d444aff99cab8d1b64011285b734",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/XRL0005/XRL0005_unit.bp",
            ["sourceBlueprintSha256"] = "15a4a7e97d35e1e59a9506cbf864243625cd469aafe591dab12ff6221f63d101",
            ["sourceModelSha256"] = "407b59bbe32c69dc16abc858a1fa9a8994fb34af2c155fab5ab99abf75bbbd73",
            ["sourceRigBones"] = 4,
            ["sourceRuntimeDurationSeconds"] = 6.666666865348816,
            ["sourceScript"] = "units/XRL0005/XRL0005_script.lua",
            ["sourceScriptSha256"] = "64d57a0a49c88dac79108d0af9aba591e4a06cfc3062bbd1a399a3ad79952e3e",
            ["sourceUniformScale"] = 0.05,
        },
        ["megalithEgg"] = {
            ["clientSpawnBehavior"] = false,
            ["hostOwnsSpawnAndDelete"] = true,
            ["openAnimationKey"] = "open",
            ["openDurationSeconds"] = 6.666666865348816,
            ["product"] = "ugl3101",
            ["sinkDistance"] = 20,
            ["sinkSpeed"] = 5,
            ["sourceBuildUnit"] = "url0304",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.5,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.5,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 1,
            ["z"] = 1,
        },
        ["targetBones"] = {
            [1] = "Root",
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 10,
            ["regen"] = 0,
            ["value"] = 10,
        },
    },
    ["economy"] = {
        ["buildTime"] = 4800,
        ["cost"] = {
            ["alloys"] = 800,
            ["energy"] = 8000,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardMegalithEgg",
        },
        ["displayName"] = "Experimental Construction Egg",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "factory",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech3_structure1_factory.png",
        ["iconUIBuildSortPriority"] = 490,
        ["iconUIType"] = "land",
        ["name"] = "Megalith Trebuchet Egg",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["tpId"] = "ugs4905",
    },
    ["intel"] = {
        ["visionRadius"] = 5,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 5,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 5,
        },
    },
    ["skirtSize"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["tags"] = {
        [1] = "EXPERIMENTAL",
        [2] = "GUARD",
        [3] = "LAND",
        [4] = "MEGALITH_EGG",
        [5] = "STRUCTURE",
        [6] = "TECH4",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_CONSTRUCTION",
        [9] = "SCFA_CYBRAN",
        [10] = "SCFA_DRAGBUILD",
        [11] = "SCFA_FACTORY",
        [12] = "SCFA_LAND",
        [13] = "SCFA_PRODUCTFA",
        [14] = "SCFA_RALLYPOINT",
        [15] = "SCFA_RECLAIMABLE",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SHOWQUEUE",
        [18] = "SCFA_STRUCTURE",
        [19] = "SCFA_TECH3",
        [20] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["open"] = {
                ["clipName"] = "Open",
                ["durationTicks"] = 67,
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs4905/LOD0/ugs4905.sananimation",
            },
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs4905/LOD0/ugs4905.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugs4905/LOD0/ugs4905.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.4,
                ["y"] = 0.4,
            },
            ["mainBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 1,
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
                    ["x"] = 0.18,
                    ["y"] = 0.75,
                    ["z"] = -0.2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.6799999999999999,
                    ["z"] = 0.18,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.78,
                    ["z"] = 0.16,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.9199999999999999,
                    ["z"] = -0.2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.9,
                    ["z"] = 0.18,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 100,
            ["lod1distance"] = 260,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.5,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
            ["thickness"] = 0.6,
        },
    },
    ["weapons"] = {},
}
