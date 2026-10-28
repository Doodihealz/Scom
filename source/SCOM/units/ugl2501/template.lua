-- ugl2501: Engineer
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Buildpoint_Left",
            [2] = "Buildpoint_Right",
        },
        ["buildBeamEffectName"] = "beam1",
        ["faEngineerWaterAnimation"] = {
            ["animationSha256"] = "389f8aadbc4bcf477b2052e3ec01468bef5f202864471f45f3bd9e660d84450c",
            ["buildCloseSeconds"] = 0,
            ["durationSeconds"] = 0.8999999761581421,
            ["exactTimeOwner"] = "coordinator -10000 progress-frame sentinel",
            ["limitation"] = "none",
            ["mapping"] = "URL0208 -> ugl2501",
            ["mediumProbe"] = "guarded water level + root world position + terrain height with hysteresis",
            ["omittedSourceHelpers"] = {},
            ["packageSha256"] = "feb5dbaa525a32f6987734620efe3f4643cb17e5a234e4518f8180b06704d11f",
            ["sourceAnimationWater"] = "units/URL0208/URL0208_Awheels.sca",
            ["sourceAnimationWaterSha256"] = "b22f5638a2996d9d579558708c36532068d8009836bfad8fce2f35c3f83a1b97",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/URL0208/URL0208_unit.bp",
            ["sourceBlueprintSha256"] = "eddd9987117e3cc3062b849c1de7be153cefada2581ab12404ff01a41025f807",
            ["sourceDormantTransform"] = {
                ["runtimeBound"] = false,
                ["sha256"] = "4631c0ebd36d4dbdf0d7fcc992ffb410ff3fdabf4fbded79a6c09171d5a9655a",
                ["source"] = "units/URL0208/URL0208_Atransform01.sca",
            },
            ["sourceFactionLifecycle"] = "lua/cybranunits.lua",
            ["sourceFactionLifecycleSha256"] = "f126ce26875ef8b51f240296af8bd0d86ff07e3fc4b2a5ebf0a5ba4478687411",
            ["sourceFrames"] = 28,
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceRate"] = 1,
            ["sourceReverseRate"] = -1,
            ["sourceScript"] = "units/URL0208/URL0208_script.lua",
            ["sourceScriptSha256"] = "957785569c55c5cc0b992d22e55dd06f9585f3702c81e8726a4cbf9afef705a6",
        },
        ["faSourceContract"] = {
            ["mapping"] = "URL0208 -> ugl2501",
            ["sanctuaryTeleportSupported"] = false,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudio"] = {
                ["ambientMoveCue"] = "URL0208_Move_Loop",
                ["bank"] = "URL",
                ["bankImported"] = false,
                ["sanctuaryDonorMovementLoopRetained"] = true,
            },
            ["sourceBlueprint"] = "units/URL0208/URL0208_unit.bp",
            ["sourceBlueprintSha256"] = "eddd9987117e3cc3062b849c1de7be153cefada2581ab12404ff01a41025f807",
            ["sourceMovement"] = {
                ["independentBrakeSupported"] = false,
                ["independentReverseSupported"] = false,
                ["maxBrake"] = 1.9,
                ["maxReverseSpeed"] = 1.6,
                ["sanctuaryType"] = "TracksAmphibious",
                ["type"] = "RULEUMT_AmphibiousFloating",
            },
            ["sourceScript"] = "units/URL0208/URL0208_script.lua",
            ["sourceScriptSha256"] = "957785569c55c5cc0b992d22e55dd06f9585f3702c81e8726a4cbf9afef705a6",
            ["sourceTeleportEnergyMod"] = 0.15,
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0.6251773898894238,
                [3] = -0.29291581034752534,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "URL0208",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 73897,
                ["entry"] = "units/URL0208/URL0208_lod0.scm",
                ["sha256"] = "fd3b949d43719f203cabf7872a3fc50aa24a88221ac3a1d41980606d9df067e6",
            },
        },
        ["scoGameplayEngineerBeam"] = "1.0.0",
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/ugl2501/LOD0/ugl2501_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.28161901235580444,
                        ["y"] = -0.0003292923853444405,
                        ["z"] = 0.22778521483727895,
                    },
                    ["width"] = 0.12171,
                },
                [2] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.28161847591400146,
                        ["y"] = -0.0003292797683793706,
                        ["z"] = -0.2166569828432028,
                    },
                    ["width"] = 0.12171,
                },
                [3] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.2816980183124542,
                        ["y"] = -0.0003292430252479859,
                        ["z"] = 0.22778521483727063,
                    },
                    ["width"] = 0.12171,
                },
                [4] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.2816980481147766,
                        ["y"] = -0.0003292257516700429,
                        ["z"] = -0.21665698284321191,
                    },
                    ["width"] = 0.12171,
                },
            },
            ["unit"] = "ugl2501",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.32,
                ["z"] = -0.01,
            },
            ["size"] = {
                ["x"] = 1.1,
                ["y"] = 1.2,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aglu1420",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod1120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.32,
            ["z"] = -0.01,
        },
        ["collisionSize"] = {
            ["x"] = 0.9,
            ["y"] = 0.9,
            ["z"] = 1,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Buildpoint_Left",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.GUARD * Tags.BUILDABLE_BY_T2_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 710,
            ["regen"] = 0,
            ["value"] = 710,
        },
    },
    ["economy"] = {
        ["buildTime"] = 800,
        ["cost"] = {
            ["alloys"] = 160,
            ["energy"] = 840,
        },
        ["storage"] = {
            ["alloys"] = 20,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 1.3,
        ["y"] = 1.4,
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
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_land1_engineer.png",
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
        ["tpId"] = "ugl2501",
        ["unitTypeName"] = "GuardT2Engineer",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
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
                ["y"] = 0.4,
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
            ["outerRadius"] = 20,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
    },
    ["tags"] = {
        [1] = "AMPHIBIOUS",
        [2] = "BUILDABLE_BY_T2_FACTORY",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "CONSTRUCTION",
        [5] = "ENGINEER",
        [6] = "GUARD",
        [7] = "HARVEST",
        [8] = "LAND",
        [9] = "MOBILE",
        [10] = "TECH2",
        [11] = "ALLOYS_STORAGE",
        [12] = "SCFA_ALLUNITS",
        [13] = "SCFA_BUILTBYTIER2FACTORY",
        [14] = "SCFA_BUILTBYTIER3FACTORY",
        [15] = "SCFA_CAPTURE",
        [16] = "SCFA_CONSTRUCTION",
        [17] = "SCFA_CYBRAN",
        [18] = "SCFA_ENGINEER",
        [19] = "SCFA_LAND",
        [20] = "SCFA_MOBILE",
        [21] = "SCFA_PATROLHELPER",
        [22] = "SCFA_PRODUCTSC1",
        [23] = "SCFA_RECLAIM",
        [24] = "SCFA_RECLAIMABLE",
        [25] = "SCFA_REPAIR",
        [26] = "SCFA_SELECTABLE",
        [27] = "SCFA_SHOWQUEUE",
        [28] = "SCFA_TECH2",
        [29] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl2501/LOD0/ugl2501.sananimation",
            },
            ["waterTransform"] = {
                ["clipName"] = "AnimWater",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl2501/LOD0/ugl2501.sananimation",
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
                    ["particleName"] = "VFX/Death/vgd1201_death_land_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.545,
                    ["z"] = -0.21000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.482,
                    ["z"] = 0.16999999999999998,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18000000000000002,
                    ["y"] = 0.5720000000000001,
                    ["z"] = 0.15,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.698,
                    ["z"] = -0.21000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.68,
                    ["z"] = 0.16999999999999998,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 67,
            ["lod1distance"] = 174,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.32,
                ["z"] = -0.01,
            },
            ["size"] = {
                ["x"] = 1.1,
                ["y"] = 1.2,
            },
        },
    },
}
