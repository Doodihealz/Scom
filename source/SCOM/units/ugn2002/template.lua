-- ugn2002: Tier 2: Siren Class
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["minimumWaterDepth"] = 0,
            ["sourceBlueprintSha256"] = "F56250399950F9C11002312D1FD471F0D57C0F65AAC18FE30E4C430BF6D6F5F4",
            ["sourceId"] = "URS0202",
            ["sourceMinimumWaterDepth"] = 0,
            ["sourceUniformScale"] = 0.0775,
            ["targetId"] = "ugn2002",
            ["textureResolution"] = 2048,
        },
        ["scoIdleResetLocomotion"] = true,
        ["scoSourceDeath"] = {
            ["hasMovement"] = true,
            ["sourceId"] = "URS0202",
            ["variants"] = {
                [1] = {
                    ["durationSeconds"] = 21.66666603088379,
                    ["key"] = "scoSourceDeath01",
                    ["rateMax"] = 1.2,
                    ["rateMin"] = 0.8,
                    ["weight"] = 100,
                },
                [2] = {
                    ["durationSeconds"] = 21.66666603088379,
                    ["key"] = "scoSourceDeath02",
                    ["rateMax"] = 1.2,
                    ["rateMin"] = 0.8,
                    ["weight"] = 100,
                },
                [3] = {
                    ["durationSeconds"] = 34,
                    ["key"] = "scoSourceDeath03",
                    ["rateMax"] = 1.2,
                    ["rateMin"] = 0.8,
                    ["weight"] = 100,
                },
            },
        },
        ["scoSourceInterception"] = {
            ["sourceId"] = "URS0202",
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
                    ["sourceIndex"] = 3,
                    ["sourceLabel"] = "Zapper",
                    ["targetClass"] = "tactical",
                },
            },
        },
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "URS0202",
            ["targetId"] = "ugn2002",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.46,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1,
                ["y"] = 4.2,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.46,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.6,
            ["y"] = 1.5,
            ["z"] = 6.2,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 3000,
            ["regen"] = 0,
            ["value"] = 3000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 8000,
        ["cost"] = {
            ["alloys"] = 2000,
            ["energy"] = 18000,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 9,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardNavalUnit",
        },
        ["displayName"] = "Tier 2: Siren Class",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Siren Class",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ugn2002",
    },
    ["intel"] = {
        ["radarRadius"] = 150,
        ["sonarRadius"] = 120,
        ["visionRadius"] = 65,
    },
    ["movement"] = {
        ["acceleration"] = 4.5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 4.5,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 40,
        ["sortOrder"] = 5,
        ["speed"] = 4.5,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 150,
        },
        [3] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 120,
        },
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 80,
        },
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 75,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 65,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 65,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_FACTORY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "GUARD",
        [4] = "MOBILE",
        [5] = "NAVAL",
        [6] = "CRUISER",
        [7] = "TECH2",
        [8] = "ANTI_AIR",
        [9] = "ANTI_SURFACE",
        [10] = "DIRECT_FIRE",
        [11] = "SCFA_AIRSTAGINGPLATFORM",
        [12] = "SCFA_ALLUNITS",
        [13] = "SCFA_ANTIAIR",
        [14] = "SCFA_ANTIMISSILE",
        [15] = "SCFA_BUILTBYTIER2FACTORY",
        [16] = "SCFA_BUILTBYTIER3FACTORY",
        [17] = "SCFA_CRUISER",
        [18] = "SCFA_CYBRAN",
        [19] = "SCFA_DIRECTFIRE",
        [20] = "SCFA_MOBILE",
        [21] = "SCFA_NAVAL",
        [22] = "SCFA_OVERLAYANTIAIR",
        [23] = "SCFA_OVERLAYDEFENSE",
        [24] = "SCFA_OVERLAYDIRECTFIRE",
        [25] = "SCFA_OVERLAYMISC",
        [26] = "SCFA_OVERLAYRADAR",
        [27] = "SCFA_OVERLAYSONAR",
        [28] = "SCFA_PRODUCTSC1",
        [29] = "SCFA_RECLAIMABLE",
        [30] = "SCFA_REPAIR",
        [31] = "SCFA_SELECTABLE",
        [32] = "SCFA_TECH2",
        [33] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["scoSourceDeath01"] = {
                ["clipName"] = "AnimAsink",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn2002/LOD0/ugn2002.sananimation",
            },
            ["scoSourceDeath02"] = {
                ["clipName"] = "AnimAsink02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn2002/LOD0/ugn2002.sananimation",
            },
            ["scoSourceDeath03"] = {
                ["clipName"] = "AnimAsink03",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn2002/LOD0/ugn2002.sananimation",
            },
            ["source_animasink02_2"] = {
                ["clipName"] = "AnimAsink02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn2002/LOD0/ugn2002.sananimation",
            },
            ["source_animasink03_3"] = {
                ["clipName"] = "AnimAsink03",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn2002/LOD0/ugn2002.sananimation",
            },
            ["source_animasink_1"] = {
                ["clipName"] = "AnimAsink",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn2002/LOD0/ugn2002.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn2002/LOD0/ugn2002.sananimation",
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
                    ["x"] = 0.288,
                    ["y"] = 0.835,
                    ["z"] = -1.2400000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.35200000000000004,
                    ["y"] = 0.73,
                    ["z"] = 1.1159999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.32000000000000006,
                    ["y"] = 0.8800000000000001,
                    ["z"] = 0.9920000000000001,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.288,
                    ["y"] = 1.09,
                    ["z"] = -1.2400000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.35200000000000004,
                    ["y"] = 1.06,
                    ["z"] = 1.1159999999999999,
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
                ["y"] = 0.46,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1,
                ["y"] = 4.2,
            },
            ["thickness"] = 0.17,
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Front_Right_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "front_barrel",
                    ["pitchMax"] = 30,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 30,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "front_turret",
                    ["yawMax"] = 135,
                    ["yawMin"] = -135,
                    ["yawSpeed"] = 90,
                },
            },
            ["damage"] = 80,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn2002/muzzle_particlegun.sanvfx",
            },
            ["firingRandomness"] = 0.3,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Front_Right_Muzzle",
                        [2] = "Front_Left_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Front_Left_Muzzle"] = {
                    ["aimController"] = "Front_Right_Muzzle",
                },
                ["Front_Right_Muzzle"] = {
                    ["aimController"] = "Front_Right_Muzzle",
                },
            },
            ["name"] = "ParticleGun",
            ["projectileLifetime"] = 5.33333333,
            ["projectileTemplate"] = "psf0092",
            ["rangeMax"] = 80,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "90e8c7adebb2460ed3e2cef3d3ce16a47356e0d21007e7384085cca303d6cd15",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "ParticleGun",
                ["sourceProjectile"] = "/projectiles/CDFProtonCannon02/CDFProtonCannon02_proj.bp",
            },
            ["scoSeaParityTargetGate"] = "TargetAbove",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "ParticleGun",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_Launcher_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 10,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "launcher_barrel",
                    ["pitchMax"] = 80,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 20,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "launcher_turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 115,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn2002/muzzle_aagun.sanvfx",
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
                        [1] = "Right_Launcher_Muzzle01",
                        [2] = "Right_Launcher_Muzzle02",
                        [3] = "Right_Launcher_Muzzle03",
                        [4] = "Left_Launcher_Muzzle01",
                        [5] = "Left_Launcher_Muzzle02",
                        [6] = "Left_Launcher_Muzzle03",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Left_Launcher_Muzzle01"] = {
                    ["aimController"] = "Right_Launcher_Muzzle01",
                },
                ["Left_Launcher_Muzzle02"] = {
                    ["aimController"] = "Right_Launcher_Muzzle01",
                },
                ["Left_Launcher_Muzzle03"] = {
                    ["aimController"] = "Right_Launcher_Muzzle01",
                },
                ["Right_Launcher_Muzzle01"] = {
                    ["aimController"] = "Right_Launcher_Muzzle01",
                },
                ["Right_Launcher_Muzzle02"] = {
                    ["aimController"] = "Right_Launcher_Muzzle01",
                },
                ["Right_Launcher_Muzzle03"] = {
                    ["aimController"] = "Right_Launcher_Muzzle01",
                },
            },
            ["name"] = "AAGun",
            ["projectileLifetime"] = 5.5,
            ["projectileTemplate"] = "psf0083",
            ["rangeMax"] = 75,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1.25,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "a7b08165aca0e481b27001b61bd2e0790f605ab0ce24c87a4734c9d379ae82db",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AAGun",
                ["sourceProjectile"] = "/projectiles/CAANanoDart03/CAANanoDart03_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AAGun",
            },
            ["targetWaterLimits"] = "Above",
        },
        [3] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_Launcher_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "launcher_barrel",
                    ["pitchMax"] = 40,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "launcher_turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 60,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn2002/muzzle_groundgun.sanvfx",
            },
            ["firingRandomness"] = 0.3,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Right_Launcher_Muzzle01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Right_Launcher_Muzzle02",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Right_Launcher_Muzzle03",
                    },
                },
                [4] = {
                    ["muzzles"] = {
                        [1] = "Left_Launcher_Muzzle01",
                    },
                },
                [5] = {
                    ["muzzles"] = {
                        [1] = "Left_Launcher_Muzzle02",
                    },
                },
                [6] = {
                    ["muzzles"] = {
                        [1] = "Left_Launcher_Muzzle03",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.3,
            ["muzzleSalvoSize"] = 6,
            ["muzzles"] = {
                ["Left_Launcher_Muzzle01"] = {
                    ["aimController"] = "Right_Launcher_Muzzle01",
                },
                ["Left_Launcher_Muzzle02"] = {
                    ["aimController"] = "Right_Launcher_Muzzle01",
                },
                ["Left_Launcher_Muzzle03"] = {
                    ["aimController"] = "Right_Launcher_Muzzle01",
                },
                ["Right_Launcher_Muzzle01"] = {
                    ["aimController"] = "Right_Launcher_Muzzle01",
                },
                ["Right_Launcher_Muzzle02"] = {
                    ["aimController"] = "Right_Launcher_Muzzle01",
                },
                ["Right_Launcher_Muzzle03"] = {
                    ["aimController"] = "Right_Launcher_Muzzle01",
                },
            },
            ["name"] = "GroundGun",
            ["projectileLifetime"] = 5.5,
            ["projectileTemplate"] = "psf0082",
            ["rangeMax"] = 80,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 2,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "199bd908af987d0ce1173e112053d699e50c5ff7d43f0fd912166145e8e786d4",
                ["sourceIndex"] = 4,
                ["sourceLabel"] = "GroundGun",
                ["sourceProjectile"] = "/projectiles/CAANanoDart02/CAANanoDart02_proj.bp",
            },
            ["scoSeaParityTargetGate"] = "TargetAbove",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 4,
                ["sourceLabel"] = "GroundGun",
            },
            ["targetWaterLimits"] = "Above",
        },
        [4] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Zapper_Muzzle",
                    ["aimTolerance"] = 5,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "zapper",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 180,
                    ["projectileSpeed"] = 25,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "zapper",
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
                ["onFire"] = "VFX/SCOM/Source/ugn2002/muzzle_zapper.sanvfx",
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
                ["sourceBlueprintSha256"] = "f56250399950f9c11002312d1fd471f0d57c0f65aac18fe30e4c430bf6d6f5f4",
                ["sourceId"] = "URS0202",
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "Zapper",
            },
            ["scoFaSourceWeapon"] = {
                ["Audio"] = {
                    ["Fire"] = {
                        ["Bank"] = "URSWeapon",
                        ["Cue"] = "URS0202_Anti_Missile",
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
                ["MaximumBeamLength"] = 60,
                ["MuzzleSalvoDelay"] = 0,
                ["MuzzleSalvoSize"] = 1,
                ["NeedPrep"] = true,
                ["RackBones"] = {
                    [1] = {
                        ["MuzzleBones"] = {
                            [1] = "Zapper_Muzzle",
                        },
                        ["RackBone"] = "zapper",
                    },
                },
                ["RackFireTogether"] = false,
                ["RackRecoilDistance"] = 0,
                ["RackReloadTimeout"] = 0,
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
                ["TurretBoneMuzzle"] = "Zapper_Muzzle",
                ["TurretBonePitch"] = "zapper",
                ["TurretBoneYaw"] = "zapper",
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
            ["scoFaSourceWeaponIndex"] = 3,
            ["scoSourceInterceptionLabel"] = "Zapper",
            ["scoTacticalBeam"] = true,
            ["scoTacticalOwned"] = true,
        },
    },
}
