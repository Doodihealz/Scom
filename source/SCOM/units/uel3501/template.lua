-- uel3501: Engineer
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Turret_Muzzle01",
            [2] = "Turret_Muzzle02",
            [3] = "Turret_Muzzle03",
        },
        ["buildBeamEffectName"] = "beam1",
        ["faEngineerWaterAnimation"] = {
            ["animationSha256"] = "56b61afc4ecf1dc2edc7b4fbf8ec34a4deaa7df7643f4ac67caf6ef4a7a322f4",
            ["buildCloseSeconds"] = 0.4000000059604645,
            ["durationSeconds"] = 1.6666666269302368,
            ["exactTimeOwner"] = "coordinator -10000 progress-frame sentinel",
            ["limitation"] = "Sanctuary has one animation component; build-open temporarily suspends water sampling and exact phase is restored after close",
            ["mapping"] = "UEL0309 -> uel3501",
            ["mediumProbe"] = "guarded water level + root world position + terrain height with hysteresis",
            ["omittedSourceHelpers"] = {
                [1] = "Turret_Barrel_Muzzle",
                [2] = "Turret_Barrel_Muzzle01",
            },
            ["packageSha256"] = "feb5dbaa525a32f6987734620efe3f4643cb17e5a234e4518f8180b06704d11f",
            ["sourceAnimationWater"] = "units/UEL0309/UEL0309_Awheels.sca",
            ["sourceAnimationWaterSha256"] = "d651793a5b43601a38695f17551e2c925fe12657e7f38717afc13f253f71a687",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEL0309/UEL0309_unit.bp",
            ["sourceBlueprintSha256"] = "7710ec8ac0c9c3157c516d24b7a91acc26914090870217aa8e80da46ad862ccb",
            ["sourceFactionLifecycle"] = "lua/terranunits.lua",
            ["sourceFactionLifecycleSha256"] = "4cf1990c6320b3999bd86edb2e0bba0a543942ae58e808cb41cf05c469d35b5e",
            ["sourceFrames"] = 51,
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceRate"] = 1,
            ["sourceReverseRate"] = -1,
            ["sourceScript"] = "units/UEL0309/UEL0309_script.lua",
            ["sourceScriptSha256"] = "a84606264cf517151137026c6e12a8c47d2c19a36e02876b1f4a1ed77909ba49",
        },
        ["faSourceContract"] = {
            ["mapping"] = "UEL0309 -> uel3501",
            ["sanctuaryTeleportSupported"] = false,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceAudio"] = {
                ["ambientMoveCue"] = "UEL0309_Move_Loop",
                ["bank"] = "UEL",
                ["bankImported"] = false,
                ["sanctuaryDonorMovementLoopRetained"] = true,
            },
            ["sourceBlueprint"] = "units/UEL0309/UEL0309_unit.bp",
            ["sourceBlueprintSha256"] = "7710ec8ac0c9c3157c516d24b7a91acc26914090870217aa8e80da46ad862ccb",
            ["sourceMovement"] = {
                ["independentBrakeSupported"] = false,
                ["independentReverseSupported"] = false,
                ["maxBrake"] = 1.9,
                ["maxReverseSpeed"] = 1.4,
                ["sanctuaryType"] = "TracksAmphibious",
                ["type"] = "RULEUMT_AmphibiousFloating",
            },
            ["sourceScript"] = "units/UEL0309/UEL0309_script.lua",
            ["sourceScriptSha256"] = "a84606264cf517151137026c6e12a8c47d2c19a36e02876b1f4a1ed77909ba49",
            ["sourceTeleportEnergyMod"] = 0.15,
        },
        ["multiConstructionBeam"] = {
            ["materialPath"] = "VFX/SCOM/ConstructionBeams/uef.sanmaterial",
            ["prefabName"] = "SCOM.EDAUefEngineerBeam",
            ["shrink"] = 0.05,
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -2.9802322387695314e-09,
                [2] = 0.7528169334193845,
                [3] = -0.04965113693453644,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 3,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UEL0309",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 112966,
                ["entry"] = "units/UEL0309/UEL0309_lod0.scm",
                ["sha256"] = "a3ec73daa88880161edb9ad51945867b29a60cfdda61fe0f25fa21c9a784b41a",
            },
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["scoGameplayEngineerBeam"] = "1.0.0",
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/uel3501/LOD0/uel3501_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.3255999982357025,
                        ["y"] = 0.003245400746313835,
                        ["z"] = 0.31906510834817264,
                    },
                    ["width"] = 0.165,
                },
                [2] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.32559995353221893,
                        ["y"] = 0.0032453836992358703,
                        ["z"] = 0.08536544573728375,
                    },
                    ["width"] = 0.165,
                },
                [3] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.3212961480021477,
                        ["y"] = 0.0032453115189134416,
                        ["z"] = -0.33173378611679116,
                    },
                    ["width"] = 0.2208,
                },
                [4] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.3212999999523163,
                        ["y"] = 0.003245239807075196,
                        ["z"] = -0.33173378611677906,
                    },
                    ["width"] = 0.2208,
                },
                [5] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.32559995353221893,
                        ["y"] = 0.0032453948751177564,
                        ["z"] = 0.08536551092986208,
                    },
                    ["width"] = 0.165,
                },
                [6] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.32559995353221893,
                        ["y"] = 0.0032454603509661467,
                        ["z"] = 0.3190651530516462,
                    },
                    ["width"] = 0.165,
                },
            },
            ["unit"] = "uel3501",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.47,
                ["z"] = 0.04,
            },
            ["size"] = {
                ["x"] = 1.3,
                ["y"] = 1.8,
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
            ["name"] = "aelu1230",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod1130",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.47,
            ["z"] = 0.04,
        },
        ["collisionSize"] = {
            ["x"] = 1.1,
            ["y"] = 1.2,
            ["z"] = 1.6,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Turret_Muzzle02",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 15,
        ["canBuild"] = "(Tags.EDA * Tags.BUILDABLE_BY_T3_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1500,
            ["regen"] = 0,
            ["value"] = 1500,
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
        ["y"] = 2,
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
        ["tpId"] = "uel3501",
        ["unitTypeName"] = "EDAT3Engineer",
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
        [4] = "EDA",
        [5] = "ENGINEER",
        [6] = "HARVEST",
        [7] = "LAND",
        [8] = "MOBILE",
        [9] = "TECH3",
        [10] = "ALLOYS_STORAGE",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYTIER3FACTORY",
        [13] = "SCFA_CAPTURE",
        [14] = "SCFA_CONSTRUCTION",
        [15] = "SCFA_ENGINEER",
        [16] = "SCFA_LAND",
        [17] = "SCFA_MOBILE",
        [18] = "SCFA_PATROLHELPER",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RECLAIM",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_REPAIR",
        [23] = "SCFA_SELECTABLE",
        [24] = "SCFA_SHOWQUEUE",
        [25] = "SCFA_TECH3",
        [26] = "SCFA_UEF",
        [27] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimBuild",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel3501/LOD0/uel3501.sananimation",
            },
            ["close"] = {
                ["clipName"] = "AnimClose",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel3501/LOD0/uel3501.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel3501/LOD0/uel3501.sananimation",
            },
            ["waterTransform"] = {
                ["clipName"] = "AnimWater",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel3501/LOD0/uel3501.sananimation",
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
                    ["particleName"] = "VFX/Death/ved1301_death_land_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.198,
                    ["y"] = 0.77,
                    ["z"] = -0.2800000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.24200000000000002,
                    ["y"] = 0.6859999999999999,
                    ["z"] = 0.32799999999999996,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.22000000000000003,
                    ["y"] = 0.806,
                    ["z"] = 0.296,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.198,
                    ["y"] = 0.974,
                    ["z"] = -0.2800000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.24200000000000002,
                    ["y"] = 0.95,
                    ["z"] = 0.32799999999999996,
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
                ["y"] = 0.47,
                ["z"] = 0.04,
            },
            ["size"] = {
                ["x"] = 1.3,
                ["y"] = 1.8,
            },
        },
    },
}
