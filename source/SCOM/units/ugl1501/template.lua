-- ugl1501: Engineer
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Buildpoint_Center",
        },
        ["buildBeamEffectName"] = "beam1",
        ["faEngineerWaterAnimation"] = {
            ["animationSha256"] = "66419a8e261d0b6f2630983eae5907a8c2a5d8606097419dd50b2ea2807d4d5a",
            ["buildCloseSeconds"] = 0,
            ["durationSeconds"] = 0.8999999761581421,
            ["exactTimeOwner"] = "coordinator -10000 progress-frame sentinel",
            ["limitation"] = "none",
            ["mapping"] = "URL0105 -> ugl1501",
            ["mediumProbe"] = "guarded water level + root world position + terrain height with hysteresis",
            ["omittedSourceHelpers"] = {},
            ["packageSha256"] = "feb5dbaa525a32f6987734620efe3f4643cb17e5a234e4518f8180b06704d11f",
            ["rejectedLegacy"] = {
                ["Aconstruct01"] = "204f9658bc3b64942528ee351a7aebf11fc55992064ff61a80a1f6b785db99ea",
                ["Aconstruct02"] = "015d9c3623496a0438066a840eb743bb5f5641d2a174ed82ef0805105bfa731e",
                ["Aidle01"] = "c1ddae02300f55c9b78d66b929747e5834ec9651574718a55c5c80e1190a32df",
                ["Aidle02"] = "f23550c0a661e33de0e16d1d053697a094b25d57b0f2f6b1f940cae7cd83ee93",
                ["Aswim01"] = "47e3d0a992471be4e47ad7bdadfbd18300adeb1c3d17992c1240a54986a679c4",
                ["Atransform02"] = "82a3e3ec00a586d977fbbfcc34c0281edb5539b0193ebda008d747c8a00ed0f9",
                ["Awalk01"] = "327baed48899d3b42a2dc2c387447c10365c9a4b3e48e6b067db3df51ad5d379",
                ["reason"] = "moving source hierarchy is absent from native LOD0 skeleton; no alias is valid",
            },
            ["sourceAnimationWater"] = "units/URL0105/URL0105_Awheels.sca",
            ["sourceAnimationWaterSha256"] = "4ab6dea31186e457030d13094d40e4c1e8e1e1969ed63f17373f86c4dd29c1bb",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/URL0105/URL0105_unit.bp",
            ["sourceBlueprintSha256"] = "3eb677289b63514a1152a1328f899d7a8a88bdc549a3556bb77cd3562508ac8e",
            ["sourceDormantTransform"] = {
                ["runtimeBound"] = false,
                ["sha256"] = "2b1dbba7ca3901562622ee516135f9f716ea5bceba6f5972885fa3ea9059ea52",
                ["source"] = "units/URL0105/URL0105_Atransform01.sca",
            },
            ["sourceFactionLifecycle"] = "lua/cybranunits.lua",
            ["sourceFactionLifecycleSha256"] = "f126ce26875ef8b51f240296af8bd0d86ff07e3fc4b2a5ebf0a5ba4478687411",
            ["sourceFrames"] = 28,
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceRate"] = 1,
            ["sourceReverseRate"] = -1,
            ["sourceScript"] = "units/URL0105/URL0105_script.lua",
            ["sourceScriptSha256"] = "39de5d1c7b1f97f8c4294c45d9edb7a958f0cff8f2d4653d5ee286c5378687f9",
        },
        ["faSourceContract"] = {
            ["mapping"] = "URL0105 -> ugl1501",
            ["sanctuaryTeleportSupported"] = false,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudio"] = {
                ["ambientMoveCue"] = "URL0105_Move_Loop",
                ["bank"] = "URL",
                ["bankImported"] = false,
                ["sanctuaryDonorMovementLoopRetained"] = true,
            },
            ["sourceBlueprint"] = "units/URL0105/URL0105_unit.bp",
            ["sourceBlueprintSha256"] = "3eb677289b63514a1152a1328f899d7a8a88bdc549a3556bb77cd3562508ac8e",
            ["sourceMovement"] = {
                ["independentBrakeSupported"] = false,
                ["independentReverseSupported"] = false,
                ["maxBrake"] = 1.9,
                ["maxReverseSpeed"] = 1.7,
                ["sanctuaryType"] = "TracksAmphibious",
                ["type"] = "RULEUMT_AmphibiousFloating",
            },
            ["sourceScript"] = "units/URL0105/URL0105_script.lua",
            ["sourceScriptSha256"] = "39de5d1c7b1f97f8c4294c45d9edb7a958f0cff8f2d4653d5ee286c5378687f9",
            ["sourceTeleportEnergyMod"] = 0.15,
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0.4759580608882085,
                [3] = -0.19603212845751605,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "URL0105",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 59209,
                ["entry"] = "units/URL0105/URL0105_LOD0.scm",
                ["sha256"] = "c1077d151a1798ccce6e942bc7bc4bdfa0ca89703ee5a3507e79c22228c21ec2",
            },
        },
        ["scoGameplayEngineerBeam"] = "1.0.0",
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/ugl1501/LOD0/ugl1501_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.20789997279644012,
                        ["y"] = -0.00024308804787743707,
                        ["z"] = 0.16813716296479683,
                    },
                    ["width"] = 0.089839,
                },
                [2] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.2078995406627655,
                        ["y"] = -0.00024307164284619737,
                        ["z"] = -0.15992297228053376,
                    },
                    ["width"] = 0.089839,
                },
                [3] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.20793230831623077,
                        ["y"] = -0.00024305358894468818,
                        ["z"] = 0.16813714806362984,
                    },
                    ["width"] = 0.089839,
                },
                [4] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.20793235301971436,
                        ["y"] = -0.00024303252729555164,
                        ["z"] = -0.15992295737937917,
                    },
                    ["width"] = 0.089839,
                },
            },
            ["unit"] = "ugl1501",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.24,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1,
                ["y"] = 1,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aglu1410",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod1110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.24,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.8,
            ["y"] = 0.7,
            ["z"] = 0.8,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Buildpoint_Center",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 5,
        ["canBuild"] = "(Tags.GUARD * Tags.BUILDABLE_BY_T1_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 145,
            ["regen"] = 0,
            ["value"] = 145,
        },
    },
    ["economy"] = {
        ["buildTime"] = 260,
        ["cost"] = {
            ["alloys"] = 52,
            ["energy"] = 260,
        },
        ["storage"] = {
            ["alloys"] = 10,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 1.2,
        ["y"] = 1.2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardEngineer",
        },
        ["displayName"] = "Engineer",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "engineer",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_engineer.png",
        ["iconUIBuildSortPriority"] = 150,
        ["iconUIType"] = "amphibious",
        ["name"] = "Engineer",
        ["orders"] = {
            ["Assist"] = true,
            ["AttackMove"] = true,
            ["Capture"] = true,
            ["Harvest"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Pause"] = false,
            ["Repair"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "ugl1501",
        ["unitTypeName"] = "GuardT1Engineer",
    },
    ["intel"] = {
        ["visionRadius"] = 18,
    },
    ["movement"] = {
        ["acceleration"] = 1.9,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
            [2] = "SeabedSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
            [2] = "SeabedSmall",
        },
        ["hullWaterSensor"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.3,
                ["z"] = 0,
            },
        },
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 120,
        ["sortOrder"] = 6,
        ["speed"] = 1.9,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "TracksAmphibious",
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 5,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 18,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 18,
        },
    },
    ["tags"] = {
        [1] = "AMPHIBIOUS",
        [2] = "BUILDABLE_BY_T1_FACTORY",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "CONSTRUCTION",
        [6] = "ENGINEER",
        [7] = "GUARD",
        [8] = "HARVEST",
        [9] = "LAND",
        [10] = "MOBILE",
        [11] = "TECH1",
        [12] = "ALLOYS_STORAGE",
        [13] = "SCFA_ALLUNITS",
        [14] = "SCFA_BUILTBYTIER1FACTORY",
        [15] = "SCFA_BUILTBYTIER2FACTORY",
        [16] = "SCFA_BUILTBYTIER3FACTORY",
        [17] = "SCFA_CAPTURE",
        [18] = "SCFA_CONSTRUCTION",
        [19] = "SCFA_CYBRAN",
        [20] = "SCFA_ENGINEER",
        [21] = "SCFA_LAND",
        [22] = "SCFA_MOBILE",
        [23] = "SCFA_PATROLHELPER",
        [24] = "SCFA_PRODUCTSC1",
        [25] = "SCFA_RECLAIM",
        [26] = "SCFA_RECLAIMABLE",
        [27] = "SCFA_REPAIR",
        [28] = "SCFA_SELECTABLE",
        [29] = "SCFA_SHOWQUEUE",
        [30] = "SCFA_TECH1",
        [31] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl1501/LOD0/ugl1501.sananimation",
            },
            ["waterTransform"] = {
                ["clipName"] = "AnimWater",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl1501/LOD0/ugl1501.sananimation",
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
                    ["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Explosions/mi explosion 03 hpx.ogg",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vgd1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.415,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.366,
                    ["z"] = 0.144,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.16000000000000003,
                    ["y"] = 0.436,
                    ["z"] = 0.128,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.534,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.52,
                    ["z"] = 0.144,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 66,
            ["lod1distance"] = 173,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.24,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1,
                ["y"] = 1,
            },
        },
    },
}
