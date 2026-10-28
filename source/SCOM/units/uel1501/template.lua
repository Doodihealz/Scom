-- uel1501: Engineer
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Turret_Muzzle",
        },
        ["buildBeamEffectName"] = "beam1",
        ["faEngineerWaterAnimation"] = {
            ["animationSha256"] = "7e943b71a35220443810ee99ab27ec67c3523dd03e9694e452c8e4c9d4cc817e",
            ["buildCloseSeconds"] = 0.3333333134651184,
            ["durationSeconds"] = 1.6666666269302368,
            ["exactTimeOwner"] = "coordinator -10000 progress-frame sentinel",
            ["limitation"] = "Sanctuary has one animation component; build-open temporarily suspends water sampling and exact phase is restored after close",
            ["mapping"] = "UEL0105 -> uel1501",
            ["mediumProbe"] = "guarded water level + root world position + terrain height with hysteresis",
            ["omittedSourceHelpers"] = {},
            ["packageSha256"] = "feb5dbaa525a32f6987734620efe3f4643cb17e5a234e4518f8180b06704d11f",
            ["sourceAnimationWater"] = "units/UEL0105/UEL0105_Awheels.sca",
            ["sourceAnimationWaterSha256"] = "0970abfd894ab503582c65451f170472b512845324f0e670331518883d72a02b",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEL0105/UEL0105_unit.bp",
            ["sourceBlueprintSha256"] = "94daaf4535afafd99543deeb799b13c84f4a17312b6c9dab89ba954486deae2b",
            ["sourceFactionLifecycle"] = "lua/terranunits.lua",
            ["sourceFactionLifecycleSha256"] = "4cf1990c6320b3999bd86edb2e0bba0a543942ae58e808cb41cf05c469d35b5e",
            ["sourceFrames"] = 51,
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceRate"] = 1,
            ["sourceReverseRate"] = -1,
            ["sourceScript"] = "units/UEL0105/UEL0105_script.lua",
            ["sourceScriptSha256"] = "c45d1e9b621eb5679e9ea6bf07c18bed5b655dbf8ea360efd97c773beb67b35c",
        },
        ["faSourceContract"] = {
            ["mapping"] = "UEL0105 -> uel1501",
            ["sanctuaryTeleportSupported"] = false,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudio"] = {
                ["ambientMoveCue"] = "UEL0105_Move_Loop",
                ["bank"] = "UEL",
                ["bankImported"] = false,
                ["sanctuaryDonorMovementLoopRetained"] = true,
            },
            ["sourceBlueprint"] = "units/UEL0105/UEL0105_unit.bp",
            ["sourceBlueprintSha256"] = "94daaf4535afafd99543deeb799b13c84f4a17312b6c9dab89ba954486deae2b",
            ["sourceMovement"] = {
                ["independentBrakeSupported"] = false,
                ["independentReverseSupported"] = false,
                ["maxBrake"] = 1.9,
                ["maxReverseSpeed"] = 1.5,
                ["sanctuaryType"] = "TracksAmphibious",
                ["type"] = "RULEUMT_AmphibiousFloating",
            },
            ["sourceScript"] = "units/UEL0105/UEL0105_script.lua",
            ["sourceScriptSha256"] = "c45d1e9b621eb5679e9ea6bf07c18bed5b655dbf8ea360efd97c773beb67b35c",
            ["sourceTeleportEnergyMod"] = 0.15,
        },
        ["multiConstructionBeam"] = {
            ["materialPath"] = "VFX/SCOM/ConstructionBeams/uef.sanmaterial",
            ["prefabName"] = "SCOM.EDAUefEngineerBeam",
            ["shrink"] = 0.05,
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0.390019572495045,
                [3] = -0.08908732683314449,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UEL0105",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 65703,
                ["entry"] = "units/UEL0105/UEL0105_LOD0.scm",
                ["sha256"] = "ab7d1a6cac33529834d9c130d6ff2ba789434cb013579c750d1378ff5e7d9fb6",
            },
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["scoGameplayEngineerBeam"] = "1.0.0",
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/uel1501/LOD0/uel1501_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.20812498778104782,
                        ["y"] = 0.00012458979647121123,
                        ["z"] = -0.0634445175738578,
                    },
                    ["width"] = 0.124639,
                },
                [2] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.20810670405626297,
                        ["y"] = 0.00012459352176025362,
                        ["z"] = -0.06344452502443902,
                    },
                    ["width"] = 0.124639,
                },
            },
            ["unit"] = "uel1501",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.28,
                ["z"] = 0.03,
            },
            ["size"] = {
                ["x"] = 1,
                ["y"] = 1.2,
            },
        },
        ["uefEngineerBuildAnimation"] = {
            ["authoredRate"] = 1,
            ["closeAnimationKey"] = "close",
            ["durationSeconds"] = 0.3333333134651184,
            ["exactTimeOwner"] = "coordinator -10000 progress-frame sentinel",
            ["openAnimationKey"] = "build",
            ["restAnimationKey"] = "walk",
            ["sourceClipRate"] = 5,
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aelu1210",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod1110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.28,
            ["z"] = 0.03,
        },
        ["collisionSize"] = {
            ["x"] = 0.8,
            ["y"] = 0.8,
            ["z"] = 1,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Turret_Muzzle",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 5,
        ["canBuild"] = "(Tags.EDA * Tags.BUILDABLE_BY_T1_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 150,
            ["regen"] = 0,
            ["value"] = 150,
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
        ["y"] = 1.4,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAUefEngineer",
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
        ["tpId"] = "uel1501",
        ["unitTypeName"] = "EDAT1Engineer",
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
        [6] = "EDA",
        [7] = "ENGINEER",
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
        [19] = "SCFA_ENGINEER",
        [20] = "SCFA_LAND",
        [21] = "SCFA_MOBILE",
        [22] = "SCFA_PATROLHELPER",
        [23] = "SCFA_PRODUCTSC1",
        [24] = "SCFA_RECLAIM",
        [25] = "SCFA_RECLAIMABLE",
        [26] = "SCFA_REPAIR",
        [27] = "SCFA_SELECTABLE",
        [28] = "SCFA_SHOWQUEUE",
        [29] = "SCFA_TECH1",
        [30] = "SCFA_UEF",
        [31] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimBuild",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel1501/LOD0/uel1501.sananimation",
            },
            ["close"] = {
                ["clipName"] = "AnimClose",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel1501/LOD0/uel1501.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel1501/LOD0/uel1501.sananimation",
            },
            ["waterTransform"] = {
                ["clipName"] = "AnimWater",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel1501/LOD0/uel1501.sananimation",
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
                    ["particleName"] = "VFX/Death/ved1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.48000000000000004,
                    ["z"] = -0.17,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.42400000000000004,
                    ["z"] = 0.21,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.16000000000000003,
                    ["y"] = 0.504,
                    ["z"] = 0.19,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.6160000000000001,
                    ["z"] = -0.17,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.6000000000000001,
                    ["z"] = 0.21,
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
                ["y"] = 0.28,
                ["z"] = 0.03,
            },
            ["size"] = {
                ["x"] = 1,
                ["y"] = 1.2,
            },
        },
    },
}
