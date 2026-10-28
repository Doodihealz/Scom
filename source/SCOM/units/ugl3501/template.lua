-- ugl3501: Engineer
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Buildpoint_Left",
            [2] = "Buildpoint_Center",
            [3] = "Buildpoint_Right",
        },
        ["buildBeamEffectName"] = "beam1",
        ["faEngineerWaterAnimation"] = {
            ["animationSha256"] = "616769ea98f6ce14e7a612df4b8a8b4ae2048a07e50b40df351f2a722b9f7a80",
            ["buildCloseSeconds"] = 0,
            ["durationSeconds"] = 0.8999999761581421,
            ["exactTimeOwner"] = "coordinator -10000 progress-frame sentinel",
            ["limitation"] = "none",
            ["mapping"] = "URL0309 -> ugl3501",
            ["mediumProbe"] = "guarded water level + root world position + terrain height with hysteresis",
            ["omittedSourceHelpers"] = {},
            ["packageSha256"] = "feb5dbaa525a32f6987734620efe3f4643cb17e5a234e4518f8180b06704d11f",
            ["sourceAnimationWater"] = "units/URL0309/URL0309_Awheels.sca",
            ["sourceAnimationWaterSha256"] = "acc8961e61dc1091022de639317e71aa4adbdacf038906c6aa99f81259b444f8",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/URL0309/URL0309_unit.bp",
            ["sourceBlueprintSha256"] = "70ad5c542a3781bb25e0dda8c2d29bf8b699bed8f6ce5e6d6284826e6e4a0232",
            ["sourceDormantTransform"] = {
                ["runtimeBound"] = false,
                ["sha256"] = "30187773af22fee6b3fe0e1e132b9e8f72a83c1fcd2d44e2ffec3fff8743e9c6",
                ["source"] = "units/URL0309/URL0309_Atransform01.sca",
            },
            ["sourceFactionLifecycle"] = "lua/cybranunits.lua",
            ["sourceFactionLifecycleSha256"] = "f126ce26875ef8b51f240296af8bd0d86ff07e3fc4b2a5ebf0a5ba4478687411",
            ["sourceFrames"] = 28,
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceRate"] = 1,
            ["sourceReverseRate"] = -1,
            ["sourceScript"] = "units/URL0309/URL0309_script.lua",
            ["sourceScriptSha256"] = "80206def06b03e4ec47e92d7304b6813a46e37b717aad42bc853d9aed55310f5",
        },
        ["faSourceContract"] = {
            ["mapping"] = "URL0309 -> ugl3501",
            ["sanctuaryTeleportSupported"] = false,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudio"] = {
                ["ambientMoveCue"] = "URL0309_Move_Loop",
                ["bank"] = "URL",
                ["bankImported"] = false,
                ["sanctuaryDonorMovementLoopRetained"] = true,
            },
            ["sourceBlueprint"] = "units/URL0309/URL0309_unit.bp",
            ["sourceBlueprintSha256"] = "70ad5c542a3781bb25e0dda8c2d29bf8b699bed8f6ce5e6d6284826e6e4a0232",
            ["sourceMovement"] = {
                ["independentBrakeSupported"] = false,
                ["independentReverseSupported"] = false,
                ["maxBrake"] = 1.9,
                ["maxReverseSpeed"] = 1.6,
                ["sanctuaryType"] = "TracksAmphibious",
                ["type"] = "RULEUMT_AmphibiousFloating",
            },
            ["sourceScript"] = "units/URL0309/URL0309_script.lua",
            ["sourceScriptSha256"] = "80206def06b03e4ec47e92d7304b6813a46e37b717aad42bc853d9aed55310f5",
            ["sourceTeleportEnergyMod"] = 0.15,
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0.8184675859750081,
                [3] = -0.3814491816346763,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 3,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "URL0309",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 94697,
                ["entry"] = "units/URL0309/URL0309_lod0.scm",
                ["sha256"] = "61cfd9eda58fb135812621514f1c61ce5aeacabd6e83325ec78a10ad86b1182a",
            },
        },
        ["scoGameplayEngineerBeam"] = "1.0.0",
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/ugl3501/LOD0/ugl3501_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.3617839515209198,
                        ["y"] = -0.00042313362968589806,
                        ["z"] = 0.29259118444900944,
                    },
                    ["width"] = 0.156337,
                },
                [2] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.3617836534976959,
                        ["y"] = -0.00042266828682279746,
                        ["z"] = -0.2782975434544432,
                    },
                    ["width"] = 0.156337,
                },
                [3] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.3618428111076355,
                        ["y"] = -0.00042296506025467535,
                        ["z"] = 0.2925914526698825,
                    },
                    ["width"] = 0.156337,
                },
                [4] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.3618428409099579,
                        ["y"] = -0.0004229160185573056,
                        ["z"] = -0.278297126221888,
                    },
                    ["width"] = 0.156337,
                },
            },
            ["unit"] = "ugl3501",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.41,
                ["z"] = -0.01,
            },
            ["size"] = {
                ["x"] = 1.3,
                ["y"] = 1.4,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aglu1430",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod1130",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.41,
            ["z"] = -0.01,
        },
        ["collisionSize"] = {
            ["x"] = 1.1,
            ["y"] = 1,
            ["z"] = 1.2,
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
        ["buildPower"] = 15,
        ["canBuild"] = "(Tags.GUARD * Tags.BUILDABLE_BY_T3_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1425,
            ["regen"] = 0,
            ["value"] = 1425,
        },
    },
    ["economy"] = {
        ["buildTime"] = 2100,
        ["cost"] = {
            ["alloys"] = 490,
            ["energy"] = 3150,
        },
        ["storage"] = {
            ["alloys"] = 40,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 1.5,
        ["y"] = 1.6,
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
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_land1_engineer.png",
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
        ["tpId"] = "ugl3501",
        ["unitTypeName"] = "GuardT3Engineer",
    },
    ["intel"] = {
        ["visionRadius"] = 26,
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
                ["y"] = 0.5,
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
            ["outerRadius"] = 26,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 26,
        },
    },
    ["tags"] = {
        [1] = "AMPHIBIOUS",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "CONSTRUCTION",
        [4] = "ENGINEER",
        [5] = "GUARD",
        [6] = "HARVEST",
        [7] = "LAND",
        [8] = "MOBILE",
        [9] = "TECH3",
        [10] = "ALLOYS_STORAGE",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYTIER3FACTORY",
        [13] = "SCFA_CAPTURE",
        [14] = "SCFA_CONSTRUCTION",
        [15] = "SCFA_CYBRAN",
        [16] = "SCFA_ENGINEER",
        [17] = "SCFA_LAND",
        [18] = "SCFA_MOBILE",
        [19] = "SCFA_PATROLHELPER",
        [20] = "SCFA_PRODUCTSC1",
        [21] = "SCFA_RECLAIM",
        [22] = "SCFA_RECLAIMABLE",
        [23] = "SCFA_REPAIR",
        [24] = "SCFA_SELECTABLE",
        [25] = "SCFA_SHOWQUEUE",
        [26] = "SCFA_TECH3",
        [27] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl3501/LOD0/ugl3501.sananimation",
            },
            ["waterTransform"] = {
                ["clipName"] = "AnimWater",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl3501/LOD0/ugl3501.sananimation",
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
                    ["particleName"] = "VFX/Death/vgd1301_death_land_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.198,
                    ["y"] = 0.6599999999999999,
                    ["z"] = -0.25,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.24200000000000002,
                    ["y"] = 0.59,
                    ["z"] = 0.206,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.22000000000000003,
                    ["y"] = 0.69,
                    ["z"] = 0.182,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.198,
                    ["y"] = 0.83,
                    ["z"] = -0.25,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.24200000000000002,
                    ["y"] = 0.81,
                    ["z"] = 0.206,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 73,
            ["lod1distance"] = 191,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.41,
                ["z"] = -0.01,
            },
            ["size"] = {
                ["x"] = 1.3,
                ["y"] = 1.4,
            },
        },
    },
}
