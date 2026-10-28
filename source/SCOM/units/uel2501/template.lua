-- uel2501: Engineer
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Turret_Muzzle_01",
            [2] = "Turret_Muzzle_02",
        },
        ["buildBeamEffectName"] = "beam1",
        ["faEngineerWaterAnimation"] = {
            ["animationSha256"] = "af308597e2b0be3c3425d1959fc9822000d42260d79f3163aa48a45dd1d8004d",
            ["buildCloseSeconds"] = 0.4000000059604645,
            ["durationSeconds"] = 1.6666666269302368,
            ["exactTimeOwner"] = "coordinator -10000 progress-frame sentinel",
            ["limitation"] = "Sanctuary has one animation component; build-open temporarily suspends water sampling and exact phase is restored after close",
            ["mapping"] = "UEL0208 -> uel2501",
            ["mediumProbe"] = "guarded water level + root world position + terrain height with hysteresis",
            ["omittedSourceHelpers"] = {
                [1] = "Turret_Muzzle",
            },
            ["packageSha256"] = "feb5dbaa525a32f6987734620efe3f4643cb17e5a234e4518f8180b06704d11f",
            ["sourceAnimationWater"] = "units/UEL0208/UEL0208_Awheels.sca",
            ["sourceAnimationWaterSha256"] = "bf419e97d5a6e41e1a9b760105e7788fd974c19fbc35bacab9b1f0cc327becc1",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEL0208/UEL0208_unit.bp",
            ["sourceBlueprintSha256"] = "5e444a49c6a849aecab6d84b604f1957d58e148d0e5f89be56c4aed813198987",
            ["sourceFactionLifecycle"] = "lua/terranunits.lua",
            ["sourceFactionLifecycleSha256"] = "4cf1990c6320b3999bd86edb2e0bba0a543942ae58e808cb41cf05c469d35b5e",
            ["sourceFrames"] = 51,
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceRate"] = 1,
            ["sourceReverseRate"] = -1,
            ["sourceScript"] = "units/UEL0208/UEL0208_script.lua",
            ["sourceScriptSha256"] = "4c357b4d1158e39d7a8f16a5a5f65958bea5e1fa30d062d1903675d331f70357",
        },
        ["faSourceContract"] = {
            ["mapping"] = "UEL0208 -> uel2501",
            ["sanctuaryTeleportSupported"] = false,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudio"] = {
                ["ambientMoveCue"] = "UEL0208_Move_Loop",
                ["bank"] = "UEL",
                ["bankImported"] = false,
                ["sanctuaryDonorMovementLoopRetained"] = true,
            },
            ["sourceBlueprint"] = "units/UEL0208/UEL0208_unit.bp",
            ["sourceBlueprintSha256"] = "5e444a49c6a849aecab6d84b604f1957d58e148d0e5f89be56c4aed813198987",
            ["sourceMovement"] = {
                ["independentBrakeSupported"] = false,
                ["independentReverseSupported"] = false,
                ["maxBrake"] = 1.9,
                ["maxReverseSpeed"] = 1.4,
                ["sanctuaryType"] = "TracksAmphibious",
                ["type"] = "RULEUMT_AmphibiousFloating",
            },
            ["sourceScript"] = "units/UEL0208/UEL0208_script.lua",
            ["sourceScriptSha256"] = "4c357b4d1158e39d7a8f16a5a5f65958bea5e1fa30d062d1903675d331f70357",
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
                [2] = 0.5775148062500328,
                [3] = -0.03099070279750946,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UEL0208",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 110182,
                ["entry"] = "units/UEL0208/UEL0208_lod0.scm",
                ["sha256"] = "8e91ce58ba641d0313e02b1a20e9397af31e623aac5f53bd4ac5ee7cfbea4ca3",
            },
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["scoGameplayEngineerBeam"] = "1.0.0",
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/uel2501/LOD0/uel2501_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.2604798898100853,
                        ["y"] = 0.002596452819378304,
                        ["z"] = 0.18465544984675442,
                    },
                    ["width"] = 0.132,
                },
                [2] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.2570369765162468,
                        ["y"] = 0.0025961417681271324,
                        ["z"] = -0.1522628874238154,
                    },
                    ["width"] = 0.17664,
                },
                [3] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.25704001635313034,
                        ["y"] = 0.00259611569109677,
                        ["z"] = -0.15226287717926268,
                    },
                    ["width"] = 0.17664,
                },
                [4] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.26047997176647186,
                        ["y"] = 0.002596667023571722,
                        ["z"] = 0.1846554572972989,
                    },
                    ["width"] = 0.132,
                },
            },
            ["unit"] = "uel2501",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.36,
                ["z"] = 0.07,
            },
            ["size"] = {
                ["x"] = 1.1,
                ["y"] = 1.4,
            },
        },
        ["uefEngineerBuildAnimation"] = {
            ["authoredRate"] = 1,
            ["closeAnimationKey"] = "close",
            ["durationSeconds"] = 0.4000000059604645,
            ["exactTimeOwner"] = "coordinator -10000 progress-frame sentinel",
            ["openAnimationKey"] = "build",
            ["restAnimationKey"] = "walk",
            ["sourceClipRate"] = 5,
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aelu1220",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod1120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.36,
            ["z"] = 0.07,
        },
        ["collisionSize"] = {
            ["x"] = 0.9,
            ["y"] = 1,
            ["z"] = 1.2,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Turret_Muzzle_01",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.EDA * Tags.BUILDABLE_BY_T2_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 730,
            ["regen"] = 0,
            ["value"] = 730,
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
        ["y"] = 1.6,
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
        ["tpId"] = "uel2501",
        ["unitTypeName"] = "EDAT2Engineer",
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
        [5] = "EDA",
        [6] = "ENGINEER",
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
        [17] = "SCFA_ENGINEER",
        [18] = "SCFA_LAND",
        [19] = "SCFA_MOBILE",
        [20] = "SCFA_PATROLHELPER",
        [21] = "SCFA_PRODUCTSC1",
        [22] = "SCFA_RECLAIM",
        [23] = "SCFA_RECLAIMABLE",
        [24] = "SCFA_REPAIR",
        [25] = "SCFA_SELECTABLE",
        [26] = "SCFA_SHOWQUEUE",
        [27] = "SCFA_TECH2",
        [28] = "SCFA_UEF",
        [29] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimBuild",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel2501/LOD0/uel2501.sananimation",
            },
            ["close"] = {
                ["clipName"] = "AnimClose",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel2501/LOD0/uel2501.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel2501/LOD0/uel2501.sananimation",
            },
            ["waterTransform"] = {
                ["clipName"] = "AnimWater",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel2501/LOD0/uel2501.sananimation",
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
                    ["particleName"] = "VFX/Death/ved1201_death_land_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.61,
                    ["z"] = -0.16999999999999998,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.54,
                    ["z"] = 0.28600000000000003,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18000000000000002,
                    ["y"] = 0.64,
                    ["z"] = 0.262,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.78,
                    ["z"] = -0.16999999999999998,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.76,
                    ["z"] = 0.28600000000000003,
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
                ["y"] = 0.36,
                ["z"] = 0.07,
            },
            ["size"] = {
                ["x"] = 1.1,
                ["y"] = 1.4,
            },
        },
    },
}
