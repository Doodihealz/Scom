-- ugn3003: Tier 3: Command Class
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["minimumWaterDepth"] = 0,
            ["sourceBlueprintSha256"] = "FD213C8521821F9ED04E5A6CE200A4FAE7EBA697EA93FDE45F35918AE67E37FD",
            ["sourceId"] = "URS0303",
            ["sourceMinimumWaterDepth"] = 0,
            ["sourceUniformScale"] = 0.1,
            ["targetId"] = "ugn3003",
            ["textureResolution"] = 2048,
        },
        ["scoCargo"] = {
            ["airStorage"] = true,
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0,
                [3] = 0,
            },
            ["canFire"] = false,
            ["cargoClass"] = 10,
            ["portable"] = false,
            ["slots"] = {
                [1] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 1,
                    },
                },
                [2] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 2,
                    },
                },
                [3] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 3,
                    },
                },
                [4] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 4,
                    },
                },
                [5] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 5,
                    },
                },
                [6] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 6,
                    },
                },
                [7] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 7,
                    },
                },
                [8] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 8,
                    },
                },
                [9] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 9,
                    },
                },
                [10] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 10,
                    },
                },
                [11] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 11,
                    },
                },
                [12] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 12,
                    },
                },
                [13] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 13,
                    },
                },
                [14] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 14,
                    },
                },
                [15] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 15,
                    },
                },
                [16] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 16,
                    },
                },
                [17] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 17,
                    },
                },
                [18] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 18,
                    },
                },
                [19] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 19,
                    },
                },
                [20] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 20,
                    },
                },
                [21] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 21,
                    },
                },
                [22] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 22,
                    },
                },
                [23] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 23,
                    },
                },
                [24] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 24,
                    },
                },
                [25] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 25,
                    },
                },
                [26] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 26,
                    },
                },
                [27] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 27,
                    },
                },
                [28] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 28,
                    },
                },
                [29] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 29,
                    },
                },
                [30] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 30,
                    },
                },
                [31] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 31,
                    },
                },
                [32] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 32,
                    },
                },
                [33] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 33,
                    },
                },
                [34] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 34,
                    },
                },
                [35] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 35,
                    },
                },
                [36] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 36,
                    },
                },
                [37] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 37,
                    },
                },
                [38] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 38,
                    },
                },
                [39] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 39,
                    },
                },
                [40] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 40,
                    },
                },
                [41] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 41,
                    },
                },
                [42] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 42,
                    },
                },
                [43] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 43,
                    },
                },
                [44] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 44,
                    },
                },
                [45] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 45,
                    },
                },
                [46] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 46,
                    },
                },
                [47] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 47,
                    },
                },
                [48] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 48,
                    },
                },
                [49] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 49,
                    },
                },
                [50] = {
                    ["bone"] = "Root",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 50,
                    },
                },
            },
        },
        ["scoIdleResetLocomotion"] = true,
        ["scoSourceDeath"] = {
            ["hasMovement"] = true,
            ["sourceId"] = "URS0303",
            ["variants"] = {
                [1] = {
                    ["durationSeconds"] = 23.33333396911621,
                    ["key"] = "scoSourceDeath01",
                    ["rateMax"] = 1.5,
                    ["rateMin"] = 0.9,
                    ["weight"] = 100,
                },
                [2] = {
                    ["durationSeconds"] = 33.33333206176758,
                    ["key"] = "scoSourceDeath02",
                    ["rateMax"] = 1.5,
                    ["rateMin"] = 0.9,
                    ["weight"] = 100,
                },
                [3] = {
                    ["durationSeconds"] = 33.33333206176758,
                    ["key"] = "scoSourceDeath03",
                    ["rateMax"] = 1.5,
                    ["rateMin"] = 0.9,
                    ["weight"] = 100,
                },
            },
        },
        ["scoSourceInterception"] = {
            ["sourceId"] = "URS0303",
            ["weapons"] = {
                ["Zapper"] = {
                    ["beam"] = {
                        ["collisionDelay"] = 0.1,
                        ["lifetime"] = 0.1,
                    },
                    ["counted"] = false,
                    ["damage"] = 1,
                    ["interval"] = 0.5,
                    ["muzzleVelocity"] = 0,
                    ["muzzles"] = {
                        [1] = "Zapper_Muzzle",
                    },
                    ["projectile"] = "pbf0005",
                    ["rangeMax"] = 50,
                    ["rangeMin"] = 0,
                    ["reload"] = 2,
                    ["sourceIndex"] = 5,
                    ["sourceLabel"] = "Zapper",
                    ["targetClass"] = "tactical",
                },
            },
        },
        ["scoSourceSurfaceCarrier"] = 1,
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "URS0303",
            ["targetId"] = "ugn3003",
        },
        ["seaParityUnsupported"] = {},
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.475,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2,
                ["y"] = 10,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.475,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 3.3,
            ["y"] = 1.7,
            ["z"] = 15.5,
        },
    },
    ["construction"] = {
        ["buildPower"] = 150,
        ["canBuild"] = "(Tags.SCFA_BUILTBYTIER3FACTORY * Tags.SCFA_CYBRAN * Tags.SCFA_MOBILE * Tags.SCFA_AIR * (Tags.SCFA_ANTINAVY + Tags.SCFA_INTELLIGENCE + Tags.SCFA_ANTIAIR)) * Tags.SCFA_ALLUNITS",
        ["range"] = 30,
        ["rollOffPoints"] = {
            [1] = {
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["platformOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["rollOffTime"] = 0,
                ["unitSpin"] = 0,
            },
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 20000,
            ["regen"] = 0,
            ["value"] = 20000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 10800,
        ["cost"] = {
            ["alloys"] = 3600,
            ["energy"] = 36000,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 17,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardNavalUnit",
        },
        ["displayName"] = "Tier 3: Command Class",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Command Class",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
            ["Transport"] = true,
        },
        ["toggles"] = {
            ["RepeatBuild"] = false,
        },
        ["tpId"] = "ugn3003",
    },
    ["intel"] = {
        ["radarRadius"] = 200,
        ["sonarRadius"] = 40,
        ["visionRadius"] = 85,
    },
    ["movement"] = {
        ["acceleration"] = 3,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 2.5,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 30,
        ["sortOrder"] = 5,
        ["speed"] = 3,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 200,
        },
        [3] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 40,
        },
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 75,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 85,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 85,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_FACTORY",
        [2] = "GUARD",
        [3] = "MOBILE",
        [4] = "NAVAL",
        [5] = "CARRIER",
        [6] = "TECH3",
        [7] = "ANTI_AIR",
        [8] = "SCFA_AIRSTAGINGPLATFORM",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_ANTIAIR",
        [11] = "SCFA_ANTIMISSILE",
        [12] = "SCFA_BUILTBYTIER3FACTORY",
        [13] = "SCFA_CARRIER",
        [14] = "SCFA_CYBRAN",
        [15] = "SCFA_FACTORY",
        [16] = "SCFA_INTELLIGENCE",
        [17] = "SCFA_MOBILE",
        [18] = "SCFA_NAVAL",
        [19] = "SCFA_NAVALCARRIER",
        [20] = "SCFA_OVERLAYANTIAIR",
        [21] = "SCFA_OVERLAYDEFENSE",
        [22] = "SCFA_OVERLAYMISC",
        [23] = "SCFA_OVERLAYRADAR",
        [24] = "SCFA_OVERLAYSONAR",
        [25] = "SCFA_PRODUCTSC1",
        [26] = "SCFA_RECLAIMABLE",
        [27] = "SCFA_REPAIR",
        [28] = "SCFA_SELECTABLE",
        [29] = "SCFA_SHOWQUEUE",
        [30] = "SCFA_TECH3",
        [31] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["scoSourceDeath01"] = {
                ["clipName"] = "AnimAsink01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn3003/LOD0/ugn3003.sananimation",
            },
            ["scoSourceDeath02"] = {
                ["clipName"] = "AnimAsink02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn3003/LOD0/ugn3003.sananimation",
            },
            ["scoSourceDeath03"] = {
                ["clipName"] = "AnimAsink03",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn3003/LOD0/ugn3003.sananimation",
            },
            ["source_animasink01_1"] = {
                ["clipName"] = "AnimAsink01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn3003/LOD0/ugn3003.sananimation",
            },
            ["source_animasink02_2"] = {
                ["clipName"] = "AnimAsink02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn3003/LOD0/ugn3003.sananimation",
            },
            ["source_animasink03_3"] = {
                ["clipName"] = "AnimAsink03",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn3003/LOD0/ugn3003.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn3003/LOD0/ugn3003.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
            },
            ["mainBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 20,
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
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.594,
                    ["y"] = 0.8999999999999999,
                    ["z"] = -3.1,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.726,
                    ["y"] = 0.7809999999999999,
                    ["z"] = 2.79,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.66,
                    ["y"] = 0.9510000000000001,
                    ["z"] = 2.48,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.594,
                    ["y"] = 1.189,
                    ["z"] = -3.1,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.726,
                    ["y"] = 1.155,
                    ["z"] = 2.79,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 150,
            ["lod1distance"] = 390,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.475,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2,
                ["y"] = 10,
            },
            ["thickness"] = 0.18,
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Front_Right_AA_Muzzle_01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.1,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Front_Right_AA_Turret_Barrel",
                    ["pitchMax"] = 60,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 90,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Front_Right_AA_Turret",
                    ["yawMax"] = 130,
                    ["yawMin"] = -130,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 10,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn3003/muzzle_aagun01.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Front_Right_AA_Muzzle_01",
                        [2] = "Front_Right_AA_Muzzle_02",
                        [3] = "Front_Right_AA_Muzzle_03",
                        [4] = "Front_Right_AA_Muzzle_04",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Front_Right_AA_Muzzle_01"] = {
                    ["aimController"] = "Front_Right_AA_Muzzle_01",
                },
                ["Front_Right_AA_Muzzle_02"] = {
                    ["aimController"] = "Front_Right_AA_Muzzle_01",
                },
                ["Front_Right_AA_Muzzle_03"] = {
                    ["aimController"] = "Front_Right_AA_Muzzle_01",
                },
                ["Front_Right_AA_Muzzle_04"] = {
                    ["aimController"] = "Front_Right_AA_Muzzle_01",
                },
            },
            ["name"] = "AAGun01",
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0004",
            ["rangeMax"] = 75,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "0460b42285f54f1b3cd041b431805ab8a0d54c1d6246c0ba26d6980156f19152",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun01",
                ["sourceProjectile"] = "/projectiles/CAAAutocannon01/CAAAutocannon01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun01",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Back_Right_AA_Muzzle_01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.1,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Back_Right_AA_Turret_Barrel",
                    ["pitchMax"] = 60,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 90,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Back_Right_AA_Turret",
                    ["yawMax"] = 130,
                    ["yawMin"] = -130,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 10,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn3003/muzzle_aagun02.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Back_Right_AA_Muzzle_01",
                        [2] = "Back_Right_AA_Muzzle_02",
                        [3] = "Back_Right_AA_Muzzle_03",
                        [4] = "Back_Right_AA_Muzzle_04",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Back_Right_AA_Muzzle_01"] = {
                    ["aimController"] = "Back_Right_AA_Muzzle_01",
                },
                ["Back_Right_AA_Muzzle_02"] = {
                    ["aimController"] = "Back_Right_AA_Muzzle_01",
                },
                ["Back_Right_AA_Muzzle_03"] = {
                    ["aimController"] = "Back_Right_AA_Muzzle_01",
                },
                ["Back_Right_AA_Muzzle_04"] = {
                    ["aimController"] = "Back_Right_AA_Muzzle_01",
                },
            },
            ["name"] = "AAGun02",
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0004",
            ["rangeMax"] = 75,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "0460b42285f54f1b3cd041b431805ab8a0d54c1d6246c0ba26d6980156f19152",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AAGun02",
                ["sourceProjectile"] = "/projectiles/CAAAutocannon01/CAAAutocannon01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AAGun02",
            },
            ["targetWaterLimits"] = "Above",
        },
        [3] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Back_Left_AA_Muzzle_01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.1,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Back_Left_AA_Turret_Barrel",
                    ["pitchMax"] = 60,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 90,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Back_Left_AA_Turret",
                    ["yawMax"] = 130,
                    ["yawMin"] = -130,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 10,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn3003/muzzle_aagun03.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Back_Left_AA_Muzzle_01",
                        [2] = "Back_Left_AA_Muzzle_02",
                        [3] = "Back_Left_AA_Muzzle_03",
                        [4] = "Back_Left_AA_Muzzle_04",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Back_Left_AA_Muzzle_01"] = {
                    ["aimController"] = "Back_Left_AA_Muzzle_01",
                },
                ["Back_Left_AA_Muzzle_02"] = {
                    ["aimController"] = "Back_Left_AA_Muzzle_01",
                },
                ["Back_Left_AA_Muzzle_03"] = {
                    ["aimController"] = "Back_Left_AA_Muzzle_01",
                },
                ["Back_Left_AA_Muzzle_04"] = {
                    ["aimController"] = "Back_Left_AA_Muzzle_01",
                },
            },
            ["name"] = "AAGun03",
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0004",
            ["rangeMax"] = 75,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "0460b42285f54f1b3cd041b431805ab8a0d54c1d6246c0ba26d6980156f19152",
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "AAGun03",
                ["sourceProjectile"] = "/projectiles/CAAAutocannon01/CAAAutocannon01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "AAGun03",
            },
            ["targetWaterLimits"] = "Above",
        },
        [4] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Front_Left_AA_Muzzle_01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.1,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Front_Left_AA_Turret_Barrel",
                    ["pitchMax"] = 60,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 90,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Front_Left_AA_Turret",
                    ["yawMax"] = 130,
                    ["yawMin"] = -130,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 10,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn3003/muzzle_aagun04.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Front_Left_AA_Muzzle_01",
                        [2] = "Front_Left_AA_Muzzle_02",
                        [3] = "Front_Left_AA_Muzzle_03",
                        [4] = "Front_Left_AA_Muzzle_04",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Front_Left_AA_Muzzle_01"] = {
                    ["aimController"] = "Front_Left_AA_Muzzle_01",
                },
                ["Front_Left_AA_Muzzle_02"] = {
                    ["aimController"] = "Front_Left_AA_Muzzle_01",
                },
                ["Front_Left_AA_Muzzle_03"] = {
                    ["aimController"] = "Front_Left_AA_Muzzle_01",
                },
                ["Front_Left_AA_Muzzle_04"] = {
                    ["aimController"] = "Front_Left_AA_Muzzle_01",
                },
            },
            ["name"] = "AAGun04",
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0004",
            ["rangeMax"] = 75,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "0460b42285f54f1b3cd041b431805ab8a0d54c1d6246c0ba26d6980156f19152",
                ["sourceIndex"] = 4,
                ["sourceLabel"] = "AAGun04",
                ["sourceProjectile"] = "/projectiles/CAAAutocannon01/CAAAutocannon01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 4,
                ["sourceLabel"] = "AAGun04",
            },
            ["targetWaterLimits"] = "Above",
        },
        [5] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Zapper_Muzzle",
                    ["aimTolerance"] = 5,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Zapper_Muzzle",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 180,
                    ["projectileSpeed"] = 25,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Zapper_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 720,
                },
            },
            ["beam"] = {
                ["cullDistance"] = 400,
                ["fadeInTime"] = 0,
                ["fadeOutTime"] = 0.01,
                ["renderLifetime"] = 0.1,
                ["subMesh"] = {
                    [1] = {
                        ["material"] = "VFX/SCOM/Source/Beams/bfa_zapper_0.sanmaterial",
                        ["model"] = "VFX/SCOM/Source/Beams/bfa_zapper_0.sanmodel",
                    },
                },
            },
            ["beamLifetime"] = 1,
            ["collideFriendly"] = false,
            ["damage"] = 1,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn3003/muzzle_zapper.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Zapper_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Zapper_Muzzle"] = {
                    ["aimController"] = "Zapper_Muzzle",
                },
            },
            ["name"] = "Zapper",
            ["projectileTemplate"] = "pbf0005",
            ["rangeMax"] = 50,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.25,
            ["reloadTime"] = 2,
            ["scoFaMissingWeapon"] = {
                ["sourceBlueprintSha256"] = "fd213c8521821f9ed04e5a6ce200a4fae7eba697ea93fde45f35918ae67e37fd",
                ["sourceId"] = "URS0303",
                ["sourceIndex"] = 5,
                ["sourceLabel"] = "Zapper",
            },
            ["scoFaSourceWeapon"] = {
                ["Audio"] = {
                    ["Fire"] = {
                        ["Bank"] = "URSWeapon",
                        ["Cue"] = "URS0303_Anti_Missile",
                        ["LodCutoff"] = "Weapon_LodCutoff",
                    },
                },
                ["BallisticArc"] = "RULEUBA_None",
                ["BeamCollisionDelay"] = 0.1,
                ["BeamLifetime"] = 0.1,
                ["CollideFriendly"] = false,
                ["Damage"] = 1,
                ["DamageType"] = "Normal",
                ["DisplayName"] = "Zapper Anti Missile",
                ["FireTargetLayerCapsTable"] = {
                    ["Water"] = "Air",
                },
                ["FiringTolerance"] = 5,
                ["Label"] = "Zapper",
                ["MaxRadius"] = 50,
                ["MuzzleSalvoDelay"] = 0,
                ["MuzzleSalvoSize"] = 1,
                ["NeedPrep"] = true,
                ["RackBones"] = {
                    [1] = {
                        ["MuzzleBones"] = {
                            [1] = "Zapper_Muzzle",
                        },
                        ["RackBone"] = "Zapper_Turret",
                    },
                },
                ["RackFireTogether"] = false,
                ["RackRecoilDistance"] = 0,
                ["RackReloadTimeout"] = 10,
                ["RackSalvoChargeTime"] = 0,
                ["RackSalvoReloadTime"] = 0,
                ["RackSalvoSize"] = 1,
                ["RackSlavedToTurret"] = false,
                ["RangeCategory"] = "UWRC_Countermeasure",
                ["RateOfFire"] = 0.5,
                ["TargetCheckInterval"] = 0.5,
                ["TargetRestrictDisallow"] = "UNTARGETABLE,STRATEGIC",
                ["TargetRestrictOnlyAllow"] = "TACTICAL,MISSILE",
                ["TargetType"] = "RULEWTT_Projectile",
                ["TrackingRadius"] = 1.5,
                ["TurretBoneMuzzle"] = "Zapper_Turret",
                ["TurretBonePitch"] = "Zapper_Muzzle",
                ["TurretBoneYaw"] = "Zapper_Turret",
                ["TurretDualManipulators"] = false,
                ["TurretPitch"] = 0,
                ["TurretPitchRange"] = 90,
                ["TurretPitchSpeed"] = 180,
                ["TurretYaw"] = 0,
                ["TurretYawRange"] = 180,
                ["TurretYawSpeed"] = 720,
                ["Turreted"] = true,
                ["WeaponCategory"] = "Defense",
            },
            ["scoFaSourceWeaponIndex"] = 5,
            ["scoSourceInterceptionLabel"] = "Zapper",
            ["scoTacticalBeam"] = true,
            ["scoTacticalOwned"] = true,
        },
    },
}
